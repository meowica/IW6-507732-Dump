#include maps\_utility;
#include common_scripts\utility;
#include maps\_specialops;

emptyMissionDifficultyStr	= "00000000000000000000000000000000000000000000000000";

SOTABLE_COL_INDEX  = 0;
SOTABLE_COL_REF	   = 1;
SOTABLE_COL_NAME   = 2;
SOTABLE_COL_GROUP  = 13;
SOTABLE_COL_UNLOCK = 5;

main()
{

	level.specOpsGroups = [];
	
	// survival and mission group index 0-99
	for( i=0; i<100; i++ )
	{
		ref = tablelookup( "sp/specopstable.csv", SOTABLE_COL_INDEX, i, SOTABLE_COL_REF );
		if ( ref != "" )
			setupSoGroup( ref );
		else
			break;
	}
	
	specOpsSettings = maps\_endmission::createMission( "SPECIAL_OPS" );
	
	// number of survival maps on release of MW3
	release_survival_number = int( tablelookup( "sp/specopstable.csv", 0, "survival_count", 1 ) );
	
	//dlc_survival_number = 0;		// dlc maps do not track progress
	
	// survival levels index 100-199
	for( i=100; i<200; i++ )
	{
		internal_index = i - 100;
		ref = tablelookup( "sp/specopstable.csv", SOTABLE_COL_INDEX, i, SOTABLE_COL_REF );
		if ( ref != "" )
			specOpsSettings addSpecOpLevel( ref, internal_index );
		else
			break;
	}

	// mission levels index 200-299
	for( i=200; i<300; i++ )
	{
		internal_index = i - 200 + release_survival_number;
		ref = tablelookup( "sp/specopstable.csv", SOTABLE_COL_INDEX, i, SOTABLE_COL_REF );
		if ( ref != "" )
			specOpsSettings addSpecOpLevel( ref, internal_index );
		else
			break;
	}
	
	level.specOpsSettings = specOpsSettings;
}

setupSoGroup( so_ref )
{
	level.specOpsGroups[ so_ref ] 				= spawnStruct();
	level.specOpsGroups[ so_ref ].ref		 	= so_ref;
	level.specOpsGroups[ so_ref ].unlock		= int( tablelookup( "sp/specopstable.csv", SOTABLE_COL_REF, so_ref, SOTABLE_COL_UNLOCK ) );
}

setSoLevelCompleted( levelIndex )
{
	foreach( player in level.players )
	{
		if ( isdefined( player.eog_noreward ) && player.eog_noreward )
			continue;
			
		specOpsString = player GetLocalPlayerProfileData( "missionSOHighestDifficulty" );
		
		if ( !isdefined( specOpsString ) )
			continue;
		
		if ( isdefined( player.award_no_stars ) )
			continue;
		
		pre_total_stars = 0;
		for ( i = 0; i < specOpsString.size; i++ )
			pre_total_stars += max( 0, int( specOpsString[ i ] ) - 1 );

		if ( specOpsString.size == 0 )
			specOpsString = emptyMissionDifficultyStr;

		// if profile has no zeros for unplayed levels, we need to populate it with zeros
		while( levelIndex >= specOpsString.size )
			specOpsString += "0";
		
		// survival stars are calculated by waves, not difficulty
		stars = 0;
		if ( is_survival() )
		{
			stars = 0;
		}
		else
		{
			assertex( isdefined( level.specops_reward_gameskill ), "Game skill not setup correctly for coop." );
			stars = level.specops_reward_gameskill;
			
			if ( isdefined( player.forcedGameSkill ) )
				stars = player.forcedGameSkill;	
		}
		
		// only set record if more stars earned
		// difficulty of "4" is 3 stars, thus if 4>3 means we are already at 3 stars, so we skip
		if ( int( specOpsString[ levelIndex ] ) > stars )
			continue;
		
		newString = "";
		for ( index = 0; index < specOpsString.size; index++ )
		{
			if ( index != levelIndex )
				newString += specOpsString[ index ];
			else
				newString += stars + 1;
		}
		
		post_total_stars = 0;
		for ( i = 0; i < newString.size; i++ )
			post_total_stars += max( 0, int( newString[ i ] ) - 1 );
			
		delta_total_stars = post_total_stars - pre_total_stars;
		if ( delta_total_stars > 0 )
		{
			player.eog_firststar = is_first_difficulty_star( newString );
			player.eog_newstar = true;
			player.eog_newstar_value = delta_total_stars;
			
			foreach ( group in level.specOpsGroups )
			{
				if ( group.unlock == 0 )
					continue;
					
				if ( level.ps3 && isSplitscreen() && isdefined( level.player2 ) && player == level.player2 )
					continue;
					
				if ( pre_total_stars < group.unlock && post_total_stars >= group.unlock )
				{
					player.eog_unlock = true;
					player.eog_unlock_value = group.ref;
					
					// BELOW: no more groups in main menu thus we dont need "ui_last_opened_group" dvar set.
					/* 
					if ( getdvarint( "solo_play" ) && ( player == level.player ) )
						setdvar( "ui_last_opened_group", 0 );
					*/
				}
			}
			
			if ( post_total_stars >= 48 )
			{
				player.eog_unlock = true;
				player.eog_unlock_value = "so_completed";
				music_stop( 1 );
			}
		}
		
		if ( player maps\_specialops_code::can_save_to_profile() || ( isSplitscreen() && level.ps3 && isdefined( level.player2 ) && player == level.player2 ) )
			player SetLocalPlayerProfileData( "missionSOHighestDifficulty", newString );
	}
}

is_first_difficulty_star( specOpsString )
{
	// returns false if the current level does not require difficulty selection
	if ( !is_survival() )
	{
		if( int( tablelookup( "sp/specOpsTable.csv", 1, level.script, 14 ) ) == 0 )
			return false;
	}
	
	// number of survival maps on release of MW3
	release_survival_number = int( tablelookup( "sp/specopstable.csv", 0, "survival_count", 1 ) );
	release_mission_number 	= int( tablelookup( "sp/specopstable.csv", 0, "mission_count", 1 ) );
	release_total			= release_survival_number + release_mission_number;
	
	specOpsSum = 0;
	if ( is_survival() )
	{
		for( i=0; i<release_survival_number; i++ )
			specOpsSum += int( max ( 0, int( specOpsString[i] ) - 1 ) );
	}
	else
	{
		for( i=release_survival_number; i<release_total; i++ )
			specOpsSum += int( max ( 0, int( specOpsString[i] ) - 1 ) );
	}
	return ( specOpsSum == 1 );
}

addSpecOpLevel( levelName, internal_index )
{
	if ( isdefined( internal_index ) )
		levelIndex = internal_index;
	else
		levelIndex = self.levels.size;
	
	self.levels[ levelIndex ] = spawnStruct();
	self.levels[ levelIndex ].name = levelName;

	level_group = tablelookup( "sp/specopstable.csv", SOTABLE_COL_REF, levelName, SOTABLE_COL_GROUP );
	if ( level_group == "" )
		return;
	
	if( !isdefined( level.specOpsGroups[ level_group ].group_members ) )
		level.specOpsGroups[ level_group ].group_members = [];
	
	member_size = level.specOpsGroups[ level_group ].group_members.size;
	level.specOpsGroups[ level_group ].group_members[ member_size ] = levelName;
}

// SpecOps end of game summary calculations
so_eog_summary_calculate( was_success )
{	
	assertex( isdefined( was_success ), "so_eog_summary_calculate() requires a true or false value for the was_success parameter." );

	if ( !isdefined( self.so_eog_summary_data ) )
		self.so_eog_summary_data = [];	

	// time is capped to 24 hours
	if ( !isdefined( level.challenge_start_time ) )
	{
		// If the mission never started, force it to a time of 0.
		level.challenge_start_time = 0;
		level.challenge_end_time = 0;
	}
	
	assertex( isdefined( level.challenge_end_time ), "level.challenge_end_time is not defined" );
	
	session_time = min( level.challenge_end_time - level.challenge_start_time, 86400000 );
	session_time = round_millisec_on_sec( session_time, 1, false );
	
	foreach ( player in level.players )
	{
		player.so_eog_summary_data[ "time" ] 			= session_time;
		player.so_eog_summary_data[ "name" ] 			= player.playername;
		player.so_eog_summary_data[ "difficulty" ] 		= player get_player_gameskill(); //level.specops_reward_gameskill;
		
		if ( isdefined( player.forcedGameSkill ) )
			player.so_eog_summary_data[ "difficulty" ] 	= player.forcedGameSkill;	
	}
	
	level.session_score = 0;
	if ( is_survival() )
	{
		// SURVIVAL MODE
		assert( isdefined( level.so_survival_score_func ) );
		assert( isdefined( level.so_survival_wave_func ) );

		foreach ( player in level.players )
		{
			player.so_eog_summary_data[ "score" ] 	= [[ level.so_survival_score_func ]]();
			player.so_eog_summary_data[ "wave" ] 	= [[ level.so_survival_wave_func ]]();
			
			assert( isdefined( player.game_performance ) && isdefined( player.game_performance[ "kill" ] ) );
			player.so_eog_summary_data[ "kills" ]	= player.game_performance[ "kill" ];
		}
		
		level.session_score	= [[ level.so_survival_score_func ]]();
	}
	else
	{
		// MISSION MODE
		worst_time = 300000; //5 mins
		if ( isdefined( level.so_mission_worst_time ) )
			worst_time = level.so_mission_worst_time;
		
		session_time_score = 0;
		if ( session_time < worst_time )
			session_time_score = int ( ( ( worst_time - session_time ) / worst_time ) * 10000 );
		
		assertex( isdefined( level.specops_reward_gameskill ), "SpecOps difficult is not setup correctly. 'level.specops_reward_gameskill'" );
		level.session_score = int( level.specops_reward_gameskill * 10000 ) + session_time_score;
		
		foreach ( player in level.players )
		{
			assert( isdefined( player.stats ) && isdefined( player.stats[ "kills" ] ) );
			
			player.so_eog_summary_data[ "kills" ]	= player.stats[ "kills" ];
			player.so_eog_summary_data[ "score" ] 	= level.session_score;
		}
	}

	//setdvar( "ui_eog_success_heading_player1", "" );	// clear summary title
	//setdvar( "ui_eog_success_heading_player2", "" );
	
	// if scripter does not specify no-defaults, then we save space for them
	if ( !isdefined( level.custom_eog_no_defaults ) || !level.custom_eog_no_defaults )
	{	
		foreach ( player in level.players )
		{
			if ( is_coop() )
				player.eog_line = 4;
			else
				player.eog_line = 3;
		}
	}
		
	//----------------------------------------------
	// Callback
	//----------------------------------------------
	
	// callback that sets custom data and/or overrides for eog summary
	if( isdefined( level.eog_summary_callback ) )
		[[level.eog_summary_callback]]();
	
	// give XP based on final score
	if ( was_success && isdefined( level.xp_enable ) && level.xp_enable )
	{
		flag_set( "special_op_final_xp_given" );
		
		assert( isdefined( level.maxrank ) );
		foreach ( player in level.players )
		{		
			xp_earned = calculate_xp( player.so_eog_summary_data[ "score" ] );
			first_time_completion_xp = 0;
			
			if ( isdefined( level.never_played ) && level.never_played )
			{
				player thread givexp( "completion_xp" );
				first_time_completion_xp = maps\_rank::getScoreInfoValue( "completion_xp" );
			}
			else
			{
				best_score = undefined;
				best_score_var = tablelookup( "sp/specOpsTable.csv", 1, level.script, 9 );
				if ( IsDefined( best_score_var ) && best_score_var != "" )
					best_score = player GetLocalPlayerProfileData( best_score_var );
				
				// if never played and was sucessful then give completion XP
				if ( isdefined( best_score ) && best_score == 0 && !is_survival() )
				{
					player thread givexp( "completion_xp" );
					first_time_completion_xp = maps\_rank::getScoreInfoValue( "completion_xp" );
				}
			}
			
			if ( !is_survival() )
			{
				total_xp = first_time_completion_xp + xp_earned;
				
				// append a line to the end for XP!!
				assert( isdefined( player.summary ) && isdefined( player.summary[ "rankxp" ] ) );
				assert( isdefined( level.maxXP ) );
				
				// if no XP was given, do not display this message
				if ( player.summary[ "rankxp" ] < level.maxXP ) 
				{
					if ( first_time_completion_xp != 0 )
						player thread add_custom_eog_summary_line( "@SPECIAL_OPS_UI_XP_COMPLETION_FRIST_TIME", "^8+" + first_time_completion_xp, "@SPECIAL_OPS_UI_XP_COMPLETION", "^8+" + total_xp );	
					else
						player thread add_custom_eog_summary_line( "@SPECIAL_OPS_UI_XP_COMPLETION", "", "^8+" + total_xp );	
				}
				
				player thread giveXP( "final_score_xp", xp_earned );
			}
		}
	}
	
	// Don't use any defaults if specified.
	if ( !isdefined( level.custom_eog_no_defaults ) || !level.custom_eog_no_defaults )
		add_eog_default_stats();
}

calculate_xp( score )
{
	// self is player
	return int( score / 10 );	
}

// displays end of game summary menus and popups
so_eog_summary_display()
{
	if ( isdefined( level.eog_summary_delay ) && level.eog_summary_delay > 0 )
		wait level.eog_summary_delay;
		
	// TODO: Ditch _ambient entirely and use _audio!
	thread maps\_ambient::use_eq_settings( "specialop_fadeout", 1 );
	thread maps\_ambient::blend_to_eq_track( 1, 10 );	
	
	// reset popup dvars
	reset_eog_popup_dvars();
	
	// player 1
	// setup eog popups that shows stars earned, unlocks, and new best score
	if( isdefined( level.player.eog_firststar ) && level.player.eog_firststar )
		setdvar( "ui_first_star_player1", level.player.eog_firststar );		
	
	if( isdefined( level.player.eog_newstar ) && level.player.eog_newstar )
		setdvar( "ui_eog_player1_stars", level.player.eog_newstar_value );
		
	if( isdefined( level.player.eog_unlock ) && level.player.eog_unlock )
		setdvar( "ui_eog_player1_unlock", level.player.eog_unlock_value );		

	if( isdefined( level.player.eog_bestscore ) && level.player.eog_bestscore )
		setdvar( "ui_eog_player1_bestscore", level.player.eog_bestscore_value );	
	
	if ( is_coop() )
	{
		// player 1
		if( isdefined( level.player.eog_noreward ) && level.player.eog_noreward )
			setdvar( "ui_eog_player1_noreward", level.player.eog_noreward );	

		// player 2
		if( isdefined( level.player2.eog_firststar ) && level.player2.eog_firststar )
			setdvar( "ui_first_star_player2", level.player2.eog_firststar );

		if( isdefined( level.player2.eog_newstar ) && level.player2.eog_newstar )
			setdvar( "ui_eog_player2_stars", level.player2.eog_newstar_value );
			
		if( isdefined( level.player2.eog_unlock ) && level.player2.eog_unlock )
			setdvar( "ui_eog_player2_unlock", level.player2.eog_unlock_value );		

		if( isdefined( level.player2.eog_noreward ) && level.player2.eog_noreward )
			setdvar( "ui_eog_player2_noreward", level.player2.eog_noreward );	

		if( isdefined( level.player2.eog_bestscore ) && level.player2.eog_bestscore )
			setdvar( "ui_eog_player2_bestscore", level.player2.eog_bestscore_value );	

		wait 0.05;
		level.player openpopupmenu( "coop_eog_summary" );
		level.player2 openpopupmenu( "coop_eog_summary2" );
	}
	else
	{
		wait 0.05;
		level.player openpopupmenu( "sp_eog_summary" );
	}
}

reset_eog_popup_dvars()
{
	SetDvar( "ui_eog_player1_stars"	   , "" );
	SetDvar( "ui_eog_player1_unlock"   , "" );
	SetDvar( "ui_eog_player1_besttime" , "" );
	SetDvar( "ui_eog_player1_bestscore", "" );
	SetDvar( "ui_eog_player1_noreward" , "" );
	
	SetDvar( "ui_eog_player2_stars"	   , "" );
	SetDvar( "ui_eog_player2_unlock"   , "" );
	SetDvar( "ui_eog_player2_besttime" , "" );
	SetDvar( "ui_eog_player2_bestscore", "" );
	SetDvar( "ui_eog_player2_noreward" , "" );
}

// ========================= Setup default stats in end-of-game summary ===========================
add_eog_default_stats()
{
	foreach ( player in level.players )
	{
		// Coop heading "You" "Teammate"
		player so_eog_default_playerlabel();	
		
		// Kills
		player so_eog_default_kills();
		
		// Time
		player so_eog_default_time();

		// Difficulty
		player so_eog_default_difficulty();
		
		// Score
		if ( !level.missionfailed )
			player so_eog_default_score();
	}
}

so_eog_default_playerlabel()
{
	if ( is_coop() )
		self add_custom_eog_summary_line( "", "@SPECIAL_OPS_PERFORMANCE_YOU", "@SPECIAL_OPS_PERFORMANCE_PARTNER", undefined, 1 );
}

so_eog_default_kills()
{
	kills = self.so_eog_summary_data[ "kills" ];
	
	if ( is_coop() )
	{
		p2_kills = get_other_player( self ).so_eog_summary_data[ "kills" ];
		self add_custom_eog_summary_line( "@SPECIAL_OPS_UI_KILLS", kills, p2_kills, undefined, 2 );
	}
	else
	{
		self add_custom_eog_summary_line( "@SPECIAL_OPS_UI_KILLS", kills, undefined, undefined, 1 );
	}
}

so_eog_default_difficulty()
{
	diffString[ 0 ] = "@MENU_RECRUIT";
	diffString[ 1 ] = "@MENU_REGULAR";
	diffString[ 2 ] = "@MENU_HARDENED";
	diffString[ 3 ] = "@MENU_VETERAN";
	
	diff = self get_player_gameskill();
	//diff = diffString[ self.so_eog_summary_data[ "difficulty" ] ];
	self add_custom_eog_summary_line( "@SPECIAL_OPS_UI_DIFFICULTY", diff, undefined, undefined, 2 + int( is_coop() ) );
}

so_eog_default_time()
{
	seconds 		= self.so_eog_summary_data[ "time" ] * 0.001;
	time_string 	= convert_to_time_string( seconds, true );

	self add_custom_eog_summary_line( "@SPECIAL_OPS_UI_TIME", time_string, undefined, undefined, 3 + int( is_coop() ) );
}

so_eog_default_score()
{
	if ( is_coop() )
		score_label = "@SPECIAL_OPS_UI_TEAM_SCORE";
	else
		score_label = "@SPECIAL_OPS_UI_SCORE";
	
	final_score = self.so_eog_summary_data[ "score" ];
	self add_custom_eog_summary_line( score_label, final_score );
}