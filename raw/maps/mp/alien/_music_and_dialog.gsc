#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	
	// TEMP: Remove references to "team"
	while ( !isDefined( game[ "allies" ] ) )
	{
		wait 0.05;
	}	
	
	//using allies defaults for all this stuff for now.
	if( level.multiTeamBased )
	{
		for( i = 0; i < level.teamNameList.size; i++ )
		{
			str_spawn_team = "spawn_" + level.teamNameList[i];
			str_defeat_team = "defeat_" + level.teamNameList[i];
			str_victory_team = "victory_" + level.teamNameList[i];
			str_winning_team = "winning_" + level.teamNameList[i];
			str_losing_team = "losing_" + level.teamNameList[i];
			
			game["music"][str_spawn_team] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "spawn_music";
			game["music"][str_defeat_team] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "defeat_music";
			game["music"][str_victory_team] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "victory_music";
			game["music"][str_winning_team] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "winning_music";
			game["music"][str_losing_team] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "losing_music";
			game["voice"][level.teamNameList[i]] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "1mc_";
		}
	}
	else
	{
		game["music"]["spawn_allies"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "spawn_music";
		game["music"]["defeat_allies"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "defeat_music";
		game["music"]["victory_allies"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "victory_music";
		game["music"]["winning_allies"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "winning_music";
		game["music"]["losing_allies"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "losing_music";
		game["voice"]["allies"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "allies" ) + "1mc_";

		game["music"]["spawn_axis"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "axis" ) + "spawn_music";
		game["music"]["defeat_axis"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "axis" ) + "defeat_music";
		game["music"]["victory_axis"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "axis" ) + "victory_music";
		game["music"]["winning_axis"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "axis" ) + "winning_music";
		game["music"]["losing_axis"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "axis" ) + "losing_music";
		game["voice"]["axis"] = maps\mp\gametypes\_teams::getTeamVoicePrefix( "axis" ) + "1mc_";
	}
	
	game["music"]["losing_time"] = "mp_time_running_out_losing";
	
	game["music"]["suspense"] = [];
	game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_01";
	game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_02";
	game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_03";
	game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_04";
	game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_05";
	game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_06";

	game["dialog"]["mission_success"] = "null";
	game["dialog"]["mission_failure"] = "null";
	game["dialog"]["mission_draw"] = "null";

	game["dialog"]["round_success"] = "null";
	game["dialog"]["round_failure"] = "null";
	game["dialog"]["round_draw"] = "null";
	
	// status
	game["dialog"]["timesup"] = "null";
	game["dialog"]["winning_time"] = "null";
	game["dialog"]["losing_time"] = "null";
	game["dialog"]["winning_score"] = "null";
	game["dialog"]["losing_score"] = "null";
	game["dialog"]["lead_lost"] = "null";
	game["dialog"]["lead_tied"] = "null";
	game["dialog"]["lead_taken"] = "null";
	game["dialog"]["last_alive"] = "null";

	game["dialog"]["boost"] = "null";

	if ( !isDefined( game["dialog"]["null"] ) )
		game["dialog"]["offense_obj"] = "null";
	if ( !isDefined( game["dialog"]["null"] ) )
		game["dialog"]["defense_obj"] = "null";
	
	game["dialog"]["hardcore"] = "null";
	game["dialog"]["highspeed"] = "null";
	game["dialog"]["tactical"] = "null";

	game["dialog"]["challenge"] = "null";
	game["dialog"]["promotion"] = "null";

	game["dialog"]["bomb_taken"] = "null";
	game["dialog"]["bomb_lost"] = "null";
	game["dialog"]["bomb_defused"] = "null";
	game["dialog"]["bomb_planted"] = "null";

	game["dialog"]["obj_taken"] = "null";
	game["dialog"]["obj_lost"] = "null";

	game["dialog"]["obj_defend"] = "null";
	game["dialog"]["obj_destroy"] = "null";
	game["dialog"]["obj_capture"] = "null";
	game["dialog"]["objs_capture"] = "null";

	game["dialog"]["hq_located"] = "null";
	game["dialog"]["hq_enemy_captured"] = "null";
	game["dialog"]["hq_enemy_destroyed"] = "null";
	game["dialog"]["hq_secured"] = "null";
	game["dialog"]["hq_offline"] = "null";
	game["dialog"]["hq_online"] = "null";

	game["dialog"]["move_to_new"] = "null";

	game["dialog"]["push_forward"] = "pushforward";

	game["dialog"]["attack"] = "null";
	game["dialog"]["defend"] = "null";
	game["dialog"]["offense"] = "null";
	game["dialog"]["defense"] = "null";

	game["dialog"]["halftime"] = "null";
	game["dialog"]["overtime"] = "null";
	game["dialog"]["side_switch"] = "null";

	game["dialog"]["flag_taken"] = "null";
	game["dialog"]["flag_dropped"] = "null";
	game["dialog"]["flag_returned"] = "null";
	game["dialog"]["flag_captured"] = "null";
	game["dialog"]["flag_getback"] = "null";
	game["dialog"]["enemy_flag_bringhome"] = "null";
	game["dialog"]["enemy_flag_taken"] = "null";
	game["dialog"]["enemy_flag_dropped"] = "null";
	game["dialog"]["enemy_flag_returned"] = "null";
	game["dialog"]["enemy_flag_captured"] = "null";
	
	game["dialog"]["got_flag"] = "null";
	game["dialog"]["dropped_flag"] = "null";
	game["dialog"]["enemy_got_flag"] = "null";
	game["dialog"]["enemy_dropped_flag"] = "null";	

	game["dialog"]["capturing_a"] = "null";
	game["dialog"]["capturing_b"] = "null";
	game["dialog"]["capturing_c"] = "null";
	game["dialog"]["captured_a"] = "null";
	game["dialog"]["captured_b"] = "null";
	game["dialog"]["captured_c"] = "null";

	game["dialog"]["securing_a"] = "null";
	game["dialog"]["securing_b"] = "null";
	game["dialog"]["securing_c"] = "null";
	game["dialog"]["secured_a"] = "null";
	game["dialog"]["secured_b"] = "null";
	game["dialog"]["secured_c"] = "null";

	game["dialog"]["losing_a"] = "null";
	game["dialog"]["losing_b"] = "null";
	game["dialog"]["losing_c"] = "null";
	game["dialog"]["lost_a"] = "null";
	game["dialog"]["lost_b"] = "null";
	game["dialog"]["lost_c"] = "null";

	game["dialog"]["enemy_taking_a"] = "null";
	game["dialog"]["enemy_taking_b"] = "null";
	game["dialog"]["enemy_taking_c"] = "null";
	game["dialog"]["enemy_has_a"] = "null";
	game["dialog"]["enemy_has_b"] = "null";
	game["dialog"]["enemy_has_c"] = "null";

	game["dialog"]["lost_all"] = "null";
	game["dialog"]["secure_all"] = "null";
	
	game["dialog"]["losing_target"] = "null";
	game["dialog"]["lost_target"] = "null";
	game["dialog"]["taking_target"] = "null";
	game["dialog"]["took_target"] = "null";
	game["dialog"]["defcon_raised"] = "null";
	game["dialog"]["defcon_lowered"] = "null";
	game["dialog"]["one_minute_left"] = "null";
	game["dialog"]["thirty_seconds_left"] = "null";	

	game["dialog"]["destroy_sentry"] = "null";
	game["music"]["nuke_music"] = "nuke_music";

	game["dialog"]["sentry_gone"] = "null";
	game["dialog"]["sentry_destroyed"] = "null";
	game["dialog"]["ti_gone"] = "null";
	game["dialog"]["ti_destroyed"] = "null";
	
	game["dialog"]["ims_destroyed"] = "null";
	game["dialog"]["lbguard_destroyed"] = "null";
	game["dialog"]["ballistic_vest_destroyed"] = "null";
	game["dialog"]["remote_sentry_destroyed"] = "null";
	game["dialog"]["sam_destroyed"] = "null";
	game["dialog"]["sam_gone"] = "null";
	
	game["dialog"]["backup_destroyed"] = "null";
	game["dialog"]["gpsb_destroyed"] = "null";
	game["dialog"]["radar_destroyed"] = "null";

	game["dialog"]["claymore_destroyed"] = "null";
	game["dialog"]["mine_destroyed"] = "null";

	level thread onPlayerConnect();
	level thread onLastAlive();
	level thread musicController();
	level thread onGameEnded();
	level thread onRoundSwitch();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill ( "connected", player );

		player thread onPlayerSpawned();
		player thread finalKillcamMusic();
	}
}


onPlayerSpawned()
{
	self endon ( "disconnect" );

	self waittill( "spawned_player" );

	if ( !level.splitscreen || level.splitscreen && !isDefined( level.playedStartingMusic ) )
	{
		//only play one spawn music
		if( !self isSplitscreenPlayer() || self isSplitscreenPlayerPrimary() )
			self playLocalSound( game["music"]["spawn_" + self.team] );
		
		if ( level.splitscreen )
			level.playedStartingMusic = true;
	}

	/*if ( isDefined( game["dialog"]["gametype"] ) && (!level.splitscreen || self == level.players[0]) )
	{
		if ( isDefined( game["dialog"]["allies_gametype"] ) && self.team == "allies" )
			self leaderDialogOnPlayer( "allies_gametype" );
		else if ( isDefined( game["dialog"]["axis_gametype"] ) && self.team == "axis" )
			self leaderDialogOnPlayer( "axis_gametype" );
		else if ( !self isSplitscreenPlayer() || self isSplitscreenPlayerPrimary() )
			self leaderDialogOnPlayer( "gametype" );
	}
	*/

	gameFlagWait( "prematch_done" );
	/*
	if ( self.team == game["attackers"] )
	{
		if( !self isSplitscreenPlayer() || self isSplitscreenPlayerPrimary() )
			self leaderDialogOnPlayer( "offense_obj", "introboost" );
	}
	else
	{
		if( !self isSplitscreenPlayer() || self isSplitscreenPlayerPrimary() )
			self leaderDialogOnPlayer( "defense_obj", "introboost" );
	}
	*/
}


onLastAlive()
{
	level endon ( "game_ended" );

	level waittill ( "last_alive", player );
	
	if ( !isAlive( player )	)
		return;
	/*
	player leaderDialogOnPlayer( "last_alive" );
	*/
}


onRoundSwitch()
{
	level waittill ( "round_switch", switchType );

	switch( switchType )
	{
		case "halftime":
			foreach ( player in level.players )
			{
				if( player isSplitscreenPlayer() && !player isSplitscreenPlayerPrimary() )
					continue;
				/*
				player leaderDialogOnPlayer( "halftime" );
				*/
			}
			break;
		case "overtime":
			foreach ( player in level.players )
			{
				if( player isSplitscreenPlayer() && !player isSplitscreenPlayerPrimary() )
					continue;
				
				/*
				player leaderDialogOnPlayer( "overtime" );
				*/
			
			}
			break;
		default:
			foreach ( player in level.players )
			{
				if( player isSplitscreenPlayer() && !player isSplitscreenPlayerPrimary() )
					continue;
				
				/*
				player leaderDialogOnPlayer( "side_switch" );
				*/
			}
			break;
	}
}


onGameEnded()
{
	level thread roundWinnerDialog();
	level thread gameWinnerDialog();
	
	level waittill ( "game_win", winner );
	
	if ( level.teamBased )
	{
		if ( level.splitscreen )
		{
			if ( winner == "allies" )
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
			else if ( winner == "axis" )
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
			else
				playSoundOnPlayers( game["music"]["nuke_music"] );
		}
		else
		{
			if ( winner == "allies" )
			{
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
				playSoundOnPlayers( game["music"]["defeat_axis"], "axis" );
			}
			else if ( winner == "axis" )
			{
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
				playSoundOnPlayers( game["music"]["defeat_allies"], "allies" );
			}
			else
			{
				playSoundOnPlayers( game["music"]["nuke_music"] );
			}
		}
	}
	else
	{
		foreach ( player in level.players )
		{
			if( player isSplitscreenPlayer() && !player isSplitscreenPlayerPrimary() )
						continue;

			if ( player.pers["team"] != "allies" && player.pers["team"] != "axis" )
				player playLocalSound( game["music"]["nuke_music"] );			
			else if ( isDefined( winner ) && isPlayer( winner ) && player == winner )
				player playLocalSound( game["music"]["victory_" + player.pers["team"] ] );
			else if ( !level.splitScreen )
				player playLocalSound( game["music"]["defeat_" + player.pers["team"] ] );
		}
	}
}


roundWinnerDialog()
{
	level waittill ( "round_win", winner );

	delay = level.roundEndDelay / 4;
	if ( delay > 0 )
		wait ( delay );

	if ( !isDefined( winner ) || isPlayer( winner ) /*|| isDefined( level.nukeDetonated )*/ )
		return;
	/*
	if ( winner == "allies" )
	{
		leaderDialog( "round_success", "allies" );
		leaderDialog( "round_failure", "axis" );
	}
	else if ( winner == "axis" )
	{
		leaderDialog( "round_success", "axis" );
		leaderDialog( "round_failure", "allies" );
	}
	*/
}


gameWinnerDialog()
{
	level waittill ( "game_win", winner );
	
	delay = level.postRoundTime / 2;
	if ( delay > 0 )
		wait ( delay );

	if ( !isDefined( winner ) || isPlayer( winner ) /*|| isDefined( level.nukeDetonated )*/ )
		return;
	/*
	if ( winner == "allies" )
	{
		leaderDialog( "mission_success", "allies" );
		leaderDialog( "mission_failure", "axis" );
	}
	else if ( winner == "axis" )
	{
		leaderDialog( "mission_success", "axis" );
		leaderDialog( "mission_failure", "allies" );
	}
	else
	{
		leaderDialog( "mission_draw" );
	}	
	*/
}


musicController()
{
	level endon ( "game_ended" );
	
	if ( !level.hardcoreMode )
		thread suspenseMusic();
	
	level waittill ( "match_ending_soon", reason );
	assert( isDefined( reason ) );

	if ( getWatchedDvar( "roundlimit" ) == 1 || game["roundsPlayed"] == (getWatchedDvar( "roundlimit" ) - 1) )
	{	
		if ( !level.splitScreen )
		{
			if ( reason == "time" )
			{
				if ( level.teamBased )
				{
					if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_allies"], "allies" );
							playSoundOnPlayers( game["music"]["losing_axis"], "axis" );
						}
						/*
						leaderDialog( "winning_time", "allies" );
						leaderDialog( "losing_time", "axis" );
						*/
					}
					else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_axis"], "axis" );
							playSoundOnPlayers( game["music"]["losing_allies"], "allies" );
						}
						/*
						leaderDialog( "winning_time", "axis" );
						leaderDialog( "losing_time", "allies" );
						*/
					}
				}
				else
				{
					if ( !level.hardcoreMode )
						playSoundOnPlayers( game["music"]["losing_time"] );
					
					//leaderDialog( "timesup" );
				}
			}	
			else if ( reason == "score" )
			{
				if ( level.teamBased )
				{
					if ( game["teamScores"]["allies"] > game["teamScores"]["axis"] )
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_allies"], "allies" );
							playSoundOnPlayers( game["music"]["losing_axis"], "axis" );
						}
				
						//leaderDialog( "winning_score", "allies" );
						//leaderDialog( "losing_score", "axis" );
					}
					else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
					{
						if ( !level.hardcoreMode )
						{
							playSoundOnPlayers( game["music"]["winning_axis"], "axis" );
							playSoundOnPlayers( game["music"]["losing_allies"], "allies" );
						}
							
						//leaderDialog( "winning_score", "axis" );
						//leaderDialog( "losing_score", "allies" );
					}
				}
				else
				{
					winningPlayer = maps\mp\gametypes\_gamescore::getHighestScoringPlayer();
					losingPlayers = maps\mp\gametypes\_gamescore::getLosingPlayers();
					excludeList[0] = winningPlayer;

					if ( !level.hardcoreMode )
					{
						winningPlayer playLocalSound( game["music"]["winning_" + winningPlayer.pers["team"] ] );
						
						foreach ( otherPlayer in level.players )
						{
							if ( otherPlayer == winningPlayer )
								continue;
								
							otherPlayer playLocalSound( game["music"]["losing_" + otherPlayer.pers["team"] ] );							
						}
					}
	
					//winningPlayer leaderDialogOnPlayer( "winning_score" );
					//leaderDialogOnPlayers( "losing_score", losingPlayers );
				}
			}
			
			level waittill ( "match_ending_very_soon" );
			//leaderDialog( "timesup" );
		}
	}
	else
	{
		if ( !level.hardcoreMode )
			playSoundOnPlayers( game["music"]["losing_allies"] );

		//leaderDialog( "timesup" );
	}
}


suspenseMusic()
{
	level endon ( "game_ended" );
	level endon ( "match_ending_soon" );
	
	if ( IsDefined( level.noSuspenseMusic ) && level.noSuspenseMusic )
		return;
	
	numTracks = game["music"]["suspense"].size;
	wait ( 120 );
	
	for ( ;; )
	{
		wait ( randomFloatRange( 60, 120 ) );
		
		playSoundOnPlayers( game["music"]["suspense"][randomInt(numTracks)] ); 
	}
}


finalKillcamMusic()
{
	self waittill ( "showing_final_killcam" );
}

//===========================================
//       alienPlayerPainBreathingSound()
//===========================================
alienPlayerPainBreathingSound()
{	
	level endon ( "game_ended" );
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "joined_team" );
	self endon ( "joined_spectators" );
	
	wait ( 2 );

	while ( true )
	{
		wait ( 0.2 );
			
		if ( shouldPlayPainBreathingSound() )
		{
			self playLocalSound( "breathing_hurt" );
			wait ( .784 );
			wait ( 0.1 + randomfloat (0.8) );
		}
	}
}

//===========================================
//       shouldPlayPainBreathingSound()
//===========================================
VERY_HURT_HEALTH = 0.55; //If player's health ratio is below this value, he is considered very hurt
shouldPlayPainBreathingSound()
{
	if ( maps\mp\gametypes\aliens::isHealthRegenDisabled() ||
	     self isUsingRemote() ||
	     ( isDefined( self.breathingStopTime ) && gettime() < self.breathingStopTime ) ||   //Still playing previous pain sound
	     self.health > self.maxhealth * self.healthRegenMaxPercent * VERY_HURT_HEALTH   //Have enough health, not hurting
	   )
		return false;
	else
		return true;		
}

	
//============================================
//				Downed VO
//============================================
playVOForDowned()
{    vo_list = [ "p1_downed_01",
                 "p1_downed_02",
                 "p2_downed_01",
                 "p2_downed_01",
                 "p3_downed_01",
                 "p3_downed_02",
                 "p4_downed_01",
                 "p4_downed_02"
              ];
	playRandomVOline( vo_list );
}

playVOForRevived()
{
    vo_list = [ "p1_reviving_01",
                "p1_reviving_02",
                "p2_reviving_01",
                "p2_reviving_02",
                "p3_reviving_01",
                "p3_reviving_02",
                "p4_reviving_01",
                "p4_reviving_02"
              ];

	playRandomVOline( vo_list );
}

playVOForWaveStart()
{
	vo_list = [ "P1_trouble_02",
				"P1_trouble_01",
				"p2_trouble_02",
				"p2_trouble_01",
				"p4_trouble_01",
				"p4_trouble_02",
				"p3_trouble_01",
				"p3_trouble_02"
			  ];
	playRandomVOline( vo_list );
}

playVOForBombAboutDrop()
{
	vo_list = [ "o_drop_soon_03",
				"o_drop_soon_04",
				"o_drop_soon_01"
			  ];
	playRandomVOline( vo_list );
}

playVOForBombDetonate()
{
	vo_list = [ "o_return_trip_02",
				"o_return_trip_04",
				"o_return_trip_04b",
				"o_return_trip_05",
				"o_return_trip_06"
			  ];
	playRandomVOline( vo_list );
}

playVOForBombPlant()
{
	vo_list = [ "p1_planting_01",
				"p2_planting_01",
				"p4_planting_01",
				"p4_planting_02",
				"p3_defend_01",
				"p3_defend_02",
				"p4_defend_01",
				"p4_defend_02"
			  ];
	playRandomVOline( vo_list );
}

playVOForSpitterSpawn()
{
	vo_list = [ "p1_near_spitter_01",
				"p2_near_spitter_01",
				"p3_near_spitter_01",
				"p4_near_spitter_01"
			  ];
	playRandomVOline( vo_list );
}

playVOForQueenSpawn()
{
	vo_list = [ "p1_near_queen_01",
				"p2_near_queen_01",
				"p3_near_queen_01",
				"p4_near_queen_01"
			  ];
	playRandomVOline( vo_list );
}

playVOForBomDamaged()
{
	BOMB_DAMAGE_COOL_DOWN_TIME = 7000;  //in ms
	current_time = getTime();
	
	if ( !isDefined( level.next_bomb_damage_VO_time ) || level.next_bomb_damage_VO_time < current_time )
	{
		level.next_bomb_damage_VO_time = current_time + BOMB_DAMAGE_COOL_DOWN_TIME;
		
		vo_list = [ "p1_defend_attack_01",
					"p1_defend_attack_02",
					"p2_defend_attack_01",
					"p2_defend_attack_02",
					"p3_defend_attack_01",
					"p3_defend_attack_02",
					"p4_defend_attack_01",
					"p4_defend_attack_02"
				  ];
		playRandomVOline( vo_list );
	}
}

playRandomVOline( vo_list )
{
	random_index = RandomInt( vo_list.size );
	vo_alias = vo_list[ random_index ];
	playVOToAllPlayers ( vo_alias );
}

playVOToAllPlayers( alias )
{
	playSoundOnPlayers( alias, "allies" );
}