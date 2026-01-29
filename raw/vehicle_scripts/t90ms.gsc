#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "t90ms", model, type, classname );
	build_localinit( ::init_local );
	
	if ( classname == "script_vehicle_t90ms_sand" )
	{
		build_deathmodel( "vehicle_t90ms_tank_iw6", "vehicle_t90_tank_woodland_d", 0.25 );
				   //   effect 								   tag 		      sound 			   bEffectLooping    delay 	    bSoundlooping    waitDelay   
		build_deathfx( "fx/explosions/vehicle_tank_explosion", "tag_deathfx", "exp_armor_vehicle", undefined		  , undefined, undefined	  , 0 );
		build_deathfx( "fx/fire/t90_death_fire_smoke"		 , "tag_deathfx", "fire_metal_medium", undefined		  , undefined, true			  , 0 );
	}
	else
	{
		build_deathmodel( model, "vehicle_t90_tank_woodland_dt" );
		build_deathfx( "fx/explosions/vehicle_explosion_t90", "tag_deathfx", "exp_armor_vehicle", undefined		  , undefined, undefined	  , 0 );
		build_deathfx( "fx/fire/t90_death_fire_smoke"		, "tag_deathfx", "fire_metal_medium", undefined		  , undefined, true			  , 0 );
	}
	
	build_shoot_shock( "tankblast" );
	build_drive( %t90ms_driving_idle_forward, %t90ms_driving_idle_forward, 10 );
	
	if( !IsSubStr( classname, "sand" ) )
		build_turret( "t90_turret2", "tag_turret2", "vehicle_t90_PKT_Coaxial_MG" );
	
	add_turret = IsSubStr( classname, "_turret" ) || IsSubStr( classname, "sand" );

	if ( add_turret )
		build_turret( "dshk_gaz", "tag_turret_hatch", "weapon_dshk_turret_t90", 1028, "auto_ai", 0.2, 20, -14);
		
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_rumble( "tank_rumble", 0.15, 4.5, 600, 1, 1 );
	build_team( "axis" );
	build_mainturret();
	build_frontarmor( 0.33 ); // regens this much of the damage from attacks to the front
	build_bulletshield( true );
	
	if ( add_turret ) //only build positions if we'll need one
	{
		//first function is responsible for creating the positions in the vehicle
		build_aianims( ::setanims, ::set_vehicle_anims );
	}
}

init_local()
{
}

set_vehicle_anims( positions )
{
	return positions;
}

#using_animtree( "generic_human" );
setanims()
{
	positions = [];
	
	//mg gunner
	positions[ 0 ] = spawnstruct();
	
	positions[ 0 ].sittag = "tag_turret_hatch";
	positions[ 0 ].sittag_offset = ( 0, 0, -16 );
	
	positions[ 0 ].bHasGunWhileRiding = false;
	positions[ 0 ].idle = %gaz_turret_idle;
	positions[ 0 ].mgturret = 1;// which of the turrets is this guy going to use	
	
	return positions;
}

/*QUAKED script_vehicle_t90ms (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\t90ms::main( "vehicle_t90ms_tank_iw6", undefined, "script_vehicle_t90ms" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_t90ms
sound,vehicle_t90,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_t90ms_tank_iw6"
default:"vehicletype" "t90ms"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_t90ms_sand (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\t90ms::main( "vehicle_t90ms_tank_iw6", "t90_sand", "script_vehicle_t90ms_sand" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_t90ms
sound,vehicle_t90,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_t90ms_tank_iw6"
default:"vehicletype" "t90_sand"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_t90ms_trophy (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\t90ms::main( "vehicle_t90ms_tank_iw6", "t90_trophy", "script_vehicle_t90ms_trophy" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_t90ms
sound,vehicle_t90,vehicle_standard,all_sp
sound,vehicle_armor_exp,vehicle_standard,all_sp

defaultmdl="vehicle_t90ms_tank_iw6"
default:"vehicletype" "t90_trophy"
default:"script_team" "axis"
*/

