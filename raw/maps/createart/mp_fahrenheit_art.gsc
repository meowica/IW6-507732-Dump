// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{
	level.tweakfile = true;
	level.parse_fog_func = maps\createart\mp_fahrenheit_fog::main;

	setDevDvar( "scr_fog_disable", "0" );
//	setExpFog( 1500, 9016, 0.49, 0.47, 0.52, 1, 0.35, 0, 0.88, 0.71, 0.63, 1, (-0.9, 0.37, 0.26), 0, 77, 0.9, 0, 0, 0 );
	VisionSetNaked( "mp_fahrenheit", 0 );
}
