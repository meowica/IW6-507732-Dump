//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Factory Chase												**
//                                                                          **
//    Created: 	8/5/12	Neversoft											**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

start()
{
	maps\factory_util::actor_teleport( level.squad[ "ALLY_ALPHA" ]	, "parking_lot_start_alpha" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_BRAVO" ]	, "parking_lot_start_bravo" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_CHARLIE" ], "parking_lot_start_charlie" );
	
	level.player maps\factory_util::move_player_to_start_point( "playerstart_parking_lot" );
	
	level.blockade_vehicle_1 = spawn_vehicle_from_targetname ( "blockade_vehicle_1" );
	level.blockade_vehicle_1 vehicle_lights_on( "headlights" );

	level.blockade_vehicle_1.animname = "first_opfor_car";
	
	level.blockade_vehicle_2 = maps\_vignette_util::vignette_vehicle_spawn( "blockade_vehicle_2", "second_opfor_car" ); //"value" (kvp), "anim_name"
	level.blockade_vehicle_3 = maps\_vignette_util::vignette_vehicle_spawn( "blockade_vehicle_3", "heavy_weapon_opfor_car" ); //"value" (kvp), "anim_name"
	level.blockade_vehicle_2 vehicle_lights_on( "headlights" );
	level.blockade_vehicle_3 vehicle_lights_on( "headlights" );
	
	level.blockade_vehicle_1 thread maps\factory_chase::vehicle_catch_fire_when_shot(  );
	level.blockade_vehicle_2 thread maps\factory_chase::vehicle_catch_fire_when_shot(  );
	level.blockade_vehicle_3 thread maps\factory_chase::vehicle_catch_fire_when_shot(  );
	
	thread chase_scripted_flyovers();
	
	foreach ( guy in level.squad )
	{
		guy.grenadeammo = 0;	
	}	
	
	thread chase_ally_vehicle_setup();
	thread car_chase_intro_car_crash_setup();
	
	// Deletes script models
	thread maps\factory_powerstealth::train_cleanup();
}

main()
{
	flag_wait ( "chase_start_done" );
	battlechatter_off( "allies" );
	thread chase_dialog();
	// thread chase_getaway_foot_soldiers();
	// thread chase_airstrike();
	// chase_ally_vehicle_setup();
	
	// In order to give the vehicle time to spawn
	
	level notify ( "semi_trailer_entrance" );
	
	thread car_chase_intro_car_crash();
	
	level waittill ( "player_switch" );
	
								 //   spawn_trigger_targetname 		    group_targetname 				   delete_trigger_targetname 	   
	thread chase_spawn_drone_group ( "chase_enemy_trigger_1"		 , "chase_first_turn_drone_spawner" , "chase_enemy_trigger_2" );
	thread chase_spawn_drone_group ( "chase_warehouse_drones_trigger", "chase_warehouse_drone_spawner"	, "chase_delete_warehouse_drones" );
	thread chase_spawn_drone_group ( "chase_enemy_trigger_2"		 , "chase_drone_spawner_2"			, "chase_delete_drone_group_2" );
	thread chase_spawn_drone_group ( "chase_spawn_skybridge_drones_1", "chase_drone_skybridge_spawner_1", "chase_delete_drone_group_2" );
	thread chase_spawn_drone_group ( "chase_delete_warehouse_drones" , "chase_drone_skybridge_spawner_2", "chase_delete_drone_group_2" );
	// thread chase_wall_crash();
	
	thread maps\factory_audio::audio_sfx_car_chase_sequence();
	
	wait 42;
	nextmission();

	// level.player_vehicle thread maps\factory_audio::audio_car_explode();
}

section_flag_init()
{
	flag_init ( "player_mount_vehicle_start" );
	flag_init ( "player_mount_vehicle_done" );
	flag_init ( "car_chase_complete" );
	flag_init ( "chase_start_done" );
}

section_precache()
{
	PreCacheModel ( "shipping_frame_boxes" );
}

setup_trailer_platform()
{
	thread chase_player_mount_moving_trailer();
	
	trailer_platform		= GetEnt( "trailer_platform", "targetname" );
	trailer_platform.origin = ( level.ally_vehicle_trailer.origin + ( 395, 0, 112 ) );
	trailer_platform.angles = ( level.ally_vehicle_trailer.angles + ( 0, 180, 0 ) );
    trailer_platform LinkTo( level.ally_vehicle_trailer );
	crate_1 = GetEnt ( "trailer_crate_1", "targetname" );
	//crate_2 = GetEnt ( "trailer_crate_2", "targetname" );
    crate_1 LinkTo( level.ally_vehicle_trailer, "body_anim_jnt" );
    //crate_2 LinkTo( level.ally_vehicle_trailer, "body_anim_jnt" );
    death_triggers = GetEntArray ( "trailer_platform_wheel_death_trigger", "targetname" );
    foreach ( trigger in death_triggers )
    {
    	trigger EnableLinkto();
    	trigger LinkTo ( level.ally_vehicle_trailer );
    }
    
    nodes = GetEntArray ( "trailer_node", "script_noteworthy");
	foreach ( node in nodes )
	{
		node Linkto ( level.ally_vehicle_trailer, "body_anim_jnt" );
	}
    
	thread semi_trailer_death_trigger();
    
    rails = GetEntArray ( "trailer_side_rail", "targetname" );
    foreach ( rail in rails )
    {
    	rail LinkTo ( level.ally_vehicle_trailer, "body_anim_jnt" );
    }
    
	flag_wait ( "player_mount_vehicle_start" );
	
	thread maps\factory_audio::audio_play_ending_scene();
	
	flag_set ( "music_chase_ending" );

	//reset sprint params changed in factory_car_chase() in factory_anim
	SetSavedDvar( "player_sprintUnlimited" , "0" );
	SetSavedDvar( "player_sprintSpeedScale", 1 );

	foreach ( trigger in death_triggers )
	{
		trigger delete();
	}
}

chase_player_mount_moving_trailer()
{
	
	trigger = GetEnt ( "get_in_vehicle_trigger", "targetname" );
	trigger EnableLinkTo();
	trigger LinkTo ( level.ally_vehicle_trailer );
	waittillframeend;
	level waittill ( "start_mount" );
	flag_set ( "factory_rooftop_wind_gust_moment" );
	trigger trigger_on();
	
	// Prevent using the trigger if thermal is being toggled on/off
	trigger thread get_in_vehicle_trigger_thermal_handler();
	
	thread chase_airstrike_kills_player();
	thread chase_player_falls_off_trailer();
	
	// Check that the player is touching the trigger, on the ground, and facing roughly the same direction as the trailer
	while ( 1 )
	{
		if ( abs ( level.player.angles[ 1 ] - level.ally_vehicle_trailer.angles[ 1 ] ) < 45 && flag( "player_near_trailer_rear" ) && level.player IsOnGround () )
		{
			break;	
		}
		
		wait 0.05;	
	}
	
	level.player DisableWeapons();

	// This is to prevent players who are jumping from retaining their momentum and clipping the ground during the lerp
	level.player SetStance ( "stand" );
	vel = level.player GetVelocity();
	level.player SetVelocity( ( vel[ 0 ], vel[ 1 ], 0 ) );
	
	flag_set ( "player_mount_vehicle_start" );
	level notify ( "player_mount_vehicle_start" );
	
	// this is created in factory_anim.gsc
	level.ally_vehicle_trailer notify ( "stop_loop" );
	
	player_rig = spawn_anim_model( "player_rig" );
	factory_car_chase_intro_ally_pulls_up_player_b201 = spawn_anim_model( "factory_car_chase_intro_ally_pulls_up_player_b201" );
	factory_car_chase_intro_ally_pulls_up_player_b202 = spawn_anim_model( "factory_car_chase_intro_ally_pulls_up_player_b202" );
	factory_car_chase_intro_ally_pulls_up_player_b203 = spawn_anim_model( "factory_car_chase_intro_ally_pulls_up_player_b203" );
	player_rig Hide();
	
	guys				 = [];
	// guys[ "ally_delta" ] = level.ally_delta;
	// guys[ "player_rig" ] = player_rig;
	guys[ "ally_alpha" ] = level.squad[ "ALLY_ALPHA" ];
	guys[ "ally_bravo" ] = level.squad[ "ALLY_BRAVO" ];
	guys[ "ally_charlie" ] = level.squad[ "ALLY_CHARLIE" ];
	
	// The bombers play their scene off a static node
	node = getent( "car_chase_intro", "script_noteworthy" );
	bombers				 = [];
	bombers[ "factory_car_chase_intro_ally_pulls_up_player_b201" ] = factory_car_chase_intro_ally_pulls_up_player_b201;
	bombers[ "factory_car_chase_intro_ally_pulls_up_player_b202" ] = factory_car_chase_intro_ally_pulls_up_player_b202;
	bombers[ "factory_car_chase_intro_ally_pulls_up_player_b203" ] = factory_car_chase_intro_ally_pulls_up_player_b203;
	
	player_rig LinkTo ( level.ally_vehicle_trailer, "body_anim_jnt" );
	
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	
	level.ally_vehicle_trailer notify ( "stop_loop" );
	
	node thread anim_single ( bombers, "factory_car_chase_intro_ally_pulls_up_player" );
	
	foreach ( guy in guys )
	{
		guy Linkto ( level.ally_vehicle_trailer, "body_anim_jnt" );
	}
	
	level.ally_vehicle_trailer thread anim_single ( guys, "factory_car_chase_intro_ally_pulls_up_player", "body_anim_jnt" );
	level.ally_vehicle_trailer thread anim_single_solo ( player_rig, "factory_car_chase_intro_ally_pulls_up_player", "body_anim_jnt"  );
	
	arc = 0;
	level.player PlayerLinkToBlend( player_rig, "tag_player", .5, 0.25, 0.25 );
	wait .5;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 0, arc, arc, arc, arc, true );
	player_rig Show();
	
	// Wait until the mounting vignette is done playing
	wait ( GetAnimLength ( player_rig getanim ( "factory_car_chase_intro_ally_pulls_up_player" ) ) - 0.5 );
	player_rig Delete();

	level.player EnableWeapons();
	
	flag_set ( "player_mount_vehicle_done" );
	
	level.player SetMovingPlatformPlayerTurnRate( 0.75 );
	level.player SetStance ( "crouch" );	
	vel = level.player GetVelocity();
	level.player Unlink ();
	level.player SetVelocity( vel );
	level.player.attackeraccuracy = 0.01;

	// Bullets do not exactly go where they seem like they should, so let's turn off friendly fire for now
	// maps\_friendlyfire::TurnOff();
	
	autosave_by_name( "chase" );
	
	wait 1;
	
	flag_set ( "factory_rooftop_wind_gust_moment" );
	// Re-enable the movement disabled above
	level.player FreezeControls ( false );
	level.player SetMoveSpeedScale( 0.5 );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	
	// teleport_player ( node );
	
}

chase_scripted_flyovers()
{
	
	wait 4;
	
	spawn_vehicles_from_targetname_and_drive ( "rooftop_bomber" );	
	
	chase_airstrike_explosion( "rooftop_airstrike_explosion" );
	
	flag_wait ( "player_mount_vehicle_start" );
	
	chase_wait_for_semi_touch ( "chase_enemy_trigger_2" );
	
	spawn_vehicles_from_targetname_and_drive ( "smokestack_bomber" );	
	
	// level waittill ( "hit_vehicle_02" );
	// spawn_vehicles_from_targetname_and_drive ( "bomber_1" );
}

/*
trailer_steering()
{
	
	while ( 1 )
	{
		oldangles = level.ally_vehicle_trailer.angles;
		oldpos	  = level.ally_vehicle_trailer.origin;
		wait 0.1;
		posdif = Distance ( level.ally_vehicle_trailer.origin, oldpos );
		// inches per tenth of a second to miles per hour
		mph = posdif * 0.568181818;
		dif = level.ally_vehicle_trailer.angles - oldangles;
		if ( dif[ 1 ]  >= 0.5 )
			IPrintLn ( "left: " + dif[ 1 ] );
		if ( dif[ 1 ] < -0.5 )
			IPrintLn ( "right: " + ( -1 * dif[ 1 ] ) );
		IPrintLn ( "speed: " + mph );
		g_force = mph * dif[1];
		wait .1;
	}
}
*/

chase_looped_afterburner()
{
	//After Burners are pretty much like turbo boost. They don't use them all the time except when 
	//bursts of speed are needed. Needs a cool sound when they're triggered. Currently, they are set
	//to be on all the time, but it would be cool to see them engage as they fly away.

	PlayFXOnTag( level._effect[ "cheap_spot" ], self, "tag_engine_right" );
	PlayFXOnTag( level._effect[ "cheap_spot" ], self, "tag_engine_left" );

}

chase_airstrike_explosion( source_targetname )
{
	source = GetEnt ( source_targetname, "targetname" );
	PlayFX ( getfx ( source.script_fxid ), source.origin, source.angles );
	level notify ( source_targetname );
}

chase_airstrike_kills_player()
{
	level endon ( "player_mount_vehicle_start" );
	wait_for_flag_or_timeout( "player_left_parking_lot", 6 );
	//"You were killed by the airstrike.\nClimb on the getaway vehicle."
	SetDvar( "ui_deadquote", &"FACTORY_FAIL_ESCAPE" );
	PlayFX ( level._effect[ "101ton_bomb" ], level.player.origin );
	level.player Kill();	
	missionFailedWrapper();
}

chase_player_falls_off_trailer()
{
	flag_wait( "player_mount_vehicle_done" );
	center = GetEnt ( "trailer_platform_center", "targetname" );
	while ( 1 )
	{
		dist = Distance ( center.origin, level.player.origin );
		if ( dist > 512 && IsAlive( level.player ) )
		{
				// level.player SetMoveSpeedScale( 1 );
				//"You fell off the trailer."
				SetDvar( "ui_deadquote", &"FACTORY_FAIL_FELL_OFF_TRAILER" );
				PlayFX ( level._effect[ "101ton_bomb" ], level.player.origin );
				level.player Kill();	
				missionFailedWrapper();
				break;
		}
		wait 0.25;
	}
}

chase_dialog()
{

	level waittill ( "hit_vehicle_02" );
	
	// IPrintLnBold ( "Get on the trailer! Go go go!" );
	level.squad[ "ALLY_ALPHA" ] smart_dialogue ( "factory_mrk_getonthetrailer" );
	
	chase_wait_for_semi_touch ( "chase_enemy_trigger_1" );
	
	//Diaz: Dead End!
	smart_radio_dialogue ( "factory_diz_deadend" );
	//Merrick: No choice! Go through!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue ( "factory_bkr_nochoice" );
	
	chase_wait_for_semi_touch ( "chase_delete_warehouse_drones" );
	
	//Hesh: Ohhhhh shit...
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue ( "factory_hsh_ohhhhshit" );
	
	//Merrick: We got problems back here. Gun it!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue ( "factory_mrk_wegotproblemsback" );
	
	//Oldboy: Pedal's to the metal already!
	smart_radio_dialogue ( "factory_oby_pedalstothemetal" );
	
	//Oldboy:  Hang on!
	smart_radio_dialogue ( "factory_oby_hangon" );
	
}

// Disables the use trigger while the player is toggling thermal on/off
get_in_vehicle_trigger_thermal_handler()
{
	self endon( "trigger" ); // Kill this script when the trigger gets activated
	trigger_on = true;
	while ( 1 )
	{
		if ( level.player.thermal_anim_active && trigger_on )
		{
			self trigger_off();
			trigger_on = false;
		}
		else if ( !level.player.thermal_anim_active && !trigger_on )
		{
			self trigger_on();
			trigger_on = true;
		}
		wait 0.1;
	}
}

// See if players can figure this out without the golden bar
/*
manage_player_vehicle_objective_marker()
{
	marker = GetEnt ( "temp_vehicle_marker", "targetname" );
	marker Hide();
	marker LinkTo ( level.ally_vehicle_trailer );
	level waittill ( "start_mount" );
	marker Show();
	flag_wait ( "player_mount_vehicle_start" );
	marker Delete();
}
*/

chase_ally_vehicle_setup()
{
	// Spawn the chase vehicles early, so the player doesn't see them spawn in.
	level.ally_vehicle		   = maps\_vignette_util::vignette_vehicle_spawn( "chase_ally_vehicle"		  , "het_cab" );
	level.ally_vehicle_trailer = maps\_vignette_util::vignette_vehicle_spawn( "chase_ally_vehicle_trailer", "het_trailer" );
	level.ally_vehicle godon();
	level.ally_vehicle_trailer godon();
	
	// thread manage_player_vehicle_objective_marker();
	
	kill_trigger = GetEnt ( "trailer_airstrike_kill_trigger", "targetname" );
	kill_trigger EnableLinkTo();
	kill_trigger LinkTo ( level.ally_vehicle );
	
	thread setup_trailer_platform();
	
	waittillframeend;
	
	node = getent( "car_chase_intro", "script_noteworthy" );
							 //   guy 					      anime 					  
	node anim_first_frame_solo ( level.ally_vehicle		   , "car_chase_intro_car_crash" );
	node anim_first_frame_solo ( level.ally_vehicle_trailer, "car_chase_intro_car_crash" );
	
	flag_set ( "chase_start_done" );
	
	// wait till now to actually start up the vehicle
	level waittill ( "semi_trailer_entrance" );
	
	level.ally_vehicle thread play_sound_on_tag ( "scn_factory_horn_short", "tag_origin" );
	level.ally_vehicle_front = Spawn ( "script_origin", level.ally_vehicle GetTagOrigin ( "tag_engine_right" ) );
	level.ally_vehicle_front LinkTo( level.ally_vehicle );
	
	vector					= VectorNormalize( AnglesToForward( level.ally_vehicle.angles ) );
	forward					= vector * 192;
	headlight_source		= Spawn ( "script_model", ( level.ally_vehicle.origin + ( 0, 0, 56 ) + forward ) );
	headlight_source.angles = level.ally_vehicle.angles;
	headlight_source SetModel ( "tag_origin" );
	headlight_source LinkTo ( level.ally_vehicle );
	PlayFXOnTag( level._effect[ "real_spot" ], headlight_source, "tag_origin" );
	
	level.ally_vehicle_trailer thread vehicle_lights_on ( "running" );
	level.ally_vehicle vehicle_lights_on ( "running" );
	
	// thread chase_ally_vehicle_trailer_hack();
	thread chase_headlight_fx_swap( headlight_source );
	
}

/*
chase_ally_vehicle_trailer_hack()
{
	level endon ( "face_off_begins" );
	while ( 1 )
	{
		wait 0.1;
		speed = level.ally_vehicle Vehicle_GetSpeed();
		level.ally_vehicle_trailer Vehicle_SetSpeedImmediate( speed, 60, 60 );
	}
}

*/

chase_headlight_fx_swap( headlight_source )
{
	flag_wait ( "player_mount_vehicle_start" );
	
	StopFXOnTag( level._effect[ "real_spot" ], headlight_source, "tag_origin" );
	waittillframeend;

	PlayFXOnTag( level._effect[ "cheap_spot" ], headlight_source, "tag_origin" );
		
}

chase_blockade_crash()
{
	foreach ( guy in level.squad )
	{
		guy.ignoreme = true;
	}
	level.player.ignoreme = true;
	
	enemies = get_living_ai_array ( "blockade_enemy", "script_noteworthy" );
	foreach ( guy in enemies )
	{
		guy SetEntityTarget( level.ally_vehicle );
		guy.maxSightDistSqrd = 8192 * 8192;
		turret				 = guy GetTurret ();
		if ( IsDefined ( turret ) )
		{
		  turret SetTargetEntity( level.ally_vehicle );	
		}
	}
	
	wait 1;
	
	// No more reactions from the squad that might interfere with pathing to the curb hop start point.
	foreach ( guy in level.squad )
	{
		guy disable_pain();
		guy.ignoresuppression			   = true;
		SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );
	}
	
	activate_trigger_with_targetname ( "p_b_r_ally_move_602" );
	
	wait 2;
	
	// Stop shooting at enemies
	foreach ( guy in level.squad )
	{
		guy.ignoreall = true;
	}

	level.ally_vehicle thread play_sound_on_tag ( "scn_factory_horn_long", "tag_origin" );
	
	// Enemies make ineffectual attempt to flee
	enemies = get_living_ai_array ( "blockade_enemy", "script_noteworthy" );
	foreach ( enemy in enemies )
	{
		enemy.ignoreall = true;
		wait .1;
		enemy SetGoalEntity(level.blockade_vehicle_3);
	}	
	
	wait 3;
	
	level notify ( "semi_rams_blockade" );
	
	enemies = get_living_ai_array ( "blockade_enemy", "script_noteworthy" );
	foreach ( enemy in enemies )
	{
		enemy Kill( (-462, 55, 40));
	}	

	level.player.ignoreme = false;
}

ally_reach_curb_hop( anime )
{
	self.goalradius = 8;
	node			= GetEnt( "car_chase_intro_proxy", "targetname" );
	node anim_reach_and_approach_solo ( self, anime );
	self SetGoalPos ( self.origin );
}

/*
chase_blockade_cars_hit()
{
	level waittill ( "hit_vehicle_02" );
	cars = GetEntArray ( "parking_lot_car", "script_noteworthy" );
	foreach ( car in cars )
	{
		car thread destructible_force_explosion();
		wait 0.1;
	}
	
}
*/
car_chase_intro_car_crash_setup()
{
	// First frame all of the objects which get run over by the truck in the parking lot
	guys = [];
	
	level.factory_car_chase_intro_broken_awning01	= spawn_anim_model( "factory_car_chase_intro_broken_awning01" );
	level.factory_car_chase_intro_broken_awning02	= spawn_anim_model( "factory_car_chase_intro_broken_awning02" );
	level.factory_car_chase_intro_broken_awning03	= spawn_anim_model( "factory_car_chase_intro_broken_awning03" );
	level.factory_car_chase_intro_broken_awning04	= spawn_anim_model( "factory_car_chase_intro_broken_awning04" );
	level.factory_car_chase_intro_broken_fence01	= spawn_anim_model( "factory_car_chase_intro_broken_fence01" );
	level.factory_car_chase_intro_broken_fence02	= spawn_anim_model( "factory_car_chase_intro_broken_fence02" );
	level.factory_car_chase_intro_broken_light_post = spawn_anim_model( "factory_car_chase_intro_broken_light_post" );
	level.factory_car_chase_intro_side_car01 = spawn_anim_model( "factory_car_chase_intro_side_car01_crash" );
	level.factory_car_chase_intro_side_car02 = spawn_anim_model( "factory_car_chase_intro_side_car02_crash" );
	level.third_opfor_car = maps\_vignette_util::vignette_vehicle_spawn( "parking_lot_stationary_vehicle", "third_opfor_car" );
	level.third_opfor_car thread vehicle_catch_fire_when_shot();
	
	guys[ "factory_car_chase_intro_broken_awning01"	  ] = level.factory_car_chase_intro_broken_awning01;
	guys[ "factory_car_chase_intro_broken_awning02"	  ] = level.factory_car_chase_intro_broken_awning02;
	guys[ "factory_car_chase_intro_broken_awning03"	  ] = level.factory_car_chase_intro_broken_awning03;
	guys[ "factory_car_chase_intro_broken_awning04"	  ] = level.factory_car_chase_intro_broken_awning04;
	guys[ "factory_car_chase_intro_broken_fence01"	  ] = level.factory_car_chase_intro_broken_fence01;
	guys[ "factory_car_chase_intro_broken_fence02"	  ] = level.factory_car_chase_intro_broken_fence02;
	guys[ "factory_car_chase_intro_broken_light_post" ] = level.factory_car_chase_intro_broken_light_post;
	guys[ "factory_car_chase_intro_side_car01_crash" ] = level.factory_car_chase_intro_side_car01;
	guys[ "factory_car_chase_intro_side_car02_crash" ] = level.factory_car_chase_intro_side_car02;
	
	node = getent( "car_chase_intro", "script_noteworthy" );
	node anim_first_frame ( guys, "car_chase_intro_car_crash" );	
	node anim_first_frame_solo ( level.third_opfor_car, "factory_car_chase" );	
	
	// Make non-colliding the brush that blocks off the knocked over states for the utility trucks
	truck_blocker_2 = GetEnt ( "parking_lot_trucks_at_rest_blocker", "targetname" );
	truck_blocker_2 ConnectPaths();
	truck_blocker_2 NotSolid();
}

car_chase_intro_car_crash()
{
	
	parking_lot_guys = [];
	
	parking_lot_guys[ "factory_car_chase_intro_broken_awning01"	  ] = level.factory_car_chase_intro_broken_awning01;
	parking_lot_guys[ "factory_car_chase_intro_broken_awning02"	  ] = level.factory_car_chase_intro_broken_awning02;
	parking_lot_guys[ "factory_car_chase_intro_broken_awning03"	  ] = level.factory_car_chase_intro_broken_awning03;
	parking_lot_guys[ "factory_car_chase_intro_broken_awning04"	  ] = level.factory_car_chase_intro_broken_awning04;
	parking_lot_guys[ "factory_car_chase_intro_broken_fence01"	  ] = level.factory_car_chase_intro_broken_fence01;
	parking_lot_guys[ "factory_car_chase_intro_broken_fence02"	  ] = level.factory_car_chase_intro_broken_fence02;
	parking_lot_guys[ "factory_car_chase_intro_broken_light_post" ] = level.factory_car_chase_intro_broken_light_post;
	parking_lot_guys[ "first_opfor_car"							  ] = level.blockade_vehicle_1;
	parking_lot_guys[ "second_opfor_car"						  ] = level.blockade_vehicle_2;
	parking_lot_guys[ "factory_car_chase_intro_side_car01_crash" ] = level.factory_car_chase_intro_side_car01;
	parking_lot_guys[ "factory_car_chase_intro_side_car02_crash" ] = level.factory_car_chase_intro_side_car02;
	
	node = getent( "car_chase_intro", "script_noteworthy" );
	
	// threading the solar panels and enemy vehicles since they have a shorter animation.
	node thread anim_single( parking_lot_guys, "car_chase_intro_car_crash" );
	
	// These vehicles should all have been spawned by now
	chase_guys = [];

	chase_guys[ "heavy_weapon_opfor_car" ] = level.blockade_vehicle_3;
	chase_guys[ "het_cab"				   ] = level.ally_vehicle;
	chase_guys[ "het_trailer"			   ] = level.ally_vehicle_trailer;
		
	// level.ally_delta = maps\_vignette_util::vignette_actor_spawn( "chase_ally_delta", "ally_delta" ); //"value" (kvp), "anim_name"
	// level.ally_delta LinkTo ( level.ally_vehicle_trailer );
	// level.ally_vehicle_trailer thread anim_loop_solo ( level.ally_delta, "factory_car_chase_intro_ally_pulls_up_player_loop", "stop_loop" );
	
	thread chase_blockade_crash();
	// thread chase_blockade_cars_hit();
	// thread chase_blockade_apc_hit();
	
	thread car_crash_slowmo();
	level.ally_vehicle thread maps\factory_parking_lot::parking_lot_blockade_vehicle_death_radius();
	
	level.ally_vehicle notify( "suspend_drive_anims" );
	level.ally_vehicle_trailer notify( "suspend_drive_anims" );

	level.ally_vehicle thread maps\factory_audio::sfx_play_crash_scene();
	node thread anim_single( chase_guys, "car_chase_intro_car_crash" );
	level waittill ( "player_switch" );

	// Swaps the building corner geo out, so the animated model can take over.
	exploder( "building_corner_01_exploder" );
	
	thread maps\factory_anim::factory_car_chase_spawn();
	
	chase_wait_for_semi_touch ( "chase_entering_warehouse" );
	
	parking_lot_guys[ parking_lot_guys.size] = level.third_opfor_car;
	parking_lot_guys[ parking_lot_guys.size] = level.blockade_vehicle_3;
	parking_lot_guys[ parking_lot_guys.size] = level.factory_car_chase_intro_side_car03_blowup;
	
	foreach ( guy in parking_lot_guys )
	{
		guy delete();
	}
	
}

car_crash_slowmo()
{
	wait 5.3333;
	Earthquake( 0.5, 1.5, level.player.origin, 2500 );
	level.player PlayRumbleOnEntity( "artillery_rumble" );
}

semi_trailer_death_trigger()
{
	level endon ( "semi_stopped" );
	kill_trigger = GetEnt ( "trailer_intro_kill_trigger", "targetname" );
    kill_trigger EnableLinkTo();
    kill_trigger Linkto ( level.ally_vehicle_trailer );
    kill_trigger thread semi_trailer_death_trigger_delete();
    
    flag_wait ( "flag_trailer_intro_kill" );
    
    SetDvar( "ui_deadquote", &"FACTORY_FAIL_HIT_BY_TRAILER" );
	level.player Kill();
	missionFailedWrapper();
    
}

semi_trailer_death_trigger_delete()
{
	level waittill ( "semi_stopped" );
	
	self delete();
}

/*
chase_getaway_foot_soldiers()
{
	level waittill ( "hit_vehicle_3" );
	wait 2;
	spawners = GetEntArray ( "parking_lot_wave_2", "targetname" );
	
	foreach ( spawner in spawners )
	{
		guy = spawner spawn_ai();
		if ( IsDefined ( guy ) )
		{
			guy SetEntityTarget( level.ally_vehicle );		
		}
	}
	
	level waittill ( "chase_explosion_3_c" );
	enemies = get_living_ai_array ( "parking_lot_wave_2", "script_noteworthy" );
	foreach ( guy in enemies )
	{
		guy kill();
	}
	
	level waittill ( "chase_explosion_3_d" );
	wait .5;
	enemies = get_living_ai_array ( "security_booth_enemy", "script_noteworthy" );
	foreach ( guy in enemies )
	{
		guy kill();
	}
	
}

chase_wall_crash()
{
	wall = GetEnt ( "chase_crash_wall", "targetname" );
	chase_wait_for_semi_touch( "chase_crash_wall_volume" );
	PlayFX ( level._effect[ "factory_chase_stack_pieces_impact_dust" ], wall.origin, ( -1, -1, 0 ) );
	wall Delete();
}
*/
chase_wait_for_semi_touch( volume_targetname )
{
	volume = GetEnt ( volume_targetname, "targetname" );
	while ( !level.ally_vehicle_front IsTouching( volume ) )
	{
		wait 0.05;	
	}	
}

chase_spawn_drone_group( spawn_trigger_targetname, group_targetname, delete_trigger_targetname )
{
	chase_wait_for_semi_touch ( spawn_trigger_targetname );
	guys = array_spawn_targetname ( group_targetname );
	if ( IsDefined ( delete_trigger_targetname ) )
	{
	    chase_wait_for_semi_touch ( delete_trigger_targetname );
		// guys = array_removeDead_or_dying ( guys );
		foreach ( guy in guys )
		{
			guy Delete();
	
		}
	}
}
/*
enemy_vehicle_crash_on_path_end( explode_notify )
{
	self endon ( "death" );
	level waittill ( explode_notify );
	self thread maps\factory_audio::audio_car_explode();
	
	self VehPhys_Launch( 80 * ( AnglesToForward ( self.angles ) + ( 0, 0, .2 ) ), 1 );
	wait RandomFloatRange ( 0.2, .5 );
	self notify ( "stop_vehicle_detect_crash" );
	self Kill();
	array_thread( self.riders, ::vehicle_crash_guy, self );
	self thread vehicle_crash_launch_guys();
}
*/
enemy_vehicle_setup( explode_notify )
{
	waittillframeend;
	
	self vehicle_lights_on( "headlights" );
	// self thread enemy_vehicle_twitch();
	// self thread vehicle_crash_when_driver_dies();
	self thread vehicle_catch_fire_when_shot();
	// self thread enemy_vehicle_crash_on_path_end( explode_notify );
}

/*
helicopter_temp_attach_guy()
{
	guy		  = spawn_targetname ( "chase_heli_gunner" );
	linkpoint = Spawn ( "script_origin", self GetTagOrigin ( "tag_flash_22" ) - ( 0, 32, 0 ) );
	linkpoint SetModel ( "tag_origin" );
	linkpoint.angles = self GetTagAngles ( "tag_flash_22" );
	linkpoint LinkTo ( self, "tag_flash_22" );
	
	guy teleport_to_ent_tag( linkpoint, "tag_origin" );
	guy LinkTo ( linkpoint, "tag_origin" );
	guy.favoriteenemy	 = level.player;
	guy.attackeraccuracy = 0.01;
}
*/

vehicle_catch_fire_when_shot(  )
{
	self endon ( "death" );
	self.vehicle_stays_alive = true;
	while ( self.health > 0 )
	{
		self waittill( "damage" );
		waittillframeend; // to let friendlyfire_sheild process our health
		
		if ( self.health < self.healthbuffer )
			break;	
	}
	self godon();
	// If it's a physics vehicle, it's one of the chase vehicles, and will be de-animated and launched
	if ( self Vehicle_IsPhysVeh() )
	{
		// determine an approximate velocity by picking an origin and then another one later
		old_origin = self.origin;
		wait .1;
		vector = self.origin - old_origin;
		self StopAnimScripted();
		// teleporting the physics vehicle to its own location appears to reset its physics properties (otherwise it had a weird spin to it, as I think it was trying to reach ithe angles of the spawner).
		self Vehicle_Teleport ( self.origin, self.angles );
		// multiply the vector derived above, add an up force of a random amount and then launch it
		launchvector = 4 * vector + (0,0, RandomIntRange ( 10, 15) );
		self VehPhys_Launch ( launchvector, RandomFloatRange ( 0.6, 1 ), self GetTagOrigin ( "TAG_BRAKELIGHT_RIGHT" )  );
	}
	
	PlayFX ( level._effect[ "lynxexplode" ], self.origin, AnglesToUp( self.angles)  );
	self vehicle_lights_off ( "headlights" );
	array_thread( self.riders, ::vehicle_crash_guy, self );
	
	PlayFXOnTag ( level._effect[ "lynxfire" ], self, "tag_hood_fx" );	
}

vehicle_crash_guy( vehicle )
{
	if ( !IsDefined( self ) || self.vehicle_position == 0 )
	{
		return;
	}
	else
	{
		self.deathanim = undefined;
		self.noragdoll = undefined;
		vehicle.riders = array_remove( vehicle.riders, self );

		self.ragdoll_immediate = true;
		
		if ( IsDefined( self ) )
		{
			if ( !IsDefined( self.magic_bullet_shield ) )
				self Kill();
		}
	}
}

vehicle_crash_launch_guys()
{
	wait 0.1; // .1 longer wait then the one in vehicle_crash_guy
	if ( IsDefined( self ) )
	{
		expl_origin = self GetTagOrigin( "tag_guy1" );
		PhysicsExplosionCylinder( expl_origin, 300, 300, .25 );
	}
}