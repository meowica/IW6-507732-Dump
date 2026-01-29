#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// usa_gas_station_trash_bin_02 toy
	//---------------------------------------------------------------------
	destructible_create( "toy_usa_gas_station_trash_bin_02", "tag_origin", 120, undefined, 32, "no_melee" );
				destructible_fx( "tag_fx_high", "fx/props/garbage_spew_des", true, "splash" );
				destructible_fx( "tag_fx_high", "fx/props/garbage_spew", true, damage_not( "splash" ) );
				destructible_explode( 600, 651, 1, 1, 10, 20 );	 // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage

		destructible_state( undefined, "usa_gas_station_trash_bin_02_base", undefined, undefined, undefined, undefined, undefined, false );
		destructible_part( "tag_fx_high", "usa_gas_station_trash_bin_02_lid", undefined, undefined, undefined, undefined, 1.0, 1.0 );
}
