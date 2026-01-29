// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 	level.parse_fog_func = maps\createart\mp_flooded_fog::main;

	//* Fog section * 

	setDevDvar( "scr_fog_disable", "1" );

	VisionSetNaked( "mp_flooded", 0 );

}
