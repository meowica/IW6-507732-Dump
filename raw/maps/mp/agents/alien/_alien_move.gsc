#include common_scripts\utility;
#include maps\mp\agents\_scriptedAgents;

ALLOW_SLIDE_DIST_SQR = 20.0 * 20.0;
DODGE_CHANCE_ENEMY_FACING_TOLERANCE = 0.966; // cos 15, how closely our enemy has to be looking at us
DODGE_CHANCE_ALIEN_FACING_TOLERANCE = 0.766; // cos 40, how closely we have to be facing our enemy
DODGE_CHANCE_LOOK_AT_TIME = 1500.0; // Time our enemy has to look at us before dodging
DODGE_CHANCE_MAX_DISTANCE_SQ = 4000000.0; // 2000.0 * 2000.0
MIN_DODGE_DIST_SQUARED = 65536.0; // 256 * 256

main()
{
	self endon( "killanimscript" );

	self.bLockGoalPos = false;
	self.playing_pain_animation = false;

	self ScrAgentSetPhysicsMode( "gravity" );
	
	self StartMove();
	self ContinueMovement();
}

StartMove()
{	
	if ( canDoStartMove())
	{
		switch( getStartMoveType() )
		{
			case "run-start":
				self doRunStart();
				break;
			case "walk-start":
				self doWalkStart();
				break;
			case "leap-to-run":
				self doLeapToRunStart();
				break;
			default:
				break;
		}
	}
}

end_script()
{
	self.bLockGoalPos = false;
	self.playing_pain_animation = false;
	self CancelAllBut( undefined );
	self ScrAgentSetAnimScale( 1, 1 );
	self.previousAnimState = "move";
}

SetupMovement()
{
	self.enableStop = true;
	self thread WaitForMovemodeChange();
	self thread WaitForJumpSoon();
	self thread WaitForSharpTurn();
	self thread WaitForStop();
	self thread WaitForNearMiss();
	self thread WaitForDodgeChance();	
}

ContinueMovement()
{
	self SetupMovement();

	self ScrAgentSetAnimMode( "code_move" );
	self ScrAgentSetOrientMode( "face motion" );
	self SetMoveAnim( self.moveMode );
}

WaitForMovemodeChange()
{
	self endon( "killanimscript" );
	self endon( "alienmove_endwait_runwalk" );
	curMovement = self.moveMode;
	while ( true )
	{
		if ( curMovement != self.moveMode )
		{
			self SetMoveAnim( self.moveMode );
			curMovement = self.moveMode;
		}
		wait( 0.1 );
	}
}

WaitForSharpTurn()
{
	self endon( "alienmove_endwait_sharpturn" );

	self waittill( "path_dir_change", newDir );
	
	angleIndex = GetAngleIndexFromSelfYaw( newDir );

	if ( angleIndex == 4 )	// 4 means this turn wasn't sharp enough for me to care. (angle ~= 0)
	{
		self thread WaitForSharpTurn();
		return;
	}

	//Try run-turn
	animState = "run_turn";
	turnAnim = self GetAnimEntry( animState, angleIndex );	
	canDoTurn = CanDoTurnAnim( turnAnim );

	if ( !canDoTurn )
	{
		// If run-turn animation fails, use the quick-turn animation
		//animState = "quick_turn";
		//turnAnim = self GetAnimEntry( animState, angleIndex );
		//canDoTurn = CanDoTurnAnim( turnAnim );
	}
	
	if ( !canDoTurn )
	{
		self thread WaitForSharpTurn();
		return;
	}

	self CancelAllBut( "sharpturn" );

	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	
	self.bLockGoalPos = true;
	self.enableStop = false;

	self PlayAnimNAtRateUntilNotetrack( animState, angleIndex, self.moveplaybackrate, animState, "code_move" );
	self ScrAgentSetOrientMode( "face motion" );
	self.bLockGoalPos = false;

	self ContinueMovement();
}

WaitForStop()
{
	self endon( "alienmove_endwait_stop" );

	self waittill( "stop_soon" );
	
	if ( !self shouldDoStopAnim() || self.movemode == "walk" )
	{
		self thread WaitForStop();
		return;
	}

	goalPos = self GetPathGoalPos();
	//assert( IsDefined( goalPos ) );

	if ( !isDefined( goalPos ) )
	{
		self thread WaitForStop();
		return;
	}
	
	meToStop = goalPos - self.origin;
	finalFaceDir = getStopEndFaceDir( goalPos );
	
	animState = getStopAnimState();
	animIndex = getStopAnimIndex( animState, finalFaceDir );
	
	stopAnim = self GetAnimEntry( animState, animIndex );
	stopDelta = GetMoveDelta( stopAnim );
	stopAngleDelta = GetAngleDelta( stopAnim );
	
	// not enough room left to play the animation.  abort. (i'm willing to squish/scale the anim up to 48 units.)	
	if ( Length( meToStop ) + 48 < Length( stopDelta ) )
	{
		self thread WaitForStop();
		return;
	}

	stopData = self GetStopData( goalPos );
	stopStartPos = self CalcAnimStartPos( stopData.pos, stopData.angles[1], stopDelta, stopAngleDelta );
	stopStartPosDropped = self DropPosToGround( stopStartPos );

	if ( !IsDefined( stopStartPosDropped ) )
	{
		self thread WaitForStop();
		return;
	}

	if ( !self CanMovePointToPoint( stopData.pos, stopStartPosDropped ) )
	{
		self thread WaitForStop();
		return;
	}

	self CancelAllBut( "stop", "sharpturn" );

	self thread WaitForPathSet( "alienmove_endwait_pathsetwhilestopping", "alienmove_endwait_stop" );

	// scale the anim if necessary, to make sure we end up where we wanted to end up.
	scaleFactors = GetAnimScaleFactors( goalPos - self.origin, stopDelta );

	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", VectorToAngles( meToStop ) );
	self ScrAgentSetAnimScale( scaleFactors.xy, scaleFactors.z );
	self PlayAnimNUntilNotetrack( animState, animIndex, animState, "end" );
	self ScrAgentSetAnimScale( 1.0, 1.0 );
	
	// Make sure we made it
	goalPos = self GetPathGoalPos();
	if ( DistanceSquared( self.origin, goalPos ) < ALLOW_SLIDE_DIST_SQR )
	{
		// Success
		self ScrAgentSetAnimMode( "code_move_slide" );
		self SetAnimState( "idle" );	// if all went well, idle state should kick in without this.  if all didn't... cover it up.		
		return;
	}
	else
	{
		// Failure - return to move
		StartMove();
		ContinueMovement();
	}
}

getStopEndFaceDir( goalPos )
{
	if ( isDefined ( self.enemy ) )
		return ( self.enemy.origin - goalPos );

	return ( goalPos - self.origin );
}

getStopAnimState()
{
	switch( self.movemode )
	{
	case "run":
	case "jog":
		return "run_stop";
	case "walk":
		return "walk_stop";
	default:
		AssertMsg( "Trying to get stop animState for unknown movemode: " + self.movemode );
	}
}

getStopAnimIndex( animState, meToStop )
{
	switch( animState )
	{
	case "walk_stop":
		return 0;
	case "run_stop":
		return GetAngleIndexFromSelfYaw( meToStop );
	}
}

WaitForPathSet( endOnNotify, killParentNotify )
{
	self endon( "killanimscript" );
	self endon( endOnNotify );

	oldGoalPos = self ScrAgentGetGoalPos();

	self waittill( "path_set" );

	newGoalPos = self ScrAgentGetGoalPos();

	if ( DistanceSquared( oldGoalPos, newGoalPos ) < 1 )
	{
		self thread WaitForPathSet( endOnNotify, killParentNotify );
		return;
	}

	self notify( killParentNotify );

	self ContinueMovement();
}

WaitForJumpSoon()
{
	self endon( "killanimscript" );
	self endon( "alienmove_endwait_jumpsoon" );

	self waittill( "traverse_soon" );
	self CancelAllBut( "jumpsoon" );

	startNode = self GetNegotiationStartNode();
	endNode = self GetNegotiationEndNode();

	// Check if alien should do the run-to-leap animations
	targetVector = endNode.origin - startNode.origin;
	angleIndex = GetAngleIndexFromSelfYaw( endNode.origin - startNode.origin );
	if ( !shouldDoLeapArrivalAnim( startNode, angleIndex ) )
	{
		self thread WaitForJumpSoon();
		return;
	}
	
	// Check if alien can move from anim start position to the start node
	arrivalAnimState = "jump_launch_arrival";
	arrivalAnim = self GetAnimEntry( arrivalAnimState, angleIndex );
	moveDelta = GetMoveDelta( arrivalAnim );
	angleYawDelta = GetAngleDelta( arrivalAnim );
	if ( !self CanMovePointToPoint( self.origin, startNode.origin ) )
	{
		self thread WaitForJumpSoon();
		return;
	}

	self thread WaitForPathSet( "alienmove_endwait_pathsetwhilejumping", "alienmove_endwait_jumpsoon" );
	
	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	
	scaleFactors = GetAnimScaleFactors( startNode.origin - self.origin, moveDelta );
	self ScrAgentSetAnimScale( scaleFactors.xy, scaleFactors.z );
	self PlayAnimNAtRateUntilNotetrack( arrivalAnimState, angleIndex, self.moveplaybackrate, "jump_launch_arrival", "anim_will_finish" );
	self ScrAgentSetOrientMode( "face angle abs", vectorToAngles( targetVector ) );
	self ScrAgentSetAnimScale( 1.0, 1.0 );
	
	startNode = self GetNegotiationStartNode();
	if ( isDefined( startNode ) && distanceSquared( self.origin, startNode.origin ) < ALLOW_SLIDE_DIST_SQR )
		self ScrAgentSetAnimMode( "code_move_slide" );  // hope that we enter the traverse state at some point...
	else
		self ContinueMovement();
}

SetMoveAnim( moveMode )
{
	if ( moveMode == "run" )
	{
		nEntries = self GetAnimEntryCount( "run" );
		animWeights = [ /*01*/ 20, /*03*/ 80 ];
		assert( animWeights.size == nEntries );
		randIndex = GetRandomIndex( animWeights );
		assert( randIndex < nEntries );
		self SetAnimState( "run", randIndex, self.moveplaybackrate );
	}
	else if ( moveMode == "jog" )
	{
		self SetAnimState( "jog", undefined, self.moveplaybackrate );
	}
	else if ( moveMode == "walk" )
	{
		self SetAnimState( "walk", undefined, self.moveplaybackrate );
	}
	else
	{
		assertmsg( "unimplemented move mode " + moveMode );
	}
}

GetRandomIndex( weights )
{
	weightSum = 0;
	foreach ( weight in weights )
		weightSum += weight;
	randIndex = RandomIntRange( 0, weightSum );
	weightSum = 0;
	for ( i = 0; i < weights.size; i++ )
	{
		weightSum += weights[i];
		if ( randIndex <= weightSum )
			return i;
	}
	assertmsg( "should not get here." );
	return 0;
}

CancelAllBut( doNotCancel, doNotCancel2 )
{
	cleanups = [ "runwalk", "sharpturn", "stop", "pathsetwhilestopping", "jumpsoon", "pathsetwhilejumping", "pathset", "nearmiss", "dodgechance" ];

	bCheckDoNotCancel = IsDefined( doNotCancel );
	bCheckDoNotCancel2 = IsDefined( doNotCancel2 );

	foreach ( cleanup in cleanups )
	{
		if ( bCheckDoNotCancel && cleanup == doNotCancel )
			continue;
		if ( bCheckDoNotCancel2 && cleanup == doNotCancel2 )
			continue;
		self notify( "alienmove_endwait_" + cleanup );
	}
}

GetStopData( goalPos )
{
	stopData = SpawnStruct();

	if ( IsDefined( self.node ) )
	{
		stopData.pos = self.node.origin;
		stopData.angles = self.node.angles;
	}
	else if ( isDefined( self.enemy ) )
	{
		stopData.pos = goalPos;
		stopData.angles = vectorToAngles( self.enemy.origin - goalPos );
	}
	else
	{
		stopData.pos = goalPos;
		stopData.angles = self.angles;
	}

	return stopData;
}

CalcAnimStartPos( stopPos, stopAngle, animDelta, animAngleDelta )
{
	dAngle = stopAngle - animAngleDelta;
	angles = ( 0, dAngle, 0 );
	vForward = AnglesToForward( angles );
	vRight = AnglesToRight( angles );

	forward = vForward * animDelta[0];
	right = vRight * animDelta[1];

	return stopPos - forward + right;
}


onFlashbanged()
{
	self DoStumble();
}

onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( maps\mp\alien\_utility::is_pain_available() )
		self DoStumble( vDir, sHitLoc, iDamage );
}

DoStumble( damageDirection, hitLocation, iDamage )
{
	self endon( "killanimscript" );

	if ( self.playing_pain_animation )
		return;

	self CancelAllBut( undefined );
	self.stateLocked = true;
	self.playing_pain_animation = true;

	animState = self maps\mp\agents\alien\_alien_anim_utils::getPainAnimState( "run_stumble", iDamage );
	animIndex = maps\mp\agents\alien\_alien_anim_utils::getPainAnimIndex( "run", damageDirection, hitLocation );

	anime = self GetAnimEntry( animState, animIndex );
	self maps\mp\alien\_utility::always_play_pain_sound( anime );
	self maps\mp\alien\_utility::register_pain( anime );
	
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	self ScrAgentSetAnimMode( "anim deltas" );
	self PlayAnimNAtRateUntilNotetrack( animState, animIndex, self.movePlaybackRate, "run_stumble", "code_move" );

	self.playing_pain_animation = false;
	self.stateLocked = false;
	
	if ( shouldStartMove() )
		self StartMove();
	
	self ContinueMovement();
}

WaitForNearMiss( enemy )
{
	self endon( "killanimscript" );
	self endon( "alienmove_endwait_nearmiss" );	

	while ( true )
	{
		self waittill_any( "bulletwhizby", "damage" );
		if ( !self.playing_pain_animation )
		{
			DoDodge();
		}
	}
}

WaitForDodgeChance()
{
	self endon( "killanimscript" );
	self endon( "alienmove_endwait_dodgechance" );
	
	currentLookAtDuration = 0.0;
	lastTimeStamp = GetTime();
	
	while ( true )
	{
		wait 0.1;
		
		if ( IsAlive( self.enemy ) )
		{
			if ( DistanceSquared( self.origin, self.enemy.origin ) > DODGE_CHANCE_MAX_DISTANCE_SQ )
			{
				currentLookAtDuration = 0.0;
				continue;				
			}
			
			currentTime = GetTime();
			enemyToMe = VectorNormalize( self.origin - self.enemy.origin );
			enemyFacing = AnglesToForward( self.enemy.angles );
	
			// Fail if enemy isn't looking at us
			if ( VectorDot( enemytoMe, enemyFacing ) < DODGE_CHANCE_ENEMY_FACING_TOLERANCE )
			{
				currentLookAtDuration = 0.0;
				continue;
			}
			
			currentLookAtDuration += currentTime - lastTimeStamp;
			
			// Fail if we're not navigating towards the enemy
			meToEnemy = enemyToMe * -1.0;
			myFacing = AnglesToForward( self.angles );
			if ( VectorDot( meToEnemy, myFacing ) < DODGE_CHANCE_ALIEN_FACING_TOLERANCE )
			{
				continue;
			}
			
			if ( currentLookAtDuration >= DODGE_CHANCE_LOOK_AT_TIME && !self.playing_pain_animation )
			{
				DoDodge( "dodgechance" );
				currentLookAtDuration = 0.0;
			}
			
			lastTimeStamp = currentTime;
		}
	}
}

DoDodge( endwait )
{
	self endon( "killanimscript" );
	DODGE_FREQUENCY = 1000; // 1 second
	DODGE_CHANCE = 0.5;
	
	if( IsDefined( self.last_dodge_time ) && GetTime() - self.last_dodge_time < DODGE_FREQUENCY )
		return;

	if( RandomFloat( 1.0 ) < DODGE_CHANCE )
		return;
	
	if ( IsAlive( self.enemy ) && DistanceSquared( self.origin, self.enemy.origin ) < MIN_DODGE_DIST_SQUARED )
		return;
	
	if ( cointoss() )
	{
		if ( !TryDodge( "dodge_left", endwait ) )
			TryDodge( "dodge_right", endwait );
	}
	else
	{
		if ( !TryDodge( "dodge_right", endwait ) )
			TryDodge( "dodge_left", endwait );
	}	
}

TryDodge( dodgeState, endwait )
{
	MIN_DODGE_SCALE = 0.5;
	
	dodgeEntry = self GetRandomAnimEntry( dodgeState );
	dodgeAnim = self GetAnimEntry( dodgeState, dodgeEntry );
	moveScale = GetSafeAnimMoveDeltaPercentage( dodgeAnim );
	
	if ( moveScale < MIN_DODGE_SCALE )
		return false;

	self.last_dodge_time = GetTime();

	self CancelAllBut( endwait );	
	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	self ScrAgentSetAnimScale( moveScale, 1.0 );
	self PlayAnimUntilNotetrack( dodgeState, "dodge", "end" );
	self ScrAgentSetAnimScale( 1, 1 );
	self ContinueMovement();

	return true;
}

doWalkStart()
{
	animState = "walk_start";
	animIndex = GetRandomAnimEntry( animState );
	
	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	
	self.bLockGoalPos = true;

	self PlayAnimNAtRateUntilNotetrack( animState, animIndex, self.movePlaybackRate, animState, "code_move" );
	self ScrAgentSetOrientMode( "face motion" );
	
	self.bLockGoalPos = false;
}

doRunStart()
{
	self doStartMoveAnim( "run_start" );
}

doLeapToRunStart()
{
	self doStartMoveAnim( "leap_to_run_start" );
}

doStartMoveAnim( animState )
{
	angleIndex = getStartMoveAngleIndex();
	
	lookaheadDir = self GetLookaheadDir();
	lookaheadAngles = VectorToAngles( lookaheadDir );
		
	startAnim = self GetAnimEntry( animState, angleIndex );
	startAnimTranslation = GetMoveDelta( startAnim );

	endPos = RotateVector( startAnimTranslation, self.angles ) + self.origin;
	
	// JohnW: Disabling trace check - mostly redundant from sharpturn traces in code
	//if ( !self CanMovePointToPoint( self.origin, endPos ) )
		//return;

	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	
	self.bLockGoalPos = true;

	self PlayAnimNAtRateUntilNotetrack( animState, angleIndex, self.movePlaybackRate, animState, "code_move" );
	self ScrAgentSetOrientMode( "face motion" );
	
	self.bLockGoalPos = false;
	
}

canDoStartMove()
{
	if ( !isdefined( self.traverseComplete ) 
	  && !isdefined( self.skipStartMove ) 
	  && ( !isdefined( self.disableExits ) || self.disableExits == false ))
	{
		return true;
	}
	else
	{
		return false;
	}
}

getStartMoveType()
{
	previousAnimState = self.previousAnimState;
	switch( previousAnimState )
	{
	case "traverse_jump":
		return "leap-to-run";
	default:
		switch( self.movemode )
		{
		case "run":
			return "run-start";
		case "walk":
			return "walk-start";
		default:
			return "run-start";
		}
	}
}

shouldDoStopAnim()
{
	return ( isDefined( self.enableStop ) && self.enableStop == true );
}

shouldDoLeapArrivalAnim( startNode, angleIndex )
{
	if( startNode.type == "Jump" || startNode.type == "Jump Attack" )  // For jump nodes, always do run-to-leap animation
		return true;
	else if ( traversalStartFromIdle( startNode.animscript ) )  // If the traversal animation starts at the idle position, need to play run-to-leap
		return true;
	else if( angleIndex == 3 || angleIndex == 4 || angleIndex == 5 )  // For other traversals, do not play when the incoming angle is either 45 or 0
		return false;
	else
		return true;
}

traversalStartFromIdle( anim_script )
{
	switch( anim_script )
	{
	case "alien_climb_up":
	case "alien_climb_up_over_56":
	case "climb_up_end_jump_side_l":
	case "climb_up_end_jump_side_r":
	case "alien_climb_up_ledge_18_run":
	case "alien_climb_up_ledge_18_idle":
		return true;
	default:
		return false;
	}
}

CanDoTurnAnim( turnAnim )
{
	HEIGHT_OFFSET = 16;
	RADIUS_OFFSET = 10;
	HEIGHT_OFFSET_COOR = ( 0, 0, 16 );
	
	if ( !IsDefined( self GetPathGoalPos()) )
		return false;

	assert( isDefined( turnAnim ));
	
	codeMoveTimes = GetNotetrackTimes( turnAnim, "code_move" );
	assert( codeMoveTimes.size == 1 );

	codeMoveTime = codeMoveTimes[ 0 ];
	assert( codeMoveTime <= 1 );

	moveDelta = GetMoveDelta( turnAnim, 0, codeMoveTime );
	codeMovePoint = self LocalToWorldCoords( moveDelta );
	codeMovePoint = GetGroundPosition( codeMovePoint, self.radius );
	if ( !isDefined( codeMovePoint ) )
		return false;
	
	trace_passed = self AIPhysicsTracePassed( self.origin + HEIGHT_OFFSET_COOR, codeMovePoint + HEIGHT_OFFSET_COOR, self.radius - RADIUS_OFFSET, self.height - HEIGHT_OFFSET );
	if ( trace_passed )
		return true;
	else	
		return false;
}

shouldStartMove()
{
	angleIndex = getStartMoveAngleIndex();
	
	return ( angleIndex < 3 || angleIndex > 5 ); //We do not want to do start move if the look ahead direction is straight ahead or 45 degree to either side
}

getStartMoveAngleIndex()
{
	return GetAngleIndexFromSelfYaw( self GetLookaheadDir() );
}