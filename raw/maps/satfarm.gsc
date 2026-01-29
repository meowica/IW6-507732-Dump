#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


main()
{
					//   dvar_name 			     current_gen_val    next_gen_val   
	setsaveddvar_cg_ng( "r_specularcolorscale", 3.00			 , 6.00 );
	setsaveddvar_cg_ng( "r_diffusecolorscale" , 1.24			 , 1.24 );

	SetSavedDvar( "sm_sunShadowScale", 0.65 );
	//SetSavedDvar( "sm_sunsamplesizenear", 3000 );
	
	template_level( "satfarm" );
	maps\createart\satfarm_art::main();
	maps\satfarm_fx::main();
	maps\satfarm_precache::main();
	maps\satfarm_anim::main();
	
	satfarm_starts();
	maps\satfarm_code::reconuavinit();
	satfarm_init();
	satfarm_precache();
	
	maps\_load::main();
	maps\satfarm_audio::main();
	maps\_rv_vfx::init(); // Global breakable system
	
	satfarm_global_flags();
	
	// init heli functions
	maps\_helifly_missile::precache_guided_missiles();
	maps\satfarm_code_heli::chopper_ai_init();
	maps\satfarm_code_heli::heli_ai_collision_cylinder_setup();
	maps\_helifly_missile::init_missiles();
	
	level.player maps\_helifly_missile::player_missile_init();
	level.player.heli_hud[ "missile_range" ] .alpha = 0;
	level.player.heli_hud[ "missile_roll"  ] .alpha = 0;
	
	// init tank functions
	maps\satfarm_code::nav_mesh_build();
	maps\satfarm_code::init_system();
	
	maps\_drone_ai::init();
		
	// set up generic node based tank spawn func
	maps\satfarm_code::generic_tank_dynamic_path_spawner_setup();
	//maps\satfarm_code::generic_gaz_dynamic_path_spawner_setup();
	maps\satfarm_code::generic_gaz_spawner_setup();
	maps\satfarm_code::generic_tank_spawner_setup();
	
								 //   key 			   func 									  
	array_spawn_function_noteworthy( "crawling_guys", maps\satfarm_code::crawling_guys_spawnfunc );
	array_spawn_function_noteworthy( "limping_guys" , maps\satfarm_code::limping_guys_spawnfunc );
	
	array_spawn_function_noteworthy( "air_strip_quick_cleanup_enemies", maps\satfarm_air_strip::air_strip_ai_quick_cleanup_spawn_function, 4500 * 4500 );
	array_spawn_function_noteworthy( "base_array_enemies", maps\satfarm_base_array::base_array_ai_cleanup_spawn_function );
	
	SetSavedDvar( "compassTickertapeStretch", "1.0" );
	SetNorthYaw( 0.0 );
	
	setsaveddvar_cg_ng( "fx_alphathreshold", 9, 9 );
	
	maps\satfarm_ambient_a10::a10_precache();
	maps\satfarm_ambient_a10::a10_spawn_funcs();
	
	/# thread maps\satfarm_code::count_vehicles();#/
}

satfarm_starts()
{
		   //   msg 			     func 												     loc_string 	      optional_func 										 
	add_start( "intro"			  , maps\satfarm_intro::intro_init						  , "Intro"			   , maps\satfarm_intro::intro_main );
	add_start( "crash_site"		  , maps\satfarm_crash_site::crash_site_init			  , "Crash Site"	   , maps\satfarm_crash_site::crash_site_main );
	add_start( "base_array"		  , maps\satfarm_base_array::base_array_init			  , "Base Array"	   , maps\satfarm_base_array::base_array_main );
	add_start( "air_strip"		  , maps\satfarm_air_strip::air_strip_init				  , "Air Strip"		   , maps\satfarm_air_strip::air_strip_main );
	add_start( "air_strip_secured", maps\satfarm_air_strip_secured::air_strip_secured_init, "Air Strip Secured", maps\satfarm_air_strip_secured::air_strip_secured_main );
	add_start( "tower"			  , maps\satfarm_tower::tower_init						  , "Tower"			   , maps\satfarm_tower::tower_main );
	add_start( "warehouse"		  , maps\satfarm_tower::warehouse_init					  , "Warehouse"		   , maps\satfarm_tower::warehouse_main );
	add_start( "bridge_deploy"	  , maps\satfarm_bridge_deploy::bridge_deploy_init		  , "Bridge Deploy"	   , maps\satfarm_bridge_deploy::bridge_deploy_main );
	add_start( "bridge"			  , maps\satfarm_bridge::bridge_init					  , "Bridge"		   , maps\satfarm_bridge::bridge_main );
		   //   msg 	   func 							   loc_string    optional_func 					    
	add_start( "complex", maps\satfarm_complex::complex_init, "Complex"	  , maps\satfarm_complex::complex_main );
	add_start( "final"			  , maps\satfarm_final::final_init						  , "Final"	  			, maps\satfarm_final::final_main );
	//add_start( "buster"		  , maps\satfarm_final::final_init						  , "buster"	  		, maps\satfarm_final::final_main );
	
	default_start( maps\satfarm_intro::intro_init );
}

satfarm_global_flags()
{
	flag_init( "player_in_tank" );
	//checkpoint flags
	flag_init( "intro_end" );
	flag_init( "crash_site_end" );
	flag_init( "base_array_end" );
	flag_init( "air_strip_end" );
	flag_init( "air_strip_secured_end" );
	flag_init( "tower_end" );
	flag_init( "warehouse_end" );
	flag_init( "bridge_deploy_end" );
	flag_init( "bridge_end" );
	flag_init( "satfarm_canyon_end" );
	flag_init( "satfarm_complex_end" );
	flag_init( "all_tanks_stop_firing" );
	
	flag_init( "hangar_blasted" );
	
	//system flags
	flag_init( "nostopping" );
	flag_init( "MG_FIRE" );
	flag_init( "THERMAL_ON" );
	flag_init( "ZOOM_ON" );
	flag_init( "POPPED_SMOKE" );
	flag_init( "player_guiding_round" );
	flag_init( "player_fired_guided_round" );
	flag_init( "guided_round_enabled" );
	
	// Relative Speed Flags
	flag_init( "allies_stop_canyon" );
	flag_init( "allies_stop_complex" );
	
	flag_init( "ambush_reverse" );
	
	flag_init( "enough_crash_site_enemies_dead" );
	
	//Air strip secured flags
	flag_init( "ghost2_landed" );
	flag_init( "send_enemy_for_player" );
	flag_init( "start_rappel" );
	flag_init( "player_landed" );

	//Tower flags
	flag_init( "spawn_control_room_enemies_wave_2" );
	flag_init( "control_room_three_left" );
	flag_init( "control_room_enemies_dead" );
	flag_init( "player_ready_for_javelin_nest" );
	flag_init( "player_shot_at_javelin_nest" );
	flag_init( "player_waits_too_long_at_javelin_nest" );
	flag_init( "javelin_nest_alerted" );
	flag_init( "javelin_nest_enemies_dead" );
	flag_init( "loading_bay_runner_1_dead" );
	flag_init( "loading_bay_runner_2_dead" );
	flag_init( "send_in_loading_bay_runner_3" );
	flag_init( "loading_bay_enemies_retreat" );
	flag_init( "all_enemies_out_of_loading_bay" );
	flag_init( "elevator_room_cleared" );
	flag_init( "player_shot_at_enemies_in_warehouse" );
	flag_init( "allies_in_elevator" );
	flag_init( "player_and_allies_in_elevator" );
	flag_init( "elevator_landed" );
	flag_init( "unload_elevator" );
	flag_init( "lift_landed" );
	flag_init( "warehouse_enemies_alerted" );
	flag_init( "start_warehouse_runners" );
	flag_init( "advance_allies_wave_2_flag" );
	flag_init( "advance_allies_wave_3_flag" );
	flag_init( "advance_allies_wave_3a_flag" );
	flag_init( "advance_allies_wave_4_flag" );
	flag_init( "advance_allies_wave_5_flag" );
	flag_init( "advance_allies_wave_6_flag" );
	flag_init( "warehouse_last_push" );
	flag_init( "warehouse_cleared" );
	flag_init( "player_train_trigger" );
	flag_init( "player_on_train" );
	
	//Complex Flags
	flag_init( "apache_ally1_fire" );
	flag_init( "apache_ally2_fire" );
	flag_init( "apache_ally3_fire" );
	flag_init( "dismounted_tank" );
	flag_init( "missile_out_of_bounds" );
	
	//Damage Flags
	flag_init( "optics_out" );
	flag_init( "smoke_out" );
	flag_init( "tow_out" );
	flag_init( "compass_out" );
	flag_init( "thermal_out" );
	flag_init( "all_guns_out" );
	flag_init( "final_hit" );
		
	//Final Flags
	flag_init( "final_mounting_tank" );
	flag_init( "final_rail" );
	flag_init( "final_kill_turrets" );
	flag_init( "missile_strike" );
	flag_init( "missile_strike_now" );
}

satfarm_init()
{
	maps\satfarm_complex::complex_init();
}

satfarm_precache()
{
	PrecacheDigitalDistortCodeAssets();
	
	PreCacheItem( "ak12" );
	PreCacheItem( "rpg_straight" );
	PreCacheItem( "tankfire_straight_fast" );
	PreCacheItem( "freerunner" );
	PreCacheItem( "honeybadger" );
	
	PreCacheShader( "thermalbody_snowlevel" );
	
	PreCacheShader( "m1a1_compass_center" );
	PreCacheShader( "m1a1_compass_enemy" );
	PreCacheShader( "m1a1_compass_objective" );
	PreCacheShader( "m1a1_compass_scanline" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_bottom_left" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_bottom_left_red" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_bottom_right" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_bottom_right_red" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_top_left" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_top_left_red" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_top_right" );
	PreCacheShader( "m1a1_tank_missile_reticle_inner_top_right_red" );
	PreCacheShader( "m1a1_tank_sabot_fuel_gauge" );
	PreCacheShader( "m1a1_tank_sabot_fuel_range" );
	PreCacheShader( "m1a1_tank_sabot_fuel_range_horizontal" );
	PreCacheShader( "m1a1_tank_sabot_grid_overlay" );
	PreCacheShader( "m1a1_tank_sabot_reticle_center" );
	PreCacheShader( "m1a1_tank_sabot_reticle_center_red" );
	PreCacheShader( "m1a1_tank_sabot_reticle_outer_left" );
	PreCacheShader( "m1a1_tank_sabot_reticle_outer_left_red" );
	PreCacheShader( "m1a1_tank_sabot_reticle_outer_right" );
	PreCacheShader( "m1a1_tank_sabot_reticle_outer_right_red" );
	PreCacheShader( "m1a1_tank_sabot_target_range" );
	PreCacheShader( "m1a1_tank_sabot_vignette" );
	PreCacheShader( "m1a1_tank_primary_reticle" );
	PreCacheShader( "m1a1_tank_primary_reticle_center" );
	PreCacheShader( "m1a1_tank_primary_reticle_center_red" );
	PreCacheShader( "m1a1_tank_primary_reticle_cross" );
	PreCacheShader( "m1a1_tank_primary_reticle_cross_red" );
	PreCacheShader( "m1a1_tank_weapon_progress_bar" );
	PreCacheShader( "m1a1_tank_weapon_progress_bar_infinite" );
	PreCacheShader( "m1a1_tank_weapon_select_arrow" );
	PreCacheShader( "green_block" );
	PreCacheShader( "red_block" );
	PreCacheShader( "ugv_screen_overlay" );
	PreCacheShader( "ugv_vignette_overlay" );
	PreCacheShader( "overlay_static" );
	PreCacheShader( "m1a1_tank_sabot_scanline" );
	PreCacheItem( "sabot_guided" );
	PreCacheItem( "sabot_guided_detonate" );
	//"ROT"
	PreCacheString( &"SATFARM_RANGE_ON_TARGET" );
	//"FUEL RANGE"
	PreCacheString( &"SATFARM_FUEL_RANGE" );
	//"FUEL\nRANGE"
	PreCacheString( &"SATFARM_FUELRANGE" );
	//"100M"
	PreCacheString( &"SATFARM_RANGE_1" );
	//"200M"
	PreCacheString( &"SATFARM_RANGE_2" );
	//"300M"
	PreCacheString( &"SATFARM_RANGE_3" );
	//"400M"
	PreCacheString( &"SATFARM_RANGE_4" );
	//"500M"
	PreCacheString( &"SATFARM_RANGE_5" );
	
	PreCacheShader( "overlay_static" );
	PreCacheShader( "ac130_hud_diamond" );
	PreCacheShader( "remotemissile_infantry_target" );
	PreCacheShader( "uav_vehicle_target" );
	PreCacheShader( "veh_hud_target" );
	PreCacheShader( "veh_hud_friendly" );
	PreCacheShader( "ac130_hud_diamond" );
	PreCacheShader( "ac130_hud_tag" );
	PreCacheShader( "button_360_rt" );
	PreCacheShader( "button_360_x" );
	PreCacheShader( "cinematic" );
		
	PreCacheModel( "viewhands_player_delta" );
	PreCacheModel( "viewhands_player_us_army" );
	
	PreCacheModel( "projectile_m203grenade" );
	
	PreCacheModel( "vehicle_a10_warthog_player" );
	PreCacheModel( "vehicle_boeing_c17" );
	PreCacheModel( "vehicle_m1a1_abrams_viewmodel" );
	PreCacheModel( "vehicle_m1a1_abrams" );
	
	PreCacheModel( "saf_parachute_proxy" );
	PreCacheModel( "saf_parachute_large" );

	PreCacheModel( "london_streetlight_01" );
	PreCacheModel( "fac_metal_barrier_post" );

	PreCacheRumble( "subtler_tank_rumble" );
	
	//tank mount
	PreCacheModel( "vehicle_m1a1_abrams_minigun_shiny_part" );
	PreCacheShellShock( "hamburg_blackout" );
	PreCacheShellShock( "hijack_engine_explosion" );
	PreCacheRumble( "ac130_40mm_fire" );
	
	//Tower
	PreCacheModel( "weapon_javelin_sp" );
	PreCacheItem( "javelin_dcburn" );
	
	PreCacheItem( "missile_attackheli" );
	
	maps\satfarm_satellite_view::satellite_view_precache();
	
	//"LOKI CONTROL ARRAY"
	//"November 24th - 03:16:[{FAKE_INTRO_SECONDS:09}]"
	//"Atacama Desert, Chile\n"
	intro_screen_create( &"SATFARM_INTROSCREEN_LINE_1", &"SATFARM_INTROSCREEN_LINE_2", &"SATFARM_INTROSCREEN_LINE_3" );
	
	//"Press [{weapnext}] to switch to guided rounds"
	add_hint_string( "HINT_SWITCH_TO_GUIDED_ROUND", &"SATFARM_HINT_SWITCH_TO_GUIDED_ROUND" );
	
	//"Press [{+attack}] to fire guided round"
	add_hint_string( "HINT_GUIDED_ROUND_FIRE", &"SATFARM_HINT_GUIDED_ROUND_FIRE" );
	
	//"Press [{+gostand}] to jump"
	add_hint_string( "HINT_RAPPEL",  &"SATFARM_RAPPEL",  maps\satfarm_air_strip_secured::HINT_RAPPEL_OFF );
	
	//"Hold [{+speed_throw}] to zoom"
	add_hint_string( "HINT_ZOOM",  &"SATFARM_HINT_ZOOM",  ::HINT_ZOOM_OFF ); //implemented on top of the ridge before the first sat array
	
	//"Press [{+activate}] to activate Thermal"
	add_hint_string( "HINT_THERMAL",  &"SATFARM_HINT_THERMAL",  ::HINT_THERMAL_OFF ); //implemented in first sat array
	
	//"Press [{+frag}] to fire machine gun"
	add_hint_string( "HINT_MACHINE_GUN",  &"SATFARM_HINT_MACHINE_GUN",  ::HINT_MACHINE_GUN_OFF ); //implemented when you bust the hangar open because it would be the first time you see infantry
	
	//"Press [{+smoke}] to pop smoke"
	add_hint_string( "HINT_SMOKE",  &"SATFARM_HINT_SMOKE",  ::HINT_SMOKE_OFF ); //implemented in first sat array
	
	level.send_enemy_for_player_trigger = GetEnt( "send_enemy_for_player_trigger", "targetname" );
	level.send_enemy_for_player_trigger trigger_off();
}

HINT_ZOOM_OFF()
{
	return flag( "ZOOM_ON" );
}

HINT_THERMAL_OFF()
{
	return flag( "THERMAL_ON" );
}

HINT_MACHINE_GUN_OFF()
{
	return flag( "MG_FIRE" );
}

HINT_SMOKE_OFF()
{
	return flag( "POPPED_SMOKE" );
}

HINT_SWITCH_TO_GUIDED_ROUND_OFF()
{
	if( IsDefined( self.tank_hud_item[ "current_weapon" ].weap ) && self.tank_hud_item[ "current_weapon" ].weap == "missile" )
		return true;
}

HINT_GUIDED_ROUND_FIRE_OFF()
{
	if( ( flag( "player_fired_guided_round" ) || flag( "player_guiding_round" ) ) )
		return true;
}