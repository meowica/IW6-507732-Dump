#include maps\_utility;
#include maps\_anim;

main()
{
	anims();
	load_player_anims();
	intro_masks();
	aurora_anims();
	vehicle_anims();
	icehole_shards();
	duffle_bag_anims();
	vault_door();
	cqb_anims();
	nvg_intro();
	dog();
	snowmobile_bodies();
	blackout_moment_anims();
	blackout_moment_props();
	checkpoint_enemy_anims();
	checkpoint_props();
	dead_guys();
	
	maps\_minigun_viewmodel::anim_minigun_hands();

	new_ambush_humans();
	jeep_doors();
	new_ambush_bags();
}
#using_animtree( "generic_human" );
checkpoint_enemy_anims()
{
	level.scr_anim[ "keegandrag" ][ "keytoss_enemy_a" ] = %clockwork_checkpoint_keytoss_enemy_a;
	level.scr_anim[ "playerdrag" ][ "keytoss_enemy_b" ] = %clockwork_checkpoint_keytoss_enemy_b;
	level.scr_anim[ "bakerdrag" ][ "shoetie" ] = %clockwork_checkpoint_shoetie_enemy;
	level.scr_anim[ "radioguy" ][ "lookout" ][ 0 ] = %clockwork_checkpoint_lookout_enemy;
	level.scr_anim[ "leanrailguy" ][ "scnleanrailguy" ][ 0 ] = %clockwork_checkpoint_lean_rail_enemy;
	
	level.scr_anim[ "generic" ][ "tapglass_enemy_a" ] = %clockwork_checkpoint_tapglass_enemy_a;
	level.scr_anim[ "generic" ][ "tapglass_enemy_b" ] = %clockwork_checkpoint_tapglass_enemy_b;
	

	level.scr_anim[ "generic" ][ "spotlight_enemy_a" ] = %clockwork_checkpoint_spotlight_enemy_a;
	addNotetrack_flag("generic","trigger_spotlight_b","start_spotlight_b","spotlight_enemy_a");
	level.scr_anim[ "generic" ][ "spotlight_enemy_b_loop" ][ 0 ] = %clockwork_checkpoint_spotlight_enemy_b_loop;
	level.scr_anim[ "generic" ][ "spotlight_enemy_b" ] = %clockwork_checkpoint_spotlight_enemy_b_exit;

}

#using_animtree( "animated_props" );
checkpoint_props()
{
	
	//Key drop scene
	level.scr_animtree[ "cp_key_jt" ] = #animtree;
	level.scr_model	  [ "cp_key_jt" ] = "generic_prop_raven";
	level.scr_anim[ "cp_key_jt" ][ "cp_key_joint" ]  = %clockwork_checkpoint_keytoss_key;
	level.scr_animtree[ "cp_key_mdl" ] = #animtree;
	level.scr_model	  [ "cp_key_mdl" ] = "ny_harbor_missle_key";
	
	level.scr_animtree[ "cp_ammo_jt" ] = #animtree;
	level.scr_model	  [ "cp_ammo_jt" ] = "generic_prop_raven";
	level.scr_anim[ "cp_ammo_jt" ][ "cp_ammo_joint" ]  = %clockwork_checkpoint_spotlight_ammobox;
	level.scr_animtree[ "cp_ammo_mdl" ] = #animtree;
	level.scr_model	  [ "cp_ammo_mdl" ] = "mil_ammo_case_1";
	
	level.scr_animtree[ "cp_light_jt" ] = #animtree;
	level.scr_model	  [ "cp_light_jt" ] = "generic_prop_raven";
	level.scr_anim[ "cp_light_jt" ][ "cp_light_joint" ]  = %clockwork_checkpoint_spotlight_light;
	
	level.scr_animtree[ "cp_light_mdl" ] = #animtree;
	level.scr_model	  [ "cp_light_mdl" ] = "clk_searchlight_ir_light";
	
	level.scr_animtree[ "cp_stand_mdl" ] = #animtree;
	level.scr_model	  [ "cp_stand_mdl" ] = "clk_searchlight_stand";
	   
	
}


#using_animtree( "generic_human" );
blackout_moment_anims()
{
	level.scr_anim[ "generic" ][ "clockwork_nvg_hallway_run_and_trip_enemy1" ] = %clockwork_nvg_hallway_run_and_trip_enemy1;
	//level.scr_anim[ "generic" ][ "clockwork_nvg_hallway_alerted_enemy2_loop" ][ 0 ] = %clockwork_nvg_hallway_alerted_enemy2_loop;
	level.scr_anim[ "generic" ][ "clockwork_nvg_hallway_alerted_enemy2" ] = %clockwork_nvg_hallway_alerted_enemy2;
	level.scr_anim[ "generic" ][ "clockwork_nvg_hallway_grope_enemy3" ] = %clockwork_nvg_hallway_grope_enemy3;
	level.scr_anim[ "generic" ][ "clockwork_nvg_hallway_buddies_enemy4" ] = %clockwork_nvg_hallway_buddies_enemy4;
	level.scr_anim[ "generic" ][ "clockwork_nvg_hallway_buddies_enemy5" ] = %clockwork_nvg_hallway_buddies_enemy5;
}

#using_animtree( "animated_props" );
blackout_moment_props()
{
	level.scr_animtree[ "bo_alerted_door_jt" ] = #animtree;
	level.scr_model	  [ "bo_alerted_door_jt" ] = "generic_prop_raven";
	level.scr_anim[ "bo_alerted_door_jt" ][ "alerted_door_joint" ]  = %clockwork_nvg_hallway_alerted_door;
	//j-MODEL
	level.scr_animtree[ "bo_alerted_door" ] = #animtree;
	level.scr_model	  [ "bo_alerted_door" ] = "clk_door_01";
	
	
	level.scr_animtree[ "bo_grope_door_jt" ] = #animtree;
	level.scr_model	  [ "bo_grope_door_jt" ] = "generic_prop_raven";
	level.scr_anim[ "bo_grope_door_jt" ][ "bo_grope_door_joint" ]  = %clockwork_nvg_hallway_grope_door;
	//j-MODEL
	level.scr_animtree[ "bo_grope_door" ] = #animtree;
	level.scr_model	  [ "bo_grope_door" ] = "clk_door_01";
}

#using_animtree( "generic_human" );
new_ambush_humans()
{
	//Player Drag Guy, death anim and drag anims
	level.scr_anim[ "playerdrag" ][ "clock_bodydrag_death" ] = %clockwork_intro_death_enemy;
	level.scr_anim[ "playerdrag" ][ "clock_bodydrag_drag"	] = %clockwork_intro_drag_body_enemy;
	
	//Keegans Drag Guy,death anim and drag anims
	level.scr_anim[ "keegandrag" ][ "clock_intro_death_guard2" ] = %clockwork_intro_death_guard2;
	level.scr_anim[ "keegandrag" ][ "clock_intro"			   ] = %clockwork_intro_cleanup_guard2;

	//Bakers Drag Guy,death anim and drag anims
	level.scr_anim[ "bakerdrag" ][ "clock_intro_guy_death" ] = %clock_intro_enemy1_death;
	level.scr_anim[ "bakerdrag" ][ "clock_intro"			 ] = %clock_intro_enemy1_drag;
	
	//ambush setup scene
	level.scr_anim[ "baker" ][ "clock_intro" ]					= %clockwork_intro_jeep_ambush_enter_baker;
	level.scr_anim[ "baker" ][ "clock_ambush_hut_wait" ][ 0 ]	= %clockwork_intro_jeep_ambush_wait1_baker;
	level.scr_anim[ "baker" ][ "clock_ambush_hut_walkout" ]		= %clockwork_intro_jeep_ambush_walkout_baker;
	level.scr_anim[ "baker" ][ "clock_ambush_wait_baker" ][ 0 ] = %clockwork_intro_jeep_ambush_wait2_baker;
	level.scr_anim[ "baker" ][ "clock_ambush_end" ]				= %clockwork_intro_jeep_ambush_end_baker;
	
	level.scr_anim[ "keegan" ][ "clock_intro" ]				 = %clockwork_intro_jeep_ambush_enter_keegan;
	level.scr_anim[ "keegan" ][ "clock_ambush_wait" ][ 0 ]	 = %clockwork_intro_jeep_ambush_wait_keegan;
	level.scr_anim[ "keegan" ][ "clock_ambush_end_knife"   ] = %clockwork_intro_jeep_ambush_end_knifekill_keegan;
	level.scr_anim[ "keegan" ][ "clock_ambush_end_gunshot" ] = %clockwork_intro_jeep_ambush_end_gunshot_keegan;
	
	addNotetrack_flag( "keegan", "drag_driver", "FLAG_gunshot_drag", "clock_ambush_end_gunshot" );
	
	level.scr_anim[ "cipher" ][ "clock_intro" ]			   = %clockwork_intro_jeep_ambush_enter_cipher;
	level.scr_anim[ "cipher" ][ "clock_ambush_wait" ][ 0 ] = %clockwork_intro_jeep_ambush_wait_cipher;
	level.scr_anim[ "cipher" ][ "clock_ambush_end" ]	   = %clockwork_intro_jeep_ambush_end_cipher;
	
				   //   animname    notetrack 	   theFlag 						   anime 		 
	addNotetrack_flag( "keegan"	 , "spawn_jeep" , "FLAG_baker_bodydrag_complete", "clock_intro" );//start ambush convoy
	addNotetrack_flag( "keegan"	 , "spawn_baker", "FLAG_baker_out_of_hut"		, "clock_intro" );//start baker walkout anim
	addNotetrack_flag( "baker", "jeep_anims", "start_ambush_scene_enemies", "clock_ambush_hut_walkout" );
	//addNotetrack_flag( "baker", "enemies_dead", "ambush_started", "clock_ambush_hut_walkout" );
	
	level.scr_anim[ "ambush_jeep_driver" ][ "clock_ambush_start_enemies" ] = %clockwork_intro_jeep_ambush_enter_enemy1;
	level.scr_anim[ "ambush_jeep_driver" ][ "clock_ambush_wait" ][ 0 ]	   = %clockwork_intro_jeep_ambush_wait_enemy1;
	//SCENARIO 1: Player Knifes Driver
	level.scr_anim[ "ambush_jeep_driver" ][ "clock_ambush_end_knife" ] = %clockwork_intro_jeep_ambush_end_knifekill_enemy1;
	//SCENARIO 2: Player shoots Driver
	level.scr_anim[ "ambush_jeep_driver" ][ "clock_ambush_end_gunshot"		] = %clockwork_intro_jeep_ambush_end_gunshot_death_enemy1;
	level.scr_anim[ "ambush_jeep_driver" ][ "clock_ambush_end_gunshot_drag" ] = %clockwork_intro_jeep_ambush_end_gunshot_drag_enemy1;
	//level.scr_anim[ "ambush_jeep_driver" ][ "clock_ambush_end_gunshot" ]	  = %clockwork_intro_jeep_ambush_end_gunshot_enemy1;
	
	level.scr_anim[ "ambush_jeep_passenger" ][ "clock_ambush_start_enemies" ] = %clockwork_intro_jeep_ambush_enter_enemy2;
	level.scr_anim[ "ambush_jeep_passenger" ][ "clock_ambush_wait" ][ 0 ]	  = %clockwork_intro_jeep_ambush_wait_enemy2;
	level.scr_anim[ "ambush_jeep_passenger" ][ "clock_ambush_end" ]			  = %clockwork_intro_jeep_ambush_end_enemy2;
	
				   //   animname    notetrack     theFlag 				  
	addNotetrack_flag( "baker"	 , "jeep_ready", "bakerambush_finished" );
	addNotetrack_flag( "keegan"	 , "jeep_ready", "keeganambush_finished" );
	addNotetrack_flag( "cipher"	 , "jeep_ready", "cipherambush_finished" );
	
}

#using_animtree( "animated_props" );
jeep_doors()
{
	//ciphers bag
	level.scr_animtree[ "jeep_door_BL" ] = #animtree;
	level.scr_model	  [ "jeep_door_BL" ] = "chinese_brave_warrior_obj_door_back_LE";
	
	                                                               	
}

#using_animtree( "animated_props" );
intro_masks()
{
	// raven prop that holds the player view in place
	level.scr_animtree[ "player_view" ] = #animtree;
	level.scr_model	  [ "player_view" ] = "generic_prop_raven";
	level.scr_anim[ "player_view" ][ "clock_prepare" ]			   = %clockwork_level_intro_player_view_link;
	
//	//player mask
//	level.scr_animtree[ "player_mask" ] = #animtree;
//	level.scr_model	  [ "player_mask" ] = "clk_facemask";
//	level.scr_anim[ "player_mask" ][ "clock_prepare" ]			   = %clockwork_level_intro_player_mask;
//		
//	//Baker mask
//	level.scr_animtree[ "baker_mask" ] = #animtree;
//	level.scr_model	  [ "baker_mask" ] = "clk_facemask";
//	level.scr_anim[ "baker_mask" ][ "clock_prepare" ]			   = %clockwork_level_intro_baker_mask;
}

#using_animtree( "animated_props" );
aurora_anims()
{
	//Aurora
	level.scr_animtree[ "aurora" ] = #animtree;
	level.scr_model	  [ "aurora" ] = "clk_aurora";
	level.scr_anim	  [ "aurora" ][ "clk_aurora_loop" ][0]			   = %clk_aurora_loop;
	level.scr_animtree[ "aurora2" ] = #animtree;
	level.scr_model	  [ "aurora2" ] = "clk_aurora2";
	level.scr_anim	  [ "aurora2" ][ "clk_aurora_loop" ][0]			   = %clk_aurora_loop;
	
}

#using_animtree( "animated_props" );
new_ambush_bags()
{
	//ciphers bag
	level.scr_animtree[ "cipher_bag" ] = #animtree;
	level.scr_model	  [ "cipher_bag" ] = "clockwork_duffle_bag_anim";
	
	level.scr_anim[ "cipher_bag" ][ "clock_intro" ]			   = %clockwork_intro_jeep_ambush_enter_cipher_bag;
	level.scr_anim[ "cipher_bag" ][ "clock_ambush_wait" ][ 0 ] = %clockwork_intro_jeep_ambush_wait_cipher_bag;
	level.scr_anim[ "cipher_bag" ][ "clock_ambush_end" ]	   = %clockwork_intro_jeep_ambush_end_cipher_bag;
	
	//keegan bag
	level.scr_animtree[ "keegan_bag" ] = #animtree;
	level.scr_model	  [ "keegan_bag" ] = "clockwork_duffle_bag_anim";
	

	level.scr_anim[ "keegan_bag" ][ "clock_intro" ]			   = %clockwork_intro_jeep_ambush_enter_keegan_bag;
	level.scr_anim[ "keegan_bag" ][ "clock_ambush_wait" ][ 0 ] = %clockwork_intro_jeep_ambush_wait_keegan_bag;
	level.scr_anim[ "keegan_bag" ][ "clock_ambush_end" ]	   = %clockwork_intro_jeep_ambush_end_keegan_bag;
	
	//baker bag
	level.scr_animtree[ "baker_bag" ] = #animtree;
	level.scr_model	  [ "baker_bag" ] = "clockwork_duffle_bag_anim";

	level.scr_anim[ "baker_bag" ][ "clock_intro"			  ]		= %clockwork_intro_jeep_ambush_enter_baker_bag;
	level.scr_anim[ "baker_bag" ][ "clock_ambush_hut_walkout" ]		= %clockwork_intro_jeep_ambush_walkout_baker_bag;
	level.scr_anim[ "baker_bag" ][ "clock_ambush_hut_wait"	 ][ 0 ] = %clockwork_intro_jeep_ambush_wait1_baker_bag;
	level.scr_anim[ "baker_bag" ][ "clock_ambush_wait_baker" ][ 0 ] = %clockwork_intro_jeep_ambush_wait2_baker_bag;
	level.scr_anim[ "baker_bag" ][ "clock_ambush_end" ]				= %clockwork_intro_jeep_ambush_end_baker_bag;

}

#using_animtree( "generic_human" );
anims()
{
	//intro anims, level start
	level.scr_anim[ "baker"	 ][ "clock_prepare" ] = %clockwork_level_intro_baker;
	//level.scr_anim[ "baker"	 ][ "clock_prepare_loop" ][0] = %clockwork_level_intro_baker_loop;
	//level.scr_anim[ "baker" ][ "clock_prepare_exit" ] = %clockwork_level_intro_baker_exit ;
	
	level.scr_anim[ "keegan" ][ "clock_prepare" ] = %clockwork_level_intro_keegan;

	level.scr_anim[ "cipher" ][ "clock_prepare" ] = %clockwork_level_intro_cipher;
	
	
	addNotetrack_flag("baker","light_off","FLAG_intro_light_off","clock_prepare");
	addNotetrack_flag("keegan","helmet_attach","FLAG_attach_keegan_helmet","clock_prepare");
	



	
				   //   animname    notetrack 	   theFlag 				    anime 		    
	addNotetrack_flag( "baker"	 , "player_mask", "FLAG_player_mask_anim", "clock_prepare" );
	addNotetrack_flag( "baker"	 , "head_swap"	, "FLAG_swap_ally_heads" , "clock_prepare" );

	

	level.scr_anim[ "baker" ][ "checkpoint_approach" ] = %clockwork_checkpoint_approach_baker_enter ;
	level.scr_anim[ "baker"	 ][ "checkpoint_approach_loop" ][0] = %clockwork_checkpoint_approach_baker_idle;
	
	level.scr_anim[ "keegan" ][ "checkpoint_approach" ] = %clockwork_checkpoint_approach_keegan_enter;
	level.scr_anim[ "keegan" ][ "checkpoint_approach_loop" ][0] = %clockwork_checkpoint_approach_keegan_idle ;
	
	level.scr_anim[ "cipher" ][ "checkpoint_approach" ] = %clockwork_checkpoint_approach_cypher_enter;
	level.scr_anim[ "cipher" ][ "checkpoint_approach_loop" ][0] = %clockwork_checkpoint_approach_cypher_idle ;
	
	
	level.scr_anim[ "cipher" ][ "ambush_approach" ] = %clockwork_pre_ambush_cypher_enter;
	level.scr_anim[ "cipher" ][ "ambush_approach_loop" ][0] = %clockwork_pre_ambush_cypher_idle;



	level.scr_anim[ "generic" ][ "ambush_enemy_react1" ] = %patrol_bored_react_look_advance;
	level.scr_anim[ "generic" ][ "ambush_enemy_react2" ] = %patrol_bored_react_look_retreat;
	level.scr_anim[ "generic" ][ "ambush_enemy_react3" ] = %patrol_bored_react_walkstop_short;
	

	level.scr_anim[ "ambush_jeep2_passenger" ][ "ambush_jeep2_passenger_wave" ] = %clockwork_intro_jeep_ambush_wave_enemy;
	

	
	//level.scr_anim[ "ambush_jeep_riderR" ][ "clock_ambush_start_enemies" ] = %clockwork_intro_jeep_ambush_start_enemy3;
	
	//START WAIT AMBUSH
	//level.scr_anim[ "baker" ][ "clock_ambush_wait" ][0]  = %clockwork_intro_jeep_ambush_wait2_baker;
	//level.scr_anim[ "keegan" ][ "clock_ambush_wait" ][0] = %clockwork_intro_jeep_ambush_wait_keegan; //keegan
	//level.scr_anim[ "cipher" ][ "clock_ambush_wait" ][0] = %clockwork_intro_jeep_ambush_wait_cipher; //cipher
	//
	//level.scr_anim[ "ambush_jeep_driver" ][ "clock_ambush_wait" ][0]	  = %clockwork_intro_jeep_ambush_wait_enemy1;
	//level.scr_anim[ "ambush_jeep_passenger" ][ "clock_ambush_wait" ][0] = %clockwork_intro_jeep_ambush_wait_enemy2;
	//level.scr_anim[ "ambush_jeep_riderR" ][ "clock_ambush_wait" ][0]	  = %clockwork_intro_jeep_ambush_wait_enemy3;//clock_ambush_wait_enemies
	
	//level.scr_anim[ "ambush_jeep_riderR" ][ "clock_ambush_end_enemies" ] = %clockwork_intro_jeep_ambush_end_enemy3;
	
	
//	level.scr_anim[ "baker"	 ][ "relaxed_idle" ][ 0 ] = %hijack_tarmac_relaxed_idle_commander;
//	level.scr_anim[ "keegan" ][ "relaxed_idle" ][ 0 ] = %hijack_tarmac_relaxed_idle_commander;
//	level.scr_anim[ "cipher" ][ "relaxed_idle" ][ 0 ] = %hijack_tarmac_relaxed_idle_commander;
		

	

	level.scr_anim[ "baker" ][ "clockwork_jeep_bloodwipe" ] = %clockwork_jeep_ride_bloodwipe_baker;
	level.scr_anim[ "keegan" ][ "clockwork_jeep_bloodwipe" ] = %clockwork_jeep_ride_bloodwipe_keegan;
	level.scr_anim[ "cipher" ][ "clockwork_jeep_bloodwipe" ] = %clockwork_jeep_ride_bloodwipe_cipher;
	
	level.scr_anim[ "keegan" ][ "clockwork_jeep_wave" ] = %clockwork_jeep_ride_wave_keegan;
	level.scr_anim[ "baker" ][ "clockwork_jeep_ack" ] = %clockwork_jeep_ride_acknowledge_baker;
	level.scr_anim[ "baker" ][ "clockwork_jeep_blackbird" ] = %clockwork_jeep_ride_enterblackbird_baker;

	                       
	   
	level.scr_anim[ "cipher" ][ "clockwork_jeep_lookout" ] = %clockwork_jeep_ride_lookout_cipher;
	level.scr_anim[ "cipher" ][ "clockwork_jeep_guncheck" ] = %clockwork_jeep_ride_guncheck_cipher;
	
	
	level.scr_anim[ "baker"	 ][ "clockwork_jeep_sync" ] = %clockwork_jeep_ride_sync_baker;
	level.scr_anim[ "cipher" ][ "clockwork_jeep_sync" ] = %clockwork_jeep_ride_sync_cipher;
	level.scr_anim[ "keegan" ][ "clockwork_jeep_sync" ] = %clockwork_jeep_ride_sync_keegan;
	
	
	
	addNotetrack_flag( "baker", "player_anim", "NOTE_player_watch_sync_jeep" );
	
	//INTRO JEEP EXIT
	level.scr_anim[ "baker"	 ][ "clockwork_garage_arrival" ] = %clockwork_garage_arrival_baker;
	level.scr_anim[ "cipher" ][ "clockwork_garage_arrival" ] = %clockwork_garage_arrival_cypher;
	level.scr_anim[ "keegan" ][ "clockwork_garage_arrival" ] = %clockwork_garage_arrival_keegan;
	
	addNotetrack_flag("baker","player_start","FLAG_player_getout_jeep","clockwork_garage_arrival");
	
	//patrol anims
	level.scr_anim[ "generic" ][ "patrol_walk" ]			 = %patrol_bored_patrolwalk;
	
	
	// Checkpoint Stop animations
//	level.scr_anim[ "keegan" ][ "stop_signal"  ]   = %cqb_stop_2_signal;
//	level.scr_anim[ "keegan" ][ "stop_signalA" ]   = %london_police_jog_2_wave;
	//level.scr_anim[ "keegan" ][ "stop_signalB" ] = %stand_exposed_wave_halt_v2;
	
	// guys running away from car
	//level.scr_anim[ "keegan" ][ "stop_run" ]   	    = %clockwork_garage_bullet_strikes_grd_01;
	//level.scr_anim[ "keegan" ][ "stop_run2" ]   	= %clockwork_garage_bullet_strikes_grd_02;
	
	// Inner base anims
	level.scr_anim[ "generic" ][ "walk_gun_unwary" ] = %dufflebag_casual_walk;
	level.scr_anim[ "keegan"  ][ "walk_gun_unwary" ] = %dufflebag_casual_keegan_walk;
	level.scr_anim[ "cipher"  ][ "walk_gun_unwary" ] = %dufflebag_casual_cypher_walk;
	
	level.scr_anim[ "generic" ][ "unarmed_cowercrouch_idle" ][ 0 ] = %unarmed_cowercrouch_idle;
	level.scr_anim[ "cipher" ][ "eyes_and_ears" ]				   = %clockwork_surveillance_room_cipher;
	level.scr_anim[ "baker" ][ "eyes_and_ears" ]				   = %clockwork_surveillance_room_baker;
	
	
	addNotetrack_flag("cipher","check_check","FLAG_checkcheck","eyes_and_ears");
	addNotetrack_flag("baker","move_out","security_complete","eyes_and_ears");

	
	level.scr_anim[ "baker"	 ][ "lights_out_approach" ] = %clockwork_power_out_enter_baker;
	level.scr_anim[ "keegan" ][ "lights_out_approach" ] = %clockwork_power_out_enter_keegan;
	level.scr_anim[ "cipher" ][ "lights_out_approach" ] = %clockwork_power_out_enter_cypher;
	
	level.scr_anim[ "baker"	 ][ "lights_out_breakout" ] = %clockwork_power_out_baker;
	level.scr_anim[ "keegan" ][ "lights_out_breakout" ] = %clockwork_power_out_keegan;
	level.scr_anim[ "cipher" ][ "lights_out_breakout" ] = %clockwork_power_out_cypher;
	
	level.scr_anim[ "generic" ][ "tunnel_wave"				 ][ 0 ] = %dcemp_guard_wave;
	level.scr_anim[ "generic" ][ "training_humvee_repair"	 ][ 0 ] = %training_humvee_repair;
//	level.scr_anim[ "generic" ][ "oilrig_balcony_smoke_idle" ][ 0 ] = %oilrig_balcony_smoke_idle;
	
//	level.scr_anim[ "generic" ][ "london_guard_idle1" ][ 0 ] = %london_guard_idle1;


	
	
	level.scr_anim[ "generic" ][ "parabolic_leaning_guy_trans2smoke" ][ 0 ] = %parabolic_leaning_guy_trans2smoke;
	level.scr_anim[ "generic" ][ "civilian_smoking_B"				 ][ 0 ] = %civilian_smoking_B;
	

	
	// lights out scene
	level.scr_anim[ "nvg_guy1" ][ "lights_out" ] = %clockwork_power_out_enemy1;
	level.scr_anim[ "nvg_guy2" ][ "lights_out" ] = %clockwork_power_out_enemy2;
	level.scr_anim[ "nvg_guy3" ][ "lights_out" ] = %clockwork_power_out_enemy3;
	level.scr_anim[ "nvg_guy4" ][ "lights_out" ] = %clockwork_power_out_enemy4;
	level.scr_anim[ "nvg_guy5" ][ "lights_out" ] = %clockwork_power_out_enemy5;
	
	level.scr_anim[ "generic" ][ "nvg_recover_anim1" ][ 0 ] = %castle_dungeon_blind_idle_guard;

	//stumbling dudes
//	level.scr_anim[ "generic" ][ "afgan_chase_ending_search_spin"		] = %afgan_chase_ending_search_spin;
//	level.scr_anim[ "generic" ][ "payback_pmc_sandstorm_stumble_1"		] = %payback_pmc_sandstorm_stumble_1;
	level.scr_anim[ "generic" ][ "payback_sstorm_blindfire"				] = %payback_sstorm_blindfire;
//	level.scr_anim[ "generic" ][ "blackout_blind_lightswitch"			] = %blackout_blind_lightswitch;
//	level.scr_anim[ "generic" ][ "afgan_chase_ending_search_spin"		] = %afgan_chase_ending_search_spin;
	level.scr_anim[ "generic" ][ "blackout_blind_fire_pistol"			] = %blackout_blind_fire_pistol;
//	level.scr_anim[ "generic" ][ "blackout_blind_fire_pistol_death"		] = %blackout_blind_fire_pistol_death;
	level.scr_anim[ "generic" ][ "ch_castle_8_0_guard_blind"			] = %ch_castle_8_0_guard_blind;
//	level.scr_anim[ "generic" ][ "civilian_run_hunched_turnR90_stumble" ] = %civilian_run_hunched_turnR90_stumble;
	
	// new vault anims
	level.scr_anim[ "cypher" ][ "vault_approach" ]	 = %clockwork_vault_drill_intro_cypher;
	level.scr_anim[ "cypher" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_loop1_cypher;
	level.scr_anim[ "cypher" ][ "vault_betweener" ]	 = %clockwork_vault_drill_approach2_cypher;
	level.scr_anim[ "cypher" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_loop2_cypher;
	level.scr_anim[ "cypher" ][ "vault_finish" ]	 = %clockwork_vault_drill_burn_cypher;
	level.scr_anim[ "cypher" ][ "vault_loop3" ][0]	 = %clockwork_vault_drill_loop3_cypher;
	level.scr_anim[ "cypher" ][ "vault_exit" ]		 = %clockwork_vault_drill_exit_cypher;

	level.scr_anim[ "baker" ][ "vault_approach" ]	= %clockwork_vault_drill_intro_baker;
	level.scr_anim[ "baker" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_loop1_baker;
	level.scr_anim[ "baker" ][ "vault_betweener" ]	= %clockwork_vault_drill_approach2_baker;
	level.scr_anim[ "baker" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_loop2_baker;
	level.scr_anim[ "baker" ][ "vault_finish" ] 	= %clockwork_vault_drill_burn_baker;
	level.scr_anim[ "baker" ][ "vault_loop3" ][0]	 = %clockwork_vault_drill_loop3_baker;
	level.scr_anim[ "baker" ][ "vault_exit" ]		 = %clockwork_vault_drill_exit_baker;
	
	level.scr_anim[ "keegan" ][ "vault_approach" ]	 = %clockwork_vault_drill_intro_keegan;
	level.scr_anim[ "keegan" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_loop1_keegan;
	level.scr_anim[ "keegan" ][ "vault_betweener" ]	 = %clockwork_vault_drill_approach2_keegan;
	level.scr_anim[ "keegan" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_loop2_keegan;
	level.scr_anim[ "keegan" ][ "vault_finish" ]	 = %clockwork_vault_drill_burn_keegan;
	level.scr_anim[ "keegan" ][ "vault_loop3" ][0]	 = %clockwork_vault_drill_loop3_keegan;
	level.scr_anim[ "keegan" ][ "vault_exit" ]		 = %clockwork_vault_drill_exit_keegan;

//	addNotetrack_flag( "baker", "explosion_start", "explosion_start", "vault_finish" );

	addNotetrack_customFunction("cypher", "bink_start",  maps\clockwork_interior::start_scan, "vault_approach");
	addNotetrack_customFunction("cypher", "bink_stop",  maps\clockwork_interior::stop_scan, "vault_approach");
	addNotetrack_customFunction("cypher", "bink_start",  maps\clockwork_interior::start_scan, "vault_betweener");
	addNotetrack_customFunction("cypher", "bink_stop",  maps\clockwork_interior::stop_scan, "vault_betweener");

	addNotetrack_customFunction("cypher", "light_on",  maps\clockwork_interior::tablet_light_on, "vault_approach");
	addNotetrack_customFunction("cypher", "light_off",  maps\clockwork_interior::tablet_light_off, "vault_approach");
	addNotetrack_customFunction("cypher", "light_on",  maps\clockwork_interior::tablet_light_on, "vault_betweener");
	addNotetrack_customFunction("cypher", "light_off",  maps\clockwork_interior::tablet_light_off, "vault_betweener");
	addNotetrack_customFunction("cypher", "light_on",  maps\clockwork_interior::tablet_light_on, "vault_finish");
	addNotetrack_customFunction("cypher", "light_off",  maps\clockwork_interior::tablet_light_off, "vault_finish");

	addNotetrack_customFunction("cypher", "chalk_x1",  maps\clockwork_interior::chalk_swipe1, "vault_approach");
	addNotetrack_customFunction("cypher", "chalk_x2",  maps\clockwork_interior::chalk_swipe2, "vault_betweener");
	addNotetrack_flag( "cypher", "drill_here1", "drill_spot1_ready", "vault_approach" );
	addNotetrack_flag( "cypher", "drill_here2", "drill_spot2_ready", "vault_betweener" );

	//discovery guys
	level.scr_anim[ "discoverguy1" ]["discover_vault"] = %clockwork_post_vault_guard1;
	level.scr_anim[ "discoverguy2" ]["discover_vault"] = %clockwork_post_vault_guard2;

	
	//dazed guys after vault blast
	level.scr_anim[ "generic" ][ "paris_npc_dead_poses_v10"	 ][ 0 ] = %paris_npc_dead_poses_v10;
	level.scr_anim[ "generic" ][ "surprise_stop" ]					= %surprise_stop_v1;
	
	level.scr_anim[ "generic" ][ "scientist_idle" ][0] = %unarmed_cowercrouch_idle_duck;
	
//	level.scr_anim[ "generic" ][ "london_dock_soldier_walk_point" ] = %london_dock_soldier_walk_point;
//	level.scr_anim[ "generic" ][ "london_station_civ2_reaction"	  ] = %london_station_civ2_reaction;
//	level.scr_anim[ "generic" ][ "surprise_stop_v1"				  ] = %surprise_stop_v1;

	// soldier waving scientists out
	level.scr_anim[ "generic" ][ "civilian_run_hunched_B" ]			   = %civilian_run_hunched_B;
	level.scr_anim[ "generic" ][ "prague_bully_civ_run"	  ]			   = %prague_bully_civ_run;
	level.scr_anim[ "generic" ][ "flee_alley_civilain"	  ]			   = %flee_alley_civilain;
//	level.scr_anim[ "generic" ][ "london_police_wave"	  ]			   = %london_police_wave;
	level.scr_anim[ "generic" ][ "bog_price_wait_wave_A"		][ 0 ] = %bog_price_wait_wave_A;
	level.scr_anim[ "generic" ][ "roadkill_shepherd_stair_wave" ][ 0 ] = %roadkill_shepherd_stair_wave;
	
	level.scr_anim[ "generic" ][ "bust_door"	  ]			  = %clockwork_shoulder_charge_keegan;
	level.scr_anim[ "generic" ][ "shut_door_start"]			  = %clockwork_shoulder_charge_close_baker_enter;
	level.scr_anim[ "generic" ][ "shut_door_loop" ][0]		  = %clockwork_shoulder_charge_close_baker_loop;
	level.scr_anim[ "generic" ][ "shut_door_end"  ]			  = %clockwork_shoulder_charge_close_baker_exit;
	level.scr_anim[ "generic" ][ "slow_open_door" ]			  = %clockwork_stealth_open_keegan;
	level.scr_anim[ "generic" ][ "slow_open_door_idle" ][ 0 ] = %hunted_open_barndoor_idle;

	// catwalk ambush
	level.scr_anim[ "winner" ][ "catwalk_melee" ] = %clockwork_catwalk_melee_keegan;
	level.scr_anim[ "loser" ][ "catwalk_melee" ] = %clockwork_catwalk_melee_enemy;
							 //   animname    notetrack    function 							    anime 			 
	addNotetrack_customFunction( "loser"  , "break_glass" , maps\clockwork_interior::catwalk_melee_glass_break, "catwalk_melee" );
	
//	level.scr_anim[ "generic" ][ "cqb_stop_signal" ] = %CQB_stop_2_signal;
		
	// rotunda kill
	level.scr_anim[ "cipher" ][ "rotunda_kill" ] = %clockwork_rotunda_kill_keegan;
	level.scr_anim[ "guard1" ][ "rotunda_kill" ] = %clockwork_rotunda_kill_guard1;
	level.scr_anim[ "guard2" ][ "rotunda_kill" ] = %clockwork_rotunda_kill_guard2;
	level.scr_anim[ "guard3" ][ "rotunda_kill" ] = %clockwork_rotunda_kill_guard3;
	level.scr_anim[ "guard4" ][ "rotunda_kill" ] = %clockwork_rotunda_kill_guard4;

	addNotetrack_customFunction( "cipher"  , "hide_knife" , maps\clockwork_interior::hide_rotunda_knife, "rotunda_kill" );
	addNotetrack_customFunction( "cipher"  , "show_knife" , maps\clockwork_interior::show_rotunda_knife, "rotunda_kill" );

	addNotetrack_customFunction( "guard1"  , "knife_kill" , maps\clockwork_interior::rotunda_knife_stab, "rotunda_kill" );
	addNotetrack_customFunction( "guard2"  , "knife_kill" , maps\clockwork_interior::rotunda_knife_stab, "rotunda_kill" );

	addNotetrack_customFunction( "guard1"  , "knife_kill" , maps\clockwork_interior::get_killed, "rotunda_kill" );
	addNotetrack_customFunction( "guard2"  , "knife_kill" , maps\clockwork_interior::get_killed, "rotunda_kill" );
	
	
//	addNotetrack_customFunction( "guard1"  , "die" , maps\_utility::die, "rotunda_kill" );
	
	// Defend anims sjp
	level.scr_anim[ "generic" ][ "defend_run_scientist_1" ] = %clockwork_defend_run_scientist_1;
	level.scr_anim[ "generic" ][ "defend_run_scientist_2" ] = %clockwork_defend_run_scientist_2;
	level.scr_anim[ "generic" ][ "defend_run_scientist_3" ] = %clockwork_defend_run_scientist_3;
	
	// --Combat Rappel Grenade Roll--
	level.scr_anim[ "cypher" ][ "grenade_throw_exit" ]		= %cornered_rappel_enemy_roll_grenade;
	level.scr_anim[ "keegan" ][ "grenade_throw_exit" ]		= %cornered_rappel_enemy_roll_grenade;
	level.scr_anim[ "baker" ][ "grenade_throw_exit" ]		= %exposed_grenadethrowc;
	addNotetrack_customFunction( "cypher"  , "grenade_tossed" , maps\clockwork_defend::grenade_tossed, "grenade_throw_exit" );
	addNotetrack_customFunction( "keegan"  , "grenade_tossed" , maps\clockwork_defend::grenade_tossed, "grenade_throw_exit" );
	addNotetrack_customFunction( "baker"  , "grenade_throw" , maps\clockwork_defend::grenade_tossed, "grenade_throw_exit" );
	

	// guns on the table that guys grab (attached to J_prop_2)
	level.scr_anim[ "generic" ][ "defend_reload_baker" ] = %clockwork_defend_reload_baker;
	level.scr_anim[ "generic" ][ "defend_reload_keegan" ] = %clockwork_defend_reload_keegan;
	
	//Cypher shooting handgun from his hacking anim – 2 anims, left and right
	level.scr_anim[ "cypher" ][ "defend_shoot_left_cypher" ] =  %clockwork_defend_shoot_left_cypher;
	level.scr_anim[ "cypher" ][ "defend_shoot_right_cypher" ] = %clockwork_defend_shoot_right_cypher;
	
	//Ally hitting the vault door button to close it
	level.scr_anim[ "cypher" ][ "defend_close_door" ] = %clockwork_defend_close_door_keegan;  
	
	
	
	
	
	
	level.scr_anim[ "generic" ][ "civilian_walk_nervous"   ]  = %civilian_walk_nervous;
//	level.scr_anim[ "generic" ][ "civilian_walk_hurried_2" ]  = %civilian_walk_hurried_2;
//	level.scr_anim[ "generic" ][ "civilian_walk_hurried_1" ]  = %civilian_walk_hurried_1;
//	level.scr_anim[ "generic" ][ "civilian_stand_idle" ][ 0 ] = %civilian_stand_idle;
	level.scr_anim[ "generic" ][ "civilian_run" ]			  = %civilian_run_hunched_A;
	level.scr_anim[ "baker"	  ][ "table_stand_idle" ][ 0 ]	  = %clockwork_defend_loop_baker;
	level.scr_anim[ "baker" ][ "baker_fire_air" ]			  = %clockwork_scientist_clear_baker;
	
	level.scr_anim[ "baker"	 ][ "defend_bagdrop" ]			  = %clockwork_defend_bag_drop_baker;
	level.scr_anim[ "keegan" ][ "defend_bagdrop" ]			  = %clockwork_defend_bag_drop_keegan;
	level.scr_anim[ "cypher" ][ "defend_bagdrop" ]			  = %clockwork_defend_bag_drop_cypher;
	level.scr_anim[ "cypher" ][ "laptop_sit_idle_calm" ][ 0 ] = %clockwork_defend_cpu_loop_cypher;
	level.scr_anim[ "cypher" ][ "laptop_stand" ]			  = %clockwork_defend_cpu_finish_cypher;
	
							 //   animname    notetrack    function 							    anime 			 
	addNotetrack_customFunction( "keegan"  , "hide_bag" , maps\clockwork_defend::bag_vis_callback, "defend_bagdrop" );
	addNotetrack_customFunction( "cypher"  , "hide_bag" , maps\clockwork_defend::bag_vis_callback, "defend_bagdrop" );
	addNotetrack_customFunction( "baker"   , "hide_bag" , maps\clockwork_defend::bag_vis_callback, "defend_bagdrop" );
	
	
	//chaos anims
	// Commander wave
	level.scr_anim[ "generic" ][ "commander_start" 		][ 0 ] = %roadkill_shepherd_stair_wave;
	level.scr_anim[ "generic" ][ "wave_guard"  			][ 0 ] = %clockwork_chaos_wave_guard;
	
	// Intro to chaos runners
	level.scr_anim[ "generic" ][ "pointer_start" ] = %patrol_jog_orders_once;
	level.scr_anim[ "generic" ][ "runner_start"	 ] = %paris_sabre_wave;
	
	// Typer
	level.scr_anim[ "generic" ][ "typer_start"	][ 0 ] = %laptop_sit_idle_calm;
	level.scr_anim[ "generic" ][ "talker_start" ][ 0 ] = %laptop_officer_talk;
	
	// Direction giving anims
	level.scr_anim[ "generic" ][ "direction_give" ][ 0 ]			= %civilian_directions_1_A_once;
	level.scr_anim[ "generic" ][ "direction_take" ][ 0 ]			= %civilian_directions_1_B_once;
	level.scr_anim[ "generic" ][ "direction_loop" ][ 0 ] 			= %civilian_directions_2_A_idle;
	
	// Stand on balcony talking
	level.scr_anim[ "generic" ][ "balcony_talk"				 ][ 0 ]	= %killhouse_gaz_talk_side;
	
	// Fire exting
	level.scr_anim[ "generic" ][ "extinguish"				 ][ 0 ]	= %clockwork_chaos_extinguisher_loop_guard;
	
	// Drill inspection
	level.scr_anim[ "generic" ][ "vault_door_loop" 			 ][ 0 ] = %clockwork_chaos_drill_find_loop_guard;
	
	// Help friend
	//level.scr_anim[ "generic" ][ "DC_Burning_stop_bleeding_medic"	]			= %DC_Burning_stop_bleeding_medic;
	//level.scr_anim[ "generic" ][ "DC_Burning_stop_bleeding_wounded" ]			= %DC_Burning_stop_bleeding_wounded;
	//level.scr_anim[ "generic" ][ "DC_Burning_stop_bleeding_medic_idle"	 ][ 0 ] = %DC_Burning_stop_bleeding_medic_endidle;
	//level.scr_anim[ "generic" ][ "DC_Burning_stop_bleeding_wounded_idle" ][ 0 ] = %DC_Burning_stop_bleeding_wounded_endidle;
	
	// Meetup 
	level.scr_anim[ "generic" ][ "meetup_follower" ] = %london_sandman_sas_talk_sandman;
	level.scr_anim[ "generic" ][ "meetup_followed" ] = %london_sandman_sas_talk_friendly;
	
	// Doctor revival
	level.scr_anim[ "generic" ][ "dc_burning_cpr_wounded_endidle"	 ][ 0 ] = %dc_burning_cpr_wounded_endidle;
	level.scr_anim[ "generic" ][ "dc_burning_cpr_wounded"			 ]		= %dc_burning_cpr_wounded;
	level.scr_anim[ "generic" ][ "dc_burning_cpr_medic_endidle"		 ][ 0 ] = %dc_burning_cpr_medic_endidle;
	level.scr_anim[ "generic" ][ "dc_burning_cpr_medic"				 ]		= %dc_burning_cpr_medic;
	
	// Stumble to wall	
	level.scr_anim[ "generic" ][ "stumble_to_wall"					 ]		= %DC_Burning_bunker_stumble;
	level.scr_anim[ "generic" ][ "stumble_to_wall_idle"				 ][ 0 ] = %DC_Burning_bunker_sit_idle;
	
	// Computer typers
	level.scr_anim[ "generic" ][ "computer_stander_runin" ][ 0 ] = %laptop_stand_lookaway;
	level.scr_anim[ "generic" ][ "computer_stander_runin" ][ 1 ] = %laptop_stand_idle;
	level.scr_anim[ "generic" ][ "computer_stander_runin" ][ 2 ] = %laptop_stand_idle_flinch;
	level.scr_anim[ "generic" ][ "computer_stander_runin" ][ 3 ] = %laptop_stand_idle_focused;
	
	// Lost hope guy
	level.scr_anim[ "generic" ][ "lost_hope"						 ]		= %paris_ac130_sandman_rescue_talk;
	
	// Help downed guard
	level.scr_anim[ "generic" ][ "hurt_start_loop"					 ][ 0 ]	= %clockwork_chaos_enemy_help_loop1_guard;
	level.scr_anim[ "generic" ][ "hurt_anim"						 ]		= %clockwork_chaos_enemy_help_guard;
	level.scr_anim[ "generic" ][ "help_anim"						 ]		= %clockwork_chaos_enemy_help_guard2;
	level.scr_anim[ "generic" ][ "hurt_end_loop"					 ][ 0 ]	= %clockwork_chaos_enemy_help_loop2_guard;
	level.scr_anim[ "generic" ][ "help_end_loop"					 ][ 0 ]	= %clockwork_chaos_enemy_help_loop2_guard2;
	
	// Gun down walk
	level.scr_anim[ "generic" ][ "active_patrolwalk_gundown"		 ] 		= %active_patrolwalk_gundown;
	
	// Jogs
	level.scr_anim[ "generic" ][ "patrol_jog"						 ] = %combat_jog;
	level.scr_anim[ "generic" ][ "casual_killer_jog" ][ 0 ]			   = %casual_killer_jog_A;
	level.scr_anim[ "generic" ][ "casual_killer_jog" ][ 1 ]			   = %casual_killer_jog_B;
	level.scr_anim[ "generic" ][ "clock_walk" ]			  	   		   = %clockwork_walkout_allies_walk_1;
	level.scr_anim[ "generic" ][ "clock_jog" ]			 	  		   = %clockwork_walkout_allies_jog_1;
			
	// Fireman carry anims
	level.scr_anim[ "generic" ][ "carrier_sin" ]	   = %DC_Burning_wounded_carry_putdown_carrier;
	level.scr_anim[ "generic" ][ "carried_sin" ]	   = %DC_Burning_wounded_carry_putdown_wounded;
	level.scr_anim[ "generic" ][ "carrier_loop" ][ 0 ] = %DC_Burning_wounded_carry_idle_carrier;
	level.scr_anim[ "generic" ][ "carried_loop" ][ 0 ] = %DC_Burning_wounded_carry_idle_wounded;
	
	// Dragging friend to safety
	level.scr_anim[ "generic" ][ "dragged_sin"						 ]		= %clockwork_chaos_drag_dead_guy;
	level.scr_anim[ "generic" ][ "dragged_loop"					 	 ][ 0 ] = %clockwork_chaos_drag_loop_dead_guy;
	level.scr_anim[ "generic" ][ "dragger_sin"						 ]		= %clockwork_chaos_drag_guard;
	level.scr_anim[ "generic" ][ "dragger_loop"						 ][ 0 ]	= %clockwork_chaos_drag_loop_guard;
	
	// Dog handler anims
	//level.scr_anim[ "generic" ][ "dog_handler" ][ 0 ]						= %clockwork_chaos_dogsniff_handler;

	// New dog handler anims
	level.scr_anim[ "generic" ][ "cha_handler_idle" ][ 0 ]						= %clockwork_chaos_idle_handler;
	level.scr_anim[ "generic" ][ "cha_handler_alert" ]							= %clockwork_chaos_alert_handler;
	level.scr_anim[ "generic" ][ "cha_handler_react" ][ 0 ]						= %clockwork_chaos_react_handler;
	level.scr_anim[ "generic" ][ "cha_handler_turn" ]							= %clockwork_chaos_turn_handler;
	level.scr_anim[ "generic" ][ "cha_handler_idle2" ][ 0 ]						= %clockwork_chaos_idle2_handler;
	
	// Bug finders
	level.scr_anim[ "generic" ][ "bug_finder"  ]							= %clockwork_chaos_bug_find_start_guard1;
	level.scr_anim[ "generic" ][ "bug_finder_loop"					 ][ 0 ] = %clockwork_chaos_bug_find_loop_guard1;
	level.scr_anim[ "generic" ][ "bug_finder2"						 ]		= %clockwork_chaos_bug_find_start_guard2;
	level.scr_anim[ "generic" ][ "bug_finder_loop2"					 ][ 0 ] = %clockwork_chaos_bug_find_loop_guard2;
	
	// Baker elevator
//	level.scr_anim[ "generic" ][ "ele_baker"						 ]		= %clockwork_chaos_elevator_intro_baker;
//	level.scr_anim[ "generic" ][ "ele_baker_loop"					 ][ 0 ] = %clockwork_chaos_elevator_loop_baker;
//	level.scr_anim[ "generic" ][ "exit_baker" ]								= %clockwork_chaos_elevator_exit_baker;
//	level.scr_anim[ "generic" ][ "exit_guard" ]								= %clockwork_chaos_elevator_exit_guard;
//	level.scr_anim[ "generic" ][ "exit_guard_loop"					 ][ 0 ] = %clockwork_chaos_elevator_loop_guard;

	// Ally idles
//	level.scr_anim[ "generic" ][ "enter_idle_l"						 ] 		= %clockwork_walkout_allies_cypher_idle_enter;
	level.scr_anim[ "generic" ][ "idle_l"							 ]		= %clockwork_walkout_allies_cypher_idle;
//	level.scr_anim[ "generic" ][ "exit_idle_l"						 ]		= %clockwork_walkout_allies_cypher_idle_exit;

//	level.scr_anim[ "generic" ][ "enter_idle_r"						 ] 		= %clockwork_walkout_allies_merrick_idle_enter;
	level.scr_anim[ "generic" ][ "idle_r"							 ]		= %clockwork_walkout_allies_merrick_idle;
//	level.scr_anim[ "generic" ][ "exit_idle_r"						 ]		= %clockwork_walkout_allies_merrick_idle_exit;

	// Elevator Anims
	level.scr_anim[ "generic" ][ "enter_ele_mer"					 ]		= %clockwork_walkout_elevator_enter_merrick;
	level.scr_anim[ "generic" ][ "enter_ele_kee"					 ]		= %clockwork_walkout_elevator_enter_keegan;
	level.scr_anim[ "generic" ][ "enter_ele_cyp"					 ]		= %clockwork_walkout_elevator_enter_cypher;
	
	level.scr_anim[ "generic" ][ "wait_ele_mer"						 ][ 0 ] = %clockwork_walkout_elevator_wait_merrick;
	level.scr_anim[ "generic" ][ "wait_ele_kee"						 ][ 0 ] = %clockwork_walkout_elevator_wait_keegan;
	level.scr_anim[ "generic" ][ "wait_ele_cyp"						 ][ 0 ] = %clockwork_walkout_elevator_wait_cypher;
	
	level.scr_anim[ "generic" ][ "exit_ele_mer"						 ]		= %clockwork_walkout_elevator_main_merrick;
	addNotetrack_flag( "generic", "start_enemies", "elevator_enemies_start", "exit_ele_mer" );
	addNotetrack_flag( "generic", "ps_clockwork_mrk_keepyourweaponslow", 		"elevator_weapons_down", 	"exit_ele_mer" );
	addNotetrack_flag( "generic", "ps_clockwork_mrk_limp", 						"elevator_limp", 			"exit_ele_mer" );
	addNotetrack_flag( "generic", "door_close", 								"door_close", 				"exit_ele_mer" );
	addNotetrack_flag( "generic", "door_open", 				 					"door_open", 				"exit_ele_mer" );
	level.scr_anim[ "generic" ][ "exit_ele_kee"						 ]		= %clockwork_walkout_elevator_main_keegan;
	level.scr_anim[ "generic" ][ "exit_ele_cyp"						 ]		= %clockwork_walkout_elevator_main_cypher;
	level.scr_anim[ "generic" ][ "exit_ele_g1"						 ]		= %clockwork_walkout_elevator_main_enemy1;
	level.scr_anim[ "generic" ][ "exit_ele_g2"						 ]		= %clockwork_walkout_elevator_main_enemy2;
	level.scr_anim[ "generic" ][ "exit_ele_g3"						 ]		= %clockwork_walkout_elevator_main_enemy3;
	level.scr_anim[ "generic" ][ "rev_ele_g3"						 ][ 0 ]	= %clockwork_walkout_elevator_cpr_enemy3;
	level.scr_anim[ "generic" ][ "rev_ele_vic"						 ][ 0 ]	= %clockwork_walkout_elevator_cpr_victim;

	// Jeep Check
	level.scr_anim[ "generic" ][ "check_jeep"						 ][ 0 ]	= %clockwork_chaos_jeep_check_guard;

	// Cypher helping others out	
	level.scr_anim[ "generic" ][ "helpee_intro_loop"				 ][ 0 ]	= %clockwork_chaos_help_out_intro_loop_guard;
	level.scr_anim[ "generic" ][ "helpee_out"						 ]		= %clockwork_chaos_help_out_guard;
	level.scr_anim[ "generic" ][ "helper_out"						 ]		= %clockwork_chaos_help_out_cypher;
	level.scr_anim[ "generic" ][ "helpee_exit_loop"					 ][ 0 ]	= %clockwork_chaos_help_out_end_loop_guard;

	// Drag interrogation	
	level.scr_anim[ "generic" ][ "dragger_interrogate"				 ]		= %prague_interrogate_1_soldier_drag;
	level.scr_anim[ "generic" ][ "dragger_interrogate_loop"			 ][ 0 ]	= %prague_interrogate_1_soldier_idle;

	level.scr_anim[ "generic" ][ "drag_interrogate"					 ]		= %prague_interrogate_1_civ_drag;
	level.scr_anim[ "generic" ][ "drag_interrogate_loop"			 ][ 0 ]	= %prague_interrogate_1_civ_idle;

	level.scr_anim[ "generic" ][ "drag_talker_loop"					 ][ 0 ]	= %training_intro_foley_idle_talk_1;
	level.scr_anim[ "generic" ][ "drag_talker_loop"					 ][ 1 ]	= %training_intro_foley_idle_talk_2;

	level.scr_anim[ "generic" ][ "drag_talkee_loop"					 ][ 0 ]	= %training_intro_foley_idle_1;
	
	// Punchit scene
	level.scr_anim[ "generic" ][ "punchit_start_cypher"				 ]		= %clockwork_exfil_garage_punchit_start_cypher;
	level.scr_anim[ "generic" ][ "punchit_start_baker"				 ]		= %clockwork_exfil_garage_punchit_start_baker;
	level.scr_anim[ "generic" ][ "punchit_start_keegan"				 ]		= %clockwork_exfil_garage_punchit_start_keegan;
	level.scr_anim[ "generic" ][ "punchit_start_guard1"				 ]		= %clockwork_exfil_garage_punchit_start_guard1;
	level.scr_anim[ "generic" ][ "punchit_start_guard2"				 ]		= %clockwork_exfil_garage_punchit_start_guard2;
	level.scr_anim[ "generic" ][ "punchit_start_edriver"			 ]		= %clockwork_exfil_garage_punchit_start_edriver;
	level.scr_anim[ "generic" ][ "punchit_start_epass"				 ]		= %clockwork_exfil_garage_punchit_start_epass;
	level.scr_anim[ "generic" ][ "punchit_start_guard3"				 ]		= %clockwork_exfil_garage_punchit_start_guard3;


	level.scr_anim[ "generic" ][ "punchit_end_cypher"				 ]		= %clockwork_exfil_garage_punchit_end_cypher;
	level.scr_anim[ "generic" ][ "punchit_end_baker"				 ]		= %clockwork_exfil_garage_punchit_end_baker;
	level.scr_anim[ "generic" ][ "punchit_end_keegan"				 ]		= %clockwork_exfil_garage_punchit_end_keegan;
	level.scr_anim[ "generic" ][ "punchit_end_guard1"				 ]		= %clockwork_exfil_garage_punchit_end_guard1;
	level.scr_anim[ "generic" ][ "punchit_end_guard2"				 ]		= %clockwork_exfil_garage_punchit_end_guard2;
	level.scr_anim[ "generic" ][ "punchit_end_edriver"				 ]		= %clockwork_exfil_garage_punchit_end_edriver;
	level.scr_anim[ "generic" ][ "punchit_end_epass"				 ]		= %clockwork_exfil_garage_punchit_end_epass;
	level.scr_anim[ "generic" ][ "punchit_end_guard3"				 ]		= %clockwork_exfil_garage_punchit_end_guard3;           
                	
	// baker waiting anims
	level.scr_anim[ "generic" ][ "garage_enter"						 ]		= %clockwork_exfil_garage_baker_enter;
	level.scr_anim[ "generic" ][ "garage_loop"						 ][ 0 ]	= %clockwork_exfil_garage_baker_loop;
	level.scr_anim[ "generic" ][ "garage_exit"						 ]		= %clockwork_exfil_garage_baker_exit;
	
	// Base exit passenger in car anims
	level.scr_anim[ "generic" ][ "exfilstartdriver"					 ]		= %clockwork_exfil_jeepride_start_keegan;
	level.scr_anim[ "generic" ][ "exfilstartpassenger"				 ]		= %clockwork_exfil_jeepride_start_baker;
	
//	level.scr_anim[ "generic" ][ "exfilpunchdriver"					 ]		= %clockwork_exfil_jeepride_punchit_keegan;
//	level.scr_anim[ "generic" ][ "exfilpunchpassenger"				 ]		= %clockwork_exfil_jeepride_punchit_baker;
//	level.scr_anim[ "generic" ][ "exfilpunchback"					 ]		= %clockwork_exfil_jeepride_punchit_cypher;

//	level.scr_anim[ "generic" ][ "exfilintensedriver"				 ]		= %clockwork_exfil_jeepride_intense_keegan;
	
	//level.scr_anim[ "generic" ][ "stopanim"							 ]		= %clockwork_exfil_jeep_stop_guard;
	
	// Sub exfil anims
	level.scr_anim[ "generic" ][ "nxsubdriver"						 ]		= %clockwork_sub_breach_nx_driver;
	level.scr_anim[ "generic" ][ "nxsubpassenger"				 	 ]		= %clockwork_sub_breach_nx_passenger;
	level.scr_anim[ "generic" ][ "nxsubbackseat"				 	 ]		= %clockwork_sub_breach_nx_cypher;
	
	// Shockwave
	level.scr_anim[ "generic" ][ "shockwave_shock_1" 				 ] 		= %pain_electric_claymore;
	level.scr_anim[ "generic" ][ "shockwave_shock_2" 				 ] 		= %pain_electric_claymore_2;
	level.scr_anim[ "generic" ][ "shockwave_shock_3" 				 ] 		= %pain_electric_claymore_3;
	level.scr_anim[ "generic" ][ "shockwave_shock_4" 				 ] 		= %pain_electric_claymore_4;
}

#using_animtree( "generic_human" );
dead_guys()
{
	//dead
	level.scr_animtree	[ "dead" ]		   									= #animtree;
	level.scr_model		[ "dead" ]											= "body_russian_military_assault_a_arctic";
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v09" ][ 0 ] 			= %paris_npc_dead_poses_v09;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v13" ][ 0 ] 			= %paris_npc_dead_poses_v13;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v14" ][ 0 ] 			= %paris_npc_dead_poses_v14;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v15" ][ 0 ] 			= %paris_npc_dead_poses_v15;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v18" ][ 0 ] 			= %paris_npc_dead_poses_v18;level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v24_chair_sq" ][ 0 ] 	= %paris_npc_dead_poses_v24_chair_sq;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v19" ][ 0 ] 			= %paris_npc_dead_poses_v19;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v21" ][ 0 ] 			= %paris_npc_dead_poses_v21;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v22" ][ 0 ] 			= %paris_npc_dead_poses_v22;
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v24_chair_sq" ][ 0 ] 	= %paris_npc_dead_poses_v24_chair_sq;
	
	
}

#using_animtree( "player" );
load_player_anims()
{
	// helmet intro
	level.scr_animtree[ "player_mask" ] = #animtree;
	level.scr_model	  [ "player_mask" ] = "viewmodel_helmet_goggles";
	level.scr_anim[ "player_mask" ][ "clock_prepare" ]			   = %clockwork_level_intro_player_helmet_toss_mask;

	
	//player intro
	level.scr_animtree[ "player_rig" ]							= #animtree;
	level.scr_model	  [ "player_rig" ]							= "viewhands_player_yuri";

	//Player watch
	level.scr_anim[ "player_rig" ][ "watch_sync_intro"			] = %clockwork_level_intro_player_helmet_toss;
	//level.scr_anim[ "player_rig" ][ "watch_sync_generic"		] = %clockwork_sync_watch_player;
	///level.scr_anim[ "player_rig" ][ "watch_sync_generic_crouch" ] = %clockwork_sync_watch_crouch_player;
	//level.scr_anim[ "player_rig" ][ "watch_sync_jeep"			] = %clockwork_jeep_ride_sync_player;
	
	//Player Body Drag
	level.scr_anim[ "player_rig" ][ "clock_bodydrag_drag" ] 		= %clockwork_intro_drag_body_player;
	
	
//	level.scr_anim[ "player_rig" ][ "intro1" ]	   = %clockwork_vault_drill_intro_player;
//	level.scr_anim[ "player_rig" ][ "loop1" ][ 0 ] = %clockwork_vault_drill_loop1_player;
	level.scr_anim[ "player_rig" ][ "back1"	 ]	   = %clockwork_vault_drill_pullback1_player;
//	level.scr_anim[ "player_rig" ][ "intro2" ]	   = %clockwork_vault_drill_approach2_player;
//	level.scr_anim[ "player_rig" ][ "loop2" ][ 0 ] = %clockwork_vault_drill_loop2_player;
	level.scr_anim[ "player_rig" ][ "back2" ]	   = %clockwork_vault_drill_pullback2_player;
	
	// Jeep Enter
//	level.scr_anim[ "player_rig" ][ "exfil_enter_jeep_player"  ]		   	= %payback_exfil_enter_jeep_player;
	level.scr_anim[ "player_rig" ][ "ambush_jeep_enter_player" ]		   	= %clockwork_intro_jeep_ambush_jeep_enter_player;
	level.scr_anim[ "player_rig" ][ "ambush_jeep_enter_player_loop" ][ 0 ] 	= %clockwork_jeep_ride_idle_player;
	level.scr_anim[ "player_rig" ][ "clock_ambush_end_knife" ]			   	= %clockwork_intro_jeep_ambush_knifekill_player; //Attach the viewmodel_commando_knife to the player’s TAG_WEAPON_RIGHT
	level.scr_anim[ "player_rig" ][ "player_grab_ambush_bags" ]			   	= %clockwork_intro_jeep_ambush_grab_bag_player;
	level.scr_anim[ "player_rig" ][ "intro_jeep_exit_player" ] 				= %clockwork_garage_arrival_player;
	
	//Drop bag off
		
	level.scr_anim[ "player_rig" ][ "defend_bagdrop" ] 			= %clockwork_defend_bag_drop_player;
	addNotetrack_customFunction( "player_rig"  , "hide_bag" , maps\clockwork_defend::bag_vis_callback, "defend_bagdrop" );
	
	//exfil
	level.scr_anim[ "player_rig" ][ "player_getin" ] 		= %clockwork_exfil_garage_jeep_mount_player;
	
	level.scr_anim[ "player_rig" ][ "player_toturret" ] 	= %clockwork_exfil_garage_jeep_turret_enter_player;
	
	//level.scr_anim[ "player_rig" ][ "sub_jump" ] 	 		= %clockwork_sub_breach_jump_player;
	level.scr_anim[ "player_rig" ][ "nx_sub_alt" ] 			= %clockwork_sub_breach_nx_player_alt;
	addNotetrack_flag( "player_rig", "player_land", "exfil_player_land", "nx_sub_alt" );
	level.scr_anim[ "player_rig" ][ "nx_sub" ] 		 		= %clockwork_sub_breach_nx_player;
	
	//addNotetrack_customFunction( "player_rig", "knife_stab", maps\clockwork_fx::handle_ambush_victim_fx, "clock_ambush_end_knife");
	// flags for watch light fx
	addNotetrack_flag("player_rig", "light_on", "intro_watch_on", "watch_sync_intro");
	addNotetrack_flag("player_rig", "light_off", "intro_watch_off", "watch_sync_intro");
	
	
}

#using_animtree( "vehicles" );
vehicle_anims()
{
	level.scr_anim[ "garage_arrival_jeep" ][ "clockwork_garage_arrival" ] = %clockwork_garage_arrival_jeep;
	addNotetrack_flag("garage_arrival_jeep","player_start","FLAG_player_getout_jeep","clockwork_garage_arrival");
	level.scr_anim[ "ambush_jeep"		  ][ "ambush_jeep_enter_player" ] = %clockwork_intro_jeep_ambush_jeep_enter_jeepdoor;
	
	//level.scr_anim[ "ambush_jeep" ][ "clock_ambush_start" ] = %clockwork_intro_jeep_ambush_kick_jeep;
	level.scr_anim[ "ambush_jeep" ][ "clock_ambush_end" ]	  = %clockwork_intro_jeep_ambush_end_jeep;                    

	level.scr_anim[ "ambush_jeep" ][ "clockwork_jeep_bloodwipe" ] 	= %clockwork_jeep_ride_bloodwipe_jeep;
//	level.scr_anim[ "ambush_jeep" ][ "clockwork_jeep_sync" ]		= %clockwork_jeep_ride_sync_jeep;
//	level.scr_anim[ "ambush_jeep" ][ "clockwork_jeep_wave" ] 		= %clockwork_jeep_ride_wave_jeep;
	
	level.scr_anim[ "jeep" ][ "player_getin" ] 						= %clockwork_exfil_garage_jeep_mount_door;
	level.scr_anim[ "jeep" ][ "open_doors" ][ 0 ]					= %clockwork_chaos_jeep_check_jeep;
	
	level.scr_anim[ "jeep" ][ "exfilstartJeep" ]					= %clockwork_exfil_jeepride_start_jeep;
		
	//level.scr_anim[ "jeep" ][ "exfilpunchJeep" ]					= %clockwork_exfil_jeepride_punchit_jeep;
	
	//level.scr_anim[ "jeep" ][ "exfilintenseJeep" ]					= %clockwork_exfil_jeepride_intense_jeep;
	
	// Icehole crashes
	/*
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_a"	   ] = %clock_jeep_crash_ice_a;
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_b"	   ] = %clock_jeep_crash_ice_b;
	*/
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_longa" ] = %clockwork_jeep_crash_jeep_long_a;
	/*
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_longb" ] = %clockwork_jeep_crash_jeep_long_b;
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_longc" ] = %clockwork_jeep_crash_jeep_long_c;
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_1"	   ] = %clockwork_jeep_crash_jeep_1;
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_2"	   ] = %clockwork_jeep_crash_jeep_2;
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_3"	   ] = %clockwork_jeep_crash_jeep_3;
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_4"	   ] = %clockwork_jeep_crash_jeep_4;
	level.scr_anim[ "icehole_crashes" ][ "icehole_crash_5"	   ] = %clockwork_jeep_crash_jeep_5;
	*/
	
	/* * SUB BREACH**/
	// jeeps in sub crash
	/*
	level.scr_animtree[ "cw_car_breach" ]			   = #animtree;
	level.scr_model	  [ "cw_car_breach" ]			   = "vehicle_chinese_brave_warrior_anim";
	level.scr_anim[ "cw_car_breach" ][ "car1_breach" ] = %clockwork_sub_breach_jeep1;
	level.scr_anim[ "cw_car_breach" ][ "car2_breach" ] = %clockwork_sub_breach_jeep2;
	*/
	
	// nx player car
	level.scr_animtree[ "cw_car_breach" ]			   		= #animtree;
	level.scr_model	  [ "cw_car_breach" ]			   		= "vehicle_chinese_brave_warrior_anim";
	level.scr_anim[ "cw_car_breach" ][ "player_car_alt" ] 	= %clockwork_sub_breach_nx_jeep_alt;
	level.scr_anim[ "cw_car_breach" ][ "player_car" ] 		= %clockwork_sub_breach_nx_jeep;
	/*
	level.scr_animtree[ "cw_sub_breach" ]			  = #animtree;
	level.scr_model	  [ "cw_sub_breach" ]			  = "clk_sub_breach";
	level.scr_anim[ "cw_sub_breach" ][ "sub_breach" ] = %clockwork_sub_breach_sub;
	*/
	
	// new punch it
	level.scr_animtree[ "cw_punchit" ]			   						= #animtree;
	level.scr_model	  [ "cw_punchit" ]			   						= "vehicle_chinese_brave_warrior_anim";
	level.scr_anim[ "cw_punchit" ][ "punchit_start_parked_jeep" 	] 	= %clockwork_exfil_garage_punchit_start_parked_jeep;
	level.scr_anim[ "cw_punchit" ][ "punchit_start_enemy_jeep" 		] 	= %clockwork_exfil_garage_punchit_start_enemy_jeep;
	level.scr_anim[ "cw_punchit" ][ "punchit_start_ally_jeep" 		] 	= %clockwork_exfil_garage_punchit_start_ally_jeep;

	level.scr_anim[ "cw_punchit" ][ "punchit_end_parked_jeep" 		] 	= %clockwork_exfil_garage_punchit_end_parked_jeep;
	level.scr_anim[ "cw_punchit" ][ "punchit_end_enemy_jeep" 		] 	= %clockwork_exfil_garage_punchit_end_enemy_jeep;
	level.scr_anim[ "cw_punchit" ][ "punchit_end_ally_jeep" 		] 	= %clockwork_exfil_garage_punchit_end_ally_jeep;
	
}

#using_animtree( "animated_props" );
icehole_shards()
{
	// sub fx rig
	/*
	level.scr_animtree[ "subfx" ]			   	= #animtree;
	level.scr_model	  [ "subfx" ]			   	= "clk_sub_breach_fx_rig";
	level.scr_anim[ "subfx" ][ "subfxanim" ] 	= %clockwork_sub_breach_fx_anim;
	*/
	
	// sub fx rig
	level.scr_animtree	[ "nxsubfx" ]			   			= #animtree;
	level.scr_model	  	[ "nxsubfx" ]			   			= "clk_sub_breach_fx_rig";
	level.scr_anim		[ "nxsubfx" ][ "subfxanim" ] 		= %clockwork_sub_breach_nx_fxrig;
	
	addNotetrack_customFunction( "nxsubfx", "fx_notify_chunks_settle", maps\clockwork_exfil::play_sub_fx_settle ,"subfxanim" );
	//addNotetrack_customFunction( "nxsubfx", "fx_notify_hull", maps\clockwork_exfil::play_sub_fx_hull ,"subfxanim_alt" );
	//addNotetrack_customFunction( "nxsubfx", "fx_notify_jeep_ice", maps\clockwork_exfil::play_sub_fx_jeep, "subfxanim"  );
	//addNotetrack_customFunction( "nxsubfx", "FX_notify_trail", maps\clockwork_exfil::play_sub_fx_trail, "subfxanim"  );
	addNotetrack_customFunction( "nxsubfx", "fx_notify_chunks", maps\clockwork_exfil::play_sub_fx_icerise, "subfxanim"  );
	//addNotetrack_customFunction( "nxsubfx", "fx_notify_chunks", maps\clockwork_exfil::play_sub_fx_icerise, "subfxanim_alt"  );

	
	

	// Icehole crashes
	level.scr_animtree[ "cw_ice_shards_longa" ]			   = #animtree;
	level.scr_model	  [ "cw_ice_shards_longa" ]			   = "clk_ice_chunks_lrg_anim";
	level.scr_anim[ "cw_ice_shards_longa" ][ "ice_crash" ] = %clockwork_jeep_crash_ice_long_a;
	/*
	level.scr_animtree[ "cw_ice_shards_longb" ]			   = #animtree;
	level.scr_model	  [ "cw_ice_shards_longb" ]			   = "clk_ice_chunks_lrg_anim";
	level.scr_anim[ "cw_ice_shards_longb" ][ "ice_crash" ] = %clockwork_jeep_crash_ice_long_b;
	
	level.scr_animtree[ "cw_ice_shards_longc" ]			   = #animtree;
	level.scr_model	  [ "cw_ice_shards_longc" ]			   = "clk_ice_chunks_lrg_anim";
	level.scr_anim[ "cw_ice_shards_longc" ][ "ice_crash" ] = %clockwork_jeep_crash_ice_long_c;
	
	level.scr_animtree[ "clockwork_ice_crash_shards" ]				   = #animtree;
	level.scr_model	  [ "clockwork_ice_crash_shards" ]				   = "clockwork_ice_crash_shards";
	level.scr_anim[ "clockwork_ice_crash_shards" ][ "iceshard_break" ] = %clock_iceshard_break;
	*/
	
	/* * SUB BREACH**/
	//new ice
	/* remove after next year
	level.scr_animtree[ "cw_new_ice_breach1a" ]					= #animtree;
	level.scr_model	  [ "cw_new_ice_breach1a" ]					= "clk_sub_breach_ice_rev2_xm1a_anim";
	level.scr_anim[ "cw_new_ice_breach1a" ][ "ice_breach" ] 	= %clockwork_sub_breach_ice_section1;

	level.scr_animtree[ "cw_new_ice_breach1b" ]					= #animtree;
	level.scr_model	  [ "cw_new_ice_breach1b" ]					= "clk_sub_breach_ice_rev2_xm1b_anim";
	level.scr_anim[ "cw_new_ice_breach1b" ][ "ice_breach" ] 	= %clockwork_sub_breach_ice_section2;
	
	level.scr_animtree[ "cw_new_ice_breach2a" ]					= #animtree;
	level.scr_model	  [ "cw_new_ice_breach2a" ]					= "clk_sub_breach_ice_rev2_xm2a_anim";
	level.scr_anim[ "cw_new_ice_breach2a" ][ "ice_breach" ] 	= %clockwork_sub_breach_ice_section3;
	
	level.scr_animtree[ "cw_new_ice_breach2b" ]					= #animtree;
	level.scr_model	  [ "cw_new_ice_breach2b" ]					= "clk_sub_breach_ice_rev2_xm2b_anim";
	level.scr_anim[ "cw_new_ice_breach2b" ][ "ice_breach" ] 	= %clockwork_sub_breach_ice_section4;
	*/
	
	level.scr_animtree	[ "cw_sub_ice" ]							= #animtree;
	level.scr_model	  	[ "cw_sub_ice" ]							= "clk_sub_breach_nx_ice_anim";
	level.scr_anim	  	[ "cw_sub_ice" ][ "ice_breach" ]			= %clockwork_sub_breach_nx_ice;
	
	level.scr_animtree	[ "cw_sub_sub" ]							= #animtree;
	level.scr_model	  	[ "cw_sub_sub" ]							= "clk_sub_breach_nx_sub_anim";
	level.scr_anim	  	[ "cw_sub_sub" ][ "sub_breach" ]			= %clockwork_sub_breach_nx_sub;
	
	// More icehole anims
	level.scr_animtree	[ "cw_icehole" ]							= #animtree;
	level.scr_model	  	[ "cw_icehole" ]							= "clk_ice_hole01_rig";
	level.scr_anim	  	[ "cw_icehole" ][ "ice_a" ]					= %clockwork_exfil_ice_hole_a;
	level.scr_anim	  	[ "cw_icehole" ][ "ice_b" ]					= %clockwork_exfil_ice_hole_b;
	level.scr_anim	  	[ "cw_icehole" ][ "ice_c" ]					= %clockwork_exfil_ice_hole_c;
	
	// gun anims
	level.scr_animtree	[ "cw_pistol" ]								= #animtree;
	level.scr_model	  	[ "cw_pistol" ]								= "viewmodel_p226_sp";
	level.scr_anim	  	[ "cw_pistol" ][ "start" ]					= %clockwork_exfil_garage_punchit_start_pistol;
	level.scr_anim	  	[ "cw_pistol" ][ "end" ]					= %clockwork_exfil_garage_punchit_end_pistol;
}

#using_animtree( "dog" );
dog()
{
	// New dog anims
	level.scr_anim[ "generic" ][ "cha_dog_idle" ][ 0 ] 	= %clockwork_chaos_idle_dog;
	level.scr_anim[ "generic" ][ "cha_dog_alert" ]		= %clockwork_chaos_alert_dog;
	level.scr_anim[ "generic" ][ "cha_dog_react" ][ 0 ] = %clockwork_chaos_react_dog;
	level.scr_anim[ "generic" ][ "cha_dog_turn" ]		= %clockwork_chaos_turn_dog;
	level.scr_anim[ "generic" ][ "cha_dog_idle2" ][ 0 ]	= %clockwork_chaos_idle2_dog;
	
	// start loop
//	level.scr_anim[ "generic" ][ "dog_eating" ][ 0 ] = %german_shepherd_eating_loop;
//	level.scr_anim[ "generic" ][ "dog_eating_out" ]	 = %german_shepherd_eating_out;
	
	//level.scr_anim[ "generic" ][ "dog_sniffing" ][ 0 ] = %clockwork_chaos_dogsniff_dog;
	
	// bark loop
//	level.scr_anim[ "generic" ][ "dog_growl_loop" ][ 0 ] = %german_shepherd_attackidle;
//	level.scr_anim[ "generic" ][ "dog_growl_loop" ][ 1 ] = %german_shepherd_attackidle_growl;
//	level.scr_anim[ "generic" ][ "dog_growl_loop" ][ 2 ] = %german_shepherd_attackidle_bark;
//	level.scr_anim[ "generic" ][ "dog_growl_loop" ][ 3 ] = %german_shepherd_attackidle_bark;
//	level.scr_anim[ "generic" ][ "dog_growl_loop" ][ 4 ] = %german_shepherd_attackidle_growl;
	
	// scratch loop
	level.scr_anim[ "generic" ][ "dog_scratch_door" ][ 0 ] = %german_shepherd_scratch_door;
	//level.scr_anim[ "generic" ][ "dog_scratch_door" ][ 1 ] = %german_shepherd_idle;
	level.scr_anim[ "generic" ][ "dog_scratch_door" ][ 1 ] = %iw6_dog_attackidle_bark;
	//level.scr_anim[ "generic" ][ "dog_scratch_door" ][ 3 ] = %german_shepherd_idle;
	//level.scr_anim[ "generic" ][ "dog_scratch_door" ][ 4 ] = %german_shepherd_idle;
	
}

#using_animtree( "animated_props" );
duffle_bag_anims()
{
	level.scr_animtree[ "cipher_bag" ] = #animtree;
	level.scr_model	  [ "cipher_bag" ] = "clockwork_duffle_bag_anim";
	//intro
	level.scr_anim[ "cipher_bag" ][ "clock_intro" ]			 = %clockwork_intro_jeep_ambush_enter_cipher_bag;
	//level.scr_anim[ "cipher_bag" ][ "clock_ambush_start" ] = %clockwork_intro_jeep_ambush_enter_cipher_bag;
	
	level.scr_anim[ "cipher_bag" ][ "ambush_approach" ] = %clockwork_pre_ambush_cypher_bag_enter;
	level.scr_anim[ "cipher_bag" ][ "ambush_approach_loop" ][0] = %clockwork_pre_ambush_cypher_bag_idle;
	
	level.scr_animtree[ "keegan_bag" ] = #animtree;
	level.scr_model	  [ "keegan_bag" ] = "clockwork_duffle_bag_anim";
	//intro
	level.scr_anim[ "keegan_bag" ][ "clock_intro" ] = %clockwork_intro_jeep_ambush_enter_keegan_bag;
	
	// NEW AMBUSH
	//level.scr_anim[ "keegan_bag" ][ "clock_ambush_start" ] = %clockwork_intro_jeep_ambush_enter_keegan_bag;  
	
	
	level.scr_animtree[ "baker_bag" ] = #animtree;
	level.scr_model	  [ "baker_bag" ] = "clockwork_duffle_bag_anim";


	
	
	level.scr_animtree[ "player_bag" ] = #animtree;
	level.scr_model	  [ "player_bag" ] = "clockwork_duffle_bag_anim";
	
	level.scr_animtree[ "player_bag_obj" ] = #animtree;
	level.scr_model	  [ "player_bag_obj" ] = "clockwork_duffle_bag_anim_obj";
	
	
//	level.scr_anim[ "player_bag" ][ "clock_ambush"	  ] = %clockwork_intro_jeep_ambush_player_bag;
	level.scr_anim[ "player_bag" ][ "defend_bagdrop" ] = %clockwork_defend_bag_drop_player_bag;
	
	level.scr_anim[ "player_ambush_bag1" ][ "player_grab_ambush_bags" ] = %clockwork_intro_jeep_ambush_grab_bag_bag1;
	level.scr_anim[ "player_ambush_bag2" ][ "player_grab_ambush_bags" ] = %clockwork_intro_jeep_ambush_grab_bag_bag2;
	
	level.scr_anim[ "player_ambush_bag1" ][ "player_grab_ambush_bags_obj" ] = %clockwork_intro_jeep_ambush_grab_bag_bag1;
	level.scr_anim[ "player_ambush_bag2" ][ "player_grab_ambush_bags_obj" ] = %clockwork_intro_jeep_ambush_grab_bag_bag2;
	
	level.scr_anim[ "player_ambush_bag1" ][ "ambush_jeep_enter_player" ] = %clockwork_intro_jeep_ambush_jeep_enter_bag1;
	level.scr_anim[ "player_ambush_bag2" ][ "ambush_jeep_enter_player" ] = %clockwork_intro_jeep_ambush_jeep_enter_bag2;
	
	
	level.scr_anim[ "player_bag" ][ "ambush_jeep_enter_player" ] = %clockwork_intro_jeep_ambush_jeep_enter_playerbag;
	
		//intro jeep exit
	level.scr_anim[ "player_bag" ][ "intro_jeep_exit_player" ] = %clockwork_garage_arrival_player_bag;
	
		// Defend anims sjp
		//Bags in position on the table:
	level.scr_anim[ "baker_bag" ] [ "defend_world_baker_bag" ] = %clockwork_defend_world_baker_bag;
	level.scr_anim[ "keegan_bag" ][ "defend_world_keegan_bag" ] = %clockwork_defend_world_keegan_bag;
	level.scr_anim[ "cipher_bag" ][ "defend_world_cypher_bag" ] = %clockwork_defend_world_cypher_bag;
	level.scr_anim[ "player_bag" ][ "defend_world_player_bag" ] = %clockwork_defend_world_player_bag;

}

#using_animtree( "animated_props" );
vault_door()
{
	level.scr_animtree[ "vault_door" ] = #animtree;
	level.scr_model	  [ "vault_door" ] = "clk_vault_door";
	
	level.scr_anim[ "vault_door" ][ "vault_closed" ][0]  = %clockwork_vault_drill_still_door;
//	level.scr_anim[ "vault_door" ][ "vault_burn"   ]   = %clockwork_vault_drill_burn_door;

/*	
	level.scr_anim[ "vault_door" ][ "vault_approach" ]	 = %clockwork_vault_drill_still_door;
	level.scr_anim[ "vault_door" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_still_door;
	level.scr_anim[ "vault_door" ][ "vault_betweener" ]	 = %clockwork_vault_drill_still_door;
	level.scr_anim[ "vault_door" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_still_door;
*/
	level.scr_anim[ "vault_door" ][ "vault_burn"   ]  	 = %clockwork_vault_drill_burn_door;
	level.scr_anim[ "vault_door" ][ "vault_finish" ]	 = %clockwork_vault_drill_blast_door;
	
	level.scr_anim[ "vault_door" ][ "tunnel_vault" ] = %clockwork_power_out_door;
	


	addNotetrack_flag( "vault_door", "fail_safe", "power_out_failsafe", "tunnel_vault" );
//	addNotetrack_flag( "vault_door", "glow_start", "glow_start", "vault_burn" );
//	addNotetrack_flag( "vault_door", "thermite_start", "thermite_start", "vault_burn" );
//	addNotetrack_flag( "vault_door", "thermite_stop", "thermite_stop", "vault_burn" );
//	addNotetrack_flag( "vault_door", "explosion_start", "explosion_start", "vault_burn" );
 
	 
	level.scr_anim[ "vault_door" ][ "defend_open" ] = %clockwork_defend_open_door;
	level.scr_anim[ "vault_door" ][ "defend_close" ] = %clockwork_defend_close_door;
	
	
	///////////////////////////////////////////////////////////////////////////////////////////
	/// vault charge.
	level.scr_animtree[ "vault_charge1" ] = #animtree;
	level.scr_model	  [ "vault_charge1" ] = "clk_door_charge";

	level.scr_anim[ "vault_charge1" ][ "vault_approach" ]	= %clockwork_vault_drill_intro_charge1;
	level.scr_anim[ "vault_charge1" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_loop1_charge1;
	level.scr_anim[ "vault_charge1" ][ "vault_betweener" ]	= %clockwork_vault_drill_approach2_charge1;
//	level.scr_anim[ "vault_charge1" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_loop2_charge1;
//	level.scr_anim[ "vault_charge1" ][ "vault_finish" ]		= undefined;
	addNotetrack_customFunction("vault_charge1", "unhide",  maps\clockwork_code::unhide_prop, "vault_approach");
	addNotetrack_customFunction("vault_charge1", "unhide",  maps\clockwork_interior::breach_charge_fx_unhide, "vault_approach");
	addNotetrack_customFunction("vault_charge1", "activate_charge",  maps\clockwork_interior::breach_charge_fx_set, "vault_betweener");

	level.scr_animtree[ "vault_charge2" ] = #animtree;
	level.scr_model	  [ "vault_charge2" ] = "clk_door_charge";
	
//	level.scr_anim[ "vault_charge2" ][ "vault_approach"	 ]	= undefined;
//	level.scr_anim[ "vault_charge2" ][ "vault_loop1" ]		= undefined;
	level.scr_anim[ "vault_charge2" ][ "vault_betweener" ]	= %clockwork_vault_drill_approach2_charge2;
	level.scr_anim[ "vault_charge2" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_loop2_charge2;
	level.scr_anim[ "vault_charge2" ][ "vault_finish" ]		= %clockwork_vault_drill_burn_charge2;
//	level.scr_anim[ "vault_charge2" ][ "vault_loop3" ][ 0 ] = %clockwork_vault_drill_loop3_charge2;
	addNotetrack_customFunction("vault_charge2", "unhide",  maps\clockwork_code::unhide_prop, "vault_betweener");
	addNotetrack_customFunction("vault_charge2", "unhide",  maps\clockwork_interior::breach_charge_fx_unhide, "vault_betweener");
	addNotetrack_customFunction("vault_charge2", "activate_charge",  maps\clockwork_interior::breach_charge_fx_set, "vault_finish");

	
	///////////////////////////////////////////////////////////////////////////////////////////
	// Thermite
	
	level.scr_animtree[ "vault_thermite1" ] = #animtree;
	level.scr_model	  [ "vault_thermite1" ] = "clk_thermite_strip";
	
	level.scr_anim[ "vault_thermite1" ][ "vault_approach" ]	  = %clockwork_vault_drill_intro_baker_thermite1;
	level.scr_anim[ "vault_thermite1" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_idle_baker_thermite1;
//	level.scr_anim[ "vault_thermite1" ][ "vault_betweener" ]  = undefined;
//	level.scr_anim[ "vault_thermite1" ][ "vault_loop2" ]	  = undefined;
//	level.scr_anim[ "vault_thermite1" ][ "vault_finish" ]	  = undefined;
	addNotetrack_customFunction("vault_thermite1", "unhide",  maps\clockwork_code::unhide_prop, "vault_approach");

	
	level.scr_animtree[ "vault_thermite2" ] = #animtree;
	level.scr_model	  [ "vault_thermite2" ] = "clk_thermite_strip";

	level.scr_anim[ "vault_thermite2" ][ "vault_approach" ]	  = %clockwork_vault_drill_intro_baker_thermite2;
	level.scr_anim[ "vault_thermite2" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_idle_baker_thermite2;
//	level.scr_anim[ "vault_thermite2" ][ "vault_betweener" ]  = undefined;
//	level.scr_anim[ "vault_thermite2" ][ "vault_loop2" ]	  = undefined;
//	level.scr_anim[ "vault_thermite2" ][ "vault_finish" ]	  = undefined;
	addNotetrack_customFunction("vault_thermite2", "unhide",  maps\clockwork_code::unhide_prop, "vault_approach");

	level.scr_animtree[ "vault_thermite3" ] = #animtree;
	level.scr_model	  [ "vault_thermite3" ] = "clk_thermite_strip";

//	level.scr_anim[ "vault_thermite3" ][ "vault_approach" ]	  = undefined;
//	level.scr_anim[ "vault_thermite3" ][ "vault_loop1" ]	  = undefined;
	level.scr_anim[ "vault_thermite3" ][ "vault_betweener" ]  = %clockwork_vault_drill_approach2_baker_thermite3;
	level.scr_anim[ "vault_thermite3" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_idle_baker_thermite3;
//	level.scr_anim[ "vault_thermite3" ][ "vault_finish" ]	  = undefined;
	addNotetrack_customFunction("vault_thermite3", "unhide",  maps\clockwork_code::unhide_prop, "vault_betweener");

	
	
	///////////////////////////////////////////////////////////////////////////////////////////
	// wire spool	
	level.scr_animtree[ "vault_spool_prop" ]			  = #animtree;
	level.scr_model	  [ "vault_spool_prop" ]			  = "generic_prop_raven";
	
//	level.scr_anim[ "vault_spool_prop" ][ "vault_approach" ]   = undefined;
//	level.scr_anim[ "vault_spool_prop" ][ "vault_loop1" ]	   = undefined;
	level.scr_anim[ "vault_spool_prop" ][ "vault_betweener" ]  = %clockwork_vault_drill_approach2_baker_wire;
	level.scr_anim[ "vault_spool_prop" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_idle_baker_wire;
//	level.scr_anim[ "vault_spool_prop" ][ "vault_finish" ]	   = undefined;
	addNotetrack_customFunction("vault_spool_prop", "unhide",  maps\clockwork_code::unhide_prop, "vault_betweener");

	//MODEL
	level.scr_animtree[ "vault_spool" ] = #animtree;
	level.scr_model	  [ "vault_spool" ] = "com_wire_spool_beige_1";
	
	
	///////////////////////////////////////////////////////////////////////////////////////////
	// drill
	level.scr_animtree[ "vault_drill_prop" ]			  = #animtree;
	level.scr_model	  [ "vault_drill_prop" ]			  = "generic_prop_raven";
	
	level.scr_anim[ "vault_drill_prop" ][ "vault_approach" ]   = %clockwork_vault_drill_intro_drill;
	addNotetrack_customFunction("vault_drill_prop", "unhide",  maps\clockwork_code::unhide_prop, "vault_approach");

	///////////////////////////////////////////////////////////////////////////////////////////
	// glowstick 1
	level.scr_animtree[ "vault_glowstick1_prop" ] = #animtree;
	level.scr_model	  [ "vault_glowstick1_prop" ] = "generic_prop_raven";

	level.scr_anim[ "vault_glowstick1_prop" ][ "vault_approach" ]	= %clockwork_vault_drill_intro_baker_glowstick;
	level.scr_anim[ "vault_glowstick1_prop" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_idle_baker_glowstick;
	level.scr_anim[ "vault_glowstick1_prop" ][ "vault_betweener" ]	= %clockwork_vault_drill_idle_baker_glowstick;
//	level.scr_anim[ "vault_glowstick1_prop" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_idle_baker_glowstick;
//	level.scr_anim[ "vault_glowstick1_prop" ][ "vault_finish" ]		= %clockwork_vault_drill_idle_baker_glowstick;
//	level.scr_anim[ "vault_glowstick1_prop" ][ "vault_loop3" ][ 0 ] = %clockwork_vault_drill_idle_baker_glowstick;
	level.scr_anim[ "vault_glowstick1_prop" ][ "vault_exit" ]		= %clockwork_vault_drill_burn_baker_glowstick;
	
	addNotetrack_customFunction("vault_glowstick1_prop", "unhide",  maps\clockwork_code::unhide_prop, "vault_approach");
	addNotetrack_customFunction("vault_glowstick1_prop", "bakerglow_start",  maps\clockwork_code::glowstick1_on, "vault_approach");
	addNotetrack_customFunction("vault_glowstick1_prop", "bakerglow_start",  maps\clockwork_audio::glowsticks, "vault_approach");

	//MODEL
	level.scr_animtree[ "vault_glowstick1" ] = #animtree;
	level.scr_model	  [ "vault_glowstick1" ] = "weapon_light_stick_tactical_green";
	



	///////////////////////////////////////////////////////////////////////////////////////////
	// glowstick 2
	level.scr_animtree[ "vault_glowstick2_prop" ] = #animtree;
	level.scr_model	  [ "vault_glowstick2_prop" ] = "generic_prop_raven";

	level.scr_anim[ "vault_glowstick2_prop" ][ "vault_approach" ]	= %clockwork_vault_drill_intro_keegan_glowstick;
	level.scr_anim[ "vault_glowstick2_prop" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_idle_keegan_glowstick;
	level.scr_anim[ "vault_glowstick2_prop" ][ "vault_betweener" ]	= %clockwork_vault_drill_idle_keegan_glowstick;
//	level.scr_anim[ "vault_glowstick2_prop" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_idle_keegan_glowstick;
//	level.scr_anim[ "vault_glowstick2_prop" ][ "vault_finish" ]		= %clockwork_vault_drill_idle_keegan_glowstick;
//	level.scr_anim[ "vault_glowstick2_prop" ][ "vault_loop3" ][ 0 ] = %clockwork_vault_drill_idle_keegan_glowstick;
	level.scr_anim[ "vault_glowstick2_prop" ][ "vault_exit" ]		= %clockwork_vault_drill_burn_keegan_glowstick;

	addNotetrack_customFunction("vault_glowstick2_prop", "unhide",  maps\clockwork_code::unhide_prop, "vault_approach");
	addNotetrack_customFunction("vault_glowstick2_prop", "keeganglow_start",  maps\clockwork_code::glowstick2_on, "vault_approach");
	
	//MODEL
	level.scr_animtree[ "vault_glowstick2" ] = #animtree;
	level.scr_model	  [ "vault_glowstick2" ] = "weapon_light_stick_tactical_green";
	
	
	// ==== new vault props that use generic prop to animate ====

	// tablet
	level.scr_animtree[ "vault_tablet_prop" ]					= #animtree;
	level.scr_model	  [ "vault_tablet_prop" ]					= "generic_prop_raven";
	level.scr_anim[ "vault_tablet_prop" ][ "vault_approach" ]	= %clockwork_vault_drill_intro_tablet;
	level.scr_anim[ "vault_tablet_prop" ][ "vault_loop1" ][ 0 ] = %clockwork_vault_drill_loop1_tablet;
	level.scr_anim[ "vault_tablet_prop" ][ "vault_betweener" ]	= %clockwork_vault_drill_approach2_tablet;
	level.scr_anim[ "vault_tablet_prop" ][ "vault_loop2" ][ 0 ] = %clockwork_vault_drill_loop2_tablet;
	level.scr_anim[ "vault_tablet_prop" ][ "vault_finish" ]		= %clockwork_vault_drill_burn_tablet;
	addNotetrack_customFunction("vault_tablet_prop", "unhide",  maps\clockwork_code::unhide_prop, "vault_approach");

	//MODEL
	level.scr_animtree[ "vault_tablet" ] = #animtree;
	level.scr_model	  [ "vault_tablet" ] = "clk_vault_tablet";
//	level.scr_model	  [ "vault_tablet" ] = "clk_vault_tablet_pip";
	
	level.scr_animtree[ "vault_light_r" ] = #animtree;
	level.scr_anim	  [ "vault_light_r" ][ "light_explode" ]  = %clockwork_vault_drill_burn_r_light;

	level.scr_animtree[ "vault_light_l" ] = #animtree;
	level.scr_anim	  [ "vault_light_l" ][ "light_explode" ]  = %clockwork_vault_drill_burn_l_light;


}

#using_animtree( "animated_props" );
cqb_anims()
{
	level.scr_animtree[ "cqb_int_door" ]			  = #animtree;
	level.scr_model	  [ "cqb_int_door" ]			  = "generic_prop_raven";
	level.scr_anim	  [ "cqb_int_door" ][ "bust_door" ]  		= %clockwork_shoulder_charge_door;
	level.scr_anim	  [ "cqb_int_door" ][ "shut_door_loop" ][0] = %clockwork_shoulder_charge_close_door_loop;
	level.scr_anim	  [ "cqb_int_door" ][ "shut_door_end" ]  	= %clockwork_shoulder_charge_close_door_exit ;
	
	level.scr_animtree[ "cqb_ext_door" ] = #animtree;
	level.scr_model	  [ "cqb_ext_door" ] = "clk_door_exterior_animated";
	level.scr_anim	  [ "cqb_ext_door" ][ "slow_open_door" ]  = %clockwork_stealth_open_door;
	
	// Drill for chaos
	level.scr_animtree[ "chaos_drill_j" ]			  	= #animtree;
	level.scr_model	  [ "chaos_drill_j" ]			   	= "generic_prop_raven";
	level.scr_anim[ "chaos_drill_j" ][ "drill" ][ 0 ] 	= %clockwork_chaos_drill_find_loop_drill;
	
	level.scr_animtree[ "chaos_drill" ] 				= #animtree;
	level.scr_model	  [ "chaos_drill" ] 				= "weapon_drill_press";
	
	// Extinguisher for chaos
	level.scr_animtree[ "chaos_ext_j" ]			  		= #animtree;
	level.scr_model	  [ "chaos_ext_j" ]			   		= "generic_prop_raven";
	level.scr_anim[ "chaos_ext_j" ][ "ext" ][ 0 ]		= %clockwork_chaos_extinguisher_loop_extinguisher;
	
	level.scr_animtree[ "chaos_ext" ] 					= #animtree;
	level.scr_model	  [ "chaos_ext" ] 					= "clk_fire_extinguisher_lrg_anim";
	
	/*
	// Leash for chaos
	level.scr_animtree[ "chaos_leash_j" ]			  		= #animtree;
	level.scr_model	  [ "chaos_leash_j" ]			   		= "generic_prop_raven";	
	level.scr_anim[ "chaos_leash_j" ][ "cha_leash_idle" ][ 0 ] 	= %clockwork_chaos_idle_leash;
	level.scr_anim[ "chaos_leash_j" ][ "cha_leash_alert" ]		 	= %clockwork_chaos_alert_leash;
	level.scr_anim[ "chaos_leash_j" ][ "cha_leash_react" ][ 0 ] 	= %clockwork_chaos_react_leash;
	level.scr_anim[ "chaos_leash_j" ][ "cha_leash_turn" ]	 		= %clockwork_chaos_turn_leash;
	level.scr_anim[ "chaos_leash_j" ][ "cha_leash_idle2" ][ 0 ] 	= %clockwork_chaos_idle2_leash;
	*/
	level.scr_animtree[ "chaos_leash" ] 					= #animtree;
	level.scr_model	  [ "chaos_leash" ] 					= "clk_dog_leash";
	level.scr_anim[ "chaos_leash" ][ "cha_leash_idle" ][ 0 ] 		= %clockwork_chaos_idle_leash;
	level.scr_anim[ "chaos_leash" ][ "cha_leash_alert" ]		 	= %clockwork_chaos_alert_leash;
	level.scr_anim[ "chaos_leash" ][ "cha_leash_react" ][ 0 ] 	= %clockwork_chaos_react_leash;
	level.scr_anim[ "chaos_leash" ][ "cha_leash_turn" ]	 		= %clockwork_chaos_turn_leash;
	level.scr_anim[ "chaos_leash" ][ "cha_leash_idle2" ][ 0 ] 	= %clockwork_chaos_idle2_leash;

}

#using_animtree( "animated_props" );
nvg_intro()
{
	//JOINT
	level.scr_animtree[ "nvg_bin_joint" ]			 = #animtree;
	level.scr_model	  [ "nvg_bin_joint" ]			 = "generic_prop_raven";
	level.scr_anim[ "nvg_bin_joint" ][ "bin_joint" ] = %clockwork_power_out_bin;
	
	//MODEL
	level.scr_animtree[ "nvg_bin" ] = #animtree;
	level.scr_model	  [ "nvg_bin" ] = "machinery_xray_scanner_bin_single";
	
	//MODEL
	level.scr_animtree[ "fiveseven" ] = #animtree;
	level.scr_model	  [ "fiveseven" ] = "weapon_fn_fiveseven";

	//MODEL
	level.scr_animtree[ "search_wand" ] = #animtree;
	level.scr_model	  [ "search_wand" ] = "clk_metal_detector_wand";
	
	
	//plant bug joint
	level.scr_animtree[ "bug_device_joint" ]			= #animtree;
	level.scr_model	  [ "bug_device_joint" ]			= "generic_prop_raven";
	level.scr_anim[ "bug_device_joint" ][ "bug_joint" ] = %clockwork_surveillance_room_bug;
	
	//glow stick joint
	level.scr_animtree[ "bug_glowstick_joint" ]			= #animtree;
	level.scr_model	  [ "bug_glowstick_joint" ]			= "generic_prop_raven";
	level.scr_anim[ "bug_glowstick_joint" ][ "glowstick_joint" ] = %clockwork_surveillance_room_glowstick;
	
	addNotetrack_customFunction("bug_glowstick_joint", "glowstick_break",  maps\clockwork_code::glowstick_hacking_on, "glowstick_joint");
	
	level.scr_animtree[ "bug_glowstick" ] = #animtree;
	level.scr_model	  [ "bug_glowstick" ] = "weapon_light_stick_tactical_green";
	
	
	//plant bug model
	level.scr_animtree[ "bug_device" ] = #animtree;
	level.scr_model	  [ "bug_device" ] = "clk_bug_device";

	//server model
	level.scr_animtree[ "server" ] = #animtree;
	level.scr_model	  [ "server" ] = "clk_server_rack_modular_verticalslide_anim";
 	level.scr_anim[ "server" ][ "eyes_and_ears" ]		= %clockwork_surveillance_room_server;
	
	level.scr_anim[ "vault_tablet_prop" ][ "vault_finish" ]		= %clockwork_vault_drill_burn_tablet;
	
	
	//couple defend anims.
	// guns on the table that guys grab (attached to J_prop_2)
	level.scr_anim[ "generic" ][ "defend_reload_bones_baker" ] = %clockwork_defend_reload_bones_baker;
	level.scr_anim[ "generic" ][ "defend_reload_bones_keegan" ] = %clockwork_defend_reload_bones_keegan;

}

#using_animtree( "animated_props" );
snowmobile_bodies()
{


	
	
	
	level.scr_animtree[ "sm_body1" ]			 = #animtree;
	level.scr_model	  [ "sm_body1" ]			 = "clk_russian_disguise_deadbodies";
	level.scr_anim    [ "sm_body1" ][ "clock_prepare_bodies" ] = %clockwork_level_intro_enemy1;
	
	level.scr_animtree[ "sm_body2" ]			 = #animtree;
	level.scr_model	  [ "sm_body2" ]			 = "clk_russian_disguise_deadbodies";
	level.scr_anim    [ "sm_body2" ][ "clock_prepare_bodies" ] = %clockwork_level_intro_enemy2;
	
	level.scr_animtree[ "sm_body3" ]			 = #animtree;
	level.scr_model	  [ "sm_body3" ]			 = "clk_russian_disguise_deadbodies";
	level.scr_anim    [ "sm_body3" ][ "clock_prepare_bodies" ] = %clockwork_level_intro_enemy3;
}
