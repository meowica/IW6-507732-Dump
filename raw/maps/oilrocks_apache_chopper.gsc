#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\oilrocks_apache_vo;

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Apache Fight Enemy Chopper
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

start()
{
	spawn_apache_player( "apache_chopper" );
	spawn_apache_allies( "struct_apache_ally_chopper_0" );
	spawn_blackhawk_ally( "blackhawk_ally_finale" );
	// Make apache allies chopper bosses
	apache_allies = get_apache_allies();
	array_thread( apache_allies, ::self_make_chopper_boss, undefined, true );
}


main()
{
	thread apache_mission_vo_think( ::apache_mission_vo_chopper );

	thread maps\oilrocks_apache_hints::apache_hints_chopper();

	blackhawk_hides_away();
		
	autosave_by_name();

	
	apache_player = get_apache_player();
	
	// Disable chopper locations around the player
	apache_player thread maps\_chopperboss_utility::chopper_boss_locs_monitor_disable( 2048 );
	// Adjust the player's chopper pitch over time for the air battle
	thread lerp_savedDvar( "vehHelicopterPitchOffset", apache_player.heli.pitch_offset_air, 15.0 );
	
	// Adjust the player's min altitude over time for the air battle
	apache_player thread vehicle_scripts\_apache_player::altitude_min_override( 2000, 15.0 );

	thread apache_chopper_enemies();
	thread objectives();
	
	flag_wait ( "FLAG_apache_chopper_finished" );
}

blackhawk_hides_away()
{
	blackhawk = get_blackhawk_ally();
	struct	  = getstruct( "blackhawk_ally_finale", "targetname" );
	blackhawk thread vehicle_paths( struct );
}

objectives()
{
	if ( obj_exists( "apache_escort" ) )
		objective_complete( obj( "apache_escort" ) );
	
	Objective_Add( obj( "apache_chopper" ), "active", &"OILROCKS_OBJ_APACHE_CHOPPER" );
	Objective_Current( obj( "apache_chopper" ) );
}

apache_chopper_enemies()
{
	start_structs = getstructarray( "apache_chopper_enemy_hind_path_start", "targetname" );
	AssertEx( start_structs.size == 3, "There should be 3 start points for these enemy hinds to come in on." );
	
	level.apache_chopper_hinds = [];
	
	foreach ( struct in start_structs )
	{
		apache_chopper_hind_spawn( struct );
	}
	
	while ( level.apache_chopper_hinds.size > 1 )
	{
		level waittill_any_timeout( 1.0, "apache_chopper_hind_died" );
	}
	
	flag_set( "FLAG_apache_chopper_hind_destroyed_two" );
	
	
	start_structs = getstructarray( "apache_chopper_enemy_hind_path_start_part_2", "targetname" );
	AssertEx( start_structs.size == 3, "There should be 3 start points for these enemy hinds to come in on." );
	
	foreach ( struct in start_structs )
	{
		apache_chopper_hind_spawn( struct );
	}
	
	while ( level.apache_chopper_hinds.size > 0 )
	{
		level waittill_any_timeout( 1.0, "apache_chopper_hind_died" );
		
		if ( level.apache_chopper_hinds.size <= 3 && !flag( "FLAG_apache_chopper_hind_remaining_three" ) )
			flag_set( "FLAG_apache_chopper_hind_remaining_three" );
		
		if ( level.apache_chopper_hinds.size <= 1 && !flag( "FLAG_apache_chopper_hind_remaining_one" ) )
			flag_set( "FLAG_apache_chopper_hind_remaining_one" );
	}
	
	level.apache_chopper_hinds = undefined;
	
	// Make sure dialogue about the battle is done before starting the garage sequence
	flag_wait( "FLAG_apache_chopper_vo_done" );
	flag_set( "FLAG_apache_chopper_finished" );
}

apache_chopper_hind_spawn( struct_start )
{
	hind = spawn_hind_enemy( struct_start );
	hind thread choper_fly_in_think( struct_start );
	hind thread apache_chopper_hind_on_death();
	
	return hind;
}

apache_chopper_hind_on_death()
{
	AssertEx( IsDefined( level.apache_chopper_hinds ) && IsArray( level.apache_chopper_hinds ), "level.apache_chopper_hinds array not defined." );
	
	level.apache_chopper_hinds[ level.apache_chopper_hinds.size ] = self;
	
	self waittill( "death" );
	
	level.apache_chopper_hinds = array_removeUndefined( level.apache_chopper_hinds );
	
	// Because vehicles are defined on the frame that they get their death notification
	// remove them manual here
	level.apache_chopper_hinds = array_remove( level.apache_chopper_hinds, self );
	
	level notify( "apache_chopper_hind_died" );
}


