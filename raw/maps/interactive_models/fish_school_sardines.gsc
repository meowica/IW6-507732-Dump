#include maps\interactive_models\_interactive_utility;
#include common_scripts\_csplines;
#include common_scripts\utility;
#include maps\_utility;
#using_animtree( "animals" );

main()
{
	// Set up the once-off stuff
	info						= SpawnStruct();
	info.name					= "fish_school_sardines";
	info.targetname				= "interactive_fish_school_sardines";
	// A school of sardines is made up of a number of "pieces," each of which is a model with several tags.  
	info.piece			 = SpawnStruct();
	info.piece.model	 = "sardines_flocking_rig";
	info.piece.tagPrefix = "tag_attach";
	info.piece.maxTurn	 = 5;	// Degrees per frame
	// Piece animations:
	info.piece.animtree					 = #animtree;
	info.piece.anims					 = [];
	info.piece.anims[ "idle_loop"	   ] = %sardines_flock_loop;
//	info.piece.anims[ "additive"	   ] = %sardines_additive;
	info.piece.anims[ "add_bend_left"  ] = %sardines_flock_add_left60;
	info.piece.anims[ "add_bend_right" ] = %sardines_flock_add_right60;
	info.piece.anims[ "add_fast"	   ] = %sardines_flock_add_stretch_horiz;
	info.piece.anims[ "add_tilt_left"	   ] = %sardines_flock_add_tilt_left_add;
	info.piece.anims[ "add_tilt_right"	   ] = %sardines_flock_add_tilt_right_add;
	info.piece.anims[ "add_tilt_left_child"		] = %sardines_flock_add_tilt_left;
	info.piece.anims[ "add_tilt_right_child"	] = %sardines_flock_add_tilt_right;
	info.piece.anims[ "add_rotate_left"			] = %sardines_flock_add_rotate_left_add;
	info.piece.anims[ "add_rotate_left_child"	] = %sardines_flock_add_rotate_left;
	info.piece.anims[ "add_rotate_right"		] = %sardines_flock_add_rotate_right_add;
	info.piece.anims[ "add_rotate_right_child"	] = %sardines_flock_add_rotate_right;
	// Each tag on the piece has a model of fish attached to it.  Darker models are used for the fish in the center of the school
	info.fish					   = SpawnStruct();
	info.fish.model				   = [];
	// "bright", "grey1" and "grey2" are lighting variants of the same model, used to make the school look self-shadowed.
	info.fish.model[ 0 ][ "bright" ]	= "sardines_single";
	info.fish.model[ 1 ][ "bright" ]	= "sardines_smallergroup";
	info.fish.model[ 2 ][ "bright" ]	= "sardines_smallgroup";
	info.fish.model[ 2 ][ "grey1"  ]	= "sardines_smallgroup_grey75";
	info.fish.model[ 2 ][ "grey2"  ]	= "sardines_smallgroup_grey50";
	info.fish.model[ 3 ][ "bright" ]	= "sardines_smallgroup_thick_grey75";
	info.fish.model[ 3 ][ "grey1"  ]	= "sardines_smallgroup_thick_grey75";
	info.fish.model[ 3 ][ "grey2"  ]	= "sardines_smallgroup_thick_grey50";
	info.fish.anims				   = [];	// nb The fish don't need their own animtree because they're attached to the piece.
	info.fish.anims[ "idle_loop" ] = %sardines_smallgroup_loop1;	// This doesn't work - can't play the animation on more than one attached model with the same joints.
	
	// One arrangement of a school of sardines is a swirling ball.
	info.ball					   = SpawnStruct();
	info.ball.rotationPeriod	   = 5;		// Seconds per revolution of the ball.
	info.ball.numTags			   = 16;	// Only 16 of the piece's tags are set up for the ball animation.
	// Parameters related to moving the ball when the player gets close
	info.ball.relocateSpeed		   = 20;	// Top speed of the fish when relocating, units per inch.
	info.ball.reactDistance		   = 300;	// If a person gets this close, drift away.
	info.ball.panicDistance		   = 150;	// If a person gets this close, the ball will break apart and relocate.
	info.ball.maxDriftDist		   = 150;	// Distance the ball will drift to avoid the player.
	info.ball.driftSpeed		   = 10;	// Units per frame.
	// Structure of the ball.  Pieces in the ball are arranged into rings.
	info.ball.ringVertOffset	   = 48;
	info.ball.rings				   = [];
	info.ball.rings[ 0 ]		   = SpawnStruct();
	info.ball.rings[ 0 ].numPieces = 6;
	info.ball.rings[ 0 ].radius	   = 64;
	info.ball.rings[ 0 ].offset	   =-1 * info.ball.ringVertOffset;
	info.ball.rings[ 1 ]		   = SpawnStruct();
	info.ball.rings[ 1 ].numPieces = 6;
	info.ball.rings[ 1 ].radius	   = 96;
	info.ball.rings[ 1 ].offset	   = -1 * info.ball.ringVertOffset;
	info.ball.rings[ 2 ]		   = SpawnStruct();
	info.ball.rings[ 2 ].numPieces = 6;
	info.ball.rings[ 2 ].radius	   = 64;
	info.ball.rings[ 2 ].offset	   = info.ball.ringVertOffset;
	info.ball.rings[ 3 ]		   = SpawnStruct();
	info.ball.rings[ 3 ].numPieces = 6;
	info.ball.rings[ 3 ].radius	   = 96;
	info.ball.rings[ 3 ].offset	   = info.ball.ringVertOffset;

	// Another arrangement of a school of sardines is a "line," which is a snaking trail of sardines all swimming along a vehicle path.
	// Each piece is placed at distance "spacing" along the path from the previous.
	// Pieces in a path each play a "spin" animation that offsets their tags from the center and spirals them around.
	info.Line					= SpawnStruct();
	info.Line.spacing			= 3;		// In time (frames), not distance.	Mult by speed (from node in Radiant) to get distance.
	info.Line.anims				= [];
	info.Line.anim_base			= %sardines_flock_spin;
	info.Line.anims[ 0 ]		= %sardines_flock_spinloop;
	info.Line.anims[ 1 ]		= %sardines_flock_spinloop_fast;
	info.Line.anims[ 2 ]		= %sardines_flock_spinloop_faster;
	info.Line.animSpeeds[ 0 ]	= 10 * 0.88;  // MPH (to match Radiant's vehicle nodes) * 0.88 converts to inches per frame.
	info.Line.animSpeeds[ 1 ]	= 20 * 0.88;
	info.Line.animSpeeds[ 2 ]	= 50 * 0.88;
	info.Line.animOffset		= 3 / 25;	// Each piece will be this much further through the animation than the piece before it.
	info.Line.taper				= 10;		// Number of pieces to taper at the ends of the line.
	info.Line.tagmodels			= [];
	// These numbers are indices into the info.fish.model array above.  They are randomized, rounded and clipped, so they don't have to be integers or within the bounds of the array.
	info.Line.tagmodels[ "1"  ] = 4;
	info.Line.tagmodels[ "2"  ] = 3;
	info.Line.tagmodels[ "3"  ] = 3;
	info.Line.tagmodels[ "4"  ] = 3;
	info.Line.tagmodels[ "5"  ] = 3;
	info.Line.tagmodels[ "6"  ] = 3;
	info.Line.tagmodels[ "7"  ] = 2.5;
	info.Line.tagmodels[ "8"  ] = 2.5;
	info.Line.tagmodels[ "9"  ] = 2;
	info.Line.tagmodels[ "10" ] = 2;
	info.Line.tagmodels[ "11" ] = 2;
	info.Line.tagmodels[ "12" ] = 2;
	info.Line.tagmodels[ "13" ] = 2;
	info.Line.tagmodels[ "14" ] = 2;
	info.Line.tagmodels[ "15" ] = 2;
	info.Line.tagmodels[ "16" ] = 2;
	info.Line.tagmodels[ "17" ] = 1.5;
	info.Line.tagmodels[ "18" ] = 1.5;
	info.Line.tagmodels[ "19" ] = 1.5;
	info.Line.tagmodels[ "20" ] = 1.5;
	info.Line.tagmodels[ "21" ] = 1;
	info.Line.tagmodels[ "22" ] = 1;
	info.Line.tagmodels[ "23" ] = 1;
	info.Line.tagmodels[ "24" ] = 1;
	info.Line.tagmodels[ "25" ] = 1;
	info.Line.tagmodels[ "26" ] = .5;
	info.Line.tagmodels[ "27" ] = .5;
	info.Line.tagmodels[ "28" ] = .5;
	info.Line.tagmodels[ "29" ] = .5;
	info.Line.tagmodels[ "30" ] = .5;
	info.Line.tagmodels[ "31" ] = .5;	// 31 is the max number of models the engine will allow me to attach.
	// End of data.
	
	if ( !IsDefined ( level._interactive ) )
		level._interactive = [];
	level._interactive[ "sardines" ] = info;
	
	thread sardines( info );
}

sardines( info )
{
	PreCacheModel( info.piece.model );
	foreach ( modelArray in info.fish.model )
	{
		foreach ( model in modelArray )
		{
			PreCacheModel( model );
		}
	}
	PreCacheString( &"PLATFORM_HOLD_TO_USE" );	// For the test triggers for the sardine line in toy_test_animals. TODO Move this into toy_test_animals.gsc.
	

	level waittill ( "load_finished" );
	/#
		SetDevDvarIfUninitialized( "interactives_debug", 0 );
	#/
	if ( !IsDefined( level._interactive[ info.name+"_setup" ] ) )
	{
		level._interactive[ info.name+"_setup" ] = true;
		// Sort out the animations
//		info = level._interactive[ fishType ];	// Now passed as a parameter.
		info.line.animLengths = [];
		AssertEx( info.line.animSpeeds.size == info.line.anims.size, "level._interactive[ \""+info.name+"\" ]: line.animSpeeds must have same number of entries as line.anims" );
		for ( i = 0; i < info.line.animSpeeds.size; i++ )
		{
			/# 
			if ( i != 0 )
				AssertEx( info.line.animSpeeds[ i ] > info.line.animSpeeds[ i-1 ], "level._interactive[ \""+info.name+"\" ]: line.animSpeeds["+i+"] must be greater than ["+(i-1)+"].");
			#/
			info.line.animLengths[ i ] = GetAnimLength( info.line.anims[ i ] );
		}
	
		// Now spawn a thread for each sardine school in the level
		schools								   = GetEntArray( info.targetname, "targetname" );
		foreach ( school in schools )
		{
			if ( school.model == "sardines_ball_radiant" )
			{
				school thread sardines_ball( info );
			}
			else
			{
				school thread sardines_line( info );
			}
		}
	}
}

sardines_line( info )
{
	self endon( "death" );
	self HideAllParts();

	// Find the path to follow
	// There are two supported techniques.  Either the node shares an origin, or it's targeted.
	check_nodes = [];
	if ( IsDefined( self.target ) )
		check_nodes = GetVehicleNodeArray( self.target, "targetname" );
	if (check_nodes.size >= 1 )
	{
		start_node = getClosest( self.origin, check_nodes );
	}
	else
	{
		check_nodes = GetVehicleNodeArray( "fish_path", "script_noteworthy" );
		start_node = undefined;
		foreach ( check_node in check_nodes )
		{
			if ( Distance( check_node.origin, self.origin ) < 1 )
			{
				start_node = check_node;
				break;
			}
		}
	}
	AssertEx( IsDefined( start_node ), "sardines_line: sardines_line_radiant at "+self.origin+" needs a vehicle path at the same origin." );
	pathnodes = cspline_findPathnodes( start_node );
	self.path = cspline_makePath( pathnodes, true );
	pathLength = cspline_length( self.path );
	/#
		thread cspline_test( self.path );
	#/
	
	// Space the pieces evenly along the path, so that whenever we remove one from the end we can immediately recycle it at the start.
	pathTime = cspline_time( self.path );
	numPieces = Int ( ( pathTime / info.line.spacing ) + 0.5 );
	self.spacing = pathTime / numPieces;
	if ( IsDefined( self.interactive_number ) )
		self.numPieces = int ( min( numPieces, self.interactive_number ) );
	else
		self.numPieces = numPieces;
	self sardines_lineMonitorTriggers( info );
}

sardines_lineMonitorTriggers( info )
{	
	onTriggers = undefined;
	if ( IsDefined( self.target ) )
		onTriggers = GetEntArray( self.target, "targetname" );
	instant = 0;
	if ( isDefined( onTriggers ) && ( onTriggers.size > 0 ) )
	{
	    triggerNames = [];
	    foreach ( trigger in onTriggers )
	    {
	    	if ( !IsDefined( trigger.script_triggername ) )
	    	{
	    		trigger.script_triggername = "start";
	    	}
	    	Assert (	trigger.script_triggername == "start" || 
	    		    	trigger.script_triggername == "start_instant" || 
	    		    	trigger.script_triggername == "stop" || 
	    		    	trigger.script_triggername == "stop_instant" );

/*	    	if ( isDefined( trigger.script_triggername ) )
	    	{
	    		if (	trigger.script_triggername == "start" || 
	    		    	trigger.script_triggername == "start_instant" || 
	    		    	trigger.script_triggername == "stop" || 
	    		    	trigger.script_triggername == "stop_instant"
	    		   )
		    	{
*/	    			/#
	    			if ( trigger.classname == "trigger_use" )
	    			{
	    				// Assume it's for testing purposes
		    			trigger UseTriggerRequireLookAt();  
						trigger SetCursorHint( "HINT_ACTIVATE" );  
						trigger SetHintString( &"PLATFORM_HOLD_TO_USE" ); 
				    	Print3d( trigger.origin, trigger.script_triggername, (1,1,1), 1, 0.5, 10000 );
	    			}
	    			#/
			    	trigger thread waittill_notify ( "trigger", self, trigger.script_triggername, undefined, true );
//		    	}
//	    	}
	    }
	}	
	// Even if there aren't any triggers, wait to be notified.  I think I can assume that in the real game, every school needs to be explicitly triggered.
	self.startStopState = "stopped";
    while(1)
    {
		instant = 0;
	    triggerMsg = self waittill_any_return( "start", "start_instant", "stop", "stop_instant" );
	    if ( self.startStopState == "stopped" && ( triggerMsg == "start" || triggerMsg == "start_instant" ) )
		{
			self.startStopState = triggerMsg;
			self thread sardines_lineThinkLoop(  info, self.interactive_number );
		}
		else 
			self.startStopState = triggerMsg;
    }
/*	}
	else
	{
		instant = 1;
		self.startStopState = "start";
		self thread sardines_lineThinkLoop( info, self.interactive_number );
	}
*/}

/*
=============
///ScriptDocBegin
"Name: sardines_lineThinkLoop( <instant> , <numberOfFish> )"
"Summary: Start (then continue) moving sardines along a line. Uses the entity's self.startStopState variable to receive ongoing instructions."
"Module: Entity"
"CallOn: An interactive_sardines entity that has been set up by sardines_line()"
"OptionalArg: <numberOfFish>: Total number of fish entities that will swim along the line.  Undefined makes the line last forever."
"Example: self sardines_lineThinkLoop( self.interactive_number );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

sardines_lineThinkLoop( info, numberOfFishTotal )
{	
	numberOfFishToSpawn = numberOfFishTotal;
	self.numberOfFishInExistence = 0;
	pathTime = cspline_time( self.path );
	startOrigin = cspline_getPointAtTime( self.path, 0 );
	startAngles = VectorToAngles( startOrigin["vel"] );
	startOrigin = startOrigin[ "pos" ];
	
	self sardines_lineSpawnPieces( info );
	
	// First handle starting. (We now only support starting from a "stopped" state, ie when there are currently no fish swimming the path.)
	if ( self.startStopState == "start_instant" )
	{
		if ( IsDefined( numberOfFishToSpawn ) )
			currentDist  = self.spacing * numberOfFishTotal;
		else
			currentDist = self.spacing * self.numPieces;
		self.startStopState = "started";
		foreach ( piece in self.pieces )
		{
			if ( !IsDefined( numberOfFishToSpawn ) || ( numberOfFishToSpawn > 0 ) )
			{
				piece ShowAllParts();
				self.numberOfFishInExistence ++;
				piece.visible = true;
				piece sardines_lineAttachModelsAndTaperEnds( info, self.numberOfFishInExistence, numberOfFishToSpawn );
				currentDist -= self.spacing;
				piece.distance = currentDist;
				if ( IsDefined( numberOfFishToSpawn ) ) numberOfFishToSpawn --;
			}
		}
	}
	else Assert( self.startStopState == "start" );	// This fn can only be called with "start" or "start_instant"
	self.startStopState = "started";
	
	while ( !isDefined( numberOfFishToSpawn ) || numberOfFishToSpawn > 0 || self.numberOfFishInExistence > 0 )
	{
		// Handle stopping.
		if ( ( self.startStopState == "stop" ) && ( !IsDefined( numberOfFishToSpawn ) || ( numberOfFishToSpawn > info.Line.taper ) ) )
		{
			numberOfFishToSpawn = info.Line.taper;	// Make a few more to get the taper at the end of the line.
		}
		else if ( self.startStopState == "stop_instant" )
		{
			break;
		}
		
		// Now move all the bits of fish along the line
		for( pieceNum = self.pieces.size-1; pieceNum >= 0; pieceNum-- )
		{
			piece = self.pieces[ pieceNum ];
			if ( piece.distance == 0 ) 	// ie It's just been hidden and moved back to the start.
			{
				if ( !IsDefined( numberOfFishToSpawn ) || ( numberOfFishToSpawn > 0 ) )
				{
					piece ShowAllParts();
					self.numberOfFishInExistence++;
					piece.visible = true;
					piece sardines_lineAttachModelsAndTaperEnds( info, self.numberOfFishInExistence, numberOfFishToSpawn );
				}
				if ( IsDefined( numberOfFishToSpawn ) ) numberOfFishToSpawn --;	// Decrement it even when it gets below 0, so we know when to stop running the update loop.
			}
			piece.distance += 1;
			animBlendTime = undefined;
			if ( piece.distance > pathTime ) 
			{
				piece.distance = 0;
				piece.animOffset = self.pieces[ wrap( pieceNum + 1, self.pieces.size ) ].animOffset - info.line.animOffset;
				piece.animOffset = ( piece.animOffset + 1 ) - Int( piece.animOffset + 1 );	// Wrap it to the range 0-1.
				for ( animNum=0; animNum<info.line.anims.size; animNum++ )
					piece SetAnimTime( info.line.anims[ animNum ], piece.animOffset );
				piece sardines_pieceSetModelsFromArray( info, info.line.tagmodels, undefined );	// Detach all the fish models
//				piece HideAllParts();
				if ( piece.visible )
					self.numberOfFishInExistence--;
				piece.visible = false;
				animBlendTime = 0;
			}
			if ( piece.visible )
			{
				posVel = cspline_getPointAtTime( self.path, piece.distance );
				piece.origin = posVel[ "pos" ] + (0,0,piece.offset);
				angles = VectorToAngles( posVel["vel"] );
				piece.angles = angles;
				piece blendAnimsBySpeed( posVel[ "speed" ] * piece.speedForAnimMult, info.line.anims, info.line.animSpeeds, info.line.animLengths, animBlendTime );
			}
			else
			{
				piece.origin = startOrigin;
				piece.angles = startAngles;
			}
		}
		wait 0.05;
	}
	self sardines_lineDeletePieces();
	self.startStopState = "stopped";
//	self notify( "stopped" );
}

sardines_lineAttachModelsAndTaperEnds( info, numFromStart, numFromFinish )
{
	// Attach fish to the pieces, with less fish on the end pieces so the school gets tapered ends.
	// Taper the ends of the school
	if ( IsDefined( numFromFinish ) )
		numFromEitherEnd = min ( numFromStart, numFromFinish );
	else 
		numFromEitherEnd = numFromStart;
	if ( numFromEitherEnd < info.Line.taper )
	{
		if ( numFromEitherEnd==2 )	// Hide the second piece from the end, so we have a single outlier.
		{
			self.speedForAnimMult = 1;
			self sardines_pieceSetModelsFromArray( info, info.Line.tagmodels, undefined );	// Detach all the fish models
		}
		else		// Thin the piece out based on its distance from the end.
		{
			self.speedForAnimMult = 4 - ( 3 * numFromEitherEnd / info.Line.taper );	// Gives a range of 4 to almost 1
			newThicknessOffset = -4 + ( 4 * numFromEitherEnd / info.Line.taper );		// Gives a range of -4 to almost 0
			self sardines_pieceSetModelsFromArray( info, info.Line.tagmodels, "bright", newThicknessOffset );
		}
	}
	else
	{
		self.speedForAnimMult = 1;
		self sardines_pieceSetModelsFromArray( info, info.Line.tagmodels, "bright", 0 );
	}
}

sardines_lineSpawnPieces( info )	// Note: Contains a waitframe!
{
	if ( !isDefined( self.pieces ) )
	{
		/#
			self thread sardines_lineDebugDrawStats();
		#/
		currentDist = Int( 1 + cspline_time( self.path ) ); // Line them up at the end of the path so they'll immediately get wrapped back to the start.
		self.pieces = [];
		for ( pieceNum = 0; pieceNum < self.numPieces; pieceNum++ )
		{
			self.pieces[ pieceNum ]	= Spawn( "script_model", self.origin );
			piece = self.pieces[ pieceNum ];
			piece.pieceNum = pieceNum;
			piece SetModel( info.piece.model );
			piece UseAnimTree( info.piece.animtree );
			piece SetAnim( info.line.anim_base, 1, 0.1, 1 );
			for ( animNum=0; animNum<info.line.anims.size; animNum++ )
				piece SetAnim( info.line.anims[ animNum ], 0.01, 0.1, 0 );
			// Offset the pieces vertically to make the line more interesting.
			if ( pieceNum == 0 ) {
				prevOffset = 0;
				prev2Offset = 0;
			} else { 
				prevOffset = self.pieces[ pieceNum-1 ].offset;
				if ( pieceNum > 1 ) {
					prev2Offset = self.pieces[ pieceNum-2 ].offset;
				} else {
					prev2Offset = 0;
				}
			}
			if ( pieceNum == self.numPieces - 1 ) {
				piece.offset = 0.5 * ( prevOffset + self.pieces[ 0 ].offset );
			} else {
				piece.offset = 0.85 * ( RandomFloatRange( -18, 18 ) + ( 1.5 * prevOffset ) - ( 0.5 * prev2Offset ) );
			}
			piece.distance = currentDist;
			currentDist -= self.spacing;
		}
		self.pieces[ 0 ].distance = 0;	// Wrap the first piece back to the start, ready to go.
		waitframe();	// Because SetAnimTime doesn't work in the same frame as SetAnim.
		for( pieceNum = 0; pieceNum < self.numPieces; pieceNum++ )
		{
			piece = self.pieces[ pieceNum ];
			piece.animOffset = pieceNum * info.line.animOffset;
			animTime = piece.animOffset + ( piece.distance / 20 );
			animTime -= Int( animTime );
			for ( animNum=0; animNum<info.line.anims.size; animNum++ )
				piece SetAnimTime( info.line.anims[ animNum ], animTime );
//			piece HideAllParts();
			piece.visible = false;
		}
	}
}

sardines_lineDeletePieces()
{
	foreach ( piece in self.pieces )
	{
		piece Delete();
	}
	self.pieces = undefined;
}

sardines_lineDebugDrawStats()
{
	/#
		self notify( "stop sardines_lineDebugDrawStats" );
		self endon( "stop sardines_lineDebugDrawStats" );
		self endon( "death" );
		self endon ( "deleted" );	// TODO: Confirm that this works.
		
		hsArray = cspline_getNodes( self.path );
		size = 12;
		for (;;)
		{
			if ( GetDebugDvarInt( "interactives_debug" ) )
			{
				Print3d( hsArray[ 0 ][ "pos" ] + ( 0, 0, 2*size ), "Sardines line" , 						( 1, 0, 0 ), 1, 1, 4 );
				Print3d( hsArray[ 0 ][ "pos" ] + ( 0, 0,   size ), ( self.numPieces + " models" ) ,			( 1, 0, 0 ), 1, 1, 4 );
				Print3d( hsArray[ 0 ][ "pos" ]					 , self.startStopState,						( 1, 0, 0 ), 1, 1, 4 );
				Print3d( hsArray[ 0 ][ "pos" ] - ( 0, 0,   size ), self.numberOfFishInExistence + " fish",	( 1, 0, 0 ), 1, 1, 4 );
				if ( IsDefined( self.pieces ) ) {
					foreach ( piece in self.pieces )
					{
						posVel = cspline_getPointAtTime( self.path, piece.distance );
						pieceOrigin = posVel[ "pos" ] + (0,0,piece.offset);
						Print3d( pieceOrigin						, piece.pieceNum			,	( 1, 0, 0 ), 1, 1, 3 );
					}
				}
			}
			wait 0.2;
		}
	#/
}

sardines_ball( info )
{
	self endon( "death" );
	
/*
 * Testing animation blending:
 * 
	self SetModel( info.piece.model );
	self UseAnimTree( info.piece.animtree );
	self.fish_model = [];
	self thread sardines_pieceSetModels( info.fish.model[ 0 ][ "bright" ], info.ball.numTags, 0 );
	n = 0;
	self SetAnimKnob( info.piece.anims[ "idle_loop" ], 1, 1, 0 );
	self SetAnim( info.piece.anims[ "add_rotate_right_child" ] );
	self SetAnim( info.piece.anims[ "add_rotate_left_child" ] );
	while (1)
	{
		// Testing rotate
		n = wrap ( n+5, 360 );
		yawAnimVal = clampAndNormalize( n, 180, 0 );
		self SetAnim( info.piece.anims[ "add_rotate_right" ], yawAnimVal );
		yawAnimVal = clampAndNormalize( n, 180, 360 );
		self SetAnim( info.piece.anims[ "add_rotate_left" ], yawAnimVal );
		wait( 0.1 );
		// OR Testing how additive animations interact
		self SetAnimKnob( info.piece.anims[ "idle_loop" ], 1, 1, 0 );
		wait( 1 );
		self SetAnim( info.piece.anims[ "add_tilt_left_child" ], 1, 1 );
		wait( 1 );
		self SetAnim( info.piece.anims[ "add_tilt_left_child" ], 0, 1 );
		wait( 1 );
		// POP! As the leaf node animation reaches weight 0 while its "additive" parent is still weight 1.  Super annoying.  
		self SetAnim( info.piece.anims[ "add_tilt_right_child" ], 1, 1 );
		wait( 1 );
	}
*/	

	self SetModel( "tag_origin" );
	self.origin += (0,0,32);
	self.pieces = [];
	self.rotationSpeed = 360 / ( 20 * info.ball.rotationPeriod );
	self.locations = [];
	self.locations[0] = self.origin;
	self.currectLocIndex = 0;
	nextLocTarget = getstruct_delete( self.target, "targetname" );
	if ( !IsDefined( nextLocTarget ) )
	{
		self.locations[1] = self.origin + (-800,0,0);
	}	
	else while ( IsDefined( nextLocTarget ) )
	{
		self.locations[ self.locations.size ] = nextLocTarget.origin + (0,0,32);
		if (IsDefined( nextLocTarget.target ) )
			nextLocTarget = GetEnt( nextLocTarget.target, "targetname" );
		else
			nextLocTarget = undefined;
	}
	
	pieceNum = 0;
	self.rings = [];
	for ( ring	= 0; ring < info.ball.rings.size; ring++ )
	{
		self.rings[ring] = [];
		for ( i=0; i < info.ball.rings[ring].numPieces; i++ )
		{
			self.pieces[ pieceNum ]	= Spawn( "script_model", self.origin );
			self.rings[ring][i] = pieceNum;
			self.pieces[ pieceNum ].ball_ring = ring;
			self.pieces[ pieceNum ].ball_angle = i * 360 / info.ball.rings[ring].numPieces;
			self.pieces[ pieceNum ].ball_offset = info.ball.rings[ring].offset;
			self.pieces[ pieceNum ].ball_i = i;
			self.pieces[ pieceNum ].ball_inplace = true;
			
			self.pieces[ pieceNum ] SetModel( info.piece.model );
			self.pieces[ pieceNum ] sardines_ballLinkPiece( self, self.pieces[ pieceNum ].ball_angle, info.ball.rings[ring].radius, info.ball.rings[ring].offset );

			//self.pieces[ pieceNum ] HideAllParts();
			self.pieces[ pieceNum ] UseAnimTree( info.piece.animtree );
			self.pieces[ pieceNum ] SetAnimKnob( info.piece.anims[ "idle_loop" ], 1, 0.1, 1 );
			self.pieces[ pieceNum ] SetAnimKnob( info.piece.anims[ "add_bend_left" ], 1, 0.1, 1 );
			self.pieces[ pieceNum ] SetAnim( info.piece.anims[ "add_tilt_left_child" ] );
			self.pieces[ pieceNum ] SetAnim( info.piece.anims[ "add_tilt_right_child" ] );
			tiltVal = clampAndNormalize( self.pieces[ pieceNum ].ball_offset, 0, info.ball.ringVertOffset );
			self.pieces[ pieceNum ] SetAnim( info.piece.anims[ "add_tilt_left" ], tiltVal, 0.1, 1 );
			tiltVal = clampAndNormalize( self.pieces[ pieceNum ].ball_offset, 0, -1*info.ball.ringVertOffset );
			self.pieces[ pieceNum ] SetAnim( info.piece.anims[ "add_tilt_right" ], tiltVal, 0.1, 1 );
			self.pieces[ pieceNum ] SetAnimLimited( info.piece.anims[ "add_rotate_left_child" ] );
			self.pieces[ pieceNum ] SetAnimLimited( info.piece.anims[ "add_rotate_right_child" ] );

			self.pieces[ pieceNum ] SetAnim( info.fish.anims[ "idle_loop" ], 1, 0.1, 1 );		
			fish_model = 	info.fish.model[2]["grey2"];
			if ( ( ring == 1 ) || ( ring == 3 ) ){
				fish_model = 	info.fish.model[2]["bright"];
			}
			self.pieces[ pieceNum ].fish_model = [];	// Need to keep a record of what is on every tag so I can remove it without causing errors.
			self.pieces[ pieceNum ] thread sardines_pieceSetModels( fish_model, info.ball.numTags, info.piece.tagPrefix, 0 );
			pieceNum++;
		}
		self.rings_isSpread[ ring ] = false;
	}
	
	waitframe();
	for ( i = 0; i < self.pieces.size; i++ )
	{
		startTime = i * 5 / 24;
		startTime -= Int( startTime );
		self.pieces[ i ] SetAnimTime( info.piece.anims[ "idle_loop" ], startTime );
//		for ( a=0; a<info.Line.anims.size; a++ )
//			self.pieces[ i ] SetAnimTime( info.Line.anims[ a ], startTime );
	}
	angle = 0;
	
	while(1)
	{
		self thread sardines_ballRotate( info );
		wait( 2 );	// Just in case every point the ball can travel to is dangerous (eg has a player at it), wait a second to prevent fast oscillation.
		self thread sardines_detectPeople( info.ball.reactDistance, info.ball.panicDistance, info.ball.driftSpeed, info.ball.maxDriftDist, "detectPeople" );
		self waittill( "detectPeople" );
		self notify( "stop_ballRotate" );
		// Relocate
		self.currectLocIndex = wrap( self.currectLocIndex + 1, self.locations.size );
		finalDestination = self.locations[ self.currectLocIndex ];
		/#
		if ( GetDebugDvarInt( "interactives_debug" ) )
		{
			Print3d( self.origin, "Panicking!" , ( 1, 0, 0 ), 1, 1, 20 );
			thread draw_arrow_time( self.origin,finalDestination, (1,0,0), 1 );
		}
		#/
		
		self sardines_ballPanic ( info, finalDestination-self.origin, self.intruderOrigin - self.origin, info.ball.relocateSpeed );
		waitframe();
	}
}

sardines_pieceSetModels( new_model, numTags, tagPrefix, time )
{
	self endon( "death" );
	self notify( "sardines_pieceSetModels_starting" );
	self endon( "sardines_pieceSetModels_starting" );
	timePerTag = time / numTags;
	for ( tag = 1; tag <= numTags; tag++)
	{
		if ( IsDefined( self.fish_model[tag] ) ){
			self Detach( self.fish_model[tag], ( tagPrefix + tag ) );
		}
		self Attach( new_model, ( tagPrefix + tag ) );
		self.fish_model[tag] = new_model;
		wait ( timePerTag );
	}
}

// Detach and reaatach models according to the special array setup in the level._interactive["sardines"] array.  Messy, but it does work.
sardines_pieceSetModelsFromArray( info, array, newBrightness, newThicknessOffset, time )
{
	Assert( IsDefined( self.brightness ) == IsDefined( self.thicknessOffset ) );	// Both defined or both undefined.
	
	if ( !IsDefined( newBrightness ) )	// Undefined newBrightness means detach all.
	{	
		// Detach all models and set variables appropriately.
		self DetachAll();
		self.brightness = undefined;
		self.thicknessOffset = undefined;
		return;
	}
	
	if ( !isDefined( newThicknessOffset ) ) newThicknessOffset = 0;
	self endon ( "death" );
	if ( !isDefined( time ) ) time = 0;
	timePerTag = time / array.size;
	
	tags = GetArrayKeys( array );
	pseudoRandom = self.pieceNum / 10;	// pseudoRandom is a sequence of numbers between 0 and 1, used to get a little variablity from the thickness offsets.
	foreach ( tag in tags ) {
		pseudoRandom = ( ( pseudoRandom + 0.1 )* 6 );
		pseudoRandom -= Int( pseudoRandom );
		if ( IsDefined( self.brightness ) ) {
			oldModelIndex = Int( array[tag] + self.thicknessOffset + ( 2 * pseudoRandom - 1 ) );
			if ( oldModelIndex >= info.fish.model.size ) oldModelIndex = info.fish.model.size - 1;
			if ( oldModelIndex >= 0 ) {
				if ( isDefined( info.fish.model[ oldModelIndex ] ) ) {
					self Detach( info.fish.model[ oldModelIndex ][ self.brightness ], ( info.piece.tagPrefix + tag ) );
				}
			}
		}
		
		newModelIndex = Int( array[tag] + newThicknessOffset + ( 2 * pseudoRandom - 1 ) );
		if ( newModelIndex >= info.fish.model.size ) newModelIndex = info.fish.model.size - 1;
		if ( newModelIndex >= 0 ) {
			if ( isDefined( info.fish.model[ newModelIndex ] ) ) {
				self Attach( info.fish.model[ newModelIndex ][ newBrightness ], ( info.piece.tagPrefix + tag ) );
			}
			wait ( timePerTag );
		}
	}
	self.brightness = newBrightness;
	self.thicknessOffset = newThicknessOffset;
}

sardines_ballRotate( info )
{
	self endon( "death" );
	self endon( "stop_ballRotate" );
	angle = self.angles[1];
	while(1)
	{
		angle += self.rotationSpeed;
		if ( angle > 360 ) angle -= 360;
		self.angles = ( 0, angle, 0 );
		
		for ( ring=0; ring < info.ball.rings.size ; ring++ )
		{
			if ( !self.rings_isSpread[ ring ] )
				self.rings_isSpread[ ring ] = sardines_spreadRing( info, self, ring );
		}
		/#
			if ( GetDebugDvarInt( "interactives_debug" ) )
			{
				drawCross( self.origin, 20, (0,1,1), 0.05 );
				foreach ( piece in self.pieces )
				{
					if ( IsDefined( piece.ball_angle ) )
					{
						lineAngle = piece.ball_angle;
						lineLength = info.ball.rings[piece.ball_ring].radius;
						lineHeight = piece.ball_offset;
						if ( piece.ball_inplace ) lineColor = (0,1,1);
						else lineColor = (1,1,0);
						forward = AnglesToRight( self.angles + (0,lineAngle,0) );
						thread draw_line_for_time( self.origin + (0,0,lineHeight), self.origin + (0,0,lineHeight) + (lineLength*forward), lineColor[0], lineColor[1], lineColor[2], 0.05 );
					}
				}
			}
		#/
		waitframe();
	}
}

// Panic
// Send all the fish away from the ball to intermediate points and on to the new location of the ball.
sardines_ballPanic( info, destVec, intruderVec, speed )
{
	prof_begin("sardines_ballPanic");
	// Find out current velocity, and remove the pieces from whatever was moving them before.
	currentVels = [];
	for ( i = 0; i < self.pieces.size; i++ )
	{
		piece = self.pieces[ i ];
		if ( IsDefined( piece.ball_ring ) && ( piece.ball_inplace ) )	// ie, if this piece is circling the ball
		{
			pieceAngle = piece.ball_angle + self.angles[1];
			velF	   = Cos( pieceAngle );
			velR	   = Sin( pieceAngle );
			currentVels[i]   = ( velF, velR, 0 );
			currentVels[i]  *= ( self.rotationSpeed * 3.14159 / 180 ) * info.ball.rings[ piece.ball_ring ].radius;
			piece Unlink();
			piece thread sardines_pieceSetModels( info.fish.model[2]["bright"], info.ball.numTags, info.piece.tagPrefix, 0.2 );
		}
		else
		{
			// It's not circling the ball, so it's on a path.
			AssertEx ( isDefined( piece.path ), "Interactive sardines: ball is relocating and piece "+i+" is neither on the ball or on a path!" );
			piece notify( "stop_path" );
			posVel = cspline_getPointAtTime( piece.path, piece.path_distance );
			currentVels[i] = posVel[ "vel" ] * piece.speed;
			anglesToPiece = VectorToAngles( piece.origin - self.origin );
			piece.ball_angle = anglesToPiece[1] + 90;
		}
	}	
	
	// Now decide where to send the pieces.
	// Generally speaking, the pieces will split into two groups, each of which will take a different path to the new ball location.
	// The pieces each swim to one of two intermediate locations and then move as two groups to the new location of the ball.
	intrAngles = VectorToAngles( intruderVec );
	intruderVec = ( intruderVec[0], intruderVec[1], 0 );
	intruderDir = VectorNormalize( intruderVec );
	destDist = Length( destVec );
	destDir = destVec / destDist;
	destLeft = ( -1*destDir[1], destDir[0], destDir[2] );
	endPointBase = self.origin + ( destDir * ( destDist - 150 ) ) - ( destLeft * 64 );
	groups[0] = SpawnStruct();
	groups[1] = SpawnStruct();
	groups[0].pieces = [];
	groups[1].pieces = [];
	groups[0].currentVels = [];
	groups[1].currentVels = [];
	groups[0].endVel = undefined;	// These are not always defined.
	groups[1].endVel = undefined;
	// Find out which direction the dest is in, relative to the intruder
	destAngles = VectorToAngles(destVec);
	destYaw = AngleClamp180( destAngles[1] - intrAngles[1] );
	if ( destYaw > 90 || destYaw < -90 )//( !isForward )
	{
		// The dest is behind the school, away from the intruder.  
		// Group 0: All the fish on the side furthest from the dest (nearest the intruder) will continue in their current direction and then spiral out to the dest.
		// Group 1: All the fish on the side nearest the dest will wheel around and swim back to the dest.
		groups[0].midPoint = self.origin - ( 100 * destLeft ) - ( 100 * destDir ) - (0,0,100);
		groups[0].midVel   = ( destDir - destLeft - (0,0,1) ) / 1.732;
		groups[0].endPoint = endPointBase - ( destLeft * 50 );
		groups[1].midPoint = self.origin + ( 100 * destLeft ) + ( 100 * destDir ) + (0,0,100);
		groups[1].midVel   = ( ( 2 * destDir ) - destLeft + (0,0,1) ) / 2.45 ;	// sqrt(6)==2.45
		groups[1].endPoint = endPointBase + ( destLeft * 50 );
		for ( i = 0; i < self.pieces.size; i++ )
		{
			pieceAngle = AngleClamp180( self.pieces[i].ball_angle + self.angles[1] - destYaw );
			if ( pieceAngle < 0 )
			{
				groups[0].pieces[ groups[0].pieces.size ] = self.pieces[i];
				groups[0].currentVels[ groups[0].currentVels.size ] = currentVels[i];
			}
			else
			{
				groups[1].pieces[groups[1].pieces.size] = self.pieces[i];
				groups[1].currentVels[ groups[1].currentVels.size ] = currentVels[i];
			}
		}
		/#
		if ( GetDebugDvarInt( "interactives_debug" ) )
		{
			Print3d( self.origin - (0,0,15), "Goal away from intruder" , ( 1, 0, 0 ), 1, 1, 20 );
			thread draw_arrow_time( self.origin, groups[0].midPoint, (1,0.5,0), 1 );
			thread draw_arrow_time( self.origin, groups[0].midPoint, (1,0.5,0), 1 );
		}
		#/
	}
	else if ( destYaw > -90 && destYaw < 20 )//( isLeft )
	{
		// The dest is behind the intruder, straight or to the left (from the intruder's view).  
		// Group 0: All the fish on the front and right will swim around to the right of the intruder and behind him.  
		// Group 1: The fish on the back and left will continue the way they're going and on to the dest.	
		intrAngles -= self.angles;
		intruderLeft = ( -1*intruderDir[1], intruderDir[0], intruderDir[2] );	// Actually screen right.
		groups[0].midPoint = self.origin + ( intruderVec ) + ( 100 * intruderLeft ) + ( 20 * destLeft ) + (0,0,100);
		groups[0].midVel   = ( intruderDir + intruderLeft + (0,0,1) ) / 1.732;
		groups[0].endPoint = endPointBase + ( destLeft * 20 ) - (0,0,20);
		groups[0].endVel   = ( destDir - ( destLeft * 0.5 ) + (0,0,0.5) ) / 1.225;
		groups[1].midPoint = self.origin + ( 130 * intruderDir ) - ( 200 * intruderLeft ) - (0,0,100);
		groups[1].midVel  = ( intruderDir - (0,0,1) ) / 1.414;
		groups[1].endPoint = endPointBase - ( destLeft * 150 ) + (0,0,40);
		groups[1].endVel   = ( destDir + destLeft - (0,0,1) ) / 1.732;	// sqrt(3) = 1.732
		for ( i = 0; i < self.pieces.size; i++ )
		{
			pieceAngle = AngleClamp180( self.pieces[i].ball_angle - intrAngles[1] );
			// pieceAngle 0 is straight to the left.  pieceAngle > 0 is in front of the school, pieceAngle < 0 is behind.
			if ( ( pieceAngle > 45 ) || ( pieceAngle < -135 ) )
			{
				groups[0].pieces[ groups[0].pieces.size ] = self.pieces[i];
				groups[0].currentVels[ groups[0].currentVels.size ] = currentVels[i];
			}
			else
			{
				groups[1].pieces[groups[1].pieces.size] = self.pieces[i];
				groups[1].currentVels[ groups[1].currentVels.size ] = currentVels[i];
			}
		}
		/#
		if ( GetDebugDvarInt( "interactives_debug" ) )
		{
			Print3d( self.origin - (0,0,15), "Goal past intruder's left" , ( 1, 0, 0 ), 1, 1, 20 );
			thread draw_arrow_time( self.origin, groups[0].midPoint, (1,0.5,0), 1 );
			thread draw_arrow_time( self.origin, groups[0].midPoint, (1,0.5,0), 1 );
		}
		#/
	}
	else
	{
		// The dest is behind the intruder, to the right (from the intruder's view).
		// Group 1: All the fish on the front and left will continue the way they're going and on to the dest.
		// Group 2: All the fish on the back and right will wheel around away from the intruder and back to the dest.
		destDir = VectorNormalize( destVec );
		destLeft = ( -1*destDir[1], destDir[0], destDir[2] );	// Rotate 90 degrees counterclockwise
		groups[0].midPoint = self.origin + ( 20 * destLeft ) + ( 180 * destDir ) + (0,0,100);
		groups[0].midVel   = ( ( 2 * destDir ) + destLeft + (0,0,1) ) / 2.45 ;	// sqrt(6)==2.45
		groups[0].endPoint = endPointBase;
		groups[1].midPoint = self.origin + ( 150 * destLeft ) - (  60 * destDir ) - (0,0,100);
		groups[1].midVel   = ( ( 2 * destDir ) + destLeft - (0,0,1) ) / 2.45 ;	// sqrt(6)==2.45
		groups[1].endPoint = endPointBase - ( destDir * 50) + ( destLeft * 50 );
		intrAngles -= self.angles;
		for ( i = 0; i < self.pieces.size; i++ )
		{
			pieceAngle = AngleClamp180( self.pieces[i].ball_angle - intrAngles[1] );
			if ( ( pieceAngle > -45 ) && ( pieceAngle < 135 ) )
			{
				groups[0].pieces[ groups[0].pieces.size ] = self.pieces[i];
				groups[0].currentVels[ groups[0].currentVels.size ] = currentVels[i];
			}
			else
			{
				groups[1].pieces[groups[1].pieces.size] = self.pieces[i];
				groups[1].currentVels[ groups[1].currentVels.size ] = currentVels[i];
			}
		}
		/#
		if ( GetDebugDvarInt( "interactives_debug" ) )
		{
			Print3d( self.origin - (0,0,15), "Goal past intruder's right" , ( 1, 0, 0 ), 1, 1, 20 );
			thread draw_arrow_time( self.origin, groups[0].midPoint, (1,0.5,0), 1 );
			thread draw_arrow_time( self.origin, groups[1].midPoint, (1,0.5,0), 1 );
		}
		#/
	}
	foreach ( g in groups )
	{
		// Make paths from the points
		path2 = undefined;
		if ( destDist > 400 )
		{
			path2 = cspline_makePathToPoint( g.midPoint, g.endPoint, g.midVel, g.endVel );
		}
		paths = [];
		pathTimes = [];
		sort = [];
		for ( i = 0; i < g.pieces.size; i++ )
		{
			paths[i] = cspline_makePathToPoint(g.pieces[i].origin, g.midPoint, g.currentVels[i]/speed, g.midVel, true );
			pathTimes[i] = cspline_time( paths[i] );
			sort[i] = i;
			/#
			if ( GetDebugDvarInt( "interactives_debug" ) )
				thread draw_arrow_time( g.pieces[i].origin, g.pieces[i].origin + ( 30 * g.currentVels[i] / speed ), (0,1,1), 2 );
			#/	
		}
		// Sort the paths so the fish will swim along in a nice snaking stream
		spacing = info.line.spacing * speed;	// Spacing in frames
		sort = array_sortByArray( sort, pathTimes );
		// Slow them all down to evenly space the pieces
		fastestTime = 0;
		for ( n=0; n<sort.size; n++ )
		{
			i = sort[n];
			fastestTimePlus = fastestTime + ( spacing * i );
			if ( pathTimes[i] > fastestTimePlus )
				fastestTime += pathTimes[i] - fastestTimePlus;
		}
		fastestTime /= 2;	// Boon 21 Aug 2012 - trying to speed up the initial panic, quickly for a meeting.
		for ( n=0; n<sort.size; n++ )
		{
			i = sort[n];
			newPathTime = fastestTime + ( spacing * i );
			cspline_adjustTime( paths[i], newPathTime );
		}
		// We've figured out where every piece should go.  Now make them swim.
		for ( i = 0; i < g.pieces.size; i++ )
		{
			g.pieces[i] SetAnimKnob( info.Line.anim_base, 1, 0.3 );
			g.pieces[i] thread sardines_setPathAnimStartTimes( i, info.Line.anims );
			if ( ( i == 0 ) || ( i == g.pieces.size-1 ) )
				g.pieces[i] thread sardines_pieceSwimPath( info, paths[i], speed, undefined, path2, 3 );			
			else
				g.pieces[i] thread sardines_pieceSwimPath( info, paths[i], speed, undefined, path2 );	
			if ( IsDefined( g.pieces[i].ball_ring ) )
			{
				self.rings[ g.pieces[i].ball_ring ][ g.pieces[i].ball_i ] = undefined;
				g.pieces[i].ball_ring	 = undefined;
				g.pieces[i].ball_i		 = undefined;
				g.pieces[i].ball_angle	 = undefined;
				g.pieces[i].ball_offset  = undefined;
				g.pieces[i].ball_inplace = undefined;
			}
		}
	}
	
	// Move the ball
	self.origin = self.origin + destVec;
	
	for ( i = 0; i < self.pieces.size; i++ )
	{
		self.pieces[ i ] thread sardines_ballWaitThenAddPiece( info, self, i );
	}
	prof_end("sardines_ballPanic");
}

sardines_setPathAnimStartTimes( i, anims )
{
	self endon("death");
	self endon("stop_path");
	waitframe();
	startTime = i * 5 / 24;
	startTime -= Int( startTime );
	for ( i = 0; i < anims.size; i++ )
		self SetAnimTime( anims[ i ], startTime );
}

sardines_pieceSwimPath ( info, path, speed, school, path2, speedForAnimMult )
{
	if ( !IsDefined( speedForAnimMult ) ) speedForAnimMult = 1;
	self endon("death");
	self endon("stop_path");
	
	schoolBaseOrigin = undefined;
	if ( isDefined( school ) )	// Track the school's movement and adjust our position to follow it.
	{
		schoolBaseOrigin = school.origin;
	}
	self.path = path;
	self.path_distance = 0;
	pathLength = cspline_time( path );
	self.speed = pathLength / Int( ( pathLength / speed ) + 0.5 );	// Ensure we won't have a tiny amount of movement in the last frame.
	/#
		thread cspline_test( path, pathLength / ( self.speed * 20 ) );
	#/
	while (self.path_distance < ( pathLength - ( self.speed / 2 ) ) )	// -self.speed/2 for possible precision errors.
	{
		self.path_distance+=self.speed;
		if ( self.path_distance > pathLength ) self.path_distance = pathLength;
		posVel = cspline_getPointAtTime( path, self.path_distance );
		self.origin = posVel[ "pos" ];
		newAngles = VectorToAngles( posVel[ "vel" ] );
		angleDiff = newAngles - self.angles;
		angleDiff = ( AngleClamp180( angleDiff[0] ), AngleClamp180( angleDiff[1] ), 0 );
		angleChange = [];
		angleChange[0] = clamp( angleDiff[0], -1*info.piece.maxTurn, info.piece.maxTurn );
		angleChange[1] = clamp( angleDiff[1], -1*info.piece.maxTurn, info.piece.maxTurn );
		self.angles = self.angles + ( angleChange[0], angleChange[1], 0 );
		if ( isDefined( school ) )
		{
			self.origin += school.origin - schoolBaseOrigin;
			/#
			if ( GetDebugDvarInt( "interactives_debug" ) )
				thread draw_line_for_time ( posVel[ "pos" ], self.origin, 1, 1, 0, 0.05 );
			#/
			flatnessMult = ( pathLength - self.path_distance ) / ( self.speed * 5 );	// Flatten out over last 5 frames
			if ( flatnessMult < 1 )
			{
				yawDiff = angleDiff[1] - angleChange[1];
				blendedYaw = self.angles[1] + ( yawDiff * ( 1-flatnessMult ) );
				self.angles = ( AngleClamp180(self.angles[0])*flatnessMult, blendedYaw, 0 );
			}
		}
		yawDiff = AngleClamp180( self.angles[1] - newAngles[1] );
		yawAnimVal = clampAndNormalize( yawDiff, 0, -150 );
		self SetAnim( info.piece.anims[ "add_rotate_left" ], yawAnimVal, 0.05 );
		yawAnimVal = clampAndNormalize( yawDiff, 0, 150 );
		self SetAnim( info.piece.anims[ "add_rotate_right" ], yawAnimVal, 0.05 );
		self blendAnimsBySpeed( self.speed * posVel[ "speed" ] * speedForAnimMult, info.line.anims, info.line.animSpeeds, info.line.animLengths, 0.5 );
		waitframe();
	}
	if ( IsDefined( path2 ) )
	{
		self sardines_pieceSwimPath ( info, path2, speed, school, undefined, speedForAnimMult );
	}
	else
	{
		self notify( "path_complete" );
	}
}

sardines_ballWaitThenAddPiece ( info, school, pieceNum, speedForAnimMult )
{
	
	// The ball is made up of a number of pieces, each of which has a radius and an angle.
	// The pieces orbit the ball in rings.  We can have a certain number in each ring.  The inside ring fills up first.
	Assert(IsDefined(school.rotationSpeed));
	Assert(IsDefined(school.pieces[ pieceNum ]));
	Assert(IsDefined(school.pieces[ pieceNum ].speed));

	self endon( "death" );
	self endon( "stop_path" );
	self waittill( "path_complete" );
	
	// First find the distance to the point where the piece would ideally join the ball.
	spot = sardines_ballFindEmptySpot( info.ball.rings, school );
	self.ball_ring = spot.ring;
	self.ball_i = spot.i;
	circlingDistance = info.ball.rings[ self.ball_ring ].radius;
	horiz = self.origin - school.origin;
	self.ball_offset = horiz[2]/2;	// The piece will drift into vertical place after it joins the ball.
	self.ball_offset = clamp( self.ball_offset, -50,50);
	horiz = ( horiz[0], horiz[1], horiz[2]-self.ball_offset );
	distToCenterSq = LengthSquared( horiz );
	distRemaining = sqrt( distToCenterSq + ( circlingDistance * circlingDistance ) );
	// And the angle of that point (which is the same as the direction from the piece to the center)
	angsAtTangent = VectorToAngles( school.origin - self.origin );
	linkAngle = angsAtTangent[1];
	// Find out the actual coords of the point where we want to join the ball
	arrivalPoint = circlingDistance * AnglesToForward( ( 0, ( linkAngle - 90 ), 0 ) );
	arrivalPoint += school.origin + (0,0,self.ball_offset);
	// And the angle that represents on the ball now, given the relevative speeds
	timeToArrive = ( distRemaining / self.speed - 1 ) * 1.2;	// * 1.2 to allow for curvature.
	linkAngle -= (timeToArrive-1) * school.rotationSpeed;
	linkAngle -= school.angles[1];
	// And reserve our place in the selected ring
	school.rings[ self.ball_ring ][ self.ball_i ] = pieceNum;
	self.ball_angle = linkAngle;
	self.ball_inplace = false;
	sardines_sortRing( info.ball.rings[ self.ball_ring ], school, self.ball_ring );
	school.rings_isSpread[ self.ball_ring ] = false;
	/#
		if ( GetDebugDvarInt( "interactives_debug" ) )
			thread draw_arrow_time( school.origin, arrivalPoint, (0,1,1), 2 );
	#/		
	// Make a short cspline path that will get us there.
	Assert ( isDefined( self.path ) );
	posVel = cspline_getPointAtTime( self.path, self.path_distance );
	//posVel[ "vel" ] *= self.pieces[ pieceNum ].speed;
	angsAtTangent = ( angsAtTangent[0], angsAtTangent[1]+school.rotationSpeed, angsAtTangent[2] );
	arrivalVel = AnglesToForward( angsAtTangent );
	arrivalVel *= ( school.rotationSpeed * 3.14159 / 180 ) * circlingDistance;
	path = cspline_makePathToPoint( self.origin, arrivalPoint, posVel[ "vel" ], arrivalVel / self.speed );	
	cspline_adjustTime( path, timeToArrive*self.speed );
	/#
	if ( GetDebugDvarInt( "interactives_debug" ) )
	{
		thread draw_arrow_time( self.origin, self.origin + (posVel[ "vel" ]*20), (0,1,1), 1 );
		thread draw_arrow_time( arrivalPoint, arrivalPoint + (arrivalVel*20 / self.speed), (0,1,1), 1 );
	}
	#/		
	self SetAnimKnob( info.Line.anim_base );
	self thread sardines_pieceSwimPath( info, path, self.speed, school, undefined, speedForAnimMult );
	// Play the right animation
	roughTime = cspline_length( path ) / ( self.speed * 20 );
	self SetAnimKnob( info.piece.anims[ "idle_loop" ],     1, roughTime+0.5 );
	self SetAnim(     info.piece.anims[ "add_bend_left" ], 1, roughTime+0.5 );
	// And arrive
	self waittill( "path_complete" );
	self.ball_inplace = true;
	school.rings_isSpread[ self.ball_ring ] = false;	// If more than one piece arrives in a short time, they'll be all bunched up.
//	self SetAnimKnob( info.piece.anims[ "idle_loop"     ], 1, 0.1 );
//	self SetAnim(     info.piece.anims[ "add_bend_left" ], 1, 0.1, 1 );
	if ( ( self.ball_ring == 0 ) || ( self.ball_ring == 2 ) )
	{
		self thread sardines_pieceSetModels( info.fish.model[2]["grey1"], info.ball.numTags, info.piece.tagPrefix, 3 );
		self thread wait_then_fn( 3, "sardines_pieceSetModels_starting", ::sardines_pieceSetModels, info.fish.model[2]["grey2"], info.ball.numTags, info.piece.tagPrefix, 2 );
	}
	self sardines_ballLinkPiece( school, self.ball_angle, circlingDistance, self.ball_offset );
}

sardines_ballLinkPiece( school, angle, circlingDistance, offsetU )
{
	offsetF	   = circlingDistance * Sin( angle );
	offsetR	   = -1 * circlingDistance * Cos( angle );
	self LinkTo( school, "tag_origin", ( offsetF, offsetR, offsetU ), ( 0, angle, 0 ) );
}

sardines_detectPeople( reactRadius, panicRadius, driftSpeed, maxDriftDist, notifyStr )
{
	AssertEx( reactRadius > panicRadius, "Interactive sardines: Reaction radius must be greater than panic radius." );
	self endon( "death" );
	self endon( "damage" );
	self endon( notifyStr );
	
	triggerOffset = ( 0, 0, -1 * reactRadius );
	trigger = Spawn( "trigger_radius", self.origin + triggerOffset, 0, reactRadius, reactRadius*2 );
	self thread delete_on_notify( trigger, "death", "damage", notifyStr );
	
	baseOrigin = self.origin;
	safe = 1;
	atBase = 1;
	while( safe )
	{
		trigger waittill( "trigger", triggered_entity );
		if ( IsDefined( triggered_entity ) && IsPlayer( triggered_entity ) )
		{
			maxDriftDistSq = maxDriftDist * maxDriftDist;
			intruderClose = 1;
			while ( ( intruderClose || !atBase ) && safe )
			{
				self.intruderOrigin = triggered_entity.origin + (0, 0, 64);
				intruderVec = triggered_entity.origin - self.origin;
				intruderDistance = Length( intruderVec );
				if ( intruderDistance < reactRadius )
				{
					/#
					if ( GetDebugDvarInt( "interactives_debug" ) )
					{
						thread draw_line_for_time ( self.origin, self.intruderOrigin, 1, 0, 0, 0.05 );
						intruderAngles = VectorToAngles( intruderVec );
						Print3d( self.origin, intruderAngles[1], ( 1, 0, 0 ), 1, 1, 1 );
					}
					#/
					speedMult = ( reactRadius - intruderDistance ) / ( reactRadius - panicRadius );
					intruderDir = intruderVec / intruderDistance;
					self.origin = self.origin - ( speedMult * driftSpeed * intruderDir );
					trigger.origin = self.origin + triggerOffset;
					atBase = 0;
					if ( ( DistanceSquared(self.origin, baseOrigin) > maxDriftDistSq ) || ( intruderDistance < panicRadius ) )
					{
						safe = 0;	// Panic!
					}
					waitframe();
				}
				else
				{
					intruderClose = 0;
					self.intruderOrigin = undefined;
					baseDistance = Distance( self.origin, baseOrigin );
					/#
					if ( GetDebugDvarInt( "interactives_debug" ) )
						thread draw_line_for_time ( self.origin, baseOrigin, 0, 1, 0, 0.05 );
					#/
					if ( baseDistance > 1 )
					{
						dir = ( baseOrigin - self.origin ) / baseDistance;		
						self.origin += dir * 0.5;
						trigger.origin = self.origin + triggerOffset;
						waitframe();
						baseDistance = Distance( self.origin, baseOrigin );
					}
					else
					{
						atBase = 1;
					}
				}
			}	// while ( ( intruderClose || !home ) && safe )
		}
		else
		{
			/#
			if ( GetDebugDvarInt( "interactives_debug" ) )
				Print3d( self.origin, "Something weird is close!" , ( 1, 0, 0 ), 1, 1, 1 );
			#/
			waitframe();
		}
	}
    self notify( notifyStr );
}

sardines_ballFindEmptySpot( ringsInfo, school )
{
	returnVal = SpawnStruct();
	ring = 0;
	i = 0;
	found = 0;
	while ( ( ring < ringsInfo.size ) && ( !found ) )
	{
		i = 0;
		while ( ( i < ringsInfo[ ring ].numPieces ) && ( !found ) )
		{
			if ( !isDefined( school.rings[ ring ][ i ] ) )
			{
				found = true;
			}
			if ( !found )
				i++;
		}
		if ( !found )
			ring++;
	}
	returnVal.ring = ring;
	returnVal.i = i;
	return returnVal;
}

// Sorts the pieces in the ring by their angle.  Removes any undefined slots. Sets angles between 0 and 360.
sardines_sortRing( ringInfo, school, ring )
{
	pieceInds = [];
	angles = [];
	for ( i = 0; i < ringInfo.numPieces; i++ )
	{
		if ( isDefined( school.rings[ ring ][ i ] ) )
		{
			new_i = pieceInds.size;
			pieceInds[ new_i ] = school.rings[ ring ][ i ];
			angle = school.pieces[ school.rings[ ring ][ i ] ].ball_angle;
			school.pieces[ pieceInds[ new_i ] ].ball_angle = AngleClamp( angle );
			angles[ new_i ] = school.pieces[ pieceInds[ new_i ] ].ball_angle;
		}
	}
	school.rings[ ring ] = array_sortByArray( pieceInds, angles );
}

// Moves the pieces in the ring to prevent bunching.  After adding a piece, call this every frame until it returns true.
sardines_spreadRing( info, school, ringIndex )
{
	ring = school.rings[ ringIndex ];
	if ( ring.size == 0 ) return true;
	
	ringInfo = info.ball.rings[ringIndex];
	
	spread			   = true;
	maxDegreesPerFrame = 2;
	iMax			   = ring.size - 1;
	angleThreshold	   = ( 360 / ring.size ) - 5;
	forceStep1		   = [];
	forceStep2		   = [];
	forceStep3		   = [];
	movedVert		   = [];
	pieces			   = [];
	
	for ( i = 0; i <= iMax; i++ )
	{
		pieces[ i ] = school.pieces[ ring[ i ]];
	}
	for ( i = 0; i <= iMax; i++ )
	{
		forceStep1[ i ] = 0;
		forceStep2[ i ] = 0;
		forceStep3[ i ] = 0;
		myAngle	= pieces[ i ].ball_angle;
		prevAngle  = pieces[ wrap( i-1, ring.size ) ].ball_angle;
		prevAngle2 = pieces[ wrap( i-2, ring.size ) ].ball_angle;
		prevAngle3 = pieces[ wrap( i-3, ring.size ) ].ball_angle;
		if ( i == 0 ) prevAngle  -= 360;
		if ( i <= 1 ) prevAngle2 -= 360;
		if ( i <= 2 ) prevAngle3 -= 360;
		if ( myAngle - prevAngle < angleThreshold )
		{
			forceStep1[ i ]  = maxDegreesPerFrame * ( 1.01 - ( ( myAngle - prevAngle ) / angleThreshold ) );
			spread = false;
		}
		if ( ( myAngle - prevAngle2 < ( 2 * angleThreshold ) ) && ( pieces[ wrap( i-1, ring.size ) ].ball_inplace ) )
		{
			forceStep2[ i ]  += maxDegreesPerFrame * ( 1.01 - ( ( myAngle - prevAngle2 ) / ( angleThreshold * 2 ) ) );
			
			if ( ( myAngle - prevAngle2 < ( 3 * angleThreshold ) ) && ( pieces[ wrap( i-1, ring.size ) ].ball_inplace ) )
			{
				forceStep3[ i ]  += maxDegreesPerFrame * ( 1.01 - ( ( myAngle - prevAngle3 ) / ( angleThreshold * 3 ) ) );
			}
		}
		// And vertical offset
		if ( pieces[i].ball_offset != ringInfo.offset ) {
			if ( pieces[ i ].ball_inplace ) {
				move = ringInfo.offset - pieces[i].ball_offset;
				move = clamp( move, -1, 1 );
				pieces[i].ball_offset += move;
				movedVert[i] = true;
			}
			tiltVal = clampAndNormalize( pieces[i].ball_offset, 0, info.ball.ringVertOffset );
			pieces[i] SetAnimLimited( info.piece.anims[ "add_tilt_left" ], tiltVal, 0.1, 1 );
			tiltVal = clampAndNormalize( pieces[i].ball_offset, 0, -1 * info.ball.ringVertOffset );
			pieces[i] SetAnimLimited( info.piece.anims[ "add_tilt_right" ], tiltVal, 0.1, 1 );
			spread = false;
		}
	}
	if ( !spread )
	{
		needsSorting = false;
		for ( i = 0; i <= iMax; i++ )
		{
			if ( pieces[ i ].ball_inplace )	// Pieces that are not in place yet still push other pieces out of their way, but their arrival position doesn't get pushed.
			{
				forceTotal  = forceStep1[ i ]   + forceStep2[ i ]   + forceStep3[ i ];
				forceTotal  -= forceStep1[ wrap( i + 1, ring.size ) ] + forceStep2[ wrap( i + 2, ring.size ) ] + forceStep3[ wrap( i + 3, ring.size ) ];	
				forceTotal = clamp( forceTotal, -1 * maxDegreesPerFrame, maxDegreesPerFrame );
				if ( ( forceTotal != 0 ) || isDefined( movedVert[i] ) )
				{
					pieces[i].ball_angle += forceTotal;
					if ( ( pieces[i].ball_angle < 0 ) || ( pieces[i].ball_angle > 360 ) )
					{
						needsSorting = true;
					}
					pieces[i] sardines_ballLinkPiece( school, pieces[i].ball_angle, ringInfo.radius, pieces[i].ball_offset );
				}
			}
		}
		if ( needsSorting )
		{
			sardines_sortRing( ringInfo, school, ringIndex );
		}
	}
	return spread;
}