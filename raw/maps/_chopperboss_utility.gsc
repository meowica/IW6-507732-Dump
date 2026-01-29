#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;

/*
=============
///ScriptDocBegin
"Name: build_data_override( <key> , <data> )"
"Summary: called on vehicle - use it to override global defaults"
"Module: Entity"
"CallOn: A helicopter"
"MandatoryArg: <key>: Data type to change for this vehicle"
"MandatoryArg: <data>: Value to be stored for the passed data type"
"Example: build_data_override( "get_targets_func", ::get_targets_for_littlebird );"
"Valid keys: shot_count, shot_count_long, windup_time, min_target_dist2d, max_target_dist2d, get_targets_func"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

build_data_override( key, data )
{
	assertex( isdefined( level.chopperboss_const[ "default" ][ key ] ) , "Key " + key + " is not defined in level.chopperboss_const[ \"default\" ] " );
	
	level.chopperboss_const[ self.classname ][ key ] = data;
}

get_chopperboss_data( str_const )
{
	classname = self.classname;
	if ( !isdefined( level.chopperboss_const[ classname ] ) || !isdefined( level.chopperboss_const[ classname ][ str_const ] ) )
		classname = "default";
	
	return level.chopperboss_const[ classname ][ str_const ];
}

build_chopperboss_defaults()
{
	if ( isdefined( level.chopperboss_const ) )
		return;
		
	level.chopperboss_const = [];
	level.chopperboss_const[ "default" ] = [];
	level.chopperboss_const[ "default" ][ "shot_count" ]			= 20; // Alternating shot count 
	level.chopperboss_const[ "default" ][ "shot_count_long" ]		= 60; // Alternating shot count for when the helicopter wants to coninuously fire
	
	level.chopperboss_const[ "default" ][ "heli_shoot_limit" ]		= 1; // Number of helicopters that can shoot the same target
	
	level.chopperboss_const[ "default" ][ "windup_time" ]			= 2.0;
	level.chopperboss_const[ "default" ][ "weapon_cooldown_time" ]	= 1.0;
	level.chopperboss_const[ "default" ][ "face_target_timeout" ]	= 5.0;
	
	level.chopperboss_const[ "default" ][ "min_target_dist2d" ]		= 384; // Chopper does not want to be closer than this to the target
	level.chopperboss_const[ "default" ][ "max_target_dist2d" ]		= 3072; // Chopper wants to be closer than this to the target
	
	level.chopperboss_const[ "default" ][ "get_targets_func" ]		= ::chopper_boss_gather_targets;
	level.chopperboss_const[ "default" ][ "tracecheck_func" ]		= ::chopper_boss_can_hit_from_mgturret;
	level.chopperboss_const[ "default" ][ "fire_func" ]				= ::chopper_boss_fire_mgturrets;
	level.chopperboss_const[ "default" ][ "pre_move_func" ]			= ::chopper_boss_pre_move_func;
	level.chopperboss_const[ "default" ][ "post_move_func" ]		= ::chopper_boss_post_move_func;
	level.chopperboss_const[ "default" ][ "next_loc_func" ]			= maps\_chopperboss::chopper_boss_get_best_location_and_target_proc;
	// Note: This function handles calling of the "fire_func", the target range check and the max target count. Recommend you be very careful if you override this. A good choice is to call chopper_boss_stop_func in your override if possible. -JC
	level.chopperboss_const[ "default" ][ "stop_func" ]				= ::chopper_boss_stop_func;

}


/*
=============
///ScriptDocBegin
"Name: chopper_boss_locs_monitor_disable( <range2d> )"
"Summary: Continuously disables chopper boss structs within a range of the called on entity. Be careful to not pass a range2d that is too big as this can paralyze chopper logic if all of a chopper's neighboring locs are disabled."
"Module: Entity"
"CallOn: An entity, actor, helicopter, etc."
"MandatoryArg: <range2d>: The 2 dimensional distance to disable chopper boss structs around the called on entity."
"Example: level.player thread chopper_boss_locs_monitor_disable( 1024 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

chopper_boss_locs_monitor_disable( range2d )
{
	AssertEx( IsDefined( self ) && IsDefined( self.origin ), "chopper_boss_locs_monitor_disable() called without valid self." );
	
	self endon( "death" );
	self notify( "chopper_boss_locs_monitor_disable_turn_off" );
	self endon( "chopper_boss_locs_monitor_disable_turn_off" );
	
	self.chopper_boss_locs_disabled = [];
	range2d_sqrd = squared( range2d );
	
	while ( 1 )
	{
		if ( IsDefined(  level.chopper_boss_locs ) && level.chopper_boss_locs.size )
		{
			// Decrement previously gathered and disabled locs before gathering
			// the new set and disabling them
			self chopper_boss_locs_monitor_disable_reset();
			
			self_origin_2d = (self.origin[0], self.origin[1], 0);
			
			foreach ( loc in level.chopper_boss_locs )
			{
				loc_origin_2d = (loc.origin[0], loc.origin[1], 0);
				if ( DistanceSquared( self_origin_2d, loc_origin_2d ) <= range2d_sqrd )
				{
					loc chopper_boss_loc_disable();
					self.chopper_boss_locs_disabled[ self.chopper_boss_locs_disabled.size ] = loc;
				}
			}
		}
		
		wait 0.05;
	}
}

chopper_boss_locs_monitor_disable_turn_off()
{
	self notify( "chopper_boss_locs_monitor_disable_turn_off" );
	self chopper_boss_locs_monitor_disable_reset();
	self.chopper_boss_locs_disabled = undefined;
}

chopper_boss_locs_monitor_disable_clean_up()
{
	self endon( "chopper_boss_locs_monitor_disable_turn_off" );
	
	self waittill( "death" );
	
	self chopper_boss_locs_monitor_disable_reset();
}

chopper_boss_locs_monitor_disable_reset()
{
	if ( IsDefined( self.chopper_boss_locs_disabled ) && self.chopper_boss_locs_disabled.size )
	{
		foreach ( loc in self.chopper_boss_locs_disabled )
		{
			loc chopper_boss_loc_enable();
		}
	}
	
	self.chopper_boss_locs_disabled = [];
}

chopper_boss_loc_disable()
{
	if ( !IsDefined( self.disabled ) )
		self.disabled = 0;
	
	self.disabled++;
}

chopper_boss_loc_enable()
{
	AssertEx( IsDefined( self.disabled ), "chopper_boss_loc_enable() should not be called on a location that is not disabled." );
	
	if ( IsDefined( self.disabled ) )
	{
		self.disabled--;
		AssertEx( self.disabled >= 0, "chopper boss loc disabled field should never go below 0." );
		if ( self.disabled <= 0 )
			self.disabled = undefined;
	}
}

/*
=============
///ScriptDocBegin
"Name: chopper_boss_forced_target_set( <target> )"
"Summary: Sets an override target for the chopper boss targeting logic. If this is called targeting logic forces engagement of the forced target."
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <target>: Entity reference to be the only considered target."
"Example: heli chopper_boss_forced_target_set( level.player );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

chopper_boss_forced_target_set( target )
{
	AssertEx( IsDefined( target ), "chopper_boss_set_forced_target() passed undefined target" );
	AssertEx( !IsDefined( self.heli_target_forced ), "chopper_boss_set_forced_target() called on chopper that already has a forced target." );
	
	self.heli_target_forced = target;
}

/*
=============
///ScriptDocBegin
"Name: chopper_boss_forced_target_clear()"
"Summary: Clears the forced target from a heli running chopper boss logic."
"Module: Entity"
"CallOn: An entity"
"Example: heli chopper_boss_forced_target_clear();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

chopper_boss_forced_target_clear()
{
	self.heli_target_forced = undefined;
}

/*
=============
///ScriptDocBegin
"Name: chopper_boss_forced_target_get()"
"Summary: Returns a reference to the currently set forced target for a chopper boss. If a forced target doesn't exist undefined is returned."
"Module: Entity"
"CallOn: An entity"
"Example: forced_target = heli chopper_boss_forced_target_get();"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

chopper_boss_forced_target_get()
{
	target = undefined;
	if ( IsDefined( self.heli_target_forced ) )
		target = self.heli_target_forced;
	
	return target;
}

chopper_boss_set_hangout_volume( volume_ent )
{
	
	array = [];
	tester = spawn_tag_origin();
	foreach ( loc in level.chopper_boss_locs )
	{
		tester.origin = loc.origin;
		if( tester IsTouching( volume_ent ) )
			array[array.size] = loc;
	}
	tester Delete();
	
	level.chopper_boss_hangout = array;
	
}

chopper_boss_clear_hangout_volume()
{
	level.chopper_boss_hangout = undefined;
}

chopper_boss_goto_hangout()
{
	chopper_boss_wait_populate();
	loc = chopper_boss_get_closest_available_path_struct_2d( self.origin );
	self maps\_chopperboss::chopper_boss_move(loc);
}

chopper_boss_wait_populate()
{
	while ( !IsDefined( level.chopper_boss_locs_populated ) )
		wait 0.05;
}

chopper_boss_get_closest_available_path_struct_2d( origin )
{	
	dist_close = undefined;
	loc_close  = undefined;
	
	chopper_boss_locs = level.chopper_boss_locs;
	if( isdefined( level.chopper_boss_hangout ) )
		chopper_boss_locs = level.chopper_boss_hangout;
	
	foreach ( loc in chopper_boss_locs )
	{
		if ( IsDefined( loc.in_use ) || IsDefined( loc.disabled ) )
			continue;
		
		dist_2d_sqrd = distance_2d_squared( origin, loc.origin );
		
		if ( !IsDefined( dist_close ) || dist_2d_sqrd < dist_close )
		{
			dist_close = dist_2d_sqrd;
			loc_close  = loc;
		}
	}
	
	return loc_close;
}

chopper_boss_gather_targets()
{
	targets = [];
	
	if ( self.script_team == "allies" )
	{
		guys = getaiarray( "axis" );
		foreach ( ai in guys )
		{
			if ( !IsDefined( ai.ignoreme ) || ai.ignoreme == false )
			{
				targets[ targets.size ] = ai;
			}
		}
		guys = getaiarray( "team3" );
		foreach ( ai in guys )
		{
			if ( !IsDefined( ai.ignoreme ) || ai.ignoreme == false )
			{
				targets[ targets.size ] = ai;
			}
		}
	}
	else
	{
		// Target players not down and not set to ignore
		foreach( player in level.players )
		{
			if 	( !is_player_down( player ) 
				&&	( !IsDefined( player.ignoreme ) || player.ignoreme == false )
				)
			{
				targets[ targets.size ] = player;
			}
		}
		
		// Add allies
		allies = getaiarray( "allies" );
		foreach ( ally in allies )
		{
			if ( !IsDefined( ally.ignoreme ) || ally.ignoreme == false )
			{
				targets[ targets.size ] = ally;
			}
		}
		
		// If no targets were found, shoot at downed players not set to ignore
		if ( !targets.size )
		{
			foreach( player in level.players )
			{
				if	(
						!is_player_down_and_out( player )
					&&	( !IsDefined( player.ignoreme ) || player.ignoreme == false )
					)
				{
					targets[ targets.size ] = player;
				}
			}
		}
	}
	return targets;
}

chopper_boss_can_hit_from_mgturret( chopper_origin_test, target_origin )
{
	assertex( isdefined( chopper_origin_test ), "Shot origin not specified." );
	assertex( isdefined( target_origin ), "Target origin not specified." );

	// Approximate check from the X and Y of the shot origin and the Z of the turret origin
	offset_turret_z = self.mgturret[ 0 ].origin[ 2 ] - self.origin[ 2 ];
	
	return BulletTracePassed( chopper_origin_test + (0, 0, offset_turret_z), target_origin, false, self );
}

chopper_boss_can_hit_from_tag_turret( chopper_origin_test, target_origin )
{
	assertex( isdefined( chopper_origin_test ), "Shot origin not specified." );
	assertex( isdefined( target_origin ), "Target origin not specified." );
	
	// Approximate check from the X and Y of the shot origin and the Z of the turret origin
	turret_org = self getTagOrigin( "tag_flash" );
	offset_turret_z = turret_org[ 2 ] - self.origin[ 2 ];
	
	return BulletTracePassed( chopper_origin_test + (0, 0, offset_turret_z), target_origin, false, self );
}

chopper_boss_fire_mgturrets( target )
{
	assertex( isdefined( target ), "Helicopter told to shoot at invalid target" );
	
	self endon( "deathspin" );
	self endon( "death" );
	target endon( "death" );

	shot_count = self get_chopperboss_data( "shot_count" );
	
	foreach( turret in self.mgturret )
	{
		if ( isAI( target ) )
		{
			turret settargetentity( target, ( target geteye() - target.origin) * 0.7 );
		}
		else if ( isplayer( target ) )
		{
			// If player down, aim at origin and shoot to kill
			if ( is_player_down( target ) )
			{
				shot_count = self get_chopperboss_data( "shot_count_long" );
				turret settargetentity( target );
			}
			else
			{
				turret settargetentity( target, target geteye() - target.origin );
			}
		}
		else
		{
			turret settargetentity( target, ( 0, 0, 32 ) );
		}
		turret startbarrelspin();
	}
	
	wait self get_chopperboss_data( "windup_time" );
	
	turret_index = 0;
	
	for ( i = 0; i < shot_count; i++ )
	{
		weaponinfo = level.vehicle_mgturret[ self.classname ][ turret_index ];
		fire_time = weaponfiretime( weaponinfo.info );
		assertex( isdefined( fire_time ) && fire_time > 0, "Fire time not valid." );
		
		self.mgturret[ turret_index ] shootturret();
		turret_index++;
		
		if ( turret_index >= self.mgturret.size )
			turret_index = 0;

		wait fire_time + 0.05;
	}
	
	wait get_chopperboss_data( "weapon_cooldown_time" );
	
	foreach( turret in self.mgturret )
	{
		turret stopbarrelspin();
	}
}

chopper_boss_fire_weapon( target )
{
	assertex( isdefined( target ), "Helicopter told to shoot at invalid target" );
	
	self endon( "deathspin" );
	self endon( "death" );
	target endon( "death" );

	shot_count = self get_chopperboss_data( "shot_count" );
	
	if ( isAI( target ) )
	{
		self setTurretTargetEnt( target, target geteye() - target.origin );
	}
	else if ( isplayer( target ) )
	{
		// If player down, aim at origin and shoot to kill
		if ( is_player_down( target ) )
		{
			shot_count = self get_chopperboss_data( "shot_count_long" );
			self setTurretTargetEnt( target );
		}
		else
		{
			self setTurretTargetEnt( target, target geteye() - target.origin );
		}
	}
	else
	{
		self setTurretTargetEnt( target, ( 0, 0, 32 ) );
	}
		
	
	wait self get_chopperboss_data( "windup_time" );
	
	turret_index = 0;
	
	for ( i = 0; i < shot_count; i++ )
	{
		if ( isdefined( self.weapon ) )
			fire_time = weaponfiretime( self.weapon );
		else
			fire_time = 0.65;
			
		assertex( isdefined( fire_time ) && fire_time > 0, "Fire time not valid." );
		self FireWeapon();
		turret_index++;
		wait fire_time + 0.05;
	}
	
	wait get_chopperboss_data( "weapon_cooldown_time" );
}

chopper_boss_pre_move_func()
{
	if ( IsDefined( self chopper_boss_forced_target_get() ) )
	{
		self SetLookAtEnt( self chopper_boss_forced_target_get() );
	}
	else if ( IsDefined( self.heli_target ) )
	{
		self SetLookAtEnt( self.heli_target );
	}
	else
	{
		closest_player = getClosest( self.origin, level.players );
		if ( IsDefined( closest_player ) )
		{
			self SetLookAtEnt( closest_player );
		}
	}
}

chopper_boss_post_move_func()
{
}

chopper_boss_stop_func()
{		
	if ( IsDefined( self.heli_target ) )
	{
		self.fired_weapons = self maps\_chopperboss::chopper_boss_attempt_firing( self.heli_target );
	}
	else
		self.fired_weapons = false;
}