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
}

main()
{
	autosave_by_name();

	thread apache_mission_vo_think( ::apache_mission_vo_chase );
	thread maps\oilrocks_apache_hints::apache_hints_chase();
	
	thread apache_chase_allies_apache();
	thread apache_chase_ally_blackhawk_think();
	thread apache_chase_enemies();
	thread objectives();
}

objectives()
{
	if ( obj_exists( "apache_factory" ) )
		objective_complete( obj( "apache_factory" ) );
	
	while ( !IsDefined( level.apache_chase_boat ) )
		wait 0.05;
	
	//"Keep eyes on the HVT"
	Objective_Add( obj( "apache_chase" ), "active", &"OILROCKS_OBJ_APACHE_CHASE" );
	Objective_Current( obj( "apache_chase" ) );
	
	obj_ent = get_obj_ent_hvt();
	obj_ent LinkTo( level.apache_chase_boat, "tag_origin", (0,0,0), (0,0,0) );
	Objective_OnEntity( obj( "apache_chase" ), obj_ent );

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
	// HVT boat
	array_spawn_function_targetname( "apache_chase_gunboat_hvt", ::apache_chase_boat_on_spawn );
	
	enemy_veh_spawner_names = [ "apache_chase_gunboat", "apache_chase_gaz_road", "apache_chase_zpu" ];
	
	foreach ( name in enemy_veh_spawner_names )
	{
		vehicle_spawners_adjust_health_and_damage_targetname( name );
		array_spawn_function_targetname( name, ::add_as_apache_target_on_spawn );
		
		if ( name == "apache_chase_zpu" )
		{
			array_spawn_function_targetname( name, ::vehicle_zpu_think );
		}
		else
		{
			array_spawn_function_targetname( name, ::apache_chase_enemies_turret_think_delay );
		}
		
		array_spawn_function_targetname( name, ::apache_chase_enemy_on_death );
	}
	
	//"We Need Caesar Alive"
	array_spawn_function_targetname( "apache_chase_gunboat_hvt", ::on_death_mission_fail, "FLAG_apache_chase_caesar_arrived_to_island", &"OILROCKS_QUOTE_CAESAR_KILLED" );
	enemy_veh_spawner_names[ enemy_veh_spawner_names.size ] = "apache_chase_gunboat_hvt";
	
	// Prevent reliable command buffer overflow
	spawn_delay = 0.05;
	
	vehicles = [];
	
	foreach ( name in enemy_veh_spawner_names )
	{
		if ( name == "apache_chase_zpu" )
		{
			vehicles = array_combine( vehicles, spawn_vehicles_from_targetname( name ) );
		}
		else
		{
			vehicles = array_combine( vehicles, spawn_vehicles_from_targetname_and_drive( name ) );
		}
		
		wait spawn_delay;
	}
	
	flag_wait_any( "FLAG_apache_chase_finished", "FLAG_apache_chase_caesar_close_to_island" );
	
	if ( !flag( "FLAG_apache_chase_finished" ) )
		flag_set( "FLAG_apache_chase_finished" );
	
	// Clean up remaining vehicles
	vehicles_to_clean_up = [];
	vehicles			 = array_remove_undefined_dead_or_dying( vehicles );
	
	// Don't clean up Caesar
	foreach ( veh in vehicles )
	{
		if ( IsDefined( veh.script_noteworthy ) && veh.script_noteworthy == "apache_chase_gunboat_hvt" )
			continue;
		
		vehicles_to_clean_up[ vehicles_to_clean_up.size ] = veh;
	}
	
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

apache_chase_boat_on_spawn()
{
	level.apache_chase_boat = self;
}

apache_chase_ally_blackhawk_think()
{
	wait 5.0;
	
	// Send blackhawk towards the main island
	blackhawk = get_blackhawk_ally();
	blackhawk thread vehicle_paths( getstruct( "path_blackhawk_chase", "script_noteworthy" ) );
}
