#include maps\_utility;
#include common_scripts\utility;

/*
 * Limp
 * 
 * 1.) Call init_player_limp() before maps\_load::load
 * 2.) Call enable_player_limp() on player entity;
 * 	e.g. level.player enable_limp();
 * 3. ) Don't forget to set fog in your level
 *  e.g. level.player vision_set_fog_changes( "carlos", 0 );
 * 
 */

// DONT CHANGE THESE
LIMP_PITCH_MIN = 2; //2
LIMP_PITCH_MAX = 5; //5

LIMP_YAW_MIN = -8; // -8
LIMP_YAW_MAX =  2; // -2

LIMP_ROLL_MIN = 3; // 3
LIMP_ROLL_MAX = 5; // 5

LIMP_STUMBLE_TIME_MIN = 0.15; // .15
LIMP_STUMBLE_TIME_MAX = 0.45; // .45

LIMP_RECOVER_TIME_MIN = 0.65; 
LIMP_RECOVER_TIME_MAX = 1.25;

LIMP_PLAYER_SPEED_PERCENT = 75;

LIMP_HEARTBEAT_RATE = .75;

init_player_limp()
{
	PreCacheShellShock( "player_limp" );
	PreCacheShader( "black" );
}

init_default_limp()
{
	level.player_limp = [];
	level.player_limp[ "pitch" ][ "min" ] 	= LIMP_PITCH_MIN;
	level.player_limp[ "pitch" ][ "max" ] 	= LIMP_PITCH_MAX;
	level.player_limp[ "yaw" ][ "min" ]		= LIMP_YAW_MIN;
	level.player_limp[ "yaw" ][ "max" ] 	= LIMP_PITCH_MAX;
	level.player_limp[ "roll" ][ "min" ] 	= LIMP_ROLL_MIN;
	level.player_limp[ "roll" ][ "max" ] 	= LIMP_ROLL_MAX;
}

set_custom_limp( pitch, yaw, roll )
{
	if( isdefined( pitch ) )
	{
		level.player_limp[ "pitch" ][ "min" ] 	= pitch[ "min" ];
		level.player_limp[ "pitch" ][ "max" ] 	= pitch[ "max" ];
	}
	
	if( isdefined( yaw ) )
	{
		level.player_limp[ "yaw" ][ "min" ]		= yaw[ "min" ];
		level.player_limp[ "yaw" ][ "max" ] 	= yaw[ "max" ];		
	}
	
	if( isdefined( roll ) )
	{
		level.player_limp[ "roll" ][ "min" ] 	= roll[ "min" ];
		level.player_limp[ "roll" ][ "max" ] 	= roll[ "max" ];		
	}	
}

// Lets you set all params back to default or just individual ones
reset_default_limp( pitch, yaw, roll )
{
	if( !isdefined( pitch ) && !isdefined( yaw ) && !isdefined( roll ) )
	{
		level.player_limp[ "pitch" ][ "min" ] 	= LIMP_PITCH_MIN;
		level.player_limp[ "pitch" ][ "max" ] 	= LIMP_PITCH_MAX;
		level.player_limp[ "yaw" ][ "min" ]		= LIMP_YAW_MIN;
		level.player_limp[ "yaw" ][ "max" ] 	= LIMP_PITCH_MAX;
		level.player_limp[ "roll" ][ "min" ] 	= LIMP_ROLL_MIN;
		level.player_limp[ "roll" ][ "max" ] 	= LIMP_ROLL_MAX;
		
		return;		
	}
	
	if( isdefined( pitch ) )
	{
		level.player_limp[ "pitch" ][ "min" ] 	= LIMP_PITCH_MIN;
		level.player_limp[ "pitch" ][ "max" ] 	= LIMP_PITCH_MAX;		
	}
	
	if( isdefined( yaw ) )
	{
		level.player_limp[ "yaw" ][ "min" ]		= LIMP_YAW_MIN;
		level.player_limp[ "yaw" ][ "max" ] 	= LIMP_PITCH_MAX;		
	}
	
	if( isdefined( roll ) )
	{
		level.player_limp[ "roll" ][ "min" ] 	= LIMP_ROLL_MIN;
		level.player_limp[ "roll" ][ "max" ] 	= LIMP_ROLL_MAX;		
	}
}

enable_limp( lspeed, fadelimp )
{
	if ( !ent_flag_exist( "fall" ) )
	{
		ent_flag_init( "fall" );
		ent_flag_init( "collapse" );
	}
//	SetSavedDvar( "cg_drawCrosshair", 0 );
	
	if( !isdefined( level.player_limp ) )
		init_default_limp();
	
	//create_client_overlay( "black", 1, level.player );
	
	self.limp = true;
	self.sprinting = undefined;
	self.allow_fall = true;
	self.limp_strength = 1.0;
	level.default_heartbeat_rate = .75;
	self create_ground_ref_ent();
	level.originalVisionSet = self.vision_set_transition_ent.vision_set;
	
	if( !isdefined( lspeed ) )
		lspeed = LIMP_PLAYER_SPEED_PERCENT;
	self player_speed_percent( lspeed, .05 );	
	self.player_speed = lspeed;
	//self thread player_jump_punishment();
	
	self thread limp();
	
	if( isdefined( fadelimp ) )
		thread fade_limp( fadelimp );
	
}

disable_limp( forgood, fadetime )
{
	
	self notify( "stop_limp" );
	self notify( "stop_random_blur" );
	//self StopShellShock();
	self FadeOutShellShock();
	
	if( !isdefined( fadetime ) )
		fadetime = 0;
	
	if( isdefined( forgood ) )
	{
		self playerSetGroundReferenceEnt( undefined );
		setSavedDvar( "player_sprintUnlimited", "0" );
		
		self notify( "stop_limp_forgood" );
	}
	else
	{
		recover_time = randomfloatrange( LIMP_RECOVER_TIME_MIN, LIMP_RECOVER_TIME_MAX );
		base_angles = adjust_angles_to_player( ( 0,0,0 ) );
		self.ground_ref_ent rotateto( base_angles, recover_time, 0, recover_time / 2 );
		self.ground_ref_ent waittill( "rotatedone" );
	}
	
	level.player vision_set_fog_changes( level.originalVisionSet, 0 );
	//level.player player_speed_percent( 100 );
	setblur( 0, randomfloatrange( .5, .75 ) );
	self allowstand( true );
	self allowcrouch( true );
	self allowprone( true );
	self allowsprint( true );
	self allowjump( true );
}

fade_limp( time )
{
	self endon( "stop_limp" );
	wait( time );
	self thread disable_limp();	
}

limp( override )
{
	self endon( "stop_limp" );
	
	self ShellShock( "player_limp", 9999 ); // shellshock doesnt allow sprint :(
	
	self allowsprint( false );
	self allowjump( false );
	self thread player_random_blur();
	self thread player_hurt_sounds();
	
	level waittill( "blah blah blah" );
	
	alt = 0;
	
	last_visionset = self.vision_set_transition_ent.vision_set;
	
	while ( true )
	{
		
		if( self PlayerAds() > .3 )
		{
			wait(.05);
			continue;				
		}
		
		stance = level.player GetStance();
		if( stance == "crouch" || stance == "prone" )
		{
			wait(.05);
			continue;	
		}
		
		velocity = self getvelocity(); // get player's speed
		player_speed = abs( velocity [ 0 ] ) + abs( velocity[ 1 ] );
	
		if ( player_speed < 10 )
		{
			wait 0.05;
			continue;
		}

		speed_multiplier = player_speed / self.player_speed;

		p = randomfloatrange( level.player_limp[ "pitch" ][ "min" ], level.player_limp[ "pitch" ][ "max" ] );
		if ( randomint( 100 ) < 20 )
			p *= 1.5;
		r = randomfloatrange( level.player_limp[ "roll" ][ "min" ], level.player_limp[ "roll" ][ "max" ] );
		y = randomfloatrange( level.player_limp[ "yaw" ][ "min" ], level.player_limp[ "yaw" ][ "max" ] );

		stumble_angles = ( p, y, r );
		stumble_angles = stumble_angles * speed_multiplier;
		stumble_angles = stumble_angles * self.limp_strength;
		
		stumble_time = randomfloatrange( LIMP_STUMBLE_TIME_MIN, LIMP_STUMBLE_TIME_MAX );
		recover_time = randomfloatrange( LIMP_RECOVER_TIME_MIN, LIMP_RECOVER_TIME_MAX );

		if ( self.vision_set_transition_ent.vision_set != "aftermath_pain" )
			last_visionset = self.vision_set_transition_ent.vision_set;
		
		self thread vision_set_fog_changes( "aftermath_pain", 3 );
		self thread stumble( stumble_angles, stumble_time, recover_time );
		wait stumble_time;
		self thread vision_set_fog_changes( last_visionset, recover_time );
		self waittill( "recovered" );

	}
}

stumble( stumble_angles, stumble_time, recover_time, no_notify )
{
	self endon( "stop_stumble" );
	self endon( "stop_limp" );

	if ( ent_flag( "collapse" ) )
		return;

	stumble_angles = adjust_angles_to_player( stumble_angles );

	self notify( "stumble" );
	self create_ground_ref_ent();
	self.ground_ref_ent rotateto( stumble_angles, stumble_time, ( stumble_time / 4 * 3 ), ( stumble_time / 4 ) );
	self.ground_ref_ent waittill( "rotatedone" );

//	if ( level.player getstance() == "stand" )
//		level.player PlayRumbleOnEntity( "damage_light" );

	base_angles = ( randomfloat( 4 ) - 4, randomfloat( 5 ), 0 );
	base_angles = adjust_angles_to_player( base_angles );

	self.ground_ref_ent rotateto( base_angles, recover_time, 0, recover_time / 2 );
	self.ground_ref_ent waittill( "rotatedone" );

 	if ( !isdefined( no_notify ) )
		self notify( "recovered" );
}

player_random_sway()
{
	self endon( "stop_random_sway" );
	
	while(1)
	{
		velocity = self getvelocity();
		if( velocity > 0 )
		{
			wait(.05);
			continue;
		}
		
		
		wait(.05);
	}
}

player_random_blur()
{
	self endon( "dying" );
	self endon( "stop_random_blur" );

	while ( true )
	{
		wait 0.05;
		if ( randomint( 100 ) > 10 )
			continue;

		blur = randomint( 3 ) + 4;
		blur_time = randomfloatrange( 0.1, 0.3 );
		recovery_time = randomfloatrange( 0.3, 1 );
		setblur( blur * 1.2, blur_time );
		wait blur_time;
		setblur( 0, recovery_time );
		wait( recovery_time );
		wait( RandomFloatRange( 0, 1.5 ) );
		self waittill_notify_or_timeout( "blur", 5 );

	}
}

player_hurt_sounds()
{
	self endon( "stop_limp" );
	
	//level.player thread player_heartbeat();
	while( 1 )
	{
		// dont want to play over player hurt sounds when player actually gets hurt
		if( player_playing_hurt_sounds()  )
		{
			wait(.05);
			continue;
		}
		
		self notify( "blur" );
		self play_sound_in_space( "breathing_limp_start" );
		self play_sound_in_space( "breathing_limp_better" );
		wait( RandomFloatRange( 0, 1 ) );
		self waittill_notify_or_timeout( "stumble", RandomIntRange( 5, 7 ) );
	}
}

player_heartbeat()
{
	self endon( "stop_limp" );
	
	level.player_heartbeat_rate = LIMP_HEARTBEAT_RATE;
	
	while(1)
	{
		self play_sound_in_space( "breathing_limp_heartbeat" );	
		wait( level.player_heartbeat_rate );
	}
}

set_player_hearbeat_rate( num )
{
	if( !isdefined( num ) || isstring( num ) )
		level.player_heartbeat_rate = LIMP_HEARTBEAT_RATE;
	else
		level.player_heartbeat_rate = num;
}

player_playing_hurt_sounds()
{
	if( level.player.health < 50 )
		return true;	
	else
		return false;		
}


player_jump_punishment()
{
	//self endon( "stop_limp" );
	self endon( "stop_limp_forgood" );
	
	wait 1;
	while ( true )
	{
		wait 0.05;
		if ( self isonground() )
			continue;
		wait 0.2;
		if ( self isonground() )
			continue;
		// don't want to limp before hitting the ground
		while(1)
		{
			if( self isonground() )
				break;
			else
				wait(.05);
		}
		
		
		self notify( "stop_stumble" );
		wait 0.2;
		//self fall();
		self limp();
		self notify( "start_limp" );
	}
}

/*
fall()
{
	self endon( "stop_limp" );
	self endon( "stop_stumble" );

	if ( !self.allow_fall )
		return;

	ent_flag_set( "fall" );

	self setstance( "prone" );

	self thread play_sound_on_entity( "Land_plr_Damage" );

	stumbletime = 0.2;
	recovertime = 1;
	
	self thread stumble( ( 20, 10, 30 ), stumbletime, recovertime, true );
	self thread play_sound_in_space( "breathing_hurt" );
	
	wait stumbletime;
	last_visionset = self.vision_set_transition_ent.vision_set;
	self vision_set_fog_changes( "aftermath_pain", 0 );

	self PlayRumbleOnEntity( "grenade_rumble" );

	self allowstand( false );
	self allowcrouch( false );
	self viewkick( 127, level.player.origin );
	self EnableSlowAim( 0.3, 0.3 );
	
	wait recovertime;
	ent_flag_set( "fall" );

	thread recover();

	self play_sound_in_space( "sprint_gasp" );
	self play_sound_in_space( "breathing_hurt_start" );
	self play_sound_in_space( "breathing_better" );

	recovertime = 3;
	self thread vision_set_fog_changes( last_visionset, recovertime );
	self play_sound_on_entity( "breathing_better" );

	self allowstand( true );
	self allowcrouch( true );

	wait recovertime;
	
	ent_flag_clear( "fall" );
	self DisableSlowAim();
	self notify( "recovered" );

}
*/

recover()
{
	angles = self adjust_angles_to_player( ( -5, -5, 0 ) );
	self.ground_ref_ent rotateto( angles, .4, 0.4, 0 );
	self.ground_ref_ent waittill( "rotatedone" );

	angles = self adjust_angles_to_player( ( -15, -20, 0 ) );
	self.ground_ref_ent rotateto( angles, 1, 0, 1 );
	self.ground_ref_ent waittill( "rotatedone" );

	angles = self adjust_angles_to_player( ( 5, 5, 0 ) );
	self.ground_ref_ent rotateto( angles, .9, 0.7, 0.1 );
	self.ground_ref_ent waittill( "rotatedone" );

	self.ground_ref_ent rotateto( ( 0, 0, 0 ), 1, 0.2, 0.8 );
}

adjust_angles_to_player( stumble_angles )
{
	pa = stumble_angles[ 0 ];
	ra = stumble_angles[ 2 ];

	rv = anglestoright( self .angles );
	fv = anglestoforward( self .angles );

	rva = ( rv[ 0 ], 0, rv[ 1 ] * - 1 );
	fva = ( fv[ 0 ], 0, fv[ 1 ] * - 1 );
	angles = rva * pa;
	angles = angles + ( fva * ra );
	return angles + ( 0, stumble_angles[ 1 ], 0 );
}

create_ground_ref_ent()
{
	if ( isdefined( self.ground_ref_ent ) )
		return;
	
	self.ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	self playerSetGroundReferenceEnt( self.ground_ref_ent );	
}