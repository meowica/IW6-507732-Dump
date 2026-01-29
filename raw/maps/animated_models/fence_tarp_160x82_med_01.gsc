#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
    if( !isdefined ( level.anim_prop_models ) )
        level.anim_prop_models = [];
        
    model = "fence_tarp_160x82";
    if ( isSp() )
    {
        level.anim_prop_models[ model ][ "wind" ] = %fence_tarp_160x82_med_01;
    }
    else
        level.anim_prop_models[ model ][ "wind" ] = "fence_tarp_160x82_med_01";
}
    