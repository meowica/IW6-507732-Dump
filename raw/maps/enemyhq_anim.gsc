#include maps\_utility;
#include maps\_anim;
#include common_scripts\utility;

main()
{
	generic_human_anims();
	dog_anims();
	player_anims();
	vehicle_anims();
	prop_anims();
	truck_anims();

	prop_anims();
}


#using_animtree( "generic_human" );
generic_human_anims()
{
// intro anims.
	level.scr_anim[ "keegan" ][ "training_humvee_repair"	 ][ 0 ] = %training_humvee_repair;

// pass the ammo to the player
	level.scr_anim[ "baker" ][ "intro_player"] = %ehq_intro_merric;
	
//vip interrogation	
	level.scr_anim[ "bishop"  ][ "bishop_glimpse" ] = %ehq_capture_bishop;
	level.scr_anim[ "bish_e1" ][ "bishop_glimpse" ] = %ehq_capture_dude1;
	level.scr_anim[ "bish_e2" ][ "bishop_glimpse" ] = %ehq_capture_dude2;
	level.scr_anim[ "bish_e3" ][ "bishop_glimpse" ] = %ehq_capture_dude3;
 

	
	//enter the dang truck
	level.scr_anim[ "keegan" ][ "enter_truck" ] = %ehq_truck_enter_keegan;
	level.scr_anim[ "keegan" ][ "enter_truck_loop" ][ 0 ] = %ehq_truck_enter_loop_keegan;
	level.scr_anim[ "hesh" ][ "enter_truck_loop" ][ 0 ] = %bm21_guy1_idle;
	level.scr_anim[ "baker" ][ "enter_truck_loop" ][ 0 ] = %bm21_guy2_idle;


	
// vip sniping enemies
	level.scr_anim[ "vip_e1" ][ "vip_enemy" ] = %prague_bully_b_watch;
	level.scr_anim[ "vip_e2" ][ "vip_enemy" ] = %africa_burning_men_watcher_idle;
	level.scr_anim[ "vip_e3" ][ "vip_enemy" ] = %clockwork_checkpoint_lookout_enemy;
	level.scr_anim[ "vip_e4" ][ "vip_enemy" ] = %london_sandman_sas_talk_sandman;
	level.scr_anim[ "vip_e5" ][ "vip_enemy" ] = %london_sandman_sas_talk_friendly;
	level.scr_anim[ "vip_e6" ][ "vip_enemy" ] = %ny_manhattan_radio_sandman_talk;

// vip breach enemy reacts
	level.scr_anim[ "vip_e1" ][ "vip_breach_react" ] = %london_surprise_turnaround_left;
	level.scr_anim[ "vip_e2" ][ "vip_breach_react" ] = %london_surprise_turnaround_right;
	level.scr_anim[ "vip_e3" ][ "vip_breach_react" ] = %london_surprise_turnaround_left;
	level.scr_anim[ "vip_e4" ][ "vip_breach_react" ] = %breach_react_blowback_v1;
	level.scr_anim[ "vip_e5" ][ "vip_breach_react" ] = %blackice_explosionreact2;
	level.scr_anim[ "vip_e6" ][ "vip_breach_react" ] = %london_surprise_turnaround_right;


// vip breach allies
	level.scr_anim[ "ally1" ][ "vip_breach" ] = %intro_courtyard_breach_guy1;
	level.scr_anim[ "ally2" ][ "vip_breach" ] = %intro_courtyard_breach_guy5;
//	level.scr_anim[ "ally3" ][ "vip_breach" ] = %intro_courtyard_breach_guy2;
	level.scr_anim[ "ally3" ][ "vip_breach" ] = %intro_courtyard_breach_guy3;
		
//  post vip breach
	level.scr_anim[ "generic" ][ "search_walk" ][0] = %active_patrolwalk_v5;
	
	level.scr_anim[ "goodguy" ][ "vip_interrogate" ] = %ehq_vip_int_keegan;
	level.scr_anim[ "badguy" ][ "vip_interrogate" ] = %ehq_vip_int_guard;
	
	level.scr_anim[ "generic" ][ "combat_jog" ][0] = %combat_jog;

// dog ambush
	level.scr_anim[ "generic" ][ "dog_flee" ] = %run_react_stumble_non_loop;
	level.scr_anim[ "generic" ][ "basement_dog_ambush" ] = %iw6_dog_kill_back_medium_guy_1;
	
// tear gas
	level.scr_anim[ "generic" ][ "open_battingcage" ] = %doorpeek_open;
	level.scr_anim[ "generic" ][ "open_battingcage2" ] = %breach_react_blowback_v3;
	
	level.scr_anim[ "generic" ][ "enter_battingcage" ] = %corner_standL_trans_out_8;
	level.scr_anim[ "generic" ][ "teargas_react_in_place_1" ] = %teargas_react_in_place_1;
	level.scr_anim[ "generic" ][ "prague_teargas_run_1_twitch" ] = %prague_teargas_run_1_twitch;
	level.scr_anim[ "generic" ][ "prague_teargas_run_2_twitch" ] = %prague_teargas_run_2_twitch;
	level.scr_anim[ "generic" ][ "teargas_window_3" ] = %teargas_window_3;
	level.scr_anim[ "generic" ][ "corner_gas" ] = %corner_standL_grenade_B;

// collapsed room
	level.scr_anim[ "keegan" ][ "light_glowstick" ]				   = %clockwork_surveillance_room_baker;


// clubhouse breach	
// left group
	level.scr_anim[ "ally1" ][ "ch_breach" ] = %intro_courtyard_breach_guy1;
	level.scr_anim[ "ally3" ][ "ch_breach" ] = %intro_courtyard_breach_guy3;
// player group	
//	level.scr_anim[ "ally3" ][ "ch_breach" ] = %intro_courtyard_breach_guy6;
	level.scr_anim[ "ally2" ][ "ch_breach" ] = %intro_courtyard_breach_guy1;

	level.scr_anim[ "generic" ][ "teargas_react_1" ] = %teargas_react_1;
	level.scr_anim[ "generic" ][ "teargas_react_2" ] = %teargas_react_2;
	level.scr_anim[ "generic" ][ "teargas_react_3" ] = %teargas_react_3;
	level.scr_anim[ "generic" ][ "teargas_react_4" ] = %teargas_react_4;
	
	level.scr_anim[ "generic" ][ "dog_breach" ] = %kingfish_breach_ambush_soldier_start;

	
	// find bishop
	// wounded carry
	level.scr_anim[ "bishop" ][ "hvt_loop" ][0]				 			= %wounded_carry_closet_idle_wounded;
	
	level.scr_anim[ "merrick" ][ "hvt_pickup" ]			 				= %wounded_carry_pickup_closet_carrier_straight;
	level.scr_anim[ "bishop" ][ "hvt_pickup" ]				 			= %wounded_carry_pickup_closet_wounded_straight;

	level.scr_anim[ "generic" ][ "wounded_carry_carrier" ]				= %wounded_carry_fastwalk_carrier;
	level.scr_anim[ "generic" ][ "wounded_carry_wounded" ][0]			= %wounded_carry_fastwalk_wounded_relative;
	level.scr_anim[ "generic" ][ "wounded_carry_idle" ][ 0 ]		 	= %intro_fireman_carry_idle_carrier;
	level.scr_anim[ "carried" ][ "wounded_carry_idle" ][ 0 ]			= %intro_fireman_carry_idle_carried;
	
	level.scr_anim[ "bishop" ][ "hvt_fight" ] = %kingfish_price_kills_price;
	level.scr_anim[ "generic" ][ "hvt_fight" ] = %kingfish_price_kills_enemy;

	
	level.scr_anim[ "hesh" ][ "bust_thru_prep" ] = %ehq_wall_crash_prep_driver;
	level.scr_anim[ "hesh" ][ "bust_thru" ] = %ehq_wall_crash_driver; 
	level.scr_anim[ "generic" ][ "bust_thru" ] = %ehq_wall_crash_enemy1; 
	level.scr_anim[ "keegan" ][ "bust_thru" ] = %ehq_wall_crash_rearpass; 
	
	
	//Human anims that pair with the dog anims below.
	level.scr_anim[ "generic" ][ "dog_last_stand_kill" ][1] 	= %AI_attacked_german_shepherd_last_stand;
	level.scr_anim[ "generic" ][ "dog_attack_fast" ][1] 		= %AI_attacked_german_shepherd_attack_fast;
	// Jump over 32 kill
	level.scr_anim[ "generic" ][ "32Kill" ]							= %AI_attacked_german_shepherd_jump_32_kill;
	
	// Jump over 40 kill
	level.scr_anim[ "generic" ][ "dog_jump_over_40" ][1]         = %AI_attacked_german_shepherd_jump_32_kill;
	
	// dog hijack
	level.scr_anim[ "generic" ][ "dog_hijack" ]       			  = %kingfish_driver_pulled_from_truck_start;
	
	level.scr_anim[ "keegan" ][ "truck_smash" ] = %ehq_truck_drivein_hit_driver; 
	



}

#using_animtree( "dog" );
dog_anims()
{

	level.scr_anim[ "generic" ][ "dog_sniff_walk_fast" ] = %german_shepherd_sniff_loop;

	level.scr_anim[ "dog" ][ "growl" ][0] = %iw6_dog_attackidle_bark;
	level.scr_anim[ "dog" ][ "growl" ][ 1 ] = %iw6_dog_attackidle;
	level.scr_anim[ "dog" ][ "german_shepherd_run_jump_window_40" ] = %iw6_dog_traverse_over_36;
	level.scr_anim[ "dog" ][ "walk" ] = %iw6_dog_walk;
	level.scr_anim[ "dog" ][ "german_shepherd_rotate_ccw" ] = %iw6_dog_attackidle_turn_4;
	level.scr_anim[ "dog" ][ "german_shepherd_rotate_cw" ] = %iw6_dog_attackidle_turn_6;
	level.scr_anim[ "dog" ][ "sniff" ] = %iw6_dog_sniff_walk;

	level.scr_anim[ "dog" ][ "dog_breach" ] = %kingfish_breach_ambush_dog_start;
	level.scr_anim[ "dog" ][ "bust_thru_prep" ] = %ehq_wall_crash_prep_dog; 
	level.scr_anim[ "dog" ][ "bust_thru" ] = %ehq_wall_crash_dog; 
	level.scr_anim[ "dog" ][ "veh_idle" ][0] = %ehq_truck_ride_idle_dog;
	level.scr_anim[ "dog" ][ "enter_truck" ] = %ehq_truck_enter_dog; 

	//dog anims for general gameplay / combat.
	level.scr_anim[ "generic" ][ "dog_jump_over_40" ][0]		= %german_shepherd_jump_32_kill;		
	level.scr_anim[ "generic" ][ "dog_last_stand_kill" ][0] 	= %german_shepherd_attack_last_stand;
	level.scr_anim[ "generic" ][ "dog_attack_fast" ][0] 		= %german_shepherd_attack_fast;
	level.scr_anim[ "dog" ][ "32Kill" ]							= %german_shepherd_jump_32_kill;
	level.scr_anim[ "generic" ][ "dog_walk" ]					= %german_shepherd_walk_slow;

	level.scr_anim[ "dog" ][ "vip_interrogate" ] = %ehq_vip_int_dog;
	
	level.scr_anim[ "dog" ][ "found_door" ] = %german_shepherd_scratch_door;

	// dog ambush
	level.scr_anim[ "dog" ][ "basement_dog_ambush" ] = %iw6_dog_kill_back_medium_1;
	
	// dog hijack
	level.scr_anim[ "dog" ][ "dog_hijack" ]						=%kingfish_dog_pull_from_truck_start;
	
	level.scr_anim[ "dog" ][ "truck_smash" ]						=%ehq_truck_drivein_hit_dog;
	
}

#using_animtree( "player" );
player_anims()
{
	//intro sticky gun setup.
	level.scr_anim[ "player_rig" ][ "intro_player"] = %ehq_intro_player;

	
	//player bust thru
	level.scr_animtree[ "player_rig" ]							= #animtree;
	level.scr_model	  [ "player_rig" ]							= "viewhands_player_yuri";	
	level.scr_anim[ "player_rig" ][ "bust_thru_prep" ] = %ehq_wall_crash_prep_player;
	level.scr_anim[ "player_rig" ][ "bust_thru" ] = %ehq_wall_crash_player;
	level.scr_anim[ "player_rig" ][ "bust_thru_exit" ] = %ehq_wall_crash_exit_player;
	level.scr_anim[ "player_rig" ][ "player_smash_windshield" ] = %ehq_windshield_smash_player;
	level.scr_anim[ "player_rig" ][ "player_enter_truck" ] = %ehq_truck_enter_player;
	level.scr_anim[ "player_rig" ][ "get_in_chopper" ]       		  	= %ehq_helicopter_enter_player;
	level.scr_anim[ "player_rig" ][ "truck_smash" ]       		  	= %ehq_truck_drivein_hit_player;
	
	
	addNotetrack_flag("player_rig","player_gunup","FLAG_bust_thru_player_control","bust_thru");
	

	level.scr_anim[ "player_rig" ][ "ch_breach" ] = %ehq_clubhouse_breach_player;
	addNotetrack_customFunction( "player_rig", "gun_up", maps\enemyhq_basement::breach_gun_up, "ch_breach" );
				    
	level.scr_animtree[ "player_legs" ]							= #animtree;
	level.scr_model	  [ "player_legs" ]							= "viewlegs_generic";	
	level.scr_anim[ "player_legs" ][ "ch_breach" ] = %ehq_clubhouse_breach_player_legs;
//	level.scr_anim[ "player_legs" ][ "ch_breach" ] = %kingfish_kickdowndoor_player_legs;
	
}


#using_animtree( "vehicles" );
vehicle_anims()
{
	

}



#using_animtree( "vehicles" );
truck_anims()
{
	level.scr_anim[ "truck" ][ "bust_thru" ] = %ehq_wall_crash_truck; 
	level.scr_anim[ "truck" ][ "bust_thru_exit" ] = %ehq_wall_crash_exit_truck; 
	level.scr_anim[ "truck" ][ "player_smash_windshield" ] = %ehq_windshield_smash_truck; 
	
	level.scr_anim[ "truck" ][ "player_enter_truck" ] = %ehq_truck_enter_truck;
	level.scr_anim[ "truck" ][ "truck_loop" ] = %ehq_truck_enter_loop_truck;
	
	
	
}

#using_animtree( "animated_props" );
prop_anims()
{
	level.scr_animtree[ "intro_jeep_ram" ]			  = #animtree;
  	level.scr_anim[ "intro_jeep_ram" ][ "jeep_ram" ] = %ehq_truck_ram_jeep;
	
  	level.scr_animtree[ "clubhouse_doors" ]			  = #animtree;
	level.scr_model	  [ "clubhouse_doors" ]			  = "generic_prop_raven";
	level.scr_anim	  [ "clubhouse_doors" ][ "ch_breach" ]  		= %ehq_clubhouse_breach_doors ;
	
	level.scr_animtree["hamburg_security_gate_crash"] = #animtree;
//	level.scr_model	  [ "hamburg_security_gate_crash" ]			  = "generic_prop_raven";
	level.scr_anim[ "hamburg_security_gate_crash" ][ "security_gate_crash" ] = %hamburg_tank_entrance_garage;
	
	level.scr_animtree[ "bish_ch" ]						 = #animtree;
	level.scr_model	  [ "bish_ch" ]						 = "generic_prop_raven";
	level.scr_anim	[ "bish_ch" ][ "bishop_glimpse" ] = %ehq_capture_chair;
	
	
	level.scr_animtree[ "mk32" ]			   = #animtree;
	level.scr_model	  [ "mk32" ]			   = "generic_prop_raven";
	level.scr_anim[ "mk32" ][ "intro_player" ] = %ehq_intro_player_gun;


	//glow stick joint
	level.scr_animtree[ "glowstick_prop" ]			= #animtree;
	level.scr_model	  [ "glowstick_prop" ]			= "generic_prop_raven";
	level.scr_anim[ "glowstick_prop" ][ "light_glowstick" ] = %clockwork_surveillance_room_glowstick;
	
	addNotetrack_customFunction("glowstick_prop", "glowstick_break", ::glowstick_on, "light_glowstick");
	
	level.scr_animtree[ "glowstick" ] = #animtree;
	level.scr_model	  [ "glowstick" ] = "weapon_light_stick_tactical_green";
	
}
   
glowstick_on(actor)
{
	PlayFXOnTag( level._effect[ "glowstick" ], actor, "J_prop_1" );
	flag_wait("ch_stop_searching");
	glowstick_off(actor);
}

glowstick_off(actor)
{
	StopFXOnTag(level._effect[ "glowstick" ], actor, "J_prop_1" );
}