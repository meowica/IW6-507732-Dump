#include common_scripts\utility;
#include maps\mp\_utility;


main()
{
	maps\mp\mp_strikezone_precache::main();
	maps\createart\mp_strikezone_art::main();
	maps\mp\mp_strikezone_fx::main();
	
	maps\mp\_teleport::main();
	maps\mp\_teleport::teleport_set_minimap_for_zone("start", "compass_map_mp_strikezone");
	maps\mp\_teleport::teleport_set_minimap_for_zone("destroyed", "compass_map_mp_strikezone_after");
	maps\mp\_teleport::teleport_origin_use_offset(false);
	
	maps\mp\_teleport::teleport_set_pre_func( ::pre_teleport, "destroyed");
	maps\mp\_teleport::teleport_set_post_func( ::post_teleport, "destroyed");
	
	maps\mp\_load::main();
	thread maps\mp\_fx::func_glass_handler(); // Text on glass
	
//	AmbientPlay( "ambient_mp_setup_template" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit"	] = "desert";
	
	level.pre_org = getstruct("world_origin_pre", "targetname");
	level.post_org = getstruct("world_origin_post", "targetname");
	level.mid_z = 0;
	if(IsDefined(level.post_org) && IsDefined(level.pre_org))
	{
		level.mid_z = (level.pre_org.origin[2] + level.post_org.origin[2])/2;
	}

	flag_init( "teleport_to_destroyed" );
	flag_init( "start_fog_fade_in" );
	flag_init( "start_fog_fade_out" );
	
	level thread nuke_transition();
	//level thread generic_swing_ents();
	level thread fall_objects();
	
	level thread connect_watch();
/#
	level thread vision_set_stage_test();
#/
}

/#
vision_set_stage_test()
{
	SetDevDvar("vision_set_stage_fade_time", "1");
	dvar_name = "vision_set_stage";
	default_value = -1;
	SetDevDvarIfUninitialized(dvar_name, default_value);
	while(1)
	{
		value = GetDvarInt(dvar_name, default_value);
		if(value<0)
		{
			waitframe();
		}
		else
		{
			set_vision_set_stage(value, GetDvarInt("vision_set_stage_fade_time"));
			SetDvar(dvar_name, default_value);
		}
	}
}	
#/

connect_watch()
{
	while(1)
	{
		level waittill("connected", player);
		if(IsDefined(level.vision_set_stage))
			player VisionSetStage(level.vision_set_stage, .1);
	}
}

wait_on_score_or_time( score_threshold, ignore_score, time_threshold, ignore_time )
{
	// TODO: needs to take into account that "prematch_done" isn't actually the start of the game.  That's why the horrible if-test around the get_higher_score calls are there.
	
	higher_score = 0;
	
	if( isDefined( game[ "teamScores" ] ) )
	{
		higher_score = get_higher_score();
	}
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
			if( isDefined( game[ "teamScores" ] ) )
			{
				higher_score = get_higher_score();
			}
		}
	}
	else
	{
		while( ( timePassed < time_threshold ) && ( higher_score < score_threshold ) )
		{
			wait( 0.5 );
			if( isDefined( game[ "teamScores" ] ) )
			{
				higher_score = get_higher_score();
			}
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


nuke_transition()
{

	minimum_full_match_time				= 100;//the shortest timelimit in seconds we'll allow for the whole match to play out (pre and post crash). Any shorter and the whole match will take place on the plane
	minimum_half_match_time				= 20; //the shortest timelimit in seconds where we'll stage events based on percentages
	infinite_match_time_assumption		= 600; // if scorelimit and timelimit are zero (infinite match!), use this to time the level's events	

	start_trans_score = .5;
	start_trans_time = .5;
	
	score_limit = getScoreLimit();
	time_limit	= getTimeLimit() * 60; // seconds

	ignore_score = false;
	ignore_time = false;
	
	if( ( score_limit <= 0 ) && ( time_limit <= 0 ) )
	{
		ignore_score = true;
		time_limit = infinite_match_time_assumption;
	}
	else if ( score_limit <= 0 )
	{
		ignore_score = true;
	}
	else if( time_limit <= 0 )
	{
		ignore_time = true;
	}
	
	waitframe(); // give load::main time to init
	gameFlagWait( "prematch_done" );

	score_to_trans = start_trans_score * score_limit;
	time_to_trans  = start_trans_time * time_limit;	
	nuke_wait(score_to_trans, ignore_score, time_to_trans, ignore_time);
		

	maps\mp\_teleport::teleport_to_zone("destroyed");
	
}

pre_teleport()
{
	// this *should* be already handled in _nuke, but just in case that functionality doesn't get brought over to IW6, here it is...	
	if( !IsDefined( level.nuke_soundObject ) )
	{
		level.nuke_soundObject = Spawn( "script_origin", (0,0,1) );
		level.nuke_soundObject hide();
	}
	
	nuke_delay = 4;
	fog_fade_in_time = 1;
	fx_hit_player_time = 1.5; //Time it takes the dust cloud to reach the player
	pre_teleport_delay = 1; //Make sure fog is at 100%
	
	level thread delaythread( ( nuke_delay - 3.3 ), maps\mp\killstreaks\_nuke::nukeSoundIncoming );
	level thread delaythread( nuke_delay, maps\mp\killstreaks\_nuke::nukeSoundExplosion );
	level thread delaythread( nuke_delay, ::nuke_slow_motion, 0.5, 1.0, 1.0 );
	level thread delaythread( nuke_delay, ::nuke_effects );
	
	wait nuke_delay;
	
	set_vision_set_stage(1, 1); //prague_escape_nuke_flash
	level thread rumble_all_players( "hijack_plane_medium", true );
	level thread nuke_earthquake(fx_hit_player_time);
	level thread nuke_ground_tilt(fx_hit_player_time);
	
	wait fx_hit_player_time - fog_fade_in_time;
	
	//Temp sound - long sound that sounds like stuff falling down
	playSoundAtPos((0,0,35000), "ac130_going_down");
	
	flag_set( "start_fog_fade_in" );
	//thread players_fade_to_shader(fog_fade_in_time, "white", (0.393723, 0.314233, 0.141142));//Match fog color
	set_vision_set_stage(4, fog_fade_in_time); //mp_strikezone_fogout
	wait fog_fade_in_time;
	
	set_all_players_undying( true );
	wait pre_teleport_delay;
	
	flag_set( "teleport_to_destroyed" );
}

post_teleport()
{
	post_teleport_delay = .5; //Time before fog starts to fade out
	fog_fade_out_time = 25;
	
	wait post_teleport_delay;
	stop_rumble_all_players();	
	set_all_players_undying(false);

	flag_set( "start_fog_fade_out" );
	set_vision_set_stage(1, fog_fade_out_time); //mp_strikezone_after
	
	thread post_nuke_fx_exploders(1);
}

nuke_wait(score_to_trans, ignore_score, time_to_trans, ignore_time)
{
	level endon("nuke_start");
	/#
		level thread nuke_wait_dvar();
	#/
	
	wait_on_score_or_time( score_to_trans, ignore_score, time_to_trans, ignore_time );
	
	level notify("nuke_start");
}

/#
nuke_wait_dvar()
{
	level endon("nuke_start");
	
	dvar_name = "trigger_nuke";
	default_value = 0;
	SetDevDvarIfUninitialized(dvar_name, default_value);
	while(1)
	{
		
		value = GetDvarInt(dvar_name, default_value);
		if(value==default_value)
		{
			waitframe();
		}
		else
		{
			SetDvar(dvar_name, default_value);
			level notify("nuke_start");
		}
	}
}
#/

post_nuke_fx_exploders(delay_time)
{
	if(isDefined(delay_time) && delay_time>0)
		wait delay_time;
	
	exploder(2);
	
	time = 2;
	add_time = .5;
	num_plays = 5;
	for(i=0;i<num_plays;i++)
	{
		exploder(1);
		wait time;
		time += add_time;
	}
}

set_vision_set_stage(stage, time)
{
	if(!isDefined(time))
		time = 1.0;
	
	foreach(player in level.players)
	{
		player VisionSetStage(stage, time);
	}
	
	level.vision_set_stage = stage;
}

set_all_players_undying(enable)
{
	if(!IsDefined(level.players_undying))
		level.players_undying = false;
	
	if(enable == level.players_undying)
		return;
	
	if(enable)
	{
		level.prev_modifyPlayerDamage = level.modifyPlayerDamage;
		level.modifyPlayerDamage = ::undying;
	}
	else
	{
		level.modifyPlayerDamage = level.prev_modifyPlayerDamage;
	}
	
	level.players_undying = enable;
}

undying(victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	if(IsDefined(victim))
	{
		return victim.health-1;
	}
	
	return 0;
}

nuke_slow_motion( transition_to_slow, players_are_slow, transition_to_normal )
{
	SetSlowMotion( 1.0, 0.25, transition_to_slow );
	wait( players_are_slow );
	SetSlowMotion( 0.25, 1, transition_to_normal );	
}

/*
///////////////////////////////////////////////////////////////////////////////////////////////////
//
//		grabbed from airlift.gsc SP 
//
///////////////////////////////////////////////////////////////////////////////////////////////////

nuke_earthquake()
{
	wait( 1 );
	//while ( !flag( "shockwave_hit_player" ) )
	{
		earthquake( .08, .05, level.player.origin, 80000 );
		wait( .05 );
	}
	earthquake( .5, 1, level.player.origin, 80000 );
	while ( true )
	{
		earthquake( .25, .05, level.player.origin, 80000 );
		wait( .05 );
	}
}


nuke_sunlight()
{
	level.defaultSun = getMapSunLight();
	level.nukeSun = ( 3.11, 2.05, 1.67 );
	sun_light_fade( level.defaultSun, level.nukeSun, 2 );
	wait( 1 );
	thread sun_light_fade( level.nukeSun, level.defaultSun, 2 );
}

nuke_shockwave_blur()
{
	earthquake( 0.3, .5, level.player.origin, 80000 );
	SetBlur( 3, .1 );
	wait 1;
	SetBlur( 0, .5 );
}
*/

create_overlay( shader_name, start_alpha )
{
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( shader_name, 640, 480 );
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 1;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = start_alpha;
	overlay.foreground = true;
	
	return overlay;
}

fade_over_time( target_alpha, fade_time )
{
	assertex( isdefined( target_alpha ), "fade_over_time must be passed a target_alpha." );
	
	if ( isdefined( fade_time ) && fade_time > 0 )
	{
		self fadeOverTime( fade_time );
	}
	
	self.alpha = target_alpha;
	
	if ( isdefined( fade_time ) && fade_time > 0 )
	{
		wait fade_time;
	}
}

players_fade_to_shader( fade_out_time, shader, color )
{
	overlay = create_overlay( shader, 0 );
	if(IsDefined(color))
		overlay.color = color;
	
	overlay fade_over_time( 1, fade_out_time );
	
	foreach(player in level.players)
	{
		player DisableWeapons();
	}
	
	wait( fade_out_time );
	
	foreach(player in level.players)
	{
		player EnableWeapons();
	}
	
	overlay fade_over_time( 0, 1 );
	overlay Destroy();
}

nuke_earthquake(fx_hit_time)
{
	quakes = getstructarray("nuke_earthquake", "targetname");
	foreach(quake in quakes)
	{
		Earthquake(.3, fx_hit_time, quake.origin, quake.radius);
	}
	
	wait fx_hit_time;
	
	foreach(quake in quakes)
	{
		Earthquake(.5, 4, quake.origin, quake.radius);
	}
	
}

nuke_ground_tilt(fx_hit_time)
{
	fx_time_offset = .2;
	if(fx_hit_time-fx_time_offset>0)
		wait fx_hit_time-fx_time_offset;
	
	start = SpawnStruct();
	end = SpawnStruct();
	
	kick_time = .2;
	kick_angle = 20;
	foreach(player in level.players)
	{
		if(IsDefined(player.direction_to_nuke))
		{
			nuke_dir_fwd = VectorNormalize(player.direction_to_nuke);
			nuke_dir_right = VectorCross(nuke_dir_fwd, (0,0,1));
			
			
			pitch = -1 * kick_angle * VectorDot(nuke_dir_fwd, (1,0,0));
			roll = kick_angle * VectorDot(nuke_dir_right, (1,0,0));
			
			ground_ent = Spawn("script_model", player.origin);
			ground_ent.angles = (0,0,0);
			ground_ent thread delete_ground_ref_ent();
			
			
			player.ground_ref_ent = ground_ent;
			player PlayerSetGroundReferenceEnt(ground_ent);
			ground_ent Rotateto((pitch, 0, roll), kick_time, 0, kick_time);
		}
	}
	
	wait kick_time;
	
	flag_wait( "start_fog_fade_out" );	
	
	unkick_time = 1;
	foreach(player in level.players)
	{
		if(IsDefined(player.ground_ref_ent))
		{
			player.ground_ref_ent Rotateto((0, 0, 0), unkick_time, 0, unkick_time);
		}
	}
	
	wait unkick_time;
	
	foreach(player in level.players)
	{
		player PlayerSetGroundReferenceEnt(undefined);
	}
	
	
	level notify("delete_ground_ref_ents");
}

delete_ground_ref_ent()
{
	self endon("death");
	level waittill("delete_ground_ref_ents");
	self Delete();
}


rumble_all_players( rumble, loop )
{
	if ( !IsDefined( loop ) )
		loop = false;
	
	foreach ( player in level.players )
	{
		if ( loop )
		{
			player PlayRumbleLoopOnEntity( rumble );
		}
		else
		{
			player PlayRumbleOnEntity( rumble );
		}
	}
	
	if ( !loop )
		return;
	
	level waittill( "stop_rumble_loop" );
	
	foreach ( player in level.players )
	{
		player StopRumble( rumble );
	}
}

stop_rumble_all_players()
{
	level notify("stop_rumble_loop");
}

nuke_effects()
{
	foreach( player in level.players )
	{
		playerForward = anglestoforward( player.angles );
		playerForward = ( playerForward[0], playerForward[1], 0 );
		playerForward = VectorNormalize( playerForward );
	
		nukeDistance = 5000;
		/# nukeDistance = getDvarInt( "scr_nukeDistance" );	#/

		nukeEnt = Spawn( "script_model", player.origin + ( playerForward * nukeDistance ) );
		nukeEnt setModel( "tag_origin" );
		nukeEnt.angles = ( 0, (player.angles[1] + 180), 90 );
		
		player.direction_to_nuke = playerForward;

		/#
		if ( getDvarInt( "scr_nukeDebugPosition" ) )
		{
			lineTop = ( nukeEnt.origin[0], nukeEnt.origin[1], (nukeEnt.origin[2] + 500) );
			thread draw_line_for_time( nukeEnt.origin, lineTop, 1, 0, 0, 10 );
		}
		#/

		nukeEnt thread nuke_effect( player );
	}
	
	delay_to_post_disaster_fx = 1.4;
	wait( delay_to_post_disaster_fx );
	
	foreach( player in level.players )
	{
		delta = maps\mp\_teleport::get_teleport_delta( "destroyed" );
		
		playerForward = anglestoforward( player.angles );
		playerForward = ( playerForward[0], playerForward[1], 0 );
		playerForward = VectorNormalize( playerForward );
	
		nukeDistance = 5000;
		/# nukeDistance = getDvarInt( "scr_nukeDistance" );	#/

		nukeEnt = Spawn( "script_model", player.origin + ( playerForward * nukeDistance ) + delta );
		nukeEnt setModel( "tag_origin" );
		nukeEnt.angles = ( 0, (player.angles[1] + 180), 90 );

		/#
		if ( getDvarInt( "scr_nukeDebugPosition" ) )
		{
			lineTop = ( nukeEnt.origin[0], nukeEnt.origin[1], (nukeEnt.origin[2] + 500) );
			thread draw_line_for_time( nukeEnt.origin, lineTop, 1, 0, 0, 10 );
		}
		#/

		nukeEnt thread nuke_effect( player );
	}	
	
}


nuke_effect( player )
{
	player endon( "disconnect" );

	waitframe();
	PlayFXOnTagForClients( level._effect[ "rod_of_god_shockwave" ], self, "tag_origin", player );
}

generic_swing_ents()
{
	swing_anims = [];
	swing_anims["small"] = "mp_strikezone_chunk_sway_small";
	swing_anims["large"] = "mp_strikezone_chunk_sway_large";
	
	foreach(key,value in swing_anims)
	{
		PrecacheMpAnim(value);
	}
	
	swing_origins = GetEntArray("generic_swing", "targetname");
	
	foreach(swing in swing_origins)
	{		
		if(!IsDefined(swing.angles))
			swing.angles = (0,0,0);
		
		pivot = Spawn("script_model", swing.origin);
		pivot.angles = swing.angles;
		pivot SetModel("generic_prop_raven");
		
		swing linkto(pivot, "j_prop_1");
		
		
		anim_name = "small";
		if(IsDefined(swing.script_noteworthy) && IsDefined(swing_anims[swing.script_noteworthy]))
		{
			anim_name = swing.script_noteworthy;
		}
		
		pivot ScriptModelPlayAnim(swing_anims[swing.script_noteworthy]);
	}
	
}

fall_objects()
{
	objects = GetEntArray("fall_object", "targetname");
	array_thread(objects, ::fall_object_init);
}

fall_object_init()
{
	self.end = self;
	
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
		structs = getstructarray(self.script_linkto, "script_linkname");
		set_default_script_noteworthy(structs, "start");
		things = array_combine(things, structs);
		
		ents = GetEntArray(self.script_linkto, "script_linkname");
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
			default:
				break;
		}
	}
	
	set_default_angles(things);
	
	if(IsDefined(self.start) && IsDefined(self.end))
		self thread fall_object_run();
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

fall_object_run()
{
	fall_to_origin = self.origin;
	fall_to_angles = self.angles;
	
	
	trans = TransformMove(self.start.origin, self.start.angles, self.end.origin, self.end.angles, self.origin, self.angles);
	self.origin = trans["origin"];
	self.angles = trans["angles"];
	
	
	flag_wait( "start_fog_fade_out" );
	
	wait RandomFloatRange(0.8,1.0);
	
	if(IsDefined(self.script_delay))
	{
		if(self.script_delay<0)
			self.script_delay = RandomFloatRange(30, 120);
		
		wait self.script_delay;
	}
	
	PlaySoundAtPos(self.origin, "cobra_helicopter_crash");
	
	fall_speed = RandomFloatRange(300,320);
	dist = Distance(fall_to_origin, self.origin);
	time = dist/fall_speed;
	
	self moveTo(fall_to_origin, time, time, 0);
	if(fall_to_angles != self.angles)
		self RotateTo(fall_to_angles, time, 0, 0);
	
	wait time;
	
	
}