#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Small Propane tank goes KaBooM
	//---------------------------------------------------------------------

	destructible_create( "toy_propane_tank02_small", "tag_origin", 50, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 10 );
			destructible_state( undefined, undefined, 350, undefined, 32, "no_melee" );
				destructible_loopsound( "propanetank02_gas_leak_loop" );
				destructible_loopfx( "tag_cap", "fx/distortion/propane_cap_distortion", 0.1 );
			destructible_state( undefined, undefined, 350, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_cap", "fx/fire/propane_capfire_leak", 0.1 );
				destructible_sound( "propanetank02_flareup_med" );
				destructible_loopsound( "propanetank02_fire_med" );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_physics( "tag_cap", ( 50, 0, 0 ) );
				destructible_loopfx( "tag_cap", "fx/fire/propane_capfire", 0.6 );
				destructible_fx( "tag_valve", "fx/fire/propane_valvefire_flareup" );
				destructible_physics( "tag_valve", ( 50, 0, 0 ) );
				destructible_fx( "tag_cap", "fx/fire/propane_capfire_flareup" );
				destructible_loopfx( "tag_valve", "fx/fire/propane_valvefire", 0.1 );
				destructible_sound( "propanetank02_flareup_med" );
				destructible_loopsound( "propanetank02_fire_med" );
			destructible_state( undefined, undefined, 200, undefined, 5, "no_melee" );
				destructible_fx( "tag_fx", "fx/fire/propane_small_fire" );
				//destructible_fx( "tag_fx", "fx/explosions/propane_large_exp_fireball" );
				destructible_fx( "tag_fx", "fx/explosions/propane_large_exp", false );
				destructible_sound( "propanetank02_explode" );
				destructible_explode( 7000, 8000, 400, 400, 32, 100 );  // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
			destructible_state( undefined, "com_propane_tank02_small_DES", undefined, undefined, "no_melee" );
		// Lower Valve
		destructible_part( "tag_valve", "com_propane_tank02_small_valve" );
		// Top Cap
		destructible_part( "tag_cap", "com_propane_tank02_small_cap" );

}
