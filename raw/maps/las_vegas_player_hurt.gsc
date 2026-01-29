#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

HURT_SPEED_PERCENT = 75;

init_player_hurt()
{
	Precacheshellshock( "player_limp" );		
}

enable_player_hurt( hspeed )
{

//	level.originalVisionSet = self.vision_set_transition_ent.vision_set;
	
	if( flag( "FLAG_player_used_adrenaline" ) )
		flag_clear( "FLAG_player_used_adrenaline" );
	
	if( !isdefined( hspeed ) )
		hspeed = HURT_SPEED_PERCENT;
	self player_speed_percent( hspeed, .05 );	
	SetSavedDvar( "cg_drawCrosshair", 0 );	
	//level.player shellshock( "player_limp", 99999 );
	thread player_hurt_fake_shellshock();
	level.player thread player_hurt_breathing();
}

disable_player_hurt()
{
	SetSavedDvar( "cg_drawCrosshair", 1 );
	level.player notify( "stop_fake_shellshock" );
	self player_speed_percent( 70, .05 );
}

player_hurt_breathing()
{
	//aftermath_walking
	//aftermath_pain
	//aftermath_nodesat
	//aftermath_hurt
	//aftermath_glow
	//aftermath_dying
	//aftermath_blue
	//aftermath
	
	sounds = [];
	//sounds[ sounds.size ] = "breathing_limp";
	//sounds[ sounds.size ] = "breathing_hurt_start_alt";
	sounds[ sounds.size ] = "breathing_limp_better";
	
	while( !flag( "FLAG_player_used_adrenaline" ) )
	{
		
		sound = random( sounds );
		thread set_blur( 2, .5 );
		thread set_vision_set( "aftermath_nodesat", .5 );
		level.player play_sound_on_entity( sound );
		thread set_blur( 0, .5 );
//		thread set_vision_set( self.vision_set_transition_ent.vision_set, 1 );
		
		timer = RandomFloatRange( 1.8, 3.8 );
		wait( timer );
		
	}
	
//	thread set_vision_set( self.vision_set_transition_ent.vision_set, 1 );
	
}

player_hurt_fake_shellshock()
{
	level.player endon( "stop_fake_shellshock" );
	
	level.ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level.player playerSetGroundReferenceEnt( level.ground_ref_ent );
	originalAngles = level.ground_ref_ent.angles;
	
	while( 1 )
	{
		move_time = randomintrange( 3, 5 );
		
		num = [ randomintrange( 3, 8 ), randomintrange( 1, 3 ) ];
		foreach( i, inter in num )
		{
			if( cointoss() )	
				num[i] = inter*-1;
		}
		angles = ( 0, num[0], num[1] );
		angles = adjust_angles_to_player( angles );	
		level.ground_ref_ent rotateto( angles, move_time, move_time / 2, move_time / 2 );
		level.ground_ref_ent waittill( "rotatedone" );
		
		move_time = randomintrange( 4, 6 );
		
		foreach( i, inter in num )
			num[i] = inter*-1;
		
		angles = ( 0, num[0], num[1] );
		angles = adjust_angles_to_player( angles );	
		level.ground_ref_ent rotateto( angles, move_time, move_time / 2, move_time / 2 );
		level.ground_ref_ent waittill( "rotatedone" );			

	}
}

player_hurt_sprint_detection()
{
	
}

adjust_angles_to_player( stumble_angles )
{
	pa = stumble_angles[ 0 ];
	ra = stumble_angles[ 2 ];

	rv = anglestoright( level.player.angles );
	fv = anglestoforward( level.player.angles );

	rva = ( rv[ 0 ], 0, rv[ 1 ] * - 1 );
	fva = ( fv[ 0 ], 0, fv[ 1 ] * - 1 );
	angles = rva * pa;
	angles = angles + ( fva * ra );
	return angles + ( 0, stumble_angles[ 1 ], 0 );
}

player_hurt_shellshock_forever()
{
		
}