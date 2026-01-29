#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_gamelogic;
#include maps\mp\bots\_bots_util;
#include maps\mp\bots\_bots_strategy;
#include maps\mp\bots\_bots_personality;

main()
{
	// This is called directly from native code on game startup after the _bots::main() is executed
	setup_callbacks();
	setup_bot_infect();
}

setup_callbacks()
{
	level.bot_funcs["gametype_think"] = ::bot_infect_think;
	level.bot_funcs["should_pickup_weapons"] = ::bot_should_pickup_weapons_infect;
}

setup_bot_infect()
{
	level.bots_ignore_team_balance = true;
	level.bots_gametype_handles_team_choice = true;
	level.bots_gametype_handles_class_choice = true;
}

bot_should_pickup_weapons_infect()
{
	if ( level.infect_choseFirstInfected && self.team == "axis" )
		return false;	// An infected person was chosen and i'm on the infected team
	
	return maps\mp\bots\_bots::bot_should_pickup_weapons;
}

bot_infect_think()
{
	self notify( "bot_infect_think" );
	self endon(  "bot_infect_think" );

	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	while ( true )
	{
		if ( level.infect_choseFirstInfected )
		{
			if ( self.team == "axis" && self BotGetPersonality() != "run_and_gun" )
			{
				// Infected bots should be run and gun
				self bot_set_personality("run_and_gun");
			}
		}
		
		if ( self.bot_team != self.team )
			self.bot_team = self.team;	// Bot became infected so update self.bot_team (needed in infect.gsc)
		
		self [[ self.personality_update_function ]]();
		wait(0.05);
	}
}