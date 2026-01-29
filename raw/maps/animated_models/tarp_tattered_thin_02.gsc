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
        
    model = "tarp_tattered_thin_02";
    if ( SP )
    {
        level.anim_prop_models[ model ][ "self.wind" ] = %tarp_tattered_thin_02_anim;
    }
    else
        level.anim_prop_models[ model ][ "self.wind" ] = "tarp_tattered_thin_02_anim";
}
