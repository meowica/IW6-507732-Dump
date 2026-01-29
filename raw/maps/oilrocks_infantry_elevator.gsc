#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\oilrocks_infantry_code;
#include maps\oilrocks_slamzoom;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;

start()
{
	spawn_apache_allies( "apache_elevator_ally_0" );
	infantry_teleport_start( "infantry_elevator_player_start" );
	apache_allies = get_apache_allies();
	array_thread( apache_allies, ::self_make_chopper_boss, undefined, true );
}

main()
{
	trigger_wait_targetname( "trigger_elevator" );
	
	delayThread( 0.4, ::autosave_now );
	
	elevator_zoom();
	
	elevator		   = GetEnt( "elevator_up_the_shaft", "targetname" );
	elevator_positions = getstructarray_delete( "elevator_positions", "targetname" );

	zOffset = measure_shaft( "shaft_measure" );
	
	foreach ( i, guy in level.infantry_guys )
		guy ForceTeleport( elevator_positions[ i ].origin + ( 0, 0, zOffset ), ( 0, 0, 0 ) );
	
	elevator.origin += ( 0, 0, zOffset );

	wait 0.5;
	camlanding_from_apache( "camelevatorback", 0.7, 0.32 );
	
	thread autosave_by_name();
	
}

measure_shaft( targetname )
{
	shaft_measure		 = getstruct_delete( targetname, "targetname" );
	shaft_measure_target = getstruct_delete( shaft_measure.target, "targetname" );
	return shaft_measure_target.origin[ 2 ] - shaft_measure.origin[ 2 ];
}

elevator_zoom()
{
	array_spawn_targetname( "top_elevator_enemies", true );
	flash_delay = 1.5; // measured zoom_into_apache, below at 1600 ms, flash just before vehicle path ends.
	delayThread( flash_delay, ::digitalFlash, 0.35 );
	zoom_into_apache( "camelevator", 0.8, 0.3, false );
	elevator_zpus = spawn_vehicles_from_targetname( "elevator_zpu" );
			  //   entities       process 						  
	array_thread( elevator_zpus, ::vehicle_zpu_think );
	array_thread( elevator_zpus, ::add_as_apache_target_on_spawn );
	waittill_dead( elevator_zpus );
}

zoom_into_apache( noteworthy, slomo_in, blend_to_tag_time, tail_flash )
{
	tail_flash = ter_op( IsDefined( tail_flash ), tail_flash, true );

	camlanding_from_apache( noteworthy, slomo_in, blend_to_tag_time, tail_flash );
	
	struct		  = SpawnStruct();
	struct.origin = level.player.origin;
	struct.angles = level.player.angles;
	
	apache_player = spawn_apache_player_at_struct( struct );
	apache_player maps\_chopperboss_utility::chopper_boss_locs_monitor_disable_turn_off();
	
	apache_player Vehicle_SetSpeedImmediate( 40, 35, 35 );
}

convert_structs_objects( elevator_positions )
{
	elevator_linked_orgs = [];
	foreach ( position in elevator_positions )
	{
		spawned_org		   = spawn_tag_origin();
		spawned_org.origin = position.origin;
		if ( IsDefined( position.angles ) )
			spawned_org.angles = position.angles;
		elevator_linked_orgs = array_add( elevator_linked_orgs, spawned_org );
	}
	return elevator_linked_orgs;
}

_precache()
{
	flag_init( "player_back_on_elevator" );
}
