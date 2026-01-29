#include common_scripts\_destructible;
#using_animtree( "destructibles" );

vehicle_mack_truck_short( color )
{
	//---------------------------------------------------------------------
	// Mack Truck
	//---------------------------------------------------------------------
	destructible_create( "vehicle_mack_truck_short_" + color, "tag_body", 250, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 200, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 100, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_hood_fx", "fx/smoke/mack_truck_damage_blacksmoke_fire", 0.4 );
				destructible_loopfx( "tag_gastank", "fx/smoke/motorcycle_damage_blacksmoke_fire", 0.4 );
				destructible_sound( "mack_truck_flareup_med" );
				destructible_loopsound( "mack_truck_fire_med" );
				destructible_healthdrain( 15, 0.25, 300, "allies" );
			destructible_state( undefined, undefined, 300, "player_only", 32, "no_melee" );
				destructible_loopsound( "mack_truck_fire_med" );
			destructible_state( undefined, undefined, 400, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_gastank", "fx/smoke/motorcycle_damage_blacksmoke_fire", 0.4 );
				destructible_fx( "tag_cab_fire", "fx/fire/firelp_med_pm" );
				destructible_fx( "tag_death_fx", "fx/explosions/propane_large_exp", false );
				destructible_sound( "mack_truck_explode" );
				destructible_loopsound( "mack_truck_fire_med" );
				destructible_explode( 8000, 10000, 512, 512, 100, 400, undefined, undefined, 0.4, 1000 );
				//destructible_anim( %vehicle_80s_sedan1_destroy, #animtree, "setanimknob", undefined, undefined, "vehicle_80s_sedan1_destroy" );
			destructible_state( undefined, "vehicle_mack_truck_short_" + color + "_destroy", undefined, 32, "no_melee" );
		// Tires
		destructible_part( "left_wheel_01_jnt", "vehicle_mack_truck_short_" + color + "_wheel_lf", 20, undefined, undefined, "no_melee", undefined, 8.0 );
		destructible_part( "left_wheel_02_jnt", "vehicle_mack_truck_short_" + color + "_wheel_lf", 20, undefined, undefined, "no_melee", undefined, 81.0 );
		destructible_part( "left_wheel_03_jnt", "vehicle_mack_truck_short_" + color + "_wheel_lf", 20, undefined, undefined, "no_melee", undefined, 8.0 );
		// Doors
		destructible_part( "tag_door_left_front", "vehicle_mack_truck_short_" + color + "_door_lf", undefined, undefined, undefined, undefined, 1.0, 1.0 );
		// Glass ( Front )
		tag = "tag_glass_front";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_front_fx", "fx/props/car_glass_large" );
				destructible_sound( "mack_truck_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Back )
		tag = "tag_glass_back";
		destructible_part( tag, undefined, 40, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_back_fx", "fx/props/car_glass_large" );
				destructible_sound( "mack_truck_glass_break_large" );
			destructible_state( undefined );
		// Glass ( Left Front )
		tag = "tag_glass_left_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_left_front_fx", "fx/props/car_glass_med" );
				destructible_sound( "mack_truck_glass_break_small" );
			destructible_state( undefined );
		// Glass ( Right Front )
		tag = "tag_glass_right_front";
		destructible_part( tag, undefined, 20, undefined, undefined, undefined, undefined, undefined, true );
			destructible_state( tag + "_d", undefined, 60, undefined, undefined, undefined, true );
				destructible_fx( "tag_glass_right_front_fx", "fx/props/car_glass_med" );
				destructible_sound( "mack_truck_glass_break_small" );
			destructible_state( undefined );
}
