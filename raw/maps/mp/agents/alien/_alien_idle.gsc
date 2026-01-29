#include maps\mp\agents\_scriptedAgents;
#include common_scripts\utility;

MIN_IDLE_REPEAT_TIMES = 2;
IDLE_POSTURE_VOICE = "alien_voice";

main()
{
	self endon( "killanimscript" );
	
	while ( true )
	{
		self faceTarget();
		
		idleState = selectIdleAnimState();
		self ScrAgentSetAnimMode( "anim deltas" );
		self ScrAgentSetOrientMode( "face angle abs", self.angles );
		self PlayAnimNUntilNotetrack( idleState, undefined, "idle" );
	}
}

end_script()
{
	self.previousAnimState = "idle";
}

selectIdleAnimState()
{
	if ( isAlive( self.enemy ) )
	{
		// Possibly posture
		if ( cointoss() )
		{
			self PlaySound( IDLE_POSTURE_VOICE );
			return "idle_posture";
		}
	}	
	
	resultState = undefined;
	if ( !isDefined( self.idle_anim_counter ) )
	{
		self.idle_anim_counter = 0;
	}
	
	if ( self.idle_anim_counter < MIN_IDLE_REPEAT_TIMES + RandomIntRange ( 0, 1 ) )
	{
		resultState = "idle_default";
		self.idle_anim_counter += 1;
	}
	else
	{
		resultState = "idle";
		self.idle_anim_counter = 0;
	}
	
	return resultState;
}

faceTarget()
{	
	faceTarget = undefined;
	if ( IsAlive( self.enemy ) && DistanceSquared( self.enemy.origin, self.origin ) < 1600 * 1600 )
		faceTarget = self.enemy;
	else if ( IsDefined( self.owner ) )
		faceTarget = self.owner;

	if ( IsDefined( faceTarget ) )
	{
		self maps\mp\agents\alien\_alien_anim_utils::turnTowardsEntity( faceTarget );
	}
}


onDamage( eInflictor, eAttacker, iThatDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( maps\mp\alien\_utility::is_pain_available() )
		self DoPain( vDir, sHitLoc, iThatDamage );
}

DoPain( damageDirection, hitLocation, iDamage )
{	
	self endon( "killanimscript" );
	
	animState = self maps\mp\agents\alien\_alien_anim_utils::getPainAnimState( "idle_pain", iDamage );
	animIndex =  maps\mp\agents\alien\_alien_anim_utils::getPainAnimIndex( "idle", damageDirection, hitLocation );

	anime = self GetAnimEntry( animState, animIndex );
	self maps\mp\alien\_utility::always_play_pain_sound( anime );
	self maps\mp\alien\_utility::register_pain( anime );
	self.stateLocked = true;
	
	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	self PlayAnimNUntilNotetrack( animState, animIndex, "idle_pain" );
	
	self.stateLocked = false;
	self SetAnimState( "idle" );
}