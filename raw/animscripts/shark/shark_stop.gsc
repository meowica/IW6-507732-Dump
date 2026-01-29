#using_animtree( "animals" );

main()
{
	self endon( "killanimscript" );

	self clearanim( %root, 0.1 );
	self clearanim( %shark_swim_f_2, 0.2 );

	while ( 1 )
	{
		self setflaggedanimrestart( "shark_idle", %shark_swim_f, 1, 0.2, self.animplaybackrate );
		animscripts\shared::DoNoteTracks( "shark_idle" );
	}
}