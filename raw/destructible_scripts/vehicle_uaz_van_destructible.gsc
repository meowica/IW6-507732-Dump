#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// uaz_van 
	//---------------------------------------------------------------------
	/*
	"vehicle_uaz_van_destructible"
	*/
	destructible_create( "vehicle_uaz_van_destructible" , "tag_body", 250, undefined, 32, "no_melee" );
		//destructible_splash_damage_scaler( 18 );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "fire_vehicle_flareup_med" );
				destructible_loopsound( "fire_vehicle_med" );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "fire_vehicle_med" );
			destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "fx/explosions/small_vehicle_explosion", false );
				destructible_sound( "car_explode" );
				destructible_explode( 4000, 5000, 200, 250, 50, 300, undefined, undefined, 0.3, 500 );
				destructible_anim( %vehicle_80s_sedan1_destroy, #animtree, "setanimknob", undefined, undefined, "vehicle_80s_sedan1_destroy" );
			destructible_state( undefined, "vehicle_uaz_van_destroyed", undefined, 32, "no_melee" );
		// Hood
		// Tires
		destructible_part( "left_wheel_01_jnt", "vehicle_uaz_van_wheel_lf", 20, undefined, undefined, "no_melee", undefined, 2.3 );
			destructible_anim( %vehicle_80s_sedan1_flattire_LF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_01_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_RF, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "left_wheel_02_jnt", undefined, 20, undefined, undefined, "no_melee" );
			destructible_anim( %vehicle_80s_sedan1_flattire_LB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		destructible_part( "right_wheel_02_jnt",  "vehicle_uaz_van_wheel_lf" , 20, undefined, undefined, "no_melee", undefined, 1.6 );
			destructible_anim( %vehicle_80s_sedan1_flattire_RB, #animtree, "setanim" );
			destructible_sound( "veh_tire_deflate", "bullet" );
		// Glass ( Front )
		tag = "tag_glass_front";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "fx/props/car_glass_large" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Left Front )
		tag = "tag_glass_left_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Right Front )
		tag = "tag_glass_right_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Left Back )
		tag = "tag_glass_left_back";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Right Back )
		tag = "tag_glass_right_back";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
			destructible_fx( tag + "_fx", "fx/props/car_glass_med" );
			destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
}
