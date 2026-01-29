#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\_utility;
#include maps\mp\alien\_persistence;

// ================================================================
//						Combat Resources Table
// ================================================================

WAVE_TABLE					= "mp/alien/dpad_tree.csv";

TABLE_INDEX					= 0;	// [int] 	Indexing
TABLE_REF					= 1;	// [string] Reference
TABLE_UNLOCK				= 2;	// [int] 	Unlocked at rank number
TABLE_POINT_COST			= 3;	// [int] 	Combat point cost to enable
TABLE_COST					= 4;	// [int] 	Cost to buy
TABLE_NAME					= 5;	// [string] Name localized
TABLE_DESC					= 6;	// [string]	Description localized
TABLE_ICON					= 7;	// [string] Reference string of icon
TABLE_DPAD_ICON				= 8;	// [string] Reference string of dpad hud icon
TABLE_IS_UPGRADE			= 9;	// [int] 0 if not an upgrade, 1 if an upgrade

TABLE_DPAD_MAX_INDEX		= 99;	// index range per type

init_combat_resources()
{
	// level.alien_combat_resources_table can be used to override default table, should be set before _alien::main()
	if ( !isdefined( level.alien_combat_resources_table ) )
		level.alien_combat_resources_table = WAVE_TABLE;
	
	init_combat_resources_callback();
	
	init_combat_resource_from_table();
}

init_combat_resources_callback()
{
	level.alien_combat_resource_callbacks = [];

	level.alien_combat_resource_callbacks["dpad_team_ammo"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_team_ammo"].CanUse			= ::CanUse_dpad_team_ammo;
	level.alien_combat_resource_callbacks["dpad_team_ammo"].CanPurchase		= ::CanPurchase_dpad_team_ammo;
	level.alien_combat_resource_callbacks["dpad_team_ammo"].TryUse			= ::TryUse_dpad_team_ammo;
	level.alien_combat_resource_callbacks["dpad_team_ammo"].Use				= ::Use_dpad_team_ammo;
	level.alien_combat_resource_callbacks["dpad_team_ammo"].CancelUse		= ::CancelUse_dpad_team_ammo;

	level.alien_combat_resource_callbacks["dpad_team_armor"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_team_armor"].CanUse			= ::CanUse_dpad_team_armor;
	level.alien_combat_resource_callbacks["dpad_team_armor"].CanPurchase	= ::CanPurchase_dpad_team_armor;
	level.alien_combat_resource_callbacks["dpad_team_armor"].TryUse			= ::TryUse_dpad_team_armor;
	level.alien_combat_resource_callbacks["dpad_team_armor"].Use			= ::Use_dpad_team_armor;
	level.alien_combat_resource_callbacks["dpad_team_armor"].CancelUse		= ::CancelUse_dpad_team_armor;
	
	level.alien_combat_resource_callbacks["dpad_team_boost"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_team_boost"].CanUse			= ::CanUse_dpad_team_boost;
	level.alien_combat_resource_callbacks["dpad_team_boost"].CanPurchase	= ::CanPurchase_dpad_team_boost;
	level.alien_combat_resource_callbacks["dpad_team_boost"].TryUse			= ::TryUse_dpad_team_boost;
	level.alien_combat_resource_callbacks["dpad_team_boost"].Use			= ::Use_dpad_team_boost;
	level.alien_combat_resource_callbacks["dpad_team_boost"].CancelUse		= ::CancelUse_dpad_team_boost;

	level.alien_combat_resource_callbacks["dpad_claymore"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_claymore"].CanUse			= ::CanUse_dpad_claymore;
	level.alien_combat_resource_callbacks["dpad_claymore"].CanPurchase		= ::CanPurchase_dpad_claymore;
	level.alien_combat_resource_callbacks["dpad_claymore"].TryUse			= ::TryUse_dpad_claymore;
	level.alien_combat_resource_callbacks["dpad_claymore"].Use				= ::Use_dpad_claymore;
	level.alien_combat_resource_callbacks["dpad_claymore"].CancelUse		= ::CancelUse_dpad_claymore;
	
	level.alien_combat_resource_callbacks["dpad_betties"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_betties"].CanUse			= ::CanUse_dpad_betties;
	level.alien_combat_resource_callbacks["dpad_betties"].CanPurchase		= ::CanPurchase_dpad_betties;
	level.alien_combat_resource_callbacks["dpad_betties"].TryUse			= ::TryUse_dpad_betties;
	level.alien_combat_resource_callbacks["dpad_betties"].Use				= ::Use_dpad_betties;
	level.alien_combat_resource_callbacks["dpad_betties"].CancelUse			= ::CancelUse_dpad_betties;
		
	level.alien_combat_resource_callbacks["dpad_ims"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_ims"].CanUse				= ::CanUse_dpad_ims;
	level.alien_combat_resource_callbacks["dpad_ims"].CanPurchase			= ::CanPurchase_dpad_ims;
	level.alien_combat_resource_callbacks["dpad_ims"].TryUse				= ::TryUse_dpad_ims;
	level.alien_combat_resource_callbacks["dpad_ims"].Use					= ::Use_dpad_ims;
	level.alien_combat_resource_callbacks["dpad_ims"].CancelUse				= ::CancelUse_dpad_ims;
	
	level.alien_combat_resource_callbacks["dpad_sentry"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_sentry"].CanUse				= ::CanUse_dpad_sentry;
	level.alien_combat_resource_callbacks["dpad_sentry"].CanPurchase		= ::CanPurchase_dpad_sentry;
	level.alien_combat_resource_callbacks["dpad_sentry"].TryUse				= ::TryUse_dpad_sentry;
	level.alien_combat_resource_callbacks["dpad_sentry"].Use				= ::Use_dpad_sentry;
	level.alien_combat_resource_callbacks["dpad_sentry"].CancelUse			= ::CancelUse_dpad_sentry;
		
	level.alien_combat_resource_callbacks["dpad_death_machine"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_death_machine"].CanUse				= ::CanUse_dpad_backup_uav;
	level.alien_combat_resource_callbacks["dpad_death_machine"].CanPurchase			= ::CanPurchase_dpad_backup_uav;
	level.alien_combat_resource_callbacks["dpad_death_machine"].TryUse				= ::TryUse_dpad_backup_uav;
	level.alien_combat_resource_callbacks["dpad_death_machine"].Use					= ::Use_dpad_backup_uav;
	level.alien_combat_resource_callbacks["dpad_death_machine"].CancelUse			= ::CancelUse_dpad_backup_uav;
	 
	level.alien_combat_resource_callbacks["dpad_airstrike"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_airstrike"].CanUse				= ::CanUse_dpad_airstrike;
	level.alien_combat_resource_callbacks["dpad_airstrike"].CanPurchase			= ::CanPurchase_dpad_airstrike;
	level.alien_combat_resource_callbacks["dpad_airstrike"].TryUse				= ::TryUse_dpad_airstrike;
	level.alien_combat_resource_callbacks["dpad_airstrike"].Use					= ::Use_dpad_airstrike;
	level.alien_combat_resource_callbacks["dpad_airstrike"].CancelUse			= ::CancelUse_dpad_airstrike;
	
	level.alien_combat_resource_callbacks["dpad_war_machine"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_war_machine"].CanUse			= ::CanUse_dpad_trophy;
	level.alien_combat_resource_callbacks["dpad_war_machine"].CanPurchase		= ::CanPurchase_dpad_trophy;
	level.alien_combat_resource_callbacks["dpad_war_machine"].TryUse			= ::TryUse_dpad_trophy;
	level.alien_combat_resource_callbacks["dpad_war_machine"].Use				= ::Use_dpad_trophy;
	level.alien_combat_resource_callbacks["dpad_war_machine"].CancelUse			= ::CancelUse_dpad_trophy;	
	
	level.alien_combat_resource_callbacks["dpad_trap"] = spawnstruct();
	level.alien_combat_resource_callbacks["dpad_trap"].CanUse					= ::CanUse_dpad_riotshield;
	level.alien_combat_resource_callbacks["dpad_trap"].CanPurchase				= ::CanPurchase_dpad_riotshield;
	level.alien_combat_resource_callbacks["dpad_trap"].TryUse					= ::TryUse_dpad_riotshield;
	level.alien_combat_resource_callbacks["dpad_trap"].Use						= ::Use_dpad_riotshield;
	level.alien_combat_resource_callbacks["dpad_trap"].CancelUse				= ::CancelUse_dpad_riotshield;
	
	///////////////////////////////////////////////////////////
	//			Airstrike Specific properties
	////////////////////////////////////////////////////////////
	
	level.mortar_fx["tracer"] = loadFx( "fx/misc/tracer_incoming" );
	level.mortar_fx["explosion"] = loadFx( "fx/explosions/building_explosion_huge_gulag" );
	level.mortarDamageRadius = 500;
	level.mortarDamageMin = 150;
	level.mortarDamageMax = 1000;
}

init_combat_resource_from_table()
{
	level.alien_combat_resources = [];
	
	populate_combat_resource_from_table( 0, "munition" );
	populate_combat_resource_from_table( 100,"support" );
	populate_combat_resource_from_table( 200, "defense" );
	populate_combat_resource_from_table( 300, "offense" );
}

populate_combat_resource_from_table( start_idx, resource_type )
{
	level.alien_combat_resources[ resource_type ] = [];
	
	for ( i = start_idx; i <= start_idx + TABLE_DPAD_MAX_INDEX; i++ )
	{
		// break on end of line
		resource_ref = get_resource_ref_by_index( i );
		if ( resource_ref == "" ) { break; }
		
		if ( !isdefined( level.alien_combat_resources[ resource_ref ] ) )
		{
			resource 			= spawnstruct();
			resource.upgrades 	= [];
			resource.unlock 	= get_unlock_by_ref( resource_ref );
			resource.name		= get_name_by_ref( resource_ref );
			resource.icon		= get_icon_by_ref( resource_ref );
			resource.dpad_icon	= get_dpad_icon_by_ref( resource_ref );
			resource.ref		= resource_ref;
			resource.type		= resource_type;
			resource.callbacks	= level.alien_combat_resource_callbacks[resource_ref];

			level.alien_combat_resources[ resource_type ][ resource_ref ] = resource;
		}
		
		accumulated_cost = 0;
		
		// grab all upgrades for this resource
		for ( j = i; j <= start_idx + TABLE_DPAD_MAX_INDEX; j++ )
		{
			upgrade_ref = get_resource_ref_by_index( j );
			if ( upgrade_ref == "" ) { break; }
			
			if ( resource_ref == upgrade_ref || is_resource_set( resource_ref, upgrade_ref ) )
			{
				upgrade 			= spawnstruct();
				upgrade.ref			= upgrade_ref;
				upgrade.desc		= get_desc_by_ref( upgrade_ref );
				upgrade.cost		= get_cost_by_ref( upgrade_ref );//currency
				upgrade.point_cost	= get_point_cost_by_ref( upgrade_ref );
				
				accumulated_cost += int( upgrade.point_cost );
				upgrade.total_cost = accumulated_cost;

				level.alien_combat_resources[ resource_type ][ resource_ref ].upgrades[ j - i ] = upgrade;
			}
			else
			{
				break;
			}
		}
		
		// point index to next set
		i = j - 1;
	}
}

// returns true if upgrade_ref is/or an upgrade of resource_ref
is_resource_set( resource_ref, upgrade_ref )
{
	// ex: 	"dpad_blah" is resource ref
	// 		all upgrade refs should be in form of "dpad_blah_#"
	
	assert( isdefined( resource_ref ) && isdefined( upgrade_ref ) );
	
	if ( resource_ref == upgrade_ref )
		return false;
	
	if ( !issubstr( upgrade_ref, resource_ref ) )
		return false;
	
	resource_toks 	= StrTok( resource_ref, "_" );
	upgrade_toks 	= StrTok( upgrade_ref, "_" );
	
	if ( upgrade_toks.size - resource_toks.size != 1 )
		return false;
	
	for ( i = 0; i < upgrade_toks.size - 1; i++ )
	{
		if ( upgrade_toks[ i ] != resource_toks[ i ] )
			return false;		
	}
	
	return true;
}

get_resource_ref_by_index( index )
{
	return tablelookup( level.alien_combat_resources_table, TABLE_INDEX, index, TABLE_REF );
}

get_name_by_ref( ref )
{
	return tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_NAME );
}

get_icon_by_ref( ref )
{
	return tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_ICON );
}

get_dpad_icon_by_ref( ref )
{
	return tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_DPAD_ICON );
}

get_desc_by_ref( ref )
{
	return tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_DESC );
}

get_point_cost_by_ref( ref )
{
	return int( tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_POINT_COST ) );
}

get_cost_by_ref( ref )
{
	return int( tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_COST ) );
}

get_unlock_by_ref( ref )
{
	return int( tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_UNLOCK ) );
}

get_is_upgrade_by_ref( ref )
{
	return int( tablelookup( level.alien_combat_resources_table, TABLE_REF, ref, TABLE_IS_UPGRADE ) );
}

//=== Common ===
// returns true if player is holding bomb/deployables
is_holding_deployable()
{
	if ( isdefined( self.deployable ) && self.deployable )
		return true;

	if ( isdefined( self.isCarrying ) && self.isCarrying )
		return true;
	
	current_weapon = self GetCurrentWeapon();
	if ( current_weapon == "alienclaymore_mp" || current_weapon == "bouncingbetty_mp" || current_weapon == "alientrophy_mp" )
		return true;
	
	return false;
}


//////////////////////////////////////////////
//
//	Team Ammo
/////////////////////////////////////////////

CanUse_dpad_team_ammo( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

CanPurchase_dpad_team_ammo( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

TryUse_dpad_team_ammo( def, rank )
{
	if ( rank == 0 )
		self.team_ammo_rank = 0;
	if ( rank == 1 )
		self.team_ammo_rank = 1;
	if ( rank == 2 )
		self.team_ammo_rank = 2;
	if ( rank == 3 )
		self.team_ammo_rank = 3;
	if ( rank == 4 )
		self.team_ammo_rank = 4;
		
	self GiveWeapon( "deployable_vest_marker_mp" );
	self SwitchToWeapon( "deployable_vest_marker_mp" );
	self.deployable = true;
}

deployable_ammo_placed_listener()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	// disable weapon switching
//	self DisableWeaponSwitch();
	self waittill( "new_deployable_box", ammo );
//	self EnableWeaponSwitch();
	
	ammo SetThreatBiasGroup( "deployable_ammo" );
	ammo.threatbias = -10000;
}

Use_dpad_team_ammo( def, rank )
{
	self thread deployable_ammo_placed_listener();
	
	result = self maps\mp\killstreaks\_deployablebox_ammo::tryUseDeployableAmmo( rank );
	self maps\mp\alien\_gamescore::update_personal_bonus( "team_support_deploy" );
	self.deployable = false;
}

CancelUse_dpad_team_ammo( def )
{
	self takeweapon( "deployable_vest_marker_mp" );
	self.deployable = false;
}

//////////////////////////////////////////////
//
//	Team Boost
/////////////////////////////////////////////

CanUse_dpad_team_boost( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

CanPurchase_dpad_team_boost( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

TryUse_dpad_team_boost( def, rank )
{
	if ( rank == 0 )
		self.team_boost_rank = 0;
	if ( rank == 1 )
		self.team_boost_rank = 1;
	if ( rank == 2 )
		self.team_boost_rank = 2;
	if ( rank == 3 )
		self.team_boost_rank = 3;
	if ( rank == 4 )
		self.team_boost_rank = 4;
	
	self GiveWeapon( "deployable_vest_marker_mp" );
	self SwitchToWeapon( "deployable_vest_marker_mp" );
	self.deployable = true;
}

deployable_boost_placed_listener()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	self waittill( "new_deployable_box", boost );
	
	boost SetThreatBiasGroup( "deployable_ammo" );
	boost.threatbias = -10000;
}

Use_dpad_team_boost( def, rank )
{
	self thread deployable_boost_placed_listener();
	
	result = self maps\mp\killstreaks\_deployablebox_juicebox::tryUseDeployableJuiced();
	self maps\mp\alien\_gamescore::update_personal_bonus( "team_support_deploy" );
	self.deployable = false;
}

CancelUse_dpad_team_boost( def )
{
	self takeweapon( "deployable_vest_marker_mp" );
	self.deployable = false;
}


//////////////////////////////////////////////
//
//	Team Armor
/////////////////////////////////////////////

CanUse_dpad_team_armor( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_team_armor( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
TryUse_dpad_team_armor( def, rank )
{
	if ( rank == 0 )
		self.team_armor_rank = 0;
	if ( rank == 1 )
		self.team_armor_rank = 1;
	if ( rank == 2 )
		self.team_armor_rank = 2;
	if ( rank == 3 )
		self.team_armor_rank = 3;
	if ( rank == 4 )
		self.team_armor_rank = 4;
		
	self GiveWeapon( "deployable_vest_marker_mp" );
	self SwitchToWeapon( "deployable_vest_marker_mp" );
	self.deployable = true;
}

deployable_armor_placed_listener()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	// disable weapon switching
//	self DisableWeaponSwitch();
	self waittill( "new_deployable_box", health_pack );
//	self EnableWeaponSwitch();
	
	health_pack SetThreatBiasGroup( "deployable_ammo" );
	health_pack.threatbias = -10000;
}
Use_dpad_team_armor( def, rank )
{
	self thread deployable_armor_placed_listener();

	result = self maps\mp\killstreaks\_deployablebox_vest::tryUseDeployableVest();
	self maps\mp\alien\_gamescore::update_personal_bonus( "team_support_deploy" );
	self.deployable = false;
}
CancelUse_dpad_team_armor( def )
{
	self takeweapon( "deployable_vest_marker_mp" );
	self.deployable = false;
}

//////////////////////////////////////////////
//
//	Team Explosives
/////////////////////////////////////////////

CanUse_dpad_team_explosives( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

CanPurchase_dpad_team_explosives( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

TryUse_dpad_team_explosives( def, rank )
{
	self GiveWeapon( "deployable_vest_marker_mp" );
	self SwitchToWeapon( "deployable_vest_marker_mp" );
	self.deployable = true;
}

deployable_explosives_placed_listener()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	// disable weapon switching
//	self DisableWeaponSwitch();
	self waittill( "new_deployable_box", grenades );
//	self EnableWeaponSwitch();
	
	grenades SetThreatBiasGroup( "deployable_ammo" );
	grenades.threatbias = -10000;
}

Use_dpad_team_explosives( def, rank )
{
	self thread deployable_explosives_placed_listener();

	result = self maps\mp\killstreaks\_deployablebox_grenades::tryUseDeployableAmmo();
	self maps\mp\alien\_gamescore::update_personal_bonus( "team_support_deploy" );
	self.deployable = false;
}

CancelUse_dpad_team_explosives( def )
{
	self takeweapon( "deployable_vest_marker_mp" );
	self.deployable = false;
}

//////////////////////////////////////////////
//
//	Claymore
/////////////////////////////////////////////

CanUse_dpad_claymore( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_claymore( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
TryUse_dpad_claymore( def, rank )
{
	self thread TryUse_dpad_claymore_Internal( );
}
TryUse_dpad_claymore_Internal() //needs to be threaded so it can do the "use" after player_action_slot progresses.
{
	waittillframeend;
//	self SetOffhandPrimaryClass( "other");
	self GiveWeapon( "alienclaymore_mp" );
	self SwitchToWeapon( "alienclaymore_mp" );
}

Use_dpad_claymore( def, rank )
{
	
}
CancelUse_dpad_claymore( def )
{
	self takeweapon( "alienclaymore_mp" );
	self.deployable = false;
}

//////////////////////////////////////////////
//
//	Bouncing Betties
/////////////////////////////////////////////

CanUse_dpad_betties( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_betties( def, rank )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
TryUse_dpad_betties( def, rank )
{
	self thread TryUse_dpad_betties_Internal( );
}
TryUse_dpad_betties_Internal() //needs to be threaded so it can do the "use" after player_action_slot progresses.
{
	waittillframeend;
	self SetOffhandPrimaryClass( "other");
	self GiveWeapon( "bouncingbetty_mp" );
	self SwitchToWeapon( "bouncingbetty_mp" );
}

Use_dpad_betties( def, rank )
{
	
}
CancelUse_dpad_betties( def )
{
	self takeweapon( "bouncingbetty_mp" );
	self.deployable = false;
}


//////////////////////////////////////////////
//
//	Trophy
/////////////////////////////////////////////

CanUse_dpad_trophy( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_trophy( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
TryUse_dpad_trophy( def, rank )
{
	self thread TryUse_dpad_trophy_Internal( );
}
TryUse_dpad_trophy_Internal() //needs to be threaded so it can do the "use" after player_action_slot progresses.
{
	waittillframeend;
	self SetOffhandPrimaryClass ( "other");
	self _giveWeapon( "alientrophy_mp" );
	self SwitchToWeapon( "alientrophy_mp" );

	self notify( "action_use" );
}

Use_dpad_trophy( def, rank )
{
	
}
CancelUse_dpad_trophy( def )
{
	return true;
}



//////////////////////////////////////////////
//
//	Riotshield
/////////////////////////////////////////////

CanUse_dpad_riotshield( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}
	
	return true;
}
CanPurchase_dpad_riotshield( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
TryUse_dpad_riotshield( def, rank )
{
	self thread TryUse_dpad_riotshield_Internal( );
}

TryUse_dpad_riotshield_Internal() //needs to be threaded so it can do the "use" after player_action_slot progresses.
{
	waittillframeend;
	self store_weapons_status();
	self _giveWeapon( "iw5_alienriotshield_mp" );
	self SwitchToWeapon( "iw5_alienriotshield_mp" );

	self notify( "action_use" );
}

Use_dpad_riotshield( def, rank )
{
	
}
CancelUse_dpad_riotshield( def )
{
	return true;
}



//////////////////////////////////////////////
//
//	Sentry
/////////////////////////////////////////////

CanUse_dpad_sentry( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_sentry( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

TryUse_dpad_sentry( def, rank )
{
	self.last_sentry = "sentry_minigun";
	sentryGun = maps\mp\killstreaks\_autosentry::createSentryForPlayer( "sentry_minigun", self );
	sentryGun SetConvergenceTime( 0.9, "pitch" );
    sentryGun SetConvergenceTime( 0.9, "yaw" );
/*	
    if ( rank == 0 )
		sentrygun.sentrySettings[ "sentry_minigun" ].timeOut = 5;
	if ( rank == 1 )
		sentrygun.timeout = 10;
	if ( rank == 2 )
		sentrygun.timeout = 20;
	if ( rank == 3 )
		sentrygun.timeout = 40;
	if ( rank == 4 )
		sentrygun.timeout = 60;
*/		
	self.carriedSentry = sentryGun;
	
	sentryGun maps\mp\killstreaks\_autosentry::sentry_setCarried( self );
	self DisableWeapons();

}
sentry_placed_listener()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	// disable weapon switching
	self DisableWeaponSwitch();
	self waittill( "new_sentry", newSentry );
	self EnableWeaponSwitch();
	
	newSentry.threatbias = -1000;
	newSentry.maxHealth = 150;
}

Use_dpad_sentry( def, rank )
{
	self thread sentry_placed_listener();
	self.carriedSentry maps\mp\killstreaks\_autosentry::sentry_setPlaced();
	self EnableWeapons();

	self.carriedSentry = undefined;
	self.isCarrying = false;
	if ( IsDefined( self.last_weapon ) )
		self SwitchToWeapon( self.last_weapon );
}
CancelUse_dpad_sentry( def )
{
	if ( IsDefined( self.carriedSentry ) )
		self.carriedSentry maps\mp\killstreaks\_autosentry::sentry_setCancelled();
	self EnableWeapons();
	if ( IsDefined( self.last_weapon ) )
		self SwitchToWeapon( self.last_weapon );
}

//////////////////////////////////////////////
//
//	IMS
/////////////////////////////////////////////

CanUse_dpad_ims( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_ims( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

TryUse_dpad_ims( def, rank )
{
	self.ims = "ims";
	ims = maps\mp\killstreaks\_ims::createIMSForPlayer( "ims", self );
	self.carriedIMS = ims;
	ims thread maps\mp\killstreaks\_ims::ims_setCarried( self );
	self DisableWeapons();

}
ims_placed_listener()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	// disable weapon switching
	self DisableWeaponSwitch();
	self waittill( "place_ims" );
	
}

Use_dpad_ims( def, rank )
{
	self thread ims_placed_listener();
	self.carriedIms maps\mp\killstreaks\_ims::ims_setPlaced();
	self EnableWeapons();

	self.carriedIms = undefined;
	self.isCarrying = false;
	if ( IsDefined( self.last_weapon ) )
		self SwitchToWeapon( self.last_weapon );
	self EnableWeaponSwitch();
}
CancelUse_dpad_ims( def )
{
	if ( IsDefined( self.carriedIms ) )
		self.carriedIms maps\mp\killstreaks\_ims::ims_setCancelled();
	self EnableWeapons();
	if ( IsDefined( self.last_weapon ) )
		self SwitchToWeapon( self.last_weapon );
}


//////////////////////////////////////////////
//
//	Backup UAV Drone
/////////////////////////////////////////////

CanUse_dpad_backup_uav( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_backup_uav( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

TryUse_dpad_backup_uav( def, rank )
{
	backup_uav = "alienbackupuav_mp";
	self store_weapons_status();
	self _giveWeapon( backup_uav );
	self SwitchToWeapon( backup_uav );
}

Use_dpad_backup_uav( def, rank )
{
	self maps\mp\killstreaks\_ball_drone::useBallDrone( "ball_drone_backup" );
	wait 0.1;
	self restore_weapons_status();
}

CancelUse_dpad_backup_uav( def )
{
	return true;
}


//////////////////////////////////////////////
//
//	Airstrike
/////////////////////////////////////////////

CanUse_dpad_airstrike( def )
{
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}
CanPurchase_dpad_airstrike( def )
{
	if ( self is_holding_deployable() )
	{
		return false;
	}

	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}

	return true;
}

TryUse_dpad_airstrike( def, rank )
{
	self thread TryUse_dpad_airstrike_Internal( );
}

TryUse_dpad_airstrike_Internal()
{
	waittillframeend;
	//maps\mp\killstreaks\_airstrike::doAirstrike( 0, self.origin, 0, self, "allies", "airstrike" );
	self notify( "action_use" );
	doMortar();
	
}

Use_dpad_airstrike( def, rank )
{

}
CancelUse_dpad_airstrike( def )
{
	return true;
}

//////////////////////////////////////////////
//
//	Airstrike Mortar


doMortar()
{
	offset = 1;
	for ( i=0; i<5; i++ )
	{
		mortarTarget = self.origin + ( RandomIntRange(100, 600)*offset, RandomIntRange(100, 600)*offset, 0 );
		
		traceData = BulletTrace( mortarTarget+(0,0,500), mortarTarget-(0,0,500), false );
		if ( isDefined( traceData["position"] ) )
		{			
			PlayFx( level.mortar_fx["tracer"], mortarTarget );
			thread playSoundinSpace( "fast_artillery_round", mortarTarget );
			
			wait( RandomFloatRange( 0.5, 1.5 ) );
			
			PlayFx( level.mortar_fx["explosion"], mortarTarget );
			RadiusDamage( self.origin, level.mortarDamageRadius, level.mortarDamageMax, level.mortarDamageMin, self, "MOD_EXPLOSIVE" );
			PlayRumbleOnPosition( "grenade_rumble", mortarTarget );
			Earthquake( 1.0, 0.6, mortarTarget, 2000 );	
			thread playSoundinSpace( "exp_suitcase_bomb_main", mortarTarget );
			physicsExplosionSphere( mortarTarget + (0,0,30), 250, 125, 2 );
			
			offset *= -1;			
		}		
	}
}



