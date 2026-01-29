#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\_utility;

director_main()
{
	// Handle wave enemy and item spawning and manage overall game intensity
}

// ================================================================
//						Alien Wave Spawn Table
// ================================================================

WAVE_TABLE					= "mp/alien/default_wave_spawn.csv";	// AI and wave data tablelookup
TABLE_WAVE_DEF_INDEX		= 99;	// Max index used for wave definition

TABLE_INDEX					= 0;	// Indexing
TABLE_STRONGHOLD			= 1;	// Stronghold
TABLE_CYCLE					= 2;	// cycle number
TABLE_TYPES_WAVE1			= 3;	// Wave 1's AI types
TABLE_COUNT_WAVE1			= 4;	// wave 1's AI spawn counts
TABLE_TYPES_WAVE2			= 5;	// Wave 2's AI types
TABLE_COUNT_WAVE2			= 6;	// Wave 2's AI spawn counts
TABLE_TYPES_WAVE3			= 7;	// Wave 3's AI types
TABLE_COUNT_WAVE3			= 8; 	// Wave 3's AI spawn counts
TABLE_TYPES_WAVE4			= 9;	// Wave 4's AI types
TABLE_COUNT_WAVE4			= 10;	// Wave 4's AI spawn counts
TABLE_TYPES_WAVE5			= 11;	// Wave 5's AI types
TABLE_COUNT_WAVE5			= 12;	// Wave 5's AI spawn counts
TABLE_REPEAT				= 13;	// Wave repeat pattern enable

// Populates wave spawn table entries into arrays
wave_spawn_table_init()
{
	// level.alien_spawn_table can be used to override default table, should be set before _alien::main()
	if ( !isdefined( level.alien_wave_table ) )
		level.alien_wave_table = WAVE_TABLE;
	
	// main wave spawning matrix sorted by strongholds
	level.strongholds = [];

	for ( i = 0; i <= TABLE_WAVE_DEF_INDEX; i++ )
	{
		name = get_stronghold_by_index( i );
		
		if ( name == "" ) { break; }
		
		if ( !isdefined( level.strongholds[ name ] ) )
		{	
			stronghold = spawnstruct();
			stronghold.cycles = [];
			stronghold.cycles = get_cycles_array( name );
			
			level.strongholds[ name ] = stronghold;
		}
	}
	
	// initialize first wave data from table
	// level.alien_wave_status is used for tracking current wave data
	level.alien_wave_status 					= [];
	level.alien_wave_status[ "wave" ] 			= 1;
	level.alien_wave_status[ "cycle" ] 			= int( tablelookup( level.alien_wave_table, TABLE_INDEX, 0, TABLE_CYCLE ) );
	level.alien_wave_status[ "stronghold" ] 	= tablelookup( level.alien_wave_table, TABLE_INDEX, 0, TABLE_STRONGHOLD );
	
	level notify( "alien_wave_spawn_initialized" );
}

get_cycles_array( stronghold )
{
	waves 	= [];
	cycles 	= [];
	
	for ( i = 0; i <= TABLE_WAVE_DEF_INDEX; i++ )
	{
		if ( stronghold != get_stronghold_by_index( i ) )
			continue;
		
		// wave data table lookups for predefined waves 1 2 3 4 5
		waves[ 1 ] = get_wave_data( i, TABLE_TYPES_WAVE1, TABLE_COUNT_WAVE1 );
		waves[ 2 ] = get_wave_data( i, TABLE_TYPES_WAVE2, TABLE_COUNT_WAVE2 );
		waves[ 3 ] = get_wave_data( i, TABLE_TYPES_WAVE3, TABLE_COUNT_WAVE3 );
		waves[ 4 ] = get_wave_data( i, TABLE_TYPES_WAVE4, TABLE_COUNT_WAVE4 );
		waves[ 5 ] = get_wave_data( i, TABLE_TYPES_WAVE5, TABLE_COUNT_WAVE5 );
		
		cycle 					= spawnstruct();	// struct for per cycle data
		cycle.waves 			= waves;			// waves data array
		cycle.repeat 			= int( tablelookup( level.alien_wave_table, TABLE_INDEX, i, TABLE_REPEAT ) );
		cycle_num 				= get_cycle_by_index( i );
		cycles[ cycle_num ] 	= cycle;			// populate data into cycles array
	}
	return cycles;
}

get_wave_data( index, table_wave_type, table_wave_count )
{
	// wave data table lookups for predefined waves 1 2 3 4 5
	types_array = strTok( tablelookup( level.alien_wave_table, TABLE_INDEX, index, table_wave_type ), " " );
	
	// wave not defined
	if ( types_array.size < 1 )
		return undefined;
	
	count_array = strTok( tablelookup( level.alien_wave_table, TABLE_INDEX, index, table_wave_count ), " " ); 

	wave 						= SpawnStruct();	// struct for per wave data
	wave.types_array			= types_array;
	wave.types 					= [];

	foreach ( index, wave_type in types_array )
	{
		type 					= SpawnStruct();	// struct for per AI type data
		type.name 				= wave_type;
		type.count 				= int( count_array[ index ] );
		wave.types[ wave_type ] = type;
	}
	
	return wave;
}

// Reference: tablelookup( stringtable path, search column, search value, return value at column );

get_stronghold_by_index( index )
{
	return tablelookup( level.alien_wave_table, TABLE_INDEX, index, TABLE_STRONGHOLD );	
}

get_cycle_by_index( index )
{
	return int( tablelookup( level.alien_wave_table, TABLE_INDEX, index, TABLE_CYCLE ) );	
}

// ================================================================
//						Alien Attribute Table
// ================================================================

ATTRIBUTE_TABLE				= "mp/alien/default_alien_definition.csv";

TABLE_COL_INDEX				= 0;
TABLE_COL_ATTRIBUTE			= 1;
TABLE_COL_AI_TYPE1			= 2;
TABLE_COL_AI_TYPE2			= 3;
TABLE_COL_AI_TYPE3			= 4;
TABLE_COL_AI_TYPE4			= 5;
TABLE_COL_AI_TYPE5			= 6;
TABLE_COL_AI_TYPE6			= 7;
TABLE_COL_AI_TYPE7			= 8;
TABLE_COL_BOSS_TYPE1		= 9;

alien_attribute_table_init()
{
	// to be updated with default_alien_definition.csv
	// value variable type is defined in index values
	
	att_idx						= [];
	att_idx[ "ref" ] 			= "0";	// string value
	att_idx[ "name" ] 			= "1";
	att_idx[ "model" ]			= "2";
	att_idx[ "desc" ] 			= "3";
	att_idx[ "boss" ] 			= 4;	// int value
	
	att_idx[ "health" ] 		= 10;
	att_idx[ "min_cumulative_pain_threshold" ] = 11;
	att_idx[ "min_cumulative_pain_buffer_time" ] = 12.0;
	att_idx[ "accuracy" ] 		= 13.0;	// float value
	att_idx[ "speed" ] 			= 14.0;
	att_idx[ "scale" ]	 		= 15.0;
	att_idx[ "xp" ] 			= 16;
	att_idx[ "attacker_difficulty" ] = 17.0;
	att_idx[ "attacker_priority" ] = 18;
	att_idx[ "jump_cost" ]		= 19.0;
	att_idx[ "traverse_cost" ]  = 20.0;
	att_idx[ "run_cost" ]		= 21.0;
	att_idx[ "heavy_damage_threshold" ] = 22.0;
	att_idx[ "pain_interval" ] = 23.0;
	
	att_idx[ "behavior_cloak" ] = 100;
	att_idx[ "behavior_spit" ] 	= 101;
	att_idx[ "behavior_lead" ] 	= 102;
	att_idx[ "behavior_hives" ] = 103;
	
	att_idx[ "swipe_min_damage" ] = 2000;
	att_idx[ "swipe_max_damage" ] = 2001;
	att_idx[ "leap_min_damage" ] = 2002;
	att_idx[ "leap_max_damage" ] = 2003;
	att_idx[ "wall_min_damage" ] = 2004;
	att_idx[ "wall_max_damage" ] = 2005;
	att_idx[ "charge_min_damage" ] = 2006;
	att_idx[ "charge_max_damage" ] = 2007;
	att_idx[ "explode_min_damage" ] = 2008;
	att_idx[ "explode_max_damage" ] = 2009;
	
	// loots - float values
	loot_index = 1000;
	loot_index_max = 1100;
	for( i = loot_index; i < loot_index_max; i++ )
	{
		loot_ref = TableLookup( ATTRIBUTE_TABLE, TABLE_COL_INDEX, i, TABLE_COL_ATTRIBUTE );
		if ( loot_ref == "" )
			break;
		
		att_idx[ loot_ref ] = i * 1.00; // float
	}

	level.alien_types = [];
	
	// get types from table
	setup_alien_type( att_idx, TABLE_COL_AI_TYPE1 );
	setup_alien_type( att_idx, TABLE_COL_AI_TYPE2 );
	setup_alien_type( att_idx, TABLE_COL_AI_TYPE3 );
	setup_alien_type( att_idx, TABLE_COL_AI_TYPE4 );
	setup_alien_type( att_idx, TABLE_COL_AI_TYPE5 );
	setup_alien_type( att_idx, TABLE_COL_AI_TYPE6 );
	setup_alien_type( att_idx, TABLE_COL_AI_TYPE7 );
	setup_alien_type( att_idx, TABLE_COL_BOSS_TYPE1 );
}

setup_alien_type( att_idx, type )
{
	type_ref = TableLookup( ATTRIBUTE_TABLE, TABLE_COL_INDEX, att_idx[ "ref" ], type );
	
	// return if type does not exist
	if ( type_ref == "" )
		return;
	
	level.alien_types[ type_ref ] 					= SpawnStruct();
	//level.alien_types[ type_ref ].attribute_index = att_idx;	
	level.alien_types[ type_ref ].attributes 		= [];
	level.alien_types[ type_ref ].loots 			= [];
	
	foreach( key, index in att_idx )
	{
		value = TableLookup( ATTRIBUTE_TABLE, TABLE_COL_INDEX, index, type );
		
		// cast the correct variable type
		if ( !isString( index ) )
		{
			if ( !IsSubStr( value, "." ) )
				value = int( value );
			else
				value = float( value );
		}
		
		level.alien_types[ type_ref ].attributes[ key ] = value;
		
		// loot!
		if ( IsSubStr( key, "loot_" ) && value > 0.0 )
		{
			level.alien_types[ type_ref ].loots[ key ] = value;
		}
	}
}

// returns array of loot drop chances with index = loot ref string, value = chance (float)
get_loot_array()
{
	return level.alien_types[ self.alien_type ].loots;
}

// ============== Alien cloaking ==============
CONST_DECLOAK_DIST	= 800;
CONST_CLOCK_CHANCE	= 1;

alien_cloak()
{
	self endon( "death" );
	
	self thread near_player_notify();
	
	while ( 1 )
	{
		if( any_player_nearby( self.origin, CONST_DECLOAK_DIST ) )
		{
			wait 0.05;
			continue;
		}

		self waittill( "jump_launching" );
	
		// random chance of cloaking
		//	continue;
		
		self smoke_puff();
		wait 0.20;
		self Hide();
		
		waittill_any_timeout( 1, "jump_finished", "damage" ); //, "near_player" );
		
		self smoke_puff();
		wait 0.20;
		self Show();
	}
}

// WIP: SP>MP
near_player_notify()
{
	self endon( "death" );
	while ( 1 )
	{
		if ( any_player_nearby( self.origin, CONST_DECLOAK_DIST ) )
			self notify( "near_player" );
		
		wait 0.05;
	}
}

smoke_puff()
{
	PlayFXOnTag( level._effect[ "alien_teleport" ], self, "tag_origin" );
	
	// somehow in MP the tags are not valid assets???
	
	//PlayFXOnTag( level._effect[ "alien_teleport" ], self, "j_spineupper" );
	//PlayFXOnTag( level._effect[ "alien_teleport" ], self, "j_mainroot" );
	//PlayFXOnTag( level._effect[ "alien_teleport" ], self, "j_tail_3" );
	
	PlayFXOnTag( level._effect[ "alien_teleport_dist" ], self, "tag_origin" );
}

alien_eyes_on(eye_effect)
{
	// self endon("death");
	// self thread alien_eyes_off();
	self thread alien_eyes_on_threaded( 1.5, eye_effect );
	self thread reattach_eyes_on_teleport( eye_effect );
}

alien_eyes_on_threaded( delay, eye_effect )
{
	self endon( "death" );
	
	self notify( "attaching_eyes" );
	self endon( "attaching_eyes" );
	
	wait delay;
	PlayFXOnTag(eye_effect, self,"TAG_EYE_1_LE");
	PlayFXOnTag(eye_effect, self,"TAG_EYE_1_RI");
/*	waitframe();
	PlayFXOnTag(eye_effect, self,"TAG_EYE_3_LE");
	PlayFXOnTag(eye_effect, self,"TAG_EYE_1_RI");
	waitframe();
	PlayFXOnTag(eye_effect, self,"TAG_EYE_2_RI");
	PlayFXOnTag(eye_effect, self,"TAG_EYE_3_RI");
*/	
	self thread alien_eyes_off_on_death( eye_effect );
}

reattach_eyes_on_teleport( eye_effect )
{
	while ( isdefined( self ) && isalive( self ) )
	{
		self waittill( "jump_land" );
		self alien_eyes_off( eye_effect );
		self waittill( "jump_finished" );
		self thread alien_eyes_on_threaded( 0.05, eye_effect );
	}
}

alien_eyes_off_on_death( eye_effect )
{
	while ( isdefined( self ) && isalive( self ) )
	{
		amount = 0;
		self waittill( "alien_killed" );
		self thread alien_eyes_off( eye_effect );	
	}
}


alien_eyes_off( eye_effect )
{
	KillFXOnTag(eye_effect, self,"TAG_EYE_1_LE");
	KillFXOnTag(eye_effect, self,"TAG_EYE_1_RI");
/*	waitframe();
	KillFXOnTag(eye_effect, self,"TAG_EYE_3_LE");
	KillFXOnTag(eye_effect, self,"TAG_EYE_1_RI");
	waitframe();
	KillFXOnTag(eye_effect, self,"TAG_EYE_2_RI");
	KillFXOnTag(eye_effect, self,"TAG_EYE_3_RI");*/
}
