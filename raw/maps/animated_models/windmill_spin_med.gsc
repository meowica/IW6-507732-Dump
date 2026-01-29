#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
    if( !isdefined ( level.anim_prop_models ) )
        level.anim_prop_models = [];
        
    model = "machinery_windmill";
    if ( isSp() )
    {
        level.anim_prop_models[ model ][ "self.wind" ] = %windmill_spin_med;
    }
    else
        level.anim_prop_models[ model ][ "self.wind" ] = "windmill_spin_med";
}
    