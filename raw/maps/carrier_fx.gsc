#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_weather;

main()
{		
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\carrier_fx::main();
		maps\createfx\carrier_sound::main();
	}
	
	//common
	level._effect[ "flesh_hit" ]		  = LoadFX( "fx/impacts/flesh_hit" );
	level._effect[ "impact_spark_large" ] = LoadFX( "fx/impacts/impact_spark_large" );
	
	//Water
	level._effect[ "water_splash_large_eiffel_tower_bigger" ] = LoadFX( "fx/water/water_splash_large_eiffel_tower_bigger" );
	level._effect[ "water_pipe_gush_md" ]					  = LoadFX( "fx/water/water_pipe_gush_md" );
	level._effect[ "water_wake_lg" ]						  = LoadFX( "fx/water/water_wake_lg" );					   //carrier wake
	level._effect[ "ny_dvora_wakebow_chback" ]				  = LoadFX( "fx/maps/ny_harbor/ny_dvora_wakebow_chback" ); //ships front wake
	level._effect[ "splash_flood_surface_small" ]			  = LoadFX( "fx/water/splash_flood_surface_small" );	   //surface splash effect
	
	//blackhawk
	level._effect[ "minigun_projectile" ] = LoadFX( "fx/misc/minigun_projectile" );
	level._effect[ "a10_shells" ]		  = LoadFX( "fx/shellejects/a10_shell" );
	
	//zodiac
	level._effect[ "zodiac_wake_geotrail" ]		 = LoadFX( "fx/treadfx/zodiac_wake_geotrail_harbor" );
	
	//explosions
	level._effect[ "building_explosion_mega_gulag" ]   = LoadFX( "fx/explosions/building_explosion_mega_gulag" );
	level._effect[ "breach_door_metal"			 ]	   = LoadFX( "fx/explosions/breach_door_metal" );
	level._effect[ "vehicle_explosion_mig29"	 ]	   = LoadFX( "fx/explosions/vehicle_explosion_mig29" );
	level._effect[ "vehicle_explosion_pickuptruck"	 ] = LoadFX( "fx/explosions/vehicle_explosion_pickuptruck" );
	level._effect[ "FX_mig29_air_explosion"		 ]	   = LoadFX( "fx/explosions/aerial_explosion_mig29" );
	level._effect[ "FX_mig29_on_fire"			 ]	   = LoadFX( "fx/fire/jet_on_fire" );
	level._effect[ "smoke_blow_1"	 ]				   = LoadFX( "fx/explosions/jet_crash_smoke_blow_1" );
	level._effect[ "aerial_explosion_hind_woodland" ]  = LoadFX( "fx/explosions/aerial_explosion_hind_woodland" );
	
	//naval battle
	level._effect[ "ny_harbor_navalgunfirerunner" ]		  = LoadFX( "fx/misc/ny_harbor_navalgunfirerunner" );				  //generic explosion
	level._effect[ "battleship_flash_large_withmissile" ] = LoadFX( "fx/maps/ny_harbor/battleship_flash_large_withmissile" ); //ship to ship shots
	level._effect[ "antiair_runner" ]					  = LoadFX( "fx/misc/antiair_runner_flak" );						  //phalanx
	level._effect[ "thick_dark_smoke_giant" ]			  = LoadFX( "fx/smoke/thick_dark_smoke_giant_nyharbor" );			  //giant smoke plume for ship
	level._effect[ "ny_harbor_waterbarrage" ]			  = LoadFX( "fx/water/ny_harbor_waterbarrage" );					  //multiple water splashes w/ tracers
	level._effect[ "battlefield_smokebank_large" ]		  = LoadFX( "fx/smoke/battlefield_smokebank_large" );				  //white clouds/fog patches - put in vista
	level._effect[ "smoke_geotrail_ssnMissile12_trail" ]  = LoadFX( "fx/smoke/smoke_geotrail_ssnMissile12_trail" );			  //trail - must be moved
	level._effect[ "ny_battleship_explosion" ]			  = LoadFX( "fx/maps/ny_harbor/ny_battleship_explosion" );			  //ship explosion
		
		//fire
	level._effect[ "window_fire_large" ]			 = LoadFX( "fx/fire/window_fire_large" );
	level._effect[ "window_fire_large_short_smoke" ] = LoadFX( "fx/fire/window_fire_large_short_smoke" );
	level._effect[ "burning_oil_slick_1" ]			 = LoadFX( "fx/fire/burning_oil_slick_1" );
	level._effect[ "fire_line_sm" ]					 = LoadFX( "fx/fire/fire_line_sm" );
	
	//smoke
	level._effect[ "hangar_smoke" ]				  = LoadFX( "fx/maps/castle/castle_amb_smoke" );
	level._effect[ "smoke_fill_vault" ]			  = LoadFX( "fx/smoke/smoke_fill_vault" );
	level._effect[ "steam_large" ]				  = LoadFX( "fx/smoke/steam_large_vent" );
	level._effect[ "steam_fading" ]				  = LoadFX( "fx/smoke/steam_large_vent_shaft" );
	level._effect[ "steam_cloud" ]				  = LoadFX( "fx/smoke/steam_room_add_large" );
	level._effect[ "building_collapse_smoke_lg" ] = LoadFX( "fx/smoke/building_collapse_smoke_lg" );
	level._effect[ "smoke_plume_black_01" ]		  = LoadFX( "fx/smoke/smoke_plume_black_01" );
	level._effect[ "signal_smoke_green" ]		  = LoadFX( "fx/smoke/signal_smoke_green" );
	
	//muzzleflash
	level._effect[ "missile_flash_wv_cheap" ] = LoadFX( "fx/muzzleflashes/missile_flash_wv_cheap" );
	
	
	/* ROG */
	//sky flare
	level._effect[ "rog_flash_odin" ] = LoadFX( "vfx/moments/odin/rog_flash_odin" );
	level._effect[ "dcemp_sun" ]	  = LoadFX( "fx/misc/dcemp_sun" );
	level._effect[ "vfx_lens_flare" ] = LoadFX( "vfx/moments/cornered/vfx_lens_flare" );	
	//sky vortex / water shockwave
	level._effect[ "vfx_rog_shockwave_loki" ]  = LoadFX( "vfx/moments/loki/vfx_rog_shockwave_loki" );	 //shockwave ring
	level._effect[ "sw_rog_strike_shockwave" ] = LoadFX( "vfx/moments/skyway/sw_rog_strike_shockwave" ); //cloud ring
	level._effect[ "clouds_cumulus_far" ]	   = LoadFX( "fx/misc/clouds_cumulus_far" );
	level._effect[ "clouds_moving" ]		   = LoadFX( "fx/weather/clouds_moving" );	
	//sky flashes
	level._effect[ "lightning_cloud_a_persona_mp" ] = LoadFX( "fx/weather/lightning_cloud_a_persona_mp" );
	level._effect[ "aa_explosion_clouds" ]			= LoadFX( "fx/explosions/aa_explosion_clouds" );
	//projectile/explosion
	level._effect[ "sw_rog_strike_huge_tail" ]	 = LoadFX( "vfx/moments/skyway/sw_rog_strike_huge_tail" );
	level._effect[ "sw_rog_strike_huge_impact" ] = LoadFX( "vfx/moments/skyway/sw_rog_strike_huge_impact" );
	level._effect[ "sw_rog_strike_big_tail" ]	 = LoadFX( "vfx/moments/skyway/sw_rog_strike_big_tail" );
	level._effect[ "sw_rog_strike_big_impact" ]	 = LoadFX( "vfx/moments/skyway/sw_rog_strike_big_impact" );
	//rod of god deck impact
	level._effect[ "cloud_ash_lite_nyHarbor" ]	  = LoadFX( "fx/weather/cloud_ash_lite_nyHarbor" );
	level._effect[ "firelp_large_pm_carrier" ]	  = LoadFX( "fx/fire/firelp_large_pm_carrier" );
	level._effect[ "fire_large_insideexplosion" ] = LoadFX( "fx/maps/carrier/fire_large_insideexplosion" );
	level._effect[ "firelp_small_pm" ]			  = LoadFX( "fx/fire/firelp_small_pm" );
	level._effect[ "fire_decal" ]				  = LoadFX( "fx/maps/carrier/fire_decal" );
	
	
	/* TILT */
	//jet slide
	level._effect[ "spark_runner"					 ] = LoadFX( "fx/maps/carrier/spark_runner" );
	level._effect[ "tread_skid"						 ] = LoadFX( "fx/maps/carrier/tread_skid" );
	level._effect[ "ac130_40mm_impact_water_drkblue" ] = LoadFX( "fx/impacts/ac130_40mm_impact_water_drkblue" );
	
	//helicopter explosion
	level._effect[ "helicopter_explosion_hind_chernobyl" ] = LoadFX( "fx/explosions/helicopter_explosion_hind_chernobyl" );
	level._effect[ "fire_runner"						 ] = LoadFX( "fx/maps/carrier/fire_runner" );
	level._effect[ "metal_impacts"						 ] = LoadFX( "fx/maps/carrier/metal_impacts" );
	
	//waves
	level._effect[ "water_wave_lg_r" ]			   = LoadFX( "fx/maps/carrier/water_wave_lg_r" );
	level._effect[ "sub_tail_foam_r" ]			   = LoadFX( "fx/water/sub_tail_foam_r" );
	level._effect[ "carrier_deck_water_slide" ]	   = LoadFX( "fx/water/carrier_deck_water_slide" );
	level._effect[ "sub_surface_runner_sm" ]	   = LoadFX( "fx/water/sub_surface_runner_sm" );
	level._effect[ "fx_splash_carrier_side_xlg"	 ] = LoadFX( "fx/maps/carrier/fx_splash_carrier_side_xlg" );
	
	//rain for post-rod impact
	level._effect[ "rain_0"	 ] = LoadFX( "vfx/ambient/misc/no_effect" );
	level._effect[ "rain_1"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_2"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_3"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_4"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_5"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_6"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_7"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_8"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_9"	 ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	level._effect[ "rain_10" ] = LoadFX( "vfx/_requests/carrier/temp_rain" );
	
	/*level._effect[ "rain_0"	 ] = loadfx( "vfx/ambient/misc/no_effect" );
	level._effect[ "rain_1"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_1" );
	level._effect[ "rain_2"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_1" );
	level._effect[ "rain_3"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_1" );
	level._effect[ "rain_4"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_5" );
	level._effect[ "rain_5"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_5" );
	level._effect[ "rain_6"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_5" );
	level._effect[ "rain_7"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_8" );
	level._effect[ "rain_8"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_8" );
	level._effect[ "rain_9"	 ]	   = loadfx( "vfx/ambient/weather/rain/rain_10" );
	level._effect[ "rain_10" ]	   = loadfx( "vfx/ambient/weather/rain/rain_10" );*/

	thread rainInit( "none" ); // "none" "light" or "hard"
	thread car_playerWeather();	// make the actual rain effect generate around the player
}

car_playerWeather()
{
	player = getentarray( "player", "classname" )[ 0 ];
	for ( ;; )
	{
		playfx( level._effect[ "rain_drops" ], player.origin + ( 0, 0, 1200 ), ( 0, 0, -1 ) );
		wait( 0.3 );
	}
}

fx_init()
{
	SetSavedDvar( "fx_alphathreshold", 9 );
	thread heli_ride_fx();
	thread defend_sparrow_fx();
}

heli_ride_fx()
{
	thread heli_ride_big_splashes();
	thread heli_ride_multi_splashes();
	thread heli_ride_tracers();
	thread heli_ride_smoke();
	thread heli_ride_ship_explosions();
}

heli_ride_big_splashes()
{
	flag_wait( "heli_ride_big_turn" );
	fx_array = getstructarray ("heli_ride_big_splash_fx_10", "targetname" );
	foreach ( fx in fx_array )
	{
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), fx.origin );
		wait 1.5;
	}
	
	flag_wait( "minigun_redshirt_dies" );
	wait 2;
	fx_array = getstructarray ("heli_ride_big_splash_fx_20", "targetname" );
	foreach ( fx in fx_array )
	{
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), fx.origin );
		wait RandomFloatRange( 1, 4 );
	}	
	
	flag_wait ("heli_ride_water_combat_2" );
	fx_array = getstructarray ("heli_ride_big_splash_fx_30", "targetname" );
	foreach ( fx in fx_array )
	{
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), fx.origin );
		wait 0.5;
	}	
	
	flag_wait ("heli_ride_heli_combat" );
	fx_array = getstructarray ("heli_ride_big_splash_fx_40", "targetname" );
	foreach ( fx in fx_array )
	{
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), fx.origin );
		wait RandomFloatRange( 2, 4 );
	}		
	
	flag_wait ("heli_ride_sparrow_down" );
	fx_array = getstructarray ("heli_ride_big_splash_fx_50", "targetname" );
	foreach ( fx in fx_array )
	{
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), fx.origin );
		wait RandomFloatRange( 2, 4 );
	}				
}

heli_ride_multi_splashes()
{
	flag_wait( "minigun_redshirt_dies" );
	
	fx = getstruct ("heli_ride_multi_splash_fx_10", "targetname" );
	thread playfx_endon( level._effect[ "ny_harbor_waterbarrage" ], fx.origin, (0,0,0), "heli_ride_finished" );
	
	fx = getstruct ("heli_ride_multi_splash_fx_20", "targetname" );
	thread playfx_endon( level._effect[ "ny_harbor_waterbarrage" ], fx.origin, (0,0,0), "heli_ride_finished" );
}



heli_ride_tracers()
{
	flag_wait( "minigun_redshirt_dies" );
	fx_array = getstructarray ("heli_ride_tracers", "targetname" );
	foreach ( fx in fx_array )
	{
		thread playfx_endon( level._effect[ "antiair_runner" ], fx.origin, (-90,0,0), "heli_ride_finished" );
	}	
}

heli_ride_smoke()
{
	
	flag_wait ("heli_ride_big_turn" );
	fx_array = getstructarray ("heli_ride_smoke_10", "targetname" );
	foreach ( fx in fx_array )
	{	
		thread playfx_endon( level._effect[ "battlefield_smokebank_large" ], fx.origin, (0,0,0), "heli_ride_finished" );
	}
}

heli_ride_ship_explosions()
{
	flag_wait( "minigun_redshirt_dies" );
	fx_array = getstructarray ("heli_ride_ship_explosion_10", "targetname" );
	foreach ( fx in fx_array )
	{
		playfx( getfx( "ny_battleship_explosion" ), fx.origin );
		wait RandomFloatRange( 3, 5 );
	}	
		
	flag_wait( "heli_ride_water_combat_2" );
	//reuse explosion_10 for now
	fx_array = getstructarray ("heli_ride_ship_explosion_10", "targetname" );
	foreach ( fx in fx_array )
	{
		playfx( getfx( "ny_battleship_explosion" ), fx.origin );
		wait RandomFloatRange( 3, 5 );
	}		
}

defend_sparrow_fx()
{
	thread defend_sparrow_ships();
}

defend_sparrow_ships()
{
	level endon( "defend_sparrow_finished" );
	flag_wait( "defend_sparrow_start" );
	
	while ( 1 )
	{
		fx_array = getstructarray ( "defend_sparrow_ship_missiles", "targetname" );
		foreach ( fx in fx_array )
		{
			playfx( getfx( "battleship_flash_large_withmissile" ), fx.origin, AnglesToForward( fx.angles ) );
			wait RandomFloatRange( 1, 3 );
		}		
	}
}

playfx_endon( fx, origin, angles, endon_flag )
{
	tag		   = spawn_tag_origin();
	tag.origin = origin;
	tag.angles = angles;
	PlayFXOnTag( fx, tag, "tag_origin" );	
	flag_wait( endon_flag );
	StopFXOnTag( fx, tag, "tag_origin" );
}

tilt_jet_a_fx( flagname )
{
	flag_wait( flagname );
	
	PlayFXOnTag( level._effect[ "tread_skid" ], self, "fx_right_rear_wheel" );
	
	self waittillmatch( "single anim", "fx_note_1" );
	PlayFXOnTag( level._effect[ "spark_runner" ], self, "fx_nose" );
	
	self waittillmatch( "single anim", "fx_note_2" );
	PlayFXOnTag( level._effect[ "spark_runner" ], self, "fx_missle_a" );
	PlayFXOnTag( level._effect[ "spark_runner" ], self, "fx_missle_b" );
	PlayFXOnTag( level._effect[ "spark_runner" ], self, "fx_missle_c" );
	PlayFXOnTag( level._effect[ "spark_runner" ], self, "fx_engine" );
	PlayFXOnTag( level._effect[ "spark_runner" ], self, "fx_underside" );
	
	self waittillmatch( "single anim", "fx_note_3" );
	PlayFXOnTag( level._effect[ "tread_skid" ], self, "fx_left_rear_wheel" );

	self waittillmatch( "single anim", "fx_note_4" );
	PlayFXOnTag( level._effect[ "ac130_40mm_impact_water_drkblue" ], self, "fx_engine" );
	
	StopFXOnTag( level._effect[ "tread_skid" ], self, "fx_right_rear_wheel" );
	StopFXOnTag( level._effect[ "tread_skid" ], self, "fx_left_rear_wheel" );
	
	waitframe();
	
	StopFXOnTag( level._effect[ "spark_runner" ], self, "fx_nose" );
	StopFXOnTag( level._effect[ "spark_runner" ], self, "fx_missle_a" );
	StopFXOnTag( level._effect[ "spark_runner" ], self, "fx_missle_b" );
	
	waitframe();
	
	StopFXOnTag( level._effect[ "spark_runner" ], self, "fx_missle_c" );
	StopFXOnTag( level._effect[ "spark_runner" ], self, "fx_engine" );
	StopFXOnTag( level._effect[ "spark_runner" ], self, "fx_underside" );
	
}

tilt_jet_c_fx( flagname )
{
	flag_wait( flagname );
	
	self waittillmatch( "single anim", "fx_note_1" );
	PlayFXOnTag( level._effect[ "tread_skid" ], self, "fx_left_rear_wheel" );
	PlayFXOnTag( level._effect[ "tread_skid" ], self, "fx_right_rear_wheel" );

	self waittillmatch( "single anim", "fx_note_2" );
	PlayFXOnTag( level._effect[ "tread_skid" ], self, "front_wheel_jnt" );

	self waittillmatch( "single anim", "fx_note_3" );
	PlayFXOnTag( level._effect[ "ac130_40mm_impact_water_drkblue" ], self, "TAG_ENGINE_LEFT" );
	
	StopFXOnTag( level._effect[ "tread_skid" ], self, "fx_right_rear_wheel" );
	StopFXOnTag( level._effect[ "tread_skid" ], self, "fx_left_rear_wheel" );
	StopFXOnTag( level._effect[ "tread_skid" ], self, "front_wheel_jnt" );
}

tilt_chopper_fx( flagname )
{
	flag_wait( flagname );
	
	// Waiting for notifies
	self waittillmatch( "single anim", "fx_note_explosion" );
	PlayFXOnTag( level._effect[ "helicopter_explosion_hind_chernobyl" ], self, "main_rotor_jnt_blur" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "b_l_missle_pod_2" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "b_l_missle_pod_1" );
	
	self waittillmatch( "single anim", "tail_sparks" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_fx_tail_1" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_fx_tail_2" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_fx_tail_3" );
	
	self waittillmatch( "single anim", "chopper_hit_1" );
	PlayFXOnTag( level._effect[ "metal_impacts" ], self, "tag_fx_body_1" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_fx_body_1" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_fx_wheel" );
	
	self waittillmatch( "single anim", "pod_hit_3" );
	PlayFXOnTag( level._effect[ "metal_impacts" ], self, "b_r_missle_pod" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "b_r_missle_pod" );
	
	self waittillmatch( "single anim", "pod_hit_1" );
	PlayFXOnTag( level._effect[ "metal_impacts" ], self, "tag_missle_wing_3" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_missle_wing_3" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_missle_wing_4" );
	
	self waittillmatch( "single anim", "pod_hit_2" );
	PlayFXOnTag( level._effect[ "metal_impacts" ], self, "tag_missle_wing_1" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_missle_wing_1" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_missle_wing_2" );
	
	self waittillmatch( "single anim", "chopper_hit_2" );
	PlayFXOnTag( level._effect[ "fire_runner" ], self, "tag_fx_body_2" );
}
