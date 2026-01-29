#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// newspaper stand toy
	//---------------------------------------------------------------------
	destructible_create( "toy_newspaper_stand_red", "tag_origin", 120 );
			destructible_fx( "tag_door", "fx/props/news_stand_paper_spill", true, damage_not( "splash" ) );		// coin drop
			destructible_sound( "exp_newspaper_box" );												  // coin drop sounds
			destructible_explode( 2500, 2501, 64, 64, 0, 0, true );												 // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage, continue to take damage
		destructible_state( undefined, "com_newspaperbox_red_dam", 20, undefined, undefined, "splash" );
			destructible_fx( "tag_fx", "fx/props/news_stand_explosion", true, "splash" );						  // coin drop
		destructible_state( undefined, "com_newspaperbox_red_des", undefined, undefined, undefined, undefined, undefined, false );

		// front door
		destructible_part( "tag_door", "com_newspaperbox_red_door", undefined, undefined, undefined, undefined, 1.0, 1.0 );
}
