#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );


main( model, type, classname )
{	
	build_template( "humvee", model, type, classname );
	build_localinit( ::init_local );
	
	if( IsSubStr( classname, "turret" ) )
		build_turret( "minigun_m1a1_fast", "tag_turret", "weapon_chinese_brave_warrior_turret", undefined, "sentry", undefined, 0, 0, (0,0,-16) );
	
	//build_humvee_anims();
	
				  //   model 					     deathmodel 					    
	build_deathmodel( "vehicle_chinese_brave_warrior_anim", "vehicle_gaz_tigr_base_destroyed" );
	
	build_unload_groups( ::Unload_Groups );
	
	//gaz death fx/////
	level._effect[ "gazexplode" ]				= loadfx( "fx/explosions/vehicle_explosion_hummer_nodoors" );
	level._effect[ "gazsmfire" ]				= loadfx( "fx/fire/firelp_med_pm" );
	
			   //   effect 					   tag 			   sound 			    bEffectLooping    delay      bSoundlooping    waitDelay   
	//build_deathfx( "fx/fire/firelp_med_pm"	, "TAG_CAB_FIRE", "fire_metal_medium", undefined	   , undefined, true		   , 0 );
	//build_deathfx( "fx/explosions/vehicle_explosion_hummer_nodoors"	, "tag_deathfx" , "clkw_scn_ice_chase_expl"		 , undefined	   , undefined, undefined	   , undefined );
	build_deathfx( "fx/fire/firelp_med_pm"	, "tag_driver", "fire_metal_medium", undefined	   , undefined, true		   , 0 );
	build_deathfx( "fx/explosions/vehicle_explosion_hummer_nodoors"	, "tag_body" , "clkw_scn_ice_chase_expl"		 , undefined	   , undefined, undefined	   , undefined );

	//build_drive( %rubicon_driving_idle_forward, %rubicon_driving_idle_backward, 10 ); // sjp- changed to humvee anims, like the gaz, to save memory as they are already loaded.
	build_drive( %humvee_50cal_driving_idle_forward, %humvee_50cal_driving_idle_backward, 10 );
	
	build_life( 999, 500, 1500 );
	build_treadfx();
	build_team( "allies" );
	
	build_aianims( ::setanims, ::set_vehicle_anims );
	
			 //   model      name 					   tag 					   effect 							    group 		  
	build_light( classname, "headlight_truck_left"	, "tag_headlight_left"	, "fx/misc/car_headlight_jeep_l_clk"		, "headlights" );
	build_light( classname, "headlight_truck_right" , "tag_headlight_right" , "fx/misc/car_headlight_jeep_r_clk"		, "headlights" );
	build_light( classname, "taillight_truck_right" , "tag_brakelight_right", "fx/misc/car_taillight_jeep_r_clk"	 	, "headlights" );
	build_light( classname, "taillight_truck_left"	, "tag_brakelight_left" , "fx/misc/car_taillight_jeep_l_clk"	 	, "headlights" );
	build_light( classname, "brakelight_truck_right", "tag_brakelight_right", "fx/misc/car_brakelight_truck_R_pb"	 	, "brakelights" );
	build_light( classname, "brakelight_truck_left" , "tag_brakelight_left" , "fx/misc/car_brakelight_truck_L_pb"	 	, "brakelights" );
}

#using_animtree( "vehicles" );
init_local()
{
	if ( IsSubStr( self.vehicletype, "physics" ) )
	{
		anims			 = [];
		anims[ "idle"  ] = %humvee_antennas_idle_movement;
		anims[ "rot_l" ] = %humvee_antenna_L_rotate_360;
		anims[ "rot_r" ] = %humvee_antenna_R_rotate_360;
		thread maps\_vehicle_code::humvee_antenna_animates( anims );
	}
}

build_humvee_anims()
{
	build_aianims( ::setanims, ::set_vehicle_anims );
}

set_vehicle_anims( positions )
{
	positions[ 0 ].vehicle_getoutanim = %bravewarr_dismount_driver_door;
	positions[ 1 ].vehicle_getoutanim = %bravewarr_dismount_passenger_door;
	positions[ 2 ].vehicle_getoutanim = %bravewarr_dismount_backl_door;
	positions[ 3 ].vehicle_getoutanim = %bravewarr_dismount_backr_door;

	positions[ 0 ].vehicle_getinanim = %bravewarr_mount_driver_door;
	positions[ 1 ].vehicle_getinanim = %bravewarr_mount_passenger_door;
	positions[ 2 ].vehicle_getinanim = %bravewarr_mount_backl_door;
	positions[ 3 ].vehicle_getinanim = %bravewarr_mount_backr_door;
	
	positions[ 0 ].vehicle_getoutsound = "gaz_door_open";
	positions[ 1 ].vehicle_getoutsound = "gaz_door_open";
	positions[ 2 ].vehicle_getoutsound = "gaz_door_open";
	positions[ 3 ].vehicle_getoutsound = "gaz_door_open";

	positions[ 0 ].vehicle_getinsound = "gaz_door_close";
	positions[ 1 ].vehicle_getinsound = "gaz_door_close";
	positions[ 2 ].vehicle_getinsound = "gaz_door_close";
	positions[ 3 ].vehicle_getinsound = "gaz_door_close";

	return positions;
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0; i < 4; i++ )
		positions[ i ] = SpawnStruct();

	positions[ 0 ].sittag			   = "tag_driver";
	positions[ 0 ].getin			   = %bravewarr_mount_driver;
	positions[ 0 ].getout			   = %bravewarr_dismount_driver;
	positions[ 0 ].idle			 [ 0 ] = %bravewarr_idle_driver;
	positions[ 0 ].idle			 [ 1 ] = %bravewarr_idle_driver;
	positions[ 0 ].idle_alert 		   = %clockwork_exfil_jeepride_intense_keegan;
	positions[ 0 ].idleoccurrence[ 0 ] = 1000;
	positions[ 0 ].idleoccurrence[ 1 ] = 100;
	positions[ 0 ].death = %bravewarr_fallout_driver;
//	positions[ 0 ].unload_ondeath = .9;

	positions[ 1 ].sittag			   = "tag_passenger";
	positions[ 1 ].getin			   = %bravewarr_mount_passenger;
	positions[ 1 ].getout			   = %bravewarr_dismount_passenger;
	positions[ 1 ].idle			 [ 0 ] = %bravewarr_idle_passenger;
	positions[ 1 ].idle			 [ 1 ] = %bravewarr_idle_passenger;
	positions[ 1 ].idleoccurrence[ 0 ] = 1000;
	positions[ 1 ].idleoccurrence[ 1 ] = 100;
	positions[ 1 ].death = %bravewarr_fallout_passenger;
//	positions[ 1 ].unload_ondeath = .9;// doesn't have unload but lets other parts know not to delete him.

	positions[ 2 ].sittag			   = "tag_guy0";
	positions[ 2 ].getin			   = %bravewarr_mount_backL;
	positions[ 2 ].getout			   = %bravewarr_dismount_backL;
	positions[ 2 ].idle			 [ 0 ] = %bravewarr_idle_backL;
	positions[ 2 ].idle			 [ 1 ] = %bravewarr_idle_backL;
	positions[ 2 ].idleoccurrence[ 0 ] = 1000;
	positions[ 2 ].idleoccurrence[ 1 ] = 100;
	positions[ 2 ].death = %bravewarr_fallout_backL;
//	positions[ 2 ].unload_ondeath = .9;

	positions[ 3 ].sittag			   = "tag_guy1";
	positions[ 3 ].getin			   = %bravewarr_mount_backR;
	positions[ 3 ].getout			   = %bravewarr_dismount_backR;
	positions[ 3 ].idle			 [ 0 ] = %bravewarr_idle_backR;
	positions[ 3 ].idle			 [ 1 ] = %bravewarr_idle_backR;
	positions[ 3 ].idleoccurrence[ 0 ] = 1000;
	positions[ 3 ].idleoccurrence[ 1 ] = 100;
	positions[ 3 ].death = %bravewarr_fallout_backR;
//	positions[ 3 ].unload_ondeath = .9;
	
	return positions;
}

unload_groups()
{
	unload_groups							= [];
	unload_groups[ "passengers"			  ] = [];
	unload_groups[ "passenger_and_gunner" ] = [];
	unload_groups[ "passenger_and_driver" ] = [];
	unload_groups[ "all"				  ] = [];

	group												  = "passenger_and_gunner";
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
	
	group												  = "passenger_and_driver";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;

	group												  = "all";
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ group ][ unload_groups[ group ].size ] = 4;

	group												  = "passengers";
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
	unload_groups[ "default" ]							  = unload_groups[ "all" ];

	return unload_groups;
}

/*QUAKED script_vehicle_warrior (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_chinese_brave_warrior::main( "vehicle_chinese_brave_warrior_anim",  undefined, "script_vehicle_warrior" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_chinese_brave_warrior
sound, vehicle_hummer , vehicle_standard, all_sp
sound, vehicle_car_exp, vehicle_standard, all_sp

defaultmdl="vehicle_chinese_brave_warrior_anim"
default:"vehicletype" "humvee"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_warrior_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_chinese_brave_warrior::main( "vehicle_chinese_brave_warrior_anim", "warrior_opentop_physics", "script_vehicle_warrior_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_chinese_brave_warrior
sound, vehicle_hummer , vehicle_standard, all_sp
sound, vehicle_car_exp, vehicle_standard, all_sp

defaultmdl="vehicle_chinese_brave_warrior_anim"
default:"vehicletype" "warrior_opentop_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_warrior_physics_turret (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_chinese_brave_warrior::main( "vehicle_chinese_brave_warrior_anim", "warrior_opentop_physics", "script_vehicle_warrior_physics_turret" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_chinese_brave_warrior
sound, vehicle_hummer , vehicle_standard, all_sp
sound, vehicle_car_exp, vehicle_standard, all_sp

defaultmdl="vehicle_chinese_brave_warrior_anim"
default:"vehicletype" "warrior_opentop_physics"
default:"script_team" "allies"
*/