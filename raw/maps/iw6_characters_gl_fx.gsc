main()
{
	//ambient fx
	level._effect[ "test_effect" ]					= loadfx( "fx/misc/moth_runner" );
    level._effect[ "sand_blowing_flat_runner" ]		= loadfx( "fx/sand/sand_blowing_flat_runner" );
	level._effect[ "nextgen_test_trash_runner" ]	= loadfx( "fx/misc/nextgen_test_trash_runner" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\iw6_characters_gl_fx::main();
		maps\createfx\iw6_characters_gl_sound::main();
	}
}