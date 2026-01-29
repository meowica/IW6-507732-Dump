#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// fire hydrant toy
	//---------------------------------------------------------------------
	destructible_create( "toy_firehydrant", "tag_origin", 250, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 11 );
			destructible_state( undefined, undefined, 500, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_cap", "fx/props/firehydrant_leak", 0.1 );
				destructible_loopsound( "firehydrant_spray_loop" );
				destructible_healthdrain( 12, 0.2 );
			destructible_state( undefined, undefined, 800, undefined, 5, "no_melee" );
				destructible_fx( "tag_fx", "fx/props/firehydrant_exp", false );
				destructible_fx( "tag_fx", "fx/props/firehydrant_spray_10sec", false );
				destructible_sound( "firehydrant_burst" );
				destructible_explode( 17000, 18000, 96, 96, 32, 48 );   // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
			destructible_state( undefined, "com_firehydrant_dest", undefined, undefined, "no_melee" );

		// destroyed hydrant
		destructible_part( "tag_fx", "com_firehydrant_dam", undefined, undefined, undefined, undefined, 1.0, 1.0 );
		// side cap
		destructible_part( "tag_cap", "com_firehydrant_cap", undefined, undefined, undefined, undefined, 1.0, 1.0 );
}
