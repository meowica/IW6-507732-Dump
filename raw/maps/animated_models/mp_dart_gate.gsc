#include common_scripts\utility;

#using_animtree( "animated_props" );
main()
{
	if( !isdefined ( level.anim_prop_models ) )
		level.anim_prop_models = [];
		
	model = "mp_dart_gate_anim";
	if ( isSP() )
	{
		level.anim_prop_models[ model ][ "idle" ] = %mp_dart_gate_wind_idle;
	}
	else
		level.anim_prop_models[ model ][ "idle" ] = "mp_dart_gate_wind_idle";
}
