main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\prologue_fx::main();
		maps\createfx\prologue_sound::main();

		// This gets called from Odin createFX main and Youngblood createFX main
		//maps\createfx\youngblood_fx::main();
		//maps\createfx\odin_fx::main();
	}
}
