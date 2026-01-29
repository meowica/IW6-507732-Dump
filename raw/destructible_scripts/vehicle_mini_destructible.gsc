#include common_scripts\_destructible;
#using_animtree( "destructibles" );

vehicle_mini( color )
{
	//---------------------------------------------------------------------
	// Modern mini -
	//---------------------------------------------------------------------
	//"vehicle_mini_destructible_white"
	/*
	TAG_ORIGIN
  origin_animate_jnt
    TAG_BODY
      body_animate_jnt
        TAG_DEATH_FX
        TAG_DOOR_LEFT_BACK
          TAG_GLASS_LEFT_BACK
          TAG_GLASS_LEFT_BACK_02
          TAG_GLASS_LEFT_BACK_02_D
          TAG_GLASS_LEFT_BACK_02_FX
          TAG_GLASS_LEFT_BACK_D
          TAG_GLASS_LEFT_BACK_FX
        TAG_DOOR_LEFT_FRONT
          TAG_GLASS_LEFT_FRONT
          TAG_GLASS_LEFT_FRONT_D
          TAG_GLASS_LEFT_FRONT_FX
          TAG_MIRROR_LEFT
        TAG_DOOR_RIGHT_BACK
          TAG_GLASS_RIGHT_BACK
          TAG_GLASS_RIGHT_BACK_02
          TAG_GLASS_RIGHT_BACK_02_D
          TAG_GLASS_RIGHT_BACK_02_FX
          TAG_GLASS_RIGHT_BACK_D
          TAG_GLASS_RIGHT_BACK_FX
        TAG_DOOR_RIGHT_FRONT
          TAG_GLASS_RIGHT_FRONT
          TAG_GLASS_RIGHT_FRONT_D
          TAG_GLASS_RIGHT_FRONT_FX
          TAG_MIRROR_RIGHT
        TAG_DRIVER
        TAG_GLASS_BACK
        TAG_GLASS_BACK_D
        TAG_GLASS_BACK_FX
        TAG_GLASS_FRONT
        TAG_GLASS_FRONT_D
        TAG_GLASS_FRONT_FX
        TAG_HOOD
        TAG_HOOD_FX
        TAG_LIGHT_LEFT_FRONT
        TAG_LIGHT_LEFT_FRONT_D
        TAG_LIGHT_RIGHT_FRONT
        TAG_LIGHT_RIGHT_FRONT_D
        TAG_PASSENGER
        TAG_PLAYER
    TAG_WHEEL_BACK_LEFT
      left_wheel_02_jnt
    TAG_WHEEL_BACK_RIGHT
      right_wheel_02_jnt
    TAG_WHEEL_FRONT_LEFT
      left_wheel_front_animate_jnt
        left_wheel_01_jnt
    TAG_WHEEL_FRONT_RIGHT
      right_wheel_front_animate_jnt
        right_wheel_01_jnt

	*/
	destructible_create( "vehicle_mini_destructible_" + color, "tag_body", 250, undefined, 32, "no_melee" );
		//destructible_splash_damage_scaler( 18 );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 12, 0.2, 150, "allies" );
			destructible_state( undefined, undefined, 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "fx/explosions/small_vehicle_explosion", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 150, 250, 50, 300, undefined, undefined, 0.3, 500 );
				destructible_anim( %vehicle_80s_sedan1_destroy, #animtree, "setanimknob", undefined, undefined, "vehicle_80s_sedan1_destroy" );
			destructible_state( undefined, "vehicle_mini_destroyed_" + color, undefined, 32, "no_melee" );
		// Tires
		destructible_part( "left_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LF, #animtree, "setanim", true );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RF, #animtree, "setanim", true );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "left_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LB, #animtree, "setanim", true );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee", undefined, 2.3 );
			destructible_anim( %vehicle_80s_sedan1_flattire_RB, #animtree, "setanim", true );
			destructible_sound( "veh_tire_deflate", "bullet" );
		// Glass ( Front )
		tag = "TAG_GLASS_FRONT";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_D", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_front_fx", "fx/props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Back )
		tag = "tag_glass_back";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_back_fx", "fx/props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Left Front )
		tag = "tag_glass_left_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_left_front_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Right Front )
		tag = "tag_glass_right_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_right_front_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Left Back )
		tag = "tag_glass_left_back";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_left_back_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Right Back )
		tag = "tag_glass_right_back";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_right_back_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Head Light ( Left )
		tag = "tag_light_left_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, 0.5 );
			destructible_fx( tag, "fx/props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
			destructible_state( tag + "_d" );
		// Head Light ( Right )
		tag = "tag_light_right_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag, "fx/props/car_glass_headlight" );
			destructible_sound( "veh_glass_break_small" );
		// Side Mirrors
		destructible_part( "tag_mirror_left", "vehicle_mini_mirror_lf", 40, undefined, undefined, undefined, undefined, 1.0 );
			destructible_physics();
		destructible_part( "tag_mirror_right", "vehicle_mini_mirror_rf", 40, undefined, undefined, undefined, undefined, 1.0 );
			destructible_physics();
}

