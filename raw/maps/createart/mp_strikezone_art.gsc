// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{
	level.tweakfile = true;
	level.parse_fog_func = maps\createart\mp_strikezone_fog::main;
	//* Fog section * 
	//	setDevDvar( "scr_fog_disable", "0" );

  	//setExpFog( 528.898, 9881.64, 0.701961, 0.745098, 0.796079, 0.689305, 1, 0.84, 0.74, 0.59, (-0.27, -0.86, 0.40), 38, 60, 0.85 );
	//	VisionSetNaked( "mp_strikezone", 0 );

	setDevDvar( "scr_fog_disable", "0" );

	setExpFog( 528.898, 9881.64, 0.8, 0.878431, 1, 4, 0.25, 0, 0.75, 0.75, 0.744141, 1.25, (-0.27, -0.86, 0.40), 0, 100, 1.0625 );
	VisionSetNaked( "mp_strikezone", 0 );

}
	