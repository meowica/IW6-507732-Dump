#include maps\_vehicle_aianim;
#include maps\_vehicle;
#include common_scripts\utility;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	fx();
	
	build_template( "gunboat", model, type, classname );
	build_localinit( ::init_local );
	
	//build_deathmodel( model );
	build_deathfx( "fx/_requests/gunboat/vehicle_explosion_gunboat", "tag_death_fx", undefined, undefined, undefined, undefined, 0 );
	
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	
	
//	build_aianims( ::setanims, ::set_vehicle_anims );
//	build_unload_groups( ::Unload_Groups );
	
//	build_aianims( ::setanims_turret, ::set_vehicle_anims );
	
	build_turret( "dshk_gunboat", "tag_turret", "weapon_dshk" );
	
	//build_treadfx();  //currently disabled because vehicle type "boat" isn't supported. http://bugzilla.infinityward.net/show_bug.cgi?id=85644
}

fx()
{
	level._effect[ "gunboat_wake" ] = LoadFX( "fx/_requests/gunboat/vehicle_wake_gunboat" );
}

init_local()
{
	self thread wake_fx();
}

wake_fx()
{
	// JC-ToDo: Gunboat wake logic is incorrect. Talk to Nate.
	PlayFXOnTag( getfx( "gunboat_wake" ), self, "j_bodymid" );
	
	self waittill( "death" );
	
	if ( IsDefined( self ) )
	{
		StopFXOnTag( getfx( "gunboat_wake" ), self, "j_bodymid" );
	}
}

//set_vehicle_anims( positions )
//{
//	return positions;
//}

//#using_animtree( "generic_human" );
//setanims()
//{
//	positions = [];
//	for ( i = 0;i < 6;i++ )
//		positions[ i ] = spawnstruct();
//
//	positions[ 0 ].sittag = "tag_body";
//	positions[ 1 ].sittag = "tag_body";
//	positions[ 2 ].sittag = "tag_body";
//	positions[ 3 ].sittag = "tag_body";
//	positions[ 4 ].sittag = "tag_body";
//	positions[ 5 ].sittag = "tag_body";
//
//	positions[ 0 ].idle = %oilrig_civ_escape_1_seal_A;
//	positions[ 1 ].idle = %oilrig_civ_escape_2_seal_A;
//	positions[ 2 ].idle = %oilrig_civ_escape_3_A;
//	positions[ 3 ].idle = %oilrig_civ_escape_4_A;
//	positions[ 4 ].idle = %oilrig_civ_escape_5_A;
//	positions[ 5 ].idle = %oilrig_civ_escape_6_A;
//
//	positions[ 0 ].getout = %pickup_driver_climb_out;
//	positions[ 1 ].getout = %pickup_driver_climb_out;
//	positions[ 2 ].getout = %pickup_passenger_climb_out;
//	positions[ 3 ].getout = %pickup_passenger_climb_out;
//	positions[ 4 ].getout = %pickup_passenger_climb_out;
//	positions[ 5 ].getout = %pickup_passenger_climb_out;
//
//	return positions;
//}
//
//unload_groups()
//{
//	unload_groups = [];
//	unload_groups[ "passengers" ] = [];
//	unload_groups[ "all" ] = [];
//
//	group = "passengers";
//	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
//
//	group = "all";
//	unload_groups[ group ][ unload_groups[ group ].size ] = 0;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 1;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 2;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 3;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 4;
//	unload_groups[ group ][ unload_groups[ group ].size ] = 5;
//
//	unload_groups[ "default" ] = unload_groups[ "all" ];
//
//	return unload_groups;
//}

/*QUAKED script_vehicle_gunboat (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_gunboat::main( "vehicle_gun_boat_iw6", undefined, "script_vehicle_gunboat" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_gunboat
sound,vehicle_gunboat,vehicle_standard,all_sp

defaultmdl="vehicle_gun_boat_iw6"
default:"vehicletype" "gunboat"
default:"script_team" "axis"
*/

/*QUAKED script_vehicle_gunboat_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_gunboat::main( "vehicle_gun_boat_iw6","gunboat_physics", "script_vehicle_gunboat_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_gunboat
sound,vehicle_gunboat,vehicle_standard,all_sp

defaultmdl="vehicle_gun_boat_iw6"
default:"vehicletype" "gunboat_physics"
default:"script_team" "axis"
*/


/*QUAKED misc_turret_gunboat_dshk (1 0 0) (-16 -16 0) (16 16 56) pre-placed
Spawn Flags:
	pre-placed - Means it already exists in map.  Used by script only.

Key Pairs:
	leftarc - horizonal left fire arc.
	rightarc - horizonal left fire arc.
	toparc - vertical top fire arc.
	bottomarc - vertical bottom fire arc.
	yawconvergencetime - time (in seconds) to converge horizontally to target.
	pitchconvergencetime - time (in seconds) to converge vertically to target.
	suppressionTime - time (in seconds) that the turret will suppress a target hidden behind cover
	maxrange - maximum firing/sight range.
	aiSpread - spread of the bullets out of the muzzle in degrees when used by the AI
	playerSpread - spread of the bullets out of the muzzle in degrees when used by the player
	
	defaultmdl="weapon_dshk"
	default:"weaponinfo" "dshk_gunboat"
	default:"targetname" "delete_on_load"
*/