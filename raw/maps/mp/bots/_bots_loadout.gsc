
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\bots\_bots_ks;

init()
{
	// Initialize tables of loadouts per personality and per difficulty
	init_template_table();
	init_class_table();
	
	// Needed to ensure we're not trying to set bot loadouts before they have been parsed
	level.bot_loadouts_initialized = true;
}

init_class_table()
{
	filename = "mp/botClassTable.csv";
	
	level.botLoadoutSets = [];
	fieldArray = bot_loadout_fields();
	column = 0;

	for(;;)
	{
		column++;
		
		strPers = tableLookup( filename, 0, "botPersonalities", column );
		strDiff = tableLookup( filename, 0, "botDifficulties", column );
		
		if ( !isDefined( strPers ) || (strPers == "") )
			break;
		
		if ( !isDefined( strDiff ) || (strDiff == "") )
			break;
		
		loadoutValues = [];				
		foreach ( field in fieldArray )	
		{
			loadoutValues[field] = tableLookup( filename, 0, field, column );
/#
			assert_field_valid( field, loadoutValues[field] );
#/
		}
		
		personalities = StrTok( strPers, "| " );
		difficulties = StrTok( strDiff, "| " );

		foreach ( personality in personalities )
		{
			foreach ( difficulty in difficulties )
			{
				loadoutSet = bot_loadout_set( personality, difficulty, true );
				loadout = SpawnStruct();
				loadout.loadoutValues = loadoutValues;
				loadoutSet.loadouts[loadoutSet.loadouts.size] = loadout;
			}
		}
	}
}
	
init_template_table()
{
	filename = "mp/botTemplateTable.csv";

	level.botLoadoutTemplates = [];
	fieldArray = bot_loadout_fields();
	column = 0;
	
	for(;;)
	{
		column++;
		
		strTemplateName = tableLookup( filename, 0, "template_", column );
		
		if ( !isDefined( strTemplateName ) || (strTemplateName == "") )
			break;
				
		strTemplateLookupName = "template_" + strTemplateName;
		
		level.botLoadoutTemplates[strTemplateLookupName] = [];
		
		foreach ( field in fieldArray )	
		{
			entry = tableLookup( filename, 0, field, column );
			if ( IsDefined( entry ) && entry != "" )
			{
				level.botLoadoutTemplates[strTemplateLookupName][field] = entry;
/#
				assert_field_valid( field, entry );	
#/
			}
		}
	}	
}

/#
assert_field_valid( field, value )
{
	// Make sure the killstreaks loaded are valid in general for bots
	if ( field == "loadoutStreak1" || field == "loadoutStreak2" || field == "loadoutStreak3" )
	{
		killstreaks = StrTok( value, "| " );
		foreach( streak in killstreaks )
		{
			if ( GetSubStr( streak, 0, 9 ) != "template_" )
				assert_streak_valid_for_bots_in_general(streak);
		}
	}
}
#/

bot_loadout_fields()
{
	result = [];
	result[result.size] = "loadoutPrimary";
	result[result.size] = "loadoutPrimaryBuff";
	result[result.size] = "loadoutPrimaryAttachment";
	result[result.size] = "loadoutPrimaryAttachment2";
	result[result.size] = "loadoutPrimaryCamo";
	result[result.size] = "loadoutPrimaryReticle";
	result[result.size] = "loadoutSecondary";
	result[result.size] = "loadoutSecondaryBuff";
	result[result.size] = "loadoutSecondaryAttachment";
	result[result.size] = "loadoutSecondaryAttachment2";
	result[result.size] = "loadoutSecondaryCamo";
	result[result.size] = "loadoutSecondaryReticle";
	result[result.size] = "loadoutEquipment";
	result[result.size] = "loadoutPerk1";
	result[result.size] = "loadoutPerk2";
	result[result.size] = "loadoutPerk3";
	result[result.size] = "loadoutPerk4";
	result[result.size] = "loadoutPerk5";
	result[result.size] = "loadoutPerk6";
	result[result.size] = "loadoutPerk7";
	result[result.size] = "loadoutPerk8";
	result[result.size] = "loadoutOffhand";
	result[result.size] = "loadoutStreakType";
	result[result.size] = "loadoutStreak1";
	result[result.size] = "loadoutStreak2";
	result[result.size] = "loadoutStreak3";
	result[result.size] = "loadoutCharacterType";
	result[result.size] = "loadoutCharacterImage";
	return result;
}

bot_loadout_set( personality, difficulty, createIfNeeded )
{
	setName = difficulty + "_" + personality;

	if ( !isDefined( level.botLoadoutSets ) )
		level.botLoadoutSets = [];
	
	if ( !isDefined( level.botLoadoutSets[setName] ) && createIfNeeded )
	{
		level.botLoadoutSets[setName] = SpawnStruct();
		level.botLoadoutSets[setName].loadouts = [];
	}
	
	if ( isDefined( level.botLoadoutSets[setName] ) )
		return level.botLoadoutSets[setName];
}

bot_loadout_pick( personality, difficulty )
{
	loadoutSet = bot_loadout_set( personality, difficulty, false );	
	if ( IsDefined( loadoutSet ) && isDefined( loadoutSet.loadouts ) && loadoutSet.loadouts.size > 0 )
	{
		loadoutChoice = RandomInt( loadoutSet.loadouts.size );
		return loadoutSet.loadouts[loadoutChoice].loadoutValues;
	}
}

bot_validate_weapon( weaponName, attachment, attachment2  )
{
	attachmentComboTable = "mp/attachmentcombos.csv";
	
	validAttachments = getWeaponAttachmentArrayFromStats( weaponName );
	
	if ( attachment != "none" && !array_contains( validAttachments, attachment ) )
		return false;
	
	if ( attachment2 != "none" && !array_contains( validAttachments, attachment2 ) )
		return false;
	
	if ( attachment == "none" || attachment2 == "none" )
		return true;
	
	attachmentRow = TableLookupRowNum( attachmentComboTable, 0, attachment );
	if ( attachmentRow >= 0 )
	{
		columnHeader = "no";
		column = 0;
		
		while ( columnHeader != "" )
		{
			columnHeader = TableLookupByRow( attachmentComboTable, 0, column );
			if ( columnHeader == attachment2 )
			{
				allowed = TableLookupByRow( attachmentComboTable, attachmentRow, column );
				if ( allowed == "no" )
					return false;
				else
					return true;
			}
			column++;
		}
	}
	
	return true;
}

bot_perk_cost( perkName )
{
	return int( TableLookup( "mp/perktable.csv", 1, perkName, 10 ) );
}

bot_validate_perk( choice, loadoutValueName, loadoutValueArray )
{
	totalCostAllowed = 8; // TODO: Is this defined anywhere else?
	allocatedCost = 0;
	
	// Name will always be "loadoutPerkN[N][N]" from 1 to N
	index = int( GetSubStr( loadoutValueName, 11 ) );	
	
	for ( i = index - 1; i > 0; i-- )
	{
		prevPerkName = "loadoutPerk" + i;

		// Make sure we havent picked the same perk twice
		if ( choice == loadoutValueArray[prevPerkName] )
			return false;

		allocatedCost += bot_perk_cost( loadoutValueArray[prevPerkName] );
	}
	
	// Make sure this choice can be afforded with rest of choices
	if ( (allocatedCost + bot_perk_cost( choice )) > totalCostAllowed )
		return false;

	return true;
}

bot_loadout_valid_choice( loadoutValueVerbatim, loadoutValueArray, loadoutValueName, choice )
{
	valid = true;
		
	switch ( loadoutValueName )
	{
		case "loadoutPrimaryBuff":
			valid = maps\mp\gametypes\_class::isValidWeaponBuff( choice, loadoutValueArray["loadoutPrimary"] );
			break;
		case "loadoutPrimaryAttachment":
			valid = self bot_validate_weapon( loadoutValueArray["loadoutPrimary"], choice, "none" );
			break;
		case "loadoutPrimaryAttachment2":
			valid = self bot_validate_weapon( loadoutValueArray["loadoutPrimary"], loadoutValueArray["loadoutPrimaryAttachment"], choice );
			break;
		case "loadoutSecondaryBuff":
			valid = maps\mp\gametypes\_class::isValidWeaponBuff( choice, loadoutValueArray["loadoutSecondary"] );
			break;
		case "loadoutSecondaryAttachment":
			valid = self bot_validate_weapon( loadoutValueArray["loadoutSecondary"], choice, "none" );
			break;
		case "loadoutSecondaryAttachment2":
			valid = self bot_validate_weapon( loadoutValueArray["loadoutSecondary"], loadoutValueArray["loadoutSecondaryAttachment"], choice );
			break;
		case "loadoutPrimaryCamo":
			valid = (!IsDefined( self.botLoadoutFavoriteCamo ) || (choice == self.botLoadoutFavoriteCamo));
			break;
		case "loadoutStreak1":
		case "loadoutStreak2":
		case "loadoutStreak3":
			valid = bot_killstreak_is_valid_internal( choice, "bots", undefined, loadoutValueArray["loadoutStreakType"] );
			break;
		case "loadoutPerk1":
		case "loadoutPerk2":
		case "loadoutPerk3":
		case "loadoutPerk4":
		case "loadoutPerk5":
		case "loadoutPerk6":
		case "loadoutPerk7":
		case "loadoutPerk8":
			valid = bot_validate_perk( choice, loadoutValueName, loadoutValueArray );
			break;
	};
	
	return valid;
}

bot_loadout_choose_from_set( valueChoices, loadoutValue, loadoutValueArray, loadoutValueName )
{
	chosenValue = "none";
	chosenTemplate = undefined;
	validCount = 0.0;
	
	if ( array_contains( valueChoices, "specialty_null" ) )
		chosenValue = "specialty_null";
		
	foreach ( choice in valueChoices )
	{
		template = undefined;
		
		if ( GetSubStr( choice, 0, 9 ) == "template_" )
		{
			template = choice;
			templateValues = level.botLoadoutTemplates[choice][loadoutValueName];
			assert( IsDefined( templateValues ) );
			choice = bot_loadout_choose_from_set( StrTok( templateValues, "| " ), loadoutValue, loadoutValueArray, loadoutValueName );
	
			// If we have already chosen this template for any field, always choose the same template again when given the option
			if ( IsDefined( template ) && IsDefined( self.chosenTemplates[template] ) )
				return choice;
		}
				
		if ( self bot_loadout_valid_choice( loadoutValue, loadoutValueArray, loadoutValueName, choice ) )
		{
			validCount = validCount + 1.0;
			if ( RandomFloat( 1.0 ) <= (1.0 / validCount) )
			{
				chosenValue = choice;
				chosenTemplate = template;
			}
		}
	}
	
	if ( IsDefined( chosenTemplate ) )
		self.chosenTemplates[chosenTemplate] = true;
	
	return chosenValue;
}

bot_loadout_choose_values( loadoutValueArray )
{
	self.chosenTemplates = [];
		
	foreach( loadoutValueName, loadoutValue in loadoutValueArray )
	{
		valueChoices = StrTok( loadoutValue, "| " );
		
		chosenValue = self bot_loadout_choose_from_set( valueChoices, loadoutValue, loadoutValueArray, loadoutValueName );
				
		debugLoadoutValue = GetDvar( "bot_Debug" + loadoutValueName, "" );
		if ( IsDefined( debugLoadoutValue ) && debugLoadoutValue != "" )
			chosenValue = debugLoadoutValue;

		loadoutValueArray[loadoutValueName] = chosenValue;	
	}
	
	return loadoutValueArray;
}

bot_loadout_class_callback()
{   	
	personality = self BotGetPersonality();
	difficulty = self BotGetDifficulty();

	// If bot already has a loadout, stick with it most of the time
	if ( IsDefined( self.botLastLoadout ) )
	{
		same_difficulty = self.botLastLoadoutDifficulty == difficulty;
		same_personality = self.botLastLoadoutPersonality == personality;
		if ( same_difficulty && same_personality && ( !IsDefined(self.hasDied) || self.hasDied ) && !IsDefined(self.respawn_with_lockon_launcher) )
		{
			if ( RandomFloat( 1.0 ) > 0.25 )
				return self.botLastLoadout;
		}
	}

	loadoutValueArray = self bot_loadout_pick( personality, difficulty );
	loadoutValueArray = self bot_loadout_choose_values( loadoutValueArray );

	// If Squad mode then override with the loadout for that squad member
	if ( GetDvar( "squad_match" ) == "1" )
		loadoutValueArray = self bot_loadout_setup_squad_match( loadoutValueArray );

	self.botLastLoadout = loadoutValueArray;
	self.botLastLoadoutDifficulty = difficulty;
	self.botLastLoadoutPersonality = personality;
	
	if ( IsDefined( loadoutValueArray["loadoutPrimaryCamo"] ) && loadoutValueArray["loadoutPrimaryCamo"] != "none" )
		self.botLoadoutFavoriteCamo = loadoutValueArray["loadoutPrimaryCamo"];
	
	if ( IsDefined(self.respawn_with_lockon_launcher) )
	{
		loadoutValueArray["loadoutSecondary"] = level.bot_lockon_weapon;
		self.respawn_with_lockon_launcher = undefined;
		self.botLastLoadout = undefined;			// Force bot to pick a new loadout next time
	}
	
	// Setup self.loadoutPerks[];
	self.loadoutPerks = [];
	foreach ( itemName, item in loadoutValueArray )
	{
		if ( (GetSubStr( itemName, 0, 11 ) == "loadoutPerk") && (item != "specialty_null") && (item != "none") )
			self.loadoutPerks[self.loadoutPerks.size] = item;
	}
	
	return loadoutValueArray;
}

bot_setup_loadout_callback()
{
	personality = self BotGetPersonality();
	difficulty = self BotGetDifficulty();
	
	loadoutSet = bot_loadout_set( personality, difficulty, false );
	if ( IsDefined( loadoutSet ) && isDefined( loadoutSet.loadouts ) && loadoutSet.loadouts.size > 0 )
	{
		self.classCallback = ::bot_loadout_class_callback;
		return true;
	}
	
	bot_name_without_personality = GetSubStr(self.name,0,self.name.size-10);	// At this point in the setup, the bot personality might be wrong, so don't display it here
	AssertMsg("Bot <" + bot_name_without_personality + "> has no possible loadouts for personality <" + personality + "> and difficulty <" + difficulty + ">");
	self.classCallback = undefined;
	return false;
}

bot_loadout_setup_squad_match( loadoutValueArray )
{
	println( "Squad game detected - Overriding loadout" );
	
	// TODO: Handle streaks and perks

	if ( self.team == "allies" )
	{
		owner = level.players[ 0 ];
		foreach( player in level.players )
		{
			if ( IsPlayer( player ) )
			{
				owner = player;
				break;
			}
		}

		squad_slot = level.squadSlots[ self GetEntityNumber() ];
		loadoutValueArray[ "loadoutPrimary" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 0, "weapon" );
		loadoutValueArray[ "loadoutPrimaryAttachment" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 0, "attachment", 0 );
		loadoutValueArray[ "loadoutPrimaryAttachment2" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 0, "attachment", 1 );
		loadoutValueArray[ "loadoutPrimaryBuff" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 0, "buff" );
		loadoutValueArray[ "loadoutPrimaryCamo" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 0, "camo" );
		loadoutValueArray[ "loadoutPrimaryReticle" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 0, "reticle" );

		loadoutValueArray[ "loadoutSecondary" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 1, "weapon" );
		loadoutValueArray[ "loadoutSecondaryAttachment" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 1, "attachment", 0 );
		loadoutValueArray[ "loadoutSecondaryAttachment2" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 1, "attachment", 1 );
		loadoutValueArray[ "loadoutSecondaryBuff" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 1, "buff" );
		loadoutValueArray[ "loadoutSecondaryCamo" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 1, "camo" );
		loadoutValueArray[ "loadoutSecondaryReticle" ] = owner getPlayerData( "customClasses", squad_slot, "weaponSetups", 1, "reticle" );
	
		loadoutValueArray[ "loadoutEquipment" ] = owner getPlayerData( "customClasses", squad_slot, "perks", 0 );
		loadoutValueArray[ "loadoutOffhand" ] = owner getPlayerData( "customClasses", squad_slot, "perks", 1 );
		loadoutValueArray[ "loadoutCharacterType" ] = owner getPlayerData( "customClasses", squad_slot, "type" );
	}
	else
	{
		squad_slot = level.squadSlots[ self GetEntityNumber() ];
		loadoutValueArray[ "loadoutPrimary" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 0, "weapon" );
		loadoutValueArray[ "loadoutPrimaryAttachment" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 0, "attachment", 0 );
		loadoutValueArray[ "loadoutPrimaryAttachment2" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 0, "attachment", 1 );
		loadoutValueArray[ "loadoutPrimaryBuff" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 0, "buff" );
		loadoutValueArray[ "loadoutPrimaryCamo" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 0, "camo" );
		loadoutValueArray[ "loadoutPrimaryReticle" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 0, "reticle" );

		loadoutValueArray[ "loadoutSecondary" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 1, "weapon" );
		loadoutValueArray[ "loadoutSecondaryAttachment" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 1, "attachment", 0 );
		loadoutValueArray[ "loadoutSecondaryAttachment2" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 1, "attachment", 1 );
		loadoutValueArray[ "loadoutSecondaryBuff" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 1, "buff" );
		loadoutValueArray[ "loadoutSecondaryCamo" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 1, "camo" );
		loadoutValueArray[ "loadoutSecondaryReticle" ] = getEnemySquadData( "customClasses", squad_slot, "weaponSetups", 1, "reticle" );
	
		loadoutValueArray[ "loadoutEquipment" ] = getEnemySquadData( "customClasses", squad_slot, "perks", 0 );
		loadoutValueArray[ "loadoutOffhand" ] = getEnemySquadData( "customClasses", squad_slot, "perks", 1 );
		loadoutValueArray[ "loadoutCharacterType" ] = getEnemySquadData( "customClasses", squad_slot, "type" );
	}
	
	return loadoutValueArray;
}
