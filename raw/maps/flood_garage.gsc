#include maps\_utility;
#include common_scripts\utility;
#include maps\flood_util;

section_main()
{
}

section_precache()
{
}

section_flag_inits()
{
	flag_init( "garage_ally_0_door_ready" );
	flag_init( "garage_ally_1_door_ready" );
	flag_init( "garage_ally_2_door_ready" );
	flag_init( "garage_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

garage_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "garage_start" );
		//set_audio_zone( "flood_garage", 2 );
	// spawn the allies
	maps\flood_util::spawn_allies();

//	node = GetNode( "garage_ally0_cover_start", "targetname" );
//	level.allies[ 0 ] SetGoalNode( node );
//	node = GetNode( "garage_ally1_cover_start", "targetname" );
//	level.allies[ 1 ] SetGoalNode( node );
//	node = GetNode( "garage_ally2_cover_start", "targetname" );
//	level.allies[ 2 ] SetGoalNode( node );
	
	// hide swept away moment water
	thread maps\flood_swept::swept_water_toggle( "swim", "hide" );
	//thread maps\flood_swept::swept_water_toggle( "noswim", "hide" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "show" );

	thread float_cars();

	level.allies[ 0 ] thread ally_garage_sneak( "r", "garage_ally0_cover_crouch", "r_end_node" );
	level.allies[ 1 ] delayThread( 2, ::ally_garage_sneak, "y", "garage_ally1_cover_crouch", "y_end_node" );
	level.allies[ 2 ] thread ally_garage_sneak( "g", "garage_ally2_cover_crouch", "g_end_node" );
}

garage()
{
	level thread autosave_now();
	
	//disables all badplaces for destructibles so AI won't wig out while player is lighting shit up
	level.disable_destructible_bad_places = true;

	// start checking if the player is in water
	thread maps\flood_coverwater::register_coverwater_area( "coverwater_garage", "garage" );
	level.cw_player_in_rising_water = false;
	level.cw_player_allowed_underwater_time = 15;

	guys = GetEntArray( "garage_wave1_ai", "targetname" );
	array_thread( guys, ::add_spawn_function, ::enemy_garage );
	array_spawn( guys );

	guys = GetEntArray( "garage_wave1above_ai", "targetname" );
	array_thread( guys, ::add_spawn_function, ::enemy_garage );
	array_spawn( guys );
	
	thread garage_teleport_allies_off_debrisbridge();
	thread garage_wave2_trig();
	thread garage_wave3_trig();
	thread garage_wave4_trig();
	thread garage_ally_move476_jumpers();
	thread garage_ally_move476();
	thread garage_ally_move477();
	thread garage_ally_move478();	
	thread garage_ally_move479();	
	thread garage_ally_move480();	
	thread track_ai();
	//thread door_open();

	level thread maps\flood_ending::ending_transition();

	flag_wait( "garage_done" );
	JKUprint( "garage done" );
}

block_for_trigger_release( trigger )
{
	trigger endon( "death" );
	
	while( level.player IsTouching( trigger ) )
		waitframe();
}

ally_garage( color )
{
//	self maps\flood_coverwater::ai_setup_for_coverwater( "" );
	self set_force_color( color );
	self enable_cqbwalk();
}

ally_garage_sneak( color, sneak_node, end_node )
{
	self endon( "death" );

	JKUprint( self.animname + " in garage scripts!" );
//	self maps\flood_coverwater::ai_setup_for_coverwater( "", false );
	
	if( IsDefined( sneak_node ) )
		self block_ally_sneak_to_node( sneak_node );
	
	self set_force_color( color );
	self enable_cqbwalk();
	
	// FIX JKU this is a hack until we better figure out and implement this end sequence
	node = GetNode( end_node, "targetname" );
	while( Distance2D( self.origin, node.origin ) > 12 )
	{
		waitframe();
	}
	
	flag_set( "garage_" + self.animname + "_door_ready" );
//	JKUprint( self.animname + " done" );
}

block_ally_sneak_to_node( sneak_node )
{
	// get them to go into crouch to sneak up to their node
	og_moveplaybackrate = self.moveplaybackrate;
	og_movetransitionrate = self.movetransitionrate;
	og_animplaybackrate = self.animplaybackrate;
	rnd_playbackrate = RandomFloatRange( 0.75, 0.85 );
	self.moveplaybackrate = rnd_playbackrate;
	self.movetransitionrate = ( rnd_playbackrate * 0.7 );
	self.animplaybackrate = rnd_playbackrate;

	self AllowedStances( "crouch" );
	self.ignoreme = true;
	self.ignoreall = true;
	self.ignoresuppression = true;
	self disable_ai_color();
	
	og_goalradius = self.goalradius;
	self.goalradius = 1;

	sneak_node = GetNode( sneak_node, "targetname" );
	self SetGoalNode( sneak_node );
	waitframe();
	self waittill_any( "goal", "goal_changed" );
	
//	// wait till I have a node.  not exactly sure why I don't always have one but sometimes I dont.
//	while( !IsDefined( self.node ) )
//		waitframe();
//	
//	// don't let them sit in crouchwalk if the player is flashing forwards
//	dist_to_goal = Distance2D( self.origin, self.node.origin );
//	while( dist_to_goal < 555 )
//	{
//		dist_to_goal = Distance2D( self.origin, self.node.origin );
////		JKUprint( self.animname + ": " + dist_to_goal );
//		
//		if( dist_to_goal < 4 )
//			break;
//		
//		waitframe();
//	}
	
	self.ignoreall = false;
	
	self AllowedStances( "stand" );
	self.goalradius = og_goalradius;
	
	self.moveplaybackrate = og_moveplaybackrate;
	self.movetransitionrate = og_movetransitionrate;
	self.animplaybackrate = og_animplaybackrate;

	// give them some time to fire on the enemies
	wait RandomIntRange( 10, 15 );
	
	self.ignoreme = false;
	self.ignoresuppression = false;
	self enable_ai_color();
}

enemy_garage()
{
//	self maps\flood_coverwater::ai_setup_for_coverwater( "" );
	self.script_forcespawn = true;
	self enable_cqbwalk();
}

// jumper guys start un killable so you can see them jump
enemy_garage_jumper( clip_hack )
{
	self endon( "death" );
	
	self thread	enemy_garage();
	self.allowdeath = false;
	self.ignoreall = 1;
	self.ignoreme = 1;

	if( IsDefined( clip_hack ) )
	{
		ent = GetEnt( clip_hack, "targetname" );
		ent NotSolid();
		ent ConnectPaths();
	}

	self waittill( "goal" );
	
	if( IsDefined( clip_hack ) )
	{
		ent = GetEnt( clip_hack, "targetname" );
		ent Solid();
		ent DisconnectPaths();
	}

	self.allowdeath = true;
	self.ignoreall = 0;
	self.ignoreme = 0;
}

track_ai()
{
//	garage_wave1_ai, 5
//	garage_wave1above_ai, 2
	// wait for the first group to get small or for the player to hit the trigger
	while( ( get_ai_group_count( "garage_wave1_ai" ) + get_ai_group_count( "garage_wave1above_ai" ) ) > 5 )
	{
		wait 0.05;
	}
	
	activate_trigger( "garage_wave2_trig", "targetname" );
	JKUprint( "g: 2 via tracker" );
	
//	garage_wave2_ai, 5
//	garage_wave2_ai_jumper, 1
	while( ( get_ai_group_count( "garage_wave1_ai" ) + get_ai_group_count( "garage_wave1above_ai" ) + get_ai_group_count( "garage_wave2_ai" ) + get_ai_group_count( "garage_wave2_ai_jumper" ) ) > 8 )
	{
		wait 0.05;
	}
	
	activate_trigger( "garage_wave3_trig", "targetname" );
	JKUprint( "g: 2above(3) via tracker" );
	
//	 garage_wave2above_ai 3
	while( get_ai_group_count( "garage_wave2above_ai" )  > 2 )
	{
		wait 0.05;
	}
	
	activate_trigger( "garage_wave4_trig", "targetname" );
	JKUprint( "g: 4 via tracker" );
}

garage_wave2_trig()
{
	trigger = GetEnt( "garage_wave2_trig", "targetname" );
	trigger waittill( "trigger" );
	
	JKUprint( "g: 2" );
	guys = GetEntArray( "garage_wave2_ai", "targetname" );
	array_thread( guys, ::add_spawn_function, ::enemy_garage );
	array_spawn( guys );

	guys = GetEntArray( "garage_wave2_ai_jumper", "targetname" );
	array_thread( guys, ::add_spawn_function, ::enemy_garage_jumper );
	array_spawn( guys );
}

garage_wave3_trig()
{
	trigger = GetEnt( "garage_wave3_trig", "targetname" );
	trigger waittill( "trigger" );
	
	JKUprint( "g: 3" );
	guys = GetEntArray( "garage_wave2above_ai", "targetname" );
	array_thread( guys, ::add_spawn_function, ::enemy_garage );

	foreach( guy in guys )
	{
		guy spawn_ai();
		wait 0.5;
	}
//	array_spawn( guys );
}

garage_wave4_trig()
{
	trigger = GetEnt( "garage_wave4_trig", "targetname" );
	trigger waittill( "trigger" );
	
	JKUprint( "g: 4" );
	guys = GetEntArray( "garage_wave4_ai", "targetname" );
	array_thread( guys, ::add_spawn_function, ::enemy_garage );
	
	foreach( guy in guys )
	{
		guy spawn_ai();
		wait 0.5;
	}
//	array_spawn( guys );
}

pause_ally_suppression( pause )
{
//	if( level.allies [ 0 ].node != ally1_node )
	level.allies[ 0 ].ignoresuppression = true;
	level.allies[ 1 ].ignoresuppression = true;
	level.allies[ 2 ].ignoresuppression = true;
		
	wait pause;

	JKUprint( level.allies[ 0 ].node.targetname );
	level.allies[ 0 ].ignoresuppression = false;
	level.allies[ 1 ].ignoresuppression = false;
	level.allies[ 2 ].ignoresuppression = false;
}

garage_ally_move476_jumpers()
{
	trigger = GetEnt( "garage_ally_move476", "targetname" );
	trigger waittill( "trigger" );

	jumpers = GetEntArray( "garage_wave1_ai_jumper1", "targetname" );
	array_thread( jumpers, ::add_spawn_function, ::enemy_garage_jumper, "garage_jumper_clip_hack1" );
	array_spawn( jumpers );

	jumpers = GetEntArray( "garage_wave1_ai_jumper2", "targetname" );
	array_thread( jumpers, ::add_spawn_function, ::enemy_garage_jumper, "garage_jumper_clip_hack2" );
	array_spawn( jumpers );
}

garage_ally_move476()
{
	trigger = GetEnt( "garage_ally_move476", "targetname" );
	trigger endon( "death" );
	
	while( 1 )
	{
		trigger waittill( "trigger" );
		
//		thread pause_ally_suppression( 5 );

		guys1 = get_ai_group_ai( "garage_wave1_ai" );
		guys2 = get_ai_group_ai( "garage_wave2_ai" );
		guys3 = get_ai_group_ai( "garage_wave2_ai_jumper" );
		guys = array_merge( guys1, guys2 );
		guys = array_merge( guys, guys3 );
		
		// don't send a guy to the same goal volume just in case this would cause him to move unneccesarrily
		foreach( guy in guys )
		{
			if( guy GetGoalVolume().targetname != "garage_wave1_below" )
			{
				thread maps\flood_util::reassign_goal_volume( guy, "garage_wave1_below" );
			}
		}
		
		block_for_trigger_release( trigger );
	}
}

// retreat the wave1 guys if you push forwards
garage_ally_move477()
{
	trigger = GetEnt( "garage_ally_move477", "targetname" );
	trigger endon( "death" );
	
	while( 1 )
	{
		trigger waittill( "trigger" );
		
//		thread pause_ally_suppression( 2 );
		
		guys1 = get_ai_group_ai( "garage_wave1_ai" );
		guys2 = get_ai_group_ai( "garage_wave1above_ai" );
		guys3 = get_ai_group_ai( "garage_wave2_ai" );
		guys4 = get_ai_group_ai( "garage_wave2_ai_jumper" );
		guys = array_merge( guys1, guys2 );
		guys = array_merge( guys, guys3 );
		guys = array_merge( guys, guys4 );

		foreach( guy in guys )
		{
			if( guy GetGoalVolume().targetname != "garage_wave1_below_retreat" )
			{
//				thread maps\flood_util::reassign_goal_volume( guy, "garage_wave1_below_retreat" );
			}
		}		
		
		block_for_trigger_release( trigger );
	}
}

garage_ally_move478()
{
	trigger = GetEnt( "garage_ally_move478", "targetname" );
	trigger endon( "death" );
	
	while( 1 )
	{
		trigger waittill( "trigger" );
		
		// ground floor guys retreat
		guys1 = get_ai_group_ai( "garage_wave1_ai" );
		guys2 = get_ai_group_ai( "garage_wave1above_ai" );
		guys3 = get_ai_group_ai( "garage_wave2_ai" );
		guys4 = get_ai_group_ai( "garage_wave2_ai_jumper" );
		guys = array_merge( guys1, guys2 );
		guys = array_merge( guys, guys3 );
		guys = array_merge( guys, guys4 );

		foreach( guy in guys )
		{
			if( guy GetGoalVolume().targetname != "garage_wave2_below_retreat" )
			{
				thread maps\flood_util::reassign_goal_volume( guy, "garage_wave2_below_retreat" );
			}
		}
		
		block_for_trigger_release( trigger );
	}
}

garage_ally_move479()
{
	trigger = GetEnt( "garage_ally_move479", "targetname" );
	trigger endon( "death" );
	
	while( 1 )
	{
		trigger waittill( "trigger" );
		
		// ground floor guys retreat
		guys1 = get_ai_group_ai( "garage_wave1_ai" );
		guys2 = get_ai_group_ai( "garage_wave1above_ai" );
		guys3 = get_ai_group_ai( "garage_wave2_ai" );
		guys4 = get_ai_group_ai( "garage_wave2_ai_jumper" );
		guys = array_merge( guys1, guys2 );
		guys = array_merge( guys, guys3 );
		guys = array_merge( guys, guys4 );

		foreach( guy in guys )
		{
			if( guy GetGoalVolume().targetname != "garage_wave2_above" )
			{
				thread maps\flood_util::reassign_goal_volume( guy, "garage_wave2_above" );
			}
		}
		
		block_for_trigger_release( trigger );
	}
}

garage_ally_move480()
{
	flag_wait( "ending_gate_open" );
	while( 1 )
	{
		baddies = GetAIArray( "axis" );
		if( baddies.size < 3 )
			break;
		
		waitframe();
	}
	JKUprint( "move up" );
	ents = GetEntArray( "garage_ally_movement_volumes", "script_noteworthy" );
	array_delete( ents );
	
	activate_trigger( "garage_ally_move480", "targetname" );
}

float_cars()
{
	cars = GetEntArray( "floating_car", "script_linkname" );
	foreach( car in cars )
		car thread floater_logic( "car_bob" );
	
	ents = GetEntArray( "floating_container", "script_noteworthy" );
	foreach( ent in ents )
		ent thread floater_logic( "bob" );
}

//move_cars()
//{
//	cars = GetEntArray( "moving_car", "script_noteworthy" );
//	foreach( car in cars )
//	{
//		car gopath();
////		car thread floater_logic( "bob" );
//	}
//}

// Valid floating behaviors are "bob" and "spin"
floater_logic( behavior)
{
	self endon( "destroyed" );

	// stagger animation starts
	wait RandomFloatRange( 0, 1.5 );
	
	switch( behavior )
	  {
		case "spin":
			if ( isdefined (self.targetname) && self.targetname == "floating_ball")
				self thread check_for_ball_pop();
			while ( 1 )
			{
				self Moveto ((self.origin - (0,0,1)), 1, 0.2, 0.2);
				self RotateTo ((self.angles - (0,0,25)), 2);
				wait 1;
				self Moveto ((self.origin + (0,0,1)), 1, 0.2, 0.2);
				self RotateTo ((self.angles - (0,0,25)), 2);
				wait 1;
			}
		case "bob":
			while ( 1 )
			{
//				rnd_move = RandomIntRange( -2, 2 );
//				rnd_angles = RandomIntRange( -1, 1 );
				rnd_move = 2;
				rnd_angles = 1;
				time = 1.25;
				self Moveto( ( self.origin - ( 0, 0, rnd_move ) ), time, 0.2, 0.2 );
				self RotateTo( ( self.angles - ( rnd_angles, 0, rnd_angles ) ), time, 0.4, 0.4 );
				wait time;
				self Moveto( ( self.origin + ( 0, 0, rnd_move ) ), time, 0.2, 0.2 );
				self RotateTo( ( self.angles + ( rnd_angles, 0, rnd_angles ) ), time, 0.4, 0.4) ;
				wait time;
			}
		case "car_bob":
//			self thread car_sink_logic();
//			while ( self !ent_flag( "destroyed" ) )
			self thread destructible_disable_explosion();
			while ( 1 )
			{
				rnd_move = RandomFloatRange( 1.5, 2.5 );
				rnd_angles = RandomFloatRange( 0.75, 1.75 );
				time = 4;
				for( i = 0; i < 2; i++ )
				{
					self Moveto( ( self.origin - ( 0, 0, rnd_move ) ), time, time * 0.4, time * 0.4 );
					self RotateTo( ( self.angles - ( rnd_angles, 0, rnd_angles ) ), time, time * 0.4, time * 0.4 );
					wait time;
					self Moveto( ( self.origin + ( 0, 0, rnd_move ) ), time, time * 0.4, time * 0.4 );
					self RotateTo( ( self.angles + ( rnd_angles, 0, rnd_angles ) ), time, time * 0.4, time * 0.4) ;
					wait time;
				}
			}
	}
}

car_sink_logic()
{
	self ent_flag_init( "destroyed" );
	
	if( isDefined( self.script_noteworthy ) )
	{
		dest_node_blocker = GetEnt( ( self.script_noteworthy + "_destroyed" ), "targetname" );
		notdest_node_blocker = GetEnt( ( self.script_noteworthy + "_notdestroyed" ), "targetname" );
		// hide_notsolid was f'n slow for some reason when you ran into the area where the brushmodel was
//		dest_node_blocker hide_notsolid();
//		notdest_node_blocker hide_notsolid();
		dest_node_blocker Hide();
		dest_node_blocker NotSolid();
		notdest_node_blocker Hide();
		notdest_node_blocker NotSolid();
		wait 0.05;
		notdest_node_blocker ConnectPaths();
	}
	
	// wait for the car to be able to be destroyed
	while ( self isDestructible() )
		wait 0.05;
	self ent_flag_set( "destroyed" );
	
	ground_org = drop_to_ground( self.origin, self.origin[ 2 ] );
	self MoveZ( ( ground_org[ 2 ] - self.origin[ 2 ] ), 1.5, 0.02, 0.1 );
	wait 1.5;
	
	if( isDefined( self.script_noteworthy ) )
	{
		dest_node_blocker = GetEnt( ( self.script_noteworthy + "_destroyed" ), "targetname" );
		notdest_node_blocker = GetEnt( ( self.script_noteworthy + "_notdestroyed" ), "targetname" );
		notdest_node_blocker Show();
		notdest_node_blocker Solid();
		notdest_node_blocker DisConnectPaths();
		notdest_node_blocker Hide();
		notdest_node_blocker NotSolid();
		dest_node_blocker ConnectPaths();
	}
}

check_for_ball_pop()
{
	// Floating balls can be destroyed when damaged
	self SetCanDamage( true );
	self waittill ("damage");
	self notify ("popped");
//	PlayFX (level._effect[ "splash" ], self.origin);
	self delete();
}

door_open()
{
	flag_wait( "garage_ally_0_door_ready" );
	
	flag_wait_all( "garage_ally_0_door_ready", "garage_ally_1_door_ready", "garage_ally_2_door_ready" );
	level.allies[ 0 ] smart_dialogue( "flood_pri_getready" );
	
	//flood music
	music_play( "mus_flood_exfil_tension_ss" );
	
	left_door_parts = GetEntArray( "garage_door_l", "targetname" );
	right_door_parts = GetEntArray( "garage_door_r", "targetname" );
	
	door_open_time = 0.3;
	
	foreach( ent in left_door_parts )
	{
		ent RotateYaw( 130, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}
	
	foreach( ent in right_door_parts )
	{
		ent RotateYaw( -130, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}
	
	// FIX JKU need to revisit this and see if there's a better way to fix this other than turning off the door collision
//	collision_hack = GetEnt( "loading_dock_door_hack", "targetname" );
//	collision_hack NotSolid();
	
	wait door_open_time;
	
	flag_set( "garage_done" );
}

garage_teleport_allies_off_debrisbridge()
{
	trigger = GetEnt( "garage_ally_teleport", "targetname" );
	ally0_tele = getstruct( "garage_ally0_teleport", "targetname" );
	ally1_tele = getstruct( "garage_ally1_teleport", "targetname" );
	ally2_tele = getstruct( "garage_ally2_teleport", "targetname" );

	trigger waittill( "trigger" );

	// stuff like the actor aware everything and personal val we should make sure stays in sync with whatever is done to them after the debris bridge vignette
	if( IsDefined( level.allies[ 0 ].ondebrisbridge ) && level.allies[ 0 ].ondebrisbridge == 1 )
	{
		JKUprint( "teleporting ally 0" );
		level.allies[ 0 ].garage_teleported = true;
		level.allies[ 0 ] StopAnimScripted();
		level.allies[ 0 ] maps\flood_anim::vignette_actor_aware_everything();
		level.allies[ 0 ].ondebrisbridge = 0;
		level.allies[ 0 ] ForceTeleport( ally0_tele.origin, ally0_tele.angles );
		
		// move to a close node that's safe because for some reason they don't want to move to the far away node for a long time
		node = GetNode( "garage_ally0_cover_start", "targetname" );
		og_goalradius = level.allies[ 0 ].goalradius;
		level.allies[ 0 ].goalradius = 8;		
		level.allies[ 0 ] SetGoalNode( node );
		level.allies[ 0 ] waittill( "goal" );
		level.allies[ 0 ].goalradius = og_goalradius;		
		
		level.allies[ 0 ] thread ally_garage_sneak( "r", undefined, "r_end_node" );
		node = GetNode( "garage_ally0_teleport_goal", "targetname" );
		level.allies[ 0 ] SetGoalNode( node );
	}
	
	if( IsDefined( level.allies[ 1 ].ondebrisbridge ) && level.allies[ 1 ].ondebrisbridge == 1 )
	{
		JKUprint( "teleporting ally 1" );
		level.allies[ 1 ].garage_teleported = true;
		level.allies[ 1 ] StopAnimScripted();
		level.allies[ 1 ] maps\flood_anim::vignette_actor_aware_everything();
		level.allies[ 1 ].ondebrisbridge = 0;
		level.allies[ 1 ] ForceTeleport( ally1_tele.origin, ally1_tele.angles );
		
		node = GetNode( "garage_ally1_cover_start", "targetname" );
		og_goalradius = level.allies[ 1 ].goalradius;
		level.allies[ 1 ].goalradius = 8;		
		level.allies[ 1 ] SetGoalNode( node );
		level.allies[ 1 ] waittill( "goal" );
		level.allies[ 1 ].goalradius = og_goalradius;		
		
		level.allies[ 1 ] thread ally_garage_sneak( "y", undefined, "y_end_node" );
		node = GetNode( "garage_ally1_teleport_goal", "targetname" );
		level.allies[ 1 ] SetGoalNode( node );
	}
	
	if( IsDefined( level.allies[ 2 ].ondebrisbridge ) && level.allies[ 2 ].ondebrisbridge == 1 )
	{
		JKUprint( "teleporting ally 2" );
		level.allies[ 2 ].garage_teleported = true;
		level.allies[ 2 ] StopAnimScripted();
		level.allies[ 2 ] maps\flood_anim::vignette_actor_aware_everything();
		level.allies[ 2 ].ondebrisbridge = 0;
		level.allies[ 2 ] ForceTeleport( ally2_tele.origin, ally2_tele.angles );

		node = GetNode( "garage_ally2_cover_start", "targetname" );
		og_goalradius = level.allies[ 2 ].goalradius;
		level.allies[ 2 ].goalradius = 8;		
		level.allies[ 2 ] SetGoalNode( node );
		level.allies[ 2 ] waittill( "goal" );
		level.allies[ 2 ].goalradius = og_goalradius;		

		level.allies[ 2 ] thread ally_garage_sneak( "g", undefined, "g_end_node" );
		node = GetNode( "garage_ally2_teleport_goal", "targetname" );
		level.allies[ 2 ] SetGoalNode( node );
	}
}