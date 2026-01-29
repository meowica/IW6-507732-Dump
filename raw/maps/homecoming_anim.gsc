#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;

main()
{
	generic_human();
	dog();
	vehicles();
	script_model();
	flare_rig_anims();
}

#using_animtree( "generic_human" );
generic_human()
{
	// RUN ANIMS
	level.scr_anim[ "generic" ][ "combat_jog" ]		= %combat_jog;
	level.scr_anim[ "generic" ][ "scared_run" ] 	= %scared_run;
	
	/*-----------------------
	INTRO STREET
	-------------------------*/
	level.scr_anim[ "hesh" ] [ "intro_hesh_wave" ] 			= %payback_escape_forward_wave_right_price;
	
	//welder
	level.scr_anim[ "generic" ][ "cliffhanger_welder_wing" ][ 0 ]	= %cliffhanger_welder_wing;
	
	//sleeping
	//level.scr_anim[ "generic" ][ "cargoship_sleeping_guy_idle_2" ]			= %cargoship_sleeping_guy_idle_2;
	//level.scr_anim[ "generic" ][ "cargoship_sleeping_guy_idle_1" ]			= %cargoship_sleeping_guy_idle_1;
	level.scr_anim[ "generic" ][ "afgan_caves_sleeping_guard_idle" ][0]			= %afgan_caves_sleeping_guard_idle;
	level.scr_anim[ "generic" ][ "training_humvee_wounded_idle" ][0]			= %training_humvee_wounded_idle;
	
	//medic
	level.scr_anim[ "generic" ][ "DC_Burning_stop_bleeding_medic" ]				= %DC_Burning_stop_bleeding_medic;
	
	level.scr_anim[ "generic" ][ "DC_Burning_CPR_medic_endidle" ][0]			= %DC_Burning_CPR_medic_endidle;
	level.scr_anim[ "generic" ][ "DC_Burning_CPR_medic" ]			 			= %DC_Burning_CPR_medic;
	level.scr_anim[ "generic" ][ "DC_Burning_CPR_wounded" ]			 			= %DC_Burning_CPR_wounded;
	
	// wounded
	level.scr_anim[ "generic" ][ "prague_woundidle_wounded" ][0]			 	= %prague_woundidle_wounded;
	
	// wounded carry
	level.scr_anim[ "generic" ][ "wounded_carry_carrier" ]			 			= %wounded_carry_fastwalk_carrier;
	level.scr_anim[ "generic" ][ "wounded_carry_wounded" ][0]			 		= %wounded_carry_fastwalk_wounded_relative;
	level.scr_anim[ "generic" ][ "wounded_carry_putdown_carrier" ]	 			= %DC_Burning_wounded_carry_putdown_carrier;
	level.scr_anim[ "generic" ][ "wounded_carry_putdown_wounded" ]	 			= %DC_Burning_wounded_carry_putdown_wounded;
	level.scr_anim[ "generic" ][ "wounded_carry_idle_carrier" ][0]	 			= %DC_Burning_wounded_carry_idle_carrier;
	level.scr_anim[ "generic" ][ "wounded_carry_idle_wounded" ][0]		 		= %DC_Burning_wounded_carry_idle_wounded;

	// Help Sitting Wounded
	level.scr_anim[ "generic" ][ "hurt_sitting_wounded_loop" ][ 0 ]			= %clockwork_chaos_enemy_help_loop1_guard;
	level.scr_anim[ "generic" ][ "help_hurt_sitting_wounded" ]				= %clockwork_chaos_enemy_help_guard;
	level.scr_anim[ "generic" ][ "help_hurt_sitting_helper" ]				= %clockwork_chaos_enemy_help_guard2;
	level.scr_anim[ "generic" ][ "help_hurt_sitting_wounded_loop" ][ 0 ]	= %clockwork_chaos_enemy_help_loop2_guard;
	level.scr_anim[ "generic" ][ "help_hurt_sitting_helper_loop" ][ 0 ]		= %clockwork_chaos_enemy_help_loop2_guard2;
	
	// laptop
	level.scr_anim[ "generic" ][ "laptop_stand_idle" ][0]			= %laptop_stand_idle;
	
	// wire pull
	level.scr_anim[ "wire_puller" ][ "wire_pull" ]					= %armada_wire_setup_guy;
	
	// waver
	level.scr_anim[ "generic" ][ "wire_wave" ][ 0 ]					= %clockwork_chaos_wave_guard;
	level.scr_anim[ "generic" ] [ "jog_orders"		  ] 			= %patrol_jog_orders_once;
	level.scr_anim[ "generic" ] [ "intro_osprey_wave" ] 			= %payback_escape_forward_wave_left_soap;
	
	// slamraam
	level.scr_anim[ "slamraamAI_0" ][ "slamraam_tarp" ]				= %gulag_slamraam_tarp_pull_guy1_v1;
	//level.scr_anim[ "slamraamAI_1" ][ "slamraam_idle" ][0]			= %exposed_aim_5;
	level.scr_anim[ "slamraamAI_1" ][ "slamraam_tarp" ]				= %gulag_slamraam_tarp_pull_guy2_v1;
	level.scr_anim[ "slamraamAI_1" ][ "slamraam_idle" ][0]			= %gulag_slamraam_tarp_idle_guy2_v1;
	
	/*-----------------------
	HOUSE
	-------------------------*/
	
	// wall stumble
	level.scr_anim[ "generic" ][ "wall_stumble" ]					= %DC_Burning_bunker_stumble;
	level.scr_anim[ "generic" ][ "wall_stumble_idle" ][ 0 ] 		= %DC_Burning_bunker_sit_idle;
	
	level.scr_anim[ "hesh" ][ "bunker_stumble" ] 	= %cornered_building_fall_stumble_enemy_a;
	level.scr_anim[ "hesh" ][ "bunker_leave" ]		= %doorkick_2_stand;
	
	level.scr_anim[ "hesh" ][ "bunker_jumpdown_1" ] 	= %traverse_jumpdown_56;
	level.scr_anim[ "hesh" ][ "bunker_jumpdown_2" ]		= %traverse_jumpdown_96;
	
	/*-----------------------
	TOWER
	-------------------------*/
	level.scr_anim[ "hesh" ][ "tower_leave" ]		= %doorkick_2_stand;
	
	/*-----------------------
	ELIAS STREET
	-------------------------*/
	level.scr_anim[ "generic" ][ "ladder_climbon" ]		= %ladder_climbon;
	level.scr_anim[ "generic" ][ "ladder_slide" ]		= %scout_sniper_ladder_slide;
	
	level.scr_anim[ "generic" ][ "flee_run_shoot_behind" ]	= %flee_run_shoot_behind;
	level.scr_anim[ "generic" ][ "run_death_roll" ]			= %run_death_roll_02;
	
	level.scr_anim[ "dragger" ][ "elias_street_drag_wounded_drag" ]		= %airport_civ_dying_groupB_pull;
	level.scr_anim[ "dragger" ][ "elias_street_drag_wounded_death" ]	= %airport_civ_dying_groupB_pull_death;
	level.scr_anim[ "wounded" ][ "elias_street_drag_wounded_drag" ]		= %airport_civ_dying_groupB_wounded;
	level.scr_anim[ "wounded" ][ "elias_street_drag_wounded_death" ]	= %airport_civ_dying_groupB_wounded_death;
	
	/*-----------------------
	ELIAS HOUSE
	-------------------------*/
	level.scr_anim[ "hesh" ][ "elias_garage_lift" ] 	= %vegas_keegan_gate_lift;
	level.scr_anim[ "hesh" ][ "elias_garage_idle" ][0]	= %vegas_keegan_gate_idle;
	level.scr_anim[ "hesh" ][ "elias_garage_thru" ]		= %vegas_keegan_gate_thru;
	
	// MISC
	// Javelin
	level.scr_anim[ "generic" ][ "javelin_fire" ] 	= %javelin_fire_a;
	level.scr_anim[ "generic" ][ "javelin_idle" ] 	= %javelin_idle_a;
	
	level.scr_anim[ "generic" ][ "jump_down_56" ] 	= %jump_down_56;
	
	// DRONE ANIMS
	level.drone_anims[ "allies" ] [ "stand" ] [ "sprint"	] = %sprint_loop_distant_relative;
	level.drone_anims[ "allies" ] [ "stand" ] [ "run_n_gun" ] = %run_n_gun_F_relative;
	level.drone_anims[ "allies" ] [ "stand" ] [ "cqb"		] = %walk_CQB_F_relative;
	
	level.drone_anims[ "axis" ] [ "stand" ] [ "sprint"	  ] = %sprint_loop_distant_relative;
	level.drone_anims[ "axis" ] [ "stand" ] [ "run_n_gun" ] = %run_n_gun_F_relative;
	level.drone_anims[ "axis" ] [ "stand" ] [ "cqb"		  ] = %walk_CQB_F_relative;
	
	level.drone_anims[ "axis" ] [ "traverse" ] [ "traverse_jumpdown_56"	  ] = %traverse_jumpdown_56;
	level.drone_anims[ "axis" ] [ "traverse" ] [ "traverse_jumpdown_96" ] = %traverse_jumpdown_96;
	
	// GENERIC COMBAT
	level.scr_anim[ "generic" ][ "coverstand_hide_idle" ][0]			 	= %coverstand_hide_idle;
	level.scr_anim[ "generic" ][ "coverstand_hide_idle" ][1]			 	= %coverstand_look_quick;
	level.scr_anim[ "generic" ][ "coverstand_hide_idle" ][2]			 	= %coverstand_look_quick_v2;
	level.scr_anim[ "generic" ][ "coverstand_hide_idle" ][3]			 	= %coverstand_hide_idle_twitch04;
	level.scr_anim[ "generic" ][ "coverstand_hide_idle" ][4]			 	= %coverstand_hide_idle_twitch05;
	level.scr_anim[ "generic" ][ "coverstand_hide_2_aim" ]			 		= %coverstand_hide_2_aim;
	level.scr_anim[ "generic" ][ "coverstand_aim_2_hide" ]			 		= %coverstand_aim_2_hide;
	level.scr_anim[ "generic" ][ "coverstand_reload" ]			 			= %coverstand_reloadA;
	level.scr_anim[ "generic" ][ "coverstand_aim" ][0]			 			= %exposed_aim_5;
}

#using_animtree( "dog" );
dog()
{
	level.scr_anim[ "dog" ][ "casualidle" ][0] 		= %iw6_dog_casualidle;
	level.scr_anim[ "dog" ][ "down_70" ] 			= %iw6_dog_traverse_down_40;
	
	level.scr_anim[ "dog" ][ "bunker_stumble" ] 	= %german_shepherd_run_pain;
	level.scr_anim[ "dog" ][ "run" ] 				= %iw6_dog_run;	
	
}

#using_animtree( "vehicles" );
vehicles()
{
	level.scr_animtree[ "tank" ] 								 = #animtree;
	level.scr_model[ "tank" ] 									 = "vehicle_t90_tank_woodland";

	level.scr_anim[ "generic" ][ "lcac_tank_exit_01" ] 	= %lcac_tank_exit_01;
	level.scr_anim[ "generic" ][ "lcac_tank_exit_02" ] 	= %lcac_tank_exit_02;	
}

#using_animtree( "script_model" );
script_model()
{
	level.scr_animtree[ "slamraamTarp" ] 				= #animtree;
	level.scr_model[ "slamraamTarp" ] 					= "slamraam_tarp";
	level.scr_anim[ "slamraamTarp" ][ "slamraam_tarp" ] 	= %gulag_slamraam_tarp_simulation;
	
	level.scr_animtree[ "barbed_wire" ]			   = #animtree;
	level.scr_model	  [ "barbed_wire" ]			   = "mil_razorwire_long";
	level.scr_anim[ "barbed_wire" ][ "wire_pull" ] = %armada_wire_setup_wire;
}

flare_rig_anims()
{
	level.scr_animtree[ "flare_rig" ] 				= #animtree;
	level.scr_model[ "flare_rig" ] 					= "angel_flare_rig";

	level.scr_anim[ "flare_rig" ][ "flare" ][ 0 ]	= %ac130_angel_flares01;
	level.scr_anim[ "flare_rig" ][ "flare" ][ 1 ]	= %ac130_angel_flares02;
	level.scr_anim[ "flare_rig" ][ "flare" ][ 2 ]	= %ac130_angel_flares03;
}