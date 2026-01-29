#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\_vehicle;

// tagTC<note> - Current functions to support the NX Vignette Pipeline

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// tagTC<note> - Register function currently checks for valid flag and waits, 
// then plays the vignette. It'll also be a central hook point if we plan
// to extend the vignette logic (e.g. adding debug points to test scenes)
vignette_register( vignette_func, vignette_flag )
{
	// Init flag if it doesn't exist
	if( !flag_exist( vignette_flag ))
		flag_init( vignette_flag );
	
	// Thread the wait for the flag
	thread vignette_register_wait( vignette_func, vignette_flag );			
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_register_wait( vignette_func, vignette_flag )
{
	// Wait for vignette
	flag_wait( vignette_flag );

	// Play the vignette
	level thread [[vignette_func]]();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_drone_spawn( spawner_name, anim_name )
{
    // Force spawn vignette actor
    spawner = GetEnt( spawner_name, "targetname" );
    Assert( IsDefined( spawner ));
	spawner.script_forcespawn = 1;

    vignette_drone = maps\_spawner::spawner_dronespawn( spawner );
    vignette_drone.animname = anim_name;

    return vignette_drone;
}

vignette_actor_spawn( spawner_name, anim_name )
{
    // Force spawn vignette actor
    spawner = GetEnt( spawner_name, "targetname" );
    Assert( IsDefined( spawner ));
	spawner.script_forcespawn = 1;
    spawner thread add_spawn_function( ::vignette_actor_spawn_func );

    vignette_actor = spawner spawn_ai();
    vignette_actor.animname = anim_name;

    return vignette_actor;
}

vignette_actor_spawn_func()
{
    self endon ( "death" );

    // Ignore vignette actors, thread magic bullet shield
    self thread magic_bullet_shield();
	self thread vignette_actor_ignore_everything();
}

vignette_actor_delete()
{
	if( IsDefined( self.magic_bullet_shield ) )
	{
		self stop_magic_bullet_shield();
	}
    self delete();    
}

vignette_actor_kill()
{
    if ( !isalive( self ) )
        return;

	if( IsDefined( self.magic_bullet_shield ) )
	{	
		self stop_magic_bullet_shield();
	}

    self.allowDeath = true;
    self.a.nodeath = true;
    self set_battlechatter( false );

    self kill(); 
}

vignette_actor_ignore_everything()
{
	self.ignoreall = true;
	self.ignoreme = true;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.fixednode = false;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	self.dontavoidplayer = true;
	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vignette_vehicle_spawn( vehicle_name, anim_name )
{
	vehicle = spawn_vehicle_from_targetname( vehicle_name );
	vehicle.animname = anim_name;

	return vehicle;
}

vignette_vehicle_delete()
{
	self delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************