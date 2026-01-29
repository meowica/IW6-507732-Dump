main()
{
	level._effect[ "rain_drizzle" ] 													= loadfx( "vfx/moments/fahrenheit/rain_drizzle" );
	level._effect[ "vfx_glowstick" ] 													= loadfx( "vfx/moments/fahrenheit/vfx_glowstick" );
	level._effect[ "vfx_stairwell_fallingwater" ] 										= loadfx( "vfx/moments/fahrenheit/vfx_stairwell_fallingwater" );
	level._effect[ "vfx_fire_barrel_small_light" ] 										= loadfx( "vfx/ambient/fire/vfx_fire_barrel_small_light" );
	level._effect[ "birds_tropical_panicked" ] 											= loadfx( "fx/maps/mp_fahrenheit/birds_tropical_panicked" );
	level._effect[ "mp_fh_hole_splash" ] 												= loadfx( "fx/maps/mp_fahrenheit/mp_fh_hole_splash" );
	level._effect[ "carrier_deck_water_slide" ] 										= loadfx( "fx/water/carrier_deck_water_slide" );
	level._effect[ "mp_fh_rain_storm" ] 												= loadfx( "fx/maps/mp_fahrenheit/mp_fh_rain_storm" );
	level._effect[ "mp_fh_godray_thin" ] 												= loadfx( "fx/maps/mp_fahrenheit/mp_fh_godray_thin" );
	level._effect[ "mp_fh_godraylarge" ] 												= loadfx( "fx/maps/mp_fahrenheit/mp_fh_godraylarge" );
	level._effect[ "water_bubbles" ]		                                           	= loadfx( "fx/water/bubble_trail01" );
	level._effect[ "water_wake" ]			                                            = loadfx( "fx/water/player_water_wake" );
	level._effect[ "water_splash_emerge" ]	                                       		= loadfx( "fx/water/zodiac_splash_bounce_small" );
	level._effect[ "water_splash_enter" ]	                                        	= loadfx( "fx/water/body_splash" );
																																																																																																																																																																																																																				
	
		//ambient fx
    level._effect[ "room_dust_200_mp_vacant_light" ]							        = loadfx( "fx/dust/room_dust_200_blend_mp_vacant_light" );	
    level._effect[ "insects_carcass_flies" ] 		      						        = loadfx( "fx/misc/insects_carcass_flies" );	
	level._effect[ "rain_mp_bootleg" ]								                    = loadfx( "fx/weather/rain_mp_bootleg" );
	level._effect[ "rain_noise_splashes" ]			                                    = loadfx( "fx/weather/rain_noise_splashes" );
	level._effect[ "rain_splash_lite_64x64" ]			                                = loadfx( "fx/weather/rain_splash_lite_64x64" );
	level._effect[ "water_drips_fat_fast_speed" ]			                            = loadfx( "fx/water/water_drips_fat_fast_speed" );
	level._effect[ "ground_steam" ] 		                                            = loadfx( "fx/smoke/ground_steam_fh" );
	level._effect[ "rain_fahrenheit_indoor" ]								            = loadfx( "fx/weather/rain_fahrenheit_indoor" );
	level._effect[ "lightning_mp_storm" ]								                = loadfx( "fx/weather/lightning_mp_storm" );
	level._effect[ "flood_splash_fahrenheit" ]			                                = loadfx( "fx/water/flood_splash_fahrenheit" );	
	
	

/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_fahrenheit_fx::main();
#/

}
