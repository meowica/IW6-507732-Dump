main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\iw6_characters_fx::main();
		maps\createfx\iw6_characters_sound::main();
	}
}
