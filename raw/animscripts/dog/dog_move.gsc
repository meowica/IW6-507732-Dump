#include maps\_utility;
#include animscripts\shared;
#include animscripts\notetracks;
#include animscripts\utility;
#include common_scripts\utility;

#using_animtree( "dog" );

main()
{
	if ( isdefined( level.shark_functions ) )
	{
		if ( issubstr( self.model, "shark" ) )
		{
			self [[ level.shark_functions["move"] ]]();
			return;
		}
	}

	self endon( "killanimscript" );

	self thread HandleFootstepNotetracks();

	if ( self IsDogBeingDriven() )
	{
		//self StartDrivenMovement();
		self ContinueDrivenMovement();
	}
	else
	{
		self StartMove();
		self ContinueMovement();
	}
}

end_script()
{
	if ( IsDefined( self.prevTurnRate ) )
	{
		self.turnRate = self.prevTurnRate;
		self.prevTurnRate = undefined;
	}
	self.drivenMoveMode = undefined;

	if ( IsDefined( self.moveOverrideSound ) )
	{
		self StopMoveSound();
		self.moveOverrideSound = undefined;
	}

	self CancelAllBut( undefined );
}

SetupMovement()
{
	self thread WaitForDrivenChange();
	self thread WaitForRunWalkSlopeChange();
	self thread WaitForRateChange();
	self thread WaitForBark();
	self thread WaitForSharpTurn();
	self thread WaitForStop();
	self thread WaitForFollowSpeed();
}

ContinueMovement()
{
	self.moveRateMultiplier = 1;

	self SetupMovement();

	self AnimMode( "none" );
	self OrientMode( "face motion" );

	self ClearAnim( %body, 0.2 );

	self SetMoveAnim( self.moveMode, self.stairsState, true );
}

ContinueDrivenMovement()
{
	self ClearAnim( %body, 0.5 );

	self.drivenMoveMode = self GetDesiredDrivenMoveMode( "walk" );
	self SetDrivenAnim( self.drivenMoveMode, true );

	self thread WaitForDrivenChange();
	self thread DrivenAnimUpdate();
}

StartMove()
{
	negStartNode = self GetNegotiationStartNode();
	if ( IsDefined( negStartNode ) )
		goalPos = negStartNode.origin;
	else
		goalPos = self.pathGoalPos;

	if ( !IsDefined( goalPos ) )	// why would i be starting to move if i have no path goal?	// because i'm trying to 'dodge'
		return;

	// don't play start if i have no room for the start.
	if ( DistanceSquared( goalPos, self.origin ) < 256 * 256 )
		return;

	if ( isdefined( self.disableexits ) && self.disableexits )
		return;

	if ( self IsDogBeingDriven() )
		return;

	lookaheadAngles = VectorToAngles( self.lookaheadDir );

	if ( Length2DSquared( self.velocity ) > 9 )
	{
		velAngles = VectorToAngles( self.velocity );
		if ( abs( AngleClamp180( velAngles[1] - lookaheadAngles[1] ) ) < 45 )
			return;
	}
	
	angleDiff = AngleClamp180( lookaheadAngles[1] - self.angles[1] );
	angleIndex = GetAngleIndex( angleDiff );

	startAnims = self GetDogMoveAnim( "run_start" );

	startAnim = startAnims[ angleIndex ];
	startAnimTranslation = GetMoveDelta( startAnim );

	endPos = RotateVector( startAnimTranslation, self.angles ) + self.origin;
	if ( !self MayMoveFromPointToPoint( self.origin, endPos ) )
		return;

	startAnimAngles = GetAngleDelta3D( startAnim );

	self AnimMode( "zonly_physics", false );
	self OrientMode( "face angle", AngleClamp180( lookaheadAngles[1] - startAnimAngles[1] ) );
	
	animLength = GetAnimLength( startAnim );
	turnRate = abs( angleDiff - startAnimAngles[1] ) / animLength / 1000;	// degrees per millisecond
	if ( turnRate < 0.01 )
		turnRate = 0.01;
	self.prevTurnRate = self.turnRate;
	self.turnRate = turnRate;

	self SetFlaggedAnimKnobAllRestart( "dog_start_move", startAnim, %body, 1, 0.2, self.movePlaybackRate );
	self animscripts\shared::DoNotetracks( "dog_start_move" );

	self.turnRate = self.prevTurnRate;
	self.prevTurnRate = undefined;

	self AnimMode( "none", false );
	self OrientMode( "face motion" );
}

StartDrivenMovement()
{
	startAnims = self GetDogMoveAnim( "run_start" );
	startAnim = startAnims[ 4 ];

	self SetFlaggedAnimKnobAllRestart( "dog_start_move", startAnim, %body );
	self animscripts\shared::DoNotetracks( "dog_start_move" );
}

WaitForDrivenChange()
{
	self endon( "dogmove_endwait_drivenchange" );
	self endon( "killanimscript" );

	prevDrivenState = self IsDogBeingDriven();

	while ( true )
	{
		curDrivenState = self IsDogBeingDriven();
		if ( prevDrivenState != curDrivenState )
		{
			self CancelAllBut( "drivenchange" );
			if ( curDrivenState )
				ContinueMovement();
			else
				ContinueDrivenMovement();
			break;
		}
		wait( 0.2 );
	}
}

WaitForRunWalkSlopeChange()
{
	self endon( "dogmove_endwait_runwalkslope" );
	self endon( "killanimscript" );

	curMovement = self.moveMode;
	stairsState = self.stairsState;
	run_override = self.run_overrideAnim;
	walk_override = self.walk_overrideAnim;

	while ( true )
	{
		if ( curMovement != self.moveMode || stairsState != self.stairsState 
			|| self HasOverrideAnimChanged( run_override, walk_override ) )
		{
			self ClearAnim( %dog_move, 0.2 );

			if ( isdefined( self.script_nostairs ) )
				self SetMoveAnim( self.moveMode, "none", true );
			else
				self SetMoveAnim( self.moveMode, self.stairsState, true );

			curMovement = self.moveMode;
			stairsState = self.stairsState;
			run_override = self.run_overrideAnim;
			walk_override = self.walk_overrideAnim;
		}
		wait( 0.1 );
	}
}

WaitForRateChange()
{
	self endon( "dogmove_endwait_ratechange" );
	self endon( "killanimscript" );

	curRate = self.movePlaybackRate;
	curMultiplier = self.moveRateMultiplier;

	while ( true )
	{
		if ( curRate != self.movePlaybackRate || curMultiplier != self.moveRateMultiplier )
		{
			self SetMoveAnim( self.moveMode, self.stairsState, false );
			curRate = self.movePlaybackRate;
			curMultiplier = self.moveRateMultiplier;
		}
		wait( 0.1 );
	}
}

WaitForSharpTurn()
{
	self endon( "dogmove_endwait_sharpturn" );
	self endon( "killanimscript" );

	self waittill( "path_changed", bReacquire, newDir );

	if ( self.moveMode == "walk" || isdefined( self.script_noturnanim ) || self IsDogBeingDriven() )
	{
		self thread WaitForSharpTurn();
		return;
	}

	lookaheadAngles = VectorToAngles( newDir );
	angleDiff = AngleClamp180( lookaheadAngles[1] - self.angles[1] );
	angleIndex = GetAngleIndex( angleDiff );

	if ( angleIndex == 4 )	// 4 means this turn wasn't sharp enough for me to care. (angle ~= 0)
	{
		self thread WaitForSharpTurn();
		return;
	}

	self CancelAllBut( "sharpturn" );

	turnAnims = self GetDogMoveAnim( "sharp_turn" );

	turnAnim = turnAnims[ angleIndex ];
	animAngleDelta = GetAngleDelta( turnAnim );

	self AnimMode( "zonly_physics", false );
	self OrientMode( "face angle", AngleClamp180( lookaheadAngles[1] - animAngleDelta ) );

	self SetFlaggedAnimKnobAllRestart( "dog_sharp_turn", turnAnim, %body, 1, 0.2, self.movePlaybackRate );
	self animscripts\shared::DoNotetracks( "dog_sharp_turn" );

	self ClearAnim( %dog_move_turn, 0.2 );

	self ContinueMovement();
}

WaitForStop()
{
	self endon( "dogmove_endwait_stop" );
	self endon( "killanimscript" );

	self waittill( "stop_soon" );

	if ( isdefined( self.disablearrivals ) && self.disablearrivals )
		return;

	if ( self IsDogBeingDriven() )
		return;
	
	if ( IsDefined( self.node ) && self.node.type != "Path" )
	{
		angleDiff = AngleClamp180( self.node.angles[1] - self.angles[1] );
		angleIndex = GetAngleIndex( angleDiff );
	}
	else
	{
		angleIndex = 4;
	}

	stopAnims = GetDogMoveAnim( "run_stop" );

	if ( self animscripts\dog\dog_stop::ShouldAttackIdle() )
		moveType = "attack";
	else
		moveType = "casual";

	assert( IsDefined( stopAnims[moveType] ) );

	stopAnim = stopAnims[moveType][ angleIndex ];
	if ( !IsDefined( stopAnim ) )
	{
		self thread WaitForStop();
		return;
	}

	stopDelta = GetMoveDelta( stopAnim );
	stopAngleDelta = GetAngleDelta( stopAnim );

	goalPos = self.pathGoalPos;
	if ( !IsDefined( goalPos ) )
	{	// this can happen if i get pained. (in which case, this thread should really get canceled, shouldn't it?)
		self thread WaitForStop();
		return;
	}

	//assert( IsDefined( goalPos ) );

	meToStop = goalPos - self.origin;
	// not enough room left to play the animation.  abort.
	if ( Length( meToStop ) < Length( stopDelta ) )
	{
		self thread WaitForStop();
		return;
	}

	stopData = self GetStopData();
	stopStartPos = self CalcAnimStartPos( stopData.pos, stopData.angles[1], stopDelta, stopAngleDelta );
	stopStartPosDropped = DropPosToGround( stopStartPos );

	if ( !IsDefined( stopStartPosDropped ) )
	{
		self thread WaitForStop();
		return;
	}

	if ( !self MayMoveFromPointToPoint( stopData.pos, stopStartPosDropped ) )
	{
		self thread WaitForStop();
		return;
	}

	self CancelAllBut( "stop" );

	if ( DistanceSquared( stopStartPos, self.origin ) > 4 )
	{
		self thread WaitForPathSetWhileStopping();
		self SetRunToPos( stopStartPos );
		self waittill( "runto_arrived" );
		self notify( "dogmove_endwait_pathsetwhilestopping" );
	}

	self StopMoveSound();

	if ( IsDefined( self.node ) && self.node.type != "Path" )
	{
		facingAngles = self.node.angles;
	}
	else
	{
		facingDir = goalPos - self.origin;
		facingAngles = VectorToAngles( facingDir );
	}

	if ( angleIndex == 0 || angleIndex == 1 || angleIndex == 7 || angleIndex == 8 )
		facingYaw = ( 0, stopData.angles[1] - stopAngleDelta, 0 );
	else
		facingYaw = ( 0, facingAngles[1] - stopAngleDelta, 0 );

	self.dogArrivalAnim = stopAnim;

	self StartCoverArrival( stopStartPos, facingYaw[1], 0 );
}

WaitForPathSetWhileStopping()
{
	self endon( "killanimscript" );
	self endon( "dogmove_endwait_pathsetwhilestopping" );

	oldGoalPos = self.goalPos;

	self waittill( "path_set" );

	newGoalPos = self.goalPos;

	if ( Distance2DSquared( oldGoalPos, newGoalPos ) < 1 )
	{
		self thread WaitForPathSetWhileStopping();
		return;
	}

	//self notify( "dogmove_endwait_stop" );
	self CancelAllBut( "pathsetwhilestopping" );

	self ContinueMovement();
}

WaitForBark()
{
	self endon( "killanimscript" );
	self endon( "dogmove_endwait_bark" );

	updateRate = 0.3;

	waittime = updateRate;

	while ( true )
	{
		if ( IsDefined( self.script_nobark ) && self.script_nobark )
		{
			waittime = updateRate;
		}
		else if ( IsDefined( self.enemy ) )
		{
			self PlaySound( "anml_dog_bark" );
			waittime = 2 + randomInt( 1 );
		}
		else
		{
			waittime = updateRate;
		}

		wait( waittime );
	}
}

WaitForFollowSpeed()
{
	self endon( "killanimscript" );
	self endon( "dogmove_endwait_followspeed" );

	radius = 128;				// 
	minRate = 0.6;
	negThreshholdDist = -30;	// generally, people will never be more than 30 together.
	posThreshholdDist = 30;
	//influenceDist = 60;

	while ( true )
	{
		self.moveRateMultiplier = 1;

		if ( self IsDogFollowingHandler() && self.moveMode == "run" )
		{
			assert( IsDefined( self.dogHandler ) );

			if ( IsDefined( self.dogHandler.pathGoalPos ) )		// handler has path
			{
				handlerToMe = self.origin - self.dogHandler.origin;
				distToHandlerSq = LengthSquared( handlerToMe );

				// if i'm in front of my handler, slow down so he can catch up.
				// if i'm behind my handler, then slow down so i don't bump into him.
				// do it on a funny sliding scale to try to avoid sudden changes in speed.
				if ( distToHandlerSq < radius * radius )	// only do this if i'm reasonably close to the handler.
				{
					distInFrontOfHandler = VectorDot( self.dogHandler.lookaheadDir, handlerToMe );

					if ( distInFrontOfHandler > posThreshholdDist )
						self.moveRateMultiplier = Lerp( minRate, 1, LerpFraction( posThreshholdDist, radius, distInFrontOfHandler ) );
					else if ( distInFrontOfHandler > negThreshholdDist )
						self.moveRateMultiplier = minRate;
					else											// in okay-ish range.  start slowing.
						self.moveRateMultiplier = Lerp( minRate, 1, LerpFraction( negThreshholdDist, -1*radius, distInFrontOfHandler ) );
				}
			}
		}
		wait( 0.1 );
	}
}

Lerp( x, y, frac )
{
	return x + ( y - x ) * frac;
}

// what frac is n between x and y
LerpFraction( x, y, n )
{
	return (n - x) / (y - x);
}

CancelAllBut( doNotCancel1, doNotCancel2 )
{
	cleanups = [ "runwalkslope", "ratechange", "bark", "sharpturn", "stop", "pathsetwhilestopping", "followspeed", "drivenchange", "drivenanim" ];

	bCheckDoNotCancel1 = IsDefined( doNotCancel1 );
	bCheckDoNotCancel2 = IsDefined( doNotCancel2 );

	foreach ( cleanup in cleanups )
	{
		if ( bCheckDoNotCancel1 && cleanup == doNotCancel1 )
			continue;
		if ( bCheckDoNotCancel2 && cleanup == doNotCancel2 )
			continue;

		self notify( "dogmove_endwait_" + cleanup );
	}
}

GetStopData()
{
	stopData = SpawnStruct();

	if ( IsDefined( self.node ) && self.node.type != "Path" )
	{
		stopData.pos = self.node.origin;
		stopData.angles = self.node.angles;
	}
	else
	{
		assert( IsDefined( self.pathGoalPos ) );
		stopData.pos = self.pathGoalPos;
		if ( LengthSquared( self.velocity ) > 1 )
			stopData.angles = self.angles;
		else
			stopData.angles = VectorToAngles( self.lookaheadDir );
	}

	return stopData;
}

PlayMoveAnim( moveAnim, bShouldRestart, blendTime, playbackRate )
{
	if ( bShouldRestart )
		self SetFlaggedAnimKnobAllRestart( "dog_move", moveAnim, %dog_move, 1, blendTime, playbackRate );
	else
		self SetFlaggedAnimKnobAll( "dog_move", moveAnim, %dog_move, 1, blendTime, playbackRate );
}

PlayMoveAnimKnob( moveAnim, bShouldRestart, blendTime, playbackRate )
{
	if ( bShouldRestart )
		self SetFlaggedAnimKnobAllRestart( "dog_move", moveAnim, %dog_move, 1, blendTime, playbackRate );
	else
		self SetFlaggedAnimKnobAll( "dog_move", moveAnim, %dog_move, 1, blendTime, playbackRate );
}

SetMoveAnim( moveMode, stairsState, bRestart )
{
	// restart by default.
	bShouldRestart = !IsDefined( bRestart ) || bRestart;
	moveSoundAlias = undefined;

	if ( moveMode == "walk" )
	{
		self SetAnimKnob( %dog_walk, 1 );
		
		if ( isdefined( self.walk_overrideanim ) )
			moveAnim = self.walk_overrideanim;
		else
			moveAnim = self GetDogMoveAnim( "walk" );

		PlayMoveAnim( moveAnim, bShouldRestart, 0.2, self.movePlaybackRate * self.moveRateMultiplier );

		self.moveAnimType = "walk";
	}
	else if ( moveMode == "run" )
	{
		if ( stairsState == "up" )
		{
			self SetAnimKnob( %dog_slope, 1 );
			moveAnim = self GetDogMoveAnim( "run_up" );

			PlayMoveAnimKnob( moveAnim, bShouldRestart, 0.5, self.movePlaybackRate * self.moveRateMultiplier );

			self.moveAnimType = "run";
		}
		else if ( stairsState == "down" )
		{
			self SetAnimKnob( %dog_slope, 1 );
			moveAnim = self GetDogMoveAnim( "run_down" );

			PlayMoveAnimKnob( moveAnim, bShouldRestart, 0.5, self.movePlaybackRate * self.moveRateMultiplier );

			self.moveAnimType = "run";
		}
		else if ( IsDefined( self.sprint ) && self.sprint )
		{
			self SetAnimKnob( %dog_run, 1 );
			moveAnim = self GetDogMoveAnim( "sprint" );

			PlayMoveAnim( moveAnim, bShouldRestart, 0.2, self.movePlaybackRate * self.moveRateMultiplier );

			self.moveAnimType = "sprint";
		}
		else
		{
			self SetAnimKnob( %dog_run, 1 );
					
			if ( IsDefined( self.run_overrideanim ) )
			{
				moveAnim = self.run_overrideanim;
				if ( IsDefined( self.run_overridesound ) )
					moveSoundAlias = self.run_overrideSound;
			}
			else
			{
				moveAnim = self GetDogMoveAnim( "run" );
			}

			PlayMoveAnim( moveAnim, bShouldRestart, 0.2, self.movePlaybackRate * self.moveRateMultiplier );

			self.moveAnimType = "run";
		}
	}
	else
	{
		assertmsg( "unknown movemode " + moveMode );
	}

	PlayMoveSound( moveSoundAlias );
}

PlayMoveSound( overrideSound )
{
	bSelfOverrideDefined = IsDefined( self.moveOverrideSound );
	bOverrideDefined = IsDefined( overrideSound );
	if ( !bSelfOverrideDefined && !bOverrideDefined )
		return;
	else if ( bSelfOverrideDefined && bOverrideDefined && self.moveOverrideSound == overrideSound )
		return;

	self StopMoveSound();

	if ( bOverrideDefined )
		self thread LoopMoveSound( overrideSound );
}

LoopMoveSound( soundAlias )
{
	self endon( "killanimscript" );

	soundOrigin = Spawn( "script_origin", self.origin );
	soundOrigin.angles = self.angles;
	soundOrigin LinkTo( self );

	self.moveSoundOrigin = soundOrigin;

	self.moveOverrideSound = soundAlias;

	while ( true )
	{
		soundOrigin PlaySound( soundAlias, "dog_move_sound" );

		bDone = self MoveSound_WaitForDoneOrDeath( soundOrigin, "dog_move_sound" );
		if ( !IsDefined( bDone ) )
			break;
	}
}

MoveSound_WaitForDoneOrDeath( soundOrigin, doneNotify )
{
	self endon( "death" );
	soundOrigin endon( "death" );
	soundOrigin waittill( doneNotify );
	return true;
}

StopMoveSound()
{
	if ( IsDefined( self.moveSoundOrigin ) )
	{
		if ( self.moveSoundOrigin IsWaitingOnSound() )
		{
			self.moveSoundOrigin StopSounds();
			wait( 0.05 );
		}
		if ( IsDefined( self.moveSoundOrigin ) )
			self.moveSoundOrigin Delete();
		self.moveSoundOrigin = undefined;
		self.moveOverrideSound = undefined;
	}
}

GetDesiredDrivenMoveMode( prevDrivenMoveMode )
{
	cWalkToRun = 150 * 150;
	cRunToWalk = 100 * 100;

	velMagSq = Length2DSquared( self.velocity );

	if ( prevDrivenMoveMode == "walk" )
	{
		if ( velMagSq > cWalkToRun )
			return "run";
	}
	else if ( prevDrivenMoveMode == "run" )
	{
		if ( velMagSq < cRunToWalk )
			return "walk";
	}
	return prevDrivenMoveMode;
}

SetDrivenAnim( moveMode, bRestart )
{
	cTransitionBlendTime = 0.5;

	self ClearAnim( %dog_move, cTransitionBlendTime );

	if ( moveMode == "walk" )
	{
		self PlayMoveAnimKnob( self GetDogMoveAnim( "sneak" ), bRestart, cTransitionBlendTime, 1 );
	}
	else if ( moveMode == "run" )
	{
		self PlayMoveAnimKnob( self GetDogMoveAnim( "run" ), bRestart, cTransitionBlendTime, 1 );
	}
}

DrivenAnimUpdate()
{
	self endon( "dogmove_endwait_drivenanim" );
	self endon( "killanimscript" );

	while ( true )
	{
		curMoveMode = self GetDesiredDrivenMoveMode( self.drivenMoveMode );
		if ( curMoveMode != self.drivenMoveMode )
		{
			SetDrivenAnim( curMoveMode, true );
			self.drivenMoveMode = curMoveMode;
		}

		wait ( 0.1 );
	}
}

CalcAnimStartPos( stopPos, stopAngle, animDelta, animAngleDelta )
{
	dAngle = stopAngle - animAngleDelta;
	angles = ( 0, dAngle, 0 );

	worldDelta = RotateVector( animDelta, angles );
	return stopPos - worldDelta;
}

Dog_AddLean()
{
	leanFrac = Clamp( self.leanAmount / 25.0, -1, 1 );
	if ( leanFrac > 0 )
	{
		// set lean left( leanFrac );
		// set lean right( 0 );
	}
	else
	{
		// set lean left( 0 );
		// set lean right( 0 - leanFrac );
	}
}

// -180, -135, -90, -45, 0, 45, 90, 135, 180
// favor underturning, unless you're within <threshold> degrees of the next one up.
GetAngleIndex( angle, threshold )
{
	if ( !IsDefined( threshold ) )
		threshold = 10;

	if ( angle < 0 )
		return int( ceil( ( 180 + angle - threshold ) / 45 ) );
	else
		return int( floor( ( 180 + angle + threshold ) / 45 ) );
}

DropPosToGround( position )
{
	startPos = position + (0, 0, 64);
	endPos = position + (0, 0, -64);

	radius = 15;
	height = 45;

	droppedPos = self AIPhysicsTrace( startPos, endPos, radius, height, true );

	if ( abs( droppedPos[2] - startPos[2] ) < 0.5 )
		return undefined;

	if ( abs( droppedPos[2] - endPos[2] ) < 0.5 )
		return undefined;

	return droppedPos;
}

HasOverrideAnimChanged( prevRunOverride, prevWalkOverride )
{
	bPrevRunDefined = IsDefined( prevRunOverride );
	bPrevWalkDefined = IsDefined( prevWalkOverride );
	bCurRunDefined = IsDefined( self.run_overrideAnim );
	bCurWalkDefined = IsDefined( self.walk_overrideAnim );

	if ( bPrevRunDefined != bCurRunDefined )
		return true;
	else if ( bPrevRunDefined && bCurRunDefined && prevRunOverride != self.run_overrideAnim )
		return true;

	if ( bPrevWalkDefined != bCurWalkDefined )
		return true;
	else if ( bPrevWalkDefined && bCurWalkDefined && prevWalkOverride != self.walk_overrideAnim )
		return true;

	return false;
}

GetDogMoveAnim( moveSet )
{
	assertEx( animscripts\animset::ArchetypeExists( "dog" ), "dog archetype uninitialized" );

	moveAnim = LookupDogAnim( "move", moveSet );

	assertEx( IsDefined( moveAnim ), moveSet + " is not a valid move set for dogs." );

	return moveAnim;
}


HandleFootstepNotetracks()
{
	self endon( "killanimscript" );
	
	while ( true )
	{
		self waittill( "dog_move", note );

		self HandleNotetrack( note, "dog_move" );
	}
}


InitDogArchetype_Move()
{
	dogAnims = [];

	dogAnims[ "walk" ] = %iw6_dog_walk;
	dogAnims[ "run" ] = %iw6_dog_run;
	dogAnims[ "run_up" ] = %iw6_dog_ramp_up_run;
	dogAnims[ "run_down" ] = %iw6_dog_ramp_down_run;
	dogAnims[ "sprint" ] = %iw6_dog_run;
	dogAnims[ "sneak" ] = %iw6_dog_sneak_walk_forward;

	dogAnims[ "run_start" ] = [];
	dogAnims[ "run_start" ][ 0 ] = %iw6_dog_attackidle_runout_2;		// -180
	dogAnims[ "run_start" ][ 1 ] = %iw6_dog_attackidle_runout_3;		// -135
	dogAnims[ "run_start" ][ 2 ] = %iw6_dog_attackidle_runout_6;		// -90
	dogAnims[ "run_start" ][ 3 ] = %iw6_dog_attackidle_runout_9;		// -45
	dogAnims[ "run_start" ][ 4 ] = %iw6_dog_attackidle_runout_8;		// 0
	dogAnims[ "run_start" ][ 5 ] = %iw6_dog_attackidle_runout_7;		// 45
	dogAnims[ "run_start" ][ 6 ] = %iw6_dog_attackidle_runout_4;		// 90
	dogAnims[ "run_start" ][ 7 ] = %iw6_dog_attackidle_runout_1;		// 135
	dogAnims[ "run_start" ][ 8 ] = %iw6_dog_attackidle_runout_2;		// 180

	dogAnims[ "run_stop" ] = [];
	dogAnims[ "run_stop" ][ "attack" ] = [];
	dogAnims[ "run_stop" ][ "attack" ][ 0 ] = %iw6_dog_attackidle_runin_2;
	dogAnims[ "run_stop" ][ "attack" ][ 1 ] = %iw6_dog_attackidle_runin_1;
	dogAnims[ "run_stop" ][ "attack" ][ 2 ] = %iw6_dog_attackidle_runin_4;
	dogAnims[ "run_stop" ][ "attack" ][ 3 ] = %iw6_dog_attackidle_runin_7;
	dogAnims[ "run_stop" ][ "attack" ][ 4 ] = %iw6_dog_attackidle_runin_8;
	dogAnims[ "run_stop" ][ "attack" ][ 5 ] = %iw6_dog_attackidle_runin_9;
	dogAnims[ "run_stop" ][ "attack" ][ 6 ] = %iw6_dog_attackidle_runin_6;
	dogAnims[ "run_stop" ][ "attack" ][ 7 ] = %iw6_dog_attackidle_runin_3;
	dogAnims[ "run_stop" ][ "attack" ][ 8 ] = %iw6_dog_attackidle_runin_2;

	dogAnims[ "run_stop" ][ "casual" ] = [];
	dogAnims[ "run_stop" ][ "casual" ][ 0 ] = %iw6_dog_casualidle_runin_2;
	dogAnims[ "run_stop" ][ "casual" ][ 1 ] = %iw6_dog_casualidle_runin_1;
	dogAnims[ "run_stop" ][ "casual" ][ 2 ] = %iw6_dog_casualidle_runin_4;
	dogAnims[ "run_stop" ][ "casual" ][ 3 ] = %iw6_dog_casualidle_runin_7;
	dogAnims[ "run_stop" ][ "casual" ][ 4 ] = %iw6_dog_casualidle_runin_8;
	dogAnims[ "run_stop" ][ "casual" ][ 5 ] = %iw6_dog_casualidle_runin_9;
	dogAnims[ "run_stop" ][ "casual" ][ 6 ] = %iw6_dog_casualidle_runin_6;
	dogAnims[ "run_stop" ][ "casual" ][ 7 ] = %iw6_dog_casualidle_runin_3;
	dogAnims[ "run_stop" ][ "casual" ][ 8 ] = %iw6_dog_casualidle_runin_2;

	dogAnims[ "sharp_turn" ] = [];
	dogAnims[ "sharp_turn" ][ 0 ] = %iw6_dog_run_turn_2;				// -180
	dogAnims[ "sharp_turn" ][ 1 ] = %iw6_dog_run_turn_3;				// -135
	dogAnims[ "sharp_turn" ][ 2 ] = %iw6_dog_run_turn_6;				// -90
	dogAnims[ "sharp_turn" ][ 3 ] = %iw6_dog_run_turn_9;				// -45
	//dogAnims[ "sharp_turn" ][ 4 ] = %german_shepherd_run_start;				// 0	// unused!
	dogAnims[ "sharp_turn" ][ 5 ] = %iw6_dog_run_turn_7;				// 45
	dogAnims[ "sharp_turn" ][ 6 ] = %iw6_dog_run_turn_4;				// 90
	dogAnims[ "sharp_turn" ][ 7 ] = %iw6_dog_run_turn_1;				// 135
	dogAnims[ "sharp_turn" ][ 8 ] = %iw6_dog_run_turn_2;				// 180

	anim.archetypes[ "dog" ][ "move" ] = dogAnims;
}
