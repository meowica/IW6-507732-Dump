#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


// AI Section
//---------------------------------------------------------
move_to_node( nodes, forcemove, moveDelay )
{
	
	if( isdefined( moveDelay ) )
	{
		if( moveDelay == true ) 
			wait( randomfloatrange( .5, 1 ) );
		else
			wait( moveDelay );
	}
	
	if( isstring( nodes ) )
	{
		things = getnodearray( nodes, "targetname" );
		if( things.size == 1 )
		{
			nodes = undefined;
			nodes = things[0];
		}
		else
			nodes = things;
	}
	
	self notify( "ai_new_goal" );
	
	if( isArray( nodes ) )
	{
		foreach( node in nodes )
		{
			if( isdefined( self.script_noteworthy ) && isdefined( node.script_noteworthy ) )
			{
				if( self.script_noteworthy == node.script_noteworthy )
				{
					
					if( isdefined( node.target ) )
					{
						
						self endon( "ai_new_goal" );
						
						spot = getent_or_struct_or_node( node.target, "targetname" );
						
						oldgradius = undefined;
						if( isdefined( spot.radius ) )
						{
							oldgradius = self.goalradius;
							self.goalradius = spot.radius;
						}
						
						self disable_arrivals_and_exits( true );
						self thread reset_if_new_goal( oldgradius );
						self thread set_goal_any( spot );
						self waittill( "goal" );
						
						if( isdefined( spot.radius ) )
							self.goalradius = oldgradius;
						
						self disable_arrivals_and_exits( false );
					}
					
					if( self.script_noteworthy == "wounded_ai" && isdefined( self.wounded_ai ) )
						self thread set_wounded_ai_goal( node, forcemove );
					
					else
			   			self set_goal_node( node );
					
			   		break;
				}
			}
		}
	}
	else
	{
		node = nodes;
		
		if( isdefined( node.target ) )
		{
			spot = getent_or_struct_or_node( node.target, "targetname" );
			self thread set_goal_any( spot );
			self waittill( "goal" );
		}
		
		if( isdefined( self.script_noteworthy ) && isdefined( node.script_noteworthy ) )
		{
			if( self.script_noteworthy == node.script_noteworthy )
			{
				if( self.script_noteworthy == "wounded_ai" && isdefined( self.wounded_ai ) )
					self thread set_wounded_ai_goal( node, forcemove );
				else
					self set_goal_node( node );
			}
			else
				self set_goal_node( node );
		}
		else
			self set_goal_node( node );
	}
}

reset_if_new_goal( oldradius )
{
	self endon( "goal" );
	
	self waittill( "ai_new_goal" );
	if( Isdefined( oldradius ) )
		self.goalradius = oldradius;
	self disable_arrivals_and_exits( false );
}

move_to_node_heroes( node, amount )
{
	if( !isdefined( amount ) )
		amount = .4;
	
	timee = 0;
	array = array_randomize( level.heroes );
	foreach( ai in array )
	{
		ai delaythread( timee, ::move_to_node, node );
		timee = timee + amount;
	}		
}

set_goal_any( ent, delete, forcegoal, gradius )
{
	assertex( isdefined( ent ), "ent is not defined" );
	
	self endon( "death" );
	
	if( isstring( ent ) )
		ent = getent_or_struct_or_node( ent, "targetname" );
	
	if( isdefined( forcegoal ) )
	{
		if( isdefined( gradius ) )
		{
			self.oldgoalradius = self.goalradius;
			self.goalradius = 15;
		}
		self.ignoreall = true;
	}
	
	if( isdefined( ent.type ) ) // only nodes have types
		self thread set_goal_node( ent );
	
	else if( !isdefined( ent.classname ) ) //only ents have classnames
		self thread set_goal_pos( ent.origin );
	
	else if( ent.classname == "info_volume" )
		self thread old_set_goal_volume( undefined, ent );
	
	else if( ent.classname == "script_origin" )
		self setgoalentity( ent );
	
	else // assert if none of the above work								
		assertmsg( "ent is no type of goal" );
	
	if( isdefined( delete ) && delete != false )
	{
	 	self thread waittill_goal( true );
	 	return;
	}
	else if( isdefined( forcegoal ) )
	{
		self waittill_goal();
		if( isdefined( gradius ) )
			self.goalradius = self.oldgoalradius;
		self.ignoreall = false;
	}
}

old_set_goal_volume( guys, ent, name )
{
	
	if( !isdefined( ent ) )
	{
		assertex( isdefined( name ), "name is undefined" );
		ent = getent( name, "targetname" );
	}
	if( !isdefined( guys ) )
		guys = self;
	
	assertex( isdefined( ent ), "volume is undefined" );
	
	if( isarray( guys ) )
	{
		guys = array_removeDead_or_dying(guys);
		foreach( guy in guys )
			guy setgoalvolumeAuto( ent );
	}
	else if( isdefined( guys) && isalive( guys ) )
		guys setgoalvolumeAuto( ent );
}

guys_waittill_goals( guys )
{
	foreach( guy in guys )
		guy thread waittill_goal();
	
	while( 1 )
	{
		atgoal = 0;
		
		foreach( guy in guys ) 
		{
			if( isdefined( guy.atgoal ) && guy.atgoal == true )
				atgoal++;
		}
		
		if( atgoal == guys.size )
			break;
		wait( .05 );
	}
	
}

waittill_goal( delete )
{
	self endon( "death" );
	
	self.atgoal = false;
	self.oldgoalradius = self.goalradius;
	self.goalradius = 25;
	self waittill( "goal" );
	
	self.atgoal = true;
	if( isdefined( delete ) )
	{
		self delete();
		return;
	}
	
	self.goalradius = self.oldgoalradius;
	
}

waittill_death_and_respawn( spawner, goal, ender, minn, maxx )
{
	spawner endon( "stop_respawning" );
	if( isdefined( ender ) )
		level endon( ender );
	
	if( !isdefined( minn ) )
		minn = 3;
	if( !isdefined( maxx ) )
		maxx = 5;
	
	//assertex( minn > maxx );
	
	ai = undefined;
	if( isAI( self ) )
		ai = self;
	else
		spawner waittill( "spawned", ai );
	
	while( isdefined( ai ) )
	{	
		if( isdefined( goal ) )
			ai thread set_goal_any( goal );
		
		ai waittill( "death" );
	
		if( !isdefined( spawner ) )
			break;
		
		if( spawner.count == 0 )
			break;
		
		wait( randomfloatrange( minn, maxx ) );
	
		if( !isdefined( spawner ) )
			break;
		
		ai = spawner spawn_ai();
	}
}

waittill_trigger_and_kill( trig, low, high, deleteme )
{
	self endon( "death" );
	
	if( isstring( trig ) )
		trig = getent( trig, "targetname" );
	
	assertex( isdefined( trig ), "trigger is no defined" );
	
	trig waittill( "trigger" );
	
	wait( randomfloatrange( low, high ) );
	
	if( isdefined( deleteme ) )
		self delete();
	else
		self kill();
		
}

trigger_waittill_trigger( thing, timeout, notify_msg, trigent )
{
	
	if( isstring( thing ) )
		thing = getent_targetname_or_noteworthy( thing );
	

	assert( isdefined( thing ) );
	
	if( isdefined( timeout ) )
	{	
		msg = thing waittill_any_timeout( timeout, "trigger" );
		if( msg == "timeout" )
			thing notify( "trigger" );
		
	}
	else
	{
		if( isdefined( trigent ) )
		{
			while(1)
			{
				thing waittill( "trigger", ai );
				if( ai == trigent )
					break;
				
				wait(.05);
			}	
		}
		else
			thing waittill( "trigger" );
	}
		
	if( isdefined( notify_msg ) )
		level notify( notify_msg );
}

getent_targetname_or_noteworthy( name )
{
	thing = getent( name, "targetname" );
	if( !isdefined( thing ) )
		thing = getent( name, "script_noteworthy" );
	
	return thing;
}

// array = array of coordinates
get_closest_in_array( array, pos )
{
	index = get_closest_index_in_array( array, pos );
	return array[ index ];
}

get_closest_index_in_array( array, pos )
{
	dist = DistanceSquared( array[ 0 ], pos );
	index = 0;

	for ( i = 1; i < array.size; i++ )
	{
		new_dist = DistanceSquared( array[ i ], pos );
		if ( new_dist < dist )
		{
			dist = new_dist;
			closest = array[ i ];
			index = i;
		}
	}

	return index;
}

get_targeted_ents()
{
	array = [];
	array[ 0 ] = self;
	ent = self;

	while ( IsDefined( ent.target ) )
	{
		next_ent = ent get_target_ent();

		if ( !IsDefined( next_ent ) )
		{
			break;
		}

		array[ array.size ] = next_ent;
		ent = next_ent;
	}

	return array;
}

// TODO: Remove this and use get_targeted_ents()
get_target_chain_array( nextspot )
{
	assertex( isdefined( nextspot ), "nextspot is not defined" );
	
	array = [];
	array[ array.size ] = nextspot;
	
	while( isdefined( nextspot ) )
	{
		
		if( !isdefined( nextspot.target ) )
			break;
	
		nextspot = getent_or_struct_or_node( nextspot.target, "targetname" );
		
		if( !isdefined( nextspot ) )
			break;
		
		array[ array.size ] = nextspot;
		
		if( !isdefined( nextspot.target ) )
			break;
		
		wait(.05);
	}
	
	return array;
}

ignore_everything()
{
	self.ignoreall = true;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	//self.fixednode = false;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	
	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
}

clear_ignore_everything()
{
	self.ignoreall = false;
	self.grenadeawareness = 1;
	self.ignoreexplosionevents = false;
	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.fixednode = true;
	self.disableBulletWhizbyReaction = false;
	self enable_pain();
	
	if( IsDefined( self.og_newEnemyReactionDistSq ) )
	{
		self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
	}
}

set_all_ai_targetnames( spawner )
{
	if( !isdefined( spawner.targetname ) )
		return;
	self.targetname = spawner.targetname;
}

kill_over_time( ents, killer, time1, time2, safe )
{	
	
	if( !isarray( ents ) )
	{
		array = [];
		array[0] = ents;
		ents = array;
	}

	ents = remove_dead_from_array( ents );
	foreach( dude in ents )
		thread kill_over_time_single( dude, killer, time1, time2, safe );

}

kill_over_time_single( ent, killer, time1, time2, safe )
{
	ent endon( "death" );
	
	time = 3;
	
	if( !isdefined( time1 ) )
		time = randomfloat( time );
	else if( isdefined( time2 ) )
		time = randomfloatrange( time1, time2 );
	else
		time = randomfloatrange( time1 );
	
	while( isdefined( safe ) )
	{
		wait( time );
		if( player_can_see_ai( ent ) )
			continue;
		else
			safe = undefined;			
	}
	
	if( isdefined( killer ) )
		killer thread aim_and_kill( ent );
	else
		ent kill();
}

aim_and_kill( enemy )
{
	if( !isdefined( enemy ) || !isalive( enemy ) )
		return;
	
	self thread cqb_aim( enemy );
	start_pos = self gettagorigin( "tag_flash" );
	end_pos = enemy gettagorigin( "j_head" );
	
	enemy.health = 1;
	
	if( !isdefined( enemy ) || !isalive( enemy ) )
	{
		self thread cqb_aim( undefined );
		return;	
	}
	
	fireanim = undefined;
	rate = undefined;
	if( isdefined( self.a.array ) )
	{
		num = RandomInt( self.a.array[ "single" ].size );
		fireanim = self.a.array[ "single" ][ num ];
		rate = WeaponFireTime( self.weapon );
	}
	
	if( !isdefined( enemy ) || !isalive( enemy ) )
	{
		self thread cqb_aim( undefined );
		return;	
	}
	
	if( isdefined( fireanim ) )
	{
		self SetFlaggedAnimKnobRestart( "fire_notify", fireanim, 1, 0.2, rate );
		self waittill_any_timeout( 0.2, "fire_notify", "fire" );
	}
	
	MagicBullet( self.weapon, start_pos, end_pos );
	
	if( !isdefined( enemy ) || !isalive( enemy ) )
		enemy kill();
		
	self thread cqb_aim( undefined );
}

stealth_shot_accuracy( target )
{
	old = self.baseaccuracy;
	self.baseaccuracy = 9999;
	target waittill( "death" );
	self.baseaccuracy = old;
}

idle_and_react( spot, idle, react, goal )
{
	assert( isdefined( spot ) );
	
	self endon( "death" );
	self endon( "dying" );
	
	if( !isdefined( idle ) )
		idle = self.script_animation + "_idle";
	
	skipreact = false;
	if( !isdefined( react ) )
		react = self.script_animation + "_react";
	else if( react == "none" )
		skipreact = true;
	
	if( !isdefined( self.animname ) )
		spot thread anim_generic_loop( self, idle, "stop_anim" );
	else
		spot thread anim_loop_solo( self, idle, "stop_anim" );
	
	self thread waittill_dead_and_stop_anim( spot, react );
	type = self waittill_stealth_notify();
	
	spot notify( "stop_anim" );
	self StopAnimScripted();
	
	self set_ignoreme( false );
	self set_ignoreall( false );
	
	if( skipreact == false )
	{
		if( !isdefined( self.animname ) )
			spot anim_generic( self, react );
		else
			spot anim_single_solo( self, react );
	}
	
	if( isdefined( goal ) )
		self thread set_goal_any( goal );
}

waittill_dead_and_stop_anim( spot, aanim )
{
	assert( isdefined( spot ) );
	
	spot endon( aanim );
	
	self.allowpain = true;
	self.allowdeath = true;
	self.health = 10;
	self waittill_any( "death", "damage", "dying" );
	
	if( !isdefined( self ) )
		return;
	
	spot notify( "stop_anim" );
	self StopAnimScripted();
	
	if( isalive( self ) )
		self kill();
}

get_living_ai_waittill_dead_or_dying( name, type, amount, safe )
{
	array = undefined;
	
	if( isdefined( safe ) )
		array = get_living_ai_array_safe( name, type );
	else
		array = get_living_ai_array( name, type );
	if( !isdefined( array ) )
	{
		ai = get_living_ai( name, type );
		array = ai[0];
	}
	
	assert( isdefined( array ) );
	
	if( !isdefined( amount ) )
		amount = array.size;
	
	waittill_dead_or_dying( array, amount );
}

get_living_ai_array_safe( name, type )
{
	spawnerArray = getSpawner_array( name, type );
	
	wTime = undefined;
	lastD = 0;
	foreach( spawner in spawnerArray ) 
	{
		if( isdefined( spawner.script_delay ) )
		{
			if( spawner.script_delay > lastD )
				wTime = spawner.script_delay;
		}
	}
	
	if( isdefined( wTime ) )
		wait( wTime );
	
	return get_living_ai_array( name, type );
}

getSpawner_array( name, type ) 
{
	array = getentarray( name, type );
	sArray = [];
	foreach( thing in array )
	{
		if( isspawner( thing ) )
			sArray[ sArray.size ] = thing;
	}
	
	return sArray;
	
}

waittill_stealth_notify()
{
	self endon( "death" );
	level endon( "stealth_event_notify" );
	
    self addAIEventListener( "grenade danger" );
    self addAIEventListener( "projectile_impact" );
    self addAIEventListener( "silenced_shot" );
    self addAIEventListener( "bulletwhizby" );
    self addAIEventListener( "gunshot" );
	self addAIEventListener( "gunshot_teammate" );
	self addAIEventListener( "explode" );
    
    self waittill( "ai_event", eventtype );
    
    level notify( "stealth_event_notify", self );

}

waittill_stealth_notify_goloud()
{
	self endon( "death" );
	
	level waittill( "stealth_event_notify" );
	
	wait( randomfloatrange( .2, 1 ) );
	
	self notify( "stealth_event_notify" );
	
	self setgoalpos( level.player.origin );
	self enable_arrivals();
	self enable_exits();
	self.ignoreme = false;
	self.ignoreall = false;
	self.goalradius = 128;
	self.favoriteenemy = level.player;
	self set_baseaccuracy( 1000 );
	
	if( isdefined( self.flashlight_spot ) )
	{
		wait( randomfloatrange( .2, 4 ) );
		self notify( "remove_flashlight" );
	}
	
	if( isdefined( self.cqbEnabled ) )
		self disable_cqbwalk();
	else if( !isdefined( self.animname ) )
		self clear_generic_run_anim();
	else
		self clear_run_anim();
}

set_run_anim_custom( array, time1, time2 )
{
	self endon ( "stop_custom_anim_run" );
	if( !isdefined( time1 ) )
	{
		time1 = 15;
		time2 = 30;		
	}
	
	self.allowtwitches = true;
	base = array[0];
	twitches = [];
	foreach( index, thing in array )
	{
		if( index == 0 )
			continue;
		twitches[ twitches.size ] = thing;
	}
	
	self set_run_anim( base );
	while(1)
	{
		if( self.allowtwitches == false )
		{
			wait(.05);
			continue;
		}
		
		wait( randomintrange( time1, time2 ) );
		//if( randomint( 100 ) < 20 )
		//{
			aanim = twitches[ randomint( twitches.size ) ];
			self set_run_anim( aanim );
			iprintln( aanim );
			time = getanimlength( level.scr_anim[ self.animname ][ aanim ] );
			wait( time );
			self set_run_anim( base );
		//}
	}
}

set_start_locations( targetname )
{
	structs = getstructarray( targetname, "targetname" );

	foreach( struct in structs )
	{
		if( struct.script_noteworthy == "player" )
		{
			level.player SetOrigin( struct.origin );
			level.player SetPlayerAngles( struct.angles );
		}
		else
		{
			array_call( level.heroes, ::ForceTeleport, struct.origin, struct.angles );
		}
	}
}

disable_arrivals_and_exits( onoff )
{
	if( !isdefined( onoff ) )
		onoff = true;
	
	self.disablearrivals = onoff;
	self.disableexits = onoff;
}

attach_flashlight( type ) // Types : spotlight, cheap
{
	
	self endon( "death" );
	self endon( "remove_flashlight" );
	
	if( !isdefined( type ) )
		type = "";
	else
		type = "_" + type;
	
	self thread attach_flashlight_delete();
	
	while(1)
	{
		
		self.flashlight_spot = spawn_tag_origin();
		self.flashlight_spot linkto( self, "tag_flash", ( 0,0,0 ), ( 0,0,0 ) );
		PlayFXOnTag( level._effect[ "flashlight" + type ], self.flashlight_spot, "tag_origin" );
		
		self waittill( "flashlight_off" );
		
		//spot StopFXOnTag( level._effect[ "flashlight" + type ], spot, "tag_origin" );
		self.flashlight_spot delete();
		
		self waittill( "flashlight_on" );
	}
	
}

attach_flashlight_delete()
{
	self waittill_any( "remove_flashlight", "death" );
	
	if( isdefined( self.flashlight_spot ) )
		self.flashlight_spot delete();
}

anim_reach_and_anim( ai, animm )
{
	ai endon( "death" );
	ai endon( "cancel_anim" );
	
	if( isdefined( ai.animname ) )
	{
		self anim_reach_solo( ai, animm );
		self anim_single_solo( ai, animm );	
	}
	else
	{
		self anim_generic_reach( ai, animm );
		self anim_generic( ai, animm );		
	}
	ai notify( animm );
}

SetSlowMotion_func( start, end, time )
{
	setslowmotion( start, end, time );
}

waittill_flag_set( msg, flag )
{
	self endon( "death" );
	self waittill( msg );

	flag_set( flag );
}

too_close_to_allies( msg, dist, endon_flag )
{
	level endon( endon_flag );
	self endon( "death" );
	dist = Squared( dist );
	
	allies = array_add( level.heroes, level.player );
	
	while ( 1 )
	{
		foreach ( guy in allies )
		{
			if ( DistanceSquared( guy.origin, self.origin ) < dist )
			{
				self notify( msg );
				return;
			}
		}
		
		wait( 0.1 );
	}
}


#using_animtree( "vehicles" );
doors_open( ent, opentime, sound, amount, acelTime, decelTime )
{
	doors = undefined;
	if( isstring( ent ) )
		doors = getentarray( ent, "targetname" );
	else
		doors = ent;
	
	if( !isarray( doors ) )
	{
		single_door_open( doors, opentime, sound, amount, acelTime, decelTime );
		return;
	}
	
	if( !isdefined( opentime ) )
		opentime = 0.5;
	
	if( !isdefined( sound ) )
		sound = "double_door_wood_kick";
	
	if( !isdefined( acelTime ) )
		acelTime = 0;
	
	if( !isdefined( decelTime ) )
		decelTime = 0;
	
	if( !isdefined( amount ) )
		amount = 90;
	
	foreach( door in doors )
	{
		// how much to open the door
		if( isarray( amount ) )
			turnamount = randomfloatrange( amount[0], amount[1] );
		else
			turnamount = amount;
		
		// how long it takes to open the door
		if( isarray( opentime ) )
			realopentime = randomfloatrange( opentime[0], opentime[1] );
		else
			realopentime = opentime;
		
		if( door.script_noteworthy == "right" )
			turnamount = turnamount * -1;
//		else
//		{
//			if( amount < 0 )
//				amount = amount * -1;
//		}
		
		door rotateto( door.angles + ( 0, turnamount, 0 ), realopentime, acelTime, decelTime );
		door connectpaths();
		
		door thread door_waittill_rotatedone();
	}
	
	if( sound != "none" )
		doors[0] thread play_sound_in_space( sound, doors[0].origin );
	
	while( 1 )
	{
		done = 0;
		foreach( door in doors )
		{
			if( isdefined( door.rotatedone ) )
				done++;

		}
		if( done == 2 )
			break;

		wait(.05);
	}
	
	level notify( "double_doors_opened" );
}
single_door_open( door, opentime, sound, amount, acelTime, decelTime )
{
	if( isstring( door ) )
		door = getent( door, "targetname" );
	
	assert( isdefined( door ) );
	
	if( !isdefined( opentime ) )
		opentime = 0.5;
	
	if( !isdefined( sound ) )
		sound = "double_door_wood_kick";
	
	if( !isdefined( amount ) )
		amount = 90;
	
	if( isdefined( door.script_noteworthy ) && door.script_noteworthy == "right" )
		amount = amount * -1;
	
	if( !isdefined( acelTime ) )
		acelTime = 0;
	
	if( !isdefined( decelTime ) )
		decelTime = 0;
	
	door rotateto( door.angles + ( 0,amount,0 ), opentime, acelTime, decelTime  );
	door connectpaths();
	
	if( sound != "none" )
		door thread play_sound_in_space( sound );
	
}

door_waittill_rotatedone()
{
	self waittill( "rotatedone" );
	self.rotatedone = true;
}

func_waittill_msg( thing, msg, func, param1, param2 )
{
	thing endon( "death" );
	
//	if( !isdefined( self ) )
//		iprintlnbold( "hi" );
	
	thing waittill( msg );

	if( isdefined( param1 ) )
		thing thread [[ func ]]( param1 );
	else if( isdefined( param2 ) )
		param2 thread [[ func ]]( param1 );
	else
		thing thread [[ func ]]( );
}

link_two_entites( ent1, ent2, tag, originoffset, anglesoffset )
{	
	if( isdefined( tag ) )
		ent1 linkto( ent2, tag, originoffset, anglesoffset );
	else
		ent1 linkto( ent2 );
}

r_unlink( ent )
{
	ent unlink();
}

set_ai_name( name )
{
	self.orginalName = self.name;
	self.name = name;	
}

reset_ai_name()
{
	self.name = self.orginalName;
	self.orginalName = undefined;	
}

cinematicmode_on()
{
	level.player disableweapons();
	level.player AllowCrouch( false );
	level.player allowprone( false );
	level.player allowjump( false );
	level.player AllowSprint( false );
}

cinematicmode_off()
{
	level.player enableweapons();
	level.player AllowCrouch( true );
	level.player allowprone( true );
	level.player allowjump( true );
	level.player AllowSprint( true );	
}

Print3d_on_me( msg )
 { 
 /# 
	self endon( "death" );  
	self endon("go_to_new_volume");	
	self notify( "stop_print3d_on_ent" );  
	self endon( "stop_print3d_on_ent" );  
	while( 1 ) 
	{ 
		print3d( self.origin + ( 0, 0, 40 ), msg );  
		wait( 0.05 );  
	} 
 #/ 
}

set_goal_volume( volume, delay )
{
	self endon( "death" );
	
	if ( IsDefined( delay ) )
		wait( delay );
	
	self SetGoalVolumeAuto( volume );
}

enemy_volume_trigger_thread( struct, end_flag )
{
	volume = GetEnt( self.target, "targetname" );
	while ( !flag( end_flag ) )
	{
		self waittill( "trigger" );
		
		
		if ( struct.enemy_volume == volume )
		{
			wait( 0.5 );
			continue;
		}
		
		struct.enemy_volume = volume;
	}
}

force_shot_track( target, delay )
{
//	org = Spawn( "script_origin", target GetTagOrigin( "j_head" ) );
//	org LinkTo( target, "j_head" );
	
	was_ignoring = false;
	if ( self.ignoreall )
	{
		was_ignoring = true;
//		self.ignoreall = false;
	}
	
	self thread cqb_aim( target );
	
	if ( IsDefined( delay ) )
	{
		wait( delay );
	}
	
	num = RandomInt( self.a.array[ "single" ].size );
	fireanim = self.a.array[ "single" ][ num ];
	
	self SetFlaggedAnimKnobRestart( "fire_notify", fireanim, 1, 0.2, 1 );
	self waittillmatch( "fire_notify", "fire" );
	
	origin = target GetTagOrigin( "j_head" );
	self Shoot( 1, origin, true );
	
	if ( was_ignoring )
	{
		self.ignoreall = true;
	}

}

// MINI DRONE STUFF
//---------------------------------------------------------
minidrone_behavior( path_start )
{
	self.weapon = "mini_drone_9mm";
	
//	self maps\_chopperboss_utility::build_data_override( "min_target_dist2d" ,		128 );
// self maps\_chopperboss_utility::build_data_override( "max_target_dist2d" ,		1024 );
	if ( self.script_team == "allies" )
	{
//		self maps\_chopperboss_utility::build_data_override( "weapon_cooldown_time" ,	0.25 );
//		self maps\_chopperboss_utility::build_data_override( "windup_time" ,			0.25 );
	}
//	self maps\_chopperboss_utility::build_data_override( "face_target_timeout" ,	0.25 );
	
//	self maps\_chopperboss_utility::build_data_override( "heli_shoot_limit" ,		4 );
	
//	self maps\_chopperboss_utility::build_data_override( "get_targets_func", 	::mini_drone_get_targets );
//	self maps\_chopperboss_utility::build_data_override( "tracecheck_func", 	maps\_chopperboss_utility::chopper_boss_can_hit_from_tag_turret );
//	self maps\_chopperboss_utility::build_data_override( "fire_func" ,			maps\_chopperboss_utility::chopper_boss_fire_weapon );
//	self maps\_chopperboss_utility::build_data_override( "pre_move_func" ,		::mini_drone_pre_move_func );
	
	//self.owner = level.player;
	
	
//	self thread maps\_chopperboss::chopper_boss_think( path_start );
	
	if ( self.script_team == "allies" )
	{
		self godon();
		delayThread( 10.0, ::godoff );
	}
}

MINI_DRONE_IDEAL_PLAYER_DISTANCE = 512;

mini_drone_get_targets()
{
	targets = [];
	
	if ( self.script_team == "allies" )
	{
		guys = getaiarray( "axis" );
		foreach ( ai in guys )
		{
			if ( !IsDefined( ai.ignoreme ) || ai.ignoreme == false )
			{
				targets[ targets.size ] = ai;
			}
		}
		guys = getaiarray( "team3" );
		foreach ( ai in guys )
		{
			if ( !IsDefined( ai.ignoreme ) || ai.ignoreme == false )
			{
				targets[ targets.size ] = ai;
			}
		}
		
		if ( isdefined( self.owner ) && isPlayer( self.owner ) )
		{
			ideal_targets = [];
			ideal_targets_distance = [];
			foreach ( t in targets )
			{
				if ( Distance2d( self.owner.origin, t.origin ) < MINI_DRONE_IDEAL_PLAYER_DISTANCE )
				{
					ideal_targets_distance = array_add( ideal_targets_distance, t );
					if ( self.owner player_looking_at( t.origin ) )
						ideal_targets = array_add( ideal_targets, t );
				}
			}
			if ( ideal_targets.size > 0 )
				return ideal_targets;
			if ( ideal_targets_distance.size > 0 )
				return ideal_targets_distance;
		}
	}
	else
	{
		// Target players not down and not set to ignore
		foreach( player in level.players )
		{
			if 	( !is_player_down( player ) 
				&&	( !IsDefined( player.ignoreme ) || player.ignoreme == false )
				)
			{
				targets[ targets.size ] = player;
			}
		}
		
		// Add allies
		allies = getaiarray( "allies" );
		foreach ( ally in allies )
		{
			if ( !IsDefined( ally.ignoreme ) || ally.ignoreme == false )
			{
				targets[ targets.size ] = ally;
			}
		}
		
		// If no targets were found, shoot at downed players not set to ignore
		if ( !targets.size )
		{
			foreach( player in level.players )
			{
				if	(
						!is_player_down_and_out( player )
					&&	( !IsDefined( player.ignoreme ) || player.ignoreme == false )
					)
				{
					targets[ targets.size ] = player;
				}
			}
		}
	}
	return targets;
}

mini_drone_pre_move_func()
{
	if ( isdefined( self.heli_target ) )
	{
		self setlookatent( self.heli_target );
		self setTurretTargetEnt( self.heli_target );
	}
}

enable_creepwalk()
{
	self.creepwalk = true;
	
	walkanim = "creepwalk";
	twitch_weights = "creepwalk_weights";
	self set_run_anim_array( walkanim, twitch_weights );
	
	self disable_arrivals_and_exits( true );
	//self.a.pose = "stand";
	self.nododgemove = true;
	self.combatmode = "no_cover";
	self.dontmelee = true;
	self.noRunNGun = true;
	self.noRunReload = true;
	self.neverSprintForVariation = true;
	self disable_turnAnims();
}

disable_creepwalk()
{
	self.creepwalk = undefined;
	
	self disable_arrivals_and_exits( false );
	self clear_run_anim();
	
	//self.a.pose = "cover";
	self.nododgemove = false;
	self.combatmode = "cover";
	self.dontmelee = false;
	self.noRunNGun = false;
	self.noRunReload = false;
	self.neverSprintForVariation = false;
	self enable_turnAnims();
}



// Wounded Guy Section
//---------------------------------------------------------

//**** DIAZ COVER BEHAVIOR ****\\
/*
 * script_paramters ( set in any order )
 * 		crouch   : will use crouch animset
 * 		nocover  : will use stand nocover animset
 * 		noshoot  : will not play any shoot anims during idle ( if crouch or nocover will automatically not shoot )
 *  	skipexit : will skip exit anims
 *
 * 
 */

set_wounded_ai_goal( spot, forcemove )
{
	
	self notify( "wounded_ai_newgoal" );
	self endon( "wounded_ai_newgoal" );
	self endon( "disable_wounded_ai" );
	
	if( !isdefined( forcemove ) )
		while( ent_flag( "wounded_ai_playing_idle_twitch" ) )
			wait(.05);
	
	while( ent_flag( "wounded_ai_playing_exit" ) )
		wait(.05);	
	
	if( isdefined( self.oldspot ) )
	   self.oldspot notify( "stop_anim" );
	self.oldspot = spot;	
	
	spot.noshoot = false;
	spot.skipexit = false; 
	spot.exit90 = false;
	spot.exitf = false;
	
	spotSet = [];
	stance = "stand"; // default is stand
	if( isdefined( spot.script_parameters ) )
	{
		spotSet = StrTok( spot.script_parameters, " " );
	
		foreach( thing in spotSet )
		{
			if( thing == "crouch" || thing == "stand" || thing == "nocover" )
			{
				stance = thing;
				if( stance == "crouch" || stance == "nocover" )
					spot.noshoot = true;
				
				continue;
			}
			
			if( thing == "noshoot" )
				spot.noshoot = true;
			
			if( thing == "skipexit" )
				spot.skipexit = true;	
			
			if( thing == "90" )
				spot.exit90 = true;
			else if( thing == "eforward" )
				spot.exitf = true;
			
		}
	}
	
	assertex( isdefined( spot.type ), "wounded_ai goal must be a node" );
	
	spot.stancetype = undefined;
	thing = StrTok( spot.type, " " );
	spot.stancetype = tolower( thing[1] );
	if( spot.stancetype == "stand" )
	{
		spot.noshoot = true;
		stance = "nocover";
	}
	
//	if( isdefined( spotSet[0] ) && spotSet[0] != "undefined" )
//	{
//		stance = spotSet[0];
//		
//		if( stance == "crouch" )
//			spot.noshoot = true;
//	}
//
//	if( isdefined( spotSet[1] ) )
//		spot.noshoot = true;
//	
//	if( isdefined( spotSet[2] ) && spotSet[2] == "skip" )
//		spot.skipexit = true;
	
	animset = set_wounded_ai_cover_animset( stance );
	
	self.goalradius = 50;
	self setgoalpos( spot.origin );
	
	side = self get_wounded_ai_approach_side( spot );
	
	self ent_flag_clear( "wounded_ai_completed_approach_reach" );
	
	self thread set_wounded_ai_approach_behavior( spot, animset, side );
	
	self thread set_wounded_ai_cover_behavior( spot, animset );
	self thread set_wounded_ai_exit_behavior( spot, animset, forcemove );
}

set_wounded_ai_cover_behavior( spot, animset, forcemove )
{
	self endon( "wounded_ai_newgoal" );
	self endon( "disable_wounded_ai" );
	
	self waittill( "wounded_ai_approach_done" );
	
	set = [];
	if( isdefined( animset[ "idle" ][ "checkclip" ] ) )
		set[set.size] = animset[ "idle" ][ "checkclip" ];
	if( isdefined( animset[ "idle" ][ "pain" ] ) )
		set[set.size] = animset[ "idle" ][ "pain" ];
	
	if( spot.stancetype == "stand" )
	{
		set[set.size] = animset[ "look" ][ "none" ];
		spot.noshoot = true;
	}
	else
		set[set.size] = animset[ "look" ][ spot.stancetype ];
		
	if( self.allowshooting == true && ( spot.noshoot == false ) )
	{
		set[set.size] = animset[ "fire" ][ spot.stancetype ];
		set[set.size] = animset[ "fire1h" ][ spot.stancetype ];
	}		

	
	ender = "disable_wounded_ai";
	if( isdefined( forcemove ) )
		ender = "wounded_ai_newgoal";
	
	lastanim = "";
	while(1)
	{
		
		spot thread anim_loop_solo( self, animset[ "idle" ][ "idle" ], "stop_anim" );
		
		wait( randomintrange( 4, 8 ) );
		
		while(1)
		{
			animm = set[ randomint( set.size ) ];
			if( lastanim != animm )
				break;
			wait(.05);
		}
		
		spot notify( "stop_anim" );
		self stopanimscripted();		

		things = StrTok( animm, "_" );
		if( things[2] == "fire" )
			self thread shoot_alot( 5, 2.5, ender );
		else if( things[2] == "fire1h" )
			self thread shoot_alot( 2.5, 2.5, ender );
		
		self thread set_wounded_ai_player_twitch( spot, animm );
		self waittill( "wounded_ai_twitch_done" );
		
		lastanim = animm;
	}
	
}

set_wounded_ai_player_twitch( spot, animm, forcegoal )
{
	self endon( "disable_wounded_ai" );
	//if( isdefined( forcegoal ) )
	
	self ent_flag_set( "wounded_ai_playing_idle_twitch" );

	spot anim_single_solo( self, animm );

	self ent_flag_clear( "wounded_ai_playing_idle_twitch" );
	
	self notify( "wounded_ai_twitch_done" );
}

set_wounded_ai_approach_behavior( spot, animset, side )
{ 	
	self endon( "wounded_ai_stop_approach" );
	self endon( "disable_wounded_ai" );
	
	spot anim_reach_solo( self, animset[ "arrival" ][ side ] );
	
	self ent_flag_set( "wounded_ai_completed_approach_reach" );
	self ent_flag_set( "wounded_ai_playing_approach" );
	
	self notify( "wounded_ai_atgoal" );
	
	spot anim_single_solo( self, animset[ "arrival" ][ side ] );

	self ent_flag_clear( "wounded_ai_playing_approach" );	
	self notify( "wounded_ai_approach_done" );
}

set_wounded_ai_exit_behavior( spot, animset, forcemove )
{
	
	self endon( "disable_wounded_ai" );
	
	self waittill_any( "wounded_ai_newgoal" );
	
	if( !self ent_flag( "wounded_ai_playing_approach" ) )
	{
		self notify( "wounded_ai_stop_approach" );
	if( !self ent_flag( "wounded_ai_completed_approach_reach" ) )
			return;
	}

	else
		while( self ent_flag( "wounded_ai_playing_approach" ) )
			wait(.05);
	
	if( self.forcegoal == false )
	{
		
		while( self ent_flag( "wounded_ai_playing_idle_twitch" ) )
			wait(.05);
	}
	else
		self ent_flag_set( "wounded_ai_twitch_interrupted" );
	
	if( spot.skipexit == true )
	{
		self ent_flag_clear( "wounded_ai_playing_idle_twitch" );
		
		spot notify( "stop_anim" );
		self StopAnimScripted();
		return;	
	}
	
	leavetype = spot.stancetype;
	if( spot.exit90 == true )
		leavetype = spot.stancetype + "_90";
	else if( spot.exitf == true )
		leavetype = "forward";
	
	exit = animset[ "exit" ][ leavetype ];
	
	self ent_flag_set( "wounded_ai_playing_exit" );
	
	spot notify( "stop_anim" );
	spot anim_single_solo( self, exit );

	self ent_flag_clear( "wounded_ai_playing_exit" );
	self ent_flag_clear( "wounded_ai_twitch_interrupted" );
}

wounded_ai_leave_cover( forcemove )
{
	
	
}

set_wounded_ai_cover_animset( type )
{
	animset = [];
	
	if( type == "nocover" )
	{
		animset[ "arrival" ][ "middle" ] = "wounded_" + type + "_arrival";	
		
		animset[ "idle" ][ "idle" ] = "wounded_" + type + "_idle";
		
		animset[ "idle" ][ "pain" ] = "wounded_" + type + "_idle_twitch_pain";  
		animset[ "look" ][ "none" ] = "wounded_" + type + "_idle_twitch_look";
		
		animset[ "exit" ][ "stand" ] = "wounded_" + type + "_exit";
		
		return animset;
	}
	
	animset[ "idle" ][ "idle" ] = "wounded_" + type + "_idle";
	animset[ "idle" ][ "checkclip" ] = "wounded_" + type + "_idle_twitch_checkclip";
	animset[ "idle" ][ "pain" ] = "wounded_" + type + "_idle_twitch_pain";
	animset[ "look" ][ "left" ] = "wounded_" + type + "_idle_twitch_lookleft";
	animset[ "look" ][ "right" ] = "wounded_" + type + "_idle_twitch_lookright";
	
	if( type == "crouch" )
	{
		
	}
	
	if( type == "stand" )
	{
		animset[ "fire" ][ "left" ] = "wounded_" + type + "_fire_l";
		animset[ "fire" ][ "right" ] = "wounded_" + type + "_fire_r";
	
		animset[ "fire1h" ][ "left" ] = "wounded_" + type + "_fire_1h_l";
		animset[ "fire1h" ][ "right" ] = "wounded_" + type + "_fire_1h_r";
	}
	
	animset[ "arrival" ][ "right" ] = "wounded_" + type + "_arrival_r";
	animset[ "arrival" ][ "middle" ] = "wounded_" + type + "_arrival_m";
	animset[ "arrival" ][ "left" ] = "wounded_" + type + "_arrival_l";
	
	animset[ "exit" ][ "forward" ] = "wounded_" + type + "_exit_f";
	animset[ "exit" ][ "right" ] = "wounded_" + type + "_exit_l";
	animset[ "exit" ][ "left" ] = "wounded_" + type + "_exit_r";
	animset[ "exit" ][ "right_90" ] = "wounded_" + type + "_exit_r_90";
	animset[ "exit" ][ "left_90" ] = "wounded_" + type + "_exit_l_90";		
	
	return animset;	
}

get_wounded_ai_approach_side( spot )
{
	self endon( "wounded_ai_newgoal" );
	self endon( "disable_wounded_ai" );
	
	while( distance2D( self.origin, spot.origin ) > 100 )
		wait(.05);
	
	if( spot.type == "Cover Stand" )
	{
		direction = "middle";
		return direction;
	}
	
	vector = spot.origin - self.origin;
	angles = vectortoangles( vector );
	angle = angles[1] - spot.angles[1];
	
	//iprintln( angle );
	
	// angles can now only be between 180 and -180
	while( 1 )
	{
		if( angle > 180 )
			angle = angle - 360;
		
		if( angle < -180 )
			angle = angle + 360;
		
		if( angle < 180 && angle > -180 )
		{
			//iprintln( "new angle : " + angle );
			break;
		}
		
		wait(.05);
	}
	
	if( angle > 25 && angle < 160 ) // 45 135
		direction = "left";
	else if( angle < -25 && angle > -160 )
		direction = "right";
	else
		direction = "middle";
	
	//iprintln( direction );
	
	return direction;
		
}

shoot_alot( time, waittime, ender )
{

	if( isdefined( ender ) )
		self endon( ender );
	
	wait( waittime );
	
	num1 = .2;
	num2 = .6;
	
	ctime = 0;
	while( ctime < time )
	{
		self shoot();
		
		rtime = randomfloatrange( num1, num2 );
		
		if( time - ctime < rtime )
			rtime = time - ctime + .1;;
		
		wait( rtime );
		
		ctime = ctime + rtime;
	}
}

wounded_ai_pain_sounds()
{
	self endon( "disable_wounded_ai" );
	self endon( "wounded_ai_pain_sound_interrupted" );
	
	self thread wounded_ai_pain_sounded_interrupt();
	

	while( ent_flag( "FLAG_wounded_ai_play_sounds" ) )
	{
		
		wait( randomintrange( 3, 5 ) );

		stringg = "";
		if( cointoss() )
			stringg = "vegas_diz_cough";
		else
			stringg = "vegas_diz_pain_short";
			
		self.soundspot PlaySound( stringg, "sounddone" );
		
		self.soundspot waittill( "sounddone" );
		
	}
	
	self ent_flag_wait( "FLAG_wounded_ai_play_sounds" );
	self thread wounded_ai_pain_sounds();
}

wounded_ai_pain_sounded_interrupt()
{
	self endon( "disable_wounded_ai" );
	self endon( "FLAG_wounded_ai_play_sounds" );
	
	self waittill( "dialog_started" );
	
	self notify( "wounded_ai_pain_sound_interrupted" );
	
	self.soundspot stopsounds();
	
	self waittill( "dialog_ended" );
	
	self thread wounded_ai_pain_sounds();		
}

#using_animtree( "generic_human" );
enable_wounded_ai( type )
{
	if( !self ent_flag_exist( "wounded_ai_playing_idle_twitch" ) )
	{
		self ent_flag_init( "wounded_ai_playing_idle_twitch" );
		self ent_flag_init( "wounded_ai_twitch_interrupted" );
		self ent_flag_init( "wounded_ai_playing_approach" );
		self ent_flag_init( "wounded_ai_playing_exit" );
		self ent_flag_init( "wounded_ai_completed_approach_reach" );
		
		self ent_flag_init( "FLAG_wounded_ai_play_sounds" );
	}
	
	setsaveddvar( "ai_friendlyFireBlockDuration", 0 );
	
	self disable_surprise();
	
	self disable_arrivals();
	self disable_exits();
	
	self.ignoreall = true;
	self.ignoreme = true;
	
	self AllowedStances( "stand" );
	self.a.pose = "stand";
	self.a.disablePain = true;
	self.combatmode = "no_cover";
	self.ignoresuppression = true;
	self.ignorerandombulletdamage = true;
	self.alertlevel = "noncombat";
	self.alertlevelint = 0;
	self.allowpain = 0;
	self.pacifist = 1;
	self.dontmelee = true;
	self.noRunNGun = true;
	self.noRunReload = true;
	self.disableBulletWhizbyReaction = true;
	self.neverSprintForVariation = true;
	self.nogrenadereturnthrow = true;
	//self disable_turnAnims();
	
	old_grenadeawareness = self.grenadeawareness;
	self.grenadeawareness = 0;
	
	self.allowshooting = true;
	self.forcegoal = false;
	self.wounded_ai = true;
	
	self.customIdleAnimSet[ "stand" ] = %vegas_baker_stand_idle;
	
	// SETUP WALK
	
	//self thread enable_wounded_ai_runtype( type );
	
	walkanim = "wounded_limp_walk";
	twitch_weights = "wounded_ai_weights_limp";
	self set_run_anim_array( walkanim, twitch_weights );
	self set_moveplaybackrate( 0.8 );
	self.nododgemove = true;
	
	self.soundspot = spawn( "script_origin", self.origin );
	self.soundspot linkto( self, "tag_origin" );
	self ent_flag_set( "FLAG_wounded_ai_play_sounds" );
	//self thread wounded_ai_pain_sounds();

}

enable_wounded_ai_runtype( type )
{
	
	if( isdefined( type ) && type == "jog" )
	{
		self set_run_anim( "wounded_limp_jog", true ); //wounded_limp_walk
		self.moveplaybackrate = .8;
	}
	else
	{
		self set_run_anim( "wounded_limp_walk", true );	
	}
}

disable_wounded_ai()
{
	if( !isdefined( self.wounded_ai ) )
		return;
	
	self notify( "disable_wounded_ai" );
	
	if( isdefined( self.oldspot ) )
		self.oldspot notify( "stop_anim" );
	self stopanimscripted();
	
	self enable_surprise();
	
	self enable_arrivals();
	self enable_exits();
	
	self.ignoreall = false;
	self.ignoreme = false;
	
	self allowedStances( "stand", "crouch", "prone" );
	self.a.disablePain = false;
	self.nododgemove = false;
	self.combatmode	= "cover";
	self.ignoresuppression = false;
	self.ignorerandombulletdamage = false;
	self.alertlevel = "combat";
	self.alertlevelint = 0;
	self.allowpain = 1;
	self.pacifist = 0;
	self.dontmelee = false;
	self.noRunNGun = false;
	self.noRunReload = false;
	self.disableBulletWhizbyReaction = false;
	self.neverSprintForVariation = false;
	self.nogrenadereturnthrow = false;
	self enable_turnAnims();
	self set_moveplaybackrate( 1 );
	
	self.grenadeawareness = 1;
	
	self.allowshooting = undefined;
	self.forcegoal = undefined;
	self.wounded_ai = undefined;
	
	self clear_run_anim();
	
	//self animscripts\animset::set_animset_run_n_gun();
	
	self.customIdleAnimSet = undefined;
	self.customMoveTransition = undefined;
	self.permanentCustomMoveTransition = undefined;
	self.approachTypeFunc = undefined;
	self.approachConditionCheckFunc = undefined;
	self.disableCoverArrivalsOnly = undefined;
	
	self.soundspot stopsounds();
	waitframe(); // needs a wait before deleting
	self.soundspot delete();
}

// Vehicle Section
//---------------------------------------------------------
vehicle_path_notifies()
{
	self endon( "death" );
	
	funcs[ "reset_pitchroll" ] = ::chopper_reset_pitchroll;
	funcs[ "chopper_holding" ] = ::chopper_holding;
	
	while ( 1 )
	{
		self waittill( "noteworthy", note );
		
		if ( IsDefined( funcs[ note ] ) )
		{
			self [[ funcs[ note ] ]]();
		}
			
	}
}

chopper_reset_pitchroll()
{
	self SetMaxPitchRoll( 25, 25 );
}

chopper_holding()
{
	if ( !IsDefined( self.holding ) )
		return;
	
	self notify( "newpath" );
	self notify( "reached_dynamic_path_end" );
}

// AAS_72X Dynamic Path stuff aka "chopper shooter"
chopper_shooter_init( targetname )
{
	self.goal_pos = ( 0, 0, 0 );
	self.goal_dist = 0;
	self.on_path = false; // used for first getting into position
	self.do_pain = false;
	self SetNearGoalNotifyDist( 100 );
	self SetYawSpeed( 120, 60 );
	self SetHoverParams( 60, 20, 50 );
	
	node = getstruct( targetname, "targetname" );
	node init_chopper_path();

	if ( !IsDefined( self.shooter_side ) )
	{
		self.shooter_side = "right";
		if ( cointoss() )
		{
			self.shooter_side = "left";
		}
	}
	
	self.lookat_ent = Spawn( "script_origin", ( 0, 0, 0 ) );
	self set_lookat_origin();
	
	self thread chopper_shooter_pathing( node );
	self thread chopper_shooter_think();
	self thread chopper_shooter_death();
	self thread clear_chopper_shooter_flag();
}

chopper_shooter_death()
{
	self waittill( "death" );
	if ( IsDefined( self.angle_origin ) )
	{
		self.angle_origin Delete();
	}
}

clear_chopper_shooter_flag()
{
	self waittill_any( "death", "exiting" );
	level.courtyard.chopper_shooter_count--;
}

chopper_shooter_think()
{
	self endon( "death" );
	
	damage_health = ( self.health - self.healthbuffer ) * 0.75 + self.healthbuffer;
	did_pain = false;
	
	while ( 1 )
	{
		wait( 0.05 );

		self.shooters = array_removeDead_or_dying( self.shooters );
		self.shooters = array_removeUndefined( self.shooters );
		
		if ( !did_pain && self.health < damage_health )
		{
			did_pain = true;
			self.do_pain = true;
			
			self SetYawSpeed( 80, 30 );
			self SetHoverParams( 200, 50, 100 );
			
			self thread chopper_pain_fx();
		}		
		
		if ( self.shooters.size == 0 )
		{
			wait( 1 );
			// Fly Away
			self notify( "stop_pathing" );
			self ClearLookAtEnt();
			self chopper_exit();
			break;
			
		}
		else if ( self.shooters.size < 4 )
		{
//			if ( chance( 5 ) )
//			{
//				self notify( "stop_pathing" );
//				self ClearLookAtEnt();
//				self chopper_exit();
//				return;
//			}
//			else
//			{
				self try_chopper_switch_sides();
//			}
		}
	}
}

chopper_pain_fx()
{
	self endon( "death" );
	tag = "tag_engine_left";
	
	forward = AnglesToForward( self GetTagAngles( tag ) );	
	PlayFx( getfx( "aas_72x_damage_explosion" ), self GetTagOrigin( tag ), forward );
	self PlaySound( "aascout72x_helicopter_secondary_exp" );
	while ( 1 )
	{
		angles = self GetTagAngles( tag );
		forward = AnglesToForward( angles );
//		up = AnglesToUp( angles );
		PlayFx( getfx( "aas_72x_damage_trail" ), self GetTagOrigin( tag ), forward );
		wait( RandomFloatRange( 0.05, 0.2 ) );
	}
}

try_chopper_switch_sides()
{
	foreach ( shooter in self.shooters )
	{
		if ( !IsDefined( shooter ) || !IsAlive( shooter ) )
		{
			continue;
		}

		if ( self.shooter_side == "right" )
		{
			if ( shooter.vehicle_position < 4 )
			{
				return; // Don't need to switch
			}
		}
		else
		{
			if ( shooter.vehicle_position > 3 )
			{
				return; // Don't need to switch
			}
		}
	}
	
	self set_opposite_shooter_side();
}

set_opposite_shooter_side()
{
	if ( self.shooter_side == "left" )
	{
		self.shooter_side = "right";
	}
	else
	{
		self.shooter_side = "left";
	}
}

chopper_shooter_lookat_think()
{
	self endon( "stop_pathing" );
	self endon( "death" );
	
	self SetLookAtEnt( self.lookat_ent );
	
	while ( 1 )
	{
		wait( 0.2 );
		self set_lookat_origin();
	}
}

// for chopper_shooter
set_lookat_origin()
{
	angles = VectorToAngles( level.player.origin - self.origin );
	forward = AnglesToForward( angles );
	right = AnglesToRight( angles );

	if ( self.on_path && self.do_pain )
	{
		yaw = 120;
		if ( cointoss() )
			yaw = -120;
			
		right = AnglesToRight( angles + ( 0, yaw, 0 ) );
	}

	dir = right;
	if ( self.shooter_side == "right" )
	{
		dir = right * -1;
	}
	
	self.lookat_ent.origin = self.origin + ( dir * 100 );
}

chopper_shooter_pathing( start_node )
{
	self thread chopper_shooter_movement( start_node );
	
	self endon( "death" );
	self endon( "stop_pathing" );
	
/#
	//DEBUG
	foreach ( node in start_node.path )
	{
		node thread chopper_debug_node_dist();
	}
#/
		
	while ( 1 )
	{
		wait( 0.1 );

		data = get_pos_data_on_path( start_node, level.player.origin );
		closest = data[ "pos" ];
		index = data[ "index" ];
		
		// Get the current segment start			
		segment_node = start_node.path[ index ];

		// Figure out the dist percent
		point_dist = Distance( closest, segment_node.origin );
		dist = segment_node.dist + point_dist;

		percent = 0;
		if ( dist > 0 )
		{
			percent = dist / start_node.total_dist;
			percent = round_to( percent, 100 );
		}

/#
		if ( GetDvarInt( "debug_choppers" ) > 0 )
		{
			Line( closest, level.player.origin, ( 1, 1, 1 ), 1, 0, 2 );
			print3d( closest + ( 0, 0, 20 ), dist, ( 1, 1, 1 ), 1, 1, 2 );
			print3d( closest, percent, ( 1, 1, 1 ), 1, 1, 2 );
		}
#/
		buffer = 800;
		
		// allow for chopper to go to 0 if the 2d dist is valid
		if ( dist == 0 )
		{
			dist2d = Distance2D( level.player.origin, start_node.origin );
			buffer -= dist2d;
		}
		
		self.goal_dist = Max( dist + buffer, 0 );
//		print3d( self.origin + ( 0, 0, 20 ), self.goal_dist, ( 1, 1, 0 ), 1, 1, 2 );
	}
}

get_pos_data_on_path( node, origin )
{
	pos_array 		= [];
	for ( i = 0; i < node.path.size - 1; i++ )
	{
		pos = PointOnSegmentNearestToPoint( node.path[ i ].origin, node.path[ i + 1 ].origin, origin );
	
/#
		if ( GetDvarInt( "debug_choppers" ) > 0 )
		{
			Line( node.path[ i ].origin, node.path[ i + 1 ].origin, ( 1, 1, 0 ), 1, 0, 2 );
		}
#/
			
		pos_array[ pos_array.size ] = pos;
	}
		
	index = get_closest_index_in_array( pos_array, origin );
	closest = pos_array[ index ];
	
	array[ "pos" ] = closest;
	array[ "index" ] = index;
	
	return array;
}

get_path_pos_from_dist( node, dist )
{
	current_pos_data = get_pos_data_on_path( node, self.origin );
	index = current_pos_data[ "index" ];
	
	pos = undefined;
	if ( self.on_path )
	{
		i = index;
		if ( dist > node.path[ i + 1 ].dist + 50 ) // 50 is so we are approximately to that next node
		{
			self.goal_pos_stop = false;
			return node.path[ i + 1 ].origin;
		}
		else if ( i > 0 && dist < node.path[ i - 1 ].dist - 50 )
		{
			self.goal_pos_stop = false;
			return node.path[ i - 1 ].origin;
		}
		
		self.goal_pos_stop = true;
		forward = VectorNormalize( node.path[ i + 1 ].origin - node.path[ i ].origin );
		diff = dist - node.path[ i ].dist;
		pos = node.path[ i ].origin + ( forward * diff );
	}
	else // !self.on_path
	{
		self.goal_pos_stop = true;
		for ( i = 0; i < node.path.size - 1; i++ )
		{
			if ( dist > node.path[ i + 1 ].dist )
			{
				continue;
			}
			
			forward = VectorNormalize( node.path[ i + 1 ].origin - node.path[ i ].origin );
			diff = dist - node.path[ i ].dist;
			pos = node.path[ i ].origin + ( forward * diff );
			break;
		}
	}
	
	return pos;
}

chopper_shooter_movement( start_node )
{
	self endon( "death" );
	self endon( "stop_pathing" );
	
	buffer = Squared( 20 );
	
	offset = ( 0, 0, 100 );
	do_pain = false;
	
	while ( 1 )
	{
		wait( 0.05 );
		
		if ( self.on_path && self.do_pain )
		{
			self SetNearGoalNotifyDist( 20 );
			self Vehicle_SetSpeed( 60, 50, 50 );
			do_pain = true;
			yaw = RandomInt( 360 );
			origin = AnglesToForward( ( 0, yaw, 0 ) ) * 100;
			if ( cointoss() )
			{
				offset = origin + ( 0, 0, -150 );
			}
			else
			{
				offset = origin + ( 0, 0, 150 );
			}
		}
		
		pos = self get_path_pos_from_dist( start_node, self.goal_dist );
		pos += offset;

		if ( !self.on_path )
		{
			self.starting_pos = pos;
		}
		
		if ( DistanceSquared( self.origin, pos ) < buffer )
		{
			continue;
		}
		
		self thread chopper_debug_goal_pos( pos, self.goal_dist );
		
		self SetVehGoalPos( pos, self.goal_pos_stop );
		goal = self chopper_shooter_waittill_goal( pos );
		
		if ( self.on_path && do_pain )
		{
			self SetNearGoalNotifyDist( 100 );
			self Vehicle_SetSpeed( 30, 15, 50 );
			do_pain = false;
			self.do_pain = false;
			offset = ( 0, 0, 0 );
		}
			
		if ( !self.on_path && goal )
		{
			self Vehicle_SetSpeed( 30, 15, 50 );
			self.on_path = true;
			self thread chopper_shooter_lookat_think();
			offset = ( 0, 0, 0 );
		}
	}
}

chopper_shooter_waittill_goal( pos )
{
	self endon( "death" );
	
	if ( self.on_path )
	{
		msg = self waittill_any( "near_goal", "goal" );
	}
	else // !self.on_path so update more frequent
	{
		dist = self.goal_dist;
		
		while ( 1 )
		{
			wait( 0.05 );
			if ( DistanceSquared( pos, self.origin ) < Squared( 100 ) )
			{
				return true;
			}

			// the goal_dist got updated to a far away location, let's go there instead
			if ( abs( dist - self.goal_dist ) > 10 )
			{
				return false;
			}
		}
	}
	
	return true;
}



chopper_debug_node_dist()
{
/#
	while ( 1 )
	{
		wait( 0.05 );
		
		if ( GetDvarInt( "debug_choppers" ) > 0 )
		{
			Print3d( self.origin, self.dist, ( 1, 0.5, 0 ) );
		}
	}
#/
}

chopper_debug_goal_pos( pos, dist )
{
/#
	self endon( "death" );
	self notify( "stop_debug_goal_pos" );
	self endon( "stop_debug_goal_pos" );
	
	while ( 1 )
	{
		if ( GetDvarInt( "debug_choppers" ) > 0 )
		{
			Print3d( self.origin, dist, ( 0, 1, 0 ) );
			Line( self.origin, pos, ( 0, 1, 0 ) );
		}
		wait( 0.05 );
	}
#/
}

init_chopper_path()
{
	if ( IsDefined( self.path ) )
		return;

	total_dist = 0;
	path_array = self get_targeted_ents();	
	for ( i = 0; i < path_array.size - 1; i++ )
	{
		node = path_array[ i ];
		node.segment_index = i;
		
		d = Distance( path_array[ i ].origin, path_array[ i + 1 ].origin );
		node.dist = total_dist;		
		total_dist += d;
		node.segment_dist = d;
	}
	
	// End node doesn't get a dist or index
	path_array[ path_array.size - 1 ].dist = total_dist;
	
	self.total_dist = total_dist;
	self.path = path_array;
}

chopper_unload()
{
	structs = get_sorted_structs( "chopper_landing", self.origin );
	struct = get_unused_struct( structs );
	
	struct.inuse = true;
	struct thread reset_inuse( self, "reached_dynamic_path_end" );

	self SetYawSpeed( 90, 45 );
	
	// thread vehicle_paths cause script_unload in _vehicle_code.gsc ends vehicles_paths and then resumes after unloading
	self thread vehicle_paths( struct, false );
}

chopper_exit()
{
	self endon( "death" );

	self notify( "exiting" );
	structs = get_sorted_structs( "chopper_exit", self.origin );
	struct = get_unused_struct( structs );
	
	self.inuse = true;
	struct thread reset_inuse( self );
	
	self vehicle_paths( struct, false );
}

reset_inuse( ent, msg1, msg2 )
{
	ent waittill_any( "death", msg1, msg2 );
	self.inuse = false;
}

get_unused_struct( structs )
{
	foreach ( _, struct in structs )
	{
		if ( !IsDefined( struct.inuse ) )
		{
			return struct;
		}
		
		if ( !struct.inuse )
		{
			return struct;
		}
	}
	
	return undefined;
}

get_chopper_spawner( targetname )
{
	spawners = GetEntArray( targetname, "targetname" );
	spawners = array_randomize( spawners );
	spawner = undefined;
	foreach ( ent in spawners )
	{
		if ( !IsDefined( ent.inuse ) || !ent.inuse )
		{
			spawner = ent;
			break;
		}
	}
	
	return spawner;
}

// Ninja's Radio
//---------------------------------------------------------
init_enemy_radio()
{
	if ( IsDefined( level.ninja.radio ) )
		return;
	
	level.ninja.radio = Spawn( "script_origin", level.ninja.origin );
	level.ninja.radio SetModel( "com_hand_radio" );
	level.ninja.radio LinkTo( level.ninja, "j_hiptwist_ri", ( 0, -2, -5 ), ( 0, 180, 270 ) );
}

play_enemy_radio( alias )
{
	init_enemy_radio();
	level.ninja.radio play_sound_on_entity( alias );
}

// Start Points
//---------------------------------------------------------
is_start_point_before( start_point )
{
	start_point_index = get_index_of_start( start_point );
	curr_point_index = get_index_of_start( level.start_point );

	if ( IsDefined( start_point_index ) && IsDefined( curr_point_index ) )
	{
		return curr_point_index < start_point_index;
	}

	AssertMsg( "start point is wrong!" );
	return undefined;
}

is_start_point_after( start_point )
{
	start_point_index = get_index_of_start( start_point );
	curr_point_index = get_index_of_start( level.start_point );

	if ( IsDefined( start_point_index ) && IsDefined( curr_point_index ) )
	{
		return curr_point_index > start_point_index;
	}

	AssertMsg( "start point is wrong!" );
	return undefined;
}

get_index_of_start( start_point )
{
	foreach ( idx, start in level.start_functions )
	{
		if ( start[ "name" ] == start_point )
		{
			return idx;
		}
	}

	return undefined;
}

run_to_goal_delete( goal )
{
	self endon ( "death" );
	self setgoalnode ( goal );
	self waittill ( "goal" );
	self Delete();
}

// Utility Section
//---------------------------------------------------------
round_to( val, mult )
{
	val = int( val * mult ) / mult;

	return val;
}

get_sorted_structs( targetname, origin )
{
	Assert( IsDefined( origin ) );
	
	structs = getstructarray( targetname, "targetname" );
	structs = SortByDistance( structs, origin );
	return structs;
}

end_of_scripting()
{
	flag_wait( "out_of_courtyard" );

	for ( i = 0; i < 3; i++ )
	{
		IPrintLnBold( "End of NEW scripting!" );
		wait( 5 );
	}
}

chance( n )
{
	num = RandomInt( 100 );
	if ( num < n )
	{
		return true;
	}
	
	return false;
}