#include common_scripts\utility;
#include maps\_utility;
#include maps\_vehicle;
#include maps\_chopperboss_utility;

init()
{
	create_lock( "chopperboss_trace", 4 );
	build_chopperboss_defaults();
}

// Brute force gather up all of the Chopper Boss structs 
// and populate them with an array of references to each path 
// struct they link to and that links to them. This must
// be called to allow the chopper boss to fly around.
chopper_boss_locs_populate( key, val )
{
	thread chopper_boss_locs_populate_thread( key, val );
}

chopper_boss_locs_populate_thread( key, val )
{
	level.chopper_boss_locs = getstructarray( val, key );
	
	AssertEx( level.chopper_boss_locs.size, "Level does not contain any chopper boss structs with key/value " + key + ", " + val );
	
	
	inc = 0;
	foreach ( loc in level.chopper_boss_locs )
	{
		// Grab array of path loc refs that this loc links to
		loc.neighbors = loc get_linked_structs();
		
		// Step through each loc in the map and if it
		// links to this loc, add it
		foreach ( other_loc in level.chopper_boss_locs )
		{
			if ( loc == other_loc )
				continue;
			
			if ( !array_contains( loc.neighbors, other_loc ) && array_contains( other_loc get_linked_structs(), loc ) )
				loc.neighbors[ loc.neighbors.size ] = other_loc;
			inc++;
			inc %= 100;
			if( inc == 0)
				wait 0.05;
		}
		
		// remove nodes with "ignoreme" flag; they are start nodes
		foreach ( neighbor in loc.neighbors )
		{
			if ( IsDefined( neighbor.script_ignoreme ) && neighbor.script_ignoreme )
				loc.neighbors = array_remove( loc.neighbors, neighbor );
		}
		
	}	
	
	level.chopper_boss_locs_populated = true;
}


// This function isn't totally tied to the chopper boss and is used by other
// chopper logic in survival. For now it will stay here so that it's independent
// of survival logic. - JC
chopper_path_release( waittills, endons )
{
	AssertEx( IsDefined( self ), "Chopper not defined." );
	AssertEx( IsDefined( self.loc_current ), "Chopper ref to current location not defined." );
	AssertEx( IsDefined( self.loc_current.in_use ), "Current location not marked as in_use." );
	
	if ( IsDefined( endons ) )
	{
		endon_array = StrTok( endons, " " );
		foreach ( end in endon_array )
			self endon( end );
	}
	
	AssertEx( IsDefined( waittills ) && waittills.size, "Waittills not defined or array of size zero." );
	
	waittills_array = StrTok( waittills, " " );
	switch ( waittills_array.size )
	{
		case 1:
			self waittill( waittills_array[ 0 ] );
			break;
		case 2:
			self waittill_either( waittills_array[ 0 ], waittills_array[ 1 ] );
			break;
		case 3:
			self waittill_any( waittills_array[ 0 ], waittills_array[ 1 ], waittills_array[ 2 ] );
			break;
		case 4:
			self waittill_any( waittills_array[ 0 ], waittills_array[ 1 ], waittills_array[ 2 ], waittills_array[ 3 ] );
			break;
		default:
			AssertMsg( "Called with too many waittills: " + waittills_array.size + ". Add more if needed." );
			break;
	}
	
	if ( IsDefined( self.loc_current ) )
	{
		self.loc_current.in_use = undefined;
	}
}

/*
=============
///ScriptDocBegin
"Name: chopper_boss_think( <path_start> , <no_target_skip_check> )"
"Summary: Main logic loop for the chopper boss logic. Before running this on a chopper run init() to set chopper defaults and run 
chopper_boss_locs_populate( key, val ) to generate the nav graph."
"CallOn: A helicopter"
"MandatoryArg: <path_start>: The first struct in the nav graph that the Chopper should use."
"OptionalArg: <fast_move_out_of_range>: Set to true to have choppers try and move without trace checks if their closest target is 
out of their range. The result is that choppers move through the nav graph faster because they don't have to wait for other choppers 
to finish targetting before they can. Defaults to false to preseve original survival functionality."
"Example: heli chopper_boss_think( struct_start )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

chopper_boss_think( path_start, fast_move_out_of_range )
{
	AssertEx( IsDefined( path_start ), "Chopper boss behavior called with invalid path_start" );
	AssertEx( !IsDefined( path_start.in_use ), "Chopper boss behavior given start path struct that is in use." );
	AssertEx( !IsDefined( path_start.disabled ), "Chopper boss told to use path struct that is disabled" );
	
	self endon( "death" );
	self endon( "deathspin" );
	
	level endon( "special_op_terminated" );
	
	chopper_boss_wait_populate();
	
	// Default to not early out of targetting when really far away to 
	// preserve original survival functionality
	fast_move_out_of_range = ter_op( IsDefined( fast_move_out_of_range ), fast_move_out_of_range, false );
	
	// Must happen before waits!
	self.loc_current		= path_start;
	self.loc_current.in_use = true;
	
	self thread chopper_path_release( "death deathspin" );
	
	self.fired_weapons = false;
	
	// Logic Update Loop
	while ( 1 )
	{
		// Clear the target
		if ( !IsDefined( self.chopper_boss_agro ) )
			self.heli_target = undefined;
	
		
		// JC-ToDo: Chopper Boss
		//		- Have heli be able to move while shooting
		//		- Have heli ignore it's previous location if it just came from there twice ( something to stop helis from bouncing between nodes when targets are too close )
		//		- Have heli only do traces to players instead of to all allies
		
		if ( fast_move_out_of_range )
		{	
			self SetNearGoalNotifyDist( 2048 );
			// Before doing any complicated targetting ( traces ) check to 
			// see if the chopper is out of range of all targets. If so,
			// have the chopper skip the targetting delay check and move.
			closest_target	= self chopper_boss_get_closest_target_2D();
			if ( IsDefined( closest_target ) )
			{
				closest_neighbor = self chopper_boss_get_closest_neighbor_2D( closest_target );
				
				if ( IsDefined( closest_neighbor ) && !self chopper_boss_in_range( closest_target.origin, closest_neighbor.origin ) )
				{
					self.request_move = undefined;
					self [[ get_chopperboss_data( "pre_move_func" ) ]]();
					self thread chopper_boss_move( closest_neighbor );
					msg = self waittill_any_return( "reached_dynamic_path_end", "near_goal" );
					self thread [[ get_chopperboss_data( "post_move_func" ) ]]();
					continue;
				}
			}
		}
		
		// Get best location and set target
		
		// If the chopper had a move request or if the chopper
		// just fired ignore the current location in order to
		// attempt a move
		ignore_current_loc = IsDefined( self.request_move ) && self.request_move || self.fired_weapons;
		
		// Do not allow two helicopters to search for targets
		// at the same time because while searching, helicopters
		// store data on the struct locations throughout the map.
		// This also limits the chopper trace count per frame to
		// the max allowed in the below targeting logic
		while ( IsDefined( level.chopper_boss_finding_target ) && level.chopper_boss_finding_target == true )
		{
			wait 0.05;
		}
		
		// This will set the level.chopper_boss_finding_target 
		// flag to prevent other chopper from doing traces while
		// targeting. This also has waits in it if more than 4
		// traces are needed.
		best_loc = self chopper_boss_get_best_location_and_target( ignore_current_loc );
		
		if ( IsDefined( best_loc ) && self.loc_current != best_loc )
		{
			self [[ get_chopperboss_data( "pre_move_func" ) ]]();
			
			// Clear the move request as it's been filled
			self.request_move = undefined;
			self thread chopper_boss_move( best_loc );
			if ( !IsDefined( self.chopper_boss_agro ) )
				self waittill( "reached_dynamic_path_end" );
			else
				self waittill( "near_goal" );
			self thread [[ get_chopperboss_data( "post_move_func" ) ]]();
		}
		
		self [[ get_chopperboss_data( "stop_func" ) ]]();
		
		wait 0.1;
	}
}

chopper_boss_get_closest_target_2D()
{
	targets = [[ self get_chopperboss_data( "get_targets_func" ) ]]();
	if ( !targets.size )
		return undefined;
	
	closest = undefined;
	dist2D	= undefined;
	foreach ( target in targets )
	{
		if ( !IsDefined( closest ) )
		{
			closest = target;
			dist2D	= Distance2D( self.origin, target.origin );
		}
		else
		{
			dist2D_comp = Distance2D( self.origin, target.origin );
			if ( dist2D_comp < dist2D )
			{
				closest = target;
				dist2D	= dist2D_comp;
			}
		}
	}
	
	return closest;
}

chopper_boss_get_closest_neighbor_2D( target )
{
	AssertEx( IsDefined( self.loc_current ), "Chopper has no current location." );
	AssertEx( IsDefined( self.loc_current.neighbors ) && self.loc_current.neighbors.size, "Chopper current location has no neighbors." );
	
	closest = undefined;
	dist2D	= undefined;
	foreach ( neighbor in self.loc_current.neighbors )
	{
		if ( IsDefined( neighbor.in_use ) || IsDefined( neighbor.disabled ) )
				continue;
		
		if ( !IsDefined( closest ) )
		{
			closest = neighbor;
			dist2D	= Distance2D( neighbor.origin, target.origin );
		}
		else
		{
			dist2D_comp = Distance2D( neighbor.origin, target.origin );
			if ( dist2D_comp < dist2D )
			{
				closest = neighbor;
				dist2D	= dist2D_comp;
			}
		}
	}
	
	return closest;
}

chopper_boss_in_range( target_origin, loc_origin )
{
	AssertEx( IsDefined( self ), "Chopper not specified." );
	AssertEx( IsDefined( target_origin ), "Target origin not specified." );
	
	loc_origin = ter_op( IsDefined( loc_origin ), loc_origin, self.origin );
	
	target_dist = Distance2D( loc_origin, target_origin );
	
	min_dist2D = self get_chopperboss_data( "min_target_dist2d" );
	max_dist2d = self get_chopperboss_data( "max_target_dist2d" );
	
	return	target_dist >= min_dist2D && target_dist <= max_dist2d;
}

chopper_boss_set_target( target )
{
	if ( IsDefined( target ) )
	{
		self.heli_target = target;
	}
}

chopper_boss_attempt_firing( target )
{
	AssertEx( IsDefined( self )	, "Chopper not defined." );
	AssertEx( IsDefined( target ), "Target not defined." );
	
	self endon( "deathspin" );
	self endon( "death" );
	
	shot_target = false;
	
	target_forced = self maps\_chopperboss_utility::chopper_boss_forced_target_get();
	
	// Note that if there is a forced target, the passed target param gets overridden with that
	should_shoot = false;
	if ( IsDefined( target ) || IsDefined( target_forced ) )
	{	
		// If the a forced target is set ignore distance and heli target count
		// and override the passed target
		if ( IsDefined( target_forced ) )
		{
			target		 = target_forced;
			should_shoot = true;
		}
		else
		{
			heli_shooting = 0;
			if ( IsDefined( target.heli_shooting ) )
			{
				heli_shooting = target.heli_shooting;
			}
			
			if ( heli_shooting < self get_chopperboss_data( "heli_shoot_limit" ) && self chopper_boss_in_range( target.origin ) )
			{
				should_shoot = true;
			}
		}
	}
	
	if ( should_shoot )
	{
		self thread chopper_boss_manage_shooting_flag( target );
		
		self SetLookAtEnt( target );
		is_facing = self chopper_boss_wait_face_target( target, get_chopperboss_data( "face_target_timeout" ) );
		
		// After turning, make sure the target is still valid
		if ( IsDefined( target ) )
		{
			if ( IsDefined( is_facing ) && is_facing )
			{
				shot_target = self [[ get_chopperboss_data( "fire_func" ) ]]( target );
				shot_target = ter_op( IsDefined( shot_target ), shot_target, true );
			}
		}
		
		self notify( "chopper_done_shooting" );
	}
	
	return shot_target;
}

chopper_boss_manage_shooting_flag( target )
{
	Assert( IsDefined( self ) );
	Assert( IsDefined( target ) );
	
	if ( !IsDefined( target.heli_shooting ) )
	{
		target.heli_shooting = 0;
	}
		
	target.heli_shooting++;
	
	self waittill_any( "death", "deathspin", "chopper_done_shooting" );
	
	if ( IsDefined( target ) )
	{
		AssertEx( target.heli_shooting > 0, "heli_shooting flag is no longer in sync." );
		target.heli_shooting--;
	}
}

chopper_boss_wait_face_target( target, timeout )
{
	AssertEx( IsDefined( target ), "Invalid target" );
	
	self endon( "death" );
	self endon( "deathspin" );
	target endon( "death" );
	
	end_time = undefined;
	if ( IsDefined( timeout ) )
		end_time = GetTime() + timeout * 1000;
	
	while ( IsDefined( target ) )
	{
		if ( within_fov_2d( self.origin, self.angles, target.origin, 0.0 ) )
			return true;
		
		if ( IsDefined( end_time ) && GetTime() >= end_time )
			return false;
		
		wait 0.25;
	}
	
}

chopper_boss_manage_targeting_flag()
{
	AssertEx( !IsDefined( level.chopper_boss_finding_target ) || level.chopper_boss_finding_target == false, "Chopper currently targeting flag was already set to true." );
	
	level.chopper_boss_finding_target = true;
	
	self waittill_any( "death", "deathspin", "chopper_done_targeting" );
	
	level.chopper_boss_finding_target = undefined;
}

// Returns undefined if the current loc is the best
chopper_boss_get_best_location_and_target( ignore_current_loc )
{
	AssertEx( IsDefined( self ) && IsDefined( self.loc_current )						, "Chopper undefined or has no current loc reference." );
	AssertEx( IsDefined( self.loc_current.neighbors ) && self.loc_current.neighbors.size, "Chopper current location has no neighbors." );
	
	self endon( "death" );
	
	// Gather array of all optional locations
	optional_locs = self.loc_current.neighbors;
	if ( !IsDefined( ignore_current_loc ) || ignore_current_loc == false )
		optional_locs[ optional_locs.size ] = self.loc_current;
	
	targets = chopper_boss_get_target();
		
	//return self chopper_boss_get_best_location_and_target_proc( optional_locs, targets );
	return [[ self get_chopperboss_data( "next_loc_func" ) ]]( optional_locs, targets );
}

chopper_boss_get_target()
{
	targets = undefined;
	if ( IsDefined( self maps\_chopperboss_utility::chopper_boss_forced_target_get() ) )
	{
		targets = [ self maps\_chopperboss_utility::chopper_boss_forced_target_get() ];
	}
	else
	{
		targets = [[ self get_chopperboss_data( "get_targets_func" ) ]]();
	}
	return targets;
}

chopper_boss_get_best_location_and_target_proc( optional_locs, targets )
{
	tracecheck_func = self get_chopperboss_data( "tracecheck_func" );
	
	// Let other choppers know that this chopper is targeting
	// and clear the flag when the chopper dies or when
	// targetting is done
	self thread chopper_boss_manage_targeting_flag();
	
	valid_locs = [];
	traces	   = 0;
	// Check each location against each target to see if it's a 
	// valid location.
	foreach ( loc in optional_locs )
	{
		// Early out if loc in use unless it's the current location
		if ( loc != self.loc_current && IsDefined( loc.in_use ) )
			continue;
		
		// Don't evaluate locations which are disabled
		if ( IsDefined( loc.disabled ) )
			continue;
		
		// Scrub the location
		loc.heli_target = undefined;
		loc.dist2D		= undefined;
		
		dist_target = undefined;
		
		// Only allow 4 traces per frame. This wait is okay
		// because two helicopters are not allowed to think
		// about shooting at the same time. By not allowing
		// helicopters to think simultaneously, this logic
		// won't stomp other helicopter data on struct 
		// locations when searching for targets
		lock( "chopperboss_trace" );
		
		foreach ( target in targets )
		{
			unlock_wait( "chopperboss_trace" );
			lock( "chopperboss_trace" );

			// Because there is a wait at the end of this loop
			// to limit the number of traces per frame make
			// sure the target is valid before evaluating
			if ( !IsDefined( target ) )
				continue;
			
			// Early out if the loc and target are not in range of
			// each other to reduce the number of traces
			if ( self chopper_boss_in_range( target.origin, loc.origin ) == false )
				continue;
			
			trace_loc = target.origin + ( 0, 0, 64 );
			if ( IsAI( target ) || IsPlayer( target ) )
				trace_loc = target GetEye();
				
			if ( self [[ tracecheck_func ]]( loc.origin, trace_loc ) )
			{
				// if the current loc has no target use this one and grab
				// the distance
				if ( !IsDefined( loc.heli_target ) )
				{
					valid_locs[ valid_locs.size ] = loc;
					loc.heli_target				  = target;
					dist_target					  = Distance2D( loc.origin, target.origin );
				}
				else
				{
					// Because of the above in range check it can be assumed
					// that both the current target and the previously set
					// loc target are both in range so pick the closer one
					dist_test = Distance2D( loc.origin, target.origin );
					if ( dist_test < dist_target )
					{
						loc.heli_target = target;
						dist_target		= dist_test;
					}
				}
			}
			
			
		}
		unlock_wait( "chopperboss_trace" );
	}
	
	// Go through the found valid locs and make sure none of their targets died
	// during the trace wait delay in the above loop. Also make sure the locs weren't
	// scooped up by other choppers or disabled during the trace waits.
		// Note: A loc could only be scooped up by another chopper if 
		// fast_move_out_of_range was true in the call to chopper_boss_think()
		// This allows choppers to move while out of range even if other choppers
		// are busy targetting
	if ( valid_locs.size )
	{
		valid_locs_cleaned = [];
		
		foreach ( loc in valid_locs )
		{
			if ( IsDefined( loc.heli_target ) && !IsDefined( loc.in_use ) && !IsDefined( loc.disabled ) )
				valid_locs_cleaned[ valid_locs_cleaned.size ] = loc;
		}
		
		valid_locs = valid_locs_cleaned;
	}
	
	
	// If no locs were found with valid targets go through all 
	// possible locs and set their dist2D to the closest target 
	// but do not set the target for the loc.
	if ( !valid_locs.size )
	{
		// Grab the original list of optional locs
		foreach ( loc in optional_locs )
		{
			// Early out if in use unless it's the current location
			if ( loc != self.loc_current && IsDefined( loc.in_use ) )
				continue;
			
			// Don't evaulate locations which are disabled
			if ( IsDefined( loc.disabled ) )
				continue;
			
			closest_target = undefined;
			foreach ( target in targets )
			{
				// Because there is a wait in the above gather targets
				// loop make sure each target in the targets array is valid
				if ( !IsDefined( target ) )
					continue;
				
				if ( !IsDefined( closest_target ) )
				{
					closest_target = target;
					loc.dist2D	   = Distance2D( loc.origin, target.origin );
				}
				else
				{
					dist = Distance2D( loc.origin, target.origin );
					if ( dist < loc.dist2D )
					{
						closest_target = target;
						loc.dist2D	   = dist;
					}
				}
			}
			
			if ( IsDefined( loc.dist2D ) )
				valid_locs[ valid_locs.size ] = loc;
		}	
	}
	else
	{
		// Populate the valid locations with a 2D distance from their target
		foreach ( loc in valid_locs )
			loc.dist2D = Distance2D( loc.heli_target.origin, loc.origin );
	}

	// Sort the locations from the target location
	sorted_locs = array_sort_by_handler( valid_locs, ::chopper_boss_loc_compare );
	
	next_loc = undefined;
	
	// Find the closest location outside of the min distance and inside
	// the max
	foreach ( loc in sorted_locs )
	{
		min_dist2D = self get_chopperboss_data( "min_target_dist2d" );
		max_dist2D = self get_chopperboss_data( "max_target_dist2d" );
		
		if ( loc.dist2D >= min_dist2D && loc.dist2D <= max_dist2D )
		{
			next_loc = loc;
			break;
		}
	}
	
	// If no location was found outside of the min distance and inside
	// the max go to the closest location. This prevents choppers from
	// getting stuck outside the max forever until the player comes
	// in range
	if ( !IsDefined( next_loc ) && sorted_locs.size )
	{
		next_loc = sorted_locs[ 0 ];	
	}
	
	// Assign the helicopter a new target if a loc was found
	if ( IsDefined( next_loc ) && IsDefined( next_loc.heli_target ) )
		self chopper_boss_set_target( next_loc.heli_target );
	
	self notify( "chopper_done_targeting" );
	
	// Return the next location as long as it's not the current
	if ( IsDefined( next_loc ) && next_loc != self.loc_current )
		return next_loc;
	else
		return undefined;
}

chopper_boss_get_best_target_proc( targets )
{
	tracecheck_func = self get_chopperboss_data( "tracecheck_func" );
	dist_target		= undefined;
	
	// helicopters to think simultaneously, this logic
	// won't stomp other helicopter data on struct 
	// locations when searching for targets
	lock( "chopperboss_trace" );
	
	heli_target = undefined;
	
	foreach ( target in targets )
	{
		unlock_wait( "chopperboss_trace" );
		lock( "chopperboss_trace" );

		// Because there is a wait at the end of this loop
		// to limit the number of traces per frame make
		// sure the target is valid before evaluating
		if ( !IsDefined( target ) )
			continue;
		
		// Early out if the loc and target are not in range of
		// each other to reduce the number of traces
		if ( self chopper_boss_in_range( target.origin, self.origin ) == false )
			continue;
		
		trace_loc = target.origin + ( 0, 0, 64 );
		if ( IsAI( target ) || IsPlayer( target ) )
			trace_loc = target GetEye();
			
		if ( self [[ tracecheck_func ]]( self GetCentroid(), trace_loc ) )
		{
			heli_target = target;
			dist_target = Distance2D( self GetCentroid(), target.origin );
		}
	}
	
	unlock_wait( "chopperboss_trace" );
	self chopper_boss_set_target( heli_target );
}

chopper_boss_loc_compare()
{
	Assert( IsDefined( self ) && IsDefined( self.dist2D ), "Need dist2D property defined." );
	return self.dist2D;	
}

chopper_boss_move( target_struct )
{
	self notify( "chopper_boss_move" );
	AssertEx( !IsDefined( target_struct.in_use ), "helicopter told to use path that is in use." );
	AssertEx( !IsDefined( target_struct.disabled ), "helicopter told to use path that is disabled" );
	
	if ( IsDefined( self.loc_current ) )
		self.loc_current.in_use = undefined;
	self.loc_current		= target_struct;
	self.loc_current.in_use = true;
	
	self thread maps\_vehicle::vehicle_paths( target_struct );
}

chopper_boss_agro_chopper()
{
	self endon ( "stop_chopper_boss_agro_chopper" );
	self endon ( "death" );
	self endon ( "deathspin" );
	self.chopper_boss_agro = true;
	
	while ( true )
	{
		targets = chopper_boss_get_target();
		//workout targets.
		chopper_boss_get_best_target_proc( targets );
		chopper_boss_stop_func(); // usually tells the thing to fire
		wait 0.05;
	}
}

stop_chopper_boss_agro_chopper()
{
	self notify ( "stop_chopper_boss_agro_chopper" );
}