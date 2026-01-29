#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Subway car windows only "vehicle_subway_window"
	//---------------------------------------------------------------------

	destructible_create( "vehicle_subway_cart_windows", "tag_origin",  undefined, undefined, 32, "no_melee" );
		create_vehicle_subway_cart_window_single( "TAG_FRONT_WINDOW", true,  "fx/props/car_glass_subway_tall"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_01_LE", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_03_LE", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_04_LE", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_07_LE", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_08_LE", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_011_LE", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_012_LE", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_014_LE", true,  "fx/props/car_glass_subway_tall"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_01_RI", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_03_RI", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_04_RI", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_07_RI", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_08_RI", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_011_RI", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_012_RI", true,  "fx/props/car_glass_subway_large"  );
		create_vehicle_subway_cart_window_single( "TAG_WINDOW_014_RI", true,  "fx/props/car_glass_subway_tall"  );
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
