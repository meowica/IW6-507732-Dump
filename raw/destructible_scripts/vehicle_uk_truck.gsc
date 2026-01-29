#include common_scripts\_destructible;
#using_animtree( "vehicles" );

main()
{
	//"vehicle_uk_utility_truck_destructible"
	destructible_create( "vehicle_uk_truck", "tag_body", 250, undefined, 32, "no_melee" );
		tag = "TAG_GLASS_FRONT";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_D", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_front_fx", "fx/props/car_glass_large" );
				destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Back )
		tag = "TAG_GLASS_BACK";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_D", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_back_fx", "fx/props/car_glass_large" );
				destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Left Front )
		tag = "TAG_GLASS_LEFT_FRONT";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_D", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_left_front_fx", "fx/props/car_glass_med" );
				destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Right Front )
		tag = "TAG_GLASS_RIGHT_FRONT";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_D", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_right_front_fx", "fx/props/car_glass_med" );
				destructible_sound( "veh_glass_break_large" );
			destructible_state( undefined );
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

}
