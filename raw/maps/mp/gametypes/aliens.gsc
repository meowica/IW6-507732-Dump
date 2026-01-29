#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_damage;
#include maps\mp\agents\_agent_utility;
#include common_scripts\utility;
#include maps\mp\alien\scripts\_alien_armory;
#include maps\mp\alien\_utility;
#include maps\mp\alien\_collectibles;
#include maps\mp\alien\_perk_utility;

DEFAULT_REGEN_CAP = 1.0; //The max percent of player's max health that he is able to regen back up to
DEFAULT_REGEN_ACTIVATE_TIME = 3.0; //After player is damaged, the amount of time (in sec) before the health regen activates
DEFAULT_WAIT_TIME_BETWEEN_REGEN = 0.35; //When health regen is activated, the wait time between each health increase
DEFAULT_REGEN_HEALTH_AMOUNT = 1;  //The amount of health that is being added for each regen increases

//=======================================================
//				main
//=======================================================
main()
{
	if(getdvar("mapname") == "mp_background")
		return;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	if ( isUsingMatchRulesData() )
	{
		level.initializeMatchRules = ::initializeMatchRules;
		[[level.initializeMatchRules]]();
		level thread reInitializeMatchRulesOnMigration();		
	}
	else
	{
		registerRoundSwitchDvar( level.gameType, 0, 0, 9 );
		registerTimeLimitDvar( level.gameType, 10 );
		registerScoreLimitDvar( level.gameType, 500 );
		registerRoundLimitDvar( level.gameType, 1 );
		registerWinLimitDvar( level.gameType, 1 );
		registerNumLivesDvar( level.gameType, 0 );
		registerHalfTimeDvar( level.gameType, 0 );
		
		level.matchRules_damageMultiplier = 0;
		level.matchRules_vampirism = 0;
		level.prematchPeriod = 0;
	}
	
	if ( level.matchRules_damageMultiplier || level.matchRules_vampirism )
		level.modifyPlayerDamage = maps\mp\gametypes\_damage::gamemodeModifyPlayerDamage;

	level.teamBased = true;
	level.getTeamAssignment = ::getTeamAssignment;

	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.getSpawnPoint = ::getSpawnPoint;
	level.onNormalDeath = ::onNormalDeath;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onTimeLimit = ::onTimeLimit;
	level.onXPEvent = ::onXPEvent;
	level.bypassClassChoiceFunc 	= ::bypassClassChoiceFunc;
	level.callbackPlayerLastStand = ::Callback_PlayerLastStandAlien;
	level.callbackPlayerDamage = ::Callback_AlienPlayerDamage;
	level.bulletDamageMod =		getIntProperty( "perk_bulletDamage",	35 )/100;	// increased shock ammo damage by this %
	level.bot_funcs["bots_make_entity_sentient"] = ::alien_make_entity_sentient;
	
	SetDvarIfUninitialized( "alien_use_spawn_director", 0 );
	SetDvarIfUninitialized( "alien_spawn_director_load_variables", 1 );
	SetDvarIfUninitialized( "alien_cover_node_retreat", 0 );
	SetDvarIfUninitialized( "alien_retreat_towards_spawn", 1 );
	
	//used for alien_armory lockers
	level.getNodeArrayFunction 		= ::GetNodeArray;	
	
	// For the alien retreat node rating logic scheduled traces
	level.nodeFilterTracesTime = 0;
	level.nodeFilterTracesThisFrame = 0;
	
	level.maxAlienAttackerDifficultyValue = 10.0;	// max value of aliens that can attack a given target
	setAlienLoadout();
	healthRegenInit();
	
	maps\mp\agents\alien\_alien_anim_utils::initAlienAnims();
	
	level thread onPlayerConnect();
	level thread maps\mp\alien\_music_and_dialog::init();	
		
	array_thread( getEntArray( "misc_turret", "classname" ), maps\mp\alien\_trap::turret_monitorUse );
	array_thread( getEntArray( "killstreak_remotetank", "targetname" ), maps\mp\alien\_trap::tank_monitorUse );
	array_thread( getEntArray( "killstreak_vanguard", "targetname" ), maps\mp\alien\_trap::vanguard_monitorUse );
}

healthRegenInit()
{
	level.healthRegenDisabled = false;
	level.healthRegenCap = GetDvarFloat( "alien_playerHealthRegenCap", DEFAULT_REGEN_CAP );
}

//=======================================================
//				getTeamAssignment
//=======================================================
getTeamAssignment()
{
	return "allies";
}


//=======================================================
//				initializeMatchRules
//=======================================================
initializeMatchRules()
{
	//	set common values
	setCommonRulesFromMatchRulesData();
	
	//	set everything else (private match options, default .cfg file values, and what normally is registered in the 'else' below)
	SetDynamicDvar( "scr_aliens_roundswitch", 0 );
	registerRoundSwitchDvar( "aliens", 0, 0, 9 );
	SetDynamicDvar( "scr_aliens_roundlimit", 1 );
	registerRoundLimitDvar( "aliens", 1 );		
	SetDynamicDvar( "scr_aliens_winlimit", 1 );
	registerWinLimitDvar( "aliens", 1 );			
	SetDynamicDvar( "scr_aliens_halftime", 0 );
	registerHalfTimeDvar( "aliens", 0 );
		
	SetDynamicDvar( "scr_aliens_promode", 0 );
}


//=======================================================
//				onPrecacheGameType
//=======================================================
onPrecacheGameType()
{
	PrecacheMenu( "alien_armory_light_weapons" );
	PrecacheMenu( "alien_armory_heavy_weapons" );
	PrecacheMenu( "alien_armory_perks" );
	precacheString( &"ALIEN_COLLECTIBLES_USE_HEALTH_PACK" );
	precacheString( &"ALIEN_COLLECTIBLES_FIND_HEALTH_PACK" );	
	precacheString( &"ALIEN_COLLECTIBLES_COUNTDOWN_TIMER" );
	precacheString( &"ALIEN_COLLECTIBLES_COUNTDOWN_TIMER_SECONDARY" );
	precacheString( &"ALIEN_COLLECTIBLES_MIST_TIMER" );
	precacheString( &"ALIEN_COLLECTIBLES_SELF_REVIVED" );
	
	// airdrop bomb strings
	precacheString( &"ALIEN_COLLECTIBLES_PLANT_BOMB" );		// Plant bomb.
	precacheString( &"ALIEN_COLLECTIBLES_NO_BOMB" );		// You don't have the bomb.
	precacheString( &"ALIEN_COLLECTIBLES_GO_PLANT_BOMB" );	// Plant the bomb at one of the Lungs.
	precacheString( &"ALIEN_COLLECTIBLES_PICKUP_BOMB" );	// (X) Carry Bomb
	precacheString( &"ALIEN_COLLECTIBLES_REPAIR_DRILL" );
	
	// temp fx for teleportation
	level._effect[ "alien_teleport" ] 		= LoadFX( "vfx/test/vfx_alien_teleport" );
	level._effect[ "alien_teleport_dist" ] 	= LoadFX( "vfx/test/vfx_alien_teleport_dist" );
	
	//temp fx for glowing biolumesence
	level._effect[ "vfx_alien_eye" ] 		= Loadfx( "vfx/gameplay/alien/vfx_alien_eye" );
	level._effect[ "vfx_alien_minion" ] 	= Loadfx( "vfx/gameplay/alien/vfx_alien_minion" );
	
	// fx for Queen
	maps\mp\agents\alien\_alien_elite::load_queen_fx();
	
	// fx for spitter
	maps\mp\agents\alien\_alien_spitter::load_spitter_fx();
	
	// fx for minion
	maps\mp\agents\alien\_alien_minion::load_minion_fx();
	
	level._effect[ "bomb_impact" ]	 				= loadfx( "vfx/ambient/sparks/electrical_sparks");
	level._effect[ "vfx_alien_death" ]	 			= loadfx( "vfx/gameplay/alien/vfx_alien_death");
	level._effect[ "shield_impact" ]	 			= Loadfx( "fx/impacts/large_metalhit_1" );

	//turret
	PreCacheTurret( "turret_minigun_alien" );
}


//=======================================================
//				onPlayerKilled
//=======================================================
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId)
{
	self.laststand = true;
	self.inLastStand = true;	//<NOTE J.C.> When players somehow kill themselves (ex. by cooking a freg grenade), the code does not honor the
								//            last stand perk. Manually set the flag here for game ending logic checks.
			
	maps\mp\alien\_gamescore::update_team_bonus( "team_casualties" );
								
	if ( gameShouldEnd( self ) )
	{
		AlienEndGame();
		return;
	}

	self.body delete();     //<NOTE J.C.> Delete the ragdoll corpse
	self.reviveIcon = maps\mp\alien\_hud::makeReviveIcon( ( 1.0, 0.0, 0.0 ) );
	self thread lastStandBleedOutAlien( self.origin, self.angles );
}

//=======================================================
//				onNormalDeath
//=======================================================
onNormalDeath( victim, attacker, lifeId )
{
	if ( game["state"] == "postgame" && game["teamScores"][attacker.team] > game["teamScores"][level.otherTeam[attacker.team]] )
		attacker.finalKill = true;
}


//=======================================================
//				onStartGameType
//=======================================================
onStartGameType()
{
	setClientNameMode("auto_change");

	thread mp_ents_clean_up();
	
	level.disableForfeit = true;
	
	//Per alien, the size of the array that hold the recent damage info (self.recentDamages)
	level.damageListSize = 20;
	
	setObjectiveText( "allies", &"ALIEN_OBJECTIVES_ALIENS" );
	setObjectiveText( "axis", &"ALIEN_OBJECTIVES_ALIENS" );
	
	if ( level.splitscreen )
	{
		setObjectiveScoreText( "allies", &"ALIEN_OBJECTIVES_ALIENS" );
		setObjectiveScoreText( "axis", &"ALIEN_OBJECTIVES_ALIENS" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"ALIEN_OBJECTIVES_ALIENS_SCORE" );
		setObjectiveScoreText( "axis", &"ALIEN_OBJECTIVES_ALIENS_SCORE" );
	}
	
	setObjectiveHintText( "allies", &"ALIEN_OBJECTIVES_ALIENS_HINT" );
	setObjectiveHintText( "axis", &"ALIEN_OBJECTIVES_ALIENS_HINT" );
	
	maps\mp\alien\_persistence::rank_init();
	maps\mp\alien\_progression::main();
	
	initAliens();
	
	if ( !ThreatBiasGroupExists( "aliens" ) )
		CreateThreatBiasGroup( "aliens" );
	
/#
	if ( GetDvarInt( "scr_aliennavtest" ) == 1 )
	{
		level thread maps\mp\alien\_debug::alienNavTest();
	}
	
	if ( GetDvarInt( "scr_aliennogame" ) == 1 )
	{
		maps\mp\alien\_utility::alien_mode_enable( "nogame" );
	}
	
	if ( GetDvarInt( "scr_alienkillresource" ) == 1 )
	{
		maps\mp\alien\_utility::alien_mode_enable( "kill_resource" );
	}
#/	
	// init collectibles system
	if ( alien_mode_has( "collectible" ) )
		maps\mp\alien\_collectibles::pre_load();
	
	// mist init and run
	maps\mp\alien\_mist::main();
	
	// airdrop bomb init and run
	maps\mp\alien\_airdrop::main();
	
	maps\mp\alien\_spawnlogic::alien_health_per_player_init();
	
	initSpawns();
	
	armory_init();
	
	allowed[0] = level.gameType;	
	maps\mp\gametypes\_gameobjects::main( allowed );
	
	// Init starting cycle
	level.current_cycle_num = 0;
/#
	if ( GetDvarInt( "scr_startingcycle" ) > 0 )
	{
		level.current_cycle_num = GetDvarInt( "scr_startingcycle" );
	}
#/
	
	// spawns collectibles
	if ( alien_mode_has( "collectible" ) )
		maps\mp\alien\_collectibles::post_load();
	
	if ( alien_mode_has( "wave" ) && !alien_mode_has( "nogame" ) )
	{
		thread alienSpawnLogic();
	}
	else
	{
		thread runAliens();
	}

	if( !alien_mode_has( "nogame" ) )
	{
		level thread runLockers();
	}
	
	/#
		level thread maps\mp\alien\_debug::runStartPoint();
		thread maps\mp\alien\_debug::debugDvars();
	#/
		

	//Overrides///////////////////////////////////////////////////////////////		
	//Sentry
	if ( isdefined( level.sentrySettings ) && isdefined( level.sentrySettings[ "sentry_minigun" ] ) )
	{
		level.sentrySettings[ "sentry_minigun" ].maxHealth 	= 500;
		level.sentrySettings[ "sentry_minigun" ].timeOut 	= 150;
	}
	
	//IMS settings
	level.imsSettings[ "ims" ].hintString 						= &"ALIEN_COLLECTIBLES_IMS_PICKUP";	
	level.imsSettings[ "ims" ].placeString 						= &"ALIEN_COLLECTIBLES_IMS_PLACE";	
	level.imsSettings[ "ims" ].cannotPlaceString 				= &"ALIEN_COLLECTIBLES_IMS_CANNOT_PLACE";	
	
	//Override the string for vest
	level.boxSettings[ "deployable_vest" ].hintString 			= &"ALIEN_COLLECTIBLES_DEPLOYABLE_VEST_PICKUP";
	level.boxSettings[ "deployable_vest" ].capturingString 		= &"ALIEN_COLLECTIBLES_DEPLOYABLE_VEST_GETTING";
	level.boxSettings[ "deployable_vest" ].eventString 			= &"ALIEN_COLLECTIBLES_DEPLOYED_VEST";
		
	//Override the string for team ammo

	level.boxSettings[ "deployable_ammo" ].hintString 			= &"ALIEN_COLLECTIBLES_DEPLOYABLE_AMMO_PICKUP";
	level.boxSettings[ "deployable_ammo" ].capturingString 		= &"ALIEN_COLLECTIBLES_DEPLOYABLE_AMMO_TAKING";	
	level.boxSettings[ "deployable_ammo" ].eventString 			= &"ALIEN_COLLECTIBLES_DEPLOYABLE_AMMO_TAKEN";
	
	//Override the string for team grenades
	level.boxSettings[ "deployable_grenades" ].hintString 		= &"ALIEN_COLLECTIBLES_DEPLOYABLE_GRENADES_PICKUP";
	level.boxSettings[ "deployable_grenades" ].capturingString 	= &"ALIEN_COLLECTIBLES_DEPLOYABLE_GRENADES_TAKING";	
	level.boxSettings[ "deployable_grenades" ].eventString 		= &"ALIEN_COLLECTIBLES_DEPLOYABLE_GRENADES_TAKEN";
	
		//Override the string for team boost
	level.boxSettings[ "deployable_juicebox" ].hintString 		= &"ALIEN_COLLECTIBLES_DEPLOYABLE_BOOST_PICKUP";
	level.boxSettings[ "deployable_juicebox" ].capturingString 	= &"ALIEN_COLLECTIBLES_DEPLOYABLE_BOOST_TAKING";	
	level.boxSettings[ "deployable_juicebox" ].eventString 		= &"ALIEN_COLLECTIBLES_DEPLOYABLE_BOOST_TAKEN";
	
	//<NOTE J.C.> Temp fix for the SRE when the ammo box is deleting itself after its owner disconnect
	level.boxSettings[ "deployable_ammo" ].deathDamageMax = undefined;
	
	//Remote Tank specific settings for aliens mode
	level.tankSettings[ "remote_tank" ].stringPlace =			&"ALIEN_COLLECTIBLES_REMOTE_TANK_PLACE";	
	level.tankSettings[ "remote_tank" ].stringCannotPlace =		&"ALIEN_COLLECTIBLES_REMOTE_TANK_CANNOT_PLACE";	
	level.tankSettings[ "remote_tank" ].timeOut =				20.0;
	level.tankSettings[ "remote_tank" ].health =				99999; // keep it from dying anywhere in code
	level.tankSettings[ "remote_tank" ].maxHealth =				1000; // this is what we check against for death	
	level.tankSettings[ "remote_tank" ].mgTurretInfo =			"ugv_turret_mp";
	level.tankSettings[ "remote_tank" ].missileInfo =			"remote_tank_projectile_mp";
	
	//Vanguard specific settings for alien mode
	
	//Bouncing Betty override values
	level.mineDamageMin = 325;
	level.mineDamageMax = 750;
	
	//max claymores and betties and such one player can own at a time before they start destroying the oldest one
	level.maxPerPlayerExplosives = 10;
	
	// 	Trap Inits 
	maps\mp\alien\_trap::traps_init();
	
	// 	Team Bonus
	maps\mp\alien\_gamescore::reset_team_bonus();
	
	level.spitter_gas_cloud_count = 0;
}


//===========================================
// 			onPlayerConnect
//===========================================
onPlayerConnect()
{
	while( true )
	{
		level waittill( "connected", player );
		
		if( !IsAI( player ) )
		{
			// init persistence data
			player maps\mp\alien\_persistence::player_persistence_init();

			player thread player_init_currency();
			player thread player_init_health_regen();
			player maps\mp\alien\_gamescore::reset_personal_bonus();
			player maps\mp\alien\_hud::createBonusInfoHUD();
			player thread maps\mp\alien\_hud::createPainOverlay();
			player thread maps\mp\alien\_progression::player_setup();
			
			if ( alien_mode_has( "kill_resource" ) )
			{
				player thread player_init_assist_bonus();
				iprintlnbold( "Destroy 3 Hives, earn cash to purchase defenses." );
			}

			player resetUIDvarsOnConnect();			
		}
	}
}

player_init_currency()
{
	self endon( "disconnect" );
	
	self waittill( "loot_initialized" );
	self updatePlayerLootDvar ("ui_player_money", "loot_blood_small" );
	self updatePlayerLootDvar ("ui_player_yellow_eggs", "item_yellow_egg");
	self updatePlayerLootDvar ("ui_player_green_eggs", "item_green_egg");
	self updatePlayerLootDvar ("ui_player_red_eggs", "item_red_egg");
	self updatePlayerLootDvar ("ui_player_blue_eggs", "item_blue_egg");
	self updatePlayerLootDvar ("ui_player_purple_eggs", "item_purple_egg");
	//self give_loot( "loot_blood_small", 1500 );
}

player_init_health_regen()
{
	self.healthRegenMaxPercent = level.healthRegenCap;
	self.regenSpeed = 1;
}

player_init_invulnerability()
{
	self.haveInvulnerabilityAvailable = true;
}

player_init_damageShield()
{
	self.damageShieldExpireTime = getTime();
}

player_gain_lastStand()
{
	self.haveLastStandAvailable = true;
}

player_init_assist_bonus()
{
	self.leftover_assist_bonus = 0;
}

player_lose_lastStand()
{
	self.haveLastStandAvailable = false;
}

//===========================================
// 			AlienEndGame
//===========================================
AlienEndGame()
{
	level thread maps\mp\gametypes\_gamelogic::endGame( "axis", maps\mp\gametypes\_teams::getTeamEliminatedString( "allies" ) );
}

//===========================================
// 			gameShouldEnd
//===========================================
gameShouldEnd( player_just_down )
{	
	if ( alien_mode_has( "nogame" ) )
	{
		return false;
	}
	
	num_self_revive = player_just_down get_loot_count( "item_revive_booster" );
	num_health_packs = player_just_down get_loot_count( "item_health_pack" );
	
	if ( num_self_revive > 0 ) 
	{
		return false;
	}
	
	if ( !alien_mode_has( "kill_resource" ) && num_health_packs > 0 )
	{
		return false;
	}
	
	foreach( player in level.players )
	{
		if ( player == player_just_down )
			continue;
		
		if ( player.inLastStand == false )
			return false;
	}
	return true;
}

//=======================================================
//				onSpawnPlayer
//=======================================================
onSpawnPlayer()
{
	// Use the initial alien loadout
	self.pers["gamemodeLoadout"] = level.alien_loadout;
	
	self.isBoosted = undefined;
	self.isHealthBoosted = undefined;	
	
	// because self.lastdeathpos is not reliable
	self thread player_last_death_pos();
	self thread alienPlayerHealthHints();
	self player_init_invulnerability();
	self player_init_damageShield();
	self player_gain_lastStand();
	
	if ( alien_mode_has( "loot" ) )
		self maps\mp\alien\_collectibles::player_loot_init();
	
	if ( alien_mode_has( "airdrop" ) )
		self thread maps\mp\alien\_airdrop::watchBomb();
		
	self thread maps\mp\alien\_collectibles::watchThrowableItems();
				
	// manages player mist
	self thread maps\mp\alien\_mist::player_fog_think();
	self thread alienPlayerHealthRegen();
	self thread alienPlayerArmor();
	
	self thread pistol_ammo_regen();
	self thread waitLoadoutFinish();

	if ( !isDefined( self.friendiconParams ) )
		maps\mp\alien\_hud::makeFriendlyHeadIcon();
	
	self resetUIDvarsOnSpawn();
}

player_last_death_pos()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	
	self.last_death_pos = self.origin;
	
	while ( 1 )
	{
		self waittill( "damage" ); // safer to wait for damage than every frame
		self.last_death_pos = self.origin;
	}
}

waitLoadoutFinish()
{
	//<TODO J.C.>: This is a temp hack. As loadoutAllPerks() is currently commented out in _class.gsc (line 1143) for unknown reason.  
	//             We need our own alien-specific giveLoadout() sooner rather than later.
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	
	//Wait for the class loadout to finish
	self waittill( "giveLoadout" );
	
	self givePerk( "specialty_pistoldeath", false );
	self givePerk( "specialty_falldamage", false );
	self SwitchToWeapon( "iw6_alienp226_mp" );
}

alienPlayerHealthHints()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	
	while ( true )
	{
		regen_ratio_limit = 0.33; //REGEN_LIMIT_HEALTH_BAR_SEGMENT / GetDvarInt ( "player_health_bar_segments" );
		regen_ratio_limit = int( regen_ratio_limit * 100 )/100; // centi
		ratio = self.health / self.maxHealth;
		
		// no warning in last stand as you can not heal
		if ( isdefined( self.laststand ) && self.laststand )
		{
			wait 0.05;
			continue;
		}
		
		if ( ratio < regen_ratio_limit )
		{
			if ( self has_healthpack() )
			{
//				self setLowerMessage( "use_health", &"ALIEN_COLLECTIBLES_USE_HEALTH_PACK", 5 );
				//self delayThread( 0.05, ::display_hint, "use_health" );
			}
			else
			{
//				self setLowerMessage( "find_health", &"ALIEN_COLLECTIBLES_FIND_HEALTH_PACK", 5 );
//				//self delayThread( 0.05, ::display_hint, "find_health" );
			}
		}
		
		self waittill_any_timeout( 5, "health_regened", "damage" );
		
		waittillframeend;
	}	
}

has_healthpack()
{
	if ( isdefined( self.has_health_pack ) && self.has_health_pack )
		return true;
	
	return false;
	
	/*
	// does player already have item in dpad left
	override = self GetWeaponHudIconOverride( "actionslot3" );
	if ( isdefined( override ) && override != "none" )
		return true;
	
	return false;
	*/
}

//=======================================================
//				onTimeLimit
//=======================================================
onTimeLimit()
{
	maps\mp\gametypes\_gamelogic::default_onTimeLimit();
}


//=======================================================
//				onXPEvent
//=======================================================
onXPEvent( event )
{
	self maps\mp\gametypes\_globallogic::onXPEvent( event );
}


//=======================================================
//				getSpawnPoint
//=======================================================
getSpawnPoint()
{
	spawnteam = self.pers["team"];
	
	if( level.gracePeriod && isDefined( level.alien_player_spawn_group ) )
	{
		grouplist = [ "group0", "group1", "group2", "group3" ];
		grouplist = array_randomize( grouplist );
		level.group = grouplist[0];
		
		//use this for start spawn logic
		group = level.group;
		
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_alien_spawn_" + group + "_start" );
		//spawnPoint = spawnPoints[0];
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_tdm_spawn_axis_start" );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );	
	}

	return spawnPoint;
}


//======================================================= 
//				initSpawns
//=======================================================
initSpawns()
{
	maps\mp\alien\_director::alien_attribute_table_init();
	
	// wave spawners
	if ( alien_mode_has( "wave" ) )
	{
		maps\mp\alien\_spawnlogic::alien_wave_init();
		
		// init locations for meteroid drops
		thread maps\mp\alien\_spawnlogic::setup_meteoroid_paths();
		
		// init lurker spawners and patrol loops
		maps\mp\alien\_spawnlogic::alien_lurker_init();
	}
	
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	
	//maps\mp\gametypes\_spawnlogic::addStartSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::addStartSpawnPoints( "mp_tdm_spawn_axis_start" );
	
	if ( isDefined( level.alien_player_spawn_group ) )
	{
		maps\mp\gametypes\_spawnlogic::addStartSpawnPoints( "mp_alien_spawn_group3_start");
		maps\mp\gametypes\_spawnlogic::addStartSpawnPoints( "mp_alien_spawn_group1_start");
		//maps\mp\gametypes\_spawnlogic::addStartSpawnPoints( "mp_alien_spawn_group2_start");
		maps\mp\gametypes\_spawnlogic::addStartSpawnPoints( "mp_alien_spawn_group0_start");
	}
	
	//maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	//maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	
	// not setting this was causing ents spawned acting weird! it complains ents outside playable area
	setMapCenter( level.mapCenter );
}


//=======================================================
//				initAliens
//=======================================================
initAliens()
{
	if ( !IsDefined( level.agent_funcs ) )
		level.agent_funcs = [];
	
	level.agent_funcs["alien"] 					= [];
	
	level.agent_funcs["alien"]["spawn"]		= ::alienAgentSpawn;
	
	level.agent_funcs["alien"]["think"] 		= ::alienAgentThink;
	level.agent_funcs["alien"]["on_killed"]		= ::onAlienAgentKilled;
	level.agent_funcs["alien"]["on_damaged"]	= ::onAlienAgentDamaged;
	level.agent_funcs["alien"]["on_damaged_finished"] = maps\mp\agents\alien\_alien_think::onDamageFinish;
	
	level.alien_funcs["brute"]["approach"]    = maps\mp\agents\alien\_alien_think::default_approach;
	level.alien_funcs["minion"]["approach"]    = maps\mp\agents\alien\_alien_minion::minion_approach;
	level.alien_funcs["spitter"]["approach"]    = maps\mp\agents\alien\_alien_spitter::spitter_approach;
	level.alien_funcs["elite"]["approach"]    = maps\mp\agents\alien\_alien_elite::elite_approach;
	level.alien_funcs["brute1"]["approach"]    = maps\mp\agents\alien\_alien_think::default_approach;
	level.alien_funcs["brute2"]["approach"]    = maps\mp\agents\alien\_alien_think::default_approach;
	level.alien_funcs["brute3"]["approach"]    = maps\mp\agents\alien\_alien_think::default_approach;
	level.alien_funcs["brute4"]["approach"]    = maps\mp\agents\alien\_alien_think::default_approach;
	
	level.alien_funcs["brute"]["combat"]    = maps\mp\agents\alien\_alien_think::default_alien_combat;
	level.alien_funcs["minion"]["combat"]    = maps\mp\agents\alien\_alien_think::default_alien_combat;
	level.alien_funcs["spitter"]["combat"]    = maps\mp\agents\alien\_alien_spitter::spitter_combat;
	level.alien_funcs["elite"]["combat"]    = maps\mp\agents\alien\_alien_think::default_alien_combat;
	level.alien_funcs["brute1"]["combat"]    = maps\mp\agents\alien\_alien_think::default_alien_combat;
	level.alien_funcs["brute2"]["combat"]    = maps\mp\agents\alien\_alien_think::default_alien_combat;
	level.alien_funcs["brute3"]["combat"]    = maps\mp\agents\alien\_alien_think::default_alien_combat;
	level.alien_funcs["brute4"]["combat"]    = maps\mp\agents\alien\_alien_think::default_alien_combat;

	level.used_nodes = [];
	level.used_nodes_list_size = 20;
	level.used_nodes_list_index = 0;
	
	level.alien_jump_melee_speed = 1.05;
	level.alien_jump_melee_gravity = 900;
}

//=======================================================
//				Callback_AlienPlayerDamage
//=======================================================
Callback_AlienPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
    if ( sMeansOfDeath == "MOD_TRIGGER_HURT" )
    {
        handleKilledByKillPlane();
    }
    else if ( shouldTakeDamage( eAttacker ) )
    {
    	isUsingRemoteAndWillBeLowHealth = usingRemoteAndWillBeLowHealth ( iDamage );
    	
    	if ( shouldUseInvulnerability ( iDamage ) || isUsingRemoteAndWillBeLowHealth )
    	{
    		useInvulnerability( iDamage );
    	}
    	
    	if ( isUsingRemoteAndWillBeLowHealth )
    	{
    		stopUsingRemote();
    	}
    	
    	maps\mp\alien\_hud::playPainOverlay( vDir );
    	iDamage = int ( iDamage * perk_GetDamageReductionScaler() );
    	maps\mp\gametypes\_damage::Callback_PlayerDamage_internal( eInflictor, eAttacker, self, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
    	self notify( "player_damaged" );
    }         
}

//=======================================================
//				handleKilledByKillPlane
//=======================================================
handleKilledByKillPlane()
{
	SPAWN_POINT_CLASSNAME = "mp_tdm_spawn_axis_start";
	start_points = level.spawnPointArray[ SPAWN_POINT_CLASSNAME ];
	
	random_index = randomIntRange( 0, start_points.size );
	start_point = start_points[ random_index ];
	
	self.reviveIcon = maps\mp\alien\_hud::makeReviveIcon( ( 1.0, 0.0, 0.0 ) );
	self thread lastStandBleedOutAlien( start_point.origin, start_point.angles );
}

//=======================================================
//				shouldUseInvulnerability
//=======================================================
shouldUseInvulnerability ( iDamage )
{
	DAMAGE_BUFFER_LIMIT = 20;  // If player is taking a huge amount of damage, no Invulnerability
	
	return ( self.haveInvulnerabilityAvailable && iDamage > self.health && iDamage < ( self.health + DAMAGE_BUFFER_LIMIT ) );
}

//=======================================================
//			  usingRemoteAndWillBeLowHealth
//=======================================================
usingRemoteAndWillBeLowHealth ( iDamage )
{
	USING_REMOTE_LOW_HEALTH_RATIO = 0.2;
	
	low_health_limit = self.maxhealth * USING_REMOTE_LOW_HEALTH_RATIO;
	
	return ( isUsingRemote() && ( iDamage > self.health || ( self.health - iDamage ) <= low_health_limit ) );
}

//=======================================================
//			         stopUsingRemote
//=======================================================
stopUsingRemote()
{
	self notify ( "stop_using_remote" );
}

//=======================================================
//				useInvulnerability
//=======================================================
useInvulnerability( iDamage )
{
	self.health = iDamage + 1;   // Make sure player has 1 health left
	self.haveInvulnerabilityAvailable = false;
}

//=======================================================
//				shouldTakeDamage
//=======================================================
shouldTakeDamage( attacker )
{
	if ( IsDefined ( attacker ) && attacker == self )
        return false;
	
    if ( isDefined ( self.inLastStand ) && self.inLastStand )
        return false;

    if ( getTime() < self.damageShieldExpireTime )  // have damage shield
 		return false;
    	
    return true;
}

//=======================================================
//				onAlienAgentDamaged
//=======================================================
onAlienAgentDamaged( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{	
	typeSpecificDamageProcessing( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
	
	if ( hitBodyPartImmuneToDamage( vPoint, vDir, sHitLoc ) )
		return false;
	
	// ignore friendly fire damage for team based modes
	if ( level.teambased && IsDefined( eAttacker ) && IsDefined(eAttacker.team) && (self.team == eAttacker.team) && ( isDefined ( eAttacker.alien_type ) && !alienTypeCanDoFriendlyDamage( eAttacker ) ) )
		return false;
		
	// don't let helicopters and other vehicles crush a player, if we want it to then put in a special case here
	if ( IsDefined( sMeansOfDeath ) && sMeansOfDeath == "MOD_CRUSH" && IsDefined( eInflictor ) && IsDefined( eInflictor.classname ) && eInflictor.classname == "script_vehicle" )
		return false;

	if ( !IsDefined( self ) || !isReallyAlive( self ) )
		return false;
	
	if ( IsDefined( eAttacker ) && eAttacker.classname == "script_origin" && IsDefined( eAttacker.type ) && eAttacker.type == "soft_landing" )
		return false;

	if ( sWeapon == "killstreak_emp_mp" || sWeapon == "alienspit_mp" || sWeapon == "alienspit_gas_mp" )
		return false;

	if ( sWeapon == "xm25_mp" && sMeansOfDeath == "MOD_IMPACT" )
		iDamage = 95;
	
	// Handle armor
	if ( !(idFlags & level.iDFLAGS_NO_ARMOR) && sWeapon != "none" )
	{
		iDamage = Int( iDamage * armorMitigation( vPoint, vDir, sHitLoc ) );
	}
	
	if ( IsDefined( sMeansOfDeath ) && sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" )
	{
		iDamage += Int(idamage * level.bulletDamageMod);
	}
	
 	if( iDamage <= 0 )
 		return false;

	if ( IsDefined( eAttacker ) && eAttacker != self && iDamage > 0 && ( !IsDefined( sHitLoc ) || sHitLoc != "shield" ) )
	{
		if( iDFlags & level.iDFLAGS_STUN )
			typeHit = "stun";
		else if( !shouldWeaponFeedback( sWeapon ) )
			typeHit = "none";
		else if ( isDefined( eInflictor ) && isDefined( eInflictor.damageFeedback ) && eInflictor.damageFeedback == false )
			typeHit = "none";
		else
			typeHit = "standard";
				
		eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( typeHit );
	}
 	
	giveAssistBonus( eAttacker, iDamage );
	
/#
	self maps\mp\alien\_debug::debugTrackDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
#/	
	return self [[ self agentFunc( "on_damaged_finished" ) ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

typeSpecificDamageProcessing( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	//<NOTE J.C.> On a "damage" notify, we are only getting the damage and attacker back. Ideally, we should move this type of
	//            damage process as a listener running on specific alien type

	switch ( get_alien_type() )
	{
	case "elite":
		maps\mp\agents\alien\_alien_elite::queenDamageProcessing( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		break;
	default:
		break;
	}
}

hitBodyPartImmuneToDamage( vPoint, vDir, sHitLoc )
{
	switch ( get_alien_type() )
	{
	case "elite":
		return maps\mp\agents\alien\_alien_elite::hitQueenBodyPartImmuneToDamage( vPoint, vDir, sHitLoc );
	default:
		return false;
	}
}

armorMitigation( vPoint, vDir, sHitLoc )
{
	switch( get_alien_type() )
	{
	case "brute":
		return maps\mp\agents\alien\_alien_think::armorMitigation( vPoint, vDir, sHitLoc );
	default:
		return 1.0; // No mitigation
	}
}

alienTypeCanDoFriendlyDamage( attacker )
{	
	switch( attacker get_alien_type() )
	{
	case "minion":
		return true;
	default:
		return false;
	}	
}

giveAssistBonus( attacker, damage )
{
	if( !isPlayer( attacker ) || !alien_mode_has( "kill_resource" ) )
		return;
	
	TOTAL_BONUS_AMOUNT = 100; //We should base this total amount based on different alien type eventually
	BONUS_INCREMENT_AMOUNT = 20;
	
	new_assist_bonus = int ( TOTAL_BONUS_AMOUNT * damage / self.max_health );
	total_assist_bonus = attacker.leftover_assist_bonus + new_assist_bonus;
	
	increment = int( total_assist_bonus / BONUS_INCREMENT_AMOUNT );
	attacker.leftover_assist_bonus = total_assist_bonus - increment * BONUS_INCREMENT_AMOUNT;
	assist_bonus = increment * BONUS_INCREMENT_AMOUNT;
	
	attacker maps\mp\alien\_collectibles::give_loot( "loot_blood_small", assist_bonus );
	attacker notify( "loot_pickup" );
}

//=======================================================
//				alienSpawnLogic
//=======================================================
alienSpawnLogic()
{
	level endon( "game_ended" );
	
	level.alien_pregame_delay	= 100000; //60;
	level.alien_cycle_intermission 	= 100000; //120;
	level.alien_wave_intermission 	= 1;
	
	//if( startPointEnabled() )
	//	level.alien_pregame_delay	= 30;	
	
	maps\mp\alien\_spawnlogic::alien_wave_spawn_think();
}

//=======================================================
//				runAliens
//=======================================================
runAliens()
{
	level endon( "game_ended" );
	
	wait( 3 );
	
	while ( true )
	{
		if ( notEnoughDebugAliens() )
		{
			addAlienAgentWithOverride();
		}
		wait 0.5;
	}
}
		
notEnoughDebugAliens()
{
	desired_count = GetDvarInt( "mp_alien_count", 0 );
	current_count = getAgentsOfType( "alien" ).size;
	
	if ( desired_count > current_count )
	{
		return true;
	}
	
	return false;
}

addAlienAgentWithOverride()
{
	alien_type_override = GetDvar ( "alien_type_override" );
	
	if ( alien_type_override != "" )
			alien = addAlienAgent( "axis", undefined, undefined, alien_type_override );
	else
		alien = addAlienAgent( "axis" );
	
	return alien;
}

//=======================================================
//				addAlienAgent
//=======================================================
addAlienAgent( team, spawnOrigin, spawnAngle, alienType )
{
	agent = getFreeAgent( "alien" );
	
	if ( IsDefined( agent ) )
	{
		if ( IsDefined( team ) )
			agent set_agent_team( team );
		else
			agent set_agent_team( agent.team );
		
		agent.agent_teamParticipant = false;
		agent.agent_gameParticipant = false;
		
		agent thread [[ agent agentFunc("spawn") ]]( spawnOrigin, spawnAngle, alienType );
	}
	
	return agent;
}


//=======================================================
//				alienAgentSpawn
//=======================================================
alienAgentSpawn( spawnOrigin, spawnAngles, alienType )
{
	if ( !isDefined( alienType ) )
		alienType = "wave brute";
	
	alien_type = remove_spawn_type( alienType );
	
	if ( !isDefined( spawnOrigin ) || !isDefined( spawnAngles ) )
	{
		spawnPoint 	= self [[level.getSpawnPoint]]();
		spawnOrigin = spawnpoint.origin;
		spawnAngles = spawnpoint.angles;
	}
	
	self set_alien_model( alien_type );
	
	self spawn_alien_agent( spawnOrigin, spawnAngles, alien_type );
	
	self set_alien_attributes( alienType );
	
	self set_code_fields( alien_type );
	
	self set_script_fields( spawnOrigin );
			
	self type_specific_init();
	
	self setup_watcher();
	
	self misc_setup();
		
	self thread maps\mp\agents\alien\_alien_think::main();
}

set_code_fields( alien_type )
{
	self.allowJump = true;
	self.allowladders = 1;
	self.moveMode = "run";
	self.radius = 15;
	self.height = 72;
	self.turnrate = 0.3;
	self.sharpTurnNotifyDist = 48;
	self.traverseSoonNotifyDist = level.alienAnimData.jumpLaunchArrival_maxMoveDelta;
	self.stopSoonNotifyDist = level.alienAnimData.stopSoon_NotifyDist;
	self.jumpCost = level.alien_types[ alien_type ].attributes[ "jump_cost" ];
	self.traverseCost = level.alien_types[ alien_type ].attributes[ "traverse_cost" ];
	self.runCost = level.alien_types[ alien_type ].attributes[ "run_cost" ];
}

set_script_fields( spawnOrigin )
{
	self.species = "alien";
	self.enableStop = true;
	self.isActive 	= true;
	self.spawnTime 	= GetTime();
	self.attacking_player = false;
	self.spawnOrigin = spawnOrigin;
	self.recentDamages = [];
	self.damageListIndex = 0;
	self.swipeChance = 0.5;
	self.leapEndPos = undefined;
	self.trajectoryActive = false;
}

remove_spawn_type( alienType )
{
	// if spawn type is passed in, it is the first token delimited by a space, second token is alien type
	spawnTypeConfig = strtok( alienType, " " );
	if ( isdefined( spawnTypeConfig ) && spawnTypeConfig.size == 2 )
		return spawnTypeConfig[ 1 ];
	else
		return alienType;	
}

set_alien_model( alien_type )
{	
	alien_model = level.alien_types[ alien_type ].attributes[ "model" ];
	self SetModel( alien_model );
	self show();
}

spawn_alien_agent( spawnOrigin, spawnAngles, alien_type )
{	
	// the self.OnEnterAnimState field needs to be set before SpawnAgent
	self.OnEnterAnimState = maps\mp\agents\alien\_alien_think::onEnterAnimState;  
	anim_class = get_anim_class( alien_type );
	self SpawnAgent( spawnOrigin, spawnAngles, anim_class, 15, 50 );
}

get_anim_class( alien_type )
{
	switch ( alien_type )
	{
	case "brute1":    // temp alien types
	case "brute2":    // temp alien types
	case "brute3":    // temp alien types
	case "brute4":    // temp alien types
		return "alien_brute_animclass";
	default:
		return ( "alien_" + alien_type + "_animclass" );
	}
}

set_alien_attributes( alienType )
{	
	self maps\mp\alien\_spawnlogic::assign_alien_attributes( alienType );
}

type_specific_init()
{
	switch ( get_alien_type() )
	{
	case "elite":
		maps\mp\agents\alien\_alien_elite::queen_init();
		break;
	case "minion":
		maps\mp\agents\alien\_alien_minion::minion_init();
		break;
	case "spitter":
		maps\mp\agents\alien\_alien_spitter::spitter_init();
		break;
	default:
		break;	
	}
}

misc_setup()
{
	self SetThreatBiasGroup( "aliens" );
	self ScrAgentSetClipMode( "agent" );
	self TakeAllWeapons();
	self givePerk ( "specialty_spygame", false );
	//self maps\mp\agents\alien\_alien_anim_utils::calculateAnimData();
}

setup_watcher()
{
	self thread maps\mp\agents\alien\_alien_think::watch_for_scripted();
	self thread maps\mp\agents\alien\_alien_think::watch_for_badpath();
	self thread maps\mp\agents\alien\_alien_think::watch_for_insolid();
	self thread maps\mp\_flashgrenades::MonitorFlash();
	self thread maps\mp\agents\alien\_alien_think::MonitorFlash();
	
/#	
	if ( GetDvarInt( "scr_aliendebugvelocity" ) == 1 )
		self thread maps\mp\alien\_debug::alienDebugVelocity();
#/
}

//=======================================================
//				alienAgentThink
//=======================================================
alienAgentThink()
{
}


//=======================================================
//				onAlienAgentKilled
//=======================================================
onAlienAgentKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	self.isActive 	= false;
	self.hasDied 	= false;
	self.owner		= undefined;

	if ( !isDefined ( vDir ) )
		vDir = anglesToForward( self.angles );
	
	maps\mp\alien\_gamescore::update_team_bonus( "team_kills" );
	
	play_death_anim_and_ragdoll( eInflictor, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc );
	
	self maps\mp\agents\alien\_alien_think::OnEnterAnimState( self.currentAnimState, "death" );	// we don't need to enter death so much as exit currentAnimState.
	
	self playSound( "alien_death" );
	
	PlayFX(level._effect[ "vfx_alien_death" ],self.origin);
	
	give_attacker_kill_rewards( eAttacker );
	
	level notify( "alien_killed" );
}

give_attacker_kill_rewards( attacker )
{
	if ( !isDefined( attacker ) || !isPlayer( attacker ) )
		return;
	
	reward_point = get_reward_point_for_kill();
	
	attacker maps\mp\alien\_gamescore::givePlayerScore( reward_point );
	attacker maps\mp\alien\_persistence::give_player_currency( reward_point * ( attacker perk_GetCurrencyScalePerKill() ) );
}

get_reward_point_for_kill()
{
	switch( get_alien_type() )
	{
	case "spitter":
		return 200;
	default:
		return 100;
	}
}

play_death_anim_and_ragdoll( eInflictor, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc )
{
	primary_animState = get_primary_death_anim_state();
	
	if ( is_special_death( primary_animState ) )
	{
		animState = primary_animState;
		animIndex = self maps\mp\agents\alien\_alien_anim_utils::getSpecialDeathAnimIndex( primary_animState );
	}
	else
	{
		animState = self maps\mp\agents\alien\_alien_anim_utils::getDeathAnimState( ( primary_animState + "_death" ), iDamage );
		animIndex = self maps\mp\agents\alien\_alien_anim_utils::getDeathAnimIndex( primary_animState , vDir, sHitLoc );
	}
	
	self ScrAgentSetPhysicsMode( get_death_anim_physics_mode( animState ) ); 
	self SetAnimState( animState, animIndex );
	
	self.body = get_clone_agent( animState, animIndex );
	
	self thread handle_ragdoll( self.body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath, animState );
}

get_primary_death_anim_state()
{
	// special death case 
	if ( isdefined( self.shocked ) && self.shocked )   //for electric fence, shock backwards anim
		return "electric_shock_death";   
	
	switch ( self.currentAnimState )
	{
	case "move":
		{
			if ( self.trajectoryActive )
				return "jump";
			else
				return "run";
		}
	case "idle":
		{
			return "idle";
		}
	case "melee":
		{
			if ( self.trajectoryActive )
				return "jump";
			if ( isDefined ( self.melee_in_move_back ) && self.melee_in_move_back )
				return "idle";
			else
				return "run";
		}
	case "traverse":
		{
			return "idle";
		}
	default:
		{
			AssertMsg( "currentAnimState: " + self.currentAnimState + " does not have a death anim mapping." );
		}
	}
}

is_special_death( primary_animState )
{
	switch ( primary_animState )
	{
	case "electric_shock_death":  
		return true;
	default:
		return false;
	}
}

get_death_anim_physics_mode( anim_state )
{
	switch ( anim_state )
	{
	case "electric_shock":   // so alien doesn't get stuck on electric fence geo
		return "noclip";  
	default:
		return "gravity";
	}
}

get_clone_agent( animState, animIndex )
{
	animEntry = self GetAnimEntry( animState, animIndex );
	animLength = GetAnimLength( animEntry );
	if ( AnimHasNotetrack( animEntry, "start_ragdoll" ) )
	{
		notetracks = GetNotetrackTimes( animEntry, "start_ragdoll" );
		assert( notetracks.size > 0 );
		animLength *= notetracks[0];
	}
	    		
	deathAnimDuration = int( animLength * 1000 ); // duration in milliseconds
	
	return ( self CloneAgent( deathAnimDuration ) );
}

handle_ragdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath, animState )
{
	delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );

	// electric fence shock does physics to send aliens flying
	// TODO: Remove once death animation for shock_death does this
	if ( animState == "shock_death" )
	{
		self notify( "in_ragdoll", body.origin );
	}
}

//=======================================================
//				enableAlienScripted
//=======================================================
enableAlienScripted()
{
	self.alien_scripted = true;
	self notify( "alien_main_loop_restart" );
}

//=======================================================
//				disableAlienScripted
//=======================================================
disableAlienScripted()
{
	self.alien_scripted = false;
}

//===========================================
// 			setAlienLoadout
//===========================================
setAlienLoadout()
{
	level.alien_loadout["loadoutPrimary"] 				= "none";
	level.alien_loadout["loadoutPrimaryAttachment"]		= "none";
	level.alien_loadout["loadoutPrimaryAttachment2"]	= "none";
	level.alien_loadout["loadoutPrimaryBuff"]			= "specialty_null";
	level.alien_loadout["loadoutPrimaryCamo"]			= "none";
	level.alien_loadout["loadoutPrimaryReticle"]		= "none";
	
	level.alien_loadout["loadoutSecondary"]				= "iw6_alienp226";	
	level.alien_loadout["loadoutSecondaryAttachment"]	= "none";
	level.alien_loadout["loadoutSecondaryAttachment2"]	= "none";
	level.alien_loadout["loadoutSecondaryBuff"]			= "specialty_null";
	level.alien_loadout["loadoutSecondaryCamo"]			= "none";
	level.alien_loadout["loadoutSecondaryReticle"]		= "none";
	
	level.alien_loadout["loadoutEquipment"]				= "none";
	level.alien_loadout["loadoutOffhand"]				= "none";
	
	level.alien_loadout["loadoutPerk1"]					= "specialty_pistoldeath";	// Last Stand
	level.alien_loadout["loadoutPerk2"]					= "specialty_null";
	level.alien_loadout["loadoutPerk3"]					= "specialty_null";
	
	level.alien_loadout["loadoutActiveAbility"]			= "specialty_null";		
	level.alien_loadout["loadoutPassiveAbility"]		= "specialty_null";
	level.alien_loadout["loadoutJuggernaut"] 			= false;
}

pistol_ammo_regen( item )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	// First ensure the player has at least a single clip of ammo for each weapon
	weapList = self GetWeaponsListPrimaries();
	foreach( weap in weapList )
	{
		baseweapon = GetWeaponBaseName( weap );
		if (baseweapon == "iw6_alienp226_mp" )
		{
			clipSize = WeaponClipSize( weap );
			self SetWeaponAmmoClip( weap, clipSize );
		}
	}
		
	regen_interval = 0.2; // 5 bullets per second
	
	while( 1 )
	{
		weapList = self GetWeaponsListPrimaries();
		foreach( weap in weapList )
		{
			baseweapon = GetWeaponBaseName( weap );
			if ( baseweapon == "iw6_alienp226_mp" )
			{
				ammoStock = self GetWeaponAmmoStock( weap );
				self SetWeaponAmmoStock( weap, ammoStock + 1 );
			}
		}
		
		wait( regen_interval );
	}
}

//===========================================
// 		bypassClassChoiceFunc
//===========================================
bypassClassChoiceFunc()
{
		// Players
	return "gamemode";
}

//===========================================
// 		Callback_PlayerLastStandAlien
//===========================================
Callback_PlayerLastStandAlien( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{	
	self notify( "last_stand" );
	
	self.inLastStand 		= true;
	self.lastStand 			= true;
	self.ignoreme			= true;
	self.health 			= 1;
	
	registerLastStandParameter( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc );
	
	maps\mp\alien\_gamescore::update_team_bonus( "team_casualties" );
	
	if( !mayDoLastStandAlien( self ) )
	{
		self.useLastStandParams = true;
		self.reviveIcon = maps\mp\alien\_hud::makeReviveIcon( ( 1.0, 0.0, 0.0 ) );
		self thread lastStandWaittillDeathAlien();
		self thread lastStandBleedOutAlien( self.origin, self.angles );
		return;
	}
			
	self store_weapons_status();
	self only_use_weapon( "iw6_alienp226_mp" );
	
	self _disableUsability();
	self player_lose_lastStand();
	self thread lastStandReviveAlien();
}

//===========================================
// 		registerLastStandParameter
//===========================================
registerLastStandParameter( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc )
{
	lastStandParams 					= spawnStruct();
	lastStandParams.eInflictor 			= eInflictor;
	lastStandParams.attacker 			= attacker;
	lastStandParams.iDamage 			= iDamage;
	lastStandParams.attackerPosition 	= attacker.origin;
	lastStandParams.sMeansOfDeath 		= sMeansOfDeath;
	lastStandParams.sWeapon 			= sWeapon;
	lastStandParams.vDir 				= vDir;
	lastStandParams.sHitLoc 			= sHitLoc;
	lastStandParams.lastStandStartTime 	= getTime();
	
	if( IsDefined( attacker ) && IsPlayer( attacker ) && (attacker getCurrentPrimaryWeapon() != "none") )
		lastStandParams.sPrimaryWeapon = attacker getCurrentPrimaryWeapon();
	else
		lastStandParams.sPrimaryWeapon = undefined;
	
	self.lastStandParams 	= lastStandParams;
}

//===========================================
// 		onlyUseLastStandWeapon
//===========================================
only_use_weapon( weapon )
{
	self _giveWeapon( weapon );
	self SwitchToWeapon( weapon );
	self DisableWeaponSwitch();
}

//===========================================
// 			mayDoLastStandAlien
//===========================================
mayDoLastStandAlien( player )
{
	if ( alien_mode_has( "nogame" ) )
	    return true;
	
	return player.haveLastStandAvailable;
}

//===========================================
// 			lastStandReviveAlien
//===========================================
lastStandReviveAlien()
{
	self endon( "disconnect" );
	self endon( "revive");
	level endon( "game_ended" );
	
	level notify ( "player_last_stand" );
	
	BLEED_OUT_TIME = 20;

	if ( gameShouldEnd( self ) )
	{
		AlienEndGame();
		return;
	}
	
	reviveEnt = spawn( "script_model", self.origin );
	
	if ( self shouldRevive() )
    {
		self thread self_revive( reviveEnt );
    }
	else
	{  	
		self thread lastStandWaittillDeathAlien();
		
		reviveEnt setModel( "tag_origin" );
		reviveEnt setCursorHint( "HINT_NOICON" );
		reviveEnt setHintString( &"PLATFORM_REVIVE" );
		reviveEnt linkTo( self );
		reviveEnt makeUsable();
		reviveEnt.owner = self;
		reviveEnt.inUse = false;
		reviveEnt.targetname = "revive_trigger";
		reviveEnt maps\mp\gametypes\_damage::updateUsableByTeam( self.team );
		reviveEnt thread maps\mp\gametypes\_damage::trackTeamChanges( self.team );
		reviveEnt thread maps\mp\gametypes\_damage::deleteOnReviveOrDeathOrDisconnect();
		reviveEnt thread lastStandWaittillLifeRecived();
		reviveEnt endon ( "death" );
		reviveEnt endon ( "disconnect" );
		self.revive_trigger = reviveEnt;
		
		self.reviveIcon = maps\mp\alien\_hud::makeReviveIcon( (0.33, 0.75, 0.24) );
		
		self thread maps\mp\alien\_hud::lastStandTimerAlien( BLEED_OUT_TIME );
		self thread lastStandKeepOverlayAlien();
		self thread maps\mp\alien\_hud::lastStandUpdateReviveIconColorAlien( reviveEnt, self.reviveIcon, BLEED_OUT_TIME);
		
		level thread maps\mp\alien\_music_and_dialog::playVOForDowned();
		
		wait( BLEED_OUT_TIME );
		
		self thread lastStandBleedOutAlien( self.origin, self.angles );
	}
}

shouldRevive()
{
	if ( alien_mode_has( "nogame" ) )
	    return true;
	
	if ( self has_loot( "item_revive_booster" ) )
		return true;
	
	if ( !alien_mode_has( "kill_resource" ) && self has_loot( "item_health_pack" ) )
		return true;
	
	return false;
}

//=========================================== 
//			Self Revive
//===========================================
self_revive( reviveEnt)
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	wait( 3 );
	self lastStandRespawnPlayerAlien( reviveEnt );
	
	if ( alien_mode_has( "loot" ) && self has_loot( "item_revive_booster" ) )
	{
		self take_loot( "item_revive_booster", 1 );
		self setLowerMessage( "self revived", &"ALIEN_COLLECTIBLES_SELF_REVIVED", 4 );
	}
	else if ( !alien_mode_has( "kill_resource" ) && alien_mode_has( "loot" ) && self has_loot( "item_health_pack" ) )
	{
	 	self take_loot( "item_health_pack", 1 );
	 	self setLowerMessage( "health revived", &"ALIEN_COLLECTIBLES_HEALTH_REVIVED", 4 );
	}
}


//===========================================
// 			lastStandBleedOutAlien
//===========================================
lastStandBleedOutAlien( respawn_loc, respawn_angles )
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	if ( gameShouldEnd( self ) )
	{
		AlienEndGame();
		return;
	}

	wait 0.05; // Clear out callstack to prevent overrun

	self store_weapons_status();
	
	self wait_in_spectator( respawn_loc, respawn_angles );
	self notify ( "death" );
	self updateSessionState( "playing" );
	
	self thread maps\mp\gametypes\_playerlogic::spawnPlayer( true );
	self.health = getHealthCap();
	//self thread onSpawnPlayer(); // spawnPlayer() already calls onSpawnPlayer()...
	
	self EnableWeaponSwitch();
	self thread restore_weapons_status();
}

// ----------- Helper functions for wait in spectator ------------
wait_in_spectator( respawn_loc, respawn_angles )
{	
	// self is dead player
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	SPECTATOR_REVIVE_TIME = 6000;  //in ms
	
	self thread maps\mp\gametypes\_playerlogic::respawn_asSpectator();
	
	self.forceSpawnOrigin = respawn_loc;
	self.forceSpawnAngles = respawn_angles;
	
	// NOW WE PLAY THE WAITING GAME >:D
	corpse = spawn( "script_model", respawn_loc, 0 );
	corpse setmodel( "ld_death_ground_pose_02" );
	corpse setCursorHint( "HINT_NOICON" );
	corpse setHintString( &"PLATFORM_REVIVE" );
	corpse makeUsable();
	corpse thread deleteCorpse( self );
	self.reviveIcon SetTargetEnt( corpse );
	
	while ( isdefined( self ) && isdefined( corpse ) )
	{
		// wait for friendly player to use
		corpse waittill ( "trigger", player );

		revive_success = get_revive_result( self, player, corpse, SPECTATOR_REVIVE_TIME );
		
		if ( revive_success )
		{
			//Clean up corpse
			corpse delete();
			
			//Clean up icon	
			if( isDefined ( self.reviveIcon ) )
				self.reviveIcon destroy();
			
			player maps\mp\alien\_gamescore::update_personal_bonus( "teammate_revive" );
			
			return;
		}
		else
		{
			wait 0.05;
			continue;
		}
	}
}

get_revive_result( downed_player, reviver, use_entity, use_time )
{
	if ( !isplayer( reviver ) )
		return false;

	reviver.isCapturingCrate = true;
	
	// links reviver in place and display bar
	useEnt = use_entity createUseEnt();
	useEnt.owner = downed_player;
	result = useEnt useHoldThink( reviver, use_time );
	
	if ( IsDefined( useEnt ) )
		useEnt delete();
	
	reviver.isCapturingCrate = false;
	
	return result;
}

deleteCorpse( owner )
{
	self endon( "death" );
	owner waittill( "disconnect" );
	
	self MakeUnusable();
}

createUseEnt()
{
	useEnt = Spawn( "script_origin", self.origin );
	useEnt.curProgress = 0;
	useEnt.useTime = 0;
	useEnt.useRate = 8000;
	useEnt.inUse = false;
	useEnt thread deleteUseEnt( self );
	return useEnt;
}

deleteUseEnt( owner )
{
	self endon ( "death" );
	owner waittill( "death" );
	self delete();
}

//===========================================
// 			lastStandWaittillDeathAlien
//===========================================
lastStandWaittillDeathAlien()
{
	self endon( "disconnect" );
	self endon( "revive" );
	level endon( "game_ended" );
	
	self waittill( "death" );

//	self clearLowerMessage( "last_stand" );
	self.lastStand 			= undefined;
	self.inLastStand 		= false;
	self.ignoreme			= false;
}

//===========================================
// 			reviveTriggerThinkAlien
//===========================================
reviveTriggerThinkAlien()
{
	self endon ( "death" );
	level endon ( "game_ended" );
	
	self MakeUsable();
	self waittill ( "trigger", player );
	self makeUnUsable();
	
/*	if ( IsPlayer( player ) )
	{
		player thread maps\mp\gametypes\_hud_message::SplashNotifyDelayed( "reviver", 200 );
		player thread maps\mp\gametypes\_rank::giveRankXP( "reviver", 200 );
	}
*/	
	self.owner notify ( "revive_trigger", player );

	return;
}

//===========================================
// 		lastStandWaittillLifeRecived
//===========================================
lastStandWaittillLifeRecived()
{
	self endon( "death" );
	level endon( "game_ended" );
	
	NORMAL_REVIVE_TIME = 1000; //in ms
	
	player = self.owner;
	
	while ( true )
	{
		self thread reviveTriggerThinkAlien();
		player waittill( "revive_trigger", reviver );
		
		revive_success = get_revive_result( player, reviver, self, NORMAL_REVIVE_TIME );
		
		if ( revive_success )
			break;
		else
			continue;
	}
	
	reviver maps\mp\alien\_gamescore::update_personal_bonus( "teammate_revive" );
	
	player EnableWeaponSwitch();
	player restore_weapons_status();
	
	player.reviveIcon destroy();
	player lastStandRespawnPlayerAlien( self );
}

//===========================================
// 		lastStandRespawnPlayerAlien
//===========================================
lastStandRespawnPlayerAlien( reviveEnt )
{
	AFTER_REVIVE_DAMAGE_SHIELD_TIME = 3000; // in ms
	
	self notify ( "revive" );
	
	self.lastStand 			= undefined;
	self.inLastStand		= false;
	self.headicon 			= "";
	self.health 			= getHealthCap();
	self.moveSpeedScaler 	= 1;
	self.revived 			= true;
	self.ignoreme			= false;
	self.haveInvulnerabilityAvailable = true;
	self.damageShieldExpireTime = getTime() + AFTER_REVIVE_DAMAGE_SHIELD_TIME;
		
	if( self _hasPerk( "specialty_lightweight" ) )
	{
		self.moveSpeedScaler = lightWeightScalar();
	}
	
	self LastStandRevive();
	self setStance( "crouch" );
	self _enableUsability();
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale();	
	self clearLowerMessage( "last_stand" );
	self givePerk( "specialty_pistoldeath", false );
	
	level thread maps\mp\alien\_music_and_dialog::playVOForRevived();
	reviveEnt delete();
}

//===========================================
// 			lastStandKeepOverlayAlien
//===========================================
lastStandKeepOverlayAlien()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "revive" );
	level endon( "game_ended" );
	
	// keep the health overlay going by making code think the player is getting damaged
	while ( !level.gameEnded )
	{
		self.health = 2;
		wait .05;
		self.health = 1;
		wait .5;
	}
}

//===========================================
//       alienPlayerHealthRegen()
//===========================================
alienPlayerHealthRegen()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	self endon ( "faux_spawn" );
	level endon ( "game_ended" );
		
	self thread maps\mp\alien\_music_and_dialog::alienPlayerPainBreathingSound();
	
	while ( true )
	{	
		self waittill( "damage" );
		
		if ( !canRegenHealth() )
			continue;
		
		self.regenSpeed = getRegenSpeed();
		healthCap = getHealthCap();
		healthRatio = self.health / healthCap;
		
		self thread healthRegen( getTime(), healthRatio, healthCap );
		self thread maps\mp\gametypes\_healthoverlay::breathingManager( getTime(), healthRatio );
	}
}

alienPlayerArmor()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	self endon( "faux_spawn" );
	self endon( "game_ended" );

	if ( !isDefined( self.lightArmorHP ) )
	{
		self.lightArmorHP = 0;
	}
	self SetCoopPlayerData( "alienSession", "armor", 0 );	
	previous_armor = 0;
	
	while ( true )
	{
		self waittill_any( "player_damaged", "enable_armor" );
		if ( !isDefined( self.lightArmorHP ) )
		{
			if ( previous_armor > 0 )
			{
				self SetCoopPlayerData( "alienSession", "armor", 0 );
				previous_armor = 0;
			}
		}
		else if ( previous_armor != self.lightArmorHP )
		{
			self SetCoopPlayerData( "alienSession", "armor", self.lightArmorHP );
			previous_armor = self.lightArmorHP;
		}
	}
}

//===========================================
//       getHealthCap()
//===========================================
getHealthCap()
{
	if ( IsDefined( self.isHealthBoosted ) )
		self.healthRegenMaxPercent = 0.5;
	else
		self.healthRegenMaxPercent = DEFAULT_REGEN_CAP;
	
	cap = clamp( self.maxhealth * self.healthRegenMaxPercent, 0, self.maxhealth );
	return int( cap );
}

//===========================================
//       canRegenHealth()
//===========================================
canRegenHealth()
{
	if ( isDefined ( self.inLastStand ) && self.inLastStand )
	{
		return false;
	}
	return true;
}

//===========================================
//       getRegenSpeed()
//===========================================
getRegenSpeed()
{
//	if( self _hasPerk( "specialty_regenfaster" ) )
//		return ( self.regenSpeed * level.regenHealthMod );
//	else
		return self.regenSpeed;
}

//===========================================
//       healthRegen()
//===========================================
healthRegen( hurtTime, healthRatio, healthCap )
{
	self notify( "healthRegeneration" );
	self endon ( "healthRegeneration" );
	
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	level endon ( "game_ended" );
	
	if ( isHealthRegenDisabled() )
		return;
	
	regenData = spawnStruct();
	getRegenData( regenData );
	
	wait ( regenData.activateTime );
	
	while ( true )
	{
		regenData = spawnStruct();
		getRegenData( regenData );
		
		if ( self.health < Int ( healthCap ))
			if ( ( self.health + regenData.regenAmount ) > Int ( healthCap ) )
				self.health = Int ( healthCap );
			else
				self.health += regenData.regenAmount;
		else
			break;
		
		wait( regenData.waitTimeBetweenRegen );
	}
		
	self notify( "healed" );
	
	player_init_invulnerability();
	
	//fully regenerated
	self maps\mp\gametypes\_damage::resetAttackerList();
}

//===========================================
//       getRegenData()
//===========================================
getRegenData( regenData )
{
	//<Note J.C.>Potentially based on self.regenSpeed or some buffs? Return default value for now
	if ( IsDefined( self.isHealthBoosted ) )
	{
		regenData.activateTime = DEFAULT_REGEN_ACTIVATE_TIME * 0.05;
		regenData.waitTimeBetweenRegen = DEFAULT_WAIT_TIME_BETWEEN_REGEN * 0.25;
		regenData.regenAmount = DEFAULT_REGEN_HEALTH_AMOUNT * 100;
	}
	else
	{
		regenData.activateTime = DEFAULT_REGEN_ACTIVATE_TIME;
		regenData.waitTimeBetweenRegen = DEFAULT_WAIT_TIME_BETWEEN_REGEN;
		regenData.regenAmount = DEFAULT_REGEN_HEALTH_AMOUNT;
	}
}

//===========================================
//       isHealthRegenDisabled()
//===========================================
isHealthRegenDisabled()
{
	return (( IsDefined( level.healthRegenDisabled ) && level.healthRegenDisabled ) ||
	        ( IsDefined( self.healthRegenDisabled ) && self.healthRegenDisabled ));
}


//===========================================
//       uiDvars()
//===========================================
resetUIDvarsOnSpawn()
{

}

resetUIDvarsOnConnect()
{
	self SetClientOmnvar( "ui_alien_max_currency", self.maxCurrency );
}

resetUIDvarsOnSpectate()
{

}

//========================================================
//			alien_make_entity_sentient
//========================================================
alien_make_entity_sentient( team, expendable )
{
	if ( self should_make_entity_sentient() )
	{
		if ( IsDefined( expendable ) ) 
			return self MakeEntitySentient( team, expendable );	
		else
			return self MakeEntitySentient( team );	
	}
}

should_make_entity_sentient()
{
	// Sentry
	if ( IsDefined( self.sentryType ) )
	{
		return true;
	}
	
	// IMS
	if ( IsDefined( self.imsType ) )
	{
		return true;
	}
	
	// Drill
	if ( IsDefined( level.drill ) && self == level.drill )
	{
		return true;
	}
	
	return false;	
}