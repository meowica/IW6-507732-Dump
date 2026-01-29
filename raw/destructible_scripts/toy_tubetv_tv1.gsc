#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	toy_tubetv_( "tv1" );
}

toy_tubetv_( version )
{
	//---------------------------------------------------------------------
	// Tube TV
	//---------------------------------------------------------------------
	destructible_create( "toy_tubetv_" + version, "tag_origin", 1, undefined, 32 );
		destructible_splash_damage_scaler( 1 );
			destructible_fx( "tag_fx", "fx/explosions/tv_explosion" );
			destructible_sound( "tv_shot_burst" );
			destructible_explode( 20, 2000, 9, 9, 3, 3, undefined, 12 );	// force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
		destructible_state( undefined, "com_" + version + "_d", undefined, undefined, "no_melee" );
}