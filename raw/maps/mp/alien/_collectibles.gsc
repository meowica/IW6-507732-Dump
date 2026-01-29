#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\alien\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\scripts\_alien_armory;
#include maps\mp\alien\_persistence;


COLLECTIBLES_TABLE			= "mp/alien/collectibles.csv";		// collectable itmes definition

TABLE_ITEM_INDEX			= 0;	// Indexing
TABLE_ITEM_REF				= 1;	// reference string
TABLE_ITEM_MODEL			= 2;	// xmodel string
TABLE_ITEM_NAME				= 3;	// localization name
TABLE_ITEM_DESC				= 4;	// localization desc, use hint
TABLE_ITEM_COUNT			= 5;	// count per spawn
TABLE_ITEM_PARTS			= 6;	// parts array
TABLE_ITEM_OWNERSHIP		= 7;	// ownership type, soulbound/shared/droppable
TABLE_ITEM_RESPAWN			= 8;	// respawn timer, 0 = no respawn, float value
TABLE_ITEM_RESPAWN_MAX		= 9;	// respawn times, 0 = always, 1 = respawns once
TABLE_ITEM_VIS				= 10;	// visibility condition string
TABLE_ITEM_UNLOCK			= 11;	// unlock requirement
TABLE_ITEM_PLAYER_MAX		= 12; 	// player inventory max carry count

TABLE_ITEM_PERSIST			= 13;	// Does not get removed from the world after use
TABLE_ITEM_XP				= 14;	// XP reward for collecting
TABLE_ITEM_COST				= 15;	// cost of pickup if it requires, 0 = no cost

TABLE_ITEM_NEWWEAPON1		= 16;	// Upgraded base weapon
TABLE_ITEM_ATTACH1_UPGRADE1	= 17;	// arttachment option 1 for upgrade station 1
TABLE_ITEM_ATTACH2_UPGRADE1	= 18;	// second attachment option for upgrade station 1
TABLE_ITEM_CAMO_UPGRADE1	= 19;	//camo option for weapon for upgrade station 1
TABLE_ITEM_RETICLE_UPGRADE1	= 20;	//reticle option for weapon for upgrade station 1

TABLE_ITEM_NEWWEAPON2		= 21;	// Upgraded base weapon
TABLE_ITEM_ATTACH1_UPGRADE2	= 22;	// arttachment option 1 for upgrade station 2
TABLE_ITEM_ATTACH2_UPGRADE2	= 23;	// second attachment option for upgrade station 2
TABLE_ITEM_CAMO_UPGRADE2	= 24;	//camo option for weapon for upgrade station 2
TABLE_ITEM_RETICLE_UPGRADE2	= 25;	//reticle option for weapon for upgrade station 2

TABLE_PART_INDEX			= 0;
TABLE_PART_REF				= 1;
TABLE_PART_MODEL			= 2;
TABLE_PART_NAME				= 3;
TABLE_PART_DESC				= 4;
TABLE_PART_COUNT			= 5;
TABLE_PART_PARENT			= 6;	// parent item this part contributes to
TABLE_PART_OWNERSHIP		= 7;
TABLE_PART_RESPAWN			= 8;
TABLE_PART_RESPAWN_MAX		= 9;
TABLE_PART_VIS				= 10;
TABLE_PART_UNLOCK			= 11;
TABLE_PART_PLAYER_MAX		= 12;

ITEM_MIN_SPAWN_DISTANCE_SQR = 1024.0 * 1024.0;
SENTRY_MIN_KILL_DISTANCE_SQR = 0.0 * 0.0;
SENTRY_TIMEOUT = 150;

// Kill resource variables
KILL_RESOURCE_MAX 		= 5000;
COST_HEALTHPACK			= 1000;
COST_SENTRY				= 3000;
COST_AMMO				= 1000;
COST_AIRSTRIKE			= 4000;
COST_TEAM_HEALTHPACK    = 1000;

CONST_SENTRY_THREAT_BIAS = -1000;
CONST_SENTRY_HEALTH = 150;

CONST_WEAPON_CURRENCY	= "loot_blood_small";

pre_load()
{
	if ( !alien_mode_has( "collectible" ) )
		return;
	
	// precache item assets
	collectibles_model_precache();
	
	// precache shaders
	PreCacheShader( "dpad_health_pack" );
	
	// setup fx
	level._effect[ "vfx_alien_weapon_pickup" ]	 = loadfx( "vfx/gameplay/alien/vfx_alien_weapon_pickup");
	level._effect[ "Fire_Cloud" ]	 = loadfx( "vfx/gameplay/alien/vfx_alien_gas_fire");
	level._effect[ "Alien_On_Fire" ]	 = loadfx( "vfx/gameplay/alien/vfx_alien_on_fire");
	level._effect[ "Propane_explosion" ] = loadfx( "fx/explosions/propane_tank_small" );
	// -=-=-=-=-=-=-  -=-=-=-=-=-=-  -=-=-=-=-=-=-  -=-=-=-=-=-=-
	
	// TODO: Mp version of sentry
	/*
	// init sentry
	common_scripts\_sentry::main();		// preload sentry assets
	
	// following settings are overrides, run after _sentry::main()
	// if you see 20000+ hp, that is health buffer, its real health is still the amount above 20000
	level.sentry_settings[ "sentry_minigun" ].health = 700; // common_scripts\_sentry.gsc line 307
	level.sentry_settings[ "sentry_minigun" ].bullet_armor = 42;
	*/
	
	// init collectibles table
	level.collectibles 	= [];
	collectibles_table_init( 0, 99 );		// items
	collectibles_table_init( 100, 199 );	// weapons
	collectibles_table_init( 1000, 1099 );	// loots
	
	lootbox_table_init( 1000000, 1000100 );	// loot boxes
	
	// precache collectible pickup strings ( must match [desc] of stringtable: mp/alien/collectibles.csv )
	collectibles_hint_precache();
}

collectibles_model_precache()
{
	PreCacheModel( "ls_aid_supplybag_01" );
	PreCacheModel( "weapon_syringe" );
	PreCacheModel( "sentry_minigun_folded" );
	PreCacheModel( "weapon_claymore" );
	PreCacheModel( "grenade_bag" );
	PreCacheModel( "mil_ammo_case_1_open" );
	PreCacheModel( "prop_dogtags_foe" );
	PreCacheModel( "propane_tank_iw6" );
	PreCacheModel( "projectile_bouncing_betty_grenade" );
	PreCacheModel( "tool_cabinet_02_iw6" );
}

collectibles_hint_precache()
{
	all_hints_array = [];
	
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_AMMO" ] 				= &"ALIEN_COLLECTIBLES_PICKUP_AMMO";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_AUTO_SENTRY" ] 			= &"ALIEN_COLLECTIBLES_PICKUP_AUTO_SENTRY";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_CLAYMORE" ] 			= &"ALIEN_COLLECTIBLES_PICKUP_CLAYMORE";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_C4" ] 					= &"ALIEN_COLLECTIBLES_PICKUP_C4";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_GRENADE" ]				= &"ALIEN_COLLECTIBLES_PICKUP_GRENADE";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_MAUL" ] 				= &"ALIEN_COLLECTIBLES_PICKUP_MAUL";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_AK12" ]					= &"ALIEN_COLLECTIBLES_PICKUP_AK12";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_M27" ]					= &"ALIEN_COLLECTIBLES_PICKUP_M27";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_FLASH" ]				= &"ALIEN_COLLECTIBLES_PICKUP_FLASH";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_HEALTH_PACK" ]			= &"ALIEN_COLLECTIBLES_PICKUP_HEALTH_PACK";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_FAST_LEGS_BOOST" ]		= &"ALIEN_COLLECTIBLES_PICKUP_FAST_LEGS_BOOST";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_FAST_HANDS_BOOST" ]		= &"ALIEN_COLLECTIBLES_PICKUP_FAST_HANDS_BOOST";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_HEALTH_REGEN_BOOST" ]	= &"ALIEN_COLLECTIBLES_PICKUP_HEALTH_REGEN_BOOST";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_SELF_REVIVE_BOOST" ]	= &"ALIEN_COLLECTIBLES_PICKUP_SELF_REVIVE_BOOST";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_PROPANE_TANK" ] 		= &"ALIEN_COLLECTIBLES_PICKUP_PROPANE_TANK";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_SHOCK_AMMO" ] 			= &"ALIEN_COLLECTIBLES_PICKUP_SHOCK_AMMO";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_GAS_CAN" ] 				= &"ALIEN_COLLECTIBLES_PICKUP_GAS_CAN";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_MK32" ] 				= &"ALIEN_COLLECTIBLES_PICKUP_MK32";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_HONEYBADGER" ] 			= &"ALIEN_COLLECTIBLES_PICKUP_HONEYBADGER";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_VKS" ] 					= &"ALIEN_COLLECTIBLES_PICKUP_VKS";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_FP6" ] 					= &"ALIEN_COLLECTIBLES_PICKUP_FP6";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_BOUNCING_BETTY" ] 		= &"ALIEN_COLLECTIBLES_PICKUP_BOUNCING_BETTY";
	all_hints_array[ "ALIEN_COLLECTIBLES_LOOT_BLOOD_S" ] 				= &"ALIEN_COLLECTIBLES_LOOT_BLOOD_S";
	all_hints_array[ "ALIEN_COLLECTIBLES_LOCKER_UPGRADE1" ] 			= &"ALIEN_COLLECTIBLES_LOCKER_UPGRADE1";
	all_hints_array[ "ALIEN_COLLECTIBLES_LOCKER_UPGRADE2" ] 			= &"ALIEN_COLLECTIBLES_LOCKER_UPGRADE2";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_KRISS" ] 				= &"ALIEN_COLLECTIBLES_PICKUP_KRISS";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_MICROTAR" ] 			= &"ALIEN_COLLECTIBLES_PICKUP_MICROTAR";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_FLAMETHROWER" ] 		= &"ALIEN_COLLECTIBLES_PICKUP_FLAMETHROWER";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_ACR" ] 					= &"ALIEN_COLLECTIBLES_PICKUP_ACR";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_LMG" ] 					= &"ALIEN_COLLECTIBLES_PICKUP_LMG";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_ELEPHANTGUN" ] 			= &"ALIEN_COLLECTIBLES_PICKUP_ELEPHANTGUN";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_P226" ] 				= &"ALIEN_COLLECTIBLES_PICKUP_P226";
	all_hints_array[ "ALIEN_COLLECTIBLES_PICKUP_L115A3" ] 				= &"ALIEN_COLLECTIBLES_PICKUP_L115A3";
	
	// (X) Open
	all_hints_array[ "ALIEN_COLLECTIBLES_OPEN" ]				= &"ALIEN_COLLECTIBLES_OPEN";
					

	foreach ( item in level.collectibles )
	{
		foreach ( key, hint in all_hints_array )
		{
			if ( item.desc == key )
			{
				item.desc = hint;
				PreCacheString( hint );
				break; // item.desc is now a localized string, can't compare to regular strings anymore
			}
		} 
	}
}

post_load()
{	
	if ( !alien_mode_has( "collectible" ) )
		return;
	
	// TEMP: multiple loot drop offsets
	level.loot_offset 					= [];
	level.loot_offset[ "health" ] 		= ( -16, -16, 0 );
	level.loot_offset[ "equipment" ] 	= ( 16, -16, 0 );
	level.loot_offset[ "weapon" ] 		= ( -16, 16, 0 );
	level.loot_offset[ "inventory" ] 	= ( 16, 16, 0 );
	
	// init collectibles in the world
	collectibles_world_init();
	lootbox_world_init();
	
	if ( !ThreatBiasGroupExists( "deployable_ammo" ) )
		CreateThreatBiasGroup( "deployable_ammo" );
	SetIgnoreMeGroup( "deployable_ammo", "aliens" );
	
	level.collectibles_lootcount = 0;
	level.alien_loot_initialized = true;
}

// sets up player for loot collection - fresh start every spawn, lose everything!
// TODO: maybe have player drop all carried loots as a bag where he/she died for later pickup
player_loot_init()
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( !alien_mode_has( "loot" ) )
		return;
	
	self.lootbag = [];
	self.has_health_pack = false;

//	self thread maps\mp\alien\_hud::update_self_revives_collected( -210, 107, "item_revive_booster", &"ALIEN_COLLECTIBLES_LOOT_SELF_REVIVES_COLLECTED" );
//	self thread maps\mp\alien\_hud::update_yellow_eggs_collected( -210, 83, "item_yellow_egg", &"ALIEN_COLLECTIBLES_LOOT_YELLOW_EGGS_COLLECTED" );
//	self thread maps\mp\alien\_hud::update_health_packs_collected( -210, 71, "item_health_pack", &"ALIEN_COLLECTIBLES_LOOT_HEALTH_PACKS_COLLECTED" );
//	self thread maps\mp\alien\_hud::update_red_eggs_collected( -210, 59, "item_red_egg", &"ALIEN_COLLECTIBLES_LOOT_RED_EGGS_COLLECTED" );
//	self thread maps\mp\alien\_hud::update_purple_eggs_collected( -210, 47, "item_purple_egg", &"ALIEN_COLLECTIBLES_LOOT_PURPLE_EGGS_COLLECTED" );
//	self thread maps\mp\alien\_hud::update_blue_eggs_collected( -210, 35, "item_blue_egg", &"ALIEN_COLLECTIBLES_LOOT_BLUE_EGGS_COLLECTED" ); //Batteries
//	self thread maps\mp\alien\_hud::update_shock_ammo_collected( 330, 155, "item_shock_ammo", &"ALIEN_COLLECTIBLES_LOOT_SHOCK_AMMO_COUNT" ); 
	self notify( "loot_initialized" );
	
	level.fireCloudDuration = getDvarInt( "scr_fireCloudDuration", "9");
	level.fireCloudRadius = getDvarInt( "scr_fireCloudRadius", "185");
	level.fireCloudHeight = getDvarInt( "scr_fireCloudHeight", "120");
	level.fireCloudTickDamage = getDvarInt( "scr_fireCloudTickDamage", "100");
	level.fireCloudPlayerTickDamage = getDvarInt( "scr_fireCloudTickDamage", "3");

	level.fireCloudList = [];
	
	if ( alien_mode_has( "kill_resource" ) )
	{
		self maps\mp\alien\_hud::create_gain_credit_hud(-38, 38, &"MP_PLUS" );
		//self give_loot( "loot_blood_small", 5000 );
	}

}

collectibles_world_init()
{
	assertex( isdefined( level.collectibles ), "Collectibles not initialized" );
	level.itemexplodethisframe = false;
	level.collectibles_worldcount = [];
	
	// grab all collectible items
	items = getstructarray( "item", "targetname" );
	parts = getstructarray( "part", "targetname" );
	
	level.world_items = array_combine( items, parts );
	
	foreach ( world_item in level.world_items )
	{
		assertex( isdefined( world_item.script_noteworthy ), "Item at " + world_item.origin + " is missing script_noteworthy as item type" );
		world_item.item_ref = world_item.script_noteworthy;
		assertex( item_exist( world_item.item_ref ), "Item: " + world_item.item_ref + " does not exist in collectibles, update collectibles.csv, and check if max_item_index is set to include number of items in table" );
		
		world_item setup_item_data();
		
		level.collectibles_worldcount[ world_item.item_ref ] = level.collectibles[ world_item.item_ref ].count;
	}
	
	init_throwableItems();
	
	area_name = get_area_for_cycle( level.current_cycle_num );
	thread spawn_items_in_area( area_name );
}

init_throwableItems()
{
	level.thrown_entities = [];
	
	level.throwable_items = [];
	//                           weapon name
	level.throwable_items [ "alienpropanetank_mp" ] = init_throwable( 10000, "propane_tank_iw6", true, &"ALIEN_COLLECTIBLES_PICKUP_PROPANE_TANK", ::propaneTankWatchUse );
}

init_throwable( force, model, canBePickedUp, hintString, pickUpFunc )
{
	item_data = spawnStruct();
	item_data.force = force;   // the forward force that is applied when the item is thrown
	item_data.model = model;   // the item model
	item_data.canBePickedUp = canBePickedUp;  // boolean.  whether the item can be picked back up again
	item_data.hintString = hintString;        // if the item can be picked up back, the hint string that is applied
	item_data.pickUpFunc = pickUpFunc;        // if the item can be picked up back, call back function on the item
	
	return item_data;
}

spawn_random_item( ignore_distance_check, type )
{
	// if type not defined, spawn all
	randomized_items = array_randomize( level.world_items );
	foreach ( world_item in randomized_items )
	{
		if ( isdefined( type ) )
		{
			if ( type != world_item.item_ref )
				continue;
		}
		
		if ( level.collectibles_worldcount[ world_item.item_ref ] > 0 )
		{
			// skip this one if an item already exist here
			if ( isdefined( world_item.item_ent ) )
				continue;
			
			// Skip this one if it's too close to the players
			if ( !ignore_distance_check && !world_item item_min_distance_from_players() )
				continue;
			
			// spawn first one
			world_item spawn_item();
			// item ready for pickup :D
			world_item thread item_pickup_listener();

			//thread spawnPickup( item );
			level.collectibles_worldcount[ world_item.item_ref ]--;
		}
	}
}

get_area_for_cycle( cycle )
{
	if ( isDefined( level.world_areas_by_cycle ) && level.world_areas_by_cycle.size > cycle )
	{
		return level.world_areas_by_cycle[ cycle ];
	}
	
	return "all";
}

spawn_items_in_area( area )
{
	randomized_items = array_randomize( level.world_items );
	
	foreach ( world_item in randomized_items )
	{
		if ( !world_item.data["persist"] && area != "all" && !array_contains( world_item.areas, area ) )
			continue;
		
		if ( level.collectibles_worldcount[ world_item.item_ref ] > 0 )
		{
			if ( isDefined( world_item.item_ent ) )
				continue;
			
			world_item spawn_item();
			world_item thread item_pickup_listener();
			level.collectibles_worldcount[ world_item.item_ref ]--;
		}
	}
}

remove_items_in_area( area )
{
	foreach( world_item in level.world_items )
	{
		if ( isDefined( world_item.item_ent ) )
		{
			if ( !world_item.data["persist"] && area != "all" && !array_contains( world_item.areas, area ) )
				continue;
			
			world_item remove_world_item();
			level.collectibles_worldcount[ world_item.item_ref ]++;
		}
	}
}


// this keeps track of data (such as count, respawn times etc) per item
setup_item_data( is_part )
{
	self.override = SpawnStruct();
	
	if ( !isdefined( self.script_noteworthy ) )
		self.script_noteworthy = self.item_ref;

	self.isLoot		= is_collectible_loot( self.item_ref );
	self.isWeapon	= is_collectible_weapon( self.item_ref );
	self.isItem		= is_collectible_item( self.item_ref );
	
	self.areas		= self get_item_areas();
	
	// overrides
	if ( isdefined( self.script_parameters ) )
	{
		// parsing parameters
		// format: "key=value key=value"
		string_toks = StrTok( self.script_parameters, " " );
		foreach ( token in string_toks )
		{
			string_tok = StrTok( self.script_parameters, "=" );
			
			if ( string_tok.size == 0 )
				continue;
			
			assertex( string_tok.size == 2, "Incorrect format for override parameter, script_parameters 'key=value key=value ...'" );

			key 	= string_tok[ 0 ];
			value 	= string_tok[ 1 ];

			switch ( key )
			{
				case "respawn_max":
					self.override.respawn_max = int( value );
					break;

				case "unlock":
					self.override.unlock = int( value );
					break;
		
				default:
					AssertMsg( "You can not override: " + key + " on " + self.item_ref );
					break;
			}
		}
	}
	
	// init item data, tracker of item data
	self.data = [];
	self.data[ "count" ] 			= level.collectibles[ self.item_ref ].count;
	self.data[ "respawn_count" ]	= level.collectibles[ self.item_ref ].respawn_max;
	
	self.data[ "times_collected" ] 	= 0;
	self.data[ "last_collector" ] 	= undefined;
	self.data[ "vis" ]				= true;	// visibility
	self.data[ "unlock" ]			= 1;
	self.data[ "persist" ] 			= level.collectibles[ self.item_ref ].persist;
	self.data[ "cost" ] 			= level.collectibles[ self.item_ref ].cost;

	if ( isdefined( self.override ) )
	{
		if ( isdefined( self.override.respawn_max ) )
			self.data[ "respawn_count" ] = self.override.respawn_max;
		if ( isdefined( self.override.unlock ) )
			self.data[ "unlock" ] = self.override.unlock;
	}
}

get_item_areas()
{
	if ( !isDefined( level.world_areas ) )
	{
		return;
	}
	
	my_areas = [];
	
	foreach ( area_name, area_volume in level.world_areas )
	{
		if ( IsPointInVolume( self.origin, area_volume ) )
		{
			my_areas[ my_areas.size ] = area_name;
		}
	}
	
	return my_areas;
}

spawn_world_item( dropToGround, needPressXToUse )
{
	// self is world item struct	
	item_ref = self.item_ref;
	
	item_ent = spawn( "script_model", get_world_item_spawn_pos( dropToGround ) );
	item_ent SetModel( level.collectibles[ item_ref ].model );
	
	if ( IsDefined( self.angles ) )
	{
	   	item_ent.angles = self.angles;
	}
	else
	{
		item_ent.angles = (0, 0, 0);
	}
	
	self.item_ent = item_ent;
	
	if ( needPressXToUse )
	{
		make_item_ent_useable( self.item_ent, get_item_desc( item_ref ) );
		self.use_ent = self.item_ent;
	}
	else
	{
		self.use_ent = spawn( "trigger_radius", item_ent.origin, 0, 32, 32 );
	}
	
	if ( should_explode_on_damage ( item_ref ) )
		self.item_ent thread explodeOnDamage();
	
	self notify ( "spawned" );
	
/#  // debug
	if ( getdvarint( "debug_collectibles" ) == 1 )
		maps\mp\alien\_debug::debug_collectible( self );
#/
}

get_world_item_spawn_pos( dropToGround )
{
	VERTICAL_OFFSET = ( 0, 0, 16 );
	
	if ( dropToGround )
		return ( drop_to_ground( self.origin ) + VERTICAL_OFFSET );
	else
		return self.origin;
}

make_item_ent_useable( item_ent, hintString )
{
	item_ent SetCursorHint( "HINT_NOICON" );
	item_ent SetHintString( hintString );
	item_ent MakeUsable();
}

should_explode_on_damage ( item_ref )
{
	switch ( item_ref )
	{
	case "item_alienpropanetank_mp":
		return true;
	default:
		return false;
	}
}

spawn_item()
{
	spawn_world_item( false, true );
}

spawn_loot( item_owner )
{
	spawn_world_item( true, false );
	
	self.item_ent.loot_owner = item_owner;
	level.collectibles_lootcount++;
	
	self thread loot_collection_timeout();
	self thread item_fx();
}

loot_collection_timeout()
{
	self endon( "death" );
	self endon( "deleted" );

	self.loot_collection_timeout = 5;	// time out in seconds
	
	while ( self.loot_collection_timeout )
	{
		wait 1;
		self.loot_collection_timeout--;
	}
}

// delayed fx
item_fx()
{
	self.item_ent endon( "death" );
	level endon ( "game_ended" );
	
	// have to wait many frames in MP before playing fx on newly spawned model... wheres the wiki??
	wait 0.05;
	
	// TEMP - setup marker for easy visibility
	playFx( level._effect[ "vfx_alien_weapon_pickup" ], self.origin );	
}

// spin
item_spin()
{
	// self is script struct
	self.item_ent endon( "death" );
	level endon ( "game_ended" );
	
	rot_speed 	= 90;
	time 		= 10;
	
	while( 1 )
	{
		if ( !self.data[ "vis" ] )
		{
			self waittill( "spawned" );
		}
		
		self.item_ent RotateVelocity( ( 0, rot_speed, 0 ), time );
		if ( isdefined( self.item_ent_2 ) )
			self.item_ent_2 RotateVelocity( ( 0, rot_speed, 0 ), time );
		
		wait time;	 // 10
	}
}

// bob
item_bob()
{	
	// self is script struct
	self.item_ent endon( "death" );
	level endon ( "game_ended" );
	
	bob_range 		= 10;
	original_origin = self.item_ent.origin;
	up_origin 		= original_origin + ( 0, 0, bob_range/2 );
	down_origin 	= original_origin - ( 0, 0, bob_range/2 );
	
	accel 			= 0.25;
	decel 			= accel;
	time 			= accel + decel + 0.1;
	
	while( 1 )
	{
		if ( !self.data[ "vis" ] )
		{
			self waittill( "spawned" );
		}
		
		self.item_ent MoveTo( up_origin, time, accel, decel );
		
		if ( isdefined( self.item_ent_2 ) )
			self.item_ent_2 MoveTo( up_origin, time, accel, decel );
		
		wait time;
		
		self.item_ent MoveTo( down_origin, time, accel, decel );
		
		if ( isdefined( self.item_ent_2 ) )
			self.item_ent_2 MoveTo( down_origin, time, accel, decel );
		
		wait time;
	}
}

// item_pickup_listener( touch pickup )
item_pickup_listener()
{
	self endon( "death" );
	self endon( "timedout" );	// only by loot items
	level endon ( "game_ended" );
		
	while ( true )
	{
		self.use_ent waittill( "trigger", owner );
		
		if ( owner [[ get_func_cangive( self.item_ref ) ]]( self ) )
		{
			// TODO: get new sound for MP
			owner PlayLocalSound( "scavenger_pack_pickup" );
			
			owner thread [[ get_func_give( self.item_ref ) ]]( self );
			
			self.data[ "last_collector" ] = owner;
			self.data[ "times_collected" ]++;
			level.collectibles_worldcount[ self.item_ref ]++;
			owner notify( "loot_pickup", self );
		}
		else
		{
			// failed to give
			wait 0.05;
			continue;
		}
		
		if ( self.data[ "persist" ] > 0 )
		{
			continue;
		}
		else
		{
			self remove_world_item();
	
			// if respawns for finite times
			if ( self.data[ "respawn_count" ] <= 0 )
			{
				return;
			}
			
			// wait for respawn
			//wait level.collectibles[ self.item_ref ].respawn;
			
			level waittill( "alien_cycle_ended" );
			
			self.data[ "respawn_count" ]--;
			// Disabling respawning
			//spawn_random_item( false, self.item_ref );
		}
		// end, no loop
		return;
	}
}

// touch or use
loot_pickup_listener( item_owner, touch )
{
	self endon( "death" );
	self endon( "timedout" );	// only by loot items
	level endon ( "game_ended" );
	
	isLoot = is_collectible_loot( self.item_ref );
	
	if( !isdefined( touch ) )
		touch = false;
	
	// if not touch based, we apply press (X) use based
	if ( !touch )
	{	
		make_item_ent_useable( self.item_ent, get_item_desc( self.item_ref ) );		
	}
	
	while ( true )
	{
		self.use_ent waittill( "trigger", owner );
		
		if ( !isdefined( owner ) || !isplayer( owner ) )
		{
			wait 0.05;
			continue;
		}
		
		if ( owner [[ get_func_cangive( self.item_ref ) ]]( self ) )
		{
			// TODO: get new sound for MP
			owner PlayLocalSound( "scavenger_pack_pickup" );

			owner thread [[ get_func_give( self.item_ref ) ]]( self );
			owner notify( "loot_pickup", self );
		}
		else
		{
			// failed to give
			wait 0.05;
			continue;
		}
		
		/#
			if ( getdvarint( "debug_collectibles" ) == 1
			    && isLoot
			    && isdefined( item_owner )
			    && item_owner != owner
			    && isplayer( item_owner )
			    && isplayer( owner ) )
			{
				IPrintLn( owner.name + " took " + item_owner.name + "'s loot [" + self.item_ref + "]" );
			}
		#/

		if ( self.data[ "persist" ] > 0 )
		{
			continue;
		}
		else
		{
			self remove_loot();
		}
		return;
	}
}

// removes loot if not picked up in time
loot_pickup_timeout( owner, loot_timeout )
{
	self endon( "death" );
	level endon ( "game_ended" );

	countdown = loot_timeout;
	while ( countdown )
	{
		wait 1;
		countdown--;
	}
	
	/#
		if ( getdvarint( "debug_collectibles" ) == 1 )
		{
			player_name = "unknown player";
			if ( isdefined( owner ) && isplayer( owner ) && isdefined( owner.name ) )
				player_name = owner.name;
			
			iprintln( player_name + "'s loot [" + self.item_ref + "] timed out" );
		}
	#/
	
	if ( self.data[ "persist" ] > 0 )
	{
		self notify( "timedout" );
		self remove_world_item();
	}
}

// remove loot, world model, and touch trigger
remove_loot()
{
	remove_world_item();
	level.collectibles_lootcount--;
}

remove_world_item()
{
	self.item_ent delete();
	
	if ( isdefined( self.use_ent ) )  // use_ent could be different from item_ent
		self.use_ent delete();
}

item_min_distance_from_players()
{
	return !any_player_nearby( self.origin, ITEM_MIN_SPAWN_DISTANCE_SQR );
}

is_item( ref )
{
	return IsSubStr( ref, "item" );
}

is_part( ref )
{
	return IsSubStr( ref, "part" );
}

get_parent_item( ref )
{
	parent = level.collectibles[ ref ].parent;
	assertex( isdefined( parent ), "Part: " + ref + " does not have a parent" );
	
	return parent;
}

collectibles_table_init( index_start, index_end )
{
	// populate table
	for ( i = index_start; i < index_end; i++ )
	{
		ref = TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_INDEX, i, TABLE_ITEM_REF );
		if ( ref == "" )
			break;
		
		item				= SpawnStruct();
		item.index			= i;
		item.ref			= ref;
		item.model			= TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_INDEX, i, TABLE_ITEM_MODEL );
		item.name			= TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_INDEX, i, TABLE_ITEM_NAME );
		item.desc			= TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_INDEX, i, TABLE_ITEM_DESC );
		parts_string		= TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_REF, item.ref, TABLE_ITEM_PARTS );
		item.craftable		= false;
		
		// if parts are defined
		if ( parts_string != "" )
		{
			item.parts_string	= parts_string;
			item.craftable		= true;
			string_array 		= strtok( parts_string, " " );
			parts_ref_array		= [];
			item.recipe			= [];
			required_count		= 1;	// number of count of a part it requires for crafting
			
			assert_msg			= "Item " + item.ref + " does not have parts defined correctly, 'part count part count etc...'";
			
			for ( j = 0; j < string_array.size; j ++ )
			{
				string = string_array[ j ];
				
				if ( IsSubStr( string, "part" ) )
				{
					parts_ref_array[ parts_ref_array.size ] = string;
				}
				else
				{
					required_count = int( string );
					assertex( j - 1 >= 0 && isdefined( string_array[ j - 1 ] ) && string_array[ j - 1 ] != "", assert_msg );
					item.recipe[ string_array[ j - 1 ] ] = required_count;
				}
			}
			
			assertex( parts_ref_array.size, assert_msg );
			item.parts		= get_parts( item.ref, parts_ref_array );		// array of part structs
		}
		
		item.count			= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_ITEM_INDEX, i, TABLE_ITEM_COUNT ) );
		item.ownership 		= TableLookup( COLLECTIBLES_TABLE, 			TABLE_ITEM_INDEX, i, TABLE_ITEM_OWNERSHIP );
		item.respawn		= float( TableLookup( COLLECTIBLES_TABLE, 	TABLE_ITEM_INDEX, i, TABLE_ITEM_RESPAWN ) );
		item.respawn_max	= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_ITEM_INDEX, i, TABLE_ITEM_RESPAWN_MAX ) );
		item.vis			= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_ITEM_INDEX, i, TABLE_ITEM_VIS ) );
		item.unlock			= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_ITEM_INDEX, i, TABLE_ITEM_UNLOCK ) );
		item.player_max		= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_ITEM_INDEX, i, TABLE_ITEM_PLAYER_MAX ) );
		item.persist		= int( TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_INDEX, i, TABLE_ITEM_PERSIST ) );
		item.cost			= int( TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_INDEX, i, TABLE_ITEM_COST ) );
		item.cost_display	= TableLookup( COLLECTIBLES_TABLE, TABLE_ITEM_INDEX, i, TABLE_ITEM_COST );
		item.func_give		= get_func_give( item.ref );
		item.func_cangive	= get_func_cangive( item.ref );
		
		item.isLoot			= is_collectible_loot( item.ref );
		item.isWeapon		= is_collectible_weapon( item.ref );
		item.isItem			= is_collectible_item( item.ref );
		
		// data structs, not world item structs
		level.collectibles[ item.ref ] = item;
	}
}

is_collectible_loot( item_ref )
{
	if ( isdefined( level.collectibles ) 
	    && isdefined( level.collectibles[ item_ref ] ) 
	    && isdefined( level.collectibles[ item_ref ].isLoot ) 
	)
	{
		return level.collectibles[ item_ref ].isLoot;		
	}
	else
	{
		return ( GetSubStr( item_ref, 0, 5 ) == "loot_" );
	}
}

is_collectible_weapon( item_ref )
{
	if ( isdefined( level.collectibles ) 
	    && isdefined( level.collectibles[ item_ref ] ) 
	    && isdefined( level.collectibles[ item_ref ].isWeapon ) 
	)
	{
		return level.collectibles[ item_ref ].isWeapon;		
	}
	else
	{
		return ( GetSubStr( item_ref, 0, 5 ) == "weapon_" );
	}
}

is_collectible_item( item_ref )
{
	if ( isdefined( level.collectibles ) 
	    && isdefined( level.collectibles[ item_ref ] ) 
	    && isdefined( level.collectibles[ item_ref ].isItem ) 
	)
	{
		return level.collectibles[ item_ref ].isItem;		
	}
	else
	{
		return ( GetSubStr( item_ref, 0, 5 ) == "item_" );
	}
}

get_parts( item_ref, parts_ref_array )
{
	if ( item_exist( item_ref ) && isdefined( level.collectibles[ item_ref ].parts ) )
	{
		return level.collectibles[ item_ref ].parts;
	}
	
	parts 					= [];
	
	foreach ( part_ref in parts_ref_array )
	{
		part 				= SpawnStruct();
		part.ref 			= part_ref;
		
		part.index			= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_INDEX );
		part.model			= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_MODEL );
		part.name 			= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_NAME );
		part.desc 			= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_DESC );
		part.count 			= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_PART_REF, part.ref, TABLE_PART_COUNT ) );
		part.parent 		= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_PARENT );
		
		assertex( item_ref == part.parent, "Item " + item_ref + " and part " + part.ref + " are not associated correctly in table" );
		
		part.ownership		= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_OWNERSHIP );
		part.respawn		= float( TableLookup( COLLECTIBLES_TABLE, 	TABLE_PART_REF, part.ref, TABLE_PART_RESPAWN ) );
		part.respawn_max	= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_PART_REF, part.ref, TABLE_PART_RESPAWN_MAX ) );
		part.vis			= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_VIS );
		part.unlock			= TableLookup( COLLECTIBLES_TABLE, 			TABLE_PART_REF, part.ref, TABLE_PART_UNLOCK );
		part.player_max		= int( TableLookup( COLLECTIBLES_TABLE, 	TABLE_PART_REF, part.ref, TABLE_PART_PLAYER_MAX ) );
		
		parts[ part.ref ]	= part;
		
		// collectibles catagorizes all pickupable items
		level.collectibles[ part.ref ] = part;
	}
	
	return parts;	// array of part structs
}

item_exist( ref )
{
	return isdefined( level.collectibles[ ref ] );
}

get_item_desc( ref )
{
	return level.collectibles[ ref ].desc;
}

get_item_name( ref )
{
	return level.collectibles[ ref ].name;
}	

get_maxstock( ref )
{
	return level.collectibles[ ref ].player_max;
}

// ====================================
// 		give and cangive functions
// ====================================

give_default( item )
{
	return;	
}

cangive_default( item )
{
	return false;	
}

get_func_give( ref )
{
	AssertEx( IsDefined( ref ) && ref !="" , "The item ref name must be defined and not empty string." );
	
	if ( item_exist( ref ) )
		return level.collectibles[ ref ].func_give;

	func_give = ::give_default;
	
	switch ( ref )
	{
		case "item_flash_grenade_mp":
		case "item_frag_grenade_mp":
		case "item_c4_mp":
		case "item_alienclaymore_mp":
		case "item_bouncingbetty_mp":	
			func_give = ::give_offhand;
			break;

		case "item_shock_ammo":
			func_give = ::give_shock_ammo;
			break;
			
		case "item_health_pack":

		case "loot_blood_small":
		case "loot_blood_med":
		case "loot_blood_large":
		case "loot_blood_xl":
			func_give = ::give_loot_blood;
			break;		

		case "item_yellow_egg":
		case "item_green_egg":
		case "item_blue_egg":
		case "item_red_egg":	
		case "item_purple_egg":
		case "loot_teeth":
		case "loot_relic_1":
		case "loot_relic_2":
		case "item_revive_booster":
			func_give = ::give_loot_generic;
			break;		
		
		case "item_fast_legs_booster":
		case "item_fast_hands_booster"	:
		case "item_health_regen_booster":
			func_give = ::give_booster;
			break;
			
		case "item_alienpropanetank_mp":
		case "item_alienbattery_mp":
		case "item_aliengascan_mp":
			func_give = ::give_throwable_weapon;
			break;
		
		case "item_upgrade_station1":
		case "item_upgrade_station2":
			func_give = ::give_upgrade_station;
			break;
			
		default:
			//AssertMsg( "Unhandled item: " + ref + " is looking for func_give" );
			break;
	}

	if ( strtok( ref, "_" )[ 0 ] == "weapon" )
	{
		func_give = ::give_weapon;
	}
	
	return func_give;
}

get_func_cangive( ref )
{	
	AssertEx( IsDefined( ref ) && ref !="" , "The item ref name must be defined and not empty string." );
	
	if ( item_exist( ref ) )
		return level.collectibles[ ref ].func_cangive;

	func_cangive = ::cangive_default;

	switch ( ref )
	{
		case "item_flash_grenade_mp":
		case "item_frag_grenade_mp":
		case "item_c4_mp":
		case "item_alienclaymore_mp":
		case "item_bouncingbetty_mp":
			func_cangive = ::cangive_offhand;
			break;
			
		case "item_shock_ammo":
			func_cangive = ::cangive_shock_ammo;
			break;
			
		case "item_health_pack":
			
		case "loot_blood_small":
		case "loot_blood_med":
		case "loot_blood_large":
		case "loot_blood_xl":
			func_cangive = ::cangive_loot_blood;
			break;

		case "item_yellow_egg":
		case "item_green_egg":
		case "item_blue_egg":
		case "item_red_egg":	
		case "item_purple_egg":
		case "loot_teeth":
		case "loot_relic_1":
		case "loot_relic_2":
			func_cangive = ::cangive_loot_generic;
			break;
			
		case "item_revive_booster":
			func_cangive = ::cangive_self_revive;
			break;	
			
		case "item_fast_legs_booster":
		case "item_fast_hands_booster"	:
		case "item_health_regen_booster":
			func_cangive = ::cangive_booster;
			break;

		case "item_alienpropanetank_mp":
		case "item_alienbattery_mp":
		case "item_aliengascan_mp":
			func_cangive = ::cangive_throwable_weapon;
			break;

		case "item_upgrade_station1":
		case "item_upgrade_station2":
			func_cangive = ::cangive_upgrade_station;
			break;			
			
		default:
			//AssertMsg( "Unhandled item: " + ref + " is looking for func_give" );
			break;
	}
	
	if ( strtok( ref, "_" )[ 0 ] == "weapon" )
	{
		func_cangive = ::cangive_weapon;
	}
	
	return func_cangive;
}

// ====================================
// [offhand]
// ====================================
give_offhand( item )
{
	ref = item.item_ref;
	weapon_ref = getsubstr( ref, 5 );	// to remove "item_"
	
	if ( !self hasweapon( weapon_ref ) )
	{	
		if ( ref == "item_alienclaymore_mp" || ref == "item_c4_mp" || ref == "item_bouncingbetty_mp" )
		{
			self setOffhandPrimaryClass( "other" );
		}
		else
		{
			self setOffhandPrimaryClass( "frag" );	
		}
		
		self giveweapon( weapon_ref );
	}
	
	max_carry = get_maxstock( ref );
	self setweaponammostock( weapon_ref, max_carry );
}

cangive_offhand( item )
{
	ref = item.item_ref;	
	weapon_ref = getsubstr( ref, 5 );	// to remove "item_"
	
	max_carry = get_maxstock( ref );
	return self GetWeaponAmmoStock( weapon_ref ) < max_carry;
}

// ====================================
// [ammo]
// ====================================
give_ammo( item )
{
	ref = item.item_ref;	
	primary_weapons = self GetWeaponsListPrimaries();

	// give only stock not incomplete clips for all weapons
	foreach ( weapon in primary_weapons )
	{
		max_stock = WeaponMaxAmmo( weapon );
		self SetWeaponAmmoStock( weapon, max_stock );
	}
}

cangive_ammo( item )
{
	ref = item.item_ref;	
	primary_weapons = self GetWeaponsListPrimaries();
	
	foreach ( weapon in primary_weapons )
	{
		max_stock 		= WeaponMaxAmmo( weapon );
		player_stock 	= self getweaponammostock( weapon );
		
		if ( player_stock < max_stock )
		{
			return true;
		}
	}
	return false;
}

give_shock_ammo( item )
{ 
	ref = item.item_ref;
	currentweapon = self GetCurrentWeapon();
	shock_ammo_count = WeaponMaxAmmo( currentweapon );
	
	self give_loot( "item_shock_ammo", shock_ammo_count );
	
	primary_weapons = self GetWeaponsListPrimaries();
	foreach ( weapon in primary_weapons )
	{
		max_stock = WeaponMaxAmmo( weapon );
		self SetWeaponAmmoStock( weapon, max_stock );
	}
	self thread shock_ammo_tracker( shock_ammo_count );

}

cangive_shock_ammo( item )
{
	return true;
}
// ====================================
// [weapons]
// ====================================
give_weapon( item )
{
	ref = item.item_ref;
	weapon_ref = getsubstr( ref, 7 );	// to remove "weapon_"
	cost = item.data[ "cost" ];	
	
	// cost the purchaser
	self take_player_currency( cost );
	
	if( !self HasWeapon( weapon_ref ) )
	{
		cur_primary_weapon 	= self get_replaceable_weapon();
		
		if ( IsDefined( cur_primary_weapon ) )
		{
			cur_primary_clip 	= self GetWeaponAmmoClip( cur_primary_weapon );
			cur_primary_stock 	= self GetWeaponAmmoStock( cur_primary_weapon );
			
			// take away current primary weapon and spawn it on the ground where player is ---Only take the weapon now, do not spawn it on the ground.
			self TakeWeapon( cur_primary_weapon );
			
			dropped_weapon = spawn( "weapon_" + cur_primary_weapon, self.origin + ( 0, 0, 64 ) );
			dropped_weapon itemweaponsetammo( cur_primary_clip, cur_primary_stock );
		
			cur_primary_alt_weapon = weaponaltweaponname( cur_primary_weapon );
			if ( cur_primary_alt_weapon != "none" )
			{
				cur_primary_alt_clip 	= self GetWeaponAmmoClip( cur_primary_alt_weapon );
				cur_primary_alt_stock 	= self GetWeaponAmmoStock( cur_primary_alt_weapon );
	
				dropped_weapon itemweaponsetammo( cur_primary_alt_clip, cur_primary_alt_stock, cur_primary_alt_clip, 1 );
			}
			
		}
		
		//print3d( dropped_weapon.origin, "dropped weapon!", (1 ,1, 0), 0.5, 1, 200 );
		
		self giveweapon( weapon_ref );
		self SwitchToWeapon( weapon_ref );
	}
	else
	{
		max_stock = WeaponMaxAmmo( weapon_ref );
		self SetWeaponAmmoStock( weapon_ref, max_stock );
		self SwitchToWeapon( weapon_ref );
	}
}

get_replaceable_weapon()
{
	// if holding more than one weapon remove the current
	primary_weapons = self GetWeaponsListPrimaries();
	if ( primary_weapons.size > 1 )
	{
		current_weapon = self GetCurrentWeapon();
		if ( WeaponInventoryType( current_weapon ) == "altmode" )
		{
			current_weapon = get_weapon_name_from_alt( current_weapon ); 
		}
		// if current weapon held is a weapon that can be taken away
		if ( IsDefined( current_weapon ) && WeaponInventoryType( current_weapon ) == "primary" )
		{
			return current_weapon;
		}
		else
		{
			// find a primary weapon to take away
			weapon_list = self GetWeaponsList( "primary" );
			foreach ( weapon in weapon_list )
			{
				if ( WeaponClass( weapon ) != "item" )
					return weapon;
			}
		}
	}
	return undefined;
}

get_weapon_name_from_alt( weapon )
{
	if ( WeaponInventoryType( weapon ) != "altmode" )
	{
		assertmsg( "Get weapon name from alt called on non alt weapon." );
		return weapon;
	}
	
	// Assume alt weapon names are always in the format
	// of: "alt_iw5_scar_mp_m230"
	return GetSubStr( weapon, 4 );
}

cangive_weapon( item )
{
	ref = item.item_ref;	
	weapon_ref = getsubstr( ref, 7 );	// to remove "weapon_"
	currentweapon = self GetCurrentWeapon();
	if  ( !self is_holding_deployable() )
	{
		if( !self HasWeapon( weapon_ref ) )
		{
			return self player_has_enough_currency( item.data[ "cost" ] );
		}
		else
		{
			max_stock 		= WeaponMaxAmmo( weapon_ref );
			player_stock 	= self getweaponammostock( weapon_ref );
			
			if ( player_stock < max_stock )
			{
				return true;
			}
		}
	}
	
	return false;
}

give_throwable_weapon( item )
{
	ref = item.item_ref;	
	item_ref = getsubstr( ref, 5 );	// to remove "item_"
	
	self _giveWeapon( item_ref );
	self SwitchToWeapon( item_ref );
	self DisableWeaponSwitch();
	self displayThrowMessage();
}

cangive_throwable_weapon( item )
{
	ref = item.item_ref;	
	weapon_ref = getsubstr( ref, 5 );	// to remove "item_"
	
	if( !self HasWeapon( weapon_ref ) && !self is_holding_deployable() )
	{
		return true;
	}
	else
	{
		return false;
	}
}
// ====================================
// [upgrade stations]
// ====================================
give_upgrade_station( item )
{
    ref = item.item_ref;    
    item_ref = getsubstr( ref, 5 );    // to remove "item_"
    cost = item.data[ "cost" ];    

    // cost the purchaser
    self take_player_currency( cost );
    
    fullweaponname = self GetCurrentWeapon();
    baseweapon = GetWeaponBaseName( fullweaponname );
    newbaseweapon = GetWeaponBaseName( fullweaponname );
    attach1 = "none";
    attach2 = "none";    
    camo = 0;
    reticle = 0;
    
    if ( item_ref == "upgrade_station1" )
    {
        newbaseweapon    	= TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 16 );
        attach1     		= TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 17 );
        attach2     		= TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 18 );
        camo         		= int( TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 19 ) );
        reticle     		= int( TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 20 ) );
    }
    else if ( item_ref == "upgrade_station2" )
    {
        newbaseweapon   	= TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 21 );
        attach1     		= TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 22 );
        attach2     		= TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 23 );
        camo         		= int( TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 24 ) );
        reticle     		= int( TableLookUp( "mp/alien/collectibles.csv", 3, baseweapon, 25 ) );
    }
    
    if ( attach1 == "" )
    {
        attach1 = "none";
    }
    
    if ( attach2 == "" )
    {
        attach2 = "none";
    }
    
    weaponname = strip_suffix( newbaseweapon, "_mp" );
    newweapon = maps\mp\gametypes\_class::buildWeaponName( weaponname, attach1, attach2, camo, reticle );
    
    self TakeWeapon( fullweaponname );
    self GiveWeapon( newweapon );
    self GiveStartAmmo ( newweapon );
    self SwitchToWeapon( newweapon );
}

cangive_upgrade_station( item )
{
	weaponname = self GetCurrentWeapon();
	baseweapon = GetWeaponBaseName( weaponname );
	
	if ( self player_has_enough_currency( item.data[ "cost" ] ) && !self is_holding_deployable() )
	{
		switch ( baseweapon )
		{
			case "iw6_alienp226_mp":
			case "iw6_alienfp6_mp":
			case "iw6_alienm27_mp":
			case "iw6_alienmaul_mp":
			case "iw6_alienak12_mp":
			case "iw6_alienkriss_mp":
			case "iw6_alienhoneybadger_mp":
			case "iw6_alienmicrotar_mp":
			case "iw5_alienacr_mp":
			case "iw6_alienelephantgun_mp":
			case "iw6_alienmk32_mp":
			case "iw6_alienl115a3_mp":
			case "iw6_alienflamethrower_mp":
			case "iw6_alienlmg_mp":
			
				return true;
			default:
				IPrintLnBold( "Current weapon can't be upgraded" );
				return false;
		}
	}
	else
	{
		IPrintLnBold( "Can't afford the weapon upgrade" );
		return false;
	}
}

modify_sentry_setting()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	
	self waittill( "new_sentry", sentry_ent );
	
	// make sentries aim faster due to alien's higher speed
	sentry_ent SetConvergenceTime( 0.9, "pitch" );	
    sentry_ent SetConvergenceTime( 0.9, "yaw" );
    
    //sentry_ent SetLeftArc( 90 );
	//sentry_ent SetRightArc( 90 );
	//sentry_ent SetBottomArc( 30 );
	//sentry_ent SetTopArc( 60 );
	
	//sentry_ent thread sentry_timed_death( SENTRY_TIMEOUT );
}

any_player_near_sentry()
{
	return any_player_nearby( self.origin, SENTRY_MIN_KILL_DISTANCE_SQR );
}

// ====================================
// [healthpack]
// ====================================

give_health( item )
{
	ref = item.item_ref;
	
	give_health_by_ref( ref );
}

give_health_by_ref( ref )
{
	// overriding action slot 3 (dpad left) due to dpad left is for alt weapon only
	
	icon = "dpad_health_pack";
	
	/*
	if ( ref == "item_health_pills" )
	{
		// TODO need pills icon
		icon = "hint_pills";
	}*/
	
	// If we already have a health pack in kill_resource, go to full health
	if ( alien_mode_has( "kill_resource" ) && isDefined( self.has_health_pack ) && self.has_health_pack == true )
	{
		self.health = self.maxhealth;
		return;
	}
	
	self setWeaponHudIconOverride( "actionslot3", icon );
	self.has_health_pack = true;
	self.haveInvulnerabilityAvailable = true;
	self give_loot( "item_health_pack", 1 );
	self notifyonplayercommand( "use_health", "+actionslot 3" );

//	setLowerMessage( "use_health", &"ALIEN_COLLECTIBLES_USE_HEALTH_PACK", 3 );
	self thread health_listener( ref );
	
	//	No longer running this as we can self revive if we have a health pack and we die TODO: Remove this when proven self revive	
	//	self thread drop_health_on_death( ref );	
}

drop_health_on_death( ref )
{
	self endon( "remove_health_pack" );
	
	self waittill( "death" );
	
	// quickly grab last death pos before player updates this
	if ( isdefined( self.last_death_pos ) )
		pos = self.last_death_pos + level.loot_offset[ "health" ];
	else
		pos = self.origin + ( 0, 0, 64 );
	
	if ( !isdefined( self.has_health_pack ) || !self.has_health_pack )
		return;

	// clear lower message of health warnings
//	self thread clearLowerMessage( "use_health" );
//	self thread clearLowerMessage( "find_health" );
	
	self.has_health_pack = false;
	self setWeaponHudIconOverride( "actionslot3", "none" );

	// drops loot - health pack is (x) to pick up instead of proxy
	drop_loot( pos, ref, self, false );
}

can_use_health()
{
	/*
	if ( self is_holding_deployable() )
	{
		return false;
	}*/
	
	if ( isdefined( self.laststand ) && self.laststand )
	{
		return false;
	}
	
	if ( self.health == self.maxhealth )
	{
		return false;
	}
	
	if ( alien_mode_has( "kill_resource" ) && get_loot_count( "loot_blood_small" ) < COST_HEALTHPACK )
	{
		iprintln( "Not enough resources to use health." );
		return false;
	}
	
	return true;
}

health_listener( ref )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self waittill( "use_health" );
	
	// allow drop of health pack
	if ( self is_drop_button_pressed() )
	{
		if ( alien_mode_has( "kill_resource" ) )
		{
			if ( get_loot_count( "loot_blood_small" ) >= COST_HEALTHPACK )
			{
				// Drop the healthpack
				drop_loot( self.origin + ( 0, 0, 64 ), ref, self, false );
				take_loot( "loot_blood_small", COST_HEALTHPACK );
				self thread health_listener( ref );
				return;
			}
		}
		else
		{
			// clear lower message of health warnings
//			self thread clearLowerMessage( "use_health" );
//			self thread clearLowerMessage( "find_health" );
			
			self.has_health_pack = false;
			self setWeaponHudIconOverride( "actionslot3", "none" );
		
			// drops loot - health pack is (x) to pick up instead of proxy
			drop_loot( self.origin + ( 0, 0, 64 ), ref, self, false );
			self take_loot( "item_health_pack", 1 );
			self notify( "remove_health_pack" );
		}
		return;
	}
	
	// cant use health when in laststand or health is full!
	if ( !self can_use_health() )
	{
		self PlayLocalSound( "alien_killstreak_empty" );
		//IPrintLn( "You have full health!" );
		wait 0.05;
		
		self thread health_listener( ref );
		return;
	}	
	
	// health USED!!!
	self PlayLocalSound( "alien_killstreak_equip" );
	self setWeaponHudIconOverride( "actionslot3", "none" );
	self.has_health_pack = false;
	self take_loot( "item_health_pack", 1 );
	
	// TODO: new sounds for healing
	self PlaySound( "juggernaut_breathing_sound" );
	
	// TODO: need mp's flashing red player pain
	/*
	if ( self ent_flag( "player_has_red_flashing_overlay" ) )
	{
		maps\_gameskill::player_recovers_from_red_flashing();
	}
	*/
	
/#
	if ( GetDvarint( "player_infinite_healthpacks" ) > 0 )
	{
		self give_health_by_ref( "item_health_pack" );
	}
#/

	// TODO logic for pills healing only partial
	/*
	pills_heal_frac = 0.25;
	if ( ref == "item_health_pills" )
	{
		cur_health = self.health;
		max_health = self.maxhealth;
		self.health = min( max_health, cur_health + ( pills_heal_frac * max_health ) );
	}
	*/
	
	// TODO: figure out health kit heal amount, maybe always 80%?
	//self.health += ( self.maxhealth - self.health ) * 0.8;
	self.health = self.maxhealth;
	
	/#
	if ( getdvarint( "debug_collectibles" ) == 1 )
		IPrintLn( "[item_health_pack] applied" );
	#/
		
	// clear lower message of health warnings
//	self thread clearLowerMessage( "use_health" );
//	self thread clearLowerMessage( "find_health" );
		
	self notify( "remove_health_pack" );
	
	self maps\mp\gametypes\aliens::player_gain_lastStand();

	if ( alien_mode_has( "kill_resource" ) )
	{
		self take_loot( "loot_blood_small", COST_HEALTHPACK );
		self give_health_by_ref( "item_health_pack" );
	}
	
}

cangive_health( item )
{
	//turning this off as it's no longer in the kill resource system BB TODO: properly remove the health packs
	
	return false; //dump out early
/*		
	ref = item.item_ref;
		
	if ( alien_mode_has( "kill_resource" ) )
	{
		return true;
	}
	
	// does player already have item in dpad left
	override = self GetWeaponHudIconOverride( "actionslot3" );
	if ( isdefined( override ) && override != "none" )
	{
//		setLowerMessage( "use_health", &"ALIEN_COLLECTIBLES_USE_HEALTH_PACK", 3 );
		return false;
	}
	
	return true;
*/	
}

// ====================================
// [explosives]
// ====================================
give_slotted_explosive( item )
{
	ref = item.item_ref;
	
	ammo_added		= 5;
	ammo_curr		= 0;
	extra_clip		= 0;
	slot 			= 1;
	
	weapon_ref 		= getsubstr( ref, 5 );	// to remove "item_"
	
	if( !self HasWeapon( weapon_ref ) )
	{
		if ( ref == "item_alienclaymore_mp" )
		{
			self SetOffhandPrimaryClass( "other");
			self _giveWeapon( "alienclaymore_mp", 0 );
//			slot = 1;
			
			// -.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.-
			// In TU update claymore was changed to a clip only weapon. This
			// means getammostock actually returns the clip count. Because of
			// this no extra clip ammo needs to be considered.
			
//			// claymore has 1 ammo in clip the moment its given to player,
//			// we need to give one less for stock to give the correct total amount.
//			extra_clip = 1;
			// -.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.-
		}
		else if ( ref == "item_c4_mp" )
		{
			slot = 2;
		}

		self GiveWeapon( weapon_ref );
		self SetActionSlot( slot, "weapon", weapon_ref );
	}
	else
	{
		ammo_curr = self GetWeaponAmmoStock( weapon_ref );
	}

	// -.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.-
	// In TU update claymore was changed to a clip only weapon. This
	// means getammostock actually returns the clip count. Because of
	// this no extra clip ammo needs to be considered.
	
//	// edge case where claymore clip is 0 and stock is 9,
//	// giving more stock will not increase total ammo, we need to give 1 clip
//	if ( ref == "claymore" && self getweaponammoclip( ref ) == 0 )
//	{
//		self SetWeaponAmmoclip( ref, 1 );
//		ammo_added--;
//	}
	// -.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.--.-.-.-

	// TO DO: C4s can be exploited by throwing them but not detonating them, then buy more.
	// Since we aren't tracking how many C4s are alive in the world,
	// players can buy infinite C4s then detonate all at once, BOOM!
	self SetWeaponAmmoStock( weapon_ref, ammo_curr + ammo_added - extra_clip );
}

cangive_slotted_explosive( item )
{
	ref = item.item_ref;
	weapon_ref = getsubstr( ref, 5 );	// to remove "item_"
	
	if ( self HasWeapon( weapon_ref ) )
	{
		// Claymore's clip and stock are the same thing
		if ( ref == "item_alienclaymore_mp" )
		{
			total 	= self getweaponammostock( weapon_ref );
			return 	( level.collectibles[ ref ].player_max != total );
		}

		// C4's clip and stock are the same thing
		if ( ref == "item_c4_mp" )
		{
			total 	= self getweaponammostock( weapon_ref );
			return 	( level.collectibles[ ref ].player_max != total );
		}
	}

	return true;
}

// ====================================
// [booster]
// ====================================
give_booster( item )
{
	ref = item.item_ref;
//	self give_loot( ref, 1 );
	
	switch ( ref )
	{		
		case "item_fast_legs_booster":
			self thread player_fast_legs_booster( 30 );
			break;
		case "item_fast_hands_booster":
			self thread player_fast_hands_booster( 30 );
			break;		
		case "item_health_regen_booster":
			self thread player_health_regen_booster( 30 );
			break;				
			
		default:
			//AssertMsg( "Unhandled item: " + ref + " is looking for func_give" );
			break;
	}
}
 
cangive_booster( item )
{
	ref 				= item.item_ref;
	owner 				= item.item_ent.loot_owner;
	
	if ( isDefined( self.isBoosted ) )
		return false;
	
	if ( !isdefined( owner ) || isdefined( owner ) && owner == self )
		return true;
	
	collection_timeout	= item.loot_collection_timeout;

	if ( isdefined( item.loot_collection_timeout ) &&  item.loot_collection_timeout <= 0 )
		return true;

	return false;
}

try_drop_loot( eAttacker )
{
	loot_owner = undefined;
		
	if ( isdefined( eAttacker ) ) 
	{
		if ( isplayer( eAttacker ) )
		{
			loot_owner = eAttacker;
		}
		else
		{
			if ( isdefined( eAttacker.owner ) && isPlayer( eAttacker.owner ) )
				loot_owner = eAttacker.owner;
		}
	}
	
	assert( isdefined( level.alien_loot_initialized ) );
	
	if ( isdefined( loot_owner ) && IsPlayer( loot_owner ) )
	{
		// returns array of loot drop chances, index = loot reference string, value = chance (float)
		loots_array = self maps\mp\alien\_director::get_loot_array();
		
		loot_dropped = 0;		
		foreach( loot_ref, loot_chance in loots_array )
		{
			if ( loot_chance > randomfloat( 1 ) )
			{
				loot_dropped++;
				thread drop_loot( self.body.origin, loot_ref, loot_owner, true, 30, true );
			}
		}
	}	
}

//==================================================================================
// 								COLLECTIBLE LOOTS
//==================================================================================

// drop_loot( position, reference string, owner, touch pickup method, loot timeout )
drop_loot( pos, ref, owner, touch, timeout, auto_pickup )
{
	if ( !alien_mode_has( "loot" ) )
		return;
	
	// auto pickup logic
	if ( isdefined( auto_pickup ) && auto_pickup )
	{
		item 						= SpawnStruct();
		item.item_ref 				= ref;
		item.item_ent 				= spawn( "script_model", pos );
		item_model 					= "tag_origin"; //level.collectibles[ ref ].model;	
		item.item_ent 				SetModel( item_model );
		item.item_ent.loot_owner 	= owner;
		
		if ( owner [[ get_func_cangive( ref ) ]]( item ) )
		{
			owner [[ get_func_give( ref ) ]]( item );
			owner notify( "loot_pickup" );
		}
		
//		item.item_ent thread sendLootToPlayer( pos + ( 0, 0, 80 ) );
		return;
	}
		
	// create world item "script model" only used as a container
	item					= spawn( "script_model", pos );
	item 					SetModel( "tag_origin" );
	item.angles				= ( 0, 0, 0 );
	item.item_ref			= ref;
	item 					setup_item_data();
	
	if ( is_collectible_item( ref ) || is_collectible_weapon( ref ) )
		item.spawn_loot_fx = true;
	
	// spawn the loot and listen for pickup or timeout
	item spawn_loot( owner );
	
	if ( !isdefined( touch ) )
		touch = false;
	
	item thread loot_pickup_listener( owner, touch );
	
	if ( isdefined( timeout ) && timeout )
		item thread loot_pickup_timeout( owner, timeout );
	
	/#
		if ( getdvarint( "debug_collectibles" ) == 1 )
		{
			player_name = "unknown player";
			if ( isdefined( owner ) && isplayer( owner ) && isdefined( owner.name ) )
				player_name = owner.name;
			
			iprintln( player_name + "'s loot [" + item.item_ref + "] spawned at: " + item.origin );
		}
	#/
}

setup_player_loot( ref )
{
	// self is player
	
	loot 		= SpawnStruct();
	loot.count 	= 0;
	
	self.lootbag[ ref ] = loot;
}

has_loot( ref )
{
	if ( isdefined( self.lootbag[ ref ] ) && self.lootbag[ ref ].count > 0 )
		return true;
	
	return false;
}

get_loot_count( ref )
{
	if ( self has_loot( ref ) )
	{
		return self.lootbag[ ref ].count;
	}
	else
	{
		return 0;	
	}
}

// returns remaining loot count
take_loot( ref, count )
{
	if ( self has_loot( ref ) )
	{
		self.lootbag[ ref ].count -= count;
		
		self notify( "loot_removed" );
		
		if ( self.lootbag[ ref ].count <= 0 )
		{
		    self.lootbag[ ref ] = undefined;
		    return 0;
		}
		else
		{
			return self.lootbag[ ref ].count;
		}
	}
	else
	{
		return 0;
	}	
}

// returns final count
give_loot( ref, count )
{
	if ( has_loot( ref ) )
	{
		self.lootbag[ ref ].count += count;
	}
	else
	{
		self setup_player_loot( ref );
		self.lootbag[ ref ].count = count;
	}

	if ( alien_mode_has( "kill_resource" ) && ref == "loot_blood_small" )
	{
		self maps\mp\alien\_gamescore::givePlayerScore( count );
		
		self give_player_currency( count );
		
		if ( count > 0 )
			thread flash_credit_gain( count );
	}
	
	// give xp
	if ( isdefined( level.alien_xp ) && ref == "loot_blood_small" )
	{
		self give_player_xp( count );
	}
	
	// TEMP method of communcation to menus by updating money dvar
	if ( isdefined( level.armory_items ) )
	{
		switch ( ref )
		{
			case "loot_blood_small":
				maps\mp\alien\scripts\_alien_armory::updatePlayerLootDvar("ui_player_money", "loot_blood_small" );
				break;	
			case "item_yellow_egg":
				maps\mp\alien\scripts\_alien_armory::updatePlayerLootDvar("ui_player_yellow_eggs", "item_yellow_egg");
				break;
			case "item_green_egg":
				maps\mp\alien\scripts\_alien_armory::updatePlayerLootDvar("ui_player_green_eggs", "item_green_egg");
				break;
			case "item_red_egg":
				maps\mp\alien\scripts\_alien_armory::updatePlayerLootDvar("ui_player_red_eggs", "item_red_egg");
				break;
			case "item_blue_egg":
				maps\mp\alien\scripts\_alien_armory::updatePlayerLootDvar("ui_player_blue_eggs", "item_blue_egg");
				break;
			case "item_purple_egg":			
				maps\mp\alien\scripts\_alien_armory::updatePlayerLootDvar("ui_player_purple_eggs", "item_purple_egg");
				break;				
			default:
				//AssertMsg( "Unhandled item: " + ref + " is looking for func_give" );
				break;
		}
	}
	
	return self.lootbag[ ref ].count;
}

update_hint( available_credit, cost_requirement, hud_element )
{
	if ( available_credit >= cost_requirement	)
		hud_element.alpha = 1;
	else
		hud_element.alpha = 0;
}

flash_credit_gain( amount )
{	
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self notify( "kill_credit_flash" );
	self endon( "kill_credit_flash" );
	
	self.gain_credit_message setvalue( amount );
	self.gain_credit_message.alpha = 1;
	self.gain_credit_message fadeOverTime( 0.30 );
	self.gain_credit_message.alpha = 0;
}

sendLootToPlayer( pos )
{
	self endon( "death" );
	
	travel_time 	= 0.75;
	
	/#
		accel 			= 0.25;
		decel			= 0.25;
		rot_speed 		= 720;
	
		self RotateVelocity( ( 0, rot_speed, 0 ), travel_time );
		self MoveTo( pos, travel_time, accel, decel );
	#/
		
	wait travel_time;
	self delete();
}

// ====================================
// [loot:bloods]
// ====================================

give_loot_blood( item )
{
	ref = item.item_ref;
	
	// TODO: maybe blood count is from the stringtable instead of defined here.
	blood_count = 0;
	if ( ref == "loot_blood_small" )
		blood_count = 100;
	if ( ref == "loot_blood_med" )
		blood_count = 200;
	if ( ref == "loot_blood_large" )
		blood_count = 700;
	if ( ref == "loot_blood_xl" )
		blood_count = 1500;
	
	self give_loot( "loot_blood_small", blood_count );
}

cangive_loot_blood( item )
{
	ref 				= item.item_ref;
	owner 				= item.item_ent.loot_owner;
	
	if ( !isdefined( owner ) || (isdefined( owner ) && owner == self ) )
		return true;
	
	collection_timeout	= item.loot_collection_timeout;
	
	if ( isdefined( item.loot_collection_timeout ) && item.loot_collection_timeout <= 0 )
		return true;
	
	return false;
}

give_loot_generic( item )
{
	ref = item.item_ref;
	self give_loot( ref, 1 );
}
 
cangive_loot_generic( item )
{
	ref 				= item.item_ref;
	owner 				= item.item_ent.loot_owner;
	
	if ( !isdefined( owner ) || (isdefined( owner ) && owner == self ) )
		return true;
	
	collection_timeout	= item.loot_collection_timeout;
	
	if ( isdefined( item.loot_collection_timeout ) && item.loot_collection_timeout <= 0 )
		return true;

	return false;
}

cangive_self_revive( item )
{
	ref 				= item.item_ref;
	owner 				= item.item_ent.loot_owner;
	
	revive_carry_limit = 2;
	revive_booster_count = self get_loot_count( "item_revive_booster" );
	collection_timeout	= item.loot_collection_timeout;
	
	if ( !isdefined( owner ) || (isdefined( owner ) && owner == self ) )
	{
		if ( revive_booster_count < ( revive_carry_limit ) )
		{
			revive_booster_count = revive_booster_count + 1;
			return true;
		}
		else
		{
			return false;
		}
	}
		
	if ( isdefined( item.loot_collection_timeout ) && item.loot_collection_timeout <= 0 )
	{
		if ( revive_booster_count < ( revive_carry_limit ) )
		{
			revive_booster_count = revive_booster_count + 1;
			return true;
		}
		else
		{
			return false;
		}
	}

	return false;
}

is_drop_button_pressed()
{
	return self SecondaryOffhandButtonPressed();
}

// returns true if player is holding bomb/deployables
is_holding_deployable()
{
	current_weapon = self GetCurrentWeapon();
	
	if ( current_weapon == "alienclaymore_mp" || current_weapon == "bouncingbetty_mp" || current_weapon == "alientrophy_mp" || current_weapon == "alienbomb_mp" || current_weapon == "deployable_vest_marker_mp" || current_weapon == "iw5_alienriotshield_mp" )
		return true;

	if ( isdefined( self.isCarrying ) && self.isCarrying )
	{
		return true;
	}
	
	return false;

}

//==================================================================================
// 									LOOT BOXES
//==================================================================================

TABLE_LOOTBOX_INDEX				= 0;
TABLE_LOOTBOX_REF				= 1;
TABLE_LOOTBOX_ITEM_START_COL 	= 2;

lootbox_world_init()
{
	assertex( isdefined( level.collectibles ), "Collectibles not initialized" );
	
	level.world_lootboxes = [];	

	all_boxes = getentarray( "lootbox", "targetname" );
	
	if ( !isdefined( all_boxes ) || all_boxes.size == 0 )
		return;
	
	foreach ( lootbox in all_boxes )
	{
		assertex( isdefined( lootbox.script_noteworthy ), "lootbox is missing script_noteworthy for defining tier" );
		lootbox.tier = lootbox.script_noteworthy;
		
		if ( !isdefined( level.world_lootboxes[ lootbox.tier ] ) )
			level.world_lootboxes[ lootbox.tier ] = [];
		
		// this is the script model of the box "closed"
		level.world_lootboxes[ lootbox.tier ][ level.world_lootboxes[ lootbox.tier ].size ] = lootbox; 
		
		lootbox thread setup_lootbox();
	}
}

setup_lootbox()
{
	// self is lootbox script model "closed"
	self.opened_model = getent( self.target, "targetname" );
	
	msg = "There can only be one opened script_model targeted by the lootbox script_model with script_noteworthy = opened";
	assertex( isdefined( self.opened_model ) && isdefined( self.opened_model.script_noteworthy ) && self.opened_model.script_noteworthy == "opened", msg );
	
	self.opened_model hide();
	
	self.item_locs = [];
	self.item_locs = getstructarray( self.target, "targetname" );
	
	msg = "Missing item_loc struct with script_noteworthy = item_loc";
	assertex( isdefined( self.item_locs ) && self.item_locs.size, msg );
	
	self thread lootbox_listener();
}

lootbox_listener()
{
	// self is lootbox script_model
	level endon ( "game_ended" );
	
	// setup usable for self
	self SetCursorHint( "HINT_NOICON" );
	self SetHintString( &"ALIEN_COLLECTIBLES_OPEN" );
	self MakeUsable();
	
	while ( isdefined( self ) )
	{
		self waittill( "trigger", owner );
		
		if ( !isdefined( owner ) || !isplayer( owner ) )
		{
			wait 0.05;
			continue;
		}
		
		// swap model
		self.opened_model show();
		
		self thread spawn_items_inside_lootbox( owner );
		
		self hide();
		self MakeUnUsable();
		self delete();
		
		return;
	}
}

spawn_items_inside_lootbox( owner )
{
	// added loots into dice array for random picking
	dice = [];
	foreach ( item in level.lootboxes[ self.tier ].loots )
	{
		// add multiple instance of the same loot based on chance defined in table
		for ( j = 0; j < item.chance; j++ )
			dice[ dice.size ] = item.item_ref;
	}
	
	for ( i = 0; i < self.item_locs.size; i++ )
	{
		// select item based on defined chance score in string table
		item_ref = dice[ RandomIntRange( 0, dice.size ) ];
		
		drop_loot( self.item_locs[ i ].origin, item_ref, owner, false );
		
		/#
		IPrintLn( "Lootbox[" + self.tier + "] spawned: " + item_ref );
		#/
	}
}


lootbox_table_init( index_start, index_end )
{
	level.lootboxes = [];
	
	for ( i = index_start; i < index_end; i++ )
	{	
		box 		= SpawnStruct();
		box.ref		= TableLookup( COLLECTIBLES_TABLE, TABLE_LOOTBOX_INDEX, i, TABLE_LOOTBOX_REF );
		
		if ( box.ref == "" )
			break;
		
		box.loots 	= [];
		
		box.total_chance = 0;

		for ( j = TABLE_LOOTBOX_ITEM_START_COL; j < TABLE_LOOTBOX_ITEM_START_COL + 8; j++ )
		{
			item_ref_chance_string = TableLookup( COLLECTIBLES_TABLE, TABLE_LOOTBOX_INDEX, i, j );
			
			// end of item columns
			if ( item_ref_chance_string == "" )
				break;
			
			item_ref_chance 	= [];
			item_ref_chance 	= StrTok( item_ref_chance_string, " " );
			
			assertex( item_ref_chance.size == 2, "Lootbox item defined should have item_ref and count delimited by a space" );
			
			item 						= SpawnStruct();
			item.item_ref 				= item_ref_chance[ 0 ];
			item.chance 				= int( item_ref_chance[ 1 ] );
			
			box.total_chance 			+= item.chance;
			box.loots[ box.loots.size ] = item;
		}

		level.lootboxes[ box.ref ] = box;
	}
}

//==================================================================================
// 							PROPANE TANK WEAPON
//==================================================================================

watchThrowableItems()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	
	itemTeam = self.pers["team"];
	
	while ( 1 )
	{
		self waittill( "grenade_fire",throwableitem, weapname );
		
		if ( isThrowableItem( weapname ) )
		{
			self TakeWeapon( weapname );
			self EnableWeaponSwitch();
			throwableitem delete();
			
			level thread watchThrowableItemStopped( weapname, itemTeam, self getEye(), self getPlayerAngles(), self );
		}
	}
}

watchThrowableItemStopped( weapname, itemTeam, playerEye, playerAngles, ignoreEntity )
{
	level endon( "game_ended" );
	
	waitframe();  // wait for the grenade item to be deleted
	
	item_data = level.throwable_items[ weapname ];
	
	forward_direction = anglesToForward( playerAngles );
	spawnAngles = anglesToUp( playerAngles );   // temp. This is for the propane to fly out sideway. Need an university method
	
	spawnPos = bulletTrace( playerEye,playerEye + forward_direction * 30, true, ignoreEntity );
	physics_model = spawn( "script_model", spawnPos[ "position" ] );
	physics_model.angles = vectorToAngles( spawnAngles );
	physics_model setmodel( item_data.model );
	
	add_to_thrown_entity_list( physics_model );
	physics_model thread clean_up_on_death();
	
	waitframe();  // wait for the angles to be set before applying physics
	
	physics_model PhysicsLaunchServer( ( 0,0,0 ), forward_direction * item_data.force );

	wait ( 0.5 );  // There is no good notify to wait for.  "physics_finished" is too late.
	
	physics_model thread explodeOnDamage();
	
	if ( item_data.canBePickedUp )
	{
		make_item_ent_useable( physics_model, item_data.hintString );
		physics_model thread [[item_data.pickUpFunc]]( weapname );
	}
}

add_to_thrown_entity_list( item )
{
	level.thrown_entities[ level.thrown_entities.size ] = item;
}

clean_up_on_death()
{
	level endon( "game_ended" );
	self waittill( "death" );
	level.thrown_entities = array_remove( level.thrown_entities, self );
}

propaneTankWatchUse( weapname )
{
	level endon( "game_ended" );
	self endon( "death" );
	
	while ( true )
	{
		self waittill ( "trigger", player );
		
		if ( !isPlayer ( player ) )
			continue;
		
		break;
	}
	
	player playLocalSound( "scavenger_pack_pickup" );
	player _giveWeapon( weapname );
	player SwitchToWeapon( weapname );
	player DisableWeaponSwitch();
	player displayThrowMessage();
		
	self delete();
}

isThrowableItem( weaponName )
{
	return isDefined( level.throwable_items[ weaponName ] );
}

displayThrowMessage()
{
	self setLowerMessage( "throw_item", &"ALIEN_COLLECTIBLES_THROW_ITEM", 3 );
}

explodeOnDamage()
{
	self endon( "death" );

	self setcandamage( true );
	self.maxhealth = 100000;
	self.health = self.maxhealth;

	while ( true )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );
		
		if ( !isPlayer ( attacker ) )
			continue;
		
		break;
	}
	
	PlayFx( level._effect[ "Propane_explosion" ], drop_to_ground( self.origin ) );
	RadiusDamage( self.origin, 256, 1000, 250, attacker );
	self Playsound( "grenade_explode_metal" );
		
	self thread fireCloudMonitor( level.fireCloudDuration, self.origin, attacker  );
		
	self delete();
}

fireCloudMonitor( duration, position, attacker )
{
	fireCloudRadius = level.fireCloudRadius;
	fireCloudHeight = level.fireCloudHeight;
	fireCloudTickDamage = level.fireCloudTickDamage;
	fireCloudPlayerTickDamage = level.fireCloudPlayerTickDamage;

	// spawn trigger radius for the effect areas
	fireEffectArea = spawn( "trigger_radius", position, 0, fireCloudRadius, fireCloudHeight );
	fireEffectArea.owner = self.owner;

	gasFire = SpawnFx( level._effect[ "Fire_Cloud" ], position );
	triggerFx( gasFire );
		
	fireTotalTime = 0.0;		// keeps track of the total time the fire cloud has been "alive"
	fireTickTime = 1.0;		// fire cloud ticks damage every second
	fireInitialWait = 1.5;	// wait this long before the cloud starts ticking for damage
	fireTickCounter = 0;		// just an internal counter to count fire damage ticks
	
	wait(fireInitialWait );
	fireTotalTime +=fireInitialWait;
	
	for( ;; )
	{
		if( fireTotalTime >= duration )
		{
			break;
		}
		//apply shellshock/damage fx to aliens in the fire cloud
		foreach ( agent in level.agentArray )
		{	
	    	if( isalive(agent) && agent istouching( fireEffectArea ) )
			{
				agent DoDamage( fireCloudTickDamage, position, attacker );
//				agent thread alien_on_fire( duration ); 
			}
		}
	    //apply shellshock/damage fx to players in the fire cloud
	    foreach ( player in level.players )
		{	
	    	if( isalive(player) && player istouching( fireEffectArea ) )
			{
				player DoDamage( fireCloudPlayerTickDamage, position );
			}
		}
	    	    
		wait( fireTickTime );
		fireTotalTime += fireTickTime;
		fireTickCounter += 1;
	}

	//clean up
	fireEffectArea delete();
	gasfire delete();
}

//======Not used yet, need to turn on flames on alien when damaged by fire
 
alien_on_fire( time )
{
	self endon( "death" );
	self notify( "alien_on_fire" );
	
	//wait 1.5;
	PlayFXOnTag( level._effect[ "Alien_On_Fire" ], self, "tag_origin" );
	wait 1.5;
	self thread alien_fire_off_on_death();
	self thread alien_fire_off( time );
}

alien_fire_off_on_death()
{
	while ( isdefined( self ) && isalive( self ) )
	{
		amount = 0;
		self waittill( "alien_killed" );
		KillFXOnTag( level._effect[ "Alien_On_Fire" ], self,"tag_origin" );
	}
}


alien_fire_off( time )
{
	wait ( time - 1.5 );
	KillFXOnTag( level._effect[ "Alien_On_Fire" ], self,"tag_origin" );
}


//==================================================================================
// 							SHOCK AMMO
//==================================================================================
shock_ammo_tracker( shock_ammo_count )
{
	self givePerk( "specialty_explosivebullets", false );
	self givePerk( "specialty_bulletdamage", false );
	
	for (i = 0; i <= shock_ammo_count; i++ )
	{
	 	self waittill( "weapon_fired" );
		take_loot( "item_shock_ammo", 1);
	}
	self _unsetPerk( "specialty_explosivebullets" );
	self _unsetPerk( "specialty_bulletdamage" );
}

handle_cycle_end()
{
	next_cycle = level.current_cycle_num+1;
	if ( level.world_areas_by_cycle.size > next_cycle )
	{
		this_area = get_area_for_cycle( level.current_cycle_num );
		next_area = get_area_for_cycle( next_cycle );
		if ( this_area != next_area )
		{
			remove_items_in_area( this_area );
			remove_thrown_entity_in_area( this_area );
			spawn_items_in_area( next_area );
		}
	}
}

remove_thrown_entity_in_area( area )
{
	foreach( thrown_entity in level.thrown_entities )
	{
		entity_in_areas = thrown_entity get_item_areas();
		
		if ( array_contains( entity_in_areas, area ) )
		{
			level.thrown_entities = array_remove( level.thrown_entities, thrown_entity );
			thrown_entity delete();
		}
	}
}
