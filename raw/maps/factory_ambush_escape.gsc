//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Factory Ambush Escape										**
//                                                                          **
//    Created: 	8/5/12	Neversoft											**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


start()
{
	maps\factory_util::actor_teleport( level.squad[ "ALLY_ALPHA"   ], "ambush_escape_start_alpha"	);
	maps\factory_util::actor_teleport( level.squad[ "ALLY_BRAVO"   ], "ambush_escape_start_bravo"	);
	maps\factory_util::actor_teleport( level.squad[ "ALLY_CHARLIE" ], "ambush_escape_start_charlie" );
	
	flag_set( "lgt_ambush_escape_jump" );
	// Give the allies initial color orders
	maps\factory_util::safe_trigger_by_targetname( "ambush_escape_allies_goto_office" );

	level.player maps\factory_util::move_player_to_start_point( "playerstart_ambush_escape" );
	
	// Audio: Cue up pa bursts for next section
	thread maps\factory_audio::sfx_pa_bursts();

	//level thread spawn_scripted_spotlight_choppers();
	thread maps\factory_rooftop::rooftop_heli();
	thread maps\factory_fx::rooftop_wind_gusts();
	
	// Deletes script models
	thread maps\factory_powerstealth::train_cleanup();
}

section_precache()
{
}

section_flag_init()
{
	flag_init( "ambush_escape_clear" );
	flag_init ( "spawn_loading_dock_vehicles ");
	flag_init ( "lgt_ambush_escape_jump" );
}

main()
{
	// TEMP
	level.use_animated_ambush_escape_chopper = true;

	// Save
	autosave_by_name( "ambush_escape" );

	// thread maps\factory_util::make_it_rain( "rain_heavy_mist", "car_chase_complete" );
	
	// Wait for player to hit trigger in security room
	flag_wait( "ambush_player_in_office" );
	
	thread ambush_escape_rain_control();

	thread ambush_escape_dialogue();
	
	// TEMP FIX
	// Force thermal off and disable it
	//level.player thread maps\factory_util::thermal_disable();
	if( level.player.thermal == true )
	{
		level.player notify( "use_thermal" );
		level.player maps\factory_util::turn_off_thermal_vision();
	}

	// Animated spotlight
	// level thread escape_animated_spotlight();

	// Move allies to the rooftop entrance
	// level.squad[ "ALLY_ALPHA"	] thread maps\factory_anim::ambush_escape_ally01_spotlight_run();
	// level.squad[ "ALLY_BRAVO"	] thread maps\factory_anim::ambush_escape_ally02_spotlight_run();
	// level.squad[ "ALLY_CHARLIE" ] thread maps\factory_anim::ambush_escape_ally03_spotlight_run();
	
	maps\factory_util::safe_trigger_by_targetname( "ambush_escape_allies_stop_midway" );
	
	flag_wait ( "spawn_loading_dock_vehicles");
	
	thread loading_dock_vehicles();
	
	maps\factory_util::safe_trigger_by_targetname( "ambush_escape_allies_rooftop" );
	
	// Start the heli fly over
	//level.escape_chopper_spotlight_1 thread escape_chopper_spotlight_one();
	//level.escape_chopper_spotlight_2 thread escape_chopper_spotlight_two();
	thread maps\factory_rooftop::rooftop_door_breach();
	
	flag_wait( "ambush_escape_clear" );
	
	// wait 0.1; // Short wait to allow for spotlight to get cleaned up
}

ambush_escape_rain_control()
{

	flag_wait ( "ambush_escape_rain");			
	thread maps\_weather::rainLight ( 0 );

}

ambush_escape_dialogue()
{
	
	flag_wait ( "ambush_escape_dialogue_trigger");
	
	// Merrick: "Diaz! We need a vehicle!"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_needavehicle" );
	
	// Diaz: "Copy that! We’re securing a vehicle. RV at the parking lot to the South"
	smart_radio_dialogue( "factory_diz_securingvehicle" );
}

loading_dock_vehicles()
{
	
	// We're spawning the escape vehicle at this point, since it's visible in the distant loading dock
	thread maps\factory_chase::chase_ally_vehicle_setup();
	cars = spawn_vehicles_from_targetname_and_drive( "ambush_escape_vehicle" );
	foreach ( car in cars )
	{	
		car thread loading_dock_vehicle_setup();
	}

	flag_wait ("ambush_escape_clear");
	
	cars_2 = spawn_vehicles_from_targetname_and_drive( "ambush_escape_vehicle_second_wave" );
	foreach ( car in cars_2 )
	{
		car thread loading_dock_vehicle_setup();
	}
}

loading_dock_vehicle_setup()
{
	self vehicle_lights_on ( "headlights" );
	self thread maps\factory_chase::vehicle_catch_fire_when_shot();
	foreach ( guy in self.riders )
	{
		guy thread loading_dock_enemies();	
	}
	self waittill ( "reached_end_node" );
	wait ( RandomFloatRange ( 1.0, 2.0 ));
	self vehicle_lights_off ( "headlights" );
	
	level waittill ( "rooftop_complete" );	
	self delete();
}

loading_dock_enemies()
{
	self waittill ("goal");
	self delete();
}

/*
// Spawn the choppers and let them idle
spawn_scripted_spotlight_choppers()
{
	level.escape_chopper_spotlight_1 = spawn_vehicle_from_targetname( "escape_chopper_spotlight_1" );
	level.escape_chopper_spotlight_2 = spawn_vehicle_from_targetname( "escape_chopper_spotlight_2" );

	c1 = level.escape_chopper_spotlight_1;
	c2 = level.escape_chopper_spotlight_2;
	
	// Unkillable
	c1 godon();
	c2 godon();

	// Direct the turrets to their proper targets
	c1 vehicle_scripts\_attack_heli::heli_default_target_setup();
	c2 vehicle_scripts\_attack_heli::heli_default_target_setup();

	c1 thread vehicle_scripts\_attack_heli::heli_spotlight_on( "tag_barrel", false );
	c2 thread vehicle_scripts\_attack_heli::heli_spotlight_on( "tag_barrel", false );

	c1 SetHoverParams ( 128 );
	c2 SetHoverParams ( 128 );

	c1 thread spotlight_heli_target_think( "escape_spotlight_node_1" );
	c2 thread spotlight_heli_target_think( "escape_spotlight_node_2" );
}

// Animated version of the spotlight chopper
escape_animated_spotlight()
{
	if( !level.use_animated_ambush_escape_chopper )
	{
		return;
	}
	flag_wait( "ambush_escape_heli_1_trigger" );
	level thread maps\factory_anim::ambush_escape_spotlight_chopper();
}

escape_chopper_spotlight_one()
{
	self endon( "death" );
	if( level.use_animated_ambush_escape_chopper )
	{
		return;
	}

	flag_wait( "ambush_escape_heli_1_trigger" );

	// Start the path
	chopper_node = GetStruct( self.target, "targetname" );
	self thread vehicle_paths( chopper_node );
	PlayFXOnTag ( level._effect[ "real_heli_spot" ], self, "tag_barrel" );

	// Player hit heli 2 flag
	flag_wait( "ambush_escape_heli_2_trigger" );
	StopFXOnTag( level._effect[ "real_heli_spot" ], self, "tag_barrel" );
}


// Spawns chopper with spotlight
escape_chopper_spotlight_two()
{
	self endon( "death" );
	if( level.use_animated_ambush_escape_chopper )
	{
		return;
	}

	flag_wait( "ambush_escape_heli_2_trigger" );
	wait 0.1;

	// Start the path
	chopper_node = GetStruct( self.target, "targetname" );
	self thread vehicle_paths( chopper_node );
	PlayFXOnTag ( level._effect[ "spotlight_model_factory" ], self, "tag_barrel" );

	// Handle spotlight juggling
	self thread chopper_two_spotlight_killer();

	// Move spotlight away
	self waittill( "position_4" );
	self notify( "stop_spotlight_tracking" );
	self thread spotlight_heli_target_think( "escape_spotlight_node_1" );
}

// Kills the spotlight when its needed by the next chopper
chopper_two_spotlight_killer()
{
	self endon( "death" );

	// Player hit heli 2 flag
	flag_wait( "ambush_escape_clear" );
	StopFXOnTag( level._effect[ "spotlight_model_factory" ], self, "tag_barrel" );	
}

spotlight_heli_target_think( node_targetname )
{
	self endon( "death" );
	self endon( "stop_spotlight_tracking" );
	target = GetEnt( node_targetname, "targetname" );
	org_pos = target.origin;
		
	offsetMinX = 0;
	offsetMaxX = 32;
	offsetMinY = 0;
	offsetMaxY = 32;
	offsetMinZ = 0;
	offsetMaxZ = 32;

	self SetTurretTargetEnt( target, ( 0, 0, 0 ) );

	while ( 1 )
	{
		// Re-roll the randoms
		randX_offset = RandomIntRange( offsetMinX, offsetMaxX );
		randY_offset = RandomIntRange( offsetMinY, offsetMaxY );
		randZ_offset = RandomIntRange( offsetMinZ, offsetMaxZ );

		// Randomize left/right Y offset
		if ( cointoss() )
		{
			randY_offset *= -1;
		}
		
		// Randomize up/down Z offset
		if ( cointoss() )
		{
			randZ_offset *= -1;
		}
		
		// Randomize fore/back X offset
		if ( cointoss() )
		{
			randX_offset *= -1;
		}

		// Move the target entity to the random position
		target.origin = ( org_pos + ( randX_offset, randY_offset, randZ_offset ) );
		wait ( RandomFloatRange ( 0.1, 0.25 ) );
	}
}
*/