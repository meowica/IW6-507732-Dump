#include common_scripts\utility;
#include maps\mp\alien\_utility;

CYCLE_TABLE					= "mp/alien/default_cycle_spawn.csv";	// cycle data tablelookup
TABLE_CYCLE_DEF_INDEX 		= 199;	// max index used for cycle definition

TABLE_INDEX					= 0;	// Indexing
TABLE_CYCLE					= 1;	// cycle number
TABLE_INTENSITY				= 2;	// Cycle intensity level
TABLE_INTENSITY_THRESHOLD	= 3;	// Intensity value to switch to this level
TABLE_RESPAWN_THRESHOLD		= 4;	// Threshold to start respawning at
TABLE_RESPAWN_DELAY			= 5;	// Delay after hitting threshold before respawning starts
TABLE_TYPES1				= 6;	// First AI Type
TABLE_COUNT1				= 7;	// First AI Count
TABLE_TYPES2				= 8;	// Second AI Type
TABLE_COUNT2				= 9;	// Second AI Count
TABLE_TYPES3				= 10;	// Third AI Type
TABLE_COUNT3				= 11; 	// Third AI Count
TABLE_TYPES4				= 12;	// Fourth AI Type
TABLE_COUNT4				= 13;	// Fourth AI Count
TABLE_TYPES5				= 14;	// Fifth AI Type
TABLE_COUNT5				= 15;	// Fifth AI Count
TABLE_TYPES6				= 16;	// Sixth AI Type
TABLE_COUNT6				= 17;	// Sixth AI Count

TABLE_SPAWN_EVENT_START_INDEX		= 200;	
TABLE_SPAWN_EVENT_END_INDEX			= 299;
TABLE_SPAWN_EVENT_CYCLE				= 1;	// The cycle this spawn event can happen in
TABLE_SPAWN_EVENT_NOTIFY			= 2;  	// The notify that activates this spawn event
TABLE_SPAWN_EVENT_ID				= 3;	// The unique id for this spawn event
TABLE_SPAWN_EVENT_TIME_LIMIT		= 4;  	// The time limit before this spawn event expires if not completed

TABLE_SPAWN_EVENT_WAVE_START_INDEX		= 300;	
TABLE_SPAWN_EVENT_WAVE_END_INDEX		= 399;
TABLE_SPAWN_EVENT_WAVE_ID				= 1;	// The unique id this wave belongs to
TABLE_SPAWN_EVENT_WAVE_BLOCKING			= 2;  	// Whether or not this wave blocks to wait for all members of it to be killed
TABLE_SPAWN_EVENT_WAVE_SPAWN_DELAY		= 3;	// The delay before activation after previous wave ends
TABLE_SPAWN_EVENT_WAVE_TYPE1			= 4;  	// The first type to spawn
TABLE_SPAWN_EVENT_WAVE_COUNT1			= 5;  	// The number of first type to spawn
TABLE_SPAWN_EVENT_WAVE_TYPE2			= 6;  	// The second type to spawn
TABLE_SPAWN_EVENT_WAVE_COUNT2			= 7;  	// The number of second type to spawn
TABLE_SPAWN_EVENT_WAVE_TYPE3			= 8;  	// The third type to spawn
TABLE_SPAWN_EVENT_WAVE_COUNT3			= 9;  	// The number of third type to spawn
TABLE_SPAWN_EVENT_WAVE_TYPE4			= 10;  	// The fourth type to spawn
TABLE_SPAWN_EVENT_WAVE_COUNT4			= 11;  	// The number of fourth type to spawn
TABLE_SPAWN_EVENT_WAVE_TYPE5			= 12;  	// The fifth type to spawn
TABLE_SPAWN_EVENT_WAVE_COUNT5			= 13;  	// The number of fifth type to spawn

TABLE_MIN_SPAWN_INTERVAL							= 400;	// Min interval between spawns
TABLE_SAFE_SPAWN_DISTANCE							= 401;	// How close player has to be before doing a trace
TABLE_SPAWN_POINT_LAST_USED_DURATION 				= 402;	// How long a spawn point is considered recently used
TABLE_FULL_INTENSITY_TIME							= 403;	// How much time it takes to go from 0.0 to 1.0 intensity with no modifiers
TABLE_PLAYER_DOWNED_INTENSITY_MODIFIER				= 404;	// How much to modify intensity by if a player is downed
TABLE_PLAYER_DEATH_INTENSITY_MODIFIER				= 405;	// How much to modify intensity by if a player dies
TABLE_PLAYER_HEALTH_INTENSITY_MODIFIER				= 406;	// How much to modify intensity by if average player damage over time is too low
TABLE_PLAYER_DOWNED_INTENSITY_MULTIPLIER 			= 407; 	// How much to decrease the time intensity multiplier by for each player downed
TABLE_PLAYER_HEALTH_BUFFER_TIME						= 408;	// How long of a player damage buffer is needed before it can modify intensity
TABLE_PLAYER_HEALTH_BUFFER_MIN_DAMAGE_PER_PLAYER	= 409;	// Min average damage per player before it starts modifying intensity
TABLE_GROUP_BREAK_AWAY_DISTANCE						= 410;	// Min distance before a player is considered to have broken away from team
TABLE_PLAYER_IN_ZONE_SCORE							= 411;	// How much to add to zone score for each player in the zone
TABLE_CURRENT_ATTACKER_ZONE_SCORE					= 412;	// How much to subtract from zone score for each current attacker on a player in the zone
TABLE_RECENTLY_SPAWNED_ZONE_MODIFIER				= 413;	// How much to subtract from zone score for each recently used spawn node in the zone
TABLE_MAX_BREAK_AWAY_SCORE_INCREASE					= 414;	// Max amount to increase zone score for a break away player in that zone
TABLE_SPAWN_EVENT_MIN_ACTIVATION_TIME				= 415;	// Base time to wait after notify received before activating a spawn event
TABLE_SPAWN_EVENT_PER_ALIEN_ACTIVATION_INCREASE		= 416;	// Additional time per alive alien to add to wait time
TABLE_VARIABLE_COLUMN								= 2;	// column for variable values

BASE_PLAYER_COUNT_MULTIPLIER = 0.4;
ADDITIONAL_PLAYER_COUNT_MULTIPLIER = 0.2;
MAX_ALIEN_COUNT = 18;

MIN_SPAWN_INTERVAL = 1.0;
SAFE_SPAWN_DISTANCE = 500.0;
LAST_USED_TIME_DURATION = 5000.0;
FULL_INTENSITY_TIME = 180000.0;
INTENSITY_MODIFIER_PLAYER_DOWNED = -0.05;
INTENSITY_MODIFIER_PLAYER_DEATH = -0.05;
INTENSITY_MODIFIER_PLAYER_HEALTH = 0.05;
INTENSITY_MULTIPLIER_MODIFIER_DOWNED_PLAYER = 0.25;
INTENSITY_HEALTH_BUFFER_TIME = 20000.0;
INTENSITY_HEALTH_MIN_TOTAL_DAMAGE_PER_PLAYER = 100.0;

GROUP_BREAK_AWAY_DISTANCE = 1500;
PLAYER_IN_ZONE_SCORE = 0.75;
CURRENT_ATTACKER_FOR_ZONE_SCALE = 0.25;
RECENTLY_SPAWNED_ZONE_MODIFIER = 0.25;
MAX_BREAK_AWAY_SCORE_INCREASE = 2.5;

WAVE_SPAWN_SOUND = "alien_distant";

init( alien_cycle_table )
{
	if ( IsDefined( alien_cycle_table ) )
		level.alien_cycle_table = alien_cycle_table;
	else
		level.alien_cycle_table = CYCLE_TABLE;
	
	load_cycles_from_table();
	build_spawn_zones();
	load_spawn_events_from_table();
	load_variables_from_table();
	
	level.play_alien_wave_spawn_sound = false;
	
	/#level thread monitor_debug_dvar();#/
}

load_variables_from_table()
{
		level.min_spawn_interval = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_MIN_SPAWN_INTERVAL, TABLE_VARIABLE_COLUMN ) );
		
		safeSpawnDistanceValue = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_SAFE_SPAWN_DISTANCE, TABLE_VARIABLE_COLUMN ) );
		level.safe_spawn_distance_sq = safeSpawnDistanceValue * safeSpawnDistanceValue;
		
		level.spawn_point_last_used_duration = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_SPAWN_POINT_LAST_USED_DURATION, TABLE_VARIABLE_COLUMN ) ) * 1000.0;
		level.full_intensity_time = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_FULL_INTENSITY_TIME, TABLE_VARIABLE_COLUMN ) ) * 1000.0;
		level.player_downed_intensity_modifier = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_PLAYER_DOWNED_INTENSITY_MODIFIER, TABLE_VARIABLE_COLUMN ) );
		level.player_death_intensity_modifier = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_PLAYER_DEATH_INTENSITY_MODIFIER, TABLE_VARIABLE_COLUMN ) );
		level.player_health_intensity_modifier = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_PLAYER_HEALTH_INTENSITY_MODIFIER, TABLE_VARIABLE_COLUMN ) );
		level.player_downed_intensity_multiplier_modifier = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_PLAYER_DOWNED_INTENSITY_MULTIPLIER, TABLE_VARIABLE_COLUMN ) );
		level.player_health_buffer_time = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_PLAYER_HEALTH_BUFFER_TIME, TABLE_VARIABLE_COLUMN ) ) * 1000.0;
		level.player_health_buffer_min_damage_per_player = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_PLAYER_HEALTH_BUFFER_MIN_DAMAGE_PER_PLAYER, TABLE_VARIABLE_COLUMN ) );
		
		breakAwayDistance = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_GROUP_BREAK_AWAY_DISTANCE, TABLE_VARIABLE_COLUMN ) );
		level.group_break_away_distance_sq = breakAwayDistance * breakAwayDistance;
		
		level.player_in_zone_score_modifier = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_PLAYER_IN_ZONE_SCORE, TABLE_VARIABLE_COLUMN ) );
		level.current_attacker_in_zone_score_modifier = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_CURRENT_ATTACKER_ZONE_SCORE, TABLE_VARIABLE_COLUMN ) );
		level.recently_used_spawn_zone_score_modifier = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_RECENTLY_SPAWNED_ZONE_MODIFIER, TABLE_VARIABLE_COLUMN ) );
		level.max_break_away_zone_score_increase = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_MAX_BREAK_AWAY_SCORE_INCREASE, TABLE_VARIABLE_COLUMN ) );
		
		level.spawn_event_min_activation_time = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_SPAWN_EVENT_MIN_ACTIVATION_TIME, TABLE_VARIABLE_COLUMN ) );
		level.spawn_event_per_alien_activation_increase = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, TABLE_SPAWN_EVENT_PER_ALIEN_ACTIVATION_INCREASE, TABLE_VARIABLE_COLUMN ) );
}

load_spawn_events_from_table()
{
	for ( entryIndex = TABLE_SPAWN_EVENT_START_INDEX; entryIndex <= TABLE_SPAWN_EVENT_END_INDEX; entryIndex++ )
	{
		cycle = tablelookup( level.alien_cycle_table, TABLE_INDEX, entryIndex, TABLE_SPAWN_EVENT_CYCLE );
		if ( cycle == "" )
			break;
		
		cycleNum = int( cycle ) - 1;
		/# AssertEx( cycleNum >= 0 && cycleNum < level.spawn_cycles.size, "Spawn event cycle " + cycle + " references non-existent cycle!" );#/
		
		spawnEvent = SpawnStruct();
		spawnEvent.activation_notify = tablelookup( level.alien_cycle_table, TABLE_INDEX, entryIndex, TABLE_SPAWN_EVENT_NOTIFY );
		spawnEvent.id = int( tablelookup( level.alien_cycle_table, TABLE_INDEX, entryIndex, TABLE_SPAWN_EVENT_ID ) );
		spawnEvent.time_limit = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, entryIndex, TABLE_SPAWN_EVENT_TIME_LIMIT ) );
		spawnEvent.waves = [];
		
		newIndex = level.spawn_cycles[cycleNum].spawn_events.size;
		level.spawn_cycles[cycleNum].spawn_events[newIndex] = spawnEvent;
	}
	
	load_spawn_event_waves_from_table();
}

load_spawn_event_waves_from_table()
{
	for ( entryIndex = TABLE_SPAWN_EVENT_WAVE_START_INDEX; entryIndex <= TABLE_SPAWN_EVENT_WAVE_END_INDEX; entryIndex++ )
	{
		id = tablelookup( level.alien_cycle_table, TABLE_INDEX, entryIndex, TABLE_SPAWN_EVENT_WAVE_ID );
		if ( id == "" )
			break;
		
		spawnEventWave = SpawnStruct();
		spawnEventWave.blocking = get_spawn_event_wave_blocking_by_index( entryIndex );
		spawnEventWave.spawn_delay = float( tablelookup( level.alien_cycle_table, TABLE_INDEX, entryIndex, TABLE_SPAWN_EVENT_ID ) );
		spawnEventWave.types = get_spawn_event_types_array( entryIndex );
		
		add_spawn_event_wave( int( id ), spawnEventWave );
	}
}

add_spawn_event_wave( id, wave )
{
	for ( cycleIndex = 0; cycleIndex < level.spawn_cycles.size; cycleIndex++ )
	{
		for ( eventIndex = 0; eventIndex < level.spawn_cycles[cycleIndex].spawn_events.size; eventIndex++ )
		{
			if ( level.spawn_cycles[cycleIndex].spawn_events[eventIndex].id == id )
			{
				addIndex = level.spawn_cycles[cycleIndex].spawn_events[eventIndex].waves.size;
				level.spawn_cycles[cycleIndex].spawn_events[eventIndex].waves[addIndex] = wave;
				return;
			}
		}
	}
}

get_spawn_event_wave_blocking_by_index( index )
{
	blocking = tablelookup( level.alien_cycle_table, TABLE_INDEX, index, TABLE_SPAWN_EVENT_WAVE_BLOCKING );
	
	return blocking == "yes";
}

get_spawn_event_types_array( cycle )
{
	types = [];
	
	types[0] = get_type_data( cycle, TABLE_SPAWN_EVENT_WAVE_TYPE1, TABLE_SPAWN_EVENT_WAVE_COUNT1 );
	types[1] = get_type_data( cycle, TABLE_SPAWN_EVENT_WAVE_TYPE2, TABLE_SPAWN_EVENT_WAVE_COUNT2 );
	types[2] = get_type_data( cycle, TABLE_SPAWN_EVENT_WAVE_TYPE3, TABLE_SPAWN_EVENT_WAVE_COUNT3 );
	types[3] = get_type_data( cycle, TABLE_SPAWN_EVENT_WAVE_TYPE4, TABLE_SPAWN_EVENT_WAVE_COUNT4 );
	types[4] = get_type_data( cycle, TABLE_SPAWN_EVENT_WAVE_TYPE5, TABLE_SPAWN_EVENT_WAVE_COUNT5 );
	
	types = sort_array( types, ::sort_priority_levels_func );
	
	return types;
}

/#
monitor_debug_dvar()
{
	SetDevDvarIfUninitialized( "debug_spawn_director", 0 );
	SetDevDvarIfUninitialized( "spawn_director_timed_wave_test", 1 );
	SetDevDvarIfUninitialized( "scr_alienwavedebug", "-1 0.0" );
	SetDevDvarIfUninitialized( "scr_alienspawninfo", 0 );
						   
	level.debug_spawn_director_active = false;
	level.debug_spawn_director_spawn_index = 0;
	level.debug_spawn_director_spawn_list = [];
	
	while( true )
	{
		waveDebugValues = strtok( GetDvar( "scr_alienwavedebug", "-1 0.0" ), " " );
		AssertEx( waveDebugValues.size == 2, "Invalid entry for scr_alienwavedebug dvar! Should be integer value for cycle number, and float value (0.0 - 1.0) for intensity level. ( scr_alienwavedebug \"4 0.5\" )" );
		waveDebugCycle = int( waveDebugValues[0] ) - 1;
		if ( waveDebugCycle >= 0 )
		{
			AssertEx( waveDebugCycle < level.spawn_cycles.size, "Invalid cycle entry! Should be between 1 and " + level.spawn_cycles.size );
			if ( alien_mode_has( "nogame" ) )
			{
				level.current_intensity = float( waveDebugValues[1] );
				level.current_cycle = level.spawn_cycles[ waveDebugCycle ];
				level.current_intensity_level = calculate_current_intensity_level();
				level.pending_meteor_spawns = 0;
				level thread monitor_meteor_spawn();
				types = level.current_cycle.intensityLevels[level.current_intensity_level].ai_types;
				spawn_wave( types, false );
			}
			else
			{
				AssertMsg( "Can't activate scr_alienwavedebug unless nogame mode is active!" );
			}
			SetDevDvar( "scr_alienwavedebug", "-1 0.0" );
		}
		
		if ( !level.debug_spawn_director_active && GetDvarInt( "debug_spawn_director", 0 ) > 0 )
		{
			level.debug_spawn_director_active = true;
			level notify( "debug_mode_activated" );
			level thread debug_respawn_monitor();

			if ( IsDefined( level.current_cycle ) )
			{
				foreach ( aiType in level.current_cycle.currently_spawned )
				{
					foreach ( killAI in aiType )
					{
						killAi Suicide();
					}
				}
			}
		}
		
		if ( level.debug_spawn_director_active && GetDvarInt( "debug_spawn_director", 0 ) <= 0 )
		{
			level notify( "debug_mode_deactivated" );
			level.debug_spawn_director_active = false;
			level.debug_spawn_director_spawn_index = 0;
			
			foreach ( killAI in level.debug_spawn_director_spawn_list )
			{
				killAI Suicide();
			}
		}
		
		wait 0.05;
	}
}#/

set_intensity( intensity )
{
	level.current_intensity = clamp( intensity, 0.0, 1.0 );
}

// TODO: Maybe let it set the intensity on force off as well to get a new default without having to call set_intensity
force_intensity( force_on, intensity )
{
	if ( force_on )
		level.forced_current_intensity = clamp( intensity, 0.0, 1.0 );
	else if ( IsDefined( level.forced_current_intensity ) )
		level.forced_current_intensity = undefined;
}

load_cycles_from_table()
{
	level.spawn_cycles = [];
	
	for ( entryIndex = 0; entryIndex <= TABLE_CYCLE_DEF_INDEX; entryIndex++ )
	{
		cycleName = get_cycle_by_index( entryIndex );
		if ( cycleName == "" )
			break;

		cycleIndex = int( cycleName ) - 1;
		if ( !IsDefined ( level.spawn_cycles[ cycleIndex ] ) )
		{
			cycle = SpawnStruct();
			cycle.intensityLevels = [];
			cycle.currently_spawned = [];
			cycle.spawn_events = [];
			level.spawn_cycles[ cycleIndex ] = cycle;
		}
		else
		{
			cycle = level.spawn_cycles[ cycleIndex ];
		}
		
		newLevel = SpawnStruct();
		newLevel.intensityThreshold = get_intensity_threshold_by_index( entryIndex );
		newLevel.ai_types = get_types_array( entryIndex );
		newLevel.respawn_threshold = get_respawn_threshold_by_index( entryIndex );
		newLevel.respawn_delay = get_respawn_delay_by_index( entryIndex );
		
		cycle.intensityLevels[ cycle.intensityLevels.size ] = newLevel;
	}
	
	foreach ( cycle in level.spawn_cycles )
	{
		cycle.intensityLevels = sort_array( cycle.intensityLevels, ::sort_intensity_levels_func );
		
		// TODO: Temp change so that string table can be laid out in seconds instead of intensity threshold
		if ( cycle.intensityLevels.size > 0 )
		{
			fullIntensityTime = cycle.intensityLevels[cycle.intensityLevels.size - 1].intensityThreshold;
			foreach( intensityLevel in cycle.intensityLevels )
		    {
				if ( fullIntensityTime <= 0.0 )
				{
					intensityLevel.intensityThreshold = 0.0;	
				}
				else
				{
		    		intensityLevel.intensityThreshold = intensityLevel.intensityThreshold / fullIntensityTime;	
				}
		    }
			cycle.fullIntensityTime = fullIntensityTime * 1000.0; // ms
		}
	}
	
}

sort_array( array, sort_func, beginning_index )
{
	if ( !IsDefined( beginning_index ) )
		beginning_index = 0;
	
	sortedArray = [];
	foreach ( entry in array )
		sortedArray[ sortedArray.size ] = entry;

	for ( i = beginning_index + 1; i < sortedArray.size; i++ )
	{
		entry = sortedArray[ i ];

		for ( j = i - 1; j >= beginning_index && [[ sort_func ]]( sortedArray[j], entry ); j-- )
			sortedArray[ j + 1 ] = sortedArray[ j ];

		sortedArray[ j + 1 ] = entry;
	}		
	
	return sortedArray;
}

sort_intensity_levels_func( test_entry, base_entry)
{
	/#Assert( IsDefined( test_entry.intensityThreshold ) && IsDefined( base_entry.intensityThreshold ) );#/
	return test_entry.intensityThreshold > base_entry.intensityThreshold;
}

sort_priority_levels_func( test_entry, base_entry)
{
	if ( !IsDefined( base_entry.type_name ) )
		return true;
	
	if ( !IsDefined( test_entry.type_name ) )
		return false;
	
	testPriorityLevel = level.alien_types[ test_entry.type_name ].attributes[ "attacker_priority" ];
	basePriorityLevel = level.alien_types[ base_entry.type_name ].attributes[ "attacker_priority" ];
	return testPriorityLevel > basePriorityLevel;
}

build_spawn_zones()
{
	spawnLocations = getstructarray( "alien_spawn_struct", "targetname" ); // temp to handle areas lacking in spawn zones for now
	spawnZones = GetEntArray( "spawn_zone", "targetname" );
	
	level.spawn_zones = [];
	
	foreach ( zone in spawnZones )
	{
		/# AssertEx( !spawn_zone_exists( zone.script_linkName ), "Spawn zone with script_linkName of " + zone.script_linkName + " defined multiple times!" );#/
			
		zoneInfo = SpawnStruct();
		zoneInfo.zone_name = zone.script_linkName;
		zoneInfo.volume = zone;
		zoneInfo.spawn_nodes = [];
		level.spawn_zones[ zone.script_linkName ] = zoneInfo;
	}
	
	level.temp_spawn_locs = [];
	foreach ( location in spawnLocations )
	{
		validTypes = [];
		if ( IsDefined( location.script_noteworthy ) )
			validTypes = strtok( location.script_noteworthy, " " );
		
		locationInfo = [];
		locationInfo["types"] = validTypes;
		locationInfo["location"] = location;
	
		level.temp_spawn_locs[level.temp_spawn_locs.size] = locationInfo;
		if ( !IsDefined( location.script_linkTo ) )
			continue;
		
		linkedZones = location get_links();
		foreach ( zone in linkedZones )
		{
			/#assertex( IsDefined( level.spawn_zones[zone] ), "Invalid linked spawn zone: " + zone );#/
			locationIndex = level.spawn_zones[zone].spawn_nodes.size;
			level.spawn_zones[zone].spawn_nodes[locationIndex] = locationInfo;
		}	
	}
	
	/#
	foreach ( zone in level.spawn_zones )
	{
		AssertEx( zone.spawn_nodes.size > 0, "Spawn zone " + zone.zone_name + " does not have any linked spawners!" );
	}
	#/
}

spawn_zone_exists( zone_name )
{
	foreach( index, zone in level.spawn_zones )
	{
		if ( index == zone_name )
			return true;
	}
	
	return false;
}

get_cycle_by_index( index )
{
	return tablelookup( level.alien_cycle_table, TABLE_INDEX, index, TABLE_CYCLE );
}

get_intensity_level_by_index( index )
{
	return tablelookup( level.alien_cycle_table, TABLE_INDEX, index, TABLE_INTENSITY );	
}

get_respawn_threshold_by_index( index )
{
	respawnThreshold = tablelookup( level.alien_cycle_table, TABLE_INDEX, index, TABLE_RESPAWN_THRESHOLD );
	
	if ( respawnThreshold == "" || respawnThreshold == " " )
		return -1;
	
	return int( respawnThreshold );
}

get_respawn_delay_by_index( index )
{
	respawnDelay = tablelookup( level.alien_cycle_table, TABLE_INDEX, index, TABLE_RESPAWN_DELAY );
		
	if ( respawnDelay == "" || respawnDelay == " " )
		return -1;
	
	return float( respawnDelay );
}

get_intensity_threshold_by_index( index )
{
	return float( tablelookup( level.alien_cycle_table, TABLE_INDEX, index, TABLE_INTENSITY_THRESHOLD ) );
}

get_types_array( cycle )
{
	types = [];
	
	types[0] = get_type_data( cycle, TABLE_TYPES1, TABLE_COUNT1 );
	types[1] = get_type_data( cycle, TABLE_TYPES2, TABLE_COUNT2 );
	types[2] = get_type_data( cycle, TABLE_TYPES3, TABLE_COUNT3 );
	types[3] = get_type_data( cycle, TABLE_TYPES4, TABLE_COUNT4 );
	types[4] = get_type_data( cycle, TABLE_TYPES5, TABLE_COUNT5 );
	types[5] = get_type_data( cycle, TABLE_TYPES6, TABLE_COUNT6 );
	
	types = sort_array( types, ::sort_priority_levels_func );
	
	return types;
}

get_type_data( row_index, table_ai_type, table_count_type )
{
	typeName = tablelookup( level.alien_cycle_table, TABLE_INDEX, row_index, table_ai_type );
	
	if ( typeName == "" )
		return undefined;
	
	typeRange = strTok( tablelookup( level.alien_cycle_table, TABLE_INDEX, row_index, table_count_type ), " " );
	assertex( typeRange.size > 0 && typeRange.size <= 2, typeName + " doesn't have valid spawn range in cycle " + ( row_index + 1 ) );
	
	typeData = SpawnStruct();
	typeData.type_name = typeName;
	typeRange[0] = int( typeRange[0] );
	typeRange[1] = int( typeRange[1] );
	
	if ( typeRange.size == 0 )
	{
		typeData.min_spawned = 0;
		typeData.max_spawned = 0;
	}
	else if ( typeRange.size == 1 )
	{
		typeData.min_spawned = typeRange[0];
		typeData.max_spawned = typeRange[0];
	}
	else
	{
		if ( typeRange[0] <= typeRange[1] )
		{
			typeData.min_spawned = typeRange[0];
			typeData.max_spawned = typeRange[1];
		}
		else
		{
			typeData.min_spawned = typeRange[1];
			typeData.max_spawned = typeRange[0];	
		}
	}

	return typeData;	
}

start_cycle( cycle_num )
{
	AssertEx( cycle_num > 0 && cycle_num <= level.spawn_cycles.size, cycle_num + " is invalid cycle number" );
	level thread spawn_director_loop( cycle_num - 1 );
}

end_cycle()
{
	level notify( "end_cycle" );
	//<NOTE J.C.> This is for external scripts (such as mist and lurker).  Maybe we can combine the two notifies soon?
	level notify( "alien_cycle_ended" );
}

activate_spawn_event( event_notify )
{
	spawnEvent = find_spawn_event( event_notify );
	
	if ( !IsDefined( spawnEvent ) )
	{
		AssertMsg( event_notify + " is not a valid notify for cycle " + level.current_cycle_num );
		return;	
	}
	
	level thread run_spawn_event( spawnEvent );
}

find_spawn_event( event_notify )
{
	foreach( spawnEvent in level.current_cycle.spawn_events )
	{
		if ( spawnEvent.activation_notify == event_notify )
			return spawnEvent;
	}
	
	return undefined;
}

wait_for_spawn_event_delay()
{
	while ( level.pending_meteor_spawns > 0 )
		wait 0.05;
	
	timeToWait = level.spawn_event_min_activation_time + level.spawn_event_per_alien_activation_increase * get_current_agent_count();
	wait timeToWait;
}

run_spawn_event( spawn_event )
{
	level endon( "end_cycle" );
	
	level.intensity_spawning_paused = true;
	wait_for_spawn_event_delay();
	run_spawn_event_wave_spawning( spawn_event );
	
	level.intensity_spawning_paused = false;
	level notify( "spawn_event_complete", spawn_event.activation_notify );
}

run_spawn_event_wave_spawning( spawn_event )
{
	level endon( "spawn_event_time_limit_reached" );
	
	spawnEventBeginTime = GetTime();
	level thread spawn_event_time_limit_monitor( spawn_event.time_limit );
	allEventSpawnedAliens = [];
	
	foreach( wave in spawn_event.waves )
	{	
		if ( wave.spawn_delay > 0.0 )
			wait wave.spawn_delay;	
		
		if ( wave_has_minion_type( wave ) )
			spawnedAliens = spawn_event_meteor_wave_spawn( wave );
		else
			spawnedAliens = spawn_event_wave_spawn( wave );
		
		allEventSpawnedAliens = array_combine( allEventSpawnedAliens, spawnedAliens );
	}
	
	wait_for_all_aliens_killed( allEventSpawnedAliens );
}

wave_has_minion_type( wave )
{
	foreach( alienType in wave.types )
	{
		if ( alienType.type_name == "minion" )
			return true;
	}
	
	return false;
}

spawn_event_wave_spawn( wave )
{
	spawnedAliens = spawn_wave( wave.types, false );
	
	if ( wave.blocking )
		wait_for_all_aliens_killed( spawnedAliens );

	return spawnedAliens;	
}

spawn_event_meteor_wave_spawn( wave )
{
	spawnedAliens = spawn_wave( wave.types, false );

	while ( level.pending_meteor_spawns > 0 )
	{
		level waittill( "meteor_aliens_spawned", aliens, requestedCount );
		spawnedAliens = array_combine( spawnedAliens, aliens );
		wait 0.05; // let the pending_meteor_spawns value update
	}
	
	if ( wave.blocking )
		wait_for_all_aliens_killed( spawnedAliens );
	
	return spawnedAliens;
}

spawn_event_time_limit_monitor( time_limit )
{
	level endon( "spawn_event_complete" );
	
	wait time_limit;
	level notify( "spawn_event_time_limit_reached" );
}

wait_for_all_aliens_killed( aliens )
{
	level endon( "spawn_event_complete" );
	level endon( "spawn_event_time_limit_reached" );	
	
	while ( true )
	{
		anyAliveAliens = false;
		foreach ( alien in aliens )
		{
			if ( IsAlive( alien ) )
			{
				anyAliveAliens = true;
				break;				
			}
		}	
		
		if ( !anyAliveAliens )
			break;
		
		wait 0.05;
	}
}

spawn_director_loop( cycle_num)
{
	level endon( "end_cycle" );
	
	level.spawn_node_traces_this_frame = 0;
	level.spawn_node_traces_frame_time = GetTime();
	level.intensity_spawning_paused = false;
	
	level.current_cycle_num = cycle_num;
	level.current_cycle = level.spawn_cycles[ cycle_num ];
	cycle_begin_intensity_monitor();
	level.pending_meteor_spawns = 0;
	level thread monitor_meteor_spawn();
	level thread spawn_type_vo_monitor();
	
	if ( !IsDefined( level.debug_spawn_director_active ) || !level.debug_spawn_director_active )
		initial_spawn();
	
	while ( true )
	{
		/#
		while ( level.debug_spawn_director_active )
			wait 0.05;
		#/
		respawnActive = respawn_threshold_monitor();
		
		/#
		if ( level.debug_spawn_director_active )
			continue;
		#/
			
		respawn( respawnActive );
	}
}

INTENSITY_MONITOR_FREQUENCY = 0.1;

cycle_begin_intensity_monitor()
{
	level thread monitor_player_spawns();
	level thread monitor_total_player_damage();
	foreach( player in level.players )
		set_up_player_monitors( player );
	
	level.current_intensity_level = -1;
	level.current_intensity = 0.0;
	
	level thread intensity_monitor_update_loop();
}

intensity_monitor_update_loop()
{
	level endon( "end_cycle" );
	
	last_intensity_update_time = GetTime();

	// initial pass: linear increase in intensity over time
	while ( true )
	{
		currentTime = GetTime();
		
		if ( !level.intensity_spawning_paused )
		{
			if ( IsDefined( level.forced_current_intensity ) )
			{
				level.current_intensity = level.forced_current_intensity;
			}
			else if ( level.current_cycle.fullIntensityTime == 0.0 )
			{
				level.current_intensity = 1.0;	
			}
			else
			{
				intensityIncrease = ( currentTime - last_intensity_update_time ) / level.current_cycle.fullIntensityTime;
				level.current_intensity = clamp( level.current_intensity + intensityIncrease * get_intensity_increase_multiplier(), 0.0, 1.0 );
			}
			
			last_intensity_update_time = currentTime;
			intensityLevel = calculate_current_intensity_level();
			
			if ( level.current_intensity_level != intensityLevel )
				level notify( "intensity_level_changed" );
			
			level.current_intensity_level = intensityLevel;		
			//IPrintLnBold( "Intensity: " + level.current_intensity + ", Intensity Level: " + level.current_intensity_level ); 
		}
		else
		{
			last_intensity_update_time = currentTime;		
		}
		
		wait INTENSITY_MONITOR_FREQUENCY;
	}
}

calculate_current_intensity_level()
{
	for ( intensityIndex = 0; intensityIndex < level.current_cycle.intensityLevels.size; intensityIndex++ )
	{
		if ( level.current_cycle.intensityLevels[intensityIndex].intensityThreshold > level.current_intensity )
			break;
	}
	
	return intensityIndex - 1;
}

get_intensity_increase_multiplier()
{
	numberOfDownedPlayers = level.players.size - get_number_of_non_downed_players();
	multiplier = 1.0 - numberOfDownedPlayers * level.player_downed_intensity_multiplier_modifier;
	return max( 0.0, multiplier );
}

set_up_player_monitors( player )
{
	level thread monitor_player_downed( player );
	level thread monitor_player_death( player );
	level thread monitor_player_damage( player );
}

monitor_player_spawns()
{
	level endon( "end_cycle" );
	
	while ( true )
	{
		// TODO: Does this break down if 2 players spawn in the same frame in the middle of a cycle?
		level waittill( "player_spawned", player );
		set_up_player_monitors( player );
	}
}

monitor_player_death( player )
{
	level endon( "end_cycle" );
	player endon( "disconnect" );
	
	player waittill( "death" );
	level.current_intensity = clamp( level.current_intensity - level.player_death_intensity_modifier, 0.0, 1.0 );
	reset_damage_buffer();
}

monitor_player_downed( player )
{
	level endon( "end_cycle" );
	player endon( "disconnect" );
	
	player waittill( "player_last_stand" );
	level.current_intensity = clamp( level.current_intensity - level.player_downed_intensity_modifier, 0.0, 1.0 );
	reset_damage_buffer();
}

monitor_player_damage( player )
{
	level endon( "end_cycle" );
	player endon( "death" );
	player endon( "disconnect" );
	
	while ( true )
	{
		player waittill( "damage", amount );
		index = level.damage_buffer.size;
		level.damage_buffer[index]["amount"] = amount;
		level.damage_buffer[index]["time"] = GetTime();
	}
}

reset_damage_buffer()
{
	level.damage_buffer = [];
	level.buffer_start_time = GetTime();
}

monitor_total_player_damage()
{
	level endon( "end_cycle" );
	reset_damage_buffer();
	
	while( true )
	{
		currentTime = GetTime();
	
		for ( validIndex = 0; validIndex < level.damage_buffer.size; validIndex++ )
		{
			if ( ( currentTime - level.damage_buffer[validIndex]["time"] ) < level.player_health_buffer_time )
				break;
		}
		
		if ( validIndex != 0 )
		{
			prune_damage_buffer( validIndex );
		}
		
		bufferDamage = 0.0;
		for ( bufferIndex = 0; bufferIndex < level.damage_buffer.size; bufferIndex++ )
		{
			bufferDamage += level.damage_buffer[bufferIndex]["amount"];
		}
		
		hasEnoughBuffer = ( currentTime - level.buffer_start_time ) > level.player_health_buffer_time;
		hasEnoughDamage = bufferDamage > level.player_health_buffer_min_damage_per_player * get_number_of_non_downed_players();
		
		if ( hasEnoughBuffer && !hasEnoughDamage )
		{
			level.current_intensity = clamp( level.current_intensity + level.player_health_intensity_modifier, 0.0, 1.0 );
			reset_damage_buffer();
		}
	
		wait 0.1;		
	}
}

get_number_of_non_downed_players()
{
	playerCount = 0;

	for ( playerIndex = 0; playerIndex < level.players.size; playerIndex++ )
	{
		player = level.players[playerIndex];
		if ( !IsAlive( player ) )
			continue;
		
		if ( IsDefined( player.inLastStand ) && player.inLastStand )
			continue;
		
		playerCount++;
	}
	
	return playerCount;
}

prune_damage_buffer( startIndex )
{
	newBuffer = [];
	newBufferIndex = 0;
	
	for ( bufferIndex = startIndex; bufferIndex < level.damage_buffer.size; bufferIndex++ )
	{
		newBuffer[newBufferIndex] = level.damage_buffer[bufferIndex];
		newBufferIndex++;
	}
	
	level.damage_buffer = newBuffer;
}


initial_spawn()
{
	while ( level.current_intensity_level < 0 )
		wait 0.05;
	
	types = level.current_cycle.intensityLevels[level.current_intensity_level].ai_types;
	spawn_wave( types, false );
}

respawn( respawnActive )
{
	types = level.current_cycle.intensityLevels[level.current_intensity_level].ai_types;
	spawn_wave( types, respawnActive );
}

spawn_wave( types, respawn )
{
	level.play_alien_wave_spawn_sound = true;
	spawnedAliens = [];
	
	for ( typesIndex = 0; typesIndex < types.size; typesIndex++ )
	{
		spawnedAliens = array_combine ( spawn_type( types[ typesIndex ], respawn ), spawnedAliens );
	}
	
	return spawnedAliens;
}

/#
debug_respawn_monitor()
{
	level endon( "debug_mode_deactivated" );
	
	level.debug_spawn_director_spawn_list = [];
	
	while( true )
	{
		while ( !IsDefined( level.current_intensity_level ) || level.current_intensity_level < 0 )
			wait 0.05;
		
		desiredTotalAI = GetDvarInt( "debug_spawn_director", 0 );
		currentlyAlive = [];
		foreach ( testAI in level.debug_spawn_director_spawn_list )
		{
			if ( IsAlive ( testAi ) )
				currentlyAlive[currentlyAlive.size] = testAI;
		}
		level.debug_spawn_director_spawn_list = currentlyAlive;
		
		for ( spawnIndex = level.debug_spawn_director_spawn_list.size; spawnIndex < desiredTotalAI; spawnIndex++ )
		{
			alien = spawn_alien( get_random_type_from_current_intensity() );

			listIndex = level.debug_spawn_director_spawn_list.size;
			level.debug_spawn_director_spawn_list[listIndex] = alien;
			wait level.min_spawn_interval;
		}
		
		wait 0.05;
	}
}

get_random_type_from_current_intensity()
{
	randomTypeIndex = RandomInt( level.current_cycle.intensityLevels[level.current_intensity_level].ai_types.size );
	
	return level.current_cycle.intensityLevels[level.current_intensity_level].ai_types[randomTypeIndex].type_name;
}

#/

respawn_threshold_monitor()
{
	level endon( "end cycle" );
	level endon( "intensity_level_changed" );
	/#level endon( "debug_mode_activated" );#/
	
	while ( true )
	{
		if ( level.current_intensity_level >= 0 && !level.intensity_spawning_paused )
		{
			respawnThreshold = level.current_cycle.intensityLevels[level.current_intensity_level].respawn_threshold;
			if ( respawnThreshold >= 0 )
			{
				currentAITotal = get_current_agent_count();
				
				respawnThreshold = int ( respawnThreshold * get_current_spawn_count_multiplier() );
				if ( currentAITotal <= respawnThreshold )
					break;
			}
		}
		
		wait 0.1;	
	}
	
	respawnDelay = level.current_cycle.intensityLevels[level.current_intensity_level].respawn_delay;
	if ( level.current_intensity_level >= 0  && respawnDelay >= 0 )
		wait respawnDelay * get_current_spawn_count_multiplier();
	
	return true;
}

prune_currently_spawned()
{
	foreach ( index, aiTypeList in level.current_cycle.currently_spawned )
	{
		currently_alive = [];
		foreach ( testAI in aiTypeList )
		{
			if ( IsAlive( testAI ) )
			    currently_alive[ currently_alive.size ] = testAI;
		}
		level.current_cycle.currently_spawned[index] = currently_alive;
	}
}

get_current_spawn_count_multiplier()
{
	return BASE_PLAYER_COUNT_MULTIPLIER + (ADDITIONAL_PLAYER_COUNT_MULTIPLIER * ( level.players.size - 1 ) );
}

spawn_type_vo_monitor()
{
	level endon( "end cycle" );
	currentTime = GetTime();
	nextValidSpitterVOTime = currentTime;
	nextValidQueenVOTime = currentTime;
	
	spitterVOInterval = 15000; //ms
	queenVOInterval = 15000; //ms
	
	while ( true )
	{
		level waittill( "alien_type_spawned", ai_type );
		
		switch( ai_type )
		{
			case "spitter":
				currentTime = GetTime();
				if ( currentTime >= nextValidSpitterVOTime )
				{
					level thread maps\mp\alien\_music_and_dialog::playVOForSpitterSpawn();
					nextValidSpitterVOTime = currentTime + spitterVOInterval;
				}
				break;
				
			case "elite":
				currentTime = GetTime();
				if ( currentTime >= nextValidQueenVOTime )
				{
					level thread maps\mp\alien\_music_and_dialog::playVOForQueenSpawn();
					nextValidQueenVOTime = currentTime + queenVOInterval;
				}
				break;
				
			default:
				break;
		}
	}
}

debug_spawn_info( spawn_time, respawn, requested_amount, modified_amount, spawn_type, actual_amount )
{
	if ( IsDefined(respawn) && respawn )
		spawnTypeDebug = "Respawn=";
	else
		spawnTypeDebug = "Spawn=";
		
	msg = spawnTypeDebug + requested_amount + " " + spawn_type + " Modified=" + modified_amount + " Time=" + spawn_time;
	
	if ( IsDefined( actual_amount ) )
		msg = msg + " Spawned=" + actual_amount;
	
	IPrintLnBold( msg );	
}

spawn_type( ai_type, respawn )
{	
	spawnTime = int( level.current_intensity * level.current_cycle.fullIntensityTime * 0.001 );
	
	if ( ai_type.min_spawned == ai_type.max_spawned )
		desiredSpawnAmount = ai_type.min_spawned;
	else
		desiredSpawnAmount = RandomIntRange( ai_type.min_spawned, ai_type.max_spawned );
	modifiedDesiredSpawnAmount = max( 1, int ( desiredSpawnAmount * get_current_spawn_count_multiplier() ) );
	spawnedAliens = [];
	
	level notify( "alien_type_spawned", ai_type.type_name );
	
	// TODO: Possibly make this tuneable in the string table so any alien type can be spawned from a meteor
	if ( ai_type.type_name == "minion" )
	{
		/#
		if ( GetDvarInt( "scr_alienspawninfo", 0 ) == 1 ) 
		{
			debug_spawn_info( spawnTime, respawn, desiredSpawnAmount, modifiedDesiredSpawnAmount, ai_type.type_name );
		}
		#/
		
		level thread spawn_meteor_aliens( modifiedDesiredSpawnAmount, ai_type.type_name );
		wait level.min_spawn_interval;
		return [];
	}	
	
	for ( spawnIndex = 0; spawnIndex < modifiedDesiredSpawnAmount; spawnIndex++ )
	{
		// TODO: Possibly rework to spread the spawn out amongst types if we're close to the max count when respawning so at least one of each type is spawned
		if ( get_current_agent_count() >= MAX_ALIEN_COUNT )
			break;
		
		alien = spawn_alien( ai_type.type_name );
		spawnedAliens[spawnedAliens.size] = alien;
	
		listIndex = 0;
		if ( IsDefined ( level.current_cycle.currently_spawned[ai_type.type_name] ) )
			listIndex = level.current_cycle.currently_spawned[ai_type.type_name].size;
		level.current_cycle.currently_spawned[ai_type.type_name][listIndex] = alien;

		wait level.min_spawn_interval;
	}
	
	/#
	if ( GetDvarInt( "scr_alienspawninfo", 0 ) == 1 ) 
	{
		debug_spawn_info( spawnTime, respawn, desiredSpawnAmount, modifiedDesiredSpawnAmount, ai_type.type_name, spawnedAliens.size );
	}
	#/
	
	return spawnedAliens;
}

spawn_meteor_aliens( desired_spawn_amount, alien_type )
{
	if ( desired_spawn_amount >= 9 )
		alien_per_meteoroid = int( desired_spawn_amount / 3 );
	else
		alien_per_meteoroid = 4;
		
	while ( desired_spawn_amount > 0 )
	{
		count = alien_per_meteoroid;
		if ( desired_spawn_amount < alien_per_meteoroid )
			count = desired_spawn_amount;
		
		level thread maps\mp\alien\_spawnlogic::spawn_alien_meteoroid( alien_type, count );
		level.pending_meteor_spawns += count;
		desired_spawn_amount -= count;
		
		// random wait
		wait RandomIntRange( 5, 10 );
	}	
}

monitor_meteor_spawn( alien_type )
{
	level endon( "end_cycle" );
	
	while ( true )
	{
		level waittill( "meteor_aliens_spawned", aliens, requestedCount );
		
		foreach ( alien in aliens )
		{
			if ( !IsAlive( alien ) )
				continue;
			
			alienType = alien maps\mp\alien\_utility::get_alien_type();
			listIndex = 0;
			if ( IsDefined ( level.current_cycle.currently_spawned[alienType] ) )
				listIndex = level.current_cycle.currently_spawned[alienType].size;
			
			level.current_cycle.currently_spawned[alienType][listIndex] = alien;
		}
		
		level.pending_meteor_spawns -= requestedCount;
	}
}

get_current_agent_count()
{
	currentCount = 0;
	prune_currently_spawned();
	
	foreach ( aiType in level.current_cycle.currently_spawned )
	{
		currentCount += aiType.size;		
	}
	
	return currentCount + level.pending_meteor_spawns;
}

spawn_alien( ai_type )
{
	spawnPoint = find_safe_spawn_point( ai_type );
	spawnAngles = ( 0, 0, 0 );
	if ( IsDefined( spawnPoint.angles ) )
		spawnAngles = spawnPoint.angles;
	
	spawnType = "wave" + " " + ai_type;
	alien = maps\mp\gametypes\aliens::addAlienAgent( "axis", spawnPoint.origin, spawnAngles, spawnType );

	spawnPoint.last_used_time = GetTime();
	
	if ( level.play_alien_wave_spawn_sound )
	{
		playSoundAtPos( spawnPoint.origin, WAVE_SPAWN_SOUND );
		level.play_alien_wave_spawn_sound = false;
	}
	
	return alien;
}

find_safe_spawn_point( type_name )
{
	playerVolumes = get_current_player_volumes();
	
	if ( playerVolumes.size == 0 )
	{
		// temp fallback if nobody is in a volume. Will be updated, probably to pick spot around guy who needs a close spawn the most
		spawnLocationInfo = find_random_spawn_node( level.temp_spawn_locs, type_name, ::filter_spawn_point_by_distance_from_player );
		return spawnLocationInfo[ "node" ];
	}
	else if ( playerVolumes.size == 1 )
	{
		foreach ( index, player in playerVolumes )
		{
			if ( level.spawn_zones[index].spawn_nodes.size == 0 )
				continue;
			
			spawnLocationInfo =  find_random_spawn_node( level.spawn_zones[index].spawn_nodes, type_name );
			return spawnLocationInfo[ "node" ];
		}
	}

	return find_safe_spawn_spot_with_volumes( playerVolumes, type_name );
}

filter_spawn_point_by_distance_from_player( spawnNode )
{
	testLocation = level.players[0].origin;
	return DistanceSquared( testLocation, spawnNode.origin ) > level.safe_spawn_distance_sq;
}

find_random_spawn_node( spawn_nodes, type_name, filter_func, filter_optional_param )
{
	/# 
	if ( level.debug_spawn_director_active )
		return debug_find_spawn_node( spawn_nodes );
	#/
		
	spawn_nodes = array_randomize( spawn_nodes );
	bestIndex = 0;
	minDesiredTimeSinceUsed = RandomFloatRange( level.spawn_point_last_used_duration * 0.5, level.spawn_point_last_used_duration * 0.75 );
	bestTimeSinceUsed = 0.0;
	foundValidNode = false;
	
	for ( nodeIndex = 0; nodeIndex < spawn_nodes.size; nodeIndex++ )
	{
		spawnNode = spawn_nodes[nodeIndex]["location"];
		
		if ( IsDefined( filter_func ) && !passes_spawn_node_filter( spawnNode, filter_func, filter_optional_param ) )
			continue;
		
		if ( !is_valid_spawn_node_for_type ( spawn_nodes[nodeIndex]["types"], type_name ) )
			continue;

		if ( !IsDefined( spawnNode.last_used_time ) )
		{
			foundValidNode = true;
			break;
		}
		
		timeSinceUsed = GetTime() - spawnNode.last_used_time;
		
		if  ( timeSinceUsed > minDesiredTimeSinceUsed )
		{
			foundValidNode = true;
			break;
		}
		
		if ( timeSinceUsed > bestTimeSinceUsed )
		{
			bestTimeSinceUsed = timeSinceUsed;
			bestIndex = nodeIndex;
		}
	}
	
	nodeInfo = [];
	nodeInfo[ "node" ] = spawn_nodes[bestIndex]["location"];
	nodeInfo[ "validNode" ] = foundValidNode;
	
	return nodeInfo;
}

/#
debug_find_spawn_node( spawn_nodes )
{
	if ( level.debug_spawn_director_spawn_index >= spawn_nodes.size )
		level.debug_spawn_director_spawn_index = 0;
	
	nodeInfo = [];
	nodeInfo[ "node" ] = spawn_nodes[level.debug_spawn_director_spawn_index]["location"];
	nodeInfo[ "validNode" ] = true;
	level.debug_spawn_director_spawn_index++;
	
	return nodeInfo;		
}
#/

is_valid_spawn_node_for_type ( valid_types, type_name )
{
	if ( valid_types.size == 0 )
			return true;
	
	foreach ( ai_type in valid_types )
	{
		if ( ai_type == type_name )
			return true;
	}
	
	return false;
}

passes_spawn_node_filter( spawn_node, filter_func, filter_optional_param )
{
	if ( IsDefined( filter_optional_param ) )
		return [[ filter_func ]]( spawn_node, filter_optional_param );
	
	return [[ filter_func ]]( spawn_node );
}

find_safe_spawn_spot_with_volumes( player_volumes, type_name )
{
	sortedVolumes = score_and_sort_spawn_zones( player_volumes );
		
	foreach ( zone in sortedVolumes )
	{
		if ( level.spawn_zones[zone.name].spawn_nodes.size == 0 )
			continue;
		
		playersToTest = [];
		foreach( index, zoneVolume in player_volumes )
		{
			if ( index != zone.name )
				playersToTest = array_combine( playersToTest, zoneVolume.players );
		}
		
		spawnLocationInfo = find_random_spawn_node( level.spawn_zones[zone.name].spawn_nodes, type_name, ::is_safe_spawn_location, playersToTest );
		if ( spawnLocationInfo[ "validNode" ] )
			return spawnLocationInfo[ "node" ];
		
		// TODO: Possibly search outwards for more nodes to try in order to force the higher scored zone to be used before moving to next zone
	}
	
	// temp fallback, return random
	spawnLocationInfo = find_random_spawn_node( level.temp_spawn_locs, type_name, ::filter_spawn_point_by_distance_from_player );
	return spawnLocationInfo[ "node" ];
}

score_and_sort_spawn_zones( spawn_zones )
{
	playerProximity = calculate_player_proximity_scores();
	
	foreach ( zone in spawn_zones )
	{
		zoneScore = 0.0;
		
		foreach( player in zone.players )
		{
			zoneScore += level.player_in_zone_score_modifier;
			if ( IsDefined( player.current_attackers ) )
				zoneScore -= player.current_attackers.size * level.current_attacker_in_zone_score_modifier;
			
			if ( IsDefined( playerProximity[player.name] ) && ( playerProximity[player.name] > level.group_break_away_distance_sq) )
				zoneScore += min( level.max_break_away_zone_score_increase, playerProximity[player.name] / level.group_break_away_distance_sq );
		}
		
		zoneScore -= get_number_of_recently_used_spawn_points_in_zone( zone ) * level.recently_used_spawn_zone_score_modifier;
		
		// TODO: Possibly slightly increment score based on number of available spawn nodes for that zone
		
		zone.zone_score = zoneScore;
	}
	
	return sort_array( spawn_zones, ::sort_zone_score_func );
}

calculate_player_proximity_scores()
{
	playerProximity = [];
	
	if ( level.players.size <= 2 )
		return playerProximity;
	
	for ( playerIndex = 0; playerIndex < level.players.size; playerIndex++ )
	{
		playerName = level.players[playerIndex].name;
		if ( !IsDefined( playerProximity[playerName] ) )
			playerProximity[playerName] = 99999999.0;
		
		for ( closePlayerIndex = playerIndex + 1; closePlayerIndex < level.players.size; closePlayerIndex++ )
		{
			distanceSq = DistanceSquared( level.players[playerIndex].origin, level.players[closePlayerIndex].origin );
			if ( distanceSq < playerProximity[playerName])
				playerProximity[playerName] = distanceSq;
			
			closePlayerName = level.players[closePlayerIndex].name;
			if ( !IsDefined( playerProximity[closePlayerName] ) || distanceSq < playerProximity[closePlayerName] )
				playerProximity[closePlayerName] = distanceSq;
		}
	}
	
	return playerProximity;
}

get_number_of_recently_used_spawn_points_in_zone( zone )
{
	recentlyUsedCount = 0;
	currentTime = GetTime();
	
	for ( nodeIndex = 0; nodeIndex < level.spawn_zones[zone.name].spawn_nodes.size; nodeIndex++ )
	{
		spawnPoint = level.spawn_zones[zone.name].spawn_nodes[nodeIndex]["location"];
		if ( IsDefined( spawnPoint.last_used_time ) )
		{
			elapsedTime = currentTime - spawnPoint.last_used_time;
			if ( elapsedTime < level.spawn_point_last_used_duration )
				recentlyUsedCount++;
		}
	}
	
	return recentlyUsedCount;
}

sort_zone_score_func( test_entry, base_entry )
{
	return test_entry.zone_score > base_entry.zone_score;		
}

is_safe_spawn_location( spawnLocation, playersToTest )
{
	foreach ( player in playersToTest )
	{
		if ( DistanceSquared( spawnLocation.origin, player.origin ) > level.safe_spawn_distance_sq )
			continue;
			
		if ( has_line_of_sight( spawnLocation.origin, player.origin ) )
		    return false;
	}
	
	return true;
}	

has_line_of_sight( spawnLocation, playerLocation )
{
	while ( max_traces_reached() )
		wait 0.05;
	
	level.spawn_node_traces_this_frame++;
	
	return BulletTracePassed( spawnLocation, playerLocation, false, undefined );
}

get_current_player_volumes()
{
	spawnZoneVolumes = [];
	currentVolumes = [];
	
	foreach ( zone in level.spawn_zones )
	{
		spawnZoneVolumes[spawnZoneVolumes.size] = zone.volume;
	}
	
	foreach ( player in level.players )
	{
		playerCurrentVolumes = player GetIsTouchingEntities( spawnZoneVolumes );
		foreach ( volume in playerCurrentVolumes )
		{
			entryIndex = 0;
			if ( !IsDefined( currentVolumes[volume.script_linkName] ) )
			{
				volumeName = volume.script_linkName;
				currentVolumes[volumeName] = SpawnStruct();
				currentVolumes[volumeName].players = [];
				currentVolumes[volumeName].origin = volume.origin;
				currentVolumes[volumeName].name = volumeName;
			}
			
			entryIndex = currentVolumes[volume.script_linkName].players.size;
			currentVolumes[volume.script_linkName].players[entryIndex] = player;
		}
	}
	
	return currentVolumes;
}

max_traces_reached()
{
	MAX_TRACE_COUNT_PER_FRAME = 5;
	if ( gettime() > level.spawn_node_traces_frame_time )
	{
		level.spawn_node_traces_frame_time = gettime();
		level.spawn_node_traces_this_frame = 0;
	}
	
	return level.spawn_node_traces_this_frame >= MAX_TRACE_COUNT_PER_FRAME;	
}
