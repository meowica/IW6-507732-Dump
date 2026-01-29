#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "c17", model, type, classname );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_boeing_c17" );

	build_deathfx( "fx/explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
	build_rumble( "mig_rumble", .2, .4, 22600, .05, .05 );
	build_life( 999, 500, 1500 );
	build_treadfx();
	build_team( "allies" );
	build_is_airplane();
}

init_local()
{
}

/*QUAKED script_vehicle_c17 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_c17::main( "vehicle_boeing_c17", "c17", "script_vehicle_c17" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_c17

defaultmdl="vehicle_boeing_c17"
default:"vehicletype" "c17"
default:"script_team" "allies"
*/