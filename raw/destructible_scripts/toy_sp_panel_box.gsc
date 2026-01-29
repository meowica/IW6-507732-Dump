#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// space panel box medium toy
	//---------------------------------------------------------------------
	destructible_create( "toy_sp_panel_box", "tag_origin", 15, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 15 );
			destructible_fx( "tag_fx", "fx/props/electricbox4_explode", undefined, undefined, undefined, 1 );
			destructible_sound( "exp_fusebox_sparks" );
			destructible_explode( 5, 2000, 132, 32, 1, 1, undefined, 0 );	 // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage, continue damage, originoffset
		destructible_state( undefined, "me_electricbox4_dest", undefined, undefined, "no_melee" );
		// door
		destructible_part( "tag_fx", "me_electricbox4_door", undefined, undefined, undefined, undefined, 1.0, 1.0 );
}
