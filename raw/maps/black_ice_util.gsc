#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_vignette;

SCRIPT_NAME = "black_ice_util.gsc";

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_start( player_start_name )
{
	// Grab struct
	player_start = GetEnt( player_start_name, "targetname" );
	AssertEx( IsDefined( player_start ), "Player start '" + player_start_name + "' does not exist!" );
	
	// Move player to start
	level.player setOrigin( player_start.origin );
	level.player setPlayerAngles( player_start.angles );
}

player_setup()
{
	level.player.animname = "player";
	level.player SetThreatBiasGroup( "player" );
	
	// This will kill the player via fire (to override the default deathinvulernabletime)
	level.player thread fire_death_watcher();
}

fire_death_watcher( damage_amt, attacker )
{
	while( 1 )
	{
		flag_wait( "flag_fire_damage_on" );
		self waittill( "damage", damage_amt, attacker, direction_vec, point, type );
		
		if( IsDefined( attacker ) && attacker.classname != "worldspawn" )
		{
			if( ( attacker == level._fire_damage_ent ) && ((self.health - damage_amt) <= 0 ))
			{
				setdvar( "ui_deadquote", &"BLACK_ICE_DEATH_FIRE" );
				MissionFailedWrapper();
			}
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

exploder_damage_loop( exploder_name, damage_ent )
{		
	fires = [];
	
	fires_list = get_exploder_array( exploder_name );
	
	// Sort out fires that may be in exploder group, but shouldn't cause damage	
	foreach( fire in fires_list )
	{
		if( IsDefined( fire.v[ "damage" ] ) && ( fire.v[ "damage" ] > 0 ))
		{
			// Make sure damage position is on the ground
			fire.v[ "origin" ] = GetGroundPosition( fire.v[ "origin" ], 1 );
			fires = array_add( fires, fire );
		}
	}
	
	if( !Isdefined( level._fires ))
		level._fires = [];
	
	level._fires[ exploder_name ] = fires;
	
	while( fires.size > 0 )
	{
		flag_wait( "flag_fire_damage_on" );
		foreach( fire in fires )
		{
			// Send damage OR remove fire if it doesn't exist anymore
			if( IsDefined( fire ))
				fire thread fire_damage( damage_ent );
			else
				fires = array_remove( fires, fire );
			
//			if( IsDefined( fire ))
//				print3d( fire.v[ "origin" ], "(.)", (1,1,1), 1,1,1000 );
			
		}
		wait( 0.1 );
	}
}

fire_damage( damage_ent, damage_amount )
{
	if ( IsDefined( self.v[ "delay" ] ) )
		delay = self.v[ "delay" ];
	else
		delay = 1;

	if ( IsDefined( self.v[ "damage_radius" ] ) )
		radius = self.v[ "damage_radius" ];
	else
		radius = 128;

	// How much damage?
	damage = 4;
	if( IsDefined( damage_amount ))
		damage = damage_amount;
//	else if( self.v[ "damage" ] > 0 )
//		damage = self.v[ "damage" ];
	
	origin = self.v[ "origin" ];

	wait( delay );
	
	// Cause damage	
	RadiusDamage( origin, radius, damage, damage, damage_ent );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Takes a value and returns a 0 - 1 float based a min and max
normalize_value( min_val, max_val, val_to_normalize )
{

	if ( val_to_normalize > max_val )
	{
		return 1.0;
	}
	else if ( val_to_normalize < min_val )
	{
		return 0.0;
	}	
	return (( val_to_normalize - min_val ) / ( max_val -  min_val ));
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Use a 0 - 1 float to generate a value based on min and max values
// zero is the min value, 1 is the max value, anything in between would be factored.
factor_value_min_max( min_val, max_val, factor_val )
{
	return ( max_val * factor_val ) + ( min_val * ( 1 - factor_val ));
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Alpha team
spawn_allies()
{
	CONST_EXPECTED_NUM_ALLIES = 2;		//How many allies do we expect?
	
	// Get Spawners
	spawners = GetEntArray( "spawner_allies", "script_noteworthy" );	
	AssertEx( spawners.size == CONST_EXPECTED_NUM_ALLIES, "Alpha squad has " + spawners.size + " spawners (expecting " + CONST_EXPECTED_NUM_ALLIES + ")" );
	
	array_thread( spawners, ::add_spawn_function, ::spawnfunc_ally );
	
	// Spawn and load into global
	level._allies = spawn_allies_group( spawners );		
}

spawn_allies_swim()
{
	// Get Spawners							 
	ally_spawners = GetEntArray( "spawner_allies_swim", "script_noteworthy" );
	//bravo_spawners = GetEntArray( "spawner_bravo_swim", "script_noteworthy" );
	//AssertEx( ( ally_spawners.size + bravo_spawners.size ) == level.CONST_EXPECTED_NUM_SWIM_ALLIES, "Alpha & Bravo squad has " + ( ally_spawners.size + bravo_spawners.size ) + " spawners (expecting " + level.CONST_EXPECTED_NUM_SWIM_ALLIES + ")" );

	// Spawn and return (loading into separate global outside of this script)
	allies = spawn_allies_group( ally_spawners );
	//bravo = spawn_bravo_group( bravo_spawners );
	
	// Custom building this array now (we want them in particular positions)
	swimmers = [];
	//swimmers[0] = bravo[0];
	swimmers[0] = allies[0];
	//swimmers[2] = bravo[1];
	swimmers[1] = allies[1];
	
	return swimmers;
	//return array_merge( allies, bravo );
}

spawn_allies_group( spawners )
{
	spawned_allies = [];
	
	foreach( spawner in spawners )
	{		
		Assert( IsDefined( spawner.targetname ));
		
		if( IsSubStr( spawner.targetname, "ally_01" ))
		{			
			spawner.script_friendname = "Merrick";
			ally = spawner spawn_ai();			
			Assert( IsDefined( ally ));
			ally.animname = "ally1";
			ally.v.invincible = true;
			spawned_allies[ 0 ] = ally;			
		}
		else if( IsSubStr( spawner.targetname, "ally_02" ))
		{
			spawner.script_friendname = "Hesh";
			ally = spawner spawn_ai();
			Assert( IsDefined( ally ));
			ally.animname = "ally2";
			ally.v.invincible = true;
			spawned_allies[ 1 ] = ally;
		}
		else
		{
			AssertMsg( "Unknown ally '" + spawner.targetname );
		}		
	}
	
	Assert( spawned_allies.size == spawners.size );
	
	return spawned_allies;
}

// Spawnfunc for Alpha team members
spawnfunc_ally()
{
	self set_archetype( "black_ice_ally" );
	self magic_bullet_shield();	
	self.hero = true;
}

// Teleport allies to specific postiions/angles
teleport_allies( position_tNames )
{	
	Assert( IsDefined( self ));
	
	// Get starting positions
	positions = [];
	foreach( tName in position_tNames )
		positions = array_add( positions, GetStruct( tName, "targetname" ));
	
	if( positions.size == 0 )
	{
		// No positions, maybe the ents are not script_structs
		foreach( tName in position_tNames )
		{
			position = GetEnt( tName, "targetname" );
			AssertEX( IsDefined( position ), level.start_point + ": Ally start point position '" + tName + "' does not exist!" );
			positions = array_add( positions, position );			
		}
	}		
	
	// Make sure there are enough positions for everyone
	if( positions.size != self.size )		
		AssertMsg( level.start_point + ": There are " + positions.size + " start point positions for squad (expecting " + self.size + ")" );

	for( i = 0; i < self.size; i++ )
	{
		if( !IsDefined( positions[ i ].angles ))
			positions[ i ].angles = self[ i ].angles;
		self[ i ] ForceTeleport( positions[ i ].origin, positions[ i ].angles );
	}
}

// Bravo Team
spawn_bravo()
{
	// Get Spawners
	spawners = GetEntArray( "spawner_bravo", "script_noteworthy" );	
	
	foreach( guy in spawners )	
	{
		guy add_spawn_function( ::spawnfunc_bravo );
	}	
	
	// Spawn and load into global
	level._bravo = spawn_bravo_group( spawners );
}

spawn_bravo_group( spawners )
{
	spawned_bravo = [];
	
	foreach( spawner in spawners )
	{		
		Assert( IsDefined( spawner.targetname ));
		
		if( IsSubStr( spawner.targetname, "bravo_01" ))
		{
			ally = spawner spawn_ai();
			Assert( IsDefined( ally ));
			ally.disable_sniper_glint = 1;
			ally.animname = "bravo1";
			spawned_bravo[ 0 ] = ally;
		}
		else if( IsSubStr( spawner.targetname, "bravo_02" ))
		{
			ally = spawner spawn_ai();
			Assert( IsDefined( ally ));
			ally.animname = "bravo2";				
			spawned_bravo[ 1 ] = ally;
		}
		else
		{
			AssertMsg( "Unknown ally '" + spawner.targetname );
		}
	}
	
	Assert( spawned_bravo.size == spawners.size );
	
	return spawned_bravo;
}

// Spawnfunc for Bravo team members
spawnfunc_bravo()
{	
	self magic_bullet_shield();
	// self thread hide_dufflebag(); // no dufflebags on ghillie characters
}

hide_dufflebag()
{
	// get duffle bag parts
	bag_parts = [];
	bag_parts[ bag_parts.size ] = "J_Cog";
	bag_parts[ bag_parts.size ] = "J_Strap_Base";
	bag_parts[ bag_parts.size ] = "J_Strap_End";
	bag_parts[ bag_parts.size ] = "J_Strap_1";
	bag_parts[ bag_parts.size ] = "J_Strap_2";
	bag_parts[ bag_parts.size ] = "J_Strap_3";
	bag_parts[ bag_parts.size ] = "J_Strap_4";
	bag_parts[ bag_parts.size ] = "J_Strap_5";
	bag_parts[ bag_parts.size ] = "J_Strap_6";
	bag_parts[ bag_parts.size ] = "J_Strap_7";
	bag_parts[ bag_parts.size ] = "J_Strap_8";
	bag_parts[ bag_parts.size ] = "J_Strap_9";
	bag_parts[ bag_parts.size ] = "J_Strap_10";
	bag_parts[ bag_parts.size ] = "J_Strap_11";
	bag_parts[ bag_parts.size ] = "J_Strap_12";
	bag_parts[ bag_parts.size ] = "J_Strap_13";
	bag_parts[ bag_parts.size ] = "J_Strap_14";
	
	// hide duffle bag
	foreach ( part in bag_parts )
		self HidePart( part );
}

//*******************************************************************
//																	*
//		ALERTS														*
//*******************************************************************

ai_alert_range( entity, radius, needs_sight, play_reaction, tell_friends )
{
	self endon( "death" );
	self endon( "alert" );

	radius_sq = radius * radius;
	
	while( 1 )
	{
		dist = DistanceSquared( self.origin, entity.origin );
		if( DistanceSquared( self.origin, entity.origin ) <= radius_sq )
		{
			if( IsDefined( needs_sight ) && needs_sight)
			{
				if( self CanSee( entity ) )
					break;
			}
			else
				break;
		}
		wait 0.05;
	}
	
	self thread ai_alert( play_reaction, tell_friends );
}

ai_alert_bullet( play_react, tell_friends )
{
	self endon( "death" );
	self endon( "alert" );
	
	while( 1 )
	{
		self waittill( "bulletwhizby", shooter, distance );
		if( distance < 70.0 && shooter GetThreatBiasGroup() == "alpha" )
			break;
	}
	
	self thread ai_alert( play_react, tell_friends );
}

ai_alert_damage( play_react, tell_friends )
{
	self endon( "death" );
	self endon( "alert" );
	
	// add friend alert to account for death
	tell_locals = tell_friends;
	if( IsString( tell_locals ) )
	{
		baddies = get_ai_group_ai( tell_locals );
		foreach( baddie in baddies )
			if( baddie != self )
				baddie thread ai_alert_friend_death( self, false, false );
		
		// switch tell_locals to a bool... avoid errors and allow check for aigroup
		tell_locals = true;
	}
	if( tell_locals && IsDefined( self.script_aigroup ) )
	{
		baddies = get_ai_group_ai( self.script_aigroup );
		foreach( baddie in baddies )
			if( baddie != self )
				baddie thread ai_alert_friend_death( self, false, false );
	}
	
	// check for damage
	while( 1 )
	{
		self waittill( "damage", amount, shooter );
		if( shooter GetThreatBiasGroup() == "alpha" )
			break;
	}
	
	self thread ai_alert( play_react, tell_friends );
}

ai_alert_friend_death( dead_friend, play_react, tell_friends )
{
	self endon( "death" );
	self endon( "alert" );
	self notify( dead_friend.unique_id );
	self endon( dead_friend.unique_id );
	
	// wait till your friend dies
	dead_friend waittill( "death" );
	self thread ai_alert( play_react, tell_friends );
}

ai_alert( play_react, tell_friends )
{
	self endon( "death" );
	
	// init vars
	if( !IsDefined( play_react ) )
		play_react = false;
	if(  !IsDefined( tell_friends ) )
		tell_friends = false;
	
	// clear old patrolling stuff
	self StopAnimScripted();
	self enable_danger_react( 10 );
	self clear_run_anim();
	self clear_deathanim();
	
	// play reaction animation
	if( play_react && IsDefined( self.surprise_anims ) )
	{
		self.animname = "generic";
		anims = self.surprise_anims;
		
		self thread anim_single_solo( self, random( anims ) );
		self.allowdeath = true;
		wait( RandomFloatRange( 0.7, 1.0 ) );
		self StopAnimScripted();
	}
	
	// halt predifined pathing
	self notify( "stop_going_to_node" );
	
	// un-make ghost
	if( self GetThreatBiasGroup() != "axis" )
	{
		SetThreatBias( self GetThreatBiasGroup(), "alpha", 100 );
		SetThreatBias( "alpha", self GetThreatBiasGroup(), 100 );
	}
	else
	{
		self set_ignoreall( false );
		self set_ignoreme( false );
	}
	
	// give gun back
	self thread gun_recall();
	
	// alert your friends
	if( IsString( tell_friends ) )
	{
		baddies = get_ai_group_ai( tell_friends );
		foreach( baddie in baddies )
			if( baddie != self )
				baddie thread ai_alert( false, false );
		
		// switch tell_friends to a bool... avoid errors and allow check for aigroup
		tell_friends = true;
	}
	if( tell_friends && IsDefined( self.script_aigroup ) )
	{
		baddies = get_ai_group_ai( self.script_aigroup );
		foreach( baddie in baddies )
			if( baddie != self )
				baddie thread ai_alert( false, false );
	}
	
	// stop loops
	self notify( "alert" );
}

flash_grenade_proc( guy, goto_name )
{
	// called from a notetrack
	
	// get start origins
	startOrg = guy GetTagOrigin( "J_Wrist_LE" );
	endOrg	 = GetEnt( goto_name, "targetname" );
	endOrg	 = endOrg.origin;

	strength = ( Distance( endOrg, guy.origin ) * 2.0 );
	strength = clamp( strength, 300, 1000 );
	vector	 = VectorNormalize( endOrg - guy.origin );
	velocity = ( vector * strength );
	
	// throw grenade
	MagicGrenadeManual( "flash_grenade", startOrg, velocity, 1.0 );
}

delay_retreat( group, time, op_count, flg, trigs, b_off, notes )
{
	// thread opfor count retreat condition
	if( IsDefined( op_count ) )
	{
		thread opfor_retreat( group, op_count, flg, trigs, b_off, notes );
	}
	
	// wait
	flag_wait_or_timeout( flg, time );
	
	// check flag
	if( flag( flg ) )
		return;
	
	// TEMP TEMP
	// IPrintLnBold( "Retreat timeout: " + time + " seconds" );
	
	// start retreat
	thread retreat_proc( flg, trigs, b_off, notes );
}

opfor_retreat( group, op_count, flg, trigs, b_off, notes )
{
	// wait
	while( get_ai_group_sentient_count( group ) > op_count && !flag( flg ) )
		wait( 0.1 );
	
	// check flag
	if( flag( flg ) )
		return;
	
	// TEMP TEMP
	// IPrintLnBold( "Retreat kills: " + get_ai_group_sentient_count( group ) + " left" );
	
	// start retreat
	thread retreat_proc( flg, trigs, b_off, notes );
}

retreat_proc( flg, trigs, b_off, notes )
{
	// make sure trigs is an array
	if( IsDefined( trigs ) && !IsArray( trigs ) )
		trigs = [ trigs ];
	
	// get triggers
	if( IsDefined( trigs ) )
	{
		t_array = [];
		foreach( trig in trigs )
		{
			trig = GetEnt( trig, "targetname" );
			if( IsDefined( trig ) )
				t_array[t_array.size] = trig;
		}
		
		if( t_array.size > 0 )
			trigs = t_array;
		else
			trigs = undefined;
	}
	
	// trigger trigs
	if( IsDefined( trigs ) )
	{
		trigs[0] notify( "trigger" );
		
		// turn off trigger ( if bool is set )
		if( IsDefined( b_off ) && b_off )
			array_thread( trigs, ::trigger_off );
	}
	
	// set flag
	if( !flag( flg ) )
		flag_set( flg );
	
	// check notes
	if( IsDefined( notes ) && !IsArray( notes ) )
		notes = [ notes ];
	
	// send notes
	if( IsDefined( notes ) )
		foreach( note in notes )
			level notify( note );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

temp_dialogue_line( name, msg, time )
{
	if ( GetDvarInt( "loc_warnings", 0 ) )
		return;// I'm not localizing your damn temp dialog lines - Nate.

	if ( !isdefined( level.dialogue_huds ) )
	{
		level.dialogue_huds = [];
	}

	for ( index = 0; ; index++ )
	{
		if ( !isdefined( level.dialogue_huds[ index ] ) )
			break;
	}
	color = "^3";
	
	if( !IsDefined( time ) )
		time = 1;
	time = max( 1, time );

	level.dialogue_huds[ index ] = true;

	hudelem = maps\_hud_util::createFontString( "default", 1.5 );
	hudelem.location = 0;
	hudelem.alignX = "left";
	hudelem.alignY = "top";
	hudelem.foreground = 1;
	hudelem.sort = 20;

	hudelem.alpha = 0;
	hudelem FadeOverTime( 0.5 );
	hudelem.alpha = 1;
	hudelem.x = 40;
	hudelem.y = 260 + index * 18;
	hudelem.label = " " + color + "< " + name + " > ^7" + msg;
	hudelem.color = ( 1, 1, 1 );

	wait( time );
	timer = 0.5 * 20;
	hudelem FadeOverTime( 0.5 );
	hudelem.alpha = 0;

	for ( i = 0; i < timer; i++ )
	{
		hudelem.color = ( 1, 1, 0 / ( timer - i ) );
		wait( 0.05 );
	}
	wait( 0.25 );

	hudelem Destroy();

	level.dialogue_huds[ index ] = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
check_anim_time( animname, anime, time )
{
	curr_time = self GetAnimTime( level.scr_anim[ animname ][ anime ] );
	if ( curr_time >= time )		
	{
		return true;
	}

	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

trigger_ally_advance( tTrigger, custom_timeout, index, num_to_move )
{				
	if( !IsDefined( level._allies_advancing ))
		level._allies_advancing = false;
	
	// Keep track of if allies are moving to spots
	if( !flag_exist( "flag_allies_moving" ))
		flag_init( "flag_allies_moving" );
		
	triggers = GetEntArray( tTrigger, "targetname" );
	Assert( triggers.size > 0 );	

	array_thread( triggers, ::waittill_trigger_or_timeout, custom_timeout, index, num_to_move );	
	
	// If enemy number defined
	if( IsDefined( index ))
		thread waittill_enemy_number_remaining( index, num_to_move );
	
	level waittill( "notify_ally_advance" );
	
	array_thread( triggers, ::send_notify, "trigger" );
	
	// Turn off triggers
	array_thread( triggers, ::trigger_off );
		
	// Kill accessory functions
	level notify( "notify_kill_ally_advance_scripts" );
	
	// Wait until allies are at their goals (this is checked in waittill_trigger_or_timeout_result)
	thread waittill_allies_at_goal();	
	
	wait( 0.05 );
}

waittill_trigger_or_timeout( custom_timeout, index, num_to_move )
{
	self endon( "notify_kill_ally_advance_scripts" );		
	
	self ally_advance_debug();
	
	// Wait for player to trigger OR for timeout
	self waittill_timeout( custom_timeout );				
	
	level notify( "notify_ally_advance" );
}

waittill_timeout( timer )
{
	level endon( "notify_kill_ally_advance_scripts" );	
	self endon( "trigger" );
	
	// Wait for allies to stop moving
	while( level._allies_advancing )
		wait( 0.05 );
	
	ally_advance_debug( "timeout_start" );
	
	// If timer is not defined OR timer is equal to 0, wait for trigger
	if( !IsDefined( timer ) || (timer == 0 ))
		self waittill( "trigger" );	
	else
		wait( timer );
	
	ally_advance_debug( "timeout_end" );
}

waittill_enemy_number_remaining( index, num_to_move )
{
	level endon( "notify_kill_ally_advance_scripts" );
		
	// Wait for allies to stop moving
	while( level._allies_advancing )
		wait( 0.05 );
	
	Assert( IsDefined( num_to_move ));
	while( 1 )
	{
		enemies = remove_dead_from_array( level._enemies[ index ] );
		if( enemies.size <= num_to_move )
			break;
		
		wait( 0.5 );
	}
	
	ally_advance_debug( "enemy_number_reached" );
	
	level notify( "notify_ally_advance" );
}

waittill_allies_at_goal()
{	
	level notify( "notify_kill_allies_at_goal" );
	level endon( "notify_kill_allies_at_goal" );
	
	level._allies_advancing = true;
	
	ally_advance_debug( "allies_moving" );
	
	ent = spawnstruct();
	ent.threads = 0;	
	
	// Wait until goals
	foreach( ally in level._allies )	
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
			
	foreach( ally in level._allies )
	{
		ally.goalradius = ally._old_goalradius;
	}
	
	level._allies_advancing = false;
	
	ally_advance_debug( "allies_at_goal" );
	
	waittill_ally_proximity();
	
	ally_advance_debug( "player_near_allies" );
}

waittill_ally_proximity()
{	
	// Distance player must be within one ally
	DIST = 300;	
	
	dist_sq = dist * DIST;	
	
	ally1 = level._allies[ 0 ];
	ally2 = level._allies[ 1 ];
	
	while( 1 )
	{
		// Break when player is within a certain distance of one of the allies
		ally1_to_player = DistanceSquared( ally1.origin, level.player.origin );
		ally2_to_player = DistanceSquared( ally2.origin, level.player.origin );
		if( ( ally1_to_player <= dist_sq ) || ( ally1_to_player <= dist_sq ))
			break;
		
		wait( 0.5 );		
	}	
}

ally_advance_debug( msg )
{
	debug_on = 0;	
	
	if( debug_on )
	{
		if( self != level )
		{
			// If self is defined, assume its a trigger
			self thread ally_advance_debug_trigger();
		}
		else
		{
			iprintln( msg );
		}
	}
}

ally_advance_debug_trigger()
{
	self waittill( "trigger" );
	iprintln( self.targetname + " triggered" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ignore_until_goal()
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

add_enemy( index )
{	
	if( !IsDefined( level._enemies[ index ] ))
	   level._enemies[ index ] = [];
	   
	level._enemies[ index ] = array_add( level._enemies[ index ], self );
	self._current_index = index;
}

enemy_index_check( index )
{
	AssertEX( Isdefined( level._enemies[ index ] ), index + " does not exist in level._enemies" );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

retreat( index, vols_index, max_delay )
{		
	enemy_index_check( index );
	
	if( !IsDefined( level.retreat_volumes_list ))
		level.retreat_volumes_list = [];
	
	level notify( "notify_kill_retreat" + index );	
	level endon( "notify_kill_retreat" + index );
	
	guys = remove_dead_from_array( level._enemies[ index ] );	
	guys = SortByDistance( guys, level.player.origin );
	
	delay = 0.05;
	
	if( IsDefined( max_delay ) && ( max_delay > delay ))
		delay = max_delay;
	
	foreach( guy in guys )
		if( IsAlive( guy ))
			guy go_to_goal_volume( vols_index, delay );			
}

go_to_goal_volume( vols_index, max_delay )
{			
	self endon( "notify_stop_retreat" );
		
	vol = self choose_vol( vols_index );
	
	if( !IsDefined( vol ))
		return;
		
	self._current_goal_volume = vol;	
	
//	self notify( "stop_print3d" );
//	self thread debug_current_volume();
//	self thread debug_show_vol_nodes();
	
	self endon( "death" );		
	
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
	
	// Disable fixed node if on	
	self set_fixednode_false();		
	self SetGoalVolumeAuto( vol );
}

//debug_current_volume()
//{		
//	self endon( "stop_print3d" );
//	self endon( "death" );
//	
//	while( 1 )
//	{
//		print3d( self.origin + (0,0,64), self._current_goal_volume.script_noteworthy, (1,1,1), 1, 0.5, 1 );
//		wait( 0.05 );
//	}
//}
//
//debug_show_vol_nodes()
//{
//	self endon( "stop_print3d" );
//	self endon( "death" );
//	
//	while( 1 )
//	{
//		foreach( node in self._current_goal_volume.nodes )
//		{
//			mark = "o";
//			
//			if( IsDefined( node.owner ))
//				mark = "x";
//			
//			print3d( node.origin, mark + "(" + self._current_goal_volume._num_ai + "/" + self._current_goal_volume.nodes.size + ")", (1,0,0), 1, 1, 1 );
//		}
//		wait( 0.05 );
//	}
//}

choose_vol( vols_index )
{		
	vol = choose_vol_solo( vols_index );
	
	if( IsDefined( vol ))
	{
		self update_available_nodes( vol );
		return vol;
	}
	
	// All vols are occupied, send to another volume if retreat volumes are defined
	if( IsDefined( level.retreat_volumes_list ) && ( level.retreat_volumes_list.size > 0 ))
	{
		foreach( vol_name in level.retreat_volumes_list )
		{
			vol = choose_vol_solo( vol_name );
			if( IsDefined( vol ))
			{
				self update_available_nodes( vol );
				return vol;
			}
		}	
	}
	
	// If retreat node
	if( IsDefined( level.retreat_final ))
	{						
		vol = choose_vol_solo( level.retreat_final );
		
		if( IsDefined( vol ))
		{
			self thread ignore_until_goal();
			guys = [self];
			thread AI_delete_when_out_of_sight( guys, 256 );				
			return vol;
		}
	}
	
	// Totally out!  Have guys seek player
//	iprintln( vols_index + " doesn't have enough nodes for guys!" );
	
	if( IsDefined( self._current_index ))
	{
		level._enemies[ self._current_index ] = array_remove( level._enemies[ self._current_index ], self );
		self._current_index = undefined;
	}
	
	self._current_goal_volume = undefined;
	self thread player_seek_enable();
	
	iprintln( "player_seek " + self.export );
	
	self notify( "notify_stop_retreat" );
}

update_available_nodes( vol )
{	
	if( IsDefined( self._current_goal_volume ))
		self._current_goal_volume._num_ai--;
	
	self._current_goal_volume = vol;	
	vol._num_ai++;
	
	self thread deathfunc_vol_num_watcher( vol );
}

deathfunc_vol_num_watcher( vol )
{
	self notify( "notify_new_vol" );
	self endon( "notify_new_vol" );
	
	self waittill_either( "death", "notify_stop_retreat" );
	vol._num_ai--;
}

choose_vol_solo( vols_index )
{
	AssertEX( Isdefined( level._vols[ vols_index ] ), vols_index + " does not exist in level._vols" );
	
	vols = SortByDistance( level._vols[ vols_index ], self.origin );	
	
	// Choose the closest volume that doesn't already have too many guys
	foreach( vol in vols )
	{
		if( vol._num_ai < vol._max_ai )
		{
//			vol thread vol_available_nodes_watcher();			
			return vol;			
		}
	}
}

retreat_vol_pop( array )
{
	Assert( level.retreat_volumes_list.size > 0 );	
	vol = level.retreat_volumes_list[ 0 ];
	level.retreat_volumes_list = array_remove_index( level.retreat_volumes_list, 0 );	
	return vol;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_vol( string, type )
{
	Assert( IsDefined( string ));
	
	vol = undefined;
	
	if( IsDefined( type ))
	{
		vol = GetEnt( string, type );
	}
	else
	{
		// Assume targetname
		vol = GetEnt( string, "targetname" );
	}
	
	Assert( IsDefined( vol ));
	
	return vol;
}

get_vol_array( string, type )
{
	Assert( IsDefined( string ));
	
	vols = undefined;
	
	if( IsDefined( type ))
	{
		vols = GetEntArray( string, type );
	}
	else
	{
		// Assume targetname
		vols = GetEntArray( string, "targetname" );
	}
	
	Assert( vols.size > 0 );
	
	return vols;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vols_and_nodes()
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
						
						if( !IsDefined( vol.nodes ))
							vol.nodes = [];
						
						vol.nodes = array_add( vol.nodes, node );
					}
				}				
			}
			
			if( IsDefined( vol.nodes ))
			{
				if( !IsDefined( vols[ vol.script_noteworthy ] ))
			   		vols[ vol.script_noteworthy ] = [];
				
				vols[ vol.script_noteworthy ] = array_add( vols[ vol.script_noteworthy ], vol );
				
				vol._num_ai = 0;
			}
			else
			{
				vol._num_ai = 0;
				PrintLn( SCRIPT_NAME + ": Warning - Volume '" + vol.script_noteworthy + "' has no cover nodes!" );
			}
		}
	}
	
	node_test delete();
	
	return vols;
}

vol_available_nodes_watcher()
{
	self notify( "notify_stop_nodes_watcher" );
	self endon( "notify_stop_nodes_watcher" );
	
	while( 1 )
	{
		num_available_nodes = self.nodes.size;
		
		foreach( node in self.nodes )
			if( IsDefined( node.owner ))
				num_available_nodes--;
		
		self._num_ai = num_available_nodes;
			
		if( self._num_ai == self.nodes.size )
			break;
		
		wait( 0.05 );
	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

delete_at_anim_end( animname, anime, is_vignette_actor )
{
	while ( !( self maps\black_ice_util::check_anim_time( animname, anime, 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}
	
	if ( IsDefined( is_vignette_actor ) && is_vignette_actor )
	{
		self maps\_vignette_util::vignette_actor_delete();
	}
	else
	{
		self Delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ignore_everything()
{		
	// Looks like unignore_everything wasn't called, clear first
	if( IsDefined( self._ignore_settings_old ))
		self unignore_everything();
	
	self._ignore_settings_old = [];
	
	self.disableplayeradsloscheck = set_ignore_setting( self.disableplayeradsloscheck, "disableplayeradsloscheck", true );
	self.ignoreall				  = set_ignore_setting( self.ignoreall, "ignoreall", true );
	self.ignoreme				  = set_ignore_setting( self.ignoreme, "ignoreme", true );
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
	// Don't restore old settings
	if( IsDefined( dont_restore_old ) && dont_restore_old )
		if( IsDefined( self._ignore_settings_old ))
			self._ignore_settings_old = undefined;
			
	self.disableplayeradsloscheck = restore_ignore_setting( "disableplayeradsloscheck", false );
	self.ignoreall				  = restore_ignore_setting( "ignoreall", false );
	self.ignoreme				  = restore_ignore_setting( "ignoreme", false );
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

quake( soundalias, delay_time )
{
	if (!IsDefined( delay_time ) )
		delay_time = 0.0;
	
	level.player playsound( soundalias );
	wait delay_time;
	Earthquake( 0.5, 1, level.player.origin, 3000 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

array_thread_targetname( targetname, func, var1, var2, var3, var4, var5, var6, var7, var8, var9 )
{
	things = GetEntArray( targetname, "targetname" );
	
	if( things.size > 0 )
		array_thread( things, func, var1, var2, var3, var4, var5, var6, var7, var8, var9 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

trig_stairs_setup()
{
	level endon( "turn_off_stairs_trigs" );
	
	// get stairs trigs
	trigs = GetEntArray( "trig_stairs", "script_noteworthy" );
	
	// thread stairs loops
	array_thread( trigs, ::trig_stairs_proc );
}

trig_stairs_proc()
{
	level endon( "turn_off_stairs_trigs" );
	
	// init vars
	allow_cqb = undefined;
	if( IsDefined( self.script_parameters ) && self.script_parameters == "allow_cqb" )
		allow_cqb = true;
	
	while( 1 )
	{
		self waittill( "trigger", dude );
		
		if( !IsDefined( dude.inStairsTrig ) )
			dude thread ai_stairs_proc( self, allow_cqb );
	}
}

ai_stairs_proc( trig, allow_cqb )
{
	self endon( "death" );
	
	// init vars
	self.inStairsTrig = true;
	
	// process trigger enter
	if( IsPlayer( self ) )
		thread blend_movespeedscale( 0.6 );
	else
	{
		// handle cqb
		if( !IsDefined( allow_cqb ) && IsDefined( self.cqbwalking ) )
		{
			self.wasCQB = true;
			self thread disable_cqbwalk();
		}
		
		// speed up move
		self.old_move_rate = self.moveplaybackrate;
		self set_moveplaybackrate( 1.25, 0.25 );
	}
	
	// wait till out of trigger
	while( self IsTouching( trig ) )
	{
		if( IsPlayer( self ) && !IsDefined( self.stairs_low_speed ) )
		{
			ally = getClosest( self.origin, level._allies, 128 );
			if( IsDefined( ally ) && within_fov( level.player.origin, level.player.angles, ally.origin, 0) )
			{
				self.stairs_low_speed = true;
				self thread blend_movespeedscale( 0.5 );
			}
		}
		
		wait( 0.05 );
	}
	
	// process trigger exit
	if( IsPlayer( self ) )
	{
		if( IsDefined( self.stairs_low_speed ) )
			thread blend_movespeedscale_default( 0.4 );
		else
			thread blend_movespeedscale_default( 0.25 );
	}
	else
	{
		// handle cqb
		if( IsDefined( self.wasCQB ) )
		{
			self.wasCQB = undefined;
			self thread enable_cqbwalk();
		}
		
		// slow down move
		self set_moveplaybackrate( self.old_move_rate, 0.25 );
	}
	
	// cleanup vars
	self.inStairsTrig = undefined;
	self.stairs_low_speed = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_trigger_ent_targetname( tTrig, guys, func, var1 )
{
	trigger = GetEnt( tTrig, "targetname" );	
	Assert( IsDefined( trigger ));
	
	trigger waittill_trigger_ent( guys, func, var1 );	
}

// Waits until an array of entities have passed a trigger (thread this bad boy to just run a func on each ent)
waittill_trigger_ent( guys, func, var1 )
{	
	ents_array = [];
//	target = undefined;
	
	// If array, load right in.  If single ent, add to array.
	Assert( IsDefined( guys ));
	if( IsArray( guys ))
		ents_array = guys;
	else
		ents_array[ 0 ] = guys;		
	
	Assert( ents_array.size > 0 );
	
	// If trigger is targeting something, get it
//	if( IsDefined( self.target ))
//		target = GetEntAny( self.target );
	
	trigger_count = 0;	
	remaining_ents = ents_array;
	
	while( 1 )
	{
		self waittill( "trigger", ent );

		foreach( guy in remaining_ents )
		{
			if( guy == ent )
			{
				trigger_count++;
				remaining_ents = array_remove( remaining_ents, guy );
				if( IsDefined( func ))
				{
					if( IsDefined( var1 ))
						ent thread [[func]]( var1 );
					else
						ent thread [[func]]();
				}
						
				break;
			}
		}
		
		if( trigger_count == ents_array.size )
			break;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

GetEntAny( str, key_name  )
{
	Assert( IsDefined( str ));
	
	key = "targetname";
	
	if( IsDefined( key_name ))
		key = key_name;
	
	obj = undefined;
	
	// Try ents
	obj = GetEntArray( str, key );
	
	if( obj.size == 0 )
	{
		// Try structs
		obj = GetStructArray( str, key );
	}
	else
	{
		if( obj.size == 1 )
			return obj[ 0 ];
		else
			return obj;
	}
	
	if( obj.size == 0)
	{
		// Try nodes
		obj = GetNodeArray( str, key );
	}
	else
	{
		if( obj.size == 1 )
			return obj[ 0 ];
		else
			return obj;
	}
	
	if( obj.size == 0)
	{
		// Try vehicle nodes
		obj = GetVehicleNodeArray( str, key );
	}
	else
	{
		if( obj.size == 1 )
			return obj[ 0 ];
		else
			return obj;
	}
	
	if( obj.size == 0 )
	{
		AssertMsg( "Cannot GetEntAny on thing with '" + key + "' '" + str + "'" );
	}
	else
	{
		if( obj.size == 1 )
			return obj[ 0 ];
		else
			return obj;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Set up a model to be a "door" (with model or brushmodel)
setup_door( tDoor, animname, hinge_tag )
{
	door = undefined;
	
	if( IsString( tDoor ))
		door = GetEnt( tDoor, "targetname" );
	else
		door = tDoor;
	
	Assert( IsDefined( door ));

	if( ( door.classname != "script_model" ) && ( door.classname != "script_brushmodel" ))
	         AssertMsg( "Door needs to be script_model linked to origin and collision brush. It is currently: " + door.classname );
		
	brush = undefined;
	
	if( IsDefined( door.target ))
	{
		parts = GetEntArray( door.target, "targetname" );
	
		foreach( part in parts )
		{
			if( part.classname == "script_brushmodel" )
			{
				brush = part;
			}
			else if( part.classname == "script_origin" )
			{										
				if( !IsDefined( hinge_tag ))
				{
					// If a hinge is not defined, but an origin is linked, use script_origin as main door
					door.hinge = part;	
					door.hinge.tag_name = hinge_tag;					
					door Linkto( door.hinge );			
				}
			}
		}		
	}	
	
	// Create hinge if tag defined
	if( IsDefined( hinge_tag ))
	{		
		AssertEx( IsDefined( door GetTagOrigin( hinge_tag )), "Hinge tag '" + hinge_tag + "' does not exist for '" + door.model + "'" );
		
		door.hinge = spawn_tag_origin();
		door.hinge.origin = door GetTagOrigin( hinge_tag );
		door.hinge.angles = door GetTagAngles( hinge_tag );
				
		// Door will be used in anim.  Keep unlinked so door can be put into anim properly
		if( !IsDefined( animname ))
			door LinkTo( door.hinge );
	}
	
	// Setup collision	
	if( IsDefined( brush ))
	{
		door.col_brush = brush;
		
		if( IsDefined( hinge_tag ))		
		{
			// Use a tag			
			door.col_brush LinkTo( door, hinge_tag );
		}
		else
		{
			// Use the origin
			door.col_brush LinkTo( door );
		}
	}
	else if( door.classname == "script_brushmodel" )
	{
		// No collision brush, main door is brush
		door.col_brush = door;
	}
	
	// Remember original angles
	door.original_angles = door.angles;
	
	// Apply animname
	if( IsDefined( animname ))
		door assign_animtree( animname );
	
	return door;
}

rebuild_door( door )
{
	Assert( IsDefined( door ));
	Assert( IsDefined( door.animname ));
	
	origin = door.origin;
	angles = door.angles;
	anim_name = door.animname;
	original_angles = door.original_angles;
	
	targetname = undefined;
	target = undefined;
	hinge_tag = undefined;
	
	// Get data from door
	if( IsDefined( door.targetname ))
		targetname = door.targetname;
	
	if( IsDefined( door.target ))
		target = door.target;
	
	if( IsDefined( door.hinge ))
		hinge_tag = door.hinge.tag_name;
	
	// Remove the door
	door delete();
	
	// Rebuild the door
	door = spawn_anim_model( anim_name, origin );
	door.angles = angles;	
	door.target = target;
	door = setup_door( door, anim_name, hinge_tag );	
	door.original_angles = original_angles;
	
	return door;
}

// Swinging doors
close_door( yaw_angle, time, paths_time )
{	
	door = self;
	
	// Animations were played on door previously, disable animtree so rotation functions can run
	if( IsDefined( self._lastAnimTime ))
	{
		self._lastAnimTime = undefined;
		self StopUseAnimTree();
	}
	
	hinge = undefined;
	
	if( IsDefined( door.hinge ))
	{
		// A separate object is defined as the hinge, make sure door is linked to hinge
		if( !door IsLinked())
			door LinkTo( door.hinge );
		hinge = door.hinge;
	}
	else
	{
		// We are rotating the door on it's origin
		hinge = door;
	}
	
	if( IsDefined( yaw_angle ))
		hinge RotateYaw( yaw_angle, time );
	else
		hinge RotateTo( door.original_angles, time );
	
	// If a paths_time is defined, wait that much before connecting paths, otherwise wait until door completely moved
	if( IsDefined( paths_time ))
		wait( paths_time );
	else
		wait( time );
	
	if( IsDefined( door.col_brush ))
		door.col_brush DisconnectPaths();
}

open_door( yaw_angle, time, paths_time )
{
	door = self;
	
	// Animations were played on door previously, disable animtree so rotation functions can run
	if( IsDefined( self._lastAnimTime ))
	{
		self._lastAnimTime = undefined;
		self StopUseAnimTree();
	}
	
	hinge = undefined;
	
	if( IsDefined( door.hinge ))
	{
		// A separate object is defined as the hinge, make sure door is linked to hinge
		if( !door IsLinked())
			door LinkTo( door.hinge );
		hinge = door.hinge;
	}
	else
	{
		// We are rotating the door on it's origin
		hinge = door;
	}
	
	open_angle = undefined;
	bounce_back_angle = undefined;
	
	// setup door for bounce back
	if( IsArray( yaw_angle ) )
	{
		open_angle		  = yaw_angle[ 0 ];
		bounce_back_angle = yaw_angle[ 1 ];
	}
	else
	{
		open_angle = yaw_angle;
	}
	
	// open door
	hinge RotateYaw( open_angle, time );
	
	// If a paths_time is defined, wait that much before connecting paths, otherwise wait until door completely moved
	if( IsDefined( paths_time ))
		wait( paths_time );
	else
		wait( time );
	
	if ( IsDefined( door.col_brush ) )
		door.col_brush ConnectPaths();
	
	if ( IsDefined( paths_time ) && paths_time < time )
		wait( time - paths_time );
	
	// bounce back
	wait( 0.05 );
	if( IsDefined( bounce_back_angle ) )
		hinge RotateYaw( bounce_back_angle, 2.5, 0.05, 2.45 );
}

// Gates
close_gate( position, time, paths_time )
{		
	self MoveTo( position, time );
	
	// If a paths_time is defined, wait that much before connecting paths, otherwise wait until door completely moved
	if( IsDefined( paths_time ))
		wait( paths_time );
	else
		wait( time );
	
	self.col_brush DisconnectPaths();
}

open_gate( position, time, paths_time )
{		
	self MoveTo( position, time );
	
	// If a paths_time is defined, wait that much before connecting paths, otherwise wait until door completely moved
	if( IsDefined( paths_time ))
		wait( paths_time );
	else
		wait( time );
	
	self.col_brush ConnectPaths();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vision_hit_transition( vision1, vision2, time_in, hold_time, time_out )
{
	
	thread vision_set_fog_changes( vision1, time_in );
	
	wait( time_in  );
	IPrintLn( "start hold" );
			 
	wait( hold_time );
	IPrintLn( "end hold" );
	thread vision_set_fog_changes( vision2, time_out );
	
	wait( time_out );
	
}

// Waits for flag, then sets vision sets on/off (and runs optional funcs)
vision_watcher( flag, vision_on, time_on, vision_off, time_off, function_start, function_end, end_notify )
{
	AssertEX( IsDefined( flag ), "Vision set flag not defined" );	
	AssertEX( IsDefined( vision_on ), "Vision set on not defined" );
	AssertEX( IsDefined( time_on ), "Vision set time on not defined" );
	AssertEX( IsDefined( vision_off ), "Vision set off not defined" );
	AssertEX( IsDefined( time_off ), "Vision set time off not defined" );
	
	if( !IsDefined( level.flag[ flag ] ))
		flag_init( flag );
	
	if( !IsDefined( level._vision_sets_active ))
		level._vision_sets_active = 0;
	
	thread vision_watcher_thread( flag, vision_on, time_on, vision_off, time_off, function_start, function_end, end_notify );
}

vision_watcher_thread( flag, vision_on, time_on, vision_off, time_off, function_start, function_end, end_notify )
{
	if( IsDefined( end_notify ))
		level endon( end_notify );
			
	active = false;
	
 	while( 1 )
	{
		if( flag( flag ) && !active )
		{
			// Vision on
			vision_set_fog_changes( vision_on, time_on );
			//IPrintLn( "new vision =" + vision_on );
			
			if( IsDefined( function_start ))
				thread [[ function_start ]]();
			
			active = true;
			level._vision_sets_active++;
		}
		else if( !flag( flag ) && active )
		{
			// Vision off
			
			// If player is not touching two vision set areas, set back to default vision
			if( level._vision_sets_active == 1 )
			{
				vision_set_fog_changes( vision_off, time_off );
				//IPrintLn( "new vision =" + vision_off );
			}
			
			if( IsDefined( function_end ))
				thread [[ function_end ]]();
			
			active = false;
			level._vision_sets_active--;
		}
		
		wait( 0.05 );
	}	
}

flag_watcher( flag, function_start, function_end, end_notify )
{
	if( IsDefined( end_notify ))
		level endon( end_notify );
	
	if( !flag_exist( flag ))
		flag_init( flag );
			
	active = false;
	
 	while( 1 )
	{
		if( flag( flag ) && !active )
		{
			if( IsDefined( function_start ))
				thread [[ function_start ]]();
			
			active = true;
		}
		else if( !flag( flag ) && active )
		{
			if( IsDefined( function_end ))
				thread [[ function_end ]]();
			
			active = false;
		}
		
		wait( 0.05 );
	}	
}
	
//*******************************************************************
//                                                                  *
//     Realistic Ammo Reload Test                                   *
//*******************************************************************

real_reload()
{
	self endon( "death" );
	
	while( 1 )
	{
		self waittill( "reload_start" );
		myWeap = self GetCurrentWeapon();
		myAmmo = self GetCurrentWeaponClipAmmo();
		
		self thread real_reload_proc( myWeap, myAmmo );
	}
}

real_reload_proc( myWeap, myAmmo )
{
	self endon( "death" );
	self endon( "weapon_fire" );
	self endon( "weapon_change" );
	self endon( "weapon_dropped" );
	
	self waittill( "reload" );
	
	if( myWeap == self GetCurrentWeapon() && myAmmo != self GetCurrentWeaponClipAmmo() )
	{
		myStock = self GetWeaponAmmoStock( myWeap );
		self SetWeaponAmmoStock( myWeap, myStock - myAmmo );
	}
}
//*******************************************************************
//                                                                  *
//     Light Scripts                                   				*
//*******************************************************************
black_ice_geyser_pulse()
{
	mylights = GetEntArray("firegeyser_flicker","targetname");
	for(i=0 ; i<mylights.size; i++)
	{
		if(is_gen4())
		{mylights[i] thread flicker(0.3,1.0,"notify_stop_flicker");}
		else{mylights[i] thread flicker();}
	}	
}
black_ice_geyser2_pulse()
{
	mylights = GetEntArray("blackice_flicker2","script_noteworthy");
	for(i=0 ; i<mylights.size; i++)
	{
		if(is_gen4())
		{mylights[i] thread flicker(0.3,1.0,"notify_stop_flicker");}
		else{mylights[i] thread flicker();}
	}	
}

//mag is from 0.0 to 1.0.  zero is little to no flicker, 1.0 is max flicker.
//pulse_length is the frequency of flickering.  1.0 is the baseline for how this script was written.  lower pulse_length = faster flicker
flicker( mag, pulse_length, kill_notify,fullIntensity )
{
	
	if( !IsDefined( mag ))
		mag = 0.2;
	
	if( mag > 0.999 ) 
		mag = 0.999;
	
	if( !IsDefined( pulse_length ))
		pulse_length = 1.0;
	
	self endon( "notify_stop_flicker" );
	//jitter light
	if(is_gen4())
	{self thread jitterMove(10 , 0.2, 0.1);}
	else
	{self thread jitterMove(3.5 , 0.2, 0.1);}
	//note: base_waittime must be the same size array as base_magchange
	base_waittime = [ 0.10, 0.05, 0.10, 0.05, 0.25, 0.05, 0.075, 0.05, 0.15, 0.075 ];
	base_magchage = [ 0.00, 0.25, 0.50, 0.40, 0.05, 0.45, 1.000, 0.25, 0.02, 0.750 ];
	
	if(!IsDefined(fullIntensity))
		fullIntensity = self GetLightIntensity();
	i = 0;
	while( 1 )
	{
		self SetLightIntensity(fullIntensity*(1-(mag * base_magchage[i])));//0.0
		wait base_waittime[ i ] * pulse_length;
		i += 1;
		if ( i == base_waittime.size )
			i = 0;
	}
}
//disp is max displacement timeTrans is Max time translation
jitterMove(disp,timeTrans,minTimeTrans)
{
	if(!IsDefined(disp))
		disp = 2.0;
	minDisp = 1.0;
	if(!IsDefined(timeTrans))
		timeTrans = 0.25;
	if(!IsDefined(minTimeTrans))
		minTimeTrans = 0.1;
	startOrigin = self.origin;
	while(1)
	{	
		newpos = startOrigin+randomvectorrange(minDisp,disp);
		newtimetrans = 	RandomFloatRange(minTimeTrans,timeTrans);	
		self moveTo(newpos,newtimetrans);
		wait newtimetrans;
		self moveTo(startOrigin,0.1);
		wait 0.1;		
	}
	
}
rotateLights(rotatorName, lightName, rotDirection)
{
	lights = GetEntArray(lightName,"targetname");
	rotator = GetEnt(rotatorName,"targetname");
	rotator thread rotateMe(-360,rotDirection);
	foreach(light in lights)
	{light thread manual_linkto(rotator,(light.origin - rotator.origin));}
}
//rotate horizontal and vertical light rotators script origins
rotateMe(degreespersecond, direction)
{
	while(1)
	{
		switch(direction)
		{
			case "yaw":
				self RotateYaw(degreespersecond,1);
				wait 1;
				break;
			case "pitch":
				self RotatePitch(degreespersecond,1);
				wait 1;
				break;
			case "roll":
				self RotateRoll(degreespersecond,1);
				wait 1;
				break;
			default:
				wait 1;
				break;	
		}
	}
}
god_rays_from_world_location ( source_origin, start_flag, end_flag, start_vision_set, end_vision_set )
{
	if ( is_gen4() )
	{
		// CHAD TESTS FOR PC GOD RAYS from STATIC LOCATION!!!!!
		if ( IsDefined ( start_flag ) )
			flag_wait ( start_flag );
		
		//IPrintLnBold ("starting world location god rays");
		ent1=0;
		ent2=0;
		if ( IsDefined ( start_vision_set ) )
			maps\_utility::vision_set_fog_changes( start_vision_set, 5 );
		ent = maps\_utility::create_sunflare_setting( "default" );
		while (1)
		{
			//get cylindrical coordinate angles
			ent1 = ATan ( (level.player.origin[2] - source_origin[2])/sqrt( squared((level.player.origin[0] - source_origin[0]))+(squared( (level.player.origin[1] - source_origin[1]) ) ) ) );
			if (level.player.origin[0] < source_origin[0])
			{
				ent2 = ATan ((level.player.origin[1] - source_origin[1])/(level.player.origin[0] - source_origin[0]));
			}
			else
			{
				ent2 = (180+ATan ((level.player.origin[1] - source_origin[1])/(level.player.origin[0] - source_origin[0])));
			}
				
			//set new sunflare angles
			ent.position = (ent1, ent2, 0);
			maps\_art::sunflare_changes( "default", 0 );
			wait 0.05;
			if ( IsDefined ( end_flag ) )
			{
				if (flag ( end_flag ))
			    break;
			}
		}
		//IPrintLnBold ("stopping world location god rays");
		if ( IsDefined ( end_vision_set ) )
		{
			maps\_utility::vision_set_fog_changes( end_vision_set, 5 );
			wait 5;
			maps\_utility::vision_set_fog_changes( "", 1 );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

set_forceSuppression( bool )
{
	Assert( IsDefined( bool ));
	
	if( bool )
		self.forceSuppression = true;
	else
		self.forceSuppression = false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

push_player_impulse( dir, mag, time )
{
	
	current_time = time;
	dir *= mag;
	
	start_dir = dir;
	
	while ( current_time > 0.0 )
	{
		
		
		mag_factor = maps\black_ice_util::normalize_value( 0, time, current_time );
		
		dir = start_dir * mag_factor;
		
		level.player PushPlayerVector( dir );
		
		//push_mag = maps\black_ice_util::factor_value_min_max( push_mag_max, push_mag_min, push_factor );
		
		wait level.TIMESTEP;
		
		current_time -= level.TIMESTEP;
		
	}
	
	dir = ( 0, 0, 0 );
	
	level.player PushPlayerVector( dir );
	
}

player_view_shake_blender( target_time, current_stength, target_strength )
{
	time = target_time;
	while( time > 0)
	{
		strength_factor = maps\black_ice_util::normalize_value( 0, target_time, time );
		
		strength = maps\black_ice_util::factor_value_min_max( target_strength, current_stength, strength_factor );
		
		//IPrintLn("quake = " + strength );
		
		earthquake( strength, 0.2, level.player.origin, 100000.00 );
		
		wait( level.TIMESTEP );
		time -= level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debug_pos_3d( str )
{		
	self endon( "stop_print3d" );
	self endon( "death" );
		
	string_label = "(.)";
	
	if( IsDefined( str ))
		string_label = str;
	
	while( 1 )
	{
		print3d( self.origin, string_label, (1,1,1), 1, 0.5, 1 );
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ally_cqb_kill( index, distance, stop_after_number, player_looking )
{			
	level endon( "stop_ally_cqb_kill" );
	
	AssertEX( Isdefined( level._enemies[ index ] ), index + " does not exist in level._enemies" );
		
	self enable_cqbwalk();
	
	while( level._enemies[ index ].size == 0 )
		wait( 0.05 );	                      
	                      
	// Default distance to kill
	dist = 192;
	
	enemies = remove_dead_from_array( level._enemies[ index ] );

	if( enemies.size == 0 )
		return;
	
	enemies = SortByDistance( enemies, self.origin );
	
	// custom distance to kill applied
	if( IsDefined( distance ))
		dist = distance;	
	
	if( !IsDefined( stop_after_number ))	
		stop_after_number = enemies.size;
	
	if( stop_after_number > enemies.size )	
		stop_after_number = enemies.size;
	
	// Kill 'em all!
	for( i = 0; i < stop_after_number; i++ )
	{			
		self ally_cqb_kill_solo( enemies[ i ], dist, player_looking );
		wait( 0.05 );
	}		
}

ally_cqb_kill_solo( guy, dist, player_looking )
{
	guy endon( "death" );
	guy endon( "kill" );
	
	while( IsAlive( guy ))
	{
		can_shoot = false;
		aim_spot = undefined;
		
		aim_spot = spawn_tag_origin();
		aim_spot.origin = guy GetTagOrigin( "j_head" );
		aim_spot LinkTo( guy );
		
		if( self animscripts\utility::CanSeeAndShootPoint( aim_spot.origin ))
		{
		   	can_shoot = true;		   	
			self cqb_aim( aim_spot );
			wait( 0.5 );			
		}
		
		if( IsDefined( player_looking ) && player_looking )
		{
			// Wait until player is looking
			while( !level.player player_looking_at( guy.origin ))
				wait( 0.05 );
		}	
			
		current_dist_sq = DistanceSquared( self.origin, guy.origin );				
		
		// If within acceptable distance, perform the kill
		if( current_dist_sq <= (dist * dist ))
		{
			if( can_shoot )
			{
				self Shoot( 1000, aim_spot.origin );
				guy vignette_kill();
				break;		  		
			}
		}
		
		wait( 0.05 );
		
		aim_spot delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cover_left_idle( nTargetname )
{				
	Assert( Isdefined( self.animname ));	
	
	idle_node = self;
			
	if( IsDefined( nTargetname ))
	{
		node = GetNode( nTargetname, "targetname" );
		idle_node = spawn_tag_origin();
		idle_node.origin = node.origin;
		idle_node.angles = VectorToAngles( AnglesToRight( node.angles ));
		self thread idle_cleanup( idle_node );
	}
	
	idle_node thread anim_loop_solo( self, "cover_left_idle" );
}

idle_cleanup( node )
{
	self waittill( "stop_loop" );
	node notify( "stop_loop" );
	node delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_trigger_activate_looking_at( obj, dot )
{
	self endon( "trigger" );	
	
	Assert( IsDefined( obj ));
	
	self thread trigger_delete();
	
	while( 1 )
	{
		if( level.player player_looking_at( obj.origin, dot, true ) )
			self trigger_on();
		else
			self trigger_off();
		wait( 0.05 );
	}
}

trigger_delete()
{
	self waittill( "trigger" );
	self delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_tag_anim_rig( model_name, animname, end_chars, save_models )
{
	if ( !IsDefined( end_chars ) )
	{
		end_chars = 3;
	}
	
	rig = GetEnt( model_name, "script_noteworthy" );
		
	rig.anim_node = spawn_tag_origin();
	rig.anim_node.origin = rig.origin;
	rig.anim_node.angles = rig.angles;
	
	rig assign_animtree( animname );
	model_name = rig.model;
	
    num_tags = GetNumParts( model_name );
    for( i = 0; i < num_tags; i++ )
    {
        tag_name = GetPartName( model_name, i );

        if( GetSubStr( tag_name, 0, 4 ) == "mdl_" )
        {
            // the tag should be named mdl_<xmodel name>_xxx where xxx is a number reference like 001
            part_name = GetSubStr( tag_name, 4, tag_name.size - end_chars );
            mdl = Spawn( "script_model", rig GetTagOrigin( tag_name ) );
            mdl SetModel( part_name );
            mdl.angles = rig GetTagAngles( tag_name );
            mdl LinkTo( rig, tag_name );
            
            if ( IsDefined( save_models ) && save_models )
            {
            	// tagBR< note >: Certain models we want to have collision
            	mdl.coll = "coll_" + GetSubStr( tag_name, 4, tag_name.size );
            	        	
            	level.tag_anim_rig_models[ level.tag_anim_rig_models.size ] = mdl;
            }
        }
    }
    
    return rig;
}

tag_anim_rig_init_and_flag_wait( flag_name, anime )
{
	if( !flag_exist( flag_name ))
		flag_init( flag_name );
	
	self.anim_node anim_first_frame_solo( self, anime );
	
	flag_wait( flag_name );	
	
	self.anim_node anim_single_solo( self, anime );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_trigger( end_notify )
{
	self waittill( "trigger" );
	level notify( end_notify );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start_point_is_after( str, bool_include_str )
{
	str_index = undefined;
	sp_index = undefined;
	
	str = ToLower( str );
	
	start_points = GetArrayKeys( level.start_arrays );
	
	for( i = 0; i < start_points.size; i++ )
	{
		// Find indices for actual start point and referenced start point
		if( start_points[ i ] == str )
			str_index = i;
		if( start_points[ i ] == level.start_point )
			sp_index = i;
	}
	
	Assert( IsDefined( str_index ));
	Assert( IsDefined( sp_index ));
	
	if( Isdefined( bool_include_str ) && bool_include_str )
	{
		// Include the start point referenced
		if( sp_index >= str_index )
			return true;
	}
	else if( sp_index > str_index )
	{
		// Do not include the start point referenced
		return true;
	}
	
	return false;
}

start_point_is_before( str, bool_include_str )
{
	str_index = undefined;
	sp_index = undefined;
	
	str = ToLower( str );
	
	start_points = GetArrayKeys( level.start_arrays );
	
	for( i = 0; i < start_points.size; i++ )
	{
		// Find indices for actual start point and referenced start point
		if( start_points[ i ] == str )
			str_index = i;
		if( start_points[ i ] == level.start_point )
			sp_index = i;
	}

	Assert( IsDefined( str_index ));
	Assert( IsDefined( sp_index ));
	
	if( Isdefined( bool_include_str ) && bool_include_str )
	{
		// Include the start point referenced
		if( sp_index <= str_index )
			return true;
	}
	else if( sp_index < str_index )
	{
		// Do not include the start point referenced
		return true;
	}
	
	return false;
}

/*
=============
///ScriptDocBegin
"Name: setup_player_for_animated_sequence( <do_player_link>, <link_clamp_angle>, <rig_origin>, <rig_angles>, <do_player_restrictions>, <do_player_restrictions_by_notify> )"
"Summary: Automate the process of spawning a rig, mover, linking player for an animated sequence."
"Module: Player"
"OptionalArg: <do_player_link>: defaults to true"
"OptionalArg: <link_clamp_angle>: defaults to 60"
"OptionalArg: <rig_origin>: defaults to player's origin"
"OptionalArg: <rig_angles>: defaults to player's angles"
"OptionalArg: <do_player_restrictions>: defaults to true"
"OptionalArg: <do_player_restrictions_by_notify>: defaults to false"
"Example: maps\black_ice_util::setup_player_for_animated_sequence()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
setup_player_for_animated_sequence( do_player_link, link_clamp_angle, rig_origin, rig_angles, do_player_restrictions, do_player_restrictions_by_notify, mover_model )
{
	// Setup default variables
	if ( !IsDefined( do_player_link) )
	{
		do_player_link = true;
	}
	
	if ( do_player_link )
	{
		if ( !IsDefined( link_clamp_angle ) )
		{
			link_clamp_angle = 60;
		}
	}
	
	if ( !IsDefined( rig_origin ) )
	{
		rig_origin = level.player.origin;
	}
		
	if ( !IsDefined( rig_angles ) )
	{
		rig_angles = level.player.angles;
	}
	
	if ( !IsDefined( do_player_restrictions ) )
	{
		do_player_restrictions = true;
	}
	
	// Setup player rig for anims
	player_rig = spawn_anim_model( "player_rig", rig_origin );
	level.player_rig = player_rig;
	player_rig.angles = rig_angles;
	//player_rig hide();
	
	player_rig.animname = "player_rig";
	
	if ( IsDefined( mover_model ) )
	{
		player_mover = spawn_anim_model( mover_model );
	}
	else
	{
		player_mover = spawn_tag_origin();
	}
	
	level.player_mover = player_mover;
	player_mover.origin = rig_origin;
	player_mover.angles = rig_angles;
	player_rig LinkTo( player_mover );
	
	if ( do_player_link )
	{
		level.player PlayerLinkToDelta( player_rig, "tag_player", 1, link_clamp_angle, link_clamp_angle, link_clamp_angle, link_clamp_angle, true );
	}
	
	if ( do_player_restrictions )
	{
		thread player_animated_sequence_restrictions( do_player_restrictions_by_notify );
	}
}

/*
=============
///ScriptDocBegin
"Name: player_animated_sequence_restrictions( <do_player_restrictions_by_notify> )"
"Summary: All the restrictions necessary for the player to do an animated sequence."
"Module: Player"
"OptionalArg: <do_player_restrictions_by_notify>: defaults to false"
"Example: maps\black_ice_util::player_animated_sequence_restrictions()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
player_animated_sequence_restrictions( do_player_restrictions_by_notify )
{
	if( IsDefined( do_player_restrictions_by_notify ) && do_player_restrictions_by_notify )
		level.player waittill( "notify_player_animated_sequence_restrictions" );
	
	level.player.disableReload = true;
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player DisableWeaponSwitch();

	level.player AllowCrouch( false );
	level.player AllowJump( false );
	//level.player AllowLean( false );
	level.player AllowMelee( false );
	level.player AllowProne( false );
	level.player AllowSprint( false );
}

/*
=============
///ScriptDocBegin
"Name: player_animated_sequence_cleanup()"
"Summary: Re-enables all the previous restrictions after a player goes through an animated sequence."
"Module: Player"
"Example: maps\black_ice_util::player_animated_sequence_cleanup()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
player_animated_sequence_cleanup()
{
	if ( !IsDefined( level.player.early_weapon_enabled ) || !level.player.early_weapon_enabled )
	{
		level.player.early_weapon_enabled = undefined;
		
		level.player.disableReload = false;
		level.player EnableWeapons();
		level.player EnableOffhandWeapons();
		level.player EnableWeaponSwitch();
	}

	level.player AllowCrouch( true );
	level.player AllowJump( true );
	//level.player AllowLean( true );
	level.player AllowMelee( true );
	level.player AllowProne( true );
	level.player AllowSprint( true );
	
	level.player Unlink();
	
	if ( IsDefined( level.player_mover ) )
	{
		level.player_mover Delete();
	}
	
	if ( IsDefined( level.player_rig ) )
	{
		level.player_rig Delete();
	}
}

/*
=============
///ScriptDocBegin
"Name: get_rumble_ent_linked( parent, rumble )"
"Summary: a poached version of get_rumble_ent that works on a PlayerLinkWeaponViewToDelta player, since get_rumble_ent uese get_eye"
"Module: Player"
"Arg: parent: defaults to false"
"OptionalArg: rumble: defaults to "steady_rumble""
"Example: maps\black_ice_util::get_rumble_ent_linked( level.snake_cam_dummy )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_rumble_ent_linked( parent, rumble )
{
	if ( is_coop() )
		PrintLn( "^3Warning! Using get_rumble_ent will cause the same rumbles to apply to all of the coop players!" );

	player = get_player_from_self();
	if ( !IsDefined( rumble ) )
		rumble = "steady_rumble";
	ent = Spawn( "script_origin", parent.origin );
	ent.intensity = 1;
	ent thread update_rumble_intensity_linked( player, rumble, parent );
	return ent;
}


update_rumble_intensity_linked( player, rumble, parent )
{
	self endon( "death" );
	
	rumble_playing = false;
	
	for ( ;; )
	{
		// There is a code bug where if rumbles are played on the first frame, and then you quit and resume from the beginning-of-level save,
		// the rumble may not stop correctly.  To work around this, we don't play on the first frame.  GetTime() on the first frame will be
		// 300, which is (NUM_SETTLE_FRAMES + 1) * FRAME_MSEC
		
		if ( self.intensity > 0.0001 && GetTime() > 300 )
		{
			if ( !rumble_playing )
			{
				self PlayRumbleLoopOnEntity( rumble );
				rumble_playing = true;
			}
		}
		else
		{
			if ( rumble_playing )
			{
				self StopRumble( rumble );
				rumble_playing = false;
			}			
		}
				
		height = 1 - self.intensity;
		height *= 1000;
		self.origin = (parent.origin) + ( 0, 0, height );
		/#
		if( is_coop() )
			PrintLn( "^3Warning! Using get_rumble_ent will cause the same rumbles to apply to all of the coop players!" );
		#/
		wait( 0.05 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ally_catchup( min_distance, max_distance )
{
	self notify( "notify_ally_catchup_stop" );
	self endon( "notify_ally_catchup_stop" );	
	
	// Expecting ally to be within the range of min_dist and max_dist
	min_dist = 400;
	max_dist = 600;		
	
	if( IsDefined( min_distance ))
		min_dist = min_distance;
	
	if( IsDefined( max_distance ))
		max_dist = max_distance;
	
	nodes = GetAllNodes();
	
	// If really far away, warp them if player isn't looking
	while( Distance( self.origin, level.player.origin ) > min_dist )
	{
		if( !level.player player_looking_at( self.origin, 0.1, true ))
		{
			// Find a node to warp the enemy to:
			//		* Path node
			//		* Distance < maximum distance
			//		* Height of node is near height of player's origin
			//		* Player is not looking at
			foreach( node in nodes )
			{
				if(
				   IsSubStr( node.type, "Path" ) &&				   
				   Distance( node.origin, level.player.origin ) <= max_dist  && 
				   Distance( node.origin, level.player.origin ) >= min_dist  &&
				   abs( (node.origin[ 2 ] - level.player.origin[ 2 ]) < 10 ) &&
				   !level.player player_looking_at( node.origin, 0.1, true )
				)
				{
					// Near the player and player isn't looking, teleport!
					self ForceTeleport( node.origin, VectorToAngles( level.player.origin - node.origin ));
					break;
				}
			}
		}
		
		wait( 0.05 );
	}
}

