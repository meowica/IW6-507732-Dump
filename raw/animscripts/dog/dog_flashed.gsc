#include animscripts\Combat_utility;
#include animscripts\notetracks;
#include maps\_utility;

#using_animtree( "dog" );

main()
{
	if ( isdefined( level.shark_functions ) )
	{
		if ( issubstr( self.model, "shark" ) )
		{
			self [[ level.shark_functions["flashed"] ]]();
			return;
		}
	}
	
	self endon( "killanimscript" );
	self endon( "stop_flashbang_effect" );

	wait randomfloatrange( 0, 0.4 );

	self clearanim( %body, 0.1 );

	duration = self flashBangGetTimeLeftSec();

	if ( duration > 2 && randomint( 100 ) > 60 )
		self setflaggedanimrestart( "flashed_anim", self GetDogFlashedAnim( "flash_long" ), 1, 0.2, self.animplaybackrate * 0.75 );
	else
		self setflaggedanimrestart( "flashed_anim", self GetDogFlashedAnim( "flash_short" ), 1, 0.2, self.animplaybackrate );

	animLength = getanimlength( self GetDogFlashedAnim( "flash_short" ) ) * self.animplaybackrate;

	if ( duration < animLength )
		self DoNoteTracksForTime( duration, "flashed_anim" );
	else
		self animscripts\shared::DoNoteTracks( "flashed_anim" );

	self.flashed = false;
	self notify( "stop_flashbang_effect" );
}

GetDogFlashedAnim( a_Anim )
{
	assertEx( animscripts\animset::ArchetypeExists( "dog" ), "dog archetype uninitialized" );

	flashedAnim = animscripts\utility::LookupDogAnim( "reaction", a_Anim );

	assertEx( IsDefined( flashedAnim ), a_Anim + " is not a valid reaction animation for dogs." );

	return flashedAnim;
}