#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
    if( !isdefined ( level.anim_prop_models ) )
        level.anim_prop_models = [];
        
    model = "fence_tarp_352x88";
    if ( isSP() )
    {
        level.anim_prop_models[ model ][ "self.wind" ] = %fence_tarp_352x88_med_01;
    }
    else
        level.anim_prop_models[ model ][ "self.wind" ] = "fence_tarp_352x88_med_01";
}
    