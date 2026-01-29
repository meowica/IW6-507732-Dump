#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;
#include maps\homecoming_util;

main()
{
	precacheStuff();
	template_level( "homecoming" );
	
	maps\createart\homecoming_art::main();
	maps\homecoming_fx::main();
	
	set_default_start( "street" );					    
	add_start( "street"	, ::start_street_sequence, "street", maps\homecoming_intro::intro_sequence_street );
	add_start( "bunker"	, ::start_bunker_sequence, "bunker", maps\homecoming_beach::beach_sequence_bunker_new );
	//add_start( "ambient", ::start_beach_ambient, "beach ambient" );
	//add_start( "artillery", ::start_bunker_artillery_sequence, "artillery", maps\homecoming_beach::bunker_beach_artillery_sequence );
	//add_start( "bunker2"	, ::start_bunker_wave2_sequence, "bunker wave2", maps\homecoming_beach::bunker_beach_defend_wave2_sequence );
	add_start( "trench", ::start_trenches_sequence, "trenches", maps\homecoming_beach::beach_sequence_trenches );
	add_start( "trench2", ::start_trenches2_sequence, "trenches2", maps\homecoming_beach::beach_trenches_combat_part2 );
	add_start( "tower_retreat", ::start_tower_retreat, "tower retreat", maps\homecoming_retreat::tower_retreat_sequence );
	add_start( "elias_street", ::start_elias_street, "elias street", maps\homecoming_retreat::elias_street_sequence );
	add_start( "elias_house", ::start_elias_house, "elias house", maps\homecoming_retreat::elias_house_sequence );
	//add_start( "tower", ::start_tower_sequence, "tower", maps\homecoming_beach::tower_sequence );
	//add_start( "a10", ::start_a10_test,"a10", maps\homecoming_a10::a10_strafe_mechanic );
	//add_start( "preacher", maps\homecoming_beach::preacher_test, "preacher" );
	
	//intro_screen_create( &"HOMECOMING_INTROSCREEN_LINE_1", &"HOMECOMING_INTROSCREEN_LINE_5", &"HOMECOMING_INTROSCREEN_LINE_2" );
	
	add_hint_string( "hint_bullets", &"HOMECOMING_HINT_BULLETS_DONTHURT_VEHICLE" );
	add_hint_string( "hint_a10", &"HOMECOMING_HINT_USE_A10_MECHANIC", maps\homecoming_a10::a10_hint_func );
				    
	init_level_flags();
	
	maps\homecoming_precache::main();
	maps\_load::main();
	maps\homecoming_audio::main();
	maps\homecoming_anim::main();
	
	maps\homecoming_a10::init_a10();
	maps\_drone_ai::init();
	maps\_javelin::init();
	maps\_stinger::init();
	
	level.free_flight = false;
	//thread maps\a10_proto_code::main();
	
	// lookahead value - how far the drone will lookahead for movement direction
	// larger number makes smother, more linear travel. small value makes character go almost exactly point to point
	level.drone_lookAhead_value = 75; // default = 200
	
	global_spawn_functions();
	init_MainAI();
	init_LevelVariables();
	
	SetSavedDvar( "ai_friendlysuppression", 0 );
	SetSavedDvar( "ai_friendlyfireblockduration", 0 );
	SetDvarIfUninitialized( "daniel", 0 );
	
	level.mortarExcluders = [];
	level.noMaxMortarDist = true;
	level.mortarEarthquakeRadius = 3000;
	level.mortarWithinFOV = cos( 25 );
	setDvarIfUninitialized( "bog_camerashake", "1" );
	maps\_mortar::bog_style_mortar();
	
	flag_set( "load_setup_complete" );
	
	/#
	// DEBUG
	thread debug_ai_drone_amounts();
	#/
		
}

precacheStuff()
{
	precacheModel( "projectile_slamraam_missile" );
	precacheModel( "weapon_javelin" );
	precacheModel( "vehicle_t90_tank_woodland" );
	PreCacheModel( "angel_flare_rig" );
	PreCacheModel( "mw_test_soldier" );
	
	PreCacheItem( "slamraam_missile_guided_fast" );
	PrecacheItem( "hovercraft_missile_guided" );
	PreCacheItem( "javelin" );
	PrecacheItem( "javelin_dcburn" );
	PrecacheItem( "javelin_no_explode" );
	PrecacheItem( "rpg" );
	PrecacheItem( "sc2010" );
	PrecacheItem( "honeybadger" );
	PrecacheItem( "missile_attackheli" );
	PrecacheItem( "missile_attackheli_dcburn" );
	
	PreCacheShellShock( "homecoming_bunker" );
}

init_level_flags()
{
	flag_init( "load_setup_complete" );
	
	// Intro3
	flag_init( "FLAG_bunker_turrets_setup" );
	flag_init( "FLAG_start_bunker_turret_fire" );
	flag_init( "intro_osprey_fly_away" );
	// flag_init( "TRIGFLAG_stop_skybridge_drones" );
	// flag_init( "TRIGFLAG_stryker_goto_final_position" );
	flag_init( "FLAG_turn_off_abrams_player_check" );
	
	// Beach
	flag_init( "FLAG_intro_hesh_start" );
	flag_init( "FLAG_start_bunker" );
	flag_init( "FLAG_stop_trench_drones" );
	flag_init( "NODEFLAG_first_hovercraft_arrived" );
	flag_init( "NODEFLAG_wave1_final_hovercraft_goal" );
	flag_init( "FLAG_start_artillery_sequence" );
	flag_init( "artillery_humvee_blowup" );
	flag_init( "artillery_shack_blowup" );
	flag_init( "artillery_mg_blowup" );
	flag_init( "artillery_roof_blowup" );
	flag_init( "FLAG_artillery_sequence_done" );
	
	// Trenches
	flag_init( "FLAG_start_trenches" );
	flag_init( "FLAG_tower_hind_destroyed" );
	
	// Tower
	flag_init( "FLAG_start_tower_sequence" );
	flag_init( "FLAG_hesh_move_through_tower" );
	flag_init( "FLAG_start_tower_retreat" );
	flag_init( "FLAG_player_leaving_tower" );
	
	// Elias Street
	flag_init( "FLAG_start_elias_street" );
	flag_init( "FLAG_stop_elias_street_ambient_retreaters" );
	flag_init( "FLAG_elias_street_ground_enemies" );
	
	// Elias House
	flag_init( "FLAG_start_elias_house" );
}

init_LevelVariables()
{
	level.aiArray = [];
	level.lastBulletHint = 0;
	level.drone_death_handler = maps\homecoming_drones::drone_death_handler;
	level.javelinTargets = [];
	level.deletableDrones = [];
	level.bunker_beach_ai = [];
	level.bunker_beach_vehicles = [];
	level.beachFrontGuys  = []; 	
	level.hovercrafts = [];
	level.hovercraftDrones = [];
}

global_spawn_functions()
{
	spawners = getspawnerarray();
	foreach( spawner in spawners )
		spawner thread add_spawn_function( ::set_all_ai_targetnames, spawner );
	
	// ai
	array_spawn_function_noteworthy( "magic_bullet_shield", ::magic_bullet_shield );
	array_spawn_function_noteworthy( "delete_on_goal", ::waittill_goal, 56, true );
	array_spawn_function_noteworthy( "set_ai_array", ::set_ai_array );
	array_spawn_function_noteworthy( "default_mg_guy", ::default_mg_guy );
	array_spawn_function_noteworthy( "wounded_carry_guy", ::wounded_carry_guy );
	//array_spawn_function_noteworthy( "fake_shooter", ::fake_shooter_think );
	
	// vehicles
	array_spawn_function_noteworthy( "vehicle_path_notifications", ::vehicle_path_notifications );
	array_spawn_function_noteworthy( "vehicle_allow_player_death", ::vehicle_allow_player_death );
	
	thread maps\homecoming_beach::trench_artemis();
	
	maps\homecoming_intro::intro_spawn_functions();
	maps\homecoming_beach::beach_spawn_functions();
	maps\homecoming_retreat::retreat_spawn_functions();
	maps\homecoming_drones::drones_request_init();
	
	array_thread( getentarray( "hide_on_load", "script_noteworthy" ), ::hide_entity );
	array_thread( getentarray( "trigger_off", "script_noteworthy" ), ::trigger_off );
	array_thread( getentarray( "smoke_trigger", "script_noteworthy" ), ::smoke_trigger );
	array_thread( getentarray( "smoke_stop_trigger", "script_noteworthy" ), ::smoke_stop_trigger );
	array_thread( getentarray( "move_up_watcher", "targetname" ), ::move_up_when_clear );
}

// STARTS
start_street_sequence()
{
	fadein = create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_osprey" );
	level.player setstance( "crouch" );
	fadein thread fade_over_time( 0, 1 );
}

start_bunker_sequence()
{	
	fadein = create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_bunker" );
	flag_set( "FLAG_start_bunker" );
	//thread maps\homecoming_beach::beach_flyover_helis();
	level.heroes move_to_goal( "movespot_bunker" );
	// waitframe for level.bunker_beach_ai to become defined
	getent( "start_beach_ai", "targetname" ) notify_delay( "trigger", .05 );
	fadein thread fade_over_time( 0, 1 );
}

start_bunker_artillery_sequence()
{
	fadein = create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_inside_bunker" );
	flag_set( "FLAG_start_artillery_sequence" );
	level.heroes move_to_goal( "movespot_bunker" );	
	
	disable_trigger_with_targetname( "player_top_bunker_trig" );
	disable_trigger_with_targetname( "player_inside_bunker" );
	
	fadein thread fade_over_time( 0, 1 );
}

start_bunker_wave2_sequence()
{
	fadein = create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_inside_bunker" );
	flag_set( "FLAG_start_artillery_sequence" );
	level.heroes move_to_goal( "movespot_bunker" );	
	
	//thread maps\homecoming_beach::beach_bunker_drones();
	
	flag_set( "FLAG_artillery_sequence_done" );
	
	turret = getent( "bunker_turret", "targetname" );
	nonBroken = getent( "bunker_mg_nonbroken", "targetname" );
	broken = getent( "bunker_mg_broken", "targetname" );
	
	nonBroken delete();
	broken show();
	turret notify( "stop_using_built_in_burst_fire" );
	turret notify( "stopfiring" );
	turret delete();
	
	nonBroken = getent( "bunker_roof_nonbroken", "targetname" );
	broken = getent( "bunker_roof_broken", "targetname" );
	
	broken show();
	nonBroken delete();
	
	disable_trigger_with_targetname( "player_top_bunker_trig" );
	disable_trigger_with_targetname( "player_inside_bunker" );
	
	fadein thread fade_over_time( 0, 1 );
}

start_beach_ambient()
{
	alliesTeletoStartSpot( "start_inside_bunker" );
	thread maps\homecoming_beach_ambient::init_beach_ambient();
}

start_trenches_sequence()
{
	fadein = create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_trenches" );
	fadein thread fade_over_time( 0, 1 );	
	
	//thread maps\homecoming_beach::beach_flyover_helis();
	
	maps\homecoming_beach_ambient::init_beach_ambient();
	
	activate_trigger( "start_beach_ai", "targetname" );
	activate_trigger( "start_balcony_ai", "targetname" );
	
	flag_set( "FLAG_start_trenches" );
}

start_trenches2_sequence()
{
	fadein = create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_trenches_part2" );

	level.hesh set_force_color( "r" );
	level.dog set_force_color( "b" );
	
	activate_trigger( "trenches_moveup_trig4", "targetname" );
	
	droneClip = getent( "bunker_trench_drone_clip", "targetname" );
	droneClip connectPaths();
	droneClip delete();
	
	fadein thread fade_over_time( 0, 1 );	
}

start_tower_sequence()
{
	fadein = create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_tower" );
	
	droneClip = getent( "bunker_trench_drone_clip", "targetname" );
	droneClip connectPaths();
	droneClip delete();
	
	door = getent( "trench_tower_garage_entrance", "targetname" );
	door connectPaths();
	door delete();
	
	flag_set( "FLAG_start_tower_sequence" );
	
	fadein thread fade_over_time( 0, 1 );		
}

start_tower_retreat()
{
	fadein = create_client_overlay( "black", 1, level.player );
	
	flag_set( "FLAG_start_tower_retreat" );

	alliesTeletoStartSpot( "start_tower_retreat" );	
	fadein thread fade_over_time( 0, 1 );	
}

start_elias_street()
{
	fadein = create_client_overlay( "black", 1, level.player );
	
	flag_set( "FLAG_start_elias_street" );

	alliesTeletoStartSpot( "start_elias_street" );	
	fadein thread fade_over_time( 0, 1 );	
}

start_elias_house()
{
	fadein = create_client_overlay( "black", 1, level.player );
		
	flag_set( "FLAG_start_elias_house" );
	
	alliesTeletoStartSpot( "start_elias_house" );	
	fadein thread fade_over_time( 0, 1 );	
}

start_a10_test()
{
	alliesTeletoStartSpot( "start_a10_test" );	
}

// MAIN AI
init_MainAI()
{
	level.heroes = [];
	spawners = getentarray( "main_ai", "targetname" );
	
	foreach( spawner in spawners )
	{
		ai = spawner spawn_ai( true, true );
		ai make_hero();
		ai.animname = spawner.script_noteworthy;
		ai.script_noteworthy = spawner.script_noteworthy;
		
		if( spawner.script_noteworthy == "hesh" )
		{
			level.hesh = ai;
			ai.name = "Hesh";
		}
		else if( spawner.script_noteworthy == "dog" )
		{
			level.dog = ai;
			ai.name = "Cairo";
			ai.ignoreme = true;
			ai.ignoresuppression = true;
			ai SetDogAttackRadius( 56 );
			ai set_moveplaybackrate( .8 );
		}
		
		level.heroes[ level.heroes.size ] = ai;
	}
	
//	level.dog SetDogHandler( level.hesh );
//	level.dog setgoalentity( level.hesh );
}