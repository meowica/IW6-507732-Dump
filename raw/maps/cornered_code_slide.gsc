#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\_hud_util;

building_fall_slide_setup()
{
	flag_init( "left_pressed" );
	flag_init( "right_pressed" );
}

#using_animtree( "player" );
building_fall_anim_rig()
{
	level.base_falling_hands_anim = %cornered_building_fall_slide_player;
	level.base_falling_legs_anim = %cornered_building_fall_slide_player_viewleg;
	hands_rig = level.fall_arms_and_legs[ 0 ];
	legs_rig = level.fall_arms_and_legs[ 1 ];
	
	//CREATE INVISIBLE ANIM PATH TO PLAY NOTE TRACKS ON
	animnode = getstruct( "fall_animnode", "targetname" );
	path_rig = spawn_anim_model( "player_bldg_fall" );
	animnode thread anim_first_frame_solo( path_rig, "cornered_building_fall_slide_player" );
	path_rig Hide();
	level.fall_path_rig = path_rig;
	
	//LINK CURRENT MODELS TO INVISIBLE RIG - PLAYER IS ALREADY LINKED TO ARMS
	//hands_rig LinkTo( path_rig, "tag_player" );
	//legs_rig LinkTo( path_rig, "tag_player" );
	
	//START INVISIBLE PATH ANIM & MODEL ANIMS
	animnode thread anim_single_solo( path_rig, "cornered_building_fall_slide_player" );
	animnode thread anim_single_solo( hands_rig, "cornered_building_fall_slide_player" );
	//hands_rig SetAnim( level.base_falling_hands_anim, 1, 0 );
	hands_rig SetAnim( %cornered_building_fall_slide_player_l, 0.01, 0 );		
	hands_rig SetAnim( %cornered_building_fall_slide_player_r, 0.01, 0 );
	animnode thread anim_single_solo( legs_rig, "cornered_building_fall_slide_player" );
	//legs_rig SetAnim( level.base_falling_legs_anim, 1, 0 );	
	legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_l, 0.01, 0 );
	legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_r, 0.01, 0 );
	
	//WAIT UNTIL WE ALLOW INPUT
	//path_rig waittillmatch( "single anim", "original_start" );
	//hands_rig waittillmatch( "single anim", "original_start" );
	thread input_monitor();
	thread player_play_anims( hands_rig, legs_rig );
}

input_monitor()
{
	level.player endon( "death" );
	level endon( "fall_slide_ending" );
	
	while( 1 )
	{
		analog_input = level.player GetNormalizedMovement();
		if( analog_input[ 1 ] >= 0.15 )
		{
			//IPrintLn( "pressing right" );
			//IPrintLn( Distance2D( hands_rig.origin, path_rig.origin ) );
			flag_clear( "left_pressed" );
			flag_set( "right_pressed" );
		}
		else if( analog_input[ 1 ] <= -0.15 )
		{
			//IPrintLn( "pressing left" );
			//IPrintLn( Distance2D( hands_rig.origin, path_rig.origin ) );
			flag_clear( "right_pressed" );
			flag_set( "left_pressed" );
		}
		else
		{
			flag_clear( "left_pressed" );
			flag_clear( "right_pressed" );
		}
		waitframe();
	}
}

#using_animtree( "player" );
player_play_anims( hands_rig, legs_rig )
{
	level.player endon( "death" );
	level endon( "fall_slide_ending" );
	
	blend_to_lean_time = 1.45;
	blend_to_idle_time = 1.45;
	
	while( 1 )
	{
		if( flag( "left_pressed" ) )
		{
			//IPrintLn( "anim left pressed" );
			hands_rig SetAnim( %cornered_building_fall_slide_player_l, 1, blend_to_lean_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_l, 1, blend_to_lean_time );
			// what a pain!!! can't turn the default anim to 0 or else it will restart when I try to turn it up again.
			hands_rig SetAnim( level.base_falling_hands_anim, 0.01, blend_to_lean_time );
			legs_rig SetAnim( level.base_falling_legs_anim, 0.01, blend_to_lean_time );
			hands_rig SetAnim( %cornered_building_fall_slide_player_r, 0.01, blend_to_idle_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_r, 0.01, blend_to_idle_time );
			
			flag_waitopen( "left_pressed" );
			//IPrintLn( "anim left done pressed" );
			hands_rig SetAnim( level.base_falling_hands_anim, 1, blend_to_idle_time );
			legs_rig SetAnim( level.base_falling_legs_anim, 1, blend_to_idle_time );
			hands_rig SetAnim( %cornered_building_fall_slide_player_l, 0.01, blend_to_idle_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_l, 0.01, blend_to_idle_time );
			hands_rig SetAnim( %cornered_building_fall_slide_player_r, 0.01, blend_to_idle_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_r, 0.01, blend_to_idle_time );
		}
		else if( flag( "right_pressed" ) )
		{
			//IPrintLn( "anim right pressed" );
			hands_rig SetAnim( %cornered_building_fall_slide_player_r, 1, blend_to_lean_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_r, 1, blend_to_lean_time );
			// what a pain!!! can't turn the default anim to 0 or else it will restart when I try to turn it up again.
			hands_rig SetAnim( level.base_falling_hands_anim, 0.01, blend_to_lean_time );
			legs_rig SetAnim( level.base_falling_legs_anim, 0.01, blend_to_lean_time );
			hands_rig SetAnim( %cornered_building_fall_slide_player_l, 0.01, blend_to_idle_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_l, 0.01, blend_to_idle_time );
			
			flag_waitopen( "right_pressed" );
			//IPrintLn( "anim right done pressed" );
			hands_rig SetAnim( level.base_falling_hands_anim, 1, blend_to_idle_time );
			legs_rig SetAnim( level.base_falling_legs_anim, 1, blend_to_idle_time );
			hands_rig SetAnim( %cornered_building_fall_slide_player_r, 0.01, blend_to_idle_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_r, 0.01, blend_to_idle_time );
			hands_rig SetAnim( %cornered_building_fall_slide_player_l, 0.01, blend_to_idle_time );
			legs_rig SetAnim( %cornered_building_fall_slide_player_viewleg_l, 0.01, blend_to_idle_time );
		}
		else
		{
			flag_wait_any( "left_pressed", "right_pressed" );
		}
	}
}