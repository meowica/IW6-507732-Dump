#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;
#include maps\black_ice_vignette;

SCRIPT_NAME = "black_ice_command.gsc";

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start_outside()
{
	iprintln( "Command_Outside" );
	
	flag_set( "flag_fire_damage_on" );
	flag_set( "flag_fx_screen_bokehdots_rain" );
	maps\black_ice_fx::fx_command_interior_on();
	
	maps\black_ice_util::player_start( "player_start_command_outside" );
	
	thread maps\black_ice_refinery::util_show_destroyed_derrick();	
	
	position_tNames = 
	[    
		"struct_ally_start_command_outside_01",
		"struct_ally_start_command_outside_02"
	];
	
	level._allies maps\black_ice_util::teleport_allies( position_tNames );
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_rain_heavy", 2 );	
	
	activate_trigger_with_targetname( "trig_derrick_ally_7" );

	// Break the glass	
	glass = GetGlassArray( "glass_command_center" );
	foreach( pane in glass )
		DestroyGlass( pane );
	
	// Remove refinery geo
	thread maps\black_ice_refinery::util_refinery_stack_cleanup();
	
	thread command_godrays();
		
	maps\black_ice_fx::pipe_deck_water_suppression_fx();
	maps\black_ice_pipe_deck::fx_command_snow();
	maps\black_ice_fx::fx_command_interior_on();
}

start_inside()
{
	iprintln( "Command_Inside" );
	
	maps\black_ice_util::player_start( "player_start_command"  );
	
	thread maps\black_ice_refinery::util_show_destroyed_derrick();	
	maps\black_ice_fx::fx_command_interior_on();
	
	position_tNames = 
	[    
		"struct_ally_start_command_01",
		"struct_ally_start_command_02"
	];
	
	level._allies maps\black_ice_util::teleport_allies( position_tNames );
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_controlroom_01", 2 );	
	
	// Break the glass
	glass = GetGlassArray( "glass_command_center" );
	foreach( pane in glass )
		DestroyGlass( pane );	
		
	// Remove refinery geo
	thread maps\black_ice_refinery::util_refinery_stack_cleanup();
	
	thread command_godrays();	
		
	maps\black_ice_fx::pipe_deck_water_suppression_fx();
	maps\black_ice_pipe_deck::fx_command_snow();	
}

main()
{							
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	exploder( "command_console_baker" );
	
	// Setup enemies
	enemy_init();
	
	// Setup doors	
	door_out = level._command.door_out;		
	
	thread allies();	
	thread player_disable_suppression_sequence();
	thread dialog_baker_start();	
	thread command_light_change();
	thread set_command_dof();
	thread event_pipe_explosions();
	
	// Disable end flag
	trig_flag_command_done = GetEnt( "trig_flag_command_done", "targetname" );
	Assert( IsDefined( trig_flag_command_done ));
	trig_flag_command_done trigger_off();
	
	// Setup trigger button
	button_trig = GetEnt( "trig_command_button", "targetname" );
	Assert( IsDefined( button_trig ));
	
	//flashing light to get players attention
	exploder( "command_center_flashing_button" );
	
	button_trig waittill_trigger_activate_looking_at( level._command.player_enemy, 0.5 );
		
	//Audio: Start use console sfx
	thread maps\black_ice_audio::sfx_plr_cmd_console();
	
	stop_exploder( "command_center_flashing_button" );
	
	flag_clear( "flag_fire_damage_on" );
	
	// Start sequence	
	flag_set( "flag_player_start_sequence" );
	thread enable_audio_feedback();
	
	// wait til Sequence over
	level waittill( "flag_start_lights" );
	
	//end music
		music_play( "mus_blackice_exfil_ss" );
	
	//level waittill_either( "flag_lever_pulled", "flag_command_fail_late" );
	
	// Open door out
	door_out thread open_door( 90, 1 );
	
	wait( 1 );
	
	// Allies wait at positions until player heads over
	//activate_trigger_with_targetname( "trig_command_exfil_ally_positions" );

	// Enable end flag trigger	
	//trig_flag_command_done trigger_on();		
	flag_wait( "flag_command_done" );
}

section_flag_inits()
{
	flag_init( "flag_control_sequence_over" );
	flag_init( "flag_command_start" );	
	flag_init( "flag_objective_fire_supression" );
	flag_init( "flag_player_start_sequence" );
	flag_init( "flag_command_fail_early" );
	flag_init( "flag_command_fail_late" );
	flag_init( "flag_command_done" );
	flag_init( "flag_command_baker_console_anim" );
	flag_init( "flag_player_started_input" );
	flag_init( "flag_player_out_of_red" );
	flag_init( "flag_player_held_green" );
	flag_init( "flag_start_control_monitor_fx" );
	flag_init( "flag_player_failed_control" );
	flag_init( "flag_player_control_success" );
	flag_init( "flag_baker_instructing" );
	flag_init( "flag_start_lights");
	flag_init( "flag_blowup_pipes" );
	//flag_init( "flag_first_color_pass"  );
	flag_init( "flag_audio_feedback" );
}

section_precache()
{		
	add_hint_string( "pull_lever", &"BLACK_ICE_COMMAND_PULL_LEVER", ::hint_pull_lever );
	PreCacheString( &"BLACK_ICE_COMMAND_USE_CONSOLE" );
	PreCacheString( &"BLACK_ICE_COMMAND_FAIL_EARLY" );
	PreCacheString( &"BLACK_ICE_COMMAND_FAIL_LATE" );
	PreCacheRumble( "steady_rumble" );
}

hint_pull_lever()
{
	return false || flag( "flag_player_started_input") || flag( "flag_player_out_of_red" );;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_post_inits()
{
	level._command = SpawnStruct();
	
	//these will increase with dificulty
	level.player_lever_control_sensitivity = 0.033;
	
	
	level.bar_drift_rate = 0.0;
	
	//this init value will make the bar raise while the monitor comes out of the console
	level.player_lever_input = -0.0036;
	//fire supression will init to the next to lowest level
	level.water_supression_level = 1;
	level.color_status = 0;
	
	// Get structs
	level._command.player_struct = GetStruct( "struct_command_player", "targetname" );	
	level._command.baker_struct = GetStruct( "struct_command_baker", "targetname" );	
	
	if( IsDefined( level._command.player_struct ))	
	{
		// Struct for enter door anim
		level._command.baker_enter_struct = GetStruct( "vignette_controlroom_enter", "script_noteworthy" );
		
		// Doors
		level._command.door_in = setup_door( "model_command_door_in", "blackice_door_refinery" );
		level._command.door_out = setup_door( "model_command_door_out", "blackice_door_refinery" );
		level._command.baker_enter_struct anim_first_frame_solo( level._command.door_in, "command_enter" );	
	}
	else
	{
		iprintln( SCRIPT_NAME + ": Warning - Command player struct missing (compiled out?)" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
enable_audio_feedback()
{
	wait 5;
	flag_set("flag_audio_feedback");
}
dialog_baker_start()
{		
	level endon( "flag_player_start_sequence" );
	level endon( "flag_command_fail_late" );
	
	// Player is in
	flag_wait( "flag_command_start" );
	//thread temp_dialogue_line( "Baker", "Let's finish the job. Get on that console. Shut down the water supression.", 3 );
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_takeoverthatconsole" );
	flag_set( "flag_objective_fire_supression" );

	wait( 4.0 );
	
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_rookgetthatguy" );
		
	wait( 5.0 );
	
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_nowrookgetto" );
		
//	wait( 5.5 );
//		
//	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_shutdownthefire" );
//		
//	wait( 5.5 );
//		
//	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_rookthefiresression" );
		
	i = 0;
	waittime = 6;
	baker_nags = [ "black_ice_bkr_nowrookgetto", "black_ice_bkr_takeoverthatconsole", "black_ice_bkr_rookgetthatguy"  ];
		
	while( 1 )
	{
		
		wait( waittime );
			
		level._allies[ 0 ] smart_dialogue( baker_nags[ i ] );
			
		if( waittime < 30 )
			waittime += 3;
			
		i += 1;
		
			
		if ( i == baker_nags.size )
			i = 0;
			
	}
}

dialog_baker_success()
{
	level endon( "flag_command_fail_late" );
	
	level waittill( "notify_dialog_command_end" );
	smart_radio_dialogue( "black_ice_bkr_moveitletsgo" );
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

door_close()
{
	door = level._command.door_in;
	
	// Allies are in
	if(( level.start_point != "command_inside" ))
		waittill_trigger_ent_targetname( "trig_command_ally", level._allies );
	
	// Player is in
	flag_wait( "flag_command_start" );
	autosave_by_name( "command_2" );		
	
	flag_wait( "flag_player_start_sequence" );
	
	// Close door
	if( level.start_point != "command_inside" )
		door close_door( undefined, 0.6 );
	
	activate_trigger_with_targetname( "trig_command_ally2_position" );
	
	cleanup_pipedeck();
	
	// Clean up debris from refinery (player is not going back)
	maps\black_ice_refinery::util_debris_remove();
}


cleanup_pipedeck()
{
	level notify( "notify_stop_pipedeckfx" );
	// Stop fire damage on pipe deck (hurt radii)
//	level notify( "notify_stop_fire_damage" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies()
{			
	array_call( level._allies, ::PushPlayer, true );
	
	// Door closes once player and allies are inside
	thread door_close();
	
	// Baker opens door
	if( level.start_point != "command_inside" )
		level._allies[ 0 ] allies_baker_command_enter();
	
	// Send fuentes into room
	activate_trigger_with_targetname( "trig_command_ally_enter" );
	
	// Baker starts into command sequence
	level._allies[ 0 ] thread allies_baker_command_inside();	
}

allies_baker_command_enter()
{
	struct = level._command.baker_enter_struct;
	door = level._command.door_in;	
		
	// Baker approaches door
	struct anim_reach_solo( self, "command_enter_approach" );
	struct anim_single_solo( self, "command_enter_approach" );
	self cover_left_idle();
	
	// Wait for baker to reach door and player to be looking at him		
	while( !level.player player_looking_at( self.origin, 0.5 ))
		wait( 0.05 );
	
	// Stop loop
	self notify( "stop_loop" );
	
	// Baker opens door
	self thread maps\black_ice_audio::sfx_command_center_door_open();
	struct thread anim_single( [self, door], "command_enter" );
	door.col_brush ConnectPaths();
}

allies_baker_command_inside()
{	
	struct = level._command.baker_struct;		
	
	self ignore_everything();
	
	// Get to console, push body away, and start working
	struct anim_reach_solo( self, "command_init" );
	struct thread vignette_single_solo( self, "command_init", "command_loop" );
	
	level waittill( "notify_baker_push_opfor" );
	
	thread enemies_scene( struct );
	
	// Start main sequence
	flag_wait( "flag_player_start_sequence" );
	
	self vignette_end();

	//wait for console sequence to end
	level waittill( "notify_player_end_sequence");
	
	self unignore_everything();

	self set_run_anim( "DRS_sprint" );	
	self enable_ai_color();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemy_init()
{			
	baker_struct = level._command.baker_struct;
	player_struct = level._command.player_struct;
	
	// Spawn
	baker_enemy = GetEnt( "enemy_command_inside_1", "targetname" ) spawn_ai();
	baker_enemy.animname = "command_enemy_1";
	baker_enemy ignore_everything();
	baker_enemy magic_bullet_shield();
	
	player_enemy = GetEnt( "enemy_command_inside_2", "targetname" ) spawn_ai();
	player_enemy.animname = "command_enemy_2";
	player_enemy ignore_everything();
	player_enemy magic_bullet_shield();
	
	chair = spawn_anim_model( "command_opfor1_chair", level._command.baker_struct.origin );
		
	level._command.baker_enemy = baker_enemy;
	level._command.player_enemy = player_enemy;
	level._command.enemy_chair = chair;
	
	// Setup	
	baker_struct anim_first_frame_solo( baker_enemy, "command_start" );
	player_struct anim_first_frame_solo( player_enemy, "command_start" );		
	baker_struct anim_first_frame_solo( chair, "command_start" );	
}

enemies_scene( struct )
{
	enemy = level._command.baker_enemy;		
	enemy set_deathanim( "command_start" );
	enemy.noragdoll = true;	
	enemy stop_magic_bullet_shield();
	enemy kill();
	
	chair = level._command.enemy_chair;
	struct thread anim_single_solo( chair, "command_start" );
	
	//Audio: SFX for pushing body out of chair
	thread maps\black_ice_audio::sfx_baker_move_body_chair(chair);
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

command_fail_early_death()
{		
	
	level waittill( "notify_blast_kill_player" );
	
	
	//this flag will stop the light vision sets from changing
   	flag_set( "flag_player_dying_on_rig" );
   	vision_set_fog_changes("black_ice_exfil_explosive_death",0.5);

	earthquake( 0.5, 0.5, level.player.origin, 2048  );
    level.player PlayRumbleOnEntity( "damage_heavy" );
    exploder( "exfil_pull_early_explosion" );
   
    level.player thread maps\_gameskill::blood_splat_on_screen( "left" );
    level.player thread maps\_gameskill::blood_splat_on_screen( "right" );
    level.player thread maps\_gameskill::blood_splat_on_screen( "bottom" );
    
    SetDvar( "ui_deathquote", &"BLACK_ICE_COMMAND_FAIL_EARLY" );
    
    wait( 1.0 );

	//level.player kill();
	MissionFailedWrapper();
	
	//hold script while ending
	wait( 10 );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

command_fail_late_death()
{		
	
	level waittill( "notify_blast_kill_player" );
	
	//this flag will stop the light vision sets from changing
   	flag_set( "flag_player_dying_on_rig" );
   	vision_set_fog_changes("black_ice_exfil_explosive_death",0.5);

	earthquake( 0.5, 0.5, level.player.origin, 2048  );
    level.player PlayRumbleOnEntity( "damage_heavy" );
    exploder( "exfil_pull_early_explosion" );
    
    //	//AUDIO: distant explosions sfx/	
    thread maps\black_ice_audio::sfx_blackice_tanks_dist_explo();
   
    level.player thread maps\_gameskill::blood_splat_on_screen( "left" );
    level.player thread maps\_gameskill::blood_splat_on_screen( "right" );
    level.player thread maps\_gameskill::blood_splat_on_screen( "bottom" );
    
    SetDvar( "ui_deathquote", &"BLACK_ICE_COMMAND_FAIL_LATE" );
    
    wait( 1.0 );

	//level.player kill();
	MissionFailedWrapper();
	
	//hold script while ending
	wait( 10 );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_disable_suppression_sequence()
{			
	player_struct = level._command.player_struct;
	baker_struct = level._command.baker_struct;				
	
	// Setup player and blend them to anim
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	//baker_console = spawn_anim_model( "command_console_baker", level.player.origin );
	//player_console = spawn_anim_model( "command_console_player", level.player.origin );
	
	player_struct anim_first_frame_solo( player_rig, "command_start" );
	//player_struct anim_first_frame_solo( player_console, "command_start" );	
	//baker_struct anim_first_frame_solo( baker_console, "command_start" );
	
	player_rig Hide();	
	
	
	//setup buttons and monitors for the player to pressplayer_lever_animate
	console_buttons = GetEntarray( "command_shutoff_button", "targetname" );
	baker_lever = GetEntarray( "command_lever_baker", "targetname" );
	baker_monitor = GetEntarray( "command_monitor_baker", "targetname" );
	player_lever = GetEntarray( "command_lever_player", "targetname" );
	player_lever_animate = player_lever[0];
	player_monitor = GetEntarray( "command_monitor_player", "targetname" );
	foreach( button in console_buttons  )
	{
		button assign_animtree( "command_shutoff_button" );
		button anim_first_frame_solo( button, "command_shutoff_button" );
	}
	foreach( lever in baker_lever  )
	{
		lever assign_animtree( "command_lever" );
		lever anim_first_frame_solo( lever, "command_baker_end" );
	}

	//init the lever at 0.5, this is where the player hand anim will start.
	player_lever_animate assign_animtree( "command_lever" );
	player_lever_animate thread anim_single_solo( player_lever_animate, "command_player_control" );
	anim_set_rate_single( player_lever_animate, "command_player_control", 0.0 );
	player_lever_animate SetAnimTime( level.scr_anim[ "command_lever" ][ "command_player_control" ], 0.5 );
	
	foreach( monitor in baker_monitor  )
	{
		monitor assign_animtree( "command_monitor" );
		monitor anim_first_frame_solo( monitor, "command_monitor_baker" );
	}
	foreach( monitor in player_monitor  )
	{
		monitor assign_animtree( "command_monitor" );
		monitor anim_first_frame_solo( monitor, "command_monitor_player" );
	}
		
	//wait for player to start sequence
	level waittill( "flag_player_start_sequence" );	
	
	//setup player and link to scene
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player DisableWeaponSwitch();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowMelee( false );
	thread smooth_player_link( player_rig, 0.5 );
	
	////////start anims...//////////
	
	// Enemy	
	enemy = level._command.player_enemy;
	enemy.allowdeath = true;
	enemy.a.nodeath = true;
	enemy.v.death_on_end = true;
	player_struct thread vignette_single_solo( enemy, "command_start" );
	
	//baker and console need to activate when the player is looking away
	thread allies_baker_console_anims( baker_struct, player_rig );
	//player and console anims
	thread player_input_console_animate( player_struct, player_rig, player_lever_animate );
	
	foreach( button in console_buttons  )
	{
		button thread anim_single_solo( button, "command_shutoff_button" );	
	}
	foreach( monitor in baker_monitor  )
	{
		monitor thread anim_single_solo( monitor, "command_monitor_baker" );
	}
	i = 0;
	foreach( monitor in player_monitor  )
	{
		//0 is the players monitor....should stamp out prefab and make only one.
		if( i == 0  )
		{
			monitor thread anim_single_solo( monitor, "command_monitor_player" );
			thread monitor_controls_and_fx( monitor );
		}
		i += 1;
	}
	
	////////////////////////////
	
	//thread events that occur during the scene
	thread player_view_manager();
	thread water_shutdown_exploder_manager();
	thread dialog_baker_init_control();
	thread dim_overhead_light();
	
	//start logic for player control
	player_control_sequence();
	
	if( flag( "flag_command_fail_early" ))
	{
		//IPrintLnBold( "FAILING EARLY!" );
		//lever pulled too soon.  fail sequence.
		baker_struct thread anim_single_solo( level._allies[ 0 ], "command_early" );
		foreach( lever in baker_lever  )
		{
			lever thread anim_single_solo( lever, "command_baker_early" );
		}
		
		level.player LerpViewAngleClamp( 0.5, 0, 0, 0, 0, 0, 0 );
		player_lever_animate thread anim_single_solo( player_lever_animate, "command_player_early" );
		player_struct thread anim_single_solo( player_rig, "command_early" );
		
		
		command_fail_early_death();
		
	}
	else if( flag( "flag_command_fail_late" ))
	{
		flag_set( "flag_start_lights" );
		
		//lever pulled too late.  fail sequence
		baker_struct thread anim_single_solo( level._allies[ 0 ], "command_late" );
		foreach( lever in baker_lever  )
		{
			lever thread anim_single_solo( lever, "command_baker_late" );
		}
		
		level.player LerpViewAngleClamp( 2.0, 0, 0, 0, 0, 0, 0 );
		
		//wait for baker to grab player before scene is over
		wait( 2 );
		flag_set( "flag_control_sequence_over");
		player_struct thread anim_single_solo( player_rig, "command_late" );
		player_lever_animate thread anim_single_solo( player_lever_animate, "command_player_late" );
		
		player_anim = player_rig getanim( "command_late" );
		lever_anim = player_lever_animate getanim( "command_player_late" );
		time = level._allies[ 0 ] getanimtime( level.scr_anim[ "ally1" ][ "command_late" ] );
		player_rig SetAnimTime( player_anim, time );
		player_lever_animate SetAnimTime( lever_anim, time );
		
		command_fail_late_death();
	}
	else
	{
		//sucess!
		time_before_explosion = 2.8;
		level.water_supression_level = 0;
		thread dialog_baker_success();
		thread explosions_success( time_before_explosion );
		thread sucess_swelling_rumble( time_before_explosion, 0.4, 0.3 );
		level._allies[ 0 ] thread allies_baker_command_end_anim( baker_struct );
		
		flag_set( "flag_start_lights");
		
		foreach( monitor in baker_monitor  )
		{
			monitor thread anim_single_solo( monitor, "command_monitor_baker_end" );
		}
		foreach( monitor in player_monitor  )
		{
			monitor thread anim_single_solo( monitor, "command_monitor_player_end" );
//			StopFXOnTag( getfx( "console_command_start" ), monitor, "tag_fx_screen" );
//			StopFXOnTag( getfx( "console_command_yellow" ), monitor, "tag_fx_screen" );
//			StopFXOnTag( getfx( "console_command_red" ), monitor, "tag_fx_screen" );
		}
		foreach( lever in baker_lever  )
		{
			lever thread anim_single_solo( lever, "command_baker_end" );
		}
		
		flag_set( "flag_control_sequence_over");
		thread maps\black_ice_audio::sfx_cmd_seq_end();
		
		level._command.enemy_chair delete();
		//level.player LerpViewAngleClamp( 0.5, 0, 0, 0, 0, 0, 0 );
		level.player SpringCamDisabled( 0.5 );
		player_lever_animate thread anim_single_solo( player_lever_animate, "command_player_end" );
		player_struct anim_single_solo( player_rig, "command_end" );
		//slow player until rubberbanding kicks in
		SetSavedDvar ( "g_speed", 100);
		//IPrintLn( "end!" );
		
	}
	
	level.player unlink();
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player EnableWeaponSwitch();
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	level.player AllowMelee( true );
	
	player_rig delete();
	
	level notify( "notify_player_end_sequence");
	flag_set( "flag_command_done" );
}

///////////////////////////////
//START PLAYER CONTROL SEQUENCE
///////////////////////////////

player_control_sequence()
{
	//level endon( "flag_control_sequence_over" );
	level endon( "flag_player_failed_control" );
	
	//wait for sequence to start
	level waittill( "notify_start_player_control" );
	
	//bring up hint
	display_hint( "pull_lever" );
	
	//Baker will nag until failing if the player does not start moving the controls and keep the bar in the green.
	thread player_control_baker_nag_and_fail();
		
	//wait_for_player_input before checking for the green
	level notify( "notify_player_start_input_test" );
	while ( !flag( "flag_player_started_input" ))
	{
		   	wait level.TIMESTEP;
	}
	
	//make sure player holds the bar in the green.  If so he "gets it" and sequence proceeds.  
	check_hold_bar_in_green();
	
	flag_set( "flag_player_held_green" );
	
	//wait for bater to stop instructing if he is
	while ( flag( "flag_baker_instructing" ))
	{
		   	wait level.TIMESTEP;
	}
	
	//notfiy extra monitor fx to start...this will make the panel light in when the fail conditions to the game become active
	level notify( "notify_start_control_minigame" );
	
	//explosions occur when turbines get shut down
	thread explosion_progression_control_sequence();
	
	//thread the checker, player will die when in the red from here on out
	thread check_hold_bar_in_green_or_die();
	//holding the gauge will gradually get harder
	thread player_control_increase_difficulty();
	//baker talks during scene
	thread dialog_baker_player_control();
	
	//duration of control sequence
	wait( 12.9 );
	
}

check_hold_bar_in_green()
{
	//clear this so hint string sticks
	flag_clear( "flag_player_started_input" );
		
	green_hold_time = 2.0;
	
	hold_time = green_hold_time;
	
	in_red = false;
	red_hint_timer = 1;
	hint_timer = red_hint_timer;
		
	while( 1 )
	{
		//timer
		if(	level.color_status == 0 )
		{
			hold_time -= level.TIMESTEP;
			if( hold_time < 0.0  )
				break;			
		}
		else
		{
			//reset timer
			hold_time = green_hold_time;
		}
		
		//put up hint string if player in red
		if(	level.color_status == 2 )
		{
			hint_timer -= level.TIMESTEP;
			
			if(( in_red == false ) && ( hint_timer < 0.0 ))
			{
				flag_clear( "flag_player_out_of_red" );
				display_hint( "pull_lever" );
				in_red = true;
			}
		}
		else
		{
			//reset timer
			hint_timer = red_hint_timer;
			in_red = false;
			flag_set( "flag_player_out_of_red" );
		}
		
		wait level.TIMESTEP;
	}
	
	

}

check_hold_bar_in_green_or_die()
{
	
	//once the lights start, player is safe
	level endon(  "flag_start_lights" );
	
	in_red = false;
	red_fail_timer = 0.55;
	fail_timer = red_fail_timer;
		
	while( 1 )
	{
		//player_will_fail_if_in_red
		if(	level.color_status == 2 )
		{
			fail_timer -= level.TIMESTEP;
			if( fail_timer < 0.0 )
				break;
		}
		else
		{
			//reset timer
			fail_timer = red_fail_timer;
		}
			
		wait level.TIMESTEP;
	}
	
	flag_set( "flag_player_failed_control" );
	flag_set( "flag_command_fail_late" );
	
}

player_control_increase_difficulty()
{
	
	//time over which to increase difficulty
	timer_max = 8;
	timer = timer_max;
	start_drift_rate = 0.0045;
	end_drift_rate = 0.0152;
	
	while( timer > 0.0 )
	{
				
		factor = maps\black_ice_util::normalize_value( 0, timer_max, timer );
		drift = maps\black_ice_util::factor_value_min_max( end_drift_rate, start_drift_rate, factor );
		
		level.bar_drift_rate = drift;
		
		timer -= level.TIMESTEP;
		wait level.TIMESTEP;
	}
}

dialog_baker_player_control()
{
	
	level endon( "flag_command_fail_late" );
	
	level._allies[ 0 ] thread smart_radio_dialogue( "black_ice_bkr_rookthefiresression" );
	//Ok, here we go.  Just keep us out of the red.  This won't take long.
	
	wait( 5.95 );
	
	//thread temp_dialogue_line( "Baker", "This wont take long...you ready for us Bravo?", 3 );
	//level._allies[ 0 ] thread smart_dialogue( "black_ice_bkr_whentheygodown" );
	//When this thing goes offline, we’re gonna have to haul ass outta here.
	
//	wait( 3.25  );
//	
//	thread temp_dialogue_line( "Bravo", "Ready and waiting", 1.3 );
//	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_supressionsdownlets" );
	
	//wait( 7.7 );
	
	level._allies[ 0 ] thread smart_radio_dialogue( "black_ice_bkr_supressionsdownlets" );
	//First turbine's down.  Keep it steady.
		
	wait( 4.2 );
	
	level._allies[ 0 ] thread smart_radio_dialogue( "black_ice_bkr_ready321now" );
	//Almost there…
	
	wait( 2.0 );

	level._allies[ 0 ] thread smart_radio_dialogue( "black_ice_bkr_rookpullthelever" );
	//Last one.  Hit it!
	
	wait( 1.2 );
	
	music_play( "mus_blackice_exfil_ss" );
	
	
	
//	while( !(level.color_status == 0)  )
//	{
//		wait level.TIMESTEP;
//	}

}


player_control_baker_nag_and_fail( )
{
	
	level endon( "notify_start_control_minigame" );
	
//	wait( 5 );
//	
//	wait_while_color_status_in_green();
	
//	linetime = 3;
//	thread dialog_line_with_flag( "Baker", "Keep the pressure in the green so I can start on the shutoff valves", linetime  );
//	wait( linetime );//temp wait
	//Keep the pressure in the green, until I'm done with the shutoff valve.  
	
	
	wait( 5 );
	
	wait_while_color_status_in_green();
	
//	linetime = 3;
//	dialog_line_with_flag( "Baker", "Hurry, we dont have a lot of time", linetime );
//	wait( linetime );//temp wait
	//Hold it steady!
	level._allies[ 0 ] smart_radio_dialogue( "black_ice_mrk_holditsteady" );
	
	wait( 3 );
	
	wait_while_color_status_in_green();
	
//	linetime = 3;
//	dialog_line_with_flag( "Baker", "Hold the pressure in the green or we're screwed!", linetime );
//	wait( linetime );//temp wait
	//You gotta keep the pressure down, or we're sinking with this thing.
	level._allies[ 0 ] smart_radio_dialogue( "black_ice_mrk_yougottakeepthe" );
	
	wait( 3 );
	
	wait_while_color_status_in_green();
	
//	linetime = 2;
//	dialog_line_with_flag( "Baker", "ROOK HURRY!!!", linetime );
//	wait( linetime );//temp wait
	//Keep us out of the red!!
	level._allies[ 0 ] smart_radio_dialogue( "black_ice_mrk_keepusoutof" );
	
	wait( 0.1 );
	
	wait_while_color_status_in_green();

	flag_set( "flag_player_failed_control" );
	flag_set( "flag_command_fail_late" );

}

wait_while_color_status_in_green()
{
	
	while( level.color_status == 0 )
	{
		wait level.timestep;
	}
	
}

dialog_line_with_flag( char, dialog, waittime )
{
	
	flag_set( "flag_baker_instructing" );
	thread temp_dialogue_line( char, dialog, waittime );
	wait( waittime );//tempwait
	flag_clear( "flag_baker_instructing" );
	
}



/////////////////////////////
//END PLAYER CONTROL SEQUENCE
/////////////////////////////

allies_baker_command_end_anim( struct )
{
	struct anim_single_solo( self, "command_end", undefined, 0.6 );
	self notify( "notify_command_end_done" );
}


player_input_console_animate( player_struct, player_rig, player_lever_animate )
{
	
	//variables
	bar_lerp_rate = 0.085;
	hand_lerp_rate = 0.26;
	analog_move_rate = 0.072;
	
	
	//inits
	//initiating bar_lerped and bar_target at 0.6 will gently allow the bar to continue rising.
	bar_lerped = 0.6;
	hand_lerped = 0.5;
	hasnt_started = true;
				
	bar_target = 0.6;
	hand_target = 0.5;
	analog_input = [];
	
	level endon( "flag_control_sequence_over" );

	player_struct anim_single_solo( player_rig, "command_start" );
	
	level notify( "notify_start_player_control" );
	
	//init player anim at 0.5(in the midpoint of the lever animation)
	player_struct thread anim_single_solo( player_rig, "command_control" );
	anim_set_rate_single( player_rig, "command_control", 0.0 );
	player_rig SetAnimTime( level.scr_anim[ "player_rig" ][ "command_control" ], 0.5 );
	
	level waittill( "notify_player_start_input_test" );
	//freeze_input_until_player_pulls();
	
	while( 1 )
	{
		
		
		analog_input = level.player GetNormalizedMovement();
		
		/////factor the way the bar moves
		//get the rate to move the target...simple factor of amount of analog * the rate variable
		anim_target_mover = analog_input[0] * analog_move_rate;
		
		
		//allow the bar to raise until the player starts giving inputs. ( bar_target continues to use init values. not updating from player input until player starts input.
		if( hasnt_started == true )
		{
			if( abs( analog_input[0] ) > 0.2 )
			{
				hasnt_started = false;
				//broadcast that the player has started giving input.  This will start the first phase of the minigame.
				flag_set( "flag_player_started_input"  );
			}
		}
		else
		{
			//factor the way the hand moves
			hand_target = normalize_value( -1, 1, analog_input[0] );	
			bar_target = hand_target;
		}

		hand_lerped = lerp_value( hand_lerped, hand_target, hand_lerp_rate );
		bar_lerped = lerp_value( bar_lerped, bar_target, bar_lerp_rate );
		
		//player_struct thread anim_single_solo( player_rig, "command_control" );
		player_rig SetAnimTime( level.scr_anim[ "player_rig" ][ "command_control" ], ( 1 - hand_lerped ) );
		player_lever_animate SetAnimTime( level.scr_anim[ "command_lever" ][ "command_player_control" ], ( 1 - hand_lerped ) );
		
		//broadcast for fx monitor
		broadcast_player_input( 1 - bar_lerped );
		
		
		wait level.TIMESTEP;
	}
}

dialog_baker_init_control()
{
//	wait( 4.1 );
//	thread temp_dialogue_line( "Baker", "Good...Automated fire supression is down", 2.7 );
//	
//	wait( 2.7 );
//	temp_dialogue_line( "Baker", "Manually keep the water pressure in the green so I can start on the shutoff valves", 3 );
	
	wait( 5 );
	level._allies[ 0 ] smart_radio_dialogue( "black_ice_bkr_shutdownthefire" );
	//Keep the pressure in the green, until I'm done with the shutoff valve.  
}

freeze_input_until_player_pulls()
{
	
	while(1)
	{
		analog_input = level.player GetNormalizedMovement();
		
		if( analog_input[0] < -0.2 )
			break;
		
		wait level.TIMESTEP;
		
	}
	
	flag_set( "flag_player_started_input"  );
}

broadcast_player_input( bar_effect_lerped )
{
	
	
	if( bar_effect_lerped > 0.5 )
	{
		move_factor = maps\black_ice_util::normalize_value( 0.5, 1.0, bar_effect_lerped );
		move = maps\black_ice_util::factor_value_min_max( 0, level.player_lever_control_sensitivity, move_factor );
	}
	else
	{
		move_factor = maps\black_ice_util::normalize_value( 0.0, 0.5, bar_effect_lerped );
		move = maps\black_ice_util::factor_value_min_max( level.player_lever_control_sensitivity, 0, move_factor );
		move = 0 - move;
	}
	
	level.player_lever_input = move;
}


monitor_controls_and_fx( monitor )
{
		
	//flag_set( "flag_first_color_pass" );
	
	PlayFXOnTag( getfx( "console_command_start" ), monitor, "tag_fx_screen" );
	thread start_timed_monitor_fx( monitor );
	
	//variables
	bar_noise_small_range = 0.031;
	//bar_drift_lerp_rate = 0.05;
	
	rumble = 0;
	color_status = 0;
	old_color_status = 0;
	fail_screen = false;
	
	//				current, target, lerped
	bar_noise_1 = [ 0.0, 0.0, 0.0 ];
	bar_noise_2 = [ 0.0, 0.0, 0.0 ];
	bar_noise_3 = [ 0.0, 0.0, 0.0 ];
	   //drift amount, direction, timer
	bar_drift = [ 0.0, 0, 0.0 ];
	bar_actual = 0.65;
	
	monitor_fx_g = spawn_anim_model( "command_monitor_fx_green", monitor GetTagOrigin( "j_monitor" ) );
	monitor_fx_y = spawn_anim_model( "command_monitor_fx_yellow", monitor GetTagOrigin( "j_monitor" )  );
	monitor_fx_r = spawn_anim_model( "command_monitor_fx_red", monitor GetTagOrigin( "j_monitor" )  );
	
	monitor_fx_y hide();
	monitor_fx_r hide();
	
	level.monitor_fx = [ monitor_fx_g, monitor_fx_y, monitor_fx_r ];
	
	//link each model and play initial fx
	foreach( mon in level.monitor_fx )
	{	
		mon linkto( monitor, "j_monitor" );
		mon SetAnim( level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_1" ], 1, 0.0, 0.0 );
		mon SetAnim( level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_2" ], 1, 0.0, 0.0 );
		mon SetAnim( level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_3" ], 1, 0.0, 0.0 );
	}
	
	while( !flag( "flag_control_sequence_over" ) )
	{
		//get the big drift the player will need to fight against.
		bar_drift = monitor_bar_drift( bar_drift );
		
		//do the small noise to make the bars more chaotic(this will just be a small amount applied after all the factoring)
		bar_noise_1 = monitor_bar_noise( bar_noise_1, bar_noise_small_range );
		bar_noise_2 = monitor_bar_noise( bar_noise_2, bar_noise_small_range );
		bar_noise_3 = monitor_bar_noise( bar_noise_3, bar_noise_small_range );
		
		//figure out the actual based off the player input and bar drift
		bar_actual += level.player_lever_input;
		
		//apply bar drift
		bar_actual += bar_drift[0];
		
		//allow room for bar noise to be applied without going above or below 0 and 1
		bar_actual = cap_range( bar_actual, bar_noise_small_range, (1 - bar_noise_small_range) );
		
		//set the anim times for each model
		foreach( mon in level.monitor_fx )
		{	
			mon SetAnimtime( level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_1" ], bar_actual + bar_noise_1[2]  );
			mon SetAnimtime( level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_2" ], bar_actual + bar_noise_2[2]  );
			mon SetAnimtime( level.scr_anim[ "command_monitor_fx_green" ][ "command_monitor_fx_3" ], bar_actual + bar_noise_3[2]  );
		}
		
		//figure out the color status based on where the bars are(in the danger zone, etc
		color_status = monitor_color_status( color_status, bar_actual );
		
		//direction the warnings are going in
		if( bar_actual < 0.5 )
			top_of_bar = true; //top of bar
		else
			top_of_bar = false; //bottom of bar
		
		
		//COLOR STATUS
		//if the player failed, just light it up red.
		if( flag( "flag_player_failed_control" )  )
		{
			if( !fail_screen )
			{
				if( top_of_bar )
				{
					killFXOnTag( getfx( "console_command_green_d" ), monitor, "tag_fx_screen" );
					killFXOnTag( getfx( "console_command_red_u" ), monitor, "tag_fx_screen" );
				}
				else
				{
					killFXOnTag( getfx( "console_command_green_u" ), monitor, "tag_fx_screen" );
					killFXOnTag( getfx( "console_command_red_d" ), monitor, "tag_fx_screen" );
				}
				wait( level.TIMESTEP );
				killFXOnTag( getfx( "console_command_start" ), monitor, "tag_fx_screen" );
				killFXOnTag( getfx( "console_command_timer" ), monitor, "tag_fx_screen" );
				playFXOnTag( getfx( "console_command_fail" ), monitor, "tag_fx_screen" );
				monitor_fx_g hide();
				monitor_fx_y hide();
				monitor_fx_r show();
				fail_screen = true;
			}
		}
		else
		{
			//if not failed, continue normally
			//change the color status, only if you need to
			if( !(color_status == old_color_status) )
			{
				switch( color_status )
				{
					case  0:
						monitor_fx_g show();
						monitor_fx_y hide();
						monitor_fx_r hide();
						if( flag(  "flag_start_control_monitor_fx" ) )
						{
							if( top_of_bar )
							{
								PlayFXOnTag( getfx( "console_command_green_u" ), monitor, "tag_fx_screen" );
								StopFXOnTag( getfx( "console_command_yellow_u" ), monitor, "tag_fx_screen" );
							}
							else
							{
								PlayFXOnTag( getfx( "console_command_green_d" ), monitor, "tag_fx_screen" );
								StopFXOnTag( getfx( "console_command_yellow_d" ), monitor, "tag_fx_screen" );
							}
						}
						rumble = 0;
						level.color_status = 0;
					break;
					case  1:
						monitor_fx_g hide();
						monitor_fx_y show();
						monitor_fx_r hide();
						if( flag(  "flag_start_control_monitor_fx" ) )
						{
							if( top_of_bar )
							{
								//direction is up
								PlayFXOnTag( getfx( "console_command_yellow_u" ), monitor, "tag_fx_screen" );
								StopFXOnTag( getfx( "console_command_red_u" ), monitor, "tag_fx_screen" );
								StopFXOnTag( getfx( "console_command_green_u" ), monitor, "tag_fx_screen" );
							}
							else
							{
								//direction is down
								PlayFXOnTag( getfx( "console_command_yellow_d" ), monitor, "tag_fx_screen" );
								StopFXOnTag( getfx( "console_command_red_d" ), monitor, "tag_fx_screen" );
								StopFXOnTag( getfx( "console_command_green_d" ), monitor, "tag_fx_screen" );
							}
						}
						rumble = 1;
						level.color_status = 1;
					break;
					case  2:
						monitor_fx_g hide();
						monitor_fx_y hide();
						monitor_fx_r show();
						if( flag(  "flag_start_control_monitor_fx" ) )
						{
							if( top_of_bar )
							{
								//direction is up
								StopFXOnTag( getfx( "console_command_yellow_u" ), monitor, "tag_fx_screen" );
								PlayFXOnTag( getfx( "console_command_red_u" ), monitor, "tag_fx_screen" );
							}
							else
							{
								//direction is down
								StopFXOnTag( getfx( "console_command_yellow_d" ), monitor, "tag_fx_screen" );
								PlayFXOnTag( getfx( "console_command_red_d" ), monitor, "tag_fx_screen" );
							}
						}
						rumble = 2;
						level.color_status = 2;
					break;		
				}
			old_color_status = color_status;
			}
		}
		
		if ( flag("flag_audio_feedback"))
			thread maps\black_ice_audio::sfx_lever_logic(rumble);
		
		//rumble if in danger
		if( flag( "flag_start_control_monitor_fx" ))
		{
			switch( rumble )
			{
				case 0:
					//thread maps\black_ice_audio::sfx_lever_green();
				break;
				case 1:
					level.player PlayRumbleOnEntity( "lever_feedback_light" );
					//thread maps\black_ice_audio::sfx_lever_yellow();
				break;
				case 2:
					level.player PlayRumbleOnEntity( "lever_feedback_heavy" );
					//thread maps\black_ice_audio::sfx_lever_red();
				break;
			}
		}
		
		//set the water level target for fire supression
		fire_supression_status( bar_actual );
		
		
		wait( level.TIMESTEP );
	}
	
	wait( 0.25 );
	//play effects for monitor shutting off.
	monitor_fx_g hide();
	monitor_fx_y hide();
	monitor_fx_r hide();
	
	killFXOnTag( getfx( "console_command_red_u" ), monitor, "tag_fx_screen" );
	killFXOnTag( getfx( "console_command_red_d" ), monitor, "tag_fx_screen" );
	wait( level.timestep );
	killFXOnTag( getfx( "console_command_yellow_u" ), monitor, "tag_fx_screen" );
	killFXOnTag( getfx( "console_command_yellow_d" ), monitor, "tag_fx_screen" );
	wait( level.timestep );
	killFXOnTag( getfx( "console_command_green_u" ), monitor, "tag_fx_screen" );
	killFXOnTag( getfx( "console_command_green_d" ), monitor, "tag_fx_screen" );
	wait( level.timestep );
	KillFXOnTag( getfx( "console_command_timer" ), monitor, "tag_fx_screen" );
	PlayFXOnTag( getfx( "console_command_end" ), monitor, "tag_fx_screen" );
}

start_timed_monitor_fx( monitor )
{
	
	level waittill(  "notify_start_control_minigame" );
	wait( 1.5 );
	//Audio: Console light up
	thread maps\black_ice_audio::sfx_cmd_console_acknowledge();
	
	flag_set( "flag_start_control_monitor_fx" );
	PlayFXOnTag( getfx( "console_command_green_u" ), monitor, "tag_fx_screen" );
	PlayFXOnTag( getfx( "console_command_green_d" ), monitor, "tag_fx_screen" );
	wait( level.timestep );
	KillFXOnTag( getfx( "console_command_start" ), monitor, "tag_fx_screen" );
	PlayFXOnTag( getfx( "console_command_timer" ), monitor, "tag_fx_screen" );
	
}

fire_supression_status( bar_actual )
{
	
	if( bar_actual > 0.5 )
	{
		water_factor = maps\black_ice_util::normalize_value( 0.53, 0.86, bar_actual );
		water_level = maps\black_ice_util::factor_value_min_max( 6.99, 1, water_factor );
	}
	else
	{
		water_factor = maps\black_ice_util::normalize_value( 0.16, 0.47, bar_actual );
		water_level = maps\black_ice_util::factor_value_min_max( 1, 6.99, water_factor );
	}
	
	level.water_supression_level = int( water_level );

}

monitor_color_status( color_status, bar )
{
	//LOW IS TOP OF BAR. HIGH IS BOTTOM!
	//                  low   high
	yellowthreshold = [ 0.32 , 0.63 ];
	redthreshold = 	[ 0.14, 0.80 ];
	
	//IPrintLn( bar );
	
//	//check to see if this is the first pass...warnings will only occur after the player has started the sequence
//	if(( flag( "flag_first_color_pass" ) ) && ( bar > yellowthreshold[1] ))
//		return 0;
//	else
//	{
//		flag_clear( "flag_first_color_pass"  );
//		IPrintLnBold( bar );
//	}
		
	if( bar < yellowthreshold[0] )
	{
		//bar is lower than yellow low
		if( bar < redthreshold[0] )
		{
			//bar is lowe than red threashold
			color_status = 2;
		}
		else
			color_status = 1;
	}
	else if( bar > yellowthreshold[1] )
	{
		//bar is greater than yellow high
		if( bar > redthreshold[1] )
		{
			//bar is lowe than red threashold
			color_status = 2;
		}
		else
			color_status = 1;
	}
	else
	{
		//bar is in the middle
		color_status = 0;
	}
	
//	IPrintLn( bar );
//	IPrintLn( color_status );
		
	return color_status;
}

monitor_bar_noise( bar_noise, bar_noise_range )
{
	bar_move_rate = 0.0022;
	
	//push current to randomly generated value
	if( abs( bar_noise[0] - bar_noise[1]) < bar_move_rate )
	{
		//current is close to target, seek new random target.
		bar_noise[0] = bar_noise[1];
		bar_noise[1] = RandomFloatRange( 0 - bar_noise_range, bar_noise_range );
	}
	else
	{	
		if( bar_noise[0] > bar_noise[1]  )
		{
			//current is greater than target.
			bar_noise[0] = bar_noise[0] - bar_move_rate;
		}
		else
		{
			//current is less than target
			bar_noise[0] = bar_noise[0] + bar_move_rate;
		}	
	}
	
	//now lerp the lerped value to the current
	bar_noise[2] = lerp_value( bar_noise[2], bar_noise[0], 0.13 );
	
	return bar_noise;
}

monitor_bar_drift( bar_drift )
{
	drift_lerp_rate = 0.025;
	max_time = 3.8;
	min_time = 3.5;
	//level.bar_drift_rate;
	
	//check timer
	if( bar_drift[2] < 0.0  )
	{
		//timer done, change direction
		if( bar_drift[1] == 0 )
			bar_drift[1] = 1;
		else
			bar_drift[1] = 0;
		
		bar_drift[2] = RandomFloatrange( min_time, max_time );
	}
	
	if( bar_drift[1] == 0 )
	{
		//direction is up
		bar_drift[0] = lerp_value( bar_drift[0], level.bar_drift_rate, drift_lerp_rate );
	}
	else
	{
		//direction is down
		bar_drift[0] = lerp_value( bar_drift[0], ( 0 -level.bar_drift_rate ), drift_lerp_rate );
	}
	
	bar_drift[2] -= level.TIMESTEP;
	
	return bar_drift;
	
}

explosion_progression_control_sequence()
{
	
	thread explode_wait_quake( 5.5, "command_control_1", 0.2, 0.26, .75 );
	thread explode_wait_quake( 8.25, "command_control_2", 0.18, 0.35, .85 );
	thread explode_wait_quake( 9.75, "command_control_3", 0.15, 0.41, 1 );
	
}

explosions_success( time_before_explosion )
{
	explode_wait_quake( time_before_explosion, "command_control_4", 0.4, 0.55, 1.3 );
	
	flag_set( "flag_blowup_pipes" );
	
	wait( 2.0 );
	
	Earthquake( 0.35, 1, level.player.origin, 3000 );
	
	wait( 1 );
	
	Earthquake( 0.4, 0.8, level.player.origin, 3000 );
	
	wait( 1.6 );
	
	Earthquake( 0.4, 1.3, level.player.origin, 3000 );
	
}


explode_wait_quake( waittime, explode, delaytime, scale, duration )
{
	
	wait( waittime );
	
	exploder( explode );
	
	//Audio: Explosion sfx
	thread maps\black_ice_audio::sfx_controlroom_explosions(explode);
	
	wait( delaytime );
		
	Earthquake( scale, duration, level.player.origin, 3000 );
	
}

//create a rumble and quake that swells before final explosion
sucess_swelling_rumble( time_before_explosion, time_before_rumble, fade_time )
{
	wait( time_before_rumble );
	
	time_before_explosion = ( time_before_explosion - ( time_before_rumble + fade_time ));
	
	//IPrintlnbold(  time_before_explosion );
	rumble_ent = get_rumble_ent();
	rumble_ent.intensity = 0.0;
	rumble_ent thread rumble_ramp_to( 0.4, time_before_explosion );
	thread maps\black_ice_util::player_view_shake_blender( time_before_explosion, 0.001, 0.21 );
	wait( time_before_explosion );
	//shut off rumble and shake for one second before big rumble
	rumble_ent thread rumble_ramp_to( 0.05, fade_time );
	thread maps\black_ice_util::player_view_shake_blender( fade_time, 0.21, 0.05 );
	wait( fade_time + 0.15 );
	//big rumble in and out fore splosion
	rumble_ent thread rumble_ramp_to( 1.3, 0.2 );
	wait( 0.2 );
	rumble_ent thread rumble_ramp_to( 0.0, 0.8 );
	wait( 1.3 );
	rumble_ent delete();
	
	
}

command_light_change()
{
	
	level endon( "flag_ladder_jumpcheck" );
	
	light1 = GetEnt( "comms_overhead_1","targetname");
	light2 = GetEnt( "comms_overhead_2","targetname");
//	light3 = GetEnt( "comms_overhead_3","targetname");
	
	//lights = [ light1, light2, light3 ];
	lights = [ light1, light2 ];
	
	redlights = GetEntArray( "emergency_red_exfil_light","targetname" );
	
	foreach( light in lights )
	{
		light SetLightIntensity( 2 );
	}
	
	//set one command center light to flicker	
	//light3 thread flicker( 0.9, 0.5, "notify_stop_flicker" );
	
	//setup models
	sirens_on = GetEntArray( "command_light_siren", "targetname" );
	sirens_nolight_on = GetEntArray( "command_light_siren_nolight", "targetname" );
	sirens_off = GetEntArray( "command_light_siren_off", "targetname" );
	sirens_nolight_off = GetEntArray( "command_light_siren_nolight_off", "targetname" );
	
	//create souces for light fx to play off
	effect_sources_light = [];
	i = 0;
	foreach( siren in sirens_on )
	{	
		
		effect_sources_light[i] = spawn_tag_origin();
		
		effect_sources_light[i].origin = siren gettagorigin( "TAG_fx_main" );
		effect_sources_light[i].angles = siren gettagangles( "TAG_fx_main" );
	
		effect_sources_light[i] LinkTo( siren,  "TAG_fx_main" );
		i += 1;
	}
	
	//create souces for nolight fx to play off
	effect_sources_nolight = [];
	i = 0;
	foreach( siren in sirens_nolight_on )
	{	
		effect_sources_nolight[i] = spawn_tag_origin();
		
		effect_sources_nolight[i].origin = siren gettagorigin( "TAG_fx_main" );
		effect_sources_nolight[i].angles = siren gettagangles( "TAG_fx_main" );
	
		effect_sources_nolight[i] LinkTo( siren,  "TAG_fx_main" );
		i += 1;
	}
	
	//hide "on" models
	foreach( siren in sirens_on )
	{
		siren hide();
	}
	foreach( siren in sirens_nolight_on )
	{
		siren hide();
	}
	
	//wait for player to pull lever
	if(level.start_point != "exfil" )
		level waittill( "flag_start_lights"  );
	
	wait( 0.55 );
	
	//turn off white lights(stop flicker too)
	foreach( light in lights )
	{
		light notify( "notify_stop_flicker" );
		light SetLightIntensity(0.0001);
		light SetLightRadius( 12 );
	}
	
	light_pulserate = 0.6;
	//wait light_pulserate;
	
	//flash red lights on and off
	while( 1 )
	{
		///////////red lights on!///////////
		stop_exploder( "exfil_wall_alarm_yellow" );
		
		wait level.TIMESTEP;
		
		if( !flag("flag_vision_exfil_deck")  &&  !flag( "flag_player_dying_on_rig" )  )
			vision_set_fog_changes( "black_ice_command_red", 0 );
		
		
		//fx for lights
		foreach( source in effect_sources_light )
		{				
			PlayFXOnTag( level._effect[ "command_siren_red" ], source, "tag_origin" );
		}
		//fx for no lights
		foreach( source in effect_sources_nolight )
		{				
			PlayFXOnTag( level._effect[ "command_siren_red_low" ], source, "tag_origin" );
		}
		//set dynamic light
		foreach( light in redlights )
		{				
			light SetLightIntensity(1.2);
		}
		foreach( siren in sirens_on )
		{
			siren show();
		}
		foreach( siren in sirens_nolight_on )
		{
			siren show();
		}
		foreach( siren in sirens_off )
		{
			siren hide();
		}
		foreach( siren in sirens_nolight_off )
		{
			siren hide();
		}
		
		wait light_pulserate;
		////////////red lights off//////////
		/// 
		if( !flag("flag_vision_exfil_deck") &&  !flag( "flag_player_dying_on_rig" )  )
			vision_set_fog_changes( "black_ice_command_yellow", 0 );
		
		//fx for lights
		foreach( source in effect_sources_light )
		{				
			StopFXOnTag( level._effect[ "command_siren_red" ], source, "tag_origin" );
		}
		//fx for no lights
		foreach( source in effect_sources_nolight )
		{				
			StopFXOnTag( level._effect[ "command_siren_red_low" ], source, "tag_origin" );
		}
		//set dynamic light
		foreach( light in redlights )
		{				
			light SetLightIntensity(0.0001);
		}
		foreach( siren in sirens_on )
		{
			siren hide();
		}
		foreach( siren in sirens_nolight_on )
		{
			siren hide();
		}
		foreach( siren in sirens_off )
		{
			siren show();
		}
		foreach( siren in sirens_nolight_off )
		{
			siren show();
		}
		
		wait level.TIMESTEP;
		
		exploder( "exfil_wall_alarm_yellow" );
		
		wait light_pulserate;
		
	}
}

allies_baker_console_anims( baker_struct, player_rig )
{
	
	level waittill( "flag_command_baker_console_anim" );
			
	baker_struct thread anim_single_solo( level._allies[ 0 ], "command_start" );
	//baker_struct thread anim_single_solo( baker_console, "command_start" );
	
	bakeranim = level._allies[ 0 ] getanim( "command_start" );
	//consoleanim = baker_console getanim( "command_start" );
	
	wait( level.TIMESTEP );
	
	time = player_rig GetAnimTime( level.scr_anim[ "player_rig" ][ "command_start" ] );
	
	level._allies[ 0 ] SetAnimTime( bakeranim, time );
	
	level waittill( "notify_start_control_minigame" );
	
	baker_struct thread anim_single_solo( level._allies[ 0 ], "command_control" );
	
	//baker_console SetAnimTime( consoleanim, time );
}

player_view_manager()
{
	
	// Start player lookaround control	
	level waittill( "notify_control_room_allow_free_look" );
	level.player LerpViewAngleClamp( 1.0, 0, 0, 20, 20, 20, 15 );
	
	level waittill( "notify_focus_monitor" );

	level.player SpringCamEnabled( 0.4, 3.2, 1.6 );
	wait( 1.5 );
	level.player SpringCamEnabled( 0.4, 3.2, 0.4 );
	
}

smooth_player_link( player_rig, blendtime )
{
	
	level.player PlayerLinkToBlend( player_rig, "tag_player", blendtime );
	wait( blendtime );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
	player_rig Show();	
	
}


player_anim_countdown()
{
	wait( GetAnimLength( level.scr_anim[ "player_rig" ][ "command_start" ] ));
	level notify( "notify_player_command_start_anim_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


water_shutdown_exploder_manager()
{
	
	level waittill( "notify_control_room_allow_free_look" );	
	
	//IPrintLnBold( "shutdown!" );
	

	thread supression_shutdown_sequencer( "water_supression_on_1", "water_supression_off_a_1", "water_supression_off_b_1", "water_supression_off_c_1", "water_supression_off_d_1", "water_supression_off_e_1", "water_supression_off_f_1"  );
	wait 0.5;
	thread supression_shutdown_sequencer( "water_supression_on_2", "water_supression_off_a_2", "water_supression_off_b_2", "water_supression_off_c_2", "water_supression_off_d_2", "water_supression_off_e_2", "water_supression_off_f_2" );
	wait 0.5;
	thread supression_shutdown_sequencer( "water_supression_on_3", "water_supression_off_a_3", "water_supression_off_b_3", "water_supression_off_c_3", "water_supression_off_d_3", "water_supression_off_e_3", "water_supression_off_f_3" );


	
//	wait 0.3;
//	exploder( "derrick_explode_small" );
//	quake( "scn_blackice_tanks_dist_explo" );
//	//delete derrick fire
//	//exploder( "oil_geyeser_01" ) delete();
//	
//	wait 2.8;
//	exploder( "pipedeck_explode_01" );
//	quake( "scn_blackice_tanks_dist_explo" );
//	
//	wait 0.6;
//	exploder( "pipedeck_explode_02" );
//	quake( "scn_blackice_tanks_dist_explo" );
//	
//	wait 3.3;
//	exploder( "pipedeck_explode_03" );
//	quake( "scn_blackice_tanks_dist_explo" );
//	
//	wait 2.3;
//	exploder( "pipedeck_explode_04" );
//	quake( "scn_blackice_tanks_dist_explo" );
	//earthquake( 0.44, 3, level.player.origin, 128 );
	
}

supression_shutdown_sequencer( on, off1, off2, off3, off4, off5, off6 )
{
	water_levels = [ off6, off5, off4, off3, off2, off1, on ];
	//sytem will init with the water all the way on
	current_supression_level = 6;
	while( 1 )
	{
		if( current_supression_level > level.water_supression_level )
		{
			//blend to next lowest level
			blend_to_exploder( water_levels[current_supression_level], water_levels[current_supression_level - 1] );
			current_supression_level -= 1;
		}
		else if( current_supression_level < level.water_supression_level )
		{
			//blend to next highest level
			blend_to_exploder( water_levels[current_supression_level], water_levels[current_supression_level + 1] );
			current_supression_level += 1;
		}
		
		if( current_supression_level == 0 )
		{			
			///it will only reach zero when the sequence is over shutdowmn!  end sequencer!!!
			blend_to_exploder( off6 );
			break;
		}
		
		wait level.TIMESTEP;	
	}
	
}

blend_to_exploder( exploder1, exploder2 )
{
	//this will toggle between exploders over a set time.  starts weighting the first exploder more, then moves to the second exploder
	steps = 3;
	max_on = 0.1;
	while( steps > 0 )
	{
		//2
		stop_exploder( exploder1 );
		if( isdefined( exploder2 ))
			exploder( exploder2 );
		wait( max_on/steps );
		//1
		exploder( exploder1 );
		if( isdefined( exploder2 ))
			stop_exploder( exploder2 );
		wait( max_on - (max_on/steps) );
		steps -= 1;
	}
	
	stop_exploder( exploder1 );
	if( isdefined( exploder2 ))
		exploder( exploder2 );
	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_pipe_explosions()
{
	flag_wait( "flag_command_start" );
	
	// Remove old pipes
	old_pipes = GetEntArray( "model_pipedeck_explosion3_old", "targetname" );
	foreach( thing in old_pipes )
		thing delete();
	
	// Setup rigs
	rig_2 = setup_tag_anim_rig( "pipe_explosion2", "pipedeck_explosion2_rig" );
	rig_3 = setup_tag_anim_rig( "pipe_explosion3", "pipedeck_explosion3_rig" );	
	
	// Setup rigs to animate on flag
	rig_2 thread tag_anim_rig_init_and_flag_wait( "flag_command_pipes_2", "pipes_explode" );
	rig_3 thread tag_anim_rig_init_and_flag_wait( "flag_command_pipes_3", "pipes_explode" );	
	
	flag_wait( "flag_blowup_pipes" );
	
	wait( 0.3 );
	
	// Make pipes explode once lever is pulled
	flag_set( "flag_command_pipes_2" );
	flag_set( "flag_command_pipes_3" );
}


dim_overhead_light()
{
	wait 3.5;
	coms_overhead_light = getEnt("comms_overhead_1","targetname");
	current_intensity = coms_overhead_light GetLightIntensity();
	new_color = (0.89,0.75,0.57);
	new_intensity = 1.4;
	intensity_trans = 0.05;
	
	thread transitionlightcolor(coms_overhead_light,new_color);
	while(current_intensity>new_intensity)
	{
	current_intensity-=intensity_trans;
	coms_overhead_light SetLightIntensity(current_intensity);
	waitframe();
	}
	light_pulse(coms_overhead_light,1.0);
}
set_command_dof()
{
	maps\_art::dof_enable_script( 0, 7, 4, 121, 545, 0.3, 2.0 );
	
	level waittill( "flag_start_lights" );
	
	maps\_art::dof_disable_script( 1.25 );
}


light_pulse(light,min_intensity)
{
	level endon("flag_start_lights");
	self.light = light;
	self.min_intensity = min_intensity;
	maxintensity = light GetLightIntensity();
	currentintensity = self.light GetLightIntensity();		
	while(1)
	{
		while(currentintensity>min_intensity)
		{
			currentintensity -= 0.01;
			self.light SetLightIntensity(currentintensity);
			waitframe();
		}
		while(currentintensity<maxintensity)
		{
			currentintensity += 0.02;
			self.light SetLightIntensity(currentintensity);
			waitframe();
		}
		waitframe();
	}
}


transitionlightcolor(light,new_color)
{
	self.new_color = new_color;
	mylight = light;
	current_color = mylight GetLightColor();
	while(current_color[0]>self.new_color[0])
	{
		current_color-=(0.01,0.01,0.01);
		mylight SetLightColor(current_color);
		waitframe();
	}
	while(current_color[1]>self.new_color[1])
	{
		current_color-=(0.0,0.01,0.01);
		mylight SetLightColor(current_color);
		waitframe();
	}
	while(current_color[2]>self.new_color[2])
	{
		current_color-=(0.0,0.0,0.01);		
		mylight SetLightColor(current_color);
		waitframe();
	}
}

notetrack_blast_shake_early(player_rig)
{
	level notify( "notify_blast_kill_player" );
}

notetrack_blast_shake_late(player_rig)
{
	level notify( "notify_blast_kill_player" );
}
command_godrays()
{
	gr_origin = getEnt("cc_gr_origin","targetname");
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_catwalk");
		god_rays_from_world_location ( gr_origin.origin, "flag_command_start", "flag_teleport_rig", undefined, undefined);
	}
}


//*******************************************************************
//util                                                              *
//                                                                  *
//*******************************************************************

copy_node( node )
{
	new_node = spawn_tag_origin();
	new_node.origin = node.origin;
	new_node.angles = node.angles;
	
	return new_node;
}

lerp_value( value, tar, rate )
{
	
	diff = ( tar - value ) * rate;
	value += diff;
	
	return value;
	
}

cap_range( val, min, max )
{
	
	if( val > max )
		val = max;
	else if( val < min )
		val = min;
	
	return val;
}