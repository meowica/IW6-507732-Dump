#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "iveco_lynx_turret", model, type, classname );
	build_localinit( ::init_local );
	build_unload_groups( ::unload_groups );
	
	build_aianims( ::setanims_turret, ::set_vehicle_anims );
	
	build_drive( %iveco_lynx_idle_driving_idle_forward, %iveco_lynx_idle_driving_idle_forward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	
	build_lynx_death( classname );
	
	build_turret( "dshk_gaz_factory", "tag_turret", "weapon_dshk", undefined, "auto_ai", 0.2, -20, -14 );
	
	// Re-enable headlights once the destroyed version has proper tags
	
				 //   classname    name 		   tag 					   effect 						      group      delay   
	build_light( classname	, "headlight_L" , "TAG_HEADLIGHT_LEFT"	, "fx/misc/spotlight_btr80_daytime", "running", 0.0 );
	build_light( classname	, "headlight_R" , "TAG_HEADLIGHT_RIGHT" , "fx/misc/spotlight_btr80_daytime", "running", 0.0 );
	build_light( classname	, "brakelight_L", "TAG_BRAKELIGHT_LEFT" , "fx/misc/car_taillight_btr80_eye", "running", 0.0 );
	build_light( classname	, "brakelight_R", "TAG_BRAKELIGHT_RIGHT", "fx/misc/car_taillight_btr80_eye", "running", 0.0 );
	
			 //   classname    name 		   tag 					   effect 							    group 	      delay   
	build_light( classname	, "headlight_L" , "TAG_HEADLIGHT_LEFT"	, "fx/misc/car_headlight_gaz_l_night", "headlights", 0.0 );
	build_light( classname	, "headlight_R" , "TAG_HEADLIGHT_RIGHT" , "fx/misc/car_headlight_gaz_r_night", "headlights", 0.0 );
	build_light( classname	, "brakelight_L", "TAG_BRAKELIGHT_LEFT" , "fx/misc/car_taillight_btr80_eye"	 , "headlights", 0.0 );
	build_light( classname	, "brakelight_R", "TAG_BRAKELIGHT_RIGHT", "fx/misc/car_taillight_btr80_eye"	 , "headlights", 0.0 );
	
}

init_local()
{
}

build_lynx_death( classname )
{
	// death fx/////
	level._effect[ "lynxfire"	] = LoadFX( "fx/fire/firelp_med_pm_nolight" );
	level._effect[ "lynxexplode" ] = LoadFX( "fx/explosions/vehicle_explosion_gaz" );
	level._effect[ "lynxcookoff" ] = LoadFX( "fx/explosions/ammo_cookoff" );
	level._effect[ "lynxsmfire"	] = LoadFX( "fx/fire/firelp_small_pm_a" );

				  //   model 				      deathmodel 						  
	build_deathmodel( "vehicle_iveco_lynx_iw6", "vehicle_iveco_lynx_destroyed_iw6_static" );
	
	// Change these tags once the destroyed version has them
	//	build_deathfx( effect, 									tag, 					sound, 				bEffectLooping, 	delay, 			bSoundlooping, waitDelay, stayontag, notifyString )
	build_deathfx( "fx/explosions/vehicle_explosion_gaz", "tag_origin" );
		
			   //   effect 						     tag 		     sound 	    bEffectLooping    delay      bSoundlooping    waitDelay   
	build_deathfx( "fx/fire/firelp_med_pm_nolight", "tag_origin"  , undefined, undefined	   , undefined, true		   , 0 );
	build_deathfx( "fx/fire/firelp_small_pm_a"	  , "tag_origin", undefined, undefined	   , undefined, true		   , 3 );
	
	build_deathquake( 1, 1.6, 500 );

}

unload_groups()
{
	unload_groups = [];

	group												  = "passengers";
	unload_groups[ group ]								  = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	
	group												  = "all_but_gunner";
	unload_groups[ group ]								  = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;

	group												  = "rear_driver_side";
	unload_groups[ group ]								  = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;

	group												  = "all";
	unload_groups[ group ]								  = [];
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
	positions[ 0 ].vehicle_getoutanim = %gaz_dismount_frontl_door;
	positions[ 1 ].vehicle_getoutanim = %gaz_dismount_frontr_door;
	positions[ 2 ].vehicle_getoutanim = %gaz_dismount_backl_door;
	positions[ 3 ].vehicle_getoutanim = %gaz_dismount_backr_door;

	positions[ 0 ].vehicle_getinanim = %gaz_mount_frontl_door;
	positions[ 1 ].vehicle_getinanim = %gaz_mount_frontr_door;
	positions[ 2 ].vehicle_getinanim = %gaz_enter_back_door;
	positions[ 3 ].vehicle_getinanim = %gaz_enter_back_door;

	// Need audio to take a look at aliases for this part
	/*
	positions[ 0 ].vehicle_getoutsound = "gaz_door_open";
	positions[ 1 ].vehicle_getoutsound = "gaz_door_open";
	positions[ 2 ].vehicle_getoutsound = "gaz_door_open";
	positions[ 3 ].vehicle_getoutsound = "gaz_door_open";

	positions[ 0 ].vehicle_getinsound = "gaz_door_close";
	positions[ 1 ].vehicle_getinsound = "gaz_door_close";
	positions[ 2 ].vehicle_getinsound = "gaz_door_close";
	positions[ 3 ].vehicle_getinsound = "gaz_door_close";
	*/
	return positions;
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0;i < 4;i++ )
		positions[ i ] = SpawnStruct();

	positions[ 0 ].sittag = "tag_driver";
	positions[ 1 ].sittag = "tag_passenger";
	positions[ 2 ].sittag = "tag_guy0";
	positions[ 3 ].sittag = "tag_guy1";

	positions[ 0 ].bHasGunWhileRiding = false;

	positions[ 0 ].death				 = %gaz_dismount_frontl; // todo: fixme
	//positions[ 0 ].death_no_ragdoll	 = true;
	positions[ 0 ].death_delayed_ragdoll = 3;

	positions[ 0 ].idle = %gaz_idle_frontl;
	positions[ 1 ].idle = %gaz_idle_frontr;
	positions[ 2 ].idle = %gaz_idle_backl;
	positions[ 3 ].idle = %gaz_idle_backr;

	positions[ 0 ].getout = %gaz_dismount_frontl;
	positions[ 1 ].getout = %gaz_dismount_frontr;
	positions[ 2 ].getout = %gaz_dismount_backl;
	positions[ 3 ].getout = %gaz_dismount_backr;

	positions[ 0 ].getin = %gaz_mount_frontl;
	positions[ 1 ].getin = %gaz_mount_frontr;
	positions[ 2 ].getin = %gaz_enter_backr;
	positions[ 3 ].getin = %gaz_enter_backl;
	
	return positions;
}

setanims_turret()
{
	positions = setanims();
	
	// override some of the settings for the turret guy
	positions[ 3 ].mgturret				   = 0;// which of the turrets is this guy going to use
	positions[ 3 ].sittag				   = "tag_guy_turret";

	return positions;
}


/*QUAKED script_vehicle_iveco_lynx_turret (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\iveco_lynx_turret::main( "vehicle_iveco_lynx_iw6", undefined, "script_vehicle_iveco_lynx_turret" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_iveco_lynx_turret

defaultmdl="vehicle_iveco_lynx_iw6"
default:"vehicletype" "iveco_lynx_turret"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_iveco_lynx_turret_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\iveco_lynx_turret::main( "vehicle_iveco_lynx_iw6", "iveco_lynx_turret_physics", "script_vehicle_iveco_lynx_turret_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_iveco_lynx_turret

defaultmdl="vehicle_iveco_lynx_iw6"
default:"vehicletype" "iveco_lynx_turret_physics"
default:"script_team" "axis"
*/