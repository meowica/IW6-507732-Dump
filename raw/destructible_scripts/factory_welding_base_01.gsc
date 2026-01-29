#include common_scripts\_destructible;

main()
{
	destructible_create( "factory_welding_base_01", "tag_origin", 200, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 12 );
			destructible_loopfx( "tag_fx", "vfx/moments/factory/factory_base_top_smoke_01", 0.5 );
		destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
			destructible_loopfx( "tag_fx", "vfx/moments/factory/factory_base_top_smoke_02", 0.4 );
		destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
			destructible_healthdrain( 16, 0.2 );
			destructible_loopfx( "tag_fx", "vfx/moments/factory/factory_base_top_sparks_runner", 0.5 );
			destructible_fx( "tag_fx", "vfx/moments/factory/factory_base_top_explosion_runner" );
		destructible_state( undefined, undefined, 600, undefined, 32, "no_melee" );
			destructible_function( ::factory_welding_base_01_kill_light );
			destructible_explode( 7000, 8000, 96, 96, 32, 48, undefined );
			destructible_fx( "tag_fx", "vfx/moments/factory/factory_base_explosion_runner" );
			destructible_fx( "tag_door_lg", "vfx/moments/factory/factory_base_door_lg_runner" );
			destructible_fx( "tag_door_sm", "vfx/moments/factory/factory_base_door_sm_runner" );
		destructible_state( undefined, "fac_welding_base_01_destroyed" );
/*
		// large door
		destructible_part( "tag_door_lg", "fac_welding_base_01_lg_door_destroyed", undefined, undefined, undefined, undefined, 1.0, 1.3 );

		// small door
		destructible_part( "tag_door_sm", "fac_welding_base_01_sm_door_destroyed", undefined, undefined, undefined, undefined, 1.0, 1.3 );
*/
}

factory_welding_base_01_kill_light()
{
	// Need to do this to get around red light not playing (due to limit in number of _fx calls in destructible?) and kill
	// green light without killing red light.
	if ( IsDefined ( level._effect[ "glow_green_light_30_nolight" ] ) )
	{
		StopFXOnTag( level._effect[ "glow_green_light_30_nolight" ], self, "tag_light_green" );
	}
	
	wait 0.05;
	
	if ( IsDefined ( level._effect[ "glow_red_light_30_blinker_nolight" ] ) )
	{
		PlayFXOnTag( level._effect[ "glow_red_light_30_blinker_nolight" ], self, "tag_light_red" );
	}
}
