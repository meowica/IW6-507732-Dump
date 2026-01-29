#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;



main()
{
	generic_human();
	shark();
	player();
	radio();
	script_model();
	vehicles();
}

#using_animtree( "vehicles" );
vehicles()
{
	level.scr_anim[ "missile_boat" ][ "missile_boat_arrive" ] = %ship_graveyard_boat_arrival;
	level.scr_anim[ "missile_boat" ][ "missile_boat_idle" ][0] = %ship_graveyard_boat_idle;
	
	level.scr_model[ "crash_chopper" ] = "vehicle_mi_28_destroyed";
	level.scr_animtree[ "crash_chopper" ] = #animtree;
	level.scr_anim[ "crash_chopper" ][ "trench_drown" ] = %ship_graveyard_underwater_rescue_hind;
	addNoteTrack_flag( "crash_chopper", "start_drop", "drown_chopper_start", "trench_drown" );
	addNoteTrack_flag( "crash_chopper", "impact_1", "drown_chopper_i1", "trench_drown" );
	addNoteTrack_flag( "crash_chopper", "impact_2", "drown_chopper_i2", "trench_drown" );
	addNoteTrack_flag( "crash_chopper", "impact_3", "drown_chopper_i3", "trench_drown" );
	
	level.scr_animtree[ "lcs_front" ] = #animtree;
	level.scr_anim[ "lcs_front" ][ "lighthouse_fall" ] = %ship_graveyard_lighthouse_fall_LCS_front;
	
	level.scr_animtree[ "lcs_back" ] = #animtree;
	level.scr_anim[ "lcs_back" ][ "lighthouse_fall" ] = %ship_graveyard_lighthouse_fall_LCS_rear;
	
	level.scr_animtree[ "torpedo" ] = #animtree;
	level.scr_anim[ "torpedo" ][ "torpedo_idle" ] = %torpedo_deployed_idle;
}

#using_animtree( "script_model" );
script_model()
{
	level.scr_model[ "torch" ] = "weapon_underwater_torch";
	level.scr_animtree[ "torch" ] = #animtree;
	level.scr_anim[ "torch" ][ "weld_idle" ][0] = %swimming_welding_1_torch;
	addNotetrack_customFunction( "torch", "weld_on", ::weld_fx_on, "weld_idle" );
	addNotetrack_customFunction( "torch", "weld_off", ::weld_fx_off, "weld_idle" );
	
	level.scr_model[ "bangstick" ] = "old_wood_churnstick_01";
	level.scr_animtree[ "bangstick" ] = #animtree;
	
	level.scr_model[ "trench_boat" ] = "tag_origin";
	level.scr_animtree[ "trench_boat" ] = #animtree;
	level.scr_anim[ "trench_boat" ][ "trench_drown" ] = %ship_graveyard_underwater_rescue_boat;
	
	level.scr_model[ "breather_hose" ] = "props_scuba_hose_a";
	level.scr_animtree[ "breather_hose" ] = #animtree;
	level.scr_anim[ "breather_hose" ][ "trench_drown" ] = %ship_graveyard_underwater_rescue_tube;
	
	level.scr_model[ "debris" ] = "shpg_wreck_debris_c";
	level.scr_animtree[ "debris" ] = #animtree;
	level.scr_anim[ "debris" ][ "trench_drown" ] = %ship_graveyard_underwater_rescue_debris;
	
	level.scr_model[ "cars" ] = "shpg_barge_cars";
	level.scr_animtree[ "cars" ] = #animtree;
	level.scr_anim[ "cars" ][ "car_crash" ] = %ship_graveyard_car0;
	
	level.scr_animtree[ "lcs" ] = #animtree;
	level.scr_anim[ "lcs" ][ "lcs_crash" ] = %ship_graveyard_boat_collapse;
	addNoteTrack_flag( "lcs", "boat_ground", "trench_lcs_hit_ground", "lcs_crash" );
	addNoteTrack_flag( "lcs", "boat_barge", "trench_lcs_hit_barge", "lcs_crash" );
	
	level.scr_animtree[ "barge" ] = #animtree;
	level.scr_anim[ "barge" ][ "lcs_crash" ] = %ship_graveyard_barge_collapse;
	
	level.scr_animtree[ "door_L" ] = #animtree;
	level.scr_animtree[ "door_R" ] = #animtree;
	level.scr_animtree[ "pole" ] = #animtree;
	level.scr_animtree[ "barrel" ] = #animtree;
	level.scr_animtree[ "torch_f" ] = #animtree;
	level.scr_animtree[ "torch_p" ] = #animtree;
	level.scr_animtree[ "pipe" ] = #animtree;

	level.scr_model[ "pipe" ] = "shpg_dbreach_pipe_a";
	level.scr_anim[ "pipe" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_pole;
	
	level.scr_model[ "torch_f" ] = "viewmodel_underwater_torch";
	level.scr_model[ "torch_p" ] = "viewmodel_underwater_torch";
	
	level.scr_anim[ "torch_p" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_player_torch;
	level.scr_anim[ "torch_f" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_friendly_torch;
	level.scr_anim[ "torch_p" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_player_torch;
	level.scr_anim[ "torch_f" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_friendly_torch;	
	level.scr_anim[ "torch_p" ][ "weld_breach_idle" ][0] = %ship_graveyard_door_breach_idle_player_torch;
	level.scr_anim[ "torch_f" ][ "weld_breach_idle" ][0] = %ship_graveyard_door_breach_idle_friendly_torch;
	
	addNotetrack_customFunction( "torch_p", "weld_pop", ::weld_fx_pop, "weld_breach" );
	addNotetrack_customFunction( "torch_f", "weld_pop_friendly", ::weld_fx_pop, "weld_breach" );
	
	level.scr_anim[ "door_L" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_door_L;
	level.scr_anim[ "door_R" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_door_R;
	level.scr_anim[ "door_L" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_door_L;
	level.scr_anim[ "door_R" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_door_R;
	
	level.scr_anim[ "pole" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_pole;
	
	level.scr_anim[ "barrel_0" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_01;
	level.scr_anim[ "barrel_1" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_02;
	level.scr_anim[ "barrel_2" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_03;
	level.scr_anim[ "barrel_3" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_04;
	level.scr_anim[ "barrel_4" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_05;
	level.scr_anim[ "barrel_5" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_06;
	level.scr_anim[ "barrel_6" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_07;
	level.scr_anim[ "barrel_7" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_08;
	level.scr_anim[ "barrel_8" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_09;
	level.scr_anim[ "barrel_9" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_10;
	level.scr_anim[ "barrel_10" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_11;
	level.scr_anim[ "barrel_11" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_12;
	level.scr_anim[ "barrel_12" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_13;
	level.scr_anim[ "barrel_13" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_14;
	level.scr_anim[ "barrel_14" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_15;
	level.scr_anim[ "barrel_15" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_barrel_16;
	
	addNoteTrack_sound( "barrel_5", "scn_shipg_torch_barrels_fall", "weld_breach", "scn_shipg_torch_barrels_fall" );
	
		
	level.scr_animtree[ "lighthouse" ] = #animtree;
	level.scr_anim[ "lighthouse" ][ "lighthouse_fall" ] = %ship_graveyard_lighthouse_fall_lighthouse;
	
	level.scr_animtree[ "intro_boat" ] = #animtree;
	level.scr_anim[ "intro_boat" ][ "rocking" ][0] = %ship_graveyard_intro_boat;
}

#using_animtree( "player" );
player()
{
	level.scr_anim[ "player_rig" ][ "shark_attack" ] = %shark_attack_VM_player_1;
	level.scr_anim[ "player_rig" ][ "shark_attack_2" ] = %shark_attack_VM_player_2;
	level.scr_anim[ "player_rig" ][ "shark_attack_4" ] = %shark_attack_VM_player_4;

	level.scr_anim[ "player_rig" ][ "shark_attack_F" ] = %shark_attack_VM_player_4;
	level.scr_anim[ "player_rig" ][ "shark_attack_R" ] = %shark_attack_VM_player_4_R;
	level.scr_anim[ "player_rig" ][ "shark_attack_L" ] = %shark_attack_VM_player_4_L;
	level.scr_anim[ "player_rig" ][ "shark_attack_B" ] = %shark_attack_VM_player_4;
	
	level.scr_anim[ "player_rig" ][ "trench_drown" ] = %ship_graveyard_underwater_rescue_player;
	addNoteTrack_flag( "player_rig", "drop_debris", "drown_drop_lcs", "trench_drown" );
	addNoteTrack_flag( "player_rig", "back_impact", "drown_player_impact", "trench_drown" );
	addNoteTrack_flag( "player_rig", "player_pre-unlink", "drown_pre_unlink_player", "trench_drown" );
	addNoteTrack_flag( "player_rig", "player_unlink", "drown_unlink_player", "trench_drown" );
	addNoteTrack_flag( "player_rig", "scn_shipg_rescue_hand", "drown_hand_sound", "trench_drown" );
	
	addNotetrack_customFunction( "player_rig", "drowning_sounds_rumbles", ::drowning_sounds_rumbles, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_hand_free_debris_burst", ::vfx_hand_free_debris_burst_fx, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_player_strain_forearm", ::vfx_player_strain_forearm, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_player_strain_wrist", ::vfx_player_strain_wrist, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_player_hand_r_on", ::vfx_player_hand_r_on, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_player_hand_r_off", ::vfx_player_hand_r_off, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_player_hand_l_on", ::vfx_player_hand_l_on, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_player_hand_l_off", ::vfx_player_hand_l_off, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_baker_hand_r_on", ::vfx_baker_hand_r_on, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_baker_hand_r_off", ::vfx_baker_hand_r_off, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_baker_hand_l_on", ::vfx_baker_hand_l_on, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_baker_hand_l_off", ::vfx_baker_hand_l_off, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_baker_hand_strain", ::vfx_baker_hand_strain, "trench_drown" );
	addNotetrack_customFunction( "player_rig", "scn_shipg_rescue_metal_bubbles", ::vfx_metal_bubbles, "trench_drown" );
		
	addNoteTrack_sound( "player_rig", "shipg_player_drowning", "trench_drown", "shipg_player_drowning" );
	//addNoteTrack_sound( "player_rig", "scn_shipg_rescue_hand", "trench_drown", "scn_shipg_rescue_hand" );
	addNoteTrack_sound( "player_rig", "scn_shipg_rescue_helmet", "trench_drown", "scn_shipg_rescue_helmet" );
	addNoteTrack_sound( "player_rig", "scn_shipg_rescue_heave", "trench_drown", "scn_shipg_rescue_heave" );
	addNoteTrack_sound( "player_rig", "scn_shipg_rescue_heli", "trench_drown", "scn_shipg_rescue_heli" );
	addNoteTrack_sound( "player_rig", "scn_shipg_rescue_hitback", "trench_drown", "scn_shipg_rescue_hitback" );
	addNoteTrack_sound( "player_rig", "scn_shipg_rescue_hitback", "trench_drown", "scn_shipg_rescue_hitback" );
	
	level.scr_anim[ "player_rig" ][ "melee_A" ] = %ship_graveyard_melee_A_charge_player;
	level.scr_anim[ "player_rig" ][ "melee_A_win" ] = %ship_graveyard_melee_A_win_player;
	level.scr_anim[ "player_rig" ][ "melee_A_lose" ] = %ship_graveyard_melee_A_lose_player;
	level.scr_anim[ "player_rig" ][ "melee_A_stab1" ] = %ship_graveyard_melee_A_stab1_player;
	level.scr_anim[ "player_rig" ][ "melee_A_stab2" ] = %ship_graveyard_melee_A_stab2_player;
	level.scr_anim[ "player_rig" ][ "melee_A_reset" ] = %ship_graveyard_melee_A_reset_player;

	
	addNotetrack_notify("player_rig","impact","impact","melee_A");
	addNotetrack_notify("player_rig","stab","stab","melee_A_stab1");
	addNotetrack_notify("player_rig","stab","stab","melee_A_win");
	addNotetrack_notify("player_rig","pull_out","pull_out","melee_A_win");
	addNotetrack_notify("player_rig","stop anim","stop anim","melee_A_win");
	
	addNotetrack_sound("player_rig","stab_sound","melee_A_stab1","scn_shipg_melee_stab1");
	addNotetrack_sound("player_rig","stab_sound","melee_A_stab2","scn_shipg_melee_stab2");
	
	level.scr_sound[ "player_rig" ][ "melee_A_lose" ] = "scn_shipg_melee_stab2";
	
	level.scr_anim[ "player_rig" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_player;
	level.scr_anim[ "player_rig" ][ "weld_breach_idle" ][0] = %ship_graveyard_door_breach_idle_player;
	level.scr_anim[ "player_rig" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_player;
	
	addNoteTrack_sound( "player_rig", "scn_shipg_torch_plr_ignite", "weld_approach", "scn_shipg_torch_plr_ignite" );
	addNoteTrack_sound( "player_rig", "scn_shipg_torch_plr_torch", "weld_breach", "scn_shipg_torch_plr_torch" );
	
	addNoteTrack_notify( "player_rig", "script 87", "script 87", "weld_approach" );
		
	addNotetrack_customFunction( "player_rig", "script 87", ::weld_sound_loop_player, "weld_approach" );
	
	addNoteTrack_flag( "player_rig", "script 77", "fade_sound_player_torch1", "weld_breach" );
	addNoteTrack_flag( "player_rig", "script 123", "fade_sound_player_torch2", "weld_breach" );
	addNoteTrack_flag( "player_rig", "script 214", "fade_sound_player_torch3", "weld_breach" );
	addNoteTrack_flag( "player_rig", "script 274", "fade_sound_player_torch4", "weld_breach" );
	addNoteTrack_flag( "player_rig", "script 337", "fade_sound_player_torch5", "weld_breach" );	
	
	level.scr_anim[ "player_rig" ][ "lighthouse_deploy" ] = %ship_graveyard_lighthouse_deploy_player;
	level.scr_anim[ "player_rig" ][ "lighthouse_entry" ] = %ship_graveyard_lighthouse_entry_player;
	
	//addNotetrack_customFunction( "lighthouse_deploy", "Torpedo_on", ::vfx_torpedo_kickup, "player_rig" );
	//addNotetrack_customFunction( "lighthouse_deploy", "Torpedo_on", ::vfx_torpedo_wings_out, "player_rig" );
	
	level.scr_anim[ "player_rig" ][ "lighthouse_fall_arms" ] = %ship_graveyard_lighthouse_fall_player_lurp;
	level.scr_anim[ "player_rig" ][ "lighthouse_fall" ] = %ship_graveyard_lighthouse_fall_player;
	
	level.scr_anim[ "player_rig" ][ "idle_above_water" ][0] = %ship_graveyard_intro_player_above_water;
	level.scr_anim[ "player_rig" ][ "roll_into_water" ] = %ship_graveyard_intro_player_above_water_rolloff;
	level.scr_anim[ "player_rig" ][ "below_water_tutorial_dive" ] = %ship_graveyard_intro_player_below_water;
}

weld_sound_loop_player(guy)
{
//	org = guy spawn_tag_origin();
//	org.origin = guy GetTagOrigin("tag_weapon_right");
	
//	org LinkTo(guy, "tag_weapon_right");

	org = level.player.torch_fx_org;
	
	org ScaleVolume(0.0, 0);
	waitframe();

	org PlayLoopSound("scn_shipg_torch_plr_torch_loop");
	
	org ScaleVolume(1, 1.56);
	
	flag_wait("fade_sound_player_torch1");
	org scalevolume(0.0, 0.66);
	
	flag_wait("fade_sound_player_torch2");
	org scalevolume(1.0,0.66);
	
	flag_wait("fade_sound_player_torch3");
	org scalevolume(0.0, 0.66);  
	
	flag_wait("fade_sound_player_torch4");
	org scalevolume(1.0, 0.66); 
	
	flag_wait("fade_sound_player_torch5");
	org scalevolume (0.0, 2.6);
	
	wait 2.6;
	org thread stop_loop_sound_on_entity("scn_shipg_torch_plr_torch_loop");
}

vfx_torpedo_kickup( thing ) 
{
	playfxontag( getfx( "torpedo_kickup" ), thing, "TAG_PROPELLER_FX" );
}

vfx_torpedo_wings_out( thing ) 
{
	playfxontag( getfx( "torpedo_wings_out" ), thing, "r_wing0_JNT" );
}

vfx_hand_free_debris_burst_fx( thing ) 
{
	playfxontag( getfx( "hand_free_debris_burst" ), thing, "j_wrist_ri" );
}

vfx_player_strain_forearm( thing ) 
{
	playfxontag( getfx( "hand_debris_strain_forearm" ), thing, "j_elbow_ri" );
}

vfx_player_strain_wrist( thing ) 
{
	playfxontag( getfx( "hand_debris_strain_wrist" ), thing, "j_wrist_ri" );
}

vfx_player_hand_r_on( thing ) 
{
	playfxontag( getfx( "hand_debris_player_on" ), thing, "j_mid_ri_1" );
}

vfx_player_hand_r_off( thing ) 
{
	playfxontag( getfx( "hand_debris_player_off" ), thing, "j_mid_ri_1" );
}

vfx_player_hand_l_on( thing ) 
{
	playfxontag( getfx( "hand_debris_player_on" ), thing, "j_mid_le_1" );
}

vfx_player_hand_l_off( thing ) 
{
	playfxontag( getfx( "hand_debris_player_off" ), thing, "j_mid_le_1" );
}

vfx_baker_hand_r_on( thing ) 
{
	playfxontag( getfx( "hand_debris_baker_on" ), level.baker, "j_mid_ri_1" );
}

vfx_baker_hand_r_off( thing ) 
{
	playfxontag( getfx( "hand_debris_baker_off" ), level.baker, "j_mid_ri_1" );
}

vfx_baker_hand_l_on( thing ) 
{
	playfxontag( getfx( "hand_debris_baker_on" ), level.baker, "j_mid_le_1" );
}

vfx_baker_hand_l_off( thing ) 
{
	playfxontag( getfx( "hand_debris_baker_off" ), level.baker, "j_mid_le_1" );
}

vfx_baker_hand_strain( thing ) 
{
	playfxontag( getfx( "hand_debris_baker_strain" ), level.baker, "j_mid_le_1" );
}

vfx_metal_bubbles( thing ) 
{
	playfxontag( getfx( "metal_plate_bubbles" ), thing, "j_mid_ri_1" );
}

drowning_sounds_rumbles( thing )
{
//	level.player PlayRumbleOnEntity( "damage_light" );
//	Earthquake( 0.2, 0.25, level.player.origin, 1024 );	
}

#using_animtree( "animals" );
shark()
{
	level.scr_model[ "shark" ] = "fullbody_tigershark";
	level.scr_animtree[ "shark" ] = #animtree;
	level.scr_anim[ "shark" ][ "shark_swim_f" ][0] = %shark_swim_f;
	level.scr_anim[ "shark" ][ "shark_swim_l" ][0] = %shark_swim_l;
	level.scr_anim[ "shark" ][ "shark_swim_r" ][0] = %shark_swim_r;
	level.scr_anim[ "shark" ][ "shark_attack" ] = %shark_attack_VM_shark_1;
	level.scr_anim[ "shark" ][ "shark_attack_2" ] = %shark_attack_VM_shark_2;
	level.scr_anim[ "shark" ][ "shark_attack_4" ] = %shark_attack_VM_shark_4;
	
	level.scr_anim[ "shark" ][ "shark_attack_F" ] = %shark_attack_VM_shark_4;
	level.scr_anim[ "shark" ][ "shark_attack_R" ] = %shark_attack_VM_shark_4_R;
	level.scr_anim[ "shark" ][ "shark_attack_L" ] = %shark_attack_VM_shark_4_L;
	level.scr_anim[ "shark" ][ "shark_attack_B" ] = %shark_attack_VM_shark_4;
	
	level.scr_anim[ "shark" ][ "shark_moment" ]	  = %shark_attack_on_diver_1_shark;
	level.scr_anim[ "shark" ][ "shark_moment2" ]	  = %shark_attack_on_diver_2_shark;
}

#using_animtree( "generic_human" );
generic_human()
{
	level.scr_anim[ "generic" ][ "surface_swim_idle" ][0] = %prague_intro_swim_idle_01;
	
	level.scr_anim[ "generic" ][ "sonar_hit" ] = %swimming_blast_front;
	
	level.scr_anim[ "generic" ][ "swimming_swim_turn_l180" ] = %swimming_swim_turn_l180;
	level.scr_anim[ "generic" ][ "swimming_swim_turn_U45"  ] = %swimming_swim_turn_U45;
	level.scr_anim[ "generic" ][ "swimming_swim_turn_R45"  ] = %swimming_swim_turn_R45;
	level.scr_anim[ "generic" ][ "swimming_swim_turn_D45"  ] = %swimming_swim_turn_D45;
	level.scr_anim[ "generic" ][ "swimming_swim_turn_U45_L45"  ] = %swimming_swim_turn_U45_L45;
	level.scr_anim[ "generic" ][ "swimming_swim_turn_D45_R45"  ] = %swimming_swim_turn_D45_R45;
	
	level.scr_anim[ "generic" ][ "swimming_aiming_move_to_idle_180" ] = %swimming_aiming_move_to_idle_180;
	level.scr_anim[ "generic" ][ "swimming_idle_to_aiming_move_180" ] = %swimming_idle_to_aiming_move_180;
	
	level.scr_anim[ "generic" ][ "swimming_aiming_move_to_cover_r1_l45_d45" ] = %swimming_aiming_move_to_cover_r1_l45_d45;
	level.scr_anim[ "generic" ][ "swimming_cover_r1_to_aiming_move_r45_u45" ] = %swimming_cover_r1_to_aiming_move_r45_u45;
	level.scr_anim[ "generic" ][ "swimming_cover_r1_loop" ][ 0 ]	  = %swimming_cover_r1_loop;
	
	level.scr_anim[ "generic" ][ "swimming_aiming_move_to_cover_l1" ] = %swimming_aiming_move_to_cover_l1;
	level.scr_anim[ "generic" ][ "swimming_cover_l1_exit_r180"		] = %swimming_cover_l1_to_aiming_move_r90;
	level.scr_anim[ "generic" ][ "swimming_cover_l1_idle" ][ 0 ]	  = %swimming_cover_l1_idle;
	
	level.scr_anim[ "generic" ][ "swimming_aiming_move_to_cover_l1_r90" ] = %swimming_aiming_move_to_cover_l1_r90;
	level.scr_anim[ "generic" ][ "swimming_cover_l1_to_aiming_move_l90" ] = %swimming_cover_l1_to_aiming_move_l90;
	
	level.scr_anim[ "generic" ][ "harbor_floating_idle_04" ][ 0 ]	  = %harbor_floating_idle_04;
	level.scr_anim[ "generic" ][ "harbor_floating_idle_03" ][ 0 ]	  = %harbor_floating_idle_03;
	level.scr_anim[ "generic" ][ "harbor_floating_idle_02" ][ 0 ]	  = %harbor_floating_idle_02;
	
	level.scr_anim[ "generic" ][ "shark_moment" ]	  = %shark_attack_on_diver_1_diver;
	level.scr_anim[ "generic" ][ "shark_moment2" ]	  = %shark_attack_on_diver_2_diver;
	
	level.scr_anim[ "generic" ][ "weld_idle" ][0]	  = %swimming_welding_1;
	level.scr_anim[ "generic" ][ "bangstick_idle" ][0]	  = %swimming_bang_stick_idle;
	
	level.scr_anim[ "generic" ][ "trench_drown" ] = %ship_graveyard_underwater_rescue_baker;
	addNoteTrack_flag( "generic", "rebreather_plugin", "drown_rebreather_plugin", "trench_drown" );
	addNoteTrack_flag( "generic", "debris_drop", "drown_debris_impact", "trench_drown" );
	
	level.scr_anim[ "generic" ][ "death_boat_A" ] = %ship_graveyard_boat_death_A;
	level.scr_anim[ "generic" ][ "death_boat_A_loop" ][0] = %ship_graveyard_boat_death_A_hold;
	
	level.scr_anim[ "generic" ][ "melee_A" ] = %ship_graveyard_melee_A_charge_enemy;
	level.scr_anim[ "generic" ][ "melee_A_win" ] = %ship_graveyard_melee_A_win_enemy;
	level.scr_anim[ "generic" ][ "melee_A_lose" ] = %ship_graveyard_melee_A_lose_enemy;
	level.scr_anim[ "generic" ][ "melee_A_stab1" ] = %ship_graveyard_melee_A_stab1_enemy;
	level.scr_anim[ "generic" ][ "melee_A_stab2" ] = %ship_graveyard_melee_A_stab2_enemy;
	level.scr_anim[ "generic" ][ "melee_A_reset" ] = %ship_graveyard_melee_A_reset_enemy;

		
	addNotetrack_notify("generic","mask_pull","mask_pull","melee_A");
	addNotetrack_notify("generic","start_ragdoll","start_ragdoll","melee_A_win");
	addNotetrack_notify("generic","stop_anim","stop_anim","melee_A_win");
	addNotetrack_notify("generic","pull_out","pull_out","melee_A_reset");
	addNotetrack_notify("generic","pull_out","pull_out","melee_A_lose");
	addNotetrack_notify("generic","stop anim","stop anim","melee_A_lose");
	
	
	level.scr_anim[ "baker" ][ "weld_approach" ] = %ship_graveyard_door_breach_approach_friendly;
	level.scr_anim[ "baker" ][ "weld_breach_idle" ][0] = %ship_graveyard_door_breach_idle_friendly;
	level.scr_anim[ "baker" ][ "weld_breach" ] = %ship_graveyard_door_breach_cut_friendly;
	
	addNoteTrack_sound( "baker", "scn_shipg_torch_npc_grab1", "weld_approach", "scn_shipg_torch_npc_grab1" );	
	addNoteTrack_sound( "baker", "scn_shipg_torch_npc_grab2", "weld_approach", "scn_shipg_torch_npc_grab2" );	
	addNoteTrack_sound( "baker", "scn_shipg_torch_npc_hitdoor", "weld_approach", "scn_shipg_torch_npc_hitdoor" );	
	addNoteTrack_sound( "baker", "scn_shipg_torch_npc_ignite", "weld_approach", "scn_shipg_torch_npc_ignite" );	
	
	addNoteTrack_sound( "baker", "scn_shipg_torch_npc_torch1", "weld_breach", "scn_shipg_torch_npc_torch1" );
	
	addNotetrack_customFunction( "baker", "script 250", ::weld_sound_loop_npc, "weld_approach" );
	addNoteTrack_flag( "baker", "script 279", "stop_npc_weld_sfx_loop", "weld_breach" );
		
	level.scr_anim[ "baker" ][ "lighthouse_deploy" ] = %ship_graveyard_lighthouse_deploy_friendly;
	level.scr_anim[ "baker" ][ "lighthouse_entry" ] = %ship_graveyard_lighthouse_entry_friendly;
	level.scr_anim[ "baker" ][ "lighthouse_idle" ][0] = %ship_graveyard_lighthouse_idle_friendly;
	level.scr_anim[ "baker" ][ "lighthouse_nag" ] = %ship_graveyard_lighthouse_nag_friendly;
	level.scr_anim[ "baker" ][ "lighthouse_fall" ] = %ship_graveyard_lighthouse_fall_friendly;
	
	level.scr_anim[ "baker" ][ "on_boat_intro" ] = %ship_graveyard_intro_friendly_above_water;
	
	level.scr_anim[ "legs" ][ "lighthouse_fall" ] = %ship_graveyard_lighthouse_fall_player_legs;
	level.scr_anim[ "legs" ][ "below_water_tutorial_dive" ] = %ship_graveyard_intro_player_below_water_legs;
	level.scr_animtree[ "legs" ] = #animtree;		
}

weld_sound_loop_npc(guy)
{
	level.baker.torch_fx_org ScaleVolume(0.0, 0);
	waitframe();
	level.baker.torch_fx_org PlayLoopSound("scn_shipg_torch_npc_torch_loop", "j_wrist_le", 1, 1);
	level.baker.torch_fx_org ScaleVolume(1, 0.9);
	
	flag_wait("stop_npc_weld_sfx_loop");
	
	level.baker.torch_fx_org stop_loop_sound_on_entity("scn_shipg_torch_npc_torch_loop");
}

radio()
{
	level.scr_radio[ "shpg_killfirm_other_0" ] = "shipg_bkr_tangodown";
	level.scr_radio[ "shpg_killfirm_other_1" ] = "shipg_bkr_gotone";
	level.scr_radio[ "shpg_killfirm_other_2" ] = "shipg_bkr_hesdown";
	level.scr_radio[ "shpg_killfirm_other_3" ] = "shipg_bkr_targetneutralized";

	level.scr_radio[ "shpg_killfirm_other_0_loud" ] = "shipg_bkr_tangodown2";
	level.scr_radio[ "shpg_killfirm_other_1_loud" ] = "shipg_bkr_hesdown3";
	level.scr_radio[ "shpg_killfirm_other_2_loud" ] = "shipg_bkr_targetdown";
	level.scr_radio[ "shpg_killfirm_other_3_loud" ] = "shipg_bkr_gothim";
	
	level.scr_radio[ "shpg_shark_attack_0" ] = "shipg_bkr_ontousmovemove";
	level.scr_radio[ "shpg_shark_attack_1" ] = "shipg_bkr_theyreontous";
}

weld_fx_on( torch )
{
	if ( !isdefined( torch.welding ) || torch.welding == false )
		torch.welding = true;
	else
		return;
	
	playfxontag( getfx( "weld_sparks" ), torch, "tag_fx" );
	torch PlayLoopSound ( "scn_shipg_sm_wreck_npc_torch_lp");
	torch thread play_sound_on_entity("scn_shipg_sm_wreck_npc_torch_start");	
}


weld_fx_off( torch )
{
	torch.welding = false;
	stopfxontag( getfx( "weld_sparks" ), torch, "tag_fx" );
	torch thread play_sound_on_entity("scn_shipg_sm_wreck_npc_torch_stop");
	torch StopLoopSound ("scn_shipg_sm_wreck_npc_torch_lp");
}

weld_fx_pop( torch )
{
	playfxontag( getfx( "welding_underwater_pop" ), torch, "tag_fx" );
}