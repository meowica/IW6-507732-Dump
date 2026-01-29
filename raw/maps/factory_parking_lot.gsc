//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Factory Parking Lot											**
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
	maps\factory_util::actor_teleport( level.squad[ "ALLY_ALPHA" ]	, "parking_lot_start_alpha" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_BRAVO" ]	, "parking_lot_start_bravo" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_CHARLIE" ], "parking_lot_start_charlie" );
	
	level.player maps\factory_util::move_player_to_start_point( "playerstart_parking_lot" );
	
	thread parking_lot_blockade_vehicle_1( "blockade_vehicle_1" );
	
	thread maps\_weather::rainMedium ( 1 );
	
	thread maps\factory_chase::car_chase_intro_car_crash_setup();
	
	thread maps\factory_chase::chase_ally_vehicle_setup();
	
	flag_set ( "player_near_rooftop_end" );
}

main()
{
	autosave_by_name( "rooftop_complete" );
	
	thread parking_lot_rain_stops();
	
	thread parking_lot_ally_location_check();
	
	thread load_outro_transients();

	// If the player has found a nice spot to camp on the rooftop, and chooses to sit there, we're still going to blow up the factory. 
	wait_for_flag_or_timeout ( "player_near_rooftop_end", 30 );
	
	parking_lot_vehicle_setup();

}

parking_lot_rain_stops()
{
	flag_wait ( "player_off_roof");
	thread maps\_weather::rainNone ( 5 );	
}

load_outro_transients()
{
	// Adding wait so the disappearing models are less obvious
	flag_wait ( "player_off_roof");
	
	// CF - LOADING UP NEXT TRANSIENT FASTFILE WHICH INCLUDES CAR CHASE ITEMS
	transient_unloadall_and_load( "factory_outro_tr" );
    
	level waittill ( "semi_trailer_entrance" );
	// making sure all transient FF items are loaded
	maps\factory_util::sync_transients();
}

section_flag_init()
{
	flag_init ( "allies_in_loading_dock" );
}

section_precache()
{
}

parking_lot_vehicle_setup()
{
	parking_lot_blockade();
	thread parking_lot_dialog();
	
	// Grenades are just bad news in this encounter, enemies keep throwing them back.
	foreach ( guy in level.squad )
	{
		guy.grenadeammo = 0;	
	}
	// thread parking_lot_location_player_check();
	flag_wait ( "allies_in_loading_dock" );
	
	wait 4;
	
	level notify ( "here_comes_the_truck" );
}

parking_lot_dialog()
{
	// KM - Need to figure out a more reliable way of generating the enemy reactions to the truck entrance.
	//thread parking_lot_enemy_dialog();
	
	//Rogers: Vehicles incoming!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_rgs_vehiclesincoming" );
	
	//Merrick: Get to cover!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_gettocover2" );
	
	flag_wait ( "allies_in_loading_dock" );
	
	//Merrick: Stay down!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_staydown" );
	
	//Rogers: Running low! Where's Diaz!?
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_rgs_runninglow" );
	
	//Merrick: Diaz! Where is our exfil?!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_whereisourexfil" );
	
	//Diaz: Almost there!
	smart_radio_dialogue( "factory_diz_almostthere" );
	
	//Diaz: Coming in hot! On your right!
	smart_radio_dialogue ( "factory_diz_inhotonright" );
	
	
}

// Randomly select among any remaining enemies int he parking lot and have them react to the incoming truck.
parking_lot_enemy_dialog()
{
	level waittill ( "here_comes_the_truck" );
	guys = get_living_ai_array ( "blockade_enemy"	, "script_noteworthy" );
	guys = get_array_of_closest( level.player.origin, guys );
	
	//Generic Soldier 1: What?!
	guys[ 0 ] thread enemy_alive_dialog ( "factory_gs1_what" );
	wait 0.2;
	
	//Generic Soldier 1: Look out!
	guys[ 1 ] thread enemy_alive_dialog( "factory_gs1_lookout" );
	wait 0.1;
	
	//Generic Soldier 1: Run!
	guys[ 2 ] thread enemy_alive_dialog( "factory_gs1_run" );
	wait 0.3;
	
	//Generic Soldier 1: Shoot it!
	guys[ 3 ] thread enemy_alive_dialog( "factory_gs1_shootit" );
	
}

// Check if the guy exists and is living before playing dialog
enemy_alive_dialog( Line )
{
	if ( IsDefined ( self ) && IsAlive ( self ) )
	    {
			self.animname = "enemy";
	    	self smart_dialogue( Line );
	    }
}

parking_lot_blockade()
{
	wait .1;
	thread parking_lot_blockade_vehicle_2( "blockade_vehicle_2" );
	wait .1;
	thread parking_lot_blockade_vehicle_3( "blockade_vehicle_3" );
	
	foreach ( guy in level.squad )
	{
		guy thread parking_lot_allies_take_cover();
	}
}

parking_lot_allies_take_cover()
{
	self enable_sprint();
	self disable_pain();
	self.ignoresuppression			   = true;
	level.ai_friendlyFireBlockDuration = GetDvarFloat( "ai_friendlyFireBlockDuration" );
	SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );
	
	flag_wait ( "allies_in_loading_dock" );
	
	self disable_sprint();
	// self enable_pain();
	// self.ignoresuppression = false;
	// SetSavedDvar( "ai_friendlyFireBlockDuration", level.ai_friendlyFireBlockDuration );
}

parking_lot_ally_location_check()
{
	volume = GetEnt ( "loading_dock_cover", "targetname" );
	while ( 1 )
	{
		guys = volume get_ai_touching_volume( "allies" );
		if ( guys.size == 3 )
		{
			flag_set ( "allies_in_loading_dock" );
			break;	
		}
		wait 0.1;
	}
	thread parking_lot_timeout();
}

parking_lot_timeout()
{
	level endon ( "player_off_roof" );
	wait 10;
	maps\factory_util::safe_trigger_by_targetname ( "start_chase_sequence_trigger" );
	level waittill ( "semi_trailer_entrance");
	level notify ( "player_off_roof" );
}

/*
parking_lot_location_player_check()
{
	volume = GetEnt ( "loading_dock_cover", "targetname" );
	while ( 1 )
	{
		if ( level.player IsTouching ( volume ) )
		{
			flag_set ( "player_in_loading_dock" );
			level.player.threatbias = -500;
		}
		else
		{
			flag_clear ( "player_in_loading_dock" );
			level.player.threatbias = 1500;
		}
		wait 0.25;
		
	}
}
*/

parking_lot_blockade_vehicle_1( vehicle_targetname )
{
	level.blockade_vehicle_1 = spawn_vehicle_from_targetname ( vehicle_targetname );
	level.blockade_vehicle_1 vehicle_lights_on( "running" );
	level.blockade_vehicle_1 thread maps\factory_audio::sfx_jeep_drive_up_01();
	level.blockade_vehicle_1 godon();
	
	level.blockade_vehicle_1.animname = "first_opfor_car";
	node = getent( "car_chase_intro", "script_noteworthy" );
	level.blockade_vehicle_1 notify ( "suspend_drive_anims" );
	node thread anim_single_solo( level.blockade_vehicle_1, "car_chase_intro_pullup" );
	
	wait 3;
	level.blockade_vehicle_1 godoff();
	level.blockade_vehicle_1 thread maps\factory_chase::vehicle_catch_fire_when_shot(  );
	level.blockade_vehicle_1 vehicle_unload( "all" );
	level waittill ( "hit_vehicle_01" );
	level.blockade_vehicle_1 thread parking_lot_blockade_vehicle_death_radius();
	
	// The utility trucks in the parking lot becomes deadly projectiles as well
	level.factory_car_chase_intro_side_car01 thread parking_lot_blockade_vehicle_death_radius();
	level.factory_car_chase_intro_side_car02 thread parking_lot_blockade_vehicle_death_radius();
}

parking_lot_blockade_vehicle_2( vehicle_targetname )
{
	level.blockade_vehicle_2 = spawn_vehicle_from_targetname ( vehicle_targetname );
	level.blockade_vehicle_2 vehicle_lights_on( "running" );
	level.blockade_vehicle_2 thread maps\factory_audio::sfx_jeep_drive_up_02();
	level.blockade_vehicle_2 godon();
		
	level.blockade_vehicle_2.animname = "second_opfor_car";
	
	node = getent( "car_chase_intro", "script_noteworthy" );
	level.blockade_vehicle_2 notify ( "suspend_drive_anims" );
	node thread anim_single_solo( level.blockade_vehicle_2, "car_chase_intro_pullup" );
	
	wait 3.5;
	level.blockade_vehicle_2 godoff();
	level.blockade_vehicle_2 thread maps\factory_chase::vehicle_catch_fire_when_shot(  );
	level.blockade_vehicle_2 vehicle_unload( "all_but_gunner" );
	level waittill ( "hit_vehicle_02" );
	level.blockade_vehicle_2 thread parking_lot_blockade_vehicle_death_radius();
	
}

parking_lot_blockade_vehicle_3( vehicle_targetname )
{
	level.blockade_vehicle_3 = spawn_vehicle_from_targetname ( vehicle_targetname );
	level.blockade_vehicle_3 vehicle_lights_on( "running" );
 	level.blockade_vehicle_3 thread maps\factory_audio::sfx_tank_drive_up();
	level.blockade_vehicle_3 godon();
 		
 	level.blockade_vehicle_3.animname = "heavy_weapon_opfor_car";
	node = getent( "car_chase_intro", "script_noteworthy" );
	level.blockade_vehicle_3 notify ( "suspend_drive_anims" );
	node thread anim_single_solo( level.blockade_vehicle_3, "car_chase_intro_pullup" );
	wait 2.5;
	level.blockade_vehicle_3 godoff();
	level.blockade_vehicle_3 thread maps\factory_chase::vehicle_catch_fire_when_shot(  );
	level.blockade_vehicle_3 vehicle_unload( "all" );
	level waittill ( "hit_vehicle_03" );
	level.blockade_vehicle_3 thread parking_lot_blockade_vehicle_death_radius();
}

parking_lot_blockade_vehicle_death_radius()
{
	level endon ( "semi_stopped" );
	while ( 1 )
	{
		dist = Distance ( self.origin, level.player.origin );
		if ( dist < 256 )
		{
			SetDvar( "ui_deadquote", &"FACTORY_FAIL_HIT_BY_TRAILER" );
			level.player Kill();
			missionFailedWrapper();
		}
		wait 0.1;
	}
}

parking_lot_fire_hydrant_explodes()
{
	target = GetEnt ("parking_lot_apc_target_02", "targetname");
	RadiusDamage( target.origin, 100, 5000, 5000, level.player );
}

/*
parking_lot_player_death_trigger()
{
	level endon ( "semi_trailer_entrance_complete" );
	trigger_wait_targetname( "parking_lot_kill_trigger" );
	self notify ( "stop_firing" );
 	// self thread maps\factory_util::apc_firing_logic( level.player, 0 ); 	
	level.player DoDamage( ( level.player.health - 1 ), self.origin );
	wait 0.5;
	level.player Kill();
		
}

*/