#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "fence_tarp_107x56";
	if ( isSP() )
	{
		level.anim_prop_models[ model ][ "wind" ] = %fence_tarp_107x56_med_01;
	}
	else
		level.anim_prop_models[ model ][ "wind" ] = "fence_tarp_107x56_med_01";
}
