#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;

#using_animtree( "generic_human" );
main()
{
	generic_human();
	player_anims();
	animated_prop_anims();
	minigun_anims();
	
	maps\_minigun_viewmodel::anim_minigun_hands();
}

#using_animtree( "generic_human" );
generic_human()
{
    level.scr_anim[ "crawl_death_1" ][ "crawl" ]		 		= %civilian_crawl_1;
	level.scr_anim[ "crawl_death_1" ] [ "death" ] [ 0 ]	  = %civilian_crawl_1_death_A;
	level.scr_anim[ "crawl_death_1" ] [ "death" ] [ 1 ]	  = %civilian_crawl_1_death_B;
	level.scr_anim[ "crawl_death_1" ] [ "blood_fx_rate" ] = 0.5;
	level.scr_anim[ "crawl_death_1" ] [ "blood_fx"		] = "blood_drip";
	
	level.scr_anim[ "crawl_death_2" ][ "crawl" ]		 = %civilian_crawl_2;
	level.scr_anim[ "crawl_death_2" ] [ "death" ] [ 0 ]	 = %civilian_crawl_2_death_A;
	level.scr_anim[ "crawl_death_2" ] [ "death" ] [ 1 ]	 = %civilian_crawl_2_death_B;
	level.scr_anim[ "crawl_death_2" ][ "blood_fx_rate" ] = 0.25;
	
	level.scr_anim[ "wounded_ai" ] [ "wounded_limp_jog" ] = %vegas_baker_limp_jog;
	level.scr_anim[ "wounded_ai" ] [ "wounded_limp_run" ] = %vegas_baker_run_pain;
	
	
	//TOWER
	//Control room
	level.scr_anim[ "merrick" ] [ "satfarm_control_tower_merrick" ] = %satfarm_control_tower_merrick;
	level.scr_anim[ "hesh"	  ] [ "satfarm_control_tower_hesh"	  ] = %satfarm_control_tower_keegan;
	
	//Javelin Nest
	level.scr_anim[ "generic" ] [ "spotter_on_radio_idle" ] [ 0 ] = %roadkill_cover_radio_soldier2;
	level.scr_anim[ "generic" ] [ "spotter_on_radio_react" ]	  = %crouch_cover_reaction_B;
	
	level.scr_anim[ "generic" ] [ "javelin_nest_animated_gunner" ] [ 0 ] = %roadkill_cover_active_soldier2;
	
	level.scr_anim[ "generic" ] [ "javelin_idle_a"			 ] [ 0 ] = %javelin_idle_a;
	level.scr_anim[ "generic" ] [ "javelin_fire_a"	]				 = %javelin_fire_a;
	level.scr_anim[ "generic" ] [ "javelin_react_a" ]				 = %javelin_react_a;
	level.scr_anim[ "generic" ] [ "javelin_death_4" ]				 = %javelin_death_4;
	
	level.scr_anim[ "merrick" ][ "stand_exposed_wave_target_spotted" ] = %stand_exposed_wave_target_spotted;
	
	//Warehouse
	level.scr_anim[ "generic" ] [ "clockwork_chaos_wave_guard"				 ]	 = %clockwork_chaos_wave_guard;
	level.scr_anim[ "generic" ] [ "clockwork_chaos_extinguisher_idle"	 ] [ 0 ] = %clockwork_chaos_extinguisher_loop_guard;
	level.scr_anim[ "generic" ] [ "clockwork_checkpoint_lean_rail_enemy" ] [ 0 ] = %clockwork_checkpoint_lean_rail_enemy;
	level.scr_anim[ "generic" ] [ "coup_talking_patrol_guy1" ]					 = %coup_talking_patrol_guy1;
	level.scr_anim[ "generic" ] [ "coup_talking_patrol_guy2" ]					 = %coup_talking_patrol_guy2;
	
	
	level.scr_anim[ "merrick" ] [ "traverse40_2_cover" ] = %traverse40_2_cover;
	level.scr_anim[ "hesh"	  ] [ "traverse40_2_cover" ] = %traverse40_2_cover;
	
	//intro crew
	level.scr_anim[ "intro_commander" ] [ "intro" ]	  = %satfarm_cargobay_commander; //this guy has all the scene notetracks
	level.scr_anim[ "intro_crewmaster" ] [ "intro" ]  = %satfarm_cargobay_crewmaster;
	level.scr_anim[ "intro_helper"	   ] [ "intro" ]  = %satfarm_cargobay_helper;
	level.scr_anim[ "intro_lieutenant" ] [ "intro" ]  = %satfarm_cargobay_lieutenant;
	level.scr_anim[ "intro_soldier1"   ] [ "intro" ]  = %satfarm_cargobay_soldier1;
	level.scr_anim[ "intro_soldier2"   ] [ "intro" ]  = %satfarm_cargobay_soldier2;
	level.scr_anim[ "intro_turretman"  ] [ "intro" ]  = %satfarm_cargobay_turretman;

	
	//loading anim
	level.scr_anim[ "tank_loader" ][ "idle_reload" ] 			= %abrams_loader_load;
	
	//dead tank crew
	level.scr_anim[ "dead" ][ "paris_npc_dead_poses_v24_chair_sq" ][ 0 ] 	= %paris_npc_dead_poses_v24_chair_sq;
	
	level.scr_anim[ "ally" ][ "clockwork_chaos_wave_guard" ][ 0 ]		   = %clockwork_chaos_wave_guard;
	level.scr_anim[ "ally" ] [ "payback_escape_start_wave_soap"			 ] = %payback_escape_start_wave_soap;
	level.scr_anim[ "ally" ] [ "run_react_stumble"						 ] = %run_react_stumble_non_loop;
	level.scr_anim[ "ally" ] [ "run_react_flinch"						 ] = %run_react_flinch_non_loop;
	level.scr_anim[ "ally" ] [ "payback_escape_forward_wave_right_price" ] = %payback_escape_forward_wave_right_price;
	level.scr_anim[ "ally" ] [ "run_react_duck"							 ] = %run_react_duck_non_loop;
	level.scr_anim[ "ally" ] [ "longdeath_wander_leg_1"					 ] = %longdeath_wander_leg_1;
	level.scr_anim[ "ally" ] [ "longdeath_wander_leg_collapse_1"		 ] = %longdeath_wander_leg_collapse_1;
	level.scr_anim[ "ally" ] [ "traverse_jumpdown_96"					 ] = %traverse_jumpdown_96;
	level.scr_anim[ "ally" ] [ "death_explosion_run_F_v1"				 ] = %death_explosion_run_F_v1;
}

#using_animtree( "player" );
player_anims()
{
	//Tower
	level.scr_animtree[ "player_arms" ]								   = #animtree;
	level.scr_model	  [ "player_arms" ]								   = "viewhands_player_delta";
	level.scr_anim[ "player_arms" ] [ "satfarm_control_tower_player" ] = %satfarm_control_tower_player;
	
	//tank anims	
	level.scr_animtree[ "player_rig" ]	= #animtree;
	level.scr_model	  [ "player_rig" ]	= "viewhands_player_delta";
  //level.scr_anim[ "player_rig" ][ "garage_crash_exit" ] = %hamburg_tank_crash_exit_upperbody;
	level.scr_anim[ "player_rig" ] [ "garage_crash_exit" ] = %satfarm_tank_exit_upperbody;
	level.scr_anim[ "player_rig" ] [ "mount_tank"		 ] = %hamburg_tank_entry_upperbody;

	level.scr_animtree[ "player_rig_legs" ]	 = #animtree;
	level.scr_model	  [ "player_rig_legs" ]	 = "viewlegs_generic";
  //level.scr_anim[ "player_rig_legs" ][ "garage_crash_exit" ] = %hamburg_tank_crash_exit_lowerbody;
	level.scr_anim[ "player_rig_legs" ] [ "garage_crash_exit" ] = %satfarm_tank_exit_lowerbody;
	level.scr_anim[ "player_rig_legs" ] [ "mount_tank"		  ] = %hamburg_tank_entry_lowerbody;
}

#using_animtree( "animated_props" );
animated_prop_anims()
{
	level.scr_animtree[ "satfarm_hangar_breach_s1" ]						   = #animtree;
	level.scr_model	  [ "satfarm_hangar_breach_s1" ]						   = "saf_hangar_breach_01";
	level.scr_anim[ "satfarm_hangar_breach_s1" ][ "satfarm_hangar_breach_s1" ] = %satfarm_hangar_breach_s1;
	
	level.scr_animtree[ "satfarm_hangar_breach_s2" ]						   = #animtree;
	level.scr_model	  [ "satfarm_hangar_breach_s2" ]						   = "saf_hangar_breach_02";
	level.scr_anim[ "satfarm_hangar_breach_s2" ][ "satfarm_hangar_breach_s2" ] = %satfarm_hangar_breach_s2;
	
	level.scr_animtree[ "satfarm_hangar_breach_s3" ]						   = #animtree;
	level.scr_model	  [ "satfarm_hangar_breach_s3" ]						   = "saf_hangar_breach_03";
	level.scr_anim[ "satfarm_hangar_breach_s3" ][ "satfarm_hangar_breach_s3" ] = %satfarm_hangar_breach_s3;
	
	level.scr_animtree[ "satfarm_hangar_breach_s4" ]						   = #animtree;
	level.scr_model	  [ "satfarm_hangar_breach_s4" ]						   = "saf_hangar_breach_04";
	level.scr_anim[ "satfarm_hangar_breach_s4" ][ "satfarm_hangar_breach_s4" ] = %satfarm_hangar_breach_s4;
	
	//ambient tank, plane and chutes
	level.scr_animtree[ "tank_ambient" ]			   = #animtree;
	level.scr_model	  [ "tank_ambient" ]			   = "vehicle_m1a1_abrams_viewmodel";//FIXME:  shouldn't be the viewmodel
	level.scr_anim[ "tank_ambient" ][ "ambient_drop" ] = %satfarm_ambient_tank_drop_m1a1;
	
	level.scr_animtree[ "c17_ambient" ]				  = #animtree;
	level.scr_model	  [ "c17_ambient" ]				  = "vehicle_boeing_c17";
	level.scr_anim[ "c17_ambient" ][ "ambient_drop" ] = %satfarm_ambient_tank_drop_c17;
	
	level.scr_animtree[ "pilot_chute_tank_ambient" ]					 = #animtree;
	level.scr_model	  [ "pilot_chute_tank_ambient" ]					 = "saf_parachute_proxy";
	level.scr_anim[ "pilot_chute_tank_ambient" ][ "pilot_chute_deploy" ] = %satfarm_ambient_tank_drop_pilotchute;
	
	level.scr_animtree[ "main_chute0_tank_ambient" ]					  = #animtree;
	level.scr_model	  [ "main_chute0_tank_ambient" ]					  = "saf_parachute_large";
	level.scr_anim[ "main_chute0_tank_ambient" ][ "main_chute_deploy" ] = %satfarm_ambient_tank_drop_mainchute1;
	
	level.scr_animtree[ "main_chute1_tank_ambient" ]					  = #animtree;
	level.scr_model	  [ "main_chute1_tank_ambient" ]					  = "saf_parachute_large";
	level.scr_anim[ "main_chute1_tank_ambient" ][ "main_chute_deploy" ] = %satfarm_ambient_tank_drop_mainchute2;
	
	level.scr_animtree[ "main_chute2_tank_ambient" ]					  = #animtree;
	level.scr_model	  [ "main_chute2_tank_ambient" ]					  = "saf_parachute_large";
	level.scr_anim[ "main_chute2_tank_ambient" ][ "main_chute_deploy" ] = %satfarm_ambient_tank_drop_mainchute3;
	
	
	//intro tanks
	level.scr_animtree[ "playertank_fake" ]		   = #animtree;
	level.scr_model	  [ "playertank_fake" ]		   = "vehicle_m1a1_abrams_viewmodel";
	level.scr_anim[ "playertank_fake" ][ "intro" ] = %satfarm_infil_playertank_conveyed_back;
	
	level.scr_animtree[ "playertank" ]		  = #animtree;
	level.scr_anim[ "playertank" ][ "intro" ] = %satfarm_infil_playertank;
	
	level.scr_animtree[ "crashedtank" ]		   = #animtree;
	level.scr_model	  [ "crashedtank" ]		   = "vehicle_m1a1_abrams";
	level.scr_anim[ "crashedtank" ][ "intro" ] = %satfarm_infil_crashedtank;
	
	level.scr_animtree[ "allytank_right" ]		  = #animtree;
	level.scr_anim[ "allytank_right" ][ "intro" ] = %satfarm_infil_allytank_right;
	
	//intro c17
	level.scr_animtree[ "playerc17" ]		 = #animtree;
	level.scr_model	  [ "playerc17" ]		 = "vehicle_boeing_c17";
	level.scr_anim[ "playerc17" ][ "intro" ] = %satfarm_infil_playerc17;
	
	level.scr_animtree[ "crashedc17" ]		  = #animtree;
	level.scr_model	  [ "crashedc17" ]		  = "vehicle_boeing_c17";
	level.scr_anim[ "crashedc17" ][ "intro" ] = %satfarm_infil_crashedc17;
	
	level.scr_animtree[ "allyc17_right" ]		 = #animtree;
	level.scr_model	  [ "allyc17_right" ]		 = "vehicle_boeing_c17";
	level.scr_anim[ "allyc17_right" ][ "intro" ] = %satfarm_infil_allyc17_right;
	
	//pilot chutes
	level.scr_animtree[ "pilot_chute_player" ]					   = #animtree;
	level.scr_model	  [ "pilot_chute_player" ]					   = "saf_parachute_proxy";
	level.scr_anim[ "pilot_chute_player" ][ "pilot_chute_deploy" ] = %satfarm_infil_pilotchute_player;
	
	level.scr_animtree[ "pilot_chute_crashedtank" ]						= #animtree;
	level.scr_model	  [ "pilot_chute_crashedtank" ]						= "saf_parachute_proxy";
	level.scr_anim[ "pilot_chute_crashedtank" ][ "pilot_chute_deploy" ] = %satfarm_infil_pilotchute_crashedtank;
	
	level.scr_animtree[ "pilot_chute_allytankright" ]					  = #animtree;
	level.scr_model	  [ "pilot_chute_allytankright" ]					  = "saf_parachute_proxy";
	level.scr_anim[ "pilot_chute_allytankright" ][ "pilot_chute_deploy" ] = %satfarm_infil_pilotchute_allytankright;
	
	//main chutes player
	level.scr_animtree[ "main_chute0_player" ]					  = #animtree;
	level.scr_model	  [ "main_chute0_player" ]					  = "saf_parachute_large";
	level.scr_anim[ "main_chute0_player" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute1_player;
	
	level.scr_animtree[ "main_chute1_player" ]					  = #animtree;
	level.scr_model	  [ "main_chute1_player" ]					  = "saf_parachute_large";
	level.scr_anim[ "main_chute1_player" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute2_player;
	
	level.scr_animtree[ "main_chute2_player" ]					  = #animtree;
	level.scr_model	  [ "main_chute2_player" ]					  = "saf_parachute_large";
	level.scr_anim[ "main_chute2_player" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute3_player;
	
	//main chutes crashedtank
	level.scr_animtree[ "main_chute0_crashedtank" ]					   = #animtree;
	level.scr_model	  [ "main_chute0_crashedtank" ]					   = "saf_parachute_large";
	level.scr_anim[ "main_chute0_crashedtank" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute1_crashedtank;
	
	level.scr_animtree[ "main_chute1_crashedtank" ]					   = #animtree;
	level.scr_model	  [ "main_chute1_crashedtank" ]					   = "saf_parachute_large";
	level.scr_anim[ "main_chute1_crashedtank" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute2_crashedtank;
	
	level.scr_animtree[ "main_chute2_crashedtank" ]					   = #animtree;
	level.scr_model	  [ "main_chute2_crashedtank" ]					   = "saf_parachute_large";
	level.scr_anim[ "main_chute2_crashedtank" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute3_crashedtank;
	
	//main chutes allytankright
	level.scr_animtree[ "main_chute0_allytankright" ]					 = #animtree;
	level.scr_model	  [ "main_chute0_allytankright" ]					 = "saf_parachute_large";
	level.scr_anim[ "main_chute0_allytankright" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute1_allytankright;
	
	level.scr_animtree[ "main_chute1_allytankright" ]					 = #animtree;
	level.scr_model	  [ "main_chute1_allytankright" ]					 = "saf_parachute_large";
	level.scr_anim[ "main_chute1_allytankright" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute2_allytankright;
	
	level.scr_animtree[ "main_chute2_allytankright" ]					 = #animtree;
	level.scr_model	  [ "main_chute2_allytankright" ]					 = "saf_parachute_large";
	level.scr_anim[ "main_chute2_allytankright" ][ "main_chute_deploy" ] = %satfarm_infil_mainchute3_allytankright;
}

#using_animtree( "vehicles" );
minigun_anims()
{
	level.scr_animtree[ "minigun_m1a1" ]			 = #animtree;
	level.scr_model	  [ "minigun_m1a1" ]			 = "weapon_m1a1_minigun";
	level.scr_anim[ "minigun_m1a1" ][ "mount_tank" ] = %hamburg_tank_entry_minigun;
}