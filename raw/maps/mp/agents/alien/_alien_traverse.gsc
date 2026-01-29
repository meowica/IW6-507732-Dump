#include maps\mp\agents\_scriptedAgents;

main()
{	
	self endon( "killanimscript" );

	self.bLockGoalPos = true;

	startNode = self GetNegotiationStartNode();
	endNode = self GetNegotiationEndNode();
	assert( IsDefined( startNode ) && IsDefined( endNode ) );

	animState = undefined;

	if ( startNode.type == "Jump" || startNode.type == "Jump Attack" )
	{
		nextNode = self GetNegotiationNextNode();
		self.traverseType = "jump";
		self Jump( startNode, endNode, nextNode );
	}
	else
	{
		self.traverseType = "canned";
		self doTraverse( startNode, endNode );
	}
}

end_script()
{
	self.bLockGoalPos = false;
	if ( self.traverseType == "jump" )
	{
		self.previousAnimState = "traverse_jump";
	}
	else
	{
		self.previousAnimState = "traverse_canned";
	}
	self.traverseType = undefined;
}


Jump( startNode, endNode, nextNode )
{
	nextPos = undefined;
	if ( IsDefined( nextNode ) )
		nextPos = nextNode.origin;

	self maps\mp\agents\alien\_alien_jump::Jump( startNode.origin, startNode.angles, endNode.origin, endNode.angles, nextPos );
}

doTraverse( startNode, endNode )
{
	animState = undefined;
	traverseData = level.alienAnimData.cannedTraverseAnims[ startNode.animscript ];
	self.endNode = endNode;
	
	if ( !isDefined( traverseData ) )
	{
		AssertMsg( "Traversal '" + startNode.animscript + "' is not supported" );
		return;
	}
	
	if ( IsDefined( traverseData [ "animState" ] ) )
	{
		animState = traverseData [ "animState" ];
	}
	else
	{
		assertmsg( "No animState specified for traversal '" + startNode.animscript + "'" );
		return;
	}
	
	self ScrAgentSetPhysicsMode( "noclip" );
	self ScrAgentSetOrientMode( "face angle abs", startNode.angles );
	self ScrAgentSetAnimMode( "anim deltas" );

	if ( isdefined( traverseData[ "traverseSound" ] ) )
		self thread maps\mp\_utility::play_sound_on_tag( traverseData[ "traverseSound" ] );

	if ( isdefined( traverseData[ "traverseAnimRate" ] ) )
		self ScrAgentSetAnimScale( traverseData[ "traverseAnimRate" ], traverseData[ "traverseAnimRate" ] );
	
	switch ( animState )
	{
	case "traverse_climb_up":
		alienClimbUp( startNode, endNode, "traverse_climb_up", self GetAnimEntry( "traverse_climb_up", 4 ) );
		break;
	case "traverse_climb_up_over_56":
		alienClimbUp( startNode, endNode, "traverse_climb_up_over_56" );
		break;
	case "traverse_climb_up_ledge_18_run":
		alienClimbUp( startNode, endNode, "traverse_climb_up_ledge_18_run" );
		break;
	case "traverse_climb_up_ledge_18_idle":
		alienClimbUp( startNode, endNode, "traverse_climb_up_ledge_18_idle" );
		break;
	case "climb_up_end_jump_side_l":
		alienClimbUp( startNode, endNode, "climb_up_end_jump_side_l" );
		break;
	case "climb_up_end_jump_side_r":
		alienClimbUp( startNode, endNode, "climb_up_end_jump_side_r" );
		break;		
	case "traverse_climb_down":
		alienClimbDown( startNode, endNode, "traverse_climb_down" );
		break;
	case "traverse_climb_over_56_down":
		alienClimbDown( startNode, endNode, "traverse_climb_over_56_down" );
		break;
	default:
		animIndex = traverseData [ "animIndex" ];
		PlayAnimNUntilNotetrack( animState, animIndex, "canned_traverse", "end", ::handleTraverseNotetracks );
		break;
	}

	self.endNode = undefined;
	self ScrAgentSetAnimScale( 1, 1 );
}

handleTraverseNotetracks( note, animState, animIndex, animTime )
{
	if ( note == "traverse_drop" || note == "traverse_up" )
		return scaleTraverseZ( animState, animIndex, animTime );
}

scaleTraverseZ( animState, animIndex, animTime )
{
	traverseAnim = self GetAnimEntry( animState, animIndex );
	moveDelta = GetMoveDelta( traverseAnim, animTime, 1 );
	
	remainingHeight = abs( self.endNode.origin[2] - self.origin[2] );
	self ScrAgentSetAnimScale( 1, abs( remainingHeight / moveDelta[2] ) );
}

//===========================================
// Special traversals 
//===========================================

//////////////////
// Climb up

alienClimbUp( startNode, endNode, animState, longerEndAnim )
{	
	startAnim = self GetAnimEntry( animState, 0 );
	scrabbleAnim = self GetAnimEntry( animState, 1 );
	loopAnim = self GetAnimEntry( animState, 2 );
	endAnim = self GetAnimEntry( animState, 3 );
	
	totalHeight = endNode.origin[ 2 ] - startnode.origin[ 2 ];
	totalXYDist = Distance2D( startnode.origin, endNode.origin );
	startAnimHeight = GetMoveDelta( startAnim, 0, 1 )[ 2 ];
	scrabbleAnimHeight = GetMoveDelta( scrabbleAnim, 0, 1 )[ 2 ];
	loopAnimHeight = GetMoveDelta( loopAnim, 0, 1 )[ 2 ];
	endAnimHeight = GetMoveDelta( endAnim, 0, 1 )[ 2 ];
	longerEndAnimHeight = undefined;
	
	climbUpNotetrackTime = getNoteTrackTimes( startAnim, "climb_up_teleport" ) [ 0 ];
	climbUpAnimDeltaBeforeNotetrack = GetMoveDelta( startAnim, 0, climbUpNotetrackTime );
	climbUpAnimDeltaAfterNotetrack = GetMoveDelta( startAnim, climbUpNotetrackTime, 1 );
	startAnimHeightAfterNotetrack = climbUpAnimDeltaAfterNotetrack[ 2 ];
	startAnimXYDistBeforeNotetrack = length( climbUpAnimDeltaBeforeNotetrack * ( 1, 1, 0 ) );
	startAnimXYDistAfterNotetrack = length( climbUpAnimDeltaAfterNotetrack * ( 1, 1, 0 ) );
	
	if ( totalHeight < ( startAnimHeight + endAnimHeight ) )
		Println( "ERROR: Height is too short for " + animState + ".  Modify the geo or use another traversal." );
	
	distForScrabbleAndLoop = totalHeight - ( startAnimHeight + endAnimHeight );
	canDoScrabble = false;
	numOfLoop = 0;
	if ( distForScrabbleAndLoop > 0 )
	{
		canDoScrabble = ( distForScrabbleAndLoop - scrabbleAnimHeight ) > 0;
		numOfLoop = max ( 0, floor ( ( distForScrabbleAndLoop - canDoScrabble * scrabbleAnimHeight ) / loopAnimHeight ) );
	}
	
	teleportAnimHeight = canDoScrabble * scrabbleAnimHeight + numOfLoop * loopAnimHeight + startAnimHeightAfterNotetrack;
	teleportRealHeight = totalHeight - endAnimHeight - ( startAnimHeight - startAnimHeightAfterNotetrack ); 
	animScalerZ = teleportRealHeight / teleportAnimHeight;
	
	canDoLongerEndAnim = false;
	if ( isDefined ( longerEndAnim ))
	{
		longerEndAnimHeight = GetMoveDelta( longerEndAnim, 0, 1 )[ 2 ];
		endAnimHeightDiff = longerEndAnimHeight - endAnimHeight;
		canDoLongerEndAnim = ( teleportRealHeight - teleportAnimHeight ) > endAnimHeightDiff;
		animScalerZ = ( teleportRealHeight - canDoLongerEndAnim * endAnimHeightDiff )/ teleportAnimHeight;
	}
	
	selectedEndAnim = endAnim;
	if ( canDoLongerEndAnim )
		selectedEndAnim = longerEndAnim;
	
	stopTeleportNotetrack = getNoteTrackTimes( selectedEndAnim, "stop_teleport" ) [ 0 ];
	endAnimHeightBeforeNotetrack = GetMoveDelta( selectedEndAnim, 0, stopTeleportNotetrack )[ 2 ];
	stopToEndAnimDelta = GetMoveDelta( selectedEndAnim, stopTeleportNotetrack, 1 );
	stopToEndAnimDeltaXY = length( stopToEndAnimDelta * ( 1, 1, 0 ) );
	
	animScalerXY = ( totalXYDist - startAnimXYDistBeforeNotetrack - stopToEndAnimDeltaXY ) / startAnimXYDistAfterNotetrack;
	
	// startAnim: Play the anim normally until climb_up_teleport notetrack
	self ScrAgentSetAnimScale( 1, 1 );
	PlayAnimNUntilNotetrack( animState, 0, "canned_traverse", "climb_up_teleport", ::handleTraverseNotetracks );
	
	// startAnim: Initial horizontal scaling to make up fpr any XY displacement.  Start to scale to Z.
	self ScrAgentSetAnimScale( animScalerXY, animScalerZ );
	self WaitUntilNotetrack( "canned_traverse", "end" );
	
	// scrabble and loop animation: Continue the Z scaling.	
	self ScrAgentSetAnimScale( 1, animScalerZ );
	if ( canDoScrabble )
    	PlayAnimNUntilNotetrack( animState, 1, "canned_traverse", "finish", ::handleTraverseNotetracks );
    	
	for ( i = 0; i < numOfLoop; i++ )
    {
    	PlayAnimNUntilNotetrack( animState, 2, "canned_traverse", "end", ::handleTraverseNotetracks );
    } 
	
	//Final height adjustment, making sure alien reach enough height and will not end up inside geo when finish the traversal
	selfToEndHeight = endNode.origin[ 2 ] - self.origin[ 2 ] - stopToEndAnimDelta[ 2 ];
	animScalerZ = 1.0;
	if ( selfToEndHeight > endAnimHeightBeforeNotetrack )
		animScalerZ = selfToEndHeight / endAnimHeightBeforeNotetrack;
		
	self ScrAgentSetAnimScale( 1, animScalerZ );

	if ( canDoLongerEndAnim )	
		PlayAnimNUntilNotetrack( animState, 4, "canned_traverse", "stop_teleport", ::handleTraverseNotetracks );
	else
		PlayAnimNUntilNotetrack( animState, 3, "canned_traverse", "stop_teleport", ::handleTraverseNotetracks );

	//Final horizontal adjustment, making sure alien will end at the traverse End node
	selfToEndXY = distance2D( self.origin, endNode.origin );
	animScalerXY = selfToEndXY / stopToEndAnimDeltaXY;
	
	self ScrAgentSetAnimScale( animScalerXY, 1 );
	self WaitUntilNotetrack( "canned_traverse", "end" );
}

/////////////////////
// Climb down

alienClimbDown( startNode, endNode, animState )
{
	startAnim = self GetAnimEntry( animState, 0 );
	loopAnim = self GetAnimEntry( animState, 1 );
	slideAnim = self GetAnimEntry( animState, 2 );	
	endAnim = self GetAnimEntry( animState, 3 );
	jumpOffEndAnim = self GetAnimEntry( animState, 4 );
	
	totalHeight= startNode.origin[ 2 ] - endNode.origin[ 2 ];
	startAnimHeight = -1 * GetMoveDelta( startAnim, 0, 1 )[ 2 ];
	slideAnimHeight = -1 * GetMoveDelta( slideAnim, 0, 1 )[ 2 ];
	loopAnimHeight = -1 * GetMoveDelta( loopAnim, 0, 1 )[ 2 ];
	endAnimHeight = -1 * GetMoveDelta( endAnim, 0, 1 )[ 2 ];
	jumpOffEndAnimHeight = -1 * GetMoveDelta( jumpOffEndAnim, 0, 1 )[ 2 ];
	
	if ( totalHeight < ( startAnimHeight + endAnimHeight ) )
		Println( "ERROR: Height is too short for " + animState + ".  Modify the geo or use another traversal." );
	
	endAnimToPlay = endAnim;
	endAnimToPlayHeight = endAnimHeight;
	canDoJump = false;
	
	//Determine whether alien can play the jump off anim for end
	if ( self canDoJumpForEnd( startnode, endNode, startAnim, jumpOffEndAnim ))
	{
		endAnimToPlay = jumpOffEndAnim;
		endAnimToPlayHeight = jumpOffEndAnimHeight; 
		canDoJump = true;		
	}
	
	distForSlideAndLoop = totalHeight - ( startAnimHeight + endAnimToPlayHeight );
	canDoSlide = false;
	numOfLoop = 0;
	if ( distForSlideAndLoop > 0 )
	{
		canDoSlide = ( distForSlideAndLoop - slideAnimHeight ) > 0;
		numOfLoop = max ( 0, floor (( distForSlideAndLoop - canDoSlide * slideAnimHeight ) / loopAnimHeight ));
	}
	
	self ScrAgentSetAnimScale( 1, 1 );
	PlayAnimNUntilNotetrack( animState, 0, "canned_traverse", "end", ::handleTraverseNotetracks );
	
	slideAndLoopAnimHeight = canDoSlide * slideAnimHeight + numOfLoop * loopAnimHeight;
	if ( slideAndLoopAnimHeight > 0 )
	{
		animScaler = abs( ( distForSlideAndLoop )/ slideAndLoopAnimHeight );
		self ScrAgentSetAnimScale( 1, animScaler );
	}
	
	//<Note J.C.>: Playing the loop and slide animation from the same anim state has caused the following issue.:
	//             (1) The "will_finish_soon" notetrack will fire off immediately due to the short anim length for the slide anim, 
	//                 causing the slide animation to not play
	//             (2) When this happens, the alien will keep playing the loop animation even when the jump-off state is activated.
	//             If time permits, we need to look into how situations like this should be prevented.
	for ( i = 0; i < numOfLoop; i++ )
    {
    	PlayAnimNUntilNotetrack( "traverse_climb_down_loop", 0, "traverse_climb_down_loop", "end", ::handleTraverseNotetracks );
    }
	if ( canDoSlide )
		PlayAnimNUntilNotetrack( "traverse_climb_down_slide", 0, "traverse_climb_down_slide", "end", ::handleTraverseNotetracks );
	
	//Final height adjustment, making sure alien ends up on the ground when finish
	teleportStartTime = getNoteTrackTimes( endAnimToPlay, "climb_down_teleport" ) [ 0 ];
	teleportEndTime = getNoteTrackTimes( endAnimToPlay, "stop_teleport" ) [ 0 ];
	animHeightAfterNotetrack = -1 * GetMoveDelta( endAnimToPlay, teleportStartTime, teleportEndTime )[ 2 ];
	heightAdjustment = abs( self.origin[ 2 ] - endNode.origin[ 2 ] - abs ( GetMoveDelta( endAnimToPlay, teleportEndTime, 1 )[ 2 ] ) );
	animScaler = heightAdjustment / animHeightAfterNotetrack;
	
	self ScrAgentSetAnimScale( 1, animScaler );
	
	if ( canDoJump )
		PlayAnimNUntilNotetrack( animState, 4, "canned_traverse", "stop_teleport", ::handleTraverseNotetracks );
	else
		PlayAnimNUntilNotetrack( animState, 3, "canned_traverse", "stop_teleport", ::handleTraverseNotetracks );
		
	self ScrAgentSetAnimScale( 1, 1 );
	self ScrAgentSetPhysicsMode( "gravity" );
	self WaitUntilNotetrack( "canned_traverse", "end" );
}

canDoJumpForEnd( startnode, endNode, startAnim, jumpAnim )
{	
	TRACE_START_FORWARD_PADDING = 10;
	TRACE_END_UP_PADDING = ( 0, 0, 10 );
	TRACE_CAPSULE_RADIUS = 5;
	TRACE_CAPSULE_HEIGHT = self.height;
	
	startAnimDelta = GetMoveDelta( startAnim, 0, 1 );
	startAnimDeltaXY = Length2D ( startAnimDelta );
	startAnimDeltaZ = startAnimDelta [ 2 ] * -1;
	
	jumpAnimDelta = GetMoveDelta( jumpAnim, 0, 1 );
	jumpAnimDeltaXY = Length2D ( jumpAnimDelta );
	jumpAnimDeltaZ = jumpAnimDelta[ 2 ] * -1;

	startToEndXY = VectorNormalize (( endNode.origin - startnode.origin ) * ( 1, 1, 0 ));
	startAnimEndPos = startnode.origin + startToEndXY * startAnimDeltaXY - ( 0, 0, startAnimDeltaZ );
	
	startAnimEndGroundPos = PhysicsTrace( startAnimEndPos, startAnimEndPos + ( 0, 0, -2000 ) );
	startAnimEndAboveGround = ( startAnimEndPos - startAnimEndGroundPos ) [ 2 ];
	
	if ( startAnimEndAboveGround < jumpAnimDeltaZ )
		return false;
	
	jumpStartPos = startAnimEndGroundPos + ( 0, 0, jumpAnimDeltaZ );
	jumpEndPos = startAnimEndGroundPos + startToEndXY * jumpAnimDeltaXY;
	
	traceStartPos = jumpStartPos + startToEndXY * TRACE_START_FORWARD_PADDING;
	traceEndPos = jumpEndPos + TRACE_END_UP_PADDING;
	
	return ( self AIPhysicsTracePassed( traceStartPos, traceEndPos, TRACE_CAPSULE_RADIUS, TRACE_CAPSULE_HEIGHT, false ) );
}