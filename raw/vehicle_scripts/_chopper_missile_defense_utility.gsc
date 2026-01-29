#include maps\_utility;
#include common_scripts\utility;

array_removeInvalidMissiles( missiles )
{
	missiles_valid = [];
	foreach ( m in missiles )
	{
		if ( !IsValidMissile( m ) )
			continue;
		
		missiles_valid[ missiles_valid.size ] = m;
	}
	
	return missiles_valid;
}

monitorEnemyMissileFire()
{
	owner = self.owner;
	
	for ( ; ; )
	{
		// JC-ToDo: This could miss a missile if two missiles are fired at the same time. Should grab missiles from an array or
		// instead of a notify the attacker should pass the missile directly to self.firedOnMe array.
		owner waittill( "LISTEN_missile_fire", missile );
		
		if ( !IsValidMissile( missile ) )
			continue;
		
		self.firedOnMe = array_removeInvalidMissiles( self.firedOnMe );
		self.firedOnMe = array_add( self.firedOnMe, missile );
	}
}

missile_monitorMissTarget( target, delete, delete_dist, missile_notify_missed, missile_endon )
{
	AssertEx( IsDefined( missile_notify_missed ), "missile_notify_missed must be defined." );
	
	missile = self;
	
	// Handle multiple systems calling this function
	missile notify( "missile_monitorMissTarget" );
	missile endon( "missile_monitorMissTarget" );
	
	missile endon( "death" );
	
	if ( IsDefined( missile_endon ) )
	{
		missile endon( missile_endon );
	}
	
	target endon( "death" );
	
	delete = ter_op( IsDefined( delete ), delete, false );
	
	// Clear this just in case there was a previous call to this function
	// where this missile missed a target
	missile.missed_target = undefined;
	
	dot = 1.0;
	
	while ( dot > 0.75 )
	{
		wait 0.05;
		
		// The target may be an ent that doesn't get death
		// notifies so validate it here
		if ( !IsDefined( target ) )
			break;
		
		missile_fwd			  = AnglesToForward( missile.angles );
		target_to_missile_fwd = VectorNormalize( target.origin - missile.origin );
		
		dot = VectorDot( target_to_missile_fwd, missile_fwd );
	}
	
	if ( IsDefined( target ) )
	{
		missile.missed_target = target;
	}
	
	missile notify( missile_notify_missed );
	
	missile Missile_ClearTarget();
	
	// If the target has missile defense logic running remove this
	// missile from the danger list.
	if	(
			IsDefined( target )
		&&	IsDefined( target.missile_defense )
		&&	IsDefined( target.missile_defense.firedOnMe )
		&&	target.missile_defense.firedOnMe.size
		)
	{
		target.missile_defense.firedOnMe = array_remove( target.missile_defense.firedOnMe, missile );
	}
	
	if ( !delete )
		return;
	
	if ( IsDefined( delete_dist ) )
	{
		delete_dist_sqrd = squared( delete_dist );
		
		while ( DistanceSquared( missile.origin, target.origin ) < delete_dist_sqrd )
			wait 0.05;
	}
	
	missile Delete();
}

monitorFlareRelease_auto( func_hud_flares_used, func_hud_flares_free )
{	
	owner = self.owner;
	
	activeRadius 	= self.flareActiveRadius;
	fireFlares 		= false;
	cooldown		= self.flareCooldown;
	flareNumPairs 	= self.flareNumPairs;
	flareReloadTime = self.flareReloadTime;
	
	for ( ; ; )
	{
		foreach ( missile in self.firedOnMe )
		{
			if ( dsq_2d_ents_lt( owner, missile, activeRadius ) )
			{
				fireFlares = true;
				break;
			}
		}
		
		have_ammo = true;
		if ( fireFlares )
		{
			if ( IsDefined( func_hud_flares_used ) )
				have_ammo = self [[ func_hud_flares_used ]]();
			
			if ( have_ammo )
			{
				for ( i = 0; i < flareNumPairs; i++ )
				{
					sides = array_randomize( [ "right", "left" ] );
					
					self delayThread( i * 0.5 + 0.05, ::shootFlares, sides[ 0 ] );
					self delayThread( i * 0.5 + 0.5, ::shootFlares, sides[ 1 ] );
				}
				wait cooldown;
			}
			
			fireFlares = false;
			
			if ( have_ammo )
			{
				if ( IsDefined( func_hud_flares_free ) )
					self childthread [[ func_hud_flares_free ]]( flareReloadTime );
				
				// If there was ammo for the fire then the cooldown wait already occurred
				continue;
			}
		}
		
		wait 0.05;
	}
}

monitorFlareRelease_input( func_hud_flares_used, func_hud_flares_free )
{
	AssertEx( IsDefined( func_hud_flares_used ) && IsDefined( func_hud_flares_free ), "Both hud use flare and hud free flare funcs need to be defined when calling monitorFlareRelease_input()" );
	
	owner = self.owner;
	
	activeRadius 	= self.flareActiveRadius;
	fireFlares 		= false;
	cooldown		= self.flareCooldown;
	flareNumPairs 	= self.flareNumPairs;
	flareReloadTime = self.flareReloadTime;
	
	owner NotifyOnPlayerCommand( "Listen_chopper_player_missile_defense_shoot_flares", "+smoke" );
	
	while ( 1 )
	{
		owner waittill( "Listen_chopper_player_missile_defense_shoot_flares" );
		
		// If flares successfully marked used, there was ammo
		// so fire flares
		if ( self [[ func_hud_flares_used ]]() )
		{	
			for ( i = 0; i < flareNumPairs; i++ )
			{
				sides = array_randomize( [ "right", "left" ] );
				
				self delayThread( i * 0.5 + 0.05, ::shootFlares, sides[ 0 ] );
				self delayThread( i * 0.5 + 0.5, ::shootFlares, sides[ 1 ] );
			}
			
			// Mark one flare ammo free on a delay
			self childthread [[ func_hud_flares_free ]]( flareReloadTime );
			
			// Wait cooldown before being allowed to fire again
			wait cooldown;
		}
	}
}

monitorEnemyMissileLockOn( func_hud_missile_lock )
{
	owner = self.owner;
	
	for ( ; ; )
	{
		owner waittill( "LISTEN_missile_lockOn", missileOwner );
		
		if ( !IsDefined( missileOwner ) )
			continue;
		
		if ( IsDefined( func_hud_missile_lock ) )
		{
			if ( !( self isEnemyLockedOnToMe( missileOwner ) ) )
				self childthread [[ func_hud_missile_lock ]]( missileOwner );
		}
		
		self.lockedOnToMe = array_removeUndefined( self.lockedOnToMe );
		self.lockedOnToMe = array_add( self.lockedOnToMe, missileOwner );
	}
}

isEnemyLockedOnToMe( enemy )	
{
	return is_in_array( self.lockedOnToMe, enemy );
}

isAnyEnemyLockedOnToMe()
{
	self.lockedOnToMe = array_removeUndefined( self.lockedOnToMe );
	
	return self.lockedOnToMe.size;
}

isAnyMissileFiredOnMe()
{
	self.firedOnMe = array_removeInvalidMissiles( self.firedOnMe );
	
	return self.firedOnMe.size;
}

flare_trackVelocity()
{
	self endon( "LISTEN_end_flare_trackVelocity" );
	self endon( "death" );
	
	self.velocity 	= 0;
	lastPos 		= self.origin;
	
	for ( ; ; wait 0.05 )
	{
		self.velocity 	= self.origin - lastPos;
		lastPos 		= self.origin;
	}
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
// MATH - These functions should be in a generic math util somewhere
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

dsq_2d_ents_lt( ent1, ent2, r, h, _default )
{
	if ( IsDefined( ent1 ) && IsDefined( ent2 ) && IsDefined( r ) )
		if ( IsDefined( h ) )
			return ter_op ( dsq_2d_ents( ent1, ent1 ) < Squared( r ) && abs( ent2.origin[ 2 ] - ent1.origin[ 2 ] ) < h, true, false );
		else
			return ter_op ( dsq_2d_ents( ent1, ent2 ) < Squared( r ), true, false );
	return ( ter_op( IsDefined( _default ), _default, false ) );
}

dsq_2d_ents( a, b )
{
	return LengthSquared( ( a.origin[ 0 ] - b.origin[ 0 ], a.origin[ 1 ] - b.origin[ 1 ], 0 ) );
}

dsq_ents_lt( ent1, ent2, r, _default )
{
	if ( IsDefined( ent1 ) && IsDefined( ent2 ) && IsDefined( r ) )
		return ter_op ( DistanceSquared( ent1.origin, ent2.origin ) < Squared( r ), true, false );
	return ( ter_op( IsDefined( _default ), _default, false ) );

}

flat_angle_yaw( angle )
{
	Assert( IsDefined( angle ) );
	return ( 0, angle[ 1 ], 0 );
}

gt_op( a, b, _default )
{
	if ( IsDefined( a ) && IsDefined( b ) )
		return ter_op( a > b, a, b );
	if ( IsDefined( a ) && !IsDefined( b ) )
		return a;
	if ( !IsDefined( a ) && IsDefined( b ) )
		return b;
	return _default;		
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
// Array - These functions should be in a generic array util somewhere
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

override_array_delete( array, msgs, delay )
{
	Assert( IsDefined( array ) && IsArray( array ) );
	
	if ( !IsDefined( msgs ) )
		msgs = [ "death" ];
	Assert( IsArray( msgs ) );
	
	delay 	= gt_op( delay, 0 );
	
	foreach( item in array )
	{
		if ( IsDefined( item ) )
		{
			if ( IsArray( item ) )
			{
				if ( delay > 0 )
				{
					override_array_delete( item, msgs, delay );
					wait 0.05;
				}
				else
					thread override_array_delete( item, msgs, 0 );
			}
			else
			{
				foreach ( msg in msgs )
					item notify( msg );
					
				if ( delay > 0 )
				{
					wait 0.05;
					if ( IsDefined( item ) )
						item Delete();
				}
				else
					item Delete();
			}
		}
	}
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
// Misc. Utility Functions
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//

on_param_death_delete_self( param )
{
	self notify( "on_param_death_delete_self" );
	self endon( "on_param_death_delete_self" );
	
	self endon( "death" );
	
	param waittill( "death" );
	
	if ( IsDefined( self ) )
		self Delete();
}

//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//
// Attempting to make flare shooting and management common
//-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.//


shootFlares( side )
{
	if ( !IsDefined( self ) || !IsDefined( self.owner ) )
		return;
	
	owner = self.owner;
	
	// Spawn and position rig
	
	rig = spawn_anim_model( self.flareRig_name );
	
	angles = owner.angles;
	if ( IsDefined( self.flareRig_tagAngles ) )
	{
		angles = flat_angle_yaw( owner GetTagAngles( self.flareRig_tagAngles ) );
	}
	else if ( IsPlayer( owner ) )
	{
		// If this is the player grab the look pitch
		angles = ( owner GetPlayerAngles()[ 0 ], angles[ 1 ], angles[ 2 ] );
	}
	
	origin = owner.origin;
	if ( IsDefined( self.flareRig_tagOrigin ) )
	{
		origin = owner GetTagOrigin( self.flareRig_tagOrigin );
	}
	
	right		= AnglesToRight( angles );
	sign		= ter_op( side == "right", 1, -1 );
	rightOffset	= self.flareSpawnOffsetRight;
	rig.origin 	= origin + sign * rightOffset * right;
	yawOffset	= RandomFloatRange( self.flareSpawnMinYawOffset, self.flareSpawnMaxYawOffset );
	pitchOffset = RandomFloatRange( self.flareSpawnMinPitchOffset, self.flareSpawnMaxPitchOffset );
	angles		= ( angles[ 0 ] - pitchOffset, angles[ 1 ] + -1 * sign * yawOffset, angles[ 2 ] + sign * 90 );
	rig.angles	= angles;
	
	if ( self.flareRig_link )
	{
		rig LinkTo( self.vehicle, "tag_origin" );
	}
	
	// Spawn flares by tag and record them
	
	self.flares = array_removeUndefined( self.flares );
	
	flares 	= [];
	tags 	= [ "flare_left_bot", "flare_right_bot" ];
		
	foreach ( tag in tags )
	{
		flare 			= rig spawn_tag_origin();
		flare.origin 	= rig GetTagOrigin( tag );
		flare.angles 	= rig GetTagAngles( tag );
		flare LinkTo( rig, tag );
		flare thread flare_trackVelocity();
		flares[ tag ] = flare;
	}
	
	self.flares = array_combine( self.flares, flares );
	
	// Play flare anim
	
	count 	= level.scr_anim[ self.flareRig_name ][ "flare" ].size;
	anime 	= level.scr_anim[ self.flareRig_name ][ "flare" ][ self.flareIndex % count ];
	self.flareIndex++;
	
	anim_rate = ter_op( IsDefined( self.flareRig_animRate ), self.flareRig_animRate, 1 );
	rig SetFlaggedAnim( "flare_anim", anime, 1, 0, anim_rate );

	// Play flare fx
	
	// JC-ToDo: I'm not sure why this wait is here. Why you no comment!
	wait 0.05;
	
	foreach ( tag, flare in flares )
	{
		if ( IsDefined( flare ) )
		{
			PlayFXOnTag( self.flareFx, flares[ tag ], "tag_origin" );
		}
	}
	
	rig thread play_sound_on_tag( self.flareSound, "tag_fx", true );

	rig waittillmatch( "flare_anim", "end" );
	
	foreach ( tag, flare in flares )
	{
		if ( IsDefined( flare ) )
		{
			StopFXOnTag( self.flareFx, flares[ tag ], "tag_origin" );
		}
	}

	rig Delete();
	
	flares = array_removeUndefined( flares );
	array_thread( flares, ::flare_doBurnOut );
	
	if ( IsDefined( self.flares ) )
		self.flares = array_removeUndefined( self.flares );
}

FLARE_BURN_OUT_TIME 	= 0.2;
FLARE_VELOCITY_SCALE 	= 14;

flare_doBurnOut()
{
	self endon( "death" );
	
	self notify( "LISTEN_end_flare_trackVelocity" );
	
	self MoveGravity( FLARE_VELOCITY_SCALE * self.velocity, FLARE_BURN_OUT_TIME );
	wait FLARE_BURN_OUT_TIME;
	
	// Don't delete flares which are undefined or paired with a missile.
	// Paired flares are cleaned up by the missile logic
	if ( !IsDefined( self ) || IsDefined( self.myTarget ) )
		return;
	
	self Delete();
}

flare_monitorAttractor( attractor )
{
	self waittill( "death" );
	
	Missile_DeleteAttractor( attractor );
}

flare_monitorTakingOutMissile( range, missile, missile_defense )
{	
	self endon( "death" );
	missile endon( "death" );
	
	// Let the missile lock on systems know that the missile is no longer locked
	missile notify( "LISTEN_missile_attached_to_flare" );
	
	range_sqrd = squared( range );
	
	// Once this flare and this missile are linked the regular flare system
	// will no longer clean up this flare. It's up to this missile flare 
	// pairing system to make sure the missile and the flare are destroyed.
	missile.myTarget 	= self;
	self.myTarget 		= missile;
	
	// These two calls insure that the flare and the missile are cleaned up together
	// if the other dies
	missile thread on_param_death_delete_self( self );
	self thread on_param_death_delete_self( missile );
	
	// Get a notification if the missile misses the flair
	missile thread missile_monitorMissTarget( missile.myTarget, false, undefined, "LISTEN_missile_missed_flare" );
	
	while ( 1 )
	{
		msg = waittill_any_timeout( 0.05, "LISTEN_missile_missed_flare" );
		
		// Insure the missile_monitorMissTarget() logic a chance to run
		waittillframeend;
		
		// If the missile missed the flare or if the missile is
		// in range of the flare destroy the missile
		if	(
				msg == "LISTEN_missile_missed_flare" 
			||	( IsDefined( missile.missed_target ) && missile.missed_target == missile.myTarget )
			|| 	DistanceSquared( self.origin, missile.origin ) <= range_sqrd
			)
		{
			if ( self IsLinked() )
				self UnLink();
			
			angles 	= flat_angle_yaw( missile.angles );
			fwd 	= AnglesToForward( angles );
			
			PlayFX( missile_defense.flareFxExplode, missile.origin, fwd );
			StopFXOnTag( missile_defense.flareFx, self, "tag_origin" );
			
			Earthquake( 0.5, 0.6, missile.origin, 2048 );
			
			thread play_sound_in_space( "chopper_trophy_fire", missile.origin );
			
			missile Delete();
			self Delete();
			return;
		}
	}
}


monitorFlares()
{
	for ( ; ; wait 0.05 )
	{
		self.firedOnMe 	= array_removeInvalidMissiles( self.firedOnMe );
		self.flares 	= array_removeUndefined( self.flares );
		
		if ( self.firedOnMe.size && self.flares.size )
		{
			pairFlaresWithClosestMissile();
		}
	}
}

pairFlaresWithClosestMissile()
{
	range = self.missileTargetFlareRadius;
	
	foreach ( missile in self.firedOnMe )
	{
		if ( !IsValidMissile( missile ) || IsDefined( missile.myTarget ) )
			continue;

		flare 			= undefined;
		flareInRange 	= false;
		
		foreach ( _flare in self.flares )
		{
			if ( IsDefined( _flare.myTarget ) )
				continue;
			if ( !IsDefined( flare ) )
				flare = _flare;
			
			dsq1 = DistanceSquared( flare.origin, missile.origin );
			dsq2 = DistanceSquared( _flare.origin, missile.origin );
			
			if ( dsq1 < range * range )
				flareInRange = true;
			
			if ( dsq2 < dsq1 )
				flare = _flare;
		}
		
		if ( IsDefined( flare ) && flareInRange )
		{
			AssertEx( IsDefined( missile.type_missile ), "ai_missile_defense handling missile without type_missile field." );
			missile.type_missile = ter_op( IsDefined( missile.type_missile ), missile.type_missile, "guided" );
			
			switch ( missile.type_missile )
			{
				case "guided":
					missile Missile_SetTargetEnt( flare );
					missile Missile_SetFlightmodeDirect();
					break;
				case "straight":
					attractor = Missile_CreateAttractorEnt( flare, 100000, range );
					flare thread flare_monitorAttractor( attractor );
					break;
			}
			
			flare thread flare_monitorTakingOutMissile( self.flareDestroyMissileRadius, missile, self );
		}
	}
}

