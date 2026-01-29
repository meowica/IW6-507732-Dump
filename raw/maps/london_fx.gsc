#include common_scripts\utility;
#include maps\_utility;

main()
{
	maps\createfx\london_fx::main();
	maps\createfx\london_sound::main();	
//	level thread treadfx_override();

	footstep_fx();
	level_fx();
	ambient_fx();
}

level_fx()
{
	level._effect[ "forklift_blinklight" ]			= LoadFX( "fx/misc/light_blink_forklift" );
	level._effect[ "forklift_headlight" ]			= LoadFX( "fx/misc/car_headlight_forklift" );

	level._effect[ "chase_heli_spotlight" ] 		= LoadFX( "fx/misc/chase_heli_spotlight_model" );
	level._effect[ "chase_heli_spotlight_cheap" ] 	= LoadFX( "fx/misc/docks_heli_spotlight_model_cheap" );

	level._effect[ "docks_heli_spotlight" ] 		= LoadFX( "fx/misc/docks_heli_spotlight_model" );
	level._effect[ "docks_heli_spotlight_cheap" ] 	= LoadFX( "fx/misc/docks_heli_spotlight_model_cheap" );
	
	level._effect[ "chopper_flares" ] 				= LoadFX( "fx/misc/flares_cobra" );
	level._effect[ "impact_fx" ]					= LoadFX( "fx/impacts/flesh_hit_body_fatal_exit" );
	level._effect[ "impact_fx_nonfatal" ]			= LoadFX( "fx/impacts/flesh_hit_body_nonfatal" );

	level._effect[ "rpg_trail" ] 					= LoadFX( "fx/smoke/smoke_geotrail_rpg" );
	level._effect[ "rpg_muzzle" ] 					= LoadFX( "fx/muzzleflashes/at4_flash" );
	level._effect[ "rpg_explode" ] 					= LoadFX( "fx/explosions/rpg_wall_impact" );

	level._effect[ "interactive_tv_light" ]			= LoadFX( "fx/props/interactive_tv_light" );

//	level._effect[ "lynx_tail_damaged" ]			= LoadFX( "fx/fire/fire_smoke_trail_L" );
//	level._effect[ "lynx_engine_damaged" ]			= LoadFX( "fx/fire/fire_smoke_trail_L" );

	level._effect[ "clouds_predator" ]				= LoadFX( "fx/misc/clouds_predator" );

	level._effect[ "silencer_flash" ] 				= LoadFX( "fx/muzzleflashes/m4m203_silencer" );

	level._effect[ "minigun_shells" ] 				= LoadFX( "fx/shellejects/20mm_cargoship" );
}

ambient_fx()
{	

	level._effect[ "waterfall_drainage_short_london" ]	= LoadFX( "fx/water/waterfall_drainage_short_london" );
	level._effect[ "waterfall_splash_medium_london" ]	= LoadFX( "fx/water/waterfall_splash_medium_london" );
	level._effect[ "drainpipe_runoff" ]					= LoadFX( "fx/water/drainpipe_runoff" );
	level._effect[ "drainpipe_runoff_splash" ]			= LoadFX( "fx/water/drainpipe_runoff_splash" );
	level._effect[ "ride_parallax_debris" ]				= LoadFX( "fx/misc/ride_parallax_debris" );
	level._effect[ "light_glow_white_london" ]			= LoadFX( "fx/misc/light_glow_white_london" );
	
	
	level._effect[ "mist_drifting" ]					= LoadFX( "fx/smoke/mist_drifting" );
	level._effect[ "mist_distant_drifting" ]			= LoadFX( "fx/smoke/mist_distant_drifting" );
	level._effect[ "mist_drifting_groundfog" ]			= LoadFX( "fx/smoke/mist_drifting_groundfog" );
	level._effect[ "mist_drifting_london_docks" ]		= LoadFX( "fx/smoke/mist_drifting_london_docks" );
	level._effect[ "ground_fog_london_river" ]			= LoadFX( "fx/smoke/ground_fog_london_river" );

	level._effect[ "room_smoke_200" ]					= LoadFX( "fx/smoke/room_smoke_200" );
	level._effect[ "room_smoke_400" ]					= LoadFX( "fx/smoke/room_smoke_400" );

	level._effect[ "rain_london" ]						= LoadFX( "fx/weather/rain_london" );
	level._effect[ "rain_london_fill" ]					= LoadFX( "fx/weather/rain_london_fill" );
	level._effect[ "rain_noise_splashes" ]				= LoadFX( "fx/weather/rain_noise_splashes" );
	level._effect[ "rain_splash_subtle_64x64" ]			= LoadFX( "fx/weather/rain_splash_subtle_64x64" );
	level._effect[ "rain_splash_subtle_128x128" ]		= LoadFX( "fx/weather/rain_splash_subtle_128x128" );
	level._effect[ "rain_splash_lite_64x64" ]			= LoadFX( "fx/weather/rain_splash_lite_64x64" );
	level._effect[ "rain_splash_lite_128x128" ]			= LoadFX( "fx/weather/rain_splash_lite_128x128" );

	level._effect[ "lighthaze_london" ] 				= LoadFX( "fx/misc/lighthaze_london" );


	level._effect[ "firelp_med_pm" ]					= LoadFX( "fx/fire/firelp_med_pm" );
	level._effect[ "firelp_med_pm_cheap" ]				= LoadFX( "fx/fire/firelp_med_pm_cheap" );
	level._effect[ "firelp_small_pm" ]				 	= LoadFX( "fx/fire/firelp_small_pm" );
	
	level._effect[ "trash_spiral_runner" ]				= LoadFX( "fx/misc/trash_spiral_runner" );
	
//	level._effect[ "streetlamp_poisonous_gas_before" ]	= LoadFX( "fx/misc/streetlamp_poisonous_gas_before" );
	
//	level._effect[ "fire_falling_runner_point" ]		= LoadFX( "fx/fire/fire_falling_runner_point" );
//	level._effect[ "fire_falling_runner_point_far" ]	= LoadFX( "fx/fire/fire_falling_runner_point_far" );
	
	
//	level._effect[ "cloud_ash_lite_nyHarbor" ]				= LoadFX( "fx/weather/cloud_ash_lite_nyHarbor" );
//	level._effect[ "carbomb_large" ]					= LoadFX( "fx/explosions/carbomb_large" );
//	level._effect[ "carbomb_large_blastwave" ]			= LoadFX( "fx/explosions/carbomb_large_blastwave" );
//	level._effect[ "poisonous_gas_carbomb" ]			= LoadFX( "fx/explosions/poisonous_gas_carbomb" );
//	level._effect[ "poisonous_gas_carbomb_cheap_loop" ]	= LoadFX( "fx/explosions/poisonous_gas_carbomb_cheap_loop" );
//	level._effect[ "poisonous_gas_carbomb_cheap" ]		= LoadFX( "fx/explosions/poisonous_gas_carbomb_cheap" );
//	level._effect[ "poisonous_gas_carbomb_distant" ]	= LoadFX( "fx/explosions/poisonous_gas_carbomb_distant" );
//	level._effect[ "poisonous_gas_carbomb_distant_large" ]	= LoadFX( "fx/explosions/poisonous_gas_carbomb_distant_large" );
//	level._effect[ "poisonous_gas_linger_low_thin" ]	= LoadFX( "fx/smoke/poisonous_gas_linger_low_thin" );
//	level._effect[ "poisonous_gas_linger_large_thin" ]	= LoadFX( "fx/smoke/poisonous_gas_linger_large_thin" );
//	level._effect[ "poisonous_gas_linger_large_subtle" ]	= LoadFX( "fx/smoke/poisonous_gas_linger_large_subtle" );
//	level._effect[ "poisonous_gas_linger_medium_thick_killer" ] = LoadFX( "fx/smoke/poisonous_gas_linger_medium_thick_killer" );
//	level._effect[ "poisonous_gas_linger_medium_thick_killer_pulse" ] = LoadFX( "fx/smoke/poisonous_gas_linger_medium_thick_killer_pulse" );
//	level._effect[ "poisonous_gas_linger_medium_thick_killer_ins" ] = LoadFX( "fx/smoke/poisonous_gas_linger_medium_thick_killer_instant" );
//	level._effect[ "poisonous_gas_linger_medium_thick_sat" ] = LoadFX( "fx/smoke/poisonous_gas_linger_medium_thick_sat" );
//	level._effect[ "poisonous_gas_ground_london_player" ] = LoadFX( "fx/smoke/poisonous_gas_ground_london_player" );
//	level._effect[ "poisonous_gas_ground_z_fill" ] 		= LoadFX( "fx/smoke/poisonous_gas_ground_z_fill" );

//	level._effect[ "poisonous_gas_bubbling_left" ]			= LoadFX( "fx/smoke/poisonous_gas_bubbling_left" );
//	level._effect[ "poisonous_gas_bubbling_right" ]			= LoadFX( "fx/smoke/poisonous_gas_bubbling_right" );
//	level._effect[ "poisonous_gas_bubbling_start_left" ]		= LoadFX( "fx/smoke/poison_gas_attack" );
//	level._effect[ "poisonous_gas_bubbling_start_right" ]		= LoadFX( "fx/smoke/poisonous_gas_bubbling_start_right" );
//	level._effect[ "poisonous_gas_bubbling_small_left" ]		= LoadFX( "fx/smoke/poisonous_gas_bubbling_small_left" );
//	level._effect[ "poisonous_gas_bubbling_small_right" ]		= LoadFX( "fx/smoke/poisonous_gas_bubbling_small_right" );
	
//	level._effect[ "glass_shatter_london" ] 			= LoadFX( "fx/misc/glass_shatter_london" );
	level._effect[ "steam_vent_large_wind" ] 			= LoadFX( "fx/smoke/steam_vent_large_wind" );
	
//	level._effect[ "building_explosion_london_obscured" ]	= LoadFX( "fx/explosions/building_explosion_london_obscured" );
//	level._effect[ "building_explosion_london" ]		= LoadFX( "fx/explosions/building_explosion_london" );
//	level._effect[ "building_explosion_london_car" ]	= LoadFX( "fx/explosions/building_explosion_london_car" );
//	level._effect[ "flaming_meteor" ]					= LoadFX( "fx/fire/flaming_meteor" );
//	level._effect[ "flaming_meteor_large" ]				= LoadFX( "fx/fire/flaming_meteor_large" );
//	level._effect[ "helicopter_collide_docks" ]			= LoadFX( "fx/explosions/helicopter_collide_docks" );
//	level._effect[ "helicopter_explosion_docks" ]		= LoadFX( "fx/explosions/helicopter_explosion_docks" );
//	level._effect[ "helicopter_explosion_docks_giant" ]	= LoadFX( "fx/explosions/helicopter_explosion_docks_giant" );
//	level._effect[ "crane_cockpit_explosion" ]			= LoadFX( "fx/explosions/crane_cockpit_explosion" );
//	level._effect[ "car_impact_explosion" ]				= LoadFX( "fx/explosions/car_impact_explosion" );
//	level._effect[ "water_splash_large" ]				= LoadFX( "fx/water/water_splash_large" );
	// fire fx
	level._effect[ "fire_tree_london" ]							= LoadFX( "fx/fire/fire_tree_london" );
	level._effect[ "fire_tree_slow_london" ]					= LoadFX( "fx/fire/fire_tree_slow_london" );
	level._effect[ "fire_falling_runner_london" ]				= LoadFX( "fx/fire/fire_falling_runner_london" );
	level._effect[ "fire_tree_embers_london" ]					= LoadFX( "fx/fire/fire_tree_embers_london" );
	level._effect[ "fire_tree_distortion_london" ]				= LoadFX( "fx/fire/fire_tree_distortion_london" );
	
	level._effect[ "collumn_explosion" ]					= LoadFX( "fx/explosions/collumn_explosion" );
	level._effect[ "collumn_explosion_dense" ]				= LoadFX( "fx/explosions/collumn_explosion_dense" );
	
//	level._effect[ "police_barrier_des" ]					= LoadFX( "fx/props/police_barrier_des" );
	
	level._effect[ "uk_utility_truck_debris" ]				= LoadFX( "fx/misc/uk_utility_truck_debris" );
	level._effect[ "uk_utility_truck_spew" ]				= LoadFX( "fx/misc/uk_utility_truck_spew" );
	level._effect[ "truck_explosion_subway" ]				= LoadFX( "fx/explosions/truck_explosion_subway" );
	level._effect[ "smoke_fill_subway" ]					= LoadFX( "fx/smoke/smoke_fill_subway" );
	level._effect[ "smoke_fill_linger_subway" ]				= LoadFX( "fx/smoke/smoke_fill_linger_subway" );
	level._effect[ "smoke_fill_linger_subway_rolling" ]		= LoadFX( "fx/smoke/smoke_fill_linger_subway_rolling" );
	level._effect[ "smoke_fill_linger_subway_gap" ]		= LoadFX( "fx/smoke/smoke_fill_linger_subway_gap" );
	
	
	level._effect[ "sparks_car_scrape_line" ]				= LoadFX( "fx/misc/sparks_car_scrape_line" );
	level._effect[ "sparks_car_scrape_point" ]				= LoadFX( "fx/misc/sparks_car_scrape_point" );
	
	level._effect[ "debris_subway_fallover" ]						= LoadFX( "fx/misc/debris_subway_fallover" );
	level._effect[ "debris_subway_fallover_sparky" ]						= LoadFX( "fx/misc/debris_subway_fallover_sparky" );
	level._effect[ "debris_subway_impact_line" ]					= LoadFX( "fx/misc/debris_subway_impact_line" );
	level._effect[ "debris_subway_scrape_line" ]					= LoadFX( "fx/misc/debris_subway_scrape_line" );
	level._effect[ "debris_subway_scrape_line_short" ]				= LoadFX( "fx/misc/debris_subway_scrape_line_short" );
	level._effect[ "debris_subway_scrape_line_short_heavy" ]		= LoadFX( "fx/misc/debris_subway_scrape_line_short_heavy" );
	level._effect[ "debris_subway_scrape_player" ]					= LoadFX( "fx/misc/debris_subway_scrape_player" );
	
	level._effect[ "sparks_subway_scrape_line" ]					= LoadFX( "fx/misc/sparks_subway_scrape_line" );
	level._effect[ "sparks_subway_scrape_line_short" ]				= LoadFX( "fx/misc/sparks_subway_scrape_line_short" );
	level._effect[ "sparks_subway_scrape_line_short_diminishing" ]	= LoadFX( "fx/misc/sparks_subway_scrape_line_short_diminishing" );
	level._effect[ "sparks_subway_scrape_line_short_heavy" ]		= LoadFX( "fx/misc/sparks_subway_scrape_line_short_heavy" );
	level._effect[ "sparks_subway_scrape_player" ]					= LoadFX( "fx/misc/sparks_subway_scrape_player" );
	level._effect[ "sparks_subway_scrape_point" ]					= LoadFX( "fx/misc/sparks_subway_scrape_point" );
	level._effect[ "sparks_subway_scrape_point_wheels" ]			= LoadFX( "fx/misc/sparks_subway_scrape_point_wheels" );
	level._effect[ "sparks_subway_truck_collision" ]				= LoadFX( "fx/misc/sparks_subway_truck_collision" );
	
	level._effect[ "sparks_truck_scrape_line_short_diminishing" ]	= LoadFX( "fx/misc/sparks_truck_scrape_line_short_diminishing" );
	
	level._effect[ "hand_dirt_drag" ]							= LoadFX( "fx/smoke/hand_dirt_drag" );


	level._effect[ "vehicle_sever_subway" ]						= LoadFX( "fx/explosions/vehicle_sever_subway" );
	level._effect[ "light_blink_subway" ]						= LoadFX( "fx/lights/light_blink_subway" );
	
	level._effect[ "light_blink_london_police_car" ]			= LoadFX( "fx/lights/light_blink_london_police_car" );
	level._effect[ "light_blink_london_police_car_gassy" ]		= LoadFX( "fx/lights/light_blink_london_police_car_gassy" );
	level._effect[ "light_blink_london_police_car_gassy_sat" ]	= LoadFX( "fx/lights/light_blink_london_police_car_gassy_sat" );
	
//	level._effect[ "detonator_light" ]	= LoadFX( "fx/lights/light_detonator_blink" );
	
	level._effect[ "sparks_falling_runner_loop" ]				= LoadFX( "fx/explosions/sparks_falling_runner_loop" );
	level._effect[ "transformer_spark_runner_loop" ]			= LoadFX( "fx/explosions/transformer_spark_runner_loop" );
	level._effect[ "generator_spark_runner_loop" ]				= LoadFX( "fx/explosions/generator_spark_runner_loop" );
	level._effect[ "electrical_transformer_spark_runner_loop" ]	= LoadFX( "fx/explosions/electrical_transformer_spark_runner_loop" );
	level._effect[ "electrical_transformer_spark_runner_lon" ]	= LoadFX( "fx/explosions/electrical_transformer_spark_runner_lon" );

	level._effect[ "tread_dust_london_loop" ]					= LoadFX( "fx/treadfx/tread_dust_london_loop" );

	level._effect[ "cloud_ash_lite_london" ]					= LoadFX( "fx/weather/cloud_ash_lite_london" );
	level._effect[ "falling_dirt_frequent_runner" ]				= LoadFX( "fx/dust/falling_dirt_frequent_runner" );
	

	level._effect[ "fire_sprinkler" ]							= LoadFX( "fx/water/fire_sprinkler" );
	level._effect[ "fire_sprinkler_wide" ]						= LoadFX( "fx/water/fire_sprinkler_wide" );
	level._effect[ "water_pipe_spray_splash_z" ]				= LoadFX( "fx/water/water_pipe_spray_splash_z" );


	level._effect[ "dirt_kickup_hands" ]						= LoadFX( "fx/misc/dirt_kickup_hands" );
	level._effect[ "dirt_kickup_hands_light" ]					= LoadFX( "fx/misc/dirt_kickup_hands_light" );
	level._effect[ "dirt_kickup_head" ]							= LoadFX( "fx/misc/dirt_kickup_head" );

//	level._effect[ "heli_dust_poisonous_gas" ] 					= LoadFX( "fx/treadfx/heli_dust_poisonous_gas" );
//	level._effect[ "heli_dust_poisonous_gas_london" ]			= LoadFX( "fx/treadfx/heli_dust_poisonous_gas_london" );
//	level._effect[ "heli_dust_poisonous_gas_london2" ]			= LoadFX( "fx/treadfx/heli_dust_poisonous_gas_london2" );
	
	level._effect[ "glass_shatter_cone" ]						= LoadFX( "fx/misc/glass_shatter_cone" );

	level._effect[ "large_vehicle_explosion_london" ]			= LoadFX( "fx/explosions/large_vehicle_explosion_london" );
	
	level._effect[ "wood_barrier_debris" ]						= LoadFX( "fx/explosions/wood_barrier_debris" );
	
	level._effect[ "large_glass_london_kick" ]					= LoadFX( "fx/misc/large_glass_london_kick" );
	level._effect[ "med_glass_london_kick" ]					= LoadFX( "fx/misc/med_glass_london_kick" );
	
	level._effect[ "poison_gas_attack" ]						= LoadFX( "fx/smoke/poison_gas_attack" );
	
	
	level._effect[ "dirt_kickup_concrete_cylinder_loop" ]		= LoadFX( "fx/misc/dirt_kickup_concrete_cylinder_loop" );
	level._effect[ "dirt_kickup_concrete_cylinder" ]			= LoadFX( "fx/misc/dirt_kickup_concrete_cylinder" );
	
}
	
//treadfx_override()
//{
//	
//	flying_tread_fx_large = "fx/treadfx/heli_dust_poisonous_gas";
//	
//	maps\_treadfx::setvehiclefx( "pavelow", "brick", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "bark", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "carpet", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "cloth", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "concrete", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "dirt", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "flesh", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "foliage", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "glass", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "grass", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "gravel", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "ice", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "metal", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "mud", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "paper", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "plaster", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "rock", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "sand", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "snow", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "water", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "wood", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "asphalt", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "ceramic", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "plastic", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "rubber", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "cushion", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "fruit", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "painted metal", flying_tread_fx_large );
// 	maps\_treadfx::setvehiclefx( "pavelow", "default", flying_tread_fx_large );
//	maps\_treadfx::setvehiclefx( "pavelow", "none", flying_tread_fx_large );
//}

footstep_fx()
{
	animscripts\utility::setFootstepEffect( "asphalt", 	LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "brick", 	LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "concrete", LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "dirt", 	LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "mud", 		LoadFX( "fx/impacts/footstep_mud" ) );
	animscripts\utility::setFootstepEffect( "rock", 	LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "sand", 	LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffect( "water", 	LoadFX( "fx/impacts/footstep_water" ) );

	animscripts\utility::setFootstepEffectSmall( "asphalt", 	LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "brick", 		LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "concrete", 	LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "dirt", 		LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "mud", 		LoadFX( "fx/impacts/footstep_mud" ) );
	animscripts\utility::setFootstepEffectSmall( "rock", 		LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "sand", 		LoadFX( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setFootstepEffectSmall( "water", 		LoadFX( "fx/impacts/footstep_water" ) );
  
	//Other notetrack fx
	/*
	setNotetrackEffect( <notetrack>, <tag>, <surface>, <loadfx>, <sound_prefix>, <sound_suffix> )
		<notetrack>: name of the notetrack to do the fx/sound on
		<tag>: name of the tag on the AI to use when playing fx
		<surface>: the fx will only play when the AI is on this surface. Specify "all" to make it work for all surfaces.
		<loadfx>: load the fx to play here
		<sound_prefix>: when this notetrack hits a sound can be played. This is the prefix of the sound alias to play ( gets followed by surface type )
		<sound_suffix>: suffix of sound alias to play, follows the surface type. Example: prefix of "bodyfall_" and suffix of "_large" will play sound alias "bodyfall_dirt_large" when the notetrack happens on dirt.
	*/
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"dirt",		loadfx ( "fx/impacts/bodyfall_dust_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"concrete",	loadfx ( "fx/impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"asphalt",	loadfx ( "fx/impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	animscripts\utility::setNotetrackEffect( "bodyfall small", 		"J_SpineLower", 		"rock",		loadfx ( "fx/impacts/bodyfall_default_small_runner" ), "bodyfall_", "_small" );
	
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"dirt",		loadfx ( "fx/impacts/bodyfall_dust_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"concrete",	loadfx ( "fx/impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"asphalt",	loadfx ( "fx/impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	animscripts\utility::setNotetrackEffect( "bodyfall large", 		"J_SpineLower", 		"rock",		loadfx ( "fx/impacts/bodyfall_default_large_runner" ), "bodyfall_", "_large" );
	
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"dirt",		loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"concrete",	loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"asphalt",	loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"rock",		loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx left", 		"J_Knee_LE", 			"mud",		loadfx ( "fx/impacts/footstep_mud" ) );
	
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"dirt",		loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"concrete",	loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"asphalt",	loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"rock",		loadfx ( "fx/impacts/footstep_dust" ) );
	animscripts\utility::setNotetrackEffect( "knee fx right", 		"J_Knee_RI", 			"mud",		loadfx ( "fx/impacts/footstep_mud" ) );
}


notetrack_footstep_wrapper( foot, groundtype )
{
	if ( self is_touching_footstep_trigger() )
	{
//		print3d( self GetTagOrigin( foot ), "splash", ( 1, 1, 1 ), 1, 1, 5 );
		animscripts\notetracks::playFootStepEffect( foot, "water" );
		return true;
	}

	return false;
}
notetrack_footstep_small_wrapper( foot, groundtype )
{
	if ( self is_touching_footstep_trigger() )
	{
//		print3d( self GetTagOrigin( foot ), "splash_small", ( 1, 1, 1 ), 1, 1, 5 );
		animscripts\notetracks::playFootStepEffectSmall( foot, "water" );
		return true;
	}

	return false;
}

is_touching_footstep_trigger()
{
	foreach ( trigger in level.footstep_triggers ) 
	{
		if ( !IsDefined( trigger ) )
		{
			level.footstep_triggers = array_remove( level.footstep_triggers, trigger );
			continue;
		}

		if ( self IsTouching( trigger ) )
		{
			return true;
		}
	}

	return false;
}
