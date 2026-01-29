#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Mig 29 Landed Airplane
	//---------------------------------------------------------------------
	destructible_create( "vehicle_mig29_landed", "TAG_ORIGIN", 250, undefined, 32, "splash" );
		destructible_splash_damage_scaler( 11 );
				destructible_loopfx( "TAG_front_fire", "fx/smoke/car_damage_whitesmoke", 0.4 );
				destructible_loopfx( "TAG_rear_fire", "fx/smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 200, undefined, 32, "splash" );
				destructible_loopfx( "TAG_front_fire", "fx/smoke/car_damage_blacksmoke", 0.4 );
				destructible_loopfx( "TAG_rear_fire", "fx/smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 100, undefined, 32, "splash" );
				destructible_loopfx( "TAG_front_fire", "fx/smoke/airplane_damage_blacksmoke_fire", 0.4 );
				destructible_loopfx( "TAG_rear_fire", "fx/smoke/airplane_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 15, 0.25, 512, "allies" );
			destructible_state( undefined, undefined, 300, "player_only", 32, "splash" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, undefined, 400, undefined, 32, "splash" );
				destructible_fx( "TAG_FX", "fx/explosions/vehicle_explosion_mig29", false );
				destructible_sound( "car_explode" );
				destructible_explode( 8000, 10000, 512, 512, 50, 300, undefined, undefined, 0.4, 1000 );
				destructible_anim( %vehicle_mig29_destroy, #animtree, "setanimknob", undefined, undefined, "vehicle_mig29_destroy" );
			destructible_state( undefined, "vehicle_mig29_v2_dest", undefined, 32, "splash" );

		destructible_part( "TAG_COCKPIT", "vehicle_mig29_dest_cockpit", 40, undefined, undefined, undefined, undefined, 1.0 );
}
