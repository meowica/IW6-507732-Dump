#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
#include maps\loki_util;
#include maps\_vignette_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	flag_inits();

	player_anims();
	generic_human();
	script_models();
	dialogue();
	vehicles();	

	level thread vignettes();
}

anim_precache()
{
	PreCacheModel( "viewhands_us_lunar" );	
}

vignettes()
{
//	level thread vignette_register( ::skybridge_doorbreach_spawn, "vignette_skybridge_doorbreach_trigger" );
}

flag_inits()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
player_anims()
{
	level.scr_animtree	[ "player_rig"	] = #animtree;
	level.scr_model		[ "player_rig"	] = "viewhands_us_lunar";
	
//	viewhands_player_us_army
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "viewmodel_space_l_arm_sidepush" ] = %viewmodel_space_l_arm_sidepush;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";
	
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "viewmodel_space_l_arm_downpush" ] = %viewmodel_space_l_arm_downpush;
	level.scr_model[ "player_rig" ] = "viewhands_player_us_army";

	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_anim[ "player_rig" ][ "infil" ] = %loki_infil_player;
	level.scr_model[ "player_rig" ] = "viewhands_us_lunar_animated";

	level.scr_animtree[ "player_rig" ]					= #animtree;
	level.scr_anim[ "player_rig" ][ "explosion_part1" ] = %loki_moving_cover_player_part1;
	level.scr_anim[ "player_rig" ][ "explosion_part2" ] = %loki_moving_cover_player_part2;
	level.scr_model[ "player_rig" ]						= "viewhands_us_lunar_animated";

	// ROG sequence
	level.scr_animtree[ "player_rig" ]							 = #animtree;
	level.scr_anim[ "player_rig" ] [ "idle"					   ] = %loki_rog_fp_idle_1;
	level.scr_anim[ "player_rig" ] [ "breakapart"			   ] = %loki_rog_fp_breakapart;
	level.scr_anim[ "player_rig" ] [ "camera_shake"			   ] = %loki_rog_fp_idle_1_shake;
	level.scr_anim[ "player_rig" ] [ "camera_shake_breakapart" ] = %loki_rog_fp_breakapart_shake;
}

#using_animtree("generic_human");
generic_human()
{
	level.scr_animtree	[ "generic" ]						 = #animtree;
	level.scr_anim[ "generic" ][ "in_your_face_death" ][ 0 ] = %casual_stand_idle;

	level.scr_animtree	[ "ally_0" ]	  = #animtree;
	level.scr_anim[ "ally_0" ][ "infil" ] = %loki_infil_ally1;

	level.scr_animtree	[ "ally_1" ]	  = #animtree;
	level.scr_anim[ "ally_1" ][ "infil" ] = %loki_infil_ally2;

	level.scr_animtree	[ "ally_2" ]	  = #animtree;
	level.scr_anim[ "ally_2" ][ "infil" ] = %loki_infil_ally3;

	level.scr_animtree	[ "redshirt_0" ]	  = #animtree;
	level.scr_anim[ "redshirt_0" ][ "infil" ] = %loki_infil_ally4;

	level.scr_animtree	[ "redshirt_1" ]	  = #animtree;
	level.scr_anim[ "redshirt_1" ][ "infil" ] = %loki_infil_ally5;

	level.scr_animtree	[ "redshirt_2" ]	  = #animtree;
	level.scr_anim[ "redshirt_2" ][ "infil" ] = %loki_infil_ally6;

	level.scr_animtree	[ "redshirt_3" ]	  = #animtree;
	level.scr_anim[ "redshirt_3" ][ "infil" ] = %loki_infil_ally7;

	level.scr_animtree	[ "player_legs" ]				 = #animtree;
	level.scr_anim[ "player_legs" ][ "explosion_part1" ] = %loki_moving_cover_player_legs_part1;
	level.scr_anim[ "player_legs" ][ "explosion_part2" ] = %loki_moving_cover_player_legs_part2;
	level.scr_model[ "player_legs" ]					 = "us_space_assault_body";

	level.scr_animtree	[ "deadbody" ]				  = #animtree;
	level.scr_anim[ "deadbody" ][ "explosion_part1" ] = %loki_moving_cover_deadbody_01;

	level.scr_animtree	[ "generic" ]				 = #animtree;
	level.scr_anim[ "generic" ][ "explosion_part1" ] = %death_explosion_up10;
	level.scr_anim[ "generic" ][ "explosion_death" ] = %death_explosion_up10;
}

#using_animtree( "script_model" );
script_models()
{	
	level.scr_animtree[ "infil_shuttle" ]		 = #animtree;
	level.scr_anim[ "infil_shuttle" ][ "infil" ] = %loki_infil_shuttle;
	level.scr_model[ "infil_shuttle" ]			 = "vehicle_space_shuttle";

	level.scr_animtree[ "infil_shuttle_chair0" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair0" ][ "infil" ] = %loki_infil_player_seat;
	level.scr_model[ "infil_shuttle_chair0" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "infil_shuttle_chair1" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair1" ][ "infil" ] = %loki_infil_ally1_seat;
	level.scr_model[ "infil_shuttle_chair1" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "infil_shuttle_chair2" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair2" ][ "infil" ] = %loki_infil_ally2_seat;
	level.scr_model[ "infil_shuttle_chair2" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "infil_shuttle_chair3" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair3" ][ "infil" ] = %loki_infil_ally3_seat;
	level.scr_model[ "infil_shuttle_chair3" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "infil_shuttle_chair4" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair4" ][ "infil" ] = %loki_infil_ally4_seat;
	level.scr_model[ "infil_shuttle_chair4" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "infil_shuttle_chair5" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair5" ][ "infil" ] = %loki_infil_ally5_seat;
	level.scr_model[ "infil_shuttle_chair5" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "infil_shuttle_chair6" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair6" ][ "infil" ] = %loki_infil_ally6_seat;
	level.scr_model[ "infil_shuttle_chair6" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "infil_shuttle_chair7" ]		= #animtree;
	level.scr_anim[ "infil_shuttle_chair7" ][ "infil" ] = %loki_infil_ally7_seat;
	level.scr_model[ "infil_shuttle_chair7" ]			= "vehicle_space_shuttle_seat";

	level.scr_animtree[ "in_your_face" ]				  = #animtree;
	level.scr_anim[ "in_your_face" ][ "explosion_part1" ] = %loki_moving_cover_panel_piece_part1;
	level.scr_anim[ "in_your_face" ][ "explosion_part2" ] = %loki_moving_cover_panel_piece_part2;
	level.scr_model[ "in_your_face" ]					  = "loki_solar_panel_piece_01";

	// ROG sequence
	level.scr_animtree[ "ROG" ] = #animtree;
	level.scr_model[ "ROG" ] = "loki_rog_for_player_launch";
	level.scr_anim[ "ROG" ][ "breakapart" ] = %loki_rog_breakapart;
	level.scr_anim[ "ROG" ][ "decelerate" ] = %loki_rog_decelerate;
	level.scr_anim[ "ROG" ][ "decelerate_loop" ] = %loki_rog_decelerate_loop;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_01" ] = %loki_rog_seperate_01;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_02" ] = %loki_rog_seperate_02;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_03" ] = %loki_rog_seperate_03;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_04" ] = %loki_rog_seperate_04;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_05" ] = %loki_rog_seperate_05;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_06" ] = %loki_rog_seperate_06;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_07" ] = %loki_rog_seperate_07;
	level.scr_anim[ "ROG" ][ "loki_rog_seperate_08" ] = %loki_rog_seperate_08;

	// ROG camera sway
	level.scr_animtree[ "ROG_sway" ]				   = #animtree;
	level.scr_model	  [ "ROG_sway" ]				   = "tag_origin";
	level.scr_anim[ "ROG_sway" ] [ "violent_sway" ] = %loki_rog_fp_breakapart_shake;

	level.scr_animtree[ "loki_rog_single" ] = #animtree;
	level.scr_model[ "loki_rog_single" ] = "loki_rog_single_rod";
}

#using_animtree("vehicles"); 
vehicles() 
{
}

dialogue()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// TODO <MJS> check if this is something that should be moved into _utility.gsc
vignette_actor_aware_everything()
{
	self.ignoreall = false;
	self.ignoreme = false;
	self.grenadeawareness = 1;
	self.ignoreexplosionevents = false;
	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.fixednode = true;
	self.disableBulletWhizbyReaction = false;
	self enable_pain();
	self.dontavoidplayer = false;
	if( IsDefined( self.og_newEnemyReactionDistSq ) )
	{
		self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
	}
}