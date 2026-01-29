#include maps\_utility;
#include common_scripts\utility;
#include maps\loki_util;
#include maps\_vehicle;
#include maps\_anim;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	add_hint_string( "pickup_gun", &"LOKI_IN_YOUR_FACE", ::stop_in_your_face_hint );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PreCacheItem( "kriss_eotech_space" );
	PreCacheString( &"LOKI_IN_YOUR_FACE" );
	PreCacheString( &"LOKI_IN_YOUR_FACE_FAIL" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "moving_cover_done" );
	flag_init( "gun_picked_up" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

moving_cover_start()
{
	player_move_to_checkpoint_start( "moving_cover" );
	spawn_allies();

	array_spawn_function( GetSpawnerTeamArray( "axis" ), ::enemy_marker );
	
	level.allies[ 0 ] set_force_color( "r" );
	level.allies[ 1 ] set_force_color( "g" );
	level.allies[ 2 ] set_force_color( "b" );
	
	foreach( ally in level.allies )
		ally thread maps\_space_ai::handle_angled_nodes();
	
	level.player FreezeControls( true );
	level.player DisableWeapons();
	level.player HideViewModel();
	level.player TakeAllWeapons();
	
	player_rig   = spawn_anim_model( "player_rig" );
	player_legs  = spawn_anim_model( "player_legs" );
	in_your_face = spawn_anim_model( "in_your_face" );

	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 15, 15, 15, 15, 1 );
	
	level.explosion_parts					= [];
	level.explosion_parts[ "player_rig"	  ] = player_rig;
	level.explosion_parts[ "player_legs"  ] = player_legs;
	level.explosion_parts[ "in_your_face" ] = in_your_face;

//	in_your_face_start = getstruct( "in_your_face_start", "targetname" );
//
//	in_your_face = Spawn( "script_model", ( -96466, 89517.3, 92066.1 ) );
//	in_your_face.angles = ( 0, 270, 416.5 );
//	in_your_face SetModel( "fed_space_assault_body" );
//	level.in_your_face = in_your_face;
//
//	pos_offset = ( 25, -38, -26 );  // distance, it's +up -down, it's -left +right
//	angles_offset = in_your_face.angles * ( 1, 0.6667, 1 );
//	in_your_face LinkToPlayerView( level.player, "tag_origin", pos_offset, angles_offset, false );
	
	ents = GetEntArray( "destructible_toy", "targetname" );
//	foreach( ent in ents )
//		RadiusDamage( ent.origin, 1, 111, 111 );
}

moving_cover()
{
	autosave_by_name_silent( "moving_cover" );
	
	level.allow_movement = true;
	
//	level thread node_test();
	level thread moving_cover_main();
	
	level.ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level.player playerSetGroundReferenceEnt( level.ground_ref_ent );
	
// MM moving cover test!!!!!!!!!!!!!!
	level thread maps\loki_combat_two::trigger_wave_3_during_moving_cover();
	
	flag_wait( "moving_cover_done" );
}

moving_cover_main()
{
	node = GetEnt( "explosion_node2", "targetname" );
	ally_0_start_node = getstruct( "moving_cover_ally_0", "targetname" );
	ally_1_start_node = getstruct( "moving_cover_ally_1", "targetname" );
	ally_2_start_node = getstruct( "moving_cover_ally_2", "targetname" );
	ally_0_end_node	  = getstruct( "combat_two_ally_0", "targetname" );
	ally_1_end_node	  = getstruct( "combat_two_ally_1", "targetname" );
	ally_2_end_node	  = getstruct( "combat_two_ally_2", "targetname" );

	level thread start_moving_cover( "post_object_", 1, 45 );
	level thread start_moving_cover3( "post_object_new_", 1, 45 );
	
	level.allies[ 0 ] ForceTeleport( ally_0_start_node.origin, ally_0_start_node.angles );
	level.allies[ 1 ] ForceTeleport( ally_1_start_node.origin, ally_1_start_node.angles );
	level.allies[ 2 ] ForceTeleport( ally_2_start_node.origin, ally_2_start_node.angles );
	
	level.allies[ 0 ] SetGoalPos( ally_0_end_node.origin );
	level.allies[ 1 ] SetGoalPos( ally_1_end_node.origin );
	level.allies[ 2 ] SetGoalPos( ally_2_end_node.origin );
	
	ais = spawn_space_ais_from_targetname( "enemy_moving_cover_final" );
	foreach( ai in ais )
	{
		ai.maxfaceenemydist = 99999;
		ai.goalradius = 64;
//		ai disable_arrivals();
//		ai.moveplaybackrate  = 1.5;
		ai.baseaccuracy = 0.0;
		
		ai_target_target = ai get_target_ent();
		ai_target_target = ( ai_target_target get_all_target_ents() )[ 0 ];
		ai thread ai_follow_cover( ai_target_target, 200 );
		ai delayThread( 4, ::ramp_up_accurracy, 4, 0.5 );
	}

	node anim_single( level.explosion_parts, "explosion_part2" );

	level.explosion_parts[ "player_rig" ] Delete();
	level.explosion_parts[ "player_legs" ] Delete();
	level.player Unlink();
	level.player FreezeControls( false );
	level.player EnableWeapons();
	level.player ShowViewModel();
	
	level.player GiveWeapon( "kriss_eotech_space" );
	level.player SwitchToWeapon( "kriss_eotech_space" );
	level.player GiveMaxAmmo("kriss_eotech_space");

	level thread set_current( 5000, 15 );
	
	flag_wait( "stop_explosion_push" );
	
	JKUprint( "push stop" );
	SetSavedDvar( "player_swimWaterCurrent", ( 0, 0, 0 ) );
//	Objective_Add( 1, "current", "reach ally for repairs", ally_helper.origin );
}

moving_cover_main_old()
{
	objective_tele	  = getstruct( "objective_tele", "targetname" );
	ally_helper		  = getstruct( "combat_two_ally_0", "targetname" );
	ally_0_start_node = getstruct( "moving_cover_ally_0", "targetname" );
	ally_1_start_node = getstruct( "moving_cover_ally_1", "targetname" );
	ally_2_start_node = getstruct( "moving_cover_ally_2", "targetname" );
	ally_0_end_node	  = getstruct( "combat_two_ally_0", "targetname" );
	ally_1_end_node	  = getstruct( "combat_two_ally_1", "targetname" );
	ally_2_end_node	  = getstruct( "combat_two_ally_2", "targetname" );
	
	level.player display_hint( "pickup_gun" );
//	level thread in_your_face();
	wait_for_x_pressed();	
	
	level.allies[ 0 ] ForceTeleport( ally_0_start_node.origin, ally_0_start_node.angles );
	level.allies[ 1 ] ForceTeleport( ally_1_start_node.origin, ally_1_start_node.angles );
	level.allies[ 2 ] ForceTeleport( ally_2_start_node.origin, ally_2_start_node.angles );
	
	level.allies[ 0 ] SetGoalPos( ally_0_end_node.origin );
	level.allies[ 1 ] SetGoalPos( ally_1_end_node.origin );
	level.allies[ 2 ] SetGoalPos( ally_2_end_node.origin );

	level thread lerp_fov_overtime( 1, 65 );
	PlayFX( getfx( "explosion" ), objective_tele.origin );
	Earthquake( 1, 1, level.player.origin, 1600 );

	level.in_your_face UnlinkFromPlayerView( level.player );
	level.in_your_face notify( "stop_loop" );
	level.in_your_face delayCall( 0.5, ::RotateVelocity, ( 5, 10, 2 ), 9999 );
	
	level thread set_current( 5000, 15 );	
//	SetSavedDvar( "player_swimWaterCurrent", ( 4000, 0, 0 ) );
//	level.player SetVelocity( AnglesToForward( player_tele_node.angles ) * -150 );

//	player_vehicle = spawn_vehicle_from_targetname_and_drive( "player_vehicle" );
//	mover.origin = player_vehicle.origin;
//	mover.angles = player_vehicle.angles * ( 1, -1, 1 );
//	mover LinkTo( player_vehicle );

//	level.player SetPlayerAngles( level.player.angles + ( 0, 180, 0 ) );
//	level.player PlayerLinkToDelta( mover, "tag_origin", 1, 360, 360, 64, 64, false );
//	level thread movement_input_think( mover, player_vehicle );

//	in_your_face_mover Show();
//	in_your_face_mover.origin = player_vehicle.origin;
//	in_your_face_mover.angles = player_vehicle.angles;
	
	level thread start_moving_cover( "post_object_", 1, 45 );
	level thread start_moving_cover3( "post_object_new_", 1, 45 );
	
	ais = spawn_space_ais_from_targetname( "enemy_moving_cover_final" );
	foreach( ai in ais )
	{
		ai.maxfaceenemydist = 99999;
		ai.goalradius = 64;
//		ai disable_arrivals();
//		ai.moveplaybackrate  = 1.5;
		ai.baseaccuracy = 0.0;
		
		ai_target_target = ai get_target_ent();
		ai_target_target = ( ai_target_target get_all_target_ents() )[ 0 ];
		ai thread ai_follow_cover( ai_target_target, 200 );
		ai delayThread( 1, ::ramp_up_accurracy, 4, 0.5 );
	}

	level thread notify_delay( "stop_explosions", 6 );
	
	level.player FreezeControls( false );
	level.player EnableWeapons();
	level.player ShowViewModel();
	
	flag_wait( "stop_explosion_push" );
	
	JKUprint( "push stop" );
	
	level.player DisableInvulnerability();
	SetSavedDvar( "player_swimWaterCurrent", ( 0, 0, 0 ) );

	Objective_Add( 1, "current", "reach ally for repairs", ally_helper.origin );
}

set_current( rate, time )
{
	level.player endon( "death" );
	level endon( "stop_explosion_push" );
	
	time = time * 1000;
	server_frames = time / 50;
	step_amount = rate / server_frames;
	
	for( i = 0; i < server_frames; i++ )
	{
		SetSavedDvar( "player_swimWaterCurrent", ( rate, 0, 0 ) );
		rate -= step_amount;
		waitframe();
	}
	
	IPrintLn( "push stopped" );
}

ramp_up_accurracy( time, final_accuracy )
{
	self endon( "death" );

	time = time * 1000;
	server_frames = time / 50;
	step_amount = ( final_accuracy - self.baseaccuracy ) / server_frames;
	
	wait 3;
	
	for( i = 0; i < server_frames; i++ )
	{
		self.baseaccuracy += step_amount;
		waitframe();
	}
	
	self.baseaccuracy = final_accuracy;
	
//	IPrintLn( self.baseaccuracy );
	IPrintLn( "accuracy 1" );
}

stop_in_your_face_hint()
{
	if( flag( "gun_picked_up" ) )
		return true;
	else
		return false;
}

in_your_face()
{
	level.player endon( "death" );
	level endon( "gun_picked_up" );
	
	while( 1 )
	{
//		JKUprint( level.player.health );
		forward = AnglesToForward( level.player.angles );
		rnd_pos_infront = ( level.player.origin + ( 15 * forward ) ) + ( RandomFloatRange( -10, 10 ), RandomFloatRange( -10, 10 ), 55 );
		MagicBullet( "kriss_eotech_space", rnd_pos_infront, level.player.origin );
		setDvar( "ui_deadquote", &"LOKI_IN_YOUR_FACE_FAIL" );
		
		wait RandomFloatRange( 1, 2 );
	}
}

wait_for_x_pressed()
{
	level.player endon( "death" );
	
	count = 0;
	press_time = 5;
	while( !( count > press_time ) )
	{
		count = 0;
		while( level.player UseButtonPressed() )
		{
			if( count > press_time )
				break;
			
			count += 1;
			waitframe();
		}
		waitframe();
	}

	flag_set( "gun_picked_up" );
//	level.player EnableInvulnerability();
	level.player GiveWeapon( "kriss_eotech_space" );
	level.player SwitchToWeapon( "kriss_eotech_space" );
	level.player GiveMaxAmmo("kriss_eotech_space");
}

start_moving_cover( prefix, count, time )
{
	debris_col = GetEntArray( "explosion_debris_col", "targetname" );
	foreach( col in debris_col )
		col LinkTo( col get_target_ent() );
	
//	disconnect_nodes = GetNodeArray( "explosion_disconnect_node", "targetname" );
//	foreach( node in disconnect_nodes )
//		node DisconnectNode();

	debris_wave_count = count;
	
	for( i = 1; i <= debris_wave_count; i++ )
	{
		debris = GetEntArray( prefix + i, "script_noteworthy" );
		
		foreach( debri in debris )
		{
//			AssertEx( IsDefined( debri.script_linkto ), "Object at, " + debri.origin + " has no script_linkto defined." );
			
			debri MoveTo( ( debri getstruct( debri.target, "targetname" ) ).origin, time );
			debri RotateVelocity( ( RandomFloatRange( -5, 5 ), 0, RandomFloatRange( -5, 5 ) ), 999 );
//			wait RandomFloatRange( 0.0, 0.25 );
		}
	}
}

start_moving_cover3( prefix, count, time )
{
//	disconnect_nodes = GetNodeArray( "explosion_disconnect_node", "targetname" );
//	foreach( node in disconnect_nodes )
//		node DisconnectNode();

	debris_wave_count = count;
	
	for( i = 1; i <= debris_wave_count; i++ )
	{
		debris = GetEntArray( prefix + i, "script_noteworthy" );
		
		foreach( debri in debris )
		{
			AssertEx( IsDefined( debri.script_linkto ), "Object at, " + debri.origin + " has no script_linkto defined." );
			linked_ent = GetEnt( debri.script_linkto, "targetname" );
			debri LinkTo( linked_ent );
		}
		
			
		// second loop to move and rotate them after they've all been linked up
		foreach( debri in debris )
		{
			linked_ent = GetEnt( debri.script_linkto, "targetname" );
			linked_ent MoveTo( ( linked_ent getstruct( linked_ent.target, "targetname" ) ).origin, time );
			linked_ent RotateVelocity( ( RandomFloatRange( -5, 5 ), 0, RandomFloatRange( -5, 5 ) ), 999 );
		}
	}
}

node_test()
{
	node = GetNode( "node_test", "targetname" );
	while( 1 )
	{
		JKUline( node.origin + ( -12, 0, 0 ), node.origin + ( 12, 0, 0 ) );
		JKUline( node.origin + ( 0, -12, 0 ), node.origin + ( 0, 12, 0 ) );
		JKUline( node.origin + ( 0, 0, -12 ), node.origin + ( 0, 0, 12 ) );
		waitframe();
	}
}

ai_follow_cover( cover, ignore_dist )
{
	self endon( "death" );
	self endon("stop_follow_cover");

	cover_ai_start_offset = cover.origin - self.origin;
	
	while( 1 )
	{
		goal_pos = cover.origin - cover_ai_start_offset;
		self SetGoalPos( goal_pos );
		
		if( BulletTracePassed( self.origin, goal_pos, false, undefined) )
			JKUline( self.origin, goal_pos );
		else
			JKUline( self.origin, goal_pos, ( 1, 0, 0 ) );
		
		if( Distance2D( self.origin, goal_pos ) < ignore_dist - 50 )
		{
			self.ignoreall = 0;
			JKUline( goal_pos + ( -12, 0, 0 ), goal_pos + ( 12, 0, 0 ) );
			JKUline( goal_pos + ( 0, -12, 0 ), goal_pos + ( 0, 12, 0 ) );
			JKUline( goal_pos + ( 0, 0, -12 ), goal_pos + ( 0, 0, 12 ) );
		}
		else
		{
			self.ignoreall = 1;
			JKUline( goal_pos + ( -12, 0, 0 ), goal_pos + ( 12, 0, 0 ), ( 1, 0, 0 ) );
			JKUline( goal_pos + ( 0, -12, 0 ), goal_pos + ( 0, 12, 0 ), ( 1, 0, 0 ) );
			JKUline( goal_pos + ( 0, 0, -12 ), goal_pos + ( 0, 0, 12 ), ( 1, 0, 0 ) );
		}
		
		waitframe();
	}
}

HELPLESS_SCALAR_ACCEL_PERCENTAGE = 0.05;
HELPLESS_SCALAR_DECEL_PERCENTAGE = 0.01;
HELPLESS_LEASH_LENGTH = 360;
HELPLESS_TOP_SPEED = 2;
HELPLESS_LOOK_SPEED_SCALAR = 6;

movement_input_think( mover, player_vehicle )
{
	level.player endon( "death" );
	level endon( "swept_take_control" );

	while( 1 )
	{
		analog_input = level.player GetNormalizedMovement();
		last_analog_input = ( analog_input[ 1 ], analog_input[ 0 ], analog_input[ 2 ] );
		JKUprint( analog_input );
//		JKUdebug_line( mover.origin, mover.origin + ( analog_input[ 1 ], analog_input[ 0 ], 0 ) * 100, ( 1, 0, 0 ) );
//		JKUdebug_line( mover.origin, mover.origin + AnglesToForward( mover.angles ) * ( analog_input[ 1 ], analog_input[ 0 ], 0 ) * 100, ( 0, 1, 0 ) );
		pos = ( AnglesToRight( mover.angles ) * ( analog_input[ 1 ] * 100 ) );
		pos1 = ( AnglesToForward( mover.angles ) * ( analog_input[ 0 ] * 100 ) );
		JKUline( mover.origin, mover.origin + ( pos + pos1 ), ( 0, 1, 1 ) );
		JKUline( mover.origin, mover.origin + AnglesToUp( mover.angles ) * 100, ( 0, 0, 1 ) );

		if( level.allow_movement )
		{
			movement_scalar = HELPLESS_SCALAR_ACCEL_PERCENTAGE;
			while( Length( analog_input ) > 0.1 )
			{
				pos = ( AnglesToRight( mover.angles ) * ( analog_input[ 1 ] * 100 ) );
				pos1 = ( AnglesToForward( mover.angles ) * ( analog_input[ 0 ] * 100 ) );
				JKUline( mover.origin, mover.origin + ( pos + pos1 ), ( 0, 1, 1 ) );
				
				stick_percentage = Length( analog_input );
				if( stick_percentage > 1 )
				{
					stick_percentage = 1;
				}
				
				posr = ( AnglesToRight( mover.angles ) * ( analog_input[ 1 ] * ( ( movement_scalar * HELPLESS_TOP_SPEED ) * stick_percentage ) ) );
				posf = ( AnglesToForward( mover.angles ) * ( analog_input[ 0 ] * ( ( movement_scalar * HELPLESS_TOP_SPEED ) * stick_percentage ) ) );

				new_pos = mover.origin + posr;
				// use this if we want to allow you to move forwards and backl
//				new_pos = mover.origin + ( posr + posf );

//				IPrintLn( analog_input );
//				IPrintLn( "foo " + Distance2D( new_pos, player_vehicle.origin ) );
				
				if( Distance2D( new_pos, player_vehicle.origin ) <= HELPLESS_LEASH_LENGTH )
				{
					mover.origin = new_pos;
					mover LinkTo( player_vehicle, "tag_player" );
				}
				else
				{
					IPrintLn( "max distance reached" );
				}
				
				if( movement_scalar != 1 )
					movement_scalar += HELPLESS_SCALAR_ACCEL_PERCENTAGE;

//				JKUprint( movement_scalar );
				
				waitframe();

				last_analog_input = posr;
				// use this if we want to allow you to move forwards and backl
//				last_analog_input = ( posr + posf );
				analog_input = level.player GetNormalizedMovement();
			}
			while( movement_scalar != HELPLESS_SCALAR_DECEL_PERCENTAGE && Length( analog_input ) < 0.1 )
			{
				if( movement_scalar != HELPLESS_SCALAR_DECEL_PERCENTAGE )
					movement_scalar -= HELPLESS_SCALAR_DECEL_PERCENTAGE;
				
//				JKUprint( movement_scalar );
				
				new_pos = mover.origin + ( last_analog_input * ( movement_scalar * HELPLESS_TOP_SPEED ) );

				if( Distance2D( new_pos, player_vehicle.origin ) <= HELPLESS_LEASH_LENGTH )
				{
					mover.origin = new_pos;
					mover LinkTo( player_vehicle, "tag_player" );
				}
				
				waitframe();
				analog_input = level.player GetNormalizedMovement();
			}
		}
		waitframe();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
