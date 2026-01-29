#include maps\_utility;
#include animscripts\shared;
#include animscripts\notetracks;
#include animscripts\utility;
#include common_scripts\utility;


#using_animtree( "animals" );

main()
{
	self endon( "killanimscript" );
	
	self clearanim( %root, 0.2 );
	self clearanim( %shark_swim_f, 0.2 );
	
	while ( 1 )
	{
		self moveLoop();

	}
}

moveLoop()
{
	self endon( "killanimscript" );
	self endon( "stop_soon" );

	self.moveLoopCleanupFunc = undefined;

	while ( 1 )
	{
		if ( self.disableArrivals )
			self.stopAnimDistSq = 0;
		else
			self.stopAnimDistSq = anim.dogStoppingDistSq;

		self moveLoopStep();
	}
}

moveLoopStep()
{
	self endon( "move_loop_restart" );
	
	self Shark_UpdateLeanAnim();
	self setflaggedanim( "shark_swim", %shark_swim_f_2, 1, 0.2, self.moveplaybackrate );
	DoNoteTracksForTime( 0.2, "shark_swim" );
}


Shark_UpdateLeanAnim()
{
	leanFrac = Clamp( self.leanAmount / 8.0, -1, 1 );
	if ( leanFrac > 0 )
	{
		self SetAnim( %shark_add_turn_l, leanFrac, 0.2, 1, true );
		self SetAnim( %shark_add_turn_r, 0.0, 0.2, 1, true );
	}
	else
	{
		self SetAnim( %shark_add_turn_l, 0.0, 0.2, 1, true );
		self SetAnim( %shark_add_turn_r, 0-leanFrac, 0.2, 1, true );
	}
}