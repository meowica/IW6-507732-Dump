#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\_hud_util;
#include maps\oilrocks_apache_vo;



start()
{
	// Setup Player Apache
	spawn_apache_player( "apache_chase" );
	
	// Spawn Friendlies
	spawn_blackhawk_ally( "struct_blackhawk_ally_chase" );
	spawn_apache_allies( "struct_apache_ally_chase_0" );
	thread main_start();
}

main_start()
{
	autosave_by_name();

	thread apache_mission_vo_think( ::apache_mission_vo_antiair );
	thread maps\oilrocks_apache_hints::apache_hints_chase();
	
	thread apache_chase_allies_apache();

	thread apache_chase_ally_blackhawk_think();
	thread apache_chase_enemies();
	
	if ( obj_exists( "apache_factory" ) )
		objective_complete( obj( "apache_factory" ) );
	
}

main()
{
}

objectives()
{
	objective = obj( "apache_anti_air" );
	//"Clear the anti-air targets."
	Objective_Add( objective, "current", &"OILROCKS_OBJ_APACHE_ANTIAIR" );
	Objective_Current( objective );
	anti_air_objective = GetEntArray( "anti_air_objective", "targetname" );
	vehicles = Vehicle_GetArray();
	finished_flag = "FLAG_apache_antiairfinished";
	for ( i = 0; i < anti_air_objective.size; i++ )
	{
		anti_air_objective[i] thread anti_air_objectiv_trigger( objective, i, vehicles, finished_flag );
	}
	flag_wait( finished_flag );
}

anti_air_objectiv_trigger( objective, index, vehicles, finished_flag )
{
	flag_count_increment( finished_flag );
	touching = [];
	points = [];
	foreach ( vehicle in vehicles )
	{
		if ( IsDefined( vehicle ) && IsPointInVolume( vehicle.origin, self ) )
		{
			touching[ touching.size ] = vehicle;
			points[ points.size ] = vehicle.origin;
		}
	}
	Objective_AdditionalPosition( objective, index, AveragePoint( points ) );
	waittill_dead( touching );
	Objective_AdditionalPosition( objective, index, ( 0, 0, 0 ) );
	flag_count_decrement( finished_flag );
}

apache_chase_allies_apache()
{
	apache_allies = get_apache_allies();
	array_thread( apache_allies, ::apache_chase_ally_apache_think );
}

apache_chase_ally_apache_think()
{
	id		   = get_apache_ally_id();
	path_start = getstruct( "apache_chase_ally_path_start_0" + id, "script_noteworthy" );
	
	self vehicle_paths( path_start );
	self self_make_chopper_boss( undefined, true );
}

apache_chase_enemies()
{
	enemy_veh_spawner_names = [ "apache_chase_gunboat", "apache_chase_gaz_road", "apache_chase_zpu", "apache_chase_additional_zpu", "apache_chase_gunboat_hvt" ];
		
	foreach ( name in enemy_veh_spawner_names )
	{
		vehicle_spawners_adjust_health_and_damage_targetname( name );
		array_spawn_function_targetname( name, ::add_as_apache_target_on_spawn );
		
		if ( name == "apache_chase_zpu" || name == "apache_chase_additional_zpu" )
		{
			array_spawn_function_targetname( name, ::vehicle_zpu_think );
		}
		else
		{
			array_spawn_function_targetname( name, ::apache_chase_enemies_turret_think_delay );
		}
		
		array_spawn_function_targetname( name, ::apache_chase_enemy_on_death );
	}
	
	// Prevent reliable command buffer overflow
	spawn_delay = 0.05;
	
	vehicles = [];
	
	foreach ( name in enemy_veh_spawner_names )
	{
		if ( name == "apache_chase_zpu" || name == "apache_chase_additional_zpu" )
		{
			vehicles = array_combine( vehicles, spawn_vehicles_from_targetname( name ) );
		}
		else
		{
			vehicles = array_combine( vehicles, spawn_vehicles_from_targetname_and_drive( name ) );
		}
		
		wait spawn_delay;
	}
	
	thread objectives();
	
	flag_wait_any( "FLAG_apache_chase_finished", "FLAG_apache_chase_caesar_close_to_island" );
	
	if ( !flag( "FLAG_apache_chase_finished" ) )
		flag_set( "FLAG_apache_chase_finished" );
	
	// Clean up remaining vehicles
	vehicles_to_clean_up			 = array_remove_undefined_dead_or_dying( vehicles );
	array_thread( vehicles_to_clean_up, ::ai_clean_up, false, true );
}

apache_chase_enemies_turret_think_delay()
{	
	// Give the Gunboats time to get clear of the docs
	if ( IsDefined( self.classname ) && IsSubStr( self.classname, "_gunboat" ) )
	{
		self endon( "death" );
		wait 3.0;
	}
	
	self vehicle_ai_turret_think( false, false, undefined, false );
}

// JC-ToDo: Should merge this and the factory on death functions into a generic func. Potentially use the array_spawn_func_on_death_flag_whatever() I'm using for V.O.
apache_chase_enemy_on_death()
{
	if ( !IsDefined( level.apache_chase_enemies ) )
	{
		level.apache_chase_enemies = 0;
	}
	
	level.apache_chase_enemies++;
	
	self waittill( "death" );
	
	// Count already reached if this is undefined
	if ( !IsDefined( level.apache_chase_enemies ) )
		return;
	
	// Check to see if all enemies have been cleared for this section
	level.apache_chase_enemies--;
	
	if ( level.apache_chase_enemies <= 1 )
	{
		flag_set( "FLAG_apache_chase_finished" );
		
		level.apache_chase_enemies = undefined;
	}
}

apache_chase_ally_blackhawk_think()
{
	wait 5.0;
	
	// Send blackhawk towards the main island
	blackhawk = get_blackhawk_ally();
	blackhawk thread vehicle_paths( getstruct( "path_blackhawk_chase", "script_noteworthy" ) );
}
