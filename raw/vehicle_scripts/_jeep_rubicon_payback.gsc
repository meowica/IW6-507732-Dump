#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );


main( model, type, classname )
{
	build_template( "humvee", model, type, classname );
	build_localinit( ::init_local );
	
	if( IsSubStr( classname, "turret" ) )
		build_turret( "minigun_m1a1", "tag_turret", "weapon_m1a1_minigun", undefined, "sentry", undefined, 0, 0 );

	build_humvee_anims();
	
				  //   model 					     deathmodel 					    
	build_deathmodel( "vehicle_jeep_rubicon"	  , "vehicle_hummer_opentop_destroyed" );
	build_deathmodel( "vehicle_jeep_rubicon_white", "vehicle_hummer_opentop_destroyed" );
	
	build_unload_groups( ::Unload_Groups );

	rubicon_death_fx								 = [];
	rubicon_death_fx[ "vehicle_jeep_rubicon"	   ] = "fx/explosions/vehicle_explosion_hummer_nodoors";
	rubicon_death_fx[ "vehicle_jeep_rubicon_white" ] = "fx/explosions/vehicle_explosion_hummer_nodoors";
	rubicon_death_fx[ "vehicle_chinese_brave_warrior" ] = "fx/explosions/vehicle_explosion_hummer_nodoors";
	
			   //   effect 					   tag 			   sound 			    bEffectLooping    delay      bSoundlooping    waitDelay   
	build_deathfx( "fx/fire/firelp_med_pm"		, "TAG_CAB_FIRE", "fire_metal_medium", undefined	   , undefined, true		   , 0 );
	build_deathfx( rubicon_death_fx[ model ], "tag_deathfx" , "car_explode"		 , undefined	   , undefined, undefined	   , undefined );

	build_drive( %rubicon_driving_idle_forward, %rubicon_driving_idle_backward, 10 );
	
	build_life( 999, 500, 1500 );
	build_team( "allies" );
	
	build_aianims( ::setanims, ::set_vehicle_anims );
	
			 //   model      name 					   tag 					   effect 							    group 		  
	build_light( classname, "headlight_truck_left"	, "tag_headlight_left"	, "fx/maps/payback/payback_headlights_l", "headlights" );
	build_light( classname, "headlight_truck_right" , "tag_headlight_right" , "fx/maps/payback/payback_headlights_r", "headlights" );
	build_light( classname, "taillight_truck_right" , "tag_brakelight_right", "fx/misc/car_taillight_truck_R_pb"	 , "headlights" );
	build_light( classname, "taillight_truck_left"	, "tag_brakelight_left" , "fx/misc/car_taillight_truck_L_pb"	 , "headlights" );
	build_light( classname, "brakelight_truck_right", "tag_brakelight_right", "fx/misc/car_brakelight_truck_R_pb"	 , "brakelights" );
	build_light( classname, "brakelight_truck_left" , "tag_brakelight_left" , "fx/misc/car_brakelight_truck_L_pb"	 , "brakelights" );
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
	return positions;
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	for ( i = 0; i < 4; i++ )
		positions[ i ] = SpawnStruct();

	positions[ 0 ].sittag			   = "tag_driver";
	positions[ 0 ].getin			   = %rubicon_mount_driver;
	positions[ 0 ].getout			   = %rubicon_dismount_driver;
	positions[ 0 ].idle			 [ 0 ] = %rubicon_idle_driver;
	positions[ 0 ].idle			 [ 1 ] = %rubicon_duck_driver;
	positions[ 0 ].idleoccurrence[ 0 ] = 1000;
	positions[ 0 ].idleoccurrence[ 1 ] = 100;
	positions[ 0 ].death = %rubicon_fallout_driver;
//	positions[ 0 ].unload_ondeath = .9;

	positions[ 1 ].sittag			   = "tag_passenger";
	positions[ 1 ].getin			   = %rubicon_mount_passenger;
	positions[ 1 ].getout			   = %rubicon_dismount_passenger;
	positions[ 1 ].idle			 [ 0 ] = %rubicon_idle_passenger;
	positions[ 1 ].idle			 [ 1 ] = %rubicon_duck_passenger;
	positions[ 1 ].idleoccurrence[ 0 ] = 1000;
	positions[ 1 ].idleoccurrence[ 1 ] = 100;
	positions[ 1 ].death = %rubicon_fallout_passenger;
//	positions[ 1 ].unload_ondeath = .9;// doesn't have unload but lets other parts know not to delete him.

	positions[ 2 ].sittag			   = "tag_guy0";
	positions[ 2 ].getin			   = %rubicon_mount_backL;
	positions[ 2 ].getout			   = %rubicon_dismount_backL;
	positions[ 2 ].idle			 [ 0 ] = %rubicon_idle_backL;
	positions[ 2 ].idle			 [ 1 ] = %rubicon_duck_backL;
	positions[ 2 ].idleoccurrence[ 0 ] = 1000;
	positions[ 2 ].idleoccurrence[ 1 ] = 100;
	positions[ 2 ].death = %rubicon_fallout_backL;
//	positions[ 2 ].unload_ondeath = .9;

	positions[ 3 ].sittag			   = "tag_guy1";
	positions[ 3 ].getin			   = %rubicon_mount_backR;
	positions[ 3 ].getout			   = %rubicon_dismount_backR;
	positions[ 3 ].idle			 [ 0 ] = %rubicon_idle_backR;
	positions[ 3 ].idle			 [ 1 ] = %rubicon_duck_backR;
	positions[ 3 ].idleoccurrence[ 0 ] = 1000;
	positions[ 3 ].idleoccurrence[ 1 ] = 100;
	positions[ 3 ].death = %rubicon_fallout_backR;
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

/*QUAKED script_vehicle_jeep_rubicon_payback (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_jeep_rubicon_payback::main( "vehicle_jeep_rubicon",undefined, "script_vehicle_jeep_rubicon_payback" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_jeep_rubicon_payback
sound,vehicle_hummer,vehicle_standard,all_sp


defaultmdl="vehicle_jeep_rubicon"
default:"vehicletype" "humvee"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_jeep_rubicon_payback_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_jeep_rubicon_payback::main( "vehicle_jeep_rubicon", "hummer_opentop_physics", "script_vehicle_jeep_rubicon_payback_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_jeep_rubicon_payback
sound, vehicle_hummer , vehicle_standard, all_sp
sound, vehicle_car_exp, vehicle_standard, all_sp

defaultmdl="vehicle_jeep_rubicon"
default:"vehicletype" "hummer_opentop_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_jeep_rubicon_white_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_jeep_rubicon_payback::main( "vehicle_jeep_rubicon_white", "hummer_opentop_physics", "script_vehicle_jeep_rubicon_white_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_jeep_rubicon_payback
sound, vehicle_hummer , vehicle_standard, all_sp
sound, vehicle_car_exp, vehicle_standard, all_sp

defaultmdl="vehicle_jeep_rubicon_white"
default:"vehicletype" "hummer_opentop_physics"
default:"script_team" "allies"
*/
