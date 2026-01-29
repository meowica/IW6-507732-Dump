#include maps\_vehicle_aianim;
#include maps\_vehicle;
#include maps\_utility;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "m1a1", model, type, classname );
	build_localinit( ::init_local );
	
	build_deathmodel( "vehicle_m1a1_abrams", "vehicle_t90_tank_woodland_d", 0.25 );
			   //   effect 								    tag 		   sound 			    bEffectLooping    delay      bSoundlooping    waitDelay   
	build_deathfx( "fx/explosions/vehicle_tank_explosion", "tag_deathfx", "exp_armor_vehicle", undefined	   , undefined, undefined	   , 0 );
	build_deathfx( "fx/fire/t90_death_fire_smoke"		 , "tag_deathfx", "fire_metal_medium", undefined	   , undefined, true		   , 0 );
	
	
	// Annoying shock, remove for now and reduce later
	//build_shoot_shock( "tankblast" );
	build_drive( %abrams_movement, %abrams_movement_backwards, 10 );
	build_exhaust( "fx/distortion/abrams_exhaust" );
	build_deckdust( "fx/dust/abrams_deck_dust" );
	build_deathfx( "fx/explosions/vehicle_explosion_m1a1", 			"tag_deathfx", 			"exp_armor_vehicle", 		undefined, 			undefined, 		undefined, 		0, undefined, undefined, undefined, 10 );
	
	build_team( "allies" );
	
	if ( classname == "script_vehicle_m1a1_abrams_sand_minigunonly" )
	{
		build_turret( "minigun_m1a1", "tag_turret_mg_r", "weapon_m1a1_minigun", undefined, "sentry", undefined, 0, 0 );
	}
	else
	{
		if ( classname != "script_vehicle_m1a1_abrams_sand_noturrets" )
		{
			build_turret( "m1a1_coaxial_mg", "tag_coax_mg", "vehicle_m1a1_abrams_PKT_Coaxial_MG_woodland", undefined, undefined, undefined, 0, 0 );
			build_mainturret();
		}
		
		if( IsSubStr( classname, "_turret" ) )
		{
			build_turret( "minigun_m1a1", "tag_turret_mg_r", "weapon_m1a1_minigun", undefined, "sentry", undefined, 0, 0 );
			build_turret( "m1a1_coaxial_mg", "tag_coax_mg", "vehicle_m1a1_abrams_PKT_Coaxial_MG_woodland", undefined, undefined, undefined, 0, 0 );
			build_mainturret();
		}
	}
	
	build_treadfx();
	build_life( 999, 500, 1500 );
	
	// Rumble was for players on the ground near this tank when it was moving
	// not for a player driving
	//build_rumble( "tank_rumble", 0.15, 4.5, 900, 1, 1 );
	
	build_aianims( ::setanims, ::set_vehicle_anims );
	build_frontarmor( 1 ); // regens this much of the damage from attacks to the front	
}

init_local()
{
	waittillframeend; //let riders be defined;
	foreach ( rider in self.riders )
	{
		rider thread magic_bullet_shield( true );
	}
}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
	//loaderText
	this_position								   = 0;
	positions[ this_position ].vehicle_turret_fire = %abrams_loader_shell;
	return positions;
}

//level.hero_tank.riders[0] linkto( level.hero_tank, "tag_turret_mg_r", (0,0,-38),(0,0,0) )
#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	//gunner
	this_position			   = 0;
	position				   = SpawnStruct();
	position.idle			   = %abrams_loader_load;
	position.turret_fire	   = %abrams_loader_load;
	position.turret_fire_tag   = "tag_guy1";
	position.sittag			   = "tag_guy1";
	positions[ this_position ] = position;

	//loader
	this_position			   = 1;
	position				   = SpawnStruct();
	position.idle			   = %hamburg_tank_driver_afterfall_loop;
	position.sittag			   = "tag_guy0";
	positions[ this_position ] = position;
	
	//minigun guy
	this_position					 = 2;
	position						 = SpawnStruct();
	position.mgturret				 = 0; // which of the turrets is this guy going to use
	position.passenger_2_turret_func = ::humvee_turret_guy_gettin_func;
	position.sittag					 = "tag_turret_mg_r";
	position.sittag_offset			 = ( 0, 0, -40 );
	positions[ this_position ]		 = position;

	return positions;
}

humvee_turret_guy_gettin_func( vehicle, guy, pos, turret )
{
	animation = %humvee_passenger_2_turret;
	guy animscripts\hummer_turret\common::guy_goes_directly_to_turret( vehicle, pos, turret, animation );	
}

/*QUAKED script_vehicle_m1a1_abrams_player_drivable (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams_viewmodel", "m1a1_player_drivable", "script_vehicle_m1a1_abrams_player_drivable" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp

defaultmdl="vehicle_m1a1_abrams_viewmodel"
default:"vehicletype" "m1a1_player_drivable"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_m1a1_abrams_player_drivable_test (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams_viewmodel", "m1a1_player_drivable_test", "script_vehicle_m1a1_abrams_player_drivable_test" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp

defaultmdl="vehicle_m1a1_abrams_viewmodel"
default:"vehicletype" "m1a1_player_drivable_test"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_m1a1_abrams_player_drivable_relative (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams_viewmodel", "m1a1_player_drivable_relative", "script_vehicle_m1a1_abrams_player_drivable_relative" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp

defaultmdl="vehicle_m1a1_abrams_viewmodel"
default:"vehicletype" "m1a1_player_drivable_relative"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_m1a1_abrams_player_drivable_relative_physics (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams_viewmodel", "m1a1_player_drivable_relative_physics", "script_vehicle_m1a1_abrams_player_drivable_relative_physics" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp

defaultmdl="vehicle_m1a1_abrams_viewmodel"
default:"vehicletype" "m1a1_player_drivable_relative_physics"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_m1a1_abrams_sand (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams", "m1a1_sand", "script_vehicle_m1a1_abrams_sand" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp

defaultmdl="vehicle_m1a1_abrams"
default:"vehicletype" "m1a1_sand"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_m1a1_abrams_sand_minigunonly (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams_mp", "m1a1_sand", "script_vehicle_m1a1_abrams_sand_minigunonly" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp
xmodel,vehicle_m1a1_abrams_mp

defaultmdl="vehicle_m1a1_abrams_mp"
default:"vehicletype" "m1a1_sand"
default:"script_team" "allies"
*/

/*QUAKED script_vehicle_m1a1_abrams_sand_noturrets (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams_mp", "m1a1_sand", "script_vehicle_m1a1_abrams_sand_noturrets" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp
xmodel,vehicle_m1a1_abrams

defaultmdl="vehicle_m1a1_abrams"
default:"vehicletype" "m1a1_sand"
default:"script_team" "allies"
*/
	
/*QUAKED script_vehicle_m1a1_abrams_player_drivable_relative_physics_turret (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_m1a1_player_drivable::main( "vehicle_m1a1_abrams_viewmodel", "m1a1_player_drivable_relative_physics", "script_vehicle_m1a1_abrams_player_drivable_relative_physics_turret" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a1_abrams_m1a1_player_drivable
sound, vehicle_abrams		   , vehicle_standard, all_sp
sound, vehicle_abrams_commander, vehicle_standard, all_sp
sound, weapon_minigun		   , vehicle_standard, all_sp

defaultmdl="vehicle_m1a1_abrams_viewmodel"
default:"vehicletype" "m1a1_player_drivable_relative_physics"
default:"script_team" "allies"
*/