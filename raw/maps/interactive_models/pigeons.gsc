// Interactive_models\Pigeons.gsc

// At Nate's suggestion I'm trying not to entangle this with other systems.  There are some things I can't avoid though.
// I introduced a level array called "_interactive" that I'll use for all this stuff that isn't a traditional destructible.
// However, my intention is that any given type of interactive object can have its own struct in this array.
// Pigeons are interactive_birds.  They have a rig that all the birds attach to and different bird models for flying vs sitting.
#include common_scripts\utility;
#include maps\interactive_models\_birds;
	
#using_animtree( "animals" );
main()
{
	if( !isdefined ( level._interactive ) )
		level._interactive = [];
			
	info = SpawnStruct();
	info.interactive_type	= "pigeons";
	info.rig_model 			= "pigeon_flock_rig";
	info.rig_animtree		= #animtree;
	info.rig_numtags		= 12;
	info.bird_model["idle"] = "pigeon_iw5";
	info.bird_model["fly"]	= "pigeon_fly_iw5";
	info.bird_animtree		= #animtree;
	info.topSpeed			= 400;			// Inches per second.
	info.accn				= 100;			// Use this for both acceleration and deceleration.
	info.scareRadius		= 300;			// Distance at which pigeons will leave perch to avoid player or AI.
	info.death_effect		= LoadFX( "fx/props/chicken_exp_white" );
	info.birdmodel_anims	= [];
	info.rigmodel_anims		= [];
	if ( isSP() )
	{
		info.birdmodel_anims[ "idle" ][ 0 ] 		= %pigeon_idle;
		info.birdmodel_anims[ "idleweight" ][ 0 ]	= 1;
		info.birdmodel_anims[ "idle" ][ 1 ] 		= %pigeon_idle_twitch_1;
		info.birdmodel_anims[ "idleweight" ][ 1 ]	= 0.3;
		info.birdmodel_anims[ "flying" ] 			= %pigeon_flying_cycle;
		info.rigmodel_anims[ "flying" ]				= %pigeon_flock_fly_loop;
		info.rigmodel_anims[ "takeoff_wire" ]		= %pigeon_flock_takeoff_wire;	// These match the Radiant keypairs "interactive_takeoffAnim" and "interactive_landAnim"
		info.rigmodel_anims[ "land_wire" ]			= %pigeon_flock_land_wire;
		info.rigmodel_anims[ "takeoff_ground" ]		= %pigeon_flock_takeoff_ground;
		info.rigmodel_anims[ "land_ground" ]		= %pigeon_flock_land_ground;
	}
	else
	{
		// None of this MP part has been tested yet...I'm just keeping it populated to make it easier to test when I get to it.
		info.birdmodel_anims[ "idle" ][ 0 ] 		= "pigeon_idle";
		info.birdmodel_anims[ "idleweight" ][ 0 ]	= 1;
		info.birdmodel_anims[ "idle" ][ 1 ] 		= "pigeon_idle_twitch_1";
		info.birdmodel_anims[ "idleweight" ][ 1 ]	= 0.3;
		info.birdmodel_anims[ "flying" ] 			= "pigeon_flying_cycle";
		info.rigmodel_anims[ "flying" ]				= "pigeon_flock_fly_loop";
		info.rigmodel_anims[ "takeoff_wire" ]		= "pigeon_flock_takeoff_wire";
		info.rigmodel_anims[ "land_wire" ]			= "pigeon_flock_land_wire";
		info.rigmodel_anims[ "takeoff_ground" ]		= "pigeon_flock_takeoff_ground";
		info.rigmodel_anims[ "land_ground" ]		= "pigeon_flock_land_ground";
	}
	info.sounds				= [];
	info.sounds[ "takeoff" ]						= "anml_bird_startle_flyaway";
	
	// Stuff from here down probably won't need to be changed for different kinds of birds.
	
	// Precache.
	PreCacheModel( info.bird_model[ "fly" ] );
	PreCacheModel( info.bird_model[ "idle" ] );
	// Define functions for removing entities when they're not needed.
	info.saveToStructFn = maps\interactive_models\_birds::birds_saveToStruct;
	info.loadFromStructFn = maps\interactive_models\_birds::birds_loadFromStruct;
	// Determine how far into the takeoff and land animations the flock can move away from its perch.
	info.rigmodel_pauseStart = [];
	info.rigmodel_pauseEnd = [];
	indices = GetArrayKeys( info.rigmodel_anims );
	foreach ( index in indices )
	{
		if ( string_starts_with( index, "takeoff_" ) )
			info.rigmodel_pauseStart[ index ]	= get_last_takeoff( info, index, info.rig_numtags );
		else if ( string_starts_with( index, "land_" ) )
			info.rigmodel_pauseEnd[ index ]		= get_first_land( info, index, info.rig_numtags );
	}
	
	level._interactive[ info.interactive_type ] = info;
	
	thread maps\interactive_models\_birds::birds();
}