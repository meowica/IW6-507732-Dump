#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\skyway_util;

//*******************************************************************
//																	*
//																	*
//*******************************************************************

section_flag_inits()
{
	// general flags
	flag_init( "flag_rooftops_start" );
	flag_init( "flag_rt2_combat_start" );
	flag_init( "flag_rt2_combat_fin" );
	flag_init( "flag_rt2_combat_retreat" );
	flag_init( "flag_rooftops_combat_end" );
	
	// helo encoutner
	flag_init( "flag_rt1_helo_start" );
	flag_init( "flag_helo_end" );
}

section_precache()
{
	// PreCacheModel( "weapon_stinger" );
	// PreCacheItem( "stinger" );
}

section_post_inits()
{
	// setup ai funcs
	thread setup_spawners();
}

start()
{
	IPrintLn( "rooftops" );
	
	// init player
	player_start = GetEnt( "rt1_start_player", "targetname" ); //GetEnt( "player_start_rt_hangar", "targetname" );
	level.player SetOrigin( player_start.origin );
	level.player SetPlayerAngles( player_start.angles );
	
	// init allies
	node = GetEnt( "rt1_start_ally", "targetname" );
	level._ally ForceTeleport( node.origin, node.angles );
	
	// TEMP TEMP - thread real_reload on player
	level.player thread real_reload();
	// TEMP TEMP - thread debug loop
	thread bmcd_debug_loop();
	
	// start encounter
	delayThread( 0.05, ::flag_set, "flag_rooftops_start" );
}

main()
{
	// setup triggers (sandbag - can be cleaned to setup per car)
	notes = [ "train_rt1", "train_rt2", "train_rt3", "train_rt4" ];
	foreach( note in notes )
		array_call( level._train.cars[ note ].trigs, ::SetMovingPlatformTrigger );
	
	// init & move ally to 1st car
	level._ally thread set_grenadeammo( 0 );
	nodes = GetNodeArray( "rt1_node_start_ally", "targetname" );
	level._ally thread follow_path( nodes[ RandomInt( nodes.size ) ] );
	
	// init level vars
	old_goalradius			 = level.default_goalradius;
	level.default_goalradius = 768;
	
	//**********************************************************
	// Wait for player to approach rooftops
	flag_wait( "flag_rooftops_start" );
	delayThread(0.05, ::autosave_by_name, "rooftops_start" );
	
	// increase player threat to allow ally forward movement
	SetThreatBias( "player", "axis", 250 );
	
	// encounter flow
	thread rt_start();
	rt_combat();
	
	//**********************************************************
	// Cleanup Rooftops Combat
	level waittill( "notify_teleport_rooftop_vista" );
	
	level.default_goalradius = old_goalradius;
}

//*******************************************************************
//																	*
//		ENCOUTNER SCRIPTS											*
//*******************************************************************
rt_start()
{
	// move ally
	level._ally thread set_force_color( "r" );
	thread temp_dialogue_line( "Hesh", "Let's get going before they figure out we're on the roof", 2.5 );
	
	//**********************************************************
	// Helo encounter
	flag_wait( "flag_rt1_helo_start" );
	
	// move ally (switch to helo nodes)
	level._ally thread set_force_color( "b" );
	
	IPrintLnBold( "Helicopters approach for quick helo combat" );
	thread temp_dialogue_line( "Hesh", "Helos! Take Cover!", 1 );
	
	// TEMP TEMP - end helo event
	delayThread( 5, ::flag_set, "flag_helo_end" );
	
	//**********************************************************
	// Helo dead
	flag_wait( "flag_helo_end" );
	IPrintLnBold( "Congratulations! You killed the helos!" );
	
	// switch ally to normal nodes
	level._ally thread set_force_color( "r" );
	
	// move ally to rt2 (if he's not already there)
	if( !flag( "flag_rt2_combat_start" ) )
	{
		thread temp_dialogue_line( "Hesh", "Helos down. Move forward!", 1.5 );
		GetEnt( "rt2_color_start", "targetname" ) notify( "trigger" );
	}
		
}

//**************************************************************
//		Rooftop combat
//**************************************************************
rt_combat()
{
	flag_wait( "flag_rt2_combat_start" );
	
	flood_spawn( GetEntArray( "rt2_opfor", "targetname" ) );
	
	delay_retreat( "rt_opfor", 30, -4, "flag_rt2_combat_retreat", [ "rt2_color_start", "rt2_color_end", "rt2_color_fin" ], true );
	
	flood_spawn( GetEntArray( "rt3_opfor", "targetname" ) );
}

//*******************************************************************
//																	*
//		AI SCRIPTS													*
//*******************************************************************

setup_spawners()
{
	// setup infils
	setup_rooftops_infils( [ "train_rt1", "train_rt2", "train_rt3", "train_rt4" ] );
	
	// setup opfor	    
	array_spawn_function_targetname( "rt2_opfor", ::rt_spawn_node_check, "flag_rt2_combat_fin", "rt2_node_fin" );
	
	// setup threatbias
	// SetThreatBias( "I_am_attacking", "you", 256 );
}

rt_spawn_node_check( my_flag, my_node )
{
	self endon( "death" );
	
	// wait till ai finishes infil
	if( IsDefined( self.script_wtf ) )
		self waittill( "infil_done" );
	
	// check for retreat (otherwise follow normal logic)
	if( flag( my_flag ) )
		self thread follow_path( GetNode( my_node, "targetname" ) );
}

setup_rooftops_infils( notes )
{
	if( !IsArray( notes ) || notes.size < 1 )
		return;
	
	foreach( note in notes )
	{
		array = GetEntArray( note, "script_noteworthy" );
		
		foreach( part in array )
			if( IsDefined( part.classname ) && IsSubStr( part.classname, "actor_" ) )
				part add_spawn_function( ::opfor_infil_logic );
	}
}

//*******************************************************************
//																	*
//		AI INFIL LOGIC												*
//*******************************************************************

opfor_infil_logic()
{
	self endon( "death" );
	
	// check if an entry is defined
	if ( !IsDefined( self.script_wtf ) )
		return;
	
	// TEMP TEMP - reduce move speed
	// self set_moveplaybackrate( RandomFloatRange( 0.8, 0.9 ) );
	
	// get entry from list of entries an ai can use (script_wtf)
	entry = get_entry( GetEntArray( self.script_wtf, "targetname" ) );
	animname = entry.script_namenumber + "_opfor";
	
	// set entry in use (unlock upon death or cleanup)
	self thread infil_entry_lock( entry );
	
	// check for anims[] and set it up
	if ( !IsDefined( entry.anims ) )
	{
		// asign animtree (script_namenumber) and create anims array
		entry assign_animtree( entry.script_namenumber );
		entry.anims	= [];
		
		for ( i = 0; i < entry.script_side.size; i++ )
		{
			// get direction char
			char = GetSubStr( entry.script_side, i, i + 1 );
			
			// add direction anim to array
			switch( char )
			{
				case "F":
					entry.anims[ entry.anims.size ] = "sw_entry_f";
					break;
				case "U":
					entry.anims[ entry.anims.size ] = "sw_entry_u";
					break;
				case "R":
					entry.anims[ entry.anims.size ] = "sw_entry_r";
					break;
				case "L":
					entry.anims[ entry.anims.size ] = "sw_entry_l";
					break;
			}
		}
	}
	
	// pick anim and animate
	i = RandomInt( entry.anims.size );
	self.allowdeath = true;
	entry thread anim_single_solo( entry, entry.anims[ i ] );
	self LinkTo( entry );
	entry anim_single_solo( self, entry.anims[ i ], undefined, undefined, animname );
	self Unlink();
	
	// go to node
	if( IsDefined( self.target ) )
		self thread follow_path( GetNode( self.target, "targetname" ) );
	
	// cleanup
	self notify( "infil_done" );
}

get_entry( entries )
{
	self endon( "death" );
	
	entry = entries[ RandomInt( entries.size ) ];
	
	while( 1 )
	{
		if ( RandomInt( 100 ) < entry.script_index && !isTrue( entry.in_use ) )
		return entry;
		
		wait( 0.05 );
	}	
}

infil_entry_lock( entry )
{
	// lock entry
	entry.in_use = true;
	
	// check for shared infil (breaks "in_use" early )
	if( IsDefined( self.script_parameters ) )
		self notify_delay( "infil_share", self.script_parameters );
	
	// wait till infil is free
	self waittill_any( "death", "infil_done", "infil_share" );
	
	// clear entry and stop thread
	entry.in_use = undefined;
}

//*******************************************************************
//																	*
//		PUSH & RUMBLE SCRIPTS										*
//*******************************************************************

//**************************************************************
//		Rumble Scripts
//**************************************************************
rumble_player_push( push_org, push_mag )
{
	// play effects on the player
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	train_quake( 0.3, 1.2, level.player.origin, 256 );
	level.player ViewKick( 10, push_org );
}

rumble_helo_hit( dist, push_org )
{
	if ( dist > 1.5 )
		return;
	if ( dist > 1 )
	{
		// small rumble
    	level.player PlayRumbleOnEntity( "damage_light" );
		train_quake( 0.11, 1.0, level.player.origin, 128 );
	}
	else
	{
		// play effects on the player
    	level.player PlayRumbleOnEntity( "grenade_rumble" );
		train_quake( 0.3, 1.2, level.player.origin, 256 );
		level.player ShellShock( "default_nosound", 2 );
		level.player ViewKick( 10, push_org );
	}
}

//**************************************************************
//		Push Scripts
//**************************************************************
player_push( push_org, safe_dist, push_min, push_max, push_time, rumble )
{
	dist = Distance( level.player.origin, push_org );
	
	// check if player is pushed
	if ( dist < safe_dist )
	{
		// get push vector (weighted average based on distance and the min/max push)
		avg = clamp( dist / safe_dist, 0, 1 );
		vec = VectorNormalize( level.player.origin - push_org );
		vec	*= ( push_min * avg ) + ( push_max * ( 1 - avg ) );
		
		// push player
    	thread player_push_impulse( vec, push_time );
	}
    
	// thread rumble if defined
	if ( IsDefined( rumble ) )
		thread [[ rumble ]]( dist / safe_dist, push_org );
}

player_push_train( car, push_dir, push_mag, push_time, rumble )
{
	// get push vector (from the forward unit vector of the train)
	ang = ( 0, 1, 0 ) * car.body GetTagAngles( "j_spineupper" ) + push_dir;
	vec = AnglesToForward( ang ) * push_mag;
	
	// push player
	thread player_push_impulse( vec, push_time );
    
	// thread rumble if defined
	if ( IsDefined( rumble ) )
		thread [[ rumble ]]( level.player.origin + vec, push_mag);
}

player_push_impulse( vec, push_time )
{
	// init time
	if( !IsDefined( push_time ) )
		push_time = 0.5;
	my_time = push_time;
	
	while ( my_time > 0.0 )
	{
		// get weighted push (slows to a stop by the end)
		avg = clamp( my_time / push_time, 0, 1 );
		push = vec * avg;
		
		// push player
		level.player PushPlayerVector( push );
		
		// increment time
		my_time -= 0.05;
		wait( 0.05 );
	}
	
	// stop push
	level.player PushPlayerVector( ( 0, 0, 0 ) );
}

//*******************************************************************
//																	*
//		UTIL SCRIPTS												*
//*******************************************************************

ignore_run( speed, note )
{
	self endon( "death" );
	self notify( "stop_ignore_run" );
	self endon( "stop_ignore_run" );
	
	if ( !IsDefined( speed ) )
		speed = 1.0;
	
	// init & speed up
	self.old					   = [];
	self.old[ "react_dist" ]	   = self.newEnemyReactionDistSq;
	self.old[ "color" ]			   = self get_force_color();
	self.old[ "moveplaybackrate" ] = self.moveplaybackrate;
	self.old[ "grenade_aware"	 ] = self.grenadeAwareness;
	self thread set_moveplaybackrate( speed, 0.25 );
	
	// ignore stuff
	self set_ignoreall( true );
	self PushPlayer( true );
	self.a.disablePain				 = 1;
	self.allowPain					 = 0;
	self.disableBulletWhizbyReaction = 1;
	self.disableFriendlyFireReaction = 1;
	self.disableplayeradsloscheck	 = 1;
	self.doDangerReact				 = 0;
	self.dontavoidplayer			 = 1;
	self.dontMelee					 = 1;
	self.flashBangImmunity			 = 1;
	self.grenadeAwareness			 = 0;
	self.ignoreexplosionevents		 = 1;
	self.ignorerandombulletdamage	 = 1;
	self.ignoresuppression			 = 1;
	self.newEnemyReactionDistSq		 = 0;
	
	if ( IsDefined( note ) )
	{
		// wait till note
		self waittill( note );
		
		// stop ignore run
		self stop_ignore_run();
	}
}

stop_ignore_run()
{
	self endon( "death" );
	self notify( "stop_ignore_run" );
	
	// setup default saved vals if not already saved
	if ( !IsDefined( self.old ) )
	{
		self.old					   = [];
		self.old[ "react_dist"		 ] = 262144;
		self.old[ "color"			 ] = "r";
		self.old[ "moveplaybackrate" ] = 1;
		self.old[ "grenade_aware"	 ] = 0.9;
	}
	
	// reset ai
	self set_ignoreall( false );
	self PushPlayer( false );
	self.a.disablePain				 = 0;
	self.allowPain					 = 1;
	self.disableBulletWhizbyReaction = undefined;
	self.disableFriendlyFireReaction = undefined;
	self.disableplayeradsloscheck	 = 0;
	self.doDangerReact				 = 1;
	self.dontavoidplayer			 = 0;
	self.dontMelee					 = undefined;
	self.flashBangImmunity			 = undefined;
	self.grenadeAwareness			 = self.old[ "grenade_aware" ];
	self.ignoreexplosionevents		 = 0;
	self.ignorerandombulletdamage	 = 0;
	self.ignoresuppression			 = 0;
	self.newEnemyReactionDistSq		 = self.old[ "react_dist" ];
	
	// reset speed & color movement
	self set_moveplaybackrate( self.old[ "moveplaybackrate" ] );
	self set_force_color( self.old[ "color" ] );
}

//*******************************************************************
//																	*
//		TEMP TEST SCRIPTS											*
//*******************************************************************

bmcd_debug_loop()
{	
	level notify_delay( "stop_cody_debug", 0.1 );
	
	while( 1 )
	{
		if ( level.player ButtonPressed( "DPAD_LEFT" ) )
		{
			iprintln( "blue" );
			level._ally thread set_force_color( "b" );
			wait( 0.2 );
		}
		else if ( level.player ButtonPressed( "DPAD_RIGHT" ) )
		{
			iprintln( "red" );
			level._ally thread set_force_color( "r" );
			wait( 0.2 );
		}
		else if ( level.player ButtonPressed( "DPAD_UP" ) )
		{
			iprintln( "const quake" );
			thread player_const_quake_blendto( 0.2, 0.1 );
			wait( 0.2 );
		}
		else if ( level.player ButtonPressed( "DPAD_DOWN" ) )
		{
			iprintln( "earthquake 100k" );
			train_quake( 0.45, 1.2, level.player.origin, 100000 );
			wait( 0.2 );
		}
		
		wait( 0.1 );
	}
}