#using_animtree( "dog" );

main()
{
	if ( isdefined( level.shark_functions ) )
	{
		if ( issubstr( self.model, "shark" ) )
		{
			self [[ level.shark_functions["init"] ]]();
			return;
		}
	}
	
	self useAnimTree( #animtree );

	initDogAnimations();
	InitDogArchetype();
	animscripts\init::firstInit();

	self.ignoreSuppression = true;
	self.newEnemyReactionDistSq = 0;

	self.chatInitialized = false;
	self.noDodgeMove = true;
	self.root_anim = %body;

	self.meleeAttackDist = 0;
	self thread setMeleeAttackDist();

	self.a = spawnStruct();
	self.a.pose = "stand";					// to use DoNoteTracks()
	self.a.nextStandingHitDying = false;	// to allow dogs to use bullet shield
	self.a.movement = "run";

	animscripts\init::set_anim_playback_rate();

	self.suppressionThreshold = 1;
	self.disableArrivals = false;
	self.stopAnimDistSq = anim.dogStoppingDistSq;
	self.useChokePoints = false;
	self.turnRate = 0.2;

	self thread animscripts\combat_utility::monitorFlash();

	self.pathEnemyFightDist = 512;
	self setTalkToSpecies( "dog" );

	self.health = int( anim.dog_health * self.health );
}


setMeleeAttackDist()
{
	self endon( "death" );

	while ( 1 )
	{
		if ( isdefined( self.enemy ) && isplayer( self.enemy ) )
			self.meleeAttackDist = anim.dogAttackPlayerDist;
		else
			self.meleeAttackDist = anim.dogAttackAIDist;

		self waittill( "enemy" );
	}
}


initDogAnimations()
{
	if ( !isdefined( level.dogsInitialized ) )
	{
		level.dogsInitialized = true;
		// [{+melee}] Melee the dog right when it bites to grab its throat.
		precachestring( &"SCRIPT_PLATFORM_DOG_DEATH_DO_NOTHING" );
		// [{+melee}] Melee the dog before it bites to grab its throat.
		precachestring( &"SCRIPT_PLATFORM_DOG_DEATH_TOO_LATE" );
		// [{+melee}] Wait for the dog to bite to grab its throat.
		precachestring( &"SCRIPT_PLATFORM_DOG_DEATH_TOO_SOON" );
		// [{+melee}]
		precachestring( &"SCRIPT_PLATFORM_DOG_HINT" );

		// Watch for the ^3[{+melee}]^7 hint to grab a dog.
		precachestring( &"NEW_DOG_DEATH_DO_NOTHING_ALT" );
		// Too late. Watch for the ^3[{+melee}]^7 hint to grab a dog.
		precachestring( &"NEW_DOG_DEATH_TOO_LATE_ALT" );
		// Too early. Wait for the ^3[{+melee}]^7 hint to grab a dog.
		precachestring( &"NEW_DOG_DEATH_TOO_SOON_ALT" );
	}

	// Initialization that should happen once per level
	if ( isDefined( anim.NotFirstTimeDogs ) )// Use this to trigger the first init
		return;
	precacheShader( "hud_dog_melee"	 );
	precacheShader( "hud_hyena_melee" );
	anim.NotFirstTimeDogs = 1;
	anim.dogStoppingDistSq = lengthSquared( getmovedelta( %iw6_dog_attackidle_runin_8, 0, 1 ) * 3 ) ;
	anim.dogStartMoveDist = length( getmovedelta( %iw6_dog_attackidle_runout_8, 0, 1 ) );

	// notetime = getNotetrackTimes( %german_shepherd_attack_player, "dog_melee" );
	// anim.dogAttackPlayerDist = length( getmovedelta( %german_shepherd_attack_player, 0, notetime[ 0 ] ) );
	anim.dogAttackPlayerDist = 102;// hard code for now, above is not accurate.

	offset = getstartorigin( ( 0, 0, 0 ), ( 0, 0, 0 ), %iw6_dog_kill_front_quick_1 );
	anim.dogAttackAIDist = length( offset );

	anim.dogTraverseAnims					= [];
	anim.dogTraverseAnims[ "wallhop"	  ] = %iw6_dog_traverse_over_24;
	anim.dogTraverseAnims[ "window_40"	  ] = %iw6_dog_traverse_over_36;
	anim.dogTraverseAnims[ "jump_down_40" ] = %iw6_dog_traverse_down_40;
	anim.dogTraverseAnims[ "jump_down_24" ] = %iw6_dog_traverse_down_24;
	anim.dogTraverseAnims[ "jump_up_24"	  ] = %iw6_dog_traverse_up_24;
	anim.dogTraverseAnims[ "jump_up_40"	  ] = %iw6_dog_traverse_up_40;
	anim.dogTraverseAnims[ "jump_up_80"	  ] = %iw6_dog_traverse_up_70;
	anim.dogTraverseAnims[ "jump_down_70" ] = %iw6_dog_traverse_down_70;

	anim.dogLookPose[ "attackIdle" ][ 2 ] = %german_shepherd_attack_look_down;
	anim.dogLookPose[ "attackIdle" ][ 4 ] = %german_shepherd_attack_look_left;
	anim.dogLookPose[ "attackIdle" ][ 6 ] = %german_shepherd_attack_look_right;
	anim.dogLookPose[ "attackIdle" ][ 8 ] = %german_shepherd_attack_look_up;

	anim.dogLookPose[ "normal" ][ 2 ] = %german_shepherd_look_down;
	anim.dogLookPose[ "normal" ][ 4 ] = %german_shepherd_look_left;
	anim.dogLookPose[ "normal" ][ 6 ] = %german_shepherd_look_right;
	anim.dogLookPose[ "normal" ][ 8 ] = %german_shepherd_look_up;

	// effects used by dog
	level._effect[ "dog_bite_blood" ] = loadfx( "fx/impacts/deathfx_dogbite" );
	level._effect[ "deathfx_bloodpool" ] = loadfx( "fx/impacts/deathfx_bloodpool_view" );

	// setup random timings for dogs attacking the player
	slices = 5;
	array = [];
	for ( i = 0; i <= slices; i++ )
	{
		array[ array.size ] = i / slices;
	}
	level.dog_melee_index = 0;
	level.dog_melee_timing_array = common_scripts\utility::array_randomize( array );

	setdvar( "friendlySaveFromDog", "0" );
}


InitDogArchetype()
{
	animscripts\animset::init_anim_sets();

	if ( animscripts\animset::ArchetypeExists( "dog" ) )
		return;

	anim.archetypes[ "dog" ] = [];

	animscripts\dog\dog_stop::InitDogArchetype_Stop();
	animscripts\dog\dog_move::InitDogArchetype_Move();
	animscripts\dog\dog_pain::InitDogArchetype_Reaction();
	animscripts\dog\dog_death::InitDogArchetype_Death();
}