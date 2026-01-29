#include maps\_global_fx_code;
#include maps\_utility;
#include maps\_weather;
#include common_scripts\_createfx;
#include common_scripts\utility;

main()
{
	level._effect[ "door_open_dust_short_01" ]									= loadfx( "fx/dust/door_open_dust_short_01" );
	// level._effect[ "fire_extinguisher_exp" ]									= loadfx( "fx/props/fire_extinguisher_exp" );
	level._effect[ "factory_fog_cover" ]										= loadfx( "fx/smoke/factory_fog_cover" );
	level._effect[ "factory_fog_ground_400" ]									= loadfx( "fx/smoke/factory_fog_ground_400" );
	level._effect[ "factory_fog_patch" ]										= loadfx( "fx/smoke/factory_fog_patch" );
	level._effect[ "101ton_bomb" ]												= loadfx( "vfx/gameplay/explosions/101ton_bomb" );
	level._effect[ "amber_light_100_blinker_nolight" ]							= loadfx( "vfx/ambient/lights/amber_light_100_blinker_nolight" );
	level._effect[ "amber_light_45_beacon_glow" ]								= loadfx( "vfx/ambient/lights/amber_light_45_beacon_glow" );
	level._effect[ "amber_light_45_beacon_nolight_beam" ]						= loadfx( "vfx/ambient/lights/amber_light_45_beacon_nolight_beam" );
	level._effect[ "amber_light_45_beacon_nolight_glow" ]						= loadfx( "vfx/ambient/lights/amber_light_45_beacon_nolight_glow" );
	level._effect[ "amber_light_running_3_nolight" ]							= loadfx( "vfx/ambient/lights/amber_light_running_3_nolight" );
	level._effect[ "amber_light_running_4_nolight" ]							= loadfx( "vfx/ambient/lights/amber_light_running_4_nolight" );
	level._effect[ "amber_light_running_8_nolight" ]							= loadfx( "vfx/ambient/lights/amber_light_running_8_nolight" );
	level._effect[ "cable_sparks_funner" ]										= loadfx( "vfx/ambient/sparks/cable_sparks_funner" );
	level._effect[ "drip_50x5" ]												= loadfx( "vfx/ambient/water/drip_50x5" );
	level._effect[ "drip_5x5" ]													= loadfx( "vfx/ambient/water/drip_5x5" );
	level._effect[ "dropped_flashlight_spotlight_runner" ] 						= loadfx( "vfx/ambient/lights/dropped_flashlight_spotlight_runner" );
	level._effect[ "dust_motes_100" ]											= loadfx( "vfx/ambient/dust/particulates/dust_motes_100" );
	level._effect[ "dust_puff_light_fast_16" ]									= loadfx( "vfx/ambient/dust/dust_puff_light_fast_16" );
	level._effect[ "electrical_sparks" ]										= loadfX( "vfx/ambient/sparks/electrical_sparks" );
	level._effect[ "electrical_sparks_20_funner" ]								= loadfx( "vfx/ambient/sparks/electrical_sparks_20_funner" );
	level._effect[ "electrical_sparks_fuller" ]									= loadfx( "vfx/ambient/sparks/electrical_sparks_fuller" );
	level._effect[ "electrical_sparks_small_funner" ]							= loadfx( "vfx/ambient/sparks/electrical_sparks_small_funner" );
	level._effect[ "explosion_150" ]											= loadfx( "vfx/gameplay/explosions/explosion_150" );
	level._effect[ "factory_ambush_assembly_smoke"]								= loadFX( "vfx/moments/factory/factory_ambush_assembly_smoke" );
	level._effect[ "factory_ambush_assembly_smoke_flir2"]						= loadFX( "vfx/moments/factory/factory_ambush_assembly_smoke_flir2" );
	level._effect[ "factory_ambush_chest_blood" ]								= loadfx( "vfx/moments/factory/factory_ambush_chest_blood" );
	level._effect[ "factory_ambush_grenade_trail_runner" ]						= LoadFX( "vfx/moments/factory/factory_ambush_grenade_trail_runner" );
	level._effect[ "factory_ambush_monitor" ]									= loadfx( "vfx/moments/factory/factory_ambush_monitor" );
	level._effect[ "factory_ambush_monitor_error" ]								= loadfx( "vfx/moments/factory/factory_ambush_monitor_error" );
	level._effect[ "factory_ambush_smoke" ]										= loadfx( "vfx/moments/factory/factory_ambush_smoke" );
	level._effect[ "factory_ambush_smoke_grenade" ]								= loadfx( "vfx/moments/factory/factory_ambush_smoke_grenade" );
	level._effect[ "factory_ambush_smoke_grenade_hand" ]						= loadfx( "vfx/moments/factory/factory_ambush_smoke_grenade_hand" );
	level._effect[ "factory_box_scanner" ]										= loadfx( "vfx/moments/factory/factory_box_scanner" );
	level._effect[ "factory_box_scanner_godray" ]								= loadfx( "vfx/moments/factory/factory_box_scanner_godray" );
	level._effect[ "factory_breach_edge_sparks" ]								= loadfx( "vfx/moments/factory/factory_breach_edge_sparks" );
	level._effect[ "factory_breach_monitor_sparks_01" ]							= loadfx( "vfx/moments/factory/factory_breach_monitor_sparks_01" );
	level._effect[ "factory_breach_runner" ]									= loadfx( "vfx/moments/factory/factory_breach_runner" );
	level._effect[ "factory_chase_awning_dust" ]								= loadfx( "vfx/moments/factory/factory_chase_awning_dust" );
	level._effect[ "factory_chase_box_smoke" ]									= loadfx( "vfx/moments/factory/factory_chase_box_smoke" );
	level._effect[ "factory_chase_corner_dust" ]								= loadfx( "vfx/moments/factory/factory_chase_corner_dust" );
	level._effect[ "factory_chase_het_tire_smoke_runner" ]						= loadfx( "vfx/moments/factory/factory_chase_het_tire_smoke_runner" );
	level._effect[ "factory_chase_jeep_explosion " ]							= loadfx( "vfx/moments/factory/factory_chase_jeep_explosion" );
	level._effect[ "factory_chase_jeep_fire" ]									= loadfx( "vfx/moments/factory/factory_chase_jeep_fire" );
	level._effect[ "factory_chase_jeep_fire_small" ]							= loadfx( "vfx/moments/factory/factory_chase_jeep_fire_small" );
	level._effect[ "factory_chase_lamp_dust" ]									= loadfx( "vfx/moments/factory/factory_chase_lamp_dust" );
	level._effect[ "factory_chase_missile_explosion" ]							= loadfx( "vfx/moments/factory/factory_chase_missile_explosion" );
	level._effect[ "factory_chase_side_explosion" ]								= loadfx( "vfx/moments/factory/factory_chase_side_explosion" );
	level._effect[ "factory_chase_stack_big_dust" ]								= loadfx( "vfx/moments/factory/factory_chase_stack_big_dust" );
	level._effect[ "factory_chase_stack_big_dust_linger" ]						= loadfx( "vfx/moments/factory/factory_chase_stack_big_dust_linger" );
	level._effect[ "factory_chase_stack_break" ]								= loadfx( "vfx/moments/factory/factory_chase_stack_break" );
	level._effect[ "factory_chase_stack_pieces_impact_dust" ]					= loadfx( "vfx/moments/factory/factory_chase_stack_pieces_impact_dust" );
	level._effect[ "factory_chase_stack_pieces_trail_runner" ]					= loadfx( "vfx/moments/factory/factory_chase_stack_pieces_trail_runner" );
	level._effect[ "factory_chase_stack_pipe_explosion" ]						= loadfx( "vfx/moments/factory/factory_chase_stack_pipe_explosion" );
	level._effect[ "factory_chase_stack_small_dust" ]							= loadfx( "vfx/moments/factory/factory_chase_stack_small_dust" );
	level._effect[ "factory_chase_stack_small_roof_dust" ]						= loadfx( "vfx/moments/factory/factory_chase_stack_small_roof_dust" );
	level._effect[ "factory_chase_stack_walkway_dust" ]							= loadfx( "vfx/moments/factory/factory_chase_stack_walkway_dust" );
	level._effect[ "factory_chase_turn_explosion" ]								= loadfx( "vfx/moments/factory/factory_chase_turn_explosion" );
	level._effect[ "factory_chase_warehouse_door_explosion" ]					= loadfx( "vfx/moments/factory/factory_chase_warehouse_door_explosion" );
	level._effect[ "factory_chase_warehouse_explosion" ]						= loadfx( "vfx/moments/factory/factory_chase_warehouse_explosion" );
	level._effect[ "factory_chase_warehouse_fireball" ]							= loadfx( "vfx/moments/factory/factory_chase_warehouse_fireball" );
	level._effect[ "factory_floodlight_flare" ]									= loadfx( "vfx/moments/factory/factory_floodlight_flare" );
	level._effect[ "factory_het_cab_headlight_beam"	]							= loadfx( "vfx/moments/factory/factory_het_cab_headlight_beam" );
	level._effect[ "factory_het_cab_headlight_lens"	]							= loadfx( "vfx/moments/factory/factory_het_cab_headlight_lens" );
	level._effect[ "factory_intro_helicopter_rain" ]							= loadfx( "vfx/moments/factory/factory_intro_helicopter_rain" );
	level._effect[ "factory_intro_helicopter_raindrops" ]						= loadfx( "vfx/moments/factory/factory_intro_helicopter_raindrops" );
	level._effect[ "factory_intro_hero_rain" ]									= loadfx( "vfx/moments/factory/factory_intro_hero_rain" );
	level._effect[ "factory_intro_stab_blood_ally" ]							= loadfx( "vfx/moments/factory/factory_intro_stab_blood_ally" );
	level._effect[ "factory_intro_stab_blood_knife" ]							= loadfx( "vfx/moments/factory/factory_intro_stab_blood_knife" );
	level._effect[ "factory_intro_stab_blood_player" ]							= loadfx( "vfx/moments/factory/factory_intro_stab_blood_player" );
	level._effect[ "factory_intro_white_light_1200" ]							= loadfx( "vfx/moments/factory/factory_intro_white_light_1200" );
	level._effect[ "factory_moving_piece_light" ]								= loadfx( "vfx/moments/factory/factory_moving_piece_light" );
	level._effect[ "factory_moving_piece_light_flir2" ]							= loadfx( "vfx/moments/factory/factory_moving_piece_light" );
	level._effect[ "factory_presat_stadium_light" ]								= loadfx( "vfx/moments/factory/factory_presat_stadium_light" );
//	level._effect[ "factory_sat_blue_light" ]									= loadfx( "vfx/moments/factory/factory_sat_blue_light" );
	level._effect[ "factory_sat_floor_steam" ]									= loadfx( "vfx/moments/factory/factory_sat_floor_steam" );
	level._effect[ "factory_sat_studio_light" ]									= loadfx( "vfx/moments/factory/factory_sat_studio_light" );
	level._effect[ "factory_sat_tunnel_steam" ]									= loadfx( "vfx/moments/factory/factory_sat_tunnel_steam" );
//	level._effect[ "factory_sat_warm_light" ]									= loadfx( "vfx/moments/factory/factory_sat_warm_light" );
	level._effect[ "factory_single_drip" ]										= loadfx( "vfx/moments/factory/factory_single_drip" );
	level._effect[ "factory_single_splash" ]									= loadfx( "vfx/moments/factory/factory_single_splash" );
	level._effect[ "factory_water_splash_runner" ]								= loadfx( "vfx/moments/factory/factory_water_splash_runner" );
	level._effect[ "factory_water_splash_wave" ]								= loadfx( "vfx/moments/factory/factory_water_splash_wave" );
	level._effect[ "factory_water_splash_wave_bright" ]							= loadfx( "vfx/moments/factory/factory_water_splash_wave_bright" );
	level._effect[ "factory_water_spray_01" ]									= loadfx( "vfx/moments/factory/factory_water_spray_01" );
	level._effect[ "flashlight_spotlight" ]										= loadfx( "vfx/ambient/lights/flashlight_spotlight" );
	level._effect[ "flashlight_spotlight_flare" ]								= loadfx( "vfx/ambient/lights/flashlight_spotlight_flare" );
	level._effect[ "glow_green_light_30_nolight" ]								= loadfx( "vfx/ambient/lights/vfx_glow_green_light_30_nolight" );
	level._effect[ "glow_green_light_15_nolight" ]								= loadfx( "vfx/ambient/lights/vfx_glow_green_light_15_nolight" );
	level._effect[ "glow_red_light_100_blinker" ]								= loadfx( "vfx/ambient/lights/vfx_glow_red_light_100_blinker" );
	level._effect[ "glow_red_light_100_blinker_nolight" ]						= loadfx( "vfx/ambient/lights/vfx_glow_red_light_100_blinker_nolight" );
	level._effect[ "glow_red_light_100_nolight" ]								= loadfx( "vfx/ambient/lights/vfx_glow_red_light_100_nolight" );
	level._effect[ "glow_red_light_15_nolight" ]								= loadfx( "vfx/ambient/lights/vfx_glow_red_light_15_nolight" );
	level._effect[ "glow_red_light_30_blinker_nolight" ]						= loadfx( "vfx/ambient/lights/vfx_glow_red_light_30_blinker_nolight" );
	level._effect[ "glow_red_light_400_strobe" ]								= loadfx( "vfx/ambient/lights/vfx_glow_red_light_400_strobe" );
	level._effect[ "no_effect" ]												= loadfx( "vfx/ambient/misc/no_effect" );
	level._effect[ "leaf_green_light_wind_blue" ]								= loadfx( "vfx/ambient/trees/leaf_green_light_wind_blue" );
	level._effect[ "leaf_green_strong_wind_blue" ]								= loadfx( "vfx/ambient/trees/leaf_green_strong_wind_blue" );
	level._effect[ "leaf_palm_light_wind_blue" ]								= loadfx( "vfx/ambient/trees/leaf_palm_light_wind_blue" );
	level._effect[ "leaf_palm_strong_wind_blue" ]								= loadfx( "vfx/ambient/trees/leaf_palm_strong_wind_blue" );
	level._effect[ "lights_stadium_drizzle" ]									= loadfx( "vfx/ambient/weather/rain/lights_stadium_drizzle" );
	level._effect[ "lights_stadium_rain_soft" ]									= loadfx( "vfx/ambient/weather/rain/lights_stadium_rain_soft" );
	level._effect[ "parking_lot_double_light" ]									= loadfx( "vfx/ambient/lights/parking_lot_double_light" );
	level._effect[ "parking_lot_double_light_rain" ]							= loadfx( "vfx/ambient/lights/parking_lot_double_light_rain" );
	level._effect[ "rain_ground_100_runner" ]									= loadfx( "vfx/ambient/weather/rain/rain_ground_100_runner" );
	level._effect[ "rain_horizontal_150" ]										= loadfx( "vfx/ambient/weather/rain/rain_horizontal_150" );
	level._effect[ "rain_splash_100x100" ]										= loadfx( "vfx/ambient/weather/rain/rain_splash_100x100" );
	level._effect[ "rain_splash_200x200" ]										= loadfx( "vfx/ambient/weather/rain/rain_splash_200x200" );
	level._effect[ "rain_splash_20x20" ]										= loadfx( "vfx/ambient/weather/rain/rain_splash_20x20" );
	level._effect[ "rain_splash_puddle_50x50_runner" ]							= loadfx( "vfx/ambient/weather/rain/rain_splash_puddle_50x50_runner" );
	level._effect[ "raindrops_screen_3_0" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_3_0" );
	level._effect[ "raindrops_screen_3_1" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_3_1" );
	level._effect[ "raindrops_screen_3_2" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_3_2" );
	level._effect[ "raindrops_screen_3_3" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_3_3" );
	level._effect[ "raindrops_screen_3_4" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_3_4" );
	level._effect[ "raindrops_screen_5_0" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_5_0" );
	level._effect[ "raindrops_screen_5_1" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_5_1" );
	level._effect[ "raindrops_screen_5_2" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_5_2" );
	level._effect[ "raindrops_screen_5_3" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_5_3" );
	level._effect[ "raindrops_screen_5_4" ]										= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_5_4" );
	level._effect[ "raindrops_screen_10_0" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_10_0" );
	level._effect[ "raindrops_screen_10_1" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_10_1" );
	level._effect[ "raindrops_screen_10_2" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_10_2" );
	level._effect[ "raindrops_screen_10_3" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_10_3" );
	level._effect[ "raindrops_screen_10_4" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_10_4" );
	level._effect[ "raindrops_screen_20_0" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_20_0" );
	level._effect[ "raindrops_screen_20_1" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_20_1" );
	level._effect[ "raindrops_screen_20_2" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_20_2" );
	level._effect[ "raindrops_screen_20_3" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_20_3" );
	level._effect[ "raindrops_screen_20_4" ]									= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_20_4" );
	level._effect[ "rect_glow_120" ]											= loadfx( "vfx/ambient/lights/rect_glow_120" );
	level._effect[ "rect_glow_120_godray" ]										= loadfx( "vfx/ambient/lights/rect_glow_120_godray" );
	level._effect[ "rect_glow_300" ]											= loadfx( "vfx/ambient/lights/rect_glow_300" );
	level._effect[ "red_light_15_rain" ]										= loadfx( "vfx/ambient/lights/red_light_15_rain" );
	level._effect[ "red_light_15_rain_nolight" ]								= loadfx( "vfx/ambient/lights/red_light_15_rain_nolight" );
	level._effect[ "red_light_30_rain_oriented" ]								= loadfx( "vfx/ambient/lights/red_light_30_rain_oriented" );
	level._effect[ "red_light_30_rain_side_nolight" ]							= loadfx( "vfx/ambient/lights/red_light_30_rain_side_nolight" );
	level._effect[ "red_light_1200_strobe" ]									= loadfx( "vfx/ambient/lights/red_light_1200_strobe" );
	level._effect[ "smk_wispy_small_blue" ]										= loadfx( "vfx/ambient/smoke/smk_wispy_small_blue" );
	level._effect[ "smokestack_blue" ]											= loadfx( "vfx/ambient/smoke/smokestack_blue" );
	level._effect[ "smokestack_small_blue" ]									= loadfx( "vfx/ambient/smoke/smokestack_small_blue" );
	level._effect[ "smoky_fluorescent_light" ]									= loadfx( "vfx/ambient/lights/smoky_fluorescent_light" );
	level._effect[ "smoky_fluorescent_light_200_soft" ]							= loadfx( "vfx/ambient/lights/smoky_fluorescent_light_200_soft" );
	level._effect[ "smoky_fluorescent_light_soft" ]								= loadfx( "vfx/ambient/lights/smoky_fluorescent_light_soft" );
	level._effect[ "smoky_fluorescent_light_wall_soft" ]						= loadfx( "vfx/ambient/lights/smoky_fluorescent_light_wall_soft" );
	level._effect[ "steam_low" ]												= loadfx( "vfx/ambient/steam/steam_low" );
	level._effect[ "steam_low_small" ]											= loadfx( "vfx/ambient/steam/steam_low_small" );
	level._effect[ "steam_floor_vent_low" ]										= loadfx( "vfx/ambient/steam/steam_floor_vent_low" );
	level._effect[ "steam_jet_small" ]											= loadfx( "vfx/ambient/steam/steam_jet_small" );
	level._effect[ "steam_lazy_60" ]											= loadfx( "vfx/ambient/steam/steam_lazy_60" );
	level._effect[ "steam_wall_vent" ]											= loadfx( "vfx/ambient/steam/steam_wall_vent" );
	level._effect[ "welding_sparks_funner" ]									= loadfx( "vfx/ambient/sparks/welding_sparks_funner" );
	level._effect[ "splash_body_shallow" ]										= loadfx( "vfx/ambient/water/splash_body_shallow" );
	level._effect[ "splash_body_shallow_bigger" ]								= loadfx( "vfx/ambient/water/splash_body_shallow_bigger" );
	level._effect[ "white_light_100_nolight" ]									= loadfx( "vfx/ambient/lights/white_light_100_nolight" );
	level._effect[ "white_light_60_beam_nolight" ]								= loadfx( "vfx/ambient/lights/white_light_60_beam_nolight" );
	level._effect[ "white_light_60_soft_nolight" ]									= loadfx( "vfx/ambient/lights/white_light_60_soft_nolight" );

	level._effect[ "car_headlight_gaz_l_night" ]								= loadfx( "fx/misc/car_headlight_gaz_l_night" );
	level._effect[ "car_headlight_gaz_r_night" ]								= loadfX( "fx/misc/car_headlight_gaz_r_night" );
	level._effect[ "car_taillight_btr80_eye" ]									= loadfx( "fx/misc/car_taillight_btr80_eye" );
	
	level._effect[ "real_spot"			  ] = LoadFX( "fx/lights/lights_spotlight_modern_so_spotlight_castle" );
	level._effect[ "cheap_spot"			  ] = LoadFX( "fx/lights/lights_spotlight_long_castle" );
	level._effect[ "flashlight"			  ] = LoadFX( "fx/misc/flashlight" );
	// level._effect[ "lights_headlight"	  ] = LoadFX( "fx/lights/lights_headlight" );
	level._effect[ "office_muzzle_flash" ] = LoadFX( "fx/misc/factory_muzzle_light_big" );
	
	level._effect[ "lights_console_blue"			 ] = LoadFX( "fx/lights/fxlight_blue" );
	
	level._effect[ "spotlight_model_factory"		 ]	 = LoadFX( "fx/misc/spotlight_model_factory" );
	// level._effect[ "spotlight_model_factory_weapon" ] = LoadFX( "fx/misc/spotlight_model_factory_weapon" );

	level._effect[ "silencer_flash" ] 				= LoadFX( "fx/misc/factory_muzzle_light_big" );
	
	// level._effect[ "intro_takedown_light" ] = LoadFX( "fx/lights/factory_intro_takedown_light" );

	// level._effect[ "_attack_heli_spotlight" ] = LoadFX( "fx/misc/spotlight_large" );
	// level._effect[ "light_blowout"			] = LoadFX( "fx/explosions/tv_flatscreen_explosion" );
	
	// CF - Overall pass temp
	level._effect[ "airstrip_explosion"							] = LoadFX( "fx/explosions/airstrip_explosion" );
	level._effect[ "factory_rooftop_wind_gust"					] = LoadFX( "vfx/moments/factory/factory_rooftop_wind_gust" );
	level._effect[ "factory_rooftop_wind_gust_ground"			] = LoadFX( "vfx/moments/factory/factory_rooftop_wind_gust_ground" );
	// level._effect[ "bomb_explosion_ac130_bombing_run_dist_mega" ] = LoadFX( "fx/explosions/bomb_explosion_ac130_bombing_run_dist_mega" );
	// level._effect[ "ssn12_concrete_impact"						] = LoadFX( "fx/impacts/ssn12_concrete_impact" );
	// level._effect[ "wall_collapse_dust_wave_hamburg"			] = LoadFX( "fx/dust/wall_collapse_dust_wave_hamburg" );
	level._effect[ "water_pipe_spray_small"						] = LoadFX( "fx/water/water_pipe_spray_small" );
	level._effect[ "water_pipe_spray_wide"						] = LoadFX( "fx/water/water_pipe_spray_wide" );
	level._effect[ "heavy_drip_splash_floor"					] = LoadFX( "fx/water/heavy_drip_splash_floor" );
	level._effect[ "rain_splash_puddles_md"						] = LoadFX( "fx/weather/rain_splash_puddles_md" );
	level._effect[ "light_blink_forklift"						] = LoadFX( "fx/misc/light_blink_forklift" );
	//level._effect[ "footstep_splash_large" 						] = LoadFX( "fx/water/body_splash_prague" );
	level._effect[ "factory_single_splash_plr" 					] = loadfx( "vfx/moments/factory/factory_single_splash_plr" );

	// Ingress temp
	// level._effect[ "amb_dust_hangar"		] = LoadFX( "fx/dust/amb_dust_hangar" );
	// level._effect[ "amb_dust_int"			] = LoadFX( "fx/dust/amb_dust_int" );
	// level._effect[ "light_shaft_dust_large" ] = LoadFX( "fx/dust/light_shaft_dust_large" );
	
	// Ambush Temptemp
	// level._effect[ "powerline_runner"							  ] = LoadFX( "fx/explosions/powerline_runner" );
	// level._effect[ "electrical_transformer_spark_runner_loop_drk" ] = LoadFX( "fx/explosions/electrical_transformer_spark_runner_loop_drk" );

	// Lightning
	level._effect[ "lightning"			] = LoadFX( "fx/weather/lightning" );
	level._effect[ "lightning_bolt"		] = LoadFX( "fx/weather/lightning_bolt" );
	level._effect[ "lightning_bolt_lrg" ] = LoadFX( "fx/weather/lightning_bolt_lrg" );
	
	addLightningExploder( 10 ); // these exploders make lightning flashes in the sky
	addLightningExploder( 11 );
	addLightningExploder( 12 );
	level.nextLightning = GetTime() + 1;// 10000 + randomfloat( 4000 );// sets when the first lightning of the level will go off
	
	level._effect[ "rain_0"	 ] = loadfx( "vfx/ambient/misc/no_effect" );
	level._effect[ "rain_1"	 ] = loadfx( "vfx/ambient/weather/rain/rain_1" );
	level._effect[ "rain_2"	 ] = loadfx( "vfx/ambient/weather/rain/rain_1" );
	level._effect[ "rain_3"	 ] = loadfx( "vfx/ambient/weather/rain/rain_1" );
	level._effect[ "rain_4"	 ] = loadfx( "vfx/moments/factory/factory_rain_5" );
	level._effect[ "rain_5"	 ] = loadfx( "vfx/moments/factory/factory_rain_5" );
	level._effect[ "rain_6"	 ] = loadfx( "vfx/moments/factory/factory_rain_5" );
	level._effect[ "rain_7"	 ] = loadfx( "vfx/moments/factory/factory_rain_8" );
	level._effect[ "rain_8"	 ] = loadfx( "vfx/moments/factory/factory_rain_8" );
	level._effect[ "rain_9"	 ] = loadfx( "vfx/moments/factory/factory_rain_10" );
	level._effect[ "rain_10" ] = loadfx( "vfx/moments/factory/factory_rain_10" );

	thread rainInit( "none" ); // "none" "light" or "hard"
	thread factory_playerWeather();	// make the actual rain effect generate around the player
	
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\factory_fx::main();
		maps\createfx\factory_sound::main();
	}
}

fx_init()
{
	global_FX( "red_light_15_rain_nolight_FX_origin",	"vfx/ambient/lights/red_light_30_nolight",	-2 );
//	global_FX( "light_red_steady_FX_origin",			"vfx/ambient/lights/red_light_30_nolight",	-2 );
	flag_init( "fx_player_watersheeting" );
	flag_init( "fx_screen_raindrops" );
	flag_init( "fx_thermal_glitch" );
	flag_init( "factory_rooftop_wind_gust" );
	flag_init( "factory_rooftop_wind_gust_moment" );

//	animscripts\utility::setFootstepEffect( "concrete", 			loadfx( "fx/impacts/footstep_water" ) );
//	animscripts\utility::setFootstepEffectSmall( "concrete", 		loadfx( "fx/impacts/footstep_water" ) );
	animscripts\utility::setFootstepEffect( "grass", 				loadfx( "vfx/moments/factory/factory_footstep_water" ) );
	animscripts\utility::setFootstepEffectSmall( "grass", 			loadfx( "vfx/moments/factory/factory_footstep_water" ) );
	animscripts\utility::setFootstepEffect( "gravel", 				loadfx( "vfx/moments/factory/factory_footstep_water" ) );
	animscripts\utility::setFootstepEffectSmall( "gravel", 			loadfx( "vfx/moments/factory/factory_footstep_water" ) );


	// SSAO
//	r_ssao			 = Dvar_RegisterEnum( "r_ssao", r_ssaoNames, SSAO_MODE_LOW, DVAR_ARCHIVE | DVAR_LATCH, "Screen Space Ambient Occlusion mode" );
//	r_ssaoStrength	 = Dvar_RegisterFloat( "r_ssaoStrength", 1.2f, 0.0f, 8.0f, DVAR_CHEAT | DVAR_SAVED, "Strength of Screen Space Ambient Occlusion effect" );
//	r_ssaoPower		 = Dvar_RegisterFloat( "r_ssaoPower", 1.0f, 0.0f, 16.0f, DVAR_CHEAT | DVAR_SAVED, "Power curve applied to SSAO factor" );
//	r_ssaoBlurRadius = Dvar_RegisterFloat( "r_ssaoBlurRadius", 1.0f, 0.0f, 16.0f, DVAR_DEFAULT_FLAGS, "Apply gaussian blur with this radius to calculated SSAO values" );
//	r_ssaoDownsample = Dvar_RegisterBool( "r_ssaoDownsample", true, DVAR_DEFAULT_FLAGS, "Perform SSAO calculation on downsampled depth buffer" );
//	r_ssaoDebug		 = Dvar_RegisterEnum( "r_ssaoDebug", r_ssaoDebugNames, SSAO_DEBUG_DISABLED, DVAR_DEFAULT_FLAGS, "Render calculated or applied Screen Space Ambient Occlusion values" );

	fx_enable_ssao();
	
	// Thermal
	level.friendly_thermal_Reflector_Effect = level._effect[ "no_effect" ];
	level.assemblySmoke						= undefined;
	level.assemblySmokeFlir2				= undefined;
	level.assemblySmokePos					= ( 5434.46, -1387.37, 279.125 );
	level.smokeintensity					= 0;
	level.smokevolume						= GetEnt( "ambush_smoke_volume", "targetname" );
	
	SetSavedDvar( "r_thermalDetailScale", 0.375 );
	SetSavedDvar( "r_thermalFadeControl", 1 );
	SetSavedDvar( "r_thermalFadeColor"	, "0.19 0.43 0.19 1.0" );
	SetSavedDvar( "r_thermalFadeMin"	, 1300 );	// old value 800
	SetSavedDvar( "r_thermalFadeMax"	, 1301 );	// old value 1000

	if ( is_gen4() )
	{
		SetSavedDvar( "fx_alphathreshold", 1 );
		SetSavedDvar( "r_thermalColorOffset", 0.26);					// Temp fix for thermal in next_gen.
//		SetSavedDvar( "r_reactiveTurbulenceDrawEffectors", 1 );
	}
	else
	{
		SetSavedDvar( "fx_alphathreshold", 9 );
	}
	
//	level.thermalFadeMin	= 800;
//	level.thermalFadeMax	= 1000;
//	level.thermalFadeMinADS = 1200;
//	level.thermalFadeMaxADS = 1400;
	
	// Reactive
/*
	r_reactiveMotionWindDir - Controls the global wind direction. Steve: 3d vector -1 to 1 ( 1 -1 0 ) for example
	r_reactiveMotionWindStrength - Scale of the global wind direction . 1 = normal 50 = WINDY 1-- looks dumb. 
	r_reactiveMotionWindAreaScale - Scales distribution of wind motion . Steve: Makes the grass more bendy instead of stiff, Shouldnt go past 10ish.. 
	r_reactiveMotionWindAmplitudeScale - Scales amplitude of wind wave motion. Steve* How much the grass actually moves. .1 = subtle. 1 = Theres wind. 2 = WINDY. .  
	
	r_reactiveMotionPlayerRadius: Radial distance from the player that influences reactive motion models (inches) 
	r_reactiveMotionActorRadius: Radial distance from the ai characters that influences reactive motion models (inches) 
	r_reactiveMotionActorVelocityMax: AI velocity considered the maximum when determining the length of motion tails (inches/sec) 
	r_reactiveMotionVelocityTailScale: Additional scale for the velocity-based motion tails, as a factor of the effector radius
*/

	level.defaultReactiveWind					  = [];
	level.defaultReactiveWind[ "strength"		] = 1.0;
	level.defaultReactiveWind[ "amplitudeScale" ] = 1.2;
	level.defaultReactiveWind[ "frequencyScale" ] = 0.7;

	SetSavedDvar( "r_reactiveMotionWindStrength"	  , level.defaultReactiveWind[ "strength" ] );
	SetSavedDvar( "r_reactiveMotionWindAmplitudeScale", level.defaultReactiveWind[ "amplitudeScale" ] );
	SetSavedDvar( "r_reactiveMotionWindFrequencyScale", level.defaultReactiveWind[ "frequencyScale" ] );

	add_earthquake( "chase_quake_big", 0.6, 1.5, 4000 );
//	add_earthquake( "chase_quake_medium", 0.5, 1.3, 3500 );
	add_earthquake( "chase_quake_small", 0.4, 1.0, 2000 );
	
	level thread fx_ambient_setup();
	level thread fx_screen_raindrops();
}

lgt_intro_train_light()
{
	ent = Spawn( "script_model", ( 2080, 5420, 450 ) ); // node.origin );
    ent SetModel( "tag_origin" );
    //trigger_wait_targetname ( "trig_intro_vignette" );
    //IPrintLnBold("triggered");
    //PlayFXOnTag( level._effect[ "intro_takedown_light" ], ent, "tag_origin" );
    //ent waittill( "intro_kill_sequence_start" );
    //StopFXOnTag( level._effect[ "intro_takedown_light" ], ent, "tag_origin" );
    
    //flag_wait( "intro_kill_sequence_done" );
    //PlayFXOnTag( level._effect[ "intro_takedown_light" ], ent, "tag_origin" );
    //flag_wait( "player_entered_awning" );
    //IPrintLnBold("killed");
    //StopFXOnTag( level._effect[ "intro_takedown_light" ], ent, "tag_origin" );
  
}

lgt_assembly_flicker_anim ( lgt )
{
	val = lgt GetLightIntensity();
	lgt SetLightIntensity ( 0.01 );
	wait ( RandomFloatRange ( 2.0, 4.0 ) );
	lgt thread maps\_lights::generic_flickering();
	wait ( RandomFloatRange ( 6.0, 10.0 ) );
	lgt notify("stop_dynamic_light_behavior");
	lgt SetLightIntensity ( val );
}

lgt_ambush_begin()
{
	// Player is about to enter assembly line area
	// flag_wait( "reveal_room_player_at_exit" );

	ents = getentarray( "ambush", "targetname" );
	ents_tv = getentarray( "ambush_tv", "targetname" );
	ents_line = getentarray( "ambush_assembly_lights", "script_noteworthy" );
	foreach ( ent in ents )
	{
		ent SetLightIntensity ( 1.75 );
	}
	foreach ( ent in ents_tv )
	{
		ent SetLightIntensity ( 3.0 );
	}
	
	ents_cons = GetEntArray( "ambush_console", "targetname" );
	foreach ( ent in ents_cons )
	{
		ent = PlayFX( level._effect[ "lights_console_blue" ], ent.origin );
	}
		
	level waittill( "ambush_triggered" );
	wait 16.75;	
	foreach ( ent in ents )
	{
		ent SetLightIntensity ( 0.01 );
	}
	foreach ( ent in ents_tv )
	{
		ent SetLightIntensity ( 0.01 );
	}	
	wait 0.75;
	foreach ( ent in ents_line )
	{
		if ( maps\_lights::is_light_entity (ent) )
		{
			thread lgt_assembly_flicker_anim ( ent );
		}
	}
	flag_set( "lgt_factory_ambush_breach" );
}


fx_assembly_setup()
{
	Exploder( "assembly_ambient" );
	Exploder( "assembly_ambient_off_in_smoke" );

	// Green lights on welding bases.
	ents = GetEntArray( "factory_welding_base_01", "script_noteworthy" );
	foreach ( ent in ents )
	{
		PlayFXOnTag( level._effect[ "glow_green_light_30_nolight" ], ent, "tag_light_green" );
	}
}

lgt_vision_fog_init()
{
	flag_init( "lgt_factory_ambush_breach" );
	flag_init( "lgt_exit_weapon_room" );
	SetSavedDvar("r_sky_fog_intensity", 0.75);
	thread trigger_vf_intro();
	//thread trigger_vf_factory_reveal();
	thread trigger_vf_powerstealth();
	thread trigger_vf_presat();
	thread trigger_vf_weapon_reveal();
	thread trigger_vf_ambush();
	thread trigger_vf_ambush_breach();
	thread trigger_vf_chase();
}

trigger_vf_intro()
{	
	flag_wait( "lgt_playerkill_done");
	maps\_art::dof_enable_script( 6.87, 52.83, 5, 1000, 7000, 0.15, 0.6 );
	//SetViewModelDepthOfField(2, 7);
	
	flag_wait("lgt_playerkill_complete");
	maps\_art::dof_disable_script( 2.5 );
}

trigger_vf_factory_reveal()
{
	/*
	flag_wait( "factory_exterior_reveal" );
	maps\_utility::vision_set_fog_changes( "factory", 4 );
	
	flag_wait( "card_swiped" );
	wait 4;
	maps\_utility::vision_set_fog_changes( "factory_interior", 4 );
	wait 4.0;
	maps\_utility::vision_set_fog_changes( "", 4 );
	*/
}

trigger_vf_powerstealth()
{
	self endon ("presat_entrance");
	
	flag_wait_any( "entered_factory_1", "powerstealth_end", "lgt_weapon_room_jump" );
	//maps\_utility::vision_set_fog_changes( "", 0.4 );
	
	lgts = GetEntArray("lgt_powerstealth_racks", "script_noteworthy");
	small = false;
	//while (1)
	{
		flag_wait("lgt_flag_powerstealth");
		wait 0.1;
		rad = 20;
		
		if ( small == true )
		{
			rad = 800;
			small = false;
		}
		else
		{
			small = true;
		}
		
		//IPrintLnBold(rad);
		foreach (lgt in lgts)
		{
			lgt SetLightRadius ( rad );
		}		
	}
}

trigger_vf_presat()
{		
	//flag_wait( "presat_open_revolving_door" );
	flag_wait( "presat_entrance" );
	door_lgt = GetEnt("lgt_presat_revolving_door", "script_noteworthy");
	if (IsDefined(door_lgt))
	{
		door_lgt SetLightIntensity(2.5);
	}
	
	warning_door_lgt = GetEnt("lgt_presat_warning", "script_noteworthy");		
	if (IsDefined(warning_door_lgt))		
	{
		rotCount = RandomIntRange(5,7) * 8;
		warning_door_lgt SetLightIntensity(1.25);
		for ( i = 0 ; i < rotCount ; i++ )
		{
			warning_door_lgt RotateYaw(45,1);
		}
		warning_door_lgt SetLightIntensity ( 0.1 );
	}
}

AlphabetizeEntArray( array )
{
	if ( array.size <= 1 )
		return array;
	
/*
 * new_array = [];
new_array = array_add( new_array, new_item );
that will add new_item to array
The array order would be the order you add them, so you can presort them or whatever.

*/

	//get names
	arrayNames = [array.size];
	
	for( i = 0 ; i < array.size; i++ )
	{
		ent = array[i];
		if ( isDefined ( ent.targetname) )
		{
			arrayNames[i] = ent.targetname;
			//IPrintLnBold ( arrayNames[i] );
		}
		else
		{
			arrayNames[i] = "";
			//IPrintLnBold ( "" );
		}
	}
	
	//sort
	//iCount = 0;
	for ( asize = arrayNames.size - 1; asize >= 1; asize-- )
	{
		largest = arrayNames[asize];
		largestEnt = array[asize];
		
		largestIndex = asize;
		for ( i = 0; i < asize; i++ )
		{
			string1 = arrayNames[ i ];
			
			if ( StrICmp(string1, largest ) > 0 )
			{
				largest = string1;
				largestEnt = array[i];
				largestIndex = i;
			}
		}
		
		if(largestIndex != asize)
		{
			arrayNames[largestIndex] = arrayNames[asize];
			array[largestIndex] = array[asize];
			arrayNames[asize] = largest;
			array[asize] = largestEnt;
		}
	}

	return array;
}


//Based on 'changeLightColorTo' in _lights.gsc
changeLightIntensityOverTime( targetIntensity, time )
{	
	startIntensity = self GetLightIntensity();	
	
	incs = Int( time / .05 );

	incIntensity = ( targetIntensity - startIntensity ) / incs ;
	curIntensity = startIntensity;
	for ( i = 0; i < incs; i++ )
	{
		curIntensity += incIntensity;
		self SetLightIntensity( curIntensity );
		wait .05;
	}
		
	self SetLightIntensity( targetIntensity );
}

trigger_vf_weapon_reveal()
{
	if ( is_gen4() )
	{
		lgt_weapon_reveal_sequence_ng();
	}
	else
	{
		lgt_weapon_reveal_sequence();
	}
}

lgt_weapon_rim_dim( rim_lgts, rim_keep_lgts )
{
	foreach (lgt in rim_lgts)
	{
		lgt thread changeLightIntensityOverTime( 0.2, 2.0 );
		//lgt SetLightRadius ( 20 );
	}
	foreach (lgt in rim_keep_lgts)
	{
		lgt thread changeLightIntensityOverTime( 0.1, 2.0 );
		//lgt SetLightRadius ( 800 );		
	}
	wait 2.0;	
	foreach (lgt in rim_lgts)
	{
		lgt SetLightRadius ( 20 );
	}
}

lgt_weapon_reveal_sequence()
{
	door_lgts = GetEntArray("lgt_sat_room_amber", "script_noteworthy");	
	rim_lgts = GetEntArray( "lgt_sat_room_rim", "script_noteworthy" );
	
	flag_wait( "lgt_weapon_room_jump" );
	wait 2;
	foreach ( lgt in door_lgts)
	{
		lgt thread changeLightIntensityOverTime( 1.5, 1.0 );
	}

//	Exploder( "lgt_sat_room_rim" );
	flag_wait( "lgt_weapon_sequencing" );
	
	/*Grab the rim lights and turn off*/
	wait 0.5;
	sat_lgts = GetEntArray( "lgt_weapon_room_01", "script_noteworthy" );
	foreach ( lgt in sat_lgts )
	{
		lgt SetLightIntensity (4.5);
	}

//	Exploder( "lgt_weapon_room_01" );
	
	wait 0.6;
	sat_lgts = GetEntArray( "lgt_weapon_room_02", "script_noteworthy" );
	foreach ( lgt in sat_lgts )
	{
		lgt SetLightIntensity (5);
	}
	
//	Exploder( "lgt_weapon_room_02" );
	
	foreach (lgt in rim_lgts)
	{
		lgt thread changeLightIntensityOverTime( 0.01, 2.0 );	
		lgt SetLightRadius ( 20 );
	}
	
//	Stop_Exploder( "lgt_sat_room_rim" );

	wait 0.6;
	sat_lgts = GetEntArray( "lgt_weapon_room_03", "script_noteworthy" );
	foreach ( lgt in sat_lgts )
	{
		lgt SetLightIntensity (3.5);
	}
	
//	Exploder( "lgt_weapon_room_03" );
	
	wait 0.6;
	sat_lgts = GetEntArray( "lgt_weapon_room_04", "script_noteworthy" );
	foreach ( lgt in sat_lgts )
	{
		lgt SetLightIntensity (4);
	}	
//	Exploder( "lgt_weapon_room_04" );	
}

lgt_weapon_reveal_sequence_ng()
{	
	door_lgts = GetEntArray("lgt_sat_room_amber", "script_noteworthy");	
	rim_lgts = GetEntArray( "lgt_sat_room_rim", "script_noteworthy" );
	rim_keep_lgts = GetEntArray( "lgt_sat_room_rim_keep", "script_noteworthy" );
	foreach (lgt in rim_lgts)
	{
		lgt SetLightIntensity (0.85);
	}
	foreach (lgt in rim_keep_lgts)
	{
		lgt SetLightIntensity (0.85);
	}

//	Exploder( "lgt_sat_room_rim" );
	flag_wait( "lgt_weapon_room_jump" );
		
	wait 4.5;
	foreach ( lgt in door_lgts)
	{
		lgt thread changeLightIntensityOverTime( 3.0, 0.75 );
	}
	
	flag_wait( "lgt_weapon_sequencing" );

	wait 1;
	thread lgt_weapon_rim_dim( rim_lgts, rim_keep_lgts );
	sat_lgts = GetEntArray( "lgt_weapon_room_01", "script_noteworthy" );
	foreach ( lgt in sat_lgts )
	{		
		val = (lgt GetLightIntensity()) * 20;
		lgt SetLightIntensity (3.0);
	}
//	Exploder( "lgt_weapon_room_01" );

	wait 1;
	//sat_lgts = GetEntArray( "lgt_weapon_room_02", "script_noteworthy" );
	//foreach ( lgt in sat_lgts )
	//{
	//	lgt thread changeLightIntensityOverTime( 4.0, 0.25 );
	//	val = (lgt GetLightIntensity()) * 20;
	//}
	
	wait 1;
	sat_lgts = GetEntArray( "lgt_weapon_room_03", "script_noteworthy" );
	foreach ( lgt in sat_lgts )
	{
		lgt thread changeLightIntensityOverTime( 4.5, 0.1 );
		val = (lgt GetLightIntensity()) * 40;
		//lgt thread changeLightIntensityOverTime ( val, 0.2 );
	}
//	Exploder( "lgt_weapon_room_03" );

	wait 1;
	sat_lgts = GetEntArray( "lgt_weapon_room_04", "script_noteworthy" );
	foreach ( lgt in sat_lgts )
	{
		val = (lgt GetLightIntensity()) * 20;
		//lgt SetLightIntensity ( val );
		lgt SetLightIntensity (6);
	}	
//	Exploder( "lgt_weapon_room_04" );
//	Stop_Exploder( "lgt_sat_room_rim" );
}

trigger_vf_ambush()
{
	flag_wait_any( "lgt_ambush_jump", "sat_room_clear");
	maps\_utility::vision_set_fog_changes( "factory_ambush", 1 );
	thread lgt_ambush_begin();
}

trigger_vf_ambush_breach()
{
	flag_wait( "lgt_factory_ambush_breach" );
	maps\_utility::vision_set_fog_changes( "", 1 );
}

trigger_vf_chase()
{
}

fx_track_thermal()
{
	//level thread fx_thermal_glitch();
	//level thread fx_thermal_glitch_flashbangs();
	level thread fx_thermal_glitch_flashbang_spotlight();
	thermalOn = false;
	
	for ( ;; )
	{
		if ( level.player.thermal )
		{
/*
			if ( level.player isADS() )
			{
				SetSavedDvar( "r_thermalFadeMin", level.thermalFadeMinADS );
				SetSavedDvar( "r_thermalFadeMax", level.thermalFadeMaxADS );
			}
			else
			{
				SetSavedDvar( "r_thermalFadeMin", level.thermalFadeMin );
				SetSavedDvar( "r_thermalFadeMax", level.thermalFadeMax );
			}
*/

			if ( !thermalOn )
			{
				thermalOn = true;
				SetExpFog( 0, 110, 0.4, 0.4, 0.4, 0, 0 );									// Fog off.
				SetSavedDvar( "r_cc_mode", "clut" );
				stop_exploder( "assembly_ambient_off_in_thermal" );
			}
		}
		else if ( thermalOn )
		{
			thermalOn = false;
			
			if ( IsDefined( level.smokevolume ) && level.player IsTouching( level.smokevolume ) )
		    {
				SetExpFog( 0, 110, 0.4, 0.4, 0.4, level.smokeintensity, 0 );					// Fog on.
			}
			    
			SetSavedDvar( "r_cc_mode", "off" );
			exploder( "assembly_ambient_off_in_thermal" );
		}

		wait 0.05;
	}
}

// This relies on bias2 being 0.0 or 1.0.
fx_thermal_glitch_transition( bias1, bias2, lerp1, lerp2 )
{
	self endon( "fx_thermal_glitch" );
	
	curBias1 = getdvarvector( "r_cc_toneBias1" );
	curBias2 = getdvarvector( "r_cc_toneBias2" );
	curLerp1 = GetDvarInt( "r_cc_lerp1" );
	curLerp2 = GetDvarInt( "r_cc_lerp2" );
	
	diff = 0.1 * Int( 10.0 * abs( curBias2[ 0 ] - bias2[ 0 ] ) );
	
	while ( diff >= 0.05 )
	{
		diff -= 0.05;
		frac = 1.0 - diff;
		
		SetSavedDvar( "r_cc_toneBias1", VectorLerp( curBias1, bias1, frac ) );
		SetSavedDvar( "r_cc_toneBias2", VectorLerp( curBias2, bias2, frac ) );
		SetSavedDvar( "r_cc_lerp1"	  , ( curLerp1 + ( frac * ( curLerp1 - lerp1 ) ) ) );
		SetSavedDvar( "r_cc_lerp2"	  , ( curLerp2 + ( frac * ( curLerp1 - lerp2 ) ) ) );
		wait 0.05;
	}
	
	SetSavedDvar( "r_cc_toneBias1", bias1 );
	SetSavedDvar( "r_cc_toneBias2", bias2 );
	SetSavedDvar( "r_cc_lerp1"	  , lerp1 );
	SetSavedDvar( "r_cc_lerp2"	  , lerp2 );
}

// Thermal vision is blown out by flashbangs or spotlight for a duration
fx_thermal_glitch_flashbang_spotlight()
{
	level endon( "stop_thermal_glitch" );
	level.player endon( "end_thermal" );
	glitch_time_flashbang			  = 8;
	glitch_time_spotlight			  = 4;
	glitch_time						  = glitch_time_flashbang;
	level.player.thermal_blind_status = "";

	while ( 1 )
	{
		// Wait for the player to get flashed or blinded by spotlight
		event = level.player waittill_any_return( "flashed", "spotlight_blind" );
		
		// Only do anything if thermal is turned on
		if ( level.player.thermal && IsAlive( level.player ) )
		{
			// Determine the type
			if ( event == "flashed" )
			{
				glitch_time = glitch_time_flashbang;
			}
			else if ( event == "spotlight_blind" )
			{
				glitch_time = glitch_time_spotlight;
			}

			// Apply blind
			if ( level.player.thermal_blind_status != "blind" )
			{
				//iprintlnbold( "start blind" );
				// Start the transition to broken thermal
				flag_set( "fx_thermal_glitch" );
				wait 0.01;

				level.player VisionSetThermalForPlayer( "factory_thermal_blowout_1", 0.0 );
				flag_clear( "fx_thermal_glitch" );
				level thread fx_thermal_glitch_transition( ( 0.5, 0.5, 0.5 ), ( 1.0, 1.0, 1.0 ), 0, 5000 );

				// Spawn the reset script
				level.player thread fx_thermal_glitch_timer( glitch_time );

				level.player.thermal_blind_status = "blind";	
			}
			// Already was blinded - refresh blind
			else if ( level.player.thermal_blind_status == "blind" )
			{
				//iprintlnbold( "reblind" );
				level.player notify( "reset_blind_timer" );
				level.player thread fx_thermal_glitch_timer( glitch_time );
			}
		}
		wait 0.1;
	}
}

fx_thermal_glitch_timer( delay )
{
	self endon( "reset_blind_timer" );
	wait delay;

	// Return view to normal
	flag_set( "fx_thermal_glitch" );
	wait 0.01;

	level.player VisionSetThermalForPlayer( "thermal_mp", 0.0 );
	flag_clear( "fx_thermal_glitch" );
	level thread fx_thermal_glitch_transition( ( 0.0, 0.0, 0.0 ), ( 0.0, 0.0, 0.0 ), 0, 500 );
	level.player.thermal_blind_status = "normal";
	
	// Temp fix to set vision set after getting flashbanged in ambush.
	wait 1.0;
	maps\_utility::vision_set_fog_changes( "factory_ambush_breach", 2 );
}

fx_ambush_spawn_assembly_smoke()
{
	gasNodes = GetEntArray( "gas_node", "targetname" );
	
	foreach ( node in gasNodes )
	{
		PlayFX( level._effect[ "factory_ambush_smoke_grenade" ], node.origin, ( 0, 0, 1 ), ( 1, 0, 0 ) );
	}
	
	// Regular smoke.
	wait 0.05;
	level.assemblySmoke = Spawn( "script_model",  level.assemblySmokePos);
	level.assemblySmoke SetModel( "tag_origin" );
	level.assemblySmoke AddPitch( 270 );
	PlayFXOnTag( level._effect[ "factory_ambush_assembly_smoke" ], level.assemblySmoke, "tag_origin" );
	thread maps\factory_audio::ambush_smoke_grenade_explo_sfx();

	wait 0.05;
	level.assemblySmokeFlir2 = Spawn( "script_model", level.assemblySmokePos );
	level.assemblySmokeFlir2 SetModel( "tag_origin" );
	level.assemblySmokeFlir2 AddPitch( 270 );
	PlayFXOnTag( level._effect[ "factory_ambush_assembly_smoke_flir2" ], level.assemblySmokeFlir2, "tag_origin" );

	level.smokeintensity = 0.6;
	level thread fx_ambush_smoke_killer();
	SetExpFog( 0, 110, 0.4, 0.4, 0.4, 0, 0.05 );						// Start fog.
	wait 0.05;
	SetExpFog( 0, 110, 0.4, 0.4, 0.4, level.smokeintensity, 8 );
	
	// Kill strobe lights, etc.
	wait 3;
	fx_disable_ssao();													// Assmes that the flashbang will cover this pop.
	stop_exploder( "ambush_door_exploder_strobe" );
	stop_exploder( "assembly_ambient_off_in_smoke" );
}

// Turns off the smoke particles when the encounter is over.
fx_ambush_smoke_killer()
{
	flag_wait( "ambush_stop_smoke" );
	
	fx_enable_ssao();					// Assmes that the flashbang will cover this pop.
	
	// Kill smoke.
	if ( IsDefined( level.assemblySmoke ) )
	{
		StopFXOnTag( level._effect[ "factory_ambush_assembly_smoke" ], level.assemblySmoke, "tag_origin" );
	}

	if ( IsDefined( level.assemblySmokeFLIR2 ) )
	{
		StopFXOnTag( level._effect[ "factory_ambush_assembly_smoke_flir2" ], level.assemblySmokeFlir2, "tag_origin" );
	}

	if ( IsDefined( level.smokevolume ) && level.player IsTouching( level.smokevolume ) )
	{
		while ( level.smokeintensity >= 0.05 )
		{
			level.smokeintensity = level.smokeintensity - 0.05;
			
			if ( !level.player.thermal )
			{
				SetExpFog( 0, 110, 0.4, 0.4, 0.4, level.smokeintensity, 0.1 );
			}

			wait 0.1;
		}
	}
	
	level.smokeintensity = 0;
	exploder( "assembly_ambient_off_in_smoke" );
	
	// Temp fix to set vision set after getting flashbanged in ambush.
	maps\_utility::vision_set_fog_changes( "factory_ambush_breach", 2 );
}

fx_ambush_welding_start( guy )
{
	if ( !IsDefined( level.flag[ guy.animname ] ) )
	{
		flag_init( guy.animname );
	}

	// JR - Fix for queued up sparks
	if ( !flag( "factory_assembly_line_resume_speed_front" ) && !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		// No sparks yet!
		return;
	}
	
	flag_clear( guy.animname );

	i = 0;
	
	while ( IsDefined( guy) && !flag( guy.animname ) )
	{
		// Only show sparks if the anim speed up is done
		if ( flag( "factory_assembly_line_resume_speed_front" ) && flag( "factory_assembly_line_resume_speed_back" ) )
		{
			PlayFXOnTag( level._effect[ "welding_sparks_funner" ], guy, "tag_fx_01" );
		}
		
		// The welding runners each last 500ms, thus PlayFXOnTag needs to be called every 0.5 seconds.
		wait 0.5;
	}

	if ( IsDefined( guy ) )
	{
		KillFXOnTag( level._effect[ "welding_sparks_funner" ], guy, "tag_fx_01" );
	}
}

fx_ambush_welding_stop( guy )
{
	flag_set( guy.animname );
	StopFXOnTag( level._effect[ "welding_sparks_funner" ]	   , guy, "tag_fx_01" );
}

fx_ambush_piece_start( guy )
{
	f = "piece" + guy.mover_prefab_id;
		
	if ( !IsDefined( level.flag[ f ] ) )
	{
		flag_init( f );
	}

	// JR - Fix for queued up sparks
	if ( !flag( "factory_assembly_line_resume_speed_front" ) || !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		// No sparks yet!
		return;
	}
	
	flag_clear( f );
/*
	while ( 1 )
	{
		// Only show sparks if the anim speed up is done
		if ( flag( "factory_assembly_line_resume_speed_front" ) && flag( "factory_assembly_line_resume_speed_back" ) )
		{
			if ( level.player.thermal ) {
				KillFXOnTag( level._effect[ "factory_moving_piece_light" ], guy, "j_anim_jnt_main_piston_arm_btm" );
				PlayFXOnTag( level._effect[ "factory_moving_piece_light_flir2" ], guy, "j_anim_jnt_main_piston_arm_btm" );
			}
			else {
				KillFXOnTag( level._effect[ "factory_moving_piece_light_flir2" ], guy, "j_anim_jnt_main_piston_arm_btm" );
				PlayFXOnTag( level._effect[ "factory_moving_piece_light" ], guy, "j_anim_jnt_main_piston_arm_btm" );
			}
			
			// The runners each last 500ms, thus PlayFXOnTag needs to be called every 0.5 seconds.
			wait 0.5;
		}
	}
*/
	while ( !flag( f ) )
	{
		if ( level.player.thermal )
		{
			PlayFXOnTag( level._effect[ "factory_moving_piece_light_flir2" ], guy, "j_anim_jnt_main_piston_arm_btm" );
		}
		else {
			PlayFXOnTag( level._effect[ "factory_moving_piece_light" ], guy, "j_anim_jnt_main_piston_arm_btm" );
		}
		
		wait 0.5;
	}
}

fx_ambush_piece_stop( guy )
{
	flag_set( "piece" + guy.mover_prefab_id );
	StopFXOnTag( level._effect[ "factory_moving_piece_light" ]		, guy, "j_anim_jnt_main_piston_arm_btm" );
	StopFXOnTag( level._effect[ "factory_moving_piece_light_flir2" ], guy, "j_anim_jnt_main_piston_arm_btm" );
}

fx_ambush_chest_blood( guy )
{
	blood = spawn_tag_origin();
//	blood.origin = (guy GetTagOrigin( "j_pectoral_le" ) ) + ( 0, 148, 0 );
//	blood LinkTo( guy );
	blood LinkTo( guy, "j_pectoral_le", ( 0, -5, 0 ), ( 0, 270, 0 ) );
	PlayFXOnTag( level._effect[ "factory_ambush_chest_blood" ], blood, "tag_origin" );
}

// Swap the card reader.
fx_assembly_cardreader_unlock( guy )
{
	stop_exploder( "assembly_cardreader_lock" );
	exploder( "assembly_cardreader_unlock" );
	fx_show_hide( "assembly_cardreader_unlock", "assembly_cardreader_lock" );
}

fx_ambient_setup()
{
	level.fx_outdoor_triggers = [];
	
	array_thread( GetEntArray( "fx_intro_ambient", "targetname" ), ::fx_intro_ambient );
	array_thread( GetEntArray( "fx_entrance_ambient", "targetname" ), ::fx_entrance_ambient );
	array_thread( GetEntArray( "fx_powerstealth_ambient", "targetname" ), ::fx_powerstealth_ambient );
	array_thread( GetEntArray( "fx_presat_ambient", "targetname" ), ::fx_presat_ambient );
	array_thread( GetEntArray( "fx_sat_ambient", "targetname" ), ::fx_sat_ambient );
	array_thread( GetEntArray( "fx_roof_ambient", "targetname" ), ::fx_roof_ambient );
	array_thread( GetEntArray( "fx_chase_ambient", "targetname" ), ::fx_chase_ambient );
	
	level thread fx_outdoor_ambient();
}

fx_intro_ambient()
{
	level.fx_outdoor_triggers[ level.fx_outdoor_triggers.size ] = self;
	
	for ( ;; )
	{
		self waittill( "trigger" );
		
		exploder( "intro_ambient" );
		
		if( is_gen4() )
		{
			exploder( "intro_ambient_ng" );
		}

		while ( level.player IsTouching( self ) )
		{
			wait 0.1;
		}
		
		stop_exploder( "intro_ambient" );
		stop_exploder( "intro_ambient_ng" );
	}
}

fx_entrance_ambient()
{
	for ( ;; )
	{
		self waittill( "trigger" );
		
		exploder( "entrance_ambient" );

		while ( level.player IsTouching( self ) )
		{
			wait 0.1;
		}
		
		stop_exploder( "entrance_ambient" );
	}
}

fx_powerstealth_ambient()
{
	for ( ;; )
	{
		self waittill( "trigger" );
		
		exploder( "powerstealth_ambient" );

		while ( level.player IsTouching( self ) )
		{
			wait 0.1;
		}
		
		stop_exploder( "powerstealth_ambient" );
	}
}

fx_presat_ambient()
{
	for ( ;; )
	{
		self waittill( "trigger" );
		
		exploder( "presat_ambient" );

		while ( level.player IsTouching( self ) )
		{
			wait 0.1;
		}
		
		stop_exploder( "presat_ambient" );
	}
}

fx_sat_ambient()
{
	for ( ;; )
	{
		self waittill( "trigger" );
		
		exploder( "sat_ambient" );

		if( is_gen4() )
		{
			exploder( "sat_ambient_ng" );
		}

		while ( level.player IsTouching( self ) )
		{
			wait 0.1;
		}
		
		stop_exploder( "sat_ambient" );
		stop_exploder( "sat_ambient_ng" );
	}
}

fx_roof_ambient()
{
	level.fx_outdoor_triggers[ level.fx_outdoor_triggers.size ] = self;

	for ( ;; )
	{
		self waittill( "trigger" );
		
		exploder( "roof_ambient" );
		
		while ( level.player IsTouching( self ) )
		{
			wait 0.1;
		}

		stop_exploder( "roof_ambient" );
	}
}

fx_chase_ambient()
{
	level.fx_outdoor_triggers[ level.fx_outdoor_triggers.size ] = self;

	for ( ;; )
	{
		self waittill( "trigger" );
		
		exploder( "chase_ambient" );
		exploder( "chase_intro_lamp_on" );
		
		while ( level.player IsTouching( self ) )
		{
			wait 0.1;
		}

		stop_exploder( "chase_ambient" );
		stop_exploder( "chase_intro_lamp_on" );
	}
}

fx_outdoor_ambient()
{
	lastTouch = false;
	
	for  ( ;; )
	{
		touching = false;
		
		foreach ( e in level.fx_outdoor_triggers )
		{
			touching = touching || level.player IsTouching( e );
		}
		
		if ( touching != lastTouch )
		{
			if ( touching )
			{
				exploder( "outdoor_ambient" );
				exploder( "smokestacks" );
				exploder( "smokestack_big" );
				exploder( "smokestack_small" );
			}
			else
			{
				stop_exploder( "outdoor_ambient" );
				stop_exploder( "smokestacks" );
				stop_exploder( "smokestack_big" );
				stop_exploder( "smokestack_small" );
			}
			
			lastTouch = touching;
		}
		
		wait 0.1;
	}
}

fx_intro_rain()
{
	Exploder( "lights_rain_cards" );
//	Exploder( "lights_rain_cards_drizzle" );
	
	flag_wait( "entered_conveyor" );
	
	Stop_Exploder( "lights_rain_cards" );
//	Stop_Exploder( "lights_rain_cards_drizzle" );
}

// Swap the card reader.
fx_intro_cardreader_unlock( guy )
{
	stop_exploder( "intro_cardreader_lock" );
	exploder( "intro_cardreader_unlock" );
	fx_show_hide( "intro_cardreader_unlock", "intro_cardreader_lock" );
}

fx_set_wind( strength, amplitudeScale, frequencyScale, t )
{
					   //   name 							      value 	      time   
	thread lerp_savedDvar( "r_reactiveMotionWindStrength"	   , strength	   , t );
	thread lerp_savedDvar( "r_reactiveMotionWindAmplitudeScale", amplitudeScale, t );
	thread lerp_savedDvar( "r_reactiveMotionWindFrequencyScale", frequencyScale, t );
}

fx_show_hide( showName, hideName )
{
	if ( IsDefined( showName ) )
	{
		ents = GetEntArray( showName, "targetname" );
		
		foreach ( e in ents )
		{
			e Show();
		}
	}
	
	if ( IsDefined( hideName ) )
	{
		ents = GetEntArray( hideName, "targetname" );
		
		foreach ( e in ents )
		{
			e Hide();
		}
	}
}

fx_show_delete( showName, deleteName )
{
	if ( IsDefined( showName ) )
	{
		ents = GetEntArray( showName, "targetname" );
		
		foreach ( e in ents )
		{
			e Show();
		}
	}
	
	if ( IsDefined( deleteName ) )
	{
		ents = GetEntArray( deleteName, "targetname" );
		
		foreach ( e in ents )
		{
			e Delete();
		}
	}
}

lightning_flash( dir, num, type )
{
	//IPrintLnBold ("lightning flash call");

	level notify( "emp_lighting_flash" );
	level endon( "emp_lighting_flash" );
	
	if ( level.createFX_enabled )
		return;

	num = 1;
	if ( !IsDefined( level.old_type ) )
		level.old_type = 9;
	if ( !IsDefined( dir ) )
		dir = ( -20, 60, 0 );
	
	//level.player delaythread (2, ::play_sound_on_entity, "elm_factory_thunder");
	//level.player playsound( "elm_factory_thunder" );

	//SetSunDirection(dir);
	
	// if a type is passed, do not randomly choose a flash pattern
	if ( !IsDefined( type ) )
	{
		type = RandomInt( 10 );
		// don't allow repeats of the same type when doing random pattern choices
		if (type == level.old_type)
		{
			//IPrintLnBold ("return");
			return;
		}
	}
	//IPrintLnBold ("type:"+type+" oldtype:"+level.old_type);
	level.old_type = type;
	
	if ( is_gen4() )
	{
		mult = 6.00;
		switch( type )
	    {
	    	case 0:
				lightning_single_flash( 1.5 * mult, 1.5 * mult, 1.8 * mult, 0.8, 3);
				lightning_single_flash( 1.7 * mult, 1.7 * mult, 2.1 * mult, 1.0, 3);
				lightning_single_flash( 1.5 * mult, 1.5 * mult, 1.8 * mult, 0.8, 9);
				lightning_single_flash( 3.2, 3.2, 3.6, 1.0, 3);
		   		lightning_normal();
				wait RandomFloatRange (1,5);
	    		break;
	    	case 1:
				lightning_single_flash( 1.7 * mult, 1.7 * mult, 2.1 * mult, 1.0, 6);
				lightning_single_flash( 1.0 * mult, 1.0 * mult, 1.3 * mult, 0.8, 9);
				lightning_single_flash( 1.9 * mult, 1.9 * mult, 2.4 * mult, 0.8, 6);
				lightning_single_flash( 1.0 * mult, 1.0 * mult, 1.3 * mult, 1.0, 3);
		   		lightning_normal();
				wait RandomFloatRange (1,4);
	    		break;
	    	case 2:
				lightning_single_flash( 1.5 * mult, 1.5 * mult, 1.8 * mult, 1.0, 6);
		   		lightning_normal();
				wait RandomFloatRange (0.1,2);
	    		break;
	    	case 3:
				lightning_single_flash( 1.7 * mult, 1.7 * mult, 2.1 * mult, 1.0, 6);
		   		lightning_normal();
				wait RandomFloatRange (0.3,2);
	    		break;
	    	case 4:
				lightning_single_flash( 1.9 * mult, 1.9 * mult, 2.3 * mult, 1.0, 6);
		   		lightning_normal();
				wait RandomFloatRange (0.3,2);
	    		break;
	    	case 5:
				lightning_single_flash( 1.0 * mult, 1.0 * mult, 1.3 * mult, 0.8, 3);
				lightning_single_flash( 1.0 * mult, 1.0 * mult, 1.3 * mult, 0.8, 3);
		   		lightning_normal();
				wait RandomFloatRange (0.4,4);
	    		break;
	    	case 6:
	    	case 7:
	    	case 8:
	    	case 9:
		   		num = RandomIntRange( 1, 3 );
			    for ( i = 0; i < num; i++ )
			    {
			    	lightning_single_flash( 0.7 * mult, 0.7 * mult, 0.9 * mult, 1.0, RandomFloatRange(2,9));
			    }
		   		lightning_normal();
				wait RandomFloatRange (0.1,2);
	    		break;
		}

	}
	else
	{
		switch( type )
	    {
	    	case 0:
				lightning_single_flash( 0.5, 0.5, 0.8, 0.8, 3);
				lightning_single_flash( 0.5, 0.6, 0.8, 1.0, 3);
				lightning_single_flash( 0.5, 0.6, 0.8, 0.8, 9);
				lightning_single_flash( 1.7, 1.7, 1.9, 1.0, 3);
		   		lightning_normal();
				wait RandomFloatRange (1,5);
	    		break;
	    	case 1:
				lightning_single_flash( 1.7, 1.7, 1.9, 1.0, 6);
				lightning_single_flash( 0.5, 0.5, 0.8, 0.8, 9);
				lightning_single_flash( 1.7, 1.7, 1.9, 0.8, 6);
				lightning_single_flash( 0.8, 0.9, 1.2, 1.0, 3);
		   		lightning_normal();
				wait RandomFloatRange (1,4);
	    		break;
	    	case 2:
				lightning_single_flash( 0.5, 0.5, 0.8, 1.0, 6);
		   		lightning_normal();
				wait RandomFloatRange (0.1,2);
	    		break;
	    	case 3:
				lightning_single_flash( 1.0, 1.0, 1.5, 1.0, 6);
		   		lightning_normal();
				wait RandomFloatRange (0.3,2);
	    		break;
	    	case 4:
				lightning_single_flash( 1.2, 1.2, 1.5, 1.0, 6);
		   		lightning_normal();
				wait RandomFloatRange (0.3,2);
	    		break;
	    	case 5:
				lightning_single_flash( 0.8, 0.8, 1.2, 0.8, 3);
				lightning_single_flash( 0.8, 0.8, 1.2, 0.8, 3);
		   		lightning_normal();
				wait RandomFloatRange (0.4,4);
	    		break;
	    	case 6:
	    	case 7:
	    	case 8:
	    	case 9:
		   		num = RandomIntRange( 1, 3 );
			    for ( i = 0; i < num; i++ )
			    {
			    	lightning_single_flash( 0.7, 0.7, 0.9, 1.0, RandomFloatRange(2,12));
			    }
		   		lightning_normal();
				wait RandomFloatRange (0.1,2);
	    		break;				
	    	/*
			//OLD CASES
			case 0:
	    		wait( 0.05 );
			    SetSunLight( 1, 1, 1.1 );	
			    wait( 0.05 );
			    SetSunLight( 1.25, 1.22, 1.35 );
	    		break;

	    	case 1:
	    		wait( 0.05 );  
			    SetSunLight( 1, 1, 1.1 );	
			    wait( 0.05 );
			    SetSunLight( 1.25, 1.23, 1.35 );
			   	wait( 0.05 );
			    SetSunLight( 1.7, 1.7, 1.9 );
	    		break;

	    	case 2:
	    		wait( 0.05 );
			    SetSunLight( 1, 1, 1.15 );
			    wait( 0.05 );
			    SetSunLight( 1.25, 1.25, 1.3 );
			   	wait( 0.05 );
			    SetSunLight( 1.7, 1.65, 1.9 );					    
			    wait( 0.05 );		
			    SetSunLight( 1.25, 1.2, 1.35 );
	    		break;
	    		*/
	    }
	}
	
    wait RandomFloatRange( 0.05, 0.061 );
		lightning_normal();
}

lightning_single_flash( R_value, G_value, B_value, ramp_percentage, ramp_down_frames)
{
	level.defaultSunLight = GetMapSunLight();
	//IPrintLnBold ("sunlight R:"+level.defaultSunLight[0]+", B:"+level.defaultSunLight[1]+", G:"+level.defaultSunLight[2]);
	Default_R = level.defaultSunLight[0];
	Default_G = level.defaultSunLight[1];
	Default_B = level.defaultSunLight[2];

	Delta_R = (R_value - Default_R) / ramp_down_frames;
	Delta_G = (G_value - Default_G) / ramp_down_frames;
	Delta_B = (B_value - Default_B) / ramp_down_frames;

	while (ramp_down_frames * ramp_percentage > 0 )
	{
	    SetSunLight( R_value, G_value, B_value );
		wait 0.05;
		ramp_down_frames = ramp_down_frames - 1;
		R_value = R_value - Delta_R;
		G_value = G_value - Delta_G;
		B_value = B_value - Delta_B;
	}
}

lightning_flash_primary( lgt_ent, num )
{
	if (IsDefined(lgt_ent))
	{
		//IPrintLnBold("defined");
		//level notify( "emp_lighting_flash_primary" );
		//level endon( "emp_lighting_flash_primary" );
		
		lgt_ent SetLightIntensity( 3.2 );
 		
		if ( !IsDefined( num ) )
	   		num = RandomIntRange( 1, 4 );
				
		for ( i = 0; i < num; i++ )
	    {
	    	type = RandomInt( 3 );
		    switch( type )
		    {
		    	case 0:
		    		{
		    			wait( 0.05 );
					    lgt_ent SetLightIntensity( 2.6 );	
					    wait( 0.05 );
					    lgt_ent SetLightIntensity( 1.75 );
			    	}
		    		break;
	
		    	case 1:
			    	{
			    		wait( 0.05 );
					    lgt_ent SetLightIntensity( 2.2 );
					    wait( 0.05 );
					    lgt_ent SetLightIntensity( 3.15 );
					   	wait( 0.05 );
					    lgt_ent SetLightIntensity( 1.7 );		
			    	}			    	
		    		break;
	
		    	case 2:
		    		{
			    		wait( 0.05 );
					    lgt_ent SetLightIntensity( 1.2 );
					    wait( 0.05 );
					    lgt_ent SetLightIntensity( 2.0 );
					   	wait( 0.05 );
					    lgt_ent SetLightIntensity( 3.2 );
					    wait( 0.05 );
						lgt_ent SetLightIntensity( 2.2 );
		    		}
		    		
		    		break;
		    }
		    
		    wait RandomFloatRange( 0.05, 0.65 );
	   		lgt_ent SetLightIntensity( 0.1 );
	    }
	    lgt_ent SetLightIntensity( 0.1 );	    
	}
}


lightning_normal()
{
    ResetSunLight();
    ResetSunDirection();	
}

factory_playerWeather()
{
	for ( ;; )
	{
		// We have high ceilings on interior space, so this offset has been increased for Factory
		PlayFX( level._effect[ "rain_drops" ], level.player.origin + ( 0, 0, 1400 ), ( 0, 0, -1 ), ( 1, 0, 0 ) );
		wait( 0.3 );
	}
}

factory_chase_playerWeather()
{
	maps\_weather::rainNone( 1 );

	for ( ;; )
	{
//		PlayFX( level._effect[ "rain_angled_factory" ], level.player.origin + ( 0, 0, 1400 ), (AnglesToForward (level.ally_vehicle_trailer.angles)));
		PlayFX( level._effect[ "rain_drops" ], level.player.origin + ( 0, 0, 1400 ), ( -1,0,0));
		wait( 0.3 );
	}
}

fx_assembly_monitor_bink_init()
{
	fx_show_hide( "ambush_breach_ally_monitor_1_bink", "ambush_breach_ally_monitor_1_desktop" );
	fx_show_hide( "ambush_breach_ally_monitor_2_bink", "ambush_breach_ally_monitor_2_desktop" );
	fx_show_hide( undefined, "ambush_breach_ally_monitor_1_dim" );
	fx_show_hide( undefined, "ambush_breach_ally_monitor_2_dim" );

	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameLoopResident( "factory_computer_screensaver" );
	
	thread ambush_screensaver_loop();
}

ambush_screensaver_loop()
{
	level endon( "stop_screensaver_bink" );
	thread fx_assembly_monitor_bink_load_and_play();

	while ( 1 )
	{
		CinematicInGameLoop( "factory_computer_screensaver" );
		wait( 1 );

		while ( IsCinematicPlaying() )
		{
			wait( 0.5 );
		}
	}
}

// The PDA bink is triggered and paused to give it time to load.
// It is then unpaused based on the anim note track
fx_assembly_monitor_bink_load_and_play()
{
	flag_wait( "ambush_triggered" );
	level notify( "stop_screensaver_bink" );
	CinematicInGameSync( "factory_computer_pda" );
	wait 0.2;
	PauseCinematicInGame( 1 );

	level waittill( "start_ambush_bink" );
	level notify( "stop_screensaver_bink" );
	PauseCinematicInGame( 0 );
}

fx_assembly_monitor_bink_start( guy )
{
	level notify( "start_ambush_bink" );
	// Just to be safe.
	fx_show_delete( "ambush_breach_ally_monitor_1_dim", "ambush_breach_ally_monitor_1_desktop" );
	fx_show_delete( "ambush_breach_ally_monitor_2_dim", "ambush_breach_ally_monitor_2_desktop" );
}

fx_enable_ssao()
{
	if ( is_gen4() )
	{
		SetSavedDvar( "r_ssaoStrength", 3.0 );
		SetSavedDvar( "r_ssaoPower"	  , 1.2 );
	}
}

fx_disable_ssao()
{
	if ( is_gen4() )
	{
		SetSavedDvar( "r_ssaoStrength", 0.5 );
		SetSavedDvar( "r_ssaoPower"	  , 0.5 );
	}
}

fx_assembly_ally_monitor_swap_1( guy )
{
	wait 0.5;
	fx_show_delete( "ambush_breach_ally_monitor_1_desktop", "ambush_breach_ally_monitor_1_bink" );
	
	wait 1.5;
	fx_show_delete( "ambush_breach_ally_monitor_1_dim", "ambush_breach_ally_monitor_1_desktop" );
	
	wait 0.1;
	Exploder( "ambush_ally_monitor_1_search" );
}

fx_assembly_ally_monitor_swap_2( guy )
{
	wait 0.5;
	fx_show_delete( "ambush_breach_ally_monitor_2_desktop", "ambush_breach_ally_monitor_2_bink" );
	
	wait 1.2;
	fx_show_delete( "ambush_breach_ally_monitor_2_dim", "ambush_breach_ally_monitor_2_desktop" );
	
	wait 0.1;
	Exploder( "ambush_ally_monitor_2_search" );
}

fx_assembly_ally_monitor_error( guy )
{
	Stop_Exploder( "ambush_ally_monitor_1_search" );
	Stop_Exploder( "ambush_ally_monitor_2_search" );
	
	wait 0.5;														// Previous fx is on 500ms loop/life.
	Exploder( "ambush_ally_monitor_error" );
	
	wait 10.7;
	Stop_Exploder( "ambush_ally_monitor_error" );
	fx_show_delete( undefined, "ambush_breach_ally_monitor_1_dim" );
	fx_show_delete( undefined, "ambush_breach_ally_monitor_2_dim" );

	// Just to be safe.
	Stop_Exploder( "ambush_ally_monitor_1_search" );
	Stop_Exploder( "ambush_ally_monitor_2_search" );
	fx_show_delete( undefined, "ambush_breach_ally_monitor_1_bink" );
	fx_show_delete( undefined, "ambush_breach_ally_monitor_2_bink" );
	fx_show_delete( undefined, "ambush_breach_ally_monitor_1_desktop" );
	fx_show_delete( undefined, "ambush_breach_ally_monitor_2_desktop" );
}

fx_assembly_ally_monitor_delete()
{
	fx_show_delete( "ambush_breach_ally_monitor_1_desktop", "ambush_breach_ally_monitor_1_bink" );
	fx_show_delete( "ambush_breach_ally_monitor_2_desktop", "ambush_breach_ally_monitor_2_bink" );

	wait 12;
	Stop_Exploder( "ambush_ally_monitor_1_search" );
	Stop_Exploder( "ambush_ally_monitor_2_search" );

	wait 7.5;
	maps\factory_fx::fx_show_delete( undefined, "ambush_breach_ally_monitor_1_desktop" );
	maps\factory_fx::fx_show_delete( undefined, "ambush_breach_ally_monitor_2_desktop" );
}
fx_assembly_ceiling_cables( guy )
{
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_01" ], "tag_fx_001" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_02" ], "tag_fx_001" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_03" ], "tag_fx_001" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_01" ], "tag_fx_002" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_02" ], "tag_fx_002" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_03" ], "tag_fx_002" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_01" ], "tag_fx_003" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_02" ], "tag_fx_003" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_03" ], "tag_fx_003" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_01" ], "tag_fx_004" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_02" ], "tag_fx_004" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_03" ], "tag_fx_004" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_01" ], "tag_fx_005" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_02" ], "tag_fx_005" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_03" ], "tag_fx_005" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_01" ], "tag_fx_006" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_02" ], "tag_fx_006" );
	PlayFXOnTag( level._effect[ "cable_sparks_funner" ], level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_03" ], "tag_fx_006" );
}

fx_screen_raindrops()
{
	level.screenRain = spawn( "script_model", ( 0, 0, 0 ) );
	level.screenRain setmodel( "tag_origin" );
	level.screenRain.origin = level.player.origin;
	level.screenRain LinkToPlayerView (level.player, "tag_origin", (0,0,0), (0,0,0), true );

	i = 0;
	
	for( ;; )
	{
		if ( flag( "fx_screen_raindrops" ) || flag( "fx_player_watersheeting" ) )
		{
			sheeted = false;
			upAngle = level.player GetPlayerAngles();
	
			if ( flag( "fx_player_watersheeting" ) && upAngle[ 0 ] < 25 )
			{
				level.player SetWaterSheeting( 1, 1.0 );
				sheeted = true;
			}
			
			if ( flag( "fx_screen_raindrops" ) )
			{
				if ( !sheeted && upAngle[ 0 ] < -55 && RandomInt( 100 ) < 20 )
				{
					level.player SetWaterSheeting( 1, 1.0 );
				}

				i = i + 1;
				
				if (i > 4 )
				{
					i = 0;
				}

				if ( upAngle[ 0 ] < -40 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_20_" + i ], level.screenRain, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < -25 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_10_" + i ], level.screenRain, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < 25 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_5_" + i ], level.screenRain, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < 40 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_3_" + i ], level.screenRain, "tag_origin" );
				}
			}
		}
		
		wait 0.5;
	}
}

splash_on_player( end_flag )
{
	level endon( end_flag );
    level.splash_tag = "tag_flash";
    level.splash_X = RandomFloatRange(-25, -5);
    level.splash_Y = RandomFloatRange(-1, 1);
    level.splash_Z = RandomFloatRange(1, 2);
    level.splash_angles = (0,0,0);

	model1 = Spawn( "script_model", (0,0,20) );
    model2 = Spawn( "script_model", (0,0,20) );
    while( 1 )
    {
		if (flag ( "fx_player_watersheeting" ) )
		{
			//IPrintLnBold ( "under a water spout" );
			splash_type = RandomInt( 3 );
		    switch( splash_type )
		    {
		    	case 0:
				level.splash_FX = "splash_body_shallow";
				break;
		    	case 1:
		    	case 2:
				level.splash_FX = "factory_single_splash_plr";
				break;
		    }
		}
		else
		{
			//level.splash_FX = "glow_green_light_30_nolight";
			level.splash_FX = "factory_single_splash_plr";
			//IPrintLnBold ( "standard" );
		}

		model1 Delete();
        model1 = Spawn( "script_model", (0,0,20) );
	    model1 SetModel( "tag_origin" );
		thread splash_on_player_choose_location();
		model1 LinkToPlayerView( self, level.splash_tag, ( level.splash_X, level.splash_Y, level.splash_Z ), level.splash_angles, true );
        //PlayFxOnTag( getfx( "factory_single_drip" ), model1, "tag_origin" );
        PlayFxOnTag( getfx( level.splash_FX ), model1, "tag_origin" );
        wait RandomFloatRange(0.06, 0.3);
		model2 Delete();
        model2 = Spawn( "script_model", (0,0,20) );
	    model2 SetModel( "tag_origin" );
		thread splash_on_player_choose_location();
		model2 LinkToPlayerView( self, level.splash_tag, ( level.splash_X, level.splash_Y, level.splash_Z ), level.splash_angles, true );
        //PlayFxOnTag( getfx( "factory_single_drip" ), model2, "tag_origin" );
        PlayFxOnTag( getfx( level.splash_FX ), model2, "tag_origin" );
        wait RandomFloatRange(0.06, 0.3);
    }
}

splash_on_player_choose_location()
{
	location = RandomInt( 3 );
    switch( location )
    {
    	case 0:
			// On the Weapon
			//IPrintLnBold ( location );
			//level.splash_FX = "factory_single_splash_plr";
			if ( level.player GetCurrentWeapon() == "uspflir2_silencer" )
			{
			    level.splash_tag = "tag_flash";
			    level.splash_X = RandomFloatRange(-10, -1);
			    level.splash_Y = RandomFloatRange(-0.5, 0.5);
			    level.splash_Z = RandomFloatRange(0.0, 0.5);
			    level.splash_angles=(0,0,0);
	    		break;
			}
			if ( level.player GetCurrentWeapon() == "factory_knife" )
			{
			    level.splash_tag = "tag_weapon";
			    level.splash_X = RandomFloatRange(0.5, 9.5);
			    level.splash_Y = RandomFloatRange(-0.5, 0.5);
			    level.splash_Z = RandomFloatRange(-0.5, 0.5);
			    level.splash_angles=(90,0,0);
	    		break;
			}
		    level.splash_tag = "tag_flash";
		    level.splash_X = RandomFloatRange(-28, -5);
		    level.splash_Y = RandomFloatRange(-1, 1);
		    level.splash_Z = RandomFloatRange(0.5, 1.1);
		    level.splash_angles=(0,0,0);
    		break;
    	case 1:
			//IPrintLnBold ( location );
			// On the forearm
			//level.splash_FX = "factory_single_splash_plr";
		    level.splash_tag = "j_elbow_le";
		    level.splash_X = RandomFloatRange(0, 18);
		    level.splash_Y = RandomFloatRange(-1, 1);
		    level.splash_Z = RandomFloatRange(-3, 2);
		    level.splash_angles=(90,0,0);
    		break;
    	case 2:
			//IPrintLnBold ( location );
			// On the hand
			//level.splash_FX = "glow_green_light_30_nolight";
		    level.splash_tag = "j_thumb_le_0";
		    level.splash_X = RandomFloatRange(-2, 2);
		    level.splash_Y = RandomFloatRange(0.5, 1.5);
		    level.splash_Z = RandomFloatRange(-1, 1);
		    level.splash_angles=(90,0,0);
    		break;
	}
}



splash_on_actor( rain_actor, end_flag, speed_limit )
{
	while ( !flag ( end_flag ))
	{
		if ( flag ("factory_rooftop_wind_gust"))
		{
			spray = RandomIntRange (0,3);
			switch ( spray )
			{
				case 0:
					//break;
				case 1:
					//break;
				case 2:
					//break;
				case 4:
					PlayFX( getfx( "factory_rooftop_wind_gust_ground" ), (rain_actor.origin+(30,0,RandomFloatRange(0,40))), (0,-1,0), (0,0,1) );
					break;
			}
		}
		wait 0.25;
	}
}

rooftop_wind_gusts()
{
	// Uncomment to test out FX playing around characers and player
	/*
	level waittill ( "rooftop_door_kicked" );
	thread maps\factory_fx::splash_on_actor ( level.squad[ "ALLY_ALPHA" ], "player_mount_vehicle_start" );
	//thread maps\factory_fx::splash_on_actor ( level.squad[ "ALLY_BRAVO" ], "player_mount_vehicle_start" );
	thread maps\factory_fx::splash_on_actor ( level.squad[ "ALLY_CHARLIE" ], "player_mount_vehicle_start" );
	flag_set ( "factory_rooftop_wind_gust" );
	flag_set ( "factory_rooftop_wind_gust_moment" );
	while(1)
	{
		// START A NEW SERIES OF GUSTS
		gust_repeats = RandomIntRange (7,10);
		//IPrintLnBold ("new gust");
		flag_set ( "factory_rooftop_wind_gust" );
		while(gust_repeats)
		{
			PlayFX( getfx( "factory_rooftop_wind_gust_ground" ), (level.player.origin+(-130,RandomFloatRange(-40,40),RandomFloatRange(0,40))), (0,-1,0), (0,0,1) );
			if ( flag ("factory_rooftop_wind_gust_moment") )
			{
				PlayFX( getfx( "factory_rooftop_wind_gust" ), (level.player.origin+(-400,RandomFloatRange(-100,100),RandomFloatRange(0,60))), (1,0,0), (0,0,1) );
				//IPrintLnBold ("new gust");
			}
			wait RandomFloatRange (0.4,1.0);
			gust_repeats = gust_repeats - 1;
		}
		flag_clear ( "factory_rooftop_wind_gust" );
		flag_clear ( "factory_rooftop_wind_gust_moment" );
		wait RandomFloatRange (1,4);
		//if ( flag ("player_mount_vehicle_start") ) 
		//	break;
	}
	*/
}

rain_on_actor( rain_actor, end_flag, time_delay, just_drips )
{
	//IPrintLnBold( "RAINING ON" );
	//IPrintLnBold( rain_actor );
	
	level endon( end_flag );
    new_model = spawn_tag_origin();
    new_model2 = spawn_tag_origin();
    new_model3 = spawn_tag_origin();
    new_model4 = spawn_tag_origin();
	last_pos = rain_actor.origin;

    while( 1 )
    {
    	if (flag ( end_flag ))
    		break;
    	if (!IsAlive (rain_actor) )
    		break;
    	// check to make sure ally is not moving too fast
		last_pos_min = rain_actor.origin - (1, 1, 1);
		last_pos_max = rain_actor.origin + (1, 1, 1);
		if (last_pos[0] > last_pos_min[0] && last_pos[0] < last_pos_max[0] && last_pos[1] > last_pos_min[1] && last_pos[1] < last_pos_max[1] )
		{
			// drip from head
			new_model2.origin = rain_actor GetTagOrigin( "J_Neck" );
			new_model2.origin = ( new_model2.origin + (RandomFloatRange(-4, 4), RandomFloatRange(-10, 2), RandomFloatRange(2, 4)) );
			PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model2, "tag_origin" );
				
			// drip from gun
			new_model3.origin = rain_actor GetTagOrigin( "TAG_FLASH" );
			new_model3.origin = ( new_model3.origin + (RandomFloatRange(-1, 1), RandomFloatRange(-2, 2), RandomFloatRange(0, 1)) );
			PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model3, "tag_origin" );
	
			// drip from chest
			new_model4.origin = rain_actor GetTagOrigin( "J_Neck" );
			new_model4.origin = ( new_model4.origin + (RandomFloatRange(-11, 11), RandomFloatRange(0, 9), RandomFloatRange(-1, 1)) );
			PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model4, "tag_origin" );
	
		}
		else
		{
			// moving fast so only drip from torso and lower positions to not seem to hand in air
			// drip from chest
			new_model2.origin = rain_actor GetTagOrigin( "J_Neck" );
			new_model2.origin = ( new_model2.origin + (RandomFloatRange(-11, 11), RandomFloatRange(0, 9), RandomFloatRange(-45, -25)) );
			PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model4, "tag_origin" );
			new_model3.origin = rain_actor GetTagOrigin( "J_Neck" );
			new_model3.origin = ( new_model3.origin + (RandomFloatRange(-11, 11), RandomFloatRange(0, 9), RandomFloatRange(-45, -25)) );
			PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model4, "tag_origin" );
			new_model4.origin = rain_actor GetTagOrigin( "J_Neck" );
			new_model4.origin = ( new_model4.origin + (RandomFloatRange(-11, 11), RandomFloatRange(0, 9), RandomFloatRange(-45, -25)) );
			PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model4, "tag_origin" );
	
		}

		// if only drips, do not do splashes
		if (!IsDefined ( just_drips ) )
		{
			// check to make sure ally is not moving almost at all
			last_pos_min = rain_actor.origin - (3, 3, 3);
			last_pos_max = rain_actor.origin + (3, 3, 3);
			if (last_pos[0] > last_pos_min[0] && last_pos[0] < last_pos_max[0] && last_pos[1] > last_pos_min[1] && last_pos[1] < last_pos_max[1] )
			{
				//IPrintLnBold( "not moving fast" );
				// also choose an alternate splash locations
				splash_location = randomintrange( 0, 9 );
				if (splash_location < 6)
				{
					// splat on ally's back
					new_model.origin = rain_actor GetTagOrigin( "J_Neck" );
					new_model.origin = ( new_model.origin + (RandomFloatRange(-11, 11), RandomFloatRange(0, 9), RandomFloatRange(-1, 1)) );
					PlayFXOnTag( level._effect[ "factory_single_splash" ], new_model, "tag_origin" );
					PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model, "tag_origin" );
				}
				if (splash_location == 6)
				{
					// splat on ally's head
					new_model.origin = rain_actor GetTagOrigin( "J_Neck" );
					new_model.origin = ( new_model.origin + (RandomFloatRange(-3, 3), RandomFloatRange(-10, -1), RandomFloatRange(7, 8)) );
					PlayFXOnTag( level._effect[ "factory_single_splash" ], new_model, "tag_origin" );
					PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model, "tag_origin" );
				}
				if (splash_location == 7)
				{
					new_model.origin = rain_actor GetTagOrigin( "TAG_FLASH" );
					PlayFXOnTag( level._effect[ "factory_single_splash" ], new_model, "tag_origin" );
					PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model, "tag_origin" );
				}
				if (splash_location == 8)
				{
					new_model.origin = rain_actor GetTagOrigin( "J_Wrist_RI" );
					PlayFXOnTag( level._effect[ "factory_single_splash" ], new_model, "tag_origin" );
					PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model, "tag_origin" );
				}
				if (splash_location == 9)
				{
					new_model.origin = rain_actor GetTagOrigin( "tag_inhand" );
					PlayFXOnTag( level._effect[ "factory_single_splash" ], new_model, "tag_origin" );
					PlayFXOnTag( level._effect[ "factory_single_drip" ], new_model, "tag_origin" );
				}
			}
			else
			{
				// moving fast so only splat inside ally's back
				new_model.origin = rain_actor GetTagOrigin( "J_Neck" );
				new_model.origin = ( new_model.origin + (RandomFloatRange(-11, 11), RandomFloatRange(-5, 5), RandomFloatRange(-6, 1)) );
				PlayFXOnTag( level._effect[ "factory_single_splash" ], new_model, "tag_origin" );

				last_pos_min = rain_actor.origin - (6, 6, 6);
				last_pos_max = rain_actor.origin + (6, 6, 6);
				/*
				if (last_pos[0] > last_pos_min[0] && last_pos[0] < last_pos_max[0] && last_pos[1] > last_pos_min[1] && last_pos[1] < last_pos_max[1] )
				{
				}
				else
				{
					// Play splash on ground
			    	type = RandomInt( 3 );
				    switch( type )
				    {
				    	case 0:
				    		break;
				    	case 1:
				    		break;
				    	case 2:
							//PlayFX( getfx( "splash_body_shallow_bigger" ), rain_actor.origin );
							PlayFX( getfx( "footstep_splash_large" ), rain_actor.origin );
				    		break;
				    }
				}
				*/
			}
		}
		if (IsAlive (rain_actor))
			last_pos = rain_actor.origin;
		wait time_delay;
	}
    new_model delete();
    new_model2 delete();
    new_model3 delete();
    new_model4 delete();

}

fx_sat_revolving_door_light_setup()
{
	array_thread( GetEntArray( "fx_sat_revolving_door_light", "targetname" ), ::fx_sat_revolving_door_light );
}

fx_sat_revolving_door_light()
{
	// Don't link effects tag object to light because rotation doesn't work.
	
	// Beam.
	beam = spawn_tag_origin();
	beam.origin = self.origin - ( 0, 0, 5 );
	beam.angles = self.angles - ( 0, 90, 0 );
	beam LinkTo( self );
	
	PlayFXOnTag( level._effect[ "amber_light_45_beacon_nolight_beam" ], beam, "tag_origin" );

	// Glow.	
	glow = spawn_tag_origin();
	glow.origin = self.origin - ( 0, 0, 5 );
	glow.angles = self.angles;
	glow LinkTo( self );
	
	PlayFXOnTag( level._effect[ "amber_light_45_beacon_nolight_glow" ], glow, "tag_origin" );

	self thread fx_sat_revolving_door_light_rotate();

	flag_wait( "presat_locked" );

	beam Delete();
	glow Delete();
}

fx_sat_revolving_door_light_rotate()
{
	self endon( "death" );
	self endon( "presat_locked" );

	while( 1 )
	{
		self RotateYaw( 360, 1.5 );
	    wait 1.5;
	}
}

/*
fx_intro_kill_godrays_on()
{
	self endon( "music_jungle_slide" );
	
	while( 1 )
	{
		flag_wait( "fx_intro_kill_godrays_on" );
		maps\_utility::vision_set_fog_changes( "factory_intro_kill", 2 );
		flag_wait( "fx_intro_kill_godrays_off" );
		flag_clear( "fx_intro_kill_godrays_on" );
	}
}

fx_intro_kill_godrays_off()
{
	self endon( "music_jungle_slide" );
	
	while( 1 )
	{
		flag_wait( "fx_intro_kill_godrays_off" );
		maps\_utility::vision_set_fog_changes( "factory_intro", 2 );
		flag_wait( "fx_intro_kill_godrays_on" );
		flag_clear( "fx_intro_kill_godrays_off" );
	}
}
*/

fx_intro_kill_ally_stab( guy )
{
	blood = spawn_tag_origin();
	blood LinkTo( guy, "j_neck", ( 3, -2, 6 ), ( 270, 0, 0 ) );
	PlayFXOnTag( level._effect[ "factory_ambush_chest_blood" ], blood, "tag_origin" );
	
	wait 20.0;
	blood Delete();
}

fx_intro_kill_player_stab( guy )
{
	blood = spawn_tag_origin();
	blood LinkTo( guy, "j_spineupper", ( 12, -14, 0 ), ( 0, 275, 0 ) );
	PlayFXOnTag( level._effect[ "factory_intro_stab_blood_player" ], blood, "tag_origin" );

/*
	wait 0.2;
	
	screenBlood = spawn( "script_model", ( 0, 0, 0 ) );
	screenBlood setmodel( "tag_origin" );
	screenBlood.origin = level.player.origin;
	screenBlood LinkToPlayerView (level.player, "tag_origin", (0,0,0), (0,0,0), true );
	PlayFXOnTag(  level._effect[ "factory_intro_stab_blood_screen" ], screenBlood, "tag_origin" );
*/

	wait 20.0;
	blood Delete();
//	screenBlood Delete();
}

fx_chase_het_tire_smoke( guy )
{
	PlayFXOnTag( level._effect[ "factory_chase_het_tire_smoke_runner" ], guy, "tag_wheel_back_left" );
	PlayFXOnTag( level._effect[ "factory_chase_het_tire_smoke_runner" ], guy, "tag_wheel_back_right" );
	
	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_het_tire_smoke_runner" ], guy, "tag_wheel_middle_left" );
	PlayFXOnTag( level._effect[ "factory_chase_het_tire_smoke_runner" ], guy, "tag_wheel_middle_right" );	
}

fx_chase_stack_small_break( guy )
{
	Exploder( "chase_stack_small_break" );
	
	wait 1.5;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_00" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_01" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_02" );
	
	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_03" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_04" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_05" );
	
	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_06" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_07" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_08" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_09" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_10" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_11" );
	

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_12" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_13" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_14" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_15" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_16" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_17" );
	

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_18" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_19" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_20" );
}

fx_chase_box_explosions_start( guy )
{
	maps\_utility::vision_set_fog_changes( "factory_chase_explosion", 0.5 );
}

fx_chase_warehouse_explosion( guy )
{
	maps\_utility::vision_set_fog_changes( "factory_chase_explosion", 0.1 );
	exploder( "chase_warehouse_missile_explosion" );

	wait 0.4;
	exploder( "chase_warehouse_door_explosion" );

	wait 0.3;
	exploder( "chase_warehouse_explosion" );
	
	// This script_exploder swaps the warehouse ceiling version to the destroyed state
	exploder( "building_crash_01_exploder" );
	
	wait 2.0;
	exploder( "chase_stack_base_explosion" );
	
	wait 0.5;	
	maps\_utility::vision_set_fog_changes( "", 1.0 );
}

fx_chase_stack_break_01( guy )
{
	Exploder( "chase_stack_break_01" );
	
	wait 1.5;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_21" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_22" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_23" );
	
	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_24" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_25" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_26" );
	
	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_27" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_28" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_29" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_30" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_31" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_32" );
	

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_33" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_34" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_35" );
}

fx_chase_stack_break_02( guy )
{
	Exploder( "chase_stack_break_02" );
	
	wait 1.5;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_00" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_01" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_02" );
	
	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_03" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_04" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_05" );
	
	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_06" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_07" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_08" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_09" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_10" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_11" );
	

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_12" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_13" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_14" );

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_15" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_16" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_17" );
	

	wait 0.05;
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_18" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_19" );
	PlayFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner" ], guy, "tag_fx_falling_chunks_20" );
}

fx_chase_stack_piece( guy, tagFX )
{
	StopFXOnTag( level._effect[ "factory_chase_stack_pieces_trail_runner"], guy, tagFX );
	pos = guy GetTagOrigin( tagFX );
	PlayFX( level._effect[ "factory_chase_stack_pieces_impact_dust" ], pos, ( 0, 0, 1 ), ( 1, 0, 0 ) );
}

fx_chase_stack_piece_027( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_23" );
}

/*
fx_chase_stack_piece_030( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_24" );
}

fx_chase_stack_piece_034( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_25" );
}
*/

fx_chase_stack_piece_037( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_33" );
}

fx_chase_stack_piece_039( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_31" );
}

/*
fx_chase_stack_piece_041( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_29" );
}
*/

fx_chase_stack_piece_042( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_35" );
}

fx_chase_stack_piece_007( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_20" );
}

fx_chase_stack_piece_008( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_15" );
}

fx_chase_stack_piece_017( guy )
{
	fx_chase_stack_piece( guy, "tag_fx_falling_chunks_00" );
}

