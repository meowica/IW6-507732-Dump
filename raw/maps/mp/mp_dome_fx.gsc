main()
{
	
	//ambient fx
	level._effect[ "sand_storm_light_outside" ]						= loadfx( "fx/weather/sand_storm_mp_dome_exterior" );
	level._effect[ "sand_storm_light_inside" ]						= loadfx( "fx/weather/sand_storm_mp_dome_interior" );
	level._effect[ "sand_storm_light_inside_outdoor_only" ]			= loadfx( "fx/weather/sand_storm_mp_dome_interior_outdoor_only" );
	level._effect[ "sand_spray_detail_runner0x400" ]	 	= loadfx( "fx/dust/sand_spray_detail_runner_0x400" );
	level._effect[ "sand_spray_detail_runner400x400" ]	 	= loadfx( "fx/dust/sand_spray_detail_runner_400x400" );
	level._effect[ "sand_spray_detail_oriented_runner_mp_dome" ]	= loadfx( "fx/dust/sand_spray_detail_oriented_runner_mp_dome" );
	level._effect[ "sand_spray_cliff_oriented_runner" ] 	= loadfx( "fx/dust/sand_spray_cliff_oriented_runner" );

	level._effect[ "hallway_smoke" ]							= loadfx( "fx/smoke/hallway_smoke_light" );
	level._effect[ "light_shaft_dust_large" ]					= loadfx( "fx/dust/light_shaft_dust_large" );	
	level._effect[ "room_dust_200" ]							= loadfx( "fx/dust/room_dust_200_blend" );	
	level._effect[ "room_dust_100" ]							= loadfx( "fx/dust/room_dust_100_blend" );	
	level._effect[ "battlefield_smokebank_S" ]					= loadfx( "fx/smoke/battlefield_smokebank_S" );
	level._effect[ "dust_ceiling_ash_large" ]					= loadfx( "fx/dust/dust_ceiling_ash_large" );
	level._effect[ "ash_spiral_runner" ]			 			= loadfx( "fx/dust/ash_spiral_runner" );
	level._effect[ "dust_wind_fast_paper" ]						= loadfx( "fx/dust/dust_wind_fast_paper" );
	level._effect[ "dust_wind_slow_paper" ]						= loadfx( "fx/dust/dust_wind_slow_paper" );
	level._effect[ "trash_spiral_runner" ]						= loadfx( "fx/misc/trash_spiral_runner" );
	level._effect[ "leaves_spiral_runner" ]						= loadfx( "fx/misc/leaves_spiral_runner" );
	level._effect[ "dust_ceiling_ash_large_mp_vacant" ]			= loadfx( "fx/dust/dust_ceiling_ash_large_mp_vacant" );
	level._effect[ "room_dust_200_mp_vacant" ]					= loadfx( "fx/dust/room_dust_200_blend_mp_vacant" );	
	level._effect[ "light_shaft_dust_large_mp_vacant" ]			= loadfx( "fx/dust/light_shaft_dust_large_mp_vacant" );	
	level._effect[ "light_shaft_dust_large_mp_vacant_sidewall" ] = loadfx( "fx/dust/light_shaft_dust_large_mp_vacant_sidewall" );	
	
	level._effect[ "falling_brick_runner" ]					= loadfx( "fx/misc/falling_brick_runner" );
	level._effect[ "falling_brick_runner_line_400" ]		= loadfx( "fx/misc/falling_brick_runner_line_400" );
	level._effect[ "firelp_med_pm" ]					 	= loadfx( "fx/fire/firelp_med_pm_nodistort" );
	level._effect[ "firelp_small_pm" ]				 		= loadfx( "fx/fire/firelp_small_pm" );
	
/#
    if ( getdvar( "clientSideEffects", "1" ) != "1" )
        maps\createfx\mp_dome_fx::main();
#/

}
