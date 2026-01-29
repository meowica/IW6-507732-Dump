#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;
                                                    
main()
{
//	maps\_hand_signals::initHandSignals();
	
	generic_human();
	player();
	script_models();
	animated_props();
	vehicles();
	
	squad_vo();
}

#using_animtree( "generic_human" );
generic_human()
{
	level.scr_anim[ "generic" ][ "zodiac_ascend" ] = %blackice_ally5_rigascend;
	
	//--Intro--
	//deck run	
	//level.scr_anim[ "keegan" ][ "carry_idle" ][ 0 ]					= %ch_pragueb_3_1_idle_soap;
	//level.scr_anim[ "keegan" ][ "carry_run"	 ][ 0 ]					= %ch_pragueb_3_1_run_soap;
	//level.scr_anim[ "generic" ][ "wounded_carry_fastwalk_carrier" ] = %wounded_carry_fastwalk_carrier;
	//level.scr_anim[ "generic" ][ "patrol_jog_orders"			  ] = %patrol_jog_orders;
	
	//level.scr_anim[ "dad" ][ "london_guard_idle1" ][ 0 ] = %london_guard_idle1;
	
	//level.scr_anim[ "dad"	  ] [ "carrier_ghost_intro_deck_dad"   ] = %carrier_ghost_intro_deck_dad;
	//--Intro Deck--
	level.scr_anim[ "hesh" ] [ "carrier_ghost_intro_deck_ally1" ] = %carrier_ghost_intro_deck_ally1;
	level.scr_anim[ "generic" ] [ "carrier_ghost_intro_deck_ally2" ] = %carrier_ghost_intro_deck_ally2;
	level.scr_anim[ "generic" ] [ "carrier_ghost_intro_deck_ally3" ] = %carrier_ghost_intro_deck_ally3;
	level.scr_anim[ "generic" ] [ "carrier_ghost_intro_deck_ally4" ] = %carrier_ghost_intro_deck_ally4;

	//--Medbay--
	level.scr_anim[ "generic" ] [ "carrier_ghost_intro_medbay_ally1"   ]  = %carrier_ghost_intro_medbay_ally1;
	level.scr_anim[ "hesh"	  ] [ "carrier_ghost_intro_medbay_dad"	   ]  = %carrier_ghost_intro_medbay_dad;
	level.scr_anim[ "merrick" ] [ "carrier_ghost_intro_medbay_merrick" ]  = %carrier_ghost_intro_medbay_merrick;
	level.scr_anim[ "hesh" ] [ "wounded_carry_closet_idle_wounded" ][ 0 ] = %wounded_carry_closet_idle_wounded;

	level.scr_anim[ "generic" ][ "cpr_wounded_endidle"	 ][ 0 ]		= %dc_burning_cpr_wounded_endidle;
	level.scr_anim[ "generic" ][ "cpr_wounded"			 ]			= %dc_burning_cpr_wounded;
	level.scr_anim[ "generic" ][ "cpr_medic_endidle"		 ][ 0 ] = %dc_burning_cpr_medic_endidle;
	level.scr_anim[ "generic" ][ "cpr_medic"				 ]		= %dc_burning_cpr_medic;
	
	//--Campfire--
	level.scr_anim[ "dad"	 ] [ "sitting_guard_loadAK_idle" ][ 0 ] = %sitting_guard_loadAK_idle;
	
	//--Medbay Hall--
	level.scr_anim[ "generic" ][ "clock_jog" ]			 	  		   = %clockwork_walkout_allies_jog_1;
	level.scr_anim[ "hesh" ] [ "carrier_medbay_letsgo_hesh_enter" ]		 = %carrier_medbay_letsgo_hesh_enter;
	level.scr_anim[ "hesh" ] [ "carrier_medbay_letsgo_hesh_exit"  ]		 = %carrier_medbay_letsgo_hesh_exit;
	level.scr_anim[ "hesh" ] [ "carrier_medbay_letsgo_hesh_loop" ] [ 0 ] = %carrier_medbay_letsgo_hesh_loop;
	
	level.scr_anim[ "rs1" ] [ "carrier_hallway_talk_loop" ] [ 0 ]	= %carrier_hallway_talk_redshirt1_loop;
	level.scr_anim[ "rs2" ] [ "carrier_hallway_talk_loop" ] [ 0 ]	= %carrier_hallway_talk_redshirt2_loop;
	level.scr_anim[ "rs1" ] [ "carrier_hallway_salute_enter" ]		= %carrier_hallway_salute_redshirt1_enter;
	level.scr_anim[ "rs2" ] [ "carrier_hallway_salute_enter" ]		= %carrier_hallway_salute_redshirt2_enter;
	level.scr_anim[ "rs1" ] [ "carrier_hallway_salute_loop" ] [ 0 ] = %carrier_hallway_salute_redshirt1_loop;
	level.scr_anim[ "rs2" ] [ "carrier_hallway_salute_loop" ] [ 0 ] = %carrier_hallway_salute_redshirt2_loop;
	level.scr_anim[ "rs1" ] [ "carrier_hallway_salute_exit" ]		= %carrier_hallway_salute_redshirt1_exit;
	level.scr_anim[ "rs2" ] [ "carrier_hallway_salute_exit" ]		= %carrier_hallway_salute_redshirt2_exit;
	
	
	//deck combat - carrier life 
	level.scr_anim[ "director" ] [ "tugger_scene_enter" ]		  = %carrier_elevator_scene_director_enter;
	level.scr_anim[ "director" ] [ "tugger_scene_exit"	]		  = %carrier_elevator_scene_director_exit;
	level.scr_anim[ "director" ][ "tugger_scene_loop"	 ]	[ 0 ] = %carrier_elevator_scene_director_loop;
	
	level.scr_anim[ "inspector1" ] [ "tugger_scene_enter" ]		  = %carrier_elevator_scene_inspector1_enter;
	level.scr_anim[ "inspector1" ] [ "tugger_scene_exit"  ]		  = %carrier_elevator_scene_inspector1_exit;
	level.scr_anim[ "inspector1" ][ "tugger_scene_loop"	 ]	[ 0 ] = %carrier_elevator_scene_inspector1_loop;
	
	level.scr_anim[ "inspector2" ] [ "tugger_scene_enter" ]		  = %carrier_elevator_scene_inspector2_enter;
	level.scr_anim[ "inspector2" ] [ "tugger_scene_exit"  ]		  = %carrier_elevator_scene_inspector2_exit;
	level.scr_anim[ "inspector2" ][ "tugger_scene_loop"	 ]	[ 0 ] = %carrier_elevator_scene_inspector2_loop;
	
	level.scr_anim[ "pilot" ] [ "tugger_scene_enter" ]		  = %carrier_elevator_scene_pilot_enter;
	level.scr_anim[ "pilot" ] [ "tugger_scene_exit"	 ]		  = %carrier_elevator_scene_pilot_exit;
	level.scr_anim[ "pilot" ][ "tugger_scene_loop"	 ]	[ 0 ] = %carrier_elevator_scene_pilot_loop;
	
	
	
	//deck combat 1
//	level.scr_anim[ "generic" ][ "dead_reshirt"	 ]		  = %exposed_death_firing;
	level.scr_anim[ "generic" ] [ "jog_1" ] [ 0 ]		  = %london_police_jog;
	level.scr_anim[ "generic" ] [ "jog_2" ] [ 0 ]		  = %training_jog_guy1;
	level.scr_anim[ "generic" ] [ "plane_wave_on"	   ]  = %flood_convoy_checkpoint_opfor04;
	level.scr_anim[ "hesh"	  ] [ "plane_wave_on"	   ]  = %flood_convoy_checkpoint_opfor04;
	level.scr_anim[ "generic" ] [ "repair2"			   ]  = %training_humvee_repair;
	level.scr_anim[ "generic" ] [ "repair1"			   ]  = %hijack_intro_worker_checklist_loop;
	level.scr_anim[ "generic" ] [ "repair3"			   ]  = %london_inspector_check01;
	level.scr_anim[ "generic" ] [ "waveguy1"		   ]  = %payback_sstorm_guard_wave_2;
	level.scr_anim[ "generic" ] [ "waveguy2"		   ]  = %paris_ac130_pinned_sandman_wave;
	level.scr_anim[ "generic" ] [ "stop that forklift" ]  = %london_police_wave_2;
	level.scr_anim[ "generic" ] [ "deck_run_wave1"	   ]  = %paris_sabre_wave_kitchen;
	level.scr_anim[ "generic" ] [ "stand_fire"		   ]  = %exposed_aim_5;
	level.scr_anim[ "generic" ][ "javelin_idle_a" ] [ 0 ] = %javelin_idle_a;
	level.scr_anim[ "generic" ] [ "javelin_fire_a"	  ]	  = %javelin_fire_a;
	level.scr_anim[ "generic" ] [ "javelin_death_4"	  ]	  = %javelin_death_4;
	level.scr_anim[ "generic" ] [ "fork_driver"		  ]	  = %london_utilitytruck_driver_idle;
	level.scr_anim[ "generic" ] [ "outside_door_talk" ]	  = %carrier_deck_wave_dude;
	level.scr_anim[ "hesh"	  ] [ "hesh_talk"		  ]	  = %carrier_deck_wave_hesh;
	level.scr_anim[ "merrick" ] [ "wave_over"	   ]	  = %stand_exposed_wave_on_me;
	level.scr_anim[ "merrick" ] [ "walk_and_talk"  ]	  = %clockwork_walkout_allies_walk_1;
	level.scr_anim[ "merrick" ] [ "dive"		   ]	  = %corner_standR_explosion_divedown;
	level.scr_anim[ "merrick" ] [ "wave_to_player" ]	  = %carrier_deck_wave_merrick;
	
	
	
	
	//heli ride
	level.scr_anim[ "hesh" ][ "hesh_blackhawk_getin" ]	   = %rescue_ending_pres_heli_getin_president;
	
	//gunner death
	level.scr_anim[ "hesh" ] [ "carrier_heli_ride_idle_ally"	  ] [ 0 ]	= %carrier_heli_ride_idle_ally;
	level.scr_anim[ "generic" ] [ "carrier_heli_ride_idle_gunner" ] [ 0 ]	= %carrier_heli_ride_idle_gunner;
	level.scr_anim[ "generic" ] [ "carrier_heli_ride_gunner_death_gunner" ] = %carrier_heli_ride_gunner_death_gunner;
	level.scr_anim[ "hesh" ] [ "carrier_heli_ride_gunner_death_ally"	  ] = %carrier_heli_ride_gunner_death_ally;	
	
	//heli run ambience
	level.scr_anim[ "generic" ] [ "dragger"				  ] = %payback_docks_drag_body1;
	level.scr_anim[ "generic" ] [ "wounded being dragged" ] = %payback_docks_drag_body2;
	level.scr_anim[ "generic" ] [ "run_wave"			  ] = %favela_run_and_wave;
	
	//heli crash
	level.scr_anim[ "hesh" ] [ "helicrash_pullup" ] = %sw_roofhit_hesh_pullup;
	
	//defend sparrow
	level.scr_anim[ "generic" ] [ "crouch_idle"			  ] [ 0 ]  = %casual_crouch_idle;
	level.scr_anim[ "generic" ] [ "casual_crouch_V2_idle" ] [ 0 ]  = %casual_crouch_V2_idle;
	level.scr_anim[ "generic" ] [ "casual_crouch_V2_idle_out"	 ] = %casual_crouch_V2_idle_out;
	level.scr_anim[ "generic" ] [ "readystand_idle"	 ][ 0 ]		   = %readystand_idle;
	
	//deck combat 2
	level.scr_anim[ "generic" ] [ "redshirt_crouch" ] [ 0 ] = %coverstand_hide_idle_wave02;
	level.scr_anim[ "hesh"	  ] [ "hesh_crouch"		] [ 0 ] = %coverstand_hide_idle_wave02;
	level.scr_anim[ "hesh"	  ] [ "run_into_cover"	] [ 0 ] = %coverstand_hide_idle_wave01;
	level.scr_anim[ "generic" ] [ "run_blindfire"	 ]		= %run_n_gun_L_120;
	
//	addNotetrack_customFunction( "hesh", "handoff_rumble", maps\prague_escape_code::play_light_rumble, "toss_gun" );

	//victory moment	
	level.scr_anim[ "generic" ] [ "london_civ_idle_wave"		 ][ 0 ] = %london_civ_idle_wave;
	level.scr_anim[ "generic" ] [ "london_police_jog_2_wave"	 ]		= %london_police_jog_2_wave;
	level.scr_anim[ "generic" ] [ "london_police_wave_1"  ] [ 0 ]		= %london_police_wave_1;	

	//rod of god reactions
	level.scr_anim[ "generic" ] [ "corner_left_lookat_range_up" ] [ 0 ] = %corner_left_lookat_range_up;
	level.scr_anim[ "hesh"	  ] [ "corner_left_lookat_range_up" ] [ 0 ] = %corner_left_lookat_range_up;
	level.scr_anim[ "generic" ] [ "hunted_tunnel_guy1_lookup" ]			= %hunted_tunnel_guy1_lookup;
	level.scr_anim[ "generic" ] [ "patrol_jog_look_up_once"	  ]			= %patrol_jog_look_up_once;
	level.scr_anim[ "generic" ] [ "unarmed_cowerstand_react"  ]			= %unarmed_cowerstand_react;
	level.scr_anim[ "hesh"	  ] [ "unarmed_cowerstand_react"  ]			= %unarmed_cowerstand_react;

	// --DECK TILT--
	//explosion on island - listed in common_anims.csv
	level.scr_anim[ "generic" ] [ "explosion_death_1" ] = %death_explosion_stand_F_v2;
	level.scr_anim[ "generic" ] [ "explosion_death_2" ] = %death_explosion_stand_F_v3;
	
	//deck run - listed in common_anims.csv
	level.scr_anim[ "generic" ] [ "death_explosion_stand_B_v1" ] = %death_explosion_stand_B_v1;
	level.scr_anim[ "generic" ] [ "death_explosion_stand_B_v2" ] = %death_explosion_stand_B_v2;
	level.scr_anim[ "generic" ] [ "death_explosion_stand_B_v3" ] = %death_explosion_stand_B_v3;
	level.scr_anim[ "generic" ] [ "death_explosion_stand_L_v1" ] = %death_explosion_stand_L_v1;
	level.scr_anim[ "generic" ] [ "death_explosion_stand_L_v2" ] = %death_explosion_stand_L_v2;
			
	//reaction anims for allies when running to the heli - listed in common_anims.csv
	level.scr_anim[ "generic" ] [ "run_react_stumble"	  ] = %run_react_stumble;
	level.scr_anim[ "generic" ] [ "run_pain_stumble"	  ] = %run_pain_stumble;
	level.scr_anim[ "generic" ] [ "run_pain_fallonknee"	  ] = %run_pain_fallonknee;
	level.scr_anim[ "generic" ] [ "run_pain_stomach_fast" ] = %run_pain_stomach_fast;
	level.scr_anim[ "generic" ] [ "run_pain_fall"		  ] = %run_pain_fall;
	
	//reaction anims for allies when they are at a node on their way to heli - listed in common_anims.csv
	level.scr_anim[ "generic" ] [ "exposed_pain_2_crouch"	   ] = %exposed_pain_2_crouch;
	level.scr_anim[ "generic" ] [ "exposed_crouch_pain_flinch" ] = %exposed_crouch_pain_flinch;
	
	//deck specific stumbles and falls
	level.scr_anim[ "generic" ][ "carrier_fall_loop" ]			 = %carrier_fall_loop; //not really a loop atm
	level.scr_anim[ "generic" ] [ "carrier_stumble_fall"	   ] = %carrier_stumble_fall;
	level.scr_anim[ "generic" ] [ "carrier_stumble_recover"	   ] = %carrier_stumble_recover;
	level.scr_anim[ "generic" ] [ "carrier_enemy_deck_slide_a" ] = %carrier_enemy_deck_slide_a;
	level.scr_anim[ "generic" ] [ "carrier_enemy_deck_slide_b" ] = %carrier_enemy_deck_slide_b;
	
	//leg grab anim
	//level.scr_anim[ "generic" ] [ "carrier_deck_grapple_start_russian" ] = %carrier_deck_grapple_start_russian;
	//level.scr_anim[ "generic" ] [ "carrier_deck_grapple_lose_russian"  ] = %carrier_deck_grapple_lose_russian;
	//level.scr_anim[ "generic" ] [ "carrier_deck_grapple_death_russian" ] = %carrier_deck_grapple_death_russian;
	
	//level.scr_anim[ "merrick" ][ "carrier_deck_grapple_start_seal" ]			= %carrier_deck_grapple_start_seal;
	//addNotetrack_customFunction( "merrick", "player_fail", maps\proto_carrier_flight_deck::leg_grab_archer_fail, "carrier_deck_grapple_start_seal" );
	//level.scr_anim[ "merrick" ] [ "carrier_deck_grapple_escape_seal" ] = %carrier_deck_grapple_escape_seal;
	//level.scr_anim[ "merrick" ] [ "carrier_deck_grapple_lose_seal"	] = %carrier_deck_grapple_lose_seal;
	
	//--Outro--
	//JMCD: TEMP CHANGED TO HESH TO PREVENT SRE (DUE TO DELETING MERRICK EARLIER)
	level.scr_anim[ "hesh" ] [ "carrier_outro"	] = %carrier_outro_merric;
	level.scr_anim[ "generic" ] [ "carrier_outro"	] = %carrier_outro_helmsman;
	
	level.scr_anim[ "generic" ] [ "dead_body_floating_1" ][ 0 ] = %dead_body_floating_1;
	level.scr_anim[ "generic" ] [ "dead_body_floating_2" ][ 0 ] = %dead_body_floating_2;
}

#using_animtree( "player" );
player()
{
	level.scr_animtree[ "player_rig" ] = #animtree;
	level.scr_model[ "player_rig" ] = "viewhands_player_udt";	
	level.scr_anim[ "player_rig" ][ "carrier_player_slide" ]		 		= %carrier_player_slide;
	
	//slow intro
	level.scr_anim[ "player_rig" ] [ "carrier_ghost_intro_deck_player"	 ] = %carrier_ghost_intro_deck_player;
	level.scr_anim[ "player_rig" ] [ "carrier_ghost_intro_medbay_player" ] = %carrier_ghost_intro_medbay_player;
	level.scr_anim[ "player_rig" ] [ "carrier_medbay_fever_doors"		 ] = %carrier_medbay_fever_player;

	//aas_72x
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_out" ] 	= %vegas_player_littlebird_lean_out;
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_in" ] 	= %vegas_player_littlebird_lean_in;	
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_out_b" ] 	= %vegas_player_littlebird_lean_out_b;
	level.scr_anim[ "player_rig"] [ "vegas_player_littlebird_lean_in_b" ] 	= %vegas_player_littlebird_lean_in_b;
	
	level.scr_animtree[ "player_legs" ]											 = #animtree;
	level.scr_model	  [ "player_legs" ]											 = "viewlegs_generic";
	level.scr_anim[ "player_legs" ] [ "carrier_ghost_intro_medbay_player_legs" ] = %carrier_ghost_intro_medbay_player_legs;
	
	//gunner death
	level.scr_anim[ "player_rig" ] [ "carrier_heli_ride_gunner_death_player" ] = %carrier_heli_ride_gunner_death_player;	
	
	//heli crash
	level.scr_anim[ "player_rig" ][ "helicrash_jump" ] = %sw_roofhit_player_jump;
	addNotetrack_notify( "player_rig", "player_hit_car", "notify_jump_hit_side" );
    addNotetrack_notify( "player_rig", "player_end_vignette", "notify_player_end_vignette" );
	
	// --Outro--
	level.scr_anim[ "player_rig" ][ "carrier_outro" ] = %carrier_outro_player;
}

#using_animtree( "script_model" );
script_models()
{
	//turret at entry
	level.scr_animtree[ "turret" ]								= #animtree;
}

#using_animtree( "animated_props" );
animated_props()
{
	// --Intro--
	level.scr_animtree[ "cart" ]								= #animtree;
	level.scr_model	  [ "cart" ]								= "generic_prop_raven";
	level.scr_anim[ "cart" ][ "carrier_ghost_intro_deck_cart" ] = %carrier_ghost_intro_deck_cart;
	
	level.scr_animtree[ "medbay_doors" ]								  = #animtree;
	level.scr_model	  [ "medbay_doors" ]								  = "generic_prop_raven";
	level.scr_anim[ "medbay_doors" ] [ "carrier_medbay_fever_doors" ] = %carrier_medbay_fever_doors;
	
	// --Tilt--
	// rolling barrel
	level.scr_animtree[ "sstorm_barrel" ]				  = #animtree;
	level.scr_anim[ "sstorm_barrel" ][ "roll_loop" ][ 0 ] = %payback_sstorm_barrel_roll;
	
	// rolling spool
	level.scr_animtree[ "spool" ]					= #animtree;
	level.scr_anim[ "spool" ][ "roll_first_frame" ] = %carrier_spool_deck_slide;
	level.scr_anim[ "spool" ][ "roll_loop" ][ 0 ]	= %carrier_spool_deck_slide;
	
	// Exploding helicopter
	level.scr_animtree[ "exploding_heli" ]							= #animtree;
	level.scr_anim[ "exploding_heli" ][ "carrier_mi_17_idle" ][ 0 ] = %carrier_mi_17_idle;
	level.scr_anim[ "exploding_heli" ][ "carrier_mi_17_explosion" ] = %carrier_mi_17_explosion;
	
	// Sliding jet
	level.scr_animtree[ "sliding_jet" ]								 = #animtree;
	level.scr_anim[ "sliding_jet" ] [ "carrier_mig29_deck_slide_a" ] = %carrier_mig29_deck_slide_a;
	level.scr_anim[ "sliding_jet" ] [ "carrier_mig29_deck_slide_b" ] = %carrier_mig29_deck_slide_b;
	level.scr_anim[ "sliding_jet" ] [ "carrier_mig29_deck_slide_c" ] = %carrier_mig29_deck_slide_c;
		
	// Forklift
	level.scr_animtree[ "forklift" ]						 = #animtree;
	level.scr_anim[ "forklift" ][ "carrier_forklift_slide" ] = %carrier_forklift_slide;
	
	// Generic
	level.scr_animtree[ "generic_slide" ]								  = #animtree;
	level.scr_model	  [ "generic_slide" ]								  = "generic_prop_raven";
	level.scr_anim[ "generic_slide" ] [ "carrier_prop_deck_slide_far_a" ] = %carrier_prop_deck_slide_far_a;
	level.scr_anim[ "generic_slide" ] [ "carrier_prop_deck_slide_far_b" ] = %carrier_prop_deck_slide_far_b;
	level.scr_anim[ "generic_slide" ] [ "carrier_prop_deck_slide_mid_a" ] = %carrier_prop_deck_slide_mid_a;
	level.scr_anim[ "generic_slide" ] [ "carrier_prop_deck_slide_full" ] = %carrier_prop_deck_slide_full;
	level.scr_anim[ "generic_slide" ] [ "carrier_prop_deck_slide_fall" ] = %carrier_prop_deck_slide_fall;
	
	// Barrels
	level.scr_animtree[ "barrels" ]									 = #animtree;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_a"  ] = %carrier_barrel_pallet_slide_a;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_b1" ] = %carrier_barrel_pallet_slide_b1;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_b2" ] = %carrier_barrel_pallet_slide_b2;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_c1" ] = %carrier_barrel_pallet_slide_c1;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_c2" ] = %carrier_barrel_pallet_slide_c2;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_c3" ] = %carrier_barrel_pallet_slide_c3;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_c4" ] = %carrier_barrel_pallet_slide_c4;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_c5" ] = %carrier_barrel_pallet_slide_c5;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_c6" ] = %carrier_barrel_pallet_slide_c6;
	level.scr_anim[ "barrels" ] [ "carrier_barrel_pallet_slide_c7" ] = %carrier_barrel_pallet_slide_c7;
	
}

#using_animtree( "generic_human" );
squad_vo()
{

}

#using_animtree( "vehicles" );
vehicles()
{
	level.scr_animtree[ "nh90" ]								= #animtree;
	level.scr_anim[ "nh90" ][ "carrier_ghost_intro_deck_nh90" ] = %carrier_ghost_intro_deck_nh90;
	blackhawk_anims();
	
	//deck combat- carrier life 
	
	level.scr_animtree[ "tugger" ]				   = #animtree;
	level.scr_anim[ "tugger" ] [ "tugger_scene_enter" ] = %carrier_elevator_scene_tugger_enter;
	level.scr_anim[ "tugger" ] [ "tugger_scene_exit" ] = %carrier_elevator_scene_tugger_exit;
	level.scr_anim[ "tugger" ] [ "tugger_scene_loop" ] [0] = %carrier_elevator_scene_tugger_loop;
	
	level.scr_animtree[ "elevator_jet" ]				   = #animtree;
	level.scr_anim[ "elevator_jet" ] [ "elevator_jet_scene_enter" ] = %carrier_elevator_scene_jet_enter;
	level.scr_anim[ "elevator_jet" ] [ "elevator_jet_scene_exit" ] = %carrier_elevator_scene_jet_exit;
	level.scr_anim[ "elevator_jet" ] [ "elevator_jet_scene_loop" ] [0] = %carrier_elevator_scene_jet_loop;
	
	
	// --Outro --
	level.scr_animtree[ "zodiac" ]				   = #animtree;
	level.scr_anim[ "zodiac" ] [ "carrier_outro" ] = %carrier_outro_zodiac;
	
	level.scr_animtree[ "outro_blackhawk" ]								   = #animtree;
	level.scr_anim[ "outro_blackhawk" ] [ "carrier_outro_enter_heli" ]	   = %carrier_outro_enter_heli;
	level.scr_anim[ "outro_blackhawk" ] [ "carrier_outro_idle_heli" ][ 0 ] = %carrier_outro_idle_heli;
}

blackhawk_anims()
{
	level.scr_animtree[ "carrier_blackhawk" ] = #animtree;
	load_blackhawk_turret_anims();
	maps\_minigun_viewmodel::anim_minigun_hands();	
}

load_blackhawk_turret_anims()
{
	level.scr_animtree[ "blackhawk_turret" ]							= #animtree;	
}
