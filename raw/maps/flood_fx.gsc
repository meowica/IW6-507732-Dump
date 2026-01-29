#include maps\_utility;
#include common_scripts\utility;
#include maps\_gameskill;
#include maps\_anim;
#include maps\_vignette_util;

main()
{
	level._effect[ "mall_floating_debri_med2" ] = loadfx( "vfx/moments/flood/mall_floating_debri_med2" );
	level._effect[ "mall_floating_debri_med" ] = loadfx( "vfx/moments/flood/mall_floating_debri_med" );
	level._effect[ "splash_line_runner" ] = loadfx( "vfx/moments/flood/splash_line_runner" );
	level._effect[ "edge_splashes_line" ] = loadfx( "vfx/moments/flood/edge_splashes_line" );
	level._effect[ "flood_drips_big" ] = loadfx( "vfx/moments/flood/flood_drips_big" );
	level._effect[ "flood_character_drips_big_pool" ] = loadfx( "vfx/moments/flood/flood_character_drips_big_pool" );
	level._effect[ "flood_character_drips_child" ] = loadfx( "vfx/moments/flood/flood_character_drips_child" );
	//level._effect[ "swept_floating_debri_large" ] = loadfx( "vfx/moments/flood/swept_floating_debri_large" );
        level._effect[ "swept_floating_debri_hump" ] = loadfx( "vfx/moments/flood/swept_floating_debri_hump" );
	level._effect[ "floodwater_splash_small_01" ] = loadfx( "vfx/ambient/water/floodwater_splash_small_01" );
	level._effect[ "edge_splashes_roil_left" ] = loadfx( "vfx/ambient/water/edge_splashes_roil_left" );
	level._effect[ "floodwater_splash_large_02" ] = loadfx( "vfx/ambient/water/floodwater_splash_large_02" );
	level._effect[ "edge_splashes_roil" ] = loadfx( "vfx/ambient/water/edge_splashes_roil" );
	level._effect[ "floodwater_splash_large_01" ] = loadfx( "vfx/ambient/water/floodwater_splash_large_01" );
	level._effect[ "ai_blood_underwater" ] = loadfx( "vfx/moments/flood/ai_blood_underwater" );
	level._effect[ "splash_player_hand_r_strong" ] = loadfx( "fx/water/splash_player_hand_r_strong" );
	level._effect[ "flood_particulate_in_light_large" ] = loadfx( "fx/water/flood_particulate_in_light_large" );
	level._effect[ "bubbles_stream_large_slow" ] = loadfx( "vfx/ambient/water/bubbles_stream_large_slow" );
	level._effect[ "swept_floating_debri_large" ] = loadfx( "vfx/moments/flood/swept_floating_debri_large" );
	level._effect[ "flood_hand_splash_in" ] = loadfx( "vfx/moments/flood/flood_hand_splash_in" );
	level._effect[ "dunk_bubbles_runner" ] = loadfx( "vfx/moments/flood/dunk_bubbles_runner" );
	level._effect[ "flood_mr_falling_dust_debri_nosmk" ] = loadfx( "vfx/moments/flood/flood_mr_falling_dust_debri_nosmk" );
	level._effect[ "flood_mr_falling_dust_debri_slight" ] = loadfx( "vfx/moments/flood/flood_mr_falling_dust_debri_slight" );
	level._effect[ "bubbles_leak_vent_02" ] = loadfx( "vfx/ambient/water/bubbles_leak_vent_02" );
	level._effect[ "bubbles_stream_large" ] = loadfx( "vfx/ambient/water/bubbles_stream_large" );
	level._effect[ "surface_bubble_sheet" ] = loadfx( "vfx/test/surface_bubble_sheet" );
	level._effect[ "vfx_warehouse_surface_bubbles_run" ] = loadfx( "vfx/moments/flood/vfx_warehouse_surface_bubbles_run" );
	level._effect[ "flood_warehouse_ledge_cover" ] = loadfx( "vfx/moments/flood/flood_warehouse_ledge_cover" );
	level._effect[ "flood_warehouse_water_ledge_froth" ] = loadfx( "vfx/moments/flood/flood_warehouse_water_ledge_froth" );
	level._effect[ "vfx_warehouse_surface_bubbles" ] = loadfx( "vfx/moments/flood/vfx_warehouse_surface_bubbles" );
	level._effect[ "vfx_warehouse_door_splashes_lrg_dark" ] = loadfx( "vfx/moments/flood/vfx_warehouse_door_splashes_lrg_dark" );
	level._effect[ "vfx_warehouse_water_burst_02" ] = loadfx( "vfx/moments/flood/vfx_warehouse_water_burst_02" );
	level._effect[ "vfx_warehouse_water_stream_sml" ] = loadfx( "vfx/moments/flood/vfx_warehouse_water_stream_sml" );
	level._effect[ "vfx_warehouse_water_burst_01" ] = loadfx( "vfx/moments/flood/vfx_warehouse_water_burst_01" );
	level._effect[ "flood_water_alley_fill_shallow" ] = loadfx( "vfx/moments/flood/flood_water_alley_fill_shallow" );
	level._effect[ "flood_water_alley_fill_shallow_left" ] = loadfx( "vfx/moments/flood/flood_water_alley_fill_shallow_left" );
        level._effect[ "flood_dam_water_pre_fall" ] = loadfx( "vfx/moments/flood/flood_dam_water_pre_fall" );
        level._effect[ "flood_warehouse_lip_cascade_debris" ] = loadfx( "vfx/moments/flood/flood_warehouse_lip_cascade_debris" );
	level._effect[ "flood_warehouse_floating_debri_03" ] = loadfx( "vfx/moments/flood/flood_warehouse_floating_debri_03" );
	level._effect[ "flood_floating_paper_slow2" ] = loadfx( "vfx/moments/flood/flood_floating_paper_slow2" );
	level._effect[ "flood_particlulates_03" ] = loadfx( "vfx/moments/flood/flood_particlulates_03" );
	level._effect[ "flood_warehouse_floating_debri_02" ] = loadfx( "vfx/moments/flood/flood_warehouse_floating_debri_02" );
	level._effect[ "flood_warehouse_floating_debri_01" ] = loadfx( "vfx/moments/flood/flood_warehouse_floating_debri_01" );
	level._effect[ "vfx_warehouse_big_door_steam_01" ] = loadfx( "vfx/moments/flood/vfx_warehouse_big_door_steam_01" );
	level._effect[ "vfx_warehouse_door_splashes_sml" ] = loadfx( "vfx/moments/flood/vfx_warehouse_door_splashes_sml" );
	level._effect[ "vfx_warehouse_door_splashes_lrg" ] = loadfx( "vfx/moments/flood/vfx_warehouse_door_splashes_lrg" );
	level._effect[ "vfx_warehouse_lip_froth_01" ] = loadfx( "vfx/moments/flood/vfx_warehouse_lip_froth_01" );
	level._effect[ "vfx_warehouse_lip_water_splashes" ] = loadfx( "vfx/moments/flood/vfx_warehouse_lip_water_splashes" );
	level._effect[ "vfx_warehouse_lip_water" ] = loadfx( "vfx/moments/flood/vfx_warehouse_lip_water" );
	level._effect[ "mall_rooftop_updust_01_runner" ] = loadfx( "vfx/moments/flood/mall_rooftop_updust_01_runner" );
	level._effect[ "flood_mr_debri_explosion_small" ] = loadfx( "vfx/moments/flood/flood_mr_debri_explosion_small" );
	level._effect[ "flood_mr_opfor_splashes_runner" ] = loadfx( "vfx/moments/flood/flood_mr_opfor_splashes_runner" );
	level._effect[ "flood_mr_opfor_splashes" ] = loadfx( "vfx/moments/flood/flood_mr_opfor_splashes" );
	level._effect[ "flood_mr_splash_med" ] = loadfx( "vfx/moments/flood/flood_mr_splash_med" );
	level._effect[ "big_sparks_no_col" ] = loadfx( "vfx/moments/big_sparks_no_col" );
	level._effect[ "big_sparks" ] = loadfx( "vfx/moments/big_sparks" );
	level._effect[ "mr_sudden_dust" ] = loadfx( "vfx/moments/flood/mr_sudden_dust" );
	level._effect[ "flood_dust_debri_frequent_runner" ] = loadfx( "vfx/moments/flood/flood_dust_debri_frequent_runner" );
	level._effect[ "flood_dust_debri_slight_runner" ] = loadfx( "vfx/moments/flood/flood_dust_debri_slight_runner" );
	level._effect[ "flood_mr_dust_runner" ] = loadfx( "vfx/moments/flood/flood_mr_dust_runner" );
	level._effect[ "flood_mr_falling_dust_debri" ] = loadfx( "vfx/moments/flood/flood_mr_falling_dust_debri" );
	level._effect[ "flood_integration_foamsplash_med_dropper" ] = loadfx( "vfx/moments/flood/flood_integration_foam_med_dropper" );
	level._effect[ "flood_small_sparks_runner_frequent" ] = loadfx( "vfx/moments/flood/flood_small_sparks_runner_frequent" );
	level._effect[ "skybridge_crush_dust_emit" ] = loadfx( "vfx/moments/flood/skybridge_crush_dust_emit" );
	level._effect[ "flood_small_sparks_runner" ] = loadfx( "vfx/moments/flood/flood_small_sparks_runner" );
	level._effect[ "small_sparks" ] = loadfx( "vfx/moments/flood/small_sparks" );
	level._effect[ "flood_glass_shatter" ] = loadfx( "vfx/moments/flood/flood_glass_shatter" );
	level._effect[ "flood_dust_hit_medium_glass" ] = loadfx( "vfx/moments/flood/flood_dust_hit_medium_glass" );
	level._effect[ "flood_debri_crumble_dust_medium" ] = loadfx( "vfx/moments/flood/flood_debri_crumble_dust_medium" );
	level._effect[ "flood_dust_hit_medium" ] = loadfx( "vfx/moments/flood/flood_dust_hit_medium" );
	level._effect[ "flood_dust_hit_large" ] = loadfx( "vfx/moments/flood/flood_dust_hit_large" );
	level._effect[ "flood_falling_debri_splash_med" ] = loadfx( "vfx/moments/flood/flood_falling_debri_splash_med" );
	level._effect[ "flood_integration_foam_med_dropper" ] = loadfx( "vfx/moments/flood/flood_integration_foamsplash_med_dropper" );
	level._effect[ "flood_integration_foam_bus_dropper" ] = loadfx( "vfx/moments/flood/flood_integration_foam_bus_dropper" );
	level._effect[ "flood_integration_foam_dropper" ] = loadfx( "vfx/moments/flood/flood_integration_foam_dropper" );
	level._effect[ "flood_integration_foam_small" ] = loadfx( "vfx/moments/flood/flood_integration_foam_small" );
	level._effect[ "flood_dam_hit_smoke" ] = loadfx( "vfx/moments/flood/flood_dam_hit_smoke" );
	level._effect[ "flood_m880_low_smk" ] = loadfx( "vfx/moments/flood/flood_m880_low_smk" );
	level._effect[ "flesh_hit_knife" ] = loadfx( "fx/impacts/flesh_hit_knife" );
	//level._effect[ "knife_attack_throat" ] = loadfx( "fx/maps/dubai/knife_attack_throat" );
	level._effect[ "blood_throat_stab2" ] = loadfx( "fx/misc/blood_throat_stab2" );
	level._effect[ "factory_intro_stab_blood_player" ] = loadfx( "vfx/moments/factory/factory_intro_stab_blood_player" );
	level._effect[ "clockwork_knifestab_windshieldsplatter" ] = loadfx( "fx/impacts/clockwork_knifestab_windshieldsplatter" );
	level._effect[ "factory_intro_stab_blood_screen" ] = loadfx( "vfx/moments/factory/factory_intro_stab_blood_screen" );
	level._effect[ "flood_smk_amb_fast_low" ] = loadfx( "vfx/moments/flood/flood_smk_amb_fast_low" );
	level._effect[ "flood_smk_amb_fast" ] = loadfx( "vfx/moments/flood/flood_smk_amb_fast" );
	level._effect[ "vfx_crater_dust_small_bright" ] = loadfx( "vfx/ambient/atmospheric/vfx_crater_dust_small_bright" );
	level._effect[ "m880_exp_up" ] = loadfx( "vfx/moments/flood/m880_exp_up" );
	level._effect[ "flood_dust_hit" ] = loadfx( "vfx/moments/flood/flood_dust_hit" );
	level._effect[ "flood_flare_outdoor_small" ] = loadfx( "vfx/moments/flood/flood_flare_outdoor_small" );
	level._effect[ "flood_flare_wh_emergency" ] = loadfx( "vfx/moments/flood/flood_flare_wh_emergency" );
	level._effect[ "flood_flare_wh_doorbreak" ] = loadfx( "vfx/moments/flood/flood_flare_wh_doorbreak" );
	level._effect[ "vfx_fire_wall_small" ] = loadfx( "vfx/ambient/fire/wall/vfx_fire_wall_small" );
	level._effect[ "m880_exp_dust" ] = loadfx( "vfx/moments/flood/m880_exp_dust" );
	level._effect[ "tank_exp_compressed" ] = loadfx( "vfx/moments/flood/tank_exp_compressed" );
	level._effect[ "flood_flare_outdoor_01" ] = loadfx( "vfx/moments/flood/flood_flare_outdoor_01" );
	level._effect[ "lens_flare_test_01" ] = loadfx( "vfx/test/lens_flare_test_01" );
	level._effect[ "transformer_explosion" ] = loadfx( "fx/explosions/transformer_explosion" );
	level._effect[ "flood_pole_hit" ] = loadfx( "vfx/moments/flood/flood_pole_hit" );
	level._effect[ "missile_impact_intro" ] = loadfx( "fx/explosions/missile_impact_intro" );
	level._effect[ "impact_sparks" ] = loadfx( "fx/impacts/impact_sparks_slow" );
	level._effect[ "flood_vignette_dust_runner" ] = loadfx( "vfx/moments/flood/flood_vignette_dust_runner" );
	level._effect[ "flood_vignette_dust" ] = loadfx( "vfx/moments/flood/flood_vignette_dust" );
	level._effect[ "flood_vignette_sparks_runner" ] = loadfx( "vfx/moments/flood/flood_vignette_sparks_runner" );
	level._effect[ "flood_m880_tire_dust" ] = loadfx( "vfx/moments/flood/flood_m880_tire_dust" );
	level._effect[ "car_crush_dust" ] = loadfx( "fx/dust/car_crush_dust" );
	level._effect[ "vehicle_tank_crush" ] = loadfx( "fx/explosions/vehicle_tank_crush" );
	level._effect[ "amb_dust_light_small_mixlit" ] = loadfx( "fx/dust/amb_dust_light_small_mixlit" );
	level._effect[ "flood_falling_sparks_runner" ] = loadfx( "vfx/moments/flood/flood_falling_sparks_runner" );
	level._effect[ "flood_stairwell_falling_dust_runner" ] = loadfx( "vfx/moments/flood/flood_stairwell_falling_dust_runner" );
	level._effect[ "falling_water_spray" ] = loadfx( "fx/water/falling_water_spray" );
	level._effect[ "flood_falling_sparks" ] = loadfx( "vfx/moments/flood/flood_falling_sparks" );
	level._effect[ "flood_falling_dirt_garage_runner" ] = loadfx( "vfx/moments/flood/flood_falling_dirt_garage_runner" );
	level._effect[ "falling_dirt_light_runner_tiffanies" ] = loadfx( "fx/dust/falling_dirt_light_runner_tiffanies" );
	level._effect[ "falling_dust_clockwork" ] = loadfx( "fx/dust/falling_dust_clockwork" );
	level._effect[ "sparks_test_01" ] = loadfx( "vfx/test/sparks_test_01" );
	level._effect[ "infil_ground_smk_plume_far" ] = loadfx( "vfx/moments/flood/infil_ground_smk_plume_far" );
    level._effect[ "water_single_splash_lrg" ] = loadfx( "vfx/ambient/water/water_single_splash_lrg" );
	level._effect[ "flood_water_ceiling_pour_lrg" ] = loadfx( "vfx/moments/flood/flood_water_ceiling_pour_lrg" );
	level._effect[ "flood_water_ceiling_pour_sm" ] = loadfx( "vfx/moments/flood/flood_water_ceiling_pour_sm" );
	level._effect[ "flood_water_ceiling_pour_medium" ] = loadfx( "vfx/moments/flood/flood_water_ceiling_pour_medium" );
	level._effect[ "flood_ground_smoke" ] = loadfx( "vfx/moments/flood/flood_ground_smoke" );
	level._effect[ "big_fuel_fire" ] = loadfx( "vfx/moments/flood/big_fuel_fire" );
	level._effect[ "flood_big_tank_explosion" ] = loadfx( "vfx/moments/flood/flood_big_tank_explosion" );
	level._effect[ "vfx_crater_dust_medium" ] = loadfx( "vfx/ambient/atmospheric/vfx_crater_dust_medium" );
	level._effect[ "flood_tank_window_break" ] = loadfx( "vfx/moments/flood/flood_tank_window_break" );
	level._effect[ "planter_explode" ] = loadfx( "vfx/moments/flood/planter_explode" );
	level._effect[ "streetlight_flare_yellow" ] = loadfx( "vfx/ambient/props/streetlight_flare_yellow" );
	level._effect[ "flood_tank_tank_crush" ] = loadfx( "vfx/moments/flood/flood_tank_tank_crush" );
	level._effect[ "tank_fire_ground_dust" ] = loadfx( "vfx/moments/flood/tank_fire_ground_dust" );
	level._effect[ "flood_infil_heli_dust_large" ] = loadfx( "vfx/moments/flood/flood_infil_heli_dust_large" );
	level._effect[ "flood_intro_heli_smoke" ] = loadfx( "vfx/moments/flood/flood_intro_heli_smoke" );
	level._effect[ "flood_swept_underwater" ] = loadfx( "vfx/moments/flood/flood_swept_underwater" );
	level._effect[ "rapids_splash_burst" ] = loadfx( "fx/water/rapids_splash_burst" );
	level._effect[ "light_car_wide_underwater" ] = loadfx( "vfx/ambient/lights/light_car_wide_underwater" );
	level._effect[ "lynx_brakelight" ] = loadfx( "vfx/moments/flood/lynx_brakelight" );
	level._effect[ "flood_floating_bottles_slow" ] = loadfx( "vfx/moments/flood/flood_floating_bottles_slow" );
	//level._effect[ "scuba_mask_distortion_warble" ] = loadfx( "vfx/moments/ship_graveyard/scuba_mask_distortion_warble" );
	//level._effect[ "shpg_scuba_bubbles_plr_front_dive" ] = loadfx( "vfx/_requests/shipg/shpg_scuba_bubbles_plr_front_dive" );
	level._effect[ "flood_floating_paper_slow" ] = loadfx( "vfx/moments/flood/flood_floating_paper_slow" );
	level._effect[ "flood_underwater_debri_large" ] = loadfx( "vfx/moments/flood/flood_underwater_debri_large" );
	level._effect[ "flood_underwater_godrays" ] = loadfx( "vfx/moments/flood/flood_underwater_godrays" );
	//level._effect[ "scuba_bubbles_plr_panic" ] = loadfx( "vfx/moments/ship_graveyard/scuba_bubbles_plr_panic" );
	//level._effect[ "bubbles_breath_hero" ] = loadfx( "vfx/ambient/water/bubbles_breath_hero" );
	//level._effect[ "vfx_godray_jungle_anim" ] = loadfx( "vfx/ambient/lights/vfx_godray_jungle_anim" );
	level._effect[ "flood_particlulates_light_02" ] = loadfx( "vfx/moments/flood/flood_particlulates_light_02" );
	level._effect[ "flood_particlulates_02" ] = loadfx( "vfx/moments/flood/flood_particlulates_02" );
	//level._effect[ "flood_particulate_in_light" ] = loadfx( "fx/water/flood_particulate_in_light" );
	level._effect[ "vfx_fire_wall_medium" ] = loadfx( "vfx/ambient/fire/wall/vfx_fire_wall_medium" );
	level._effect[ "flood_steam_floor_vent_low" ] = loadfx( "vfx/moments/flood/flood_steam_floor_vent_low" );
	level._effect[ "flood_steam_wall_vent" ] = loadfx( "vfx/moments/flood/flood_steam_wall_vent" );
	level._effect[ "smk_perif_oriented_smaller_02" ] = loadfx( "vfx/ambient/smoke/smk_perif_oriented_smaller_02" );
	//level._effect[ "vfx_godray_streaks_short_intense_org" ] = loadfx( "vfx/ambient/lights/vfx_godray_streaks_short_intense_org" );
	level._effect[ "underwater_current_straight" ] = loadfx( "vfx/ambient/water/underwater_current_straight" );
	level._effect[ "vfx_godray_streaks_short" ] = loadfx( "vfx/ambient/lights/vfx_godray_streaks_short" );
	//level._effect[ "circle_glow_w_beam_lg" ] = loadfx( "vfx/ambient/lights/circle_glow_w_beam_lg" );
	//level._effect[ "godray_underwater_long" ] = loadfx( "fx/lights/godray_underwater_long" );
	//level._effect[ "light_boat_bottom_wide_underwater" ] = loadfx( "vfx/ambient/lights/light_boat_bottom_wide_underwater" );
	level._effect[ "bubbles_mass_sheet_wider_fast" ] = loadfx( "vfx/ambient/water/bubbles_mass_sheet_wider_fast" );
	level._effect[ "vfx_embers_oriented_small" ] = loadfx( "vfx/ambient/sparks/vfx_embers_oriented_small" );
	level._effect[ "flood_bomb_flash_large" ] = loadfx( "vfx/moments/flood/flood_bomb_flash_large" );
	level._effect[ "flood_bombing_run_dist_runner" ] = loadfx( "vfx/moments/flood/flood_bombing_run_dist_runner" );
	level._effect[ "flood_periph_plumes" ] = loadfx( "vfx/moments/flood/flood_periph_plumes" );
	level._effect[ "flood_periph_plume" ] = loadfx( "vfx/moments/flood/flood_periph_plume" );
	level._effect[ "infil_ground_smk_plume_thin" ] = loadfx( "vfx/moments/flood/infil_ground_smk_plume_thin" );
	level._effect[ "flash_large" ] = loadfx( "vfx/moments/flood/flash_large" );
	level._effect[ "tank_concrete_explosion_omni" ] = loadfx( "vfx/gameplay/explosions/tank_concrete_explosion_omni" );
	level._effect[ "garage_explosion_flash" ] = loadfx( "vfx/moments/flood/flash_large" );
	level._effect[ "dust_puff_light_fast_16_02" ] = loadfx( "vfx/ambient/dust/dust_puff_light_fast_16_02" );
	level._effect[ "smk_perif_oriented_small_obscure" ] = loadfx( "vfx/ambient/smoke/smk_perif_oriented_small_obscure" );
	level._effect[ "cloud_ash_lite_flood" ] = loadfx( "vfx/moments/flood/cloud_ash_lite_flood" );
	level._effect[ "aa_flak_single" ] = loadfx( "fx/explosions/aa_flak_single" );
	level._effect[ "vfx_fire_burning_fuel_tank_nosmk" ] = loadfx( "vfx/ambient/fire/fuel/vfx_fire_burning_fuel_tank_nosmk" );
	level._effect[ "smk_perif_oriented_smaller_01" ] = loadfx( "vfx/ambient/smoke/smk_perif_oriented_smaller_01" );
	level._effect[ "antiair_single_tracer_flak" ] = loadfx( "fx/misc/antiair_single_tracer_flak" );
	level._effect[ "antiair_runner_flak_day" ] = loadfx( "fx/misc/antiair_runner_flak_day" );
	level._effect[ "battle_dust_fast_small" ] = loadfx( "fx/dust/battle_dust_fast_small" );
	level._effect[ "smk_perif_oriented_small_01" ] = loadfx( "vfx/ambient/smoke/smk_perif_oriented_small_01" );
	//level._effect[ "vfx_fire_burning_fuel_tank" ] = loadfx( "vfx/ambient/fire/fuel/vfx_fire_burning_fuel_tank" );
	//level._effect[ "vfx_fire_car_large" ] = loadfx( "vfx/ambient/fire/fuel/vfx_fire_car_large" );
	level._effect[ "vfx_fire_wall_lg_far" ] = loadfx( "vfx/ambient/fire/wall/vfx_fire_wall_lg_far" );
	level._effect[ "infil_ground_smk_plume" ] = loadfx( "vfx/moments/flood/infil_ground_smk_plume" );
	level._effect[ "infil_building_fire_small" ] = loadfx( "vfx/moments/flood/infil_building_fire_small" );
	level._effect[ "infil_building_smoke" ] = loadfx( "vfx/moments/flood/infil_building_smoke" );
	level._effect[ "smk_plume_black_lrg" ] = loadfx( "vfx/ambient/smoke/smk_plume_black_lrg" );
	//level._effect[ "smk_street_obscure" ] = loadfx( "vfx/ambient/smoke/smk_street_obscure" );
	level._effect[ "sparks_subway_truck_collision" ] = loadfx( "fx/misc/sparks_subway_truck_collision" );
	level._effect[ "thermite_sparks_collide" ] = loadfx( "fx/explosions/thermite_sparks_collide" );
	level._effect[ "vehicle_scrape_sparks_smokey" ] = loadfx( "fx/misc/vehicle_scrape_sparks_smokey" );
	level._effect[ "sparks_car_scrape_point" ] = loadfx( "fx/misc/sparks_car_scrape_point" );
	level._effect[ "infil_heli_smk_swirl_lt_01" ] = loadfx( "vfx/moments/flood/infil_heli_smk_swirl_lt_01" );
	level._effect[ "smk_street_fog_low" ] = loadfx( "vfx/ambient/smoke/smk_street_fog_low" );
	level._effect[ "battle_dust_medium" ] = loadfx( "fx/dust/battle_dust_medium" );
	level._effect[ "sunglow_ginormous" ] = loadfx( "vfx/ambient/lights/sunglow_ginormous" );
	level._effect[ "infil_building_fire" ] = loadfx( "vfx/moments/flood/infil_building_fire" );
	//level._effect[ "infil_heli_smk_plume_lt_01" ] = loadfx( "vfx/moments/flood/infil_heli_smk_plume_lt_01" );
	level._effect[ "flood_infil_tank_hit" ] = loadfx( "vfx/moments/flood/flood_infil_tank_hit" );
	level._effect[ "rooftop1_stairwell_dust" ] = loadfx( "vfx/moments/flood/rooftop1_stairwell_dust" );
	level._effect[ "flood_skybridge_build_fallingdust_runner" ] = loadfx( "vfx/moments/flood/flood_skybridge_build_fallingdust_runner" );
	level._effect[ "amb_dust_dark_building_smolder_small" ] = loadfx( "fx/dust/amb_dust_dark_building_smolder_small" );
	level._effect[ "amb_dust_dark_building_smolder" ] = loadfx( "fx/dust/amb_dust_dark_building_smolder" );
	level._effect[ "rooftop1_heli_dust_kickup" ] = loadfx( "vfx/moments/flood/rooftop1_heli_dust_kickup" );
	level._effect[ "mountain_clouds_wispy_02" ] = loadfx( "vfx/ambient/weather/clouds/mountain_clouds_wispy_02" );
	level._effect[ "mountain_clouds_wispy" ] = loadfx( "vfx/ambient/weather/clouds/mountain_clouds_wispy" );
	level._effect[ "area_splash_20x20_runner" ] = loadfx( "vfx/ambient/weather/rain/area_splash_20x20_runner" );
	level._effect[ "rain_ground_100_runner" ] = loadfx( "vfx/ambient/weather/rain/rain_ground_100_runner" );
	level._effect[ "rooftops_mid_periph_smoke_column" ] = loadfx( "vfx/moments/flood/rooftops_mid_periph_smoke_column" );
	level._effect[ "flood_mist_static_sparkle" ] = loadfx( "vfx/moments/flood/flood_mist_static_sparkle" );
	level._effect[ "sunglow_huge" ] = loadfx( "vfx/ambient/lights/sunglow_huge" );
	level._effect[ "rapids_splash_lg_flood" ] = loadfx( "vfx/moments/flood/rapids_splash_lg_flood" );
	level._effect[ "flood_mist_low_01" ] = loadfx( "vfx/moments/flood/flood_mist_low_01" );
	level._effect[ "rooftop1_heli_debris_kickup" ] = loadfx( "vfx/moments/flood/rooftop1_heli_debris_kickup" );
	level._effect[ "gust_debris_pieces" ] = loadfx( "vfx/ambient/misc/gust_debris_pieces" );
	level._effect[ "rooftop_1_wall_kick_dust" ] = loadfx( "vfx/moments/flood/rooftop_1_wall_kick_dust" );
	level._effect[ "flood_rooftops_fallingdust_runner" ] = loadfx( "vfx/moments/flood/flood_rooftops_fallingdust_runner" );
	level._effect[ "blood_stealth_hatchet" ] = loadfx( "vfx/moments/flood/blood_stealth_hatchet" );
	level._effect[ "blood_cough_heavy" ] = loadfx( "fx/misc/blood_cough_heavy" );
	level._effect[ "blood_chest_wound" ] = loadfx( "fx/misc/blood_chest_wound" );
	level._effect[ "intro_blood_throat_stab" ] = loadfx( "fx/maps/warlord/intro_blood_throat_stab" );
	level._effect[ "blood_spurt_trapped_underwater" ] = loadfx( "fx/water/blood_spurt_trapped_underwater" );
	
	level._effect[ "blood_spurt_underwater" ] = loadfx( "fx/water/blood_spurt_underwater" );
	level._effect[ "flood_swept_body_bubbles" ] = loadfx( "vfx/moments/flood/flood_swept_body_bubbles" );
	level._effect[ "bubbles_player_hand" ] = loadfx( "vfx/moments/flood/flood_swept_body_bubbles" );
	//level._effect[ "flood_swept_flashlight" ] = loadfx( "fx/misc/flashlight_spotlight_occlude" );
	level._effect[ "flood_swept_flashlight" ] = loadfx( "vfx/moments/flood/flood_swept_flashlight" );
	level._effect[ "flood_swept_player_murk" ] = loadfx( "vfx/moments/flood/flood_swept_player_murk" );
	level._effect[ "waterline_test_01" ] = loadfx( "vfx/test/waterline_test_01" );
	level._effect[ "splash_crest_large_fast" ] = loadfx( "vfx/ambient/water/splash_crest_large_fast" );
	level._effect[ "splash_patch_medium_01" ] = loadfx( "vfx/ambient/water/splash_patch_medium_01" );
	level._effect[ "splash_line_medium_01" ] = loadfx( "vfx/ambient/water/splash_line_medium_01" );
	level._effect[ "mall_rooftop_guy_falls_02" ] = loadfx( "vfx/moments/flood/mall_rooftop_guy_falls_02" );
	level._effect[ "debri_bubbles_emit" ] = loadfx( "vfx/moments/flood/debri_bubbles_emit" );
	level._effect[ "debri_bubbles" ] = loadfx( "vfx/moments/flood/debri_bubbles" );
	level._effect[ "mall_rooftop_guy_falls" ] = loadfx( "vfx/moments/flood/mall_rooftop_guy_falls" );
	level._effect[ "flood_splash_lg_r" ] = loadfx( "vfx/moments/flood/flood_splash_lg_r" );
	level._effect[ "flood_mr_debri_explosion_up" ] = loadfx( "vfx/moments/flood/flood_mr_debri_explosion_up" );
	level._effect[ "flood_body_ambient_bubbles" ] = loadfx( "vfx/moments/flood/flood_body_ambient_bubbles" );
	level._effect[ "flood_hand_bubbles" ] = loadfx( "vfx/moments/flood/flood_hand_bubbles" );
	level._effect[ "warehouse_doorbreach_cover_splashes" ] = loadfx( "vfx/moments/flood/warehouse_doorbreach_cover_splashes" );
	level._effect[ "flood_mr_debri_explosion" ] = loadfx( "vfx/moments/flood/flood_mr_debri_explosion" );
	level._effect[ "debri_explosion" ] = loadfx( "fx/explosions/debri_explosion" );
	level._effect[ "mall_rooftop_splashes_medium" ] = loadfx( "vfx/moments/flood/mall_rooftop_splashes_medium" );
	level._effect[ "mall_rooftop_door_glow" ] = loadfx( "vfx/moments/flood/mall_rooftop_door_glow" );
	level._effect[ "mall_rooftop_door_godray" ] = loadfx( "vfx/moments/flood/mall_rooftop_door_godray" );
	level._effect[ "mall_rooftop_updust_01" ] = loadfx( "vfx/moments/flood/mall_rooftop_updust_01" );
	level._effect[ "mall_rooftop_splashes_huge" ] = loadfx( "vfx/moments/flood/mall_rooftop_splashes_huge" );
	level._effect[ "mall_rooftop_collapse_dust_huge_01" ] = loadfx( "vfx/moments/flood/mall_rooftop_collapse_dust_huge_01" );
	level._effect[ "mall_rooftop_collapse_dust_small" ] = loadfx( "vfx/moments/flood/mall_rooftop_collapse_dust_small" );
	level._effect[ "mall_rooftop_crack_splash_runner" ] = loadfx( "vfx/moments/flood/mall_rooftop_crack_splash_runner" );
	level._effect[ "warehouse_doorbreach_splash" ] = loadfx( "vfx/moments/flood/warehouse_doorbreach_splash" );
	level._effect[ "warehouse_doorbreach_smoke" ] = loadfx( "vfx/moments/flood/warehouse_doorbreach_smoke" );
	level._effect[ "streets_godray_01" ] = loadfx( "vfx/moments/flood/streets_godray_01" );
	level._effect[ "smk_wispy_thin_low_short" ] = loadfx( "vfx/moments/flood/smk_wispy_thin_low_short" );
	level._effect[ "smk_wispy_thin" ] = loadfx( "vfx/moments/flood/smk_wispy_thin" );
	level._effect[ "mall_rooftop_steam" ] = loadfx( "vfx/moments/flood/mall_rooftop_steam" );
	level._effect[ "m880_red_glow" ] = loadfx( "vfx/moments/flood/m880_red_glow" );
	level._effect[ "vfx_steam_stack_blowing_drkprpl_1" ] = loadfx( "vfx/ambient/smoke/vfx_steam_stack_blowing_drkprpl_1" );
	level._effect[ "mall_rooftop_rapids_splashes" ] = loadfx( "vfx/moments/flood/mall_rooftop_rapids_splashes" );
	level._effect[ "mall_rooftop_up_mist" ] = loadfx( "vfx/moments/flood/mall_rooftop_up_mist" );
	level._effect[ "mall_rooftop_rumble_smoke" ] = loadfx( "vfx/moments/flood/mall_rooftop_rumble_smoke" );
	level._effect[ "mall_rooftop_collapse_dust_medium" ] = loadfx( "vfx/moments/flood/mall_rooftop_collapse_dust_medium" );
	level._effect[ "mall_rooftop_crush_dust_emit" ] = loadfx( "vfx/moments/flood/mall_rooftop_crush_dust_emit" );
	level._effect[ "mall_rooftop_dust_linger" ] = loadfx( "vfx/moments/flood/mall_rooftop_dust_linger" );
	level._effect[ "flood_stairwell_falling_dust" ] = loadfx( "vfx/moments/flood/flood_stairwell_falling_dust" );
	level._effect[ "flood_mall_roof_small_splash" ] = loadfx( "vfx/moments/flood/flood_mall_roof_small_splash" );
	level._effect[ "mall_rooftop_crush_dust" ] = loadfx( "vfx/moments/flood/mall_rooftop_crush_dust" );
	level._effect[ "flood_m880_hand_dust" ] = loadfx( "vfx/moments/flood/flood_m880_hand_dust" );
	level._effect[ "flood_mall_roof_debri_01" ] = loadfx( "vfx/moments/flood/flood_mall_roof_debri_01" );
	level._effect[ "flood_mall_roof_med_splash" ] = loadfx( "vfx/moments/flood/flood_mall_roof_med_splash" );
	level._effect[ "flood_mall_roof_big_splash_01" ] = loadfx( "vfx/moments/flood/flood_mall_roof_big_splash_01" );
	level._effect[ "flood_mall_roof_waterpile_01" ] = loadfx( "vfx/moments/flood/flood_mall_roof_waterpile_01" );
	level._effect[ "flood_mall_roof_waterpile_small_01" ] = loadfx( "vfx/moments/flood/flood_mall_roof_waterpile_small_01" );
	level._effect[ "splash_lens_01" ] = loadfx( "vfx/ambient/water/splash_lens_01" );
	level._effect[ "splash_lens_03" ] = loadfx( "vfx/ambient/water/splash_lens_03" );
	level._effect[ "flood_water_door_spray_small_light" ] = loadfx( "vfx/moments/flood/flood_water_door_spray_small_light" );
	level._effect[ "flood_door_glow_tight_01" ] = loadfx( "vfx/moments/flood/flood_door_glow_tight_01" );
	level._effect[ "randomfan_small" ] = loadfx( "vfx/ambient/lights/randomfan_small" );
	level._effect[ "randomfan" ] = loadfx( "vfx/ambient/lights/randomfan" );
	level._effect[ "warmglow" ] = loadfx( "vfx/ambient/lights/warmglow" );
	//level._effect[ "chromaloop_right" ] = loadfx( "vfx/ambient/misc/chromaloop_right" );
	//level._effect[ "chromaloop_left" ] = loadfx( "vfx/ambient/misc/chromaloop_left" );
	level._effect[ "flood_splash_door_froth_01" ] = loadfx( "vfx/moments/flood/flood_splash_door_froth_01" );
	level._effect[ "flood_splash_door_glow_splashes_01" ] = loadfx( "vfx/moments/flood/flood_splash_door_glow_splashes_01" );
	level._effect[ "flood_door_glow_01" ] = loadfx( "vfx/moments/flood/flood_door_glow_01" );
	level._effect[ "water_drips_hallway" ] = loadfx( "fx/water/water_drips_hallway" );
	level._effect[ "drips_fast" ] = loadfx( "fx/misc/drips_fast" );
	level._effect[ "drips_slow_infrequent" ] = loadfx( "fx/misc/drips_slow_infrequent" );
	level._effect[ "flood_wh_drip_singlestream_01" ] = loadfx( "vfx/moments/flood/flood_wh_drip_singlestream_01" );
	level._effect[ "flood_splash_door_stream_thick_01" ] = loadfx( "vfx/moments/flood/flood_splash_door_stream_thick_01" );
	level._effect[ "flood_splash_door_stream_long" ] = loadfx( "vfx/moments/flood/flood_splash_door_stream_long" );
	level._effect[ "flood_splash_door_medium_frequent_runner" ] = loadfx( "vfx/moments/flood/flood_splash_door_medium_frequent_runner" );
	level._effect[ "flood_splash_door_small_runner" ] = loadfx( "vfx/moments/flood/flood_splash_door_small_runner" );
	level._effect[ "dropper_test" ] = loadfx( "vfx/test/dropper_test" );
	level._effect[ "flood_falling_palm_tree" ] = loadfx( "vfx/moments/flood/flood_falling_palm_tree" );
	level._effect[ "splash_lens_02" ] = loadfx( "vfx/ambient/water/splash_lens_02" );
	level._effect[ "flood_dam_water_tip_splash" ] = loadfx( "vfx/moments/flood/flood_dam_water_tip_splash" );
	level._effect[ "flood_dam_water_valley_splashes_01" ] = loadfx( "vfx/moments/flood/flood_dam_water_valley_splashes_01" );
	level._effect[ "flood_dam_water_falling_02" ] = loadfx( "vfx/moments/flood/flood_dam_water_falling_02" );
	level._effect[ "flood_dam_water_explosion" ] = loadfx( "vfx/moments/flood/flood_dam_water_explosion" );
	level._effect[ "birds_dam_birds_01" ] = loadfx( "vfx/moments/flood/birds_dam_birds_01" );
	level._effect[ "birds_flood_street_birds_01" ] = loadfx( "vfx/moments/flood/birds_flood_street_birds_01" );

	level._effect[ "flood_m880_exhaust_static" ] = loadfx( "vfx/moments/flood/flood_m880_exhaust_static" );
	level._effect[ "flood_m880_smoke_swirl" ] = loadfx( "vfx/moments/flood/flood_m880_smoke_swirl" );
	level._effect[ "flood_m880_missile_begin" ] = loadfx( "vfx/moments/flood/flood_m880_missile_begin" );
	level._effect[ "birds_tree_panicked" ] = loadfx( "fx/animals/birds_tree_panicked" );
	level._effect[ "birds_takeoff_up_dark" ] = loadfx( "fx/misc/birds_takeoff_up_dark" );
	level._effect[ "flood_dam_hit_explosion_cheap" ] = loadfx( "vfx/moments/flood/flood_dam_hit_explosion_cheap" );
	level._effect[ "flood_dam_hit_explosion" ] = loadfx( "vfx/moments/flood/flood_dam_hit_explosion" );
	level._effect[ "flood_m880_launch_falling_dust_02" ] = loadfx( "vfx/moments/flood/flood_m880_launch_falling_dust_02" );
	level._effect[ "flood_m880_launch_dust_linger" ] = loadfx( "vfx/moments/flood/flood_m880_launch_dust_linger" );
	level._effect[ "flood_m880_exhaust_02" ] = loadfx( "vfx/moments/flood/flood_m880_exhaust_02" );
	level._effect[ "small_water_splash"		 ] = LoadFX( "fx/water/flood_splash_small" );
	level._effect[ "small_water_splash_fast" ] = LoadFX( "fx/water/flood_splash_small_fast" );
	level._effect[ "medium_water_splash"	 ] = LoadFX( "fx/water/flood_splash_medium" );
	level._effect[ "medium_water_splash_oneshot" ] = LoadFX( "fx/water/flood_splash_medium_oneshot" );
	level._effect[ "giant_water_splash"		 ] = LoadFX( "vfx/moments/flood/flood_street_giant_water_splash" );
	
	// Dam Event
	level._effect[ "vfx_m880_exhaust" ] = LoadFX( "vfx/gameplay/missile/fire/vfx_m880_exhaust" );
	level._effect[ "vfx_m880_exhaust_front" ] = LoadFX( "vfx/gameplay/missile/fire/vfx_m880_exhaust_front" );
	level._effect[ "flood_m880_exhaust" ] = LoadFX( "vfx/moments/flood/flood_m880_exhaust" );
	level._effect[ "flood_m880_dust" ] = LoadFX( "vfx/moments/flood/flood_m880_dust" );
	level._effect[ "flood_m880_launch_falling_dust" ] = LoadFX( "vfx/moments/flood/flood_m880_launch_falling_dust" );
	level._effect[ "godray_large_01" ] = LoadFX( "vfx/ambient/misc/godray_large_01" );
	level._effect[ "flood_m880_missile_trail_01" ] = LoadFX( "vfx/moments/flood/flood_m880_missile_trail_01" );
	level._effect[ "flood_m880_afterburn_ignite" ] = LoadFX( "vfx/moments/flood/flood_m880_afterburn_ignite" );
	
	level._effect["flood_dam_event_base_mist"] = LoadFX("fx/water/flood_dam_event_base_mist");
	level._effect["flood_dam_event_street_mist"] = LoadFX("fx/water/flood_dam_event_street_mist");
	level._effect["flood_dam_event_alley_mist"] = LoadFX("fx/water/flood_dam_event_alley_mist");
	level._effect["flood_dam_event_street_mist2"] = LoadFX("fx/water/flood_dam_event_street_mist2");
	
	level._effect["flood_dam_event_street_obj_mist"] = LoadFX("fx/water/flood_dam_event_street_obj_mist");
	level._effect["flood_dam_event_street_splash_lp"] = LoadFX("fx/water/flood_dam_event_street_splash_lp");
	level._effect["flood_dam_event_street_splash_shadow_lp"] = LoadFX("fx/water/flood_dam_event_street_splash_shadow_lp");
	level._effect["flood_dam_event_bigwave_splash_lp"] = LoadFX("fx/water/flood_dam_event_bigwave_splash_lp");
	level._effect["flood_dam_event_bigwave2_splash_lp"] = LoadFX("fx/water/flood_dam_event_bigwave2_splash_lp");
	level._effect["flood_splash_pole_impact_01"] = LoadFX("vfx/moments/flood/flood_splash_pole_impact_01");
	level._effect["flood_splash_pole_impact_shadow_01"] = LoadFX("vfx/moments/flood/flood_splash_pole_impact_shadow_01");
	level._effect["flood_street_splash_large_01"] = LoadFX("vfx/moments/flood/flood_street_splash_large_01");
	level._effect["flood_street_splash_front_rolling"] = LoadFX("vfx/moments/flood/flood_street_splash_front_rolling");
	level._effect["flood_street_splash_front_rolling_dark"] = LoadFX("vfx/moments/flood/flood_street_splash_front_rolling_dark");
	level._effect["flood_alley_splash_front_rolling"] = LoadFX("vfx/moments/flood/flood_alley_splash_front_rolling");
			
	// level._effect["flood_streets_tree_dust"] = LoadFX("vfx/moments/flood/flood_streets_tree_dust");
	level._effect["flood_splash_small_lp"] = LoadFX("fx/water/flood_splash_small_lp");
	level._effect["flood_splash_small_far_lp"] = LoadFX("fx/water/flood_splash_small_far_lp");
	level._effect["flood_paper_blowing_cards"] = LoadFX("vfx/moments/flood/flood_paper_blowing_cards");
	level._effect["flood_warehouse_double_doors_froth"] = LoadFX("vfx/moments/flood/flood_warehouse_double_doors_froth");
	level._effect["flood_warehouse_ally_mantle"] = LoadFX("vfx/moments/flood/flood_warehouse_ally_mantle");
	level._effect["flood_splash_alley_front"] = LoadFX("fx/water/flood_splash_alley_front");
	level._effect["flood_splash_alley_reverse"] = LoadFX("fx/water/flood_splash_alley_reverse");

	// water emerge stuff stolen from warlord
	level._effect[ "water_emerge"				] = LoadFX( "fx/maps/warlord/water_emerge" );
	//level._effect[ "water_emerge_2"				] = LoadFX( "fx/maps/warlord/water_emerge_2" );
	//level._effect[ "water_emerge_3"				] = LoadFX( "fx/maps/warlord/water_emerge_3" );
	level._effect[ "water_emerge_4"				] = LoadFX( "fx/maps/warlord/water_emerge_4" );
	//level._effect[ "water_emerge_weapon"		] = LoadFX( "fx/maps/warlord/water_emerge_weapon" );
	//level._effect[ "water_emerge_player_weapon" ] = LoadFX( "fx/maps/warlord/water_emerge_player_weapon" );
	//level._effect[ "water_emerge_player_hand"	] = LoadFX( "fx/maps/warlord/water_emerge_player_hand" );
	//level._effect[ "water_emerge_bulge"			] = LoadFX( "fx/maps/warlord/water_emerge_bulge" );
	//level._effect[ "water_emerge_bulge_2"		] = LoadFX( "fx/maps/warlord/water_emerge_bulge_2" );
	
	// new warlord like stuff
	level._effect[ "water_emerge_weapon" ] = LoadFX( "vfx/moments/flood/flood_water_emerge_weapon" );
	level._effect[ "character_drips"	 ] = LoadFX( "vfx/moments/flood/flood_character_drips" );

	// temp FX for ambients - CHAD
	level._effect[ "antiair_runner_flak" ] = LoadFX( "fx/misc/antiair_runner_flak" );

	level._effect["rpg_trail"]				 									= loadfX ("fx/smoke/smoke_geotrail_rpg");
	level._effect["blackhawk_explosion"]										= loadfx ("fx/explosions/heli_engine_osprey_explosion");	
	level._effect["car_glass_large"]											= loadfx ("fx/props/car_glass_large");	
	level._effect["water_hydrant"]												= loadfx ("fx/water/water_hydrant");	
	level._effect[ "pipe_steam" ]												= loadFX ("fx/impacts/pipe_steam" );
	level._effect[ "pipe_steam_looping" ]										= loadFX ("fx/impacts/pipe_steam_looping" );
	level._effect[ "footstep_water" ]							= loadfx( "fx/maps/ny_harbor/footstep_water" );
	level._effect[ "player_submerge" ]							= loadfx( "fx/water/player_submerge" );
	level._effect[ "rapids_splash_0x1000" ]						= loadfx( "fx/water/rapids_splash_0x1000" );
	level._effect[ "rapids_splash_1000x1000" ]					= loadfx( "fx/water/rapids_splash_1000x1000" );
	level._effect[ "rapids_splash_large" ]						= loadfx( "fx/water/rapids_splash_large" );
	level._effect[ "rapids_splash_md_castle" ]					= loadfx( "fx/water/rapids_splash_md_castle" );
	level._effect[ "rapids_splash_sm_castle" ]					= loadfx( "fx/water/rapids_splash_sm_castle" );
	level._effect[ "rapids_splash_xlg_fast_castle" ]			= loadfx( "fx/water/rapids_splash_xlg_fast_castle" );
	level._effect[ "river_splash_lg_castle" ]					= loadfx( "fx/water/river_splash_lg_castle" );
	level._effect[ "river_splash_small" ]						= loadfx( "fx/water/river_splash_small" );
	level._effect[ "water_intro_river_dressing" ]				= loadfx( "fx/water/water_intro_river_dressing" );
	level._effect[ "water_intro_river_dressing_fast" ]			= loadfx( "fx/water/water_intro_river_dressing_fast" );
	level._effect[ "water_intro_river_dressing_large" ]			= loadfx( "fx/water/water_intro_river_dressing_large" );
	level._effect[ "water_intro_river_wake_field" ]				= loadfx( "fx/water/water_intro_river_wake_field" );
	level._effect[ "flooded_water_tower_impact" ]				= loadfx( "fx/water/flooded_water_tower_impact" );
	level._effect[ "flooded_office_murk" ]						= loadfx( "fx/water/flooded_office_murk" );
	
	level._effect[ "amb_dust_verylight_cheap" ]							= loadfx( "fx/dust/amb_dust_verylight_cheap" );
	level._effect[ "amb_dust_verylight_small" ]							= loadfx( "fx/dust/amb_dust_verylight_small" );
	level._effect[ "amb_dust_light_med_graylit" ]						= loadfx( "fx/dust/amb_dust_light_med_graylit" );
	level._effect[ "dust_ground_gust_dubai" ]							= loadfx( "fx/dust/dust_ground_gust_dubai" );
	level._effect[ "heli_land_swirl_large" ]							= loadfx( "fx/dust/heli_land_swirl_large" );
	level._effect[ "battle_dust_huge_01" ]								= loadfx( "fx/dust/battle_dust_huge_01" );
	level._effect[ "battle_dust_huge_02" ]								= loadfx( "fx/dust/battle_dust_huge_02" );
	level._effect[ "amb_dust_light_large_mixlit" ]						= loadfx( "fx/dust/amb_dust_light_large_mixlit" );
	
	//for use with kill_deathflag
	level._effect[ "flesh_hit" ]					 			= loadfx( "fx/impacts/flesh_hit" );

	//infil ambient fx
	//level._effect[ "smoke_plume_black_01" ]						= loadfx ("fx/smoke/smoke_plume_black_01" );
	//level._effect[ "smoke_plume_black_02" ]						= loadfx ("fx/smoke/smoke_plume_black_02" );
	//level._effect[ "smoke_plume_black_model_sml" ]				= loadfx ("fx/smoke/smoke_plume_black_model_sml" );
	//level._effect[ "smoke_plume_black_model_mid" ]				= loadfx ("fx/smoke/smoke_plume_black_model_mid" );
	//level._effect[ "smoke_plume_black_model_lg" ]				= loadfx ("fx/smoke/smoke_plume_black_model_lg" );
	//level._effect[ "smoke_distant_black_01" ]					= loadfx ("fx/smoke/smoke_distant_black_01" );
	//level._effect[ "bomb_explosion_ac130_bombing_run_dist_runner" ]					= loadfx ("fx/explosions/bomb_explosion_ac130_bombing_run_dist_runner" );
	
	//mall garage fx
	level._effect[ "tank_concrete_explosion" ]						= loadfx ("vfx/gameplay/explosions/impacts/vfx_tank_concrete_explosion" );
	
	//warehouse fx
	level._effect[ "flood_water_splash_light_01"	] 					= LoadFX( "vfx/moments/flood/flood_water_splash_light_01" );
	level._effect[ "flood_water_splash_light_small_01"	] 				= LoadFX( "vfx/moments/flood/flood_water_splash_light_small_01" );
	level._effect[ "flood_water_splash_large_dark_01"	] 				= LoadFX( "vfx/moments/flood/flood_water_splash_large_dark_01" );
	level._effect[ "flood_water_splash_medium_dark_01"	] 				= LoadFX( "vfx/moments/flood/flood_water_splash_medium_dark_01" );
	level._effect[ "flood_water_splash_dark_small_01"	] 				= LoadFX( "vfx/moments/flood/flood_water_splash_dark_small_01" );
	level._effect[ "flood_water_door_spray_medium"	] 					= LoadFX( "vfx/moments/flood/flood_water_door_spray_medium" );
	level._effect[ "flood_water_door_spray_small"	] 					= LoadFX( "vfx/moments/flood/flood_water_door_spray_small" );
	level._effect[ "flood_water_splash_light_falling"	] 				= LoadFX( "vfx/moments/flood/flood_water_splash_light_falling" );
	level._effect[ "flood_water_splash_dark_falling"	] 				= LoadFX( "vfx/moments/flood/flood_water_splash_dark_falling" );
	level._effect[ "flood_water_door_spray_room01"	] 					= LoadFX( "vfx/moments/flood/flood_water_door_spray_room01" );
	level._effect[ "flood_water_door_spray_room02_small_dark"	] 		= LoadFX( "vfx/moments/flood/flood_water_door_spray_room02_small_dark" );
	level._effect[ "flood_water_door_spray_room02_medium"	] 			= LoadFX( "vfx/moments/flood/flood_water_door_spray_room02_medium" );
	level._effect[ "flood_water_door_spray_room02_door_break"	] 		= LoadFX( "vfx/moments/flood/flood_water_door_spray_room02_door_break" );
	level._effect[ "flood_water_double_doors_spray"	] 		= LoadFX( "vfx/moments/flood/flood_water_double_doors_spray" );
	
	//level._effect[ "flood_water_stream splash_dark_01"	] 				= LoadFX( "vfx/moments/flood/flood_water_stream splash_dark_01" );
	// FIX JKU shouldn't this be using the same bubbles as the coverwater????  (scuba)
	level._effect[ "flooded_player_bubbles" ] = LoadFX( "fx/water/flooded_player_bubbles" );
	level._effect[ "flashlight"					 ] = LoadFX( "fx/misc/flashlight" );

	//rooftops ambient debri
	level._effect[ "flood_mist_01" ]							= loadfx ("fx/water/flood_mist_01" );
	
	//splash fx
	level._effect[ "splash_mist_lg" ]							= loadfx( "fx/water/splash_mist_lg" );
	level._effect[ "splash_pole_impact_01" ]					= loadfx( "vfx/ambient/water/splash_pole_impact_01" );
	level._effect[ "splash_large_impact_01" ]					= loadfx( "vfx/ambient/water/splash_large_impact_01" );
	//level._effect[ "splash_flood_surface_small" ]				= loadfx( "fx/water/splash_flood_surface_small" );
	
	//swept fx
	level._effect[ "flood_water_swept_bubbles_01" ]					= loadfx( "vfx/moments/flood/flood_water_swept_bubbles_01" );

	
	//skybridge event fx
	level._effect[ "building_collapse_smoke_lg" ]				= loadfx ("fx/smoke/building_collapse_smoke_lg" );
	level._effect[ "sparks_runner" ]							= loadfx ("fx/explosions/sparks_runner" );
	//bokehdot screenfx
	level._effect[ "bokehdots_far" ]			= loadfx ( "vfx/gameplay/screen_effects/vfx_scrnfx_bokehdots_inst_far" );
	level._effect[ "bokehdots_close" ]			= loadfx ( "vfx/gameplay/screen_effects/vfx_scrnfx_bokehdots_inst_close" );
	level._effect[ "bokehdots_16" ]				= loadfx ( "vfx/gameplay/screen_effects/scrnfx_water_bokeh_dots_inst_16" );
	level._effect[ "bokehdots_32" ]				= loadfx ( "vfx/gameplay/screen_effects/scrnfx_water_bokeh_dots_inst_32" );
	level._effect[ "bokehdots_64" ]				= loadfx ( "vfx/gameplay/screen_effects/scrnfx_water_bokeh_dots_inst_64" );	

	level._effect[ "waterdrops_3" ]					  = LoadFX ( "vfx/gameplay/screen_effects/vfx_scrnfx_waterdrops_3" );
	level._effect[ "waterdrops_20_inst" ]			  = LoadFX ( "vfx/gameplay/screen_effects/vfx_scrnfx_waterdrops_20_inst" );
	level._effect[ "bokehdots_and_waterdrops_heavy" ] = LoadFX ( "vfx/gameplay/screen_effects/vfx_scrnfx_bokehwater_heavy" );
	
	// flare countermeasure fx for chopper
	level._effect[ "chopper_countermeasure" ]	= loadfx ( "vfx/moments/flood/flood_m880_missile_trail_01" );
	
	// flag to play particles or not - for debugging and sequence refactoring
	level.playAngryFloodVFX = true;

	// set the default level vision set
	set_vision_set( "flood", 0 );
	fog_set_changes( "flood", 0 );
	level.cw_bloom_above = "flood_bloom";
	level.cw_vision_above = "flood";
	level.cw_fog_above = "flood";
	
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\flood_fx::main();
		maps\createfx\flood_sound::main();	
	}


   thread fx_vision_fog_init();
   //thread fx_loading_docks_water_01();
   //thread fx_loading_docks_water_02();
   thread fx_mall_roof_water_hide();
   thread fx_rooftops_water_hide();
   //thread fx_rooftops_water_show();
   thread fx_dam_waterfall_hide();
   //thread alley_water_hide();
   thread set_enter_skybridge_room_vf();
   thread freon_leak_fx_turn_off_damage();
   thread rooftop_01_misc_fx();
   thread fx_skybridge_room_bokeh_01();
   thread fx_skybridge_room_bokeh_02();
   thread fx_retarget_warehouse_waters_lighting();
   thread fx_retarget_rooftop_water_lighting();
   thread trigger_debris_bridge_water();
   thread fx_set_alpha_threshold();
   //thread fx_hide_mr_clip_effects();


   //thread fx_mall_rooftop_hide_shadow_geo();
   //level thread vignettes();
   //thread fx_underwaterfx_kill();
	//thread flood_amb_fx();

   //thread fx_loading_docks_water_hide_top();
   setup_flood_water_anims();

//SetSavedDvar("sm_sunSampleSizeNear", 3.5);
//go to .6 after heli lands... in flood_streets.gsc
}

flood_amb_fx()
{
	Exploder("10523");
}

fx_lynx_sparks( convoy_lynx )
{
	IPrintLnBold( "got lynx fx" );
	Exploder("barrel_explosion");
}

fx_tank_window_break()
{
	wait 1;
	//IPrintLnBold( "tank_window_break fx" );
	exploder( "tank_window_break" );
}


#using_animtree( "script_model" );
setup_flood_water_anims()
{
	level.scr_animtree	[ "alley_water" ]								 = #animtree;
	level.scr_model		[ "alley_water" ]								 = "flood_alley_flood_water_contig0";
	level.scr_anim		[ "alley_water" ][ "flood_alleyflood_contig_waterflow0" ] = %flood_alleyflood_contig_waterflow0;

	level.scr_animtree	[ "angry_water" ]								 = #animtree;
	level.scr_model		[ "angry_water" ]								 = "flood_angryflood_contig0";
	level.scr_anim		[ "angry_water" ][ "flood_angryflood_contig_waterflow0" ] = %flood_angryflood_contig_waterflow0;

	addNotetrack_notify("angry_water", "flood_shake_tree_right_1", "flood_shake_tree_right_1", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_right_2", "flood_shake_tree_right_2", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_right_3", "flood_shake_tree_right_3", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_right_4", "flood_shake_tree_right_4", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_right_5", "flood_shake_tree_right_5", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_right_6", "flood_shake_tree_right_6", "flood_angryflood_contig_waterflow0");

	addNotetrack_notify("angry_water", "flood_shake_tree_left_1", "flood_shake_tree_left_1", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_left_2", "flood_shake_tree_left_2", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_left_3", "flood_shake_tree_left_3", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_left_4", "flood_shake_tree_left_4", "flood_angryflood_contig_waterflow0");
	addNotetrack_notify("angry_water", "flood_shake_tree_left_5", "flood_shake_tree_left_5", "flood_angryflood_contig_waterflow0");
	
	level.scr_animtree	[ "angry_water_leading_edge" ]								 = #animtree;
	level.scr_model		[ "angry_water_leading_edge" ]								 = "flood_angryflood_contig0";
	level.scr_anim		[ "angry_water_leading_edge" ][ "flood_angryflood_edge_tracker0" ] = %flood_angryflood_edge_tracker0;

	level.scr_animtree	[ "angry_water_bigwave_0" ]								 = #animtree;
	level.scr_model		[ "angry_water_bigwave_0" ]								 = "flood_angryflood_edge_tracker_0";
	level.scr_anim		[ "angry_water_bigwave_0" ][ "flood_angry_flood_bigwave0" ] = %flood_angry_flood_bigwave0;

	level.scr_animtree	[ "angry_water_bigwave_1" ]								 = #animtree;
	level.scr_model		[ "angry_water_bigwave_1" ]								 = "flood_angryflood_big_wave_1";
	level.scr_anim		[ "angry_water_bigwave_1" ][ "flood_angry_flood_bigwave1" ] = %flood_angry_flood_bigwave1;

	level.scr_animtree	[ "alley_water_near_trackers" ]								 = #animtree;
	level.scr_model		[ "alley_water_near_trackers" ]								 = "flood_alley_flood_near_trackers";
	level.scr_anim		[ "alley_water_near_trackers" ][ "flood_alley_flood_near_trackers_anim" ] = %flood_alley_flood_near_trackers_anim;

	level.scr_animtree	[ "alley_water_far_trackers" ]								 = #animtree;
	level.scr_model		[ "alley_water_far_trackers" ]								 = "flood_alley_flood_far_trackers";
	level.scr_anim		[ "alley_water_far_trackers" ][ "flood_alley_flood_far_trackers_anim" ] = %flood_alley_flood_far_trackers_anim;

	level.scr_animtree	[ "alley_water_far_water" ]								 = #animtree;
	level.scr_model		[ "alley_water_far_water" ]								 = "flood_alley_flood_far_water";
	level.scr_anim		[ "alley_water_far_water" ][ "flood_alley_flood_far_water_anim" ] = %flood_alley_flood_far_water_anim;

	level.scr_animtree	[ "alley_water_near_water" ]								 = #animtree;
	level.scr_model		[ "alley_water_near_water" ]								 = "flood_alley_flood_near_water";
	level.scr_anim		[ "alley_water_near_water" ][ "flood_alley_flood_near_water_anim" ] = %flood_alley_flood_near_water_anim;

	level.scr_animtree	[ "mall_rooftop_debris" ]								 = #animtree;
	level.scr_model		[ "mall_rooftop_debris" ]								 = "flood_mall_rooftop_wh_debri";
	level.scr_anim		[ "mall_rooftop_debris" ][ "flood_mall_rooftop_wh_debri0_anim" ] = %flood_mall_rooftop_wh_debri0_anim;
	
	angry_water_obj = getent("angry_flood_water_model", "targetname");
	angry_water_obj hide();
	alley_water_obj = getent("alley_flood_water_model", "targetname");
	alley_water_obj hide();
	big_wave_water_obj = getent("angry_flood_big_wave_water_model", "targetname");
	big_wave_water_obj hide();
}

fx_set_alpha_threshold()
{
	if( is_gen4() )
       {
         //Setting the point where a faded out particle stops being drawn and thereby freeing up fillrate.
          setsaveddvar("fx_alphathreshold",2);
        }
        else
        {
           setsaveddvar("fx_alphathreshold",9);
        }
}

freon_leak_fx_turn_off_damage()
{
	level.pipesDamage = false;
}
/*
fx_hide_mr_clip_effects()
{
	 mr_clip_effects = GetEnt( "mr_clip_effects", "targetname" );
	 mr_clip_effects hide();
	 mr_clip_effects NotSolid();
}

fx_show_mr_clip_effects()
{
	 mr_clip_effects = GetEnt( "mr_clip_effects", "targetname" );
	 mr_clip_effects show();
	 mr_clip_effects solid();
}
*/
//lgt_flag_init()
//{
//	flag_init ( "mall_lights_off_trigger" );
//	flag_init ( "mall_lights_adjust_trigger" );
//}
	

//lgt_mall_lights_off()
//{
//	flag_wait ( "mall_lights_off_trigger" );
//	lightoff = GetEntArray( "mall_lights_off", "targetname" );
//	foreach (ent in lightoff)

//		ent setLightIntensity( 0 );
		
//		VisionSetNaked("flood_warehouse_lightson", 0);
// 		level.cw_vision_above = "flood_warehouse_lightson";
 		
//}
	
//	lgt_mall_lights_adjust()
//{
//	flag_wait ( "mall_lights_adjust_trigger" );
		
//	VisionSetNaked("flood_warehouse", 4);
//	level.cw_vision_above = "flood_warehouse";
//}

attach_fx_anim_model_street_flood(root_model, xmodel_name, tag_name, death_timer)
{
	pos = root_model GetTagOrigin(tag_name);
	my_angles = (root_model GetTagAngles(tag_name)) + (RandomInt(360), RandomInt(360), RandomInt(360));
	new_model = Spawn("script_model", pos );
	new_model.angles = my_angles;
	// new_model.origin += (0,-120,50);
	// new_model.origin = pos;
	new_model SetModel( xmodel_name );
	new_model LinkTo( root_model, tag_name );
	new_model DelayCall(death_timer, ::Delete);
}

attach_fx_anim_model_mall_debris(root_model, xmodel_name, tag_name, death_timer)
{
	pos = root_model GetTagOrigin(tag_name);
	my_angles = root_model GetTagAngles(tag_name);
	new_model = Spawn("script_model", pos );
	new_model.angles = my_angles;
	new_model.origin += (0,0,0);
	// new_model.origin = pos;
	new_model SetModel( xmodel_name );
	new_model LinkTo( root_model, tag_name );
	new_model DelayCall(death_timer, ::Delete);
}


attach_fx_anim_model_alley_flood(root_model, xmodel_name, tag_name, death_timer)
{
	pos = root_model GetTagOrigin(tag_name);
	my_angles = (root_model GetTagAngles(tag_name)) + (RandomInt(360), RandomInt(360), RandomInt(360));
	new_model = Spawn("script_model", pos );
	new_model.angles = my_angles;
	new_model.origin += (-20,0,20);
	// new_model.origin = pos;
	new_model SetModel( xmodel_name );
	new_model LinkTo( root_model, tag_name );
	new_model DelayCall(death_timer, ::Delete);
}

alley_end_of_alley_fx()
{
	flag_wait("alley_move_toend");
	
	Exploder("flood_alley_paper");
	wait 0.50;
	Exploder("flood_alley_paper");
	wait 0.25;
	Exploder("alley_splashes");

	flag_wait("player_doing_warehouse_mantle");
	delete_exploder("alley_splashes");
	delete_exploder("flood_alley_paper");
	delete_exploder("flood_splash_alley_reverse");
	delete_exploder("flood_splash_alley_front");
}

alley_flood_water()
{

/*
	level.scr_animtree	[ "alley_water_near_trackers" ]								 = #animtree;
	level.scr_model		[ "alley_water_near_trackers" ]								 = "flood_alley_flood_near_trackers";
	level.scr_anim		[ "alley_water_near_trackers" ][ "flood_alley_flood_near_trackers_anim" ] = %flood_alley_flood_near_trackers_anim;

	level.scr_animtree	[ "alley_water_far_trackers" ]								 = #animtree;
	level.scr_model		[ "alley_water_far_trackers" ]								 = "flood_alley_flood_far_trackers";
	level.scr_anim		[ "alley_water_far_trackers" ][ "flood_alley_flood_far_trackers_anim" ] = %flood_alley_flood_far_trackers_anim;

	level.scr_animtree	[ "alley_water_far_water" ]								 = #animtree;
	level.scr_model		[ "alley_water_far_water" ]								 = "flood_alley_flood_far_water";
	level.scr_anim		[ "alley_water_far_water" ][ "flood_alley_flood_far_water_anim" ] = %flood_alley_flood_far_water_anim;

	level.scr_animtree	[ "alley_water_near_water" ]								 = #animtree;
	level.scr_model		[ "alley_water_near_water" ]								 = "flood_alley_flood_near_water";
	level.scr_anim		[ "alley_water_near_water" ][ "flood_alley_flood_near_water_anim" ] = %flood_alley_flood_near_water_anim;

 */
	//SetSavedDvar( "sm_sunSampleSizeNear", 0.250 );

	node = getstruct("alley_flood_script", "script_noteworthy");
	node.angles = (0,0,0);
	
	alley_near_water_tracker = Spawn("script_model", node.origin );
	alley_near_water_tracker hide();
	alley_near_water_tracker SetModel( "flood_alley_flood_near_trackers" );
	alley_near_water_tracker.animname = "alley_water_near_trackers";
	alley_near_water_tracker assign_animtree();

	alley_far_water_tracker = Spawn("script_model", node.origin );
	alley_far_water_tracker hide();
	alley_far_water_tracker SetModel( "flood_alley_flood_far_trackers" );
	alley_far_water_tracker.animname = "alley_water_far_trackers";
	alley_far_water_tracker assign_animtree();

	alley_far_water = Spawn("script_model", node.origin );
	alley_far_water hide();
	alley_far_water SetModel( "flood_alley_flood_far_water" );
	alley_far_water.animname = "alley_water_far_water";
	alley_far_water assign_animtree();

	alley_near_water = Spawn("script_model", node.origin );
	alley_near_water hide();
	alley_near_water SetModel( "flood_alley_flood_near_water" );
	alley_near_water.animname = "alley_water_near_water";
	alley_near_water assign_animtree();

	guys_near = [];
	guys_near["alley_water_near_trackers"] = alley_near_water_tracker;

	guys_far = [];
	guys_far["alley_water_far_trackers"] = alley_far_water_tracker;

	guys_far_water = [];
	guys_far_water["alley_water_far_water"] = alley_far_water;

	guys_near_water = [];
	guys_near_water["alley_water_near_water"] = alley_near_water;


	//alley_near_water_tracker show();
	//alley_far_water_tracker show();
	//alley_far_water show();
	//alley_near_water show();

	Exploder("flood_splash_alley_reverse");
	
	node thread anim_single(guys_near, "flood_alley_flood_near_trackers_anim");
	node thread anim_single(guys_far, "flood_alley_flood_far_trackers_anim");
	wait 0.45; // delay start of the water mesh so that  we get more particles in front of it
	//node thread anim_single(guys_far_water, "flood_alley_flood_far_water_anim");
	node thread anim_single(guys_near_water, "flood_alley_flood_near_water_anim");
	
	// play a bunch of effects on the trackers	
	alley_far_water_tracker thread alley_flood_far_vfx_attachments();
	alley_near_water_tracker thread alley_flood_near_vfx_attachments();
	thread alley_froth_vfx(alley_near_water_tracker);
	wait 1;
	Exploder("flood_splash_alley_front");
	
	thread alley_fill_shallow( "alley_fill_shallow_end", "alley_rising_water_end", ( 500, -4104, -58 ), 6, "flood_water_alley_fill_shallow" );
	
	// Cleanup for TFFs ( do not remove ) tagDK
	flag_wait( "player_at_stairs_stop_nag" );
	
	alley_near_water_tracker delete();
	alley_far_water_tracker delete();
	alley_far_water delete();
	alley_near_water delete();
}

alley_fill_shallow( struct_tname, mover_tname, pos, time, fx )
{
	foreach( ally in level.allies )
	{
		if( !IsDefined( ally.is_running_alley_stuff ) )
		{
			ally.is_running_alley_stuff = true;
			ally thread maps\flood_coverwater::entity_fx_and_anims_think( "stop_alley_wakes", ( 0, 0, 0 ), false );
		}
	}
	
	ent = GetEnt( mover_tname, "targetname" );
	ent MoveTo( pos, time );
//	ent Hide();
	
	fill_shallow_node = getstruct( struct_tname, "targetname" );
	fill_shallow = Spawn( "script_model", fill_shallow_node.origin );
	fill_shallow SetModel( "tag_origin" );
	fill_shallow.angles = fill_shallow_node.angles;

	PlayFXOnTag( level._effect[ fx ], fill_shallow, "tag_origin" );
	
	flag_wait( "player_at_stairs_stop_nag" );
	
	KillFXOnTag( level._effect[ fx ], fill_shallow, "tag_origin" );
	fill_shallow Delete();
}

alley_froth_vfx(alley_near_water_tracker)
{
	wait 5;
	
	level.froth_vfx = [];
	
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_34");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_33");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_32");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_21");
	waitframe();
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_18");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_16");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_10");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_8");
	waitframe();
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_19");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_43");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_46");
	level.froth_vfx[level.froth_vfx.size] = PlayFXOnTagSpecial(level._effect["flood_alley_splash_front_rolling"], alley_near_water_tracker, "j_near_48");
	
	wait 20;
	
	foreach (vfx in level.froth_vfx)
	{
		StopFXOnTag(vfx[1],vfx[0],"tag_origin");
		vfx[0] Delete();
	}
}

alley_flood_far_vfx_attachments()
{
	//road_barrier_post
	//flood_crate_plastic_single02
	//com_pallet_2
	//com_coffee_machine_destroyed

	debris_list = ["flood_crate_plastic_single02", "com_pallet_2", "com_pallet_2", "com_trafficcone02"];
	level.alley_far = [];
	
	wait 1.5;
	cnt = 0;
	for (i=0; i<52; i+=3)
	{
		tag_name = ("j_far_" + i);
		level.alley_far[i] = PlayFXOnTagSpecial(level._effect["flood_splash_small_lp"], self, tag_name);
		// PlayFXOnTag(level._effect["flood_splash_small_far_lp"], self, tag_name);
		if (i>0)
		{
			
			if (RandomFloat(1.0) > 0.5)
			{
				tag_name = ("j_far_" + (i-1));
				
				if (RandomFloat(1.0) > 0.4)
					attach_fx_anim_model_alley_flood(self, debris_list[RandomInt(debris_list.size)], tag_name, 12.0);
			}
		}
		
		cnt += 1;
		if (cnt == 3)
		{
			waitframe();
			cnt = 0;
		}
	}
	wait 6.67;

	cnt = 0;
	for (i=0; i<52; i+=3)
	{
		tag_name = ("j_far_" + i);
		//StopFXOnTag(level._effect["flood_splash_small_lp"], self, tag_name);
		StopFXOnTag(level.alley_far[i][1],level.alley_far[i][0],"tag_origin");
		level.alley_far[i][0] Delete();
		// StopFXOnTag(level._effect["flood_splash_small_far_lp"], self, tag_name);
		
		cnt += 1;
		if (cnt == 3)
		{
			waitframe();
			cnt = 0;
		}
	}
}
	
alley_flood_near_vfx_attachments()
{
	debris_list = ["intro_wood_floorboard_piece02", "intro_wood_floorboard_piece03", "intro_wood_floorboard_piece01", "cardboard_box3", "road_barrier_post", "com_trafficcone01","com_trafficcone01", "com_trafficcone02", "flood_crate_plastic_single02"];
	level.alley_near = [];

	wait 1.5;
	cnt = 0;
	for (i=0; i<75; i+=2)
	{
		tag_name = ("j_near_" + i);
		level.alley_near[i] = PlayFXOnTagSpecial(level._effect["flood_splash_small_lp"], self, tag_name);
		/*
		if (i>0)
		{
			if (RandomFloat(1.0) > 0.3)
			{
				tag_name = ("j_near_" + (i-1));
				if (RandomFloat(1.0) > 0.5)
					attach_fx_anim_model_alley_flood(self, debris_list[RandomInt(debris_list.size)], tag_name, 12.0);
			}
		}
*/
		cnt += 1;
		if (cnt == 3)
		{
			waitframe();
			cnt = 0;
		}
	}

	wait 16;
	cnt = 0;
	for (i=0; i<75; i+=2)
	{
		tag_name = ("j_near_" + i);
		//StopFXOnTag(level._effect["flood_splash_small_lp"], self, tag_name);
		StopFXOnTag(level.alley_near[i][1],level.alley_near[i][0],"tag_origin");
		level.alley_near[i][0] Delete();
		cnt += 1;
		if (cnt == 3)
		{
			waitframe();
			cnt = 0;
		}
	}
	
}

PlayFXOnTagSpecial (effect_id, ent, tag_name)
{
	smodel_ent = Spawn("script_model", ent.origin);
	smodel_ent setModel("tag_origin");
	smodel_ent.targetname = "DELETEME";
	smodel_ent LinkTo(ent,tag_name,(0,0,0),(0,0,0));
	PlayFXOnTag(effect_id,smodel_ent,"tag_origin");
	return [smodel_ent,effect_id];
}

angry_flood_water()
{
	node = getstruct("angry_flood_script", "script_noteworthy");
	angry_water_obj = getent("angry_flood_water_model", "targetname");
	angry_water_obj.animname = "angry_water";
	angry_water_obj assign_animtree();

	water_lighting_target = Spawn("script_model", (-1677,-3443.8,42.3));
	angry_water_obj RetargetScriptModelLighting(water_lighting_target);

	edge_tracker_model = Spawn("script_model", node.origin );
	edge_tracker_model SetModel( "flood_angryflood_edge_tracker_0" );
	edge_tracker_model.animname = "angry_water_leading_edge";
	edge_tracker_model assign_animtree();
	
	guys = [];
	guys["angry_water"] = angry_water_obj;

	edge_guys = [];
	edge_guys["angry_water_leading_edge"] = edge_tracker_model;
	
	angry_water_obj show();
	edge_tracker_model hide();
	
	if ( level.playAngryFloodVFX )
	{
		thread angry_flood_splash_sequencing_lf();
		thread angry_flood_splash_sequencing_rt();
	}

	thread angry_flood_big_wave_water();

	node anim_first_frame(edge_guys, "flood_angryflood_edge_tracker0");
	
	if( is_gen4() )
	{
		// on nextgen, they're the same because we're using particle lighting
		light_effect = level._effect["flood_street_splash_front_rolling"];
		dark_effect = level._effect["flood_street_splash_front_rolling"];
	}
	else
	{
		light_effect = level._effect["flood_street_splash_front_rolling"];
		dark_effect = level._effect["flood_street_splash_front_rolling_dark"];
	}
	
	rolling_wave_elems = [];
	if ( level.playAngryFloodVFX )
	{
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_0");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_001");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(light_effect, edge_tracker_model, "j_wave_front_002");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_003");
		waitframe();
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_004");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_007");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_008");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(light_effect, edge_tracker_model, "j_wave_front_014");
		waitframe();
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_013");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_012");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_010");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_011");
		waitframe();
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_001");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_009");
		rolling_wave_elems[rolling_wave_elems.size] = PlayFXOnTagSpecial(dark_effect, edge_tracker_model, "j_wave_front_015");
	}
	
	node thread anim_single(edge_guys, "flood_angryflood_edge_tracker0");
	node thread anim_single(guys, "flood_angryflood_contig_waterflow0");
	thread angry_flood_street_mist();
	wait 15;
	
	if (level.playAngryFloodVFX )
	{
		counter = 0;
		for ( i=(rolling_wave_elems.size-1); i>=0; i--)
		{
			StopFXOnTag(rolling_wave_elems[i][1],rolling_wave_elems[i][0],"tag_origin");
			rolling_wave_elems[i][0] Delete();
			
			// we can only stopFXOnTag 4 times in a frame before we have to wait.
			counter ++;
			if (counter == 4)
			{
				counter = 0;
				waitframe();
			}
		}
	}
	edge_tracker_model Delete();
	stop_looping_splashes();
}

angry_flood_street_mist()
{
	wait 2;
	Exploder("flood_dam_event_street_mist_1a");
	wait 1;
	Exploder("flood_dam_event_street_mist_1b");
	wait 1;
	Exploder("flood_dam_event_street_mist_1c");
}

angry_flood_big_wave_water()
{
	node = getstruct("angry_flood_big_wave_script", "script_noteworthy");
	big_wave_water_obj = getent("angry_flood_big_wave_water_model", "targetname");
	big_wave_water_obj.animname = "angry_water_bigwave_0";
	big_wave_water_obj assign_animtree();


	guys = [];
	guys["angry_water_bigwave_0"] = big_wave_water_obj;

	node anim_first_frame(guys, "flood_angry_flood_bigwave0");
	big_wave_water_obj hide();
	thread big_wave_2();
	wait 3.5;

	the_effect = level._effect["flood_dam_event_bigwave_splash_lp"];

	/*
	j_bigwave_35x
	j_bigwave_12
	j_bigwave_01
	j_bigwave_03
	j_bigwave_24
	j_bigwave_22
	j_bigwave_27
	j_bigwave_00x
	j_bigwave_23
	j_bigwave_16
	j_bigwave_10
	j_bigwave_26  
	*/
	
	big_wave_elems = [];
	if (level.playAngryFloodVFX )
	{
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_18");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_00");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_01");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_02");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_03");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_04");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_05");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_06");
		waitframe();
		//PlayFXOnTag(the_effect, big_wave_water_obj, "j_bigwave_07");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_08");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_10");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_11");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_12");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_13");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_14");
		//big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_15");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_16");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_17");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_19");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_21");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_22");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_23");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_24");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_26");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_27");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_28");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_29");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_31");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_35");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_37");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_38");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_39");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_water_obj, "j_bigwave_41");
	}


	if (level.playAngryFloodVFX )
	{
		thread big_wave_addl_effects();
	}
	node thread anim_single(guys, "flood_angry_flood_bigwave0");
	
	wait 6.3;
	
	// now bigwave2 is at it's height ... start killing stuff!
	
	if (level.playAngryFloodVFX)
	{
		counter = 0;
		for ( i=(big_wave_elems.size-1); i>=0; i--)
		{
			StopFXOnTag(big_wave_elems[i][1],big_wave_elems[i][0],"tag_origin");
			big_wave_elems[i][0] Delete();
			
			// we can only stopFXOnTag 4 times in a frame before we have to wait.
			counter ++;
			if (counter == 4)
			{
				counter = 0;
				waitframe();
			}
		}
	}
	big_wave_water_obj Delete();

}

big_wave_2()
{

	wait 8.2;
	node = getstruct("angry_flood_big_wave_script", "script_noteworthy");
	
	big_wave_2_obj = Spawn("script_model", node.origin );
	big_wave_2_obj hide();
	big_wave_2_obj SetModel( "flood_angryflood_big_wave_1" );
	big_wave_2_obj.animname = "angry_water_bigwave_1";
	big_wave_2_obj assign_animtree();

	guys = [];
	guys["angry_water_bigwave_1"] = big_wave_2_obj;

	the_effect = level._effect["flood_dam_event_bigwave_splash_lp"];
	//the_effect = level._effect["flood_dam_event_bigwave_splash_lp"];
	
	node anim_first_frame(guys, "flood_angry_flood_bigwave1");

	//road_barrier_post
	//com_trafficcone01
	//flood_crate_plastic_single02
	//com_wheelbarrow
	//com_pallet_2
	//com_coffee_machine_destroyed

	
	attach_fx_anim_model_street_flood(big_wave_2_obj, "road_barrier_post", "j_bigwave2_18", 4.0);
	attach_fx_anim_model_street_flood(big_wave_2_obj, "flood_crate_plastic_single02", "j_bigwave2_21", 4.0);
	attach_fx_anim_model_street_flood(big_wave_2_obj, "com_pallet_2", "j_bigwave2_01", 4.0);
	attach_fx_anim_model_street_flood(big_wave_2_obj, "com_coffee_machine_destroyed", "j_bigwave2_15", 4.0);
	// attach_fx_anim_model_street_flood(big_wave_2_obj, "com_coffee_machine_destroyed", "j_bigwave2_18", 4.0);
	attach_fx_anim_model_street_flood(big_wave_2_obj, "com_trafficcone02", "j_bigwave2_10", 4.0);
	
	big_wave_elems = [];
	if (level.playAngryFloodVFX)
	{
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_10");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_14");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_19");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_18");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_17");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_01");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_03");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_21");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_12");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_11");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_13");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_09");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_08");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_07");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_06");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_05");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_15");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_02");
		waitframe();
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_16");
		big_wave_elems[big_wave_elems.size] = PlayFXOnTagSpecial(the_effect, big_wave_2_obj, "j_bigwave2_00");
	}

	
	// setup near miss checks on bones at the start of the wave
	near_miss_bones = [];
	near_miss_bones[ 0 ] = "j_bigwave2_16";
	near_miss_bones[ 1 ] = "j_bigwave2_11";
	near_miss_bones[ 2 ] = "j_bigwave2_13";
	near_miss_bones[ 3 ] = "j_bigwave2_03";
	
	foreach( bone in near_miss_bones )
	{
//		near_miss = Spawn( "script_model", big_wave_2_obj GetTagOrigin( bone ) );
//		near_miss SetModel( "trigger_radius_display_256" );
		near_miss = Spawn( "trigger_radius", big_wave_2_obj GetTagOrigin( bone ), 0, 256, 256 );
		near_miss EnableLinkTo();
		near_miss LinkTo( big_wave_2_obj, bone );
		near_miss thread maps\flood_fx::fx_angry_flood_nearmiss( true );
	}
	
	
	node anim_single(guys, "flood_angry_flood_bigwave1");
	// attach more effects

	if (level.playAngryFloodVFX )
	{
		counter = 0;
		for ( i=(big_wave_elems.size-1); i>=0; i--)
		{
			StopFXOnTag(big_wave_elems[i][1],big_wave_elems[i][0],"tag_origin");
			big_wave_elems[i][0] Delete();
			
			// we can only stopFXOnTag 4 times in a frame before we have to wait.
			counter ++;
			if (counter == 4)
			{
				counter = 0;
				waitframe();
			}
		}
	}
	
	big_wave_2_obj Delete();

}

big_wave_addl_effects()
{
	/*
	wait 4.3667;
	Exploder("street_flood_big_wave_splash_0");
	wait 0.2;
	Exploder("street_flood_big_wave_splash_1");
	wait 0.3;
	Exploder("street_flood_big_wave_splash_2");
	wait 0.1;
	Exploder("street_flood_big_wave_splash_3");
	*/
}

angry_flood_splash_sequencing_rt()
{
	Exploder ("flood_street_paper");
	wait 2.5;
	Exploder("angry_flood_lp_scrrt_1");
	wait 1.5;
	Exploder("angry_flood_lp_scrrt_2");
	wait 1.1;
	Exploder("angry_flood_lp_scrrt_3");
	wait 1.5;
	Exploder("angry_flood_lp_scrrt_4a");
	wait 0.1;
	Exploder("angry_flood_lp_scrrt_4b");
	wait 1.3;
	Exploder("angry_flood_lp_scrrt_5");
	wait 2.5;
	Exploder("angry_flood_lp_scrrt_6");
	wait 1.5;
	Exploder("angry_flood_lp_scrrt_7a");
	wait 0.5;
	Exploder("angry_flood_lp_scrrt_7b");
	wait 0.1;
	Exploder("angry_flood_lp_scrrt_8");
	wait 1.5;
	Exploder("angry_flood_lp_scrrt_9");
	wait 0.5;
	Exploder("angry_flood_lp_scrrt_10");
	wait 0.75;
	Exploder("angry_flood_lp_scrrt_11");
}

angry_flood_splash_sequencing_lf()
{
	wait 2.83;
	Exploder("angry_flood_lp_scrlf_1");
	wait 1.5;
	Exploder("angry_flood_lp_scrlf_2");
	wait 1.116;
	Exploder("angry_flood_lp_scrlf_3");
	wait 0.51;
	Exploder("angry_flood_lp_scrlf_4a");
	Exploder("angry_flood_lp_scrlf_4b");
	wait 1.38;
	Exploder("angry_flood_lp_scrlf_5");
	wait 2.03;
	Exploder("angry_flood_lp_scrlf_6");
	wait 1.06;
	Exploder("angry_flood_lp_scrlf_8");
	wait 0.2;
	Exploder("angry_flood_lp_scrlf_7a");
	wait 0.1;
	Exploder("angry_flood_lp_scrlf_7b");
	wait 0.1;
	Exploder("angry_flood_lp_scrlf_7c");
}

stop_looping_splashes()
{
	wait 30.0;
	stop_exploder("angry_flood_lp_scrrt_1");
	stop_exploder("angry_flood_lp_scrrt_2");
	stop_exploder("angry_flood_lp_scrrt_3");
	stop_exploder("angry_flood_lp_scrrt_4a");
	stop_exploder("angry_flood_lp_scrrt_4b");
	stop_exploder("angry_flood_lp_scrrt_5");
	stop_exploder("angry_flood_lp_scrrt_6");
	stop_exploder("angry_flood_lp_scrrt_7a");
	stop_exploder("angry_flood_lp_scrrt_7b");
	stop_exploder("angry_flood_lp_scrrt_8");
	stop_exploder("angry_flood_lp_scrrt_9");
	stop_exploder("angry_flood_lp_scrrt_10");
	stop_exploder("angry_flood_lp_scrrt_11");
	stop_exploder("angry_flood_lp_scrlf_1");
	stop_exploder("angry_flood_lp_scrlf_2");
	stop_exploder("angry_flood_lp_scrlf_3");
	stop_exploder("angry_flood_lp_scrlf_4a");
	stop_exploder("angry_flood_lp_scrlf_4b");
	stop_exploder("angry_flood_lp_scrlf_5");
	stop_exploder("angry_flood_lp_scrlf_6");
	stop_exploder("angry_flood_lp_scrlf_8");
	stop_exploder("angry_flood_lp_scrlf_7a");
	stop_exploder("angry_flood_lp_scrlf_7b");
	stop_exploder("angry_flood_lp_scrlf_7c");
}

fx_mall_rooftop_debris()
{
// mall_rooftop_wh_debri_01	

/*
	level.scr_animtree	[ "mall_rooftop_debris" ]								 = #animtree;
	level.scr_model		[ "mall_rooftop_debris" ]								 = "flood_mall_rooftop_wh_debri";
	level.scr_anim		[ "mall_rooftop_debris" ][ "flood_mall_rooftop_wh_debri0_anim" ] = %flood_mall_rooftop_wh_debri0_anim;
*/

	flag_wait( "breach_door_open" );
//	flag_wait("ally2_breach_ready");

	node = getstruct("mall_rooftop_wh_debri_01", "script_noteworthy");
	node.angles = (0,0,0);
	node.origin += (-5,-5,-32);
	
	flood_mall_rooftop_wh_debri = Spawn("script_model", node.origin );
	flood_mall_rooftop_wh_debri hide();
	flood_mall_rooftop_wh_debri SetModel( "flood_mall_rooftop_wh_debri" );
	flood_mall_rooftop_wh_debri.animname = "mall_rooftop_debris";
	flood_mall_rooftop_wh_debri assign_animtree();

	guys_debris = [];
	guys_debris["mall_rooftop_debris"] = flood_mall_rooftop_wh_debri;

	// flood_mall_rooftop_wh_debri show();
	node thread anim_first_frame(guys_debris, "flood_mall_rooftop_wh_debri0_anim");
	
	// attach Models
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_barrel_green", "j_com_barrel_green_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_folding_chair", "j_com_folding_chair_50_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_pallet_2", "j_com_pallet_2_55_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_plastic_crate_pallet", "j_com_plastic_crate_pallet_57_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashbin01", "j_com_trashbin_56_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "com_trashcan_metal_with_trash", "j_com_trashcan_metal_with_trash_56_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "pb_weaponscase", "j_pb_weaponscase_57_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_green_destroyed", "j_vehicle_coupe_green_destroyed_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_gold_destructible", "j_vehicle_coupe_green_destroyed_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_green_destroyed", "j_vehicle_coupe_green_destroyed_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_gold_destructible", "j_vehicle_coupe_green_destroyed_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_green_destroyed", "j_vehicle_coupe_green_destroyed_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_gold_destructible", "j_vehicle_coupe_green_destroyed_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_green_destroyed", "j_vehicle_coupe_green_destroyed_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_gold_destructible", "j_vehicle_coupe_green_destroyed_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_green_destroyed", "j_vehicle_coupe_green_destroyed_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_gold_destructible", "j_vehicle_coupe_green_destroyed_09", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_coupe_green_destroyed", "j_vehicle_coupe_green_destroyed_10", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_blue", "j_vehicle_van_mica_destroyed_00", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_gray", "j_vehicle_van_mica_destroyed_01", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_blue", "j_vehicle_van_mica_destroyed_02", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_red", "j_vehicle_van_mica_destroyed_03", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_gray", "j_vehicle_van_mica_destroyed_04", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_blue", "j_vehicle_van_mica_destroyed_05", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_red", "j_vehicle_van_mica_destroyed_06", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_blue", "j_vehicle_van_mica_destroyed_07", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_gray", "j_vehicle_van_mica_destroyed_08", 50.0);
	attach_fx_anim_model_mall_debris(flood_mall_rooftop_wh_debri, "vehicle_mini_destructible_red", "j_vehicle_van_mica_destroyed_09", 50.0);

	node thread anim_single(guys_debris, "flood_mall_rooftop_wh_debri0_anim");

	/*
	// play a bunch of effects on the trackers
	alley_far_water_tracker thread alley_flood_far_vfx_attachments();
	alley_near_water_tracker thread alley_flood_near_vfx_attachments();
	*/
}

fx_warehouse_ally_mantle(hips_delay, feet_delay)
{
	water_ent = GetEntArray( "coverwater_warehouse_premantle", "targetname" );

	wait hips_delay;
	water_height = water_ent[0].origin[2];

	knee_pos = self GetTagOrigin("J_Knee_RI");
	knee_pos = (knee_pos[0], knee_pos[1], water_height);
	PlayFX(level._effect["flood_warehouse_ally_mantle"],knee_pos,(0,1,0), (0,0,1));
	
	wait 0.1;
	water_height = water_ent[0].origin[2];
	knee_pos = self GetTagOrigin("J_Knee_LE");
	knee_pos = (knee_pos[0], knee_pos[1], water_height);
	PlayFX(level._effect["flood_warehouse_ally_mantle"],knee_pos,(0,1,0), (0,0,1));

	wait feet_delay;
	water_height = water_ent[0].origin[2];
	ankle_pos = self GetTagOrigin("J_Ankle_RI");
	ankle_pos = (ankle_pos[0], ankle_pos[1], water_height);
	PlayFX(level._effect["flood_warehouse_ally_mantle"],ankle_pos,(0,1,0), (0,0,1));
	
	wait 0.1;
	water_height = water_ent[0].origin[2];
	ankle_pos = self GetTagOrigin("J_Ankle_LE");
	ankle_pos = (ankle_pos[0], ankle_pos[1], water_height);
	PlayFX(level._effect["flood_warehouse_ally_mantle"],ankle_pos,(0,1,0), (0,0,1));
}

fx_warehouse_door_burst()
{
	//IPrintLnBold( "got doorbreak fx" );
	wh_splashes_upper = GetEnt( "wh_splashes_upper", "targetname" );

	exploder( "warehouse_doorbreak" );
	wait 0.3;
	PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_big_door_splash_001" );
	PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_big_door_splash_002" );
	/*
	wait 10;
	
	KillFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_big_door_splash_001" );
	KillFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_big_door_splash_002" );
	//exploder( "wh_thick" );
	*/
}

fx_wh_splashes()
{
	wh_splashes_lower = GetEnt( "wh_splashes_lower", "targetname" );
	wh_splashes_upper = GetEnt( "wh_splashes_upper", "targetname" );
	
	PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg_dark" ), wh_splashes_lower, "tag_fx_big_door_splash_001" );
	PlayFXOnTag( GetFX( "vfx_warehouse_lip_froth_01" ), wh_splashes_lower, "tag_fx_lip_splash_001" );
	PlayFXOnTag( GetFX( "vfx_warehouse_lip_froth_01" ), wh_splashes_lower, "tag_fx_lip_splash_002" );
	waitframe();
	//PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_small_door_splash_002" );
	//PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_big_door_splash_001" );
	//PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_big_door_splash_002" );
	PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_sml" ), wh_splashes_upper, "tag_fx_small_door_splash_004" );
	PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_sml" ), wh_splashes_upper, "tag_fx_small_door_splash_003" );
	/*
	wait 15;
	KillFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg_dark" ), wh_splashes_lower, "tag_fx_big_door_splash_001" );
	KillFXOnTag( GetFX( "vfx_warehouse_lip_froth_01" ), wh_splashes_lower, "tag_fx_lip_splash_001" );
	KillFXOnTag( GetFX( "vfx_warehouse_lip_froth_01" ), wh_splashes_lower, "tag_fx_lip_splash_002" );
	waitframe();
	KillFXOnTag( GetFX( "vfx_warehouse_door_splashes_sml" ), wh_splashes_upper, "tag_fx_small_door_splash_004" );
	KillFXOnTag( GetFX( "vfx_warehouse_door_splashes_sml" ), wh_splashes_upper, "tag_fx_small_door_splash_003" );
	*/
}

fx_warehouse_door_burst_02()
{
	//IPrintLnBold( "got doorbreak fx" );
	wh_splashes_upper = GetEnt( "wh_splashes_upper", "targetname" );

	//exploder( "warehouse_doorbreak" );
	exploder( "wh_thick" );
	PlayFXOnTag( GetFX( "vfx_warehouse_door_splashes_lrg" ), wh_splashes_upper, "tag_fx_small_door_splash_002" );

}

fx_warehouse_amb_fx()
{
	//IPrintLnBold( "got doorbreak fx" );

	exploder( "wh_drips" );
	exploder( "wh_doorsprays" );
	exploder( "wh_randomfan_01" );
	stop_exploder("dam_water_falling");

	//fx_warehouse_double_doors();
	//exploder( "wh_thick" );
}

fx_warehouse_double_doors()
{
	level endon( "ally0_breach_ready" );
	flag_wait ("player_doing_warehouse_mantle");
	
	fx_tracker = level.flood_double_door_center;
	while (1)
	{
		pos0 = fx_tracker.origin + (0, -10, 0);
		pos1 = fx_tracker.origin + (-20, -10, 0);
		pos2 = fx_tracker.origin + (20, -10, 0);
		
		val = RandomInt(3);

		if (val == 0)
		{
			PlayFX(level._effect["flood_warehouse_double_doors_froth"], pos0);
		} else if (val == 1) {
			PlayFX(level._effect["flood_warehouse_double_doors_froth"], pos1);
		} else {
			PlayFX(level._effect["flood_warehouse_double_doors_froth"], pos2);
		}

		wait RandomFloat(0.25);
	}
}

//shut off warehouse debris effects, requires string: script_noteworthy of debris to destroy
destroy_fx_warehouse_floating_debris()// debris_to_kill )
{
	//debris = GetEnt( debris_to_kill, "script_noteworthy" );
	//debris Delete();
	
	warehouse_upper_floating_debris = GetEnt( "warehouse_upper_floating_debris", "script_noteworthy" );
	warehouse_premantle_floating_debris = GetEnt( "coverwater_warehouse_premantle_debris", "script_noteworthy" );
	
	//make sure all boxes disappear so they don't linger on mall rooftop
	//main floating debris tags debri_03
	for ( h = 1; h <= 2; h++ )
	{

    	tag_fx_debri_3 = "tag_fx_debri_3_00" + h;
	
		KillFXOnTag( GetFX( "flood_warehouse_floating_debri_03" ), warehouse_upper_floating_debris, tag_fx_debri_3 );
		waitframe();
	}
	
	//main floating debris tags debri_02
	for ( i = 1; i <= 10; i++ )
	{
		if(i < 10)
		{
	        tag_fx_debri_2 = "tag_fx_debri_2_00" + i;
		}
		else
		{
			tag_fx_debri_2 = "tag_fx_debri_2_0" + i;
		}
		KillFXOnTag( GetFX( "flood_warehouse_floating_debri_02" ), warehouse_upper_floating_debris, tag_fx_debri_2 );
		waitframe();
	}
	
	//main floating debris tags debri_01
	for ( j = 1; j <= 3; j++ )
	{

    	tag_fx_debri_1 = "tag_fx_debri_1_00" + j;
	
		KillFXOnTag( GetFX( "flood_warehouse_floating_debri_01" ), warehouse_upper_floating_debris, tag_fx_debri_1 );
		waitframe();
	}
	
	if( IsDefined(warehouse_upper_floating_debris) && IsDefined(warehouse_premantle_floating_debris) )
	{
		warehouse_upper_floating_debris Delete();
		warehouse_premantle_floating_debris Delete();
	}
}

//shuts off debris falling from lip when player mantles
destroy_lip_debris_fx()
{
	warehouse_premantle_floating_debris = GetEnt( "coverwater_warehouse_premantle_debris", "script_noteworthy" );
	StopFXOnTag( GetFX( "flood_warehouse_lip_cascade_debris" ), warehouse_premantle_floating_debris, "tag_fx_debri_lip" );
}

//starts warehouse debris effects
fx_warehouse_floating_debris()
{	
	warehouse_upper_floating_debris = GetEnt( "warehouse_upper_floating_debris", "script_noteworthy" );
	warehouse_premantle_floating_debris = GetEnt( "coverwater_warehouse_premantle_debris", "script_noteworthy" );
	
	//premantle lip cascading debris tag_fx_debri_lip
	PlayFXOnTag( GetFX( "flood_warehouse_lip_cascade_debris" ), warehouse_premantle_floating_debris, "tag_fx_debri_lip" );
	
	//main floating debris tags debri_03
	for ( h = 1; h <= 2; h++ )
	{

    	tag_fx_debri_3 = "tag_fx_debri_3_00" + h;
	
		PlayFXOnTag( GetFX( "flood_warehouse_floating_debri_03" ), warehouse_upper_floating_debris, tag_fx_debri_3 );
		waitframe();
	}
	
	//main floating debris tags debri_02
	for ( i = 1; i <= 10; i++ )
	{
		if(i < 10)
		{
	        tag_fx_debri_2 = "tag_fx_debri_2_00" + i;
		}
		else
		{
			tag_fx_debri_2 = "tag_fx_debri_2_0" + i;
		}
		PlayFXOnTag( GetFX( "flood_warehouse_floating_debri_02" ), warehouse_upper_floating_debris, tag_fx_debri_2 );
		waitframe();
	}
	
	//main floating debris tags debri_01
	for ( j = 1; j <= 3; j++ )
	{

    	tag_fx_debri_1 = "tag_fx_debri_1_00" + j;
	
		PlayFXOnTag( GetFX( "flood_warehouse_floating_debri_01" ), warehouse_upper_floating_debris, tag_fx_debri_1 );
		waitframe();
	}
	
	//main floating debris tags particlulates_03
	for ( k = 1; k <= 8; k++ )
	{
		tag_fx_particulates_03 = "tag_fx_particulates_02_00" + k;
        
		PlayFXOnTag( GetFX( "flood_particlulates_03" ), warehouse_upper_floating_debris, tag_fx_particulates_03 );
		//PlayFXOnTag( GetFX( "flooded_office_murk" ), warehouse_upper_floating_debris, tag_fx_particulates_03 );
		waitframe();
	}
	
	//main floating debris tags flood_floating_paper_slow
	for ( l = 1; l <= 5; l++ )
	{
		tag_fx_flood_floating_paper_slow = "tag_fx_flood_floating_paper_slow_00" + l;
        
		PlayFXOnTag( GetFX( "flood_floating_paper_slow2" ), warehouse_upper_floating_debris, tag_fx_flood_floating_paper_slow );
		waitframe();
	}
	
	//premantle Floating debris tags debri_01
	for ( m = 1; m <= 3; m++ )
	{
		tag_fx_debri_1_2 = "tag_fx_debri_1_00" + m;
		
		PlayFXOnTag( GetFX( "flood_warehouse_floating_debri_01" ), warehouse_premantle_floating_debris, tag_fx_debri_1_2 );
		if( i != 3 )
		{
			PlayFXOnTag( GetFX( "flood_warehouse_floating_debri_02" ), warehouse_premantle_floating_debris, tag_fx_debri_1_2 );
		}
		else
		{
			PlayFXOnTag( GetFX( "flood_warehouse_floating_debri_03" ), warehouse_premantle_floating_debris, tag_fx_debri_1_2 );
		}
		waitframe();
	}
	self.already_spawned = true;
}

// for interior checkpoint, checks to see if debris already spawned before playing it again
fx_warehouse_floating_debris_int()
{
	if( !IsDefined(self.already_spawned) || ( IsDefined(self.already_spawned) && !self.already_spawned ) )
	{
		thread fx_warehouse_floating_debris();
	}
}

fx_warehouse_splashes()
{	
	water_loadingdocks_lower = GetEnt( "water_loadingdocks_lower_splashes", "script_noteworthy" );
	water_loadingdocks = GetEnt( "water_loadingdocks_splashes", "script_noteworthy" );
	
	//lower water splashes
	for ( i = 0; i < 10; i++ )
	{
		if( i < 10 )
        	tag_splash_dark_large = "tag_splash_dark_large_0" + i;
		else
        	tag_splash_dark_large = "tag_splash_dark_large_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_large_dark_01" ), water_loadingdocks_lower, tag_splash_dark_large );
		wait 0.01;
	}

	for ( i = 0; i < 19; i++ )
	{
		if( i < 10 )
        	tag_splash_dark_medium = "tag_splash_dark_medium_0" + i;
		else
        	tag_splash_dark_medium = "tag_splash_dark_medium_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_medium_dark_01" ), water_loadingdocks_lower, tag_splash_dark_medium );
		wait 0.01;
	}
	for ( i = 0; i < 8; i++ )
	{
		if( i < 10 )
        	tag_splash_dark_small = "tag_splash_dark_small_0" + i;
		else
        	tag_splash_dark_small = "tag_splash_dark_small_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_dark_small_01" ), water_loadingdocks_lower, tag_splash_dark_small );
		wait 0.01;
	}
	
	for ( i = 0; i < 9; i++ )
	{
		if( i < 10 )
        	tag_splash_light = "tag_splash_light_0" + i;
		else
        	tag_splash_light = "tag_splash_light_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_light_01" ), water_loadingdocks_lower, tag_splash_light );
		wait 0.01;
	}
	/*
	for ( i = 0; i < 1; i++ )
	{
		if( i < 10 )
        	tag_splash_light_small = "tag_splash_light_small_0" + i;
		else
        	tag_splash_light_small = "tag_splash_light_small_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_light_small_01" ), water_loadingdocks_lower, tag_splash_light_small );
		wait 0.01;
	}
	*/
	//upper water splashes
	/*
	for ( i = 0; i < 16; i++ )
	{
		if( i < 10 )
        	tag_splash_dark_ledge = "tag_splash_dark_ledge_0" + i;
		else
        	tag_splash_dark_ledge = "tag_splash_dark_ledge_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_medium_dark_01" ), water_loadingdocks, tag_splash_dark_ledge );
		wait 0.01;
	}
*/
	for ( i = 0; i < 19; i++ )
	{
		if( i < 10 )
        	tag_splash_dark_small_ledge = "tag_splash_dark_small_ledge_0" + i;
		else
        	tag_splash_dark_small_ledge = "tag_splash_dark_small_ledge_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_dark_small_01" ), water_loadingdocks, tag_splash_dark_small_ledge );
		wait 0.01;
	}
/*
	for ( i = 0; i < 1; i++ )
	{
		if( i < 10 )
        	tag_splash_light_ledge = "tag_splash_light_ledge_0" + i;
		else
        	tag_splash_light_ledge = "tag_splash_light_ledge_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_light_01" ), water_loadingdocks, tag_splash_light_ledge );
		wait 0.01;
	}

	for ( i = 0; i < 10; i++ )
	{
		if( i < 10 )
        	tag_splash_light_small_ledge = "tag_splash_light_small_ledge_0" + i;
		else
        	tag_splash_light_small_ledge = "tag_splash_light_small_ledge_" + i;
		
		PlayFXOnTag( GetFX( "flood_water_splash_light_small_01" ), water_loadingdocks, tag_splash_light_small_ledge );
		wait 0.01;
	}
*/
}

fx_warehouse_door_breach()
{
	exploder("wh_doorbreach");
}

/*
fx_swept_body_bubbles( hands_rig, start_rig )
{
	PlayFXOnTag( getfx( "flood_hand_bubbles" ), hands_rig, "j_wrist_ri" );
	PlayFXOnTag( getfx( "flood_hand_bubbles" ), hands_rig, "j_wrist_le" );
	//PlayFXOnTag( getfx( "flood_body_ambient_bubbles" ), hands_rig, "tag_origin" );
	//PlayFXOnTag( getfx( "flood_water_swept_bubbles_01" ), hands_rig, "tag_origin" );
	//PlayFXOnTag( getfx( "debri_bubbles_emit" ), hands_rig, "tag_flash" );
	//IPrintLnBold("kill bubbles");
			flag_wait( "cw_player_abovewater" );

	StopFXOnTag( getfx( "flood_hand_bubbles" ), start_rig, "j_wrist_ri" );
	StopFXOnTag( getfx( "flood_hand_bubbles" ), start_rig, "j_wrist_le" );
	//StopFXOnTag( getfx( "flood_body_ambient_bubbles" ), start_rig, "tag_torso" );
	//StopFXOnTag( getfx( "flood_water_swept_bubbles_01" ), start_rig, "j_wrist_le" );

}
*/

fx_swept_start_bubble_mass()
{
	//PlayFXOnTag( getfx( "shpg_scuba_bubbles_plr_front_dive" ), level.cw_player_view_fx_source, "tag_origin" );

	/*
	while( 1)
	{
		flag_wait( "cw_player_underwater" );
		IPrintLn( "above_water_swept" );
		
		PlayFXOnTag( getfx( "flood_hand_bubbles" ), hands_rig, "j_wrist_ri" );
		PlayFXOnTag( getfx( "flood_hand_bubbles" ), hands_rig, "j_wrist_le" );
		
		flag_wait( "cw_player_abovewater" );
		IPrintLn( "below_water_swept" );
	
		KillFXOnTag( getfx( "flood_hand_bubbles" ), hands_rig, "j_wrist_ri" );
		KillFXOnTag( getfx( "flood_hand_bubbles" ), hands_rig, "j_wrist_le" );

		waitframe();
	}
	*/
}


fx_warehouse_stop_cover_water()
{
	wait 4;
	stop_exploder("wh_coverplashes");
}

fx_rooftop_crush_dust()
{
	wait 3;
	//IPrintLnBold( "got crush dust" );

	PlayFXOnTag( GetFX( "mall_rooftop_crush_dust_emit" ), level.mallroof_impact, "j_bone01" );
}

fx_rooftop_collapse_fx()
{
	wait 2;
	//IPrintLn( "start" );

	exploder("roofcollapse_medium_dust_01");
	wait 1;
	//IPrintLn( "roofcollapse_bigsplash_01" );
	exploder("mr_updust");

	exploder("roofcollapse_bigsplash_01");
	wait 1;
	//IPrintLn( "mr_bigdust" );

	exploder("mr_bigdust");
	wait 1;
	exploder("mr_bigsplashes");
	exploder("mr_debri_explosions");
	
}
	
fx_dam_missile_dust()
{
	exploder("m880_dust_linger");
	exploder("m880_dust");
	wait 2;
	exploder("m880_fallingdust");
	exploder("m880_hand_dust");
	//wait 1;
	exploder("m880_swirlsmoke");
}

fx_dam_explosion()
{
	dam_water_valley = GetEnt( "dam_water_valley", "targetname" );
	wait 5.3;
	exploder("dam_hit_explosion");
	stop_exploder( "dam_pre_waterfall" );

	wait 3;
	exploder("dam_water_burst");
	wait 2.0;
	exploder("dam_water_tip_splash");
	exploder("dam_water_splash_01");
	wait 0.9;
	dam_waterfall = GetEnt( "dam_waterfall", "targetname" );
	dam_waterfall show();
	wait 1.5;
	dam_water_valley show();
	wait 0.5;
	exploder("dam_water_falling");
	exploder("dam_birds_01");

}

fx_dam_waterfall_hide()
{
	dam_waterfall = GetEnt( "dam_waterfall", "targetname" );
	dam_water_valley = GetEnt( "dam_water_valley", "targetname" );
	dam_waterfall Hide();
	dam_water_valley hide();
}

fx_dam_waterfall_show()
{
	dam_waterfall = GetEnt( "dam_waterfall", "targetname" );
	dam_water_valley = GetEnt( "dam_water_valley", "targetname" );
	dam_waterfall show();
	dam_water_valley show();
}

rooftop_01_misc_fx()
{
	flag_init( "rooftop_01_misc_fx" );

	flag_wait( "rooftop_01_misc_fx" );
	//tIPrintLnBold( "got rooftop misc fx" );
	exploder( "rooftop1_misc_fx" );
	thread maps\flood_audio::sfx_stairwell_wind();
	wait 3;
	exploder( "rooftop_stairwell_dust" );
}

trigger_debris_bridge_water()
{
	flag_init( "trigger_debris_bridge_water" );

	flag_wait( "trigger_debris_bridge_water" );
	//IPrintLnBold( "got debris water trigger" );
	debri_bridge_water = GetEnt( "debri_bridge_water", "targetname" );
	swept_water_swim = GetEnt( "swept_water_swim", "targetname" );
	debri_bridge_water show();
	swept_water_swim hide();
}

exit_stealth_misc_fx()
{
	//flag_wait( "stealth_kill_02_done" );
	fx_dam_waterfall_show();
	exploder( "dam_water_falling" );
}


fx_dam_missile_afterburn_01()
{
	//wait 0.5;
	PlayFXOnTag( GetFX( "flood_m880_afterburn_ignite" ), level.dam_break_m880, "rocket_cover_rear_01_jnt" );
	
	VisionSetNaked("flood_dam", 2);
	
//	maps\_art::dof_enable_script( 0, 745, 4, 65000, 88000, 0.5, 0.6 );

}

fx_dam_missile_launch_01()
{
	stop_exploder("m880_redlight");

	exploder("m880_glowsmoke_1st_new");
	wait 0.1;
	//IPrintLnBold( "m880_glowsmoke_tip" );
	exploder("m880_glowsmoke_tip_new");
	PlayFXOnTag( GetFX( "flood_m880_afterburn_ignite" ), level.dam_break_m880, "rocket_cover_rear_01_jnt" );

	wait 0.48;
	//IPrintLnBold( "m880_glowsmoke_tip_fk" );
	exploder("m880_glowsmoke_new");
	wait 0.1;
	//IPrintLnBold( "m880_glowsmoke_tip_fk" );
	exploder("m880_glowsmoke_tip_new");

	wait 0.13;
	//IPrintLnBold( "m880_glowsmoke_02" );
	exploder("m880_glowsmoke_02");
	wait 0.1;
	//IPrintLnBold( "m880_glowsmoke_02_tip" );
	exploder("m880_glowsmoke_02_tip");
	stop_exploder("church_amb_fx");
	//alley_godray = GetEnt( "alley_godray", "targetname" );
	//alley_godray hide();


	wait 0.9;
	//IPrintLnBold( "m880_glowsmoke_03" );
	exploder("m880_glowsmoke");
	wait 0.1;
	//IPrintLnBold( "m880_glowsmoke_tip_03" );
	exploder("m880_glowsmoke_tip");
	
	wait 0.35;
	//IPrintLnBold( "m880_glowsmoke_04" );
	exploder("m880_glowsmoke_02");
	wait 0.1;
	//IPrintLnBold( "m880_glowsmoke_04_tip" );
	exploder("m880_glowsmoke_02_tip");

	//wait 0.3;

/*
	rear_effect = level._effect[ "flood_m880_exhaust" ];
	front_effect = level._effect[ "flood_m880_exhaust" ];
	
	PlayFXOnTag(rear_effect, level.dam_break_m880, "rocket_cover_rear_01_jnt");
	wait 0.1;
	PlayFXOnTag(front_effect, level.dam_break_m880, "rocket_cover_front_01_jnt");x
	*/
}

fx_dam_missile_launch_02()
{
	/*
	exploder("m880_glowsmoke");
	wait 0.1;
	exploder("m880_glowsmoke_02");
*/
	wait 0.5;
	
	//IPrintLnBold( "missile_02" );

	rear_effect = level._effect[ "flood_m880_afterburn_ignite" ];
	//front_effect = level._effect[ "flood_m880_exhaust" ];
	
	PlayFXOnTag(rear_effect, level.dam_break_m880, "rocket_cover_rear_02_jnt");
	//wait 0.1;
	//PlayFXOnTag(front_effect, level.dam_break_m880, "rocket_cover_front_02_jnt");
}

fx_dam_missile_launch_03()
{
	/*
	exploder("m880_glowsmoke");
	wait 0.1;
	exploder("m880_glowsmoke_02");
*/
	wait 0.5;
	//IPrintLnBold( "missile_03" );

	rear_effect = level._effect[ "flood_m880_afterburn_ignite" ];
	//front_effect = level._effect[ "flood_m880_exhaust" ];
	
	PlayFXOnTag(rear_effect, level.dam_break_m880, "rocket_cover_rear_03_jnt");
	//wait 0.1;
	//PlayFXOnTag(front_effect, level.dam_break_m880, "rocket_cover_front_03_jnt");
}

fx_dam_missile_launch_04()
{
	/*
	exploder("m880_glowsmoke");
	wait 0.1;
	exploder("m880_glowsmoke_02");
*/
	wait 0.5;
	
	//IPrintLnBold( "missile_04" );

	rear_effect = level._effect[ "flood_m880_afterburn_ignite" ];
	//front_effect = level._effect[ "flood_m880_exhaust" ];
	
	PlayFXOnTag(rear_effect, level.dam_break_m880, "rocket_cover_rear_04_jnt");
	//wait 0.1;
	//PlayFXOnTag(front_effect, level.dam_break_m880, "rocket_cover_front_04_jnt");
}

dam_street_flood_church_hits()
{
	wait 2.5;
	Exploder("street_flood_big_splash_church_1");
	wait 0.33;
	Exploder("street_flood_big_splash_church_1a");
	wait 0.3;
	Exploder("street_flood_big_splash_church_1b");
	wait 0.3;
	Exploder("street_flood_big_splash_church_1c");
	wait 0.3;
	Exploder("street_flood_big_splash_church_2");
	Exploder("street_flood_big_splash_church_top_fall_1");
	// church tower falling over

}


dam_street_flood_big_splashes_fx()
{
	/*
	wait 1.7;
	Exploder("street_flood_big_splash_1");
	wait 2.0;
	Exploder("street_flood_big_splash_2");
	wait 3.0;
	Exploder("street_flood_big_splash_3");
	wait 2.5;
	Exploder("street_flood_big_splash_4");*/
}

flood_onscreen_timer()
{
	val = 0.0;
	while (true)
	{
		IPrintLn(val);
		val += 0.05;
		wait 0.05;
	}
}

dam_street_flood_fx()
{
	thread dam_street_flood_big_splashes_fx();
	wait 1.75;
	Exploder("flood_dam_event_street_flood_mist_1");
	wait 0.5;
	Exploder("flood_dam_event_street_flood_mist_2");
	wait 0.5;
	Exploder("flood_dam_event_street_flood_mist_3");
}

dam_flood_fx()
{
	// thread flood_onscreen_timer();
	wait 11.5;
	//Exploder("dam_flood_base_mist");
	thread dam_street_flood_fx();
}
/*
alley_water_hide()
{
	alley_water = GetEnt( "water_alley", "targetname" );
	if ( IsDefined(alley_water) )
	{
		alley_water Hide();
		alley_water NotSolid();
		alley_water MoveZ( -50, 0.01, 0, 0 );
	//	alley_water moveto( (144, -1760, -59), 0.01, 0, 0 );
	}
}

alley_water_show_and_move()
{

	alley_water = GetEnt( "water_alley", "targetname" );
	if ( IsDefined(alley_water) )
	{
		alley_water show();
		alley_water Solid();
		alley_water MoveZ( 50, 7.5, 0, 0 );
		wait 7.5;
//		IPrintLn( "water done rising: " + GetTime() );
	//	alley_water moveto( (144, -1760, -10), 4, 0, 0 );
	}
}
*/
alley_flood_fx()
{
	//wait 0.0;
	Exploder("flood_dam_event_alley_mist_1");
	wait 0.25;
	Exploder("flood_dam_event_alley_mist_2");

	// clean up on the street
	stop_exploder("flood_dam_event_street_flood_mist_1");
	stop_exploder("flood_dam_event_street_flood_mist_2");
	stop_exploder("flood_dam_event_street_flood_mist_3");
	stop_exploder("flood_dam_event_street_mist_1a");
	stop_exploder("flood_dam_event_street_mist_1b");
	stop_exploder("flood_dam_event_street_mist_1c");
}

fx_checkpoint_states()
{
	// Per section ambient FX states
	waittillframeend;// let the actual start functions run before this one
	start = level.start_point;
	
	if ( is_default_start() )
	{
		// CF - Removing specific lines but leaving the thread call
		// these infil_explosions were only being played if not greenlight
		// temp check for greenlight
		//if( level.start_point != "dam" )
		{
			thread infil_explosions();
			exploder( "flak" );
			stop_exploder( "ending_smk_plume" );

			return;
		}
	}
	if ( start == "streets" )
	{
		thread infil_explosions();
		exploder( "flak" );
		stop_exploder( "ending_smk_plume" );
		stop_exploder( "dam_pre_waterfall" );
		stop_exploder( "mr_sunflare" );
		stop_exploder("swept_sunflare");

		return;
	}
	if ( start == "streets_to_dam" )
	{
		thread infil_explosions();
		exploder( "flak" );
		stop_exploder( "ending_smk_plume" );
		//exploder( "alley_flares" );
		exploder( "dam_pre_waterfall" );
		stop_exploder( "mr_sunflare" );
		stop_exploder("swept_sunflare");

		return;
	}
	if ( start == "streets_to_dam_2" )
	{
		thread infil_explosions();
		exploder( "flak" );
		exploder( "m880_crash_fx" );
		//exploder( "alley_flares" );
		stop_exploder( "ending_smk_plume" );
		exploder( "dam_pre_waterfall" );
		stop_exploder( "mr_sunflare" );
		stop_exploder("swept_sunflare");

		return;
	}
	if ( start == "dam" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "ending_smk_plume" );
		exploder( "intro_amb_fx" );
		stop_exploder( "mr_sunflare" );
		//exploder( "alley_flares" );
		stop_exploder("swept_sunflare");
		exploder( "dam_pre_waterfall" );
		return;
	}
	if ( start == "flooding_ext" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "ending_smk_plume" );
		stop_exploder( "mr_sunflare" );
		stop_exploder("swept_sunflare");
		//exploder( "alley_flares" );
		stop_exploder( "dam_pre_waterfall" );
		return;
	}
	if ( start == "flooding_int" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "dam_pre_waterfall" );
		//stop_exploder( "alley_flares" );
		stop_exploder( "ending_smk_plume" );
		stop_exploder( "mr_sunflare" );
		stop_exploder("swept_sunflare");
		set_vision_set("flood_warehouse", 0);
		
		thread fx_retarget_warehouse_waters_lighting();

		return;
	}
	if ( start == "mall" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "dam_pre_waterfall" );
		//stop_exploder( "alley_flares" );
		stop_exploder( "ending_smk_plume" );
		exploder( "mr_sunflare" );
		stop_exploder("swept_sunflare");

		set_vision_set("flood_stairs", 0);
		//thread fx_show_mr_clip_effects();
//		fog_set_changes( "flood_stairs", 0 );
//	 	level.cw_vision_above = "flood_stairs";
//	 	level.cw_fog_above = "flood_stairs";
		return;
	}
	if ( start == "swept" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "dam_pre_waterfall" );
		//stop_exploder( "alley_flares" );
		stop_exploder( "ending_smk_plume" );
		stop_exploder("huge_plume");
		exploder("huge_plume_swept");
		exploder("swept_sunflare");
		stop_exploder( "mr_sunflare" );

		set_vision_set("flood_two", 0);
//		fog_set_changes( "flood_two", 0 );
//	 	level.cw_vision_above = "flood_two";
//	 	level.cw_fog_above = "flood_two";
		return;
	}
	if ( start == "roof_stealth" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "dam_pre_waterfall" );
		stop_exploder( "ending_smk_plume" );
		stop_exploder( "mr_sunflare" );
		//stop_exploder( "alley_flares" );
		stop_exploder("huge_plume");
		set_vision_set("flood_stealth", 0);
//		fog_set_changes( "flood_stealth", 0 );
//	 	level.cw_vision_above = "flood_stealth";
//	 	level.cw_fog_above = "flood_stealth";

		return;
	}
	if ( start == "skybridge" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "dam_pre_waterfall" );
		stop_exploder( "intro_amb_fx" );
		//stop_exploder( "alley_flares" );
		stop_exploder( "ending_smk_plume" );
		stop_exploder("huge_plume");
		stop_exploder( "mr_sunflare" );
		exit_stealth_misc_fx();
		set_vision_set("flood_two", 0);
		return;
	}
	if ( start == "rooftops" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "dam_pre_waterfall" );
		stop_exploder( "intro_amb_fx" );
		//stop_exploder( "alley_flares" );
		exploder( "ending_smk_plume" );
		stop_exploder("huge_plume");
		stop_exploder( "mr_sunflare" );
		exit_stealth_misc_fx();
		thread maps\flood_anim::building_01_debri_anim_spawn();

		return;
	}
	if ( start == "rooftop_water" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "dam_pre_waterfall" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "mr_sunflare" );
		//stop_exploder( "alley_flares" );
		exploder( "ending_smk_plume" );
		stop_exploder("huge_plume");
		exit_stealth_misc_fx();
		return;
	}
	if ( start == "debrisbridge" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "dam_pre_waterfall" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "mr_sunflare" );
		//stop_exploder( "alley_flares" );
		exploder( "ending_smk_plume" );
		stop_exploder("huge_plume");
		return;
	}
	if ( start == "garage" )
	{
		stop_exploder( "flak" );
		stop_exploder( "111" );
		stop_exploder( "112" );
		stop_exploder( "dam_pre_waterfall" );
		stop_exploder( "intro_amb_fx" );
		stop_exploder( "mr_sunflare" );
		//stop_exploder( "alley_flares" );
		exploder( "ending_smk_plume" );
		stop_exploder("huge_plume");
		set_vision_set("flood_garage2", 0);
//		fog_set_changes( "flood_garage2", 0 );
//	 	level.cw_vision_above = "flood_garage2";
//	 	level.cw_fog_above = "flood_garage2";
		return;
	}
}

fx_loading_docks_water_hide_top()
{
	//IPrintLnBold( "got water01" );
	room01_topwater = GetEnt( "water_loadingdocks_lower_high", "targetname" );
	room01_topwater Hide();
	
	// patrick changed this to use a flag that gets set as soon as the doors start opening
//	level waittill( "enter_loadingdocks" );
	//level waittill( "alley_move_warehouse" );
	
	//IPrintLnBold( "got water01 wait" );
	//water_01 show();
	//water_01 moveto( (22, -3314, -54), 3, 0, 0 );
}
	

fx_loading_docks_water_01()
{
	//IPrintLnBold( "got water01" );
	water_01 = GetEnt( "water_moving_warehouse_01", "targetname" );
	water_01 Hide();
	
	// patrick changed this to use a flag that gets set as soon as the doors start opening
//	level waittill( "enter_loadingdocks" );
	level waittill( "alley_move_warehouse" );
	
	//IPrintLnBold( "got water01 wait" );
	water_01 show();
	water_01 moveto( (22, -3314, -54), 3, 0, 0 );
}

fx_mall_rooftop_hide_shadow_geo()
{
	shadow_geo = GetEnt( "mall_rooftop_water_shadow_geo", "targetname" );
	shadow_geo_chunk = GetEnt( "mall_rooftop_water_geo_chunk", "targetname" );
	shadow_geo Hide();
	shadow_geo_chunk Hide();
}

fx_heli_land()
{
	exploder( "grounddust" );
}

infil_explosions()
{
	wait 4;
	//IPrintLnBold( "got explosions" );
	//exploder( "flak" );
	exploder( "111" );
	wait 1;
	exploder( "112" );
	wait 2;
	exploder( "111" );
	wait 1;
	exploder( "112" );
	wait 2;
	exploder( "111" );
	wait 1;
	exploder( "112" );
	wait 2;
	exploder( "111" );
	wait 1;
	exploder( "112" );
	wait 2;
	exploder( "1" );
	wait 1;
	exploder( "112" );
	wait 2;
	exploder( "111" );
	wait 1;
	exploder( "112" );
	wait 2;
	exploder( "1" );
	wait 3;
	exploder( "112" );
	wait 2;
	exploder( "111" );
	wait 3;
	exploder( "112" );
	wait 2;
	exploder( "1" );
	wait 1;
	exploder( "112" );
	wait 2;
	exploder( "111" );
	wait 1;
	exploder( "112" );
	wait 5;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
	wait 12;
	exploder( "1" );
}

fx_rooftops_water_hide()
{
	debri_bridge_water = GetEnt( "debri_bridge_water", "targetname" );
	//rooftops_water_swept = GetEnt( "swept_water_swim", "targetname" );
	debri_bridge_water Hide();
	//rooftops_water_swept Hide();
}

/*
fx_dam_godrays_hide()
{
	dam_godrays = GetEnt( "dam_godrays", "targetname" );
	rooftops_water Hide();
}
*/
/*
fx_rooftops_water_show()
{
	rooftops_water = GetEnt( "swept_water_noswim", "targetname" );
	rooftops_water show();
}
*/
fx_loading_docks_water_02()
{
	water_02 = GetEnt( "water_moving_warehouse_02", "targetname" );
	water_02 Hide();
	
	// patrick changed this to use a flag that gets set as soon as the doors start opening
//	level waittill( "enter_loadingdocks" );
	level waittill( "alley_move_warehouse" );
	
	water_02 show();
	water_02 moveto( (-201, -3461, -47), 4, 0, 0 );
}

fx_mall_roof_water_hide()
{
	mall_roof_water = GetEnt( "mall_roof_water", "targetname" );
	mall_roof_water Hide();
	mall_roof_water NotSolid();
	mall_roof_water_geo = GetEnt( "mall_roof_water_geo", "targetname" );
	mall_roof_water_geo Hide();
	mall_roof_water_geo NotSolid();
}

fx_mall_roof_water_show()
{
	mall_roof_water = GetEnt( "mall_roof_water", "targetname" );
	mall_roof_water_geo = GetEnt( "mall_roof_water_geo", "targetname" );
	//loadingdocks_water_upper = GetEnt( "water_loadingdocks", "targetname" );
	//loadingdocks_water_lower = GetEnt( "water_loadingdocks_lower", "targetname" );
	mall_rooftop_water_target = GetEnt( "mall_rooftop_water_target", "targetname" );

	mall_roof_water_geo RetargetScriptModelLighting( mall_rooftop_water_target );

	mall_roof_water show();
	mall_roof_water Solid();
	mall_roof_water_geo show();
	mall_roof_water_geo Solid();
	//mall_roof_water moveto( (896, -4032, 80), 0.01, 0, 0 );
	//test light grid on water
	//wait 2;
	
	//warehouse_water_model moveto( (-64, -2304, 400), 19, 0, 0 );

	stop_exploder( "wh_doorsprays" );
	stop_exploder( "warehouse_doorbreak" );
	
	exploder( "mall_floating_debri_med" );
}

fx_retarget_warehouse_waters_lighting()
{
	warehouse_waters_retarget = GetEnt( "warehouse_waters_retarget", "targetname" );
	coverwater_warehouse_above = GetEnt( "coverwater_warehouse_above", "targetname" );
	coverwater_warehouse_postmantle_above = GetEnt( "coverwater_warehouse_postmantle_above", "targetname" );
	coverwater_warehouse_premantle_above = GetEnt( "coverwater_warehouse_premantle_above", "targetname" );

	coverwater_warehouse_above RetargetScriptModelLighting( warehouse_waters_retarget );
	coverwater_warehouse_postmantle_above RetargetScriptModelLighting( warehouse_waters_retarget );
	coverwater_warehouse_premantle_above RetargetScriptModelLighting( warehouse_waters_retarget );
}

fx_retarget_rooftop_water_lighting()
{
	rooftops_water_retarget = GetEnt( "rooftops_water_retarget", "targetname" );
	debri_bridge_water = GetEnt( "debri_bridge_water", "targetname" );
	swept_water_swim = GetEnt( "swept_water_swim", "targetname" );

	debri_bridge_water RetargetScriptModelLighting( rooftops_water_retarget );
	swept_water_swim RetargetScriptModelLighting( rooftops_water_retarget );
	
	//debri_bridge_water hide();
	//swept_water_swim hide();
}

fx_mall_roof_amb_fx()
{
	corner_01_godrays = GetEnt( "corner_01_godrays", "targetname" );
	corner_01_godrays hide();

	exploder("huge_plume");
	exploder("mall_rooftop_amb");
	exploder("mall_rooftop_rapid_splash");
}

fx_swept_dunk_bubbles()
{
	//wait 1;
	PlayFXOnTag(GetFX("dunk_bubbles_runner"), level.cw_player_view_fx_source, "tag_origin");
	PlayFXOnTag(GetFX("rapids_splash_burst"), level.cw_player_view_fx_source, "tag_origin");
}

fx_swept_amb_fx()
{
	// Patrick, I changed this to call the script in the util file as that script has safeguards against the source not existing
//	maps\flood_util::set_player_view_water_fx_source();
	stop_exploder( "mall_rooftop_amb" );
	exploder("huge_plume_swept");

//	PlayFXOnTag( getfx( "flood_water_swept_bubbles_01" ), level.player_view_water_fx_source, "tag_origin" );
}

fx_skybridge_event()
{
	//IPrintLnBold( "got bridge fx" );
	exploder( "skybridge_building_smoke_02" );
}



//	Lighting Stuff ****************************************************


fx_vision_fog_init()
{
	thread set_enter_loadingdocks_vf();
	thread set_enter_rooftop_1_vf();
//	thread set_enter_canope_vf();
	thread set_enter_stairwell();
	thread set_enter_stealth_vf();
	thread set_enter_garage2_vf();
	thread set_enter_garage_mall_vf();
	thread set_warelights_off();
	thread set_door_burst_light();
	
}

set_enter_garage_mall_vf()
{	
 	flag_init("vs_garage1_trigger");
	
	while(1)
	{
		flag_wait("vs_garage1_trigger");
		vision_set_changes("flood_garage_mall", 1);
		fog_set_changes("flood_garage_mall", 1);
		
		while(flag("vs_garage1_trigger"))
		{
			waitframe();
		}
		
		vision_set_fog_changes("flood", 2);
	}
}

set_warelights_off()
{
	trigger = GetEnt("mall_light_off_trig", "targetname");
	warelights_off = GetEntArray( "mall_light", "targetname" );
	if ( IsDefined(trigger) )
	{
		trigger waittill ( "trigger" );
		
		foreach (ent in warelights_off)
		{
			
			ent SetLightRadius(13);
		}
	}
}
	
set_door_burst_light()
{
	flag_init("warehouse_door_burst");
	burst_light = GetEnt("punchLight", "targetname");
	
	
		flag_wait("warehouse_door_burst");
		
		if ( IsDefined(burst_light))
		{		    
		    burst_light SetLightIntensity(5);
		}
	
	
}


set_enter_canope_vf()
{
	//level endon("");
	flag_init("vs_canope_trigger");
	
	while(1)
	{
		flag_wait("vs_canope_trigger");
		VisionSetNaked("flood", 4);
		level.cw_vision_above = "flood";
		//trigger waittill( "trigger" );

		while(flag("vs_canope_trigger"))
		{
			waitframe();
		}
	
		VisionSetNaked("flood", 3);
		level.cw_vision_above = "flood";
 	}

}

set_enter_loadingdocks_vf()
{
	trigger = GetEnt( "inside_loadingdocks_vf", "targetname" );
	if ( IsDefined(trigger) )
	{
		trigger waittill( "trigger" );
	
		VisionSetNaked("flood_warehouse", .5);
		fog_set_changes( "flood_warehouse", .5);
	 	level.cw_vision_above = "flood_warehouse";
		level.cw_fog_above = "flood_warehouse";
		
	}
}

set_enter_stairwell()
{
	trigger = GetEnt("enter_stairwell", "targetname");
	//trigger2 = GetEnt("mall_rooftops_debri_trigger", "script_flag");
	lgtwarestuff = GetEntArray("warevolumes", "targetname");
	burst_light = GetEnt("punchLight", "targetname");
	upperFill = GetEnt("upperFill", "targetname");
	if ( IsDefined(trigger) )
	{
		
		trigger waittill( "trigger" );
		
		if (!flag("cw_player_underwater") )
		{
			VisionSetNaked("flood_stairs", 3);
			fog_set_changes( "flood_stairs", 3);
			SetSavedDvar("sm_sunSampleSizeNear", .10);
		}
		
	
		//delete lighting crap no longer needed
		foreach (ent in lgtwarestuff)
		{
			ent delete();
		}
		
		level.cw_vision_above = "flood_stairs";
	 	level.cw_fog_above = "flood_stairs";
	 	
	 	
	 	flag_wait("mall_rooftops_debri_trigger");
		
		if ( IsDefined(burst_light))
		{		    
		    burst_light SetLightIntensity(.20);
		}
		
		if ( IsDefined(upperFill))
		{		    
		    upperFill SetLightIntensity(.4);
		}
		
	}
}

		
set_enter_rooftop_1_vf()
{
	trigger = GetEnt("fx_mall_rooftop", "targetname");
	if ( IsDefined(trigger) )
	{
		trigger waittill( "trigger" );
	
		VisionSetNaked("flood_rooftop_1", .35);
		fog_set_changes( "flood_rooftop_1", 0 );
		SetSavedDvar("sm_sunSampleSizeNear", .25);
		
	 	level.cw_vision_above = "flood";
	 	level.cw_fog_above = "flood_rooftop_1";
	 	 	
	}
		 	
}

set_enter_swept_vf()
{
	start = level.start_point;
	if ( start == "swept" )
	{
	level.cw_vision_above = "flood_two";
	level.cw_fog_above = "flood";
		
		//changing sun flare for best composition in swept
		if ( is_gen4() )
	    {
	        //IPrintLnBold ("moving god rays");
	        ent = maps\_utility::create_sunflare_setting( "default" );
	        ent.position = (-17, -114, 0);
	        maps\_art::sunflare_changes( "default", 0 );    
		}

	}
}

set_enter_stealth_vf()
{
	//level endon("");
	flag_init("stealth_vs_trigger");
	
	//getting sunflare back to where it should be
	if ( is_gen4() )
	    {
	        //IPrintLnBold ("moving god rays");
	        ent = maps\_utility::create_sunflare_setting( "default" );
	        ent.position = (-40, -71.5, 0);
	        maps\_art::sunflare_changes( "default", 0 );    
		}
	
	while(1)
	{
		flag_wait("stealth_vs_trigger");
//		VisionSetNaked("flood_stealth", 3);
//		fog_set_changes( "flood_stealth", 0 );
		vision_set_fog_changes( "flood_stealth", 1);
		
		level.cw_vision_above = "flood_stealth";
		level.cw_fog_above = "flood_stealth";
		level.cw_fog_under = "flood_underwater";

		while(flag("stealth_vs_trigger"))
		{
			waitframe();
		}
	
		SetSavedDvar("sm_sunSampleSizeNear", .65);
		
		vision_set_fog_changes(	"flood_two", 3);
		level.cw_vision_above = "flood_two";
		level.cw_fog_above = "flood_two";

 	}

}

set_enter_garage2_vf()
{
	//level endon("");
	flag_init("garage2_vs_trigger");
	
	while(1)
	{
		flag_wait("garage2_vs_trigger");
		if (!flag("cw_player_underwater"))
				  {
					VisionSetNaked("flood_garage2", 3);
					fog_set_changes( "flood_garage2", 1 );
					//next line is above water vision set...
					level.cw_vision_above = "flood_garage2";
					level.cw_fog_above = "flood_garage2";
				  }

		while(flag("garage2_vs_trigger") || (flag("cw_player_underwater")))
		{
			waitframe();			
		}
		
//		if (!flag("cw_player_underwater"))
//		{
//			VisionSetNaked("flood_flood_two", 3);
//			fog_set_changes( "flood_flood_two", 3);
//		}
		
	
		vision_set_fog_changes("flood_two", 3);
		level.cw_vision_above = "flood_two";
		level.cw_fog_above = "flood";
		
 	}

}

set_enter_skybridge_room_vf()
{
	//level endon("");
	flag_init("vs_skybridge_room_trigger");
	
	while(1)
	{
		flag_wait("vs_skybridge_room_trigger");
//		VisionSetNaked("flood_skybridge_room", 3);
//		level.cw_vision_above = "flood_skybridge_room";
		vision_set_fog_changes("flood_skybridge_room", 3);
			
		SetSavedDvar("sm_sunSampleSizeNear", .25);

		while(flag("vs_skybridge_room_trigger"))
		{
			waitframe();
		}
	
		VisionSetNaked("flood_two", 3);
		level.cw_vision_above = "flood_two";
		level.cw_fog_above = "flood_two";
 	}

}

lgt_shadow_improve_dam()
{

	wait 1;
	IPrintLnBold ("Start Shadow Improvement Dam");
	//SetSavedDvar("sm_sunSampleSizeNear", 3.5);
	//SetSavedDvar ("sm_polygonOffsetScale", .5);
	//SetSavedDvar ("sm_polygonOffsetBias", .5);
	
	wait 15;
	IPrintLnBold ("End Shadow Improvement Dam");
	
}

//adding in some bokehdot screenfx hooks :apm

fx_create_bokehdots_source()
{	
	if( !IsDefined( level.player.flood_bokehdot ) )
		level.player.flood_bokehdot = 0;
	
	if( !IsDefined( level.flood_source_bokehdots )  )
	{
		level.flood_source_bokehdots = spawn( "script_model", ( 0, 0, 0 ) );
		level.flood_source_bokehdots setmodel( "tag_origin" );
//		level.flood_source_bokehdots.origin = level.player.origin;
		level.flood_source_bokehdots LinkToPlayerView( level.player, "tag_origin", (0,0,0), (0,0,0), true );
	}	
}

fx_bokehdots_far()
{
	fx_create_bokehdots_source();
	
	if( !flag( "cw_player_underwater" ) )
	{
		thread delayThread( 0.05, ::fx_waterdrops_3 );
		if( level.player.flood_bokehdot <= 5 )
		{
//			IPrintLn( "new far bokeh created " + level.player.flood_bokehdot );
			level.player.flood_bokehdot++;
			PlayFXOnTag( GetFX( "bokehdots_far" ), level.flood_source_bokehdots, "tag_origin" );
			wait 5;
			StopFXOnTag( GetFX( "bokehdots_far" ), level.flood_source_bokehdots, "tag_origin" );
			level.player.flood_bokehdot--;
		}
	}
}

fx_bokehdots_close()
{
	fx_create_bokehdots_source();
	
	if( !flag( "cw_player_underwater" ))
	{
		thread delayThread( 0.05, ::fx_waterdrops_3 );
		thread delayThread( 0.10, ::fx_waterdrops_3 );
		if( level.player.flood_bokehdot <= 5 )
		{
//			IPrintLn( "new close bokeh created " + level.player.flood_bokehdot );
			level.player.flood_bokehdot++;
			PlayFXOnTag( GetFX( "bokehdots_close" ), level.flood_source_bokehdots, "tag_origin" );
			wait 5;
			StopFXOnTag( GetFX( "bokehdots_close" ), level.flood_source_bokehdots, "tag_origin" );
			level.player.flood_bokehdot--;
		}
	}
}

fx_turn_on_bokehdots_16_player()
{
	fx_create_bokehdots_source();
	
	if( !flag( "cw_player_underwater" ) )
	{
		PlayFXOnTag( GetFX( "bokehdots_16" ), level.flood_source_bokehdots, "tag_origin" );
		//PlayFXOnTag( getfx( "splash_lens_02" ), level.flood_source_bokehdots, "tag_origin" );
	}
}

fx_turn_on_bokehdots_32_player()
{
	fx_create_bokehdots_source();
	
	if( !flag( "cw_player_underwater" ) )
	{
		PlayFXOnTag( GetFX( "bokehdots_32" ), level.flood_source_bokehdots, "tag_origin" );
		//PlayFXOnTag( getfx( "splash_lens_01" ), level.flood_source_bokehdots, "tag_origin" );
	}
}

fx_turn_on_bokehdots_64_player()
{
	fx_create_bokehdots_source();
	
	if( !flag( "cw_player_underwater" ) )
	{
		PlayFXOnTag( GetFX( "bokehdots_64" ), level.flood_source_bokehdots, "tag_origin" );
		//PlayFXOnTag( getfx( "splash_lens_03" ), level.flood_source_bokehdots, "tag_origin" );

	}
}

fx_waterdrops_3()
{
	fx_create_bokehdots_source();
	
	if( !flag( "cw_player_underwater" ))
		PlayFXOnTag( GetFX( "waterdrops_3" ), level.flood_source_bokehdots, "tag_origin" );
}

fx_waterdrops_20_inst()
{
	fx_create_bokehdots_source();
	
	if( !flag( "cw_player_underwater" ))
		PlayFXOnTag( GetFX( "waterdrops_20_inst" ), level.flood_source_bokehdots, "tag_origin" );
}

fx_bokehdots_and_waterdrops_heavy( lifetime )
{
	fx_create_bokehdots_source();
	
	if( !IsDefined( lifetime ) )
		lifetime = 5;
	
	if( !flag( "cw_player_underwater" ) && level.player.flood_bokehdot <= 5 )
	{
		level.player.flood_bokehdot++;
		PlayFXOnTag( GetFX( "bokehdots_and_waterdrops_heavy" ), level.flood_source_bokehdots, "tag_origin" );
		wait lifetime;
		StopFXOnTag( GetFX( "bokehdots_and_waterdrops_heavy" ), level.flood_source_bokehdots, "tag_origin" );
		level.player.flood_bokehdot--;
	}
}

bokehdots_audition_test()
{	
	self endon( "death" );
	self notify( "stop raining_bokeh" );
	self endon( "stop raining_bokeh" );
	self.has_raining_bokeh = 1;
	
	while ( isdefined( self ) )
	{
		wait( 0.05 );
		if( !isdefined( self ) )
			break;
		
		thread fx_turn_on_bokehdots_16_player();
		wait( 5 );
		thread fx_turn_on_bokehdots_32_player();
		wait( 5 );
		thread fx_turn_on_bokehdots_64_player();
		wait( 5 );

	}
}
	

fx_lens_splash_02()
{
	fx_create_bokehdots_source();
	//IPrintLn( "here here" );
	//need to check if underwater first
	PlayFXOnTag( getfx( "splash_lens_02" ), level.flood_source_bokehdots, "tag_origin" );
	wait 2;
	PlayFXOnTag( getfx( "splash_lens_02" ), level.flood_source_bokehdots, "tag_origin" );
	wait 2;
	PlayFXOnTag( getfx( "splash_lens_02" ), level.flood_source_bokehdots, "tag_origin" );
	//PlayFXOnTag( getfx( "chromaloop_left" ), level.flood_source_bokehdots, "tag_origin" );
}

// this get played at the start of the wave and on the alley side collision checkers to put water splash on the players screen
fx_angry_flood_nearmiss( delete )
{
	self waittill( "trigger" );
	
	// don't keep on doing these even if you're in the radius
	if( !IsDefined( level.flood_near_miss ) )
		level.flood_near_miss = 0;
	
	if( !level.flood_near_miss )
	{
//		IPrintLn( "doing near miss" );
		level.flood_near_miss = 1;
		
		thread fx_turn_on_bokehdots_16_player();
		thread fx_waterdrops_20_inst();
		level.player SetWaterSheeting( 1, 1.5 );
		
		wait RandomFloatRange( 0.7, 1.1 );
		level.flood_near_miss = 0;
	}
	else
//		IPrintLn( "not doing near miss" );
	
	if( IsDefined( delete ) && delete )
		self Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//stealth fx
fx_swept_underwater_fx_on()
{
	level endon( "skybridge_done" );
	
	stealth_fx = GetEnt( "stealth_fx", "targetname" );
	
	while( 1 )
	{
		flag_wait( "cw_player_underwater" );
		PlayFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_001" );
		waitframe();
		PlayFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_002" );
		waitframe();
		PlayFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_003" );
		waitframe();
		PlayFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_004" );
		waitframe();
		PlayFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_005" );
		waitframe();
		PlayFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_006" );
		flag_wait( "cw_player_abovewater" );
	}
}

fx_swept_underwater_fx_off()
{
	level endon( "skybridge_done" );
	
	stealth_fx = GetEnt( "stealth_fx", "targetname" );
	
	while( 1 )
	{
		flag_wait( "cw_player_abovewater" );
		KillFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_001" );
		waitframe();
		KillFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_002" );
		waitframe();
		KillFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_003" );
		waitframe();
		KillFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_004" );
		waitframe();
		KillFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_005" );
		waitframe();
		KillFXOnTag( getfx( "flood_swept_player_murk" ), stealth_fx, "tag_fx_stealth_murk_006" );
		flag_wait( "cw_player_underwater" );
	}
}

start_ally1_bubbles( guys )
{
	while( 1)
	{
		flag_wait( "cw_player_underwater" );
//		IPrintLn( "submerged" );
		
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_LE" );
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_RI" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_RI" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_LE" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_SpineLower" );
		
		flag_wait( "cw_player_abovewater" );
//		IPrintLn( "surfaced" );
	
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_LE" );
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_RI" );
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_SpineLower" );

		waitframe();
	}

	/*
	flag_wait_any( "cw_player_underwater", "cw_player_abovewater" );
	while( 1 )
	{
	  if( flag( "cw_player_underwater" ) );
	  {
	    // underwater stuff
	    flag_waitopen( "cw_player_underwater" );
	    PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_LE" );

	  }
	  else if( flag( "cw_player_abovewater" ) );
	  {
	    // above water stuff
	    flag_waitopen( "cw_player_abovewater" );
	    KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_LE" );

	  }
	  waitframe();
	}
	*/
}

start_ally1_submerge_bubbles( guys )
{
	while( 1)
	{
		flag_wait( "cw_player_underwater" );
//		IPrintLn( "submerged" );

		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_LE" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_RI" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_RI_1" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_LE_1" );		

		flag_wait( "cw_player_abovewater" );
//		IPrintLn( "surfaced" );

		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_RI_1" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_LE_1" );

		waitframe();	
	}
}

ally1_emerge_splash( guys )
{
	IPrintLn( "ally1_emerge_splash" );

}

fx_ally1_kill_upper_bubbles( guys )
{
	/*
	while( 1)
	{
		flag_wait( "player_submerged" );
		IPrintLn( "submerged" );


		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_RI_1" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_LE_1" );
		
		flag_wait( "cw_player_abovewater" );
		IPrintLn( "surfaced" );
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_RI_1" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_LE_1" );

		waitframe();
	}
*/
}

fx_opfor3_tussle_bubbles( guys )
{
	while( 1)
	{
		flag_wait( "cw_player_underwater" );
//		IPrintLn( "submerged" );
		
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_LE" );
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_RI" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_RI" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_LE" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_SpineLower" );
		
		flag_wait( "cw_player_abovewater" );
//		IPrintLn( "surfaced" );
	
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_LE" );
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_RI" );
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_SpineLower" );

		waitframe();
	}

}

fx_opfor3_pushdown_bubbles( guys )
{
	while( 1)
	{
		flag_wait( "cw_player_underwater" );
//		IPrintLn( "submerged" );

		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_LE" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_RI" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_RI_1" );
		waitframe();
		PlayFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_LE_1" );		

		flag_wait( "cw_player_abovewater" );
//		IPrintLn( "surfaced" );

		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_RI_1" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_LE_1" );

		waitframe();
	}
}

fx_ally1_kill_tussle_bubbles_02( guys )
{
	/*
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Ankle_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Knee_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_SpineLower" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_LE" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Elbow_RI" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_RI_1" );
		waitframe();
		KillFXOnTag( getfx( "bubbles_player_hand" ), guys, "J_Mid_LE_1" );
		*/
}

fx_stealthkill_02_blood_01( guys )
{
	PlayFXOnTag( getfx( "blood_spurt_trapped_underwater" ), guys, "J_Index_RI_1" );
}

fx_stealthkill_02_blood_02( guys )
{
	PlayFXOnTag( getfx( "intro_blood_throat_stab" ), guys, "J_Clavicle_RI" );
}

fx_stealthkill_02_opfor2_blood_01( guys )
{
	PlayFXOnTag( getfx( "intro_blood_throat_stab" ), guys, "TAG_EYE" );
}

fx_stealthkill_02_opfor2_blood_02( guys )
{
	PlayFXOnTag( getfx( "intro_blood_throat_stab" ), guys, "TAG_EYE" );
	waitframe();
	/*
	PlayFXOnTag( getfx( "blood_chest_wound" ), guys, "TAG_EYE" );
	wait 1.5;
	KillFXOnTag( getfx( "blood_chest_wound" ), guys, "TAG_EYE" );
*/
}

fx_hatchet_face_1( guys )
{
	PlayFXOnTag( getfx( "blood_stealth_hatchet" ), guys, "TAG_INHAND" );
	wait 3;
	KillFXOnTag( getfx( "blood_stealth_hatchet" ), guys, "TAG_INHAND" );
}

fx_rooftops_wall_kick()
{
	wait 13.2;
	exploder( "rooftop1_wall_kick_dust" );
}

fx_infil_heli_smoke()
{
	//IPrintLnBold(" got heli smoke");
	//exploder( "infil_sunglow" );

	PlayFXOnTag(GetFX("flood_intro_heli_smoke"), level.cw_player_view_fx_source, "tag_origin");
}

fx_skybridge_room_bokeh_01()
{
	flag_init( "skybridge_room_bokeh_01" );
	flag_wait( "skybridge_room_bokeh_01" );
	fx_create_bokehdots_source();

		PlayFXOnTag( GetFX( "bokehdots_64" ), level.flood_source_bokehdots, "tag_origin" );
		wait 0.5;
		PlayFXOnTag( GetFX( "bokehdots_64" ), level.flood_source_bokehdots, "tag_origin" );
}

fx_skybridge_room_bokeh_02()
{
	flag_init( "skybridge_room_bokeh_02" );
	flag_wait( "skybridge_room_bokeh_02" );
	fx_create_bokehdots_source();

		PlayFXOnTag( GetFX( "bokehdots_64" ), level.flood_source_bokehdots, "tag_origin" );
		wait 0.5;
		PlayFXOnTag( GetFX( "bokehdots_64" ), level.flood_source_bokehdots, "tag_origin" );
		wait 0.5;
		PlayFXOnTag( GetFX( "bokehdots_64" ), level.flood_source_bokehdots, "tag_origin" );
}

// treadfx
treadfx_override()
{
	//IPrintLnBold( "got tread fx" );
	rooftop_treadfx = "vfx/moments/flood/rooftop1_heli_dust_kickup";
	//maps\_treadfx::setallvehiclefx( "script_vehicle_ny_harbor_hind", rooftop_treadfx );
	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "brick", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "bark", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "carpet", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "cloth", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "concrete", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "dirt", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "flesh", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "foliage", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "glass", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "grass", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "gravel", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "ice", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "metal", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "mud", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "paper", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "plaster", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "rock", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "sand", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "snow", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "water", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "wood", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "asphalt", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "ceramic", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "plastic", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "rubber", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "cushion", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "fruit", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "painted metal", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "default", rooftop_treadfx );
	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "none", rooftop_treadfx );
	
	
	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "brick", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "bark", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "carpet", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "cloth", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "concrete", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "dirt", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "flesh", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "foliage", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "glass", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "grass", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "gravel", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "ice", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "metal", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "mud", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "paper", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "plaster", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "rock", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "sand", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "snow", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "water", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "wood", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "asphalt", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "ceramic", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "plastic", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "rubber", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "cushion", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "fruit", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "painted metal", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "default", rooftop_treadfx );
	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "none", rooftop_treadfx );
	
	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "brick", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "bark", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "carpet", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "cloth", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "concrete", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "dirt", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "flesh", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "foliage", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "glass", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "grass", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "gravel", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "ice", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "metal", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "mud", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "paper", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "plaster", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "rock", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "sand", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "snow", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "water", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "wood", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "asphalt", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "ceramic", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "plastic", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "rubber", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "cushion", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "fruit", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "painted metal", rooftop_treadfx );
 	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "default", rooftop_treadfx );
	maps\_treadfx::setvehiclefx( "script_vehicle_nh90 ", "none", rooftop_treadfx );
}

character_make_wet( time, gun )
{
//	IPrintLn( "making wet" );
	
	if( !IsDefined( time ) )
	   time = 1;
	
	if( !IsDefined( gun ) )
	   gun = false;
	   
	wetfx_tags = [];
	wetfx_tags[ 0 ] = "J_Elbow_LE";
	wetfx_tags[ 1 ] = "J_Elbow_RI";
	wetfx_tags[ 2 ] = "J_Wrist_LE";
	wetfx_tags[ 3 ] = "J_Wrist_RI";
	wetfx_tags[ 4 ] = "TAG_STOWED_BACK";
	wetfx_tags[ 5 ] = "J_Neck";

	if( gun )
		PlayFXOnTag( GetFX( "water_emerge_weapon" ), self, "TAG_FLASH" );
	
	// put time in milliseconds
	start_time = GetTime() + ( time * 1000 );
	last_time = GetTime();
	
	while( last_time < start_time )
	{
		foreach( wetfx_tag in wetfx_tags )
		{
			wetfx_tag_pos = self GetTagOrigin( wetfx_tag ) + ( RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ) );
			PlayFX( GetFX( "character_drips" ), wetfx_tag_pos );
			wait RandomFloatRange( 0.03, 0.09 );
		}
		wait RandomFloatRange( 0.05, 0.2 );
		last_time = GetTime();
		//If ther character is standing still, change out the drip/pool effects
		//PrintLn( "starting drip switcher" );
		thread fx_drip_switcher();
	}

//	IPrintLn( "done making wet" );
}

fx_drip_switcher()
{
	//if( self.animname == "flood_warehouse_stairs_loop_ally_01" || self.animname == "flood_warehouse_stairs_loop_ally_02" || self.animname == "flood_warehouse_stairs_loop_ally_03" )
	if( flag( "ally0_stair_ready" ) || flag( "ally1_stair_ready" ))//stainding still in loop anim
    {
        //replace the pooling drips with drips that don't leave pools
		level._effect[ "character_drips" ] = LoadFX( "vfx/moments/flood/flood_character_drips_child" );
		//PrintLn( "switching to no pool" );
		//then play the big pool effect 1 time
		wait 1;
		if( !IsDefined(self.drip_already_played) )
		{
			//PlayFXonTag( GetFX( "flood_character_drips_big_pool" ), self, "TAG_STOWED_BACK" );
			PlayFXonTag( GetFX( "flood_drips_big" ), self, "TAG_STOWED_BACK" );
			self.drip_already_played = true;
			//PrintLn( "drop big pool" );
		}
    }
	if( flag("moving_to_mall") )
    {
    	//set the drip effects back to the pooling ones
		level._effect[ "character_drips" ] = LoadFX( "vfx/moments/flood/flood_character_drips" );
		//PrintLn( "switching back to pooling drips" );
    }
}
