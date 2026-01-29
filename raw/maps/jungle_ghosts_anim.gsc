#include maps\_anim;
#include maps\_utility;
#include common_scripts\utility;

#using_animtree("generic_human");
main()
{
	maps\_hand_signals::initHandSignals();
	maps\_patrol_anims::main();

	player_anims();
	generic_human_anims();
	vehicle_anims();
	//model_anims();
	script_model_anims();
	script_model();
}

	
generic_human_anims()
{	
	//intro jumpdown	
	level.scr_anim[ "alpha1" ][ "intro_jumpdown" ] = %jungle_ghost_intro_jumpdown_guy1;
	level.scr_anim[ "alpha2" ][ "intro_jumpdown" ] = %jungle_ghost_intro_jumpdown_guy2;
	
	addNotetrack_customFunction( "victim", "bodyfall large", ::knife_notetrack_death );
	addNotetrack_flag( "killer", "stab", "interupt_end", "knife_takedown" ); //animname notetrack function 		 
							
	addNotetrack_customFunction( "killer"  , "knife_attach", ::attach_knife );
	addNotetrack_customFunction( "killer"  , "knife_detach", ::detach_knife );
	addNotetrack_customFunction( "killer"  , "knife_insert", ::insert_knife );
	
	
	level.scr_anim[ "killer" ][ "trans_to_knifewalk" ] = %stealthkill_cqb_trans_2_walk;
	level.scr_anim[ "killer" ][ "knifewalk"			 ] = %stealthkill_walk;
	level.scr_anim[ "killer" ][ "knifewalk_takedown" ] = %stealthkill_a_1;
	level.scr_anim[ "victim" ][ "knifewalk_takedown" ] = %stealthkill_b_1;
	
//	level.scr_anim[ "alpha1" ][ "takedown_new1" ] = %stealthkill_a_short_1;
//	level.scr_anim[ "alpha2" ][ "takedown_new1" ] = %stealthkill_a_short_1;
//	level.scr_anim[ "victim" ][ "takedown_new1" ] = %stealthkill_b_short_1;

	level.scr_anim[ "generic" ][ "traverse_jumpdown_96"	 ] = %traverse_jumpdown_96;
	level.scr_anim[ "generic" ][ "traverse_jumpdown_130" ] = %traverse_jumpdown_130;
	
	level.scr_anim[ "generic" ][ "active_patrolwalk_gundown" ] = %active_patrolwalk_gundown;
	
	
	//hostage at top of hill
	
	//waterdunk idle as player approaches
	level.scr_anim[ "guard1"   ][ "water_dunk_loop" ][ 0 ] = %jungle_ghost_wf_holdup_enemy1_loop;
	level.scr_anim[ "guard2"   ][ "standing_idle" ][ 0 ] = %so_hijack_execution_standing_idle_terrorist;
	level.scr_anim[ "hostage1" ][ "water_dunk_loop" ][ 0 ] = %jungle_ghost_wf_holdup_hostage1_loop;
	level.scr_anim[ "hostage2" ][ "water_dunk_loop" ][ 0 ] = %jungle_ghost_wf_holdup_hostage2_loop;
	
	//one off push hostage underwater
	level.scr_anim[ "guard1"   ][ "push_underwater" ] = %jungle_ghost_wf_holdup_enemy1_push;	
	level.scr_anim[ "hostage1" ][ "push_underwater" ] = %jungle_ghost_wf_holdup_hostage1_push;
	level.scr_anim[ "hostage2" ][ "push_underwater" ] = %jungle_ghost_wf_holdup_hostage2_push;
	
	level.scr_anim[ "hostage1" ][ "underwater_idle" ][ 0 ] = %jungle_ghost_wf_holdup_hostage1_wateridle;
	
	//guard threatens hotage2 with same fate as 1, this loops untilplayer unties him
	level.scr_anim[ "guard1"   ][ "interrogation" ] = %jungle_ghost_wf_holdup_enemy1_point2hostage2;	
	level.scr_anim[ "hostage2" ][ "interrogation" ][0] = %jungle_ghost_wf_holdup_hostage2_point2hostage2;
	
	//guard gets shot
	level.scr_anim[ "guard1"   ][ "waterfall_death" ] = %jungle_ghost_wf_holdup_enemy1_death;	
	addNotetrack_customFunction( "guard1"  , "scn_jungl_drowned_hostage1_punchface", ::vfx_hostage1_facepunch, "waterfall_death" );
	
	//hostages getup
	level.scr_anim[ "hostage1" ][ "helped_up" ] = %jungle_ghost_wf_holdup_hostage1_helpup;
	level.scr_anim[ "hostage2" ][ "getup" ] = %jungle_ghost_wf_holdup_hostage2_getup;
	level.scr_anim[ "hostage1" ][ "getup" ] = %jungle_ghost_wf_holdup_hostage2_getup;
	
	level.scr_anim[ "alpha1" ][ "helped_up" ] = %jungle_ghost_wf_holdup_friendly_helpup;
	
	//Stream chopper crash 
	level.scr_anim[ "generic" ][ "explo_react1" ] = %blackice_explosionreact1;
	level.scr_anim[ "generic" ][ "explo_react2" ] = %blackice_explosionreact2;
	
	level.scr_anim[ "generic" ][ "ambush_react1" ] = %cqb_stand_react_A;
	level.scr_anim[ "generic" ][ "ambush_react2" ] = %cqb_stand_react_B;
	level.scr_anim[ "generic" ][ "ambush_react3" ] = %cqb_stand_react_C;
	level.scr_anim[ "generic" ][ "ambush_react4" ] = %cqb_stand_react_D;
	level.scr_anim[ "generic" ][ "ambush_react5" ] = %cqb_stand_react_E;
	
	//help-up lookout guys
	level.scr_anim[ "guy1" ][ "helpup_lookout" ] = %jungle_ghost_lookout_helpup_guy1;
	level.scr_anim[ "guy2" ][ "helpup_lookout" ] = %jungle_ghost_lookout_helpup_guy2;
	
	level.scr_anim[ "guy1" ][ "meeting" ] = %jungle_ghost_patrol_meeting_guy1;
	level.scr_anim[ "guy2" ][ "meeting" ] = %jungle_ghost_patrol_meeting_guy2;
	level.scr_anim[ "guy3" ][ "meeting" ] = %jungle_ghost_patrol_meeting_guy3;
	
	level.scr_anim[ "generic" ][ "meeting_idle1" ][0] = %jungle_ghost_patrol_meeting_idle_guy1;
	level.scr_anim[ "generic" ][ "meeting_idle2" ][0] = %jungle_ghost_patrol_meeting_idle_guy2;
	level.scr_anim[ "generic" ][ "meeting_idle3" ][0] = %jungle_ghost_patrol_meeting_idle_guy3;
	
	//guy looking over cliff
	level.scr_anim[ "generic" ][ "cliff_look" ][0] = %jungle_ghost_cliff_looker;
	level.scr_anim[ "generic" ][ "cliff_look_react" ] = %exposed_idle_reactA;
	
	//runway crate carry	
	level.scr_anim[ "crate_guy1" ][ "crate_carry" ] = %africa_militia_carry_crate_guy1;
	level.scr_anim[ "crate_guy2" ][ "crate_carry" ] = %africa_militia_carry_crate_guy2;
	
	//runway casual idle
	level.scr_anim[ "generic" ][ "crowdsniper_civ_crowdidle1" ] = %crowdsniper_civ_crowdidle1;
	level.scr_anim[ "generic" ][ "crowdsniper_civ_crowdidle2" ] = %crowdsniper_civ_crowdidle2;
	level.scr_anim[ "generic" ][ "crowdsniper_civ_crowdidle3" ] = %crowdsniper_civ_crowdidle3;
	
	level.scr_anim[ "generic" ][ "training_pit_stand_idle" ] = %training_pit_stand_idle;
	level.scr_anim[ "generic" ][ "training_intro_foley_idle_1" ] = %training_intro_foley_idle_1;
	level.scr_anim[ "generic" ][ "training_intro_foley_idle_talk_2" ] = %training_intro_foley_idle_talk_2;
	
	level.scr_anim[ "generic" ][ "freerunnerA_jumpacross" ] = %freerunnerA_jumpacross;
	level.scr_anim[ "generic" ][ "freerunnerB_jumpacross" ] = %freerunnerB_jumpacross;

	//intro player and friendly takedown
	level.scr_anim[ "ai_enemy" ][ "intro_takedown" ] = %jungle_ghost_intro_stealthkill_ai_enemy;
	level.scr_anim[ "ai_friendly" ][ "intro_takedown_arrival" ] = %jungle_ghost_intro_stealthkill_ai_friendly_transition;
	level.scr_anim[ "ai_friendly" ][ "intro_takedown_idle" ][0] = %jungle_ghost_intro_stealthkill_ai_friendly_transition_i;
	
	level.scr_anim[ "ai_friendly" ][ "intro_takedown" ] = %jungle_ghost_intro_stealthkill_ai_friendly;
	level.scr_anim[ "player_enemy" ][ "intro_takedown" ] = %jungle_ghost_intro_stealthkill_player_enemy;
	
	level.scr_anim[ "player_enemy" ][ "intro_takedown_death_idle" ][0] = %jungle_ghost_intro_stealthkill_player_enemy_deathidle;
	level.scr_anim[ "ai_enemy" ][ "intro_takedown_death_idle" ][0] = %jungle_ghost_intro_stealthkill_ai_enemy_deathidle;
	
	level.scr_anim[ "player_enemy" ][ "intro_takedown_death" ] = %jungle_ghost_intro_stealthkill_player_enemy_death;
	level.scr_anim[ "ai_enemy" ][ "intro_takedown_death" ] = %jungle_ghost_intro_stealthkill_ai_enemy_death;
	
	level.scr_anim[ "generic" ][ "run_reaction_180" ] = %run_reaction_180;
	level.scr_anim[ "generic" ][ "run_reaction_L_quick" ] = %run_reaction_L_quick;
	
	level.scr_anim[ "generic" ][ "throw_smoke" ] = %exposed_crouch_fast_grenade_1;
	
	//ai slide to escape run
	level.scr_anim[ "generic" ][ "jungle_ghost_ai_slide1" ]			= %jungle_ghost_ai_slide_guy1;
	level.scr_anim[ "generic" ][ "jungle_ghost_ai_slide2" ]			= %jungle_ghost_ai_slide_guy2;
	
	//ending swimming stuff 
	level.scr_anim[ "generic" ][ "swim_idle" ][0]			= %prague_intro_swim_idle_01;
	level.scr_anim[ "generic" ][ "swim" ]			= %prague_intro_swim_breaststroke_01;
	level.scr_anim[ "generic" ][ "swim_fast" ]			= %prague_intro_swim_breaststroke_02;
	level.scr_anim[ "generic" ][ "signal_stop_swim" ]			= %prague_intro_swim_holdposition;
	
	level.scr_anim[ "generic" ][ "jungle_ghost_wf_escape_jumpoff_guy1" ]			= %jungle_ghost_wf_escape_jumpoff_guy1;
	level.scr_anim[ "generic" ][ "jungle_ghost_wf_escape_jumpoff_guy2" ]			= %jungle_ghost_wf_escape_jumpoff_guy2;
	
	level.scr_anim[ "generic" ][ "saw_gunner_prone_runout_L" ]			= %saw_gunner_prone_runout_L;
	level.scr_anim[ "generic" ][ "factory_rooftop_jumpoff_ally02" ]			= %factory_rooftop_jumpoff_ally02;

	
	//waterfall enemies who get ambushed from behind waterfall
	level.scr_anim[ "generic" ][ "patrol_jog_360_once" ] = %patrol_jog_360_once;
	level.scr_anim[ "generic" ][ "patrol_jog_orders_once" ] = %patrol_jog_orders_once;
	level.scr_anim[ "generic" ][ "patrol_jog" ] = %patrol_jog;
	
	//water walk/run
	level.scr_anim[ "generic" ][ "water_walk_1" ] = %water_walk_01;
	level.scr_anim[ "generic" ][ "water_walk_2" ] = %water_walk_02;
	
	level.scr_anim[ "generic" ][ "water_run_1" ] = %water_run_01;
	level.scr_anim[ "generic" ][ "water_run_2" ] = %water_run_02;
	
	level.scr_anim[ "pilot" ][ "new_crash" ] 		= %jungle_ghost_helicrash_pilot;
	level.scr_anim[ "pilot" ][ "new_crash_idle" ][0] 		= %jungle_ghost_helicrash_pilot_idle;
		
	level.scr_anim[ "dead_jungle_pilot" ][ "dead_idle" ][0] = %paris_npc_dead_poses_v24_chair_sq;
	
	addNotetrack_customFunction( "ai_enemy", "knife out", ::intro_takedown_knife_notetrack_func );
	addNotetrack_customFunction( "player_enemy", "knife in", ::intro_takedown_knife_notetrack_func );
	
	addNotetrack_customFunction( "generic", "fire", ::magic_smoke_nade, "throw_smoke" );

	addNotetrack_customFunction( "guard1", "fire", ::executor_kill_hostage_notetrack );
	addNotetrack_customFunction( "guard2", "fire", ::executor_kill_hostage_notetrack );
	
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_dunk", ::vfx_hostage1_dunk, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_lift", ::vfx_hostage1_lift, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_waterboard_start", ::vfx_hostage1_waterboard_start, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_waterboard_stop", ::vfx_hostage1_waterboard_stop, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_push_splash", ::vfx_hostage1_push_splash, "push_underwater" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_wateridle_start", ::vfx_hostage1_wateridle_start, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_wateridle_stop", ::vfx_hostage1_wateridle_stop, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_liftup", ::vfx_hostage1_liftup, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_body_ripple", ::vfx_hostage1_body_ripple, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_arm_l_splash", ::vfx_hostage1_arm_l_splash, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_arm_r_splash", ::vfx_hostage1_arm_r_splash, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_arm_l_liftout", ::vfx_hostage1_arm_l_liftout, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_arm_r_liftout", ::vfx_hostage1_arm_r_liftout, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_arm_r_pushsplash", ::vfx_hostage1_arm_r_pushsplash, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_leg_l_pushsplash", ::vfx_hostage1_leg_l_pushsplash, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_leg_l_splash", ::vfx_hostage1_leg_l_splash, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_leg_r_lift", ::vfx_hostage1_leg_r_lift, "water_dunk_loop" );
	addNotetrack_customFunction( "hostage1"  , "scn_jungl_drowned_hostage1_leg_r_pushsplash", ::vfx_hostage1_leg_r_pushsplash, "water_dunk_loop" );
}


vfx_hostage1_facepunch( guy ) 
{
         playfxontag( getfx( "flesh_hit_large" ), guy, "j_neck" );
}


vfx_hostage1_dunk( thing ) 
{
         playfxontag( getfx( "drowned_dunk_in" ), thing, "j_wrist_ri" );
}


vfx_hostage1_lift( thing ) 
{
         playfxontag( getfx( "drowned_dunk_out" ), thing, "j_wrist_ri" );
}


vfx_hostage1_waterboard_start( thing ) 
{
         playfxontag( getfx( "drowned_waterboarding_loop" ), thing, "j_wrist_ri" );
}


vfx_hostage1_waterboard_stop( thing ) 
{
         stopfxontag( getfx( "drowned_waterboarding_loop" ), thing, "j_wrist_ri" );
}


vfx_hostage1_push_splash( thing ) 
{
         playfxontag( getfx( "drowned_push_splash" ), thing, "j_wrist_ri" );
}


vfx_hostage1_wateridle_start( thing ) 
{
         playfxontag( getfx( "drowned_underwater_loop" ), thing, "j_wrist_ri" );
}


vfx_hostage1_wateridle_stop( thing ) 
{
         stopfxontag( getfx( "drowned_underwater_loop" ), thing, "j_wrist_ri" );
}


vfx_hostage1_liftup( thing ) 
{
         playfxontag( getfx( "drowned_lift_out" ), thing, "j_wrist_ri" );
}


vfx_hostage1_body_ripple( thing ) 
{
         playfxontag( getfx( "drowned_body_ripple" ), thing, "j_wrist_ri" );
}


vfx_hostage1_arm_l_splash( thing ) 
{
         playfxontag( getfx( "drowned_splash_hand_in" ), thing, "j_wrist_ri" );
}


vfx_hostage1_arm_r_splash( thing ) 
{
         playfxontag( getfx( "drowned_splash_hand_in" ), thing, "j_wrist_ri" );
}


vfx_hostage1_arm_l_liftout( thing ) 
{
         playfxontag( getfx( "drowned_splash_hand_out" ), thing, "j_wrist_ri" );
}


vfx_hostage1_arm_r_liftout( thing ) 
{
         playfxontag( getfx( "drowned_splash_hand_out" ), thing, "j_wrist_ri" );
}


vfx_hostage1_arm_r_pushsplash( thing ) 
{
         playfxontag( getfx( "drowned_limb_push_splash" ), thing, "j_wrist_ri" );
}


vfx_hostage1_leg_l_pushsplash( thing ) 
{
         playfxontag( getfx( "drowned_limb_push_splash" ), thing, "j_wrist_ri" );
}


vfx_hostage1_leg_l_splash( thing ) 
{
         playfxontag( getfx( "drowned_splash_hand_in" ), thing, "j_wrist_ri" );
}


vfx_hostage1_leg_r_lift( thing ) 
{
         playfxontag( getfx( "drowned_splash_hand_out" ), thing, "j_wrist_ri" );
}


vfx_hostage1_leg_r_pushsplash( thing ) 
{
         playfxontag( getfx( "drowned_limb_push_splash" ), thing, "j_wrist_ri" );
}


intro_takedown_knife_notetrack_func( guy )
{
	guy die();
}


magic_smoke_nade( guy )
{
	wait 1.5;
	nade_land = getstruct("smoke_land", "targetname" );
	MagicGrenade( "smoke_grenade_american", nade_land.origin +( 0,0,20 ), nade_land.origin, .05 );

}

#using_animtree( "vehicles" );
vehicle_anims()
{
	level.scr_animtree[ "mi17" ] 					= #animtree;
	level.scr_model[ "mi17" ] 					= "vehicle_mi17_woodland_fly_cheap";
	level.scr_anim[ "mi17" ][ "airdrop" ] 		= %prague_drop_mi17;
	level.scr_anim[ "mi17" ][ "airdrop_idle" ] 		= %prague_idle_mi17;
	level.scr_anim[ "mi17" ][ "prague_drop_btr" ] 		= %prague_drop_mi17;
			
	level.scr_animtree[ "aas" ] 					= #animtree;
	level.scr_model[ "aas" ] 					= "vehicle_aas_72x_destructible";
	level.scr_anim[ "aas" ][ "new_crash" ] 		= %jungle_ghost_helicrash_helicopter;
	level.scr_anim[ "aas" ][ "new_crash_idle" ][0] 		= %jungle_ghost_helicrash_helicopter_idle;
	
	level.scr_animtree[ "airdrop_rope" ] 					= #animtree;
	level.scr_model[ "airdrop_rope" ] 					= "com_prague_rope_animated";
	level.scr_anim[ "airdrop_rope" ][ "airdrop" ] 		= %prague_drop_rope;
	level.scr_anim[ "airdrop_rope" ][ "airdrop_idle" ] 		= %prague_idle_rope;
	level.scr_anim[ "airdrop_rope" ][ "prague_drop_btr" ] 		= %prague_drop_rope;
		
	level.scr_animtree[ "btr" ] 					= #animtree;
	level.scr_model[ "btr" ] 					= "vehicle_btr80_low";
	level.scr_anim[ "btr" ][ "airdrop" ] 		= %prague_drop_btr;
	level.scr_anim[ "btr" ][ "airdrop_idle" ] 		= %prague_idle_btr;
	level.scr_anim[ "btr" ][ "prague_drop_btr" ] 		= %prague_drop_btr;
	
	level.scr_animtree["player_parachute"] = #animtree;
	level.scr_model[ "player_parachute" ]						 		= "vehicle_parachute";
	level.scr_anim["player_parachute"]	["parachute_land"]				 = %halo_parachute_parachute_landing_01; //time = 3.48/12.93 26%	
		
	addNotetrack_customFunction( "aas"  , "heli_killed", ::heli_crash_heli_killed, 			"new_crash" );
	
	addNotetrack_customFunction( "aas"  , "box_hit_1", ::heli_crash_box_hit_1, 				"new_crash" );
	addNotetrack_customFunction( "aas"  , "blade_hit_1", ::heli_crash_blade_hit_1, 			"new_crash" );
	addNotetrack_customFunction( "aas"  , "engine_fail", ::heli_crash_engine_fail, 			"new_crash" );
	addNotetrack_customFunction( "aas"  , "box_hit_2", ::heli_crash_box_hit_2, 				"new_crash" );	
	addNotetrack_customFunction( "aas"  , "blade_hit_2", ::heli_crash_blade_hit_2, 			"new_crash" );	
		
	addNotetrack_customFunction( "aas"  , "blade_swap", ::heli_blade_swap, 					"new_crash" );
	addNotetrack_customFunction( "aas"  , "chopper_impact", ::heli_chopper_impact, 			"new_crash" );
	
	addNotetrack_customFunction( "aas"  , "blade_hit_water", ::heli_crash_blade_hit_water, 	"new_crash" );
	addNotetrack_customFunction( "aas"  , "tail_rotor_hit", ::heli_crash_tail_rotor_hit, 	"new_crash" );
	addNotetrack_customFunction( "aas"  , "body_hit_water", ::heli_crash_body_hit_water, 	"new_crash" );
	

}

	
heli_crash_heli_killed( heli )
{
	playfxontag( getfx( "vfx_helicrash_helibodyfire" ), heli, "TAG_ENGINE_LEFT" );
	playfxontag( getfx( "vfx_helicrash_rpg_explosion" ), heli, "TAG_ENGINE_LEFT" );
		
    //playfxontag( getfx( "drowned_waterboarding_loop" ), thing, "j_wrist_ri" );

}


heli_crash_box_hit_1( heli )
{
	activate_exploder( "box_hit_1" );
}

heli_crash_blade_hit_1( heli )
{
	heli SetModel("vehicle_aas_72x_destructible");
	
	activate_exploder( "blade_hit_1" );
}

heli_crash_engine_fail( heli )
{
	activate_exploder( "engine_fail" );
	//playfxontag( getfx( "vfx_helicrash_rotorspinsmoke" ), heli, "TAG_ENGINE_LEFT" );
	  
}

heli_crash_box_hit_2( heli )
{
	activate_exploder( "box_hit_2" );
}

heli_crash_blade_hit_2( heli )
{
	activate_exploder( "blade_hit_2" );
}

heli_blade_swap( heli )
{
	//IPrintLn("blade swap");
	//tag_blade
	heli hidepart( "tag_blade");
	
	activate_exploder( "blade_swap" );
}

heli_chopper_impact( heli )
{
	flag_set("chopper_impact");
	
	activate_exploder( "chopper_impact" );
	
	//playfxontag( getfx( "vfx_helicrash_helibodyfire" ), heli, "TAG_ORIGIN" );
}

heli_crash_blade_hit_water( heli )
{
	activate_exploder( "blade_hit_water" );
}

heli_crash_tail_rotor_hit( heli )
{
	activate_exploder( "tail_rotor_hit" );
}

heli_crash_body_hit_water( heli )
{
	activate_exploder( "body_hit_water" );
}


#using_animtree( "animated_props" );
script_model_anims()
{
	level.scr_animtree[ "pristine_crate" ] 					= #animtree;
	level.scr_model[ "pristine_crate" ] 					= "jungle_crate_01";
	level.scr_anim[ "pristine_crate" ][ "new_crash" ] 		= %jungle_ghost_helicrash_crate;
	level.scr_anim[ "pristine_crate" ][ "new_crash_idle" ][0] 		= %jungle_ghost_helicrash_crate_idle;
	
	level.scr_animtree[ "damaged_crate" ] 					= #animtree;
	level.scr_model[ "damaged_crate" ] 					= "jungle_crate_01_dmg";
	level.scr_anim[ "damaged_crate" ][ "new_crash" ] 		= %jungle_ghost_helicrash_crate;
	level.scr_anim[ "damaged_crate" ][ "new_crash_idle" ][0] 		= %jungle_ghost_helicrash_crate_idle;	
	
	addNotetrack_customFunction( "pristine_crate"  , "crate_impact", ::hide_me, "new_crash" );
	addNotetrack_customFunction( "damaged_crate"  , "crate_impact", ::show_me, "new_crash" );
}

hide_me( me )
{
	//WOOD CRATE FROM CHOPPER CRASH
	me hide();
	crate_sbm = get_target_ent("dest_crate");
	crate_sbm NotSolid();
	crate_sbm ConnectPaths();
	
	thread play_sound_in_space( "detpack_explo_wood", me.origin );
	wait .5;
	thread play_sound_in_space( "explo_tree", me.origin );

	
	dest_crate = getent( "dest_crate", "targetname" );
	dest_crate Solid();
	dest_crate DisconnectPaths();
}

show_me( me )
{
	me show();
	damage_vol = getstruct("crate_do_damage","targetname");
	wait (0.5);
	RadiusDamage(damage_vol.origin, 80, 1000, 1000);
}

executor_kill_hostage_notetrack(guy)
{
	s = guy.scene_struct;	
	s notify("hostage_shot", guy.script_noteworthy );
}

knife_notetrack_death( guy )
{
	guy stopanimscripted();
	guy die();
}

attach_knife( ent )
{
	level notify( "interupt_end" );
	ent thread play_sound_on_entity( "jungle_takedown_grab" );
	ent.knife_attached = true;
	ent attach( "weapon_parabolic_knife", "TAG_INHAND", true );
}

detach_knife( ent )
{
	if ( IsDefined( ent.knife_attached ) && ent.knife_attached )
	{
		ent detach( "weapon_parabolic_knife", "TAG_INHAND", true );
		ent.knife_attached = undefined;
	}
}

insert_knife( guy )
{	
	guy thread play_sound_on_entity("jungle_takedown_slice");
}


#using_animtree( "player" );
player_anims()
{
	level.scr_animtree[ "player_rig" ] 					 			= #animtree;
	level.scr_model[ "player_rig" ] 					 			= "viewhands_player_gs_jungle";	
	
	level.scr_anim[ "player_rig" ][ "intro_takedown" ] = %jungle_ghost_intro_stealthkill_player_playervm;
	level.scr_anim[ "player_rig" ][ "helped_up" ] = %jungle_ghost_wf_holdup_player_helpup; //waterfall guy helpup
	level.scr_anim[ "player_rig" ][ "waterfall_jump" ] = %jungle_ghost_wf_escape_jumpoff_player; //waterfall guy helpup
	
	level.scr_anim[ "player_rig" ][ "para_crash" ] = %jungle_ghost_parachute_crash_falling; //waterfall guy helpup
	
}

#using_animtree( "script_model" );
script_model()
{
	level.scr_animtree[ "seal_boat1" ] 					 			= #animtree;
	level.scr_animtree[ "seal_boat2" ] 					 			= #animtree;
	
	level.scr_anim[ "seal_boat1" ][ "outro" ] 		= %jungle_ghost_boat_1;
	level.scr_anim[ "seal_boat2" ][ "outro" ] 		= %jungle_ghost_boat_2;
}
