main()
{
	level._effect[ "test_effect" ]										 = loadfx( "fx/misc/moth_runner" );
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\iw6_character_raven_fx::main();
}
