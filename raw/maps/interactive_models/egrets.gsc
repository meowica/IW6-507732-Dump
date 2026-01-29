// Interactive_models\Pigeons.gsc

// At Nate's suggestion I'm trying not to entangle this with other systems.  There are some things I can't avoid though.
// I introduced a level array called "_interactive" that I'll use for all this stuff that isn't a traditional destructible.
// However, my intention is that any given type of interactive object can have its own struct in this array.

// Egrets are interactive_birds.  They have a rig that all the birds attach to and different bird models for flying vs sitting.
// TODO I plan to have multiple birds attached to each tag on the rig.  This means that the rig has to stay on the perch for some  
// extra frames after the last "takeoff" notetrack so that all the birds in the sub-model can take off.
#include common_scripts\utility;
#include maps\interactive_models\_birds;
	
#using_animtree( "animals" );
main()
{
	if( !isdefined ( level._interactive ) )
		level._interactive = [];
			
	info = SpawnStruct();
	info.interactive_type	= "egrets";
	info.rig_model 			= "pigeon_flock_rig";
	info.rig_animtree		= #animtree;
	info.rig_numtags		= 12;
	info.bird_health		= 500;
	info.bird_model["idle"] = "bird_egret_flock";
	info.bird_model["fly"]	= "bird_egret_flock_fly";
	info.bird_animtree		= #animtree;
	bird_takeoffDelay		= 15/30;		// Seconds (frames/framerate) to wait after last "takeoff" notetrack for birds in sub-model to get airborne.
	bird_landDelay			= 15/30;		// Seconds 
	info.topSpeed			= 400;			// Inches per second.
	info.accn				= 100;			// Use this for both acceleration and deceleration.
	info.scareRadius		= 600;			// Distance at which birds will leave perch to avoid player or AI.
	info.death_effect		= LoadFX( "fx/props/chicken_exp_white" );
	info.birdmodel_anims	= [];
	info.rigmodel_anims		= [];
	if ( isSP() )
	{
		info.birdmodel_anims[ "idle" ]		 		= %egret_flock_idle1;
//		info.birdmodel_anims[ "idleweight" ][ 0 ]	= 1;
		info.birdmodel_anims[ "takeoff" ]			= %egret_flock_takeoff;
//		info.birdmodel_anims[ "land" ]				= %egret_flock_land;
		info.birdmodel_anims[ "flying" ]			= %egret_flock_fly;
		info.rigmodel_anims[ "flying" ]				= %bird_flock_large_fly_loop;
		info.rigmodel_anims[ "takeoff_tree" ]		= %bird_flock_large_takeoff_tree;	// These match the Radiant keypairs "interactive_takeoffAnim" and "interactive_landAnim"
		info.rigmodel_anims[ "land_tree" ]			= %bird_flock_large_land_tree;
		info.rigmodel_anims[ "takeoff_ground" ]		= %bird_flock_large_takeoff_ground;
		info.rigmodel_anims[ "land_ground" ]		= %bird_flock_large_land_ground;
	}
	else
	{
		// None of this MP part has been tested yet...I'm just keeping it populated to make it easier to test when I get to it.
		info.birdmodel_anims[ "idle" ]		 		= "egret_flock_idle1";
		info.birdmodel_anims[ "takeoff" ]			= "egret_flock_takeoff";
//		info.birdmodel_anims[ "land" ]				= "egret_flock_land";
		info.birdmodel_anims[ "flying" ]			= "egret_flock_fly";
		info.rigmodel_anims[ "flying" ]				= "bird_flock_large_fly_loop";
		info.rigmodel_anims[ "takeoff_tree" ]		= "bird_flock_large_takeoff_tree";
		info.rigmodel_anims[ "land_tree" ]			= "bird_flock_large_land_tree";
		info.rigmodel_anims[ "takeoff_ground" ]		= "bird_flock_large_takeoff_ground";
		info.rigmodel_anims[ "land_ground" ]		= "bird_flock_large_land_ground";
	}
	
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
			info.rigmodel_pauseStart[ index ]	= get_last_takeoff( info, index, info.rig_numtags ) + bird_takeoffDelay;
		else if ( string_starts_with( index, "land_" ) )
			info.rigmodel_pauseEnd[ index ]		= get_first_land( info, index, info.rig_numtags );
	}
	
	level._interactive[ info.interactive_type ] = info;
	
	thread maps\interactive_models\_birds::birds();
}