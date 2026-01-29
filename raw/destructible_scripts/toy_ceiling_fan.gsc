#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// ceiling fan
	//---------------------------------------------------------------------
	destructible_create( "toy_ceiling_fan", "tag_origin", 0, undefined, 32 );
			destructible_anim( %me_fanceil1_spin, #animtree, "setanimknob", undefined, undefined, "me_fanceil1_spin" );
		destructible_state( "tag_origin", "me_fanceil1", 150 );
			destructible_anim( %me_fanceil1_spin_stop, #animtree, "setanimknob", undefined, undefined, "me_fanceil1_spin_stop" );
			destructible_fx( "tag_fx", "fx/explosions/ceiling_fan_explosion" );
			destructible_sound( "ceiling_fan_sparks" );
			destructible_explode( 1000, 2000, 32, 32, 5, 32, undefined, 0 );	// force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage, continue damage, originoffset
		destructible_state( undefined, "me_fanceil1_des", undefined, undefined, "no_melee" );
			destructible_part( "tag_fx", undefined, 150, undefined, undefined, undefined, 1.0 );
}
