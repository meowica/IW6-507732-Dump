#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_gamelogic;
#include maps\mp\bots\_bots_util;
#include maps\mp\bots\_bots_strategy;
#include maps\mp\bots\_bots_personality;
#include maps\mp\gametypes\_damage;

//=======================================================
//						main
//=======================================================
main()
{
	setup_callbacks();
}

setup_callbacks()
{
	level.agent_funcs["player"]["on_killed"] 	= ::on_agent_player_killed;
	level.agent_funcs["player"]["think"] 		= ::agent_bnty_think;
}

agent_bnty_think()
{
	self notify( "agent_bnty_think" );
	self endon(  "agent_bnty_think" );

	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
		
	self childthread ammoRefill();
		
	while( !IsDefined(self.zone) )
	{
		waitframe();
	}

	defendLocation = self.zone.origin;
	
	self bounty_VIP_think( defendLocation, 150 );
}

bounty_VIP_think( defendLocation, radius )
{
	self BotSetStance("none");
	self BotClearScriptGoal();
	self bot_disable_tactical_goals();
	
	self.cur_defend_node		= undefined;
	self.bot_defending 			= true;
	self.bot_defending_center 	= defendLocation;
	self.bot_defending_radius 	= radius;
	self.cur_defend_stance 		= "crouch";
	self.bot_defending_type 	= "protect";
	
	self givePerk( "_specialty_blastshield", false );
	self maps\mp\perks\_perkfunctions::setHeavyArmor( 2000 );
	
	self SetModel( "fullbody_juggernaut_c_mp" );
	self SetViewmodel( "viewhands_juggernaut_ally" );
	self SetClothType("cloth");
	
	self TakeAllWeapons();
	self _giveWeapon( "iw6_maul_mp" );
	
	while( true )
	{
		while( true )
		{
			self.cur_defend_node = self.zone.node;
			
			if( IsDefined(self.cur_defend_node) )
			{
				break;
			}
			else
			{
				waitframe();
			}
		}
	
		self BotSetScriptGoalNode( self.cur_defend_node, "tactical" );
		result = self waittill_any_return( "goal", "bad_path" );
		
		if( result == "goal" )
		{
			self childthread defense_watch_entrances_at_goal();
			break;
		}
		
		self.cur_defend_node = undefined;
	}
}


ammoRefill()
{
	while( true )
	{
		if( IsDefined(self.primaryWeapon) )
		{
			self giveMaxAmmo( self.primaryWeapon );
		}
		
		if( IsDefined(self.secondaryWeapon) )
		{
			self giveMaxAmmo( self.secondaryWeapon );
		}
		
		wait( 10 );
	}
}


on_agent_player_killed( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	self.zone.dropLocation = self.origin;
	
	// ragdoll
	self.body = self CloneAgent( deathAnimDuration );
	thread delayStartRagdoll( self.body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
		
	// award XP for killing agents
	if( isPlayer( eAttacker ) )
	{
		eAttacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", 100, sWeapon, sMeansOfDeath );	
		eAttacker thread maps\mp\killstreaks\_killstreaks::giveAdrenaline( "vehicleDestroyed" );		
	}

	self maps\mp\agents\_agents::removeKillCamEntity();
	self maps\mp\agents\_agent_utility::deactivateAgent();
}