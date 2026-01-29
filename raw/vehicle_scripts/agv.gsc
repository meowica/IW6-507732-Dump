#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "agv", model, type, classname );
	build_localinit( ::init_local );
	build_deathmodel( model, model );
	build_drive( %iveco_lynx_idle_driving_idle_forward, %iveco_lynx_idle_driving_idle_forward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	
	build_light( classname, "top_light", "tag_top_light", "vfx/ambient/lights/glow_blue_light_rect_150_blinker", "running", 0.1 );
}

init_local()
{
	vehicle_lights_on( "running" );
}



/*QUAKED script_vehicle_agv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\agv::main( "fac_agv", undefined, "script_vehicle_agv" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_agv

defaultmdl="fac_agv"
default:"vehicletype" "agv"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_agv_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\agv::main( "fac_agv", "agv_physics", "script_vehicle_agv_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_agv
sound,vehicle_forklift,vehicle_standard,all_sp

defaultmdl="fac_agv"
default:"vehicletype" "agv_physics"
*/
