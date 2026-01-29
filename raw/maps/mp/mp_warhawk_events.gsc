#include common_scripts\utility;
#include maps\mp\_utility;

#using_animtree("animated_props");
precache()
{
	level.heli_anims = [];
	level.heli_anims["heli_flyby_01"] = "mp_warhawk_heli_flyby_01";
	level.heli_anims["heli_flyby_02"] = "mp_warhawk_heli_flyby_02";
	level.heli_anims_length = [];
	level.heli_anims_length["heli_flyby_01"] = GetAnimLength( %mp_warhawk_heli_flyby_01 );
	level.heli_anims_length["heli_flyby_02"] = GetAnimLength( %mp_warhawk_heli_flyby_02 );
	
	level.air_raid_active = false;

//	PrecacheMpAnim( "mp_warhawk_metal_door_closed_loop" );
	PrecacheMpAnim( "mp_warhawk_metal_door_open_in" );
	PrecacheMpAnim( "mp_warhawk_metal_door_open_in_loop" );
	PrecacheMpAnim( "mp_warhawk_metal_door_open_out" );
	PrecacheMpAnim( "mp_warhawk_metal_door_open_out_loop" );
	PrecacheMpAnim( "mp_frag_metal_door_chain" );

}

random_destruction( min_wait_time, max_wait_time )
{
	level endon("stop_dynamic_events");
	
	destructible_array = getstructarray( "random_destructible", "targetname" );

	random_destruction_preprocess( destructible_array );
	
	while( destructible_array.size > 0 )
	{
		wait_time = RandomFloatRange( min_wait_time, max_wait_time );
		wait( wait_time );
		
		destructible_array = array_randomize( destructible_array );
		if(destructible_array[0].mortar_starts.size>0 && destructible_array[0].mortar_ends.size>0)
		{
			start = random(destructible_array[0].mortar_starts);
			end = random(destructible_array[0].mortar_ends);
			random_mortars_fire(start.origin, end.origin);
		}
		
		destructible_entity_targets = GetEntArray( destructible_array[0].target, "targetname" );

		foreach( destructible_element in destructible_entity_targets )
		{
			switch( destructible_element.script_noteworthy )
			{
				case "destructible_before":
					destructible_element trigger_off();
					break;	
					
				case "destructible_after":
					destructible_element trigger_on();
					break;
					
				case "undefined":
				default:
					break;
			}
		}
		
		destructible_struct_targets = getstructarray( destructible_array[0].target, "targetname" );
		foreach( destructible_element in destructible_struct_targets )
		{	
			if( IsDefined( destructible_element.script_noteworthy ) && IsDefined(level._effect[ destructible_element.script_noteworthy ]) )
			{
				PlayFX( level._effect[ destructible_element.script_noteworthy ], destructible_element.origin );
			}
		}
		
		if ( IsDefined( destructible_array[ 0 ].script_parameters ) )
		{
			params = StrTok( destructible_array[ 0 ].script_parameters, ";" );
			foreach ( param in params )
			{
				toks = StrTok( param, "=" );
				if ( toks.size!= 2 )
				{
					continue;
				}
				
				switch( toks[ 0 ] )
				{
					case "play_sound":
						playSoundAtPos( destructible_array[ 0 ].origin, toks[1] );
						break;
					case "play_fx":
						PlayFX( level._effect[ toks[1] ], destructible_array[ 0 ].origin );
						break;
					default:
						break;
				}
			}
		}

		destructible_array = array_remove( destructible_array, destructible_array[0] );			
	}	
}

random_destruction_preprocess( destructible_array )
{
	foreach( element in destructible_array )
	{
		element.mortar_starts = [];
		element.mortar_ends = [];
		
		destructible_before = [];
		
		ents = GetEntArray( element.target, "targetname" );
		structs = getstructarray( element.target, "targetname" );
		destructible_targets = array_combine(structs, ents);
		
		foreach( destructible_element in destructible_targets )
		{
			switch( destructible_element.script_noteworthy )
			{
				case "destructible_after":
					destructible_element trigger_off();
					break;
				case "mortar_start":
					element.mortar_starts[element.mortar_starts.size] = destructible_element;
					break;
				case "mortar_end":
					element.mortar_ends[element.mortar_ends.size] = destructible_element;
					break;
				case "destructible_before":
					//May need to be choosen as a mortar end point
					destructible_before[destructible_before.size] = destructible_element;
					break;
				case "undefined":
				default:
					break;
			}
		}

		if(element.mortar_starts.size==0)
		{
			element.mortar_starts = getstructarray("mortar_start", "targetname");
		}
		
		if(element.mortar_ends.size==0)
		{
			element.mortar_ends = destructible_before;
		}
				
	}
}

#using_animtree("animated_props");
plane_crash()
{
//	level._effect["osprey_crash"] = LoadFX("fx/explosions/helicopter_explosion_osprey_ground");
//	level._effect["osprey_burn"] = LoadFX("fx/fire/heli_crash_fire");
//	
//	level.plane_crash_anims = [];
//	level.plane_crash_anims_events = [];
//	
//	//Anims
//	level.plane_crash_anims["mp_warhawk_osprey_crash"] = %mp_warhawk_osprey_crash;
//	
//	foreach(key,value in level.plane_crash_anims)
//	{
//		PrecacheMpAnim(key);
//		level.plane_crash_anims_events[key] = [];
//		level.plane_crash_anims_events[key][0] = create_anim_event("start", 0.0);
//	}
//	
//	//Events
//	name = "mp_warhawk_osprey_crash";
//	anim_events = [];
//	anim_events["crash_sound"] = 3.37;
//	anim_events["hit_watertower"] = 5.23;
//	anim_events["hit_ground"] = 8.37;
//	
//	foreach(event_name, time in anim_events)
//	{
//		size = level.plane_crash_anims_events[name].size;
//		level.plane_crash_anims_events[name][size] = create_anim_event(event_name, time);
//	}
//	
//	foreach(key,value in level.plane_crash_anims)
//	{
//		//End event must be last
//		num_events = level.plane_crash_anims_events[key].size;
//		level.plane_crash_anims_events[key][num_events] = create_anim_event("end", GetAnimLength(level.plane_crash_anims[key]) );
//	}
//	
//	planes = getstructarray("plane_crash", "targetname");
//	array_thread(planes, ::plane_crash_init);
}

plane_crash_init()
{
	if(!IsDefined(self.target))
		return;
	if(!isDefined(self.script_animation) || !IsDefined(level.plane_crash_anims[self.script_animation]))
		return;
	
	ents = GetEntArray(self.target, "targetname");
	structs = getstructarray(self.target, "targetname");
	
	targets = array_combine(ents, structs);
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch ( target.script_noteworthy )
		{
			case "plane":
				self.plane = target;
				self thread run_func_on_notify("end", ::delete_ent, target);
				break;
			case "scene_node":
				self.scene_node = target;
				if(!IsDefined(self.scene_node.angles))
					self.scene_node.angles = (0,0,0);
				break;
			case "show":
				target Hide();
				self thread run_func_on_notify(target.script_parameters, ::show_ent, target);
				break;
			case "show_trigger":
				target trigger_off();
				self thread run_func_on_notify(target.script_parameters, ::show_trigger, target);
				break;
			case "kill_players":
				self thread run_func_on_notify(target.script_parameters, ::kill_players_touching_ent, target);
				break;
			case "delete":
				self thread run_func_on_notify(target.script_parameters, ::delete_ent, target);
				break;
			case "fx":
				self thread run_func_on_notify(target.script_parameters, ::play_fx, target);
				break;
			case "trigger_fx":
				if(IsDefined(target.script_fxid) && IsDefined(level._effect[target.script_fxid]))
				{
					fx_ent = SpawnFx(level._effect[target.script_fxid], target.origin, AnglesToForward(target.angles));
					self thread run_func_on_notify(target.script_parameters, ::trigger_fx, fx_ent);
				}
				break;
			default:
				break;
		}
	}
	
	if(self.script_animation == "mp_warhawk_osprey_crash")
	{
		self thread run_func_on_notify("start", ::play_fx_on_tag, "osprey_trail", "tag_engine_ri_fx2", self.plane);
		self thread run_func_on_notify("crash_sound", ::play_sound_on_ent, self.plane, "osprey_crash");
		self thread run_func_on_notify("hit_watertower", ::play_sound_at_ent, self.plane, "osprey_hit_tower");
		self thread run_func_on_notify("hit_ground", ::stop_fx_on_tag, "osprey_trail", "tag_engine_ri_fx2", self.plane);
	}
	
	//if(IsDefined(self.plane))
	//	self thread plan_crash_run(RandomIntRange(60,60*3));
}

plan_crash_run(waitTime)
{
	level endon("stop_dynamic_events");
	
	if(IsDefined(waitTime))
		wait waitTime;
	
	if(IsDefined(self.scene_node))
	{
		self.plane.origin = self.scene_node.origin;
		self.plane.angles = self.scene_node.angles;
	}
	self.plane ScriptModelPlayAnimDeltaMotion(self.script_animation);
	self thread run_anim_events(level.plane_crash_anims_events[self.script_animation]);
}


create_anim_event(note, time)
{
	s = SpawnStruct();
	s.time = time;
	s.note = note;
	s.done = false;
	
	return s;
}

run_anim_events(events)
{
	start_time = GetTime();
	while(1)
	{
		foreach(event in events)
		{
			if(event.done)
				continue;
			
			if((GetTime()-start_time)/1000 >= event.time)
			{
				self notify(event.note);
				event.done = true;
				if(event.note == "end")
					return;
			}
		}
		wait .05;
	}
}

run_func_on_notify(note, func, param1, param2, param3)
{
	self waittill(note);
	
	if(IsDefined(param3))
	{
		self thread [[func]](param1, param2, param3);
	}
	else if(IsDefined(param2))
	{
		self thread [[func]](param1, param2);
	}
	else if(IsDefined(param1))
	{
		self thread [[func]](param1);
	}
	else
	{
		self thread [[func]]();
	}
}

show_ent(ent)
{
	ent Show();
}

show_trigger(ent)
{
	ent trigger_on();
}

delete_ent(ent)
{
	ent Delete();
}

play_sound_on_ent(ent, sound)
{
	ent PlaySound(sound);
}

play_sound_at_ent(ent, sound)
{
	playSoundAtPos(ent.origin, sound);
}

kill_players_touching_ent(ent)
{
	foreach(player in level.players)
	{
		if(player IsTouching(ent))
		{
			player _suicide();
		}
	}
}

play_fx(ent)
{
	if(!IsDefined(ent.script_fxid) || !IsDefined(level._effect[ent.script_fxid]))
		return;
	
	PlayFX(level._effect[ent.script_fxid], ent.origin, AnglesToForward(ent.angles));
}

trigger_fx(ent)
{
	TriggerFX(ent);
}

play_fx_on_tag(fx, tag, ent)
{
	PlayFXOnTag( getfx(fx), ent, tag );
}

stop_fx_on_tag(fx, tag, ent)
{
	StopFXOnTag( getfx(fx), ent, tag );
}

random_mortars()
{
	level.random_mortar_models = [];
	
	mortars = getstructarray("mortar_start", "targetname");
	
	while(1)
	{
		mortars = array_randomize(mortars);
		for(i=0;i<mortars.size;i++)
		{
			mortar = mortars[i];
			target_org = mortar random_mortars_get_target();
			if(!IsDefined(target_org))
				continue;
			
			level thread random_mortars_fire(mortar.origin, target_org);
		
			wait RandomFloatRange(3,10);
		}
		
		wait RandomFloatRange(3,10);
	}
}
	
random_mortars_fire(start_org, end_org)
{
	dirt_effect_radius = 350;
	
	mortar_model = random_mortars_get_model(start_org);
	mortar_model.origin = start_org;
	mortar_model.in_use = true;
	
	waitframe();//Model may have just spawned
	PlayFXOnTag( getfx("random_mortars_trail"), mortar_model, "tag_fx");
	
	air_time = RandomFloatRange(3,4);
	launch_dir = trajectorycalculateinitialvelocity(start_org, end_org, (0,0,-800), air_time);
	
	mortar_model.angles = VectorToAngles(launch_dir) * (-1,1,1);
	
	delayThread(air_time-1.5, ::random_mortars_incoming_sound, end_org);
	
	mortar_model MoveGravity(launch_dir, air_time);
	//mortar_model thread draw_move_path();
	//mortar_model thread draw_model_path();
	mortar_model waittill("movedone");
	
	foreach ( player in level.players )
	{
		if(player.health<player.maxhealth)
			continue;
		
		distSqr = DistanceSquared(player.origin, end_org);
		if(distSqr<140*140)
		{
			player DoDamage(5, end_org);
		}
	}
	
	PlayRumbleOnPosition("artillery_rumble", end_org);
	
	foreach ( player in level.players )
	{
		if ( player isUsingRemote() )
		{
			continue;
		}
		
		if ( distance( end_org, player.origin ) > dirt_effect_radius )
		{
			continue;
		}
		
		if ( player DamageConeTrace( end_org ) )
		{
			player thread maps\mp\gametypes\_shellshock::dirtEffect( end_org );
		}
	}
	
	PlayFX( getfx("random_mortars_impact"), end_org);
	StopFXOnTag(getfx("random_mortars_trail"), mortar_model, "tag_fx");
	waitframe();
	mortar_model.origin = start_org; //"hide" it
	mortar_model.in_use = false;
	
}

random_mortars_incoming_sound(org)
{
	playSoundAtPos( org, "mortar_incoming" );
}

random_mortars_get_target()
{
	targets = getstructarray(self.target, "targetname");
	if(targets.size==0)
		return undefined;
	
	target = random(targets);
	
	org = target.origin;
	if(IsDefined(target.radius))
	{
		dir = AnglesToForward((0,RandomFloatRange(0,360),0));
		org = org + (dir*RandomFloatRange(0,target.radius));
	}
	return org;
}

random_mortars_get_model(origin)
{
	if(!IsDefined(level.random_mortar_models))
		level.random_mortar_models = [];
	
	mortar_model = undefined;
	
	foreach ( model in level.random_mortar_models)
	{
		if(!model.in_use)
		{
			mortar_model = model;
			
			break;
		}
	}
	
	if(!IsDefined(mortar_model))
	{
		mortar_model = spawn("script_model", origin);
		mortar_model SetModel("projectile_rpg7");
		mortar_model.in_use = false;
		level.random_mortar_models[level.random_mortar_models.size] = mortar_model;
	}
	
	return mortar_model;
}

draw_move_path()
{
	self endon("movedone");
	
	while(1)
	{
		org1 = self.origin;
		waitframe();
		self thread drawLine(org1, self.origin, 10, (1,0,0));
	}	
}

draw_model_path()
{
	self endon("movedone");
	
	models = [];
	while(1)
	{
		wait .5;
		model = spawn("script_model", self.origin);
		model SetModel(self.model);
		model.angles = self.angles;
		models[models.size] = model;
	}
	
	wait 10;
	
	foreach(model in models)
	{
		model delete();
	}
}

jet_flyby()
{
	jet_flyby = []; //getstructarray("jet_flyby", "targetname");
	jet_flyby_radial = getstructarray("jet_flyby_radial", "targetname");
	
	planes = array_combine(jet_flyby, jet_flyby_radial);
	foreach(plane in planes)
	{
		plane.radial = plane.targetname == "jet_flyby_radial";
	}
	
	
	while(1)
	{
		wait RandomFloatRange(10,20);
				
		planes = array_randomize(planes);
		for(i=0;i<planes.size;i++)
		{
			plane = planes[i];
			
			start = undefined;
			end = undefined;
			if(plane.radial)
			{
				start = SpawnStruct();
				end = SpawnStruct();
				
				if(!IsDefined(plane.radius))
					plane.radius = 8000;
				
				fly_angles = (0,RandomFloatRange(0,360),0);
				fly_dir = AnglesToForward(fly_angles);
				
				start.origin = plane.origin - (plane.radius*fly_dir);
				start.angles = (fly_angles[0]+3, fly_angles[1], (0));
				
				end.origin = plane.origin + (plane.radius*fly_dir);
				end.angles = (fly_angles[0]+5, fly_angles[1], (0));
				
				if(IsDefined(plane.height))
				{
					start.origin = start.origin + (0,0,RandomFloatRange(0,plane.height));
					end.origin = end.origin + (0,0,RandomFloatRange(0,plane.height));
				}
			}
			else
			{
				targets = getstructarray(plane.target, "targetname");
				
				target = random(targets);
				if(!IsDefined(target))
					continue;
				
				start = plane;
				end = target;
			}
			
			speed = RandomFloatRange(1500,1600);
			dist = Distance(start.origin, end.origin);
			time = dist/speed;
			
			model = spawn("script_model", start.origin);
			model.angles = end.angles;
			//model SetModel("vehicle_nh90");
			model SetModel("vehicle_pavelow");
			waitframe();//Need to wait a frame to play fx on newly spawned models
			//playfxontag( level._effect[ "afterburner" ], model, "tag_engine_right" );
			//playfxontag( level._effect[ "afterburner" ], model, "tag_engine_left" );
			model PlayloopSound( "cobra_helicopter_dying_loop" );
			
			model MoveTo(end.origin, time);
			model RotateTo(end.angles, time);
			model waittill("movedone");
			model Delete();
			
			wait RandomFloatRange(10,20);
		}
	}
}


air_raid()
{
	level endon("stop_dynamic_events");
	level.air_raids = getstructarray("air_raid", "targetname");
	
	while(1)
	{
		level.air_raid_active = false;
		wait RandomFloatRange(60*2.5, 60*3.5);
		level.air_raid_active = true;
		thread air_raid_siren(15);
		wait 10; //Delay between siren start and mortar fire
		air_raid_fire(.5,.6, 40);
	}
}

air_raid_siren(siren_time)
{
	if(!IsDefined(level.air_raid_siren_ent))
	{
		level.air_raid_siren_ent = getEnt("air_raid_siren", "targetname");
	}
	
	if(IsDefined(level.air_raid_siren_ent))
	{
		level.air_raid_siren_ent PlaySound("air_raid_siren");
	}
	wait siren_time;
	
	if(IsDefined(level.air_raid_siren_ent))
	{
		level.air_raid_siren_ent StopSounds();
	}
}

air_raid_fire(delay_min, delay_max, max_mortars)
{
	foreach(raid in level.air_raids)
	{
		raid.last_target = raid;
	}
	
	level.air_raids = array_randomize(level.air_raids);
	
	mortar_count = 0;
	mortar_fired = true;
	while(mortar_fired)
	{
		mortar_fired = false;
		foreach(raid in level.air_raids)
		{
			if(!IsDefined(raid.last_target) || !IsDefined(raid.last_target.target))
				continue;
			
			next_target = random(getstructarray(raid.last_target.target, "targetname"));
			if(!isDefined(next_target))
				continue;
			
			if(!IsDefined(raid.radius))
				raid.radius = 300;
			if(!IsDefined(next_target.radius))
				next_target.radius = 100;
			
			start = random_point_in_circle(raid.origin, raid.radius);
			end = random_point_in_circle(next_target.origin, next_target.radius);
			
			thread random_mortars_fire(raid.origin, next_target.origin);
			mortar_count++;
			if(mortar_count>=max_mortars)
				return;
			raid.last_target = next_target;
			
			wait RandomFloatRange(delay_min, delay_max);
			
			mortar_fired = true;
		}
	}
}

random_point_in_circle(origin, radius)
{
	if(radius>0)
	{
		rand_dir = AnglesToForward((0,RandomFloatRange(0,360),0));
		rand_radius = RandomFloatRange(0, radius);
		origin = origin + (rand_dir*rand_radius);
	}
	
	return origin;
}

heli_anims()
{
	level endon("stop_dynamic_events");
	
	heli_anims = getstructarray("heli_anim", "targetname");
	if(heli_anims.size==0)
		return;
	
	heli_index = heli_anims.size;
	
	foreach(heli in heli_anims)
	{
		if(!IsDefined(heli.angles))
			heli.angles = (0,0,0);
	}
	
	while(1)
	{
		heli_index++;
		if(heli_index>=heli_anims.size)
		{
			heli_anims = array_randomize(heli_anims);
			heli_index = 0;
		}
		
		wait RandomFloatRange(10,20);
		
		
		if(level.air_raid_active)
			continue;
		
		heli = heli_anims[heli_index];
		if(!IsDefined(heli.script_animation) || !IsDefined(level.heli_anims[heli.script_animation]) || !IsDefined(level.heli_anims_length[heli.script_animation]))
			continue;
		
		
		model = spawn("script_model", heli.origin);
		model.angles = heli.angles;
		//model SetModel("vehicle_nh90");
		model SetModel("vehicle_pavelow");
		model PlayLoopSound("heli_flyover");
		
		model ScriptModelPlayAnimDeltaMotion(level.heli_anims[heli.script_animation]);
		
		wait level.heli_anims_length[heli.script_animation];
		
		model Delete();
		
	}
}

chain_gate()
{
	left_gate  = GetEnt( "left_gate", "targetname" );
	right_gate = GetEnt( "right_gate", "targetname" );
	lock	   = GetEnt( "lock", "targetname" );
	gate_clip  = GetEnt( "gate_clip", "targetname" );
	gate_trigger = GetEnt( "gate_trigger", "targetname" );
	
	gate_anim_node = Spawn( "script_model", left_gate.origin );
	gate_anim_node SetModel( "generic_prop_raven" );
	gate_anim_node.angles = left_gate.angles;
	waitframe();
	gate_clip ConnectPaths();
	waitframe();
	left_gate LinkTo( gate_anim_node, "j_prop_1" );
	right_gate LinkTo( gate_anim_node, "j_prop_2" );
	waitframe();
	add_to_bot_damage_targets( gate_trigger );
	lock ScriptModelPlayAnim( "mp_frag_metal_door_chain" );	
	gate_trigger waittill( "damage", amount, attacker, direction_vec, point, type );

	open_in = ( direction_vec[0] > 0 );

	lock Delete();
	remove_from_bot_damage_targets( gate_trigger );
	gate_trigger Delete();
	
	left_gate playsound( "warhawk_gate_iron_open" );

	if( open_in )
	{
//		IPrintLnBold( "ScriptModelPlayAnimDeltaMotion  - mp_warhawk_metal_door_open_in" );
		gate_anim_node ScriptModelPlayAnimDeltaMotion( "mp_warhawk_metal_door_open_in" );
	}
	else
	{
//		IPrintLnBold( "ScriptModelPlayAnimDeltaMotion  - mp_warhawk_metal_door_open_out" );
		gate_anim_node ScriptModelPlayAnimDeltaMotion( "mp_warhawk_metal_door_open_out" );
	}	
	
	wait( 0.5 );

//	gate_clip ConnectPaths();
	waitframe();
	gate_clip Delete();
}

