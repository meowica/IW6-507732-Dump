#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "m880_launcher", model, type, classname );
	build_localinit( ::init_local );
	build_deathmodel( model, model );
	build_drive( %m880_launcher_idle_driving_idle_forward, %m880_launcher_idle_driving_idle_forward, 10 );
	//build_deathfx( "fx/explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "axis" );
}

init_local()
{
}



/*QUAKED script_vehicle_m880_launcher (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m880_launcher::main( "vehicle_m880_launcher", undefined, "script_vehicle_m880_launcher" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m880_launcher

defaultmdl="vehicle_m880_launcher"
default:"vehicletype" "m880_launcher"
default:"script_team" "axis"
*/
