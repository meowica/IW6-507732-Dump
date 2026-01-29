#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
    if( !isdefined ( level.anim_prop_models ) )
        level.anim_prop_models = [];
        
    model = "accessories_windsock_large";
    if ( isSp() )
    {
        level.anim_prop_models[ model ][ "self.wind" ] = %windsock_large_wind_medium;
    }
    else
        level.anim_prop_models[ model ][ "self.wind" ] = "windsock_large_wind_medium";
}
    