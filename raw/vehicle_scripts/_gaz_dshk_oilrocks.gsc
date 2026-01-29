#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	build_template( "gaz_tigr_turret_oilrocks", model, type, classname );
	build_localinit( ::init_local );

	build_unload_groups( ::Unload_Groups );

	build_drive( %humvee_50cal_driving_idle_forward, %humvee_50cal_driving_idle_backward, 10 );
	
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	
	build_aianims( ::setanims_turret, ::set_vehicle_anims );
	build_turret( "dshk_gaz", "tag_turret", "weapon_dshk_turret", undefined, "auto_ai", 0.2, -20, -14 );
	
	build_gaz_death( classname );
	
	level._effect[ "FX_gaz_splash" ]					= LoadFX( "fx/water/water_splash_large" );
}

init_local()
{
	thread BridgeDeath();
}

BridgeDeath()
{
	self waittill ("death" );
	
	if ( IsDefined( self ) && is_touching_bridge_trigger() )
	{
		if( self Vehicle_GetSpeed() == 0 )
			return;
		self Vehicle_OrientTo( self.origin, self.angles, self Vehicle_GetSpeed(), 0 );
		self AnimScripted( "bridgdeath", self.origin, self.angles, %oilrocks_car_explosion_right );
		wait 0.8;
		if ( !IsDefined( self ) )
			return;
		PlayFX( getfx( "FX_gaz_splash" ), self.origin );
		self Delete();
	}
}

is_touching_bridge_trigger()
{
	triggers = GetEntArray( "bridge_death", "targetname" );
	foreach ( trigger in triggers )
		if ( IsPointInVolume( self.origin, trigger ) )
			return true;
	return false;
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

	group												  = "gunner";
	unload_groups[ group ]								  = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	group												  = "all";
	unload_groups[ group ]								  = [];
	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
	unload_groups[ group ][ unload_groups[ group ].size ] = 3;

	unload_groups[ "default" ] = unload_groups[ "all" ];

	return unload_groups;
}

build_gaz_death( classname )
{
	//build_deathmodel( "vehicle_gaz_tigr_harbor", "vehicle_gaz_tigr_harbor_destroyed" );
	build_deathmodel( "vehicle_gaz_tigr_base_oilrocks", "vehicle_gaz_tigr_base_destroyed_oilrocks" );
	//"Name: build_radiusdamage( <offset> , <range> , <maxdamage> , <mindamage> , <bKillplayer>, <delay> )"
	build_radiusdamage( ( 0, 0, 32 ), 300, 200, 0, false );
			   //   effect 												      tag 			      sound 			   bEffectLooping    delay    bSoundlooping    waitDelay    stayontag   
	build_deathfx( "fx/_requests/oilrocks/optimize_temp/deathfx_gaz_delete", "body_animate_jnt", "exp_armor_vehicle", undefined		  , 0	   , undefined		, undefined	 , true );
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

set_vehicle_anims_turret( positions )
{
	positions[ 3 ].vehicle_getoutanim = %gaz_turret_getout_gaz;

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

	positions[ 0 ].death				   = %gaz_dismount_frontl; // todo: fixme
	positions[ 0 ].death_no_ragdoll		   = true;
	//positions[ 0 ].death_delayed_ragdoll = 3;

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
	
	positions[ 3 ].mgturret				   = 0;// which of the turrets is this guy going to use
	positions[ 3 ].passenger_2_turret_func = ::gaz_turret_guy_gettin_func;
	positions[ 3 ].sittag				   = "tag_guy_turret";
	positions[ 3 ].getout				   = %gaz_turret_getout_guy1;
	positions							   = set_vehicle_anims_turret( positions );

	return positions;
}

gaz_turret_guy_gettin_func( vehicle, guy, pos, turret )
{
	// todo
	/*
	animation = %humvee_passenger_2_turret;
	guy animscripts\hummer_turret\common::guy_goes_directly_to_turret( vehicle, pos, turret, animation );	
	*/
}

/*QUAKED script_vehicle_gaz_tigr_turret_oilrocks (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_gaz_dshk_oilrocks::main( "vehicle_gaz_tigr_base_oilrocks", undefined, "script_vehicle_gaz_tigr_turret_oilrocks" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_gaz_tigr_turret_oilrocks
sound,vehicle_gaz_tigr_harbor,vehicle_standard,all_sp

defaultmdl="vehicle_gaz_tigr_base_oilrocks"
default:"vehicletype" "gaz_tigr_turret_oilrocks"
default:"script_team" "axis"
*/









