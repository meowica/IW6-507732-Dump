#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Ceiling fluorescent light
	//---------------------------------------------------------------------
	destructible_create( "toy_light_ceiling_fluorescent_single" , "tag_origin", 150, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 15 );	
			destructible_fx( "tag_fx", "fx/misc/light_fluorescent_single_blowout_runner" );
			destructible_fx( "tag_swing_center_fx", "fx/misc/light_blowout_swinging_runner" );
			destructible_fx( "tag_swing_center_fx_far", "fx/misc/light_blowout_swinging_runner" );
			destructible_lights_out( 32 );
			destructible_explode( 20, 2000, 64, 64, 40, 80 );   // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
			destructible_anim( %light_fluorescent_single_swing, #animtree, "setanimknob", undefined, 0, "light_fluorescent_single_swing" );
				destructible_sound( "fluorescent_light_fall", undefined, 0 ); 
				destructible_sound( "fluorescent_light_bulb", undefined, 0  ); 
				//destructible_sound( "fluorescent_light_spark", undefined, 0  ); 
			destructible_anim( %light_fluorescent_single_swing_02, #animtree, "setanimknob", undefined, 1, "light_fluorescent_single_swing_02" );
				destructible_sound( "fluorescent_light_hinge", undefined, 1  ); 
				destructible_sound( "fluorescent_light_bulb", undefined, 1  ); 
				//destructible_sound( "fluorescent_light_spark", undefined, 1  ); 
			destructible_anim( %light_fluorescent_single_swing_03, #animtree, "setanimknob", undefined, 2, "light_fluorescent_single_swing_03" );
				destructible_sound( "fluorescent_light_fall", undefined, 2  ); 
				destructible_sound( "fluorescent_light_bulb", undefined, 2  ); 
				//destructible_sound( "fluorescent_light_spark", undefined, 2  ); 
			destructible_anim( %light_fluorescent_single_null, #animtree, "setanimknob", undefined, 3, "light_fluorescent_single_null" );
		destructible_state( undefined, "me_lightfluohang_single_destroyed", undefined, undefined, "no_melee" );
}
