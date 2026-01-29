main()
{
//	level._effect[ "test_effect" ]										= loadfx( "fx/misc/moth_runner" );
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\so_stealth_prague_fx::main();
	
	maps\prague_fx::main();
	maps\createfx\prague_fx::main();

}
