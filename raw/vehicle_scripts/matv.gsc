#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "matv", model, type, classname  );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_matv", "vehicle_matv" );

	hummer_death_fx = [];
	hummer_death_fx[ "vehicle_matv" ] = "fx/explosions/vehicle_explosion_hummer";

	build_unload_groups( ::Unload_Groups );

	build_deathfx( "fx/fire/firelp_med_pm", "TAG_PASSENGER", "fire_metal_medium", undefined, undefined, true, 0 );
	build_deathfx( hummer_death_fx[ model ], "tag_death_fx", "car_explode" );

	build_drive( %humvee_50cal_driving_idle_forward, %humvee_50cal_driving_idle_backward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	anim_func = ::setanims;
	if ( isdefined( type ) && issubstr( type, "open" ) )
		anim_func = ::opentop_anims;
			
	build_aianims( anim_func, ::set_vehicle_anims );
	

}

#using_animtree( "vehicles" );
init_local()
{
	if ( issubstr( self.vehicletype, "physics" ) )
	{
		anims = [];
		anims[ "idle" ] = %humvee_antennas_idle_movement;
		anims[ "rot_l" ] = %humvee_antenna_L_rotate_360;
		anims[ "rot_r" ] = %humvee_antenna_R_rotate_360;
		thread maps\_vehicle_code::humvee_antenna_animates( anims );
	}
	
}


unload_groups()
{
	unload_groups = [];

	group = "passengers";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	group = "rear_driver_side";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;

	group = "all";
	unload_groups[ group ] = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}




#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
	positions[ 0 ].vehicle_getoutanim = %humvee_dismount_frontL_door;
	positions[ 1 ].vehicle_getoutanim = %humvee_dismount_frontR_door;
	positions[ 2 ].vehicle_getoutanim = %humvee_dismount_backL_door;
	positions[ 3 ].vehicle_getoutanim = %humvee_dismount_backR_door;

	positions[ 0 ].vehicle_getinanim = %humvee_mount_frontL_door;
	positions[ 1 ].vehicle_getinanim = %humvee_mount_frontR_door;
	positions[ 2 ].vehicle_getinanim = %humvee_mount_backL_door;
	positions[ 3 ].vehicle_getinanim = %humvee_mount_backR_door;

	positions[ 0 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 1 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 2 ].vehicle_getoutsound = "hummer_door_open";
	positions[ 3 ].vehicle_getoutsound = "hummer_door_open";

	positions[ 0 ].vehicle_getinsound = "hummer_door_close";
	positions[ 1 ].vehicle_getinsound = "hummer_door_close";
	positions[ 2 ].vehicle_getinsound = "hummer_door_close";
	positions[ 3 ].vehicle_getinsound = "hummer_door_close";

	return positions;
}




#using_animtree( "generic_human" );


opentop_anims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 0 ].idle = %humvee_idle_frontL;
	positions[ 1 ].idle = %humvee_idle_frontR;
	positions[ 2 ].idle = %humvee_idle_backL;
	positions[ 3 ].idle = %humvee_idle_backR;

	positions[ 0 ].getout = %humvee_driver_climb_out;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	positions[ 2 ].getout = %humvee_passenger_out_L;
	positions[ 3 ].getout = %humvee_passenger_out_R;

	positions[ 0 ].getin = %humvee_mount_frontL_nodoor;
	positions[ 1 ].getin = %humvee_mount_frontR_nodoor;
	positions[ 2 ].getin = %humvee_mount_backL_nodoor;
	positions[ 3 ].getin = %humvee_mount_backR_nodoor;
	
	return positions;
}

setanims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 0 ].idle = %humvee_idle_frontL;
	positions[ 1 ].idle = %humvee_idle_frontR;
	positions[ 2 ].idle = %humvee_idle_backL;
	positions[ 3 ].idle = %humvee_idle_backR;

	positions[ 0 ].getout = %humvee_driver_climb_out;
	positions[ 1 ].getout = %humvee_passenger_out_R;
	positions[ 2 ].getout = %humvee_passenger_out_L;
	positions[ 3 ].getout = %humvee_passenger_out_R;

	positions[ 0 ].getin = %humvee_mount_frontL;
	positions[ 1 ].getin = %humvee_mount_frontR;
	positions[ 2 ].getin = %humvee_mount_backL; 
	positions[ 3 ].getin = %humvee_mount_backR;
	
	return positions;
}




/*QUAKED script_vehicle_matv (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\matv::main( "vehicle_matv", undefined, "script_vehicle_matv" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_matv
sound,vehicle_car_exp,vehicle_standard,all_sp
sound,vehicle_hummer,vehicle_standard,all_sp


defaultmdl="vehicle_matv"
default:"vehicletype" "matv"
default:"script_team" "allies"
*/
