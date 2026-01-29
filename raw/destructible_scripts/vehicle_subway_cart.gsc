#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Subway car "vehicle_subway_cart_destructible"
	//---------------------------------------------------------------------

/*
   Just the doors!

body_animate_jnt
  J_LE_Front_Door_01
	TAG_WINDOW_SMALL_02_LE
	TAG_WINDOW_SMALL_02_LE_D
  J_LE_Front_Door_02
	TAG_WINDOW_SMALL_03_LE
	TAG_WINDOW_SMALL_03_LE_D
  J_LE_Front_Door_03
	TAG_WINDOW_SMALL_04_LE
	TAG_WINDOW_SMALL_04_LE_D
  J_LE_Front_Door_04
	TAG_WINDOW_SMALL_05_LE
	TAG_WINDOW_SMALL_05_LE_D
  J_RI_Front_Door_01
	TAG_WINDOW_SMALL_02_RI
	TAG_WINDOW_SMALL_02_RI_D
  J_RI_Front_Door_02
	TAG_WINDOW_SMALL_03_RI
	TAG_WINDOW_SMALL_03_RI_D
  J_RI_Front_Door_03
	TAG_WINDOW_SMALL_04_RI
	TAG_WINDOW_SMALL_04_RI_D
  J_RI_Front_Door_04
	TAG_WINDOW_SMALL_05_RI
	TAG_WINDOW_SMALL_05_RI_D
=
*/
	destructible_create( "vehicle_subway_cart", "tag_origin", undefined, undefined, 32, "no_melee" );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_02_RI", true,  "fx/props/car_glass_subway_tall"  );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_03_RI", true,  "fx/props/car_glass_subway_tall"  );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_04_RI", true,  "fx/props/car_glass_subway_tall"  );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_05_RI", true,  "fx/props/car_glass_subway_tall"  );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_02_LE", true,  "fx/props/car_glass_subway_tall"  );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_03_LE", true,  "fx/props/car_glass_subway_tall"  );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_04_LE", true,  "fx/props/car_glass_subway_tall"  );
	create_vehicle_subway_cart_window_single( "TAG_WINDOW_SMALL_05_LE", true,  "fx/props/car_glass_subway_tall"  );

}


create_vehicle_subway_cart_window_single( tag_center, has_destructible_mid_stage, fx )
{
	destructible_part( tag_center, undefined, 140, undefined, undefined, undefined, undefined, undefined, true );
	if( has_destructible_mid_stage )
		destructible_state( tag_center + "_D", undefined, 80, undefined, undefined, undefined, true );
	destructible_fx( tag_center, fx );
	destructible_sound( "veh_glass_break_large" );
	destructible_state( undefined );
}
