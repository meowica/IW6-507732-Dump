#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	player_anims();
	generic_human_anims();
	script_model_anims();
	vehicle_anims();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
player_anims()
{
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_model[ "player_rig" ] = "viewhands_player_ranger_dirty";
	
	level.scr_anim[ "player_rig" ][ "player_intro" ] = %blackice_player_intro;
	//level.scr_anim[ "player_rig" ][ "player_surface" ] = %blackice_player_surface;
	level.scr_anim[ "player_rig" ][ "player_surface_arms" ] = %blackice_player_surface_arms;
	level.scr_anim[ "player_rig" ][ "player_surface_root" ] = %blackice_player_surface_root;
	level.scr_anim[ "player_rig" ][ "player_surface_root_pt2" ] = %blackice_player_surface_root_pt2;
	
	addNotetrack_flag( "player_rig", "surface_anim_swap", "flag_surface_anim_swap" );
	
	//level.scr_anim[ "player_rig" ][ "playerarms_idle" ] = %blackice_playerarms_idle;
	//level.scr_anim[ "player_rig" ][ "playerarms_in" ] = %blackice_playerarms_in;
	//level.scr_anim[ "player_rig" ][ "playerarms_out" ] = %blackice_playerarms_out;
	
	//level.scr_anim[ "player_rig" ][ "playercamera_forward" ] = %blackice_playercamera_forward;
	//level.scr_anim[ "player_rig" ][ "playercamera_idle" ] = %blackice_playercamera_idle;
	
	// rig ascend
	level.scr_anim[ "player_rig" ][ "alpha_rig_ascend_aim" ] = %blackice_player_rigascend_aim;
	level.scr_anim[ "player_rig" ][ "alpha_rig_ascend_aim_loop" ][0] = %blackice_player_rigascend_aim_loop;
	level.scr_anim[ "player_rig" ][ "alpha_rig_ascend_linkup" ] = %blackice_player_linkup;
	level.scr_anim[ "player_rig" ][ "alpha_rig_ascend_groundidle" ][0] = %blackice_player_groundidle;
	level.scr_anim[ "player_rig" ][ "alpha_rig_ascend" ] = %blackice_player_rigascend;
	level.scr_anim[ "player_rig" ][ "player_rigascend_noise" ] = %blackice_player_rigascend_noise;
	level.scr_anim[ "player_rig" ][ "rigascend_noise_parent" ] = %rigascend_noise;
	level.scr_anim[ "player_rig" ][ "rig_ascend_stop" ] = %blackice_player_rigascend_stop;
	level.scr_anim[ "player_rig" ][ "rig_ascend_start" ] = %blackice_player_rigascend_start;
	
	// Aim additives
	level.scr_anim[ "player_rig" ][ "rigascend_aim_left_parent" ] = %rigascend_aim_left;
	level.scr_anim[ "player_rig" ][ "rigascend_aim_right_parent" ] = %rigascend_aim_right;
	level.scr_anim[ "player_rig" ][ "rigascend_aim_up_parent" ] = %rigascend_aim_up;
	level.scr_anim[ "player_rig" ][ "rigascend_aim_down_parent" ] = %rigascend_aim_down;
	level.scr_anim[ "player_rig" ][ "rigascend_aim_left" ] = %blackice_player_rigascend_aim_left;
	level.scr_anim[ "player_rig" ][ "rigascend_aim_right" ] = %blackice_player_rigascend_aim_right;
	level.scr_anim[ "player_rig" ][ "rigascend_aim_up" ] = %blackice_player_rigascend_aim_up;
	level.scr_anim[ "player_rig" ][ "rigascend_aim_down" ] = %blackice_player_rigascend_aim_down;
	
	addNotetrack_customFunction( "player_rig", "free_look_active", ::notetrack_player_free_look_active, "alpha_rig_ascend" );
	addNotetrack_customFunction( "player_rig", "additive_anims_start", ::notetrack_player_additive_anims_start, "alpha_rig_ascend" );
	addNotetrack_customFunction( "player_rig", "draw_weapon", ::notetrack_player_draw_weapon_ascend, "alpha_rig_ascend" );
	addNotetrack_flag( "player_rig", "bravo_leave", "flag_ascend_bravo_go", "alpha_rig_ascend_linkup"  );
	addNotetrack_notify( "player_rig", "change_snowfx", "notify_start_catwalks_snow", "alpha_rig_ascend" );
	
	// common room breach
	level.scr_anim[ "player_rig" ][ "breach" ] = %blackice_commonroom_player;
	addNotetrack_notify( "player_rig", "start_bullets", "notify_start_bullets", "breach" );
	addNotetrack_notify( "player_rig", "green_light_start", "notify_start_green_light", "breach" );
	addNotetrack_notify( "player_rig", "red_light_start", "notify_start_red_light", "breach" );
	addNotetrack_notify( "player_rig", "damage_breacher", "notify_damage_breacher", "breach" );
	addNotetrack_flag( "player_rig", "ally_start", "flag_common_breach_ally_start", "breach" );
	addNotetrack_customFunction( "player_rig", "draw_weapon", ::cw_common_breach_draw_weapon, "breach" );
	
	// Flare Stackascender_aim_left
	level.scr_anim[ "player_rig" ][ "turn_off_flare_stack" ] = %blackice_flare_stack_player;
	
	// Control Room
	level.scr_anim[ "player_rig" ][ "command_start" ] = %blackice_controlroom_player_start;
	//level.scr_anim[ "player_rig" ][ "command_control" ] = %blackice_controlroom_player_control;
	level.scr_anim[ "player_rig" ][ "command_end" ] = %blackice_controlroom_player_end;
	level.scr_anim[ "player_rig" ][ "command_early" ] = %blackice_controlroom_player_early;
	level.scr_anim[ "player_rig" ][ "command_late" ] = %blackice_controlroom_player_late;
	level.scr_anim[ "player_rig" ][ "command_control" ] = %blackice_controlroom_player_control;
	
	
	//exfil
	level.scr_anim [ "player_rig" ][ "ladder_chase" ] = %blackice_player_exfil_explode;
	level.scr_anim [ "player_rig" ][ "exfil_fail" ] = %blackice_player_exfil_fail;
	level.scr_anim [ "player_rig" ][ "jump_arms" ] = %blackice_player_exfil_jumparms;
	level.scr_anim [ "player_rig" ][ "jump_arms_fail" ] = %blackice_player_exfil_jumparms_fail;
	
	//test for moving camera
	level.scr_anim [ "player_rig" ][ "cam_test" ] = %blackice_player_exfil_jumparms;

	addNotetrack_notify( "player_rig", "focus_monitor", "notify_focus_monitor", "command_start" );
	addNotetrack_notify( "player_rig", "blast", "notify_command_early_blast", "command_early"  );
	addNotetrack_notify( "player_rig", "flare_console_small_quake", "notify_flare_stack_button_press", "turn_off_flare_stack"  );
	addNotetrack_notify( "player_rig", "flip_switch", "notify_console_flip_switch", "turn_off_flare_stack" );
	addNotetrack_notify( "player_rig", "draw_weapon", "notify_player_draw_weapon", "turn_off_flare_stack" );
	addNotetrack_notify( "player_rig", "unlink", "notify_player_unlink", "turn_off_flare_stack" );
	addNotetrack_notify( "player_rig", "flare_stack_off", "notify_stop_flare_stack", "turn_off_flare_stack" );
	addNotetrack_notify( "player_rig", "unhide_arms", "notify_player_unhide_arms", "ladder_chase"  );
	addNotetrack_notify( "player_rig", "fade_to_black", "notify_flyout_fade_to_black", "ladder_chase"  );
	addNotetrack_notify( "player_rig", "death", "notify_player_hit_ice", "exfil_fail" );
	addNotetrack_notify( "player_rig", "quit_smoking", "notify_stop_view_smoke_fx", "exfil_fail" );
	addNotetrack_customFunction( "player_rig", "allow_player_control", ::notetrack_swim_begin_player_control, "player_intro" );
	addNotetrack_customFunction( "player_rig", "player_breach_water", ::notetrack_player_breach_water );
	addNotetrack_customFunction( "player_rig", "player_remove_mask", ::notetrack_remove_mask );
	addNotetrack_customFunction( "player_rig", "release_allies", ::notetrack_release_allies );
	addNotetrack_customFunction( "player_rig", "draw_weapon", ::notetrack_player_draw_weapon_surface );
	addNotetrack_customFunction( "player_rig", "loosen_lookaround", ::notetrack_swim_loosen_lookaround );
	//addNotetrack_customFunction( "player_rig", "Start_player_control", ::notetrack_ascend_start_player_control, "alpha_rig_ascend" );
	addNotetrack_customFunction( "player_rig", "End_player_control", ::notetrack_ascend_end_player_control, "alpha_rig_ascend" );
	addNotetrack_customFunction( "player_rig", "allow_free_look", ::notetrack_control_room_allow_free_look );
	addNotetrack_customFunction( "player_rig", "start_baker", ::notetrack_control_room_start_baker );
	addNotetrack_customFunction( "player_rig", "slowmo_start", maps\black_ice_exfil::notetrack_slowmo_start );
	addNotetrack_customFunction( "player_rig", "fire_shake", maps\black_ice_ascend::notetrack_fire_shake );
	addNotetrack_customFunction( "player_rig", "takeoff", maps\black_ice_ascend::notetrack_takeoff );
	addNotetrack_customFunction( "player_rig", "shake_start", maps\black_ice_ascend::notetrack_shake_start );
	addNotetrack_customFunction( "player_rig", "shake_stop", maps\black_ice_ascend::notetrack_shake_stop );
	addNotetrack_customFunction( "player_rig", "grab_shake", maps\black_ice_exfil::notetrack_grab_shake );
	addNotetrack_customFunction( "player_rig", "shockwave_shake", maps\black_ice_exfil::notetrack_shockwave_shake );
	addNotetrack_customFunction( "player_rig", "blast_shake_early", maps\black_ice_command::notetrack_blast_shake_early );
	addNotetrack_customFunction( "player_rig", "blast_shake_late", maps\black_ice_command::notetrack_blast_shake_late );
	//addNotetrack_notify( "player_rig", "show_legs", "notify_exfil_showlegs", "ladder_chase" );
	addNotetrack_flag( "player_rig", "fail_late", "flag_ladder_jumpfail_nojump", "ladder_chase"  );

	
}

#using_animtree( "generic_human" );
generic_human_anims()
{
	// Intro: Snake Cam
	level.scr_anim[ "snake_cam_enemy" ][ "intro_1" ] = %blackice_intro_snakecam_opfor_1;
	level.scr_anim[ "snake_cam_enemy" ][ "intro_2" ] = %blackice_intro_snakecam_opfor_2;
	level.scr_anim[ "snake_cam_enemy" ][ "intro_3" ] = %blackice_intro_snakecam_opfor_3;
	level.scr_anim[ "snake_cam_enemy" ][ "intro_4" ] = %blackice_intro_snakecam_opfor_4;
	level.scr_anim[ "snake_cam_enemy" ][ "intro_5" ] = %blackice_intro_snakecam_opfor_9;
	
	level.scr_anim[ "opfor5" ][ "enemy_dismount" ] = %blackice_intro_snakecam_opfor_5;
	level.scr_anim[ "opfor6" ][ "enemy_dismount" ] = %blackice_intro_snakecam_opfor_6;
	level.scr_anim[ "opfor7" ][ "enemy_dismount" ] = %blackice_intro_snakecam_opfor_7;
	level.scr_anim[ "opfor8" ][ "enemy_dismount" ] = %blackice_intro_snakecam_opfor_8;
	
	// Swim: intro, place charge, etc.
	level.scr_anim[ "scuba_ally" ][ "intro_ally1" ] = %blackice_intro_ally2;
	level.scr_anim[ "scuba_ally" ][ "intro_ally2" ] = %blackice_intro_ally1;
	
	addNotetrack_customFunction( "scuba_ally", "bubbles_1", ::notetrack_intro_ally2_bubbles );
	addNotetrack_notify( "scuba_ally", "line3_1", "notify_snake_cam_dialogue_line3_1" );
	
	// Swim: awaiting player detonate
	level.scr_anim[ "scuba_ally" ][ "intro_ally1_idle" ][0] = %blackice_intro_ally2_idle;
	level.scr_anim[ "scuba_ally" ][ "intro_ally2_idle" ][0] = %blackice_intro_ally1_idle;
	
	// Swim: breach
	level.scr_anim[ "scuba_ally"	   ][ "breach_ally1"	   ] = %blackice_breach_ally2;
	level.scr_anim[ "scuba_ally"	   ][ "breach_ally2"	   ] = %blackice_breach_ally1;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim0"		   ] = %blackice_introbreach_opfor1_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim1"		   ] = %blackice_introbreach_opfor2_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim2"		   ] = %blackice_introbreach_opfor3_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim3"		   ] = %blackice_introbreach_opfor4_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim4"		   ] = %blackice_introbreach_opfor5_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim5"		   ] = %blackice_introbreach_opfor6_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim6"		   ] = %blackice_introbreach_opfor7_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim7"		   ] = %blackice_introbreach_opfor8_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim8"		   ] = %blackice_introbreach_opfor9_death;
	level.scr_anim[ "ice_breach_enemy" ][ "death_anim9"		   ] = %blackice_introbreach_opfor10_death;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor0" ] = %blackice_introbreach_opfor1;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor1" ] = %blackice_introbreach_opfor2;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor2" ] = %blackice_introbreach_opfor3;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor3" ] = %blackice_introbreach_opfor4;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor4" ] = %blackice_introbreach_opfor5;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor5" ] = %blackice_introbreach_opfor6;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor6" ] = %blackice_introbreach_opfor7;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor7" ] = %blackice_introbreach_opfor8;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor8" ] = %blackice_introbreach_opfor9;
	level.scr_anim[ "ice_breach_enemy" ][ "introbreach_opfor9" ] = %blackice_introbreach_opfor10;
	
	//level.scr_anim[ "snake_cam_enemy" ][ "snowmobile_breach_opfor" ] = %blackice_introbreach_opfor_11;
	
					 //   animname 	    notetrack    theNotify 				 

	addNotetrack_notify( "scuba_ally", "line5_1"			, "notify_swim_dialog5_1" );
	addNotetrack_flag(   "scuba_ally", "line5_1"			, "flag_player_clear_to_breach" );				  
	addNotetrack_notify( "scuba_ally", "line6"				, "notify_swim_dialog6" );
	addNotetrack_notify( "scuba_ally", "line6_1"			, "notify_swim_dialog6_1" );
	addNotetrack_notify( "scuba_ally", "line6_2"			, "notify_swim_dialog6_2" );
	addNotetrack_notify( "scuba_ally", "line6_3"			, "notify_swim_dialog6_3" );
	addNotetrack_notify( "scuba_ally", "line6_4"			, "notify_swim_dialog6_4" );
	addNotetrack_notify( "scuba_ally", "line6_5"			, "notify_swim_dialog6_5" );
	addNotetrack_notify( "scuba_ally", "line7"				, "notify_swim_dialog7" );
	addNotetrack_notify( "scuba_ally", "line7_1"			, "notify_swim_dialog7_1" );
	addNotetrack_notify( "scuba_ally", "line8"				, "notify_swim_dialog8" );
	addNotetrack_notify( "scuba_ally", "pullout_detonator"	, "notify_pullout_detonator" );
	addNotetrack_notify( "scuba_ally", "end_breach"			, "notify_swim_end_breach" );
	addNotetrack_notify( "scuba_ally", "allow_movement"		, "notify_swim_allow_movement" );
	
	// Swim: surface
	level.scr_anim[ "scuba_ally" ][ "surface_ally1" ]			= %blackice_surface_ally2;
	level.scr_anim[ "scuba_ally" ][ "surface_ally2" ]			= %blackice_surface_ally1;
	level.scr_anim[ "scuba_ally" ][ "surface_ally1_idle" ][ 0 ] = %blackice_surface_ally2_idle;
	level.scr_anim[ "scuba_ally" ][ "surface_ally2_idle" ][ 0 ] = %blackice_surface_ally1_idle;
	level.scr_anim[ "scuba_ally" ][ "surface_ally1_up" ]		= %blackice_surface_ally2_up;
	level.scr_anim[ "scuba_ally" ][ "surface_ally2_up" ]		= %blackice_surface_ally1_up;
	level.scr_anim[ "scuba_ally" ][ "surface_ally3_up" ]		= %blackice_surface_ally3_up;
	level.scr_anim[ "scuba_ally" ][ "surface_ally3_up_pt2" ]	= %blackice_surface_ally3_up_pt2;
	
	
	addNotetrack_notify( "scuba_ally", "icehole_godrays" , "notify_icehole_godrays" );
	
	//Baker: We need to get on that rig before they dig in.
	addNotetrack_dialogue( "scuba_ally", "wave_to_player", "surface_ally1_up", "blackice_bkr_onthatrig" );
	
	// stairs anim replacements
	archetype = [];
	archetype["run"]["stairs_up"] = %traverse_stair_run_01_blackice; // %traverse_stair_run_01;
	register_archetype( "black_ice_ally", archetype );
	
	// Surface enemy pain reations
	level.scr_anim[ "generic" ][ "camp_pain_dead"	] = %blackice_surface_opfor4;
	level.scr_anim[ "generic" ][ "camp_pain_long_1"	] = %blackice_surface_opfor1;
	level.scr_anim[ "generic" ][ "camp_pain_long_2" ] = %blackice_surface_opfor2;
	level.scr_anim[ "generic" ][ "camp_pain_short_1" ] = %blackice_surface_opfor3;
	level.scr_anim[ "generic" ][ "camp_pain_tumble" ] = %blackice_surface_opfor5;
	
	// Surface enemy chaos
	level.scr_anim[ "generic" ][ "unarmed_run" ] = %unarmed_scared_run_delta;
	level.scr_anim[ "generic" ][ "run_180_1"   ] = %run_reaction_180;
	level.scr_anim[ "generic" ][ "run_180_2"   ] = %civilian_run_upright_turn180;
	
	// exit red building
	level.scr_anim[ "generic" ][ "bc_door_kick" ] = %doorkick_2_cqbrun;
	addNotetrack_customFunction( "generic", "kick", maps\black_ice_camp::bc_door_open, "bc_door_kick" );
	
	// Office infil
	level.scr_anim[ "ally1" ][ "grenade" ] = %doorpeek_grenade;
	level.scr_anim[ "ally1" ][ "kick"	 ] = %doorpeek_kick;
	
	// base camp helo
	level.scr_anim[ "heli_opfor1" ][ "arrive" ] = %blackice_basecamp_heliarrive_opfor1;
	level.scr_anim[ "heli_opfor2" ][ "arrive" ] = %blackice_basecamp_heliarrive_opfor2;
	level.scr_anim[ "heli_opfor3" ][ "arrive" ] = %blackice_basecamp_heliarrive_opfor3;
	level.scr_anim[ "heli_opfor4" ][ "arrive" ] = %blackice_basecamp_heliarrive_opfor4;
	level.scr_anim[ "heli_opfor1" ][ "leave"  ] = %blackice_basecamp_heli_opfor1;
	level.scr_anim[ "heli_opfor2" ][ "leave"  ] = %blackice_basecamp_heli_opfor2;
	level.scr_anim[ "heli_opfor3" ][ "leave"  ] = %blackice_basecamp_heli_opfor3;
	level.scr_anim[ "heli_opfor4" ][ "leave"  ] = %blackice_basecamp_heli_opfor4;
	
	// rig ascend
	level.scr_anim[ "bravo1" ][ "ascend_runin" ] = %blackice_ally1_runin;
	level.scr_anim[ "bravo1" ][ "ascend_waiting" ][0] = %blackice_ally1_waiting;
	level.scr_anim[ "bravo1" ][ "bravo_rope_shoot" ] = %blackice_ally1_rigshoot;
	level.scr_anim[ "bravo1" ][ "bravo_rope_idle" ][0] = %blackice_ally1_rig_idle;
	level.scr_anim[ "bravo1" ][ "bravo_rig_ascend" ] = %blackice_ally1_rigascend;
	level.scr_anim[ "bravo2" ][ "ascend_runin" ] = %blackice_ally2_runin;
	level.scr_anim[ "bravo2" ][ "ascend_waiting" ][0] = %blackice_ally2_waiting;
	level.scr_anim[ "bravo2" ][ "bravo_rope_shoot" ] = %blackice_ally2_rigshoot;
	level.scr_anim[ "bravo2" ][ "bravo_rope_idle" ][0] = %blackice_ally2_rig_idle;
	level.scr_anim[ "bravo2" ][ "bravo_rig_ascend" ] = %blackice_ally2_rigascend;
	
	level.scr_anim[ "ally1" ][ "ascend_runin" ] = %blackice_ally4_runin;
	level.scr_anim[ "ally1" ][ "ascend_waiting" ][0] = %blackice_ally4_waiting;
	level.scr_anim[ "ally1" ][ "alpha_rope_shoot" ] = %blackice_ally4_ropeshoot;
	level.scr_anim[ "ally1" ][ "alpha_hand_rope" ][0] = %blackice_ally4_handrope;
	level.scr_anim[ "ally1" ][ "alpha_rig_ascend" ] = %blackice_ally4_rigascend;
	level.scr_anim[ "ally2" ][ "ascend_runin" ] = %blackice_ally5_runin;
	level.scr_anim[ "ally2" ][ "ascend_waiting" ][0] = %blackice_ally5_waiting;
	level.scr_anim[ "ally2" ][ "alpha_rope_shoot" ] = %blackice_ally5_ropeshoot;
	level.scr_anim[ "ally2" ][ "alpha_hand_rope" ][0] = %blackice_ally5_handrope;
	level.scr_anim[ "ally2" ][ "alpha_rig_ascend" ] = %blackice_ally5_rigascend;
	level.scr_anim[ "opfor" ][ "alpha_rig_ascend" ] = %blackice_opfor_rigascend;
	
//	addNotetrack_notify( "bravo1", "line0", "notify_ascend_dialog0" );
//	addNotetrack_notify( "bravo1", "line1", "notify_ascend_dialog1" );
//	addNotetrack_notify( "bravo1", "line2", "notify_ascend_dialog2" );
//	addNotetrack_notify( "bravo1", "line3", "notify_ascend_dialog3" );
//	addNotetrack_notify( "bravo1", "line4", "notify_ascend_dialog4" );
	addNotetrack_notify( "bravo1", "line5", "notify_ascend_dialog5" );
//	addNotetrack_notify( "bravo1", "line6", "notify_ascend_dialog6" );
//	addNotetrack_notify( "bravo1", "line7", "notify_ascend_dialog7" );
	addNotetrack_flag( "ally1", "dialog_dontstop", "flag_dialog_dontstop" );
	addNotetrack_flag( "ally1", "dialog_weaponsfree", "flag_dialog_weaponsfree" );
	//addNotetrack_customFunction( "bravo1", "rubber_band_start", ::notetrack_ascend_rubberband_bravo_start, "bravo_rig_ascend" );
	addNotetrack_customFunction( "bravo1", "rubber_band_stop", ::notetrack_ascend_rubberband_bravo_stop, "bravo_rig_ascend" );
	addNotetrack_customFunction( "ally1", "rubber_band_start", ::notetrack_ascend_rubberband_alpha_start, "alpha_rig_ascend" );
	addNotetrack_customFunction( "ally1", "rubber_band_stop", ::notetrack_ascend_rubberband_alpha_stop, "alpha_rig_ascend" );
	
	//level.scr_animtree[ "player_legs_intro" ] = #animtree;
	//level.scr_model[ "player_legs_intro" ] = "body_hero_blackice_udt";
	//level.scr_anim[ "player_legs_intro" ][ "intro_legs" ] = %blackice_player_intro_body;
	
	level.scr_animtree[ "player_legs_ascend" ] = #animtree;
	level.scr_model[ "player_legs_ascend" ] = "body_hero_sandman_seal_udt_b";
	level.scr_anim[ "player_legs_ascend" ][ "alpha_rig_ascend_linkup" ] = %blackice_playerlegs_linkup;
	level.scr_anim[ "player_legs_ascend" ][ "alpha_rig_ascend_groundidle" ][0] = %blackice_playerlegs_groundidle;
	level.scr_anim[ "player_legs_ascend" ][ "alpha_rig_ascend" ] = %blackice_playerlegs_rigascend;
	level.scr_anim[ "player_legs_ascend" ][ "rig_ascend_stop" ] = %blackice_playerlegs_rigascend_stop;
	level.scr_anim[ "player_legs_ascend" ][ "rig_ascend_start" ] = %blackice_playerlegs_rigascend_start;
	
	// catwalks falling death
	level.scr_anim[ "generic" ][ "cw_falling_death" ][ 0 ] = %blackice_catwalk_deathfall_1;
	level.scr_anim[ "generic" ][ "cw_falling_death" ][ 1 ] = %blackice_catwalk_deathfall_2;
	level.scr_anim[ "generic" ][ "cw_falling_death" ][ 2 ] = %blackice_catwalk_deathfall_5;
	level.scr_anim[ "generic" ][ "cw_falling_death" ][ 3 ] = %blackice_catwalk_deathfall_6;
	
	// bravo breach
	level.scr_anim [ "bravo1" ][ "bravo_breach" ] = %blackice_commonroom_breach_baker;
	level.scr_anim [ "bravo2" ][ "bravo_breach" ] = %blackice_commonroom_breach_fuentes;							 
	addNotetrack_notify( "bravo1" , "common_room_breach_door", "cw_bravo_breach_door" );
	
	// Catwalks stairs kill
	level.scr_anim[ "ally1" ][ "cw_stairskill" ] = %blackice_stairskill_baker;
	level.scr_anim[ "opfor" ][ "cw_stairskill" ] = %blackice_stairskill_opfor;
	
	// Catwalks high kill
	level.scr_anim[ "ally1"	  ][ "catwalk_kill" ] = %blackice_catwalkkill_ally;
	level.scr_anim[ "ally2"	  ][ "catwalk_kill" ] = %blackice_catwalkkill_ally;
	level.scr_anim[ "generic" ][ "catwalk_kill" ] = %blackice_catwalkkill_opfor;
	
	// Living spaces breach
	level.scr_anim[ "ally1" ][ "cw_tape_breach" ] = %blackice_doortape_ally1;
	level.scr_anim[ "ally2" ][ "cw_tape_breach" ] = %blackice_doortape_ally2;
	
	addNotetrack_customFunction( "ally2" , "doortape_breach", ::notetrack_cw_tape_explode, "cw_tape_breach"  );
	
	// Barracks hallway clear
	level.scr_anim[ "ally1"	  ][ "cw_hallsweep" ] = %blackice_hallwayclear_baker;
	level.scr_anim[ "ally2"	  ][ "cw_hallsweep" ] = %blackice_hallwayclear_fuentes;
	level.scr_anim[ "generic" ][ "cw_hallsweep" ] = %blackice_hallwayclear_opfor;
	//Fuentes: Clear.  Move up.
	addNotetrack_dialogue( "ally2", "fuentes_va_clear_1", "cw_hallsweep", "blackice_fnt_clearmoveup" );
	//Baker: Rooms clear. Go.
	addNotetrack_dialogue( "ally1", "baker_vo_clear_1", "cw_hallsweep", "blackice_bkr_roomscleargo" );
	//Fuentes: Contact.
	addNotetrack_dialogue( "ally2", "fuentes_vo_contact", "cw_hallsweep", "black_ice_fnt_contact" );
	//Baker: Clear.
	addNotetrack_dialogue( "ally1", "baker_vo_clear_2", "cw_hallsweep", "blackice_bkr_clear" );
	//Fuentes: Room clear.
	addNotetrack_dialogue( "ally2", "fuentes_va_clear_2", "cw_hallsweep", "blackice_fnt_roomclear" );
	addNotetrack_notify( "ally2", "fuentes_vo_contact", "cw_hallsweep_ally2_attack", "cw_hallsweep" );
	addNotetrack_customFunction( "generic", "opfor_dead", ::vig_actor_kill, "cw_hallsweep" );
		
	// common room breach
	level.scr_anim[ "ally1" ][ "rec_breach_check" ]		  = %blackice_commonroom_ally1_check;
	level.scr_anim[ "ally1" ][ "rec_breach"		  ]		  = %blackice_commonroom_ally1_pt1;
	level.scr_anim[ "ally2" ][ "rec_breach"		  ]		  = %blackice_commonroom_ally2_pt1;
	level.scr_anim[ "ally1" ][ "rec_breach_idle" ][ 0 ]	  = %blackice_commonroom_ally1_idle;
	level.scr_anim[ "ally2" ][ "rec_breach_idle" ][ 0 ]	  = %blackice_commonroom_ally2_idle;
	level.scr_anim[ "ally1"	  ][ "rec_breach_move"		] = %blackice_commonroom_ally1_pt2;
	level.scr_anim[ "ally2"	  ][ "rec_breach_move"		] = %blackice_commonroom_ally2_pt2;
	level.scr_anim[ "generic" ][ "exposed_flashbang_v1" ] = %exposed_flashbang_v1;
	level.scr_anim[ "generic" ][ "exposed_flashbang_v3" ] = %exposed_flashbang_v3;	   
	addNotetrack_notify( "ally1"   , "blast"	  , "cw_common_door_down"  , "rec_breach" );
	addNotetrack_notify( "ally1"   , "throwaflash", "cw_common_throw_flash", "rec_breach" );
	
	// Flarestack
	level.scr_anim[ "ally1" ][ "flarestack_start" ]			  = %blackice_flamestack_ally1;
	level.scr_anim[ "ally1" ][ "flarestack_idle" ][ 0 ]		  = %blackice_flamestack_ally1_idle;
	level.scr_anim[ "ally1" ][ "flarestack_end" ]			  = %blackice_flamestack_ally1_end;	
	addNotetrack_notify( "ally1"   , "start_scan", "notify_flarestack_start_scan", "flarestack_start" );	
	addNotetrack_notify( "ally1"   , "pistol_pullout", "notify_flarestack_baker_pistol_pullout", "flarestack_end" );
	addNotetrack_notify( "ally1"   , "pistol_fire"	 , "notify_flarestack_baker_pistol_fire", "flarestack_end" );
	addNotetrack_notify( "ally1"   , "pistol_putawayz", "notify_flarestack_baker_pistol_putaway", "flarestack_end" );
	
	level.scr_anim[ "flarestack_guy" ][ "flarestack_init_loop" ][ 0 ] = %blackice_flamestack_opfor1_startidle;
	level.scr_anim[ "flarestack_guy" ][ "flarestack_start" ]		  = %blackice_flamestack_opfor1;
	level.scr_anim[ "flarestack_guy" ][ "flarestack_idle" ][ 0 ] = %blackice_flamestack_opfor1_idle;
	level.scr_anim[ "flarestack_guy" ][ "flarestack_end" ]			  = %blackice_flamestack_opfor1_end;	
	addNotetrack_notify( "flarestack_guy", "death", "notify_flarestack_enemy_kill", "flarestack_end" );
	addNotetrack_notify( "flarestack_guy", "audio_point", "notify_flarestack_enemy_on_console", "flarestack_start" );
	
	level.scr_anim[ "ally1" ][ "flarestack_exit" ]			  = %blackice_flamestack_ally1_exit;
	addNotetrack_notify( "ally1", "door_open", "notify_flamestack_door_open", "flarestack_exit" );	
	
	// Generic idle anims
	level.scr_anim[ "ally1" ][ "cover_left_idle" ][ 0 ] = %blackice_corner_standL_alert_idle;
	
	// Baker derrick hold	
	level.scr_anim[ "ally1" ][ "refinery_hold_init" ]	   = %blackice_baker_hold2_init;
	level.scr_anim[ "ally1" ][ "refinery_hold_idle" ][ 0 ] = %blackice_baker_hold2_idle;
	level.scr_anim[ "ally1" ][ "refinery_hold_end" ]	   = %blackice_baker_hold2_end;
	
	// Derrick explosion reactions
	level.scr_anim[ "refinery_guy" ][ "derrick_explode_reaction_1" ] = %blackice_explosionreact1;
	level.scr_anim[ "refinery_guy" ][ "derrick_explode_reaction_2" ] = %blackice_explosionreact2;
	
	level.scr_anim[ "generic" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;	
	level.scr_anim[ "refinery_guy1" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;
	level.scr_anim[ "refinery_guy2" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;
	level.scr_anim[ "refinery_guy3" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;
	level.scr_anim[ "refinery_guy4" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;
	level.scr_anim[ "refinery_guy5" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;
	level.scr_anim[ "refinery_guy6" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;
	level.scr_anim[ "refinery_guy7" ][ "derrick_explode_death" ] = %death_explosion_run_F_v2;
		
	// Refinery scene
	level.scr_anim[ "refinery_guy1" ][ "derrick_explode_scene" ] = %blackice_topside_opfor1;
	level.scr_anim[ "refinery_guy2" ][ "derrick_explode_scene" ] = %blackice_topside_opfor2;
	level.scr_anim[ "refinery_guy3" ][ "derrick_explode_scene" ] = %blackice_topside_opfor3;
	level.scr_anim[ "refinery_guy4" ][ "derrick_explode_scene" ] = %blackice_topside_opfor4;
	level.scr_anim[ "refinery_guy5" ][ "derrick_explode_scene" ] = %blackice_topside_opfor5;
	level.scr_anim[ "refinery_guy6" ][ "derrick_explode_scene" ] = %blackice_topside_opfor6;
	level.scr_anim[ "refinery_guy7" ][ "derrick_explode_scene" ] = %blackice_topside_opfor7;
	
	level.scr_anim[ "refinery_guy6" ][ "death_pose" ] = %blackice_topside_opfor6_dead;
	
	addNotetrack_notify( "refinery_guy1", "derrick_detonation", "notify_refinery_explosion_start" );	 
	//addNotetrack_notify( "refinery_guy1", "baker_hold", "notify_refinery_baker_hold" );
		
	// Tanks catwalk scene
	level.scr_anim[ "tanks_guy_1" ][ "tanks_bridge_fall_scene" ] = %blackice_tanks_catwalk_collapse_opfor1;
	level.scr_anim[ "tanks_guy_1" ][ "tanks_bridge_fall_death" ] = %blackice_tanks_catwalk_collapse_opfor1_death;
	level.scr_anim[ "tanks_guy_2" ][ "tanks_bridge_fall_scene" ] = %blackice_tanks_catwalk_collapse_opfor2;
	
	addNotetrack_customFunction( "tanks_guy_1", "start_custom_death", ::notetrack_tanks_start_custom_death, "tanks_bridge_fall_scene" );
	addNotetrack_customFunction( "tanks_guy_1", "end_custom_death", ::notetrack_tanks_end_custom_death, "tanks_bridge_fall_scene" );		

	// Engine Room door
	level.scr_anim[ "ai0" ][ "engineroom_workers_throughdoor" ] = %blackice_engineroom_throughdoor_worker1;
	level.scr_anim[ "ai1" ][ "engineroom_workers_throughdoor" ] = %blackice_engineroom_throughdoor_worker2;
	level.scr_anim[ "ai0" ][ "engineroom_workers_idle" ][ 0 ] = %blackice_engineroom_idle_worker1;
	level.scr_anim[ "ai1" ][ "engineroom_workers_idle" ][ 0 ] = %blackice_engineroom_idle_worker2;
	level.scr_anim[ "ai0" ][ "engineroom_workers_death" ] = %blackice_engineroom_death_worker1;
	level.scr_anim[ "ai1" ][ "engineroom_workers_death" ] = %blackice_engineroom_death_worker2;
	
	// Engine room enter
	level.scr_anim[ "ally1" ][ "engine_room_enter" ] = %blackice_engineroom_postup_ally1;
	
	// Engine Room hallway
	level.scr_anim[ "ai0" ][ "engineroom_worker2_run" ] = %blackice_engineroom2_walkout;
	level.scr_anim[ "ai0" ][ "engineroom_worker2_idle" ][ 0 ] = %blackice_engineroom2_idle;
	
	// Engine room fire extinguisher guys
	level.scr_anim[ "extinguisher_guy" ][ "extinguisher_loop1" ][0] = %blackice_engineroom_firefighter1_idle;
	level.scr_anim[ "extinguisher_guy" ][ "extinguisher_loop2" ][0] = %blackice_engineroom_firefighter2_idle;
	level.scr_anim[ "extinguisher_guy" ][ "extinguisher_loop3" ][0] = %blackice_engineroom_firefighter3_idle;
	
	level.scr_anim[ "extinguisher_guy" ][ "extinguisher_loop_break1" ] = %blackice_engineroom_firefighter1;
	level.scr_anim[ "extinguisher_guy" ][ "extinguisher_loop_break2" ] = %blackice_engineroom_firefighter2;
	level.scr_anim[ "extinguisher_guy" ][ "extinguisher_loop_break3" ] = %blackice_engineroom_firefighter3;	
	
	// Mudpumps
	level.scr_anim[ "ally1" ][ "topdrive_reaction" ] = %blackice_explosionreact2;	
	
	level.scr_anim[ "ally1" ][ "topdrive_duck_full" ] = %blackice_topdrive_ally2;
	level.scr_anim[ "ally1" ][ "topdrive_duck" ] = %blackice_topdrive_ally1;
	level.scr_anim[ "ally2" ][ "topdrive_duck" ] = %blackice_topdrive_ally1;
	
	addNotetrack_notify( "ally1", "heli_notify", "notify_spawn_pipedeck_heli", "topdrive_duck" );		
	
	// Pipe Deck boat scene
	level.scr_anim[ "lifeboat_guy1" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor1;
	level.scr_anim[ "lifeboat_guy2" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor2;
	level.scr_anim[ "lifeboat_guy3" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor3;
	level.scr_anim[ "lifeboat_guy4" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor4;	
	level.scr_anim[ "lifeboat_guy5" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor5;
	level.scr_anim[ "lifeboat_guy6" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor6;
	level.scr_anim[ "lifeboat_guy7" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor7;
	level.scr_anim[ "lifeboat_guy8" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor8;		
	level.scr_anim[ "lifeboat_guy9" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor9;
	level.scr_anim[ "lifeboat_guy10" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor10;
	level.scr_anim[ "lifeboat_guy11" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor11;
	level.scr_anim[ "lifeboat_guy12" ][ "lifeboat_deploy" ] = %blackice_lifeboat_opfor12;	
	
	
	// Derrick scene
	level.scr_anim[ "derrick_guy1" ][ "heat_shield_run" ] = %blackice_pipedeck_heat_opfor1;
	level.scr_anim[ "derrick_guy2" ][ "heat_shield_run" ] = %blackice_pipedeck_heat_opfor2;
	
	// Command center enter
	level.scr_anim[ "ally1" ][ "command_enter_approach" ] = %blackice_baker_controlroomdoor_1;
	level.scr_anim[ "ally1" ][ "command_enter" ] = %blackice_baker_controlroomdoor_2;
		
	// Command Center Baker
	level.scr_anim[ "ally1" ][ "command_init" ] = %blackice_controlroompanel_baker_init;
	level.scr_anim[ "ally1" ][ "command_loop" ][ 0 ] = %blackice_controlroompanel_baker_loop;
	level.scr_anim[ "ally1" ][ "command_start" ] = %blackice_controlroompanel_baker_Start;
	level.scr_anim[ "ally1" ][ "command_control" ] = %blackice_controlroompanel_baker_control;
	level.scr_anim[ "ally1" ][ "command_end" ] = %blackice_controlroompanel_baker_end;
	level.scr_anim[ "ally1" ][ "command_early" ] = %blackice_controlroompanel_baker_early;
	level.scr_anim[ "ally1" ][ "command_late" ] = %blackice_controlroompanel_baker_late;
	
			    	 //   animname    notetrack 		   the notify 				  anime
	addNotetrack_notify( "ally1"   , "opfor1_anim_start", "notify_baker_push_opfor"	, "command_init" );
	addNotetrack_notify( "ally1"   , "dialog_instruct_1", "notify_dialog_instruct_1", "command_start" );
	addNotetrack_notify( "ally1"   , "dialog_instruct_2", "notify_dialog_instruct_2", "command_start" );
	addNotetrack_notify( "ally1"   , "dialog_instruct_3", "notify_dialog_instruct_3", "command_start" );
	addNotetrack_notify( "ally1"   , "dialog_instruct_4", "notify_dialog_instruct_4", "command_start" );
	addNotetrack_notify( "ally1"   , "dialog_instruct_5", "notify_dialog_instruct_5", "command_start" );
	//addNotetrack_notify( "ally1"   , "focus_baker", 	  "notify_focus_baker", 	  "command_start" );
	//addNotetrack_notify( "ally1"   , "focus_panel", 	  "notify_focus_panel", 	  "command_start" );
//	addNotetrack_customFunction( "ally1"   , "dialog_count_1"	, ::notetrack_command_dialog_count_1   , "command_control" );
//	addNotetrack_customFunction( "ally1"   , "dialog_count_2"	, ::notetrack_command_dialog_count_2   , "command_control" );
//	addNotetrack_customFunction( "ally1"   , "dialog_count_3"	, ::notetrack_command_dialog_count_3   , "command_control" );
//	addNotetrack_customFunction( "ally1"   , "dialog_count_4"	, ::notetrack_command_dialog_count_4   , "command_control" );
//	addNotetrack_customFunction( "ally1"   , "dialog_count_5"	, ::notetrack_command_dialog_count_5   , "command_control" );
//	addNotetrack_customFunction( "ally1"   , "dialog_count_6"	, ::notetrack_command_dialog_count_6   , "command_control" );
//	addNotetrack_customFunction( "ally1"   , "fail_late"		, ::notetrack_command_fail_late		   , "command_control" );
	
							 //   animname    notetrack 		   function 						      anime 	
	addNotetrack_customFunction( "ally1"   , "dialog_fail_early", ::notetrack_command_dialog_fail_early, "command_early" );
	addNotetrack_customFunction( "ally1"   , "dialog_fail_late" , ::notetrack_command_dialog_fail_late , "command_late" );
	addNotetrack_customFunction( "ally1"   , "dialog_end"		, ::notetrack_command_dialog_end	   , "command_end" );
		
	// Command Center Enemies
	level.scr_anim[ "command_enemy_1" ][ "command_idle" ][ 0 ] = %blackice_controlroompanel_opfor1_loop;
	level.scr_anim[ "command_enemy_1" ][ "command_death" ]	   = %blackice_controlroompanel_opfor1_death;
	level.scr_anim[ "command_enemy_1" ][ "command_start" ]	   = %blackice_controlroompanel_opfor1_death_push;
	level.scr_anim[ "command_enemy_2" ][ "command_idle" ][ 0 ] = %blackice_controlroompanel_opfor2_loop;
	level.scr_anim[ "command_enemy_2" ][ "command_death" ]	   = %blackice_controlroompanel_opfor2_death;
	level.scr_anim[ "command_enemy_2" ][ "command_start" ]	   = %blackice_controlroom_player_start_opfor;
	
	
	//exfil
	level.scr_anim [ "ally1" ][ "exfil_corner_cut" ] = %blackice_controlroom_exfil_stairs_1;	
	level.scr_anim [ "ally2" ][ "exfil_corner_cut" ] = %blackice_controlroom_exfil_stairs_2;
	level.scr_anim [ "ally1" ][ "exfil_steam_react" ] = %blackice_controlroom_exfil_finalroom_1;	
	level.scr_anim [ "ally2" ][ "exfil_steam_react" ] = %blackice_controlroom_exfil_finalroom_2;
	level.scr_anim [ "ally1" ][ "ladder_chase" ] = %blackice_ally1_exfil_explode;	
	level.scr_anim [ "ally2" ][ "ladder_chase" ] = %blackice_ally2_exfil_explode;
	
	level.scr_animtree[ "player_legs_exfil" ] = #animtree;
	level.scr_model[ "player_legs_exfil" ] = "body_hero_sandman_seal_udt_b";
	level.scr_anim[ "player_legs_exfil" ][ "ladder_chase" ] = %blackice_playerlegs_exfil_explode; 
	
	
	addNotetrack_notify( "ally1"  , "pipe_burst", "notify_exfil_steam_burst", "exfil_steam_react" );
	addNotetrack_notify( "ally1"  , "start_ladder_chase", "notify_start_ladder_chase", "exfil_steam_react" );
	addNotetrack_flag( "ally1"  , "pipe_explosion", "flag_command_pipes_explosion", "exfil_steam_react" );
	
	//addNotetrack_customFunction( "ally1", "player_grab_ladder", ::notetrack_player_grab_ladder, "ladder_chase" );
	addNotetrack_customFunction( "ally1", "baker_dialog_1", ::notetrack_exfil_dialog_1, "ladder_chase" );
	addNotetrack_customFunction( "ally1", "baker_dialog_2", ::notetrack_exfil_dialog_2, "ladder_chase" );
	addNotetrack_customFunction( "ally1", "player_teleport", ::notetrack_player_teleport, "ladder_chase" );
	addNotetrack_customFunction( "ally1", "heli_swing", ::notetrack_heli_swing, "ladder_chase" );
	addNotetrack_customFunction( "ally1", "start_slomo", ::notetrack_start_slomo, "ladder_chase" );
	addNotetrack_customFunction( "ally1", "end_slomo", ::notetrack_end_slomo, "ladder_chase" );

	// Rubber banding
	level.scr_anim[ "ally1" ][ "DRS_sprint" ]				 = %sprint1_loop;
	level.scr_anim[ "ally1" ][ "DRS_combat_jog" ]			 = %combat_jog;
	level.scr_anim[ "ally2" ][ "DRS_sprint" ]				 = %sprint1_loop;
	level.scr_anim[ "ally2" ][ "DRS_combat_jog" ]			 = %combat_jog;	
}

#using_animtree( "script_model" );
script_model_anims()
{
	// Snake Cam
	level.scr_animtree[ "snake_cam" ] = #animtree;
	level.scr_model[ "snake_cam" ] = "tag_origin";
	level.scr_anim[ "snake_cam" ][ "retract" ] = %blackice_intro_snakecam_retract;
	
	addNotetrack_customFunction( "snake_cam" , "lens_water", ::notetrack_snake_cam_lens_water );
	addNotetrack_customFunction( "snake_cam" , "underwater_transition", ::notetrack_snake_cam_underwater_transition );
	addNotetrack_notify( "snake_cam"   , "rumble_cam_1", "notify_rumble_cam_1"	, "retract" );
	addNotetrack_notify( "snake_cam"   , "rumble_cam_2", "notify_rumble_cam_2"	, "retract" );
	addNotetrack_notify( "snake_cam"   , "rumble_cam_3", "notify_rumble_cam_3"	, "retract" );
	addNotetrack_notify( "snake_cam"   , "rumble_cam_4", "notify_rumble_cam_4"	, "retract" );
		
	// Intro Breach
	//level.scr_animtree[ "player_gun_intro" ] = #animtree;
	//level.scr_model[ "player_gun_intro" ] = "viewmodel_underwater_aps";
	//level.scr_anim[ "player_gun_intro" ][ "intro_gun" ] = %blackice_player_intro_gun;
	
	level.scr_animtree[ "snowmobile_1" ] = #animtree;
	level.scr_model[ "snowmobile_1" ] = "vehicle_snowmobile_iw6";
	level.scr_anim[ "snowmobile_1" ][ "intro_drive" ] = %blackice_intro_drive_snowmobile_1;
	//level.scr_anim[ "snowmobile_1" ][ "snowmobile_breach" ] = %blackice_introbreach_snowmobile_01;
	
	level.scr_animtree[ "snowmobile_2" ] = #animtree;
	level.scr_model[ "snowmobile_2" ] = "vehicle_snowmobile_iw6";
	level.scr_anim[ "snowmobile_2" ][ "intro_drive" ] = %blackice_intro_drive_snowmobile_2;
		
	level.scr_animtree[ "gaz71" ] = #animtree;
	level.scr_model[ "gaz71" ] = "vehicle_gaz71_iw6";
	level.scr_anim[ "gaz71" ][ "intro_drive" ] = %blackice_intro_drive_gaz71;
	level.scr_anim[ "gaz71" ][ "intro_breach" ] = %blackice_introbreach_gaz71;
	
	addNotetrack_notify( "gaz71", "line2_1", "notify_snake_cam_dialogue_line2_1" );
	addNotetrack_notify( "gaz71", "line2_2", "notify_snake_cam_dialogue_line2_2" );
	addNotetrack_notify( "gaz71", "line2_3", "notify_snake_cam_dialogue_line2_3" );
	addNotetrack_notify( "gaz71", "line2_4", "notify_snake_cam_dialogue_line2_4" );
	addNotetrack_notify( "gaz71", "rumble_snowmobile_1", "notify_rumble_snowmobile_1" );
	addNotetrack_notify( "gaz71", "rumble_snowmobile_2", "notify_rumble_snowmobile_2" );
	addNotetrack_notify( "gaz71", "rumble_truck_1", "notify_rumble_truck_1" );
	addNotetrack_notify( "gaz71", "rumble_truck_2", "notify_rumble_truck_2" );
	addNotetrack_notify( "gaz71", "rumble_truck_3", "notify_rumble_truck_3" );
	addNotetrack_notify( "gaz71", "rumble_truck_off", "notify_rumble_truck_off" );
	
	//addNotetrack_customFunction( "gaz71" , "rumble_start", ::BLANK );
	//addNotetrack_customFunction( "gaz71" , "rumble_stop", ::BLANK );
	addNotetrack_customFunction( "gaz71" , "camera_retract", ::notetrack_snake_cam_retract );
	addNotetrack_customFunction( "gaz71" , "enemy_dismount", ::notetrack_snake_enemy_dismount );
		
	level.scr_animtree[ "gaztiger" ] = #animtree;
	level.scr_model[ "gaztiger" ] = "vehicle_iveco_lynx_iw6";
	level.scr_anim[ "gaztiger" ][ "intro_drive" ] = %blackice_intro_drive_gaztiger;
	level.scr_anim[ "gaztiger" ][ "intro_breach" ] = %blackice_introbreach_gaztiger;
	
	level.scr_animtree[ "gaztiger_2" ] = #animtree;
	level.scr_model[ "gaztiger_2" ] = "vehicle_iveco_lynx_iw6";
	level.scr_anim[ "gaztiger_2" ][ "intro_drive" ] = %blackice_intro_drive_gaztiger2;
	
	level.scr_animtree[ "bm21_1" ] = #animtree;
	level.scr_model[ "bm21_1" ] = "vehicle_tatra_t815_iw6_covered";
	level.scr_anim[ "bm21_1" ][ "intro_drive" ] = %blackice_intro_drive_truck1;
	level.scr_anim[ "bm21_1" ][ "intro_breach" ] = %blackice_introbreach_truck1; 
	level.scr_anim[ "bm21_1" ][ "surface_truck" ] = %blackice_intro_truck_fall;
	
	level.scr_animtree[ "blackice_ice_chunks_truck" ] = #animtree;
	level.scr_model[ "blackice_ice_chunks_truck" ] = "blackice_ice_chunks_truck";
	level.scr_anim[ "blackice_ice_chunks_truck" ][ "surface_truck" ] = %blackice_intro_truck_fall_icechunks;
		
	level.scr_animtree[ "bm21_2" ] = #animtree;
	level.scr_model[ "bm21_2" ] = "vehicle_tatra_t815_iw6_covered";
	level.scr_anim[ "bm21_2" ][ "intro_drive" ] = %blackice_intro_drive_truck2;
	level.scr_anim[ "bm21_2" ][ "intro_breach" ] = %blackice_introbreach_truck2;
	
	level.scr_animtree[ "bm21_3" ] = #animtree;
	level.scr_model[ "bm21_3" ] = "vehicle_tatra_t815_iw6_covered";
	level.scr_anim[ "bm21_3" ][ "intro_drive" ] = %blackice_intro_drive_truck3;
	
	level.scr_animtree[ "introbreach_props" ] = #animtree;
	level.scr_model[ "introbreach_props" ] = "blackice_introbreach_props";
	level.scr_anim[ "introbreach_props" ][ "intro_breach" ] = %blackice_introbreach_props_01;
	level.scr_anim[ "introbreach_props" ][ "intro_breach_end" ] = %blackice_introbreach_props_end;
	
	level.scr_animtree[ "ice_chunks1" ] = #animtree;
	level.scr_model[ "ice_chunks1" ] = "blackice_infil_ice_chunks_1";
	level.scr_anim[ "ice_chunks1" ][ "intro_breach" ] = %blackice_introbreach_ice1;
	level.scr_anim[ "ice_chunks1" ][ "intro_breach_loop" ][0] = %blackice_introbreach_ice1_loop;
	level.scr_anim[ "ice_chunks1" ][ "intro_breach_end" ] = %blackice_introbreach_ice1_end;
	
	level.scr_animtree[ "ice_chunks2" ] = #animtree;
	level.scr_model[ "ice_chunks2" ] = "blackice_infil_ice_chunks_2";
	level.scr_anim[ "ice_chunks2" ][ "intro_breach" ] = %blackice_introbreach_ice2;
	level.scr_anim[ "ice_chunks2" ][ "intro_breach_loop" ][0] = %blackice_introbreach_ice2_loop;
	level.scr_anim[ "ice_chunks2" ][ "intro_breach_end" ] = %blackice_introbreach_ice2_end;
	
	level.scr_animtree[ "breach_water" ] = #animtree;
	level.scr_model[ "breach_water" ] = "blackice_breach_water";
	level.scr_anim[ "breach_water" ][ "intro_breach" ] = %blackice_introbreach_water;
	level.scr_anim[ "breach_water" ][ "intro_breach_end" ] = %blackice_introbreach_water_end;
	
	// Living spaces breach
	level.scr_animtree[ "tape_breach_door"	   ]				 = #animtree;
	level.scr_animtree[ "tape_breach_door_dam" ]				 = #animtree;
	level.scr_model	  [ "tape_breach_door"	   ]				 = "bulkhead_door";
	level.scr_model	  [ "tape_breach_door_dam" ]				 = "bulkhead_door_damaged";
	level.scr_anim[ "tape_breach_door"	   ][ "cw_tape_breach" ] = %blackice_doortape_door;
	level.scr_anim[ "tape_breach_door_dam" ][ "cw_tape_breach" ] = %blackice_doortape_door;
	
	level.scr_animtree[ "tape_breach_tape" ]				 = #animtree;
	level.scr_model	  [ "tape_breach_tape" ]				 = "blackice_explosive_tape";
	level.scr_anim[ "tape_breach_tape" ][ "cw_tape_breach" ] = %blackice_doortape_tape;
	
	// Barracks hallway clear
	level.scr_animtree[ "hallway_door" ]			   = #animtree;
	level.scr_model	  [ "hallway_door" ]			   = "bi_hallway_door";
	level.scr_anim[ "hallway_door" ][ "cw_hallsweep" ] = %blackice_hallwayclear_door;
	
	// common room breach
	level.scr_animtree[ "breach_door_charge" ]		   = #animtree;
	level.scr_model	  [ "breach_door_charge" ]		   = "blackice_comm_room_breacher";
	level.scr_anim[ "breach_door_charge" ][ "breach" ] = %blackice_commonroom_charge;
	level.scr_animtree[ "common_door_dam" ]			   = #animtree;
	level.scr_model	  [ "common_door_dam" ]			   = "hallway_double_door_damaged";
	level.scr_anim[ "common_door_dam" ][ "explode" ]   = %blackice_commonroom_door;
	level.scr_animtree[ "common_door" ]			   = #animtree;
	level.scr_model	  [ "common_door" ]			   = "hallway_double_door";
	level.scr_anim[ "common_door" ][ "bullets" ]   = %blackice_commonroom_door_bullets;
	
	
	// Oil Pumps
	level.scr_animtree[ "oil_pump" ] = #animtree;
	level.scr_anim[ "oil_pump" ][ "motion" ] = %oil_pump_2;
	
	// Flarestack
	level.scr_animtree[ "flarestack_door_in" ]					 = #animtree;	
	level.scr_anim[ "flarestack_door_in" ][ "flarestack_start" ] = %blackice_flamestack_door;
	
	level.scr_animtree[ "baker_sidearm" ] = #animtree;
	level.scr_model[ "baker_sidearm" ] = "weapon_walther_p99_iw5";
	
	level.scr_animtree[ "flarestack_door_out" ]					 = #animtree;	
	level.scr_anim[ "flarestack_door_out" ][ "flarestack_exit" ] = %blackice_flamestack_door_exit;	
	
	// Derrick
	level.scr_animtree[ "derrick" ]					 = #animtree;
	level.scr_model	  [ "derrick" ]					 = "blackice_oil_derrick";
	level.scr_anim[ "derrick" ][ "collapse"		   ] = %blackice_derrick_collapse;
	level.scr_anim[ "derrick" ][ "small_explosion" ] = %blackice_derrick_small_explosion;
	
	///test for moving camera
	level.scr_animtree[ "tag_origin" ]					= #animtree;
	level.scr_anim[ "tag_origin" ][ "cam_test"] 		= %blackice_player_exfil_jumpcam;
	
							 //   animname    notetrack 	     function 							 
	addNotetrack_customFunction( "derrick" , "small_explosion", ::notetrack_derrick_small_explosion );
	addNotetrack_customFunction( "derrick" , "large_explosion", ::notetrack_derrick_large_explosion );
	addNotetrack_customFunction( "derrick" , "traveling_block_impact", ::notetrack_traveling_block_impact );
	addNotetrack_customFunction( "derrick" , "impact_rig"	  , ::notetrack_derrick_impact_rig );
	addNotetrack_customFunction( "derrick" , "start_combat"   , ::notetrack_refinery_start_combat );
	
	// Travelling block (part of derrick explosion) 
	level.scr_animtree[ "traveling_block" ]				= #animtree;
	level.scr_model[ "traveling_block" ]				= "blackice_traveling_block";	
	level.scr_anim[ "traveling_block" ][ "derrick_explosion" ] = %blackice_derrick_traveling_block2;
	
	addNotetrack_customFunction( "traveling_block" , "hit_1", ::notetrack_derrick_debris_hit_1 );
	addNotetrack_customFunction( "traveling_block" , "hit_2", ::notetrack_derrick_debris_hit_2 );
	
	// big chunk (part of derrick explosion that slides near the player into the barrels) 
	level.scr_animtree[ "derrick_chunk" ]				 = #animtree;
	level.scr_model[ "derrick_chunk" ]				     = "blackice_derrick_chunk";	
	level.scr_anim[ "derrick_chunk" ][ "derrick_explosion" ] = %blackice_derrick_traveling_block;
	
	addNotetrack_customFunction( "derrick_chunk" , "hitbarrels", ::notetrack_derrick_chunk_hit_barrels );
	
	// big chunk (part of derrick explosion that slides near the player into the barrels) 
	level.scr_animtree[ "oiltank_catwalk" ]				 = #animtree;
	level.scr_model[ "oiltank_catwalk" ]				     = "blackice_refinery_tank_catwalk_destroyed";	
	level.scr_anim[ "oiltank_catwalk" ][ "oiltank_catwalk" ] = %blackice_derrick_oiltank_catwalk;
	
	addNotetrack_customFunction( "oiltank_catwalk", "swap_catwalk", ::notetrack_oiltank_catwalk_swap );
	
	//misc objects that react to the oiltank explosion
	level.scr_animtree[ "oiltank_forklift" ]				= #animtree;
	level.scr_model[ "oiltank_forklift" ]				     = "vehicle_forklift_blackice";	
	level.scr_anim[ "oiltank_forklift" ][ "derrick_explosion" ] = %blackice_derrick_debris_forklift;
	
	level.scr_animtree[ "oiltank_forklift_crate" ]				= #animtree;
	level.scr_model[ "oiltank_forklift_crate" ]				     = "ch_crate48x64_snow_no_tweak";	
	level.scr_anim[ "oiltank_forklift_crate" ][ "derrick_explosion" ] = %blackice_derrick_debris_forklift_crate;
	
	level.scr_animtree[ "oiltank_spool" ]				= #animtree;
	level.scr_model[ "oiltank_spool" ]				     = "wire_spool_metal";	
	level.scr_anim[ "oiltank_spool" ][ "derrick_explosion" ] = %blackice_derrick_debris_spool;
	
	level.scr_animtree[ "oiltank_debris_1_1" ]				= #animtree;
	level.scr_model[ "oiltank_debris_1_1" ]				     = "junk_scrap_08";	
	level.scr_anim[ "oiltank_debris_1_1" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_debris_1;
	
	level.scr_animtree[ "oiltank_debris_1_2" ]				= #animtree;
	level.scr_model[ "oiltank_debris_1_2" ]				     = "junk_scrap_08";	
	level.scr_anim[ "oiltank_debris_1_2" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_debris_2;
	
	level.scr_animtree[ "oiltank_debris_1_3" ]				= #animtree;
	level.scr_model[ "oiltank_debris_1_3" ]				     = "junk_scrap_08";	
	level.scr_anim[ "oiltank_debris_1_3" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_debris_3;
	
	level.scr_animtree[ "oiltank_debris_2" ]				= #animtree;
	level.scr_model[ "oiltank_debris_2" ]				     = "junk_scrap_05";	
	level.scr_anim[ "oiltank_debris_2" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_debris_4;
	
	level.scr_animtree[ "oiltank_debris_3" ]				= #animtree;
	level.scr_model[ "oiltank_debris_3" ]				     = "junk_scrap_10";	
	level.scr_anim[ "oiltank_debris_3" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_debris_5;
	
	
	// barrels that get crushed 
	level.scr_animtree[ "barrel_crush" ]				= #animtree;
	level.scr_model[ "barrel_crush" ]				= "blackice_barrel_crush";	
	level.scr_anim[ "barrel_crush" ][ "barrel_crush_1" ] = %blackice_derrick_barrel_1;
	level.scr_anim[ "barrel_crush" ][ "barrel_crush_2" ] = %blackice_derrick_barrel_2;
	level.scr_anim[ "barrel_crush" ][ "barrel_crush_3" ] = %blackice_derrick_barrel_3;
	level.scr_anim[ "barrel_crush" ][ "barrel_crush_4" ] = %blackice_derrick_barrel_4;
	level.scr_anim[ "barrel_crush" ][ "barrel_crush_5" ] = %blackice_derrick_barrel_5;
	
	level.scr_animtree[ "barrel_oiltank_crush_1" ]				= #animtree;
	level.scr_animtree[ "barrel_oiltank_crush_2" ]				= #animtree;
	level.scr_animtree[ "barrel_oiltank_crush_3" ]				= #animtree;
	level.scr_animtree[ "barrel_oiltank_crush_4" ]				= #animtree;
	level.scr_animtree[ "barrel_oiltank_crush_5" ]				= #animtree;
	level.scr_animtree[ "barrel_oiltank_crush_6" ]				= #animtree;
	level.scr_animtree[ "barrel_oiltank_crush_7" ]				= #animtree;
	level.scr_model[ "barrel_oiltank_crush_1" ]				= "blackice_barrel_crush";	
	level.scr_model[ "barrel_oiltank_crush_2" ]				= "blackice_barrel_crush";	
	level.scr_model[ "barrel_oiltank_crush_3" ]				= "blackice_barrel_crush";	
	level.scr_model[ "barrel_oiltank_crush_4" ]				= "blackice_barrel_crush";	
	level.scr_model[ "barrel_oiltank_crush_5" ]				= "blackice_barrel_crush";	
	level.scr_model[ "barrel_oiltank_crush_6" ]				= "blackice_barrel_crush";	
	level.scr_model[ "barrel_oiltank_crush_7" ]				= "blackice_barrel_crush";	
	level.scr_anim[ "barrel_oiltank_crush_1" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_barrel_1;
	level.scr_anim[ "barrel_oiltank_crush_2" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_barrel_2;
	level.scr_anim[ "barrel_oiltank_crush_3" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_barrel_3;
	level.scr_anim[ "barrel_oiltank_crush_4" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_barrel_4;
	level.scr_anim[ "barrel_oiltank_crush_5" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_barrel_5;
	level.scr_anim[ "barrel_oiltank_crush_6" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_barrel_6;
	level.scr_anim[ "barrel_oiltank_crush_7" ][ "derrick_explosion" ] = %blackice_derrick_oiltank_barrel_7;
	
	// misc_debris (part of derrick explosion) 
	level.scr_animtree[ "derrick_debris_1" ]				= #animtree;
	level.scr_model[ "derrick_debris_1" ]				= "ny_harbor_debris_misc_01";	
	level.scr_anim[ "derrick_debris_1" ][ "derrick_debris_1" ] = %blackice_derrick_debris_1_1;
	level.scr_anim[ "derrick_debris_1" ][ "derrick_debris_2" ] = %blackice_derrick_debris_1_2;
	
	level.scr_animtree[ "derrick_debris_2" ]				= #animtree;
	level.scr_model[ "derrick_debris_2" ]				= "ny_harbor_debris_misc_02";	
	level.scr_anim[ "derrick_debris_2" ][ "derrick_debris_1" ] = %blackice_derrick_debris_2_1;
	level.scr_anim[ "derrick_debris_2" ][ "derrick_debris_2" ] = %blackice_derrick_debris_2_2;
	
	level.scr_animtree[ "derrick_debris_3" ]				= #animtree;
	level.scr_model[ "derrick_debris_3" ]				= "ny_harbor_debris_misc_03";	
	level.scr_anim[ "derrick_debris_3" ][ "derrick_debris_1" ] = %blackice_derrick_debris_3_1;
	level.scr_anim[ "derrick_debris_3" ][ "derrick_debris_2" ] = %blackice_derrick_debris_3_2;
	
	level.scr_animtree[ "derrick_debris_4" ]				= #animtree;
	level.scr_model[ "derrick_debris_4" ]				= "ny_harbor_debris_misc_04";	
	level.scr_anim[ "derrick_debris_4" ][ "derrick_debris_1" ] = %blackice_derrick_debris_4_1;
	level.scr_anim[ "derrick_debris_4" ][ "derrick_debris_2" ] = %blackice_derrick_debris_4_2;
	
	level.scr_animtree[ "derrick_debris_5" ]				= #animtree;
	level.scr_model[ "derrick_debris_5" ]				= "ny_harbor_debris_misc_05";	
	level.scr_anim[ "derrick_debris_5" ][ "derrick_debris_1" ] = %blackice_derrick_debris_5_1;
	level.scr_anim[ "derrick_debris_5" ][ "derrick_debris_2" ] = %blackice_derrick_debris_5_2;
	
	level.scr_animtree[ "derrick_debris_6" ]				= #animtree;
	level.scr_model[ "derrick_debris_6" ]				= "ny_harbor_debris_misc_06";	
	level.scr_anim[ "derrick_debris_6" ][ "derrick_debris_1" ] = %blackice_derrick_debris_6_1;
	level.scr_anim[ "derrick_debris_6" ][ "derrick_debris_2" ] = %blackice_derrick_debris_6_2;
	
	addNotetrack_customFunction( "traveling_block" , "hitground", ::notetrack_derrick_debris_hitground );
	addNotetrack_customFunction( "derrick_chunk" , "hitground", ::notetrack_derrick_debris_hitground );
	addNotetrack_customFunction( "derrick_debris_1" , "hitground", ::notetrack_derrick_debris_hitground );
	addNotetrack_customFunction( "derrick_debris_2" , "hitground", ::notetrack_derrick_debris_hitground );
	addNotetrack_customFunction( "derrick_debris_3" , "hitground", ::notetrack_derrick_debris_hitground );
	addNotetrack_customFunction( "derrick_debris_4" , "hitground", ::notetrack_derrick_debris_hitground );
	addNotetrack_customFunction( "derrick_debris_5" , "hitground", ::notetrack_derrick_debris_hitground );
	addNotetrack_customFunction( "derrick_debris_6" , "hitground", ::notetrack_derrick_debris_hitground );
	
	// Refinery door
	level.scr_animtree[ "blackice_door_refinery" ]				= #animtree;
	level.scr_model[ "blackice_door_refinery" ]				= "blackice_door_refinery";	
	level.scr_anim[ "blackice_door_refinery" ][ "command_enter" ] = %blackice_door_controlroomdoor_2;
	
	// wires
	level.scr_animtree[ "derrick_wires" ]				= #animtree;
	
	//top drive pipes
	level.scr_animtree[ "drill_pipe1" ]				= #animtree;
	level.scr_model[ "drill_pipe1" ]				= "blackice_drill_pipe_single";	
	level.scr_anim[ "drill_pipe1" ][ "fall" ] = %blackice_topdrive_pipe1_fall;
	
	level.scr_animtree[ "drill_pipe2" ]				= #animtree;
	level.scr_model[ "drill_pipe2" ]				= "blackice_drill_pipe_single";	
	level.scr_anim[ "drill_pipe2" ][ "fall" ] = %blackice_topdrive_pipe2_fall;
	
	level.scr_animtree[ "drill_pipe3" ]				= #animtree;
	level.scr_model[ "drill_pipe3" ]				= "blackice_drill_pipe_single";	
	level.scr_anim[ "drill_pipe3" ][ "fall" ] = %blackice_topdrive_pipe3_fall;
	
	level.scr_animtree[ "drill_pipe4" ]				= #animtree;
	level.scr_model[ "drill_pipe4" ]				= "blackice_drill_pipe_single";	
	level.scr_anim[ "drill_pipe4" ][ "fall" ] = %blackice_topdrive_pipe4_fall;
	
	//top drive
	level.scr_animtree[ "top_drive" ]				= #animtree;
	level.scr_model[ "top_drive" ]				= "topdrive_destroyed";
	level.scr_anim[ "top_drive" ][ "fall" ] = %blackice_topdrive_fall;

	
	// Office infil door
	level.scr_animtree[ "hiding_door" ]			 = #animtree;
	level.scr_anim[ "hiding_door" ][ "grenade" ] = %doorpeek_grenade_door;
	level.scr_anim[ "hiding_door" ][ "kick"	   ] = %doorpeek_kick_door;
	
	// Intro assets
	level.scr_animtree[ "player_scuba" ] = #animtree;
	level.scr_model[ "player_scuba" ] = "prop_player_scuba_tank";
	level.scr_anim[ "player_scuba" ][ "scuba_intro" ] = %blackice_scuba_intro;
	
	level.scr_animtree[ "player_mask" ] = #animtree;
	level.scr_model[ "player_mask" ] = "viewmodel_scuba_mask";
	level.scr_anim[ "player_mask" ][ "mask_surface" ] = %blackice_mask_surface;
	level.scr_anim[ "player_mask" ][ "mask_surface_pt2" ] = %blackice_mask_surface_pt2;

	//level.scr_animtree[ "limpet_mine" ] = #animtree;
	//level.scr_model[ "limpet_mine" ] = "linear_shape_charge";
	//level.scr_anim[ "limpet_mine" ][ "mine_01" ] = %blackice_intro_mine_01;
	//level.scr_anim[ "limpet_mine" ][ "mine_02" ] = %blackice_intro_mine_02;
	
	level.scr_animtree[ "borescope" ] = #animtree;
	level.scr_model[ "borescope" ] = "blackice_borescope";
	level.scr_anim[ "borescope" ][ "borescope" ] = %blackice_intro_borescope_01;
		
	// ascend
	level.scr_animtree[ "ascend_launcher_non_anim" ] = #animtree;
	level.scr_model[ "ascend_launcher_non_anim" ] = "black_ice_line_launcher";
	
	level.scr_animtree[ "ascend_hook" ] = #animtree;
	level.scr_model[ "ascend_hook" ] = "grappling_hook_rigged";
	level.scr_anim[ "ascend_hook" ][ "ascend_hook" ] = %blackice_player_rigascend_hook;
	
	level.scr_animtree[ "ascend_hook_ally1" ] = #animtree;
	level.scr_model[ "ascend_hook_ally1" ] = "grappling_hook_rigged";
	level.scr_anim[ "ascend_hook_ally1" ][ "ascend_hook" ] = %blackice_ally1_rigascend_hook;
	
	level.scr_animtree[ "ascend_hook_ally2" ] = #animtree;
	level.scr_model[ "ascend_hook_ally2" ] = "grappling_hook_rigged";
	level.scr_anim[ "ascend_hook_ally2" ][ "ascend_hook" ] = %blackice_ally2_rigascend_hook;
	
	level.scr_animtree[ "ascend_hook_ally3" ] = #animtree;
	level.scr_model[ "ascend_hook_ally3" ] = "grappling_hook_rigged";
	level.scr_anim[ "ascend_hook_ally3" ][ "ascend_hook" ] = %blackice_ally3_rigascend_hook;
	
	level.scr_animtree[ "ascend_hook_ally4" ] = #animtree;
	level.scr_model[ "ascend_hook_ally4" ] = "grappling_hook_rigged";
	level.scr_anim[ "ascend_hook_ally4" ][ "ascend_hook" ] = %blackice_ally4_rigascend_hook;
	
	level.scr_animtree[ "ascend_launcher" ] = #animtree;
	level.scr_model[ "ascend_launcher" ] = "viewmodel_black_ice_line_launcher";
	level.scr_anim[ "ascend_launcher" ][ "alpha_rig_ascend_aim" ] = %blackice_playerascender_rigascend_aim;
	level.scr_anim[ "ascend_launcher" ][ "alpha_rig_ascend_aim_loop" ][0] = %blackice_playerascender_aim_loop;
	level.scr_anim[ "ascend_launcher" ][ "alpha_rig_ascend_linkup" ] = %blackice_player_lineshooter_linkup;
	
	// Aim additives
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_left_parent" ] = %ascender_aim_left;
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_right_parent" ] = %ascender_aim_right;
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_up_parent" ] = %ascender_aim_up;
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_down_parent" ] = %ascender_aim_down;
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_left" ] = %blackice_playerascender_aim_left;
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_right" ] = %blackice_playerascender_aim_right;
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_up" ] = %blackice_playerascender_aim_up;
	level.scr_anim[ "ascend_launcher" ][ "ascender_aim_down" ] = %blackice_playerascender_aim_down;
	
	level.scr_animtree[ "ascend_ascender" ] = #animtree;
	level.scr_model[ "ascend_ascender" ] = "black_ice_rope_ascender";
	level.scr_anim[ "ascend_ascender" ][ "alpha_rig_ascend_linkup" ] = %blackice_player_ascender_linkup;
	level.scr_anim[ "ascend_ascender" ][ "alpha_rig_ascend_groundidle" ][0] = %blackice_player_ascender_groundidle;
	level.scr_anim[ "ascend_ascender" ][ "alpha_rig_ascend" ] = %blackice_player_ascender_rigascend;
	
	level.scr_animtree[ "ally1_ascend_launcher" ] = #animtree;
	level.scr_model[ "ally1_ascend_launcher" ] = "rig_linelauncher_animated";
	level.scr_anim[ "ally1_ascend_launcher" ][ "ascend_runin" ] = %blackice_ally1_lineshooter_runnin;
	level.scr_anim[ "ally1_ascend_launcher" ][ "ascend_waiting" ][0] = %blackice_ally1_lineshooter_waiting;
	level.scr_anim[ "ally1_ascend_launcher" ][ "alpha_rope_shoot" ] = %blackice_ally1_lineshooter_shoot;
	level.scr_anim[ "ally1_ascend_launcher" ][ "alpha_hand_rope" ][0] = %blackice_ally1_lineshooter_idle;
	level.scr_anim[ "ally1_ascend_launcher" ][ "alpha_rig_ascend" ] = %blackice_ally1_lineshooter_ascend;
	
	level.scr_animtree[ "ally1_ascend_ascender" ] = #animtree;
	level.scr_model[ "ally1_ascend_ascender" ] = "black_ice_rope_ascender";
	level.scr_anim[ "ally1_ascend_ascender" ][ "alpha_hand_rope" ][0] = %blackice_ally1_ascender_idle;
	level.scr_anim[ "ally1_ascend_ascender" ][ "alpha_rig_ascend" ] = %blackice_ally1_ascender_ascend;
	
	level.scr_animtree[ "ally2_ascend_launcher" ] = #animtree;
	level.scr_model[ "ally2_ascend_launcher" ] = "rig_linelauncher_animated";
	level.scr_anim[ "ally2_ascend_launcher" ][ "ascend_runin" ] = %blackice_ally2_lineshooter_runnin;
	level.scr_anim[ "ally2_ascend_launcher" ][ "ascend_waiting" ][0] = %blackice_ally2_lineshooter_waiting;
	level.scr_anim[ "ally2_ascend_launcher" ][ "alpha_rope_shoot" ] = %blackice_ally2_lineshooter_shoot;
	level.scr_anim[ "ally2_ascend_launcher" ][ "alpha_hand_rope" ][0] = %blackice_ally2_lineshooter_idle;
	level.scr_anim[ "ally2_ascend_launcher" ][ "alpha_rig_ascend" ] = %blackice_ally2_lineshooter_ascend;
	
	level.scr_animtree[ "ally2_ascend_ascender" ] = #animtree;
	level.scr_model[ "ally2_ascend_ascender" ] = "black_ice_rope_ascender";
	level.scr_anim[ "ally2_ascend_ascender" ][ "alpha_hand_rope" ][0] = %blackice_ally2_ascender_idle;
	level.scr_anim[ "ally2_ascend_ascender" ][ "alpha_rig_ascend" ] = %blackice_ally2_ascender_ascend;
	
	level.scr_animtree[ "bravo1_ascend_launcher" ] = #animtree;
	level.scr_model[ "bravo1_ascend_launcher" ] = "rig_linelauncher_animated";
	level.scr_anim[ "bravo1_ascend_launcher" ][ "ascend_runin" ] = %blackice_bravo2_lineshooter_runnin;
	level.scr_anim[ "bravo1_ascend_launcher" ][ "ascend_waiting" ][0] = %blackice_bravo2_lineshooter_waiting;
	level.scr_anim[ "bravo1_ascend_launcher" ][ "bravo_rope_shoot" ] = %blackice_bravo2_lineshooter_shoot;
	level.scr_anim[ "bravo1_ascend_launcher" ][ "bravo_rope_idle" ][0] = %blackice_bravo2_lineshooter_idle;
	level.scr_anim[ "bravo1_ascend_launcher" ][ "bravo_rig_ascend" ] = %blackice_bravo2_lineshooter_ascend;
	
	level.scr_animtree[ "bravo1_ascend_ascender" ] = #animtree;
	level.scr_model[ "bravo1_ascend_ascender" ] = "black_ice_rope_ascender";
	level.scr_anim[ "bravo1_ascend_ascender" ][ "bravo_rope_idle" ][0] = %blackice_bravo1_ascender_idle;
	level.scr_anim[ "bravo1_ascend_ascender" ][ "bravo_rig_ascend" ] = %blackice_bravo1_ascender_ascend;
	
	level.scr_animtree[ "bravo2_ascend_launcher" ] = #animtree;
	level.scr_model[ "bravo2_ascend_launcher" ] = "rig_linelauncher_animated";
	level.scr_anim[ "bravo2_ascend_launcher" ][ "ascend_runin" ] = %blackice_bravo1_lineshooter_runnin;
	level.scr_anim[ "bravo2_ascend_launcher" ][ "ascend_waiting" ][0] = %blackice_bravo1_lineshooter_waiting;
	level.scr_anim[ "bravo2_ascend_launcher" ][ "bravo_rope_shoot" ] = %blackice_bravo1_lineshooter_shoot;
	level.scr_anim[ "bravo2_ascend_launcher" ][ "bravo_rope_idle" ][0] = %blackice_bravo1_lineshooter_idle;
	level.scr_anim[ "bravo2_ascend_launcher" ][ "bravo_rig_ascend" ] = %blackice_bravo1_lineshooter_ascend;
	
	level.scr_animtree[ "bravo2_ascend_ascender" ] = #animtree;
	level.scr_model[ "bravo2_ascend_ascender" ] = "black_ice_rope_ascender";
	level.scr_anim[ "bravo2_ascend_ascender" ][ "bravo_rope_idle" ][0] = %blackice_bravo2_ascender_idle;
	level.scr_anim[ "bravo2_ascend_ascender" ][ "bravo_rig_ascend" ] = %blackice_bravo2_ascender_ascend;		

	level.scr_animtree[ "ascend_rope1" ] = #animtree;
	level.scr_model[ "ascend_rope1" ] = "black_ice_rope_prop";
	level.scr_anim[ "ascend_rope1" ][ "alpha_rope_shoot" ] = %blackice_allyrope1_shoot;
	level.scr_anim[ "ascend_rope1" ][ "alpha_hand_rope" ][0] = %blackice_allyrope1_hand;
	level.scr_anim[ "ascend_rope1" ][ "alpha_rig_ascend_linkup" ] = %blackice_allyrope1_linkup;
	level.scr_anim[ "ascend_rope1" ][ "alpha_rig_ascend_groundidle" ][0] = %blackice_allyrope1_groundidle;
	level.scr_anim[ "ascend_rope1" ][ "alpha_rig_ascend" ] = %blackice_allyrope1_rigascend;
	
	level.scr_animtree[ "ascend_rope2" ] = #animtree;
	level.scr_model[ "ascend_rope2" ] = "black_ice_rope_prop";
	level.scr_anim[ "ascend_rope2" ][ "alpha_rope_shoot" ] = %blackice_allyrope2_shoot;
	level.scr_anim[ "ascend_rope2" ][ "alpha_hand_rope" ][0] = %blackice_allyrope2_hand;
	level.scr_anim[ "ascend_rope2" ][ "alpha_rig_ascend" ] = %blackice_allyrope2_rigascend;
	
	level.scr_animtree[ "ascend_rope3" ] = #animtree;
	level.scr_model[ "ascend_rope3" ] = "black_ice_rope_prop";
	level.scr_anim[ "ascend_rope3" ][ "alpha_rope_shoot" ] = %blackice_allyrope3_shoot;
	level.scr_anim[ "ascend_rope3" ][ "alpha_hand_rope" ][0] = %blackice_allyrope3_hand;
	level.scr_anim[ "ascend_rope3" ][ "alpha_rig_ascend" ] = %blackice_allyrope3_rigascend;
	
	level.scr_animtree[ "bravo_ascend_rope1" ] = #animtree;
	level.scr_model[ "bravo_ascend_rope1" ] = "black_ice_rope_prop";
	level.scr_anim[ "bravo_ascend_rope1" ][ "bravo_rope_shoot" ] = %blackice_bravorope1_shoot;
	level.scr_anim[ "bravo_ascend_rope1" ][ "bravo_rope_idle" ][0] = %blackice_bravorope1_idle;
	level.scr_anim[ "bravo_ascend_rope1" ][ "bravo_rig_ascend" ] = %blackice_bravorope1_ascend;
	
	level.scr_animtree[ "bravo_ascend_rope2" ] = #animtree;
	level.scr_model[ "bravo_ascend_rope2" ] = "black_ice_rope_prop";
	level.scr_anim[ "bravo_ascend_rope2" ][ "bravo_rope_shoot" ] = %blackice_bravorope2_shoot;
	level.scr_anim[ "bravo_ascend_rope2" ][ "bravo_rope_idle" ][0] = %blackice_bravorope2_idle;
	level.scr_anim[ "bravo_ascend_rope2" ][ "bravo_rig_ascend" ] = %blackice_bravorope2_ascend;
	
	addNotetrack_sound( "hiding_door", "sound door death", "any", "scn_blackice_door_kick" );
	//addNotetrack_sound( "hiding_door", "sound door open", "any", "scn_doorpeek_door_open" );
	//addNotetrack_sound( "hiding_door", "sound door slam", "any", "scn_doorpeek_door_slam" );
	
	// Flare Stack
	level.scr_animtree[ "flare_stack_console" ] = #animtree;
	level.scr_anim[ "flare_stack_console" ][ "turn_off_flare_stack" ] = %blackice_flare_stack_console_press;
	level.scr_anim[ "flare_stack_console" ][ "console_open" ] = %blackice_flare_stack_console;
	
	// Engine Room
	level.scr_animtree[ "extinguisher" ] = #animtree;
	level.scr_model[ "extinguisher" ] = "com_fire_extinguisher_anim";
	level.scr_anim[ "extinguisher" ][ "extinguisher_loop1" ][0] = %blackice_engineroom_firefighter1_ext_idle;
	level.scr_anim[ "extinguisher" ][ "extinguisher_loop2" ][0] = %blackice_engineroom_firefighter2_ext_idle;
	level.scr_anim[ "extinguisher" ][ "extinguisher_loop3" ][0] = %blackice_engineroom_firefighter3_ext_idle;
	
	level.scr_anim[ "extinguisher" ][ "extinguisher_loop_break1" ] = %blackice_engineroom_firefighter1_ext;
	level.scr_anim[ "extinguisher" ][ "extinguisher_loop_break2" ] = %blackice_engineroom_firefighter2_ext;
	level.scr_anim[ "extinguisher" ][ "extinguisher_loop_break3" ] = %blackice_engineroom_firefighter3_ext;
		
	// Tanks catwalk colllapse
	level.scr_animtree[ "tanks_pipe" ] = #animtree;
	level.scr_model[ "tanks_pipe" ] = "blackice_catwalk_collapse_pipe";
	level.scr_anim[ "tanks_pipe" ][ "tanks_bridge_fall_scene" ] = %blackice_tanks_catwalk_collapse_pipe1;
	
	level.scr_animtree[ "tanks_bridge" ] = #animtree;
	level.scr_anim[ "tanks_bridge" ][ "tanks_bridge_fall_scene" ] = %blackice_tanks_catwalk_collapse_bridge;
	addNotetrack_notify( "tanks_bridge", "model_swap", "notify_bridge_model_swap", "tanks_bridge_fall_scene" );		
	
	// Pipe Deck boat scene
	level.scr_animtree[ "lifeboat1" ] = #animtree;		
	level.scr_anim[ "lifeboat1" ][ "lifeboat_deploy" ] = %blackice_lifeboat1;	
	
	level.scr_animtree[ "lifeboat2" ] = #animtree;	
	level.scr_anim[ "lifeboat2" ][ "lifeboat_deploy" ] = %blackice_lifeboat2;
	
	level.scr_animtree[ "lifeboat_crates" ] = #animtree;
	level.scr_model[ "lifeboat_crates" ] = "blackice_lifeboat_crates";
	level.scr_anim[ "lifeboat_crates" ][ "lifeboat_deploy" ] = %blackice_lifeboat_crates_01;
	
	// Pipes explosions
	level.scr_animtree[ "pipedeck_explosion2_rig" ] = #animtree;
	level.scr_anim[ "pipedeck_explosion2_rig" ][ "pipes_explode" ] = %blackice_pipedeck_explosion2_01;
	
	level.scr_animtree[ "pipedeck_explosion3_rig" ] = #animtree;
	level.scr_anim[ "pipedeck_explosion3_rig" ][ "pipes_explode" ] = %blackice_pipedeck_explosion3_01;
	
	level.scr_animtree[ "pipedeck_explosion4_rig" ] = #animtree;
	level.scr_anim[ "pipedeck_explosion4_rig" ][ "pipes_explode" ] = %blackice_pipedeck_explosion4_01;	
	
//	level.scr_animtree[ "exfil_pipes_explosion_rig" ] = #animtree;
//	level.scr_anim[ "exfil_pipes_explosion_rig" ][ "pipes_explode" ] = %blackice_pipedeck_exposion_exfil_01;
	
	level.scr_animtree[ "pipedeck_pipe" ] = #animtree;
	level.scr_model[ "pipedeck_pipe" ] = "blackice_drill_pipe_single";
	
	level.scr_animtree[ "pipedeck_crate" ] = #animtree;
	level.scr_model[ "pipedeck_crate" ] = "ch_crate48x64_snow_no_tweak";		
	
	level.scr_animtree[ "pipedeck_crane_1" ] = #animtree;
	level.scr_anim[ "pipedeck_crane_1" ][ "pipes_explode" ] = %blackice_pipedeck_explosion2_crane;
	
	//pipedeck wires
	level.scr_animtree[ "wires" ] = #animtree;
	level.scr_anim[ "wires" ][ "vig_pipdeck_wires" ][0] = %blackice_wires_pipedeck_01;
	
	// Pipe Deck Heli target	
	level.scr_animtree[ "pipedeck_heli_target" ] = #animtree;
	level.scr_model[ "pipedeck_heli_target" ] = "blackice_pipedeck_heliattack_hitpoint";
	level.scr_anim[ "pipedeck_heli_target" ][ "final_support" ] = %blackice_pipedeck_heliattack_hitpoint_01;
		
//	//command center
	//levers
	level.scr_animtree[ "command_lever" ] = #animtree;
	level.scr_anim[ "command_lever" ][ "command_player_end" ] = %blackice_controlroom_lever_player_end;
	level.scr_anim[ "command_lever" ][ "command_player_early" ] = %blackice_controlroom_lever_player_early;
	level.scr_anim[ "command_lever" ][ "command_player_late" ] = %blackice_controlroom_lever_player_late;
	level.scr_anim[ "command_lever" ][ "command_player_control" ] = %blackice_controlroom_lever_player_control;
	level.scr_anim[ "command_lever" ][ "command_baker_end" ] = %blackice_controlroom_lever_baker_end;
	level.scr_anim[ "command_lever" ][ "command_baker_early" ] = %blackice_controlroom_lever_baker_early;
	level.scr_anim[ "command_lever" ][ "command_baker_late" ] = %blackice_controlroom_lever_baker_late;
	
	//monitor fx
	level.scr_animtree[ "command_monitor_fx_green" ] = #animtree;
	level.scr_model[ "command_monitor_fx_green" ] = "bi_command_center_panel_26_screen_green";
	level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_1" ] = %blackice_controlroom_monitor_fx_1;
	level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_2" ] = %blackice_controlroom_monitor_fx_2;
	level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_3" ] = %blackice_controlroom_monitor_fx_3;
	//level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_poser" ] = %blackice_controlroom_monitor_fx_poser;
	
	level.scr_animtree[ "command_monitor_fx_yellow" ] = #animtree;
	level.scr_model[ "command_monitor_fx_yellow" ] = "bi_command_center_panel_26_screen_yellow";
	level.scr_anim[ "command_monitor_fx_yellow" ][ "command_monitor_fx_1" ] = %blackice_controlroom_monitor_fx_1;
	level.scr_anim[ "command_monitor_fx_yellow" ][ "command_monitor_fx_2" ] = %blackice_controlroom_monitor_fx_2;
	level.scr_anim[ "command_monitor_fx_yellow" ][ "command_monitor_fx_3" ] = %blackice_controlroom_monitor_fx_3;
	//level.scr_anim[ "command_monitor_fx_yellow" ][ "command_monitor_fx_poser" ] = %blackice_controlroom_monitor_fx_poser;
	
	level.scr_animtree[ "command_monitor_fx_red" ] = #animtree;
	level.scr_model[ "command_monitor_fx_red" ] = "bi_command_center_panel_26_screen_red";
	level.scr_anim[ "command_monitor_fx_red" ][ "command_monitor_fx_1" ] = %blackice_controlroom_monitor_fx_1;
	level.scr_anim[ "command_monitor_fx_red" ][ "command_monitor_fx_2" ] = %blackice_controlroom_monitor_fx_2;
	level.scr_anim[ "command_monitor_fx_red" ][ "command_monitor_fx_3" ] = %blackice_controlroom_monitor_fx_3;
	//level.scr_anim[ "command_monitor_fx_red" ][ "command_monitor_fx_poser" ] = %blackice_controlroom_monitor_fx_poser;
	
	// player buttons
	level.scr_animtree[ "command_shutoff_button" ] = #animtree;
	level.scr_anim[ "command_shutoff_button" ][ "command_shutoff_button" ] = %blackice_command_shutoff_button;
	
	// monitors
	level.scr_animtree[ "command_monitor" ] = #animtree;
	level.scr_anim[ "command_monitor" ][ "command_monitor_player" ] = %blackice_command_monitor_player;
	level.scr_anim[ "command_monitor" ][ "command_monitor_baker" ] = %blackice_command_monitor_baker;
	level.scr_anim[ "command_monitor" ][ "command_monitor_player_end" ] = %blackice_command_monitor_player_end;
	level.scr_anim[ "command_monitor" ][ "command_monitor_baker_end" ] = %blackice_command_monitor_baker_end;
	
	//chairs
	level.scr_animtree[ "command_opfor1_chair" ] = #animtree;
	level.scr_model[ "command_opfor1_chair" ] = "blackice_commandcenter_chair";
	level.scr_anim[ "command_opfor1_chair" ][ "command_death" ] = %blackice_controlroompanel_chair_death;
	level.scr_anim[ "command_opfor1_chair" ][ "command_start" ] = %blackice_controlroompanel_chair_death_push;	
		
	//exfil
	
	level.scr_animtree[ "debris01" ] = #animtree;
	level.scr_anim[ "debris01" ][ "runout_group1" ] = %blackice_runout_group_1;
	level.scr_model[ "debris01" ] = "blackice_runout_group1";

	level.scr_animtree[ "debris02" ] = #animtree;
	level.scr_anim[ "debris02" ][ "runout_group2" ] = %blackice_runout_group_2;
	level.scr_model[ "debris02" ] = "blackice_runout_group2";
	
	level.scr_animtree[ "debris03" ] = #animtree;
	level.scr_anim[ "debris03" ][ "runout_group3" ] = %blackice_runout_group_3;
	level.scr_model[ "debris03" ] = "blackice_runout_group3";
	
	level.scr_animtree[ "bulkhead_door" ] = #animtree;
	level.scr_model[ "bulkhead_door" ] = "bulkhead_door";
	level.scr_anim[ "bulkhead_door" ][ "shoulder_door" ] = %blackice_controlroom_exfil_finalroom_door;	
	
	level.scr_animtree[ "exfil_helo" ] = #animtree;
	level.scr_model[ "exfil_helo" ] = "vehicle_mi24p_hind_blackice";
	level.scr_anim[ "exfil_helo" ][ "idle" ] = %blackice_helo_idle;
	level.scr_anim[ "exfil_helo" ][ "ladder_chase" ] = %blackice_helo_explode;
	
	addNotetrack_notify( "exfil_helo", "spotlight_on", "notify_helo_spotlight_on", "idle" );		
	addNotetrack_notify( "exfil_helo", "spotlight_off", "notify_helo_spotlight_off", "ladder_chase" );
	
	level.scr_animtree[ "cam_shake" ] = #animtree;
	level.scr_model[ "cam_shake" ] = "tag_origin";
	level.scr_anim[ "cam_shake" ][ "jump_shake" ] = %blackice_player_exfil_jumpcam;
	level.scr_anim[ "cam_shake" ][ "jump_shake_fail" ] = %blackice_player_exfil_jumpcam_fail;
		
	level.scr_animtree[ "exfil_ladder" ] = #animtree;
	level.scr_model[ "exfil_ladder" ] = "blackice_rope_ladder";
	level.scr_anim[ "exfil_ladder" ][ "idle" ] = %blackice_rope_ladder_idle;
	level.scr_anim[ "exfil_ladder" ][ "ladder_chase" ] = %blackice_rope_ladder_explode;
	
	level.scr_animtree[ "exfil_oilrig" ] = #animtree;
	level.scr_model[ "exfil_oilrig" ] = "black_ice_rig_platform";
	level.scr_anim[ "exfil_oilrig" ][ "ladder_chase" ] = %blackice_oilrig_exfil_explode;
	
	addNotetrack_notify( "exfil_oilrig", "sphere_start_fall", "notify_sphere_start_fall", "ladder_chase" );		
	addNotetrack_notify( "exfil_oilrig", "sphere_hit_ground", "notify_sphere_hit_ground", "ladder_chase" );
	addNotetrack_notify( "exfil_oilrig", "rig_explode", "notify_rig_explode", "ladder_chase" );		
	
	level.scr_animtree[ "exfil_lifeboat1" ] = #animtree;
	level.scr_model[ "exfil_lifeboat1" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat1" ][ "ladder_chase" ] = %blackice_lifeboat1_exfil_explode;

	level.scr_animtree[ "exfil_lifeboat2" ] = #animtree;
	level.scr_model[ "exfil_lifeboat2" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat2" ][ "ladder_chase" ] = %blackice_lifeboat2_exfil_explode;

	level.scr_animtree[ "exfil_lifeboat3" ] = #animtree;
	level.scr_model[ "exfil_lifeboat3" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat3" ][ "ladder_chase" ] = %blackice_lifeboat3_exfil_explode;

	level.scr_animtree[ "exfil_lifeboat4" ] = #animtree;
	level.scr_model[ "exfil_lifeboat4" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat4" ][ "ladder_chase" ] = %blackice_lifeboat4_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat5" ] = #animtree;
	level.scr_model[ "exfil_lifeboat5" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat5" ][ "ladder_chase" ] = %blackice_lifeboat5_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat6" ] = #animtree;
	level.scr_model[ "exfil_lifeboat6" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat6" ][ "ladder_chase" ] = %blackice_lifeboat6_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat7" ] = #animtree;
	level.scr_model[ "exfil_lifeboat7" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat7" ][ "ladder_chase" ] = %blackice_lifeboat7_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat8" ] = #animtree;
	level.scr_model[ "exfil_lifeboat8" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat8" ][ "ladder_chase" ] = %blackice_lifeboat8_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat9" ] = #animtree;
	level.scr_model[ "exfil_lifeboat9" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat9" ][ "ladder_chase" ] = %blackice_lifeboat9_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat10" ] = #animtree;
	level.scr_model[ "exfil_lifeboat10" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat10" ][ "ladder_chase" ] = %blackice_lifeboat10_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat11" ] = #animtree;
	level.scr_model[ "exfil_lifeboat11" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat11" ][ "ladder_chase" ] = %blackice_lifeboat11_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat12" ] = #animtree;
	level.scr_model[ "exfil_lifeboat12" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat12" ][ "ladder_chase" ] = %blackice_lifeboat12_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat13" ] = #animtree;
	level.scr_model[ "exfil_lifeboat13" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat13" ][ "ladder_chase" ] = %blackice_lifeboat13_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat14" ] = #animtree;
	level.scr_model[ "exfil_lifeboat14" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat14" ][ "ladder_chase" ] = %blackice_lifeboat14_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat15" ] = #animtree;
	level.scr_model[ "exfil_lifeboat15" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat15" ][ "ladder_chase" ] = %blackice_lifeboat15_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat16" ] = #animtree;
	level.scr_model[ "exfil_lifeboat16" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat16" ][ "ladder_chase" ] = %blackice_lifeboat16_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat17" ] = #animtree;
	level.scr_model[ "exfil_lifeboat17" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat17" ][ "ladder_chase" ] = %blackice_lifeboat17_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat18" ] = #animtree;
	level.scr_model[ "exfil_lifeboat18" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat18" ][ "ladder_chase" ] = %blackice_lifeboat18_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat19" ] = #animtree;
	level.scr_model[ "exfil_lifeboat19" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat19" ][ "ladder_chase" ] = %blackice_lifeboat19_exfil_explode;
	
	level.scr_animtree[ "exfil_lifeboat20" ] = #animtree;
	level.scr_model[ "exfil_lifeboat20" ] = "rnk_lifeboat";
	level.scr_anim[ "exfil_lifeboat20" ][ "ladder_chase" ] = %blackice_lifeboat20_exfil_explode;
	
	level.scr_animtree[ "exfil_viewexplosion_source" ] = #animtree;
	level.scr_model[ "exfil_viewexplosion_source" ] = "bi_viewexplosion_source";
	
}

collapsed_derrick_wire_anims()
{
	wires = GetEnt( "derrick_wires", "targetname" );
	wires.animname = "derrick_wires";
	wires SetAnimTree();
	//wires setanim( "wire_anim", 1, 0, 1 );
	wires setanim( %blackice_derrick_collapse_wires_1, 1, 0, 1 );
	wires setanim( %blackice_derrick_collapse_wires_2, 1, 0, 1 );
	wires setanim( %blackice_derrick_collapse_wires_3, 1, 0, 1 );
	wires setanim( %blackice_derrick_collapse_wires_4, 1, 0, 1 );
	wires setanim( %blackice_derrick_collapse_wires_5, 1, 0, 1 );
	wires setanim( %blackice_derrick_collapse_wires_6, 1, 0, 1 );
}


#using_animtree( "vehicles" );
vehicle_anims()
{
	// base camp helo
	level.scr_anim[ "bc_reinforce_helo" ][ "arrive" ]		  = %blackice_basecamp_heliarrival;
	level.scr_anim[ "bc_reinforce_helo" ][ "idle_loop" ][ 0 ] = %blackice_basecamp_heliidle;
	level.scr_anim[ "bc_reinforce_helo" ][ "leave" ]		  = %blackice_basecamp_helileave;
	
	// Mudpumps / pipe deck heli
	level.scr_animtree[ "pipedeck_heli" ]						 = #animtree;
	level.scr_model	  [ "pipedeck_heli" ]						 = "blackice_drill_pipe_single";
	level.scr_anim[ "pipedeck_heli" ][ "heli_reveal" ]			 = %blackice_topdrive_helireveal;
	level.scr_anim[ "pipedeck_heli" ][ "heli_reveal_loop" ][ 0 ] = %blackice_topdrive_helireveal_loop;
	level.scr_anim[ "pipedeck_heli" ][ "final_support" ]		 = %blackice_pipedeck_heliattack_01;
	
					 //   animname 		   notetrack 		     theNotify 				      anime 		  
	addNotetrack_notify( "pipedeck_heli", "gun_on"			  , "notify_heli_anim_fire_on" , "final_support" );
	addNotetrack_notify( "pipedeck_heli", "gun_off"			  , "notify_heli_anim_fire_off", "final_support" );
	addNotetrack_notify( "pipedeck_heli", "command_lights_out", "notify_command_lights_out", "final_support" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

notetrack_swim_loosen_lookaround( player_rig )
{
	level.player LerpViewAngleClamp( 1.0, 0, 0, level.spring_cam_max_clamp, level.spring_cam_max_clamp, level.spring_cam_max_clamp, level.spring_cam_max_clamp );
	level.player_ground_origin_target = Spawn( "script_origin", ( 0, 0, 0 ) );
    level.player_ground_origin unLink(  );
    level.player_ground_origin RotateTo ( level.player_ground_origin_target.angles, 1.0 );
    level.player_ground_origin_target Delete();
    
	//level.player PlayerSetGroundReferenceEnt( undefined );
    //level.player_ground_origin Delete();
}

notetrack_swim_begin_player_control( player_rig )
{
	level.player Unlink();
	level.player_mover Delete();
	level.player_rig Delete();
}

notetrack_player_breach_water( player_rig )
{
	
	black_fade_in_time = 0.2;
	black_hold_time = 0.2;
	black_fade_out_time = 1.5;
	
	// Black overlay
	black_overlay = maps\_hud_util::create_client_overlay( "black", 0, level.player );
	black_overlay FadeOverTime( black_fade_in_time );
	black_overlay.alpha = 1;
	
	//FADE IN BLACK....................................................
	wait black_fade_in_time;

	//bring in superbright vision set
	thread vision_set_fog_changes("black_ice_basecamp_breach", 0.1);
	
	//let scripts know the player is above the water now
	flag_set( "player_water_breach" );
	
	//HOLD BLACK..........................................................
	wait black_hold_time;
	
	// Play the end anim on the water & ice models
	level.breach_anim_node thread anim_single_solo( level.breach_props["breach_water"], "intro_breach_end" );
	level.breach_anim_node thread anim_single_solo( level.breach_props["ice_chunks1"], "intro_breach_end" );
	//level.breach_anim_node thread anim_single_solo( level.breach_props["ice_chunks2"], "intro_breach_end" );
	level.breach_anim_node thread anim_single_solo( level.breach_props["introbreach_props"], "intro_breach_end" );
	
	// Disable goggle overlay, turn of scuba hud/fx
	level.player maps\_underwater::underwater_hud_enable( false );
	level.player thread maps\_underwater::stop_player_scuba();
	if ( IsDefined( level.player.hud_scubaMask ) )
	{
		SetHUDLighting( false );
		level.player.hud_scubaMask  maps\_hud_util::destroyElem();
	}
	
	//unhide world prop of players mask
	level.player_mask Show();
	
	// Fade out black overlay
	black_overlay FadeOverTime( black_fade_out_time );
	black_overlay.alpha = 0;
	
	//start water sheeting fx
	///thread intro_player_goggles_watersheeting_fx();

	//start a slow fade from bright white screen	
	thread vision_set_fog_changes("black_ice_basecamp", 1.5);
	
	//FADE OUT BLACK...............................................
	wait black_fade_out_time;
	
	//cleanup
	black_overlay Destroy();
	
	
}

notetrack_intro_ally2_bubbles( dude )
{
	PlayFXOnTag( getfx( "scuba_bubbles_friendly" ), dude.scuba_org, "tag_origin" );
	
}

notetrack_remove_mask( player_rig )
{
	
}

notetrack_release_allies( player_rig )
{
	level notify( "bc_release_allies" );
}

notetrack_player_draw_weapon_surface( player_rig )
{
	//player should draw his weapon a littel bit prior to the vignette ending
	level.player TakeWeapon( "aps_underwater" );
	level.player SwitchToWeapon( level.default_weapon );
	level.player.disableReload = false;
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player EnableWeaponSwitch();
	SetSavedDvar( "hud_drawhud", 1 );
	
	level.player.early_weapon_enabled = true;
}

notetrack_player_draw_weapon_ascend( player_rig )
{
	//player should draw his weapon a littel bit prior to the vignette ending
	level.player.disableReload = false;
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player EnableWeaponSwitch();
	
	level.player.early_weapon_enabled = true;
}

notetrack_derrick_small_explosion( guys )
{
	level notify( "notify_derrick_small_explosion" );
}

notetrack_traveling_block_impact( guys )
{	
	//AUDIO - playing a derrick explosion sfx
	thread maps\black_ice_audio::sfx_blackice_derrick_exp6_ss(); 
	
	level notify( "notify_traveling_block_impact" );
}

notetrack_derrick_large_explosion( guys )
{
	level notify( "notify_derrick_large_explosion" );
	flag_set( "flag_derrick_exploded" );
}

notetrack_derrick_impact_rig( guys )
{
	level notify( "notify_derrick_impact_rig" );
}

notetrack_refinery_start_combat( thing )
{
	level notify( "notify_notetrack_debris_end" );
	//IPrintLnBold("start");
}

//notetrack_ascend_rubberband_bravo_start( dude )
//{
//	level notify( "notify_ascend_rubberband_bravo_start" );
//}

notetrack_ascend_rubberband_bravo_stop( dude )
{
	level notify( "notify_ascend_rubberband_bravo_stop" );
}

notetrack_ascend_rubberband_alpha_start( dude )
{
	level notify( "notify_ascend_rubberband_alpha_start" );
}

notetrack_ascend_rubberband_alpha_stop( dude )
{
	level notify( "notify_ascend_rubberband_alpha_stop" );
}

notetrack_player_free_look_active( player_rig )
{
	level.player LerpViewAngleClamp( 0.02, 0, 0, 60, 60, 60, 60 );
}

notetrack_player_additive_anims_start( player_rig )
{
	level.player notify( "notify_additive_anims_start" );
	
	level.allow_player_ascend_move = 1;
	
	//player_rig SetAnim( level.scr_anim[ "player_rig" ][ "player_rigascend_noise" ], 1.0, 0.05, 1.0 );
	player_rig SetAnimLimited( level.scr_anim[ "player_rig" ][ "player_rigascend_noise" ], 1, 0.1 );
	player_rig SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_noise_parent" ], 0, 0.1 );
	
	maps\black_ice_ascend::player_ramp_up_wind();
}

notetrack_ascend_end_player_control( player_rig )
{
	level.allow_player_ascend_move = 0;
	
	//AUDIO: stopping ascender sfx
	thread maps\black_ice_audio::sfx_stop_ascent_sounds(); 
	
	level.player LerpViewAngleClamp( 1.0, 0, 0, 0, 0, 0, 0 );
	
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "rig_ascend_start" ], 0.0 );
	level.player_legs SetAnim( level.scr_anim[ "player_legs_ascend" ][ "rig_ascend_start" ], 0.0 );
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "rig_ascend_stop" ], 0.0 );
	level.player_legs SetAnim( level.scr_anim[ "player_legs_ascend" ][ "rig_ascend_stop" ], 0.0 );
	level.player_rig SetAnimLimited( level.scr_anim[ "player_rig" ][ "player_rigascend_noise" ], 0.0, 0.2 );
	level.player_rig SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_noise_parent" ], 0.0, 0.2 );
	
	// Set the anim node back to straight
	level notify( "notify_end_ascend_pendulum" );
	wait level.TIMESTEP;
	level.player_ascend_anim_node RotateTo( ( 0, level.player_ascend_anim_node.angles[1], 0 ), level.TIMESTEP );
}

notetrack_cw_tape_explode( guy )
{
	
	level notify( "notify_cw_tape_explode" );
	
}

notetrack_control_room_allow_free_look( player_rig )
{
	level notify( "notify_control_room_allow_free_look" );
}

notetrack_control_room_start_baker( player_rig )
{
	flag_set( "flag_command_baker_console_anim" );
}

//notetrack_player_grab_ladder( guys )
//{
//	//IPrintLnBold( "ladder grabbed!!!" );
//	//level notify( "notify_player_grab_ladder" );
//	flag_set( "flag_ladder_grabbed" );
//
//}

notetrack_exfil_dialog_1( guy )
{
	level notify( "notify_exfil_dialog_1" );
}

notetrack_exfil_dialog_2( guy )
{
	level notify( "notify_exfil_dialog_2" );
}

notetrack_player_teleport( guys )
{
	level notify( "notify_exfil_player_teleport" );
	level notify( "notify_stop_view_smoke_fx" );
}

notetrack_heli_swing( guys )
{
	flag_set( "flag_helo_swing" );
	level.player PlayRumbleOnEntity( "helo_ladder_swing" );
}

notetrack_start_slomo( guys )
{
	level notify( "notify_exfil_start_slomo" );
}

notetrack_end_slomo( guys )
{
	level notify( "notify_exfil_end_slomo" );
}

ambient_derrick_animation()
{
	thread collapsed_derrick_wire_anims();	
}

//notetrack_command_baker_push( guys )
//{
//	level notify( "notify_baker_push_opfor" );
//}

//notetrack_command_dialog_instruct_1( guys )
//{
//	level notify( "notify_dialog_instruct_1" );
//}

//notetrack_command_dialog_instruct_2( guys )
//{
//	level notify( "notify_dialog_instruct_2" );
//}
//
//notetrack_command_dialog_instruct_3( guys )
//{
//	level notify( "notify_dialog_instruct_3" );
//}
//
//notetrack_command_dialog_instruct_4( guys )
//{
//	level notify( "notify_dialog_instruct_4" );
//}

//notetrack_command_dialog_count_1( guys )
//{
//	level notify( "notify_dialog_count_1" );
//}

//notetrack_command_dialog_count_2( guys )
//{
//	level notify( "notify_dialog_count_2" );
//}
//
//notetrack_command_dialog_count_3( guys )
//{
//	level notify( "notify_dialog_count_3" );
//}
//
//notetrack_command_dialog_count_4( guys )
//{
//	level notify( "notify_dialog_count_4" );
//}
//
//notetrack_command_dialog_count_5( guys )
//{
//	level notify( "notify_dialog_count_5" );
//}
//
//notetrack_command_dialog_count_6( guys )
//{
//	level notify( "notify_dialog_count_6" );
//}
//
//notetrack_command_fail_late( guys )
//{
//	level notify( "notify_fail_late" );
//}

notetrack_command_dialog_fail_early( guys )
{
	thread maps\black_ice_util::temp_dialogue_line( "Baker", "ROOK!  TO SOON!  GET OUT, NOW!!!", 3 );
}

notetrack_command_dialog_fail_late( guys )
{
	//thread maps\black_ice_util::temp_dialogue_line( "Baker", "SHIT! GET THE...", 2 );
	//make him stop talking
	radio_dialogue_stop();
	//wait a beat
	wait(0.5);
	
	level._allies[0] smart_radio_dialogue_interrupt( "black_ice_mrk_shitadamkeepthe" );
}

notetrack_command_dialog_end( guys )
{
	//thread maps\black_ice_util::temp_dialogue_line( "Baker", "MOVE IT!", 2 );
	level notify( "notify_dialog_command_end" );
}

notetrack_derrick_debris_hitground( thing )
{
	thing notify( "hitground" );
}

notetrack_derrick_debris_hit_1( thing )
{
	level notify( "notify_debris_ground_fx_1" );
}

notetrack_derrick_debris_hit_2( thing )
{
	level notify( "notify_debris_ground_fx_2" );
}

notetrack_derrick_chunk_hit_barrels( thing )
{
	//IPrintLnBold( "test");
	earthquake( 0.33, 0.65, level.player.origin, 128 );
	level.player PlayRumbleOnEntity( "damage_light" );
}

notetrack_oiltank_catwalk_swap( thing )
{ 
	level notify( "notify_swap_catwalk" );
}

notetrack_tanks_start_custom_death( guy )
{
	level notify( "notify_tanks_start_custom_death" );
}

notetrack_tanks_end_custom_death( guy )
{
	level notify( "notify_tanks_end_custom_death" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

smooth_player_link( player_rig, blendtime )
{
	level.player PlayerLinkToBlend( player_rig, "tag_player", blendtime );
	wait( blendtime );
	
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
	player_rig Show();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
snake_cam_enemy_anims()
{
	for ( i = 1; i < level.snake_cam_enemies.size; i++ )
	{
		level.snake_cam_anim_node thread anim_single_solo( level.snake_cam_enemies[i], "intro_" + ( i + 1 ) );
	}
	
	// intentional non-thread, so that it halts execution
	level.snake_cam_anim_node anim_single_solo( level.snake_cam_enemies[0], "intro_1" );
	
	// Take the first snake_cam_enemy and turn him into the snowmobile enemy, thread off his first frame anim
    //TAG CP: commenting out the snowmobile crash into water during swim forward*********************************************
//	level.snowmobile_enemy = level.snake_cam_enemies[0];
//	level.snake_cam_enemies = array_remove( level.snake_cam_enemies, level.snake_cam_enemies[0] );
//	
//	level.breach_anim_node thread anim_first_frame_solo( level.snowmobile_enemy, "snowmobile_breach_opfor" );
	
	foreach( guy in level.snake_cam_enemies )
	{
		guy Delete();
		guy = undefined;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_intro_anims()
{
	level.allies_breach_anim_node thread anim_single_solo( level.player_scuba, "scuba_intro" );
	
	//level.allies_breach_anim_node thread anim_single_solo( level.breach_mines["limpet_mine1"], "mine_01" );
	//level.allies_breach_anim_node thread anim_single_solo( level.breach_mines["limpet_mine2"], "mine_02" );
	
	level.allies_breach_anim_node thread anim_single_solo( level.borescope, "borescope" );
	level.borescope thread maps\black_ice_util::delete_at_anim_end( "borescope", "borescope" );
	
	level.allies_breach_anim_node thread anim_single_solo( level.player_rig, "player_intro" );
	
	// legs
	//level.allies_breach_anim_node thread anim_single_solo( level.player_legs, "intro_legs" );
	//level.player_legs thread maps\black_ice_util::delete_at_anim_end( "player_legs_intro", "intro_legs" );
	
	// gun
	//level.allies_breach_anim_node thread anim_single_solo( level.player_underwater_rifle, "intro_gun" );
	//level.player_underwater_rifle thread maps\black_ice_util::delete_at_anim_end( "player_gun_intro", "intro_gun" );
	
	level.allies_breach_anim_node thread anim_single_solo( level._allies_swim[ 0 ], "intro_ally1" );
	level.allies_breach_anim_node thread anim_single_solo( level._allies_swim[ 1 ], "intro_ally2" );
	//level.allies_breach_anim_node thread anim_single_solo( level._allies_swim[ 2 ], "intro_ally3" );
	//level.allies_breach_anim_node thread anim_single_solo( level._allies_swim[ 3 ], "intro_ally4" );
	
	// waittill player detonates or is told to detonate
	level waittill_either( "notify_swim_dialog5_1", "flag_swim_breach_detonate" );
	
	//level notify( "notify_wait_player_detonate" );
	
	//tagCP moved looping idle to this script, since its an anim thread an will always occur after intro
	//only idle if the breach has not started
	if ( !flag( "flag_swim_breach_detonate"))
		thread maps\black_ice_anim::swim_await_detonate_anims();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_await_detonate_anims()
{
	for ( i = 0; i < level.CONST_EXPECTED_NUM_SWIM_ALLIES; i++ )
	{
		level.allies_breach_anim_node thread anim_loop_solo( level._allies_swim[ i ], "intro_ally" + ( i + 1 ) + "_idle", "stop_loop" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_enemies_first_frame_anims()
{
	for( i = 0; i < level.ice_breach_enemies.size; i++ )
	{
		level.breach_anim_node thread anim_first_frame_solo( level.ice_breach_enemies[i], "introbreach_opfor" + i );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_props_first_frame_anims()
{
	//level.allies_breach_anim_node thread anim_first_frame_solo( level.breach_mines["limpet_mine1"], "mine_01" );
	//level.allies_breach_anim_node thread anim_first_frame_solo( level.breach_mines["limpet_mine2"], "mine_02" );
	
	level.allies_breach_anim_node thread anim_first_frame_solo( level.borescope, "borescope" );
	
	level.breach_anim_node anim_first_frame( level.breach_props, "intro_breach" );
	
	// tagBR< note > First parameter is the delay time (may want to tie it to a notetrack instead?)
	//level.breach_anim_node delayThread( 18.0, ::anim_single, level.breach_vehicles, "intro_drive" );
	//level.breach_anim_node delayThread( 18.0, ::anim_single_solo, level.vehicle_no_breach, "intro_drive" );
	//level.vehicle_no_breach thread maps\black_ice_util::delete_at_anim_end( "bm21_3", "intro_drive" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_vehicles_snake_cam_anims()
{
	level.snake_cam_anim_node thread anim_single( level.breach_vehicles, "intro_drive" );
	level.snake_cam_anim_node thread anim_single( level.vehicles_no_breach, "intro_drive" );
	
	level.vehicles_no_breach["bm21_3"] thread maps\black_ice_util::delete_at_anim_end( "bm21_3", "intro_drive" );
	level.vehicles_no_breach["gaztiger_2"] thread maps\black_ice_util::delete_at_anim_end( "gaztiger_2", "intro_drive" );
	level.vehicles_no_breach["snowmobile_2"] thread maps\black_ice_util::delete_at_anim_end( "snowmobile_2", "intro_drive" );
	
	while ( !( level.vehicles_no_breach["snowmobile_1"] maps\black_ice_util::check_anim_time( "snowmobile_1", "intro_drive", 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}
	
	// Take the first snowmobile and use him for the breach as well, spawn off first frame anim
	
	//TAG CP: commenting out the snowmobile*************************************************
	//level.breach_anim_node thread anim_first_frame_solo( level.vehicles_no_breach["snowmobile_1"], "snowmobile_breach" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
notetrack_snake_cam_retract( gaz71 )
{
	level.snake_cam_anim_node thread anim_single_solo( level.snake_cam_dummy, "retract" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
notetrack_snake_enemy_dismount( gaz71 )
{
	// get and spawn guys
	spawners	  = GetEntArray( "enemy_dismount", "script_noteworthy" );
	dismount_guys = array_spawn( spawners );
	
	// init animnames
	foreach ( guy in dismount_guys )
	{
		guy.animname = guy.script_parameters;
		guy maps\black_ice_util::ignore_everything();
		guy thread magic_bullet_shield();
    }
	
	// animate
	level.snake_cam_anim_node anim_single( dismount_guys, "enemy_dismount" );
	
	// cleanup guys
	foreach ( guy in dismount_guys )
	{
		guy stop_magic_bullet_shield();
		guy Delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
notetrack_snake_cam_lens_water( snake_cam )
{
	
	flag_set( "flag_snake_cam_below_water" );
	// Play waterline FX
	player_view_fx_source = Spawn( "script_model", ( 0, 0, 0 ) );
	player_view_fx_source SetModel( "tag_origin" );
	player_view_fx_source LinkToPlayerView( level.player, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
	PlayFXOnTag( getfx( "snake_cam_waterline_under" ), player_view_fx_source, "tag_origin" );
	
	level waittill( "snake_cam_transition_to_underwater_complete" );
	StopFXOnTag( getfx( "snake_cam_waterline_under" ), player_view_fx_source, "tag_origin" );
	player_view_fx_source Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
notetrack_snake_cam_underwater_transition( snake_cam )
{
	level notify( "notify_underwater_transition" );
	flag_set( "flag_intro_above_ice" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_breach_anims()
{
	level.allies_breach_anim_node notify( "stop_loop" );
	
	for ( i = 0; i < level.CONST_EXPECTED_NUM_SWIM_ALLIES; i++ )
	{
		level.allies_breach_anim_node thread anim_single_solo( level._allies_swim[ i ], "breach_ally" + ( i + 1 ) );
	}
	
	// Enemies
	for( i = 0; i < level.ice_breach_enemies.size; i++ )
	{
		// Thread off the anim and set the death anim
		level.breach_anim_node thread anim_single_solo( level.ice_breach_enemies[i], "introbreach_opfor" + i );
		level.ice_breach_enemies[i].deathAnim = level.ice_breach_enemies[i] maps\_utility::getanim( "death_anim" + i );
		
		// tagBR< note > Was told not to put these in as AndyM is tasked
		//PlayFX( getfx( "jump_into_water_splash" ), level.ice_breach_enemies[i].origin );
		//PlayFXOnTag( getfx( "jump_into_water_trail" ), level.ice_breach_enemies[i], "tag_origin" );
	}
	
	// Props
	level.breach_anim_node thread anim_single( level.breach_props, "intro_breach" );
	
	thread swim_breach_ice_anims();
	
	// Vehicles
	level.breach_anim_node thread anim_single( level.breach_vehicles, "intro_breach" );
	thread maps\black_ice_fx::intro_turn_on_vehicle_underwater_lights_fx();
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_breach_ice_anims()
{
	level endon( "bc_player_ready" );
	
	while ( !( level.breach_props["ice_chunks1"] maps\black_ice_util::check_anim_time( "ice_chunks1", "intro_breach", 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}
	
	level.breach_anim_node thread anim_loop_solo( level.breach_props["ice_chunks1"], "intro_breach_loop", "stop_loop" );
	//level.breach_anim_node thread anim_loop_solo( level.breach_props["ice_chunks2"], "intro_breach_loop", "stop_loop" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree( "generic_human" );
swim_enemy_death_anim_override()
{
	if ( !IsDefined( self.noDeathSound ) )
	{
		self animscripts\death::PlayDeathSound();
	}
		
	if ( IsDefined( self.deathAnim ) )
    {
		self AnimMode( "nogravity" );
		self StopAnimScripted();
		//self SetFlaggedAnimKnobAllRestart( "deathanim", self.deathAnim, %body, 1, .1 );
		self SetFlaggedAnimKnobLimitedRestart( "deathanim", self.deathAnim, 1, .4 );
		PlayFXOnTag( getfx( "swim_ai_death_blood" ), self, "j_spineupper" );
		
		// tagBR< note >: MUST wait here...death scripts insist on it
		wait GetAnimLength( self.deathAnim );
		
		return true;
    }
	
	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_allies_swim_forward()
{
	for ( i = 0; i < level._allies_swim.size; i++ )
	{
		thread swim_single_ally_swim_forward( i );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_single_ally_swim_forward( index )
{
	level.allies_breach_anim_node anim_single_solo( level._allies_swim[ index ], "surface_ally" + ( index + 1 ) );
	
	if ( !flag( "flag_player_breaching" ) )
	{
		level.allies_breach_anim_node thread anim_loop_solo( level._allies_swim[ index ], "surface_ally" + ( index + 1 ) + "_idle" );
		//level._allies_swim[ index ] SetLookAtEntity( level.player );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_ally_surface_anim()
{
	//level._allies_swim[ 0 ] SetLookAtEntity();
	//level._allies_swim[ 1 ] SetLookAtEntity();
	vig = level.allies_breach_anim_node;
	
	// old times 0.0, 0.0, 5.9, 6.1
	vig thread maps\black_ice_swim::scuba_surface( 0.5, level._allies_swim[ 0 ], "surface_ally1_up", level._allies[ 0 ], "bc_node_surf_ally1" );
	vig thread maps\black_ice_swim::bravo_post_snake_cam( 0.0, level._bravo[ 0 ] , "bc_node_surf_bravo1", "surface_ally3_up" );
	vig thread maps\black_ice_swim::bravo_post_snake_cam( 0.0, level._bravo[ 1 ] , "bc_node_surf_bravo2" );
	vig maps\black_ice_swim::scuba_surface( 2.0, level._allies_swim[ 1 ], "surface_ally2_up", level._allies[ 1 ], "bc_node_surf_ally2" );
	
	
	// This notifies to swap the swim allies to normal dudes
	level notify( "notify_ally_swim_surface_anims_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_truck_surface_anim()
{
	struct = getstruct( "vignette_truck_fall", "script_noteworthy" );
	blackice_ice_chunks_truck = spawn_anim_model( "blackice_ice_chunks_truck" );
	surface_truck = spawn_anim_model( "bm21_1" );
	level.surface_truck = surface_truck;
	level.blackice_ice_chunks_truck = blackice_ice_chunks_truck;
	
	scene_pieces = [ surface_truck, blackice_ice_chunks_truck] ;
	

	// PlayFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], surface_truck, "tag_taillight_left" ); // TEMP TEMP TATRA
	// PlayFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], surface_truck, "tag_taillight_right" ); // TEMP TEMP TATRA
	// PlayFXOnTag( level._effect[ "vehicle_bm21_brakelight_light" ], surface_truck, "tag_fx_tank" ); // TEMP TEMP TATRA
	// PlayFXOnTag( level._effect[ "truck_exhaust" ], surface_truck, "tag_fx_cab" ); // TEMP TEMP TATRA
	
	struct anim_first_frame( scene_pieces, "surface_truck" );
	
	//struct anim_first_frame_solo( blackice_ice_chunks_truck, "surface_truck" );
	
	level waittill("flag_player_breaching");
	
	struct anim_single( scene_pieces, "surface_truck" );
	
	//struct anim_single_solo( blackice_ice_chunks_truck, "surface_truck" );
	
	//level.allies_breach_anim_node anim_last_frame_solo( surface_truck, "surface_truck" );
	
	//surface_truck delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_truck_surface_destroy()
{
	// StopFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.surface_truck, "tag_taillight_left" ); // TEMP TEMP TATRA
	// StopFXOnTag( level._effect[ "vehicle_bm21_brakelight" ], level.surface_truck, "tag_taillight_right" ); // TEMP TEMP TATRA
	wait 0.1;
	// StopFXOnTag( level._effect[ "vehicle_bm21_brakelight_light" ], level.surface_truck, "tag_fx_tank" ); // TEMP TEMP TATRA
	// StopFXOnTag( level._effect[ "truck_exhaust" ], level.surface_truck, "tag_fx_cab" ); // TEMP TEMP TATRA
	
	level.surface_truck Delete();
	level.surface_truck = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_player_surface_anim()
{
	player_rig_arms = spawn_anim_model( "player_rig" );
	player_rig_arms SetAnim( level.scr_anim[ "player_rig" ][ "player_surface_arms" ] );
	
	org = player_rig_arms getTagOrigin( "tag_knife_attach" );
	
	// Need to do some blending magic ---
	level.player_rig = spawn_anim_model( "player_rig" );
	level.player_rig Hide();
	//level.allies_breach_anim_node anim_first_frame_solo( level.player_rig, "player_surface" );
	level.allies_breach_anim_node thread anim_single_solo( level.player_rig, "player_surface_root" );
	level.player PlayerLinkToBlend( level.player_rig, "tag_player", 1.6 );
	
	//player_mask
	player_mask = spawn_anim_model( "player_mask", org );
	//player_mask StartUsingHeroOnlyLighting();
	level.player_mask = player_mask;
	player_mask Hide();
	level.allies_breach_anim_node thread anim_single_solo( player_mask, "mask_surface" );
		
	// We are playing a 2nd set of anims when the screen goes black
	while ( !( level.player_rig maps\black_ice_util::check_anim_time( "player_rig", "player_surface_root", 1.0 ) ) )
	{
		// This is called off an anim notetrack when the screen goes black, to swap to the 2nd anims
		if ( flag( "flag_surface_anim_swap" ) )
		{
			break;
		}
		
		org = level.player GetEye();
		ang = level.player GetPlayerAngles();
		player_rig_arms.origin = org;
		player_rig_arms.angles = ang;

		wait level.TIMESTEP;
	}
	
	// Stop the first set of anims, play the 2nd set
	player_rig_arms Delete();
	level.player_rig Show();
	
	level.player_rig StopAnimScripted();
	player_mask StopAnimScripted();
	level._bravo[ 0 ] StopAnimScripted();
	
	level.allies_breach_anim_node thread anim_single_solo( level.player_rig, "player_surface_root_pt2" );
	level.allies_breach_anim_node thread anim_single_solo( player_mask, "mask_surface_pt2" );
	level.allies_breach_anim_node thread anim_single_solo( level._bravo[ 0 ], "surface_ally3_up_pt2" );
	
	while ( !( level.player_rig maps\black_ice_util::check_anim_time( "player_rig", "player_surface_root_pt2", 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}
	
	// player out of water
	level notify( "bc_player_ready" );
	
	player_mask Delete();
	level.player_mask = undefined;
	
	// tagBR< note >: Turn off the bubble effects (played off the swim allies' flippers)
	thread maps\_swim_ai_common::restore_water_footsteps();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

intro_player_goggles_watersheeting_fx()
{
//wait 4.0;	
level.player SetWaterSheeting( 1, 3 );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cw_common_breach_player( door )
{
	vig_node = GetEnt("cw_vig_common_room_breach", "targetname");
	

	// spawn models
	level.breach_charge = spawn_anim_model( "breach_door_charge" );
	player_rig = spawn_anim_model( "player_rig" );
	player_rig hide();
	
	//setup door
	door assign_animtree( "common_door" );
	
	// ready player
	level.player disableweapons();
	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );

	guys = [ player_rig, level.breach_charge ];
	arc = 0;

	// level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	thread smooth_player_link( player_rig, 0.4 );

	// vig_node anim_single(guys, "breach");
	vig_node thread anim_single_solo( guys[1], "breach" );
	door thread anim_single_solo( door, "bullets" );
	vig_node anim_single_solo( guys[0], "breach" );


	// clean up player
	level.player unlink();
	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );
	
	// clean up models
	player_rig delete();
	
}

cw_common_breach_draw_weapon( dude )
{
	level.player enableweapons();
}

cw_common_breach_allies()
{
	vig_node = GetEnt( "cw_vig_common_room_breach", "targetname" );
	
	vig_node anim_single( level._allies, "rec_breach" );
	vig_node thread anim_loop( level._allies, "rec_breach_idle", "stop_looping_anim" );
	
	// wait for player to throw a flash
	flag_wait( "flag_common_breach_done" );
	
	// go into common room
	vig_node notify( "stop_looping_anim" );
	vig_node anim_single( level._allies, "rec_breach_move", undefined, 0.1 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vig_actor_kill( guy )
{
    if ( !isalive( guy ) )
        return;

	if( IsDefined( guy.magic_bullet_shield ) )
	{	
		guy stop_magic_bullet_shield();
	}

    guy.allowDeath = true;
    guy.a.nodeath = true;
    guy set_battlechatter( false );

    guy kill(); 
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "generic_human" );
spawn_dead_bodies_mudpumps()
{		
	// Pipe Deck Dead Bodies
	level.scr_animtree[ "body_mud1" ] = #animtree;
	level.scr_anim[ "body_mud1" ][ "bodies" ][0] = %blackice_mudpump_bodies_01;
	level.scr_model[ "body_mud1" ] = "body_chemwar_russian_assault_dd";
	
	level.scr_animtree[ "body_mud2" ] = #animtree;
	level.scr_anim[ "body_mud2" ][ "bodies" ][0] = %blackice_mudpump_bodies_02;
	level.scr_model[ "body_mud2" ] = "body_chemwar_russian_assault_dd";

	level.scr_animtree[ "body_mud3" ] = #animtree;
	level.scr_anim[ "body_mud3" ][ "bodies" ][0] = %blackice_mudpump_bodies_03;
	level.scr_model[ "body_mud3" ] = "body_chemwar_russian_assault_e";

	level.scr_animtree[ "body_mud4" ] = #animtree;
	level.scr_anim[ "body_mud4" ][ "bodies" ][0] = %blackice_mudpump_bodies_04;
	level.scr_model[ "body_mud4" ] = "body_chemwar_russian_assault_d";

	level.scr_animtree[ "body_mud5" ] = #animtree;
	level.scr_anim[ "body_mud5" ][ "bodies" ][0] = %blackice_mudpump_bodies_05;
	level.scr_model[ "body_mud5" ] = "body_chemwar_russian_assault_d";

	level.scr_animtree[ "body_mud6" ] = #animtree;
	level.scr_anim[ "body_mud6" ][ "bodies" ][0] = %blackice_mudpump_bodies_06;
	level.scr_model[ "body_mud6" ] = "body_chemwar_russian_assault_e";

	node = getstruct( "bodies", "script_noteworthy" );
	
	guys = [];
	
	for( i = 1; i <= 6; i++ )
    {
		guy = spawn_anim_model( "body_mud" + i );
		guys = array_add( guys, guy );
		if ( mod( i, 2 ) == 0 )
			guy Attach( "head_chemwar_russian_b","" );
		else
			guy Attach( "head_chemwar_russian_c","" );
    }

	node anim_loop(guys, "bodies");
}

#using_animtree( "generic_human" );
spawn_dead_bodies_pipe_deck()
{	
	// Pipe Deck Dead Bodies
	level.scr_animtree[ "body1" ] = #animtree;
	level.scr_anim[ "body1" ][ "bodies" ][0] = %blackice_pipedeck_bodies_01;
	level.scr_model[ "body1" ] = "body_chemwar_russian_assault_dd";
	
	level.scr_animtree[ "body2" ] = #animtree;
	level.scr_anim[ "body2" ][ "bodies" ][0] = %blackice_pipedeck_bodies_02;
	level.scr_model[ "body2" ] = "body_chemwar_russian_assault_dd";

	level.scr_animtree[ "body3" ] = #animtree;
	level.scr_anim[ "body3" ][ "bodies" ][0] = %blackice_pipedeck_bodies_03;
	level.scr_model[ "body3" ] = "body_chemwar_russian_assault_e";

	level.scr_animtree[ "body4" ] = #animtree;
	level.scr_anim[ "body4" ][ "bodies" ][0] = %blackice_pipedeck_bodies_04;
	level.scr_model[ "body4" ] = "body_chemwar_russian_assault_d";

	level.scr_animtree[ "body5" ] = #animtree;
	level.scr_anim[ "body5" ][ "bodies" ][0] = %blackice_pipedeck_bodies_05;
	level.scr_model[ "body5" ] = "body_chemwar_russian_assault_d";

	level.scr_animtree[ "body6" ] = #animtree;
	level.scr_anim[ "body6" ][ "bodies" ][0] = %blackice_pipedeck_bodies_06;
	level.scr_model[ "body6" ] = "body_chemwar_russian_assault_e";

	level.scr_animtree[ "body7" ] = #animtree;
	level.scr_anim[ "body7" ][ "bodies" ][0] = %blackice_pipedeck_bodies_07;
	level.scr_model[ "body7" ] = "body_chemwar_russian_assault_d";

	level.scr_animtree[ "body8" ] = #animtree;
	level.scr_anim[ "body8" ][ "bodies" ][0] = %blackice_pipedeck_bodies_08;
	level.scr_model[ "body8" ] = "body_chemwar_russian_assault_ee";

	level.scr_animtree[ "body9" ] = #animtree;
	level.scr_anim[ "body9" ][ "bodies" ][0] = %blackice_pipedeck_bodies_09;
	level.scr_model[ "body9" ] = "body_chemwar_russian_assault_dd";

	level.scr_animtree[ "body10" ] = #animtree;
	level.scr_anim[ "body10" ][ "bodies" ][0] = %blackice_pipedeck_bodies_10;
	level.scr_model[ "body10" ] = "body_chemwar_russian_assault_e";
	
	node = getstruct( "bodies", "script_noteworthy" );

	guys = [];
	
	for( i = 1; i <= 10; i++ )
    {
		guy = spawn_anim_model( "body" + i );
		guys = array_add( guys, guy );
		if ( mod( i, 2 ) == 0 )
			guy Attach( "head_chemwar_russian_b","" );
		else
			guy Attach( "head_chemwar_russian_c","" );
    }

	node anim_loop(guys, "bodies");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//******************************************************************

vig_pipdeck_wires()
{
	node = getstruct("vig_pipdeck_wires", "script_noteworthy");
	// model0 = spawn_anim_model("model0");
	wires = GetEnt( "blackice_wires_pipedeck_anim", "targetname" );
	wires assign_animtree ("wires");
	
	guys = [];
	guys["wires"] = wires;

	node anim_loop(guys, "vig_pipdeck_wires");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//******************************************************************

runout_group1()
{
	node = getstruct("vignette_exfil_runout", "script_noteworthy");
	debris01 = spawn_anim_model("debris01");

	guys = [];
	guys["debris01"] = debris01;
	node anim_first_frame(guys, "runout_group1");
	wait 2.0;
	node anim_single(guys, "runout_group1");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//******************************************************************

runout_group2()
{
	node = getstruct("vignette_exfil_runout", "script_noteworthy");
	debris02 = spawn_anim_model("debris02");

	guys = [];
	guys["debris02"] = debris02;
	node anim_first_frame(guys, "runout_group2");
	wait 4.85;
	node anim_single(guys, "runout_group2");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//******************************************************************

runout_group3()
{
	node = getstruct("vignette_exfil_runout", "script_noteworthy");
	debris03 = spawn_anim_model("debris03");

	guys = [];
	guys["debris03"] = debris03;
	node anim_first_frame(guys, "runout_group3");
	wait 7.0;
	node anim_single(guys, "runout_group3");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//******************************************************************