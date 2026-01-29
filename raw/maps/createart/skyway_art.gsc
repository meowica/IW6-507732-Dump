// _createart generated.  modify at your own risk. Changing values should be fine.
main()
{

	level.tweakfile = true;
	level.player = GetEntArray( "player", "classname" )[0];
	maps\createart\skyway_fog::main();
	thread maps\skyway_util::dynamic_sun_sample_size();

}

