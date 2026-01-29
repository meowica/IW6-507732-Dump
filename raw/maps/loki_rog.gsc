#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	level.TIMESTEP = 0.05;
	level.ROG_explosion_radius = 2000;
	level.ROG_num_rods = 8;
	level.ROG_single_order = [ 6, 7, 5, 0, 4, 1, 3, 2 ];
	level.ROG_single_curr_index = 0;
	level.ROG_single_num_active = 0;
	level.can_fire = false;
	// Simulate terminal velocity for ROG
	// For a human, it'd be approx:
	// Need in/frame: 54 m/s * level.TIMESTEP (s/frame) * 40 (in/m)
	level.ROG_velocity = 108.0;
	// But, of course, that's definitely too slow for the engine...hence:
	level.ROG_velocity *= 90.0;
	level.ROG_velocity_start	  = level.ROG_velocity;
	level.ROG_single_velocity_max = level.ROG_velocity * 13.0;
	level.ROG_single_acceleration= 10000.0;
	level._layouts						   = [];
	level._layouts[ "learn"	   ]		   = [];
	level._layouts[ "practice" ]		   = [];
	level._layouts[ "execute"  ]		   = [];
	level.ROG_targets					   = [];
	level.ROG_current_layout			   = "";
	level.ROG_current_section			   = 0;
	level.ROG_sequence_time				   = 40.0;
	level.ROG_sequence_time_warning		   = 20.4;
	level.ROG_sequence_time_terminal	   = 27.0;
	level.ROG_targets_enemies			   = 0;
	level.ROG_targets_friendlies		   = 0;
	level.ROG_targets_flyers			   = [];
	level.ROG_targets_flyers[ 0 ]		   = [];
	level.ROG_targets_flyers[ 1 ]		   = [];
	level.ROG_targets_flyers[ 2 ]		   = [];
	level.ROG_targets_flyers[ 3 ]		   = [];
	level.crater_array					   = [];
	level.rog_blast_radius_outer		   = [];
	level.rog_blast_radius_inner		   = [];
	level.ROG_moving_targets			   = [];
	level.ROG_moving_targets[ "learn"	 ] = [];
	level.ROG_moving_targets[ "practice" ] = [];
	level.ROG_moving_targets[ "execute"	 ] = [];
	level.ROG_last_blast_pos			   = undefined;

	SetDvarIfUninitialized( "dev_dollyzoom_fov_start_learn", 12 );
	SetDvarIfUninitialized( "dev_dollyzoom_fov_start_practice", 25 );
	SetDvarIfUninitialized( "dev_dollyzoom_fov_start_execute", 45 );
	SetDvarIfUninitialized( "dev_dollyzoom_time_start_zoom_length_learn", 1.75 );
	SetDvarIfUninitialized( "dev_dollyzoom_time_start_zoom_length_practice", 1.15 );
	SetDvarIfUninitialized( "dev_dollyzoom_time_start_zoom_length_execute", 0.95 );
	SetDvarIfUninitialized( "dev_dollyzoom_fov_end", 65 );				// this needs to match kriss_ROG fov setting
	SetDvarIfUninitialized( "dev_dollyzoom_time_delta", 36.0 );
	SetDvarIfUninitialized( "dev_camera_delta_from_learn_start", 240000 );
	SetDvarIfUninitialized( "dev_camera_delta_from_practice_start", 210000 );
	SetDvarIfUninitialized( "dev_camera_delta_from_execute_start", 185100 );
	SetDvarIfUninitialized( "dev_ROG_rechamber_time", 0.8 );
	SetDvarIfUninitialized( "dev_ROG_AOE_duration_time", 3.0 );
	SetDvarIfUninitialized( "dev_ROG_AOE_duration_interval", 0.5 );
	SetDvarIfUninitialized( "dev_ROG_blast_radius", 2000.0 );
	SetDvarIfUninitialized( "dev_ROG_target_reveal_spacing", 0.06 );
	SetDvarIfUninitialized( "dev_ROG_flyer_group_0_reveal", 0.0 );
	SetDvarIfUninitialized( "dev_ROG_flyer_group_1_reveal", 4.0 );
	SetDvarIfUninitialized( "dev_ROG_flyer_group_2_reveal", 7.0 );
	SetDvarIfUninitialized( "dev_ROG_flyer_group_3_reveal", 10.0 );
	SetDvarIfUninitialized( "dev_ROG_final_decent_delta", 15500.0 );
	SetDvarIfUninitialized( "dev_ROG_final_decent_time", 4.0 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	PreCacheItem( "kriss_rog_0" );
	PreCacheItem( "kriss_rog_1" );
	PreCacheItem( "kriss_rog_2" );
	PreCacheRumble( "steady_rumble" );
	//PreCacheShellShock( "default" );

	PreCacheShader( "nightvision_overlay_goggles" );

	// Temp crater model
	PreCacheModel( "ac_prs_ter_crater_a_1" );

	maps\loki_rog_hud::section_precache();

	add_hint_string( "hint_launch_single_rod", &"LOKI_ROG_TEACH_TEXT_0", ::disable_launch_single_rod_hint );
	add_hint_string( "hint_zoom", &"LOKI_ROG_TEACH_TEXT_1", ::disalbe_zoom_hint );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "rog_done" );
	flag_init( "layout_learn_done" );
	flag_init( "layout_practice_done" );
	flag_init( "layout_execute_done" );
	flag_init( "setup_layout_done" );
	flag_init( "starting_anim_done" );
	flag_init( "attack_pressed" );
	flag_init( "dont_show_pull_trigger_hint" );
	flag_init( "dont_show_zoom_hint" );
	flag_init( "force_low_camera_shake" );
	flag_init( "final_decent_active" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rog_start()
{
	player_move_to_checkpoint_start( "rog" );
	//spawn_allies();

	//maps\loki_util::player_move_to_checkpoint_start( "rog" );
	//maps\loki_util::spawn_allies();

	flag_set( "attack_pressed" );
	/*
	foreach( ally in level.allies )
	{
		ally disable_ai_color();
	}
	*/
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rog()
{
	autosave_by_name_silent( "rog" );

	if ( !flag( "attack_pressed" ) )
	{
		wait_till_player_uses_terminal();
	}

	setup_layout( "learn" );
	level thread ROG_logic();

	flag_wait( "layout_learn_done" );

	autosave_by_name( "layout_learn_done" );

	cleanup_layout( "learn" );

	flag_clear( "dont_show_zoom_hint" );
	setup_layout( "practice" );

	flag_wait( "layout_practice_done" );

	autosave_by_name( "layout_practice_done" );

	cleanup_layout( "practice" );

	setup_layout( "execute" );

	flag_wait( "layout_execute_done" );
	//flag_wait( "rog_done" );

	cleanup_layout( "execute" );

	
	nextmission();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_init()
{
	//play the rog ambient sounds loop
	set_audio_zone ( "loki_rog_fire" );

	// start our progression feedback
	level thread ROG_feedback_logic();

	// setup moving pieces
	level.player_rig		  = spawn_anim_model( "player_rig" );
	level.player_rig.animname = "player_rig";
	level.mover_model		  = spawn_anim_model( "ROG" );
	level.player_mover		  = spawn_tag_origin();
	level.ROG_ref_ent		  = GetEnt( "ROG_ref_ent", "script_noteworthy" );
	level.ROG_AOE_reticle	  = GetEnt( "AOE", "targetname" );
	level.ROG_AOE_reticle Hide();
	level.ROG_AOE_reticle NotSolid();
	for ( index = 0; index < 8; index++ )
	{
		level.rog_blast_radius_outer[ index ] = GetEnt( "blast_radius_outer_" + index, "targetname" );
		level.rog_blast_radius_outer[ index ] NotSolid();
		level.rog_blast_radius_outer[ index ] Hide();
		level.rog_blast_radius_inner[ index ] = GetEnt( "blast_radius_inner_" + index, "targetname" );
		level.rog_blast_radius_inner[ index ] NotSolid();
		level.rog_blast_radius_inner[ index ] Hide();
	}

	// player initial setup
	level.player EnableSlowAim( 0.15, 0.15 );
	level.player.ignoreme = true;
	level.player thread ROG_ADS_logic();
	level.player PlayerSetGroundReferenceEnt( level.ROG_ref_ent );
	//level.ROG_ref_ent thread ROG_camera_sway();

	level.player DisableOffhandWeapons();
	level.player DisableWeaponSwitch();
	level.player AllowCrouch( false );
	level.player AllowJump( false );
	//level.player AllowLean( false );
	level.player AllowMelee( false );
	level.player AllowProne( false );
	level.player AllowSprint( false );
	level.player DisableWeaponSwitch();
	level.player AllowMelee( false );
	level.player AllowFire( false );
	level.player HideViewModel();

	// start our UI
	level thread maps\loki_rog_hud::ROG_hud();
	level thread maps\loki_rog_hud::ROG_vision();
	level thread maps\loki_rog_hud::ROG_screen_shake();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_reset()
{
	level.ROG_start = GetEnt( "ROG_start_" + level.ROG_current_layout + "_" + level.ROG_current_section, "script_noteworthy" );

	level thread ROG_velocity_adjust();

	level.mover_model Show();

	for ( i = 0; i < level.ROG_num_rods; i++ )
	{
		if ( IsDefined( level.ROG_single_rods ) && IsDefined( level.ROG_single_rods[i] ) )
		{
			continue;
		}

		tag_name = "tag_rog_00" + ( i + 1 );
		org = level.mover_model GetTagOrigin( tag_name );
		ang = level.mover_model GetTagAngles( tag_name );

		level.ROG_single_rods[i] = spawn_anim_model( "loki_rog_single", org );
		level.ROG_single_rods[i].angles = ang;

		level.ROG_single_rods[i] LinkTo( level.mover_model, tag_name );
		level.ROG_single_rods[i] Show();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_camera_sway()
{
	level endon( "ROG_end" );
	level.camera_sway_model = spawn_anim_model( "ROG_sway" );
	sway_anim = level.scr_anim[ "ROG_sway" ][ "violent_sway" ];
	level.camera_sway_model LinkTo( self );

	while( true )
	{
		flag_wait( "starting_anim_done" );

		level.camera_sway_model SetAnimRestart( sway_anim, 1.0, 0.0, 1.0 );

		flag_waitopen( "starting_anim_done" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_ADS_logic()
{
	// TODO <MJS> can prolly hook up hiding the target model here as well.
	// TODO <MJS> need to force off PC toggle ads.
	level endon( "ROG_end" );

	level.player AllowAds( false );
	prev_can_fire_state = level.can_fire;

	while( true )
	{
		if ( prev_can_fire_state != level.can_fire )
		{
			if ( level.can_fire )
			{
				level.player AllowAds( true );
			}
			else
			{
				level.player AllowAds( false );
			}
		}
		prev_can_fire_state = level.can_fire;
		wait( level.TIMESTEP );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

wait_till_player_uses_terminal()
{
	dist = 100;
	terminal = getent("rog_terminal_obj", "targetname");
	usable = getent("rog_terminal", "targetname");
	usable MakeUsable();
	while(1)
	{
		if(distance(level.player.origin, terminal.origin) < dist)
		{
			usable SetHintString( &"SCRIPT_HOLD_TO_USE" );
			if(flag("attack_pressed"))
			{
				
				usable delete();
				
				terminal_link = getent("rog_terminal_link", "targetname");
				level.player PlayerLinkToBlend( terminal_link, "", 1.0, .3, .3 );
				break;
			}
		}
		wait(.1);
	}
	wait(1.25);
	terminal delete();
	//IPrintLnBold("Start ROG Sequence");
	level.player Unlink();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

setup_layout( section )
{
	// reset these values
	level.ROG_targets_enemies = 0;
	level.ROG_targets_friendlies = 0;
	destruction_reset();

	level.ROG_current_layout = section;

	switch( level.ROG_current_layout )
	{
		case "learn":
			level.player GiveWeapon( "kriss_rog_0" );
			level.player SwitchToWeapon( "kriss_rog_0" );
			break;
		case "practice":
			level.player TakeWeapon( "kriss_rog_0" );
			level.player GiveWeapon( "kriss_rog_1" );
			level.player SwitchToWeapon( "kriss_rog_1" );
			break;
		case "execute":
			level.player TakeWeapon( "kriss_rog_1" );
			level.player GiveWeapon( "kriss_rog_2" );
			level.player SwitchToWeapon( "kriss_rog_2" );
	}

	origins = getstructarray( "layout_" + section + "_struct", "targetname" );
	foreach( origin in origins )
	{
		model = Spawn( "script_model", origin.origin );
		model.angles = origin.angles;
		if( IsDefined( origin.script_noteworhty ) )
		{
			switch( origin.script_noteworhty )
			{
				case "dots":
					model SetModel( "vehicle_parachute" );
					break;

				case "large_target":
					model SetModel( "vehicle_hummer" );
					break;

				case "vehicle":
					model SetModel( "vehicle_m1a1_abrams" );
					break;

				case "building":
					model SetModel( "ac_prs_enm_cargo_crate_a_1" );
					break;
					
				case "jet":
					model SetModel( "vehicle_f15" );
					break;

				default:
					model SetModel( "character_fed_space_assault_a" );
			}
		}
		else
		{
			model SetModel( "character_fed_space_assault_a" );
		}
		if( IsDefined( origin.script_index ) )
		{
			if( !IsDefined( level.ROG_moving_targets[ level.ROG_current_layout ][ origin.script_index ] ) )
			{
				level.ROG_moving_targets[ level.ROG_current_layout ][ origin.script_index ] = [];
			}
			level.ROG_moving_targets[ level.ROG_current_layout ][ origin.script_index ][ level.ROG_moving_targets[ level.ROG_current_layout ][ origin.script_index ].size ] = model;
			model.script_index = origin.script_index;
		}
		model.script_team = origin.script_team;
		if( origin.script_team == "allies" )
		{
			level.ROG_targets_friendlies++;
		}
		else
		{
			level.ROG_targets_enemies++;
		}
		model.script_noteworthy = origin.script_noteworthy;
		model.targetname = "ROG_opfor_target";
		level._layouts[ section ][ level._layouts[ section ].size ] = model;
	}
	flag_set( "setup_layout_done" );
	IPrintLn( "Layout " + level.ROG_current_layout + " has " + level.ROG_targets_enemies + " enemy targets & " + level.ROG_targets_friendlies + " friendly targets" );
	script_brushmodel_moving_clouds = GetEnt( "script_origin_rog_camera_" + section + "_0", "targetname" );
	thread stephen_script_move_clouds( script_brushmodel_moving_clouds );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

stephen_script_move_clouds( camera_node )
{
	script_brushmodel_moving_clouds		   = get_target_ent( "script_brushmodel_moving_clouds" );
	script_brushmodel_moving_clouds.origin = ( camera_node.origin[0], camera_node.origin[1], -66749 );
	
	wait 4;
	level endon( "setup_layout_done" );

	script_brushmodel_moving_clouds MoveZ( 200000, 30, .1, .1 );	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

cleanup_layout( section )
{
	foreach( targ in level.ROG_targets )
	{
		if ( Target_IsTarget( targ ) )
		{
			Target_Remove( targ );
		}
	}

	foreach ( model in level._layouts[ section ] )
	{
		if ( IsDefined( model ) )
		{
			model Delete();
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

disable_launch_single_rod_hint()
{
	if( level.player AttackButtonPressed() && level.can_fire )
	{
		flag_set( "dont_show_pull_trigger_hint" );
	}
	return flag( "dont_show_pull_trigger_hint" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

disalbe_zoom_hint()
{
	if ( level.player AdsButtonPressed() && level.can_fire )
	{
		flag_set( "dont_show_zoom_hint" );
	}
	return flag( "dont_show_zoom_hint" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_logic()
{
	// This logic is all temp until we have better timing mechanisms in place
	fade_in_time = 0.5;
	add_wait_time = 0.05;
	fade_out_time = 0.0;

	// initial fade out
	level thread black_fade( fade_in_time, add_wait_time, fade_out_time );
	wait fade_in_time;

	level notify( "kill_thrusters" );

	ROG_init();
	level thread ROG_sequence_new_pass( true );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_sequence_animations( wait_time )
{
	wait( wait_time );

	level.mover_model SetAnim( level.scr_anim[ "ROG" ][ "breakapart" ], 1.0, 0.0, 1.0 );
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "breakapart" ], 1.0, 0.0, 1.0 );
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "camera_shake_breakapart" ], 1.0, 0.0, 1.0 );

	while ( !( level.mover_model check_anim_time( "ROG", "breakapart", 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}

	//level.mover_model SetAnim( level.scr_anim[ "ROG" ][ "decelerate" ], 1.0, 0.0, 1.0 );
	
	//while ( !( level.mover_model check_anim_time( "ROG", "decelerate", 1.0 ) ) )
	//{
	//	wait level.TIMESTEP;
	//}

	//level.mover_model SetAnim( level.scr_anim[ "ROG" ][ "decelerate_loop" ], 1.0, 0.0, 1.0 );
	flag_set( "starting_anim_done" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_sequence_new_pass( new_layout )
{
	fade_in_time = 0.0;
	add_wait_time = 0.05;
	fade_out_time = 1.0;

	level thread black_fade( fade_in_time, add_wait_time, fade_out_time );

	wait fade_in_time;

	ROG_reset();
	player_setup();		// should be about relinking everything

	flag_clear( "starting_anim_done" );

	// Reset variables
	level.ROG_single_curr_index = 0;

	ROG_target_cleanup();
	ROG_reset_anims();

	level thread ROG_mechanics();
	level thread ROG_sequence_animations( fade_out_time );
	level thread maps\loki_rog_hud::ROG_hud_logic_reset();

	flag_wait( "starting_anim_done" );
	if ( new_layout )
	{
		level thread ROG_setup_targets();
	}
	level thread ROG_targeting_logic();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_reset_anims()
{
	// Reset all anims
	level.mover_model SetAnim( level.scr_anim[ "ROG" ][ "breakapart" ], 0.0, 0.0, 0.0 );
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "breakapart" ], 0.0, 0.0, 0.0 );
	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "camera_shake_breakapart" ], 0.0, 0.0, 0.0 );
	
	for ( i = 0; i < level.ROG_num_rods; i++ )
	{
		anime = "loki_rog_seperate_0" + ( i + 1 );
		level.mover_model SetAnim( level.scr_anim[ "ROG" ][ anime ], 0.0, 0.0, 0.0 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_target_cleanup()
{
	foreach( target in level.ROG_targets )
	{
		if ( IsDefined( target.mark_for_delete ) && target.mark_for_delete )
		{
			target Delete();
			level.ROG_targets = array_remove( level.ROG_targets, target );
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

black_fade( fade_in_time, add_wait_time, fade_out_time )
{
	// Black overlay
	black_overlay = maps\_hud_util::create_client_overlay( "black", 0, level.player );
	
	if ( fade_in_time > 0 )
	{
		black_overlay FadeOverTime( fade_in_time );
	}
	
	black_overlay.alpha = 1;
	
	wait fade_in_time;
	wait add_wait_time;
	
	// Fade out black overlay
	if ( fade_out_time > 0 )
	{
		black_overlay FadeOverTime( fade_out_time );
	}
	
	black_overlay.alpha = 0;
	
	wait fade_out_time;
	
	black_overlay Destroy();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

check_anim_time( animname, anime, time )
{
	curr_time = self GetAnimTime( level.scr_anim[ animname ][ anime ] );
	if ( curr_time >= time )		
	{
		return true;
	}

	return false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_setup()
{
	//reset our moving pieces
	level.player_mover Unlink();
	level.mover_model Unlink();
	level.player_rig Unlink();
	level.player Unlink();
	level.player_mover.origin = level.rog_start.origin;
	level.player_mover.angles = level.rog_start.angles;
	level.mover_model.origin  = level.rog_start.origin;
	level.mover_model.angles  = level.rog_start.angles;
	level.player_rig.origin	  = level.rog_start.origin;
	level.player_rig.angles	  = level.rog_start.angles;
	level.player.origin		  = level.rog_start.origin;
	level.player.origin		  = level.rog_start.angles;

	setup_player_for_animated_sequence( true, 0, level.ROG_start.origin, level.ROG_start.angles, true, false, "ROG" );

	level.player thread ROG_camera_logic();

	level.player_rig SetAnim( level.scr_anim[ "player_rig" ][ "idle" ], 1.0, 0.0, 1.0 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_camera_logic()
{
	self notify( "foobar" );
	self endon( "foobar" );

	while( true )
	{
		level waittill( "ROG_new_sequence" );
		wait( 0.6 );
		self PlayerLinkToDelta( level.player_rig, "tag_player", 1, 0, 0, 45, 0, true );
		wait( level.TIMESTEP );
		self LerpViewAngleClamp( level.TIMESTEP, 0, 0, 45, 45, 45, 25 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_velocity_adjust()
{
	level endon( "ROG_end_of_sequence" );
	
	level.ROG_velocity = level.ROG_velocity_start;

	IPrintLn( "Starting Velocity: " + level.ROG_velocity );
	wait 12;
	level.ROG_velocity *= .5;
	IPrintLn( "Slow Down: " + level.ROG_velocity );
	level waittill_any( "targets_cleared", "ammo_depleted" );
	level.ROG_velocity *= 10;
	IPrintLn( "Finishing Speed: " + level.ROG_velocity );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_setup_targets()
{
	level notify( "ROG_targeting" );

	level.ROG_targets = GetEntArray( "ROG_opfor_target", "targetname" );
	//IPrintLn( "Target count: " + level.ROG_targets.size );

	count = 0;
	foreach ( targ in level.ROG_targets )
	{
		count++;
		Target_Set( targ );
		Target_SetAttackMode( targ, "top" );
		targ ROG_set_target_color();
		Target_HideFromPlayer( targ, level.player );

		if( 0 == mod( count, 4 ) )
		{
			// was getting server overflow without this wait
			wait ( 0.05 );
		}
	}

	level thread ROG_target_reveal_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_target_reveal_logic()
{
	count = 0;
	wait_time = GetDvarFloat( "dev_ROG_target_reveal_spacing" );
	switch( level.ROG_current_layout )
	{
		case "learn":
		case "practice":
			foreach ( targ in level.ROG_targets )
			{
				count++;
				Target_ShowToPlayer( targ, level.player );
				targ.showing = true;

				if ( 0.04 < wait_time )
				{
					level.player PlaySound( "scn_loki_rog_target_on" );
					wait( wait_time );
				}
				else
				{
					if( 0 == mod( count, 4 ) )
					{
						level.player PlaySound( "scn_loki_rog_target_on" );
						wait ( 0.05 );
					}
				}
			}
			break;

		case "execute":
			foreach ( targ in level.ROG_targets )
			{
				if ( targ.script_team == "allies" )
				{
					count++;
					Target_ShowToPlayer( targ, level.player );
					targ.showing = true;

					if ( 0.04 < wait_time )
					{
						level.player PlaySound( "scn_loki_rog_target_on" );
						wait( wait_time );
					}
					else
					{
						if( 0 == mod( count, 4 ) )
						{
							level.player PlaySound( "scn_loki_rog_target_on" );
							wait ( 0.05 );
						}
					}
				}
			}
			break;

	}
	level thread ROG_target_move_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_target_move_logic()
{
	delta = GetDvarFloat( "dev_ROG_target_reveal_spacing" );

	foreach( group in level.ROG_moving_targets[ level.ROG_current_layout ] )
	{
		Assert( IsDefined( group[ 0 ] ) );
		index	= group[ 0 ].script_index;
		spacing = 0;

		mover = GetEnt( "vehicle_target_mover_" + level.ROG_current_layout + "_" + index, "script_noteworthy" );
		reveal_time = mover.script_index;

		foreach( target in group )
		{
			target LinkTo( mover );
			if ( !IsDefined( target.showing ) )
			{
				level delayThread( reveal_time + spacing, ::ROG_reveal_individual_target, target );
				spacing += delta;
			}
		}
		mover delayThread( reveal_time, ::ROG_move_target_group, index );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_reveal_individual_target( targ )
{
	Target_SetOffscreenShader( targ, "ac130_hud_target_offscreen" );
	Target_ShowToPlayer( targ, level.player );
	level.player PlaySound( "scn_loki_rog_target_on" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_move_target_group( index )
{
	// we should have a retreat path for after the first ROGs have starting hitting.

	node_start_target = GetVehicleNode ( "node_target_mover_" + level.ROG_current_layout + "_" + index, "targetname" );
	self AttachPath ( node_start_target );
	self gopath();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_targeting_logic()
{
	level endon( "ROG_new_sequence" );

	can_fire = true;
	level thread ROG_move_AOE_target();
	
	while ( 1 )
	{
		if ( level.ROG_single_curr_index == level.ROG_num_rods )
		{
			level.player notify( "ammo_depleted" );
			break;
		}
		
		eye_pos = level.player GetEye();
		player_angles = level.player GetPlayerAngles();
		combined_angles = CombineAngles( level.player_mover.angles, player_angles );
		forward = AnglesToForward( combined_angles );
		
		if ( level.player AttackButtonPressed() )
		{
			if ( can_fire && level.can_fire )
			{
				can_fire = false;
				
				// Need to get a trace from the player's eye to the position on the ground where the reticle is pointed
				trace = BulletTrace( eye_pos, ( eye_pos + ( forward * 250000 ) ), false, level.mover_model, false );

				level.player PlaySound( "scn_loki_rog_press_trigger" );
				level.player notify( "ROG_fired" );
				level thread ROG_fire_single( trace["position"], true );
			}
		}
		else
		{
			can_fire = true;
		}
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*ROG_targeting_logic()
{
	player_fov = int( getdvar( "cg_fov" ) );
	target_locked = -1;
	
	ROG_single_num_fired = 0;
	
	while ( 1 )
	{
		for ( i = 0; i < level.ROG_targets.size; i++ )
		{
			if ( target_locked >= 0 )
			{
				if ( i != target_locked )
				{
					continue;
				}
			}
			
			targ = level.ROG_targets[i];
			loop_break = false;
			
			if ( IsDefined( targ ) )
			{
				switch ( targ.icon_state )
				{
					case "marked":
						if ( i == target_locked )
						{
							target_locked = -1;
						}
						
						break;
						
					case "lock":
						if ( level.player WorldPointInReticle_Circle( targ.origin, player_fov, 16 ) )
						{
							if ( ( level.ROG_mode == "single_fire" && level.player AttackButtonPressed() ) ||
							     ( level.ROG_mode == "hellfire" && level.player FragButtonPressed() ) ||
							     ( level.ROG_mode == "paint" ) )
							{
								Target_SetShader( targ, "veh_hud_target_marked" );
								targ.icon_state = "marked";
								
								if ( level.ROG_mode == "single_fire" )
								{
									thread ROG_fire_single( targ.origin, true );
								}
								else
								{
									ROG_single_separate_anim();
								}
								
								ROG_single_num_fired++;
								
								if ( ROG_single_num_fired == 8 )
								{
									if ( level.ROG_mode == "hellfire" || level.ROG_mode == "paint" )
									{
										display_hint( "hint_launch_all_rods" );
											
										while ( !( level.player AttackButtonPressed() ) )
										{
											wait level.TIMESTEP;
										}
										
										thread ROG_fire_all();
									}
									else
									{
										wait 0.5;
									}
									
									level notify( "ROG_end" );
									return;
								}
									
								wait 0.2;
							}
						}
						else
						{
							//Target_SetShader( targ, "veh_hud_target" );
							targ ROG_set_target_color();
							targ.icon_state = "idle";
							
							target_locked = -1;
						}
						break;
						
					case "idle":
						//if ( Target_IsInRect( targ, level.player, player_fov, 32, 32 ) )
						if ( target_locked < 0 )
						{
							if ( level.player WorldPointInReticle_Circle( targ.origin, player_fov, 16 ) )
							{
								Target_SetShader( targ, "veh_hud_target_locking" );
								targ.icon_state = "lock";
								
								target_locked = i;
							}
						}
						break;
				}
			}
			
			if ( target_locked >= 0 )
				break;
		}
		
		wait level.TIMESTEP;
	}
}*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ROG_single_separate_anim( anime )
{
	level.mover_model SetAnim( level.scr_anim[ "ROG" ][ anime ], 1.0, 0.0, 1.0 );
	
	//PlayFXOnTag( level._effect[ "ROG_single_geotrail" ], level.ROG_single_rods[index], "tag_origin" );
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	
	level.ROG_single_curr_index++;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_fire_single( targ, play_separate_anim, index )
{
	if ( !IsDefined( index ) )
	{
		index = level.ROG_single_order[level.ROG_single_curr_index];
	}

	level thread ROG_rechamger_logic();

	ROG_single = level.ROG_single_rods[index];
	ROG_single Show();

	level.ROG_single_num_active++;
	
	/* 	tagBR< rant > BEGIN ---
		Here we are going to play an animation on the rod before script takes control and moves it to the ground. It would be nice
		if you could just play the anim, unlink it, and then move it via script by carrying on the velocity at which it was moving
		in the anim. This doesn't work quite right, because there is (I believe) a one-frame delay when you unlink() an object
		before applying a translation in script works. A second option is to spawn an entirely different rod, hide the original,
		and then set its position/angles to the animated one's position/angles every frame, thereby not needing to unlink() and
		hence, no glitch. Doesn't work because there is a delay when setting this data (thanks to the client/server architecture).
		A thrid option is to spawn an entirely different rod, hide it, and then set its position/angles to the animated one's
		position/angles when the anim is done playing, and then move that object in script as you wouldn't need to unlink() and
		hence no delay. Sounds good on paper. Doesn't work. Attempting to get any new rod to sync up exactly with the animated one
		has been futile. The code has been left in, however, commented out, in case a new victim would like to walk this path. To
		do so, comment out the block of code: // Be the victim #1, and uncomment block of code: // Be the victim #2
		tagBR< rant > END ---
	 */
	new_ROG = spawn_anim_model( "loki_rog_single", ROG_single.origin );
	new_ROG.angles = ROG_single.angles;
	
	ROG_single_velocity = ( 0, 0, 0 );
	prev_org = new_ROG.origin;
	
	new_ROG Hide();

	ROG_single delayCall( 0.8, ::PlaySound, "scn_loki_rog_missile_fire" );

	//play_separate_anim = false;
	if ( play_separate_anim )
	{
		anime = "loki_rog_seperate_0" + ( index + 1 );

		ROG_single_separate_anim( anime );
		
		// While the separate anim is playing out...
		while ( !( level.mover_model check_anim_time( "ROG", anime, 1.0 ) ) )
		{
			// ...move the new ROG to the position of the one that is animating
			new_ROG.origin = ROG_single.origin;
			new_ROG.angles = ROG_single.angles;
			
			// ...calculate the velocity
			ROG_single_velocity = ( new_ROG.origin - prev_org ) / level.TIMESTEP;
			prev_org = new_ROG.origin;
			
			wait level.TIMESTEP;
		}
	}
	
	// Be the victim #1
	new_ROG Delete();
	ROG_single Unlink();

	// Be the victim #2
	// Now the anim is done playing, set pos/angles, delete the linked one, and make the new one our "real" one
	//new_ROG.origin = ROG_single.origin;
	//new_ROG.angles = ROG_single.angles;
	//ROG_single Delete();
	//level.ROG_single_rods[index] = new_ROG;
	//ROG_single = level.ROG_single_rods[index];
	//ROG_single Show();

	// tagBR< note >: Play an FX here to mask the anim/unlink glitch noted above
	PlayFXOnTag( level._effect[ "ROG_single_geotrail" ], level.ROG_single_rods[index], "tag_origin" );
	level.player PlayRumbleOnEntity( "grenade_rumble" );

	// Initial distance to target
	dist_sq_init = LengthSquared( targ - ROG_single.origin );
	
	// Sanity check (we divide by this value later)
	AssertEx( dist_sq_init > 0, "This most likely means the bullet trace has collided with one of the rods...no fix currently" );
	
	explosion_dist_check = ( level.ROG_single_velocity_max * level.ROG_single_velocity_max * level.TIMESTEP * level.TIMESTEP ) + 100;
	
	velocity_x = abs( ROG_single_velocity[0] );
	velocity_y = abs( ROG_single_velocity[1] );
	velocity_z = abs( ROG_single_velocity[2] );

	ROG_smart_target_logic( targ, index, ROG_single_velocity[2] );

	start_time = GetTime();
	while ( 1 )
	{
		// v = v0 + at
		velocity_x += ( level.ROG_single_acceleration * level.TIMESTEP );
		velocity_y += ( level.ROG_single_acceleration * level.TIMESTEP );
		velocity_z += ( level.ROG_single_acceleration * level.TIMESTEP );
		
		// Clamp downward velocity
		if ( velocity_z > level.ROG_single_velocity_max)
		{
			velocity_z = level.ROG_single_velocity_max;
		}
		
		// We want to ramp up lateral acceleration as a ratio on initial and curr distance to target
		dist_sq = LengthSquared( targ - ROG_single.origin );
		ratio = 1.0 - ( dist_sq / dist_sq_init );
		
		dir = VectorNormalize( targ - ROG_single.origin );
		dir = ( dir[0] * ratio, dir[1] * ratio, dir[2] );
		
		offset_x = ( dir[0] * velocity_x * level.TIMESTEP );
		offset_y = ( dir[1] * velocity_y * level.TIMESTEP );
		offset_z = ( dir[2] * velocity_z * level.TIMESTEP );
		offset = ( offset_x, offset_y, offset_z );
		
		ROG_single.origin += offset;
		
		// Ground explosion
		if ( LengthSquared( targ - ROG_single.origin ) < explosion_dist_check )
		{
			PlayFX( level._effect[ "ROG_single_explosion" ], ROG_single.origin );

			ROG_single_do_explosion_dmg( targ );
			ROG_single thread destruction_explosion();
			if ( "execute" == level.ROG_current_layout )
			{
				level thread ROG_do_AOE_duration_damage( targ );
			}
			level.ROG_last_blast_pos = ROG_single.origin;
			level.ROG_single_num_active--;

			break;
		}
		
		wait level.TIMESTEP;
	}
	
	ROG_single Delete();
	level.ROG_single_rods[index] = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_smart_target_logic( targ, index, rog_single_velocity )
{
	ROG_single = level.ROG_single_rods[index];

	//t_start = GetAnimLength( level.scr_anim[ "ROG" ][ "loki_rog_seperate_0" + ( index + 1 ) ] );
	dist = Distance( targ, ROG_single.origin );
	//ROG_single_velocity = level.ROG_velocity + level.ROG_single_v0;
	vel_t_max = ( level.ROG_single_velocity_max - rog_single_velocity ) / level.ROG_single_acceleration;
	dist_t_max_vel = ( 0.5 * level.ROG_single_acceleration * vel_t_max * vel_t_max ) + ( ROG_single_velocity * vel_t_max );
	if( dist > dist_t_max_vel )
	{
		t_total = vel_t_max + ( ( dist - dist_t_max_vel ) / level.ROG_single_velocity_max );
	}
	else
	{
		top = sqrt( squared( rog_single_velocity ) - ( 2 * level.ROG_single_acceleration * dist * -1 ) );
		top = ( -1 * rog_single_velocity ) + top;
		t_total = top / level.ROG_single_acceleration;
	}
	//t_total += t_start;
	level thread ROG_aoe_logic( index, targ + ( 0, 0, 64 ), t_total );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_single_do_explosion_dmg( exp_org )
{
	for ( i = 0; i < level.ROG_targets.size; i++ )
	{
		len = Length( level.ROG_targets[i].origin - exp_org );

		if ( len < level.ROG_explosion_radius )
		{
			if ( Target_IsTarget( level.ROG_targets[i] ) )
			{
				Target_Remove( level.ROG_targets[i] );

				if ( level.ROG_targets[i].script_team == "allies" )
				{
					level.ROG_targets_friendlies--;
					level.player notify( "ally_hit" );
				}
				else
				{
					level.ROG_targets_enemies--;
					level.player notify( "enemy_hit" );
					if( level.ROG_targets_enemies == 0 )
					{
						level notify( "targets_cleared" );
					}
				}

				level.ROG_targets[i].mark_for_delete = true;
			}
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_rechamger_logic()
{
	level.can_fire = false;
	wait( GetDvarFloat( "dev_ROG_rechamber_time" ) );
	if ( level.player_mover.origin[2] > -100000 && level.ROG_single_curr_index != level.ROG_num_rods )
	{
		level.can_fire = true;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_mechanics()
{
	// tagBR< note >: Uncomment this line to make the ROG not descend
	//level endon( "ROG_targeting" );
	level endon( "ROG_end" );

	level thread ROG_ending_path();

	// Teleport ROG back to correct start point
	level.ROG_start = GetEnt( "ROG_start_" + level.ROG_current_layout + "_" + level.ROG_current_section, "script_noteworthy" );
	level.player_mover.origin = level.ROG_start.origin;
	level.player_mover.angles = level.ROG_start.angles;

	rumble_ent = get_rumble_ent();
	rumble_ent.intensity = .3;

	level thread ROG_special_sequence_mechanics();

	level notify( "ROG_new_sequence" );
	flag_clear( "setup_layout_done" );
	
	wait level.TIMESTEP;

	while ( 1 )
	{
		level.player_mover.origin += ( 0, 0, ( -1 * level.ROG_velocity * level.TIMESTEP ) );
		
		if ( level.player_mover.origin[2] < -100000 )
		{
			flag_set( "final_decent_active" );

			level.can_fire = false;
			while ( level.ROG_single_num_active )
			{
				wait level.TIMESTEP;
			}
			break;
		}
		
		if ( level.ROG_single_curr_index == level.ROG_num_rods && !level.ROG_single_num_active )
		{
			level notify( "ammo_depleted" );
		}

		wait level.TIMESTEP;
	}

	flag_waitopen( "final_decent_active" );

	fade_in_time = 0.5;
	add_wait_time = 0.05;
	fade_out_time = 0.0;

	level thread black_fade( fade_in_time, add_wait_time, fade_out_time );
	wait fade_in_time;

	ROG_check_progress();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_check_progress()
{
	success = false;

	// need to check targets now
	if( level.ROG_targets_enemies <= 0 )
	{
		success = true;
		level.player notify( "done" );
	}
	else
	{
		ammo_count = 0;
		foreach( rod in level.ROG_single_rods )
		{
			if ( IsDefined( rod ) )
			{
				ammo_count++;
			}
		}
		if ( ammo_count == level.ROG_num_rods )
		{
			flag_clear( "dont_show_pull_trigger_hint" );
		}
	}

	if( success )
	{
		if ( !flag( "layout_learn_done" ) )
		{
			flag_set( "layout_learn_done" );
		}
		else if ( !flag( "layout_practice_done" ) )
		{
			flag_set( "layout_practice_done" );
		}
		else if ( !flag( "layout_execute_done" ) )
		{
			flag_set( "layout_execute_done" );
		}

		flag_wait( "setup_layout_done" );
	}

	level notify( "ROG_end_of_sequence" );
	level notify( "ROG_new_sequence" );
	thread ROG_sequence_new_pass( success );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_ending_path()
{
	flag_wait( "final_decent_active" );

	// need to unhide models
	level.mover_model Show();
	foreach( ROG in level.ROG_single_rods )
	{
		ROG Show();
	}

	time = GetDvarFloat( "dev_dollyzoom_time_start_zoom_length_" + level.ROG_current_layout );

	// now need to move player to ROG bundle
	level.player_rig MoveTo( level.player_mover.origin, time, 0.25, 0.7 );

	// lock camera
	level.player LerpViewAngleClamp( time , 0, 0, 10, 10, 20, 0 );
	wait( time );
	// need to pitch camear up a bit
	//level.player_rig RotateYaw( -20, time );

	// reattach
	level.player_rig LinkTo( level.mover_model );

	//level.ROG_ref_ent RotatePitch( -20, 1.0 );

	// final animation
	delta = ( 0, 0, (-1 ) * GetDvarFloat( "dev_ROG_final_decent_delta" ) );
	time = GetDvarFloat( "dev_ROG_final_decent_time" );
	level.player_mover MoveTo( level.player_mover.origin + delta, time );

	// there is a half second fade in
	level delayThread( time - 0.5, ::flag_clear, "final_decent_active" );

	// should store last rog hit so we have our camera look at that blast
	if ( IsDefined( level.ROG_last_blast_pos ) )
	{
		ref_ent_angles = level.ROG_ref_ent.angles;
		//dir = VectorNormalize( level.ROG_last_blast_pos - level.player.origin );
		dir = level.ROG_last_blast_pos - level.player.origin;
		angles = VectorToAngles( dir );
		level.player_mover RotateTo( angles, time / 2.0 );
		level.ROG_ref_ent RotateTo( angles, time / 2.0 );

		wait( time / 2.0 );

		dir = level.ROG_last_blast_pos - level.player.origin;
		angles = VectorToAngles( dir );
		level.player_mover RotateTo( angles, time / 2.0 );
		level.ROG_ref_ent RotateTo( angles, time / 2.0 );

		wait( time / 2.0 );
		level.ROG_ref_ent.angles = ref_ent_angles;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_set_target_color()
{
	if ( ( isDefined( self.script_team ) && self.script_team == "allies" ) || ( isDefined( self.team ) && self.team == "allies" ) )
	{
		if ( IsDefined( self.script_noteworthy ) )
		{
			switch( self.script_noteworthy )
			{
				case "dots":
					index = RandomIntRange( 0, 3 );
					Target_SetShader( self, "hud_rog_target_dot_group_" + index + "_g" );
					break;
	
				case "large_target":
					Target_SetShader( self, "hud_rog_target_g" );
					break;
	
				case "vehicle":
					Target_SetShader( self, "hud_rog_target_vehicle_a_g" );
					break;
	
				case "building":
					Target_SetShader( self, "hud_rog_target_building_g" );
					break;
	
				case "jet":
					Target_SetShader( self, "hud_rog_target_vehicle_b_g" );
					break;
	
				default:
					Target_SetShader( self, "hud_rog_target_g" );
			}
		}
		else
		{
			Target_SetShader( self, "hud_rog_target_g" );
		}
		//Target_SetColor( self, ( 0, 1, 0 ) );
	}
	else
	{
		if ( IsDefined( self.script_noteworthy ) )
		{
			switch( self.script_noteworthy )
			{
				case "dots":
					index = RandomIntRange( 0, 3 );
					Target_SetShader( self, "hud_rog_target_dot_group_" + index + "_r" );
					break;
	
				case "large_target":
					Target_SetShader( self, "hud_rog_target_r" );
					break;
	
				case "vehicle":
					Target_SetShader( self, "hud_rog_target_vehicle_a_r" );
					break;
	
				case "building":
					Target_SetShader( self, "hud_rog_target_building_r" );
					break;
	
				case "jet":
					Target_SetShader( self, "hud_rog_target_vehicle_b_r" );
					break;
	
				default:
					Target_SetShader( self, "hud_rog_target_r" );
			}
		}
		else
		{
			Target_SetShader( self, "hud_rog_target_r" );
		}
		//Target_SetColor( self, ( 0, 1, 0 ) );
	}

	Target_Flush( self );
	Target_ShowToPlayer( self, level.player );
}


/*
=============
///ScriptDocBegin
"Name: setup_player_for_animated_sequence( <do_player_link>, <link_clamp_angle>, <rig_origin>, <rig_angles>, <do_player_restrictions>, <do_player_restrictions_by_notify> )"
"Summary: Automate the process of spawning a rig, mover, linking player for an animated sequence."
"Module: Player"
"OptionalArg: <do_player_link>: defaults to true"
"OptionalArg: <link_clamp_angle>: defaults to 60"
"OptionalArg: <rig_origin>: defaults to player's origin"
"OptionalArg: <rig_angles>: defaults to player's angles"
"OptionalArg: <do_player_restrictions>: defaults to true"
"OptionalArg: <do_player_restrictions_by_notify>: defaults to false"
"Example: maps\black_ice_util::setup_player_for_animated_sequence()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
setup_player_for_animated_sequence( do_player_link, link_clamp_angle, rig_origin, rig_angles, do_player_restrictions, do_player_restrictions_by_notify, mover_model )
{
	// Setup default variables
	if ( !IsDefined( do_player_link) )
	{
		do_player_link = true;
	}
	
	if ( do_player_link )
	{
		if ( !IsDefined( link_clamp_angle ) )
		{
			link_clamp_angle = 60;
		}
	}
	
	if ( !IsDefined( rig_origin ) )
	{
		rig_origin = level.player.origin;
	}
		
	if ( !IsDefined( rig_angles ) )
	{
		rig_angles = level.player.angles;
	}
	
	if ( !IsDefined( do_player_restrictions ) )
	{
		do_player_restrictions = true;
	}

	// Setup player rig for anims
	level.player_rig.origin = rig_origin;
	level.player_rig.angles = rig_angles;
	//player_rig hide();

	if ( IsDefined( mover_model ) )
	{
		level.mover_model.origin = rig_origin;
		level.mover_model.angles = rig_angles;
		level.player_rig LinkTo( level.mover_model );
		
		level.player_mover.origin = rig_origin;
		level.player_mover.angles = rig_angles;
		level.mover_model LinkTo( level.player_mover );
	}
	else
	{
		level.player_mover.origin = rig_origin;
		level.player_mover.angles = rig_angles;
		level.player_rig LinkTo( level.player_mover );
	}

	level.player_rig RotatePitch( -20, 0.05 );
	wait( 0.05 );

	if ( do_player_link )
	{
		level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, 0, 0, 45, 0, true );
	}
}


/*
=============
///ScriptDocBegin
"Name: player_animated_sequence_cleanup()"
"Summary: Re-enables all the previous restrictions after a player goes through an animated sequence."
"Module: Player"
"Example: maps\black_ice_util::player_animated_sequence_cleanup()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
player_animated_sequence_cleanup()
{
	if ( !IsDefined( level.player.early_weapon_enabled ) || !level.player.early_weapon_enabled )
	{
		level.player.early_weapon_enabled = undefined;
		
		level.player.disableReload = false;
		level.player EnableWeapons();
		level.player EnableOffhandWeapons();
		level.player EnableWeaponSwitch();
	}

	level.player AllowCrouch( true );
	level.player AllowJump( true );
	//level.player AllowLean( true );
	level.player AllowMelee( true );
	level.player AllowProne( true );
	level.player AllowSprint( true );
	
	level.player Unlink();
	
	if ( IsDefined( level.player_mover ) )
	{
		level.player_mover Delete();
	}
	
	if ( IsDefined( level.player_rig ) )
	{
		level.player_rig Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_aoe_logic( index, pos, time )
{
	// move to location
	delta = pos - level.rog_blast_radius_outer[ index ].origin;
	level.rog_blast_radius_outer[ index ].origin += delta;
	level.rog_blast_radius_inner[ index ].origin += delta + ( 0, 0, -400 );

	wait( 0.05 );

	level.rog_blast_radius_outer[ index ] Solid();
	level.rog_blast_radius_outer[ index ] Show();
	level.rog_blast_radius_inner[ index ] Solid();
	level.rog_blast_radius_inner[ index ] Show();

	// animate
	level.rog_blast_radius_inner[ index ] MoveZ( 400, time, 0.75 * time );
	//anim_set_rate();

	wait( time );

	level.rog_blast_radius_outer[ index ] NotSolid();
	level.rog_blast_radius_outer[ index ] Hide();
	level.rog_blast_radius_inner[ index ] NotSolid();
	level.rog_blast_radius_inner[ index ] Hide();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_move_AOE_target()
{
	level endon( "final_decent_active" );

	level thread ROG_AOE_reticle_visibility_logic();

	while( true )
	{
		eye_pos = level.player GetEye();
		player_angles = level.player GetPlayerAngles();
		combined_angles = CombineAngles( level.player_mover.angles, player_angles );
		forward = AnglesToForward( combined_angles );

		trace = BulletTrace( eye_pos, ( eye_pos + ( forward * 250000 ) ), false, level.mover_model, false );
		level.ROG_AOE_reticle.origin = trace[ "position" ] + ( 0, 0, 1200 );
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_AOE_reticle_visibility_logic()
{
	flag_wait( "starting_anim_done" );

	level.ROG_AOE_reticle Show();
	level.ROG_AOE_reticle Solid();

	flag_wait( "final_decent_active" );

	level.ROG_AOE_reticle Hide();
	level.ROG_AOE_reticle NotSolid();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_special_sequence_mechanics()
{
	switch( level.ROG_current_layout )
	{
		case "learn":
			level thread ROG_camera_framing_of_sequence( GetDvarFloat( "dev_dollyzoom_fov_start_learn" ), GetDvarFloat( "dev_dollyzoom_time_start_zoom_length_learn" ) );
			break;
		case "practice":
			level thread ROG_camera_framing_of_sequence( GetDvarFloat( "dev_dollyzoom_fov_start_practice" ), GetDvarFloat( "dev_dollyzoom_time_start_zoom_length_practice" ) );
			break;
		case "execute":
			level thread ROG_camera_framing_of_sequence( GetDvarFloat( "dev_dollyzoom_fov_start_execute" ), GetDvarFloat( "dev_dollyzoom_time_start_zoom_length_execute" ) );
			break;
	}

	if ( !flag( "dont_show_pull_trigger_hint" ) )
	{
		level delayThread( 2.5, ::display_hint, "hint_launch_single_rod" );
	}
	if ( !flag( "dont_show_zoom_hint" ) )
	{
		level delayThread( 2.5, ::display_hint, "hint_zoom" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_camera_framing_of_sequence( starting_fov, setup_time )
{
	level notify( "ROG_zoomed_in_sequence" );
	level endon( "ROG_zoomed_in_sequence" );

	flag_wait( "starting_anim_done" );

	//level.player thread ROG_dolly_zoom_logic( starting_fov, setup_time );
	level.player thread ROG_attach_to_firing_position();
	delaythread( 0.5, ::flag_set, "force_low_camera_shake" );

	wait( setup_time );

	level.can_fire = true;

	level waittill( "ROG_new_sequence" );
	flag_clear( "force_low_camera_shake" );
	level.player EnableSlowAim( 0.15, 0.15 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_dolly_zoom_logic( fov_0, setup_time )
{
	self thread ROG_dolly_zoom_cleanup( setup_time );
	level endon( "ROG_new_sequence" );
	level endon( "targets_cleared" );
	level endon( "ammo_depleted" );

	current_fov		= 0;
	frame_count		= 0;
	ads_frame_count = 0;
	delta			= GetDvarFloat( "dev_dollyzoom_fov_end" ) - fov_0;
	rate			= delta / ( GetDvarFloat( "dev_dollyzoom_time_delta" ) * 20 );

	// setup
	level.player LerpFOV( fov_0, setup_time );

	wait( setup_time );
	//IPrintLn( "cg_fov = " + GetDvarFloat( "cg_fov" ) );

	// initial Dolly Zoom
	self LerpFOV( GetDvarFloat( "dev_dollyzoom_fov_end" ), GetDvarFloat( "dev_dollyzoom_time_delta" ) );

	while( true )
	{
		if ( self PlayerAds() > 0 )
		{
			// need to take us out of our lerping state, and set our FOV correctly
			ads_frame_count = 1;
			current_fov = ( rate * ( ads_frame_count + frame_count ) ) + fov_0;
			self LerpFOV( current_fov, 0.05 );
			wait( 0.05 );

			//IPrintLn( "cg_fov = " + GetDvarFloat( "cg_fov" ) );

			while( self PlayerAds() > 0 )
			{
				ads_frame_count++;
				wait( 0.05 );
			}

			// return our FOV to what it should have been if we were continually Dolly Zooming
			ads_frame_count++;
			current_fov = ( rate * ( ads_frame_count + frame_count ) ) + fov_0;
			self LerpFOV( current_fov, 0.05 );
			wait( 0.05 );

			// reset Dolly Zoom
			frame_count += ads_frame_count;
			self LerpFOV( GetDvarFloat( "dev_dollyzoom_fov_end" ), GetDvarFloat( "dev_dollyzoom_time_delta" ) - ( frame_count * 0.05 ) );
			continue;
		}

		//current_fov = fov_0 + ( rate * frame_count );
		//IPrintLn( "cg_fov = " + GetDvarFloat( "cg_fov" ) + ". It should be " + current_fov );

		frame_count++;
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_dolly_zoom_cleanup( setup_time )
{
	wait( setup_time );
	level waittill_any( "ROG_new_sequence", "targets_cleared", "ammo_depleted" );
	self LerpFOV( GetDvarFloat( "dev_dollyzoom_fov_end" ), 1.0 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_attach_to_firing_position()
{
	level.player_rig Unlink();

	delta = -1.0 * GetDvarFloat( "dev_camera_delta_from_" + level.ROG_current_layout + "_start" );
	level.player_rig MoveTo( level.ROG_start.origin + ( 0, 0, delta ), GetDvarFloat( "dev_dollyzoom_time_start_zoom_length_" + level.ROG_current_layout ), 0.25, 0.7 );

	level.mover_model Hide();
	foreach( rog in level.ROG_single_rods )
	{
		rog Hide();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

destruction_explosion()
{
	impact_point = self.origin;
	
	crater_fx = Spawn( "script_model", impact_point );
	crater_fx.angles = ( -90, 0, 0 );
	crater_fx SetModel( "tag_origin" );
	
	wait( 1.0 );

	PlayFXOnTag( getfx( "explosion_01" ), crater_fx, "tag_origin" );
	PlayFXOnTag( getfx( "smoke_01" ), crater_fx, "tag_origin" );
	
	wait( 1.0 );
	
	PlayFXOnTag( getfx( "shockwave_02" ), crater_fx, "tag_origin" );
	
	level.crater_array = add_to_array( level.crater_array, crater_fx );
	
	crater = Spawn( "script_model", impact_point );
	crater SetModel( "ac_prs_ter_crater_a_1" );
	level.crater_array = add_to_array( level.crater_array, crater );
	crater PlaySound( "scn_loki_rog_explode" );

//	PlayFXOnTag( getfx( "shockwave_02" ), level.main_fx_node_unrotated, "tag_origin" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

destruction_reset()
{
	foreach( crater in level.crater_array )
	{
		if( IsDefined( crater ) )
		{
			crater delete();
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_feedback_logic()
{
	self thread add_dialogue_line( "Keegan", "Priority one, we need to wipe out that sat farm.", "green" );
	wait( 1.2 );
	self thread add_dialogue_line( "Keegan", "I'm taking control of the camera. You just worry about those targets.", "green" );

	while( "learn" == level.ROG_current_layout )
	{
		msg = level.player waittill_any_return( "ROG_fired", "enemy_hit", "ally_hit", "altimeter_warning", "ammo_depleted", "done" );
		ROG_play_feedback( msg );
		if( msg == "done" )
		{
			break;
		}
	}

	self thread add_dialogue_line( "Keegan", "Stay on point. We got another war zone that needs some cleaning up.", "green" );
	wait( 2.0 );
	self thread add_dialogue_line( "Keegan", "You got control of the zoom now. Have at it.", "green" );

	while( "practice" == level.ROG_current_layout )
	{
		msg = level.player waittill_any_return( "ROG_fired", "enemy_hit", "ally_hit", "altimeter_warning", "ammo_depleted", "done" );
		ROG_play_feedback( msg );
		if( msg == "done" )
		{
			break;
		}
	}

	self thread add_dialogue_line( "Keegan", "Good shooting, All tangos down. Let's see what we can do for Ghost team.", "green" );

	while( "execute" == level.ROG_current_layout )
	{
		msg = level.player waittill_any_return( "ROG_fired", "enemy_hit", "ally_hit", "altimeter_warning", "ammo_depleted", "done" );
		ROG_play_feedback( msg );
		if( msg == "done" )
		{
			break;
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_play_feedback( msg )
{
	feedback_played = false;

	switch( msg )
	{
		case "ROG_fired":
			if ( RandomFloat( 1.0 ) > 0.5 )
			{
				random_lines = make_array( "Kinetic strike inbound.", "Care package incoming.", "Bombs away." );
				self thread add_dialogue_line( "Keegan", random_lines[ RandomIntRange( 0, random_lines.size ) ], "green" );
				feedback_played = true;
			}
			break;
		case "enemy_hit":
			if ( RandomFloat( 1.0 ) > 0.5 )
			{
				random_lines = make_array( "That's a good hit.", "More just like that.", "Nice." );
				self thread add_dialogue_line( "Keegan", random_lines[ RandomIntRange( 0, random_lines.size ) ], "green" );
				feedback_played = true;
			}
			break;
		case "ally_hit":
			random_lines = make_array( "Check your fire. Those are friendlies.", "You're getting sloppy.", "Wrong team." );
			self thread add_dialogue_line( "Keegan", random_lines[ RandomIntRange( 0, random_lines.size ) ], "green" );
			feedback_played = true;
			break;
		case "altimeter_warning":
			self thread add_dialogue_line( "Keegan", "Almost done with our descent.", "green" );
			feedback_played = true;
			break;
		case "ammo_depleted":
			self thread add_dialogue_line( "Keegan", "Ammo depleted.", "green" );
			feedback_played = true;
			break;
		case "done":
			self thread add_dialogue_line( "Keegan", "Area clear.", "green" );
			feedback_played = true;
			break;
	}
	if ( feedback_played )
	{
		wait( RandomFloatRange( 1.2, 3.0 ) );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debug_stick_usuage_text()
{
	level notify( "debug_text" );
	level endon( "debug_text" );

	prev = level._debug_stick_indicator;

	while( true )
	{
		if ( prev != level._debug_stick_indicator )
		{
			IPrintLn( "Using " + level._debug_stick_indicator + " stick." );
			prev = level._debug_stick_indicator;
		}

		wait ( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debug_stick_data()
{
	left_movement = self GetNormalizedMovement();
	right_movement = self GetNormalizedCameraMovement();
	left_largest = 0;
	right_largetst = 0;
	left_engaged = false;
	right_engaged = false;

	if( abs( left_movement[ 0 ] ) > 0.3 || abs( left_movement[ 1 ] ) > 0.3 )
	{
		left_engaged = true;
		if ( abs( left_movement[ 0 ] ) > abs( left_movement[ 1 ] ) )
		{
			left_largest = 0;
		}
		else
		{
			left_largest = 1;
		}
	}

	if( abs( right_movement[ 0 ] ) > 0.3 || abs( right_movement[ 1 ] ) > 0.3 )
	{
		right_engaged = true;
		if ( abs( right_movement[ 0 ] ) > abs( right_movement[ 1 ] ) )
		{
			right_largest = 0;
		}
		else
		{
			right_largest = 1;
		}
	}

	if( left_engaged && right_engaged )
	{
		if ( abs( left_movement[ left_largest ] ) > abs( right_movement[ 0 ] ) )
		{
			level._debug_stick_indicator = "left";
			return left_movement;
		}
		else
		{
			level._debug_stick_indicator = "right";
			return right_movement;
		}
	}
	if( left_engaged )
	{
		level._debug_stick_indicator = "left";
		return left_movement;
	}
	if( right_engaged )
	{
		level._debug_stick_indicator = "right";
		return right_movement;
	}

	return left_movement;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_move_to_checkpoint_start( node_targetname )
{
	// Move player to start
	node = GetEnt( node_targetname, "targetname" );
	level.player setOrigin( node.origin );
	level.player setPlayerAngles( node.angles );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies_move_to_checkpoint_start( checkpoint, reset )
{
	// Move allies to start points
	for ( i = 0; i < 3; i++ )
	{
		struct_targetname = checkpoint + "_ally_" + i;
		struct			  = GetStruct( struct_targetname, "targetname" );
		level.allies[ i ] ForceTeleport( struct.origin, struct.angles );
		if( IsDefined( reset ) )
		{
			level.allies[ i ] clear_force_color();
			level.allies[ i ] SetGoalPos( struct.origin );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_allies()
{
	level.allies					  = [];
	level.allies[ level.allies.size ] = spawn_ally( "ally_0" );
	level.allies[ level.allies.size ] = spawn_ally( "ally_1" );
	level.allies[ level.allies.size ] = spawn_ally( "ally_2" );
	
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_ally( allyName, overrideSpawnPointName )
{
	spawnname = undefined;
	if ( !IsDefined( overrideSpawnPointName ) )
	{
		spawnname = level.start_point + "_" + allyName;
	}
	else
	{
		spawnname = overrideSpawnPointName + "_" + allyName;
	}

	ally = spawn_targetname_at_struct_targetname( allyName, spawnname );
	if ( !IsDefined( ally ) )
	{
		return undefined;
	}
	ally make_hero();
	if ( !IsDefined( ally.magic_bullet_shield ) )
	{
		ally magic_bullet_shield();
		ally.animname = allyName;
	}

	return ally;	
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawn_targetname_at_struct_targetname( tname, sname )
{
	spawner = GetEnt( tname, "targetname" );
	sstart	= getstruct( sname, "targetname" );
	if ( IsDefined( spawner ) && IsDefined( sstart ) )
	{
		//spawner add_spawn_function( maps\_space_ai::enable_space );
		spawned = spawner spawn_ai();

		if( !IsDefined( sstart.angles ) )
			sstart.angles = level.player.angles;
		spawned ForceTeleport( sstart.origin, sstart.angles );		

		return spawned;
	}
	if ( IsDefined( spawner ) )
	{
		//spawner add_spawn_function( maps\_space_ai::enable_space );
		spawned = spawner spawn_ai();
		IPrintLnBold( "Add a script struct called: " + sname + " to spawn him in the correct location." );
		spawned Teleport( level.player.origin, level.player.angles );
		return spawned;
		
	}
	IPrintLnBold( "failed to spawn " + tname + " at " + sname );

	return undefined;
}

set_flags_on_input()
{
	level endon("stop_listening_for_input");
	while( 1 )
	{
		/*
		analog_input = level.player GetNormalizedMovement();

		if((abs(analog_input[ 1 ]) - abs(analog_input[ 0 ])) > 0)
		{
			y_most = true;	
		}
		else
		{
			y_most = false;
		}
		if( analog_input[ 1 ] >= 0.15 && y_most)
		{
//			IPrintLn( "pressing right" + analog_input[ 1 ]);
			flag_clear( "left_pressed" );
			flag_clear( "forward_pressed" );
			flag_set( "right_pressed" );			
		}
		else if( analog_input[ 1 ] <= -0.15 && y_most)
		{
//			IPrintLn( "pressing left" + analog_input[ 1 ] );
			flag_clear( "right_pressed" );
			flag_clear( "forward_pressed" );
			flag_set( "left_pressed" );			
		}
		else if( analog_input[ 0 ] >= 0.15 )
		{
			//x_most by default now...
//			IPrintLn( "pressing forward" + analog_input[ 0 ]);
			flag_clear( "right_pressed" );
			flag_clear( "left_pressed" );
			flag_set( "forward_pressed" );			
		}
		else
		{
			flag_clear( "left_pressed" );
			flag_clear( "right_pressed" );
			flag_clear( "forward_pressed" );
		}
		*/
		if( level.player UseButtonPressed())// || level.player AttackButtonPressed())
		{
			//x_most by default now...
//			IPrintLn( "pressing attack");
			flag_set( "attack_pressed" );			
		}
		else
		{
			flag_clear( "attack_pressed" );
		}
		
		waitframe();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_do_AOE_duration_damage( exp_org )
{
	blast_radius = GetDvarFloat( "dev_ROG_blast_radius" );
	count = Int( GetDvarFloat( "dev_ROG_AOE_duration_time" ) / GetDvarFloat( "dev_ROG_AOE_duration_interval" ) );
	while( 0 < count )
	{
		for( i = 0; i < level.ROG_targets_flyers.size; i++ )
		{
			level.ROG_targets_flyers[ i ] = array_removeUndefined( level.ROG_targets_flyers[ i ] );
			for( j = 0; j < level.ROG_targets_flyers[ i ].size; j++ )
			{
				len = Length( level.ROG_targets_flyers[ i ][ j ].origin - exp_org );

				if ( len < blast_radius )
				{
					if ( Target_IsTarget( level.ROG_targets_flyers[ i ][ j ] ) )
					{
						Target_Remove( level.ROG_targets_flyers[ i ][ j ] );
		
						level.ROG_targets_enemies--;
						level.player notify( "enemy_hit" );
						if( level.ROG_targets_enemies == 0 )
						{
							level notify( "targets_cleared" );
						}

						index = find_target_index( level.ROG_targets_flyers[ i ][ j ] );
						level.ROG_targets[ index ].mark_for_delete = true;
						level.ROG_targets_flyers[ i ][ j ] = undefined;
					}
				}
			}
		}

		count--;
		wait( GetDvarFloat( "dev_ROG_AOE_duration_interval" ) );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

find_target_index( target )
{
	ret = 0;
	for( index = 0; index < level.ROG_targets.size; index++ )
	{
		if( target == level.ROG_targets[ index ] )
		{
			ret = index;
			break;
		}
	}

	return ret;
}