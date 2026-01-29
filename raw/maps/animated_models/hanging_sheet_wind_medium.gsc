#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];

	model = "hanging_sheet";
	if ( isSP() )
		level.anim_prop_models[ model ][ "wind_medium" ] = %hanging_clothes_sheet_wind_medium;
	else
		level.anim_prop_models[ model ][ "wind_medium" ] = "hanging_clothes_sheet_wind_medium";
}
