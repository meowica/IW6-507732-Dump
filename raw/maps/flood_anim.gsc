#include common_scripts\utility;
#include maps\_utility;
#include maps\_anim;
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
	dialogue();
	script_models();
	vehicles();	

	level thread vignettes();
	//thread mall_rooftop_debri_020_spawn();
}

anim_precache()
{
	PreCacheModel( "viewhands_player_ranger_dirty_urban" );	
}

vignettes()
{
	level thread vignette_register( ::skybridge_doorbreach_spawn	  , "vignette_skybridge_doorbreach_trigger" );
	level thread vignette_register( ::skybridge_ally_approach		  , "vignette_skybridge_approach" );
	level thread vignette_register( ::skybridge_scene_spawn			  , "vignette_skybridge_flag" );
	level thread vignette_register( ::debris_bridge_spawn			  , "vignette_debris_bridge_loop1_flag" );
	level thread vignette_register( ::building_01_debri_anim_spawn	  , "building_01_debri" );
	level thread vignette_register( ::ending_breach_spawn			  , "vignette_ending_doorbreach_flag" );
	level thread vignette_register( ::ending_pt1_player_sequence_start, "vignette_ending_player_jumped_flag" );
	level thread vignette_register( ::ending_pt1_sequence			  , "vignette_ending_scene_start" );
	level thread vignette_register( ::ending_pt2_player_sequence	  , "vignette_ending_crash_flag" );


	//spawn m880 and first frame it
	//make sure m880 exists first (for TFF)
	dam_break_m880_spawner = GetEnt( "dam_break_m880", "targetname" );
	if ( IsDefined( dam_break_m880_spawner ) )
	{
		level thread dam_break_m880_init();
		level thread dam_break_m880_shadows_init();
	}
	
	//spawn church spire and first frame it
	level thread church_destruction_init();
	//spawn dam debris and first frame everything
	level thread init_dam_destruction_anim();
	level thread dam_break_street_water_init();
	level thread street_stop_sign_01_spawn();
	
	level thread vignette_register( ::dam_break_m880_launch_prep_spawn, "vignette_dam_break_m880_launch_prep" );
		
	//don't run this if it's the flooding_ext checkpoint
	if ( level.start_point != "flooding_ext" )
	{
		level thread vignette_register( ::dam_break_spawn, "vignette_dam_break" );
	}
}

flag_inits()
{
	flag_init( "vignette_debris_bridge_vign2_flag" );
	flag_init( "vignette_debris_bridge_loop3_flag" );
	flag_init( "vignette_dam_break_end_flag" );
	flag_init( "vignette_ending_player_jumped_flag" );
	flag_init( "vignette_ending_scene_start" );
	flag_init( "vignette_ending_qte_success" );
	flag_init( "vignette_ending_qte_failure" );
	flag_init( "vignette_ending_qte_pickup_gun" );

	flag_init( "skybridge_ally_done" );

	flag_init( "rooftops_water_truck_intro_done" );
	flag_init( "rooftops_water_flare_intro_done" );

	flag_init( "debrisbridge_ally_0_ready" );
	flag_init( "debrisbridge_ally_1_ready" );
	flag_init( "debrisbridge_ally_2_ready" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

#using_animtree( "player" );
player_anims()
{
	// created by JKU.  I don't think we really want to be setting the models multiple different times
	level.scr_animtree	[ "player_rig"	] = #animtree;
	level.scr_model		[ "player_rig"	] = "viewhands_player_ranger_dirty_urban";
	
	//Infil
	level.scr_anim		[ "player_rig" ][ "infil" ]						 = %flood_infil_player;
//	addNotetrack_customFunction( "player_rig", "start_qte", maps\flood_streets::mlrs_start_qte, "mlrs_kill1_start" );
	
	//MLRS Kill Start
	level.scr_anim[ "player_rig" ][ "mlrs_kill1_start" ] = %flood_mlrs_kill1_player_start;
	addNotetrack_customFunction( "player_rig", "start_qte", maps\flood_streets::mlrs_start_qte, "mlrs_kill1_start" );
	
	//MLRS Kill End
	level.scr_anim[ "player_rig" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_player_kill;
	
	//MLRS Kill Fail	
	level.scr_anim[ "player_rig" ][ "m880_kill1_fail" ] = %flood_mlrs_kill1_player_fail;

	
	//Dam Break
	level.scr_anim[ "player_rig" ][ "dam_break" ] = %flood_dam_break_player;

	addNotetrack_customFunction( "player_rig", "opfor_m880_escape", ::opfor_m880_escape_spawn );
	addNotetrack_customFunction( "player_rig", "play_cone_anims", ::play_cone_anims );
	addNotetrack_customFunction( "player_rig", "start_street_water", ::dam_break_street_water );
	
	addNotetrack_customFunction( "player_rig", "start_church_destruction", ::start_church_destruction );
	
	/*
	//Heli Crash - Jump
	level.scr_animtree	[ "player_rig" ]					   = #animtree;
	level.scr_anim[ "player_rig" ][ "heli_crash_player_jump" ] = %flood_heli_crash_jump_player;
	
	addNotetrack_customFunction( "heli_crash_player_jump", "start_opfor_fall", ::heli_crash_opfor_fall_out );
	
	level.scr_animtree	[ "player_rig" ]								 = #animtree;
	level.scr_anim[ "player_rig" ][ "heli_crash_fight_03" ] = %flood_heli_crash_fight_03_player;
	*/

	level.scr_animtree	[ "swept_path_rig" ]											  = #animtree;
	level.scr_anim		[ "swept_path_rig" ][ "flood_sweptaway_player_path"				] = %flood_sweptaway_player_path;
	level.scr_model		[ "swept_path_rig" ]											  = "viewhands_player_ranger_dirty_urban";

	level.scr_anim		[ "player_rig" ][ "flood_sweptaway"	  ] = %flood_sweptaway_player;
	level.scr_anim		[ "player_rig" ][ "flood_sweptaway_L" ] = %flood_sweptaway_player_L;
	level.scr_anim		[ "player_rig" ][ "flood_sweptaway_R" ] = %flood_sweptaway_player_R;

	// sweptaway end vignette
	level.scr_anim[ "player_rig" ][ "sweptaway_end_b"		] = %flood_sweptaway_end_player;
	addNotetrack_customFunction( "player_rig", "rumble_antenna", maps\flood_swept::antenna_rumble );
	addNotetrack_customFunction( "player_rig", "rumble", maps\flood_swept::truck_rumble );
	
	// knife pullout
	level.scr_anim[ "player_rig" ][ "stealth_knife_pullout" ] = %viewmodel_flood_knife_rh_pullout;
	
	// stealth kill 2
	level.scr_anim[ "player_rig" ][ "stealth_kill_02" ] = %flood_stealthkill_02_player;
	level.scr_anim[ "player_rig" ][ "mall_roofcollapse_player01" ] = %flood_roofcollapse_player_01;
	level.scr_anim[ "player_rig" ][ "stealth_traverse" ] = %flood_stealthkill_02_player_traverse;
	
	addNotetrack_customFunction( "player_rig", "fx_stealthkill_02_blood_01", maps\flood_fx::fx_stealthkill_02_blood_01 );

	level.scr_anim		[ "player_rig" ][ "skybridge_flinch" ] = %flood_skybridge_skybridgewalk_player;
	addNotetrack_customFunction( "player_rig", "lookingdown", ::skybridge_ally_cross );

	// outro pt1
	level.scr_anim[ "player_rig" ] [ "outro_pt1_breach"						  ] = %flood_outro_pt1_breach_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_melee_player"				  ] = %flood_outro_pt1_melee_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_melee_win"					  ] = %flood_outro_pt1_melee_win_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_melee_fail"					  ] = %flood_outro_pt1_melee_fail_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_garcia_punch"				  ] = %flood_outro_pt1_garcia_punch_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_garcia_punch_player_additive" ] = %flood_outro_pt1_garcia_punch_player_additive;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_garcia_kill_pt1"			  ] = %flood_outro_pt1_garcia_kill_pt1_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_garcia_kill_pt2"			  ] = %flood_outro_pt1_garcia_kill_pt2_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt1_crash"						  ] = %flood_outro_pt1_crash_player;
	addNotetrack_customFunction( "player_rig", "start_ally_vignette", ::ending_pt1_allies_sequence_start		   , "outro_pt1_breach" );
	addNotetrack_customFunction( "player_rig", "start_interior"		, ::ending_pt1_scene_start					   , "outro_pt1_melee_player" );
	addNotetrack_customFunction( "player_rig", "hit_small"			, maps\flood_ending::ending_player_take_damage , "outro_pt1_melee_player" );
	addNotetrack_customFunction( "player_rig", "start_kill_opfor01" , ::ending_qte_0_start						   , "outro_pt1_melee_player" );
	addNotetrack_customFunction( "player_rig", "sfx_heli_jump" 		, maps\flood_audio::sfx_heli_jump_script );
	addNotetrack_customFunction( "player_rig", "hit_big"			, maps\flood_ending::ending_player_failed_qte_0, "outro_pt1_melee_fail" );
	addNotetrack_customFunction( "player_rig", "sfx_slomo"			, maps\flood_audio::sfx_slomo_script	 );
	addNotetrack_customFunction( "player_rig", "slowmo_start"		, maps\flood_ending::ending_player_slowmo_start, "outro_pt1_garcia_punch" );
	addNotetrack_customFunction( "player_rig", "hit_big"			, maps\flood_ending::ending_player_broken_nose , "outro_pt1_garcia_punch" );
	addNotetrack_customFunction( "player_rig", "hit_small"			, maps\flood_ending::ending_player_take_damage , "outro_pt1_garcia_punch" );
	addNotetrack_customFunction( "player_rig", "slowmo_end"			, maps\flood_ending::ending_player_slowmo_end  , "outro_pt1_garcia_punch" );
	addNotetrack_customFunction( "player_rig", "player_can_fire"	, ::ending_harmless_shots_logic				   , "outro_pt1_garcia_punch" );
	addNotetrack_customFunction( "player_rig", "fade_to_black"		, maps\flood_ending::ending_player_fade		   , "outro_pt1_crash" );
	addNotetrack_customFunction( "player_rig", "sfx_plane_crash"		, maps\flood_audio::sfx_plane_crash_script		   , "outro_pt1_crash" );
	addNotetrack_customFunction( "player_rig", "sfx_ally_grab"		, maps\flood_audio::sfx_ally_grab_script );
	addNotetrack_customFunction( "player_rig", "sfx_gun_grab"		, maps\flood_audio::sfx_gun_grab_script );
	addNotetrack_customFunction( "player_rig", "sfx_alarms"		, maps\flood_audio::sfx_alarms_script );
	addNotetrack_customFunction( "player_rig", "sfx_stop_alarms"		, maps\flood_audio::sfx_stop_alarms_script );

	// outro pt2
	level.scr_anim[ "player_rig" ] [ "outro_pt2_start"				 ] = %flood_outro_pt2_start_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt2_start_fail"			 ] = %flood_outro_pt2_start_player_fail;
	level.scr_anim[ "player_rig" ] [ "outro_pt2_save_vargas"		 ] = %flood_outro_pt2_save_vargas_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt2_save_vargas_win_01"	 ] = %flood_outro_pt2_save_vargas_win_01_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt2_save_vargas_win_02"	 ] = %flood_outro_pt2_save_vargas_win_02_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt2_save_vargas_fail_01" ] = %flood_outro_pt2_save_vargas_fail_01_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt2_save_vargas_fail_02" ] = %flood_outro_pt2_save_vargas_fail_02_player;
	level.scr_anim[ "player_rig" ] [ "outro_pt2_vargas_death"		 ] = %flood_outro_pt2_vargas_death_player;
	addNotetrack_customFunction( "player_rig", "player_grab_vargas", maps\flood_ending::ending_player_qte_reach_logic, "outro_pt2_save_vargas" );
	addNotetrack_customFunction( "player_rig", "sfx_wake_up"		, maps\flood_audio::sfx_wake_up_script	 );
	addNotetrack_customFunction( "player_rig", "sfx_save"		, maps\flood_audio::sfx_save_script	 );

	//level.scr_anim[ "player_legs" ][ "outro_pt2_start" ] = %flood_outro_pt2_start_player_legs;
	//temp commenting out so as to not introduce more bugs.  These will eventually be the 'alt' states for the save vargas part.
	//level.scr_anim[ "player_rig" ][ "outro_pt2_save_vargas" ] = %flood_outro_pt2_save_vargas_player_state02;
	//level.scr_anim[ "player_rig" ][ "outro_pt2_save_vargas" ] = %flood_outro_pt2_save_vargas_player_state03;
}


#using_animtree("generic_human");
generic_human()
{
	maps\_patrol_anims::main();
	maps\_patrol_anims_gundown::main();
	maps\_patrol_anims_creepwalk::main();
	maps\_hand_signals::initHandSignals();
	level.scr_anim[ "generic" ][ "active_patrolwalk_gundown" ] = %active_patrolwalk_gundown;

	// infil guy that fires rpgs past the helicopters
	level.scr_anim[ "generic" ][ "rpg_reload" ] = %RPG_stand_reload;
	
	// this is a hack anim that is used for anim_reach when an anim where the start pos is the same as the scripted node is needed.
	level.scr_anim[ "ally_0" ][ "anim_reach" ] = %flood_cornerwaving_ally06_loop;
	level.scr_anim[ "ally_1" ][ "anim_reach" ] = %flood_cornerwaving_ally06_loop;
	level.scr_anim[ "ally_2" ][ "anim_reach" ] = %flood_cornerwaving_ally06_loop;

	//Infil
	level.scr_anim[ "ally_0" ] [ "infil_loop"	 ][ 0 ] = %flood_infil_ally1_loop;
	level.scr_anim[ "ally_0" ] [ "infil_vo"		 ]		= %flood_infil_ally1_vo;
	level.scr_anim[ "ally_1" ] [ "infil_jumpout" ]		= %flood_infil_ally2_jumpout;
	
	level.scr_anim[ "ally_0" ][ "infil" ]			   = %flood_infil_heli_01_ally_01;
	//level.scr_anim[ "heli_01_gunner_01" ][ "infil" ] = %flood_infil_heli_01_gunner;
	level.scr_anim[ "heli_01_copilot"	][ "infil" ]   = %flood_infil_heli_01_copilot;
	level.scr_anim[ "heli_02_ally_01"	][ "infil" ]   = %flood_infil_heli_02_ally_01;
	level.scr_anim[ "heli_02_ally_02"	][ "infil" ]   = %flood_infil_heli_02_ally_02;
	level.scr_anim[ "heli_02_ally_03"	][ "infil" ]   = %flood_infil_heli_02_ally_03;
	level.scr_anim[ "heli_02_ally_04"	][ "infil" ]   = %flood_infil_heli_02_ally_04;
	level.scr_anim[ "heli_02_gunner_01" ][ "infil" ]   = %flood_infil_heli_02_gunner_01;
	level.scr_anim[ "heli_02_gunner_02" ][ "infil" ]   = %flood_infil_heli_02_gunner_02;
	level.scr_anim[ "heli_02_pilot"		][ "infil" ]   = %flood_infil_heli_02_pilot;
	level.scr_anim[ "heli_02_copilot"	][ "infil" ]   = %flood_infil_heli_02_copilot;
	
	level.scr_anim[ "heli_02_ally_01" ][ "infil_dismount" ] = %flood_infil_heli_02_ally_01_dismount;
	level.scr_anim[ "heli_02_ally_02" ][ "infil_dismount" ] = %flood_infil_heli_02_ally_02_dismount;
	level.scr_anim[ "heli_02_ally_03" ][ "infil_dismount" ] = %flood_infil_heli_02_ally_01_dismount;
	level.scr_anim[ "heli_02_ally_04" ][ "infil_dismount" ] = %flood_infil_heli_02_ally_02_dismount;
	
	addNotetrack_customFunction( "ally_0", "unlink", maps\flood_infil::unlink_ally_from_heli );
	//addNotetrack_customFunction( "ally_1", "unlink", maps\flood_infil::unlink_ally_from_heli );
	//addNotetrack_customFunction( "ally_1", "unlink", maps\flood_infil::unlink_ally_from_heli );
	
	// Price wave you on after helicopter
	level.scr_anim[ "ally_0" ][ "price_exit_chopper_wave" ] = %flood_move_forward_and_wave;
	
	//mall garage collapse stumble
	level.scr_anim[ "generic" ][ "run_root" ] = %combatrun_forward;
	level.scr_anim[ "generic" ][ "run_duck" ] = %run_react_duck;
	level.scr_anim[ "generic" ][ "run_flinch" ] = %run_react_flinch;
	level.scr_anim[ "generic" ][ "run_stumble" ] = %run_react_stumble;
	level.scr_anim[ "generic" ][ "run_stumble_non_loop" ] = %run_react_stumble_non_loop;
	
	//MLRS Kill Start
	level.scr_anim[ "mlrs_kill1_opfor" ][ "mlrs_kill1_start" ] = %flood_mlrs_kill1_opfor_start;
	
	//MLRS Kill End
	level.scr_anim[ "mlrs_kill1_opfor" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_opfor_kill;
	level.scr_anim[ "mlrs_kill1_end_player_legs" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_playerlegs_kill;
	
	//MLRS Kill Fail
	level.scr_anim[ "mlrs_kill1_opfor" ][ "m880_kill1_fail" ] = %flood_mlrs_kill1_opfor_fail;
	//level.scr_anim[ "mlrs_kill_opfor" ][ "mlrs_kill1_fail" ] = %flood_mlrs_kill1_opfor_kill;
	
	//Dam Break
	level.scr_anim[ "ally_0" ][ "dam_break" ] = %flood_dam_break_ally_03;
	level.scr_anim[ "ally_1" ][ "dam_break" ] = %flood_dam_break_ally_01;
	level.scr_anim[ "ally_2" ][ "dam_break" ] = %flood_dam_break_ally_02;
	level.scr_anim[ "dam_break_player_legs" ][ "dam_break" ] = %flood_dam_break_player_legs;
	level.scr_anim[ "dam_break_opfor_m880" ][ "opfor_m880_escape" ] = %flood_dam_break_opfor_m880;
	
	/*
	//Heli Crash
	level.scr_anim[ "ally_0" ][ "heli_crash_intro" ] = %flood_heli_crash_intro_baker;
	level.scr_anim[ "opfor_01" ][ "heli_crash_intro" ] = %flood_heli_crash_intro_opfor_01;
	level.scr_anim[ "opfor_02" ][ "heli_crash_intro" ] = %flood_heli_crash_intro_opfor_02;
		
	level.scr_anim[ "ally_0" ][ "heli_crash_fight_01_loop" ][0] = %flood_heli_crash_fight_01_loop_baker;
	level.scr_anim[ "opfor_01" ][ "heli_crash_fight_01_loop" ][0] = %flood_heli_crash_fight_01_loop_opfor_02;
	level.scr_anim[ "opfor_02" ][ "heli_crash_opfor_fall_out" ] = %flood_heli_crash_fight_01_dead_opfor_02;
	
	level.scr_anim[ "opfor_03" ][ "heli_crash_fight_02" ] = %flood_heli_crash_fight_02_opfor_03;
	level.scr_anim[ "opfor_03" ][ "heli_crash_fight_02_dead" ] = %flood_heli_crash_fight_02_dead_opfor_03;
	
	level.scr_anim[ "rourke" ][ "heli_crash_fight_03" ] = %flood_heli_crash_fight_03_rourke;
	*/
	//Streets_to_Dam
	level.scr_anim[ "ally_0" ][ "ally_hold_01"			]				= %flood_ally_hold_signal_ally_01;
		
	// Convoy Checkpoint
	level.scr_anim[ "convoy_checkpoint_opfor01" ][ "convoy_checkpoint" ] = %flood_convoy_checkpoint_opfor01;
	level.scr_anim[ "convoy_checkpoint_opfor02" ][ "convoy_checkpoint" ] = %flood_convoy_checkpoint_opfor02;
	level.scr_anim[ "convoy_checkpoint_opfor03" ][ "convoy_checkpoint" ] = %flood_convoy_checkpoint_opfor03;
	level.scr_anim[ "convoy_checkpoint_opfor04" ][ "convoy_checkpoint" ] = %flood_convoy_checkpoint_opfor04;
	
	// Launcher Callouts
	level.scr_anim[ "launcher_callout_ally01" ][ "launcher_callout_ally01" ] = %flood_launcher_callout_ally01;
	level.scr_anim[ "launcher_callout_ally02" ][ "launcher_callout_ally02" ] = %flood_launcher_callout_ally02;
	level.scr_anim[ "launcher_callout_ally03" ][ "launcher_callout_ally03" ] = %flood_launcher_callout_ally03;
	
	// traversal
	level.scr_anim[ "generic"			 ][ "ch_pragueb_7_5_crosscourt_aimantle_a" ] = %ch_pragueb_7_5_crosscourt_aimantle_a;

	// Warehouse Stairs
	level.scr_anim[ "ally_0" ][ "warehouse_stairs_start" ]	   = %flood_warehouse_stairs_start_ally_01;
	level.scr_anim[ "ally_1" ][ "warehouse_stairs_start" ]	   = %flood_warehouse_stairs_start_ally_02;
	level.scr_anim[ "ally_2" ][ "warehouse_stairs_start" ]	   = %flood_warehouse_stairs_start_ally_03;
	
	level.scr_anim[ "ally_0" ][ "warehouse_stairs_loop" ][ 0 ] = %flood_warehouse_stairs_loop_ally_01;
	level.scr_anim[ "ally_1" ][ "warehouse_stairs_loop" ][ 0 ] = %flood_warehouse_stairs_loop_ally_02;
	level.scr_anim[ "ally_2" ][ "warehouse_stairs_loop" ][ 0 ] = %flood_warehouse_stairs_loop_ally_03;
	
	level.scr_anim[ "ally_0" ][ "warehouse_stairs_end" ]	   = %flood_warehouse_stairs_end_ally_01;
	level.scr_anim[ "ally_1" ][ "warehouse_stairs_end" ]	   = %flood_warehouse_stairs_end_ally_02;
	level.scr_anim[ "ally_2" ][ "warehouse_stairs_end" ]	   = %flood_warehouse_stairs_end_ally_03;
	
//	addNotetrack_customFunction( "ally_0"  , "start_vo"		   , maps\flood_flooding::flooding_stairs_vo );
	addNotetrack_customFunction( "ally_0"  , "event_quaker_big", maps\flood_mall::event_quaker_big );
	

	//Breach: guys react to mall breach
	level.scr_anim[ "generic" ][ "mall_breach_enemy_1" ] = %breach_chair_hide_reaction_v1;
	level.scr_anim[ "breacher2" ][ "mall_breach_enemy_2" ] = %breach_react_push_guy1;
	level.scr_anim[ "breacher3" ][ "mall_breach_enemy_2" ] = %breach_react_push_guy2;

	level.scr_anim[ "ally_0" ][ "flood_warehouse_breach"			 ] = %flood_warehouse_breach_ally1;
	addNotetrack_customFunction( "ally_0", "door_open", maps\flood_flooding::open_loading_dock_doors, "flood_warehouse_breach" );
	
	//mall roof door entrance
	level.scr_anim[ "ally_2" ][ "flood_mall_roof_door_walkup" ] = %flood_entering_mall_rooftop_ally2_walkup;
	
	level.scr_anim[ "ally_0" ][ "flood_mall_roof_door" ] = %flood_entering_mall_rooftop_ally1;
	level.scr_anim[ "ally_2" ][ "flood_mall_roof_door" ] = %flood_entering_mall_rooftop_ally2;
	level.scr_anim[ "ally_1" ][ "flood_mall_roof_door" ] = %flood_entering_mall_rooftop_ally3;
	
	level.scr_anim[ "ally_1" ][ "flood_mall_roof_door_loop" ][ 0 ] = %flood_entering_mall_rooftop_ally3_loop1;
	level.scr_anim[ "ally_0" ][ "flood_mall_roof_door_loop" ][ 0 ] = %flood_entering_mall_rooftop_ally1_loop1;
	level.scr_anim[ "ally_2" ][ "flood_mall_roof_door_loop" ][ 0 ] = %flood_entering_mall_rooftop_ally2_loop1;
	
	level.scr_anim[ "ally_1" ][ "flood_mall_roof_door_open_loop" ][ 0 ] = %flood_entering_mall_rooftop_ally3_loop2;
	level.scr_anim[ "ally_1" ][ "flood_mall_roof_door_outdoor" ] = %flood_entering_mall_rooftop_ally3_outdoor;
	
	level.scr_anim[ "ally_0" ][ "flood_mall_roof_fall" ] = %flood_mall_roofcollapse_fall_ally01;
	level.scr_anim[ "ally_1" ][ "flood_mall_roof_fall" ] = %flood_mall_roofcollapse_fall_ally02;
	level.scr_anim[ "ally_2" ][ "flood_mall_roof_fall" ] = %flood_mall_roofcollapse_fall_ally03;
	
	// sweptaway
	level.scr_anim[ "swept_opfor_floater" ][ "sweptaway" ] = %flood_sweptaway_opfor_floating;
	level.scr_anim[ "swept_opfor_tree" ][ "sweptaway" ] = %flood_sweptaway_opfor_tree;
	
	// sweptaway end vignette
	level.scr_anim[ "ally_0" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_ally1;
	level.scr_anim[ "sweptaway_end_opfor_floater" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_opfor_floating;
	level.scr_anim[ "sweptaway_end_opfor_pinned" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_opfor_pinned;
	
	//stealth kills
	level thread stealth_generic_human();

	// skybridge door breach
	level.scr_anim[ "ally_0" ][ "skybridge_doorbreach" ] = %flood_skybridge_doorbreach_ally;
	
	// skybridge
	level.scr_anim[ "ally_0" ][ "skybridge_ally_approach"	 ]		= %flood_skybridge_skybridgewalk_ally_front_start;
	level.scr_anim[ "ally_0" ][ "skybridge_ally_loop"		 ][ 0 ] = %flood_skybridge_skybridgewalk_ally_front_loop;
	level.scr_anim[ "ally_0" ][ "skybridge_cross_behind" ]			= %flood_skybridge_skybridgewalk_ally_back;
	level.scr_anim[ "ally_0" ][ "skybridge_cross_ahead"	 ]			= %flood_skybridge_skybridgewalk_ally_front;

	// rooftops
	level.scr_anim[ "generic" ][ "hacking"	  ][ 0 ] = %london_warehouse_computer_idle;
	level.scr_anim[ "opfor_0" ][ "hacking"	  ][ 0 ] = %london_warehouse_computer_idle;
	level.scr_anim[ "opfor_1" ][ "hacking"	  ][ 0 ] = %london_warehouse_computer_idle;
	level.scr_anim[ "generic" ][ "stand_idle" ][ 0 ] = %readystand_idle_twitch_1;

	level.scr_anim[ "ally_0" ][ "ally_hold_01"			]				= %flood_ally_hold_signal_ally_01;
	level.scr_anim[ "ally_0" ][ "rooftops_traversal_01" ]				= %flood_rooftop_traversal_ally01;
	level.scr_anim[ "ally_0" ][ "rooftops_traversal_03" ]				= %flood_rooftop_traversal_ally03;
	level.scr_anim[ "opfor_0" ][ "rooftops_heli_ropeladder_loop" ][ 0 ] = %flood_rooftops_01_opfor01_loop;
	level.scr_anim[ "opfor_1" ][ "rooftops_heli_ropeladder_loop" ][ 0 ] = %flood_rooftops_01_opfor02_loop;
	level.scr_anim[ "opfor_0" ][ "rooftops_heli_ropeladder" ]			= %flood_rooftops_01_opfor01;
	level.scr_anim[ "opfor_1" ][ "rooftops_heli_ropeladder" ]			= %flood_rooftops_01_opfor02;
	level thread rooftop1_generic_human();
	level.scr_anim[ "ally_0" ][ "rooftops_idle_loop_0" ][ 0 ]			= %flood_rooftop_traversal_ally01_loop1;
	level.scr_anim[ "ally_0" ][ "rooftops_idle_loop_1" ][ 0 ]			= %flood_rooftop_traversal_ally01_loop2;
	level.scr_anim[ "ally_0" ][ "rooftops_wall_kick" ]					= %flood_rooftop_traversal_ally01_walktoWall;
	level.scr_anim[ "ally_0" ][ "rooftops_water_long_jump" ]			= %flood_rooftop_traversal_ally02;
	level.scr_anim[ "ally_0" ][ "rooftops_water_stumble_and_jump" ]		= %flood_rooftop_traversal_ally03_secondjump;
	level.scr_anim[ "ally_0" ][ "rooftops_water_approach_stumble" ]		= %flood_rooftop_traversal_ally02_merge;
	level.scr_anim[ "ally_0" ][ "rooftops_water_approach_loop" ][ 0 ]	= %flood_rooftop_traversal_ally02_loop;
	level.scr_anim[ "ally_0" ][ "rooftops_water_approach_jump" ]		= %flood_rooftop_traversal_ally02_secondjump;

	// roofops 2 encoutner
	level.scr_anim[ "opfor_0" ][ "rooftops_water_reveal" ] = %flood_rooftops_02_encounter_opfor_01;
	level thread rooftop2_generic_human();
	level.scr_anim[ "opfor_1" ][ "rooftops_water_reveal_flare" ][ 0 ] = %flood_rooftop_waving_flares_opfor_loop;

	// debris bridge
	level.scr_anim[ "ally_0" ][ "debris_bridge_vign2_loc0" ] = %flood_debrisbridge_vign2_ally1;
	level.scr_anim[ "ally_0" ][ "debris_bridge_vign2_loc1" ] = %flood_debrisbridge_vign2_ally2;
	level.scr_anim[ "ally_0" ][ "debris_bridge_vign2_loc2" ] = %flood_debrisbridge_vign2_ally3;
	level.scr_anim[ "ally_1" ][ "debris_bridge_vign2_loc0" ] = %flood_debrisbridge_vign2_ally1;
	level.scr_anim[ "ally_1" ][ "debris_bridge_vign2_loc1" ] = %flood_debrisbridge_vign2_ally2;
	level.scr_anim[ "ally_1" ][ "debris_bridge_vign2_loc2" ] = %flood_debrisbridge_vign2_ally3;
	level.scr_anim[ "ally_2" ][ "debris_bridge_vign2_loc0" ] = %flood_debrisbridge_vign2_ally1;
	level.scr_anim[ "ally_2" ][ "debris_bridge_vign2_loc1" ] = %flood_debrisbridge_vign2_ally2;
	level.scr_anim[ "ally_2" ][ "debris_bridge_vign2_loc2" ] = %flood_debrisbridge_vign2_ally3;

	level.scr_anim[ "ally_0" ][ "debrisbridge_loop0" ][ 0 ] = %flood_debrisbridge_loop_3_ally1;
	level.scr_anim[ "ally_0" ][ "debrisbridge_loop1" ][ 0 ] = %flood_debrisbridge_loop_3_ally2;
	level.scr_anim[ "ally_0" ][ "debrisbridge_loop2" ][ 0 ] = %flood_debrisbridge_loop_3_ally3;
	level.scr_anim[ "ally_1" ][ "debrisbridge_loop0" ][ 0 ] = %flood_debrisbridge_loop_3_ally1;
	level.scr_anim[ "ally_1" ][ "debrisbridge_loop1" ][ 0 ] = %flood_debrisbridge_loop_3_ally2;
	level.scr_anim[ "ally_1" ][ "debrisbridge_loop2" ][ 0 ] = %flood_debrisbridge_loop_3_ally3;
	level.scr_anim[ "ally_2" ][ "debrisbridge_loop0" ][ 0 ] = %flood_debrisbridge_loop_3_ally1;
	level.scr_anim[ "ally_2" ][ "debrisbridge_loop1" ][ 0 ] = %flood_debrisbridge_loop_3_ally2;
	level.scr_anim[ "ally_2" ][ "debrisbridge_loop2" ][ 0 ] = %flood_debrisbridge_loop_3_ally3;
	
	// garage
	level.scr_anim[ "garage_jump_01_opfor" ][ "garage_jump_01" ] = %flood_garage_jump_opfor_01;
	
	// mall rooftop guys
	level.scr_anim[ "opfor_1" ][ "flood_mall_roof_opfor" ][ 0 ] = %flood_mall_rooftop_opfor1_loop;
	level.scr_anim[ "opfor_2" ][ "flood_mall_roof_opfor" ][ 0 ] = %flood_mall_rooftop_opfor2_loop;

	level.scr_anim[ "opfor_2" ][ "flood_mall_roof_opfor_shot" ] = %flood_mall_rooftop_opfor2_shot;
	
	// warehouse mantles
	level.scr_anim[ "ally_0" ][ "flood_warehouse_mantle" ] = %flood_warehouse_traversal_ally2;
	level.scr_anim[ "ally_1" ][ "flood_warehouse_mantle" ] = %flood_warehouse_traversal_ally1;
	level.scr_anim[ "ally_2" ][ "flood_warehouse_mantle" ] = %traverse_stepup_52;
	
	level.scr_anim[ "generic" ][ "run_react_stumble_non_loop" ] = %run_react_stumble_non_loop;
	level.scr_anim[ "generic" ][ "readystand_idle_twitch_1" ][ 0 ] = %readystand_idle_twitch_1;
	level.scr_anim[ "generic" ][ "run_trans_2_readystand_1" ] = %run_trans_2_readystand_1;
	
	level.scr_anim[ "ally_1" ][ "flood_cornerwaving_loop" ][ 0 ] = %readystand_idle_twitch_1;
	
	level.scr_anim[ "ally_0" ][ "flood_cornerwaving_loop" ][ 0 ] = %flood_cornerwaving_ally06_loop;
	level.scr_anim[ "ally_0" ][ "flood_cornerwaving_run" ]		 = %flood_cornerwaving_ally06_run;
	level.scr_anim[ "ally_0" ][ "flood_cornerwaving_enter" ]	 = %flood_cornerwaving_ally06_run_enter;

	level.scr_anim[ "generic" ][ "ending_door_kick" ] = %doorkick_2_cqbrun;

	// Outro Old
	level.scr_anim[ "ally_0" ][ "outro" ] = %flood_outro_heli_jump_price;
	level.scr_anim[ "ally_1" ][ "outro" ] = %flood_outro_heli_jump_vargas;
	level.scr_anim[ "generic" ][ "outro" ] = %flood_outro_heli_jump_garcia;
	level.scr_anim[ "ally_0" ][ "outro_melee_01" ] = %flood_outro_melee_01_price;
	level.scr_anim[ "ally_1" ][ "outro_melee_01" ] = %flood_outro_melee_01_vargas;
	level.scr_anim[ "generic" ][ "outro_melee_01" ] = %flood_outro_melee_01_garcia;
	
	// ending breach
	level.scr_anim[ "ally_0" ] [ "outro_pt1_breach"		   ] = %flood_outro_pt1_breach_price;
	level.scr_anim[ "ally_0" ] [ "outro_pt1_breach_nearby" ] = %flood_outro_pt1_breach_price_corner_stand;
	level.scr_anim[ "ally_1" ] [ "outro_pt1_breach"		   ] = %flood_outro_pt1_breach_vargas;

	// ending Garcia
	level.scr_anim[ "generic" ][ "outro_pt1_garcia_punch"	 ] = %flood_outro_pt1_garcia_punch_garcia;			// garcia knocks player to the ground
	level.scr_anim[ "generic" ][ "outro_pt1_garcia_kill_pt1" ] = %flood_outro_pt1_garcia_kill_pt1_garcia;		// garcia lines up a kill shot on player
	level.scr_anim[ "generic" ][ "outro_pt1_garcia_kill_pt2" ] = %flood_outro_pt1_garcia_kill_pt2_garcia;		// garcia gets killed
	level.scr_anim[ "generic" ][ "outro_pt1_crash" ]		   = %flood_outro_pt1_crash_garcia;					// death of garcia

	// price fights opfor 1, then goes for garcia
	level.scr_anim[ "ally_0" ][ "outro_pt1_start" ]					= %flood_outro_pt1_start_price;				// get on
	level.scr_anim[ "ally_0" ][ "outro_pt1_start_loop_price" ][ 0 ] = %flood_outro_pt1_start_loop_price;		// loop battle with opfor 1
	level.scr_anim[ "ally_0" ][ "outro_pt1_garcia_punch"	]		= %flood_outro_pt1_garcia_punch_price;		// price still fighting opfor 1
	level.scr_anim[ "ally_0" ][ "outro_pt1_garcia_kill_pt1" ]		= %flood_outro_pt1_garcia_kill_pt1_price;	// price saves player from garcia kill shot
	level.scr_anim[ "ally_0" ][ "outro_pt1_garcia_kill_pt2" ]		= %flood_outro_pt1_garcia_kill_pt2_price;	// price is visible for kill shot
	level.scr_anim[ "ally_0" ][ "outro_pt1_crash" ]					= %flood_outro_pt1_crash_price;				// heli crash
	//addNotetrack_customFunction( "ally_0", "price_death", maps\flood_ending::ending_price_gets_capped, "outro_pt1_garcia_kill_pt2" );


	// vargas, fights opfor 0, then switches to opfor 2, kills pilot( opfor 3 )
	level.scr_anim[ "ally_1" ][ "outro_pt1_start" ]					 = %flood_outro_pt1_start_vargas;			// get on
	level.scr_anim[ "ally_1" ][ "outro_pt1_start_loop_vargas" ][ 0 ] = %flood_outro_pt1_start_loop_vargas;		// loop battle with opfor 0
	level.scr_anim[ "ally_1" ][ "outro_pt1_melee_vargas" ]			 = %flood_outro_pt1_melee_vargas;			// switches to opfor 2
	level.scr_anim[ "ally_1" ][ "outro_pt1_pilot_kill"	 ]			 = %flood_outro_pt1_pilot_kill_vargas;		// kill pilot ( opfor 3 )
	level.scr_anim[ "ally_1" ][ "outro_pt1_crash" ]					 = %flood_outro_pt1_crash_vargas;			// crash

	// opfor 0, fights Vargas, then player, gets killed or kills player
	level.scr_anim[ "opfor_0" ][ "outro_pt1_breach" ]				  = %flood_outro_pt1_start_opfor01;
	level.scr_anim[ "opfor_0" ][ "outro_pt1_start" ]				  = %flood_outro_pt1_start_opfor01;			// get on
	level.scr_anim[ "opfor_0" ][ "outro_pt1_start_loop_vargas" ][ 0 ] = %flood_outro_pt1_start_loop_opfor01;	// loop battle with vargas
	level.scr_anim[ "opfor_0" ][ "outro_pt1_melee_player" ]			  = %flood_outro_pt1_melee_opfor01;			// switches to player
	level.scr_anim[ "opfor_0" ][ "outro_pt1_melee_win"	  ]			  = %flood_outro_pt1_melee_win_opfor01;		// opfor 0 dies
	level.scr_anim[ "opfor_0" ][ "outro_pt1_melee_fail"	  ]			  = %flood_outro_pt1_melee_fail_opfor01;	// opfor 0 kills player
	level.scr_anim[ "opfor_0" ][ "outro_pt1_garcia_punch" ]			  = %flood_outro_pt1_garcia_punch_opfor01;	// death of opfor 0

	// opfor 1, fight Price, then gets in garcia scuffle
	level.scr_anim[ "opfor_1" ][ "outro_pt1_breach" ]				  = %flood_outro_pt1_start_opfor02;
	level.scr_anim[ "opfor_1" ][ "outro_pt1_start" ]				 = %flood_outro_pt1_start_opfor02;			// get on
	level.scr_anim[ "opfor_1" ][ "outro_pt1_start_loop_price" ][ 0 ] = %flood_outro_pt1_start_loop_opfor02;		// loop battle with Price
	level.scr_anim[ "opfor_1" ][ "outro_pt1_garcia_punch" ]			 = %flood_outro_pt1_garcia_punch_opfor02;	// fighting still with price
	level.scr_anim[ "opfor_1" ][ "outro_pt1_garcia_kill_pt1" ]		 = %flood_outro_pt1_garcia_kill_pt1_opfor02;// gets knocked out
	level.scr_anim[ "opfor_1" ][ "outro_pt1_garcia_kill_pt2" ]		 = %flood_outro_pt1_garcia_kill_pt2_opfor02;// still there?
	level.scr_anim[ "opfor_1" ][ "outro_pt1_crash" ]				 = %flood_outro_pt1_crash_opfor02;			// crash

	// opfor 2, takes on vargas once player shows up, then gets in garcia scuffle
	level.scr_anim[ "opfor_2" ][ "outro_pt1_breach" ]		= %flood_outro_pt1_start_opfor03;
	level.scr_anim[ "opfor_2" ][ "outro_pt1_melee_vargas" ] = %flood_outro_pt1_melee_opfor03;					// fights vargas
	level.scr_anim[ "opfor_2" ][ "outro_pt1_pilot_kill"	  ] = %flood_outro_pt1_pilot_kill_opfor03;				// something when pilot dies

	// pilot is just around then gets killed by vargas
	level.scr_anim[ "opfor_3" ][ "outro_pt1_pilot_kill"		 ] = %flood_outro_pt1_pilot_kill_pilot;				// gets killed by vargas
	level.scr_anim[ "opfor_3" ][ "outro_pt1_garcia_kill_pt1" ] = %flood_outro_pt1_garcia_kill_pt1_pilot;		// auto pilot
	level.scr_anim[ "opfor_3" ][ "outro_pt1_garcia_kill_pt2" ] = %flood_outro_pt1_garcia_kill_pt2_pilot;		// more shots of this dead pilot
	level.scr_anim[ "opfor_3" ][ "outro_pt1_crash" ]		   = %flood_outro_pt1_crash_pilot;					// crash
	addNotetrack_customFunction( "opfor_3", "pilot_shot", ::outro_pt1_blood, "outro_pt1_pilot_kill" );


	// ending pt2
	level.scr_anim[ "generic"			 ][ "outro_pt2_start" ] = %flood_outro_pt2_start_garcia;

	level.scr_anim[ "ally_0" ] [ "outro_pt2_start"				 ] = %flood_outro_pt2_start_vargas;
	level.scr_anim[ "ally_0" ] [ "outro_pt2_save_vargas"		 ] = %flood_outro_pt2_save_vargas_vargas;
	level.scr_anim[ "ally_0" ] [ "outro_pt2_save_vargas_win_01"	 ] = %flood_outro_pt2_save_vargas_win_01_vargas;
	level.scr_anim[ "ally_0" ] [ "outro_pt2_save_vargas_win_02"	 ] = %flood_outro_pt2_save_vargas_win_02_vargas;
	level.scr_anim[ "ally_0" ] [ "outro_pt2_save_vargas_fail_01" ] = %flood_outro_pt2_save_vargas_fail_01_vargas;
	level.scr_anim[ "ally_0" ] [ "outro_pt2_save_vargas_fail_02" ] = %flood_outro_pt2_save_vargas_fail_02_vargas;
	level.scr_anim[ "ally_0" ] [ "outro_pt2_vargas_death"		 ] = %flood_outro_pt2_vargas_death_vargas;

	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_start"				] = %flood_outro_pt2_start_player_legs;
	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_start_fail"			] = %flood_outro_pt2_start_legs_fail;
	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_save_vargas"			] = %flood_outro_pt2_save_vargas_legs;
	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_vargas_death"		] = %flood_outro_pt2_vargas_death_legs;
	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_save_vargas_win_01"	] = %flood_outro_pt2_save_vargas_win_01_legs;
	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_save_vargas_fail_01" ] = %flood_outro_pt2_save_vargas_fail_01_legs;
	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_save_vargas_win_02"	] = %flood_outro_pt2_save_vargas_win_02_legs;
	level.scr_anim[ "outro_player_legs" ] [ "outro_pt2_save_vargas_fail_02" ] = %flood_outro_pt2_save_vargas_fail_02_legs;
}

stealth_generic_human()
{
	level.scr_anim[ "ally_0"				][ "stealth_kill_01" ]	   = %flood_stealthkill_01_ally1;
	level.scr_anim[ "stealth_enemy_flash"	][ "stealth_kill_01" ]	   = %flood_stealthkill_01_opfor1;
	level.scr_anim[ "stealth_enemy_debris"	][ "stealth_kill_01" ]	   = %flood_stealthkill_01_opfor2;
	level.scr_anim[ "stealth_enemy_3"		][ "stealth_kill_01" ]	   = %flood_stealthkill_01_opfor3;
	level.scr_anim[ "ally_0"			 ][ "stealth_kill_idle" ][ 0 ] = %flood_stealthkill_01_loop_02_ally1;

	addNotetrack_customFunction( "ally_0"  , "go_under_water"		, maps\flood_roof_stealth::enemy_start_vo, "stealth_kill_01" );
	addNotetrack_customFunction( "ally_0"  , "attach_script_hatchet", maps\flood_roof_stealth::give_hatchet	 , "stealth_kill_01" );
	addNotetrack_customFunction( "ally_0"  , "holdup"		  , maps\flood_roof_stealth::ally0_instruction_vo_holdup );
	addNotetrack_customFunction( "ally_0"  , "go_under_water2", maps\flood_roof_stealth::ally0_instruction_vo );
	
	level.scr_anim[ "stealth_enemy_flash"  ][ "stealth_kill_02" ] = %flood_stealthkill_02_opfor1;
	level.scr_anim[ "stealth_enemy_debris" ][ "stealth_kill_02" ] = %flood_stealthkill_02_opfor2;
	level.scr_anim[ "ally_0"			   ][ "stealth_kill_02" ] = %flood_stealthkill_02_ally1;
	
	level.scr_anim[ "stealth_enemy_flash" ][ "stealth_kill_02_idle" ][ 0 ]	   = %flood_stealthkill_02_opfor1_loop;
	level.scr_anim[ "stealth_enemy_flash" ][ "stealth_kill_02_into_idle2" ]	   = %flood_stealthkill_02_opfor1_into_loop;
	level.scr_anim[ "stealth_enemy_flash"  ] [ "stealth_kill_02_idle2" ] [ 0 ] = %flood_stealthkill_02_opfor1_loop2;
	level.scr_anim[ "stealth_enemy_debris" ] [ "stealth_kill_02_idle"  ] [ 0 ] = %flood_stealthkill_02_opfor2_loop;
	
	// This is separated out for the TFF system
	if ( level.start_point != "roof_stealth" )
	{
		level waittill( "swept_success" );
	}
	
							 //   animname 		     notetrack 						    function 									   
	addNotetrack_customFunction( "ally_0"		  , "start_ally1_bubbles"			 , maps\flood_fx::start_ally1_bubbles );
	addNotetrack_customFunction( "ally_0"		  , "start_ally1_submerge_bubbles"	 , maps\flood_fx::start_ally1_submerge_bubbles );
	addNotetrack_customFunction( "ally_0"		  , "start_ally1_submerge_bubbles"	 , maps\flood_fx::start_ally1_submerge_bubbles );
	addNotetrack_customFunction( "ally_0"		  , "fx_ally1_kill_upper_bubbles"	 , maps\flood_fx::fx_ally1_kill_upper_bubbles );
	addNotetrack_customFunction( "ally_0"		  , "fx_ally1_kill_tussle_bubbles_02", maps\flood_fx::fx_ally1_kill_tussle_bubbles_02 );
	addNotetrack_customFunction( "stealth_enemy_3", "fx_opfor3_tussle_bubbles"		 , maps\flood_fx::fx_opfor3_tussle_bubbles );
	addNotetrack_customFunction( "stealth_enemy_3", "fx_opfor3_pushdown_bubbles"	 , maps\flood_fx::fx_opfor3_pushdown_bubbles );
	
	//Diaz: Rook, grab a gun off of one of these guys.
	addNotetrack_dialogue( "ally_0", "ally_audioline_lookback", "stealth_kill_02", "flood_diz_grabagun" );
							 //   animname 			      notetrack 						   function 									    
	addNotetrack_customFunction( "stealth_enemy_flash" , "fx_stealthkill_02_blood_02"		, maps\flood_fx::fx_stealthkill_02_blood_02 );
	addNotetrack_customFunction( "stealth_enemy_debris", "fx_stealthkill_02_opfor2_blood_01", maps\flood_fx::fx_stealthkill_02_opfor2_blood_01 );
	addNotetrack_customFunction( "stealth_enemy_debris", "fx_stealthkill_02_opfor2_blood_02", maps\flood_fx::fx_stealthkill_02_opfor2_blood_02 );
	addNotetrack_customFunction( "ally_0"			   , "hatchet_face_1"					, maps\flood_fx::fx_hatchet_face_1 );
	addNotetrack_customFunction( "ally_0"			   , "detach_hatchet"					, maps\flood_roof_stealth::detach_hatchet );
}

rooftop1_generic_human()
{
	// This is separated out for the TFF system
	if ( level.start_point != "rooftops" )
	{
		flag_wait( "skybridge_done" );
	}

	addNotetrack_customFunction( "opfor_0", "killme", ::rooftops_heli_ropeladder_cleanup, "rooftops_heli_ropeladder" );
}
rooftop2_generic_human()
{
	// This is separated out for the TFF system
	if ( level.start_point != "rooftop_water" )
	{
		flag_wait( "rooftops_done" );
	}
	
	addNotetrack_customFunction( "opfor_0", "fire", maps\flood_rooftops::rooftops_water_reveal_shoot, "rooftops_water_reveal" );
	addNotetrack_customFunction( "ally_0", "gun_shot_01", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_0", "gun_shot_02", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_0", "gun_shot_03", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_1", "gun_shot_01", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_1", "gun_shot_02", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_1", "gun_shot_03", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_2", "gun_shot_01", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_2", "gun_shot_02", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );
	addNotetrack_customFunction( "ally_2", "gun_shot_03", maps\flood_rooftops::debrisbridge_combat_crossing, "debris_bridge_vign2_loc0" );

	addNotetrack_customFunction( "generic", "kick", ::notetrack_open_gate, "ending_door_kick" );
}

dialogue()
{
	// Tanks Nags
	//Price: Keep up with team!
	level.scr_sound[ "ally_0" ][ "flood_pri_keepupwithteam" ] = "flood_pri_keepupwithteam";
	//Vargas: Elias! Keep up!
	level.scr_sound[ "ally_1" ][ "flood_vrg_cmoneliaskeepup" ] = "flood_vrg_cmoneliaskeepup";
	//Merrick: Make a run for it!
	level.scr_sound[ "ally_1" ][ "flood_mrk_makearunfor" ] = "flood_mrk_makearunfor";	

	// M880 Ladder Nags
	//Vargas: Elias, take out the driver!
	level.scr_sound[ "ally_0" ][ "flood_vrg_eliastakeoutthe" ] = "flood_vrg_eliastakeoutthe";
	//Vargas: The driver's still alive! Take him out now!
	level.scr_sound[ "ally_0" ][ "flood_vrg_thedriversstillalive" ] = "flood_vrg_thedriversstillalive";
	//Vargas: Elias! Stop the Missile Truck! Right Side!
	level.scr_sound[ "ally_0" ][ "flood_vrg_eliasstopthemissile" ] = "flood_vrg_eliasstopthemissile";
	//Vargas: There's a ladder on the right side!
	level.scr_sound[ "ally_0" ][ "flood_vrg_theresaladderon" ] = "flood_vrg_theresaladderon";	
		
	// Dam Break Nags
	//Price: We got you covered! Just take out the launcher!
	level.scr_sound[ "ally_0" ][ "flood_bkr_gotyoucovered" ] = "flood_bkr_gotyoucovered";
	//Price: Take that launcher out now!
	level.scr_sound[ "ally_0" ][ "flood_bkr_takelauncherout" ] = "flood_bkr_takelauncherout";
	//Price: Stop the launch!
	level.scr_sound[ "ally_0" ][ "flood_bkr_stopsequence" ] = "flood_bkr_stopsequence";
	
	// escaping the crazy flood water
	//Price: We've got to get off the street!
	level.scr_sound[ "ally_0" ][ "flood_bkr_getoffstreet" ] = "flood_bkr_getoffstreet";
	//Merrick: Let's move it, Elias!
	level.scr_sound[ "ally_2" ][ "flood_kgn_letsmoveit" ] = "flood_kgn_letsmoveit";
	//Vargas: It's the flood waters! We need to move!
	level.scr_sound[ "ally_1" ][ "flood_diz_floodwaters" ] = "flood_diz_floodwaters";
	
	// start nag lines
	//Price: Move, Elias!
	level.scr_sound[ "ally_0" ][ "flood_bkr_moverook"		 ] = "flood_bkr_moverook";
	//Price: Keep moving!
	level.scr_sound[ "ally_0" ][ "flood_bkr_keepmoving"		 ] = "flood_bkr_keepmoving";
	//Price: Pick up the pace, Elias!
	level.scr_sound[ "ally_0" ][ "flood_bkr_pickuppace"		 ] = "flood_bkr_pickuppace";
	
	// you catch up
	//Price: Down the alley!
	level.scr_sound[ "ally_1" ][ "flood_bkr_downthealley" ] = "flood_bkr_downthealley";
	//Merrick: The water's right on our tail!
	level.scr_sound[ "ally_2" ][ "flood_kgn_onourtail"	 ] = "flood_kgn_onourtail";
	
	//Price: Dead end!
	level.scr_sound[ "ally_1" ][ "flood_kgn_weretrapped"	 ] = "flood_kgn_weretrapped";

	// kick door down
	//Vargas: In here!
	level.scr_sound[ "ally_0" ][ "flood_diz_inhere"			 ] = "flood_diz_inhere";
	
	// running inside
	//Price: We're not safe here! We've got to make it to higher ground.
	level.scr_sound[ "ally_0" ][ "flood_bkr_notsafehere"	 ] = "flood_bkr_notsafehere";
	//Vargas: Don't stop running, Elias!
	level.scr_sound[ "ally_1" ][ "flood_diz_dontstoprunning" ] = "flood_diz_dontstoprunning";
	//Merrick: Keep moving!
	level.scr_sound[ "ally_2" ][ "flood_kgn_keepmoving2" ] = "flood_kgn_keepmoving2";

	//Price: Up the stairs!
	level.scr_sound[ "ally_0" ][ "flood_bkr_upthestairs"	 ] = "flood_bkr_upthestairs";
	
	//Price: Everyone catch your breath.
	level.scr_sound[ "ally_0" ][ "flood_bkr_catchyourbreath" ] = "flood_bkr_catchyourbreath";

	/*
	//Price: Gamma 1, this is Ghost Team. What's your location? Over.
	level.scr_sound[ "ally_0" ][ "flood_bkr_gamma1thisis" ] = "flood_bkr_gamma1thisis";
	//Price: Gamma 1, do you read?
	level.scr_sound[ "ally_0" ][ "flood_bkr_gamma1doyou" ] = "flood_bkr_gamma1doyou";
	//Vargas: Garcia set a trap, and you walked us right into it.
	level.scr_sound[ "ally_1" ][ "flood_vrg_laughingunderhisbreath" ] = "flood_vrg_laughingunderhisbreath";
	//Price: We're still going after Garcia.  If you have a problem with that, maybe it's time you find a new line of work.
	level.scr_sound[ "ally_0" ][ "flood_pri_youthinkthisis" ] = "flood_pri_youthinkthisis";
	//Vargas: Maybe it's time this team found a new commander.
	level.scr_sound[ "ally_1" ][ "flood_vrg_noithinkgarcia" ] = "flood_vrg_noithinkgarcia";
	//Price: We'll deal with this later.
	level.scr_sound[ "ally_0" ][ "flood_pri_wellwerenotdone" ] = "flood_pri_wellwerenotdone";
	//Vargas: What are you talking about?
	level.scr_sound[ "ally_1" ][ "flood_vrg_whatareyoutalking" ] = "flood_vrg_whatareyoutalking";
	//Price: We're alive, so Garcia is still going to die.
	level.scr_sound[ "ally_0" ][ "flood_pri_werealivesogarcia" ] = "flood_pri_werealivesogarcia";
	//Vargas: He'd already be dead, if I was in charge.
	level.scr_sound[ "ally_1" ][ "flood_vrg_hedalreadybedead" ] = "flood_vrg_hedalreadybedead";
	//Price: Fall in! We are finishing this mission!
	level.scr_sound[ "ally_0" ][ "flood_pri_fallinweare" ] = "flood_pri_fallinweare";
	*/

	//Vargas: Commentary, Lieutenant.
	level.scr_sound[ "ally_0" ][ "flood_vrg_commentarylieutenant" ] = "flood_vrg_commentarylieutenant";
	//Merrick: I think it's bad, sir.
	level.scr_sound[ "ally_1" ][ "flood_mrk_ithinkitsbad" ] = "flood_mrk_ithinkitsbad";
	//Vargas: Run of the mill bad or holy-shit-I-can't-believe-that-just-happened bad?
	level.scr_sound[ "ally_0" ][ "flood_vrg_runofthemill" ] = "flood_vrg_runofthemill";
	//Merrick: Holy-shit-I-can't-believe-that-just-happened, sir.
	level.scr_sound[ "ally_1" ][ "flood_mrk_sir" ] = "flood_mrk_sir";
	//Vargas: That would be 'Sit-Rep confirmed.'
	level.scr_sound[ "ally_0" ][ "flood_vrg_thatwouldbesitrep" ] = "flood_vrg_thatwouldbesitrep";
	//Merrick: Sit-rep confirmed, sir.
	level.scr_sound[ "ally_1" ][ "flood_mrk_sitrepconfirmedsir" ] = "flood_mrk_sitrepconfirmedsir";
	//Merrick: What kind of man floods his own city?
	level.scr_sound[ "ally_1" ][ "flood_mrk_whatkindofman" ] = "flood_mrk_whatkindofman";
	//Vargas: A man who won't surrender.
	level.scr_sound[ "ally_0" ][ "flood_vrg_amanwhowont" ] = "flood_vrg_amanwhowont";
	//Oldboy: This place isn't gonna hold much longer.
	level.scr_sound[ "ally_2" ][ "flood_bkr_thisplaceisntgonna" ] = "flood_bkr_thisplaceisntgonna";
	//Vargas: It's hot out there.
	level.scr_sound[ "ally_0" ][ "flood_vrg_itshotoutthere" ] = "flood_vrg_itshotoutthere";
	//Vargas: Any objections to finishing up our mission?
	level.scr_sound[ "ally_0" ][ "flood_vrg_anyobjectionstofinishing" ] = "flood_vrg_anyobjectionstofinishing";
	//Vargas: All right, let's go get this sonofabitch.
	level.scr_sound[ "ally_0" ][ "flood_vrg_allrightletsgo" ] = "flood_vrg_allrightletsgo";
	
	// MALL SPANISH VO
	//Venezuelan Soldier 2: We lose anyone to that big wave?
	level.scr_sound[ "opfor_1" ][ "flood_vs2_weloseanyoneto"	 ] = "flood_vs2_weloseanyoneto";
	//Venezuelan Soldier 4: Everyone's accounted for, sir.
	level.scr_sound[ "opfor_1" ][ "flood_vs4_everyonesaccountedforsir"	 ] = "flood_vs4_everyonesaccountedforsir";
	//Venezuelan Soldier 3: The report said we will be getting helicopter extraction as soon as they can provide it.
	level.scr_sound[ "opfor_1" ][ "flood_vs3_thereportsaidwe"	 ] = "flood_vs3_thereportsaidwe";
	//Venezuelan Soldier 3: Since this was a last minute move, it's going to take some time to get enough helicopters in the air.
	level.scr_sound[ "opfor_1" ][ "flood_vs3_sincethiswasa"	 ] = "flood_vs3_sincethiswasa";
	//Venezuelan Soldier 2: Start prepping the landing zone.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_startpreppingthelanding"	 ] = "flood_vs2_startpreppingthelanding";
	//Venezuelan Soldier 2: Get the supplies together. Prioritize what's worth salvaging.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_getthesuppliestogether"	 ] = "flood_vs2_getthesuppliestogether";
	//Venezuelan Soldier 2: Keep an eye out for any Americans.  Some of them may have already gotten to high ground before the dam broke.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_keepaneyeout"	 ] = "flood_vs2_keepaneyeout";
	//Venezuelan Soldier 3: Make sure you have a full loadout before we leave. We might encounter resistant during the flight out.
	level.scr_sound[ "opfor_1" ][ "flood_vs3_makesureyouhave"	 ] = "flood_vs3_makesureyouhave";
	//Venezuelan Soldier 1: Did you hear that?
	level.scr_sound[ "opfor_1" ][ "flood_vs1_didyouhearthat"	 ] = "flood_vs1_didyouhearthat";
	//Venezuelan Soldier 4: I can barely hear anything over the water.
	level.scr_sound[ "opfor_1" ][ "flood_vs4_icanbarelyhear"	 ] = "flood_vs4_icanbarelyhear";
	//Venezuelan Soldier 5: The water jammed up my gun. Can someone toss me a dry weapon?
	level.scr_sound[ "opfor_1" ][ "flood_vs5_thewaterjammedup"	 ] = "flood_vs5_thewaterjammedup";
	//Venezuelan Soldier 1: I can't believe they actually gave that order.
	level.scr_sound[ "opfor_1" ][ "flood_vs1_icantbelievethey"	 ] = "flood_vs1_icantbelievethey";
	
	// MALL SPANISH VO POST QUAKE
	//Venezuelan Soldier 2: Everyone check your equipment.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_everyonecheckyour"	 ] = "flood_vs2_everyonecheckyour";
	//Venezuelan Soldier 2: Jimenez, Ramos, Garcia! Check the south side of the building.  See if it's any more stable.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_jimenezramosgarciacheck"	 ] = "flood_vs2_jimenezramosgarciacheck";
	//Venezuelan Soldier 1: On it!
	level.scr_sound[ "opfor_1" ][ "flood_vs1_onit"	 ] = "flood_vs1_onit";
	//Venezuelan Soldier 2: How much longer for that helicopter?
	level.scr_sound[ "opfor_1" ][ "flood_vs2_howmuchlongerfor"	 ] = "flood_vs2_howmuchlongerfor";
	//Venezuelan Soldier 3: 5 minutes!
	level.scr_sound[ "opfor_1" ][ "flood_vs3_5minutes"	 ] = "flood_vs3_5minutes";
	//Venezuelan Soldier 2: We might not be here in 5 minutes.  We need that helicopter now!
	level.scr_sound[ "opfor_1" ][ "flood_vs2_wemightnotbe"	 ] = "flood_vs2_wemightnotbe";
	//Venezuelan Soldier 2: Make sure they understand our status.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_makesuretheyunderstand"	 ] = "flood_vs2_makesuretheyunderstand";
	//Venezuelan Soldier 2: Rodriguez, I need you to keep an eye out for…
	level.scr_sound[ "opfor_1" ][ "flood_vs2_rodriguezineedyou"	 ] = "flood_vs2_rodriguezineedyou";
	//Venezuelan Soldier 4: I'm a bit busy over here, sir.
	level.scr_sound[ "opfor_1" ][ "flood_vs4_imabitbusy"	 ] = "flood_vs4_imabitbusy";
	//Venezuelan Soldier 2: Hurry up and pull Pinto out of that hole.  We need to make sure we're ready for extraction.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_hurryupandpull"	 ] = "flood_vs2_hurryupandpull";
	//Venezuelan Soldier 2: Sanchez and Castillo! Make sure we still have a secured landing zone for the helicopter!
	level.scr_sound[ "opfor_1" ][ "flood_vs2_sanchezandcastillomake"	 ] = "flood_vs2_sanchezandcastillomake";
	//Venezuelan Soldier 2: I don't want anything keeping us from getting out of here.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_idontwantanything"	 ] = "flood_vs2_idontwantanything";
	//Venezuelan Soldier 6: Yes, sir!
	level.scr_sound[ "opfor_1" ][ "flood_vs6_yessir"	 ] = "flood_vs6_yessir";
	//Venezuelan Soldier 2: Any update on that helicopter.
	level.scr_sound[ "opfor_1" ][ "flood_vs2_anyupdateonthat"	 ] = "flood_vs2_anyupdateonthat";
	//Venezuelan Soldier 3: The operator's are overwhelmed.  I can't get any type of real response.
	level.scr_sound[ "opfor_1" ][ "flood_vs3_theoperatorsare"	 ] = "flood_vs3_theoperatorsare";
	//Venezuelan Soldier 2: Anyone seeing a safe way off of this roof, if we can't get a helicopter?
	level.scr_sound[ "opfor_1" ][ "flood_vs2_anyoneseeingasafe"	 ] = "flood_vs2_anyoneseeingasafe";
	//Venezuelan Soldier 2: How're things looking on the south side?
	level.scr_sound[ "opfor_1" ][ "flood_vs2_howrethingslookingon"	 ] = "flood_vs2_howrethingslookingon";
	//Venezuelan Soldier 6: It feels like the roof is starting to shift.
	level.scr_sound[ "opfor_1" ][ "flood_vs6_itfeelslikethe"	 ] = "flood_vs6_itfeelslikethe";

	//Venezuelan Soldier 4: Hold On!
	level.scr_sound[ "opfor_1" ][ "flood_vs4_holdon"		 ] = "flood_vs4_holdon";
	//Venezuelan Soldier 5: I am holding on!
	level.scr_sound[ "opfor_2" ][ "flood_vs5_holdingon"		 ] = "flood_vs5_holdingon";
	//Venezuelan Soldier 5: Pull me up!
	level.scr_sound[ "opfor_2" ][ "flood_vs5_pullmeup"		 ] = "flood_vs5_pullmeup";
	//Venezuelan Soldier 4: I can't get any leverage!
	level.scr_sound[ "opfor_1" ][ "flood_vs4_getanyleverage" ] = "flood_vs4_getanyleverage";
	//Venezuelan Soldier 5: I'm slipping! I'm slipping!
	level.scr_sound[ "opfor_2" ][ "flood_vs5_imslipping"	 ] = "flood_vs5_imslipping";
	
	//Venezuelan Soldier 2: Americans!
	level.scr_sound[ "generic" ][ "flood_vz2_americans"		 ] = "flood_vz2_americans";
	//Venezuelan Soldier 2: We're not alone up here!
	level.scr_sound[ "generic" ][ "flood_vz2_notalone"		 ] = "flood_vz2_notalone";

	// at the mall door
	//Price: Guns ready.
	level.scr_sound[ "ally_0" ][ "flood_diz_gunsready"		 ] = "flood_diz_gunsready";
	//Vargas: At least five tangos. 10 meters.
	level.scr_sound[ "ally_1" ][ "flood_diz_tangosoutthere" ] = "flood_diz_tangosoutthere";
	//Price: Stay alert.
	level.scr_sound[ "ally_1" ][ "flood_diz_staylowandquiet" ] = "flood_diz_staylowandquiet";
	
	// nags for the mall door breach
	//Price: Get out there, Elias.
	level.scr_sound[ "ally_1" ][ "flood_diz_outthererook" ] = "flood_bkr_outthererook";
	//Baker: Get moving or we'll be spotted.
	level.scr_sound[ "ally_1" ][ "flood_diz_bespotted" ] = "flood_bkr_bespotted";
	
	//on roof, telling player to break stealth
	//Price: Go hot on Elias's mark.
	level.scr_radio[ "flood_bkr_hotonrooksmark" ] = "flood_bkr_hotonrooksmark";
	//Price: We can get the jump on them.
	level.scr_radio[ "flood_bkr_thejump" ] = "flood_bkr_thejump";
	
	// player dumb, allies breaking stealth
	//Baker: We can't wait any longer.
	level.scr_radio[ "flood_bkr_cantwait" ] = "flood_bkr_cantwait";
	//Baker: Weapons Free!
	level.scr_sound[ "ally_0" ][ "flood_bkr_weaponsfree" ] = "flood_bkr_weaponsfree";
	
	//Price: They've spotted us! Return Fire!
	level.scr_sound[ "ally_0" ][ "flood_bkr_spottedus" ] = "flood_bkr_spottedus";

	//Vargas: This roof isn't holding together!
	level.scr_sound[ "ally_1" ][ "flood_kgn_keepmoving"		 ] = "flood_kgn_keepmoving";
	//Merrick: What do you want to do about it? We're getting shot at!
	level.scr_sound[ "ally_2" ][ "flood_diz_gettingshotat"	 ] = "flood_diz_gettingshotat";
	//Price: Just keep engaging targets!
	level.scr_sound[ "ally_0" ][ "flood_diz_engagingtargets" ] = "flood_diz_engagingtargets";
	
	//Merrick: Half the roof's gone!
	level.scr_sound[ "ally_2" ][ "flood_mrk_halftheroofsgone" ] = "flood_mrk_halftheroofsgone";
	//Price: Well, I hope you can swim!
	level.scr_sound[ "ally_0" ][ "flood_pri_wellihopeyou" ] = "flood_pri_wellihopeyou";
	
	//Vargas: Walker!
	level.scr_sound[ "ally_0" ][ "flood_vrg_walker" ] = "flood_vrg_walker";
	//Vargas: Hold On!
	level.scr_sound[ "ally_0" ][ "flood_vrg_holdon" ] = "flood_vrg_holdon";
	//Vargas: I got ya!
	level.scr_sound[ "ally_0" ][ "flood_vrg_eliasigotcha" ] = "flood_vrg_eliasigotcha";
	//Vargas: Grab my hand, Walker!
	level.scr_sound[ "ally_0" ][ "flood_vrg_grabmyhandwalker" ] = "flood_vrg_grabmyhandwalker";
	
	//Vargas: Follow my lea-- SHIT! Get down!
	level.scr_sound[ "ally_0" ][ "flood_vrg_theyrecomingthisway" ] = "flood_vrg_theyrecomingthisway";
	//Vargas: Follow my lea-- SHIT! Get down!
	level.scr_radio[ "flood_vrg_folowmyleashit" ] = "flood_vrg_folowmyleashit";
	
	//Venezuelan Soldier 8: Duarte, check in there.
	level.scr_sound[ "stealth_enemy_flash" ][ "flood_vs8_duartecheckinthere"	 ] = "flood_vs8_duartecheckinthere";
	//Venezuelan Soldier 7: Yes, sir.
	level.scr_sound[ "stealth_enemy_3" ][ "flood_vs7_yessir"	 ] = "flood_vs7_yessir";
	//Venezuelan Soldier 8: Castillo, you're with me.
	level.scr_sound[ "stealth_enemy_flash" ][ "flood_vs8_castilloyourewithme"	 ] = "flood_vs8_castilloyourewithme";
	//Venezuelan Soldier 9: What's that up ahead?
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_whatsthatupahead"	 ] = "flood_vs9_whatsthatupahead";
	//Venezuelan Soldier 8: I think that's another doorway.
	level.scr_sound[ "stealth_enemy_flash" ][ "flood_vs8_ithinkthatsanother"	 ] = "flood_vs8_ithinkthatsanother";
	//Venezuelan Soldier 8: Castillo, try and clear out that rubble.
	level.scr_sound[ "stealth_enemy_flash" ][ "flood_vs8_castillotryandclear"	 ] = "flood_vs8_castillotryandclear";
	//Venezuelan Soldier 9: Could I get some light on this, Cortez?
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_couldigetsome"	 ] = "flood_vs9_couldigetsome";
	//Venezuelan Soldier 8: Sure.
	level.scr_sound[ "stealth_enemy_flash" ][ "flood_vs8_sure"	 ] = "flood_vs8_sure";
	
	// Discussion at the debris
	//Venezuelan Soldier 9: I just can’t get through here.
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_getthrough"	 ] = "flood_vs9_getthrough";
	//Venezuelan Soldier 8: Don't give up! Keep trying.
	level.scr_sound[ "stealth_enemy_flash"	 ][ "flood_vs8_dontgiveup"	 ] = "flood_vs8_dontgiveup";
	//Venezuelan Soldier 9: Can you help me with this?
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_makingprogress" ] = "flood_vs9_makingprogress";
	//Venezuelan Soldier 9: I can't get a good grip.
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_goodgrip"		 ] = "flood_vs9_goodgrip";
	//Venezuelan Soldier 9: But keep the light steady!
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_lightsteady"	 ] = "flood_vs9_lightsteady";
	//Venezuelan Soldier 8: Do you want me to help of keep the light steady?
	level.scr_sound[ "stealth_enemy_flash"	 ][ "flood_vs8_keepthelight"	 ] = "flood_vs8_keepthelight";
	//Venezuelan Soldier 9: Fine, just keep is steady.
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_finejustkeep"	 ] = "flood_vs9_finejustkeep";
	//Venezuelan Soldier 8: I  haven't heard anything from Duarte in a bit. Do you think something happened to him?
	level.scr_sound[ "stealth_enemy_flash"	 ][ "flood_vs8_thinksomething" ] = "flood_vs8_thinksomething";
	//Venezuelan Soldier 9: Cortez! The light!
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vs9_thelight"		 ] = "flood_vs9_thelight";
	//Venezuelan Soldier 8: Oh, right.
	level.scr_sound[ "stealth_enemy_flash"	 ][ "flood_vs8_ohright"		 ] = "flood_vs8_ohright";

	//Vargas: They spotted you!
	level.scr_sound[ "ally_0" ][ "flood_diz_theyseeyou"			 ] = "flood_diz_theyseeyou";
	//Venezuelan Soldier 8: There's Americans in here!
	level.scr_sound[ "stealth_enemy_flash" ][ "flood_vz8_americanshere"			 ] = "flood_vz8_americanshere";
	//Venezuelan Soldier 9: There's Americans in here!
	level.scr_sound[ "stealth_enemy_debris" ][ "flood_vz9_americanshere"			 ] = "flood_vz9_americanshere";

	//Vargas: This will be useful.
	level.scr_sound[ "ally_0" ][ "flood_vrg_thiswillbeuseful"		 ] = "flood_vrg_thiswillbeuseful";
	//Vargas: Hold up.
	level.scr_sound[ "ally_0" ][ "flood_vrg_holdup"		 ] = "flood_vrg_holdup";
	// RADIO
	//Vargas: Hold up.
	level.scr_radio[ "flood_vrg_holdup_2"		 ] = "flood_vrg_holdup_2";
	
	//Vargas: Only two more up ahead. You go straight, I'll flank around.
	level.scr_sound[ "ally_0" ][ "flood_diz_yougoleft"			 ] = "flood_diz_yougoleft";
	// RADIO
	//Vargas: Only two more up ahead. You go straight, I'll flank around.
	level.scr_radio[ "flood_vrg_onlytwomoreup"			 ] = "flood_vrg_onlytwomoreup";
	
	// RADIO
	//Vargas: We'll take them out on your mark.
	level.scr_radio[ "flood_vrg_welltakethemout"			 ] = "flood_vrg_welltakethemout";

	//Vargas: Get below the water to sneak up on them.
	level.scr_sound[ "ally_0" ][ "flood_diz_getbelow"			 ] = "flood_diz_getbelow";
	//Vargas: Go underwater and we'll get the jump on them.
	level.scr_sound[ "ally_0" ][ "flood_diz_gounderwater"		 ] = "flood_diz_gounderwater";

	// RADIO
	//Vargas: Get below the water and sneak up on them.
	level.scr_radio[ "flood_vrg_getbelowthewater"			 ] = "flood_vrg_getbelowthewater";
	// RADIO
	//Vargas: Go underwater and we'll get the jump on them.
	level.scr_radio[ "flood_vrg_gounderwaterandwell"		 ] = "flood_vrg_gounderwaterandwell";
	
	// only using this one because the other one is too long
	//Diaz: Rook, grab a gun off of one of these guys.
	level.scr_sound[ "ally_0" ][ "flood_diz_grabagun" ] = "flood_diz_grabagun";
	
	//Price: Garcia's got to be in here.
	level.scr_sound[ "ally_0" ][ "flood_pri_garciasgottobe" ] = "flood_pri_garciasgottobe";
	
	//Merrick: What?...  Are?,,, Are these civilians?
	level.scr_sound[ "ally_2" ][ "flood_mrk_whatarearethese" ] = "flood_mrk_whatarearethese";
	//Price: We'll deal with that later! We gotta get Garcia!
	level.scr_sound[ "ally_2" ][ "flood_pri_welldealwiththat" ] = "flood_pri_welldealwiththat";

	
	// skybridge
	//Vargas: Priority one is surviving. Let's get to higher ground.
	level.scr_sound[ "ally_1" ][ "flood_diz_stabelground" ] = "flood_diz_stabelground";
	//Vargas: It looks like this is the only way to go.
	level.scr_sound[ "ally_1" ][ "flood_diz_onlywaytogo" ] = "flood_diz_onlywaytogo";
	//Vargas: It's barely holding together!
	level.scr_sound[ "ally_1" ][ "flood_diz_barelyholding" ] = "flood_diz_barelyholding";
	//Vargas: Keep moving!
	level.scr_sound[ "ally_1" ][ "flood_diz_keepmoving2" ] = "flood_diz_keepmoving2";
	//Vargas: Get across the bridge!
	level.scr_sound[ "ally_1" ][ "flood_diz_rightforus"	 ] = "flood_diz_rightforus";
	//Vargas: Hurry!
	level.scr_sound[ "ally_1" ][ "flood_diz_hurry"		 ] = "flood_diz_hurry";


	// rooftops A
	//Venezuelan Soldier 10: This can't be worth it.
	level.scr_sound[ "generic" ][ "flood_vs10_hearme"		 ] = "flood_vs10_hearme";
	//Venezuelan Soldier 11: The commander says we need to download this data before we leave the city.
	level.scr_sound[ "generic" ][ "flood_vz11_downloaddata"	 ] = "flood_vz11_downloaddata";
	//Venezuelan Soldier 10: But the building is barely standing.
	level.scr_sound[ "generic" ][ "flood_vs10_priorityalert" ] = "flood_vs10_priorityalert";
	//Venezuelan Soldier 11: We have our orders.
	level.scr_sound[ "generic" ][ "flood_vs11_rewire"		 ] = "flood_vs11_rewire";
	//Venezuelan Soldier 10: So?  The whole wall is gone.
	level.scr_sound[ "generic" ][ "flood_vs10_setupfine"	 ] = "flood_vs10_setupfine";
	//Venezuelan Soldier 11: If you want to go upstairs and argue with the commander, be my guest.
	level.scr_sound[ "generic" ][ "flood_vz11_goargue"		 ] = "flood_vz11_goargue";
	//Venezuelan Soldier 11: Enemies!
	level.scr_sound[ "generic" ][ "flood_vz11_enemies"		 ] = "flood_vz11_enemies";
	//Venezuelan Soldier 12: Get to your guns! The enemies are here!
	level.scr_sound[ "generic" ][ "flood_vz12_getguns"		 ] = "flood_vz12_getguns";
	//Vargas: Grab a gun. We've got hostiles ahead.
	level.scr_sound[ "ally_1" ][ "flood_diz_hostileahead"	 ] = "flood_diz_hostileahead";
	//Vargas: Hold up.
	level.scr_sound[ "ally_1" ][ "flood_diz_holdup"			 ] = "flood_diz_holdup";
	//Vargas: We'll go hot on your mark.
	level.scr_sound[ "ally_1" ][ "flood_diz_gohotmark"		 ] = "flood_diz_gohotmark";
	//Vargas: Up the stairs!
	level.scr_sound[ "ally_1" ][ "flood_diz_upthestairs2"	 ] = "flood_diz_upthestairs2";
	//Vargas: Clear! .. Hold up. Let me try and…
	level.scr_sound[ "ally_1" ][ "flood_diz_getsomebearings" ] = "flood_diz_getsomebearings";
	//Vargas: Let's go!
	level.scr_sound[ "ally_0" ][ "flood_diz_gethimselfkilled" ] = "flood_diz_gethimselfkilled";
	//Price: This Ghost zero-one.  If there's anyone on this frequency, sound off now. Over.  I repeat this is Ghost zero-one, requesting support. Over.
	level.scr_radio[ "flood_pri_thisghostzerooneif" ] = "flood_pri_thisghostzerooneif";
	//Price: Vargas? We're under heavy fire! Make you way to the building just West of the Hotel!
	level.scr_radio[ "flood_pri_vargaswereunderheavy" ] = "flood_pri_vargaswereunderheavy";
	//Price: Just follow your damn orders!
	level.scr_radio[ "flood_pri_justfollowyourdamn" ] = "flood_pri_justfollowyourdamn";


	// rooftops A to B
	//Vargas: Elias drop down.
	level.scr_sound[ "ally_0" ][ "flood_diz_dropdown"		 ] = "flood_diz_dropdown";
	//Vargas: Jump the gap.
	level.scr_sound[ "ally_0" ][ "flood_diz_jumpthegap"		 ] = "flood_diz_jumpthegap";
	//Diaz: Keep moving.
	level.scr_sound[ "ally_0" ][ "flood_diz_keepmoving3"	 ] = "flood_diz_keepmoving3";


	// rooftops B
	//Vargas: Elias, down here!
	level.scr_sound[ "ally_0" ][ "flood_vrg_downhereelias"			 ]	= "flood_vrg_downhereelias";
	//Vargas: Get down here, Elias!
	level.scr_sound[ "ally_0" ][ "flood_diz_getdownhere"			 ]	= "flood_diz_getdownhere";
	//Vargas: Elias, get down here! I need support!
	level.scr_sound[ "ally_0" ][ "flood_diz_getdownhereneedsupport" ]	= "flood_diz_getdownhereneedsupport";
	//Vargas: Price, I think we hear you.
	level.scr_sound[ "ally_0" ][ "flood_diz_cominginfromabove"		 ]	= "flood_diz_cominginfromabove";
	//Vargas: Coming in from above.
	level.scr_sound[ "ally_0" ][ "flood_diz_infromabove"			 ]	= "flood_diz_infromabove";



	// use water as cover
	//Vargas: Use the water for cover.
	level.scr_sound[ "ally_0" ][ "flood_diz_usethewater"		 ] = "flood_diz_usethewater";


	// flankers
	//Diaz: They're flanking us. Watch your three!
	level.scr_sound[ "ally_0" ][ "flood_diz_flankingus" ] = "flood_diz_flankingus";


	// debrisbridge
	//Merrick: It's barely staying together.
	level.scr_sound[ "ally_2" ][ "flood_kgn_barelystaying"			 ] = "flood_kgn_barelystaying";
	//Price: Elias, drop down here!
	level.scr_sound[ "ally_0" ][ "flood_bkr_dropdownhere"			 ] = "flood_bkr_dropdownhere";
	//Merrick: Elias, we need support down here!
	level.scr_sound[ "ally_2" ][ "flood_kgn_needsupport"			 ] = "flood_kgn_needsupport";
	
	// debirsbridge to garage
	//Price: Watch your footing.
	level.scr_sound[ "ally_1" ][ "flood_diz_watchyourfooting"		 ] = "flood_diz_watchyourfooting";
	//Price: Elias, you've got to get across now!
	level.scr_sound[ "ally_2" ][ "flood_diz_getacrossnow"			 ] = "flood_diz_getacrossnow";
}

	
#using_animtree( "script_model" );
script_models()
{	
//	level.scr_animtree[ "player_weapon" ]						= #animtree;
//	level.scr_model[ "player_weapon" ]							= "acr_reflex";

	//Infil
//	level.scr_animtree[ "heli_01_gunner_turret" ] = #animtree;
//	level.scr_anim[ "heli_01_gunner_turret" ][ "infil" ] = %flood_infil_heli_01_gunner_turret;
//	level.scr_model[ "heli_01_gunner_turret" ] = "weapon_blackhawk_minigun_viewmodel";
//	
//	level.scr_animtree[ "heli_02_gunner_turret_01" ] = #animtree;
//	level.scr_anim[ "heli_02_gunner_turret_01" ][ "infil" ] = %flood_infil_heli_02_gunner_turret_01;
//	level.scr_model[ "heli_02_gunner_turret_01" ] = "weapon_blackhawk_minigun_viewmodel";
//
//	level.scr_animtree[ "heli_02_gunner_turret_02" ] = #animtree;
//	level.scr_anim[ "heli_02_gunner_turret_02" ][ "infil" ] = %flood_infil_heli_02_gunner_turret_02;
//	level.scr_model[ "heli_02_gunner_turret_02" ] = "weapon_blackhawk_minigun_viewmodel";
	
//	addNotetrack_customFunction( "breach_player_rig", "kick_door"	  , maps\flood_chopper::open_church_doors, "lowtech_breach" );
//	addNotetrack_customFunction( "breach_player_rig", "weapon_pullout", maps\flood_chopper::church_weapon_pullout, "lowtech_breach" );
	
	// stop sign
	level.scr_animtree[ "flood_stop_sign_01" ] = #animtree;
	level.scr_anim[ "flood_stop_sign_01" ][ "street_stop_sign_01" ] = %flood_streets_stop_sign;
	level.scr_model[ "flood_stop_sign_01" ] = "flood_stop_sign";
	
	// lynx smash
	level.scr_animtree[ "lynx_smash" ]			   = #animtree;
	level.scr_anim[ "lynx_smash" ][ "lynx_smash" ] = %flood_tank_battle_lynx_smash_lynx;
	level.scr_model[ "lynx_smash" ]				   = "flood_smashed_lynx";

	level.scr_animtree[ "lynx_smash_debris" ]			  = #animtree;
	level.scr_anim[ "lynx_smash_debris" ][ "lynx_smash" ] = %flood_tank_battle_lynx_smash_wall;
	level.scr_model[ "lynx_smash_debris" ]				  = "flood_convoy_debris_lynx";

	// window smash
	level.scr_animtree[ "flood_tank_battle_barrier_01" ]			  = #animtree;
	level.scr_anim[ "flood_tank_battle_barrier_01" ][ "tank_window" ] = %flood_tank_battle_window_barrier_01;
	level.scr_model[ "flood_tank_battle_barrier_01" ]				  = "flood_tank_battle_barrier_01";

	level.scr_animtree[ "flood_tank_battle_barrier_02" ]			  = #animtree;
	level.scr_anim[ "flood_tank_battle_barrier_02" ][ "tank_window" ] = %flood_tank_battle_window_barrier_02;
	level.scr_model[ "flood_tank_battle_barrier_02" ]				  = "flood_tank_battle_barrier_02";

	level.scr_animtree[ "flood_tank_battle_window_frame" ]				= #animtree;
	level.scr_anim[ "flood_tank_battle_window_frame" ][ "tank_window" ] = %flood_tank_battle_window_windowframe;
	level.scr_model[ "flood_tank_battle_window_frame" ]					= "flood_tank_battle_window_frame";

	level.scr_animtree[ "flood_tank_battle_tankdebris" ]			  = #animtree;
	level.scr_anim[ "flood_tank_battle_tankdebris" ][ "tank_window" ] = %flood_tank_battle_window_tankdebris;
	level.scr_model[ "flood_tank_battle_tankdebris" ]				  = "flood_tank_battle_tankdebris";

	//Convoy Crash Debris
	level.scr_animtree[ "convoy_debris_cone_01" ] = #animtree;
	level.scr_anim[ "convoy_debris_cone_01" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_cone_01;
	level.scr_model[ "convoy_debris_cone_01" ] = "com_trafficcone01";

	level.scr_animtree[ "convoy_debris_cone_02" ] = #animtree;
	level.scr_anim[ "convoy_debris_cone_02" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_cone_02;
	level.scr_model[ "convoy_debris_cone_02" ] = "com_trafficcone01";
	
	level.scr_animtree[ "convoy_debris_cone_03" ] = #animtree;
	level.scr_anim[ "convoy_debris_cone_03" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_cone_03;
	level.scr_model[ "convoy_debris_cone_03" ] = "com_trafficcone01";

	level.scr_animtree[ "convoy_plastic_barricade_01" ] = #animtree;
	level.scr_anim[ "convoy_plastic_barricade_01" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_plastic_barricade_01;
	level.scr_model[ "convoy_plastic_barricade_01" ] = "plastic_jersey_barrier_01";

	level.scr_animtree[ "convoy_plastic_barricade_02" ] = #animtree;
	level.scr_anim[ "convoy_plastic_barricade_02" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_plastic_barricade_02;
	level.scr_model[ "convoy_plastic_barricade_02" ] = "plastic_jersey_barrier_01";

	level.scr_animtree[ "convoy_plastic_barricade_03" ] = #animtree;
	level.scr_anim[ "convoy_plastic_barricade_03" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_plastic_barricade_03;
	level.scr_model[ "convoy_plastic_barricade_03" ] = "plastic_jersey_barrier_01";

	level.scr_animtree[ "convoy_plastic_barricade_04" ] = #animtree;
	level.scr_anim[ "convoy_plastic_barricade_04" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_plastic_barricade_04;
	level.scr_model[ "convoy_plastic_barricade_04" ] = "plastic_jersey_barrier_01";

	level.scr_animtree[ "convoy_tall_barricade_01" ] = #animtree;
	level.scr_anim[ "convoy_tall_barricade_01" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_tall_barricade_01;
	level.scr_model[ "convoy_tall_barricade_01" ] = "com_barrier_tall1";

	level.scr_animtree[ "convoy_tall_barricade_02" ] = #animtree;
	level.scr_anim[ "convoy_tall_barricade_02" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_tall_barricade_02;
	level.scr_model[ "convoy_tall_barricade_02" ] = "com_barrier_tall1";

	level.scr_animtree[ "convoy_short_barricade_01" ] = #animtree;
	level.scr_anim[ "convoy_short_barricade_01" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_short_barricade_01;
	level.scr_model[ "convoy_short_barricade_01" ] = "concrete_barrier_damaged_1";
	
	level.scr_animtree[ "convoy_debris_barrel_01" ] = #animtree;
	level.scr_anim[ "convoy_debris_barrel_01" ][ "m880_crash_barrels" ] = %flood_convoy_crash_debris_barrel_01;
	level.scr_model[ "convoy_debris_barrel_01" ] = "com_barrel_green";

	level.scr_animtree[ "convoy_debris_barrel_02" ] = #animtree;
	level.scr_anim[ "convoy_debris_barrel_02" ][ "m880_crash_barrels" ] = %flood_convoy_crash_debris_barrel_02;
	level.scr_model[ "convoy_debris_barrel_02" ] = "com_barrel_green";

	level.scr_animtree[ "convoy_debris_barrel_03" ] = #animtree;
	level.scr_anim[ "convoy_debris_barrel_03" ][ "m880_crash_barrels" ] = %flood_convoy_crash_debris_barrel_03;
	level.scr_model[ "convoy_debris_barrel_03" ] = "com_barrel_green";

	level.scr_animtree[ "convoy_debris_barrel_04" ] = #animtree;
	level.scr_anim[ "convoy_debris_barrel_04" ][ "m880_crash_barrels" ] = %flood_convoy_crash_debris_barrel_04;
	level.scr_model[ "convoy_debris_barrel_04" ] = "com_barrel_green";

	level.scr_animtree[ "convoy_debris_barrel_05" ] = #animtree;
	level.scr_anim[ "convoy_debris_barrel_05" ][ "m880_crash_barrels" ] = %flood_convoy_crash_debris_barrel_05;
	level.scr_model[ "convoy_debris_barrel_05" ] = "com_barrel_green";

	level.scr_animtree[ "convoy_debris_barrel_06" ] = #animtree;
	level.scr_anim[ "convoy_debris_barrel_06" ][ "m880_crash_barrels" ] = %flood_convoy_crash_debris_barrel_06;
	level.scr_model[ "convoy_debris_barrel_06" ] = "com_barrel_green";

	level.scr_animtree[ "convoy_debris_barrel_07" ] = #animtree;
	level.scr_anim[ "convoy_debris_barrel_07" ][ "m880_crash_barrels" ] = %flood_convoy_crash_debris_barrel_07;
	level.scr_model[ "convoy_debris_barrel_07" ] = "com_barrel_green";
	
	level.scr_animtree[ "convoy_debris_lynx" ] = #animtree;
	level.scr_anim[ "convoy_debris_lynx" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_lynx;
	level.scr_model[ "convoy_debris_lynx" ] = "flood_convoy_debris_lynx";

	level.scr_animtree[ "convoy_debris_m880_01" ] = #animtree;
	level.scr_anim[ "convoy_debris_m880_01" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_m880_01;
	level.scr_model[ "convoy_debris_m880_01" ] = "flood_convoy_debris_m880_01";

	level.scr_animtree[ "convoy_debris_m880_02" ] = #animtree;
	level.scr_anim[ "convoy_debris_m880_02" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_m880_02;
	level.scr_model[ "convoy_debris_m880_02" ] = "flood_convoy_debris_m880_02";

	level.scr_animtree[ "convoy_debris_m880_03" ] = #animtree;
	level.scr_anim[ "convoy_debris_m880_03" ][ "m880_crash_debris" ] = %flood_convoy_crash_debris_m880_03;
	level.scr_model[ "convoy_debris_m880_03" ] = "flood_convoy_debris_m880_03";
	
	level.scr_animtree[ "m880_radiation_gate" ] = #animtree;
	level.scr_anim[ "m880_radiation_gate" ][ "m880_crash_debris" ] = %flood_convoy_crash_radiation_gate;
	level.scr_model[ "m880_radiation_gate" ] = "flood_radiation_portal";
	
	//Convoy M880 Stuck Loop
	level.scr_animtree[ "convoy_tall_barricade_01" ] = #animtree;
	level.scr_anim[ "convoy_tall_barricade_01" ][ "m880_crash_loop" ][0] = %flood_convoy_crash_debris_tall_barricade_loop_01;
	level.scr_model[ "convoy_tall_barricade_01" ] = "com_barrier_tall1";

	level.scr_animtree[ "convoy_tall_barricade_02" ] = #animtree;
	level.scr_anim[ "convoy_tall_barricade_02" ][ "m880_crash_loop" ][0] = %flood_convoy_crash_debris_tall_barricade_loop_02;
	level.scr_model[ "convoy_tall_barricade_02" ] = "com_barrier_tall1";
	
	level.scr_animtree[ "m880_radiation_gate" ] = #animtree;
	level.scr_anim[ "m880_radiation_gate" ][ "m880_crash_loop" ][0] = %flood_convoy_crash_radiation_gate_loop;
	level.scr_model[ "m880_radiation_gate" ] = "flood_radiation_portal";
	
	//MRLS Kill Start
	level.scr_animtree[ "mlrs_kill1_knife" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_knife" ][ "mlrs_kill1_start" ] = %flood_mlrs_kill1_knife_start;
	level.scr_model[ "mlrs_kill1_knife" ] = "viewmodel_bowie_knife";

	level.scr_animtree[ "mlrs_kill1_gun" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_gun" ][ "mlrs_kill1_start" ] = %flood_mlrs_kill1_gun_start;
	level.scr_model[ "mlrs_kill1_gun" ] = "weapon_m9a1_iw6"; 
	
	level.scr_animtree[ "m880_radiation_gate" ] = #animtree;
	level.scr_anim[ "m880_radiation_gate" ][ "mlrs_kill1_start" ] = %flood_mlrs_kill1_radiation_gate_start;
	level.scr_model[ "m880_radiation_gate" ] = "flood_radiation_portal";
	
	//MRLS Kill End
	level.scr_animtree[ "mlrs_kill1_knife" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_knife" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_knife_end;
	level.scr_model[ "mlrs_kill1_knife" ] = "viewmodel_bowie_knife";

	level.scr_animtree[ "mlrs_kill1_end_grenade" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_end_grenade" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_grenade;
	level.scr_model[ "mlrs_kill1_end_grenade" ] = "viewmodel_m67";

	level.scr_animtree[ "m880_radiation_gate" ] = #animtree;
	level.scr_anim[ "m880_radiation_gate" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_radiation_gate_kill;
	level.scr_model[ "m880_radiation_gate" ] = "flood_radiation_portal";

	level.scr_animtree[ "mlrs_kill1_gun" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_gun" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_gun_end;
	level.scr_model[ "mlrs_kill1_gun" ] = "weapon_m9a1_iw6";
	
	level.scr_animtree[ "mlrs_kill1_barricade_01" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_barricade_01" ][ "mlrs_kill1_barricades" ] = %flood_mlrs_kill1_debris_gate_01;
	level.scr_model[ "mlrs_kill1_barricade_01" ] = "ny_barrier_pedestrian_01";

	level.scr_animtree[ "mlrs_kill1_barricade_02" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_barricade_02" ][ "mlrs_kill1_barricades" ] = %flood_mlrs_kill1_debris_gate_02;
	level.scr_model[ "mlrs_kill1_barricade_02" ] = "ny_barrier_pedestrian_01";
	
	
	//MRLS Kill Fail
	level.scr_animtree[ "mlrs_kill1_knife" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_knife" ][ "m880_kill1_fail" ] = %flood_mlrs_kill1_knife_fail;
	level.scr_model[ "mlrs_kill1_knife" ] = "viewmodel_bowie_knife";

	level.scr_animtree[ "mlrs_kill1_gun" ] = #animtree;
	level.scr_anim[ "mlrs_kill1_gun" ][ "m880_kill1_fail" ] = %flood_mlrs_kill1_gun_fail;
	level.scr_model[ "mlrs_kill1_gun" ] = "weapon_m9a1_iw6";
	
	//Dam Break
	level.scr_animtree[ "dam_break_missile_01" ] = #animtree;
	level.scr_anim[ "dam_break_missile_01" ][ "dam_break_missile_01" ] = %flood_dam_break_missile_01;
	level.scr_model[ "dam_break_missile_01" ] = "projectile_slamraam_missile";

	level.scr_animtree[ "dam_break_missile_02" ] = #animtree;
	level.scr_anim[ "dam_break_missile_02" ][ "dam_break_missile_02" ] = %flood_dam_break_missile_02;
	level.scr_model[ "dam_break_missile_02" ] = "projectile_slamraam_missile";

	level.scr_animtree[ "dam_break_missile_03" ] = #animtree;
	level.scr_anim[ "dam_break_missile_03" ][ "dam_break_missile_03" ] = %flood_dam_break_missile_03;
	level.scr_model[ "dam_break_missile_03" ] = "projectile_slamraam_missile";

	level.scr_animtree[ "dam_break_missile_04" ] = #animtree;
	level.scr_anim[ "dam_break_missile_04" ][ "dam_break_missile_04" ] = %flood_dam_break_missile_04;
	level.scr_model[ "dam_break_missile_04" ] = "projectile_slamraam_missile";
	
	level.scr_animtree[ "dam_break_dam" ] = #animtree;
	level.scr_anim[ "dam_break_dam" ][ "dam_break_dam_destruction" ] = %flood_dam_break_dam;
	level.scr_model[ "dam_break_dam" ] = "flood_dam_break_dam";
	
	level.scr_animtree[ "dam_break_street_debris" ] = #animtree;
	level.scr_anim[ "dam_break_street_debris" ][ "dam_break_street_water" ] = %flood_dam_break_street_debris_01;
	level.scr_model[ "dam_break_street_debris" ] = "flood_dam_street_street_debris";
	
	level.scr_animtree[ "dam_break_helmet" ] = #animtree;
	level.scr_anim[ "dam_break_helmet" ][ "dam_break" ] = %flood_dam_break_helmet;
	level.scr_model[ "dam_break_helmet" ] = "flood_dam_break_helmet";
	
	level.scr_animtree[ "dam_break_cone_01" ] = #animtree;
	level.scr_anim[ "dam_break_cone_01" ][ "dam_break_cones" ] = %flood_dam_break_cone_01;
	level.scr_model[ "dam_break_cone_01" ] = "flood_dam_break_cone_01";
	
	level.scr_animtree[ "dam_break_cone_02" ] = #animtree;
	level.scr_anim[ "dam_break_cone_02" ][ "dam_break_cones" ] = %flood_dam_break_cone_02;
	level.scr_model[ "dam_break_cone_02" ] = "flood_dam_break_cone_01";
	
	level.scr_animtree[ "dam_break_cone_03" ] = #animtree;
	level.scr_anim[ "dam_break_cone_03" ][ "dam_break_cones" ] = %flood_dam_break_cone_03;
	level.scr_model[ "dam_break_cone_03" ] = "com_trafficcone01";
	
	level.scr_animtree[ "dam_break_barrier_01" ] = #animtree;
	level.scr_anim[ "dam_break_barrier_01" ][ "dam_break_cones" ] = %flood_dam_break_barricade_01;
	level.scr_model[ "dam_break_barrier_01" ] = "ny_barrier_pedestrian_01";
	
	level.scr_animtree[ "dam_break_barrier_02" ] = #animtree;
	level.scr_anim[ "dam_break_barrier_02" ][ "dam_break_cones" ] = %flood_dam_break_barricade_02;
	level.scr_model[ "dam_break_barrier_02" ] = "ny_barrier_pedestrian_01";
	
	level.scr_animtree[ "dam_break_barrier_03" ] = #animtree;
	level.scr_anim[ "dam_break_barrier_03" ][ "dam_break_cones" ] = %flood_dam_break_barricade_03;
	level.scr_model[ "dam_break_barrier_03" ] = "ny_barrier_pedestrian_01";
	
	level.scr_animtree[ "dam_break_church_spire" ] = #animtree;
	level.scr_anim[ "dam_break_church_spire" ][ "start_church_destruction" ] = %flood_dam_break_church_destruction;
	level.scr_model[ "dam_break_church_spire" ] = "flood_church_spire";
	
	//Convoy Checkpoint
	level.scr_animtree[ "convoy_checkpoint_radio" ] = #animtree;
	level.scr_anim[ "convoy_checkpoint_radio" ][ "convoy_checkpoint" ] = %flood_convoy_checkpoint_radio;
	level.scr_model[ "convoy_checkpoint_radio" ] = "com_hand_radio";
	
	//Alley Flood
	level.scr_animtree[ "alley_flood_debris" ] = #animtree;
	level.scr_anim[ "alley_flood_debris" ][ "alley_flood" ] = %flood_alley_debris;
	level.scr_model[ "alley_flood_debris" ] = "flood_alley_flood_debris";

	//mall rooftop debri
	//level.scr_animtree[ "mall_rooftop_debri_020" ] = #animtree;
	//level.scr_anim[ "mall_rooftop_debri_020" ][ "mall_rooftop_debri_020" ] = %mall_rooftop_debri_020_anim;
	//level.scr_model[ "mall_rooftop_debri_020" ] = "mall_rooftop_debri_020";
	/*
	level.scr_animtree[ "mall_rooftop_debri_021" ] = #animtree;
	level.scr_anim[ "mall_rooftop_debri_021" ][ "mall_rooftop_debri_021" ] = %mall_rooftop_debri_021_anim;
	level.scr_model[ "mall_rooftop_debri_021" ] = "mall_rooftop_debri_021";
	level.scr_animtree[ "mall_rooftop_debri_022" ] = #animtree;
	level.scr_anim[ "mall_rooftop_debri_022" ][ "mall_rooftop_debri_022" ] = %mall_rooftop_debri_022_anim;
	level.scr_model[ "mall_rooftop_debri_022" ] = "mall_rooftop_debri_022";
	level.scr_animtree[ "mall_rooftop_debri_023" ] = #animtree;
	level.scr_anim[ "mall_rooftop_debri_023" ][ "mall_rooftop_debri_023" ] = %mall_rooftop_debri_023_anim;
	level.scr_model[ "mall_rooftop_debri_023" ] = "mall_rooftop_debri_023";
	level.scr_animtree[ "mall_rooftop_wh_debri_01" ] = #animtree;
	level.scr_anim[ "mall_rooftop_wh_debri_01" ][ "mall_rooftop_wh_debri_01" ] = %mall_rooftop_wh_debri_01_anim;
	level.scr_model[ "mall_rooftop_wh_debri_01" ] = "mall_rooftop_wh_debri_01";

*/
	/*
	level.scr_animtree[ "mall_rooftop_debri_03" ] = #animtree;
	level.scr_anim[ "mall_rooftop_debri_03" ][ "mall_rooftop_debri_03" ] = %mall_rooftop_debri_03_anim;
	level.scr_model[ "mall_rooftop_debri_03" ] = "mall_rooftop_debri_03";
*/
	level.scr_animtree[ "building_01_debri" ] = #animtree;
	level.scr_anim[ "building_01_debri" ][ "building_01_debri_anim" ] = %building_01_debri_anim;
	level.scr_model[ "building_01_debri" ] = "building_01_debri";

	//mall roof door entrance
	level.scr_animtree[ "flood_mall_roof_door_model" ]								 = #animtree;
	level.scr_anim[ "flood_mall_roof_door_model" ][ "flood_mall_roof_door"		   ] = %flood_entering_mall_rooftop_door;
	level.scr_anim[ "flood_mall_roof_door_model" ][ "flood_mall_roof_door_outdoor" ] = %flood_entering_mall_rooftop_door_outdoor;
	level.scr_model[ "flood_mall_roof_door_model" ]									 = "tag_origin"; //flood_warehouse_door_02_left

	// Sweptaway
	level.scr_animtree[ "sweptaway_lynx_01" ] = #animtree;
	level.scr_anim[ "sweptaway_lynx_01" ][ "sweptaway" ] = %flood_sweptaway_lynx_01;
	level.scr_model[ "sweptaway_lynx_01" ] = "vehicle_iveco_lynx_iw6";

	level.scr_animtree[ "sweptaway_lynx_02" ] = #animtree;
	level.scr_anim[ "sweptaway_lynx_02" ][ "sweptaway" ] = %flood_sweptaway_lynx_02;
	level.scr_model[ "sweptaway_lynx_02" ] = "vehicle_iveco_lynx_iw6";

	level.scr_animtree[ "sweptaway_lynx_03" ] = #animtree;
	level.scr_anim[ "sweptaway_lynx_03" ][ "sweptaway" ] = %flood_sweptaway_lynx_03;
	level.scr_model[ "sweptaway_lynx_03" ] = "vehicle_iveco_lynx_iw6";

	level.scr_animtree[ "sweptaway_coupe" ] = #animtree;
	level.scr_anim[ "sweptaway_coupe" ][ "sweptaway" ] = %flood_sweptaway_coupe;
	level.scr_model[ "sweptaway_coupe" ] = "vehicle_civilian_sedan_blue_iw6";
	
	level.scr_animtree[ "sweptaway_tower_01" ] = #animtree;
	level.scr_anim[ "sweptaway_tower_01" ][ "sweptaway" ] = %flood_sweptaway_debris_tower_01;
	level.scr_model[ "sweptaway_tower_01" ] = "flood_fallen_antennae_01";

	level.scr_animtree[ "sweptaway_tower_02" ] = #animtree;
	level.scr_anim[ "sweptaway_tower_02" ][ "sweptaway" ] = %flood_sweptaway_debris_tower_02;
	level.scr_model[ "sweptaway_tower_02" ] = "flood_fallen_antennae_01";

	level.scr_animtree[ "sweptaway_tower_03" ] = #animtree;
	level.scr_anim[ "sweptaway_tower_03" ][ "sweptaway" ] = %flood_sweptaway_debris_tower_03;
	level.scr_model[ "sweptaway_tower_03" ] = "flood_fallen_antennae_01";

	level.scr_animtree[ "sweptaway_tower_04" ] = #animtree;
	level.scr_anim[ "sweptaway_tower_04" ][ "sweptaway" ] = %flood_sweptaway_debris_tower_04;
	level.scr_model[ "sweptaway_tower_04" ] = "flood_fallen_antennae_01";

	level.scr_animtree[ "sweptaway_palm" ] = #animtree;
	level.scr_anim[ "sweptaway_palm" ][ "sweptaway" ] = %flood_sweptaway_debris_palm;
	level.scr_model[ "sweptaway_palm" ] = "foliage_tree_palm_tall_2";

	level.scr_animtree[ "sweptaway_street_sign" ] = #animtree;
	level.scr_anim[ "sweptaway_street_sign" ][ "sweptaway" ] = %flood_sweptaway_debris_street_light;
	level.scr_model[ "sweptaway_street_sign" ] = "signal_light_traffic_sign";

	// sweptaway end vignette
	level.scr_animtree[ "sweptaway_antenna_01" ] = #animtree;
	level.scr_anim[ "sweptaway_antenna_01" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_antenna_01;
	level.scr_model[ "sweptaway_antenna_01" ] = "flood_antenna_01";

	level.scr_animtree[ "sweptaway_antenna_02" ] = #animtree;
	level.scr_anim[ "sweptaway_antenna_02" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_antenna_02;
	level.scr_model[ "sweptaway_antenna_02" ] = "flood_antenna_02";

//	level.scr_animtree[ "sweptaway_antenna_03" ] = #animtree;
//	level.scr_anim[ "sweptaway_antenna_03" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_antenna_03;
//	level.scr_model[ "sweptaway_antenna_03" ] = "flood_antenna_03";

	level.scr_animtree[ "sweptaway_macktruck" ]					 = #animtree;
	level.scr_anim[ "sweptaway_macktruck" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_macktruck;
	level.scr_model[ "sweptaway_macktruck" ]					 = "vehicle_mack_truck_short_destroy";

	level.scr_animtree[ "sweptaway_end_chair" ] = #animtree;
	level.scr_anim[ "sweptaway_end_chair" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_debris_chair;
	level.scr_model[ "sweptaway_end_chair" ] = "com_office_chair_killhouse";

	level.scr_animtree[ "sweptaway_end_ibeam" ] = #animtree;
	level.scr_anim[ "sweptaway_end_ibeam" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_debris_ibeam;
	level.scr_model[ "sweptaway_end_ibeam" ] = "flood_debris_i_beam";
	
	level.scr_animtree[ "sweptaway_end_pinned" ] = #animtree;
	level.scr_anim[ "sweptaway_end_pinned" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_debris_pinned;
	level.scr_model[ "sweptaway_end_pinned" ] = "flood_debris_wall_chunk";
	
	

	// skybridge door breach
	level.scr_animtree[ "skybridge_door_breach_door" ]						 = #animtree;
	level.scr_model	  [ "skybridge_door_breach_door" ]						 = "fac_rooftop_exit_door_r";
	level.scr_anim[ "skybridge_door_breach_door" ][ "skybridge_doorbreach" ] = %flood_skybridge_doorbreach_door;
	
	// skybridge
	level.scr_animtree[ "sweptaway_skybridge_01" ]										= #animtree;
	level.scr_model	  [ "sweptaway_skybridge_01" ]										= "flood_skybridge1_update";
	level.scr_anim[ "sweptaway_skybridge_01" ][ "sweptaway_end_b" ]						= %flood_sweptaway_end_skybridge_01;
	level.scr_anim[ "sweptaway_skybridge_01" ][ "skybridge_scene" ]						= %flood_skybridge_skybridge;
	level.scr_anim[ "sweptaway_skybridge_01" ][ "flood_skybridge_skybridge_loop" ][ 0 ] = %flood_skybridge_skybridge_loop;
	level.scr_anim[ "sweptaway_skybridge_01" ][ "flood_skybridge_skybridge_part2" ]		= %flood_skybridge_skybridge_part2;

	level thread skybridge_script_models();
	
	// skybridge - building that collapses
	level.scr_animtree[ "skybridge_building03" ]									 = #animtree;
	level.scr_model	  [ "skybridge_building03" ]									 = "flood_skybridge_building03";
	level.scr_anim[ "skybridge_building03" ][ "skybridge_scene"		 ]				 = %flood_skybridge_bulding;
	level.scr_anim[ "skybridge_building03" ][ "flood_skybridge_building_loop" ][ 0 ] = %flood_skybridge_bulding_loop;
	level.scr_anim[ "skybridge_building03" ][ "flood_skybridge_building_part2" ]	 = %flood_skybridge_bulding_part2;

	level.scr_animtree[ "skybridge_bus" ]				   = #animtree;
	level.scr_anim[ "skybridge_bus" ][ "skybridge_scene" ] = %flood_skybridge_bus;
	level.scr_model[ "skybridge_bus" ]					   = "mp_dart_bus";
	
	// skybridge - player bridge
	level.scr_animtree[ "skybridge_sect_0" ]						= #animtree;
	level.scr_model	  [ "skybridge_sect_0" ]						= "flood_skybridge1_update_piece1";
	level.scr_anim	[ "skybridge_sect_0" ][ "skybridge_sway" ][ 0 ] = %flood_skybridge_skybridgewalk_loop1_piece1;
	level.scr_anim	[ "skybridge_sect_0" ][ "skybridge_break" ]		= %flood_skybridge_skybridgewalk_piece1;
	level.scr_animtree[ "skybridge_sect_1" ]						= #animtree;
	level.scr_model	  [ "skybridge_sect_1" ]						= "flood_skybridge1_update_piece2";
	level.scr_anim	[ "skybridge_sect_1" ][ "skybridge_sway" ][ 0 ] = %flood_skybridge_skybridgewalk_loop1_piece2;
	level.scr_anim	[ "skybridge_sect_1" ][ "skybridge_break" ]		= %flood_skybridge_skybridgewalk_piece2;
	level.scr_animtree[ "skybridge_sect_2" ]						= #animtree;
	level.scr_model	  [ "skybridge_sect_2" ]						= "flood_skybridge1_update_piece3";
	level.scr_anim	[ "skybridge_sect_2" ][ "skybridge_sway" ][ 0 ] = %flood_skybridge_skybridgewalk_loop1_piece3;
	level.scr_anim	[ "skybridge_sect_2" ][ "skybridge_break" ]		= %flood_skybridge_skybridgewalk_piece3;


	level.scr_animtree[ "mallroof_back" ]						   = #animtree;
	level.scr_anim[ "mallroof_back" ][ "mallroof_collapse"		 ] = %flood_mallroof_back1;
	level.scr_model[ "mallroof_back" ]							   = "flood_mallroof_back";
	addNotetrack_flag( "mallroof_back", "enemy_area_falling" , "enemy_area_falling" , "mallroof_collapse" );
	addNotetrack_flag( "mallroof_back", "player_area_falling", "player_area_falling", "mallroof_collapse" );
	addNotetrack_flag( "mallroof_back", "ally_area_falling"	 , "ally_area_falling"	, "mallroof_collapse" );

	level.scr_animtree[ "mallroof_center" ]						   = #animtree;
	level.scr_anim[ "mallroof_center" ][ "mallroof_collapse"	 ] = %flood_mallroof_center1;
	level.scr_model[ "mallroof_center" ]						   = "flood_mallroof_center";
	
	level.scr_animtree[ "mallroof_far" ]					   = #animtree;
	level.scr_anim[ "mallroof_far" ][ "mallroof_collapse"	 ] = %flood_mallroof_far1;
	level.scr_model[ "mallroof_far" ]						   = "flood_mallroof_far";
	
	level.scr_animtree[ "mallroof_impact" ]							= #animtree;
	level.scr_anim[ "mallroof_impact" ][ "mallroof_collapse" ]		= %flood_mallroof_impact1;
	level.scr_anim[ "mallroof_impact" ][ "mallroof_idle"	 ][ 0 ] = %flood_mallroof_impact_idle;
	level.scr_model[ "mallroof_impact" ]							= "flood_mallroof_impact";
	
	level.scr_animtree[ "mallroof_rafters1" ]					   = #animtree;
	level.scr_anim[ "mallroof_rafters1" ][ "mallroof_collapse"	 ] = %flood_mallroof_rafters11;
	level.scr_model[ "mallroof_rafters1" ]						   = "flood_mallroof_rafters1";
	
	level.scr_animtree[ "mallroof_rafters2" ]					   = #animtree;
	level.scr_anim[ "mallroof_rafters2" ][ "mallroof_collapse"	 ] = %flood_mallroof_rafters21;
	level.scr_model[ "mallroof_rafters2" ]						   = "flood_mallroof_rafters2";
	
	level.scr_animtree[ "mallroof_acboxes" ]					   = #animtree;
	level.scr_anim[ "mallroof_acboxes" ][ "mallroof_collapse"	 ] = %flood_mallroof_acboxes1;
	level.scr_model[ "mallroof_acboxes" ]						   = "flood_mallroof_acboxes";
	
	level.scr_animtree[ "mallroof_smallrubble" ]					   = #animtree;
	level.scr_anim[ "mallroof_smallrubble" ][ "mallroof_collapse"	 ] = %flood_mallroof_smallrubble1;
	level.scr_model[ "mallroof_smallrubble" ]						   = "flood_mallroof_smallrubble";
	
	level.scr_animtree[ "mallroof_cables" ]						   = #animtree;
	level.scr_anim[ "mallroof_cables" ][ "mallroof_collapse"	 ] = %flood_mallroof_cables1;
	level.scr_model[ "mallroof_cables" ]						   = "flood_mallroof_cables";
	
	level.scr_animtree[ "swept_start_debris" ]											   = #animtree;
	level.scr_anim[ "swept_start_debris" ][ "flood_sweptaway_player_start_underwater"	 ] = %flood_sweptaway_start_underwater_debris_01;
	level.scr_model[ "swept_start_debris" ]												   = "flood_sweptaway_start_underwater_debris";
	
	level.scr_animtree[ "mall_roof_opfor_geo" ]								= #animtree;
	level.scr_anim[ "mall_roof_opfor_geo" ][ "flood_mall_roof_opfor" ][ 0 ] = %flood_mall_rooftop_floor_loop;
	level.scr_anim[ "mall_roof_opfor_geo" ][ "flood_mall_roof_opfor_shot" ] = %flood_mall_rooftop_floor_shot;
	level.scr_model[ "mall_roof_opfor_geo" ]								= "flood_rooftop_collapse_opfor_loop";
	
	level.scr_animtree[ "mall_roof_opfor_geo_vign" ]							  = #animtree;
	level.scr_anim[ "mall_roof_opfor_geo_vign" ][ "flood_mall_roof_opfor_vign1" ] = %flood_mall_rooftop_floor_vign1;
	level.scr_model[ "mall_roof_opfor_geo_vign" ]								  = "roof_collapse_faling_floor_vign1";

	level.scr_animtree[ "flood_stealthkill_02_filecabinet_01" ]					 = #animtree;
	level.scr_anim[ "flood_stealthkill_02_filecabinet_01" ][ "stealth_kill_02" ] = %flood_stealthkill_02_filecabinet_01;
	level.scr_model[ "flood_stealthkill_02_filecabinet_01" ]					 = "com_filecabinetblackclosed";

	level.scr_animtree[ "flood_stealthkill_02_filecabinet_02" ]					 = #animtree;
	level.scr_anim[ "flood_stealthkill_02_filecabinet_02" ][ "stealth_kill_02" ] = %flood_stealthkill_02_filecabinet_02;
	level.scr_model[ "flood_stealthkill_02_filecabinet_02" ]					 = "com_filecabinetblackclosed_dam";

	level.scr_animtree[ "stealthkill_photocopier" ]					 = #animtree;
	level.scr_anim[ "stealthkill_photocopier" ][ "stealth_kill_02" ] = %flood_stealthkill_02_copier_01;
	level.scr_model[ "stealthkill_photocopier" ]					 = "com_photocopier_dtr";

	level.scr_animtree[ "stealth_flashlight" ] = #animtree;
	level.scr_model	  [ "stealth_flashlight" ] = "com_flashlight_on";

	level.scr_animtree[ "stealth_hatchet" ] = #animtree;
	level.scr_model	  [ "stealth_hatchet" ] = "com_hatchet";

	level.scr_animtree[ "stealth_axebox" ]					= #animtree;
	level.scr_anim[ "stealth_axebox" ][ "stealth_kill_01" ] = %flood_stealthkill_01_axebox;
	level.scr_model [ "stealth_axebox" ]					= "flood_stealthkill_axebox";

	level.scr_animtree[ "skybridge_player" ]						 = #animtree;
	level.scr_model	  [ "skybridge_player" ]						 = "flood_skybridge1_update";
	level.scr_anim[ "skybridge_player" ][ "skybridgewalk_vignette" ] = %flood_skybridge_skybridgewalk;
	level.scr_anim[ "skybridge_player" ][ "skybridgewalk_loop"	   ] = %flood_skybridge_skybridgewalk_loop1;

	// rooftops encounter 01
	level.scr_animtree[ "rooftops_ropeladder" ]										= #animtree;
	level.scr_model	  [ "rooftops_ropeladder" ]										= "blackice_rope_ladder";
	level.scr_anim[ "rooftops_ropeladder" ][ "rooftops_heli_ropeladder"		 ]		= %flood_rooftops_01_rope_ladder;
	level.scr_anim[ "rooftops_ropeladder" ][ "rooftops_heli_ropeladder_loop" ][ 0 ] = %flood_rooftops_01_rope_ladder_loop;

	level.scr_animtree[ "rooftops_brickwall" ]					   = #animtree;
	level.scr_model	  [ "rooftops_brickwall" ]					   = "flood_traversal_01_wall";
	level.scr_anim[ "rooftops_brickwall" ][ "rooftops_wall_kick" ] = %flood_rooftop_traversal_wall;
	//addNotetrack_customFunction( "rooftops_brickwall", "wall_falls", maps\flood_rooftops::rooftops_outro_remove_blocker, "rooftops_wall_kick" );
	
	//level.scr_animtree[ "skybridge_skybridge02" ] = #animtree;
	//level.scr_anim[ "skybridge_skybridge02" ][ "skybridge_scene" ] = %flood_skybridge_skybridge;
	//level.scr_model[ "skybridge_skybridge02" ] = "flood_skybridge1_update";

	//roofops opfor waving flares
	level.scr_animtree[ "flare_left_01" ] = #animtree;
	level.scr_anim[ "flare_left_01" ][ "rooftops_water_reveal_flare" ][ 0 ] = %flood_rooftop_waving_flares_flare_left_loop;
	level.scr_model[ "flare_left_01" ] = "ctl_emergency_flare_animated";

	level.scr_animtree[ "flare_right_01" ] = #animtree;
	level.scr_anim[ "flare_right_01" ][ "rooftops_water_reveal_flare" ][ 0 ] = %flood_rooftop_waving_flares_flare_right_loop;
	level.scr_model[ "flare_right_01" ] = "ctl_emergency_flare_animated";
	
	// debris bridge
	level.scr_animtree[ "debris_debrissmall" ]								= #animtree;
	level.scr_model	  [ "debris_debrissmall" ]								= "flood_debris_small_01";
	level.scr_anim[ "debris_debrissmall" ][ "debris_bridge_loop1" ][ 0 ]	= %flood_debrisbridge_loop1_debris;
	level.scr_anim[ "debris_debrissmall" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_debris;
	level.scr_animtree[ "debris_movingtruck" ]								= #animtree;
	level.scr_model	  [ "debris_movingtruck" ]								= "vehicle_moving_truck";
	level.scr_anim[ "debris_movingtruck" ][ "debris_bridge_loop1" ][ 0 ]	= %flood_debrisbridge_loop1_movingtruck;
	level.scr_anim[ "debris_movingtruck" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_movingtruck;
	level.scr_anim[ "debris_movingtruck" ][ "debris_bridge_loop2" ][ 0 ]	= %flood_debrisbridge_loop2_movingtruck;
	level.scr_animtree[ "debris_vanblue" ]									= #animtree;
	level.scr_model	  [ "debris_vanblue" ]									= "vehicle_van_blue";
	level.scr_anim[ "debris_vanblue" ][ "debris_bridge_loop1" ][ 0 ]		= %flood_debrisbridge_loop1_vanblue;
	level.scr_anim[ "debris_vanblue" ][ "debris_bridge_vign1" ]				= %flood_debrisbridge_vign1_vanblue;
	level.scr_anim[ "debris_vanblue" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_vanblue;
	level.scr_animtree[ "debris_00" ]										= #animtree;
	level.scr_model	  [ "debris_00" ]										= "flood_debris_small_01";
	level.scr_anim[ "debris_00" ][ "debris_bridge_loop1" ][ 0 ]				= %flood_debrisbridge_loop1_debris_01;
	level.scr_anim[ "debris_00" ][ "debris_bridge_vign1" ]					= %flood_debrisbridge_vign1_debris_01;
	level.scr_anim[ "debris_00" ][ "debris_bridge_loop2" ][ 0 ]				= %flood_debrisbridge_loop2_debris_01;
	level.scr_animtree[ "debris_bus" ]										= #animtree;
	level.scr_model	  [ "debris_bus" ]										= "mp_dart_bus";
	level.scr_anim[ "debris_bus" ][ "debris_bridge_vign1" ]					= %flood_debrisbridge_vign1_bus;
	level.scr_anim[ "debris_bus" ][ "debris_bridge_loop2" ][ 0 ]			= %flood_debrisbridge_loop2_bus;
	level.scr_animtree[ "debris_cargocontainer" ]							= #animtree;
	level.scr_model	  [ "debris_cargocontainer" ]							= "ny_harbor_cargocontainer_destroyed02";
	level.scr_anim[ "debris_cargocontainer" ][ "debris_bridge_vign1" ]		= %flood_debrisbridge_vign1_cargocontainer;
	level.scr_anim[ "debris_cargocontainer" ][ "debris_bridge_loop2" ][ 0 ] = %flood_debrisbridge_loop2_cargocontainer;
	level.scr_animtree[ "debris_coupeblue" ]								= #animtree;
	level.scr_model	  [ "debris_coupeblue" ]								= "vehicle_civilian_sedan_blue_iw6";
	level.scr_anim[ "debris_coupeblue" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_coupeblue;
	level.scr_anim[ "debris_coupeblue" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_coupeblue;
	level.scr_animtree[ "debris_coupedeepblue" ]							= #animtree;
	level.scr_model	  [ "debris_coupedeepblue" ]							= "vehicle_civilian_sedan_bronze_iw6";
	level.scr_anim[ "debris_coupedeepblue" ][ "debris_bridge_vign1" ]		= %flood_debrisbridge_vign1_coupedeepblue;
	level.scr_anim[ "debris_coupedeepblue" ][ "debris_bridge_loop2" ][ 0 ]	= %flood_debrisbridge_loop2_coupedeepblue;
	level.scr_animtree[ "debris_vangold" ]									= #animtree;
	level.scr_model	  [ "debris_vangold" ]									= "vehicle_van_gold_destructible";
	level.scr_anim[ "debris_vangold" ][ "debris_bridge_vign1" ]				= %flood_debrisbridge_vign1_vangold;
	level.scr_anim[ "debris_vangold" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_vangold;
	level.scr_animtree[ "debris_coupegreen" ]								= #animtree;
	level.scr_model	  [ "debris_coupegreen" ]								= "vehicle_civilian_sedan_black_iw6";
	level.scr_anim[ "debris_coupegreen" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_coupegreen;
	level.scr_anim[ "debris_coupegreen" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_coupegreen;
	level.scr_animtree[ "debris_macktruck" ]								= #animtree;
	level.scr_model	  [ "debris_macktruck" ]								= "flood_mack_truck_short";
	level.scr_anim[ "debris_macktruck" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_macktruck;
	level.scr_anim[ "debris_macktruck" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_macktruck;
	level.scr_animtree[ "debris_subcompgreen" ]								= #animtree;
	level.scr_model	  [ "debris_subcompgreen" ]								= "vehicle_civilian_sedan_white_iw6";
	level.scr_anim[ "debris_subcompgreen" ][ "debris_bridge_vign1" ]		= %flood_debrisbridge_vign1_subcompgreen;
	level.scr_anim[ "debris_subcompgreen" ][ "debris_bridge_loop2" ][ 0 ]	= %flood_debrisbridge_loop2_subcompgreen;
	level.scr_animtree[ "debris_truckbm21" ]								= #animtree;
	level.scr_model	  [ "debris_truckbm21" ]								= "vehicle_man_7t_destroy_iw6";
	level.scr_anim[ "debris_truckbm21" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_truckmb21;
	level.scr_anim[ "debris_truckbm21" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_truckmb21;
	level.scr_animtree[ "debris_utiltruck" ]								= #animtree;
	level.scr_model	  [ "debris_utiltruck" ]								= "vehicle_uk_utility_truck_static";
	level.scr_anim[ "debris_utiltruck" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_utiltruck;
	level.scr_anim[ "debris_utiltruck" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_utiltruck;
	level.scr_animtree[ "debris_vangreen" ]									= #animtree;
	level.scr_model	  [ "debris_vangreen" ]									= "vehicle_van_green_destructible";
	level.scr_anim[ "debris_vangreen" ][ "debris_bridge_vign1" ]			= %flood_debrisbridge_vign1_vangreen;
	level.scr_anim[ "debris_vangreen" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_vangreen;
	level.scr_animtree[ "debris_01" ]										= #animtree;
	level.scr_model	  [ "debris_01" ]										= "flood_debris_small_01";
	level.scr_anim[ "debris_01" ][ "debris_bridge_vign1" ]					= %flood_debrisbridge_vign1_debris_02;
	level.scr_anim[ "debris_01" ][ "debris_bridge_loop2" ][ 0 ]				= %flood_debrisbridge_loop2_debris_02;
	level.scr_animtree[ "debris_02" ]										= #animtree;
	level.scr_model	  [ "debris_02" ]										= "flood_debris_small_01";
	level.scr_anim[ "debris_02" ][ "debris_bridge_vign1" ]					= %flood_debrisbridge_vign1_debris_03;
	level.scr_anim[ "debris_02" ][ "debris_bridge_loop2" ][ 0 ]				= %flood_debrisbridge_loop2_debris_03;
	level.scr_animtree[ "debris_antenna" ]									= #animtree;
	level.scr_model	  [ "debris_antenna" ]									= "flood_antenna_02";
	level.scr_anim[ "debris_antenna" ][ "debris_bridge_vign1" ]				= %flood_debrisbridge_vign1_antenna;
	level.scr_anim[ "debris_antenna" ][ "debris_bridge_loop2" ][ 0 ]		= %flood_debrisbridge_loop2_antenna;
	level.scr_animtree[ "debris_wall" ]										= #animtree;
	level.scr_model	  [ "debris_wall" ]										= "flood_debris_bridge_busted_wall";
	level.scr_anim[ "debris_wall" ][ "debris_bridge_vign1" ]				= %flood_debrisbridge_vign1_busted_wall;
	level.scr_animtree[ "debris_clip" ]										= #animtree;
	level.scr_model	  [ "debris_clip" ]										= "tag_origin";
	level.scr_anim[ "debris_clip" ][ "debris_bridge_vign1" ]				= %flood_debrisbridge_vign1_collision;
	level.scr_anim[ "debris_clip" ][ "debris_bridge_loop2" ][ 0 ]			= %flood_debrisbridge_loop2_collision;

	level.scr_animtree[ "warehouse_door_burst" ]												   = #animtree;
	level.scr_anim[ "warehouse_door_burst" ][ "flood_warehouse_doorbuckling_door"	  ]			   = %flood_warehouse_doorbuckling_door;
	level.scr_anim[ "warehouse_door_burst" ][ "flood_warehouse_doorbuckling_door_alt" ]			   = %flood_warehouse_doorbuckling_door_alt;
	level.scr_anim[ "warehouse_door_burst" ][ "flood_warehouse_doorbuckling_door_loop1"		][ 0 ] = %flood_warehouse_doorbuckling_door_loop1;
	level.scr_anim[ "warehouse_door_burst" ][ "flood_warehouse_doorbuckling_door_loop2"		][ 0 ] = %flood_warehouse_doorbuckling_door_loop2;
	level.scr_anim[ "warehouse_door_burst" ][ "flood_warehouse_doorbuckling_door_loop2_alt" ][ 0 ] = %flood_warehouse_doorbuckling_door_loop2_alt;

	level.scr_animtree[ "warehouse_double_doorl" ]							   = #animtree;
	level.scr_anim[ "warehouse_double_doorl" ][ "warehouse_double_door" ][ 0 ] = %flood_warehouse_double_door_left;
//	level.scr_model[ "warehouse_double_doorl" ]								   = "flood_warehouse_double_door_left";
	level.scr_model[ "warehouse_double_doorl" ]								   = "flood_warehouse_door_left";
	
	level.scr_animtree[ "warehouse_double_doorr" ]							   = #animtree;
	level.scr_anim[ "warehouse_double_doorr" ][ "warehouse_double_door" ][ 0 ] = %flood_warehouse_double_door_right;
//	level.scr_model[ "warehouse_double_doorr" ]								   = "flood_warehouse_double_door_right";
	level.scr_model[ "warehouse_double_doorr" ]								   = "flood_warehouse_door_right";
	
	level.scr_animtree[ "ending_breach_door_l" ]				   = #animtree;
	level.scr_model	  [ "ending_breach_door_l" ]				   = "tag_origin";
	level.scr_anim[ "ending_breach_door_l" ][ "outro_pt1_breach" ] = %flood_outro_pt1_breach_door_left;

	level.scr_animtree[ "ending_breach_door_r" ]				   = #animtree;
	level.scr_model	  [ "ending_breach_door_r" ]				   = "tag_origin";
	level.scr_anim[ "ending_breach_door_r" ][ "outro_pt1_breach" ] = %flood_outro_pt1_breach_door_right;


	// ending player gun
	level.scr_animtree[ "outro_gun_player" ]							= #animtree;
	level.scr_model	  [ "outro_gun_player" ]							= "weapon_m9a1_iw6";
	level.scr_anim[ "outro_gun_player" ][ "outro_pt1_melee_player"	  ] = %flood_outro_pt1_melee_pistol;
	level.scr_anim[ "outro_gun_player" ][ "outro_pt1_melee_win"		  ] = %flood_outro_pt1_melee_win_pistol;
	level.scr_anim[ "outro_gun_player" ][ "outro_pt1_melee_fail"	  ] = %flood_outro_pt1_melee_fail_pistol;
	level.scr_anim[ "outro_gun_player" ][ "outro_pt1_garcia_punch"	  ] = %flood_outro_pt1_garcia_punch_pistol;
	level.scr_anim[ "outro_gun_player" ][ "outro_pt1_garcia_kill_pt1" ] = %flood_outro_pt1_garcia_kill_pt1_p_pistol;
	level.scr_anim[ "outro_gun_player" ][ "outro_pt1_garcia_kill_pt2" ] = %flood_outro_pt1_garcia_kill_pt2_p_pistol;
	level.scr_anim[ "outro_gun_player" ][ "outro_pt1_crash"			  ] = %flood_outro_pt1_crash_p_pistol;

	// ending garcia gun
	level.scr_animtree[ "outro_gun_garcia" ]							= #animtree;
	level.scr_model	  [ "outro_gun_garcia" ]							= "weapon_m9a1_iw6";
	level.scr_anim[ "outro_gun_garcia" ][ "outro_pt1_garcia_kill_pt1" ] = %flood_outro_pt1_garcia_kill_pt1_g_pistol;
	level.scr_anim[ "outro_gun_garcia" ][ "outro_pt1_garcia_kill_pt2" ] = %flood_outro_pt1_garcia_kill_pt2_g_pistol;
	level.scr_anim[ "outro_gun_garcia" ][ "outro_pt1_crash"			  ] = %flood_outro_pt1_crash_g_pistol;


	// ending  heli
	level.scr_animtree[ "outro_pt1_heli" ]				   = #animtree;
	level.scr_model	  [ "outro_pt1_heli" ]				   = "vehicle_nh90_interior";
	level.scr_anim[ "outro_pt1_heli" ][ "outro_pt1_heli" ] = %flood_outro_pt1_helicopter; 

	level.scr_animtree[ "outro_heli_front" ]						  = #animtree;
	level.scr_model	  [ "outro_heli_front" ]						  = "vehicle_nh90_flood_front";
	level.scr_anim[ "outro_heli_front" ] [ "outro_pt2_start"		] = %flood_outro_pt2_start_heli_front;

	level.scr_animtree[ "outro_heli_mid" ]							= #animtree;
	level.scr_model	  [ "outro_heli_mid" ]							= "vehicle_nh90_flood_mid";
	level.scr_anim[ "outro_heli_mid" ] [ "outro_pt2_start"		  ] = %flood_outro_pt2_start_heli_mid;

	level.scr_animtree[ "outro_heli_rear" ]							 = #animtree;
	level.scr_model	  [ "outro_heli_rear" ]							 = "vehicle_nh90_flood_mid";
	level.scr_anim[ "outro_heli_rear" ] [ "outro_pt2_start"		   ] = %flood_outro_pt2_start_heli_rear;

	level.scr_animtree[ "outro_wire_grab" ]					 = #animtree;
	level.scr_model	  [ "outro_wire_grab" ]					 = "flood_outro_wire";
	level.scr_anim[ "outro_wire_grab" ][ "outro_pt2_start" ] = %flood_outro_pt2_wire;
	
	level.scr_animtree[ "outro_pt1_blood" ] = #animtree;
	level.scr_anim[ "outro_pt1_blood" ][ "outro_pt1_blood" ] = %flood_outro_pt1_blood;
	level.scr_model[ "outro_pt1_blood" ] = "vehicle_nh90_blood_windshield";
}

skybridge_script_models()
{
	wait( 0.5 );
	
	// This is separated out for the TFF system
	if ( level.start_point != "sweptaway" )
	{
		level waittill( "swept_away" );
	}
	//addNotetrack_customFunction( "sweptaway_skybridge_01", "busboom"  , maps\flood_rooftops::skybridge_debris_hit, "flood_skybridge_skybridge_part2" );
	
							 //   animname 				    notetrack    function 									      anime 						    
	addNotetrack_customFunction( "sweptaway_skybridge_01", "boom1"	  , maps\flood_rooftops::skybridge_debris_hit_large, "flood_skybridge_skybridge_part2" );
	addNotetrack_customFunction( "sweptaway_skybridge_01", "boom2"	  , maps\flood_rooftops::skybridge_debris_hit_med  , "flood_skybridge_skybridge_part2" );
	addNotetrack_customFunction( "sweptaway_skybridge_01", "boom3"	  , maps\flood_rooftops::skybridge_debris_hit_large, "flood_skybridge_skybridge_part2" );
}
	
#using_animtree("vehicles"); 
vehicles() 
{
	//Infil
	level.scr_anim[ "infil_heli_player" ][ "infil" ] = %flood_infil_heli_01;
	level.scr_anim[ "infil_heli_ally" ][ "infil" ] = %flood_infil_heli_02;
	
	level.scr_anim[ "lynx_smash" ][ "lynx_smash_tank" ] = %flood_tank_battle_lynx_smash_tank;
	
	//M880 Crash
	level.scr_anim[ "m880_crash_m880" ][ "m880_crash" ] = %flood_convoy_crash_m880;

	level.scr_anim[ "convoy_lynx" ][ "m880_crash" ] = %flood_convoy_crash_lynx;
	addNotetrack_customFunction( "convoy_lynx", "lynx_sparks", maps\flood_fx::fx_lynx_sparks );

//	level.scr_anim[ "convoy_lynx" ][ "m880_crash_hold" ] = %flood_convoy_crash_lynx_hold;
	
	//M880 Stuck Loop
	level.scr_anim[ "m880_crash_m880" ][ "m880_crash_loop" ][0] = %flood_convoy_crash_m880_stuck_loop;
	
	//MLRS Kill
	level.scr_anim[ "mlrs_kill1_m880" ][ "mlrs_kill1_start" ] = %flood_mlrs_kill1_m880_start;
	
	level.scr_anim[ "mlrs_kill1_m880" ][ "mlrs_kill1_end" ] = %flood_mlrs_kill1_m880_kill;
	
	//Dam Break
	level.scr_anim[ "dam_break_m880" ][ "dam_break_m880_launch_prep" ] = %flood_dam_break_m880_launch_prep;
	
	level.scr_anim[ "dam_break_m880" ][ "dam_break" ] = %flood_dam_break_mrls;
	
	addNotetrack_customFunction( "dam_break_m880", "fire_missile_01", ::dam_break_missile_01 );
	addNotetrack_customFunction( "dam_break_m880", "fire_missile_02", ::dam_break_missile_02 );
	addNotetrack_customFunction( "dam_break_m880", "fire_missile_03", ::dam_break_missile_03 );
	addNotetrack_customFunction( "dam_break_m880", "fire_missile_04", ::dam_break_missile_04 );
	
	//Alley Flood
	level.scr_animtree[ "alley_flood_man7t" ]						= #animtree;
	level.scr_anim[ "alley_flood_man7t" ][ "alley_flood" ] = %flood_alley_man7t;
	
	/*
	//Heli Crash
	level.scr_anim[ "heli" ][ "heli_crash_intro" ] = %flood_heli_crash_intro_heli;
	
	level.scr_anim[ "heli" ][ "heli_crash_fight_01_loop" ] = %flood_heli_crash_fight_01_loop_heli;
	
	level.scr_anim[ "heli" ][ "heli_crash_player_jump" ] = %flood_heli_crash_player_jump_heli;
	
	level.scr_anim[ "heli" ][ "heli_crash_fight_03" ] = %flood_heli_crash_fight_03_heli;
	*/
	
	//Sweptaway
	level.scr_anim[ "sweptaway_m880" ][ "sweptaway" ] = %flood_sweptaway_m880;

	level.scr_anim[ "sweptaway_man7t" ][ "sweptaway" ] = %flood_sweptaway_man7t;
	
	level.scr_anim[ "sweptaway_end_man7t" ][ "sweptaway_end_b" ] = %flood_sweptaway_end_man7t;
	
	//rooftop encounter 01
	level.scr_anim[ "rooftops_hind" ][ "rooftops_heli_ropeladder"	 ]		  = %flood_rooftops_01_hind;
	level.scr_anim[ "rooftops_hind" ][ "rooftops_heli_ropeladder_loop" ][ 0 ] = %flood_rooftops_01_hind_loop;
	
	// Outro
	level.scr_anim[ "outro_heli" ][ "outro" ] = %flood_outro_heli_jump_heli;
	
	level.scr_anim[ "outro_heli" ][ "outro_melee_01" ] = %flood_outro_melee_01_heli;
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

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
infil_spawn()
{
	infil_heli_player = vignette_vehicle_spawn("infil_heli_player", "infil_heli_player"); //"value" (kvp), "anim_name"
	infil_heli_ally = vignette_vehicle_spawn("infil_heli_ally", "infil_heli_ally"); //"value" (kvp), "anim_name"
	ally_01 = vignette_actor_spawn("ally_01", "ally_01"); //"value" (kvp), "anim_name"
	heli_02_ally_01 = vignette_actor_spawn("heli_02_ally_01", "heli_02_ally_01"); //"value" (kvp), "anim_name"
	heli_02_ally_02 = vignette_actor_spawn("heli_02_ally_02", "heli_02_ally_02"); //"value" (kvp), "anim_name"
	heli_01_gunner_01 = vignette_actor_spawn("heli_01_gunner_01", "heli_01_gunner_01"); //"value" (kvp), "anim_name"
	heli_01_copilot = vignette_actor_spawn("heli_01_copilot", "heli_01_copilot"); //"value" (kvp), "anim_name"
	heli_02_ally_03 = vignette_actor_spawn("heli_02_ally_03", "heli_02_ally_03"); //"value" (kvp), "anim_name"
	heli_02_ally_04 = vignette_actor_spawn("heli_02_ally_04", "heli_02_ally_04"); //"value" (kvp), "anim_name"
	heli_02_gunner_01 = vignette_actor_spawn("heli_02_gunner_01", "heli_02_gunner_01"); //"value" (kvp), "anim_name"
	heli_02_gunner_02 = vignette_actor_spawn("heli_02_gunner_02", "heli_02_gunner_02"); //"value" (kvp), "anim_name"
	heli_02_pilot = vignette_actor_spawn("heli_02_pilot", "heli_02_pilot"); //"value" (kvp), "anim_name"
	heli_02_copilot = vignette_actor_spawn("heli_02_copilot", "heli_02_copilot"); //"value" (kvp), "anim_name"

	infil(infil_heli_player, infil_heli_ally, ally_01, heli_02_ally_01, heli_02_ally_02, heli_01_gunner_01, heli_01_copilot, heli_02_ally_03, heli_02_ally_04, heli_02_gunner_01, heli_02_gunner_02, heli_02_pilot, heli_02_copilot);

	infil_heli_player vignette_vehicle_delete();
	infil_heli_ally vignette_vehicle_delete();
//    ally_01 vignette_actor_delete();
	heli_02_ally_01 vignette_actor_delete();
	heli_02_ally_02 vignette_actor_delete();
	heli_01_gunner_01 vignette_actor_delete();
	heli_01_copilot vignette_actor_delete();
	heli_02_ally_03 vignette_actor_delete();
	heli_02_ally_04 vignette_actor_delete();
	heli_02_gunner_01 vignette_actor_delete();
	heli_02_gunner_02 vignette_actor_delete();
	heli_02_pilot vignette_actor_delete();
	heli_02_copilot vignette_actor_delete();
}

infil(infil_heli_player, infil_heli_ally, ally_01, heli_02_ally_01, heli_02_ally_02, heli_01_gunner_01, heli_01_copilot, heli_02_ally_03, heli_02_ally_04, heli_02_gunner_01, heli_02_gunner_02, heli_02_pilot, heli_02_copilot)
{

	node = getstruct("vignette_infil", "script_noteworthy");

	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );
	
	heli_01_gunner_turret = spawn_anim_model("heli_01_gunner_turret");
	
	heli_02_gunner_turret_01 = spawn_anim_model("heli_02_gunner_turret_01");

	heli_02_gunner_turret_02 = spawn_anim_model("heli_02_gunner_turret_02");

	//Helicopter Anims
	helicopters = [];
	helicopters["infil_heli_player"] = infil_heli_player;
	helicopters["infil_heli_ally"] = infil_heli_ally;
	
	//Guys sitting in player helicopter
	guys_heli_01 = [];
	guys_heli_01["heli_01_copilot"] = heli_01_copilot;
	guys_heli_01["heli_01_gunner_01"] = heli_01_gunner_01;
	guys_heli_01["heli_01_gunner_turret"] = heli_01_gunner_turret;
	
	//Player and Ally
	guys_heli_01_dismount = [];
	guys_heli_01_dismount["player_rig"] = player_rig;
	guys_heli_01_dismount["ally_01"] = ally_01;
	
	//Guys sitting in ally helicopter
	guys_heli_02 = [];
	guys_heli_02["heli_02_pilot"] = heli_02_pilot;
	guys_heli_02["heli_02_copilot"] = heli_02_copilot;
	guys_heli_02["heli_02_gunner_01"] = heli_02_gunner_01;
	guys_heli_02["heli_02_gunner_02"] = heli_02_gunner_02;
	guys_heli_02["heli_02_gunner_turret_01"] = heli_02_gunner_turret_01;
	guys_heli_02["heli_02_gunner_turret_02"] = heli_02_gunner_turret_02;
	guys_heli_02["heli_02_ally_03"] = heli_02_ally_03;
	guys_heli_02["heli_02_ally_04"] = heli_02_ally_04;
	
	//Allies that dismount from ally helicopter
	guys_heli_02_dismount = [];
	guys_heli_02_dismount["heli_02_ally_01"] = heli_02_ally_01;
	guys_heli_02_dismount["heli_02_ally_02"] = heli_02_ally_02;

	arc = 15;

	player_rig LinkTo( infil_heli_player, "tag_player", (0,0,0), (0,0,0) );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 60, arc, arc, arc, true );
	
	ally_01 LinkTo( infil_heli_player, "tag_player", (0,0,0), (0,0,0) );
	
	foreach ( guy in guys_heli_01 )
	{
		guy LinkTo( infil_heli_player, "tag_player", (0,0,0), (0,0,0) );
	}
	
	foreach ( guy in guys_heli_02 )
	{
		guy LinkTo( infil_heli_ally, "tag_player", (0,0,0), (0,0,0) );
	}

	
	level.player DisableWeapons();

	//Play helicopter anims
	node thread anim_single(helicopters, "infil");
	thread	maps\flood_fx::fx_heli_land();

	//Start player and ally anims and unlink from helicopter when finished.
	thread play_guy_heli_01_anims(node, guys_heli_01_dismount, player_rig, ally_01);

	//Start guys sitting in player helicopter anims.
	node thread anim_single(guys_heli_01, "infil");
	
	//Start guys that dismount from ally helicopter anims.
	node thread anim_single(guys_heli_02_dismount, "infil");
	
	//Start guys that dismount from ally helicopter anims.
	node anim_single(guys_heli_02, "infil");


//	level notify("infil_done");

}

play_guy_heli_01_anims(node, guys_heli_01_dismount, player_rig, ally_01)
{
	node anim_single(guys_heli_01_dismount, "infil");

	level.player unlink();

	player_rig delete(); 

	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );
	level.player EnableWeapons();
	
    level notify("infil_done");
    
    //adding this for now to remove this guy
    //need to instead make him go from animated to AI
    ally_01 stop_magic_bullet_shield();
    ally_01 delete();
}
	

*/
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// mlrs kill1
/*
mlrs_kill1_spawn()
{
	mlrs_kill_player_body = vignette_actor_spawn("vignette_mrls_kill_player_body", "mlrs_kill_player_body"); //"value" (kvp), "anim_name"
	mlrs_kill_opfor = vignette_actor_spawn("vignette_mrls_kill_opfor", "mlrs_kill_opfor"); //"value" (kvp), "anim_name"

	mlrs_kill1(mlrs_kill_player_body, mlrs_kill_opfor);

	mlrs_kill_player_body vignette_actor_delete();
	mlrs_kill_opfor vignette_actor_delete();
}

mlrs_kill1(mlrs_kill_player_body, mlrs_kill_opfor)
{

	node = getstruct("vignette_mlrs_kill1_node", "script_noteworthy");

	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );
	level.player DisableWeapons();

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["mlrs_kill_player_body"] = mlrs_kill_player_body;
	guys["mlrs_kill_opfor"] = mlrs_kill_opfor;

	arc = 15;

	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);
	
	thread maps\flood_audio::mssl_launch_destory_sfx();

	node anim_single(guys, "mlrs_kill1");

	mlrs_kill1_end(node, player_rig, mlrs_kill_player_body, mlrs_kill_opfor);


	level.player unlink();

	player_rig delete();

	level.player EnableWeapons();
	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );

} 



mlrs_kill1_end(node, player_rig, mlrs_kill_player_body, mlrs_kill_opfor)
{

	//node = getstruct("vignette_mlrs_kill1_node", "script_noteworthy");

	mlrs_grenade = spawn_anim_model("mlrs_grenade");

	mlrs_knife = spawn_anim_model("mlrs_knife");

	//level.player FreezeControls( true );
	//level.player allowprone( false );
	//level.player allowcrouch( false );

	//player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;
	guys["mlrs_kill_player_body"] = mlrs_kill_player_body;
	guys["mlrs_kill_opfor"] = mlrs_kill_opfor;
	guys["mlrs_grenade"] = mlrs_grenade;
	guys["mlrs_knife"] = mlrs_knife;

	//arc = 15;

	//level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "mlrs_kill1_end");

	//level.player unlink();

	//player_rig delete();

	//level.player FreezeControls( false );
	//level.player allowprone( true );
	//level.player allowcrouch( true );

}
*/



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//#using_animtree( "vehicles" );
dam_break_m880_init()
{
	level.dam_break_m880 = vignette_vehicle_spawn("dam_break_m880", "dam_break_m880"); //"value" (kvp), "anim_name"
	
//	level.dam_break_m880 = getent("dam_break_m880", "targetname");
//	level.dam_break_m880.animname = "dam_break_m880";
//	shadow_array = GetEntArray("m880_shadow_brush_after", "targetname");
//	foreach ( shadow in shadow_array)
//	{
//		shadow hide();
//	}
	
	node = getstruct( "vignette_dam_break", "script_noteworthy" );
	//node must have been moved at some point 
	node.origin = node.origin + (0,0,3);	
	node anim_first_frame_solo(level.dam_break_m880, "dam_break_m880_launch_prep");
	
	//un-vehicle-ify the m880 so its suspension doesn't pop
	animation	  = level.scr_anim[ "dam_break_m880" ][ "dam_break_m880_launch_prep" ];
	anim_point	  = node;
	struct		  = SpawnStruct();
	struct.origin = GetStartOrigin( anim_point.origin, anim_point.angles, animation );
	struct.angles = GetStartAngles( anim_point.origin, anim_point.angles, animation );

//	IPrintLn("m880 start orienting");
	level.dam_break_m880 Vehicle_OrientTo( struct.origin, struct.angles, 25.0, 0.0 );
//	IPrintLn("m880 waiting");
	level.dam_break_m880 waittill( "orientto_complete" );

//	IPrintLn("m880 done orienting");
	
	level.dam_break_m880 notify( "suspend_drive_anims" );
	
	node anim_first_frame_solo(level.dam_break_m880, "dam_break_m880_launch_prep");	
//	IPrintLn("m880 init done");

}

dam_break_m880_shadows_init()
{
	shadow_array = GetEntArray("m880_shadow_brush_after", "targetname");
	foreach ( shadow in shadow_array)
	{
		shadow hide();
	}
	
	dam_break_m880_shadows_switch();
}

dam_break_m880_shadows_switch()
{
	level waittill("dam_break_start");	
	
	//use wait until notetrack is in
	wait(2.0);
	
	shadow_array = GetEntArray("m880_shadow_brush_before", "targetname");
	foreach ( shadow in shadow_array)
	{
		shadow hide();
	}	
	
	shadow_array = GetEntArray("m880_shadow_brush_after", "targetname");
	foreach ( shadow in shadow_array)
	{
		shadow show();
	}	
}

dam_break_m880_launch_prep_spawn()
{
//	dam_break_m880 = vignette_vehicle_spawn("dam_break_m880", "dam_break_m880"); //"value" (kvp), "anim_name"

	dam_break_m880_launch_prep(level.dam_break_m880);

//	dam_break_m880 vignette_vehicle_delete();
}

dam_break_m880_launch_prep(dam_break_m880)
{

	node = getstruct("vignette_dam_break", "script_noteworthy");


	guys = [];
	guys["dam_break_m880"] = dam_break_m880;
	
	node thread anim_single(guys, "dam_break_m880_launch_prep");
	//moving node back to original pos for the rest of the animations
	node.origin = node.origin - (0,0,3);
}

dam_break_spawn()
{
//	dam_break_ally_01 = vignette_actor_spawn("vignette_dam_break_ally_01", "dam_break_ally_01"); //"value" (kvp), "anim_name"
//	dam_break_ally_02 = vignette_actor_spawn("vignette_dam_break_ally_02", "dam_break_ally_02"); //"value" (kvp), "anim_name"
//	dam_break_ally_03 = vignette_actor_spawn("vignette_dam_break_ally_03", "dam_break_ally_03"); //"value" (kvp), "anim_name"
	
	dam_break_player_legs = vignette_actor_spawn("vignette_dam_break_player_legs", "dam_break_player_legs"); //"value" (kvp), "anim_name"

//	dam_break_m880 = vignette_vehicle_spawn("dam_break_m880", "dam_break_m880"); //"value" (kvp), "anim_name"

	dam_break(dam_break_player_legs, level.dam_break_m880);

	dam_break_player_legs vignette_actor_delete();
//	dam_break_ally_01 vignette_actor_delete();
//	dam_break_ally_02 vignette_actor_delete();
//	dam_break_ally_03 vignette_actor_delete();
//	dam_break_m880 vignette_vehicle_delete();
}


dam_break(dam_break_player_legs, dam_break_m880)
{
	level.player endon("death");
	
	thread maps\flood_fx::fx_dam_missile_launch_01(); // play rocket launch vfx
	thread maps\flood_fx::fx_dam_missile_dust(); // play rocket launch vfx

	wait 0.3; // need a bit of time here to make sure the player registers them firing and why they're being blown back
	
//	node = getstruct("vignette_dam_break", "script_noteworthy");
	
	dam_break_helmet = spawn_anim_model("dam_break_helmet");
	
	g_friendlyNameDist_old = GetDvarInt( "g_friendlyNameDist" );
	SetSavedDvar( "g_friendlyNameDist", 0 );
	
	level.player FreezeControls( true );
	level.player stopsliding();
//	SetDvar("slide_enable", "1");

	//trying to make sure player is in "stand" before they play the anims
	if(level.player GetStance() == "prone")
	{
		level.player SetStance("crouch");
		while(level.player GetStance() != "crouch")
		{
			waitframe();
		}
	}
	
	if(level.player GetStance() == "crouch")
	{
		level.player SetStance("stand");
		while(level.player GetStance() != "stand")
		{
			waitframe();
		}
	}
	
	level.player allowprone( false );
	level.player allowcrouch( false );
	
	player_rig = spawn_anim_model( "player_rig" );
	level.player HideViewModel();
	
	guys = [];
//	guys["ally_0"] = dam_break_ally_01;
//	guys["ally_1"] = dam_break_ally_02;
//	guys["ally_2"] = dam_break_ally_03;
	guys["dam_break_player_legs"] = dam_break_player_legs;
	guys["player_rig"] = player_rig;
	guys["dam_break_m880"] = dam_break_m880;
	//guys["dam_break_dam"] = dam_break_dam;
	guys["dam_break_helmet"] = dam_break_helmet; 

	arc = 0;
	level.player PlayerLinkToBlend( player_rig, "tag_player", .25,.125,.125); 
//	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1); 
	
	level.player DisableWeapons();

	node = getstruct("vignette_dam_and_church_destruction", "script_noteworthy");
	
	thread play_dam_break_water(node);
	
	thread play_dam_destruction_anim();
	
	node = getstruct("vignette_dam_break", "script_noteworthy");
	
	thread change_dof();
	
	thread enable_player_control( player_rig );
	thread enable_lens_vignette( player_rig );

	//thread maps\flood_fx::lgt_shadow_improve_dam();
	
	level notify("dam_break_start");
	
	foreach( ally in level.allies )
		ally thread dam_break_ally( node );
	
	level thread maps\flood_streets::add_dam_vignette_hud_overlay();
	node anim_single(guys, "dam_break");
	
	level.player ShowViewModel(); 

	level.player unlink();

	player_rig delete();
	
	// if your current weapon isn't a rifle, switch to the first rifle we find since the timing works better with rifles
	if( WeaponClass( level.player GetCurrentPrimaryWeapon() ) != "rifle" )
	{
		weaplist = level.player GetWeaponsListPrimaries();
		foreach( weap in weaplist )
		{
			if( WeaponClass( weap ) == "rifle" )
			{
				level.player SwitchToWeaponImmediate( weap );
				break;
			}
		}
	}

	level.player EnableWeapons();

	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );
//	SetDvar("slide_enable", "1");
	
	SetSavedDvar( "g_friendlyNameDist", g_friendlyNameDist_old );

	//added flag to end of vignette so we can check if it's over
	flag_set("vignette_dam_break_end_flag");
	
	VisionSetNaked("flood", 3);
	
}

dam_break_ally( node )
{
	self endon( "death" );
	
	self thread dam_break_ally_hide(3);
	
	switch( self.animname )
	{
		case "ally_0":
			self SetGoalPos( getstruct( "ally0_flee_face", "targetname" ).origin );
			node anim_single_solo( self, "dam_break" );
			self thread maps\flood_flooding::ally0_main();
			break;
		case "ally_1":
			self SetGoalNode( GetNode( "ally1_flee_face", "targetname" ) );
			node anim_single_solo( self, "dam_break" );
			self thread maps\flood_flooding::ally1_main();
			break;
		case "ally_2":
			self SetGoalNode( GetNode( "ally2_flee_face", "targetname" ) );
			node anim_single_solo( self, "dam_break" );
			self thread maps\flood_flooding::ally2_main();
			break;
	}
}

dam_break_ally_hide(timer)
{
	self hide();
	
	wait(timer);
	
	self show();
}

opfor_m880_escape_spawn(guys)
{
	dam_break_opfor_m880 = vignette_actor_spawn("vignette_dam_break_opfor_m880", "dam_break_opfor_m880"); //"value" (kvp), "anim_name"

	opfor_m880_escape(guys, dam_break_opfor_m880);

	dam_break_opfor_m880 vignette_actor_delete();
}

opfor_m880_escape(guys, dam_break_opfor_m880)
{

	node = getstruct("vignette_dam_break", "script_noteworthy");


	guys = [];
	guys["dam_break_opfor_m880"] = dam_break_opfor_m880;

	node anim_single(guys, "opfor_m880_escape");

}

init_dam_destruction_anim()
{
	node = getstruct("vignette_dam_and_church_destruction", "script_noteworthy");
	
	level.dam_break_dam = spawn_anim_model("dam_break_dam");
	
	dam = getent("flood_dam", "targetname");
	if(isdefined(dam))
	{
		dam hide();
	}
	
	guys = [];
	guys["dam_break_dam"] = level.dam_break_dam;
	
	node anim_first_frame(guys, "dam_break_dam_destruction");
}

play_dam_destruction_anim()
{
	node = getstruct("vignette_dam_and_church_destruction", "script_noteworthy");
	
	if(!isdefined(level.dam_break_dam))
	{
		level.dam_break_dam = spawn_anim_model("dam_break_dam");
	}
	
	guys = [];
	guys["dam_break_dam"] = level.dam_break_dam;
	
	thread maps\flood_fx::fx_dam_explosion();
	thread maps\flood_streets::dam_waterfall_hide();

	node anim_single(guys, "dam_break_dam_destruction");
}

play_cone_anims(guys)
{
	node = getstruct("vignette_dam_break", "script_noteworthy");
	
	dam_break_cone_01 = spawn_anim_model("dam_break_cone_01");
	col = GetEnt( "cone_collision1", "targetname" );
	col.origin = dam_break_cone_01 GetTagOrigin( "com_trafficcone02" );
	col.angles = dam_break_cone_01 GetTagAngles( "com_trafficcone02" );
	col LinkTo( dam_break_cone_01, "com_trafficcone02", ( 0, 0, 20 ), ( 0, 0, 0 ) );
	
	dam_break_cone_02 = spawn_anim_model("dam_break_cone_02");
	col = GetEnt( "cone_collision2", "targetname" );
	col.origin = dam_break_cone_02 GetTagOrigin( "com_trafficcone02" );
	col.angles = dam_break_cone_02 GetTagAngles( "com_trafficcone02" );
	col LinkTo( dam_break_cone_02, "com_trafficcone02", ( 0, 0, 20 ), ( 0, 0, 0 ) );
	
	dam_break_cone_03 = spawn_anim_model("dam_break_cone_03");
	
	dam_break_barrier_01 = spawn_anim_model("dam_break_barrier_01");
	
	dam_break_barrier_02 = spawn_anim_model("dam_break_barrier_02");
	
	dam_break_barrier_03 = spawn_anim_model("dam_break_barrier_03");

	guys = [];
	guys["dam_break_cone_01"] = dam_break_cone_01;
	guys["dam_break_cone_02"] = dam_break_cone_02;
	guys["dam_break_cone_03"] = dam_break_cone_03;
	guys["dam_break_barrier_01"] = dam_break_barrier_01; 
	guys["dam_break_barrier_02"] = dam_break_barrier_02;
	guys["dam_break_barrier_03"] = dam_break_barrier_03;

	node anim_single(guys, "dam_break_cones");
}

enable_player_control( player_rig )
{
//	player_rig waittill_notetrack_or_damage("start_vignetting");
//	flag_set("vignette_lens");
	
	player_rig waittill_notetrack_or_damage("player_control");

	arc = 15;
	
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1); 
	level.player SpringCamEnabled( 1.0, 3.2, 1.6 );
	
//	player_rig waittill_notetrack_or_damage("end_vignetting");
//	flag_set("vignette_lens_fade_out");
}

enable_lens_vignette(player_rig)
{
	self endon( "death" );
	
	player_rig waittillmatch( "single anim", "start_vignetting" );
//	player_rig waittill_notetrack_or_damage("start_vignetting");
	flag_set("vignette_lens");
	
	player_rig waittillmatch( "single anim", "end_vignetting" );
//	player_rig waittill_notetrack_or_damage("end_vignetting");
	flag_set("vignette_lens_fade_out");
}

change_dof()
{
	maps\_art::dof_enable_script( 0, 184, 4, 777, 11650, 0, 0.25 );
	
	wait 11.67;
	
	maps\_art::dof_disable_script( 1.5 );
}
	
dam_break_missile_01( guys )
{
	node = getstruct("vignette_dam_break", "script_noteworthy");
	
	dam_break_missile_01 = spawn_anim_model("dam_break_missile_01");
	
	dam_break_missile_01 Hide(); 
	
	
	guys = [];
	guys["dam_break_missile_01"] = dam_break_missile_01;
	
	thread maps\flood_fx::fx_dam_missile_afterburn_01(); 

	node thread anim_single(guys, "dam_break_missile_01");
	
	fx = getfx( "flood_m880_missile_trail_01" );
	fx2 = getfx( "flood_m880_missile_begin" );
	PlayFXOnTag( fx2, dam_break_missile_01, "tag_fx" );
	wait 0.01;
	PlayFXOnTag( fx, dam_break_missile_01, "tag_fx" );

	//wait 0.1;
	//StopFXOnTag( fx2, dam_break_missile_01, "tag_fx" );

}

dam_break_missile_02( guys )
{
	node = getstruct("vignette_dam_break", "script_noteworthy");
	
	dam_break_missile_02 = spawn_anim_model("dam_break_missile_02");
	
	dam_break_missile_02 Hide();
	

	guys = [];
	guys["dam_break_missile_02"] = dam_break_missile_02;

	thread maps\flood_fx::fx_dam_missile_launch_02(); // play rocket launch vfx

	node thread anim_single(guys, "dam_break_missile_02");
	
	fx = getfx( "flood_m880_missile_trail_01" );
	fx2 = getfx( "flood_m880_missile_begin" );
	PlayFXOnTag( fx2, dam_break_missile_02, "tag_fx" );
	wait 0.01;
	PlayFXOnTag( fx, dam_break_missile_02, "tag_fx" );
	
	//wait 0.1;
	//StopFXOnTag( fx2, dam_break_missile_02, "tag_fx" );

}

dam_break_missile_03( guys )
{
	node = getstruct("vignette_dam_break", "script_noteworthy");
	
	dam_break_missile_03 = spawn_anim_model("dam_break_missile_03");
	
	dam_break_missile_03 Hide();
	
	
	guys = [];
	guys["dam_break_missile_03"] = dam_break_missile_03;
	
	thread maps\flood_fx::fx_dam_missile_launch_03(); // play rocket launch vfx
	
	node thread anim_single(guys, "dam_break_missile_03");
	
	fx = getfx( "flood_m880_missile_trail_01" );
	fx2 = getfx( "flood_m880_missile_begin" );
	PlayFXOnTag( fx2, dam_break_missile_03, "tag_fx" );
	wait 0.01;
	PlayFXOnTag( fx, dam_break_missile_03, "tag_fx" );
	//wait 0.1;
	//StopFXOnTag( fx2, dam_break_missile_03, "tag_fx" );
	
}

dam_break_missile_04( guys )
{
	node = getstruct("vignette_dam_break", "script_noteworthy");
	
	dam_break_missile_04 = spawn_anim_model("dam_break_missile_04");
	
	dam_break_missile_04 Hide();
	
	
	guys = [];
	guys["dam_break_missile_04"] = dam_break_missile_04;
	
	thread maps\flood_fx::fx_dam_missile_launch_04(); // play rocket launch vfx


	node thread anim_single(guys, "dam_break_missile_04");
	
	fx = getfx( "flood_m880_missile_trail_01" );
	fx2 = getfx( "flood_m880_missile_begin" );
	PlayFXOnTag( fx2, dam_break_missile_04, "tag_fx" );
	wait 0.01;
	PlayFXOnTag( fx, dam_break_missile_04, "tag_fx" );
	
	//wait 0.1;
	//StopFXOnTag( fx2, dam_break_missile_04, "tag_fx" );
}


play_dam_break_water(node)
{
	thread maps\flood_fx::dam_flood_fx();
}

dam_break_street_water_init()
{
	node = getstruct("vignette_dam_break_floating_objects", "script_noteworthy");

	dam_break_street_debris = spawn_anim_model("dam_break_street_debris");
	
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone01", "j_flood_dam_street_street_debris_com_trafficcone01_1" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone01", "j_flood_dam_street_street_debris_com_trafficcone01_2" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone01", "j_flood_dam_street_street_debris_com_trafficcone01_3" );
	attach_fx_anim_model( dam_break_street_debris, "vehicle_iveco_lynx_iw6", "j_flood_dam_street_street_debris_vehicle_iveco_lynx_iw6_4" );
	//1 don't spawn this one till animation needs it
//	attach_fx_anim_model( dam_break_street_debris, "vehicle_iveco_lynx_iw6", "j_flood_dam_street_street_debris_vehicle_iveco_lynx_iw6_5" );
	attach_fx_anim_model( dam_break_street_debris, "vehicle_iveco_lynx_iw6", "j_flood_dam_street_street_debris_vehicle_iveco_lynx_iw6_6" );
	attach_fx_anim_model( dam_break_street_debris, "flood_light_generator", "j_flood_dam_street_street_debris_flood_light_generator_7" );
	attach_fx_anim_model( dam_break_street_debris, "flood_light_generator", "j_flood_dam_street_street_debris_flood_light_generator_8" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_9" );
	//2 don't spawn this one till animation needs it
//	attach_fx_anim_model( dam_break_street_debris, "vehicle_man_7t_iw6", "j_flood_dam_street_street_debris_vehicle_man_7t_iw6_10" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_11" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_12" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_13" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_14" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_15" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_16" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_17" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_18" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_19" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_20" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_21" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_22" );
	attach_fx_anim_model( dam_break_street_debris, "vehicle_man_7t_iw6", "j_flood_dam_street_street_debris_vehicle_man_7t_iw6_23" );
	attach_fx_anim_model( dam_break_street_debris, "flood_light_generator", "j_flood_dam_street_street_debris_flood_light_generator_24" );
	//3 don't spawn this one till animation needs it
//	attach_fx_anim_model( dam_break_street_debris, "vehicle_man_7t_iw6", "j_flood_dam_street_street_debris_vehicle_man_7t_iw6_25" );
	attach_fx_anim_model( dam_break_street_debris, "vehicle_iveco_lynx_iw6", "j_flood_dam_street_street_debris_vehicle_iveco_lynx_iw6_26" );
	attach_fx_anim_model( dam_break_street_debris, "flood_light_generator", "j_flood_dam_street_street_debris_flood_light_generator_27" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_28" );
	attach_fx_anim_model( dam_break_street_debris, "com_trafficcone02", "j_flood_dam_street_street_debris_com_trafficcone02_29" );
	
	dam_break_street_debris Hide();
	

	guys = [];
	guys["dam_break_street_debris"] = dam_break_street_debris;
	
	level.dam_break_street_debris = dam_break_street_debris;

	node anim_first_frame(guys, "dam_break_street_water");	
}

dam_break_street_water( guys )
{
	node = getstruct("vignette_dam_break_floating_objects", "script_noteworthy");

	//so we don't duplicate these until the animation needs them
	attach_fx_anim_model( level.dam_break_street_debris, "vehicle_iveco_lynx_iw6", "j_flood_dam_street_street_debris_vehicle_iveco_lynx_iw6_5" );
	attach_fx_anim_model( level.dam_break_street_debris, "vehicle_man_7t_iw6", "j_flood_dam_street_street_debris_vehicle_man_7t_iw6_10" );
	attach_fx_anim_model( level.dam_break_street_debris, "vehicle_man_7t_iw6", "j_flood_dam_street_street_debris_vehicle_man_7t_iw6_25" );
	
	guys = [];
	guys["dam_break_street_water_01"] = level.dam_break_street_water_01;
	guys["dam_break_street_water_02"] = level.dam_break_street_water_02;
	guys["dam_break_street_water_03"] = level.dam_break_street_water_03;
	guys["dam_break_street_water_04"] = level.dam_break_street_water_04;
	guys["dam_break_street_debris"] = level.dam_break_street_debris;

	delayThread( 6, maps\flood_fx::fx_bokehdots_and_waterdrops_heavy, 4 );
	delayThread( 7, maps\flood_fx::fx_bokehdots_and_waterdrops_heavy, 4 );
	delayThread( 8, maps\flood_fx::fx_bokehdots_and_waterdrops_heavy, 4 );
	// this is just temp to keep you from hiding from the flood collision until we have proper flood collision
	delayThread( 6, maps\flood_flooding::angry_flood_collision_cheater, "waterball_path_1" );
	delayThread( 8, maps\flood_fx::alley_fill_shallow, "alley_fill_shallow_start", "alley_rising_water_start", ( -650, -4104, -58 ), 9.4, "flood_water_alley_fill_shallow_left" );

//	thread maps\flood_flooding::angry_flood_collision( guys, 128, 4, "player_doing_warehouse_mantle" );
	
	thread maps\flood_fx::angry_flood_water();
	node anim_single(guys, "dam_break_street_water");
}

church_destruction_init()
{
//	level.dam_break_m880 = vignette_vehicle_spawn("dam_break_m880", "dam_break_m880"); //"value" (kvp), "anim_name"
	
	level.dam_break_church_spire = spawn_anim_model("dam_break_church_spire");
	
	node = getstruct("vignette_dam_and_church_destruction", "script_noteworthy");

	node anim_first_frame_solo(level.dam_break_church_spire, "start_church_destruction");	
}

start_church_destruction(guys)
{

	node = getstruct("vignette_dam_and_church_destruction", "script_noteworthy");

//	dam_break_church_spire = spawn_anim_model("dam_break_church_spire");


	guys = [];
	guys["dam_break_church_spire"] = level.dam_break_church_spire;
	
	thread maps\flood_fx::dam_street_flood_church_hits();
	wait 3.5;

	node anim_single(guys, "start_church_destruction");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// palm trees
palm_tree_spawn()
{

	palm_tree();

}

palm_tree()
{

	node = getstruct("vignette_plam_tree", "script_noteworthy");

	palm_tree_01 = spawn_anim_model("palm_tree_01");


	guys = [];
	guys["palm_tree_01"] = palm_tree_01;

	node anim_single(guys, "palm_tree");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// stop sign
street_stop_sign_01_spawn()
{
	node = getstruct("vignette_street_stop_sign_01", "script_noteworthy");

	flood_stop_sign_01 = spawn_anim_model("flood_stop_sign_01");

	guys = [];
	guys["flood_stop_sign_01"] = flood_stop_sign_01;

	node anim_first_frame(guys, "street_stop_sign_01");

	flag_wait("vignette_streets_stop_sign_01");
	
	street_stop_sign_01(flood_stop_sign_01);

}

street_stop_sign_01(flood_stop_sign_01)
{

	node = getstruct("vignette_street_stop_sign_01", "script_noteworthy");

	guys = [];
	guys["flood_stop_sign_01"] = flood_stop_sign_01;

	node anim_single(guys, "street_stop_sign_01");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Convoy Checkpoint
convoy_checkpoint_spawn()
{
	convoy_checkpoint_opfor01 = vignette_actor_spawn("convoy_checkpoint_opfor01", "convoy_checkpoint_opfor01"); //"value" (kvp), "anim_name"
	convoy_checkpoint_opfor02 = vignette_actor_spawn("convoy_checkpoint_opfor02", "convoy_checkpoint_opfor02"); //"value" (kvp), "anim_name"
	convoy_checkpoint_opfor03 = vignette_actor_spawn("convoy_checkpoint_opfor03", "convoy_checkpoint_opfor03"); //"value" (kvp), "anim_name"
	convoy_checkpoint_opfor04 = vignette_actor_spawn("convoy_checkpoint_opfor04", "convoy_checkpoint_opfor04"); //"value" (kvp), "anim_name"

	convoy_checkpoint(convoy_checkpoint_opfor01, convoy_checkpoint_opfor02, convoy_checkpoint_opfor03, convoy_checkpoint_opfor04);

	convoy_checkpoint_opfor01 vignette_actor_delete();
	convoy_checkpoint_opfor02 vignette_actor_delete();
	convoy_checkpoint_opfor03 vignette_actor_delete();
	convoy_checkpoint_opfor04 vignette_actor_delete();
}

convoy_checkpoint(convoy_checkpoint_opfor01, convoy_checkpoint_opfor02, convoy_checkpoint_opfor03, convoy_checkpoint_opfor04)
{

	node = getstruct("vignette_convoy_checkpoint_node", "script_noteworthy");

	convoy_checkpoint_radio = spawn_anim_model("convoy_checkpoint_radio");
	
	convoy_checkpoint_radio thread maps\flood_streets::delete_on_flag("enemy_alerted");
	
	guys = [];	
	if(isdefined(convoy_checkpoint_opfor02))
	{
		//moving anim start to -1443 for guy next to barriers...so he doesn't get killed
		guys["convoy_checkpoint_opfor02"] = convoy_checkpoint_opfor02;
		node.origin = node.origin + (60,0,0);
		node thread anim_single(guys, "convoy_checkpoint");
		node.origin = node.origin + (-60,0,0);
	}
	
	guys = [];
	if(isdefined(convoy_checkpoint_opfor01))
	{
		guys["convoy_checkpoint_opfor01"] = convoy_checkpoint_opfor01;
	}
	if(isdefined(convoy_checkpoint_opfor03))
	{
		guys["convoy_checkpoint_opfor03"] = convoy_checkpoint_opfor03;
	}
	if(isdefined(convoy_checkpoint_opfor04))
	{
		guys["convoy_checkpoint_opfor04"] = convoy_checkpoint_opfor04;
	}
	if(isdefined(convoy_checkpoint_radio))
	{
		guys["convoy_checkpoint_radio"] = convoy_checkpoint_radio;
	}
	node anim_single(guys, "convoy_checkpoint");
	
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


m880_crash_spawn(m880_crash_m880, convoy_lynx)
{
	//m880_crash_m880 = vignette_vehicle_spawn("target_name", "m880_crash_m880"); //"value" (kvp), "anim_name"
//	convoy_lynx = vignette_vehicle_spawn("convoy_lynx", "convoy_lynx"); //"value" (kvp), "anim_name"
//	convoy_lynx = level.launcher_lynx;
	m880_crash(m880_crash_m880, convoy_lynx);

	//m880_crash_m880 vignette_vehicle_delete();
//	convoy_lynx vignette_vehicle_delete();
}

m880_crash( m880_crash_m880, convoy_lynx )
{

	
	node = getstruct("vignette_m880_crash", "script_noteworthy");
	//Play Debris Anims
	node notify("start_crash_debris");
	//Play Barrel Debris Anims, these are longer than everything else hence the new thread.
	node notify("start_crash_barrels");
	
	guys = [];
	guys["m880_crash_m880"] = m880_crash_m880;
//	guys["convoy_lynx"] = convoy_lynx;
		
//	m880_crash_m880 notify( "suspend_drive_anims" );

	//Play Vehicle Anims
	
	convoy_lynx thread m880_lynx_crash();
	animation = level.scr_anim[ "m880_crash_m880" ][ "m880_crash" ];
	anim_point = node;
	struct = SpawnStruct();
	struct.origin = GetStartOrigin( anim_point.origin, anim_point.angles, animation );
	struct.angles = GetStartAngles( anim_point.origin, anim_point.angles, animation );

//	car = self;
//	IPrintLn("m880 start orienting");
	m880_crash_m880 Vehicle_OrientTo( struct.origin, struct.angles, 25.0, 0.0 );
//	IPrintLn("m880 waiting");
	m880_crash_m880 waittill( "orientto_complete" );

//	IPrintLn("m880 done orienting");
	
	m880_crash_m880 notify( "suspend_drive_anims" );
//	m880_crash_m880 AnimScripted( "car_anim", anim_point.origin, anim_point.angles, animation );
	
	node anim_single(guys, "m880_crash");	

}

m880_lynx_crash()
{
//	animation = %flood_convoy_crash_lynx;
//	node = getstruct("vignette_m880_crash", "script_noteworthy");
	
	guys = [];
	guys["convoy_lynx"] = self;
	
	animation = level.scr_anim[ "convoy_lynx" ][ "m880_crash" ];
	anim_point = getstruct("vignette_m880_crash", "script_noteworthy");

	struct = SpawnStruct();
	struct.origin = GetStartOrigin( anim_point.origin, anim_point.angles, animation );
	struct.angles = GetStartAngles( anim_point.origin, anim_point.angles, animation );

	car = self;
	
	car Vehicle_OrientTo( struct.origin, struct.angles, 25.0, 0.0 );
	car waittill( "orientto_complete" );

	car notify( "suspend_drive_anims" );
	level notify("lynx_crash_start");
//	car AnimScripted( "car_anim", anim_point.origin, anim_point.angles, animation );
	anim_point anim_single(guys, "m880_crash");
	level notify("lynx_crash_end");
}

//m880_crash_animated_script_model( vehicle, anim_point, animtree, animation )
//{
//	if ( GetDvarInt( "show_script_model" ) == 0 )
//	{
//		return;
//	}
//
////	offset = ( 0, -300, 0 );
//	offset = ( 0, 0, 0 );
//	ent = Spawn( "script_model", anim_point.origin );
//	ent SetModel( vehicle.model );
//	ent UseAnimTree( animtree );
//
//	ent AnimScripted( "blah", anim_point.origin + offset, anim_point.angles, animation );
//	
//	vehicle waittill( "death" );
//	wait( 1 );
//	ent Delete();
//}
//
//lynx_crash_hold_loop(convoy_lynx)
//{
//	convoy_lynx endon("death");
////	wait(1.0);
//	
//	convoy_lynx notify( "suspend_drive_anims" );
//	while(1)
//	{
//		self anim_single_solo(convoy_lynx, "m880_crash_hold");	
//	}
//}


m880_crash_loop(m880_crash_m880)
{
	m880_crash_m880 endon("stop_crash_loop");
	
	node = getstruct("vignette_m880_crash", "script_noteworthy");
//
//	convoy_barrier_tall_01 = spawn_anim_model("convoy_barrier_tall_01");
//
//	convoy_barrier_tall_02 = spawn_anim_model("convoy_barrier_tall_02");

//	m880_radiation_gate = spawn_anim_model("m880_radiation_gate");

	guys = [];
	guys["m880_crash_m880"] = m880_crash_m880;
	guys["convoy_barrier_tall_01"] = level.convoy_tall_barricade_01;
	guys["convoy_barrier_tall_02"] = level.convoy_tall_barricade_02;
	guys["m880_radiation_gate"] = level.m880_radiation_gate;

//	node anim_single(guys, "m880_crash_loop");
	node thread anim_loop(guys, "m880_crash_loop", "stop_crash_loop");
	
//	wait(10);
//	
//	node notify("stop_crash_loop");

}

m880_crash_anim_init()
{
	wait(.1);
	node = getstruct("vignette_m880_crash", "script_noteworthy");
	
	thread m880_crash_barrels( node );	
	
	thread m880_crash_debris( node );
	
	thread m880_crash_debris_left_side( node );
}

m880_crash_debris( node )
{
	convoy_debris_cone_01 = spawn_anim_model("convoy_debris_cone_01");

	convoy_debris_cone_02 = spawn_anim_model("convoy_debris_cone_02");

	convoy_debris_cone_03 = spawn_anim_model("convoy_debris_cone_03");

	convoy_plastic_barricade_01 = spawn_anim_model("convoy_plastic_barricade_01");

	convoy_plastic_barricade_02 = spawn_anim_model("convoy_plastic_barricade_02");

	convoy_plastic_barricade_03 = spawn_anim_model("convoy_plastic_barricade_03");

	convoy_plastic_barricade_04 = spawn_anim_model("convoy_plastic_barricade_04");

	level.convoy_tall_barricade_01 = spawn_anim_model("convoy_tall_barricade_01");

	level.convoy_tall_barricade_02 = spawn_anim_model("convoy_tall_barricade_02");

	convoy_short_barricade_01 = spawn_anim_model("convoy_short_barricade_01");
	
	convoy_debris_lynx = spawn_anim_model("convoy_debris_lynx");

	convoy_debris_m880_01 = spawn_anim_model("convoy_debris_m880_01");

	convoy_debris_m880_02 = spawn_anim_model("convoy_debris_m880_02");

	convoy_debris_m880_03 = spawn_anim_model("convoy_debris_m880_03");

//	level.m880_radiation_gate = spawn_anim_model("m880_radiation_gate");
	level.m880_radiation_gate = getent("checkpoint_gate", "targetname");
	level.m880_radiation_gate.animname = "m880_radiation_gate";
	level.m880_radiation_gate assign_animtree();

	guys = [];
	guys["convoy_debris_cone_01"] = convoy_debris_cone_01;
	guys["convoy_debris_cone_02"] = convoy_debris_cone_02;
	guys["convoy_debris_cone_03"] = convoy_debris_cone_03;
	guys["convoy_plastic_barricade_01"] = convoy_plastic_barricade_01;
	guys["convoy_plastic_barricade_02"] = convoy_plastic_barricade_02;
	guys["convoy_plastic_barricade_03"] = convoy_plastic_barricade_03;
	guys["convoy_plastic_barricade_04"] = convoy_plastic_barricade_04;
	guys["convoy_tall_barricade_01"] = level.convoy_tall_barricade_01;
	guys["convoy_tall_barricade_02"] = level.convoy_tall_barricade_02;
	guys["convoy_short_barricade_01"] = convoy_short_barricade_01;
	guys["convoy_debris_lynx"] = convoy_debris_lynx;
	guys["convoy_debris_m880_01"] = convoy_debris_m880_01;
//	guys["convoy_debris_m880_02"] = convoy_debris_m880_02;
	guys["convoy_debris_m880_03"] = convoy_debris_m880_03;
	guys["m880_radiation_gate"] = level.m880_radiation_gate;

	node anim_first_frame(guys, "m880_crash_debris");

//	//spawn unbroken models until anim starts
	
	convoy_unbroken_debris_m880_01 = getent("checkpoint_concrete_swap_barrier_1", "targetname");
	convoy_unbroken_debris_m880_02 = getent("checkpoint_concrete_swap_barrier_2", "targetname");
	//get rid of this one
	convoy_unbroken_debris_m880_02 delete();
	convoy_unbroken_debris_m880_03 = getent("checkpoint_concrete_swap_barrier_3", "targetname");

	convoy_debris_m880_01 hide();
//	convoy_debris_m880_02 hide();
	convoy_debris_m880_03 hide();
	
	node thread m880_crash_debris_collision_change();
	
	node waittill("start_crash_debris");
	
	show_array = [convoy_debris_m880_01, convoy_debris_m880_03];
//	show_array = [convoy_debris_m880_01, convoy_debris_m880_02, convoy_debris_m880_03];
	delete_array = [convoy_unbroken_debris_m880_01, convoy_unbroken_debris_m880_03];
//	delete_array = [convoy_unbroken_debris_m880_01, convoy_unbroken_debris_m880_02, convoy_unbroken_debris_m880_03];
		
	thread wait_show_and_delete_debris(2.5, show_array, delete_array);

	node anim_single(guys, "m880_crash_debris");
	
	node notify("change_collision");
	
//	convoy_debris_m880_01 delete();
//
//	convoy_debris_m880_02 delete();
//
//	convoy_debris_m880_03 delete();

}

wait_show_and_delete_debris(timer, show_array, delete_array)
{
	wait(timer);
	
	foreach ( thing in show_array)
	{
		thing show();
	}
	
	foreach ( thing in delete_array)
	{
		thing delete();
	}	
}

m880_crash_debris_left_side( node )
{
	node waittill("start_crash_debris");
	
	wait(4.0);
	
	node = getstruct("vignette_m880_crash_left", "script_noteworthy");
	
//	convoy_debris_m880_01 = spawn_anim_model("convoy_debris_m880_01");

	convoy_debris_m880_02 = spawn_anim_model("convoy_debris_m880_02");

//	convoy_debris_m880_03 = spawn_anim_model("convoy_debris_m880_03");

	guys = [];
		
//	guys["convoy_debris_m880_01"] = convoy_debris_m880_01;
	guys["convoy_debris_m880_02"] = convoy_debris_m880_02;
//	guys["convoy_debris_m880_03"] = convoy_debris_m880_03;
	
	
	node.origin = node.origin + (0, -25,0);
//	node anim_single(guys, "m880_crash_debris");
	node anim_last_frame_solo(convoy_debris_m880_02, "m880_crash_debris");
//	node anim_last_frame_solo(convoy_debris_m880_03, "m880_crash_debris");

}

m880_crash_debris_collision_change()
{
	collision_array = GetEntArray("clip_after_m880_crash", "targetname");
	foreach ( brush in collision_array)
	{
		brush hide();
		brush NotSolid();
	}
	
	self waittill("start_crash_debris");
	
	wait(2.9);
	
//	self waittill("change_collision");
	
	collision_array = GetEntArray("clip_before_m880_crash", "targetname");
	foreach ( brush in collision_array)
	{
		brush delete();
	}
	
	collision_array = GetEntArray("clip_after_m880_crash", "targetname");
	foreach ( brush in collision_array)
	{
		if(level.player istouching(brush))
		{
			brush thread push_player_out_of_brush((20,0,0));
		}
		else
		{
			brush show();
			brush Solid();
		}
		
	}
}

//call on brush that's going to be made solid
//if player is touching apply vector to player until not touching
push_player_out_of_brush(vector)
{
	while(level.player istouching(self))
	{
		level.player PushPlayerVector(vector, true);
				
		waitframe();
	}
	level.player PushPlayerVector((0, 0, 0));
	
	self show();
	self Solid();
}

m880_crash_barrels( node )
{
	convoy_debris_barrel_01 = spawn_anim_model("convoy_debris_barrel_01");

	convoy_debris_barrel_02 = spawn_anim_model("convoy_debris_barrel_02");

	convoy_debris_barrel_03 = spawn_anim_model("convoy_debris_barrel_03");

	convoy_debris_barrel_04 = spawn_anim_model("convoy_debris_barrel_04");

//	convoy_debris_barrel_05 = spawn_anim_model("convoy_debris_barrel_05");

	convoy_debris_barrel_06 = spawn_anim_model("convoy_debris_barrel_06");

	convoy_debris_barrel_07 = spawn_anim_model("convoy_debris_barrel_07");


	guys = [];
	guys["convoy_debris_barrel_01"] = convoy_debris_barrel_01;
	guys["convoy_debris_barrel_02"] = convoy_debris_barrel_02;
	guys["convoy_debris_barrel_03"] = convoy_debris_barrel_03;
	guys["convoy_debris_barrel_04"] = convoy_debris_barrel_04;
//	guys["convoy_debris_barrel_05"] = convoy_debris_barrel_05;
	guys["convoy_debris_barrel_06"] = convoy_debris_barrel_06;
	guys["convoy_debris_barrel_07"] = convoy_debris_barrel_07;

	node anim_first_frame(guys, "m880_crash_barrels");
	
	node waittill("start_crash_barrels");
	

	node anim_single(guys, "m880_crash_barrels");
	/*
	wait 3;
	PlayFXOnTag( level._effect[ "flood_vignette_sparks_runner" ], convoy_debris_barrel_01, "polySurface19" );
	PlayFXOnTag( level._effect[ "flood_vignette_sparks_runner" ], convoy_debris_barrel_02, "polySurface19" );
	PlayFXOnTag( level._effect[ "flood_vignette_sparks_runner" ], convoy_debris_barrel_03, "polySurface19" );
	wait 2;
	PlayFXOnTag( level._effect[ "flood_vignette_sparks_runner" ], convoy_debris_barrel_04, "polySurface19" );
	PlayFXOnTag( level._effect[ "flood_vignette_sparks_runner" ], convoy_debris_barrel_06, "polySurface19" );
	PlayFXOnTag( level._effect[ "flood_vignette_sparks_runner" ], convoy_debris_barrel_07, "polySurface19" );
*/
}





//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Launcher Callout 01

launcher_callout_ally01_spawn()
{
	launcher_callout_ally01 = vignette_actor_spawn("launcher_callout_ally01", "launcher_callout_ally01"); //"value" (kvp), "anim_name"

	launcher_callout_ally01(launcher_callout_ally01);

	launcher_callout_ally01 vignette_actor_delete();
}

launcher_callout_ally01(launcher_callout_ally01, node_origin, node_angles)
{

	node = getstruct("vignette_launcher_callout_ally01_node", "script_noteworthy");

	if(isdefined(node_origin)  && isdefined(node_angles))
	{
		node.origin = node_origin;
		node.angles = node_angles;		
	}

	guys = [];
	guys["launcher_callout_ally01"] = launcher_callout_ally01;

	node anim_single(guys, "launcher_callout_ally01");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Launcher Callout 02

launcher_callout_ally02_spawn()
{
	launcher_callout_ally02 = vignette_actor_spawn("launcher_callout_ally02", "launcher_callout_ally02"); //"value" (kvp), "anim_name"

	launcher_callout_ally02(launcher_callout_ally02);

	launcher_callout_ally02 vignette_actor_delete();
}

launcher_callout_ally02(launcher_callout_ally02, node_origin, node_angles)
{

	node = getstruct("vignette_launcher_callout_ally02_node", "script_noteworthy");

	if(isdefined(node_origin)  && isdefined(node_angles))
	{
		node.origin = node_origin;
		node.angles = node_angles;		
	}
	
	guys = [];
	guys["launcher_callout_ally02"] = launcher_callout_ally02;

	node anim_single(guys, "launcher_callout_ally02");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Launcher Callout 03

launcher_callout_ally03_spawn()
{
	launcher_callout_ally03 = vignette_actor_spawn("launcher_callout_ally03", "launcher_callout_ally03"); //"value" (kvp), "anim_name"

	launcher_callout_ally03(launcher_callout_ally03);

	launcher_callout_ally03 vignette_actor_delete();
}

launcher_callout_ally03(launcher_callout_ally03, node_origin, node_angles)
{

	node = getstruct("vignette_launcher_callout_ally03_node", "script_noteworthy");

	if(isdefined(node_origin)  && isdefined(node_angles))
	{
		node.origin = node_origin;
		node.angles = node_angles;		
	}
	
	guys = [];
	guys["launcher_callout_ally03"] = launcher_callout_ally03;

	node anim_single(guys, "launcher_callout_ally03");

} 

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

alley_flood_spawn()
{
	alley_flood();
}

alley_flood()
{
	node = getstruct("vignette_alley_flood", "script_noteworthy");

	// FIX JKU should this be on a notetrack when the truck hits or based on the water?
	delayThread( 7.5, maps\flood_flooding::alley_flood_collision_cheater, "waterball_path_4" );
//	thread maps\flood_flooding::angry_flood_collision( guys, 96, 10, "player_at_stairs" );

	startdelay = 0.0;
	thread alley_flood_vehicles_spawn( node, startdelay );
//	delayThread( 0.05, maps\_anim::anim_set_time, guys, "alley_flood", startdelay );
	
	thread maps\flood_fx::alley_flood_fx();
	thread maps\flood_fx::alley_flood_water();
	//node waittill("goal"); // animation is finished playing
	//flag_wait("player_doing_warehouse_mantle");
	

}

alley_flood_vehicles_spawn( node, startdelay )
{
	alley_flood_man7t = vignette_vehicle_spawn("alley_flood_man7t", "alley_flood_man7t"); //"value" (kvp), "anim_name"
	alley_flood_debris = spawn_anim_model( "alley_flood_debris" );
	
	alley_flood_man7t maps\_vehicle::godon();

	guys = [];
	guys[ "alley_flood_man7t" ] = alley_flood_man7t;
	guys[ "alley_flood_debris" ] = alley_flood_debris;

	node thread anim_single( guys, "alley_flood", undefined, 10 );
//	delayThread( 0.05, maps\_anim::anim_set_time, guys, "alley_flood", startdelay );
	
	// Cleanup for TFFs
	flag_wait( "player_at_stairs_stop_nag" );
	
	alley_flood_man7t maps\_vehicle::godoff();
	
	alley_flood_man7t delete();
	alley_flood_debris delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

warehouse_stairs_start_spawn()
{
	warehouse_stairs_ally_01 = vignette_actor_spawn("vignette_warehouse_stairs_ally_01", "warehouse_stairs_ally_01"); //"value" (kvp), "anim_name"
	warehouse_stairs_ally_02 = vignette_actor_spawn("vignette_warehouse_stairs_ally_02", "warehouse_stairs_ally_02"); //"value" (kvp), "anim_name"
	warehouse_stairs_ally_03 = vignette_actor_spawn("vignette_warehouse_stairs_ally_03", "warehouse_stairs_ally_03"); //"value" (kvp), "anim_name"

	warehouse_stairs_start(warehouse_stairs_ally_01, warehouse_stairs_ally_02, warehouse_stairs_ally_03);

	warehouse_stairs_ally_01 vignette_actor_delete();
	warehouse_stairs_ally_02 vignette_actor_delete();
	warehouse_stairs_ally_03 vignette_actor_delete();
}

warehouse_stairs_start(warehouse_stairs_ally_01, warehouse_stairs_ally_02, warehouse_stairs_ally_03)
{

	node = getstruct("vignette_warehouse_stairs", "script_noteworthy");


	guys = [];
	guys["warehouse_stairs_ally_01"] = warehouse_stairs_ally_01;
	guys["warehouse_stairs_ally_02"] = warehouse_stairs_ally_02;
	guys["warehouse_stairs_ally_03"] = warehouse_stairs_ally_03;

	node anim_single(guys, "warehouse_stairs_start");
	
	node anim_single(guys, "warehouse_stairs_loop");
	
	node anim_single(guys, "warehouse_stairs_end");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


/*
heli_crash_intro_spawn()
{

	heli_crash_intro();

//	heli vignette_vehicle_delete();
//	baker vignette_actor_delete();
//	opfor_01 vignette_actor_delete();
//	opfor_02 vignette_actor_delete();
}

heli_crash_intro( heli, baker, opfor_01, opfor_02 )
{
	level.rorke_heli	 = vignette_vehicle_spawn( "heli_crash_helicopter", "heli" ); //"value" (kvp), "anim_name"

	level.opfor_01 = vignette_actor_spawn( "heli_crash_opfor_01", "opfor_01" ); //"value" (kvp), "anim_name"
	level.opfor_02 = vignette_actor_spawn( "heli_crash_opfor_02", "opfor_02" ); //"value" (kvp), "anim_name"
	
	node = getstruct( "vignette_heli_crash", "script_noteworthy" );

	intro				= [];
	intro[ "heli"	  ] = level.rorke_heli;
	intro[ "ally_0"	  ] = level.allies[0];
	intro[ "opfor_01" ] = level.opfor_01;
	intro[ "opfor_02" ] = level.opfor_02;
	
	fight_loop_01				= [];
	fight_loop_01[ "ally_0"	  ] = level.allies[0];
	fight_loop_01[ "opfor_01" ] = level.opfor_01;
	fight_loop_01[ "heli"	  ] = level.rorke_heli;

	node anim_single( intro, "heli_crash_intro" );
	
	//Looping vignette for baker and opfor 01
//	node thread anim_loop( fight_loop_01, "heli_crash_fight_01_loop", "end_heli_intro_loop" );
	
	if( flag( "player_jumped" ) )
	{
		node notify( "end_heli_intro_loop" );
	}
	else
	{
		level notify( "heli_got_away" );
	}
}

heli_crash_player_jump()
{
	node = getstruct( "vignette_heli_crash", "script_noteworthy" );
	
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );

	level.player_rig = spawn_anim_model( "player_rig" );

	guys				 = [];
	guys[ "player_rig" ] = level.player_rig;
	guys[ "heli"	   ] = level.rorke_heli;

	arc = 15;

	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );

	node anim_single( guys, "heli_crash_player_jump" );
}

heli_crash_opfor_fall_out()
{
	node = getstruct( "vignette_heli_crash", "script_noteworthy" );

	guys			   = [];
	guys[ "opfor_02" ] = level.opfor_02;

    node anim_single( guys, "heli_crash_opfor_fall_out" );
    
    level.opfor_02 vignette_actor_delete();
}

heli_crash_fight_02()
{
	opfor_03 = vignette_actor_spawn( "heli_crash_opfor_03", "opfor_03" ); //"value" (kvp), "anim_name"
	
	node = getstruct("vignette_heli_crash", "script_noteworthy");

	guys = [];
	guys["opfor_03"] = opfor_03;

	node anim_single(guys, "heli_crash_fight_02");

	//death for opfor when shot
	node anim_single(guys, "heli_crash_fight_02_dead");

	level notify( "first_heli_enemy_dead" );
	
	opfor_03 vignette_actor_delete();
}

heli_crash_fight_03()
{
	rourke = vignette_actor_spawn( "heli_crash_rourke", "rourke" ); //"value" (kvp), "anim_name"
	
	node = getstruct("vignette_heli_crash", "script_noteworthy");

	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );

	guys = [];
	guys["player_rig"] = level.player_rig;
	guys["rourke"] = rourke;
	guys["heli"] = level.rorke_heli;
	
	arc = 15;

	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	node anim_single(guys, "heli_crash_fight_03");

	level.player unlink();

	level.player_rig delete();
	rourke vignette_actor_delete();
	level.rorke_heli vignette_vehicle_delete();


	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );
	
	level notify( "rorke_heli_end" );
}
*/
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// mall roof door

flood_mall_roof_door_spawn()
{
	vignette_mall_roof_door_ally1 = vignette_actor_spawn("vignette_mall_roof_door_ally1", "vignette_mall_roof_door_ally1"); //"value" (kvp), "anim_name"
	vignette_mall_roof_door_ally2 = vignette_actor_spawn("vignette_mall_roof_door_ally2", "vignette_mall_roof_door_ally2"); //"value" (kvp), "anim_name"
	vignette_mall_roof_door_ally3 = vignette_actor_spawn("vignette_mall_roof_door_ally3", "vignette_mall_roof_door_ally3"); //"value" (kvp), "anim_name"

	flood_mall_roof_door(vignette_mall_roof_door_ally1, vignette_mall_roof_door_ally2, vignette_mall_roof_door_ally3);

	vignette_mall_roof_door_ally1 vignette_actor_delete();
	vignette_mall_roof_door_ally2 vignette_actor_delete();
	vignette_mall_roof_door_ally3 vignette_actor_delete();
}

flood_mall_roof_door( vignette_mall_roof_door_ally3, vignette_mall_roof_door_ally1, vignette_mall_roof_door_ally2, flood_mall_roof_door_model )
{
	node = getstruct( "mall_breach_origin", "targetname" );

	guys = [];
	guys["vignette_mall_roof_door_ally1"] = vignette_mall_roof_door_ally1;
	guys["vignette_mall_roof_door_ally2"] = vignette_mall_roof_door_ally2;
	guys["vignette_mall_roof_door_ally3"] = vignette_mall_roof_door_ally3;
	guys["flood_mall_roof_door_model"] = flood_mall_roof_door_model;
	
//	node anim_reach( guys, "flood_mall_roof_door" );

	node anim_single(guys, "flood_mall_roof_door");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flood_sweptaway()
{

	node = getstruct("flood_sweptaway", "script_noteworthy");

	level.player FreezeControls( true );
	level.player allowprone( false );
	level.player allowcrouch( false );

	player_rig = spawn_anim_model( "player_rig" );

	guys = [];
	guys["player_rig"] = player_rig;

	arc = 15;

	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1);

	level.player DisableWeapons();
	
	node anim_single(guys, "flood_sweptaway");

	level.player unlink();

	player_rig delete();

	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );
	level.player EnableWeapons();

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


sweptaway_spawn()
{
	swept_opfor_floater = vignette_actor_spawn( "swept_opfor_floater", "swept_opfor_floater" ); //"value" (kvp), "anim_name"
	swept_opfor_tree	= vignette_actor_spawn( "swept_opfor_tree", "swept_opfor_tree" ); //"value" (kvp), "anim_name"
	sweptaway_m880		= vignette_vehicle_spawn( "sweptaway_man7t_2", "sweptaway_m880" ); //"value" (kvp), "anim_name"
	sweptaway_man7t		= vignette_vehicle_spawn( "sweptaway_man7t", "sweptaway_man7t" ); //"value" (kvp), "anim_name"

	sweptaway(swept_opfor_floater, swept_opfor_tree, sweptaway_m880, sweptaway_man7t);

	swept_opfor_floater vignette_actor_delete();
	swept_opfor_tree vignette_actor_delete();
	sweptaway_m880 vignette_vehicle_delete();
	sweptaway_man7t vignette_vehicle_delete();
}

sweptaway(swept_opfor_floater, swept_opfor_tree, sweptaway_m880, sweptaway_man7t)
{
	node = getstruct("vignette_sweptaway", "script_noteworthy");

	sweptaway_lynx_01	  = spawn_anim_model( "sweptaway_lynx_01" );
	sweptaway_lynx_02	  = spawn_anim_model( "sweptaway_lynx_02" );
	sweptaway_lynx_03	  = spawn_anim_model( "sweptaway_lynx_03" );
	sweptaway_coupe		  = spawn_anim_model( "sweptaway_coupe" );
	sweptaway_tower_01	  = spawn_anim_model( "sweptaway_tower_01" );
	sweptaway_tower_02	  = spawn_anim_model( "sweptaway_tower_02" );
	sweptaway_tower_03	  = spawn_anim_model( "sweptaway_tower_03" );
	sweptaway_tower_04	  = spawn_anim_model( "sweptaway_tower_04" );
	sweptaway_palm		  = spawn_anim_model( "sweptaway_palm" );
	sweptaway_street_sign = spawn_anim_model( "sweptaway_street_sign" );

	guys							= [];
	guys[ "swept_opfor_floater"	  ] = swept_opfor_floater;
	//guys[ "swept_opfor_tree"	  ] = swept_opfor_tree;
	guys[ "sweptaway_lynx_01"	  ] = sweptaway_lynx_01;
	guys[ "sweptaway_lynx_02"	  ] = sweptaway_lynx_02;
	guys[ "sweptaway_lynx_03"	  ] = sweptaway_lynx_03;
	guys[ "sweptaway_coupe"		  ] = sweptaway_coupe;
	guys[ "sweptaway_m880"		  ] = sweptaway_m880;
	guys[ "sweptaway_man7t"		  ] = sweptaway_man7t;
	guys[ "sweptaway_tower_01"	  ] = sweptaway_tower_01;
	guys[ "sweptaway_tower_02"	  ] = sweptaway_tower_02;
	guys[ "sweptaway_tower_03"	  ] = sweptaway_tower_03;
	guys[ "sweptaway_tower_04"	  ] = sweptaway_tower_04;
	guys[ "sweptaway_palm"		  ] = sweptaway_palm;
	guys[ "sweptaway_street_sign" ] = sweptaway_street_sign;
	
	PlayFXOnTag( level._effect[ "light_car_wide_underwater" ], sweptaway_lynx_01, "tag_headlight_left" );
	PlayFXOnTag( level._effect[ "light_car_wide_underwater" ], sweptaway_lynx_01, "tag_headlight_right" );
	waitframe();
	PlayFXOnTag( level._effect[ "lynx_brakelight" ], sweptaway_lynx_01, "tag_brakelight_left" );
	PlayFXOnTag( level._effect[ "lynx_brakelight" ], sweptaway_lynx_01, "tag_brakelight_right" );
	
	node anim_single(guys, "sweptaway");
}

sweptaway_test()
{
	node = getstruct("vignette_sweptaway", "script_noteworthy");

	swept_opfor_tree = vignette_actor_spawn( "swept_opfor_tree", "swept_opfor_tree" );
	sweptaway_coupe	 = spawn_anim_model( "sweptaway_coupe" );
	
	guys = [];
	guys["swept_opfor_tree"] = swept_opfor_tree;
	guys["sweptaway_coupe"] = sweptaway_coupe;

	node anim_single( guys, "sweptaway" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_doorbreach_setup()
{
	node = getstruct( "vignette_skybridge_doorbreach_node", "script_noteworthy" );

	if( !IsDefined( level.skybridge_door ) )
	{
		clip_loc			 = getstruct( "skybridge_doorbreach_struct", "targetname" );
		level.skybridge_door = spawn_anim_model( "skybridge_door_breach_door", clip_loc.origin );
		origin				 = Spawn( "script_origin", clip_loc.origin );
		origin LinkTo( level.skybridge_door );
		player_clip = GetEnt( "skybridge_doorbreach_clip", "targetname" );
		player_clip LinkTo( origin );
	}

	node anim_first_frame_solo( level.skybridge_door, "skybridge_doorbreach" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_doorbreach_spawn()
{
	node = getstruct( "vignette_skybridge_doorbreach_node", "script_noteworthy" );

	level.allies[ 0 ] clear_archetype();

	if( !IsDefined( level.skybridge_door ) )
	{
		clip_loc			 = getstruct( "skybridge_doorbreach_struct", "targetname" );
		level.skybridge_door = spawn_anim_model( "skybridge_door_breach_door", clip_loc.origin );
		origin				 = Spawn( "script_origin", clip_loc.origin );
		origin LinkTo( level.skybridge_door );
		player_clip = GetEnt( "skybridge_doorbreach_clip", "targetname" );
		player_clip LinkTo( origin );
	}

	guys									   = [];
	guys[ "ally_0" ]						   = level.allies[ 0 ];
	guys[ "skybridge_door_breach_door"		 ] = level.skybridge_door;

	if( !level.allies[ 0 ] NearNode( GetNode( "skybridge_breach_node", "targetname" ) ) )
	{
		node anim_reach_solo( level.allies[ 0 ], "skybridge_doorbreach" );
	}

	node anim_single( guys, "skybridge_doorbreach" );

	level.allies[ 0 ] disable_turnAnims();
	flag_set( "skybridge_vo_1" );

	if( !flag( "vignette_skybridge_approach" ) )
	{
		level.allies[ 0 ] set_force_color( "r" );
	}
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_ally_approach()
{
	level.allies[ 0 ] endon( "player_on_skybridge" );

	level.allies[ 0 ] disable_ai_color();
	level.allies[ 0 ] vignette_actor_ignore_everything();

	node = getstruct("vignette_skybridge_node", "script_noteworthy");

	node anim_reach_solo( level.allies[ 0 ], "skybridge_ally_approach" );

	level.allies[ 0 ] enable_turnAnims();
	node anim_single_solo( level.allies[ 0 ], "skybridge_ally_approach" );

	flag_set( "skybridge_vo_2" );

	level thread skybridge_restart_player_bridge_loop();
	node thread anim_loop_solo( level.allies[ 0 ], "skybridge_ally_loop", "player_on_skybridge" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Skybridge
skybridge_scene_firstframe()
{
	thread skybridge_restart_player_bridge_loop();
	
	node = getstruct("vignette_skybridge_node", "script_noteworthy");

	if ( !IsDefined( level.skybridge_building ) )
	{
		level.skybridge_building = spawn_anim_model( "skybridge_building03" );
	}
	if ( !IsDefined( level.skybridge_bus ) )
	{
		level.skybridge_bus = spawn_anim_model( "skybridge_bus" );
	}
	if ( !IsDefined( level.skybridge_model ) )
	{
		level.skybridge_model = spawn_anim_model( "sweptaway_skybridge_01" );
	}

	guys							 = [];
	guys[ "skybridge_building03"   ] = level.skybridge_building;
	guys[ "skybridge_bus"		   ] = level.skybridge_bus;
	guys[ "sweptaway_skybridge_01" ] = level.skybridge_model;

	node thread anim_first_frame( guys, "skybridge_scene" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree( "script_model" );
skybridge_scene_spawn()
{
	node = getstruct( "vignette_skybridge_node", "script_noteworthy" );

	node thread skybridge_player_bridge_vignette();


	if ( !IsDefined( level.skybridge_building ) )
	{
		level.skybridge_building = spawn_anim_model( "skybridge_building03" );
	}
	if ( !IsDefined( level.skybridge_bus ) )
	{
		level.skybridge_bus = spawn_anim_model( "skybridge_bus" );
	}
	if ( !IsDefined( level.skybridge_model ) )
	{
		level.skybridge_model = spawn_anim_model( "sweptaway_skybridge_01" );
	}

	guys							 = [];
	guys[ "sweptaway_skybridge_01" ] = level.skybridge_model;
	guys[ "skybridge_building03"   ] = level.skybridge_building;
	guys[ "skybridge_bus"		   ] = level.skybridge_bus;

	node thread anim_first_frame( guys, "skybridge_scene" );

	flag_wait( "skybridge_player_outside" );

	node thread anim_single( guys, "skybridge_scene" );

	wait_for_flag_or_time_elapses( "on_skybridge", GetAnimLength( level.scr_anim[ "skybridge_building03" ][ "skybridge_scene" ] ) );
	
	if( !flag( "on_skybridge" ) )
	{
		node thread anim_loop_solo( guys[ "sweptaway_skybridge_01" ], "flood_skybridge_skybridge_loop", "player_land" );
		node thread anim_loop_solo( guys[ "skybridge_building03" ]	, "flood_skybridge_building_loop" , "player_land" );
	}

	flag_wait( "on_skybridge" );
	thread maps\flood_audio::skybridge_wash_away();

	node notify( "player_land" );
	guys[ "sweptaway_skybridge_01" ]StopAnimScripted(  );
	guys[ "skybridge_building03"   ]StopAnimScripted(  );
	node thread anim_single_solo( guys[ "sweptaway_skybridge_01" ], "flood_skybridge_skybridge_part2" );
	node thread anim_single_solo( guys[ "skybridge_building03" ]  , "flood_skybridge_building_part2" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_player_bridge_vignette()
{
	// Wait until TFF is loaded	
	flag_wait( "flood_end_tr_loaded" );
	
	level thread skybridge_restart_player_bridge_loop( undefined, 1 );

	flag_wait( "on_skybridge" );

	self thread skybridge_player_flinch();

	// stop player skybridge's loop
	self notify( "player_bridge_restart" );
	foreach ( section in level.skybridge_sections )
	{
		section StopAnimScripted();
	}

	foreach ( sect in level.skybridge_sections )
	{
		self thread anim_first_frame_solo( sect, "skybridge_break" );
	}

	wait( 0.866 );

	foreach ( sect in level.skybridge_sections )
	{
		self thread anim_single_solo( sect, "skybridge_break" );
	}
	

	thread	maps\flood_fx::fx_skybridge_event();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_restart_player_bridge_loop( start_time, skip_clip )
{
	if ( !IsDefined( level.skybridge_sections ) )
	{
		level.skybridge_sections = [];
		level.skybridge_origins	 = [];
	}
	animation	= undefined;
	loop_length = 0.0;

	node = getstruct( "vignette_skybridge_node", "script_noteworthy" );
	node notify( "player_bridge_restart" );

	if ( 0 < level.skybridge_sections.size )
	{
		foreach ( section in level.skybridge_sections )
		{
			section StopAnimScripted();
		}
		node thread anim_loop( level.skybridge_sections, "skybridge_sway", "player_bridge_restart" );
	}
	else
	{
		for ( index = 0; index < 3; index++ )
		{
			clip_loc						  = getstruct( "skybridge_clip_loc_" + index, "script_noteworthy" );
			level.skybridge_sections[ index ] = spawn_anim_model( "skybridge_sect_" + index, clip_loc.origin );
			if ( IsDefined( skip_clip ) )
			{
				level.skybridge_origins[ index ] = Spawn( "script_origin", clip_loc.origin );
				switch( index )
				{
					case 0:
						level.skybridge_origins[ index ] LinkToBlendToTag( level.skybridge_sections[ index ], "j_bridge_001" );
						break;
		
					case 1:
						level.skybridge_origins[ index ] LinkToBlendToTag( level.skybridge_sections[ index ], "j_bridge_003" );
						break;
		
					case 2:
						level.skybridge_origins[ index ] LinkToBlendToTag( level.skybridge_sections[ index ], "j_bridge_008" );
						break;
		
				}
				player_clip = GetEnt( "skybridge_clip_" + index, "targetname" );
				player_clip LinkTo( level.skybridge_origins[ index ] );
			}
		}
		node thread anim_loop( level.skybridge_sections, "skybridge_sway", "player_bridge_restart" );
	}

	if( IsDefined( start_time ) )
	{
		waittillframeend;
		for ( index = 0; index < level.skybridge_sections.size; index++ )
		{
			animation = level.scr_anim[ "skybridge_sect_" + index ][ "skybridge_sway" ][ 0 ];
			loop_length = GetAnimLength( animation );
			level.skybridge_sections[ index ] SetAnimTime( animation, ( loop_length - start_time ) / loop_length );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_player_flinch()
{
	if( level.player IsSprinting() || level.player IsMeleeing() || level.player IsThrowingGrenade() )
	{
		level.player HideViewModel();
	}
	level.player DisableWeapons();
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player AllowSprint( false );
	level.player StopSliding();
	level.player SetStance( "stand" );
	while( "stand" != level.player GetStance() )
	{
		wait ( 0.05 );
	}

	player_rig = spawn_anim_model( "player_rig" );

	guys				 = [];
	guys[ "player_rig" ] = player_rig;

	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.3 );

	self thread anim_single( guys, "skybridge_flinch" );
	wait ( 0.75 );
	level.player PlayRumbleOnEntity( "light_1s" );
	wait ( 0.25 );
	level.player PlayRumbleOnEntity( "heavy_2s" );
	wait( 0.66 );

	level.player unlink();

	player_rig delete();

	level.player FreezeControls( false );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player AllowSprint( true );
	level.player EnableWeapons();
	level.player ShowViewModel();

	level.player thread maps\flood_rooftops::skybridge_rumble_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_ally_cross( guy )
{
	blocker = GetEnt( "backwards_blocker", "targetname" );
	blocker MoveZ( -416, 0.05 );
	node = getstruct( "vignette_skybridge_node", "script_noteworthy" );

	level.allies[ 0 ] notify( "player_on_skybridge" );
	node notify( "player_on_skybridge" );
	level.allies[ 0 ] StopAnimScripted();

	vol = GetEnt( "ally_in_front_vol", "targetname" );
	if ( level.allies[ 0 ] IsTouching( vol ) )
	{
		node thread anim_single_solo( level.allies[ 0 ], "skybridge_cross_ahead" );
	}
	else
	{
		node thread anim_single_solo( level.allies[ 0 ], "skybridge_cross_behind" );
	}

	// could be changed to notetrack...
	wait ( 0.75 );
	flag_set( "skybridge_vo_3" );
	level.allies[ 0 ] enable_cqbwalk();
	wait ( 6.55 );

	level.allies[ 0 ] vignette_actor_aware_everything();
	level.allies[ 0 ] enable_ai_color();
	level.allies[ 0 ] set_force_color( "r" );

	flag_set( "skybridge_ally_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_ally_holdup()
{
	self endon( "interrupt" );

	self thread rooftops_ally_holdup_interrupt();

	node = getstruct( "ally_hold_01_node", "script_noteworthy" );

	node anim_reach_solo( self, "ally_hold_01" );

	node anim_single_solo( self, "ally_hold_01" );

	self set_force_color( "r" );

	self notify( "holdup_complete" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_ally_holdup_interrupt()
{
	self endon( "holdup_complete" );

	flag_wait( "rooftops_interior_encounter_start" );
	self notify( "interrupt" );
	self StopAnimScripted();
	self set_force_color( "r" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_enemy_exfil_setup_heli()
{
	node						= getstruct( "vignette_rooftops_ropeladder_node", "script_noteworthy" );
	flag_wait( "rooftops_heli_spawned" );
	exploder( "rooftop1_heli_debri" );
	
	//Audio
	thread maps\flood_audio::sfx_heli_rooftops_sequence(level.rooftop_heli);

	level.rooftop_heli.animname								= "rooftops_hind";
	level.rooftops_exfil_anim_guys							= [];
	level.rooftops_exfil_anim_guys[ "rooftops_hind"		 ]	= level.rooftop_heli;
	level.rooftops_exfil_anim_guys[ "rooftops_ropeladder" ] = spawn_anim_model( "rooftops_ropeladder" );
	level.rooftops_exfil_anim_guys[ "opfor_0" ]				= level.rooftop_heli_opfor[ 0 ];
	level.rooftops_exfil_anim_guys[ "opfor_1" ]				= level.rooftop_heli_opfor[ 1 ];

	node thread anim_loop( level.rooftops_exfil_anim_guys, "rooftops_heli_ropeladder_loop", "exfil_abort" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rooftops encounter 01

rooftops_enemy_exfil_spawn()
{
	flag_wait( "rooftops_heli_spawned" );

	node = getstruct( "vignette_rooftops_ropeladder_node", "script_noteworthy" );

	flag_wait( "rooftops_exterior_encounter_start" );
	wait( 0.5 );

	node notify( "exfil_abort" );	
	foreach( guy in level.rooftops_exfil_anim_guys )
	{
		guy StopAnimScripted();
	}

	if ( !IsAlive( level.rooftop_heli_opfor[ 0 ] ) )
	{
		level.rooftops_exfil_anim_guys = array_remove( level.rooftops_exfil_anim_guys, level.rooftop_heli_opfor[ 0 ] );
	}
	if ( !IsAlive( level.rooftop_heli_opfor[ 1 ] ) )
	{
		level.rooftops_exfil_anim_guys = array_remove( level.rooftops_exfil_anim_guys, level.rooftop_heli_opfor[ 1 ] );
	}

	//thread foo();
	node thread anim_single( level.rooftops_exfil_anim_guys, "rooftops_heli_ropeladder" );
	stop_exploder( "rooftop1_heli_debri" );


	wait( 2.033 );
	level.rooftop_heli_opfor[ 1 ] notify( "fight" );
	wait ( 10.1 );	// magic number is from animation data

	/*
	if ( !IsAlive( level.rooftop_heli_opfor[ 0 ] ) )
	{
		level.rooftops_exfil_anim_guys = array_remove( level.rooftops_exfil_anim_guys, level.rooftop_heli_opfor[ 0 ] );
	}
	if ( IsAlive( level.rooftop_heli_opfor[ 1 ] ) )
	{
		level.rooftops_exfil_anim_guys = array_remove( level.rooftops_exfil_anim_guys, level.rooftop_heli_opfor[ 1 ] );
	}
	*/

	level.rooftops_exfil_anim_guys[ "rooftops_hind"		 ] Delete();
	level.rooftops_exfil_anim_guys[ "rooftops_ropeladder" ] Delete();

	/*
	foreach( guy in level.rooftops_exfil_anim_guys )
	{
		if( IsDefined( guy ) )
		{
			guy Delete();
		}
	}
	*/
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_heli_ropeladder_cleanup( guy )
{
	guy thread vignette_actor_kill();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_enemy_exfil_spawn_actors( spawners )
{
	Assert( IsArray( spawners ) );

	for ( index = 0; index < spawners.size; index++ )
	{
		spawners[ index ].script_forcespawn					= 1;
		level.rooftop_heli_opfor[ index ]					= spawners[ index ] spawn_ai();
		level.rooftop_heli_opfor[ index ].animname			= "opfor_" + index;

		level.rooftop_heli_opfor[ index ].health			= 1;
		level.rooftop_heli_opfor[ index ].allowdeath		= true;
		if( !IsDefined( spawners[ index ].script_noteworthy ) )
		{
			level.rooftop_heli_opfor[ index ].ragdoll_immediate = true;
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_outro_scene_setup()
{
	//wait( 0.5 ); ?
	
	// Wait until TFF is loaded	
	flag_wait( "flood_end_tr_loaded" );
	
	node = getstruct( "vignette_rooftops_outro", "script_noteworthy" );

	level.rooftop_outro_props[ "rooftops_brickwall" ] = spawn_anim_model( "rooftops_brickwall" );

	node anim_first_frame( level.rooftop_outro_props, "rooftops_wall_kick" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_outro_scene_spawn()
{
	node = getstruct( "vignette_rooftops_outro", "script_noteworthy" );

	props						  = [];
	props[ "rooftops_brickwall" ] = level.rooftop_outro_props[ "rooftops_brickwall" ];
	props[ "ally_0"				] = level.allies			 [ 0 ];

	node anim_reach_solo( level.allies[ 0 ], "rooftops_wall_kick" );
	level.rooftop_outro_props[ "rooftops_brickwall" ] thread maps\flood_audio::sfx_rooftops_wall_kick();
	thread maps\flood_fx::fx_rooftops_wall_kick();
	node anim_single( props, "rooftops_wall_kick" );

	node thread anim_loop_solo( level.allies[ 0 ], "rooftops_idle_loop_1", "push_forward" );
	flag_wait( "rooftops_vo_check_drop" );
	flag_wait_any( "player_in_sight_of_ally", "rooftops_player_dropped_down", "rooftops_player_pushing" );
	node notify( "push_forward" );

	node anim_single_solo( level.allies[ 0 ], "rooftops_traversal_01" );

	level.allies[ 0 ] disable_turnAnims();
	level.allies[ 0 ] set_force_color( "r" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_long_jump_spawn()
{
	node = getstruct( "rooftops_water_long_jump", "targetname" );
	
	node anim_reach_solo( level.allies[ 0 ], "rooftops_water_long_jump" );
	level.allies[ 0 ] thread maps\flood_audio::sfx_rooftops_ally_jump();
	node anim_single_solo( level.allies[ 0 ], "rooftops_water_long_jump" );

	if( flag( "rooftops_water_player_followed" ) )
	{
		node anim_single_solo( level.allies[ 0 ], "rooftops_water_stumble_and_jump" );
	}
	else
	{
		node anim_single_solo( level.allies[ 0 ], "rooftops_water_approach_stumble" );
		if( !flag( "rooftops_water_player_followed" ) )
		{
			node thread anim_loop_solo( level.allies[ 0 ], "rooftops_water_approach_loop", "player_followed" );
			flag_wait( "rooftops_water_player_followed" );
			node notify( "player_followed" );
			level.allies[ 0 ] StopAnimScripted();
		}
		node anim_single_solo( level.allies[ 0 ], "rooftops_water_approach_jump" );
	}

	level.allies[ 0 ] enable_turnAnims();
	level.allies[ 0 ] set_force_color( "r" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_intro_spawn_actors( spawners )
{
	Assert( IsArray( spawners ) );

	for ( index = 0; index < spawners.size; index++ )
	{
		spawners[ index ].script_forcespawn = 1;
		actor								= spawners[ index ] spawn_ai();
		actor.animname						= "opfor_" + index;
		actor.health						= 1;
		actor.allowdeath					= true;
		if( actor.target == "truck_reveal_a" )
		{
			actor.ragdoll_immediate				= true;
		}
		actor.ignoreme						= true;
		level.rooftops_water_opfor[ index ] = actor;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_intro()
{
	self thread rooftops_water_intro_flare_scene();
	self thread rooftops_water_intro_truck_scene();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_intro_flare_scene()
{
	node					 = getstruct( "vignette_opfor_waving_flares", "script_noteworthy" );
	guys					 = [];
	guys[ "opfor_1" ]		 = level.rooftops_water_opfor[ 1 ];
	guys[ "flare_left_01"  ] = spawn_anim_model( "flare_left_01" );
	guys[ "flare_right_01" ] = spawn_anim_model( "flare_right_01" );

	level.rooftops_water_opfor[ 1 ] thread maps\flood_rooftops::rooftops_water_intro_flare_setup( guys[ "flare_left_01" ], guys[ "flare_right_01" ] );
	level.rooftops_water_opfor[ 1 ] thread maps\flood_rooftops::rooftops_water_intro_flare_actor_cleanup();

	node thread anim_loop( guys, "rooftops_water_reveal_flare", "spotted" );
	flag_wait( "rooftops_water_encounter_start" );
	level waittill_notify_or_timeout( "firing_at_player", 5.0 );
	node notify( "spotted" );

	if ( IsAlive( level.rooftops_water_opfor[ 1 ] ) )
	{
		level.rooftops_water_opfor[ 1 ] StopAnimScripted();
		level.rooftops_water_opfor[ 1 ].health = 150;
		level.rooftops_water_opfor[ 1 ].ignoreme = false;
		level.rooftops_water_opfor[ 1 ] notify( "fight" );
	}
	flag_set( "rooftops_water_flare_intro_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_intro_truck_scene()
{
	node = getstruct( "vignette_rooftops_02_encounter_node", "script_noteworthy" );
	truck_guys				= [];
	truck_guys[ "opfor_0" ] = level.rooftops_water_opfor[ 0 ];
	//truck_guys[ "opfor_1" ] = level.rooftops_water_opfor[ 1 ];

	node thread anim_first_frame( truck_guys, "rooftops_water_reveal" );

	// need to hide weapon
	// level thread maps\flood_rooftops::rooftops_water_intro_weapon_setup( level.rooftops_water_opfor[ 0 ] );

	flag_wait( "rooftops_water_encounter_start" );

	node thread anim_single( truck_guys, "rooftops_water_reveal" );
	wait( 0.05 );
	//level.rooftops_water_opfor[ 1 ] thread vignette_actor_kill();
	rand = RandomFloat( 1.0 );
	wait( 3.05 + rand );
	// notify that first volley has been shot at player
	level notify( "firing_at_player" );
	wait( 3.266 - rand );

	foreach( opfor in truck_guys )
	{
		if ( IsAlive( opfor ) )
		{
			opfor.health = 150;
			opfor.ignoreme = false;
			opfor.ragdoll_immediate = false;
			opfor notify( "fight" );
		}
	}
	flag_set( "rooftops_water_truck_intro_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Debris Bridge Loop 1
debris_bridge_spawn()
{
	props = debris_bridge_loop1();

	flag_wait( "vignette_debris_bridge_vign1_flag" );

	thread maps\flood_audio::debris_bridge_sfx();

	props = debris_bridge_vign1_and_loop2( props );

	flag_wait_all( "debrisbridge_ally_0_ready", "debrisbridge_ally_1_ready", "debrisbridge_ally_2_ready" );

	debris_bridge_vign2_and_loop3( props );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debris_bridge_loop1()
{
	node = getstruct( "vignette_debris_bridge_node", "script_noteworthy" );
	model_handles = [];
	model_handles[ model_handles.size ] = "debris_debrissmall";
	model_handles[ model_handles.size ] = "debris_wall";
	model_handles[ model_handles.size ] = "debris_movingtruck";
	model_handles[ model_handles.size ] = "debris_vanblue";
	model_handles[ model_handles.size ] = "debris_00";

	props = [];
	foreach( handle in model_handles )
	{
		props[ props.size ] = spawn_anim_model( handle );
	}

	node thread anim_loop( props, "debris_bridge_loop1", "pile_up" );
	node thread anim_first_frame( make_array( props[ 1 ] ), "debris_bridge_vign1" );

	return props;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debris_bridge_vign1_and_loop2( prev_props )
{
	Assert( IsDefined( prev_props ) && IsArray( prev_props ) );

	node = getstruct( "vignette_debris_bridge_node", "script_noteworthy" );
	node notify( "pile_up" );
	level.debrisbridge_origins = [];

	model_handles = [];
	model_handles[ model_handles.size ] = "debris_bus";
	model_handles[ model_handles.size ] = "debris_cargocontainer";
	model_handles[ model_handles.size ] = "debris_coupeblue";
	model_handles[ model_handles.size ] = "debris_coupedeepblue";
	model_handles[ model_handles.size ] = "debris_vangold";
	model_handles[ model_handles.size ] = "debris_coupegreen";
	model_handles[ model_handles.size ] = "debris_macktruck";
	model_handles[ model_handles.size ] = "debris_subcompgreen";
	model_handles[ model_handles.size ] = "debris_truckbm21";
	model_handles[ model_handles.size ] = "debris_utiltruck";
	model_handles[ model_handles.size ] = "debris_vangreen";
	model_handles[ model_handles.size ] = "debris_01";
	model_handles[ model_handles.size ] = "debris_02";
	model_handles[ model_handles.size ] = "debris_antenna";

	foreach( prop in model_handles )
	{
		if( "debris_vangreen" == prop || "debris_01" == prop )
		{
			// need to add no sight clip to some debris
			if( "debris_vangreen" == prop )
			{
				handle = 14;
			}
			else
			{
				handle = 15;
			}
			clip_loc	= getstruct( "debrisbridge_struct_" + handle, "script_noteworthy" );
			model		= spawn_anim_model( prop, clip_loc.origin );
			origin		= Spawn( "script_origin", clip_loc.origin );
			player_clip = GetEnt( "debrisbridge_prop_" + handle, "targetname" );
			origin LinkTo( model );
			player_clip LinkTo( origin );

			prev_props				  [ prev_props.size					] = model;
			level.debrisbridge_origins[ level.debrisbridge_origins.size ] = origin;
		}
		else
		{
			prev_props[ prev_props.size ] = spawn_anim_model( prop );
		}
	}

	level thread maps\flood_rooftops::debrisbridge_wall_break_logic();
	node anim_single( prev_props, "debris_bridge_vign1" );

	flag_set( "debrisbridge_ready" );

	prev_props[ 0 ] Delete();
	prev_props = array_removeUndefined( prev_props );
	wall = prev_props[ 0 ];
	prev_props = array_remove( prev_props, wall );

	// may need to first frame this bitch
	prev_props[ "debris_clip" ] = spawn_anim_model( "debris_clip" );
	node anim_first_frame_solo( prev_props[ "debris_clip" ], "debris_bridge_vign1" );
	clip = GetEnt( "debrisbridge_clip_all", "targetname" );
	clip Linkto( prev_props[ "debris_clip" ] );

	node thread anim_loop( prev_props, "debris_bridge_loop2", "bridge_crossing" );

	return prev_props;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debris_bridge_final_loop()
{
	node = getstruct( "vignette_debris_bridge_node", "script_noteworthy" );

	props = [];
	//props[ props.size ] = spawn_anim_model( "debris_debrissmall" );
	//props[ props.size ] = spawn_anim_model( "debris_wall" );
	props[ props.size ] = spawn_anim_model( "debris_movingtruck" );
	props[ props.size ] = spawn_anim_model( "debris_vanblue" );
	props[ props.size ] = spawn_anim_model( "debris_00" );
	props[ props.size ] = spawn_anim_model( "debris_bus" );
	props[ props.size ] = spawn_anim_model( "debris_cargocontainer" );
	props[ props.size ] = spawn_anim_model( "debris_coupeblue" );
	props[ props.size ] = spawn_anim_model( "debris_coupedeepblue" );
	props[ props.size ] = spawn_anim_model( "debris_vangold" );
	props[ props.size ] = spawn_anim_model( "debris_coupegreen" );
	props[ props.size ] = spawn_anim_model( "debris_macktruck" );
	props[ props.size ] = spawn_anim_model( "debris_subcompgreen" );
	props[ props.size ] = spawn_anim_model( "debris_truckbm21" );
	props[ props.size ] = spawn_anim_model( "debris_utiltruck" );
	props[ props.size ] = spawn_anim_model( "debris_vangreen" );
	props[ props.size ] = spawn_anim_model( "debris_01" );
	props[ props.size ] = spawn_anim_model( "debris_02" );
	props[ props.size ] = spawn_anim_model( "debris_antenna" );
	node thread anim_loop( props, "debris_bridge_loop2", "bridge_crossing" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debris_bridge_allies_loop()
{
	anim_node = getstruct( "vignette_debris_bridge_node", "script_noteworthy" );

	// the actual anim nodes are node in the same order as the cover nodes
	goal_nodes					  = [];
	goal_nodes[ goal_nodes.size ] = GetNode( "debrisbridge_kill_shot_0", "targetname" );
	goal_nodes[ goal_nodes.size ] = GetNode( "debris_bridge_loop_node" , "targetname" );
	goal_nodes[ goal_nodes.size ] = GetNode( "debrisbridge_kill_shot_1", "targetname" );

	level.allies[ 0 ] thread debris_bridge_reach_and_loop( anim_node, 0 );
	level.allies[ 0 ].debrisbridge_loc = 0;
	level.allies[ 1 ] thread debris_bridge_reach_and_loop( anim_node, 2 );
	level.allies[ 1 ].debrisbridge_loc = 2;
	level.allies[ 2 ] thread debris_bridge_reach_and_loop( anim_node, 1 );
	level.allies[ 2 ].debrisbridge_loc = 1;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debris_bridge_reach_and_loop( node, index )
{
	vignette_actor_ignore_everything();
	node anim_reach_solo( self, "debrisbridge_loop" + index );
	if ( 2 != index )
	{
		node thread anim_loop_solo( self, "debrisbridge_loop" + index, "move_across" );
	}
	else
	{
		node thread anim_loop_solo( self, "debrisbridge_loop" + index, "move_across_late" );
	}
	flag_set( "debrisbridge_ally_" + index + "_ready" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debris_bridge_vign2_and_loop3( props )
{
	node = getstruct( "vignette_debris_bridge_node", "script_noteworthy" );

	flag_wait( "debrisbridge_ready" );
	node notify( "move_across" );
	node notify( "bridge_crossing" );

	foreach ( ally in level.allies )
	{
		if ( 2 != ally.debrisbridge_loc )
		{
			ally StopAnimScripted();
		}
	}
	foreach( prop in props )
	{
		prop StopAnimScripted();
	}

	waittillframeend;

	cover_flank = undefined;
	foreach( ally in level.allies )
	{
		if( 2 == ally.debrisbridge_loc )
		{
			cover_flank = ally;
		}
		else
		{
			ally thread debris_bridge_actor_vign_and_transition_to_combat( node );
		}
	}
	node thread anim_loop( props, "debris_bridge_loop2" );

	level thread maps\flood_rooftops::debrisbridge_crossing();

	wait( 1.0 );
	flag_set( "debrisbridge_vo_1" );
	wait( 7.666 );

	while( !flag( "debrisbridge_player_advancing" ) )
	{
		wait( 4.333 );
	}
	node notify( "move_across_late" );
	cover_flank StopAnimScripted();
	cover_flank thread debris_bridge_actor_vign_and_transition_to_combat( node );
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debris_bridge_actor_vign_and_transition_to_combat( node )
{
	level endon( "garage_done" );

	self.ondebrisbridge = 1;
	node anim_single_solo( self, "debris_bridge_vign2_loc" + self.debrisbridge_loc );

	self vignette_actor_aware_everything();
	self enable_ai_color();
	self.ondebrisbridge = 0;
	
	switch( self.animname )
	{
		case "ally_0":
			if( !IsDefined( self.garage_teleported ) )
			{
				self thread maps\flood_garage::ally_garage_sneak( "r", "garage_ally0_cover_crouch", "r_end_node" );
			}
			break;

		case "ally_1":
			if( !IsDefined( self.garage_teleported ) )
			{
				self thread maps\flood_garage::ally_garage_sneak( "y", "garage_ally1_cover_crouch", "y_end_node" );
			}
			break;

		case "ally_2":
			if( !IsDefined( self.garage_teleported ) )
			{
				self thread maps\flood_garage::ally_garage_sneak( "g", "garage_ally2_cover_crouch", "g_end_node" );
				//Merrick: What?...  Are?,,, Are these civilians?
//				self dialogue_queue( "flood_mrk_whatarearethese" );
				//Price: We'll deal with that later! We gotta get Garcia!
//				self dialogue_queue( "flood_pri_welldealwiththat" );
			}
			break;

		default:
			AssertEx( false, self.animname + " animname not supported." );
	}

	// Removed by JKU.  Send them into garage logic instead of to these color nodes
//	trigger = GetEnt( "debrisbridge_encounter_done", "targetname" );
//	if( IsDefined( trigger ) )
//	{
//		trigger notify( "trigger" );
//	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// garage

garage_jump_01_spawn()
{
	garage_jump_01_opfor = vignette_actor_spawn("garage_jump_01_opfor", "garage_jump_01_opfor"); //"value" (kvp), "anim_name"

	garage_jump_01(garage_jump_01_opfor);

	garage_jump_01_opfor vignette_actor_delete();
}

garage_jump_01(garage_jump_01_opfor)
{

	node = getstruct("vignette_garage_jump_01", "script_noteworthy");


	guys = [];
	guys["garage_jump_01_opfor"] = garage_jump_01_opfor;

	node anim_single(guys, "garage_jump_01");

}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// garage

garage_jump_02_spawn()
{
	garage_jump_02_opfor = vignette_actor_spawn("garage_jump_02_opfor", "garage_jump_02_opfor"); //"value" (kvp), "anim_name"

	garage_jump_02(garage_jump_02_opfor);

	garage_jump_02_opfor vignette_actor_delete();
}

garage_jump_02(garage_jump_02_opfor)
{

	node = getstruct("vignette_garage_jump_02", "script_noteworthy");


	guys = [];
	guys["garage_jump_02_opfor"] = garage_jump_02_opfor;

	node anim_single(guys, "garage_jump_02");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rooftops traversal 01
rooftops_traversal_01_spawn()
{
	//level.allies[ 1 ] maps\_vignette_util::vignette_actor_ignore_everything();

	node = getstruct( "vignette_rooftops_traversal_01", "script_noteworthy" );

	//node anim_reach_solo( level.allies[1], "rooftops_traversal_01" );

	node anim_single( make_array( level.allies[ 0 ] ), "rooftops_traversal_01" );

	//level.allies[ 1 ] vignette_actor_aware_everything();
	//level.allies[ 1 ] enable_ai_color();
	//level.allies[ 1 ] set_force_color( "r" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rooftops traversal 02

rooftops_traversal_02_spawn()
{
//	rooftops_traversal_02_ally = vignette_actor_spawn("rooftops_traversal_02_ally", "rooftops_traversal_02_ally"); //"value" (kvp), "anim_name"
//
//	rooftops_traversal_02(rooftops_traversal_02_ally);
//
//	rooftops_traversal_02_ally vignette_actor_delete();
}

rooftops_traversal_02(rooftops_traversal_02_ally)
{
	node = getstruct("rooftops_traversal_02_ally_node", "script_noteworthy");


	guys = [];
	guys["rooftops_traversal_02_ally"] = rooftops_traversal_02_ally;

	node anim_single(guys, "rooftops_traversal_02");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// rooftops traversal 03

rooftops_traversal_03_spawn()
{
//	rooftops_traversal_03_ally = vignette_actor_spawn("rooftops_traversal_03_ally", "rooftops_traversal_03_ally"); //"value" (kvp), "anim_name"
//
//	rooftops_traversal_03(rooftops_traversal_03_ally);
//
//	rooftops_traversal_03_ally vignette_actor_delete();
}

rooftops_traversal_03(rooftops_traversal_03_ally)
{

	node = getstruct("rooftops_traversal_03_ally_node", "script_noteworthy");


	guys = [];
	guys["rooftops_traversal_03_ally"] = rooftops_traversal_03_ally;

	node anim_single(guys, "rooftops_traversal_03");

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

attach_fx_anim_model(root_model, xmodel_name, tag_name)
{
	pos = root_model GetTagOrigin(tag_name);
	my_angles = root_model GetTagAngles(tag_name);
	new_model = Spawn("script_model", pos );
	new_model.angles = my_angles;
	new_model.origin = pos;
	new_model SetModel( xmodel_name );
	new_model LinkTo( root_model, tag_name );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_animatic_setup()
{
	level.ending_door_l = spawn_anim_model( "ending_breach_door_l" );
	level.ending_door_r = spawn_anim_model( "ending_breach_door_r" );

	level.ending_heli = spawn_anim_model( "outro_pt1_heli" );
	level.ending_hvt  = vignette_actor_spawn( "garcia_spawner", "generic" );
	level.ending_hvt vignette_actor_ignore_everything();
	level.ending_hvt gun_remove();
	level.ending_opfor_0 = vignette_actor_spawn( "vignette_ending_opfor01", "opfor_0" );
	level.ending_opfor_0 vignette_actor_ignore_everything();
	level.ending_opfor_0 gun_remove();
	level.ending_opfor_1 = vignette_actor_spawn( "vignette_ending_opfor02", "opfor_1" );
	level.ending_opfor_1 vignette_actor_ignore_everything();
	level.ending_opfor_1 gun_remove();
	level.ending_opfor_2 = vignette_actor_spawn( "vignette_outro_opfor03", "opfor_2" );
	level.ending_opfor_2 vignette_actor_ignore_everything();
	level.ending_opfor_3 = vignette_actor_spawn( "vignette_outro_pilot", "opfor_3" );
	level.ending_opfor_3 vignette_actor_ignore_everything();
	level.ending_opfor_3 gun_remove();
	level.outro_node	= getstruct( "vignette_outro", "script_noteworthy" );

	level.outro_node anim_first_frame( make_array( level.ending_door_l, level.ending_door_r, level.ending_opfor_0, level.ending_opfor_1, level.ending_opfor_2 ), "outro_pt1_breach" );
	level.outro_node anim_first_frame_solo( level.ending_heli, "outro_pt1_heli" );
	level.outro_node anim_first_frame( make_array( level.ending_opfor_0, level.ending_opfor_1 ), "outro_pt1_start" );
	level.outro_node anim_first_frame_solo( level.ending_opfor_2, "outro_pt1_melee_vargas" );
	level.outro_node anim_first_frame_solo( level.ending_opfor_3, "outro_pt1_pilot_kill" );
	level.outro_node anim_first_frame_solo( level.ending_hvt, "outro_pt1_garcia_punch" );

	level.ending_opfor_3 Hide();
	level.ending_hvt Hide();

	battlechatter_off( "axis" );
	battlechatter_off( "allies" );

	parts = GetEntArray( "upper_garage_door_l", "targetname" );
	foreach( part in parts )
	{
		part LinkTo( level.ending_door_l );
	}
	parts = GetEntArray( "upper_garage_door_r", "targetname" );
	foreach( part in parts )
	{
		part LinkTo( level.ending_door_r );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//Helicopter will play in it's own thread.  Eventually starting the moment the door is breached.
ending_pt1_heli()
{
	guys					 = [];
	guys[ "outro_pt1_heli" ] = self;

	level.outro_node anim_single( guys, "outro_pt1_heli" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_breach_spawn()
{
	if( level.player IsSprinting() || level.player IsMeleeing() || level.player IsThrowingGrenade() )
	{
		level.player HideViewModel();
	}
	level.player DisableWeapons();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowSprint( false );
	level.player AllowJump( false );
	level.player SetStance( "stand" );
	while( "stand" != level.player GetStance() )
	{
		wait ( 0.05 );
	}

	flag_set( "player_entering_final_area" );
	autosave_by_name_silent( "ending_breach" );

	level.g_friendlyNameDist_old = GetDvarInt( "g_friendlyNameDist" );
	SetSavedDvar( "g_friendlyNameDist", 0 );
	level.ending_heli thread ending_pt1_heli();
	level.allies[ 1 ] thread ending_pt1_ally_1_sequence();
	level.player thread maps\flood_ending::ending_lower_raise_weapon_logic();
	arms = spawn_anim_model( "player_rig" );

	guys						   = [];
	guys[ "opfor_0"				 ] = level.ending_opfor_0;
	guys[ "opfor_1"				 ] = level.ending_opfor_1;
	guys[ "opfor_2"				 ] = level.ending_opfor_2;
	guys[ "ending_breach_door_l" ] = level.ending_door_l;
	guys[ "ending_breach_door_r" ] = level.ending_door_r;
	guys[ "player_rig"			 ] = arms;

	level.player PlayerLinkToBlend( arms, "tag_player", 0.2, 0.1, 0.1 );

	scene = "outro_pt1_breach";
	level.outro_node thread anim_single( guys, scene );

	level.outro_node waittill( scene );

	flag_set( "ending_vo_1" );

	level.player ShowViewModel();
	level.player Unlink();

	level.player AllowCrouch( true );
	level.player AllowProne( true );
	level.player AllowSprint( true );
	level.player AllowJump( true );
	
	level.player EnableWeapons();

	arms Delete();

	level.player thread maps\flood_ending::final_sequence_fail_condition();
	level.player thread maps\flood_ending::ending_player_reach_final_sequence();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt1_allies_sequence_start( guy )
{
	thread maps\flood_audio::play_helicopter_leaving_sound();
	
	foreach( actor in level.allies )
	{
		actor disable_ai_color();
		actor vignette_actor_ignore_everything();
	}

	guys			= [];
	guys[ "ally_0" ] = level.allies[ 0 ];
	guys[ "ally_1" ] = level.allies[ 1 ];

	scene = "outro_pt1_breach";
	level.outro_node thread anim_single( guys, scene );
	music_play( "mus_flood_exfil_chase_ss", 0.5 );

	level.allies[ 0 ] thread ending_pt1_ally_0_sequence();
	level.allies[ 1 ] thread ending_pt1_ally_1_sequence();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt1_ally_0_sequence()
{
	guys = make_array( self, level.ending_opfor_1 );

	flag_wait( "vignette_ending_scene_start" );

	foreach ( actor in guys )
	{
		actor StopAnimScripted();
		actor Linkto( level.ending_heli );
	}
	self gun_remove();


	{
		//Start Loop Price - Price and Opfor02 will loop in this thread until Garcia punches the player in the face.
		level.allies[ 0 ] gun_remove();

		scene = "outro_pt1_start_loop_price";
		level.ending_heli thread anim_loop( guys, scene, "player_passed_first_action", "tag_origin" );
		flag_wait( "vignette_ending_qte_success" );

		level.ending_heli notify( "player_passed_first_action" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt1_ally_1_sequence()
{
	guys = make_array( self, level.ending_opfor_0, level.ending_opfor_2 );

	flag_wait( "vignette_ending_scene_start" );

	foreach ( actor in guys )
	{
		actor StopAnimScripted();
		actor Linkto( level.ending_heli );
	}
	self gun_remove();


	{
		//Melee Vargas - When the player jumps on the helicopter Vargas and opfor03 will melee in a seperate thread.
		guys = array_remove( guys, level.ending_opfor_0 );

		scene = "outro_pt1_melee_vargas";
		qte_anim = self getanim( scene );
		wait_time = GetAnimLength( qte_anim );
		level.ending_heli thread anim_single( guys, scene, "tag_origin" );
		flag_wait_or_timeout( "vignette_ending_qte_success", wait_time );
	}


	if( !flag( "vignette_ending_qte_success" ) )
	{
		level.ending_heli anim_last_frame_solo( self, scene, "tag_origin" );
		level.ending_heli anim_last_frame_solo( level.ending_opfor_2, scene, "tag_origin" );
		return;
	}


	level.ending_opfor_3 Show();
	level.ending_opfor_3 Linkto( level.ending_heli );


	{
		//Pilot Killed - This thread plays when the player sucessfully kills Opfor01 at the end of Melee Player.
		guys[ "opfor_3" ] = level.ending_opfor_3;

		scene = "outro_pt1_pilot_kill";
		level.ending_heli thread anim_single( guys, scene, "tag_origin" );
		level thread maps\flood_ending::ending_opfor_kill_pilot();				// TODO need notetrack
		level.ending_heli waittill( scene );
	}

	level.ending_heli anim_last_frame_solo( self, scene, "tag_origin" );
	self Hide();
	level.ending_opfor_2 vignette_actor_kill();
	level.ending_opfor_2 Hide();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt1_player_sequence_start()
{
	level.player DisableWeapons();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowSprint( false );
	level.player AllowJump( false );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );

	level.ending_arms = spawn_anim_model( "player_rig" );
	level.ending_arms Hide();
	level.ending_arms Linkto( level.ending_heli );

	level.player thread maps\flood_ending::ending_player_camera_logic();
	level.player thread maps\flood_ending::ending_player_qte_0_logic();
	level.player thread maps\flood_ending::ending_player_weapon_logic();

	scene = "outro_pt1_melee_player";
	level.ending_heli thread anim_single_solo( level.ending_arms, scene, "tag_origin" );
	wait( 0.3 );
	level.ending_arms Show();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt1_scene_start( guy )
{
	flag_set( "vignette_ending_scene_start" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_qte_0_start( guy )
{
	level.player notify( "qte_0_start" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt1_sequence()
{
	level.ending_gun  = spawn_anim_model( "outro_gun_player" );
	level.enemy_gun	  = spawn_anim_model( "outro_gun_garcia" );
	guys			  = [];

	{
		//Melee Player - This is the player interaction with Opfor01 in which the player kills Opfor and takes his gun.
		flag_clear( "vignette_ending_qte_success" );
		level.player thread maps\flood_ending::ending_player_land_on_heli_effects();
		level.ending_gun LinkTo( level.ending_heli );
		level.ending_opfor_0 LinkTo( level.ending_heli );

		guys[ "outro_gun_player" ] = level.ending_gun;
		guys[ "opfor_0"			 ] = level.ending_opfor_0;
		scene					   = "outro_pt1_melee_player";
		qte_anim				   = level.ending_gun getanim( scene );
		wait_time				   = GetAnimLength( qte_anim );
		level.ending_heli thread anim_single( guys, scene, "tag_origin" );
		flag_wait_or_timeout( "vignette_ending_qte_success", wait_time );
	}


	level.player notify( "qte_0_fail" );
	guys[ "player_rig" ] = level.ending_arms;


	if( !flag( "vignette_ending_qte_success" ) )
	{
		//Melee Player Fail - If the user doesn't act and shoot the opfor then this is the fail condition/animation.
		scene				 = "outro_pt1_melee_fail";
		level.ending_heli thread anim_single( guys, scene, "tag_origin" );
		level.ending_heli waittill( scene );
		level.ending_heli anim_last_frame_solo( level.ending_opfor_0, scene, "tag_origin" );
		return;
	}


	level.ending_hvt Show();
	level.ending_hvt LinkTo( level.ending_heli );
	level.ending_gun StopAnimScripted();
	level.ending_gun Unlink();
	level.ending_gun LinkTo( level.ending_arms, "tag_knife_attach2" );


	{
		//Garcia Punch - This is the thread immediatley after the player/user kills Opfor01 in which Garcia grabs your gun and punches you in the face.
		//This is another moment of player interactivity.
		guys			  = array_remove( guys, level.ending_gun );
		guys[ "ally_0" ]  = level.allies[ 0 ];
		guys[ "opfor_1" ] = level.ending_opfor_1;
		guys[ "generic" ] = level.ending_hvt;

		scene = "outro_pt1_garcia_punch";
		delayThread( 1.2, ::flag_set, "ending_vo_3" );
		level.ending_heli thread anim_single( guys, scene, "tag_origin" );
		level.ending_heli waittill( scene );
	}


	level.ending_opfor_0 vignette_actor_kill();
	level.ending_opfor_0 Hide();
	level.enemy_gun LinkTo( level.ending_heli );


	{
		//Garcia Kill Pt1 - Garcia stand over the player about to execute him, price saves your life, and the player grabs a gun.
		flag_clear( "vignette_ending_qte_success" );
		guys					   = array_remove( guys, level.ending_opfor_0 );
		guys[ "outro_gun_player" ] = level.ending_gun;
		guys[ "outro_gun_garcia" ] = level.enemy_gun;
		guys[ "opfor_3"			 ] = level.ending_opfor_3;

		scene	  = "outro_pt1_garcia_kill_pt1";
		level.player thread maps\flood_ending::ending_price_gets_capped( level.allies[ 1 ] );
		level.ending_heli thread anim_single( guys, scene, "tag_origin" );
		flag_wait_any( "vignette_ending_qte_success", "vignette_ending_qte_failure" );
	}


	if( !flag( "vignette_ending_qte_success" ) )
	{
		if( !flag( "already_failing" ) )
		{
			SetDvar( "ui_deadquote", &"FLOOD_ENDING_QTE_0_FAILED" );
			level thread maps\_utility::missionFailedWrapper();
		}

		return;
	}


	level.allies[ 1 ] Show();
	guys[ "ally_1" ]	 = level.allies[ 1 ];
	level.ending_hvt StopAnimScripted();


	{
		//Crash - if the player kills garcia then this is the crash animation and final thread of Outro pt1.
		level.player delayCall( 0.4, ::DisableWeapons );

		scene = "outro_pt1_crash";
		level thread maps\flood_ending::ending_shake_effects();
		level.ending_heli thread anim_single( guys, scene, "tag_origin" );
		level.ending_heli waittill( scene );
	}


	// cleanup
	StopAllRumbles();
	level.player notify( "earthquake_end" );
	level.ending_gun Delete();
	level.enemy_gun Delete();
	//level.allies[ 0 ] vignette_actor_kill();
	level.allies[ 2 ] vignette_actor_kill();
	level.ending_opfor_0 vignette_actor_kill();
	level.ending_opfor_1 vignette_actor_kill();
	level.ending_opfor_2 vignette_actor_kill();
	level.ending_opfor_3 vignette_actor_kill();
	level.ending_opfor_1 Delete();
	level.ending_opfor_3 Delete();
	level.ending_heli Delete();

	flag_set( "vignette_ending_crash_flag" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_harmless_shots_logic( guy )
{
	level.ending_arms endon( "shot_window_done" );

	scene = "outro_pt1_garcia_punch";
	base_anim = level.ending_arms getanim( scene );
	anim_time = GetAnimLength( base_anim );
	starttime = GetNotetrackTimes( base_anim, "player_can_fire" );
	stoptime  = GetNotetrackTimes( base_anim, "slowmo_end" );

	level.ending_arms thread notify_delay( "shot_window_done", anim_time * ( stoptime[ 0 ] - starttime[ 0 ] ) );
	level.ending_gun thread delayCall( 0.5 + ( anim_time * ( stoptime[ 0 ] - starttime[ 0 ] ) ), ::LinkTo, level.ending_arms, "tag_knife_attach" );

	while( true )
	{
		while( !level.player AttackButtonPressed() )
		{
			wait( 0.05 );
		}

		level.player thread ending_player_shoot_gun();

		while( level.player AttackButtonPressed() )
		{
			wait( 0.05 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_shoot_gun()
{
	self PlayRumbleOnEntity( "heavygun_fire" );
	PlayFXOnTag( level._effect[ "fx_usp_muzzle_flash" ], level.ending_gun, "tag_flash" );
	self PlaySound( "weap_p99_fire_plr" );
	
	add_anim = level.ending_arms getanim( "outro_pt1_garcia_punch_player_additive" );
	anim_time = GetAnimLength( add_anim );

	level.ending_arms SetAnimRestart( add_anim, 1, 0, 1 );

	wait( anim_time );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

outro_pt1_blood( guys )
{

	//level.ending_heli = spawn_anim_model( "outro_pt1_heli" );

	outro_pt1_blood = spawn_anim_model("outro_pt1_blood");


	guys = [];
	guys["outro_pt1_blood"] = outro_pt1_blood;

	outro_pt1_blood LinkTo(level.ending_heli);
	
	level.ending_heli anim_single(guys, "outro_pt1_blood");

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt2_player_sequence()
{
	autosave_by_name_silent( "ending_crash" );
	SetDvar( "ui_deadquote", "" );
	flag_clear( "vignette_ending_qte_success" );
	flag_clear( "vignette_ending_scene_start" );

	level.outro_node = getstruct( "vignette_outro_end", "script_noteworthy" );

	level thread ending_pt2_heli();
	level thread ending_pt2_hvt();
	level.player thread maps\flood_ending::ending_qte_catch();

	legs			 = vignette_actor_spawn( "vignette_outro_player_legs", "outro_player_legs" );
	guys = [];
	guys[ "player_rig"		  ] = level.ending_arms;
	guys[ "outro_player_legs" ] = legs;
	//guys[ "ally_1"			 ]	= level.allies[ 1 ]; 

	{
		//Start of the second half of the outro.
		scene = "outro_pt2_start";
		level.outro_node thread anim_first_frame( guys, scene );
		delaythread( 3.0, ::flag_set, "ending_vo_pt2_start" );
		wait ( 4.0 );
		flag_set( "vignette_ending_scene_start" );
		delaythread( 6.9, ::ending_qte_catch_start, level.player );
		level.outro_node thread anim_single( guys, scene );
		level.outro_node waittill( scene );
	}


	if ( flag( "vignette_ending_qte_success" ) )
	{
		delaythread( 2.0, ::flag_clear, "vignette_ending_qte_success" );
		maps\flood_ending::ending_create_qte_prompt( &"FLOOD_ENDING_QTE_2_PROMPT" );
		scene = "outro_pt2_save_vargas";
		level.outro_node thread anim_single( guys, scene );
		level.outro_node waittill( scene );
	}
	else
	{
		guys = array_remove( guys, level.allies[ 0 ] );
		flag_set( "missionfailed" );
		level.player delayThread( 2.12, maps\flood_util::fell_in_water_fail, 7, true );
		level.outro_node thread anim_single( guys, "outro_pt2_start_fail" );
		level.outro_node thread anim_single_solo( level.allies[ 0 ], "outro_pt2_save_vargas" );
		return;
	}
	
	guys[ "ally_0"			 ]	= level.allies[ 0 ]; 

	if ( flag( "smash_rate_bad" ) )
	{
		scene = "outro_pt2_save_vargas_fail_01";
		level.outro_node thread anim_single( guys, scene );
		level.outro_node waittill( scene );
	}
	else
	{
		scene = "outro_pt2_save_vargas_win_01";
		level.outro_node thread anim_single( guys, scene );
		level.outro_node waittill( scene );
	}


	if ( flag( "smash_rate_bad" ) )
	{
		scene = "outro_pt2_save_vargas_fail_02";
		level.outro_node thread anim_single( guys, scene );
		level.outro_node waittill( scene );
	}
	else
	{
		scene = "outro_pt2_save_vargas_win_02";
		level.outro_node thread anim_single( guys, scene );
		level.outro_node waittill( scene );
	}


	flag_set( "vignette_ending_qte_success" );
	maps\flood_ending::ending_destroy_qte_prompt();


	{
		scene = "outro_pt2_vargas_death";
		level.outro_node thread anim_single( guys, scene );
		level.outro_node waittill( scene );
	}


	level.allies[ 0 ] vignette_actor_kill();
	level.allies[ 0 ] Hide();
	level.allies[ 1 ] vignette_actor_kill();
	level.allies[ 1 ] Hide();

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", 0 );
	SetSavedDvar( "actionSlotsHide", 0 );
	SetSavedDvar( "hud_showStance", 1 );
	SetSavedDvar( "g_friendlyNameDist", level.g_friendlyNameDist_old ); 
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt2_heli()
{
	outro_heli_front = spawn_anim_model( "outro_heli_front" );
	outro_heli_mid	 = spawn_anim_model( "outro_heli_mid" );
	outro_heli_rear	 = spawn_anim_model( "outro_heli_rear" );
	wire			 = spawn_anim_model( "outro_wire_grab" );
	
	guys					   = [];
	guys[ "outro_heli_front" ] = outro_heli_front;
	guys[ "outro_heli_mid"	 ] = outro_heli_mid;
	guys[ "outro_heli_rear"	 ] = outro_heli_rear;
	guys[ "outro_wire_grab"	 ] = wire;
	scene					   = "outro_pt2_start";

	level.outro_node anim_first_frame( guys, scene );

	flag_wait( "vignette_ending_scene_start" );

	level.outro_node thread anim_single( guys, scene );
	level.outro_node waittill( scene );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt2_hvt()
{
	guys					   = [];
	guys[ "generic"			 ] = level.ending_hvt;
	guys[ "ally_0"			 ]	= level.allies[ 0 ]; 
	scene					   = "outro_pt2_start";

	level.outro_node anim_first_frame( guys, scene );

	flag_wait( "vignette_ending_scene_start" );

	level.outro_node thread anim_single( guys, scene );
	level.outro_node waittill( scene );
	level.ending_hvt vignette_actor_kill();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_qte_catch_start( guy )
{
	flag_set( "ending_qte_catch_active" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_pt2_player_reach_anim( player_rig )
{
	level endon( "vignette_ending_qte_success" );

	root_anim = player_rig getanim( "outro_pt2_save_vargas" );
	time = GetAnimLength( root_anim );

	// start off the anim
	player_rig SetAnimRestart( root_anim, 1, 0, 1 );

	weight = 0.0;

	while( true )
	{
		if( flag( "smash_rate_bad" )  )
		{
			weight -= 0.05;
		}
		else
		{
			weight = 1.0;
		}

		if( 0 > weight )
		{
			weight = 0.0;
		}
		player_rig SetAnim( root_anim, weight, 0, 1 );
		wait ( 0.05 );
	}

}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


/*
mall_rooftop_debri_020_spawn()
{
	mall_rooftop_debri_020();
}
mall_rooftop_debri_020()
{
	node = getstruct("mall_rooftop_debri_020", "script_noteworthy");
	mall_rooftop_debri_020 = spawn_anim_model("mall_rooftop_debri_020");
		
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_1" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_2" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_3" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_4" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_5" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_6" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_7" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_8" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_9" );
		
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_10" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_11" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_12" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_13" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_020_vehicle_coupe_green_destroyed_14" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_15" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_16" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_17" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_020_vehicle_coupe_green_destroyed_18" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_19" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_20" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_21" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_22" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_020_vehicle_coupe_green_destroyed_23" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_24" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_25" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_26" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_27" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_28" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_29" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_30" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_31" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_32" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_33" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_34" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_35" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_36" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_37" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_38" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_39" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_40" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_41" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_42" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_43" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_44" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_45" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_46" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_47" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_48" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_49" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_50" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_51" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_52" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_53" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_54" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_55" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_56" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_57" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_58" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_59" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_60" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_61" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_62" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_63" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_64" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_65" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_66" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_67" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_68" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_69" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_70" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_71" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_72" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_73" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_74" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_75" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_76" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_77" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_78" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_79" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_80" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_81" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_82" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_83" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_84" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_85" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_86" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_87" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_88" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_89" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_90" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_91" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_92" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_93" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_94" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_95" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_96" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_97" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_98" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_99" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_100" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_020_vehicle_coupe_green_destroyed_101" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_020_vehicle_van_mica_destroyed_102" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_103" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_104" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_020_vehicle_coupe_green_destroyed_105" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_106" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_107" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_108" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_109" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashbin01", "j_mall_rooftop_debri_020_com_trashbin01_110" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_111" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_112" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_020_vehicle_coupe_green_destroyed_113" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_114" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_115" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_116" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_pallet_2", "j_mall_rooftop_debri_020_com_pallet_2_117" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_118" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_119" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_barrel_green", "j_mall_rooftop_debri_020_com_barrel_green_120" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_plastic_crate_pallet", "j_mall_rooftop_debri_020_com_plastic_crate_pallet_121" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_122" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_123" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_folding_chair", "j_mall_rooftop_debri_020_com_folding_chair_124" );
		attach_fx_anim_model( mall_rooftop_debri_020, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_020_com_trashcan_metal_with_trash_125" );
		attach_fx_anim_model( mall_rooftop_debri_020, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_020_vehicle_van_mica_destroyed_126" );
		
		mall_rooftop_debri_020 hide();
		//IPrintLnBold( "got debri 0" );
	guys = [];
	guys["mall_rooftop_debri_020"] = mall_rooftop_debri_020;
	node anim_single(guys, "mall_rooftop_debri_020");

}
*/
/*	
mall_rooftop_debri_021_spawn()
{
	wait 0.01;

	//mall_rooftop_debri_021();
}

mall_rooftop_debri_021()
{
	node = getstruct("mall_rooftop_debri_021", "script_noteworthy");
	mall_rooftop_debri_021 = spawn_anim_model("mall_rooftop_debri_021");
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_1" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_2" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_3" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_4" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_5" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_6" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_7" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_8" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_9" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_10" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_11" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_12" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_13" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_14" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_15" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_16" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_17" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_18" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_19" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_20" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_21" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_22" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_23" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_24" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_25" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_26" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_27" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_28" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_29" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_30" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_31" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_32" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_33" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_34" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_35" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_36" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_021_vehicle_coupe_green_destroyed_37" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_38" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_39" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_021_vehicle_coupe_green_destroyed_40" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_41" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_42" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_43" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_44" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_45" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_46" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_47" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_48" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_49" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_50" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_51" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_52" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_021_vehicle_coupe_green_destroyed_53" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_54" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_55" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_56" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_57" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_58" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_59" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_60" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_61" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_62" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_63" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_64" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_65" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_66" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_67" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_68" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_69" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_70" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_71" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_72" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_73" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_74" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_75" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_76" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_77" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_78" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_79" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_80" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_81" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_82" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_83" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_84" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_85" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_86" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_87" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_021_vehicle_coupe_green_destroyed_88" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_89" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_90" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_91" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_92" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_93" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_94" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_95" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_96" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_97" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_98" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_99" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_021_vehicle_coupe_green_destroyed_100" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_101" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_102" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_103" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_104" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_105" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_021_com_trashcan_metal_with_trash_106" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_107" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_108" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_109" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_110" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_111" );
		attach_fx_anim_model( mall_rooftop_debri_021, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_021_vehicle_van_mica_destroyed_112" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_113" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_114" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_barrel_green", "j_mall_rooftop_debri_021_com_barrel_green_115" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_folding_chair", "j_mall_rooftop_debri_021_com_folding_chair_116" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_118" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_120" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_plastic_crate_pallet", "j_mall_rooftop_debri_021_com_plastic_crate_pallet_121" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_122" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_123" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_pallet_2", "j_mall_rooftop_debri_021_com_pallet_2_124" );
		attach_fx_anim_model( mall_rooftop_debri_021, "com_trashbin01", "j_mall_rooftop_debri_021_com_trashbin01_126" );
		
	mall_rooftop_debri_021 hide();
	guys = [];
	guys["mall_rooftop_debri_021"] = mall_rooftop_debri_021;
	node anim_single(guys, "mall_rooftop_debri_021");
}

mall_rooftop_debri_022_spawn()
{
	wait 0.02;

	//mall_rooftop_debri_022();
}

mall_rooftop_debri_022()
{
	node = getstruct("mall_rooftop_debri_022", "script_noteworthy");
	mall_rooftop_debri_022 = spawn_anim_model("mall_rooftop_debri_022");
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_1" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_3" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_4" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_022_vehicle_coupe_green_destroyed_5" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_6" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_8" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_022_vehicle_coupe_green_destroyed_9" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_11" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_13" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_14" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_16" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_19" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_20" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_21" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_22" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_23" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_24" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_25" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_022_vehicle_van_mica_destroyed_27" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_022_vehicle_van_mica_destroyed_29" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_30" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_32" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_35" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_37" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_38" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_39" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_41" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_022_vehicle_van_mica_destroyed_43" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_44" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_46" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_48" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_51" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_52" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_53" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_54" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_61" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_62" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_65" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_66" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_022_vehicle_coupe_green_destroyed_67" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_68" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_71" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_72" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_74" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_75" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_76" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_78" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_79" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_80" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_82" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_83" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_84" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_85" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_86" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_87" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_88" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_89" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_92" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_96" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_99" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_101" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_102" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_103" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_104" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_105" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_106" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_108" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_110" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_022_vehicle_coupe_green_destroyed_112" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_113" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_114" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_115" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_116" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_pallet_2", "j_mall_rooftop_debri_022_com_pallet_2_117" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_barrel_green", "j_mall_rooftop_debri_022_com_barrel_green_118" );
		attach_fx_anim_model( mall_rooftop_debri_022, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_022_vehicle_van_mica_destroyed_119" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_120" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashbin01", "j_mall_rooftop_debri_022_com_trashbin01_121" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_plastic_crate_pallet", "j_mall_rooftop_debri_022_com_plastic_crate_pallet_122" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_folding_chair", "j_mall_rooftop_debri_022_com_folding_chair_123" );
		attach_fx_anim_model( mall_rooftop_debri_022, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_022_com_trashcan_metal_with_trash_125" );
	
		mall_rooftop_debri_022 hide();
	guys = [];
	guys["mall_rooftop_debri_022"] = mall_rooftop_debri_022;
	node anim_single(guys, "mall_rooftop_debri_022");
}

mall_rooftop_debri_023_spawn()
{
	wait 0.03;
	//mall_rooftop_debri_023();
}

mall_rooftop_debri_023()
{
	node = getstruct("mall_rooftop_debri_023", "script_noteworthy");
	mall_rooftop_debri_023 = spawn_anim_model("mall_rooftop_debri_023");
		attach_fx_anim_model( mall_rooftop_debri_023, "com_pallet_2", "j_mall_rooftop_debri_023_com_pallet_2_2" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_023_com_trashcan_metal_with_trash_3" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_folding_chair", "j_mall_rooftop_debri_023_com_folding_chair_4" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_023_com_trashcan_metal_with_trash_5" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_trashbin01", "j_mall_rooftop_debri_023_com_trashbin01_6" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_folding_chair", "j_mall_rooftop_debri_023_com_folding_chair_7" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_pallet_2", "j_mall_rooftop_debri_023_com_pallet_2_8" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_trashbin01", "j_mall_rooftop_debri_023_com_trashbin01_10" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_trashbin01", "j_mall_rooftop_debri_023_com_trashbin01_11" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_12" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_13" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_14" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_pallet_2", "j_mall_rooftop_debri_023_com_pallet_2_16" );
		attach_fx_anim_model( mall_rooftop_debri_023, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_023_vehicle_van_mica_destroyed_17" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_18" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_trashbin01", "j_mall_rooftop_debri_023_com_trashbin01_20" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_pallet_2", "j_mall_rooftop_debri_023_com_pallet_2_22" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_folding_chair", "j_mall_rooftop_debri_023_com_folding_chair_23" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_pallet_2", "j_mall_rooftop_debri_023_com_pallet_2_25" );
		attach_fx_anim_model( mall_rooftop_debri_023, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_023_vehicle_coupe_green_destroyed_26" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_27" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_28" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_folding_chair", "j_mall_rooftop_debri_023_com_folding_chair_31" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_folding_chair", "j_mall_rooftop_debri_023_com_folding_chair_32" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_folding_chair", "j_mall_rooftop_debri_023_com_folding_chair_34" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_023_com_trashcan_metal_with_trash_35" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_36" );
		attach_fx_anim_model( mall_rooftop_debri_023, "com_barrel_green", "j_mall_rooftop_debri_023_com_barrel_green_37" );
	
		mall_rooftop_debri_023 hide();
	guys = [];
	guys["mall_rooftop_debri_023"] = mall_rooftop_debri_023;
	node anim_single(guys, "mall_rooftop_debri_023");
}

mall_rooftop_wh_debri_01_spawn()
{
	//mall_rooftop_wh_debri_01();
}

mall_rooftop_wh_debri_01()
{
	node = getstruct("mall_rooftop_wh_debri_01", "script_noteworthy");
	mall_rooftop_wh_debri_01 = spawn_anim_model("mall_rooftop_wh_debri_01");
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_1" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_2" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_3" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_4" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_5" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_6" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_7" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_8" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_9" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_10" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_11" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_12" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_13" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_14" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_15" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_16" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_17" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_18" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_19" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_20" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_21" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_22" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_23" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_24" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_25" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_26" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_27" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_28" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_29" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_30" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_31" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_32" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_33" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_34" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_35" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_36" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_37" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_38" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_39" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_40" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_41" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_42" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_43" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_44" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_45" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_46" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_47" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_48" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_49" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_50" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_51" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_52" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_53" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_54" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_55" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_56" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_57" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_58" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_59" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_60" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_61" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_62" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_63" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_64" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_65" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_66" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_67" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_68" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_69" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_70" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_71" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "cardboard_box9", "j_mall_rooftop_wh_debri_01_cardboard_box9_72" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_73" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "flood_crate_plastic_single02", "j_mall_rooftop_wh_debri_01_flood_crate_plastic_single02_74" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_cardboardboxshortclosed_1", "j_mall_rooftop_wh_debri_01_com_cardboardboxshortclosed_1_75" );
		attach_fx_anim_model( mall_rooftop_wh_debri_01, "com_trash_bin_sml01", "j_mall_rooftop_wh_debri_01_com_trash_bin_sml01_76" );

	mall_rooftop_wh_debri_01 hide();
	guys = [];
	guys["mall_rooftop_wh_debri_01"] = mall_rooftop_wh_debri_01;
	node anim_single(guys, "mall_rooftop_wh_debri_01");
}

*/
/*

mall_rooftop_debri_03_spawn()
{

	mall_rooftop_debri_03();

}

mall_rooftop_debri_03()
{

	node = getstruct("mall_rooftop_debri_03", "script_noteworthy");

	mall_rooftop_debri_03 = spawn_anim_model("mall_rooftop_debri_03");

		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_1" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_2" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_3" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_4" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_5" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_6" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_7" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_8" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_03_vehicle_coupe_green_destroyed_9" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_10" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_11" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_12" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_13" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_14" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_15" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_16" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_17" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_18" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_19" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_20" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_21" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_22" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_23" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_24" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_25" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_26" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_27" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_28" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_29" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_30" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_31" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_32" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_33" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_34" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_35" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_36" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_37" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_38" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_39" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_03_vehicle_coupe_green_destroyed_40" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_41" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_42" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_43" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_44" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_03_vehicle_coupe_green_destroyed_45" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_46" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_47" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_48" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_49" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_03_vehicle_van_mica_destroyed_50" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_51" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_52" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_53" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_54" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_03_vehicle_van_mica_destroyed_55" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_56" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_57" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_58" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_03_vehicle_van_mica_destroyed_59" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_60" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_61" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_03_vehicle_coupe_green_destroyed_62" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_63" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_64" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_03_vehicle_van_mica_destroyed_65" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_66" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_67" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_68" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_69" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_70" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_71" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_72" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_73" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_74" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_van_mica_destroyed", "j_mall_rooftop_debri_03_vehicle_van_mica_destroyed_75" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_76" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_03_vehicle_coupe_green_destroyed_77" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_78" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_79" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_80" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_81" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_82" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_83" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_84" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_85" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_86" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_87" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_88" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_pallet_2", "j_mall_rooftop_debri_03_com_pallet_2_89" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_90" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_91" );
		attach_fx_anim_model( mall_rooftop_debri_03, "vehicle_coupe_green_destroyed", "j_mall_rooftop_debri_03_vehicle_coupe_green_destroyed_92" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_93" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_94" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_95" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_96" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_97" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_98" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_99" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_100" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_plastic_crate_pallet", "j_mall_rooftop_debri_03_com_plastic_crate_pallet_101" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_102" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_103" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_104" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashbin01", "j_mall_rooftop_debri_03_com_trashbin01_105" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_106" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_107" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_108" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_109" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_110" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_trashcan_metal_with_trash", "j_mall_rooftop_debri_03_com_trashcan_metal_with_trash_111" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_112" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_folding_chair", "j_mall_rooftop_debri_03_com_folding_chair_113" );
		attach_fx_anim_model( mall_rooftop_debri_03, "com_barrel_green", "j_mall_rooftop_debri_03_com_barrel_green_114" );
		
	mall_rooftop_debri_03 hide();
	guys = [];
	guys["mall_rooftop_debri_03"] = mall_rooftop_debri_03;

	node anim_single(guys, "mall_rooftop_debri_03");

}



*/
/*
rooftops_building_01_debri()
{
	node = getstruct("mall_rooftop_debri_023", "script_noteworthy");
	mall_rooftop_debri_023 = spawn_anim_model("mall_rooftop_debri_023");
attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_1" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_2" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_plastic_crate_pallet", "j_flood_rooftops_building01_debri01_com_plastic_crate_pallet_3" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_pallet_2", "j_flood_rooftops_building01_debri01_com_pallet_2_4" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_5" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_6" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_7" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashcan_metal_with_trash", "j_flood_rooftops_building01_debri01_com_trashcan_metal_with_trash_8" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_9" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_10" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_11" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_12" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_13" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_14" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "pb_weaponscase", "j_flood_rooftops_building01_debri01_pb_weaponscase_15" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashcan_metal_with_trash", "j_flood_rooftops_building01_debri01_com_trashcan_metal_with_trash_16" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_17" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_18" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_19" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_20" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_pallet_2", "j_flood_rooftops_building01_debri01_com_pallet_2_21" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashcan_metal_with_trash", "j_flood_rooftops_building01_debri01_com_trashcan_metal_with_trash_22" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_23" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_24" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_25" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_26" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_27" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_28" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_29" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashbin01", "j_flood_rooftops_building01_debri01_com_trashbin01_30" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_31" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_32" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_33" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_34" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_35" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_36" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_37" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_38" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashcan_metal_with_trash", "j_flood_rooftops_building01_debri01_com_trashcan_metal_with_trash_39" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_40" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_41" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_42" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_43" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashbin01", "j_flood_rooftops_building01_debri01_com_trashbin01_44" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_45" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_plastic_crate_pallet", "j_flood_rooftops_building01_debri01_com_plastic_crate_pallet_46" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_47" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_48" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_49" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_50" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_51" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_52" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_barrel_green", "j_flood_rooftops_building01_debri01_com_barrel_green_53" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_54" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashbin01", "j_flood_rooftops_building01_debri01_com_trashbin01_55" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "pb_weaponscase", "j_flood_rooftops_building01_debri01_pb_weaponscase_56" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_57" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashcan_metal_with_trash", "j_flood_rooftops_building01_debri01_com_trashcan_metal_with_trash_58" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_59" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_60" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_61" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_pallet_2", "j_flood_rooftops_building01_debri01_com_pallet_2_62" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_folding_chair", "j_flood_rooftops_building01_debri01_com_folding_chair_63" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_64" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_folding_chair", "j_flood_rooftops_building01_debri01_com_folding_chair_65" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_folding_chair", "j_flood_rooftops_building01_debri01_com_folding_chair_66" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashbin01", "j_flood_rooftops_building01_debri01_com_trashbin01_67" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_68" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_69" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_70" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium01_71" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_72" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_73" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_plastic_crate_pallet", "j_flood_rooftops_building01_debri01_com_plastic_crate_pallet_74" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_75" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_76" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_barrel_green", "j_flood_rooftops_building01_debri01_com_barrel_green_77" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_folding_chair", "j_flood_rooftops_building01_debri01_com_folding_chair_78" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "pb_weaponscase", "j_flood_rooftops_building01_debri01_pb_weaponscase_82" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_folding_chair", "j_flood_rooftops_building01_debri01_com_folding_chair_83" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_trashbin01", "j_flood_rooftops_building01_debri01_com_trashbin01_84" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall04", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall04_85" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardsmall03", "j_flood_rooftops_building01_debri01_com_wallchunk_boardsmall03_86" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_87" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_folding_chair", "j_flood_rooftops_building01_debri01_com_folding_chair_89" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardmedium02", "j_flood_rooftops_building01_debri01_com_wallchunk_boardmedium02_90" );
		attach_fx_anim_model( flood_rooftops_building01_debri01, "com_wallchunk_boardlarge01", "j_flood_rooftops_building01_debri01_com_wallchunk_boardlarge01_91" );
		
		mall_rooftop_debri_023 hide();
	guys = [];
	guys["mall_rooftop_debri_023"] = mall_rooftop_debri_023;
	node anim_single(guys, "mall_rooftop_debri_023");
	
}

*/
building_01_debri_anim_spawn()
{

	building_01_debri_anim();

}

building_01_debri_anim()
{
	exploder( "rooftops_amb_fx" );

	node = getstruct("building_01_debri_anim", "script_noteworthy");

	building_01_debri = spawn_anim_model("building_01_debri");
	attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_5" );
		
	attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_6" );
		attach_fx_anim_model( building_01_debri, "com_plastic_crate_pallet", "j_building_01_debri_com_plastic_crate_pallet_7" );
		attach_fx_anim_model( building_01_debri, "com_pallet_2", "j_building_01_debri_com_pallet_2_8" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_9" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_10" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_11" );
		attach_fx_anim_model( building_01_debri, "com_trashcan_metal_with_trash", "j_building_01_debri_com_trashcan_metal_with_trash_12" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_13" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_14" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_15" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_16" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_17" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_18" );
		attach_fx_anim_model( building_01_debri, "pb_weaponscase", "j_building_01_debri_pb_weaponscase_19" );
		attach_fx_anim_model( building_01_debri, "com_trashcan_metal_with_trash", "j_building_01_debri_com_trashcan_metal_with_trash_20" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_21" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_22" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_23" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_24" );
		attach_fx_anim_model( building_01_debri, "com_pallet_2", "j_building_01_debri_com_pallet_2_25" );
		attach_fx_anim_model( building_01_debri, "com_trashcan_metal_with_trash", "j_building_01_debri_com_trashcan_metal_with_trash_26" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_27" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_28" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_29" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_30" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_31" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_32" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_33" );
		attach_fx_anim_model( building_01_debri, "com_trashbin01", "j_building_01_debri_com_trashbin01_34" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_35" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_36" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_37" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_38" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_39" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_40" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_41" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_42" );
		attach_fx_anim_model( building_01_debri, "com_trashcan_metal_with_trash", "j_building_01_debri_com_trashcan_metal_with_trash_43" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_44" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_45" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_46" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_47" );
		attach_fx_anim_model( building_01_debri, "com_trashbin01", "j_building_01_debri_com_trashbin01_48" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_49" );
		attach_fx_anim_model( building_01_debri, "com_plastic_crate_pallet", "j_building_01_debri_com_plastic_crate_pallet_50" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_51" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_52" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_53" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_54" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_55" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_56" );
		attach_fx_anim_model( building_01_debri, "com_barrel_green", "j_building_01_debri_com_barrel_green_57" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_58" );
		attach_fx_anim_model( building_01_debri, "com_trashbin01", "j_building_01_debri_com_trashbin01_59" );
		attach_fx_anim_model( building_01_debri, "pb_weaponscase", "j_building_01_debri_pb_weaponscase_60" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_61" );
		attach_fx_anim_model( building_01_debri, "com_trashcan_metal_with_trash", "j_building_01_debri_com_trashcan_metal_with_trash_62" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_63" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_64" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_65" );
		attach_fx_anim_model( building_01_debri, "com_pallet_2", "j_building_01_debri_com_pallet_2_66" );
		attach_fx_anim_model( building_01_debri, "com_folding_chair", "j_building_01_debri_com_folding_chair_67" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_68" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_69" );
		attach_fx_anim_model( building_01_debri, "com_folding_chair", "j_building_01_debri_com_folding_chair_70" );
		attach_fx_anim_model( building_01_debri, "com_folding_chair", "j_building_01_debri_com_folding_chair_71" );
		attach_fx_anim_model( building_01_debri, "com_trashbin01", "j_building_01_debri_com_trashbin01_72" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_73" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_74" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_75" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium01", "j_building_01_debri_com_wallchunk_boardmedium01_76" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_77" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_78" );
		attach_fx_anim_model( building_01_debri, "com_plastic_crate_pallet", "j_building_01_debri_com_plastic_crate_pallet_80" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_81" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_82" );
		attach_fx_anim_model( building_01_debri, "com_barrel_green", "j_building_01_debri_com_barrel_green_83" );
		attach_fx_anim_model( building_01_debri, "com_folding_chair", "j_building_01_debri_com_folding_chair_84" );
		attach_fx_anim_model( building_01_debri, "pb_weaponscase", "j_building_01_debri_pb_weaponscase_85" );
		attach_fx_anim_model( building_01_debri, "com_folding_chair", "j_building_01_debri_com_folding_chair_86" );
		attach_fx_anim_model( building_01_debri, "com_trashbin01", "j_building_01_debri_com_trashbin01_87" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall04", "j_building_01_debri_com_wallchunk_boardsmall04_88" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardsmall03", "j_building_01_debri_com_wallchunk_boardsmall03_89" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_90" );
		attach_fx_anim_model( building_01_debri, "com_folding_chair", "j_building_01_debri_com_folding_chair_91" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardmedium02", "j_building_01_debri_com_wallchunk_boardmedium02_92" );
		attach_fx_anim_model( building_01_debri, "com_wallchunk_boardlarge01", "j_building_01_debri_com_wallchunk_boardlarge01_93" );
		
		building_01_debri hide();
	guys = [];
	guys["building_01_debri"] = building_01_debri;

	node anim_single(guys, "building_01_debri_anim");

}


setup_enemies_open_gate()
{
	level.ending_gate_l = spawn_anim_model( "ending_breach_door_l" );
	level.ending_gate_r = spawn_anim_model( "ending_breach_door_r" );

	level.ending_gate_node_left = getstruct( "ending_gate_node_left", "targetname" );
	level.ending_gate_node_left anim_first_frame_solo( level.ending_gate_l, "outro_pt1_breach" );
	level.ending_gate_node_right = getstruct( "ending_gate_node_right", "targetname" );
	level.ending_gate_node_right anim_first_frame_solo( level.ending_gate_r, "outro_pt1_breach" );

	parts = GetEntArray( "garage_door_r", "targetname" );
	foreach( part in parts )
	{
		part LinkTo( level.ending_gate_l );
	}
	parts = GetEntArray( "garage_door_l", "targetname" );
	foreach( part in parts )
	{
		part LinkTo( level.ending_gate_r );
	}
}

enemies_open_gate()
{
	spawners = GetEntArray( "ending_enemies", "targetname" );
	array_thread( spawners, ::add_spawn_function, ::disable_long_death );
	array_thread( spawners, ::add_spawn_function, ::enable_cqbwalk );
	array_thread( spawners, ::add_spawn_function, maps\flood_ending::ending_temp_ignore );
	array_thread( spawners, ::spawn_ai, true );

	spawner = GetEnt( "gate_keeper", "targetname" );
	spawner add_spawn_function( ::disable_long_death );
	spawner add_spawn_function( maps\flood_ending::ending_temp_ignore );
	actor = spawner spawn_ai( true );
	actor.animname = "generic";

	node = getstruct( "ending_open_door" , "targetname" );

	node anim_reach_solo( actor, "ending_door_kick" );
	node thread anim_single_solo( actor, "ending_door_kick" );
	wait( 0.10 );
	level.ending_gate_node_left thread anim_single_solo( level.ending_gate_l, "outro_pt1_breach" );
	level.ending_gate_node_right thread anim_single_solo( level.ending_gate_r, "outro_pt1_breach" );
}

notetrack_open_gate( guy )
{
	maps\flood_ending::ending_swing_doors_open();
	flag_set( "ending_gate_open" );
}