main()
{
	level._effect[ "test_effect" ]										 = loadfx( "fx/misc/moth_runner" );
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\iw5_characters_fx::main();
}
