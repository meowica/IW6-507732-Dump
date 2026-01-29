#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;


locker_armory_func( menu_name )
{
/*	
	// Attachments
	"none",
	"gl",
	"reflex",
	"silencer",
	"acog",
	"grip",
	"akimbo",
	"thermal",
	"shotgun",
	"heartbeat",
	"fmj",
	"xmags",
	"rof",
	"eotech",
	"tactical",
	"vzscope",
	"hamrhybrid",
	"hybrid",
	"zoomscope",
	"silencerunderbarrel",
	"silencerunderbarrel02",
	"silencerunderbarrel03",
*/
		
	self thread armory_user_thread( menu_name );
}

armory_init()
{	
	armory_table 			= "mp/alien/mode_string_tables/alien_armory.csv";
	table_col_index			= 0;
	table_col_ref 			= 1;
	table_col_type			= 2;
	table_col_subtype		= 3;
	table_col_cost 			= 4;
//	table_col_name 			= 5;
//	table_col_desc 			= 6;
//	table_col_icon 			= 7;
	table_col_attach1		= 8;
	table_col_attach2 		= 9;
	table_col_camo 			= 10;
	table_col_reticle		= 11;
	table_col_yelloweggcost	= 12;
	table_col_greeneggcost	= 13;
	table_col_redeggcost	= 14;
	table_col_blueeggcost	= 15;
	table_col_purpleeggcost	= 16;

	// Increase this if the table gets too large
	max_idx 			= 100;
	
	//assert( !IsDefined( level.armory_items ) );
	level.armory_items = [];
	
	for ( i = 0; i < max_idx; i++ )
	{		
		ref = TableLookup( armory_table, table_col_index, i, table_col_ref );
		if ( !IsDefined( ref ) || ref == "" )
			continue;
		
		row_num = TableLookupRowNum( armory_table, table_col_index, i );
		assert( row_num >= 0 );
		newItem 				= SpawnStruct();
		newItem.idx 			= i;
		newItem.ref 			= ref;
		newItem.type 			= TableLookupByRow( armory_table, row_num, table_col_type );
		newItem.subType			= TableLookupByRow( armory_table, row_num, table_col_subtype );
		cost_data 				= [];
		cost_data["blood"]		= Int( TableLookupByRow( armory_table, row_num, table_col_cost ) );
		cost_data["yellow_egg"]	= Int( TableLookupByRow( armory_table, row_num, table_col_yelloweggcost ) );
		cost_data["green_egg"]	= Int( TableLookupByRow( armory_table, row_num, table_col_greeneggcost ) );
		cost_data["red_egg"]	= Int( TableLookupByRow( armory_table, row_num, table_col_redeggcost ) );
		cost_data["blue_egg"]	= Int( TableLookupByRow( armory_table, row_num, table_col_blueeggcost ) );
		cost_data["purple_egg"]	= Int( TableLookupByRow( armory_table, row_num, table_col_purpleeggcost ) );
		newItem.cost			= cost_data;
		newItem.attach1 		= TableLookupByRow( armory_table, row_num, table_col_attach1 );
		newItem.attach2 		= TableLookupByRow( armory_table, row_num, table_col_attach2 );
		newItem.camo 			= TableLookupByRow( armory_table, row_num, table_col_camo );
		newItem.reticle 		= TableLookupByRow( armory_table, row_num, table_col_reticle );
		newItem.giveFunc 		= ::armory_give;
	
		if ( newItem.attach1 == "" )
			newItem.attach1 = "none";
		
		if ( newItem.attach2 == "" )
			newItem.attach2 = "none";
		
		if ( newItem.camo == "" )
		{
			newItem.camo = 0;
		}
		else
		{
			// Resolve the camo index
			newItem.camo = Int( TableLookup( "mp/camoTable.csv", 1, newItem.camo, 0 ) );
		}
		
		if ( newItem.reticle == "" )
		{
			newItem.reticle = 0;
		}
		else
		{
			// Resolve the reticle index
			newItem.reticle = Int( TableLookup( "mp/reticleTable.csv", 1, newItem.reticle, 0 ) );
		}
		
		level.armory_items[level.armory_items.size] = newItem;
	}
}


armory_get_by_index( index )
{
	foreach( item in level.armory_items )
	{
		if ( item.idx == index )
			return item;
	}
	
	return undefined;
}

armory_user_thread( menu_name )
{
	self endon( "death" );
	level endon( "game_ended" );
	
	// Handle last stand?
	
	self OpenPopupMenu( menu_name );
	self FreezeControls( true );
	 
	while( 1 )
	{
		self waittill( "menuresponse", menu, response );
		
		if ( response == "quit" )
		{
			self armory_close();
			break;
		}

		// Purchased something?
		if ( IsSubStr( response, "purchase" ) )
		{
			item_index 	= Int( StrTok( response, "_" )[1] );
			
			item = armory_get_by_index( item_index );
			assert( IsDefined( item ) );
			
			//if ( self.money >= item.cost )
			// TODO: get currency type from armory table the item trades in
			// ex: item.currency_type = "loot_blood_small";
			// cost colum can be "loot_blood_small 500" as stringtable entry
			// parses loot currency string and cost integer
			
			if (self can_purchase( item ))
			{
			    self maps\mp\alien\_collectibles::take_loot( "loot_blood_small", item.cost["blood"] );
			    self maps\mp\alien\_collectibles::take_loot( "item_yellow_egg", item.cost["yellow_egg"] );
			    self maps\mp\alien\_collectibles::take_loot( "item_green_egg", item.cost["green_egg"] );
			    self maps\mp\alien\_collectibles::take_loot( "item_red_egg", item.cost["red_egg"] );
			    self maps\mp\alien\_collectibles::take_loot( "item_blue_egg", item.cost["blue_egg"] );
			    self maps\mp\alien\_collectibles::take_loot( "item_purple_egg", item.cost["purple_egg"] );
				 				
				self updatePlayerLootDvar ("ui_player_money", "loot_blood_small" );
				self updatePlayerLootDvar ("ui_player_yellow_eggs", "item_yellow_egg");
				self updatePlayerLootDvar ("ui_player_green_eggs", "item_green_egg");
				self updatePlayerLootDvar ("ui_player_red_eggs", "item_red_egg");
				self updatePlayerLootDvar ("ui_player_blue_eggs", "item_blue_egg");
				self updatePlayerLootDvar ("ui_player_purple_eggs", "item_purple_egg");
				
				// Give the item
				self [[item.giveFunc]]( item );

				self armory_close();
				break;
			}
		}
	}
	
	level notify( "player_used_locker" );
}

can_purchase ( item )
{
	cost_blood 			= item.cost["blood"];
	cost_yellow_eggs 	= item.cost["yellow_egg"];
	cost_green_eggs 	= item.cost["green_egg"];
	cost_red_eggs 		= item.cost["red_egg"];
	cost_blue_eggs 		= item.cost["blue_egg"];
	cost_purple_eggs 	= item.cost["purple_egg"];
	
	blood_in_bag = self maps\mp\alien\_collectibles::get_loot_count( "loot_blood_small" );
	yellow_egg_in_bag = self maps\mp\alien\_collectibles::get_loot_count( "item_yellow_egg" );
	green_egg_in_bag = self maps\mp\alien\_collectibles::get_loot_count( "item_green_egg" );
	red_egg_in_bag = self maps\mp\alien\_collectibles::get_loot_count( "item_red_egg" );
	blue_egg_in_bag = self maps\mp\alien\_collectibles::get_loot_count( "item_blue_egg" );
	purple_egg_in_bag = self maps\mp\alien\_collectibles::get_loot_count( "item_purple_egg" );
	
	return ( (blood_in_bag >= cost_blood ) && ( yellow_egg_in_bag >= cost_yellow_eggs ) && ( green_egg_in_bag >= cost_green_eggs ) && (red_egg_in_bag >= cost_red_eggs ) && ( blue_egg_in_bag >= cost_blue_eggs ) && ( purple_egg_in_bag >= cost_purple_eggs ) );
}
	
armory_close()
{
	self ClosePopupMenu();
	self FreezeControls( false );
}


armory_give( item )
{
	switch( item.type )
	{
		case "weapon":
		{
			self armory_give_weapon( item );
			break;
		}
		case "perk":
		{
			self armory_give_perk( item );
			break;
		}
		case "killstreak":
		{
			self armory_give_killstreak( item );
			break;
		}
		case "offhand":
		{
			self armory_give_offhand( item );
			break;
		}
		case "ammo":
		{
			self maps\mp\alien\_collectibles::give_ammo( item );
			break;
		}
		case "health":
		{
			self maps\mp\alien\_collectibles::give_health( item );
			break;
		}
				
	}
}


armory_give_weapon( item )
{
	weap_name		= item.ref;
	weap_attach1 	= item.attach1;
	weap_attach2 	= item.attach2;
	weap_camo 		= item.camo;
	weap_reticle 	= item.reticle;
	
	newWeapon = maps\mp\gametypes\_class::buildWeaponName( weap_name, weap_attach1, weap_attach2, weap_camo, weap_reticle );
	
	if ( self HasWeapon( newWeapon ) )
	{
		// Just give ammo
		self GiveMaxAmmo( newWeapon );
		return;
	}
	
	cur_weapons = self GetWeaponsListPrimaries();
	if ( cur_weapons.size >= 2 )
	{
		drop_weapon = self GetCurrentPrimaryWeapon();
		assert( IsDefined( drop_weapon ) );
		self TakeWeapon( drop_weapon );
	}
	
	self _giveWeapon( newWeapon );
	
	weaponTokens = StrTok( newWeapon, "_" );	
	if ( weaponTokens[0] == "iw5" )
		weaponName = weaponTokens[0] + "_" + weaponTokens[1];
	else if ( weaponTokens[0] == "alt" )
		weaponName = weaponTokens[1] + "_" + weaponTokens[2];
	else
		weaponName = weaponTokens[0];
	
	self.pers["primaryWeapon"] = weaponName;	
	self.primaryWeapon = newWeapon;
	
	self GiveMaxAmmo( newWeapon );
	self SwitchToWeapon( newWeapon );
	
	self updatePlayerWeaponDvars();
}


armory_give_perk( item )
{
	perk_name = item.ref;
	if ( IsDefined( self.isBoosted ) )
	    return;
	
	if ( self _hasPerk( perk_name ) )
		return;
	
	if ( item.subType == "internal" )
	{
		self armory_give_perk_custom( item );
		return;
	}	

	self givePerk( perk_name, false );
	self updatePlayerPerkDvar();
}

armory_give_perk_custom( item )
{
	perk_name = item.ref;

	// Set the player as having this perk
	self.perks[ perk_name ] = true;
	self updatePlayerPerkDvar();

	switch( perk_name )
	{
		case "siege_ammo_regen":
			self thread player_ammo_regen( item );
			break;
		case "health_regen_booster":
			self thread player_health_regen_booster( 30 );
			break;
		case "fast_legs_booster":
			self thread player_fast_legs_booster( 60 );
			break;	
		case "fast_hands_booster":
			self thread player_fast_hands_booster( 60 );
			break;	
		case "mega_booster":
			self thread player_mega_booster( 60 );
			break;				
		default:
			AssertMsg( "Unhandled custom perk: " + perk_name );
	}
}

armory_give_killstreak( item )
{
	killstreak_name		= item.ref;
	
	switch( killstreak_name )
	{
		case "ims":
			self maps\mp\killstreaks\_killstreaks::giveKillstreak( "ims" );
			break;
		case "sentry":
			self maps\mp\killstreaks\_killstreaks::giveKillstreak( "sentry" );
			self thread maps\mp\alien\_collectibles::modify_sentry_setting();
			break;
	}

}

armory_give_offhand( item )
{
	offhand_name		= item.ref;
	switch( offhand_name )
	{
		case "frag_grenade_mp":
			self setOffhandPrimaryClass( "frag" );
			self giveWeapon ( offhand_name );
			break;
		default:
			self setOffhandPrimaryClass( "other" );
			self giveWeapon ( offhand_name );
			break;
	}
}
	
player_health_regen_booster( time )
{
	self endon( "death" );
	self endon( "faux_spawn" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self.isHealthBoosted = true;
	self.isBoosted = true;
	waitTime = time;
	endTime = ( waitTime * 1000 ) + GetTime();
	self SetClientDvar( "ui_juiced_end_milliseconds", endTime );
	wait( waitTime );
	
	self player_unset_health_regen_booster();
}

player_unset_health_regen_booster()
{
	self.isHealthBoosted = undefined;
	self.isBoosted = undefined;
	self SetClientDvar( "ui_juiced_end_milliseconds", 0 );
}

player_fast_legs_booster( time )
{
	self endon( "death" );
	self endon( "faux_spawn" );
	self endon( "disconnect" );
	level endon( "game_ended" );
//	self.isBoosted = true;
	
	self givePerk( "specialty_marathon", false );
	self.moveSpeedScaler = 1.1;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale();
		
//	waitTime = time;
//	endTime = ( waitTime * 1000 ) + GetTime();
//	self SetClientDvar( "ui_juiced_end_milliseconds", endTime );
//	wait( waitTime );

//	self player_unset_fast_legs_booster();
}

player_unset_fast_legs_booster()
{
	self _unsetPerk( "specialty_marathon" );
	self.moveSpeedScaler = 1;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale();
	
	self.isBoosted = undefined;
	self SetClientDvar( "ui_juiced_end_milliseconds", 0 );

	self notify( "unset_fast_legs" );
}

player_fast_hands_booster( time )
{
	self endon( "death" );
	self endon( "faux_spawn" );
	self endon( "disconnect" );
	level endon( "game_ended" );
//	self.isBoosted = true;
	
	// reloading == specialty_fastreload
	self givePerk( "specialty_fastreload", false );
	// ads'ing == specialty_quickdraw
	self givePerk( "specialty_quickdraw", false );
	// movement == specialty_stalker
	self givePerk( "specialty_stalker", false );
	// throwing grenades == specialty_fastoffhand
	self givePerk( "specialty_fastoffhand", false );
	// sprint recovery == specialty_fastsprintrecovery
	self givePerk( "specialty_fastsprintrecovery", false );
	// switching weapons == specialty_quickswap
	//self givePerk( "specialty_quickswap", false );

//	waitTime = time;
//	endTime = ( waitTime * 1000 ) + GetTime();
//	self SetClientDvar( "ui_juiced_end_milliseconds", endTime );
//	wait( waitTime );

//	self player_unset_fast_hands_booster();
}

player_unset_fast_hands_booster()
{
		
	// reloading == specialty_fastreload
	self _unsetPerk( "specialty_fastreload" );

	// ads'ing == specialty_quickdraw
	self _unsetPerk( "specialty_quickdraw" );

	// movement == specialty_stalker
	self _unsetPerk( "specialty_stalker" );

	// throwing grenades == specialty_fastoffhand
	self _unsetPerk( "specialty_fastoffhand" );

	// sprint recovery == specialty_fastsprintrecovery
	self _unsetPerk( "specialty_fastsprintrecovery" );

	// switching weapons == specialty_quickswap
	self _unsetPerk( "specialty_quickswap" );
	
	self.isBoosted = undefined;
	self SetClientDvar( "ui_juiced_end_milliseconds", 0 );
}

player_ammo_regen( item )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	// First ensure the player has at least a single clip of ammo for each weapon
	weapList = self GetWeaponsListPrimaries();
	foreach( weap in weapList )
	{
		clipSize = WeaponClipSize( weap );
		self SetWeaponAmmoClip( weap, clipSize );
	}
	
	regen_interval = 0.2; // 5 bullets per second
	
	while( 1 )
	{
		weapList = self GetWeaponsListPrimaries();
		foreach( weap in weapList )
		{
			ammoStock = self GetWeaponAmmoStock( weap );
			self SetWeaponAmmoStock( weap, ammoStock + 1 );
		}
		
		wait( regen_interval );
	}
}

player_ammo_refill( item ) 
{
	weaponList = self GetWeaponsListAll();
	
	if ( IsDefined( weaponList ) )
	{
		foreach ( weaponName in weaponList )
		{
			// allow bullet weapons to get extra clips
			if ( maps\mp\gametypes\_weapons::isBulletWeapon( weaponName ) )
			{
				self GiveMaxAmmo( weaponName, 2 );
			}
			// limit the ammo of launchers so they aren't abused
			else if ( WeaponClass( weaponName ) == "rocketlauncher" )
			{
				self GiveMaxAmmo( weaponName, 1 );
				// self GiveStartAmmo( weaponName );
			}
		}
	}
}


player_mega_booster( time )
{
	self endon( "death" );
	self endon( "faux_spawn" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self.isBoosted = true;
	self.isHealthBoosted = true;
	self givePerk( "specialty_marathon", false );
	self.moveSpeedScaler = 1.25;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale();
	
	// reloading == specialty_fastreload
	self givePerk( "specialty_fastreload", false );
	// ads'ing == specialty_quickdraw
	self givePerk( "specialty_quickdraw", false );
	// movement == specialty_stalker
	self givePerk( "specialty_stalker", false );
	// throwing grenades == specialty_fastoffhand
	self givePerk( "specialty_fastoffhand", false );
	// sprint recovery == specialty_fastsprintrecovery
	self givePerk( "specialty_fastsprintrecovery", false );
	// switching weapons == specialty_quickswap
	self givePerk( "specialty_quickswap", false );

	waitTime = time;
	endTime = ( waitTime * 1000 ) + GetTime();
	self SetClientDvar( "ui_juiced_end_milliseconds", endTime );
	wait( waitTime );

	self player_unset_fast_hands_booster();
}

player_unset_mega_booster()
{
	self.isHealthBoosted = undefined;
	self _unsetPerk( "specialty_marathon" );
	self.moveSpeedScaler = 1;
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale();	

		// reloading == specialty_fastreload
	self _unsetPerk( "specialty_fastreload" );

	// ads'ing == specialty_quickdraw
	self _unsetPerk( "specialty_quickdraw" );

	// movement == specialty_stalker
	self _unsetPerk( "specialty_stalker" );

	// throwing grenades == specialty_fastoffhand
	self _unsetPerk( "specialty_fastoffhand" );

	// sprint recovery == specialty_fastsprintrecovery
	self _unsetPerk( "specialty_fastsprintrecovery" );

	// switching weapons == specialty_quickswap
	self _unsetPerk( "specialty_quickswap" );
	
	self.isBoosted = undefined;
	self SetClientDvar( "ui_juiced_end_milliseconds", 0 );
}

//===========================================
// 				initLockerData
//===========================================
initLockerData()
{
	locker_data = [];
	
	// Light Weapons
	locker_data["light_weapons"] = SpawnStruct();
	locker_data["light_weapons"].use_func = ::locker_armory_func;
	locker_data["light_weapons"].use_param = "alien_armory_light_weapons";
	locker_data["light_weapons"].hint_text = &"ALIEN_COLLECTIBLES_LOCKER_LIGHT";

	// Heavy Weapons
	locker_data["heavy_weapons"] = SpawnStruct();
	locker_data["heavy_weapons"].use_func = ::locker_armory_func;
	locker_data["heavy_weapons"].use_param = "alien_armory_heavy_weapons";
	locker_data["heavy_weapons"].hint_text = &"ALIEN_COLLECTIBLES_LOCKER_HEAVY";

	// Perks
	locker_data["perks"] = SpawnStruct();
	locker_data["perks"].use_func = ::locker_armory_func;
	locker_data["perks"].use_param = "alien_armory_perks";
	locker_data["perks"].hint_text = &"ALIEN_COLLECTIBLES_LOCKER_PERK";
			
	return locker_data;
}


//===========================================
// 				runLockers
//===========================================
runLockers()
{
	locker_data = initLockerData();
	run_thread_on_targetname( "alien_armory_light_weapons", ::locker_thread, locker_data, "light_weapons" );
	run_thread_on_targetname( "alien_armory_heavy_weapons", ::locker_thread, locker_data, "heavy_weapons" );
	run_thread_on_targetname( "alien_armory_perks", 		::locker_thread, locker_data, "perks" );
}


//===========================================
// 			searchable_cabinet
//===========================================
locker_thread( locker_data_array, locker_type )
{
	// Retrieve the data for the cabinet type
	assert( IsDefined( locker_data_array ) );
	locker_data = locker_data_array[locker_type];
	assert( IsDefined( locker_data ) );
		
	self MakeUsable();
	self UseTriggerRequireLookAt(); 
	self SetCursorHint( "HINT_ACTIVATE" );	
	self SetHintString( locker_data.hint_text );
	
	while( true )
	{
		self waittill( "trigger", player );	
		
		self PlaySound( "intelligence_briefcase_pickup" ); 
		
		player thread [[locker_data.use_func]]( locker_data.use_param );
		
		wait( 1 );
	}
}

updatePlayerLootDvar( dvarName, itemName )
{
	assert( IsPlayer( self ) );                
	self SetClientDvar( dvarName, self maps\mp\alien\_collectibles::get_loot_count( itemName ) );
}

updatePlayerWeaponDvars()
{
	assert( IsPlayer( self ) );
	clientNum = self GetEntityNumber();
	
	weap1 = "none";
	weap2 = "none";
	
	weapList = self GetWeaponsListPrimaries();
	if ( weapList.size )
	{
		weap1_full = weapList[0];
		
		weaponTokens = StrTok( weap1_full, "_" );	
		if ( weaponTokens[0] == "iw5" )
			weap1 = weaponTokens[0] + "_" + weaponTokens[1];
		else if ( weaponTokens[0] == "alt" )
			weap1 = weaponTokens[1] + "_" + weaponTokens[2];
		else
			weap1 = weaponTokens[0];
	}
	if ( weapList.size > 1 )
	{
		weap2_full = weapList[1];
		
		weaponTokens = StrTok( weap2_full, "_" );	
		if ( weaponTokens[0] == "iw5" )
			weap2 = weaponTokens[0] + "_" + weaponTokens[1];
		else if ( weaponTokens[0] == "alt" )
			weap2 = weaponTokens[1] + "_" + weaponTokens[2];
		else
			weap2 = weaponTokens[0];
	}
	
	self SetClientDvar( "ui_player_weap1", weap1 );
	self SetClientDvar( "ui_player_weap2", weap2 );
}


updatePlayerPerkDvar()
{
	assert( IsPlayer( self ) );
	clientNum = self GetEntityNumber();
	
	perk_bits = 0;
	
	first_perk_index = undefined;
	
	foreach( item in level.armory_items )
	{
		if ( item.type == "perk" )
		{
			if ( !IsDefined( first_perk_index ) )
				first_perk_index = item.idx;
			
			perk_index = item.idx - first_perk_index;
			assert( perk_index < 32 ); // It's a bit-array stored as an integer
			
			if ( self _hasPerk( item.ref ) )
			{
				perk_bits = perk_bits | ( 1 << perk_index );
			}
		}
	}
	
	self SetClientDvar( "ui_player_perks", perk_bits );
}
