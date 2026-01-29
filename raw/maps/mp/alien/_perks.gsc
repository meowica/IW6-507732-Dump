#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\_utility;
#include maps\mp\alien\_perkfunctions;

init_perks()
{
	init_perks_callback();
	
	init_perks_from_table();
}

WAVE_TABLE					= "mp/alien/perks_tree.csv";
init_perks_from_table()
{
	// level.alien_perks_table can be used to override default table, should be set before _alien::main()
	if ( !isdefined( level.alien_perks_table ) )
		level.alien_perks_table = WAVE_TABLE;
	
	level.alien_perks = [];
	
	update_perks_from_table( 0, "perk_0" );
	update_perks_from_table( 100, "perk_1" );
}

init_perks_callback()
{
	level.alien_perk_callbacks = [];

	level.alien_perk_callbacks["perk_health"] = spawnstruct();
	level.alien_perk_callbacks["perk_health"].Set		   = ::set_perk_health_level_0;
	level.alien_perk_callbacks["perk_health"].unSet 	   = ::unset_perk_health_level_0;
	
	level.alien_perk_callbacks["perk_health_1"] = spawnstruct();
	level.alien_perk_callbacks["perk_health_1"].Set		   = ::set_perk_health_level_1;
	level.alien_perk_callbacks["perk_health_1"].unSet 	   = ::unset_perk_health_level_1;
	
	level.alien_perk_callbacks["perk_health_2"] = spawnstruct();
	level.alien_perk_callbacks["perk_health_2"].Set		   = ::set_perk_health_level_2;
	level.alien_perk_callbacks["perk_health_2"].unSet 	   = ::unset_perk_health_level_2;
	
	level.alien_perk_callbacks["perk_health_3"] = spawnstruct();
	level.alien_perk_callbacks["perk_health_3"].Set		   = ::set_perk_health_level_3;
	level.alien_perk_callbacks["perk_health_3"].unSet 	   = ::unset_perk_health_level_3;
	
	level.alien_perk_callbacks["perk_health_4"] = spawnstruct();
	level.alien_perk_callbacks["perk_health_4"].Set		   = ::set_perk_health_level_4;
	level.alien_perk_callbacks["perk_health_4"].unSet 	   = ::unset_perk_health_level_4;
	
	level.alien_perk_callbacks["perk_pistol"] = spawnstruct();
	level.alien_perk_callbacks["perk_pistol"].Set		   = ::set_perk_default;
	level.alien_perk_callbacks["perk_pistol"].unSet		   = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_pistol_1"] = spawnstruct();
	level.alien_perk_callbacks["perk_pistol_1"].Set		   = ::set_perk_default;
	level.alien_perk_callbacks["perk_pistol_1"].unSet      = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_pistol_2"] = spawnstruct();
	level.alien_perk_callbacks["perk_pistol_2"].Set		   = ::set_perk_default;
	level.alien_perk_callbacks["perk_pistol_2"].unSet      = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_pistol_3"] = spawnstruct();
	level.alien_perk_callbacks["perk_pistol_3"].Set		   = ::set_perk_default;
	level.alien_perk_callbacks["perk_pistol_3"].unSet      = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_pistol_4"] = spawnstruct();
	level.alien_perk_callbacks["perk_pistol_4"].Set		   = ::set_perk_default;
	level.alien_perk_callbacks["perk_pistol_4"].unSet      = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_money"] = spawnstruct();
	level.alien_perk_callbacks["perk_money"].Set		   = ::set_perk_money_level_0;
	level.alien_perk_callbacks["perk_money"].unSet	       = ::unset_perk_money_level_0;
	
	level.alien_perk_callbacks["perk_money_1"] = spawnstruct();
	level.alien_perk_callbacks["perk_money_1"].Set		   = ::set_perk_money_level_1;
	level.alien_perk_callbacks["perk_money_1"].unSet	   = ::unset_perk_money_level_1;
	
	level.alien_perk_callbacks["perk_money_2"] = spawnstruct();
	level.alien_perk_callbacks["perk_money_2"].Set		   = ::set_perk_money_level_2;
	level.alien_perk_callbacks["perk_money_2"].unSet	   = ::unset_perk_money_level_2;
	
	level.alien_perk_callbacks["perk_money_3"] = spawnstruct();
	level.alien_perk_callbacks["perk_money_3"].Set		   = ::set_perk_money_level_3;
	level.alien_perk_callbacks["perk_money_3"].unSet	   = ::unset_perk_money_level_3;
	
	level.alien_perk_callbacks["perk_money_4"] = spawnstruct();
	level.alien_perk_callbacks["perk_money_4"].Set		   = ::set_perk_money_level_4;
	level.alien_perk_callbacks["perk_money_4"].unSet	   = ::unset_perk_money_level_4;
	
	level.alien_perk_callbacks["perk_quick_hands"] = spawnstruct();
	level.alien_perk_callbacks["perk_quick_hands"].Set	   = ::set_perk_quick_hands_level_0;
	level.alien_perk_callbacks["perk_quick_hands"].unSet   = ::unset_perk_quick_hands_level_0;
	
	level.alien_perk_callbacks["perk_quick_hands_1"] = spawnstruct();
	level.alien_perk_callbacks["perk_quick_hands_1"].Set   = ::set_perk_quick_hands_level_1;
	level.alien_perk_callbacks["perk_quick_hands_1"].unSet = ::unset_perk_quick_hands_level_1;
	
	level.alien_perk_callbacks["perk_quick_hands_2"] = spawnstruct();
	level.alien_perk_callbacks["perk_quick_hands_2"].Set   = ::set_perk_quick_hands_level_2;
	level.alien_perk_callbacks["perk_quick_hands_2"].unSet = ::unset_perk_quick_hands_level_2;
	
	level.alien_perk_callbacks["perk_quick_hands_3"] = spawnstruct();
	level.alien_perk_callbacks["perk_quick_hands_3"].Set   = ::set_perk_quick_hands_level_3;
	level.alien_perk_callbacks["perk_quick_hands_3"].unSet = ::unset_perk_quick_hands_level_3;
	
	level.alien_perk_callbacks["perk_quick_hands_4"] = spawnstruct();
	level.alien_perk_callbacks["perk_quick_hands_4"].Set   = ::set_perk_quick_hands_level_4;
	level.alien_perk_callbacks["perk_quick_hands_4"].unSet = ::unset_perk_quick_hands_level_4;
	
	level.alien_perk_callbacks["perk_fast_legs"] = spawnstruct();
	level.alien_perk_callbacks["perk_fast_legs"].Set	   = ::set_perk_fast_legs_level_0;
	level.alien_perk_callbacks["perk_fast_legs"].unSet	   = ::unset_perk_fast_legs_level_0;
	
	level.alien_perk_callbacks["perk_fast_legs_1"] = spawnstruct();
	level.alien_perk_callbacks["perk_fast_legs_1"].Set	   = ::set_perk_fast_legs_level_1;
	level.alien_perk_callbacks["perk_fast_legs_1"].unSet   = ::unset_perk_fast_legs_level_1;
	
	level.alien_perk_callbacks["perk_fast_legs_2"] = spawnstruct();
	level.alien_perk_callbacks["perk_fast_legs_2"].Set	   = ::set_perk_fast_legs_level_2;
	level.alien_perk_callbacks["perk_fast_legs_2"].unSet   = ::unset_perk_fast_legs_level_2;
	
	level.alien_perk_callbacks["perk_fast_legs_3"] = spawnstruct();
	level.alien_perk_callbacks["perk_fast_legs_3"].Set	   = ::set_perk_fast_legs_level_3;
	level.alien_perk_callbacks["perk_fast_legs_3"].unSet   = ::unset_perk_fast_legs_level_3;
	
	level.alien_perk_callbacks["perk_fast_legs_4"] = spawnstruct();
	level.alien_perk_callbacks["perk_fast_legs_4"].Set	   = ::set_perk_fast_legs_level_4;
	level.alien_perk_callbacks["perk_fast_legs_4"].unSet   = ::unset_perk_fast_legs_level_4;
	
	level.alien_perk_callbacks["perk_team_player"] = spawnstruct();
	level.alien_perk_callbacks["perk_team_player"].Set	   = ::set_perk_default;
	level.alien_perk_callbacks["perk_team_player"].unSet   = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_team_player_1"] = spawnstruct();
	level.alien_perk_callbacks["perk_team_player_1"].Set   = ::set_perk_default;
	level.alien_perk_callbacks["perk_team_player_1"].unSet = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_team_player_2"] = spawnstruct();
	level.alien_perk_callbacks["perk_team_player_2"].Set   = ::set_perk_default;
	level.alien_perk_callbacks["perk_team_player_2"].unSet = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_team_player_3"] = spawnstruct();
	level.alien_perk_callbacks["perk_team_player_3"].Set   = ::set_perk_default;
	level.alien_perk_callbacks["perk_team_player_3"].unSet = ::unset_perk_default;
	
	level.alien_perk_callbacks["perk_team_player_4"] = spawnstruct();
	level.alien_perk_callbacks["perk_team_player_4"].Set   = ::set_perk_default;
	level.alien_perk_callbacks["perk_team_player_4"].unSet = ::unset_perk_default;
}

//////////////////////////////////////////////
//           Default Perk Use Func
//////////////////////////////////////////////
set_perk_default() 
{ 
	iprintln( "====================================================================================" );
	iprintlnBold( "Warning - using set_perk_default().  Implement the proper perk set function." );
	iprintln( "====================================================================================" );
}

unset_perk_default() 
{ 
	iprintln( "====================================================================================" );
	iprintlnBold( "Warning - using unset_perk_default().  Implement the proper perk unset function." );
	iprintln( "====================================================================================" );	
}

// ================================================================
//						Perks Table
// ================================================================
TABLE_INDEX					= 0;	// [int] 	Indexing
TABLE_REF					= 1;	// [string] Reference
TABLE_UNLOCK				= 2;	// [int] 	Unlocked at rank number
TABLE_POINT_COST			= 3;	// [int] 	Combat point cost to enable this perk(upgrades)
TABLE_NAME					= 4;	// [string] Name localized
TABLE_DESC					= 5;	// [string]	Description localized
TABLE_ICON					= 6;	// [string] Reference string of icon for perk
TABLE_IS_UPGRADE			= 7;	// [int]	1 if this is an upgrade, 0 if not

TABLE_PERK_MAX_INDEX		= 100;
// Populates data table entries into level array
update_perks_from_table( start_idx, perk_type )
{
	level.alien_perks[ perk_type ] = [];
	
	for ( i = start_idx; i <= start_idx + TABLE_PERK_MAX_INDEX; i++ )
	{
		// break on end of line
		perk_ref = get_perk_ref_by_index( i );
		if ( perk_ref == "" ) { break; }
		
		if ( !isdefined( level.alien_perks[ perk_ref ] ) )
		{
			perk 			= spawnstruct();
			perk.upgrades 	= [];
			perk.unlock 	= get_unlock_by_ref( perk_ref );
			perk.name		= get_name_by_ref( perk_ref );
			perk.icon		= get_icon_by_ref( perk_ref );
			perk.ref		= perk_ref;
			perk.type       = perk_type;
			perk.callbacks	= level.alien_perk_callbacks[ perk_ref ];
			
			level.alien_perks[ perk_type ][ perk_ref ] = perk;
		}
		
		// grab all upgrades for this perk
		for ( j = i; j <= start_idx + TABLE_PERK_MAX_INDEX; j++ )
		{
			upgrade_ref = get_perk_ref_by_index( j );
			if ( upgrade_ref == "" ) { break; }
			
			if ( upgrade_ref == perk_ref || is_perk_set( perk_ref, upgrade_ref ) )
			{
				upgrade 		= spawnstruct();
				upgrade.ref		= upgrade_ref;
				upgrade.desc	= get_desc_by_ref( upgrade_ref );
				upgrade.point_cost	= get_point_cost_by_ref( upgrade_ref );

				level.alien_perks[ perk_type ][ perk_ref ].upgrades[ j - i ] = upgrade;
			}
			else
			{
				break;
			}
		}
		
		// point index to next perk set
		i = j - 1;
	}
}

// returns true if upgrade_ref is/or an upgrade of perk_ref
is_perk_set( perk_ref, upgrade_ref )
{
	// ex: 	"perk_blah" is perk ref
	// 		all upgrade refs should be in form of "perk_blah_#"
	
	assert( isdefined( perk_ref ) && isdefined( upgrade_ref ) );
	
	if ( perk_ref == upgrade_ref )
		return false;
	
	if ( !issubstr( upgrade_ref, perk_ref ) )
		return false;
	
	perk_toks 		= StrTok( perk_ref, "_" );
	upgrade_toks 	= StrTok( upgrade_ref, "_" );
	
	if ( upgrade_toks.size - perk_toks.size != 1 )
		return false;
	
	for ( i = 0; i < upgrade_toks.size - 1; i++ )
	{
		if ( upgrade_toks[ i ] != perk_toks[ i ] )
			return false;		
	}
	
	return true;
}

get_perk_ref_by_index( index )
{
	return tablelookup( level.alien_perks_table, TABLE_INDEX, index, TABLE_REF );
}

get_name_by_ref( ref )
{
	return tablelookup( level.alien_perks_table, TABLE_REF, ref, TABLE_NAME );
}

get_icon_by_ref( ref )
{
	return tablelookup( level.alien_perks_table, TABLE_REF, ref, TABLE_ICON );
}

get_desc_by_ref( ref )
{
	return tablelookup( level.alien_perks_table, TABLE_REF, ref, TABLE_DESC );
}

get_point_cost_by_ref( ref )
{
	return int( tablelookup( level.alien_perks_table, TABLE_REF, ref, TABLE_POINT_COST ) );
}

get_unlock_by_ref( ref )
{
	return int( tablelookup( level.alien_perks_table, TABLE_REF, ref, TABLE_UNLOCK ) );
}

get_is_upgrade_by_ref( ref )
{
	return int( tablelookup( level.alien_perks_table, TABLE_REF, ref, TABLE_IS_UPGRADE ) );
}