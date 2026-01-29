// single_fish
// For individual animals that play an idle animation in a radius, then flee to another point when disturbed.
#include maps\interactive_models\_interactive_utility;
#include common_scripts\_csplines;

fish()
{
	level waittill ( "load_finished" );	

	if ( IsDefined( level._interactive[ "fish_setup" ] ) )
	{
		return;
	}
	
	level._interactive[ "fish_setup" ] = true;
	
/* I implemented support for script_structs in addition to script_models.  However, they make things more complicated and 
   Nate tells me that as long as ents are deleted before _load they don't matter anyway.  So here is the script, commented out.
	script_structs = common_scripts\utility::getstructarray( "interactive_fish", "script_noteworthy" );
	foreach ( script_struct in script_structs ) {
		PreCacheModel( script_struct.script_modelname );
	}
*/
	/#
	fishes = GetEntArray( "interactive_fish_bannerfish", "targetname" );
	AssertEx ( fishes.size == 0, "Use (script_noteworthy,interactive_fish) and (interactive_type,fish_bannerfish) instead of (targetname,interactive_fish_bannerfish) for interactive fish now." );
	/*if ( fishes.size != 0 ) {
		IPrintLn( "Converting interactive fish from targetname to script_noteworthy.  This will stop working soon." );
		foreach ( fish in fishes )
		{
			Assert( !IsDefined( fish.script_noteworthy ) );
			fish.script_noteworthy = "interactive_fish";
			Assert( !IsDefined( fish.interactive_type ) );
			fish.interactive_type = "fish_bannerfish";
		}
	}*/
	#/
		
	fishes = GetEntArray( "interactive_fish", "script_noteworthy" );
	foreach ( fish in fishes )
	{
		if ( fish.classname == "script_model" )
			fish thread single_fish_start();
		// else it should be a script_struct, so wait for 
	}
}

single_fish_start()
{
	Assert( IsDefined( self.interactive_type ) );
	Assert( IsDefined( level._interactive[ self.interactive_type ] ) );
	
	if ( isDefined( self.target ) )
		positions = GetEntArray( self.target, "targetname" );
	else
		positions = [];
	if ( positions.size >= 1 && isDefined( positions[0].script_noteworthy ) && positions[0].script_noteworthy == "interactive_fish" ) {
		// Positions[0] is another fish.  Connect them.
		AssertEx ( positions.size == 1, "Fish that target other fish must only have one target. " + self.origin );
		self.following = positions[0];
		if ( !IsDefined( positions[0].followedBy ) ) positions[0].followedBy = [];
		positions[0].followedBy[ positions[0].followedBy.size ] = self;
		positions = [];	// We don't want to store the other fish's origin as a flee location.
	}
	start_pos = SpawnStruct();
	start_pos.origin = self.origin;
	start_pos.script_radius = self.script_radius;
	positions[ positions.size ] = start_pos;
	if ( !IsDefined( self.script_moveplaybackrate ) ) self.script_moveplaybackrate = 1;
	foreach ( position in positions )
	{
		if ( !IsDefined( position.script_radius ) ) 
			position.script_radius = level._interactive[ self.interactive_type ].default_wander_radius;
	}
	self thread single_fish_idle( self.interactive_type, positions, start_pos.origin, start_pos.script_radius, true );
}

// single_fish_idle
// Plays an idle animation (that moves roughly forward) and periodically redirects to stay near the supplied center point.
single_fish_idle( interactive_index, positions, posOrigin, posRadius, firstTime )
{
	self endon( "death" );
	self endon( "interrupted" );
	if ( !IsDefined( firstTime ) ) firstTime = false;
	info = level._interactive[ interactive_index ];
	self UseAnimTree( info.animtree );
	
	// Create a trigger and a thread to take over when the trigger fires
	//self thread detect_events( "interrupted" );	// This would make it react to gunfire & explosions
	self thread detect_people( info.react_distance, "interrupted", [ "interrupted", "death", "damage" ] );
	self thread single_fish_flee( interactive_index, positions );
	
	while ( 1 )
	{
		// Choose and play an animation
		// If we're well outside the radius, play a fast-moving animation to get there
		centerVec = posOrigin - self.origin;
		centerDistance = Length( ( centerVec[0], centerVec[1], 2*centerVec[2] ) );	// Double Z component so radius is squashed vertically.  It just feels better that way.
		if ( centerDistance > posRadius * 2 )
			animPlaying = self single_anim( info.anims, "flee_continue", "idle anim", true, self.script_moveplaybackrate );
		else
			animPlaying = self single_anim( info.anims, "idle", "idle anim", true, self.script_moveplaybackrate );
		animLength = GetAnimLength( animPlaying ) / self.script_moveplaybackrate;
		AssertEx( animLength > 0, "Fish: animLength is 0! Have you added an idle animation and forgotten to put it in the fastfile?" );
		
		animSpeed = Length( GetMoveDelta( animPlaying ) ) / animLength;
		totalWait = 0;
		
		/#
		if ( GetDebugDvarInt( "interactives_debug" ) )
		{
			drawCircle( posOrigin					   , posRadius    , (0,1,0), animLength );
		}
		#/
		
		if ( firstTime )	// firstTime is used to set a random start point when the level starts.
		{
			wait( 0.05 );
			animTime = RandomFloatRange( 0, 1 );
			self SetAnimTime( animPlaying, animTime );
			totalWait = ( animTime * animLength ) + 0.05;
			firstTime = false;
		}
		
		// Now move a bit, then redirect, move a bit more, redirect again, etc
		while ( totalWait < animLength )
		{
			waitTime = info.wander_redirect_time * RandomFloatRange( 0.5, 1.5 ) / self.script_moveplaybackrate;
			if ( totalWait + waitTime > animLength - ( info.wander_redirect_time / 2 ) )
				waitTime = animLength - totalWait;
			if ( animSpeed * waitTime > posRadius )
				waitTime = posRadius / ( animSpeed * 1.5 );	// 1.5 fudge because animations have varying speeds.
			
			// Check position and redirect.
			forward = AnglesToForward( self.angles );
			projectedPosition = self.origin + ( 0.5 * animSpeed * forward * waitTime );	// Position halfway through next wait period
			centerDirection = posOrigin - projectedPosition;
			projectedDistance = Length( ( centerDirection[0], centerDirection[1], 2*centerDirection[2] ) );	// Double Z component so radius is squashed vertically.
			if ( projectedDistance + ( animSpeed * waitTime ) < posRadius )
			{
				if ( centerDistance < posRadius ) {
					// We're outside the radius, headed towards it.  Don't turn too far.
					turnYawAngle = RandomFloatRange( -20, 20 );
				} else {
					// We're well within the radius.  Just turn randomly
					turnYawAngle = RandomFloatRange( -60, 60 );
				}
				turnPitchAngle = RandomFloatRange(-20,20) - ( 0.5 * self.angles[0] );
				interactives_drawDebugLineForTime( self.origin, posOrigin, 0,1,0, waitTime );
				// Bug 29068 says the fish flip on their back.  I think I fixed it, but assert here just in case.
				AssertEx( abs( self.angles[0] + turnPitchAngle ) <= 60, "Fish pitch outside limits, 1. cDist/pRad: " + (centerDistance/posRadius) + ", pitch: " + self.angles[0] );
			}
			else
			{
				// We're in danger of leaving the radius, so turn inward.
				right = AnglesToRight( self.angles );
				turnYawAngle = RandomFloatRange( 60, 100 );
				if ( VectorDot( centerDirection, forward ) > 0 )
				{
					// Already moving towards the center so don't turn so much
					turnYawAngle -= 60;	
					if ( centerDistance < posRadius ) {
						// We're outside the radius, headed towards it.  Turn even less.
						turnYawAngle /= 2;
					}
				}
				if ( VectorDot( centerDirection, right ) > 0 )
					turnYawAngle *= -1;
				heightPlay = posRadius / 2;	// Radius is squashed vertically.
				if ( centerDirection[2] < -1 * heightPlay )
					turnPitchAngle = RandomFloatRange(  15, 30) - ( 0.5 * self.angles[0] );
				else if ( centerDirection[2] > heightPlay )
					turnPitchAngle = RandomFloatRange(-30,  -15) - ( 0.5 * self.angles[0] );
				else if ( centerDirection[2] < -0.5 * heightPlay )
					turnPitchAngle = RandomFloatRange(  0, 30) - ( 0.5 * self.angles[0] );
				else if ( centerDirection[2] > 0.5 * heightPlay )
					turnPitchAngle = RandomFloatRange(-30,  0) - ( 0.5 * self.angles[0] );
				else 
					turnPitchAngle = RandomFloatRange(-20, 20) - ( 0.5 * self.angles[0] );
					
				interactives_drawDebugLineForTime( self.origin, posOrigin, .7,.7,0, waitTime );
				// Bug 29068 says the fish flip on their back.  I think I fixed it, but assert here just in case.
				AssertEx( abs( self.angles[0] + turnPitchAngle ) <= 60, "Fish pitch outside limits, 2. cD[2]/hPlay: " + (centerDirection[2]/heightPlay) + ", pitch: " + self.angles[0] );
			}
			if ( turnYawAngle > 0 )
			{
				self SetAnimLimitedRestart( info.anims["turn_left_child"], 1, 0 );
				self SetAnim( info.anims["turn_left"], min(turnYawAngle/60,1), 0 );
				//self single_anim( info.anims, "turn_left", "turn anim", true );
			}
			else
			{
				self SetAnimLimitedRestart( info.anims["turn_right_child"], 1, 0, self.script_moveplaybackrate );
				self SetAnim( info.anims["turn_right"], min(turnYawAngle/-60,1), 0 );
				//self single_anim( info.anims, "turn_right", "turn anim", true );
			}
			self RotateBy( (turnPitchAngle,turnYawAngle,0), 0.5 / self.script_moveplaybackrate, 0, 0.5 / self.script_moveplaybackrate );
			self.detect_people_trigger[ "interrupted" ].origin = projectedPosition - (0,0,16);	// Keep the trigger a little low because the player's collision doesn't seem to include his head.

			wait waitTime;
			totalWait += waitTime;
			// Bug 29068 says the fish flip on their back.  I think I fixed it, but assert here just in case.
			Assert( abs( self.angles[0] ) <= 60 );
			Assert( abs( self.angles[2] ) < 0.001 );
		}
	}
}

// Move to new position, then start the idle thread again
single_fish_flee( interactive_index, positions )
{
	self endon( "death" );
	info = level._interactive[ interactive_index ];
	nextPositionIndex = RandomInt( positions.size );
	self.nextOrigin = positions[ nextPositionIndex ].origin;
	nextRadius = positions[ nextPositionIndex ].script_radius;
	
	self waittill( "interrupted" );
	interrupterDir = undefined;
	if ( isDefined( self.interruptedEnt ) )
	{
		if ( IsSentient( self.interruptedEnt ) )
			interrupterEyePos = self.interruptedEnt GetEye();
		else
			interrupterEyePos = self.interruptedEnt.origin;
		/#
		interactives_DrawDebugLineForTime ( self.origin, interrupterEyePos, 1, 0, 0, 3 );
		#/
		//if ( DistanceSquared( interrupterEyePos, self.origin ) < level._interactive[ interactive_index ].react_distance )
			interrupterDir = VectorNormalize( interrupterEyePos - self.origin );
	}
	
	self thread single_fish_InterruptFollowers();
    self.nextOrigin = self single_fish_GetNextOrigin();
	moveVec = self.nextOrigin - self.origin;
	moveDirection = VectorNormalize( moveVec );
	if ( IsDefined( interrupterDir ) && VectorDot( interrupterDir, moveDirection ) > 0.7 ) {
		moveDirection = interrupterDir + VectorNormalize( moveDirection - interrupterDir );	// Make it roughly 45 degrees away from interrupterDir, to avoid collisions.
	}
	forward = AnglesToForward( self.angles );
	if ( VectorDot( moveDirection, forward ) > 0.7 )
	{
		fleeAnim = "flee_straight";
	}
	else
	{
		right = AnglesToRight( self.angles );
		if ( VectorDot( moveDirection, right ) > 0 )
		{
			fleeAnim = "flee_right";
		}
		else
		{
			fleeAnim = "flee_left";
		}
	}
	newAngles = VectorToAngles( moveDirection );
	/#
	interactives_DrawDebugLineForTime ( self.origin, self.origin + 20*moveDirection, 0, 0, 1, 3 );
	interactives_DrawDebugLineForTime ( self.origin, self.origin + 20*AnglesToForward(newAngles), 0, 0, 1, 3 );
	#/

	randomFleeSpeed = randomFloatRange( 0.8, 1.2 );
	flee_anim = self single_anim( info.anims, fleeAnim, "flee anim", true, self.script_moveplaybackrate * randomFleeSpeed );
	self RotateTo( newAngles, 0.2 / self.script_moveplaybackrate, 0, 0.2 / self.script_moveplaybackrate );	// nb This doesn't appear to work if the animation has delta-rotation in it.
	// Continue curving the path towards the goal
	fleeAnimLength = GetAnimLength( flee_anim ) / ( self.script_moveplaybackrate * randomFleeSpeed );
	fleeAnimLength -= 0.5;
	wait( 0.5 );
	while ( ( fleeAnimLength > 0.5 ) && ( DistanceSquared( self.nextOrigin, self.origin ) > nextRadius * nextRadius ) ) {
		moveVec = self.nextOrigin - self.origin;
		moveDirection = VectorNormalize( moveVec );
		newAngles = VectorToAngles( moveDirection );
		self RotateTo( newAngles, 1, 0.1, 0.4 );
		wait( 0.5 );
		fleeAnimLength -= 0.5;
	}
	self waittillmatch( "flee anim", "end" );
	self thread single_fish_idle( interactive_index, positions, self.nextOrigin, nextRadius );
}

single_fish_GetNextOrigin()
{
	if ( IsDefined( self.following ) ) {
		return self.following single_fish_GetNextOrigin();
	} else {
		return self.nextOrigin;
	}
}

single_fish_InterruptFollowers()
{
	self endon( "death" );
	wait ( 0.05 * RandomInt( 3 ) );
	if ( IsDefined( self.following ) ) {
		self.following.interruptedEnt = self.interruptedEnt;
	    self.following notify( "interrupted" );
	}
	if ( IsDefined( self.followedBy ) ) {
		numFollowers = self.followedBy.size;
		foreach ( follower in self.followedBy ) {
			wait ( 0.05 * RandomIntRange( 5, 10 ) / numFollowers );
			follower.interruptedEnt = self.interruptedEnt;
			follower notify( "interrupted" );
		}
	}
}

/*
=============
///ScriptDocBegin
"Name: single_fish_saveToStruct()"
"Summary: Saves the entity information into a struct, so that entities are freed up for other uses.  My intention is that this will be called through [[level._interactive[...].saveToStructFn]]"
"Module: _fish"
"CallOn: An interactive fish entity"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
single_fish_saveToStruct()
{
	AssertEx( IsDefined( self.interactive_type ), "Fish entity does not have an interactive_type keypair." );
	AssertEx( IsDefined( level._interactive ), "Fish entity in map, but level._interactive is not defined." );
	AssertEx( IsDefined( level._interactive[ self.interactive_type ] ), ( "Fish entity in map, but level._interactive[" + self.interactive_type + "] is not defined." ) );

	struct = spawnStruct();
	// Save everything that might be in the ent
	struct.model				= self.model;
	struct.interactive_type		= self.interactive_type;
	struct.origin				= self.origin;
	struct.angles				= self.angles;
	struct.target				= self.target;
	struct.targetname			= self.targetname;
	struct.script_noteworthy	= self.script_noteworthy;
	struct.script_radius		= self.script_radius;

	self Delete();
	return struct;
}

/*
=============
///ScriptDocBegin
"Name: single_fish_loadFromStruct()"
"Summary: Loads the entity information from a struct and recreates the fish.  My intention is that this will be called through [[level._interactive[...].loadFromStructFn]]"
"Module: _fish"
"CallOn: A struct that was returned by single_fish_saveToStruct()"
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

single_fish_loadFromStruct()
{
	ent = Spawn( "script_model", self.origin );
	// Necessary stuff
	ent SetModel( self.model );
	ent.interactive_type	= self.interactive_type;
	ent.origin				= self.origin;
	ent.angles				= self.angles;
	ent.target				= self.target;
	ent.targetname			= self.targetname;
	ent.script_noteworthy	= self.script_noteworthy;
	ent.script_radius		= self.script_radius;
	
	ent thread single_fish_start_after_frameend();	// Since fish follow each other, we need to let them all spawn before they start thinking.
}

single_fish_start_after_frameend()
{
	waittillframeend;
	single_fish_start();
}