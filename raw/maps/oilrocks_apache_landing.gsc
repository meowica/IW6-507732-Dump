#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\oilrocks_slamzoom;
#include maps\_chopperboss_utility;

start()
{
	spawn_apache_allies( "apache_landing_ally_0" );
	apache_player = spawn_apache_player( "apache_landing" );
	spawn_blackhawk_ally( "apache_landing_blackhawk_ally", undefined, undefined, true );

	apache_player maps\_chopperboss_utility::chopper_boss_locs_monitor_disable_turn_off();

	apache_allies = get_apache_allies();
	array_thread( apache_allies, ::self_make_chopper_boss, undefined, true );
}

main()
{
	chopper_boss_set_hangout_volume( GetEnt( "hangout_volume_landingzone", "targetname" ) );
	apache_allies = get_apache_allies();
	array_thread( apache_allies, ::chopper_boss_goto_hangout );

	blackhawk_idle_next_to_factory();

	objective_player_clears_landing();
	
	blackhawk_landing();
}

blackhawk_idle_next_to_factory()
{
	blackhawk	= get_blackhawk_ally();
	Assert( IsDefined( blackhawk ) );
	struct		   = getstruct( "apache_landing_blackhawk_ally", "targetname" );
	blackhawk thread vehicle_paths( struct );
}

_precache()
{
	flag_init( "landing_finished" );
}

objective_player_clears_landing()
{
	objective = obj( "apache_landing_killingeverythings" );
	//"Clear the landing"
	Objective_Add( objective, "active", &"OILROCKS_OBJ_CLEAR_THE_LANDING" );
	Objective_Current( objective );
	Objective_Position( objective, getstruct( "objective_pos_kill_everything", "targetname" ).origin );

	struct_encounter = getstruct( "landing_encounter", "targetname" );
	ai_remaining	 = escort_encounter_think( struct_encounter );
	objective_complete( objective );
}

blackhawk_landing()
{
	blackhawk	= get_blackhawk_ally();
	blackhawk notify( "stop_kicking_up_dust" );
	blackhawk thread maps\_vehicle_code::aircraft_wash_thread();
	
	triggerLanding = GetEnt( "trigger_landing_zone", "targetname" );
	blackhawk SetTargetYaw( triggerLanding.angles[ 1 ] );
	neworg = groundpos( triggerLanding.origin + ( 0, 0, 200 ) ) + ( 0, 0, blackhawk.fastropeoffset );
	blackhawk SetVehGoalPos( neworg, 1 );
	blackhawk Vehicle_SetSpeed( 70, 33, 33 );
	blackhawk SetHoverParams( 0, 0, 55 );
	blackhawk waittill ( "goal" );
	blackhawk thread vehicle_unload();
	
	
	wait 7.0;
	
	landing_kill_enemies = GetEnt( "landing_kill_enemies", "targetname" );
	enemies				 = GetAIArray( "axis" );
	foreach ( enemy in enemies )
		if ( enemy IsTouching( landing_kill_enemies ) )
			enemy Kill();
	
	camlanding_from_apache( "camlanding" );
//	spline_cam( "CamLanding", 1150 );
	level.HeroGuy Delete();
	level.HeroGuy		= undefined;
	level.infantry_guys = array_remove_undefined_dead_or_dying( level.infantry_guys );
}