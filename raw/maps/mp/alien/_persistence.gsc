#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\_utility;
#include maps\mp\alien\_perk_utility;

//=======================================================
//		Player persistent data script
//=======================================================

CURRENCY_MAX = 6000;
POINTS_MAX = 5;
/*

> Player XP & Rank & Prestige
> Player Unlocks ( title cards, perks, dpad abilities )
> Player Loadout setup
> Player Options/Settings
> Player Combat Stats ( career stats and scoring )
> Player Leaderboard data
> Player Permanent Items

*/

// ====================== PERKS ======================

// get player selected perks
get_selected_perk_0() 	{ return self getcoopplayerdata( "alienPlayerLoadout", "perks", 0 ); }
get_selected_perk_1() 	{ return self getcoopplayerdata( "alienPlayerLoadout", "perks", 1 ); }

// get current perks, upgraded perks is tracked in alienSession perks[]
get_perk_0_level() 		{ return self getcoopplayerdata( "alienSession", "perk_0_level" ); }
get_perk_1_level() 		{ return self getcoopplayerdata( "alienSession", "perk_1_level" ); }

// set current perk upgrade
set_perk_0_level( upgrade_level ) { self setcoopplayerdata( "alienSession", "perk_0_level", upgrade_level ); }
set_perk_1_level( upgrade_level ) { self setcoopplayerdata( "alienSession", "perk_1_level", upgrade_level ); }

set_perk( perk_ref )   { self [[level.alien_perk_callbacks[perk_ref].Set]](); }
unset_perk( perk_ref ) { self [[level.alien_perk_callbacks[perk_ref].unSet]](); }

// initialize the current perk upgrade level, 0
init_perk_level()
{
	self set_perk_0_level( 0 );
	self set_perk_1_level( 0 );
}

give_initial_perks()
{
	self set_perk( self get_selected_perk_0() );
	self set_perk( self get_selected_perk_1() );
}

// ====================== COMBAT RESOURCES ======================

// get player selected dpad combat resources
get_selected_dpad_up() 		{ return self getcoopplayerdata( "alienPlayerLoadout", "munition" ); }
get_selected_dpad_down()	{ return self getcoopplayerdata( "alienPlayerLoadout", "support" ); }
get_selected_dpad_left()	{ return self getcoopplayerdata( "alienPlayerLoadout", "defense" ); }
get_selected_dpad_right()	{ return self getcoopplayerdata( "alienPlayerLoadout", "offense" ); }

// get current combat resources, upgraded resources is tracked in alienSession...
get_dpad_up_level() 	{ return self getcoopplayerdata( "alienSession", "munition_level" ); }
get_dpad_down_level()	{ return self getcoopplayerdata( "alienSession", "support_level" ); }
get_dpad_left_level()	{ return self getcoopplayerdata( "alienSession", "defense_level" ); }
get_dpad_right_level()	{ return self getcoopplayerdata( "alienSession", "offense_level" ); }

get_upgrade_level( type )					{ return self getcoopplayerdata( "alienSession", type + "_level" ); }
set_upgrade_level( type, upgrade_level )	{ self setcoopplayerdata( "alienSession", type + "_level", upgrade_level ); }

// set current combat resource upgrades
set_dpad_up_level( upgrade_level ) 		{ self setcoopplayerdata( "alienSession", "munition_level", upgrade_level ); }
set_dpad_down_level( upgrade_level )	{ self setcoopplayerdata( "alienSession", "support_level", upgrade_level ); }
set_dpad_left_level( upgrade_level )	{ self setcoopplayerdata( "alienSession", "defense_level", upgrade_level ); }
set_dpad_right_level( upgrade_level )	{ self setcoopplayerdata( "alienSession", "offense_level", upgrade_level ); }

// initialize the current combat resource upgrade level, 0
init_combat_resource_level()
{
	self set_dpad_up_level( 0 );
	self set_dpad_down_level( 0 );
	self set_dpad_left_level( 0 );
	self set_dpad_right_level( 0 );
}

// ====================== CURRENCY ======================

get_player_currency()			{ return self getcoopplayerdata( "alienSession", "currency" ); }
get_player_max_currency()		{ return self.maxCurrency; }
set_player_currency( amount )	{ self setcoopplayerdata( "alienSession", "currency", int( amount ) ); }
get_player_score()				{ return self getcoopplayerdata( "alienSession", "score" ); }
set_player_score( amount )		{ self setcoopplayerdata( "alienSession", "score", int( amount ) ); }
get_player_points()				{ return self getcoopplayerdata( "alienSession", "skill_points" ); }
set_player_points( amount )		{ self setcoopplayerdata( "alienSession", "skill_points", int( amount ) ); }

set_player_max_currency( amount )
{
	self SetClientOmnvar( "ui_alien_max_currency", amount );
	self.maxCurrency = amount;
}

give_player_currency( amount )
{
	assert( amount >= 0 );
	current_amount = self get_player_currency();
	new_amount = current_amount + amount;
	new_amount =  min( new_amount, self get_player_max_currency() );
	
	self notify( "loot_pickup" );

	self set_player_currency( new_amount );
}

take_player_currency( amount ) 
{
	assert( amount >= 0 );
	current_amount = self get_player_currency();
	new_amount = max( 0, current_amount - amount );

	self notify( "loot_removed" );
	
	self set_player_currency( new_amount );
}

player_has_enough_currency( amount ) 
{
	assert( amount >= 0 );
	currency = self get_player_currency();
	return (currency >= amount);
}

try_take_player_currency( amount )
{
	if ( self player_has_enough_currency( amount ) )
	{
		self take_player_currency( amount );
		return true;
	}
	else
	{
		return false;
	}
}

give_player_points( amount )
{
	assert( amount >= 0 );
	current_amount = self get_player_points();
	new_amount = current_amount + amount;
	new_amount = min( new_amount, POINTS_MAX );
	
	self set_player_points( new_amount );
}

take_player_points( amount )
{
	assert( amount >= 0 );
	current_amount = self get_player_points();
	new_amount = max( 0, current_amount - amount );

	self notify( "points_removed" );
	
	self set_player_points( new_amount );
}

player_has_enough_points( amount ) 
{
	assert( amount >= 0 );
	points = self get_player_points();
	return (points >= amount);
}

try_take_player_points( amount )
{
	if ( self player_has_enough_points( amount ) )
	{
		self take_player_points( amount );
		return true;
	}
	else
	{
		return false;
	}
}

// check against rank for unlock
is_unlocked( item_ref )
{
	item_type 			= undefined;
	item_type 			= strtok( item_ref, "_" )[ 0 ];  	// currently only "perk" or "dpad"
	
	item_unlock_rank 	= level.combat_resource[ item_ref ].unlock;
	player_rank 		= self get_player_rank();
	
	return player_rank >= item_unlock_rank;
	// return int( self getplayerdata( "unlock", item_ref ) );
}

player_persistence_init()
{
	// enable xp
	level.alien_xp = true;
	
	// inits with playerdata
	self init_combat_resource_level();
	self init_perk_level();
	
	self init_each_perk();
	self give_initial_perks();

	self set_player_currency( self perk_GetStartCurrency() );
	self set_player_max_currency( CURRENCY_MAX );
	
	self set_player_points( 0 );
	self set_player_score( 0 );
}

// ====================== CAREER ======================

// XP/Rank Table
RANK_TABLE					= "mp/alien/rankTable.csv";

TABLE_ID					= 0;	// [int] 	Rank ID
TABLE_REF					= 1;	// [string] Rank Reference
TABLE_XP_MIN				= 2;	// [int] 	Min XP
TABLE_XP_NEXT				= 3;	// [int] 	XP to Next
TABLE_XP_MAX				= 4;	// [int]	Max XP
TABLE_LEVEL					= 5;	// [int]	Rank number display
TABLE_RANK_SHORT			= 6;	// [string] Short rank localized
TABLE_RANK_FULL				= 7;	// [string]	Full rank localized
TABLE_RANK_INGAME			= 8;	// [string] In game rank localized
TABLE_ICON					= 8;	// [string] Rank icon

// Populates data table entries into level array
rank_init()
{
	// level.alien_perks_table can be used to override default table, should be set before _alien::main()
	if ( !isdefined( level.alien_ranks_table ) )
		level.alien_ranks_table = RANK_TABLE;
	
	level.alien_ranks = [];
	
	// max rank is defined in table
	level.alien_max_rank = int( tablelookup( level.alien_ranks_table, TABLE_ID, "maxrank", TABLE_REF ) );
	assertex( isdefined( level.alien_max_rank ) && level.alien_max_rank );
	
	for ( i = 0; i <= level.alien_max_rank; i++ )
	{
		// break on end of line
		rank_ref = get_ref_by_id( i );
		if ( rank_ref == "" ) { break; }
		
		if ( !isdefined( level.alien_ranks[ i ] ) )
		{
			rank 					= spawnstruct();
			rank.id					= i;
			rank.ref				= rank_ref;
			rank.lvl				= get_level_by_id( i );
			rank.icon				= get_icon_by_id( i );
			
			rank.xp					= [];
			rank.xp[ "min" ] 		= get_minxp_by_id( i );
			rank.xp[ "next" ]		= get_nextxp_by_id( i );
			rank.xp[ "max" ]		= get_maxxp_by_id( i );
			
			rank.name				= [];
			rank.name[ "short" ]	= get_shortrank_by_id( i );
			rank.name[ "full" ] 	= get_fullrank_by_id( i );
			rank.name[ "ingame" ]	= get_ingamerank_by_id( i );
			
			level.alien_ranks[ i ] = rank;
		}
	}
}

get_ref_by_id( id )
{
	return tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_REF );
}

get_minxp_by_id( id )
{
	return int( tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_XP_MIN ) );
}

get_maxxp_by_id( id )
{
	return int( tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_XP_MAX ) );
}

get_nextxp_by_id( id )
{
	return int( tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_XP_NEXT ) );
}

get_level_by_id( id )
{
	return int( tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_LEVEL ) );
}

get_shortrank_by_id( id )
{
	return tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_RANK_SHORT );
}

get_fullrank_by_id( id )
{
	return tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_RANK_FULL );
}

get_ingamerank_by_id( id )
{
	return tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_RANK_INGAME );
}

get_icon_by_id( id )
{
	return tablelookup( level.alien_ranks_table, TABLE_ID, id, TABLE_ICON );
}


// get player xp stats
get_player_rank()			{ return self getcoopplayerdata( "alienPlayerStats", "rank" ); }
get_player_xp()				{ return self getcoopplayerdata( "alienPlayerStats", "experience" ); }
get_player_prestige()		{ return self getcoopplayerdata( "alienPlayerStats", "prestige" ); }

// set player xp stats
set_player_rank( rank )			
{
/#
	// validattion
	player_xp 	= self get_player_xp();
	player_rank = self get_rank_by_xp( player_xp );
	
	assertex( rank == player_rank, "Trying to set rank different than XP requirement" );
#/
	self setcoopplayerdata( "alienPlayerStats", "rank", rank ); 
}

set_player_xp( xp )				
{ 
/#
	player_xp = self get_player_xp();
	assertex( player_xp <= xp, "Trying to set XP lower than before" );
#/
	self setcoopplayerdata( "alienPlayerStats", "experience", xp ); 
}

set_player_prestige( prestige )	{ self setcoopplayerdata( "alienPlayerStats", "prestige", prestige ); }

// validates if rank meets xp requirements
get_rank_by_xp( xp )
{
	rank = 0;
	
	for ( i = 0; i < level.alien_ranks.size; i++ )
	{
		if ( xp >= level.alien_ranks[ i ].xp[ "min" ] )
		{
			if ( xp < level.alien_ranks[ i ].xp[ "max" ] )
			{
				rank = level.alien_ranks[ i ].id;
				break;
			}
		}
	}
	
	return rank;
}

give_player_xp( xp )
{
	old_rank = self get_player_rank();			// get old rank for rank check later
	old_xp = self get_player_xp();				// get old xp for addition of xp
	new_xp = old_xp + xp;

/#	
	if ( getDvar( "alien_debug_xp" ) == "1" )
		IPrintLn( "+" + xp + "xp [" + new_xp + "]" );
#/
		
	// set new xp
	self set_player_xp( new_xp );				// set new xp
	
	// did player level up?
	new_rank = self get_rank_by_xp( new_xp );	// get new rank
	
	if ( new_rank > old_rank )					// is new rank higher than old rank
	{
		self set_player_rank( new_rank );		// set new rank
		self notify( "ranked_up", new_rank ); 	// notify for any splash or blah

/#		if ( getDvar( "alien_debug_xp" ) == "1" )
			IPrintLnbold( "Ranked up: Lv." + new_rank + " [XP: " + new_xp + "]" );
#/
		
	}
}
 