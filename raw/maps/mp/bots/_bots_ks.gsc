#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_gamelogic;

#include maps\mp\bots\_bots;
#include maps\mp\bots\_bots_util;

//========================================================
//				bot_killstreak_setup
//========================================================

bot_killstreak_setup()
{
 	if ( !IsDefined( level.killstreak_botfunc ) )
	{
 		// ======================================================================================
		// Selectable Killstreaks ===============================================================

 		// Simple Use ===========================================================================
 		
 		bot_register_killstreak_func( "helicopter_flares",  		::bot_killstreak_simple_use, ::aerial_vehicle_allowed );
		bot_register_killstreak_func( "ball_drone_backup", 			::bot_killstreak_simple_use );
		bot_register_killstreak_func( "guard_dog",					::bot_killstreak_simple_use );
		bot_register_killstreak_func( "agent",						::bot_killstreak_simple_use );
		bot_register_killstreak_func( "jammer",						::bot_killstreak_simple_use, ::bot_can_use_emp );
		bot_register_killstreak_func( "air_superiority",			::bot_killstreak_simple_use, ::bot_can_use_air_superiority );

 		// Airdrop / Drop =======================================================================

 		bot_register_killstreak_func( "airdrop_juggernaut_maniac",  ::bot_killstreak_drop_outside );	
		bot_register_killstreak_func( "uplink",  					::bot_killstreak_drop_anywhere, ::bot_can_use_uplink );
		bot_register_killstreak_func( "deployable_juicebox",		::bot_killstreak_drop_anywhere );

 		// Special ==============================================================================

		bot_register_killstreak_func( "ims",  						maps\mp\bots\_bots_sentry::bot_killstreak_sentry, undefined, "trap" );
		bot_register_killstreak_func( "aa_launcher",				::bot_killstreak_never_use, ::bot_can_use_aa_launcher );

 		// ======================================================================================
		// Other Killstreaks (functional but not picked in botTemplateTable.csv==================
			
		bot_register_killstreak_func( "airdrop_assault",  			::bot_killstreak_drop_outside );
		bot_register_killstreak_func( "uav_3dping",  				::bot_killstreak_drop_outside, ::bot_can_use_uav );
		bot_register_killstreak_func( "deployable_vest",  			::bot_killstreak_drop_anywhere );
		bot_register_killstreak_func( "deployable_ammo",  			::bot_killstreak_drop_anywhere );
		bot_register_killstreak_func( "deployable_grenades",		::bot_killstreak_drop_anywhere );
		bot_register_killstreak_func( "emp",  						::bot_killstreak_simple_use, ::bot_can_use_emp );
		bot_register_killstreak_func( "helicopter",  				::bot_killstreak_simple_use, ::aerial_vehicle_allowed );
		bot_register_killstreak_func( "precision_airstrike",  		::bot_killstreak_choose_loc_enemies );
		bot_register_killstreak_func( "stealth_airstrike",  		::bot_killstreak_choose_loc_enemies );
		bot_register_killstreak_func( "sam_turret",  				maps\mp\bots\_bots_sentry::bot_killstreak_sentry, undefined, "turret_air" );
		bot_register_killstreak_func( "sentry",  					maps\mp\bots\_bots_sentry::bot_killstreak_sentry, undefined, "turret" );

		// Not Yet / No Longer Supported ========================================================

		/*
		bot_register_killstreak_func( "littlebird_support",  		::bot_killstreak_simple_use );
		bot_register_killstreak_func( "refill_ammo",				::bot_killstreak_simple_use );
		bot_register_killstreak_func( "counter_uav",  				::bot_killstreak_simple_use );
		bot_register_killstreak_func( "littlebird_flock",  			::bot_killstreak_simple_use );
		bot_register_killstreak_func( "directional_uav",			::bot_killstreak_simple_use );
		bot_register_killstreak_func( "uav",  						::bot_killstreak_simple_use );
		bot_register_killstreak_func( "uav_support",  				::bot_killstreak_simple_use );
		bot_register_killstreak_func( "ball_drone_radar", 			::bot_killstreak_simple_use );
		bot_register_killstreak_func( "ball_drone_3dping", 			::bot_killstreak_simple_use );
		bot_register_killstreak_func( "nuke",  						::bot_killstreak_simple_use );
		bot_register_killstreak_func( "osprey_gunner",  			::bot_killstreak_simple_use );
		bot_register_killstreak_func( "remote_mg_turret",  			::bot_killstreak_simple_use );
		bot_register_killstreak_func( "remote_tank",  				::bot_killstreak_simple_use );
		bot_register_killstreak_func( "remote_uav",  				::bot_killstreak_simple_use );
		
		bot_register_killstreak_func( "airdrop_juggernaut",  		::bot_killstreak_drop_outside );
		bot_register_killstreak_func( "airdrop_juggernaut_recon",  	::bot_killstreak_drop_outside );
		bot_register_killstreak_func( "airdrop_remote_tank",  		::bot_killstreak_drop_outside );
		bot_register_killstreak_func( "airdrop_sentry_minigun",  	::bot_killstreak_drop_outside );
		bot_register_killstreak_func( "escort_airdrop",  			::bot_killstreak_drop_outside );
		
		bot_register_killstreak_func( "kineticbombardment",			::bot_killstreak_choose_loc_enemies );
		bot_register_killstreak_func( "mrsiartillery",				::bot_killstreak_choose_loc_enemies );
		
		bot_register_killstreak_func( "ac130",  					::bot_killstreak_remote_control, ::bot_control_ac130 );
		bot_register_killstreak_func( "vanguard",  					::bot_killstreak_remote_control, ::bot_control_vanguard );
		bot_register_killstreak_func( "predator_missile",  			::bot_killstreak_remote_control, ::bot_control_predator_missile );
		bot_register_killstreak_func( "remote_mortar",  			::bot_killstreak_remote_control, ::bot_control_remote_mortar );
		bot_register_killstreak_func( "remote_tank", 	 			::bot_killstreak_remote_control, ::bot_control_remote_tank );
		
		Killstreaks from devgui (if not listed above):
		
		Assault:
		heli_pilot
		lasedStrike
		drone_hive
		
		Support:
		gas_airstrike
		heli_sniper
		high_value_target
		odin_support
		placeable_barrier
		recon_agent
		scramble_turret
		*/
		
		/#		
		bot_validate_killstreak_funcs();
		#/
	}
}


//========================================================
//				bot_register_killstreak_func 
//========================================================
bot_register_killstreak_func( name, func, can_use, optionalParam )
{
 	if ( !IsDefined( level.killstreak_botfunc ) )
		level.killstreak_botfunc = [];

	level.killstreak_botfunc[name] = func;
	
	if ( !IsDefined( level.killstreak_botcanuse ) )
		level.killstreak_botcanuse = [];
	
	level.killstreak_botcanuse[name] = can_use;
	
 	if ( !IsDefined( level.killstreak_botparm ) )
		level.killstreak_botparm = [];

	level.killstreak_botparm[name] = optionalParam;

 	if ( !IsDefined( level.bot_supported_killstreaks ) )
		level.bot_supported_killstreaks = [];
	level.bot_supported_killstreaks[level.bot_supported_killstreaks.size] = name;
}


/#
assert_streak_valid_for_bots_in_general(streak)
{
	if ( !bot_killstreak_valid_for_bots_in_general(streak) )
	{
		AssertMsg( "Bots do not support killstreak <" + streak + ">" );
	}
}

assert_streak_valid_for_specific_bot(streak, bot)
{
	if ( !bot_killstreak_valid_for_specific_bot(streak, bot) )
	{
		AssertMsg( "Bot <" + bot.name + "> does not support killstreak <" + streak + ">" );
	}
}

//========================================================
//				bot_validate_killstreak_funcs 
//========================================================
bot_validate_killstreak_funcs()
{
	// Give a second for other killstreaks to be included before testing
	// Needed because for example, init() in _dog_killstreak.gsc is called AFTER this function
	wait(1);
	
	errors = [];
	foreach( streakName in level.bot_supported_killstreaks )
	{
		if ( !bot_killstreak_valid_for_humans(streakName) )
		{
			error( "bot_validate_killstreak_funcs() invalid killstreak: " + streakName );		
			errors[errors.size] = streakName;
		}
	}
	if ( errors.size )
	{
		temp = level.killstreakFuncs;
		level.killStreakFuncs = [];
		foreach( streakName in temp )
		{
			if ( !array_contains( errors, streakName ) )
				level.killStreakFuncs[streakName] = temp[streakName];
		}
	}
}

bot_killstreak_valid_for_humans(streakName)
{
	// Checks if the specified killstreak is valid for human players (i.e. set up correctly, human players can use it, etc)
	return bot_killstreak_is_valid_internal(streakName, "humans");
}

bot_killstreak_valid_for_bots_in_general(streakName)
{
	// Checks if the specified killstreak is valid for bot players.  This means it is set up correctly for humans, AND bots also know how to use it
	return bot_killstreak_is_valid_internal(streakName, "bots");
}

bot_killstreak_valid_for_specific_bot(streakName, bot)
{
	// Checks if the specified killstreak is valid for bot players.  This means it is set up correctly for humans, AND bots also know how to use it,
	// and this specific bot can use it
	return bot_killstreak_is_valid_internal(streakName, "bots", bot);
}
#/

bot_killstreak_valid_for_specific_streakType(streakName, streakType, assertIt)
{
	if ( bot_is_fireteam_mode() )
	{
		// Disable asserts in fireteam for now
		return true;
	}

	// Checks if the specified killstreak is valid for bot players.  This means it is set up correctly for humans, AND bots also know how to use it,
	// and a bot with the given streakType could use it
	if ( bot_killstreak_is_valid_internal(streakName, "bots", undefined, streakType) )
	{
		return true;
	}
	else if ( assertIt )
	{
		AssertMsg( "Bots with streakType <" + streakType + "> do not support killstreak <" + streakName + ">" );
	}

	return false;
}

bot_killstreak_is_valid_internal(streakName, who_to_check, optional_bot, optional_streak_type)
{
	streakTypeSubStr = undefined;
	
	if ( !bot_killstreak_is_valid_single(streakName, who_to_check) )
	{
		// Either bots or human players don't have a function handle this killstreak
		return false;
	}
	
	if ( IsDefined( optional_streak_type ) )
	{
		// "loadoutStreakType" will be streaktype_assault, etc, so remove first 11 chars
		streakTypeSubStr = GetSubStr( optional_streak_type, 11);

		switch ( streakTypeSubStr ) 
		{
			case "assault":
				if ( !isAssaultKillstreak( streakName ) )
					return false;
				break;
			case "support":
				if ( !isSupportKillstreak( streakName ) )
					return false;
				break;
		}
	}
	
	return true;
}

bot_killstreak_is_valid_single(streakName, who_to_check)
{
	if ( who_to_check == "humans" )
	{
		return ( IsDefined( level.killstreakFuncs[streakName] ) && getKillstreakIndex( streakName ) != -1 );
	}
	else if ( who_to_check == "bots" )
	{
		return IsDefined( level.killstreak_botfunc[streakName] );
	}
	
	AssertMsg("Unreachable");
}
	
//========================================================
//				bot_think_killstreak 
//========================================================
bot_think_killstreak()
{
	self notify( "bot_think_killstreak" );
	self endon(  "bot_think_killstreak" );

	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	while( !IsDefined(level.killstreak_botfunc) )
		wait(0.05);
	
	for(;;)
	{
		if ( self bot_allowed_to_use_killstreaks() )
		{
			killstreaks_array = self.pers["killstreaks"];
			if ( IsDefined( killstreaks_array ) )
			{
				restart_loop = false;
				for ( ksi = 0; ksi < killstreaks_array.size && !restart_loop; ksi++ )
				{
					killstreak_info = killstreaks_array[ksi];
					
					if ( IsDefined( killstreak_info.streakName ) && IsDefined( self.bot_killstreak_wait ) && IsDefined( self.bot_killstreak_wait[killstreak_info.streakName] ) && GetTime() < self.bot_killstreak_wait[killstreak_info.streakName] )
						continue;
					
					if ( killstreak_info.available )
					{
						can_use_killstreak_function = level.killstreak_botcanuse[ killstreak_info.streakName ];
						if ( IsDefined(can_use_killstreak_function) && !self [[ can_use_killstreak_function ]]() )
							continue;
						
						killstreak_info.weapon = getKillstreakWeapon( killstreak_info.streakName );
						bot_killstreak_func = level.killstreak_botfunc[ killstreak_info.streakName ];
						
						if ( IsDefined( bot_killstreak_func ) )
					    {
							// Call the function (do NOT thread it)
							// This way its easy to manage one killstreak working at a time
							// and all these functions will end when any of the above endon conditions are met
							result = self [[bot_killstreak_func]]( killstreak_info, killstreaks_array, can_use_killstreak_function, level.killstreak_botparm[ killstreak_info.streakName ] );
							if ( !IsDefined( result ) || result == false )
							{
								// killstreak cannot be used yet, stop trying for a bit and come back to it later
								if ( !isdefined( self.bot_killstreak_wait ) )
									self.bot_killstreak_wait = [];
								self.bot_killstreak_wait[killstreak_info.streakName] = GetTime() + 5000;
							}
					    }
						else
						{
							// Bots dont know how to use this killstreak, just get rid of it so we can use something else on the stack
							killstreak_info.available = false;
							self maps\mp\killstreaks\_killstreaks::updateKillstreaks( false );
						}
						
						restart_loop = true;
					}
				}
			}
		}
		
		wait( RandomFloatRange( 1.0, 2.0 ) );
	}
}

bot_can_use_aa_launcher()
{
	// Bots don't use the AA Launcher like any other killstreak, rather it sits in their weapon list and code can select it as a weapon
	return false;
}

bot_killstreak_never_use()
{
	// This function needs to exist because every killstreak for bots needs a function, but it should never be called
	AssertMsg( "bot_killstreak_never_use() was somehow called" );
}

bot_can_use_air_superiority()
{
	if ( !self aerial_vehicle_allowed() )
		return false;
	
	possible_targets = self maps\mp\killstreaks\_air_superiority::findTargets();
	cur_time = GetTime();
	foreach( target in possible_targets )
	{
		if ( cur_time - target.birthtime > 5000 )
			return true;
	}
	
	return false;
}

aerial_vehicle_allowed()
{
	return !self isAirDenied();
}

bot_can_use_emp()
{
	// is there already an active EMP?
	if ( IsDefined( level.empPlayer ) )
		return false;
	
	otherTeam = level.otherTeam[self.team];	
	if ( isdefined( level.teamEMPed ) && IsDefined( level.teamEMPed[ otherTeam ] ) && level.teamEMPed[ otherTeam ] ) 
		return false;
	
	return true;
}

bot_can_use_uplink()
{
	// is there already an active uplink?
	if ( IsDefined( level.upLink ) && IsDefined( level.upLink[ self.team ] ) && level.upLink[ self.team ] > 0 )
		return false;
	
	return true;
}

bot_can_use_uav()
{
	// is there already an active UAV?
	if ( IsDefined( level.activeUAVs ) && IsDefined( level.activeUAVs[ self.team ] ) && level.activeUAVs[ self.team ] > 0 )
		return false;
	
	if ( IsDefined( level.activeUAVs ) && IsDefined( level.activeUAVs[ self.guid ] ) && level.activeUAVs[ self.guid ] > 0 )
		return false;
	
	return true;
}

//========================================================
//				bot_killstreak_simple_use 
//========================================================
bot_killstreak_simple_use( killstreak_info, killstreaks_array, canUseFunc, optional_param )
{
	self endon( "commander_took_over" );

	wait( RandomIntRange( 3, 5 ) );
		
	if ( !self bot_allowed_to_use_killstreaks() )
	{
		// This may have become false during the wait, like an enemy appeared while we were waiting
		return true;
	}
	
	if ( IsDefined( canUseFunc ) && !self [[canUseFunc]]() )
		return false;
	
	bot_switch_to_killstreak_weapon( killstreak_info, killstreaks_array, killstreak_info.weapon );
	
	return true;
}

//========================================================
//				bot_killstreak_drop_anywhere
//========================================================
bot_killstreak_drop_anywhere( killstreak_info, killstreaks_array, canUseFunc, optional_param )
{
	bot_killstreak_drop( killstreak_info, killstreaks_array, canUseFunc, optional_param, false );
}
	
//========================================================
//				bot_killstreak_drop_outside
//========================================================
bot_killstreak_drop_outside( killstreak_info, killstreaks_array, canUseFunc, optional_param )
{
	bot_killstreak_drop( killstreak_info, killstreaks_array, canUseFunc, optional_param, true );
}

//========================================================
//				bot_killstreak_drop
//========================================================
bot_killstreak_drop( killstreak_info, killstreaks_array, canUseFunc, optional_param, only_outside )
{
	self endon( "commander_took_over" );

	wait( RandomIntRange( 2, 4 ) );
	
	if ( !isDefined( only_outside ) ) 
		only_outside = false;
	
	if ( !self bot_allowed_to_use_killstreaks() )
	{
		// This may have become false during the wait, like an enemy appeared while we were waiting
		return true;
	}
	
	if ( IsDefined( canUseFunc ) && !self [[canUseFunc]]() )
		return false;
	
	ammo = self GetWeaponAmmoClip( killstreak_info.weapon ) + self GetWeaponAmmoStock( killstreak_info.weapon );
	if ( ammo == 0 )
	{
		// Trying to use an airdrop but we don't have any ammo
		foreach( streak in killstreaks_array )
		{
			if ( IsDefined(streak.streakName) && streak.streakName == killstreak_info.streakName )
				streak.available = 0;
		}
		self maps\mp\killstreaks\_killstreaks::updateKillstreaks( false );
		return true;
	}

	node_target = undefined;
	if ( only_outside )
	{
		outside_nodes = [];
		nodes_in_cone = self bot_get_nodes_in_cone( 750, 0.6, true );
		foreach ( node in nodes_in_cone )
		{
			if ( NodeExposedToSky( node ) )
				outside_nodes = array_add( outside_nodes, node );
		}
		
		if ( (nodes_in_cone.size > 5) && (outside_nodes.size > nodes_in_cone.size * 0.6) )
		{
			outside_nodes_sorted = get_array_of_closest( self.origin, outside_nodes, undefined, undefined, undefined, 150 );
			if ( outside_nodes_sorted.size > 0 )
				node_target = random(outside_nodes_sorted);
			else
				node_target = random(outside_nodes);
		}
	}
	
	if ( IsDefined(node_target) || !only_outside )
	{
		self BotSetFlag( "disable_movement", true );
		
		if ( IsDefined(node_target) )
			self BotLookAtPoint( node_target.origin, 1.5+0.95, "script_forced" );
		
		bot_switch_to_killstreak_weapon( killstreak_info, killstreaks_array, killstreak_info.weapon );
		wait(2.0);
		self BotPressButton( "attack" );
		wait(1.5);
		self SwitchToWeapon( "none" );	// clears scripted weapon for bots
		self BotSetFlag( "disable_movement", false );
	}
	
	return true;
}

//========================================================
//				bot_killstreak_remote_control
//========================================================
bot_killstreak_remote_control( killstreak_info, killstreaks_array, canUseFunc, controlFunc )
{
	self endon( "commander_took_over" );
	
	// let control thread decide if we can use this killstreak now or not
	if ( !IsDefined( controlFunc ) || !self [[controlFunc]](true) )
		return false;

	if ( !self bot_allowed_to_use_killstreaks() )
	{
		// This may have become false during the wait, like an enemy appeared while we were waiting
		return true;
	}
	
	// Get to a place to hide around me first
	nodesAroundMe = GetNodesInRadius( self.origin, 500, 0, 512 );
	if ( IsDefined( nodesAroundMe ) && nodesAroundMe.size > 0 )
	{
		hideNode = self BotNodePick( nodesAroundMe, 1, "node_hide" );
		if ( IsDefined( hideNode ) )
		{
			self BotSetScriptGoalNode( hideNode, "tactical" );
			result = self bot_waittill_goal_or_fail();
			if ( self BotHasScriptGoal() && IsDefined( self BotGetScriptGoalNode() ) && self BotGetScriptGoalNode() == hideNode )
				self BotClearScriptGoal();
			if ( result != "goal" )
				return true;
		}
	}
	
	// let control thread decide if we can use this killstreak now or not
	if ( !IsDefined( controlFunc ) || !self [[controlFunc]](true) )
		return false;

	if ( !self bot_allowed_to_use_killstreaks() )
	{
		// This may have become false during the wait, like an enemy appeared while we pathed to hiding spot
		return true;
	}
	
	bot_switch_to_killstreak_weapon( killstreak_info, killstreaks_array, killstreak_info.weapon );

	return self [[controlFunc]](false);
}

//========================================================
//				bot_control_ac130
//========================================================
bot_control_ac130( validToUseCheck )
{
	if ( validToUseCheck )
	{
		// validToUseCheck is true when the function is called to check if its ok to try and do this now
		if ( IsDefined( level.ac130player ) || level.ac130InUse )
			return false;

		if ( self isAirDenied() )
			return false;
	}
	else
	{
		// validToUseCheck is false when we are actively remote controlling something
		wait 0.5;
		
		while ( level.ac130player == self )
		{
			// TODO: Target enemies that are visible and shoot at them
			wait 0.05;
		}
	}	

	return true;
}

// Airspace is too crouded when any of these conditions are met
//	if ( isDefined( level.ac130player ) || level.ac130InUse )
//	if ( level.littleBirds >= 3 && dropType != "airdrop_mega" )
//	if ( airStrikeType == "harrier" && level.planes > 1 )
//  if ( isDefined( level.chopper ) )
//	if ( level.lbStrike >= 1 )

bot_switch_to_killstreak_weapon( killstreak_info, killstreaks_array, weapon_name )
{
	self bot_notify_streak_used( killstreak_info, killstreaks_array );
	wait(0.05);	// Wait for the notify to be received and self.killstreakIndexWeapon to be set
	self SwitchToWeapon( weapon_name );
}

bot_notify_streak_used( killstreak_info, killstreaks_array )
{
	if ( IsDefined( killstreak_info.isgimme ) && killstreak_info.isgimme )
	{
		self notify("streakUsed1");
	}
	else
	{
		for ( index = 0; index < 3; index++ )
		{
			if ( IsDefined(killstreaks_array[index].streakName) )
			{
				if ( killstreaks_array[index].streakName == killstreak_info.streakname )
					break;
			}
		}
		self notify("streakUsed" + (index+1));
	}
}

//========================================================
//			bot_killstreak_choose_loc_enemies 
//========================================================
bot_killstreak_choose_loc_enemies( killstreak_info, killstreaks_array, canUseFunc, optional_param )
{
	self endon( "commander_took_over" );
	wait( RandomIntRange( 3, 5 ) );
	
	if ( !self bot_allowed_to_use_killstreaks() )
	{
		// This may have become false during the wait, like an enemy appeared while we were waiting
		return;
	}
	
	zone_nearest_bot = GetZoneNearest( self.origin );
	if ( !IsDefined(zone_nearest_bot) )
		return;
	
	self BotSetFlag( "disable_movement", true );
	bot_switch_to_killstreak_weapon( killstreak_info, killstreaks_array, killstreak_info.weapon );
	wait 2;

	zone_count = GetZoneCount();
	best_zone = -1;
	best_zone_count = 0;
	possible_fallback_zones = [];
	iterate_backwards = RandomFloat(100) > 50;	// randomly choose to iterate backwards
	for ( z = 0; z < zone_count; z++ )
	{
		if ( iterate_backwards )
			zone = zone_count - 1 - z;
		else
			zone = z;
		
		if ( (zone != zone_nearest_bot) && (BotZoneGetIndoorPercent( zone ) < 0.25) )
		{
			// This zone is not the current bot's zone, and it is mostly an outside zone
			enemies_in_zone = BotZoneGetCount( zone, self.team, "enemy_predict" );
			if ( enemies_in_zone > best_zone_count )
			{
				best_zone = zone;
				best_zone_count = enemies_in_zone;
			}
			
			possible_fallback_zones = array_add( possible_fallback_zones, zone );
		}
	}
	
	if ( best_zone >= 0 )
		zoneCenter = GetZoneOrigin( best_zone );
	else if ( possible_fallback_zones.size > 0 )
		zoneCenter = GetZoneOrigin( random(possible_fallback_zones) );
	else
		zoneCenter = GetZoneOrigin(RandomInt( GetZoneCount() ));

	randomOffset = (RandomFloatRange(-500, 500), RandomFloatRange(-500, 500), 0);

	self notify( "confirm_location", zoneCenter + randomOffset, RandomIntRange(0, 360) );
	
	wait( 1.0 );
	self BotSetFlag( "disable_movement", false );
}

//========================================================
//			bot_think_watch_aerial_killstreak 
//========================================================
bot_think_watch_aerial_killstreak()
{
	self notify( "bot_think_watch_aerial_killstreak" );
	self endon(  "bot_think_watch_aerial_killstreak" );

	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	
	global_badplace_time_between_placing = 8;
	global_badplace_duration = 10;
	
	if ( !IsDefined(level.last_global_badplace_time) )
	{
		level.last_global_badplace_time = GetTime();
	}
	
	currently_hiding = false;
	while(1)
	{
		needs_to_hide = false;
		
		// Note: Stealth Bomber not checked for because...its stealth
		
		// Enemy called in Attack Helicopter / Chopper Gunner / Pave Low
		if ( IsDefined(level.chopper) && level.chopper.team != self.team )
		{
			needs_to_hide = true;
		}
				
		// Ally is using precision airstrike / harrier
		// Note: You'd think to check level.airstrikeInProgress, but actually when that variable
		//       is set to "undefined" the airstrike still has some time before it finishes
		if ( IsDefined(level.artilleryDangerCenters) )
		{
			foreach ( artilleryDangerCenter in level.artilleryDangerCenters )
			{
				if ( artilleryDangerCenter.team == self.team )
				{
					if ( isStrStart( artilleryDangerCenter.streakname, "precision" ) || isStrStart( artilleryDangerCenter.streakname, "harrier" ) )
					{
						needs_to_hide = true;
					}
				}
			}
		}
		
		// Enemy called in harrier jet
		if ( isDefined(level.harriers) )
		{
			foreach ( harrier in level.harriers )
			{
				if ( IsDefined(harrier) && harrier.team != self.team )
				{
					needs_to_hide = true;
				}
			}
		}
		
		// Enemy is using AC130
		if ( IsDefined(level.ac130InUse) && level.ac130InUse )
		{
			if ( IsDefined(level.ac130player) && level.ac130player.team != self.team )
			{
				needs_to_hide = true;
				if ( GetTime() > level.last_global_badplace_time + global_badplace_time_between_placing * 1000 )
				{
					BadPlace_Global( "", global_badplace_duration, self.team, "only_sky" );
					level.last_global_badplace_time = GetTime();
				}
			}
		}
		
		// Enemy is using Reaper
		if ( IsDefined(level.remote_mortar) && level.remote_mortar.team != self.team )
		{
			needs_to_hide = true;
			if ( GetTime() > level.last_global_badplace_time + global_badplace_time_between_placing * 1000 )
			{
				BadPlace_Global( "", global_badplace_duration, self.team, "only_sky" );
				level.last_global_badplace_time = GetTime();
			}
		}
		
		// Enemy is using predator drone
		if ( IsDefined(level.remoteMissileInProgress) )
		{
			foreach ( rocket in level.rockets )
			{
				if ( rocket.type == "remote" && rocket.team != self.team )
				{
					needs_to_hide = true;
					if ( GetTime() > level.last_global_badplace_time + global_badplace_time_between_placing * 1000 )
					{
						BadPlace_Global( "", global_badplace_duration, self.team, "only_sky" );
						level.last_global_badplace_time = GetTime();
					}
				}
			}
		}
		
		if ( !currently_hiding && needs_to_hide )
		{
			currently_hiding = true;
			self BotSetFlag( "hide_indoors", 1 );
		}
		if ( currently_hiding && !needs_to_hide )
		{
			currently_hiding = false;
			self BotSetFlag( "hide_indoors", 0 );
		}
		
		wait(RandomFloatRange(0.05,4.0));
	}
}
