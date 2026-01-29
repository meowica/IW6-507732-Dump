#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	build_template( "lcs", model, type, classname );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_lcs", "vehicle_lcs_destroyed_front" );
	build_life( 999, 500, 1500 );
	build_team( "allies" );
}

init_local()
{
}

/*QUAKED script_vehicle_lcs (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:
//iw6-depot/iw6/map_source/ship_graveyard_script.map
vehicle_scripts\_lcs::main( "vehicle_lcs", undefined, "script_vehicle_lcs" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_lcs
sound,vehicle_zodiac,vehicle_standard,all_sp

defaultmdl="vehicle_lcs"
default:"vehicletype" "lcs"
default:"script_team" "axis"
*/