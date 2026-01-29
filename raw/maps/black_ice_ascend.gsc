#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
start()
{
	iprintln( "Ascend" );
	maps\black_ice_util::player_start( "player_start_ascend" );
	vision_set_fog_changes( "black_ice_catwalks", 0 );
	
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_oilrig_catwalk", 2 );
	
	// teleport allies
	if ( level._allies.size < 2 )
	{
		level maps\black_ice_util::spawn_allies();
	}
	
	// init allies
	array_thread( level._allies, ::set_ignoreSuppression, true );
	
	ascend_anim_node = getstruct( "vignette_alpha_team_rigascend", "script_noteworthy" );
	
	// check for bravo setup
	if( level._bravo.size < 2 )
	{
		// spawn bravo
		level maps\black_ice_util::spawn_bravo();
	}
	
	bravo_ascend_anim_node = getstruct( "vignette_beta_rig_ascend", "script_noteworthy" );
	
	// move allies to ascend position
	node = GetNode( "bc_node_ascend_ally1", "targetname" );
	level._allies[0] ForceTeleport( node.origin, node.angles );
	level._allies[0] thread follow_path( node );
	node = GetNode( "bc_node_ascend_ally2", "targetname" );
	level._allies[1] ForceTeleport( node.origin, node.angles );
	level._allies[1] thread follow_path( node );
	node = GetNode( "bc_node_ascend_bravo1", "targetname" );
	level._bravo[1] ForceTeleport( node.origin, node.angles );
	level._bravo[1] thread follow_path( node );
	node = GetNode( "bc_node_ascend_bravo2", "targetname" );
	level._bravo[0] ForceTeleport( node.origin, node.angles );
	level._bravo[0] thread follow_path( node );
	
	level.launchers_attached = false;
	level.ascend_waiting = true;
	
	// start spotlights
	flag_set( "bc_flag_spots_close" );
	thread maps\black_ice_camp::main_spot();
	thread maps\black_ice_camp::fake_spot( "cw_spotlight_2", "cw_spot_2_org" );
	thread maps\black_ice_camp::fake_spot( "cw_spotlight_3", "cw_spot_3_org" );
	
	//start ground snow
	thread maps\black_ice_camp::ascend_snow_fx();
	
	// Cargo
	thread hanging_cargo_motion();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	level.ascend_launch_pos = getstruct( "ascend_launch_pos", "script_noteworthy" );
	
	if ( !IsDefined( level.ascend_anim_node ) )
	{
		level.ascend_anim_node = getstruct( "vignette_alpha_team_rigascend", "script_noteworthy" );
	}
	
	level.bravo_ascend_anim_node = getstruct( "vignette_beta_rig_ascend", "script_noteworthy" );
	level.bravo_ascend_anim_node.origin = level.ascend_anim_node.origin;
	level.bravo_ascend_anim_node.angles = level.ascend_anim_node.angles;
	level.player_ascend_anim_node = GetEnt( "vignette_alpha_player_rigascend", "script_noteworthy" );
	
	level.sfx_ascend_check = "stop";
	level.sfx_ascend_node = spawn( "script_origin", (1414, 3969, 4069) );
	
	init_ascend_vars();
		
	thread start_catwalk_snow();
	thread ascend_dialog();
	thread ascend_vision_sets();
	thread ascend_logic();
}

//*******************************************************************
//																	*
//		VISION SET CHANGES											*
//*******************************************************************
ascend_vision_sets()
{
	// player starts ascending
	flag_wait( "flag_ascend_start" );
	vision_set_fog_changes( "black_ice_catwalks", 7 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_flag_inits()
{
	flag_init( "flag_ascend_triggered" );
	flag_init( "flag_ascend_start" );
	flag_init( "flag_ascend_bravo_go" );
	flag_init( "flag_player_ascending" );
	flag_init( "flag_bravo_ascend_complete" );
	flag_init( "flag_alpha_ascend_complete" );
	flag_init( "flag_ascend_end" );
	flag_init( "flag_player_line_launched" );
	flag_init( "flag_dialog_dontstop" );
	flag_init( "flag_dialog_weaponsfree" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	add_hint_string( "hint_ascend_init", &"BLACK_ICE_ASCEND_INIT", ::hint_ascend_init_func );
	add_hint_string( "hint_ascend_launch", &"BLACK_ICE_ASCEND_LAUNCH", ::hint_ascend_func );
	add_hint_string( "hint_ascend", &"BLACK_ICE_ASCEND_ASCEND", ::hint_ascend_func );
	
	PreCacheModel( "black_ice_rope_prop" );
	PreCacheModel( "black_ice_rope_prop_obj" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ally_setup()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_setup( clamp_angles, rig_origin, rig_angles )
{
	if ( !IsDefined( clamp_angles ) )
	{
		clamp_angles = 60;
	}
	
	maps\black_ice_util::setup_player_for_animated_sequence( true, clamp_angles, rig_origin, rig_angles, false, undefined );
}
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
enemy_setup()
{
	level.ascend_enemy = maps\_vignette_util::vignette_actor_spawn( "ascend_enemy", "opfor" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
props_setup()
{
	level.ascend_launcher = spawn_anim_model( "ascend_launcher" );
	level.ascend_ascender = spawn_anim_model( "ascend_ascender" );
	
	level.ascend_hook = spawn_anim_model( "ascend_hook" );
	level.ascend_hook_ally1 = spawn_anim_model( "ascend_hook_ally1" );
	level.ascend_hook_ally2 = spawn_anim_model( "ascend_hook_ally2" );
	level.ascend_hook_ally3 = spawn_anim_model( "ascend_hook_ally3" );
	level.ascend_hook_ally4 = spawn_anim_model( "ascend_hook_ally4" );
	
	level.ascend_launcher Hide();
	level.ascend_ascender Hide();
	level.ascend_hook Hide();
	level.ascend_hook_ally1 Hide();
	level.ascend_hook_ally2 Hide();
	level.ascend_hook_ally3 Hide();
	level.ascend_hook_ally4 Hide();
	
	if ( !IsDefined( level.ally1_ascend_launcher ) )
	{
		level.ally1_ascend_launcher = spawn_anim_model( "ally1_ascend_launcher" );
		level.ally2_ascend_launcher = spawn_anim_model( "ally2_ascend_launcher" );
	}
	
	level.ally1_ascend_ascender = spawn_anim_model( "ally1_ascend_ascender" );
	level.ally2_ascend_ascender = spawn_anim_model( "ally2_ascend_ascender" );
	
	level.ally1_ascend_ascender Hide();
	level.ally2_ascend_ascender Hide();
	
	level.ascend_rope1 = spawn_anim_model( "ascend_rope1" );
	level.ascend_rope2 = spawn_anim_model( "ascend_rope2" );
	level.ascend_rope3 = spawn_anim_model( "ascend_rope3" );
	
	level.ascend_rope1 Hide();
	level.ascend_rope2 Hide();
	level.ascend_rope3 Hide();
	
	if ( !IsDefined( level.bravo1_ascend_launcher ) )
	{
		level.bravo1_ascend_launcher = spawn_anim_model( "bravo1_ascend_launcher" );
		level.bravo2_ascend_launcher = spawn_anim_model( "bravo2_ascend_launcher" );
	}
	
	if ( !IsDefined( level.bravo1_ascend_ascender ) )
	{
		level.bravo1_ascend_ascender = spawn_anim_model( "bravo1_ascend_ascender" );
		level.bravo2_ascend_ascender = spawn_anim_model( "bravo2_ascend_ascender" );
		
		level.bravo1_ascend_ascender Hide();
		level.bravo2_ascend_ascender Hide();
	}
	
	if ( !IsDefined( level.bravo_ascend_rope1 ) )
	{
		level.bravo_ascend_rope1 = spawn_anim_model( "bravo_ascend_rope1" );
		level.bravo_ascend_rope2 = spawn_anim_model( "bravo_ascend_rope2" );
		
		level.bravo_ascend_rope1 Hide();
		level.bravo_ascend_rope2 Hide();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_ascend_vars()
{
	// const value ascend anims will run at (default is 1.0)
	level.ASCEND_ANIMS_RATE = 1.0;
	
	level.allow_player_ascend_move = 0;
	level.ascend_current_rate = 0.0;
	level.bravo_curr_rate = level.ASCEND_ANIMS_RATE;
	level.alpha_curr_rate = level.ASCEND_ANIMS_RATE;
}

start_catwalk_snow()
{

	level waittill( "notify_start_catwalks_snow" );

	exploder( "catwalks_snow" );
	exploder( "catwalks_lights" );
	
	wait 0.1;
	stop_exploder( "ascend_snow_huge" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_dialog()
{
	
	//wait for player to trigger sequence
	level waittill( "notify_ascend_linesout" );
	
	//dialog for shooting out lines and nagging player
	thread dialog_linesout();
	
	//wait for player to shoot line
	level waittill( "notify_ascend_dialog_splitoff" );
	
	//baker instructs alpha and bravo
	wait( 1.0 );
	smart_radio_dialogue( "black_ice_bkr_rogersdiazyouarebravo" );
	smart_radio_dialogue( "blackice_diz_atthetop" );
	smart_radio_dialogue( "black_ice_bkr_rookfuentesstickwithme" );
	if( !flag( "flag_player_ascending"  )  )
		smart_radio_dialogue( "blackice_bkr_yourmarkrook" );

	//wait for fuentes to get to the top and take down the tango
	level waittill( "notify_ascend_dialog5" );
	smart_radio_dialogue( "blackice_fnt_aboveyou" );
	smart_radio_dialogue( "blackice_grn_grunt" );
	smart_radio_dialogue( "blackice_grn_bravosup" );
	
	//wait for bakers line right before getting up and over the top
	if( !flag( "flag_dialog_weaponsfree" ))
	{
		//if enough time, put in this filler line.  This state will only happen if the player waits a long time to ascend.
		if( !flag( "flag_dialog_dontstop" ))
		{
			flag_wait( "flag_dialog_dontstop" );	
			thread smart_radio_dialogue( "blackice_bkr_inrange" );
		}
		flag_wait( "flag_dialog_weaponsfree" );
	}

	//deliver bakers line right before getting up and over the top
	smart_radio_dialogue( "black_ice_bkr_getreadyweaponsfree" );

}

dialog_linesout()
{
	//baker instructs
	smart_radio_dialogue( "blackice_bkr_linesuphere" );
	
	wait( 0.8 );
	
	//if time(player has not shot yet), diaz delivers line
	if ( !flag( "flag_player_line_launched" ))
		smart_radio_dialogue( "blackice_diz_lineout" );
	
	wait( 3.0 );
	
	//nag the player
	if ( !flag( "flag_player_line_launched" ))
		smart_radio_dialogue( "blackice_bkr_ropeup" );
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
runin_to_ascend( runin_node )
{
	// self is the AI ally
		
	// Anim reach to the runin positions
	runin_node anim_reach_solo( self, "ascend_runin" );
	
	// Destroy the (temp) non-animated models
	self Detach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
	
	// Animate the launcher & dude simultaneously
	self.launcher Show();
	
	anim_array = [];
	anim_array[0] = self;
	anim_array[1] = self.launcher;
	
	// This blocks execution
	runin_node anim_single( anim_array, "ascend_runin" );
	
	// Now play idles
	level.ascend_anim_node thread anim_loop( anim_array, "ascend_waiting", "stop_loop" );
	
	level.allies_ascend_ready++;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_logic()
{
	level.player endon( "death" );
	
	ally_setup();
	props_setup();
	
	thread bravo_ascend();
	
	guys = [];
	guys["ally1"] = level._allies[0];
	guys["ally2"] = level._allies[1];
	guys["ally1_ascend_launcher"] = level.ally1_ascend_launcher;
	guys["ally2_ascend_launcher"] = level.ally2_ascend_launcher;
	
	// Destroy the (temp) non-animated models
	if ( IsDefined( level.launchers_attached ) && level.launchers_attached )
	{
		level._allies[0] Detach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
		level._allies[1] Detach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
		level.launchers_attached = false;
	}
	
	// This happens when starting from the 'ascend' checkpoint
	if ( IsDefined( level.ascend_waiting ) && level.ascend_waiting )
	{
		level.ascend_anim_node thread anim_loop( guys, "ascend_waiting", "stop_loop" );
	}
	
	// First, wait for player to press 'x' to initiate the sequence
	level.ascend_launch_pos.hint_active = false;
	
	thread hint_ascend_init_watcher();
	
	level.ascend_launch_pos waittill( "trigger" );
	level.ascend_launch_pos = undefined;
	
	flag_set( "flag_ascend_triggered" );
	
	// Destroy assets from the ice breach
	maps\black_ice_swim::destroy_persistent_ice_breach_props();
	
	guys["ascend_rope2"] = level.ascend_rope2;
	guys["ascend_rope3"] = level.ascend_rope3;
	
	level.ascend_rope2 Show();
	level.ascend_rope3 Show();
	
	level.ascend_anim_node notify( "stop_loop" );

	// Play rope shoot anims
	level.ascend_anim_node thread anim_reach( level._allies, "alpha_rope_shoot" );
	level.ascend_anim_node thread anim_single( guys, "alpha_rope_shoot" );
	
	// Need to do some blending magic ---
	blend_time = 1.0;
	maps\black_ice_util::player_animated_sequence_restrictions();
	blend_player_rig = spawn_anim_model( "player_rig" );
	blend_player_rig.origin = level.player.origin;
	blend_player_rig.angles = level.player.angles;
	blend_player_rig Hide();
	level.player_ascend_anim_node thread anim_single_solo( blend_player_rig, "alpha_rig_ascend_aim" );
	level.player PlayerLinkToBlend( blend_player_rig, "tag_player", blend_time );
	blend_player_rig thread wait_and_unhide_ascend_aim_assets( blend_time );
	// ---
	
	//AUDIO: starting player rig ascend sfx
	thread maps\black_ice_audio::sfx_blackice_rig_start_ss();
	
	// AUDIO: stopping distant rig sfx
	thread maps\black_ice_audio::sfx_stop_dist_oil_rig();
	
	// Create the player array with everything except the rig
	level.player_legs = spawn_anim_model( "player_legs_ascend" );
	player_array["player_legs"] = level.player_legs;
	player_array["ascend_rope1"] = level.ascend_rope1;
	player_array["ascend_ascender"] = level.ascend_ascender;
	
	level.ascend_rope1 Show();
	
	//vo for lines out
	level notify( "notify_ascend_linesout" );
	
	// Blocks until player gets to the aiming portion of the sequence
	level.ascend_launcher.origin = level.player.origin;
	level.ascend_launcher.angles = level.player.angles;
	level.player_ascend_anim_node anim_single_solo( level.ascend_launcher, "alpha_rig_ascend_aim" );
	
	// Destroy the temp rig & launcher, create the new ones, play loop anims
	level.player Unlink();
	player_setup( 0.01, blend_player_rig.origin, blend_player_rig.angles );
	blend_player_rig Delete();
	player_array["player_rig"] = level.player_rig;
	
	new_ascend_launcher = spawn_anim_model( "ascend_launcher" );
	new_ascend_launcher.origin = level.ascend_launcher.origin;
	new_ascend_launcher.angles = level.ascend_launcher.angles;
	level.ascend_launcher Delete();
	level.ascend_launcher = new_ascend_launcher;
	
	// Play the aim loops
	//level.player_ascend_anim_node thread anim_loop_solo( level.player_rig, "alpha_rig_ascend_aim_loop", "stop_loop" );
	//level.player_ascend_anim_node thread anim_loop_solo( level.ascend_launcher, "alpha_rig_ascend_aim_loop", "stop_loop" );
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "alpha_rig_ascend_aim_loop" ][0], 1, 0, 1 );
	level.ascend_launcher SetAnim( level.scr_anim[ "ascend_launcher" ][ "alpha_rig_ascend_aim_loop" ][0], 1, 0, 1 );
	
	level.player_rig thread ascend_aim_logic();

	// Pause the allies from shooting
	anim_set_rate( guys, "alpha_rope_shoot", 0.0 );
	
	// Wait for player to launch rope
	display_hint_timeout( "hint_ascend_launch" );
	
	// Turn on the detailed flare stack
	thread maps\black_ice::flarestack_swap();
	
	// While we're waiting for player to launch rope, we allow allies to fire after a delay
	ally_launch_delay = 2000;
	start_time = GetTime();
	while ( !( level.player AttackButtonPressed() ) )
	{
		if ( !IsDefined( level._allies[0].line_shot ) || !level._allies[0].line_shot )
		{
			if ( GetTime() - start_time > ally_launch_delay )
			{
				//Audio - playing ally ascender launches 2nd round
				thread maps\black_ice_audio::sfx_blackice_rig_start3_ss();
				anim_set_rate( guys, "alpha_rope_shoot", 1.0 );
				level._allies[0].line_shot = true;
			}
		}
		else
		{
			// Need to go into waiting loop once allies have launched
			if ( !IsDefined( level._allies[0].waiting ) || !level._allies[0].waiting )
			{
				if ( level._allies[0] maps\black_ice_util::check_anim_time( "ally1", "alpha_rope_shoot", 1.0 ) )
				{
					guys["ally1_ascend_ascender"] = level.ally1_ascend_ascender;
					guys["ally2_ascend_ascender"] = level.ally2_ascend_ascender;
					
					level.ally1_ascend_ascender Show();
					level.ally2_ascend_ascender Show();
					
					level.ascend_anim_node thread anim_loop( guys, "alpha_hand_rope", "stop_loop" );
					
					level._allies[0].waiting = true;
				}
			}
		}
		
		wait level.TIMESTEP;
	}
	
	level notify( "ascend_rope_launched" );
	flag_set( "flag_player_line_launched"  );	
	
	// ready player for ascend
	SetThreatBias( "player", "axis", -256 );
	
	// If allies have not launched, then launch now
	if ( !IsDefined( level._allies[0].line_shot ) || !level._allies[0].line_shot )
	{
		//Audio - playing ally ascender launches 2nd round
		thread maps\black_ice_audio::sfx_blackice_rig_start3_ss();
		anim_set_rate( guys, "alpha_rope_shoot", 1.0 );
	}
	
	// Player launch and linkup anims
	level.ascend_ascender Show();
	level.player_ascend_anim_node notify( "stop_loop" );
	
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "alpha_rig_ascend_aim_loop" ][0], 0, 0, 1 );
	level.ascend_launcher SetAnim( level.scr_anim[ "ascend_launcher" ][ "alpha_rig_ascend_aim_loop" ][0], 0, 0, 1 );
	
	level.player_ascend_anim_node thread anim_single( player_array, "alpha_rig_ascend_linkup" );
	level.player_ascend_anim_node thread anim_single_solo( level.ascend_launcher, "alpha_rig_ascend_linkup" );
	
	level notify( "notify_ascend_dialog_splitoff" );
	
//	// In order to proceed, both alpha_rope_shoot (allies) & alpha_rig_ascend_linkup (player) anims need to complete
	while ( 1 )
	{
		// If allies are not already playing waiting loop
		if ( !IsDefined( level._allies[0].waiting ) || !level._allies[0].waiting )
		{
			// And their shoot anims complete
			if ( level._allies[0] maps\black_ice_util::check_anim_time( "ally1", "alpha_rope_shoot", 1.0 ) )
			{
				// Play waiting loop
				guys["ally1_ascend_ascender"] = level.ally1_ascend_ascender;
				guys["ally2_ascend_ascender"] = level.ally2_ascend_ascender;
				
				level.ally1_ascend_ascender Show();
				level.ally2_ascend_ascender Show();
				
				level.ascend_anim_node thread anim_loop( guys, "alpha_hand_rope", "stop_loop" );
				
				level._allies[0].waiting = true;
			}
		}
		
		// If player is not already playing waiting loop
		if ( !IsDefined( level.player.waiting ) || !level.player.waiting )
		{
			// And his shoot anim completes
			if ( level.player_rig maps\black_ice_util::check_anim_time( "player_rig", "alpha_rig_ascend_linkup", 1.0 ) )
			{	
				delayThread( 5, ::flag_set, "flag_ascend_start" );
				
				// Player idle loops
				level.player_ascend_anim_node thread anim_loop( player_array, "alpha_rig_ascend_groundidle", "stop_loop" );
				
				level.player.waiting = true;
			}
		}
		
		// Exit out when both allies & player are in waiting loops
		if ( IsDefined( level._allies[0].waiting ) && level._allies[0].waiting && IsDefined( level.player.waiting ) && level.player.waiting )
		{
			level.player.waiting = undefined;
			break;
		}
		
		wait level.TIMESTEP;
	}
	
	// Lerp player view back up
	view_lerp_time = 0.3;
	level.player LerpViewAngleClamp( view_lerp_time, 0, 0, 60, 60, 60, 60 );
	
	// Send bravo on their way
	//TAG CP: moving this flag to a notetrack in player hookup animation.  This way bravo can leave when the player is still hooking up.
	//flag_set( "flag_ascend_bravo_go" );

	//TAG CP: wait to let baker finish his VO and get bravo more separated from alpha.
	//wait( 1.0 );
	
	// Call this as soon as we allow the player to ascend
	calculate_bravo_rubberband_base();
	
	// Wait for player to begin ascending
	display_hint( "hint_ascend" );
	while ( !( level.player AttackButtonPressed() ) )
	{
		wait level.TIMESTEP;
	}
	
	flag_set( "flag_player_ascending" );
	
	level.player_ascend_anim_node notify( "stop_loop" );
	level.ascend_anim_node notify( "stop_loop" );
	
	// Need to link them to the node, so that we can manipulate the node to affect motion on all entities animating
	foreach ( thing in player_array )
	{
		thing LinkTo( level.player_ascend_anim_node );
	}
	
	//AUDIO: starting rig ascend sfx
	thread maps\black_ice_audio::sfx_rig_ascend_logic( "go" );
	
	// Lerp the view down (need it clamped so the anim has control of the camera)
	level.player LerpViewAngleClamp( view_lerp_time, 0, 0, 0, 0, 0, 0 );
	wait view_lerp_time;
	
	level.player_ascend_anim_node thread anim_single( player_array, "alpha_rig_ascend" );
	
	// Play the hook anim
	grapplehooks = [];
	grapplehooks["ascend_hook_ally1"] = level.ascend_hook_ally1;
	grapplehooks["ascend_hook_ally2"] = level.ascend_hook_ally2;
	grapplehooks["ascend_hook_ally3"] = level.ascend_hook_ally3;
	grapplehooks["ascend_hook_ally4"] = level.ascend_hook_ally4;
	
	level.player_ascend_anim_node thread anim_single_solo( level.ascend_hook, "ascend_hook" );
	level.ascend_anim_node thread anim_single( grapplehooks, "ascend_hook" );
	///
	level.ascend_hook Show();
	level.ascend_hook_ally1 Show();
	level.ascend_hook_ally2 Show();
	level.ascend_hook_ally3 Show();
	level.ascend_hook_ally4 Show();
	
	// Set some initial values for the anim state machine and thread off the mechanics
	level.ascend_state = "ascend";
	level.ascend_state_transition = false;
	level.start_ascend_time = GetTime();
	
	thread ascend_mechanics( player_array );
	
	level.player.ignoreme = true;
	
	// Rubberbanding
	thread alpha_ascend_rubberband( guys );
	thread alpha_ascend_rubberband_cleanup( guys );
	level.ascend_anim_node thread anim_single( guys, "alpha_rig_ascend" );
	
	thread post_ascend_cleanup();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_aim_logic()
{
	// self is the player_rig
	
	level endon( "ascend_rope_launched" );
	
	// Tweakables -------
	level.static_damping_factor = -7.2;
	level.kinetic_damping_factor = -1.2;
	level.accel_factor = 14.0;
	level.max_velocity = 2.4;
	// END Tweakables ---
	
	// Don't touch these -------
	self.up_velocity = 0.0;
	self.down_velocity = 0.0;
	self.left_velocity = 0.0;
	self.right_velocity = 0.0;
	
	self.up_weight = 0.0;
	self.down_weight = 0.0;
	self.left_weight = 0.0;
	self.right_weight = 0.0;
	// END ---------------------

	// Set parent nodes initially to zero
	self SetAnim( level.scr_anim[ "player_rig" ][ "rigascend_aim_left_parent" ], 0, 0 );
	self SetAnim( level.scr_anim[ "player_rig" ][ "rigascend_aim_right_parent" ], 0, 0 );
	self SetAnim( level.scr_anim[ "player_rig" ][ "rigascend_aim_up_parent" ], 0, 0 );
	self SetAnim( level.scr_anim[ "player_rig" ][ "rigascend_aim_down_parent" ], 0, 0 );
	
	level.ascend_launcher SetAnim( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_left_parent" ], 0, 0 );
	level.ascend_launcher SetAnim( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_right_parent" ], 0, 0 );
	level.ascend_launcher SetAnim( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_up_parent" ], 0, 0 );
	level.ascend_launcher SetAnim( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_down_parent" ], 0, 0 );
	
	self thread ascend_aim_logic_cleanup();
		
	while ( 1 )
	{
		///#
		//the_player_num = level.player_rig GetEntNum();
		//IPrintLnBold( the_player_num );
		//#/
		
		self ascend_aim_lerp_anims();

		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_aim_lerp_anims()
{
	// self is the player_rig
	
	level endon( "ascend_rope_launched" );
	
	// Grab analog input
	analog_current = level.player GetNormalizedCameraMovement();
	
	//IPrintLnBold( analog_current );
	
	push_up = ter_op( analog_current[0] > 0.1, true, false );
	push_down = ter_op( analog_current[0] < -0.1, true, false );
	push_left = ter_op( analog_current[1] <- 0.1, true, false );
	push_right = ter_op( analog_current[1] > 0.1, true, false );
	
	pos_up = ter_op( self.up_weight > 0.0, true, false );
	pos_down = ter_op( self.down_weight > 0.0, true, false );
	pos_left = ter_op( self.left_weight > 0.0, true, false );
	pos_right = ter_op( self.right_weight > 0.0, true, false );
	
	up_accel = 0.0;
	down_accel = 0.0;
	left_accel = 0.0;
	right_accel = 0.0;
	
	if ( push_up )
	{
		if ( !pos_down )
		{
			up_accel = analog_current[0];
		}
		else
		{
			down_accel = ( -1.0 * analog_current[0] );
		}
				
	}
	else if ( push_down )
	{
		if ( !pos_up )
		{
			down_accel = ( -1.0 * analog_current[0] );
		}
		else
		{
			up_accel = analog_current[0];
		}
	}
	
	if ( push_left )
	{
		if ( !pos_right )
		{
			left_accel = ( -1.0 * analog_current[1] );
		}
		else
		{
			right_accel = ( analog_current[1] );
		}
				
	}
	else if ( push_right )
	{
		if ( !pos_left )
		{
			right_accel = ( analog_current[1] );
		}
		else
		{
			left_accel = ( -1.0 * analog_current[1] );
		}
	}
	
	self.up_velocity += up_accel * level.accel_factor * level.TIMESTEP;
	self.down_velocity += down_accel * level.accel_factor * level.TIMESTEP;
	self.left_velocity += left_accel * level.accel_factor * level.TIMESTEP;
	self.right_velocity += right_accel * level.accel_factor * level.TIMESTEP;
	
	// Clamping -------
	self.up_velocity = ter_op( self.up_velocity > level.max_velocity, level.max_velocity, self.up_velocity );
	self.up_velocity = ter_op( self.up_velocity < ( -1 * level.max_velocity ), ( -1 * level.max_velocity ), self.up_velocity );
	self.down_velocity = ter_op( self.down_velocity > level.max_velocity, level.max_velocity, self.down_velocity );
	self.down_velocity = ter_op( self.down_velocity < ( -1 * level.max_velocity ), ( -1 * level.max_velocity ), self.down_velocity );
	self.left_velocity = ter_op( self.left_velocity > level.max_velocity, level.max_velocity, self.left_velocity );
	self.left_velocity = ter_op( self.left_velocity < ( -1 * level.max_velocity ), ( -1 * level.max_velocity ), self.left_velocity );
	self.right_velocity = ter_op( self.right_velocity > level.max_velocity, level.max_velocity, self.right_velocity );
	self.right_velocity = ter_op( self.right_velocity < ( -1 * level.max_velocity ), ( -1 * level.max_velocity ), self.right_velocity );
	// END Clamping ---
	
	// Select Damping Factor -------
	if ( !( push_up || push_down || push_left || push_right ) )
	{
		damping_factor = level.static_damping_factor;
	}
	else
	{
		damping_factor = level.kinetic_damping_factor;
	}
	// END Select Damping Factor ---
	
	// Air Resistance (damping) -------
	self.up_velocity += ( damping_factor * self.up_velocity * level.TIMESTEP );
	self.down_velocity += ( damping_factor * self.down_velocity * level.TIMESTEP );
	self.left_velocity += ( damping_factor * self.left_velocity * level.TIMESTEP );
	self.right_velocity += ( damping_factor * self.right_velocity * level.TIMESTEP );
	// END Air Resistance (damping) ---
	
	// Update Weight -------
	self.up_weight += ( self.up_velocity * level.TIMESTEP );
	self.down_weight += ( self.down_velocity * level.TIMESTEP );
	self.left_weight += ( self.left_velocity * level.TIMESTEP );
	self.right_weight += ( self.right_velocity * level.TIMESTEP );
	// END Update Weight ---
	
	// If we go negative, we need to "switch sides"
	if ( self.up_weight < 0.0 )
	{
		self.down_weight = ( -1.0 * self.up_weight );
		self.up_weight = 0.0;
		
		self.down_velocity = ( -1.0 * self.up_velocity );
		self.up_velocity = 0.0;
	}
	else if ( self.down_weight < 0.0 )
	{
		self.up_weight = ( -1.0 * self.down_weight );
		self.down_weight = 0.0;
		
		self.up_velocity = ( -1.0 * self.down_velocity );
		self.down_velocity = 0.0;
	}
	
	if ( self.left_weight < 0.0 )
	{
		self.right_weight = ( -1.0 * self.left_weight );
		self.left_weight = 0.0;
		
		self.right_velocity = ( -1.0 * self.left_velocity );
		self.left_velocity = 0.0;
	}
	else if ( self.right_weight < 0.0 )
	{
		self.left_weight = ( -1.0 * self.right_weight );
		self.right_weight = 0.0;
		
		self.left_velocity = ( -1.0 * self.right_velocity );
		self.right_velocity = 0.0;
	}
	
	// Clamp Weight -------
	self.left_weight = ter_op( self.left_weight > 1.0, 1.0, self.left_weight );
	self.right_weight = ter_op( self.right_weight > 1.0, 1.0, self.right_weight );
	self.up_weight = ter_op( self.up_weight > 1.0, 1.0, self.up_weight );
	self.down_weight = ter_op( self.down_weight > 1.0, 1.0, self.down_weight );
	// END Clamp Weight ---
	
	// Need to have the child anim set to 1 (every frame evidently), and use limited as we don't want to mess with the parent node
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_left" ], 1, 0 );
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_right" ], 1, 0 );
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_up" ], 1, 0 );
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_down" ], 1, 0 );
	
	// Now lerp the parent node weight
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_left_parent" ], self.left_weight, level.TIMESTEP );
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_right_parent" ], self.right_weight, level.TIMESTEP );
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_up_parent" ], self.up_weight, level.TIMESTEP );
	self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_down_parent" ], self.down_weight, level.TIMESTEP );
	
	// Launcher
	// Need to have the child anim set to 1 (every frame evidently), and use limited as we don't want to mess with the parent node
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_left" ], 1, 0 );
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_right" ], 1, 0 );
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_up" ], 1, 0 );
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_down" ], 1, 0 );
	
	// Now lerp the parent node weight
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_left_parent" ], self.left_weight, level.TIMESTEP );
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_right_parent" ], self.right_weight, level.TIMESTEP );
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_up_parent" ], self.up_weight, level.TIMESTEP );
	level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_down_parent" ], self.down_weight, level.TIMESTEP );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_aim_logic_cleanup()
{
	// self is player_rig
	
	level waittill( "ascend_rope_launched" );
	
	//Audio - playing player ascender launching sound
	thread maps\black_ice_audio::sfx_blackice_rig_start2_ss();
	
	lerp_time = 0.2;
	start_time = GetTime();
	
	// Lerp angles to zero over time
	level.player LerpViewAngleClamp( lerp_time, 0, 0, 0, 0, 0, 0 );
	
	left_rate = self.left_weight / ( lerp_time / level.TIMESTEP );
	right_rate = self.right_weight / ( lerp_time / level.TIMESTEP );
	up_rate = self.up_weight / ( lerp_time / level.TIMESTEP );
	down_rate = self.down_weight / ( lerp_time / level.TIMESTEP );
	
	while ( ( GetTime() - start_time ) < ( lerp_time * 1000 ) )
	{
		// lerp the weights to zero over time
		self.left_weight -= left_rate;
		self.right_weight -= right_rate;
		self.up_weight -= up_rate;
		self.down_weight -= down_rate;
		
		// Clamp Weight -------
		self.left_weight = ter_op( self.left_weight < 0.0, 0.0, self.left_weight );
		self.right_weight = ter_op( self.right_weight < 0.0, 0.0, self.right_weight );
		self.up_weight = ter_op( self.up_weight < 0.0, 0.0, self.up_weight );
		self.down_weight = ter_op( self.down_weight < 0.0, 0.0, self.down_weight );
		// END Clamp Weight ---
		
		// Need to have the child anim set to 1 (every frame evidently), and use limited as we don't want to mess with the parent node
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_left" ], 1, 0 );
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_right" ], 1, 0 );
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_up" ], 1, 0 );
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_down" ], 1, 0 );
		
		// Now lerp the parent node weight
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_left_parent" ], self.left_weight, level.TIMESTEP );
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_right_parent" ], self.right_weight, level.TIMESTEP );
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_up_parent" ], self.up_weight, level.TIMESTEP );
		self SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_aim_down_parent" ], self.down_weight, level.TIMESTEP );
		
		// Launcher
		// Need to have the child anim set to 1 (every frame evidently), and use limited as we don't want to mess with the parent node
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_left" ], 1, 0 );
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_right" ], 1, 0 );
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_up" ], 1, 0 );
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_down" ], 1, 0 );
		
		// Now lerp the parent node weight
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_left_parent" ], self.left_weight, level.TIMESTEP );
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_right_parent" ], self.right_weight, level.TIMESTEP );
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_up_parent" ], self.up_weight, level.TIMESTEP );
		level.ascend_launcher SetAnimLimited( level.scr_anim[ "ascend_launcher" ][ "ascender_aim_down_parent" ], self.down_weight, level.TIMESTEP );
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
wait_and_unhide_ascend_aim_assets( blend_time )
{
	// self is blend_player_rig
	wait blend_time;
	
	self Show();
	level.ascend_launcher Show();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_ramp_up_wind()
{
	level endon("notify_end_ascend_pendulum");
	
	wind_weight = 0.0;
	current_time = 0.0;
	start_time = 0.0;
	start_time = level.player_rig GetAnimTime( level.scr_anim[ "player_rig" ][ "alpha_rig_ascend" ] );
	//IPrintLn( "start time = " + start_time);
	
	end_time = 0.0;	
	end_time_array = [];
	end_time_array = GetNotetrackTimes( level.scr_anim[ "player_rig" ][ "alpha_rig_ascend" ], "max_wind" );
	end_time = end_time_array[0];
	//IPrintLn( end_time );
	
	wind_min = 0.2;
	wind_max = 1.0;
	
	while( 1 ) 
	{
		
		current_time = level.player_rig GetAnimTime( level.scr_anim[ "player_rig" ][ "alpha_rig_ascend" ] );
		
		wind_weight = maps\black_ice_util::normalize_value( start_time, end_time, current_time );
		
		wind_weight = maps\black_ice_util::factor_value_min_max( wind_min, wind_max, wind_weight );
		
		level.player_rig SetAnimLimited( level.scr_anim[ "player_rig" ][ "rigascend_noise_parent" ], wind_weight, 0.1 );
		
		//IPrintLn( wind_weight );
		
		wait ( level.TIMESTEP );
	}
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
alpha_ascend_rubberband( alpha_array )
{
	level endon( "notify_ascend_rubberband_alpha_stop" );
	
	level waittill( "notify_ascend_rubberband_alpha_start" );
	
	min_rate = 0.1;
	max_rate = level.ASCEND_ANIMS_RATE;
	
	rate_delta = 0.1;
	
	while ( 1 )
	{
		// Use the player's current ascend rate to rubberband alpha team
		rubberband_rate = maps\black_ice_util::factor_value_min_max( min_rate, max_rate, level.ascend_current_rate );
		
		// lerp the ascend anim rate
		// curr = curr + ( target - curr ) * rate
		level.alpha_curr_rate += ( ( rubberband_rate - level.alpha_curr_rate ) * rate_delta );
		
		anim_set_rate( alpha_array, "alpha_rig_ascend", level.alpha_curr_rate );
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
alpha_ascend_rubberband_cleanup( alpha_array )
{
	level waittill( "notify_ascend_rubberband_alpha_stop" );
	
	rate_delta = 0.1;
	
	while ( !( level._allies[0] maps\black_ice_util::check_anim_time( "ally1", "alpha_rig_ascend", 1.0 ) ) )
	{
		// lerp the ascend anim rate
		// curr = curr + ( target - curr ) * rate
		level.alpha_curr_rate += ( ( level.ASCEND_ANIMS_RATE - level.alpha_curr_rate ) * rate_delta );
		
		anim_set_rate( alpha_array, "alpha_rig_ascend", level.alpha_curr_rate );
		
		wait level.TIMESTEP;
	}
	
	flag_set( "flag_alpha_ascend_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
bravo_ascend()
{
	guys = [];
	guys["bravo1"] = level._bravo[0];
	guys["bravo2"] = level._bravo[1];
	guys["bravo1_ascend_launcher"] = level.bravo1_ascend_launcher;
	guys["bravo2_ascend_launcher"] = level.bravo2_ascend_launcher;
	
	// Destroy the (temp) non-animated models
	if ( IsDefined( level.launchers_attached ) && level.launchers_attached )
	{
		level._bravo[0] Detach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
		level._bravo[1] Detach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
		level.launchers_attached = false;
	}
	
	// This happens when starting from the 'ascend' checkpoint
	if ( IsDefined( level.ascend_waiting ) && level.ascend_waiting )
	{
		level.bravo_ascend_anim_node thread anim_loop( guys, "ascend_waiting", "stop_loop" );
	}
	
	while ( !flag( "flag_ascend_triggered" ) )
	{
		wait level.TIMESTEP;
	}
	
	level.bravo_ascend_anim_node notify( "stop_loop" );
	
	guys["bravo_ascend_rope1"] = level.bravo_ascend_rope1;
	guys["bravo_ascend_rope2"] = level.bravo_ascend_rope2;
	
	level.bravo_ascend_rope1 Show();
	level.bravo_ascend_rope2 Show();
	
	// Play rope shoot anims
	level.bravo_ascend_anim_node thread anim_reach( level._bravo, "bravo_rope_shoot" );
	level.bravo_ascend_anim_node anim_single( guys, "bravo_rope_shoot" );
	
	// Play idle anims
	level.bravo_ascend_anim_node thread anim_loop( guys, "bravo_rope_idle", "stop_loop" );
	
	// Wait for the prompt to continue
	while ( !flag( "flag_ascend_bravo_go" ) )
	{
		wait level.TIMESTEP;
	}
	
	// ready bravo for ascend
	level.bravo_ascend_anim_node notify( "stop_loop" );
	array_thread( level._bravo, ::set_ignoreme, true );
	array_thread( level._bravo, ::disable_surprise );
	
	// Play the opfor anim synced up to bravo team
	enemy_setup();
	level.ascend_anim_node thread anim_single_solo( level.ascend_enemy, "alpha_rig_ascend" );
	level.ascend_enemy thread maps\black_ice_util::delete_at_anim_end( "opfor", "alpha_rig_ascend", true );
	
	guys["bravo1_ascend_ascender"] = level.bravo1_ascend_ascender;
	guys["bravo2_ascend_ascender"] = level.bravo2_ascend_ascender;
	
	level.bravo1_ascend_ascender Show();
	level.bravo2_ascend_ascender Show();
	
	thread bravo_ascend_rubberband( guys );
	thread bravo_ascend_rubberband_cleanup( guys );
	level.bravo_ascend_anim_node anim_single( guys, "bravo_rig_ascend" );
	
	level notify( "notify_bravo_ascend_complete" );
	flag_set( "flag_bravo_ascend_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
calculate_bravo_rubberband_base()
{
	level.bravo_ascend_rubberband_base = level._bravo[1] GetAnimTime( level.scr_anim[ "bravo2" ][ "bravo_rig_ascend" ] );
	level notify( "notify_ascend_rubberband_bravo_start" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
bravo_ascend_rubberband( bravo_array )
{
	level endon( "notify_ascend_rubberband_bravo_stop" );
	
	level waittill( "notify_ascend_rubberband_bravo_start" );
	
	min_rate = 0.75;
	max_rate = level.ASCEND_ANIMS_RATE;
	
	min_delta = 0.0;
	max_delta = 0.06;
	
	rate_delta = 0.1;
	
	
	while ( 1 )
	{
		// Grab the difference between bravo & player's percentage through the anim
		bravo_time = level._bravo[1] GetAnimTime( level.scr_anim[ "bravo2" ][ "bravo_rig_ascend" ] );
		player_time = 0;
		if ( flag( "flag_player_ascending" ) )
		{
			player_time = level.player_rig GetAnimTime( level.scr_anim[ "player_rig" ][ "alpha_rig_ascend" ] );
		}
		
		anim_time_delta = bravo_time - player_time - level.bravo_ascend_rubberband_base;
		
		// Use that delta to calculate a rubberbanded anim rate
		rubberband_factor = maps\black_ice_util::normalize_value( min_delta, max_delta, anim_time_delta );
		
		rubberband_rate = maps\black_ice_util::factor_value_min_max( min_rate, max_rate, ( 1.0 - rubberband_factor ) );
		
		// lerp the ascend anim rate
		// curr = curr + ( target - curr ) * rate
		level.bravo_curr_rate += ( ( rubberband_rate - level.bravo_curr_rate ) * rate_delta );
		
		anim_set_rate( bravo_array, "bravo_rig_ascend", level.bravo_curr_rate );
		
		// and the enemy needs to be synced up
		anim_set_rate_single( level.ascend_enemy, "alpha_rig_ascend", level.bravo_curr_rate );
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
bravo_ascend_rubberband_cleanup( bravo_array )
{
	level endon( "notify_bravo_ascend_complete" );
	
	level waittill( "notify_ascend_rubberband_bravo_stop" );
	
	rate_delta = 0.1;
	
	while ( 1 )
	{
		// lerp the ascend anim rate
		// curr = curr + ( target - curr ) * rate
		level.bravo_curr_rate += ( ( level.ASCEND_ANIMS_RATE - level.bravo_curr_rate ) * rate_delta );
		
		anim_set_rate( bravo_array, "bravo_rig_ascend", level.bravo_curr_rate );
		
		// and the enemy needs to be synced up
		if ( IsDefined( level.ascend_enemy ) )
		{
			anim_set_rate_single( level.ascend_enemy, "alpha_rig_ascend", level.bravo_curr_rate );
		}
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hint_ascend_init_watcher()
{
	while ( 1 )
	{
		if ( !IsDefined( level.ascend_launch_pos ) )
			return;
		
		if ( !level.ascend_launch_pos.hint_active )
		{
			dist = Distance2D( level.player GetEye(), level.ascend_launch_pos.origin );
		
			if ( dist < 100 )
			{
				level.ascend_launch_pos.hint_active = true;
				
				// tagBR< wtf? >: Apparently you need to call display_hint_timeout() to display a hint that will NOT timeout
				// ...as display_hint(), by default, will timeout after 30 seconds...
				display_hint_timeout( "hint_ascend_init" );
			}
		}
		
		wait 0.05;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_mechanics( player_array )
{
	thread ascend_pendulum( level.player_ascend_anim_node, 1.25, 0.0, 1.5, undefined, "notify_end_ascend_pendulum" );
	
	curr_rate = 0.0;
	rate_delta = 0.1;
	
	while ( !flag( "flag_ascend_end" ) )
	{
		if ( level.allow_player_ascend_move == 0 )
		{
			anim_set_rate( player_array, "alpha_rig_ascend", 1.0 );
			level.ascend_current_rate = 1.0;
			curr_rate = 1.0;
			
			wait level.TIMESTEP;
			continue;
		}
		
		switch ( level.ascend_state )
		{
			case "idle":
				if ( level.ascend_state_transition )
				{
					ascend_idle_state_transition();
				}
								
				ascend_idle_state();
				break;
				
			case "ascend":
				if ( level.ascend_state_transition )
				{
					ascend_ascend_state_transition();
				}
				
				ascend_ascend_state();
				break;
				
			case "stop":
				if ( level.ascend_state_transition )
				{
					ascend_stop_state_transition();
				}
				
				ascend_stop_state();
				break;
		}
		
		// lerp the ascend anim rate
		// curr = curr + ( target - curr ) * rate
		curr_rate += ( ( level.ascend_target_rate - curr_rate ) * rate_delta );
		
		anim_set_rate( player_array, "alpha_rig_ascend", curr_rate );
		
		level.ascend_current_rate = curr_rate;
				
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_idle_state_transition()
{
	level.ascend_state_transition = false;
	level.ascend_target_rate = 0.0;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_idle_state()
{
	if ( level.player AttackButtonPressed() )
	{
		level.ascend_state = "ascend";
		level.ascend_state_transition = true;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_ascend_state_transition()
{
	level.ascend_state_transition = false;
	level.start_ascend_time = GetTime();
	level.ascend_target_rate = level.ASCEND_ANIMS_RATE;
	flag_set( "flag_player_ascending" );
	
	level.player_rig SetAnimRestart( level.scr_anim[ "player_rig" ][ "rig_ascend_start" ] );
	level.player_legs SetAnimRestart( level.scr_anim[ "player_legs_ascend" ][ "rig_ascend_start" ] );
	
	//AUDIO: starting rig ascend sfx
	thread maps\black_ice_audio::sfx_rig_ascend_logic( "go" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_ascend_state()
{
	min_time = 500; // ms
	
	// If enough time has elapsed
	if ( ( GetTime() - level.start_ascend_time ) > min_time )
	{
		// And the player is not pressing the ascend button
		if ( !( level.player AttackButtonPressed() ) )
		{
			level.ascend_state = "stop";
			level.ascend_state_transition = true;
		}
	}
	
	// Player rubberband
	if ( !flag( "flag_bravo_ascend_complete" ) )
	{
		rubberband_factor = 3.0;
		level.ascend_target_rate = level.ASCEND_ANIMS_RATE + ( ( level.ASCEND_ANIMS_RATE - level.bravo_curr_rate ) / rubberband_factor );
	}
	else
	{
		level.ascend_target_rate = level.ASCEND_ANIMS_RATE;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_stop_state_transition()
{
	level.ascend_state_transition = false;
	level.stop_ascend_time = GetTime();
	level.ascend_target_rate = 0.0;
	flag_clear( "flag_player_ascending" );
	
	level.player_rig SetAnimRestart( level.scr_anim[ "player_rig" ][ "rig_ascend_stop" ] );
	level.player_legs SetAnimRestart( level.scr_anim[ "player_legs_ascend" ][ "rig_ascend_stop" ] );
	
	//AUDIO: stopping rig ascend sfx
	thread maps\black_ice_audio::sfx_rig_ascend_logic( "stop" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_stop_state()
{
	min_time = 500; // ms
	
	// If enough time has elapsed
	if ( ( GetTime() - level.stop_ascend_time ) > min_time )
	{
		level.ascend_state = "idle";
		level.ascend_state_transition = true;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ascend_pendulum( control_node, theta_max_x, theta_max_y, theta_max_z, pend_length, ender_notify )
{
	if ( IsDefined( ender_notify ) )
	{
		level endon( ender_notify );
	}
	
	init_x = control_node.angles[0];
	init_y = control_node.angles[1];
	init_z = control_node.angles[2];
	
	// FALLBACK
	//level.player_ascend_anim_node Vibrate( ( 1, 0, 0 ), 1.5, 5.0, 300 );
	
	theta_x = 0.0;
	theta_y = 0.0;
	theta_z = 0.0;
	angle_rate_delta = 0.015;
	
	g = 385.73; // in/s^2
	max_rope_length = 1240.0;
	min_rope_length = 300.0;
	
	freq_factor = 100.0;
	
	// Our ( 1/2Pi ) factor, or in our case 1/360
	ANG_FACTOR = ( freq_factor / 360.0 );
	
	// Initially rotate the node so it coincides with our pendular motion
	//level.player_ascend_anim_node RotateTo( ( theta_max_x, level.player_ascend_anim_node.angles[1], 0.0 ), 1.6 );
	//wait 1.6;
	
	t = 0.0;
	L = min_rope_length;
	omega = 0.0;
	freq = 0.0;
	period = 0.0;
	
	// If a static length has been passed in, we can pre-compute many values
	if ( IsDefined( pend_length ) && pend_length > 0.0 )
	{
		L = pend_length;
		omega = sqrt( g / L ); // angular frequency
		freq = ( ANG_FACTOR * omega );
		
		Assert( freq > 0 );
		period = 1.0 / freq;
	}
	
	while ( !flag_exist( "flag_common_breach" ) || !flag( "flag_common_breach" ) )
	{
		// simple harmonic motion
		// theta = theta_max * sin( sqrt( g/L ) * t )
		
		// Make computations when length is dynamic
		if ( !IsDefined( pend_length ) )
		{
			// Use the anim time to regulate the length of the rope
			anim_time = ( level.player_rig GetAnimTime( level.scr_anim[ "player_rig" ][ "alpha_rig_ascend" ] ) );
			L = ( 1.0 - anim_time ) * max_rope_length;
		
			// Clamping
			if ( L < min_rope_length )
			{
				L = min_rope_length;
			}
		
			omega = sqrt( g / L ); // angular frequency
		
			freq = ( ANG_FACTOR * omega );
			
			Assert( freq > 0 );
			period = 1.0 / freq;
		}
		
		// We need to ensure the t value doesn't over-inflate
		if ( t > period )
		{
			t -= period;
		}
		
		// Do the SHM calculation
		theta = ( omega * t * freq_factor );
		
		// lerp the angles to max over time
		// curr = curr + ( target - curr ) * rate
		theta_x += ( ( theta_max_x - theta_x ) * angle_rate_delta );
		delta_x = theta_x * Sin( theta + 90 );
		
		theta_y += ( ( theta_max_y - theta_y ) * angle_rate_delta );
		delta_y = theta_y * Sin( theta + 90 );
		
		theta_z += ( ( theta_max_z - theta_z ) * angle_rate_delta );
		delta_z = theta_z * Sin( theta );
		
		// Apply the calculated angles
		control_node.angles = ( ( init_x + delta_x ), ( init_y + delta_y ), ( init_z + delta_z ) );
		
		t += level.TIMESTEP;
		wait level.TIMESTEP;
	}
	
	control_node notify( "notify_pendular_motion_complete" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hanging_cargo_motion()
{
	NUM_CARGO_SETS = 3;
	thread maps\black_ice_audio::sfx_cargo_sway();
	for ( i = 0; i < NUM_CARGO_SETS; i++ )
	{
		control_node = GetEnt( "hanging_cargo_node_" + i, "script_noteworthy" );
		cargo = GetEntArray( "hanging_cargo_" + i, "script_noteworthy" );
		
		pend_length = 0.0;
		
		if ( cargo.size )
		{
			z_avg = 0.0;
			
			for ( j = 0; j < cargo.size; j++ )
			{
				cargo[j] LinkTo( control_node );
				
				// linking clip if there is any
				if( IsDefined( cargo[j].target ) )
				{
					clip = GetEnt( cargo[j].target, "targetname" );
					clip LinkTo( cargo[j] );
				}
				
				z_avg += cargo[j].origin[2];
			}
			
			// Taking an average of the z pos values as an "approximation" of the center of mass position of the cargo
			z_avg /= cargo.size;
			COM = ( cargo[0].origin[0], cargo[0].origin[1], z_avg );
			
			// Calculate the length of the pendulum, taking into consideration the cargo's origin is not at the base :/
			pend_length = Length( control_node.origin - COM );
			pend_length += 600; // <-- origin is 600 up from the cargo's center of mass at base
		}

		thread ascend_pendulum( control_node, RandomFloatRange( 0.975, 1.275 ), RandomFloatRange( 4.0, 6.0 ), RandomFloatRange( 0.3, 0.6 ), pend_length );
		thread hanging_cargo_cleanup( control_node, cargo );
		
		// Spawn off the set of cargo that ascends
		if ( IsDefined( control_node.targetname ) && control_node.targetname == "hanging_cargo_ascend" )
		{
			thread hanging_cargo_ascension( control_node );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hanging_cargo_ascension( control_node )
{
	// This is a flag trigger at the catwalk mid stair section (right in front of the cargo to ascend)
	flag_wait( "flag_mid_start" );

	move_to_point = control_node.origin + ( 0, 0, 1000 );
	time = 30.0; // seconds
	
	control_node MoveTo( move_to_point, time, 1.0, 0.0 );
	
	// Wait and then close the doors
	wait ( time / 2.0 );
	
	door_time = 5.0;
	door1 = GetEnt( "left_cargo_elevator_door_1", "targetname" );
	door2 = GetEnt( "left_cargo_elevator_door_2", "targetname" );
	door1 MoveTo( door1.origin + ( 0, 226, 0 ), door_time, 0.0, 0.0 );
	door2 MoveTo( door2.origin + ( 0, -226, 0 ), door_time, 0.0, 0.0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hanging_cargo_cleanup( control_node, cargo )
{
	control_node waittill( "notify_pendular_motion_complete" );
	
	for ( i = 0; i < cargo.size; i++ )
	{
		cargo[i] Delete();
	}
	
	control_node Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
post_ascend_cleanup()
{
	// Wait for ascend to complete
	while ( !( level.player_rig maps\black_ice_util::check_anim_time( "player_rig", "alpha_rig_ascend", 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}
	
	while ( !flag( "flag_alpha_ascend_complete" ) || !flag( "flag_bravo_ascend_complete" ) )
	{
		wait level.TIMESTEP;
	}
	
	flag_set( "sfx_ascend_done" );
	flag_set( "flag_ascend_end" );
	stop_exploder( "basecamp_snow" );
	stop_exploder( "basecamp_lights" );
	
	maps\black_ice_util::player_animated_sequence_cleanup();
	
	level.ascend_anim_node = undefined;
	level.bravo_ascend_anim_node = undefined;
	level.player_ascend_anim_node = undefined;
	
	/*
	level.ascend_hook Delete();
	level.ascend_hook = undefined;
	
	level.ascend_launcher Delete();
	level.ascend_launcher = undefined;
	level.ally1_ascend_launcher Delete();
	level.ally1_ascend_launcher = undefined;
	level.ally2_ascend_launcher Delete();
	level.ally2_ascend_launcher = undefined;
	
	level.ascend_ascender Delete();
	level.ascend_ascender = undefined;
	level.ally1_ascend_ascender Delete();
	level.ally1_ascend_ascender = undefined;
	level.ally2_ascend_ascender Delete();
	level.ally2_ascend_ascender = undefined;
	
	level.ascend_rope1 Delete();
	level.ascend_rope1 = undefined;
	level.ascend_rope2 Delete();
	level.ascend_rope2 = undefined;
	level.ascend_rope3 Delete();
	level.ascend_rope3 = undefined;
	
	level.bravo1_ascend_launcher Delete();
	level.bravo1_ascend_launcher = undefined;
	level.bravo2_ascend_launcher Delete();
	level.bravo2_ascend_launcher = undefined;
	
	level.bravo1_ascend_ascender Delete();
	level.bravo1_ascend_ascender = undefined;
	level.bravo2_ascend_ascender Delete();
	level.bravo2_ascend_ascender = undefined;
	
	level.bravo_ascend_rope1 Delete();
	level.bravo_ascend_rope1 = undefined;
	level.bravo_ascend_rope2 Delete();
	level.bravo_ascend_rope2 = undefined;
	*/
	
	level.player_legs Delete();
	level.player_legs = undefined;
	
	level.allow_player_ascend_move = undefined;
	level.ascend_current_rate = undefined;
	level.bravo_curr_rate = undefined;
	level.alpha_curr_rate = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hint_ascend_init_func()
{
	dist = Distance2D( level.player GetEye(), level.ascend_launch_pos.origin );
	
	if ( dist < 100 )
	{
		if ( level.player UseButtonPressed() )
		{
			level.ascend_launch_pos notify( "trigger" );
			return true;
		}
	}
	else
	{
		level.ascend_launch_pos.hint_active = false;
		return true;
	}
	
	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
hint_ascend_func()
{
	return ter_op( level.player AttackButtonPressed(), true, false );
}


notetrack_fire_shake(player_rig)
{
    
    earthquake( .4, 0.5, level.player.origin, 2048  );
    level.player PlayRumbleOnEntity( "pistol_fire" );
  
}

notetrack_takeoff(player_rig)
{
    
    earthquake( .3, 1.0, level.player.origin, 2048  );
    level.player PlayRumbleOnEntity( "grenade_rumble" );
  
}

notetrack_shake_start(player_rig)
{
    
    // earthquake( 1.0, 1.0, level.player.origin, 2048  );
    //level.player PlayRumbleOnEntity( "grenade_rumble" );
  
}

notetrack_shake_stop(player_rig)
{
    
    //earthquake( 1.0, 1.0, level.player.origin, 2048  );
    //level.player PlayRumbleOnEntity( "grenade_rumble" );
  
}