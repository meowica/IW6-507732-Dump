main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\iw6_vehicles_fx::main();
		maps\createfx\iw6_vehicles_sound::main();
	}
}
