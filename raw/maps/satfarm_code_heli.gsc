#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

/***
 * 		Helicopter script
 ***/
 // Health overrides for enemy vehicles applied to spawner before spawn.
// NOTE: If a spawner has script_startinghealth set on it already
// that value takes priority and these values are not used.
CONST_ENEMY_HIND_HEALTH						= 19999;

CONST_VEH_TURRET_RANGE_SQUARED				= 12000 * 12000;

CONST_ENEMY_HIND_DAMAGE_STATES				= 1;			// Number of damage states for the chopper including the starting healthy state
CONST_ENEMY_HIND_DAMAGE_ROCKET_ADJUST_DELAY = 1.0;			// Number of seconds to delay after missile damage before allowing another missile's damage to be scaled. Prevents two quick rockets from blowing up hind.
CONST_HELI_VS_HELI_MG_RANGE_2D_SQUARED		= 600 * 600;	// Inside this Distance 2D Squared AI helis will use their MG
CONST_HELI_VS_HELI_MIN_SHOOT_TIME_MSEC		= 1500;			// Helicopters shoot at each other (and the player) at the least every this many milliseconds
CONST_HELI_VS_HELI_MAX_SHOOT_TIME_MSEC		= 3000;			// Helicopters shoot at each other (and the player) at the most every this many milliseconds
CONST_VEHICLE_VS_PLAYER_LOCK_ON_TIME		= 1.5;			// Helicopters from

CONST_HELI_MIN_TARGET_DIST_2D				= 2048;
CONST_HELI_MAX_TARGET_DIST_2D				= 8192;

// Call chopper_ai_init() before spawning a helicopter using the mesh system. 
// Currently setup for one mesh.
chopper_ai_init()
{
	// Chopper mesh setup. Can make another call for different mesh sections?
	maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "heli_nav_mesh" );
	
	// Chopper stats and funcs
	maps\_chopperboss::init();
	
	level.missile_lockon_notify_delay = 30;
	level.next_missile_lockon_notify = 0;
}

// Call to spawn helicopters to mesh.
spawn_hind_enemies( count, start )
{
	spawned	   = 0;
	// change mesh start targetname for new meshes?
	if( !IsDefined( start ) )
		start = "heli_nav_mesh_start";
	
	locs_start = getstructarray( start, "targetname" );
	
	helis = [];
	
	while ( spawned < count )
	{
		loc_spawn = undefined;
		
		foreach ( loc in locs_start )
		{
			if ( !IsDefined( loc.in_use ) && !IsDefined( loc.disabled ) )
			{
				loc_spawn = loc;
				break;
			}
		}
		
		if ( IsDefined( loc_spawn ) )
		{
			hind = spawn_hind_enemy( loc_spawn );
			hind self_make_chopper_boss( loc_spawn, true );
			hind thread npc_tank_combat_init();
			helis = add_to_array( helis, hind );
			
			locs_start = array_remove( locs_start, loc_spawn );
			locs_start[ locs_start.size ] = loc_spawn;
			spawned++;
		}
		
		wait 0.05;
	}
	
	targets = getentarray( "lockon_targets", "script_noteworthy" );
	//array_thread( targets, maps\_helifly_missile::enable_lockon ); //majernik commented out 5/2/2013 due to sre in this function, we don't have lockon anymore in the tank mission anyway all the lockon stuff should be removed
	
	return helis;
}

// Spawns individual helicopters.
// IW - Uses chopper boss movement and shooting along with Chetan's
// missile defense logic
spawn_hind_enemy( ent_start )
{
	spawner = GetEnt( "hind_enemy", "targetname" );
	//spawner vehicle_spawner_adjust_health_and_damage(); // Current damage works with tank combat

	while ( IsDefined( spawner.vehicle_spawned_thisframe ) )
		wait 0.05;
	
	if ( IsDefined( ent_start ) )
	{
		spawner.origin = ent_start.origin;
		if ( IsDefined( ent_start.angles ) )
			spawner.angles = ent_start.angles;
	}
	
	hind = vehicle_spawn( spawner );
	
	hind.script_noteworthy = "lockon_targets";
	hind.enableRocketDeath = true;
	
	hind Vehicle_SetSpeed( 85, 35, 35 );
	
	//hind thread add_as_apache_target_on_spawn(); 	// manage_target_loc should already do this.
	hind thread hind_manage_damage_states(); 		// In the case one shot doesn't destory heli
	
	hind heli_ai_collision_cylinder_add();
	
	return hind;
}

self_make_chopper_boss( path_start, fly_to_path )
{
	self endon( "death" );
	
	if ( !IsDefined( path_start ) )
	{
		while ( 1 )
		{
			path_start = maps\_chopperboss_utility::chopper_boss_get_closest_available_path_struct_2d( self.origin );
			
			if ( IsDefined( path_start ) )
				break;
			
			wait 0.05;
		}
	}
	
	fly_to_path = ter_op( IsDefined( fly_to_path ), fly_to_path, false );
	
	if ( fly_to_path )
	{
		path_start.in_use = true;
		
		self thread vehicle_paths( path_start );
		self waittill( "reached_dynamic_path_end" );
				
		path_start.in_use = undefined;
	}
	
	// Make sure overrides are set for the hind
	if ( !IsDefined( level.chopperboss_const[ self.classname ] ) )
	{
		// Tweak numbers to move tanks closer/futher away.
		self maps\_chopperboss_utility::build_data_override( "min_target_dist2d", CONST_HELI_MIN_TARGET_DIST_2D );
		self maps\_chopperboss_utility::build_data_override( "max_target_dist2d", CONST_HELI_MAX_TARGET_DIST_2D );
		
		self maps\_chopperboss_utility::build_data_override( "get_targets_func", ::heli_ai_gather_targets );
		self maps\_chopperboss_utility::build_data_override( "tracecheck_func" , ::heli_ai_can_hit_target );
		self maps\_chopperboss_utility::build_data_override( "fire_func"	   , ::heli_ai_shoot_target );
		self maps\_chopperboss_utility::build_data_override( "next_loc_func"   , ::heli_ai_next_loc_func );
		self maps\_chopperboss_utility::build_data_override( "pre_move_func"   , ::heli_ai_pre_move_func );
		self maps\_chopperboss_utility::build_data_override( "stop_func"	   , ::heli_ai_stop_func );
	}
	
	self thread maps\_chopperboss::chopper_boss_think( path_start, false );
	self thread _heli_ai_pre_move_func_internal();
}

heli_ai_gather_targets()
{
	targets = [];
	
	// If a forced target is set for a hind this logic does not get called in _chopperboss.gsc
	targets = array_removeUndefined( level.allytanks );
	targets = add_to_array( targets, level.playertank );
	
	return targets;
}

heli_ai_can_hit_target( chopper_origin, target_origin )
{
	return true;
}

// What changes to make for tank combat? Are homing missiles approriate?
heli_ai_shoot_target( target )
{
	// Don't use missiles if the target is an AI or if missiles were used recently
	use_missile = true;
	if ( IsAI( target ) )
	{
		use_missile = false;
	}
	else if ( IsDefined( self.heli_ai_shoot_missile_time_next ) && GetTime() < self.heli_ai_shoot_missile_time_next )
	{
		use_missile = false;
	}
	else if ( distance_2d_squared( self.origin, target.origin ) <= CONST_HELI_VS_HELI_MG_RANGE_2D_SQUARED )
	{
		use_missile = false;
	}
	
	num_shots = 1;
	
	if ( !self.is_moving )
		num_shots = RandomIntRange( 1, 4 );
	
	self heli_fire_missiles( target, num_shots );
	
	return true;
}

heli_fire_missiles( eTarget, iShots, delay, customMissiles )
{
	self endon( "death" );
	self endon( "heli_players_dead" );
	
	if ( IsDefined( self.defaultWeapon ) )
		defaultWeapon = self.defaultWeapon;
	else
		defaultWeapon = "minigun_littlebird_quickspin";
	weaponName = "missile_attackheli";
	if ( isdefined( customMissiles ) )
		weaponName = customMissiles;
	
	loseTargetDelay  = undefined;
	tags = [];
	self SetVehWeapon( defaultWeapon );
	if ( !isdefined( iShots ) )
		iShots = 1;
	if ( !isdefined( delay ) )
		delay = 1;
	
	//if the target is a struct, need to spawn a dummy ent to fire at
	if ( !isdefined( eTarget.classname ) )
	{
		if ( !isdefined( self.dummyTarget) )
		{
			self.dummyTarget = Spawn( "script_origin", eTarget.origin );
			self thread delete_on_death( self.dummyTarget );
		}
		self.dummyTarget.origin = eTarget.origin;
		eTarget = self.dummyTarget;
	}

	tags[ 0 ] = "tag_missile_left";
	tags[ 1 ] = "tag_missile_right";

	nextMissileTag = -1;

	for ( i = 0 ; i < iShots ; i++ )
	{
		nextMissileTag++;
		if ( nextMissileTag >= tags.size )
			nextMissileTag = 0;

		self SetVehWeapon( weaponName );
		self.firingMissiles = true;
		
		// if the player is moving shoot at where they were
		eTarget2 = eTarget;
		if ( eTarget == level.playertank )
			eTarget2 = _get_player_tank_target();
		
		eMissile = self FireWeapon( tags[ nextMissileTag ], eTarget2 );
		eMissile thread _missile_earthquake();
		eMissile thread _missile_start_lockon_notify( eTarget );
		
		if ( IsDefined( eTarget.is_fake ) && eTarget.is_fake )
			eMissile thread _missile_cleanup_fake_target(eTarget);
		
		if ( i < iShots - 1 )
			wait delay;
	}
	self.firingMissiles = false;
	self SetVehWeapon( defaultWeapon );
}

_get_player_tank_target()
{
	tank_speed = level.playertank Vehicle_GetSpeed();
	
	if ( tank_speed == 0 )
		return level.playertank;
	
	tank_velocity = level.playertank Vehicle_GetVelocity();
	dist_away = tank_speed * 2;
	location = level.playertank.origin + ( ( -1 * VectorNormalize( tank_velocity ) ) * dist_away );
	
	fake_target = spawn_tag_origin();
	fake_target.is_fake = true;
	
	fake_target.origin = location;

	return fake_target;
}

_missile_cleanup_fake_target(target)
{
	self waittill( "death" );
	
	target Delete();
}

_missile_start_lockon_notify( target )
{
	if ( target != level.playertank && !IsDefined( target.is_fake ) )
		return;
	
	cur_time = GetTime();
	
	if ( cur_time < level.next_missile_lockon_notify )
		return;
	
	level.next_missile_lockon_notify = GetTime() + ( level.missile_lockon_notify_delay * 1000 );
		
	IPrintLnBold( "HELI MISSILE LOCKED ON" );
	IPrintLnBold( "MOVE!" );
	level.player thread play_loop_sound_on_entity( "missile_incoming" );
	self waittill( "death" );
	level.player thread stop_loop_sound_on_entity( "missile_incoming" );
}

_missile_earthquake()
{
	//does an earthquake when a missile hits and explodes
	if ( DistanceSquared( self.origin, level.player.origin ) > 9000000 )
		return;
	org = self.origin;
	while ( IsDefined( self ) )
	{
		org = self.origin;
		wait( 0.1 );
	}
	Earthquake( 0.7, 1.5, org, 1600 );
}

//heli_fire_turret( target, lookatEnt )
//{
//	self endon( "death" );
//	self notify( "switching_targets" );
//	self endon( "switching_targets" );
//	self endon( "stop_firing" );
//	
//	if( IsDefined( target.classname ) )
//	{
//		self SetTurretTargetEnt( target );
//		
//		if( isdefined( lookatEnt ) )
//			self SetLookAtEnt( target );
//	}
//	else
//		self SetTurretTargetVec( target.origin );
//	
//	burstMin = 30;
//	burstMax = 50;
//	if( isdefined( self.script_burst_min ) && isdefined( self.script_burst_max ) )
//	{
//		burstMin = self.script_burst_min;
//		burstMax = self.script_burst_max;
//	}
//	
//	fireWait = .05;
//	if( isdefined( self.fireWait ) )
//		fireWait = self.fireWait;
//	
//	while( 1 )
//	{
//		self thread heli_fire_turret_sound();
//		
//		burst = randomintrange( burstMin, burstMax );
//		
//		for( i=0; i<burst; i++ )
//		{
//			if( isdefined( self.firingMissiles ) && self.firingMissiles == true )
//				continue;
//		
//			self fireweapon();
//			wait( fireWait );
//		}
//		
//		self notify( "stop_minigun_sound" );
//		
//		wait( randomfloatrange( .4, .9 ) );
//	}
//}
//
//heli_fire_turret_sound()
//{	
//	sEnt = spawn( "script_origin", self.origin );
//	sEnt linkto( self );
//	
//	//sEnt thread play_sound_on_entity( "minigun_heli_gatling_spinup" + randomintrange( 1,4 ) );
//	//sEnt delaythread( 1, ::play_loop_sound_on_entity, "minigun_heli_gatling_fire" );
//	SEnt thread play_loop_sound_on_entity( "minigun_heli_gatling_fire" );
//	self waittill_any( "death", "switching_targets", "stop_firing", "stop_minigun_sound" );
//	sEnt stop_loop_sound_on_entity( "minigun_heli_gatling_fire" );
//	sEnt delete();
//}

heli_ai_next_loc_func( optional_locs, targets, tracecheck_func )
{
	tracecheck_func = self maps\_chopperboss_utility::get_chopperboss_data( "tracecheck_func" );
	
	// Let other choppers know that this chopper is targeting
	// and clear the flag when the chopper dies or when
	// targetting is done
	self thread maps\_chopperboss::chopper_boss_manage_targeting_flag();
	
	valid_locs = [];
	traces = 0;
	// Check each location against each target to see if it's a 
	// valid location.
	foreach( loc in optional_locs )
	{
		// Early out if loc in use unless it's the current location
		if ( loc != self.loc_current && isdefined( loc.in_use ) )
			continue;
			
		if ( IsDefined( self.loc_last ) && loc == self.loc_last )
			continue;
		
		// Don't evaluate locations which are disabled
		if ( IsDefined( loc.disabled ) )
			continue;
		
		// Scrub the location
		loc.heli_target = undefined;
		loc.dist2D = undefined;
		
		dist_target = undefined;
		
		// Only allow 4 traces per frame. This wait is okay
		// because two helicopters are not allowed to think
		// about shooting at the same time. By not allowing
		// helicopters to think simultaneously, this logic
		// won't stomp other helicopter data on struct 
		// locations when searching for targets
		lock( "chopperboss_trace" );
		
		foreach( target in targets )
		{
			unlock_wait( "chopperboss_trace" );
			lock( "chopperboss_trace" );

			// Because there is a wait at the end of this loop
			// to limit the number of traces per frame make
			// sure the target is valid before evaluating
			if ( !IsDefined( target ) )
				continue;
			
			// Early out if the loc and target are not in range of
			// each other to reduce the number of traces
			if ( self maps\_chopperboss::chopper_boss_in_range( target.origin, loc.origin ) == false )
				continue;
			
			trace_loc = target.origin + ( 0, 0, 64 );
			if ( isAI( target ) || isPlayer( target ) )
				trace_loc = target geteye();
				
			if ( self [[ tracecheck_func ]]( loc.origin, trace_loc ) )
			{
				// if the current loc has no target use this one and grab
				// the distance
				if ( !IsDefined( loc.heli_target ) )
				{
					valid_locs[ valid_locs.size ] = loc;
					loc.heli_target				  = target;
					dist_target					  = Distance2D( loc.origin, target.origin );
				}
				else
				{
					// Because of the above in range check it can be assumed
					// that both the current target and the previously set
					// loc target are both in range so pick the closer one
					dist_test = Distance2D( loc.origin, target.origin );
					if ( dist_test < dist_target )
					{
						loc.heli_target = target;
						dist_target		= dist_test;
					}
				}
			}
			
			
		}
		unlock_wait( "chopperboss_trace" );
	}
	
	// Go through the found valid locs and make sure none of their targets died
	// during the trace wait delay in the above loop. Also make sure the locs weren't
	// scooped up by other choppers or disabled during the trace waits.
		// Note: A loc could only be scooped up by another chopper if 
		// fast_move_out_of_range was true in the call to chopper_boss_think()
		// This allows choppers to move while out of range even if other choppers
		// are busy targetting
	if ( valid_locs.size )
	{
		valid_locs_cleaned = [];
		
		foreach ( loc in valid_locs )
		{
			if ( IsDefined( loc.heli_target ) && !IsDefined( loc.in_use ) && !IsDefined( loc.disabled ) )
				valid_locs_cleaned[ valid_locs_cleaned.size ] = loc;
		}
		
		valid_locs = valid_locs_cleaned;
	}
	
	
	// If no locs were found with valid targets go through all 
	// possible locs and set their dist2D to the closest target 
	// but do not set the target for the loc.
	if ( !valid_locs.size )
	{
		// Grab the original list of optional locs
		foreach ( loc in optional_locs )
		{
			// Early out if in use unless it's the current location
			if ( loc != self.loc_current && IsDefined( loc.in_use ) )
				continue;
			
			// Don't evaulate locations which are disabled
			if ( IsDefined( loc.disabled ) )
				continue;
			
			closest_target = undefined;
			foreach( target in targets )
			{
				// Because there is a wait in the above gather targets
				// loop make sure each target in the targets array is valid
				if ( !IsDefined( target ) )
					continue;
				
				if ( !IsDefined( closest_target ) )
				{
					closest_target = target;
					loc.dist2D	   = Distance2D( loc.origin, target.origin );
				}
				else
				{
					dist = Distance2D( loc.origin, target.origin );
					if ( dist < loc.dist2D )
					{
						closest_target = target;
						loc.dist2D	   = dist;
					}
				}
			}
			
			if ( IsDefined( loc.dist2D ) )
				valid_locs[ valid_locs.size ] = loc;
		}	
	}
	else
	{
		// Populate the valid locations with a 2D distance from their target
		foreach ( loc in valid_locs )
			loc.dist2D = Distance2D( loc.heli_target.origin, loc.origin );
	}

	// Sort the locations from the target location
	sorted_locs = array_sort_by_handler( valid_locs, maps\_chopperboss::chopper_boss_loc_compare );
	
	next_loc = undefined;
	
	// Find the closest location outside of the min distance and inside
	// the max
	foreach( loc in sorted_locs )
	{
		min_dist2D = self maps\_chopperboss_utility::get_chopperboss_data( "min_target_dist2d" );
		max_dist2D = self maps\_chopperboss_utility::get_chopperboss_data( "max_target_dist2d" );
		
		if ( loc.dist2D >= min_dist2D && loc.dist2D <= max_dist2D )
		{
			next_loc = loc;
			break;
		}
	}
	
	// If no location was found outside of the min distance and inside
	// the max go to the closest location. This prevents choppers from
	// getting stuck outside the max forever until the player comes
	// in range
	if ( !isdefined( next_loc ) && sorted_locs.size )
	{
		next_loc = sorted_locs[ 0 ];	
	}
	
	// Assign the helicopter a new target if a loc was found
	if ( IsDefined( next_loc ) && IsDefined( next_loc.heli_target ) )
	{
		self maps\_chopperboss::chopper_boss_set_target( next_loc.heli_target );
	}
	
	self notify( "chopper_done_targeting" );
	
	// Return the next location as long as it's not the current
	if ( isdefined( next_loc ) && next_loc != self.loc_current )
		return next_loc;
	else
		return undefined;
}

heli_ai_pre_move_func()
{
	//self thread _heli_ai_pre_move_func_internal();
}

_heli_ai_pre_move_func_internal()
{
	self endon( "deathspin" );
	self endon( "death" );
	
	self.is_moving = true;
	
	while ( self.is_moving )
	{
		self heli_set_look_at_ent();
		
		self heli_attempt_fire();
		
		fire_delay = RandomFloatRange( 1, 4 );
		
		wait fire_delay;
	}
}

heli_set_look_at_ent()
{
	if ( IsDefined( self maps\_chopperboss_utility::chopper_boss_forced_target_get() ) )
	{
		self SetLookAtEnt( self maps\_chopperboss_utility::chopper_boss_forced_target_get() );
	}
	else if ( IsDefined( self.heli_target ) )
	{
		self SetLookAtEnt( self.heli_target );
	}
	else
	{
		self ClearLookAtEnt();
	}
}

heli_ai_stop_func()
{
/*
	self.is_moving = false;
	if ( !IsDefined( self.loc_last ) || self.loc_last != self.loc_current )
		self.loc_last = self.loc_current;
	
	while ( IsDefined( self.firingMissiles ) && self.firingMissiles )
		waitframe();
	
	self heli_attempt_fire();
	*/
}

heli_attempt_fire()
{
	if ( IsDefined( self.heli_target ) )
		self.fired_weapons = self maps\_chopperboss::chopper_boss_attempt_firing( self.heli_target );
	else
		self.fired_weapons = false;
}

hind_manage_damage_states()
{
	self endon( "death" );
	self endon( "deathspin" );

	health_original = self.health - self.healthbuffer;
	state			= 0;
	
	while ( 1 )
	{
		health = self.health - self.healthbuffer;
		
		if ( health <= health_original * 0.5 )
		{
			PlayFXOnTag( getfx( "tank_heavy_smoke" ), self, "tag_deathfx" );
			self DoDamage( health * 2, self.origin );
		}
		
		wait 0.05;
	}
}

// Heli Utils

heli_ai_collision_cylinder_setup()
{
	level.heli_collision_ai = GetEntArray( "heli_collision_ai_mesh", "targetname" );
	
	foreach ( ent in level.heli_collision_ai )
	{
		ent.start_origin = ent.origin;
		ent.start_angles = ent.angles;
		ent.in_use		 = false;
	}
}

heli_ai_collision_cylinder_add()
{
	AssertEx( IsDefined( level.heli_collision_ai ) && level.heli_collision_ai.size, "heli_ai_collision_cylinder_add() called without initiallizing the cylinder collision logic." );
	
	cylinder = undefined;
	
	foreach ( ent in level.heli_collision_ai )
	{
		if ( !ent.in_use )
		{
			cylinder = ent;
		}
	}
	
	AssertEx( IsDefined( cylinder ), "heli_ai_collision_cylinder_add() failed to grab a valid heli ai collision brush model." );
	
	if ( IsDefined( cylinder ) )
	{
		cylinder.in_use = true;
		cylinder.origin = self.origin;
		cylinder.angles = self.angles;
		cylinder LinkTo( self, "tag_origin" );
		self thread heli_ai_collision_cylinder_on_death_remove( cylinder );
	}
}

heli_ai_collision_cylinder_on_death_remove( cylinder )
{
	self waittill( "death" );
	
	cylinder Unlink();
	cylinder.origin = cylinder.start_origin;
	cylinder.angles = cylinder.start_angles;
	cylinder.in_use = false;
}