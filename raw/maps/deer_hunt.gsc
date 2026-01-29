#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\deer_hunt_util;

/* IW6 Deer Hunt: Geo by Geoff Hudson Scripting by Steve Holmes */

#using_animtree("generic_human");
main()
{
	template_level( "deer_hunt" );
	maps\createart\deer_hunt_art::main();
	maps\deer_hunt_fx::main();
	maps\deer_hunt_anim::main();
	maps\deer_hunt_precache::main();
	
	precache_stuff();
	//init_level_flags();

	add_start( "intro", maps\deer_hunt_intro::intro_setup, "Intro" );
	add_start( "lobby", ::lobby_entrance, "Lobby Entrance" );
	add_start( "outside", ::outside_start, "Theater Exit" );
	add_start( "street", ::street_start, "Promenade Exit" );
	add_start( "encounter1", ::encounter1_start, "First Encounter" );
	add_start( "encounter2", ::encounter2_start, "Gas Station" );
	add_start( "lariver", ::lariver_start, "L.A. River" );
	add_start( "lariver_nogame", ::lariver_nogame_start, "L.A. River - no scripting" );
	add_start( "ride", ::ride_start, "Jeep Ride" );
	add_start( "house", ::house_start, "Elias' House" );
				
	default_start( maps\deer_hunt_intro::intro_setup );
	setup_flags();
	
	//"Ghost Town"
	//"June 26th - 05:12:[{FAKE_INTRO_SECONDS:17}]"
	//"Adam Rorke"
	//"Special Forces ODA 2112"
	//"1 mile south of the new U.S. border"
	intro_screen_create( &"DEER_HUNT_INTROSCREEN_LINE_3", &"DEER_HUNT_INTROSCREEN_LINE_4", &"DEER_HUNT_INTROSCREEN_LINE_5" );

	
	maps\_load::main();
	maps\deer_hunt_audio::main();
	maps\_drone_deer::init();
	maps\_load::set_player_viewhand_model( "viewhands_player_sas_woodland" );
		
	// Setup Stealth
	maps\_stealth::main();
	array_thread( level.players, maps\_stealth_utility::stealth_default );
	
	maps\_patrol_anims_gundown::main();
	maps\_patrol_anims_creepwalk::main();
	//thread maps\deer_hunt_intro::lobby_ruckus();
	
	//trigs = GetEntArray( "deer_ruckus", "script_noteworthy");
	//array_thread( trigs, maps\deer_hunt_intro::deer_ruckus_trig_logic );
	
	creepwalk_anims = [];
	creepwalk_anims["run"][ "straight" ] = %creepwalk_f;
	creepwalk_anims["run"][ "move_f" ] = %creepwalk_f;	
	
	register_archetype( "creepwalk_archetype", creepwalk_anims );
	
	gundown_anims = [];
	gundown_anims["run"][ "straight" ] = %active_patrolwalk_gundown;
	gundown_anims["run"][ "move_f" ] = %active_patrolwalk_gundown;	
	
	register_archetype( "gundown_archetype", gundown_anims );
	
	SetDvarIfUninitialized( "steve", 0 );
	
	spot = (-13868.7, 13216.9, -466.8);
	BadPlace_Cylinder( "axis", 0, spot, 300, 100, "axis" );

}


precache_stuff()
{
	PreCacheModel( "fullbody_prototype_deer_a" );

	PreCacheItem( "acr_hybrid_silenced" );
	
	PreCacheString( &"DEER_HUNT_INTROSCREEN_LINE_1" );
	PreCacheString( &"DEER_HUNT_INTROSCREEN_LINE_2" );
	PreCacheString( &"DEER_HUNT_INTROSCREEN_LINE_3" );
	PreCacheString( &"DEER_HUNT_INTROSCREEN_LINE_4" );
	PreCacheString( &"DEER_HUNT_INTROSCREEN_LINE_5" );
	
	PreCacheString( &"DEER_HUNT_JEEP_INTROLINE_1" );
	PreCacheString( &"DEER_HUNT_JEEP_INTROLINE_2" );
	PreCacheString( &"DEER_HUNT_JEEP_INTROLINE_3" );
	
}

setup_flags()
{
	flag_init("flare_down");
	flag_init("to_theater_exit");
	flag_init("deer_runs");
	flag_init("shadow_guy_dead");
	flag_init("shadow_chasers_hot");
	flag_init( "roof_guy_dead" );
	flag_init("gasstation_guys_engaged");
	flag_init( "level.gasstation_guys" );
	flag_init( "send_dog_to_roof" );
	flag_init( "jeep_ai_spawned" );
	flag_init( "jeep_arrived" );
	flag_init( "player_in_jeep" );
	flag_init( "friendlies_in_jeep" );
	flag_init( "lariver_finished" );
	flag_init( "exit_theater" );
	flag_init( "deer_moved_away" );
	flag_init( "hesh_to_shop_door" );
	flag_init( "gas_station_open_fire" );
	flag_init( "intro_vo_done" );
	flag_init( "intro_takedown_aborted" );
	flag_init( "intro_takedown_started" );
	flag_init( "intro_takedown_done" );
	flag_init( "intro_takedown_ready" );
	flag_init( "friendlies_spawned" );
	flag_init( "dog_kill_started" );
	flag_init( "dog_kill_aborted" );
	flag_init( "dog_kill_ended" );
	flag_init( "execution_start" );
	flag_init( "civilians_shot" );
	//flag_init( "" );
	
	flag_trigs();	
}


flag_trigs()
{
	if ( getdvarint( "r_reflectionProbeGenerate" ) == 1 )
		return;
	
	trig_flags = [];
	trig_flags[trig_flags.size] = "lobby_entrance";
	trig_flags[trig_flags.size] = "lobby_exit_approach" ;
	trig_flags[trig_flags.size] = "lobby_exit" ;
	trig_flags[trig_flags.size] = "screen_arrive";
	trig_flags[trig_flags.size] = "promenade_exit_halfway";
	trig_flags[trig_flags.size] = "promenade_exit";
	//trig_flags[trig_flags.size] = "shop_approach";
	trig_flags[trig_flags.size] = "shop_exit";
	trig_flags[trig_flags.size] = "player_at_shop_door";
	trig_flags[trig_flags.size] = "player_at_encounter1";
	trig_flags[trig_flags.size] = "dog_distracts";
	trig_flags[trig_flags.size] = "hill_pos1";
	trig_flags[trig_flags.size] = "hill_pos2";
	trig_flags[trig_flags.size] = "dog_on_roof";
	trig_flags[trig_flags.size] = "player_to_roof";
	trig_flags[trig_flags.size] = "gasstation_clear";
	trig_flags[trig_flags.size] = "gate_approach";
	trig_flags[trig_flags.size] = "pipe_halfway";
	trig_flags[trig_flags.size] = "pipe_exit";
	trig_flags[trig_flags.size] = "pipe_enter";
	trig_flags[trig_flags.size] = "through_screen";
	trig_flags[trig_flags.size] = "hallway_halfway";
	trig_flags[trig_flags.size] = "to_lobby_entrance";
	trig_flags[trig_flags.size] = "dog_to_shadow_guy";
	trig_flags[trig_flags.size] = "road_chasm_approach";
	trig_flags[trig_flags.size] = "hesh_attacks_shadow_guys";
	trig_flags[trig_flags.size] = "theater_exit";
	trig_flags[trig_flags.size] = "dropdown_arrive";
	trig_flags[trig_flags.size] = "gas_station_enter";
	trig_flags[trig_flags.size] = "to_pipe";
	trig_flags[trig_flags.size] = "player_under_bridge";
	trig_flags[trig_flags.size] = "lariver_final_position";
	trig_flags[trig_flags.size] = "hesh_to_lookout";
	trig_flags[trig_flags.size] = "encounter1_approach";
	trig_flags[trig_flags.size] = "player_on_bus";
	trig_flags[trig_flags.size] = "player_out_of_chasm";
	trig_flags[trig_flags.size] = "back_enemies_fight_begin";
	
	trig_flags_player_only = [];
	trig_flags_player_only[ trig_flags_player_only.size ]= "player_dropped_down";
	//trig_flags_player_only[ trig_flags_player_only.size ]= "";
	//trig_flags_player_only[ trig_flags_player_only.size ]= "";
	//trig_flags_player_only[ trig_flags_player_only.size ]= "";

	foreach( flag_name in trig_flags )
	{
		init_flag_and_set_on_targetname_trigger( flag_name );
	}
	
	foreach( flag_name in trig_flags_player_only )
	{
		thread set_flag_on_targetname_trigger_by_player( flag_name );
	}
}

init_flag_and_set_on_targetname_trigger( trig_targetname )
{
	flag_init( trig_targetname );
	thread set_flag_on_targetname_trigger( trig_targetname );	
}




lobby_entrance()
{
	thread maps\deer_hunt_intro::move_player_to_start( "lobby_entrance_player" );
	thread maps\deer_hunt_intro::player_control();
	thread maps\deer_hunt_intro::deer_init();
	thread maps\deer_hunt_intro::setup_friendlies();
	thread maps\deer_hunt_intro::lobby_ruckus();	
	thread maps\deer_hunt_intro::intro_enemies();
	thread maps\deer_hunt_intro::intro_vo();
	
	flag_wait( "friendlies_spawned" );
	level.hesh set_force_color( "red" );
	level.dog set_force_color( "blue" );
	
	structs = getstructarray( "lobby_entrance_ai", "targetname" );
	
	foreach( i, ai in level.squad )
	{
		ai enable_ai_color();
		ai ForceTeleport( structs[i].origin, structs[i].angles );
	}
	
	level.hesh set_force_color( "red" );
	level.dog set_force_color( "blue" );
	
	activate_trigger_with_targetname( "theater_exit" );
	activate_trigger_with_targetname( "to_lobby_entrance" );

}

outside_start()
{
	thread maps\deer_hunt_intro::move_player_to_start( "outside_start_player" );
	thread maps\deer_hunt_intro::player_control();
	thread maps\deer_hunt_intro::intro_enemies();
	thread maps\deer_hunt_intro::setup_friendlies();
	thread maps\deer_hunt_intro::intro_vo();
	
	flag_wait( "friendlies_spawned" );
	level.hesh set_force_color( "red" );
	level.dog set_force_color( "blue" );
	
	activate_trigger_with_targetname("lobby_exit_approach");
	
	structs = getstructarray( "outside_start_ai", "targetname" );
	
	foreach( i, ai in level.squad )
	{
		ai enable_ai_color();
		ai ForceTeleport( structs[i].origin, structs[i].angles );

	}
	
	exit_spawners = getentarray( "promenade_exit_deer", "targetname" );
	
	foreach( i, s in exit_spawners )
	{
		exit_deer[i] = maps\_drone_deer::deer_dronespawn( s );
		exit_deer[i] thread maps\deer_hunt_intro::deer_detects_when_to_run();
	}
	//level.hesh set_force_color( "red" );
	//level.dog set_force_color( "blue" );
	
}

street_start()
{
	thread maps\deer_hunt_intro::move_player_to_start( "street_start_player" );
	thread maps\deer_hunt_intro::player_control();
	thread maps\deer_hunt_intro::intro_enemies();
	thread maps\deer_hunt_intro::setup_friendlies();
	thread maps\deer_hunt_intro::intro_vo();
	
	flag_wait( "friendlies_spawned" );
	level.hesh set_force_color( "red" );
	level.dog set_force_color( "blue" );
	
	structs = getstructarray( "street_start_ai", "targetname" );
	
	foreach( i, ai in level.squad )
	{
		ai enable_ai_color();
		ai ForceTeleport( structs[i].origin, structs[i].angles );

	}
	
	level.hesh enable_cqbwalk();
		
}

encounter1_start()
{
	thread maps\deer_hunt_intro::move_player_to_start( "encounter1_player" );
	thread maps\deer_hunt_intro::player_control();
	thread maps\deer_hunt_intro::intro_enemies();
	thread maps\deer_hunt_intro::setup_friendlies();
	thread maps\deer_hunt_intro::intro_vo();
	
	flag_wait( "friendlies_spawned" );
	level.hesh set_force_color( "red" );
	level.dog set_force_color( "blue" );
	
	//level.shadow_guys = array_spawn_targetname( "shadow_guy", 1 );
	
	structs = getstructarray( "encounter1_ai", "targetname" );
	
	foreach( i, ai in level.squad )
	{
		//ai enable_ai_color();
		ai ignore_me_ignore_all();
		ai ForceTeleport( structs[i].origin, structs[i].angles );

	}
	
	level.hesh disable_ai_color();
	level.dog delaythread( 1, ::enable_ai_color );
	level.hesh enable_cqbwalk();

	level.team2 = array_spawn_targetname( "team2" );
	team2_structs = getstructarray( "team2_encounter1", "targetname" );
	
	foreach( i, s in team2_structs )
	{
		//level.team2[i] thread maps\deer_hunt_intro::lariver_team2_logic();
		level.team2[i] forceteleport( s.origin, s.angles );
	}
	
	activate_trigger_with_targetname( "dropdown_arrive");
	activate_trigger_with_targetname( "player_on_bus" ); //sends team2 to their covering spot
	
	blocker = getent( "dropdown_blocker", "targetname" );
	blocker.origin += (0,0,400);
	blocker ConnectPaths();
	wait(.05);
	blocker delete();
	
	array_thread( level.team2, ::cqb_off_sprint_on );
	
	flag_wait("pipe_enter");
	thread maps\deer_hunt_intro::lariver_global_setup();
	
}

encounter2_start()
{
	thread maps\deer_hunt_intro::move_player_to_start( "gasstation_start_player" );
	thread maps\deer_hunt_intro::player_control();
	
	thread maps\deer_hunt_intro::setup_friendlies();
	
	thread maps\deer_hunt_intro::intro_enemies();	
	thread maps\deer_hunt_intro::intro_vo();
	
	flag_wait( "friendlies_spawned" );
	level.hesh set_force_color( "red" );
	level.dog set_force_color( "blue" );
	
	structs = getstructarray( "gasstation_start_ai", "targetname" );
	
	foreach( i, ai in level.squad )
	{
		ai enable_ai_color();
		ai ForceTeleport( structs[i].origin, structs[i].angles );
	}
	
	level.team2 = array_spawn_targetname( "team2" );
	team2_structs = getstructarray( "team2_encounter2", "targetname" );
	
	foreach( i, s in team2_structs )
	{
		//level.team2[i] thread maps\deer_hunt_intro::lariver_team2_logic();
		level.team2[i] forceteleport( s.origin, s.angles );
	}
	
	activate_trigger_with_targetname("encounter1_approach");
	activate_trigger_with_targetname("hesh_to_dropdown");
	
	flag_wait("pipe_enter");
	thread maps\deer_hunt_intro::lariver_global_setup();
	
}


lariver_start()
{
	thread maps\deer_hunt_intro::move_player_to_start( "la_river_player" );
	thread maps\deer_hunt_intro::player_control();
	//thread maps\deer_hunt_intro::intro_enemies();
	thread maps\deer_hunt_intro::setup_friendlies();
	thread maps\deer_hunt_intro::intro_vo();
	
	flag_wait( "friendlies_spawned" );
	level.hesh set_force_color( "red" );
	level.dog set_force_color( "blue" );
	
	structs = getstructarray( "la_river_ai", "targetname" );
	
	foreach( i, ai in level.squad )
	{
		ai enable_ai_color();
		ai ForceTeleport( structs[i].origin, structs[i].angles );
	}
	
	level.team2 = array_spawn_targetname( "team2" );
	team2_structs = getstructarray( "team2_lariver", "targetname" );
	
	foreach( i, s in team2_structs )
	{
		//level.team2[i] thread maps\deer_hunt_intro::lariver_team2_logic();
		level.team2[i] forceteleport( s.origin, s.angles );
	}
	
	//level.player GiveWeapon( "kriss" );
	level.player GiveWeapon( "m14ebr_scope" );
	level.player SwitchToWeapon( "m14ebr_scope" );
	level.player GiveMaxAmmo( "m14ebr_scope" );
	thread maps\deer_hunt_intro::lariver_global_setup();
	
}


lariver_nogame_start()
{
	//ai and vehicle spawns go away please
	trigger_off( "trigger_multiple", "classname" );
	trigger_off( "trigger_radius", "classname" );
	trigger_off( "trigger_multiple_spawn", "classname" );

	thread maps\deer_hunt_intro::move_player_to_start( "la_river_player" );
	
	level.player GiveWeapon( "kriss" );
	level.player SwitchToWeapon( "kriss" );
	level.player GiveMaxAmmo( "kriss" );
	
}

ride_start()
{
	//thread maps\deer_hunt_intro::move_player_to_start( "ride_player_start" );
	thread maps\deer_hunt_ride::jeep_ride_setup();
	
	
}

house_start()
{
	level.hesh = spawn_targetname( "hesh", 1 );
	level.dog = spawn_targetname( "dog", 1 );	

	level.squad = [level.hesh, level.dog ];
	
	thread maps\deer_hunt_intro::move_player_to_start( "house_player" );
	thread maps\deer_hunt_ride::setup_house();
	
	structs = getstructarray( "house_ai", "targetname" );
	
	foreach( i, ai in level.squad )
	{
		ai ForceTeleport( structs[i].origin, structs[i].angles );
	}
	
	level.hesh thread maps\deer_hunt_ride::hesh_navigation_logic();
	level.dog thread maps\deer_hunt_ride::dog_navigation_logic();
	
	
}
