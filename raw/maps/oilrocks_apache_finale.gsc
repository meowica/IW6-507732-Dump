#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\_hud_util;
#include maps\oilrocks_apache_vo;
#include maps\_chopperboss_utility;

start()
{
	spawn_apache_player( "apache_finale" );
	spawn_apache_allies( "struct_apache_ally_finale_0" );
	spawn_blackhawk_ally( "blackhawk_ally_finale", undefined, undefined, false );
}

main()
{
	blackhawk_ally =	get_blackhawk_ally();
	blackhawk_ally ent_flag_init( "blackhawk_reached_end" );
	spawn_infantry_in_blackhawk();
	
	apache_allies = get_apache_allies();
	array_thread( apache_allies, ::self_make_chopper_boss, undefined, true );

	thread apache_mission_vo_think( ::apache_mission_vo_finale );
	thread apache_player_adjust();
	thread blackhawk_path_to_end();
	
	objective = objective_protect_start();
	
	enemies_vehicle();
	//enemies_infantry();

	blackhawk_ally add_wait( ::ent_flag_wait, "blackhawk_reached_end" );
	add_wait( ::flag_wait, "player_near_ending" );
	do_wait_any();
	objective_complete( objective );
	chopper_boss_set_hangout_volume( GetEnt( "hangout_volume_landingzone", "targetname" ) );
}

objective_protect_start()
{
	objective = obj( "protect_the_blackhawk" );
	//"Protect the blackhawk"
	Objective_Add( objective, "active", &"OILROCKS_OBJ_PROTECT_THE_BLACKHAWK" );
	Objective_Current( objective );
	Objective_OnEntity( objective, get_blackhawk_ally() );
	return objective;
}

blackhawk_path_to_end()
{
	blackhawk = get_blackhawk_ally();
	Assert( IsDefined( blackhawk ) );
	blackhawk vehicle_paths( getstruct( "blackhawk_to_end", "targetname" ) );
}

apache_player_adjust()
{
	apache_player = get_apache_player();
	
	if ( GetDvarFloat( "vehHelicopterPitchOffset" ) != apache_player.heli.pitch_offset_ground )
	{
		// Adjust the player's chopper pitch over time for the air battle
		thread lerp_savedDvar( "vehHelicopterPitchOffset", apache_player.heli.pitch_offset_ground, 15.0 );
	}
	
	if ( IsDefined( apache_player.alt_override ) )
	{
		// Adjust the player's min altitude over time for the ground battles
		apache_player thread vehicle_scripts\_apache_player::altitude_min_override_remove( 20.0 );
	}
}

enemies_infantry()
{
	struct_encounter = getstruct( "apache_finale_escort_struct_first", "targetname" );
	ai_remaining	 = escort_encounter_think( struct_encounter );
	delayThread( 6, ::clean_enemies_infantry, ai_remaining );
}

clean_enemies_infantry( ai_remaining )
{
	ai_remaining = array_remove_undefined_dead_or_dying( ai_remaining );
	array_thread( ai_remaining, ::ai_clean_up );
}

enemies_vehicle()
{
	// All Used Vehicle Spawners
	enemy_veh_spawner_names = [ "apache_finale_gaz",  "apache_finale_gaz_loop_CW", "apache_finale_gaz_loop_CCW" ];
	
	foreach ( name in enemy_veh_spawner_names )
	{
		vehicle_spawners_adjust_health_and_damage_targetname( name );
		array_spawn_function_targetname( name, ::add_as_apache_target_on_spawn );
		array_spawn_function_targetname( name, ::vehicle_ai_turret_think, false, false, undefined, false );
		array_spawn_function_targetname( name, ::enemy_vehicle_wave_on_spawn );
	}
	
	
	spawn_delay = 0.05;
	
	// Spawn Wave One
	enemy_veh_spawner_names_wave = [ "apache_finale_gaz", "apache_finale_gaz_loop_CW", "apache_finale_gaz_loop_CCW" ];
	foreach ( name in enemy_veh_spawner_names_wave )
	{
		spawn_vehicles_from_targetname_and_drive( name );
		wait spawn_delay;
	}
	
	enemy_waittill_count( "apache_finale_enemy_vehicle", 2 );
	
	flag_set( "FLAG_apache_finale_enemy_vehicle_wave_done_01" );
	
	// Spawn Wave Two
	enemy_veh_spawner_names_wave = [ "apache_finale_gaz", "apache_finale_gaz_loop_CW", "apache_finale_gaz_loop_CCW" ];
	foreach ( name in enemy_veh_spawner_names_wave )
	{
		spawn_vehicles_from_targetname_and_drive( name );
		wait spawn_delay;
	}
	
	enemy_waittill_count( "apache_finale_enemy_vehicle", 2 );
	
}

enemy_vehicle_wave_on_spawn()
{
	self.targetname = "apache_finale_enemy_vehicle";
}

enemy_waittill_count( name, count )
{
	veh_alive = GetEntArray( name, "targetname" );
	veh_alive = array_remove_undefined_dead_or_dying( veh_alive );
	AssertEx( IsDefined( veh_alive.size ) && veh_alive.size, "apache_finale_enemy_waittill_count() called using targetname that has no living entities." );
	
	while ( veh_alive.size > count )
	{
		wait 0.05;
		
		veh_alive = GetEntArray( "apache_finale_enemy_vehicle", "targetname" );
		veh_alive = array_remove_undefined_dead_or_dying( veh_alive );
	}
}

ally_infantry_on_spawn()
{
	self friendly_setup();
	self friendly_setup_apache_section(	 );
	self ThermalDrawDisable();
}