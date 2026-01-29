#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "foliage_pacific_flowers06_animated";
	if ( isSp() )
	{
		level.anim_prop_models[ model ][ "wind" ] = %foliage_pacific_flowers06_sway;
	}
	else
		level.anim_prop_models[ model ][ "wind" ] = "foliage_pacific_flowers06_sway";
}
