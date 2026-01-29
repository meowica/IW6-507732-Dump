#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

#include maps\ship_graveyard_util;

#using_animtree("vehicles");
vehicles()
{
	level.scr_animtree[ "dominator_uav_vehicle" ] = #animtree;
	level.scr_anim[ "dominator_uav_vehicle" ][ "dominator_uav" ] = %domintaor_uav_driving_idle_forward;
}

torpedo_go( start_pos, start_ang )
{		
	vehicles();
	
	SetDVar( "dominator_speed", 5 );
	SetDVar( "dominator_angle", 0 );
	SetDVar( "dominator_pitch_angle_acceleration", 1 );
	SetDVar( "dominator_max_pitch_angle_velocity", 2 );
	SetDVar( "dominator_yaw_angle_acceleration", 1 );
	SetDVar( "dominator_max_yaw_angle_velocity", 2 );
	
	SetDVar( "domgrav", 25 );
	SetDVar( "domthermal", 1 );

	SetDVar( "dpfov", 110 );
	SetDVar( "dph", 440 );
	SetDVar( "dpw", 150 );
	SetDVar( "dpx", 570 );
	SetDVar( "dpy", 20 );

	SetDVar( "dp1fov", 100 );
	SetDVar( "dp1h", 150 );
	SetDVar( "dp1w", 225 );
	SetDVar( "dp1x", 480 );
	
	source = get_target_ent( "remote_missile_source" );
	source.origin = start_pos;
	source.angles = start_ang;
	fwd = AnglesToForward( source.angles );

	flag_init( "force_detonate_dom" );
	
	
	level.player DisableWeaponSwitch();
	level.player GiveWeapon( "remote_torpedo_tablet" );
	level.player SwitchToWeapon( "remote_torpedo_tablet" );	
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameLoop("torpedo");
	SetSavedDvar( "player_swimSpeed", 0 );
	level.player EnableSlowAim( 0.01, 0.01 );
	org = level.player spawn_tag_origin();
	org.angles = level.player GetPlayerAngles();
//	level.player PlayerLinkToAbsolute( org, "tag_origin" );

	wait( 2.5 );
	level.player DisableSlowAim();
	SetSavedDvar( "player_swimSpeed", 90 );
	level.player unlink();
	org delete();
	
	fade_out( 0.5 );
	StopCinematicInGame();
	
	level.player.breathing_overlay[ "gasmask_overlay" ].alpha = 0;
//	level.f_min[ "gasmask_overlay" ] = 0.0;
//	level.f_max[ "gasmask_overlay" ] = 0.0;
	level.player notify( "stop_scuba_breathe" );
	level.player maps\_underwater::player_scuba_mask_disable( true );

	delaythread( 0.1, ::fade_in, 0.3 );
	delayThread( 12, ::flag_set, "force_detonate_dom" );
	level.player torpedo_fire( source );
	
	setSavedDvar( "sm_cameraOffset", 0 );
	setSavedDvar( "sm_sunShadowScale", 1 );
	setSavedDvar( "sm_sunSampleSizeNear", 0.25 );	
	
	level.player maps\_underwater::player_scuba_mask( true );
	level.f_min[ "gasmask_overlay" ] = 0.3;
	level.f_max[ "gasmask_overlay" ] = 0.95;	
	level.player delaythread( 0.1, maps\_swim_player::flashlight );
	level.player TakeWeapon( "remote_torpedo_tablet" );
	level.player SwitchToWeapon( level.player.last_weapon );
	level.player EnableWeaponSwitch();
	
	flag_wait("turn_on_bubbles_after_torpedo");
	
	level.player thread maps\_underwater::player_scuba();
}

torpedo_accel()
{
	org = spawn_tag_origin();
	org.origin = (0,0,5);
	org moveZ( 15, 3 );
	org endon( "movedone" );
	while( 1 )
	{
		SetDVar( "dominator_speed", org.origin[2] );
		wait( 0.05 );
	}
}

torpedo_fire( source )
{
	// Local setup.
	node = get_target_ent( "sonar_wreck_crash_player" );
	self.dom = SpawnStruct();
	self.start_origin = node.origin;
	self.start_angles = node.angles;
	
	forward = AnglesToForward( source.angles );
	start_pos =  source.origin;

	// Dominator ent. 
	dominator_ent = Spawn( "script_model", start_pos );
	dominator_ent.angles = source.angles;
	dominator_ent SetModel( "viewmodel_torpedo" );
	dominator_ent UseAnimTree( level.scr_animtree[ "torpedo" ] );
	dominator_ent SetAnim( level.scr_anim[ "torpedo" ][ "torpedo_idle" ] );
	dominator_ent.dominator_angular_velocity = ( 0, 0, 0 );
	self.dom.ref_ent = dominator_ent;

	// Link to vehicle. 
	player_ent = Spawn( "script_model", dominator_ent.origin + forward * -200.0 );
	player_ent.angles = dominator_ent.angles;
	player_ent SetModel( "tag_origin" );
 	link_pitch = 0;
 	player_ent LinkTo( dominator_ent, "tag_body", ( -1.5, 0, -6.5 ), ( link_pitch, 0, 0 ));
	self PlayerLinkToDelta( player_ent, "tag_origin", 1.0, 0, 0, 0, 0, 1 );
	self.dom.player_ent = player_ent;
	
	// Player mode setup.
	self lock_player_controls( true );
	fire_delay = 0;
	self.dom.sprint = 0;
	self.dom.sprint_time = 0;

	// HUD stuff
	//last_vision = level.player.vision_set_transition_ent.vision_set;
	self enable_torpedo_ui();
	self ThermalVisionOn();
	self VisionSetThermalForPlayer( "default_night_mp", 0 );

	level.sonar_boat setModel( "vehicle_lcs_flir" );
	SetSavedDvar( "r_cc_mode", "clut" );
	if ( !game_is_current_gen() )
	{
		SetSavedDvar( "r_thermalColorOffset", 0.26 );
	}
	//SetSavedDvar( "r_cc_toneBias1", (-1,0,0) );
	//SetExpFog( 0, 110, 0.4, 0.4, 0.4, 0, 0 );									// Fog off.
	self thread track_lcs_targets();
	level notify( "torpedo_ready" );
	
	level.player thread spawn_model_fx((3,0,0));
	
	// FIRE!
	level waittill( "fire_torpedo" );
	wait( 0.25 );
	dominator_ent unlink(); // probably shouldn't be here!
	
	Earthquake( 0.75, 0.7, level.player.origin, 1024 );
	
	thread torpedo_accel();
	
	dominator_ent PlaySound( "scn_shipg_torpedo_start", "start_sound_done" );
	dominator_ent delayCall( 0.75, ::PlayLoopSound, "scn_shipg_torpedo_loop" );
	
	// Control loop.
	while( 1 )
	{
		// Get stick movements, bias twords right stick. 
		right_stick = self GetNormalizedCameraMovement();
		left_stick = self GetNormalizedMovement();

		// Stick bias and invert. 
		if ( right_stick[ 0 ] == 0 )
		{
			if ( isdefined( self GetLocalPlayerProfileData( "invertedPitch" )) 
				&& self GetLocalPlayerProfileData( "invertedPitch" ))
			{
				right_stick = ( left_stick[ 0 ] * -1.0, right_stick[ 1 ], right_stick[ 2 ]);
			}
			else 
			{
				right_stick = ( left_stick[ 0 ], right_stick[ 1 ], right_stick[ 2 ]);
			}
		}
		if ( right_stick[ 1 ] == 0 )
		{
			right_stick = ( right_stick[ 0 ], left_stick[ 1 ], right_stick[ 2 ]);
		}
	
		// Update angular velocity. 
		dominator_ent.dominator_angular_velocity = ( 
			dominator_ent dominator_accelerate( "pitch",
												dominator_ent.dominator_angular_velocity, 
												right_stick 
												),
			dominator_ent dominator_accelerate( "yaw",
												dominator_ent.dominator_angular_velocity, 
												right_stick 
												),
			dominator_ent dominator_accelerate( "roll",
												dominator_ent.dominator_angular_velocity, 
												right_stick 
												));

		// Yaw and Pitch.
		dominator_ent.angles += dominator_ent.dominator_angular_velocity * ( 1, 1, 0 );
		clamp_size_down = 80;
		clamp_size_up = 55;
		if ( dominator_ent.angles[ 0 ] > clamp_size_down )
		{
			dominator_ent.angles = ( clamp_size_down, dominator_ent.angles[ 1 ], 0 );
		}
		else if ( dominator_ent.angles[ 0 ] < ( clamp_size_up * -1 ))
		{
			dominator_ent.angles = (( clamp_size_up * -1 ), dominator_ent.angles[ 1 ], 0 );
		}
		
		// Roll. 
		dominator_ent.angles *= ( 1, 1, 0 );
		dominator_ent.angles += ( 0, 0, ( dominator_ent.dominator_angular_velocity[ 2 ] * -5.0 ));
		
		// Velocity. 
		gravity_frac = dominator_ent.angles[ 0 ] / 90.0;
		if ( dominator_ent.angles[ 0 ] < 0 )
		{
			gravity_frac /= 3.0;
		}
		speed = GetDVarFloat( "dominator_speed" );// + ( gravity_frac * GetDvarFloat( "domgrav" )) ;
		dominator_ent.velocity = AnglesToForward( dominator_ent.angles )  * speed;

		new_origin = dominator_ent.origin + dominator_ent.velocity;
		fwd = AnglesToForward( dominator_ent.angles ) * 5;
		
		// Kamikaze. 
		trace = BulletTrace( dominator_ent.origin, new_origin  + dominator_ent.velocity, false, dominator_ent );
		trace_ground = BulletTrace( self GetEye(), self GetEye() + ( 0, 0, 5 ), false, dominator_ent );
		if ( trace[ "fraction" ] < 1 || trace_ground[ "fraction" ] < 1 || flag( "force_detonate_dom" ) )
		{
			self thread detonate_dominator( dominator_ent.origin, new_origin  + dominator_ent.velocity );
			break;
		}
		
		// Update movement. 			
		prev_origin = dominator_ent.origin;
		dominator_ent.origin = new_origin;
		
		wait( 0.01 );
	}
	
	hit_lcs = false;
	foreach ( t in level.sonar_boat.target_points )
	{
		if ( Distance( self.origin, t.origin ) < 196 )
		{
			hit_lcs = true;
			break;
		}
	}
	
	level notify( "exit_torpedo", hit_lcs );
	
	wait( .25 );

	//self thread maps\_remoteturret::uav_disable_view( 0.05 );
	disable_torpedo_ui();
	self ThermalVisionOff();
	SetSavedDvar( "r_cc_mode", "off" );
	//self thread vision_set_fog_changes( last_vision, 0.05 );
}

lock_player_controls( lock )
{
	if ( lock == true )
	{
		self DisableWeapons();
		self DisableOffhandWeapons();	
		self HideViewModel();	
	}
	else 
	{
		self ShowViewModel();	
		self EnableWeapons();
		self EnableOffhandWeapons();
	}
	
	self AllowCrouch( !lock );
	self AllowProne( !lock );
	self AllowSprint( !lock );
	self AllowAds( !lock );
}

dominator_accelerate( type, velocity, movement_normal )
{
	// Init locals. 
	if ( type == "yaw" )
	{
		max_vel = GetDVarFloat( "dominator_max_yaw_angle_velocity" );
		acceleration = GetDVarFloat( "dominator_yaw_angle_acceleration" );
		index = 1;
		norm_index = 1;
		dead_zone = 0.01;
	}
	else if ( type == "roll" )
	{
		max_vel = GetDVarFloat( "dominator_max_yaw_angle_velocity" );
		acceleration = GetDVarFloat( "dominator_yaw_angle_acceleration" );
		index = 2;
		norm_index = 1;
		dead_zone = 0.01;
	}
	else 
	{
		max_vel = GetDVarFloat( "dominator_max_pitch_angle_velocity" );
		acceleration = GetDVarFloat( "dominator_pitch_angle_acceleration" );
		index = 0;
		norm_index = 0;
		dead_zone = 0.3;
	}
	
	// Check for release. 
	normal = dominator_get_dead_zone_range( movement_normal[ norm_index ] * -1.0, dead_zone );
	if ( normal == 0 )
	{
		if ( type == "yaw" )
		{
			acceleration *= 3.5;
		}
		else if ( type == "roll" )
		{
			acceleration *= 1.5;
		}
		else 
		{
			acceleration *= 2.1;
		}
	}

	// Get target acceleration. 
	current_normal = velocity[ index ] / max_vel;
	target_normal = normal - current_normal;
	acceleration = ( target_normal * acceleration );

	// Add in acceleration. 
	if ( type == "yaw" )
	{
		velocity += ( 0, acceleration, 0 );
	}
	else if ( type == "roll" )
	{
		velocity += ( 0, 0, acceleration );
	}
	else 
	{
		velocity += ( acceleration, 0, 0 );
	}

	return velocity[ index ];
}

dominator_get_dead_zone_range( movement_normal, min_movement )
{
	movement = Clamp(( abs( movement_normal ) - min_movement ), 0, 1 );
	range = ( 1.0 - min_movement );
	movement = movement / range;
	if ( movement_normal < 0.0 )
	{
		movement *= -1.0;
	}
	return movement;
}

detonate_dominator( start_pos, end_pos )
{
        //stop the looping sound for the torpedo spinning grinders
	if ( IsDefined( level.sound_torpedo_ent ) )
	{
		level.sound_torpedo_ent StopLoopsound();
		level.sound_torpedo_ent delete();
	}
	
	fwd = AnglesToForward( self getplayerangles() );
	//PlayFX( getfx( "shpg_underwater_explosion_med_a" ), self.origin + (fwd*15) );
	// Rumble. 
	self thread dominator_earthquake( 1.0, true );
	thread play_sound_in_space( "underwater_explosion", self.origin );
	fade_out( 0.1, "white" );
	
	// Destroy model.
	self SetOrigin( self.start_origin );
	self SetPlayerAngles( self.start_angles );
	self.dom.ref_ent Delete();
	self.dom.player_ent Delete();
	
	// Clear dominator ref on player. 
	self.dom.ref_ent = undefined;
			
	// Restore player. 
	self lock_player_controls( false );
	wait( 0.2 );
	thread fade_in( 0.35, "white" );
}

dominator_earthquake( frac, only_rumble )
{
	if ( only_rumble == false )
	{
		Earthquake( frac * 0.8, 2.0, self.origin, 100000.00 );
	}

	if ( frac < 0.2 )
	{
		self PlayRumbleOnEntity( "damage_heavy" );
	}
	else 
	{
		self PlayRumbleOnEntity( "damage_heavy" );
		wait( 0.2 );
		self PlayRumbleOnEntity( "damage_light" );
		wait( 0.2 );
		self PlayRumbleOnEntity( "damage_light" );
	}
}

track_lcs_targets()
{
	lcs = level.sonar_boat;
	targets = level.sonar_boat.target_points;
	
	foreach ( t in targets )
	{
		shader = "apache_targeting_circle";
		color = ( 1, 0, 0 );
		target_enable( t, shader, color, 128 );
		t thread disable_target_on_death();
	}
}

disable_target_on_death()
{
	level waittill( "exit_torpedo" );
	if ( Target_IsTarget( self ) )
		Target_Remove( self );
}

target_enable( target, shader, color, radius )
{
	if ( !IsDefined( target ) )
		return;
	
	offset = ( 0,0,0 );
	
	Target_Alloc( target, offset );
	Target_SetShader( target, shader );
	
	Target_DrawSquare( target, 24 );
	/*
	Target_SetScaledRenderMode( target, true );	
	
	Target_DrawSingle( target );
	Target_DrawCornersOnly( target, true );	
	*/
	
	if ( IsDefined( color ) )
		Target_SetColor( target, color );
	Target_SetMaxSize( target, 128 );
	Target_SetMinSize( target, 64, false );
	Target_SetDelay( target, 0.6 );
	
	
	Target_Flush( target );
}

enable_torpedo_ui()
{
	flag_set("pause_dynamic_dof" );
	maps\_art::dof_enable_script( 1, 20, 5, 9000, 90000, 3, 0.1 );
	
	level.torpedo_hud_items = [];

	hudelem = create_client_overlay( "torpedo_frame_edge", 1, level.player );
	hudelem.foreground = false;
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;

	hudelem = level.player createClientIcon( "torpedo_center", 200, 200 );
	hudelem setPoint( "CENTER", undefined, 0, 0, 0 );
	hudelem.alpha = 0.4;
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_centerbox", 800, 320 );
	hudelem setPoint( "CENTER", undefined, 0, 0, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;

	hudelem = level.player createClientIcon( "torpedo_horizonline", 700, 60 );
	hudelem setPoint( "CENTER", undefined, 0, 0, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_centerline", 110, 60 );
	hudelem setPoint( "BOTTOM", "CENTER", 0, -20, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_frame_center", 200, 12 );
	hudelem setPoint( "TOP", "TOP", 0, 10, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_databit_3", 200, 26 );
	hudelem setPoint( "TOP", "TOP", 0, 14, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_frame_center_bottom", 200, 12 );
	hudelem setPoint( "BOTTOM", "BOTTOM", 0, -10, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_sidebracket_l", 30, 340 );
	hudelem setPoint( "LEFT", "LEFT", 60, 0, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_databit_1", 200, 26 );
	hudelem setPoint( "LEFT TOP", "LEFT", 60, 120, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_sidebracket_r", 30, 340 );
	hudelem setPoint( "RIGHT", "RIGHT", -60, 0, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
	
	hudelem = level.player createClientIcon( "torpedo_databit_2", 200, 26 );
	hudelem setPoint( "RIGHT TOP", "RIGHT", -105, 120, 0 );
	level.torpedo_hud_items[ level.torpedo_hud_items.size ] = hudelem;
}

disable_torpedo_ui()
{
	maps\_art::dof_disable_script( 0.1 );
	
	foreach ( elem in level.torpedo_hud_items )
	{
		elem destroy();
	}
	
	if( flag( "pause_dynamic_dof" ) )
		flag_clear( "pause_dynamic_dof" );
}

spawn_model_fx( offset )
{
	self.crt_plane = Spawn( "script_model", (0,0,0) );
	self.crt_plane setModel( "torpedo_crtplane" );
	self.crt_plane LinkToPlayerView( self, "tag_origin", (2,0,0) + offset, (0,-90,0), true );
	
	level waittill ("exit_torpedo");
	
	self.crt_plane UnlinkFromPlayerView(self);
	self.crt_plane delete();
}
