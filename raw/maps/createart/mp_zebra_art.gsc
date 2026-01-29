// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{
	level.tweakfile = true;
	level.parse_fog_func = maps\createart\mp_zebra_fog::main;

	setDevDvar( "scr_fog_disable", "0" );
//	setExpFog( 26.5524, 5027.08, 0.499583, 0.501709, 0.524027, 1, 0.75, 0, 0.851563, 0.724327, 0.612061, 3, (-0.252709, 0.835087, 0.488638), 7, 30, 1, 0.15625, 0, 90 );
	VisionSetNaked( "mp_zebra", 0 );
}
