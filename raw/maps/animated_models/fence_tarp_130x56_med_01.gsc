#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "fence_tarp_130x56";
	if ( isSp() )
	{
		level.anim_prop_models[ model ][ "wind" ] = %fence_tarp_130x56_med_01;
	}
	else
		level.anim_prop_models[ model ][ "wind" ] = "fence_tarp_130x56_med_01";
}
