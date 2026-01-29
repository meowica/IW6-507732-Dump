// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 	level.parse_fog_func = maps\createart\mp_snow_fog::main;

	//* Fog section * 

	setDevDvar( "scr_fog_disable", "0" );

	//setExpFog( 385, 2750, 0.549, 0.64, 0.778, 0.09, 0, 0.195, 0.213, 0.264, (0.00425573, 0.00323934, 1), 78.0987, 93.3811, 0.278491 );
	VisionSetNaked( "mp_snow", 0 );

}
