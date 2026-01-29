#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\alien\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\scripts\_alien_armory;
#include maps\mp\alien\_persistence;

MAX_CURRENCY = 6000;
ACTION_SLOT_MAX_FREQUENCY = 0.2;

main()
{
	// init perks from data table
	maps\mp\alien\_perks::init_perks();
	
	// init combat resources from data table
	maps\mp\alien\_combat_resources::init_combat_resources();
}

//=== Common ===

player_setup()
{
	self SetActionSlot( 1, "" );
	self SetActionSlot( 2, "" );
	self SetActionSlot( 3, "" );
	self SetActionSlot( 4, "" );

	self NotifyOnPlayerCommand( "action_slot_1", "+actionslot 1" );
	self NotifyOnPlayerCommand( "action_slot_2", "+actionslot 2" );
	self NotifyOnPlayerCommand( "action_slot_3", "+actionslot 3" );
	self NotifyOnPlayerCommand( "action_slot_4", "+actionslot 4" );
	self NotifyOnPlayerCommand( "action_use", "+attack");
	self NotifyOnPlayerCommand( "alt_action_use", "-attack");

/#
	self maps\mp\alien\_debug::debug_progression_upgrade( "munition_try_upgrade", "+smoke" );
#/

	self thread player_watcher();
}

player_watcher()
{
	self thread player_action_slot_1();
	self thread player_action_slot_2();
	self thread player_action_slot_3();
	self thread player_action_slot_4();

	self thread player_watch_upgrade();
}

player_watch_upgrade()
{
	self thread player_watch_dpad_upgrade( level.alien_combat_resources[ "munition" ][ self get_selected_dpad_up() ] );
	self thread player_watch_dpad_upgrade( level.alien_combat_resources[ "support" ][ self get_selected_dpad_down() ] );
	self thread player_watch_dpad_upgrade( level.alien_combat_resources[ "defense" ][ self get_selected_dpad_left() ] );
	self thread player_watch_dpad_upgrade( level.alien_combat_resources[ "offense" ][ self get_selected_dpad_right() ] );

	self thread player_watch_perk_upgrade( level.alien_perks["perk_0"][ self get_selected_perk_0() ], "perk_0" );
	self thread player_watch_perk_upgrade( level.alien_perks["perk_1"][ self get_selected_perk_1() ], "perk_1" );
}

player_watch_dpad_upgrade( resource )
{
	self player_watch_upgrade_internal( resource, resource.type );
}

player_watch_perk_upgrade( resource, slot )
{
	self player_watch_upgrade_internal( resource, slot );
	self thread player_handle_perk_upgrades( resource, slot );
}

player_watch_upgrade_internal( resource, type )
{
	notifyname = type + "_try_upgrade";
	while( true )
	{
		self waittillmatch( "luinotifyserver", notifyname );
		rank = self get_upgrade_level( type );
		
		if ( (rank + 1 < resource.upgrades.size) && self try_take_player_points( resource.upgrades[rank + 1].point_cost ) )
		{
			rank += 1;
			self set_upgrade_level( type, rank );
			self notify( "upgrade" );
		}
	}
}

//=== Perks ===

get_perk_ref_at_upgrade_level( perk_type, perk_ref, upgrade_level )
{
	return ( level.alien_perks[ perk_type ][ perk_ref ].upgrades[ upgrade_level ].ref );
}

player_handle_perk_upgrades( resource, type )
{
	while ( true )
	{
		self waittill( "upgrade" );
		rank = self get_upgrade_level( type );
		assert( rank > 0 );
		unset_perk( get_perk_ref_at_upgrade_level( type, resource.ref, rank - 1 ) );
		set_perk( get_perk_ref_at_upgrade_level( type, resource.ref, rank ) );
	}
}

//=== Action ===
player_cancel()
{
	self player_cancel_internal();

	//cleanup
	self EnableWeapons( );

	if ( IsDefined( self.last_weapon ) )
		self SwitchToWeapon( self.last_weapon );

	self.alien_used_resource = undefined;
}

player_cancel_internal()
{
	self endon( "action_finish_used" );
	self waittill_any( "action_slot_pressed", "upgrade", "action_slot_1", "action_slot_2", "action_slot_3", "action_slot_4" );

	resource = level.alien_combat_resources[ "munition" ][ self get_selected_dpad_up() ];
	self [[resource.callbacks.CancelUse]]( resource );
	resource = level.alien_combat_resources[ "support" ][ self get_selected_dpad_down() ];
	self [[resource.callbacks.CancelUse]]( resource );
	resource = level.alien_combat_resources[ "defense" ][ self get_selected_dpad_left() ];
	self [[resource.callbacks.CancelUse]]( resource );
	resource = level.alien_combat_resources[ "offense" ][ self get_selected_dpad_right() ];
	self [[resource.callbacks.CancelUse]]( resource );

	self notify( "canceled" );
	self notify( "player_action_slot_restart" );
}

player_watch_use()
{
	self endon( "action_unusable" );
	self waittill( "action_use" );
}

player_alt_watch_use()
{
	self endon( "action_unusable" );
	self waittill( "alt_action_use" );
}

player_use( resource, rank )
{
	self.last_weapon = self GetCurrentWeapon();

	self endon( "canceled" );
	self thread player_cancel();

	self [[resource.callbacks.TryUse]]( resource, rank );

	while ( true )
	{
		if( self [[resource.callbacks.CanUse]]( resource ) )
		{
			if( resource.ref != "dpad_claymore" && resource.ref != "dpad_betties" )
			{
				self player_watch_use();
			}
			else
			{
				self player_alt_watch_use();
			}
				
			break;
		}
		else
		{
			self notify( "action_unusable" );
		}

		wait 0.05;
	}

	self take_player_currency( resource.upgrades[rank].cost );
	self PlayLocalSound( "alien_killstreak_equip" );
	self [[resource.callbacks.Use]]( resource, rank );
	wait 0.5;
	self.alien_used_resource = undefined;
	self notify( "action_finish_used" );
	self notify( "player_action_slot_restart" );
}

player_action_slot( resource, rank, waittillname ) 
{
	self endon( "player_action_slot_block" );
	self endon( "upgrade" );

	while ( true )
	{
		self waittill( waittillname );
		if ( !IsDefined( self.alien_used_resource ) )
		{
			if ( self [[resource.callbacks.CanPurchase]]( resource ) )
			{
				if ( self player_has_enough_currency( resource.upgrades[rank].cost ) ) 
				{
					self.alien_used_resource = resource;
					self thread player_use( resource, rank );
					self notify( "player_action_slot_block" );
				}
			}
		}
	}
}

player_action_slot_1()
{
	while( true )
	{
		resource = level.alien_combat_resources[ "munition" ][ self get_selected_dpad_up() ];
		rank = self get_dpad_up_level();
		self thread player_action_slot( resource, rank, "action_slot_1" );
		self waittill_any( "upgrade", "player_action_slot_restart" );
		wait ACTION_SLOT_MAX_FREQUENCY;
	}
}

player_action_slot_2()
{
	while( true )
	{
		resource = level.alien_combat_resources[ "support" ][ self get_selected_dpad_down() ];
		rank = self get_dpad_down_level();
		self thread player_action_slot( resource, rank, "action_slot_2" );
		self waittill_any( "upgrade", "player_action_slot_restart" );
		wait ACTION_SLOT_MAX_FREQUENCY;
	}
}

player_action_slot_3()
{
	while( true )
	{
		resource = level.alien_combat_resources[ "defense" ][ self get_selected_dpad_left() ];
		rank = self get_dpad_left_level();
		self thread player_action_slot( resource, rank, "action_slot_3" );
		self waittill_any( "upgrade", "player_action_slot_restart" );
		wait ACTION_SLOT_MAX_FREQUENCY;
	}
}

player_action_slot_4()
{
	while( true )
	{
		resource = level.alien_combat_resources[ "offense" ][ self get_selected_dpad_right() ];
		rank = self get_dpad_right_level();
		self thread player_action_slot( resource, rank, "action_slot_4" );
		self waittill_any( "upgrade", "player_action_slot_restart" );
		wait ACTION_SLOT_MAX_FREQUENCY;
	}
}