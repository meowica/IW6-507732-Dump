#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// toy_furniture_coffee_table_modern variants
	//---------------------------------------------------------------------
	destructible_create( "toy_furniture_coffee_table_modern_0" + 2, "tag_origin", 50, undefined, 32, "no_melee" );
				destructible_fx( "tag_fx", "fx/props/furniture_coffee_table_modern_0" + 2, true, undefined );
				//destructible_explode( force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage, continueDamage, originOffset, earthQuakeScale, earthQuakeRadius, originOffset3d, delaytime )
				destructible_explode( 600, 1651, 60, 60, 10, 20, undefined, 10 );	 // force_min, force_max, rangeSP, rangeMP, mindamage, maxdamage
				
		destructible_state( undefined, "furniture_coffee_table_modern_0" + 2 + "_dest", undefined, undefined, undefined, undefined, undefined, false );
}
