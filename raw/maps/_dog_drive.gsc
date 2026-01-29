#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

#using_animtree( "dog" );

DOG_MAX_ANGLE_LIMIT = 180;
DOG_MAX_DISPLAY_DIST = 300;
DOG_MAX_ATTACK_DIST = 85;

dog_drive_indirect( dog )
{
	default_dof( 0.1 );
	thread maps\_audio::set_filter( "dog_camera" );
	
	dog disable_ai_color();
	level.dog_flush_functions[ "jumpup" ] = ::dog_jumpup;
	
	if ( dog ent_flag_exist( "pause_dog_command" ) )
		dog ent_flag_set( "pause_dog_command" );
	
	if ( !dog ent_flag_exist( "dogcam_acquire_targets" ) )
		dog ent_flag_init( "dogcam_acquire_targets" );
	dog ent_flag_set( "dogcam_acquire_targets" );
	dog.controlling_dog = true;
	
	self.controlled_dog = dog;
	self LerpFOV( 90, 0.05 );
	self EnableSlowAim( 0.3, 0.3 );
	self DisableWeapons();
	self AllowCrouch( false );
	self AllowStand( true );
	self AllowProne( true );
	self AllowSprint( false );

	self.ignoreme = true;
	self EnableInvulnerability();
	
	self.overlays = [];
	self.overlays[ self.overlays.size ] = self maps\_hud_util::create_client_overlay( "dogcam_edge", 1, self );
	self.overlays[self.overlays.size-1].foreground = false;
//	self.overlays[self.overlays.size-1].sort = 99;
	
	self.overlays[ self.overlays.size ] = self maps\_hud_util::create_client_overlay( "dogcam_dirt", 1, self );
	self.overlays[self.overlays.size-1].foreground = false;

	hudelem = level.player createClientIcon( "dogcam_targeting_circle", 150, 150 );
	hudelem setPoint( "CENTER", undefined, 1, -5, 0 );
	hudelem.color = (1,0,0);
	hudelem.alpha = 0;
	self.hud_target_lock = hudelem;
	self.overlays[ self.overlays.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "dogcam_center", 600, 300 );
	hudelem setPoint( "CENTER", undefined, 0, 0, 0 );
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientIcon( "dogcam_compass", 250, 35 );
	hudelem setPoint( "TOP", "TOP", 0, 10, 0 );
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientIcon( "dogcam_battery", 100, 12 );
	hudelem setPoint( "RIGHT TOP", "RIGHT TOP", 0, 25, 0 );
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientIcon( "dogcam_frame_top", 600, 40 );
	hudelem setPoint( "TOP", "TOP", 0, -20, 0 );
	self.overlays[ self.overlays.size ] = hudelem;		
	
	hudelem = level.player createClientIcon( "dogcam_frame_bot", 600, 80 );
	hudelem setPoint( "BOTTOM", "BOTTOM", 0, 32, 0 );
	self.overlays[ self.overlays.size ] = hudelem;	
	
	hudelem = level.player createClientIcon( "dogcam_timestamp", 200, 50 );
	hudelem setPoint( "LEFT BOTTOM", "LEFT BOTTOM", 14, -25, 0 );
	self.overlays[ self.overlays.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "dogcam_rec", 50, 50 );
	hudelem setPoint( "LEFT BOTTOM", "LEFT BOTTOM", 0, -11.5, 0 );
	hudelem thread rec_blink();
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientIcon( "dogcam_vision_off", 180, 50 );
	hudelem setPoint( "RIGHT BOTTOM", "RIGHT BOTTOM", 0, -25, 0 );
	self.attack_indicator_off = hudelem;
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientIcon( "dogcam_vision_on", 180, 50 );
	hudelem setPoint( "RIGHT BOTTOM", "RIGHT BOTTOM", 0, -25, 0 );
	self.overlays[ self.overlays.size ] = hudelem;
	self.attack_indicator_on = hudelem;
	hudelem.alpha = 0;
	
	hudelem = level.player createClientIcon( "dogcam_bracket_r", 60, 400 );
	hudelem setPoint( "RIGHT", "RIGHT", 0, 0, 0 );
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientIcon( "dogcam_bracket_l", 69, 400 );
	hudelem setPoint( "LEFT", "LEFT", 0, 0, 0 );
	self.overlays[ self.overlays.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "dogcam_scanline", 1600, 75 );
	hudelem setPoint( "CENTER", undefined, 0, 0, 0 );
	hudelem thread scanline_move();
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientFontString( "default", 0.8 );
	hudelem setPoint( "RIGHT BOTTOM", "LEFT BOTTOM", 188.5, -51, 0 );
	hudelem setText( "00 : 00   00" );
	hudelem.alpha = 0.4;
	hudelem thread time_countup();
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientFontString( "default", 0.7 );
	hudelem setPoint( "CENTER", "CENTER", 0, 55, 0 );
	hudelem setText( "" );
	hudelem.alpha = 0.5;
	self.hud_enemy_tracker = hudelem;
	self.overlays[ self.overlays.size ] = hudelem;

	hudelem = level.player createClientFontString( "default", 0.8 );
	hudelem setPoint( "CENTER", "RIGHT BOTTOM", -75, -66, 0 );
	hudelem setText( "" );
	hudelem.alpha = 0.5;
	self.hud_enemy_tracker_range = hudelem;
	self.overlays[ self.overlays.size ] = hudelem;
	
//	self ThermalVisionOn();
	
	dog ThermalDrawDisable();
	dog.turnRate = 0.15;
	dog disable_exits();
	dog disable_arrivals();
	setSavedDvar( "r_znear", 0 );
	setSavedDvar( "compass", 0 );
	setSavedDvar( "hud_showstance", 0 );
	
	dog walkdist_zero();
	dog.dontchangepushplayer = true;
	dog pushplayer( true );
	
	org = Spawn("script_model", (0,0,0));
	org setModel( "tag_player" );
	org linkTo( dog, "tag_camera", (0,0,0), (0,0,0) );
	dog.camera_tag = org;

	spawn_model_fx( (0,0,0), (0,0,0) );
	
	self PlayerLinkWeaponViewToDelta( org, "tag_player", 0, DOG_MAX_ANGLE_LIMIT, DOG_MAX_ANGLE_LIMIT, 15, 15, true );
	self PlayerLinkedSetViewZnear( false );
	
	level.see_enemy_dot = 0.85;
	level.see_enemy_dot_close = 0.95;
	
	self.dog_track_range = DOG_MAX_DISPLAY_DIST;
	self.dog_attack_range = DOG_MAX_ATTACK_DIST;
	
	dog setDogCommand( "driven" );
	dog setDogMaxDriveSpeed( 80 );
	dog SetDogAutoAttackWhenDriven( false );
	
	org PlayLoopSound( "ambient_dog_camera" );
	
	cam_org = dog spawn_tag_origin();
	cam_org linkTo( dog, "tag_camera", (0,0,0), (0,0,0) );
	
	dog.cam_sound_sources = [];
	dog.cam_sound_sources = array_add( dog.cam_sound_sources, cam_org );
	
	//self thread dog_indirect_control_input( dog );
	self thread dog_wait_for_attack( dog );
	self thread sound_on_stick_movement( dog, cam_org );
	self thread lerp_on_attack( dog );
	self thread detect_sprint_click( dog );
	self thread nearby_enemy_tracking( dog );
	self thread dog_bark( level.dog );
}

default_dof( time )
{
	maps\_art::dof_enable_script( 1, 80, 3, 1500, 4500, 3, time );
}

nearby_enemy_tracking( dog )
{
	self.hud_enemy_tracker endon( "death" );
	self endon( "stop_dog_drive" );
	
	had_target = false;
	was_tracking_target = false;
	
	while ( 1 )
	{
		angles = self getPlayerAngles();
		old_guy = undefined;
		if ( isdefined( dog.closest_enemy_in_range ) )
			old_guy = dog.closest_enemy_in_range;
		enemy = self find_nearby_enemy( self.dog_track_range, angles );
		dog.closest_enemy_in_range = enemy;
		
		if ( isdefined( old_guy ) )
			if ( !isdefined( enemy ) || enemy != old_guy )
				old_guy thread hud_outlineEnable( 0 );
		
		self.attack_indicator_off.alpha = 1;
		self.attack_indicator_on.alpha = 0;
		
		if ( isdefined( enemy ) )
		{
			
			inch_dist = Distance2d( dog.origin, enemy.origin );
			dist = inch_dist * 0.0254;
			
			enemy.dist_to_dog = inch_dist;
			
			numbers = strtok( dist + "", "." );
			short_num = "0";
			if ( numbers.size > 1 )
			{
				short_num = numbers[1][0];
			}
			
			self.hud_enemy_tracker setText( "TGT: " + numbers[0] + "." + short_num + " M" );
			
			if ( inch_dist <= self.dog_attack_range )
			{
				if ( dog ent_flag( "dogcam_acquire_targets" ) )
				{
					self.hud_enemy_tracker_range setText( "TARGET IN RANGE" );
					self.hud_target_lock.alpha = 1;
					self.hud_target_lock.color = (1,0,0);
					if ( !had_target )
					{
						self notify( "dogcam_acquired_target" );
						self thread play_sound_on_entity( "scn_nml_camera_enemy_in_range" );
						enemy thread hud_outlineEnable( 1 );
					}
					was_tracking_target = false;
					had_target = true;
					self.attack_indicator_off.alpha = 0;
					self.attack_indicator_on.alpha = 1;
				}
			}
			else
			{
				self.hud_target_lock.alpha = 1;
				self.hud_target_lock.color = (0.2,0,0);
				self.hud_enemy_tracker_range setText( "TARGET OUT OF RANGE" );
				had_target = false;
				if ( !was_tracking_target )
				{
					self thread play_sound_on_entity("scn_nml_camera_enemy_contact_on");
				}								
				was_tracking_target = true;
				enemy thread hud_outlineEnable( 0 );
			}
		}
		else
		{
			self.hud_target_lock.alpha = 0;
			self.hud_enemy_tracker setText( "" );
			self.hud_enemy_tracker_range setText( "" );
			if ( was_tracking_target )
			{
				self thread play_sound_on_entity("scn_nml_camera_enemy_contact_off");
			}
			had_target = false;
			was_tracking_target = false;
		}
		
		if ( !was_tracking_target )
		{
			//self thread stop_loop_sound_on_entity( "ui_binoc_scan_loop" );
		}
		
		wait( 0.05 );
	}
}

spawn_model_fx( offset1, offset2 )
{
	self.crt_plane = Spawn( "script_model", (0,0,0) );
	self.crt_plane setModel( "torpedo_crtplane" );
	self.crt_plane LinkToPlayerView( self, "tag_origin", (2,0,0) + offset1, (0,-90,0), true );

	self.screen_glitch_org = spawn( "script_model", (0,0,0) );
	self.screen_glitch_org setModel( "tag_origin" );
	self.screen_glitch_org.origin = level.player.origin;
	self.screen_glitch_org LinkToPlayerView( level.player, "tag_origin", (25,0,0) + offset2, (0,180,0), true );
	
	self thread maps\_dog_drive::screen_glitches();
}

delete_model_fx()
{
	self.crt_plane delete();	
	self.screen_glitch_org delete();
}

scanline_move()
{
	self endon( "death" );
	
	self childthread scanline_flicker();
	
	self MoveOverTime( 8 );
	self.y = 400;
	wait( 8 );
	
	while( 1 )
	{
		wait( 0.05 );
		self.y = -400;
		wait( 0.05 );
		self MoveOverTime( 16 );
		self.y = 400;
		wait( 16 );
	}
}

rec_blink()
{
	self endon( "death" );
	
	while( 1 )
	{
		self.alpha = 0;
		wait( 0.75 );
		self.alpha = 1;
		wait( 0.75 );
	}
}

time_countup()
{
	self endon( "death" );
	start_time = getTime();
	while( 1 )
	{
		mins_extra = "";
		secs_extra = "";
		mili_extra = "";
		time = getTime();
		
		mins = int( time / 60000 );
		time -= mins * 60000;
		if ( mins < 10 )
			mins_extra = "0";
		
		secs = int( time / 1000 );
		time -= secs * 1000;
		if ( secs < 10 )
			secs_extra = "0";
		
		mili = int( time / 10 );
		if ( mili < 10 )
			mili_extra = "0";
		self setText( mins_extra + mins + " : " + secs_extra + secs + "   " + mili_extra + mili );
		wait( 0.05 );
	}
}

scanline_flicker()
{
	while( 1 )
	{
		self FadeOverTime( 2 );
		self.alpha = 0.3;
		wait( 2 );
		self FadeOverTime( 2 );
		self.alpha = 1;
		wait( 2 );
	}
}

screen_glitches()
{
	self.screen_glitch_org endon( "death" );
	self endon( "disable_screen_glitch" );
	
	while( 1 )
	{
		if ( isdefined( level._effect[ "screen_glitch" ] ) )
			PlayFXOnTag( getfx( "screen_glitch" ), self.screen_glitch_org, "tag_origin" );
		level.player thread play_sound_on_entity( "scn_nml_camera_flicker_short" );
		self waittill_notify_or_timeout( "do_screen_glitch", RandomFloatRange( 5, 8 ) );
	}
}

constant_screen_glitches()
{
	self.screen_glitch_org endon( "death" );
	self endon( "stop_constant_glitch" );
	
	while( 1 )
	{
		if ( isdefined( level._effect[ "screen_glitch" ] ) )
			PlayFXOnTag( getfx( "screen_glitch" ), self.screen_glitch_org, "tag_origin" );		
		self waittill_notify_or_timeout( "do_screen_glitch", 0.05 );
	}
}

dog_drive_indirect_disable( dog )
{
	maps\_art::dof_disable_script( 0.75 );
	maps\_audio::clear_filter();
	
	ai = getAIArray( "axis" );
	foreach ( a in ai )
	{
		a HudOutlineDisable();
	}
	
	dog setDogCommand( "attack" );
	dog.controlling_dog = undefined;
	
	if ( dog ent_flag_exist( "pause_dog_command" ) )
		dog ent_flag_clear( "pause_dog_command" );
		
	self notify( "stop_dog_drive" );
	self unlink();
	self enableWeapons();
//	self ThermalVisionOff();
	self DisableInvulnerability();
	self.ignoreme = false;
	self LerpFOV( 65, 0.05 );
	self DisableSlowAim();
	
	self AllowCrouch( true );
	self AllowStand( true );
	self AllowProne( true );
	self AllowSprint( true );

	foreach ( o in self.overlays )
	{
		o destroy();
	}
	self.crt_plane delete();
	self.screen_glitch_org delete();
	setSavedDvar( "r_znear", 4 );
	setSavedDvar( "compass", 1 );
	setSavedDvar( "hud_showstance", 1 );

	dog walkdist_reset();	
	dog.turnRate = 0.2;
	dog.ignoreall = false;
	dog.ignoreme = false;
	dog.camera_tag StopLoopSound();

	self CameraUnlink( dog.camera_tag );
	
	foreach( org in dog.cam_sound_sources )
	{
		org StopLoopSound();
		waitframe();
		org delete();
	}
	dog.camera_tag delete();
	
}

detect_sprint_click( dog )
{
	self endon( "stop_dog_drive" );
	
	self notifyOnPlayerCommand( "clicked_sprint", "+sprint" );
	self notifyOnPlayerCommand( "clicked_sprint", "+sprint_zoom" );
	self notifyOnPlayerCommand( "clicked_sprint", "+breath_sprint" );
	
	dog.sprint = false;
	
	while( 1 )
	{
		self waittill( "clicked_sprint" );
		self LerpViewAngleClamp( 0.3, 0, 0.2, DOG_MAX_ANGLE_LIMIT / 2, DOG_MAX_ANGLE_LIMIT / 2, 4, 4 );
		dog thread play_sound_on_entity( "anml_dog_run_start" );
		dog.sprint = true;
		dog setDogMaxDriveSPeed( 400 );
		dog SetDogAutoAttackWhenDriven( true );
		self thread dog_sprint_disable( dog );
		wait( 1 );
	}
}

dog_sprint_disable( dog )
{
	while( 1 )
	{
		input = self GetNormalizedMovement();
	
		if ( input[0] < 0.98 || dog dog_is_in_combat() )
		{
			dog.sprint = false;
			dog setDogMaxDriveSPeed( 80 );
			dog SetDogAutoAttackWhenDriven( false );
			if ( !dog dog_is_in_combat() )
				self LerpViewAngleClamp( 0.3, 0.1, 0.1, DOG_MAX_ANGLE_LIMIT, DOG_MAX_ANGLE_LIMIT, 15, 15 );			
			return;
		}
		wait( 0.05 );
	}
}

dog_is_in_combat()
{
	return ( self.script == "dog_combat" );
}

sound_on_stick_movement( dog, sound_source )
{
	self endon( "stop_dog_drive" );
	
	playing_sound = false;
	old_dot = 1;
	while( 1 )
	{
		play_sound = false;
		input = self GetNormalizedCameraMovement();
		v1 = AnglesToForward( self getPlayerAngles() );
		v2 = AnglesToForward( dog GetTagAngles( "TAG_CAMERA" ) );
		dot = VectorDot( v1, v2 );
		if ( Distance2d( input, (0,0,0) ) > 0.1 && abs(old_dot - dot) > 0.00 )
		{
			play_sound = true;
		}
		old_dot = dot;
		if ( play_sound != playing_sound )
		{
			if ( play_sound )
			{
				sound_source PlayLoopSound( "dog_cam_mvmnt" );
			}
			else
			{
				sound_source StopLoopSound( "dog_cam_mvmnt" );
			}
			playing_sound = play_sound;
			wait( 0.1 );
		}
		wait( 0.05 );
	}
}

dog_wait_for_attack( dog )
{
	self endon( "stop_dog_drive" );
	
	self notifyOnPlayerCommand( "attack_command", "+attack" );
	self notifyOnPlayerCommand( "attack_command", "+frag" );
	
	while( 1 )
	{
		self waittill( "attack_command" );

		if ( isdefined( dog.closest_enemy_in_range ) )
		{
			if ( isdefined( dog.closest_enemy_in_range.dist_to_dog ) && dog.closest_enemy_in_range.dist_to_dog <= self.dog_attack_range )
			{
				self thread dog_attack_command_internal( dog );
			}
		}
		wait( 0.5 );
		dog SetDogAutoAttackWhenDriven( false );
	}
}

dog_attack_command_internal( dog )
{
	self notify( "dog_attack_internal" );
	self endon( "dog_attack_internal" );
	enemy = dog.closest_enemy_in_range;
//	dog thread play_sound_on_entity( "anml_dog_bark" );
	dog SetDogAutoAttackWhenDriven( true );
	wait_for_damage_or_attack( enemy );
	dog SetDogAutoAttackWhenDriven( false );
}

wait_for_damage_or_attack( enemy )
{
	self endon( "damage" );
	enemy waittill_either( "dog_attacks_ai", "death" );
}

dog_command_attack( ai, player )
{
	ai.ignoreme = false;
	ai setThreatBiasGroup( "dog_targets" );
	ai thread restore_ignoreme( self );
	self.favoriteenemy = ai;
	self.ignoreall = false;
	self GetEnemyInfo( ai );
	self setGoalEntity( ai );
	msg = ai waittill_any_return( "dog_attacks_ai", "death" );
}

lerp_on_attack( my_dog )
{
	self endon( "stop_dog_drive" );
	
	while ( 1 )
	{
		level waittill( "dog_attacks_ai", dog, enemy );
		if ( dog == my_dog )
		{
			maps\_art::dof_enable_script( 1, 1, 10, 50, 180, 3, 0.2 );
			self thread constant_screen_glitches();
			self LerpViewAngleClamp( 0.3, 0, 0.2, 0, 0, 0, 0 );
			wait( 0.8 );
			self notify( "stop_constant_glitch" );
//			self PlayerLinkWeaponViewToDelta( dog.camera_tag, "tag_player", 1, DOG_MAX_ANGLE_LIMIT, DOG_MAX_ANGLE_LIMIT, 15, 15, true );
			
			enemy waittill( "death" );
			default_dof( 1.25 );
			dog setGoalPos( dog.origin );
			self LerpViewAngleClamp( 0.3, 0.1, 0.1, DOG_MAX_ANGLE_LIMIT, DOG_MAX_ANGLE_LIMIT, 15, 15 );			
//			self PlayerLinkWeaponViewToDelta( dog.camera_tag, "tag_player", 0, DOG_MAX_ANGLE_LIMIT, DOG_MAX_ANGLE_LIMIT, 15, 15, true );
		}
	}
}

restore_ignoreme( dog )
{
	self endon( "death" );
	self endon( "dog_attacks_ai" );
	dog waittill( "cancel_attack" );
	self setThreatBiasGroup( "axis" );
}

dog_indirect_control_input( dog )
{
	self endon( "stop_dog_drive" );
	
	if ( !dog ent_flag_exist( "dog_busy" ) )
		dog ent_flag_init( "dog_busy" );
	if ( !dog ent_flag_exist( "running_command" ) )
		dog ent_flag_init( "running_command" );
	
	dog ent_flag_clear( "dog_busy" );
	dog ent_flag_clear( "running_command" );
	
	dog.last_command = [];
	dog.last_command[ "position" ] = undefined;
	dog.last_command[ "volume" ] = undefined;
	
	while( 1 )
	{
		dog ent_flag_waitopen( "dog_busy" );
		input = self GetNormalizedMovement();
		
		input_angles = VectorToAngles( input );
		
		if ( input_angles[1] >= (360-DOG_MAX_ANGLE_LIMIT) || input_angles[1] <= (DOG_MAX_ANGLE_LIMIT) )
		{
			len = Distance2d((0,0,0), input);
			
			mx = max( abs( input[0] ), abs( input[1] ) );
			
			if ( input[0] < 0.8 )
				dog.sprint = false;
					
			if ( abs( len > 0.1 ) )
			{
				scale = mx / len;
				
				input = input * scale;
				
				input_scale = Distance((0,0,0), input);
				
				if ( self AttackButtonPressed() || dog.sprint )
				{
					scale_max = 1.5;
				}
				else
				{
					scale_max = 1;
				}
				
				self thread do_goto_trace( dog, ((input_scale * input_scale) * scale_max) + 0.05, input );
			}
			else if ( dog.script == "dog_move" )
			{
			//	dog setGoalPos( dog.origin );
			}
		}
		else if ( dog.script == "dog_move" )
		{
		//	dog setGoalPos( dog.origin );
		}
		wait( 0.05 );
	}
}

dog_attack_internal( dog, enemy )
{
//	dog ent_flag_set( "dog_busy" );
	dog endon( "cancel_attack" );
	self notify( "new_goto" );
	dog.moveplaybackrate = 1;
	//self PlayerLinkWeaponViewToDelta( dog.camera_tag, "tag_player", 0.1, 10, 10, 15, 15, true );
	//self PlayerLinkedSetViewZnear( false );
	dog dog_command_attack( enemy, self );
	//self PlayerLinkWeaponViewToDelta( dog.camera_tag, "tag_player", 0.1, 170, 170, 15, 15, true );
	//self PlayerLinkedSetViewZnear( false );
//	dog ent_flag_clear( "dog_busy" );
}

DOG_MIN_AUTOATTACK_DIST = 64;

check_for_enemies( dog, move_scale, input )
{
	input_angles = VectorToAngles( input );
	player_angles = self getPlayerAngles();
	angles = ( dog.angles[0], player_angles[1] - input_angles[1], 0 );

	if ( isdefined( dog.enemy ) )
		if ( isdefined( dog.enemy.syncedmeleetarget ) )
			return true;
	
//	if ( self AttackButtonPressed() )
	{
		enemy = self find_nearby_enemy( (100 * move_scale) + 50, angles );
		if ( isdefined( enemy ) )
		{
			
			if ( !isdefined( dog.favoriteenemy ) || dog.favoriteenemy != enemy )
			{
				dog notify( "cancel_attack" );
//				iprintln( "dog new enemy" );
				thread dog_attack_internal( dog, enemy );
			}
			return true;
		}
	}
	
	if ( isdefined( dog.favoriteenemy ) )
	{
		look_forward = AnglesToForward( angles );
		enemy_forward = VectorNormalize( dog.favoriteenemy.origin - dog.origin );
	
		new_dot = VectorDot( look_forward, enemy_forward );
		if ( ( new_dot > 0.8 || Distance( dog.origin, dog.favoriteenemy.origin) < DOG_MIN_AUTOATTACK_DIST ) )
		{
//			iprintln( "dog keeping enemy" );
			dog.favoriteenemy.ignoreme = false;
			dog.ignoreall = false;
			return true;
		}
		
	}
	
	return false;
}

do_goto_trace( dog, move_scale, input, noattackoverride )
{
	self notify( "new_goto" );
	self endon( "new_goto" );
	start = self maps\_dog_control::Get_Eye();//dog getTagOrigin( "TAG_ORIGIN" );
	//start = start + (0,0,50);
	input_angles = VectorToAngles( input );
	player_angles = self getPlayerAngles();
	angles = ( dog.angles[0], player_angles[1] - input_angles[1], 0 );
	end = start + ( AnglesToForward( angles ) * ((100 * move_scale) + 32) );
	
	if ( !isdefined( noattackoverride ) )
		if ( self check_for_enemies( dog, move_scale, input ) )
			return;
	
	dog.moveplaybackrate = move_scale * 1;
	dog notify( "cancel_attack" );
	dog.ignoreall = true;
	dog.favoriteenemy = undefined;
	
//	iprintln( "dog new position" );
	self LerpViewAngleClamp( 0.5, 0.2, 0.2, DOG_MAX_ANGLE_LIMIT, DOG_MAX_ANGLE_LIMIT, 15, 15 );
	
//	trace = dog AIPhysicsTrace( start, end, undefined, undefined, true, true );
	trace = BulletTrace( start, end, false, dog );
	trace[ "start" ] = start;
	trace[ "end" ] = end;
	
	org = trace[ "position" ];
	
	vol = maps\_dog_control::get_flush_volume( org );
	
	if ( isdefined( vol ) )
	{
		if ( !isdefined( dog.last_command[ "volume" ] ) || dog.last_command[ "volume" ] != vol )
		{
			dog ent_flag_set( "running_command" );
			dog.last_command[ "position" ] = org;
			dog.last_command[ "volume" ] = vol;
			dog.moveplaybackrate = 1;
			dog dog_command_flush( vol, trace );
			dog ent_flag_clear( "running_command" );
		}
	}
	else
	{
		if ( !isdefined( dog.last_command[ "position" ] ) || dog.last_command[ "position" ] != org )
		{
			dog ent_flag_set( "running_command" );
			dog.last_command[ "position" ] = org;
			dog.last_command[ "volume" ] = undefined;
			dog dog_command_goto( trace );
			dog ent_flag_clear( "running_command" );
		}
	}
}

// distFromWall in direction of normal
get_reflected_point( trace, distFromWall )
{
	P = trace["start"];
	Q = trace["position"];
	N = trace["normal"];

	QP = P - Q;
	
	if ( QP == ( 0,0,0 ) )
		return P;
	
	QPdotN = VectorDot( QP, N );
	scaler = distFromWall / QPdotN;
	PonWallToP = QPdotN * N;
	PonWall = P - PonWallToP;
	QtoPonWall = PonWall - Q;

	scaledPonWallToP = N * distFromWall;

	lengthQtoPonWall = Length( QtoPonWall );
	normQtoPonWall = QtoPonWall / lengthQtoPonWall;
	scaledQtoPonWall = normQtoPonWall * ( scaler * lengthQtoPonWall );

	reflectedPonWall = Q - scaledQtoPonWall;
	reflectedPoint = reflectedPonWall + scaledPonWallToP;
	reflectedPoint = ( reflectedPoint[0], reflectedPoint[1], Q[2] );

	//Line( P, Q, ( 0, 255, 0 ), 1, false, 3 );
	//Line( Q, reflectedPoint, ( 0, 0, 255 ), 1, false, 3 );

	return reflectedPoint;
}

dog_command_goto( trace )
{	
	self.goalheight = 16;
	self.goalradius = 16;
	org = trace[ "position" ];
	nml = trace[ "normal" ];

	if ( abs( nml[2] ) < 0.2 && trace["fraction"] < 1 )
	{
		//org = org + (nml*64);
		org = get_reflected_point( trace, 24 );
	}
	
	start = org;
	end = org - (0,0,9000);
	
	trace = self AIPhysicsTrace( start, end, undefined, undefined, true, true );
	org = trace[ "position" ];
	
	self setGoalPos( org );
	wait( 0.2 );
	if ( isdefined( self.pathgoalpos ) )
	{
		return;
	}
	else if ( Distance2d( self.origin, org ) > self.goalradius )
	{
		nodes = GetNodesInRadius( org, 96, 0, 96 );
		nodes = SortByDistance( nodes, self.origin );
		if ( nodes.size > 0 )
		{
			node = nodes[0];
			self setGoalPos( node.origin );
			self waittill( "goal" );
		}
	}
}

dog_command_flush( vol, trace )
{
	org = trace[ "position" ];
	func = level.dog_flush_functions[ vol.script_noteworthy ];
	self thread [[ func ]]( vol, trace );
	level waittill( "dog_flush_started" );
	vol.done_flushing = true;
	level waittill( "dog_flush_done" );
}

dog_jumpup( volume, trace )
{
	level notify( "dog_flush_started" );
	waittillframeend;
	volume.done_flushing = undefined;
	self thread dog_jumpup_goto( trace );
	waitframe();
	volume.done_flushing = undefined;
	trigger = volume get_target_ent();
	self thread dog_jumpup_wait( trigger );
	
	self waittill( "command_goto_done" );
	level notify( "dog_flush_done" );
}

dog_jumpup_goto( trace )
{
	self endon( "stop_goto" );
	dog_command_goto( trace );
	self notify( "command_goto_done" );
}

dog_jumpup_wait( trigger )
{
	self endon( "command_goto_done" );
	trigger waittill( "trigger" );
	self notify( "stop_goto" );
	node = trigger get_target_ent();
	self setGoalPos( node.origin );
	self waittill( "goal" );
	self notify( "command_goto_done" );
}

#using_animtree( "dog" );

dog_drive_animscript( dog )
{
	dog useAnimTree( #animtree );
	dog setAnimKnobAll( %german_shepherd_look_forward, %german_shepherd_look, 1, 0.3, 1 );
	
	dog setAnimLimited( %german_shepherd_look, 1, 0.3, 1 );
	dog setAnimLimited( %german_shepherd_look_left, 1, 0.3, 1 );
	dog setAnimLimited( %german_shepherd_look_right, 1, 0.3, 1 );
	dog setAnimLimited( %german_shepherd_stationaryrun, 1, 0.3, 1 );
	dog setAnimLimited( %german_shepherd_stationaryrun_lean_L, 0, 0.3, 1 );
	dog setAnimLimited( %german_shepherd_stationaryrun_lean_R, 0, 0.3, 1 );
	
	self thread track_right_stick( dog );
	self thread track_left_stick( dog );
}

track_left_stick( dog )
{
	while( 1 )
	{
		movement = self GetNormalizedMovement();
		desiredRun = movement[0];
		
		if ( desiredRun > 0 )
		{
			weight = desiredRun;
			dog setAnim( %german_shepherd_runinplace, weight, 0.2, weight ); 
			dog setAnim( %german_shepherd_look, 0, 0.2, 1 ); 
		}
		else
		{
			dog setAnim( %german_shepherd_look, 1, 0.2, 1 ); 
			dog setAnim( %german_shepherd_runinplace, 0, 0.2, 1 ); 
		}
		
		look = self GetNormalizedCameraMovement();
		desiredFacing = look[1];

		weights = [];
		weights[ "center" ] = 0;
		weights[ "left" ] = 0;
		weights[ "right" ] = 0;
		
		if ( desiredFacing > 0 )
		{
			weights[ "left" ] = 0;
			weights[ "right" ] = desiredFacing;
			weights[ "center" ] = 1 - weights[ "right" ];
		}
		else if ( desiredFacing < 0 )
		{
			weights[ "right" ] = 0;
			weights[ "left" ] = -1*desiredFacing;	
			weights[ "center" ] = 1 - weights[ "left" ];
		}
		else
		{
			weights[ "left" ] = 0;
			weights[ "right" ] = 0;
			weights[ "center" ] = 1;
		}
		
		dog setanimLimited( %german_shepherd_stationaryrun, weights[ "center" ], 0.5, 1 );
		dog setanimLimited( %german_shepherd_stationaryrun_lean_L, weights[ "left" ], 0.5, 1 );
		dog setanimLimited( %german_shepherd_stationaryrun_lean_R, weights[ "right" ], 0.5, 1 );
		
		wait( 0.05 );
	}
}

track_right_stick( dog )
{
	currentFacing = 0.0;
	desiredFacing = 0.0;
	
	while( 1 )
	{
		movement = self GetNormalizedCameraMovement();
		desiredFacing = movement[1] * 0.85;
		
		if ( desiredFacing < 0 )
		{
			weight = -1*desiredFacing;
			dog setAnimLimited( %german_shepherd_look_4, weight, 0.2, 1 ); 
			dog setAnimLimited( %german_shepherd_look_6, 0, 0.2, 1 ); 
		}
		else
		{
			dog setAnimLimited( %german_shepherd_look_6, desiredFacing, 0.2, 1 ); 
			dog setAnimLimited( %german_shepherd_look_4, 0, 0.2, 1 ); 
		}
		
		
		wait( 0.05 );
	}
}

find_nearby_enemy( max_dist, look_angles )
{
	enemy = undefined;
	enemies = getaiarray( "axis" );
	close_enemies = [];
	old_dot = level.see_enemy_dot;
	close_dot = level.see_enemy_dot_close;
	player = self;
	end = player maps\_dog_control::Get_Eye();
	
	enemies = SortByDistance( enemies, player.controlled_dog.origin );
	foreach ( e in enemies )
	{
		if ( Distance( e.origin, player.controlled_dog.origin ) < DOG_MIN_AUTOATTACK_DIST )
			return e;
		else 
			break;
	}
	
	foreach ( e in enemies )
	{
		new_end = ( end[0], end[1], e.origin[2] );
		angles = VectorToAngles( e.origin - new_end );
		forward = AnglesToForward( angles );
		player_angles = look_angles;
		player_forward = AnglesToForward( player_angles );
	
		new_dot = VectorDot( forward, player_forward );
		if ( new_dot > close_dot )
		{
			close_enemies = array_Add( close_enemies, e );
		}
	}
	
	if ( close_enemies.size > 0 )
	{
		close_enemies = sortByDistance( close_enemies, end );
		foreach ( e in close_enemies )
		{
			if ( maps\_dog_control::test_trace( e getEye() , end , player.controlled_dog ) && (!isdefined(max_dist) || Distance2d( end, e.origin ) <= max_dist) )
			{
				return e;
			}
		}
	}
	
	if ( !isdefined( enemy ) )
	{
		old_dot = level.see_enemy_dot;
		
		foreach ( e in enemies )
		{
			angles = VectorToAngles( e.origin - end );
			forward = AnglesToForward( angles );
			player_angles = look_angles;
			player_forward = AnglesToForward( player_angles );
		
			new_dot = VectorDot( forward, player_forward );
			if ( new_dot > old_dot && maps\_dog_control::test_trace( e getEye() , end , player.controlled_dog ) && (!isdefined(max_dist) || Distance2d( end, e.origin ) <= max_dist) )
			{
				enemy = e;
				old_dot = new_dot;
			}
		}
	}
	
	return enemy;
}


hud_outlineEnable( color )
{
	if ( !isdefined( self.no_more_outlines ) )
		self HudOutlineEnable( color );
}

dog_bark( dog )
{
	self endon( "stop_dog_drive" );
	
	self NotifyOnPlayerCommand( "LISTEN_ads_button_pressed", "+toggleads_throw" );
	self NotifyOnPlayerCommand( "LISTEN_ads_button_pressed", "+speed_throw" );
	self NotifyOnPlayerCommand( "LISTEN_ads_button_pressed", "+speed" );
	self NotifyOnPlayerCommand( "LISTEN_ads_button_pressed", "+ads_akimbo_accessible" );
	self NotifyOnPlayerCommand( "LISTEN_ads_button_pressed", "+smoke" );
	
	while( 1 )
	{
		self waittill( "LISTEN_ads_button_pressed" );
		dog thread play_sound_on_entity( "anml_dog_bark_attention" );
		dog anim_generic( dog, "dog_bark" );
		level notify( "dog_barked", dog );
		if ( !flag( "_stealth_spotted" ) )
		{
			dog attract_guys_to_dog();
		}
		wait( 1 );
	}
}

attract_guys_to_dog()
{
	ai = getAIArray( "axis" );
	ai = SortByDistance( ai, self.origin );
	foreach( guy in ai )
	{
		if ( isdefined( guy._stealth ) )
		{
			if ( Distance( guy.origin, self.origin ) < 800 )
			{
				guy maps\_stealth_visibility_enemy::enemy_event_awareness_notify( "heard_scream", self.origin );
			}
			else
			{
				break;
			}
		}
	}
}