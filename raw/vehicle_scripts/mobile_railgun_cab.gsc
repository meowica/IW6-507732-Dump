#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	build_template( "mobile_railgun_cab", model, type, classname );
	build_localinit( ::init_local );

	build_drive( %mobile_railgun_cab_movement, %mobile_railgun_cab_movement, 25 );

	build_treadfx();
	
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	
			 //   classname    name 			   tag 					   effect 													    group 	      delay   
	build_light( classname	, "headlight_beam_l_01", "tag_headlight_beam_l_01", "vfx/moments/factory/factory_het_cab_headlight_beam", "headlights", 0.0 );
	build_light( classname	, "headlight_beam_l_02", "tag_headlight_beam_l_02", "vfx/moments/factory/factory_het_cab_headlight_beam", "headlights", 0.0 );
	build_light( classname	, "headlight_beam_r_01", "tag_headlight_beam_r_01", "vfx/moments/factory/factory_het_cab_headlight_beam", "headlights", 0.0 );
	build_light( classname	, "headlight_beam_r_02", "tag_headlight_beam_r_02", "vfx/moments/factory/factory_het_cab_headlight_beam", "headlights", 0.0 );
	build_light( classname	, "headlight_lens_l_01", "tag_headlight_lens_l_01", "vfx/moments/factory/factory_het_cab_headlight_lens", "headlights", 0.0 );
	build_light( classname	, "headlight_lens_l_02", "tag_headlight_lens_l_02", "vfx/moments/factory/factory_het_cab_headlight_lens", "headlights", 0.0 );
	build_light( classname	, "headlight_lens_r_01", "tag_headlight_lens_r_01", "vfx/moments/factory/factory_het_cab_headlight_lens", "headlights", 0.0 );
	build_light( classname	, "headlight_lens_r_02", "tag_headlight_lens_r_02", "vfx/moments/factory/factory_het_cab_headlight_lens", "headlights", 0.0 );
	
			 //   classname    name 			   tag 					   effect 													    group 	   delay   
	build_light( classname, "back_running_light_l", "tag_back_running_light_l", "vfx/ambient/lights/amber_light_running_8_nolight", "running", 0.0 );
	build_light( classname, "back_running_light_r", "tag_back_running_light_r", "vfx/ambient/lights/amber_light_running_8_nolight", "running", 0.0 );
	build_light( classname, "bumper_light_l_01", "tag_bumper_light_l_01", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "bumper_light_l_02", "tag_bumper_light_l_02", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "bumper_light_r_01", "tag_bumper_light_r_01", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "bumper_light_r_02", "tag_bumper_light_r_02", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "top_light", "tag_top_light", "vfx/ambient/lights/amber_light_100_blinker_nolight", "running", 0.0 );
	build_light( classname, "step_light_l", "tag_step_light_l", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "step_light_r", "tag_step_light_r", "vfx/ambient/lights/amber_light_running_4_nolight", "running", 0.0 );
	build_light( classname, "windshield_light_01", "tag_windshield_light_01", "vfx/ambient/lights/amber_light_running_3_nolight", "running", 0.0 );
	build_light( classname, "windshield_light_02", "tag_windshield_light_02", "vfx/ambient/lights/amber_light_running_3_nolight", "running", 0.0 );
	build_light( classname, "windshield_light_03", "tag_windshield_light_03", "vfx/ambient/lights/amber_light_running_3_nolight", "running", 0.0 );
	build_light( classname, "windshield_light_04", "tag_windshield_light_04", "vfx/ambient/lights/amber_light_running_3_nolight", "running", 0.0 );
	build_light( classname, "windshield_light_05", "tag_windshield_light_05", "vfx/ambient/lights/amber_light_running_3_nolight", "running", 0.0 );
	build_light( classname, "windshield_light_06", "tag_windshield_light_06", "vfx/ambient/lights/amber_light_running_3_nolight", "running", 0.0 );
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

/*QUAKED script_vehicle_mobilerailgun_cab (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\mobile_railgun_cab::main( "mobile_railgun_cab", undefined, "script_vehicle_mobilerailgun_cab" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_mobile_railgun_cab

defaultmdl="vehicle_mobile_railgun_cab"
default:"vehicletype" "mobile_railgun_cab"
default:"script_team" "allies"
*/


/*QUAKED script_vehicle_mobilerailgun_cab_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\mobile_railgun_cab::main( "mobile_railgun_cab", undefined, "script_vehicle_mobilerailgun_cab_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_mobile_railgun_cab

defaultmdl="vehicle_mobile_railgun_cab"
default:"vehicletype" "mobile_railgun_cab_physics"
default:"script_team" "allies"
*/






