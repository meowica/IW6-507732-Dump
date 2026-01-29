#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\clockwork_code;
#include animscripts\utility;

clockwork_intro_pre_load()
{
	flag_init( "intro_finished" );
	flag_init( "FLAG_swap_ally_heads" );
	flag_init( "FLAG_player_mask_anim" );
	//intro flags
	flag_init("delete_ambush_jeep2");
	flag_init("ally_checkpoint_approach");
	flag_init("FLAG_attach_keegan_helmet");
	flag_init("flag_intro_baker_exit");
	flag_init("flag_intro_cipher_exit");
	flag_init("flag_intro_keegan_exit");
	flag_init("trigger_spotlight_b");
	flag_init("FLAG_obj_enterbase");
	flag_init("FLAG_obj_enterbase_complete");
	flag_init("destroy_player_intro");
	flag_init("start_watch_anim");
	flag_init("checkpoint_vo_rook_shoot");
	flag_init( "start_enemies_provoked_early" );
	flag_init("ok_shoot_radio");
	flag_init( "checkpoint_taken"		);
	flag_init( "player_at_checkpoint"	);
	flag_init("intro_destroy_player_off");
	flag_init("start_ambush_scene");
	flag_init("start_ambush_scene_enemies");
	flag_init("intro_text_done");
	flag_init("flag_intro_bodydrag_enemy");
	flag_init("start_spotlight_b");
	flag_init("ambush_destroy_player_off");
	flag_init("player_drag_body");
	flag_init("ambush_scene_started");
	flag_init("ambush_anim_finished");
	flag_init("introdrive_finished");
	flag_init("FLAG_obj_bodydrag");
	flag_init("FLAG_obj_bodydrag_complete");
	flag_init("FLAG_baker_bodydrag_complete");
	flag_init("FLAG_obj_getinjeep");
	flag_init("FLAG_obj_getinjeep_complete");	
	flag_init("FLAG_obj_pickupbags_complete");
	flag_init("entering_blackbird_vo");
	flag_init("start_intro_convoy");
	flag_init("player_looking_at_tower");
	flag_init( "bakerambush_finished" );
	flag_init( "cipherambush_finished" );
	flag_init( "keeganambush_finished" );
	flag_init("start_enemies_weaponsfree");
	flag_init("ally_dead");
	flag_init("spawn_checkpoint_guards");
	flag_init("bodydrag1_fakedead");
	flag_init("bodydrag2_fakedead");
	flag_init("bodydrag3_fakedead");
	flag_init("player_told_to_get_bags");
	flag_init("player_didnt_shoot_target");
	flag_init("FLAG_cipher_kicks_jeep");
	flag_init("btr_reverse_here");
	flag_init("allies_prep_lightsout");
	flag_init("FLAG_keegan_wave_jeep");
	flag_init("FLAG_baker_out_of_hut");
	flag_init("FLAG_enable_enter_jeep");
	flag_init("ambush_scene_shot");
	flag_init("ambush_scene_stab");
	flag_init("bulbs_parking");
	flag_init("FLAG_gunshot_drag");
	flag_init("FLAG_entrance_drones");
	flag_init("FLAG_player_failcase_tunnel");
	flag_init("btr_sees_playerdrag_body");
	flag_init("spotlight_track_player");
	flag_init("FLAG_intro_light_off");
	flag_init("ambush_player_timeout");
	flag_init("checkpoint_vo_tango");
	flag_init("lights_out");
	flag_init("ambush_scene_timeout");
	flag_init("FLAG_checkcheck");
	flag_init("tower_kill_ok");
	flag_init("checkpoint_taken2");
	flag_init("k_reached_ambush_anim");
	flag_init("c_reached_ambush_anim");
	flag_init("FLAG_take_the_rest");
	flag_init("FLAG_intro_jeeps_pull_away");
	
	
	//Knife kill flags
	flag_init("player_near_stab_guy");
	flag_init("player_looking_at_stab_guy");
	flag_init("player_in_position_for_stab_kill");
	flag_init("enable_stab");
	flag_init("intro_cp_radio");
	flag_init("FLAG_the_last_guy");
	//ride
	flag_init("start_watchsync_vo");
	flag_init("start_playerstand_reveal");
	
	//ambush flags
	flag_init("destroy_player_ambush");
	flag_init("start_ambush_vo");
	flag_init( "ambush_enemies_provoked" );
	flag_init( "ambush_finished"		 );
	flag_init( "ambush_stop_vo"			 );
	flag_init("quiet_kill_balcony_guy");
	
	flag_init("checkpoint_player_picks_target");
	
	
	//drive flags
	flag_init( "player_in_jeep"	   );
	flag_init( "start_intro_drive" );
	flag_init("FLAG_start_blackout_vo");
	
	
	//nvg related flags
	flag_init("nvg_gun_up");
	
	flag_init( "obj_optional_scientist_activated" );
	flag_init( "obj_optional_scientist_complete" );
}

//setup_intro()
//{
//	thread intro_display_introscreen();
//	level.start_point = "intro";
//	setup_player();
//	disable_trigger_with_targetname("TRIG_checkpoint_taken2");
//}

setup_intro2()
{	
	level.start_point = "intro2";
	setup_player();
	
	intro_display_introscreen();
	
	//thread maps\clockwork_audio::checkpoint_intro2();
	disable_trigger_with_targetname("TRIG_checkpoint_taken2");
}

//#using_animtree( "generic_human" );
setup_ambush()
{
	level.start_point = "start_ambush";
	setup_player();
	
	flag_set("checkpoint_taken");
	
	activate_trigger_with_targetname("checkpoint_taken_color_trig");

	disable_trigger_with_targetname("trig_get_in_jeep");
	
	
	//setup scenes
	level.pre_ambush_scene_org = getstruct( "ambush_scene_org", "targetname" );
	level.ambush_jeep_scene	   = getstruct( "ambush_jeep_scene", "targetname" );
	
	thread maps\clockwork_audio::checkpoint_start_ambush();

	spawn_allies();
	//setup_dufflebag_anims();
	
	foreach ( ally in level.allies )
	{
		ally.ignoreall	= 1;
		ally.ignoreme	= 1;
		//ally enable_cqbwalk();
		ally forceUseWeapon( "m14_scoped_silencer_arctic", "primary" );
	}
	
	thread cipher_ambush_approach(level.allies[2],"cipher","cipher_bag","ambush_approach","ambush_approach_loop",level.pre_ambush_scene_org);
	
	thread intro_ambush_vo();
	level.player.ignoreme	= 1;
	
	setup_bodydrag_startpoint();

	battlechatter_off();
	
	thread spawn_ambush_vehicles();
	thread player_failcase_tunnel();
	thread obj_enterbase();
	thread setup_optional_objective();
	flag_set("FLAG_obj_enterbase");
}

setup_checkpoint()
{
	level.start_point = "checkpoint";
	setup_player();
	
	//setup scenes
	level.pre_ambush_scene_org = getstruct( "ambush_scene_org", "targetname" );
	level.ambush_jeep_scene	   = getstruct( "ambush_jeep_scene", "targetname" );
	
	spawn_allies();
	//setup_dufflebag_anims();
	
	//disable_trigger_with_targetname("trig_player_stab");
	disable_trigger_with_targetname("trig_get_in_jeep");
	disable_trigger_with_targetname("TRIG_checkpoint_taken2");
	
	foreach ( ally in level.allies )
	{
		ally.ignoreall	= 1;
		ally.ignoreme	= 1;
		//ally enable_cqbwalk();
		ally forceUseWeapon( "m14_scoped_silencer_arctic", "primary" );
	}
	
	
	
	level.player.ignoreme	= 1;
	
	battlechatter_off();
	
	thread intro_checkpoint_vo();
	thread obj_enterbase();
	flag_set("FLAG_obj_enterbase");
	//thread blend_movespeedscale_custom(60,1);
	//thread player_dynamic_move_speed();
	
	level.checkpoint_patrol_anim = [];
	level.checkpoint_patrol_anim[0] = "patrol_walk";
	level.checkpoint_patrol_anim[1] = "walk_gun_unwary"; 

	level.ambush_recover_anim = [];
	level.ambush_recover_anim[0] = "ambush_enemy_react1";
	level.ambush_recover_anim[1] = "ambush_enemy_react2";
	level.ambush_recover_anim[2] = "ambush_enemy_react3";

	thread setup_optional_objective();
	
	wait .5;
	activate_trigger_with_targetname("TRIG_allies_goto_checkpoint");
	
}

//Guys have their disguised head setup in the character entry, so only the first checkpoint needs to worry about swapping them.
//Put on normal heads.
override_setup_headmodels_for_allies()
{	


	foreach(dude in level.allies)
	{
		head_model = dude.script_parameters;
		dude Detach(dude.headmodel, "");
		dude Attach( head_model, "", true );
		dude.headmodel = head_model;
	}
		
}

//Put on Disguised heads.
setup_disguise_for_allies()
{
	foreach(dude in level.allies)
	{
		head_model = dude.script_noteworthy;
		
		dude Detach( dude.headmodel , "" );
		dude Attach( head_model, "", true );
		dude.headmodel = head_model;
	}	
}
begin_intro()
{	
	//maps\_blizzard::blizzard_level_set( "none" );
	
	spawn_allies();
	if( level.Console ) // our temp heads are crashing the PC- only do it for consoles until we get final heads.
		override_setup_headmodels_for_allies();


	//setup_dufflebag_anims();
	
	foreach ( ally in level.allies )
	{
		ally.ignoreall	= 1;
		ally.ignoreme	= 1;
		ally enable_cqbwalk();
		ally.disable_sniper_glint = true;
	}
	//disable_trigger_with_targetname("trig_player_stab");
	disable_trigger_with_targetname("trig_get_in_jeep");
	level.player.ignoreme	= 1;

	flag_wait("intro_text_done");
		
	level.checkpoint_patrol_anim = [];
	level.checkpoint_patrol_anim[0] = "patrol_walk";
	level.checkpoint_patrol_anim[1] = "walk_gun_unwary";

	level.ambush_recover_anim = [];
	level.ambush_recover_anim[0] = "ambush_enemy_react1";
	level.ambush_recover_anim[1] = "ambush_enemy_react2";
	level.ambush_recover_anim[2] = "ambush_enemy_react3";

	thread setup_optional_objective();
	
	//Wait for this section to finish.
	flag_wait( "intro_finished" );
}


begin_checkpoint()
{
	
}

begin_ambush()
{
	thread prepare_ambush();
	thread intro_drive();
	//disable_trigger_with_targetname("trig_player_stab");
	disable_trigger_with_targetname("trig_get_in_jeep");
	flag_wait("introdrive_finished");
}

//////// INTRO SCRIPTING ////////////
//
//
//
//
/////////////////////////////////////

intro_display_introscreen()
{
	thread endOnDeath();
	intro_screen_create( &"CLOCKWORK_INTROSCREEN_LINE_1", &"CLOCKWORK_INTROSCREEN_LINE_5", &"CLOCKWORK_INTROSCREEN_LINE_2" ); //&"CLOCKWORK_INTROSCREEN_LINE_2"
	level.intro_black = thread maps\clockwork_code::introscreen_generic_black_fade_in_on_flag("start_watch_anim",2.5);
	level.player FreezeControls( true );
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	
	thread intro_anims();
	thread obj_enterbase();
	//thread swap_ally_heads();
	
	thread spawn_convoy();
	
	
	level.player FreezeControls( false );

	flag_set("intro_text_done");
	
}

player_intro_anims( anim_root, anim_name, player_link, weapons )
{
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	
	player_arms = spawn_anim_model( "player_rig" );
	watch = spawn_anim_model( "player_rig" );
	watch SetModel( "clk_watch_viewhands" );

	thread watch_light_fx( player_arms, watch );
	thread watch_tick( watch );
				
	player_arms Show();
	watch Show();
	level.player PlayerLinkToDelta( player_arms, "tag_player", 1.0, 30, 12, 30, 30, true );
	
	anim_root thread anim_single_solo( watch, anim_name );
	anim_root anim_single_solo( player_arms, anim_name );
	
	player_arms Hide();
	watch Hide();
	
	level.player GiveWeapon( "helmet_goggles" );
	level.player SwitchToWeapon( "helmet_goggles" );
	
	wait 2.467;
	
	foreach ( weapon in weapons )
		level.player GiveWeapon( weapon );
	
	level.player SwitchToWeapon( "m14_scoped_silencer_arctic" );
	level.player TakeWeapon( "helmet_goggles" );
	
	level.player PlayerLinkToBlend( player_link, "J_prop_1", 1.0 );
	wait 1.0;
		
	level.player Unlink();
	player_arms Delete();
	watch Delete();
}

intro_anims()
{
	thread maps\clockwork_audio::intro_black();
	scene = getstruct("intro2_start","targetname");
	player_link = spawn_anim_model( "player_view" );
	scene anim_first_frame_solo( player_link, "clock_prepare" );
	weapons = level.player GetWeaponsListPrimaries();
	foreach ( weapon in weapons )
		level.player TakeWeapon( weapon );

	wait 1.5;
	
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_time" );
	
	thread player_intro_anims( scene, "watch_sync_intro", player_link, weapons );
	thread intro_anims_enemies();
	thread maps\clockwork_audio::intro_watch();
	level.allies[0] thread handle_baker_intro_anim(scene, player_link);
	level.allies[1] thread handle_keegan_intro_anim(scene);
	level.allies[2] thread handle_cipher_intro_anim(scene);
	
	foreach(ally in level.allies)
	{
		ally forceUseWeapon( "m14_scoped_silencer_arctic", "primary" );
	}
	
	wait 1;
	flag_set("start_watch_anim");
	

	level.allies[2] char_dialog_add_and_go( "clockwork_cyr_2235" );
	
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_uniforms" );
	
	//level.allies[0] thread char_dialog_add_and_go( "clockwork_bkr_syncwatches" );
	
	level.allies[0] thread char_dialog_add_and_go( "clockwork_bkr_moveout" );
	
	flag_set("FLAG_obj_enterbase"); 
	
	foreach(ally in level.allies)
	{
		ally enable_cqbwalk();
	}

	wait 5;
	
	flag_set("start_intro_convoy");

	thread player_failcase_tunnel();
	wait 1.5;

	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_jeeppatrol" );
	level thread maps\_introscreen::introscreen( true );
	thread intro_checkpoint_vo();
}

handle_baker_intro_anim( scn, player_link )
{
	level.allies[0].animname = "baker";
//	baker_mask = spawn_anim_model("baker_mask");
	player_mask = spawn_anim_model("player_mask");                   
	
//	thread hide_at_end_anim(baker_mask);
	thread hide_at_end_anim(player_mask);
	
	arr = array(player_link,level.allies[0]);

	scn thread anim_single_solo( player_mask, "clock_prepare" );
//	scn thread anim_single_solo( baker_mask, "clock_prepare" );
	
	scn anim_single(arr, "clock_prepare");
	
	/*
	scn thread anim_loop_solo(self,"clock_prepare_loop");
	flag_wait_or_timeout("flag_intro_baker_exit",1);
	scn notify("stop_loop");
	scn thread anim_single_solo(self, "clock_prepare_exit");
	*/
	
	activate_trigger_with_targetname("baker_intro_color");
}

handle_keegan_intro_anim( scn )
{
	level.allies[1].animname = "keegan";
	scn thread anim_single_solo(self, "clock_prepare");
	
	//flag_wait("FLAG_attach_keegan_helmet");
	
	
	
	activate_trigger_with_targetname("kb_intro_color");
}

handle_cipher_intro_anim( scn )
{
	level.allies[2].animname = "cipher";

	scn anim_single_solo(self, "clock_prepare");
	//scn thread anim_loop_solo(self,"clock_prepare_loop");
	
	//flag_wait("flag_intro_cipher_exit");

	//scn notify("stop_loop");
		
	//scn thread anim_single_solo(self, "clock_prepare_exit");
	activate_trigger_with_targetname("intro_allymove_jeep");
}


//ally_run_across_road()
//{
//	trigger = getent("trig_run_across_road","targetname");
//	
//	for(;;)
//	{
//		trigger waittill("trigger", guy);
//		guy cqb_walk("off");
//	}
//}
//
//ally_resume_cqb()
//{
//	trigger = getent("trig_return_cqb","targetname");
//	trigger waittill("trigger");
//	foreach(dude in level.allies)
//	{
//		dude enable_cqbwalk();
//	}
//
//}

hide_at_end_anim(ent)
{
	ent waittillmatch("single anim","end");
	if(ent.animname == "player_mask" )
	{
		if( level.Console ) // our temp heads are crashing the PC- only do it for consoles until we get final heads.
		setup_disguise_for_allies();
		
	}
	ent Delete();
}

intro_anims_enemies()
{
	scene = getstruct("intro2_start","targetname");
	//guys = array_spawn_targetname("snowmobile_intro_enemies");
	
	guy1 = spawn_anim_model( "sm_body1",scene.origin );
	guy1.animname = "sm_body1";
	guy2 = spawn_anim_model( "sm_body2",scene.origin );
	guy2.animname = "sm_body2";
	guy3 = spawn_anim_model( "sm_body3",scene.origin );
	guy3.animname = "sm_body3";
	
	scene thread anim_first_frame_solo( guy1,"clock_prepare_bodies" );
	scene thread anim_first_frame_solo( guy2,"clock_prepare_bodies" );
	
	waitframe();

	flag_wait("flag_intro_keegan_exit");
	
	scene anim_single_solo( guy3,"clock_prepare_bodies" );

}

//intro_anims_player()
//{
//	//flag_wait("FLAG_player_mask_anim");
//
//	level.intro_player_arms = spawn_anim_model( "player_rig" );
//	level.intro_player_arms SetModel( "viewmodel_helmet_goggles" );
//	level.intro_player_arms.animname = "player_rig";
//	level.intro_player_arms show();
//	level.player PlayerLinkToDelta( level.intro_player_arms, "tag_player", 0.5, 30, 12, 30, 30, false );
//
//	level.player thread anim_single_solo( level.intro_player_arms, "clock_player_intro_mask");
//	
//	
//	black = create_overlay_element( "black", 0 );
//	black fadeovertime( 5 );
//	black.alpha = 1;
//	//thread hud_hide();
//	
//			
//			
//	wait 2;
//	
//	black fadeovertime( 1 );
//	black.alpha = 0;
//	
//	level.player Unlink();
//	level.intro_player_arms Delete();
//	level.player EnableWeapons();
//	level.player EnableOffhandWeapons();
//	
//}

//////// END INTRO SCRIPTING ////////
//
//
//
//
/////////////////////////////////////



//////// CHECKPOINT COMBAT SCRIPTING ////////
//
//
//
//
/////////////////////////////////////////////
setup_checkpoint_combat()
{
	flag_wait("spawn_checkpoint_guards");
	
	thread player_failcase_tunnel();
	
	//setup scenes
	level.pre_ambush_scene_org = getstruct( "ambush_scene_org", "targetname" );
	level.ambush_jeep_scene	   = getstruct( "ambush_jeep_scene", "targetname" );

	
	array_spawn_function_targetname( "introcp_guy_radio", ::handle_radio_alert ); 
	array_spawn_function_targetname( "introcp_guys_tower", ::handle_tower_alert );
	array_spawn_function_targetname( "introcp_guys_remaining", ::handle_remaining_alert );
	
	//make sure special case guys pass the player shot notify, set them up.
	array_spawn_function_targetname( "intro_bodydrag_enemy", ::handle_remaining_alert );
	array_spawn_function_targetname( "intro_bodydrag2_enemy", ::handle_remaining_alert );
	array_spawn_function_targetname( "balcony_death_guy", ::handle_remaining_alert );
	
	array_spawn_function_noteworthy("checkpoint_patrollers", ::checkpoint_patrol, true);
	
	thread handle_radiotower_guy(); //spawn in radiotower guy and set him up for scene
		
	level.introcp_guys_tower	= array_spawn_targetname( "introcp_guys_tower", 1 );
	level.introcp_guys_remaining	= array_spawn_targetname( "introcp_guys_remaining", 1 );
	
	level.special_death_guys = [];
	
	thread handle_balcony_death();
	
	wait 2;
	
	thread handle_player_bodydrag_death();
	thread handle_keegandrag_death();

}

handle_radiotower_guy()
{
	level.introcp_guy_radio		= spawn_targetname( "introcp_guy_radio", 1 );
	level.introcp_guy_radio.animname = "radioguy";
	level.introcp_guy_radio.allowdeath = true;
	level.introcp_guy_radio gun_remove();
	
	radio = Spawn( "script_model", ( 0, 0, 0 ) );
	radio SetModel( "com_hand_radio" );
	radio LinkTo( level.introcp_guy_radio, "tag_weapon_left", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	binoc = Spawn( "script_model", ( 0, 0, 0 ) );
	binoc SetModel( "weapon_binocular" );
	binoc LinkTo( level.introcp_guy_radio, "tag_weapon_right", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	level.pre_ambush_scene_org thread anim_loop_solo(level.introcp_guy_radio, "lookout");
	
	flag_wait("start_enemies_provoked_early");
	
	if ( IsDefined( level.introcp_guy_radio ) && IsAlive( level.introcp_guy_radio ) )
		MagicBullet( level.allies[ 2 ].weapon, level.allies[ 2 ] GetTagOrigin( "tag_flash" ), level.introcp_guy_radio GetTagOrigin( "j_head" ) );
}

intro_checkpoint_vo()
{
	thread setup_checkpoint_combat();
	thread checkpoint_combat_failsafe();
	thread radio_tower_guy_shot();
	thread ally_checkpoint_approaches();
	
	level endon("start_enemies_provoked_early");
	
	flag_wait("spawn_checkpoint_guards");
	
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_checkpointsahead" );

	wait .4;
	
	radioguy = get_ai_group_ai("intro_cp_radio");
	
	radio_dialog_add_and_go("clockwork_diz_northernridge");
	
	wait 1;
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_copyall" );
	
	wait 1;
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_quicklyandquietly" );
	
	flag_wait("checkpoint_vo_tango");
	
	//flag_clear("player_dynamic_move_speed");
	
	thread autosave_by_name( "checkpoint" );
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_count8" );
	
	flag_wait("checkpoint_vo_rook_shoot");
	
	thread look_for_last_guy();
	
	flag_wait("FLAG_the_last_guy");
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_thereheis" );
	//thread add_dialogue_line("Baker","There he is, exiting the near building.  We’re good to go.");

	flag_set("ok_shoot_radio");
	
	if( IsDefined(level.introcp_guy_radio) && IsAlive(level.introcp_guy_radio))
	{
		level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_bestshot" );
		thread look_at_tower_early_vo();
	}
	thread handle_radio_tower_kill();
	
	flag_wait("intro_cp_radio");
	
	foreach(guy in level.introcp_guys_tower)
	{
		guy thread handle_com_tower_kill();
	}
	
	wait 1.5;
	
	level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_totheleft" );
	
	thread look_at_tower_vo();
	thread look_at_tower_vo_timeout();
	
	flag_wait("player_looking_at_tower");
	
	thread cipher_keegan_tower_kill();
	
	thread vo_tower_shoot();

	flag_set("tower_kill_ok");
	

	waittill_aigroupcleared("intro_cp_tower");
	level notify("disable_combat_failsafe");
	foreach(guy in level.introcp_guys_remaining)
	{
		if ( IsDefined( guy ) )
		{
			guy thread handle_remaining_kill();
			guy thread alert_enemies();
		}
	}
	
	foreach(guy in level.special_death_guys)
	{
		if ( IsDefined( guy ) )
		{
			guy thread handle_remaining_kill();
			guy thread alert_enemies();
		}
	}
	
	thread handle_checkpoint_end_condition();
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_splash3" );
	
	waitframe();
	
	thread remaining_kill();
	
	level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_pickatarget" );
	//thread add_dialogue_line("Baker","Rook, take a target below, well take the rest...");
	
	waittill_aigroupcleared("intro_cp_remaining");
	//wait 3.5;
	
}

ally_checkpoint_approaches()
{
	level endon("start_enemies_provoked_early");

	flag_wait("ally_checkpoint_approach");
	
	foreach(guy in level.allies)
	{
		guy cqb_walk( "on" );
	}
	
	thread approach_anims(level.allies[0],"baker", "checkpoint_approach", "checkpoint_approach_loop", level.pre_ambush_scene_org);
	thread approach_anims(level.allies[1],"keegan", "checkpoint_approach", "checkpoint_approach_loop", level.pre_ambush_scene_org);
	thread cipher_approach_anims(level.allies[2],"cipher", "checkpoint_approach", "checkpoint_approach_loop", level.pre_ambush_scene_org);
	
}

approach_anims(guy, animname, anime, loopanime, scene)
{
	level endon("cancel_approach_anims");
	
	guy disable_ai_color();	
	guy.animname = animname;
	
	scene anim_reach_solo(guy,anime);
	scene anim_single_solo(guy, anime);
	scene thread anim_loop_solo(guy, loopanime,"stop_loop");
	guy thread handle_approach_anims_end( scene );

}

handle_approach_anims_end( scene )
{
	flag_wait_any("intro_finished","start_enemies_provoked_early");
	self enable_ai_color();
	scene notify("stop_loop");
	self anim_stopanimscripted(); 	
}

cipher_approach_anims(guy, animname, anime, loopanime, scene)
{
	level endon("cancel_approach_anims");
	
	guy disable_ai_color();	
	guy.animname = animname;
	
	scene anim_reach_solo(guy,anime);
	scene anim_single_solo(guy, anime);
	scene thread anim_loop_solo(guy, loopanime,"stop_loop");
	guy thread handle_ciper_approach_anims_end( scene );

}

handle_ciper_approach_anims_end( scene )
{
	flag_wait_any("intro_finished","start_enemies_provoked_early");
	
	if(flag("start_enemies_provoked_early"))
	{
		self enable_ai_color();
	}

	scene notify("stop_loop");
	self anim_stopanimscripted(); 
}

cipher_ambush_approach(guy, guyanimname, baganimname, anime, loop, scene)
{
	scene anim_reach_solo(guy,anime);
	guy.animname = guyanimname;

	scene anim_single_solo(guy, anime);
	level notify("c_reached_ambush_anim");
	flag_set("c_reached_ambush_anim");
	
	//If keegan has not yet reached his anim start... start Cyphers loop.
	if(!flag("k_reached_ambush_anim"))
		scene thread anim_loop_solo(guy, loop,"stop_loop");
	
	
	level waittill("k_reached_ambush_anim");
	
	scene notify("stop_loop");
	guy anim_stopanimscripted(); 

}



vo_tower_shoot()
{
	wait .5;
	
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_takethemiddle" );
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_takethemiddle2" );
	flag_set("FLAG_take_the_rest");
}

radio_tower_guy_shot()
{
	level endon("start_enemies_provoked_early");
	
	flag_wait("intro_cp_radio");
	if(flag("ok_shoot_radio"))
	{
	wait .25;
	level.allies[2] char_dialog_add_and_go("clockwork_kgn_hesdown" );
	wait 1.5;
}

	if(!flag("ok_shoot_radio"))
	{
		flag_set("start_enemies_provoked_early");
	}
	
}

handle_checkpoint_end_condition()
{
	flag_wait_all("bodydrag1_fakedead","bodydrag2_fakedead","bodydrag3_fakedead");
	
	battlechatter_off();
	thread maps\clockwork_audio::pre_ambush();
	thread spawn_ambush_vehicles();
	
	flag_set( "intro_finished" );
	flag_set( "checkpoint_taken" );	
	activate_trigger_with_targetname("checkpoint_taken_color_trig");
	enable_trigger_with_targetname("TRIG_checkpoint_taken2");
	
	//cipher has a custom approach and loop to wait for keegan to begin anim.
	thread cipher_ambush_approach(level.allies[2],"cipher","cipher_bag","ambush_approach","ambush_approach_loop",level.pre_ambush_scene_org);
	thread intro_ambush_vo();
	
	thread autosave_by_name( "checkpoint_clear" );
	

	level.allies[0] enable_ai_color();
	level.allies[1] enable_ai_color();
	
}

look_at_tower_early_vo()
{
	level endon("player_shot_someone_on_radio");
	level endon("player_shot_target_on_tower");
	level endon("player_shot_someone_on_tower");
	level endon("start_enemies_provoked_early");
	
	towerorg = GetEnt("towerorg","targetname");
	
	while( 1 )
	{
		if( level.player isADS() && level.player adsbuttonpressed() )
		{
			towerorg waittill_player_lookat_for_time( 2, 0.98 );
			
			level.allies[0] char_dialog_add_and_go("clockwork_bkr_talltower");
			//thread add_dialogue_line( "Baker","Rook, the radio tower... to the right." );
			
			wait 3;
		}
		
		wait .25;
	}

}

look_for_last_guy()
{
	thread look_for_last_guy_timeout();
	
	level endon("last_guy_out_building");
	level endon("player_shot_someone_on_radio");
	
	lastguyorg = GetEnt("lastguyorg","targetname");
	
	while( 1 )
	{
		lastguyorg waittill_player_lookat_for_time( 0.6, 0.98 );
		flag_set("FLAG_the_last_guy");
			
		wait 2;
		break;
	}
}

look_for_last_guy_timeout()
{
	wait 3;
	flag_set("FLAG_the_last_guy");
	level notify("last_guy_out_building");
}

look_at_tower_vo()
{
	level endon("player_shot_someone_on_tower");
	level endon("player_shot_target_on_tower");
	level endon("player_looking_at_tower");
	level endon("start_enemies_provoked_early");
	
	lookat = cos(7);
	
	towerorg = GetEnt("towerorg","targetname");
	
	towerorg waittill_player_lookat_for_time( .5, lookat );
	flag_set("player_looking_at_tower");
}

look_at_tower_vo_timeout()
{
	level endon("start_enemies_provoked_early");
	wait 7;
	flag_set("player_looking_at_tower");
	level notify("player_looking_at_tower");
}

checkpoint_combat_failsafe()
{
	level endon( "player_shot_someone_on_tower" );
	level endon( "player_shot_target_on_tower" );
	level endon( "disable_combat_failsafe" );
	//create an endon for when allies finish shooting enemies on tower
	
	flag_wait( "start_enemies_provoked_early");
	//for various endons
	level notify("going_in_hot");
	level notify("cancel_approach_anims");
	
	activate_trigger_with_targetname("inhot_color_trig");
	
	flag_set("FLAG_intro_jeeps_pull_away");//hack for if the player goes in hot before setting world flag, this ensures the jeeps pull away.
	
	level notify("start_enemies_provoked_early");
	
	level.allies[0] StopSounds();
	
	waitframe();
	
	level.allies[0] thread char_dialog_add_and_go( "clockwork_bkr_goinginhot" );
	
	flag_set("FLAG_the_last_guy");
	
	remaining_enemies = GetAIArray("axis");
	foreach(guy in remaining_enemies)
	{
		if (IsDefined(guy) && IsAlive(guy) && !IsDefined(guy.fake_dead))
		{
			guy thread alert_enemies_early();
		}
	}
	
	group1 = get_ai_group_ai("intro_cp_radio");
	group2 = get_ai_group_ai("intro_cp_tower");
	group3 = get_ai_group_ai("intro_cp_remaining");
	group4 = get_ai_group_ai("intro_cp_specialcase");
	
	arrComb1 = array_combine(group1, group2);
	arrComb2 = array_combine(group3, group4);
	arrCombFinal = array_combine(arrComb1, arrComb2);
	
	wait 1.5;
	
	thread attack_targets( level.allies, arrCombFinal, 3, 4.5, true );
	
	waittill_aigroupcleared("intro_cp_radio");
	waittill_aigroupcleared("intro_cp_tower");
	waittill_aigroupcleared("intro_cp_remaining");
	
	thread handle_checkpoint_end_condition();
}



handle_radio_tower_kill()
{
	level endon( "player_shot_someone_on_radio" );
	level endon("start_enemies_provoked_early");
	
	//level.player waittill( "weapon_fired" );
	
	self waittill( "damage", damage, attacker );
	
	if( attacker == level.player )
	{
		level notify( "player_shot_someone_on_radio" );
		
	}
}

handle_com_tower_kill()
{
	level endon( "player_shot_someone_on_tower" );
	level endon( "player_shot_target_on_tower" );
	level endon("start_enemies_provoked_early");
	
	self waittill( "damage", damage, attacker );
	
	if( attacker == level.player )
	{
		if( ( IsDefined(self.script_noteworthy) ) && ( self.script_noteworthy == "tower_player_target"))
		{
			level notify( "player_shot_target_on_tower" );
		}
		else
		{
			level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_payattention" );
			level notify( "player_shot_someone_on_tower" );
			
		}
	}
	else	
	{
			level notify("keegan_cipher_shoot_timeout");
	}
}

handle_remaining_kill()
{
	level endon( "player_shot_someone_in_remaining" );
	level endon("start_enemies_provoked_early");
	
	//level.player waittill( "weapon_fired" );
	
	self waittill( "damage", damage, attacker );
	
	if( attacker == level.player ) 
	{
		level notify( "player_shot_someone_in_remaining" );
	}		
	
}

cipher_keegan_tower_kill()
{
	level endon("start_enemies_provoked_early");
	
	//thread player_fired_weapon();
	waittill_any_notify_or_timeout("player_shot_gun","player_shot_someone_on_tower","player_shot_target_on_tower", 9);

	if(!flag("tower_kill_ok") && !flag("start_enemies_provoked_early"))
	{
		flag_set("start_enemies_provoked_early");
	}
	
		level.allies[0] StopSounds();
		
		towerguys = get_ai_group_ai("intro_cp_tower");
		
		attack_targets(level.allies, towerguys, .5, .75, true, true);
		level notify("allies_shot_targets_tower");
	
}

//player_fired_weapon()
//{
//	level endon("allies_shot_targets_tower");
//	level.player waittill( "weapon_fired" );	
//	level notify("player_shot_gun");
//}

remaining_kill()
{
	remaining_enemies = get_ai_group_ai("intro_cp_remaining");//GetAIArray("axis");
	remaining_enemies_special = get_ai_group_ai("intro_cp_specialcase");
	
	arrComb = array_combine(remaining_enemies, remaining_enemies_special);
	
	waittill_notify_or_timeout("player_shot_someone_in_remaining", 4);
	flag_set("checkpoint_player_picks_target");
	attack_targets( level.allies, arrComb, .3, .6, true);
}

handle_radio_alert() //for the radio guy
{
	self.ignoreme = true;
	self.ignoreall = true;
	self.diequietly = true;
	self.health = 1;
	self thread handle_radio_tower_kill();
}

handle_tower_alert() //for the com tower guys
{
	self.health = 1;
	self.ignoreme = true;
	self.ignoreall = true;
	self.diequietly = true;
	self.reactingToBullet = false;
	self.disableBulletWhizbyReaction = true;
	self.disable_dive_whizby_react = true;
	
	
	if(IsDefined(self.script_noteworthy) && self.script_noteworthy == "tower_player_target")
	{
		self thread tower_tapglass_scene("tapglass_enemy_a");
	}
	
	if(IsDefined(self.script_noteworthy) && self.script_noteworthy == "tower_walkout_guy")
	{
		self thread tower_tapglass_scene("tapglass_enemy_b");
	}
	
	if(IsDefined(self.script_noteworthy) && self.script_noteworthy == "leanrailguy")
	{
		self.allowdeath = true;
		self.animname = "leanrailguy";
		level.pre_ambush_scene_org thread anim_loop_solo(self,"scnleanrailguy");
	}
	
	
	//self thread checkpoint_patrol( true );
	self thread handle_tower_enemy_provoked_early();
}

tower_tapglass_scene(scn)
{
	//flag_wait("player_looking_at_tower");
	self.allowdeath = true;
	self.animname = "generic";
	level.pre_ambush_scene_org thread anim_single_solo(self,scn);
}


handle_remaining_alert() //used for special case drag guys and remaining normal guys
{
	scene = level.pre_ambush_scene_org;
	
	if(IsDefined(self.script_noteworthy) && self.script_noteworthy == "spotlight_checkpoint_a")
	{
		self thread kill_on_failsafe();
		flag_wait("FLAG_the_last_guy");
	
		if(IsDefined(self) && IsAlive(self))
		{
			self.animname = "generic";
			guy = self;
			//self.allowdeath = true;
			level.pre_ambush_scene_org thread anim_single_solo(self,"spotlight_enemy_a");
			
			//ammo boxes animation
			joint = spawn_anim_model("cp_ammo_jt", scene.origin);
			
			ammo1 = spawn_anim_model( "cp_ammo_mdl", scene.origin );
			ammo1 linkto( joint , "J_prop_1" );
			
			ammo2 = spawn_anim_model( "cp_ammo_mdl", scene.origin );
			ammo2 linkto( joint , "J_prop_2" );
			
			scene thread anim_single_solo(joint, "cp_ammo_joint" );
			joint thread ammo_crate_failsafe( guy, ammo1, ammo2 );
		}
		
	}
	
	if(IsDefined(self.script_noteworthy) && self.script_noteworthy == "spotlight_checkpoint_b")
	{
		self thread handle_spotlight_enemy_b();
		self thread kill_on_failsafe();
	}
	
	if(IsDefined(self) && IsAlive(self))
	{
		self.alertlevel = "noncombat";
		self.ignoreme = true;
		self.ignoreall = true;
		self set_allowdeath(true);
		self thread handle_remaining_enemy_provoked_early();
	}
}

kill_on_failsafe()
{
	flag_wait_any("start_enemies_provoked_early","checkpoint_player_picks_target");
	
	wait RandomIntRange(1,2);
	
	if(IsDefined(self) && IsAlive(self))
	{
		MagicBullet( level.allies[ 2 ].weapon, level.allies[ 2 ] GetTagOrigin( "tag_flash" ), self GetTagOrigin( "j_head" ) );
	}
		
	wait 1;
	
	if(IsDefined(self) && IsAlive(self))
	{
		self Kill();
	}
}

ammo_crate_failsafe( guy, box1, box2 )
{
	flag_wait("drop_ammo_crates");
	
	self anim_stopanimscripted();
	guy anim_stopanimscripted();
	scale = randomfloatrange( 10, 100 );
	
	box1_vec = vectorNormalize( (box1.origin -1 ) - box1.origin );
	box1 unlink();
	box1 PhysicsLaunchClient( box1.origin, box1_vec * scale );
		
	box2_vec = vectorNormalize( (box2.origin -1 ) - box2.origin );
	box2 unlink();
	box2 PhysicsLaunchClient( box2.origin, box2_vec * scale );
	
}


handle_spotlight_enemy_b()
{
	self endon("death");
	
	scene = level.pre_ambush_scene_org;
	self.animname = "generic";
	scene thread anim_loop_solo(self,"spotlight_enemy_b_loop","stop_spotlight_enemy_b_loop");
	
	joint = spawn_anim_model("cp_light_jt", scene.origin );
		
	stand = spawn_anim_model( "cp_stand_mdl", scene.origin );
	stand linkto( joint , "J_prop_2" );
		
	light = spawn_anim_model( "cp_light_mdl",scene.origin );
	light linkto( joint , "J_prop_1" );
	
	scene thread anim_first_frame_solo(joint, "cp_light_joint" );
	
	flag_wait("start_spotlight_b"); //notetrack flag to start light move animations.
	
	scene notify("stop_spotlight_enemy_b_loop"); //make sure loop is ended.
	
	scene thread anim_single_solo(joint, "cp_light_joint" );
	
	if(IsDefined(self) && IsAlive(self))
	{
		scene thread anim_single_solo(self,"spotlight_enemy_b");
	}
	//joint thread stop_spotlight_move();
	
}

//stop_spotlight_move()
//{
//	flag_wait("start_enemies_provoked_early");
//	self anim_stopanimscripted();
//}
//handle_remaining_enemies() //anim handling for the remaining dudes
//{
//	self waittill("player_shot_someone_in_remaining");
//	
//	wait .2;
//	
//	if(!self.special_case)
//	{
//		recover_anim = level.ambush_recover_anim[randomint(level.ambush_recover_anim.size)];
//		self thread anim_generic(self, recover_anim);
//		self set_allowdeath(true);
//	}
//}

alert_enemies()
{
	self endon("death");
	
	//wait(RandomIntRange(.5, .75));
	self clear_run_anim();
	self.animname = "generic";
	recover_anim = level.ambush_recover_anim[randomint(level.ambush_recover_anim.size)];
	
	if( ( IsDefined(self.script_noteworthy) ) && ( self.script_noteworthy == "checkpoint_patrollers"))
	{
		self cqb_walk( "on" );
		self waittill("goal");
		self thread anim_single_solo(self, recover_anim);
		self set_allowdeath(true);
		self waittillmatch("anim single","end");
		self thread anim_loop_solo( self,"nvg_recover_anim1");
	}
	else
	{
		//self thread anim_single_solo(self, recover_anim);
		self set_allowdeath(true);
		self waittillmatch("anim single","end");
		self thread anim_loop_solo( self,"nvg_recover_anim1");
		
	}

	wait 2;
	
	self.baseaccuracy = 1;
	self.ignoreall = 0;
	self.ignoreme = 0;
	self.grenadeawareness = 0;
	self set_moveplaybackrate(1);	
	level.player set_ignoreme(false);
	
	self.ignoreall = false;
	self.disablearrivals = 0;
	self.disableexits = 0;
}

alert_enemies_early() //anim handling for the remaining dudes
{
	self endon("death");
	
	self anim_stopanimscripted();
	
	self.baseaccuracy = 1;
	self.ignoreall = 0;
	self.ignoreme = 0;
	self.grenadeawareness = 0;
	self set_moveplaybackrate(1);	
	

	foreach(ally in level.allies)
	{
		ally.ignoreall = false;
		ally.ignoreme = false;
		ally.accuracy = 0.8;
	}
	
	level.player set_ignoreme(false);
	
}

handle_tower_enemy_provoked_early()
{	
	level endon( "player_shot_someone_on_tower" );
	level endon( "player_shot_target_on_tower" );
	level endon( "allies_shot_targets_tower" );
	level endon("disable_combat_failsafe");
	
	//level endon( "remove_enemy_tower_provoked_early" );
	
	//self endon("death");
	
	self AddAIEventListener( "grenade danger" );
	self AddAIEventListener( "projectile_impact" );
	self AddAIEventListener( "bulletwhizby" );
	self AddAIEventListener( "gunshot" );
	self AddAIEventListener( "explode" );
	//self AddAIEventListener( "death" );
	    
	self waittill_any( "ai_event", "flashbang" );
	wait .25;
	flag_set( "start_enemies_provoked_early" );	
	self StopAnimScripted();
	self.ignoreall = false;
	self.ignoreme  = false;
	
}

someone_please_kill_me_now()
{
	level endon( "player_shot_someone_on_tower" );
	level endon( "player_shot_target_on_tower" );
	level endon("allies_shot_targets_tower");
	level endon("disable_combat_failsafe");
	
	self waittill("damage");
	flag_set( "start_enemies_provoked_early" );	
}

handle_remaining_enemy_provoked_early()
{	
	self endon("damage");
	level endon( "player_shot_someone_on_tower" );
	level endon( "player_shot_target_on_tower" );
	level endon("allies_shot_targets_tower");
	level endon("disable_combat_failsafe");
	
	//self endon("death");

	self AddAIEventListener( "grenade danger" );
	self AddAIEventListener( "projectile_impact" );
	self AddAIEventListener( "bulletwhizby" );
	self AddAIEventListener( "gunshot" );
	self AddAIEventListener( "explode" );
	//self AddAIEventListener( "silenced_shot" );
	//self AddAIEventListener( "death" );
	self thread someone_please_kill_me_now();
	self waittill_any( "ai_event", "flashbang","death","going_in_hot" );
	flag_set( "start_enemies_provoked_early" );
	//waitframe();
	
	self anim_stopanimscripted();
	self.ignoreall = false;
	self.ignoreme  = false;
	
	
}

//////// END CHECKPOINT COMBAT SCRIPTING ////
//
//
//
//
/////////////////////////////////////////////

spawn_convoy()
{
	flag_wait("start_intro_convoy");
	
	thread maps\clockwork_audio::jeeps_by();
	
	convoyjeep1 = spawn_vehicle_from_targetname_and_drive( "convoyjeep1" );
	convoyjeep1 maps\_vehicle::vehicle_lights_on( "running");
	wait 2;

	convoyjeep2 = spawn_vehicle_from_targetname_and_drive( "convoyjeep2" );
	convoyjeep2 maps\_vehicle::vehicle_lights_on( "headlights");
	
	
	vehs = [];
	vehs[0] = convoyjeep1;
	vehs[1] = convoyjeep2;
	
	array_thread( vehs, ::damage_watcher_intro );
	array_thread( vehs, ::destroy_player_intro );
}

prepare_ambush()
{
	flag_wait( "checkpoint_taken2" );
	
	foreach ( ally in level.allies )
	{
		ally.ignoreall	= 1;
		ally.ignoreme	= 1;
		ally disable_cqbwalk();
	}
	level.player.ignoreme	= 1;
	
	

	thread obj_bodydrag();
	thread obj_getinjeep();
	//Que up ambush scene
	thread start_ambush_scene();
	
	level.allies[0].animname = "baker";
	level.allies[1].animname = "keegan";
	level.allies[2].animname = "cipher";

	init_animated_dufflebags();

	//Bakers thread
	thread handle_baker_ambush_anims( level.pre_ambush_scene_org, level.allies[0], "clock_intro", level.bags[0], level.intro_balcony_guy, undefined); //FLAG_baker_bodydrag_complete
	
	//thread ally_reach_and_start_scene( level.pre_ambush_scene_org, level.allies[1], "clock_intro", level.bags[2], undefined, undefined );
	
	cipherandkeegan = [];
	cipherandkeegan[0] = level.allies[1];//keegan
	cipherandkeegan[1] = level.allies[2];//cipher
	
	c_and_k_bags = [];
	c_and_k_bags[0] = level.bags[1];
	c_and_k_bags[1] = level.bags[2];
	
	//Ally thread
	
	thread allies_reach_and_start_scene( level.pre_ambush_scene_org, cipherandkeegan, "clock_intro", c_and_k_bags, level.intro_keegandrag_guy, undefined );
	
	
}

handle_baker_ambush_anims( org, ally, anime, bag, body, flag_to_set )
{
	level endon("ambush_player_shot");
	level endon("ambush_player_kill");
	level endon("ambush_keegan_kill");
	level endon("player_knifes_driver");
	//level endon("destroy_player_ambush");
	
	//ally set_moveplaybackrate(1.33);
	org anim_reach_solo( ally, anime );	
	
	thread player_stab_driver();
	
	thread maps\clockwork_audio::baker_drag_body1();
	
	actors = [];
	
	actors[0] = ally;
	actors[1] = bag;
	
	actors[0].animname = "baker";
	actors[1].animname = "baker_bag";
	
	if(IsDefined( body ))
	{
		actors = add_to_array( actors, body );
	}

	//hard detatch bags to allow anims
	ally hide_dufflebag();
	
	org anim_single( actors, "clock_intro" );
	
	if(body == level.intro_balcony_guy )
	{
		level.intro_balcony_guy thread kill_guy_at_end_of_anim();
	}
	
	if(IsDefined(flag_to_set))
	{
		flag_set( flag_to_set );
	}
	
	//ally set_moveplaybackrate(1);
	
	//in the hut loop scene
	org thread anim_loop( actors, "clock_ambush_hut_wait","stop_clock_ambush_hut_wait");
	
	flag_wait("FLAG_baker_out_of_hut");
	
	//stop his loop
	org notify("stop_clock_ambush_hut_wait");
	ally anim_stopanimscripted();
	
	waitframe();
	
	org anim_single_solo( actors[0], "clock_ambush_hut_walkout" );
}

//cipher and keegan bags scene
allies_reach_and_start_scene( org, allies, anime, bags, body, flag_to_set )
{	
	allies[0] thread  goto_anim_start_spot(anime, org);
	
	flag_wait_all("k_reached_ambush_anim","c_reached_ambush_anim");
	
	thread failsafe_c_k_bags( bags );
	
	actors = [];
	actors = array_combine(allies, bags);
	
	//if a body drag is needed, add the body here
	if(IsDefined( body ))
	{
		body.animname = "keegandrag";
		actors = add_to_array( actors, body );
	}	

	//hard detatch bags to allow anims
	hide_dufflebags();
	
	thread maps\clockwork_audio::foley_pre_ambush();
	wait .15;
	
	//play the scene on all actors.
	org thread anim_single( actors, "clock_intro" );
	
	level.intro_keegandrag_guy thread kill_guy_at_end_of_anim();
	
	foreach(dude in allies)
	{
		dude thread waittill_end_of_anim_for_loop( org, "clock_ambush_wait","stop_clock_ambush_wait");//stop_clock_ambush_wait
	}
}

goto_anim_start_spot( anime, org )
{
	org anim_reach_solo(self,anime);
	
	if(self.animname == "keegan")
	{
		level notify("k_reached_ambush_anim");
		flag_set("k_reached_ambush_anim");
	}
	
	if(self.animname == "cipher")
	{
		level notify("c_reached_ambush_anim");
		flag_set("c_reached_ambush_anim");
	}
}

failsafe_c_k_bags( bags )
{
	flag_wait("destroy_player_ambush");
	
	//handle failcase for all bags in scene so they dont animate.
	foreach(bag in bags)
	{	
		bag anim_stopanimscripted();
		bag hide();
		
		newbag = spawn_anim_model("keegan_bag", bag.origin); 
		//newbag = spawn_anim_model( "cp_ammo_mdl", bag.origin );
		
		newbag.animname = "keegan_bag";
		newbag.origin = bag.origin;
		
		
		
		scale = randomfloatrange( 10, 20 );	
		//bag_vec = vectorNormalize( (bag.origin -1 ) - bag.origin );
		bag_vec = ( 0, 0, -1 );
		//bag Unlink();
		wait .05;
		newbag PhysicsLaunchClient( newbag.origin, bag_vec * scale );
	}
}

//allies_stop_loop_anim( ender )
//{
//	self notify( ender );
//	waittillframeend;
//}

waittill_end_of_anim_for_loop( org, loop, ender )
{
	level endon("player_knifes_driver");
	level endon("destroy_player_ambush");
	level endon("ambush_player_shot");
	level endon("ambush_player_kill");
	level endon("ambush_keegan_kill");
	level endon("ambush_scene_start");
	
	self waittillmatch("single anim","end");
	org anim_loop_solo(self, loop, ender);
}


kill_guy_at_end_of_anim()
{
	self waittillmatch("single anim","end");
	self guy_silent_death();
}

obj_enterbase()
{
	flag_wait("FLAG_obj_enterbase");
	enterbase = obj( "enterbase" );

	Objective_Add( enterbase, "active", &"CLOCKWORK_OBJ_INTO_BASE" );
	Objective_Current( enterbase );
		
	flag_wait("FLAG_obj_enterbase_complete");
	
	objective_complete(enterbase);
}

obj_bodydrag()
{
	flag_wait("FLAG_obj_bodydrag");
	bodydrag = obj( "CleanupCheckpoint" );
	
	obj_position = GetEnt("obj_dragbody","targetname");

	Objective_Add( bodydrag, "active", &"CLOCKWORK_OBJ_CHECKPOINT" );
	Objective_Current( bodydrag );
	Objective_Position( bodydrag, obj_position.origin );
		
	flag_wait("FLAG_obj_bodydrag_complete");
	
	if(!flag("destroy_player_ambush"))
		objective_complete(bodydrag);
	
	
}

	
obj_getinjeep()
{
	flag_wait("FLAG_enable_enter_jeep");
	
	wait 2;
	
	enable_trigger_with_targetname("trig_get_in_jeep");
	
	level.gold_jeep_player_door = Spawn("script_model",level.jeep.origin);
	level.gold_jeep_player_door SetModel("chinese_brave_warrior_obj_door_back_LE");
	level.gold_jeep_player_door.angles = level.jeep.angles;
	level.gold_jeep_player_door LinkTo(level.jeep);
	//gold_jeep_player_door glow();
	
	getinjeep = obj( "getinjeep" );
	
	obj_position = GetEnt("obj_getinjeep","targetname");

	Objective_Add( getinjeep, "active", &"CLOCKWORK_OBJ_CHECKPOINT" );
	Objective_Current( getinjeep );
	//Objective_Position( getinjeep, obj_position.origin );
		
	flag_wait("FLAG_obj_getinjeep_complete");
	
	objective_complete(getinjeep);
}

obj_stabdriver()
{
	//flag_wait("FLAG_enable_enter_jeep");
	
	
	level.gold_jeep_stab_door = Spawn("script_model",level.jeep.origin);
	level.gold_jeep_stab_door SetModel("chinese_brave_warrior_obj_door_front_LE");
	level.gold_jeep_stab_door.angles = level.jeep.angles;
	level.gold_jeep_stab_door LinkTo(level.jeep);
	
	
	stab = obj( "stab" );
	
	obj_position = GetEnt("obj_stabdriver","targetname");

	Objective_Add( stab, "active", &"CLOCKWORK_OBJ_DRIVER" );
	Objective_Current( stab );
	//Objective_Position( stab, obj_position.origin );
		
	level waittill_any("ambush_player_shot","ambush_player_kill", "ambush_keegan_kill","player_knifes_driver", "ambush_scene_start");
	
	//flag_wait_any("ambush_scene_stab");

	objective_complete(stab);
	
	level.gold_jeep_stab_door delete();
}

spawn_ambush_vehicles()
{	
	//flag_wait_all("flag_intro_bodydrag_enemy","FLAG_baker_bodydrag_complete");
	flag_wait("FLAG_baker_bodydrag_complete");	// this is a world flag trigger inside the hut baker drags body into.
	
	thread hold_fire_unless_ads("nvgs_on");
	
	//Hack for bug involving killing driver after anim finishes, the passenger and driver act like they are unloading.
	level.save_aianims = level.vehicle_aianims["script_vehicle_warrior"];
	level.vehicle_aianims[ "script_vehicle_warrior" ][0].death = undefined;
	
	level.jeep	= spawn_vehicle_from_targetname_and_drive( "intro_jeep" );
	level.jeep2 = spawn_vehicle_from_targetname_and_drive("intro_jeep2");
	
	
	level.jeep maps\_vehicle::vehicle_lights_on( "headlights");
	level.jeep2 maps\_vehicle::vehicle_lights_on( "headlights");
	
	level.jeep godon();
	level.jeep2 godon();
	
	spawn_jeep_riders();
	spawn_jeep2_riders();
	
	//level.jeep thread veh_origin_angles_printout();
	
	thread maps\clockwork_audio::vehicles_approaching();
	
	wait 2;
	
	level.btr_ambush = spawn_vehicle_from_targetname_and_drive( "intro_btr_ambush" );
	level.btr_ambush maps\_vehicle::vehicle_lights_on( "running");
	level.btr_ambush godon();
	
	
	vehs = [];
	vehs[0] = level.jeep;  
	vehs[1] = level.btr_ambush; 
	vehs[2] = level.jeep;
	
	thread notify_ambush_destroy_player_off();
	
	array_thread( level.ambush_enemies, ::damage_watcher_ambush,"ambush_destroy_player_off");
	array_thread( vehs, ::damage_watcher_ambush);
	array_thread( vehs, ::destroy_player_ambush);
	thread bullet_watcher_ambush();
	thread destroy_player_ambush_vo();
	//thread ambush_destroy_player_off_test();
}

ambush_jeep2_guy_wave(scn)
{
	level endon("destroy_player_ambush");
	flag_wait("FLAG_baker_out_of_hut");
	scn anim_single_solo(self,"ambush_jeep2_passenger_wave","tag_passenger");
}

//ambush_destroy_player_off_test()
//{
//	flag_wait("ambush_destroy_player_off");
//	IPrintLn("AMBUSH_ DESTORY_PLAYER_OFF");
//}

guy_silent_death( time )
{
	if(IsDefined(time))
		wait time;
	
	if ( IsDefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
	{
		self stop_magic_bullet_shield();
	}
	
	self.a.nodeath = true; 
	self set_allowdeath(true);
	self die();
}

spawn_jeep_riders()
{
	level.jeep.dontunloadonend = true;
	
	//ambush jeep driver
	level.ambush_jeep_driver = GetEnt( "ambush_jeep_driver" , "targetname" ) spawn_ai( true );
	level.ambush_jeep_driver magic_bullet_shield();
	level.ambush_jeep_driver gun_remove();
	level.ambush_jeep_driver.animname = "ambush_jeep_driver";
	level.ambush_jeep_driver.script_startingposition = 0;
	level.jeep thread maps\_vehicle_aianim::guy_enter( level.ambush_jeep_driver );
	
	//level.ambush_jeep_driver LinkTo( level.jeep , "tag_driver" , ( 0 , 0 , 0 ) , ( 0 , 0 , 0 ) );
	//level.jeep thread anim_loop_solo( level.ambush_jeep_driver , "ambush_jeep_driver_loop" , "stop_ambush_jeep_driver_loop" , "tag_driver" );

	//ambush jeep passenger
	level.ambush_jeep_passenger = GetEnt( "ambush_jeep_passenger" , "targetname" ) spawn_ai( true );
	level.ambush_jeep_passenger magic_bullet_shield();
	level.ambush_jeep_passenger gun_remove();
	level.ambush_jeep_passenger.animname = "ambush_jeep_passenger";
	level.ambush_jeep_passenger.script_startingposition = 1;
	level.jeep thread maps\_vehicle_aianim::guy_enter( level.ambush_jeep_passenger );
	//level.ambush_jeep_passenger LinkTo( level.jeep , "tag_passenger" , ( 0 , 0 , 0 ) , ( 0 , 0 , 0 ) );
	//level.jeep thread anim_loop_solo( level.ambush_jeep_passenger , "ambush_jeep_passenger_loop" , "stop_ambush_jeep_passenger_loop" , "tag_passenger" );
	
	//ambush jeep backR
	/*
	level.ambush_jeep_riderR = GetEnt( "ambush_jeep_riderR" , "targetname" ) spawn_ai( true );
	level.ambush_jeep_riderR magic_bullet_shield();

	level.ambush_jeep_riderR gun_remove();
	level.ambush_jeep_riderR.animname = "ambush_jeep_riderR";
	level.ambush_jeep_driver.script_startingposition = 3;
	level.jeep thread maps\_vehicle_aianim::guy_enter( level.ambush_jeep_riderR );
	//level.ambush_jeep_riderR LinkTo( level.jeep , "tag_guy0" , ( 0 , 0 , 0 ) , ( 0 , 0 , 0 ) );
	//level.jeep thread anim_loop_solo( level.ambush_jeep_riderR , "ambush_jeep_riderR_loop" , "stop_ambush_jeep_riderR_loop" , "tag_guy1" );	
	*/
	level.ambush_enemies = [];
	level.ambush_enemies[0] = level.ambush_jeep_driver;
	level.ambush_enemies[1] = level.ambush_jeep_passenger;
	//level.ambush_enemies[2] = level.ambush_jeep_riderR;
}

spawn_jeep2_riders()
{
level.jeep2.dontunloadonend = true;
	
	//ambush jeep2 driver
	level.ambush_jeep2_driver = GetEnt( "ambush_jeep2_driver" , "targetname" ) spawn_ai( true );
	//level.ambush_jeep2_driver magic_bullet_shield();
	level.ambush_jeep2_driver gun_remove();
	level.ambush_jeep2_driver.animname = "ambush_jeep2_driver";
	level.ambush_jeep2_driver.script_startingposition = 0;
	level.jeep2 thread maps\_vehicle_aianim::guy_enter( level.ambush_jeep2_driver );	
	
	//ambush jeep passenger
	level.ambush_jeep2_passenger = GetEnt( "ambush_jeep2_passenger" , "targetname" ) spawn_ai( true );
	//level.ambush_jeep2_passenger magic_bullet_shield();
	level.ambush_jeep2_passenger gun_remove();
	level.ambush_jeep2_passenger.animname = "ambush_jeep2_passenger";
	level.ambush_jeep2_passenger.script_startingposition = 1;
	level.jeep2 thread maps\_vehicle_aianim::guy_enter( level.ambush_jeep2_passenger );
	level.ambush_jeep2_passenger thread ambush_jeep2_guy_wave( level.jeep2 );
	
	//ambush jeep backR
	level.ambush_jeep2_backR = GetEnt( "ambush_jeep2_backR" , "targetname" ) spawn_ai( true );
	//level.ambush_jeep2_backR magic_bullet_shield();
	level.ambush_jeep2_backR gun_remove();
	level.ambush_jeep2_backR.animname = "ambush_jeep2_backR";
	level.ambush_jeep2_backR.script_startingposition = 3;
	level.jeep2 thread maps\_vehicle_aianim::guy_enter( level.ambush_jeep2_backR );
	//level.ambush_jeep_passenger LinkTo( level.jeep , "tag_passenger" , ( 0 , 0 , 0 ) , ( 0 , 0 , 0 ) );
	
}

handle_player_bodydrag_death()
{
	scene = level.pre_ambush_scene_org;
	
	spawner							 = GetEnt( "intro_bodydrag_enemy", "targetname" );
	level.intro_bodydrag_guy			 = spawner spawn_ai( true );
	level.intro_bodydrag_guy.animname = "playerdrag";
	level.intro_bodydrag_guy.allowdeath = true;
	
	
	//key animation
	joint = spawn_anim_model("cp_key_jt", scene.origin);
	key = spawn_anim_model( "cp_key_mdl", scene.origin );
	key linkto( joint , "J_prop_1" );
	joint thread key_failsafe(key);
	
	scene thread anim_single_solo(joint, "cp_key_joint" );
	
	level.pre_ambush_scene_org thread anim_single_solo(level.intro_bodydrag_guy,"keytoss_enemy_b");

	level.intro_bodydrag_guy thread player_bodydrag_damage_watcher();
	level.intro_bodydrag_guy.dontmelee = true;
	level.special_death_guys[1] = level.intro_bodydrag_guy;
	level.special_death_guys[1].special_case = true;
	
	level waittill_any("player_shot_someone_in_remaining","going_in_hot");
	
	if(IsDefined(level.intro_bodydrag_guy) && IsAlive(level.intro_bodydrag_guy))
	{
		level.intro_bodydrag_guy.ignoreall = 0;
		level.intro_bodydrag_guy.ignoreme = 0;
	}
	wait 3;
	
	if ( IsDefined( level.intro_bodydrag_guy ) && IsAlive( level.intro_bodydrag_guy ) )
		MagicBullet( level.allies[ 2 ].weapon, level.allies[ 2 ] GetTagOrigin( "tag_flash" ), level.intro_bodydrag_guy GetTagOrigin( "j_head" ) );
}

key_failsafe( key)
{
	flag_wait("start_enemies_provoked_early");
	self anim_stopanimscripted();	
	scale = randomfloatrange( 10, 100 );
	key_vec = vectorNormalize( (key.origin -1 ) - key.origin );
	key unlink();
	key PhysicsLaunchClient( key.origin, key_vec * scale );
}

player_bodydrag_damage_watcher()
{
	
	self.health = 999;
  	self.delete_on_death = false;
	self.dontDoNotetracks = true;	
	self.allowdeath = false;
	self.allowpain = false;
    self.no_pain_sound = true;
    self.diequietly = true;
    self.a.nodeath = true;
	
	self.noragdoll = true;
	self.nocorpsedelete = true;
	
	self waittill( "damage" );
	
	if(!flag("FLAG_take_the_rest"))
	{
		flag_set("start_enemies_provoked_early");
	}
	
	//self anim_stopanimscripted();
	self.dontEverShoot = true;
	self.ignoreme = true;
	self setcontents( 0 );
	self gun_remove();
	self.fake_dead = true;
	flag_set("bodydrag1_fakedead");
	self.animname = "playerdrag";
    level.pre_ambush_scene_org anim_single_solo( self, "clock_bodydrag_death" );
    self.team = "neutral";
    level.pre_ambush_scene_org anim_first_frame_solo( self, "clock_bodydrag_drag" );
    thread player_body_drag();
}

handle_keegandrag_death()
{
	spawner							 = GetEnt( "intro_bodydrag2_enemy", "targetname" );
	level.intro_keegandrag_guy			 = spawner spawn_ai( true );
	level.intro_keegandrag_guy.animname = "keegandrag";
	level.intro_keegandrag_guy.allowdeath = true;
	
	level.pre_ambush_scene_org thread anim_single_solo(level.intro_keegandrag_guy,"keytoss_enemy_a");

	level.intro_keegandrag_guy thread keegandrag_death_damage_watcher();
	level.intro_keegandrag_guy.dontmelee = true;
	
	level.special_death_guys[2] = level.intro_keegandrag_guy;
	level.special_death_guys[2].special_case = true;
	
	level waittill_any("player_shot_someone_in_remaining","going_in_hot");
	
	if(IsDefined(level.intro_keegandrag_guy) && IsAlive(level.intro_keegandrag_guy))
	{
		level.intro_keegandrag_guy.ignoreall = 0;
		level.intro_keegandrag_guy.ignoreme = 0;
	}
	
	wait 2;
	
	if ( IsDefined( level.intro_keegandrag_guy ) && IsAlive( level.intro_keegandrag_guy ) )
		MagicBullet( level.allies[ 1 ].weapon, level.allies[ 1 ] GetTagOrigin( "tag_flash" ), level.intro_keegandrag_guy GetTagOrigin( "j_head" ) );
}

keegandrag_death_damage_watcher()
{
	
	self.health = 999;
  	self.delete_on_death = false;
	self.dontDoNotetracks = true;	
	self.allowdeath = false;
	self.allowpain = false;
    self.no_pain_sound = true;
    self.diequietly = true;
    self.a.nodeath = true;
	
	self.noragdoll = true;
	self.nocorpsedelete = true;
	self.grenadeawareness = 0;
	

	self waittill( "damage" );
	
	
	if(!flag("FLAG_take_the_rest"))
	{
		flag_set("start_enemies_provoked_early");
	}
	
	//self anim_stopanimscripted();
	self.dontEverShoot = true;
	self.ignoreme = true;
	self setcontents( 0 );
	self gun_remove();
	self.fake_dead = true;
	flag_set("bodydrag2_fakedead");
	self.animname = "keegandrag";
    level.pre_ambush_scene_org anim_single_solo( self, "clock_intro_death_guard2" );
    level.pre_ambush_scene_org anim_first_frame_solo( self, "clock_intro" );
 	
}

setup_bodydrag_startpoint()
{
	//player drag body
	spawner							 = GetEnt( "intro_bodydrag_enemy", "targetname" );
	level.intro_bodydrag_guy			 = spawner spawn_ai( true );
	level.intro_bodydrag_guy.animname = "playerdrag";
	level.intro_bodydrag_guy.dontmelee = true;
	level.intro_bodydrag_guy.ignoreme = true;
	level.intro_bodydrag_guy.ignoreall = true;
	level.intro_bodydrag_guy setcontents( 0 );
	level.intro_bodydrag_guy gun_remove();
	level.pre_ambush_scene_org anim_first_frame_solo( level.intro_bodydrag_guy, "clock_bodydrag_drag" );
	thread player_body_drag();
	
	//Keegan Drag Body
	spawner							 = GetEnt( "intro_bodydrag2_enemy", "targetname" );
	level.intro_keegandrag_guy			 = spawner spawn_ai( true );
	level.intro_keegandrag_guy.animname = "keegandrag";
	level.intro_keegandrag_guy.dontmelee = true;
	level.intro_keegandrag_guy.ignoreme = true;
	level.intro_keegandrag_guy.ignoreall = true;
	level.intro_keegandrag_guy setcontents( 0 );
	level.intro_keegandrag_guy gun_remove();
	level.pre_ambush_scene_org anim_first_frame_solo( level.intro_keegandrag_guy, "clock_intro" );
	
	//Baker drag body
	spawner							 = GetEnt( "balcony_death_guy", "targetname" );
	level.intro_balcony_guy			 = spawner spawn_ai( true );
	level.intro_balcony_guy.animname = "bakerdrag";
	level.intro_balcony_guy.dontmelee = true;
	level.intro_balcony_guy.ignoreall = true;
	level.intro_balcony_guy.ignoreme = true;
	level.intro_balcony_guy setcontents( 0 );

    
    level.pre_ambush_scene_org anim_first_frame_solo( level.intro_balcony_guy, "clock_intro" );

}

player_body_drag()
{
//	level endon("start_ambush_scene");
	
	thread btr_sees_body();
	flag_wait("flag_intro_bodydrag_enemy");
	thread maps\clockwork_audio::player_drag_body();
	
	disable_trigger_with_targetname("trig_intro_bodydrag_scene");
	
	level.drag_player_arms = spawn_anim_model( "player_rig" );
	
	drag_actors = [];
	drag_actors[0] = level.drag_player_arms;
	drag_actors[1] = level.intro_bodydrag_guy;
	
	level.intro_bodydrag_guy.a.nodeath = true;
	level.intro_bodydrag_guy set_allowdeath(true);
			
	level.player SetStance("stand");
	
	level.player FreezeControls(true);
		
	level.player DisableWeapons();
	level.drag_player_arms hide();
	
	level.pre_ambush_scene_org thread anim_single( drag_actors, "clock_bodydrag_drag");
	level.player PlayerLinkToBlend( level.drag_player_arms, "tag_player", .5 );
	//level.player PlayerLinkToDelta( level.drag_player_arms, "tag_player", .5, 30, 30, 30, 30, false );
	
	wait .5;
	
	level.drag_player_arms Show();
	
	drag_actors[1] waittillmatch("single anim","end");
	
	level.player Unlink();
	level.drag_player_arms Delete();
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	
	flag_set("FLAG_obj_bodydrag_complete");
	level.player FreezeControls( false );
	level.intro_bodydrag_guy guy_silent_death();
	level notify("player_hid_barrier_body");
	
}

btr_sees_body()
{
	level endon("player_hid_barrier_body");
	
	flag_wait("btr_sees_playerdrag_body");
	flag_set("destroy_player_ambush");
}

player_stab_driver()
{
	level endon("destroy_player_ambush");
	level endon("ambush_scene_start");
	
	flag_wait("enable_stab");
	level notify("enable_stab");
	
	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	
	level.cosine[ "25" ] = cos( 25 );

	player_arms = spawn_anim_model( "player_rig",level.pre_ambush_scene_org.origin );
	player_arms attach( "viewmodel_commando_knife", "TAG_WEAPON_RIGHT" );
	player_arms hide();
	level.pre_ambush_scene_org thread anim_first_frame_solo( player_arms, "clock_ambush_end_knife");
	
	thread obj_stabdriver();
	thread stab_enemy_hint();
	thread player_looking_at_stabguy();
	
	waittill_player_triggers_stealth_kill();

	level.player SetStance("stand");
	level.player disableweapons();
	
	
	level.ambush_jeep_driver Unlink();
	
	while ( 1 )
	{
		if ( level.player IsMeleeing() )
		{
			wait( 1 );
			break;
		}

		if ( level.player IsThrowingGrenade() )
		{
			break;
		}
		
		break;
	}
	
	level notify("player_knifes_driver");
	flag_set("ambush_scene_stab");
	
	player_arms show();
	level.player PlayerLinkToBlend( player_arms, "tag_player",.15); 
	
	wait .15;
	
	thread drop_him_vo();
	
	level.pre_ambush_scene_org notify("stop_clock_ambush_wait");
	
	actors = [];
	actors[0] = player_arms;
	actors[1] = level.ambush_jeep_driver;
	
	level.pre_ambush_scene_org thread anim_single( actors, "clock_ambush_end_knife");
	
	level.ambush_jeep_driver thread waittill_clockambush_end_enemies(); //wait til driver gets to end of anim, and kill him, unlink, etc.
	level.ambush_jeep_driver thread waittill_clockambush_driver_dead();	// wait til the driver gets to end of anim, and play FX
	level.player PlayerLinkToAbsolute( player_arms, "tag_player");//,.25,15,15,11,11);
		
	player_arms waittillmatch("single anim","end");
	
	level.player Unlink();
	player_arms Delete();
	level notify("ambush_scene_over");
	//enable_trigger_with_targetname("trig_get_in_jeep");
	//flag_set("FLAG_enable_enter_jeep");
		
	level.player enableWeapons();
	level.player AllowMelee(true);

	/*
	while( !flag( "FLAG_obj_getinjeep_complete" ) )
	{
		level.jeep Vehicle_SetSpeed( 0, 10 );
		wait .01;
	}
	*/
}

drop_him_vo()
{
	wait 1.25;
	level.allies[2] thread char_dialog_add_and_go("clockwork_cyr_dropem2");	
}

player_looking_at_stabguy()
{
	level endon( "player_knifes_driver" );
	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	
	thread handle_weapon_melee_toggle();
	
	bInFOV = undefined;
	trig_player_stab = getent( "trig_player_stab", "script_noteworthy" );
	org = getent( trig_player_stab.target, "targetname" );
	
	while( true )
	{
		wait( 0.05 );
		if ( flag( "player_near_stab_guy" ) )
		{
			bInFOV = within_fov( level.player geteye(), level.player getPlayerAngles(), org.origin, level.cosine[ "25" ] );
			if ( bInFOV ) 
			{
				flag_set( "player_looking_at_stab_guy" );
				//level.player DisableWeapons();
				//level.player AllowMelee( false );
			}
			else
			{
				flag_clear( "player_looking_at_stab_guy" );
				//level.player EnableWeapons();
				//level.player AllowMelee( true );
			}
		}
		else
			
		flag_clear( "player_looking_at_stab_guy" );	
	}
}

handle_weapon_melee_toggle()
{
	//level endon( "player_knifes_driver" );
	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	level endon( "ambush_scene_timeout" );
	level endon("ambush_scene_over");
	
	while( true )
	{
		wait( 0.05 );
		if (flag( "player_near_stab_guy" ) )
		{
			level.player DisableWeapons();
			level.player AllowMelee( false );
		}
		
		if (!flag( "player_near_stab_guy" ) )
		{
			level.player enableWeapons();
			level.player AllowMelee( true );
		}
	}
}

stab_enemy_hint()
{
	level endon( "player_knifes_driver" );
	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	level endon( "ambush_player_timeout" );
	
	sHint = &"CLOCKWORK_PROMPT_STAB";
	thread stab_enemy_hint_cleanup();
	
	while ( !flag( "ambush_scene_stab" ) )
	{
		flag_wait( "player_looking_at_stab_guy" );
		
		thread hint( sHint );
		
		flag_set( "player_in_position_for_stab_kill" );
		
		while ( flag( "player_looking_at_stab_guy" ) )
			wait( 0.05 );
		
		flag_clear( "player_in_position_for_stab_kill" );
		thread hint_fade();
	}
	thread hint_fade();
}

stab_enemy_hint_cleanup()
{
	flag_wait_any( "ambush_scene_stab","ambush_scene_shot","ambush_scene_timeout" );
	thread hint_fade();
}


waittill_player_triggers_stealth_kill()
{
	while ( !flag( "ambush_scene_stab" ) )
	{
		wait( 0.05 );
		if ( ( flag( "player_looking_at_stab_guy" ) ) && ( level.player MeleeButtonPressed() ) )
			break;
	}
}

handle_balcony_death()
{
	spawner							 = GetEnt( "balcony_death_guy", "targetname" );
	level.intro_balcony_guy			 = spawner spawn_ai( true );
	level.intro_balcony_guy.animname = "bakerdrag";
	//level.intro_balcony_guy AllowedStances("stand");
	//level.intro_balcony_guy.allowdeath = true; 
	
	//level.introcp_guys_final = add_to_array(level.introcp_guys_remaining, level.intro_balcony_guy);
	
	level.special_death_guys[0] = level.intro_balcony_guy;
	level.special_death_guys[0].special_case = true;
	
	//level.pre_ambush_scene_org anim_single_solo( level.intro_balcony_guy, "shoetie" );

	level.intro_balcony_guy thread balcony_death_damage_watcher();
	level.intro_balcony_guy.dontmelee = true;
	level waittill_any("player_shot_someone_in_remaining");
	
	level.intro_balcony_guy.ignoreall = 0;

	wait 4;
	
	if ( IsDefined( level.intro_balcony_guy ) && IsAlive( level.intro_balcony_guy ) )
		MagicBullet( level.allies[ 0 ].weapon, level.allies[ 0 ] GetTagOrigin( "tag_flash" ), level.intro_balcony_guy GetTagOrigin( "j_head" ) );
}

balcony_death_damage_watcher()
{
	self.health = 999;
  	self.delete_on_death = false;
	self.dontDoNotetracks = true;	
	self.allowdeath = false;
	self.allowpain = false;
    self.no_pain_sound = true;
    self.diequietly = true;
    self.a.nodeath = true;
	
	self.noragdoll = true;
	self.nocorpsedelete = true;
	

	self waittill( "damage" );
	
	if(!flag("FLAG_take_the_rest"))
	{
		flag_set("start_enemies_provoked_early");
	}
	
	//self anim_stopanimscripted();
	self.dontEverShoot = true;
	self.ignoreme = true;
	self.ignoreall = true;
	self setcontents( 0 );
	self.fake_dead = true;
	flag_set("bodydrag3_fakedead");	
	self.animname = "bakerdrag";
    level.pre_ambush_scene_org anim_single_solo( self, "clock_intro_guy_death" );
   	level.pre_ambush_scene_org anim_first_frame_solo( self, "clock_intro" );
}


start_ambush_scene()
{
	//flag_wait("start_ambush_scene");
	flag_wait("FLAG_baker_out_of_hut");
	
	level endon("destroy_player_ambush");
	
	if(!flag("destroy_player_ambush"))
	{
		//thread maps\clockwork_audio::ambush_scene();
		thread animate_ambush_scene_enemies();
	
		level.allies[0].script_startingposition = 1;
		level.allies[1].script_startingposition = 0;
		level.allies[2].script_startingposition = 3;
		level.allies[0].animname = "baker";
		level.allies[1].animname = "keegan";
		level.allies[2].animname = "cipher";
		
	
		//conditions for starting the ambush
		level waittill("enable_stab");
		
		// if the player doesnt shoot in X seconds, start scene notify
		//level.ambush_jeep_driver thread ambush_notify_on_player_timeout( 4 );
	
		//if any of the riders are damaged, start the scene notify
		foreach(guy in level.ambush_enemies)
		{
			guy thread ambush_notify_on_player_kill();
		}
		
		//if player shoots anywhere start scene notify
		thread ambush_notify_on_player_shot();
		
		// wait till any of those notifies happens
		level waittill_any("ambush_player_shot","ambush_player_kill", "ambush_keegan_kill","player_knifes_driver", "ambush_scene_start");
		
		flag_set("ambush_scene_started");
			
		//then hard stop loops.
		level.pre_ambush_scene_org  notify( "stop_clock_ambush_wait" );
			
		if(!flag("destroy_player_ambush"))
		{
			
			waittillframeend;
			
			thread maps\clockwork_audio::foley_post_ambush();
			
			base_ambush_actors = [];
			base_ambush_actors[0] = level.allies[0]; //baker
			base_ambush_actors[1] = level.allies[2]; //cipher
			base_ambush_actors[2] = level.ambush_enemies[1]; 
			base_ambush_actors[3] = level.bags[0];	
			base_ambush_actors[4] = level.bags[1];		
			base_ambush_actors[5] = level.bags[2];	
			
			level.jeep.animname = "ambush_jeep";
					
			level.pre_ambush_scene_org thread anim_single( base_ambush_actors, "clock_ambush_end" ); //scene
			level.jeep thread anim_single_solo( level.jeep, "clock_ambush_end" ); //scene
			level.jeep.dontunloadonend = true;
			
			
			if(flag("ambush_scene_stab"))
			{
				level.pre_ambush_scene_org thread anim_single_solo( level.allies[1], "clock_ambush_end_knife" ); //scene
				level.pre_ambush_scene_org notify("stop_loop");
				thread maps\clockwork_audio::ambush_kill_driver_player();
			}
			
			
			if(flag("ambush_scene_shot")) //if shot instead
			{
				level.pre_ambush_scene_org notify("stop_loop");
				
				gunshot_actors = [];
				gunshot_actors[0] = level.allies[1];//keegan
				gunshot_actors[1] = level.ambush_jeep_driver;
				
				level.pre_ambush_scene_org thread anim_single_solo( gunshot_actors[0], "clock_ambush_end_gunshot" ); //scene
				level.pre_ambush_scene_org thread anim_single_solo( gunshot_actors[1], "clock_ambush_end_gunshot" ); //scene
				
				gunshot_actors[1] thread wait_keegan_drag();
				//enable_trigger_with_targetname("trig_get_in_jeep");	
				thread maps\clockwork_audio::ambush_kill_driver_cypher();
				
				level.allies[1] char_dialog_add_and_go("clockwork_kgn_goodshot");
				
			}
			
			if(flag("ambush_player_timeout")) //if timeout instead
			{	
				flag_set("ambush_scene_timeout");
				level notify("ambush_scene_timeout");
				wait 1.5;
				
				level.pre_ambush_scene_org notify("stop_loop");
				
				gunshot_actors = [];
				gunshot_actors[0] = level.allies[1];//keegan
				gunshot_actors[1] = level.ambush_jeep_driver;
				
				level.pre_ambush_scene_org thread anim_single_solo( gunshot_actors[0], "clock_ambush_end_gunshot" ); //scene
				level.pre_ambush_scene_org thread anim_single_solo( gunshot_actors[1], "clock_ambush_end_gunshot" ); //scene
				
				gunshot_actors[1] thread wait_keegan_drag();
				
				//enable_trigger_with_targetname("trig_get_in_jeep");
				
				thread maps\clockwork_audio::ambush_kill_driver_cypher();
			}
			
			level.player enableWeapons();
			level.player AllowMelee(true);
			
			bloodsplatter = Spawn("script_model", level.jeep.origin);
			bloodsplatter SetModel("chinese_brave_warrior_fx_glass");
			bloodsplatter.angles = level.jeep.angles;
			bloodsplatter LinkTo(level.jeep);
			
			
			level.ambush_enemies[1] thread waittill_clockambush_end_enemies(); // silent kill enemies after each of their anims
		
			//level.pre_ambush_scene_org thread anim_single_solo( level.ambush_enemies[0], "clock_ambush_end_enemies" );
			//level.ambush_enemies[0] thread waittill_clockambush_end_enemies(); // silent kill enemies after each of their anims
			
			flag_set("FLAG_enable_enter_jeep");
			
			
			//these wait for each ally to finish anims, then set a specific flag. when each flag is set (including player get in) the jeep can start driving.
			level.allies[0] thread anim_clockambush_finished("bakerambush_finished");
			level.allies[1] thread anim_clockambush_finished("cipherambush_finished");
			level.allies[2] thread anim_clockambush_finished("keeganambush_finished");
			
			level.bags[0] thread link_bag_to_jeep_after_anim();
			level.bags[1] thread link_bag_to_jeep_after_anim();
			level.bags[2] thread link_bag_to_jeep_after_anim();
			
			waitframe();
			
			
			while( !flag( "FLAG_obj_getinjeep_complete" ) )
			{
				level.jeep Vehicle_SetSpeed( 0, 10 );
				wait .01;
			}
			
		}
	}
}

wait_keegan_drag()
{
	self waittillmatch("single anim","end");
	level.pre_ambush_scene_org thread anim_first_frame_solo( self, "clock_ambush_end_gunshot_drag" ); 
	
	flag_wait("FLAG_gunshot_drag");
	
	level.pre_ambush_scene_org thread anim_single_solo( self, "clock_ambush_end_gunshot_drag" ); 

	self waittill_clockambush_end_enemies();
}

animate_ambush_scene_enemies()
{

	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	level endon( "player_knifes_driver" );
	level endon("destroy_player_ambush");
	flag_wait("start_ambush_scene_enemies");

	
	//wait 1.5;
	
	foreach(enemy in level.ambush_enemies)
	{
		enemy.health = 9999;
  		enemy.delete_on_death = false;
  		enemy.a.nodeath = true;
		//enemy.allowdeath = false;
		enemy.allowpain = true;
    	enemy.no_pain_sound = true;
    	enemy.diequietly = true;
		enemy.dontEverShoot = true;
		enemy.noragdoll = true;
		enemy.nocorpsedelete = true;
		enemy.ignoreme = true;
		enemy Unlink();
	}
	
	foreach(guy in level.ambush_enemies)
	{
		guy anim_stopanimscripted();
	}

	level.jeep notify("stop_loop");

	level.pre_ambush_scene_org anim_single( level.ambush_enemies, "clock_ambush_start_enemies" );
	
	thread ambush_notify_on_player_timeout( 12 );
	
	if(IsDefined(level.ambush_enemies[0]) && IsAlive(level.ambush_enemies[0]))
	{
		level.pre_ambush_scene_org thread anim_loop_solo( level.ambush_enemies[0], "clock_ambush_wait","stop_clock_ambush_wait" );
}

	if(IsDefined(level.ambush_enemies[1]) && IsAlive(level.ambush_enemies[1]))
	{
		level.pre_ambush_scene_org thread anim_loop_solo( level.ambush_enemies[1], "clock_ambush_wait","stop_clock_ambush_wait" );
	}

	//level.pre_ambush_scene_org anim_loop( level.ambush_enemies, "clock_ambush_wait","stop_loop" );
}


ambush_notify_on_player_timeout( time )
{
	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	level endon("player_knifes_driver");
	
	wait time;
	
	flag_set("ambush_player_timeout");
	level notify( "ambush_scene_start" );

	wait 1.5;
	
	//playfxontag( getfx( "ak47_muzzleflash" ), level.allies[ 2 ].weapon, "tag_flash"  );
	if ( IsDefined( level.ambush_jeep_driver ) && IsAlive( level.ambush_jeep_driver ) )
		MagicBullet( level.allies[ 2 ].weapon, level.allies[ 2 ] GetTagOrigin( "tag_flash" ), level.ambush_jeep_driver GetTagOrigin( "j_head" ) );
	
	thread maps\clockwork_audio::ambush_kill_driver_cypher();
}

ambush_notify_on_player_kill()
{
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	
	self waittill( "damage", damage, attacker );
	
	if(attacker == level.player)
	{
		flag_set("ambush_scene_shot");
		level notify( "ambush_player_kill" );
		
	}
	if(attacker == level.allies[1])
	{
		flag_set("ambush_scene_shot");
		level notify( "ambush_keegan_kill" );
		
	}
	
}

ambush_notify_on_player_shot()
{
	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	
	level.player waittill( "weapon_fired" );
	
	wait 1;
	
	if( IsDefined( level.ambush_jeep_driver ) && IsAlive( level.ambush_jeep_driver ) )
	{
		MagicBullet( level.allies[ 2 ].weapon, level.allies[ 2 ] GetTagOrigin( "tag_flash" ), level.ambush_jeep_driver GetTagOrigin( "j_head" ) );
		flag_set("ambush_scene_shot");
		level notify( "ambush_player_shot" );
	}
}

//waittill_clockintro_finished_idle()
//{
//	self waittillmatch("single anim","end");
//	self thread anim_loop_solo(self,"relaxed_idle", "stop_relaxed_idle");
//}

waittill_clockambush_end_enemies()
{
	self waittillmatch("single anim","end");
	self.a.nodeath = true;
	self.allowdeath = true;
	self stop_magic_bullet_shield();
	self die();
	self Unlink();
}

waittill_clockambush_driver_dead()
{
	self waittillmatch("single anim","end");
	exploder("162");
	//PlayFXOnTag(GetFX("fx/misc/blood_pool_small_soap"), self, "tag_origin");
}

anim_clockambush_finished( flag_to_set )
{
	self waittillmatch("single anim","end");
	level.jeep thread maps\_vehicle_aianim::guy_enter( self );
	flag_set( flag_to_set );
}

link_bag_to_jeep_after_anim()
{
	self waittillmatch("single anim","end");
	self linkto(level.jeep);
}

//single_anim_finished_start_loop( root, anime, LINKTO_TAG )
//{
//	self waittillmatch("single anim","end");
//	self gun_remove();
//	
//	if(self == level.allies[0])
//		self.animname = "baker";
//	
//	if(self == level.allies[1])
//		self.animname = "keegan";
//		
//	if(self == level.allies[2])
//		self.animname = "cipher";
//	
//	self LinkTo( level.jeep , LINKTO_TAG , ( 0 , 0 , 0 ) , ( 0 , 0 , 0 ) );
//	root thread anim_loop_solo( self , anime, undefined, LINKTO_TAG );
//}
//
//cipher_waittill_clockambush_finished()
//{
//	level.allies[2] waittillmatch("single anim","end");
//	flag_set("cipherambush_finished");
//}
//
//keegan_waittill_clockambush_finished()
//{
//	level.allies[1] waittillmatch("single anim","end");
//	flag_set("keeganambush_finished");
//}

intro_ambush_vo()
{
	level endon( "player_knifes_driver" );
	level endon( "ambush_player_shot" );
	level endon( "ambush_player_kill" );
	level endon( "ambush_keegan_kill" );
	level endon( "destroy_player_ambush" );
	
	level.allies[2] char_dialog_add_and_go("clockwork_cyr_clear");
		
	level.allies[1] char_dialog_add_and_go("clockwork_kgn_clear");
	
	if(flag("start_enemies_provoked_early"))
    {
		level.allies[0] char_dialog_add_and_go("clockwork_bkr_beencleaner");
	   //thread add_dialogue_line("Baker","That could have gone cleaner...");
    }
	else
	{
		level.allies[0] char_dialog_add_and_go("clockwork_bkr_nicejob");
		//level.allies[0] char_dialog_add_and_go("clockwork_bkr_cleanitup");
	}
	
	flag_wait("checkpoint_taken2");
	wait .5;
	flag_set("FLAG_obj_bodydrag");
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_clearthatbody");
	
	level.allies[1] char_dialog_add_and_go("clockwork_bkr_intheback");
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_wherespatrol");
	
	radio_dialog_add_and_go("clockwork_diz_headedyourway");
	
	flag_wait("FLAG_baker_bodydrag_complete"); // this is a world flag trigger inside the hut baker drags body into.
	//flag_wait_all("flag_intro_bodydrag_enemy","FLAG_baker_bodydrag_complete");
	
	radio_dialog_add_and_go("clockwork_diz_patrolinbound");

	level.allies[1] char_dialog_add_and_go("clockwork_kgn_showtime");
	
	level.allies[2] char_dialog_add_and_go("clockwork_cyr_betterwork");
	
	wait 5;
	
	level.allies[2] char_dialog_add_and_go("clockwork_mrk_letthebtrpass");
	
	level waittill("enable_stab");
	
	thread get_in_jeep_nag_vo();
	
	level.allies[2] char_dialog_add_and_go("clockwork_cyr_gotthedriver");
	
	wait 2;
	
	level.allies[2] char_dialog_add_and_go("clockwork_cyr_movein");
	
	wait 2;
	
	level.allies[2] char_dialog_add_and_go("clockwork_cyr_takeoutdriver");
	
	wait 2;
	
	level.allies[2] char_dialog_add_and_go("clockwork_cyr_gotthedriver");
	
	//flag_set( "ambush_stop_vo" );
	
}




get_in_jeep_nag_vo()
{
	level endon("player_in_jeep");
	
	flag_wait("bakerambush_finished");
	
	while(1)
	{
		
		level.allies[0] char_dialog_add_and_go("clockwork_bkr_wastingtime");
		
		wait( randomfloatrange( 1, 4 ) );	
		
		level.allies[0] char_dialog_add_and_go("clockwork_bkr_timetogo");
		
		wait( randomfloatrange( 1, 4 ) );	
		
		level.allies[0] char_dialog_add_and_go("clockwork_bkr_rookgetin");
		
		wait( randomfloatrange( 1, 4 ) );	
		
		level.allies[0] char_dialog_add_and_go("clockwork_bkr_gotaschedule");
		
		wait( randomfloatrange( 1, 4 ) );	
	}
}

intro_drive()
{
	MAX_ROTATE_ANG = 66;
	flag_wait( "start_intro_drive" );
	level notify("player_in_jeep");
	
	thread maps\clockwork_interior::spin_fans("introdrive_finished");
	
	thread autosave_by_name( "jeep_drive_intro" );
	
	thread maps\clockwork_audio::enter_jeep();
	//level.jeep.dontunloadonend = false;
	thread maps\clockwork_interior_nvg::handle_tunnel_ambience(); //que the tunnel ambience
	thread spawn_enemy_road_jeep();
	thread entrance_drones();
	foreach(guy in level.allies)
	{
		guy.alertlevel = "noncombat";
	}
	
	level.player setstance("stand");
	
	level.player FreezeControls( true );
	
	level.gold_jeep_player_door delete(); //remove gold glowy door
	level.player DisableWeapons();
	level.jeep_player_arms = spawn_anim_model( "player_rig" );
	level.jeep_player_arms SetModel( "clk_watch_viewhands_off" );
	
	level.jeep_player_arms hide();
		
	level.jeep_player_arms LinkTo( level.jeep, "tag_guy0", ( 50, 0, 0 ), ( 0, 0, 0 ) );
	level.jeep_player_arms thread anim_first_frame_solo( level.jeep_player_arms, "ambush_jeep_enter_player" );
	level.player PlayerLinkToBlend( level.jeep_player_arms, "tag_player", .5 );
	
	

	
	jeep_actors[0] = level.jeep;
	jeep_actors[0].animname = "ambush_jeep";
	
	actors[0] = level.jeep_player_arms;
	actors[1] = spawn_anim_model("player_bag");
	//actors[2] = spawn_anim_model("player_bag");
	//actors[3] = spawn_anim_model("player_bag");
	
	//actors[2].animname = "player_ambush_bag1";
	//actors[3].animname = "player_ambush_bag2";
	
	
	level.jeep thread anim_single( jeep_actors, "ambush_jeep_enter_player" );
	level.jeep thread anim_single( actors, "ambush_jeep_enter_player", "tag_guy0" );
	
	wait .25;
	
	level.jeep_player_arms show();
	
	level.jeep_player_arms waittillmatch("single anim","end");
	level.player FreezeControls( false );
	level.jeep_player_arms hide();
	actors[1] LinkTo(level.jeep);
	//actors[2] LinkTo(level.jeep);
	//actors[3] LinkTo(level.jeep);
	
	//level.jeep anim_first_frame_solo( level.jeep_player_arms, "watch_sync_jeep", "tag_player" ); //tag_guy0
	
	//level.jeep_player_arms Hide();
	level.player AllowCrouch(false);
	level.player AllowProne(false);
	//level.player SetPlayerAngles((level.player.angles[0], level.player.angles[1], 0));
	level.player PlayerLinkToDelta( level.jeep_player_arms, "tag_player",1, 130,130,40,15 );

	flag_set("FLAG_obj_getinjeep_complete");
	flag_wait_all( "bakerambush_finished", "cipherambush_finished", "keeganambush_finished","FLAG_obj_getinjeep_complete");
	level.vehicle_aianims["script_vehicle_warrior"] = level.save_aianims;
	
	wait 1;
	
	//Jeep starts driving
	thread maps\clockwork_audio::vehicle_player_01();
	
	//FX on
	//thread maps\clockwork_fx::turn_effects_on("intro_spotlight","fx/lights/light_search_clockwork"); //search light
	thread maps\clockwork_fx::turn_effects_on( "cagelight", "fx/lights/lights_cone_cagelight" );
   	thread maps\clockwork_fx::turn_effects_on( "tubelight_parking", "fx/lights/lights_flourescent" );
	thread maps\clockwork_interior_nvg::nvg_area_lights_on_fx();
    exploder(100); // turn on snow fx
    exploder(300); //turn on ambient garage smoke
	exploder(850); //turn on vista mist
	
	//attach_bags_to_jeep();
	
	level.jeep.attachedpath = undefined;
    level.jeep notify( "newpath" );

	intro_path = GetVehicleNode( "intro_road_path", "targetname" );
	level.jeep thread vehicle_paths( intro_path );
    level.jeep StartPath( intro_path );
    level.jeep Vehicle_SetSpeed( 30, 4, 4 ); //needed to get the vehicle moving
    level.jeep ResumeSpeed( 3 );
    
    
    level.allies[1].animname = "keegan";
    level.allies[2].animname = "cipher";
    
 
    wait 0.3;
    
 
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_bloodwipe",level.allies[0], 1, true);
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_bloodwipe",level.allies[1], 0, true);
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_bloodwipe",level.allies[2], 3, true);
	//level.jeep thread anim_single_solo(level.jeep,"clockwork_jeep_bloodwipe");
	
	wait 2.5;
	
    level.allies[0] char_dialog_add_and_go("clockwork_bkr_keepspacing" );
    
	level.allies[2] char_dialog_add_and_go("clockwork_cyr_roger" );
    
	flag_wait("start_watchsync_vo");
	stop_exploder(2000); //stop all fx in intro area
	
	thread allies_jeep_sync_anim();
	
	level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_preparetosync" );
	
	//thread look_at_watch_in_jeep();
	
	//**WATCH ANIM**//
	/*
		level.jeep_player_arms show();

		SetSavedDvar( "cg_cinematicFullScreen", "0" );
		CinematicInGameSync( "digital_watch" );
		thread maps\clockwork_audio::ride_watch_beep();
		
		level.jeep anim_single_solo( level.jeep_player_arms, "watch_sync_jeep", "tag_guy0" );
		
		level.player EnableWeapons();
		level.jeep_player_arms Hide();
	
		StopCinematicInGame();
	*/
	//***END WATCH ANIM***//
	
	thread blackout_timer(70,&"CLOCKWORK_POWERDOWN",true, false);
	
	thread maps\clockwork_interior_nvg::init_tunnel();
	
	//wait a little to start VO
	wait 4;
	
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_lookout",level.allies[2], 3, true);
	
	radio_dialog_add_and_go("clockwork_diz_under5mins");
	
	radio_dialog_add_and_go("clockwork_diz_sealingit");

	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_ack",level.allies[0], 1, true);
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_guncheck",level.allies[2], 3, true);
	
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_copyall" );

	flag_wait("entering_blackbird_vo");
	
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_blackbird",level.allies[0], 1, true);
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_blackbird" );
	
	thread exit_jeep_anims();
	
	flag_wait( "introdrive_finished" );
	
	thread autosave_by_name( "jeep_drive_exit" );
	
	level.bags[0] Delete();
	actors[1] Delete();
}

spawn_enemy_road_jeep()
{
	flag_wait("enemy_road_jeep");
	gaz = spawn_vehicle_from_targetname_and_drive("intro_enemy_gaz");
	gaz maps\_vehicle::vehicle_lights_on( "headlights");
	flag_wait("FLAG_keegan_wave_jeep");
	//Keegan Waves
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_wave",level.allies[1], 0, true);
	//level.jeep thread anim_single_solo(level.jeep,"clockwork_jeep_wave");
}

//once allies play watch sync anim, play respective loops again
allies_jeep_sync_anim()
{
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_sync",level.allies[0], 1, true);
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_sync",level.allies[1], 0, true);
	level.jeep thread vehicle_play_guy_anim("clockwork_jeep_sync",level.allies[2], 3, true);
	//level.jeep thread anim_single_solo(level.jeep,"clockwork_jeep_sync");
}

#using_animtree( "generic_human" );
exit_jeep_anims()
{
	level.allies[0].get_out_override = %clockwork_garage_arrival_baker;
	level.allies[1].get_out_override = %clockwork_garage_arrival_keegan;
	level.allies[2].get_out_override = %clockwork_garage_arrival_cypher;
	//Player jumps out
	flag_wait( "jeep_intro_ride_done" );
	
	wait 1;
	
	level.jeep vehicle_unload();
	flag_set( "introdrive_finished" );

	thread player_exit_jeep();
	
	level.allies[0].animname = "baker";
	level.allies[1].animname = "keegan";
	level.allies[2].animname = "cipher";

	
	foreach(guy in level.allies)
	{
		//guy anim_stopanimscripted();
		guy gun_recall();
	}

	//actors = add_to_array(level.allies, level.jeep);
	level.jeep.animname = "garage_arrival_jeep";
	level.jeep thread anim_single_solo( level.jeep, "clockwork_garage_arrival" );
	
	
	foreach(ally in level.allies)
	{
		//ally Unlink();
		ally enable_ai_color();
	}
	
	level.player.ignoreme = false;
	
	foreach(ally in level.allies)
	{
		ally.ignoreSuppression = true;
	    ally.IgnoreRandomBulletDamage = true;
	    ally.ignoreExplosionEvents = true;
	    ally.disableBulletWhizbyReaction = true;
	    ally.disableFriendlyFireReaction = true;
		ally.ignoreme = false;
		ally.disableplayeradsloscheck = true;
	}

	show_dufflebags();
	thread maps\clockwork_interior_nvg::handle_lights_out_approach();
	
	wait 10;
	
	flag_set("start_nvg_guy_anims"); //this flag starts the first group of nvg guy anims 
	flag_set("start_closing_vault_door");
}

player_exit_jeep()
{
	flag_wait("FLAG_player_getout_jeep");
	
	level.player DisableWeapons();
	player_rig			= spawn_anim_model( "player_rig",level.jeep.origin );
	level.player_rig	= player_rig;
	level.player_rig Hide();
	//level.player_rig LinkTo( level.jeep, "tag_guy0", ( 0, -10, -87 ), ( 0, 0, 0 ) );
	player_bag = spawn_anim_model("player_bag");
	//level.jeep anim_single_solo( level.player_rig, "intro_jeep_stand_player", "tag_player2" );
		
	thread maps\clockwork_audio::exit_jeep();
	
	stop_exploder(150);             //turn off tunnel fx
	stop_exploder(100);           //turn snow fx off
	stop_exploder(850);           //turn off vista mist
	
	//level.player PlayerLinkTo( level.player_rig, "tag_player",0 ,25,25,25,25 );
	//level.player player_dismount_vehicle();
	
	actors[0] = player_rig;
	actors[1] = player_bag;
	actors[1].animname = "player_bag";
	
	
	
	level.player_rig Show();
	level.player PlayerLinkToAbsolute( level.player_rig, "tag_player",1);
	
	
	level.jeep thread anim_first_frame( actors, "intro_jeep_exit_player" );
	
	level.jeep thread anim_single( actors, "intro_jeep_exit_player" );
	
	if(!flag("interior_start_point"))
	{
		level.player PlayerLinkToBlend( level.player_rig, "tag_player",1);
	}
	
	level.player_rig waittillmatch("single anim","end");

	//blackout_approach_viewbob();
	
	level.player Unlink();
	level.player_rig Delete();
	player_bag delete();
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player SwitchToWeapon( "ak47_grenadier_acog" );
	level.player AllowCrouch(true);
	level.player AllowProne(true);
	
	flag_clear( "player_DMS_allow_sprint" );
	
	thread maps\clockwork_interior_nvg::player_failcase_leave_garage();
}

//look_at_watch_in_jeep()
//{
//	//flag_wait("NOTE_player_watch_sync_jeep");
//	
//	level.player DisableWeapons();
//	wait .25;
//	
//	if ( level.player GetStance() == "stand" )
//	{
//		look_at_watch( level.jeep, "watch_sync_jeep", "digital_watch", "tag_guy0", false );
//	}
//	else
//	{
//		look_at_watch( level.jeep_player_arms, "watch_sync_generic_crouch", "digital_watch", "tag_player",false );
//	}
//	
//	level.player SetPlayerAngles((level.player.angles[0], level.player.angles[1], 0));
//	level.player.origin = level.jeep_player_arms GetTagOrigin("tag_player");
//	level.player PlayerLinkToDelta( level.jeep_player_arms, "tag_player", .9 );	
//}
//
//player_stand_reveal()
//{
//	flag_wait("start_playerstand_reveal");	
//	level.player SetStance("stand");
//}

//attach_bags_to_jeep()
//{
//	foreach(bag in level.bags)
//	{
//		bag LinkTo(level.jeep);
//	}
//}
// support code //

//create_overlay_element( shader_name, start_alpha )
//{
//	overlay = newHudElem();
//	overlay.x = 0;
//	overlay.y = 0;
//	overlay setshader( shader_name, 640, 480 );
//	overlay.alignX = "left";
//	overlay.alignY = "top";
//	overlay.horzAlign = "fullscreen";
//	overlay.vertAlign = "fullscreen";
//	overlay.alpha = start_alpha;
//	overlay.foreground = true;
//	overlay.sort = 2;
//	return overlay;
//}
//
//add_living_ai_to_array( guys )
//{
//    groupguys = [];
//	
//	foreach ( guy in guys )
//	{
//		if ( IsAlive( guy ) )
//		{
//			groupguys[ groupguys.size ] = guy;
//		}	
//	}
//	
//	return groupguys;
//}
//
//delete_corpse_in_volume( volume )
//{
//	Assert( IsDefined( volume ) );
//	if ( self IsTouching( volume ) )
//		self Delete();
//}

checkpoint_patrol (enable )
{
	self endon("death");
	
	self.ignoreall = enable;
	self.disablearrivals = enable;
	self.disableexits = enable;

	self.animname = "generic";
	
	patrol_anim = level.checkpoint_patrol_anim[1]; //randomint(level.checkpoint_patrol_anim.size)
			
	self set_run_anim( patrol_anim );
	self thread disable_checkpoint_patrol();
}

disable_checkpoint_patrol()
{
	self endon("death");
	
	flag_wait_any("start_enemies_provoked_early","start_enemies_weaponsfree");
	
	wait 3;
	
	self.ignoreall = false;
	self.disablearrivals = 0;
	self.disableexits = 0;

	self clear_run_anim();
}

damage_watcher_intro()
{
	self endon("death");

		self waittill("damage",amount,attacker);
		
		if ( attacker == level.player )
		{
			//level notify("destroy_player");
			flag_set("destroy_player_intro");
		}
	
}

damage_watcher_ambush( additional_end )
{
	self endon("death");
	level endon( "ambush_destroy_player_off" );
	
	if(IsDefined(additional_end))
		level endon(additional_end);
	
	self waittill("damage",amount,attacker);
		
	if ( attacker == level.player )
	{
		//level notify("destroy_player");
		flag_set("destroy_player_ambush");
		level notify("destroy_player_ambush");
	}
}

bullet_watcher_ambush()
{
	//level endon("destroy_player_ambush");
	level endon( "ambush_destroy_player_off" );
	//thread enable_stab_flag_test();
	level.player waittill( "weapon_fired" );
		
	//level notify("destroy_player");
	flag_set("destroy_player_ambush");
	level notify("destroy_player_ambush");
}

//enable_stab_flag_test()
//{
//	flag_wait("enable_stab");
//	IPrintLn("test");
//}
destroy_player_intro()
{
	self endon("death");
	flag_wait("destroy_player_intro");
	
	wait 1;
	
	self.ignoreall = false;
	level.player.ignoreme = false;
	self Vehicle_SetSpeed(0,RandomIntRange(5,35));
		
	if( self.vehicletype == "uaz" )
	{
		wait 1;
		self vehicle_unload();
	}
	
	if( self.vehicletype == "btr80" )
	{
		wait 3;
		self btr_fire_logic();
	}
	
	if( self.vehicletype == "humvee" )
	{
		wait 1;
		self vehicle_unload();
	}
}

destroy_player_ambush()
{
	self endon("death");
	//level endon( "ambush_destroy_player_off" );
	
	flag_wait("destroy_player_ambush");
	level notify("destroy_player_ambush");
		
	self.ignoreall = false;
	level.player.ignoreme = false;
	foreach(guy in level.allies)
	{
		guy.ignoreme = false;
	}
	
	if( self.vehicletype == "btr80" )
	{	
		if(flag("btr_reverse_here"))
		{
			self Vehicle_SetSpeed(0,99999,99999);
			
			wait 1.5;
			
			self.script_vehicle_selfremove = 1;
			self.attachedpath = undefined;
		    self notify( "newpath" );
		    self Vehicle_SetSpeed( 1, 4, 4 ); //needed to get the vehicle moving
	    	self ResumeSpeed( 3 );
			path = GetVehicleNode( "btr_failsafe_path", "targetname" );
			self thread vehicle_paths( path );
		    self StartPath( path );
			
			self.veh_transmission = "reverse";
			self vehicle_wheels_backward();
			
			wait 1;
		
			self thread btr_fire_logic();
			
			wait 3;
			
			self Vehicle_SetSpeed(0,99999,99999);
		}
		else
		{
	
			self Vehicle_SetSpeed(0,99999,99999);
			
			wait 2;
			
			self thread btr_fire_logic();
		}
		
		wait 3.5;
		level.allies[1] char_dialog_add_and_go("clockwork_bkr_abortmission");
		mission_failed_intro();
	}
	
		
	if( self.vehicletype == "humvee" )
	{
		self Vehicle_SetSpeed(0,RandomIntRange(5,7));
		
		//self.dontunloadonend = false;
		wait 1;
		self vehicle_unload();
		foreach(guy in level.ambush_enemies)
		{
			guy gun_recall();
			guy.health = 100;
	  		guy.delete_on_death = true;
	  		guy.a.nodeath = false;
			guy.allowdeath = true;
			guy.allowpain = true;
	    	guy.no_pain_sound = false;
	    	guy.diequietly = false;
			//guy.dontevershoot = false;	
			guy.noragdoll = false;
			guy.nocorpsedelete = false;
			guy Unlink();
			guy.ignoreall = false;
			guy.ignoreme = false;			
		}
	}
	
	level.allies[0].ignoreall = false;
	level.allies[0].ignoreme = false;
	level.allies[0] anim_stopanimscripted();
	
	level.allies[1].ignoreall = false;
	level.allies[1].ignoreme = false;
	level.allies[1] anim_stopanimscripted();
		
	level.allies[2].ignoreall = false;
	level.allies[2].ignoreme = false;
	level.allies[2] anim_stopanimscripted();
	

}

destroy_player_ambush_vo()
{
	flag_wait("destroy_player_ambush");
	level.allies[1] thread char_dialog_add_and_go("clockwork_bkr_damnitrook");
}
notify_ambush_destroy_player_off()
{
	flag_wait("ambush_destroy_player_off");
	level notify("ambush_destroy_player_off");
}

mission_failed_intro()
{
	SetDvar( "ui_deadquote", &"CLOCKWORK_QUOTE_COMPROMISE" );
	maps\_utility::missionFailedWrapper();
}

btr_fire_logic()
{	
	/*
	foreach(guy in level.allies)
	{
		toAttack = self SightConeTrace(guy);
		
		if(toAttack)
		{
			guy stop_magic_bullet_shield();
			self SetTurretTargetEnt( toAttack );
		}
	}
	*/
	
	while(true)
	{
		self btr_burst(3, 0.75, level.player);
		wait 2;
	}

}

btr_burst( burstshots, accuracyScalar, target )
{
	for( i = 0; i < burstShots; i++ )
	{
		turret_org = self GetTagOrigin( "tag_turret2" );
					
		x = target.origin[ 0 ] + RandomIntRange( -64, 64 ) * accuracyScalar;
		y = target.origin[ 1 ] + RandomIntRange( -64, 64 ) * accuracyScalar;
		z = target.origin[ 2 ] + RandomIntRange( -32, 0 )  * accuracyScalar;
		targetOrigin = ( x, y, z );
					
		angles = VectorToAngles( targetOrigin - turret_org );
		forward = AnglesToForward( angles );
		vec = ( forward* 12 );
		end = turret_org + vec;
					
		PlayFX( getfx( "bmp_flash_wv" ), turret_org, forward, ( 0,0,1 ) );
		MagicBullet( "btr80_turret_castle", turret_org, end );
	
		self PlaySound( "btr80_fire" ); 
		
		//shot delay
		wait( RandomFloatRange( .10, .2 ) );
		
		// deleted btr80_fire
	}
}

//veh_origin_angles_printout()
//{
//
//	while(1)
//	{
//		IPrintLn( self.origin );
//		IPrintLn( self.angles );
//		wait .25;
//	}
//}
//
//intro_hero_stances()
//{
//	foreach(ally in level.allies)
//	{
//		ally AllowedStances("crouch");
//	}
//}
//
//reset_intro_hero_stances()
//{
//	foreach(ally in level.allies)
//	{
//		ally AllowedStances("crouch", "stand", "prone");
//	}
//}

blackout_timer( iSeconds, sLabel, bUseTick, startpoint )
{
	level endon("blackout_early");
	
	switch(startpoint)
	{
		case 0: //normal
			if ( getdvar( "notimer" ) == "1" )
				return;
		
			if ( !isdefined( bUseTick ) )
				bUseTick = false;
			// destroy any previous timer just in case
			//level endon( "kill_timer" );
		
			// -- timer setup --	
			level.hudTimerIndex = 20;
			level.timer = maps\_hud_util::get_countdown_hud( -250 );
			level.timer SetPulseFX( 30, 900000, 700 );// something, decay start, decay duration
			level.timer.label = sLabel;
			level.timer settenthstimer( iSeconds );
			level.start_time = gettime();
		
			// -- timer expired --
			//if ( bUseTick == true )
				//thread timer_tick();
				
			wait (iSeconds - 15);
			break;
		case 1: //startpoint
				
				if ( getdvar( "notimer" ) == "1" )
				return;
		
			if ( !isdefined( bUseTick ) )
				bUseTick = false;
			// destroy any previous timer just in case
			//level endon( "kill_timer" );
		
			// -- timer setup --	
			level.hudTimerIndex = 20;
			level.timer = maps\_hud_util::get_countdown_hud( -250 );
			level.timer SetPulseFX( 30, 900000, 700 );// something, decay start, decay duration
			level.timer.label = sLabel;
			level.timer settenthstimer( iSeconds );
			level.start_time = gettime();
		
			// -- timer expired --
			//if ( bUseTick == true )
				//thread timer_tick();
		
			wait(26);
			break;
	}
	
	thread radio_dialog_add_and_go("clockwork_diz_15secs");
	
	thread maps\clockwork_audio::lights_out_music();
	thread maps\clockwork_audio::timer_tick();
	
	wait(14);
	
	flag_set("allies_prep_lightsout");
	flag_set("nvg_gun_up");

	level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_readynvgs");
	
	wait 1;
	
	//do blackout
	flag_set( "lights_out" );
	flag_set("lights_off");
	
	level notify("ready_nvgs");
	
	level.timer destroy();
}

//timer_tick()
//{
//	//level endon( "obj_escape_complete" );
//	level endon( "kill_timer" );
//	while ( true )
//	{
//		wait( 1 );
//		level.player thread play_sound_on_entity( "countdown_beep" );
//	}
//}

vehicle_play_guy_anim(anime, guy, pos, playIdle)
{	 
    animpos = anim_pos( self, pos );
    animation = guy getanim(anime);
    
    guy notify ("newanim");
    guy endon( "newanim" );
    guy endon( "death" );
    
	//self animontag(guy, animpos.sittag, animation );
	self anim_single_solo(guy, anime, animpos.sittag);
	
	if(!IsDefined(playIdle) || playIdle == true)
	{
		self guy_idle(guy, pos); 	
	}
}

waittill_any_notify_or_timeout(string1, string2, string3, timer )
{
	if ( isdefined( string1 ) )
		self endon( string1 );
	
	if ( isdefined( string2 ) )
		self endon( string2 );
	
	if ( isdefined( string3 ) )
		self endon( string3 );
	
	wait (timer);
}

//swap_ally_heads()
//{
//	flag_wait( "FLAG_swap_ally_heads" );
//	
//	head_model = "head_opforce_arab_c";
//	
//	foreach(dude in level.allies)
//	{
//		dude Detach( dude.headmodel , "" );
//		dude Attach( head_model, "", true );
//		dude.headmodel = head_model;
//	}
//}

entrance_drones()
{
	flag_wait("FLAG_entrance_drones");
	//thread spotlight_road();
	//thread maps\clockwork_fx::turn_effects_on("intro_spotlight","fx/lights/light_search_clockwork");
	
	wait 2;
	flag_set("spotlight_track_player");
	
	drones_patrol = array_spawn_targetname("exterior_tunnel_guards_patrol");
	drones = array_spawn_targetname("exterior_tunnel_guards");
	
	
	
	foreach(guy in drones_patrol)
	{
		//guy set_run_anim( "walk_gun_unwary" );
		guy.runAnim = getGenericAnim( "active_patrolwalk_gundown" );
		if(IsDefined(self.animation))
		{
			guy.idleAnim = getGenericAnim( self.animation );
	}
}
}

//spotlight_road()
//{
//	road_spotlight = GetEnt( "intro_spotlight", "targetname" );
//	org = spawn( "script_origin", road_spotlight.origin );
//	org LinkTo(road_spotlight);
//	
//	org.angles = VectorToAngles(level.player.origin - road_spotlight.origin);
//	fwd = AnglesToForward( org.angles );
//	PlayFXontag( getfx("fx/lights/light_search_clockwork"),road_spotlight,"searchlight_body_straight_lod0");
//	
//	road_spotlight endon( "death" );
//	
//	while(!flag("entering_blackbird_vo"))
//	{
//		wait .1;
//		org.angles = VectorToAngles(level.player.origin - road_spotlight.origin );
//		road_spotlight RotateTo( org.angles , .25, .1, .1 );
//	}
//	
//	StopFXOnTag(getfx("fx/lights/light_search_clockwork"),road_spotlight,"searchlight_body_straight_lod0");
//}

player_failcase_tunnel()
{
	thread player_failcase_tunnel_overrun();
	level endon("player_in_jeep");
	
	nags =[];
	nags[0] ="clockwork_bkr_getbackhererook";
	nags[1] ="clockwork_bkr_rookreturntothe";
	nags[2] ="clockwork_bkr_rookwhereyagoing";
	
	while(true)
	{
	flag_wait("FLAG_player_failcase_tunnel");
		nagline = 0;
	
		while(flag("FLAG_player_failcase_tunnel"))
		{
			if (nagline > nags.size - 1)
			{
				SetDvar( "ui_deadquote", &"CLOCKWORK_QUOTE_LEFT_TEAM" );
				maps\_utility::missionFailedWrapper();
				break;
			}
	
			level.allies[0] char_dialog_add_and_go(nags[nagline]);
			nagline++;
			
			wait( randomfloatrange( 2, 4 ) );	
		}
	}
}

player_failcase_tunnel_overrun()
{
	level endon("player_in_jeep");
	flag_wait("FLAG_player_failcase_tunnel_overrun");
	SetDvar( "ui_deadquote", &"CLOCKWORK_QUOTE_LEFT_TEAM" );
	maps\_utility::missionFailedWrapper();
}

setup_optional_objective()
{
	level endon( "optional_objective_skipped" );
	thread cleanup_optional_objective();
	
	intel = GetEnt( "optional_objective_object", "targetname" );
	intel_glow = GetEnt( "optional_objective_object_glow", "targetname" );
	
	intel MakeUsable();
	//"Press and hold [{+usereload}] to retrieve intel."
	intel SetHintString( &"CLOCKWORK_OPTIONAL_PICKUP" );
	intel waittill( "trigger" );
	
	intel Delete();
	intel_glow Delete();
	
	flag_set( "obj_optional_scientist_activated" );
	
	thread optional_objective();
	
	radio_dialog_add_and_go( "clockwork_diz_inteluploadedsecondary" );
}

optional_objective()
{
	optional_obj = obj( "optional" );
	//"(Optional) Kill Dr. Barros and retrieve any additional intel on his person"
	Objective_Add( optional_obj, "active", &"CLOCKWORK_OBJ_OPTIONAL" );
	Objective_State( optional_obj, "current" );

	flag_wait( "obj_optional_scientist_complete" );

	Objective_State( optional_obj, "done" );
}

cleanup_optional_objective()
{
	level endon( "obj_optional_scientist_activated" );
	level waittill( "player_in_jeep" );
	
	level notify( "optional_objective_skipped" );
	
	intel = GetEnt( "optional_objective_object", "targetname" );
	intel_glow = GetEnt( "optional_objective_object_glow", "targetname" );

	intel Delete();
	intel_glow Delete();
}