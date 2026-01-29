#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// trashbin02 toy
	//---------------------------------------------------------------------
	destructible_create( "toy_trashbin_02", "tag_origin", 120, undefined, 32, "no_melee" );
				destructible_fx( "tag_fx", "fx/props/garbage_spew_des", true, "splash" );
				destructible_fx( "tag_fx", "fx/props/garbage_spew", true, damage_not( "splash" ) );
				destructible_sound( "exp_trashcan_sweet" );
				destructible_explode( 600, 800, 1, 1, 10, 20 );	 // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage

		destructible_state( undefined, "com_trashbin02_dmg", undefined, undefined, undefined, undefined, undefined, false );

		destructible_part( "tag_fx", "com_trashbin02_lid", undefined, undefined, undefined, undefined, 1.0, 1.0 );

}
