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
	level.scr_animtree[ "player_rig" ]						 = #animtree;
	level.scr_model[ "player_rig" ]   					     = "viewhands_player_udt";
	level.scr_anim[ "player_rig" ][ "player_sway_static" ] = %sw_player_sway_static;
	level.scr_anim[ "player_rig" ][ "player_nosway_static" ] = %sw_player_nosway_static;
    level.scr_anim[ "player_rig" ][ "roofhit_jump" ] = %sw_roofhit_player_jump;
    level.scr_anim[ "player_rig" ][ "hangar_intro" ] = %sw_intro_player;
    
    addNotetrack_notify( "player_rig", "player_hit_car", "notify_jump_hit_side" );
    addNotetrack_notify( "player_rig", "player_end_vignette", "notify_player_end_vignette" );
    
    //----------------------------------------------------------------------------------
	//	
	// LOCO BOMB PLACE
	//
	//----------------------------------------------------------------------------------
	level.scr_anim[ "player_rig" ][ "loco_bombplace" ] = %sw_enginecar_bombplace_player;
	
	addNotetrack_notify( "player_rig", "hesh_move", "notify_loco_bombplace_hesh_move" );
    
    //----------------------------------------------------------------------------------
	//	
	// LOCO BREACH
	//
	//----------------------------------------------------------------------------------
	level.scr_anim[ "player_rig" ][ "loco_breach" ] = %sw_enginecar_breach_player;
	level.scr_anim[ "player_rig" ][ "loco_standoff" ] = %sw_enginecar_standoff_player;
	
	addNotetrack_notify( "player_rig", "slomo_start", "notify_loco_breach_slowmo_start" );
	addNotetrack_notify( "player_rig", "slomo_end", "notify_loco_breach_slowmo_end" );
	addNotetrack_notify( "player_rig", "door_explode", "notify_loco_breach_door_explode" );
	addNotetrack_customFunction( "player_rig", "player_shot", ::loco_breach_player_shot );
	addNotetrack_customFunction( "player_rig", "player_punched", ::loco_breach_player_punched );
}

#using_animtree( "generic_human" );
generic_human_anims()
{
	// hangar intro	
	level.scr_anim[ "ally1"			   ] [ "hangar_intro" ] = %sw_intro_hesh;
	level.scr_anim[ "enemy_hangar_1"   ] [ "hangar_intro" ] = %sw_intro_enemy_01;
	level.scr_anim[ "enemy_hangar_2"   ] [ "hangar_intro" ] = %sw_intro_enemy_02;
	level.scr_anim[ "boss"			   ] [ "hangar_intro" ] = %sw_intro_rorke;
	level.scr_anim[ "enemy_hangar_pip" ] [ "hangar_intro" ] = %sw_intro_security;
	
	// hatch infil
	level.scr_anim[ "sw_hatch_opfor" ][ "sw_entry_f" ] = %sw_hatchexit_op_f_01;
	
	// ladder infil
	level.scr_anim[ "sw_door_r_opfor" ][ "sw_entry_u" ] = %sw_rooftop_ladder_infils_DR_S;
	level.scr_anim[ "sw_door_l_opfor" ][ "sw_entry_u" ] = %sw_rooftop_ladder_infils_DL_S;
	level.scr_anim[ "sw_door_r_opfor" ][ "sw_entry_l" ] = %sw_rooftop_ladder_infils_DR_CL;
	level.scr_anim[ "sw_door_l_opfor" ][ "sw_entry_l" ] = %sw_rooftop_ladder_infils_DL_CL;
	level.scr_anim[ "sw_door_r_opfor" ][ "sw_entry_r" ] = %sw_rooftop_ladder_infils_DR_CR;
	level.scr_anim[ "sw_door_l_opfor" ][ "sw_entry_r" ] = %sw_rooftop_ladder_infils_DL_CR;
		
	// Rooftops	
	level.scr_anim[ "ally1" ][ "roofhit_jump" ] = %sw_roofhit_hesh_jump;
	level.scr_anim[ "ally1" ][ "roofhit_land" ] = %sw_roofhit_hesh_land;
	level.scr_anim[ "ally1" ][ "roofhit_pullup" ] = %sw_roofhit_hesh_pullup;
	
	//----------------------------------------------------------------------------------
	//	
	// LOCO BOMB PLACE
	//
	//----------------------------------------------------------------------------------
	level.scr_anim[ "ally1" ][ "loco_bombplace_1" ] = %sw_enginecar_bombplace1_hesh;
	level.scr_anim[ "ally1" ][ "loco_bombplace_2" ] = %sw_enginecar_bombplace2_hesh;
	
	//----------------------------------------------------------------------------------
	//	
	// LOCO BREACH
	//
	//----------------------------------------------------------------------------------
	level.scr_anim[ "ally1" ][ "loco_breach" ] = %sw_enginecar_breach_hesh;
	level.scr_anim[ "vargas" ][ "loco_breach" ] = %sw_enginecar_breach_vargas;
	level.scr_anim[ "opfor1" ][ "loco_breach" ] = %sw_enginecar_breach_opfor1;
	level.scr_anim[ "opfor2" ][ "loco_breach" ] = %sw_enginecar_breach_opfor2;
	level.scr_anim[ "opfor3" ][ "loco_breach" ] = %sw_enginecar_breach_opfor3;
	level.scr_anim[ "opfor4" ][ "loco_breach" ] = %sw_enginecar_breach_opfor4;
	
	level.scr_anim[ "ally1" ][ "loco_standoff" ] = %sw_enginecar_standoff_hesh;
	level.scr_anim[ "vargas" ][ "loco_standoff" ] = %sw_enginecar_standoff_vargas;
}

#using_animtree( "script_model" );
script_model_anims()
{
	// Hangar Intro
	level.scr_animtree[ "hangar_door"		]				 = #animtree;
	level.scr_animtree[ "hangar_pip_camera" ]				 = #animtree;
	level.scr_animtree[ "hangar_wall"		]				 = #animtree;	
	level.scr_model	  [ "hangar_door"		]				 = "tag_origin";
	level.scr_model	  [ "hangar_pip_camera" ]				 = "tag_origin";
	level.scr_model	  [ "hangar_wall"		]				 = "sw_intro_temp_wall";
	level.scr_anim[ "hangar_door"		] [ "hangar_intro" ] = %sw_intro_slidingdoor;
	level.scr_anim[ "hangar_pip_camera" ] [ "hangar_intro" ] = %sw_intro_camera;
	level.scr_anim[ "hangar_wall"		] [ "hangar_intro" ] = %sw_intro_wall;
	
	// traincar wheels
	level.scr_anim[ "traincar_pass_sus_b" ][ "wheels" ] = %sw_train_wheels;
		
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR PASSENGER
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_passenger_1_body"  ]				 = #animtree;
	level.scr_animtree[ "train_passenger_1_sus_f" ]				 = #animtree;
	level.scr_animtree[ "train_passenger_1_sus_b" ]				 = #animtree;
	level.scr_anim[ "train_passenger_1_body"  ] [ "bb_1"	   ] = %sw_bb_1_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "bb_2"	   ] = %sw_bb_2_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "bc_1"	   ] = %sw_bc_1_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "bc_2"	   ] = %sw_bc_2_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "bc_3"	   ] = %sw_bc_3_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "loop_a1"	   ] = %sw_loopa1_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "loop_a2"	   ] = %sw_loopa2_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "_a3_1"	   ] = %sw__a3_1_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "_a3_2"	   ] = %sw__a3_2_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "_a3_3"	   ] = %sw__a3_3_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "_a3_4"	   ] = %sw__a3_4_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "sathit_1"   ] = %sw_sathit1_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "sathit_2"   ] = %sw_sathit_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "hangarhit"  ] = %sw_hangerhit_pass2_body;
	level.scr_anim[ "train_passenger_1_body"  ] [ "roofhit"	   ] = %sw_roofhit_pass2_body;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "bb_1"	   ] = %sw_bb_1_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "bb_2"	   ] = %sw_bb_2_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "bc_1"	   ] = %sw_bc_1_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "bc_2"	   ] = %sw_bc_2_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "bc_3"	   ] = %sw_bc_3_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "loop_a1"	   ] = %sw_loopa1_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "loop_a2"	   ] = %sw_loopa2_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "_a3_1"	   ] = %sw__a3_1_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "_a3_2"	   ] = %sw__a3_2_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "_a3_3"	   ] = %sw__a3_3_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "_a3_4"	   ] = %sw__a3_4_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "sathit_1"   ] = %sw_sathit1_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "sathit_2"   ] = %sw_sathit_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "hangarhit"  ] = %sw_hangerhit_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "roofhit"	   ] = %sw_roofhit_pass2_sus_f;
	level.scr_anim[ "train_passenger_1_sus_f" ] [ "wheels"	   ] = %sw_train_wheels;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "bb_1"	   ] = %sw_bb_1_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "bb_2"	   ] = %sw_bb_2_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "bc_1"	   ] = %sw_bc_1_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "bc_2"	   ] = %sw_bc_2_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "bc_3"	   ] = %sw_bc_3_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "loop_a1"	   ] = %sw_loopa1_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "loop_a2"	   ] = %sw_loopa2_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "_a3_1"	   ] = %sw__a3_1_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "_a3_2"	   ] = %sw__a3_2_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "_a3_3"	   ] = %sw__a3_3_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "_a3_4"	   ] = %sw__a3_4_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "sathit_1"   ] = %sw_sathit1_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "sathit_2"   ] = %sw_sathit_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "hangarhit"  ] = %sw_hangerhit_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "roofhit"	   ] = %sw_roofhit_pass2_sus_b;
	level.scr_anim[ "train_passenger_1_sus_b" ] [ "wheels"	   ] = %sw_train_wheels;
		
	// Intro
//	level.scr_animtree[ "train_passenger_curtain" ]						  = #animtree;
//	level.scr_model	  [ "train_passenger_curtain" ]						  = "sw_intro_cloth";
//	level.scr_anim[ "train_passenger_curtain" ][ "pass_intro_start" ]	  = %sw_intro_cloth_01;
//	level.scr_anim[ "train_passenger_curtain" ][ "pass_intro_idle" ][ 0 ] = %sw_intro_cloth_01_idle;
//	level.scr_anim[ "train_passenger_curtain" ][ "pass_intro_end" ]		  = %sw_intro_cloth_01_end;
	
	
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR HANGAR
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_hangar_body"	 ]			   = #animtree;
	level.scr_animtree[ "train_hangar_sus_f" ]			   = #animtree;
	level.scr_animtree[ "train_hangar_sus_b" ]			   = #animtree;
	level.scr_anim[ "train_hangar_body"	 ] [ "bb_1"		 ] = %sw_bb_1_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "bb_2"		 ] = %sw_bb_2_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "bc_1"		 ] = %sw_bc_1_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "bc_2"		 ] = %sw_bc_2_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "bc_3"		 ] = %sw_bc_3_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "loop_a1"	 ] = %sw_loopa1_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "loop_a2"	 ] = %sw_loopa2_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "ab_1"	 ] = %sw_ab1_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "ab_2"	 ] = %sw_ab2_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "_a3_1"	 ] = %sw__a3_1_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "_a3_2"	 ] = %sw__a3_2_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "_a3_3"	 ] = %sw__a3_3_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "_a3_4"	 ] = %sw__a3_4_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "sathit_1"	 ] = %sw_sathit1_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "sathit_2"	 ] = %sw_sathit_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "hangarhit" ] = %sw_hangerhit_hang_body;
	level.scr_anim[ "train_hangar_body"	 ] [ "roofhit"	 ] = %sw_roofhit_hang_body;
	level.scr_anim[ "train_hangar_sus_f" ] [ "bb_1"		 ] = %sw_bb_1_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "bb_2"		 ] = %sw_bb_2_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "bc_1"		 ] = %sw_bc_1_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "bc_2"		 ] = %sw_bc_2_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "bc_3"		 ] = %sw_bc_3_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "loop_a1"	 ] = %sw_loopa1_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "loop_a2"	 ] = %sw_loopa2_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "ab_1"	 ] = %sw_ab1_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "ab_2"	 ] = %sw_ab2_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "_a3_1"	 ] = %sw__a3_1_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "_a3_2"	 ] = %sw__a3_2_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "_a3_3"	 ] = %sw__a3_3_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "_a3_4"	 ] = %sw__a3_4_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "sathit_1"	 ] = %sw_sathit1_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "sathit_2"	 ] = %sw_sathit_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "hangarhit" ] = %sw_hangerhit_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "roofhit"	 ] = %sw_roofhit_hang_sus_f;
	level.scr_anim[ "train_hangar_sus_f" ] [ "wheels"	 ] = %sw_loco_wheels;
	level.scr_anim[ "train_hangar_sus_b" ] [ "bb_1"		 ] = %sw_bb_1_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "bb_2"		 ] = %sw_bb_2_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "bc_1"		 ] = %sw_bc_1_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "bc_2"		 ] = %sw_bc_2_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "bc_3"		 ] = %sw_bc_3_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "loop_a1"	 ] = %sw_loopa1_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "loop_a2"	 ] = %sw_loopa2_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "ab_1"	 ] = %sw_ab1_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "ab_2"	 ] = %sw_ab2_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "_a3_1"	 ] = %sw__a3_1_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "_a3_2"	 ] = %sw__a3_2_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "_a3_3"	 ] = %sw__a3_3_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "_a3_4"	 ] = %sw__a3_4_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "sathit_1"	 ] = %sw_sathit1_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "sathit_2"	 ] = %sw_sathit_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "hangarhit" ] = %sw_hangerhit_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "roofhit"	 ] = %sw_roofhit_hang_sus_b;
	level.scr_anim[ "train_hangar_sus_b" ] [ "wheels"	 ] = %sw_loco_wheels;
	
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR SAT 1
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_sat_1_body"	]			   = #animtree;
	level.scr_animtree[ "train_sat_1_sus_f" ]			   = #animtree;
	level.scr_animtree[ "train_sat_1_sus_b" ]			   = #animtree;
	level.scr_anim[ "train_sat_1_body"	] [ "bb_1"	     ] = %sw_bb_1_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "bb_2"	     ] = %sw_bb_2_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "bc_1"		 ] = %sw_bc_1_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "bc_2"		 ] = %sw_bc_2_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "bc_3"		 ] = %sw_bc_3_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "loop_a1"	 ] = %sw_loopa1_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "loop_a2"	 ] = %sw_loopa2_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "ab_1"	 ] = %sw_ab1_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "ab_2"	 ] = %sw_ab2_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "_a3_1"		 ] = %sw__a3_1_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "_a3_2"		 ] = %sw__a3_2_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "_a3_3"		 ] = %sw__a3_3_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "_a3_4"		 ] = %sw__a3_4_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "sathit_1"	 ] = %sw_sathit1_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "sathit_2"	 ] = %sw_sathit_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "hangarhit"  ] = %sw_hangerhit_satb_body;
	level.scr_anim[ "train_sat_1_body"	] [ "roofhit"	 ] = %sw_roofhit_satb_body;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "bb_1"	     ] = %sw_bb_1_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "bb_2"	     ] = %sw_bb_2_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "bc_1"		 ] = %sw_bc_1_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "bc_2"		 ] = %sw_bc_2_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "bc_3"		 ] = %sw_bc_3_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "loop_a1"	 ] = %sw_loopa1_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "loop_a2"	 ] = %sw_loopa2_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "ab_1"	 ] = %sw_ab1_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "ab_2"	 ] = %sw_ab2_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "_a3_1"		 ] = %sw__a3_1_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "_a3_2"		 ] = %sw__a3_2_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "_a3_3"		 ] = %sw__a3_3_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "_a3_4"		 ] = %sw__a3_4_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "sathit_1"	 ] = %sw_sathit1_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "sathit_2"	 ] = %sw_sathit_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "hangarhit"  ] = %sw_hangerhit_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "roofhit"	 ] = %sw_roofhit_satb_sus_f;
	level.scr_anim[ "train_sat_1_sus_f" ] [ "wheels"	 ] = %sw_loco_wheels;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "bb_1"	     ] = %sw_bb_1_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "bb_2"	     ] = %sw_bb_2_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "bc_1"		 ] = %sw_bc_1_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "bc_2"		 ] = %sw_bc_2_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "bc_3"		 ] = %sw_bc_3_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "loop_a1"	 ] = %sw_loopa1_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "loop_a2"	 ] = %sw_loopa2_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "ab_1"	 ] = %sw_ab1_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "ab_2"	 ] = %sw_ab2_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "_a3_1"		 ] = %sw__a3_1_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "_a3_2"		 ] = %sw__a3_2_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "_a3_3"		 ] = %sw__a3_3_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "_a3_4"		 ] = %sw__a3_4_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "sathit_1"	 ] = %sw_sathit1_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "sathit_2"	 ] = %sw_sathit_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "hangarhit"  ] = %sw_hangerhit_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "roofhit"	 ] = %sw_roofhit_satb_sus_b;
	level.scr_anim[ "train_sat_1_sus_b" ] [ "wheels"	 ] = %sw_loco_wheels;
	
	// little satellites
	level.scr_animtree[ "model_sat_1_satellite_1" ]			= #animtree;
	level.scr_anim[ "model_sat_1_satellite_1" ] [ "sway"	  ] = %sw_sway_satb_sat_1;
	level.scr_anim[ "model_sat_1_satellite_1" ] [ "sathit_1" ] = %sw_sathit1_satb_sat_1;
	
	level.scr_animtree[ "model_sat_1_satellite_2" ]			= #animtree;
	level.scr_anim[ "model_sat_1_satellite_2" ] [ "sway"	  ] = %sw_sway_satb_sat_2;
	level.scr_anim[ "model_sat_1_satellite_2" ] [ "sathit_1" ] = %sw_sathit1_satb_sat_2;
	
	level.scr_animtree[ "model_sat_1_satellite_3" ]			= #animtree;
	level.scr_anim[ "model_sat_1_satellite_3" ] [ "sway"	  ] = %sw_sway_satb_sat_3;
	level.scr_anim[ "model_sat_1_satellite_3" ] [ "sathit_1" ] = %sw_sathit1_satb_sat_3;
	
	level.scr_animtree[ "model_sat_1_satellite_4" ]			= #animtree;
	level.scr_anim[ "model_sat_1_satellite_4" ] [ "sway"	  ] = %sw_sway_satb_sat_4;
	level.scr_anim[ "model_sat_1_satellite_4" ] [ "sathit_1" ] = %sw_sathit1_satb_sat_4;
	
	level.scr_animtree[ "model_sat_1_satellite_5" ]			= #animtree;
	level.scr_anim[ "model_sat_1_satellite_5" ] [ "sway"	  ] = %sw_sway_satb_sat_5;
	level.scr_anim[ "model_sat_1_satellite_5" ] [ "sathit_1" ] = %sw_sathit1_satb_sat_5;
	
	level.scr_animtree[ "model_sat_1_satellite_6" ]			= #animtree;
	level.scr_anim[ "model_sat_1_satellite_6" ] [ "sway"	  ] = %sw_sway_satb_sat_6;
	level.scr_anim[ "model_sat_1_satellite_6" ] [ "sathit_1" ] = %sw_sathit1_satb_sat_6;
	
	level.scr_animtree[ "model_sat_1_satellite_7" ]			= #animtree;
	level.scr_anim[ "model_sat_1_satellite_7" ] [ "sway"	  ] = %sw_sway_satb_sat_7;
	level.scr_anim[ "model_sat_1_satellite_7" ] [ "sathit_1" ] = %sw_sathit1_satb_sat_7;
	
	
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR ROOFTOPS 1
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_rt1_body"  ]				 = #animtree;
	level.scr_animtree[ "train_rt1_sus_f" ]				 = #animtree;
	level.scr_animtree[ "train_rt1_sus_b" ]				 = #animtree;
	level.scr_anim[ "train_rt1_body"  ] [ "bb_1"	   ] = %sw_bb_1_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "bb_2"	   ] = %sw_bb_2_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "bc_1"	   ] = %sw_bc_1_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "bc_2"	   ] = %sw_bc_2_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "bc_3"	   ] = %sw_bc_3_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "loop_a1"	   ] = %sw_loopa1_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "loop_a2"	   ] = %sw_loopa2_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "ab_1"	   ] = %sw_ab1_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "ab_2"	   ] = %sw_ab2_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "_a3_1"	   ] = %sw__a3_1_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "_a3_2"	   ] = %sw__a3_2_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "_a3_3"	   ] = %sw__a3_3_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "_a3_4"	   ] = %sw__a3_4_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "sathit_1"   ] = %sw_sathit1_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "sathit_2"   ] = %sw_sathit_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "hangarhit"  ] = %sw_hangerhit_pass3_body;
	level.scr_anim[ "train_rt1_body"  ] [ "roofhit"	   ] = %sw_roofhit_pass3_body;
	level.scr_anim[ "train_rt1_sus_f" ] [ "bb_1"	   ] = %sw_bb_1_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "bb_2"	   ] = %sw_bb_2_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "bc_1"	   ] = %sw_bc_1_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "bc_2"	   ] = %sw_bc_2_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "bc_3"	   ] = %sw_bc_3_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "loop_a1"	   ] = %sw_loopa1_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "loop_a2"	   ] = %sw_loopa2_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "ab_1"	   ] = %sw_ab1_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "ab_2"	   ] = %sw_ab2_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "_a3_1"	   ] = %sw__a3_1_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "_a3_2"	   ] = %sw__a3_2_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "_a3_3"	   ] = %sw__a3_3_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "_a3_4"	   ] = %sw__a3_4_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "sathit_1"   ] = %sw_sathit1_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "sathit_2"   ] = %sw_sathit_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "hangarhit"  ] = %sw_hangerhit_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "roofhit"	   ] = %sw_roofhit_pass3_sus_f;
	level.scr_anim[ "train_rt1_sus_f" ] [ "wheels"	   ] = %sw_train_wheels;
	level.scr_anim[ "train_rt1_sus_b" ] [ "bb_1"	   ] = %sw_bb_1_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "bb_2"	   ] = %sw_bb_2_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "bc_1"	   ] = %sw_bc_1_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "bc_2"	   ] = %sw_bc_2_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "bc_3"	   ] = %sw_bc_3_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "loop_a1"	   ] = %sw_loopa1_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "loop_a2"	   ] = %sw_loopa2_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "ab_1"	   ] = %sw_ab1_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "ab_2"	   ] = %sw_ab2_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "_a3_1"	   ] = %sw__a3_1_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "_a3_2"	   ] = %sw__a3_2_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "_a3_3"	   ] = %sw__a3_3_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "_a3_4"	   ] = %sw__a3_4_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "sathit_1"   ] = %sw_sathit1_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "sathit_2"   ] = %sw_sathit_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "hangarhit"  ] = %sw_hangerhit_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "roofhit"	   ] = %sw_roofhit_pass3_sus_b;
	level.scr_anim[ "train_rt1_sus_b" ] [ "wheels"	   ] = %sw_train_wheels;
	
	
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR ROOFTOPS 2
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_rt2_body"  ]				 = #animtree;
	level.scr_animtree[ "train_rt2_sus_f" ]				 = #animtree;
	level.scr_animtree[ "train_rt2_sus_b" ]				 = #animtree;
	level.scr_anim[ "train_rt2_body"  ] [ "bb_1"	   ] = %sw_bb_1_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "bb_2"	   ] = %sw_bb_2_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "bc_1"	   ] = %sw_bc_1_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "bc_2"	   ] = %sw_bc_2_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "bc_3"	   ] = %sw_bc_3_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "loop_a1"	   ] = %sw_loopa1_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "loop_a2"	   ] = %sw_loopa2_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "ab_1"	   ] = %sw_ab1_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "ab_2"	   ] = %sw_ab2_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "_a3_1"	   ] = %sw__a3_1_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "_a3_2"	   ] = %sw__a3_2_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "_a3_3"	   ] = %sw__a3_3_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "_a3_4"	   ] = %sw__a3_4_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "sathit_1"   ] = %sw_sathit1_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "sathit_2"   ] = %sw_sathit_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "hangarhit"  ] = %sw_hangerhit_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "roofhit"	   ] = %sw_roofhit_pass4_body;
	level.scr_anim[ "train_rt2_sus_f" ] [ "bb_1"	   ] = %sw_bb_1_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "bb_2"	   ] = %sw_bb_2_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "bc_1"	   ] = %sw_bc_1_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "bc_2"	   ] = %sw_bc_2_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "bc_3"	   ] = %sw_bc_3_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "loop_a1"	   ] = %sw_loopa1_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "loop_a2"	   ] = %sw_loopa2_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "ab_1"	   ] = %sw_ab1_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "ab_2"	   ] = %sw_ab2_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "_a3_1"	   ] = %sw__a3_1_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "_a3_2"	   ] = %sw__a3_2_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "_a3_3"	   ] = %sw__a3_3_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "_a3_4"	   ] = %sw__a3_4_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "sathit_1"   ] = %sw_sathit1_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "sathit_2"   ] = %sw_sathit_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "hangarhit"  ] = %sw_hangerhit_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "roofhit"	   ] = %sw_roofhit_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "wheels"	   ] = %sw_train_wheels;
	level.scr_anim[ "train_rt2_sus_b" ] [ "bb_1"	   ] = %sw_bb_1_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "bb_2"	   ] = %sw_bb_2_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "bc_1"	   ] = %sw_bc_1_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "bc_2"	   ] = %sw_bc_2_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "bc_3"	   ] = %sw_bc_3_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "loop_a1"	   ] = %sw_loopa1_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "loop_a2"	   ] = %sw_loopa2_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "ab_1"	   ] = %sw_ab1_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "ab_2"	   ] = %sw_ab2_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "_a3_1"	   ] = %sw__a3_1_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "_a3_2"	   ] = %sw__a3_2_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "_a3_3"	   ] = %sw__a3_3_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "_a3_4"	   ] = %sw__a3_4_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "sathit_1"   ] = %sw_sathit1_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "sathit_2"   ] = %sw_sathit_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "hangarhit"  ] = %sw_hangerhit_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "roofhit"	   ] = %sw_roofhit_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "wheels"	   ] = %sw_train_wheels;
	
	level.scr_anim[ "train_rt2_body"  ] [ "roofhit_loop"  ] = %sw_roofhit_loop_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "roofhit_shift" ] = %sw_roofhit_shift_pass4_body;
	level.scr_anim[ "train_rt2_body"  ] [ "roofhit_fall"  ] = %sw_roofhit_fall_pass4_body;
	level.scr_anim[ "train_rt2_sus_f" ] [ "roofhit_loop"  ] = %sw_roofhit_loop_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "roofhit_shift" ] = %sw_roofhit_shift_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_f" ] [ "roofhit_fall"  ] = %sw_roofhit_fall_pass4_sus_f;
	level.scr_anim[ "train_rt2_sus_b" ] [ "roofhit_loop"  ] = %sw_roofhit_loop_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "roofhit_shift" ] = %sw_roofhit_loop_pass4_sus_b;
	level.scr_anim[ "train_rt2_sus_b" ] [ "roofhit_fall"  ] = %sw_roofhit_fall_pass4_sus_b;
	
	level.scr_anim[ "train_rt2_sus_f" ][ "roofhit_helodamage" ]  = %sw_roofhit_helodamage_pass4_sus_f;
	
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR ROOFTOPS 3
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_rt3_body"  ]				 = #animtree;
	level.scr_animtree[ "train_rt3_sus_f" ]				 = #animtree;
	level.scr_animtree[ "train_rt3_sus_b" ]				 = #animtree;
	level.scr_anim[ "train_rt3_body"  ] [ "bb_1"	   ] = %sw_bb_1_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "bb_2"	   ] = %sw_bb_2_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "bc_1"	   ] = %sw_bc_1_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "bc_2"	   ] = %sw_bc_2_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "bc_3"	   ] = %sw_bc_3_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "loop_a1"	   ] = %sw_loopa1_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "loop_a2"	   ] = %sw_loopa2_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "ab_1"	   ] = %sw_ab1_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "ab_2"	   ] = %sw_ab2_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "_a3_1"	   ] = %sw__a3_1_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "_a3_2"	   ] = %sw__a3_2_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "_a3_3"	   ] = %sw__a3_3_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "_a3_4"	   ] = %sw__a3_4_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "sathit_1"   ] = %sw_sathit1_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "sathit_2"   ] = %sw_sathit_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "hangarhit"  ] = %sw_hangerhit_pass5_body;
	level.scr_anim[ "train_rt3_body"  ] [ "roofhit"	   ] = %sw_roofhit_pass5_body;
	level.scr_anim[ "train_rt3_sus_f" ] [ "bb_1"	   ] = %sw_bb_1_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "bb_2"	   ] = %sw_bb_2_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "bc_1"	   ] = %sw_bc_1_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "bc_2"	   ] = %sw_bc_2_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "bc_3"	   ] = %sw_bc_3_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "loop_a1"	   ] = %sw_loopa1_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "loop_a2"	   ] = %sw_loopa2_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "ab_1"	   ] = %sw_ab1_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "ab_2"	   ] = %sw_ab2_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "_a3_1"	   ] = %sw__a3_1_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "_a3_2"	   ] = %sw__a3_2_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "_a3_3"	   ] = %sw__a3_3_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "_a3_4"	   ] = %sw__a3_4_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "sathit_1"   ] = %sw_sathit1_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "sathit_2"   ] = %sw_sathit_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "hangarhit"  ] = %sw_hangerhit_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "roofhit"	   ] = %sw_roofhit_pass5_sus_f;
	level.scr_anim[ "train_rt3_sus_f" ] [ "wheels"	   ] = %sw_train_wheels;
	level.scr_anim[ "train_rt3_sus_b" ] [ "bb_1"	   ] = %sw_bb_1_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "bb_2"	   ] = %sw_bb_2_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "bc_1"	   ] = %sw_bc_1_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "bc_2"	   ] = %sw_bc_2_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "bc_3"	   ] = %sw_bc_3_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "loop_a1"	   ] = %sw_loopa1_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "loop_a2"	   ] = %sw_loopa2_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "ab_1"	   ] = %sw_ab1_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "ab_2"	   ] = %sw_ab2_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "_a3_1"	   ] = %sw__a3_1_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "_a3_2"	   ] = %sw__a3_2_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "_a3_3"	   ] = %sw__a3_3_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "_a3_4"	   ] = %sw__a3_4_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "sathit_1"   ] = %sw_sathit1_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "sathit_2"   ] = %sw_sathit_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "hangarhit"  ] = %sw_hangerhit_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "roofhit"	   ] = %sw_roofhit_pass5_sus_b;
	level.scr_anim[ "train_rt3_sus_b" ] [ "wheels"	   ] = %sw_train_wheels;
	addNotetrack_notify( "train_rt3_body", "allow_teleport", "player_train_new_anim" );
	addNotetrack_notify( "train_rt3_body", "break_sus_l", "notify_break_sus_l", "_a3_1" );
	addNotetrack_notify( "train_rt3_body", "break_sus_r", "notify_break_sus_r", "_a3_1" );
	addNotetrack_notify( "train_rt3_body", "scrape_wall", "notify_train_scrape_Wall", "_a3_1" );
	addNotetrack_notify( "train_rt3_body", "stop_scrape_wall", "notify_train_stop_scrape_Wall", "_a3_1" );
	addNotetrack_notify( "train_rt3_body", "hit_wall", "notify_train_hit_Wall", "_a3_1" );
	
	
	
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR ROOFTOPS 4
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_rt4_body"  ]				 = #animtree;
	level.scr_animtree[ "train_rt4_sus_f" ]				 = #animtree;
	level.scr_animtree[ "train_rt4_sus_b" ]				 = #animtree;
	level.scr_anim[ "train_rt4_body"  ] [ "bb_1"	   ] = %sw_bb_1_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "bb_2"	   ] = %sw_bb_2_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "bc_1"	   ] = %sw_bc_1_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "bc_2"	   ] = %sw_bc_2_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "bc_3"	   ] = %sw_bc_3_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "loop_a1"	   ] = %sw_loopa1_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "loop_a2"	   ] = %sw_loopa2_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "ab_1"	   ] = %sw_ab1_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "ab_2"	   ] = %sw_ab2_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "_a3_1"	   ] = %sw__a3_1_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "_a3_2"	   ] = %sw__a3_2_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "_a3_3"	   ] = %sw__a3_3_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "_a3_4"	   ] = %sw__a3_4_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "sathit_1"   ] = %sw_sathit1_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "sathit_2"   ] = %sw_sathit_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "hangarhit"  ] = %sw_hangerhit_pass6_body;
	level.scr_anim[ "train_rt4_body"  ] [ "roofhit"	   ] = %sw_roofhit_pass6_body;
	level.scr_anim[ "train_rt4_sus_f" ] [ "bb_1"	   ] = %sw_bb_1_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "bb_2"	   ] = %sw_bb_2_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "bc_1"	   ] = %sw_bc_1_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "bc_2"	   ] = %sw_bc_2_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "bc_3"	   ] = %sw_bc_3_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "loop_a1"	   ] = %sw_loopa1_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "loop_a2"	   ] = %sw_loopa2_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "ab_1"	   ] = %sw_ab1_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "ab_2"	   ] = %sw_ab2_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "_a3_1"	   ] = %sw__a3_1_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "_a3_2"	   ] = %sw__a3_2_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "_a3_3"	   ] = %sw__a3_3_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "_a3_4"	   ] = %sw__a3_4_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "sathit_1"   ] = %sw_sathit1_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "sathit_2"   ] = %sw_sathit_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "hangarhit"  ] = %sw_hangerhit_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "roofhit"	   ] = %sw_roofhit_pass6_sus_f;
	level.scr_anim[ "train_rt4_sus_f" ] [ "wheels"	   ] = %sw_train_wheels;
	level.scr_anim[ "train_rt4_sus_b" ] [ "bb_1"	   ] = %sw_bb_1_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "bb_2"	   ] = %sw_bb_2_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "bc_1"	   ] = %sw_bc_1_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "bc_2"	   ] = %sw_bc_2_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "bc_3"	   ] = %sw_bc_3_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "loop_a1"	   ] = %sw_loopa1_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "loop_a2"	   ] = %sw_loopa2_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "ab_1"	   ] = %sw_ab1_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "ab_2"	   ] = %sw_ab2_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "_a3_1"	   ] = %sw__a3_1_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "_a3_2"	   ] = %sw__a3_2_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "_a3_3"	   ] = %sw__a3_3_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "_a3_4"	   ] = %sw__a3_4_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "sathit_1"   ] = %sw_sathit1_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "sathit_2"   ] = %sw_sathit_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "hangarhit"  ] = %sw_hangerhit_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "roofhit"	   ] = %sw_roofhit_pass6_sus_b;
	level.scr_anim[ "train_rt4_sus_b" ] [ "wheels"	   ] = %sw_train_wheels;
	
		
	//----------------------------------------------------------------------------------
	//	
	// TRAINCAR LOCOMOTIVE
	//
	//----------------------------------------------------------------------------------
	level.scr_animtree[ "train_loco_body"  ]				 = #animtree;
	level.scr_animtree[ "train_loco_sus_f" ]				 = #animtree;
	level.scr_animtree[ "train_loco_sus_b" ]				 = #animtree;
	level.scr_anim[ "train_loco_body"  ] [ "bb_1"	   ] = %sw_bb_1_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "bb_2"	   ] = %sw_bb_2_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "bc_1"	   ] = %sw_bc_1_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "bc_2"	   ] = %sw_bc_2_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "bc_3"	   ] = %sw_bc_3_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "loop_a1"	   ] = %sw_loopa1_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "loop_a2"	   ] = %sw_loopa2_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "ab_1"	   ] = %sw_ab1_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "ab_2"	   ] = %sw_ab2_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "_a3_1"	   ] = %sw__a3_1_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "_a3_2"	   ] = %sw__a3_2_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "_a3_3"	   ] = %sw__a3_3_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "_a3_4"	   ] = %sw__a3_4_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "ending_fall"	   ] = %sw__a3_4_loco_body;
	level.scr_anim[ "train_loco_body"  ] [ "sathit_1"   ] = %sw_sathit1_pass6_body;
	level.scr_anim[ "train_loco_body"  ] [ "sathit_2"   ] = %sw_sathit_pass6_body;
	level.scr_anim[ "train_loco_body"  ] [ "hangarhit"  ] = %sw_hangerhit_pass6_body;
	level.scr_anim[ "train_loco_body"  ] [ "roofhit"	   ] = %sw_roofhit_pass6_body;
	level.scr_anim[ "train_loco_sus_f" ] [ "bb_1"	   ] = %sw_bb_1_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "bb_2"	   ] = %sw_bb_2_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "bc_1"	   ] = %sw_bc_1_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "bc_2"	   ] = %sw_bc_2_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "bc_3"	   ] = %sw_bc_3_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "loop_a1"	   ] = %sw_loopa1_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "loop_a2"	   ] = %sw_loopa2_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "ab_1"	   ] = %sw_ab1_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "ab_2"	   ] = %sw_ab2_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "_a3_1"	   ] = %sw__a3_1_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "_a3_2"	   ] = %sw__a3_2_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "_a3_3"	   ] = %sw__a3_3_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "_a3_4"	   ] = %sw__a3_4_loco_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "sathit_1"   ] = %sw_sathit1_pass6_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "sathit_2"   ] = %sw_sathit_pass6_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "hangarhit"  ] = %sw_hangerhit_pass6_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "roofhit"	   ] = %sw_roofhit_pass6_sus_f;
	level.scr_anim[ "train_loco_sus_f" ] [ "wheels"	   ] = %sw_loco_wheels;
	level.scr_anim[ "train_loco_sus_b" ] [ "bb_1"	   ] = %sw_bb_1_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "bb_2"	   ] = %sw_bb_2_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "bc_1"	   ] = %sw_bc_1_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "bc_2"	   ] = %sw_bc_2_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "bc_3"	   ] = %sw_bc_3_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "loop_a1"	   ] = %sw_loopa1_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "loop_a2"	   ] = %sw_loopa2_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "ab_1"	   ] = %sw_ab1_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "ab_2"	   ] = %sw_ab2_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "_a3_1"	   ] = %sw__a3_1_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "_a3_2"	   ] = %sw__a3_2_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "_a3_3"	   ] = %sw__a3_3_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "_a3_4"	   ] = %sw__a3_4_loco_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "sathit_1"   ] = %sw_sathit1_pass6_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "sathit_2"   ] = %sw_sathit_pass6_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "hangarhit"  ] = %sw_hangerhit_pass6_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "roofhit"	   ] = %sw_roofhit_pass6_sus_b;
	level.scr_anim[ "train_loco_sus_b" ] [ "wheels"	   ] = %sw_loco_wheels;
	
	//----------------------------------------------------------------------------------
	//	
	// EVENT ANIMS
	//
	//----------------------------------------------------------------------------------
	
	// hangar rog hit
	level.scr_animtree[ "hangar_hatch"	]				= #animtree;
	level.scr_animtree[ "hangar_crane"	]				= #animtree;
	level.scr_animtree[ "hangar_tank_1" ]				= #animtree;
	level.scr_animtree[ "hangar_car_1"	]				= #animtree;
	level.scr_animtree[ "hangar_car_2"	]				= #animtree;
	level.scr_animtree[ "hangar_car_3"	]				= #animtree;
	level.scr_animtree[ "hangar_car_4"	]				= #animtree;
	level.scr_animtree[ "hangar_car_5"	]				= #animtree;
	level.scr_animtree[ "hangar_car_6"	]				= #animtree;
	level.scr_animtree[ "hangar_car_7"	]				= #animtree;
	level.scr_animtree[ "hangar_car_8"	]				= #animtree;
	level.scr_model	  [ "hangar_hatch"	]				= "sw_hangercar_floordoor";
	level.scr_model	  [ "hangar_crane"	]				= "factory_assembly_moving_front_piece";
	level.scr_model	  [ "hangar_tank_1" ]				= "vehicle_battletank";
	level.scr_model	  [ "hangar_car_1"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_model	  [ "hangar_car_2"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_model	  [ "hangar_car_3"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_model	  [ "hangar_car_4"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_model	  [ "hangar_car_5"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_model	  [ "hangar_car_6"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_model	  [ "hangar_car_7"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_model	  [ "hangar_car_8"	]				= "vehicle_iveco_lynx_iw6";
	level.scr_anim[ "hangar_hatch"	 ] [ "hangar_hit" ] = %sw_hanger_rod_floordoor;
	level.scr_anim[ "hangar_crane"	 ] [ "hangar_hit" ] = %sw_hanger_rod_crane_01;
	level.scr_anim[ "hangar_tank_1"	 ] [ "hangar_hit" ] = %sw_hanger_rod_tank_01;
	level.scr_anim[ "hangar_car_1"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_01;
	level.scr_anim[ "hangar_car_2"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_02;
	level.scr_anim[ "hangar_car_3"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_03;
	level.scr_anim[ "hangar_car_4"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_04;
	level.scr_anim[ "hangar_car_5"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_05;
	level.scr_anim[ "hangar_car_6"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_06;
	level.scr_anim[ "hangar_car_7"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_07;
	level.scr_anim[ "hangar_car_8"	 ] [ "hangar_hit" ] = %sw_hanger_rod_car_08;
	
	// hatch infil
	level.scr_animtree[ "sw_hatch" ]			 = #animtree;
	level.scr_model	  [ "sw_hatch" ]			 = "sw_hatch_01";
	level.scr_anim[ "sw_hatch" ][ "sw_entry_f" ] = %sw_hatchexit_hatch_f_01;
	
	// ladder infil
	level.scr_animtree[ "sw_door_r" ]			   = #animtree;
	level.scr_animtree[ "sw_door_l" ]			   = #animtree;
	level.scr_model	  [ "sw_door_r" ]			   = "cnd_exit_door_right";
	level.scr_model	  [ "sw_door_l" ]			   = "cnd_exit_door_right";
	level.scr_anim[ "sw_door_r" ] [ "sw_entry_u" ] = %sw_rooftop_ladder_infils_door_DR_S;
	level.scr_anim[ "sw_door_l" ] [ "sw_entry_u" ] = %sw_rooftop_ladder_infils_door_DL_S;
	level.scr_anim[ "sw_door_r" ] [ "sw_entry_l" ] = %sw_rooftop_ladder_infils_door_DR_CL;
	level.scr_anim[ "sw_door_l" ] [ "sw_entry_l" ] = %sw_rooftop_ladder_infils_door_DL_CL;
	level.scr_anim[ "sw_door_r" ] [ "sw_entry_r" ] = %sw_rooftop_ladder_infils_door_DR_CR;
	level.scr_anim[ "sw_door_l" ] [ "sw_entry_r" ] = %sw_rooftop_ladder_infils_door_DL_CR;
	
	// helo rooftops
	level.scr_animtree[ "rt_helo" ] = #animtree;
	level.scr_model	  [ "rt_helo" ] = "vehicle_nh90";
	
	
	//small helo rooftops
	level.scr_animtree[ "rt_helo_small" ] = #animtree;
	level.scr_model	  [ "rt_helo_small" ] = "vehicle_aas_72x";
	level.scr_anim[ "rt_helo_small" ][ "roofhit" ] = %sw_roofhit_helo_1;
	level.scr_anim[ "rt_helo_small" ][ "roofhit_flyin" ] = %sw_roofhit_flyin_helo_1;
	level.scr_anim[ "rt_helo_small" ][ "roofhit_loop" ][0] = %sw_roofhit_loop_helo_1;
	level.scr_anim[ "rt_helo_small" ][ "roofhit_shift" ] = %sw_roofhit_fall_helo_1;
	addNotetrack_notify( "rt_helo_small", "helo_hit_train", "notify_helo_hit_train" );
	
	//----------------------------------------------------------------------------------
	//	
	// LOCO BREACH
	//
	//----------------------------------------------------------------------------------

	

//	level.scr_animtree[ "tag_origin" ]						= #animtree;
//	level.scr_anim[ "tag_origin" ][ "player_sway_static"]	= %sw_player_sway_static;
//	level.scr_anim[ "tag_origin" ][ "player_nosway_static"] = %sw_player_nosway_static;
}

update_train_path_anims( scenario )
{
	switch( scenario )
	{
		case "roofhit":
			level.scr_anim[ "train_rt2_sus_f" ][ "loop_a1" ] = %sw_loopa1_pass4_sus_f_broken;
			level.scr_anim[ "train_rt2_sus_f" ][ "loop_a2" ] = %sw_loopa2_pass4_sus_f_broken;
			break;
	}
}


#using_animtree( "vehicles" );
vehicle_anims()
{
	
}


//----------------------------------------------------------------------------------
//	
// LOCO BREACH
//
//----------------------------------------------------------------------------------
	
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
loco_breach_player_shot( player_rig )
{
	// tagBR< note >: We need something a bit more elegant than this, i.e. animate weapon
	level.player TakeAllWeapons();
	level.player DisableWeapons();
	
	level.player LerpViewAngleClamp( 0.2, 0.0, 0.0, 0, 0, 0, 0 );
	
	level.player ShellShock( "default", 1.5 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
loco_breach_player_punched( player_rig )
{
	level.player DoDamage( 100, level.vargas GetEye(), level.vargas, level.vargas );
	//level.player ShellShock( "default", 1.0 );
}
