#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_gamelogic;
#include maps\mp\bots\_bots_util;
#include maps\mp\bots\_bots_strategy;
#include maps\mp\bots\_bots_personality;

main()
{
	// This is called directly from native code on game startup after the _bots::main() is executed
	maps\mp\bots\_bots_gametype_sd::setup_callbacks();
	setup_callbacks();
	
/#
	thread bot_sr_debug();
#/
	
	maps\mp\bots\_bots_gametype_sd::bot_sd_start();
}

setup_callbacks()
{
	level.bot_funcs["gametype_think"] = ::bot_sr_think;
}

/#
bot_sr_debug()
{
	while(1)
	{
		if ( GetDvar("bot_DrawDebugGametype") == "sr" )
		{
			foreach( tag in level.dogtags )
			{
				if ( tag maps\mp\gametypes\_gameobjects::canInteractWith("allies") || tag maps\mp\gametypes\_gameobjects::canInteractWith("axis") )
				{
					if ( IsDefined(tag.bot_picking_up) )
					{
						if ( IsDefined(tag.bot_picking_up["allies"]) && IsAlive(tag.bot_picking_up["allies"]) )
							line( tag.curorigin, tag.bot_picking_up["allies"].origin + (0,0,20), (0,1,0), 1.0, true );
						if ( IsDefined(tag.bot_picking_up["axis"]) && IsAlive(tag.bot_picking_up["axis"]) )
							line( tag.curorigin, tag.bot_picking_up["axis"].origin + (0,0,20), (0,1,0), 1.0, true );
					}
					
					if ( IsDefined(tag.bot_camping) )
					{
						if ( IsDefined(tag.bot_camping["allies"]) && IsAlive(tag.bot_camping["allies"]) )
							line( tag.curorigin, tag.bot_camping["allies"].origin + (0,0,20), (0,1,0), 1.0, true );
						if ( IsDefined(tag.bot_camping["axis"]) && IsAlive(tag.bot_camping["axis"]) )
							line( tag.curorigin, tag.bot_camping["axis"].origin + (0,0,20), (0,1,0), 1.0, true );
					}
				}
			}
		}
		
		wait(0.05);
	}
}
#/

bot_sr_think()
{
	self notify( "bot_sr_think" );
	self endon(  "bot_sr_think" );

	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self.suspend_sd_role = undefined;
	self childthread tag_watcher();
	
	maps\mp\bots\_bots_gametype_sd::bot_sd_think();
}

tag_watcher()
{
	while(1)
	{
		wait(0.05);
		
		if ( self.health <= 0 )
			continue;
		
		visible_tags = maps\mp\bots\_bots_gametype_conf::bot_find_visible_tags( false );
		if ( visible_tags.size > 0 )
		{
			tag_chosen = Random(visible_tags);
			if ( self.team == game["attackers"] )
			{
				if ( IsDefined(self.role) && self.role != "atk_bomber" )
				{
					if ( self.team == tag_chosen.tag.victimteam )
					{
						// Attackers are hesitant to pick up ally kills, since they are probably going to be camped
						random_roll = RandomFloat(1.0);
						if ( random_roll < 0.10 )
						{
							self sr_pick_up_tag( tag_chosen.tag );
						}
						else
						{
							wait(1.0);
						}
					}
					else
					{
						// Attackers just pick up enemy kills, since they don't have the time to sit and camp them
						self sr_pick_up_tag( tag_chosen.tag );
					}
				}
			}
			else
			{
				if ( IsDefined(self.role) && self.role != "bomb_defuser" )
				{
					if ( self.team == tag_chosen.tag.victimteam )
					{
						// Defenders just pick up allied kills, since they know attackers probably won't camp them
						self sr_pick_up_tag( tag_chosen.tag );
					}
					else
					{
						if ( level.bombPlanted )
						{
							// If bomb is planted, defenders just try to pick up their allies
							self sr_pick_up_tag( tag_chosen.tag );
						}
						else
						{
							// If bomb is not planted, defenders will always camp enemy kills since they aren't under time pressure
							self sr_camp_tag( tag_chosen.tag );
						}
					}
				}
			}
		}
	}
}

sr_pick_up_tag( tag )
{
	if ( IsDefined(tag.bot_picking_up) && IsDefined(tag.bot_picking_up[self.team]) && IsAlive(tag.bot_picking_up[self.team]) && tag.bot_picking_up[self.team] != self )
		return;
	
	if ( self bot_is_defending() )
		self bot_defend_stop();
	
	tag.bot_picking_up[self.team] = self;
	self.suspend_sd_role = true;
	
	self childthread notify_when_tag_picked_up(tag, "tag_picked_up");
	self BotSetScriptGoal( tag.curorigin, 0, "tactical" );
	
	result = self bot_waittill_goal_or_fail( undefined, "tag_picked_up" );
	self BotClearScriptGoal();
	self.suspend_sd_role = undefined;
}

notify_when_tag_picked_up( tag, tag_notify )
{
	while( tag maps\mp\gametypes\_gameobjects::canInteractWith(self.team) )
	{
		wait(0.05);
	}
	
	self notify(tag_notify);
}

sr_camp_tag( tag )
{
	if ( IsDefined(tag.bot_camping) && IsDefined(tag.bot_camping[self.team]) && IsAlive(tag.bot_camping[self.team]) && tag.bot_camping[self.team] != self )
		return;
	
	if ( self bot_is_defending() )
		self bot_defend_stop();
	
	tag.bot_camping[self.team] = self;
	self.suspend_sd_role = true;
	
	self clear_camper_data();
	
	while( tag maps\mp\gametypes\_gameobjects::canInteractWith(self.team) )
	{
		if ( self should_select_new_ambush_point() )
		{
			if ( find_ambush_node( tag.curorigin ) )
			{
				self childthread maps\mp\bots\_bots_gametype_conf::bot_camp_tag(tag, "tactical");
			}
		}
		
		wait(0.05);
	}
	
	self BotClearScriptGoal();
	self.suspend_sd_role = undefined;
}