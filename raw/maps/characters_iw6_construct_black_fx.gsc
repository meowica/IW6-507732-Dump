main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\characters_iw6_construct_black_fx::main();
		maps\createfx\characters_iw6_construct_black_sound::main();
	}
}
