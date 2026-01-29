#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

crash_site_init()
{
    level.start_point = "crash_site";
    
    kill_spawners_per_checkpoint( "crash_site" );
}

crash_site_main()
{
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "crash_site_" );
		
		// setup allies
		spawn_heroes_checkpoint( "crash_site_" );

		array_thread( level.allytanks, ::npc_tank_combat_init );
	}
	
	level.herotanks[ 0 ] thread tank_relative_speed( "base_array_relative_speed", "crash_site_end", 200, 15	 , 2 );
	level.herotanks[ 1 ] thread tank_relative_speed( "base_array_relative_speed", "crash_site_end", 250, 13.5, 1.5 );
	
	thread crash_site_begin();
	
	flag_wait( "crash_site_end" );
	
	maps\_spawner::killspawner( 20 );
    kill_vehicle_spawners_now( 20 );
    crash_site_cleanup();
}

crash_site_begin()
{
	thread intro_and_crash_site_ally_setup();
	thread crash_site_enemies_setup();
	thread crash_site_mig29_destroys_ally_tanks();
	thread crash_site_a10_overhead();
	thread crash_site_vo();
	thread a10_and_mig_scene();
	thread maps\satfarm_base_array::base_array_ambient_dogfight_1();
    thread maps\satfarm_base_array::base_array_ambient_dogfight_2();
    thread maps\satfarm_base_array::base_array_ambient_dogfight_3();
	//"Rendesvouz with Bravo Team."
	Objective_Add( obj( "rendesvouz" ), "current", &"SATFARM_OBJ_RENDESVOUZ" );
	autosave_by_name( "crash_site" );
}

intro_and_crash_site_ally_setup()
{
	if( !IsDefined( level.intro_and_crash_site_ally_tanks ) )
	{
		if( level.start_point == "intro" )
		{
			level.intro_and_crash_site_ally_tanks = spawn_vehicles_from_targetname_and_drive( "intro_allies" );
		}

		else if( level.start_point == "crash_site" )
		{
			level.intro_and_crash_site_ally_tanks = spawn_vehicles_from_targetname_and_drive( "crash_site_allies" );
		}
		
		level.allytanks = array_combine( level.allytanks, level.intro_and_crash_site_ally_tanks );
		array_thread( level.intro_and_crash_site_ally_tanks, ::npc_tank_combat_init );
		
		foreach( ally in level.intro_and_crash_site_ally_tanks )
		{
			if( IsDefined( ally.script_noteworthy ) && ( ( ally.script_noteworthy == "intro_ally0" ) || ( ally.script_noteworthy == "crash_site_ally0" ) ) )
			{
				ally thread tank_relative_speed( "base_array_relative_speed", undefined, 200, 15, 2 );
				ally thread delayed_kill( RandomFloatRange( 0.1, 2.0 ), "sat_array_enemies_retreat_01" );
			}
			else if( IsDefined( ally.script_noteworthy ) && ( ( ally.script_noteworthy == "intro_ally1" ) || ( ally.script_noteworthy == "crash_site_ally1" ) ) )
			{
				ally thread tank_relative_speed( "base_array_relative_speed", undefined, 1200, 10, 3 );
				ally thread delayed_kill( RandomFloatRange( 0.1, 2.0 ), "sat_array_enemies_retreat_01" );
			}
			else if( IsDefined( ally.script_noteworthy ) && ( ( ally.script_noteworthy == "intro_ally2" ) || ( ally.script_noteworthy == "crash_site_ally2" ) ) )
			{
				ally thread tank_relative_speed( "base_array_relative_speed", undefined, 950, 12, 1.5 );
				ally thread delayed_kill( RandomFloatRange( 0.1, 1.5 ), "base_array_ridge_reached" );
			}
		}
	}
	else if( level.start_point == "intro" )
	{
		thread switch_node_on_flag( level.intro_and_crash_site_ally_tanks[ 0 ], "", "switch_crash_site_path_ally0", "crash_site_path_ally0" );
		thread switch_node_on_flag( level.intro_and_crash_site_ally_tanks[ 1 ], "", "switch_crash_site_path_ally1", "crash_site_path_ally1" );
		thread switch_node_on_flag( level.intro_and_crash_site_ally_tanks[ 2 ], "", "switch_crash_site_path_ally2", "crash_site_path_ally2" );
	}
}

crash_site_enemies_setup()
{
	flag_wait( "spawn_crash_site_initial_enemies" );
	
	//Badger: Enemy armor ahead!
	thread radio_dialog_add_and_go( "satfarm_bgr_enemyarmorahead" );
	
	enemytanks = spawn_vehicles_from_targetname_and_drive( "crash_site_enemies" );
	
	foreach ( enemytank in enemytanks )
	{
		enemytank.compass_flash = true;
	}
	
	level.enemytanks = array_combine( level.enemytanks, enemytanks );
	array_thread( enemytanks, ::npc_tank_combat_init );
	
	thread crash_site_enemies_death_watcher( enemytanks );
	
	flag_wait_either( "retreat_crash_site_enemies", "enough_crash_site_enemies_dead" );
	
	//flag_set( "crash_site_allies_advance_to_ridge" );
	
	foreach( enemy in enemytanks )
	{
		if( IsDefined( enemy ) && enemy.classname != "script_vehicle_corpse" )
		{
			
			if( enemy.script_noteworthy == "crash_site_enemy_01" )
			{
				enemy.veh_transmission = "reverse";
				enemy.script_transmission  = "reverse";
				switch_node_now( enemy, GetVehicleNode( "crash_site_enemy_retreat_node_01", "targetname" ) );
				
				enemy thread delayed_kill( RandomFloatRange( 4.0, 6.0 ) );
			}
			
			else if( enemy.script_noteworthy == "crash_site_enemy_02" )
			{
				enemy.veh_transmission = "reverse";
				enemy.script_transmission  = "reverse";
				switch_node_now( enemy, GetVehicleNode( "crash_site_enemy_retreat_node_02", "targetname" ) );
				
				enemy thread delayed_kill( RandomFloatRange( 3.0, 6.0 ) );
			}
			
			else if( enemy.script_noteworthy == "crash_site_enemy_03" )
			{
				enemy.veh_transmission = "reverse";
				enemy.script_transmission  = "reverse";
				switch_node_now( enemy, GetVehicleNode( "crash_site_enemy_retreat_node_03", "targetname" ) );
				
				enemy thread delayed_kill( RandomFloatRange( 2.0, 5.0 ) );
			}
			
			else if( enemy.script_noteworthy == "crash_site_enemy_04" )
			{
				enemy thread delayed_kill( RandomFloatRange( 0.1, 1.5 ) );
			}
			
			else if( enemy.script_noteworthy == "crash_site_enemy_05" )
			{
				enemy thread delayed_kill( RandomFloatRange( 0.1, 1.5 ) );
			}
		}
	}
}

a10_and_mig_scene()
{
	flag_wait( "spawn_crash_site_background_enemies" );
	
	level.crash_site_background_enemies = spawn_vehicles_from_targetname_and_drive( "crash_site_background_enemies" );
	
	level.enemytanks = array_combine( level.enemytanks, level.crash_site_background_enemies );
	array_thread( level.crash_site_background_enemies, ::npc_tank_combat_init );
	
	level.crash_site_a10_missile_dive_1 = spawn_vehicle_from_targetname_and_drive( "crash_site_a10_missile_dive_1" );
	
	wait( 1.75 );
	
	mig = spawn_vehicle_from_targetname_and_drive( "crash_site_mig29_gun_dive_2" );
	mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
}

crash_site_enemies_death_watcher( array_of_tanks )
{
	waittilltanksdead( array_of_tanks, 3 );
	
	flag_set( "enough_crash_site_enemies_dead" );
}

crash_site_mig29_destroys_ally_tanks()
{
	flag_wait( "start_crash_site_mig29_gun_dive_1" );
	
	spawn_vehicle_from_targetname_and_drive( "crash_site_mig29_gun_dive_1" );
}

crash_site_a10_overhead()
{
	level.crash_site_a10_gun_dive_1 = spawn_vehicle_from_targetname_and_drive( "crash_site_a10_gun_dive_1" );
	
	wait( 0.5 );
	
	mig = spawn_vehicle_from_targetname_and_drive( "crash_site_mig29_gun_dive_3" );
	mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
}

crash_site_vo()
{
	//Badger: We missed the drop zone, Overlord. Awaiting orders.
	radio_dialog_add_and_go( "satfarm_bgr_wemissedthedrop" );
	
	//Overlord: Proceed to the ridge and rendezvous with B-Company.
	radio_dialog_add_and_go( "satfarm_hqr_proceedtotheridge" );
	
	//Bravo: We are under heavy fire, Overlord.
	radio_dialog_add_and_go( "satfarm_brv_weareunderheavy" );
	
	//Overlord: Hold tight, Bravo, Badger group is moving in.
	radio_dialog_add_and_go( "satfarm_hqr_holdtightbravobadger" );
	
	thread maps\satfarm_base_array::base_array_ridge_obj_marker();
	
	//Overlord: Badger One, Bravo’s position is on your readout.
	radio_dialog_add_and_go( "satfarm_hqr_badgeronebravosposition" );
	
	//Badger: Copy, Overlord.
	radio_dialog_add_and_go( "satfarm_bgr_copyoverlord" );
	
	//Badger: We need to push through to Bravo team!
	radio_dialog_add_and_go( "satfarm_bgr_weneedtopush" );
}

crash_site_cleanup()
{
	//wait( 1.0 );
	ents = GetEntArray( "crash_site_ent", "script_noteworthy" );
	array_delete( ents );
}