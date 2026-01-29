// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
 	level.parse_fog_func = maps\createart\mp_frag_fog::main;

	//* Fog section * 

	setDevDvar( "scr_fog_disable", "0" );

	//setExpFog( 1500, 6146, 0.8, 0.878431, 1, 4, 0.25, 0, 0.75, 0.75, 0.744141, 1.25, (0.41704, 0.894594, 0.160562), 0, 100, 1.0625 );
	VisionSetNaked( "mp_frag", 0 );

}
