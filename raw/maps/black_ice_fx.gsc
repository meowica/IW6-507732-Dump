#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include animscripts\utility;
#include maps\_hud_util;

main()
{	
	level._effect[ "heli_spotlight" ] = loadfx( "vfx/moments/black_ice/vfx_spotlight_heli_model" );
	level._effect[ "glow_cone_cloudy_dust_01" ] = loadfx( "vfx/moments/black_ice/vfx_glow_cone_cloudy_dust_01" );
	level._effect[ "glow_tv_small_01" ] = loadfx( "vfx/moments/black_ice/vfx_glow_tv_small_01" );
	level._effect[ "glow_tv_med_01" ] = loadfx( "vfx/moments/black_ice/vfx_glow_tv_med_01" );
	level._effect[ "glow_flourescent_bulb_01" ] = loadfx( "vfx/moments/black_ice/vfx_glow_flourescent_bulb_01" );
	level._effect[ "glow_tv_large_flicker" ] = loadfx( "vfx/moments/black_ice/vfx_glow_tv_large_flicker" );
	level._effect[ "flare_light_yllwgrn_square_cone1" ] = loadfx( "vfx/moments/black_ice/vfx_flare_light_yllwgrn_square_cone1" );
	level._effect[ "smk_hanging_gray_01" ] = loadfx( "vfx/moments/black_ice/vfx_smk_hanging_gray_01_before" );
	level._effect[ "smk_hanging_orange_01" ] = loadfx( "vfx/moments/black_ice/vfx_smk_hanging_orange_01_before" );
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\black_ice_fx::main();
		maps\createfx\black_ice_sound::main();
	}
	
	//temp
	
	level._effect[ "vfx_rig_fire_exfil_huge" ] = loadfx( "vfx/moments/black_ice/vfx_rig_fire_exfil_huge" );
	level._effect[ "exfil_light_explode" ] 			= LoadFX( "fx/explosions/sparks_light_explode_blackice" );
	//level._effect[ "exfil_siren_red" ] 			= LoadFX( "fx/lights/siren_light_red" );
	level._effect[ "flarestack_siren_red" ] 		= LoadFX( "fx/lights/siren_light_red_big" );
	level._effect[ "command_siren_red" ] 			= LoadFX( "fx/lights/siren_light_red_static" );
	level._effect[ "command_siren_red_low" ] 		= LoadFX( "fx/lights/siren_light_red_static_low" );
	//level._effect[ "exfil_siren_red_cheap" ] 		= LoadFX( "fx/lights/siren_light_red_cheap" );
	//level._effect[ "exfil_siren_yellow_cheap" ] 	= LoadFX( "fx/lights/siren_light_yellow_cheap" );
	level._effect[ "oil_rain_pipedeck" ]			= LoadFX( "fx/misc/blackice_oil_rain_pipedeck" );
	level._effect[ "steam_flamestack_shutdown" ]	= LoadFX( "vfx/moments/black_ice/vfx_flarestack_pipeburst_sequence_01" );
    level._effect[ "oil_rain_tanks" ]			    = LoadFX( "fx/misc/blackice_oil_rain_tanks" );
	level._effect[ "flamestack_hand_Scan" ]			= LoadFX( "fx/misc/blackice_hand_scan" );
	//level._effect[ "flamestack_hand_Scan_off" ]		= LoadFX( "fx/misc/blackice_hand_scan_off" );

	level._effect[ "flamestack_snow_door_open" ] 	= LoadFX( "fx/misc/blackice_snow_door_open" );
	level._effect[ "refinery_pipe_explosion_small" ]= LoadFX( "fx/explosions/blackice_refinery_prederrick_small" );
	level._effect[ "refinery_pipe_explosion_large" ]= LoadFX( "fx/explosions/blackice_refinery_prederrick_large" );
	level._effect[ "exfil_steam_burst" ]			= LoadFX( "fx/smoke/steam_jet_large_blackice" );
	level._effect[ "exfil_steam_small" ]			= LoadFX( "fx/smoke/blackice_steam_engineroom_small" );
	level._effect[ "exfil_wall_alarm_yellow" ] 		= LoadFX( "fx/misc/blackice_wall_alarm_yellow" );	
	//level._effect[ "exfil_ceiling_smoke" ] 		= LoadFX( "fx/smoke/hallway_smoke_thin_blackice" );
	level._effect[ "smoke_doorway_windy" ] 			= LoadFX( "fx/smoke/doorway_smoke_windy_blackice" );
	level._effect[ "fire_tanks_pipefire_windy" ] 	= LoadFX( "fx/fire/blackice_oil_pipe_fire_windy" );
	level._effect[ "tanks_fire_huge" ] 				= LoadFX( "vfx/ambient/fire/fuel/vfx_fire_windy_fireball_large_01" );
	level._effect[ "icehole_light" ]     			= LoadFX( "fx/misc/blackice_icehole_light" );
	level._effect[ "icehole_godray" ] 				= loadfx( "vfx/ambient/lights/vfx_godray_underice_anim" );
	level._effect[ "hind_turret_impacts" ]  		= LoadFX( "fx/impacts/hind_turret_blackice_runner" );
	level._effect[ "exfil_view_explosion" ]  		= LoadFX( "fx/explosions/blackice_exfil_viewscreen_explosion" );
	level._effect[ "exfil_command_fail_blast" ]  	= LoadFX( "fx/explosions/blackice_explosion_large" );
	level._effect[ "console_command_start" ]  		= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_start" );
	level._effect[ "console_command_timer" ]  		= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_timer" );
	level._effect[ "console_command_green_u" ]  	= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_green_u" );
	level._effect[ "console_command_green_d" ]  	= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_green_d" );
	level._effect[ "console_command_yellow_u" ]  	= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_yellow_u" );
	level._effect[ "console_command_yellow_d" ]  	= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_yellow_d" );
	level._effect[ "console_command_red_u" ]  		= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_red_u" );
	level._effect[ "console_command_red_d" ]  		= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_red_d" );
	level._effect[ "console_command_end" ]  		= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_end" );
	level._effect[ "console_command_fail" ]  		= LoadFX( "vfx/moments/black_ice/vfx_console_command_display_fail" );
	level._effect[ "command_control_explosion" ] 	= LoadFX( "fx/explosions/blackice_refinery_oiltank_huge" );
	level._effect[ "command_console_baker" ]		= loadfx( "vfx/moments/black_ice/vfx_console_command_display_baker" );
 	level._effect[ "command_console_baker_sm" ]		= loadfx( "vfx/moments/black_ice/vfx_console_command_display_baker_sm" );
 	level._effect[ "hind_shell_eject" ]				= loadfx( "fx/shellejects/hind_turret_shell_blackice" );
 	level._effect[ "breacher_light_green" ] 		= LoadFX( "fx/misc/light_breacher_green" );	
 	level._effect[ "breacher_light_red" ] 			= LoadFX( "fx/misc/light_breacher_red" );
 	level._effect[ "truck_underside" ] 				= LoadFX( "vfx/moments/black_ice/blackice_bouncelight_undertruck" );
 	level._effect[ "exfil_rigcollapse_splash" ] 	= LoadFX( "vfx/moments/black_ice/vfx_rigcollapse_splash" );
 	level._effect[ "exfil_sphere_trail" ] 			= LoadFX( "fx/smoke/blackice_exfil_sphere_trail" );
 	level._effect[ "exfil_helospotlight_explode" ] 	= LoadFX( "fx/explosions/spotlight_explode_blackice" );
	
	//under_water_intro
	level._effect[ "ice_breach_explosion" ] 		= LoadFX( "fx/explosions/underwater_breach_charge_large_blackice" );
	level._effect[ "ice_breach_collapse" ]			= LoadFX( "fx/misc/underwater_ice_collapse" );
	level._effect[ "glowstick_orange" ] 			= LoadFX( "fx/misc/glow_stick_glow_orange_blackice" );
	level._effect[ "glowstick_orange_fade" ] 		= LoadFX( "fx/misc/glow_stick_glow_orange_fade_blackice" );
 	level._effect[ "snake_cam_waterline_under" ] 	= LoadFX( "vfx/moments/flood/water_waterline_swept_01" );
	level._effect[ "scuba_bubbles" ] 				= LoadFX( "vfx/moments/ship_graveyard/scuba_bubbles_plr_front" );
	level._effect[ "scuba_bubbles_friendly" ] 		= LoadFX( "vfx/ambient/water/bubbles_breath_hero" );
	level._effect[ "scuba_mask_distortion" ]		= LoadFX( "vfx/moments/ship_graveyard/scuba_mask_distortion" );
	level._effect[ "swim_kick_bubble" ]				= LoadFX( "vfx/gameplay/footsteps/swim_kick_bubbles" );
	level._effect[ "swim_ai_blood_impact" ] 		= LoadFX( "fx/water/blood_spurt_underwater"		 );
	level._effect[ "swim_ai_death_blood"	] 		= LoadFX( "fx/impacts/deathfx_bloodpool_underwater" );
	level._effect[ "water_particulate_headlight" ] 	= LoadFX( "fx/water/ocean_particulate_in_spotlight"  );
	level._effect[ "water_particulate_01" ] 	    = LoadFX( "fx/water/ocean_particulate_dark" );
	level._effect[ "mine_light" ] 					= loadfx( "vfx/ambient/lights/vfx_glow_red_light_100_blinker_undrwater" );
	level._effect[ "water_bubble_cloud_descent_med" ] = loadfx( "vfx/moments/black_ice/underwater_gascloud_med_emit" );
	
	//snow
	level._effect[ "snow_blowoff_ledge_loop" ] 		= LoadFX( "fx/snow/snow_blowoff_ledge_oriented" );	
	level._effect[ "snow_blowoff_edge_small" ] 		= loadfx( "vfx/moments/black_ice/vfx_snow_blowoff_edge_small_black_ice" );
	level._effect[ "snow_wind" ] 					= LoadFX( "vfx/moments/black_ice/snow_wind_black_ice" ); 
    level._effect[ "snow_drift" ] 					= LoadFX( "fx/snow/snow_ground_oriented_drift_blackice" );
	level._effect[ "cold_breath" ]				    = loadfx( "fx/misc/cold_breath_cheap" );
	level._effect[ "snow_wind_fast" ] 				= LoadFX( "vfx/moments/black_ice/vfx_snow_wind_fast_black_ice" );
	level._effect[ "snow_wind_fast_short" ] 		= LoadFX( "vfx/moments/black_ice/vfx_snow_wind_fast_short_black_ice" ); 	
	level._effect[ "snow_wind_tanks" ] 				= LoadFX( "fx/snow/snow_wind_tanks_blackice" ); 
	level._effect[ "snow_wind_catwalks" ] 			= LoadFX( "fx/snow/snow_wind_catwalks_blackice" ); 
	level._effect[ "snow_wind_ascend_huge" ] 		= LoadFX( "fx/snow/snow_wind_ascend_huge_blackice" ); 	
	level._effect[ "snow_wind_catwalks_windtunnel" ]= LoadFX( "fx/snow/snow_wind_catwalks_windtunnel_blackice" ); 
	level._effect[ "snow_wind_ascend" ]				= LoadFX( "fx/snow/snow_wind_ascend_blackice" ); 		
	level._effect[ "snow_drift_heavy" ] 			= LoadFX( "fx/snow/snow_ground_oriented_drift_heavy_blackice" ); 
	level._effect[ "snow_drift_tanks" ] 			= LoadFX( "fx/snow/snow_ground_drift_tanks_blackice");
	level._effect[ "catwalks_snow_door_open" ] 		= LoadFX( "fx/misc/blackice_snow_door_open_inward" );
	level._effect[ "catwalks_snow_door_open_ground" ]= LoadFX( "fx/misc/blackice_snow_door_open_inward_ground" );
	level._effect[ "snow_blowoff_ledge_loop_heavy" ]= LoadFX( "fx/snow/snow_blowoff_ledge_oriented_heavy" );
	level._effect[ "shockwave_snow_disturb" ]     	= LoadFX( "fx/misc/blackice_snow_shockwave_disturb" );
	level._effect[ "shockwave_snow_disturb_small" ] = LoadFX( "fx/misc/blackice_snow_shockwave_disturb_small" );
	level._effect[ "shockwave_snow_disturb_huge" ]  = LoadFX( "fx/misc/blackice_snow_shockwave_disturb_huge" );
	
    // vehicle_lights
    level._effect[ "headlight_bm21_underwater" ]	 = loadfx( "vfx/moments/black_ice/headlight_bm21_underwater" );
	level._effect[ "headlight_bm21_underwater_flicker" ] = loadfx( "vfx/moments/black_ice/headlight_bm21_underwater_flicker" );
	level._effect[ "headlight_gaz_underwater" ] 	= loadfx( "vfx/moments/black_ice/headlight_gaz_underwater" );
	level._effect[ "vehicle_gaz_brakelight" ] 		= LoadFX( "fx/misc/car_taillight_btr80_eye" );
	level._effect[ "vehicle_bm21_headlight_spotlight" ] = LoadFX( "fx/lights/spotlight_bm21_headlights_blackice" );
	level._effect[ "vehicle_bm21_brakelight" ]		= LoadFX( "fx/misc/car_brakelight_bm21" );
	level._effect[ "vehicle_bm21_brakelight_light" ] = LoadFX( "fx/lights/blackice_taillight_light" );
	level._effect[ "vfx_aircraft_light_red_blink_fog" ] = loadfx( "vfx/moments/black_ice/vfx_aircraft_light_red_blink_fog" );
	level._effect[ "vfx_aircraft_light_white_blink_fog" ] = loadfx( "vfx/moments/black_ice/vfx_aircraft_light_white_blink_fog" );
	level._effect[ "vfx_aircraft_light_green_blink_fog" ] = loadfx( "vfx/moments/black_ice/vfx_aircraft_light_green_blink_fog" );
	
	//vehicle_exhaust
	level._effect[ "truck_exhaust" ] 				= LoadFX( "fx/smoke/blackice_truck_exhaust" );
	
	// Bullet FX
	level._effect[ "ice_infil_underwater_bullet_trail" ] = LoadFX( "fx/water/ice_infil_underwater_bullet_trail" );
	
	//catwalk breach
	level._effect[ "catwalk_det_tape" ]				= LoadFX( "fx/explosions/door_breach_metal_tape_blackice" );
	
	// Common Room Breach
	level._effect[ "common_breach_charge" ] = LoadFX( "fx/explosions/blackice_commonroom_breach" );
	level._effect[ "common_breach_damaged_breacher"	  ] = LoadFX( "fx/misc/blackice_damaged_breacher" );
	
	// Explosion for derrick
	level._effect[ "derrick_explode_small" ]		= LoadFX( "fx/explosions/oil_derrick_explosion_02" );
	level._effect[ "derrick_explode_large" ] 		= LoadFX( "fx/explosions/oil_derrick_explosion_01" );
	level._effect[ "derrick_dirt_shockwave" ]	    = LoadFX( "fx/explosions/oil_derrick_collapse_shockwave" );
	
	//amb derrick fx
	level._effect[ "smoke_blowing_gray_large" ] 	    = LoadFX( "fx/smoke/smoke_large_cheap_grey" );
	level._effect[ "smoke_blowing_hot_large" ]   	    = LoadFX( "fx/smoke/smoke_large_hot" );
	level._effect[ "smoke_blowing_white_white" ]   	    = LoadFX( "fx/smoke/steam_vent_large_windslow" );
	level._effect[ "smoke_blowing_white_white_2" ] 		= LoadFX( "vfx/ambient/smoke/vfx_steam_stack_blowing_drkprpl_1" );
	level._effect[ "smoke_blowing_white_2_shockwave" ]  = loadfx( "vfx/ambient/smoke/vfx_steam_stack_blown_drkprpl_1" );
	level._effect[ "red_light_derrick_01" ]				= loadfx( "vfx/ambient/lights/vfx_glow_red_light_200_nolight" );
	level._effect[ "red_light_derrick_oscillator_01" ]	= loadfx( "vfx/ambient/lights/vfx_glow_red_light_200_oscillate_nolight" );
	level._effect[ "red_light_derrick_blinking_01" ]	= loadfx( "vfx/ambient/lights/vfx_glow_red_light_400_blinker_nolight" );
	level._effect[ "blue_light_derrick_01" ]			= loadfx( "vfx/ambient/lights/vfx_glow_blue_light_200_nolight" );
	level._effect[ "warm_light_derrick_01" ]			= loadfx( "vfx/ambient/lights/vfx_warm_light_oriented_square_nolight" );
	
	// Sniper Flesh FX
	level._effect[ "flesh_hit" ]					= LoadFX( "fx/impacts/flesh_hit" );
	
	// Helo Spotlight
	level._effect[ "catwalk_spot"		] 			= LoadFX( "fx/lights/lights_spotlight_heli_search" );
	level._effect[ "catwalk_spot_cheap" ] 			= loadfx( "vfx/moments/black_ice/vfx_spotlight_search_snow_cheap" );
	
	//fire_and_suppresion
	level._effect[ "fire_sputter_med" ] 			= LoadFX( "fx/fire/oil_fire_suppressed" );
	level._effect[ "fire_oil_burnoff_01" ] 		    = LoadFX( "fx/fire/oil_burnoff" );
	level._effect[ "fire_oil_burnoff_extinguish" ] 	= LoadFX( "fx/fire/oil_burnoff_extinguish" );
	level._effect[ "water_sprinkler_01" ] 			= LoadFX( "vfx/ambient/water/water_sprinkler_high_pressure" );
	level._effect[ "fire_burning_oil_patch_01" ] 	= LoadFX( "fx/fire/burning_oil_patch" );
	level._effect[ "fire_falling_point" ] 			= LoadFX( "vfx/ambient/fire/dripping/vfx_fire_falling_runner_pnt_1_dlt" );
	level._effect[ "smoke_dark_large_cloud" ] 		= LoadFX( "fx/smoke/dark_smoke_cloud_large_blackice" );
	level._effect[ "fire_grounded_med_01" ] 		= LoadFX( "vfx/ambient/fire/vfx_fire_grounded_med_nxglight" );
	level._effect[ "fire_grounded_large_01" ] 		= loadfx( "vfx/ambient/fire/vfx_fire_grounded_large_nxglight" );
	level._effect[ "sparks_twisty_blown_500x1000" ] = loadfx( "vfx/ambient/sparks/vfx_sparks_twisty_blown_500x1000" );
	level._effect[ "fire_grounded_xtralarge" ] 		= loadfx( "vfx/ambient/fire/vfx_fire_grounded_xtralarge_nxglight" );
    level._effect[ "fire_ceiling_large_fade_01" ] 	= LoadFX( "vfx/ambient/fire/wall/vfx_fire_wall_lg_nofog_ae_fade" );
	level._effect[ "fire_ceiling_large_01" ] 		= LoadFX( "vfx/ambient/fire/wall/vfx_fire_wall_lg" );
    level._effect[ "fire_fireball_hall_large_01" ] 	= LoadFX( "vfx/moments/black_ice/vfx_fireball_hall_blocking_large" );
	level._effect[ "fire_fireball_med_01" ] 	    = LoadFX( "fx/fire/blackice_fireball_med" );
	level._effect[ "fire_glow_med_01" ] 	        = LoadFX( "vfx/ambient/lights/vfx_glow_fire_200_nolight_ae" );
	level._effect[ "fire_grounded_engine_room" ] 	= LoadFX( "fx/fire/blackice_fire_grounded_engine_room" );
	level._effect[ "fire_supression_pipedeck" ] 	= LoadFX( "fx/water/blackice_fire_supression" );
	level._effect[ "fire_supression_shutdown_a" ] 	= LoadFX( "fx/water/blackice_fire_supression_shutdown_a" );
	level._effect[ "fire_supression_shutdown_b" ] 	= LoadFX( "fx/water/blackice_fire_supression_shutdown_b" );
	level._effect[ "fire_supression_shutdown_c" ] 	= LoadFX( "fx/water/blackice_fire_supression_shutdown_c" );
	level._effect[ "fire_supression_shutdown_d" ] 	= LoadFX( "fx/water/blackice_fire_supression_shutdown_d" );
	level._effect[ "fire_supression_shutdown_e" ] 	= LoadFX( "fx/water/blackice_fire_supression_shutdown_e" );
	level._effect[ "fire_supression_shutdown_f" ] 	= LoadFX( "fx/water/blackice_fire_supression_shutdown_f" );
	
	//refinery
	level._effect[ "light_yellow_emergency_01" ] 	= LoadFX( "vfx/ambient/lights/vfx_yellow_emergency_strobe_100");
	
	//steam
	level._effect[ "steam_jet_medium_01" ] 		     = LoadFX( "vfx/moments/black_ice/vfx_steam_pipe_burst_linger_01" );
	level._effect[ "pipe_deck_steam_jet" ]			= LoadFX( "fx/smoke/halon_gas_jet" );
	
	// derrick explosion debris and fallout and refinery
	level._effect[ "refinery_debris_explosion" ] 	= LoadFX( "vfx/gameplay/explosions/vfx_exp_oiltank_lg" );
	level._effect[ "refinery_debris_trail_large" ] 	= LoadFX( "fx/smoke/blackice_debris_trail_large" );
	level._effect[ "refinery_debris_trail_small" ]	= LoadFX( "fx/smoke/blackice_debris_trail_small" );
	level._effect[ "refinery_debris_smolder_large" ] = LoadFX( "vfx/ambient/fire/debris_smolder_large" );
	level._effect[ "refinery_debris_smolder_small" ] = LoadFX( "fx/fire/blackice_debris_smolder_small" );
	level._effect[ "refinery_debris_fire_oiltank" ] = LoadFX( "vfx/ambient/fire/fuel/vfx_fire_burning_tank_fireball_01" );
	level._effect[ "refinery_debris_sparks_01" ]    = LoadFX( "vfx/moments/black_ice/vfx_tb_metal_sparks_trail" );
	level._effect[ "refinery_debris_tb_impact_01" ] = LoadFX( "vfx/moments/black_ice/vfx_tb_metal_impact_sparks_large" );
	
	 //oil_gyser
	level._effect[ "oil_geyser_01" ] 				= LoadFX( "fx/fire/oil_geyser_burning" );
	
	// Oil 
	level._effect[ "oil_spots_01" ]					= LoadFX( "fx/impacts/oil_spots_growing_decal_1" );
	level._effect[ "oil_spray_2" ]					= LoadFX( "fx/water/water_pipe_burst" );
	level._effect[ "oil_rain_500" ]					= LoadFX( "vfx/ambient/liquids/vfx_oil_rain_500" );
	level._effect[ "oil_rain_1k_outdoor" ]			= LoadFX( "vfx/ambient/liquids/vfx_oil_rain_1k_outdoor" );
	level._effect[ "oil_rain_500_outdoor" ]			= LoadFX( "vfx/ambient/liquids/vfx_oil_rain_500_outdoor" );
	level._effect[ "oil_rain_500_heavy_outdoor" ]	= LoadFX( "vfx/ambient/liquids/vfx_oil_rain_500_outdoor_heavy" );
	level._effect[ "oil_droplet_imapcts_50" ]		= LoadFX( "vfx/ambient/liquids/vfx_oil_droplet_impacts_50" );
	level._effect[ "oil_droplet_imapcts_100" ]		= LoadFX( "vfx/ambient/liquids/vfx_oil_droplet_impacts_100" );
	level._effect[ "oil_droplet_imapcts_200" ]		= LoadFX( "vfx/ambient/liquids/vfx_oil_droplet_impacts_200" );
	level._effect[ "oil_droplet_imapcts_heavy_100" ]= LoadFX( "vfx/ambient/liquids/vfx_oil_droplet_impacts_heavy_100" );
	level._effect[ "oil_droplet_imapcts_heavy_200" ]= LoadFX( "vfx/ambient/liquids/vfx_oil_droplet_impacts_heavy_200" );
	
	//Smoke 
	level._effect[ "smoke_doorway_01" ] 			= LoadFX( "fx/smoke/doorway_smoke_thick_blackice" );
	level._effect[ "smoke_tanks_pipe" ] 			= LoadFX( "fx/smoke/blackice_tanks_pipe_smoke" );
	level._effect[ "smoke_hallway_01" ] 			= LoadFX( "fx/smoke/hallway_smoke_thick_blackice" );	
	level._effect[ "obscuring_haze_playerview" ]	= LoadFX( "vfx/moments/black_ice/vfx_obscuring_haze_playerview" );
	level._effect[ "heli_smoke_01" ]				= LoadFX( "fx/smoke/smoke_swirl_heli_flyin" );
	
	//flamesstack
 	level._effect[ "console_light_blink" ] 			= LoadFX( "fx/misc/light_console_blink" );	
 	level._effect[ "pistol_muzzleflash" ]			= loadfx( "fx/muzzleflashes/pistolflash" );
 	level._effect[ "pistol_shot_smoke" ]			= loadfx( "vfx/moments/black_ice/vfx_smk_puff_flash");
 	level._effect[ "headshot_blood" ]				= loadfx( "fx/maps/dubai/yuri_headshot_blood" );
 	level._effect[ "flarestack_console_01" ]		= loadfx( "vfx/moments/black_ice/vfx_console_flarestack_display_01" );
 	level._effect[ "flarestack_console_02" ]		= loadfx( "vfx/moments/black_ice/vfx_console_flarestack_display_02" );
 	 level._effect[ "flarestack_console_01_sm" ]	= loadfx( "vfx/moments/black_ice/vfx_console_flarestack_display_01_sm" );
 	level._effect[ "flarestack_console_02_sm" ]		= loadfx( "vfx/moments/black_ice/vfx_console_flarestack_display_02_sm" );
 	level._effect[ "flarestack_bloodsplatter_window" ]= LoadFX( "vfx/moments/black_ice/vfx_blood_splatter_drips_oriented_01");
	
 	//tanks
 	level._effect[ "tanks_pipe_trail" ] 	= LoadFX( "fx/smoke/blackice_tanks_pipe_trail" );
	
 	// Engine room
	level._effect[ "fire_extinguisher_spray" ] 	= LoadFX( "vfx/moments/black_ice/fire_extinguisher_spray_engineroom" );
	
	//screenfx
	level._effect[ "bokeh_splats_01" ]				= loadfx( "vfx/gameplay/screen_effects/vfx_screen_bokeh_splats_add_01" );
	level._effect[ "bokeh_fieryflash_01" ]			= loadfx( "vfx/gameplay/screen_effects/vfx_scrnfx_fiery_bokeh_flash_01" );	
	level._effect[ "pipedeck_heat_haze2" ] 			= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_heat_haze_2" );
	level._effect[ "pipedeck_heat_haze3" ] 			= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_heat_haze_3" );
	level._effect[ "pipedeck_heat_haze4" ] 			= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_heat_haze_4" );
	level._effect[ "pipedeck_heat_haze5" ] 			= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_heat_haze_5" );
	level._effect[ "raindrops_screen_3" ]			= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_3" );
	level._effect[ "raindrops_screen_5" ]			= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_5" );
	level._effect[ "raindrops_screen_10" ]			= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_10" );
	level._effect[ "raindrops_screen_20" ]			= loadfx( "vfx/gameplay/screen_effects/raindrops_screen_20" );
	level._effect[ "oildrops_screen_3" ]			= loadfx( "vfx/gameplay/screen_effects/oildrops_screen_3" );
	level._effect[ "oildrops_screen_5" ]			= loadfx( "vfx/gameplay/screen_effects/oildrops_screen_5" );
	level._effect[ "oildrops_screen_10" ]			= loadfx( "vfx/gameplay/screen_effects/oildrops_screen_10" );
	level._effect[ "oildrops_screen_20" ]			= loadfx( "vfx/gameplay/screen_effects/oildrops_screen_20" );
	level._effect[ "snakecam_static" ] 				= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_snakecam_static" );
	level._effect[ "snakecam_on" ] 					= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_snakecam_on" );
	
	// Heli
	level._effect[ "hellfire_ignition" ]	    	= LoadFX( "fx/_requests/blackice/apache_hellfire_ignition" );
	//level._effect[ "heli_spotlight" ]	        	= loadfx( "fx/misc/blackice_spotlight_model" );
	level._effect[ "heli_spotlight_bright" ]		= loadfx( "fx/misc/blackice_spotlight_model_superbright" );
	level._effect[ "heli_spotlight_bright_fade" ]	= loadfx( "fx/misc/blackice_spotlight_model_superbright_fade" );
	
	//command
	level._effect[ "command_window_light" ] 		= loadfx( "vfx/moments/black_ice/vfx_command_center_window_lighting" );
	level._effect[ "electrical_sparks_med_rndm_loop" ] = loadfx( "vfx/ambient/sparks/electrical_sparks_med_rndm_loop" );
	level._effect[ "paper_blowing_stack_vortex" ] = loadfx( "fx/misc/paper_blowing_stack_vortex" );
	
	// Exfil
	level._effect[ "exfil_fire" ] 					= loadfx( "vfx/moments/black_ice/vfx_fire_ground_exfil" );
	level._effect[ "smoke_plume_thick_blk_01" ] 	= LoadFX( "fx/smoke/smoke_thick_black_plume_fat" );
	level._effect[ "player_view_smoke" ] 			= LoadFX( "fx/smoke/blackice_view_smoke" );
	level._effect[ "exfil_xplosion_huge" ] 			= loadfx( "vfx/moments/black_ice/vfx_rig_fire_exfil_xplosion_huge" );
	level._effect[ "exfil_xplosion_huger" ] 		= loadfx( "vfx/moments/black_ice/vfx_rig_fire_exfil_xplosion_huger" );
	level._effect[ "explosion_oiltank_lg" ] 		= loadfx( "vfx/gameplay/explosions/vfx_exp_oiltank_lg" );
	level._effect[ "water_wake_med" ] 				= loadfx( "vfx/moments/black_ice/vfx_water_wake_med" );	
	level._effect[ "exfil_xplosion_shockwave" ] = loadfx( "vfx/moments/black_ice/vfx_exfil_xplosion_shockwave" );
	
	//perif

	level._effect[ "vfx_perif_smkfire_plume_5k_b4" ] = loadfx( "vfx/ambient/skybox/vfx_perif_smkfire_plume_5k_b4" );
	level._effect[ "perif_smk_plume_01" ] = LoadFX( "vfx/ambient/smoke/vfx_smk_perif_plume_auroralit_large_01" );
	
	//flares
	level._effect[ "flare_light_med_orange1_cone1_snw1" ] = loadfx( "vfx/moments/black_ice/vfx_flare_light_med_orange1_cone1_sn1" );
	level._effect[ "flare_light_med_orange1_snw1" ] 	= loadfx( "vfx/moments/black_ice/vfx_flare_light_med_orange1_sn1" );
	level._effect[ "flare_light_med_orange1_cone1" ] 	= loadfx( "vfx/moments/black_ice/vfx_flare_light_med_orange1_cone1" );
	level._effect[ "flare_light_med_orange1" ] 			= loadfx( "vfx/moments/black_ice/vfx_flare_light_med_orange1" );
	
	level._effect[ "flare_light_med_cwhite1_cone1_snw1" ] = loadfx( "vfx/moments/black_ice/vfx_flare_light_med_cwhite1_cone1_sn1" );
	level._effect[ "flare_light_med_cwhite1_snw1" ] 	= loadfx( "vfx/moments/black_ice/vfx_flare_light_med_cwhite1_sn1" );
	level._effect[ "flare_light_med_cwhite1_cone1" ] 	= loadfx( "vfx/moments/black_ice/vfx_flare_light_med_cwhite1_cone1" );
	level._effect[ "flare_light_med_cwhite1" ] 			= loadfx( "vfx/moments/black_ice/vfx_flare_light_med_cwhite1" );
}

fx_init()
{
	flag_init( "flag_fx_player_watersheeting" );
	flag_init( "flag_fx_screen_raindrops" );
	flag_init( "flag_fx_screen_oildrops" );
	flag_init( "flag_fx_screen_bokehdots_rain" );
	
	level thread fx_screen_bokehdots_rain();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//object to attach view particles to
create_view_particle_source()
{
	
	if( !IsDefined( level.view_particle_source )  )
	{
		level.view_particle_source = spawn( "script_model", ( 0, 0, 0 ) );
		level.view_particle_source setmodel( "tag_origin" );
		
		level.view_particle_source.origin = level.player.origin;
		
		//PlayFXOnTag(  GetFX( "pipedeck_heat_haze5" ), particle_source, "tag_origin" );
		
		level.view_particle_source LinkToPlayerView( level.player, "tag_origin", (0,0,0), (0,0,0), true );
	}
	
}


//add fx to spinning sirens
//Link_siren_fx( light, fx_tag, fx )
//{
//	effect_source = spawn_tag_origin();
//	
//	effect_source.origin = light gettagorigin( fx_tag );
//	effect_source.angles = light gettagangles( fx_tag );
//	
//	wait( level.TIMESTEP );
//	
//	PlayFXOnTag( fx, effect_source, "tag_origin" );
//	
//	wait( 0.5 );
//	
//	effect_source LinkTo( light, fx_tag );
//
//}

////////fx for intro
//underwaterbit
snake_cam_fx()
{
	
	create_view_particle_source();
				
	PlayFXOnTag(  GetFX( "snakecam_static" ), level.view_particle_source, "tag_origin" );
	exploder ( "intro_snakecam" );
	
	level waittill( "notify_snakecam_on" );
	
	PlayFXOnTag(  GetFX( "snakecam_on" ), level.view_particle_source, "tag_origin" );
	
	level waittill( "notify_underwater_transition" );
	
	stop_exploder ( "intro_snakecam" );
	
	StopFXOnTag(  GetFX( "snakecam_static" ), level.view_particle_source, "tag_origin" );
	
}

intro_turn_on_vehicle_underwater_lights_fx()
{
	thread turn_on_gaztiger_underwater_lights_fx();
	thread turn_on_gaztiger_underwater_bubble_fx();
	thread turn_on_bm21_underwater_bubble_fx();
	wait ( 5.0 );
	thread turn_on_bm21_2_underwater_lights_fx();
	wait ( 15.0 );
	thread turn_off_bm21_2_underwater_lights_fx();
}

turn_on_gaztiger_underwater_lights_fx()
{
	PlayFXOnTag( level._effect[ "headlight_gaz_underwater" ], level.breach_vehicles["gaztiger"], "tag_headlight_left" );
	PlayFXOnTag( level._effect[ "headlight_gaz_underwater" ], level.breach_vehicles["gaztiger"], "tag_headlight_right" );
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "vehicle_gaz_brakelight" ], level.breach_vehicles["gaztiger"], "tag_brakelight_left" );
	PlayFXOnTag( level._effect[ "vehicle_gaz_brakelight" ], level.breach_vehicles["gaztiger"], "tag_brakelight_right" );
}

turn_on_gaztiger_underwater_bubble_fx()
{
	//play bubble fx on tags
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_back_right" );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_back_left" );
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_front_right" );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_front_left" );
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_antenna" );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_brakelight_left" );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_brakelight_right" );	
}

turn_off_gaztiger_underwater_lights_fx()
{
	StopFXOnTag( level._effect[ "headlight_gaz_underwater" ], level.breach_vehicles["gaztiger"], "tag_headlight_left" );
	StopFXOnTag( level._effect[ "headlight_gaz_underwater" ], level.breach_vehicles["gaztiger"], "tag_headlight_right" );
	wait ( level.timestep );
	StopFXOnTag( level._effect[ "vehicle_gaz_brakelight" ], level.breach_vehicles["gaztiger"], "tag_brakelight_left" );
	StopFXOnTag( level._effect[ "vehicle_gaz_brakelight" ], level.breach_vehicles["gaztiger"], "tag_brakelight_right" );
}

turn_on_bm21_2_underwater_lights_fx()
{
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_2"], "tag_taillight_left" );
	PlayFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_2"], "tag_taillight_right" );
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "headlight_bm21_underwater" ], level.breach_vehicles["bm21_2"], "tag_headlight_right" );
	PlayFXOnTag( level._effect[ "headlight_bm21_underwater" ], level.breach_vehicles["bm21_2"], "tag_headlight_left" );	
}

turn_on_bm21_underwater_bubble_fx()
{
	//play bubble fx on tags
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_back_right" );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_back_left" );
	wait ( 5.0 );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_front_right" );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_wheel_front_left" );
	wait ( level.timestep );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_brakelight_left" );
	PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], level.breach_vehicles["gaztiger"], "tag_brakelight_right" );	
}

turn_off_bm21_2_underwater_lights_fx()
{
	StopFXOnTag( level._effect[ "headlight_bm21_underwater" ], level.breach_vehicles["bm21_2"], "tag_headlight_right" );
	PlayFXOnTag( level._effect[ "headlight_bm21_underwater_flicker" ], level.breach_vehicles["bm21_2"], "tag_headlight_right" );
	wait ( 0.01 );
	StopFXOnTag( level._effect[ "headlight_bm21_underwater" ], level.breach_vehicles["bm21_2"], "tag_headlight_left" );
	PlayFXOnTag( level._effect[ "headlight_bm21_underwater_flicker" ], level.breach_vehicles["bm21_2"], "tag_headlight_left" );	
	wait ( level.timestep );
	StopFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_2"], "tag_taillight_left" );
	StopFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_2"], "tag_taillight_right" );	
}


intro_turn_on_prop_bm21_1_lights_fx()
{
	//PlayFXOnTag( level._effect[ "vehicle_bm21_headlight" ], level.breach_vehicles["bm21_1"], "tag_headlight_right" );
	//PlayFXOnTag( level._effect[ "vehicle_bm21_headlight" ], level.breach_vehicles["bm21_1"], "tag_headlight_left" );
	wait .01;
	PlayFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_1"], "tag_taillight_left" );
	PlayFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_1"], "tag_taillight_right" );
	// wait .01;
	//PlayFXOnTag( level._effect[ "vehicle_bm21_headlight_spotlight" ], level.breach_vehicles["bm21_1"], "tag_headlight_right" );
}

intro_turn_off_prop_bm21_1_lights_fx()
{
	StopFXOnTag( level._effect[ "vehicle_bm21_headlight" ], level.breach_vehicles["bm21_1"], "tag_headlight_right" );
	StopFXOnTag( level._effect[ "vehicle_bm21_headlight" ], level.breach_vehicles["bm21_1"], "tag_headlight_left" );	
	StopFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_1"], "tag_taillight_left" );
	wait .01;
	StopFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.breach_vehicles["bm21_1"], "tag_taillight_right" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

intro_detonation_sequence_fx()
{
	tag_mine2 = spawn_tag_origin();
	tag_mine2 LinkTo ( level.breach_mines[1], "tag_fx", (0,0,0), ( -90, 0, 0) );	
	PlayFXOnTag( level._effect[ "ice_breach_explosion" ], tag_mine2, "tag_origin" );

	
	//exploder ( "intro_charge_1" );
	level.player PlayRumbleOnEntity( "grenade_rumble" ); 
	//level.player ShellShock("default_nosound", 2);
	wait 0.20;
	
	//exploder ( "intro_charge_2" );
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	wait 0.25;
	
	tag_mine1 = spawn_tag_origin();
	tag_mine1 LinkTo ( level.breach_mines[0], "tag_fx", (0,0,0), (-90,0,0) );	
	PlayFXOnTag( level._effect[ "ice_breach_explosion" ], tag_mine1, "tag_origin" );

	
	//exploder ( "intro_charge_3" );
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	wait 0.20;

}

turn_on_oil_derrick_lightsFX()
{
	oil_derrick = level._refinery.derrick_model;
	wait.01;
	
	playFXonTag( level._effect[ "blue_light_derrick_01" ], oil_derrick, "tagFX_blue_light_01" );
	playFXonTag( level._effect[ "blue_light_derrick_01" ], oil_derrick, "tagFX_blue_light_03" );
	playFXonTag( level._effect[ "blue_light_derrick_01" ], oil_derrick, "tagFX_blue_light_02");
	wait.01;
		
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_01" );
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_01" );
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_01" );
	wait.01;
	
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_02" );
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_02" );	
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_02" );
	wait.01;
	
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_03" );
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_03" );	
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_03" );
	wait.01;
	
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_04" );
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_04" );	
	playFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_04" );
	wait.01;
	
	playFXonTag( level._effect[ "red_light_derrick_blinking_01" ], oil_derrick, "tagFX_red_light_d_01" );
	playFXonTag( level._effect[ "red_light_derrick_oscillator_01" ], oil_derrick, "tagFX_red_light_d_01" );
	wait.01;
	
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_01" );
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_01" );	
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_01" );
	wait.01;
	
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_02" );
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_02" );
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_02" );
	wait.01;
	
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_03" );
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_03" );
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_03" );
	wait.01;
	
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_04" );
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_04" );
	playFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_04" );
	wait.01;	

}

turn_off_oil_derrick_lightsFX()
{
	oil_derrick = level._refinery.derrick_model;
	wait.01;
	
	stopFXonTag( level._effect[ "blue_light_derrick_01" ], oil_derrick, "tagFX_blue_light_01" );
	stopFXonTag( level._effect[ "blue_light_derrick_01" ], oil_derrick, "tagFX_blue_light_03" );
	stopFXonTag( level._effect[ "blue_light_derrick_01" ], oil_derrick, "tagFX_blue_light_02");
	wait.01;
		
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_01" );
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_01" );
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_01" );
	wait.01;
	
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_02" );
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_02" );	
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_02" );
	wait.01;
	
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_03" );
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_03" );	
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_03" );
	wait.01;
	
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_a_04" );
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_b_04" );	
	stopFXonTag( level._effect[ "red_light_derrick_01" ], oil_derrick, "tagFX_red_light_c_04" );
	wait.01;
	
	stopFXonTag( level._effect[ "red_light_derrick_blinking_01" ], oil_derrick, "tagFX_red_light_d_01" );
	stopFXonTag( level._effect[ "red_light_derrick_oscillator_01" ], oil_derrick, "tagFX_red_light_d_01" );
	wait.01;
	
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_01" );
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_01" );	
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_01" );
	wait.01;
	
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_02" );
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_02" );
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_02" );
	wait.01;
	
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_03" );
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_03" );
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_03" );
	wait.01;
	
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_a_04" );
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_b_04" );
	stopFXonTag( level._effect[ "warm_light_derrick_01" ], oil_derrick, "tagFX_core_light_c_04" );
	wait.01;	

}

refinery_travelling_block_impact_fx()
{
	//first impact and bounce
	//wait 0.05;
	level waittill ( "notify_debris_ground_fx_1" );
	level.chunk_spark_fx_tag = spawn_tag_origin();
	level.chunk_spark_fx_tag LinkTo ( level._refinery.scripted[ "derrick_chunk" ], "tag_origin", (20,20,0), (0,-45,180) );	
	playFXonTag( level._effect[ "refinery_debris_sparks_01" ], level.chunk_spark_fx_tag, "tag_origin" );
	thread refinery_stop_chunk_spark_fx();
	
	tag_tb_pos = level._refinery.scripted[ "traveling_block" ] getTagOrigin( "tag_origin" );
	playFX( level._effect[ "refinery_debris_tb_impact_01" ], tag_tb_pos + (0,0,-70));
	
	//second impact and slide
	level waittill ( "notify_debris_ground_fx_2" );
	
	//level.tb_spark_fx_tag = spawn_tag_origin();
	//level.tb_spark_fx_tag LinkTo ( level._refinery.scripted[ "traveling_block" ], "tag_origin", (20,-20,0), (0,45,0) );
	//playFXonTag( level._effect[ "refinery_debris_sparks_01" ], level.tb_spark_fx_tag, "tag_origin" );
	//thread refinery_stop_travelling_block_spark_fx();
}

refinery_stop_chunk_spark_fx()
{
	wait 0.75;
	stopFXonTag( level._effect[ "refinery_debris_sparks_01" ], level.chunk_spark_fx_tag, "tag_origin" );	
}

refinery_stop_travelling_block_spark_fx()
{
	wait 0.75;
	stopFXonTag( level._effect[ "refinery_debris_sparks_01" ], level.tb_spark_fx_tag, "tag_origin" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
pipe_deck_fx()
{
	//exploder ( "pipe_deck_oil_rain_01" );
	exploder ( "pipe_deck_oil_rain" );
	exploder ( "pipe_deck_lights" );
	thread pipe_deck_water_suppression_fx();	
	//thread heat_column_fx();
}

heat_column_fx()
{
	level endon( "flag_vision_command" );
	level endon( "flag_vision_pipedeck_off" );
	//do_vision_sets = false;
	
	heatdist1=1650;
	heatdist2=1200;
	heatdist3=850;
	heatdist4=670;
	heatdist5=570;
	
	quake_max_mag = 0.11;
	quake_max_dist = 1900;
	quake_min_dist = 500;
	quake_angle_min = 0.5;
	
	quakemag = 0;
	heatstate=0;
	
	//for blending visionsets
	heatvision = 0;
	targetheatvision = 0;
	
	heatsource = level._refinery.derrick_struct;
	
	create_view_particle_source();
			
	while(1)
	{
		
		//if ( flag( "flag_vision_pipedeck_heat_fx" ) )
		//{
			//obtain distance from heatsource
			dist_to_heat = Distance( level.player.origin, heatsource.origin );
			
			//IPrintLn( dist_to_heat );
			//obtain angle to heatsource, normalized as 0 - 1(0 is facing away, 1 is facing towards
			
			to_fire = heatsource.origin - level.player.origin;
	        to_fire = ( to_fire[0], to_fire[1], 0 );
	        to_fire = VectorNormalize( to_fire );
	        
	        look_dir = AnglesToForward( level.player.angles );
	        look_dir = ( look_dir[0], look_dir[1], 0 );
	        look_dir = VectorNormalize( look_dir );
	        
	        dot = VectorDot( to_fire, look_dir );
	          
			//iprintln( "dot = " + dot );
			
			if ( dist_to_heat < heatdist5)
			{
				//IPrintLn( "heatzone5" );
				if ( dot > 0.33 )
					target_heatstate = 5;	
				else if ( dot > -0.33 )
					target_heatstate = 4;
				else
					target_heatstate = 3;
			}
			else if ( dist_to_heat < heatdist4)
			{
				//IPrintLn( "heatzone4" );
				if ( dot > 0.65 )
					target_heatstate = 5;	
				else if ( dot > -0.33 )
					target_heatstate = 4;
				else
					target_heatstate = 3;
			}
			else if ( dist_to_heat < heatdist3)
			{
				//IPrintLn( "heatzone3" );
			if ( dot > 0.35 )
					target_heatstate = 3;	
				else
					target_heatstate = 2;
			}
			else if ( dist_to_heat < heatdist2)
			{
				//IPrintLn( "heatzone2" );
				if ( dot > 0.75 )
					target_heatstate = 3;	
				else if ( dot > -0.33 )
					target_heatstate = 2;
				else
					target_heatstate = 1;
}
			else if ( dist_to_heat < heatdist1)
			{
				//IPrintLn( "heatzone1" );
				if ( dot > 0.60 )
					target_heatstate = 2;	
				else if ( dot > -0.25 )
					target_heatstate = 1;
				else
					target_heatstate = 0;
			}
			else
			{
				//IPrintLn( "heatzone0" );
				target_heatstate = 0;
			}
		

		//if in mudpumps, do not do heat fx
		if(  flag( "flag_vision_mudpumps" ) )
			target_heatstate = 0;
				
		
		
		//iprintln( "targ = " + target_heatstate + " state = " + heatstate );
		
		if ( target_heatstate != heatstate )
		{
			switch( target_heatstate )
			{
				case 0:
					//IPrintLn( "state0" );
					heatstate = 0;
					quakemag = 0;
					targetheatvision = 0;
					//StopFXOnTag(  GetFX( "pipedeck_heat_haze1" ), level.view_particle_source, "tag_origin" );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					
					maps\_art::dof_disable_script( 0 );
					level.player SetViewModelDepthOfField( 0.0, 0.0 );
					
//					if ( do_vision_sets )
//					{
//						flag_clear( "flag_vision_pipedeck_heat_1" );
//						flag_clear( "flag_vision_pipedeck_heat_2" );
//						flag_clear( "flag_vision_pipedeck_heat_3" );
//						flag_clear( "flag_vision_pipedeck_heat_4" );
//						flag_clear( "flag_vision_pipedeck_heat_5" );
						
//						if(  !flag( "flag_vision_mudpumps" ) )
//						{
//							IPrintLnBold( "pipedeck1!!" );
//							flag_set( "flag_vision_pipedeck" );
//						}
//					}
							
					break;
				case 1:
					//IPrintLn( "state1" );
					heatstate = 1;
					quakemag = 0.03;
					targetheatvision = 0.2;
					StopFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					
					PlayFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					
					maps\_art::dof_enable_script( 0, 0, 4, 0, 194.25, 0.1225, 0 );
					level.player SetViewModelDepthOfField( 0.0, 13.26 );
					
//					if ( do_vision_sets )
//					{
//						flag_set( "flag_vision_pipedeck_heat_1" );
//						wait( 0.1 );
//						//flag_clear( "flag_vision_pipedeck" );
//						flag_clear( "flag_vision_pipedeck_heat_2" );
//						flag_clear( "flag_vision_pipedeck_heat_3" );
//						flag_clear( "flag_vision_pipedeck_heat_4" );
//						flag_clear( "flag_vision_pipedeck_heat_5" );
//						
//					}
					
					break;
				case 2:
					//IPrintLn( "state2" );
					heatstate = 2;
					quakemag = 0.042;
					targetheatvision = 0.4;
					StopFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					
					PlayFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					
					maps\_art::dof_enable_script( 0, 0, 4, 0, 389, 0.245, 0 );
					level.player SetViewModelDepthOfField( 0.0, 13.26 );
					
//					if ( do_vision_sets )
//					{
//						flag_set( "flag_vision_pipedeck_heat_2" );
//						wait( 0.1 );
//						flag_clear( "flag_vision_pipedeck_heat_1" );
//						flag_clear( "flag_vision_pipedeck_heat_3" );
//						flag_clear( "flag_vision_pipedeck_heat_4" );
//						flag_clear( "flag_vision_pipedeck_heat_5" );
//					}
					
					break;
				case 3:
					//IPrintLn( "state3" );
					heatstate = 3;
					quakemag = 0.08;
					targetheatvision = 0.55;
					StopFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					
					PlayFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					
					maps\_art::dof_enable_script( 0, 0, 4, 0, 583, 0.3675, 0 );
					level.player SetViewModelDepthOfField( 0.0, 13.26 );
									
//					if ( do_vision_sets )
//					{					
//						flag_set( "flag_vision_pipedeck_heat_3" );
//						wait( 0.1 );
//						flag_clear( "flag_vision_pipedeck_heat_1" );
//						flag_clear( "flag_vision_pipedeck_heat_2" );
//						flag_clear( "flag_vision_pipedeck_heat_4" );
//						flag_clear( "flag_vision_pipedeck_heat_5" );
//						
//					}
					
					break;
				case 4:
					//IPrintLn( "state4" );
					heatstate = 4;
					quakemag = 0.105;
					targetheatvision = 0.75;
					StopFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					
					PlayFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					
					maps\_art::dof_enable_script( 0, 0, 4, 0, 777, 0.49, 0 );
					level.player SetViewModelDepthOfField( 0.0, 13.26 );
					
//					if ( do_vision_sets )
//					{
//						flag_set( "flag_vision_pipedeck_heat_4" );
//						wait( 0.1 );
//						flag_clear( "flag_vision_pipedeck_heat_1" );
//						flag_clear( "flag_vision_pipedeck_heat_2" );
//						flag_clear( "flag_vision_pipedeck_heat_3" );
//						flag_clear( "flag_vision_pipedeck_heat_5" );
//					}
					
					break;
				case 5:
					//IPrintLn( "state5" );
					heatstate = 5;
					quakemag = 0.125;
					targetheatvision = 1.0;
					StopFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					
					PlayFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					
					maps\_art::dof_enable_script( 0, 188, 4, 250, 777, 1.49, 0 );
					level.player SetViewModelDepthOfField( 0.0, 23.20 );
					
//					if ( do_vision_sets )
//					{
//						flag_set( "flag_vision_pipedeck_heat_5" );
//						wait( 0.1 );
//						flag_clear( "flag_vision_pipedeck_heat_1" );
//						flag_clear( "flag_vision_pipedeck_heat_2" );
//						flag_clear( "flag_vision_pipedeck_heat_3" );
//						flag_clear( "flag_vision_pipedeck_heat_4" );
//					}
					
					break;
				default:
					heatstate = 0;
					quakemag = 0;
					targetheatvision = 0.0;
					//StopFXOnTag(  GetFX( "pipedeck_heat_haze1" ), level.view_particle_source, "tag_origin" );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze2" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze4" ), level.view_particle_source, "tag_origin" );
					wait ( level.timestep );
					StopFXOnTag(  GetFX( "pipedeck_heat_haze5" ), level.view_particle_source, "tag_origin" );
					
					maps\_art::dof_disable_script( 0 );
					level.player SetViewModelDepthOfField( 0.0, 0.0 );
					//IPrintLn( "outofrange" );
					
//					if ( do_vision_sets )
//					{
//					
//						flag_clear( "flag_vision_pipedeck_heat_1" );
//						flag_clear( "flag_vision_pipedeck_heat_2" );
//						flag_clear( "flag_vision_pipedeck_heat_3" );
//						flag_clear( "flag_vision_pipedeck_heat_4" );
//						flag_clear( "flag_vision_pipedeck_heat_5" );
//					}
			}
		}
	
		//do camera shake and visionset
	
		//if in mudpumps, do not do heat fx
		if(  !flag( "flag_vision_mudpumps" ) )
	        heatvision = pipedeckVisionSwitching( heatvision, targetheatvision );
					
		//IPrintLn( "quakemag = " + quakemag );
		if ( quakemag > 0 )
			earthquake( quakemag, 0.2, level.player.origin, 128 );
		
		wait level.TIMESTEP;
	
	}
}
//blend two vision sets based on dot product of player and target.  Uses distance to distance threshhold as multiplier.
pipedeckVisionSwitching( heatvision, targetheatvision)
{
	rate = 0.025;
//	if(dot<0)
//		dot=0;
//	if(dist<distthresh)
//		dist=distthresh;
//	blendamount = (distthresh/dist)*dot;
	delta = abs( heatvision - targetheatvision );
	//IPrintLn( "target =" + targetheatvision, "heat = " + heatvision, "delta = " + delta  );
	if( delta <= rate )
		heatvision = targetheatvision;
	else if( heatvision > targetheatvision )
		heatvision -= rate;
	else
		heatvision += rate;
	
	//IPrintLn(heatvision);
	level.player VisionSetNakedForPlayer_Lerp("black_ice_pipedeck","black_ice_pipedeck_heat_5",heatvision);
	
	return heatvision;
}

exfil_player_view_smoke_particles()
{
	
	create_view_particle_source();
	
	//IPrintLnBold( "start_particles!" );
	
	PlayFXOnTag(  GetFX( "player_view_smoke" ), level.view_particle_source, "tag_origin" );
	
	level waittill ( "notify_stop_view_smoke_fx" );
	
	StopFXOnTag(  GetFX( "player_view_smoke" ), level.view_particle_source, "tag_origin" );
	
}
		
pipe_deck_water_suppression_fx()
{
	
	// Will hold fire suppression for command scene
	level._fire_suppression = SpawnStruct();
	level._fire_suppression.loopers = [];
	level._fire_suppression.ents = [];
		
	//suppression_01 = get_exploder_array( "pipe_deck_water_suppression_dmg" );	
	//suppression_02 = get_exploder_array( "pipe_deck_water_suppression" );
	//suppressors = get_exploder_array( "pipe_deck_water_suppression" );
		
	if( level.start_point != "exfil" )
	{
		// Derrick fires
		exploder( "derrick_fire_ground" );	
		thread maps\black_ice_util::exploder_damage_loop( "derrick_fire_ground", level._fire_damage_ent );
		
		// Pipe deck water suppression		
		exploder( "water_supression_on_1" );
		exploder( "water_supression_on_2" );
		exploder( "water_supression_on_3" );		
	}	
		
	// Grab supression exploders and locations to kill them at command center
	//suppressors = array_combine( suppression_01, suppression_02 );	
//	foreach( thing in suppressors )
//	{
//		looper = SpawnStruct();
//		ent = SpawnStruct();
//		
//		looper.origin = thing.v[ "origin" ];
//		ent.origin = thing.v[ "origin" ];
//		looper.looper = thing.looper;
//		ent.exploder = thing.v[ "exploder" ];
//		
//		level._fire_suppression.loopers = array_add( level._fire_suppression.loopers, looper );
//		level._fire_suppression.ents = array_add( level._fire_suppression.ents, ent );
//	}
}

fx_command_interior_on()
{
	exploder( "fx_command_interior" );
	//IPrintLnBold( "fx_command!" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

engineroom_turn_on_fx()
{
	exploder ( "engineroom_01" );
	exploder ( "engineroom_02" );
		
	thread maps\black_ice_util::exploder_damage_loop( "engineroom_01", level._fire_damage_ent );
}


engineroom_turn_off_fx()
{
	stop_exploder ( "engineroom_01" );	
	
	flag_wait( "flag_top_drive_walkway" );
	stop_exploder ( "engineroom_02" );
}

engineroom_headsmoke_fx_start()
{	
	
	level.smokehead = level.player spawn_tag_origin();
	level.smokehead LinkTo ( level.player );
	PlayFXOnTag( level._effect[ "obscuring_haze_playerview" ], level.smokehead, "tag_origin" );
	
	//heat warble
	create_view_particle_source();
	
	PlayFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
	maps\_art::dof_enable_script( 0, 0, 4, 0, 777, 1.49, 0 );
	level.player SetViewModelDepthOfField( 0.0, 13.26 );
}

engineroom_headsmoke_fx_end()
{
	StopFXOnTag( level._effect[ "obscuring_haze_playerview" ], level.smokehead, "tag_origin" );	
	
	//level.smokehead delete();		
	
	//heat warble
	StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), level.view_particle_source, "tag_origin" );
	
	//TAG CP do not delete view particle source cause we use it later
	//level.view_particle_source delete();
	maps\_art::dof_disable_script( 0 );
	level.player SetViewModelDepthOfField( 0.0, 0.0 );
	
	level notify( "notify_stop_screen_shake" );
	
	//wait 5.0;
	
	//clean this shit up
	//if( isdefined(level.smokehead))
		//level.smokehead delete();
}

engineroom_heat_fx_shake()
{
	level endon( "notify_stop_screen_shake" );
	
	quakemag = 0.05;
	
	while( 1 )
	{
		earthquake( quakemag, 0.2, level.player.origin, 128 );
		wait level.TIMESTEP;
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
refinery_turn_on_buildup_fx_01()
{
	exploder ( "ref_emeg_lights_01" );
	flag_wait( "flag_refinery_gas_blowout_01" );
	exploder ( "ref_buildup_pre_01" );
	refinery_buildup_quake_delay( 0.4, 1.5, 0.4 );
	
	flag_wait( "flag_refinery_gas_blowout_02" );
	exploder ( "ref_buildup_pre_02" );
	refinery_buildup_quake_delay( 0.6, 5.5, 0.4 );
	
	flag_wait( "flag_refinery_gas_blowout_03" );
	exploder ( "ref_buildup_01" );
	exploder ( "ref_buildup_r_01" );
	
	//AUDIO: sfx for pipe bursts
	thread maps\black_ice_audio::sfx_long_pipe_bursts();
	
	wait 1.5;
	exploder ( "ref_buildup_02" );
	
}

refinery_buildup_quake_delay( mag, dur, delay_time )
{
	wait( delay_time );
	
	earthquake( mag, dur, level.player.origin, 128 );
}


turn_off_refinery_buildup_fx_01()
{
	//IPrintLnBold( "hello" );
	stop_exploder ( "ref_buildup_pre_01" );
	stop_exploder ( "ref_buildup_01" );
	stop_exploder ( "ref_buildup_r_01" );
	stop_exploder ( "ref_buildup_02" );
}

tanks_bridge_fall_fx()
{
	//wait( 0.05 );
	PlayFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_1" );
	PlayFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_2" );
	wait(0.05);
	PlayFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_3" );
	PlayFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_4" );
	wait(0.05);
	PlayFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_5" );
	PlayFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_6" );
	
	wait ( 5.0 );
	
	stopFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_1" );
	stopFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_2" );
	wait(0.05);
	stopFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_3" );
	stopFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_4" );
	wait(0.05);
	stopFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_5" );
	stopFXOnTag( getfx("tanks_pipe_trail"), level._tanks.pipe, "tag_fx_6" );
	//iprintln( "why you no st0p" );
	
}

tanks_bridge_fall_explosions()
{
	exploder( "tanks_pipe_explode_1" );
	Earthquake( 0.3, 1.6, level.player.origin, 3000 );
	exploder( "tanks_pipe_explode_smoke" );
	
	wait( 1.5);
	
	exploder( "tanks_pipe_explode_2" );
	Earthquake( 0.17, 1.2, level.player.origin, 3000 );
	
	wait( 0.8);
	
	exploder( "tanks_pipe_explode_3" );
	Earthquake( 0.3, 1.4, level.player.origin, 3000 );
	
	
	//wait( 1.8 );
	
	//thread tanks_bridge_aftershocks();
	
	//exploder( "tanks_pipe_explode_4" );
	//Earthquake( 0.28, 1.2, level.player.origin, 3000 );
	
}

tanks_bridge_aftershocks()
{
	
	min_quake = 0.11;
	max_quake = 0.22;
	min_duration = 0.7;
	max_duration = 1.3;
	min_time = 0.3;
	max_time = 1.8;
	diminish = 0.94;
	
	while( min_quake > 0.01 )
	{
		quake = RandomFloatRange( min_quake, max_quake );
		time = RandomFloatRange( min_time, max_time );
		duration = RandomFloatRange( min_duration, max_duration );
		Earthquake( quake, duration, level.player.origin, 3000 );
		
		//AUDIO: screenshake sfx
		thread maps\black_ice_audio::sfx_screenshake();
		
		min_quake *= diminish;
		max_quake *= diminish;
		
		wait( time );
	}
	
}

turn_on_flarestack_fx()
{
	origin = GetEnt( "origin_flarestack_fx", "targetname" );
	Assert( IsDefined( origin ));
	
	flame = spawn_tag_origin();
	flame.angles = origin.angles;
	flame.origin = origin.origin;
	
	PlayFXOnTag( GetFX( "fire_oil_burnoff_01" ), flame, "tag_origin" );
	
	level waittill( "notify_stop_flare_stack" );
		
	StopFXOnTag( GetFX( "fire_oil_burnoff_01" ), flame, "tag_origin" );
	
	//wait( 1.0 );
	
	PlayFXOnTag( GetFX( "fire_oil_burnoff_extinguish" ), flame, "tag_origin" );
	
	level notify( "notify_flare_stack_off" );
	
	thread maps\black_ice_flarestack::fx_flarestack_motion();
	
	wait( 2.2 );
	
	//vent some steam
	level notify( "flamestack_steam_vent" );
	exploder( "flamestack_steam_vent" );
}

flarestack_turn_on_console_fx()
{
	
	exploder( "flarestack_console_normal" );
	
	level waittill( "notify_flare_stack_off" );	
	
	stop_exploder( "flarestack_console_normal" );
	
	exploder( "flarestack_console_emergency" );
	
	
}

exfil_heli_smoke_fx_01()
{
	wait 8.0;
	for( i = 0; i < 3; i++ )
	{
		level.exfil_heli_tag = spawn_tag_origin();
		level.exfil_heli_tag LinkTo ( level.heli, "tag_origin", (0,0,-20), (0,0,0) );
		PlayFXOnTag( level._effect[ "heli_smoke_01" ], level.exfil_heli_tag, "tag_origin" );
		wait( RandomFloatRange( 1, 2 ));
	}

	
}

coldbreathfx()
{
	guys = level._allies;
	
	foreach( guy in guys )
	{
		guy thread turn_on_cold_breath_fx();
	}
	//thread turn_on_cold_breath_player_fx();
	flag_wait ( "flag_catwalks_end" );
	
		foreach( guy in guys )
	{
		//guy thread turn_off_cold_breath_fx();
		//iprintlnbold ( "turn off frosty" );
		self notify( "stop personal effect" );
		//self.has_cold_breath = 0;
	}		
}

turn_on_cold_breath_fx()
{
	tag = "TAG_EYE";
	self endon( "death" );
	self notify( "stop personal effect" );
	self endon( "stop personal effect" );
	self.has_cold_breath = 1;
	while ( !flag( "flag_catwalks_end" ))
	{
		wait( 0.05 );
		if( !isdefined( self ) )
			break;
		
		playfxOnTag( level._effect[ "cold_breath" ], self, tag );
		wait( 2.5 + randomfloat( 2.5 ) );
	}
}


turn_off_cold_breath_fx()
{	
	self.has_cold_breath = 0;
	while ( isdefined( self ) )
	{
		wait( 0.05 );
		if( !isdefined( self ) )
			break;
	}
}

turn_on_cold_breath_player_fx()
{
	level.coldbreath_player = spawn_tag_origin();
	//level.coldbreath_player LinkTo ( level.player);
	level.coldbreath_player linktoplayerview( level.player, "tag_origin", (0,0,0), (0,0,0), true );
	self endon( "death" );
	self notify( "stop personal effect" );
	self endon( "stop personal effect" );
	
	self.has_cold_breath = 1;
	while ( isdefined( self ) )
	{
		wait( 0.05 );
		if( !isdefined( self ) )
			break;
		
		PlayFX( level._effect[ "cold_breath" ], level.coldbreath_player.origin, level.player.angles );
		//playfxOnTag( level._effect[ "concrete_axis_test" ], level.coldbreath_player, "tag_origin" );
		wait( 0.5 + randomfloat( 0.5 ) );
	}
}



fx_screen_bokehdots_rain()
{	
	flag_wait( "flag_fx_screen_bokehdots_rain" );
	create_view_particle_source();

	for( ;; )
	{
		//wait ( 1.0 );
		if ( flag( "flag_fx_screen_bokehdots_rain" ) )
		{
			//iprintln( "singing_in_the_rain" );
			PlayFXOnTag(  GetFX( "bokeh_splats_01" ), level.view_particle_source, "tag_origin" );
		}
		else//if ( !flag( "flag_fx_screen_bokehdots_rain" ) )
		{
			//iprintln( "stop raining" );
			stopFXOnTag(  GetFX( "bokeh_splats_01" ), level.view_particle_source, "tag_origin" );
		}
		
	wait( 3.0 );	
	}
	
}

fx_screen_raindrops()
{
	create_view_particle_source();
	
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
				//iprintln( "singing_in_the_rain" );
				if ( !sheeted && upAngle[ 0 ] < -55 && RandomInt( 100 ) < 20 )
				{
					level.player SetWaterSheeting( 1, 1.0 );
				}
				
				if ( upAngle[ 0 ] < -40 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_20" ], level.view_particle_source, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < -25 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_10" ], level.view_particle_source, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < 25 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_5" ], level.view_particle_source, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < 40 )
				{
					PlayFXOnTag(  level._effect[ "raindrops_screen_3" ], level.view_particle_source, "tag_origin" );
				}
			}
		}
		
		wait 1.0;
	}
}

fx_screen_oildrops()
{
	create_view_particle_source();
	
	for( ;; )
	{
		if ( flag( "fx_screen_oildrops" ) || flag( "fx_player_watersheeting" ) )
		{
			sheeted = false;
			upAngle = level.player GetPlayerAngles();
			if ( flag( "fx_player_watersheeting" ) && upAngle[ 0 ] < 25 )
			{
				level.player SetWaterSheeting( 1, 1.0 );
				sheeted = true;
			}
			
			if ( flag( "fx_screen_oildrops" ) )
			{
				//iprintln( "singing_in_the_rain" );
				if ( !sheeted && upAngle[ 0 ] < -55 && RandomInt( 100 ) < 20 )
				{
					level.player SetWaterSheeting( 1, 1.0 );
				}
				/*
				if ( upAngle[ 0 ] < -40 )
				{
					PlayFXOnTag(  level._effect[ "oildrops_screen_20" ], level.view_particle_source, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < -25 )
				{
					PlayFXOnTag(  level._effect[ "oildrops_screen_10" ], level.view_particle_source, "tag_origin" );
				}
				*/
				if ( upAngle[ 0 ] < 25 )
				{
					PlayFXOnTag(  level._effect[ "oildrops_screen_5" ], level.view_particle_source, "tag_origin" );
				}
				else if ( upAngle[ 0 ] < 40 )
				{
					PlayFXOnTag(  level._effect[ "oildrops_screen_3" ], level.view_particle_source, "tag_origin" );
				}  
			}
		}
		
		wait 2.0;
	}
}
	
turn_on_bokeh_fieryflash_player_fx()
{
	create_view_particle_source();
	wait ( .5 );
	PlayFXOnTag(  GetFX( "bokeh_fieryflash_01" ), level.view_particle_source, "tag_origin" );
}

exfil_oilrig_preboom_fx(oil_rig)
{
	level waittill ( "notify_exfil_player_teleport" );
	thread exfil_oilrig_ball_drop_fx(oil_rig);
	thread exfil_oilrig_explosions_fx(oil_rig);	
	thread exfil_oilrig_shockwave_fx(oil_rig);
	
	level.geysertag = spawn_tag_origin();
	level.geysertag LinkTo ( oil_rig, "j_rigtop_1", (0,0,500), (-90,0,-55) );
	
	
	level.xplotag1 = spawn_tag_origin();
	level.xplotag1 LinkTo ( oil_rig, "j_rigtop_1", (500,-1500,500), (-79,0,0) );
	
	level.xplotag2 = spawn_tag_origin();
	level.xplotag2 LinkTo ( oil_rig, "j_rigtop_1", (-1000,0,100), (0,0,0) );
	
	level.xplotag3 = spawn_tag_origin();
	level.xplotag3 LinkTo ( oil_rig, "j_rigtop_1", (500,0,500), (-90,0,0) );
		
	level.xplotag4 = spawn_tag_origin();
	level.xplotag4 LinkTo ( oil_rig, "j_rigtop_1", (-1000,-1700,500), (-90,0,0) );
	
	level.xplotag5 = spawn_tag_origin();
	level.xplotag5 LinkTo ( oil_rig, "j_rigtop_1", (500, 1000, 300), (-90,0,0) );
	
	//spawn tags origins for legspashes
	level.splshtag1 = spawn_tag_origin();
	level.splshtag1 LinkTo ( oil_rig, "tag_fx_splash_leg_01", (0,0,0), (0,0,0) );
	
	level.splshtag2 = spawn_tag_origin();
	level.splshtag2 LinkTo ( oil_rig, "tag_fx_splash_leg_02", (0,0,0), (0,0,0) );
	
	level.splshtag3 = spawn_tag_origin();
	level.splshtag3 LinkTo ( oil_rig, "tag_fx_splash_leg_03", (0,0,0), (0,0,0) );
	
	level.splshtag4 = spawn_tag_origin();
	level.splshtag4 LinkTo ( oil_rig, "tag_fx_splash_leg_04", (0,0,0), (0,0,0) );
	
	level.splshtag7 = spawn_tag_origin();
	level.splshtag7 LinkTo ( oil_rig, "tag_fx_splash_leg_07", (0,0,0), (0,0,0) );
	
	level.splshtag11 = spawn_tag_origin();
	level.splshtag11 LinkTo ( oil_rig, "tag_fx_splash_leg_11", (0,0,0), (0,0,0) );
	
	level.splshtag15 = spawn_tag_origin();
	level.splshtag15 LinkTo ( oil_rig, "tag_fx_splash_leg_15", (0,0,0), (0,0,0) );
	
	
	
	//PlayFXOnTag(  GetFX( "vfx_rig_fire_exfil_huge" ), level.xplotag2, "tag_origin" );
	
	
	wait ( 0.1 );
	smokefire_tag1 = oil_rig gettagorigin( "j_rigtop_1" );
	smoke_fire_1 = spawnFx( getFx( "vfx_rig_fire_exfil_huge" ), ( smokefire_tag1 + (0,0,100)), (90,90,0) );
	triggerFx( smoke_fire_1, -50 );
	
	
}

exfil_oilrig_explosions_fx(oil_rig)
{	
	level waittill ( "notify_rig_explode" );
	//IPrintLnBold ("skiboooshh");
	
	PlayFXOnTag(  GetFX( "exfil_xplosion_huger" ), level.xplotag5, "tag_origin" );
	
	thread turn_on_bokeh_fieryflash_player_fx();
	
	PlayFXOnTag(  GetFX( "exfil_rigcollapse_splash" ), level.splshtag1, "tag_origin" );
	
	wait( 0.2 );
	
	PlayFXOnTag(  GetFX( "exfil_rigcollapse_splash" ), level.splshtag2, "tag_origin" );
	
	wait( 0.2 );
	
	PlayFXOnTag(  GetFX( "exfil_rigcollapse_splash" ), level.splshtag4, "tag_origin" );
	
	wait( 0.2 );
	
	PlayFXOnTag(  GetFX( "exfil_rigcollapse_splash" ), level.splshtag3, "tag_origin" );
	
	wait( 0.2 );
	
	PlayFXOnTag(  GetFX( "exfil_rigcollapse_splash" ), level.splshtag7, "tag_origin" );
	
	wait( 0.2 );
		
	PlayFXOnTag(  GetFX( "exfil_rigcollapse_splash" ), level.splshtag11, "tag_origin" );
	
	wait( 0.2 );
			
	PlayFXOnTag(  GetFX( "exfil_rigcollapse_splash" ), level.splshtag15, "tag_origin" );
	
	wait( 0.2 );
	
}

exfil_oilrig_shockwave_fx(oil_rig)
{	
	level waittill ( "notify_rig_explode" );
	
	wait ( 0.1 );
	
	oil_rig_forward = AnglesToForward( oil_rig.angles - ( 0, 0, 0 )) ;
	oil_rig_up = AnglesToup( oil_rig.angles - ( 0, -90, 0 )) ;
	PlayFX( level._effect[ 	"exfil_xplosion_shockwave" ], oil_rig.origin );
	
	wait( 0.1 );
	
	earthquake( 0.15, 0.6, level.player.origin, 3000 );
	level.player PlayRumbleOnEntity( "damage_light" );
	
	wait(1.1);
	
	earthquake( 0.41, 1.8, level.player.origin, 3000 );
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	level.player thread shockwave_dirt_hit(2, 0.1, 7);
	exploder( "shockwave_exfil" );
	
	
}

shockwave_dirt_hit(time, fadein, fadeout)
{
	overlay = NewClientHudElem( self );
	overlay.x = 0;
	overlay.y = 0;

	overlay SetShader( "fullscreen_dirt_right", 640, 480 );
	
	overlay.splatter = true;
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.sort = 1;
	overlay.foreground = 0;
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 0;
	
	//fade up
	fade_counter = 0;
	if (!IsDefined(fadein))
		fadein = 1;
	if (!IsDefined(fadeout))
		fadeout = 1;
	
	while(fade_counter < fadein)
	{
		overlay.alpha += 0.05;	
		fade_counter += 0.05;
		wait 0.05;
	}
	overlay.alpha = 1;
	
	wait time;

	//fade down
	fade_counter = 0;
	while(fade_counter < fadeout)
	{
		overlay.alpha -= 0.05;
		fade_counter += 0.05;
		wait 0.05;
	}
	overlay.alpha = 0;
	
	overlay destroy();
}

exfil_oilrig_ball_drop_fx(oil_rig)
{
	
	level waittill ( "notify_sphere_start_fall" );
		
	level.trailtag_sphere = spawn_tag_origin();
	level.trailtag_sphere LinkTo ( oil_rig, "j_sphere_01", (0,0,0), (0,0,0) );
	
	PlayFXOnTag( GetFX( "exfil_sphere_trail" ), level.trailtag_sphere, "tag_origin" );	
	
	level waittill ( "notify_sphere_hit_ground" );
	//IPrintLnBold ("balls, dropping");
	
	StopFXOnTag( GetFX( "exfil_sphere_trail" ), level.trailtag_sphere, "tag_origin" );

	sphere_pos = oil_rig GetTagOrigin ( "j_sphere_01" ) + ( 0,0,200);
	//PlayFXOnTag(  GetFX( "exfil_xplosion_huge" ), level.xplotag_sphere, "tag_origin" );	
	PlayFX( level._effect[ "exfil_xplosion_huge" ], sphere_pos );
}

exfil_blackice_exfil_heli_lights_fx()
{
	PlayFXOnTag(  GetFX( "vfx_aircraft_light_white_blink_fog" ), level.heli, "tag_light_belly" );
	
	PlayFXOnTag(  GetFX( "vfx_aircraft_light_red_blink_fog" ), level.heli, "tag_light_tail" );
	
	//adding a wait...seems like too many playfxontag is canceling the call for the spotlight
	wait( level.TIMESTEP );
	
	PlayFXOnTag(  GetFX( "vfx_aircraft_light_red_blink_fog" ), level.heli, "tag_light_R_wing" );
	
	PlayFXOnTag(  GetFX( "vfx_aircraft_light_green_blink_fog" ), level.heli, "tag_light_L_wing" );	
}

fx_command_window_light_on()
{
	exploder( "pipedeck_command_window_light" );
}

fx_command_window_light_off()
{
	stop_exploder( "pipedeck_command_window_light" );
}

fx_exfil_lifeboat_wake(lifeboat)
{
	wait  (2.0);	
	while(1)
	{
		wait  (.1);
		forward = AnglesToForward( lifeboat.angles - ( 90, 0, 0 )) ;
		up = AnglesToForward( lifeboat.angles - ( 0, -90, 0 )) ;
		PlayFX( level._effect[ "water_wake_med" ], lifeboat.origin, forward, up );
	}
	
}
