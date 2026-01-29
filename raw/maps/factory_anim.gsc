#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;
#include maps\_vignette_util;

main()
{
	generic_human();
	script_model();
	player();
	dialog();
	vehicles();
	level thread vignettes();
}

vignettes()
{
	
	// level thread vignette_register( ::factory_introkill_jungle_player_spawn, "factory_introkill_jungle" );
	// level thread vignette_register( ::factory_intro_spawn		 , "factory_intro" );
	level thread vignette_register( ::ambush						, "ambush_triggered" ); 
	//level thread vignette_register( ::factory_car_chase_spawn		, "factory_car_chase" );
	
}

#using_animtree( "generic_human" );
generic_human()
{	
	//   animname 		   notetrack 			      function 													    anime 	
	
	// Intro_jungle kills
	level.scr_anim[ "ally_alpha"  ][ "factory_intro_jungle_drop_ally01"  ] = %factory_intro_jungle_drop_ally01;
	level.scr_anim[ "ally_alpha"  ][ "factory_intro_jungle_drop_ally01_loop01"  ][ 0 ] = %factory_intro_jungle_drop_ally01_loop01;
	level.scr_anim[ "ally_alpha"  ][ "factory_intro_jungle_drop_ally01_ptr02"  ] = %factory_intro_jungle_drop_ally01_ptr02;
	level.scr_anim[ "ally_alpha"  ][ "factory_intro_jungle_drop_ally01_loop02"  ][ 0 ] = %factory_intro_jungle_drop_ally01_loop02;
	level.scr_anim[ "ally_alpha"  ][ "factory_intro_jungle_drop_kill_ally01"  ] = %factory_intro_jungle_drop_kill_ally01;

	// baker kill enemy
	level.scr_anim[ "introkill_enemy1"  ][ "factory_intro_jungle_drop_opfor01"  ] = %factory_intro_jungle_drop_opfor01;
	level.scr_anim[ "introkill_enemy1"  ][ "factory_intro_jungle_drop_kill_opfor01"  ] = %factory_intro_jungle_drop_kill_opfor01;
	addNotetrack_customFunction( "introkill_enemy1", "fx_intro_kill_ally_stab", maps\factory_fx::fx_intro_kill_ally_stab );
	level.scr_anim[ "introkill_enemy1"  ][ "factory_intro_jungle_drop_opfor01_loop"  ][ 0 ] = %factory_intro_jungle_drop_opfor01_loop;
	// player kill enemy
	level.scr_anim[ "introkill_enemy2"  ][ "factory_intro_jungle_drop_opfor02"  ] = %factory_intro_jungle_drop_opfor02;
	level.scr_anim[ "introkill_enemy2"  ][ "factory_intro_jungle_drop_opfor02_loop"  ][ 0 ] = %factory_intro_jungle_drop_opfor02_loop;
	level.scr_anim[ "introkill_enemy2"  ][ "factory_intro_jungle_drop_kill_player"  ] = %factory_intro_jungle_drop_kill_opfor02;
	addNotetrack_customFunction( "introkill_enemy2", "fx_intro_kill_player_stab", maps\factory_fx::fx_intro_kill_player_stab );

	// Intro_jungle
	
	level.scr_anim[ "generic"	  ][ "crouch_fastwalk_F"					   ]   = %crouch_fastwalk_F;
	level.scr_anim[ "ally_alpha"  ][ "crouch_fastwalk_F"					   ]   = %crouch_fastwalk_F;
	level.scr_anim[ "player_body" ][ "factory_intro_jungle_player"			   ]   = %factory_intro_jungle_body_player;
	level.scr_anim[ "ally_alpha"  ][ "factory_intro_jungle_slide_baker_enter"  ]   = %factory_intro_jungle_slide_baker_enter;
	level.scr_anim[ "ally_alpha"  ][ "factory_intro_jungle_slide_baker_lookup" ]   = %factory_intro_jungle_slide_baker_lookup;
	level.scr_anim[ "ally_alpha" ][ "factory_intro_jungle_slide_baker_loop" ][ 0 ] = %factory_intro_jungle_slide_baker_loop;
	level.scr_anim[ "ally_alpha" ][ "factory_intro_jungle_slide_baker_exit" ]	   = %factory_intro_jungle_slide_baker_exit;
	
	// Intro ally wallhops
	
	// level.scr_anim[ "player_body"  ][ "factory_intro_jungle_slide_player" ] = %factory_intro_jungle_slide_body_player;
	level.scr_anim[ "ally_bravo"   ][ "factory_intro_jungle_wallhop"	  ] = %factory_intro_jungle_wallhop_ally01;
	level.scr_anim[ "ally_charlie" ][ "factory_intro_jungle_wallhop"	  ] = %factory_intro_jungle_wallhop_ally02;
	level.scr_anim[ "ally_delta"   ][ "factory_intro_jungle_wallhop"	  ] = %factory_intro_jungle_wallhop_ally03;
	
	
	// Intro

	level.scr_anim[ "ally_bravo"	][ "factory_intro" ]							= %factory_intro_ally01;
	level.scr_anim[ "ally_alpha"	][ "factory_intro" ]							= %factory_intro_ally02;
	level.scr_anim[ "initial_enemy" ][ "factory_intro" ]							= %factory_intro_guard;
	// level.scr_anim[ "generic"		][ "active_patrolwalk_gundown"	][ 0 ]			= %active_patrolwalk_gundown;
	// level.scr_anim[ "generic"		][ "patrol_bored_gundown_walk1" ][ 0 ]			= %patrol_bored_gundown_walk1;
	level.scr_anim[ "initial_enemy" ][ "flashlight_searching"		][ 0 ]			= %so_hijack_search_flashlight_high_loop;
	level.scr_anim[ "initial_enemy" ][ "factory_opfor_trainyard_patrol_enter" ]		= %factory_opfor_trainyard_patrol_enter;
	level.scr_anim[ "initial_enemy" ][ "factory_opfor_trainyard_patrol_loop" ][ 0 ] = %factory_opfor_trainyard_patrol_loop;
	level.scr_anim[ "initial_enemy" ][ "factory_opfor_trainyard_patrol_reaction" ]	= %factory_opfor_trainyard_patrol_reaction;
	level.scr_anim[ "initial_enemy" ][ "factory_opfor_trainyard_melee_death" ]	= %factory_opfor_trainyard_melee_death_opfor;

	//   animname 		   notetrack 				     function 									    anime
	addNotetrack_customFunction( "initial_enemy", "notetrack_kill"			, maps\factory_powerstealth::kill_initial_guard );
	
	level.scr_anim[ "ally_charlie" ][ "factory_intro_ally03" ] = %factory_intro_ally03;
	
	level.scr_anim[ "ally_alpha" ][ "factory_intro_ally_mantle" ]		   = %factory_intro_cover_ally02;
	level.scr_anim[ "ally_alpha" ][ "factory_intro_ally_cover_idle" ][ 0 ] = %factory_intro_cover_idle_ally02;
	
	level.scr_anim[ "ally_delta" ][ "factory_engine_jump_ally01" ] = %factory_engine_jump_ally01;
	level.scr_anim[ "ally_echo"	 ][ "factory_engine_jump_ally02" ] = %factory_engine_jump_ally02;
	

	// STEALTH //
	// level.scr_anim[ "initial_enemy" ][ "patrol_bored_patrolwalk_ice" ]		  = %patrol_bored_patrolwalk_ice;
	level.scr_anim[ "initial_enemy" ][ "patrol_bored_idle" ][ 0 ]			  = %patrol_bored_idle;
	level.scr_anim[ "initial_enemy" ][ "patrol_bored_patrolwalk_twitch"		] = %patrol_bored_patrolwalk_twitch;
	level.scr_anim[ "initial_enemy" ][ "active_patrolwalk_pause"			] = %active_patrolwalk_pause;
	// level.scr_anim[ "initial_enemy" ][ "casual_killer_walk_shoot_L_aimdown" ] = %casual_killer_walk_shoot_L_aimdown;
	
	// level.scr_anim[ "enemy" ][ "rubicon_fallout_driver"					 ] = %rubicon_fallout_driver;				  //Truck driver death anim
	// level.scr_anim[ "enemy" ][ "kingfish_driver_pulled_from_truck_start" ] = %kingfish_driver_pulled_from_truck_start;//Truck driver death anim
	// level.scr_anim[ "enemy" ][ "boneyard_driver_death"					 ] = %boneyard_driver_death;				  //Truck driver death anim

	level.scr_anim[ "ally_alpha" ][ "heat_approach_6" ] = %heat_approach_6;
	
	// Truck sequence
	level.scr_anim[ "ally_charlie" ][ "factory_truck_ally02_search" ]	= %factory_truck_ally02_search;
	level.scr_anim[ "enemy"		   ][ "factory_truck_enemy01_death" ]	= %factory_truck_enemy01_death;
	level.scr_anim[ "enemy"		   ][ "factory_truck_enemy01_enter" ]	= %factory_truck_enemy01_enter;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy01_loop" ][ 0 ]		= %factory_truck_enemy01_loop;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy02_death"		  ] = %factory_truck_enemy02_death;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy02_death_searched" ] = %factory_truck_enemy02_death_searched;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy02_loop" ][ 0 ]		= %factory_truck_enemy02_loop;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy03_death" ]			= %factory_truck_enemy03_death;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy03_loop" ][ 0 ]		= %factory_truck_enemy03_loop;
	
	level.scr_anim[ "enemy" ][ "factory_truck_enemy01" ] = %factory_truck_enemy01;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy02" ] = %factory_truck_enemy02_enter;
	level.scr_anim[ "enemy" ][ "factory_truck_enemy03" ] = %factory_truck_enemy03;
	
	level.scr_anim[ "enemy" ][ "factory_truck_driver_loop"	] = %factory_truck_driver_loop;
	level.scr_anim[ "enemy" ][ "factory_truck_driver_death" ] = %factory_truck_driver_death;
	
//	level.scr_anim[ "enemy" ][ "london_surprise_turnaround_right" ] = %london_surprise_turnaround_right;
	level.scr_anim[ "enemy" ][ "surprise_stop_v1"					 ] = %surprise_stop_v1;
	level.scr_anim[ "enemy" ][ "prague_intro_dock_guard_reaction_02" ] = %prague_intro_dock_guard_reaction_02;
		
	level.scr_anim[ "ally_charlie" ][ "factory_allies_enter_factory_ally_01" ] = %factory_allies_enter_factory_ally_01;
	addNotetrack_customFunction( "ally_charlie", "intro_cardreader_unlock", maps\factory_fx::fx_intro_cardreader_unlock );
	level.scr_anim[ "ally_bravo" ][ "factory_allies_enter_factory_ally_02" ] = %factory_allies_enter_factory_ally_02;
	
	level.scr_anim[ "ally_charlie" ][ "combatwalk_F_spin" ] = %combatwalk_F_spin;
	
	// Power Stealth
	level.scr_anim[ "generic" ][ "patrol_bored_patrolwalk"	   ]	= %patrol_bored_patrolwalk;
	// level.scr_anim[ "generic" ][ "patrol_bored_patrolwalk_ice" ]	= %patrol_bored_patrolwalk_ice;
	level.scr_anim[ "generic" ][ "patrol_bored_idle" ][ 0 ]			= %patrol_bored_idle;
	level.scr_anim[ "generic" ][ "walk_gun_unwary"				 ]	= %dufflebag_casual_walk;
	level.scr_anim[ "enemy" ][ "dufflebag_casual_idle" ][ 0 ]		= %dufflebag_casual_idle;
	level.scr_anim[ "generic" ][ "patrol_bored_patrolwalk_twitch" ] = %patrol_bored_patrolwalk_twitch;
	
	level.scr_anim[ "generic" ][ "exposed_crouch_idle_twitch_v2" ][ 0 ] = %exposed_crouch_idle_twitch_v2;
	level.scr_anim[ "ally_charlie" ][ "cqb_aim" ][ 0 ] = %cqb_stand_aim5;
	level.scr_anim[ "ally_charlie" ][ "cqb_walk_2_creepwalk" ] = %cqb_walk_2_creepwalk;
	
	// level.scr_anim[ "ally_alpha" ][ "prague_stealth_kill_n_catch_soap"	] = %prague_stealth_kill_n_catch_soap;
	// level.scr_anim[ "enemy"		 ][ "prague_stealth_kill_n_catch_guard" ] = %prague_stealth_kill_n_catch_guard;

	level.scr_anim[ "ally_alpha"   ][ "corner_standL_signal_hold"			   ] = %corner_standL_signal_hold;
	level.scr_anim[ "ally_alpha"   ][ "CQB_stop_2_signal"					   ] = %CQB_stop_2_signal;
	// level.scr_anim[ "ally_alpha"   ][ "afgan_caves_intro_stop"				   ] = %afgan_caves_intro_stop;
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_ally_intro" ] = %factory_power_stealth_ally_intro;
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_ally_intro_loop" ][ 0 ] = %factory_power_stealth_ally_intro_loop;
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_ally_intro_talk" ] = %factory_power_stealth_ally_intro_talk;
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_ally_exit_loop" ][ 0 ] = %factory_power_stealth_ally_exit_loop;
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_ally_intro_exit" ] = %factory_power_stealth_ally_intro_exit;
	level.scr_anim[ "ally_alpha"   ][ "CQB_stand_signal_move_up"			   ] = %CQB_stand_signal_move_up;
	level.scr_anim[ "generic" ][ "CornerStndR_alert_signal_enemy_spotted" ] = %CornerStndR_alert_signal_enemy_spotted;
	level.scr_anim[ "generic"	   ][ "signal_onme"							   ] = %CQB_stand_wave_on_me;
	level.scr_anim[ "generic"	   ][ "signal_go_cqb"						   ] = %CQB_stand_wave_go_v1;
	level.scr_anim[ "generic"	   ][ "signal_stop"							   ] = %CQB_stand_signal_stop;

	// level.scr_anim[ "generic" ][ "oilrig_balcony_smoke_idle"	][ 0 ] = %oilrig_balcony_smoke_idle;
	// level.scr_anim[ "generic" ][ "crowdsniper_civ_crowdidle1"	][ 0 ] = %crowdsniper_civ_crowdidle1;
	// level.scr_anim[ "generic" ][ "crowdsniper_civ_crowdidle2"	][ 0 ] = %crowdsniper_civ_crowdidle2;
	// level.scr_anim[ "generic" ][ "crowdsniper_civ_crowdidle3"	][ 0 ] = %crowdsniper_civ_crowdidle3;
	// level.scr_anim[ "enemy"	  ][ "parabolic_leaning_guy_twitch" ][ 0 ] = %parabolic_leaning_guy_twitch;
	
	// level.scr_anim[ "ally_alpha" ][ "stealthkill_a_1" ]				 = %stealthkill_a_1;
	// level.scr_anim[ "enemy"		 ][ "stealthkill_b_1" ]				 = %stealthkill_b_1;
	// level.scr_anim[ "ally_bravo"   ][ "stealthkill_a_1" ]			 = %stealthkill_a_1;//Placeholder for custom anim to come
	// level.scr_anim[ "ally_charlie" ][ "stealthkill_a_1" ]			 = %stealthkill_a_1;//Placeholder for custom anim to come
	// level.scr_anim[ "ally_alpha" ][ "ICBM_patrol_knifekill_winner" ] = %ICBM_patrol_knifekill_winner;
	// level.scr_anim[ "enemy"		 ][ "ICBM_patrol_knifekill_looser" ] = %ICBM_patrol_knifekill_looser;
	
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_lower_hallway_enter_ally" ] = %factory_power_stealth_lower_hallway_enter_ally;
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_lower_hallway_cross_ally" ] = %factory_power_stealth_lower_hallway_cross_ally;
	
	level.scr_anim[ "ally_alpha" ][ "factory_power_stealth_breakarea_ally_shoot" ] = %factory_power_stealth_breakarea_ally_shoot;
	addNotetrack_customFunction( "ally_alpha", "pistol", maps\factory_powerstealth::ps_alpha_pistol_switch );
	addNotetrack_customFunction( "ally_alpha", "pistol", maps\factory_powerstealth::ps_alpha_pistol_fire );
	
	// Sleeping guard melee kill
//	level.scr_anim[ "generic" ][ "sleep_idle" ][ 0 ] = %parabolic_guard_sleeper_idle;
//	level.scr_anim[ "generic" ][ "sleep_react" ]	 = %parabolic_guard_sleeper_react;
//	level.scr_anim[ "generic" ][ "throat_stab" ]	 = %africa_tower_throat_stab_npc;
	addNotetrack_customFunction( "generic", "knife_in", ::throat_stab_npc );
	
	// level.scr_anim[ "generic" ][ "sitting_guard_loadAK_idle"	][ 0 ] = %sitting_guard_loadAK_idle;
	// level.scr_anim[ "generic" ][ "civilian_sitting_talking_A_1" ][ 0 ] = %civilian_sitting_talking_A_1;
	
	level.scr_anim[ "enemy" ][ "flashlight_search_loop"	  ][ 0 ] = %so_hijack_search_flashlight_high_loop;
	// level.scr_anim[ "enemy" ][ "coup_talking_patrol_guy2" ][ 0 ] = %coup_talking_patrol_guy2;
	// level.scr_anim[ "enemy" ][ "payback_search_walk_1"		 ]	 = %payback_search_walk_1_noloop;
	level.scr_anim[ "enemy" ][ "active_patrolwalk_turn_180" ]	 = %active_patrolwalk_turn_180;
	level.scr_anim[ "enemy" ][ "active_patrolwalk_v2"		]	 = %active_patrolwalk_v2;
	level.scr_anim[ "enemy" ][ "active_patrolwalk_v4"		]	 = %active_patrolwalk_v4;
	level.scr_anim[ "enemy" ][ "active_patrolwalk_v5"		]	 = %active_patrolwalk_v5;
	level.scr_anim[ "enemy" ][ "active_patrolwalk_pause"	]	 = %active_patrolwalk_pause;
	level.scr_anim[ "enemy" ][ "casual_stand_idle" ][ 0 ]		 = %casual_stand_idle;
		
	level.scr_anim[ "ally" ][ "rogers_hall_kill" ] = %factory_power_stealth_hallway_death_hero;
	
	level.scr_anim[ "ally"	][ "baker_lower_hall_kill" ] = %factory_power_stealth_lower_hallway_hero;
	level.scr_anim[ "opfor" ][ "baker_lower_hall_kill" ] = %factory_power_stealth_lower_hallway_enemy;

	level.scr_anim[ "opfor01" ][ "rest_area_kills"			 ] = %factory_power_stealth_break_area_death_a;
	level.scr_anim[ "opfor02" ][ "rest_area_kills"			 ] = %factory_power_stealth_break_area_death_b;
	level.scr_anim[ "opfor01" ][ "break_area_react_a"	 ] = %factory_power_stealth_break_area_react_a;
	level.scr_anim[ "opfor02" ][ "break_area_react_b"		 ] = %factory_power_stealth_break_area_react_b;
	level.scr_anim[ "opfor01" ][ "break_area_react_death_a" ] = %factory_power_stealth_break_area_react_death_a;
	level.scr_anim[ "opfor02" ][ "break_area_react_death_b" ] = %factory_power_stealth_break_area_react_death_b;
	
	// tagTJ: Needed to make duplicate entries to make generic script assign anims cleaner/easier
	level.scr_anim[ "ally_charlie" ][ "rogers_hall_kill_enter" ]	 = %factory_power_stealth_hallway_death_enter_hero;
	level.scr_anim[ "ally_charlie" ][ "rogers_hall_kill_loop" ][ 0 ] = %factory_power_stealth_hallway_death_loop_hero;
	level.scr_anim[ "ally_charlie" ][ "rogers_hall_kill" ]			 = %factory_power_stealth_hallway_death_hero;
	level.scr_anim[ "opfor"		   ][ "rogers_hall_kill" ]			 = %factory_power_stealth_hallway_death_enemy;
	
	level.scr_anim[ "ally_alpha" ][ "baker_lower_hall_kill_hero"  ] = %factory_power_stealth_lower_hallway_hero;
	level.scr_anim[ "enemy"		 ][ "baker_lower_hall_kill_enemy" ] = %factory_power_stealth_lower_hallway_enemy;
	
	level.scr_anim[ "opfor01" ][ "factory_power_stealth_break_area_idle_a" ][ 0 ] = %factory_power_stealth_break_area_idle_a;
	level.scr_anim[ "opfor02" ][ "factory_power_stealth_break_area_idle_b" ][ 0 ] = %factory_power_stealth_break_area_idle_b;
	level.scr_anim[ "opfor" ][ "factory_power_stealth_break_area_death_a" ]		  = %factory_power_stealth_break_area_death_a;
	level.scr_anim[ "opfor" ][ "factory_power_stealth_break_area_death_b" ]		  = %factory_power_stealth_break_area_death_b;
	
	level.scr_anim[ "enemy" ][ "console_kill" ]							   = %factory_power_stealth_console_death;
	level.scr_anim[ "enemy" ][ "factory_power_stealth_console_idle" ][ 0 ] = %factory_power_stealth_console_idle;
	
	// Upper level corner shot
	level.scr_anim[ "ally_charlie" ][ "factory_power_stealth_ally_corner_entrance" ]  = %factory_power_stealth_ally_corner_entrance;
	level.scr_anim[ "ally_charlie" ][ "factory_power_stealth_ally_corner_idle" ][ 0 ] = %factory_power_stealth_ally_corner_idle;
	level.scr_anim[ "ally_charlie" ][ "factory_power_stealth_ally_corner_exit" ]	  = %factory_power_stealth_ally_corner_exit;
							  
	// Chair death
	level.scr_anim[ "generic" ][ "sleep_enter" ] = %factory_power_stealth_opfor_console_enter;
	
	level.scr_anim[ "generic" ][ "sleep_idle" ][ 0 ] = %factory_power_stealth_opfor_console_loop;
	level.scr_anim[ "generic" ][ "throat_stab" ]	 = %factory_power_stealth_opfor_console_melee_death;
		
	level.scr_anim[ "generic" ][ "sleep_react"	] = %factory_power_stealth_opfor_console_react;
	level.scr_anim[ "generic" ][ "sleeper_shot" ] = %factory_power_stealth_opfor_console_death_shot;
	
	// Railing tumble death and Keegan approach
	level.scr_anim[ "ally_bravo" ][ "keegan_office_kill_enter" ] = %factory_power_stealth_stairway_top_ally_enter;
	level.scr_anim[ "ally_bravo" ][ "keegan_office_kill_exit" ] = %factory_power_stealth_stairway_top_ally_exit;
	level.scr_anim[ "ally_bravo" ][ "keegan_office_kill_loop" ][ 0 ] = %factory_power_stealth_stairway_top_ally_loop;
	level.scr_anim[ "ally_bravo" ][ "keegan_office_kill_shoot" ] = %factory_power_stealth_stairway_top_ally_shoot;
	addNotetrack_customFunction( "ally_bravo", "fire", maps\factory_powerstealth::bravo_shoot_office_guard );
	
	level.scr_anim[ "ally_charlie" ][ "keegan_top_stairway_kill" ] = %factory_power_stealth_stairway_top_death_hero;
	level.scr_anim[ "enemy"		   ][ "keegan_top_stairway_kill" ] = %factory_power_stealth_stairway_top_death_enemy;
	addNotetrack_customFunction( "enemy", "start_ragdoll"		, ::rag_doll );
	
	// KM - Doesn't seem to be used
	// level.scr_anim[ "enemy" ][ "blackice_catwalk_deathfall_4" ] = %blackice_catwalk_deathfall_4;
	
	level.scr_anim[ "opfor01" ][ "last_patrol_kill" ] = %factory_power_stealth_last_patrol_kill_enemy;
	level.scr_anim[ "ally01"  ][ "last_patrol_kill" ] = %factory_power_stealth_last_patrol_kill_hero;
	
	// KM - Doesn't seem to be used
	//level.scr_anim[ "opfor" ][ "training_intro_foley_idle_1" ][ 0 ] = %training_intro_foley_idle_1;

	// Allies Enter factory interior
	level.scr_anim[ "ally01" ][ "allies_enter_factory_ally01" ] = %factory_allies_enter_factory_ally_01;
	level.scr_anim[ "ally02" ][ "allies_enter_factory_ally02" ] = %factory_allies_enter_factory_ally_02;
	
	level.scr_anim[ "ally_charlie" ][ "corner_standL_trans_CQB_IN_2" ] = %corner_standL_trans_CQB_IN_2;

	// Presat Door Open ( rotating door )
	level.scr_anim[ "ally_alpha"   ][ "presat_door_arrive" ] = %factory_allies_arrive_preSAT_door_ally01;
	level.scr_anim[ "ally_charlie" ][ "presat_door_arrive" ] = %factory_allies_arrive_preSAT_door_ally02;
	level.scr_anim[ "ally_bravo"   ][ "presat_door_arrive" ] = %factory_allies_arrive_preSAT_door_ally03;
	level.scr_anim[ "ally_alpha"   ][ "presat_door_enter"  ] = %factory_allies_enter_preSAT_door_ally01;
	level.scr_anim[ "ally_charlie" ][ "presat_door_enter"  ] = %factory_allies_enter_preSAT_door_ally02;
	level.scr_anim[ "ally_bravo"   ][ "presat_door_enter"  ] = %factory_allies_enter_preSAT_door_ally03;

	// SAT Room ally idle anims
	level.scr_anim[ "ally_alpha"   ][ "sat_room_alpha_lights" ] = %factory_ambush_ally02_loop;	// Baker turns on lights
	level.scr_anim[ "ally_alpha"   ][ "sat_room_alpha_computer" ][ 0 ] = %factory_ambush_ally03_loop; // Baker uses computer
	level.scr_anim[ "ally_bravo"   ][ "sat_room_bravo_computer_01" ][ 0 ] = %factory_ambush_ally02_loop; // Keegan uses computer
	level.scr_anim[ "ally_bravo"   ][ "sat_room_bravo_computer_02" ][ 0 ] = %factory_ambush_ally02_loop; // Keegan uses computer again
	// level.scr_anim[ "ally_alpha"   ][ "arcadia_fridge_idle" ][ 0 ] = %arcadia_fridge_idle; // Baker interacts with the SAT

	// SAT interact ally
	/*
	level.scr_anim[ "ally_alpha" ][ "sat_board_ally_enter" ]		   = %factory_SATroom_pullout_Board_enter_ally01;
	level.scr_anim[ "ally_alpha" ][ "sat_board_ally_rail_loop" ][ 0 ]  = %factory_SATroom_pullout_Board_rail_loop_ally01;
	level.scr_anim[ "ally_alpha" ][ "sat_board_ally_dismount" ]		   = %factory_SATroom_pullout_Board_rail_dismount_ally01;
	level.scr_anim[ "ally_alpha" ][ "sat_board_ally_floor_loop" ][ 0 ] = %factory_SATroom_pullout_Board_floor_loop_ally01;
	level.scr_anim[ "ally_alpha" ][ "sat_board_ally_handoff" ]		   = %factory_SATroom_pullout_Board_handoff_ally01;
	*/
	
	// Assembly line door open
	level.scr_anim[ "ally_alpha"   ][ "factory_assembly_floor_open_door" ] = %factory_assembly_floor_open_door_ally01;
	level.scr_anim[ "ally_charlie" ][ "factory_assembly_floor_open_door" ] = %factory_assembly_floor_open_door_ally02;
	addNotetrack_customFunction( "ally_charlie", "assembly_cardreader_unlock", maps\factory_fx::fx_assembly_cardreader_unlock );
	
	// Ambush Desk search
	level.scr_anim[ "ally_bravo" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_ally03;
	addNotetrack_customFunction( "ally_bravo", "fx_monitor_swap", maps\factory_fx::fx_assembly_ally_monitor_swap_1 );

	level.scr_anim[ "ally_charlie" ][ "ambush_charlie_desk_search" ] = %factory_ambush_desk_search_ally02;
	addNotetrack_customFunction( "ally_charlie", "fx_monitor_swap", maps\factory_fx::fx_assembly_ally_monitor_swap_2 );

	level.scr_anim[ "ally_alpha"   ][ "tell_player_get_data" ][ 0 ] = %factory_ambush_ally01_loop;
	level.scr_anim[ "ally_charlie" ][ "charlie_typing"		 ][ 0 ] = %factory_ambush_ally02_loop;
	level.scr_anim[ "ally_bravo"   ][ "bravo_typing"		 ][ 0 ] = %factory_ambush_ally03_loop;
	
	// Ambush breach scene
	level.scr_anim[ "ally_alpha"   ][ "ambush_ally01"  ] = %factory_ambush_ally01;
	level.scr_anim[ "ally_charlie" ][ "ambush_ally02"  ] = %factory_ambush_ally02;
	level.scr_anim[ "generic"	   ][ "ambush_enemy01" ] = %factory_ambush_opfor01;
	level.scr_anim[ "generic"	   ][ "ambush_enemy02" ] = %factory_ambush_opfor02;
	level.scr_anim[ "generic"	   ][ "ambush_enemy03" ] = %factory_ambush_opfor03;
	level.scr_anim[ "generic"	   ][ "ambush_enemy04" ] = %factory_ambush_opfor04;
	addNotetrack_customFunction( "generic", "die"		, ::kill_me );
	addNotetrack_customFunction( "generic", "fx_ambush_chest_blood", maps\factory_fx::fx_ambush_chest_blood );

	level.scr_anim[ "generic" ][ "casual_stand_idle" ][ 0 ] = %casual_stand_idle;
	level.scr_anim[ "generic" ][ "casual_stand_idle" ][ 1 ] = %casual_stand_idle_twitch;
	level.scr_anim[ "generic" ][ "casual_stand_idle" ][ 2 ] = %casual_stand_idle_twitchB;
	level.scr_anim[ "generic" ][ "bravo_rappel_drop" ]		= %berlin_granite_team_rappel_drop;
	
	// Smoke throw anims - new
	level.scr_anim[ "ally_bravo"   ][ "pop_smoke_enter_ally02" ] = %factory_ambush_pop_smoke_enter_ally02;
	level.scr_anim[ "ally_charlie" ][ "pop_smoke_enter_ally03" ] = %factory_ambush_pop_smoke_enter_ally03;

	level.scr_anim[ "ally_alpha"   ][ "pop_smoke_ally01" ] = %factory_ambush_pop_smoke_ally01;
	level.scr_anim[ "ally_bravo"   ][ "pop_smoke_ally02" ] = %factory_ambush_pop_smoke_ally02;
	level.scr_anim[ "ally_charlie" ][ "pop_smoke_ally03" ] = %factory_ambush_pop_smoke_ally03;

	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCr_01"	 ]	   = %factory_ambush_smoke_CornerCr_01;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCr_02"	 ]	   = %factory_ambush_smoke_CornerCr_02;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrL_01" ]	   = %factory_ambush_smoke_CornerCrL_01;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrL_02" ]	   = %factory_ambush_smoke_CornerCrL_02;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrL_03" ]	   = %factory_ambush_smoke_CornerCrL_03;
	//level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrL_04" ]   = %factory_ambush_smoke_CornerCrL_04;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrR_01"	 ] = %factory_ambush_smoke_CornerCrR_01;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrR_02"	 ] = %factory_ambush_smoke_CornerCrR_02;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrR_03"	 ] = %factory_ambush_smoke_CornerCrR_03;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrR_04"	 ] = %factory_ambush_smoke_CornerCrR_04;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_CornerCrR_05"	 ] = %factory_ambush_smoke_CornerCrR_05;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_stand_01"		 ] = %factory_ambush_smoke_stand_01;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_stand_02"		 ] = %factory_ambush_smoke_stand_02;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_stand_03"		 ] = %factory_ambush_smoke_stand_03;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_walkforward_01"	 ] = %factory_ambush_smoke_walkforward_01;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_walking_cough_01" ] = %factory_ambush_smoke_walking_cough_01;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_walking_cough_02" ] = %factory_ambush_smoke_walking_cough_02;
	level.scr_anim[ "generic" ][ "factory_ambush_smoke_walking_cough_03" ] = %factory_ambush_smoke_walking_cough_03;

	// Rooftop
	
	// breach
	
	level.scr_anim[ "ally_alpha"   ][ "rooftop_breach_idle" ][ 0 ] = %factory_longest_50_intro_door_breach_ally1_idle;
	level.scr_anim[ "ally_charlie" ][ "rooftop_breach_idle" ][ 0 ] = %factory_longest_50_intro_door_breach_ally2_idle;
	
	level.scr_anim[ "ally_alpha"   ][ "rooftop_breach"								 ] = %factory_longest_50_intro_door_breach_ally1;
	level.scr_anim[ "ally_charlie" ][ "rooftop_breach"								 ] = %factory_longest_50_intro_door_breach_ally2;
	level.scr_anim[ "enemy"		   ][ "exposed_idle_reactB"							 ] = %exposed_idle_reactB;
	
	level.scr_anim[ "enemy" ][ "rooftop_enemy_door_kick" ] = %door_kick_in;
	
	// jumpoff	
	level.scr_anim[ "ally_alpha"   ][ "factory_rooftop_jumpoff_ally01" ] = %factory_rooftop_jumpoff_ally01;
	level.scr_anim[ "ally_bravo"   ][ "factory_rooftop_jumpoff_ally02" ] = %factory_rooftop_jumpoff_ally02;
	level.scr_anim[ "ally_charlie" ][ "factory_rooftop_jumpoff_ally03" ] = %factory_rooftop_jumpoff_ally03;
	
	// parking lot beckon loop
	
	level.scr_anim[ "ally_alpha" ][ "factory_car_chase_intro_ally_pulls_up_player_loop" ][ 0 ] = %factory_car_chase_intro_ally_wave_to_player_loop;

	level.scr_anim[ "ally_alpha" ][ "factory_car_chase_intro_ally_pulls_up_player" ]		   = %factory_car_chase_intro_ally_pulls_up_player_ally;
	level.scr_anim[ "ally_bravo" ][ "factory_car_chase_intro_ally_pulls_up_player" ]		   = %factory_car_chase_intro_ally_pulls_up_player_ally02;
	level.scr_anim[ "ally_charlie" ][ "factory_car_chase_intro_ally_pulls_up_player" ]		   = %factory_car_chase_intro_ally_pulls_up_player_ally03;
	
	// parking lot traversals

	level.scr_anim[ "ally_alpha"   ][ "factory_parking_lot_crub_hop_ally01" ] = %factory_parking_lot_crub_hop_ally01;
	level.scr_anim[ "ally_bravo"   ][ "factory_parking_lot_crub_hop_ally02" ] = %factory_parking_lot_crub_hop_ally02;
	level.scr_anim[ "ally_charlie" ][ "factory_parking_lot_crub_hop_ally03" ] = %factory_parking_lot_crub_hop_ally03;

	//car_chase
	level.scr_anim[ "ally_alpha" ][ "factory_car_chase" ]		   = %factory_car_chase_ally01;
	level.scr_anim[ "ally_bravo" ][ "factory_car_chase" ]		   = %factory_car_chase_ally02;
	level.scr_anim[ "ally_charlie" ][ "factory_car_chase" ]		   = %factory_car_chase_ally03;

}

#using_animtree( "script_model" );
script_model()
{	
	// IntroKill_jungle
	level.scr_animtree[ "foliage" ]								 = #animtree;
	level.scr_anim[ "foliage" ][ "factory_intro_jungle_drop_player" ] = %factory_intro_jungle_drop_foliage;
	level.scr_model[ "foliage" ]								 = "factory_intro_jungle_drop_foliage";

	// Intro_jungle
	level.scr_animtree[ "foliage" ]								 = #animtree;
	level.scr_anim[ "foliage" ][ "factory_intro_jungle_player" ] = %factory_intro_jungle_foliage;
	level.scr_model[ "foliage" ]								 = "factory_intro_jungle_foliage";

	level.scr_animtree[ "chair" ]				= #animtree;
	level.scr_model	  [ "chair" ]				= "fac_ambush_desk_search_chair";
	level.scr_anim[ "chair" ][ "sleep_react"  ] = %factory_power_stealth_opfor_console_react_chair;
	level.scr_anim[ "chair" ][ "sleeper_shot" ] = %factory_power_stealth_opfor_console_death_shot_chair;
	level.scr_anim[ "chair" ][ "sleep_enter"  ] = %factory_power_stealth_opfor_console_enter_chair;
	level.scr_anim[ "chair" ][ "throat_stab"  ] = %factory_power_stealth_opfor_console_melee_death_chair;
	
	level.scr_animtree[ "rope" ] = #animtree;
	level.scr_model	  [ "rope" ] = "weapon_rappel_rope_long";
	
	level.scr_animtree[ "factory_intro_clipboard" ]								 = #animtree;
	level.scr_anim[ "factory_intro_clipboard" ][ "factory_truck_enemy02"	   ] = %factory_truck_enemy02_clipboard;
	level.scr_anim[ "factory_intro_clipboard" ][ "factory_truck_enemy02_death" ] = %factory_truck_enemy02_death_clipboard;
	level.scr_model[ "factory_intro_clipboard" ]								 = "com_clipboard_wpaper";
	
	//factory entrance cranes
	level.scr_animtree[ "front_crane" ]								 = #animtree;
	level.scr_anim[ "front_crane" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_front_crane;
	level.scr_model[ "front_crane" ]								 = "factory_crane_loader_01";

	level.scr_animtree[ "front_crane_beam" ]							  = #animtree;
	level.scr_anim[ "front_crane_beam" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_front_crane_beam;
	level.scr_model[ "front_crane_beam" ]								  = "tag_origin";
	//level.scr_model[ "front_crane_beam" ]								  = "vehicle_battletank";

	level.scr_animtree[ "factory_crane_rear" ]								= #animtree;
	level.scr_anim[ "factory_crane_rear" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_rear_crane;
	level.scr_model[ "factory_crane_rear" ]									= "factory_crane_loader_01";

	level.scr_animtree[ "factory_crane_rear_beam" ]								 = #animtree;
	level.scr_anim[ "factory_crane_rear_beam" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_rear_crane_beam;
	level.scr_model[ "factory_crane_rear_beam" ]								 = "tag_origin";
	
	/*
	level.scr_animtree[ "factory_crane_battletank" ]							  = #animtree;
	level.scr_anim[ "factory_crane_battletank" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_tank;
	level.scr_model[ "factory_crane_battletank" ]								  = "vehicle_battletank";
	*/

	level.scr_animtree[ "factory_crane_missiles" ]								= #animtree;
	level.scr_anim[ "factory_crane_missiles" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_missiles;
	level.scr_model[ "factory_crane_missiles" ]									= "tag_origin";
	
	level.scr_animtree[ "factory_allies_enter_factory_container01" ]								= #animtree;
	level.scr_anim[ "factory_allies_enter_factory_container01" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_container01;
	level.scr_model[ "factory_allies_enter_factory_container01" ]									= "tag_origin";
	
	level.scr_animtree[ "factory_allies_enter_factory_container02" ]								= #animtree;
	level.scr_anim[ "factory_allies_enter_factory_container02" ][ "allies_enter_factory_cranes" ] = %factory_allies_enter_factory_container02;
	level.scr_model[ "factory_allies_enter_factory_container02" ]									= "tag_origin";
	
	
	//power stealth rest kills
	level.scr_animtree[ "chair_opfor01" ]				   = #animtree;
	level.scr_anim[ "chair_opfor01" ][ "rest_area_kills" ] = %factory_power_stealth_break_area_death_a_chair;
	level.scr_anim[ "chair_opfor01" ][ "break_area_react_a_chair" ] = %factory_power_stealth_break_area_react_a_chair;
	level.scr_anim[ "chair_opfor01" ][ "break_area_react_death_a_chair" ] = %factory_power_stealth_break_area_react_death_a_chair;
	level.scr_model[ "chair_opfor01" ]					   = "factory_folding_chair";

	level.scr_animtree[ "chair_opfor02" ]				   = #animtree;
	level.scr_anim[ "chair_opfor02" ][ "rest_area_kills" ] = %factory_power_stealth_break_area_death_b_chair;
	level.scr_anim[ "chair_opfor02" ][ "break_area_react_b_chair" ] = %factory_power_stealth_break_area_react_b_chair;
	level.scr_anim[ "chair_opfor02" ][ "break_area_react_death_b_chair" ] = %factory_power_stealth_break_area_react_death_b_chair;
	level.scr_model[ "chair_opfor02" ]					   = "factory_folding_chair";

	// SAT room panel prop
	/*
	level.scr_animtree[ "sat_board_panel" ]	  =	  #animtree;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_start" ] = %factory_SATroom_pullout_Board_start_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_pulloff" ] = %factory_SATroom_pullout_Board_pulloff_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_look" ][ 0 ] = %factory_SATroom_pullout_Board_look_loop_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_grab" ] = %factory_SATroom_pullout_Board_grab_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_pull" ] = %factory_SATroom_pullout_Board_pull_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_dismount" ] = %factory_SATroom_pullout_Board_dismount_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_hold" ][ 0 ] = %factory_SATroom_pullout_Board_hold_loop_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_flip" ] = %factory_SATroom_pullout_Board_flip_pannel;
	level.scr_anim[ "sat_board_panel" ][ "sat_board_handoff" ] = %factory_SATroom_pullout_Board_handoff_pannel;
	level.scr_model[ "sat_board_panel" ] = "factory_satroom_access_pannel";	
	*/
	// assembly line door
	level.scr_animtree[ "assembly_floor_door" ]									  = #animtree;
	level.scr_anim[ "assembly_floor_door" ][ "factory_assembly_floor_open_door" ] = %factory_assembly_floor_open_door_door;
	level.scr_model[ "assembly_floor_door" ]									  = "factory_assembly_room_door";

	//automated assembly line
	level.scr_animtree[ "front_moving_piece" ]							 = #animtree;
	level.scr_anim[ "front_moving_piece" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_piece;
	level.scr_model[ "front_moving_piece" ]								 = "factory_assembly_moving_front_piece";
	
	level.scr_animtree[ "front_moving_piece_belt" ]							  = #animtree;
	level.scr_anim[ "front_moving_piece_belt" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_piece;
	level.scr_model[ "front_moving_piece_belt" ]							  = "factory_assembly_moving_front_belt";
	
							 //   animname 			    notetrack 			      function 				   
	addNotetrack_customFunction( "front_moving_piece", "front_station_01_start", ::front_station_start_01 );
	addNotetrack_customFunction( "front_moving_piece", "front_station_02_start", ::front_station_start_02 );
	addNotetrack_customFunction( "front_moving_piece", "front_station_03_start", ::front_station_start_03 );
	addNotetrack_customFunction( "front_moving_piece", "front_station_04_start", ::front_station_start_04 );
	addNotetrack_customFunction( "front_moving_piece", "front_station_05_start", ::front_station_start_05 );
	addNotetrack_customFunction( "front_moving_piece", "front_station_06_start", ::front_station_start_06 );
//	addNotetrack_customFunction( "front_moving_piece", "fx_ambush_piece_start", maps\factory_fx::fx_ambush_piece_start );
//	addNotetrack_customFunction( "front_moving_piece", "fx_ambush_piece_stop" , maps\factory_fx::fx_ambush_piece_stop );
	addNotetrack_startFXonTag( "front_moving_piece", "fx_ambush_piece_start", undefined, "factory_moving_piece_light", "j_anim_jnt_main_piston_arm_btm" );
	addNotetrack_stopFXonTag( "front_moving_piece", "fx_ambush_piece_stop", undefined, "factory_moving_piece_light", "j_anim_jnt_main_piston_arm_btm" );
	
	level.scr_animtree[ "back_moving_piece" ]							= #animtree;
	level.scr_anim[ "back_moving_piece" ][ "automated_assemebly_line" ] = %factory_assembly_line_back_piece;
	level.scr_model[ "back_moving_piece" ]								= "factory_assembly_moving_back_piece";
							 //   animname 			   notetrack 					   function 			   
	addNotetrack_customFunction( "back_moving_piece", "back_station_01_start"		, ::back_station_start_01 );
	addNotetrack_customFunction( "back_moving_piece", "back_station_02_start"		, ::back_station_start_02 );
	addNotetrack_customFunction( "back_moving_piece", "back_station_03_start"		, ::back_station_start_03 );
	addNotetrack_customFunction( "back_moving_piece", "back_station_04_start"		, ::back_station_start_04 );
	addNotetrack_customFunction( "back_moving_piece", "back_station_05_start"		, ::back_station_start_05 );
	addNotetrack_customFunction( "back_moving_piece", "back_station_turn_rail_track", ::back_turn_rail_track );

	// 1a
	level.scr_animtree[ "factory_assembly_line_front_station01_arm_a" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station01_arm_a" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station01_arm_A;
	level.scr_model[ "factory_assembly_line_front_station01_arm_a" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station01_arm_a", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station01_arm_a", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 1b
	level.scr_animtree[ "factory_assembly_line_front_station01_arm_b" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station01_arm_b" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station01_arm_B;
	level.scr_model[ "factory_assembly_line_front_station01_arm_b" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station01_arm_b", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station01_arm_b", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );
	
	// 2a
	level.scr_animtree[ "factory_assembly_line_front_station02_arm_a" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station02_arm_a" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station02_arm_A;
	level.scr_model[ "factory_assembly_line_front_station02_arm_a" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_a", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_a", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 2b
	level.scr_animtree[ "factory_assembly_line_front_station02_arm_b" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station02_arm_b" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station02_arm_B;
	level.scr_model[ "factory_assembly_line_front_station02_arm_b" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_b", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_b", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 2c
	level.scr_animtree[ "factory_assembly_line_front_station02_arm_c" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station02_arm_c" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station02_arm_C;
	level.scr_model[ "factory_assembly_line_front_station02_arm_c" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_c", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_c", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 2d
	level.scr_animtree[ "factory_assembly_line_front_station02_arm_d" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station02_arm_d" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station02_arm_D;
	level.scr_model[ "factory_assembly_line_front_station02_arm_d" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_d", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station02_arm_d", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 3a
	level.scr_animtree[ "factory_assembly_line_front_station03_arm_a" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station03_arm_a" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station03_arm_A;
	level.scr_model[ "factory_assembly_line_front_station03_arm_a" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_a", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_a", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 3b
	level.scr_animtree[ "factory_assembly_line_front_station03_arm_b" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station03_arm_b" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station03_arm_B;
	level.scr_model[ "factory_assembly_line_front_station03_arm_b" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_b", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_b", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );
	
	// 3c
	level.scr_animtree[ "factory_assembly_line_front_station03_arm_c" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station03_arm_c" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station03_arm_C;
	level.scr_model[ "factory_assembly_line_front_station03_arm_c" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_c", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_c", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );
	
	// 3d
	level.scr_animtree[ "factory_assembly_line_front_station03_arm_d" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station03_arm_d" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station03_arm_D;
	level.scr_model[ "factory_assembly_line_front_station03_arm_d" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_d", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station03_arm_d", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 4a
	level.scr_animtree[ "factory_assembly_line_front_station04_arm_a" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station04_arm_a" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station04_arm_A;						 
	level.scr_model[ "factory_assembly_line_front_station04_arm_a" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station04_arm_a", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station04_arm_a", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 4b
	level.scr_animtree[ "factory_assembly_line_front_station04_arm_b" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station04_arm_b" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station04_arm_B;						 
	level.scr_model[ "factory_assembly_line_front_station04_arm_b" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station04_arm_b", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station04_arm_b", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 4c
	level.scr_animtree[ "factory_assembly_line_front_station04_arm_c" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station04_arm_c" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station04_arm_C;								 
	level.scr_model[ "factory_assembly_line_front_station04_arm_c" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station04_arm_c", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station04_arm_c", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 5a
	level.scr_animtree[ "factory_assembly_line_front_station05_arm_a" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station05_arm_a" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station05_arm_A;								 
	level.scr_model[ "factory_assembly_line_front_station05_arm_a" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station05_arm_a", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station05_arm_a", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 5b
	level.scr_animtree[ "factory_assembly_line_front_station05_arm_b" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station05_arm_b" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station05_arm_B;							 
	level.scr_model[ "factory_assembly_line_front_station05_arm_b" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station05_arm_b", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station05_arm_b", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );
	
	// 5c
	level.scr_animtree[ "factory_assembly_line_front_station05_arm_c" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station05_arm_c" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station05_arm_C;								 
	level.scr_model[ "factory_assembly_line_front_station05_arm_c" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station05_arm_c", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station05_arm_c", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );
	
	// 6a
	level.scr_animtree[ "factory_assembly_line_front_station06_arm_a" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station06_arm_a" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station06_arm_A;							 
	level.scr_model[ "factory_assembly_line_front_station06_arm_a" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station06_arm_a", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station06_arm_a", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// 6b
	level.scr_animtree[ "factory_assembly_line_front_station06_arm_b" ]							  = #animtree;
	level.scr_anim[ "factory_assembly_line_front_station06_arm_b" ][ "automated_assemebly_line" ] = %factory_assembly_line_front_station06_arm_B;							 
	level.scr_model[ "factory_assembly_line_front_station06_arm_b" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_front_station06_arm_b", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_front_station06_arm_b", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// b1
	level.scr_animtree[ "factory_assembly_line_back_station01" ]						   = #animtree;
	level.scr_anim[ "factory_assembly_line_back_station01" ][ "automated_assemebly_line" ] = %factory_assembly_line_back_station01;
	level.scr_model[ "factory_assembly_line_back_station01" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_back_station01", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_back_station01", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// b2
	level.scr_animtree[ "factory_assembly_line_back_station02" ]						   = #animtree;
	level.scr_anim[ "factory_assembly_line_back_station02" ][ "automated_assemebly_line" ] = %factory_assembly_line_back_station02;
	level.scr_model[ "factory_assembly_line_back_station02" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_back_station02", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_back_station02", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// b3
	level.scr_animtree[ "factory_assembly_line_back_station03" ]						   = #animtree;
	level.scr_anim[ "factory_assembly_line_back_station03" ][ "automated_assemebly_line" ] = %factory_assembly_line_back_station03;							  
	level.scr_model[ "factory_assembly_line_back_station03" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_back_station03", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_back_station03", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// b4
	level.scr_animtree[ "factory_assembly_line_back_station04" ]						   = #animtree;
	level.scr_anim[ "factory_assembly_line_back_station04" ][ "automated_assemebly_line" ] = %factory_assembly_line_back_station04;							  
	level.scr_model[ "factory_assembly_line_back_station04" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_back_station04", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_back_station04", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );

	// b5
	level.scr_animtree[ "factory_assembly_line_back_station05" ]						   = #animtree;
	level.scr_anim[ "factory_assembly_line_back_station05" ][ "automated_assemebly_line" ] = %factory_assembly_line_back_station05;								  
	level.scr_model[ "factory_assembly_line_back_station05" ] = "factory_assembly_automated_arm";
	addNotetrack_customFunction( "factory_assembly_line_back_station05", "fx_ambush_welding_start", maps\factory_fx::fx_ambush_welding_start );
	addNotetrack_customFunction( "factory_assembly_line_back_station05", "fx_ambush_welding_stop" , maps\factory_fx::fx_ambush_welding_stop );
	
	level.scr_animtree[ "factory_assembly_line_back_turn_rail_track" ]							 = #animtree;
	level.scr_anim[ "factory_assembly_line_back_turn_rail_track" ][ "automated_assemebly_line" ] = %factory_assembly_line_back_turn_rail_track;
	level.scr_model[ "factory_assembly_line_back_turn_rail_track" ] = "factory_back_turn_rail_track";
	
	// Assembly line arm malfunction
	level.scr_animtree[ "factory_assembly_line_arm_malfunction" ]						= #animtree;
	level.scr_anim[ "factory_assembly_line_arm_malfunction" ][ "arm_malfunction" ][ 0 ] = %factory_assembly_automated_arm_malfunction_loop;
	level.scr_model[ "factory_assembly_line_arm_malfunction" ]							= "factory_assembly_automated_arm_damaged";


	//Ambush desk search
	level.scr_animtree[ "desk_chair" ]							 = #animtree;
	level.scr_anim[ "desk_chair" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_chair;
	level.scr_model[ "desk_chair" ]								 = "fac_ambush_desk_search_chair";

	level.scr_animtree[ "desk_phone" ]							 = #animtree;
	level.scr_anim[ "desk_phone" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_phone;
	level.scr_model[ "desk_phone" ]								 = "fac_ambush_desk_search_phone";

	level.scr_animtree[ "desk_trash_can" ]							 = #animtree;
	level.scr_anim[ "desk_trash_can" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_trash_can;
	level.scr_model[ "desk_trash_can" ]								 = "fac_trash_bin";

	level.scr_animtree[ "desk_book01" ]							  = #animtree;
	level.scr_anim[ "desk_book01" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_book01;
	level.scr_model[ "desk_book01" ]							  = "com_office_book_black_standing";

	level.scr_animtree[ "desk_book02" ]							  = #animtree;
	level.scr_anim[ "desk_book02" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_book02;
	level.scr_model[ "desk_book02" ]							  = "com_office_book_blue_standing";

	level.scr_animtree[ "desk_book03" ]							  = #animtree;
	level.scr_anim[ "desk_book03" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_book03;
	level.scr_model[ "desk_book03" ]							  = "com_office_book_black_standing";

	level.scr_animtree[ "desk_book04" ]							  = #animtree;
	level.scr_anim[ "desk_book04" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_book04;
	level.scr_model[ "desk_book04" ]							  = "com_office_book_red_flat";

	level.scr_animtree[ "desk_book05" ]							  = #animtree;
	level.scr_anim[ "desk_book05" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_book05;
	level.scr_model[ "desk_book05" ]							  = "com_office_book_black_standing";

	level.scr_animtree[ "desk_book06" ]							  = #animtree;
	level.scr_anim[ "desk_book06" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_book06;
	level.scr_model[ "desk_book06" ]							  = "com_office_book_red_flat";

	level.scr_animtree[ "desk_book07" ]							  = #animtree;
	level.scr_anim[ "desk_book07" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_book07;
	level.scr_model[ "desk_book07" ]							  = "com_office_book_blue_standing";

	level.scr_animtree[ "desk_keyboard" ]							= #animtree;
	level.scr_anim[ "desk_keyboard" ][ "ambush_bravo_desk_search" ] = %factory_ambush_desk_search_keyboard;
	level.scr_model[ "desk_keyboard" ]								= "fac_keyboard";
	
	//ambush
	level.scr_animtree[ "factory_ambush_usb_stick" ]			   = #animtree;
	level.scr_anim[ "factory_ambush_usb_stick" ][ "ambush_props" ] = %factory_ambush_usb_stick;
	level.scr_model[ "factory_ambush_usb_stick" ]				   = "factory_ambush_usb_stick";

	level.scr_animtree[ "factory_ambush_door" ]				  = #animtree;
	level.scr_anim[ "factory_ambush_door" ][ "ambush_props" ] = %factory_ambush_door;
	level.scr_model[ "factory_ambush_door" ]				  = "factory_ambush_door";
	
	level.scr_animtree[ "factory_ambush_desk" ]				  = #animtree;
	level.scr_anim[ "factory_ambush_desk" ][ "ambush_props" ] = %factory_ambush_desk;
	level.scr_model[ "factory_ambush_desk" ]				  = "factory_ambush_desk";
	
	level.scr_animtree[ "factory_ambush_monitor01" ]			   = #animtree;
	level.scr_anim[ "factory_ambush_monitor01" ][ "ambush_props" ] = %factory_ambush_comp_monitor_01;
	level.scr_model[ "factory_ambush_monitor01" ]				   = "factory_ambush_monitor";

	level.scr_animtree[ "factory_ambush_monitor02" ]			   = #animtree;
	level.scr_anim[ "factory_ambush_monitor02" ][ "ambush_props" ] = %factory_ambush_comp_monitor_02;
	level.scr_model[ "factory_ambush_monitor02" ]				   = "com_pc_monitor_a";

	level.scr_animtree[ "factory_ambush_mouse01" ]				 = #animtree;
	level.scr_anim[ "factory_ambush_mouse01" ][ "ambush_props" ] = %factory_ambush_comp_mouse_01;
	level.scr_model[ "factory_ambush_mouse01" ]					 = "plastic_computer_mouse_01";

	level.scr_animtree[ "factory_ambush_mouse02" ]				 = #animtree;
	level.scr_anim[ "factory_ambush_mouse02" ][ "ambush_props" ] = %factory_ambush_comp_mouse_02;
	level.scr_model[ "factory_ambush_mouse02" ]					 = "plastic_computer_mouse_01";
	
	level.scr_animtree[ "factory_ambush_keyboard01" ]				= #animtree;
	level.scr_anim[ "factory_ambush_keyboard01" ][ "ambush_props" ] = %factory_ambush_comp_keyboard_01;
	level.scr_model[ "factory_ambush_keyboard01" ]					= "fac_keyboard";
	
	level.scr_animtree[ "factory_ambush_keyboard02" ]				= #animtree;
	level.scr_anim[ "factory_ambush_keyboard02" ][ "ambush_props" ] = %factory_ambush_comp_keyboard_02;
	level.scr_model[ "factory_ambush_keyboard02" ]					= "fac_keyboard";
	
	level.scr_animtree[ "factory_ambush_clipboard" ]			   = #animtree;
	level.scr_anim[ "factory_ambush_clipboard" ][ "ambush_props" ] = %factory_ambush_clipboard;
	level.scr_model[ "factory_ambush_clipboard" ]				   = "com_clipboard_wpaper";
	
	level.scr_animtree[ "factory_ambush_cup" ]				 = #animtree;
	level.scr_anim[ "factory_ambush_cup" ][ "ambush_props" ] = %factory_ambush_cup;
	level.scr_model[ "factory_ambush_cup" ]					 = "fac_coffee_cup";
	
	level.scr_animtree[ "factory_ambush_computer" ]				  = #animtree;
	level.scr_anim[ "factory_ambush_computer" ][ "ambush_props" ] = %factory_ambush_computer_01;
	level.scr_model[ "factory_ambush_computer" ]				  = "fac_io_device";
	
	level.scr_animtree[ "factory_ambush_tv" ]				= #animtree;
	level.scr_anim[ "factory_ambush_tv" ][ "ambush_props" ] = %factory_ambush_TV_debris;
	level.scr_model[ "factory_ambush_tv" ]					= "tv_flatscreen_large";
	
	level.scr_animtree[ "factory_ambush_airduct_01" ]				= #animtree;
	level.scr_anim[ "factory_ambush_airduct_01" ][ "ambush_props" ] = %factory_ambush_airduct_01;
	level.scr_model[ "factory_ambush_airduct_01" ]					= "com_airduct_150x_square";
	
	level.scr_animtree[ "factory_ambush_airduct_02" ]				= #animtree;
	level.scr_anim[ "factory_ambush_airduct_02" ][ "ambush_props" ] = %factory_ambush_airduct_02;
	level.scr_model[ "factory_ambush_airduct_02" ]					= "com_airduct_150x_square";
	
	level.scr_animtree[ "factory_ambush_wall_debris" ]				 = #animtree;
	level.scr_anim[ "factory_ambush_wall_debris" ][ "ambush_props" ] = %factory_ambush_wall_debris;
	level.scr_model[ "factory_ambush_wall_debris" ]					 = "factory_ambush_wall_debris";

	level.scr_animtree[ "factory_ambush_ceiling_cables_01" ]			   = #animtree;
	level.scr_anim[ "factory_ambush_ceiling_cables_01" ][ "ambush_props" ] = %factory_ambush_ceiling_cables_01;
	level.scr_model[ "factory_ambush_ceiling_cables_01" ]				   = "factory_ambush_ceiling_cables";
	
	level.scr_animtree[ "factory_ambush_ceiling_cables_02" ]			   = #animtree;
	level.scr_anim[ "factory_ambush_ceiling_cables_02" ][ "ambush_props" ] = %factory_ambush_ceiling_cables_02;
	level.scr_model[ "factory_ambush_ceiling_cables_02" ]				   = "factory_ambush_ceiling_cables";
	
	level.scr_animtree[ "factory_ambush_ceiling_cables_03" ]			   = #animtree;
	level.scr_anim[ "factory_ambush_ceiling_cables_03" ][ "ambush_props" ] = %factory_ambush_ceiling_cables_03;
	level.scr_model[ "factory_ambush_ceiling_cables_03" ]				   = "factory_ambush_ceiling_cables";
	
	// Ambush fastroper ROPE anim
	level.scr_anim[ "rope" ][ "bravo_rappel_drop" ] = %berlin_granite_team_rappel_drop_rope;
	
	//Rooftop Door Breach
	
	level.scr_animtree[ "rooftop_breach_door" ]					= #animtree;
	level.scr_anim[ "rooftop_breach_door" ][ "rooftop_breach" ] = %factory_longest_50_intro_door_breach_door;
	
	//car chase
	
	level.scr_animtree[ "factory_car_chase_intro_broken_awning01" ]							= #animtree;
	level.scr_anim[ "factory_car_chase_intro_broken_awning01" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_broken_awning01;
	level.scr_model[ "factory_car_chase_intro_broken_awning01" ]								= "factory_car_chase_intro_broken_awning01";
	
	level.scr_animtree[ "factory_car_chase_intro_broken_awning02" ]							= #animtree;
	level.scr_anim[ "factory_car_chase_intro_broken_awning02" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_broken_awning02;
	level.scr_model[ "factory_car_chase_intro_broken_awning02" ]								= "factory_car_chase_intro_broken_awning02";
	
	level.scr_animtree[ "factory_car_chase_intro_broken_awning03" ]							= #animtree;
	level.scr_anim[ "factory_car_chase_intro_broken_awning03" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_broken_awning03;
	level.scr_model[ "factory_car_chase_intro_broken_awning03" ]								= "factory_car_chase_intro_broken_awning03";
	
	level.scr_animtree[ "factory_car_chase_intro_broken_awning04" ]							= #animtree;
	level.scr_anim[ "factory_car_chase_intro_broken_awning04" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_broken_awning04;
	level.scr_model[ "factory_car_chase_intro_broken_awning04" ]								= "factory_car_chase_intro_broken_awning04";
	
	level.scr_animtree[ "factory_car_chase_intro_broken_fence01" ]							= #animtree;
	level.scr_anim[ "factory_car_chase_intro_broken_fence01" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_broken_fence01;
	level.scr_model[ "factory_car_chase_intro_broken_fence01" ]								= "factory_car_chase_intro_broken_fence";
	
	level.scr_animtree[ "factory_car_chase_intro_broken_fence02" ]							= #animtree;
	level.scr_anim[ "factory_car_chase_intro_broken_fence02" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_broken_fence02;
	level.scr_model[ "factory_car_chase_intro_broken_fence02" ]								= "factory_car_chase_intro_broken_fence";
	
	level.scr_animtree[ "factory_car_chase_intro_broken_light_post" ]							= #animtree;
	level.scr_anim[ "factory_car_chase_intro_broken_light_post" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_broken_light_post;
	level.scr_model[ "factory_car_chase_intro_broken_light_post" ]								= "factory_car_chase_intro_broken_light_post";
	
	level.scr_animtree[ "factory_car_chase_smokestack_01" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_smokestack_01" ][ "factory_car_chase" ] = %factory_car_chase_smokestack_01;
	level.scr_model[ "factory_car_chase_smokestack_01" ]					   = "factory_car_chase_smokestack_large";
	addNotetrack_customFunction( "factory_car_chase_smokestack_01", "fx_chase_stack_small_break", maps\factory_fx::fx_chase_stack_small_break );
	
	level.scr_animtree[ "factory_car_chase_smokestack_02" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_smokestack_02" ][ "factory_car_chase" ] = %factory_car_chase_smokestack_02;
	level.scr_model[ "factory_car_chase_smokestack_02" ]					   = "factory_car_chase_smokestack_large";
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_break_01", maps\factory_fx::fx_chase_stack_break_01 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_break_02", maps\factory_fx::fx_chase_stack_break_02 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_027", maps\factory_fx::fx_chase_stack_piece_027 );
//	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_030", maps\factory_fx::fx_chase_stack_piece_030 );
//	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_034", maps\factory_fx::fx_chase_stack_piece_034 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_037", maps\factory_fx::fx_chase_stack_piece_037 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_039", maps\factory_fx::fx_chase_stack_piece_039 );
//	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_041", maps\factory_fx::fx_chase_stack_piece_041 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_042", maps\factory_fx::fx_chase_stack_piece_042 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_007", maps\factory_fx::fx_chase_stack_piece_007 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_008", maps\factory_fx::fx_chase_stack_piece_008 );
	addNotetrack_customFunction( "factory_car_chase_smokestack_02", "fx_chase_stack_piece_017", maps\factory_fx::fx_chase_stack_piece_017 );
		
	level.scr_animtree[ "factory_car_chase_building_corner_break_00" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_corner_break_00" ][ "factory_car_chase" ] = %factory_car_chase_building_corner_break_00;
	level.scr_model[ "factory_car_chase_building_corner_break_00" ]						= "factory_car_chase_building_corner_break_00";
	
	level.scr_animtree[ "factory_car_chase_building_corner_break_01" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_corner_break_01" ][ "factory_car_chase" ] = %factory_car_chase_building_corner_break_01;
	level.scr_model[ "factory_car_chase_building_corner_break_01" ]						= "factory_car_chase_building_corner_break_01";
	
	level.scr_animtree[ "factory_car_chase_building_corner_break_02" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_corner_break_02" ][ "factory_car_chase" ] = %factory_car_chase_building_corner_break_02;
	level.scr_model[ "factory_car_chase_building_corner_break_02" ]						= "factory_car_chase_building_corner_break_02";
	
	level.scr_animtree[ "factory_boxes_and_shvelves_01" ]					= #animtree;
	level.scr_anim[ "factory_boxes_and_shvelves_01" ][ "factory_car_chase" ] = %factory_car_chase_boxes_n_shelves_01;
	level.scr_model[ "factory_boxes_and_shvelves_01" ]						= "factory_boxes_and_shvelves_01";
	
	level.scr_animtree[ "factory_boxes_and_shvelves_02" ]					= #animtree;
	level.scr_anim[ "factory_boxes_and_shvelves_02" ][ "factory_car_chase" ] = %factory_car_chase_boxes_n_shelves_02;
	level.scr_model[ "factory_boxes_and_shvelves_02" ]						= "factory_boxes_and_shvelves_02";
	
	level.scr_animtree[ "factory_car_chase_warehouse_facade0" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_warehouse_facade0" ][ "factory_car_chase" ] = %factory_car_chase_warehouse_facade0;
	level.scr_model[ "factory_car_chase_warehouse_facade0" ]						= "factory_car_chase_warehouse_facade0";
	
	level.scr_animtree[ "factory_car_chase_warehouse_facade1" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_warehouse_facade1" ][ "factory_car_chase" ] = %factory_car_chase_warehouse_facade1;
	level.scr_model[ "factory_car_chase_warehouse_facade1" ]						= "factory_car_chase_warehouse_facade1";
	
	level.scr_animtree[ "factory_car_chase_warehouse_top" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_warehouse_top" ][ "factory_car_chase" ] = %factory_car_chase_warehouse_top;
	level.scr_model[ "factory_car_chase_warehouse_top" ]						= "factory_car_chase_warehouse_top";
	
	level.scr_animtree[ "factory_car_chase_pipes" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_pipes" ][ "factory_car_chase" ] = %factory_car_chase_pipes;
	level.scr_model[ "factory_car_chase_pipes" ]						= "fac_car_chase_pipes_01";
	
	level.scr_animtree[ "factory_car_chase_skybridge_01" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_skybridge_01" ][ "factory_car_chase" ] = %factory_car_chase_skybridge_01;
	level.scr_model[ "factory_car_chase_skybridge_01" ]						= "fac_skybridge_01";
	
	level.scr_animtree[ "factory_car_chase_skybridge_02" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_skybridge_02" ][ "factory_car_chase" ] = %factory_car_chase_skybridge_02;
	level.scr_model[ "factory_car_chase_skybridge_02" ]						= "fac_skybridge_01";
	
	level.scr_animtree[ "factory_car_chase_smokestack_wall_01" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_smokestack_wall_01" ][ "factory_car_chase" ] = %factory_car_chase_smokestack_wall_01;
	level.scr_model[ "factory_car_chase_smokestack_wall_01" ]						= "fac_smokestack_wall0";
	
	level.scr_animtree[ "factory_car_chase_smokestack_wall_02" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_smokestack_wall_02" ][ "factory_car_chase" ] = %factory_car_chase_smokestack_wall_02;
	level.scr_model[ "factory_car_chase_smokestack_wall_02" ]						= "fac_smokestack_wall1";
	
	level.scr_animtree[ "factory_car_chase_building_facade_01" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_01" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_01;
	level.scr_model[ "factory_car_chase_building_facade_01" ]						= "factory_car_chase_building_facade_01";
	
	level.scr_animtree[ "factory_car_chase_building_facade_02" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_02" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_02;
	level.scr_model[ "factory_car_chase_building_facade_02" ]						= "factory_car_chase_building_facade_02";
	
	level.scr_animtree[ "factory_car_chase_building_facade_03" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_03" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_03;
	level.scr_model[ "factory_car_chase_building_facade_03" ]						= "factory_car_chase_building_facade_03";
	
	level.scr_animtree[ "factory_car_chase_building_facade_04" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_04" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_04;
	level.scr_model[ "factory_car_chase_building_facade_04" ]						= "factory_car_chase_building_facade_04";
	
	level.scr_animtree[ "factory_car_chase_building_facade_05" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_05" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_05;
	level.scr_model[ "factory_car_chase_building_facade_05" ]						= "factory_car_chase_building_facade_05";
	
	level.scr_animtree[ "factory_car_chase_building_facade_06" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_06" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_06;
	level.scr_model[ "factory_car_chase_building_facade_06" ]						= "factory_car_chase_building_facade_06";
	
	level.scr_animtree[ "factory_car_chase_building_facade_07" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_07" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_07;
	level.scr_model[ "factory_car_chase_building_facade_07" ]						= "factory_car_chase_building_facade_01";
	
	level.scr_animtree[ "factory_car_chase_building_facade_08" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_08" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_08;
	level.scr_model[ "factory_car_chase_building_facade_08" ]						= "factory_car_chase_building_facade_02";
	
	level.scr_animtree[ "factory_car_chase_building_facade_09" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_09" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_09;
	level.scr_model[ "factory_car_chase_building_facade_09" ]						= "factory_car_chase_building_facade_03";
	
	level.scr_animtree[ "factory_car_chase_building_facade_10" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_10" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_10;
	level.scr_model[ "factory_car_chase_building_facade_10" ]						= "factory_car_chase_building_facade_04";
	
	level.scr_animtree[ "factory_car_chase_building_facade_11" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_11" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_11;
	level.scr_model[ "factory_car_chase_building_facade_11" ]						= "factory_car_chase_building_facade_05";
	
	level.scr_animtree[ "factory_car_chase_building_facade_12" ]					= #animtree;
	level.scr_anim[ "factory_car_chase_building_facade_12" ][ "factory_car_chase" ] = %factory_car_chase_building_facade_12;
	level.scr_model[ "factory_car_chase_building_facade_12" ]						= "factory_car_chase_building_facade_06";
	
}

#using_animtree( "player" );
player()
{
	// Intro_jungle_kill
	level.scr_animtree[ "player_rig" ]								= #animtree;
	level.scr_anim[ "player_rig" ][ "factory_intro_jungle_drop_player" ] = %factory_intro_jungle_drop_player;
	level.scr_model[ "player_rig" ]									= "viewhands_player_us_army";

	level.scr_animtree[ "player_rig" ]								= #animtree;
	level.scr_anim[ "player_rig" ][ "factory_intro_jungle_drop_kill_player" ] = %factory_intro_jungle_drop_kill_player;
	level.scr_model[ "player_rig" ]									= "viewhands_player_us_army";

	// Intro_jungle
	level.scr_animtree[ "player_rig" ]								= #animtree;
	level.scr_anim[ "player_rig" ][ "factory_intro_jungle_player" ] = %factory_intro_jungle_player;
	level.scr_model[ "player_rig" ]									= "viewhands_player_us_army";
	
	// Intro_jungle_slide
	/*
	level.scr_animtree[ "player_rig" ]									  = #animtree;
	level.scr_anim[ "player_rig" ][ "factory_intro_jungle_slide_player" ] = %factory_intro_jungle_slide_player;
	level.scr_model[ "player_rig" ]										  = "viewhands_player_us_army";
	*/
	
	// Intro
	level.scr_animtree[ "player_rig" ]				  = #animtree;
	level.scr_anim[ "player_rig" ][ "factory_intro" ] = %factory_intro_player;
	level.scr_model[ "player_rig" ]					  = "viewhands_player_us_army";
	// addNotetrack_customFunction( "player_rig", "notetrack_unlink_player", maps\factory_powerstealth::unlink_player_from_intro_vignette );

	level.scr_animtree[ "player_rig" ]								= #animtree;
	level.scr_anim[ "player_rig" ][ "factory_opfor_trainyard_melee_death" ] = %factory_opfor_trainyard_melee_death_player;
	level.scr_model[ "player_rig" ]									= "viewhands_player_us_army";
	
	// Powerstealth
	level.scr_anim[ "player_rig" ][ "throat_stab" ] 						= %factory_power_stealth_player_console_melee_death;
	addNotetrack_customFunction( "player_rig", "knife_in", ::throat_stab_player );
	
	// SAT Room interactions
	/*
	level.scr_anim[ "player_rig" ][ "sat_board_start" ]		= %factory_SATroom_pullout_Board_start_player;
	level.scr_anim[ "player_rig" ][ "sat_board_knife" ][ 0 ] = %factory_SATroom_pullout_Board_knife_idle_player;
	level.scr_anim[ "player_rig" ][ "sat_board_pulloff" ] 	= %factory_SATroom_pullout_Board_pulloff_player;
	level.scr_anim[ "player_rig" ][ "sat_board_look" ][ 0 ] = %factory_SATroom_pullout_Board_look_loop_player;
	level.scr_anim[ "player_rig" ][ "sat_board_grab" ]		= %factory_SATroom_pullout_Board_grab_player;
	level.scr_anim[ "player_rig" ][ "sat_board_pull" ]		= %factory_SATroom_pullout_Board_pull_player;
	level.scr_anim[ "player_rig" ][ "sat_board_dismount" ]	= %factory_SATroom_pullout_Board_dismount_player;
	level.scr_anim[ "player_rig" ][ "sat_board_hold" ][ 0 ] = %factory_SATroom_pullout_Board_hold_loop_player;
	level.scr_anim[ "player_rig" ][ "sat_board_flip" ]		= %factory_SATroom_pullout_Board_flip_player;
	level.scr_anim[ "player_rig" ][ "sat_board_handoff" ]	= %factory_SATroom_pullout_Board_handoff_player;
	*/
	//Ambush
	level.scr_animtree[ "player_rig" ]				  = #animtree;
	level.scr_anim[ "player_rig" ][ "ambush_player" ] = %factory_player_ambush;
	level.scr_model[ "player_rig" ]					  = "viewhands_player_us_army";
							 //   animname 	    notetrack 			      function 										  
	addNotetrack_customFunction( "player_rig", "fxn_monitor_bink_start", maps\factory_fx::fx_assembly_monitor_bink_start );
	addNotetrack_customFunction( "player_rig", "fxn_monitor_error"	   , maps\factory_fx::fx_assembly_ally_monitor_error );
	addNotetrack_customFunction( "player_rig", "fxn_ceiling_cables"	   , maps\factory_fx::fx_assembly_ceiling_cables );
	addNotetrack_customFunction( "player_rig", "start_ambush_fx"	   , ::ambush_notify_start_fx );
	addNotetrack_customFunction( "player_rig", "start_ambush_slowmo"   , ::ambush_notify_start_slomo );
	addNotetrack_customFunction( "player_rig", "glass_break"		   , ::ambush_notify_glass_break );
	
	level.scr_anim[ "player_rig" ][ "factory_car_chase_intro_ally_pulls_up_player" ] = %factory_car_chase_intro_ally_pulls_up_player_player;
	addNotetrack_customFunction( "player_rig", "player_switch", ::chase_pull_up_notify_switch );
	
	level.scr_anim[ "player_rig" ][ "factory_car_chase_player_knock_down_01" ] = %factory_car_chase_player_knock_down_01;
	level.scr_anim[ "player_rig" ][ "factory_car_chase_player_knock_down_02" ] = %factory_car_chase_player_knock_down_02;
	level.scr_anim[ "player_rig" ][ "factory_car_chase_player_knock_down_03" ] = %factory_car_chase_player_knock_down_03;
}

#using_animtree( "vehicles" );
vehicles()
{
	
	// intro truck
	level.scr_animtree[ "het_cab" ]										  = #animtree;
	level.scr_anim[ "het_cab"	  ][ "factory_truck_entrance" ] = %factory_truck_cab;
	level.scr_model[ "het_cab" ]											  = "vehicle_mobile_railgun_cab";
		
	level.scr_animtree[ "het_trailer" ]										  = #animtree;
	level.scr_anim[ "het_trailer" ][ "factory_truck_entrance" ] = %factory_truck_trailer;
	level.scr_model[ "het_trailer" ]											  = "vehicle_mobile_railgun_trailer";
	
	// intro_chopper for intro sequence
	level.scr_animtree[ "intro_chopper" ]										  = #animtree;
	level.scr_anim[ "intro_chopper" ][ "factory_intro_jungle_spotlight_chopper" ] = %factory_intro_jungle_spotlight_chopper;
	level.scr_model[ "intro_chopper" ]											  = "vehicle_nh90";
	
	level.scr_animtree[ "factory_car_chase_intro_ally_pulls_up_player_b201" ]										  = #animtree;
	level.scr_anim[ "factory_car_chase_intro_ally_pulls_up_player_b201" ][ "factory_car_chase_intro_ally_pulls_up_player" ] = %factory_car_chase_intro_ally_pulls_up_player_b201;
	level.scr_model[ "factory_car_chase_intro_ally_pulls_up_player_b201" ]											  = "vehicle_b2_bomber";
	
	level.scr_animtree[ "factory_car_chase_intro_ally_pulls_up_player_b202" ]										  = #animtree;
	level.scr_anim[ "factory_car_chase_intro_ally_pulls_up_player_b202" ][ "factory_car_chase_intro_ally_pulls_up_player" ] = %factory_car_chase_intro_ally_pulls_up_player_b202;
	level.scr_model[ "factory_car_chase_intro_ally_pulls_up_player_b202" ]											  = "vehicle_b2_bomber";
	
	level.scr_animtree[ "factory_car_chase_intro_ally_pulls_up_player_b203" ]										  = #animtree;
	level.scr_anim[ "factory_car_chase_intro_ally_pulls_up_player_b203" ][ "factory_car_chase_intro_ally_pulls_up_player" ] = %factory_car_chase_intro_ally_pulls_up_player_b203;
	level.scr_model[ "factory_car_chase_intro_ally_pulls_up_player_b203" ]											  = "vehicle_b2_bomber";
	
	//car_chase Intro
	level.scr_anim[ "first_opfor_car"		 ][ "car_chase_intro_pullup" ] = %factory_car_chase_intro_first_car_pullup;
	level.scr_anim[ "second_opfor_car"		 ][ "car_chase_intro_pullup" ] = %factory_car_chase_intro_second_car_pullup;
	level.scr_anim[ "heavy_weapon_opfor_car" ][ "car_chase_intro_pullup" ] = %factory_car_chase_intro_heavy_vehicle_pullup;
	
	level.scr_anim[ "first_opfor_car"		 ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_first_car_crash;
	level.scr_anim[ "second_opfor_car"		 ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_second_car_crash;
	level.scr_anim[ "heavy_weapon_opfor_car" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_heavy_vehicle_crash;
	level.scr_anim[ "het_cab"				 ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_het_cab_crash;
	addNotetrack_customFunction( "het_cab", "fx_chase_box_explosions_start", maps\factory_fx::fx_chase_box_explosions_start );
	addNotetrack_customFunction( "het_cab" , "fx_chase_warehouse_explosion", maps\factory_fx::fx_chase_warehouse_explosion );
	
	level.scr_animtree[ "factory_car_chase_intro_side_car01_crash" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_intro_side_car01_crash" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_side_car01_crash;
	level.scr_anim[ "factory_car_chase_intro_side_car01_crash" ][ "factory_car_chase" ] = %factory_car_chase_intro_side_car01_blowup;
	level.scr_model[ "factory_car_chase_intro_side_car01_crash" ]					   = "vehicle_uk_utility_truck_static";
	
	level.scr_animtree[ "factory_car_chase_intro_side_car02_crash" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_intro_side_car02_crash" ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_side_car02_crash;
	level.scr_anim[ "factory_car_chase_intro_side_car02_crash" ][ "factory_car_chase" ] = %factory_car_chase_intro_side_car02_blowup;
	level.scr_model[ "factory_car_chase_intro_side_car02_crash" ]					   = "vehicle_uk_utility_truck_static";
	
	level.scr_animtree[ "factory_car_chase_intro_side_car03_blowup" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_intro_side_car03_blowup" ][ "factory_car_chase" ] = %factory_car_chase_intro_side_car03_blowup;
	level.scr_model[ "factory_car_chase_intro_side_car03_blowup" ]					   = "vehicle_uk_utility_truck_static";
	
	level.scr_anim[ "het_trailer"			 ][ "car_chase_intro_car_crash" ] = %factory_car_chase_intro_het_trailer_crash;
	addNotetrack_customFunction( "het_trailer", "fx_chase_het_tire_smoke", maps\factory_fx::fx_chase_het_tire_smoke );
	
	level.scr_anim[ "first_opfor_car"		 ][ "factory_car_chase" ] = %factory_car_chase_intro_first_car_blowup;
	level.scr_anim[ "second_opfor_car"		 ][ "factory_car_chase" ] = %factory_car_chase_intro_second_blowup;
	level.scr_anim[ "heavy_weapon_opfor_car" ][ "factory_car_chase" ] = %factory_car_chase_intro_heavy_car_blowup;
	
	level.scr_animtree[ "third_opfor_car" ]										  = #animtree;
	level.scr_anim[ "third_opfor_car" ][ "factory_car_chase" ] = %factory_car_chase_intro_third_car_blowup;
	level.scr_model[ "third_opfor_car" ]											  = "vehicle_iveco_lynx_iw6";
	
							 //   animname    notetrack     function 			
	addNotetrack_customFunction( "het_cab" , "start_mount"	 , ::chase_notify_start_mount );			  
	addNotetrack_customFunction( "het_cab" , "hit_gaz_01", ::chase_notify_hit_vehicle_1 );
	addNotetrack_customFunction( "het_cab" , "hit_gaz_02", ::chase_notify_hit_vehicle_2 );
	addNotetrack_customFunction( "het_cab" , "hit_btr"	 , ::chase_notify_hit_vehicle_3 );
	addNotetrack_customFunction( "het_cab" , "hit_awning"	 , ::chase_notify_hit_awning );
	addNotetrack_customFunction( "het_cab" , "hit_light_pole"	 , ::chase_notify_hit_light_pole );
	addNotetrack_customFunction( "het_cab" , "hit_hydrant"	 , ::chase_notify_hit_hydrant );
	addNotetrack_customFunction( "het_cab" , "get_on_01"	 , ::ally_01_mount_trailer );
	addNotetrack_customFunction( "het_cab" , "get_on_02"	 , ::ally_02_mount_trailer );
	addNotetrack_customFunction( "het_cab" , "get_on_03"	 , ::ally_03_mount_trailer );
	addNotetrack_customFunction( "het_cab" , "fx_exploder,chase_130"	 , ::chase_trailer_catch_fire );
	addNotetrack_customFunction( "het_cab" , "fx_exploder,chase_160"	 , ::chase_trailer_crate_destroyed );
	addNotetrack_customFunction( "het_cab" , "player_knock_03"	 , ::chase_player_knock_03 );
	addNotetrack_customFunction( "het_cab" , "slide_right"	 , ::slide_right );
	addNotetrack_customFunction( "het_cab" , "slide_left_quick"	 , ::slide_left_quick );
	addNotetrack_customFunction( "het_cab" , "slide_right_quick"	 , ::slide_right_quick );
	addNotetrack_customFunction( "het_cab" , "hard_left"	 , ::hard_left );
	
	level.scr_anim[ "het_cab"	  ][ "factory_car_chase" ] = %factory_car_chase_het_cab;
	level.scr_anim[ "het_trailer" ][ "factory_car_chase" ] = %factory_car_chase_het_trailer;
	
	level.scr_animtree[ "factory_car_chase_chopper02" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_chopper02" ][ "factory_car_chase" ] = %factory_car_chase_chopper02;
	level.scr_model[ "factory_car_chase_chopper02" ]					   = "vehicle_nh90";
	
	level.scr_animtree[ "factory_car_chase_chopper03" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_chopper03" ][ "factory_car_chase" ] = %factory_car_chase_chopper03;
	level.scr_model[ "factory_car_chase_chopper03" ]					   = "vehicle_nh90";
	
	level.scr_animtree[ "factory_car_chase_chopper04" ]					   = #animtree;
	level.scr_anim[ "factory_car_chase_chopper04" ][ "factory_car_chase" ] = %factory_car_chase_chopper04;
	level.scr_model[ "factory_car_chase_chopper04" ]					   = "vehicle_nh90";
	
	level.scr_animtree[ "factory_car_chase_opfor_car01" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car01" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car01;
	level.scr_model[ "factory_car_chase_opfor_car01" ]						 = "vehicle_iveco_lynx_iw6";
	addNotetrack_customFunction( "factory_car_chase_opfor_car01" , "car_death"	 , ::chase_kill_vehicle );			 
	
	level.scr_animtree[ "factory_car_chase_opfor_car02" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car02" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car02;
	level.scr_model[ "factory_car_chase_opfor_car02" ]						 = "vehicle_iveco_lynx_iw6";
	addNotetrack_customFunction( "factory_car_chase_opfor_car02" , "car_death"	 , ::chase_kill_vehicle );		
	
	level.scr_animtree[ "factory_car_chase_opfor_car03" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car03" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car03;
	level.scr_model[ "factory_car_chase_opfor_car03" ]						 = "vehicle_iveco_lynx_iw6";
	addNotetrack_customFunction( "factory_car_chase_opfor_car03" , "car_death"	 , ::chase_kill_vehicle );		
	
	level.scr_animtree[ "factory_car_chase_opfor_car04" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car04" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car04;
	level.scr_model[ "factory_car_chase_opfor_car04" ]						 = "vehicle_iveco_lynx_iw6";
	addNotetrack_customFunction( "factory_car_chase_opfor_car04" , "car_death"	 , ::chase_kill_vehicle );		
	
	level.scr_animtree[ "factory_car_chase_opfor_car05" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car05" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car05;
	level.scr_model[ "factory_car_chase_opfor_car05" ]						 = "vehicle_iveco_lynx_iw6";
	
	level.scr_animtree[ "factory_car_chase_opfor_car06" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car06" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car06;
	level.scr_model[ "factory_car_chase_opfor_car06" ]						 = "vehicle_iveco_lynx_iw6";	
	
	level.scr_animtree[ "factory_car_chase_opfor_car07" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car07" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car07;
	level.scr_model[ "factory_car_chase_opfor_car07" ]						 = "vehicle_iveco_lynx_iw6";	
	
	level.scr_animtree[ "factory_car_chase_opfor_car08" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car08" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car08;
	level.scr_model[ "factory_car_chase_opfor_car08" ]						 = "vehicle_iveco_lynx_iw6";	
	
	level.scr_animtree[ "factory_car_chase_opfor_car09" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_opfor_car09" ][ "factory_car_chase" ] = %factory_car_chase_opfor_car09;
	level.scr_model[ "factory_car_chase_opfor_car09" ]						 = "vehicle_iveco_lynx_iw6";	
	
	
	level.scr_animtree[ "factory_car_chase_plane01" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_plane01" ][ "factory_car_chase" ] = %factory_car_chase_plane01;
	level.scr_model[ "factory_car_chase_plane01" ]						 = "vehicle_b2_bomber";
	
	level.scr_animtree[ "factory_car_chase_plane02" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_plane02" ][ "factory_car_chase" ] = %factory_car_chase_plane02;
	level.scr_model[ "factory_car_chase_plane02" ]						 = "vehicle_b2_bomber";
	
	level.scr_animtree[ "factory_car_chase_plane03" ]					 = #animtree;
	level.scr_anim[ "factory_car_chase_plane03" ][ "factory_car_chase" ] = %factory_car_chase_plane03;
	level.scr_model[ "factory_car_chase_plane03" ]						 = "vehicle_b2_bomber";
}

#using_animtree( "generic_human" );
dialog()
{
	// Intro
	

	// New Intro Dialogue - STILL NEEDS MERGING THE OLD LINES WITH THIS OR NEW LINES ADDED TO REPLACE OLD LINES
	
	//Keegan: Jericho 1-1 and 1-2, watch your step – you have two contacts approaching low
	//level.scr_radio[ "factory_kgn_jericho11and12"		 ] = "factory_kgn_jericho11and12";
	//Merrick: They’re down Creeper 1-1, we’re moving to Entry A.
	level.scr_radio[ "factory_mrk_theyredowncreeper11"	 ] = "factory_mrk_theyredowncreeper11";

	//Merrick: House Main. We have eyes on the factory. Over.
	level.scr_radio[ "factory_mrk_housemainwehave"		 ] = "factory_mrk_housemainwehave";
	//Overlord: Roger Jericho, move to Black Zone, get confirmation of LOKI then evac, ARCLIGHT will follow directly.
	level.scr_radio[ "factory_hqr_rogerjerichomoveto"		 ] = "factory_hqr_rogerjerichomoveto";
	//Merrick: Copy that. Approaching entry. 
	level.scr_radio[ "factory_mrk_copythatapproachingentry"		 ] = "factory_mrk_copythatapproachingentry";

	//Merrick: Jericho at Entry A.
	level.scr_radio[ "factory_mrk_jerichoatentrya"		 ] = "factory_mrk_jerichoatentrya";
	//Keegan: Creeper at Entry B
	//level.scr_radio[ "factory_kgn_creeperatentryb"		 ] = "factory_kgn_creeperatentryb";
	//Merrick: Copy – moving. Regroup… fifty meters.
	level.scr_radio[ "factory_mrk_copymovingregroupfifty"		 ] = "factory_mrk_copymovingregroupfifty";

	//Merrick: We see you, Creeper – moving to RV.
	level.scr_radio[ "factory_mrk_weseeyoucreeper"		 ] = "factory_mrk_weseeyoucreeper";
	//Merrick: Down... we’re moving.
	level.scr_radio[ "factory_mrk_downweremoving"		 ] = "factory_mrk_downweremoving";

	//Merrick: House Oldboy and Pick – peel-off and tap into security, watch for squirters.
	level.scr_radio[ "factory_mrk_oldboyandpickpeeloff"		 ] = "factory_mrk_oldboyandpickpeeloff";
	//Merrick: Everyone else, we’re moving left to infil and then to Black Zone to find LOKI.
	level.scr_radio[ "factory_mrk_everyoneelseweremoving"		 ] = "factory_mrk_everyoneelseweremoving";

	//Merrick: All clear, Hesh grab a security badge. I got Right.
	level.scr_radio[ "factory_mrk_allclearheshgrab"		 ] = "factory_mrk_allclearheshgrab";
	//Keegan: Cover Left.
	//level.scr_radio[ "factory_kgn_coverleft"		 ] = "factory_kgn_coverleft";

	//Merrick: On the door…
	level.scr_radio[ "factory_mrk_onthedoor"		 ] = "factory_mrk_onthedoor";

	//Keegan: Two ahead.
	//level.scr_radio[ "factory_kgn_twoahead"		 ] = "factory_kgn_twoahead";
	//Hesh: Clear to move.
	level.scr_radio[ "factory_hsh_cleartomove"		 ] = "factory_hsh_cleartomove";

	//Enenmy: Take them out!
	level.scr_radio[ "factory_spa_takethemout"		 ] = "factory_spa_takethemout";

	//Baker: Diaz?
	level.scr_radio[ "factory_bkr_diaz2"		 ] = "factory_bkr_diaz2";
	//Diaz: You're clear.
	level.scr_radio[ "factory_diz_youreclear"	 ] = "factory_diz_youreclear";
	//Baker: Let's go.
	level.scr_radio[ "factory_bkr_letsgo3"		 ] = "factory_bkr_letsgo3";
	//Baker: Hold… tango.

	//Venezuelan1: Trains are clear…
	level.scr_radio[ "factory_vs1_trainsareclear" ] = "factory_vs1_trainsareclear";
	//Venezuelan2: Roger patrol
	level.scr_radio[ "factory_vs2_rogerpatrol" ] = "factory_vs2_rogerpatrol";
	//Venezuelan3: Moving to loading docks…
	level.scr_radio[ "factory_vs3_movingtoloadingdocks" ] = "factory_vs3_movingtoloadingdocks";
	//Venezuelan2: Copy that.
	level.scr_radio[ "factory_vs2_copythat" ] = "factory_vs2_copythat";

	//Baker: Hold… tango.
	level.scr_radio[ "factory_bkr_twoapproaching"		 ] = "factory_bkr_twoapproaching";
	//Diaz: Getting close…
	level.scr_radio[ "factory_diz_gettingclose"	 ] = "factory_diz_gettingclose";
	//Baker: Rook, he's yours…keep it quiet.
	level.scr_radio[ "factory_bkr_gotthem"		 ] = "factory_bkr_gotthem";
	//Baker: Rook - on you…
	level.scr_radio[ "factory_bkr_rookonyou"	 ] = "factory_bkr_rookonyou";
	//Keegan: He's down.
	level.scr_radio[ "factory_kgn_theyredown"	 ] = "factory_kgn_theyredown";
	//Baker: Hold… … ok, moving
	level.scr_radio[ "factory_bkr_holdokaymoving" ] = "factory_bkr_holdokaymoving";
	//Baker: Ok, moving.
	level.scr_radio[ "factory_bkr_okaymoving"	 ] = "factory_bkr_okaymoving";
	//Baker: Let’s keep things moving, get our intel, and get out safe.
	level.scr_radio[ "factory_bkr_findout"		 ] = "factory_bkr_findout";

	//Baker: Ok, maintain stealth…
	level.scr_radio[ "factory_bkr_maintainstealth" ] = "factory_bkr_maintainstealth";
	//Diaz: Baker, Diaz. Fuentes and I are moving to security.
	level.scr_radio[ "factory_diz_movingtosecurity" ] = "factory_diz_movingtosecurity";
	//Baker: Copy that, you'll be our eyes and ears.
	level.scr_radio[ "factory_bkr_eyesandears"	 ] = "factory_bkr_eyesandears";
	//Baker: Keegan, Rogers, and Rook - you're with me…
	level.scr_radio[ "factory_bkr_yourewithme"	 ] = "factory_bkr_yourewithme";
 
	//Diaz: ROE?
	level.scr_radio[ "factory_diz_roe"			 ] = "factory_diz_roe";
	//Baker: Cleared hot.
	level.scr_radio[ "factory_bkr_cleartogohot"	 ] = "factory_bkr_cleartogohot";
	
	//Baker: Targets ahead.
	level.scr_radio[ "factory_bkr_targetsahead" ] = "factory_bkr_targetsahead";
	//Baker: They’re down. 
	level.scr_radio[ "factory_bkr_theyredown"	 ] = "factory_bkr_theyredown";
	//Baker: Moving.
	level.scr_radio[ "factory_bkr_moving"		 ] = "factory_bkr_moving";
	//Diaz: Tangos…
	level.scr_radio[ "factory_diz_tangos"		 ] = "factory_diz_tangos";
	//Diaz: Nice.
	level.scr_radio[ "factory_diz_nice"			 ] = "factory_diz_nice";
	//Baker: Go.
	level.scr_radio[ "factory_bkr_go"			 ] = "factory_bkr_go";
	//Keegan: Tangos ahead…
	level.scr_radio[ "factory_kgn_tangosahead"	 ] = "factory_kgn_tangosahead";
	//Keegan:  Clear
	level.scr_radio[ "factory_kgn_clear"		 ] = "factory_kgn_clear";
	
	//Baker: Diaz, Fuentes - move to security.
	level.scr_radio[ "factory_bkr_withhim"	 ] = "factory_bkr_withhim";
	//Keegan: Roger.
	level.scr_radio[ "factory_kgn_roger"	 ] = "factory_kgn_roger";
	//Baker: Get a target… Rook, we're on you…
	level.scr_radio[ "factory_bkr_getatarget" ] = "factory_bkr_getatarget";
	
	// Power Stealth
	
	//Diaz: They’re busy here…
	level.scr_radio[ "factory_diz_busyhere"			 ] = "factory_diz_busyhere";
	//Baker: Eyes open – keep moving…
	level.scr_radio[ "factory_bkr_keepmoving"		 ] = "factory_bkr_keepmoving";
	//Baker: Through here.
	level.scr_radio[ "factory_bkr_throughhere"		 ] = "factory_bkr_throughhere";
	//Baker: Rook, let’s go!
	level.scr_radio[ "factory_bkr_letsgo"			 ] = "factory_bkr_letsgo";
	//Diaz: Two tangos close, one in the back…moving away
	level.scr_radio[ "factory_diz_movingaway"		 ] = "factory_diz_movingaway";
	//Baker: Tell us when we’re clear…
	level.scr_radio[ "factory_bkr_whenwereclear"	 ] = "factory_bkr_whenwereclear";
	//Diaz: Clear
	level.scr_radio[ "factory_diz_clear"			 ] = "factory_diz_clear";
	//Baker: Drop ‘em.
	level.scr_radio[ "factory_bkr_dropem"			 ] = "factory_bkr_dropem";
	//Baker: Multiple routes - split up - sweep and clear.
	level.scr_radio[ "factory_bkr_goright"			 ] = "factory_bkr_goright";
	//Baker: Sweep and clear.
	level.scr_radio[ "factory_bkr_sweepandclear"	 ] = "factory_bkr_sweepandclear";
	//Diaz: Railguns… they’re assembling railguns here…
	level.scr_radio[ "factory_diz_railguns"			 ] = "factory_diz_railguns";
	//Baker: 6-3 to overlord, come in… overlord? I’m not getting through…
	level.scr_radio[ "factory_bkr_notgettingthrough" ] = "factory_bkr_notgettingthrough";
	//Keegan: Trying to make contact…
	level.scr_radio[ "factory_kgn_makecontact"		 ] = "factory_kgn_makecontact";
	//Baker: We’ve got eyes on multiple railgun units… let’s keep looking. Move up…
	level.scr_radio[ "factory_bkr_railgununits"		 ] = "factory_bkr_railgununits";
	
	level.scr_sound[ "opfor01" ][ "factory_sp1_miranomeimporta" ] = "factory_sp1_miranomeimporta";
	level.scr_sound[ "opfor02" ][ "factory_sp2_peroyaterminaronlas" ] = "factory_sp2_peroyaterminaronlas";
	level.scr_sound[ "opfor01" ][ "factory_sp1_ycuandosesupone" ] = "factory_sp1_ycuandosesupone";
	level.scr_sound[ "opfor02" ][ "factory_sp2_elseorventuradijo" ] = "factory_sp2_elseorventuradijo";
	level.scr_sound[ "opfor01" ][ "factory_sp1_puesesperoquelo" ] = "factory_sp1_puesesperoquelo";
	level.scr_sound[ "opfor02" ][ "factory_sp2_yoandoigual" ] = "factory_sp2_yoandoigual";
	level.scr_sound[ "opfor01" ][ "factory_sp1_quhoratienes" ] = "factory_sp1_quhoratienes";
	level.scr_sound[ "opfor02" ][ "factory_sp2_dosymedia" ] = "factory_sp2_dosymedia";
	level.scr_sound[ "opfor01" ][ "factory_sp1_putamadrenosquedan" ] = "factory_sp1_putamadrenosquedan";
	
	//Keegan: Baker!  We've got movement out here!  Lot's of it!  Grab the data and get out of there!
	level.scr_radio[ "factory_kgn_wholebattalion" ] = "factory_kgn_wholebattalion";
	//Keegan: They’re right on top of you guys!
	level.scr_radio[ "factory_kgn_ontop"		 ] = "factory_kgn_ontop";

	//Baker: There's no data…this was a setup.
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_setup"			 ] = "factory_bkr_setup";
	//Baker: Everyone get to cover!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_gettocover"		 ] = "factory_bkr_gettocover";
	//Diaz: Tangos! 10, 12, and 2!
	level.scr_sound[ "ally_bravo"	 ][ "factory_diz_everywhere"		 ] = "factory_diz_everywhere";
	//Rogers: We need an exit!
	level.scr_sound[ "ally_charlie" ][ "factory_rgs_needanexit"		 ] = "factory_rgs_needanexit";
	//Baker: Everyone – prep extraction smoke!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_extractionsmoke" ] = "factory_bkr_extractionsmoke";
	//Diaz: Ready!
	level.scr_sound[ "ally_bravo"	 ][ "factory_diz_ready"			 ] = "factory_diz_ready";
	//Baker: Pop smoke!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_popsmoke"		 ] = "factory_bkr_popsmoke";
	//Baker: Go to thermals!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_gotothermals"	 ] = "factory_bkr_gotothermals";
	//Baker: Move forward!  Go!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_totheoffices"	 ] = "factory_bkr_totheoffices";
	//Baker: Keegan! Get Overlord – we need extraction, now!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_needextractionnow" ] = "factory_bkr_needextractionnow";
	
	//Baker: Target left!
	level.scr_sound[ "ally_alpha" ][ "factory_bkr_targetleft" ] = "factory_bkr_targetleft";
	//Baker: Target right!
	level.scr_sound[ "ally_alpha" ][ "factory_bkr_targetright" ] = "factory_bkr_targetright";
	//Diaz: Tango left!
	level.scr_sound[ "ally_bravo" ][ "factory_diz_tangoleft" ] = "factory_diz_tangoleft";
	//Diaz: Tango right!
	level.scr_sound[ "ally_bravo" ][ "factory_diz_tangoright" ] = "factory_diz_tangoright";

	// General 
	/*
	//Diaz: There’re more!
	level.scr_sound[ "ally_bravo"	 ][ "factory_diz_therearemore"	 ] = "factory_diz_therearemore";
	//Rogers: They keep coming!
	level.scr_sound[ "ally_charlie" ][ "factory_rgs_keepcoming"		 ] = "factory_rgs_keepcoming";
	//Diaz: From the roof!
	level.scr_sound[ "ally_bravo"	 ][ "factory_diz_fromtheroof"	 ] = "factory_diz_fromtheroof";
	//Baker: Getting low on ammo!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_lowonammo"		 ] = "factory_bkr_lowonammo";
	//Baker: Grab weapons!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_grabweapons"	 ] = "factory_bkr_grabweapons";
	//Baker: Don’t go down!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_godown"			 ] = "factory_bkr_godown";
	//Baker: Get up!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_getup"			 ] = "factory_bkr_getup";
	//Baker: Pick up anything you can! Keep stocked!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_keepstocked"	 ] = "factory_bkr_keepstocked";
	//Baker: Don’t stop!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_dontstop2"		 ] = "factory_bkr_dontstop2";
	//Baker: Keep moving!
	level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_keepmoving2"	 ] = "factory_bkr_keepmoving2";
	//Baker: We’re not stopping!
	// level.scr_sound[ "ally_alpha"	 ][ "factory_bkr_werenotstopping" ] = "factory_bkr_werenotstopping";
	//Diaz: Running low!
	// level.scr_sound[ "ally_bravo"	 ][ "factory_diz_runninglow"		 ] = "factory_diz_runninglow";
	*/
	// Sound Effects ( Prague did this. I'm not sure why, but apparently it's necessary for these sfx)
	level.scr_sound[ "elm_thunder_distant" ] = "elm_thunder_distant";
	level.scr_sound[ "elm_thunder_strike"  ] = "elm_thunder_strike";

}

//================================================================================================
// Factory Intro Jungle
//================================================================================================
/*
factory_intro_jungle_baker_spawn()

{
	baker = vignette_actor_spawn( "leader", "baker" ); //"value" (kvp), "anim_name"
	
	factory_intro_jungle_baker( baker );
	
	baker vignette_actor_delete();
}
*/
factory_intro_jungle_baker( baker )

{
	node = getstruct( "factory_intro_jungle", "script_noteworthy" );

	guys			= [];
	guys[ "baker" ] = baker;
	
	node anim_first_frame( guys, "factory_intro_jungle_baker" );

	node anim_single( guys, "factory_intro_jungle_baker" );
}

/*
factory_introkill_jungle_player_spawn()
{
	factory_introkill_jungle_player();
}
*/
factory_introkill_jungle_player( )
{

	node = getstruct( "factorykill_player_introstart1", "script_noteworthy" );

	foliage = spawn_anim_model( "foliage" );

	level.player.active_anim = true;
	level.player FreezeControls( true );
	level.player AllowProne( false );
	//level.player AllowCrouch( false );
	level.player GiveWeapon( "factory_knife" );
	level.player SwitchToWeapon( "factory_knife" );
	level.player DisableWeapons();
	level.player SetStance( "crouch" );

	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();
	
	guys				  = [];
	guys[ "player_rig"	] = player_rig;
	guys[ "foliage"		] = foliage;
	
	node anim_first_frame( guys, "factory_intro_jungle_drop_player" );

	arc = 30;
	
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.25, 0.15, 0.15 );
	wait 0.25;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 30, 30, 10, 30, true );
	player_rig Show();

	wait 0.8;
	thread change_dof_jungle_intro();
	node anim_single( guys, "factory_intro_jungle_drop_player" );

	wait 1.5;

	// TRYING OUT GIVING THE PLAYER A KNIFE FROM THE BEGINNING
	// level.player TakeAllWeapons();
	level.player DisableWeaponSwitch();
	level.player EnableWeapons();
	level.player thread maps\factory_audio::audio_plr_intro_knife_pullout();
	
	wait .75;
	
	level.player Unlink();
	player_rig Delete();
	
	level.player.active_anim = false;
	level.player FreezeControls( false );
}

/*
factory_intro_jungle_player_spawn()
{
	player_body = vignette_actor_spawn( "fp_body", "player_body" ); //"value" (kvp), "anim_name"

	factory_intro_jungle_player( player_body );

	player_body vignette_actor_delete();
}

factory_intro_jungle_player( player_body )
{

	wait 5;
	node = getstruct( "factory_intro_jungle", "script_noteworthy" );

	foliage = spawn_anim_model( "foliage" );

	level.player.active_anim = true;
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();
	
	guys				  = [];
	guys[ "player_body" ] = player_body;
	guys[ "player_rig"	] = player_rig;
	guys[ "foliage"		] = foliage;
	
	node anim_first_frame( guys, "factory_intro_jungle_player" );
	arc = 15;

	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.25, 0.05, 0.05 );
	wait 0.25;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, true );
	player_rig Show();

	node anim_single( guys, "factory_intro_jungle_player" );

	level.player Unlink();

	player_rig Delete();

	level.player FreezeControls( false );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player.active_anim = false;
	level.player EnableWeapons();

}
*/

// Animated intro_chopper path
intro_chopper()
{
	//IPrintLnBold( "intro_chopper" );
	chopper	  = vignette_vehicle_spawn( "intro_chopper_spotlight_1", "intro_chopper" );
	// chopper	  = spawn_anim_model( "intro_chopper" );
	chopper SetCanDamage ( true );
	anim_node = GetEnt( "factory_intro_chopper", "script_noteworthy" );

	org = spawn_tag_origin();
	org teleport_to_ent_tag( chopper, "tag_turret" );
	org LinkToBlendToTag( chopper, "tag_turret", false );
	PlayFXOnTag ( level._effect[ "spotlight_model_factory" ], org, "tag_origin" );
	chopper.has_spotlight = true;
	level.intro_chopper	  = chopper;

	level.intro_chopper thread maps\factory_powerstealth::detect_player_shot();
	
	guys					= [];
	guys[ "intro_chopper" ] = chopper;
	thread maps\factory_audio::sfx_intro_helicopter_and_splash( chopper );
	anim_node anim_first_frame( guys, "factory_intro_jungle_spotlight_chopper" );
	anim_node thread anim_single( guys, "factory_intro_jungle_spotlight_chopper" );

	// Cleanup
	// player is sliding down - turn off the spotlight for next enemy
	flag_wait ( "intro_start_slide" );
	
	wait 1;
	StopFXOnTag( level._effect[ "spotlight_model_factory" ], org, "tag_origin" );
	chopper.has_spotlight = false;
	// player has mantled the train couplings - kill the chopper
	flag_wait( "audio_endofclacks" );
	org Delete();
	chopper Delete();
}

//================================================================================================
// Factory Intro Jungle slide
//================================================================================================
/*
factory_intro_jungle_slide_player_spawn()
{
	player_body = vignette_actor_spawn( "fp_body_slide", "player_body" ); //"value" (kvp), "anim_name"

	factory_intro_jungle_slide_player( player_body );

	player_body vignette_actor_delete();
}

factory_intro_jungle_slide_player( player_body )
{

	node = getstruct( "factory_intro_jungle_slide", "script_noteworthy" );

	level.player.active_anim = true;
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();
	
	guys				  = [];
	guys[ "player_body" ] = player_body;
	guys[ "player_rig"	] = player_rig;

	arc = 20;

	// Link player to delta on rig
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.02, 0.01, 0.01 );
	wait 0.01;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
	player_rig Show();

	//level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	thread play_player_anim( node, guys, player_rig, player_body );
	
	//node anim_single(guys, "factory_intro_jungle_slide_player");
	
	wait 5;
	
	factory_intro_jungle_wallhop_spawn();
	
}

play_player_anim( node, guys, player_rig, player_body )
{
	node anim_single( guys, "factory_intro_jungle_slide_player" );

	level.player Unlink();

	player_rig Delete();

	level.player FreezeControls( false );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player EnableWeapons();
	level.player.active_anim = false;	
	
//	player_body vignette_actor_delete();
}

factory_intro_jungle_wallhop_spawn()
{
	wallhop_ally01 = vignette_actor_spawn( "wallhop_ally01", "wallhop_ally01" ); //"value" (kvp), "anim_name"
	wallhop_ally02 = vignette_actor_spawn( "wallhop_ally02", "wallhop_ally02" ); //"value" (kvp), "anim_name"
//	wallhop_ally03 = vignette_actor_spawn("wallhop_ally03", "wallhop_ally03"); //"value" (kvp), "anim_name"

	factory_intro_jungle_wallhop( wallhop_ally01, wallhop_ally02 );

	wallhop_ally01 vignette_actor_delete();
	wallhop_ally02 vignette_actor_delete();
//	wallhop_ally03 vignette_actor_delete();
}
*/
factory_intro_jungle_wallhop( wallhop_ally01, wallhop_ally02 )
{

	node = getstruct( "factory_intro_jungle_wallhop", "script_noteworthy" );


	guys					 = [];
	guys[ "wallhop_ally01" ] = wallhop_ally01;
	guys[ "wallhop_ally02" ] = wallhop_ally02;
//	guys["wallhop_ally03"] = wallhop_ally03;

	node anim_single( guys, "factory_intro_jungle_wallhop" );

}

//================================================================================================
// Allies Enter Factory Interior
//================================================================================================

allies_enter_factory_cranes()
{
	flag_wait( "card_swiped" );
	
	node = getstruct( "allies_enter_factory", "script_noteworthy" );

	factory_crane_rear = spawn_anim_model( "factory_crane_rear" );
	factory_crane_rear_beam = spawn_anim_model( "factory_crane_rear_beam" );
	factory_allies_enter_factory_container01 = spawn_anim_model( "factory_allies_enter_factory_container01" );
	factory_allies_enter_factory_container02 = spawn_anim_model( "factory_allies_enter_factory_container02" );
	
	crane_beam = setup_crane_beam();
	crane_beam.origin = factory_crane_rear_beam.origin;
	crane_beam LinkTo( factory_crane_rear_beam, "tag_origin", ( 0, 0, -140 ), ( 0, 0, 0 ) );	
	
	container_01 = GetEnt( "fac_ent_container_01", "targetname" );
	container_01.origin = factory_allies_enter_factory_container01.origin;
	container_01 LinkTo( factory_allies_enter_factory_container01 );
	
	container_02 = GetEnt( "fac_ent_container_02", "targetname" );
	container_02.origin = factory_allies_enter_factory_container02.origin;
	container_02 LinkTo( factory_allies_enter_factory_container02 );

	PlayFXOnTag( level._effect[ "glow_red_light_100_blinker_nolight" ], factory_crane_rear, "tag_light_01" );
	PlayFXOnTag( level._effect[ "glow_red_light_100_blinker_nolight" ], factory_crane_rear, "tag_light_02" );
	wait 0.05;
	PlayFXOnTag( level._effect[ "glow_red_light_100_blinker_nolight" ], factory_crane_rear, "tag_light_03" );
	PlayFXOnTag( level._effect[ "glow_red_light_100_blinker_nolight" ], factory_crane_rear, "tag_light_04" );
	
//	crate = Spawn( "script_model", factory_crane_rear.origin );
//	crate SetModel( "shipping_frame_crates" );
//	crate LinkTo( factory_crane_rear_beam );
	

	
//	factory_crane_rear thread rear_crane_support01();
	
//	factory_crane_rear_beam		  = spawn_anim_model( "factory_crane_rear_beam" );
//	level.factory_crane_rear_beam = factory_crane_rear_beam;

//	factory_crane_battletank = spawn_anim_model( "factory_crane_battletank" );	
//													  //   positionx    positiony    positionz    deathflag 		 
//	factory_crane_battletank thread crane_warning_lights( -65		 , 92		  , 0		   , "kill_tank_lights" );
//	factory_crane_battletank thread crane_warning_lights( 158		 , 92		  , 0		   , "kill_tank_lights" );
//	thread kill_crane_lights_and_lower_tank_supports();
//	factory_crane_missiles = spawn_anim_model( "factory_crane_missiles" );


	guys							   = [];
	guys[ "factory_crane_rear"		 ] = factory_crane_rear;
	guys[ "factory_crane_rear_beam"	 ] = factory_crane_rear_beam;
	guys[ "factory_allies_enter_factory_container01" ] = factory_allies_enter_factory_container01;
	guys[ "factory_allies_enter_factory_container02"	 ] = factory_allies_enter_factory_container02;

//	node anim_first_frame( guys, "allies_enter_factory_cranes" );

	node thread anim_single( guys, "allies_enter_factory_cranes" );
}

setup_crane_beam()
{
	crane_beam = GetEnt( "reveal_crane_org", "targetname" );
	
	crane_parts = [];
	crane_parts = GetEntArray( crane_beam.target, "targetname" );
	
	foreach( part in crane_parts )
	{
		part LinkTo( crane_beam );
	}

	node = GetEnt( "beam_light_01", "script_noteworthy" );

	if( isDefined( node ))
    {
		glow = node spawn_tag_origin();
		glow.origin = node.origin;
	    glow LinkTo( crane_beam ); // JR - Uncomment this and the lights will rotate, but not move
	    PlayFXOnTag( level._effect[ "glow_red_light_100_blinker" ], glow, "tag_origin" );
    }
    
	node = GetEnt( "beam_light_02", "script_noteworthy" );

	if( isDefined( node ))
    {
		glow = node spawn_tag_origin();
		glow.origin = node.origin;
	    glow LinkTo( crane_beam ); // JR - Uncomment this and the lights will rotate, but not move
	    PlayFXOnTag( level._effect[ "glow_red_light_100_blinker" ], glow, "tag_origin" );
    }
	
	return crane_beam;
}

allies_enter_factory_ally01_spawn()
{

	ally01 = vignette_actor_spawn( "allies_enter_factory_ally01", "ally01" ); //"value" (kvp), "anim_name"
	
	allies_enter_factory_ally01( ally01 );

	ally01 vignette_actor_delete();

}

allies_enter_factory_ally01( ally01 )
{

	node = getstruct( "allies_enter_factory", "script_noteworthy" );

	guys = [];

	guys[ "ally01" ] = ally01;

	node anim_single( guys, "allies_enter_factory_ally01" );

}

allies_enter_factory_ally02_spawn()
{
	
	ally02 = vignette_actor_spawn( "allies_enter_factory_ally02", "ally02" ); //"value" (kvp), "anim_name"

	allies_enter_factory_ally02( ally02 );

	ally02 vignette_actor_delete();
	
}

allies_enter_factory_ally02( ally02 )
{

	node = getstruct( "allies_enter_factory", "script_noteworthy" );

	guys			 = [];
	guys[ "ally02" ] = ally02;

	node anim_single( guys, "allies_enter_factory_ally02" );

}

//================================================================================================
// POWER STEALTH
//================================================================================================
/*
power_stealth_balcony_spawn()

{
	opfor = vignette_actor_spawn( "stealth_death", "opfor" ); //"value" (kvp), "anim_name"
	
	power_stealth_balcony( opfor );
	
	opfor vignette_actor_delete();

}

power_stealth_balcony( opfor )
{

	node = getstruct( "power_stealth_balcony_fall", "script_noteworthy" );

	guys			= [];
	guys[ "opfor" ] = opfor;

	node anim_single( guys, "power_stealth_balcony" );

}

*/

/*
rogers_hall_kill_spawn()
{
	ally  = vignette_actor_spawn( "stealth_killer_02", "ally" ); //"value" (kvp), "anim_name"
	opfor = vignette_actor_spawn( "stealth_death_02", "opfor" ); //"value" (kvp), "anim_name"

	rogers_hall_kill( ally, opfor );

	ally vignette_actor_delete();

	opfor vignette_actor_delete();
}
*/
rogers_hall_kill( ally, opfor )
{
	node = getstruct( "rogers_hall_kill", "script_noteworthy" );

	guys			= [];
	guys[ "ally"  ] = ally;
	guys[ "opfor" ] = opfor;

	node anim_single( guys, "rogers_hall_kill" );

}
/*
baker_lower_hall_kill_spawn()
{

	ally  = vignette_actor_spawn( "stealth_killer_03", "ally" ); //"value" (kvp), "anim_name"
	opfor = vignette_actor_spawn( "stealth_death_03", "opfor" ); //"value" (kvp), "anim_name"

	baker_lower_hall_kill( ally, opfor );

	ally vignette_actor_delete();
	opfor vignette_actor_delete();
	
}
*/
baker_lower_hall_kill( ally, opfor )
{

	node = getstruct( "baker_lower_hall_kill", "script_noteworthy" );

	guys			= [];
	guys[ "ally"  ] = ally;
	guys[ "opfor" ] = opfor;

	node anim_single( guys, "baker_lower_hall_kill" );

}
/*
rest_area_kills_spawn()
{

	opfor01 = vignette_actor_spawn( "stealth_death_04", "opfor01" ); //"value" (kvp), "anim_name"
	opfor02 = vignette_actor_spawn( "stealth_death_05", "opfor02" ); //"value" (kvp), "anim_name"

	rest_area_kills( opfor01, opfor02 );

	opfor01 vignette_actor_delete();
	opfor02 vignette_actor_delete();
	
}
*/
rest_area_kills( opfor01, opfor02 )
{

	node = getstruct( "rest_area_kills", "script_noteworthy" );

	chair_opfor01 = spawn_anim_model( "chair_opfor01" );
	chair_opfor02 = spawn_anim_model( "chair_opfor02" );

	guys					= [];
	guys[ "opfor01"		  ] = opfor01;
	guys[ "opfor02"		  ] = opfor02;
	guys[ "chair_opfor01" ] = chair_opfor01;
	guys[ "chair_opfor02" ] = chair_opfor02;

	node anim_single( guys, "rest_area_kills" );
	
}
/*
console_kill_spawn()
{

	opfor = vignette_actor_spawn( "stealth_death_06", "opfor" ); //"value" (kvp), "anim_name"

	console_kill( opfor );

	opfor vignette_actor_delete();

}
*/
console_kill( opfor )
{

	node = getstruct( "console_kill", "script_noteworthy" );

	guys			= [];
	guys[ "opfor" ] = opfor;

	node anim_single( guys, "console_kill" );
	
}
/*
keegan_top_stairway_kill_spawn()
{
	ally  = vignette_actor_spawn( "stealth_killer_07", "ally" ); //"value" (kvp), "anim_name"
	opfor = vignette_actor_spawn( "stealth_death_07", "opfor" ); //"value" (kvp), "anim_name"

	keegan_top_stairway_kill( ally, opfor );

	ally vignette_actor_delete();
	opfor vignette_actor_delete();
}
*/
keegan_top_stairway_kill( ally, opfor )
{

	node = getstruct( "keegan_top_stairway_kill", "script_noteworthy" );


	guys			= [];
	guys[ "ally"  ] = ally;
	guys[ "opfor" ] = opfor;

	node anim_single( guys, "keegan_top_stairway_kill" );

}
/*
last_patrol_kill_spawn()
{
	opfor01 = vignette_actor_spawn( "stealth_death_08", "opfor01" ); //"value" (kvp), "anim_name"
	ally01	= vignette_actor_spawn( "stealth_killer_08", "ally01" ); //"value" (kvp), "anim_name"

	last_patrol_kill( opfor01, ally01 );

	opfor01 vignette_actor_delete();
	ally01 vignette_actor_delete();
}
*/
last_patrol_kill( opfor01, ally01 )
{

	node = getstruct( "last_patrol_kill", "script_noteworthy" );


	guys			  = [];
	guys[ "opfor01" ] = opfor01;
	guys[ "ally01"	] = ally01;

	node anim_single( guys, "last_patrol_kill" );

}

//================================================================================================
// POWERSTEALTH ANIM FUNCTIONS
//================================================================================================

throat_stab_npc( ent )
{
	start_death( ent );
//	playfxontag( getfx( "knife_attack_throat_fx2" ), ent, "J_Neck" );
}

throat_stab_player( ent )
{
	PlayFXOnTag( level._effect[ "factory_intro_stab_blood_ally" ], ent, "tag_knife_fx" );
}

start_death( ent )
{
	ent.allowdeath = true;
	ent.a.nodeath  = true;
	ent.noragdoll  = true;
	ent.diequietly = true;
	ent thread set_battlechatter( false );

	ent.DropWeapon = true;
	ent animscripts\shared::DropAIWeapon();
}


//================================================================================================
// PRESAT ROOM
//================================================================================================
presat_door_open()
{
	node = GetEnt( "presat_entrance_anim_node", "targetname" );

	guys				   = [];
	guys[ "ally_alpha"	 ] = level.squad[ "ALLY_ALPHA" ];
	guys[ "ally_bravo"	 ] = level.squad[ "ALLY_BRAVO" ];
	guys[ "ally_charlie" ] = level.squad[ "ALLY_CHARLIE" ];
	
	// Anim first frame
	node anim_reach( guys, "presat_door_arrive" );
	node anim_first_frame( guys, "presat_door_arrive" );

	// Play part 1
	node anim_single( guys, "presat_door_arrive" );

	delayThread( 1.33, ::flag_set, "presat_open_revolving_door" );

	// Play part 2
	level.squad[ "ALLY_ALPHA" ] thread presat_door_open_individual( node, 0.12, "presat_allies_enter_alpha" );
	level.squad[ "ALLY_BRAVO" ] thread presat_door_open_individual( node, 0.1, "presat_allies_enter_bravo" );
	level.squad[ "ALLY_CHARLIE" ] thread presat_door_open_individual( node, 0.1, "presat_allies_enter_charlie" );
}

// Need to split this anim up per guy since the anim length is different for each guy
presat_door_open_individual( node, end_early, trigger_name )
{
	self SetGoalPos( self.origin );
	node anim_single_solo( self, "presat_door_enter", undefined, end_early );
	self enable_ai_color_dontmove();
	flag_set( "presat_door_anim_done" );
	maps\factory_util::safe_trigger_by_targetname( trigger_name );
}

/*
//================================================================================================
// SAT ROOM ANIMS
//================================================================================================
// Alpha interacting with the satellite
sat_interact_ally()
{
	// Get the node
	node = GetEnt( "sat_board_anim_node", "targetname" );

	// Reach to enter anim
	node anim_reach_solo( self, "sat_board_ally_enter" );
	
	flag_set( "sat_room_alpha_found_it" );

	self thread sat_board_ally_enter( node );
	
	// If the player triggers the scene early, ally should
	// immediatly dismount and never do his beckon loop
	self thread sat_board_player_trigger_early( node );

	flag_wait( "sat_room_alpha_get_down" );

	// Dismount and start floor loop
	node anim_single_solo( self, "sat_board_ally_dismount" );
	node thread anim_loop_solo( self, "sat_board_ally_floor_loop", "sat_board_player_handoff" );
	
	level waittill( "sat_board_player_handoff" );
	node notify( "sat_board_player_handoff" );
	
	// Do the handoff, and finish the anim
	node anim_single_solo( self, "sat_board_ally_handoff" );

	// Set a goal node in order to run out smoothly
	goal = GetNode( "sat_baker_after_anim_node", "targetname" );
	self SetGoalNode( goal );

	self enable_ai_color_dontmove();
	wait 0.1;

	// Move ALPHA up a bit and chill while Overlord rambles.
	maps\factory_util::safe_trigger_by_targetname( "sat_room_alpha_after_cpu" );
}

// Ally climbs up and does his beckon loop
sat_board_ally_enter( node )
{
	level endon( "sat_room_alpha_get_down" );

	// Ally starts the scene
	node anim_single_solo( self, "sat_board_ally_enter" );
	flag_set( "sat_room_alpha_enter_done" );
	
	// Start the beckon loop
	node thread anim_loop_solo( self, "sat_board_ally_rail_loop", "stop_loop" );

	// Player anim started, stop the beckon loop
	flag_wait( "sat_do_player_anim" );
	node notify( "stop_loop" );
	
	flag_set( "sat_room_alpha_get_down" );
}

// Allows the player to trigger the sat anim while
// the ally anim is still playing.
sat_board_player_trigger_early( node )
{
	level endon( "sat_room_alpha_enter_done" );

	// 3 seconds gives time for the ally to climb up
	wait 3.0;
	
	// Turn the trigger on
	trigger_on( "sat_player_anim_trigger", "targetname" );
	
	// Triggered early?
	flag_wait( "sat_do_player_anim" );
	self StopAnimScripted();
	
	// Immediatly get down
	flag_set( "sat_room_alpha_get_down" );
}


// Player anim for SAT room - Input controlled version
sat_interact_player_controlled()
{
	flag_wait( "sat_do_player_anim" );

	// Get the node
	node = GetEnt( "sat_board_anim_node", "targetname" );

	level.player.active_anim = true;
	level.player FreezeControls( true );
	level.player DisableWeapons();
	level.player SetStance( "stand" );
	level.player AllowProne( false );
	level.player AllowCrouch( false );

	level.player thread maps\factory_audio::sfx_sat_room_panel_railing();
	// Setup player rig
	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();

	// Spawn a knife
	knife_prop = Spawn( "script_model", player_rig GetTagOrigin( "tag_weapon" ) );
	knife_prop SetModel( "viewmodel_bowie_knife" );
	knife_prop LinkTo( player_rig, "tag_weapon" );

	// Setup the SAT panel
	if( !isDefined( level.sat_panel ))
	{
		level.sat_panel  = spawn_anim_model( "sat_board_panel" );
	}
	level.sat_panel.script_parameters = "sat_target_C";

	// Anim objects array
	guys					  = [];
	guys[ "player_rig"		] = player_rig;
	guys[ "sat_board_panel" ] = level.sat_panel;

	// Setup
	node anim_first_frame( guys, "sat_board_start" );

	// Tell ALPHA to get down and wait for the player
	level notify( "sat_board_player_started" );

	// Force camera on if its not already
	level thread maps\factory_weapon_room::sat_delayed_force_camera();

	// Link view arcs
	r_arc = 30;
	l_arc = 30;
	t_arc = 40;
	b_arc = 25;

	// Link player to delta on rig
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.5, 0.25, 0.25 );
	wait 0.5;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, r_arc, l_arc, t_arc, b_arc, 1 );
	player_rig Show();

	// Play the anim
	node anim_single( guys, "sat_board_start" );

	// Move ally up
	maps\factory_util::safe_trigger_by_targetname( "sat_room_bravo_after_cpu" );

	// Start the pry open loop
	node thread anim_loop( guys, "sat_board_knife", "stop_idle" );

	//------- PLAYER CONTROLLED PRY OPEN ANIM -----------
	hint_array[ "gamepad_l" ] = "sat_knife";
	hint_array[ "gamepad" ] = "sat_knife";
	hint_array[ "hint" ] = "sat_knife";
	hint_array[ "hint_l" ] = "sat_knife";
	thread maps\factory_weapon_room::sat_interact_activate_hint( hint_array, "sat_room_player_knifed", 0.25 );

	// Disable zoom
	level.player.binoculars_zoom_enabled = false;

	// Force no zoom
	level.player.current_binocular_zoom_level = 0;
	level.player thread maps\factory_camera::binoculars_zoom();

	while(1)
	{
		// Wait for melee
		if( level.player MeleeButtonPressed())
		{
			flag_set( "sat_room_player_knifed" );
			node notify( "stop_idle" );
			break;
		}
		wait 0.1;
	}

	level.player thread maps\factory_audio::sfx_sat_room_panel_pry_open();
	// Start the pry open anim
	node anim_single( guys, "sat_board_pulloff" );
	//---------------------------------------------------

	// Enable zoom
	level.player.binoculars_zoom_enabled = true;

	// Delete the knife prop
	knife_prop delete();

	// Start the look loop
	node thread anim_loop( guys, "sat_board_look", "sat_board_player_done_looking" );
	level delayThread( 3.0, maps\factory_weapon_room::debug_notify, "sat_board_player_done_looking" );
	level waittill( "sat_board_player_done_looking" );
	node notify( "sat_board_player_done_looking" );
	
	// Grab the board
	node anim_single( guys, "sat_board_grab" );

	//------- PLAYER CONTROLLED PULL ANIM -----------
	prop_lerp_rate = 0.15;
	analog_move_rate = 0.025;
	level.sat_anim_idle_cur = 0.0;
	use_pull_anim_sections = false;
	pull_anim_sections = [ 0.15, 0.30, 0.60 ];

	sfx_played = false;
	prop_anim_lerped = 0.0;
	prop_anim_target = 0.0;
	analog_input = [];

	hint_array[ "gamepad_l" ] = "sat_pull_gl";
	hint_array[ "gamepad" ] = "sat_pull_g";
	hint_array[ "hint" ] = "sat_pull";
	hint_array[ "hint_l" ] = "sat_pull";
	thread maps\factory_weapon_room::sat_interact_activate_hint( hint_array, "sat_room_player_pulled", 0.25 );

	node thread anim_single( guys, "sat_board_pull" );

	anim_set_rate( guys, "sat_board_pull", 0.0 );

	// Start the Audio script
	level.player thread maps\factory_audio::sfx_sat_room_panel_pull_panel();

	level.playing_sat_anim_sound = false;
	new_input = false;
	prev_prop_anim_lerped = 0.0;
	current_anim_section = 0;
	while( prop_anim_lerped < 0.90 )
	{
		analog_input = level.player GetNormalizedMovement();
		
		// Get the rate to move the target. Simple factor of amount of analog * the rate variable
		anim_target_mover = analog_input[0] * analog_move_rate;

		// Apply this to the target( inverted to animate right )
		prop_anim_target -= anim_target_mover;

		// Cap it!
		prop_anim_target = cap_range( prop_anim_target, 0, 1 );

		idle_swim = get_idle_swim( prop_anim_lerped );

		prop_anim_lerped = lerp_value( prop_anim_lerped + idle_swim, prop_anim_target, prop_lerp_rate );

		// Update sections
		if( use_pull_anim_sections )
		{
			// If any input is detected, trigger the next anim section
			if( analog_input[0] < -0.1  && current_anim_section < pull_anim_sections.size )
			{
				current_anim_section++;
				iprintlnbold( "anim section++ " + current_anim_section );
				prop_anim_lerped = pull_anim_sections[ current_anim_section ];
			}
			else if( analog_input[0] > 0.1  && current_anim_section > 0 )
			{
				current_anim_section--;
				iprintlnbold( "anim section-- " + current_anim_section );	
				prop_anim_lerped = pull_anim_sections[ current_anim_section ];
			}
		}

		// Update the anim
		guys["player_rig"] set_time_via_rate( level.scr_anim[ "player_rig" ][ "sat_board_pull" ], prop_anim_lerped );
		guys["sat_board_panel"] set_time_via_rate( level.scr_anim[ "sat_board_panel" ][ "sat_board_pull" ], prop_anim_lerped );

		// Determine if the player moved or is holding still
		if( analog_input[0] > 0.1 || analog_input[0] < -0.1 )
		{
			//iprintlnbold("new input: " ); //" + prop_anim_lerped + ", " + prev_prop_anim_lerped );
			new_input = true;
		}
		else
		{
			//iprintlnbold("no input: " ); //+ prop_anim_lerped + ", " + prev_prop_anim_lerped );
			new_input = false;
		}

		// SFX
		if( prop_anim_lerped > 0.10 && prop_anim_lerped < 0.15 )
		{
			if( !level.playing_sat_anim_sound && new_input )
			{
				level.player notify( "sat_pull_anim_past_15" );
			}
		}
		else if( prop_anim_lerped > 0.35 && prop_anim_lerped < 0.40 )
		{
			level.player PlayRumbleOnEntity( "light_1s" );
			if( !level.playing_sat_anim_sound && new_input )
			{
				level.player notify( "sat_pull_anim_past_45" );
			}
		}
		else if( prop_anim_lerped >= 0.55 && prop_anim_lerped < 0.60 )
		{
			level.player PlayRumbleOnEntity( "heavy_1s" );
			if( !level.playing_sat_anim_sound && new_input )
			{
				level.player notify( "sat_pull_anim_past_65" );
			}
		}

		// Rumbles
		if( prop_anim_lerped > 0.45 && prop_anim_lerped < 0.65 )
		{
			level.player PlayRumbleOnEntity( "light_1s" );
		}
		else if( prop_anim_lerped >= 0.65 && prop_anim_lerped < 0.9 )
		{
			level.player PlayRumbleOnEntity( "heavy_1s" );
		}

		// Save the old value
		prev_prop_anim_lerped = prop_anim_lerped;

		
		// Wait for sectional anim
		if( use_pull_anim_sections )
		{
			wait 1.0;
		}
		else
			wait 0.05;
	}
	flag_set( "sat_room_player_pulled" );
	//-----------------------------------------------


	// Get down from the railing
	node anim_single( guys, "sat_board_dismount" );

	// Start the hold loop
	node thread anim_loop( guys, "sat_board_hold", "sat_board_player_start_flip" );
	flag_set( "sat_room_saw_board_front" );

	level waittill( "sat_board_player_start_flip" );
	node notify( "sat_board_player_start_flip" );


	//------- PLAYER CONTROLLED FLIP ANIM -----------
	prop_lerp_rate = 0.35;
	analog_move_rate = 0.05;
	level.sat_anim_idle_cur = 0.0;
	spawned_flag_timer = false;
	
	sfx_played = false;
	prop_anim_lerped = 0.0;
	prop_anim_target = 0.0;
	analog_input = [];

	hint_array[ "gamepad_l" ] = "sat_flip_gl";
	hint_array[ "gamepad" ] = "sat_flip_g";
	hint_array[ "hint" ] = "sat_flip";
	hint_array[ "hint_l" ] = "sat_flip";
	thread maps\factory_weapon_room::sat_interact_activate_hint( hint_array, "sat_room_player_flipped", 0.25 );

	node thread anim_single( guys, "sat_board_flip" );
	guys[ "player_rig" ].anim_blend_time_override = 1.0;

	anim_set_rate( guys, "sat_board_flip", 0.0 );

	level.stay_in_flip_anim = true;
	level.playing_sat_anim_sound = false;
	while( level.stay_in_flip_anim == true )
	{
		analog_input = level.player GetNormalizedMovement();

		if(sfx_played == false && prop_anim_lerped > 0.01)
		{
			level.player thread maps\factory_audio::sfx_sat_room_panel_panel_flip();
			sfx_played = true;
		}
		
		// Get the rate to move the target. Simple factor of amount of analog * the rate variable
		anim_target_mover = analog_input[1] * analog_move_rate;

		// Apply this to the target( inverted to animate right )
		prop_anim_target -= anim_target_mover;

		// Don't allow reverse movement
		prop_anim_target = cap_range( prop_anim_target, prop_anim_lerped, 1 );

		// Detect the full flip
		if( prop_anim_lerped > 0.7 )
		{
			if( !spawned_flag_timer )
			{
				spawned_flag_timer = true;
				flag_set( "sat_room_player_flipped" );
				level thread sat_stop_flip_controls();
			}
		}

		idle_swim = get_idle_swim( prop_anim_lerped );

		prop_anim_lerped = lerp_value( prop_anim_lerped + idle_swim, prop_anim_target, prop_lerp_rate );

		// Update the anim
		guys["player_rig"] set_time_via_rate( level.scr_anim[ "player_rig" ][ "sat_board_flip" ], prop_anim_lerped );
		guys["sat_board_panel"] set_time_via_rate( level.scr_anim[ "sat_board_panel" ][ "sat_board_flip" ], prop_anim_lerped );

		wait 0.05;
	}
	//-----------------------------------------------


	// Hand it off to ALPHA
	level notify( "sat_board_player_handoff" );
	level.player thread maps\factory_audio::sfx_sat_room_panel_hand_off_sfx();
	node anim_single( guys, "sat_board_handoff" );

	// Unlink and cleanup
	level.player Unlink();
	player_rig Delete();
	level.player AllowProne( true );
	level.player AllowCrouch( true );

	// Only give the the weapon back if the camera isnt active
	if( !isDefined( level.player.binoculars_active ) || !level.player.binoculars_active )
	{
		level.player EnableWeapons();
	}

	level.player FreezeControls( false );
	level.player.active_anim = false;

	// Cleanup the panel model
	level.sat_panel delete();
}

// Allow the player to flip the board a bit untill the VO is done.
sat_stop_flip_controls()
{
	wait 2.0;
	level.stay_in_flip_anim = false;
}

lerp_value( value, tar, rate )
{
	diff = ( tar - value ) * rate;
	value += diff;
	return value;
}

cap_range( val, min, max )
{
	if( val > max )
		val = max;
	else if( val < min )
		val = min;
	return val;
}

// Dan N's smoother set time script
set_time_via_rate( anime, time )
{
	prev_time = self GetAnimTime( anime );
	duration = GetAnimLength( anime );
	rate = ( time - prev_time ) * duration / 0.05;

	self SetAnimLimited( anime, 1, 0, rate );
}

// Adds a tiny bit of swim to make the anim less static
get_idle_swim( current_val )
{
	swim_inc = 0.00026;	// The anim will swim up to +- this much% per frame
	swim_max = 0.0012;	// The anim will swim away from its last controlled position up to +- this much%

	increment = RandomFloatRange( (-1 * swim_inc ), swim_inc );

	// Cap the anim value
	if( current_val + level.sat_anim_idle_cur + increment > 1.0 || current_val + level.sat_anim_idle_cur + increment < 0.0 )
	{
		return 0;
	}

	// Bias the random increment direction
	if(( level.sat_anim_idle_cur < 0 && increment < 0 ) || ( level.sat_anim_idle_cur > 0 && increment > 0 ))
	{
		increment = ( increment * ( 1-( level.sat_anim_idle_cur / swim_max )));
	}

	// Cap the swim value
	if( level.sat_anim_idle_cur + increment >= (-1 * swim_max) && level.sat_anim_idle_cur + increment <= swim_max )
	{
		level.sat_anim_idle_cur += increment;
	}

	percent_diff = round_float(( level.sat_anim_idle_cur / swim_max ), 1, false );
	return level.sat_anim_idle_cur;
}

// Does an anim first frame on the panel to get it it into place
sat_interact_setup_panel()
{
	// Get the node
	node = GetEnt( "sat_board_anim_node", "targetname" );
	
	// Setup the SAT panel
	level.sat_panel  = spawn_anim_model( "sat_board_panel" );
	level.sat_panel.script_parameters = "sat_target_C";
	
	// Anim objects array
	guys					  = [];
	guys[ "sat_board_panel" ] = level.sat_panel;

	// Setup
	node anim_first_frame( guys, "sat_board_start" );
}

// Alpha turns on the lights
sat_room_ally_lights_on()
{
	// Get the anim node
	node = GetEnt( "sat_lights_on_node", "targetname" );

	// Reach
	node anim_reach_solo( self, "sat_room_alpha_lights" );

	// Play anim
	node anim_single_solo( self, "sat_room_alpha_lights" );
	self enable_ai_color();
}
*/

// Alpha typing
sat_room_alpha_typing()
{
	wait 0.85;
	maps\factory_util::safe_trigger_by_targetname( "sat_room_alpha_move_in" );
	wait 0.1;
	self.goalradius = 32;
	self waittill( "goal" );

	// Get the anim node
	node = GetEnt( "sat_typing_node_02", "targetname" );

	// Reach
	node anim_reach_solo( self, "sat_room_alpha_computer" );

	// Play idle anim
	node thread anim_loop_solo( self, "sat_room_alpha_computer", "stop_idle" );

	flag_wait( "sat_room_bridge_down" );
	node notify( "stop_idle" );
	wait 0.1;
	self enable_ai_color();
}

// Bravo typing 1
sat_room_bravo_typing_01()
{
	// TODO needs new anim

	// Get the anim node
	node = GetEnt( "sat_typing_node_01", "targetname" );

	// Reach
	node anim_reach_solo( self, "sat_room_bravo_computer_01" );

	// Play anim
	node thread anim_loop_solo( self, "sat_room_bravo_computer_01", "stop_idle" );

	flag_wait( "sat_room_bridge_down" );
	node notify( "stop_idle" );
	wait 0.1;
	self enable_ai_color();
}

// Bravo typing 2
sat_room_bravo_typing_02()
{
	// TODO needs new anim

	// Get the anim node
	node = GetEnt( "sat_typing_node_03", "targetname" );

	// Reach
	node anim_reach_solo( self, "sat_room_bravo_computer_02" );

	// Play anim
	node thread anim_loop_solo( self, "sat_room_bravo_computer_02", "stop_idle" );

	flag_wait( "sat_room_continue" );
	node notify( "stop_idle" );
	wait 0.1;
	self enable_ai_color();
}

reveal_room_exit_door()
{
	anim_node = GetEnt( "assembly_floor_open_node", "targetname" );

	// Make the door into an anim model
	level.assembly_room_door.animname = "assembly_floor_door";
	level.assembly_room_door assign_animtree();

	guys						  = [];
	guys[ "ALLY_ALPHA"	 ]		  = level.squad[ "ALLY_ALPHA" ];
	guys[ "ALLY_CHARLIE" ]		  = level.squad[ "ALLY_CHARLIE" ];
	guys[ "assembly_floor_door" ] = level.assembly_room_door;

	// Trigger the idle anim
	flag_wait( "reveal_room_player_at_exit" );

	// Connect paths on the door
	level.assembly_room_door.connector ConnectPaths();

	// Play the door open anim
	thread maps\factory_audio::greenlight_amb_change();	
	anim_node anim_first_frame( guys, "factory_assembly_floor_open_door" );
	anim_node anim_single( guys, "factory_assembly_floor_open_door" );
	
	// Reset guys color
	level.squad[ "ALLY_ALPHA" ]enable_ai_color(	 );
	level.squad[ "ALLY_BRAVO" ]enable_ai_color(	 );

	// Disconnect paths on the door
	level.assembly_room_door.connector DisconnectPaths();
}

//================================================================================================
// AMBUSH ROOM DESK SEARCH & TYPING
//================================================================================================
// Ally Alpha loops directing player to use the computer
ambush_get_on_computer_player_nag()
{
	anim_node = getstruct( "ambush_anim_node", "script_noteworthy" );
	anim_node anim_reach_solo( self, "tell_player_get_data" );	
	anim_node thread anim_loop_solo( self, "tell_player_get_data" );
	//self thread ambush_loop_flashbang_react( anim_node, "tell_player_get_data" );

	// Alpha is part of the breach anim, so stop this one when scene starts
	flag_wait( "ambush_triggered" );

	self StopAnimScripted();
	anim_node notify( "stop_loop" );
	self enable_ai_color();
}

// Ally Bravo knocks stuff over and starts typing
ambush_bravo_computer_use()
{
	// Setup the props
	// No need for these to be in radiant since the player never sees them before the anim first frame.
	desk_chair	   = spawn_anim_model( "desk_chair" );
	desk_phone	   = spawn_anim_model( "desk_phone" );
	desk_trash_can = spawn_anim_model( "desk_trash_can" );
	desk_book01	   = spawn_anim_model( "desk_book01" );
	desk_book02	   = spawn_anim_model( "desk_book02" );
	desk_book03	   = spawn_anim_model( "desk_book03" );
	desk_book04	   = spawn_anim_model( "desk_book04" );
	desk_book05	   = spawn_anim_model( "desk_book05" );
	desk_book06	   = spawn_anim_model( "desk_book06" );
	desk_book07	   = spawn_anim_model( "desk_book07" );
	desk_keyboard  = spawn_anim_model( "desk_keyboard" );

	guys					 = [];
	guys[ "desk_chair"	   ] = desk_chair;
	guys[ "desk_phone"	   ] = desk_phone;
	guys[ "desk_trash_can" ] = desk_trash_can;
	guys[ "desk_book01"	   ] = desk_book01;
	guys[ "desk_book02"	   ] = desk_book02;
	guys[ "desk_book03"	   ] = desk_book03;
	guys[ "desk_book04"	   ] = desk_book04;
	guys[ "desk_book05"	   ] = desk_book05;
	guys[ "desk_book06"	   ] = desk_book06;
	guys[ "desk_book07"	   ] = desk_book07;
	guys[ "desk_keyboard"  ] = desk_keyboard;

	// Anim first frame the parts
	anim_node = getstruct( "desk_search_bravo_node", "script_noteworthy" );
	anim_node anim_first_frame( guys, "ambush_bravo_desk_search" );

	// Handle the desk search chair anim collision
	chair_col = GetEnt( "desk_search_anim_collision", "targetname" );
	chair_col_post = GetEnt( "desk_search_anim_collision_post", "targetname" );
	chair_col_post NotSolid();

	// Wait for start...
	flag_wait( "entered_pre_ambush_room" );

	// Intro
	anim_node anim_reach_solo( self, "ambush_bravo_desk_search" );

	// Play the desk search anim
	guys[ "ally_bravo" ] = self;
	self thread maps\factory_audio::sfx_keegan_desk();
	desk_chair thread desk_search_chair( chair_col, chair_col_post );
	anim_node anim_single( guys, "ambush_bravo_desk_search" );

	// Typing loop
	anim_node = getstruct( "desk_search_bravo_node", "script_noteworthy" );
	anim_node thread anim_loop_solo( self, "bravo_typing" );
	//self thread ambush_loop_flashbang_react( anim_node, "bravo_typing" );

	// Bravo is not part of the breach scene, so let him continue untill the breach door explodes
	flag_wait( "ambush_start_fx" );

	// Delete the chair since its pretty big
	desk_chair Delete();
	chair_col_post NotSolid();
	chair_col_post Delete();

	self StopAnimScripted();
	anim_node notify( "stop_loop" );
	self enable_ai_color();

	/*
	// Wait for cleanup
	flag_wait( "ambush_player_in_office" );
	desk_chair delete();
	desk_phone delete();
	desk_trash_can delete();
	desk_book01 delete();
	desk_book02 delete();
	desk_book03 delete();
	desk_book04 delete();
	desk_book05 delete();
	desk_book06 delete();
	desk_book07 delete();
	desk_keyboard delete();
	*/
}

// Handles the moving chair collision during the desk search anim
desk_search_chair( before, after )
{
	// Link the collision to the chair
	before LinkTo( self, "tag_chair_collision" );

	// JR - Should use a notetrack for this to be precise and safe
	wait 4.0;

	// Delete the buffer zone
	buffer = GetEnt( "ambush_desk_search_buffer", "targetname" );
	buffer NotSolid();
	buffer delete();

	// Wait for player to get away from the clip, before we swap
	// Prevents cases were collision is turned on inside the player
	chair_org = self.origin;
	while( players_within_distance( 64, chair_org ) )
	{
		wait 1.0;
	}

	before Unlink();
	before NotSolid();
	before delete();

	// Chair is done moving, swap the collision
	after Solid();
}

// Ally Charlie plays simple arrival and typing
ambush_charlie_computer_use()
{
	// Intro with desk disruption
	anim_node = getstruct( "ambush_anim_node", "script_noteworthy" );
	anim_node anim_reach_solo( self, "ambush_charlie_desk_search" );

	// JR - safety hack since the anim reach could finish before or after the ambush is triggered
	if ( flag( "ambush_triggered" ) )
	{
		self StopAnimScripted();
		anim_node notify( "stop_loop" );
		self enable_ai_color();
		return;
	}
	
	// Play the anim
	anim_node anim_single_solo( self, "ambush_charlie_desk_search" );

	// JR - safety hack since the anim single could finish before or after the ambush is triggered
	if ( flag( "ambush_triggered" ) )
	{
		self StopAnimScripted();
		anim_node notify( "stop_loop" );
		self enable_ai_color();
		return;
	}
	
	// Typing loop
	anim_node = getstruct( "ambush_anim_node", "script_noteworthy" );
	//anim_node anim_reach_solo( self, "charlie_typing" );
	anim_node thread anim_loop_solo( self, "charlie_typing" );
	//self thread ambush_loop_flashbang_react( anim_node, "charlie_typing" );

	// Charlie is part of the breach anim, so stop this one when scene starts
	flag_wait( "ambush_triggered" );

	self StopAnimScripted();
	anim_node notify( "stop_loop" );
	self enable_ai_color();
}

// Allows allies to react to being flashbanged while playing their looping idles
ambush_loop_flashbang_react( node, anim_name )
{
	level endon( "ambush_start_fx" );
	level endon( "stop_flashbang_react" );

	while ( 1 )
	{
		if ( flag( "player_used_computer" ) )
		{
			return;
		}
		
		self waittill( "flashbang", origin, amount_distance, amount_angle, attacker );
		waittillframeend;

		// Check for flashbang strength
		time = 0;
		if ( !IsDefined( self.flashEndTime ) )
		{
			continue;
		}
		else
		{
			flash_left = self.flashEndTime - GetTime();
			time	   = ( ( flash_left / 1000 ) + 0.25 );

			// Not enough flash to care about
			if ( time < 0.5 )
			{
				continue;
			}
		}

		self StopAnimScripted();
		node notify( "stop_loop" );

		self notify( "flashbang", origin, amount_distance, amount_angle, attacker );
		wait time;

		node anim_reach_solo( self, anim_name );
		node thread anim_loop_solo( self, anim_name, "stop_loop" );

		wait 0.25;
	}
}

//================================================================================================
// AMBUSH ANIMS
//================================================================================================
// Main ambush anim script
ambush()
{
	anim_node = getstruct( "ambush_anim_node", "script_noteworthy" );

	level thread ambush_player( anim_node );
	level thread ambush_ally( anim_node );
	level thread ambush_enemies( anim_node );
	level thread ambush_props( anim_node );
	level thread ambush_door( anim_node );
	level thread ambush_cables( anim_node );
}

// First frame setup for some of the props
ambush_anim_setup()
{
	// Anim node
	anim_node = getstruct( "ambush_anim_node", "script_noteworthy" );

	// Props
	factory_ambush_desk			 = GetEnt ( "factory_ambush_desk", "targetname" ); // = spawn_anim_model( "factory_ambush_desk" );
	factory_ambush_desk.animname = "factory_ambush_desk";
	factory_ambush_desk assign_animtree();

	factory_ambush_mouse01	  = spawn_anim_model( "factory_ambush_mouse01" );
	factory_ambush_mouse02	  = spawn_anim_model( "factory_ambush_mouse02" );
	factory_ambush_keyboard02 = spawn_anim_model( "factory_ambush_keyboard02" );
	factory_ambush_clipboard  = spawn_anim_model( "factory_ambush_clipboard" );
	factory_ambush_cup		  = spawn_anim_model( "factory_ambush_cup" );
	// Monitor commented out for E3 trailer. Uncomment all in this function to replace it.
	/*
	factory_ambush_computer	  = spawn_anim_model( "factory_ambush_computer" );
	factory_ambush_monitor01  = spawn_anim_model( "factory_ambush_monitor01" );
	*/
	factory_ambush_monitor02  = spawn_anim_model( "factory_ambush_monitor02" );

	// Setup the glowy versions
	/*
	monitor = GetEnt( "ambush_monitor_glow", "targetname" );
	monitor.origin = factory_ambush_monitor01.origin;
	monitor.angles = factory_ambush_monitor01.angles;
	monitor linkTo( factory_ambush_monitor01 );
	
	device = GetEnt( "ambush_device_glow", "targetname" );
	device.origin = factory_ambush_computer.origin;
	device.angles = factory_ambush_computer.angles;
	device linkTo( factory_ambush_computer );
	*/

	level.factory_ambush_props								  = [];
	level.factory_ambush_props[ "factory_ambush_desk"		] = factory_ambush_desk;
	level.factory_ambush_props[ "factory_ambush_mouse01"	] = factory_ambush_mouse01;
	level.factory_ambush_props[ "factory_ambush_mouse02"	] = factory_ambush_mouse02;
	level.factory_ambush_props[ "factory_ambush_keyboard02" ] = factory_ambush_keyboard02;
	level.factory_ambush_props[ "factory_ambush_clipboard"	] = factory_ambush_clipboard;
	level.factory_ambush_props[ "factory_ambush_cup"		] = factory_ambush_cup;
	/*
	level.factory_ambush_props[ "factory_ambush_computer"	] = factory_ambush_computer;
	level.factory_ambush_props[ "factory_ambush_monitor01"	] = factory_ambush_monitor01;
	*/
	
	level.factory_ambush_props[ "factory_ambush_monitor02"	] = factory_ambush_monitor02;
	anim_node anim_first_frame( level.factory_ambush_props, "ambush_props" );
	
	// Hides the bink poly. Delete these two lines after E3 trailer.
	monitor_screen = GetEnt( "ambush_breach_monitor_screen", "targetname" );
	monitor_screen Delete();

	// Attach the monitor material
	/*
	monitor_screen = GetEnt( "ambush_breach_monitor_screen", "targetname" );
	monitor_screen LinkTo( factory_ambush_monitor01 );
	thread maps\factory_fx::fx_assembly_monitor_bink_init();
	*/
	// Start glowing
	kb = GetEnt( "ambush_desk_kb", "targetname" );
	kb glow();
}

// Player
ambush_player( node )
{
	level.player.active_anim = true;
	level.player FreezeControls( true );
	level.player DisableWeapons();
	level.player.ignoreme = true; // Dont let the player get shot when he cant shoot back
	
	thread change_dof();
	
	// Force stand
	level.player SetStance( "stand" );
	level.player AllowProne( false );
	level.player AllowCrouch( false );

	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();

	guys				 = [];
	guys[ "player_rig" ] = player_rig;

	thread maps\factory_audio::ambush_start_intro_foley_sfx();
	
	node anim_first_frame( guys, "ambush_player" );

	// Link view arcs
	r_arc = 30;
	l_arc = 30;
	t_arc = 40;
	b_arc = 25;

	// Link player to delta on rig
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.5, 0.25, 0.25 );
	wait 0.5;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, r_arc, l_arc, t_arc, b_arc, true );
	player_rig Show();

	// Play the anim
	level notify( "play_ambush_anim" );
	node thread anim_single( guys, "ambush_player" );
	
	wait 20.333;
	
	level.player EnableWeapons();
	level.player FreezeControls( false );
	level.player.active_anim = false;

	wait 0.800;

	level.player.ignoreme = false;
	
	// Unlink and cleanup
	level.player Unlink();
	player_rig Delete();
	level.player AllowProne( true );
	level.player AllowCrouch( true );
}

change_dof()
{    
    maps\_art::dof_enable_script( 0, 0, 4, 55, 120, 1.5, 0.25 );
    
    wait 18.93;
    
    maps\_art::dof_enable_script( 0, 100, 10, 100, 1000, 0, 0.25 );
    
    wait 1.0;
    
    maps\_art::dof_disable_script( 1.25 );
}

change_dof_jungle_intro()
{
    maps\_art::dof_enable_script( 0, 0, 4, 0, 100, 1, 0.15 );
    
    wait 1.233;
    
    maps\_art::dof_enable_script( 0, 0, 4, 300, 500, 1, 0.25 );
    
    wait 3.0;
    
    maps\_art::dof_enable_script( 0, 0, 4, 100, 450, 1.5, 0.25 );
    
    wait 1.67;
    
    maps\_art::dof_disable_script( 1.25 );
}

// Setup the ally portion of the anim
ambush_ally( anim_node )
{
	// Stop any flashbang reaction anim
	//level notify( "stop_flashbang_react" );
	//foreach( ally in level.squad )
	//{
	//	ally StopAnimScripted();
	//}

											//   guy 						    anime
	anim_node thread anim_first_frame_solo( level.squad[ "ALLY_ALPHA" ]	 , "ambush_ally01" );
	anim_node thread anim_first_frame_solo( level.squad[ "ALLY_CHARLIE" ], "ambush_ally02" );

	level waittill( "play_ambush_anim" );
								   		//   guy 						   anime 		   
	anim_node thread anim_single_solo( level.squad[ "ALLY_ALPHA" ]	, "ambush_ally01" );
	anim_node thread anim_single_solo( level.squad[ "ALLY_CHARLIE" ], "ambush_ally02" );
}

// Animated fast ropers
ambush_enemies( node )
{
	window_guy_spawners = GetEntArray( "ambush_anim_breachers", "targetname" );
	window_guys			= [];
	//guy_heads			= [ "head_russian_military_d", "head_russian_military_f", "head_russian_military_dd", "head_russian_military_e" ];

	// Spawn breacher guys
	foreach ( i, spawner in window_guy_spawners )
	{
		guy				  = spawner spawn_ai( 1 );
		guy.animname	  = "generic";
		guy.goalradius	  = 0;
		guy.allowDeath	  = true;
		guy.favoriteenemy = level.player;
		guy.ignoreme	  = true;
		guy.threatbias	  = 5000;
		//guy SetLookAtEntity( level.player );
		//guy thread maps\factory_util::swap_head( guy_heads[ i ] );
		guy delayThread( 11, maps\factory_util::factory_set_ignoreme, false );
		window_guys[ window_guys.size ] = guy;
		guy enable_cqbwalk();
	}

	level waittill( "play_ambush_anim" );

	// Guy who runs in through door
	window_guys[ 0 ] magic_bullet_shield();
	node thread anim_single_solo( window_guys[ 0 ], "ambush_enemy01" );
	//node delayThread( 0.0, ::anim_single_solo, window_guys[ 0 ], "ambush_enemy01" );

	// Right window breacher
	node delayThread( 0.88, ::anim_single_solo, window_guys[ 1 ], "ambush_enemy02" );

	// Middle window breacher
	node delayThread( 0.05, ::anim_single_solo, window_guys[ 2 ], "ambush_enemy03" );

	// Left window breacher
	node delayThread( 0.4, ::anim_single_solo, window_guys[ 3 ], "ambush_enemy04" );


	// These enemis become favorite enemies after a while to guarantee they die quickly.
	flag_wait( "ambush_vignette_done" );
	wait 4.0;

	foreach( guy in window_guys )
	{
		if( isDefined( guy ) && isAlive( guy ))
		{
			guy.health = 1;
			guy.ignoreme = false;
			guy.threatbias = 10000;
		}
	}
	
	// Safer
	if( isDefined( window_guys[ 1 ] ))
	{
	level.squad[ "ALLY_ALPHA" ].favoriteenemy = window_guys[ 1 ];
		//level thread debugLine( level.squad[ "ALLY_ALPHA" ].origin, window_guys[ 1 ].origin, (1,1,0), 9999 );
	}
	if( isDefined( window_guys[ 2 ] ))
	{
	level.squad[ "ALLY_BRAVO" ].favoriteenemy = window_guys[ 2 ];
		//level thread debugLine( level.squad[ "ALLY_BRAVO" ].origin, window_guys[ 2 ].origin, (1,1,0), 9999 );
	}
	if( isDefined( window_guys[ 3 ] ))
	{
	level.squad[ "ALLY_CHARLIE" ].favoriteenemy = window_guys[ 3 ];
		//level thread debugLine( level.squad[ "ALLY_CHARLIE" ].origin, window_guys[ 3 ].origin, (1,1,0), 9999 );
	}

	// CF - TEMP HEADSHOT SCRIPTS FOR JOW TO REVIEW
	/*
	wait 19.37;
    headshot_location = spawn_tag_origin();
	headshot_location.origin = window_guys[ 0 ] GetTagOrigin( "J_Neck" );
	// play from the chest
	headshot_location.origin = (headshot_location.origin + (4, 0, -10) );
	headshot_location.angles = (headshot_location.angles+ (0, 0, 0) );
	PlayFXOnTag( level._effect[ "blood_gaz_driver" ], headshot_location, "tag_origin" );
	wait 0.09;
    headshot_location2 = spawn_tag_origin();
	headshot_location2.origin = window_guys[ 0 ] GetTagOrigin( "J_Neck" );
	// play from the head
	headshot_location2.origin = (headshot_location2.origin + (0, 0, 4) );
	headshot_location2.angles = (headshot_location2.angles+ (0, 0, 0) );
	PlayFXOnTag( level._effect[ "blood_gaz_driver" ], headshot_location2, "tag_origin" );
	wait 1;
	headshot_location Delete();
	headshot_location2 Delete();
	*/
}

debugLine( fromPoint, toPoint, color, durationFrames )
{
	for ( i = 0;i < durationFrames * 20;i++ )
	{
		line( fromPoint, toPoint, color );
		wait( 0.05 );
	}
}

// Props
ambush_props( node )
{
	AssertEx( IsDefined( level.factory_ambush_props ), "ambush_props Error: level.factory_ambush_props not defined" );

	// Re-enable the mantles
	mantles = GetEntArray( "ambush_window_mantle", "targetname" );
	foreach ( mantle in mantles )
	{
		mantle MoveZ( 100, 0.1 );
	}

	// Show the main animated keyboard
	factory_ambush_keyboard01						 = spawn_anim_model( "factory_ambush_keyboard01" );
	factory_ambush_usb_stick						 = spawn_anim_model( "factory_ambush_usb_stick" );
	first_frame_props[ "factory_ambush_keyboard01" ] = factory_ambush_keyboard01;
	first_frame_props[ "factory_ambush_usb_stick"  ] = factory_ambush_usb_stick;
	node anim_first_frame( first_frame_props, "ambush_props" );

	// Attach the PDA screen poly to the PDA
	usb_screen_poly = GetEnt( "ambush_breach_player_pda", "targetname" );
	usb_screen_poly Show();
	usb_screen_poly LinkTo( factory_ambush_usb_stick );

	// Play it
	level waittill( "play_ambush_anim" );
	
	props = array_merge( level.factory_ambush_props, first_frame_props );
	
	node thread anim_single( props, "ambush_props" );
	
	level waittill( "ambush_door_breached" );

	// Hide the pre breach geo
	pre_breach_props = GetEntArray( "ambush_desk_prop_pre", "targetname" );
	foreach ( ent in pre_breach_props )
	{
		if ( IsDefined( ent.script_parameters ) )
		{
			ent ConnectPaths();
			ent NotSolid();
		}
		ent Delete();
	}

	// Turn on post breach geo
	post_breach_props = GetEntArray( "ambush_desk_prop_post", "targetname" );
	foreach ( ent in post_breach_props )
	{
		ent Show();

		if ( IsDefined( ent.script_parameters ) )
		{
			ent Solid();
			ent DisconnectPaths();
		}
	}

	// Turn off the animated monitor screen
	// Commmented out for E3 trailer. Re-enable aterwards.
	/*
	monitor_screen = GetEnt( "ambush_breach_monitor_screen", "targetname" );
	monitor_screen Delete();
	*/
	// Turn off the 2 monitors on the wall
	screens = GetEntArray( "ambush_breach_wall_screen", "targetname" );
	foreach ( screen in screens )
	{
		screen Delete();
	}

	// Turn off monitors after animation is complete
	//level.factory_ambush_props[ "factory_ambush_monitor01"  ] SetModel( "com_pc_monitor_a" );
	//level.factory_ambush_props[ "factory_ambush_monitor02"  ] SetModel( "com_pc_monitor_a" );
	// com_pc_monitor_a

	usb_screen_poly Delete();
	factory_ambush_usb_stick Delete();

	waittillframeend;

	// Tell allies to take cover
	maps\factory_util::safe_trigger_by_targetname( "ambush_intro_ally_take_cover" );
}

// Trigger door explosion once the breach happens
ambush_door( node )
{
	factory_ambush_door		   = spawn_anim_model( "factory_ambush_door" );
	factory_ambush_tv		   = spawn_anim_model( "factory_ambush_tv" );
	factory_ambush_wall_debris = spawn_anim_model( "factory_ambush_wall_debris" );
	factory_ambush_airduct_01  = spawn_anim_model( "factory_ambush_airduct_01" );
	factory_ambush_airduct_02  = spawn_anim_model( "factory_ambush_airduct_02" );
	
	guys								 = [];
	guys[ "factory_ambush_door"		   ] = factory_ambush_door;
	guys[ "factory_ambush_tv"		   ] = factory_ambush_tv;
	guys[ "factory_ambush_wall_debris" ] = factory_ambush_wall_debris;
	guys[ "factory_ambush_airduct_01"  ] = factory_ambush_airduct_01;
	guys[ "factory_ambush_airduct_02"  ] = factory_ambush_airduct_02;

	level waittill( "ambush_door_breached" );
	node anim_first_frame( guys, "ambush_props" );
	node anim_single( guys, "ambush_props" );
}

ambush_cables( node )
{
	factory_ambush_ceiling_cables_01 = spawn_anim_model( "factory_ambush_ceiling_cables_01" );
	factory_ambush_ceiling_cables_02 = spawn_anim_model( "factory_ambush_ceiling_cables_02" );
	factory_ambush_ceiling_cables_03 = spawn_anim_model( "factory_ambush_ceiling_cables_03" );

	level.assembly_ceiling_cables										= [];
	level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_01" ] = factory_ambush_ceiling_cables_01;
	level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_02" ] = factory_ambush_ceiling_cables_02;
	level.assembly_ceiling_cables[ "factory_ambush_ceiling_cables_03" ] = factory_ambush_ceiling_cables_03;

	level waittill( "ambush_door_breached" );
	node anim_first_frame( level.assembly_ceiling_cables, "ambush_props" );
	node anim_single( level.assembly_ceiling_cables, "ambush_props" );	
}

ambush_notify_start_fx( guy )
{
	flag_set( "ambush_start_fx" );
}

ambush_notify_start_slomo( guy )
{
	level notify( "ambush_door_breached" );
	
	pre_breach_props = GetEntArray( "ambush_breach_prop_pre", "targetname" );
	foreach ( ent in pre_breach_props )
	{
		ent Delete();
	}
	
	source = GetEnt ( "ambush_breach_physics_push", "targetname" );
	PhysicsExplosionSphere( source.origin, 250, 100, 1 );
}

ambush_notify_glass_break( guy )
{
	level notify( "ambush_glass_break" );
}

// Fastrope in a guy from the ceiling
ambush_fastrope_do_anim( node_targetname, kill_guy, min_delay, max_delay )
{
	min_delay = min_delay * 1.0;
	max_delay = max_delay * 1.0;

	// Slight delay to add some natural variation to the ambush
	wait RandomFloatRange( min_delay, max_delay );

	fast_roper = self;
	node	   = GetEnt( node_targetname, "targetname" );

	rope = Spawn( "script_model", ( 0, 0, 0 ) );
	rope SetModel( "weapon_rappel_rope_long" );
	rope.origin	  = node.origin;
	rope.animname = "rope";
	rope assign_animtree();

	fast_roper.animname = "generic";

	guys			  = [];
	guys[ "generic" ] = fast_roper;
	guys[ "rope"	] = rope;

	node anim_single( guys, "bravo_rappel_drop" );

	if ( IsDefined( kill_guy ) && kill_guy == true )
	{
		fast_roper Kill();
	}

	// Clean up the rope
	rope Delete();
}

// Ambush throw smoke anim
ambush_ally_throw_smoke( target_targetname, anim_node_name, animname, dialogue, delay, enter_animname )
{
	self endon( "cleanup_grenade_throw" );

	// Optional delay for timing purposes
	wait delay;

	// Make sure the actor isnt interupted while anim reaching
	self thread maps\factory_util::disable_awareness();
	
	// Play the enter anim	
	anim_node = getstruct( anim_node_name, "script_noteworthy" );
	if ( IsDefined( enter_animname ) )
	{
		// Reach and play enter
		anim_node anim_reach_solo( self, enter_animname );
		anim_node anim_single_solo( self, enter_animname );
	}
	else
	{
		// No enter, so reach into the throw directly
		anim_node anim_reach_solo( self, animname );
	}

	// Play the throw
	anim_node thread anim_single_solo( self, animname );

	//IPrintLnBold( "playing throw anim" );
	
	// Create the grenade prop
	grenade_prop = Spawn( "script_model", self GetTagOrigin( "TAG_INHAND" ) );
	grenade_prop SetModel( "projectile_us_smoke_grenade" );
	grenade_prop LinkTo( self, "tag_inhand" );

	// CF - TEMP SMOKE GRENADE SCRIPTS FOR JOW TO REVIEW
	tagEnt_pre		  = spawn_tag_origin();
	tagEnt_pre.origin = grenade_prop.origin;
	tagEnt_pre LinkTo( grenade_prop );
	PlayFXOnTag( level._effect[ "factory_ambush_smoke_grenade_hand" ], tagEnt_pre, "tag_origin" );
	//PlayFXOnTag( level._effect[ "fire_extinguisher_exp" ], tagEnt_pre, "TAG_ORIGIN" );
	//PlayFXOnTag( level._effect[ "gazcookoff" ], tagEnt_pre, "TAG_ORIGIN" );
	//tagEnt_pre thread play_sound_on_tag("scn_factory_ambush_pull_smoke", "TAG_ORIGIN");

	// Handle the grenade prop
	self waittillmatch( "single anim", "grenade_throw" );
	
	// CF - TEMP SMOKE GRENADE SCRIPTS FOR JOW TO REVIEW
	//StopFXOnTag( level._effect[ "gazcookoff" ], tagEnt_pre, "tag_origin" );
	//StopFXOnTag( level._effect[ "fire_extinguisher_exp" ], tagEnt_pre, "tag_origin" );
	tagEnt_pre Delete();
	
	grenade_prop Delete();
	smoke_target_org = GetEnt( target_targetname, "targetname" );
	grenadeEnt = undefined;
	grenadeEnt		 = MagicGrenade( "smoke_grenade_factory", self GetTagOrigin( "TAG_INHAND" ), smoke_target_org.origin, 2 );
	if ( IsDefined( grenadeEnt ) )
	{
		tagEnt = grenadeEnt spawn_tag_origin();
		tagEnt LinkTo( grenadeEnt );
		PlayFXOnTag( level._effect[ "factory_ambush_grenade_trail_runner" ], tagEnt, "TAG_ORIGIN" );
		tagEnt thread play_sound_on_tag( "scn_factory_ambush_pull_smoke", "TAG_ORIGIN" );
		grenadeEnt thread ambush_spent_gas_grenade( smoke_target_org.script_noteworthy );
	
	// CF - TEMP SMOKE GRENADE SCRIPTS FOR JOW TO REVIEW
	//	PlayFXOnTag( level._effect[ "gazcookoff" ], tagEnt, "TAG_ORIGIN" );
	}

	// Play dialogue for smoke out
	if ( IsDefined( dialogue ) )
	{
		self smart_dialogue( dialogue );
	}

	// Set the actor back to normal
	anim_node waittill( animname );

	// Let them shoot, but keep pain reaction off since the anim put them in direct line of fire of the enemies.
	self maps\factory_util::enable_awareness();
	self.ignoreall = false;
	self.ignoreme  = false;
	self disable_dontevershoot();

	self enable_ai_color();

	wait 0.1;
	maps\factory_util::safe_trigger_by_targetname( "ambush_allies_after_smoke_pop" );
}

// Spawn a spent smoke grenade can
ambush_spent_gas_grenade( tname )
{
	can_model = GetEnt( tname, "targetname" );
	self waittill( "death" );

	can_model show();

	flag_wait( "thermal_battle_clear" );
	can_model delete();
}

// Smoke anim archetype
setup_smoke_archetype()
{
	archetype							= [];
	archetype[ "cqb" ][ "straight"	  ] = %factory_ambush_smoke_walkforward_01;
	archetype[ "cqb" ][ "straight_v2" ] = %factory_ambush_smoke_walkforward_01;

	register_archetype( "factory_smoke", archetype, true );
}

// Forces a few enemies to play smoke reaction anims
force_smoke_reaction_anims()
{
	thread ambush_enemy_walking_cough_01();
										  //   node_name 					     anim_name 							      idle_name 			 
	thread ambush_enemy_force_smoke_reaction( "ambush_force_smoke_reaction_01", "factory_ambush_smoke_CornerCrR_04"	   , "coverstand_hide_idle" );
	thread ambush_enemy_force_smoke_reaction( "ambush_force_smoke_reaction_02", "factory_ambush_smoke_CornerCrR_05"	   , "coverstand_hide_idle" );
	thread ambush_enemy_force_smoke_reaction( "ambush_force_smoke_reaction_03", "factory_ambush_smoke_walking_cough_03", "coverstand_hide_idle" );
}

// Walking cough 01
ambush_enemy_walking_cough_01()
{
	// If the player left the room early dont play this anim
	if ( flag( "player_left_ambush_room" ) )
	{
		return;
	}

	level.player waittill_notify_or_timeout( "use_thermal", 8 );

	//Baker: They can't see us, take em out!
	level.squad[ "ALLY_ALPHA" ] delayThread( 1.2, ::smart_dialogue, "factory_bkr_theycantseeus" );

	// Spawn a guy for this
	spawner = GetEnt( "ambush_walking_cough_01", "targetname" );
	guy		= spawner spawn_ai();
	if ( spawn_failed( guy ) )
	{
		//AssertMsg( "Error: walking_cough spawn failed. guy probably in view of player" );
		flag_set( "walking_cough_guy_done" );
		return;
	}

	guy.animname	  = "generic";
	guy.animating	  = true;
	guy.allowdeath	  = true;
	guy.oldgoalradius = 256;

	waittillframeend;

	// Get the anim node
	node = GetEnt( "ambush_walking_cough_node", "targetname" );
	node anim_single_solo( guy, "factory_ambush_smoke_walking_cough_01" );

	guy.animating = undefined;
	guy enable_cqbwalk();
	maps\factory_util::safe_set_goal_volume( [ guy ], "ambush_left_volume" );

	flag_set( "walking_cough_guy_done" );
}

// Forced smoke reaction
ambush_enemy_force_smoke_reaction( node_name, anim_name, idle_name, delay_time )
{
	// Get anim node
	node = GetEnt( node_name, "targetname" );

	// Make sure player isnt too close
	if ( IsDefined( node.radius ) )
	{
		if ( players_within_distance( node.radius, node.origin ) )
		{
			//AssertMsg( "Error: ambush_enemy_force_smoke_reaction_01() failed, player too close" );
			return;
		}
	}

	// Try to find a nearby enemy
	search_attempts = 3;
	excluders		= [];
	guy				= undefined;
	while ( search_attempts > 0 )
	{
		// JR - hack because get_closest_ai doesnt handle excluders like it should
		if ( excluders.size == 0 )
		{
			guy = get_closest_ai( node.origin, "axis" );	
		}
		else
		{
			guy = get_closest_ai( node.origin, "axis", excluders );
		}

		// Safety check - Is he alive, and not playing some other forced reaction anim?
		if ( IsAlive( guy ) && !IsDefined( guy.animating ) )
		{
			break;
		}
		else
		{
			// This guy is no good, keep looking
			excluders[ excluders.size ] = guy;
			search_attempts--;
			if ( search_attempts <= 0 )
			{
				AssertMsg( "Error: ambush_enemy_force_smoke_reaction_01() failed to find a valid enemy" );
				return;
			}
		}
	}

	guy.animating	  = true;
	guy.allowdeath	  = true;
	guy.animname	  = "generic";
	guy.oldgoalradius = 256;

	waittillframeend;

	guys			  = [];
	guys[ "generic" ] = guy;

	// Go to the anim location and idle
	// JR - They must idle because we delay the untill thermal has been turned on.
	// JR - The anims are pretty dang long, so this may not really be necessary.
	//node anim_reach_idle( guys, anim_name, idle_name );
	node anim_reach( guys, anim_name );

	// Wait for thermals to go on
	// JR - TODO test this without the wait
	//level.player waittill_notify_or_timeout( "use_thermal", 8 );

	if ( IsDefined( delay_time ) )
	{
		wait delay_time;

		// Have to safety check again after delay
		if ( !IsDefined( guy ) || !IsAlive( guy ) )
		{
			return;
		}
	}

	if ( IsDefined( guy ) && IsAlive( guy ) )
	{
		// Play the anim
		node anim_single_solo( guy, anim_name );
	}

	// Set him free
	if ( IsDefined( guy ) && IsAlive( guy ) )
	{
		guy.animating = undefined;
	}
}

kill_me( ent )
{
	ent kill_no_react();
}

kill_no_react()
{
if ( !IsAlive( self ) )
        return;

	if ( IsDefined( self.magic_bullet_shield ) )
	{	
		self stop_magic_bullet_shield();
	}

	self.allowDeath = true;
	self.a.nodeath	= true;
    self set_battlechatter( false );

    self Kill();
}

rag_doll( ent )
{
	ent StartRagdoll();
	ent Kill();
}

//================================================================================================
// ASSEMBLY LINE AUTOMATION
//================================================================================================
factory_assembly_line_play()
{
	level endon( "stop_assembly_line" );

	// Don't start the assembly line untill right before the room
	//level waittill( "start_assembly_line" );

	// The animations starts playing at increased speed
	// in order to fill out the entire room
	level.speed_up_multiplier = 20.0;

	// Get and save the anim node
	anim_node					  = getstruct( "automated_assemebly_line", "script_noteworthy" );
	level.assembly_anim_node	  = anim_node;
	anim_node					  = getstruct( "automated_assemebly_line_back", "script_noteworthy" );
	level.assembly_anim_node_back = anim_node;

	// Setup the pieces
	thread factory_auto_play_front();
	thread factory_auto_play_back();

	// Setup the arm malfunction
	thread ambush_arm_malfunction();

	// Delete it all for testing
	//level thread factory_assembly_line_delete();
}

// Removes the assembly line models
factory_assembly_line_delete()
{
	ents = [];
	ents = GetEntArray( "assembly_line_anim_model", "script_noteworthy" );
	foreach ( ent in ents )
	{
		ent Delete();
	}
}

factory_auto_play_front()
{
	level endon( "stop_assembly_line" );

	level.factory_assembly_line_front_station01_arm_a			= spawn_anim_model( "factory_assembly_line_front_station01_arm_a" );
	level.factory_assembly_line_front_station01_arm_a ThermalDrawEnable();
	
	level.factory_assembly_line_front_station01_arm_b			= spawn_anim_model( "factory_assembly_line_front_station01_arm_b" );
	level.factory_assembly_line_front_station01_arm_b ThermalDrawEnable();
	
	level.factory_assembly_line_front_station02_arm_a			= spawn_anim_model( "factory_assembly_line_front_station02_arm_a" );
	level.factory_assembly_line_front_station02_arm_a ThermalDrawEnable();
	
	level.factory_assembly_line_front_station02_arm_b			= spawn_anim_model( "factory_assembly_line_front_station02_arm_b" );
	level.factory_assembly_line_front_station02_arm_b ThermalDrawEnable();
	
	level.factory_assembly_line_front_station02_arm_c			= spawn_anim_model( "factory_assembly_line_front_station02_arm_c" );
	level.factory_assembly_line_front_station02_arm_c ThermalDrawEnable();
	
	level.factory_assembly_line_front_station02_arm_d			= spawn_anim_model( "factory_assembly_line_front_station02_arm_d" );
	level.factory_assembly_line_front_station02_arm_d ThermalDrawEnable();
	
	level.factory_assembly_line_front_station03_arm_a			= spawn_anim_model( "factory_assembly_line_front_station03_arm_a" );
	level.factory_assembly_line_front_station03_arm_a ThermalDrawEnable();
	
	level.factory_assembly_line_front_station03_arm_b			= spawn_anim_model( "factory_assembly_line_front_station03_arm_b" );
	level.factory_assembly_line_front_station03_arm_b ThermalDrawEnable();
	
	level.factory_assembly_line_front_station03_arm_c			= spawn_anim_model( "factory_assembly_line_front_station03_arm_c" );
	level.factory_assembly_line_front_station03_arm_c ThermalDrawEnable();
	
	level.factory_assembly_line_front_station03_arm_d			= spawn_anim_model( "factory_assembly_line_front_station03_arm_d" );
	level.factory_assembly_line_front_station03_arm_d ThermalDrawEnable();
	
	level.factory_assembly_line_front_station04_arm_a			= spawn_anim_model( "factory_assembly_line_front_station04_arm_a" );
	level.factory_assembly_line_front_station04_arm_a ThermalDrawEnable();
	
	level.factory_assembly_line_front_station04_arm_b			= spawn_anim_model( "factory_assembly_line_front_station04_arm_b" );
	level.factory_assembly_line_front_station04_arm_b ThermalDrawEnable();
	
	level.factory_assembly_line_front_station04_arm_c			= spawn_anim_model( "factory_assembly_line_front_station04_arm_c" );
	level.factory_assembly_line_front_station04_arm_c ThermalDrawEnable();
	
	level.factory_assembly_line_front_station05_arm_a			= spawn_anim_model( "factory_assembly_line_front_station05_arm_a" );
	level.factory_assembly_line_front_station05_arm_a ThermalDrawEnable();
	
	level.factory_assembly_line_front_station05_arm_b			= spawn_anim_model( "factory_assembly_line_front_station05_arm_b" );
	level.factory_assembly_line_front_station05_arm_b ThermalDrawEnable();
	
	level.factory_assembly_line_front_station05_arm_c			= spawn_anim_model( "factory_assembly_line_front_station05_arm_c" );
	level.factory_assembly_line_front_station05_arm_c ThermalDrawEnable();
	
	level.factory_assembly_line_front_station06_arm_a			= spawn_anim_model( "factory_assembly_line_front_station06_arm_a" );
	level.factory_assembly_line_front_station06_arm_a ThermalDrawEnable();
	
	level.factory_assembly_line_front_station06_arm_b			= spawn_anim_model( "factory_assembly_line_front_station06_arm_b" );
	level.factory_assembly_line_front_station06_arm_b ThermalDrawEnable();
	
	// The time to wait before spawning another iteration
	delay_between_spawns = 20.0; // THIS NEEDS TO BE A FLOAT
	num_fast_spawns		 = 4;

	// Start the loop to spawn front pieces
	while ( true )
	{
		// Spawn a new iteration of the anim
		thread spawn_front_piece(  );
		thread spawn_front_piece_belt(	);

		// Spawn a fast one
		if ( num_fast_spawns > 0 )
		{
			num_fast_spawns--;
			wait ( delay_between_spawns / level.speed_up_multiplier ); // Decrease the delay by the proper amount

			// Thats enough, turn down the speed
			if ( num_fast_spawns == 0 )
			{
				flag_set( "factory_assembly_line_resume_speed_front" );
			}
		}
		else
		{
			wait delay_between_spawns;
		}
	}
}

factory_auto_play_back()
{
	level endon( "stop_assembly_line" );

	level.factory_assembly_line_back_station01			= spawn_anim_model( "factory_assembly_line_back_station01" );
	level.factory_assembly_line_back_station01 ThermalDrawEnable();
	
	level.factory_assembly_line_back_station02			= spawn_anim_model( "factory_assembly_line_back_station02" );
	level.factory_assembly_line_back_station02 ThermalDrawEnable();
	
	level.factory_assembly_line_back_station03			= spawn_anim_model( "factory_assembly_line_back_station03" );
	level.factory_assembly_line_back_station03 ThermalDrawEnable();
	
	level.factory_assembly_line_back_station04			= spawn_anim_model( "factory_assembly_line_back_station04" );
	level.factory_assembly_line_back_station04 ThermalDrawEnable();
	
	level.factory_assembly_line_back_station05			= spawn_anim_model( "factory_assembly_line_back_station05" );
	level.factory_assembly_line_back_station05 ThermalDrawEnable();
	
	level.factory_assembly_line_back_turn_rail_track			= spawn_anim_model( "factory_assembly_line_back_turn_rail_track" );
	
	// The time to wait before spawning another iteration
	delay_between_spawns = 11.4; // THIS NEEDS TO BE A FLOAT
	num_fast_spawns		 = 11;

	// Start the loop to spawn front pieces
	while ( true )
	{
		// Spawn a new iteration of the anim
		thread spawn_back_piece();

		// Spawn a fast one
		if ( num_fast_spawns > 0 )
		{
			num_fast_spawns--;
			wait ( delay_between_spawns / level.speed_up_multiplier ); // Decrease the delay by the proper amount

			// Thats enough, turn down the speed
			if ( num_fast_spawns == 0 )
			{
				flag_set( "factory_assembly_line_resume_speed_back" );
			}
		}
		else
		{
			wait delay_between_spawns;
		}
	}

}

#using_animtree( "script_model" );
// Creates a new animated "tank chassis"
spawn_front_piece()
{
	if( flag( "stop_assembly_line" ))
	{
		return;	
	}

	// Create animated prop
	front_moving_piece			= spawn_anim_model( "front_moving_piece" );
	front_moving_piece.animname = "front_moving_piece";
	front_moving_piece ThermalDrawEnable();
	
	// Get a mover prefab ( collision and audio nodes )
	front_moving_piece maps\factory_ambush::attach_mover_prefab();
	
	// Setup the anim speed controls
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, front_moving_piece, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", front_moving_piece );
	}

	// Play the anim
	if( isDefined( level.assembly_anim_node ))
	{
		level.assembly_anim_node anim_single_solo( front_moving_piece, "automated_assemebly_line", undefined, 0.001 );
	}
		
	// Unlink the mover prefab
	front_moving_piece maps\factory_ambush::detach_mover_prefab();

	//del anim model
	front_moving_piece Delete();
}

spawn_front_piece_belt()
{
	if( flag( "stop_assembly_line" ))
	{
		return;	
	}

	//create animed prop
	front_moving_piece_belt			 = spawn_anim_model( "front_moving_piece_belt" );
	front_moving_piece_belt.animname = "front_moving_piece_belt";
	
	// Get a mover prefab ( collision and audio nodes )
	//front_moving_piece maps\factory_ambush::attach_mover_prefab();
	
	// Setup the anim speed controls
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, front_moving_piece_belt, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", front_moving_piece_belt );
	}

	// Play the anim
	if( isDefined( level.assembly_anim_node ))
	{
		level.assembly_anim_node anim_single_solo( front_moving_piece_belt, "automated_assemebly_line", undefined, 0.001 );
	}
		
	// Unlink the mover prefab
	//front_moving_piece maps\factory_ambush::detach_mover_prefab();

	//del anim model
	front_moving_piece_belt Delete();
}

// Creates a new animated "tank turret"
spawn_back_piece()
{	
	if( flag( "stop_assembly_line" ))
	{
		return;	
	}

	//create animed prop
	back_moving_piece		   = spawn_anim_model( "back_moving_piece" );
	back_moving_piece.animname = "back_moving_piece";

	// Setup the anim speed controls
	if ( !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, back_moving_piece, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_back", back_moving_piece );
	}

	// Play the anim
	if( isDefined( level.assembly_anim_node_back ))
	{
		level.assembly_anim_node_back anim_single_solo( back_moving_piece, "automated_assemebly_line", undefined, 0.001 );
	}
	
	//del anim model
	back_moving_piece Delete();
}

front_station_start_01( piece )
{
	level endon( "stop_assembly_line" );

	station_01													= [];
	station_01[ "factory_assembly_line_front_station01_arm_a" ] = level.factory_assembly_line_front_station01_arm_a;
	station_01[ "factory_assembly_line_front_station01_arm_b" ] = level.factory_assembly_line_front_station01_arm_b;
	
	level.factory_assembly_line_front_station01_arm_a PlaySound( "scn_factory_assembly_tank_arm01_ss" );

	// Spawn scripts that speed up the anim
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate, station_01, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", station_01 );
	}

	if( isDefined( level.assembly_anim_node ) && isDefined( station_01 ))
	{
		level.assembly_anim_node anim_single( station_01, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node anim_first_frame( station_01, "automated_assemebly_line" );
	}
}

front_station_start_02( piece )
{
	level endon( "stop_assembly_line" );

	station_02													= [];
	station_02[ "factory_assembly_line_front_station01_arm_a" ] = level.factory_assembly_line_front_station02_arm_a;
	station_02[ "factory_assembly_line_front_station01_arm_b" ] = level.factory_assembly_line_front_station02_arm_b;
	station_02[ "factory_assembly_line_front_station01_arm_c" ] = level.factory_assembly_line_front_station02_arm_c;
	station_02[ "factory_assembly_line_front_station01_arm_d" ] = level.factory_assembly_line_front_station02_arm_d;
	
	level.factory_assembly_line_front_station02_arm_a PlaySound( "scn_factory_assembly_tank_arm02_ss" );

	// Spawn scripts that speed up the anim
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate, station_02, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", station_02 );
	}

	if( isDefined( level.assembly_anim_node ) && isDefined( station_02 ))
	{
		level.assembly_anim_node anim_single( station_02, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node anim_first_frame( station_02, "automated_assemebly_line" );
	}
}

front_station_start_03( piece )
{	
	level endon( "stop_assembly_line" );

	station_03													= [];
	station_03[ "factory_assembly_line_front_station03_arm_a" ] = level.factory_assembly_line_front_station03_arm_a;
	station_03[ "factory_assembly_line_front_station03_arm_b" ] = level.factory_assembly_line_front_station03_arm_b;
	station_03[ "factory_assembly_line_front_station03_arm_c" ] = level.factory_assembly_line_front_station03_arm_c;
	station_03[ "factory_assembly_line_front_station03_arm_d" ] = level.factory_assembly_line_front_station03_arm_d;
	
	level.factory_assembly_line_front_station03_arm_a PlaySound( "scn_factory_assembly_tank_arm03_ss" );

	// Spawn scripts that speed up the anim
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate, station_03, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", station_03 );
	}

	if( isDefined( level.assembly_anim_node ) && isDefined( station_03 ))
	{
		level.assembly_anim_node anim_single( station_03, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node anim_first_frame( station_03, "automated_assemebly_line" );
	}
}

front_station_start_04( piece )
{
	level endon( "stop_assembly_line" );

	station_04													= [];
	station_04[ "factory_assembly_line_front_station04_arm_a" ] = level.factory_assembly_line_front_station04_arm_a;
	station_04[ "factory_assembly_line_front_station04_arm_b" ] = level.factory_assembly_line_front_station04_arm_b;
	station_04[ "factory_assembly_line_front_station04_arm_c" ] = level.factory_assembly_line_front_station04_arm_c;
		
	level.factory_assembly_line_front_station04_arm_a PlaySound( "scn_factory_assembly_tank_arm04_ss" );

	// Spawn scripts that speed up the anim
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate, station_04, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", station_04 );
	}

	if( isDefined( level.assembly_anim_node ) && isDefined( station_04 ))
	{
		level.assembly_anim_node anim_single( station_04, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node anim_first_frame( station_04, "automated_assemebly_line" );
	}
}

front_station_start_05( piece )
{
	level endon( "ambush_arm_malfunction" );

	// This specific arm blows up, so we need a way to end the regular anim
	if ( flag( "ambush_arm_malfunction" ) )
	{
		return;
	}
	
	station_05													= [];
	station_05[ "factory_assembly_line_front_station05_arm_a" ] = level.factory_assembly_line_front_station05_arm_a;
	station_05[ "factory_assembly_line_front_station05_arm_b" ] = level.factory_assembly_line_front_station05_arm_b;
	station_05[ "factory_assembly_line_front_station05_arm_c" ] = level.factory_assembly_line_front_station05_arm_c;
	
	level.factory_assembly_line_front_station05_arm_a PlaySound( "scn_factory_assembly_tank_arm05_ss" );

	// Spawn scripts that speed up the anim
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate, station_05, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", station_05 );
	}

	if( isDefined( level.assembly_anim_node ) && isDefined( station_05 ))
	{
		level.assembly_anim_node anim_single( station_05, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node anim_first_frame( station_05, "automated_assemebly_line" );
	}
}

front_station_start_06( piece )
{
	level endon( "stop_assembly_line" );

	station_06													= [];
	station_06[ "factory_assembly_line_front_station06_arm_a" ] = level.factory_assembly_line_front_station06_arm_a;
	station_06[ "factory_assembly_line_front_station06_arm_b" ] = level.factory_assembly_line_front_station06_arm_b;
	
	// Spawn scripts that speed up the anim
	if ( !flag( "factory_assembly_line_resume_speed_front" ) )
	{
		delayThread( 0.1, ::anim_set_rate, station_06, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_front", station_06 );
	}

	if( isDefined( level.assembly_anim_node ) && isDefined( station_06 ))
	{
		level.assembly_anim_node anim_single( station_06, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node anim_first_frame( station_06, "automated_assemebly_line" );
	}
}

back_station_start_01( piece )
{
	level endon( "stop_assembly_line" );

	//play station vignette
	level.factory_assembly_line_back_station01 PlaySound( "scn_factory_assembly_back_arm_ss" );

	if ( !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, level.factory_assembly_line_back_station01, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_back", level.factory_assembly_line_back_station01 );
	}

	if( isDefined( level.assembly_anim_node_back ) && isDefined( level.factory_assembly_line_back_station01 ))
	{
		level.assembly_anim_node_back anim_single_solo( level.factory_assembly_line_back_station01, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node_back anim_first_frame_solo( level.factory_assembly_line_back_station01, "automated_assemebly_line" );
	}
}

back_station_start_02( piece )
{
	level endon( "stop_assembly_line" );

	//play station vignette
	level.factory_assembly_line_back_station02 PlaySound( "scn_factory_assembly_back_arm_ss" );

	if ( !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, level.factory_assembly_line_back_station02, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_back", level.factory_assembly_line_back_station02 );
	}

	if( isDefined( level.assembly_anim_node_back ) && isDefined( level.factory_assembly_line_back_station02 ))
	{
		level.assembly_anim_node_back anim_single_solo( level.factory_assembly_line_back_station02, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node_back anim_first_frame_solo( level.factory_assembly_line_back_station02, "automated_assemebly_line" );
	}
}

back_station_start_03( piece )
{
	level endon( "stop_assembly_line" );

	//play station vignette
	level.factory_assembly_line_back_station03 PlaySound( "scn_factory_assembly_back_arm_ss" );

	if ( !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, level.factory_assembly_line_back_station03, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_back", level.factory_assembly_line_back_station03 );
	}

	if( isDefined( level.assembly_anim_node_back ) && isDefined( level.factory_assembly_line_back_station03 ))
	{
		level.assembly_anim_node_back anim_single_solo( level.factory_assembly_line_back_station03, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node_back anim_first_frame_solo( level.factory_assembly_line_back_station03, "automated_assemebly_line" );
	}
}

back_station_start_04( piece )
{
	level endon( "stop_assembly_line" );

	//play station vignette
	level.factory_assembly_line_back_station04 PlaySound( "scn_factory_assembly_back_arm_ss" );

	if ( !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, level.factory_assembly_line_back_station04, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_back", level.factory_assembly_line_back_station04 );
	}

	if( isDefined( level.assembly_anim_node_back ) && isDefined( level.factory_assembly_line_back_station04 ))
	{
		level.assembly_anim_node_back anim_single_solo( level.factory_assembly_line_back_station04, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node_back anim_first_frame_solo( level.factory_assembly_line_back_station04, "automated_assemebly_line" );
	}
}

back_station_start_05( piece )
{
	level endon( "stop_assembly_line" );

	//play station vignette
	level.factory_assembly_line_back_station05 PlaySound( "scn_factory_assembly_back_arm_ss" );

	if ( !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, level.factory_assembly_line_back_station05, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_back", level.factory_assembly_line_back_station05 );
	}

	if( isDefined( level.assembly_anim_node_back ) && isDefined( level.factory_assembly_line_back_station05 ))
	{
		level.assembly_anim_node_back anim_single_solo( level.factory_assembly_line_back_station05, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node_back anim_first_frame_solo( level.factory_assembly_line_back_station05, "automated_assemebly_line" );
	}
}

back_turn_rail_track( piece )
{
	level endon( "stop_assembly_line" );

	//play station vignette
	if ( !flag( "factory_assembly_line_resume_speed_back" ) )
	{
		delayThread( 0.1, ::anim_set_rate_single, level.factory_assembly_line_back_turn_rail_track, "automated_assemebly_line", level.speed_up_multiplier );
		thread factory_anim_resume_speed( "factory_assembly_line_resume_speed_back", level.factory_assembly_line_back_turn_rail_track );
	}
	
	piece PlaySound( "scn_factory_assembly_tank_back_ss" );
	if( isDefined( level.assembly_anim_node_back ) && isDefined( level.factory_assembly_line_back_turn_rail_track ))
	{
		level.assembly_anim_node_back anim_single_solo( level.factory_assembly_line_back_turn_rail_track, "automated_assemebly_line", undefined, 0.001 );
		level.assembly_anim_node_back anim_first_frame_solo( level.factory_assembly_line_back_turn_rail_track, "automated_assemebly_line" );
	}
}

// Sets the speed back to normal on the anim object
factory_anim_resume_speed( flag, objects )
{
	flag_wait( flag );
	
	// One object, or multiple?
	if ( IsArray( objects ) )
	{
		foreach ( object in objects )
		{
			// Make sure it still exists
			if ( IsDefined( object ) )
			{
				anim_set_rate_single( object, "automated_assemebly_line", 1.0 );
			}
		}
	}
	else
	{
		// Make sure it still exists
		if ( IsDefined( objects ) )
		{
			anim_set_rate_single( objects, "automated_assemebly_line", 1.0 );
		}
	}
}

// Deletes all the assembly line anim props
factory_assembly_line_cleanup( force_cleanup )
{
	if( !isDefined( force_cleanup ))
	{
		flag_wait( "player_off_roof" );
	}

	flag_set( "stop_assembly_line" );
	wait 0.1;
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station01_arm_a );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station01_arm_b );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station02_arm_a );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station02_arm_b );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station02_arm_c );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station02_arm_d );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station03_arm_a );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station03_arm_b );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station03_arm_c );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station03_arm_d );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station04_arm_a );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station04_arm_b );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station04_arm_c );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station05_arm_a );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station05_arm_b );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station05_arm_c );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station06_arm_a );
	maps\factory_util::safe_delete( level.factory_assembly_line_front_station06_arm_b );

	maps\factory_util::safe_delete( level.factory_assembly_line_back_station01 );
	maps\factory_util::safe_delete( level.factory_assembly_line_back_station02 );
	maps\factory_util::safe_delete( level.factory_assembly_line_back_station03 );
	maps\factory_util::safe_delete( level.factory_assembly_line_back_station04 );
	maps\factory_util::safe_delete( level.factory_assembly_line_back_station05 );

	maps\factory_util::safe_delete( level.factory_assembly_line_back_turn_rail_track );
	maps\factory_util::safe_delete( level.factory_assembly_line_arm_malfunction );
}

// This kills the player if they get stuck in the moving objects
// The alternative is
assembly_line_squash()
{
	level endon( "stop_assembly_line" );
	self waittill( "unresolved_collision" );
	RadiusDamage( self.origin, 1000, 1000, 1000 );
	//"Keep clear of moving machinery."
	SetDvar( "ui_deadquote", &"FACTORY_MACHINE_DEATH_HINT" );
	thread missionFailedWrapper();
}

// Assembly line arm malfunction
// Robot arm breaks and wiggles around
ambush_arm_malfunction()
{
	flag_wait( "ambush_arm_malfunction" );

	// Get the old arm
	level.factory_assembly_line_front_station05_arm_b Delete();
	new_arm = spawn_anim_model( "factory_assembly_line_arm_malfunction" );

	// Get the anim node
	anim_node = getstruct( "automated_assemebly_line", "script_noteworthy" );

	// Start the anim loop
	anim_node thread anim_loop_solo( new_arm, "arm_malfunction" );

	PlayFXOnTag( level._effect[ "welding_sparks_funner" ]  , new_arm, "tag_fx_01" );
	PlayFXOnTag( level._effect[ "electrical_sparks_20_funner" ], new_arm, "tag_fx_02" );
	PlayFXOnTag( level._effect[ "electrical_sparks_20_funner" ], new_arm, "tag_fx_03" );
	RadiusDamage( ( 5178, -2361, 262 ), 200, 400, 100 );

	level waittill( "stop_assembly_line" );
	anim_node notify( "stop_loop" );
	new_arm StopAnimScripted();
	level.factory_assembly_line_arm_malfunction = new_arm;
}

//================================================================================================
// CAR CHASE
//================================================================================================

chase_notify_hit_vehicle_1( guy )
{
	truck_blocker = GetEnt ( "parking_lot_truck_blocker", "targetname" );
	truck_blocker Delete();
	
	level notify ( "hit_vehicle_01" );
	
	// This takes care of the collision brush that encompasses the utility trucks after they're hit by the HET.
	truck_blocker_2 = GetEnt ( "parking_lot_trucks_at_rest_blocker", "targetname" );
	truck_blocker_2 Solid();
	
}

chase_notify_hit_vehicle_2( guy )
{
	level notify ( "hit_vehicle_02" );
}

chase_notify_hit_vehicle_3( guy )
{
	level notify ( "hit_vehicle_03" );
	wait 1;
	level notify ( "semi_stopped" );
}

chase_notify_hit_awning( guy )
{
	blocker = GetEnt ( "parking_lot_awning_blocker", "targetname" );
	blocker delete();
}

chase_notify_hit_light_pole( guy )
{
	blocker = GetEnt ( "parking_lot_light_pole_blocker", "targetname" );
	blocker delete();
}

chase_notify_hit_hydrant( guy)
{
	thread maps\factory_parking_lot::parking_lot_fire_hydrant_explodes();
}

chase_notify_start_mount ( guy )
{
	// level notify ( "start_mount");
	// iprintln ( "start mount" );
}

chase_pull_up_notify_switch ( player )
{
	level notify ( "player_switch" );
}

ally_01_mount_trailer ( guy )
{
	node = getent( "car_chase_intro", "script_noteworthy" );
	node  anim_single_solo ( level.squad[ "ALLY_ALPHA"	], "factory_parking_lot_crub_hop_ally01" );
	
	level notify ( "start_mount");
	
	level.squad [ "ALLY_ALPHA" ] Linkto ( level.ally_vehicle_trailer, "body_anim_jnt" );
	level.ally_vehicle_trailer anim_loop_solo ( level.squad [ "ALLY_ALPHA" ], "factory_car_chase_intro_ally_pulls_up_player_loop", "stop_loop", "body_anim_jnt"  );				   
}

ally_02_mount_trailer ( guy )
{
	level endon ( "player_mount_vehicle_start" );
	node = getent( "car_chase_intro", "script_noteworthy" );
	node anim_single_solo ( level.squad[ "ALLY_BRAVO"	], "factory_parking_lot_crub_hop_ally02" );

	level.squad [ "ALLY_BRAVO" ] Linkto ( level.ally_vehicle_trailer, "body_anim_jnt" );
	level.ally_vehicle_trailer anim_first_frame_solo ( level.squad [ "ALLY_BRAVO" ], "factory_car_chase_intro_ally_pulls_up_player", "body_anim_jnt" );
}

ally_03_mount_trailer ( guy )
{
	level endon ( "player_mount_vehicle_start" );
	node = getent( "car_chase_intro", "script_noteworthy" );
	node anim_single_solo ( level.squad[ "ALLY_CHARLIE"	], "factory_parking_lot_crub_hop_ally03" );
	
	level.squad [ "ALLY_CHARLIE" ] Linkto ( level.ally_vehicle_trailer, "body_anim_jnt" );
	level.ally_vehicle_trailer anim_first_frame_solo ( level.squad [ "ALLY_CHARLIE" ], "factory_car_chase_intro_ally_pulls_up_player", "body_anim_jnt" );
}

chase_kill_vehicle( vehicle )
{
	PlayFXOnTag ( level._effect [ "lynxexplode"], vehicle, "tag_deathfx" );
	array_thread( vehicle.riders, maps\factory_chase::vehicle_crash_guy, vehicle );
	vehicle thread maps\factory_chase::vehicle_crash_launch_guys();
}

chase_trailer_crate_destroyed( guy )
{
	crate = GetEnt ( "trailer_crate_2", "targetname");
	crate Setmodel ( "com_bunkercrate_broken");
	source = spawn ( "script_model", crate.origin);
	source Setmodel ( "tag_origin" );
	PlayFXonTag ( level._effect ["lynxfire"], source, "tag_origin" );
}

chase_trailer_catch_fire( guy )
{
	autosave_by_name( "chase" );
	source = spawn ( "script_model", (level.ally_vehicle_trailer GetTagOrigin ( "tag_wheel_back_left" ) + (0,0,60)));
	source Setmodel ( "tag_origin" );
	source LinkTo ( level.ally_vehicle_trailer );
	PlayFXonTag ( level._effect ["lynxfire"], source, "tag_origin" );
}

chase_player_knock_02( guy )
{
	// Only play the vignette if the player is facing mostly towards the rear of the trailer.
	
	trailer_vector = AnglesToForward ( level.ally_vehicle_trailer.angles );	
	player_angles = level.player GetPlayerAngles();
	player_vector = AnglestoForward ( player_angles);
	dot = VectorDot ( trailer_vector, -1 * player_vector );
	
	// iprintln ( "dot: " + dot );
	
	if ( dot < 0.5 )
	{
		return;
	}
	
	player_rig			   = spawn_anim_model( "player_rig" );
	player_rig hide();
	
	nodes = GetEntArray ( "trailer_node", "script_noteworthy");
	node = getClosest( level.player.origin, nodes );

	node anim_first_frame_solo( player_rig, "factory_car_chase_player_knock_down_02" );
	
	player_rig Linkto ( level.ally_vehicle_trailer, "body_anim_jnt" );
	level.player FreezeControls ( true );
		
	level.player SetStance ( "stand" );
	
	/*
	//Get the player's current weapon and attach it to the vignette
	weapon = level.player GetCurrentWeapon();
	weapon_model = level.player GetPlayerWeaponModel();
	
	player_rig Attach( weapon_model, "tag_weapon" );
	hide_tag_list = GetWeaponHideTags( weapon );
	if ( isDefined( hide_tag_list ) )
	{
		foreach ( part in hide_tag_list )
		player_rig HidePart_AllInstances( part, weapon_model );
	} 
	*/
	// level.player PlayerLinkToBlend( player_rig, "tag_player", 0.5, 0.25, 0 );
	
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
	player_rig Show();
	level.player DisableWeapons();	
	level.player HideViewModel();

	node anim_single_solo( player_rig, "factory_car_chase_player_knock_down_02" );
	
	// To help ensure that the player's origin ends up on the trailer
	// thread lerp_player_view_to_position( node.origin, level.player.angles, 0.01 );
		
	level.player Unlink ();
	level.player ShowViewModel();
	level.player EnableWeapons();	
	level.player FreezeControls ( false );
	
	player_rig Delete();
}

#using_animtree( "player" );	
chase_player_knock_03( guy )
{
	player_rig			   = spawn_anim_model( "player_rig" );
	player_rig Hide();
	
	nodes = GetEntArray ( "trailer_node_left_side", "targetname");
	level.knock_03_node = getClosest( level.player.origin, nodes );
	
	level.knock_03_node anim_first_frame_solo( player_rig, "factory_car_chase_player_knock_down_03" );
	player_rig Linkto ( level.ally_vehicle_trailer, "body_anim_jnt" );
	level.player SetStance ( "stand" );
	
	/*
	weapon = level.player GetCurrentWeapon();
	weapon_model = level.player GetPlayerWeaponModel();
	
	player_rig Attach( weapon_model, "tag_weapon" );
	hide_tag_list = GetWeaponHideTags( weapon );
	if ( isDefined( hide_tag_list ) )
	{
		foreach ( part in hide_tag_list )
		player_rig HidePart_AllInstances( part, weapon_model );
	} 
	// level.player PlayerLinkToBlend( player_rig, "tag_player", 0.5, 0.25, 0 );
	
	wait 0.5;
	*/
	
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
	level.player PushPlayerVector( (0,0,0) );
	player_rig Show();
	level.player DisableWeapons();	
	level.player HideViewModel();
	
	level.knock_03_node thread anim_single_solo( player_rig, "factory_car_chase_player_knock_down_03" );
	
	duration = (GetAnimLength( %factory_car_chase_player_knock_down_03 ) - 0.1 );
	wait ( duration );
	
	level.player SetOrigin( level.knock_03_node.origin + (0,0,5) );
	level.player Unlink ();
	
	// To help ensure that the player's origin ends up on the trailer
	// thread lerp_player_view_to_position( node.origin, level.player.angles, 0.01 );
	
	level.player ShowViewModel();
	level.player EnableWeapons();	
	player_rig Delete();
	
}

slide_right( guy )
{
	level.player PushPlayerVector( ( -12, -8, 0) );
	wait 2;
	level.player PushPlayerVector( (0,0,0) );
}

slide_left_quick( guy )
{
	level.player PushPlayerVector( ( 8, 8, 0) );
	wait 1;
	level.player PushPlayerVector( (0,0,0) );
}

slide_right_quick( guy )
{
	level.player PushPlayerVector( ( -8, -8, 0) );
	wait 1;
	level.player PushPlayerVector( (0,0,0) );
}

hard_left( guy )
{
	
	level.player PushPlayerVector( ( 0, 15, 0) );
	
	/*
	vector_to_node = level.knock_03_node.origin - level.player.origin;
	vector_to_node = ( VectorNormalize ( vector_to_node ) * 10);
	level.player PushPlayerVector( vector_to_node );
	*/
}

factory_car_chase_spawn()
{
	het_cab		= level.ally_vehicle; // vignette_vehicle_spawn("het_cab", "het_cab"); //"value" (kvp), "anim_name"
	het_trailer = level.ally_vehicle_trailer; // vignette_vehicle_spawn("het_trailer", "het_trailer"); //"value" (kvp), "anim_name"
	first_opfor_car = level.blockade_vehicle_1;
	second_opfor_car = level.blockade_vehicle_2;
	third_opfor_car = level.third_opfor_car;
	heavy_weapon_opfor_car =  level.blockade_vehicle_3;

	factory_car_chase( het_cab, het_trailer, first_opfor_car, second_opfor_car, third_opfor_car, heavy_weapon_opfor_car);
}

#using_animtree( "vehicles" );
factory_car_chase( het_cab, het_trailer, first_opfor_car, second_opfor_car, third_opfor_car, heavy_weapon_opfor_car )
{
	// Delete the static smokestacks
	static_stacks = GetEntArray ( "static_smokestack", "targetname" );
	foreach ( stack in static_stacks) 
	{
		stack delete();
	}
	
	node = getent( "car_chase_intro", "script_noteworthy" );
	
	factory_car_chase_intro_side_car01_blowup = level.factory_car_chase_intro_side_car01; // spawn_anim_model( "factory_car_chase_intro_side_car01_blowup" );
	factory_car_chase_intro_side_car02_blowup =  level.factory_car_chase_intro_side_car02; //spawn_anim_model( "factory_car_chase_intro_side_car02_blowup" );
	parking_lot_standin_truck = GetEnt ( "parking_lot_truck_03", "targetname" );
	parking_lot_standin_truck delete();
	factory_car_chase_intro_side_car03_blowup =  spawn_anim_model( "factory_car_chase_intro_side_car03_blowup" );
	level.factory_car_chase_intro_side_car03_blowup = factory_car_chase_intro_side_car03_blowup;
	
	factory_car_chase_smokestack_01 = spawn_anim_model( "factory_car_chase_smokestack_01" );
	factory_car_chase_smokestack_02 = spawn_anim_model( "factory_car_chase_smokestack_02" );
	factory_boxes_and_shvelves_01 = spawn_anim_model( "factory_boxes_and_shvelves_01" );
	factory_boxes_and_shvelves_02 = spawn_anim_model( "factory_boxes_and_shvelves_02" );
	
	factory_boxes_and_shvelves_01 thread factory_car_chase_link_boxes();
	factory_boxes_and_shvelves_02 thread factory_car_chase_link_boxes();
	
	factory_car_chase_warehouse_facade0 = spawn_anim_model( "factory_car_chase_warehouse_facade0" );
	factory_car_chase_warehouse_facade1 = spawn_anim_model( "factory_car_chase_warehouse_facade1" );
	factory_car_chase_warehouse_top = spawn_anim_model( "factory_car_chase_warehouse_top" );
	factory_car_chase_building_corner_break_00 = spawn_anim_model( "factory_car_chase_building_corner_break_00" );
	factory_car_chase_building_corner_break_01 = spawn_anim_model( "factory_car_chase_building_corner_break_01" );
	factory_car_chase_building_corner_break_02 = spawn_anim_model( "factory_car_chase_building_corner_break_02" );
	factory_car_chase_pipes = spawn_anim_model( "factory_car_chase_pipes" );
	factory_car_chase_skybridge_01 = spawn_anim_model( "factory_car_chase_skybridge_01" );
	factory_car_chase_skybridge_02 = spawn_anim_model( "factory_car_chase_skybridge_02" );
	factory_car_chase_smokestack_wall_01 = spawn_anim_model( "factory_car_chase_smokestack_wall_01" );
	factory_car_chase_smokestack_wall_02 = spawn_anim_model( "factory_car_chase_smokestack_wall_02" );
	factory_car_chase_building_facade_01 = spawn_anim_model( "factory_car_chase_building_facade_01" );
	factory_car_chase_building_facade_02 = spawn_anim_model( "factory_car_chase_building_facade_02" );
	factory_car_chase_building_facade_03 = spawn_anim_model( "factory_car_chase_building_facade_03" );
	factory_car_chase_building_facade_04 = spawn_anim_model( "factory_car_chase_building_facade_04" );
	factory_car_chase_building_facade_05 = spawn_anim_model( "factory_car_chase_building_facade_05" );
	factory_car_chase_building_facade_06 = spawn_anim_model( "factory_car_chase_building_facade_06" );
	factory_car_chase_building_facade_07 = spawn_anim_model( "factory_car_chase_building_facade_07" );
	factory_car_chase_building_facade_08 = spawn_anim_model( "factory_car_chase_building_facade_08" );
	factory_car_chase_building_facade_09 = spawn_anim_model( "factory_car_chase_building_facade_09" );
	factory_car_chase_building_facade_10 = spawn_anim_model( "factory_car_chase_building_facade_10" );
	factory_car_chase_building_facade_11 = spawn_anim_model( "factory_car_chase_building_facade_11" );
	factory_car_chase_building_facade_12 = spawn_anim_model( "factory_car_chase_building_facade_12" );
	
	// factory_car_chase_chopper03		= spawn_anim_model( "factory_car_chase_chopper03" );
	factory_car_chase_chopper03		= maps\_vignette_util::vignette_vehicle_spawn( "chase_heli_01", "factory_car_chase_chopper03" );
	factory_car_chase_chopper04		= maps\_vignette_util::vignette_vehicle_spawn( "chase_heli_02", "factory_car_chase_chopper04" );
	factory_car_chase_chopper04		maps\_vehicle::godon();
	factory_car_chase_plane01		= spawn_anim_model( "factory_car_chase_plane01" );
	factory_car_chase_plane02		= spawn_anim_model( "factory_car_chase_plane02" );
	factory_car_chase_plane03		= spawn_anim_model( "factory_car_chase_plane03" );
	
	factory_car_chase_plane01 thread maps\factory_chase::chase_looped_afterburner();
	factory_car_chase_plane02 thread maps\factory_chase::chase_looped_afterburner();
	factory_car_chase_plane03 thread maps\factory_chase::chase_looped_afterburner();
	
	guys									  = [];
	guys[ "het_cab"							] = het_cab;
	guys[ "het_trailer"						] = het_trailer;
	guys[ "first_opfor_car"							] = first_opfor_car;
	guys[ "second_opfor_car"						] = second_opfor_car;
	guys[ "third_opfor_car"						] = third_opfor_car;
	guys[ "heavy_weapon_opfor_car"							] = heavy_weapon_opfor_car;
	guys[ "factory_car_chase_intro_side_car01_blowup"		] = factory_car_chase_intro_side_car01_blowup;
	guys[ "factory_car_chase_intro_side_car02_blowup"		] = factory_car_chase_intro_side_car02_blowup;
	guys[ "factory_car_chase_intro_side_car03_blowup"		] = factory_car_chase_intro_side_car03_blowup;
	guys[ "factory_car_chase_smokestack_01" ] = factory_car_chase_smokestack_01;
	guys[ "factory_car_chase_smokestack_02" ] = factory_car_chase_smokestack_02;	
	guys[ "factory_boxes_and_shvelves_01" ] = factory_boxes_and_shvelves_01;
	guys[ "factory_boxes_and_shvelves_02" ] = factory_boxes_and_shvelves_02;
	guys[ "factory_car_chase_warehouse_facade0" ] = factory_car_chase_warehouse_facade0;
	guys[ "factory_car_chase_warehouse_facade1" ] = factory_car_chase_warehouse_facade1;
	guys[ "factory_car_chase_warehouse_top" ] = factory_car_chase_warehouse_top;	
	guys[ "factory_car_chase_building_corner_break_00"	] = factory_car_chase_building_corner_break_00;
	guys[ "factory_car_chase_building_corner_break_01"	] = factory_car_chase_building_corner_break_01;
	guys[ "factory_car_chase_building_corner_break_02"	] = factory_car_chase_building_corner_break_02;
	guys["factory_car_chase_pipes" ] = factory_car_chase_pipes;
	guys["factory_car_chase_skybridge_01" ] = factory_car_chase_skybridge_01;
	guys["factory_car_chase_skybridge_02" ] = factory_car_chase_skybridge_02;
	guys["factory_car_chase_smokestack_wall_01" ] = factory_car_chase_smokestack_wall_01;
	guys["factory_car_chase_smokestack_wall_02" ] = factory_car_chase_smokestack_wall_02;
	guys["factory_car_chase_building_facade_01" ] = factory_car_chase_building_facade_01;
	guys["factory_car_chase_building_facade_02" ] = factory_car_chase_building_facade_02;
	guys["factory_car_chase_building_facade_03" ] = factory_car_chase_building_facade_03;
	guys["factory_car_chase_building_facade_04" ] = factory_car_chase_building_facade_04;
	guys["factory_car_chase_building_facade_05" ] = factory_car_chase_building_facade_05;
	guys["factory_car_chase_building_facade_06" ] = factory_car_chase_building_facade_06;
	guys["factory_car_chase_building_facade_07" ] = factory_car_chase_building_facade_07;
	guys["factory_car_chase_building_facade_08" ] = factory_car_chase_building_facade_08;
	guys["factory_car_chase_building_facade_09" ] = factory_car_chase_building_facade_09;
	guys["factory_car_chase_building_facade_10" ] = factory_car_chase_building_facade_10;
	guys["factory_car_chase_building_facade_11" ] = factory_car_chase_building_facade_11;
	guys["factory_car_chase_building_facade_12" ] = factory_car_chase_building_facade_12;
	guys[ "factory_car_chase_chopper03"		] = factory_car_chase_chopper03;
	
	guys[ "factory_car_chase_chopper04"		] = factory_car_chase_chopper04;
	
	guys[ "factory_car_chase_opfor_car01"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car01" );
	guys[ "factory_car_chase_opfor_car02"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car02" );
	guys[ "factory_car_chase_opfor_car03"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car03" );
	guys[ "factory_car_chase_opfor_car04"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car04" );
	guys[ "factory_car_chase_opfor_car05"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car05" );
	//guys[ "factory_car_chase_opfor_car06"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car06" );
	guys[ "factory_car_chase_opfor_car07"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car07" );
	guys[ "factory_car_chase_opfor_car08"	] = factory_car_chase_enemy_vehicle_setup ( "factory_car_chase_opfor_car08" );
	guys[ "factory_car_chase_opfor_car09"	] = spawn_anim_model ( "factory_car_chase_opfor_car09" );
	
	guys[ "factory_car_chase_plane01"		] = factory_car_chase_plane01;
	guys[ "factory_car_chase_plane02"		] = factory_car_chase_plane02;
	guys[ "factory_car_chase_plane03"		] = factory_car_chase_plane03;
	
	allies = [];
	allies[ "ally_alpha" ] = level.squad[ "ALLY_ALPHA" ];
	allies[ "ally_bravo" ] = level.squad[ "ALLY_BRAVO" ];
	allies[ "ally_charlie" ] = level.squad[ "ALLY_CHARLIE" ];

	node anim_first_frame( guys, "factory_car_chase" );
	
	waittillframeend;
	
	
	SetSavedDvar( "player_sprintUnlimited" , "1" );
	SetSavedDvar( "player_sprintSpeedScale", 1.25 );

	node thread anim_single( guys, "factory_car_chase" );
	level.ally_vehicle_trailer anim_single( allies, "factory_car_chase", "body_anim_jnt" );
}

light_turns_red()
{
	light = GetEnt ( "foo", "targetname" );
	while ( 1 )
	{
		flag_wait ( "light_red" );	
		light SetLightColor( ( 1, 0, 0 ) );
		flag_waitopen ( "light_red" );
		light SetLightColor( ( 1, 1, 1 ) );	
	}
}

factory_car_chase_link_boxes( targetname )
{
	boxes = [];
    model_name = level.scr_model[ self.animname ];
    num_tags = GetNumParts( model_name );
    for( i = 0; i < 96 ; i++ )
    {
        tag_name = GetPartName( model_name, i );

        if( GetSubStr( tag_name, 0, 14 ) == "shipping_crate" )
        {
            // the tag should be named mdl_<xmodel name>_xxx where xxx is a number reference like 001
            // part_name = GetSubStr( tag_name, 4, tag_name.size - 4 );
            mdl = Spawn( "script_model", self GetTagOrigin( tag_name ) );
            mdl SetModel( "shipping_frame_boxes" );
            mdl.angles = self GetTagAngles( tag_name );
            mdl LinkTo( self, tag_name );
            
            if( IsDefined( targetname ) )
                mdl.targetname = targetname;
            boxes[ boxes.size ] = mdl;
	        // wait at least a frame so we don't slam the texture streaming or cause a hitch
	        // but I wonder how bad the hitch would be and maybe I should spawn all the same named things at once or in batches?
	        waitframe();
        }
    }
    
	maps\factory_chase::chase_wait_for_semi_touch ( "chase_delete_warehouse_boxes" );
	foreach ( mdl in boxes )
	{
		mdl delete();
	}
}

factory_car_chase_enemy_vehicle_setup( animname  )
{
	vehicle	= maps\_vehicle::spawn_vehicle_from_targetname ( animname );
	vehicle maps\_vehicle::vehicle_lights_on( "headlights" );
	vehicle.animname = animname;
	vehicle thread maps\factory_chase::vehicle_catch_fire_when_shot();
	if ( IsDefined ( vehicle.mgturret ))
	{
		vehicle.mgturret[0] SetAISpread( 15 );
	}
	return vehicle;
}

//factory intro vignette
/*
factory_intro_spawn()
{
   tagTJ - disabling for the time being so we can make sure this gets implemented correctly.  Will re-enable after IW meeting 	
	ally01 = vignette_actor_spawn("ally01", "ally01"); //"value" (kvp), "anim_name"
	ally02 = vignette_actor_spawn("ally02", "ally02"); //"value" (kvp), "anim_name"
	ally03 = vignette_actor_spawn("ally03", "ally03"); //"value" (kvp), "anim_name"
	guard  = vignette_actor_spawn("guard", "guard"); //"value" (kvp), "anim_name"

	factory_intro(ally01, ally02, ally03, guard);

	ally01 vignette_actor_delete();
	ally02 vignette_actor_delete();
	ally03 vignette_actor_delete();
	guard vignette_actor_delete();

}

factory_intro( ally01, ally02, ally03, guard )
{
   tagTJ - disabling for the time being so we can make sure this gets implemented correctly.  Will re-enable after IW meeting 
	node = getstruct("factory_intro", "script_noteworthy");

	train_car01 = spawn_anim_model("train_car01");

	train_car02 = spawn_anim_model("train_car02");

	train_car03 = spawn_anim_model("train_car03");

	train_car04 = spawn_anim_model("train_car04");

	train_car05 = spawn_anim_model("train_car05");

	level.player FreezeControls( true );
	//level.player allowprone( false );
	//level.player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys				  = [];
	guys[ "player_rig"	] = player_rig;
	guys[ "ally01"		] = ally01;
	guys[ "ally02"		] = ally02;
	guys[ "ally03"		] = ally03;
	guys[ "guard"		] = guard;
	guys[ "train_car01" ] = train_car01;
	guys[ "train_car02" ] = train_car02;
	guys[ "train_car03" ] = train_car03;
	guys[ "train_car04" ] = train_car04;
	guys[ "train_car05" ] = train_car05;

	arc = 15;

	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	

	node anim_single(guys, "factory_intro");

	level.player unlink();

	player_rig delete();

	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );

}
*/
