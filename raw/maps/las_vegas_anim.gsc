#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;

main()
{
	
	precacheAnims();
	dialog();
	sounds();
	
	thread animated_foliage_system();
	
}

precacheAnims()
{
	human_anims();
	wounded_ai_anims();
	animated_props_anims();
	model_anims();
	player_anims();
	vehicle_anims();
	
	strings = [];
	strings[0] = "ninja";
	strings[1] = "leader";
	strings[2] = "wounded_ai";
	foreach( aName in strings )
		creepwalk_anims( aName );
}

#using_animtree( "generic_human" );
human_anims()
{	

	// generic
	level.scr_anim[ "generic" ][ "active_patrolwalk_gundown" ] = %active_patrolwalk_gundown;
	
	level.scr_anim[ "generic" ][ "doorkick_stand" ] 	= %doorkick_2_stand;
	level.scr_anim[ "generic" ][ "patrol_bored_idle" ][0] 	= %patrol_bored_idle;
	level.scr_anim[ "generic" ][ "patrol_bored_react_look1" ] 	= %patrol_bored_react_look_v1;
	level.scr_anim[ "generic" ][ "patrol_bored_react_wave" ] 	= %patrol_bored_react_wave;
	level.scr_anim[ "generic" ][ "stand_2_run_180L" ] 	= %stand_2_run_180L;
	level.scr_anim[ "generic"][ "search_walk_1" ] = %payback_search_walk_1_noloop;
	level.scr_anim[ "generic"][ "exposed_death" ] =%exposed_death;
	level.scr_anim[ "generic"][ "active_patrolwalk_v1" ] =%active_patrolwalk_v1;
	level.scr_anim[ "generic"][ "active_patrolwalk_v3" ] =%active_patrolwalk_v3;
	level.scr_anim[ "generic"][ "active_patrolwalk_v5" ] =%active_patrolwalk_v5;
	level.scr_anim[ "generic" ][ "combatwalk_F_spin" ] 		= %combatwalk_F_spin;
	
	level.scr_anim[ "generic" ][ "combat_jog" ] = %combat_jog;
	level.scr_anim[ "ninja" ][ "combat_jog" ] = %combat_jog;
	
	level.scr_anim[ "generic" ][ "vegas_guy_open_double_doors" ] = %vegas_guy_open_double_doors; // generic_double_doors_open
	addnotetrack_flag( "generic", "door_open", "TRACKFLAG_kitchen_exit_double_doors_open", "vegas_guy_open_double_doors" );
	
	level.scr_anim[ "leader" ][ "readystand_idle" ][0]	= %readystand_idle;
	
	// new run cycles
	level.scr_anim[ "ninja"][ "sprint_1hand_gunup" ] = %vegas_reverse_1hand_gunUp_sprint;
	level.scr_anim[ "ninja"][ "sprint_1hand_gundown" ] = %vegas_reverse_1hand_gunDown_sprint;
	
	// interrogation
	
	// bar
	level.scr_anim[ "wounded_ai" ][ "bar_diaz_stepup" ] 	= %vegas_baker_limp_step_up;
	level.scr_anim[ "wounded_ai" ][ "bar_diaz_stepdown" ] 	= %vegas_baker_limp_step_down;
	
	level.scr_anim[ "ninja" ][ "doorkick_stand" ] 	= %doorkick_2_stand;
	
	level.scr_anim[ "ninja" ][ "humanshield_doorstack" ]				  = %corner_standR_trans_IN_1;
	level.scr_anim[ "ninja" ][ "humanshield_doorstack_idle" ][ 0 ]		  = %corner_standR_alert_idle;
	level.scr_anim[ "ninja"		 ][ "humanshield_checkdoor" ]			  = %vegas_keegan_door_check;
	level.scr_anim[ "leader"	 ][ "humanshield_doorstack" ]			  = %vegas_baker_door_stack_right;
	level.scr_anim[ "leader"	 ][ "humanshield_checkdoor" ]			  = %vegas_baker_door_check;
	level.scr_anim[ "wounded_ai" ][ "humanshield_doorstack" ]			  = %vegas_diaz_door_stack;
	level.scr_anim[ "wounded_ai" ][ "humanshield_doorstack_idle" ][ 0 ]	  = %vegas_baker_pillar_stand_idle;
	level.scr_anim[ "wounded_ai"	 ][ "humanshield_checkdoor" ]		  = %vegas_diaz_door_check;
	addNotetrack_flag( "ninja", "door_attach" , "TRACKFLAG_bar_event_attach_door", "humanshield_checkdoor"  );
	addNotetrack_flag( "ninja", "door_detach" , "TRACKFLAG_bar_event_detach_door", "humanshield_checkdoor"  );
	
	level.scr_anim[ "ninja"		][ "vegas_humanshield_breach"		 ] = %vegas_keegan_breach;
	level.scr_anim[ "ninja"		][ "vegas_humanshield_breach_loop"	 ] = %vegas_keegan_breach_loop;
	level.scr_anim[ "ninja"		][ "vegas_humanshield_breach_ending" ] = %vegas_keegan_breach_exit;
	level.scr_anim[ "leader"	 ][ "humanshield_doorstack_idle" ][0]		   = %corner_standL_alert_idle;
	level.scr_anim[ "leader"	 ][ "humanshield_baker_trans_fire" ]		   = %cornerstndl_lean_2_alert; //corner_standL_blindfire_v2
	level.scr_anim[ "leader"	 ][ "humanshield_baker_fire" ][0]		   = %cornerstndl_lean_aim_5;
	level.scr_anim[ "leader"	 ][ "humanshield_baker_fire_trans" ]		   = %cornerstndl_alert_2_lean;
	level.scr_anim[ "sacrifice" ][ "vegas_humanshield_breach"		 ] = %vegas_guy_shot_breach;
	level.scr_anim[ "hostage"	][ "vegas_humanshield_breach"		 ] = %vegas_guy_hostage_breach;
	level.scr_anim[ "hostage"	][ "vegas_humanshield_breach_loop"	 ] = %vegas_guy_hostage_breach_loop;
	level.scr_anim[ "hostage"	][ "vegas_humanshield_breach_ending" ] = %vegas_guy_hostage_breach_exit;
 
	addnotetrack_flag( "leader", "", "TRACKFLAG_humanshield_baker_nod", "humanshield_checkdoor" );
	addNotetrack_flag( "sacrifice", "start_ragdoll" , "TRACKFLAG_start_sacrifice_ragdoll", "vegas_humanshield_breach" );
	addNotetrack_customFunction( "sacrifice", "guy_shot" , ::bar_sacrifice_kill, "vegas_humanshield_breach" );
	addNotetrack_customFunction( "hostage"	, "guy_death", ::ai_kill, "vegas_humanshield_breach_ending" );
	//addNotetrack_customFunction( "hostage"	, "guy_death", ::ai_dropweapon, "vegas_humanshield_breach_ending" );
	
	level.scr_anim[ "box_guy" ][ "vegas_guy_1_box_carry_walk" ] 	= %vegas_guy_1_box_carry_walk;
	level.scr_anim[ "box_guy" ][ "vegas_guy_2_box_carry_walk" ] 	= %vegas_guy_2_box_carry_walk;
	level.scr_anim[ "box_guy" ][ "vegas_guy_1_box_carry_dead" ] 	= %vegas_guy_1_box_carry_death;
	level.scr_anim[ "box_guy" ][ "vegas_guy_2_box_carry_dead" ] 	= %vegas_guy_2_box_carry_death;
	level.scr_anim[ "box_guy" ][ "vegas_guy_1_box_carry_turn_shoot" ] 	= %vegas_guy_1_box_carry_turn_shoot;
	level.scr_anim[ "box_guy" ][ "vegas_guy_2_box_carry_turn_shoot" ] 	= %vegas_guy_2_box_carry_turn_shoot;
	
	level.scr_anim[ "radio_guy"	  ][ "bar_radioguy_idle" ][0] = %parabolic_phoneguy_idle;
	level.scr_anim[ "radio_guy"	  ][ "bar_radioguy_react" ] = %parabolic_phoneguy_reaction;
	level.scr_anim[ "radio_guy"	  ][ "bar_radioguy_death" ] = %vegas_guy_radio_death;
	level.scr_anim[ "radio_guy"	  ][ "bar_radio_pickup" ] = %vegas_guy_radio_pickup;
	level.scr_anim[ "ninja"	  ][ "bar_radio_pickup" ] = %vegas_keegan_radio_pickup;
	addNotetrack_notify( "ninja", "grab_radio", "keegan_grab_radio", "bar_radio_pickup" );
	addNotetrack_notify( "ninja", "holster_radio", "keegan_holster_radio", "bar_radio_pickup" );
	
	level.scr_anim[ "ninja"	  ][ "double_doors_open" ] = %vegas_keegan_open_double_doors;
	
	// kitchen 
	
	level.scr_anim[ "ninja"][ "look_around" ] = %combatwalk_F_spin;
	
	// kitchen walk
	level.scr_anim[ "wounded_ai" ][ "vegas_diaz_kitchen_stumble" ]		   = %vegas_diaz_kitchen_stumble;
	level.scr_anim[ "wounded_ai" ][ "vegas_diaz_kitchen_idle" ][0]		   = %vegas_diaz_kitchen_idle;
	level.scr_anim[ "wounded_ai" ][ "vegas_diaz_kitchen_idle_exit" ]		   = %vegas_diaz_kitchen_idle_exit;
	
	// kitchen fall
	level.scr_anim[ "ninja" ][ "casino_kitchen_event_enter" ]		   = %vegas_keegan_kitchen_enter_start;
	addNotetrack_customFunction( "ninja"	, "radio_from_hip", ::radio_to_hand, "casino_kitchen_event_enter" );
	addNotetrack_customFunction( "ninja", "radio_to_hip" , ::radio_to_hip, "casino_kitchen_event_enter" );
	level.scr_anim[ "ninja" ][ "casino_kitchen_keegan_wave_loop" ][ 0 ] = %vegas_keegan_kitchen_enter_loop;
	level.scr_anim[ "ninja" ][ "casino_kitchen_event_enter_end" ] = %vegas_keegan_kitchen_enter_end;
	level.scr_anim[ "ninja" ][ "vegas_keegan_kitchen_wait_loop" ][0] = %vegas_keegan_kitchen_wait_loop;
	level.scr_anim[ "ninja"		 ][ "casino_kitchen_event_ambush" ]	   = %vegas_keegan_kitchen_ambush;
	addNotetrack_customFunction( "ninja", "friendlies_exit", maps\las_vegas_casino::casino_kitchen_friendlies_exit, "casino_kitchen_event_ambush" );
	
	level.scr_anim[ "leader" ][ "casino_kitchen_event_approach"	  ]		= %cqb_trans_2_readystand_6;
	level.scr_anim[ "leader" ][ "casino_kitchen_event_enter"	  ]		= %vegas_baker_kitchen_enter;
	level.scr_anim[ "leader" ][ "casino_kitchen_event_wait_loop" ][ 0 ] = %vegas_baker_kitchen_wait_loop;
	level.scr_anim[ "leader" ][ "casino_kitchen_event_ambush_exit"	  ]		= %vegas_baker_kitchen_ambush;
	
	level.scr_anim[ "wounded_ai" ][ "casino_kitchen_event_enter"  ]			= %vegas_diaz_kitchen_enter;
	level.scr_anim[ "wounded_ai" ][ "casino_kitchen_event_wait_loop" ][ 0 ] = %vegas_diaz_kitchen_wait_loop;	
	level.scr_anim[ "wounded_ai" ][ "casino_kitchen_event_ambush_exit" ]			= %vegas_diaz_kitchen_ambush;
	
	level.scr_anim[ "flashlight_guy" ][ "casino_kitchen_event_ambush" ]		= %vegas_guy_flashlight_kitchen_ambush;
	addNotetrack_notify( "flashlight_guy", "flashlight_unlink", "flashlight_guy_unlink_flashlight", "casino_kitchen_event_ambush" );
	
	// hallway
	
	level.scr_anim[ "ninja" ][ "open_door_flathand" ] = %hunted_open_barndoor_flathand;
	level.scr_anim[ "ninja" ][ "open_door_flathand_idle" ][0] = %hunted_open_barndoor_idle;
	
	level.scr_anim[ "wounded_ai" ][ "diaz_hallway_inject" ] = %run_pain_stumble;
	level.scr_anim[ "generic" ][ "so_hijack_search_flashlight_high_loop" ][ 0 ] = %so_hijack_search_flashlight_high_loop;
	level.scr_anim[ "ninja" ][ "top_stairs_signal" ] = %CQB_stand_signal_stop;
	
	level.scr_anim[ "rappeler" ][ "temp_rappel_over_rail" ] = %oilrig_rappel_over_rail_R; // temp
	
	level.scr_anim[ "ninja" ][ "sliding_door" ] = %sw_hanger_sliding_door_ally_01; // temp
	
	level.scr_anim[ "ninja" ][ "tactical_open_door" ] = %intro_tactical_open_door_push_a; // temp
	
	//	addNotetrack_customFunction( "rappeler", "feet_on_ground", ::rappelers_stop );	
	
	
	// casino floor
	
	level.scr_anim[ "leader"	 ][ "traverse_jumpdown_130"		 ]		= %traverse_jumpdown_130;
	
	level.scr_anim[ "ninja"		 ][ "sandstorm_walk"		]		= %payback_pmc_sandstorm_stumble_1;
	level.scr_anim[ "leader"	 ][ "sandstorm_walk"		]		= %payback_pmc_sandstorm_stumble_2;
	level.scr_anim[ "wounded_ai" ][ "sandstorm_walk"		]		= %payback_pmc_sandstorm_stumble_3;
	
	level.scr_anim[ "gate_guy" ][ "rununder_casino_gate" ] 	= %unarmed_runinto_garage;
	level.scr_anim[ "gate_guy" ][ "close_casino_gate" ] 	= %unarmed_close_garage;
	
	level.scr_anim[ "ninja"		 ][ "vegas_keegan_gate_approach"	 ]		= %vegas_keegan_gate_approach;
	level.scr_anim[ "ninja"		 ][ "vegas_keegan_gate_idle"		 ][ 0 ] = %vegas_keegan_gate_lift_idle;
	level.scr_anim[ "ninja"		 ][ "vegas_keegan_gate_idle_twitch" ]		= %vegas_keegan_gate_lift_idle_twitch;
	level.scr_anim[ "ninja"		 ][ "vegas_mantle_under_gate"		]		= %vegas_keegan_gate_thru;
	level.scr_anim[ "leader"	 ][ "vegas_mantle_under_gate"		]		= %vegas_baker_gate_thru;
	level.scr_anim[ "wounded_ai" ][ "vegas_mantle_under_gate"		]		= %vegas_diaz_gate_thru;
	addNotetrack_flag( "ninja", "gate_lift_start" , "TRACKFLAG_floor_open_gate", "vegas_keegan_gate_approach"  );
	addNotetrack_flag( "ninja", "gate_lift_end" , "TRACKFLAG_floor_gate_lifed", "vegas_keegan_gate_approach"  );
	addNotetrack_flag( "ninja", "gate_release" , "TRACKFLAG_floor_close_gate", "vegas_mantle_under_gate"  );
	
	// hotel
	level.scr_anim[ "vending_dude" ][ "vending_machine_sequence" ] = %london_vending_blocker_guy1;
	
	// raid
	level.scr_anim[ "generic" ][ "vegas_raid_enemy_aware1" ] = %vegas_raid_enemy_aware1;
	level.scr_anim[ "generic" ][ "vegas_raid_enemy_aware2" ] = %vegas_raid_enemy_aware2;
	level.scr_anim[ "generic" ][ "vegas_raid_enemy_scout_aware1" ] = %vegas_raid_enemy_scout_aware1;
	level.scr_anim[ "generic" ][ "vegas_raid_enemy_scout_aware2" ] = %vegas_raid_enemy_scout_aware2;
	
	level.scr_anim[ "leader"	 ][ "vegas_raid_enter"		 ] = %vegas_keegan_raid_enter;
	level.scr_anim[ "leader"	 ][ "vegas_raid_enter_jump2" ] = %vegas_baker_raid_run_enter;
	level.scr_anim[ "wounded_ai" ][ "vegas_raid_enter"		 ] = %vegas_diaz_raid_enter;
	
	//level.scr_anim[ "ninja"][ "vegas_raid_enter_idle" ][0]	  =%vegas_keegan_raid_enter_idle;
	level.scr_anim[ "leader" ][ "vegas_raid_enter_idle" ][ 0 ]	  = %vegas_keegan_raid_enter_idle;
	//level.scr_anim[ "wounded_ai"][ "vegas_raid_enter_idle" ][0] =%vegas_diaz_raid_lookaround_idle;
	
	level.scr_anim[ "ninja"		 ][ "vegas_raid_lookaround" ] = %vegas_keegan_raid_lookaround;
	level.scr_anim[ "leader"	 ][ "vegas_raid_lookaround" ] = %vegas_baker_raid_lookaround;
	level.scr_anim[ "wounded_ai" ][ "vegas_raid_lookaround" ] = %vegas_diaz_raid_lookaround;
	
	level.scr_anim[ "ninja" ][ "combatwalk_F_spin" ] 		= %combatwalk_F_spin;
	
	level.scr_anim[ "ninja"		 ][ "vegas_raid_jump" ] = %vegas_keegan_raid_run_jump;
	addNotetrack_flag( "ninja", "jump" , "TRACKFLAG_KEEGAN_JUMP", "vegas_raid_jump"  );
	level.scr_anim[ "leader"	 ][ "vegas_raid_jump" ] = %vegas_baker_raid_window_jump;
	level.scr_anim[ "wounded_ai" ][ "vegas_raid_jump" ] = %vegas_baker_raid_window_jump;
	
	level.scr_anim[ "ninja" ][ "vegas_raid_jump_tarp_fall" ] = %vegas_keegan_raid_jump_tarp_fall;
	
	// jl pick up from slide                             
	
	level.scr_anim[ "generic" ][ "reaction_180" ] = %run_reaction_180;
	level.scr_anim[ "generic" ][ "run_180" ] = %run_turn_180;

	level.scr_anim[ "generic" ][ "run_duck" ] = %run_react_duck;
	level.scr_anim[ "generic" ][ "run_flinch" ] = %run_react_flinch;
	level.scr_anim[ "generic" ][ "run_stumble" ] = %run_react_stumble;
	
	//level.scr_anim[ "generic" ][ "dive_over_cover" ] = %africa_soap_dive_over_cover;
	
	// jog anim and look arounds - JL
	
	level.scr_anim[ "generic" ][ "patrol_jog" ] = %patrol_jog;
	level.scr_anim[ "generic" ][ "patrol_jog_360_once" ] = %patrol_jog_360_once;
	level.scr_anim[ "generic" ][ "patrol_jog_orders_once" ] = %patrol_jog_orders_once;
	level.scr_anim[ "generic" ][ "patrol_jog_look_up_once" ] = %patrol_jog_look_up_once;
	
	
	level.scr_anim[ "generic" ][ "patrol_walk_array" ] [ 0 ] = %active_patrolwalk_v1;
	level.scr_anim[ "generic" ][ "patrol_walk_array" ] [ 1 ] = %active_patrolwalk_v2;
	level.scr_anim[ "generic" ][ "patrol_walk_array" ] [ 2 ] = %active_patrolwalk_v3;
	level.scr_anim[ "generic" ][ "patrol_walk_array" ] [ 3 ] = %active_patrolwalk_v4;
	level.scr_anim[ "generic" ][ "patrol_walk_array" ] [ 4 ] = %active_patrolwalk_v5;
	
	////////////////////
// raid anims
////////////////////
	
	level.scr_anim[ "ninja"][ "raid_getup" ] 		= %vegas_keegan_raid_getup;
	level.scr_anim[ "leader"][ "raid_getup" ] 		= %vegas_baker_raid_getup;
	level.scr_anim[ "wounded_ai"][ "raid_getup" ] 	= %vegas_diaz_raid_getup;
	
	
///////////////////////////
// End anims
///////////////////////////
	level.scr_anim[ "ninja"][ "vegas_keegan_crash_getup" ] =%vegas_keegan_crash_getup;
	level.scr_anim[ "wounded_ai"][ "vegas_diaz_crash_getup" ] =%vegas_diaz_crash_getup;	
	level.scr_anim[ "leader"][ "vegas_baker_crash_getup" ] =%vegas_baker_crash_getup;
	
	level.scr_anim[ "ninja"][ "vegas_diaz_crash_wander_1" ] =%vegas_diaz_crash_wander_1;
	level.scr_anim[ "wounded_ai"][ "vegas_keegan_crash_wander_1" ] =%vegas_keegan_crash_wander_1;	
	level.scr_anim[ "leader"][ "vegas_baker_crash_wander_1" ] =%vegas_baker_crash_wander_1;			


	level.scr_anim[ "ninja"][ "vegas_keegan_crash_wander_2" ] =%vegas_keegan_crash_wander_2;
	level.scr_anim[ "wounded_ai"][ "vegas_diaz_crash_wander_2" ] =%vegas_diaz_crash_wander_2;	
	level.scr_anim[ "leader"][ "vegas_baker_crash_wander_2" ] =%vegas_baker_crash_wander_2;	
					
	level.scr_anim[ "ninja"][ "vegas_keegan_crash_wander_3" ] =%vegas_keegan_crash_wander_3;
	level.scr_anim[ "wounded_ai"][ "vegas_diaz_crash_wander_3" ] =%vegas_diaz_crash_wander_3;	
	level.scr_anim[ "leader"][ "vegas_baker_crash_wander_3" ] =%vegas_baker_crash_wander_3;			
			
			
	level.scr_anim[ "wounded_ai"][ "vegas_diaz_crash_wander_4" ] =%vegas_diaz_crash_wander_4;	
	level.scr_anim[ "leader"][ "vegas_baker_crash_wander_4" ] =%vegas_baker_crash_wander_4;			
			
		
	level.scr_anim[ "leader"][ "vegas_baker_run_pain" ] =%vegas_baker_run_pain;			
	level.scr_anim[ "leader"][ "vegas_baker_creepWalk_pain" ] =%vegas_baker_creepWalk_pain;		

	level.scr_anim[ "ninja"][ "creepwalk_traverse_under" ] =%creepwalk_traverse_under;		
	level.scr_anim[ "leader"][ "creepwalk_traverse_over_small" ] =%creepwalk_traverse_over_small;		
	
	
	level.scr_anim[ "generic"][ "creepwalk_traverse_under" ] =%creepwalk_traverse_under;		
	level.scr_anim[ "generic"][ "creepwalk_traverse_over_small" ] =%creepwalk_traverse_over_small;	
	
//	level.scr_anim[ "generic"][ "creepwalk_traverse_over_large" ] =%creepwalk_traverse_over_large;	
	
// ask addison who these are for?	
//	level.scr_anim[ "leader"][ "vegas_raid_guy_aware_B" ] =%vegas_raid_guy_aware_B;			
//	level.scr_anim[ "leader"][ "vegas_raid_guy_aware_A" ] =%vegas_raid_guy_aware_A;		

	level.scr_anim[ "ninja"][ "scout_sniper_price_wave" ] =%scout_sniper_price_wave; // do this before they move forward
	level.scr_anim[ "ninja"][ "cqb_stand_signal_stop" ] =%cqb_stand_signal_stop;
	level.scr_anim[ "ninja"][ "CornerStndR_alert_signal_enemy_spotted" ] =%CornerStndR_alert_signal_enemy_spotted;
	level.scr_anim[ "ninja"][ "CornerStndR_alert_signal_stopStay_down" ] =%CornerStndR_alert_signal_stopStay_down;
	level.scr_anim[ "ninja"][ "corner_standL_signal_move" ] =%corner_standL_signal_move;
	level.scr_anim[ "ninja"][ "corner_standL_signal_hold" ] =%corner_standL_signal_hold;
	
	level.scr_anim[ "ninja"][ "corner_standR_trans_CQB_IN_2" ] =%corner_standR_trans_CQB_IN_2;
	level.scr_anim[ "generic"][ "corner_standR_trans_CQB_IN_2" ] =%corner_standR_trans_CQB_IN_2;
	
	level.scr_anim[ "leader"][ "cornerCRL_twitchB" ] =%cornerCRL_twitchB;
	level.scr_anim[ "generic"][ "cornerCRL_twitchB" ] =%cornerCRL_twitchB;
	
	level.scr_anim[ "leader"][ "corner_standL_trans_CQB_IN_2" ] =%corner_standL_trans_CQB_IN_2;
	level.scr_anim[ "generic"][ "corner_standL_trans_CQB_IN_2" ] =%corner_standL_trans_CQB_IN_2;
	
	
	level.scr_anim[ "generic"][ "scout_sniper_price_wave" ] =%scout_sniper_price_wave;
	level.scr_anim[ "generic"][ "cqb_stand_signal_stop" ] =%cqb_stand_signal_stop;
	level.scr_anim[ "generic"][ "CornerStndR_alert_signal_enemy_spotted" ] =%CornerStndR_alert_signal_enemy_spotted;
	level.scr_anim[ "generic"][ "CornerStndR_alert_signal_stopStay_down" ] =%CornerStndR_alert_signal_stopStay_down;
	level.scr_anim[ "generic"][ "corner_standL_signal_move" ] =%corner_standL_signal_move;
	level.scr_anim[ "generic"][ "corner_standL_signal_hold" ] =%corner_standL_signal_hold;
	
	level.scr_anim[ "generic"][ "cqb_stand_react_E" ] =%cqb_stand_react_E;
	level.scr_anim[ "generic"][ "cqb_stand_react_B" ] =%cqb_stand_react_B;
	level.scr_anim[ "generic"][ "payback_sstorm_guard_shoot_reaction_1" ] =%payback_sstorm_guard_shoot_reaction_1;
	level.scr_anim[ "generic"][ "payback_sstorm_guard_shoot_reaction_2" ] =%payback_sstorm_guard_shoot_reaction_2;
	level.scr_anim[ "generic"][ "payback_sstorm_guard_shoot_reaction_3" ] =%payback_sstorm_guard_shoot_reaction_3;
	
	
	
		level.scr_anim[ "leader" ][ "baker_heliride_missle" ] = %vegas_baker_heliride_missle;
		level.scr_anim[ "ninja" ][ "keegan_heliride_missle" ] = %vegas_keegan_heliride_missle;
	
	level.scr_anim[ "chopper_pilot" ][ "vegas_heli_snipe_pilot" ] = %vegas_heli_snipe_pilot;
	
	level.scr_anim[ "ninja" ][ "vegas_keegan_bus_enter" ] = %vegas_keegan_bus_enter;
	level.scr_anim[ "generic" ][ "vegas_keegan_bus_enter" ] = %vegas_keegan_bus_enter;
	
	
	
		level.scr_anim[ "ninja" ][ "aas_72x_pilot_idle" ] = %aas_72x_pilot_idle;
		level.scr_anim[ "wounded_ai" ][ "aas_72x_guy3_idle" ] = %aas_72x_guy3_idle;
		level.scr_anim[ "leader" ][ "aas_72x_guy1_idle" ] = %aas_72x_guy1_idle;
	
		level.scr_anim[ "generic" ][ "aas_72x_pilot_idle" ] = %aas_72x_pilot_idle;
		level.scr_anim[ "generic" ][ "aas_72x_guy3_idle" ] = %aas_72x_guy3_idle;
		level.scr_anim[ "generic" ][ "aas_72x_guy1_idle" ] = %aas_72x_guy1_idle;
			
		level.scr_anim[ "leader" ][ "baker_aas72x_geton" ] = %vegas_baker_aas72x_geton;
		level.scr_anim[ "leader" ][ "baker_aas72x_idle" ] = %vegas_baker_aas72x_idle;
		
		level.scr_anim[ "wounded_ai" ][ "diaz_aas72x_geton" ] = %vegas_baker_aas72x_geton;
		level.scr_anim[ "wounded_ai" ][ "diaz_aas72x_idle" ] = %vegas_baker_aas72x_idle;
		
		level.scr_anim[ "leader" ][ "diaz_aas72x_geton" ] = %vegas_baker_aas72x_geton;
		
		level.scr_anim[ "ninja" ][ "keegan_aas72x_geton" ] = %vegas_keegan_aas72x_geton;			
		level.scr_anim[ "ninja" ][ "keegan_aas72x_idle" ] = %vegas_keegan_aas72x_idle;			
		level.scr_anim[ "ninja" ][ "keegan_aas72x_fly_idle" ] = %vegas_keegan_aas72x_fly_idle;				
		level.scr_anim[ "ninja" ][ "keegan_aas72x_fly_idle" ] = %vegas_keegan_aas72x_fly_idle;				
	
		level.scr_anim[ "ninja" ][ "keegan_aas72x_fly_look_left" ] = %vegas_keegan_aas72x_fly_look_left;	
		level.scr_anim[ "ninja" ][ "keegan_aas72x_fly_look_right" ] = %vegas_keegan_aas72x_fly_look_right;	
		level.scr_anim[ "ninja" ][ "keegan_aas72x_fly_point" ] = %vegas_keegan_aas72x_fly_point;	
		level.scr_anim[ "ninja" ][ "keegan_aas72x_fly_point2" ] = %vegas_keegan_aas72x_fly_point2;	
		level.scr_anim[ "ninja" ][ "keegan_aas72x_fly_hardturn" ] = %vegas_keegan_aas72x_fly_hardturn;	
		
		level.scr_anim[ "ninja" ][ "keegan_heliride_missile" ] = %vegas_keegan_heliride_missle;	
		level.scr_anim[ "leader" ][ "baker_heliride_missile" ] = %vegas_baker_heliride_missle;	
		
		level.scr_anim[ "leader" ][ "guy2_idle" ] = %aas_72x_guy2_idle;	
		
		
	//	level.scr_anim[ "generic" ][ "fake_get_off" ] = %aas_72x_hopoff_front_l;
	//  // subtle
	// cqb_stand_react_b // aggresive
	// berlin_delta_react_to_falling_debris_2	
	// berlin_delta_react_to_falling_debris_3 // long
	// berlin_delta_react_to_falling_debris_4 // subtle and quick
	// payback_sstorm_guard_shoot_reaction_1 // subtle and quick
	// payback_sstorm_guard_shoot_reaction_2 // subtle and quick
	// payback_sstorm_guard_shoot_reaction_3 // subtle and quick
	
	// cqb_stop_2_signal
}

#using_animtree( "generic_human" );
wounded_ai_anims()
{
	
	// baker
	level.scr_anim[ "leader" ][ "wounded_walk_baker" ] = %vegas_baker_creepWalk_pain;
	level.scr_anim[ "leader" ][ "wounded_run_baker" ] = %vegas_baker_run_pain;
	
	// diaz
	level.scr_anim[ "wounded_ai"] [ "wounded_limp_jog" ] 				= %vegas_baker_limp_jog;
	
	level.scr_anim[ "wounded_ai" ][ "wounded_run_diaz" ] = %vegas_baker_run_pain;
	
	level.scr_anim[ "wounded_ai"] [ "wounded_limp_walk" ][0] 				= %vegas_baker_limp;
	level.scr_anim[ "wounded_ai"] [ "wounded_limp_walk" ][1] 				= %vegas_baker_limp_twitch_1;
	level.scr_anim[ "wounded_ai"] [ "wounded_limp_walk" ][2] 				= %vegas_baker_limp_twitch_2;
	level.scr_anim[ "wounded_ai"] [ "wounded_limp_walk" ][3] 				= %vegas_baker_limp_twitch_3;
	
	weights = [ 4, 1, 1, 1 ];
	level.scr_anim[ "wounded_ai" ][ "wounded_ai_weights_limp" ] = common_scripts\utility::get_cumulative_weights( weights );
	
	// stand
	level.scr_anim[ "wounded_ai"][ "wounded_nocover_idle" ][0] = %vegas_baker_stand_idle;
	level.scr_anim[ "wounded_ai"][ "wounded_nocover_idle_twitch_pain" ] = %vegas_baker_stand_idle_twitch_1;
	level.scr_anim[ "wounded_ai"][ "wounded_nocover_idle_twitch_look" ] = %vegas_baker_stand_idle_twitch_2;
	level.scr_anim[ "wounded_ai"][ "wounded_nocover_arrival" ] = %vegas_baker_limp_to_stand_idle;
	level.scr_anim[ "wounded_ai"][ "wounded_nocover_exit" ] = %vegas_baker_stand_idle_to_limp;
	
	// pillar stand
	level.scr_anim[ "wounded_ai"][ "wounded_stand_idle" ][0] =%vegas_baker_pillar_stand_idle;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_idle_twitch_checkclip" ] =%vegas_baker_pillar_stand_idle_twitch_checkclip;
	addNotetrack_customFunction( "wounded_ai", "attach clip left", ::hide_clip, "wounded_stand_idle_twitch_checkclip" );
	addNotetrack_customFunction( "wounded_ai", "detach clip left", ::show_clip, "wounded_stand_idle_twitch_checkclip" );
	level.scr_anim[ "wounded_ai"][ "wounded_stand_idle_twitch_pain" ] =%vegas_baker_pillar_stand_idle_twitch_pain;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_idle_twitch_lookleft" ] =%vegas_baker_pillar_stand_idle_twitch_lookleft;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_idle_twitch_lookright" ] =%vegas_baker_pillar_stand_idle_twitch_lookright;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_fire_r" ] =%vegas_baker_pillar_fire_r;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_fire_l" ] =%vegas_baker_pillar_fire_l;
	
	level.scr_anim[ "wounded_ai"][ "wounded_stand_fire_1h_l" ] =%vegas_baker_pillar_1h_fire_l;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_fire_1h_r" ] =%vegas_baker_pillar_1h_fire_r;
	
	level.scr_anim[ "wounded_ai"][ "wounded_stand_arrival_l" ] =%vegas_baker_pillar_stand_approach_1;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_arrival_m" ] =%vegas_baker_pillar_stand_approach_2;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_arrival_r" ] =%vegas_baker_pillar_stand_approach_3;
	
	level.scr_anim[ "wounded_ai"][ "wounded_stand_exit_f" ] =%vegas_baker_pillar_exit_f;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_exit_r" ] =%vegas_baker_pillar_exit_r;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_exit_l" ] =%vegas_baker_pillar_exit_l;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_exit_r_90" ] =%vegas_baker_pillar_exit_r_90;
	level.scr_anim[ "wounded_ai"][ "wounded_stand_exit_l_90" ] =%vegas_baker_pillar_exit_l_90;
	
	level.scr_anim[ "wounded_ai"][ "wounded_stand_fire_r_loop" ][0] =%vegas_baker_pillar_fire_r;
	
	// crouch
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_idle" ][0] =%vegas_baker_pillar_sit_idle;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_idle_twitch_checkclip" ] =%vegas_baker_pillar_sit_idle_twitch_checkclip;
	addNotetrack_customFunction( "wounded_ai", "attach clip left", ::hide_clip, "wounded_crouch_idle_twitch_checkclip" );
	addNotetrack_customFunction( "wounded_ai", "detach clip left", ::show_clip, "wounded_crouch_idle_twitch_checkclip" );
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_idle_twitch_lookaround" ] =%vegas_baker_pillar_sit_idle_twitch_lookaround;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_idle_twitch_lookleft" ] =%vegas_baker_pillar_sit_idle_twitch_lookleft;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_idle_twitch_lookright" ] =%vegas_baker_pillar_sit_idle_twitch_lookright;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_idle_twitch_pain" ] =%vegas_baker_pillar_sit_idle_twitch_1;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_idle_twitch_pain" ] =%vegas_baker_pillar_sit_idle_twitch_2;
//	level.scr_anim[ "wounded_ai"][ "wounded_crouch_fire_r" ] =%vegas_baker_pillar_fire_r;
//	level.scr_anim[ "wounded_ai"][ "wounded_crouch_fire_l" ] =%vegas_baker_pillar_fire_l;
//	
//	level.scr_anim[ "wounded_ai"][ "wounded_crouch_fire_1h_l" ] =%vegas_baker_pillar_1h_fire_l;
//	level.scr_anim[ "wounded_ai"][ "wounded_crouch_fire_1h_r" ] =%vegas_baker_pillar_1h_fire_r;
	
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_arrival_l" ] =%vegas_baker_pillar_sit_approach_1;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_arrival_m" ] =%vegas_baker_pillar_sit_approach_2;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_arrival_r" ] =%vegas_baker_pillar_sit_approach_3;
	
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_exit_l" ] =%vegas_baker_pillar_sit_exit_r;
	level.scr_anim[ "wounded_ai"][ "wounded_crouch_exit_r" ] =%vegas_baker_pillar_sit_exit_l;
	
}

#using_animtree( "generic_human" );
creepwalk_anims( aName )
{
	level.scr_anim[ aName ][ "creepwalk" ][0]						= %creepwalk_f;
	level.scr_anim[ aName ][ "creepwalk" ][1]						= %creepwalk_twitch_a_1;
	level.scr_anim[ aName ][ "creepwalk" ][2]						= %creepwalk_twitch_a_2;
	level.scr_anim[ aName ][ "creepwalk" ][3]						= %creepwalk_twitch_a_3;
	level.scr_anim[ aName ][ "creepwalk" ][4]						= %creepwalk_twitch_a_4;
	
	weights = [ 4, 1, 1, 1, 1 ];
	level.scr_anim[ aName ][ "creepwalk_weights" ] = common_scripts\utility::get_cumulative_weights( weights );

	level.scr_anim[ aName ][ "creepwalk_stop" ]						= %creepwalk_2_readystand;
	level.scr_anim[ aName ][ "creepwalk_start" ]						= %readystand_2_creepwalk;	
	level.scr_anim[ aName ][ "creepwalk_2_run" ]						= %creepwalk_2_run;
}

#using_animtree( "script_model" );
model_anims()
{
	level.scr_animtree[ "tag_origin" ] 					 = #animtree;
	level.scr_model[ "tag_origin" ] 						 = "tag_origin";
	level.scr_anim[ "tag_origin" ][ "vegas_diaz_kitchen_stumble" ]				 = %vegas_cart_kitchen_stumble;
	level.scr_anim[ "tag_origin" ][ "casino_kitchen_event_enter" ]				 = %vegas_kitchen_cart_fall;
	
	level.scr_anim[ "rappel_rope_rail" ][ "temp_rappel_over_rail" ]				 = %oilrig_rappelrope_over_rail_R;
	level.scr_animtree[ "rappel_rope_rail" ] 								 = #animtree;
	level.scr_model[ "rappel_rope_rail" ] 									 = "oilrig_rappelrope_50ft";
	
	level.scr_anim[ "vending_machine" ][ "vending_machine_sequence" ] = %london_vending_blocker_vendingmachine;
	level.scr_animtree[ "vending_machine" ] 								 = #animtree;
	level.scr_model[ "vending_machine" ] 									 = "com_vending_can_new3_destroyed";
	
	level.scr_animtree[ "window" ] 					 = #animtree;
	level.scr_model[ "window" ] 						 = "lv_windowshatter";
	level.scr_anim[ "window"] [ "raid_window_shatter" ] 	= %vegas_window_shatter;
	
	level.scr_animtree[ "tarp" ] 					 = #animtree;
	level.scr_anim[ "tarp"] [ "casino_player_slide" ] 	= %vegas_tarp_fall;
	level.scr_anim[ "tarp"] [ "vegas_fall_tarp_idle" ][0] 	= %vegas_tarp_idle;
	level.scr_anim[ "tarp"] [ "vegas_ambient_tarp_idle" ][0] 	= %vegas_drapery_flutter;
	
	level.scr_anim[ "train1" ][ "vegas_train_fall_idle" ][0] 	= %vegas_train_idle;
	level.scr_anim[ "train1" ][ "vegas_train_fall" ] 	= %vegas_train_fall_car1;
	level.scr_anim[ "train2" ][ "vegas_train_fall" ] 	= %vegas_train_fall_car2;
	level.scr_anim[ "track" ][ "vegas_train_fall" ] 	= %vegas_train_fall_track;
	
	level.scr_anim[ "missile1" ] = %vegas_missle1_heliride;
	level.scr_anim[ "missile2" ] ["missle2_heliride"] = %vegas_missle2_heliride;
	level.scr_anim[ "missile3" ] = %vegas_missle3_heliride;
	level.scr_anim[ "missile4" ] = %vegas_missle4_heliride;
	level.scr_anim[ "missile5" ] = %vegas_missle5_heliride;
}

#using_animtree( "animated_props" );
animated_props_anims()
{
	level.scr_anim[ "foliage" ] [ "palmtree_mp_bushy1_sway" ][0] 	= %palmtree_mp_bushy1_sway;
	level.scr_anim[ "foliage" ] [ "vegas_palmtree_straight_windy" ][0] 	= %vegas_palmtree_straight_windy;
	level.scr_anim[ "foliage" ] [ "vegas_palmtree_dead1_windy" ][0] 	= %vegas_palmtree_dead1_windy;
	level.scr_anim[ "foliage" ] [ "vegas_palmtree_dead2_windy" ][0] 	= %vegas_palmtree_dead2_windy;
	level.scr_anim[ "foliage" ] [ "foliage_pacific_tropic_shrub01_sway" ][0] 	= %foliage_pacific_tropic_shrub01_sway;
	level.scr_anim[ "foliage" ] [ "payback_sstorm_palm_bushy_windy_med" ][0] 	= %payback_sstorm_palm_bushy_windy_med;
	level.scr_anim[ "foliage" ] [ "payback_sstorm_dwarf_palm_light" ][0] 	= %payback_sstorm_dwarf_palm_light;
	level.scr_anim[ "foliage" ] [ "foliage_desertbrush_1_sway" ][0] 	= %foliage_desertbrush_1_sway;
	level.scr_anim[ "foliage" ] [ "foliage_pacific_fern02_sway" ][0] 	= %foliage_pacific_fern02_sway;
}

#using_animtree( "player" );
player_anims()
{
	level.scr_animtree[ "player_tag" ] 					 = #animtree;
	level.scr_model[ "player_tag" ] 						 = "tag_origin";
	
	level.scr_animtree[ "player_rig" ] 					 = #animtree;
	level.scr_model[ "player_rig" ] 						 = "viewhands_player_gs_hostage";
	
	level.scr_animtree[ "player_legs" ] 					 = #animtree;
	level.scr_model[ "player_legs" ] 						 = "viewlegs_generic";
	
	level.scr_anim[ "player_rig"] [ "vegas_player_intro_stumble" ] 	= %vegas_player_intro_stumble;
	addNotetrack_notify( "player_rig", "gun_pullout", "intro_stumble_pullout_gun", "vegas_player_intro_stumble" );
	level.scr_anim[ "player_rig"] [ "vegas_player_intro_trip_chair" ] 	= %vegas_player_intro_trip_chair; //gun_pullout
	addNotetrack_notify( "player_rig", "gun_pullout", "chair_trip_pullout_gun", "vegas_player_intro_trip_chair" );
	level.scr_anim[ "player_rig"] [ "player_adrenaline_shot" ] 	= %vegas_player_injection_shot;
	
	level.scr_anim[ "player_rig" ][ "vegas_mantle_under_gate" ]					= %vegas_player_gate_thru;
	
	level.scr_anim[ "player_rig"] [ "casino_player_slide" ] 	= %vegas_player_building_slide;
	addNotetrack_flag( "player_rig", "scn_vegas_slide_catch" , "TRACKFLAG_player_fall_grab", "casino_player_slide" );
	addNotetrack_flag( "player_rig", "keegan_start_fall" , "TRACKFLAG_start_keegan_fall", "casino_player_slide" );
	addNotetrack_customFunction( "player_rig", "slomo_start" , ::slide_slowmo, "casino_player_slide" );
	addNotetrack_flag( "player_rig", "scn_vegas_slide_grabs" ,"TRACKFLAG_slide_stop_dirt_screen", "casino_player_slide" );
	addNotetrack_flag( "player_rig", "slomo_end" , "TRACKFLAG_fall_slomo_end", "casino_player_slide" );
	level.scr_anim[ "player_legs"] [ "casino_player_slide" ] 	= %vegas_player_building_slide_legs;
	
	// slide sounds
	addNotetrack_playersound( "player_rig", "scn_vegas_slide_fronts" ,"casino_player_slide", "scn_vegas_slide_fronts" );
	addNotetrack_playersound( "player_rig", "scn_vegas_slide_catch" ,"casino_player_slide", "scn_vegas_slide_catch" );
	addNotetrack_playersound( "player_rig", "scn_vegas_slide_grabs" ,"casino_player_slide", "scn_vegas_slide_grabs" );
	addNotetrack_playersound( "player_rig", "scn_vegas_slide_hitground" ,"casino_player_slide", "scn_vegas_slide_hitground" );
	
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_out" ] 	= %vegas_player_littlebird_lean_out;
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_in" ] 	= %vegas_player_littlebird_lean_in;	
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_out_b" ] 	= %vegas_player_littlebird_lean_out_b;
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_in_b" ] 	= %vegas_player_littlebird_lean_in_b;

	level.scr_anim[ "player_rig"] [ "vegas_player_raid_jump_tarp_fall" ] 	= %vegas_player_raid_jump_tarp_fall;
	level.scr_anim[ "player_rig"] [ "raid_getup" ] 							= %vegas_player_raid_getup;
	
	level.scr_anim[ "player_rig"] [ "vegas_player_crash_getup" ] 			= %vegas_player_crash_getup;
	level.scr_anim[ "player_rig"] [ "vegas_player_heliride_missle" ] 			= %vegas_player_heliride_missle;
	
	
	addNotetrack_customFunction( "player_rig", "hand_raise", ::entrance_getup_hand_fx, "raid_getup" );
	addNotetrack_customFunction( "player_rig", "hand_grab", ::entrance_getup_hand_grab, "raid_getup" );

	addNotetrack_customFunction( "player_rig", "right_hand_lift", ::fx_right_hand_getup, "raid_getup" );
	addnotetrack_playersound( "player_rig", "scn_vegas_getup_fronts", 	"raid_getup", "scn_vegas_getup_fronts" );
	addnotetrack_playersound( "player_rig", "scn_vegas_getup_armup", 	"raid_getup", "scn_vegas_getup_armup" );
	addnotetrack_playersound( "player_rig", "scn_vegas_getup_armdown", 	"raid_getup", "scn_vegas_getup_armdown" );
	addnotetrack_playersound( "player_rig", "scn_vegas_getup_grab", 	"raid_getup", "scn_vegas_getup_grab" );


}

entrance_getup_hand_fx( guy, is_temp )
{
	// TEMP
	if ( IsDefined( level.entrance_fx_on_hand ) )
		return;

	level.entrance_fx_on_hand = true;

	array = [ "thumb", "index", "mid", "ring", "pinky" ];
	foreach ( substring in array )
	{
		for ( i = 0; i < 3; i++ )
		{
			level thread fx_on_hand_thread( "J_" + substring + "_LE_" + i, "fx_on_hand_" + i );
		}
	}

	array2 = [ "j_sleave_reshape_top_le_1", "j_pinkypalm_le", "j_ringpalm_le", "j_webbing_le", "j_sleave_reshape_bottom_le_1", "j_sleave_reshape_bottom_le_2" ];
	foreach ( tag in array2 )
	{
		level thread fx_on_hand_thread( tag, "fx_on_wrist" );
	}

	thread fx_forearm_thread( "fx_on_wrist", "le" );

	// Should use notetrack on the first one
	flag_set( "fx_on_wrist" );
	flag_set( "fx_on_hand_0" );
	wait( 1 );
	flag_set( "fx_on_hand_1" );
	wait( 1 );
	level notify( "buried_sand_screen_increase" );
	flag_set( "fx_on_hand_2" );

/#
	// TESTING
	if ( GetDvarInt( "test_hand_fx" ) )
		return;
#/

	wait( 0.5 );
	level notify( "stop_hand_sand_stream" );
	wait( 0.5 );
	flag_clear( "fx_on_hand_2" );
	wait( 0.5 );
	flag_clear( "fx_on_hand_1" );
	wait( 0.25 );
	flag_clear( "fx_on_hand_0" );
	flag_clear( "fx_on_wrist" );

	wait( 0.5 );
	level notify( "buried_sand_screen_remove" );
	
//	// Now the right hand when we get pulled up up
//	wait( 2 );
//	level notify( "right_arm_sand" );
	

}

fx_right_hand_getup( guy )
{
	thread fx_forearm_thread( undefined, "ri", 2 );	
}

fx_forearm_thread( endflag, tag_suffix, duration )
{
	timer = undefined;
	if ( IsDefined( duration ) )
		timer = GetTime() + ( duration * 1000 );
		
	if ( IsDefined( endflag ) )
		flag_wait( endflag );

	while ( 1 )
	{
		if ( IsDefined( endflag ) && !flag( endflag ) )
			return;
			
		if ( IsDefined( timer ) && GetTime() > timer )
			return;
	
		wait( RandomFloatRange( 0.1, 0.2 ) );
		
		origin = level.player_rig GetTagOrigin( "j_wrist_" + tag_suffix );
		wrist = level.player_rig GetTagOrigin( "j_wrist_" + tag_suffix );
		elbow = level.player_rig GetTagOrigin( "j_elbow_" + tag_suffix );
	
		forward = VectorToAngles( elbow - wrist );
		right = AnglesToRight( forward + ( 0, 180, 0 ) );
	
		origin = origin + ( right * 2 ) + ( 0, 0, -3 );
		forward = forward + ( 0, 13, 0 );
	
	//	maps\_debug::drawArrow( origin, forward, undefined, 3 );
		forward = AnglesToForward( forward );
		up = AnglesToUp( forward );
		
		PlayFx( getfx( "vfx_sand_forearm" ), origin, forward, up );
	}
}

fx_on_hand_thread( tag, note, forward_tag )
{
	if ( IsDefined( note ) )
	{
		if ( !flag_exist( note ) )
			flag_init( note );
	
		flag_wait( note );
	}

	forward = ( 1, 0, 0 );
	scale = -4;
//	origin = level.player_rig GetTagOrigin( tag );
//	prev_origin = origin + ( 0, 0, scale );

	while ( flag( note ) )
	{
		wait( RandomFloatRange( 0.1, 0.3 ) );

		origin = level.player_rig GetTagOrigin( tag );
//		origin = origin + ( vectornormalize( prev_origin - origin ) * 2 );
//
//		angles = VectorToAngles( prev_origin - origin );
//		forward = AnglesToForward( angles );
//		up = AnglesToUp( angles );

//		if ( IsDefined( forward_tag ) )
//		{
//			forward_tag = 
//		}

//		maps\_debug::drawArrow( origin, ( 0, 0, 0 ), undefined, 3 );
		PlayFx( getfx( "vfx_sand_hand" ), origin, forward );
//		prev_origin = origin + ( 0, 0, scale );
	}
}

entrance_getup_hand_grab( guy )
{
	PlayFx( getfx( "vfx_hand_clap" ), level.player_rig GetTagOrigin( "tag_knife_attach2" ) );
}

#using_animtree( "vehicles" );
vehicle_anims()
{
//	level.scr_anim[ "generic" ][ "jeepride_crash_tunnel_pickup" ]	= %jeepride_crash_tunnel_pickup;
//	level.scr_anim[ "generic" ][ "clockwork_jeep_crash_2" ]	= %clockwork_jeep_crash_2;
//	level.scr_anim[ "generic" ][ "clockwork_jeep_crash_3" ]	= %clockwork_jeep_crash_3;
	
	level.scr_animtree[ "chopper" ] = #animtree;
	level.scr_anim[ "chopper" ][ "vegas_littlebird_take_off" ]	= %vegas_littlebird_take_off;
	level.scr_anim[ "chopper" ][ "vegas_littlebird_crash" ]	= %vegas_littlebird_crash;
	
	level.scr_anim[ "chopper" ][ "vegas_littlebird_shimmy" ]	= %vegas_littlebird_shimmy;
	level.scr_anim[ "chopper" ][ "vegas_littlebird_fishtail" ]	= %vegas_littlebird_fishtail;
	level.scr_anim[ "chopper" ][ "vegas_littlebird_dip" ]	= %vegas_littlebird_dip;
	level.scr_anim[ "chopper" ][ "vegas_littlebird_impact_left" ]	= %vegas_littlebird_impact_left;
	
	level.scr_anim[ "chopper" ][ "vegas_strip_aas_72x_crash" ]	= %vegas_strip_aas_72x_crash;
	level.scr_anim[ "chopper" ][ "vegas_heli_snipe_copter" ]	= %vegas_heli_snipe_copter;
	
	level.scr_anim[ "chopper" ][ "test_littlebird_take_off_tag_origin_fix" ]	= %test_littlebird_take_off_tag_origin_fix;
	
	level.scr_anim[ "chopper" ][ "littlebird_idle" ]	= %vegas_littlebird_idle;
}

/********************
 * NOTETRACK STUFF
********************/

ai_kill( guy )
{
	if ( !isalive( guy ) )
		return;
	if( isdefined( guy.magic_bullet_shield ) && ( guy.magic_bullet_shield == true ) )
		guy stop_magic_bullet_shield();
	guy.allowDeath = true;
	guy.a.nodeath = true;
	guy set_battlechatter( false );
	
	if( isdefined( guy.headshotFX ) )
		playfx( level._effect[ "headshot_blood" ], guy gettagorigin( "j_head" ) + ( 0,0,5 ) );
	
	guy kill();
}

bar_sacrifice_kill( guy )
{
	guy set_battlechatter( false );
	playfx( level._effect[ "headshot_blood" ], guy gettagorigin( "j_head" ) + ( 0,0,5 ) );	
	
	flag_wait( "TRACKFLAG_start_sacrifice_ragdoll" );
	
	guy StartRagdoll();
	
	waitframe();
	
	if( isdefined( guy.magic_bullet_shield ) && ( guy.magic_bullet_shield == true ) )
		guy stop_magic_bullet_shield();
	
	guy.allowDeath = true;
	guy.a.nodeath = true;
	guy set_battlechatter( false );
	
	if( isdefined( guy.headshotFX ) )
		playfx( level._effect[ "headshot_blood" ], guy gettagorigin( "j_head" ) + ( 0,0,5 ) );
	
	guy kill();
}

ai_startragdoll( guy )
{
	
	guy startragdoll();
	
}

ai_dropweapon( guy )
{
	guy gun_remove();
	guy dropweapon( guy.weapon, "right", .05 );
}

rappelers_stop( guy )
{
	guy endon( "death" );
	
	guy stopanimscripted();

	guy notify( "rappel_done" );
}

hallway_roll_flash( guy )
{
	start = guy gettagorigin( "tag_weapon_left" );
	end = getstruct( "hallway_flash_end", "targetname" );
	end.origin = end.origin + ( 0, -50, 0 );
	vector = end.origin - start;
	angles = VectorToAngles( vector );
	forward = AnglesToForward( angles );
	velocity = forward * 2000;
	time = 1.5;
	
	foreach( ai in level.heroes )
		ai setFlashbangImmunity( true );
	
	flash = MagicGrenadeManual( "flash_grenade", start, velocity, time );
	wait( .5 );
	
	level notify( "stealth_event_notify" );
	
	wait( .5 );
	
	// fake flash so it doesn't effect player
	playfx( level._effect[ "grenade_flash" ], flash.origin );
	flashHud = maps\_hud_util::create_client_overlay( "white", .5, level.player );
	flashHud thread maps\_hud_util::fade_over_time( 0, .5 );	
	thread play_sound_in_space( "flashbang_explode_default", flash.origin );
	
	flag_set( "hallway_flashbang_banged" );
	
	waitframe();
	
	// delete real flash so it doesn't go off
	flash delete();
	
	wait(1);
	
	foreach( ai in level.heroes )
		ai setFlashbangImmunity( false );
}

slide_slowmo( guy )
{
    setslowmotion( 1, .25, .05 );
    flag_wait( "TRACKFLAG_fall_slomo_end" );
    setslowmotion( .25, 1, .05 );
}

attach_pistol( dude )
{
	dude attach( "weapon_walther_p99_sp_iw5", "tag_inhand" );		
}

detach_pistol( dude )
{
	dude detach( "weapon_walther_p99_sp_iw5", "tag_inhand" );	
}

hide_clip( dude )
{
	dude endon( "wounded_ai_clip_twitch_complete" );
	
	dude HidePart( "tag_clip" );
	dude Attach( "weapon_ak47_clip", "tag_inhand" );
	
	dude ent_flag_wait( "wounded_ai_twitch_interrupted" );

	dude Detach( "weapon_ak47_clip", "tag_inhand" );
	dude ShowPart( "tag_clip" );
}

show_clip( dude )
{
	if( dude ent_flag( "wounded_ai_twitch_interrupted" ) )
		return;
	
	dude Detach( "weapon_ak47_clip", "tag_inhand" );
	dude ShowPart( "tag_clip" );
	
	dude notify( "wounded_ai_clip_twitch_complete" );
}

radio_to_hand( guy )
{
	assertex( isdefined( guy.radio ), "guy probably isn't ninja" );
	
	guy.radio unlink();
	guy.radio linkto( level.ninja, "tag_inhand", ( 0,0,0 ), ( 0,0,0 ) );	
}

radio_to_hip( guy )
{
	assertex( isdefined( guy.radio ), "guy probably isn't ninja" );
	
	guy.radio unlink();
	guy.radio linkto( level.ninja, "tag_stowed_hip_rear", ( 0,0,0 ), ( 0,0,0 ) );	
}

/********************
 * SANDSTORM SYSTEM
********************/

animated_foliage_system()
{
	triggers = getentarray( "animated_foliage_triggers", "targetname" );
	
	foreach( trig in triggers )
		thread animated_palm_system_trigs( trig );
	
	wait( .05 );
	startPoint = level.start_point;
	if( startPoint != "jumpout" )
	{
		foreach( trig in triggers )
			trig notify( "trigger" );
	}
}

animated_palm_system_trigs( trig )
{
	//trig waittill( "trigger" );
	
	if( isdefined( trig.script_noteworthy ) )
	{
		palms = getentarray( trig.script_noteworthy, "targetname" );
		foreach( tree in palms )
			tree delete();
	}
	
	palms = getentarray( trig.target, "targetname" );
	foreach( palm in palms )
		palm thread animated_palm_system_palms();
	
}

#using_animtree( "animated_props" );
animated_palm_system_palms()
{
	ent = self;
	
	pModel = ent.model;
	pAnimation = ent.animation;
	pAngles = ent.angles;
	pOrigin = ent.origin;
	pTargetname = ent.targetname;
	ent delete();
	
	palm = spawn( "script_model", pOrigin );
	palm setmodel( pModel );
	palm.angles = pAngles;
	palm.animname = "foliage";
	palm.targetname = pTargetname;
	
	palm UseAnimTree( #animtree );
	
	// give some variation in the anim
	wait( randomfloatrange( 0, 3.5 ) );
	
	rate = randomfloatrange( .8, 1.2 );
	if( pAnimation == "palmtree_mp_bushy1_sway" || pAnimation ==  "foliage_pacific_tropic_shrub01_animated" || pAnimation ==  "foliage_desertbrush_1_animated" )
		rate = 5;
	
	//palm thread anim_loop_solo( palm, pAnimation, "stop_anim" );
	palm setAnimRestart( level.scr_anim[palm.animname][pAnimation][0], 1, 1, rate );
}

/********************
 * DIALOG
********************/

#using_animtree( "generic_human" );
dialog()
{

	/*******************
	// GENERIC
	*******************/
	
	level.scr_sound["wounded_ai"][ "vegas_diz_cough" ] = "vegas_diz_cough";
	
	level.scr_sound["wounded_ai"][ "vegas_diz_pain_short" ] = "vegas_diz_pain_short";
	
	/*******************
	// POST INTEROGATION
	*******************/
	
	level.scr_sound["ninja"][ "vegas_kgn_bequick" ] 	= "vegas_kgn_bequick";		// be quick
	
	level.scr_sound["leader"][ "vegas_bkr_halfthebuilding" ] 	= "vegas_bkr_halfthebuilding";		// Enough here to blow half the building
	
	level.scr_sound["ninja"][ "vegas_kgn_diaz" ] 	= "vegas_kgn_diaz";	// diaz
	
	level.scr_sound["leader"][ "vegas_bkr_tonofblood" ] 	= "vegas_bkr_tonofblood";		// lost a ton of blood
	
	level.scr_sound["diaz"][ "vegas_diz_alldead" ] 	= "vegas_diz_alldead";	// leave me all just slow you down
	
	level.scr_sound["leader"][ "vegas_bkr_allgetting" ] 	= "vegas_bkr_allgetting";		// no were all getting out of here lets go	
	
	
	/*******************
	// RESTURANT
	*******************/
	
	// Keegan : Here's some adrenaline. It's not gonna last very long so don't use it until they know we've escaped. 
	level.scr_sound["ninja"][ "vegas_kgn_heressomeadrenalineits" ] = "vegas_kgn_heressomeadrenalineits";
	
	// Baker : What the hell happened?
	level.scr_sound["leader"][ "vegas_bkr_whatthehellhappened" ] = "vegas_bkr_whatthehellhappened";
	
	// Keegan : Our CIA contact must have been compromised. They knew we were coming.
	level.scr_sound["ninja"][ "vegas_kgn_ourciacontactmust" ] = "vegas_kgn_ourciacontactmust";
	
	// Diaz : Who the hell told them? 
	level.scr_sound["wounded_ai"][ "vegas_diz_whothehelltold" ] = "vegas_diz_whothehelltold";
	
	// Keegan : No clue. Let's just focus on getting out of here.
	level.scr_sound["ninja"][ "vegas_kgn_noclueletsjust" ] = "vegas_kgn_noclueletsjust";
	
	// PMC1 : Get these boxes downstairs to the atrium!
	level.scr_radio[ "vegas_pmc1_gettheseboxesdownstairs" ] = "vegas_pmc1_gettheseboxesdownstairs";
	
	// PMC1 : As soon as the sandstorm clears, we're movin out!
	level.scr_radio[ "vegas_pmc1_assoonasthe" ] = "vegas_pmc1_assoonasthe";
	
	// Keegan : Three or more tangos. We'll catch them by surprise.
	level.scr_sound["ninja"][ "vegas_kgn_threeormoretangos" ] = "vegas_kgn_threeormoretangos";
	
	// Keegan : Everyone ready?
	level.scr_sound["ninja"][ "vegas_kgn_everyoneready" ] = "vegas_kgn_everyoneready";
	
	// Diaz : I'm good.
	level.scr_sound["wounded_ai"][ "vegas_diz_imgood" ] = "vegas_diz_imgood";
	
	//	Baker : Do it!
	level.scr_sound["leader"][ "vegas_bkr_doit" ] = "vegas_bkr_doit";
	
	//	PMC2 : Huh?
	level.scr_sound["hostage"][ "vegas_pmc2_huh" ] = "vegas_pmc2_huh";
	
	// Keegan : Room clear. No time to hide the bodies. Let's move!
	level.scr_sound["ninja"][ "vegas_kgn_roomclearnotime" ] = "vegas_kgn_roomclearnotime";
	
	// Union : Diciple Five. Come in!
	level.scr_sound["ninja"][ "vegas_uhq_comein" ] = "vegas_uhq_comein";
	
	// Union : Diciple Five. Union, Come in!
	//level.scr_radio[ "vegas_uhq_unioncomein" ] = "vegas_uhq_unioncomein";
	level.scr_sound["ninja"][ "vegas_uhq_unioncomein" ] = "vegas_uhq_unioncomein";
	
	// Union : Diciple Three. There's no response from Diciple Five.
	level.scr_sound["ninja"][ "vegas_uhq_noresponse" ] = "vegas_uhq_noresponse";
	
	// Diaz : Hear that? Enemy radio. 
	level.scr_sound["wounded_ai"][ "vegas_diz_hearthatenemyradio" ] = "vegas_diz_hearthatenemyradio";
	
	//	Baker : Won't be long until they're onto us. Keegan, grab their coms.
	level.scr_sound["leader"][ "vegas_bkr_wontbelonguntil" ] = "vegas_bkr_wontbelonguntil";
	
	// Diciple Three : Roger that union. Diciple Three enroute. 
	level.scr_sound["ninja"][ "vegas_ds3_enroute" ] = "vegas_ds3_enroute";

	// Keegan : Doors on the left.
	level.scr_sound[ "ninja" ][ "vegas_kgn_kitchennow" ] = "vegas_kgn_kitchennow";
	
	/*******************
	// KITCHEN
	*******************/
	
	// Keegan : Clear!
	level.scr_sound[ "ninja" ][ "vegas_kgn_clear" ] = "vegas_kgn_clear";
	
	// Baker : How'd you get in?
	level.scr_sound["leader"][ "vegas_bkr_howdyougetin" ] = "vegas_bkr_howdyougetin";
	
	// Keegan : Sandstorm was making a real racket out there. Made sneaking past the guards easy. 
	level.scr_sound[ "ninja" ][ "vegas_kgn_sandstormwasmakinga" ] = "vegas_kgn_sandstormwasmakinga";
	
	//	Baker : Come on Diaz. Get up! We gotta get out of here.
	level.scr_sound["leader"][ "vegas_bkr_comeondiazget" ] = "vegas_bkr_comeondiazget";
	
	// PMC : Alpha with me through the kitchen. Bravo, continue clearing this sector.
	level.scr_sound[ "ninja" ][ "vegas_pmc1_alphawithmethrough" ] = "vegas_pmc1_alphawithmethrough";
	
	// Keegan : They're coming this way! Side room! Quick!
	level.scr_sound[ "ninja" ][ "vegas_kgn_patrolcomingthisway" ] = "vegas_kgn_patrolcomingthisway";
	
	// Keegan : Get down!
	level.scr_sound[ "ninja" ][ "vegas_kgn_hitthefloor" ] = "vegas_kgn_hitthefloor";	
	
	// Keegan : Stay down…
	level.scr_sound[ "ninja" ][ "vegas_kgn_staydown" ] = "vegas_kgn_staydown";	
	
	// Keegan : Easy…
	level.scr_sound[ "ninja" ][ "vegas_kgn_easy_2" ] = "vegas_kgn_easy_2";	
	
	//	Baker : Alright they're gone. Let's go.
	level.scr_sound["leader"][ "vegas_bkr_patrolpassedmoveout" ] = "vegas_bkr_patrolpassedmoveout";
	
	/*******************
	// HALLWLAY
	*******************/
	
	// Keegan : They're all over this sector. 
	level.scr_sound[ "ninja" ][ "vegas_kgn_theyrealloverthis" ] = "vegas_kgn_theyrealloverthis";
	
	//	PMC : Union! Diciple Five is dead! The prisoners have escaped!
	level.scr_sound["ninja"][ "vegas_pmc1_uniondiciplefiveis" ] = "vegas_pmc1_uniondiciplefiveis";	
	
	//	Baker : That's the cue. Use your adrenaline. There's no turning back now.
	level.scr_sound["leader"][ "vegas_bkr_thatsthecueuse" ] = "vegas_bkr_thatsthecueuse";	
	
	//	Union : All units, this is Union. Move and clear sector 4C Charlie. The prisoners have escaped. Shoot on sight.
	level.scr_sound["ninja"][ "vegas_uhq_allunitsthisis" ] = "vegas_uhq_allunitsthisis";	
	
	/*******************
	// GAMBLING ROOM
	*******************/
	
	/*******************
	// TRANSITION ROOM
	*******************/
	
	level.scr_sound["leader"][ "vegas_uhq_staticallelementsin" ] = "vegas_uhq_staticallelementsin";
	
	/*******************
	// RAID ROOM
	*******************/
	
	// Baker: They're trying to cut us off!
	level.scr_sound["leader"][ "vegas_bkr_theyretryingtocut" ] = "vegas_bkr_theyretryingtocut";
	
	// Keegan : In here!
	level.scr_sound["ninja"][ "vegas_kgn_inhere" ] = "vegas_kgn_inhere";
	
	// Keegan : Inside let's go.
	level.scr_sound["ninja"][ "vegas_kgn_insideletsgo" ] = "vegas_kgn_insideletsgo";
	
	// Keegan : Common Rook!
	level.scr_sound["ninja"][ "vegas_kgn_comeonrook" ] = "vegas_kgn_comeonrook";
	
	// Keegan : Get inside!
	level.scr_sound["ninja"][ "vegas_kgn_getinside_2" ] = "vegas_kgn_getinside_2";
	
	// Diaz: I'm in!
	level.scr_sound["wounded_ai"][ "vegas_diz_imin" ] = "vegas_diz_imin";
	
	// Diaz: I'm comin', I'm comin'
	level.scr_sound["wounded_ai"][ "vegas_diz_imcmonimcmon" ] = "vegas_diz_imcmonimcmon";
	
	// Baker: Everyone's in! Close it!
	level.scr_sound["ninja"][ "vegas_bkr_everyonesincloseit" ] = "vegas_bkr_everyonesincloseit";
	
	// Baker: Quick shut the door!
	level.scr_sound["leader"][ "vegas_bkr_quickshutthedoor" ] = "vegas_bkr_quickshutthedoor";
	
	// Keegan: Closing!
	level.scr_sound["ninja"][ "vegas_kgn_closing" ] = "vegas_kgn_closing";
	
	// Keegan : We need time! Barricade the door!
	level.scr_sound["ninja"][ "vegas_kgn_weneedtimebarricade" ] = "vegas_kgn_weneedtimebarricade";
	
	// Baker: Come on! Come on!
	level.scr_sound["leader"][ "vegas_bkr_comeoncomeon" ] = "vegas_bkr_comeoncomeon";
	
	// Baker: What's the plan? We are not going to be able to last in here!
	level.scr_sound["leader"][ "vegas_bkr_whatstheplanwere" ] = "vegas_bkr_whatstheplanwere";
	
	// Baker: Keegan!?!
	level.scr_sound["leader"][ "vegas_bkr_keegan_3" ] = "vegas_bkr_keeegaan"; // vegas_bkr_keegan_3 // vegas_bkr_keeegaan // vegas_bkr_keegan_2
	
	// Baker: Alright, fight from here?
	level.scr_sound["leader"][ "vegas_bkr_allrightfightfrom" ] = "vegas_bkr_allrightfightfrom";
	
	// Keegan: No time, move move!
	level.scr_sound["ninja"][ "vegas_kgn_notimemovemove" ] = "vegas_kgn_notimemovemove";
	
	// Keegan: Windows, go!
	level.scr_sound["ninja"][ "vegas_kgn_windowsgo" ] = "vegas_kgn_windowsgo";
	
	// Keegan : There's only one way out of here.
	level.scr_sound["ninja"][ "vegas_kgn_wegottagetout" ] = "vegas_kgn_wegottagetout";
	
	// Diaz: Are you kidding me?!
	level.scr_sound["wounded_ai"][ "vegas_diz_areyoukiddingme" ] = "vegas_diz_areyoukiddingme";
	
	// Diaz: Are you kidding me?!?
	level.scr_sound["leader"][ "vegas_diz_areyoukiddingme_2" ] = "vegas_diz_areyoukiddingme_2";
	
	// Keegan : We gotta jump! Hold them off!
	level.scr_sound["ninja"][ "vegas_kgn_wegottajumpits" ] = "vegas_kgn_wegottajumpits";
	
	// Baker: Diaz, Rook! You're up! I'll be right behind you!
	level.scr_sound["leader"][ "vegas_bkr_diazrookyoureup" ] = "vegas_bkr_diazrookyoureup";
	
	// Diaz: Moving!
	level.scr_sound["wounded_ai"][ "vegas_diz_letsgo" ] = "vegas_diz_letsgo";
	
	// Baker: Rook! JUMP!
	level.scr_sound["leader"][ "vegas_bkr_rookjump" ] = "vegas_bkr_rookjump";
	
	// Baker: Move it! We can't hold them off forever!
	level.scr_sound["leader"][ "vegas_bkr_moveitwecant" ] = "vegas_bkr_moveitwecant";
	
	// Baker: Move! NOW!
	level.scr_sound["leader"][ "vegas_bkr_movenow" ] = "vegas_bkr_movenow";
	
	// Baker: Breach! Go!
	level.scr_sound["leader"][ "vegas_bkr_breachgo" ] = "vegas_bkr_breachgo";
	
	// PMC 1: THEY WENT IN HERE!
	level.scr_sound["pmc"][ "vegas_pmc1_theywentinhere" ] = "vegas_pmc1_theywentinhere";
	
	// PMC 2: GET IT OPEN!
	level.scr_sound["pmc"][ "vegas_pmc2_getitopen" ] = "vegas_pmc2_getitopen";
	
	// PMC 1: PMC 1: THEY'VE BARRICADED THEMSELVES IN!
	level.scr_sound["pmc"][ "vegas_pmc1_theyvebarricadedin" ] = "vegas_pmc1_theyvebarricadedin";
	
	// PMC 2: GET A CHARGE ON THERE!
	level.scr_sound["pmc"][ "vegas_pmc2_getachargeon" ] = "vegas_pmc2_getachargeon";
	
	// PMC 1: BREACHING! BREACHING!
	level.scr_sound["pmc"][ "vegas_pmc1_breachingbreaching" ] = "vegas_pmc1_breachingbreaching";
	
	/*******************
	// 
	*******************/
	
	level.scr_sound["ninja"][ "vegas_ds3_justoutside" ] = "vegas_ds3_justoutside";

	level.scr_sound["ninja"][ "vegas_kgn_tothesuite" ] 	= "vegas_kgn_tothesuite";	// to the suite
	
	level.scr_sound["leader"][ "vegas_bkr_behindya" ] 	= "vegas_bkr_behindya";		// Right behind ya
	
	// Diaz : cough, choke, cough, cough 
	level.scr_sound["wounded_ai"][ "vegas_diz_coughs" ] 	= "vegas_diz_coughs";
	
	
	// going down the stairs
	level.scr_sound["ninja"][ "vegas_kgn_helpdiaz" ] 	= "vegas_kgn_helpdiaz";	//help diaz
	
	level.scr_sound["leader"][ "vegas_bkr_doubletime" ] 	= "vegas_bkr_doubletime";		// Double time
	
	level.scr_radio[ "vegas_uhq_alotofactivity" ] 		= "vegas_uhq_alotofactivity";// we've got a lot of activity in the main lobby

		// Alpha 1
	level.scr_radio[ "vegas_bt4_3elements" ] 		= "vegas_bt4_3elements"; // union this is black trot we have elements moving in now.
	
	level.scr_radio[ "vegas_uhq_rogerthatbt4" ] 		= "vegas_uhq_rogerthatbt4";// roger that blacktrot four
	
	

	// stumble / fall down
	level.scr_sound["ninja"][ "vegas_kgn_pickhimup" ] 	= "vegas_kgn_pickhimup";	//pick em up
	
	level.scr_sound["leader"][ "vegas_bkr_diazgo" ] 	= "vegas_bkr_diazgo";		// Diaz go
	
	
	// enemies while talking about being in the escalator room
	level.scr_radio[ "vegas_bt1_wontknow" ] 		= "vegas_bt1_wontknow"; // wait and they wont know what hit em
	
	level.scr_radio[ "vegas_uhq_routingsupport" ] 		= "vegas_uhq_routingsupport";// roger that, routing support to you now
	
	
	
	// into the hallways
	level.scr_sound["ninja"][ "vegas_kgn_thisway" ] 	= "vegas_kgn_thisway";	// this way
	
	level.scr_sound["leader"][ "vegas_bkr_dontstop" ] 	= "vegas_bkr_dontstop";		// Diaz stop
	
	// the jump
	level.scr_sound["leader"][ "vegas_bkr_jump" ] 	= "vegas_bkr_jump";		// Jump
	
	
	// getting up after the fall
	
	
	// missing ninja line "You're" gonna be alright "
	
	level.scr_sound["wounded_ai"][ "vegas_diz_loseem" ] 	= "vegas_diz_loseem";	// did we lose em
	
	level.scr_sound["leader"][ "vegas_bkr_trucksgetdown" ] 	= "vegas_bkr_trucksgetdown";		// JTrucks
	
	
	// pmc moving guys into position
	// when or around getting up
	level.scr_radio[ "vegas_uhq_sector3c" ] 		= "vegas_uhq_sector3c";// zeta seven this is union, there are headed to sector 3c
		
	level.scr_radio[ "vegas_zt7_deploying" ] 		= "vegas_zt7_deploying"; // rogr that union deploying all elements now.
	
	level.scr_sound["wounded_ai"][ "vegas_diz_coughs" ] 	= "vegas_diz_coughs";	// cough
	
	// guys looking for you on foor
	level.scr_radio[ "vegas_zt1_sweepleft" ] 		= "vegas_zt1_sweepleft"; // zeta element sweep left and right
	
	level.scr_radio[ "vegas_zt1_searchpattern" ] 		= "vegas_zt1_searchpattern"; //search pattern echo charlie go
	
	
	// waiting for the guys to pass by
	level.scr_sound["ninja"][ "vegas_kgn_easy" ] 	= "vegas_kgn_easy";	// easy
	
	level.scr_sound["ninja"][ "vegas_kgn_waitwait" ] 	= "vegas_kgn_waitwait";	// wait
	
	level.scr_sound["ninja"][ "vegas_kgn_now" ] 	= "vegas_kgn_now";	// now
	
	
	// combat kicks off
	level.scr_sound["ninja"][ "vegas_kgn_comingback" ] 	= "vegas_kgn_comingback";	// there coming back
	
	level.scr_sound["ninja"][ "vegas_kgn_thewindow" ] 	= "vegas_kgn_thewindow";	// at the windows
	
	
	// when you get to the train
	level.scr_sound["wounded_ai"][ "vegas_diz_theyreeverywhere" ] 	= "vegas_diz_theyreeverywhere";	// there everywhere
	
	
	// call this when the last troops retreat and the helicopter comes into play
	level.scr_radio[ "vegas_zt7_immediatebackup" ] 		= "vegas_zt7_immediatebackup"; // union were taking heavy casualities, request immediate back up
	
	
	
	
	// running across the strip
	level.scr_sound["ninja"][ "vegas_kgn_acrossthestrip" ] 	= "vegas_kgn_acrossthestrip";	// across the strip
	
	level.scr_sound["ninja"][ "vegas_kgn_dontstop" ] 	= "vegas_kgn_dontstop";	// Dont stop
	
	level.scr_sound["ninja"][ "vegas_kgn_movemove" ] 	= "vegas_kgn_movemove";	// move move
	
	level.scr_sound["wounded_ai"][ "vegas_diz_coughs" ] 	= "vegas_diz_coughs";	// cough	
	
	
	level.scr_sound["wounded_ai"][ "vegas_diz_muchfurther" ] 	= "vegas_diz_muchfurther";	// cough how much further	
	
	level.scr_sound["leader"][ "vegas_bkr_more" ] 	= "vegas_bkr_more";		// Were almost there d	
	
	level.scr_sound["leader"][ "vegas_bkr_almostthered" ] 	= "vegas_bkr_almostthered";	// Comon diaz
	
	level.scr_sound[ "leader" ][ "vegas_bkr_moveitdiaz" ] 	= "vegas_bkr_moveitdiaz";	// Move it diaz
	
	level.scr_sound["leader"][ "vegas_bkr_anyeasier" ] 	= "vegas_bkr_anyeasier";		// this isn't getting any easier
	
	level.scr_sound["leader"][ "vegas_bkr_stayclose" ] 	= "vegas_bkr_stayclose";		// stay close
	


	// hiding
	
	level.scr_sound["ninja"][ "vegas_kgn_anarmada" ] 	= "vegas_kgn_anarmada";	// crap there's an amarada
	
	level.scr_sound["leader"][ "vegas_bkr_getdown" ] 	= "vegas_bkr_getdown";	// Shit get down
	
	level.scr_sound["wounded_ai"][ "vegas_diz_onfoot" ] 	= "vegas_diz_onfoot";	// were not getting out here on foot, are we
	
	level.scr_sound["ninja"][ "vegas_kgn_notexactly1" ] 	= "vegas_kgn_notexactly1";	// not exactly
	
	level.scr_sound["ninja"][ "vegas_kgn_cmonletsgo" ] 	= "vegas_kgn_cmonletsgo";	// cmon lets go
	level.scr_sound["leader"][ "vegas_bkr_rightbehind" ] 	= "vegas_bkr_rightbehind";	// Right behind ya

	
	// getting into the chopper
	level.scr_sound["leader"][ "vegas_bkr_everfly" ] 	= "vegas_bkr_everfly";	// you've flown one of these before	
	
	level.scr_sound["ninja"][ "vegas_kgn_notexactly2" ] 	= "vegas_kgn_notexactly2";	// not exactly	
	
	level.scr_sound["leader"][ "vegas_bkr_helpme" ] 	= "vegas_bkr_helpme";	// help with diaz

	level.scr_sound["wounded_ai"][ "vegas_diz_justgo" ] 	= "vegas_diz_justgo";	// I'm in I'm good lets just go
	
	

	

	// flying	
	level.scr_sound["leader"][ "vegas_bkr_needtomove" ] 	= "vegas_bkr_needtomove";	// we need to move
	
	level.scr_sound["leader"][ "vegas_bkr_turningaround" ] 	= "vegas_bkr_turningaround";	// There turning around
	
	level.scr_sound["leader"][ "vegas_bkr_losinghim" ] 	= "vegas_bkr_losinghim";	//Were losing him
	
	level.scr_sound["leader"][ "vegas_bkr_staywith" ] 	= "vegas_bkr_staywith";	//stay with us
	
	level.scr_sound["leader"][ "vegas_bkr_gorightgoright" ] 	= "vegas_bkr_gorightgoright";	// going to the right 
	
	level.scr_sound["leader"][ "vegas_bkr_gotcompany" ] 	= "vegas_bkr_gotcompany";	// we got the company
	
	level.scr_sound["leader"][ "vegas_bkr_trucks" ] 	= "vegas_bkr_trucks";	// trucks
	
	level.scr_sound["leader"][ "vegas_bkr_infront" ] 	= "vegas_bkr_infront";	// in front of us
	
	level.scr_sound["leader"][ "vegas_bkr_turnaround" ] 	= "vegas_bkr_turnaround";	// turn around
	
	level.scr_sound["leader"][ "vegas_bkr_thruthealley" ] 	= "vegas_bkr_thruthealley";	// more of them through the alley
	
	level.scr_sound["leader"][ "vegas_bkr_roadblock" ] 	= "vegas_bkr_roadblock";	// road block up ahead if they see were dead
	
	level.scr_sound["leader"][ "vegas_bkr_thecanal" ] 	= "vegas_bkr_thecanal";	// use the canal
	
	level.scr_sound["leader"][ "vegas_bkr_hearem" ] 	= "vegas_bkr_hearem";	// I hear em but I can't see em
	
	level.scr_sound["leader"][ "vegas_bkr_hearem" ] 	= "vegas_bkr_hearem";	// I hear em but I can't see em
	
	// flying
	level.scr_sound["ninja"][ "vegas_kgn_holdon" ] 	= "vegas_kgn_holdon";	// hold on
	
	level.scr_sound["ninja"][ "vegas_kgn_totheright" ] 	= "vegas_kgn_totheright";	// to the right
	
	level.scr_sound["ninja"][ "vegas_kgn_trucksoffus" ] 	= "vegas_kgn_trucksoffus";	// Get those trucks off of us
	
	level.scr_sound["ninja"][ "vegas_kgn_onit" ] 	= "vegas_kgn_onit";	// On it
	
	level.scr_sound["ninja"][ "vegas_kgn_holdon2" ] 	= "vegas_kgn_holdon2";	// Hold on 2
	
	level.scr_sound["ninja"][ "vegas_kgn_lookout" ] 	= "vegas_kgn_lookout";	// Look out
	
	level.scr_sound["ninja"][ "vegas_kgn_outofthecity" ] 	= "vegas_kgn_outofthecity";	// Get us out of the city
	
	level.scr_sound[ "ninja" ][ "vegas_kgn_cuttingthrough" ] 	= "vegas_kgn_cuttingthrough";	// Were cutting through here
	
	level.scr_sound[ "ninja" ][ "vegas_kgn_barelysee" ] 	= "vegas_kgn_barelysee";	// I can barely see
	
	level.scr_sound[ "leader" ][ "qstep_run_glass" ] 	= "qstep_run_glass";	// I can barely see
	
	
	
	// Union
	
	level.scr_radio[ "vegas_uhq_acknowledged" ] 		= "vegas_uhq_acknowledged";// achknowledged stand by
	
	level.scr_radio[ "vegas_uhq_sector1c" ] 		= "vegas_uhq_sector1c";// alpha one this union, possible elements eliminated
	
	
	// Bloackade
	level.scr_radio[ "vegas_zt6_antiair" ] 		= "vegas_zt6_antiair"; // anti air in position waiting for the target
	
	level.scr_radio[ "vegas_uhq_roadblocksecured" ] 		= "vegas_uhq_roadblocksecured";// alpha elements this is union road block is secure
	
			
}

sounds()
{
	level.scr_sound[ "vehicle_skid_dirt" ] 		 = "wood_door_kick";	
	level.scr_sound[ "vehicle_skid_cement" ] 	 = "veh_car_skid_cement";
	level.scr_sound[ "heli_overhead_flyby" ] 	 = "heli_overhead_flyby";
	
	
	level.scr_sound[ "shepherd" ][ "roadkill_shp_ontheline2" ] = "wood_door_kick";	
	level.scr_sound[ "shepherd" ][ "roadkill_shp_ontheline" ] = "null";
}


//uaz_overrides()
//{
//	positions = 	vehicle_scripts\_uaz::setanims();
//
//	positions[ 0 ].sittag = "tag_driver";
//	positions[ 1 ].sittag = "tag_passenger";
//	positions[ 2 ].sittag = "tag_guy0";// RR
//	positions[ 3 ].sittag = "tag_guy1";// RR
//	positions[ 4 ].sittag = "tag_guy2";// RR
//	positions[ 5 ].sittag = "tag_guy3";// RR
//
//	positions[ 0 ].idle = %UAZ_driver_idle;
////	positions[ 1 ].idle = %UAZ_Rguy_idle;
//
//	positions[ 0 ].getout = %uaz_driver_exit_into_stand;
//	positions[ 2 ].getout = %uaz_driver_exit_into_run;
////	positions[ 3 ].getout = %uaz_passenger_exit_into_run;
//
//	positions[ 0 ].getin = %uaz_driver_enter_from_huntedrun;
//
//	positions[ 2 ].idle = [];
//	positions[ 2 ].idle[ 0 ] = %UAZ_Lguy_idle_hide;
//	positions[ 2 ].idle[ 1 ] = %UAZ_Lguy_idle_react;
//	positions[ 2 ].idleoccurrence[ 0 ] = 1000;
//	positions[ 2 ].idleoccurrence[ 1 ] = 100;
//
////	positions[ 3 ].idle = %UAZ_Rguy_idle;
////	positions[ 4 ].idle = undefined;
////	positions[ 5 ].idle = undefined;
//
//	positions[ 2 ].hidetoback = %UAZ_Lguy_trans_hide2back;
//	positions[ 2 ].back_attack = %UAZ_Lguy_fire_back;
//	positions[ 2 ].backtohide = %UAZ_Lguy_trans_back2hide;
//
//	positions[ 2 ].hide_attack_forward = %UAZ_Lguy_fire_hide_forward;
//
//	positions[ 2 ].hide_attack_left[ 0 ] = %UAZ_Lguy_fire_side_v1;
//	positions[ 2 ].hide_attack_left[ 1 ] = %UAZ_Lguy_fire_side_v2;
//	positions[ 2 ].hide_attack_left_occurrence[ 0 ] = 500;
//	positions[ 2 ].hide_attack_left_occurrence[ 1 ] = 500;
//
//	positions[ 2 ].hide_attack_left_standing[ 0 ] = %UAZ_Lguy_standfire_side_v3;
//	positions[ 2 ].hide_attack_left_standing[ 1 ] = %UAZ_Lguy_standfire_side_v4;
//	positions[ 2 ].hide_attack_left_standing_occurrence[ 0 ] = 100;
//	positions[ 2 ].hide_attack_left_standing_occurrence[ 1 ] = 100;
//
//	positions[ 2 ].hide_attack_back[ 0 ] = %UAZ_Lguy_fire_hide_back_v1;
//	positions[ 2 ].hide_attack_back[ 1 ] = %UAZ_Lguy_fire_hide_back_v2;
//	positions[ 2 ].hide_attack_back_occurrence[ 0 ] = 500;
//	positions[ 2 ].hide_attack_back_occurrence[ 1 ] = 500;
//	positions[ 2 ].react = %UAZ_Lguy_idle_react;
//
////	positions[ 1 ].hide_attack_back[ 0 ] = %UAZ_Rguy_fire_back_v2;
////	positions[ 1 ].hide_attack_back[ 1 ] = %UAZ_Rguy_fire_back_v1;
////	positions[ 1 ].hide_attack_back_occurrence[ 0 ] = 500;
////	positions[ 1 ].hide_attack_back_occurrence[ 1 ] = 500;
//
////	positions[ 1 ].hide_attack_left[ 0 ] = %UAZ_Lguy_fire_side_v1;
////	positions[ 1 ].hide_attack_left[ 1 ] = %UAZ_Lguy_fire_side_v2;
////	positions[ 1 ].hide_attack_left_occurrence[ 0 ] = 500;
////	positions[ 1 ].hide_attack_left_occurrence[ 1 ] = 500;
//
//	positions[ 0 ].duck_once = %UAZ_driver_duck;
//	positions[ 0 ].turn_right = %UAZ_driver_turnright;
//	positions[ 0 ].turn_left = %UAZ_driver_turnleft;
//	positions[ 0 ].weave = %UAZ_driver_weave;
//
//	return positions;
//}

//#using_animtree( "vehicles" );
//uaz_override_vehicle( positions )
//{
//		positions = vehicle_scripts\_uaz::set_vehicle_anims( positions );
//
//		positions[ 0 ].vehicle_idle = %UAZ_steeringwheel_idle;
//		positions[ 0 ].vehicle_duck_once = %UAZ_steeringwheel_duck;
//		positions[ 0 ].vehicle_turn_left = %UAZ_steeringwheel_turnleft;
//		positions[ 0 ].vehicle_turn_right = %UAZ_steeringwheel_turnright;
//		positions[ 0 ].vehicle_weave = %UAZ_steeringwheel_weave;
//		positions[ 2 ].vehicle_getoutanim = %uaz_rear_driver_exit_into_run_door;
//		positions[ 3 ].vehicle_getoutanim = %uaz_passenger2_exit_into_run_door;
//
//		return positions;
//}


