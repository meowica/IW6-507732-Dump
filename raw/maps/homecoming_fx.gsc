main()
{
	level._effect[ "vfx_hc_ocean_waves_blowoff" ] = loadfx( "vfx/ambient/water/vfx_hc_ocean_waves_blowoff" );
	level._effect[ "vfx_hc_ocean_waves_splash" ] = loadfx( "vfx/ambient/water/vfx_hc_ocean_waves_splash" );
	level._effect[ "smk_plume_black_xsml_hc" ] = loadfx( "vfx/ambient/smoke/smk_plume_black_xsml_hc" );
	level._effect[ "vfx_sparks_lights_hc" ] = loadfx( "vfx/ambient/sparks/vfx_sparks_lights_hc" );
	level._effect[ "vfx_smk_building_damage" ] = loadfx( "vfx/ambient/smoke/vfx_smk_building_damage" );
	level._effect[ "vfx_smk_vista_hc" ] = loadfx( "vfx/ambient/smoke/vfx_smk_vista_hc" );
	precacheFX();
	mortarFX();
	
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\homecoming_fx::main();
		maps\createfx\homecoming_sound::main();
	}
}

precacheFX()
{
	level._effect[ "drone_blood_impact" ]			= LoadFx( "vfx/gameplay/impacts/flesh/vfx_flesh_hit_body_enter" );
	
	level._effect[ "osprey_engine_explosion" ] 		= LoadFX( "fx/explosions/heli_engine_osprey_explosion" );
	level._effect[ "osprey_engine_trail" ] 			= LoadFx( "fx/fire/fire_smoke_trail_L" );
	level._effect[ "building_explosion" ] 			= LoadFX( "fx/explosions/building_explosion_huge_gulag" );
	level._effect[ "antiair_runner_flak_day" ] 		= LoadFX( "fx/misc/antiair_runner_flak_day" );
	level._effect[ "headshot_blood" ]				= LoadFx( "fx/impacts/flesh_hit_head_fatal_exit" );
	
	level._effect[ "house_hallway_explosion" ]		= LoadFx( "fx/explosions/wall_explosion_2_short" );
	
	level._effect[ "phalanx_tracer" ]				= LoadFx( "fx/misc/f15_20mm_tracer_close_ac130" );
	level._effect[ "phalanx_missile_explosion" ]	= LoadFx( "fx/explosions/aerial_explosion" );
	
	level._effect[ "tank_flash" ] 					= loadfx( "fx/muzzleflashes/abrams_flash_wv" );
	
	level._effect[ "smoke_grenade" ] 				= LoadFx( "fx/props/american_smoke_grenade_fast" );
	
	level._effect[ "javelin_muzzle" ] 				= loadfx( "fx/muzzleflashes/javelin_flash_wv" );
	level._effect[ "javelin_explosion" ] 			= loadfx( "fx/explosions/javelin_explosion" );
	level._effect[ "javelin_explosion_cheap" ] 		= loadfx( "fx/explosions/javelin_explosion_hamburg_cheap" );
	
	level._effect[ "chopper_flare" ]				= LoadFX( "fx/_requests/apache/apache_flare_ai" );
	level._effect[ "chopper_flare_explosion" ]		= LoadFX( "fx/_requests/apache/apache_trophy_explosion_ai" );
	
	level._effect[ "battleship_explosion" ]			= LoadFX( "fx/explosions/100ton_bomb" );
	
	level._effect[ "battleship_artillery_flash" ]	= LoadFX( "fx/_requests/homecoming/artillery_fire_flash" );
	level._effect[ "artillery_tracer" ]				= LoadFx( "fx/misc/105mm_tracer" );
	level._effect[ "artillery_trail" ]				= LoadFx( "fx/_requests/homecoming/artillery_tracer_trail" );
	level._effect[ "artillery_trail_2" ]			= LoadFx( "fx/fire/meteor_trail" );
	level._effect[ "artillery_wake" ]				= LoadFx( "fx/_requests/homecoming/artillery_tracer_wake" );
	level._effect[ "artillery_mist" ]				= LoadFx( "fx/_requests/homecoming/artillery_tracer_mist" );
	level._effect[ "artillery_explosion" ]			= LoadFx( "fx/explosions/mosque_impact_dirt" );
	
	level._effect[ "artillery_humvee_smoke_trail" ] = LoadFx( "fx/fire/fire_smoke_trail_L" );
	level._effect[ "artillery_shack_blowup" ]  	 	= LoadFx( "fx/explosions/wood_explosion_1" );
	level._effect[ "artillery_mg_blowup" ]  	 	= LoadFx( "fx/explosions/tank_concrete_explosion" );
	
	level._effect[ "hovercraft_smoke" ] 			= LoadFx( "fx/props/american_smoke_grenade_fast" );
	
	// A10 strafes
	level._effect[ "a10_sand_impact" ] 				= LoadFx( "fx/impacts/20mm_concrete_impact" );
	level._effect[ "a10_muzzle_flash" ] 			= LoadFx( "fx/_requests/homecoming/a10_muzzle_flash" );
	level._effect[ "a10_impact" ] 					= LoadFx( "fx/_requests/homecoming/a10_minigun_impact" );
	level._effect[ "a10_clouds" ] 					= LoadFx( "fx/weather/cloud_tunnel" );
	
	level._effect[ "a10_explosion" ] 				= loadfx( "fx/explosions/bomb_explosion_ac130_bombing_run_mega" );
	level._effect[ "a10_30mm_smoke" ]				= loadfx( "fx/smoke/smoke_trail_white_heli" );
	
	level._effect[ "flying_face_fx" ]				= loadfx( "fx/weather/flying_particulates" );
	
	// hovercraft sequence
	level._effect[ "trench_hovercraft_kickup" ]			= LoadFx( "vfx/moments/flood/rooftop1_heli_dust_kickup" );
	
	// tower sequence
	level._effect[ "tower_green_smoke" ]			= LoadFx( "fx/smoke/signal_smoke_green_2min" );
	
}

// MORTAR FX + SOUNDS
mortarFX()
{
	level._effect[ "mortar" ][ "sand" ]					= loadfx( "fx/explosions/mortarexp_mud" );
	level._effect[ "mortar" ][ "water" ]				= loadfx( "fx/explosions/mortarexp_water_lite" );
	
	level.scr_sound[ "mortar" ][ "incomming" ]				 = "mortar_incoming";
	level.scr_sound[ "mortar" ][ "dirt" ]					 = "mortar_explosion_dirt";
	level.scr_sound[ "mortar" ][ "sand" ]					 = "mortar_explosion_dirt";
	level.scr_sound[ "mortar" ][ "concrete" ]				 = "mortar_explosion_dirt";
	level.scr_sound[ "mortar" ][ "mud" ]					 = "mortar_explosion_dirt";
	level.scr_sound[ "mortar" ][ "water" ]					 = "mortar_explosion_water";	
}
