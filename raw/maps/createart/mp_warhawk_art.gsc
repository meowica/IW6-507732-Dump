// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{
	level.tweakfile = true;
	level.parse_fog_func = maps\createart\mp_warhawk_fog::main;
	//* Fog section * 
	setDevDvar( "scr_fog_disable", "0" );
//	setExpFog( 528.898, 9881.64, 0.0992, 0.0791, 0.0711, 0.527032, 0, 0.799307, 0.839089, 0.851217, (-0.408368, 0.855313, 0.318866), 0, 44.3857, 0.26224 );

	//setExpFog( 200, 7500, 0.70, 0.57, 0.45, 0.8, 0, 0.24, 0.15, 0.12, (0.57, 0.35, 0.29), 0, 108, .8 );
	VisionSetNaked( "mp_warhawk", 0 );

}
