#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "foliage_desertbrush_3_animated";
	if ( isSp() )
	{
		level.anim_prop_models[ model ][ "wind" ] = %foliage_desertbrush_1_sway;
	}
	else
		level.anim_prop_models[ model ][ "wind" ] = "foliage_desertbrush_1_sway";
}
