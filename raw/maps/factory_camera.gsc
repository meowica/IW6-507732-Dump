#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;

// Flags
// Start Flag:		"start_camera_moment"
// Player Used: 	"player_using_camera"
// End Flag:		"sat_confirmed"

// Notifies
// Player +Use:		"use_binoculars"
// Player -Use:		"stop_using_binoculars"

sat_room_camera()
{
	flag_wait( "start_camera_moment" );

	// Extra camera control mechanics
	level.camera_highlight = true;
	level.camera_require_scan = false;

	// Give the player the camera
	level.player give_camera();
	thread sat_camera_monitor();
}


// Main camera logic thread for SAT room
sat_camera_monitor()
{
	thread camera_activate_hint( 0.25, "camera_use", "give_use_hint_if_needed" );
	thread sat_nag_camera( "camera_used" );
	
	flag_wait( "player_using_camera" );

	// Auto aim
	//level.player sat_camera_auto_aim();

	level notify( "camera_used" );
	
	//thread intro_check_binocular_scan();

	setup_camera_feedback_system();

	flag_wait( "sat_begin_looking_for_A" );

	// Nag if the player closes their camera
	level.player thread camera_disabled_nag();

	// TARGET A
	ent = GetEnt( "sat_target_A", "targetname" );
	level.sat_current_target = ent;
	level.player thread sat_camera_proximity_scan( ent );
	level.player thread sat_camera_feedback( ent );
	level.player sat_camera_found_target( ent );
	flag_set( "cam_A_confirmed" );

	wait 3.0;

	// TARGET B
	flag_wait( "sat_begin_looking_for_B" );
	thread remove_tagged_entities();

	ent = GetEnt( "sat_target_B", "targetname" );
	level.sat_current_target = ent;
	level.player thread sat_camera_proximity_scan( ent );
	level.player thread sat_camera_feedback( ent );
	level.player sat_camera_found_target( ent );
	flag_set( "cam_B_confirmed" );
	level notify( "stop_nag" );

	wait 8.0;
	level.sat_current_target = undefined;

	// TARGET C
	flag_wait( "sat_begin_looking_for_C" );
	thread remove_tagged_entities();
	ent = GetEnt( "sat_target_C", "targetname" );
	level.sat_current_target = ent;

	flag_wait( "cam_C_confirmed" );
	level notify( "stop_nag" );
	level.sat_current_target = undefined;
}

// Setup the realtime feedback system
setup_camera_feedback_system()
{
	// RIGHT
	level.sat_feedback_right = [
		"factory_hqr_abitmoreto",
		"factory_hqr_overtotheright"
	];

	// RIGHT DOWN
	level.sat_feedback_right_down = [
		"factory_hqr_itsdownandto",
		"factory_hqr_downandalittle"
	];

	// RIGHT UP
	level.sat_feedback_right_up = [
		"factory_hqr_lookupanda",
		"factory_hqr_upandright"
	];

	// LEFT
	level.sat_feedback_left = [
		"factory_hqr_itstoyourleft",
		"factory_hqr_moretoyourleft"
	];

	// LEFT DOWN
	level.sat_feedback_left_down = [
		"factory_hqr_lookalittlelower",
		"factory_hqr_belowthattothe"
	];

	// LEFT UP
	level.sat_feedback_left_up = [
		"factory_hqr_itstoyourleft_2",
		"factory_hqr_leftandabovethat"
	];

	// DOWN
	level.sat_feedback_down = [
		"factory_hqr_yourelookingtoohigh",
		"factory_hqr_downlower"
	];

	// UP
	level.sat_feedback_up = [
		"factory_hqr_upabithigher",
		"factory_hqr_abovethat"
	];

	// BEHIND
	level.sat_feedback_behind = [
		"factory_hqr_turnarounditsbehind",
		"factory_hqr_icantseeit"
	];

	// PODS
	level.sat_feedback_pods = [
		"factory_hqr_thercslooklike",
		"factory_hqr_itshouldbea"
	];
	
	// RODS
	level.sat_feedback_rods = [
		"factory_hqr_lookfortherods",
		"factory_hqr_getoneofthe"
	];
	
	// FOUND IT
	level.sat_feedback_found = [
		"factory_hqr_bingo",
		"factory_hqr_righttherethatsit"
	];
}

// Get orientation data for where the player is looking
sat_camera_proximity_scan( ent )
{
	level endon( "found_sat_target" );

	while( 1 )
	{
		eye_pos = level.player GetEye();
		eye_angles = level.player GetPlayerAngles();
		playerToTarget = VectorNormalize( ent.origin - eye_pos );
		playerViewUp = AnglesToUp( eye_angles );
		playerViewRight = AnglesToRight( level.player.angles );
		playerViewForward = AnglesToForward( level.player.angles );

		self.cam_offsetRight = VectorDot( playerToTarget, playerViewRight );
		self.cam_offsetUp = VectorDot( playerToTarget, playerViewUp );
		self.cam_offsetForward = VectorDot( playerToTarget, playerViewForward );

		//iprintln( "x: " + round_float( self.cam_offsetRight, 2 ) + ", y: " + round_float( self.cam_offsetUp, 2 ) + ", z: " + round_float( self.cam_offsetForward, 2 ));

		wait 0.1;
	}
}

// Give feedback on where to look
sat_camera_feedback( ent )
{
	level endon( "found_sat_target" );

	// Keep track of current hint
	level.camera_feedback_active = true;

	// Precision limit
	precision = 0.15;


	while( 1 )
	{
		// Make sure camera is active
		while( self.binoculars_active == false )
		{
			wait 0.1;
		}


		// Behind you
		if( self.cam_offsetForward <= -0.5 )
		{
			sat_give_feedback( level.sat_feedback_behind );
		}

		// RIGHT
		else if( self.cam_offsetRight >= precision )
		{
			if( self.cam_offsetUp <= ( -1 * precision ))
			{
				sat_give_feedback( level.sat_feedback_right_down );
			}
			else if( self.cam_offsetUp >= precision )
			{
				sat_give_feedback( level.sat_feedback_right_up );
			}
			else
			{
				sat_give_feedback( level.sat_feedback_right );
			}
		}
		// LEFT
		else if( self.cam_offsetRight <= ( -1 * precision ))
		{
			if( self.cam_offsetUp <= ( -1 * precision ))
			{
				sat_give_feedback( level.sat_feedback_left_down );
			}
			else if( self.cam_offsetUp >= precision )
			{
				sat_give_feedback( level.sat_feedback_left_up );
			}
			else
			{
				sat_give_feedback( level.sat_feedback_left );
			}
		}
		// MIDDLE
		else
		{
			if( self.cam_offsetUp <= ( -1 * precision ))
			{
				sat_give_feedback( level.sat_feedback_down );
			}
			else if( self.cam_offsetUp >= precision )
			{
				sat_give_feedback( level.sat_feedback_up );
			}
		}

		wait RandomFloatRange( 2.5, 4.0 );
	}
}

// Play the feedback VO line
sat_give_feedback( feedback_array )
{
	lines_array = [];

	// Add in objective specific lines with the generic lines
	if ( !flag( "cam_A_confirmed" ) )
	{
		lines_array = array_combine( feedback_array, level.sat_feedback_pods );
		// JR - Adding the direction lines again just to reduce the chance of the specific lines repeating
		lines_array = array_combine( feedback_array, lines_array );
	}
	else
	{
		lines_array = array_combine( feedback_array, level.sat_feedback_rods );
		// JR - Adding the direction lines again just to reduce the chance of the specific lines repeating
		lines_array = array_combine( feedback_array, lines_array );
	}

	thread smart_radio_dialogue( lines_array[ RandomInt( lines_array.size ) ] );
}

// Check if the player is looking directly at the target
sat_camera_found_target( ent )
{
	// TODO - needs an endon

	while( 1 )
	{
		// Make sure camera is active
		while( self.binoculars_active == false )
		{
			wait 0.1;
		}

		// Raytrace to the target object
		if ( IsDefined( self.binoculars_trace[ "entity" ] ) && isDefined( self.binoculars_trace[ "entity" ].targetname ) &&
		    self.binoculars_trace[ "entity" ].targetname == ent.target )
		{
			thread maps\factory_audio::aud_binoculars_on_target();
			
			wait 0.75;
			
			// Found it! VO
			if( !flag( "cam_A_confirmed" ))
			{
				thread smart_radio_dialogue_interrupt( level.sat_feedback_found[0] );
			}
			else
			{
				thread smart_radio_dialogue_interrupt( level.sat_feedback_found[1] );
			}
			
			level notify( "found_sat_target" );
			level.camera_feedback_active = false;
			return;
		}
		wait 0.1;
	}
}


// Auto aim at correct area
/*
sat_camera_auto_aim()
{
	linker		 = self spawn_tag_origin();
	linker.origin = linker.origin + ( 0, 0, 0.5 );
	
	// Initial zoom target
	binoc_target = GetEnt( "initial_camera_lock_node", "script_noteworthy" );

	// getting vector between tag origin and desired target
	angle_to_roof = VectorToAngles( binoc_target.origin - linker.origin );
	
	// setting tag origin angle to desired angle
	linker.angles = angle_to_roof;
	
	// where is player looking
	player_angles = self GetGunAngles();
	
	// determining how far off player's view is from desired angle to adjust blend time
	view_diff = abs( angle_to_roof[ 1 ] - player_angles[ 1 ] );
	//IPrintLnBold( view_diff + " is yaw difference between player view and desired view." );
	
	if ( view_diff <= 10 )
	{
		blend_time = 1;
	}
	else
	{
		blend_time = 1;
		for ( i = 0; i < view_diff; i++ )
		{
			blend_time += .001; // .0115	
		}
	}
		
	waittillframeend;
	self PlayerLinkToBlend( linker, "tag_origin", blend_time );
	wait( blend_time + 0.25 );
	
	waittillframeend;
	self Unlink();
	
	waittillframeend;
	linker Delete();	
}
*/


//======================================================================================
// Camera Hints and VO
//======================================================================================
// Hint to scan the rods
/*
intro_check_binocular_scan()
{
	thread intro_binoculars_hint( 2, "camera_scan", undefined, "camera_scanned" );
	thread sat_nag_scan_rods();
	level.player waittill( "scanning_target" );
	level notify( "camera_scanned" );
}
*/

// Hint to turn off camera
/*
check_binocular_deactivate()
{
	thread intro_binoculars_hint( 2, "camera_deactivate", undefined, "camera_deactivated" );
	
	level.player waittill( "stop_using_binoculars" );
	level notify( "camera_deactivated" );
	
	wait 1.0;
	
	disable_camera();
}
*/

// Tooltip hint
camera_activate_hint( waittime, hintstring, flagname )
{
	level endon( "camera_used" );
	
	//this is so you can start the hint function when binoculars are given, not show the hint till needed, but kill the function if the player uses them before the hint.
	if ( IsDefined( flagname ) )
	{
		flag_wait( flagname );
	}
	
	wait( waittime );
	
	level.player thread display_hint( hintstring );
	
	while ( 1 )
	{
		wait( 5.0 );
		level.player thread display_hint( hintstring );
	}
}

intro_binoculars_hint( waittime, hintstring, flagname, endon_string )
{
	level endon( endon_string );
	
	//this is so you can start the hint function when binoculars are given, not show the hint till needed, but kill the function if the player uses them before the hint.
	if ( IsDefined( flagname ) )
	{
		flag_wait( flagname );
	}
	
	wait( waittime );
	
	// don't want to display hints if binoculars aren't equipped.
	while ( level.player.binoculars_active == false )
	{
		waitframe();
	}
	
	level.player thread display_hint( hintstring );
	
	while ( 1 )
	{
		wait( 7.0 );
		
		while ( level.player.binoculars_active == false )
		{
			waitframe();
		}	
		
		level.player thread display_hint( hintstring );
	}
}

// Hint and nag script for if player turns off the camera during feedback mechanic
camera_disabled_nag()
{
	level endon( "stop_nag" );
	nagging = false;

	// Keep track of current hint
	level.camera_feedback_active = false;

	while( 1 )
	{
		// Camera off while feedback should be happening
		if( !self.binoculars_active && level.camera_feedback_active )
		{
			if( !nagging )
			{
				nagging = true;

				// Spawn a nag VO loop
				thread sat_nag_camera( "player_using_camera" );

				wait 0.25;

				// Keep showing the hint
				while ( !flag( "player_using_camera" ))
				{
					self thread display_hint( "camera_use" );
					wait( 5.0 );
				}
				nagging = false;
			}
		}
		wait 0.1;
	}
}

// Nag the player to use the camera
sat_nag_camera( ender )
{
	lines =
	[
		// Merrick: Adam, use your camera and open a feed with Overlord.
		"factory_mrk_adamuseyourcamera",
		// Merrick: Adam, get an upload feed going with Overlord.
		"factory_mrk_adamgetanupload",
		// Merrick: Adam, we're on a schedule, get out your camera.
		"factory_mrk_adamwereona"
	];
	level.squad[ "ALLY_ALPHA" ] thread maps\factory_util::nag_line_generator( lines, ender );
}

// Nag the player to come to the CPU
sat_nag_come_to_C()
{
	lines =
	[
		// Merrick: Adam, over here.
		"factory_mrk_adamoverhere",
		// Merrick: Adam, give me a hand.
		"factory_mrk_adamgivemea",
		// Merrick: Adam, get footage of this guidance module.
		"factory_mrk_adamgetfootageof"
	];
	level.squad[ "ALLY_ALPHA" ] thread maps\factory_util::nag_line_generator( lines, "sat_do_player_anim" );
}

/*
// Nag the player to zoom in
sat_nag_zoom()
{
	thread maps\factory_util::add_debug_dialogue( "Overlord", "That's it Alpha-Zero. Can you zoom in on that?", "r" );

	lines = [	"Zoom in on the control module Alpha-Zero.",
				"Zoom in on the control module Alpha-Zero.",
				"Can you get us a closer look Alpha-Zero?",
				"Upload a close up of the control module.",
				"We need a closer look at the control module."
			 ];
	thread maps\factory_util::nag_line_generator_text( lines, "binocular_zoom", "Overlord", "r" );
}
*/


//======================================================================================
// Camera Setup
//======================================================================================
binoculars_init( default_visionset )
{
	// PreCacheShader( "cnd_binoculars_hud_overlay" );
	PreCacheShader( "cnd_binoculars_hud_id_box" );
	// PreCacheShader( "cnd_binoculars_hud_id_box_large" );
	PreCacheShader( "overlay_static" );
	PreCacheModel( "tag_turret" );
	PreCacheTurret( "player_view_controller_binoculars" );
	PreCacheShader( "fac_gfx_laser" );
	PreCacheShader( "fac_gfx_laser_light" );
	PreCacheShader( "fac_dpad_camera" );

	// New ui assets
	PreCacheShader( "fac_headcam_hud_center_01" );
	PreCacheShader( "fac_headcam_hud_corner_01" );
	PreCacheShader( "fac_headcam_hud_corner_02" );
	PreCacheShader( "fac_headcam_hud_corner_03" );
	PreCacheShader( "fac_headcam_hud_corner_04" );
	PreCacheShader( "fac_headcam_hud_focus_guides_01" );
	PreCacheShader( "fac_headcam_hud_focus_guides_02" );
	PreCacheShader( "fac_headcam_hud_rec_dot_01" );

	level.default_visionset = default_visionset;
	
	//"Press [{+actionslot 1}] to activate Camera."
	PreCacheString( &"FACTORY_CAMERA_USE_HINT" );

	//"Press [{+changezoom}] to toggle zoom."
	//PreCacheString( &"FACTORY_CAMERA_ZOOM_HINT" );

	//"Press and hold [{+attack}] to upload footage."
	PreCacheString( &"FACTORY_CAMERA_SCAN_HINT" );

	//"Press [{+actionslot 1}] to deactivate Camera."
	PreCacheString( &"FACTORY_CAMERA_REMOVE_HINT" );

	//[{+melee}] to pry open
	PreCacheString( &"FACTORY_SAT_MELEE_HINT" );

	//"&&"BUTTON_LOOK" down to pull"
	PreCacheString( &"FACTORY_SAT_PULL_HINT" );

	//"&&"BUTTON_LOOK" left to flip"
	PreCacheString( &"FACTORY_SAT_FLIP_HINT" );
	
	//"Press ^3[{+actionslot 1}]^7 to activate Camera."
	add_hint_string( "camera_use", &"FACTORY_CAMERA_USE_HINT" );

	//"Press ^3[{+changezoom}]^7 to toggle zoom."
	//add_hint_string( "camera_zoom", &"FACTORY_CAMERA_ZOOM_HINT" );

	//"Press and hold ^3[{+attack}]^7 to upload footage."
	add_hint_string( "camera_scan", &"FACTORY_CAMERA_SCAN_HINT" );

	//"Press ^3[{+actionslot 1}]^7 to deactivate Camera."
	add_hint_string( "camera_deactivate", &"FACTORY_CAMERA_REMOVE_HINT" );

	//[{+melee}] to pry open
	add_hint_string( "sat_knife", &"FACTORY_SAT_MELEE_HINT" );

	//"&&"BUTTON_MOVE" to pull"
	add_hint_string( "sat_pull_g", &"FACTORY_SAT_PULL_HINT_GAMEPAD" );

	//"&&"BUTTON_LOOK" to pull"
	add_hint_string( "sat_pull_gl", &"FACTORY_SAT_PULL_HINT_GAMEPAD_L" );

	//"Use movement keys to pull"
	add_hint_string( "sat_pull", &"FACTORY_SAT_PULL_HINT" );

	//"&&"BUTTON_MOVE" left to flip"
	add_hint_string( "sat_flip_g", &"FACTORY_SAT_FLIP_HINT_GAMEPAD" );

	//"&&"BUTTON_MOVE" left to flip"
	add_hint_string( "sat_flip_gl", &"FACTORY_SAT_FLIP_HINT_GAMEPAD_L" );

	//"Use movement keys to flip"
	add_hint_string( "sat_flip", &"FACTORY_SAT_FLIP_HINT" );
}


give_camera()
{
	if ( !IsDefined( self.has_binoculars ) || !self.has_binoculars )
	{
		self.has_binoculars = true;
		self.binoculars_active = false;
		
		level.sat_lock_target = "sat_target_A";
		level.sat_current_target = undefined;
		
		self.default_fov = GetDvarInt( "cg_fov" );
		
		self binoculars_set_default_zoom_level( 0 );

		// Apply a vision set
		//self binoculars_set_vision_set( "cornered_binoculars" );

		self binoculars_enable_zoom( true );
		
		self thread binoculars_hud();
	}
}

take_binoculars()
{
	self notify( "stop_using_binoculars" );
	self notify( "take_binoculars" );
		
	if ( IsDefined( self.binoculars_active ) && self.binoculars_active )
	{
		self binoculars_clear_hud();
	}
	
	self.has_binoculars = false;
	flag_clear( "player_using_camera" );
	self SetMoveSpeedScale( 1.0 );
	self setWeaponHudIconOverride( "actionslot1", "none" );
}

// Turn off and remove the camera
disable_camera()
{
	level.player take_binoculars();
	level.player SwitchToWeapon( level.default_weapon );
}

binoculars_set_default_zoom_level( zoom_level )
{
	self.binoculars_default_zoom_level = zoom_level;
}

binoculars_set_vision_set( vision_set )
{
	self.binoculars_vision_set = vision_set;
	
	if ( IsDefined( self.binoculars_active ) && self.binoculars_active )
	{
		self VisionSetNightForPlayer( self.binoculars_vision_set, 5.0 );
	}
}

binoculars_enable_zoom( enabled )
{
	self.binoculars_zoom_enabled = enabled;
	
	if ( IsDefined( self.binoculars_active ) && self.binoculars_active )
	{
		self.current_binocular_zoom_level = 0;
		binoculars_zoom();
	}
}

binoculars_hud()
{
	self endon( "take_binoculars" );
	
	self setWeaponHudIconOverride( "actionslot1", "fac_dpad_camera" );
	
	self NotifyOnPlayerCommand( "use_binoculars", "+actionslot 1" );
	self notifyOnPlayerCommand( "binocular_zoom", "+melee_zoom" );
	self notifyOnPlayerCommand( "fired_laser", "+frag" );
	
	self.camera_hud_item = [];
	
	while ( 1 )
	{
		// Loop to make sure player isnt jumping or falling when they use Camera
		while( 1 )
		{
			self waittill( "use_binoculars", forced );
			
			if(( self isOnGround() && !self.active_anim && !self.thermal_anim_active  ) || isDefined( forced ) )
			{
				if ( self.thermal )
				{
					maps\factory_util::turn_off_thermal_vision();
				}
				break;
			}
			wait 0.1;
		}

		flag_set( "player_using_camera" );
		self binoculars_init_hud();
		wait 1.5;
		
		// Loop so we can deny turning camera off during anims
		while( 1 )
		{
			self waittill_either( "use_binoculars", "stop_using_binoculars" );
			
			if( !self.active_anim )
			{
				break;
			}
			wait 0.1;
		}
		
		self notify( "stop_using_binoculars" );
		flag_clear( "player_using_camera" );
		
		self binoculars_clear_hud();

		wait 1.5;
	}
}

binoculars_init_hud()
{
	self endon( "take_binoculars" );

	self.binoculars_active = true;
	
	self _disableOffhandWeapons();
	//self SetMoveSpeedScale( 0.5 );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "cg_drawCrosshair", 0 );
	
	self _disableWeapon();
	self AllowMelee( false );
	
	// JR - This is no longer needed
	//self.binocular_target = Spawn( "script_model", self GetOrigin() );
	//self.binocular_target Hide();
	//self.binocular_target NotSolid();
	
	//Target_Set( self.binocular_target );
	//Target_SetShader( self.binocular_target, "cnd_binoculars_hud_id_box" );
	//Target_SetScaledRenderMode( self.binocular_target, true );
	//Target_HideFromPlayer( self.binocular_target, self );
	//Target_DrawCornersOnly( self.binocular_target, false );
	
	self thread zoom_lerp_dof();
	
	//self VisionSetNightForPlayer( self.binoculars_vision_set, 0.0 );
	//self NightVisionViewOn();
	
	//self.camera_hud_item[ "binocular_overlay" ] = create_client_overlay( "cnd_binoculars_hud_overlay", 0.25, self );
	//self.camera_hud_item[ "binocular_vignette" ] = maps\_hud_util::create_client_overlay( "cnd_binoculars_hud_vignette", 1, self );
	self.camera_hud_item[ "binocular_goggles" ] = create_client_overlay( "nightvision_overlay_goggles", 1.0, self );

	// New HUD items
	self.camera_hud_item[ "hud_center" ] = maps\_hud_util::createIcon( "fac_headcam_hud_center_01", 256, 256 );
	self.camera_hud_item[ "hud_center" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_center" ].alignX = "center";
	self.camera_hud_item[ "hud_center" ].alignY = "middle";
	self.camera_hud_item[ "hud_center" ].alpha = 1.0;

	self.camera_hud_item[ "hud_rec_dot" ] = maps\_hud_util::createIcon( "fac_headcam_hud_rec_dot_01", 32, 32 );
	self.camera_hud_item[ "hud_rec_dot" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_rec_dot" ].alignX = "center";
	self.camera_hud_item[ "hud_rec_dot" ].alignY = "middle";
	self.camera_hud_item[ "hud_rec_dot" ].horzAlign = "left";
	self.camera_hud_item[ "hud_rec_dot" ].vertAlign = "bottom";
	self.camera_hud_item[ "hud_rec_dot" ].x = 28;
	self.camera_hud_item[ "hud_rec_dot" ].y = -24;
	self.camera_hud_item[ "hud_rec_dot" ].alpha = 1.0;
	self.camera_hud_item[ "hud_rec_dot" ] thread sat_camera_rec_dot_flash( 0.66 );


	// Corner upper left
	self.camera_hud_item[ "hud_corner_01" ] = maps\_hud_util::createIcon( "fac_headcam_hud_corner_01", 128, 128 );
	self.camera_hud_item[ "hud_corner_01" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_corner_01" ].alignX = "left";
	self.camera_hud_item[ "hud_corner_01" ].alignY = "top";
	self.camera_hud_item[ "hud_corner_01" ].horzAlign = "left";
	self.camera_hud_item[ "hud_corner_01" ].vertAlign = "top";
	self.camera_hud_item[ "hud_corner_01" ].alpha = 1.0;

	self.camera_hud_item[ "hud_corner_02" ] = maps\_hud_util::createIcon( "fac_headcam_hud_corner_02", 128, 128 );
	self.camera_hud_item[ "hud_corner_02" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_corner_02" ].alignX = "right";
	self.camera_hud_item[ "hud_corner_02" ].alignY = "top";
	self.camera_hud_item[ "hud_corner_02" ].horzAlign = "right";
	self.camera_hud_item[ "hud_corner_02" ].vertAlign = "top";
	self.camera_hud_item[ "hud_corner_02" ].alpha = 1.0;

	self.camera_hud_item[ "hud_corner_03" ] = maps\_hud_util::createIcon( "fac_headcam_hud_corner_03", 128, 128 );
	self.camera_hud_item[ "hud_corner_03" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_corner_03" ].alignX = "left";
	self.camera_hud_item[ "hud_corner_03" ].alignY = "bottom";
	self.camera_hud_item[ "hud_corner_03" ].horzAlign = "left";
	self.camera_hud_item[ "hud_corner_03" ].vertAlign = "bottom";
	self.camera_hud_item[ "hud_corner_03" ].alpha = 1.0;

	self.camera_hud_item[ "hud_corner_04" ] = maps\_hud_util::createIcon( "fac_headcam_hud_corner_04", 128, 128 );
	self.camera_hud_item[ "hud_corner_04" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_corner_04" ].alignX = "right";
	self.camera_hud_item[ "hud_corner_04" ].alignY = "bottom";
	self.camera_hud_item[ "hud_corner_04" ].horzAlign = "right";
	self.camera_hud_item[ "hud_corner_04" ].vertAlign = "bottom";
	self.camera_hud_item[ "hud_corner_04" ].alpha = 1.0;

	// Guides
	self.camera_hud_item[ "hud_focus_01" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_02", 48, 48 );
	self.camera_hud_item[ "hud_focus_01" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_01" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_01" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_01" ].x = 0;
	self.camera_hud_item[ "hud_focus_01" ].y = 80;
	self.camera_hud_item[ "hud_focus_01" ].alpha = 1.0;

	self.camera_hud_item[ "hud_focus_02" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_02", 48, 48 );
	self.camera_hud_item[ "hud_focus_02" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_02" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_02" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_02" ].x = 0;
	self.camera_hud_item[ "hud_focus_02" ].y = -80;
	self.camera_hud_item[ "hud_focus_02" ].alpha = 1.0;

	self.camera_hud_item[ "hud_focus_03" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_01", 48, 48 );
	self.camera_hud_item[ "hud_focus_03" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_03" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_03" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_03" ].x = 160;
	self.camera_hud_item[ "hud_focus_03" ].y = 0;
	self.camera_hud_item[ "hud_focus_03" ].alpha = 1.0;

	self.camera_hud_item[ "hud_focus_04" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_01", 48, 48 );
	self.camera_hud_item[ "hud_focus_04" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_04" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_04" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_04" ].x = -160;
	self.camera_hud_item[ "hud_focus_04" ].y = 0;
	self.camera_hud_item[ "hud_focus_04" ].alpha = 1.0;

	self.camera_hud_item[ "hud_focus_05" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_01", 48, 48 );
	self.camera_hud_item[ "hud_focus_05" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_05" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_05" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_05" ].x = 80;
	self.camera_hud_item[ "hud_focus_05" ].y = 40;
	self.camera_hud_item[ "hud_focus_05" ].alpha = 1.0;

	self.camera_hud_item[ "hud_focus_06" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_01", 48, 48 );
	self.camera_hud_item[ "hud_focus_06" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_06" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_06" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_06" ].x = -80;
	self.camera_hud_item[ "hud_focus_06" ].y = 40;
	self.camera_hud_item[ "hud_focus_06" ].alpha = 1.0;

	self.camera_hud_item[ "hud_focus_07" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_01", 48, 48 );
	self.camera_hud_item[ "hud_focus_07" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_07" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_07" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_07" ].x = 80;
	self.camera_hud_item[ "hud_focus_07" ].y = -40;
	self.camera_hud_item[ "hud_focus_07" ].alpha = 1.0;

	self.camera_hud_item[ "hud_focus_08" ] = maps\_hud_util::createIcon( "fac_headcam_hud_focus_guides_01", 48, 48 );
	self.camera_hud_item[ "hud_focus_08" ] set_default_hud_parameters();
	self.camera_hud_item[ "hud_focus_08" ].alignX = "center";
	self.camera_hud_item[ "hud_focus_08" ].alignY = "middle";
	self.camera_hud_item[ "hud_focus_08" ].x = -80;
	self.camera_hud_item[ "hud_focus_08" ].y = -40;
	self.camera_hud_item[ "hud_focus_08" ].alpha = 1.0;
	
	//==============

	self.camera_hud_item[ "reticle_line_top" ] = maps\_hud_util::createIcon( "white", 1, 8 );
	self.camera_hud_item[ "reticle_line_top" ].target_width = 1;
	self.camera_hud_item[ "reticle_line_top" ].no_target_width = 1;
	self.camera_hud_item[ "reticle_line_top" ].target_height = 32;
	self.camera_hud_item[ "reticle_line_top" ].no_target_height= 32;
	self.camera_hud_item[ "reticle_line_top" ].target_x = 0;
	self.camera_hud_item[ "reticle_line_top" ].no_target_x = 0;
	self.camera_hud_item[ "reticle_line_top" ].target_y = -16;
	self.camera_hud_item[ "reticle_line_top" ].no_target_y= -16;
	self.camera_hud_item[ "reticle_line_top" ] set_default_hud_parameters();
	self.camera_hud_item[ "reticle_line_top" ].alignY = "bottom";
	self.camera_hud_item[ "reticle_line_top" ].alpha = 0.0;
	self.camera_hud_item[ "reticle_line_top" ].y = -27;
	
	self.camera_hud_item[ "reticle_line_bottom" ] = maps\_hud_util::createIcon( "white", 1, 8 );	
	self.camera_hud_item[ "reticle_line_bottom" ].target_width = 1;
	self.camera_hud_item[ "reticle_line_bottom" ].no_target_width = 1;
	self.camera_hud_item[ "reticle_line_bottom" ].target_height = 32;
	self.camera_hud_item[ "reticle_line_bottom" ].no_target_height= 32;
	self.camera_hud_item[ "reticle_line_bottom" ].target_x = 0;
	self.camera_hud_item[ "reticle_line_bottom" ].no_target_x = 0;
	self.camera_hud_item[ "reticle_line_bottom" ].target_y = 16;
	self.camera_hud_item[ "reticle_line_bottom" ].no_target_y= 16;
	self.camera_hud_item[ "reticle_line_bottom" ] set_default_hud_parameters();
	self.camera_hud_item[ "reticle_line_bottom" ].alignY = "top";
	self.camera_hud_item[ "reticle_line_bottom" ].alpha = 0.0;
	self.camera_hud_item[ "reticle_line_bottom" ].y = 27;
	
	self.camera_hud_item[ "reticle_line_left" ] = maps\_hud_util::createIcon( "white", 8, 1 );
	self.camera_hud_item[ "reticle_line_left" ].target_width = 32;
	self.camera_hud_item[ "reticle_line_left" ].no_target_width = 32;
	self.camera_hud_item[ "reticle_line_left" ].target_height = 1;
	self.camera_hud_item[ "reticle_line_left" ].no_target_height = 1;
	self.camera_hud_item[ "reticle_line_left" ].target_x = -16;
	self.camera_hud_item[ "reticle_line_left" ].no_target_x = -50;
	self.camera_hud_item[ "reticle_line_left" ].target_y = 0;
	self.camera_hud_item[ "reticle_line_left" ].no_target_y= 0;
	self.camera_hud_item[ "reticle_line_left" ] set_default_hud_parameters();
	self.camera_hud_item[ "reticle_line_left" ].alignX = "right";
	self.camera_hud_item[ "reticle_line_left" ].alpha = 0.0;
	self.camera_hud_item[ "reticle_line_left" ].x = -27;
	
	self.camera_hud_item[ "reticle_line_right" ] = maps\_hud_util::createIcon( "white", 8, 1 );
	self.camera_hud_item[ "reticle_line_right" ].target_width = 32;
	self.camera_hud_item[ "reticle_line_right" ].no_target_width = 32;
	self.camera_hud_item[ "reticle_line_right" ].target_height = 1;
	self.camera_hud_item[ "reticle_line_right" ].no_target_height = 1;
	self.camera_hud_item[ "reticle_line_right" ].target_x = 16;
	self.camera_hud_item[ "reticle_line_right" ].no_target_x = 50;
	self.camera_hud_item[ "reticle_line_right" ].target_y = 0;
	self.camera_hud_item[ "reticle_line_right" ].no_target_y= 0;
	self.camera_hud_item[ "reticle_line_right" ] set_default_hud_parameters();
	self.camera_hud_item[ "reticle_line_right" ].alignX = "left";
	self.camera_hud_item[ "reticle_line_right" ].alpha = 0.0;
	self.camera_hud_item[ "reticle_line_right" ].x = 27;

	self.binocular_reticle_pieces = [];
	self.binocular_reticle_pieces[ self.binocular_reticle_pieces.size ] = self.camera_hud_item[ "reticle_line_top" ];
	self.binocular_reticle_pieces[ self.binocular_reticle_pieces.size ] = self.camera_hud_item[ "reticle_line_bottom" ];
	self.binocular_reticle_pieces[ self.binocular_reticle_pieces.size ] = self.camera_hud_item[ "reticle_line_left" ];
	self.binocular_reticle_pieces[ self.binocular_reticle_pieces.size ] = self.camera_hud_item[ "reticle_line_right" ];

	zoom_background_x = -10;

	self.camera_hud_item[ "zoom_level_1" ] = createClientFontString( "default", 1.0 );	
	self.camera_hud_item[ "zoom_level_1" ] set_default_hud_parameters();
	self.camera_hud_item[ "zoom_level_1" ].alignX = "left";
	self.camera_hud_item[ "zoom_level_1" ].alignY = "top";
	self.camera_hud_item[ "zoom_level_1" ].horzAlign = "right";
	self.camera_hud_item[ "zoom_level_1" ].alpha = 1;
	self.camera_hud_item[ "zoom_level_1" ].x = zoom_background_x -18;
	self.camera_hud_item[ "zoom_level_1" ].y -= self.camera_hud_item[ "zoom_level_1" ].height * 3.5;
	self.camera_hud_item[ "zoom_level_1" ] SetText( "x1.0" );
	
	self.camera_hud_item[ "zoom_level_15" ] = createClientFontString( "default", 1.0 );	
	self.camera_hud_item[ "zoom_level_15" ] set_default_hud_parameters();
	self.camera_hud_item[ "zoom_level_15" ].alignX = "left";
	self.camera_hud_item[ "zoom_level_15" ].alignY = "top";
	self.camera_hud_item[ "zoom_level_15" ].horzAlign = "right";
	self.camera_hud_item[ "zoom_level_15" ].alpha = 0.25;
	self.camera_hud_item[ "zoom_level_15" ].x = zoom_background_x -18;
	self.camera_hud_item[ "zoom_level_15" ].y -= self.camera_hud_item[ "zoom_level_15" ].height * 1.5;
	self.camera_hud_item[ "zoom_level_15" ] SetText( "x1.5" );
	
	self.camera_hud_item[ "zoom_level_24" ] = createClientFontString( "default", 1.0 );	
	self.camera_hud_item[ "zoom_level_24" ] set_default_hud_parameters();
	self.camera_hud_item[ "zoom_level_24" ].alignX = "left";
	self.camera_hud_item[ "zoom_level_24" ].alignY = "top";
	self.camera_hud_item[ "zoom_level_24" ].horzAlign = "right";
	self.camera_hud_item[ "zoom_level_24" ].alpha = 0.25;
	self.camera_hud_item[ "zoom_level_24" ].x = zoom_background_x -18;
	self.camera_hud_item[ "zoom_level_24" ].y = self.camera_hud_item[ "zoom_level_24" ].height * 0.5;
	self.camera_hud_item[ "zoom_level_24" ] SetText( "x2.4" );
	
	self.camera_hud_item[ "zoom_level_40" ] = createClientFontString( "default", 1.0 );	
	self.camera_hud_item[ "zoom_level_40" ] set_default_hud_parameters();
	self.camera_hud_item[ "zoom_level_40" ].alignX = "left";
	self.camera_hud_item[ "zoom_level_40" ].alignY = "top";
	self.camera_hud_item[ "zoom_level_40" ].horzAlign = "right";
	self.camera_hud_item[ "zoom_level_40" ].alpha = 0.25;
	self.camera_hud_item[ "zoom_level_40" ].x = zoom_background_x -18;
	self.camera_hud_item[ "zoom_level_40" ].y = self.camera_hud_item[ "zoom_level_40" ].height * 2.5;
	self.camera_hud_item[ "zoom_level_40" ] SetText( "x6.0" );
	
	self.camera_hud_item[ "zoom_level_background" ] = maps\_hud_util::createIcon( "white", 20, self.camera_hud_item[ "zoom_level_40" ].height * 8 );
	self.camera_hud_item[ "zoom_level_background" ] set_default_hud_parameters();
	self.camera_hud_item[ "zoom_level_background" ].alignX = "left";
	self.camera_hud_item[ "zoom_level_background" ].alignY = "middle";
	self.camera_hud_item[ "zoom_level_background" ].horzAlign = "right";
	self.camera_hud_item[ "zoom_level_background" ].alpha = 0.1;
	self.camera_hud_item[ "zoom_level_background" ].x = zoom_background_x - self.camera_hud_item[ "zoom_level_background" ].width;
	self.camera_hud_item[ "zoom_level_background" ].sort = self.camera_hud_item[ "zoom_level_40" ].sort - 1;
	
	self.camera_hud_item[ "recognition_system" ] = createClientFontString( "default", 1.0 );	
	self.camera_hud_item[ "recognition_system" ] set_default_hud_parameters();
	self.camera_hud_item[ "recognition_system" ].alignX = "left";
	self.camera_hud_item[ "recognition_system" ].alignY = "top";
	self.camera_hud_item[ "recognition_system" ].vertAlign = "bottom";
	self.camera_hud_item[ "recognition_system" ].alpha = 0.25;
	self.camera_hud_item[ "recognition_system" ].x = -190; //200
	self.camera_hud_item[ "recognition_system" ].y = -14;
	self.camera_hud_item[ "recognition_system" ] SetText( "RECOGNITION SYSTEM ACTIVE" );
	
	self.camera_hud_item[ "target_system" ] = createClientFontString( "default", 1.0 );	
	self.camera_hud_item[ "target_system" ] set_default_hud_parameters();
	self.camera_hud_item[ "target_system" ].alignX = "right";
	self.camera_hud_item[ "target_system" ].alignY = "top";
	self.camera_hud_item[ "target_system" ].vertAlign = "bottom";
	self.camera_hud_item[ "target_system" ].alpha = 1.0;
	self.camera_hud_item[ "target_system" ].x = 190; //200
	self.camera_hud_item[ "target_system" ].y = -14;
	self.camera_hud_item[ "target_system" ] SetText( "TARGET SYSTEM ACTIVE" );
	
	self.camera_hud_item[ "bottom_bar" ] = maps\_hud_util::createIcon( "white", 400, 16 );
	self.camera_hud_item[ "bottom_bar" ] set_default_hud_parameters();
	self.camera_hud_item[ "bottom_bar" ].alignX = "center";
	self.camera_hud_item[ "bottom_bar" ].alignY = "bottom";
	self.camera_hud_item[ "bottom_bar" ].horzAlign = "center";
	self.camera_hud_item[ "bottom_bar" ].vertAlign = "bottom";
	self.camera_hud_item[ "bottom_bar" ].alpha = 0.1;
	self.camera_hud_item[ "bottom_bar" ].sort = self.camera_hud_item[ "recognition_system" ].sort - 1;
	
	self thread maps\factory_audio::aud_binoculars_vision_on();
	self thread maps\factory_audio::aud_binoculars_bg_loop();
	
	// Displays range of raytrace
	self thread binoculars_calculate_range();

	// Static UI effect
	self thread static_overlay();
	
	// Button press scan mechanic
	self thread binoculars_monitor_scanning();

	// Button press zoom
	self thread monitor_binoculars_variable_zoom();

	// Displays heading angles up top
	self thread binoculars_angles_display();
	
	// Adds the targeting boxes on rods
	self thread setup_tagged_entities();

	// Changes the reticule when on target
	self thread sat_camera_reticule();
}

// Flash the dot
sat_camera_rec_dot_flash( time )
{
	self endon( "death" );

	while( 1 )
	{
		if( !isDefined( self ))
		{
			return;
		}
		self.alpha = 0.0;
		wait time;
		if( !isDefined( self ))
		{
			return;
		}
		self.alpha = 1.0;
		wait time;
	}
}

binoculars_clear_hud()
{
	self.binoculars_active = false;

	self thread maps\factory_audio::aud_binoculars_vision_off();
	self notify( "stop_binocular_bg_loop_sound" );
	self notify( "cancel_laser" );
	
	//self binoculars_unlock_from_target();
	self thread static_overlay_off();
	self thread zoom_lerp_dof();

	self AllowMelee( true );
	self _enableOffhandWeapons();
	//self SetMoveSpeedScale( 1.0 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "cg_drawCrosshair", 1 );
	
	self _enableWeapon();
	
	keys = getArrayKeys( self.camera_hud_item );
	foreach ( key in keys )
	{
		self.camera_hud_item[ key ] Destroy();
		self.camera_hud_item[ key ] = undefined;
	}
	
	//if ( Target_IsTarget( self.binocular_target ) )
	//{
	//	Target_Remove( self.binocular_target );
	//}
	
	// Remove target boxes on objective items
	thread remove_tagged_entities();

	//self.binocular_target Delete();
	//self.binocular_target = undefined;
		
	maps\_art::dof_disable_script( 0.0 );
	
	SetSavedDvar( "cg_fov", self.default_fov );
	
	self NightVisionViewOff();
}

binoculars_calculate_range()
{
	self endon( "stop_using_binoculars" );
	self endon( "binoculars_hud_off" );
	self endon( "take_binoculars" );
	
	self.camera_hud_item[ "range" ] = self maps\_hud_util::createClientFontString( "default", 1.0 );
	self.camera_hud_item[ "range" ].x = 0;
	self.camera_hud_item[ "range" ].y = 2 - self.camera_hud_item[ "bottom_bar" ].height;
	self.camera_hud_item[ "range" ].alignX = "center";
	self.camera_hud_item[ "range" ].alignY = "top";
	self.camera_hud_item[ "range" ].horzAlign = "center";
	self.camera_hud_item[ "range" ].vertAlign = "bottom";
	self.camera_hud_item[ "range" ].color = ( 1.0, 1.0, 1.0 );
	self.camera_hud_item[ "range" ].alpha = 1.0;
	
	while ( 1 )
	{
		forward = AnglesToForward( self GetPlayerAngles() );
		
		if ( self IsLinked() && IsDefined( self.linked_world_space_forward ) )
		{
			forward = self.linked_world_space_forward;
		}
		
		self.binoculars_trace = BulletTrace( self GetEye(), self GetEye() + forward * 50000, true, self, true );
		
		while ( IsDefined( self.binoculars_trace[ "surfacetype" ] ) && self.binoculars_trace[ "surfacetype" ] == "glass" )
		{
			self.binoculars_trace = BulletTrace( self.binoculars_trace[ "position" ] + forward * 20, self.binoculars_trace[ "position" ] + forward * 50000, true, self );
		}
		
		range = Distance( self GetEye(), self.binoculars_trace[ "position" ] );
		range *= 0.0254;
		range = Int( range * 100 ) * 0.01;
		
		if ( range > 1000.0 )
		{
			// Show infinity symbol
			self.camera_hud_item[ "range" ] SetText( "RANGE 1000+ M" );
		}
		else
		{
			if ( range - Int( range ) == 0.0 )
			{
				self.camera_hud_item[ "range" ] SetText( "RANGE " + range + ".00 M" );
			}
			else if ( ( range * 10 ) - Int( range * 10 ) == 0.0 )
			{
				self.camera_hud_item[ "range" ] SetText( "RANGE " + range + "0 M" );
			}
			else
			{
				self.camera_hud_item[ "range" ] SetText("RANGE " +  range + " M" );
			}
		}
		
		wait 0.05;
	}
}

binoculars_lock_to_target( targ )
{
	if ( !self IsLinked() )
	{
		self.binoculars_linked_to_target = true;
		
		if ( !IsDefined( self.player_view_controller_model ) )
		{
			self.player_view_controller_model = Spawn( "script_model", self.origin );
			self.player_view_controller_model SetModel( "tag_origin" );
		}
		
		self.player_view_controller_model.origin = self.origin;
		self.player_view_controller_model.angles = self GetPlayerAngles();
		
		if ( !IsDefined( self.player_view_controller ) )
		{
			self.player_view_controller = get_player_view_controller( self.player_view_controller_model, "tag_origin", ( 0, 0, 0 ), "player_view_controller_binoculars" );
		}
		
		if ( !IsDefined( self.turret_look_at_ent ) )
		{
			self.turret_look_at_ent = Spawn( "script_model", self.origin );
			self.turret_look_at_ent SetModel( "tag_origin" );
		}
		
		self.turret_look_at_ent.origin = self.origin + ( AnglesToForward( self GetPlayerAngles() ) * 1000 );
		
		self.player_view_controller SnapToTargetEntity( self.turret_look_at_ent );
		
		self.prev_origin = self.origin;
		
		//self PlayerLinkToAbsolute( self.player_view_controller, "tag_aim" );
		self PlayerLinkToDelta( self.player_view_controller, "tag_aim", 0.0, 0,0,0,0,true );
		self.player_view_controller SetTargetEntity( targ, self.origin - self GetEye() );
	}
}

binoculars_unlock_from_target()
{
	if ( IsDefined( self.binoculars_linked_to_target ) && self.binoculars_linked_to_target )
	{
		self Unlink();
		self.binoculars_linked_to_target = false;
		
		if ( IsDefined( self.prev_origin ) )
		{
			self SetOrigin( self.prev_origin );
			self.prev_origin = undefined;
		}
		
		if ( IsDefined( self.player_view_controller ) )
		{
			self.player_view_controller Delete();
			self.player_view_controller = undefined;
		}
		
		if ( IsDefined( self.player_view_controller_model ) )
		{
			self.player_view_controller_model Delete();
			self.player_view_controller_model = undefined;
		}
		
		if ( IsDefined( self.turret_look_at_ent ) )
		{
			self.turret_look_at_ent Delete();
			self.turret_look_at_ent = undefined;
		}
	}
}

binocular_face_scanning( targ )
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	self endon( "stop_scanning" );
	self endon( "scanning_complete" );
	
	self.camera_hud_item[ "profile" ] = maps\_hud_util::createIcon( "white", 128, 128 );
	self.camera_hud_item[ "profile" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile" ].alignX = "left";
	self.camera_hud_item[ "profile" ].alignY = "middle";
	self.camera_hud_item[ "profile" ].horzAlign = "left";
	self.camera_hud_item[ "profile" ].vertAlign = "middle";
	self.camera_hud_item[ "profile" ].x = 0;
	self.camera_hud_item[ "profile" ].y = 50;
	self.camera_hud_item[ "profile" ].alpha = 0.9;
}

binocular_face_scanning_data()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	self.camera_hud_item[ "profile_data_line_1" ] = maps\_hud_util::createIcon( "white", self.camera_hud_item[ "profile" ].width, 10 );
	self.camera_hud_item[ "profile_data_line_1" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_line_1" ].alignX = "left";
	self.camera_hud_item[ "profile_data_line_1" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_line_1" ].x = 0;
	self.camera_hud_item[ "profile_data_line_1" ].y = 10 + self.camera_hud_item[ "profile" ].y + self.camera_hud_item[ "profile" ].height * 0.5;
	self.camera_hud_item[ "profile_data_line_1" ].alpha = 0.25;
	
	self.camera_hud_item[ "profile_data_line_2" ] = maps\_hud_util::createIcon( "white", self.camera_hud_item[ "profile" ].width, 10 );
	self.camera_hud_item[ "profile_data_line_2" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_line_2" ].alignX = "left";
	self.camera_hud_item[ "profile_data_line_2" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_line_2" ].x = 0;
	self.camera_hud_item[ "profile_data_line_2" ].y = self.camera_hud_item[ "profile_data_line_1" ].y + self.camera_hud_item[ "profile_data_line_1" ].height;
	self.camera_hud_item[ "profile_data_line_2" ].alpha = 0.15;
	
	self.camera_hud_item[ "profile_data_line_3" ] = maps\_hud_util::createIcon( "white", self.camera_hud_item[ "profile" ].width, 10 );
	self.camera_hud_item[ "profile_data_line_3" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_line_3" ].alignX = "left";
	self.camera_hud_item[ "profile_data_line_3" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_line_3" ].x = 0;
	self.camera_hud_item[ "profile_data_line_3" ].y = self.camera_hud_item[ "profile_data_line_2" ].y + self.camera_hud_item[ "profile_data_line_2" ].height;
	self.camera_hud_item[ "profile_data_line_3" ].alpha = 0.25;
	
	//self.camera_hud_item[ "profile_data_line_4" ] = maps\_hud_util::createIcon( "white", self.camera_hud_item[ "profile" ].width, 10 );
	//self.camera_hud_item[ "profile_data_line_4" ] set_default_hud_parameters();
	//self.camera_hud_item[ "profile_data_line_4" ].alignX = "left";
	//self.camera_hud_item[ "profile_data_line_4" ].horzAlign = "left";
	//self.camera_hud_item[ "profile_data_line_4" ].x = 0;
	//self.camera_hud_item[ "profile_data_line_4" ].y = self.camera_hud_item[ "profile_data_line_3" ].y + self.camera_hud_item[ "profile_data_line_3" ].height;
	//self.camera_hud_item[ "profile_data_line_4" ].alpha = 0.15;
	
	//self.camera_hud_item[ "profile_data_line_5" ] = maps\_hud_util::createIcon( "white", self.camera_hud_item[ "profile" ].width, 10 );
	//self.camera_hud_item[ "profile_data_line_5" ] set_default_hud_parameters();
	//self.camera_hud_item[ "profile_data_line_5" ].alignX = "left";
	//self.camera_hud_item[ "profile_data_line_5" ].horzAlign = "left";
	//self.camera_hud_item[ "profile_data_line_5" ].x = 0;
	//self.camera_hud_item[ "profile_data_line_5" ].y = self.camera_hud_item[ "profile_data_line_4" ].y + self.camera_hud_item[ "profile_data_line_4" ].height;
	//self.camera_hud_item[ "profile_data_line_5" ].alpha = 0.25;
	
	self.camera_hud_item[ "profile_data_feed_1" ] = createClientFontString( "default", 0.6 );
	self.camera_hud_item[ "profile_data_feed_1" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_feed_1" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_feed_1" ].x = self.camera_hud_item[ "profile_data_line_1" ].x + 1;
	self.camera_hud_item[ "profile_data_feed_1" ].y = self.camera_hud_item[ "profile_data_line_1" ].y;
	self.camera_hud_item[ "profile_data_feed_1" ].alpha = 0.75;
	self.camera_hud_item[ "profile_data_feed_1" ].defaultText = "FEED " + RandomIntRange( 10, 99 ) + "   --   ";
	
	self.camera_hud_item[ "profile_data_feed_2" ] = createClientFontString( "default", 0.6 );
	self.camera_hud_item[ "profile_data_feed_2" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_feed_2" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_feed_2" ].x = Int( self.camera_hud_item[ "profile_data_line_1" ].width / 2 ) + 1;
	self.camera_hud_item[ "profile_data_feed_2" ].y = self.camera_hud_item[ "profile_data_line_1" ].y;
	self.camera_hud_item[ "profile_data_feed_2" ].alpha = 0.75;
	self.camera_hud_item[ "profile_data_feed_2" ].defaultText = " FEED " + RandomIntRange( 10, 99 ) + "   --   ";
	
	self.camera_hud_item[ "profile_data_feed_3" ] = createClientFontString( "default", 0.6 );
	self.camera_hud_item[ "profile_data_feed_3" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_feed_3" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_feed_3" ].x = self.camera_hud_item[ "profile_data_line_2" ].x + 1;
	self.camera_hud_item[ "profile_data_feed_3" ].y = self.camera_hud_item[ "profile_data_line_2" ].y;
	self.camera_hud_item[ "profile_data_feed_3" ].alpha = 0.75;
	self.camera_hud_item[ "profile_data_feed_3" ].defaultText = "FEED " + RandomIntRange( 10, 99 ) + "   --   ";
	
	self.camera_hud_item[ "profile_data_feed_4" ] = createClientFontString( "default", 0.6 );
	self.camera_hud_item[ "profile_data_feed_4" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_feed_4" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_feed_4" ].x = Int( self.camera_hud_item[ "profile_data_line_2" ].width / 2 ) + 1;
	self.camera_hud_item[ "profile_data_feed_4" ].y = self.camera_hud_item[ "profile_data_line_2" ].y;
	self.camera_hud_item[ "profile_data_feed_4" ].alpha = 0.75;
	self.camera_hud_item[ "profile_data_feed_4" ].defaultText = " FEED " + RandomIntRange( 10, 99 ) + "   --   ";
	
	self.camera_hud_item[ "profile_data_feed_5" ] = createClientFontString( "default", 0.6 );
	self.camera_hud_item[ "profile_data_feed_5" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_feed_5" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_feed_5" ].x = self.camera_hud_item[ "profile_data_line_3" ].x + 1;
	self.camera_hud_item[ "profile_data_feed_5" ].y = self.camera_hud_item[ "profile_data_line_3" ].y;
	self.camera_hud_item[ "profile_data_feed_5" ].alpha = 0.75;
	self.camera_hud_item[ "profile_data_feed_5" ].defaultText = "FEED " + RandomIntRange( 1, 100 ) + "   --   ";
	
	self.camera_hud_item[ "profile_data_feed_6" ] = createClientFontString( "default", 0.6 );
	self.camera_hud_item[ "profile_data_feed_6" ] set_default_hud_parameters();
	self.camera_hud_item[ "profile_data_feed_6" ].horzAlign = "left";
	self.camera_hud_item[ "profile_data_feed_6" ].x = Int( self.camera_hud_item[ "profile_data_line_3" ].width / 2 ) + 1;
	self.camera_hud_item[ "profile_data_feed_6" ].y = self.camera_hud_item[ "profile_data_line_3" ].y;
	self.camera_hud_item[ "profile_data_feed_6" ].alpha = 0.75;
	self.camera_hud_item[ "profile_data_feed_6" ].defaultText = "FEED " + RandomIntRange( 1, 100 ) + "   --   ";
	
	self.camera_hud_item[ "upload_ellipsis_1" ] = createClientFontString( "default", 1.5 );
	self.camera_hud_item[ "upload_ellipsis_1" ] set_default_hud_parameters();
	self.camera_hud_item[ "upload_ellipsis_1" ].alignx = "left";
	self.camera_hud_item[ "upload_ellipsis_1" ].aligny = "bottom";
	self.camera_hud_item[ "upload_ellipsis_1" ].horzAlign = "left";
	self.camera_hud_item[ "upload_ellipsis_1" ].x = 0;
	self.camera_hud_item[ "upload_ellipsis_1" ].y = (( self.camera_hud_item[ "profile" ].height / 2 ) - self.camera_hud_item[ "profile" ].y + 2 ) * -1;
	self.camera_hud_item[ "upload_ellipsis_1" ].alpha = 0.9;
	self.camera_hud_item[ "upload_ellipsis_1" ] SetText( "." );
	
	self.camera_hud_item[ "upload_ellipsis_2" ] = createClientFontString( "default", 1.5 );
	self.camera_hud_item[ "upload_ellipsis_2" ] set_default_hud_parameters();
	self.camera_hud_item[ "upload_ellipsis_2" ].alignx = "left";
	self.camera_hud_item[ "upload_ellipsis_2" ].aligny = "bottom";
	self.camera_hud_item[ "upload_ellipsis_2" ].horzAlign = "left";
	self.camera_hud_item[ "upload_ellipsis_2" ].x = 0;
	self.camera_hud_item[ "upload_ellipsis_2" ].y = (( self.camera_hud_item[ "profile" ].height / 2 ) - self.camera_hud_item[ "profile" ].y + 2 ) * -1;
	self.camera_hud_item[ "upload_ellipsis_2" ].alpha = 0.3;
	self.camera_hud_item[ "upload_ellipsis_2" ] SetText( "  ." );
	
	self.camera_hud_item[ "upload_ellipsis_3" ] = createClientFontString( "default", 1.5 );
	self.camera_hud_item[ "upload_ellipsis_3" ] set_default_hud_parameters();
	self.camera_hud_item[ "upload_ellipsis_3" ].alignx = "left";
	self.camera_hud_item[ "upload_ellipsis_3" ].aligny = "bottom";
	self.camera_hud_item[ "upload_ellipsis_3" ].horzAlign = "left";
	self.camera_hud_item[ "upload_ellipsis_3" ].x = 0;
	self.camera_hud_item[ "upload_ellipsis_3" ].y = (( self.camera_hud_item[ "profile" ].height / 2 ) - self.camera_hud_item[ "profile" ].y + 2 ) * -1;
	self.camera_hud_item[ "upload_ellipsis_3" ].alpha = 0.6;
	self.camera_hud_item[ "upload_ellipsis_3" ] SetText( "    ." );
	
	self.camera_hud_item[ "secure" ] = createClientFontString( "default", 1.0 );
	self.camera_hud_item[ "secure" ] set_default_hud_parameters();
	self.camera_hud_item[ "secure" ].horzAlign = "left";
	self.camera_hud_item[ "secure" ].x = 0;
	self.camera_hud_item[ "secure" ].y = self.camera_hud_item[ "profile_data_line_3" ].y + self.camera_hud_item[ "profile_data_line_3" ].height;
	self.camera_hud_item[ "secure" ].alpha = 0.75;
	self.camera_hud_item[ "secure" ] SetText( "SECURE" );
	
	ellipsis_num = 1;
	
	update_ellipsis = false;
	feed_increments = self.binoculars_scan_time / 5;
	
	time = 0.0;
	
	feeds = [];
	feeds[ feeds.size ] = self.camera_hud_item[ "profile_data_feed_1" ];
	feeds[ feeds.size ] = self.camera_hud_item[ "profile_data_feed_2" ];
	feeds[ feeds.size ] = self.camera_hud_item[ "profile_data_feed_3" ];
	feeds[ feeds.size ] = self.camera_hud_item[ "profile_data_feed_4" ];
	feeds[ feeds.size ] = self.camera_hud_item[ "profile_data_feed_5" ];
	feeds[ feeds.size ] = self.camera_hud_item[ "profile_data_feed_6" ];

	while ( !self.binoculars_scanning_complete && !self.binoculars_stop_scanning )
	{
		if ( update_ellipsis )
		{
			ellipsis_num += 1;
			if ( ellipsis_num > 3 )
			{
				ellipsis_num = 1;
			}
			
			switch ( ellipsis_num )
			{
				case 1:
					self.camera_hud_item[ "upload_ellipsis_1" ].alpha = 0.9;
					self.camera_hud_item[ "upload_ellipsis_2" ].alpha = 0.3;
					self.camera_hud_item[ "upload_ellipsis_3" ].alpha = 0.6;
					break;
					
				case 2:
					self.camera_hud_item[ "upload_ellipsis_1" ].alpha = 0.6;
					self.camera_hud_item[ "upload_ellipsis_2" ].alpha = 0.9;
					self.camera_hud_item[ "upload_ellipsis_3" ].alpha = 0.3;
					break;
					
				case 3:
					self.camera_hud_item[ "upload_ellipsis_1" ].alpha = 0.3;
					self.camera_hud_item[ "upload_ellipsis_2" ].alpha = 0.6;
					self.camera_hud_item[ "upload_ellipsis_3" ].alpha = 0.9;
					break;
			}
		}

		if ( time > feed_increments && feeds.size > 1)
		{
			time = 0.0;
			feeds[ 0 ].alpha = 1.0;
			feeds = array_remove_index( feeds, 0 );
		}
		
		foreach ( feed in feeds )
		{
			feed SetText( feed.defaultText + Int( RandomFloatRange( 0.0, 10000 ) * 100000 ) / 100000 );
		}
		
		wait 0.05;
		
		time += 0.05;
		
		update_ellipsis = !update_ellipsis;
	}
	
	if ( !self.binoculars_stop_scanning )
	{
		self.camera_hud_item[ "upload_ellipsis_1" ].alpha = 0.0;
		self.camera_hud_item[ "upload_ellipsis_2" ].alpha = 0.0;
		self.camera_hud_item[ "upload_ellipsis_3" ].alpha = 0.0;
		
		self waittill( "stop_scanning" );
	}
	
	self.camera_hud_item[ "profile_data_line_1" ] Destroy();
	self.camera_hud_item[ "profile_data_line_1" ] = undefined;
	
	self.camera_hud_item[ "profile_data_line_2" ] Destroy();
	self.camera_hud_item[ "profile_data_line_2" ] = undefined;
	
	self.camera_hud_item[ "profile_data_line_3" ] Destroy();
	self.camera_hud_item[ "profile_data_line_3" ] = undefined;
	
	//self.camera_hud_item[ "profile_data_line_4" ] Destroy();
	//self.camera_hud_item[ "profile_data_line_4" ] = undefined;
	
	//self.camera_hud_item[ "profile_data_line_5" ] Destroy();
	//self.camera_hud_item[ "profile_data_line_5" ] = undefined;
	
	self.camera_hud_item[ "profile_data_feed_1" ] Destroy();
	self.camera_hud_item[ "profile_data_feed_1" ] = undefined;
	
	self.camera_hud_item[ "profile_data_feed_2" ] Destroy();
	self.camera_hud_item[ "profile_data_feed_2" ] = undefined;
	
	self.camera_hud_item[ "profile_data_feed_3" ] Destroy();
	self.camera_hud_item[ "profile_data_feed_3" ] = undefined;
	
	self.camera_hud_item[ "profile_data_feed_4" ] Destroy();
	self.camera_hud_item[ "profile_data_feed_4" ] = undefined;
	
	self.camera_hud_item[ "profile_data_feed_5" ] Destroy();
	self.camera_hud_item[ "profile_data_feed_5" ] = undefined;
	
	self.camera_hud_item[ "profile_data_feed_6" ] Destroy();
	self.camera_hud_item[ "profile_data_feed_6" ] = undefined;
	
	self.camera_hud_item[ "upload_ellipsis_1" ] Destroy();
	self.camera_hud_item[ "upload_ellipsis_1" ] = undefined;
	
	self.camera_hud_item[ "upload_ellipsis_2" ] Destroy();
	self.camera_hud_item[ "upload_ellipsis_2" ] = undefined;
	
	self.camera_hud_item[ "upload_ellipsis_3" ] Destroy();
	self.camera_hud_item[ "upload_ellipsis_3" ] = undefined;
	
	self.camera_hud_item[ "secure" ] Destroy();
	self.camera_hud_item[ "secure" ] = undefined;
}

binoculars_monitor_scanning()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	if( !isDefined( level.camera_require_scan ) || !level.camera_require_scan )
	{
		return;
	}

	// Right Bumper
	//self NotifyOnPlayerCommand( "scanning", "+smoke" );
	//self NotifyOnPlayerCommand( "stop_scanning", "-smoke" );

	// Right Trigger
	self NotifyOnPlayerCommand( "scanning", "+attack" );
	self NotifyOnPlayerCommand( "stop_scanning", "-attack" );
	
	while ( 1 )
	{
		self waittill( "scanning" );
		
		//if ( self.current_binocular_zoom_level != self.binocular_zoom_levels - 1 )
		//{
		//	continue;
		//}
		
		/*
		on_target = false;
		targ = undefined;
		if( isDefined( self.binoculars_trace[ "entity" ] ))
		{
			targ = self.binoculars_trace[ "entity" ];
			if( isDefined( targ.script_parameters ) )
			{
				if( targ.script_parameters == level.camera_target )
				{
					on_target = true;
				}
			}
		}
		*/
		on_target = true;
		
		/*
		// Check zoom setting
		if( on_target && level.camera_target == "sat_cpu_target" )
		{
			if( self.current_binocular_zoom_level == 0 )
			{
				level notify( "sat_warn_zoom" );
				thread sat_nag_zoom();
				thread intro_binoculars_hint( 0.25, "camera_zoom", undefined, "binocular_zoom" );
				on_target = false;
			}
		}
		*/

		// Correct target
		if ( on_target && flag( "sat_allow_scan" ))
		{
			//targ = GetEnt( self.binoculars_trace[ "entity" ].script_linkto, "script_linkname" );
			targ = GetEnt( level.sat_lock_target, "targetname" );
			self thread binoculars_lock_to_target( targ );
			//self thread binoculars_target_flash();
			
			self notify( "scanning_target" ); //JZ - put this in because scanning returns even if you aren't on an enemy target.
			
			// This loop waits while the camera forcably homes in on the target
			//while ( self AttackButtonPressed() && IsDefined( self.binoculars_linked_to_target ) && self.binoculars_linked_to_target && !Target_IsInCircle( self.binocular_target, self, GetDvarInt( "cg_fov" ), 50 ) )
			//{
			//	wait 0.05;
			//}
			
			if ( !self AttackButtonPressed() )
			{
				self notify( "stop_binocular_flash" );
				//Target_DrawCornersOnly( self.binocular_target, false );
				//Target_HideFromPlayer( self.binocular_target, self );
				//Target_SetShader( self.binocular_target, "cnd_binoculars_hud_id_box" );
				self binoculars_unlock_from_target();
				continue;
			}
			
			self.binoculars_scanning_complete = false;
			self.binoculars_stop_scanning = false;
			
			self thread maps\factory_audio::aud_binoculars_scan_loop();
			
			self thread binocular_face_scanning( targ );
//			self thread binocular_face_scanning_lines();
			
			// Original
			//self.camera_hud_item[ "uploading_bar" ] = maps\_hud_util::createIcon( "white", 1, 5 );
			//self.camera_hud_item[ "uploading_bar" ] set_default_hud_parameters();
			//self.camera_hud_item[ "uploading_bar" ].alignY = "bottom";
			//self.camera_hud_item[ "uploading_bar" ].horzAlign = "left";
			//self.camera_hud_item[ "uploading_bar" ].x = 0;
			//self.camera_hud_item[ "uploading_bar" ].y = self.camera_hud_item[ "profile" ].y - self.camera_hud_item[ "profile" ].height * 0.5 - 1;
			//self.camera_hud_item[ "uploading_bar" ].alpha = 0.9;
			
			// Bottom
			//self.camera_hud_item[ "uploading_bar" ] = maps\_hud_util::createIcon( "white", 1, 6 );
			//self.camera_hud_item[ "uploading_bar" ] set_default_hud_parameters();
			//self.camera_hud_item[ "uploading_bar" ].alignX = "left";
			//self.camera_hud_item[ "uploading_bar" ].alignY = "bottom";
			//self.camera_hud_item[ "uploading_bar" ].horzAlign = "center";
			//self.camera_hud_item[ "uploading_bar" ].vertAlign = "bottom";
			//self.camera_hud_item[ "uploading_bar" ].x = -200;
			//self.camera_hud_item[ "uploading_bar" ].y = -18;
			//self.camera_hud_item[ "uploading_bar" ].alpha = 0.9;
			
			// Below PIP
			self.camera_hud_item[ "uploading_bar" ] = maps\_hud_util::createIcon( "white", 1, 8 );
			self.camera_hud_item[ "uploading_bar" ] set_default_hud_parameters();
			self.camera_hud_item[ "uploading_bar" ].alignY = "bottom";
			self.camera_hud_item[ "uploading_bar" ].horzAlign = "left";
			self.camera_hud_item[ "uploading_bar" ].x = 0;
			self.camera_hud_item[ "uploading_bar" ].y = self.camera_hud_item[ "profile" ].height-5;
			self.camera_hud_item[ "uploading_bar" ].alpha = 0.9;

			self.binoculars_scan_time = 2.0;
			
			self thread binocular_face_scanning_data();
			
			self.camera_hud_item[ "recognition_system" ].alpha = 1.0;
			
			time = 0.0;

			// Data Upload Progress Bar
			while ( self AttackButtonPressed() && time < self.binoculars_scan_time )
			{
				time += 0.05;
				wait 0.05;
				
				// Original
				//self.camera_hud_item[ "uploading_bar" ] SetShader( "white", Int( ( time / 2.0 ) * ( self.camera_hud_item[ "profile" ].width - 1 ) ), 5 );
				
				// Bottom
				//self.camera_hud_item[ "uploading_bar" ] SetShader( "white", Int( ( time / 2.0 ) * ( self.camera_hud_item[ "bottom_bar" ].width - 10 ) ), 6 );
				
				// Below PIP
				self.camera_hud_item[ "uploading_bar" ] SetShader( "white", Int( ( time / 2.0 ) * ( self.camera_hud_item[ "profile" ].width - 3 ) ), 8 );
			}

			// Scan complete
			if ( time >= 1.0 )
			{
				self notify( "scanning_complete" );
				self.binoculars_scanning_complete = true;
				
				while ( self AttackButtonPressed() && time < 1.5 )
				{
					time += 0.05;
					wait 0.05;
				}
			}

			self notify( "stop_binocular_scan_loop_sound" );
			
			// Payload confirmed
			if ( time >= 1.5 )
			{
				switch( level.sat_lock_target )
				{
					case "sat_target_A":
						flag_set( "cam_A_scanned" );
						level.sat_lock_target = "sat_target_B";
						break;
					case "sat_target_B":
						level notify( "stop_nag" );
						flag_set( "cam_B_scanned" );
						break;
					default:
						break;
				}
				
				self thread maps\factory_audio::aud_binoculars_scan_positive();
				
				self.camera_hud_item[ "id_confirmed" ] = createClientFontString( "default", 1.25 );	
				self.camera_hud_item[ "id_confirmed" ] set_default_hud_parameters();
				self.camera_hud_item[ "id_confirmed" ].alignY = "middle";
				self.camera_hud_item[ "id_confirmed" ].horzAlign = "left";
				self.camera_hud_item[ "id_confirmed" ].x = self.camera_hud_item[ "profile" ].x + self.camera_hud_item[ "profile" ].width + 1;
				self.camera_hud_item[ "id_confirmed" ].y = self.camera_hud_item[ "profile" ].y;
				self.camera_hud_item[ "id_confirmed" ].alpha = 0.9;
				self.camera_hud_item[ "id_confirmed" ] SetText( "Payload Confirmed" );
				//self thread binoculars_confirmed_flash();
				
				self notify( "stop_binocular_flash" );
				//Target_DrawCornersOnly( self.binocular_target, false );
				//Target_SetShader( self.binocular_target, "cnd_binoculars_hud_id_box_large" );
			
				while ( self AttackButtonPressed() )
				{
					wait 0.05;
				}

				if ( IsDefined( self.camera_hud_item[ "id_confirmed" ] ) )
				{
					self.camera_hud_item[ "id_confirmed" ] Destroy();
					self.camera_hud_item[ "id_confirmed" ] = undefined;
				}
				
				if ( IsDefined( self.camera_hud_item[ "incomplete_data" ] ) )
				{
					self.camera_hud_item[ "incomplete_data" ] Destroy();
					self.camera_hud_item[ "incomplete_data" ] = undefined;
				}
				
				if ( IsDefined( self.camera_hud_item[ "unknown" ] ) )
				{
					self.camera_hud_item[ "unknown" ] Destroy();
					self.camera_hud_item[ "unknown" ] = undefined;
				}
				
				if ( IsDefined( self.camera_hud_item[ "match_percent" ] ) )
				{
					self.camera_hud_item[ "match_percent" ] Destroy();
					self.camera_hud_item[ "match_percent" ] = undefined;
				}
			}
			else
			{
				self thread maps\factory_audio::aud_binoculars_scan_negative();
			}
			
//			self.binocular_target HideAllParts();
				
			self.binoculars_stop_scanning = true;
			
			self.camera_hud_item[ "recognition_system" ].alpha = 0.25;

			self.camera_hud_item[ "uploading_bar" ] Destroy();
			self.camera_hud_item[ "uploading_bar" ] = undefined;
			
			self.camera_hud_item[ "profile" ] Destroy();
			self.camera_hud_item[ "profile" ] = undefined;
			
			//self notify( "stop_binocular_flash" );
			//Target_DrawCornersOnly( self.binocular_target, false );			
			//Target_SetShader( self.binocular_target, "cnd_binoculars_hud_id_box" );
			
			//if ( !self.binoculars_zoom_enabled )
			//{
				//Target_HideFromPlayer( self.binocular_target, self );
			//}
			
			self binoculars_unlock_from_target();
			wait 0.2;
		}
	}
}


static_overlay()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );

	self.camera_hud_item[ "static" ] = newClientHudElem( self );
	self.camera_hud_item[ "static" ].x = 0;
	self.camera_hud_item[ "static" ].y = 0;
	self.camera_hud_item[ "static" ].alignX = "left";
	self.camera_hud_item[ "static" ].alignY = "top";
	self.camera_hud_item[ "static" ].horzAlign = "fullscreen";
	self.camera_hud_item[ "static" ].vertAlign = "fullscreen";
	self.camera_hud_item[ "static" ] setshader( "overlay_static", 640, 480 );
	self.camera_hud_item[ "static" ].alpha = 0.75;
	self.camera_hud_item[ "static" ].sort = -3;
	
	self.camera_hud_item[ "static" ] FadeOverTime( 0.05 );
	self.camera_hud_item[ "static" ].alpha = 0.9;
	
	wait 0.05;
	
	self.camera_hud_item[ "static" ] FadeOverTime( 0.15 );
	self.camera_hud_item[ "static" ].alpha = 0.0;
	
	wait 0.15;
	
	self.camera_hud_item[ "static" ] Destroy();
	self.camera_hud_item[ "static" ] = undefined;
}

static_overlay_off()
{
	self endon( "player_using_camera" );

	self.static_overlay = newClientHudElem( self );
	self.static_overlay.x = 0;
	self.static_overlay.y = 0;
	self.static_overlay.alignX = "left";
	self.static_overlay.alignY = "top";
	self.static_overlay.horzAlign = "fullscreen";
	self.static_overlay.vertAlign = "fullscreen";
	self.static_overlay setshader( "overlay_static", 640, 480 );
	self.static_overlay.alpha = 0.75;
	self.static_overlay.sort = -3;
	
	self.static_overlay FadeOverTime( 0.05 );
	self.static_overlay.alpha = 0.9;
	
	wait 0.05;
	
	self.static_overlay FadeOverTime( 0.05 );
	self.static_overlay.alpha = 0.0;
	
	wait 0.05;
	
	self.static_overlay Destroy();
	self.static_overlay = undefined;
}

monitor_binoculars_variable_zoom()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	self.current_binocular_zoom_level = self.binoculars_default_zoom_level;
//	max_zoom_level_fov = 5;
	self.binocular_zoom_levels = 3;
	self.first_zoom_level_fov = 4;
//	zoom_fov_step = ( first_zoom_level_fov - max_zoom_level_fov ) / ( zoom_levels - 1 );
	
	self binoculars_zoom();
	
	while ( 1 )
	{
		self waittill( "binocular_zoom" );
		level notify( "binocular_zoom" );
		
		if ( self.binoculars_zoom_enabled && !self AttackButtonPressed() )
		{
			self.binocular_zooming = true;
			self.current_binocular_zoom_level++;
			if ( self.current_binocular_zoom_level >= self.binocular_zoom_levels )
			{
				self.current_binocular_zoom_level = 0;
				self thread maps\factory_audio::aud_binoculars_zoom_out();
			}
			else
			{
				self thread maps\factory_audio::aud_binoculars_zoom_in();
				
				//if ( self.current_binocular_zoom_level >= 0 )
				//{
				//	self notify( "binocular_targetting_on" );
				//}
			}
			
			foreach ( reticle_piece in self.binocular_reticle_pieces )
			{
				reticle_piece.alpha = 1.0;
			}

			
			//self.black_overlay = maps\_hud_util::create_client_overlay( "black", 0, self );
			//self.black_overlay FadeOverTime( 0.05 );
			//self.black_overlay.alpha = 1;
			
			//wait 0.05;
		
			wait 0.15;
			
			self binoculars_zoom();
			
			if ( self.current_binocular_zoom_level < 3 )
			{
				self thread zoom_lerp_dof();
			}
			//else
			//{
			//	self thread max_zoom_lerp_dof();
			//}
			
			if ( IsDefined( self.binoculars_trace[ "entity" ] ) && IsAI( self.binoculars_trace[ "entity" ] ) && self.binoculars_trace[ "entity" ] IsBadGuy() )
			{
				foreach ( reticle_piece in self.binocular_reticle_pieces )
				{
					reticle_piece.alpha = 1.0;
				}
			}
			else
			{
				foreach ( reticle_piece in self.binocular_reticle_pieces )
				{
					reticle_piece.alpha = 0.0;
				}
			}
			
			wait 0.1;
			
			self.binocular_zooming = false;

			//self.black_overlay FadeOverTime( 0.05 );
			//self.black_overlay.alpha = 0;
			
			//wait 0.05;
			
			//self.black_overlay Destroy();
		}
	}
}

binoculars_zoom()
{
	switch ( self.current_binocular_zoom_level )
	{
		case 0:
			self.camera_hud_item[ "zoom_level_1" ].alpha = 1.0;
			self.camera_hud_item[ "zoom_level_24" ].alpha = 0.25;
			break;
			
		case 1:
			self.camera_hud_item[ "zoom_level_15" ].alpha = 1.0;
			self.camera_hud_item[ "zoom_level_1" ].alpha = 0.25;
			break;
			
		case 2:
			self.camera_hud_item[ "zoom_level_24" ].alpha = 1.0;
			self.camera_hud_item[ "zoom_level_15" ].alpha = 0.25;
			break;
	}
	
	if ( self.current_binocular_zoom_level == 0 )
	{
		SetSavedDvar( "cg_fov", 65 );	// 1.0x
	}
	else if( self.current_binocular_zoom_level == 1 )
	{
		SetSavedDvar( "cg_fov", 43 );	// 1.5x
	}
	else if( self.current_binocular_zoom_level == 2 )
	{
		SetSavedDvar( "cg_fov", 27 );	// 2.4x
	}
}

/*
max_zoom_lerp_dof()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	dist = 0;
	old_dist = undefined;
	
	while ( self.current_binocular_zoom_level == 4 )
	{
		dist = Distance( self.binoculars_trace[ "position" ], self GetEye() );
		
		if ( IsDefined( old_dist ) )
		{
			dist = old_dist + ( ( dist - old_dist ) * 0.25 );
		}
		
		old_dist = dist;
		
		nearStart 	= Max( 0, ( dist - 1000 ) );
		nearEnd 	= Max( 0, ( dist - 120 ) );
		nearBlur 	= 4;
		farStart 	= dist + 120;
		farEnd 		= dist + 1000;
		farBlur 	= 4;
		
		maps\_art::dof_enable_script( nearStart, nearEnd, nearBlur, farStart, farEnd, farBlur, 0.05 );
		
		wait 0.05;
	}
}
*/

zoom_lerp_dof()
{
	self notify( "binoculars_lerp_dof" );
	self endon( "binoculars_lerp_dof" );
	
	maps\_art::dof_enable_script( 50, 100, 10, 100, 200, 6, 0.0 );
	maps\_art::dof_disable_script( 0.5 );
}

binoculars_angles_display()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	self.camera_hud_item[ "angles" ] = self maps\_hud_util::createClientFontString( "default", 1.25 );
	self.camera_hud_item[ "angles" ].x = 0;
	self.camera_hud_item[ "angles" ].y = 0;
	self.camera_hud_item[ "angles" ].alignX = "center";
	self.camera_hud_item[ "angles" ].alignY = "top";
	self.camera_hud_item[ "angles" ].horzAlign = "center";
	self.camera_hud_item[ "angles" ].vertAlign = "top";
	self.camera_hud_item[ "angles" ].color = ( 1.0, 1.0, 1.0 );
	self.camera_hud_item[ "angles" ].alpha = 1.0;
	
	//self.camera_hud_item[ "angles_degree" ] = maps\_hud_util::createIcon( "cnd_binoculars_hud_reticle_dot", 8, 8 );
	//self.camera_hud_item[ "angles_degree" ].x = 0;
	//self.camera_hud_item[ "angles_degree" ].y = 0;
	//self.camera_hud_item[ "angles_degree" ].alignX = "left";
	//self.camera_hud_item[ "angles_degree" ].alignY = "top";
	//self.camera_hud_item[ "angles_degree" ].horzAlign = "center";
	//self.camera_hud_item[ "angles_degree" ].vertAlign = "top";
	//self.camera_hud_item[ "angles_degree" ].color = ( 1.0, 1.0, 1.0 );
	//self.camera_hud_item[ "angles_degree" ].alpha = 1.0;
	
	self.camera_hud_item[ "heading" ] = self maps\_hud_util::createClientFontString( "default", 1.25 );
	self.camera_hud_item[ "heading" ].x = 0;
	self.camera_hud_item[ "heading" ].y = self.camera_hud_item[ "angles" ].height * 1.1;
	self.camera_hud_item[ "heading" ].alignX = "center";
	self.camera_hud_item[ "heading" ].alignY = "top";
	self.camera_hud_item[ "heading" ].horzAlign = "center";
	self.camera_hud_item[ "heading" ].vertAlign = "top";
	self.camera_hud_item[ "heading" ].color = ( 1.0, 1.0, 1.0 );
	self.camera_hud_item[ "heading" ].alpha = 1.0;
	
	north_yaw = GetNorthYaw();
	
	while ( 1 )
	{
		degrees = abs( AngleClamp( 0 - self GetPlayerAngles()[ 1 ] ) - north_yaw );
		minutes = ( degrees - Int( degrees ) ) * 60.0;
		seconds = ( minutes - Int( minutes ) ) * 60.0;
		
		minutes_string = "" + Int( minutes );

		if ( minutes < 10 )
		{
			minutes_string	= "0" + Int( minutes );
		}
		
		seconds_string = "" + Int( seconds );
		
		if ( seconds < 10 )
		{
			seconds_string = "0" + Int( seconds );
		}
		
		self.camera_hud_item[ "angles" ] SetText( Int( degrees ) + "  " + minutes_string + "' " + seconds_string + "\"" );
		
		if ( degrees > 337.5 || degrees < 22.5 )
		{
			self.camera_hud_item[ "heading" ] SetText( "N" );
		}
		else if ( degrees < 67.5 )
		{
			self.camera_hud_item[ "heading" ] SetText( "NE" );
		}
		else if ( degrees < 112.5 )
		{
			self.camera_hud_item[ "heading" ] SetText( "E" );
		}
		else if ( degrees < 157.5 )
		{
			self.camera_hud_item[ "heading" ] SetText( "SE" );
		}
		else if ( degrees < 202.5 )
		{
			self.camera_hud_item[ "heading" ] SetText( "S" );
		}
		else if ( degrees < 247.5 )
		{
			self.camera_hud_item[ "heading" ] SetText( "SW" );
		}
		else if ( degrees < 292.5 )
		{
			self.camera_hud_item[ "heading" ] SetText( "W" );
		}
		else
		{
			self.camera_hud_item[ "heading" ] SetText( "NW" );
		}
		/*
		if ( degrees < 10 )
		{
			self.camera_hud_item[ "angles_degree" ].x = -22;
		}
		else if ( degrees < 100 )
		{
			self.camera_hud_item[ "angles_degree" ].x = -18;
		}
		else
		{
			self.camera_hud_item[ "angles_degree" ].x = -14;
		}
		*/
		
		wait 0.05;		
	}
}

// Changes the reticule when on target
sat_camera_reticule()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	looking_at = false;

	if( !isDefined( level.camera_highlight ) || level.camera_highlight == false )
	{
		return;
	}

	// This only applies to targets A and B
	while( !flag( "sat_begin_looking_for_C" ))
	{
		if( isDefined( level.sat_current_target ))
		{
			if ( IsDefined( self.binoculars_trace[ "entity" ] ) && isDefined( self.binoculars_trace[ "entity" ].targetname ) &&
		    self.binoculars_trace[ "entity" ].targetname == level.sat_current_target.target )
			{

				looking_at = true;
			}
			else
			{
				looking_at = false;
			}
		}
		else
		{
			looking_at = false;
		}

		// Update the reticule
		/*
		foreach ( reticle_piece in self.binocular_reticle_pieces )
		{
			if ( looking_at )
			{
				target_x = reticle_piece.target_x;
				target_y = reticle_piece.target_y;
				target_width = reticle_piece.target_width;
				target_height = reticle_piece.target_height;	
			}
			else
			{
				target_x = reticle_piece.no_target_x;
				target_y = reticle_piece.no_target_y;
				target_width = reticle_piece.no_target_width;
				target_height = reticle_piece.no_target_height;
			}

			reticle_piece ScaleOverTime( 0.1, Int( target_width ), Int( target_height ) );
			reticle_piece MoveOverTime( 0.1 );
			reticle_piece.x = target_x;
			reticle_piece.y = target_y;
		}
		*/
		wait 0.1;
	}
	
	// Use a more precise method for target C
	target_C = "sat_target_C";
	while( 1 )
	{
		if( isDefined( level.sat_current_target ))
		{
			if ( ( !IsDefined( self.binocular_zooming ) || ( IsDefined( self.binocular_zooming ) && !self.binocular_zooming ) ) && ( /* !self.binocular_target IsLinked() || */ !self AttackButtonPressed() ) )
			{
				if ( IsDefined( self.binoculars_trace ) && IsDefined( self.binoculars_trace[ "entity" ] ) && ( isDefined( self.binoculars_trace[ "entity" ].script_parameters ) && self.binoculars_trace[ "entity" ].script_parameters == target_C ))
				{
					looking_at = true;
				}
				else
				{
					looking_at = false;
				}
			}
		}
		else
		{
			looking_at = false;
		}

		// Update the reticule
		foreach ( reticle_piece in self.binocular_reticle_pieces )
		{
			if ( looking_at )
			{
				target_x = reticle_piece.target_x;
				target_y = reticle_piece.target_y;
				target_width = reticle_piece.target_width;
				target_height = reticle_piece.target_height;
			}
			else
			{
				target_x = reticle_piece.no_target_x;
				target_y = reticle_piece.no_target_y;
				target_width = reticle_piece.no_target_width;
				target_height = reticle_piece.no_target_height;
			}

			reticle_piece ScaleOverTime( 0.1, Int( target_width ), Int( target_height ) );
			reticle_piece MoveOverTime( 0.1 );
			reticle_piece.x = target_x;
			reticle_piece.y = target_y;
		}
		wait 0.1;
	}
}

// Turn on the targeting boxes for the rods
setup_tagged_entities()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );

	level.tag_nodes = [];
	tag_items = [];
	
	// Tag RCS modules
	if( !flag( "cam_A_confirmed" ))
	{
		level waittill( "found_sat_target" );
		tag_items = GetEntArray( "sat_target_A_tag_nodes", "targetname" );

		// Tag them
		foreach( i, item in tag_items )
		{
			item thread add_tag( 25 );
			wait RandomFloatRange( 0.02, 0.22 );
		}
	}
	
	// Tag Rods
	if( !flag( "cam_B_confirmed" ))
	{
		level waittill( "found_sat_target" );
		tag_items = GetEntArray( "sat_target_B_tag_nodes", "targetname" );
		
		// Tag them
		foreach( i, item in tag_items )
		{
			item thread add_tag( 35 );
			wait RandomFloatRange( 0.01, 0.22 );
		}
	}

}

// Adds a target box on a single entity
add_tag( min_scale )
{
	//self.tag_target = Spawn( "script_model", self GetOrigin() );
	//self.tag_target SetModel( "soccer_ball_static" );
	//self.tag_target Hide();
	//self.tag_target NotSolid();
	//self.tag_target.origin = self.origin;
	//self.tag_target.angles = self.angles;
	//self.tag_target LinkTo( self );
	
	Target_Alloc( self, (0,0,0));
	Target_SetShader( self, "cnd_binoculars_hud_id_box" );
	Target_SetScaledRenderMode( self, true );
	Target_DrawCornersOnly( self, true );
	Target_Flush( self );
	
	Target_ShowToPlayer( self, level.player );
	level.tag_nodes = array_add( level.tag_nodes, self );	
}

// Turns off the targeting boxes for the rods
remove_tagged_entities()
{
	if( isDefined( level.tag_nodes ) && level.tag_nodes.size != 0 )
	{
		foreach( node in level.tag_nodes )
		{
			if( Target_IsTarget( node ))
			{
				Target_Remove( node );
				// wait RandomFloatRange( 0.01, 0.22 );
			}
		}
	}
}


// Helper scripts
set_default_hud_parameters()
{
	self.alignx = "left";
	self.aligny = "top";
	self.horzAlign = "center";
	self.vertAlign = "middle";
	self.hidewhendead = false;
	self.hidewheninmenu = false;
	self.sort = 205;
	self.foreground = true;
	self.alpha = 0.65;
}
