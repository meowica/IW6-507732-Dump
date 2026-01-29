#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_move_to_checkpoint_start( node_targetname )
{
	// Move player to start
	node = GetEnt( node_targetname, "targetname" );
	level.player setOrigin( node.origin );
	level.player setPlayerAngles( node.angles );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies_move_to_checkpoint_start( checkpoint, reset )
{
	// Move allies to start points
	for ( i = 0; i < 3; i++ )
	{
		struct_targetname = checkpoint + "_ally_" + i;
		struct			  = GetStruct( struct_targetname, "targetname" );
		level.allies[ i ] ForceTeleport( struct.origin, struct.angles );
		if( IsDefined( reset ) )
		{
			level.allies[ i ] clear_force_color();
			level.allies[ i ] SetGoalPos( struct.origin );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_allies()
{
	level.allies					  = [];
	level.allies[ level.allies.size ] = spawn_ally( "ally_0" );
	level.allies[ level.allies.size ] = spawn_ally( "ally_1" );
	level.allies[ level.allies.size ] = spawn_ally( "ally_2" );
	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_ally( allyName, overrideSpawnPointName )
{
	spawnname = undefined;
	if ( !IsDefined( overrideSpawnPointName ) )
	{
		spawnname = level.start_point + "_" + allyName;
	}
	else
	{
		spawnname = overrideSpawnPointName + "_" + allyName;
	}

	ally = spawn_targetname_at_struct_targetname( allyName, spawnname );
	if ( !IsDefined( ally ) )
	{
		return undefined;
	}
	ally make_hero();
	if ( !IsDefined( ally.magic_bullet_shield ) )
	{
		ally magic_bullet_shield();
		ally.animname = allyName;
	}

	return ally;	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_targetname_at_struct_targetname( tname, sname )
{
	spawner = GetEnt( tname, "targetname" );
	sstart	= getstruct( sname, "targetname" );
	if ( IsDefined( spawner ) && IsDefined( sstart ) )
	{
		spawner.origin = sstart.origin;
		if ( IsDefined( sstart.angles ) )
		{
			spawner.angles = sstart.angles;
		}
		spawned = spawner spawn_ai();
		return spawned;
	}
	if ( IsDefined( spawner ) )
	{
		spawned = spawner spawn_ai();
		IPrintLnBold( "Add a script struct called: " + sname + " to spawn him in the correct location." );
		spawned Teleport( level.player.origin, level.player.angles );
		return spawned;
		
	}
	IPrintLnBold( "failed to spawn " + tname + " at " + sname );

	return undefined;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

kill_allies()
{
	foreach( ally in level.allies )
	{
		ally stop_magic_bullet_shield();
		ally.diequietly = true;
		ally kill();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

reassign_goal_volume( guys, volume_name )
{
	Assert( IsDefined( guys ) );

	if ( !IsArray( guys ) )
	{
		guys = make_array( guys );
	}
	
	guys = array_removeDead_or_dying( guys );
	vol	 = GetEnt( volume_name, "targetname" );

	foreach ( guy in guys )
	{
		guy SetGoalVolumeAuto( vol );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_group_staggered( aSpawners, doSafe )
{
	spawn_group( aSpawners, doSafe, true );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_group( aSpawners, doSafe, doStaggered, doFlood )
{
	ASSERTEX( ( aSpawners.size > 0 ), "The array passed to array_spawn function is empty" );
	
	if( !IsDefined( doSafe ) )
	{
		doSafe = false;
	}

	if( !IsDefined( doStaggered ) )
	{
		doStaggered = false;
	}

	if ( !IsDefined( doFlood ) )
	{
		doFlood = false;
	}
	
	aSpawners = array_randomize( aSpawners );
	
	spawnedGuys = [];
	foreach( index, spawner in aSpawners )
	{
		guy = spawner spawn_ai();
		spawnedGuys[ spawnedGuys.size ] = guy;
		
		if( doStaggered )
		{
			if( index != ( aSpawners.size - 1 ) )
			{
				wait( randomfloatrange( .25, 1 ) );
			}
		}
	}
	
	if( doSafe )
	{
		//check to ensure all the guys were spawned
		ASSERTEX( ( aSpawners.size == spawnedGuys.size ), "Not all guys were spawned successfully from array_spawn" );
	}

	return spawnedGuys;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

friendly_adjust_movement_speed()
{
	self notify( "stop_adjust_movement_speed" );
	self endon( "death" );
	self endon( "stop_adjust_movement_speed" );
	
	while( IsAlive( self ) )
	{
		wait RandomFloatRange( .5, 1.5 );
		
		while( friendly_should_speed_up() )
		{
			iPrintLnBold( "friendlies speeding up" );
			self.moveplaybackrate = 3.5;
			wait 0.05;
		}
		
		self.moveplaybackrate = 1.0;
	}
}

friendly_should_speed_up()
{
	self endon( "death" );
	prof_begin( "friendly_movement_rate_math" );
	
	if ( !IsDefined( self.goalpos ) )
	{
		prof_end( "friendly_movement_rate_math" );
		return false;
	}
	
	if ( DistanceSquared( self.origin, self.goalpos ) <= level.goodFriendlyDistanceFromPlayerSquared )
	{
		prof_end( "friendly_movement_rate_math" );
		return false;
	}
	
	// check if AI is visible in player's FOV
	if ( within_fov( level.player.origin, level.player GetPlayerAngles(), self.origin, level.cosine[ "90" ] ) )
	{
		prof_end( "friendly_movement_rate_math" );
		return false;
	}
	
	prof_end( "friendly_movement_rate_math" );
	
	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Waits until either a trigger is triggered or an aigroup count has been reached
waittill_aigroupcount_or_trigger_targetname( aigroup, count, targetname )
{
	trigger = GetEnt( targetname, "targetname" );
	
	trigger endon( "trigger" );
	level endon( "aigroup_count_triggered" );
	
	waittill_aigroupcount( aigroup, count );
	level notify( "aigroup_count_triggered" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hide_scriptmodel_by_targetname( targetname )
{
    brush = GetEnt( targetname, "targetname" );
    brush Hide();
    brush NotSolid();

    if ( brush.classname == "script_brushmodel" )
    {
        brush ConnectPaths();
    }
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hide_scriptmodel_by_targetname_array( targetname )
{
    brushes = GetEntArray( targetname, "targetname" );
    
    foreach( brush in brushes )
    {
	    brush Hide();
	    brush NotSolid();
	
	    if ( brush.classname == "script_brushmodel" )
	    {
	        brush ConnectPaths();
	    }
    }
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hide_models_by_targetname( targetname, connectpaths )
{
    brushes = GetEntArray( targetname, "targetname" );

    foreach( brush in brushes )
    {
	    brush Hide();
	    brush NotSolid();
	
	    if( IsDefined( connectpaths ) && connectpaths )
	    {
		    if ( brush.classname == "script_brushmodel" )
		    {
		        brush ConnectPaths();
		    }
	    }
    }
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

show_models_by_targetname( targetname, disconnectpaths )
{
	brushes = GetEntArray( targetname, "targetname" );
    
    foreach( brush in brushes )
    {
	    brush Show();
	    brush Solid();
	
	    if( IsDefined( disconnectpaths ) && disconnectpaths )
	    {
		    if ( brush.classname == "script_brushmodel" )
		    {
		        brush DisconnectPaths();
		    }
	    }
    }
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_water_death()
{
	for ( index = 0; index < 4; index++ )
	{
		trigger = GetEnt( "trigger_water_death_" + index, "targetname" );
		trigger thread fell_in_water_fail( index );
	}

	// setup water splash fx entity infront of the player
	thread maps\flood_coverwater::setup_player_view_water_fx_source();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fell_in_water_fail( index, skip_trigger )
{
	self endon( "death" );

	if ( !IsDefined( skip_trigger ) )
	{
		self waittill( "trigger" );
	}

	// we don't want fall damage to kick in
	level.player EnableInvulnerability();

	thread maps\flood_coverwater::create_player_going_underwater_effects();
	level.player EnableSlowAim();

	level.player DisableWeapons();
	level.player HideViewModel();
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	SetSavedDvar( "compass"		   , 0 );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance" , 0 );
	level.player ShellShock( "dog_bite", 0.75 );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	level.player StunPlayer( 1.0 );
	level.player PlaySound( "scn_flood_swept_away_splash_ss" );
	maps\flood_coverwater::player_make_bubbles();

	player_rig		  = spawn_anim_model( "player_rig", level.player.origin + ( 0, 0, -128 ) );
	player_rig.angles = level.player.angles;
	player_mover	  = player_rig spawn_tag_origin();
	player_rig LinkTo( player_mover );

	guys[ "player_rig" ] = player_rig;
	arc					 = 15;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 0, arc, arc, arc, arc );
	player_rig thread anim_single( guys, "flood_sweptaway" );

	switch( index )
	{
		case 0:
		case 1:
			player_mover MoveY( -3000, 5, 1 );
			break;
		case 2:
			player_mover MoveY( -100, 10, 1 );
			break;
		case 3:
			player_mover MoveY( -500, 5, 1 );
			break;
	}
	player_mover RotateTo( ( 0, 270, 0 ), 3 );

	if( !flag( "missionfailed" ) )
	{
		SetDvar( "ui_deadquote", &"FLOOD_MOVING_WATER_FAIL" );
	}
	level thread maps\_utility::missionFailedWrapper();
	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

submerging_bubble_effects()
{
	for ( index = 0; index < 4; index++ )
	{
		PlayFx( getfx( "flooded_player_bubbles" ), level.player_view_water_fx_source.origin );
		wait 0.1;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_default_weapons( offhand_only )
{
	if( !IsDefined( offhand_only ) )
	{
		level.player GiveWeapon( "cz805bren+reflex_sp" );
		level.player GiveWeapon( "m9a1" );
		level.player SwitchToWeapon( "cz805bren" );
	}
	level.player GiveWeapon( "fraggrenade" );
	level.player GiveWeapon( "flash_grenade" );
	level.player SetOffhandSecondaryClass( "flash" );	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

update_goal_vol_from_trigger( trigger_handle, goal_vol )
{
	self endon( "death" );
	self endon( "stop_goal_volume_updates" );

	Assert( IsDefined( trigger_handle ) );
	trigger = GetEnt( trigger_handle, "targetname" );
	if( !IsDefined( trigger ) )
	{
		trigger = GetEnt( trigger_handle, "script_noteworthy" );
		if( !IsDefined( trigger ) )
		{
			AssertMsg( "No entity exists with " + trigger_handle + " with targetname or script_noteworthy KVP" );
		}
	}

	self endon( "death" );
	trigger endon( "death" );

	while ( IsAlive( self ) )
	{
		trigger waittill( "trigger" );
		maps\flood_util::reassign_goal_volume( self, goal_vol );
		while( level.player IsTouching( trigger ) )
		{
			wait( 1.0 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cleanup_triggers( trigger_name )
{
	Assert( IsDefined( trigger_name ) );
	
	triggers = GetEntArray( trigger_name, "targetname" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notify_on_aigroup_count( ai_group, count, notify_msg )
{
	waittill_aigroupcount( ai_group, count );

	self notify( notify_msg );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notify_on_enemy_count( count, notify_msg, flag_handle )
{
	while ( true )
	{
		alive = 0;
		enemies = GetAIArray( "axis" );

		foreach( enemy in enemies )
		{
			if( IsAlive( enemy ) )
			{
				//line( level.player.origin, enemy.origin, ( 0, 255, 0 ), 1, false, 1 );
				alive++;
			}
		}
		//IPrintLn( "Currently " + alive + " enemies alive" );

		if ( count >= alive )
		{
			break;
		}

		wait( 0.05 );
		//wait( 1.0 );
	}

	if( IsDefined( notify_msg ) )
	{
		self notify( notify_msg );
	}

	if ( IsDefined( flag_handle ) )
	{
		flag_set( flag_handle );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_aigroup_count_or_timeout( ai_group, count, time )
{
	self thread notify_on_aigroup_count( ai_group, count, "count_reached" );
	self waittill_notify_or_timeout( "count_reached", time );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_aigroup_count_or_trigger( ai_group, count, trigger_handle )
{
	trigger = GetEnt( trigger_handle, "targetname" );
	if( !IsDefined( trigger ) )
	{
		trigger = GetEnt( trigger_handle, "script_noteworthy" );
		if( !IsDefined( trigger ) )
		{
			AssertMsg( "No entity exists with " + trigger_handle + " with targetname or script_noteworthy KVP" );
		}
	}

	trigger thread notify_on_aigroup_count( ai_group, count, "count_reached" );
	trigger waittill_any( "trigger", "count_reached" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_enemy_count_or_trigger( count, trigger_handle )
{
	trigger = GetEnt( trigger_handle, "targetname" );
	if( !IsDefined( trigger ) )
	{
		trigger = GetEnt( trigger_handle, "script_noteworthy" );
		if( !IsDefined( trigger ) )
		{
			AssertMsg( "No entity exists with " + trigger_handle + " with targetname or script_noteworthy KVP" );
		}
	}

	trigger thread notify_on_enemy_count( count, "count_reached" );
	trigger waittill_any( "trigger", "count_reached" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_enemy_count_or_flag( count, flag_handle )
{
	assert( flag_exist( flag_handle ) );

	level endon( "count_reached" );

	// issue here if we have multiple instance running on level
	if( !flag( flag_handle ) )
	{
		level thread notify_on_enemy_count( count, "count_reached" );
		flag_wait( flag_handle );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

add_actor_danger_listeners()
{
	self AddAIEventListener( "bulletwhizby" );
	self AddAIEventListener( "gunshot" );
	self AddAIEventListener( "grenade danger" );
	self AddAIEventListener( "explode" );
	self AddAIEventListener( "gunshot_teammate" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_danger()
{
	self add_actor_danger_listeners();

	self waittill( "ai_event" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

waittill_danger_or_trigger( trigger_handle )
{
	self add_actor_danger_listeners();

	self endon( "ai_event" );

	wait_for_targetname_trigger( trigger_handle );

	return true;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

apply_deathtime( death_time )
{
	self endon( "death" );
	wait( death_time );
	wait( randomfloat( 10 ) );
	self kill();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

wait_incremental_nag_timer( timer_array, instant )
{
	if( !IsDefined( timer_array ) )
	{
		timer_array = [];
		if ( IsDefined( instant ) )
		{
			timer_array[ timer_array.size ] = 0.0;
		}
		else
		{
			timer_array[ timer_array.size ] = 5.0;
		}
		timer_array[ timer_array.size ] = 5.0;
		timer_array[ timer_array.size ] = 10.0;
		timer_array[ timer_array.size ] = 15.0;
		timer_array[ timer_array.size ] = 20.0;
		timer_array[ timer_array.size ] = 25.0;
	}

	Assert( 0 < timer_array.size );

	wait( timer_array[ 0 ] );

	if( 1 < timer_array.size ) 
	{
		return array_remove_index( timer_array, 0 );
	}
	else
	{
		return timer_array;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

kill_all_enemies()
{
    enemies = GetAIArray("axis");
    if(IsDefined(enemies))
    {
        foreach(guy in enemies)
        {
            if(isDefined(guy) && isAlive(guy))
            {
                guy kill();
            }
        }
    }
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_enemies_touching_volume( volume_handle )
{
	Assert( IsDefined( volume_handle ) );
	
	volume = GetEnt( volume_handle, "targetname" );
	if( !IsDefined( volume ) )
	{
		volume = GetEnt( volume_handle, "script_noteworthy" );
		if( !IsDefined( volume ) )
		{
			AssertMsg( "No volume exists with " + volume_handle + " with targetname or script_noteworthy KVP" );
		}
	}
	
	enemies = GetAIArray( "axis" );
	enemies = array_removeDead_or_dying( enemies );
	desired_enemies = [];
	
	foreach ( guy in enemies )
	{
		if ( guy IsTouching( volume ) )
		{
			desired_enemies = array_add( desired_enemies, guy );
		}
	}

	return desired_enemies;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

get_enemy_count_touching_volume( volume_handle )
{
	return get_enemies_touching_volume( volume_handle ).size;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notify_on_enemy_count_touching_volume( volume_handle, count, msg )
{
	self endon( "stop_checking_volume" );

	Assert( IsDefined( count ) && IsDefined( msg ) );

	while ( true )
	{
		if ( count >= get_enemies_touching_volume( volume_handle ).size )
		{
			break;
		}

		wait( 0.05 );		// not too sure how expensive checking IsTouching.
	}

	self notify( msg );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

stop_enemy_dialogue()
{
	self waittill( "death" );

	self anim_stopanimscripted();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

stop_enemy_dialogue_on_death_or_trigger( trigger_handle )
{
	self endon( "death" );

	trigger = GetEnt( trigger_handle, "targetname" );
	if( !IsDefined( trigger ) )
	{
		trigger = GetEnt( trigger_handle, "script_noteworthy" );
		if( !IsDefined( trigger ) )
		{
			AssertMsg( "No entity exists with " + trigger_handle + " with targetname or script_noteworthy KVP" );
		}
	}

	self thread stop_enemy_dialogue();

	trigger waittill( "trigger" );

	self anim_stopanimscripted();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

smart_get_nag_line( adjusted, original, index )
{
	if ( 1 < adjusted.size )
	{
		ret = array_remove( adjusted, adjusted[ index ] );
	}
	else
	{
		ret = original;
	}

	return ret;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nag_end_on_notify( nag_handles, msg, instant )
{
	self endon( msg );

	new_handles = [];
	if ( !IsArray( nag_handles ) )
	{
		nag_handles = make_array( nag_handles );
	}
	starting_count = nag_handles.size;
	count = 0;
	index = 0;

	timer_array = wait_incremental_nag_timer( undefined, instant );

	while( true )
	{
		new_handles = smart_get_nag_line( new_handles, nag_handles, index );
		if( count < starting_count )
		{
			index = 0;
		}
		else
		{
			index = RandomIntRange( 0, new_handles.size );
		}
		self smart_dialogue( new_handles[ index ] );
		count++;
		timer_array = wait_incremental_nag_timer( timer_array );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

nag_multiple_end_on_notify( naggers, nag_handles, msg )
{
	self endon( msg );

	if ( !IsArray( naggers ) )
	{
		naggers = make_array( naggers );
	}

	if ( !IsArray( nag_handles ) )
	{
		nag_handles = make_array( nag_handles );
	}

	timer_array = wait_incremental_nag_timer();

	while( true )
	{
		index = RandomInt( nag_handles.size );
		naggers[ index ] smart_dialogue( nag_handles[ index ] );
		timer_array = wait_incremental_nag_timer( timer_array );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notify_on_flag_set( flag_handle, msg )
{
	Assert( IsDefined( flag_handle ) && IsDefined( msg ) );

	flag_wait( flag_handle );

	self notify( msg );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notify_on_flag_open( flag_handle, msg )
{
	Assert( IsDefined( flag_handle ) && IsDefined( msg ) );

	flag_waitopen( flag_handle );

	self notify( msg );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notify_on_function_finish( msg, function, var1, var2, var3 )
{
	if ( !isdefined( var1 ) )
	{
		self [[ function ]]();
	}
	else if ( !isdefined( var2 ) )
	{
		self [[ function ]]( var1 );
	}
	else if ( !isdefined( var3 ) )
	{
		self [[ function ]]( var1, var2 );
	}
	else
	{
		self [[ function ]]( var1, var2, var3 );
	}

	self notify( msg );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_bokehdot_volume( targetname )
{
	ents = GetEntArray( targetname, "targetname" );
	
	foreach( ent in ents )
	{
		ent thread do_bokehdot_volume();
	}
}

do_bokehdot_volume()
{
	// FIX JKU  make sure we stop these when they're no longer needed
	level endon( "swept_away" );
	
	// assert if the volume isn't setup correctly
	AssertEx( IsDefined( self.target ), "flag volume must be linked to a script_struct" );
//	AssertEx( IsDefined( self.script_noteworthy ), "flag volume must have script_noteworthy to define the type, i.e. splash, spray." );
	
	pos_max = getstruct( self.target, "targetname" );

	// assert if the volume isn't setup correctly
	AssertEx( IsDefined( pos_max.target ), "first script_struct must be linked to another." );
	
	pos_min = getstruct( pos_max.target, "targetname" );
	pos_diff = Distance2D( pos_min.origin, pos_max.origin );
	
	// init the bokehdot source
	maps\flood_fx::fx_create_bokehdots_source();
	
	if( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "splash" )
	{
		dividing_line = 0.5;
		while( 1 )
		{
			flag_wait( "do_bokehdot" );
			if( !flag( "cw_player_underwater" ) && level.player IsTouching( self ) )
			{
//				if( RandomInt( 2 ) == 0 )
//					PlayFXOnTag( GetFX( "splash_lens_01" ), level.flood_source_bokehdots, "tag_origin" );
//				else
//					PlayFXOnTag( GetFX( "splash_lens_03" ), level.flood_source_bokehdots, "tag_origin" );
			}

			while( flag( "do_bokehdot" ) && level.player IsTouching( self ) )
			{
				if( Distance2D( level.player.origin, pos_max ) < dividing_line * pos_diff )
				{
					thread maps\flood_fx::fx_turn_on_bokehdots_64_player();
				}
				else
				{
					thread maps\flood_fx::fx_turn_on_bokehdots_16_player();
				}
				wait RandomFloatRange( 1.5, 2.5 );
			}
			waitframe();
		}
	}
//	if( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "stream" )
	else
	{
		dividing_line = 0.33;
		while( 1 )
		{
			flag_wait( "do_bokehdot" );
			if( !flag( "cw_player_underwater" ) && level.player IsTouching( self ) )
			{
//				if( RandomInt( 2 ) == 0 )
//					PlayFXOnTag( GetFX( "splash_lens_01" ), level.flood_source_bokehdots, "tag_origin" );
//				else
//					PlayFXOnTag( GetFX( "splash_lens_03" ), level.flood_source_bokehdots, "tag_origin" );
			}
			
			if( !IsDefined( self.waterdrops_once ) && level.player IsTouching( self ) )
			{
				self.waterdrops_once = true;
				thread maps\flood_fx::fx_waterdrops_20_inst();
			}
			
			while( flag( "do_bokehdot" ) && level.player IsTouching( self ) )
			{
	//			IPrintLn( Distance2D( level.player.origin, pos_max ) );
				if( Distance2D( level.player.origin, pos_max.origin ) < dividing_line * pos_diff )
				{
	//				IPrintLn( "66" );
					thread maps\flood_fx::fx_bokehdots_close();
					wait RandomFloatRange( 0.25, 0.5 );
				}
				else if( Distance2D( level.player.origin, pos_max.origin ) < ( dividing_line * 2 ) * pos_diff )
				{
	//				IPrintLn( "3366" );
					thread maps\flood_fx::fx_bokehdots_close();
					wait RandomFloatRange( 0.25, 0.5 );
				}
				else
				{
	//				IPrintLn( "33" );
					thread maps\flood_fx::fx_bokehdots_far();
					wait RandomFloatRange( 0.5, 1 );
				}
	//			IPrintLn( "nothing" );
				waitframe();
			}
			self.waterdrops_once = undefined;
			waitframe();
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
RUMBLE_FRAMES_PER_SEC = 10;
earthquake_w_fade( scale, duration, fade_in, fade_out )
{
	self notify( "earthquake_end" );
	self endon( "earthquake_end" );

	if ( !isdefined( fade_in ) )
	{
		fade_in = 0;
	}
	if ( !isdefined( fade_out ) )
	{
		fade_out = 0;
	}

	assert( ( fade_in + fade_out ) <= duration );

	frame_count = duration * RUMBLE_FRAMES_PER_SEC;
	fade_in_frame_count = fade_in * RUMBLE_FRAMES_PER_SEC;
	if ( fade_in_frame_count > 0 )
	{
		fade_in_scale_step = scale / fade_in_frame_count;
	}
	else
	{
		fade_in_scale_step = scale;
	}

	fade_out_frame_count = fade_out * RUMBLE_FRAMES_PER_SEC;
	fade_out_start_frame = frame_count - fade_out_frame_count;
	if ( fade_out_frame_count > 0 )
	{
		fade_out_scale_step = scale / fade_out_frame_count;
	}
	else
	{
		fade_out_scale_step = scale;
	}

	delay = 1 / RUMBLE_FRAMES_PER_SEC;
	scale = 0;
	for ( i = 0; i < frame_count; i++ )
	{
		if ( i <= fade_in_frame_count )
		{
			scale += fade_in_scale_step;
		}

		if ( i > fade_out_start_frame )
		{
			scale -= fade_out_scale_step;
		}

		earthquake( scale, delay, self.origin, 500 );
		wait delay;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notify_on_actor_distance_to_goal( goal, radius, msg )
{
	self endon( "death" );

	while( true )
	{
		if ( radius > Distance2D( goal, self.origin ) )
		{
			self notify( msg );
			break;
		}
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

play_nag( nags, flag, initial_time, max_time, steps, multiplier, notification, anims )
{
	self endon( "death" );
	self endon( "stop nags" );
	
	if( IsDefined( notification ) )
	{
		self endon( notification );
	}
	
	time = initial_time;

	// FIX DK need to fix param location for this to be valid
	if( !IsDefined( max_time ) )
	{
		max_time = 30;
	}
	
	nag_number = 0;
	old_nag_number = 1;
	cur_step = 0;
	
	while( !flag( flag ) )
	{
		nag_number = RandomInt( nags.size );
		
		if( nags.size > 1 )
		{
			while( old_nag_number == nag_number )
			{
				nag_number = RandomInt( nags.size );
				wait( 0.05 );
			}
		}
		
		old_nag_number = nag_number;
		
		nag = nags[ nag_number ];
		
		if( IsDefined( anims ) )
		{
			anim_to_play = anims[ RandomInt( anims.size ) ];
			// FIX JKU change to use anim generic so the animname doesn't matter???
			// FIX DK YES!
			self thread maps\_anim::anim_single_solo( self, anim_to_play );
		}
		
		// Protect against unwanted play due to delay introduced above
		if( !flag( flag ) )
		{
			level notify("nagging");
			self dialogue_queue( nag );
		}
		else
		{
			break;
		}
		
		wait RandomFloatRange( ( time * 0.8 ), ( time * 1.2 ) );
		
		if( max_time > time )
		{
			cur_step += 1;
			
			if( cur_step == steps )
			{
				cur_step = 0;
				time *= multiplier;
				
				if( max_time < time )
				{
					time = max_time;
				}
			}
		}
	}
}

push_player( state )
{
	if( !IsDefined( state ) )
		state = true;
	
	self PushPlayer( state );
}

flag_set_delayed( message, delay )
{
	delayThread( delay, ::flag_set, message, undefined );
}

// pass this the targetname of the struct you want to move to and wait
block_until_at_struct( next_node, goalradius )
{
	self endon( "death" );
	
	if( IsDefined( goalradius ) )
	{
		if( goalradius == 666 )
			self.goalradius = 88;
		else
			self.goalradius = goalradius;
	}
	
//	IPrintLn( self.script_friendname + " " + self.goalradius + " " + next_node.targetname );
	// FIX JKU evaluate what this does and see if it can be used to fix large goal radius problems
//	self.goalradius = 0;
//	self.stopAnimDistSq = squared( 64 );	// get a "stop_soon" notify when within this distance to goal, but don't slow down

	self SetGoalPos( next_node.origin );
	self.flood_current_goalnode = next_node.targetname;
	self waittill( "goal" );
	next_node = getstruct( next_node.target, "targetname" );
	return( next_node );
}

bullet_trace_debug( start_pos, end_pos, hit_character, color, time, do_debug )
{
	if( !IsDefined( hit_character ) )
		hit_character = false;
	
	if( !IsDefined( color ) )
		color = "white";
	
	if( !IsDefined( time ) )
		time = 1000;
	
	switch( color )
	{
		case "white":
			color = ( 255, 255, 255 );
			break;
		case "red":
			color = ( 255, 0, 0 );
			break;
		case "green":
			color = ( 0, 255, 0 );
			break;
		case "blue":
			color = ( 0, 0, 255 );
			break;
		default:
			break;
	}
	
	if( do_debug )
		line( start_pos, end_pos, color, 1, false, time );
	
	trace = BulletTrace( start_pos, end_pos, hit_character );
	return trace;
}

spawn_and_link_models_to_tags( targetname )
{
	num_tags = GetNumParts( self.model );
	for( i = 0; i < num_tags; i++ )
	{
		tag_name = GetPartName( self.model, i );

		if( GetSubStr( tag_name, 0, 4 ) == "mdl_" )
		{
			// the tag should be named mdl_<xmodel name>_xxx where xxx is a number reference like 001
			part_name = GetSubStr( tag_name, 4, tag_name.size - 4 );
			mdl = Spawn( "script_model", self GetTagOrigin( tag_name ) );
			mdl SetModel( part_name );
			mdl.angles = self GetTagAngles( tag_name );
			mdl LinkTo( self, tag_name );
			
			if( IsDefined( targetname ) )
				mdl.targetname = targetname;
		}
		
		// wait at least a frame so we don't slam the texture streaming or cause a hitch
		// but I wonder how bad the hitch would be and maybe I should spawn all the same named things at once or in batches?
		waitframe();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


kill_grenades()
{
	water_kill_vols = GetEntArray( "trigger_water_death", "targetname" );
	
	foreach( vol in water_kill_vols )
		vol thread grenade_kill();
}

grenade_kill()
{
	while( 1 )
	{
		grenades = GetEntArray( "grenade", "classname" );
		foreach( grenade in grenades )
		{
			if( grenade IsTouching( self ) )
			{
				JKUprint( "grenade killed" );
				grenade Delete();
				break;
			}
		}
		waitframe();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

synctransients_safe( ffname )
{
	if ( !istransientqueued( ffname ) )
	{
         // Does there exist a function which is a 'hard error' in dev builds, and compiles-to-nothing for ship builds?
		PrintLn( "Expected transient " + ffname + " was not preloaded!" );
		unloadalltransients();
		loadtransient( ffname );
		while ( !synctransients() )
		{
			wait 0.05;
	}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_palm_trees_in_rushing_water()
{		
	// this wait needs to be here to give time for the trees to be setup apparently
	waitframe();
	
	ents = GetEntArray( "palm_tree_in_rushing_water", "script_noteworthy" );
	
	foreach( ent in ents )
	{
		windrate = 1 + RandomFloat( 0.4 );
		ent SetAnimKnobRestart( level.anim_prop_models[ ent.model ][ "flood" ], 1, 0, windrate );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_water_movement( percent, time )
{
	player_speed_percent( percent, time );

	player_bob_scale_set( 1.0 / ( percent * 0.01 ), time );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// this will be the fire and forget method
play_fullscreen_splash_cinematic( bink )
{
	level.player thread play_splash_on_activate();

	while( true )
	{
		flag_wait( "pip_flag" );

		hud_elem			  = NewHudElem();
		//hud_elem.x			  = 450;
		//hud_elem.y			  = 47;
		hud_elem.horzAlign	  = "fullscreen";
		hud_elem.vertAlign	  = "fullscreen";
		//hud_elem.foreground = true;
		hud_elem.sort		  = -1; // trying to be behind introscreen_generic_black_fade_in
		hud_elem SetShader( "cinematic", 512, 512 );
		hud_elem.alpha = 0.0;

		CinematicInGame( bink );
		while ( IsCinematicPlaying() )
		{
			wait ( 0.05 );
		}

		hud_elem Destroy();

		flag_clear( "pip_flag" );
	}
}

play_splash_on_activate()
{
	while( true )
	{
		while( !self UseButtonPressed() )
		{
			wait( 0.05 );
		}
		
		flag_set( "pip_flag" );
		flag_waitopen( "pip_flag" );
	}
}

JKUprint( msg )
{
	if( IsDefined( level.JKUdebug ) && level.JKUdebug )
	{
		IPrintLn( msg );
	}
}

