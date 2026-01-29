// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{
	level.tweakfile = true;
	level.parse_fog_func = maps\createart\mp_dart_fog::main;

	setDevDvar( "scr_fog_disable", "0" );
//	setExpFog( 450, 5500, 0.716787, 0.70798, 0.530292, 2, 0.75, 0, 1, 0.789878, 0.568345, 1.70404, (-0.0711796, -0.983421, 0.166783), 20, 67, 1, 1, 40, 90 );
	VisionSetNaked( "mp_dart", 0 );
}
