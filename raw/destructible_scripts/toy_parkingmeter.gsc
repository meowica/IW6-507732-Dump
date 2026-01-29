#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// parking meter toy
	//---------------------------------------------------------------------
	destructible_create( "toy_parkingmeter", "tag_meter", 120 );
				destructible_fx( "tag_fx", "fx/props/parking_meter_coins", true, damage_not( "splash" ) ); // coin drop
				destructible_fx( "tag_fx", "fx/props/parking_meter_coins_exploded", true, "splash" );	  // coin drop
				destructible_sound( "exp_parking_meter_sweet" );										// coin drop sounds
				destructible_explode( 2800, 3000, 64, 64, 0, 0, true );	 // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage, continue to take damage
			destructible_state( undefined, "com_parkingmeter_damaged", 20, undefined, undefined, "splash" );
			destructible_state( undefined, "com_parkingmeter_destroyed", undefined, undefined, undefined, undefined, undefined, true );

		// coin collector's cap
		destructible_part( "tag_cap", "com_parkingmeter_cap", undefined, undefined, undefined, undefined, 1.0, 1.0 );
}
