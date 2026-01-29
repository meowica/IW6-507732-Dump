// Personality functions for bots

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bots_util;
#include maps\mp\bots\_bots_loadout;
#include maps\mp\bots\_bots_strategy;

//=======================================================
//			setup_personalities
//=======================================================
setup_personalities()
{
	level.bot_personality = [];
	level.bot_personality["active"][0] = "default";
	level.bot_personality["active"][1] = "run_and_gun";
	level.bot_personality["active"][2] = "cqb";
	level.bot_personality["stationary"][0] = "camper";
	
	level.bot_personality_type = [];
	foreach( index, personality_array in level.bot_personality )
	{
		foreach( personality in personality_array )
		{
			level.bot_personality_type[personality] = index;
		}
	}
	
	// Desired ratio of personalities
	// Currently we would like 2 active bots (run and gun, cqb, etc) for every 1 camper-type bot
	level.bot_personality_types_desired = [];
	level.bot_personality_types_desired["active"] = 2;
	level.bot_personality_types_desired["stationary"] = 1;

	level.bot_pers_init = [];
	level.bot_pers_init["default"] = ::init_personality_default;
	level.bot_pers_init["camper"] = ::init_personality_camper;
	
	level.bot_pers_update["default"] = ::update_personality_default;
	level.bot_pers_update["camper"] = ::update_personality_camper;
}

//=======================================================
//			assign_personality_functions
//=======================================================
bot_assign_personality_functions()
{
	self.personality = self BotGetPersonality();
	
	self.personality_init_function = level.bot_pers_init[self.personality];
	if ( !IsDefined(self.personality_init_function) )
	{
		self.personality_init_function = level.bot_pers_init["default"];
	}
	
	// Call the init function now
	self [[ self.personality_init_function ]]();
	
	self.personality_update_function = level.bot_pers_update[self.personality];
	if ( !IsDefined(self.personality_update_function) )
	{
		self.personality_update_function = level.bot_pers_update["default"];
	}
}

//=======================================================
//				bot_balance_personality
//=======================================================
bot_balance_personality()
{
	if( IsDefined(self.personalityManuallySet) && self.personalityManuallySet )
	{
		return;
	}
	
	if ( bot_is_fireteam_mode() )
		return;
	
	Assert(level.bot_personality.size == level.bot_personality_types_desired.size);
	
	persCounts = [];
	persCountsByType = [];
	foreach( personality_type, personality_array in level.bot_personality )
	{
		persCountsByType[personality_type] = 0;
		foreach( personality in personality_array )
			persCounts[personality] = 0;		
	}
	
	// Count up the number of personalities on my team (not including myself), and also the types
	foreach( bot in level.players )
	{
		if ( IsBot(bot) && IsDefined(bot.team) && (bot.team == self.team) && (bot != self) && IsDefined(bot.has_balanced_personality) )
		{
			personality = bot BotGetPersonality();
			personality_type = level.bot_personality_type[personality];
			persCounts[personality] = persCounts[personality] + 1;
			persCountsByType[personality_type] = persCountsByType[personality_type] + 1;
		}
	}
	
	// Determine which personality type is needed by looking at level.bot_personality_types_desired, which is the desired ratio of personalities
	type_needed = undefined;
	while( !IsDefined(type_needed) )
	{
		personality_types_desired_in_progress = level.bot_personality_types_desired;
		while ( personality_types_desired_in_progress.size > 0 )
		{
			pers_type_picked = bot_get_string_index_for_integer( personality_types_desired_in_progress, RandomInt(personality_types_desired_in_progress.size) );
			
			persCountsByType[pers_type_picked] -= level.bot_personality_types_desired[pers_type_picked];
			if ( persCountsByType[pers_type_picked] < 0 )
			{
				type_needed = pers_type_picked;
				break;
			}
			
			personality_types_desired_in_progress[pers_type_picked] = undefined;
		}
	}
	
	// Now that we know which personality type is needed, figure out which personality is needed within that type
	personality_needed = undefined;
	least_common_personality = undefined;
	least_common_personality_uses = 9999;
	most_common_personality = undefined;
	most_common_personality_uses = -9999;
	randomized_personalities_needed = array_randomize(level.bot_personality[type_needed]);
	foreach ( personality in randomized_personalities_needed )
	{
		if ( persCounts[personality] < least_common_personality_uses )
		{
			least_common_personality = personality;
			least_common_personality_uses = persCounts[personality];
		}
		
		if ( persCounts[personality] > most_common_personality_uses )
		{
			most_common_personality = personality;
			most_common_personality_uses = persCounts[personality];
		}
	}
	
	if ( most_common_personality_uses - least_common_personality_uses >= 2 )
		personality_needed = least_common_personality;
	else
		personality_needed = Random(level.bot_personality[type_needed]);
	
	if ( self BotGetPersonality() != personality_needed )
		self BotSetPersonality( personality_needed );
	
	self.has_balanced_personality = true;
}
	
//=======================================================
//				init_camper_data
//=======================================================
init_personality_camper()
{
	clear_camper_data();
}

//=======================================================
//				init_personality_default
//=======================================================
init_personality_default()
{
	
}

//=======================================================
//				update_personality_camper
//=======================================================
update_personality_camper()
{
	if ( should_select_new_ambush_point() && !self bot_is_defending() )
	{	
		// If we took a detour to "hunt" then wait till that goal gets cleared before camping again
		goalType = self BotGetScriptGoalType();
		foundCampNode = false;
		if ( goalType != "hunt" && !self bot_out_of_ammo() )	// Don't look for a camp node if we're out of ammo
			foundCampNode = self find_camp_node();
				
		if ( foundCampNode )
		{
			self.ambush_entrances = self bot_find_ambush_entrances( self.node_ambushing_from.origin );

			// If applicable, plant a trap to cover our rear first		
			trapTime = GetTime();
			self bot_set_optional_ambush_trap( self.ambush_entrances, self.node_ambushing_from, self.ambush_yaw );
			trapTime = GetTime() - trapTime;
			if ( trapTime > 0 && IsDefined( self.ambush_end ) && IsDefined( self.node_ambushing_from ) )
			{
				self.ambush_end += trapTime;
				self.node_ambushing_from.bot_ambush_end = self.ambush_end + 10000;
			}

			if ( !(self bot_has_tactical_goal()) && !self bot_is_defending() && IsDefined(self.node_ambushing_from) )
			{	
				// Go to the ambush point
				self BotSetScriptGoalNode( self.node_ambushing_from, "camp", self.ambush_yaw );			
				self thread clear_script_goal_on( "bad_path", "node_relinquished", "out_of_ammo" );
				self thread watch_out_of_ammo();
			
				// When we get there add in the travel time to our camping timer
				self thread bot_add_ambush_time_delayed( "clear_camper_data", "goal" );
				
				// When we get there look toward each of the entrances periodically
				self thread bot_watch_entrances_delayed( "clear_camper_data", "bot_add_ambush_time_delayed", self.ambush_entrances, self.ambush_yaw );
			}
		}
		else
		{
			// Hunt until we can find a reasonable camping spot to use
			if ( goalType == "camp" )
				self BotClearScriptGoal();
			update_personality_default();
		}
	}
}

//=======================================================
//			update_personality_default
//=======================================================
update_personality_default()
{
	script_goal = undefined;
	has_script_goal = self BotHasScriptGoal();
	if ( has_script_goal )
		script_goal = self BotGetScriptGoal();
	
	if ( !(self bot_has_tactical_goal()) )
	{	
		distSq = undefined;
		goalRadius = undefined;
		
		if ( has_script_goal ) 
		{
			distSq = DistanceSquared(self.origin,script_goal);
			goalRadius = self BotGetScriptGoalRadius();
			goalRadiusDbl = goalRadius * 2;
			
			if ( IsDefined( self.bot_memory_goal ) && distSq < goalRadiusDbl*goalRadiusDbl )
			{
				flagInvestigated = BotMemoryFlags( "investigated" );
				BotFlagMemoryEvents( 0, GetTime() - self.bot_memory_goal_time, 1, self.bot_memory_goal, goalRadiusDbl, "kill", flagInvestigated, self );
				BotFlagMemoryEvents( 0, GetTime() - self.bot_memory_goal_time, 1, self.bot_memory_goal, goalRadiusDbl, "death", flagInvestigated, self );
				self.bot_memory_goal = undefined;
				self.bot_memory_goal_time = undefined;
			}
		}
		
		if ( !has_script_goal || (distSq < goalRadius*goalRadius) )
		{
			set_random_path = self bot_random_path();
			if ( set_random_path )
				self thread clear_script_goal_on( "enemy", "bad_path", "goal", "node_relinquished", "search_end" );
		}
	}
}

//=======================================================
//			clear_script_goal_on
//=======================================================
clear_script_goal_on( event1, event2, event3, event4, event5 )
{
	self notify("clear_script_goal_on");
	self endon ("clear_script_goal_on");
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "start_tactical_goal" );
	
	self waittill_any( event1, event2, event3, event4, event5 );
	
	self BotClearScriptGoal();
}

//=======================================================
//			watch_out_of_ammo
//=======================================================
watch_out_of_ammo()
{
	self notify("watch_out_of_ammo");
	self endon ("watch_out_of_ammo");
	self endon( "death" );
	self endon( "disconnect" );
	
	while(!self bot_out_of_ammo())
		wait(0.5);
	
	self notify("out_of_ammo");
}

//=======================================================
//			bot_add_ambush_time_delayed
//=======================================================
bot_add_ambush_time_delayed( endEvent, waitFor )
{
	self notify( "bot_add_ambush_time_delayed" );
	self endon( "bot_add_ambush_time_delayed" );
	self endon( "death" );
	self endon( "disconnect" );

	if ( IsDefined( endEvent ) )
		self endon( endEvent );
	self endon( "node_relinquished" );
	self endon( "bad_path" );
	
	// Add in how long we waited to the self.ambush_end time
	startTime = GetTime();
	
	if ( IsDefined( waitFor ) )
		self waittill( waitFor );
	
	if ( IsDefined( self.ambush_end ) && IsDefined( self.node_ambushing_from ) )
	{
		self.ambush_end += GetTime() - startTime;
		self.node_ambushing_from.bot_ambush_end = self.ambush_end + 10000;
	}
	self notify( "bot_add_ambush_time_delayed" );
}

//=======================================================
//			bot_watch_entrances_delayed
//=======================================================
bot_watch_entrances_delayed( endEvent, waitFor, entrances, yaw )
{
	self notify( "bot_watch_entrances_delayed" );
	
	if ( entrances.size > 0 )
	{
		self endon( "bot_watch_entrances_delayed" );
		self endon( "death" );
		self endon( "disconnect" );
	
		self endon( endEvent );
		self endon( "node_relinquished" );
		self endon( "bad_path" );
		
		if ( IsDefined( waitFor ) ) 
			self waittill( waitFor );
		
		self endon("path_enemy");
		self childthread bot_watch_nodes( entrances, yaw, 0, self.ambush_end );
		self childthread bot_monitor_watch_entrances_camp();
	}
}

bot_monitor_watch_entrances_camp()
{
	self notify( "bot_monitor_watch_entrances_camp" );
	self endon( "bot_monitor_watch_entrances_camp" );
	self endon( "disconnect" );
	self endon( "death" );
	
	while( IsDefined( self.watch_nodes ) )
	{
		foreach( node in self.watch_nodes )
			node.watch_node_chance[self.entity_number] = 1.0;
		
		prioritize_watch_nodes_toward_enemies(0.5);

		wait(RandomFloatRange(0.5,0.75));
	}
}

//=======================================================
//			bot_find_ambush_entrances
//=======================================================
bot_find_ambush_entrances( ambush_point )
{
	// Get entrances and filter out any nodes that are too close
	entrances = FindEntrances( ambush_point );
	useEntrances = [];
	foreach ( node in entrances )
	{
		if ( DistanceSquared( self.origin, node.origin ) > 300 * 300 )
			useEntrances[useEntrances.size] = node;
	}
	return useEntrances;
}

//=======================================================
//			bot_filter_ambush_inuse
//=======================================================
bot_filter_ambush_inuse( nodes )
{
	resultNodes = [];
	
	now = GetTime();
	
	foreach( node in nodes )
	{
		if ( !IsDefined( node.bot_ambush_end ) || (now > node.bot_ambush_end) )
			resultNodes[resultNodes.size] = node;
	}
	
	return resultNodes;
}
	
//=======================================================
//			bot_filter_ambush_vicinity
//=======================================================
bot_filter_ambush_vicinity( nodes, bot, radius )
{
	resultNodes = [];
	
	radiusSq = (radius * radius);
	
	foreach( node in nodes )
	{
		tooClose = false;

		foreach( player in level.participants )
		{
			if ( !tooClose && (player.team == bot.team) && (player != bot) )
			{
				if ( IsDefined( player.node_ambushing_from ) )
				{
					distSq = DistanceSquared( player.node_ambushing_from.origin, node.origin );
					tooClose = ( distSq < radiusSq );
				}
			}			
		}
		
		if ( !tooClose )
			resultNodes[resultNodes.size] = node;	
	}
	
	return resultNodes;
}

//=======================================================
//			clear_camper_data
//=======================================================
clear_camper_data()
{
	self notify( "clear_camper_data" );
	
	if ( IsDefined( self.node_ambushing_from ) && IsDefined( self.node_ambushing_from.bot_ambush_end ) )
		self.node_ambushing_from.bot_ambush_end = undefined;
	
	self.node_ambushing_from 	= undefined;
	self.point_to_ambush		= undefined;
	self.ambush_yaw				= undefined;
	self.ambush_entrances		= undefined;
	self.ambush_duration 		= RandomIntRange( 20000, 30000 );
	self.ambush_end				= -1;	
}

//=======================================================
//			should_select_new_ambush_point
//======================================================
should_select_new_ambush_point()
{
	if ( self bot_has_tactical_goal() )
		return false;

	if ( GetTime() > self.ambush_end )
		return true;
	
	if ( !self BotHasScriptGoal() )
		return true;
	
	return false;
}


//=======================================================
//					find_camp_node
//=======================================================
find_camp_node( )
{
	self clear_camper_data();
	
	wait 0.05;

	if ( GetZoneCount() <= 0 )
		return false;

	myZone = GetZoneNearest( self.origin );
	targetZone = undefined;
	nextZone = undefined;
	faceAngles = self.angles;
	
	if ( IsDefined( myZone ) )
	{
		// Get nearest zone with predicted enemies but no allies
		zoneEnemies = BotZoneNearestCount( myZone, self.team, -1, "enemy_predict", ">", 0, "ally", "<", 1 );

		// Fallback to just nearest zone with enemies if that came back empty
		if ( !IsDefined( zoneEnemies ) )
			zoneEnemies = BotZoneNearestCount( myZone, self.team, -1, "enemy_predict", ">", 0 );

		// If we have no idea where enemies are then pick the zone furthest from me
		if ( !IsDefined( zoneEnemies ) )
		{
			furthestDist = 0;
			furthestZone = -1;
			for ( z = 0; z < GetZoneCount(); z++ )
			{
				dist = Distance2D( GetZoneOrigin( z ), self.origin );
				if ( dist > furthestDist )
				{
					furthestDist = dist;
					furthestZone = z;
				}
			}
			zoneEnemies = furthestZone;
		}

		if ( IsDefined( zoneEnemies ) )
		{
			zonePath = GetZonePath( myZone, zoneEnemies );
			if ( IsDefined( zonePath ) && (zonePath.size > 0) )
			{
				index = 0;
				
				// Pick a point along the path adjacent to predicted enemies but no further than the midpoint
				while ( index <= int(zonePath.size / 2) )
				{
					targetZone = zonePath[index];
					nextZone = zonePath[int(min(index+1, zonePath.size - 1))];

					if ( BotZoneGetCount( nextZone, self.team, "enemy_predict" ) != 0 )
						break;
					
					index++;
				}

				if ( IsDefined( targetZone ) && IsDefined( nextZone ) && targetZone != nextZone )
				{
					faceAngles = GetZoneOrigin( nextZone ) - GetZoneOrigin( targetZone );
					faceAngles = VectorToAngles( faceAngles );
				}
			}
		}
	}
		
	node_to_camp = undefined;
	
	if ( IsDefined( targetZone ) )
	{
		keep_searching = true;
		zone_steps = 1;
		use_lenient_flag = false;
		while( keep_searching )
		{
			// get set of nodes in the region we want to camp
			nodes_to_select_from = GetZoneNodesByDist( targetZone, 800 * zone_steps, true );
			
			if ( nodes_to_select_from.size > 1024 )
				nodes_to_select_from = GetZoneNodes( targetZone, 0 );
			nodes_to_select_from = bot_filter_ambush_inuse( nodes_to_select_from );
			if ( !IsDefined(self.can_camp_near_others) || !self.can_camp_near_others )
			{
				vicinity_radius = 800;
				nodes_to_select_from = bot_filter_ambush_vicinity( nodes_to_select_from, self, vicinity_radius );
			}
			
			// get direction we want to face in that region
			randomRoll = RandomInt( 100 );
			if ( randomRoll < 66 && randomRoll >= 33 )
				faceAngles = (faceAngles[0], faceAngles[1] + 45, 0);
			else if ( randomRoll < 33 )
				faceAngles = (faceAngles[0], faceAngles[1] - 45, 0);	
					
			// Choose from only the BEST camp spots from within those nodes facing that direction
			if ( nodes_to_select_from.size > 0 )
			{
				selectCount = min( nodes_to_select_from.size * 0.15, 5 );
				if ( use_lenient_flag )
					node_to_camp = self BotNodePick( nodes_to_select_from, selectCount, "node_camp", AnglesToForward( faceAngles ), "lenient" );
				else
					node_to_camp = self BotNodePick( nodes_to_select_from, selectCount, "node_camp", AnglesToForward( faceAngles ) );
			}
			
			if ( IsDefined(node_to_camp) )
			{
				keep_searching = false;
			}
			else
			{
				if ( IsDefined(self.camping_needs_fallback_camp_location) )
				{
					if ( zone_steps == 1 && !use_lenient_flag )
					{
						// First try 3 steps away instead of 1
						zone_steps = 3;
					}
					else if ( zone_steps == 3 && !use_lenient_flag )
					{
						// 3 steps failed, so try using the lenient flag
						use_lenient_flag = true;
					}
					else if ( zone_steps == 3 && use_lenient_flag )
					{
						// 3 zone steps AND the lenient flag didn't do it, so just bail
						keep_searching = false;
					}
				}
				else
				{
					keep_searching = false;
				}
			}
		}
	}
		
	if ( !IsDefined( node_to_camp ) || !self BotNodeAvailable( node_to_camp ) )
		return false;
	
	self.node_ambushing_from = node_to_camp;
	self.ambush_end = GetTime() + self.ambush_duration;
	self.node_ambushing_from.bot_ambush_end = self.ambush_end;
	self.ambush_yaw = faceAngles[1];
		
	return true;
}


//=======================================================
//					find_ambush_node
//=======================================================
find_ambush_node( optional_point_to_ambush )
{
	self clear_camper_data();
	
	if ( IsDefined(optional_point_to_ambush) )
	{
		self.point_to_ambush = optional_point_to_ambush;
	}
	else
	{
		// get all the high traffic nodes near the bot
		node_to_ambush = undefined;
		nodes_around_bot = GetNodesInRadius( self.origin, 5000, 0, 2000 );
		if ( nodes_around_bot.size > 0 )
		{
			node_to_ambush = self BotNodePick( nodes_around_bot, nodes_around_bot.size * 0.25, "node_traffic" );
		}
		
		if ( IsDefined( node_to_ambush ) )
		{
			self.point_to_ambush = node_to_ambush.origin;
		}
		else
		{
			return false;
		}
	}
	
	nodes_around_ambush_point = GetNodesInRadius( self.point_to_ambush, 2000, 0, 1000 );
	nodes_around_ambush_point = bot_filter_ambush_inuse( nodes_around_ambush_point );
	ambush_node_trying = undefined;
	if ( nodes_around_ambush_point.size > 0 )
	{
		ambush_node_trying = self BotNodePick( nodes_around_ambush_point, nodes_around_ambush_point.size * 0.15, "node_ambush", self.point_to_ambush );
	}
	
	if( !IsDefined( ambush_node_trying ) || !self BotNodeAvailable( ambush_node_trying )  )
		return false;
	
	self.node_ambushing_from = ambush_node_trying;
	self.ambush_end = GetTime() + self.ambush_duration;
	self.node_ambushing_from.bot_ambush_end = self.ambush_end;
	
	node_to_ambush_point = VectorNormalize( self.point_to_ambush - self.node_ambushing_from.origin );
	node_to_ambush_point_angles = VectorToAngles (node_to_ambush_point );

	self.ambush_yaw = node_to_ambush_point_angles[1];
	
	return true;
}

bot_random_path()
{
	random_path_func = level.bot_random_path_function[self.team];
	
	return self [[random_path_func]]();
}


//=======================================================
//					bot_random_path_default
//=======================================================
bot_random_path_default()
{
	result = false;
	
	chance_to_seek_out_killer = 50;
	if ( self.personality == "camper" )
	{
		chance_to_seek_out_killer = 0;
	}
	
	goalPos = undefined;
	if ( RandomInt(100) < chance_to_seek_out_killer )
	{
		goalPos = bot_recent_point_of_interest();
	}
	
	if ( !IsDefined( goalPos ) )
	{
		// Find a random place to go
		randomNode = self BotFindNodeRandom();
		if ( IsDefined( randomNode ) )
		{
			goalPos = randomNode.origin;
		}
	}
	
	if ( IsDefined( goalPos ) )
	{
		result = self BotSetScriptGoal( goalPos, 128, "hunt" );
	}
	
	return result;
}


//=======================================================
//				bot_setup_callback_class
//=======================================================
bot_setup_callback_class()
{
	if ( self bot_setup_loadout_callback() )
		return "callback";
	else
		return "class0";
}