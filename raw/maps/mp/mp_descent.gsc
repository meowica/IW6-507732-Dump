#include common_scripts\utility;
#include maps\mp\_utility;

main()
{
	maps\mp\mp_descent_precache::main();
	maps\createart\mp_descent_art::main();
	maps\mp\mp_descent_fx::main();
	
	maps\mp\_load::main();
	
//	AmbientPlay( "ambient_mp_setup_template" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_descent" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit" ] = "woodland";
	
	level thread fall_objects();
	level thread tilt_objects();
	level thread hang_objects();
	level thread gap_objects();
	level thread world_tilt();
	level thread connect_watch();
	level thread spawn_watch();
	
	level thread watersheet_trig_setup();
}

connect_watch()
{
	while(1)
	{
		level waittill("connected", player);
	}
}

spawn_watch()
{
	while(1)
	{
		level waittill( "player_spawned", player );
		if(IsDefined(level.vista))
			player PlayerSetGroundReferenceEnt(level.vista);	
	}
}

anglesClamp180(angles)
{
	return (AngleClamp180(angles[0]),AngleClamp180(angles[1]),AngleClamp180(angles[2]));
}

world_tilt()
{
	while(!IsDefined(level.players))
		wait .05;
	
	vista_ents = GetEntArray("vista", "targetname");
	if(!vista_ents.size)
		return;
	
	level.vista = vista_ents[0];
	foreach(ent in vista_ents)
	{
		if(IsDefined(ent.script_noteworthy) && ent.script_noteworthy=="main")
		{
			level.vista = ent;
			break;
		}
	}
	
	//Init rotation Origins
	level.vista_rotation_origins = [];
	rotation_orgs = getstructarray("rotation_point", "targetname");
	foreach(org in rotation_orgs)
	{
		if(!isDefined(org.script_noteworthy))
			continue;
		
		org.angles = (0,0,0);
		
		level.vista_rotation_origins[ org.script_noteworthy ] = org;
	}

	foreach(player in level.players)
	{
		player PlayerSetGroundReferenceEnt(level.vista);
	}
	
	foreach(ent in vista_ents)
	{
		if(ent!=level.vista)
		{
			if( IsDefined(ent.classname) && IsSubStr( ent.classname, "trigger" ))
				ent EnableLinkTo();
			ent LinkTo(level.vista);
		}
		if(!IsDefined(ent.target))
			continue;
		
		targets = GetEntArray(ent.target, "targetname");
		foreach(target in targets)
		{
			if(!IsDefined(target.script_noteworthy))
				target.script_noteworthy = "link";
			
			switch(target.script_noteworthy)
			{
				case "link":
					target LinkTo(ent);
					break;
				default:
					break;
			}
		}
	}

	max_abs_pitch = 8;
	max_abs_roll = 8;
	max_fall_dist = 6500;
	num_lerp_tilts = 2; //scale first num_lerp_tilts to be less severe
	tilt_chance = .5; //Chance of playspace being level after a fall.
	multi_fall_chance = [0,0,1,0]; //[ignored, ignored, double_fall_chance, triple_fall_chance]
	
	test_vista = SpawnStruct();
	test_vista.origin = level.vista.origin;
	test_vista.angles = level.vista.angles;
	
	//Create random falls until the building is on (near) the ground
	vista_trans = [];
	while(1)
	{
		rotate_to = (0,0,0);
		if(tilt_chance<RandomFloat(1))
		{
			rotate_to = (RandomFloatRange(-1*max_abs_pitch, max_abs_pitch), 0, RandomFloatRange(-1*max_abs_roll, max_abs_roll));
		}
		
		move_by = (0,0,RandomFloatRange(200,1000));
		
		scale = 1;
		if(num_lerp_tilts>0)
		{
			scale = (vista_trans.size+1)/num_lerp_tilts;
			scale = clamp(scale, 0, 1.0);
		}
		
		rotate_to *= scale;
		move_by *= scale;
		
		trans = test_vista world_tilt_get_trans(move_by, rotate_to);
		if(trans["origin"][2] > level.vista.origin[2] + max_fall_dist)
		{
			break;
		}
		trans["time"] = RandomFloatRange(1,2) * scale;
		
		test_vista.origin = trans["origin"];
		test_vista.angles = trans["angles"];
		
		vista_trans[vista_trans.size] = trans;	
	}
	
	fall_count = vista_trans.size;
	
	//Distribute any extra fall distance across existing falls
	extra_z = level.vista.origin[2] + max_fall_dist - vista_trans[vista_trans.size-1]["origin"][2];
	if(extra_z > 0)
	{
		add_z = array_zero_to_one(vista_trans.size, .5);
		for(i=0; i<vista_trans.size; i++)
		{
			vista_trans[i]["origin"] += (0,0,add_z[i]*extra_z);
		}
	}
	
	//Calculate wait times
	fall_wait_times = array_zero_to_one(fall_count, .5);
	for(i=0; i<fall_wait_times.size-1; i++)
	{
		multi_fall_start = i;
		multi_fall_end = i;
		
		chance = RandomFloatRange(0,1);
		max_falls = int(min(multi_fall_chance.size-1, fall_wait_times.size-i));
		for(j=max_falls; j>=2; j--)
		{
			if(multi_fall_chance[j]>chance)
			{
				multi_fall_end = multi_fall_start+(j-1);
				break;
			}
		}
		
		//Redistribute the wait times if there is a double/triple fall
		multi_fall_count = multi_fall_end - multi_fall_start;
		if(multi_fall_count>0)
		{
			delta = fall_wait_times[multi_fall_end] - fall_wait_times[multi_fall_start];
			delta *= RandomFloatRange(.2, .8);
			
			new_time = fall_wait_times[multi_fall_start] + delta;
			for(j=multi_fall_start; j<=multi_fall_end; j++)
			{
				fall_wait_times[j] = new_time;
			}
			i+=multi_fall_count;	
		}
	}
	
	
	//Assign fall objects to a fall stage
	level.fall_object_stage = [];
	for(i=0; i<fall_count; i++)
	{
		level.fall_object_stage[i] = [];
	}
	
	for(i=0; i<level.fall_objects.size; i++)
	{
		fall_object = level.fall_objects[i];
		if( !IsDefined(fall_object.script_index) )
		{
			fall_object.script_index = RandomIntRange(0, fall_count);
		}
		else
		{
			fall_object.script_index = fall_object.script_index % fall_count;
		}
		
		count = level.fall_object_stage[fall_object.script_index].size;
		level.fall_object_stage[fall_object.script_index][count] = fall_object;
	}
	
	
	for(i=0; i<vista_trans.size; i++)
	{
		tilt_wait(fall_wait_times[i]);
	
		trans = vista_trans[i];
		move_time = trans["time"];
		
		foreach(object in level.fall_object_stage[i])
		{
			object thread fall_object_run( RandomFloatRange(move_time*.25, move_time*.75) );
		}
		
		foreach(object in level.tilt_objects)
		{
			object thread tilt_object_run(trans["angles"][0], trans["angles"][2], max_abs_pitch, max_abs_roll);
		}
		
		foreach(object in level.hang_objects)
		{
			object thread hang_object_run(trans["angles"], move_time);
		}
		
		trans = vista_trans[i];
		level.vista world_tilt_move(trans);
		Earthquake(.35, 2, level.vista.origin, 100000);
		
		gap_object_moves = 0;
		max_gap_object_moves = 6;
		level.gap_objects = array_randomize(level.gap_objects);
		for(j=0; j<level.gap_objects.size && gap_object_moves<max_gap_object_moves; j++)
		{
			object = level.gap_objects[j];
			if(IsDefined(object) && !object.fallen)
			{
				object notify("gap_object_move");
				gap_object_moves++;
			}
		}
	}
}

wait_game_percent_complete( time_percent, score_percent )
{
	if(!IsDefined(score_percent))
		score_percent = time_percent;

	gameFlagWait( "prematch_done" );
	
	score_limit = getScoreLimit();
	time_limit	= getTimeLimit() * 60;
	
	ignore_score = false;
	ignore_time = false;
	
	if( ( score_limit <= 0 ) && ( time_limit <= 0 ) )
	{
		ignore_score = true;
		time_limit = 10*60;
	}
	else if ( score_limit <= 0 )
	{
		ignore_score = true;
	}
	else if( time_limit <= 0 )
	{
		ignore_time = true;
	}
	
	time_threshold = time_percent * time_limit;
	score_threshold = score_percent * score_limit;

	higher_score = get_higher_score();
	timePassed = (getTime() - level.startTime) / 1000;
	
	if( ignore_score )
	{
		while( timePassed < time_threshold )
		{
			wait( 0.5 );
			timePassed = (getTime() - level.startTime) / 1000;
		}
	}
	else if( ignore_time )
	{
		while( higher_score < score_threshold )
		{
			wait( 0.5 );
			higher_score = get_higher_score();
		}
	}
	else
	{
		while( ( timePassed < time_threshold ) && ( higher_score < score_threshold ) )
		{
			wait( 0.5 );
			higher_score = get_higher_score();
			timePassed = (getTime() - level.startTime) / 1000;
		}		
	}
}

get_higher_score()
{
	higher_score = game["teamScores"]["allies"];
	if( game["teamScores"]["axis"] > higher_score )
	{
		higher_score = game["teamScores"]["axis"];
	}
	return higher_score;
}

world_tilt_get_trans(move_delta, rotate_to)
{
	delta_angles = anglesClamp180(rotate_to - self.angles);
	
	rotation_point = level.vista_rotation_origins["south"];
	if(delta_angles[2]<0)
	{
		rotation_point = level.vista_rotation_origins["north"];
	}
	
	rotation_point.angles = self.angles;
	
	goal = SpawnStruct();
	goal.origin = rotation_point.origin + move_delta;
	goal.angles = rotate_to;
	
	trans = TransformMove(goal.origin, goal.angles, rotation_point.origin, rotation_point.angles, self.origin, self.angles);

	return trans;	
}

world_tilt_move(trans)
{
	exploder(1);
	level thread tilt_sounds();

	move_time = trans["time"];
	if(trans["origin"] != self.origin )
		self MoveTo(trans["origin"], move_time, move_time);
	if(anglesClamp180(trans["angles"]) != anglesClamp180(self.angles) )
		self RotateTo(trans["angles"], move_time);
	
	Earthquake(RandomFloatRange(.3, .5), move_time, self.origin, 100000);
	wait move_time;
}

array_zero_to_one_rand(count, min_value, max_value, sum_to)
{
	if(!IsDefined(min_value))
		min_value = 0;
	if(!IsDefined(max_value))
		max_value = 1;
	
	a = [];
	sum = 0;
	for(i=0; i<count; i++)
	{
		a[i] = RandomFloatRange(min_value, max_value);
		sum += a[i];
	}
	
	if(IsDefined(sum_to))
	{

		for(i=0; i<count; i++)
		{
			if(sum!=0)
			{
				a[i] = a[i] / sum;
				a[i] = a[i] * sum_to;
			}
			else
			{
				a[i] = sum_to/count;
			}
		}
	}
	
	return a;
}

array_zero_to_one(count, rand, sum_to)
{
	if(!IsDefined(rand))
		rand = 0;
	
	a = [];
	
	center_offset = (1/count) * .5;
	sum = 0;
	for(i=0; i<count; i++)
	{
		a[i] = (i/count) + center_offset;
	
		if(rand>0)
		{
			a[i] = a[i] + RandomFloatRange(-1*center_offset*rand, center_offset*rand);
		}
		
		sum += a[i];
	}
	
	if(IsDefined(sum_to))
	{
		for(i=0; i<count; i++)
		{
			a[i] = a[i] / sum;
			a[i] = a[i] * sum_to;
		}
	}
	
	return a;
}

tilt_wait(game_percent)
{
	level endon("tilt_start");
	/#
		level thread tilt_wait_dvar();
	#/
	wait_game_percent_complete(game_percent);
	level notify("tilt_start");
}

tilt_wait_dvar()
{
	level endon("tilt_start");
	
	dvar_name = "trigger_tilt";
	default_value = 0;
	SetDvarIfUninitialized(dvar_name, default_value);
	
	while(GetDvarInt(dvar_name) == default_value)
	{
		waitframe();
	}
	SetDvar(dvar_name, GetDvarInt(dvar_name)-1);
	
	level notify("tilt_start");	
}

tilt_sounds()
{
	sound_origins = getstructarray("tilt_sound", "targetname");
	
	foreach(org in sound_origins)
	{
		playSoundAtPos(org.origin, "cobra_helicopter_crash");
	}
}

gap_objects()
{
	level.gap_objects = [];
	objects = GetEntArray("gap_object", "targetname");
	array_thread(objects, ::gap_object_init);		
}

gap_object_init()
{
	self.fallen = false;
	self thread gap_object_damage_watch();
	self thread gap_object_move();
	level.gap_objects[level.gap_objects.size] = self;
}

gap_object_damage_watch()
{
	self endon("death");
	self endon("gap_object_fall");
	
	self SetCanDamage(true);
	
	while(1)
	{
		self.health = 10000;
		self waittill("damage");
		self notify("gap_object_move");
	}
}

gap_object_move()
{
	self endon("death");
	
	num_moves = RandomIntRange(2,4);
	
	while(1)
	{
		self waittill("gap_object_move");
		
		num_moves--;
		if(num_moves<=0)
			break;
		
		move_time = .2;
		self RotateTo((RandomFloatRange(-4,4), 0, RandomFloatRange(-4,4)), move_time);
		self MoveTo(self.origin + (0,0,-2), move_time);
		wait move_time;
	}
	
	self notify("gap_object_fall");
	self.fallen = true;
	
	fall_time = 20;
	self MoveGravity((0,0,-20), 20);
	wait fall_time;
	self Delete();
}

hang_objects()
{
	level.hang_objects = [];
	objects = GetEntArray("hang_object", "targetname");
	array_thread(objects, ::hang_object_init);		
}

hang_object_init()
{
	self.move_ent = self;
	
	things = [];
	
	if(IsDefined(self.target))
	{
		structs = getstructarray(self.target, "targetname");
		ents = GetEntArray(self.target, "targetname");
	
		things = array_combine(ents, structs);
	}
	
	foreach(thing in things)
	{
		type = thing.script_noteworthy;
		if(!IsDefined(type))
			continue;
			
		switch(type)
		{
			case "link":
				thing linkto(self);
				break;
			default:
				break;
		}
	}
	
	level.hang_objects[level.hang_objects.size] = self;
}

hang_object_run(rotate_to, move_time)
{
	self.move_ent RotateTo(rotate_to, move_time);
}

tilt_objects()
{
	level.tilt_objects = [];
	objects = GetEntArray("tilt_object", "targetname");
	array_thread(objects, ::tilt_object_init);	
}

tilt_object_init()
{
	self.positions = [];
	self.move_ent = self;
	
	self.start_origin = self.origin;
	self.start_angles = self.angles;
	
	pos_names = ["current", "current_ns", "current_we", "north", "south", "east", "west"];
	foreach(name in pos_names)
	{
		s = SpawnStruct();
		s.origin_offset = (0,0,0);
		s.angles_offset = (0,0,0);
		self.positions[name] = s;
	}
	
	things = [];
	
	if(IsDefined(self.target))
	{
		structs = getstructarray(self.target, "targetname");
		things = array_combine(things, structs);
		
		ents = GetEntArray(self.target, "targetname");
		things = array_combine(things, ents);
	}
		
	if(IsDefined(self.script_linkto))
	{
		structs = self get_linked_structs();
		things = array_combine(things, structs);
		
		ents = self get_linked_ents();
		things = array_combine(things, ents);
	}
	
	foreach(thing in things)
	{
		type = thing.script_noteworthy;
		if(!IsDefined(type))
			continue;
			
		switch(type)
		{
			case "link":
				thing linkto(self);
				break;
			case "angle_ref":
				self.move_ent = spawn("script_model", thing.origin);
				self.move_ent SetModel("tag_origin");
				self.move_ent.angles = thing.angles;
				self linkTo(self.move_ent);
				
				self.start_origin = thing.origin;
				self.start_angles = thing.angles;
				break;
			case "north":
			case "south":
			case "east":
			case "west":
				self.positions[type].target = thing;
				break;
			default:
				break;
		}
	}
	
	any_pos_defined = false;
	foreach(name in pos_names)
	{
		thing = self.positions[name].target;
		if(IsDefined(thing))
		{
			any_pos_defined = true;
			self.positions[name].origin_offset = thing.origin - self.start_origin;
			self.positions[name].angles_offset = delta_angles(self.start_angles, thing.angles);
		}
	}
	
	if(any_pos_defined)
	{
		level.tilt_objects[level.tilt_objects.size] = self;
	}
}

delta_angles(from, to)
{
	p = AnglesDelta((from[0], 0, 0), (to[0], 0, 0));
	y = AnglesDelta((0, from[1], 0), (0, to[1], 0));
	r = AnglesDelta((0, 0, from[2]), (0, 0, to[2]));
	
	return (p, y, r);
}

tilt_object_run(set_pitch, set_roll, max_pitch, max_roll)
{
	self notify("tilt_object_run");
	self endon("tilt_object_run");
	
	pos_a = self.positions["current_we"];
	pos_a_lerp = 1;
	if(abs(set_pitch)>0.1)
	{
		if(set_pitch<0)
		{
			
			pos_a = self.positions["west"];
		}
		else
		{
			pos_a = self.positions["east"];
		}
		self.positions["current_we"] = pos_a;
	}
	

	pos_b = self.positions["current_ns"];
	pos_b_lerp = 1;
	if(abs(set_roll)>0.1)
	{
		if(set_roll<0)
		{
			pos_b = self.positions["south"];
		}
		else
		{
			pos_b = self.positions["north"];
		}
		
		self.positions["current_ns"] = pos_b;
	}
	
	new_origin_offset = (0,0,0);
	new_origin_offset += pos_a.origin_offset * pos_a_lerp;
	new_origin_offset += pos_b.origin_offset * pos_b_lerp;
	self.positions["current"].origin_offset = new_origin_offset;
	
	new_angles_offset = (0,0,0);
	new_angles_offset += pos_a.angles_offset * pos_a_lerp;
	new_angles_offset += pos_b.angles_offset * pos_b_lerp;
	self.positions["current"].angles_offset = new_angles_offset;
	
	new_origin = self.start_origin + self.positions["current"].origin_offset;
	new_angles = self.start_angles + self.positions["current"].angles_offset;
	
	move_time = 3;
	
	if(new_origin!=self.move_ent.origin)
		self.move_ent MoveTo(new_origin, move_time, move_time*.3, move_time*.3);
	if(anglesClamp180(new_angles) != anglesClamp180(self.move_ent.angles))
		self.move_ent rotateTo(new_angles, move_time);
	
	wait move_time;
		
	if(self is_dynamic_path())
		self DisconnectPaths();
}

is_dynamic_path()
{
	return IsDefined(self.spawnflags) && self.spawnflags&1;
}

fall_objects()
{
	level.fall_objects = [];
	objects = GetEntArray("fall_object", "targetname");
	array_thread(objects, ::fall_object_init);
}

fall_object_init()
{
	self.end = self;
	self.clip_move = [];
	self.connect_paths = [];
	self.disconnect_paths = [];
	
	things = [];
	
	if(IsDefined(self.target))
	{
		structs = getstructarray(self.target, "targetname");
		set_default_script_noteworthy(structs, "angle_ref");
		things = array_combine(things, structs);
		
		ents = GetEntArray(self.target, "targetname");
		things = array_combine(things, ents);
	}
		
	if(IsDefined(self.script_linkto))
	{
		structs = self get_linked_structs();
		set_default_script_noteworthy(structs, "start");
		things = array_combine(things, structs);
		
		ents = self get_linked_ents();
		things = array_combine(things, ents);
	}
	
	foreach(thing in things)
	{
		if(!IsDefined(thing.script_noteworthy))
			continue;
			
		switch(thing.script_noteworthy)
		{
			case "angle_ref":
				self.end = thing;
				break;
			case "start":
				self.start = thing;
				break;
			case "link":
				thing linkto(self);
				break;
			case "connect_paths":
				self.connect_paths[self.connect_paths.size] = thing;
				thing DisconnectPaths();
				break;
			case "disconnect_paths":
				self.disconnect_paths[self.disconnect_paths.size] = thing;
				thing ConnectPaths();
				break;
			case "clip_move":
				thing.start_origin = thing.origin;
				self.clip_move[self.clip_move.size] = thing;
				break;
			default:
				break;
		}
	}
	
	set_default_angles(things);
	
	if(IsDefined(self.start) && IsDefined(self.end))
	{
		level.fall_objects[level.fall_objects.size] = self;
		self fall_object_set_start_pos();
	}
}

set_default_script_noteworthy(things, noteworthy)
{
	if(!IsDefined(things))
		return;
	
	if(!IsDefined(noteworthy))
		noteworthy = "";
	
	if(!isArray(things))
		things = [things];
	
	foreach(thing in things)
	{
		if(!IsDefined(thing.script_noteworthy))
			thing.script_noteworthy = noteworthy;
	}
}

set_default_angles(things, angles)
{
	if(!IsDefined(things))
		return;
	
	if(!IsDefined(angles))
		angles = (0,0,0);
	
	if(!isArray(things))
		things = [things];
	
	foreach(thing in things)
	{
		if(!IsDefined(thing.angles))
			thing.angles = angles;
	}
}

fall_object_set_start_pos()
{
	self.fall_to_origin = self.origin;
	self.fall_to_angles = self.angles;
	
	trans = TransformMove(self.start.origin, self.start.angles, self.end.origin, self.end.angles, self.origin, self.angles);
	self.origin = trans["origin"];
	self.angles = trans["angles"];
}

fall_object_run(delayTime)
{
	//Hack revisit this
	if(IsDefined(self.fall_object_done) && self.fall_object_done)
		return;
	
	self.fall_object_done = true;
	
	
	if(isDefined(delayTime) && delayTime>0)
		wait delayTime;
	
	//Move clip into place first
	if(self.clip_move.size)
	{
		clip_move_time = .5;
		foreach(clip in self.clip_move)
		{
			clip MoveTo(self.fall_to_origin, clip_move_time );
		}
		wait clip_move_time;
		
		foreach(clip in self.clip_move)
		{
			if(clip fall_object_is_dynamic_path())
				clip DisconnectPaths();
		}
	}
	
	fall_speed = RandomFloatRange(300,320);
	dist = Distance(self.fall_to_origin, self.origin);
	time = dist/fall_speed;
	
	self moveTo(self.fall_to_origin, time, time, 0);
	if(self.fall_to_angles != self.angles)
		self RotateTo(self.fall_to_angles, time, 0, 0);
	
	self thread fall_object_unresolved_collision_watch();
	
	wait time;
	
	self notify("stop_unresolved_collision_watch");
	
	foreach(ent in self.disconnect_paths)
	{
		ent DisconnectPaths(); 
	}
	
	foreach(ent in self.connect_paths)
	{
		ent ConnectPaths();
		ent Delete();
	}
	
	foreach(clip in self.clip_move)
	{
		clip.origin = clip.start_origin;
	}
}

fall_object_is_dynamic_path()
{
	return self.spawnflags&1;
}

fall_object_unresolved_collision_watch()
{
	self endon("death");
	self endon("stop_unresolved_collision_watch");
	
	while(1)
	{
		self waittill("unresolved_collision", player);
		player _suicide();
	}
	
}

//Move to common script
get_linked_structs()
{
	array = [];

	if ( IsDefined( self.script_linkTo ) )
	{
		linknames = get_links();
		for ( i = 0; i < linknames.size; i++ )
		{
			ent = getstruct( linknames[ i ], "script_linkname" );
			if ( IsDefined( ent ) )
			{
				array[ array.size ] = ent;
			}
		}
	}

	return array;
}

watersheet_trig_setup()
{
	
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "using_remote" );
	self endon( "stopped_using_remote" );	
	self endon( "disconnect" );
	self endon( "above_water" );
	
	trig = getent("watersheet", "targetname" );	
	//level.player ent_flag_init("water_sheet_sound");
	//level thread watersheet_sound( trig );
	
	while(1)
	{
			
		trig waittill("trigger", player );
		
		if ( !isDefined(player.isTouchingWaterSheetTrigger) || player.isTouchingWaterSheetTrigger == false)
		{
			
			thread watersheet_PlayFX( player );
		
		}
	
	}	
}

watersheet_PlayFX( player ) {
	
		player.isTouchingWaterSheetTrigger = true;
	
		player SetWaterSheeting( 1, 2 );
		wait( randomfloatrange( .15, .75) );
		player SetWaterSheeting( 0 );	
		
		player.isTouchingWaterSheetTrigger = false;
	
}

watersheet_sound( trig )
{
	trig endon("death");
	thread watersheet_sound_play(trig);
	while( 1 )
	{
		trig waittill( "trigger", player );
		
		trig.sound_end_time = GetTime() + 100;
		trig notify("start_sound");
	}
}

watersheet_sound_play(trig)
{
	trig endon("death");
	
	while(1)
	{
		trig waittill("start_sound");
		
		trig PlayLoopSound("scn_jungle_under_falls_plr");
		
		while(trig.sound_end_time>GetTime())
			wait (trig.sound_end_time-GetTime())/1000;
		
		trig StopLoopSound();
	}
}