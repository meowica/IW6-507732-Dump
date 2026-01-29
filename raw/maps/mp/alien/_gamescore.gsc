reset_all_bonus()
{
	reset_team_bonus();
	reset_players_bonus();
}

reset_team_bonus()
{
	TEAM_CASUALTIES_BONUS = 1000;   //minus 100 for each casualty
	
	team_bonus = [];
	team_bonus[ "team_casualties" ] = TEAM_CASUALTIES_BONUS;
	team_bonus[ "team_kills" ] = 0;
	
	level.team_bonus = team_bonus;
}

reset_players_bonus()
{
	foreach( player in level.players )
	{
		player reset_personal_bonus();
	}
}

reset_personal_bonus()
{
	personal_bonus = [];
	personal_bonus[ "team_support_deploy" ] = 0;
	personal_bonus[ "teammate_revive" ] = 0;
	
	self.personal_bonus = personal_bonus;
}

get_team_bonus()
{
	return get_total_bonus( level.team_bonus );
}

get_personal_bonus()
{
	return get_total_bonus( self.personal_bonus );
}

get_total_bonus( bonus_array )
{
	total_bonus = 0;
	foreach ( bonus_type, bonus_value in bonus_array )
	{
		total_bonus += bonus_value;
	}
	return total_bonus;
}

update_team_bonus( bonus_type )
{
	CONST_TEAM_CASUALTY_PENALTY = 100;
	CONST_TEAM_KILLS_BONUS_INCREMENT = 10;
	
	switch( bonus_type )
	{
	case "team_casualties":
		level.team_bonus[ "team_casualties" ] = max( 0, level.team_bonus[ "team_casualties" ] - CONST_TEAM_CASUALTY_PENALTY );
		break;
	case "team_kills":
		level.team_bonus[ "team_kills" ] += CONST_TEAM_KILLS_BONUS_INCREMENT;
		break;
	default:
		AssertMsg( "Team bonus type: " + bonus_type + " is not supported.  Initialize new type in reset_team_bonus()." );
	}
}

update_personal_bonus( bonus_type )
{
	CONST_TEAM_SUPPORT_DEPLOY_BONUS = 100;
	CONST_TEAMMATE_REVIVE_BONUS = 200;
	
	switch( bonus_type )
	{
	case "team_support_deploy":
		self.personal_bonus[ "team_support_deploy" ] += CONST_TEAM_SUPPORT_DEPLOY_BONUS;
		break;
	case "teammate_revive":
		self.personal_bonus[ "teammate_revive" ] += CONST_TEAMMATE_REVIVE_BONUS;
		break;
	default:
		AssertMsg( "Personal bonus type: " + bonus_type + " is not supported.  Initialize new type in reset_personal_bonus()." );
	}
}

givePlayerScore( value )
{
	//<NOTE J.C.> player.score can only take up to the max value of 65000. 
	//Divide by 100 to prevent player.score from exceeding the max value.  
	//Might need other long term solution.
	self.score += int ( value / 100 );
	
	// track score via session data
	old_score = self maps\mp\alien\_persistence::get_player_score();
	new_score = old_score + value;
	
	// give total score
	self maps\mp\alien\_persistence::set_player_score( new_score );
}