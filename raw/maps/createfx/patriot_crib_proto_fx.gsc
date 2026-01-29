//_createfx generated. Do not touch!!
#include common_scripts\utility;
#include common_scripts\_createfx;
main()
{
	// CreateFX entities placed: 6
	ent = createLoopEffect( "hallway_smoke_light" );
	ent set_origin_and_angles( ( -750.18, 1036.97, 39.125 ), ( 0, 270, 89.9996 ) );

	ent = createLoopEffect( "dust_light_shaft" );
	ent set_origin_and_angles( ( -102.267, 544.362, 281.879 ), ( 330, 270.001, 89.9988 ) );

	ent = createLoopEffect( "dust_light_shaft" );
	ent set_origin_and_angles( ( 475.864, 503.171, 318.858 ), ( 330, 270.001, 89.9988 ) );

	ent = createLoopEffect( "hallway_smoke_light" );
	ent set_origin_and_angles( ( 601.425, 2086.26, 50.125 ), ( 1.2351, 107.959, -3.80464 ) );

	ent = createOneshotEffect( "test_effect" );
	ent set_origin_and_angles( ( 0, 0, 64 ), ( 270, 0, 0 ) );

	ent = createOneshotEffect( "amb_dust_hangar" );
	ent set_origin_and_angles( ( -505.326, 1047.54, 222.115 ), ( 270, 0, 0 ) );

}
 
