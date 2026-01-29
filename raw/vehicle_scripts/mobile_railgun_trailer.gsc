#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	build_template( "mobile_railgun_trailer", model, type, classname );
	build_localinit( ::init_local );

	build_drive( %mobile_railgun_trailer_movement, %mobile_railgun_trailer_movement, 25 );

	build_treadfx();
	
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	
			 //   classname  name 			   tag 			effect 													   group 	 delay   
	build_light( classname, "running_light_01", "tag_running_light_01", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_02", "tag_running_light_02", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_03", "tag_running_light_03", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_04", "tag_running_light_04", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_05", "tag_running_light_05", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_06", "tag_running_light_06", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_07", "tag_running_light_07", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_08", "tag_running_light_08", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_09", "tag_running_light_09", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "running_light_10", "tag_running_light_10", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
}

init_local()
{
}

unload_groups()
{
}

#using_animtree( "vehicles" );
set_vehicle_anims()
{
}

#using_animtree( "generic_human" );
setanims()
{	
}

/*QUAKED script_vehicle_mobilerailgun_trailer (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\mobile_railgun_trailer::main( "mobile_railgun_trailer", undefined, "script_vehicle_mobilerailgun_trailer" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_mobile_railgun_trailer

defaultmdl="vehicle_mobile_railgun_trailer"
default:"vehicletype" "mobile_railgun_trailer"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_mobilerailgun_trailer_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\mobile_railgun_trailer::main( "mobile_railgun_trailer", undefined, "script_vehicle_mobilerailgun_trailer_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_mobile_railgun_trailer

defaultmdl="vehicle_mobile_railgun_trailer"
default:"vehicletype" "mobile_railgun_trailer_physics"
default:"script_team" "allies"
*/






