#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	// Would use isSP() but this runs before we can
	mapname = tolower( getdvar( "mapname" ) );
	SP = true;
	if ( string_starts_with( mapname, "mp_" ) )
		SP = false;
		
	model = "qad_tree_palm_tall_2";
	if ( SP )
	{
		level.anim_prop_models[ model ][ "still" ] = %qad_palmtree_tall_windy_a;
		level.anim_prop_models[ model ][ "strong" ] = %qad_palmtree_tall_windy_a;
		level.anim_prop_models[ model ][ "flood" ] = %qad_palmtree_tall_windy_a;
	}
	else
	{
		level.anim_prop_models[ model ][ "still" ] = "flood_palm_tree4_loop_01";
		level.anim_prop_models[ model ][ "strong" ] = "flood_palm_tree4_loop_01";
		level.anim_prop_models[ model ][ "flood" ] = "qad_palmtree_tall_windy_a";
	}
}
