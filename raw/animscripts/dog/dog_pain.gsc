#using_animtree( "dog" );

main()
{
	if ( isdefined( level.shark_functions ) )
	{
		if ( issubstr( self.model, "shark" ) )
		{
			self [[ level.shark_functions["pain"] ]]();
			return;
		}
	}
	
	self endon( "killanimscript" );

	if ( isdefined( self.enemy ) && isdefined( self.enemy.syncedMeleeTarget ) && self.enemy.syncedMeleeTarget == self && ( !isdefined( self.disablepain ) || !self.disablepain ) )
	{
		self unlink();
		self.enemy.syncedMeleeTarget = undefined;
	}

	self clearanim( %body, 0.2 );
	self setflaggedanimrestart( "dog_pain_anim", self GetDogPainAnim( "run_pain" ), 1, 0.2, 1 );

	self animscripts\shared::DoNoteTracks( "dog_pain_anim" );
}


GetDogPainAnim( a_Anim )
{
	assertEx( animscripts\animset::ArchetypeExists( "dog" ), "dog archetype uninitialized" );

	painAnim = animscripts\utility::LookupDogAnim( "reaction", a_Anim );

	assertEx( IsDefined( painAnim ), a_Anim + " is not a valid reaction animation for dogs." );

	return painAnim;
}


InitDogArchetype_Reaction()
{
	dogAnims = [];
	dogAnims[ "flash_long" ] = %german_shepherd_run_pain;
	dogAnims[ "flash_short" ] = %german_shepherd_run_flashbang_b;

	dogAnims[ "run_pain" ] = %german_shepherd_run_pain;

	anim.archetypes[ "dog" ][ "reaction" ] = dogAnims;
}