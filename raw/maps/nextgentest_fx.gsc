main()
{
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\nextgentest_fx::main();
	
	//ambient fx
	level._effect[ "sand_storm_exterior_nextgentest" ]					= loadfx( "fx/weather/sand_storm_exterior_nextgentest" );
	level._effect[ "sand_storm_interior_nextgentest" ]					= loadfx( "fx/weather/sand_storm_interior_nextgentest" );
	level._effect[ "sand_storm_interior_outdoor_only_nextgentest" ]		= loadfx( "fx/weather/sand_storm_interior_outdoor_only_nextgentest" );
	level._effect[ "sand_spray_detail_runner_0x400_nextgentest" ]	 	= loadfx( "fx/dust/sand_spray_detail_runner_0x400_nextgentest" );
	level._effect[ "sand_spray_detail_runner_400x400_nextgentest" ]	 	= loadfx( "fx/dust/sand_spray_detail_runner_400x400_nextgentest" );
	level._effect[ "sand_spray_detail_oriented_runner_nextgentest" ]	= loadfx( "fx/dust/sand_spray_detail_oriented_runner_nextgentest" );
	level._effect[ "sand_spray_cliff_oriented_runner_nextgentest" ] 	= loadfx( "fx/dust/sand_spray_cliff_oriented_runner_nextgentest" );

	level._effect[ "hallway_smoke" ]							= loadfx( "fx/smoke/hallway_smoke_light" );
	level._effect[ "light_shaft_dust_large" ]					= loadfx( "fx/dust/light_shaft_dust_large" );	
	level._effect[ "room_dust_200" ]							= loadfx( "fx/dust/room_dust_200_blend" );	
	level._effect[ "room_dust_100" ]							= loadfx( "fx/dust/room_dust_100_blend" );	
	level._effect[ "battlefield_smokebank_S" ]					= loadfx( "fx/smoke/battlefield_smokebank_S" );
	level._effect[ "dust_ceiling_ash_large" ]					= loadfx( "fx/dust/dust_ceiling_ash_large" );
	level._effect[ "dust_wind_fast_paper" ]						= loadfx( "fx/dust/dust_wind_fast_paper" );
	level._effect[ "dust_wind_slow_paper" ]						= loadfx( "fx/dust/dust_wind_slow_paper" );
	level._effect[ "trash_spiral_runner" ]						= loadfx( "fx/misc/trash_spiral_runner" );
	level._effect[ "leaves_spiral_runner" ]						= loadfx( "fx/misc/leaves_spiral_runner" );
	level._effect[ "dust_ceiling_ash_large_mp_vacant" ]			= loadfx( "fx/dust/dust_ceiling_ash_large_mp_vacant" );
	level._effect[ "room_dust_200_mp_vacant" ]					= loadfx( "fx/dust/room_dust_200_blend_mp_vacant" );	
	level._effect[ "light_shaft_dust_large_mp_vacant" ]			= loadfx( "fx/dust/light_shaft_dust_large_mp_vacant" );	
	level._effect[ "light_shaft_dust_large_mp_vacant_sidewall" ] = loadfx( "fx/dust/light_shaft_dust_large_mp_vacant_sidewall" );	

	level._effect[ "insects_flies_wall_castle" ] = loadfx( "fx/animals/insects_flies_wall_castle" );
	level._effect[ "car_damaged_heat" ] = loadfx( "fx/distortion/car_damaged_heat" );
	level._effect[ "generator_heat" ] = loadfx( "fx/distortion/generator_heat" );
	level._effect[ "amb_dust_verylight_intro_house" ] = loadfx( "fx/dust/amb_dust_verylight_intro_house" );
	level._effect[ "bulb_single" ] = loadfx( "fx/lights/bulb_single" );
	level._effect[ "bulb_single_orange" ] = loadfx( "fx/lights/bulb_single_orange" );
	level._effect[ "dubai_lantern_lights_glow" ] = loadfx( "fx/lights/dubai_lantern_lights_glow" );
	level._effect[ "dubai_lights_atrium" ] = loadfx( "fx/lights/dubai_lights_atrium" );
	level._effect[ "dubai_lights_glow_white" ] = loadfx( "fx/lights/dubai_lights_glow_white" );
	level._effect[ "fluo_lightbeam" ] = loadfx( "fx/lights/fluo_lightbeam" );
	level._effect[ "car_taillight_suburban_l" ] = loadfx( "fx/lights/car_taillight_suburban_l" );
	level._effect[ "car_taillight_suburban_r" ] = loadfx( "fx/lights/car_taillight_suburban_r" );
	level._effect[ "dubai_lantern_lights_glow" ] = loadfx( "fx/lights/dubai_lantern_lights_glow" );
	level._effect[ "sand_blowing_rooftops" ] = loadfx( "fx/sand/sand_blowing_rooftops" );
	level._effect[ "amb_dust_veryLight" ] = loadfx( "fx/dust/amb_dust_veryLight" );
	level._effect[ "amb_dust_verylight_intro_windy_mist" ] = loadfx( "fx/dust/amb_dust_verylight_intro_windy_mist" );
	level._effect[ "dust_ground_gust_warm_runner" ] = loadfx( "fx/dust/dust_ground_gust_warm_runner" );

	

	
}
