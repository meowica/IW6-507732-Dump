main()
{
	
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\deer_hunt_fx::main();
		maps\createfx\deer_hunt_sound::main();
	}
	
	level_fx();
}


level_fx()
{
	level._effect[ "flare" ] = LoadFX( "fx/misc/flare_ambient_prague" );
	
	level._effect[ "light1" ] = LoadFX( "fx/misc/docks_heli_spotlight_model_cheap" );
	level._effect[ "light2" ] = LoadFX( "fx/misc/hunted_spotlight_model" );
	level._effect[ "light3" ] = LoadFX( "fx/_requests/deer_hunt/flashlight_spotlight" );
	
	level._effect[ "flashlight" ]		 = LoadFX( "fx/misc/flashlight_spotlight_paris" );
	level._effect[ "flashlight_bounce" ] = LoadFX( "fx/misc/flashlight_pointlight_paris" );
	
	level._effect[ "water_stop"		 ] = LoadFX( "fx/water/player_water_wake" );
	level._effect[ "water_movement" ]  = LoadFX( "fx/maps/warlord/warlord_water_stop" );
	
	level._effect[ "wall_kick_impact_deer_hunt" ] = loadfx( "vfx/_requests/deer_hunt/wall_kick_impact_deer_hunt" );
	level._effect[ "green_smoke" ] = loadfx( "fx/smoke/signal_smoke_green" );
	
}
