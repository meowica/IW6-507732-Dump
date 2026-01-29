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
	if( IsDefined( trig._enemy_num ))
	{
		if( IsDefined( enemy_index ))
			trig thread waittill_enemy_num_remaining( enemy_index );
		else
			AssertMsg( "Trigger with index '" + trig._index + "' has a script_namenumber, but no enemy_index was passed!" );
	}
	
	trig waittill( "trigger" );
	
	if( trig._linked_triggers.size > 0 )
		foreach( trigger in trig._linked_triggers )
			trigger notify( "trigger" );
	
	// Wait until allies are at their goals (wait a frame to let them get moving
	trig thread waittill_allies_at_goal( self );
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

waittill_allies_at_goal( allies_array )
{	
	level notify( "notify_kill_allies_at_goal" );
	level endon( "notify_kill_allies_at_goal" );
	
	flag_set( "flag_allies_moving" );
	flag_clear( "flag_allies_player_near" );
	
	trig_index = self._index;
	
	/#	
	debug_ally_advance( "allies_moving" );
	#/
	
	ent = spawnstruct();
	ent.threads = 0;

	allies = [];
	
	if( IsArray( allies_array ))
		allies = allies_array;
	else
		allies[ 0 ] = allies_array;		
	
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
	debug_ally_advance( "allies_at_goal", trig_index );
	#/
	
	flag_clear( "flag_allies_moving" );	
		
	allies waittill_proximity();	
	
	flag_set( "flag_allies_player_near" );	
	
	/#
	debug_ally_advance( "player_near_allies", trig_index );
	#/
}

waittill_proximity()
{	
	// Distance player must be within one ally
	DIST = 250;	
	
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

/#
debug_ally_advance( msg, trig_index )
{	
	if( ALLY_DEBUG )
	{		
		if( IsDefined( msg ))
		{
			index = undefined;
			if( IsDefined( trig_index ))
				index = trig_index;
			else
				index = self._index;
			iprintln( "ally trig " + index + ": " + msg );
		}
		else
		{
			self thread debug_ally_advance_trigger();			
		}
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

#/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// ENEMIES

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

add_to_group( enemy_index )
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
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// MISC

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ignore_everything()
{			
	if( !IsDefined( self ) || !IsAI( self ) )
		return;
	
	// Looks like unignore_everything wasn't called, clear first
	if( IsDefined( self._ignore_settings_old ))
		self unignore_everything();
	
	self._ignore_settings_old = [];
	
	self.disableplayeradsloscheck = set_ignore_setting( self.disableplayeradsloscheck, "disableplayeradsloscheck", true );
	self.ignoreall				  = true; //set_ignore_setting( self.ignoreall, "ignoreall", true );
	self.ignoreme				  = true; //set_ignore_setting( self.ignoreme, "ignoreme", true );
	self.grenadeAwareness		  = set_ignore_setting( self.grenadeAwareness, "grenadeawareness", 0 );
	self.ignoreexplosionevents	  = set_ignore_setting( self.ignoreexplosionevents, "ignoreexplosionevents", true );
	self.ignorerandombulletdamage = set_ignore_setting( self.ignorerandombulletdamage, "ignorerandombulletdamage", true );
	self.ignoresuppression		  = set_ignore_setting( self.ignoresuppression, "ignoresuppression", true );
	self.dontavoidplayer		  = set_ignore_setting( self.dontavoidplayer, "dontavoidplayer", true );
	self.newEnemyReactionDistSq	  = set_ignore_setting( self.newEnemyReactionDistSq, "newEnemyReactionDistSq", 0 );
	
	self.disableBulletWhizbyReaction = set_ignore_setting( self.disableBulletWhizbyReaction, "disableBulletWhizbyReaction", true );
	self.disableFriendlyFireReaction = set_ignore_setting( self.disableFriendlyFireReaction, "disableFriendlyFireReaction", true );
	self.dontMelee					 = set_ignore_setting( self.dontMelee, "dontMelee", true );
	self.flashBangImmunity			 = set_ignore_setting( self.flashBangImmunity, "flashBangImmunity", true );
	
	self.doDangerReact			 = set_ignore_setting( self.doDangerReact, "doDangerReact", false );	
	self.neverSprintForVariation = set_ignore_setting( self.neverSprintForVariation, "neverSprintForVariation", true );
	
	self.a.disablePain = set_ignore_setting( self.a.disablePain, "a.disablePain", true );
	self.allowPain	   = set_ignore_setting( self.allowPain, "allowPain", false );
	
	self PushPlayer( true );
}

set_ignore_setting( old_value, string, new_value )
{
	Assert( self != level );	
	Assert( IsDefined( string ));	
	
	if( IsDefined( old_value ))
		self._ignore_settings_old[ string ] = old_value;	
	else
		self._ignore_settings_old[ string ] = "none";
	
	return new_value;
}

unignore_everything( dont_restore_old )
{
	if( !IsDefined( self ) || !IsAI( self ) )
		return;
	
	// Don't restore old settings
	if( IsDefined( dont_restore_old ) && dont_restore_old )
		if( IsDefined( self._ignore_settings_old ))
			self._ignore_settings_old = undefined;
			
	self.disableplayeradsloscheck = restore_ignore_setting( "disableplayeradsloscheck", false );
	self.ignoreall				  = false; //restore_ignore_setting( "ignoreall", false );
	self.ignoreme				  = false; //restore_ignore_setting( "ignoreme", false );
	self.grenadeAwareness		  = restore_ignore_setting( "grenadeawareness", 1 );
	self.ignoreexplosionevents	  = restore_ignore_setting( "ignoreexplosionevents", false );
	self.ignorerandombulletdamage = restore_ignore_setting( "ignorerandombulletdamage", false );
	self.ignoresuppression		  = restore_ignore_setting( "ignoresuppression", false );
	self.dontavoidplayer		  = restore_ignore_setting( "dontavoidplayer", false );
	self.newEnemyReactionDistSq	  = restore_ignore_setting( "newEnemyReactionDistSq", 262144 );
	
	self.disableBulletWhizbyReaction = restore_ignore_setting( "disableBulletWhizbyReaction", undefined );
	self.disableFriendlyFireReaction = restore_ignore_setting( "disableFriendlyFireReaction", undefined );
	self.dontMelee					 = restore_ignore_setting( "dontMelee", undefined );
	self.flashBangImmunity			 = restore_ignore_setting( "flashBangImmunity", undefined );
	
	self.doDangerReact			 = restore_ignore_setting( "doDangerReact", true );
	self.neverSprintForVariation = restore_ignore_setting( "neverSprintForVariation", undefined );
	
	self.a.disablePain = restore_ignore_setting( "a.disablePain", false );
	self.allowPain	   = restore_ignore_setting( "allowPain", true );
	
	self PushPlayer( false );		
		
	self._ignore_settings_old = undefined;
}

restore_ignore_setting( string, default_val )
{
	Assert( self != level );	
	Assert( IsDefined( string ));		
	                                                
	if( IsDefined( self._ignore_settings_old )) 
	{
		// Check to see if original value exists
		if( IsString( self._ignore_settings_old[ string ] ) && ( self._ignore_settings_old[ string ] == "none" ))
			return default_val;
		else
			return self._ignore_settings_old[ string ];
	}
	
	return default_val;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ignore_until_goal()
{
	self endon( "death" );
	
	self ignore_everything();
	
	self waittill( "goal" );
	
	self unignore_everything();
}