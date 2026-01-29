#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
    if( !isdefined ( level.anim_prop_models ) )
        level.anim_prop_models = [];
        
    model = "fence_tarp_draping_224x116";
    if ( isSp() )
    {
        level.anim_prop_models[ model ][ "wind" ] = %fence_tarp_draping_224x116_01;
    }
    else
        level.anim_prop_models[ model ][ "wind" ] = "fence_tarp_draping_224x116_01";
}
    