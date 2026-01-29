main()
{
	level._effect[ "test_effect" ]										 = loadfx( "fx/misc/moth_runner" );
	level._effect[ "ground_fog" ] 		     							 = loadfx( "fx/dust/ground_fog" );
	level._effect[ "amb_dust_hangar" ] 		     						 = loadfx( "fx/dust/amb_dust_hangar" );
	level._effect[ "dust_light_shaft" ] 		     					 = loadfx( "fx/dust/dust_light_shaft" );
	level._effect[ "hallway_smoke_light" ] 		     					 = loadfx( "fx/smoke/hallway_smoke_light" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
		maps\createfx\patriot_crib_proto_fx::main();
}
