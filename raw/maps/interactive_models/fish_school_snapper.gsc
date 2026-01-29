#using_animtree( "animals" );

main()
{
	// Set up the once-off stuff
	info						= SpawnStruct();
	info.name					= "fish_school_snapper";
	info.targetname				= "interactive_fish_school_snapper";

	// A school of sardines is made up of a number of "pieces," each of which is a model with several tags.
	info.piece			 = SpawnStruct();
	info.piece.model	 = "sardines_flocking_rig";
	info.piece.tagPrefix = "tag_attach";
	info.piece.maxTurn	 = 5;	// Degrees per frame
	// Piece animations:
	info.piece.animtree	 = #animtree;
	info.piece.anims	 = [];
	info.piece.anims[ "idle_loop"				] = %sardines_flock_loop;
//	info.piece.anims[ "additive"				] = %sardines_additive;
	info.piece.anims[ "add_bend_left"			] = %sardines_flock_add_left60;
	info.piece.anims[ "add_bend_right"			] = %sardines_flock_add_right60;
	info.piece.anims[ "add_fast"				] = %sardines_flock_add_stretch_horiz;
	info.piece.anims[ "add_tilt_left"			] = %sardines_flock_add_tilt_left_add;
	info.piece.anims[ "add_tilt_right"			] = %sardines_flock_add_tilt_right_add;
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
	//info.fish.model[ 0 ][ "bright" ]	= "fish_emperorsnapper_rigid";	// If a model array entry is not defined, no model will be attached when that array index is chosen.
	info.fish.model[ 1 ][ "bright" ]	= "fish_emperorsnapper_rigid";	// Use a rigid one because I can't animate it anyway, and I was getting "exceeded maximum number of anim info" errors.
	info.fish.model[ 2 ][ "bright" ]	= "fish_emperorsnapper_rigid";
	info.fish.model[ 2 ][ "grey1"  ]	= "fish_emperorsnapper_rigid";
	info.fish.model[ 2 ][ "grey2"  ]	= "fish_emperorsnapper_rigid";
	info.fish.model[ 3 ][ "bright" ]	= "fish_emperorsnapper_rigid";
	info.fish.model[ 3 ][ "grey1"  ]	= "fish_emperorsnapper_rigid";
	info.fish.model[ 3 ][ "grey2"  ]	= "fish_emperorsnapper_rigid";
	info.fish.anims				   = [];	// nb The fish don't need their own animtree because they're attached to the piece.
	info.fish.anims[ "idle_loop" ] = %sardines_smallgroup_loop1;	// This doesn't work - can't play the animation on more than one attached model with the same joints.
	
	// One arrangement of a school of sardines is a swirling ball.
	info.ball					   = SpawnStruct();
	info.ball.rotationPeriod	   = 5;		// Seconds per revolution of the ball.
	info.ball.numTags			   = 16;	// Only 16 of the piece's tags are set up for the ball animation.
	// Parameters related to moving the ball when the player gets close
	info.ball.relocateSpeed		   = 30;	// Top speed of the fish when relocating, units per inch.
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

	// Another arrangement of a school of fish is a "line," which is a snaking trail of fish all swimming along a vehicle path.
	// Each piece is placed at distance "spacing" along the path from the previous.
	// Pieces in a path each play a "spin" animation that offsets their tags from the center and spirals them around.
	// Note that the line arrangement is also used by fish in balls, when they panic and relocate.
	info.Line					= SpawnStruct();
	info.Line.spacing			= 3;		// In time (frames), not distance.	Mult by speed (from node in Radiant) to get distance.
	info.Line.anims				= [];
	info.Line.anim_base			= %sardines_flock_spin;
	info.Line.anims[ 0 ]		= %sardines_flock_spinloop;
	info.Line.anims[ 1 ]		= %sardines_flock_spinloop_fast;
	info.Line.anims[ 2 ]		= %sardines_flock_spinloop_faster;
	info.Line.animSpeeds[ 0 ]	= 20 * 0.88; // School swimming speed at which to play this animation (not anim playback speed)
	info.Line.animSpeeds[ 1 ]	= 30 * 0.88; // in MPH (to match Radiant's vehicle nodes) * 0.88 converts to inches per frame.
	info.Line.animSpeeds[ 2 ]	= 60 * 0.88;
	info.Line.animOffset		= 7 / 25;	// Each piece will be this much further through the animation than the piece before it.
	info.Line.taper				= 8;		// Number of pieces to taper at the ends of the line.
	info.Line.tagmodels			= [];
	// These numbers are indices into the info.fish.model array above.
	info.Line.tagmodels[ "1"  ] = 5;	// Notes for these numbers:
	info.Line.tagmodels[ "4"  ] = 3;	// If a tagmodel array entry is not defined, no model will be attached to that tag.
	info.Line.tagmodels[ "7"  ] = 3;	// The lower the number, the more likely it will be reduced to 0 and hence will not
	info.Line.tagmodels[ "10" ] = 2;	// have a fish attached when the pieces is "tapered" near the ends of the school.
	info.Line.tagmodels[ "13" ] = 2;	// Non-integers are allowed, as are numbers outside the range of info.fish.model.
	info.Line.tagmodels[ "16" ] = 2;
	info.Line.tagmodels[ "19" ] = 1;
	info.Line.tagmodels[ "22" ] = 1;
	info.Line.tagmodels[ "25" ] = 1;
	info.Line.tagmodels[ "28" ] = 1;
	info.Line.tagmodels[ "31" ] = 1;
	// End of data.

	if ( !IsDefined ( level._interactive ) )
		level._interactive = [];
	level._interactive[ "fish_school_snapper" ] = info;
	
	thread maps\interactive_models\fish_school_sardines::sardines( info );
}