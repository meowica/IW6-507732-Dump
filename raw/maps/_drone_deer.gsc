#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "animals" );

init()
{
	// drone type specific stuff
	//level.drone_anims[ "neutral" ][ "stand" ][ "idle" ][0]  = %deer_idle;
	level.drone_anims[ "team3" ][ "stand" ][ "idle" ]	= %deer_idle_twitch;
	level.drone_anims[ "team3" ][ "stand" ][ "run" ]		 = %deer_run;
	level.drone_anims[ "team3" ][ "stand" ][ "walk" ]		 = %deer_walk; //TODO implement walk in _drone.gsc	 =)
	//level.drone_anims[ "neutral" ][ "stand" ][ "death" ]	 = %exposed_death;
	
	// init the generic drone script
	maps\_drone::initGlobals();
}


deer_dronespawn( spawner )
{
	//USE THIS FUNC TO SPAWN DEER DRONES!
	
	if ( !isdefined( spawner ) )
		spawner = self;
	
	spawner script_delay();
	
	drone = deer_dronespawn_internal( spawner );
	Assert( IsDefined( drone ) );

	AssertEx( IsDefined( level.drone_spawn_func ), "You need to put maps\_drone_deer::init(); in your level script! Use the civilian version if your drone is a civilian and the _ai version if it's a friendly or enemy." );
	
	drone maps\_drone_deer::deer_drone_spawn_func();
	
	drone [[ level.drone_spawn_func ]]();

	drone.spawn_funcs = spawner.spawn_functions;
	
	return drone;
}


deer_dronespawn_internal( spawner )
{
	drone = spawner spawnDrone();

	drone.spawner = spawner;
	drone.drone_delete_on_unload = ( isdefined( spawner.script_noteworthy ) && spawner.script_noteworthy == "drone_delete_on_unload" );

	spawner notify( "drone_spawned", drone );
	return drone;
}

deer_drone_spawn_func()
{
	self.drone_idle_custom = 1;
	self.drone_idle_override = ::deer_drone_custom_idle;
	
	self.drone_loop_custom = 1;
	self.drone_loop_override = ::deer_drone_custom_loop;
	
	self.drone_run_speed = randomintrange( 580, 620 ); //600
}

deer_drone_custom_idle()
{
	self ClearAnim( %root, 0.2 );
	self StopAnimScripted();
	
	idle_anim = undefined;
	droneanim = level.drone_anims[ "team3" ][ "stand" ][ "idle" ];
	
	if( isarray( droneanim ) )
	{
		if(  droneanim.size > 1 ) 
		{
			idle_anim = random( droneanim );
		}	
	}
	else
	{
		idle_anim = droneanim;		
	}
		
	self SetFlaggedAnimKnobAllRestart( "drone_anim", idle_anim, %root, 1, 0.2, 1 );
	self.droneAnim = droneAnim;
	
}

deer_drone_custom_loop( droneanim, rate )
{
	wait( randomfloatrange( .10, .35 ) ); //to prevent syncing of groups
	self ClearAnim( %deer, 0.2 );
	self StopAnimScripted();

	self SetAnimknob( droneanim, 1, 0.2, rate );
	//self SetFlaggedAnimKnobAllRestart( "drone_anim", droneanim, %deer, 1, 0.2, 1 );
	self.droneAnim = droneAnim;
	
}