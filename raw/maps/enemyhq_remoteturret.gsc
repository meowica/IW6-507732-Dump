#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;

remote_turret_init( turret )
{
	PreCacheModel( "tag_turret" );
	PreCacheTurret( turret );
	PreCacheShader( "gunship_overlay_tow" );
	PreCacheShader( "remote_sniper_overlay" );
	PreCacheShader( "overlay_static" );
	PreCacheShader( "ugv_screen_overlay" );
	PreCacheShader( "m1a1_tank_sabot_scanline" );
	PreCacheShader( "remote_sniper_compass_bracket_left" );
	PreCacheShader( "remote_sniper_compass_bracket_right" );
	PreCacheShader( "remote_sniper_compass_pointer_down" );
	PreCacheShader( "remote_sniper_compass_pointer_up" );
	PreCacheShader( "remote_sniper_incline_mark_left" );
	PreCacheShader( "remote_sniper_incline_mark_left_red" );
	PreCacheShader( "remote_sniper_incline_mark_right" );
	PreCacheShader( "remote_sniper_incline_mark_right_red" );
	PreCacheShader( "remote_sniper_label_box_bg_left" );
	PreCacheShader( "remote_sniper_label_box_bg_right" );
	PreCacheShader( "remote_sniper_reticle" );
	PreCacheShader( "remote_sniper_reticle_red" );
	PreCacheShader( "remote_sniper_scanline_left" );
	PreCacheShader( "remote_sniper_scanline_right" );
	PreCacheShader( "remote_sniper_wind_direction" );
	PreCacheShader( "red_block" );
	PreCacheShader( "green_block" );
	PreCacheShader( "m1a1_tank_weapon_progress_bar" );
	PreCacheString( &"ENEMY_HQ_AIR_TEMPERATURE" );
	PreCacheString( &"ENEMY_HQ_DIRECTION" );
	PreCacheString( &"ENEMY_HQ_FIRING" );
	PreCacheString( &"ENEMY_HQ_HUMIDITY" );
	PreCacheString( &"ENEMY_HQ_INCL" );
	PreCacheString( &"ENEMY_HQ_RANGE" );
	PreCacheString( &"ENEMY_HQ_RELOADING" );
	PreCacheString( &"ENEMY_HQ_TARGETING" );
	PreCacheString( &"ENEMY_HQ_REMOTE_SNIPER_WEAPON" );
	PreCacheString( &"ENEMY_HQ_WIND" );
	PreCacheString( &"ENEMY_HQ_NORTH" );
	PreCacheString( &"ENEMY_HQ_SOUTH" );
	PreCacheString( &"ENEMY_HQ_EAST" );
	PreCacheString( &"ENEMY_HQ_WEST" );
	PreCacheString( &"ENEMY_HQ_NORTHWEST" );
	PreCacheString( &"ENEMY_HQ_SOUTHWEST" );
	PreCacheString( &"ENEMY_HQ_SOUTHEAST" );
	PreCacheString( &"ENEMY_HQ_NORTHEAST" );
	PreCacheString( &"ENEMY_HQ_NORTH_BY_NORTHWEST" );
	PreCacheString( &"ENEMY_HQ_WEST_BY_NORTHWEST" );
	PreCacheString( &"ENEMY_HQ_WEST_BY_SOUTHWEST" );
	PreCacheString( &"ENEMY_HQ_SOUTH_BY_SOUTHWEST" );
	PreCacheString( &"ENEMY_HQ_SOUTH_BY_SOUTHEAST" );
	PreCacheString( &"ENEMY_HQ_EAST_BY_SOUTHEAST" );
	PreCacheString( &"ENEMY_HQ_EAST_BY_NORTHEAST" );
	PreCacheString( &"ENEMY_HQ_NORTH_BY_NORTHEAST" );
	PreCacheString( &"ENEMY_HQ_TIMES" );
	
	level.remote_turret_type = turret;
	
	level.remote_turret_max_fov = 55;
	level.remote_turret_min_fov = 4;
	
	level.remote_turret_min_slow_aim_yaw = 0.16;
	level.remote_turret_max_slow_aim_yaw = 0.22;
	level.remote_turret_min_slow_aim_pitch = 0.25;
	level.remote_turret_max_slow_aim_pitch = 0.4;
	level.remote_turret_current_slow_yaw = 0.15;
	level.remote_turret_current_slow_pitch = 0.25;
	level.remote_turret_firing_slow_aim_modifier = 0.0;
	level.remote_turret_current_fov = level.remote_turret_max_fov;
	level.fov_range = level.remote_turret_max_fov - level.remote_turret_min_fov;
	level.slow_aim_yaw_range = level.remote_turret_max_slow_aim_yaw - level.remote_turret_min_slow_aim_yaw;
	level.slow_aim_pitch_range = level.remote_turret_max_slow_aim_pitch - level.remote_turret_min_slow_aim_pitch;

	thread remove_remote_turret_targets();
	
}

remote_turret_activate( weap, position, angle, right_arc, left_arc, top_arc, bottom_arc )
{
	
	level.old_player_origin = self.origin;
	level.old_player_angles = self.angles;
	self.prev_stance = self GetStance();
	
	self store_players_weapons( "remote_turret" );
	self TakeAllWeapons();
	
	self GiveWeapon( weap );
	self SwitchToWeaponImmediate( weap );
	
	self Hide();
	self EnableHealthShield( true );
	self EnableDeathShield( true );
	self EnableInvulnerability();
	
	self AllowAds( false );
	self AllowMelee( false );
	self AllowCrouch( false );
	self AllowProne( false );
	
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
	SetSavedDvar( "cg_fov", level.remote_turret_current_fov );
	SetSavedDvar( "compass", 0 );
	
	self SetOrigin( position );
	self SetPlayerAngles( angle );
	
	if ( !IsDefined( self.player_view_controller_model ) )
	{
		self.player_view_controller_model = Spawn( "script_model", self.origin );
		self.player_view_controller_model SetModel( "tag_origin" );
	}
	
	self.player_view_controller_model.origin = self.origin;
	self.player_view_controller_model.angles = self GetPlayerAngles();
	
	if ( !IsDefined( self.player_view_controller ) )
	{
		self.player_view_controller = get_player_view_controller( self.player_view_controller_model, "tag_origin", ( 0, 0, 0 ), level.remote_turret_type );
	}

	// only set the lookatent's origin if we had to spawn it too.	
	if ( !IsDefined( self.turret_look_at_ent ) )
	{
		self.turret_look_at_ent = Spawn( "script_model", self.origin );
		self.turret_look_at_ent SetModel( "tag_origin" );
	}
	self.turret_look_at_ent.origin = self.origin + ( AnglesToForward( self GetPlayerAngles() ) * 1000 );
	
	self.player_view_controller SnapToTargetEntity( self.turret_look_at_ent );
	
	self PlayerLinkToDelta( self.player_view_controller, "tag_aim", 1.0, right_arc, left_arc, top_arc, bottom_arc );
	
//	self VisionSetNakedForPlayer( "remote_chopper", 0.25 );
	
	self thread remote_turret_handle_zoom();
	self thread set_slow_aim();
	
	if ( !IsDefined( self.allow_dry_fire ) || self.allow_dry_fire == false )
	{
		self thread remote_turret_monitor_ammo( weap );
	}
	else
	{
		self SetWeaponAmmoClip( weap, 0 );
		self thread remote_turret_monitor_dryfire( weap );
	}
		
	self thread update_remote_turret_targets();
	self thread remote_turret_hud();
}

remote_turret_deactivate()
{
	self notify( "remote_turret_deactivate" );
	
	self remote_turret_clear_hud();
	
	self restore_players_weapons( "remote_turret" );
	
	self DisableSlowAim();
	
	self Unlink();
	self SetStance( self.prev_stance );
	self SetOrigin( level.old_player_origin );
	self SetPlayerAngles( level.old_player_angles );
	self EnableWeaponSwitch();
	self EnableOffhandWeapons();
	self Show();
	
//	self VisionSetNakedForPlayer( "enemyhq", 0.25 );
	
	self AllowAds( true );
	self AllowMelee( true );
	self AllowCrouch( true );
	self AllowProne( true );

	self EnableHealthShield( false );
	self EnableDeathShield( false );
	self DisableInvulnerability();

	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "cg_fov", 65 );
	
	self.player_view_controller Delete();
	self.player_view_controller = undefined;
	
	self.player_view_controller_model Delete();
	self.player_view_controller_model = undefined;
	
	self.turret_look_at_ent Delete();
	self.turret_look_at_ent = undefined;
	wait 0.2;
	SetSavedDvar( "cg_fov", 65 );
	SetSavedDvar( "r_hudoutlineenable", 0 );
}

remote_turret_hud()
{
	level.remote_turret_hud = [];
	
	label_bkg_width = 100;
	label_bkg_height = 25;
	sidebar_x = 72.5;
	sidebar_x_text = sidebar_x - 12.5;
	label_font_size = 1.0;
	
	level.remote_turret_hud[ "device_overlay" ] = create_client_overlay( "remote_sniper_overlay", 1 );
	level.remote_turret_hud[ "device_overlay" ].foreground = false;
	
	level.remote_turret_hud[ "screen_overlay" ] = create_client_overlay( "ugv_screen_overlay", 1 );
	level.remote_turret_hud[ "screen_overlay" ].foreground = false;
	level.remote_turret_hud[ "screen_overlay" ].sort = level.remote_turret_hud[ "device_overlay" ].sort - 20;
	
	level.remote_turret_hud[ "scanline" ] = createClientIcon( "m1a1_tank_sabot_scanline", 1000, 75 );
	level.remote_turret_hud[ "scanline" ].alignX = "center";
	level.remote_turret_hud[ "scanline" ].alignY = "middle";
	level.remote_turret_hud[ "scanline" ].horzAlign = "center";
	level.remote_turret_hud[ "scanline" ].vertAlign = "middle";
	level.remote_turret_hud[ "scanline" ].sort = level.remote_turret_hud[ "screen_overlay" ].sort;
	level.remote_turret_hud[ "scanline" ] thread remote_turret_update_scanline();
	
	level.remote_turret_hud[ "reticle" ] = createClientIcon( "remote_sniper_reticle", 620, 310 );
	level.remote_turret_hud[ "reticle" ] set_default_hud_parameters();
	level.remote_turret_hud[ "reticle" ].alignX = "center";
	level.remote_turret_hud[ "reticle" ].alignY = "middle";
	level.remote_turret_hud[ "reticle" ].sort -= 15;
	
	level.remote_turret_hud[ "reticle_red" ] = createClientIcon( "remote_sniper_reticle_red", 620, 310 );
	level.remote_turret_hud[ "reticle_red" ] set_default_hud_parameters();
	level.remote_turret_hud[ "reticle_red" ].alignX = "center";
	level.remote_turret_hud[ "reticle_red" ].alignY = "middle";
	level.remote_turret_hud[ "reticle_red" ].alpha = 0;
	level.remote_turret_hud[ "reticle_red" ].sort -= 15;
	
	level.remote_turret_hud[ "hash_bkg_left" ] = createClientIcon( "remote_sniper_scanline_left", 40, 320 );
	level.remote_turret_hud[ "hash_bkg_left" ] set_default_hud_parameters();
	level.remote_turret_hud[ "hash_bkg_left" ].alignX = "right";
	level.remote_turret_hud[ "hash_bkg_left" ].alignY = "middle";
	level.remote_turret_hud[ "hash_bkg_left" ].horzAlign = "left";
	level.remote_turret_hud[ "hash_bkg_left" ].vertAlign = "middle";
	level.remote_turret_hud[ "hash_bkg_left" ].x = sidebar_x;
	level.remote_turret_hud[ "hash_bkg_left" ].y = 0;
	level.remote_turret_hud[ "hash_bkg_left" ].alpha = 0.75;
	
	level.remote_turret_hud[ "range_bkg" ] = createClientIcon( "remote_sniper_label_box_bg_left", label_bkg_width, label_bkg_height );
	level.remote_turret_hud[ "range_bkg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "range_bkg" ].alignX = "right";
	level.remote_turret_hud[ "range_bkg" ].alignY = "middle";
	level.remote_turret_hud[ "range_bkg" ].horzAlign = "left";
	level.remote_turret_hud[ "range_bkg" ].vertAlign = "middle";
	level.remote_turret_hud[ "range_bkg" ].x = sidebar_x;
	level.remote_turret_hud[ "range_bkg" ].y = -180;
	level.remote_turret_hud[ "range_bkg" ].sort -= 1;
	
	level.remote_turret_hud[ "range_txt" ] = createClientFontString( "default", label_font_size );
	level.remote_turret_hud[ "range_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "range_txt" ].alignX = "right";
	level.remote_turret_hud[ "range_txt" ].alignY = "middle";
	level.remote_turret_hud[ "range_txt" ].horzAlign = "left";
	level.remote_turret_hud[ "range_txt" ].vertAlign = "middle";
	level.remote_turret_hud[ "range_txt" ].x = sidebar_x_text;
	level.remote_turret_hud[ "range_txt" ].y = level.remote_turret_hud[ "range_bkg" ].y;
	level.remote_turret_hud[ "range_txt" ] SetText( &"ENEMY_HQ_RANGE" );
	
	level.remote_turret_hud[ "range_val" ] = createClientFontString( "default", 1.6 );
	level.remote_turret_hud[ "range_val" ] set_default_hud_parameters();
	level.remote_turret_hud[ "range_val" ].alignX = "right";
	level.remote_turret_hud[ "range_val" ].alignY = "top";
	level.remote_turret_hud[ "range_val" ].horzAlign = "left";
	level.remote_turret_hud[ "range_val" ].vertAlign = "middle";
	level.remote_turret_hud[ "range_val" ].x = sidebar_x_text - 10;
	level.remote_turret_hud[ "range_val" ].y = level.remote_turret_hud[ "range_bkg" ].y + label_bkg_height * 0.75;
	level.remote_turret_hud[ "range_val" ] thread remote_turret_update_range();
	
	level.remote_turret_hud[ "incl_left_bkg" ] = createClientIcon( "remote_sniper_label_box_bg_left", label_bkg_width, label_bkg_height );
	level.remote_turret_hud[ "incl_left_bkg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_left_bkg" ].alignX = "right";
	level.remote_turret_hud[ "incl_left_bkg" ].alignY = "middle";
	level.remote_turret_hud[ "incl_left_bkg" ].horzAlign = "left";
	level.remote_turret_hud[ "incl_left_bkg" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_left_bkg" ].x = sidebar_x;
	level.remote_turret_hud[ "incl_left_bkg" ].y = level.remote_turret_hud[ "hash_bkg_left" ].height * -0.333;
	level.remote_turret_hud[ "incl_left_bkg" ].sort -= 1;
	
	level.remote_turret_hud[ "incl_left_txt" ] = createClientFontString( "default", label_font_size );
	level.remote_turret_hud[ "incl_left_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_left_txt" ].alignX = "right";
	level.remote_turret_hud[ "incl_left_txt" ].alignY = "middle";
	level.remote_turret_hud[ "incl_left_txt" ].horzAlign = "left";
	level.remote_turret_hud[ "incl_left_txt" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_left_txt" ].x = sidebar_x_text;
	level.remote_turret_hud[ "incl_left_txt" ].y = level.remote_turret_hud[ "incl_left_bkg" ].y;
	level.remote_turret_hud[ "incl_left_txt" ] SetText( &"ENEMY_HQ_INCL" );
	
	level.remote_turret_hud[ "incl_mark_left" ] = createClientIcon( "remote_sniper_incline_mark_left", 80, 10 );
	level.remote_turret_hud[ "incl_mark_left" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_mark_left" ].alignX = "right";
	level.remote_turret_hud[ "incl_mark_left" ].alignY = "middle";
	level.remote_turret_hud[ "incl_mark_left" ].horzAlign = "left";
	level.remote_turret_hud[ "incl_mark_left" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_mark_left" ].x = sidebar_x - level.remote_turret_hud[ "hash_bkg_left" ].width * 0.5;
	level.remote_turret_hud[ "incl_mark_left" ].y = 0;
	
	level.remote_turret_hud[ "incl_mark_left_red" ] = createClientIcon( "remote_sniper_incline_mark_left_red", 80, 10 );
	level.remote_turret_hud[ "incl_mark_left_red" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_mark_left_red" ].alignX = "right";
	level.remote_turret_hud[ "incl_mark_left_red" ].alignY = "middle";
	level.remote_turret_hud[ "incl_mark_left_red" ].horzAlign = "left";
	level.remote_turret_hud[ "incl_mark_left_red" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_mark_left_red" ].x = sidebar_x - level.remote_turret_hud[ "hash_bkg_left" ].width * 0.5;
	level.remote_turret_hud[ "incl_mark_left_red" ].y = 0;
	level.remote_turret_hud[ "incl_mark_left_red" ].alpha = 0;
	
	level.remote_turret_hud[ "wind_bkg" ] = createClientIcon( "remote_sniper_label_box_bg_left", label_bkg_width, label_bkg_height );
	level.remote_turret_hud[ "wind_bkg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "wind_bkg" ].alignX = "right";
	level.remote_turret_hud[ "wind_bkg" ].alignY = "middle";
	level.remote_turret_hud[ "wind_bkg" ].horzAlign = "left";
	level.remote_turret_hud[ "wind_bkg" ].vertAlign = "middle";
	level.remote_turret_hud[ "wind_bkg" ].x = sidebar_x;
	level.remote_turret_hud[ "wind_bkg" ].y = level.remote_turret_hud[ "hash_bkg_left" ].height * 0.4;
	level.remote_turret_hud[ "wind_bkg" ].sort -= 1;
	
	level.remote_turret_hud[ "wind_txt" ] = createClientFontString( "default", label_font_size );
	level.remote_turret_hud[ "wind_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "wind_txt" ].alignX = "right";
	level.remote_turret_hud[ "wind_txt" ].alignY = "middle";
	level.remote_turret_hud[ "wind_txt" ].horzAlign = "left";
	level.remote_turret_hud[ "wind_txt" ].vertAlign = "middle";
	level.remote_turret_hud[ "wind_txt" ].x = sidebar_x_text;
	level.remote_turret_hud[ "wind_txt" ].y = level.remote_turret_hud[ "wind_bkg" ].y;
	level.remote_turret_hud[ "wind_txt" ] SetText( &"ENEMY_HQ_WIND" );
	
	level.remote_turret_hud[ "wind_val" ] = createClientFontString( "default", 1.6 );
	level.remote_turret_hud[ "wind_val" ] set_default_hud_parameters();
	level.remote_turret_hud[ "wind_val" ].alignX = "right";
	level.remote_turret_hud[ "wind_val" ].alignY = "top";
	level.remote_turret_hud[ "wind_val" ].horzAlign = "left";
	level.remote_turret_hud[ "wind_val" ].vertAlign = "middle";
	level.remote_turret_hud[ "wind_val" ].x = sidebar_x_text - 10;
	level.remote_turret_hud[ "wind_val" ].y = level.remote_turret_hud[ "wind_bkg" ].y + label_bkg_height;
	level.remote_turret_hud[ "wind_val" ] thread remote_turret_update_wind();
	
	level.remote_turret_hud[ "wind_dir" ] = createClientIcon( "remote_sniper_wind_direction", Int( label_bkg_height * 0.75 ), Int( label_bkg_height * 0.75 * 0.5 ) );
	level.remote_turret_hud[ "wind_dir" ] set_default_hud_parameters();
	level.remote_turret_hud[ "wind_dir" ].alignX = "right";
	level.remote_turret_hud[ "wind_dir" ].alignY = "top";
	level.remote_turret_hud[ "wind_dir" ].horzAlign = "left";
	level.remote_turret_hud[ "wind_dir" ].vertAlign = "middle";
	level.remote_turret_hud[ "wind_dir" ].x = sidebar_x;
	level.remote_turret_hud[ "wind_dir" ].y = level.remote_turret_hud[ "wind_val" ].y;

	level.remote_turret_hud[ "wind_dir_txt" ] = createClientFontString( "default", 0.8 );
	level.remote_turret_hud[ "wind_dir_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "wind_dir_txt" ].alignX = "right";
	level.remote_turret_hud[ "wind_dir_txt" ].alignY = "top";
	level.remote_turret_hud[ "wind_dir_txt" ].horzAlign = "left";
	level.remote_turret_hud[ "wind_dir_txt" ].vertAlign = "middle";
	level.remote_turret_hud[ "wind_dir_txt" ].x = sidebar_x - 4;
	level.remote_turret_hud[ "wind_dir_txt" ].y = level.remote_turret_hud[ "wind_dir" ].y + level.remote_turret_hud[ "wind_dir" ].height;
	level.remote_turret_hud[ "wind_dir_txt" ] SetText( &"ENEMY_HQ_DIRECTION" );
	
	level.remote_turret_hud[ "hash_bkg_right" ] = createClientIcon( "remote_sniper_scanline_right", 40, 320 );
	level.remote_turret_hud[ "hash_bkg_right" ] set_default_hud_parameters();
	level.remote_turret_hud[ "hash_bkg_right" ].alignX = "left";
	level.remote_turret_hud[ "hash_bkg_right" ].alignY = "middle";
	level.remote_turret_hud[ "hash_bkg_right" ].horzAlign = "right";
	level.remote_turret_hud[ "hash_bkg_right" ].vertAlign = "middle";
	level.remote_turret_hud[ "hash_bkg_right" ].x = 0 - sidebar_x;
	level.remote_turret_hud[ "hash_bkg_right" ].y = 0;
	level.remote_turret_hud[ "hash_bkg_right" ].alpha = 0.75;
	
	level.remote_turret_hud[ "air_temp_bkg" ] = createClientIcon( "remote_sniper_label_box_bg_right", label_bkg_width, label_bkg_height );
	level.remote_turret_hud[ "air_temp_bkg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "air_temp_bkg" ].alignX = "left";
	level.remote_turret_hud[ "air_temp_bkg" ].alignY = "middle";
	level.remote_turret_hud[ "air_temp_bkg" ].horzAlign = "right";
	level.remote_turret_hud[ "air_temp_bkg" ].vertAlign = "middle";
	level.remote_turret_hud[ "air_temp_bkg" ].x = 0 - sidebar_x;
	level.remote_turret_hud[ "air_temp_bkg" ].y = -180;
	level.remote_turret_hud[ "air_temp_bkg" ].sort -= 1;
	
	level.remote_turret_hud[ "air_temp_txt" ] = createClientFontString( "default", label_font_size );
	level.remote_turret_hud[ "air_temp_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "air_temp_txt" ].alignX = "left";
	level.remote_turret_hud[ "air_temp_txt" ].alignY = "middle";
	level.remote_turret_hud[ "air_temp_txt" ].horzAlign = "right";
	level.remote_turret_hud[ "air_temp_txt" ].vertAlign = "middle";
	level.remote_turret_hud[ "air_temp_txt" ].x = 0 - sidebar_x_text;
	level.remote_turret_hud[ "air_temp_txt" ].y = level.remote_turret_hud[ "air_temp_bkg" ].y;
	level.remote_turret_hud[ "air_temp_txt" ] SetText( &"ENEMY_HQ_AIR_TEMPERATURE" );
	
	level.remote_turret_hud[ "air_temp_val" ] = createClientFontString( "default", 1.6 );
	level.remote_turret_hud[ "air_temp_val" ] set_default_hud_parameters();
	level.remote_turret_hud[ "air_temp_val" ].alignX = "left";
	level.remote_turret_hud[ "air_temp_val" ].alignY = "top";
	level.remote_turret_hud[ "air_temp_val" ].horzAlign = "right";
	level.remote_turret_hud[ "air_temp_val" ].vertAlign = "middle";
	level.remote_turret_hud[ "air_temp_val" ].x = 0 - sidebar_x_text + 10;
	level.remote_turret_hud[ "air_temp_val" ].y = level.remote_turret_hud[ "air_temp_bkg" ].y + label_bkg_height * 0.75;
	level.remote_turret_hud[ "air_temp_val" ] thread remote_turret_update_air_temp();
	
	level.remote_turret_hud[ "incl_right_bkg" ] = createClientIcon( "remote_sniper_label_box_bg_right", label_bkg_width, label_bkg_height );
	level.remote_turret_hud[ "incl_right_bkg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_right_bkg" ].alignX = "left";
	level.remote_turret_hud[ "incl_right_bkg" ].alignY = "middle";
	level.remote_turret_hud[ "incl_right_bkg" ].horzAlign = "right";
	level.remote_turret_hud[ "incl_right_bkg" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_right_bkg" ].x = 0 - sidebar_x;
	level.remote_turret_hud[ "incl_right_bkg" ].y = level.remote_turret_hud[ "hash_bkg_right" ].height * -0.333;
	level.remote_turret_hud[ "incl_right_bkg" ].sort -= 1;
	
	level.remote_turret_hud[ "incl_right_txt" ] = createClientFontString( "default", label_font_size );
	level.remote_turret_hud[ "incl_right_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_right_txt" ].alignX = "left";
	level.remote_turret_hud[ "incl_right_txt" ].alignY = "middle";
	level.remote_turret_hud[ "incl_right_txt" ].horzAlign = "right";
	level.remote_turret_hud[ "incl_right_txt" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_right_txt" ].x = 0 - sidebar_x_text;
	level.remote_turret_hud[ "incl_right_txt" ].y = level.remote_turret_hud[ "incl_right_bkg" ].y;
	level.remote_turret_hud[ "incl_right_txt" ] SetText( &"ENEMY_HQ_INCL" );
	
	level.remote_turret_hud[ "incl_mark_right" ] = createClientIcon( "remote_sniper_incline_mark_right", 80, 10 );
	level.remote_turret_hud[ "incl_mark_right" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_mark_right" ].alignX = "left";
	level.remote_turret_hud[ "incl_mark_right" ].alignY = "middle";
	level.remote_turret_hud[ "incl_mark_right" ].horzAlign = "right";
	level.remote_turret_hud[ "incl_mark_right" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_mark_right" ].x = 0 - sidebar_x + level.remote_turret_hud[ "hash_bkg_right" ].width * 0.5;
	level.remote_turret_hud[ "incl_mark_right" ].y = 0;
	
	level.remote_turret_hud[ "incl_mark_right_red" ] = createClientIcon( "remote_sniper_incline_mark_right_red", 80, 10 );
	level.remote_turret_hud[ "incl_mark_right_red" ] set_default_hud_parameters();
	level.remote_turret_hud[ "incl_mark_right_red" ].alignX = "left";
	level.remote_turret_hud[ "incl_mark_right_red" ].alignY = "middle";
	level.remote_turret_hud[ "incl_mark_right_red" ].horzAlign = "right";
	level.remote_turret_hud[ "incl_mark_right_red" ].vertAlign = "middle";
	level.remote_turret_hud[ "incl_mark_right_red" ].x = 0 - sidebar_x + level.remote_turret_hud[ "hash_bkg_right" ].width * 0.5;
	level.remote_turret_hud[ "incl_mark_right_red" ].y = 0;
	level.remote_turret_hud[ "incl_mark_right_red" ].alpha = 0;
	
	level.remote_turret_hud[ "humidity_bkg" ] = createClientIcon( "remote_sniper_label_box_bg_right", label_bkg_width, label_bkg_height );
	level.remote_turret_hud[ "humidity_bkg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "humidity_bkg" ].alignX = "left";
	level.remote_turret_hud[ "humidity_bkg" ].alignY = "middle";
	level.remote_turret_hud[ "humidity_bkg" ].horzAlign = "right";
	level.remote_turret_hud[ "humidity_bkg" ].vertAlign = "middle";
	level.remote_turret_hud[ "humidity_bkg" ].x = 0 - sidebar_x;
	level.remote_turret_hud[ "humidity_bkg" ].y = level.remote_turret_hud[ "hash_bkg_right" ].height * 0.4;
	level.remote_turret_hud[ "humidity_bkg" ].sort -= 1;
	
	level.remote_turret_hud[ "humidity_txt" ] = createClientFontString( "default", label_font_size );
	level.remote_turret_hud[ "humidity_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "humidity_txt" ].alignX = "left";
	level.remote_turret_hud[ "humidity_txt" ].alignY = "middle";
	level.remote_turret_hud[ "humidity_txt" ].horzAlign = "right";
	level.remote_turret_hud[ "humidity_txt" ].vertAlign = "middle";
	level.remote_turret_hud[ "humidity_txt" ].x = 0 - sidebar_x_text;
	level.remote_turret_hud[ "humidity_txt" ].y = level.remote_turret_hud[ "humidity_bkg" ].y;
	level.remote_turret_hud[ "humidity_txt" ] SetText( &"ENEMY_HQ_HUMIDITY" );
	
	level.remote_turret_hud[ "humidity_val" ] = createClientFontString( "default", 1.6 );
	level.remote_turret_hud[ "humidity_val" ] set_default_hud_parameters();
	level.remote_turret_hud[ "humidity_val" ].alignX = "left";
	level.remote_turret_hud[ "humidity_val" ].alignY = "top";
	level.remote_turret_hud[ "humidity_val" ].horzAlign = "right";
	level.remote_turret_hud[ "humidity_val" ].vertAlign = "middle";
	level.remote_turret_hud[ "humidity_val" ].x = 0 - sidebar_x_text + 10;
	level.remote_turret_hud[ "humidity_val" ].y = level.remote_turret_hud[ "humidity_bkg" ].y + label_bkg_height;
	level.remote_turret_hud[ "humidity_val" ] thread remote_turret_update_humidity();
	
	level.remote_turret_hud[ "compass_bracket_left" ] = createClientIcon( "remote_sniper_compass_bracket_left", Int( label_bkg_height / 4 ), label_bkg_height );
	level.remote_turret_hud[ "compass_bracket_left" ] set_default_hud_parameters();
	level.remote_turret_hud[ "compass_bracket_left" ].alignX = "right";
	level.remote_turret_hud[ "compass_bracket_left" ].alignY = "middle";
	level.remote_turret_hud[ "compass_bracket_left" ].horzAlign = "center";
	level.remote_turret_hud[ "compass_bracket_left" ].vertAlign = "top";
	level.remote_turret_hud[ "compass_bracket_left" ].x = -160;
	level.remote_turret_hud[ "compass_bracket_left" ].y = 25;
	
	level.remote_turret_hud[ "compass_bracket_right" ] = createClientIcon( "remote_sniper_compass_bracket_right", Int( label_bkg_height / 4 ), label_bkg_height );
	level.remote_turret_hud[ "compass_bracket_right" ] set_default_hud_parameters();
	level.remote_turret_hud[ "compass_bracket_right" ].alignX = "left";
	level.remote_turret_hud[ "compass_bracket_right" ].alignY = "middle";
	level.remote_turret_hud[ "compass_bracket_right" ].horzAlign = "center";
	level.remote_turret_hud[ "compass_bracket_right" ].vertAlign = "top";
	level.remote_turret_hud[ "compass_bracket_right" ].x = 160;
	level.remote_turret_hud[ "compass_bracket_right" ].y = 25;
	
	level.remote_turret_hud[ "compass_arrow_up" ] = createClientIcon( "remote_sniper_compass_pointer_up", level.remote_turret_hud[ "compass_bracket_left" ].width, level.remote_turret_hud[ "compass_bracket_left" ].width );
	level.remote_turret_hud[ "compass_arrow_up" ] set_default_hud_parameters();
	level.remote_turret_hud[ "compass_arrow_up" ].alignX = "center";
	level.remote_turret_hud[ "compass_arrow_up" ].alignY = "top";
	level.remote_turret_hud[ "compass_arrow_up" ].horzAlign = "center";
	level.remote_turret_hud[ "compass_arrow_up" ].vertAlign = "top";
	level.remote_turret_hud[ "compass_arrow_up" ].x = 0;
	level.remote_turret_hud[ "compass_arrow_up" ].y = level.remote_turret_hud[ "compass_bracket_left" ].y + level.remote_turret_hud[ "compass_bracket_left" ].height * 0.5;
	
	level.remote_turret_hud[ "compass_arrow_down" ] = createClientIcon( "remote_sniper_compass_pointer_down", level.remote_turret_hud[ "compass_bracket_left" ].width, level.remote_turret_hud[ "compass_bracket_left" ].width );
	level.remote_turret_hud[ "compass_arrow_down" ] set_default_hud_parameters();
	level.remote_turret_hud[ "compass_arrow_down" ].alignX = "center";
	level.remote_turret_hud[ "compass_arrow_down" ].alignY = "bottom";
	level.remote_turret_hud[ "compass_arrow_down" ].horzAlign = "center";
	level.remote_turret_hud[ "compass_arrow_down" ].vertAlign = "top";
	level.remote_turret_hud[ "compass_arrow_down" ].x = 0;
	level.remote_turret_hud[ "compass_arrow_down" ].y = level.remote_turret_hud[ "compass_bracket_left" ].y - level.remote_turret_hud[ "compass_bracket_left" ].height * 0.5;
	
	level.remote_turret_hud[ "compass_heading" ] = createClientFontString( "default", 0.8 );
	level.remote_turret_hud[ "compass_heading" ] set_default_hud_parameters();
	level.remote_turret_hud[ "compass_heading" ].alignX = "center";
	level.remote_turret_hud[ "compass_heading" ].alignY = "top";
	level.remote_turret_hud[ "compass_heading" ].horzAlign = "center";
	level.remote_turret_hud[ "compass_heading" ].vertAlign = "top";
	level.remote_turret_hud[ "compass_heading" ].x = 0;
	level.remote_turret_hud[ "compass_heading" ].y = level.remote_turret_hud[ "compass_arrow_up" ].y + level.remote_turret_hud[ "compass_arrow_up" ].height * 0.75;
	
	level.remote_turret_hud[ "weapon_status_bg" ] = createClientIcon( "black", 75, 18 );
	level.remote_turret_hud[ "weapon_status_bg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "weapon_status_bg" ].alignX = "right";
	level.remote_turret_hud[ "weapon_status_bg" ].alignY = "middle";
	level.remote_turret_hud[ "weapon_status_bg" ].horzAlign = "right";
	level.remote_turret_hud[ "weapon_status_bg" ].vertAlign = "bottom";
	level.remote_turret_hud[ "weapon_status_bg" ].x = 0 - sidebar_x - ( sidebar_x - sidebar_x_text );
	level.remote_turret_hud[ "weapon_status_bg" ].y = -51;
	level.remote_turret_hud[ "weapon_status_bg" ].sort -= 1;
	level.remote_turret_hud[ "weapon_status_bg" ].alpha = 0.333;
	
	level.remote_turret_hud[ "weapon_status_txt" ] = createClientFontString( "default", 1.2 );
	level.remote_turret_hud[ "weapon_status_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "weapon_status_txt" ].alignX = "center";
	level.remote_turret_hud[ "weapon_status_txt" ].alignY = "middle";
	level.remote_turret_hud[ "weapon_status_txt" ].horzAlign = "right";
	level.remote_turret_hud[ "weapon_status_txt" ].vertAlign = "bottom";
	level.remote_turret_hud[ "weapon_status_txt" ].x = 0 - sidebar_x - ( sidebar_x - sidebar_x_text ) - level.remote_turret_hud[ "weapon_status_bg" ].width / 2;
	level.remote_turret_hud[ "weapon_status_txt" ].y = level.remote_turret_hud[ "weapon_status_bg" ].y;
	level.remote_turret_hud[ "weapon_status_txt" ].alpha = 0.666;
	
	level.remote_turret_hud[ "weapon_name_bg" ] = createClientIcon( "black", 75, 20 );
	level.remote_turret_hud[ "weapon_name_bg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "weapon_name_bg" ].alignX = "right";
	level.remote_turret_hud[ "weapon_name_bg" ].alignY = "top";
	level.remote_turret_hud[ "weapon_name_bg" ].horzAlign = "right";
	level.remote_turret_hud[ "weapon_name_bg" ].vertAlign = "bottom";
	level.remote_turret_hud[ "weapon_name_bg" ].x = 0 - sidebar_x - ( sidebar_x - sidebar_x_text );
	level.remote_turret_hud[ "weapon_name_bg" ].y = level.remote_turret_hud[ "weapon_status_bg" ].y + level.remote_turret_hud[ "weapon_status_bg" ].height / 2 + 1;
	level.remote_turret_hud[ "weapon_name_bg" ].sort -= 1;
	level.remote_turret_hud[ "weapon_name_bg" ].alpha = 0.333;
	
	level.remote_turret_hud[ "weapon_name_txt" ] = createClientFontString( "default", 0.8 );
	level.remote_turret_hud[ "weapon_name_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "weapon_name_txt" ].alignX = "center";
	level.remote_turret_hud[ "weapon_name_txt" ].alignY = "top";
	level.remote_turret_hud[ "weapon_name_txt" ].horzAlign = "right";
	level.remote_turret_hud[ "weapon_name_txt" ].vertAlign = "bottom";
	level.remote_turret_hud[ "weapon_name_txt" ].x = 0 - sidebar_x - ( sidebar_x - sidebar_x_text ) - level.remote_turret_hud[ "weapon_name_bg" ].width / 2;
	level.remote_turret_hud[ "weapon_name_txt" ].y = level.remote_turret_hud[ "weapon_name_bg" ].y + 1;
	level.remote_turret_hud[ "weapon_name_txt" ].alpha = 0.75;
	level.remote_turret_hud[ "weapon_name_txt" ] SetText( &"ENEMY_HQ_REMOTE_SNIPER_WEAPON" );
	
	level.remote_turret_hud[ "weapon_name_bar_bg" ] = createClientIcon( "m1a1_tank_weapon_progress_bar", 104, 13 );
	level.remote_turret_hud[ "weapon_name_bar_bg" ] set_default_hud_parameters();
	level.remote_turret_hud[ "weapon_name_bar_bg" ].alignX = "center";
	level.remote_turret_hud[ "weapon_name_bar_bg" ].alignY = "top";
	level.remote_turret_hud[ "weapon_name_bar_bg" ].horzAlign = "right";
	level.remote_turret_hud[ "weapon_name_bar_bg" ].vertAlign = "bottom";
	level.remote_turret_hud[ "weapon_name_bar_bg" ].x = level.remote_turret_hud[ "weapon_name_txt" ].x;
	level.remote_turret_hud[ "weapon_name_bar_bg" ].y = level.remote_turret_hud[ "weapon_name_txt" ].y + level.remote_turret_hud[ "weapon_name_bg" ].height * 0.4;
	
	level.remote_turret_hud[ "weapon_name_bar" ] = createClientIcon( "green_block", Int( level.remote_turret_hud[ "weapon_name_bar_bg" ].width * 0.6 ), Int( level.remote_turret_hud[ "weapon_name_bar_bg" ].height * 0.5 ) );
	level.remote_turret_hud[ "weapon_name_bar" ] set_default_hud_parameters();
	level.remote_turret_hud[ "weapon_name_bar" ].alignX = "left";
	level.remote_turret_hud[ "weapon_name_bar" ].alignY = "top";
	level.remote_turret_hud[ "weapon_name_bar" ].horzAlign = "right";
	level.remote_turret_hud[ "weapon_name_bar" ].vertAlign = "bottom";
	level.remote_turret_hud[ "weapon_name_bar" ].x = level.remote_turret_hud[ "weapon_name_bar_bg" ].x - level.remote_turret_hud[ "weapon_name_bar" ].width / 2;
	level.remote_turret_hud[ "weapon_name_bar" ].y = level.remote_turret_hud[ "weapon_name_bar_bg" ].y + Int( level.remote_turret_hud[ "weapon_name_bar_bg" ].height * 0.25 );
	level.remote_turret_hud[ "weapon_name_bar" ].sort += 1;
	level.remote_turret_hud[ "weapon_name_bar" ].alpha = 0.5;
	
	level.remote_turret_hud[ "zoom_txt" ] = createClientFontString( "default", 1.2 );
	level.remote_turret_hud[ "zoom_txt" ] set_default_hud_parameters();
	level.remote_turret_hud[ "zoom_txt" ].alignX = "center";
	level.remote_turret_hud[ "zoom_txt" ].alignY = "middle";
	level.remote_turret_hud[ "zoom_txt" ].horzAlign = "center";
	level.remote_turret_hud[ "zoom_txt" ].vertAlign = "bottom";
	level.remote_turret_hud[ "zoom_txt" ].x = 0;
	level.remote_turret_hud[ "zoom_txt" ].y = -15;
	
	level.remote_turret_compass_lines = [];
	for ( i = 0; i < 9; i++ )
	{
		level.remote_turret_compass_lines[ i ] = createClientIcon( "white", 1, Int( label_bkg_height * 0.8 ) );
		level.remote_turret_compass_lines[ i ] set_default_hud_parameters();
		level.remote_turret_compass_lines[ i ].alignX = "center";
		level.remote_turret_compass_lines[ i ].alignY = "middle";
		level.remote_turret_compass_lines[ i ].horzAlign = "center";
		level.remote_turret_compass_lines[ i ].vertAlign = "top";
		level.remote_turret_compass_lines[ i ].y = level.remote_turret_hud[ "compass_bracket_left" ].y;
	}
	
	level.remote_turret_compass_numbers = [];
	for ( i = 0; i < level.remote_turret_compass_lines.size; i++ )
	{
		level.remote_turret_compass_numbers[ i ] = createClientFontString( "default", label_font_size );
		level.remote_turret_compass_numbers[ i ] set_default_hud_parameters();
		level.remote_turret_compass_numbers[ i ].alignX = "center";
		level.remote_turret_compass_numbers[ i ].alignY = "middle";
		level.remote_turret_compass_numbers[ i ].horzAlign = "center";
		level.remote_turret_compass_numbers[ i ].vertAlign = "top";
		level.remote_turret_compass_numbers[ i ].y = level.remote_turret_hud[ "compass_bracket_left" ].y;
	}
	
	level.remote_turret_pitch_lines_left = [];
	for ( i = 0; i < 11; i++ )
	{
		level.remote_turret_pitch_lines_left[ i ] = createClientIcon( "white", Int( level.remote_turret_hud[ "hash_bkg_left" ].width * 0.5 ), 1 );
		level.remote_turret_pitch_lines_left[ i ] set_default_hud_parameters();
		level.remote_turret_pitch_lines_left[ i ].alignX = "right";
		level.remote_turret_pitch_lines_left[ i ].alignY = "middle";
		level.remote_turret_pitch_lines_left[ i ].horzAlign = "left";
		level.remote_turret_pitch_lines_left[ i ].vertAlign = "middle";
		level.remote_turret_pitch_lines_left[ i ].x = sidebar_x;
		level.remote_turret_pitch_lines_left[ i ].sort += 1;
	}
	
	level.remote_turret_pitch_lines_mini_left = [];
	for ( i = 0; i < level.remote_turret_pitch_lines_left.size; i++ )
	{
		level.remote_turret_pitch_lines_mini_left[ i ] = createClientIcon( "white", Int( level.remote_turret_pitch_lines_left[ i ].width * 0.5 ), 1 );
		level.remote_turret_pitch_lines_mini_left[ i ] set_default_hud_parameters();
		level.remote_turret_pitch_lines_mini_left[ i ].alignX = "right";
		level.remote_turret_pitch_lines_mini_left[ i ].alignY = "middle";
		level.remote_turret_pitch_lines_mini_left[ i ].horzAlign = "left";
		level.remote_turret_pitch_lines_mini_left[ i ].vertAlign = "middle";
		level.remote_turret_pitch_lines_mini_left[ i ].x = sidebar_x;
		level.remote_turret_pitch_lines_mini_left[ i ].sort += 1;
	}
	
	level.remote_turret_pitch_numbers_left = [];
	for ( i = 0; i < level.remote_turret_pitch_lines_left.size; i++ )
	{
		level.remote_turret_pitch_numbers_left[ i ] = createClientFontString( "default", 0.8 );
		level.remote_turret_pitch_numbers_left[ i ] set_default_hud_parameters();
		level.remote_turret_pitch_numbers_left[ i ].alignX = "right";
		level.remote_turret_pitch_numbers_left[ i ].alignY = "middle";
		level.remote_turret_pitch_numbers_left[ i ].horzAlign = "left";
		level.remote_turret_pitch_numbers_left[ i ].vertAlign = "middle";
		level.remote_turret_pitch_numbers_left[ i ].x = level.remote_turret_hud[ "incl_mark_left" ].x - 10;
		level.remote_turret_pitch_numbers_left[ i ].sort -= 1;
	}
	
	level.remote_turret_pitch_lines_right = [];
	for ( i = 0; i < 11; i++ )
	{
		level.remote_turret_pitch_lines_right[ i ] = createClientIcon( "white", Int( level.remote_turret_hud[ "hash_bkg_right" ].width * 0.5 ), 1 );
		level.remote_turret_pitch_lines_right[ i ] set_default_hud_parameters();
		level.remote_turret_pitch_lines_right[ i ].alignX = "left";
		level.remote_turret_pitch_lines_right[ i ].alignY = "middle";
		level.remote_turret_pitch_lines_right[ i ].horzAlign = "right";
		level.remote_turret_pitch_lines_right[ i ].vertAlign = "middle";
		level.remote_turret_pitch_lines_right[ i ].x = 0 - sidebar_x;
		level.remote_turret_pitch_lines_right[ i ].sort += 1;
	}
	
	level.remote_turret_pitch_lines_mini_right = [];
	for ( i = 0; i < level.remote_turret_pitch_lines_right.size; i++ )
	{
		level.remote_turret_pitch_lines_mini_right[ i ] = createClientIcon( "white", Int( level.remote_turret_pitch_lines_right[ i ].width * 0.5 ), 1 );
		level.remote_turret_pitch_lines_mini_right[ i ] set_default_hud_parameters();
		level.remote_turret_pitch_lines_mini_right[ i ].alignX = "left";
		level.remote_turret_pitch_lines_mini_right[ i ].alignY = "middle";
		level.remote_turret_pitch_lines_mini_right[ i ].horzAlign = "right";
		level.remote_turret_pitch_lines_mini_right[ i ].vertAlign = "middle";
		level.remote_turret_pitch_lines_mini_right[ i ].x = 0 - sidebar_x;
		level.remote_turret_pitch_lines_mini_right[ i ].sort += 1;
	}
	
	level.remote_turret_pitch_numbers_right = [];
	for ( i = 0; i < level.remote_turret_pitch_lines_right.size; i++ )
	{
		level.remote_turret_pitch_numbers_right[ i ] = createClientFontString( "default", 0.8 );
		level.remote_turret_pitch_numbers_right[ i ] set_default_hud_parameters();
		level.remote_turret_pitch_numbers_right[ i ].alignX = "left";
		level.remote_turret_pitch_numbers_right[ i ].alignY = "middle";
		level.remote_turret_pitch_numbers_right[ i ].horzAlign = "right";
		level.remote_turret_pitch_numbers_right[ i ].vertAlign = "middle";
		level.remote_turret_pitch_numbers_right[ i ].x = level.remote_turret_hud[ "incl_mark_right" ].x + 10;
		level.remote_turret_pitch_numbers_right[ i ].sort -= 1;
	}
	
	self thread remote_turret_update_status();
	self thread remote_turret_update_reticle();
	self thread remote_turret_update_compass();
	self thread remote_turret_update_pitch();
	self thread remote_turret_update_zoom();
	self thread remote_turret_static_overlay();
}

remote_turret_clear_hud()
{	
	keys = getArrayKeys( level.remote_turret_hud );
	foreach ( key in keys )
	{
		level.remote_turret_hud[ key ] Destroy();
		level.remote_turret_hud[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_compass_lines );
	foreach ( key in keys )
	{
		level.remote_turret_compass_lines[ key ] Destroy();
		level.remote_turret_compass_lines[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_compass_numbers );
	foreach ( key in keys )
	{
		level.remote_turret_compass_numbers[ key ] Destroy();
		level.remote_turret_compass_numbers[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_pitch_lines_left );
	foreach ( key in keys )
	{
		level.remote_turret_pitch_lines_left[ key ] Destroy();
		level.remote_turret_pitch_lines_left[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_pitch_lines_mini_left );
	foreach ( key in keys )
	{
		level.remote_turret_pitch_lines_mini_left[ key ] Destroy();
		level.remote_turret_pitch_lines_mini_left[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_pitch_numbers_left );
	foreach ( key in keys )
	{
		level.remote_turret_pitch_numbers_left[ key ] Destroy();
		level.remote_turret_pitch_numbers_left[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_pitch_lines_right );
	foreach ( key in keys )
	{
		level.remote_turret_pitch_lines_right[ key ] Destroy();
		level.remote_turret_pitch_lines_right[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_pitch_lines_mini_right );
	foreach ( key in keys )
	{
		level.remote_turret_pitch_lines_mini_right[ key ] Destroy();
		level.remote_turret_pitch_lines_mini_right[ key ] = undefined;
	}
	
	keys = getArrayKeys( level.remote_turret_pitch_numbers_right );
	foreach ( key in keys )
	{
		level.remote_turret_pitch_numbers_right[ key ] Destroy();
		level.remote_turret_pitch_numbers_right[ key ] = undefined;
	}
}

remote_turret_update_status()
{
	self endon( "remote_turret_deactivate" );
	
	self NotifyOnPlayerCommand( "firing", "+attack" );

	while( 1 )
	{
		if ( self GetCurrentWeaponClipAmmo() <= 0 || self IsReloading() )
		{
			level.remote_turret_hud[ "weapon_status_txt" ] SetText( &"ENEMY_HQ_RELOADING" );
			level.remote_turret_hud[ "weapon_status_txt" ].alpha = 0.5;
			level.remote_turret_hud[ "weapon_status_bg" ].alpha = 0.25;
		
			while ( self GetCurrentWeaponClipAmmo() <= 0 || self IsReloading() )
			{
				wait 0.05;
			}
		}
		
		level.remote_turret_hud[ "weapon_status_txt" ] SetText( &"ENEMY_HQ_TARGETING" );
		level.remote_turret_hud[ "weapon_status_txt" ].alpha = 1;
		level.remote_turret_hud[ "weapon_status_bg" ].alpha = 0.5;
		
		self waittill( "firing" );
		
		level.remote_turret_hud[ "weapon_status_txt" ] SetText( &"ENEMY_HQ_FIRING" );
		level.remote_turret_hud[ "weapon_status_txt" ].alpha = 1;
		level.remote_turret_hud[ "weapon_status_bg" ].alpha = 0.5;
		level.remote_turret_hud[ "weapon_status_bg" ] SetShader( "red_block", level.remote_turret_hud[ "weapon_status_bg" ].width, level.remote_turret_hud[ "weapon_status_bg" ].height );
		
		clip_pct = self GetCurrentWeaponClipAmmo() / WeaponClipSize( self GetCurrentWeapon() );
		level.remote_turret_hud[ "weapon_name_bar" ] SetShader( "green_block", Int( max( 1, clip_pct * level.remote_turret_hud[ "weapon_name_bar_bg" ].width * 0.6 ) ), level.remote_turret_hud[ "weapon_name_bar" ].height );
		
		if ( clip_pct == 0 )
		{
			level.remote_turret_hud[ "weapon_name_bar" ].alpha = 0;
		}
		else
		{
			level.remote_turret_hud[ "weapon_name_bar" ].alpha = 0.5;
		}
		
		wait 0.25;
		
		level.remote_turret_hud[ "weapon_status_bg" ] SetShader( "black", level.remote_turret_hud[ "weapon_status_bg" ].width, level.remote_turret_hud[ "weapon_status_bg" ].height );
	}
}

remote_turret_update_reticle()
{
	self endon( "remote_turret_deactivate" );
	
	while ( 1 )
	{
		if ( IsDefined( level.remote_turret_trace[ "entity" ] ) && IsAI( level.remote_turret_trace[ "entity" ] ) && level.remote_turret_trace[ "entity" ] IsBadGuy() )
		{
			if ( level.remote_turret_hud[ "reticle_red" ].alpha == 0 )
			{
				level.remote_turret_hud[ "reticle_red" ].alpha = level.remote_turret_hud[ "reticle" ].alpha;
				level.remote_turret_hud[ "reticle" ].alpha = 0;
				
				level.remote_turret_hud[ "incl_mark_left_red" ].alpha = level.remote_turret_hud[ "incl_mark_left" ].alpha;
				level.remote_turret_hud[ "incl_mark_left" ].alpha = 0;
				
				level.remote_turret_hud[ "incl_mark_right_red" ].alpha = level.remote_turret_hud[ "incl_mark_right" ].alpha;
				level.remote_turret_hud[ "incl_mark_right" ].alpha = 0;
			}
		}
		else if ( level.remote_turret_hud[ "reticle" ].alpha == 0 )
		{
			level.remote_turret_hud[ "reticle" ].alpha = level.remote_turret_hud[ "reticle_red" ].alpha;
			level.remote_turret_hud[ "reticle_red" ].alpha = 0;
				
			level.remote_turret_hud[ "incl_mark_left" ].alpha = level.remote_turret_hud[ "incl_mark_left_red" ].alpha;
			level.remote_turret_hud[ "incl_mark_left_red" ].alpha = 0;
			
			level.remote_turret_hud[ "incl_mark_right" ].alpha = level.remote_turret_hud[ "incl_mark_right_red" ].alpha;
			level.remote_turret_hud[ "incl_mark_right_red" ].alpha = 0;
		}
		
		wait 0.05;
	}
}

remote_turret_update_range()
{
	level.player endon( "remote_turret_deactivate" );
	
	while ( 1 )
	{
		level.remote_turret_trace = BulletTrace( level.player GetEye(), level.player GetEye() + AnglesToForward( level.player GetPlayerAngles() ) * 36000, true, level.player, true, true, true );
		
		range = Int( Distance( level.player GetEye(), level.remote_turret_trace[ "position" ] ) / 36 );
		
		self SetText( range + ter_op( level.remote_turret_trace[ "fraction" ] == 1.0, "+", "" ) );
		wait 0.05;
	}
}

remote_turret_update_wind()
{
	level.player endon( "remote_turret_deactivate" );
	
	wind = RandomFloatRange( 0, 20 );
	
	while ( 1 )
	{
		switch ( RandomInt( 50 ) )
		{
			case 0:
				wind += RandomFloatRange( 2, 5 );
				break;
				
			case 1:
				wind -= RandomFloatRange( 2, 5 );
				break;
				
			default:
				wind += RandomFloatRange( -0.5, 0.5 );
				break;
		}
		
		wind = Clamp( wind, 0, 20 );
		
		self SetText( Int( wind * 10 ) / 10 + ter_op( modulus( Int( wind * 10 ), 10 ) == 0, ".0", "" ) );
		
		wait RandomFloatRange( 0.5, 1 );
	}
}

remote_turret_update_air_temp()
{
	level.player endon( "remote_turret_deactivate" );
	
	air_temp = RandomFloatRange( 70, 85 );
	
	while ( 1 )
	{
		switch ( RandomInt( 10 ) )
		{
			case 0:
			case 1:
				air_temp -= RandomFloatRange( 0.05, 0.1 );
				break;
				
			default:
				air_temp += RandomFloatRange( 0.025, 0.075 );
				break;
		}
		
		air_temp = Clamp( air_temp, 70, 85 );
		
		self SetText( Int( air_temp * 10 ) / 10 + ter_op( modulus( Int( air_temp * 10 ), 10 ) == 0, ".0", "" ) );
		
		wait RandomFloatRange( 5, 10 );
	}
}

remote_turret_update_humidity()
{
	level.player endon( "remote_turret_deactivate" );
	
	humidity = RandomFloatRange( 45, 95 );
	
	while ( 1 )
	{
		humidity += RandomFloatRange( -0.1, 0.1 );
		
		humidity = Clamp( humidity, 45, 95 );
		
		self SetText( Int( humidity * 100 ) / 100 + ter_op( modulus( Int( humidity * 100 ), 10 ) == 0, "0", "" ) );
		
		wait RandomFloatRange( 1, 3 );
	}
}

remote_turret_update_compass()
{
	self endon( "remote_turret_deactivate" );
	
	north = GetNorthYaw();
	left_x = level.remote_turret_hud[ "compass_bracket_left" ].x + 10;
	right_x = level.remote_turret_hud[ "compass_bracket_right" ].x - 10;
	
	angle_increments = 1;
	
	spacing = ( right_x - left_x ) / level.remote_turret_compass_numbers.size;
	
	while ( 1 )
	{
		yaw = AngleClamp( self GetPlayerAngles()[ 1 ] - north );
		
		if ( yaw < 11.25 || yaw > 348.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_NORTH" );
		}
		else if ( yaw < 33.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_NORTH_BY_NORTHEAST" );
		}
		else if ( yaw < 56.25 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_NORTHEAST" );
		}
		else if ( yaw < 78.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_EAST_BY_NORTHEAST" );
		}
		else if ( yaw < 101.25 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_EAST" );
		}
		else if ( yaw < 123.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_EAST_BY_SOUTHEAST" );
		}
		else if ( yaw < 146.25 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_SOUTHEAST" );
		}
		else if ( yaw < 168.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_SOUTH_BY_SOUTHEAST" );
		}
		else if ( yaw < 191.25 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_SOUTH" );
		}
		else if ( yaw < 213.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_SOUTH_BY_SOUTHWEST" );
		}
		else if ( yaw < 236.25 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_SOUTHWEST" );
		}
		else if ( yaw < 258.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_WEST_BY_SOUTHWEST" );
		}
		else if ( yaw < 281.25 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_WEST" );
		}
		else if ( yaw < 303.75 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_WEST_BY_NORTHWEST" );
		}
		else if ( yaw < 326.25 )
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_NORTHWEST" );
		}
		else
		{
			level.remote_turret_hud[ "compass_heading" ] SetText( &"ENEMY_HQ_NORTH_BY_NORTHWEST" );
		}
		
		start_x = left_x + ( 1.0 - ( modulus( abs( yaw ), angle_increments ) / angle_increments ) ) * spacing;
	
		angle = Int( yaw / angle_increments ) * angle_increments - ( angle_increments * ( Int( level.remote_turret_compass_numbers.size / 2 ) - ( ter_op( modulus( abs( yaw ), angle_increments ) < angle_increments / 2, 0, 1 ) ) ) );
		
		if ( angle < 0 )
		{
			angle += 360;
		}
		
		for ( i = 0; i < level.remote_turret_compass_numbers.size; i++ )
		{
			level.remote_turret_compass_lines[ i ].x = start_x + i * spacing;
			
			level.remote_turret_compass_numbers[ i ].x = start_x + ( i + 0.5 ) * spacing;
			level.remote_turret_compass_numbers[ i ] SetText( Int( angle ) );
			
			if ( modulus( abs( yaw ), angle_increments ) < angle_increments / 2 )
			{
				level.remote_turret_compass_numbers[ i ].x -= spacing;
			}
			
			angle += angle_increments;
			if ( angle > 360 )
			{
				angle -= 360;
			}
		}
		
		wait 0.05;
	}
}

remote_turret_update_pitch()
{
	self endon( "remote_turret_deactivate" );

	top = level.remote_turret_hud[ "hash_bkg_left" ].y - level.remote_turret_hud[ "hash_bkg_left" ].height * 0.28;
	bottom = level.remote_turret_hud[ "hash_bkg_left" ].y + level.remote_turret_hud[ "hash_bkg_left" ].height * 0.28;
	
	angle_increments = 2;
	
	spacing = ( bottom - top ) / level.remote_turret_pitch_numbers_left.size;
	
	line_max_alpha = 0.5;
	
	start_fade_height = ( bottom - top ) * 0.25;
	
	while ( 1 )
	{
		pitch = AngleClamp( self GetPlayerAngles()[ 0 ] );
		
		start_y = top + ( 1.0 - ( modulus( pitch, angle_increments ) / angle_increments ) ) * spacing;
	
		angle = 0 - Int( AngleClamp180( pitch ) / angle_increments ) * angle_increments + ( angle_increments * ( Int( level.remote_turret_pitch_numbers_left.size / 2 ) - ter_op( modulus( pitch, angle_increments ) < angle_increments / 2, 0, 1 ) + ter_op( pitch > 180, 1, 0 ) ) );

		for ( i = 0; i < level.remote_turret_pitch_numbers_left.size; i++ )
		{
			level.remote_turret_pitch_lines_left[ i ].y = start_y + ( i + ter_op( modulus( pitch, angle_increments ) < angle_increments / 2, -0.5, 0.5 ) ) * spacing;
			level.remote_turret_pitch_lines_left[ i ].alpha = line_max_alpha * clamp( abs( ter_op( i < level.remote_turret_pitch_numbers_left.size / 2, top, bottom ) - level.remote_turret_pitch_lines_left[ i ].y ) / start_fade_height, 0.0, 1.0 );
			
			level.remote_turret_pitch_lines_mini_left[ i ].y = start_y + i * spacing;
			level.remote_turret_pitch_lines_mini_left[ i ].alpha = line_max_alpha * clamp( abs( ter_op( i < level.remote_turret_pitch_numbers_left.size / 2, top, bottom ) - level.remote_turret_pitch_lines_mini_left[ i ].y ) / start_fade_height, 0.0, 1.0 );
			
			level.remote_turret_pitch_numbers_left[ i ].y = level.remote_turret_pitch_lines_left[ i ].y;
			level.remote_turret_pitch_numbers_left[ i ].alpha = clamp( abs( ter_op( i < level.remote_turret_pitch_numbers_left.size / 2, top, bottom ) - level.remote_turret_pitch_numbers_left[ i ].y ) / start_fade_height, 0.0, 1.0 );
			level.remote_turret_pitch_numbers_left[ i ] SetText( Int( angle ) );
			
			level.remote_turret_pitch_lines_right[ i ].y = level.remote_turret_pitch_lines_left[ i ].y;
			level.remote_turret_pitch_lines_right[ i ].alpha = level.remote_turret_pitch_lines_left[ i ].alpha;
			
			level.remote_turret_pitch_lines_mini_right[ i ].y = level.remote_turret_pitch_lines_mini_left[ i ].y;
			level.remote_turret_pitch_lines_mini_right[ i ].alpha = level.remote_turret_pitch_lines_mini_left[ i ].alpha;
			
			level.remote_turret_pitch_numbers_right[ i ].y = level.remote_turret_pitch_numbers_left[ i ].y;
			level.remote_turret_pitch_numbers_right[ i ].alpha = level.remote_turret_pitch_numbers_left[ i ].alpha;
			level.remote_turret_pitch_numbers_right[ i ] SetText( Int( angle ) );

			angle -= angle_increments;
		}
		
		wait 0.05;
	}
}

remote_turret_update_zoom()
{
	self endon( "remote_turret_deactivate" );
	
	while ( 1 )
	{
		zoom_level = 65 / GetDvarFloat( "cg_fov" );
		zoom_level = Int( zoom_level * 10 ) / 10;
		
		zoom_txt = "" + zoom_level + ter_op( modulus( zoom_level, 10 ) == 0, ".0 X", " X" );
		
		level.remote_turret_hud[ "zoom_txt" ] SetText( zoom_txt );
		
		wait 0.05;
	}
}

remote_turret_update_scanline()
{
	level.player endon( "remote_turret_deactivate" );
	
	while ( 1 )
	{
		self.y = -400;
		self MoveOverTime( 2 );
		self.y = 400;
		wait 2;
	}
}

remote_turret_static_overlay()
{
	static = newClientHudElem( self );
	static.x = 0;
	static.y = 0;
	static.alignX = "left";
	static.alignY = "top";
	static.horzAlign = "fullscreen";
	static.vertAlign = "fullscreen";
	static setshader( "overlay_static", 640, 480 );
	static.alpha = 0.1;
	static.sort = -3;
	
	ending = self waittill_any_return( "remote_turret_deactivate","fadeup_static_finale" );
	if( ending == "fadeup_static_finale" )
	{
		while(static.alpha < 1.0)
		{
			static.alpha += 0.05;
			wait 0.25;
		}
		IPrintLnBold("Out of Range.");
		self notify( "finished_static_fadeup");
	
		self waittill( "remote_turret_deactivate" );
		
	}
	static Destroy();
}

remote_turret_handle_zoom()
{
	self endon( "remote_turret_deactivate" );
	self endon( "remote_turret_nozoom" );
	
	lastLeftStick = 0;

	level.remote_turret_firing_slow_aim_modifier = 0.0;
	
	while ( 1 )
	{
		leftStick = self GetNormalizedMovement();
		
		if ( leftStick[ 0 ] == 0 )
		{
			wait 0.05;
			continue;
		}
		
		if ( ( lastLeftStick <= 0 && leftStick[ 0 ] > 0 ) || ( lastLeftStick >= 0 && leftStick[ 0 ] < 0 ) )
		{
			// DoF change
			self thread remote_turret_lerp_DoF();
		}
		
		
		scalar = level.remote_turret_current_fov / 20.0;
		scalar = min(3,scalar);
		scalr = max(0.5,scalar);
		
		level.remote_turret_current_fov -= leftStick[ 0 ] * scalar;
		
		if ( level.remote_turret_current_fov < level.remote_turret_min_fov )
		{
			level.remote_turret_current_fov = level.remote_turret_min_fov;
		}
		else if ( level.remote_turret_current_fov > level.remote_turret_max_fov )
		{
			level.remote_turret_current_fov = level.remote_turret_max_fov;
		}
		
		self LerpFOV( level.remote_turret_current_fov, 0.05 );
		
		set_slow_aim();
		
		wait 0.05;
	}	
}

set_slow_aim()
{
	fov_pct = ( level.fov_range - ( level.remote_turret_max_fov - level.remote_turret_current_fov ) ) / level.fov_range;
	
	level.remote_turret_current_slow_yaw = level.remote_turret_min_slow_aim_yaw + ( level.slow_aim_yaw_range * fov_pct ) + level.remote_turret_firing_slow_aim_modifier;
	level.remote_turret_current_slow_pitch = level.remote_turret_min_slow_aim_pitch + ( level.slow_aim_pitch_range * fov_pct ) + level.remote_turret_firing_slow_aim_modifier;
	
	self EnableSlowAim( level.remote_turret_current_slow_pitch, level.remote_turret_current_slow_yaw );
}

remote_turret_lerp_DoF( lerp_time )
{
	if( !IsDefined(lerp_time) )
		lerp_time = 0.5;
	self notify( "remote_turret_lerp_dof" );
	self endon( "remote_turret_lerp_dof" );
	
	maps\_art::dof_enable_script( 50, 100, 10, 100, 200, 6, 0.0 );
	maps\_art::dof_disable_script( lerp_time );
}


remote_turret_monitor_dryfire( weap )
{	
	self NotifyOnPlayerCommand( "attack", "+attack" );
	
	self waittill( "attack" );
		
	if ( self GetCurrentWeapon() == weap )
	{
		flag_set("checkit_dryfire");
	}
}

remote_turret_monitor_ammo( weap )
{	
	self NotifyOnPlayerCommand( "attack", "+attack" );
	
	while ( 1 )
	{
		self waittill( "attack" );
		duration = 0.5;
		radius = 200;

		if ( self GetCurrentWeapon() != weap )
		{
			return;
		}
		Earthquake(0.1,0.3,self.origin,100);
		level.player PlayRumbleOnEntity( "heavygun_fire" );
		
		if ( self GetAmmoCount( weap ) <= 0 )
		{
			if( !IsDefined(self.remote_canreload) || self.remote_canreload == 0 )
				self thread remote_turret_deactivate();
			else
			{
				IPrintLnBold("Reloading...");
				IPrintLnBold("Whirring, mechanical reloady type noises here.");
				wait 0.6;
				self SetWeaponAmmoClip( weap, 10 );
				IPrintLnBold("Reloaded.Resume death-dealing.");
			}
			
						 
		}
	}
}

update_remote_turret_targets()
{
	self endon( "remote_turret_deactivate" );
	
	SetSavedDvar( "r_hudoutlineenable", 1 );
	
	if ( IsDefined( level.dog ) )
	{
		level.dog HudOutlineEnable( 0 );
	}
	
	while ( 1 )
	{
		foreach ( ai in GetAIArray() )
		{
			if ( !IsDefined( ai ) || ( IsDefined( ai.has_target_shader ) && ai.has_target_shader ) )
			{
				continue;
			}
			
			ai.has_target_shader = true;

			if ( ai.team == "axis" )
			{
				ai HudOutlineEnable( 1 );
			}
			else
			{
				ai HudOutlineEnable( 0 );
			}
			
			ai thread remove_remote_turret_target_on_death();
		}
		
		wait 0.05;
	}
}

remove_remote_turret_target_on_death()
{
	level.player endon( "remote_turret_deactivate" );
	
	self waittill( "death" );
	
	self HudOutlineDisable();
}

remove_remote_turret_targets()
{
	while ( 1 )
	{
		level.player waittill( "remote_turret_deactivate" );
		
		foreach ( ai in GetAIArray() )
		{
			ai HudOutlineDisable();
			ai.has_target_shader = undefined;
		}
	}
}

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
	self.alpha = 1;
}

modulus( dividend, divisor )
{
	q = Int( dividend / divisor );
	return dividend - ( q * divisor );
}

