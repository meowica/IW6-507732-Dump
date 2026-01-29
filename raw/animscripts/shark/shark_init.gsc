#using_animtree( "animals" );

main()
{
	self useAnimTree( #animtree );

	initSharkAnimations();
	animscripts\init::firstInit();

	self.ignoreSuppression = true;
	self.newEnemyReactionDistSq = 0;

	self.ignoreAll = true;
	self.ignoreMe = true;
	
	self.chatInitialized = false;
	self.noDodgeMove = true;
	self.root_anim = %root;

	self.meleeAttackDist = 0;

	self.a = spawnStruct();
	self.a.pose = "stand";					// to use DoNoteTracks()
	self.a.nextStandingHitDying = false;	// to allow dogs to use bullet shield
	self.a.movement = "run";

	animscripts\init::set_anim_playback_rate();

	self.suppressionThreshold = 1;
	self.disableArrivals = false;
	self.stopAnimDistSq = anim.dogStoppingDistSq;
	self.useChokePoints = false;
	self.turnRate = 0.6;

	self.pathEnemyFightDist = 512;
	self setTalkToSpecies( "dog" );

	self.health = 400;
	self.swimmer = true;
	self.pathrandompercent = 0;
}

initSharkAnimations()
{
	
}