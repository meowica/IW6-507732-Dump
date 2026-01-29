#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;

main()
{
	precacheAnims();
}

precacheAnims()
{
	human_anims();
	zero_g_body();
	vehicles();
	player_animations();
//	animated_props_anims();
	model_anims();
	tarps();
//	player_anims();
}

#using_animtree( "generic_human" );
human_anims()
{	
	level.scr_anim[ "vargas" ] [ "hostage_chair_idle" ] [ 0 ] = %hostage_chair_twitch;
	level.scr_anim[ "vargas" ] [ "hostage_chair_idle" ] [ 0 ] = %hostage_chair_idle;
	
	
	level.scr_anim[ "generic" ] [ "hostage_chair_dive"				   ] = %hostage_chair_dive;
	level.scr_anim[ "generic" ] [ "execution_onknees_hostage_survives" ] = %execution_onknees_hostage_survives;
	level.scr_anim[ "generic" ] [ "execution_onknees_hostage"		   ] = %execution_onknees_hostage;
	
	level.scr_anim[ "kersey" ][ "rescue_chair_untie_soldier_idle" ]	[ 0 ]	 = %rescue_chair_untie_soldier_idle;
	
	level.scr_anim[ "mccoy" ][ "rescue_chair_untie_soldier_idle" ] [ 0 ]	 = %rescue_chair_untie_soldier_idle;
	
	level.scr_anim[ "knees_one" ] [ "hostage_knees_loop" ] [ 0 ] = %hostage_knees_idle;
	level.scr_anim[ "knees_one" ] [ "hostage_knees_loop" ] [ 1 ] = %hostage_knees_twitch;
	
	
	level.scr_anim[ "knees_two" ] [ "hostage_knees_loop" ] [ 0 ] = %hostage_knees_idle;
	level.scr_anim[ "knees_two" ] [ "hostage_knees_loop" ] [ 1 ] = %hostage_knees_twitch;
	
	level.scr_anim[ "price" ] [ "price_tie_up" ]	 = %explosive_plant_knee;
	
	level.scr_anim[ "vargas" ] [ "kick" ] = %door_kick_in;
	
	level.scr_anim[ "generic" ] [ "zerog_one" ] = %hijack_zerog_terrorist_01_alive;
	level.scr_anim[ "generic" ] [ "zerog_two" ] = %hijack_zerog_terrorist_02_alive;
	
	level.scr_anim[ "knees_one" ][ "zerog_three" ] = %hijack_zerog_terrorist_03_alive;
	
	level.scr_anim[ "knees_two" ][ "zerog_four" ] = %hijack_zerog_terrorist_04_alive;
	
	level.scr_anim[ "price" ][ "zerog_two" ] = %hijack_zerog_terrorist_02_alive;
	
	level.scr_anim[ "kersey" ][ "zerog_two" ] = %hijack_zerog_terrorist_02_alive;
	
	level.scr_anim[ "mccoy" ][ "zerog_one" ] = %hijack_zerog_terrorist_01_alive;
	
	level.scr_anim[ "price" ][ "climb" ][ 0 ] = %ladder_climbup;
	
	level.scr_anim[ "generic" ] [ "jump_off_wing"		] = %jump_across_100_spring;
	level.scr_anim[ "generic" ] [ "wingsuit_idle"		] = %wingsuit_cruising_idle;
	level.scr_anim[ "generic" ] [ "plane_bomb_on_plane" ] = %plane_plant_bomb;
	
	
	level.scr_anim[ "price" ][ "helper_fall_2" ] = %plane_helper_fall_2;
	
	level.scr_anim[ "vargas" ][ "hostage_ramp_down" ] = %plane_hostage_ramp_down;
	
	// chair anims
	level.scr_anim[ "vargas" ][ "vargas_sit_idle" ][ 0 ]	  = %plane_hostage_idle;
	level.scr_anim[ "vargas" ][ "vargas_sit_grab" ]			  = %plane_hostage_idle_to_grab;
	level.scr_anim[ "vargas" ] [ "vargas_sit_shake_1" ] [ 0 ] = %plane_hostage_shake;
	level.scr_anim[ "vargas" ] [ "vargas_sit_shake_2" ] [ 0 ] = %plane_hostage_shake_heavy;
	level.scr_anim[ "vargas" ][ "vargas_fall_1" ]			  = %plane_hostage_fall;
	
	level.scr_sound[ "price" ] [ "hijk_terror02_yell"	] = "hijk_terror02_yell";
	level.scr_sound[ "price" ] [ "hijk_terror02_scream" ] = "hijk_terror02_scream";
	
	level.scr_sound[ "mccoy" ] [ "hijk_terror01_yell"	] = "hijk_terror01_yell";
	level.scr_sound[ "mccoy" ] [ "hijk_terror01_scream" ] = "hijk_terror01_scream";
	
	level.scr_sound[ "kersey" ] [ "hijk_terror02_yell"	 ] = "hijk_terror02_yell";
	level.scr_sound[ "kersey" ] [ "hijk_terror02_scream" ] = "hijk_terror02_scream";

	level.scr_sound[ "knees_two" ] [ "hijk_terror04_yell"	] = "hijk_terror04_yell";
	level.scr_sound[ "knees_two" ] [ "hijk_terror04_scream" ] = "hijk_terror04_scream";
	
	level.scr_sound[ "knees_one" ] [ "hijk_terror03_yell"	] = "hijk_terror03_yell";
	level.scr_sound[ "knees_one" ] [ "hijk_terror03_scream" ] = "hijk_terror03_scream";
	
	level.scr_sound[ "hijk_jet_air_rl" ] = "hijk_jet_air_rl";	
}

_setup_chair()
{
}

#using_animtree( "generic_human" );
zero_g_body()
{
	level.scr_animtree[ "test_body" ]				 = #animtree;
	level.scr_model[ "test_body" ]					 = "viewmodel_base_viewhands"; // viewhands_player_fso
	level.scr_anim[ "test_body" ][ "zero_g_player" ] = %hijack_zero_g_player;
	
	
							 //   animname     notetrack 		    function 							    anime 		    
	addNotetrack_customFunction( "test_body", "people_lurch_left", maps\iplane_code::zerog_firsthit		 , "zero_g_player" );
	addNotetrack_customFunction( "test_body", "plane_dive_down"	 , maps\iplane_code::zerog_planedive	 , "zero_g_player" );
	addNotetrack_customFunction( "test_body", "people_fly_up"	 , maps\iplane_code::zerog_flyup		 , "zero_g_player" );
	addNotetrack_customFunction( "test_body", "screen_shake_1"	 , maps\iplane_code::zerog_secondhit	 , "zero_g_player" );
	addNotetrack_customFunction( "test_body", "plane_roll_right" , maps\iplane_code::zerog_planerollright, "zero_g_player" );
	addNotetrack_customFunction( "test_body", "screen_shake_2"	 , maps\iplane_code::zerog_bigshake		 , "zero_g_player" );
	addNotetrack_customFunction( "test_body", "plane_roll_left"	 , maps\iplane_code::zerog_planerollleft , "zero_g_player" );
	addNotetrack_customFunction( "test_body", "screen_shake_3"	 , maps\iplane_code::zerog_thirdhit		 , "zero_g_player" );
	addNotetrack_customFunction( "test_body", "plane_level_out"	 , maps\iplane_code::zerog_planelevelout , "zero_g_player" );
}

#using_animtree( "vehicles" );
vehicles()
{
	level.scr_animtree[ "hummer" ]						  = #animtree;
	level.scr_anim[ "hummer" ] [ "hummer_large_rocking" ] = %hovercraft_rocking;
	level.scr_anim[ "hummer" ] [ "hummer_small_rocking" ] = %snowmobile_vehicle_driving_idle;
}

#using_animtree( "script_model" );
model_anims()
{
	level.scr_animtree[ "chair_real" ]						 = #animtree;
	level.scr_model	  [ "chair_real" ]						 = "com_folding_chair";
	level.scr_anim[ "chair_real" ] [ "chair_idle"	 ] [ 0 ] = %plane_chair_idle;
	level.scr_anim[ "chair_real" ] [ "chair_shake_1" ] [ 0 ] = %plane_chair_shake;
	level.scr_anim[ "chair_real" ] [ "chair_shake_2" ] [ 0 ] = %plane_chair_shake_heavy;
	level.scr_anim[ "chair_real" ] [ "chair_down_ramp" ]	 = %plane_chair_ramp_down;
	level.scr_anim[ "chair_real" ] [ "chair_fall"	   ]	 = %plane_chair_fall;
	
	level.scr_animtree[ "sky_anim" ]					= #animtree;
	level.scr_model	  [ "sky_anim" ]					= "jungle_sky_model";
	level.scr_anim[ "sky_anim" ][ "sky_spin_one" ][ 0 ] = %plane_skybox_spin;

	level.scr_animtree[ "bottom_ramp" ]							= #animtree;
	level.scr_model	  [ "bottom_ramp" ]							= "tag_origin";
	level.scr_anim[ "bottom_ramp" ][ "plane_bottom_ramp_down" ] = %plane_lower_ramp_down;
	
	level.scr_animtree[ "enemy_plane" ]			   = #animtree;
	level.scr_model	  [ "enemy_plane" ]			   = "vehicle_Y_8";
	level.scr_anim[ "enemy_plane" ][ "y8_reveal" ] = %plane_y8_reveal;

	level.scr_animtree[ "top_ramp" ]			  = #animtree;
	level.scr_model	  [ "top_ramp" ]			  = "tag_origin";
	level.scr_anim[ "top_ramp" ][ "top_ramp_up" ] = %plane_upper_ramp_up;
	
	level.scr_animtree[ "tail" ]			  = #animtree;
	level.scr_model	  [ "tail" ]			  = "tag_origin";
	level.scr_anim[ "tail" ][ "tail_ripoff" ] = %plane_tail_ripoff;
	
	level.scr_animtree[ "wing_L" ]				  = #animtree;
	level.scr_model	  [ "wing_L" ]				  = "tag_origin";
	level.scr_anim[ "wing_L" ][ "wing_L_ripoff" ] = %plane_wing_L_ripoff;
	
	level.scr_animtree[ "plane_body" ]				 = #animtree;
	level.scr_model	  [ "plane_body" ]				 = "tag_origin";
	level.scr_anim[ "plane_body" ][ "body_turn_up" ] = %plane_body_turn_up;
	
	addNotetrack_customFunction( "plane_body", "tail_ripoff", ::rotate_secondary_player_enemy, "body_turn_up" );	
}

rotate_secondary_player_enemy( ent )
{	
	thread maps\iplane::rip_tail_off();
}

#using_animtree( "player" );
player_animations()
{
	level.scr_animtree[ "player_rig" ]								 = #animtree;
	level.scr_model	  [ "player_rig" ]								 = "viewhands_player_gs_hostage";
	level.scr_anim[ "player_rig" ] [ "hand_climb_right" ]			 = %plane_player_climb_R;
	level.scr_anim[ "player_rig" ] [ "hand_climb_left"	]			 = %plane_player_climb_L;
	level.scr_anim[ "player_rig" ] [ "player_fall"		]			 = %plane_player_fall;
	level.scr_anim[ "player_rig" ] [ "hand_climb_Right_idle" ] [ 0 ] = %plane_player_climb_idle_R;
	level.scr_anim[ "player_rig" ] [ "hand_climb_left_idle"	 ] [ 0 ] = %plane_player_climb_idle_L;
	level.scr_anim[ "player_rig" ] [ "player_press_button" ]		 = %plane_player_press_button;
	level.scr_anim[ "player_rig" ] [ "player_fall_2"	   ]		 = %plane_player_fall_2;
}

// putting in tarps
#using_animtree( "animated_props" );
tarps()
{
	level.scr_animtree[ "taprs0_rock" ]					  = #animtree;
	level.scr_model	  [ "taprs0_rock" ]					  = "mp_cement_tarp4";
	level.scr_anim[ "taprs0_rock" ][ "taprs0_anim" ][ 0 ] = %mp_cement_tarp4_anim_a;
	
  //  level.scr_animtree[ "taprs1_rock" ]					= #animtree;
  //  level.scr_model	[ "taprs1_rock" ]					= "fence_tarp_draping_130x50";
  //  level.scr_anim[ "taprs1_rock" ][ "taprs1_anim" ][ 0 ] = %fence_tarp_draping_224x116_01;
}