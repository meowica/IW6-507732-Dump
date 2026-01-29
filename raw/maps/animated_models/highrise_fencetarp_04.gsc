#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "highrise_fencetarp_04";
	if ( isSp() )
	{
		level.anim_prop_models[ model ][ "wind" ] = %highrise_fencetarp_04_wind;
	}
	else
		level.anim_prop_models[ model ][ "wind" ] = "highrise_fencetarp_04_wind";
}
