#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{   
	//---------------------------------------------------------------------
	// Gaz
	//---------------------------------------------------------------------
	//PreCacheModel("vehicle_gaz_tigr_harbor_destroyed");
	destructible_create( "vehicle_gaz", "tag_body", 400, undefined, 32, "no_melee" );
		//destructible_splash_damage_scaler( 18 );
				//tag_engine_right should be replace with tag_hood_fx
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_blacksmoke_fire_gaz", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 15, 0.25, 210, "allies" );
			destructible_state( undefined, undefined, 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
				//tag_origin should be replace with tag_deathfx
				destructible_fx( "tag_deathfx", "fx/explosions/vehicle_explosion_gaz", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 210, 250, 50, 300, undefined, undefined, 0.3, 500 );
				destructible_anim( %vehicle_80s_sedan1_destroy, #animtree, "setanimknob", undefined, undefined, "vehicle_80s_sedan1_destroy" );
			destructible_state( undefined, "vehicle_gaz_tigr_harbor_destroyed", undefined, 32, "no_melee" );
		// Tires
		destructible_part( "left_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "left_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		// Glass ( Front )
		tag = "tag_glass_front";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_front_fx", "fx/props/car_glass_large" );
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
		// Glass ( Left mid )
		tag = "tag_glass_left_mid";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_left_mid_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Right mid )
		tag = "tag_glass_right_mid";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_right_mid_fx", "fx/props/car_glass_med" );
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
		// Glass ( Back Left )
		tag = "tag_glass_back_left";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_back_left_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Back Right )
		tag = "tag_glass_back_right";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( "tag_glass_back_right_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
}
