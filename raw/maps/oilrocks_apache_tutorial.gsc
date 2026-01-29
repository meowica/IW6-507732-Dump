#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\oilrocks_apache_vo;
#include maps\_hud_util;

start()
{
	apache_player = spawn_apache_player( "apache_tutorial_fly" ); //, 10000, 0 );
	
	spawn_blackhawk_ally( "struct_blackhawk_ally_fly_in" );
	spawn_apache_allies( "struct_apache_ally_fly_in_0" );
	
	// Make the chopper not pitch to prevent the cockpit
	// from pitching down when the player grabs control
	// during the fly in
	SetSavedDvar( "vehHelicopterMaxPitch"	, 6.0 );
	SetSavedDvar( "vehHelicopterPitchOffset", apache_player.heli.pitch_offset_air );
}

main()
{
	thread apache_mission_vo_think( ::apache_mission_vo_tutorial );
	thread maps\oilrocks_apache_hints::apache_hints_tutorial();
	flag_wait( "introscreen_complete" );
	
	thread apache_tutorial_fly_allies();
	thread apache_tutorial_fly_move_until_input();
	thread apache_tutorial_fly_player_pitch_think();
	flag_wait( "FLAG_apache_tut_fly_finished" );
}

apache_tutorial_fly_player_pitch_think()
{
	apache_player = get_apache_player();
	owner		  = apache_player.heli.owner;
	
	owner endon( "death" );
	
	flag_wait( "FLAG_apache_tut_fly_half" );
	
	// Increase pitch range
	thread lerp_savedDvar( "vehHelicopterMaxPitch", apache_player.heli.pitch_max, 6.0 );
}

CONST_INTRO_ALLIES_SPEED_BEFORE_INPUT_PLAYER = 90;
CONST_INTRO_ALLIES_SPEED					 = 90;
CONST_INTRO_ALLIES_ACCEL					 = 35;
CONST_INTRO_ALLIES_DECEL					 = 35;
CONST_INTRO_ALLIES_SPEED_MAX				 = 120;
CONST_INTRO_ALLIES_SPEED_MIN				 = 40;
CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX		 = 4800;
CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX_STOP	 = CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX + 3600;
CONST_INTRO_ALLIES_DIST_PLAYER_2D_MIN		 = 1800;
CONST_INTRO_PLAYER_SPEED_BEFORE_INPUT_PLAYER = 90;

apache_tutorial_fly_allies()
{
	// Put allies on their respective paths
	chopper_allies = array_combine( get_apache_allies(), [ get_blackhawk_ally() ] );
	foreach ( chopper in chopper_allies )
	{
		struct = undefined;
		if ( IsSubStr( chopper.targetname, "apache" ) )
			struct = getstruct( "apache_ally_fly_in_path_0" + chopper get_apache_ally_id(), "targetname" );
		else
			struct = getstruct( "blackhaw_fly_in_path", "targetname" );
		
		chopper thread vehicle_paths( struct );
	}
	
	// Give the allies a shot in the butt to get them to speed instantly (accel rate)
	array_call( chopper_allies, ::Vehicle_SetSpeedImmediate, CONST_INTRO_ALLIES_SPEED_BEFORE_INPUT_PLAYER, CONST_INTRO_ALLIES_SPEED_BEFORE_INPUT_PLAYER );
	
	// Wait then adjust the allies accel rate so their movement is smooth from
	// struct to struct
	wait 0.1;
	array_call( chopper_allies, ::Vehicle_SetSpeed, CONST_INTRO_ALLIES_SPEED_BEFORE_INPUT_PLAYER, CONST_INTRO_ALLIES_ACCEL, CONST_INTRO_ALLIES_DECEL );
	
	flag_wait( "FLAG_apache_tut_fly_stop_auto_pilot" );
	
	array_call( chopper_allies, ::Vehicle_SetSpeed, CONST_INTRO_ALLIES_SPEED, CONST_INTRO_ALLIES_ACCEL, CONST_INTRO_ALLIES_DECEL );
	
	thread apache_tutorial_fly_allies_govern_speed( chopper_allies );
}

apache_tutorial_fly_allies_govern_speed( chopper_allies )
{
	level endon( "FLAG_apache_tut_fly_finished" );
	
	thread apache_tutorial_fly_allies_govern_speed_stop( chopper_allies, "FLAG_apache_tut_fly_finished" );
	
	// Update ally speed through canyon relative to the player
	apache_player = get_apache_player();
	
	dist_2d_sqrd_max_stop	= squared( CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX_STOP );
	dist_2d_sqrd_max		= squared( CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX );
	dist_2d_sqrd_min		= squared( CONST_INTRO_ALLIES_DIST_PLAYER_2D_MIN );
	dist_2d_sqrd_range_diff = dist_2d_sqrd_max - dist_2d_sqrd_min;
	
	AssertEx( dist_2d_sqrd_range_diff > 0, "The difference between the max range and the min distance evaluation should always be positive." );
	
	update_delay = 0.25;
	
	speed_prev = undefined;
	while ( 1 )
	{
		dist_2d_sqrd_closest = undefined;
		foreach ( ally in chopper_allies )
		{
			if ( !IsDefined( dist_2d_sqrd_closest ) )
			{
				dist_2d_sqrd_closest = Distance2DSquared( apache_player.origin, ally.origin );
			}
			else
			{
				dist_2d_sqrd_compare = Distance2DSquared( apache_player.origin, ally.origin );
				if ( dist_2d_sqrd_compare < dist_2d_sqrd_closest )
				{
					dist_2d_sqrd_closest = dist_2d_sqrd_compare;
				}
			}
		}
		
		speed = undefined;
	
		// If the allies are really far tell them to stop and wait (speed of 1)
		if ( dist_2d_sqrd_closest >= dist_2d_sqrd_max_stop )
		{
			speed = 0;
		}
		else
		{
			dist_2d_sqrd = clamp( dist_2d_sqrd_closest, dist_2d_sqrd_min, dist_2d_sqrd_max );
			
			// Ratio is subtracted from 1 because the closer the player the faster
			// the choppers need to go
			ratio = 1 - ( dist_2d_sqrd - dist_2d_sqrd_min ) / dist_2d_sqrd_range_diff;
			
			speed = CONST_INTRO_ALLIES_SPEED_MIN + ( CONST_INTRO_ALLIES_SPEED_MAX - CONST_INTRO_ALLIES_SPEED_MIN ) * ratio;
		}
		
		// Adjust the chopper speed only if there was an N% change in speed
		if ( !IsDefined( speed_prev ) || abs( speed - speed_prev ) / max( speed_prev, 0.001 ) > 0.1 )
		{
			array_call( chopper_allies, ::Vehicle_SetSpeed, speed, CONST_INTRO_ALLIES_ACCEL, CONST_INTRO_ALLIES_DECEL );
			speed_prev = speed;
		}
		
		wait update_delay;
	}
}

apache_tutorial_fly_allies_govern_speed_stop( chopper_allies, flag_stop )
{
	flag_wait( flag_stop );
	array_call( chopper_allies, ::ResumeSpeed, CONST_INTRO_ALLIES_ACCEL );
}

apache_tutorial_fly_move_until_input( apache_player )
{
	apache_player = get_apache_player();
	owner		  = apache_player.heli.owner;
	
	owner endon( "death" );
	
	// Move Down Input
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "+toggleads_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "+speed_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "+speed" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "+ads_akimbo_accessible" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "-toggleads_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "-speed_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "-speed" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "-ads_akimbo_accessible" );
	
	// Move Up
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "+smoke" );
	owner NotifyOnPlayerCommand( "LISTEN_heli_movement_input", "-smoke" );
	
	thread apache_owner_notify_on_input_camera( apache_player, "LISTEN_heli_movement_input" );
	thread apache_owner_notify_on_input_move( apache_player, "LISTEN_heli_movement_input" );
	thread apache_move_until_notify( apache_player, CONST_INTRO_PLAYER_SPEED_BEFORE_INPUT_PLAYER, "LISTEN_heli_movement_input", "FLAG_apache_tut_fly_stop_auto_pilot" );
	
	// Once input occurs make sure the auto pilot of flag is set.
	owner waittill( "LISTEN_heli_movement_input" );
	
	flag_set( "FLAG_apache_tut_fly_stop_control_hint" );
	flag_set( "FLAG_apache_tut_fly_stop_auto_pilot" );
}

apache_move_until_notify( apache_player, speed, stop_notify, level_stop_notify )
{
	if ( IsDefined( level_stop_notify ) )
		level endon( level_stop_notify );
	
	owner = apache_player.heli.owner;
	
	if ( IsDefined( stop_notify ) )
		owner endon( stop_notify );
	
	owner endon( "death" );
	
	while ( 1 )
	{
		apache_player Vehicle_SetSpeedImmediate( speed, speed, speed * 0.05 );
		wait 0.05;
	}
}

apache_owner_notify_on_input_camera( apache_player, cam_input_notify )
{
	owner = apache_player.heli.owner;
	
	owner endon( cam_input_notify );
	
	while ( 1 )
	{
		cam_norm = owner GetNormalizedCameraMovement();
		
		if ( max( abs( cam_norm[ 0 ] ), abs( cam_norm[ 1 ] ) ) > 0.2 )
			break;
		
		wait 0.05;
	}
	
	owner notify( cam_input_notify );
}

apache_owner_notify_on_input_move( apache_player, move_input_notify )
{
	owner = apache_player.heli.owner;
	
	owner endon( move_input_notify );
	
	while ( 1 )
	{
		move_norm = owner GetNormalizedMovement();
		
		if ( max( abs( move_norm[ 0 ] ), abs( move_norm[ 1 ] ) ) > 0.2 )
			break;
		
		wait 0.05;
	}
	
	owner notify( move_input_notify );
}
