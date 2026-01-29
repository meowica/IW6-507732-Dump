#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_swim_ai_common;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
start()
{
	maps\black_ice_util::player_start( "player_start_swim" );
	//TimS - forcing this to be the right ambience at level start
	//level.player SetClientTriggerAudioZone( "blackice_underwater", 2 );
	level.player SetClientTriggerAudioZone( "blackice_camera", 2 );
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	thread underwater_sfx();
	
	thread maps\black_ice_audio::sfx_camera_intro();
	thread maps\black_ice_audio::sfx_distant_oilrig();
	
	
		music_play( "mus_blackice_intro_ss" );
	
	level.CONST_EXPECTED_NUM_SWIM_ALLIES = 2;		//How many allies do we expect?
	level._allies_swim = maps\black_ice_util::spawn_allies_swim();
	
	// Hide land allies
	foreach( ally in level._allies )
	{
		ally hide();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main()
{
	// Turn off green friendnames during cinematic intro
	level.g_friendlyNameDist_old = GetDvarInt( "g_friendlyNameDist" );
	SetSavedDvar( "g_friendlyNameDist", 0 );

	level.breach_anim_node = getstruct( "breach_anim_node", "script_noteworthy" );
	level.allies_breach_anim_node = getstruct( "vignette_introbreach_allies", "script_noteworthy" );
	level.snake_cam_anim_node = getstruct( "Intro_Snake", "script_noteworthy" );
	
	ally_setup();
	player_setup();
	enemy_setup();
	props_setup();
	
	// tagBR< note >: This function blocks logic until snake cam stuff is complete
	snake_cam_logic();
	
	
	// Now do swim init
	player_swim_setup();
	enemy_swim_setup();
	
	thread maps\black_ice_anim::swim_intro_anims();
	
	
	//thread light_manager();

	swim_detonate_logic();
}

section_post_inits()
{
	// Hide parts for optimization
	if( level.start_point == "swim" )
		array_call( GetEntArray( "opt_hide_swim", "script_noteworthy" ), ::Hide );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_check_node_distance()
{
	trigger_dist = 10000;
	
	cos45 = Cos( 45 );
	
	//set flag to trigger autoswim once player is x distance from the breachpoint
	while ( !flag( "flag_swim_player_drop_tank" ) )
	{
		dist_from_target = DistanceSquared( level.player GetEye(), level.breach_pos );
		
		if ( dist_from_target < trigger_dist )
		{
			if ( within_fov_2d( level.player GetEye(), level.player.angles, level.breach_pos, cos45 ) )
			{
				flag_set( "flag_swim_player_drop_tank" );
				level notify( "notify_begin_camp_logic" );
			}
		}
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_flag_inits()
{
	flag_init( "flag_underwater_sfx" );
	flag_init( "flag_outofwater_sfx" );
	
	flag_init( "flag_swim_player_drop_tank" );
	
	flag_init( "flag_swim_breach_detonate" );
	
	flag_init( "flag_all_enemies_dead" );
	
	flag_init( "flag_player_breaching" );
	
	flag_init( "flag_player_clear_to_breach" );
	
	flag_init( "flag_intro_above_ice" );
	
	flag_init( "flag_snake_cam_below_water" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
section_precache()
{
	add_hint_string( "detonate_string", &"BLACK_ICE_SWIM_DETONATE", ::detonate_string_func );
	
	PreCacheShader( "scubamask_overlay_delta" );
	PreCacheShader( "ac130_hud_target@black_ice" );
	PreCacheShader( "ugv_vertical_meter_left" );
	PreCacheShader( "ugv_vertical_meter_right" );
	PreCacheShader( "black" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ally_setup()
{
	for ( i = 0; i < level.CONST_EXPECTED_NUM_SWIM_ALLIES; i++ )
	{
		level._allies_swim[ i ].animname = "scuba_ally";
		PlayFXOnTag ( getfx ( "glowstick_orange" ), level._allies_swim[ i ], "J_glowstick_fx" );
		level._allies_swim[ i ] thread maps\_underwater::friendly_bubbles();
		
		level._allies_swim[ i ] Attach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
	}

	//PlayFXOnTag ( getfx ( "glowstick_orange" ), level._allies_swim[ 0 ], "J_glowstick_fx" );
	//PlayFXOnTag ( getfx ( "glowstick_orange" ), level._allies_swim[ 1 ], "J_glowstick_fx" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_setup()
{
	level.snake_cam_dummy = GetEnt( "snake_terrain_cam", "targetname" );
	level.snake_cam_dummy.animname = "snake_cam";
	level.snake_cam_dummy SetAnimTree();
	
	maps\black_ice_util::player_animated_sequence_restrictions();
	
	level.player PlayerLinkWeaponViewToDelta( level.snake_cam_dummy, "tag_player", 1, 0, 0, 0, 0, true );
	level.player PlayerLinkedSetViewZnear( false );

	level.hud_static_overlay = maps\_hud_util::create_client_overlay( "nightvision_overlay_goggles", 0.5 );
	thread snake_cam_hud();
	//thread snake_cam_dof();
	thread maps\black_ice_fx::snake_cam_fx();
	thread snake_cam_vision_flicker();
	//SetSavedDvar("r_sky_fog_intensity","1");
	SetSavedDvar( "compass", 0 );
	
	level.player LerpFOV( 45, level.TIMESTEP );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
enemy_setup()
{
	spawners = GetEntArray( "snake_cam_enemy", "script_noteworthy" );
	
	guys = array_spawn( spawners );
	
	for ( i = 0; i < guys.size; i++ )
	{
		guy = guys[i];
	
	guy set_battlechatter( false );
	guy.combatmode = "no_cover";
	guy.ignoreall = true;
	guy.ignoreme = true;

	guy.newEnemyReactionDistSq_old = self.newEnemyReactionDistSq;
	guy.newEnemyReactionDistSq = 0;
	guy.grenadeammo = 0;
	
	guy.animname = "snake_cam_enemy";
	}
	
	level.snake_cam_enemies = guys;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
snake_cam_vision_flicker()
{
	//level endon( "notify_underwater_transition" );
	
	flicker_time = 0.06;
	dark = false;
	
	level.player vision_set_fog_changes( "black_ice_snakecam", 0 );
	
	while( !flag( "flag_snake_cam_below_water" )  )
	{
		
		if( !flag( "flag_snake_cam_below_water" )  )
		{
			if( dark )
			{
				level.player vision_set_fog_changes( "black_ice_snakecam", flicker_time );
				//iprint(" light!" );
				dark = false;
			}
			else
			{
				level.player vision_set_fog_changes( "black_ice_snakecam_dark", flicker_time );
				//iprint(" dark!" );
				dark = true;
			}
		}
		
		wait flicker_time;
		
	}
	
	//set new underwater snake cam vision set here
	level.player vision_set_fog_changes( "black_ice_infil_dark", 0.2 );
	
}



snake_cam_dof()
{
	maps\_art::dof_enable_script( 0, 62, 4, 73, 1380, 2, 0.25 );
	
	level waittill( "notify_underwater_transition" );
	
	maps\_art::dof_disable_script( 0.25 );	
}

snake_cam_hud()
{
	level.hudsnakecamtarget = NewHudElem();
	level.hudsnakecamtarget.x = 320;
	level.hudsnakecamtarget.y = 240;
	level.hudsnakecamtarget.alignx = "center";
	level.hudsnakecamtarget.aligny = "middle";
	level.hudsnakecamtarget SetShader("ac130_hud_target@black_ice",70,70);
	level.hudsnakecamtarget.alpha = 1.0;
	
	level.hudsnakevmeter = NewHudElem();
	level.hudsnakevmeter.x = 20;
	level.hudsnakevmeter.y = 240;
	level.hudsnakevmeter.alignX = "right";
	level.hudsnakevmeter.alignY = "middle";
	level.hudsnakevmeter SetShader( "ugv_vertical_meter_left", 16, 260 );
	
	level.hudsnakevrmeter = NewHudElem();
	level.hudsnakevrmeter.x = 620;
	level.hudsnakevrmeter.y = 240;
	level.hudsnakevrmeter.alignX = "right";
	level.hudsnakevrmeter.alignY = "middle";
	level.hudsnakevrmeter SetShader( "ugv_vertical_meter_right", 16, 260 );
	
		
}
cleanupSnakeHud()
{
	
	level.hudsnakevmeter Destroy();
	level.hudsnakevmeter = undefined;
	level.hudsnakevrmeter Destroy();
	level.hudsnakevrmeter = undefined;
	level.hudsnakecamtarget Destroy();
	level.hudsnakecamtarget = undefined;
	level.hud_static_overlay Destroy();
	level.hud_static_overlay = undefined;
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
snake_cam_logic()
{
	thread set_snakecam_dof();
	// Spawn our own black screen
	thread black_fade( 0, 7, 0.1 );
	
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "We're in position.", 2 );
	thread smart_radio_dialogue( "black_ice_mrk_wereinposition" );
	wait 2;
	//thread maps\black_ice_util::temp_dialogue_line( "Bravo", "Roger Joker 1-1-2.", 3 );
	thread smart_radio_dialogue( "black_ice_hsh_rogeractual" );
	wait 3;
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Eyes coming up.", 2 );
	thread smart_radio_dialogue( "black_ice_mrk_eyescomingup" );
	wait 2;
	
	// Black screen gone. Screen effect?
	
	thread snake_cam_dialogue();
	thread swim_intro_dialogue();
	
	thread maps\black_ice_anim::snake_cam_enemy_anims();
	thread maps\black_ice_anim::swim_props_first_frame_anims();
	thread maps\black_ice_anim::swim_vehicles_snake_cam_anims();
	thread snake_cam_shake_rumble();
	
	thread snake_cam_input_logic();
	
	level waittill( "notify_underwater_transition" );
	
	snake_cam_transition_to_underwater();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
snake_cam_dialogue()
{
	level waittill( "notify_snake_cam_dialogue_line2_1" );
	//thread maps\black_ice_util::temp_dialogue_line( "Bravo", "Last patrol is inbound.", 3 );
	thread smart_radio_dialogue( "black_ice_hsh_lastpatrolisinbound" );
	
	level waittill( "notify_snake_cam_dialogue_line2_2" );
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Copy Bravo. Is that all of them?", 3 );
	smart_radio_dialogue( "black_ice_mrk_copybravo" );
	thread smart_radio_dialogue( "black_ice_mrk_isthatallof" );
	
	level waittill( "notify_snake_cam_dialogue_line2_3" );
	//thread maps\black_ice_util::temp_dialogue_line( "Bravo", "Roger...it's a full house. See you topside.", 3 );
	smart_radio_dialogue( "black_ice_hsh_rogeritsafullhouse" );
	thread smart_radio_dialogue( "black_ice_hsh_seeyoutopside" );
	
	level waittill( "notify_snake_cam_dialogue_line2_4" );
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Adam, let's go.", 3 );
	thread smart_radio_dialogue( "black_ice_mrk_adamletsgo" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_intro_dialogue()
{
	level waittill( "notify_snake_cam_dialogue_line3_1" );
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Charges are set and everyone’s home.  Let’s introduce ourselves…on you.", 3 );
	smart_radio_dialogue( "black_ice_mrk_chargesaresetand" );
	thread smart_radio_dialogue( "black_ice_mrk_letsintroduceourselveson" );
	
	level waittill( "notify_swim_dialog5_1" );
	//thread maps\black_ice_util::temp_dialogue_line( "Baker", "Mark.  Drop them.", 1.8 );
	thread smart_radio_dialogue( "blackice_bkr_markdropthem" );
	
	// Add hint string if the player has not already detonated the c4
	wait 1;
	if ( !flag( "flag_swim_breach_detonate"))
	{
		display_hint( "detonate_string" );
	}
	
	// Nags
	wait 3.0;
	waittime = 2.0;
	if ( !flag( "flag_swim_breach_detonate"))
	{
		//thread maps\black_ice_util::temp_dialogue_line( "Baker", Drop them, Rook.", 1.8 );
		smart_radio_dialogue( "blackice_bkr_dropthemrook" );
	}
	
	wait waittime;
	if ( !flag( "flag_swim_breach_detonate"))
	{
		//thread maps\black_ice_util::temp_dialogue_line( "Baker", "Rook, set off the charges, now!", 1.8 );
		smart_radio_dialogue( "blackice_bkr_setoffcharges" );
	}
	
	wait waittime;
	if ( !flag( "flag_swim_breach_detonate"))
	{
		//thread maps\black_ice_util::temp_dialogue_line( "Baker", "blackice_bkr_windowsclosing", 1.8 );
		smart_radio_dialogue( "blackice_bkr_windowsclosing" );
	}
	
	wait waittime;
	if ( !flag( "flag_swim_breach_detonate"))
	{
		//thread maps\black_ice_util::temp_dialogue_line( "Baker", "They're moving, drop them now!", 1.8 );
		smart_radio_dialogue( "blackice_bkr_theyremoving" );
	}
	
	// Took too long, FAIL
	wait waittime;
	if ( !flag( "flag_swim_breach_detonate"))
	{
		SetDvar( "ui_deadquote", "(DEBUG) You missed your window.  mission failed" );
		MissionFailedWrapper();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

snake_cam_shake_rumble()
{
	level.player_rumble_ent = maps\black_ice_util::get_rumble_ent_linked( level.snake_cam_dummy );
	wait( 0.05 );
	level.player_rumble_ent.intensity = 0;
	
	level waittill( "notify_rumble_snowmobile_1" );
	thread player_rumble_bump( 0.08, 0.0, 0.2, 0, 0.5 );

	level waittill( "notify_rumble_snowmobile_2" );
	thread player_rumble_bump( 0.13, 0.0, 0.2, 0, 0.5 );
	
	level waittill( "notify_rumble_truck_1" );
	thread player_rumble_bump( 0.18, 0.0, 0.2, 0, 1.15 );

	level waittill( "notify_rumble_truck_2" );
	thread player_rumble_bump( 0.6, 0.0, 0.3, 0, 0.75 );
	
	level waittill( "notify_rumble_truck_3" );
	thread player_rumble_bump( 0.6, 0.0, 0.6, 0, 1.25 );
	
	level waittill( "notify_rumble_truck_off" );
	thread player_rumble_bump( 0.0, 0.0, 0.75, 0, 0.01 );
	
	level waittill( "notify_rumble_cam_1" );
	thread player_rumble_bump( 0.22, 0.0, 0.01, 0, 0.3 );

	level waittill( "notify_rumble_cam_2" );
	thread player_rumble_bump( 0.21, 0.0, 0.1, 0, 0.4 );
	
	level waittill( "notify_rumble_cam_3" );
	thread player_rumble_bump( 0.18, 0.0, 0.1, 0, 0.55 );
	
	level waittill( "notify_rumble_cam_4" );
	thread player_rumble_bump( 0.21, 0.0, 0.1, 0, 0.75 );
	
	wait( 4 );
	
	level.player_rumble_ent delete();
	
	
}

player_rumble_bump( mag_1, mag_2, time_in, hold_time, time_out )
{
	
	level notify( "notify_new_rumble_bump" );
	level endon( "notify_new_rumble_bump" );
	
	//IPrintLnBold( "rumblein" );
	
	level.player_rumble_ent rumble_ramp_to( mag_1, time_in );
	wait( time_in + hold_time );
	level.player_rumble_ent rumble_ramp_to( mag_2, time_out );
	
	//IPrintLnBold( "rumbleout" );

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


snake_cam_noise( base_angles )
{
	level endon( "notify_underwater_transition" );
	
	level notify( "snake_cam_noise" );
	
	amplitude = level.snake_cam_dummy.noise_amplitude;
	//time = level.TIMESTEP;
	time = 0.1;
	duration = 150;
	
	start_time = GetTime();
	
	while ( ( GetTime() - start_time ) < duration )
	{
		noise_angles = ( RandomFloatRange( -1 * amplitude, amplitude ), RandomFloatRange( -1 * amplitude, amplitude ), RandomFloatRange( -1 * amplitude, amplitude ) );

		//level.snake_cam_dummy.angles = base_angles + noise_angles;
		level.snake_cam_dummy.angles += noise_angles;
	
		wait time;
	}
	
	thread snake_cam_noise_falloff( amplitude );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
snake_cam_noise_falloff( amplitude )
{
	level endon( "notify_underwater_transition" );
	level endon( "snake_cam_noise" );
	
	min_amplitude = level.snake_cam_dummy.noise_min_amplitude;
	//time = level.TIMESTEP;
	time = 0.1;
	duration = 100;
	falloff_rate = 0.75;
	
	while ( 1 )
	{
		start_time = GetTime();
		
		while ( ( GetTime() - start_time ) < duration )
		{
			noise_angles = ( RandomFloatRange( -1 * amplitude, amplitude ), RandomFloatRange( -1 * amplitude, amplitude ), RandomFloatRange( -1 * amplitude, amplitude ) );
			
			//level.snake_cam_dummy.angles = base_angles + noise_angles;
			level.snake_cam_dummy.angles += noise_angles;
			
			wait time;
		}
		
		amplitude *= falloff_rate;
		
		if ( amplitude < min_amplitude )
			amplitude = min_amplitude;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
snake_cam_input_logic()
{
	level endon( "notify_underwater_transition" );
	
	is_moving = false;
	
	center_angles = level.snake_cam_dummy.angles;
	spread_half_angle_horiz = 45;
	min_angle_horiz = center_angles[1] - spread_half_angle_horiz;
	max_angle_horiz = center_angles[1] + spread_half_angle_horiz;
	spread_half_angle_vert = 12;
	min_angle_vert = center_angles[0] - spread_half_angle_vert;
	max_angle_vert = center_angles[0] + ( spread_half_angle_vert / 2 ); // Don't want to allow looking too far down, will clip through ground
	
	curr_angle_horiz = center_angles[1];
	target_angle_horiz = center_angles[1];
	curr_angle_vert = center_angles[0];
	target_angle_vert = center_angles[0];
	
	rate_horiz = 0.075;
	Assert( spread_half_angle_vert > 0 );
	rate_vert = rate_horiz * ( spread_half_angle_horiz / spread_half_angle_vert );
	
	dir_horiz = 0;
	prev_dir_horiz = 0;
	dir_vert = 0;
	prev_dir_vert = 0;
	
	noise_time_elapse_delay = 1000; // in ms
	noise_curr_time = undefined;
	
	noise_static_amplitude = 0.6;
	noise_kinetic_amplitude = 0.48;
	
	level.snake_cam_dummy.noise_min_amplitude = 0.09;
	level.snake_cam_dummy.noise_amplitude = level.snake_cam_dummy.noise_min_amplitude;
	
	// Add a little noise to begin with, until the player moves
	thread snake_cam_noise( level.snake_cam_dummy.angles );
	
	while ( 1 )
	{
		move = level.player GetNormalizedCameraMovement();
		
		// We want left/right control
		if ( move[1] || move[0] )
		{
			dir_horiz = ter_op( ( move[1] > 0 ), 1, -1 );
			dir_vert = ter_op( ( move[0] > 0 ), 1, -1 );
			
			// if player presses from rest or changes directions, send a 'jolt' of noise
			if ( !is_moving || ( dir_horiz != prev_dir_horiz ) || ( dir_vert != prev_dir_vert ) )
			{
				if ( !IsDefined( noise_curr_time ) || ( GetTime() - noise_curr_time ) > noise_time_elapse_delay )
				{
					noise_curr_time = GetTime();
					level.snake_cam_dummy.noise_amplitude = noise_static_amplitude;
				}
				else
				{
					level.snake_cam_dummy.noise_amplitude = noise_kinetic_amplitude;
				}
				
				is_moving = true;
				thread snake_cam_noise( level.snake_cam_dummy.angles );
				thread maps\black_ice_audio::sfx_camera_mvmt();
			}
			
			target_angle_horiz = ter_op( ( move[1] > 0 ), min_angle_horiz, max_angle_horiz );
			target_angle_vert = ter_op( ( move[0] > 0 ), min_angle_vert, max_angle_vert );
		
			// lerp to the target
			// curr = curr + ( target - curr ) * rate
			curr_angle_horiz += ( ( target_angle_horiz - curr_angle_horiz ) * rate_horiz * abs( move[1] ) );
			curr_angle_vert += ( ( target_angle_vert - curr_angle_vert ) * rate_vert * abs( move[0] ) );
			
			level.snake_cam_dummy.angles = ( curr_angle_vert, curr_angle_horiz, center_angles[2] );
			
			prev_dir_horiz = dir_horiz;
			prev_dir_vert = dir_vert;
		}
		else
		{
			prev_dir_horiz = 0;
			prev_dir_vert = 0;
			is_moving = false;
		}
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
snake_cam_transition_to_underwater()
{
	fade_in_time = 0.5;
	add_wait_time = 0;
	fade_out_time = 1.0;
	
	thread black_fade( fade_in_time, add_wait_time, fade_out_time );
	
	wait fade_in_time;
	cleanupSnakeHud();
	SetSavedDvar( "compass", 1 );
	
	level.player VisionSetNakedForPlayer( "", 0 );
	
	level.player LerpFOV( 60, level.TIMESTEP );
	
	level.player Unlink();
	
	thread borescope_pip();
	
	level notify( "snake_cam_transition_to_underwater_complete" );
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
	
	//turn on camera fx
	level notify( "notify_snakecam_on" );
	
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
borescope_pip()
{
	// Create pip and set parameters
	level.pip = level.player NewPIP();

	level.pip.x = 300;
	level.pip.y = 240;
	level.pip.width = 240;
	level.pip.height = 135;
	level.pip.origin =  level.borescope GetTagOrigin( "tag_camera" );
	level.pip.freeCamera = true;
	level.pip.fov = 45;
	level.pip.enableShadows = true;
	
	level.pip.entity = level.borescope;
	level.pip.tag = "tag_camera";
	
	level.pip.enable = true;
	level.pip.renderToTexture = 1;
	
	// Wait until the snake cam is destroyed and then cleanup the pip
	level.borescope waittill( "death" );
	
	level.pip.enable = false;
	level.pip = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_swim_setup()
{
	level.spring_cam_max_clamp = 30;
	level.spring_cam_min_clamp = 20;
	
	level.breach_pt = getstruct( "breach_point", "script_noteworthy" );
	level.breach_pos = ( level.breach_pt.origin + ( 0, 0, 0 ) );
	
	maps\black_ice_util::setup_player_for_animated_sequence( false, undefined, undefined, level.player.angles, false );
	
	player_scuba = spawn_anim_model( "player_scuba", level.player_rig.origin );
	level.player_scuba = player_scuba;
	
	//level.player_legs = spawn_anim_model( "player_legs_intro", level.player_rig.origin );
	
	//level.player_underwater_rifle = spawn_anim_model( "player_gun_intro", level.player_rig.origin );
	
	PlayFXOnTag ( getfx ( "glowstick_orange" ), level.player_scuba, "J_glowstick_fx" );
	
//	// Tweakable swim vars
//		* player_swimSpeed					80.0
//		* player_swimAcceleration			100.0
//		* player_swimFriction				30.0
//		* player_swimVerticalSpeed			120.0
//		* player_swimVerticalAcceleration	160.0
//		* player_swimVerticalFriction		40.0
//		* player_swimPullAwayAngle			10
//		* player_swimWaterCurrent			( 0.0, 0.0, 0.0 )
//
//		* player_swimCombatTimer			10000
				
	// tagBR< hack > Wish I didn't have to do this...
	//level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, level.spring_cam_max_clamp, level.spring_cam_max_clamp, level.spring_cam_max_clamp, level.spring_cam_max_clamp, true );
	level.player AllowSwim( true );
	level.player EnableSlowAim( 0.5, 0.5 );
	SetSavedDvar( "player_swimSpeed", 0.0 );
	SetSavedDvar( "player_swimVerticalSpeed", 0.0 );
	
	level.player PlayerLinkToDelta( level.player_rig, "tag_player", 1, 0, 0, 0, 0, true );

	//<tagCP>allow the player to look all the way up for the intro	
	level.player_ground_origin = Spawn( "script_origin", ( 0, 0, 0 ) );
	level.player_ground_origin LinkTo( level.player_rig, "tag_player" );
	level.player PlayerSetGroundReferenceEnt( level.player_ground_origin );
    
	SetHUDLighting( true );
	level.player.hud_scubaMask = level.player maps\_hud_util::create_client_overlay( "scubamask_overlay_delta", 1, level.player );
	level.player.hud_scubaMask.foreground = false;
	level.player.hud_scubaMask.sort = -99;
	level.player thread maps\_underwater::player_scuba();
	level.player maps\_underwater::underwater_hud_enable( true );
	
	init_swim_vars();
	
	init_swim();
	
	thread player_weapon_hack();
	
	maps\black_ice_util::player_animated_sequence_restrictions();
	
	wait level.TIMESTEP;
		
	level.player LerpViewAngleClamp( 0, 0, 0, level.spring_cam_min_clamp, level.spring_cam_min_clamp, level.spring_cam_min_clamp, level.spring_cam_min_clamp );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_weapon_hack()
{
	//give player detonator
	level.player GiveWeapon( "test_detonator_black_ice" );
	level.player SetWeaponAmmoClip( "test_detonator_black_ice", 0 );
	
	// Hackery to get the underwater gun not to do first raise anim	
	level.player GiveWeapon( "aps_underwater" );
	level.player SwitchToWeapon( "aps_underwater" );
	wait( 1.3 );
	//queing up the c4 before disabling weapons for the intro, so the switchto works better.
	level.player SwitchToWeapon( "test_detonator_black_ice" );
	//level.player SwitchToWeapon( level.default_weapon );
	//wait( 1.3 );
	//level.player SwitchToWeapon( "aps_underwater" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//TtagCP rubberband player speed to follow actors
//compare the players distance from the breach point to the allies distance from the breach point.  Dont let the player get closer to the breachpoint
player_swim_rubberband()
{
	level endon( "notify_swim_end" );
		
	max_speed = 80.0;
	min_speed = 40.0;
	max_dist = 130000.0;
	min_dist = 35000.0;
	
	//init for debugging
	dist_from_ally = 0.0;
	ally_dist = 0.0;
	player_dist = 0.0;
	//old_ally_pos = level._allies_swim[ 0 ].origin;
	//ally_speed = 0.0;
	
	while ( 1 )
	{	
		if ( Isdefined ( level._allies_swim[ 0 ].origin )  )
		{		
			ally_dist = DistanceSquared( level._allies_swim[ 0 ].origin, level.breach_pos );
			player_dist = DistanceSquared( level.player GetEye(), level.breach_pos );
			dist_from_ally = player_dist - ally_dist;
		}
		
		rubberband_factor = maps\black_ice_util::normalize_value( min_dist, max_dist, dist_from_ally );
		
		//IPrintLn( "distance factor is   " + rubberband_factor );
		
		player_rubberband_speed = maps\black_ice_util::factor_value_min_max( min_speed, max_speed, rubberband_factor );
		
		//IPrintLn( "rubberband speed" + player_rubberband_speed );
		
		level.player.target_swim_speed = player_rubberband_speed;
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_swim_water_current_logic()
{
	level endon( "notify_swim_end" );
	
	depth_layers = [];
	depth_layers[0] = [ -200.0, 4400 ];
	depth_layers[1] = [ -150.0, 3200 ];
	depth_layers[2] = [ -100.0, 2000 ];
	
	while ( 1 )
	{
		// Apply a water current to get the player back "in bounds"
		if ( level.player.origin[2] < depth_layers[0][0] )
		{
			level.player.target_water_current = ( 0.0, 0.0, 1.0 ) * depth_layers[0][1];
			level.player.water_current_delta = 0.2;
		}
		else if ( level.player.origin[2] < depth_layers[1][0] )
		{
			level.player.target_water_current = ( 0.0, 0.0, 1.0 ) * depth_layers[1][1];
			level.player.water_current_delta = 0.2;
		}
		else if ( level.player.origin[2] < depth_layers[2][0] )
		{
			level.player.target_water_current = ( 0.0, 0.0, 1.0 ) * depth_layers[2][1];
			level.player.water_current_delta = 0.2;
		}
		else
		{
			level.player.target_water_current = ( 0.0, 0.0, 0.0 );
			level.player.water_current_delta = 0.1;
		}
		
		wait level.TIMESTEP;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*light_manager()
{
	commentted out until light gets put back in
	//how fast the light will change per frame once hole is breached
	light_speed = 0.3;
	icehole_light = GetEnt( "infil_light_primary", "targetname" );
	
	//cache the intenstiy the lighters have set
	max_light_intensity = icehole_light GetLightIntensity();
	
	//light starts off dark
	light_intensity = 0;
	//set light
	icehole_light setLightIntensity ( light_intensity );
	
	//wait for hole to open
	level waittill( "icehole_open" );
	
	//
	while ( light_intensity < max_light_intensity )
	{
		
		light_intensity += light_speed;
		
		if ( light_intensity > max_light_intensity )
		{
			light_intensity = max_light_intensity;
		}
			
		icehole_light setLightIntensity ( light_intensity );
		wait level.TIMESTEP;
	}
	//icehole_light setlightintensity ( off );
	
}*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_swim_vars()
{
	// Set to really slow at first (for detonation phase)
	level.player.target_swim_speed = 0.0;
	level.player.swim_speed_delta = 0.03;
	
	level.player.target_water_current = ( 0, 0, 0 );
	level.player.water_current_delta = 0.1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
init_swim()
{
	flag_set( "flag_underwater_sfx" );
		
	vision_set_fog_changes("black_ice_infil",0);
	SetSavedDvar( "r_snowAmbientColor", ( 0.035, 0.04, 0.04 ) );
	thread infil_lights_and_vision();
	//fire off ambient fx
	exploder ( "underwater_amb" );
	
	level.player.hint_active = false;
	
	thread swim_check_node_distance();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_lerp_swim_vars()
{
	// self is level.player
	level endon( "notify_swim_end" );
	
	curr_swim_speed = self.target_swim_speed;
	curr_water_current = self.target_water_current;
		
	while ( 1 )
	{
		//curr_swim_speed = GetDvarFloat( "player_swimSpeed" );
		curr_swim_speed += ( ( self.target_swim_speed - curr_swim_speed ) * self.swim_speed_delta );
		SetSavedDvar( "player_swimSpeed", curr_swim_speed );
		//SetSavedDvar( "player_swimVerticalSpeed", curr_swim_speed );
		
		//curr_water_current = getdvarvector( "player_swimWaterCurrent" );
		curr_water_current += ( ( self.target_water_current - curr_water_current ) * self.water_current_delta );
		SetSavedDvar( "player_swimWaterCurrent", curr_water_current );
		
		wait level.TIMESTEP;
		//IPrintLn( level.player.target_swim_speed );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
enemy_swim_setup()
{
	level.ice_breach_enemies = [];
	spawners = GetEntArray( "ice_breach_enemy", "script_noteworthy" );
	
	foreach( spawner in spawners )
	{
		guy = spawner DoSpawn();
		
		guy.swimmer = true;
		guy.noragdoll = true;
		guy.deathFunction = maps\black_ice_anim::swim_enemy_death_anim_override;
		
		guy set_battlechatter( false );
		guy.combatmode = "no_cover";
		guy.ignoreall = true;
		guy.ignoreme = true;
		//guy.ignoreexplosionevents = true;//
		//guy.ignorerandombulletdamage = true;//
		//guy.ignoresuppression = true;//
		//guy.dontavoidplayer = true;//
		//guy.fixednode = false;//
		guy.nodrop = true;
		guy.disableArrivals = true;
		//guy.disableBulletWhizbyReaction = true;//
		guy.newEnemyReactionDistSq_old = self.newEnemyReactionDistSq;
		guy.newEnemyReactionDistSq = 0;
		guy.grenadeammo = 0;
		//guy.grenadeawareness = 0;//
		guy AllowedStances( "stand", "crouch" );
		//guy enable_cqbwalk();
		//guy set_generic_idle_anim( "_stealth_look_around" );
		guy HidePart_AllInstances( "tag_weapon" );
		guy HidePart_AllInstances( "tag_clip" );
		
		guy disable_pain();
		//guy set_allowdeath( false );//
		guy thread magic_bullet_shield();
		
		guy.animname = "ice_breach_enemy";
		
		level.ice_breach_enemies[ level.ice_breach_enemies.size ] = guy;
	}
	
	// tagBR< note >: This sets up bubble effects to play off the swim allies' flippers
	thread maps\_swim_ai_common::override_water_footsteps();
		
	maps\black_ice_anim::swim_enemies_first_frame_anims();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
props_setup()
{
	level.breach_props = [];
	
	create_persistent_ice_breach_props();
	
	level.breach_vehicles["gaz71"] = spawn_anim_model( "gaz71" );
	level.breach_vehicles["gaztiger"] = spawn_anim_model( "gaztiger" );
	level.breach_vehicles["bm21_2"] = spawn_anim_model( "bm21_2" );
	
	level.vehicles_no_breach["bm21_3"] = spawn_anim_model( "bm21_3" );
	level.vehicles_no_breach["gaztiger_2"] = spawn_anim_model( "gaztiger_2" );
	
	level.vehicles_no_breach["snowmobile_1"] = spawn_anim_model( "snowmobile_1" );
	level.vehicles_no_breach["snowmobile_2"] = spawn_anim_model( "snowmobile_2" );
	
	level.breach_mines = GetEntArray( "limpet_mine", "targetname" );
	
	level.borescope = spawn_anim_model( "borescope" );

	thread mine_blink_fx();
	
	//use herolighting on props
	/*foreach( thing in level.breach_vehicles )
		thing StartUsingHeroOnlyLighting();
	
	foreach( thing in level.breach_props )
		thing StartUsingHeroOnlyLighting();*/
	
	// Want to hide the ice prior to anim playing
	level.breach_props["ice_chunks1"] Hide();
	level.breach_props["ice_chunks2"] Hide();
	
	level.breach_props["breach_water"] Hide();
	
	// Hide the rig (prop) models initially
	//for ( i = 0; i < level.tag_anim_rig_models.size; i++ )
	//{
	//	level.tag_anim_rig_models[i] Hide();
	//}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
prop_attach_coll()
{
	coll = GetEnt( self.coll, "targetname" );
	
	if ( IsDefined( coll ) )
	{
		// tagBR< hack>: Origin offset to sync up clip origin to model origin
		coll.origin = self.origin + ( 0, 0, 32 );
		coll.angles = self.angles;
		coll LinkTo( self );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
create_persistent_ice_breach_props( play_anims )
{
	if ( !IsDefined( level.breach_props ) )
	{
		level.breach_props = [];
	}
	
	if ( !IsDefined( level.tag_anim_rig_models ) )
	{
		level.tag_anim_rig_models = [];
	}
	
	introbreach_props = maps\black_ice_util::setup_tag_anim_rig( "introbreach_props", "introbreach_props", 4, true );
	
	// Attach collision clip box to the props if they exist
	for ( i = 0; i < level.tag_anim_rig_models.size; i++ )
	{
		if ( IsDefined( level.tag_anim_rig_models[i].coll ) )
		{
			level.tag_anim_rig_models[i] prop_attach_coll();
		}
	}
	
	level.breach_props["introbreach_props"] = introbreach_props;
	
	level.breach_props["ice_chunks1"] = GetEnt( "ice_chunks1", "targetname" );
	level.breach_props["ice_chunks1"].animname = "ice_chunks1";
	level.breach_props["ice_chunks1"] maps\_utility::assign_animtree();
	
	level.breach_props["ice_chunks2"] = GetEnt( "ice_chunks2", "targetname" );
	level.breach_props["ice_chunks2"].animname = "ice_chunks2";
	level.breach_props["ice_chunks2"] maps\_utility::assign_animtree();
	
	level.breach_props["breach_water"] = spawn_anim_model( "breach_water" );
	level.breach_props["breach_water"] thread retarget_breach_water();
	
	level.breach_vehicles = [];
	level.breach_vehicles["bm21_1"] = spawn_anim_model( "bm21_1" );
	//maps\black_ice_fx::intro_turn_on_prop_bm21_1_lights_fx();
	
	if ( IsDefined( play_anims ) && play_anims )
	{
		level.breach_anim_node thread anim_loop_solo( level.breach_props["ice_chunks1"], "intro_breach_loop", "stop_loop" );
		//level.breach_anim_node thread anim_loop_solo( level.breach_props["ice_chunks2"], "intro_breach_loop", "stop_loop" );
		
		level.breach_anim_node anim_last_frame_solo( level.breach_props["introbreach_props"], "intro_breach" );
		level.breach_anim_node anim_last_frame_solo( level.breach_props["breach_water"], "intro_breach" );
		level.breach_anim_node anim_last_frame_solo( level.breach_vehicles["bm21_1"], "intro_breach" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
mine_blink_fx()
{
	foreach( breach_mine in level.breach_mines )
	{
		wait ( level.timestep );
		PlayFXOnTag ( getfx( "mine_light" ), breach_mine, "tag_fx" );
		
		wait 0.1;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
destroy_breach_mines_and_fx()
{
	// Destroy mines
	foreach( breach_mine in level.breach_mines )
	{
		wait ( level.timestep );
		StopFXOnTag ( getfx( "mine_light" ), breach_mine, "tag_fx" );
		breach_mine delete();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_detonate_logic()
{
	level waittill( "notify_pullout_detonator" );
	
	//SetSavedDvar( "cg_drawCrosshair", 0 );
	//level.player SwitchToWeaponImmediate( "test_detonator_black_ice" );
	level.player EnableWeapons();
	level.player SwitchToWeapon( "test_detonator_black_ice" );
	level.player AllowFire(false);
	
	//tagCP threading of idle for allies is move to end of ally intro anim
	//thread maps\black_ice_anim::swim_await_detonate_anims();
	
	//tagCP no linger waiting...when the detonator is out, you should be able to push the button.
	//level waittill( "notify_wait_player_detonate" );

	// Need to wait for the detonator's "raise" anim to play out
	wait 2.0;

	swim_wait_for_detonate();
	
	thread swim_player_start_breach();

	
	// ideally would check a notetrack in the player_clacker_putaway anim for when the thumb hits the button
	wait 0.5;
	
	thread swim_breach_dialog();

	ice_breach_logic();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_breach_dialog()
{
	wait 0.2;
	radio_dialogue_stop();
	if( flag("flag_player_clear_to_breach"))
	{
		wait 0.4;
		//Baker:"take them out"
		thread smart_radio_dialogue( "blackice_bkr_takeemout" );
	}
	else
	{
		wait 0.1;
		//Baker:"take them out"
		thread smart_radio_dialogue( "blackice_bkr_toosoon" );
	}

}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

swim_player_start_breach()
{
	//speed up player a little for breach section
	//level.player.target_swim_speed = 13;
	
	// Wait for the fire anim to play out
	fire_time = WeaponFireTime( "test_detonator_black_ice" );
	wait fire_time;
	
	// Then switch to the primary weapon and take the detonator
	level.player SwitchToWeapon( "aps_underwater" );
	SetSavedDvar( "player_swimCombatTimer", 5000 );
	//SetSavedDvar( "cg_drawCrosshair", 1 );
	
	// Turn on green friendnames (disabled during cinematic intro )
	SetSavedDvar( "g_friendlyNameDist", level.g_friendlyNameDist_old );
	level.g_friendlyNameDist_old = undefined;
	
	wait 1.0;
	level.player TakeWeapon( "test_detonator_black_ice" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_surface_dialog()
{
	//level waittill( "notify_swim_dialog6" );
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "We're clear.  Lets Move.", 2.0 );
	thread smart_radio_dialogue( "blackice_bkr_wereclear" );
	
	//level waittill( "notify_swim_dialog6_1" );
	//thread maps\black_ice_util::temp_dialogue_line( "Bravo (over radio)", "That woke 'em up.", 2.0 );
	//thread smart_radio_dialogue( "black_ice_hsh_thatwokeemup" );
	
	//level waittill( "notify_swim_dialog6_2" );
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Coming your way.", 2.0 );
	//thread smart_radio_dialogue( "black_ice_mrk_comingyourway" );
	
	//level waittill( "notify_swim_dialog6_3" );
	//thread maps\black_ice_util::temp_dialogue_line( "Bravo (over radio...sounds of gunfire)", "Hurry up. It's getting hot up here.", 2.0 );
	//thread smart_radio_dialogue( "black_ice_hsh_hurryupitsgetting" );
	
	level waittill( "notify_swim_dialog6_4" );
	//thread maps\black_ice_util::temp_dialogue_line( "Bravo 2", "Taking fire!", 2.0 );
	thread smart_radio_dialogue( "black_ice_hsh_takingfire" );
	
	level waittill( "notify_swim_dialog6_5" );
	//thread maps\black_ice_util::temp_dialogue_line( "Bravo 2", "Incoming! <boom!>", 2.0 );
	thread smart_radio_dialogue( "black_ice_hsh_incoming" );
	
	wait 2.0;
	
	//TAG CP: commenting out the snowmobile*************************************************
	// The muffled sound of an explosion above the ice.  A moment later a snowmobile crashes into the water on the right side of the player.
	// TODO: Need muffled sound of explosion above ice
	//IPrintLnBold( "BOOM!" );
	
	// Slightly delayed earthquake
//	wait 0.25;
//	Earthquake( 0.6, 1.5, level.player.origin, 100 );
	
	// Snowmobile crashes into water
//	level.breach_anim_node thread anim_single_solo( level.snowmobile_enemy, "snowmobile_breach_opfor" );
//	level.snowmobile_enemy thread maps\black_ice_util::delete_at_anim_end( "snake_cam_enemy", "snowmobile_breach_opfor" );
//	level.breach_anim_node thread anim_single_solo( level.vehicles_no_breach["snowmobile_1"], "snowmobile_breach" );
//	level.vehicles_no_breach["snowmobile_1"] thread maps\black_ice_util::delete_at_anim_end( "snowmobile_1", "snowmobile_breach" );
	//TAG CP: commenting out the snowmobile************************************************
	
	level waittill( "notify_swim_dialog7" );
	//if ( cointoss() )
	//{
		//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Watch out!", 2.0 );
	//}
	//else // variant
	//{
		//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Watch it!", 2.0 );
		thread smart_radio_dialogue( "black_ice_mrk_watchit" );
	//}
	
	level waittill( "notify_swim_dialog7_1" );
	//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Drop tanks and get topside!", 5.0 );
	thread smart_radio_dialogue( "black_ice_mrk_dropyourtanksand" );
	
	// Nags
	wait 5.0;
	waittime = 2.0;
	if ( !flag( "flag_swim_player_drop_tank" ) )
	{
		//thread maps\black_ice_util::temp_dialogue_line( "Bravo", "Get up here!", 2.0 );
		thread smart_radio_dialogue( "black_ice_hsh_getuphere" );
	}
	
	wait waittime;
	if ( !flag( "flag_swim_player_drop_tank" ) )
	{
		//thread maps\black_ice_util::temp_dialogue_line( "Merrick", "Double time it.", 2.0 );
		thread smart_radio_dialogue( "black_ice_mrk_doubletimeit" );
	}
	
	wait waittime;
	if ( !flag( "flag_swim_player_drop_tank" ) )
	{
		//thread maps\black_ice_util::temp_dialogue_line( "Bravo", "Where are you Alpha?!", 2.0 );
		thread smart_radio_dialogue( "black_ice_hsh_whereareyoualpha" );
	}
	
	// Took too long, FAIL
	wait waittime;
	if ( !flag( "flag_swim_player_drop_tank" ) )
	{
		SetDvar( "ui_deadquote", "(DEBUG) Bravo died.  mission failed" );
		MissionFailedWrapper();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
swim_wait_for_detonate()
{
	// Show, press 'x' to detonate
	//thread maps\black_ice_util::temp_dialogue_line( "Tango", "Okay, blast that shit!", 2 );
	//display_hint( "detonate_string" );
	
	
	level.player AllowFire(true);
	
	while( !( level.player AttackButtonPressed() ) )
	{
		wait level.TIMESTEP;
	}
	
	thread maps\black_ice_audio::sfx_breach_detonate();
	
	flag_set( "flag_swim_breach_detonate" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
detonate_string_func()
{
	return ter_op( level.player AttackButtonPressed(), true, false );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ice_breach_logic()
{
	// Explosion
	thread maps\black_ice_fx::intro_detonation_sequence_fx();
	
	Earthquake( 0.6, 1.5, level.player.origin, 100 );
	level.player ShellShock( "default_nosound", 1.5 );

	wait 0.75;
		
	handle_ice_plugs();
	
	thread destroy_breach_mines_and_fx();
	
	// Unhide the ice prior to anim playing
	level.breach_props["ice_chunks1"] Show();
	//level.breach_props["ice_chunks2"] Show();
	
	level.breach_props["breach_water"] Show();
	
	// Unhide the rig (prop) models
	//for ( i = 0; i < level.tag_anim_rig_models.size; i++ )
	//{
	//	level.tag_anim_rig_models[i] Show();
	//}
	
	level.breach_props["introbreach_props"] thread ice_breach_process_prop_fx();
	
	// Anims
	thread maps\black_ice_anim::swim_breach_anims();
	thread props_cleanup();
	
	// Enemies
	for ( i = 0; i < level.ice_breach_enemies.size; i++ )
	{
		level.ice_breach_enemies[i] thread ice_breach_process_enemy( i );
		wait level.TIMESTEP;
		level.ice_breach_enemies[i] thread ice_breach_process_enemy_fx();
	}

	wait_till_breach_end_conditions();
	
	autosave_by_name( "swim_forward" );
	
	thread maps\black_ice_anim::swim_allies_swim_forward();
	
	thread player_surface_logic();
	thread swim_surface_dialog();
	
	// Swap swim allies for land allies once anim completes
	thread scuba_ally_swap();
	
	level waittill( "notify_begin_camp_logic" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
handle_ice_plugs()
{
	ice_plugs = GetEntArray( "ice_plug", "script_noteworthy" );
	
	foreach( ice_plug in ice_plugs )
	{
		ice_plug Hide();
		ice_plug Delete();
	}
	
	// Show ice edges
	array_call( GetEntArray( "opt_hide_swim", "script_noteworthy" ), ::Show );
	
	//notify light_manager hole is open
	level notify( "icehole_open" );
}
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ice_breach_process_prop_fx()
{
	wait( 1.0 );
	model_name = self.model;
    num_tags = GetNumParts( model_name );
    
    for( i = 0; i < num_tags; i++ )
    {
    	// tagBR< note >: The tag_name here syncs up to the bone names in blackice_introbreach_props_lod0.xmodel_export
    	tag_name = GetPartName( model_name, i );
    	
    	switch( tag_name )
    	{
    		case "tag_origin_new_props":
    			// don't want to do anything with the prop model's origin, so just break
    			break;
    			
    		case "mdl_ch_crate64x64_snow_001":
    			// play a specific effect on this tag
    			//PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], self, tag_name );
    			break;
    			
    		/*
    		 * <more case statements>
    		 * 
    		 * */
    		
    		default:
    			// play a generic effect on any tags not explicit above
    			wait( level.TIMESTEP );
    			PlayFXOnTag( level._effect[ "water_bubble_cloud_descent_med" ], self, tag_name );
    			break;
    	}
    }
}

	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ice_breach_process_enemy_fx()
{
	//IPrintLnBold ( "EMIT" );
	wait( 0.75 );
	playfxontag( level._effect[ "water_bubble_cloud_descent_med" ], self, "j_mainroot" );
	playfxontag( level._effect[ "water_bubble_cloud_descent_med" ], self, "J_Ankle_ri" );
	playfxontag( level._effect[ "water_bubble_cloud_descent_med" ], self, "J_Ankle_LE" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
infil_lights_and_vision()
{
	
	flag_wait("flag_swim_breach_detonate");
	wait 1;
	vision_set_fog_changes("black_ice_infil_bright", 1.3);
	overhead_lights = GetEntArray("light_infil_script_top","targetname");
	foreach(light in overhead_lights)
	{
		thread light_brighten(light);
	}
	
	//wait for notify, becuase underwater is already pretty particle dense
	level waittill ( "notify_icehole_godrays" );
	
	exploder( "intro_icehole_godray" );
	
	level waittill ( "player_water_breach" );
	
	
	stop_exploder( "intro_icehole_godray" );
	
	//overhead_light SetLightIntensity(0.001);
	//overhead_light SetLightRadius( 12 );
	
	//stop_exploder( "icehole_light" );
	
	

}
light_brighten(light)
{
	current_intensity = light GetLightIntensity();
	max_intensity = 1;
	increase = 0.12;
	
	//exploder( "icehole_light");
	
	while( current_intensity < max_intensity  )
	{
	
		current_intensity = current_intensity + increase;
		
		light SetLightIntensity(current_intensity);
		
		wait( level.TIMESTEP );
		
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_surface_logic()
{	
	level waittill( "notify_swim_allow_movement" );
	
	level.player.target_swim_speed = 40;
	SetSavedDvar( "player_swimVerticalSpeed", 40.0 );
	
	//tag<CP>moved setting the player speed to adjust dynamically
	level.player thread player_lerp_swim_vars();
	thread player_swim_rubberband();
	thread player_swim_water_current_logic();
	
	//cue truck on surface so fx can settle in before player surfces
	thread 	maps\black_ice_anim::swim_truck_surface_anim();
	
	// post slomo breach tasks
	while ( !flag( "flag_swim_player_drop_tank" ) )
	{
		wait level.TIMESTEP;
	}
	
	flag_set ( "flag_player_breaching" );
	
	// spawn bravo
	if ( !IsDefined( level._bravo ) || level._bravo.size < 2 )
		maps\black_ice_util::spawn_bravo();
	
	surface_breach();
		
	flag_clear( "flag_underwater_sfx" );
	flag_set( "flag_outofwater_sfx" );
	
	thread player_post_swim();	
	
	// Temp - clear loop on breach_anim_node
	if ( IsDefined( level.breach_anim_node ) )
	{
		level.breach_anim_node notify( "stop_loop" );
	}

	if ( IsDefined( level.allies_breach_anim_node ) )
	{
		level.allies_breach_anim_node notify( "stop_loop" );
	}
	
//	battlechatter_on( "allies" );
//	battlechatter_on( "axis" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
surface_breach()
{
	// allies breaching anims
	thread maps\black_ice_anim::swim_ally_surface_anim();
	
	level.player.disableReload = true;
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player DisableWeaponSwitch();
	
	level.player.hint_active = undefined;
	
	level notify( "notify_swim_end" );
	
	thread player_water_breach_moment();

	//AUDIO -- SFX for player exiting water and heli passing
	thread maps\black_ice_audio::sfx_player_exits_water();
	thread maps\black_ice_audio::sfx_heli_over();
	
	maps\black_ice_anim::swim_player_surface_anim();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// Swaps the scuba aitype with the land aitype for allies, then removes scuba allies
scuba_ally_swap()
{	
	level waittill( "notify_ally_swim_surface_anims_done" );
	
	// perform cleanup after swap
	level.launchers_attached = true;
	
	if( IsDefined( level._allies_swim ) )
	{
		level._allies_swim = [];
		array_delete( level._allies_swim );
	}
}

scuba_surface( wTime, ai_swim, anime, ai_ground, goto_name )
{
	// init vars
	myAnimname		   = ai_ground.animname;
	ai_ground.animname = "scuba_ally";
	ai_ground ent_flag_init( "flag_camp_move_ally" );
	
	wait( wTime );
	
	// animate swimmer
	thread anim_single_solo( ai_swim, anime );
	
	// wait for player to surface
	flag_wait( "player_water_breach" );
	
	// swap swim ally with ground ally
	ai_ground ForceTeleport( ai_swim.origin, ai_swim.angles );
	ai_ground Attach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
	
	// save anime time & cleanup swimmer
	anim_time = ai_swim GetAnimTime( ai_swim getanim( anime ) );
	ai_swim Detach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
	ai_swim Delete();
	
	// animate ground ally
	ai_ground Show();
	thread anim_single_solo( ai_ground, anime, undefined, 0.1 );
	wait( 0.05 );
	ai_ground SetAnimTime( ai_ground getanim( anime ), anim_time );
	
	// wait for anim to finish
	wait( GetAnimLength( ai_ground getanim( anime ) ) * ( 1.0 - anim_time ) );
	
	// init ground ai
	ai_ground.animname = myAnimname;
	
	// exit if no node to go to or allies are already moving
	if( !IsDefined( goto_name ) || ai_ground ent_flag( "flag_camp_move_ally" ) )
		return;
	
	// get ready to move
	react_dist = ai_ground.newEnemyReactionDistSq;
	ai_ground.newEnemyReactionDistSq = 0;
	ai_ground disable_ai_color();
	
	// move
	ai_ground thread follow_path( GetNode( goto_name, "targetname" ) );
	
	// wait to go to colors
	ai_ground ent_flag_wait( "flag_camp_move_ally" );
	ai_ground notify( "stop_going_to_node" );
	ai_ground enable_ai_color();
	
	while( 1 )
	{
		closest = get_closest_ai( ai_ground.origin, "axis" );
		
		if( IsDefined( closest ) )
		{
			dist = DistanceSquared( ai_ground.origin, closest.origin );
			
			if( dist > react_dist )
			{
				ai_ground.newEnemyReactionDistSq = react_dist;
				break;
			}
		}
		
		wait( 0.1 );
	}
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
bravo_post_snake_cam( wTime, bravo, goto_name, anime )
{
	// self is level.allies_breach_anim_node
	
	// init vars
	bravo ent_flag_init( "flag_camp_move_ally" );
	
	wait( wTime );
	
	tele_node = GetNode( goto_name, "targetname" );
	bravo ForceTeleport( tele_node.origin, tele_node.angles );
	
	bravo Attach( level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
	
	bravo Show();
	
	if ( IsDefined( anime ) )
	{
		myAnimname = bravo.animname;
		bravo.animname = "scuba_ally";
	
		self thread anim_single_solo( bravo, anime );
		
		// wait for anim to finish
		wait( GetAnimLength( bravo getanim( anime ) ) );
	
		// reset animname
		bravo.animname = myAnimname;
	}
	
	// exit if no node to go to or allies are already moving
	if( !IsDefined( goto_name ) || bravo ent_flag( "flag_camp_move_ally" ) )
		return;
	
	// get ready to move
	react_dist = bravo.newEnemyReactionDistSq;
	bravo.newEnemyReactionDistSq = 0;
	bravo disable_ai_color();
	
	// move
	bravo thread follow_path( tele_node );
	
	// wait to go to colors
	bravo ent_flag_wait( "flag_camp_move_ally" );
	bravo notify( "stop_going_to_node" );
	bravo enable_ai_color();
	
	while( 1 )
	{
		closest = get_closest_ai( bravo.origin, "axis" );
		
		if ( IsDefined( closest ) )
		{
			dist = DistanceSquared( bravo.origin, closest.origin );
			
			if ( dist > react_dist )
			{
				bravo.newEnemyReactionDistSq = react_dist;
				break;
			}
		}
		
		wait( 0.1 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
wait_till_breach_end_conditions()
{
	level waittill( "notify_swim_end_breach" );
	
	// tagBR< note > This will need to be put back in once the ally breach anims are updated to kill all the enemies
	//while ( !flag( "flag_all_enemies_dead" ) )
	//{
	//	wait level.TIMESTEP;
	//}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_water_breach_moment()
{
	while ( !flag( "player_water_breach" ) )
	{
		wait level.TIMESTEP;
	}
	
	// player just pushed through surface of water
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_post_swim()
{
	maps\black_ice_util::player_animated_sequence_cleanup();
	level.player AllowSwim( false );
	level.player DisableSlowAim();
	
	if ( IsDefined( level.player_scuba ) )
	{
		level.player_scuba Delete();
		level.player_scuba = undefined;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ice_breach_process_enemy( index )
{
	// 2 ways to kick the enemy into their death anim:
	self thread ice_breach_process_enemy_anim( index ); // current anim gets to the end
	self thread ice_breach_process_enemy_dmg( index ); // enemy gets shot
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ice_breach_process_enemy_anim( index )
{
	self endon( "death" );
	
	while ( !( self maps\black_ice_util::check_anim_time( self.animname, "introbreach_opfor" + index, 1.0 ) ) )
	{
		wait level.TIMESTEP;
	}
	
	if ( IsDefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
	{
		self stop_magic_bullet_shield();
	}
	
	self.allowdeath = true;
	self Kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
ice_breach_process_enemy_dmg( index )
{
	self endon( "death" );
	
	self waittill( "damage", amount, attacker, direction, point, damage_type );

	if ( damage_type != "MOD_EXPLOSIVE" )
	{
		if ( direction != ( 0, 0, 0 ) )
		{
			PlayFX( getfx( "swim_ai_blood_impact" ), point, direction );
		}
	}
	
	if ( IsDefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
	{
		self stop_magic_bullet_shield();
	}
	
	self.allowdeath = true;
	self Kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
props_cleanup()
{
	// post-breach cleanup of all non-persistent ice breach props
	level.breach_vehicles["gaztiger"] thread prop_destroy( level.breach_anim_node, "intro_breach", maps\black_ice_fx::turn_off_gaztiger_underwater_lights_fx );
	//level.breach_vehicles["bm21_1"] thread prop_destroy( level.breach_anim_node, "intro_breach", maps\black_ice_fx::intro_turn_off_prop_bm21_1_lights_fx );
	level.breach_vehicles["bm21_2"] thread prop_destroy( level.breach_anim_node, "intro_breach", maps\black_ice_fx::turn_off_bm21_2_underwater_lights_fx );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
prop_destroy( caller, anime, extra_cleanup_func )
{
	// Wait until the animation completes then destroy them
	caller waittill( anime );
	
	if ( IsDefined( extra_cleanup_func ) )
	{
		[[extra_cleanup_func]]();
	}

	self Delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
destroy_persistent_ice_breach_props()
{
	if ( IsDefined( level.tag_anim_rig_models ) )
	{
		for ( i = 0; i < level.tag_anim_rig_models.size; i++ )
		{
			level.tag_anim_rig_models[i] Delete();
		}
	}
	
	if ( IsDefined( level.breach_props ) )
	{
		if ( IsDefined( level.breach_props["ice_chunks1"] ) )
		{
			level.breach_props["ice_chunks1"] Delete();
		}
			
		//if ( IsDefined( level.breach_props["ice_chunks2"] ) )
		//{
		//	level.breach_props["ice_chunks2"] Delete();
		//}
				
		if ( IsDefined( level.breach_props["breach_water"] ) )
		{
			level.breach_props["breach_water"] Delete();
		}
		
		if ( IsDefined( level.breach_props["introbreach_props"] ) )
		{
			level.breach_props[ "introbreach_props" ] Delete();
		}
	}
	
	if ( IsDefined( level.breach_vehicles ) )
	{
		if ( IsDefined( level.breach_vehicles["bm21_1"] ) )
		{
			//maps\black_ice_fx::intro_turn_off_prop_bm21_1_lights_fx();
			level.breach_vehicles["bm21_1"] Delete();
		}
	}
	
	if ( IsDefined( level.surface_truck ) )
    {
		maps\black_ice_anim::swim_truck_surface_destroy();
    }
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
underwater_sfx()
{
	wait 1;
	flag_wait( "flag_outofwater_sfx" );		
	flag_set( "sfx_stop_underice_rig" );
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
player_heartbeat()
{
	// self is level.player
	
	level endon( "stop_player_heartbeat" );
	
	while ( 1 )
	{
		self PlayLocalSound( "breathing_heartbeat" );
		wait .5;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
check_analog_movement()
{
	analog_input = level.player GetNormalizedMovement();
	
	if( ( analog_input[0] ) == 0 && ( analog_input[1] == 0 ) )
	{
		return false;
	}
	else
	{
		return true;
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
retarget_breach_water()
{
	self RetargetScriptModelLighting(GetEnt("infil_lighttarget","targetname"));
}
set_snakecam_dof()
{
	maps\_art::dof_set_base( 0, 1, 6, 1000, 7000, 0.4, 0 );
	maps\_art::dof_enable_script( 0, 211.65, 8, 10000, 30000, 0.3, 2.0 );
	
	level waittill( "flag_snake_cam_below_water" );
	maps\_art::dof_enable_script( 0, 35, 4, 786, 1903, 10, 0.1 );
	level waittill("flag_player_breaching");
	//IPrintLn("disable dof");
	maps\_art::dof_disable_script(1);
	
}
