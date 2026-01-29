#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

ALLY_DEBUG = 0;
ENEMY_DEBUG = 0;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// ALLIES

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//	Setup - Create a chain of trigger_multiple_friendly triggers.  Set script_color_allies on the triggers for each advance.  Below are additional options:
//
//	Auto-Triggering - The below options can be added to ally triggers to affect auto-triggering:
// 		trigger.script_parameters - Time to wait.  Set to 0 for instant.  Do not set for infinite.
// 		trigger.script_namenumber - Negative integer - Number of enemies to kill.  Positive integer - Number of enemies remaining in group. 
//
//	Chain-Triggering - If you want to set off another trigger when the ally trigger is triggered, just have the ally trigger target the trigger(s) in addition
//		to the next ally trigger.
//

ally_advance_watcher( trig_noteworthy, enemy_index, bool_no_delete )
{
	allies = [];	
	if( IsArray( self ))
	{
		allies = self;
	}
	else
	{
		Assert( self != level );
		allies[ 0 ] = self;
	}
	
	Assert( IsDefined( trig_noteworthy ));	
	
	level notify( trig_noteworthy + "kill" );
	level endon( trig_noteworthy + "kill" );
	
	// Keep track of if allies are moving to spots
	if( !flag_exist( "flag_allies_moving" ))
		flag_init( "flag_allies_moving" );	
	
	// Keep track of if player is near an ally
	if( !flag_exist( "flag_allies_player_near" ))
		flag_init( "flag_allies_player_near" );
	
	// Get first trigger, make sure it is trigger_multiple_friendly
	trig = GetEnt( trig_noteworthy, "script_noteworthy" );
	if( !IsDefined( trig ))
		trig = GetEnt( trig_noteworthy, "targetname" );
	Assert( IsDefined( trig ));
	AssertEX( ( trig.classname == "trigger_multiple_friendly" ), "Ally advance: First trigger '" + trig_noteworthy + "' is not trigger_multiple_friendly!" );
	
	// This will prevent triggers from being deleted after they are triggered
	delete_trigger = true;
	if( IsDefined( bool_no_delete ) && bool_no_delete )
		delete_trigger = false;		
		
	//		
	// Get all the triggers based on targets
	//
	
	triggers = [];
	while( 1 )
	{				
		// Grab trigger delay (how long until auto-triggered )
		if( IsDefined( trig.script_parameters ))
			trig._delay = float( trig.script_parameters );
		else
			trig._delay = 0;
		
		// Grab enemy number to move on (positive is enemies left, negative is enemies killed)
		if( IsDefined( trig.script_namenumber ))
			trig._enemy_num = int( trig.script_namenumber );		
		
		// Container to hold any linked triggers
		trig._linked_triggers = [];
		
		// Add trigger to array
		triggers = array_add( triggers, trig );		
		
		if( IsDefined( trig.target ))
		{
			// Grab next, or exit						
			trigs = GetEntArray( trig.target, "targetname" );			
			
			next_friendly_trigger = undefined;
							
			foreach( ent in trigs )
			{
				// Uh oh, we were expecting only one friendly trigger!
				if( ( ent.classname == "trigger_multiple_friendly" ) && IsDefined( next_friendly_trigger ))
				{
					AssertMsg( "Multiple trigger_multiple_friendlies linked to '" + trig.targetname + "'" );
				}
				else
				{
					// Find linked triggers
					if( ent.classname == "trigger_multiple_friendly" )
						next_friendly_trigger = ent;
					else if ( IsSubStr( ent.classname, "trigger" ))
						trig._linked_triggers = array_add( trig._linked_triggers, ent );
					else
						AssertMsg( "Unknown ent linked to '" + trig.targetname + "': " + ent.classname );
				}						
			}			
			
			if( !IsDefined( next_friendly_trigger ))
				break;
			
			trig = next_friendly_trigger;
		}
		else
		{
			// No more triggers
			break;
		}
	}
	
	//
	// Add main trigger to array
	//
	
	if( !IsDefined(	level._ally_trigs ))
		level._ally_trigs = [];
	
	// Add to global array
	level._ally_trigs[ trig_noteworthy ] = triggers;
	
	//
	// Start parsing triggers
	//
	
	// Set allies near flag for first trigger
	flag_set( "flag_allies_player_near" );
	
	// Add main trigger to global array
	for( i = 0; i < triggers.size; i++ )
	{
		trig = triggers[ i ];
		
		// Run the main advance script
		trig._index = i;
		allies ally_advance( trig, enemy_index );
		
		if( delete_trigger )
		{
			// Delete linked triggers
			if( IsDefined( trig._linked_triggers ))
				foreach( linked_trigger in trig._linked_triggers )
					if( IsDefined( linked_trigger ) && !IsSubStr( linked_trigger.classname, "friendly" ))
						linked_trigger delete();
			
			// Delete main trigger
			trig delete();
		}
	}	
}

ally_advance( trig, enemy_index )
{							
	trig thread waittill_trig_or_time_out();	
		
	// If enemy index exists and the designated number is not zero
	if( IsDefined( enemy_index ) && IsDefined( trig._enemy_num ))
		trig thread waittill_enemy_num_remaining( enemy_index );
	
	trig waittill( "trigger" );
	
	if( trig._linked_triggers.size > 0 )
		foreach( trigger in trig._linked_triggers )
			trigger notify( "trigger" );
	
	// Wait until allies are at their goals (wait a frame to let them get moving
	self thread waittill_at_goal();		
	wait( 0.05 );
}

waittill_trig_or_time_out()
{
	/#
	self debug_ally_advance();
	#/
	
	// Exits after trigger OR timeout
	self waittill_time_out();	

	// Wait for player to be near allies
	flag_wait( "flag_allies_player_near" );	
	
	self notify( "trigger" );
}

waittill_time_out()
{
	self endon( "trigger" );
	
	// Wait for player to be near allies	
	flag_wait( "flag_allies_player_near" );
	
	/#
	self debug_ally_advance( "timeout_start: " + self._delay );		
	#/
	
	// If timer is not defined OR timer is equal to 0, wait for trigger
	if( self._delay == 0 )
		self waittill( "trigger" );	
	else
		wait( self._delay );
	
	/#
	self debug_ally_advance( "timeout_end: " + self._delay );
	#/
}

waittill_enemy_num_remaining( enemy_index )
{
	self endon( "trigger" );
		
	// Wait for player to be near allies
	flag_wait( "flag_allies_player_near" );

	enemies = [];
	
	if( IsString( enemy_index ))
	{
		// If string, assume we are using level._enemies[].  	
		if( IsDefined( level._enemies[ enemy_index ] ))
			enemies = level._enemies[ enemy_index ];
	}
	else
	{
		// An array of enemies passed
		Assert( IsArray( enemy_index ));		
		enemies = enemy_index;				
	}
		
	// Grab the number.  Negative means num to kill, positive means num remaining	
	num = abs( self._enemy_num );	
	
	// Get the number of player kills
	initial_kills = undefined;
	num_killed = 0;		
	if( num != self._enemy_num )
		initial_kills = level.player.stats[ "kills" ];
	
	while( 1 )
	{		
		if( IsDefined( initial_kills ))
		{
			// Check the number of kills
			if( ( level.player.stats[ "kills" ] - initial_kills ) >= num )
				break;			
		}
		else
		{
			// Check the number left
			enemies = remove_dead_from_array( enemies );
			if( enemies.size <= num )
				break;
		}
		
		wait( 0.05 );
	}
	
	/#
	self debug_ally_advance( "enemy_number_reached" );
	#/
	
	self notify( "trigger" );
}

waittill_at_goal()
{	
	level notify( "notify_kill_allies_at_goal" );
	level endon( "notify_kill_allies_at_goal" );
	
	flag_set( "flag_allies_moving" );
	flag_clear( "flag_allies_player_near" );
	
	/#
	self debug_ally_advance( "allies_moving" );
	#/
	
	ent = spawnstruct();
	ent.threads = 0;

	allies = [];
	
	if( IsArray( self ))
		allies = self;
	else
		allies[ 0 ] = self;		
	
	// Wait until goals
	foreach( ally in allies )	
	{	
		ally._old_goalradius = ally.goalradius;		
		ally.goalradius = 16;
		ally thread waittill_string( "goal", ent );
		ent.threads++;
	}	

	while ( ent.threads )
	{
		ent waittill( "returned" );
		ent.threads--;
	}

	// Goals reached
	ent notify( "die" );
			
	foreach( ally in allies )
		ally.goalradius = ally._old_goalradius;
	
	/#
	self debug_ally_advance( "allies_at_goal" );
	#/
	
	flag_clear( "flag_allies_moving" );	
		
	allies waittill_proximity();	
	
	flag_set( "flag_allies_player_near" );	
	
	/#
	self debug_ally_advance( "player_near_allies" );
	#/
}

waittill_proximity()
{	
	// Distance player must be within one ally
	DIST = 300;	
	
	dist_sq = dist * DIST;	
	
	while( 1 )
	{
		foreach( ally in self )
		{
			// Break when player is within a certain distance of one of the allies
			ally_to_player = DistanceSquared( ally.origin, level.player.origin );			
			if( ally_to_player <= dist_sq )
				return;
		}
		
		wait( 0.5 );		
	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// ENEMIES

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

add_to_group( enemy_index, initial_goal_volume )
{	
	Assert( IsDefined( enemy_index ));
	Assert( IsAI( self ));
	
	// Setup enemy array
	if( !IsDefined( level._enemies ))
		level._enemies = [];
	
	if( !IsDefined( level._enemies[ enemy_index ] ))
	   level._enemies[ enemy_index ] = [];
	   
	level._enemies[ enemy_index ] = array_add( level._enemies[ enemy_index ], self );
	
	self._current_index = enemy_index;
	
	if( !IsDefined( self._current_goal_volume ))
	{
		// No goal volume specified. Assume this is a fresh spawn 
		
		// Kill go_to_node() from _spawner()
		self notify( "stop_going_to_node" );
		
		if( IsDefined( initial_goal_volume ) && !IsString( initial_goal_volume ) && !initial_goal_volume )
		{
			// Setting initial_goal_volume to false will bypass any go_to_goal_vol()		
			return;
		}
		else
		{
			if( IsString( initial_goal_volume ))
			{
				// A specific goal volume is given
				self thread go_to_goal_vol( initial_goal_volume );
			}
			else
			{
				// No goal volume passed
				current_goal_vol = self GetGoalVolume();
			
				if( IsDefined( current_goal_vol ))
				{
					// Spawner is targeting volume, assign it as their vol
					self thread go_to_goal_vol( current_goal_vol );
				}
				else
				{
					// If this guy doesn't have a target (assuming a node), and there is a current volume index for his group, send him there
					if( 
					   !IsDefined( self.target ) &&
					   IsDefined( level._retreat_current_volumes ) &&
					   IsDefined( level._retreat_current_volumes[ enemy_index ] ) &&
					   ( level._retreat_current_volumes[ enemy_index ].size > 0 )
					)
						self thread go_to_goal_vol();
				}
			}
		}
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

check_enemy_index( enemy_index )
{
	Assert( IsString( enemy_index ));
	AssertEX( Isdefined( level._enemies[ enemy_index ] ), enemy_index + " does not exist in level._enemies" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

retreat_watcher( tTrigger, enemy_index, first_vol_index, delay )
{
	Assert( IsDefined( tTrigger ));
	Assert( IsDefined( enemy_index ));
	check_vol_index( first_vol_index );
	
	level notify( tTrigger + "kill" );
	level endon( tTrigger + "kill" );
	
	// Make sure retreat volumes list exists
	if( !IsDefined( level._retreat_volumes_list ))
		level._retreat_volumes_list = [];	
	if( !IsDefined( level._retreat_volumes_list[ enemy_index ] ))
	{
		// If a list is not defined, we'll use the first vol and find all targetted volumes
		level._retreat_volumes_list[ enemy_index ] = [];
		level._retreat_volumes_list[ enemy_index ] = build_vol_list( first_vol_index );
	}
		
	// Make sure current retreat volume is specified
	if( !IsDefined( level._retreat_current_volumes ))
		level._retreat_current_volumes = [];	
	if( !IsDefined( level._retreat_current_volumes[ enemy_index ] ))
		level._retreat_current_volumes[ enemy_index ] = first_vol_index;		
	
	//NOTE: If this is the first retreat for this enemy and no vols_index is specified, choose_vol() will check each enemy's 
	//		self._current_goal_volume._target_vols for the next vol.  Assuming all enemies are currently assigned volumes
	//		they will go to their next volume.  Otherwise they will go to the level._retreat_final (if specified) or
	//		ultimately seek the player.	
	
	triggers = GetEntArray( tTrigger, "script_noteworthy" );
	Assert( triggers.size > 0 );
	
	level._retreat_trigs[ tTrigger ] = triggers;
	
	array_thread( triggers, ::trigger_wait_retreat, enemy_index, delay );
}

trigger_wait_retreat( enemy_index, delay )
{
	level endon( "notify_stop_retreat_all" );
	
	self waittill( "trigger" );
	
	/#
	if( ENEMY_DEBUG )
		iprintln( "Retreat: " + enemy_index );
	#/
	
	enemy_index_array = [];
	
	// Check to see if single index or array of indexes
	if( IsArray( enemy_index ))
		enemy_index_array = enemy_index;
	else if( IsString( enemy_index ))
		enemy_index_array[ 0 ] = enemy_index;
	else 
		AssertMsg( "Retreat error: Unknown index '" + enemy_index + "'" );
	
	// Start retreat
	foreach( index in enemy_index_array )
		enemy_retreat( enemy_index, undefined, delay );
	
	// Kill trigger
	self delete();	
}

enemy_retreat( enemy_index, vols_index, max_delay )
{		
	check_enemy_index( enemy_index );
	
	level notify( "notify_kill_retreat" + enemy_index );	
	level endon( "notify_kill_retreat" + enemy_index );
	
	guys = remove_dead_from_array( level._enemies[ enemy_index ] );	
	guys = SortByDistance( guys, level.player.origin );
	
	delay = 0.05;
	
	if( IsDefined( max_delay ) && ( max_delay > delay ))
		delay = max_delay;
	
	if( level._retreat_volumes_list[ enemy_index ].size > 0 )
	{
		// Pop the retreats list down one, and set the current goal volume
		level._retreat_current_volumes[ enemy_index ] = level._retreat_volumes_list[ enemy_index ][ 0 ];
		level._retreat_volumes_list[ enemy_index ] = array_remove_index( level._retreat_volumes_list[ enemy_index ], 0 );
	}
	
	for( i = ( guys.size - 1 ); i >= 0; i-- )
	{
		// Send guy to next goal vol
		guys[ i ] thread go_to_goal_vol( vols_index, delay );
		
		// Reduce the delay for the next guy (closest guy has shortest wait)
		delay = int( delay - (delay / guys.size));
	}
}

go_to_goal_vol( vols_index, max_delay )
{	
	self notify( "stop_go_to_goal_vol" );
	self endon( "death" );
	self endon( "stop_go_to_goal_vol" );	
		
	/#
	if( ENEMY_DEBUG )
	{
		// Debug
		self notify( "stop_print3d" );
		self thread debug_current_volume();
		self thread debug_show_vol_nodes();
	}
	#/
	
	// Choose a volume		
	vol = self choose_goal_vol( vols_index );
	
	// Volume is not defined, we're not moving
	if( !IsDefined( vol ))
		return false;
	
	if( IsString( vol ) && ( vol == "seek" ))
	{
		//
		// Seek the player
		//	
		/#
		if( ENEMY_DEBUG )
			iprintln( "Guy " + self.export + ": Retreat is out of options!  Seeking player." );
		#/
		
		// Kill retreat system for this guy
		self notify( "notify_stop_retreat" );
		
		// Clear current vol
		self._current_goal_volume = undefined;
		self ClearGoalVolume();
		
		if( IsDefined( self._current_index ))
		{
			// Already seeking
			if( self._current_index == "seek" )
				return false;
			
			// If in a group, remove from group and add to "seek"
			level._enemies[ self._current_index ] =  array_remove( level._enemies[ self._current_index ], self );
			self add_to_group( "seek", false );
			self._current_index = "seek";
		}
		
		self thread player_seek_enable();
	}
	else
	{
		// Send the enemy to the volume
		self._current_goal_volume = vol;
		
		// Delay
		delay = 0.05;		
		if( IsDefined( max_delay ))
		{
			if( max_delay >= delay )
				wait( RandomFloatrange( 0, max_delay ));
		}
		else
		{
			wait( RandomFloatrange( 0, delay ));
		}
				
		// This is not the current global volume, thread a watcher to send this guy to current if a spot opens up
		if( 
		   	IsDefined( self._current_index ) &&
		   	IsDefined( level._retreat_current_volumes ) && 
			IsDefined( level._retreat_current_volumes[ self._current_index ] ) && 
			!current_vol_acceptable()
		)
			self add_to_standby();
		else
			self._retreat_standby = undefined;
		
		// Disable fixed node if on	
		self set_fixednode_false();		
		self SetGoalVolumeAuto( vol );
	}
	
	return true;
}

choose_goal_vol( vols_index )
{		
	vol = undefined;
	
	AssertEX( IsDefined( level._vols ), "setup_retreat_vols() needs to be run before choose_goal_vol can be set" );
	
	if( IsDefined( vols_index ))
	{
		//
		// VOLUME INDEX PASSED: Choose a volume using vols_index
		//
		
		vol = choose_goal_vol_chain( vols_index );
	}
	else
	{							
		if( IsDefined( level._retreat_final ))
		{						
			//
			// FINAL RETREAT ACTIVE: Final retreat volume active
			//
			vol = choose_goal_vol_chain( level._retreat_final );
		}
		else if( IsDefined( self._current_goal_volume ))
		{
			//
			// HAS CURRENT VOLUME: Enemy has a current volume
			//
			
			// Exit if current volume is acceptable for enemy's group
			if( self current_vol_acceptable())
				return;
			
			if( IsDefined( self._current_goal_volume._target_vols ) && ( self._current_goal_volume._target_vols.size > 0 ))
			{
				// Send to next vols targetted
				vols = SortByDistance( self._current_goal_volume._target_vols, self.origin );
				
				foreach( volume in vols )
				{
					vol = choose_goal_vol_chain( volume );
					
					if( IsDefined( vol ))
						break;
				}
			}
		}		
		else if( !IsDefined( self._current_index ))
		{
			//
			// TOUCHING A VOLUME: Guy has no group index, See if guy is in any retreat volume
			//
			foreach( group in level._vols)
			{
				foreach( volume_index in group )
				{
					// Touching a volume
					if( self IsTouching( volume_index ))
						vol = choose_goal_vol_chain( volume_index );
				}
			}
		}		
	}	
	
	//
	// GLOBAL CURRENT VOLUME:  If still no volume found, try using global current volume to check all parallel volumes
	//	
	if( !IsDefined( vol ))
	{
		if(
			IsDefined( self._current_index ) && 
			IsDefined( level._retreat_current_volumes ) &&
			IsDefined( level._retreat_current_volumes[ self._current_index ] )			
		)
		{
			// Use current volume setting for enemy index
			vol = choose_goal_vol_chain( level._retreat_current_volumes[ self._current_index ] );
		}
	}
	
	//
	//  VOLUME FOUND: If volume is found, return it
	//	
	if( IsDefined( vol ))
	{				
		if( IsDefined( level._retreat_final ))
		{
			// Final retreat active.  Enemy ignores everything and heads to goal.  When out of sight, they are deleted.
			self thread ignore_to_goal();
			guys = [self];
			thread AI_delete_when_out_of_sight( guys, 256 );							
			level notify( "notify_stop_retreat_all" );
		}
		
		// Acceptable vol found, return it
		self update_vol_node_count( vol );
		return vol;
	}	

	// No volume found, but enemy is in standby.  Exit out to prevent him seeking player
	if( IsDefined( self._retreat_standby ) && self._retreat_standby )
	{
		self add_to_standby();
		return;
	}
	
	// No volume found, tell system to seek player
	return "seek";
}

current_vol_acceptable()
{
	//
	// If enemy is part of a group, check the group's volumes to see if the enemy needs to retreat
	//
	if( IsDefined( self._current_index ))
	{
		// Check current vol against current global vol
		if( 
			IsDefined( level._retreat_current_volumes ) &&
			IsDefined( level._retreat_current_volumes[ self._current_index ] ) &&
			( level._retreat_current_volumes[ self._current_index ].size > 0 )
		)
		{
			if( self._current_goal_volume.script_noteworthy == level._retreat_current_volumes[ self._current_index ] )
				return true;		
		}
		
		// Check current vol against retreat list
		if( IsDefined( level._retreat_volumes_list[ self._current_index ] ))
		{
			foreach( volume_index in level._retreat_volumes_list[ self._current_index ] )
			{
				if( self._current_goal_volume.script_noteworthy == volume_index )
					return true;
			}
		}
	}
	
	return false;
}

choose_goal_vol_chain( vols_index )
{
	Assert( IsDefined( vols_index ));	
	
	vols = [];
	
	if( !IsString( vols_index ))
	{		
		//
		// ACTUAL VOLUME: vols_index is an actual volume, check the num of ai and return if viable
		//
		vol = vols_index;
		
		if( IsDefined( vol._num_ai ) && IsDefined( vol._max_ai ))
			if( vol._num_ai < vol._max_ai )
				return vol;

		vols[ 0 ] = vol;
	}
	else
	{
		//
		// VOLUME INDEX: This is a volume index (string), run normal check
		//
		check_vol_index( vols_index );
		vols = level._vols[ vols_index ];		
		
		// Look at volumes starting with closest to enemy
		vols = SortByDistance( vols, self.origin );	
			
		foreach( volume in vols )
		{
			// Choose the closest volume that doesn't already have too many guys
			if( volume._num_ai < volume._max_ai )
				return volume;			
		}
	}	
	
	//
	// Look for linked volumes
	//
	foreach( volume in vols )
	{
		if( IsDefined( volume._target_vols ) && ( volume._target_vols.size > 0 ))
		{
			vols = SortByDistance( volume._target_vols, self.origin ); 
			foreach( target_vol in vols )
			{
				vol = choose_goal_vol_chain( target_vol );
				
				if( IsDefined( vol ))
					return vol;
			}
		}
	}
}

update_vol_node_count( vol )
{	
	if( IsDefined( self._current_goal_volume ))
		self._current_goal_volume._num_ai--;
	
	self._current_goal_volume = vol;	
	vol._num_ai++;
	
	self thread deathfunc_vol_num_decrement( vol );
}

deathfunc_vol_num_decrement( vol )
{
	self notify( "notify_new_vol" );
	self endon( "notify_new_vol" );
	
	self waittill_either( "death", "notify_stop_retreat" );
	vol._num_ai--;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

add_to_standby()
{
	self._retreat_standby = true;
	
	// Build standby list for enemies to move up if spots become available
	if( !IsDefined( level._retreat_standby ))
		level._retreat_standby = [];
	if( !IsDefined( level._retreat_standby[ self._current_index ] ))
		level._retreat_standby[ self._current_index ] = [];
	
	level._retreat_standby[ self._current_index ] = array_add( level._retreat_standby[ self._current_index ], self );
	thread standby_watcher( self._current_index );
}

standby_watcher( enemy_index )
{
	level notify( "notify_stop_standby_watcher_" + enemy_index );
	level endon( "notify_stop_standby_watcher_" + enemy_index );
	level endon( "notify_stop_retreat_all" );	
	
	while( 1 )
	{
		wait( 3 );
		
		// Get the living guys and clear the list
		retreat_list = remove_dead_from_array( level._retreat_standby[ enemy_index ] );		
		level._retreat_standby[ enemy_index ] = [];
		
		if( retreat_list.size == 0 )
			break;
		
		if( IsDefined( level._retreat_current_volumes[ enemy_index ] ))
		{
			/#
				if( ENEMY_DEBUG )
					iprintln( "Sending " + level._retreat_standby[ enemy_index ].size + " guys from '" + enemy_index + "' forward" );
			#/
			
			// Attempt to send guys forward
			foreach( guy in retreat_list )
				guy thread go_to_goal_vol( level._retreat_current_volumes[ enemy_index ] );
		}
		else
		{
			break;
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_retreat_vols()
{
	nodes = GetAllNodes();
	vols_raw = GetEntArray( "info_volume", "classname" );
	
	vols = [];
	
	node_test = spawn_tag_origin();
	
	// Find nodes in volumes
	foreach( vol in vols_raw )
	{
		if( IsDefined( vol.script_noteworthy ))
		{						
			if( IsDefined( vol.script_parameters ))
			{
				// Use script_parameters number as max capacity for ai
				vol._max_ai = int( vol.script_parameters );
			}
			else
			{
				if( !IsDefined( vol.nodes ))
					vol.nodes = [];
				
				// No allowed ai number defined, find nodes to calculate number			
				foreach( node in nodes )
				{
					// Create a temp ent to run IsTouching() and check node location against volume				
					node_test.origin = node.origin;
					
					if( node_test IsTouching( vol ))
					{	
						// Grabbing only cover, exposed, and concealment nodes					
						if( IsSubStr( node.type, "Cover" ) || IsSubStr( node.type, "Conceal" ) || IsSubStr( node.type, "Exposed" ))
						{
							// If labelled "no axis", skip the node
							if( IsDefined( node.script_parameters ) && node.script_parameters == "no_axis" )
								continue;												
							
							vol.nodes = array_add( vol.nodes, node );
						}
					}				
				}
				
				if( !IsDefined( vol.nodes ))
					iprintln( "Warning - Volume '" + vol.script_noteworthy + "' has no cover nodes!" );
				
				// Set max ai capacity var
				vol._max_ai = vol.nodes.size;
			}
			
			if( !IsDefined( vols[ vol.script_noteworthy ] ))
		   		vols[ vol.script_noteworthy ] = [];
			
			vol._target_vols = [];
			
			if( IsDefined( vol.target ))
			{
				// Find any targeted (linked) vols
				target_vols = GetEntArray( vol.target, "targetname" );				
				foreach( target_vol in target_vols )
				{
					// Make sure the volume has a script_noteworthy, just for consistency
					AssertEx( IsDefined( target_vol.script_noteworthy ), "Linked info_volume '" + target_vol.targetname + "' in retreat system does not have a script_noteworthy!" );
					vol._target_vols = array_add( vol._target_vols, target_vol );											
				}
			}
			
			// Add vol to list
			vols[ vol.script_noteworthy ] = array_add( vols[ vol.script_noteworthy ], vol );				
			
			// Set initial ai count to 0
			vol._num_ai = 0;
		}
	}
	
	node_test delete();
	
	level._vols = vols;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

check_vol_index( vol_index )
{
	Assert( IsString( vol_index ));
	AssertEX( IsDefined( level._vols[ vol_index ] ), vol_index + " does not exist in level._vols" );
}

build_vol_list( vol_index )
{		
	check_vol_index( vol_index );
	array = [];
	
	while( 1 )
	{	
		new_vol_index = undefined;
		
		foreach( vol in	level._vols[ vol_index ] )
		{
			// Get target volume
			if( IsDefined( vol._target_vols ) && ( vol._target_vols.size > 0 ))
				new_vol_index = vol._target_vols[ 0 ].script_noteworthy;
		}
		
		if( IsDefined( new_vol_index ))
			array = array_add( array, new_vol_index );			
		else
			break;
		
		vol_index = new_vol_index;
		new_vol_index = undefined;
	}
	
	return array;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ignore_to_goal()
{
	self endon( "death" );
	
	self.old_goalradius = self.goalradius;
	self.goalradius = 16;
	self.ignoreall = true;
	
	self waittill( "goal" );
	
	self.ignoreall = false;
	self.goalradius = self.old_goalradius;	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/#
debug_ally_advance( msg )
{	
	if( ALLY_DEBUG )
	{
		Assert( self != level );
		
		if( IsDefined( msg ))
			iprintln( "ally trig " + self._index + ": " + msg );
		else
			self thread debug_ally_advance_trigger();			
	}
}

debug_ally_advance_trigger()
{
	self waittill( "trigger" );
	
	name = "";
	
	if( IsDefined( self.script_noteworthy ))
		name = self.script_noteworthy + " - ";
	else if( IsDefined( self.targetname ))
		name = self.targetname + " - ";
	
	iprintln( "ally trig " + self._index + ": " + name + " triggered" );
}

debug_current_volume()
{		
	self endon( "stop_print3d" );	
	self endon( "death" );
	
	while( 1 )
	{		
		vol = "undefined";
		index = "undefined";
		if( IsDefined( self._current_goal_volume ) && IsDefined( self._current_goal_volume.script_noteworthy ))
			vol = self._current_goal_volume.script_noteworthy;
		if( IsDefined( self._current_index ))
			index = self._current_index;
		print3d( self.origin + (0,0,64), index + " - " + vol, (1,1,1), 1, 0.5, 1 );
		wait( 0.05 );
	}
}

debug_show_vol_nodes()
{
	self endon( "stop_print3d" );
	self endon( "notify_stop_retreat" );
	level endon( "notify_stop_retreat_all" );
	self endon( "death" );
	
	while( 1 )
	{		
		if( IsDefined( self._current_goal_volume ))
		{
			print3d( self._current_goal_volume.origin + (0,0,128), "(" + self._current_goal_volume._num_ai + "/" + self._current_goal_volume._max_ai + ")", (1,0,0), 1, 1, 1 );
		
			if( IsDefined( self._current_goal_volume.nodes ))
			{
				foreach( node in self._current_goal_volume.nodes )
				{
					mark = "o";
					
					if( IsDefined( node.owner ))
						mark = "x";
					
					print3d( node.origin, mark + "(" + self._current_goal_volume._num_ai + "/" + self._current_goal_volume.nodes.size + ")", (1,0,0), 1, 1, 1 );
				}
			}
		}
		wait( 0.05 );
	}
}
#/