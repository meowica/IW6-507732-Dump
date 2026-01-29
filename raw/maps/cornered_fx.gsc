#include maps\_utility;
#include common_scripts\utility;
#include maps\cornered_code;

main() 
{

	level._effect[ "embers_burst_runner_cheap" ] = loadfx( "vfx/moments/mp_warhawk/embers_burst_runner_cheap" );
	level._effect[ "vfx_atrium_window_impact" ] = loadfx( "vfx/moments/cornered/vfx_atrium_window_impact" );
	level._effect[ "cnd_atrium_floor_breakup" ] = loadfx( "vfx/moments/cornered/cnd_atrium_floor_breakup" );
	level._effect[ "fireworks_all_sm" ] = loadfx( "fx/explosions/fireworks_all_sm" );
	level._effect[ "fireworks_red_sm" ] = loadfx( "fx/explosions/fireworks_red_sm" );
	level._effect[ "fireworks_white_sm" ] = loadfx( "fx/explosions/fireworks_white_sm" );
	level._effect[ "fireworks_green_sm" ] = loadfx( "fx/explosions/fireworks_green_sm" );
	level._effect[ "fireworks_blue_sm" ] = loadfx( "fx/explosions/fireworks_blue_sm" );
	level._effect[ "vfx_spotlight_party_flare" ] = loadfx( "vfx/moments/cornered/vfx_spotlight_party_flare" );
	level._effect[ "vfx_spotlight_party" ] = loadfx( "vfx/moments/cornered/vfx_spotlight_party" );
	level._effect[ "vfx_building_side_video" ] = loadfx( "vfx/moments/cornered/vfx_building_side_video" );
	level._effect[ "vfx_bulb_prismatic_xlg" ] = loadfx( "vfx/ambient/lights/vfx_bulb_prismatic_xlg" );
	level._effect[ "vfx_building_box_graphic" ] = loadfx( "vfx/moments/cornered/vfx_building_box_graphic" );
	level._effect[ "vfx_building_line_graphic" ] = loadfx( "vfx/moments/cornered/vfx_building_line_graphic" );
	level._effect[ "vfx_building_tie_graphic" ] = loadfx( "vfx/moments/cornered/vfx_building_tie_graphic" );
	level._effect[ "cnd_red_blding_top_light3" ] = loadfx( "fx/temp/cornered/cnd_red_blding_top_light3" );
	level._effect[ "vfx_building_billboard_01" ] = loadfx( "vfx/moments/cornered/vfx_building_billboard_01" );
	level._effect[ "vfx_building_side_graphic_2" ] = loadfx( "vfx/moments/cornered/vfx_building_side_graphic_2" );
	level._effect[ "vfx_building_side_graphic" ] = loadfx( "vfx/moments/cornered/vfx_building_side_graphic" );
	level._effect[ "cnd_secondry_explosion_large" ] = loadfx( "vfx/moments/cornered/cnd_secondry_explosion_large" );
	level._effect[ "zipline_speed" ] = loadfx( "vfx/moments/cornered/zipline_speed" );
	level._effect[ "gusty_wind" ] = loadfx( "vfx/moments/cornered/gusty_wind" );
	level._effect[ "vfx_heat_haze" ] = loadfx( "vfx/ambient/atmospheric/vfx_heat_haze" );
	level._effect[ "cornered_rooftop_spotlight" ] = loadfx( "vfx/moments/cornered/cornered_rooftop_spotlight" );
	level._effect[ "raindrop_loop_window" ] = loadfx( "vfx/ambient/water/raindrop_loop_window" );
	level._effect[ "vfx_lens_flare" ] = loadfx( "vfx/moments/cornered/vfx_lens_flare" );
	level._effect[ "vfx_fireworks_lingeringsmoke_looping" ] = loadfx( "vfx/moments/cornered/vfx_fireworks_lingeringsmoke_looping" );
	level._effect[ "falling_debris_card" ] = loadfx( "vfx/moments/cornered/falling_debris_card" );
	level._effect[ "vfx_exfil_shockwave" ] = loadfx( "vfx/moments/cornered/vfx_exfil_shockwave" );
	level._effect[ "vfx_atrium_pillar_impact" ] = loadfx( "vfx/moments/cornered/vfx_atrium_pillar_impact" );
	level._effect[ "vfx_glass_window_smash" ] = loadfx( "vfx/moments/cornered/vfx_glass_window_smash" );
	level._effect[ "vfx_smk_finger" ] = loadfx( "vfx/ambient/smoke/vfx_smk_finger" );
	level._effect[ "vfx_debris_falling_exfil_2" ] = loadfx( "vfx/moments/cornered/vfx_debris_falling_exfil_2" );
	level._effect[ "vfx_exp_atrium" ] = loadfx( "vfx/moments/cornered/vfx_exp_atrium" );
	level._effect[ "vfx_exp_concrete_fracture" ] = loadfx( "vfx/gameplay/explosions/vfx_exp_concrete_fracture" );
	level._effect[ "vfx_debris_falling_exfil_" ] = loadfx( "vfx/moments/cornered/vfx_debris_falling_exfil_" );
	
	
	level._effect[ "fire_trash2" ] 							= LoadFX( "fx/fire/fire_trash2" );
	level._effect[ "spark_fall_runner_mp" ] 				= LoadFX( "fx/explosions/spark_fall_runner_mp" );
	level._effect[ "amb_wind_blowing_slow" ] 				= LoadFX( "fx/dust/amb_wind_blowing_slow" );
	level._effect[ "paper_blowing_cards_heavy_windy" ] 		= LoadFX( "fx/misc/paper_blowing_cards_heavy_windy" );
	level._effect[ "paper_blowing_cards_windy" ] 			= LoadFX( "fx/misc/paper_blowing_cards_windy" );
	level._effect[ "building_debris_falling_cornered" ] 	= LoadFX( "fx/misc/building_debris_falling_cornered" );
	level._effect[ "cnd_godray_thin" ] 						= LoadFX( "vfx/moments/cornered/cnd_godray_thin" );
	level._effect[ "smk_wispy_911" ] 						= LoadFX( "vfx/moments/cornered/smk_wispy_911" );
	level._effect[ "cloud_ash_lite_cornered" ] 				= LoadFX( "vfx/moments/cornered/cloud_ash_lite_cornered" );
	level._effect[ "vfx_fire_xtralarge_nxglight" ] 			= LoadFX( "vfx/ambient/fire/vfx_fire_xtralarge_nxglight" );
	level._effect[ "vfx_fire_small_nolight" ] 				= LoadFX( "vfx/ambient/fire/vfx_fire_small_nolight" );
	level._effect[ "vfx_fire_grounded_xtralarge_nxglight" ] = LoadFX( "vfx/ambient/fire/vfx_fire_grounded_xtralarge_nxglight" );
	level._effect[ "vfx_steam_wispy_mist" ] 				= LoadFX( "vfx/ambient/steam/vfx_steam_wispy_mist" );
	level._effect[ "vfx_int_smk_ceiling" ] 					= LoadFX( "vfx/ambient/smoke/vfx_int_smk_ceiling" );
	level._effect[ "vfx_smk_black_01" ] 					= LoadFX( "vfx/ambient/smoke/vfx_smk_black_01" );
	level._effect[ "vfx_smk_topdown_uv" ] 					= LoadFX( "vfx/ambient/smoke/vfx_smk_topdown_uv" );
	level._effect[ "vfx_electrical_spark_drip_smalldlight" ]= LoadFX( "vfx/ambient/sparks/vfx_electrical_spark_drip_smalldlight" );
	level._effect[ "vfx_electrical_spark_drip" ] 			= LoadFX( "vfx/ambient/sparks/vfx_electrical_spark_drip" );
	level._effect[ "spark_flash_15" ] 						= LoadFX( "vfx/ambient/sparks/spark_flash_15" );
	level._effect[ "vfx_emergency_light_blinking_white" ] 	= LoadFX( "vfx/ambient/lights/vfx_emergency_light_blinking_white" );
	level._effect[ "vfx_lights_conc_spill" ] 				= LoadFX( "vfx/ambient/lights/vfx_lights_conc_spill" );
	level._effect[ "vfx_glow_white_stage_cnd" ] 			= LoadFX( "vfx/ambient/lights/vfx_glow_white_stage_cnd" );
	level._effect[ "vfx_lights_conc_1"] 					= LoadFX( "vfx/ambient/lights/vfx_lights_conc_1" );
	level._effect[ "vfx_glow_yellow_spill_cnd" ] 			= LoadFX( "vfx/ambient/lights/vfx_glow_yellow_spill_cnd" );
	level._effect[ "vfx_glow_red_spill_cnd"] 				= LoadFX( "vfx/ambient/lights/vfx_glow_red_spill_cnd" );
	//level._effect[ "vfx_glow_red_light_5_blinker_nolight" ] = LoadFX( "vfx/ambient/lights/vfx_glow_red_light_5_blinker_nolight" );
	level._effect[ "leaves_falling_impact" ] 				= LoadFX( "fx/temp/cornered/leaves_falling_impact" );
	level._effect[ "pipe_burst_cornered_a" ] 				= LoadFX( "fx/temp/cornered/pipe_burst_cornered_a" );
	level._effect[ "leaves_falling_lt" ] 					= LoadFX( "fx/temp/cornered/leaves_falling_lt" );
	level._effect[ "heavy_dust_haze" ] 						= LoadFX( "fx/temp/cornered/heavy_dust_haze" );
	level._effect[ "smoke_smolder_embers" ] 				= LoadFX( "fx/temp/cornered/smoke_smolder_embers" );
	level._effect[ "dust_motes_godray" ] 					= LoadFX( "fx/temp/cornered/dust_motes_godray" );
	level._effect[ "dust_fall_runner" ] 					= LoadFX( "fx/temp/cornered/dust_fall_runner" );
	level._effect[ "dust_fallsmall_runner" ] 				= LoadFX( "fx/temp/cornered/dust_fallsmall_runner" );
	level._effect[ "paper_fall" ] 							= LoadFX( "fx/temp/cornered/paper_fall" );
	level._effect[ "dust_layered_fog" ] 					= LoadFX( "fx/temp/cornered/dust_layered_fog" );
	level._effect[ "cnd_concrete_smash" ] 					= LoadFX( "fx/temp/cornered/cnd_concrete_smash" );
	level._effect[ "cnd_building_explosion" ] 				= LoadFX( "fx/temp/cornered/cnd_building_explosion" );
	level._effect[ "cnd_building_fire" ] 					= LoadFX( "fx/temp/cornered/cnd_building_fire" );
	level._effect[ "mp_bw_embers" ] 						= LoadFX( "fx/temp/cornered/mp_bw_embers" );
	level._effect[ "ceiling_impact_hallway" ] 				= LoadFX( "fx/temp/cornered/ceiling_impact_hallway" );
	level._effect[ "cnd_flames_fire" ] 						= LoadFX( "fx/temp/cornered/cnd_flames_fire" );
	level._effect[ "cnd_glass_shatter" ] 					= LoadFX( "fx/temp/cornered/cnd_glass_shatter" );
	level._effect[ "cnd_debris_slide" ] 					= LoadFX( "fx/temp/cornered/cnd_debris_slide" );
	level._effect[ "cnd_dust_linger" ] 						= LoadFX( "fx/temp/cornered/cnd_dust_linger" );
	level._effect[ "cnd_smoke_plume_lrg" ] 					= LoadFX( "fx/temp/cornered/cnd_smoke_plume_lrg" );
	level._effect[ "cnd_yel_light2" ] 						= LoadFX( "fx/temp/cornered/cnd_yel_light2" );
	level._effect[ "cnd_yel_light1"	] 						= LoadFX( "fx/temp/cornered/cnd_yel_light1" );
	level._effect[ "cnd_neon_light"	] 						= LoadFX( "fx/temp/cornered/cnd_neon_light" );
	level._effect[ "cnd_neon_light2" ] 						= LoadFX( "fx/temp/cornered/cnd_neon_light2" );
	level._effect[ "cnd_fire_falling_exfill" ]				= LoadFX( "fx/temp/cornered/cnd_fire_falling_exfill" );
	level._effect[ "city_light_spill" ] 					= LoadFX( "fx/lights/city_light_spill" );
	level._effect[ "cornered_balcony_spotlight_nolight" ] 	= LoadFX( "fx/lights/cornered_balcony_spotlight_nolight" );
	level._effect[ "flicker_single_fxlight" ] 				= LoadFX( "fx/lights/flicker_single_fxlight" );	
	level._effect[ "powerlines_c" ]							= LoadFX( "fx/explosions/powerlines_c" );	
	level._effect[ "water_pipe_spout" ] 					= LoadFX( "fx/water/water_pipe_spout" );
	level._effect[ "falling_water_spray" ] 					= LoadFX( "fx/water/falling_water_spray" );
	
	// Ambient
	level._effect[ "vfx_bulb_prismatic" ] 					= LoadFX( "vfx/ambient/lights/vfx_bulb_prismatic" );
	level._effect[ "drips_faucet_slow" ] 					= LoadFX( "fx/water/drips_faucet_slow" );
	level._effect[ "pipe_drips" ] 							= LoadFX( "fx/temp/cornered/pipe_drips" );
	level._effect[ "amb_wind_blowing" ]						= LoadFX( "fx/dust/amb_wind_blowing" );
	level._effect[ "amb_wind_blowing_motes" ] 				= LoadFX( "fx/dust/amb_wind_blowing_motes" );
	level._effect[ "light_dust_motes_fog" ] 				= LoadFX( "fx/temp/cornered/light_dust_motes_fog" );
	
	
	// Intro
	level._effect[ "rain_drizzle_intro" ] 					= LoadFX( "vfx/moments/cornered/rain_drizzle_intro" );
	level._effect[ "rain_splash_puddle_50x50_runner" ] 		= LoadFX( "vfx/moments/cornered/rain_splash_puddle_50x50_runner" );
	level._effect[ "heli_dust_infinite" ] 					= LoadFX( "fx/treadfx/heli_dust_infinite" );
	level._effect[ "heli_dust_default_light" ] 				= LoadFX( "fx/treadfx/heli_dust_default_light" );
	
	// Zipline
	level._effect[ "zipline_anchor_impact" ] 				= LoadFX( "fx/impacts/zipline_anchor_impact" );
	level._effect[ "vfx_zipline_tracer" ] 					= LoadFX( "vfx/moments/cornered/vfx_zipline_tracer" );
	level._effect[ "zipline_shot" ] 						= LoadFX( "fx/muzzleflashes/zipline_shot" );
	level._effect[ "zipline_launcher_foot_impact" ] 		= LoadFX( "fx/impacts/zipline_launcher_foot_impact" );
	
	// Bar
	level._effect[ "lights_ext_halogen_quad_white" ] 		= LoadFX( "fx/lights/lights_ext_halogen_quad_white" );
	level._effect[ "cnd_spotlight_strobe" ]					= LoadFX( "fx/temp/cornered/cnd_spotlight_strobe" );	
	level._effect[ "cnd_ally_strobe" ]						= LoadFX( "fx/temp/cornered/cnd_ally_strobe" );	
	
	// Rappel
	level._effect[ "window_explosion_out" ] 				= LoadFX( "fx/explosions/window_explosion_out" );
	level._effect[ "copier_papers_falling" ] 				= LoadFX( "fx/temp/cornered/copier_papers_falling" );
	
	// Hallways
	
	// Stealth
	level._effect[ "cell_screen_glow_bright" ] 				= LoadFX( "vfx/moments/cornered/cell_screen_glow_bright" );
	level._effect[ "cell_screen_glow" ] 					= LoadFX( "vfx/moments/cornered/cell_screen_glow" );
	
	// Garden
	level._effect[ "water_caustics" ] 						= LoadFX( "fx/temp/cornered/water_caustics" );
	level._effect[ "light_dust_motes_fog_garden" ] 			= LoadFX( "fx/temp/cornered/light_dust_motes_fog_garden" );
	
	// Stairwell
	level._effect[ "pipe_fire_looping_fxlight" ] 			= LoadFX( "fx/impacts/pipe_fire_looping_fxlight" );
	level._effect[ "pipe_fire_looping" ] 					= LoadFX( "fx/impacts/pipe_fire_looping" );
	level._effect[ "payback_pipe_steam" ]					= LoadFX( "fx/maps/payback/payback_pipe_steam" );
	level._effect[ "banner_fire_nodrip" ] 					= LoadFX( "fx/fire/banner_fire_nodrip" );
	
	// Party
	level._effect[ "vfx_camera_flashes" ] 					= LoadFX( "vfx/moments/cornered/vfx_camera_flashes" );
	level._effect[ "vfx_crowd_dnc" ] 						= LoadFX( "vfx/moments/cornered/vfx_crowd_dnc" );
	level._effect[ "vfx_crowd_rappel_road"] 				= LoadFX( "vfx/moments/cornered/vfx_crowd_rappel_road" );
	level._effect[ "vfx_crowd_rappel_road_long"] 			= LoadFX( "vfx/moments/cornered/vfx_crowd_rappel_road_long" );
	level._effect[ "vfx_crowd_rappel"] 						= LoadFX( "vfx/moments/cornered/vfx_crowd_rappel" );
	level._effect[ "vfx_festival_spot_cnd" ] 				= LoadFX( "vfx/ambient/lights/vfx_festival_spot_cnd" );
	
	// Falling
	level._effect[ "cnd_building_fall" ] 					= LoadFX( "fx/temp/cornered/cnd_building_fall" );
	level._effect[ "cnd_building_fall_sign" ] 				= LoadFX( "fx/temp/cornered/cnd_building_fall_sign" );
	level._effect[ "vfx_atrium_tile" ] 						= LoadFX( "vfx/moments/cornered/vfx_atrium_tile" );
	
	// Ending
	level._effect[ "cnd_diablo_rays" ] 						= LoadFX( "fx/temp/cornered/cnd_diablo_rays" );
	level._effect[ "cnd_explosion_horizontal" ] 			= LoadFX( "fx/temp/cornered/cnd_explosion_horizontal" );
	level._effect[ "cnd_explosion_horizontal_sm" ] 			= LoadFX( "fx/temp/cornered/cnd_explosion_horizontal_sm" );
	level._effect[ "cnd_diablo_rays_wide" ] 				= LoadFX( "fx/temp/cornered/cnd_diablo_rays_wide" );
	level._effect[ "policelights_red" ] 					= LoadFX( "vfx/moments/cornered/policelights_red" );
	level._effect[ "policelights" ] 						= LoadFX( "vfx/moments/cornered/policelights" );
	level._effect[ "cnd_building_fall_close" ] 				= loadfx( "fx/temp/cornered/cnd_building_fall_close" );
	level._effect[ "vfx_glass_falling" ] 					= loadfx( "vfx/moments/cornered/vfx_glass_falling" );
	level._effect[ "spark_large_fountain02" ] 				= loadfx( "vfx/moments/cornered/spark_large_fountain02" );
	level._effect[ "spark_large_fountain" ] 				= loadfx( "vfx/moments/cornered/spark_large_fountain" );
	
	/// Glass cutting entry
	level._effect[ "vfx_torch_cutting_window_open_papers" ] = LoadFX( "vfx/moments/cornered/vfx_torch_cutting_window_open_papers" );
	level._effect[ "torch_cutting_glass_spark_ondeath2" ] 	= LoadFX( "vfx/moments/cornered/torch_cutting_glass_spark_ondeath2" );
	level._effect[ "torch_cutting_glass_heatribbon_path" ] 	= LoadFX( "vfx/moments/cornered/torch_cutting_glass_heatribbon_path" );
	level._effect[ "torch_cutting_glass_spark_crack" ] 		= LoadFX( "vfx/moments/cornered/torch_cutting_glass_spark_crack" );
	level._effect[ "torch_cutting_glass_spark_ondeath" ] 	= LoadFX( "vfx/moments/cornered/torch_cutting_glass_spark_ondeath" );
	level._effect[ "vfx_torch_cutting_window_open" ] 		= LoadFX( "vfx/moments/cornered/vfx_torch_cutting_window_open" );
	level._effect[ "torch_cutting_glass_spark_crack_revend"]= LoadFX( "vfx/moments/cornered/torch_cutting_glass_spark_crack_revend" );
	level._effect[ "torch_cutting_glass_spark_crack_rev" ] 	= LoadFX( "vfx/moments/cornered/torch_cutting_glass_spark_crack_rev" );
	level._effect[ "torch_cutting_glass_heatribbon" ] 		= LoadFX( "vfx/moments/cornered/torch_cutting_glass_heatribbon" );
	level._effect[ "torch_cutting_glass_heatribbon_player" ]= LoadFX( "vfx/moments/cornered/torch_cutting_glass_heatribbon_player" );
	level._effect[ "torch_cutting_glass_beam_player" ] 		= LoadFX( "vfx/moments/cornered/torch_cutting_glass_beam_player" );
	level._effect[ "torch_cutting_glass_beam" ] 			= LoadFX( "vfx/moments/cornered/torch_cutting_glass_beam" );
	level._effect[ "torch_cutting_glass_spark" ] 			= LoadFX( "vfx/moments/cornered/torch_cutting_glass_spark" );
	level._effect[ "paper_blowing_stack_flat_cluster" ] 	= LoadFX( "fx/misc/paper_blowing_stack_flat_cluster" );
	level._effect[ "paper_blowing_stack_impact" ] 			= LoadFX( "fx/misc/paper_blowing_stack_impact" );
	
	/// Zipline
	level._effect[ "fireworks" ]							= LoadFX( "fx/temp/cornered/fireworks" );
	level._effect[ "vfx_fireworks_meteors_trails" ]			= LoadFX( "vfx/moments/cornered/vfx_fireworks_meteors_trails" );
	level._effect[ "vfx_fireworks_ground_straight_single" ] = LoadFX( "vfx/moments/cornered/vfx_fireworks_ground_straight_single" );
	level._effect[ "vfx_fireworks_groundflare_oneshot2" ] 	= LoadFX( "vfx/moments/cornered/vfx_fireworks_groundflare_oneshot2" );
	level._effect[ "vfx_fireworks_groundflare_oneshot" ]	= LoadFX( "vfx/moments/cornered/vfx_fireworks_groundflare_oneshot" );
	level._effect[ "vfx_fireworks_ground_straight" ] 		= LoadFX( "vfx/moments/cornered/vfx_fireworks_ground_straight" );
	level._effect[ "vfx_fireworks_flare_explosion_p" ] 		= LoadFX( "vfx/moments/cornered/vfx_fireworks_flare_explosion_p" );
	level._effect[ "vfx_fireworks_sparkle_large" ]			= LoadFX( "vfx/moments/cornered/vfx_fireworks_sparkle_large" );
	level._effect[ "vfx_fireworks_flare_explosion" ] 		= LoadFX( "vfx/moments/cornered/vfx_fireworks_flare_explosion" );
	level._effect[ "vfx_fireworks_lingeringsmoke_r" ] 		= LoadFX( "vfx/moments/cornered/vfx_fireworks_lingeringsmoke_r" );
	level._effect[ "vfx_fireworks_lingeringsmoke" ] 		= LoadFX( "vfx/moments/cornered/vfx_fireworks_lingeringsmoke" );
	level._effect[ "vfx_fireworks_groundflare_oneshot3" ] 	= LoadFX( "vfx/moments/cornered/vfx_fireworks_groundflare_oneshot3" );
	level._effect[ "fireworks_red_lrg" ]					= LoadFX( "fx/explosions/fireworks_red_lrg" );
	level._effect[ "fireworks_red" ]						= LoadFX( "fx/explosions/fireworks_red" );	
	level._effect[ "fireworks_blue_lrg" ]					= LoadFX( "fx/explosions/fireworks_blue_lrg" );	
	level._effect[ "fireworks_blue" ]						= LoadFX( "fx/explosions/fireworks_blue" );		
	level._effect[ "fireworks_red_trail" ]					= LoadFX( "fx/explosions/fireworks_red_trail" );
	level._effect[ "fireworks_green_ch" ] 					= LoadFX( "fx/explosions/fireworks_green_ch" );
	level._effect[ "fireworks_white_falling_lg" ] 			= LoadFX( "fx/explosions/fireworks_white_falling_lg" );
	level._effect[ "fireworks_blue_falling" ] 				= LoadFX( "fx/explosions/fireworks_blue_falling" );
	level._effect[ "fireworks_white_lrg" ] 					= LoadFX( "fx/explosions/fireworks_white_lrg" );
	level._effect[ "fireworks_purple_lrg" ] 				= LoadFX( "fx/explosions/fireworks_purple_lrg" );
	level._effect[ "fireworks_green_lrg" ] 					= LoadFX( "fx/explosions/fireworks_green_lrg" );
	level._effect[ "fireworks_purple" ] 					= LoadFX( "fx/explosions/fireworks_purple" );
	level._effect[ "fireworks_white_falling_thin" ] 		= LoadFX( "fx/explosions/fireworks_white_falling_thin" );
	level._effect[ "fireworks_white_falling" ] 				= LoadFX( "fx/explosions/fireworks_white_falling" );
	level._effect[ "fireworks_green" ] 						= LoadFX( "fx/explosions/fireworks_green" );
	level._effect[ "fireworks_white" ] 						= LoadFX( "fx/explosions/fireworks_white" );
	level._effect[ "fireworks_popping" ] 					= LoadFX( "fx/explosions/fireworks_popping" );
	
	/// Screen FX - Zipline
	level._effect[ "raindrops_screen_3_0" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_3_0" );
	level._effect[ "raindrops_screen_3_1" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_3_1" );
	level._effect[ "raindrops_screen_3_2" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_3_2" );
	level._effect[ "raindrops_screen_3_3" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_3_3" );
	level._effect[ "raindrops_screen_3_4" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_3_4" );
	level._effect[ "raindrops_screen_5_0" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_5_0" );
	level._effect[ "raindrops_screen_5_1" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_5_1" );
	level._effect[ "raindrops_screen_5_2" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_5_2" );
	level._effect[ "raindrops_screen_5_3" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_5_3" );
	level._effect[ "raindrops_screen_5_4" ]					= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_5_4" );
	level._effect[ "raindrops_screen_10_0" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_10_0" );
	level._effect[ "raindrops_screen_10_1" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_10_1" );
	level._effect[ "raindrops_screen_10_2" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_10_2" );
	level._effect[ "raindrops_screen_10_3" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_10_3" );
	level._effect[ "raindrops_screen_10_4" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_10_4" );
	level._effect[ "raindrops_screen_20_0" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_20_0" );
	level._effect[ "raindrops_screen_20_1" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_20_1" );
	level._effect[ "raindrops_screen_20_2" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_20_2" );
	level._effect[ "raindrops_screen_20_3" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_20_3" );
	level._effect[ "raindrops_screen_20_4" ]				= LoadFX( "vfx/gameplay/screen_effects/raindrops_screen_20_4" );
	
	level._effect[ "neck_stab_blood" ]						= LoadFX( "vfx/moments/cornered/vfx_neck_stab_blood" );
		
	// Chopper spotlight
	level._effect["spotlight"] 								= LoadFX("fx/lights/lights_spotlight_heli_search_nosnow");

	
	
	
	/// Createfx
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\cornered_fx::main();
		if ( GetDvar( "createfx" ) == "" )
			grab_firework_effects();
		maps\createfx\cornered_sound::main();
	}
}

treadfx_override()
{
	rooftop_treadfx = "fx/treadfx/heli_dust_infinite";
	maps\_treadfx::setallvehiclefx( "script_vehicle_nh90_no_lod", rooftop_treadfx );
}


delete_stage_one_fx()
{
	if ( IsDefined( level.smoke_effect_tags ) )
	{
		for ( i = 0; i < level.smoke_effect_tags.size; i++ )
		{
			level.smoke_effect_tags[ i ] Unlink();
			level.smoke_effect_tags[ i ].origin = ( 0, 0, 0 );
			StopFXOnTag( level._effect[ level.vfxarry[ i ].v[ "fxid" ]], level.smoke_effect_tags[ i ], "tag_origin" );
		}
	}
	handle_stage_two_fx();
}

handle_stage_two_fx()
{
	vfxarry = get_exploder_array( 9876 );

	/* * Smoke columns effects**/
	foreach ( ent in vfxarry )
	{
		fx_up  = AnglesToUp( ent.v[ "angles" ] );
		fx_fwd = AnglesToForward( ent.v[ "angles" ] );
		fx	   = SpawnFx( level._effect[ ent.v[ "fxid" ]], ent.v[ "origin" ], fx_fwd, fx_up );
		TriggerFX( fx, -2240 );
	}
}

fx_checkpoint_states()
{
    // Per section ambient FX states
	start = level.start_point;
	
	if ( start == "intro" )
    {
		exploder (3456); // FX crowd
		stop_exploder(67);
	}
	
	if ( start == "rappel_stealth" )
    {
		exploder (3456); // FX crowd
		stop_exploder(67);
	}
	
	if ( start == "inverted_rappel" )
    {
		exploder (3456); // FX crowd
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		stop_exploder(67);

    }
	if ( start == "courtyard" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		stop_exploder(23); // turn off helipad lights
		stop_exploder(67);

    }
	if ( start == "bar" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		exploder(13);  // Godrays in office
		stop_exploder(23); // turn off helipad lights
		stop_exploder(67);
	}
	if ( start == "junction" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		exploder(14); // ambient fx in junction
		stop_exploder(23); // turn off helipad lights
		stop_exploder(67);
	}
	if ( start == "rappel" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		exploder(14); // ambient fx in junction
		stop_exploder(23); // turn off helipad lights
		stop_exploder(67);
		
	}
	if ( start == "garden" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		exploder(1200); // ambient fx in garden
		stop_exploder(23); // turn off helipad lights
		stop_exploder(67);
	}
	if ( start == "hvt_capture" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		exploder(1200); // ambient fx in garden
		stop_exploder(23); // turn off helipad lights
		stop_exploder(67);
	}
	if ( start == "atrium" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		stop_exploder(20); //turn off blue light shaft fx
		stop_exploder(23); // turn off helipad lights
		stop_exploder(67);
	}
	if ( start == "horizontal" )
    {
		stop_exploder(10); //turn off fx on top of heli building if starting from checkpoint
		stop_exploder(20); //turn off blue light shaft fx
		stop_exploder(22); //turn off building lights
		stop_exploder(23); //turn off helipad lights
		stop_exploder(67);
		
	}

}

activate_fireworks_exploder( num )
{
	num += "";
	
	if ( !IsDefined( level.fireworksFX ) )
	{
		common_scripts\utility::activate_exploder( num );
		return;
	}

	//here's a hook so you can know when a certain number of an exploder is going off
	level notify( "exploding_" + num );
	
	found_exploder = false;
	
	for ( i = 0; i < level.fireworksFX.size; i++ )
	{
		ent = level.fireworksFX[ i ];
		if ( !isdefined( ent ) )
			continue;

		if ( !isdefined( ent.exploder ) )
			continue;

		if ( ent.exploder + "" != num )
			continue;

		ent thread activate_individual_fireworks_exploder();
		found_exploder = true;
	}
	
	if ( !found_exploder )
		common_scripts\utility::activate_exploder( num );
}

activate_individual_fireworks_exploder()
{
	if ( IsDefined( self.delay ) )
		wait self.delay;
		
	if ( IsDefined( self.fxent ) )
		self.fxent Delete();

	forward = AnglesToForward( self.angles );
	up = AnglesToUp( self.angles );
	self.fxent = SpawnFx( common_scripts\utility::getfx( self.fxid ), self.origin, forward, up );
	TriggerFX( self.fxent );
	
	if ( IsDefined( self.soundalias ) )
		common_scripts\utility::play_sound_in_space( self.soundalias, self.origin );
}

grab_firework_effects()
{
	if ( IsDefined( level.fireworksFX ) )
		return;
		
	newCreateFx = [];
	level.fireworksFX = [];
	
	for ( i = 0; i < level.createFXent.size; i++ )
	{
		ent = level.createFXent[ i ];
		if ( !isdefined( ent ) )
		{
			newCreateFx[ newCreateFx.size ] = ent;
			continue;
		}

		if ( ent.v[ "type" ] != "exploder" )
		{
			newCreateFx[ newCreateFx.size ] = ent;
			continue;
		}

		// make the exploder actually removed the array instead?
		if ( !isdefined( ent.v[ "exploder" ] ) )
		{
			newCreateFx[ newCreateFx.size ] = ent;
			continue;
		}

		if ( !IsSubStr( ent.v[ "fxid" ], "firework" ) )
		{
			newCreateFx[ newCreateFx.size ] = ent;
			continue;
		}

		level.fireworksFX[ level.fireworksFX.size ] = convert_to_fireworks_effect( ent );
		ent = undefined;
	}
	
	level.createFXent = newCreateFx;
}

convert_to_fireworks_effect( ent )
{
	ent2 = SpawnStruct();
	ent2.fxid	 = ent.v[ "fxid" ];
	ent2.origin	 = ent.v[ "origin" ];
	ent2.angles	 = ent.v[ "angles" ];
	ent2.exploder = ent.v[ "exploder" ];
	
	if ( IsDefined( ent.v[ "soundalias" ] ) )
		ent2.soundalias = ent.v[ "soundalias" ];
	
	if ( IsDefined( ent.v[ "delay" ] ) )
		ent2.delay = ent.v[ "delay" ];
	
	return ent2;
}

fx_screen_raindrops_cleanup()
{
	level waittill( "fx_screen_raindrops_done" );
	
	wait 0.5;
	
	level.screenRain Delete();
}

fx_screen_raindrops_fast_kill()
{
	level notify( "fx_screen_raindrops_kill" );
	level.screenRain Delete();
}

fx_screen_raindrops()
{
	level endon( "fx_screen_raindrops_done" );
	level endon( "fx_screen_raindrops_kill" );
	
	level.screenRain = Spawn( "script_model", ( 0, 0, 0 ) );
	level.screenRain SetModel( "tag_origin" );
	level.screenRain.origin = level.player.origin;
	level.screenRain LinkToPlayerView ( level.player, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
	
	SetDevDvarIfUninitialized( "screen_rain_repeat_seconds", 0.2 );
	SetDevDvarIfUninitialized( "screen_rain_zipline_repeat_seconds", 0.01 );
	SetDevDvarIfUninitialized( "screen_rain_wind_repeat_seconds", 0.01 );
	SetDevDvarIfUninitialized( "screen_rain_wind_strength_to_play", 0.5 );
//	SetDevDvarIfUninitialized( "screen_rain_chance_water_sheet", 20 );
	
	thread fx_screen_raindrops_cleanup();

	i = 0;
	
	while ( true )
	{
		if ( !flag( "fx_screen_raindrops" ) )
		{
			level waittill( "fx_screen_raindrops" );
			
			if ( !flag( "fx_screen_raindrops" ) )
				continue;
		}
		
		sheeted = false;
		upAngle = level.player GetPlayerAngles();

		if ( !sheeted && upAngle[ 0 ] < -55 && RandomInt( 100 ) < GetDvarInt( "screen_rain_chance_water_sheet", 20 ) )
		{
		}

		i = i + 1;
		
		if ( i > 4 )
		{
			i = 0;
		}

		if ( flag( "player_is_ziplining" ) )
		{
		if ( upAngle[ 0 ] < -40 )
		{
			PlayFXOnTag( level._effect[ "raindrops_screen_20_" + i ], level.screenRain, "tag_origin" );
		}
		else if ( upAngle[ 0 ] < -25 )
		{
			PlayFXOnTag( level._effect[ "raindrops_screen_10_" + i ], level.screenRain, "tag_origin" );
		}
		else if ( upAngle[ 0 ] < 25 )
		{
			PlayFXOnTag( level._effect[ "raindrops_screen_5_" + i ], level.screenRain, "tag_origin" );
		}
		else if ( upAngle[ 0 ] < 40 )
		{
			PlayFXOnTag( level._effect[ "raindrops_screen_3_" + i ], level.screenRain, "tag_origin" );
		}
		}
			wait GetDvarFloat( "screen_rain_zipline_repeat_seconds", 0.01 );
	}
}
