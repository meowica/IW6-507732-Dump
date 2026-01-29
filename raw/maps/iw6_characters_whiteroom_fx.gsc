main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\iw6_characters_whiteroom_fx::main();
		maps\createfx\iw6_characters_whiteroom_sound::main();
	}
}
