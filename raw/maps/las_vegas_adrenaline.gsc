#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

init_adrenaline()
{
	PreCacheShellShock( "adrenaline" );	
	precacheShader( "combathigh_overlay" );
	precachemodel( "adrenaline_syringe_animated" );
	
	flag_init( "FLAG_player_used_adrenaline" );

// Not being used anymore.	
//	add_hint_string( "use_adrenaline", &"LAS_VEGAS_USE_ADRENALINE_HINT", ::use_adrenaline_hint );
}

ADRENALINE_MAX_SPEED = 70;
ADRENALINE_FOV_PUSLING_START = 45;

enable_adrenaline( fadetime )
{
	
	self notifyOnPlayerCommand( "used_adrenaline", "+activate" );
	self notifyOnPlayerCommand( "used_adrenaline", "+usereload" );
	
	waitframe();
	self thread display_hint( "use_adrenaline" );
	self waittill( "used_adrenaline" );	
	
	level.player disableweapons();
	level.player setstance( "stand" );
	level.player allowcrouch( false );
	level.player allowprone( false );
	
	self thread adrenaline_viewhand_anim();
	
	if( !isdefined( fadetime ) )
		fadetime = 5;

	level.player thread maps\_player_limp::disable_limp( true, fadetime );
	self player_speed_percent( ADRENALINE_MAX_SPEED, fadetime );		
	self thread adrenaline_start_heartbeat( fadetime );
	self thread adrenaline_overlay( fadetime );
	self thread adrenaline_random_blur( fadetime );
	self thread adrenaline_dof_change( fadetime );
	//self thread adrenaline_pulsing_fov( fadetime );

	self ShellShock( "adrenaline", fadetime );
	level waittill( "adrenaline_anim_complete" );
	
	flag_set( "FLAG_player_used_adrenaline" );
	
	level.player allowcrouch( true );
	level.player allowprone( true );
	level.player allowjump( true );
	level.player allowsprint( true );
	level.player enableweapons();
}

adrenaline_viewhand_anim()
{
	model = "adrenaline_syringe_animated";
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	
	spot = spawnstruct();
	spot.angles = level.player getplayerangles();
	spot.origin = level.player.origin + ( 0, 0, 5 );
	
	arc = 15;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
	
	adrenaline = spawn( "script_model", level.player.origin );
	adrenaline setmodel( "adrenaline_syringe_animated" );
	adrenaline linkto( player_rig, "tag_knife_attach2", ( 0,0,0 ), ( 0,0,0 ) );
	spot anim_single_solo( player_rig, "player_adrenaline_shot" );
	
	level.player unlink();
	
	player_rig delete();
	adrenaline delete();
	
	level notify( "adrenaline_anim_complete" );
}

set_adrenaline_state()
{
	
}

adrenaline_start_heartbeat( fadetime )
{
//	waittime = 1;
//	endbeats = 0;
//	while(1)
//	{
//		if( waittime < .05 )
//		{
//			waittime = .05;
//			endbeats++;
//		}
//		wait( waittime );
//		
//		self thread play_sound_in_space( "breathing_heartbeat" );
//	
//		if( endbeats == 3 )
//			break;
//	
//		waittime = waittime - .2;
//	}
	
	timeStart = GetTime();
	while( 1 )
	{
		self thread play_sound_in_space( "breathing_heartbeat" );
		
		time = GetTime() - timeStart;
		if( time > fadetime * 1000 ) // convert to milliseconds
			break;

		wait(.5);
	}
	
	self play_sound_in_space( "breathing_better" );
}

adrenaline_overlay( fadetime )
{
	SetHUDLighting( true );
	
	hudEffect = NewClientHudElem( level.player ); 
	hudEffect.x = 0;
	hudEffect.y = 0;
	hudEffect.horzAlign = "fullscreen";
	hudEffect.vertAlign = "fullscreen";
	hudEffect SetShader("combathigh_overlay", 640, 480);
	hudEffect.alpha = 1;
	hudEffect FadeOverTime( fadetime ); 
	hudEffect.alpha = 0;
 }

adrenaline_random_blur( fadetime )
{
	timeStart = GetTime();
	while( 1 )
	{
		btime = randomfloatrange( .2, .7 );
		SetBlur( randomfloatrange( .5, 5 ), btime );
		wait( btime );
		SetBlur( 0, btime );
		wait( btime );
		
		time = GetTime() - timeStart;
		if( time > fadetime * 1000 ) // convert to milliseconds
			break;
	}	
}

adrenaline_pulsing_fov( fadetime )
{
	fadetime_mili = fadetime * 1000;
	
	fovChange = ADRENALINE_FOV_PUSLING_START;
	defaultFOV = 65;
	
	lerp_fov_overtime( .4, fovChange );
	lerp_fov_overtime( fadetime, defaultFOV );
	
//	while(1)
//	{
//		thread lerp_fov_overtime( .5, fovChange );
//		wait( .5 );
//		thread lerp_fov_overtime( .5, defaultFOV );
//
////		if( fovChange >= defaultFOV )
////			break;
////		
////		fovChange = fovChange + 2;
//	
//		wait( .5 );
//	}
}

adrenaline_dof_change( fadetime )
{
	maps\_art::dof_enable_script( 1, 1, 4, 1, 1, 1, 0.0 );
	maps\_art::dof_disable_script( fadetime );
}

use_adrenaline_hint()
{
	return ter_op( level.player UseButtonPressed(), true, false );	
}

player_enable_adrenaline( fadetime )
{
	level.player enable_adrenaline( fadetime );
}