main()
{
	level._effect["birds_circle_main"]							= loadfx( "fx/misc/birds_circle_main" );
	level._effect["water_wave_splash2_runner"] 					= loadfx("fx/water/water_wave_splash2_runner");	
	level._effect["water_shore_splash_xlg_r"] 					= loadfx("fx/water/water_shore_splash_xlg_r");	
	level._effect["water_wave_splash_xsm_runner"] 				= loadfx("fx/water/water_wave_splash_xsm_runner");	
	level._effect["water_shore_splash_r"] 						= loadfx("fx/water/water_shore_splash_r");	
	level._effect["mist_light"] 								= loadfx("fx/water/mist_light");	
	level._effect["fog_aground"] 								= loadfx("fx/weather/fog_aground");	
	
	level._effect["drips_slow"] 								= loadfx("fx/misc/drips_slow");	
	level._effect["mp_cw_insects"] 								= loadfx("maps/mp_crosswalk_ss/mp_cw_insects");	
	level._effect["fog_bog_c"] 									= loadfx("fx/weather/fog_bog_c");	
	level._effect["falling_dirt_infrequent_runner_mp"] 						= loadfx("fx/dust/falling_dirt_infrequent_runner_mp");	
	level._effect["godrays_aground"] 							= loadfx("fx/lights/godrays_aground");	
	level._effect["godrays_aground_b"] 							= loadfx("fx/lights/godrays_aground_b");	
	level._effect["tinhat_beam"] 								= loadfx("fx/lights/tinhat_beam");	
	level._effect["bulb_single_orange"] 						= loadfx("fx/lights/bulb_single_orange");	
	level._effect["light_dust_motes_fog"] 						= loadfx("maps/mp_overwatch/light_dust_motes_fog");	
	level._effect["paper_blowing_trash_r_frequent"] 			= loadfx("fx/misc/paper_blowing_trash_r_frequent");
	level._effect["rain_mp_bootleg"] 							= loadfx("fx/weather/rain_mp_bootleg");	
	
/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_zebra_fx::main();
#/

}
