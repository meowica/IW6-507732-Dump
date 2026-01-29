#include animscripts\utility;

#using_animtree( "dog" );

main()
{
	if ( isdefined( level.shark_functions ) )
	{
		if ( issubstr( self.model, "shark" ) )
		{
			self [[ level.shark_functions["stop"] ]]();
			return;
		}
	}
	
	self endon( "killanimscript" );

	self ClearAnim( %body, 0.2 );
	self SetAnim( %dog_idle_knob );

	//self thread lookAtTarget( "attackIdle" );

	self thread WaitForDrivenChange();

	self.dogNextIdleTwitchTime = GetDogNextTwitchTime();

	while ( 1 )
	{
		if ( self IsDogBeingDriven() )
		{
			self DoDrivenIdle();
			continue;
		}

		if ( IsDefined( self.specialIdleAnim ) )
		{
			self DoSpecialIdle();
			continue;
		}

		// check turning
		if ( !self IsDogBeingDriven() && ( !IsDefined( self.bIdleLooking ) || !self.bIdleLooking ) )
		{
			handler = self.dogHandler;
			if ( IsDefined( handler ) )
			{
				if ( IsDefined( handler.node ) && IsDefined( self.node ) )
				{
					meToHandler = handler.origin - self.origin;
					TurnToAngle( VectorToYaw( meToHandler ) );
				}
				else
				{
					cTurnTowardMyHandlerRadiusSq = 256 * 256;
					cTurnWhereMyHandlerIsTurnedRadiusSq = 80 * 80;
					distToHandlerSq = DistanceSquared( self.origin, handler.origin );

					if ( distToHandlerSq < cTurnWhereMyHandlerIsTurnedRadiusSq )
					{
						self TurnToAngle( handler.angles[1] );
					}
					else if ( distToHandlerSq < cTurnTowardMyHandlerRadiusSq )
					{
						meToHandler = handler.origin - self.origin;
						anglesToHandler = VectorToYaw( meToHandler );
						self TurnToAngle( anglesToHandler );
					}
				}
			}
			else if ( IsDefined( self.node ) && ShouldFaceNodeDir( self.node ) )
			{
				self TurnToAngle( self.node.angles[1] );
			}
			else if ( IsDefined( self.enemy ) && IsAlive( self.enemy ) )
			{
				meToEnemy = self.enemy.origin - self.origin;
				TurnToAngle( VectorToYaw( meToEnemy ) );
			}
			self OrientMode( "face current" );
		}

		// do animation / sound etc.
		if ( IsDefined( self.customIdleAnimSet ) )
		{
			self StopLookAtIdle();
			self DoCustomIdle();
		}
		else if ( self ShouldAttackIdle() )
		{
			self StopIdleSound();
			self StopLookAtIdle();

			bShouldTwitch = !IsDefined( self.enemy ) || Distance2DSquared( self.origin, self.enemy.origin ) > 768 * 768;
			if ( bShouldTwitch && GetTime() > self.dogNextIdleTwitchTime )
			{
				idleAnim = self ChooseAttackIdle();
				self PlayIdleAnim( self GetDogStopAnim( idleAnim ), false, 0.2, -1 );
				self.dogNextIdleTwitchTime = GetDogNextTwitchTime();
			}
			else
			{
				self PlayIdleAnim( self GetDogStopAnim( "attackidle" ), false, 0.5, 0.5 );
			}
		}
		else if ( self ShouldCoverIdle() )
		{
			self StopIdleSound();
			self StopLookAtIdle();

			self PlayIdleAnim( self GetDogStopAnim( "cover_crouch" ), false, 0.5, 2 );
		}
		else
		{
			self StopIdleSound();

			if ( IsDefined( self.idleLookAtTargets ) )
			{
				self DoLookAtIdle();
			}
			else
			{
				self StopLookAtIdle();
				self PlayIdleAnim( self GetDogStopAnim( "casualidle" ), false, 0.5, 2 );
			}
		}
	}
}

end_script()
{
	if ( IsDefined( self.prevTurnRate ) )
	{
		self.turnRate = self.prevTurnRate;
		self.prevTurnRate = undefined;
	}
	self.dogTurnAdjust = undefined;
	self.dogTurnRate = undefined;
	self.dogNextIdleTwitchTime = undefined;

	self StopIdleSound();
	self StopLookAtIdle();
}

PlayIdleAnim( idleAnim, bRestart, blendTime, playTime )
{
	self endon( "killIdleAnim" );

	if ( bRestart )
		self SetFlaggedAnimKnobRestart( "dog_idle", idleAnim, 1, blendTime, self.animPlaybackRate );
	else
		self SetFlaggedAnimKnob( "dog_idle", idleAnim, 1, blendTime, self.animPlaybackRate );

	if ( playTime > 0 )
		self animscripts\notetracks::DoNotetracksForTime( playTime, "dog_idle" );
	else
		self animscripts\shared::DoNotetracks( "dog_idle" );
}

WaitForDrivenChange()
{
	self endon( "killanimscript" );

	bWasDriven = self IsDogBeingDriven();
	while ( true )
	{
		bIsDriven = self IsDogBeingDriven();
		if ( bIsDriven != bWasDriven )
		{
			self KillIdleAnim();
			bWasDriven = bIsDriven;
		}
		wait( 0.1 );
	}
}

KillIdleAnim()
{
	self notify( "killIdleAnim" );
	self StopLookAtIdle();
}

ShouldFaceNodeDir( node )
{
	return node.type == "Cover Crouch" || node.type == "Guard" || node.type == "Exposed";
}

GetTurnAnim( angleDiff )
{
	if ( self ShouldAttackIdle() )
	{
		if ( angleDiff < -135 || angleDiff > 135 )
			return self GetDogStopAnim( "attack_turn_180" );
		else if ( angleDiff < 0 )
			return self GetDogStopAnim( "attack_turn_right" );
		else
			return self GetDogStopAnim( "attack_turn_left" );
	}
	else
	{
		if ( angleDiff < -135 || angleDiff > 135 )
			return self GetDogStopAnim( "casual_turn_180" );
		else if ( angleDiff < 0 )
			return self GetDogStopAnim( "casual_turn_right" );
		else
			return self GetDogStopAnim( "casual_turn_left" );
	}
}

HandleDogTurnNotetracks( note )
{
	if ( note == "turn_begin" )
	{
		assert( IsDefined( self.dogTurnAdjust ) );
		assert( IsDefined( self.dogTurnRate ) );

		angleAdjustment = AngleClamp180( self.angles[1] + self.dogTurnAdjust );
		self.dogTurnAdjust = undefined;

		self.prevTurnRate = self.turnRate;
		self.turnRate = self.dogTurnRate;		// degrees per millisecond.
		self.dogTurnRate = undefined;

		self OrientMode( "face angle", angleAdjustment );
	}
	else if ( note == "turn_end" )
	{
		self.turnRate = self.prevTurnRate;
		self.prevTurnRate = undefined;
	}
}

TurnToAngle( desiredAngle )
{
	self endon( "killIdleAnim" );

	currentAngle = self.angles[1];
	angleDiff = AngleClamp180( desiredAngle - currentAngle );

	if ( -0.5 < angleDiff && angleDiff < 0.5 )
		return;

	if ( -15 < angleDiff && angleDiff < 15 )
	{
		RotateToAngle( desiredAngle, 2 );
		return;
	}

	self StopIdleSound();

	turnAnim = self GetTurnAnim( angleDiff );

	animLength = GetAnimLength( turnAnim );
	animRotation = GetAngleDelta( turnAnim );

	blendTime = 0.2;
	if ( animLength < 0.6 )
		blendTime = 0.05;	// default of 0.2 blend-smooshes too much of his rotation, dog doesn't turn nearly enough.

	self AnimMode( "zonly_physics" );
	self SetFlaggedAnimKnobRestart( "dog_turn", turnAnim, 1, blendTime );

	if ( AnimHasNotetrack( turnAnim, "turn_begin" ) && AnimHasNotetrack( turnAnim, "turn_end" ) )
	{
		beginTimes = GetNotetrackTimes( turnAnim, "turn_begin" );
		endTimes = GetNotetrackTimes( turnAnim, "turn_end" );
		turnTime = (endTimes[0] - beginTimes[0]) * animLength;

		self.dogTurnAdjust = AngleClamp180( angleDiff - animRotation );
		self.dogTurnRate = max( abs(self.dogTurnAdjust) / turnTime / 1000, 0.01 );		// degrees per millisecond.

		self OrientMode( "face current" );

		self animscripts\shared::DoNoteTracks( "dog_turn", ::HandleDogTurnNotetracks );
	}
	else
	{
		self.prevTurnRate = self.turnRate;
		self.turnRate = max( abs( AngleClamp180(angleDiff-animRotation) ) / animLength / 1000, 0.01);		// degrees per millisecond.

		self OrientMode( "face angle", AngleClamp180( desiredAngle - animRotation ) );

		self animscripts\shared::DoNoteTracks( "dog_turn" );

		self.turnRate = self.prevTurnRate;
		self.prevTurnRate = undefined;
	}

	self ClearAnim( turnAnim, 0.2 );
	self AnimMode( "none" );
}


RotateToAngle( desiredAngle, tolerance )
{
	self OrientMode( "face angle", desiredAngle );
	while ( abs( AngleClamp180( desiredAngle - self.angles[1] ) ) > tolerance )
		wait ( 0.1 );
}


//isFacingEnemy( toleranceCosAngle )
//{
//	assert( isdefined( self.enemy ) );
//
//	vecToEnemy = self.enemy.origin - self.origin;
//	distToEnemy = length( vecToEnemy );
//
//	if ( distToEnemy < 1 )
//		return true;
//
//	forward = anglesToForward( self.angles );
//
//	return( ( forward[ 0 ] * vecToEnemy[ 0 ] ) + ( forward[ 1 ] * vecToEnemy[ 1 ] ) ) / distToEnemy > toleranceCosAngle;
//}

ShouldCoverIdle()
{
	if ( IsDefined( self.node ) && self.node.type == "Cover Crouch" )
		return true;
	if ( IsDefined( self.prevNode ) && self.prevNode.type == "Cover Crouch" )
		return true;
	return false;
}

ChooseAttackIdle()
{
	twitches = [ "attackidle_twitch_1", "attackidle_twitch_2" ];
	twitchWeights = [ 1, 1 ];

	if ( !IsDefined( self.script_nobark ) || !self.script_nobark )
	{
		i = twitches.size;
		twitches[ i ] = "attackidle_bark";
		twitchWeights[ i ] = 4;
	}

	totalWeight = 0;
	for ( i = 0; i < twitchWeights.size; i++ )
		totalWeight += twitchWeights[i];

	randInt = randomInt( totalWeight );

	weight = 0;
	for ( i = 0; i < twitchWeights.size; i++ )
	{
		weight += twitchWeights[i];
		if ( randInt < weight )
			return twitches[ i ];
	}

	assertmsg( "should never get here" );
}

DoDrivenIdle()
{
	self PlayIdleSound( self.customIdleSound );

	self PlayIdleAnim( self GetDogStopAnim( "sneak" ), false, 0.5, -1 );
}

DoSpecialIdle()
{
	assert( IsDefined( self.specialIdleAnim ) );
	if ( IsArray( self.specialIdleAnim ) )
	{
		assert( self.specialIdleAnim.size > 0 );
		idleAnim = self.specialIdleAnim[ RandomInt( self.specialIdleAnim.size ) ];
	}
	else
	{
		idleAnim = self.specialIdleAnim;
	}

	self PlayIdleSound( self.customIdleSound );

	self PlayIdleAnim( idleAnim, false, 0.5, -1 );
}

DoCustomIdle()
{
	assert( IsDefined( self.customIdleAnimSet ) );
	if ( IsArray( self.customIdleAnimSet ) )
	{
		assert( self.customIdleAnimSet.size > 0 );
		if ( IsDefined( self.customIdleAnimWeights ) )
			idleAnim = anim_array( self.customIdleAnimSet, self.customIdleAnimWeights );
		else
			idleAnim = self.customIdleAnimSet[ RandomInt( self.customIdleAnimSet.size ) ];
	}
	else
	{
		idleAnim = self.customIdleAnimSet;
	}

	self PlayIdleSound( self.customIdleSound );

	self PlayIdleAnim( idleAnim, false, 0.5, -1 );
}

DoLookAtIdle()
{
	if ( !IsDefined( self.bIdleLooking ) || !self.bIdleLooking )
	{
		self.bIdleLooking = true;

		self thread LookAtIdleUpdate();
	}
	wait( 0.5 );
}

StopLookAtIdle()
{
	if ( !IsDefined( self.bIdleLooking ) || !self.bIdleLooking )
		return;

	self.bIdleLooking = undefined;
	self.idleTrackLoop = undefined;
	self notify( "endIdleLookAt" );

	//self ClearAnim( %idle_look, 1 );
	self ClearAnim( %look_2, 1 );
	self ClearAnim( %look_4, 1 );
	self ClearAnim( %look_6, 1 );
	self ClearAnim( %look_8, 1 );
}

LookAtIdleUpdate()
{
	self endon( "killanimscript" );
	self endon( "endIdleLookAt" );

	while ( IsDefined( self.idleLookAtTargets ) && IsArray( self.idleLookAtTargets ) )
	{
		target = self GetLookAtTarget( self.lookAtTarget );
		self.lookAtTarget = target;

		if ( !IsDefined( self.idleTrackLoop ) )
			self thread IdleTrackLoop();

		duration = 2 + RandomFloat( 3 );
		wait( duration );
	}

	// list got emptied out while i wasn't looking.  i'm done.
	self StopLookAtIdle();
}

GetLookAtTarget( prevTarget )
{
	bHadPrevTarget = IsDefined( prevTarget );

	if ( self.idleLookAtTargets.size == 1 )
	{
		if ( bHadPrevTarget )
			return undefined;
		else
			return self.idleLookAtTargets[0];
	}

	if ( bHadPrevTarget )
	{
		randInt = RandomInt( 100 );
		if ( randInt < 33 )
			return undefined;	// look at no one for a while
	}

	lookAtTargets = self.idleLookAtTargets;
	lookAtWeights = [];
	totalWeights = 0;
	bRemovedPrev = !bHadPrevTarget;
	for ( i = 0; i < lookAtTargets.size; i++ )
	{
		if ( !bRemovedPrev && lookAtTargets[i] == prevTarget )
		{
			lastIdx = lookAtTargets.size - 1;
			if ( i == lastIdx )
				lookAtTargets[i] = lookAtTargets[ lastIdx ];
			lookAtTargets[ lastIdx ] = undefined;
			bRemovedPrev = true;
			if ( i == lastIdx )
				break;
		}

		// favor the closest.  don't favor people outside of my cone.
		distToMeSq = Distance2DSquared( self.origin, lookAtTargets[i].origin );
		assert( distToMeSq > 0 );
		lookAtWeights[ i ] = 1 / distToMeSq;
		totalWeights += lookAtWeights[i];

		//meToTarget = VectorToAngles( lookAtTargets[i].origin - self.origin );
	}

	// look at someone.
	randFloat = RandomFloat( totalWeights );
	weight = 0;
	for ( i = 0; i < lookAtTargets.size; i++ )
	{
		weight += lookAtWeights[i];
		if ( randFloat < weight )
			return lookAtTargets[i];
	}
	assertmsg( "should never happen" );
}


IdleTrackLoop()
{
	self endon( "killanimscript" );
	self endon( "endIdleLookAt" );

	self.idleTrackLoop = true;

	self ClearAnim( %dog_idle_knob, 0.2 );
	self SetAnimKnob( self GetDogStopAnim( "casualidle_base" ), 1, 0.5 );

	//self SetAnim( %idle_look );

	self SetAnimKnobLimited( self GetDogStopAnim( "casualidle_look_2" ), 1, 0 );
	self SetAnimKnobLimited( self GetDogStopAnim( "casualidle_look_4" ), 1, 0 );
	self SetAnimKnobLimited( self GetDogStopAnim( "casualidle_look_6" ), 1, 0 );
	self SetAnimKnobLimited( self GetDogStopAnim( "casualidle_look_8" ), 1, 0 );

	leftLimit = 90;
	rightLimit = -100;
	upLimit = -25;
	downLimit = 25;

	while ( true )
	{
		myEyePos = self GetEye();
		if ( IsDefined( self.lookAtTarget ) )
		{
			targetEyePos = self.lookAtTarget GetEye();

			meToTarget = targetEyePos - myEyePos;
			meToTargetAngles = VectorToAngles( meToTarget );
		}
		else
		{
			meToTargetAngles = self.angles;
		}

		desiredYaw = AngleClamp180( meToTargetAngles[1] - self.angles[1] );
		desiredPitch = AngleClamp180( meToTargetAngles[0] - self.angles[0] );

		if ( desiredYaw > leftLimit || desiredYaw < rightLimit )
		{
			self TurnToAngle( self.angles[1] + desiredYaw * 0.75 );
			self SetAnimKnob( self GetDogStopAnim( "casualidle_base" ), 1, 0.1 );
			continue;
		}

		l = 0; r = 0;
		u = 0; d = 0;
		if ( desiredYaw > 0 )
			l = Clamp( desiredYaw / leftLimit, 0, 1 );
		else
			r = Clamp( desiredYaw / rightLimit, 0, 1 );

		if ( desiredPitch < 0 )
			u = Clamp( desiredPitch / upLimit, 0, 1 );
		else
			d = Clamp( desiredPitch / downLimit, 0, 1 );

		self SetAnimLimited( %look_2, d, 0.5 );
		self SetAnimLimited( %look_4, l, 0.5 );
		self SetAnimLimited( %look_6, r, 0.5 );
		self SetAnimLimited( %look_8, u, 0.5 );

		wait( 0.05 );
	}
}


NeedToDecelForArrival( remainingDist, speed, decel )
{
	if ( speed == 0 )
		return false;

	d = abs(remainingDist);
	v = abs( speed );
	decel = abs( decel );
	while ( d > 0 )
	{
		d -= v;
		v -= decel;
		if ( v < 0 )
			return false;
	}
	return true;
}


shouldAttackIdle()
{
	if ( IsDefined( self.node ) && self.node.type == "Guard" )
		return true;

	if ( IsDefined( self.prevNode ) && self.prevNode.type == "Guard" )
		return true;
	
	if ( IsDefined( self.enemy ) && IsAlive( self.enemy ) && DistanceSquared( self.origin, self.enemy.origin ) < 1000000 && self SeeRecently( self.enemy, 5 ) )
		return true;

	return false;
}

should_growl()
{
	if ( isdefined( self.script_growl ) )
		return true;
	if ( !isdefined( self.enemy ) )
		return false;
	if ( !isalive( self.enemy ) )
		return true;
	return !( self cansee( self.enemy ) );
}

lookAtTarget( lookPoseSet )
{
	self endon( "killanimscript" );
	self endon( "stop tracking" );

	self clearanim( %german_shepherd_look_2, 0 );
	self clearanim( %german_shepherd_look_4, 0 );
	self clearanim( %german_shepherd_look_6, 0 );
	self clearanim( %german_shepherd_look_8, 0 );

	self setDefaultAimLimits();
	self.rightAimLimit = 90;
	self.leftAimLimit = -90;

	self setanimlimited( anim.dogLookPose[ lookPoseSet ][ 2 ], 1, 0 );
	self setanimlimited( anim.dogLookPose[ lookPoseSet ][ 4 ], 1, 0 );
	self setanimlimited( anim.dogLookPose[ lookPoseSet ][ 6 ], 1, 0 );
	self setanimlimited( anim.dogLookPose[ lookPoseSet ][ 8 ], 1, 0 );

	self animscripts\track::setAnimAimWeight( 1, 0.2 );

/#	
	assert( !isdefined( self.trackLoopThread ) );
	self.trackLoopThread = thisthread;
	self.trackLoopThreadType = "lookAtTarget";
#/
	
	self animscripts\track::trackLoop( %german_shepherd_look_2, %german_shepherd_look_4, %german_shepherd_look_6, %german_shepherd_look_8 );
}

PlayIdleSound( idleSound )
{
	bSelfIdleSoundDefined = IsDefined( self.idleSound );
	bIdleSoundDefined = IsDefined( idleSound );
	if ( !bSelfIdleSoundDefined && !bIdleSoundDefined )
		return;
	else if ( bSelfIdleSoundDefined && bIdleSoundDefined && self.idleSound == idleSound )
		return;

	self StopIdleSound();

	if ( bIdleSoundDefined )
		self thread LoopIdleSound( idleSound );
}

LoopIdleSound( soundAlias )
{
	self endon( "killanimscript" );

	soundOrigin = Spawn( "script_origin", self.origin );
	soundOrigin.angles = self.angles;
	soundOrigin LinkTo( self );

	self.idleSoundOrigin = soundOrigin;

	self.idleSound = soundAlias;

	while ( true )
	{
		soundOrigin PlaySound( soundAlias, "dog_idle_sound" );

		bDone = self IdleSound_WaitForDoneOrDeath( soundOrigin, "dog_idle_sound" );
		if ( !IsDefined( bDone ) )
			break;
	}
}

IdleSound_WaitForDoneOrDeath( soundOrigin, doneNotify )
{
	self endon( "death" );
	soundOrigin endon( "death" );
	soundOrigin waittill( doneNotify );
	return true;
}

StopIdleSound()
{
	if ( IsDefined( self.idleSoundOrigin ) )
	{
		if ( self.idleSoundOrigin IsWaitingOnSound() )
		{
			self.idleSoundOrigin StopSounds();
			wait( 0.05 );
		}

		self.idleSoundOrigin Delete();
		self.idleSoundOrigin = undefined;
		self.idleSound = undefined;
	}
}

GetDogNextTwitchTime()
{
	if ( IsDefined( self.script_nobark ) && self.script_nobark )
		return GetTime() + 4000 + RandomInt( 3000 );
	return GetTime() + 1000 + RandomInt( 1000 );
}

GetDogStopAnim( a_Anim )
{
	assertEx( animscripts\animset::ArchetypeExists( "dog" ), "dog archetype uninitialized" );

	stopAnim = animscripts\utility::LookupDogAnim( "stop", a_Anim );

	assertEx( IsDefined( stopAnim ), a_Anim + " is not a valid stop animation for dogs." );

	return stopAnim;
}

InitDogArchetype_Stop()
{
	dogAnims = [];

	dogAnims[ "attackidle" ] = %iw6_dog_attackidle;		// no point in having this if we have attackidle_b?
	dogAnims[ "attack_turn_left" ] = %iw6_dog_attackidle_turn_4;
	dogAnims[ "attack_turn_right" ] = %iw6_dog_attackidle_turn_6;
	dogAnims[ "attack_turn_180" ] = %iw6_dog_attackidle_turn_2;

	dogAnims[ "cover_crouch" ] = %iw6_dog_attackidle;	// temp

	//dogAnims[ "attackidle_growl" ] = %iw6_dog_attackidle;
	//dogAnims[ "attackidle_b" ] = %iw6_dog_attackidle;
	dogAnims[ "attackidle_bark" ] = %iw6_dog_attackidle_bark;
	dogAnims[ "attackidle_twitch_1" ] = %iw6_dog_attackidle_twitch_1;
	dogAnims[ "attackidle_twitch_2" ] = %iw6_dog_attackidle_twitch_2;

	dogAnims[ "casualidle" ] = %iw6_dog_casualidle;
	dogAnims[ "casual_turn_left" ] = %iw6_dog_casualidle_turn_4;
	dogAnims[ "casual_turn_right" ] = %iw6_dog_casualidle_turn_6;
	dogAnims[ "casual_turn_180" ] = %iw6_dog_casualidle_turn_2;

	dogAnims[ "casualidle_base" ] = %iw6_dog_casualidle_base;
	dogAnims[ "casualidle_look_2" ] = %iw6_dog_casualidle_2;
	dogAnims[ "casualidle_look_4" ] = %iw6_dog_casualidle_4;
	dogAnims[ "casualidle_look_6" ] = %iw6_dog_casualidle_6;
	dogAnims[ "casualidle_look_8" ] = %iw6_dog_casualidle_8;

	dogAnims[ "sneak" ] = %iw6_dog_sneak_stand_idle;

	anim.archetypes[ "dog" ][ "stop" ] = dogAnims;
}
