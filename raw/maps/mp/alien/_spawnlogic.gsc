#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\_utility;


// ========================================================
// 						WAVE SPAWN
// ========================================================
/*
 * - One spawner ent per AI type, spawner ent is moved to spawn locations to spawn AI
 * - Spawn locations are script_structs; targetname = alien_spawn_struct; script_noteworthy = easy normal hard <- types
*/

CONST_DEFAULT_PREGAME_DELAY				= 5;		// time delay before first cycle starts after hitting wave trigger
CONST_DEFAULT_MAX_CYCLE_INTERMISSION    = 150;		// max time delay between cycles
CONST_DEFAULT_MIN_CYCLE_INTERMISSION    = 90;		// min time delay between cycles
CONST_DEFAULT_WAVE_INTERMISSION			= 7;		// time delay between waves
CONST_WAVE_END_WITH_ALIEN_NUM			= 1;		// number of aliens left in a wave before wave ends
CONST_MAX_LURKER_COUNT                  = 12;       // when adding more lurkers, the max number of lurkers that will be in the level
CONST_MIN_LURKER_COUNT                  = 8;        // when adding more lurkers, the min number of lurkers that will be in the level

/*
=============
///ScriptDocBegin
"Name: spawnAlien( origin, angles, alien_type )"
"Summary: Spawns an Alien"
"Module: Utility"
"MandatoryArg: <array>: Array of spawners"
"MandatoryArg: <func>: Function to run on the guy when he spawns"
"OptionalArg: <param1> : An optional parameter."
"OptionalArg: <param2> : An optional parameter."
"OptionalArg: <param3> : An optional parameter."
"OptionalArg: <param4> : An optional parameter."
"Example: spawnAlien( origin, target_angles, "drone" );"
"SPMP: multiplayer"
///ScriptDocEnd
=============
*/
spawnAlien( origin, angles, alien_type )
{
	return maps\mp\gametypes\aliens::addAlienAgent( "axis", origin, angles, alien_type );
}

alien_health_per_player_init()
{
	level.alien_health_per_player_scalar = [];
	level.alien_health_per_player_scalar[ 1 ] = 1;
	level.alien_health_per_player_scalar[ 2 ] = 1.375; // 20%
	level.alien_health_per_player_scalar[ 3 ] = 1.5; // 20%
	level.alien_health_per_player_scalar[ 4 ] = 1.625; // 20%
}

alien_wave_init()
{
	// populates AI type attribute into level.alien_types[]

	level.use_spawn_director = 1;
		
	if ( use_spawn_director() )
	{
		maps\mp\alien\_spawn_director::init();
	}
	else
	{
		// initializes spawn table
		maps\mp\alien\_director::wave_spawn_table_init();
		assertex( isdefined( level.strongholds ), "Stronghold wave table not initialized (yet)" );
	}
	
	// init spawn locs
	wave_spawners_init();
}

alien_lurker_init()
{
	if ( !alien_mode_has( "lurker" ) )
		return;
	
	// mode defines when lurkers are suppose to be active
	flag_init( "lurker_active" );
	
	thread init_patrol_paths();
	
	spawn_locs = getstructarray( "alien_spawn_struct", "targetname" );
	
	// lurker spawners init
	level.alien_lurkers = [];
	level.max_lurker_population = 18;
	
	// defined spawner types
	foreach ( key_string, type in level.alien_types )
	{
		alien_lurker_struct 				= SpawnStruct();
		alien_lurker_struct.spawn_locs 		= [];
		
		level.alien_lurkers[ key_string ] 	= alien_lurker_struct;
	}

	foreach ( spawn_loc in spawn_locs )
	{
		msg_prefix = "Spawn location at: " + spawn_loc.origin + " ";
		
		if ( isdefined( spawn_loc.script_noteworthy ) && spawn_loc.script_noteworthy != "" )
		{
			spawn_types = strtok( spawn_loc.script_noteworthy, " " );
			
			// script_noteworthy exp: "lurker: brute cloaker spitter"
			if( !IsSubStr( spawn_loc.script_noteworthy, "lurker" ) )
				continue;
			else
				spawn_types = array_remove( spawn_types, spawn_types[ 0 ] ); // remove "lurker:"
			
			// get spawn trigger
			spawn_loc.spawn_trigger = getent( spawn_loc.target, "targetname" );
			assert( IsDefined( spawn_loc.spawn_trigger ) );
			
			// ASSERT as we are missing spawn types for this location!
			assertex( spawn_types.size > 0, msg_prefix + "does not have enough spawn types" );
			
			foreach ( type in spawn_types )
			{
				if ( isdefined( level.alien_lurkers[ type ] ) )
				{
					level.alien_lurkers[ type ].spawn_locs[ level.alien_lurkers[ type ].spawn_locs.size ] = spawn_loc;
				}
				else
				{
					assertex( true, msg_prefix + "has unknown spawn type: " + type );
				}
			}
		}
		else if ( !use_spawn_director() )
		{
			assertex( false, msg_prefix + "is missing spawner type (script_noteworthy = brute cloaker spitter)" );
		}
	}
	
	level notify ( "alien_lurkers_spawn_initialized" );
	
	if ( !alien_mode_has( "nogame" ) )
		thread lurker_loop();
}

init_patrol_paths()
{
	level.patrol_start_nodes = Getstructarray( "patrol_start_node", "targetname" );
}


// organize spawn locations into level.alien_wave[]
wave_spawners_init()
{
	// spawn locations
	level.alien_wave = [];
	
	// defined spawner types
	foreach ( key_string, type in level.alien_types )
	{
		alien_wave_struct = SpawnStruct();
		alien_wave_struct.spawn_locs = [];
		
		level.alien_wave[ key_string ] = alien_wave_struct;
	}
	
	alien_spawn_locs = getstructarray( "alien_spawn_struct", "targetname" );
	assertex( isdefined( alien_spawn_locs ) && alien_spawn_locs.size > 0, "Not enough spawn locations (alien_spawn_struct)" );
	
	foreach ( spawn_loc in alien_spawn_locs )
	{
		msg_prefix = "Spawn location at: " + spawn_loc.origin + " ";
		
		if ( isdefined( spawn_loc.script_noteworthy ) && spawn_loc.script_noteworthy != "" )
		{
			spawn_types = strtok( spawn_loc.script_noteworthy, " " );
			
			// ignore lurker spawn locs
			if( IsSubStr( spawn_loc.script_noteworthy, "lurker" ) )
				continue;
						
			// ASSERT as we are missing spawn types for this location!
			assertex( spawn_types.size > 0, msg_prefix + "does not have enough spawn types" );
			
			foreach ( type in spawn_types )
			{
				if ( isdefined( level.alien_wave[ type ] ) )
					level.alien_wave[ type ].spawn_locs[ level.alien_wave[ type ].spawn_locs.size ] = spawn_loc;
				else
					assertex( true, msg_prefix + "has unknown spawn type: " + type );
			}
		}
		else if ( !use_spawn_director() )
		{
			assertex( false, msg_prefix + "is missing spawner type (script_noteworthy = brute cloaker spitter)" );
		}
	}
	
	level notify ( "alien_wave_spawn_initialized" );
}

assign_alien_attributes( alien_type )
{
	// self is spawned AI
	self endon( "death" );
	
	spawn_type = "none";
	
	// if spawn type is passed in, it is the first token delimited by space
	spawn_type_config = strtok( alien_type, " " );
	if ( isdefined( spawn_type_config ) && spawn_type_config.size == 2 )
	{
		if ( spawn_type_config[ 0 ] == "lurker" )
			spawn_type = "lurker";
		
		if ( spawn_type_config[ 0 ] == "wave" )
			spawn_type = "wave";
		
		alien_type = spawn_type_config[ 1 ];
	}
	
	assertex( spawn_type != "none", "spawn type defined does not exist - none" );
	assertex( isdefined( level.alien_types ), "Must run _alien::main() before _spawner::wave_spawners_init()" );
	
	// set health
	if ( isDefined( level.players ) && level.players.size > 0 )
	{
		health = level.alien_types[ alien_type ].attributes[ "health" ] * level.alien_health_per_player_scalar[ level.players.size ];
	}
	else
	{
		health = level.alien_types[ alien_type ].attributes[ "health" ];
	}
	
	self maps\mp\agents\_agents::set_agent_health( int( health ) );
	self.max_health	        = health;
	self.alien_type			= level.alien_types[ alien_type ].attributes[ "ref" ];
	
	self.moveplaybackrate 	= level.alien_types[ alien_type ].attributes[ "speed" ] * RandomFloatRange( 0.95, 1.05 );
	self.animplaybackrate 	= self.moveplaybackrate;
	self.xyanimscale		= level.alien_types[ alien_type ].attributes[ "scale" ];
	
	if ( spawn_type == "lurker" )
	{
		self thread alien_lurker_behavior();
		self.lurker = true;
	}
	
	if ( spawn_type == "wave" )
	{
		// TODO: alien behavior in MP needs to be worked on
		self thread alien_wave_behavior();
		self.wave_spawned = true;
	}
	
	if ( alien_type == "minion" )
	{
		self delayThread( 1.0, ::add_lurker_fx );
	}
	
	// TEMP: disable cloaking
	// TODO: reenable cloaking after fx is pretty
	/*
	if ( level.alien_types[ alien_type ].attributes[ "behavior_cloak" ] == 1 )
	{
		self thread maps\mp\alien\_director::alien_cloak();
	}*/
}

add_lurker_fx()
{
	if ( !isAlive( self ) )
	{
		return;
	}
	
	self endon( "death" );
	self lurker_fx_on();
	
	while ( 1 )
	{
		self waittill( "jump_land" );
		self lurker_fx_off();
		self waittill( "jump_finished" );
		self lurker_fx_on();
	}
}

lurker_fx_on()
{
	wait 0.05;
	playFxOnTag( level._effect[ "vfx_alien_minion" ], self, "tag_origin" );	
}

lurker_fx_off()
{
	KillFXOnTag( level._effect[ "vfx_alien_minion" ], self, "tag_origin" );
}

/************************/
/* Main wave spawn loop */
/************************/
alien_wave_spawn_think()
{
	pregame_delay();
	
	// wait till mist entered before spawning waves
	if ( alien_mode_has( "mist" ) )
		wait level.MIST_ENTER_TIME;
		
	level notify ( "alien_wave_spawn_started" );
	
	level thread maps\mp\alien\_music_and_dialog::playVOForWaveStart();
	
	level thread current_stronghold_update();
	
	/* for temp kill count*/ level.current_alien_count = 0;
	
	cycle_count = 1;

/#
	if ( GetDvarInt( "scr_startingcycle" ) > 0 )
	{
		cycle_count = GetDvarInt( "scr_startingcycle" ) + 1;
	}
#/
	
	while ( 1 )
	{
		level notify( "alien_cycle_started" );
		
		stronghold  = get_current_stronghold();			// string: 		each stronghold has its own sets of cycles
		cycle_index = get_current_cycle();				// int:			cycle increment
		
		if ( use_spawn_director() )
		{
			maps\mp\alien\_spawn_director::start_cycle( cycle_count );
			while ( !flag( "drill_detonated" ) )
				wait 0.05;
			maps\mp\alien\_spawn_director::end_cycle();
			maps\mp\alien\_collectibles::handle_cycle_end();
		}
		else
		{
			spawn_waves( stronghold, cycle_index, cycle_count );	
		}
		
		wait 0.05;

		intermission_delay();
		
		// wait till mist entered before spawning waves
		if ( alien_mode_has( "mist" ) )
			wait level.MIST_ENTER_TIME;
			
		// [UPDATING] increment current cycle
		if ( !use_spawn_director() && !is_cycle_repeated( stronghold, cycle_index ) )
		{
			cycle_index++;
			level.alien_wave_status[ "cycle" ] = cycle_index;
		}
		
		cycle_count++; // for displaying total cycle number
	}
}

pregame_delay()
{
	level endon( "force_cycle_start" );
	
	if ( isdefined( level.alien_pregame_delay ) )
	{
		level notify( "alien_cycle_prespawning", level.alien_pregame_delay );
		level notify( "alien_wave_prespawning", level.alien_pregame_delay );
		pregame_delay = level.alien_pregame_delay;
	}
	else
	{
		level notify( "alien_cycle_prespawning", CONST_DEFAULT_PREGAME_DELAY );
		level notify( "alien_wave_prespawning", CONST_DEFAULT_PREGAME_DELAY );
		pregame_delay = CONST_DEFAULT_PREGAME_DELAY;
	}
	
	wait pregame_delay;
}

intermission_delay()
{
	level endon( "force_cycle_start" );
	
	if ( isdefined( level.alien_cycle_intermission ) )
	{
		level notify( "alien_cycle_prespawning", level.alien_cycle_intermission );
		cycle_intermission = level.alien_cycle_intermission;
	}
	else
	{
		random_intermission_time = RandomIntRange( CONST_DEFAULT_MIN_CYCLE_INTERMISSION, CONST_DEFAULT_MAX_CYCLE_INTERMISSION + 1 );
		level notify( "alien_cycle_prespawning", random_intermission_time );
		cycle_intermission = random_intermission_time;
	}
	
	wait cycle_intermission;
	
	/*
	while ( cycle_intermission )
	{
		/#
		if ( GetDvarInt( "alien_debug_director" ) > 0 )
		{
			if ( cycle_intermission == 10 )
				iprintln( "Next cycle in 10 seconds" );
			
			if ( cycle_intermission <= 3 )
				iprintln( cycle_intermission );
		}
		#/
		
		wait 1;
		cycle_intermission--;
	}*/
}


spawn_waves( stronghold, cycle_index, cycle_count )
{
	waves = get_waves( stronghold, cycle_index );	// structs []:	array of wave structs
		
	waves_spawned = 0;	
	
	// looping through waves
	offset_index = 1;
	for ( index = offset_index; index < waves.size + offset_index; index++ )
	{
		wave = waves[ index ];
		
		level notify( "alien_wave_started" );
		
		// [UPDATING] current wave status
		level.alien_wave_status[ "wave" ] = index;
		
		spawn_types	= get_current_wave_types(); 	// string []:	array of spawn types in string
		
		// debug print
		repeating = "";
		if ( is_cycle_repeated( stronghold, cycle_index ) )
			repeating = "[R]";				
		/#
		if ( GetDvarInt( "alien_debug_director" ) > 0 )
		{
			IPrintLn( "Stronghold: " + stronghold + " - Cycle: " + cycle_count + repeating + " - Wave: " + index );
		}
		#/			
		
		// spawn the wave, it may have one or many AI types mixed
		wave_spawn( spawn_types );
		waves_spawned++;
		
		wait 1;
		
		// wait for number of aliens left before wave ends
		while ( true )
		{
			wave_alien_remain = 0;
			
			foreach( alien in level.agentArray )
			{
				if ( IsDefined( alien.wave_spawned ) && alien.wave_spawned && IsAlive( alien ) )
					wave_alien_remain++;
			}
			
			if ( wave_alien_remain <= CONST_WAVE_END_WITH_ALIEN_NUM )
				break;
			
			wait 1;
		}
				
		level notify( "alien_wave_ended" );
		
		if ( waves_spawned >= waves.size )
		{
			// =====================================
			// TEMP TEMP TEMP TEMP OMG TEMP TEMP
			// =====================================				
			if ( alien_mode_has( "airdrop" ) && index == waves.size && !flag( "drill_detonated" ) )
			{
				level notify( "alien_wave_repeating" );
			}
			else
			{
				level notify( "alien_cycle_ended" );
				
				/#
				if ( GetDvarInt( "alien_debug_director" ) > 0 )
					iprintlnbold( "Cycle Completed!" );
				#/
			}
		}
		
		if ( isdefined( level.alien_wave_intermission ) )
		{
			level notify( "alien_wave_prespawning", level.alien_wave_intermission );
			wait level.alien_wave_intermission;
		}
		else
		{
			level notify( "alien_wave_prespawning", CONST_DEFAULT_WAVE_INTERMISSION );
			wait CONST_DEFAULT_WAVE_INTERMISSION;
		}

		// =====================================
		// TEMP TEMP TEMP TEMP OMG TEMP TEMP
		// =====================================
		// TODO: rescript logic for spawning waves for a timed defend in airdrop mode
		// TEMP: if airdrop is enabled, keep respawning last wave if bomb not set and exploded
		if ( alien_mode_has( "airdrop" ) && index == waves.size && !flag( "drill_detonated" ) )
		{
			index--;			// repeat last wave

			/#
			if ( GetDvarInt( "alien_debug_director" ) > 0 )
				iprintlnbold( "bomb has not exploded, respawning wave: " + ( index + 1 ) );
			#/
		}
	}	
}

// spawns single wave, could consist one or many AI types within the wave
wave_spawn( spawn_types )
{
	level endon( "alien_wave_spawn_break" );

	// may be more than one AI types in this wave
	foreach( spawn_type in spawn_types )
	{
		// per AI type, how many AI to spawn
		AI_count_per_type = get_current_wave_type_count( spawn_type );

		// spawn a wave from afar
		wave_spawn_raw( spawn_type, AI_count_per_type ); // has delay
	}
}


// spawns alien wave of a particular type and count - spawns alien farthest from all players
wave_spawn_raw( type, alien_count, min_spawn_dist, max_spawn_dist, spawned_aliens )
{
	// list of aliens already spawned before this call
	if ( !isdefined( spawned_aliens ) )
		spawned_aliens		= [];	//  list of alien AI spawned
	
	avoid_locs 				= [];	// array of ents to avoid
	avoid_locs 				= get_players();

	all_spawn_locs			= [];
	remaining_spawn_locs 	= [];
	
	// optional random selection of farthest subset spawn location size
	random_spawn_loc_size	= 2;		// the higher this number the close it will spawn but more random

	if ( !isdefined( max_spawn_dist ) )
		max_spawn_dist 		= 5000;
	
	if ( !isdefined( min_spawn_dist ) )
		min_spawn_dist		= 2000;
	
	padding_factor 			= 1.25; // used for padding distances
	spawn_loc 				= undefined;
	spawn_from_closest		= false;
	
	// spawn closer if mist is here
	if ( flag_exist( "mist_active" ) && flag( "mist_active" ) )
	{
		min_spawn_dist 	= 500 * padding_factor;
		
		if ( isdefined( level.mist_fog ) )
			min_spawn_dist = level.mist_fog[ "half" ] * 2 * padding_factor; // effectively at 0 vis
		
		spawn_from_closest = true;
	}
	
	// filter with locations < max_spawn_dist
	foreach ( spawn_loc in level.alien_wave[ type ].spawn_locs )
	{
		foreach ( player in get_players() )
		{
			if ( Distance2D( spawn_loc.origin, player.origin ) < max_spawn_dist )
				remaining_spawn_locs[ remaining_spawn_locs.size ] = spawn_loc;
		}
	}
	all_spawn_locs = remaining_spawn_locs;
	assertex( all_spawn_locs.size, "Did not find spawn locations within: " + max_spawn_dist + " units." );
	
	// main spawn loop
	for ( i = 0; i < alien_count; i++ )
	{
		msg = "Not enough spawners for " + alien_count + " aliens. ";
		msg = msg + "[ spawned:" + spawned_aliens.size + " ]";
		
		// map has gaps where there are not enough spawns within 2000 units of a location
		if ( remaining_spawn_locs.size <= 0 )
		{
			// debug prints
			/#
			if ( GetDvarInt( "alien_debug_director" ) > 0 )
			{
				msg1 = "Not enough spawners near this location!";
				msg2 = "Need " + alien_count + " but spawned " + spawned_aliens.size;
				msg3 = "Spawning " + (alien_count - spawned_aliens.size) + " outside " + max_spawn_dist + " radius";
				IPrintLn( msg1 );
				IPrintLn( msg2 );
				IPrintLn( msg3 );
			}
			#/
			
			// recursive call to spawn remaining aliens with larger range		
			wave_spawn_raw( type, int( max( alien_count - spawned_aliens.size, 1 ) ), min_spawn_dist / padding_factor,  max_spawn_dist * padding_factor, spawned_aliens );
			return;
		}
	
		// build smaller array of spawn locations to randomly spawn with
		chosen_nodes = [];
		chosen_avoid_loc = avoid_locs[ RandomInt( avoid_locs.size ) ];
		
		// sort closest first if in mist
		remaining_spawn_locs = SortByDistance( remaining_spawn_locs, chosen_avoid_loc.origin );
		
		// sort farthest first if not in mist
		if ( !spawn_from_closest )
			remaining_spawn_locs = array_reverse( remaining_spawn_locs );
		
		// filter with locations > min_spawn_dist
		for ( j = 0; j < remaining_spawn_locs.size; j++ )
		{
			if ( min_dist_from_all_locations( remaining_spawn_locs[j], avoid_locs, min_spawn_dist ) )
			{
				chosen_nodes[ chosen_nodes.size ] = remaining_spawn_locs[j];
			}
			
			if ( chosen_nodes.size == random_spawn_loc_size )
			{
				break;
			}
		}
		
		// Fuck it
		if ( chosen_nodes.size == 0 )
		{
			if ( spawn_from_closest )
				spawn_loc = remaining_spawn_locs[ 0 ];
			else
				spawn_loc = remaining_spawn_locs[ remaining_spawn_locs.size - 1 ];
				
			// debug prints
			/#
			if ( GetDvarInt( "alien_debug_director" ) > 0 )
			{
				msg1 = "Not enough spawners near this location!";
				msg2 = "Need " + alien_count + " but spawned " + spawned_aliens.size;
				msg3 = "Spawning " + (alien_count - spawned_aliens.size) + " outside " + max_spawn_dist + " radius";
				IPrintLn( msg1 );
				IPrintLn( msg2 );
				IPrintLn( msg3 );
			}
			#/			
			
		}
		else
		{
			random_index 	= randomintrange( 0, chosen_nodes.size );
			spawn_loc 		= chosen_nodes[ random_index ];
		}
	
		assert( isdefined( spawn_loc ) );

		// MP spawning ===========================
		spawner_origin 		= spawn_loc.origin;
		spawner_angles 		= ( 0, 0, 0 );
		if ( isdefined( spawn_loc.angles ) )
			spawner_angles 	= spawn_loc.angles;
		
		spawn_type = "wave";
		spawn_type_config = spawn_type + " " + type;
		
		agent = spawnAlien( spawner_origin, spawner_angles, spawn_type_config );

		spawned_aliens[ spawned_aliens.size ] = agent;
		
		level notify( "alien_wave_spawn_single", spawned_aliens[ spawned_aliens.size ] );

		// all_spawn_locs now less the recently used
		all_spawn_locs 			= array_remove( all_spawn_locs, spawn_loc );
		remaining_spawn_locs 	= all_spawn_locs;
	}
	
	// debug print
	/#
	if ( GetDvarInt( "alien_debug_director" ) > 0 )
	{
		IPrintLn( "Type: " + type + " - Count: " + spawned_aliens.size );
	}
	#/
		
	level notify( "alien_wave_spawn_complete", spawned_aliens );
	
	return spawned_aliens;
}

/**************************/
/* Main lurker spawn loop */
/**************************/

lurker_loop()
{
	level endon( "game_ended" );
		
	//lurker_spawn_delay = 0; // seconds delay before lurker spawn triggers are active
	//delayThread( lurker_spawn_delay, ::flag_set, "lurker_active" );
	
	// assuming mode doesn't start with mist on
	flag_set( "lurker_active" );
	
	while ( true )
	{
		// lurker settings
		ai_event_settings();
		
		// TODO: define logic for which types of lurker to spawn
		type = "brute";
		foreach ( lurker_spawn_struct in level.alien_lurkers[ type ].spawn_locs )
		{
			lurker_spawn_struct notify( "new_listener" );
			lurker_spawn_struct thread lurker_listen_trigger( type );
		}
		
		// ^
		// during this time, the lurkers lurk!
		// v
		
		level waittill( "alien_cycle_prespawning", countdown );
		
		ahead_of_time = 10; // seconds ahead before wave starts
		wait ( max( 0, countdown - ahead_of_time ) );
		
		flag_clear( "lurker_active" );
		
		level notify( "removing_lurkers" );
		
		// start to get rid of lurkers =========================
		ai_event_settings_reset(); // restore event settings
		
		alive_lurkers = get_alive_lurkers();
		
		foreach ( lurker in alive_lurkers )
			lurker thread send_away_and_die();
		
		wait 6; // usually takes less thand 6 seconds to complete send_away_and_die();
		
		// fail-safe: we have to kill all lurkers to make room for wave!
		if ( get_alive_lurkers().size > 0 )
		{
			foreach( lurker in get_alive_lurkers() )
				lurker Suicide();
		}
		// lurkers all dead, prep for wave spawn ===============
		
		// wait till waves are done, restore lurkers
		level waittill( "alien_cycle_ended" );
		
		flag_set( "lurker_active" );
	}
}

// distance where lurker becomes alerted
CONST_LURKER_ALERT_DIST 			= 512;
CONST_LURKER_GUNSHOT_ALERT_DIST 	= 512;

ai_event_settings()
{
	level.old_ai_eventdistgunshot 			= GetDvarInt( "ai_eventdistgunshot" );
	level.old_ai_eventdistgunshotteam		= GetDvarInt( "ai_eventdistgunshotteam" );
	level.old_ai_eventdistnewenemy 			= GetDvarInt( "ai_eventdistnewenemy" );
	level.old_ai_eventdistdeath 			= GetDvarInt( "ai_eventdistdeath" );
	
	SetDvar( "ai_eventdistgunshot", 	CONST_LURKER_GUNSHOT_ALERT_DIST );
	SetDvar( "ai_eventdistgunshotteam", CONST_LURKER_GUNSHOT_ALERT_DIST );
	SetDvar( "ai_eventdistnewenemy", 	CONST_LURKER_ALERT_DIST );
	SetDvar( "ai_eventdistdeath", 		CONST_LURKER_ALERT_DIST );
}

ai_event_settings_reset()
{
	SetDvar( "ai_eventdistgunshot", 	level.old_ai_eventdistgunshot );
	SetDvar( "ai_eventdistgunshotteam", level.old_ai_eventdistgunshotteam );
	SetDvar( "ai_eventdistnewenemy", 	level.old_ai_eventdistnewenemy );
	SetDvar( "ai_eventdistdeath", 		level.old_ai_eventdistdeath );
}

// removes lurkers farthest from players - instantly
remove_farthest_lurker( avoid_ents )
{
	lurkers = get_alive_lurkers();

	while( lurkers.size > 1 )
	{
		foreach ( avoid_ent in avoid_ents )
		{
			far_agent 	= getclosest( avoid_ent.origin, lurkers );
			lurkers 	= array_remove( lurkers, far_agent );
			
			if ( lurkers.size == 1 )
				break;
		}
	}
	
	if ( !lurkers.size )
		return false;
	
	lurkers[ 0 ] Suicide();
}

get_alive_agents()
{
	alive_agents = [];
	foreach ( agent in level.agentArray )
	{
		if ( isalive( agent ) )
			alive_agents[ alive_agents.size ] = agent;
	}
	
	return alive_agents;
}

get_alive_lurkers()
{
	lurkers = [];
	foreach ( agent in level.agentArray )
	{
		if ( isalive( agent ) && isdefined( agent.lurker ) )
			lurkers[ lurkers.size ] = agent;
	}
	
	return lurkers;
}


CONST_LURKER_RESPAWN_TIME = 10;

// lurker's spawn trigger loop
lurker_listen_trigger( type )
{
	level endon( "game_ended" );
	level endon( "removing_lurkers" );
	
	self endon( "new_listener" );
	
	// spawn cool down after spawning
	self.cooldown 		= 0;
	self.spawned_lurker = undefined;
	self.spawn_trigger.reset = false; // false, dont spawn lurkers near player spawn, spawn when player return
	
	// self is spawn_loc
	while ( true )
	{
		// only spawn lurkers when allowed by mode
		if ( !flag( "lurker_active" ) )
		{
			flag_wait( "lurker_active" );
			self.cooldown = 0; // lurkers turned on, all spawn on trigger, previous cool down reset
		}
		
		wait self.cooldown;
		self.cooldown = 0;
		
		// if lurker already spawned here and is still alive
		if ( isdefined( self.spawned_lurker ) && isalive( self.spawned_lurker ) )
		{
			wait 0.05;
		    continue;
		}
		
		if ( !self.spawn_trigger.reset )
			self wait_for_reset();
		
		self.spawn_trigger waittill( "trigger", owner );
		self.spawn_trigger.reset = false;
		
		// if we are over budget with agents, remove lurkers
		if ( get_alive_agents().size >= get_alive_lurkers().size )
		{
			while( get_alive_agents().size >= level.max_lurker_population )
			{
				remove_farthest_lurker( get_players() );
				wait 0.1;
			}
		}
		else
		{
			while( get_alive_lurkers().size >= level.max_lurker_population )
			{
				remove_farthest_lurker( get_players() );
				wait 0.1;
			}
		}
		
		self.cooldown = CONST_LURKER_RESPAWN_TIME; // cool down for next lurker to spawn after previous one is killed

		// spawn the lurker!
		self.spawned_lurker = self spawn_lurker( type );

		// pause loop till death
		self.spawned_lurker waittill( "death" );
	}
}

// wait for everyone out of the trigger!
wait_for_reset()
{
	level endon( "game_ended" );
	level endon( "removing_lurkers" );
	
	self endon( "new_listener" );
	
	is_touching = true;
	while ( is_touching )
	{
		is_touching = false;
		foreach ( player in get_players() )
		{
			if ( player IsTouching( self.spawn_trigger ) )
				is_touching = true;
		}
		
		if ( is_touching )
			wait 0.05;
	}
	
	self.spawn_trigger.reset = true;
}

// sends lurker away from players to get deleted
// this is to make sure they aren't left to attack during mist hit
send_away_and_die()
{
	self endon( "death" );
	self notify( "run_to_death" );
	
/#
	if ( isdefined( self.lurker ) )
		self thread alien_ai_debug_print( "Lurker x_X" );
	else
		self thread alien_ai_debug_print( "x_X" );
#/
	
	// send away
	//self run_cycle();		// breaks slow near player functions
	self maps\mp\agents\alien\_alien_think::set_alien_movemode( "run" );
	self set_ignore_enemy();
	self.moveplaybackrate 	*= 1.25;
	
	far_nodes = GetNodesInRadiusSorted( self.origin, 1000, 10 );
	
	// go somewhere
	self ScrAgentSetGoalNode( far_nodes[ far_nodes.size - 1 ] );
	self ScrAgentSetGoalRadius( 64 );
	self waittill_any_timeout( 5, "goal_reached" );
	
	self clear_ignore_enemy();
		
	// cloak and delete
	smoke_puff();
	
	wait 0.20;
	//TODO: move them outside the map and remove
	
	// kill the agent
	self Suicide();
	
	return true;
}

set_ignore_enemy()
{
	self enable_alien_scripted();
	
	if ( isdefined( self.enemy ) )
		self.enemy.current_attackers = [];
}

clear_ignore_enemy()
{
	self disable_alien_scripted();

	foreach ( player in get_players() )
		self GetEnemyInfo( player );
}

smoke_puff()
{
	PlayFXOnTag( level._effect[ "alien_teleport" ], self, "j_jaw" );
	PlayFXOnTag( level._effect[ "alien_teleport" ], self, "j_spineupper" );
	PlayFXOnTag( level._effect[ "alien_teleport" ], self, "j_mainroot" );
	PlayFXOnTag( level._effect[ "alien_teleport" ], self, "j_tail_3" );
	
	PlayFXOnTag( level._effect[ "alien_teleport_dist" ], self, "j_mainroot" );
}

spawn_lurker( type )
{
	// self is spawn_loc
	assert( isdefined( self ) );

	// MP spawning ===========================
	spawner_origin 		= self.origin;
	spawner_angles 		= ( 0, 0, 0 );
	if ( isdefined( self.angles ) )
		spawner_angles 	= self.angles;
	
	spawn_type = "lurker";
	spawn_type_config = spawn_type + " " + type;
	
	agent = spawnAlien( spawner_origin, spawner_angles, spawn_type_config );
	
	return agent;
}


// WIP seek behavior 
alien_wave_behavior()
{
	self endon( "death" );
	
	// Get perfect knowledge of enemies for now
	foreach ( player in get_players() )
	{
		self GetEnemyInfo( player );
	}
	
	// Attack planted bomb if it exists
	if ( isdefined( level.bomb) && IsSentient( level.bomb ) )
		self GetEnemyInfo( level.bomb );
	
	self.goalradius = 64;
	self.inStandingMelee = false;

/#
	self thread alien_ai_debug_print( self.alien_type );
#/

	//self thread watch_alien_death();
	
	//self thread alien_aggress_sound();
	
	//self thread watch_alien_damage();
	//self.allowpain = false;
}

alien_lurker_behavior()
{
	self endon( "death" );
	self endon( "run_to_death" );
	
	self set_ignore_enemy();
	
/#
	self thread alien_ai_debug_print( "Lurker -_-zZ" );
#/
	
	self thread wakeup_to_player_distance();
	self thread wakeup_to_player_damage();
	//self thread wakeup_to_enemy();
	
	self thread walk_patrol_loop();

	self waittill( "woke" );
	
	self clear_ignore_enemy();
	
/#
	self thread alien_ai_debug_print( "Lurker >:E" );
#/
	
	wait 1; //wait for updates to agent combat variables
	
	// run if is still walking
	if ( self.movemode == "walk" )
		self maps\mp\agents\alien\_alien_think::set_alien_movemode( "run" );
}

wakeup_to_enemy()
{
	self endon( "woke" );
	self endon( "death" );
	self endon( "run_to_death" );
	
	self waittill( "enemy" );
	
	self notify( "woke" );
}

// force ignore and wake up, as ai_event dvars don't seem to work...
wakeup_to_player_distance()
{
	self endon( "woke" );
	self endon( "death" );
	self endon( "run_to_death" );
	
	wakeup = false;
	
	while ( !wakeup )
	{
		foreach ( player in get_players() )
		{
			if ( distance( player.origin, self.origin ) < 512 )
			{
				wakeup = true;
				break;
			}
		}
		
		wait 0.25;
	}
	
	self notify( "woke" );
}

wakeup_to_player_damage()
{
	self endon( "woke" );
	self endon( "death" );
	self endon( "run_to_death" );
	
	while ( true )
	{
		self waittill( "damage", damage, attacker );
		
		if ( isdefined( attacker ) && isalive( attacker ) && isplayer( attacker ) )
			break;
	}
	
	self notify( "woke" );
}

walk_patrol_loop()
{
	self endon( "woke" );
	self endon( "death" );
	self endon( "run_to_death" );
	
	wait 1;
	
	// if the patrol loop is setup we shall walk in circles!
	if ( isdefined( level.patrol_start_nodes ) )
	{
		// get closest patrol path to walk on
		node = getClosest( self.origin, level.patrol_start_nodes );
		
		self maps\mp\agents\alien\_alien_think::set_alien_movemode( "walk" );

		while ( true )
		{
			self ScrAgentSetGoalPos( node.origin );
			self ScrAgentSetGoalRadius( 32 ); // try 64 if 32 is too small
			self waittill( "goal_reached" );
			
			// stops at a node
			if ( IsDefined( node.script_delay ) )
				wait node.script_delay;
			
			node = Getstruct( node.target, "targetname" );
		}
	}
}

alien_ai_debug_print( nametag )
{
	self endon ( "death" );
	self notify ( "new_name_tag" );
	self endon ( "new_name_tag" );
	
	if ( getdvarint( "alien_debug_director" ) == 1 )
	{
		while ( true )
		{
			Print3d( self.origin, nametag, ( 1, 1, 1 ), 0.75, 2, 1 );
			wait 0.05;
		}
	}
}

// ========================================================
// 			spawning aliens via meteoroid impact
// ========================================================

get_available_meteoroid_clip( node )
{
	foreach ( clip in level.meteoroid_clips )
	{
		if ( !isdefined( clip.used_by ) )
		{
			clip.used_by = node;
			return clip;
		}
	}
	
	return undefined;
}

setup_meteoroid_paths()
{
	PreCacheModel( "moab_cliff_rock_01_thin" );
	PreCacheModel( "moab_river_rock_cluster_04" );

	level._effect[ "vfx_alien_lightning_bolt" ] = loadfx( "vfx/gameplay/alien/vfx_alien_lightning_bolt" );
	
	level.meteoroid_impact_nodes = [];
	level.meteoroid_impact_nodes = getstructarray( "meteoroid_impact", "targetname" );
	
	// default clips available for usage (3 max atm)
	level.meteoroid_clips = [];
	level.meteoroid_clips = GetEntArray( "meteoroid_clip", "targetname" );
	foreach ( clip in level.meteoroid_clips )
	{
		clip.used_by = undefined;
		clip.old_origin = clip.origin;
	}
	
	if ( !isdefined( level.meteoroid_impact_nodes ) || level.meteoroid_impact_nodes.size == 0 )
		return;
	
	foreach ( impact_node in level.meteoroid_impact_nodes )
	{
		impact_node.rocks = [];
		impact_node.occupied = false;
			
		targeted_array 	= GetStructArray( impact_node.target, "targetname" );
		
		foreach ( targeted in targeted_array )
		{
			if ( !isdefined( targeted.script_noteworthy ) )
				continue;
			
			// rocks debris
			if ( targeted.script_noteworthy == "rocks" )
			{
				impact_node.rocks[ impact_node.rocks.size ] = targeted;
			}
			
			// end position and model
			if ( targeted.script_noteworthy == "meteoroid_final" )
			{
				impact_node.meteoroid_final_pos 	= targeted.origin;
				impact_node.meteoroid_final_angles 	= targeted.angles;
				impact_node.meteoroid 				= targeted;
				
				// start position vector
				start = getstruct( targeted.target, "targetname" );
				if ( isdefined( start ) )
				{
					impact_node.meteoroid_start_pos 	= start.origin;
					impact_node.meteoroid_start_angles 	= start.angles;
					
					// end position vector, end is when it goes into the ground
					end = getstruct( start.target, "targetname" );
					if ( isdefined( end ) )
					{
						impact_node.meteoroid_end_pos 		= end.origin;
						impact_node.meteoroid_end_angles 	= end.angles;
					}
				}
			}
		}
	}
}

get_meteoroid_impact_node()
{
	// closest: to all players
	CoM = get_center_of_players();
	
	free_nodes = [];
	foreach ( node in level.meteoroid_impact_nodes )
	{
		// only sample nodes 2000 units from center of players - local stronghold
		range = 2000;
		if ( Distance2D( node.origin, CoM ) > range )
		{
			continue;
		}
		
		if ( node.occupied == false )
		{
			free_nodes[ free_nodes.size ] = node;
		}
	}
	
	if ( free_nodes.size > 0 )
	{
		//impact_struct = getClosest( CoM, free_nodes );
		
		// randomly return a location within 2000 units
		return free_nodes[ randomint( free_nodes.size ) ];
	}
	else
	{
		return undefined;
	}
}

get_center_of_players()
{
	// closest: to all players
	x = 0; y = 0; z = 0;
	foreach ( player in level.players )
	{
		x += player.origin[ 0 ];
		y += player.origin[ 1 ];
		z += player.origin[ 2 ];
	}
	
	player_count = max( 1, level.players.size );
	CoM = ( x/player_count, y/player_count, z/player_count ); // center of mass origin
	
	return CoM;
}

// spawn_alien_meteoroid( alien_type, count, respawn, spm, lasting_time )
// ===================================================
// alien_type 				= type reference string, ex: "wave cloaker"
// count (optional)			= spawn this many aliens, respawn to maintain count (global) if respawn is on (default=4+)
// respawn (optional)		= if true, count is number of aliens to maintain (default=false)
// spm (optional)			= if respawn is on, spawns per minute, ex: 30 means it will spawn an alien per 2 seconds rate (default=60/minute)
// lasttime_time (optional) = time the meteoroid lasts for respawning (default=20sec)

spawn_alien_meteoroid( alien_type, count, respawn, spm, lasting_time )
{
	// spm = spawns per minute
	
	if ( !isdefined( level.meteoroid_impact_nodes ) || level.meteoroid_impact_nodes.size == 0 )
		return;
	
	if ( !isdefined( respawn ) )
		respawn = false;
	
	if ( !isdefined( count ) )
	{
		count = 4;
		
		// two more for every existing meteoroid
		foreach ( node in level.meteoroid_impact_nodes )
		{
			if ( node.occupied )
			{
				count += 2;	
			}
		}
	}
	
	if ( !isdefined( spm ) )
		spm = 60;
	
	if ( !isdefined( lasting_time ) )
		lasting_time = 20;
	
	impact_node = get_meteoroid_impact_node();
	if ( !isdefined( impact_node ) )
	{
		//IPrintLnBold( "All meteoroid impact locations are occupied or too far" );
		return;	
	}
	
	clip = get_available_meteoroid_clip( impact_node );
	if ( !isdefined( clip ) )
	{
		//IPrintLnBold( "All meteoroid impact locations are occupied or too far" );
		return;	
	}	
	
	impact_node.occupied = true;
	impact_node.meteoroid.ent = Spawn( "script_model", impact_node.meteoroid.origin );
	impact_node.meteoroid.ent setmodel( "moab_cliff_rock_01_thin" );
	
	start_pos 		= impact_node.meteoroid_start_pos;
	start_angles	= impact_node.meteoroid_start_angles;
	final_pos 		= impact_node.meteoroid_final_pos;
	final_angles 	= impact_node.meteoroid_final_angles;
	end_pos 		= impact_node.meteoroid_end_pos;
	end_angles 		= impact_node.meteoroid_end_angles;
	
	travel_time 	= 10;
	accel 			= 8;

	impact_node.meteoroid.ent.origin = start_pos;
	impact_node.meteoroid.ent.angles = start_angles;
	
	impact_node.meteoroid.ent MoveTo( final_pos, travel_time, accel );
	thread playSoundInSpace( "alien_minion_spawn_mtr_incoming", final_pos );
	//impact_node.meteoroid.ent RotateTo( final_angles, travel_time, accel );
	impact_node.meteoroid.ent RotateVelocity( (0,360,0), travel_time, accel );
	
	lightning_strikes = 3;
	for ( i=0; i<lightning_strikes; i++ )
	{
		// lightning strikes!
		PlayFx( level._effect[ "vfx_alien_lightning_bolt" ], final_pos );
		thread playSoundInSpace( "alien_minion_spawn_lightning", final_pos );
		wait travel_time/lightning_strikes;		
	}

	impact_node.meteoroid.ent.origin = final_pos;
	impact_node.meteoroid.ent.angles = final_angles;
	
	// show rocks
	foreach ( rock in impact_node.rocks )
	{
		rock.ent = Spawn( "script_model", rock.origin );
		rock.ent setmodel( "moab_river_rock_cluster_04" );
		rock.ent.angles = rock.angles;
	}
	
	// playfx
	PlayFX( level._effect[ "stronghold_explode_large" ], impact_node.origin );
	Earthquake( 0.75, 1, impact_node.origin, 2000 );
	
	thread playSoundInSpace( "alien_meteor_impact", impact_node.origin );
	PlayRumbleOnPosition( "grenade_rumble", impact_node.origin );
	RadiusDamage( impact_node.origin, 500, 150, 10 );

	// bring on the clippage
	clip.origin = impact_node.origin;
	clip DisconnectPaths();
	
	// lightning strikes!
	PlayFx( level._effect[ "vfx_alien_lightning_bolt" ], final_pos );
	
	// spawn minions!
	spawn_meteoroid_aliens( impact_node.origin + ( 0, 0, -32 ), alien_type, count, respawn, spm, lasting_time );
	
	// reset
	impact_node.meteoroid.ent MoveTo( end_pos, travel_time/2, accel/2 );
	//impact_node.meteoroid.ent RotateTo( end_angles, travel_time/2, accel/2 );
	impact_node.meteoroid.ent RotateVelocity(  (0,90,0), travel_time/2, accel/2 );
	
	PlayFX( level._effect[ "stronghold_explode_large" ], impact_node.origin );
	thread playSoundInSpace( "alien_minion_spawn_mtr_sink", impact_node.origin );
	Earthquake( 0.3, travel_time/2, impact_node.origin, 512 );

	wait travel_time/4;
	// lightning strikes AGAIN!
	PlayFx( level._effect[ "vfx_alien_lightning_bolt" ], final_pos );
	thread playSoundInSpace( "alien_minion_spawn_lightning", final_pos );		
	wait travel_time/4;
	
	impact_node.meteoroid.ent delete();
	foreach ( rock in impact_node.rocks )
	{
		rock.ent delete();
	}
	
	// remove the clippage
	clip.origin = clip.old_origin;
	clip ConnectPaths();

	impact_node.occupied = false;
}

spawn_meteoroid_aliens( pos, alien_type, count, respawn, spm, spawn_time )
{
	wait 1;
	
	spawned = 0;
	end_time = GetTime() + spawn_time * 1000.0;
	spawned_aliens = [];
	
	while ( 1 )
	{
		if ( GetTime() >= end_time )
		{
			level notify( "meteor_aliens_spawned", spawned_aliens, count );
			return;	
		}
		
		if ( spawned >= count && !respawn )
		{
			level notify( "meteor_aliens_spawned", spawned_aliens, count );
			// kill it
			wait 7;
			return;
		}
		
		if ( !can_spawn_meteoroid_alien( alien_type, count ) )
		{
			wait 0.05;
			continue;
		}
		
		CoM 			= get_center_of_players();
		direction_vec 	= VectorNormalize( CoM - pos ); // facing center of players
		direction_vec 	= RotateVector( direction_vec, ( 0, 120 - randomint( 120 ), 0 ) );
		spawner_angles 	= VectorToAngles( direction_vec );
		
		agent = spawnAlien( pos, spawner_angles, "wave " + alien_type );
		agent thread crawl_out( pos, direction_vec );
		spawned_aliens[spawned_aliens.size] = agent;
		
		spawned++;
		
		// offset from other meteoroids if there are more than one
		wait RandomFloatRange( 0.05, 0.25 );
		
		wait ( 60/spm ) - 0.15;
	}
}

can_spawn_meteoroid_alien( alien_type, count )
{
	alive = 0;
	alive_by_type = 0;
	foreach ( agent in level.agentArray )
	{
		if ( isalive( agent ) )
		{
			if ( isdefined( agent.alien_type ) && agent.alien_type == alien_type )
				alive_by_type++;
			
			alive++;
		}
	}
	
	// budget - 1
	if ( alive > 17 )
	{
		return false;
	}
	
	if ( alive_by_type > count )
	{
		return false;
	}
	
	return true;
}

crawl_out( pos, direction_vec )
{
	self endon( "death" );
	
	self enable_alien_scripted();
	
	
	default_rate = self.moveplaybackrate;
	self.moveplaybackrate = 0.5;
	
	self ScrAgentSetGoalRadius( 4000 );
	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	self ScrAgentSetPhysicsMode( "noclip" );
	
	if ( cointoss() )
	{
		// climb out
		height = ( 0, 0, -40 );
		self SetOrigin( pos + height + VectorNormalize( direction_vec ) * 54 );

		self SetAnimState( "traverse_climb_up", 4 );
		anim_length = getAnimLength( self GetAnimEntry( "traverse_climb_up", 4 )); // animation time
		
		wait anim_length/2;
		self ScrAgentSetPhysicsMode( "gravity" );
		wait anim_length/2;
	}
	else
	{
		// climb down
		height = ( 0, 0, 160 );
		self SetOrigin( pos + height + VectorNormalize( direction_vec ) * 8 );
		
		self SetAnimState( "traverse_climb_down", 0 );
		wait getAnimLength( self GetAnimEntry( "traverse_climb_down", 0 )); // animation time

		self SetAnimState( "traverse_climb_down", 3 );
		anim_length = getAnimLength( self GetAnimEntry( "traverse_climb_down", 3 ) ); // animation time	
		
		wait anim_length/2;
		self ScrAgentSetPhysicsMode( "gravity" );
		wait anim_length/2;
	}

	//self maps\mp\agents\_scriptedagents::PlayAnimNUntilNotetrack( "traverse_climb_up", 4, "canned_traverse", "end" );
	
	self.moveplaybackrate = default_rate;
	self clear_ignore_enemy();
	
	//TEMP: force walk
	original_health = self.health;
	original_moverate = self.moveplaybackrate;
	original_animrate = self.animplaybackrate;
	
	while ( self.health > original_health * 0.95 )
	{
		self.movemode = "walk";
		self.moveplaybackrate = 1.75;
		self.animplaybackrate = 1.75;
		wait 0.05;
	}

	self.movemode = "run";
	self.moveplaybackrate = original_moverate;
	self.animplaybackrate = original_animrate;
}


// ========================================================
// 				SPAWN HELPER FUNCTIONS
// ========================================================

// updates which stronghold players are currently using
current_stronghold_update()
{
	while ( 1 )
	{
		level.alien_wave_status[ "stronghold" ] = "A";
		
		// TODO: stronghold update will be based on player trigger proximity of stronghold
		
		// WIP
		wait 5;
	}
}

// ----- reference data -----

// struct []: returns array of cycles
get_cycles( stronghold )
{
	return level.strongholds[ stronghold ].cycles;
}

// bool: returns of cycle is repeated at this stronghold
is_cycle_repeated( stronghold, cycle )
{
	cycles = get_cycles( stronghold );
	return cycles[ cycle ].repeat;
}

// struct []: returns array of waves
get_waves( stronghold, cycle )
{
	cycles = get_cycles( stronghold );
	return cycles[ cycle ].waves;
}

// ----- current data -----

// string: returns current held stronghold
get_current_stronghold()
{
	return level.alien_wave_status[ "stronghold" ];
}

// int: returns current cycle
get_current_cycle()
{
	return level.alien_wave_status[ "cycle" ];
}

// int: returns current wave
get_current_wave()
{
	return level.alien_wave_status[ "wave" ];
}

// string []: returns current wave AI types
get_current_wave_types()
{
	stronghold	= get_current_stronghold();
	cycle 		= get_current_cycle();
	wave		= get_current_wave();
	
	types_array = level.strongholds[ stronghold ].cycles[ cycle ].waves[ wave ].types_array;
	
	return types_array;
}

// int: returns current wave AI type's count
get_current_wave_type_count( type )
{
	stronghold	= get_current_stronghold();
	cycle 		= get_current_cycle();
	wave		= get_current_wave();
	
	type_count	= level.strongholds[ stronghold ].cycles[ cycle ].waves[ wave ].types[ type ].count;
	
	return type_count;
}

use_spawn_director()
{
	if ( isDefined ( level.use_spawn_director ) && level.use_spawn_director == 1)
		return true;
	return false;
}