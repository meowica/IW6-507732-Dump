#include common_scripts\utility;
//#include common_scripts\shared;
#include maps\mp\_utility;
#include maps\mp\gametypes\_gamelogic;
#include maps\mp\bots\_bots_ks;
#include maps\mp\bots\_bots_util;
#include maps\mp\bots\_bots_strategy;
#include maps\mp\bots\_bots_personality;
#include maps\mp\bots\_bots_fireteam;

//========================================================
//					main 
//========================================================
main()
{
	if( IsDefined( level.createFX_enabled ) && level.createFX_enabled )
		return;

	if ( level.script == "mp_character_room" )
		return;

	// This is called directly from native code on game startup
	// The particular gametype's main() is called from native code afterward
	
	level.bot_difficulty_defaults = [];
	level.bot_difficulty_defaults[level.bot_difficulty_defaults.size] = "recruit";
	level.bot_difficulty_defaults[level.bot_difficulty_defaults.size] = "regular";
	level.bot_difficulty_defaults[level.bot_difficulty_defaults.size] = "hardened";
	
	setup_callbacks();
	setup_personalities();

	// Enable badplaces in destructibles
	level.badplace_cylinder_func = ::badplace_cylinder;
	level.badplace_delete_func = ::badplace_delete;
	
	// Init bot killstreak script
	maps\mp\bots\_bots_ks::bot_killstreak_setup();

	// Init bot loadout data
	// Needs to be after _bots_ks::bot_killstreak_setup
	maps\mp\bots\_bots_loadout::init();
	
	// Needs to be after _bots_loadout::init()
	level thread init();
}


//========================================================
//					setup_callbacks 
//========================================================
setup_callbacks()
{
	// Setup level.bot_funcs callback function table
	level.bot_funcs = [];
	
	// Bot System functions
	level.bot_funcs["bots_spawn"]						= ::spawn_bots;
	level.bot_funcs["bots_add_scavenger_bag"]			= ::bot_add_scavenger_bag;
	level.bot_funcs["bots_add_to_level_targets"]		= ::bot_add_to_bot_level_targets;
	level.bot_funcs["bots_remove_from_level_targets"] 	= ::bot_remove_from_bot_level_targets;
	level.bot_funcs["bots_make_entity_sentient"]		= ::bot_make_entity_sentient;

	// Bot entity functions
	level.bot_funcs["think"]							= ::bot_think;
	level.bot_funcs["on_killed"]						= ::on_bot_killed;
	level.bot_funcs["should_do_killcam"]				= ::bot_should_do_killcam;
	level.bot_funcs["get_attacker_ent"]					= ::bot_get_known_attacker;
	level.bot_funcs["should_pickup_weapons"]			= ::bot_should_pickup_weapons;
	level.bot_funcs["on_damaged"]						= ::bot_damage_callback;
	level.bot_funcs["can_use_crate"]					= ::can_use_crate_always;
	level.bot_funcs["gametype_think"]					= ::default_gametype_think;
	level.bot_funcs["leader_dialog"]					= ::bot_leader_dialog;
	level.bot_funcs["player_spawned"]					= ::bot_player_spawned;
	level.bot_funcs["should_start_cautious_approach"]	= ::should_start_cautious_approach_default;
	level.bot_funcs["know_enemies_on_start"]			= ::bot_know_enemies_on_start;
	level.bot_funcs["bot_get_rank_xp"]					= ::bot_get_rank_xp;
	level.bot_funcs["ai_3d_sighting_model"]				= ::bot_3d_sighting_model;
	
	level.bot_random_path_function = [];
	level.bot_random_path_function["allies"]			= ::bot_random_path_default;
	level.bot_random_path_function["axis"]				= ::bot_random_path_default;
	
	level.bot_can_use_box_by_type["deployable_vest"]	= ::bot_should_use_ballistic_vest_crate;
	level.bot_can_use_box_by_type["deployable_ammo"]	= ::bot_should_use_ammo_crate;
	level.bot_can_use_box_by_type["scavenger_bag"]		= ::bot_should_use_scavenger_bag;
	level.bot_can_use_box_by_type["deployable_grenades"]= ::bot_should_use_grenade_crate;
	level.bot_can_use_box_by_type["deployable_juicebox"]= ::bot_should_use_juicebox_crate;
	
	// War (TDM) gametype serves as the default, so we use it to setup default gametype callbacks
	maps\mp\bots\_bots_gametype_war::setup_callbacks();
	
	// Should be after everything else, so fireteam mode can override specific callbacks if necessary
	if ( bot_is_fireteam_mode() )
	{
		bot_fireteam_setup_callbacks();
	}
}


//========================================================
//					init 
//========================================================
init()
{
	thread monitor_smoke_grenades();
	
	initLevelVariables();
	
	/#
    level thread bot_debug_drawing();
    #/
	
	if( !shouldSpawnBots() )
		return;

	refresh_existing_bots();
	
	botAutoConnectValue = BotAutoConnectEnabled();
	if ( botAutoConnectValue > 0 )
	{
		setMatchData( "hasBots", true );

		if ( bot_is_fireteam_mode() )
		{
			// Fireteam mode : spawn bots on each team with specific loadouts
			level thread bot_fireteam_init();
			// Init Fireteam commander logic - this needs to be called after Callback_StartGameType's init() functions.
			level thread maps\mp\bots\_bots_fireteam_commander::init();
		}
		else// if ( botAutoConnectValue == 1 )
		{
			// "fill_open" : drop and spawn bots as needed
	    	level thread bot_connect_monitor();
		}
	} 
}


//========================================================
//					initVariables 
//========================================================
initLevelVariables()
{
	if ( !IsDefined(level.crateOwnerUseTime) )
	{
		level.crateOwnerUseTime = 500;
	}
	
	if ( !IsDefined(level.crateNonOwnerUseTime) )
	{
		level.crateNonOwnerUseTime	= 3000;
	}
	
	// Time it takes (after losing track of an enemy) for a bot to consider himself "out of combat"
	level.bot_out_of_combat_time = 3000;
	
	// Weapon that bots will use to shoot down helicopters
	level.bot_lockon_weapon = "javelin";

	level.squadSlots = [];
}


//========================================================
//					shouldSpawnBots 
//========================================================
shouldSpawnBots()
{
	return true;
}


refresh_existing_bots()
{
	wait 1; // give level.players a chance to initialize between rounds

	// If we switched sides, the bots will still exist in game but will have lost their think threads.  So we need to restart them
	foreach ( player in level.players )
	{
		if ( IsBot( player ) )
		{
 			player.equipment_enabled = true;
 			player.bot_team = player.team;
 			player.bot_spawned_before = true;
 			player thread [[ level.bot_funcs["think"] ]]();	
		}
	}
}

/#
bot_debug_drawing()
{
	level endon( "game_ended" );
	
	while( !bot_bots_enabled_or_added() )
		wait(1.0);
	
	level.defense_debug_structs = [];
	for( i=0; i<10; i++ )
	{
		level.defense_debug_structs[level.defense_debug_structs.size] = SpawnStruct();
	}
	level.cur_num_defense_debug_structs = 0;
	
	for(;;)
	{
		draw_debug_type = GetDvar("bot_DrawDebugSpecial");
		
		clear_defense_draw();
		if ( draw_debug_type == "defend" )
		{
			bot_debug_draw_defense();
		}
		else if ( draw_debug_type == "entrances" )
		{
			bot_debug_draw_watch_nodes();
		}
		else if ( draw_debug_type == "defend_with_entrances" )
		{
			bot_debug_draw_defense();
			bot_debug_draw_watch_nodes();
		}
		else if ( draw_debug_type == "key_entry_points" )
		{
			bot_debug_draw_cached_entrances();
		}
		else if ( draw_debug_type == "key_cached_paths" )
		{
			bot_debug_draw_cached_paths();
		}
		
		wait(0.05);
	}
}

clear_defense_draw()
{
	for( i=0; i<level.cur_num_defense_debug_structs; i++ )
	{
		struct = level.defense_debug_structs[i];
		if ( IsDefined(struct.defense_trigger) && struct.defense_trigger.classname != "trigger_radius" )
			BotDebugDrawTrigger( false, level.defense_debug_structs[i].defense_trigger );
	}
	
	level.cur_num_defense_debug_structs = 0;
}

bot_debug_draw_defense()
{
	assert(level.cur_num_defense_debug_structs == 0);
	foreach( player in level.participants )
	{
		if ( player.health > 0 && IsAI( player ) && player bot_is_defending() )
		{
			struct_for_defense = undefined;
			for( i=0; i<level.cur_num_defense_debug_structs; i++ )
			{
				struct = level.defense_debug_structs[i];
				same_defense_type = struct.defense_type == player.bot_defending_type;
				same_defense_radius = IsDefined(struct.defense_radius) && IsDefined(player.bot_defending_radius) && (struct.defense_radius == player.bot_defending_radius);
				same_defense_trigger = IsDefined(struct.defense_trigger) && IsDefined(player.bot_defending_trigger) && (struct.defense_trigger == player.bot_defending_trigger);
				if ( same_defense_type && (same_defense_radius || same_defense_trigger) )
				{
					if ( bot_vectors_are_equal( struct.defense_center, player.bot_defending_center ) )
					{
						struct_for_defense = struct;
						break;
					}
				}
			}
			
			if ( IsDefined(struct_for_defense) )
			{
				if ( struct_for_defense.defense_team != player.team )
				{
					struct_for_defense.cylinder_color = (1,0,1);
				}
				
				struct_for_defense.bots = array_add( struct_for_defense.bots, player );
			}
			else
			{
				new_defense_struct = level.defense_debug_structs[level.cur_num_defense_debug_structs];
				level.cur_num_defense_debug_structs++;
				
				// Create a struct for this defense type
				if ( player.team == "allies" )
				{
					new_defense_struct.cylinder_color = (0,0,1); // allies are blue
				}
				else if ( player.team == "axis" )
				{
					new_defense_struct.cylinder_color = (1,0,0); // axis are red
				}
				
				new_defense_struct.defense_team = player.team;
				new_defense_struct.defense_type = player.bot_defending_type;
				new_defense_struct.defense_radius = player.bot_defending_radius;
				new_defense_struct.defense_trigger = player.bot_defending_trigger;
				new_defense_struct.defense_center = player.bot_defending_center;
				new_defense_struct.defense_nodes = player.bot_defending_nodes;
				new_defense_struct.bots = [];
				new_defense_struct.bots = array_add( new_defense_struct.bots, player );
			}
		}
	}
	
	for( i=0; i<level.cur_num_defense_debug_structs; i++ )
	{
		struct = level.defense_debug_structs[i];
		
		if ( IsDefined(struct.defense_nodes) )
		{
			// Draw nodes
			foreach( node in struct.defense_nodes )
				bot_draw_cylinder(node.origin, 10, 10, 0.05, undefined, struct.cylinder_color, true, 4);
		}
		
		if ( IsDefined(struct.defense_trigger) )
		{
			// Draw trigger
			if ( struct.defense_trigger.classname != "trigger_radius" )
				BotDebugDrawTrigger(true, level.defense_debug_structs[i].defense_trigger, struct.cylinder_color, true);
			else
				bot_draw_cylinder(struct.defense_center, struct.defense_trigger.radius, struct.defense_trigger.height, 0.05, undefined, struct.cylinder_color, true);
		}
		
		if ( IsDefined(struct.defense_radius) )
		{
			// Draw cylinder
			bot_draw_cylinder(struct.defense_center, struct.defense_radius, 75, 0.05, undefined, struct.cylinder_color, true);
		}
		
		foreach( bot in struct.bots )
		{
			lineStart = struct.defense_center + (0,0,25);
			lineEnd = bot.origin + (0,0,25);
			
			line_color = undefined;
			if ( bot.team == "allies" )
				line_color = (0,0,1);
			else if ( bot.team == "axis" )
				line_color = (1,0,0);
			
			line( lineStart, lineEnd, line_color, 1, true );
			
			if ( IsDefined(bot.bot_defending_override_origin_node) )
			{
				node_line_color = (max(line_color[0],0.3),max(line_color[1],0.3),max(line_color[2],0.3));
				bot_draw_cylinder(bot.bot_defending_override_origin_node.origin, 10, 10, 0.05, undefined, node_line_color, true, 4);
				line( bot.bot_defending_override_origin_node.origin, lineEnd, node_line_color, 1, true );
			}
		}
	}	
}

bot_debug_draw_watch_nodes()
{
	foreach( player in level.participants )
	{
		if ( player.health > 0 && IsAI( player ) && IsDefined(player.watch_nodes)  )
		{
			node_offset = (0,0,player GetPlayerViewHeight());
			foreach( node in player.watch_nodes )
			{
				// green means "high priority watch"
				// white means "low priority watch"
				// color lerps between the two
				entrance_color = (1 - node.watch_node_chance[player.entity_number], 1, 1 - node.watch_node_chance[player.entity_number]);
				
				line( player.origin + node_offset, node.origin + (0,0,30), entrance_color, 1, true );
				bot_draw_cylinder(node.origin + (0,0,30), 10, 10, 0.05, undefined, entrance_color, true, 4);
			}
		}
	}
}

bot_debug_draw_cached_entrances()
{
	if ( !IsDefined( level.entrance_indices ) || !IsDefined(level.entrance_points) )
		return;
	
	node_offset = (0,0,11);
	standing_offset = (0,0,55);
	crouching_offset = (0,0,40);
	prone_offset = (0,0,15);
	color_visible = (0,1,0);
	color_not_visible = (1,0,0);
	node_height = 13;
	for ( i = 0; i < level.entrance_indices.size; i++ )
	{
		entrance_collection = level.entrance_points[level.entrance_indices[i]];
		for ( j = 0; j < entrance_collection.size; j++ )
		{
			bot_draw_cylinder(entrance_collection[j].origin + node_offset, 10, node_height, 0.05, undefined, (0,1,0), true, 4);
			
			// standing
			line( level.entrance_origin_points[i] + standing_offset, entrance_collection[j].origin + node_offset + (0,0,node_height/2), color_visible, 1, true );
			
			// crouching
			color_to_use = color_not_visible;
			if ( entrance_collection[j].crouch_visible_from[level.entrance_indices[i]] )
				color_to_use = color_visible;
			line( level.entrance_origin_points[i] + crouching_offset, entrance_collection[j].origin + node_offset + (0,0,node_height/2), color_to_use, 1, true );
			
			// prone
			color_to_use = color_not_visible;
			if ( entrance_collection[j].prone_visible_from[level.entrance_indices[i]] )
				color_to_use = color_visible;
			line( level.entrance_origin_points[i] + prone_offset, entrance_collection[j].origin + node_offset + (0,0,node_height/2), color_to_use, 1, true );
		}
		
		// Note: this white cylinder is the botTarget, if it exists
		bot_draw_cylinder(level.entrance_origin_points[i], 10, 75, 0.05, undefined, (1,1,1), true, 8);
	}
}

bot_debug_draw_cached_paths()
{
	if ( !IsDefined( level.entrance_indices ) )
		return;
	
	node_colors = [ (1,0,0), (0,1,0), (0,0,1), (1,0,1), (1,1,0), (0,1,1), (1,0.6,0.6), (0.6,1,0.6), (0.6,0.6,1), (0.1,0.1,0.1) ];

	if ( !IsDefined(level.next_path_time) )
	{
		level.bot_debug_cur_first_index = level.entrance_indices.size - 2;
		level.bot_debug_cur_second_index = level.entrance_indices.size - 1;
		level.next_path_time = GetTime() - 1;
	}

	if ( GetTime() > level.next_path_time )
	{
		keep_trying = true;
		while(keep_trying)
		{
			if ( level.bot_debug_cur_second_index == level.entrance_indices.size - 1 )
			{
				if ( level.bot_debug_cur_first_index == level.entrance_indices.size - 2 )
				{
					level.bot_debug_cur_first_index = 0;
					level.bot_debug_cur_node_color = -1;
				}
				else
				{
					level.bot_debug_cur_first_index++;
				}
				level.bot_debug_cur_second_index = level.bot_debug_cur_first_index + 1;
			}
			else
			{
				level.bot_debug_cur_second_index++;
			}
			
			keep_trying = !IsDefined(level.precalculated_paths[level.entrance_indices[level.bot_debug_cur_first_index]][level.entrance_indices[level.bot_debug_cur_second_index]]);
		}
		
		level.bot_debug_cur_node_color = (level.bot_debug_cur_node_color + 1) % node_colors.size;
		level.next_path_time = GetTime() + (15 * 1000);
	}
	
	// Note: these white cylinders are the botTargets, if they exist
	bot_draw_cylinder(level.entrance_origin_points[level.bot_debug_cur_first_index], 10, 75, 0.05, undefined, (1,1,1), true, 8);
	bot_draw_cylinder(level.entrance_origin_points[level.bot_debug_cur_second_index], 10, 75, 0.05, undefined, (1,1,1), true, 8);
	foreach( node in level.precalculated_paths[level.entrance_indices[level.bot_debug_cur_first_index]][level.entrance_indices[level.bot_debug_cur_second_index]] )
	{
		bot_draw_cylinder(node.origin, 10, 13, 0.05, undefined, node_colors[level.bot_debug_cur_node_color], true, 4);
	}
}
#/

//========================================================
//				bot_player_spawned 
//========================================================
bot_player_spawned()
{
	self bot_set_loadout_class();
}

bot_set_loadout_class()
{
	if ( !IsDefined( self.bot_class ) ) 
	{
		if ( !bot_gametype_chooses_class() )
		{
			while( !IsDefined(level.bot_loadouts_initialized) )
				wait(0.05);
			
			/#
			debugClass = GetDvar( "bot_debugClass", "" );
			if ( IsDefined( debugClass ) && debugClass != "" )
			{
				self.bot_class = debugClass;
				return;
			}
			#/
			
			if ( IsDefined( self.override_class_function ) )
			{
		 		self.bot_class = [[ self.override_class_function ]]();
			}
		 	else
		 	{
		 		self.bot_class = bot_setup_callback_class();
			}
		}
		else
		{
			self.bot_class = self.class;
		}
    }
}

watch_players_connecting()
{
	while(1)
	{
		level waittill("connected", player);
		if ( !IsAI( player ) && (level.players.size > 0) )	// If playing a local listen server, ignore this for the first player to join
		{
			level.players_waiting_to_join = array_add(level.players_waiting_to_join, player);
			childthread bots_notify_on_spawn(player);
			childthread bots_notify_on_disconnect(player);
			childthread bots_remove_from_array_on_notify(player);
		}
	}
}

bots_notify_on_spawn(player)
{
	player endon("bots_human_disconnected");
	while( !array_contains(level.players,player) )
	{
		wait(0.05);
	}
	player notify("bots_human_spawned");
}

bots_notify_on_disconnect(player)
{
	player endon("bots_human_spawned");
	player waittill("disconnect");
	player notify("bots_human_disconnected");
}

bots_remove_from_array_on_notify(player)
{
	player waittill_any("bots_human_spawned","bots_human_disconnected");
	level.players_waiting_to_join = array_remove(level.players_waiting_to_join,player);
}

monitor_pause_spawning()
{
	// The purpose of this function (and all the childthreads) is to pause bot spawning while a human player is in the process of joining the game
	// So when a human connects, we add him to the "waiting" array, and he stays in there until he spawns in the game or disconnects
	// As long as there are any humans in the queue, we don't want bots to be spawning and taking up the human players' spots
	
	level.players_waiting_to_join = [];
	childthread watch_players_connecting();
	
	while(1)
	{
		if ( level.players_waiting_to_join.size > 0 )
			level.pausing_bot_connect_monitor = true;
		else
			level.pausing_bot_connect_monitor = false;
		
		wait(0.5);
	}
}

//========================================================
//				bot_connect_monitor 
//========================================================
bot_connect_monitor( num_ally_bots, num_enemy_bots )
{
	self notify( "bot_connect_monitor" );
	self endon( "bot_connect_monitor" );

	level.pausing_bot_connect_monitor = false;
	childthread monitor_pause_spawning();
	
	wait(0.5);
	bot_connect_monitor_update_time = 1.5;
	
	for(;;)
	{
		if ( level.pausing_bot_connect_monitor )
		{
			wait(bot_connect_monitor_update_time);
			continue;
		}
		
		// NOTE: if level.bots_ignore_team_balance is defined, these variables don't control the number of bots per team,
		// but combined they do control the absolute number of bots.  For example if level.bots_ignore_team_balance is defined, and 
		// max_ally_bots_absolute is 2 and max_enemy_bots_absolute is 8, the total number of bots you can have in the match is 10, but the
		// ally team could have all 10 of them.
		max_ally_bots_absolute = 9;		// No matter what, cannot have more this number ally bots
		max_enemy_bots_absolute = 9;	// No matter what, cannot have more this number enemy bots

		/#
		// if test clients have been added via the scr_testclients dvar, dont ever kick/spawn bots for team balance again
		if ( GetDvarInt("bot_DisableAutoConnect") )
			return;

		max_ally_bots_absolute = GetDvarInt("bot_MaxNumAllyBots");
		max_enemy_bots_absolute = GetDvarInt("bot_MaxNumEnemyBots");
		#/
		
		team_ally = "allies";	// team_ally is the team that the human player is on
		team_enemy = "axis";	// team_enemy is the enemy team (opposed to the team the human player is on)
		clientCounts = bot_client_counts();
		
		if ( cat_array_get( clientCounts, "humans" ) > 1 )
		{
			cur_num_allies_players = cat_array_get( clientCounts, "humans_" + "allies");
			cur_num_axis_players = cat_array_get( clientCounts, "humans_" + "axis");
			if ( cur_num_axis_players > cur_num_allies_players )
			{
				// If there are more axis players, consider that to be team_ally (team that human players are on)
				team_ally = "axis";
				team_enemy = "allies";
			}
		}
		else
		{
			humanPlayer = get_human_player();
			if ( IsDefined( humanPlayer ) )
			{
				humanPlayer_team = humanPlayer bot_get_player_team();
				if ( IsDefined(humanPlayer_team) && humanPlayer_team != "spectator" )
				{
					team_ally = humanPlayer_team;
					team_enemy = getOtherTeam( humanPlayer_team );
				}
			}
		}
		
		// Count the max size of each team (in terms of client limits)
		ally_team_size = bot_get_team_limit();
		enemy_team_size = bot_get_team_limit();
		if ( ally_team_size + enemy_team_size < bot_get_client_limit() )
		{
			// The client limit is odd, so add 1 to a team so we are still at the client limit
			if ( ally_team_size < max_ally_bots_absolute )
				ally_team_size++;
			else if ( enemy_team_size < max_enemy_bots_absolute )
				enemy_team_size++;
		}
		
		// Count current number of humans
		cur_num_ally_humans = cat_array_get( clientCounts, "humans_" + team_ally);
		cur_num_enemy_humans = cat_array_get( clientCounts, "humans_" + team_enemy);
		
		// Count current number of spectators and try predict which team they will join
		cur_num_spectators = cat_array_get( clientCounts, "spectator" );
		cur_num_ally_spectators = 0;
		cur_num_enemy_spectators = 0;
		while( cur_num_spectators > 0 )
		{
			ally_team_has_room_for_another_spectator = (cur_num_ally_humans + cur_num_ally_spectators + 1 <= ally_team_size);
			enemy_team_has_room_for_another_spectator = (cur_num_enemy_humans + cur_num_enemy_spectators + 1 <= enemy_team_size);
			
			if ( ally_team_has_room_for_another_spectator && !enemy_team_has_room_for_another_spectator )
			{
				cur_num_ally_spectators++;
			}
			else if ( !ally_team_has_room_for_another_spectator && enemy_team_has_room_for_another_spectator )
			{
				cur_num_enemy_spectators++;
			}
			else if ( ally_team_has_room_for_another_spectator && enemy_team_has_room_for_another_spectator )
			{
				if ( (cur_num_spectators % 2) == 1 )
					cur_num_ally_spectators++;
				else
					cur_num_enemy_spectators++;
			}
			
			cur_num_spectators--;
		}
		
		// Count current number of bots
		cur_num_ally_bots = cat_array_get( clientCounts, "bots_" + team_ally);
		cur_num_enemy_bots = cat_array_get( clientCounts, "bots_" + team_enemy);

		// Open bot slots per team is either the number of available spots (team size - number of humans) or the hard limit, whichever is lower
		ally_bot_slots = INT(min(ally_team_size - cur_num_ally_humans - cur_num_ally_spectators,max_ally_bots_absolute));
		enemy_bot_slots = INT(min(enemy_team_size - cur_num_enemy_humans - cur_num_enemy_spectators,max_enemy_bots_absolute));
		
		// Number of bots wanted right now is the number of available slots (from above) minus the number of bots currently in the game
		ally_bots_wanted = ally_bot_slots - cur_num_ally_bots;
		enemy_bots_wanted = enemy_bot_slots - cur_num_enemy_bots;
		
		need_to_spawn_or_drop = true;
		if ( IsDefined(level.bots_ignore_team_balance) )
		{
			// Don't move bots between teams, but maybe spawn or drop them if necessary
			total_team_size = ally_team_size + enemy_team_size;
			max_total_bots_absolute = max_ally_bots_absolute + max_enemy_bots_absolute;
			cur_num_total_humans = cur_num_ally_humans + cur_num_enemy_humans;
			cur_num_total_bots = cur_num_ally_bots + cur_num_enemy_bots;
			total_bot_slots_open = INT(min(total_team_size - cur_num_total_humans,max_total_bots_absolute));
			
			total_num_bots_wanted = total_bot_slots_open - cur_num_total_bots;
			if ( total_num_bots_wanted == 0 )
			{
				// No changes needed
				need_to_spawn_or_drop = false;
			}
			else if ( total_num_bots_wanted > 0 )
			{
				// Need to add bots.  Just even them out between teams (doesn't really matter though)
				ally_bots_wanted = INT(total_num_bots_wanted/2) + (total_num_bots_wanted % 2 );
				enemy_bots_wanted = INT(total_num_bots_wanted/2);
			}
			else if ( total_num_bots_wanted < 0 )
			{
				// Need to remove bots.  First try to remove them from the ally team, then if that doesn't do it, the enemy team as well
				num_of_bots_to_drop = total_num_bots_wanted * -1;
							
				ally_bots_wanted = -1 * INT(min(num_of_bots_to_drop,cur_num_ally_bots));
				enemy_bots_wanted = -1 * (num_of_bots_to_drop + ally_bots_wanted);
			}
		}
		else if ( ally_bots_wanted * enemy_bots_wanted < 0 && gameFlag("prematch_done") && !IsDefined(level.bots_disable_team_switching) )
		{
			// ally_bots_wanted and enemy_bots_wanted are both nonzero and have opposite signs.
			// This means one team needs to gain players and one needs to lose them.  So move bots from one team to the other.
			difference = INT(min(abs(ally_bots_wanted),abs(enemy_bots_wanted)));
			
			if ( ally_bots_wanted > 0 )
				move_bots_from_team_to_team( difference, team_enemy, team_ally );
			else if ( enemy_bots_wanted > 0 )
				move_bots_from_team_to_team( difference, team_ally, team_enemy );
			
			need_to_spawn_or_drop = false;
		}
		
		if ( need_to_spawn_or_drop )
		{
			// Spawn or drop bots for teams that are under / over the limit
			if ( enemy_bots_wanted < 0 )
			{
				drop_bots( enemy_bots_wanted * -1, team_enemy );
			}
			if ( ally_bots_wanted < 0 )
			{
				drop_bots( ally_bots_wanted * -1, team_ally );
			}
			
			if ( enemy_bots_wanted > 0 )
			{
				spawn_bots( enemy_bots_wanted, team_enemy );
			}
			if ( ally_bots_wanted > 0 )
			{
				spawn_bots( ally_bots_wanted, team_ally );
			}
		}
	
		wait(bot_connect_monitor_update_time);
	}
}

bot_get_player_team()
{
	if ( IsDefined(self.team) )
		return self.team;
	
	if ( IsDefined(self.pers["team"]) )
		return self.pers["team"];
	
	return undefined;
}

bot_client_counts()
{
	clientCounts = [];
	
	foreach ( player in level.players )
	{
		if ( IsDefined(player) && IsDefined(player.team) )
		{
			clientCounts = cat_array_add( clientCounts, "all" );
			clientCounts = cat_array_add( clientCounts, player.team );
			if ( IsBot( player ) )
			{
				clientCounts = cat_array_add( clientCounts, "bots" );
				clientCounts = cat_array_add( clientCounts, "bots_" + player.team );
			}
			else
			{
				clientCounts = cat_array_add( clientCounts, "humans" );
				clientCounts = cat_array_add( clientCounts, "humans_" + player.team );
			}
		}
	}
	
	return clientCounts;
}

cat_array_add( arrayCounts, category )
{
	if ( !IsDefined( arrayCounts ) )
	{
		arrayCounts = [];
	}
	
	if ( !IsDefined( arrayCounts[ category ] ) )
	{
		arrayCounts[ category ] = 0;
	}

	arrayCounts[ category ] = arrayCounts[ category ] + 1;
	
	return arrayCounts;
}

cat_array_get( arrayCounts, category )
{
	if ( !IsDefined( arrayCounts ) )
	{
		return 0;
	}
	
	if ( !IsDefined( arrayCounts[ category ] ) )
	{
		return 0;
	}

	return arrayCounts[ category ];
}

//========================================================
//				move_bots_from_team_to_team 
//========================================================
move_bots_from_team_to_team( count, teamFrom, teamTo )
{
	foreach ( player in level.players )
	{
		if ( IsDefined( player.connected ) && player.connected && IsBot( player ) && player.team == teamFrom )
		{
			player.bot_team = teamTo;
			player notify( "luinotifyserver", "team_select", bot_lui_convert_team_to_int(teamTo) );
			wait(0.05);	// Wait for the team change
			player notify( "luinotifyserver", "class_select", player.bot_class );
			
			count--;
			
			if ( count <= 0 )
				break;
			else
				wait(0.1);
		}
	}
}

//========================================================
//				drop_bots 
//========================================================
drop_bots( count, team )
{
	while ( count > 0 )
	{
		foreach ( player in level.players )
		{
			if ( IsDefined( player.connected ) && player.connected && IsBot( player ) && (!IsDefined( team ) || player.team == team) )
			{
				kick( player.entity_number, "EXE_PLAYERKICKED_BOT_BALANCE" );
				wait 0.1;
				break;
			}
		}
		
		count--;
	}	
}


bot_lui_convert_team_to_int( team_name )
{
	if ( team_name == "axis" )
		return 0;
	else if ( team_name == "allies" )
		return 1;
	else if ( team_name == "autoassign" || team_name == "random" )
		return 2;
	else // if ( team_name == "spectator" )
		return 3;
}


//========================================================
//					spawn_bots 
//========================================================
spawn_bots( num_bots, team, botCallback, haltWhenFull )
{
	function_start_time = GetTime();
	bots_spawned = 0;

	while( bots_spawned < num_bots && GetTime() < function_start_time + 10000 ) // don't want to be stuck in this function forever
 	{
 		wait( 0.25 );
 		bot = AddTestClient( 0, bot_lui_convert_team_to_int( team ), bots_spawned );

 		if ( !IsDefined( bot ) )
 		{
 			if ( IsDefined( haltWhenFull ) && haltWhenFull )
 				return;
 			
	 		wait( 1 );	
 			continue;
 		}

		// store away the squad slot with the client id, this is used to give the correct squad member the correct loadout.
		level.squadSlots[ bot GetEntityNumber() ] = bots_spawned;
		if ( team == "allies" )	// add one to allies as the player takes the first squad slot
			level.squadSlots[ bot GetEntityNumber() ]++;

		println( "Added Name: " + bot.name + " Ent: " + bot GetEntityNumber() + " squadSlots: " + level.squadSlots[ bot GetEntityNumber() ] );
 		
 		bots_spawned++;
 		
        bot.pers["isBot"] = true;
 		bot.equipment_enabled = true;
 		bot.bot_team = team;
 		
 		if( IsDefined(botCallback) )
 		{
 			bot [[botCallback]]();
 		}
 		
 		bot thread [[ level.bot_funcs["think"] ]]();
  	}
}

bot_gametype_chooses_team()
{
	return ( IsDefined(level.bots_gametype_handles_team_choice) && level.bots_gametype_handles_team_choice );
}

bot_gametype_chooses_class()
{
	return ( IsDefined(level.bots_gametype_handles_class_choice) && level.bots_gametype_handles_class_choice );
}

//========================================================
//					bot_think 
//========================================================
bot_think( )
{
	self notify( "bot_think" );
	self endon( "bot_think" );
	self endon( "disconnect" );
	
	while( !IsDefined( self.pers["team"] ) )
	{
		wait( 0.05 );
	}
	
	level.hasbots = true;
	
	if ( bot_gametype_chooses_team() )
		self.bot_team = self.pers["team"];
	
	team = self.bot_team;
	if ( !IsDefined( team ) )
		team = self.pers["team"];

	maps\mp\bots\_bots_ks::bot_killstreak_setup();
		
	self.entity_number = self GetEntityNumber();
		
	firstSpawn = false;
	
	if ( !isDefined( self.bot_spawned_before ) )
	{
		firstSpawn = true;
		self.bot_spawned_before = true;
		
		if ( !bot_gametype_chooses_team() )
		{
			self notify( "luinotifyserver", "team_select", bot_lui_convert_team_to_int(team) );
			wait( 0.5 );
		}
	}

	while( true )
	{
		// Choose difficulty if need be
		if ( ( self BotGetDifficulty() ) == "default" )
			self BotSetDifficulty( self bot_choose_difficulty( level.bot_difficulty_defaults ) );
		
		// Balance personalities unless we are restricting them based on difficulty
		allowAdvPersonality = self BotGetDifficultySetting( "advancedPersonality" );
		if ( firstSpawn && IsDefined( allowAdvPersonality ) && allowAdvPersonality != 0 )
	 		self bot_balance_personality();

 		/#
		debug_personality = GetDvar( "bot_debugPersonality", "default" );
	 		
	 	if( debug_personality != "default" )
	 		self bot_set_personality( debug_personality );
	 	#/
	 		
		self bot_assign_personality_functions();

 		if ( firstSpawn )
		{
 			self bot_set_loadout_class();
 			if ( !bot_gametype_chooses_class() )
				self notify( "luinotifyserver", "class_select", self.bot_class );
 			if ( self.health == 0 )
 				self waittill( "spawned_player" );	// Don't wait here if we have health (i.e. we've already spawned)
			if ( IsDefined( level.bot_funcs ) && IsDefined( level.bot_funcs["know_enemies_on_start"] ) )
				self thread [[ level.bot_funcs["know_enemies_on_start"] ]]();
			firstSpawn = false;
		}
				
		self bot_restart_think_threads();
		
		wait( 0.10 );
		
		self waittill( "death" );
		self waittill( "spawned_player" );
	}
}

bot_get_rank_xp()
{
	if ( !self BotIsRandomized() )
		return self.pers[ "rankxp" ];
	
	if ( IsDefined(self.pers[ "rankxp" ]) )
		return self.pers[ "rankxp" ];
	
	desiredRanks = bot_random_ranks_for_difficulty( self BotGetDifficulty() );

	rank = desiredRanks[ "rank" ];
	prestige = desiredRanks[ "prestige" ];	
	
	minXP = maps\mp\gametypes\_rank::getRankInfoMinXP( rank );
	maxXP = minXP + maps\mp\gametypes\_rank::getRankInfoXPAmt( rank ) ;
	rankXP = RandomIntRange( minXP, maxXP + 1 );
	
	return rankXP;
}

bot_3d_sighting_model( modelEnt, associatedEnt )
{
	self thread bot_3d_sighting_model_thread( modelEnt, associatedEnt );
}

bot_3d_sighting_model_thread( modelEnt, associatedEnt )
{
	modelEnt endon( "death" );
	
	associatedEnt endon("disconnect");	
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	while( 1 )
	{
		if ( IsAlive( self ) && !(self BotCanSeeEntity( associatedEnt )) && within_fov( self.origin, self.angles, modelEnt.origin, self BotGetFovDot() ) )
			self BotGetImperfectEnemyInfo( associatedEnt, modelEnt.origin );
		
		wait 0.1;
	}
}

bot_choose_difficulty( choices )
{
	assert( IsArray( choices ) );
	
	difficulty = self.bot_chosen_difficulty;
	
	if ( !IsDefined( difficulty ) )
	{
		inUseCount = [];
		
		foreach ( player in level.players )
		{
			if ( player == self )
				continue;
			
			if ( !isAI( player ) )
				continue;
			
			usedDifficulty = player BotGetDifficulty();
			if ( usedDifficulty == "default" )
				continue;
			
			if ( !IsDefined( inUseCount[self.team] ) )
			    inUseCount[self.team] = [];

			if ( !IsDefined( inUseCount[self.team][usedDifficulty] ) )
				inUseCount[self.team][usedDifficulty] = 1;
			else
				inUseCount[self.team][usedDifficulty]++;
		}

		lowest = -1;
		
		foreach ( choice in choices )	
		{
			if ( !IsDefined( inUseCount[self.team] ) || !IsDefined( inUseCount[self.team][choice] ) )
			{
				difficulty = choice;
				break;
			}
			else if ( lowest == -1 || inUseCount[self.team][choice] < lowest )
			{
				lowest = inUseCount[self.team][choice];
				difficulty = choice;
			}
		}
	}
		
	if ( IsDefined( difficulty ) )
		self.bot_chosen_difficulty = difficulty;
	
	return difficulty;
}

bot_random_ranks_for_difficulty( difficulty )
{
	result = [];
	result["rank"] = 0;
	result["prestige"] = 0;
	
	if ( difficulty == "default" )
		return result;
	
	// Rank: 1 - 18, 20 - 28, 30 - 38, 40 - 50 (never set to N9 so there is no chance of jumping bracket by gained XP during the match)
	if ( !isDefined( level.bot_rnd_rank ) )
	{
		level.bot_rnd_rank = [];
		level.bot_rnd_rank["recruit"][0] = 	 0;
		level.bot_rnd_rank["recruit"][1] = 	17;
		level.bot_rnd_rank["regular"][0] = 	19;
		level.bot_rnd_rank["regular"][1] = 	27;
		level.bot_rnd_rank["hardened"][0] =	29;
		level.bot_rnd_rank["hardened"][1] = 37;
		level.bot_rnd_rank["veteran"][0] = 	39;
		level.bot_rnd_rank["veteran"][1] = 	49;
	}

	// Prestige: 2 - 9 only at veteran
	if ( !isDefined( level.bot_rnd_prestige ) )
	{
		level.bot_rnd_prestige = [];
		level.bot_rnd_prestige["recruit"][0] = 	0;
		level.bot_rnd_prestige["recruit"][1] = 	0;
		level.bot_rnd_prestige["regular"][0] = 	0;
		level.bot_rnd_prestige["regular"][1] = 	0;
		level.bot_rnd_prestige["hardened"][0] =	0;
		level.bot_rnd_prestige["hardened"][1] =	0;
		level.bot_rnd_prestige["veteran"][0] = 	0;
		level.bot_rnd_prestige["veteran"][1] = 	9;
	}

	if ( IsDefined( level.bot_rnd_rank[difficulty][0] ) && IsDefined( level.bot_rnd_rank[difficulty][1] ) )
	    result["rank"] = RandomIntRange( level.bot_rnd_rank[difficulty][0], level.bot_rnd_rank[difficulty][1] + 1 );

	if ( IsDefined( level.bot_rnd_prestige[difficulty][0] ) && IsDefined( level.bot_rnd_prestige[difficulty][1] ) )
	    result["prestige"] = RandomIntRange( level.bot_rnd_prestige[difficulty][0], level.bot_rnd_prestige[difficulty][1] + 1 );

	return result;
}

can_use_crate_always( crate )
{
	// Agents can only pickup boxes normally
	if ( IsAgent(self) && !IsDefined( crate.boxType ) )
		return false;

	return true;
}

//========================================================
//					get_human_player 
//========================================================
get_human_player()
{
	result = undefined;
	
	players = getEntArray( "player", "classname" );

	if ( IsDefined( players ) )
	{
		for( index = 0; index < players.size; index++ )
		{
			if( IsDefined( players[index] ) && IsDefined( players[index].connected ) && players[index].connected &&
			    !IsAI( players[index] ) && (!IsDefined( result ) || result.team == "spectator") )
			{
				result = players[index];
			}
		}
	}
	
	return result;
}

/#
get_all_humans()
{
	humans = [];
	
	foreach ( player in level.players )
	{
		if ( player.connected && !IsAI( player ) )
			humans = array_add( humans, player );
	}
	
	return humans;
}

spectators_exist()
{
	humans = get_all_humans();
	
	foreach( player in humans )
	{
		if ( player.team == "spectator" )
			return true;
	}
	
	return false;
}
#/

//========================================================
//					bot_damage_callback 
//========================================================
bot_damage_callback( eAttacker, iDamage, sMeansOfDeath, sWeapon, eInflictor, sHitLoc )
{
 	if( !IsDefined( self ) || !IsAlive( self ) )
 	{
 		return;
 	}
 
 	if( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
 	{
 		return;
 	}
 
 	if( iDamage <= 0 )
 	{
 		return;
 	}
 
 	if ( !IsDefined( eInflictor ) )
 	{
 		if ( !IsDefined( eAttacker ) )
 			return;
 		
 		eInflictor = eAttacker;
 	}
  
 	if ( IsDefined( eInflictor ) )
 	{
 		if ( level.teamBased )
 		{
 			if ( IsDefined( eInflictor.team ) && eInflictor.team == self.team )
 				return;
 			else if ( IsDefined( eAttacker ) && IsDefined( eAttacker.team ) && eAttacker.team == self.team )
 				return;
 		}
 
 		attacker_ent = bot_get_known_attacker( eAttacker, eInflictor );
 		if ( IsDefined(attacker_ent) )
 		self BotSetAttacker( attacker_ent );
 	}
}


//========================================================
//					on_bot_killed 
//========================================================
on_bot_killed( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, killId )
{
	self BotClearScriptEnemy();
	self BotClearScriptGoal();
	
	attacker_ent = bot_get_known_attacker( attacker, eInflictor );
	if ( !bot_is_fireteam_mode() && IsDefined(attacker_ent) && attacker_ent.classname == "script_vehicle" && IsDefined(attacker_ent.helitype) )
	{
		respawn_chance = self BotGetDifficultySetting("launcherRespawnChance");
		if ( RandomFloat(1.0) < respawn_chance )
			self.respawn_with_lockon_launcher = true;
	}
}


//========================================================
//					bot_should_do_killcam 
//========================================================
bot_should_do_killcam()
{
/#
	if ( GetDvar("scr_game_spectatetype") == "2" )
	{
		if ( spectators_exist() )
		{
			return false;
		}
	}
#/
	if ( bot_is_fireteam_mode() )
		return false;
	
	skip_killcam_chance = 0.0;
	bot_difficulty = self BotGetDifficulty();
	
	if ( bot_difficulty == "recruit" )
	{
		skip_killcam_chance = 0.1;
	}
	else if ( bot_difficulty == "regular" )
	{
		skip_killcam_chance = 0.4;
	}
	else if ( bot_difficulty == "hardened" )
	{
		skip_killcam_chance = 0.7;
	}   
	else if ( bot_difficulty == "veteran" )
	{
		skip_killcam_chance = 1.0;
	}
	
	return (RandomFloat(1.0) < (1.0-skip_killcam_chance));
}


//========================================================
//					bot_should_pickup_weapons 
//========================================================
bot_should_pickup_weapons()
{
	if ( self isJuggernaut() )
		return false;
	
	return true;
}


//========================================================
//					bot_restart_think_threads 
//========================================================
bot_restart_think_threads()
{
	self thread bot_think_watch_enemy();
	self thread bot_think_tactical_goals();
	self thread bot_think_seek_dropped_weapons();
	self thread bot_think_level_actions();
	self thread bot_think_crate();
	self thread bot_think_crate_blocking_path();
	self thread bot_think_revive();
	self thread bot_think_killstreak();
	self thread bot_think_watch_aerial_killstreak();
	self thread bot_think_gametype();
}

//========================================================
//					bot_think_watch_enemy 
//========================================================
bot_think_watch_enemy()
{
	self notify( "bot_think_watch_enemy" );
	self endon(  "bot_think_watch_enemy" );
		
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	// This function is for any logic that needs to be updated each frame regarding the enemy
	self.last_enemy_sight_time = GetTime();
	
	while( true )
	{
		if ( IsDefined( self.enemy ) )
		{
			if ( self BotCanSeeEntity( self.enemy ) )
			{
				self.last_enemy_sight_time = GetTime();
			}
		}
		
		wait(0.05);
	}
}

//========================================================
//					bot_think_dropped_weapons 
//========================================================
bot_think_seek_dropped_weapons()
{
	self notify( "bot_think_seek_dropped_weapons" );
	self endon(  "bot_think_seek_dropped_weapons" );
		
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	while( true )
	{
		still_seeking_weapon = false;
		
		if ( self bot_out_of_ammo() && self [[level.bot_funcs["should_pickup_weapons"]]]() )
		{
			dropped_weapons = GetEntArray("dropped_weapon","targetname");
			dropped_weapons_sorted = get_array_of_closest(self.origin,dropped_weapons);
			if ( dropped_weapons_sorted.size > 0 )
			{
				dropped_weapon = dropped_weapons_sorted[0];
				
				if ( self bot_has_tactical_goal( "seek_dropped_weapon", dropped_weapon ) == false )
				{
					needs_to_pickup_weapon = true;
					heldweapons = self GetWeaponsListPrimaries();
					foreach ( held_weapon in heldweapons )
					{
						if ( dropped_weapon.model == GetWeaponModel(held_weapon) )
						{
							needs_to_pickup_weapon = false;
						}
					}

					action_thread = undefined;
					if ( needs_to_pickup_weapon )
						action_thread = ::bot_pickup_weapon;
					
					extra_params = SpawnStruct();
					extra_params.object = dropped_weapon;
					extra_params.script_goal_radius = 12;
					extra_params.should_abort = ::should_stop_seeking_weapon;
					extra_params.action_thread = action_thread;
					self bot_new_tactical_goal( "seek_dropped_weapon", dropped_weapon.origin, 100, extra_params );
				}
			}
		}
		
		wait( RandomFloatRange(0.25, 0.75) );
	}
}

bot_pickup_weapon( goal )
{
	self BotPressButton( "use", 2 );
	wait(2);	
}

should_stop_seeking_weapon( goal )
{
	// goal.object is the dropped weapon
	
	if ( self bot_get_total_gun_ammo() > 0 )
		return true;
	
	if ( !IsDefined( goal.object ) )
		return true;
	
	return false;
}

//========================================================
//				bot_think_level_actions 
//========================================================
bot_think_level_actions()
{
	self notify( "bot_think_level_actions" );
	self endon(  "bot_think_level_actions" );
		
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	while( true )
	{
		waittill_notify_or_timeout( "calculate_new_level_targets", randomfloatrange( 2, 10 ) );
		
		if ( !IsDefined(level.level_specific_bot_targets) || level.level_specific_bot_targets.size == 0 )
			continue;
		
		if ( self bot_has_tactical_goal( "map_interactive_object" ) )
		    continue;
		
		if ( self bot_in_combat() )
			continue;
			
		target_picked = undefined;
		foreach( level_target in level.level_specific_bot_targets )
		{
			if ( array_contains( level_target.high_priority_for, self ) )
			{
				target_picked = level_target;
				break;
			}
		}
		
		if ( !IsDefined(target_picked) )
		{
			if ( RandomInt(100) > 25 )
				continue;
			
			level_triggers_sorted = get_array_of_closest( self.origin, level.level_specific_bot_targets );
			max_dist = 256;
			if ( self BotGetScriptGoalType() == "hunt" && self BotPursuingScriptGoal() )
				max_dist = 512;
			
			// If bot is not hunting, or bot is hunting but has an enemy targeted,
			// then only use one of these if the bot is relatively close to it
			if ( DistanceSquared( self.origin, level_triggers_sorted[0].origin ) > max_dist*max_dist )
				continue;
	
			target_picked = level_triggers_sorted[0];
		}

		assert( IsDefined(target_picked) );
		
		extra_params = SpawnStruct();
		extra_params.object = target_picked;
		extra_params.should_abort = ::level_trigger_used;
		if ( target_picked.bot_interaction_type == "use" )
		{
			extra_params.action_thread = ::use_use_trigger;
			self bot_new_tactical_goal( "map_interactive_object", target_picked.bot_target.origin, 10, extra_params );
		}
		else if ( target_picked.bot_interaction_type == "damage" )
		{
			Assert(target_picked.bot_targets.size == 2);
			
			should_melee_trigger = bot_out_of_ammo() || self.hasRiotShieldEquipped;
/#
			should_melee_trigger = should_melee_trigger || (GetDvarInt("bot_SimulateNoAmmo") == 1);
#/
			if ( should_melee_trigger )
			{
				extra_params.action_thread = ::melee_damage_trigger;
				extra_params.script_goal_radius = 20;
			}
			else
			{
				extra_params.action_thread = ::attack_damage_trigger;
				extra_params.script_goal_radius = 50;
			}
			
			node_target = undefined;
			path_dist_0 = GetPathDist( self.origin, target_picked.bot_targets[0].origin );
			path_dist_1 = GetPathDist( self.origin, target_picked.bot_targets[1].origin );
			
			Assert( path_dist_0 > 0 || path_dist_1 > 0 );
			
			if ( path_dist_0 > 0 )
			{
				if ( path_dist_1 < 0 || path_dist_0 <= path_dist_1 )
					node_target = target_picked.bot_targets[0];
			}
			
			if ( path_dist_1 > 0 )
			{
				if ( path_dist_0 < 0 || path_dist_1 <= path_dist_0 )
					node_target = target_picked.bot_targets[1];
			}
			
			Assert(IsDefined(node_target));
/#
			if ( !IsDefined(node_target) )
				continue;	// In non-ship, bail to avoid SRE spam
#/
			if ( !should_melee_trigger )
				self childthread monitor_node_visible( node_target );
			self bot_new_tactical_goal( "map_interactive_object", node_target.origin, 10, extra_params );
		}
	}
}

monitor_node_visible( node_target )
{
	self endon("goal");
	
	wait(0.1);	// give two frames for the tactical goal to start before we are allowed to notify "goal"
	
	while(1)
	{
		nearest_node_self = self GetNearestNode();
		if ( IsDefined(nearest_node_self) )
		{
			if ( NodesVisible( nearest_node_self, node_target ) )
				self notify("goal");
		}
		
		wait(0.05);
	}
}

attack_damage_trigger( goal )
{
	// goal.object is the trigger
	
	self BotSetFlag("disable_movement", true);
	self BotLookAtPoint( goal.object.origin, 0.30, "script_forced" );
	self BotPressButton( "ads", 0.30 );
	wait(0.25);
	
	while( IsDefined( goal.object ) && !IsDefined(goal.object.already_used) )
	{
		self BotLookAtPoint( goal.object.origin, 0.15, "script_forced" );
		self BotPressButton( "ads", 0.15 );
		self BotPressButton( "attack" );
		wait(0.1);
	}
	self BotSetFlag("disable_movement", false);
}

melee_damage_trigger( goal )
{
	// goal.object is the trigger
	
	self BotSetFlag("disable_movement", true);
	self BotLookAtPoint( goal.object.origin, 0.30, "script_forced" );
	wait(0.25);
	
	while( IsDefined( goal.object ) && !IsDefined(goal.object.already_used) )
	{
		self BotLookAtPoint( goal.object.origin, 0.15, "script_forced" );
		self BotPressButton( "melee" );
		wait(0.1);
	}
	self BotSetFlag("disable_movement", false);
}

use_use_trigger( goal )
{
	// goal.object is the trigger
	
	if ( IsAgent(self) )
	{
		self _enableUsability();
		wait(0.05);
	}
	
	time = goal.object.use_time;
	self BotPressButton( "use", time );
	wait( time );
	
	if ( IsAgent(self) )
	{
		self _disableUsability();
	}
}

level_trigger_used( goal )
{
	// goal.object is the use_trigger
	
	if ( !IsDefined( goal.object ) )
		return true;
	
	if ( IsDefined( goal.object.already_used ) )
		return true;

	return false;
}

bot_crate_valid( crate, player_use_radius )
{
	if ( !IsDefined( crate ) )
		return false;

	if ( !(self [[ level.bot_funcs["can_use_crate"] ]]( crate )) )
		return false;
	
	// Ignore any crate that is still falling
	if ( !IsDefined(crate.boxType) && (!IsDefined( crate.droppingToGround ) || crate.droppingToGround) )
		return false;

	// Ignore any crate that is off the path grid
	if ( IsDefined(crate.on_path_grid) && !crate.on_path_grid )
		return false;
	
	if ( !IsDefined(crate.on_path_grid) )
	{
		crate thread crate_monitor_position();
		
		if ( !IsDefined(crate.nearest_node) )
		{
			nearest_node = bot_get_node_nearest_point( crate.origin, player_use_radius );
			if ( !IsDefined(nearest_node) )
			{
				crate.on_path_grid = false;
				return false;
			}
			
			crate.nearest_node = nearest_node;
			crate.dist_to_nearest_node = Distance(crate.origin, crate.nearest_node.origin);
			if ( crate.dist_to_nearest_node > player_use_radius )
			{
				crate.on_path_grid = false;
				return false;
			}			
			
			crate.on_path_grid = true;
		}
	}

	// Ignore any crate that is a trap for the other team
	if ( level.teamBased && IsDefined( crate.bomb ) && IsDefined( crate.team ) && (crate.team == self.team) )
		return false;
	
	if ( !IsDefined( crate.owner ) || (crate.owner != self) )
	{
		// I didn't call in this crate...
		// Ignore it if it is greater than 2048 distance away
		if ( DistanceSquared( self.origin, crate.origin ) > 2048 * 2048 )
			return false;
	}
	
	if ( IsDefined(crate.boxType) )
	{
		if ( IsDefined( level.boxSettings[crate.boxType] ) && ![[level.boxSettings[crate.boxType].canUseCallback]]() )
			return false;
		
		if ( IsDefined( crate.disabled_use_for ) && IsDefined(crate.disabled_use_for[self GetEntityNumber()]) && crate.disabled_use_for[self GetEntityNumber()] )
			return false;
/#				
		if ( !IsDefined(level.bot_can_use_box_by_type[crate.boxType]) )
		{
			AssertMsg( "Crate type <" + crate.boxType + "> is not supported for bots" );
			return false;
		}
#/				
		if ( !self [[level.bot_can_use_box_by_type[crate.boxType]]]( crate ) )
			return false;
	}
	
	return true;
}

//========================================================
//					bot_think_crate 
//========================================================
bot_think_crate()
{
	self notify( "bot_think_crate" );
	self endon(  "bot_think_crate" );
		
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	player_use_radius = GetDvarFloat( "player_useRadius" );

	while( true )
	{
		wait_time = RandomFloatRange(2,4);
		self waittill_notify_or_timeout("new_crate_to_take", wait_time);
		
		if ( IsDefined( self.boxes ) )
		{
			self.boxes = array_remove_duplicates( self.boxes );
		
			if ( self.boxes.size == 0 )
				self.boxes = undefined;
		}
		
		all_crates = level.carePackages;
		
		if ( !(self bot_in_combat()) && IsDefined(self.boxes) )
			all_crates = array_combine(all_crates, self.boxes);

		if ( IsDefined( level.bot_scavenger_bags ) && self _hasPerk( "specialty_scavenger" ) )
			all_crates = array_combine(all_crates, level.bot_scavenger_bags);
		
		// Early out if we didn't find any crates
		all_crates = array_remove_duplicates( all_crates );
		if ( all_crates.size == 0 )
		{
			continue;
		}
		
		if ( bot_has_tactical_goal( "airdrop_crate" ) || self BotGetScriptGoalType() == "tactical" )
		{
			continue;
		}
		
		all_valid_crates = [];
		foreach ( crate in all_crates )
		{
			if ( self bot_crate_valid( crate, player_use_radius ) )
				all_valid_crates[all_valid_crates.size] = crate;
		}
		
		// We didn't find any valid crates to take
		if ( all_valid_crates.size == 0 )
			continue;
		
		// Sort the array
		all_valid_crates = get_array_of_closest( self.origin, all_valid_crates );
		
		// First check for the closest crate the bot can see (ignoring current FOV)
		nearest_node_bot = self GetNearestNode();
		if ( !IsDefined(nearest_node_bot) )
			continue;
		
		crate_to_take = undefined;
		foreach ( crate in all_valid_crates )
		{
			if ( NodesVisible(nearest_node_bot, crate.nearest_node, true) )
			{
				crate_to_take = crate;
				break;
			}
		}

		// Couldn't see any crates, so 50% chance to take the closest one pointed out on HUD to me that isnt claimed
		if ( !IsDefined( crate_to_take ) && (RandomInt(100) < 50) && !(self isEMPed()) )
		{
			foreach ( crate in all_valid_crates )
			{
				if ( !IsDefined( crate.bots ) || !IsDefined( crate.bots[self.team] ) || crate.bots[self.team] == 0 )
				{
					crate_to_take = crate;
					break;
				}
			}
		}
		
		if ( IsDefined( crate_to_take ) )
		{
			// Claim this crate
			if ( !IsDefined(crate_to_take.boxType) )
			{
			    if ( !IsDefined( crate_to_take.bots ) )
				{
					crate_to_take.bots = [];
				}
				crate_to_take.bots[self.team] = 1;
			}
			
			extra_params = SpawnStruct();
			extra_params.object = crate_to_take;
			extra_params.start_thread = ::watch_bot_died_during_crate;
			extra_params.should_abort = ::crate_picked_up;
			crate_dest = undefined;
			
			if ( IsDefined(crate_to_take.boxType) )
			{
				if ( IsDefined( crate_to_take.boxTouchOnly ) && crate_to_take.boxTouchOnly )
				{
					extra_params.script_goal_radius = 16;
					extra_params.action_thread = undefined;
					crate_dest = crate_to_take.origin;
				}
				else
				{
					extra_params.script_goal_radius = 50;
					extra_params.action_thread = ::use_box;
					
					vec_crate_to_nearest_node = crate_to_take.nearest_node.origin - crate_to_take.origin;
					scale = Length(vec_crate_to_nearest_node) * RandomFloat(1.0);
					crate_dest = (crate_to_take.origin + VectorNormalize(vec_crate_to_nearest_node) * scale) + (0,0,12);
				}
			}
			else
			{
				extra_params.script_goal_radius = (player_use_radius - crate_to_take.dist_to_nearest_node);
				extra_params.action_thread = ::use_crate;
				extra_params.end_thread = ::stop_using_crate;
				crate_dest = crate_to_take.nearest_node.origin + (0,0,24);
			}

			if ( IsDefined(extra_params.script_goal_radius) )
				Assert(extra_params.script_goal_radius >= 0);
			
			self bot_new_tactical_goal( "airdrop_crate", crate_dest, 30, extra_params );
		}
	}
}

bot_should_use_ballistic_vest_crate( crate )
{
	return true;
}

bot_get_low_on_ammo( minPercent )
{
	weapon_list = undefined;
	if ( IsDefined(self.weaponlist) && self.weaponlist.size > 0 )
		weapon_list = self.weaponlist;
	else
		weapon_list = self GetWeaponsListPrimaries();
	
	foreach ( weapon in weapon_list )
	{
		max_clip_ammo = WeaponClipSize( weapon );
		stock_ammo = self GetWeaponAmmoStock( weapon );
		
		if ( stock_ammo <= max_clip_ammo )
			return true;
		
		if ( self GetFractionMaxAmmo( weapon ) <= minPercent )
			return true;
	}
	
	return false;
}

bot_should_use_ammo_crate( crate )
{
	return self bot_get_low_on_ammo( 0.25 );
}

bot_should_use_scavenger_bag( crate )
{
	if ( self bot_get_low_on_ammo( 0.66 ) )
	{
		// Scavenger bag must be in sight 
		nearest_node_bot = self GetNearestNode();
		if ( IsDefined( crate.nearest_node ) && IsDefined( nearest_node_bot ) )
		{
			if ( NodesVisible(nearest_node_bot, crate.nearest_node, true) )
			{
				if ( within_fov( self.origin, self.angles, crate.origin, self BotGetFovDot() ) )
				    return true;
			}
		}
	}
	
	return false;
}

bot_should_use_grenade_crate( crate )
{
	offhand_list = self GetWeaponsListOffhands();
	foreach( weapon in offhand_list )
	{
		if ( self GetWeaponAmmoStock(weapon) == 0 )
			return true;
	}
	
	return false;
}

bot_should_use_juicebox_crate( crate )
{
	return true;
}

crate_monitor_position()
{
	self notify("crate_monitor_position");
	self endon("crate_monitor_position");
	
	self endon("death");
	level endon("game_ended");
	
	while(1)
	{
		lastPos = self.origin;
		wait(0.5);
		if ( !IsAlive( self ) )
			return;
		if ( !bot_vectors_are_equal( self.origin, lastPos ) )
		{
			self.on_path_grid = undefined;
			self.nearest_node = undefined;
		}
	}
}

crate_picked_up( goal )
{
	// goal.object is the crate
	
	if ( !IsDefined( goal.object ) )
		return true;

	return false;
}

use_crate( goal )
{
	// goal.object is the crate
	
	if ( IsAgent(self) )
	{
		self _enableUsability();
		wait(0.05);
	}

	// crate.owner doesn't have to exist.  But if it does, and this bot is the owner, use the shorter amount of time
	if ( IsDefined(goal.object.owner) && goal.object.owner == self )
	{
		time = level.crateOwnerUseTime / 1000 + 0.5;
	}
	else
	{
		time = level.crateNonOwnerUseTime / 1000 + 1.0;
	}
	
	self BotPressButton( "use", time );
	wait( time );

	if ( IsAgent(self) )
	{
		self _disableUsability();
	}
}

use_box( goal )
{
	// goal.object is the box
	
	if ( IsAgent(self) )
	{
		self _enableUsability();
		wait(0.05);
	}
	
	time = (level.boxSettings[goal.object.boxType].useTime / 1000) + 0.5;
	self BotPressButton( "use", time );
	wait( time );
	
	if ( IsAgent(self) )
	{
		self _disableUsability();
	}
}

watch_bot_died_during_crate( goal )
{
	// goal.object is the crate
	
	self thread bot_watch_for_death( goal.object );
}

stop_using_crate( goal )
{
	// goal.object is the crate
	
	if ( IsDefined( goal.object ) )
	{
		goal.object.bots[self.team] = 0;
	}
}

//========================================================
//				bot_watch_for_death 
//========================================================
bot_watch_for_death( object )
{
	object endon( "death" );
	object endon( "revived" );
	object endon( "disconnect" );

	level endon( "game_ended" );

	prev_team = self.team;
	self waittill_any( "death", "disconnect" );
	if ( IsDefined(object) )
	{
		object.bots[prev_team] = 0;
	}
}


//========================================================
//			bot_think_crate_blocking_path 
//========================================================
bot_think_crate_blocking_path()
{
	self notify( "bot_think_crate_blocking_path" );
	self endon(  "bot_think_crate_blocking_path" );

	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	radius = GetDvarFloat( "player_useRadius" );

	// ensure bots don't get stuck on crates
	while( true )
	{
		wait( 3 );

		if( self UseButtonPressed() )
		{
			continue;
		}

		crates = level.carePackages;

		for ( i = 0; i < crates.size; i++ )
		{
			crate = crates[i];

			if( DistanceSquared( self.origin, crate.origin ) < radius * radius )
			{
				if ( crate.owner == self )
				{
					self BotPressButton( "use", level.crateOwnerUseTime / 1000 + 0.5 );
				}
				else
				{
					self BotPressButton( "use", level.crateNonOwnerUseTime / 1000 + 0.5 );
				}
			}
		}
	}
}

//========================================================
//					bot_think_revive 
//========================================================
bot_think_revive()
{
	self notify( "bot_think_revive" );
	self endon(  "bot_think_revive" );

	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	if( !level.teamBased )
	{
		return;
	}

	while( true )
	{
		wait( randomintrange( 3, 5 ) );

		if( !self bot_can_revive() )
		{
			continue;
		}

		revive_triggers = GetEntArray( "revive_trigger", "targetname" );
		for( i = 0; i < revive_triggers.size; i++ )
		{
			revive_trigger = revive_triggers[i];
			player = revive_trigger.owner;

			if( !IsDefined( player) )
			{
				continue;
			}

			if( player == self )
			{
				continue;
			}

			if( !IsAlive( player ) )
			{
				continue;
			}

			if( player.team != self.team )
			{
				continue;
			}

			if( !IsDefined( player.inLastStand ) || !player.inLastStand )
			{
				continue;
			}

			if ( IsDefined( player.bots ) && IsDefined( player.bots[self.team] ) && player.bots[self.team] > 0 )
			{
				continue;
			}
			
			if( DistanceSquared( self.origin, player.origin ) < 2048 * 2048 )
			{
				extra_params = SpawnStruct();
				extra_params.object = player;
				extra_params.script_goal_radius = 64;
				extra_params.start_thread = ::watch_bot_died_during_revive;
				extra_params.end_thread = ::stop_reviving;
				extra_params.should_abort = ::player_revived_or_dead;
				extra_params.action_thread = ::revive_player;
				self bot_new_tactical_goal( "revive", player.origin, 60, extra_params );
				break;
			}
		}
	}
}

watch_bot_died_during_revive( goal )
{
	// goal.object is the player to revive
	
	self thread bot_watch_for_death( goal.object );
}

stop_reviving( goal )
{
	// goal.object is the player to revive
	
	if ( IsDefined( goal.object ) )
	{
		goal.object.bots[self.team] = 0;
	}
}

player_revived_or_dead( goal )
{
	// goal.object is the player to revive
	
	if ( !IsDefined( goal.object ) || goal.object.health <= 0 )
		return true;
	
	if ( !IsDefined( goal.object.inLastStand ) || !goal.object.inLastStand )
		return true;

	return false;
}

revive_player( goal )
{
	// goal.object is the player to revive
	
	prev_team = self.team;
	self BotPressButton( "use", level.lastStandUseTime / 1000 + 0.5 );
	
	wait( level.lastStandUseTime / 1000 + 1.5 );
	
	if ( IsDefined(goal.object) )
		goal.object.bots[prev_team] = 0;
}


//========================================================
//					bot_can_revive 
//========================================================
bot_can_revive()
{
	if( !IsDefined( self ) )
	{
		return false;
	}

	if( !IsAlive( self ) )
	{
		return false;
	}

	if( IsDefined( self.laststand ) && self.laststand == true )
	{
		return false;
	}
	
	if ( self bot_has_tactical_goal( "revive" ) )
	{
		return false;	
	}

	goalType = self BotGetScriptGoalType();
	if( goalType != "none" && goalType != "guard" && goalType != "hunt" )
	{
		return false;
	}

	return true;
}


//========================================================
//				revive_watch_for_finished 
//========================================================
revive_watch_for_finished( player )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "bad_path" );
	self endon( "goal" );

	player waittill_any( "death", "revived" );
	self notify( "bad_path" );
}

//========================================================
//			bot_know_enemies_on_start
//========================================================
bot_know_enemies_on_start()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	// Wait till grace period is over, then let this bot know where enemies are
	// (this is intended for the beginning of a match to get them seeking out enemies based on "knowledge" of the map start spots)
	if ( GetTime() > 15000 ) 
		return;
	
	while ( !gameHasStarted() || !gameFlag( "prematch_done" ) )
	{
		wait 0.05;
	}

	chosenEnemy = undefined;	
	chosenEnemyKnowSelf = undefined;

	for ( enemyIdx = 0; enemyIdx < level.players.size; enemyIdx++ )
	{
		otherPlayer = level.players[enemyIdx];
		if ( IsDefined( otherPlayer ) && IsEnemyTeam( self.team, otherPlayer.team ) )
		{
			if ( !IsDefined( otherPlayer.bot_start_known_by_enemy ) )
				chosenEnemy = otherPlayer;
			
			if ( IsAI( otherPlayer ) && !IsDefined( otherPlayer.bot_start_know_enemy ) )
				chosenEnemyKnowSelf = otherPlayer;
		}
	}
	
	if ( IsDefined( chosenEnemy ) )
	{
		self.bot_start_know_enemy = true;
		chosenEnemy.bot_start_known_by_enemy = true;
		self GetEnemyInfo( chosenEnemy );		
	}
	
	if ( IsDefined( chosenEnemyKnowSelf ) )
	{
		chosenEnemyKnowSelf.bot_start_know_enemy = true;
		self.bot_start_known_by_enemy = true;
		chosenEnemyKnowSelf GetEnemyInfo( self );		
	}
}

//========================================================
//			bot_make_entity_sentient
//========================================================
bot_make_entity_sentient( team, expendable )
{
	if ( IsDefined(expendable) )
		return self MakeEntitySentient( team, expendable );
	else
	return self MakeEntitySentient( team );
}

//========================================================
//			bot_think_gametype
//========================================================
bot_think_gametype()
{
	self notify( "bot_think_gametype" );
	self endon(  "bot_think_gametype" );
	
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	gameFlagWait( "prematch_done" );
	
	self thread [[ level.bot_funcs["gametype_think"] ]]();
}

default_gametype_think()
{
	// do nothing
}


monitor_smoke_grenades()
{
	while(1)
	{
		level waittill("smoke", smoke_grenade, smoke_grenade_weaponName);
		
		if ( smoke_grenade_weaponName == "smoke_grenade_mp" )
		{
			smoke_grenade thread handle_smoke();
		}
	}
}

handle_smoke()
{
	self waittill("explode", explosion_location );
	
	new_sight_clip_origin = spawn_tag_origin();
	new_sight_clip_origin show();
	new_sight_clip_origin.origin = explosion_location;
	next_wait_time = 0.8;
	
	wait(next_wait_time);
	next_wait_time = 0.5;
	smoke_sight_clip_collision_64_short = GetEnt( "smoke_grenade_sight_clip_64_short", "targetname" );
	if ( IsDefined(smoke_sight_clip_collision_64_short) )
	{
		new_sight_clip_origin CloneBrushmodelToScriptmodel( smoke_sight_clip_collision_64_short );
		//draw_entity_bounds( new_sight_clip_origin, next_wait_time, (1,0,0) );
	}
	
	wait(next_wait_time);
	next_wait_time = 0.6;
	smoke_sight_clip_collision_64_tall = GetEnt( "smoke_grenade_sight_clip_64_tall", "targetname" );
	if ( IsDefined(smoke_sight_clip_collision_64_tall) )
	{
		new_sight_clip_origin CloneBrushmodelToScriptmodel( smoke_sight_clip_collision_64_tall );
		//draw_entity_bounds( new_sight_clip_origin, next_wait_time, (1,0,0) );
	}

	wait(next_wait_time);
	next_wait_time = 9;
	smoke_sight_clip_collision_256 = GetEnt( "smoke_grenade_sight_clip_256", "targetname" );
	if ( IsDefined(smoke_sight_clip_collision_256) )
	{
		new_sight_clip_origin CloneBrushmodelToScriptmodel( smoke_sight_clip_collision_256 );
		//draw_entity_bounds( new_sight_clip_origin, next_wait_time, (1,0,0) );
	}
	
	wait(next_wait_time);
	new_sight_clip_origin delete();
}

bot_add_scavenger_bag( dropBag )
{
	added = false;
	
	dropBag.boxType = "scavenger_bag";
	dropBag.boxTouchOnly = true;
	
	if ( !IsDefined( level.bot_scavenger_bags ) )
		level.bot_scavenger_bags = [];

	// First fill any empty slot found	
	foreach( index, existingBag in level.bot_scavenger_bags )
	{
		if ( !IsDefined( existingBag ) )
		{
			added = true;
			level.bot_scavenger_bags[index] = dropBag;
			break;
		}
	}

	if ( !added )
		level.bot_scavenger_bags[level.bot_scavenger_bags.size] = dropBag;

	// Notify all scavengers that this bag is now available
	foreach( participant in level.participants )
	{
		if ( isAI( participant ) && participant _hasPerk( "specialty_scavenger" ) )
			participant notify( "new_crate_to_take" );
	}
}