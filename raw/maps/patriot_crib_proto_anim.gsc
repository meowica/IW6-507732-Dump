#include common_scripts\utility;
#include maps\_anim;

main()
{
	maps\_player_rig::init_player_rig( "viewhands_player_delta" );
	anims_player();
	anims_human();
	anims_model();
	anims_vehicle();
	anims_dog();
	
	radio();
	dialogue();
	fx();
}

#using_animtree( "player" );
anims_player()
{
//	level.scr_animtree[ "player_rig" ] 					 					= #animtree;
//	level.scr_model[ "player_rig" ] 					 					= "viewhands_player_delta";
	
	// Intro: Hummer Exit Anims
	level.scr_anim[ "player_rig" ][ "hummer_exit" ]							= %paris_ac130_run_around_humvee_player;
	
	// Carlos Attack
	level.scr_anim[ "player_rig" ][ "crib_grab" ]							= %crib_grab_player;
	
	// Sandman Handshake
	level.scr_anim[ "player_rig" ][ "crib_handshake" ]						= %crib_handshake_player;
	
	
	
	// Custom Loadout Anims
	level.scr_anim[ "player_rig" ][ "crib_mp5_barrel_2_clip" ]				= %crib_mp5_barrel_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_mp5_barrel_2_scope" ]				= %crib_mp5_barrel_2_scope;
	level.scr_anim[ "player_rig" ][ "crib_mp5_barrel_idle" ][ 0 ]			= %crib_mp5_barrel_idle;
	level.scr_anim[ "player_rig" ][ "crib_mp5_barrel_putaway" ]				= %crib_mp5_barrel_putaway;
	level.scr_anim[ "player_rig" ][ "crib_mp5_clip_2_barrel" ]				= %crib_mp5_clip_2_barrel;
	level.scr_anim[ "player_rig" ][ "crib_mp5_clip_2_scope" ]				= %crib_mp5_clip_2_scope;
	level.scr_anim[ "player_rig" ][ "crib_mp5_clip_idle" ][ 0 ]				= %crib_mp5_clip_idle;
	level.scr_anim[ "player_rig" ][ "crib_mp5_clip_putaway" ]				= %crib_mp5_clip_putaway;
	level.scr_anim[ "player_rig" ][ "crib_mp5_pullout_2_clip" ]				= %crib_mp5_pullout_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_mp5_scope_2_barrel" ]				= %crib_mp5_scope_2_barrel;
	level.scr_anim[ "player_rig" ][ "crib_mp5_scope_2_clip" ]				= %crib_mp5_scope_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_mp5_scope_acog_idle" ][ 0 ]		= %crib_mp5_scope_acog_idle;
	level.scr_anim[ "player_rig" ][ "crib_mp5_scope_idle" ][ 0 ]			= %crib_mp5_scope_idle;
	level.scr_anim[ "player_rig" ][ "crib_mp5_scope_putaway" ]				= %crib_mp5_scope_putaway;
	level.scr_anim[ "player_rig" ][ "crib_mp5_scope_reflex_idle" ][ 0 ]		= %crib_mp5_scope_reflex_idle;
    
	level.scr_anim[ "player_rig" ][ "crib_ump45_barrel_2_clip" ]			= %crib_ump45_barrel_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_ump45_barrel_2_scope" ]			= %crib_ump45_barrel_2_scope;
	level.scr_anim[ "player_rig" ][ "crib_ump45_barrel_idle" ][ 0 ]			= %crib_ump45_barrel_idle;
	level.scr_anim[ "player_rig" ][ "crib_ump45_barrel_putaway" ]			= %crib_ump45_barrel_putaway;
	level.scr_anim[ "player_rig" ][ "crib_ump45_clip_2_barrel" ]			= %crib_ump45_clip_2_barrel;
	level.scr_anim[ "player_rig" ][ "crib_ump45_clip_2_scope" ]				= %crib_ump45_clip_2_scope;
	level.scr_anim[ "player_rig" ][ "crib_ump45_clip_idle" ][ 0 ]			= %crib_ump45_clip_idle;
	level.scr_anim[ "player_rig" ][ "crib_ump45_clip_putaway" ]				= %crib_ump45_clip_putaway;
	level.scr_anim[ "player_rig" ][ "crib_ump45_pullout_2_clip" ]			= %crib_ump45_pullout_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_ump45_scope_2_barrel" ]			= %crib_ump45_scope_2_barrel;
	level.scr_anim[ "player_rig" ][ "crib_ump45_scope_2_clip" ]				= %crib_ump45_scope_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_ump45_scope_acog_idle" ][ 0 ]		= %crib_ump45_scope_acog_idle;
	level.scr_anim[ "player_rig" ][ "crib_ump45_scope_idle" ][ 0 ]			= %crib_ump45_scope_idle;
	level.scr_anim[ "player_rig" ][ "crib_ump45_scope_putaway" ]			= %crib_ump45_scope_putaway;
	level.scr_anim[ "player_rig" ][ "crib_ump45_scope_reflex_idle" ][ 0 ]	= %crib_ump45_scope_reflex_idle;
    
	level.scr_anim[ "player_rig" ][ "crib_ak47_barrel_2_clip" ]				= %crib_ak47_barrel_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_ak47_barrel_2_scope" ]			= %crib_ak47_barrel_2_scope;
	level.scr_anim[ "player_rig" ][ "crib_ak47_barrel_idle" ][ 0 ]			= %crib_ak47_barrel_idle;
	level.scr_anim[ "player_rig" ][ "crib_ak47_barrel_putaway" ]			= %crib_ak47_barrel_putaway;
	level.scr_anim[ "player_rig" ][ "crib_ak47_clip_2_barrel" ]				= %crib_ak47_clip_2_barrel;
	level.scr_anim[ "player_rig" ][ "crib_ak47_clip_2_scope" ]				= %crib_ak47_clip_2_scope;
	level.scr_anim[ "player_rig" ][ "crib_ak47_clip_idle" ][ 0 ]			= %crib_ak47_clip_idle;
	level.scr_anim[ "player_rig" ][ "crib_ak47_clip_putaway" ]				= %crib_ak47_clip_putaway;
	level.scr_anim[ "player_rig" ][ "crib_ak47_pullout_2_clip" ]			= %crib_ak47_pullout_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_ak47_scope_2_barrel" ]			= %crib_ak47_scope_2_barrel;
	level.scr_anim[ "player_rig" ][ "crib_ak47_scope_2_clip" ]				= %crib_ak47_scope_2_clip;
	level.scr_anim[ "player_rig" ][ "crib_ak47_scope_acog_idle" ][ 0 ]		= %crib_ak47_scope_acog_idle;
	level.scr_anim[ "player_rig" ][ "crib_ak47_scope_idle" ][ 0 ]			= %crib_ak47_scope_idle;
	level.scr_anim[ "player_rig" ][ "crib_ak47_scope_putaway" ]				= %crib_ak47_scope_putaway;
	level.scr_anim[ "player_rig" ][ "crib_ak47_scope_reflex_idle" ][ 0 ]	= %crib_ak47_scope_reflex_idle;
}

#using_animtree( "generic_human" );
anims_human()
{
	level.scr_animtree[ "generic" ] 					 					= #animtree;
	// Misc. NPC Activities
	level.scr_anim[ "generic"	 ][ "training_pushups_guy1"			  ][ 0 ] = %training_pushups_guy1;
	level.scr_anim[ "generic"	 ][ "afgan_caves_sleeping_guard_idle" ][ 0 ] = %afgan_caves_sleeping_guard_idle;
	level.scr_anim[ "generic"	 ][ "civilian_reader_2"				  ][ 0 ] = %civilian_reader_2;
	level.scr_anim[ "generic"	 ][ "training_humvee_repair"		  ][ 0 ] = %training_humvee_repair;
	level.scr_anim[ "generic"	 ][ "cliffhanger_welder_wing"		  ][ 0 ] = %cliffhanger_welder_wing;
	level.scr_anim[ "generic"	 ][ "crowdsniper_civ_sitting1"		  ][ 0 ] = %crowdsniper_civ_sitting1;
	level.scr_anim[ "generic"	 ][ "laptop_sit_idle_calm"			  ][ 0 ] = %laptop_sit_idle_calm;
	level.scr_anim[ "generic"	 ][ "killhouse_laptop_idle"			  ][ 0 ] = %killhouse_laptop_idle;
	level.scr_anim[ "generic"	 ][ "killhouse_laptop_idle"			  ][ 1 ] = %killhouse_laptop_lookup;
	level.scr_anim[ "generic"	 ][ "killhouse_laptop_idle"			  ][ 2 ] = %killhouse_laptop_twitch;
	
	level.scr_anim[ "generic" ][ "training_intro_trainee_1_end_idle"		  ][ 0 ] = %training_intro_trainee_1_end_idle;
	addNotetrack_customFunction( "trainee_01", "fire_spray", ::fire_weapon );
	
	// Misc. NPC Anims Brief
	level.scr_anim[ "generic" ][ "crowdsniper_crowdwatchidle_3"		  ][ 0 ] = %crowdsniper_crowdwatchidle_3;
	level.scr_anim[ "generic" ][ "training_intro_foley_idle_1"		  ][ 0 ] = %training_intro_foley_idle_1;
	
	// Carlos Attack
	level.scr_anim[ "generic" ][ "crib_grab"	  ] = %crib_grab_soldier;
	
	// Sandman Handshake
    level.scr_anim[ "generic" ][ "crib_handshake" ] = %crib_handshake_sandman;
    
    // Torture Room Anims
	level.scr_anim[ "torture_enemy"	  ][ "torture" ] = %favela_torture_sequence_prisoner;
	level.scr_anim[ "torture_friend1" ][ "torture" ] = %favela_torture_sequence_soldier1;
	level.scr_anim[ "torture_friend2" ][ "torture" ] = %favela_torture_sequence_soldier2;
	
	// Torture Room Exit Anims
	level.scr_anim[ "torture_enemy" ][ "torture_exit" ] = %interrogate_opfor_death_a;
    
	addNotetrack_flag( "torture_friend2", "pull_start", "drop_door" );
	
	// NPC Idle Anims
	level.scr_anim[ "generic" ][ "npc_idle_armed"	][ 0 ] = %casual_stand_v2_idle;
	level.scr_anim[ "generic" ][ "npc_idle_unarmed" ][ 0 ] = %crowdsniper_crowdwatchidle_3;
	
	// NPC Jog Anims
	level.scr_anim[ "generic" ][ "npc_jog_armed"   ] = %casual_killer_jog_A;
	level.scr_anim[ "generic" ][ "npc_jog_unarmed" ] = %training_jog_guy1;
	
	// NPC Walk Anims
	level.scr_anim[ "generic" ][ "npc_walk_armed" ][ 0 ]	  = %patrol_bored_patrolwalk;
	level.scr_anim[ "generic" ][ "npc_walk_armed" ][ 1 ]	  = %patrol_bored_patrolwalk_twitch;
	level.scr_anim[ "generic" ][ "npc_walk_unarmed_slow"	] = %london_inspector_walk;
	level.scr_anim[ "generic" ][ "npc_walk_unarmed_fast"	] = %civilian_walk_hurried_1;
	level.scr_anim[ "generic" ][ "npc_walk_unarmed_cool"	] = %civilian_walk_cool;
	level.scr_anim[ "generic" ][ "npc_walk_unarmed_nervous" ] = %civilian_walk_nervous;
}

fire_weapon( guy )
{
	guy Shoot( 1.0 );
//	if ( !flag( "player_near_range" ) )
//		return;
//	guy PlaySound( "drone_m4carbine_fire_npc" );
//	PlayFXOnTag( getfx( "m16_muzzleflash" ), guy, "tag_flash" );
}

#using_animtree( "script_model" );
anims_model()
{
	// Torture Room Anims
	level.scr_animtree[ "torture_cables" ] 							= #animtree;
	level.scr_model[ "torture_cables" ] 							= "machinery_jumper_cable";
	level.scr_anim[ "torture_cables" ][ "torture" ]					= %favela_jumper_cables;
	//addNotetrack_animSound( "torture_cables", "torture", "spark", "SOUNDALIAS" );
	addNotetrack_customFunction( "torture_cables", "spark", ::jumper_cable_fx );
}

#using_animtree("vehicles");
anims_vehicle()
{
	// Intro: Hummer exit anims
	level.scr_animtree[ "hummer" ]									= #animtree;
	level.scr_anim[ "hummer" ][ "hummer_exit" ] 					= %paris_ac130_run_around_humvee_door;
}

#using_animtree( "dog" );
anims_dog()
{
	level.scr_anim[ "generic" ][ "german_shepherd_sleeping" ][ 0 ]	= %german_shepherd_sleeping;
}

radio()
{
	// Briefing Start
	level.scr_radio[ "safehouse_snd_gother"	  ] = "safehouse_snd_gother";
    
	// Outro
	level.scr_radio[ "safehouse_trk_windemup" ] = "safehouse_trk_windemup";
	level.scr_radio[ "safehouse_snd_afraidof" ] = "safehouse_snd_afraidof";
	level.scr_radio[ "safehouse_grn_nowsir"   ] = "safehouse_grn_nowsir";
	level.scr_radio[ "safehouse_snd_goodone"  ] = "safehouse_snd_goodone";
	
	// These are being played as sounds in space
	//	"safehouse_snd_littlegirls"
	//	"safehouse_trk_wheresgirl"
	//	"safehouse_snd_holdingout"
	//	"safehouse_snd_wronganswer"
	//	"safehouse_snd_tellme"
	//	"safehouse_snd_pissedyourself"
	//	"safehouse_hst_youhearme"
	//	"safehouse_hst_fyou"
	//	"safehouse_hst_sm_scrm_01"
	//	"safehouse_hst_sm_scrm_02
	//	"safehouse_hst_md_scrm_01"
	//	"safehouse_hst_md_scrm_02"
	//	"safehouse_hst_md_scrm_03"
	//	"safehouse_hst_lg_scrm_01"
	//	"safehouse_hst_lg_scrm_02"
	//	"safehouse_hst_lg_scrm_03"
	
	// Nag Lines: Outro
	
}

dialogue()
{
	// Intro
	level.scr_sound[ "generic" ][ "safehouse_grn_wakeup"	   ] = "safehouse_grn_wakeup";
	level.scr_sound[ "generic" ][ "safehouse_grn_alreadymoved" ] = "safehouse_grn_alreadymoved";
	level.scr_sound[ "generic" ][ "safehouse_grn_werelate"	   ] = "safehouse_grn_werelate";
	
	level.scr_sound[ "torture_friend2" ][ "safehouse_snd_joinus"	  ] = "safehouse_snd_joinus";
	level.scr_sound[ "torture_friend2" ][ "safehouse_snd_loadoff"	  ] = "safehouse_snd_loadoff";
	level.scr_sound[ "torture_friend2" ][ "safehouse_snd_toolong"	  ] = "safehouse_snd_toolong";
	level.scr_sound[ "torture_friend2" ][ "safehouse_snd_armoryequipment" ] = "safehouse_snd_armoryequipment";
	level.scr_sound[ "torture_friend2" ][ "safehouse_snd_readytoroll" ] = "safehouse_snd_readytoroll";
	level.scr_sound[ "generic"		   ][ "safehouse_grn_yessir"	  ] = "safehouse_grn_yessir";
	
	level.scr_sound[ "generic" ][ "safehouse_grn_justgothere" ] = "safehouse_grn_justgothere";
	level.scr_sound[ "generic" ][ "safehouse_grn_grababeer"	  ] = "safehouse_grn_grababeer";
	
	// NPC: C-Los
	level.scr_sound[ "generic" ][ "safehouse_cls_comenearme" ]		= "safehouse_cls_comenearme";
	level.scr_sound[ "generic" ][ "safehouse_cls_sitherewaiting" ]	= "safehouse_cls_sitherewaiting";
	level.scr_sound[ "generic" ][ "safehouse_cls_somespace" ] = "safehouse_cls_somespace";
	level.scr_sound[ "generic" ][ "safehouse_cls_stepback" ] = "safehouse_cls_stepback";
	level.scr_sound[ "generic" ][ "safehouse_cls_youdeaf" ] = "safehouse_cls_youdeaf";
	level.scr_sound[ "generic" ][ "safehouse_cls_rookie" ] = "safehouse_cls_rookie";
	// JC-ToDo: Add these to Carlos NPC interaction
	level.scr_sound[ "generic" ][ "safehouse_lt_giveitarest" ] = "safehouse_lt_giveitarest";
	level.scr_sound[ "generic" ][ "safehouse_cls_concernyou" ] = "safehouse_cls_concernyou";
	
	// NPC: Grinch
	level.scr_sound[ "generic" ][ "safehouse_grn_triedtorun"  ] = "safehouse_grn_triedtorun";
	level.scr_sound[ "generic" ][ "safehouse_grn_newtoys"	  ] = "safehouse_grn_newtoys";
	level.scr_sound[ "generic" ][ "safehouse_grn_getsomerest" ] = "safehouse_grn_getsomerest";
	level.scr_sound[ "generic" ][ "safehouse_grn_shuteye"	  ] = "safehouse_grn_shuteye";
	
	// NPC: LT
	level.scr_sound[ "generic" ][ "safehouse_lt_prettyquiet"	] = "safehouse_lt_prettyquiet";
	level.scr_sound[ "generic" ][ "safehouse_lt_hellofaday"		] = "safehouse_lt_hellofaday";
	level.scr_sound[ "generic" ][ "safehouse_lt_checkoutarmory" ] = "safehouse_lt_checkoutarmory";
	level.scr_sound[ "generic" ][ "safehouse_lt_finishchapter"	] = "safehouse_lt_finishchapter";
	
	// NPC: Tommy
	level.scr_sound[ "generic" ][ "safehouse_tmy_onepiece"	 ] = "safehouse_tmy_onepiece";
	level.scr_sound[ "generic" ][ "safehouse_tmy_joyriding"	 ] = "safehouse_tmy_joyriding";
	level.scr_sound[ "generic" ][ "safehouse_tmy_ontherange" ] = "safehouse_tmy_ontherange";
	level.scr_sound[ "generic" ][ "safehouse_tmy_backtowork" ] = "safehouse_tmy_backtowork";
	
	// Exlplore - Weapons Testing
	level.scr_sound[ "generic" ][ "safehouse_grn_anylouder" ] = "safehouse_grn_anylouder";

	// JC-ToDo: Hook up weapons testing	
	level.scr_sound[ "generic" ][ "safehouse_rck_overwith" ] = "safehouse_rck_overwith";
	level.scr_sound[ "generic" ][ "safehouse_rck_testweapons" ] = "safehouse_rck_testweapons";
	level.scr_sound[ "generic" ][ "safehouse_rck_ornot" ] = "safehouse_rck_ornot";
	level.scr_sound[ "generic" ][ "safehouse_rck_onmyown" ] = "safehouse_rck_onmyown";
	level.scr_sound[ "generic" ][ "safehouse_rck_testthesescopes" ] = "safehouse_rck_testthesescopes";
	level.scr_sound[ "generic" ][ "safehouse_rck_newshit" ] = "safehouse_rck_newshit";
	level.scr_sound[ "generic" ][ "safehouse_rck_getstarted" ] = "safehouse_rck_getstarted";
	level.scr_sound[ "generic" ][ "safehouse_rck_acr" ] = "safehouse_rck_acr";
	level.scr_sound[ "generic" ][ "safehouse_rck_youready" ] = "safehouse_rck_youready";
	level.scr_sound[ "generic" ][ "safehouse_rck_lightemup" ] = "safehouse_rck_lightemup";
	level.scr_sound[ "generic" ][ "safehouse_rck_sighted" ] = "safehouse_rck_sighted";
	level.scr_sound[ "generic" ][ "safehouse_rck_longrange" ] = "safehouse_rck_longrange";
	level.scr_sound[ "generic" ][ "safehouse_rck_burstfire" ] = "safehouse_rck_burstfire";
	level.scr_sound[ "generic" ][ "safehouse_rck_getoverit" ] = "safehouse_rck_getoverit";
	level.scr_sound[ "generic" ][ "safehouse_rck_mk14" ] = "safehouse_rck_mk14";
	level.scr_sound[ "generic" ][ "safehouse_rck_popsmoke" ] = "safehouse_rck_popsmoke";
	level.scr_sound[ "generic" ][ "safehouse_rck_smokeout" ] = "safehouse_rck_smokeout";
	level.scr_sound[ "generic" ][ "safehouse_rck_321fire" ] = "safehouse_rck_321fire";
	level.scr_sound[ "generic" ][ "safehouse_rck_tooeasy" ] = "safehouse_rck_tooeasy";
	level.scr_sound[ "generic" ][ "safehouse_rck_fussisabout" ] = "safehouse_rck_fussisabout";
	level.scr_sound[ "generic" ][ "safehouse_rck_downrangelong" ] = "safehouse_rck_downrangelong";
	level.scr_sound[ "generic" ][ "safehouse_rck_downrange" ] = "safehouse_rck_downrange";
	level.scr_sound[ "generic" ][ "safehouse_rck_stayfocused" ] = "safehouse_rck_stayfocused";
	level.scr_sound[ "generic" ][ "safehouse_rck_waitingfor" ] = "safehouse_rck_waitingfor";
	level.scr_sound[ "generic" ][ "safehouse_rck_hitemall" ] = "safehouse_rck_hitemall";
	level.scr_sound[ "generic" ][ "safehouse_rck_missany" ] = "safehouse_rck_missany";
	
	// Explore - Patroller
	// JC-ToDo: Hook these up to patroller
	level.scr_sound[ "generic" ][ "safehouse_ptl_questionsright" ] = "safehouse_ptl_questionsright";
	level.scr_sound[ "generic" ][ "safehouse_ptl_newgear"		 ] = "safehouse_ptl_newgear";
	level.scr_sound[ "generic" ][ "safehouse_ptl_badside"		 ] = "safehouse_ptl_badside";
	
	// Briefing	
	level.scr_sound[ "generic" ][ "safehouse_snd_locationofathena" ] = "safehouse_snd_locationofathena";
	level.scr_sound[ "generic" ][ "safehouse_snd_pronto"		   ] = "safehouse_snd_pronto";
	level.scr_sound[ "generic" ][ "safehouse_trk_yessir"		   ] = "safehouse_trk_yessir";
	level.scr_sound[ "generic" ][ "safehouse_snd_weaponloadouts"   ] = "safehouse_snd_weaponloadouts";
	level.scr_sound[ "generic" ][ "safehouse_grn_onit"			   ] = "safehouse_grn_onit";
	level.scr_sound[ "generic" ][ "safehouse_snd_gearup2"		   ] = "safehouse_snd_gearup2";
	level.scr_sound[ "generic" ][ "safehouse_snd_mapofberlin"	   ] = "safehouse_snd_mapofberlin";
	
	level.scr_sound[ "generic" ][ "safehouse_cls_someaction"	  ] = "safehouse_cls_someaction";
	
	// Loadout - Sandman Chat
	level.scr_sound[ "generic" ][ "safehouse_snd_speakwithyou"	   ] = "safehouse_snd_speakwithyou";
	level.scr_sound[ "generic" ][ "safehouse_snd_offthismission"   ] = "safehouse_snd_offthismission";
	level.scr_sound[ "generic" ][ "safehouse_snd_didwell"		   ] = "safehouse_snd_didwell";
	level.scr_sound[ "generic" ][ "safehouse_snd_joiningtheteam"   ] = "safehouse_snd_joiningtheteam";
	level.scr_sound[ "generic" ][ "safehouse_snd_regretit"		   ] = "safehouse_snd_regretit";
	level.scr_sound[ "generic" ][ "safehouse_snd_gearup"		   ] = "safehouse_snd_gearup";
	
	// Loadout - General Chat
	level.scr_sound[ "generic" ][ "safehouse_cj1_screentwo"		] = "safehouse_cj1_screentwo";
	// Sound in Space: safehouse_gnl_important
	level.scr_sound[ "generic" ][ "safehouse_snd_reisdorfhotel" ] = "safehouse_snd_reisdorfhotel";
	// Sound in Space: safehouse_gnl_haveit
	level.scr_sound[ "generic" ][ "safehouse_snd_faraway"		] = "safehouse_snd_faraway";
	level.scr_sound[ "generic" ][ "safehouse_snd_graniteteam"	] = "safehouse_snd_graniteteam";
	// Sound in Space: safehouse_gnl_enroute
	level.scr_sound[ "generic" ][ "safehouse_snd_thanksgeneral" ] = "safehouse_snd_thanksgeneral";
	level.scr_sound[ "generic" ][ "safehouse_snd_thosechoppers" ] = "safehouse_snd_thosechoppers";
	
	// Loadout - Truck Call Out
	level.scr_sound[ "generic" ][ "safehouse_trk_choppertransport" ] = "safehouse_trk_choppertransport";
	
	// Loadout - Grinch
	level.scr_sound[ "generic" ][ "safehouse_grn_loadup"			] = "safehouse_grn_loadup";
	level.scr_sound[ "generic" ][ "safehouse_grn_shotgunsecondary"	] = "safehouse_grn_shotgunsecondary";
	level.scr_sound[ "generic" ][ "safehouse_grn_pistolsecondary"	] = "safehouse_grn_pistolsecondary";
	level.scr_sound[ "generic" ][ "safehouse_grn_machinepistols"	] = "safehouse_grn_machinepistols";
	level.scr_sound[ "generic" ][ "safehouse_grn_submachinegunfan"	] = "safehouse_grn_submachinegunfan";
	level.scr_sound[ "generic" ][ "safehouse_grn_assaultrifle"		] = "safehouse_grn_assaultrifle";
	level.scr_sound[ "generic" ][ "safehouse_grn_nowgrabprimary"	] = "safehouse_grn_nowgrabprimary";
	level.scr_sound[ "generic" ][ "safehouse_grn_nowgrabsecondary"	] = "safehouse_grn_nowgrabsecondary";
	level.scr_sound[ "generic" ][ "safehouse_grn_gunsyouwant"		] = "safehouse_grn_gunsyouwant";
	level.scr_sound[ "generic" ][ "safehouse_grn_lethalandtactical" ] = "safehouse_grn_lethalandtactical";
	level.scr_sound[ "generic" ][ "safehouse_grn_gottago"			] = "safehouse_grn_gottago";
	
	// Loadout - Nags
	// JC-ToDo: Need to add these nag lines
	level.scr_sound[ "generic" ][ "safehouse_trk_loadout"	   ] = "safehouse_trk_loadout";
	level.scr_sound[ "generic" ][ "safehouse_trk_closetoready" ] = "safehouse_trk_closetoready";
	level.scr_sound[ "generic" ][ "safehouse_trk_secondnow"	   ] = "safehouse_trk_secondnow";
	
	// Loadout - Door Conversation
	// JC-ToDo: Add this conversation sequence to the load out
	level.scr_sound[ "generic" ][ "safehouse_cls_sweettime"	   ] = "safehouse_cls_sweettime";
	level.scr_sound[ "generic" ][ "safehouse_lt_goingwithus"   ] = "safehouse_lt_goingwithus";
	level.scr_sound[ "generic" ][ "safehouse_cls_whyisthat"	   ] = "safehouse_cls_whyisthat";
	level.scr_sound[ "generic" ][ "safehouse_lt_complainabout" ] = "safehouse_lt_complainabout";
	level.scr_sound[ "generic" ][ "safehouse_cls_veryfunny"	   ] = "safehouse_cls_veryfunny";
	level.scr_sound[ "generic" ][ "safehouse_trk_somethingnew" ] = "safehouse_trk_somethingnew";
	level.scr_sound[ "generic" ][ "safehouse_lt_probablyright" ] = "safehouse_lt_probablyright";
	level.scr_sound[ "generic" ][ "safehouse_cls_giantgrin"	   ] = "safehouse_cls_giantgrin";
	
	// Outro - Truck Call Out
	level.scr_sound[ "generic" ][ "safehouse_trk_choppersarehere"  ] = "safehouse_trk_choppersarehere";
	level.scr_sound[ "generic" ][ "safehouse_trk_movemovemove"	   ] = "safehouse_trk_movemovemove";
	level.scr_sound[ "generic" ][ "safehouse_trk_alphateamwaiting" ] = "safehouse_trk_alphateamwaiting";
	level.scr_sound[ "generic" ][ "safehouse_trk_getonchopper"	   ] = "safehouse_trk_getonchopper";
}

fx()
{
	// Misc. NPC fx
	level._effect[ "welding_runner" ]								= loadfx( "fx/misc/welding_runner" );
	
	// Torture Room fx
	level._effect[ "jumper_cables" ]								= loadfx( "fx/misc/jumper_cable_sparks" );
}


// Notetrack Functions
jumper_cable_fx( cables )
{
	playFXOnTag( getfx( "jumper_cables" ), cables, "j_jcable_clamp02_head_ri" );
}