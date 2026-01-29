#include maps\_utility;
#include common_scripts\utility;
#include maps\cornered_audio;
#include maps\_hud_util;

binoculars_init( default_visionset )
{
	PreCacheShader( "cnd_face_recog_border_01" );
	PreCacheShader( "cnd_binocs_hud_photo_unknown" );
	PreCacheShader( "cnd_binocs_hud_photo_001" );
	PreCacheShader( "cnd_binocs_hud_photo_002" );
	PreCacheShader( "cnd_binocs_hud_photo_003" );
	PreCacheShader( "cnd_binocs_hud_photo_004" );
	PreCacheShader( "cnd_binocs_hud_photo_005" );
	PreCacheShader( "cnd_binocs_hud_photo_006" );
	PreCacheShader( "cnd_binocs_hud_photo_007" );
	PreCacheShader( "cnd_binocs_hud_photo_008" );
	PreCacheShader( "cnd_binocs_hud_photo_009" );
	PreCacheShader( "cnd_binocs_hud_photo_011" );
	PreCacheShader( "cnd_binocs_hud_photo_012" );
	PreCacheShader( "overlay_static" );
	PreCacheShader( "white" );
	PreCacheShader( "red_block" );
	PreCacheShader( "cnd_face_recog_reticle_01" );
	PreCacheShader( "cnd_face_recog_reticle_02" );
	PreCacheShader( "cnd_face_recog_reticle_03" );
	PreCacheShader( "cnd_face_recog_reticle_03a" );
	PreCacheShader( "cnd_face_recog_reticle_data_base" );
	PreCacheShader( "cnd_face_recog_reticle_id" );
	PreCacheShader( "cnd_face_recog_frame_01" );
	PreCacheModel( "soccer_ball_static" );
	PreCacheModel( "tag_turret" );
	PreCacheModel( "cnd_facial_rcg_01" );
	PreCacheModel( "cnd_facial_rcg_02" );
	PreCacheModel( "cnd_facial_rcg_03" );
	PreCacheModel( "cnd_facial_rcg_01_non_hvt" );
	PreCacheModel( "cnd_facial_rcg_02_non_hvt" );
	PreCacheModel( "cnd_facial_rcg_03_non_hvt" );
	PreCacheTurret( "player_view_controller_binoculars" );
	PreCacheItem( "binoculars_tech" );
	PreCacheShader( "hud_icon_scan_binocs" );
	
	flag_init( "scan_target_not_facing" );	
	flag_init( "hvt_confirmed" );
	flag_init( "double_agent_confirmed" );
		
	level.default_visionset = default_visionset;
	
	self.binocular_profile_materials = [];
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_001";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_002";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_003";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_004";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_005";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_006";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_007";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_008";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_009";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_011";
	self.binocular_profile_materials[ self.binocular_profile_materials.size ] = "cnd_binocs_hud_photo_012";

	self.binocular_body_features_left = [];
//	self.binocular_body_features_left[ self.binocular_body_features_left.size ] = "J_Ankle_LE";
//	self.binocular_body_features_left[ self.binocular_body_features_left.size ] = "J_Knee_LE";
	self.binocular_body_features_left[ self.binocular_body_features_left.size ] = "J_Hip_LE";
	self.binocular_body_features_left[ self.binocular_body_features_left.size ] = "J_Wrist_LE";
	self.binocular_body_features_left[ self.binocular_body_features_left.size ] = "J_Elbow_LE";
//	self.binocular_body_features_left[ self.binocular_body_features_left.size ] = "J_Shoulder_LE";
//	self.binocular_body_features_left[ self.binocular_body_features_left.size ] = "J_Clavicle_LE";
	
	self.binocular_body_features_right = [];
//	self.binocular_body_features_right[ self.binocular_body_features_right.size ] = "J_Ankle_RI";
//	self.binocular_body_features_right[ self.binocular_body_features_right.size ] = "J_Knee_RI";
	self.binocular_body_features_right[ self.binocular_body_features_right.size ] = "J_Hip_RI";
	self.binocular_body_features_right[ self.binocular_body_features_right.size ] = "J_Wrist_RI";
	self.binocular_body_features_right[ self.binocular_body_features_right.size ] = "J_Elbow_RI";
//	self.binocular_body_features_right[ self.binocular_body_features_right.size ] = "J_Shoulder_RI";
//	self.binocular_body_features_right[ self.binocular_body_features_right.size ] = "J_Clavicle_RI";
	
	self.binoculars_linked_to_target = false;
	
	binoculars_pip_init();
}

give_binoculars()
{
	if ( IsDefined( self.has_binoculars ) && self.has_binoculars )
		return;
	
	self.has_binoculars = true;
	self.binoculars_active = false;
	
	self.default_fov = GetDvarInt( "cg_fov" );
	
	self binoculars_set_default_zoom_level( 0 );
	self binoculars_set_vision_set( "cornered_binoculars" );
	
	self thread binoculars_hud();
}

take_binoculars()
{
	if ( IsDefined( self.has_binoculars ) && !self.has_binoculars )
		return;
	
	self.has_binoculars = false;
	
	while ( IsDefined( self.binoculars_clearing_hud ) && self.binoculars_clearing_hud )
	{
		wait 0.05;
	}
	
	self notify( "stop_using_binoculars" );
	self notify( "take_binoculars" );
		
	if ( IsDefined( self.binoculars_active ) && self.binoculars_active )
	{
		if ( self HasWeapon( "binoculars_tech" ) )
		{
			self TakeWeapon( "binoculars_tech" );
		}
		
		self binoculars_clear_hud();
	}
	
	self setWeaponHudIconOverride( "actionslot1", "none" );
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
		self VisionSetNakedForPlayer( self.binoculars_vision_set, 5.0 );
	}
}

binoculars_hud()
{
	self endon( "take_binoculars" );
	
	self NotifyOnPlayerCommand( "use_binoculars", "+actionslot 1" );
	self NotifyOnPlayerCommand( "binocular_zoom", "+sprint_zoom" );
	self NotifyOnPlayerCommand( "binocular_zoom", "+melee_zoom" );
	self SetWeaponHudIconOverride( "actionslot1", "hud_icon_scan_binocs" );
	
	self.binoculars_hud_item = [];
	
	while ( 1 )
	{
		self waittill( "use_binoculars" );
		
		self.last_weapon = self GetCurrentPrimaryWeapon();
		self GiveWeapon( "binoculars_tech" );
		self SwitchToWeapon( "binoculars_tech" );
		self _disableWeaponSwitch();
		
		wait 1;
		
		self PlaySound( "item_nightvision_on" );
		
		self binoculars_init_hud();
		
		wait 0.9;
		
		self _disableWeapon();
		self TakeWeapon( "binoculars_tech" );
		
		self waittill_either( "use_binoculars", "stop_using_binoculars" );
		
		if ( IsDefined( self.binoculars_zooming ) && self.binoculars_zooming )
		{
			self waittill( "binoculars_done_zooming" );
		}
		
		self notify( "stop_using_binoculars" );
		level notify( "stop_allies_kill_tagged_enemies_without_player_watcher" );
		level notify( "stop_allies_kill_tagged_enemies_watcher" );
		
		self binoculars_clear_hud();
	}
}

binoculars_init_hud()
{
	self endon( "take_binoculars" );

	self _disableOffhandWeapons();
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "cg_drawCrosshair", 0 );

	self AllowMelee( false );
	
	self.binocular_target = Spawn( "script_model", self GetOrigin() );
	self.binocular_target SetModel( "soccer_ball_static" );
	self.binocular_target Hide();
	self.binocular_target NotSolid();
	
	Target_Set( self.binocular_target );
	Target_HideFromPlayer( self.binocular_target, self );

	self.binoculars_active = true;
	
	self thread zoom_lerp_dof();

	self.binoculars_hud_item[ "binocular_border" ] = maps\_hud_util::create_client_overlay( "cnd_face_recog_border_01", 1, self );
	self.binoculars_hud_item[ "binocular_frame" ] = maps\_hud_util::create_client_overlay( "cnd_face_recog_frame_01", 0.66, self );
	
	self.binoculars_hud_item[ "reticle" ] = maps\_hud_util::createIcon( "cnd_face_recog_reticle_01", 16, 16 );
	self.binoculars_hud_item[ "reticle" ] set_default_hud_parameters();
	self.binoculars_hud_item[ "reticle" ].alignX = "center";
	self.binoculars_hud_item[ "reticle" ].alignY = "middle";
	self.binoculars_hud_item[ "reticle" ].alpha = 0.66;
	
	self.binoculars_hud_item[ "reticle_targetting" ] = maps\_hud_util::createIcon( "cnd_face_recog_reticle_02", 60, 60 );
	self.binoculars_hud_item[ "reticle_targetting" ] set_default_hud_parameters();
	self.binoculars_hud_item[ "reticle_targetting" ].alignX = "center";
	self.binoculars_hud_item[ "reticle_targetting" ].alignY = "middle";
	self.binoculars_hud_item[ "reticle_targetting" ].alpha = 0.0;
	
	self.binocular_reticle_target = Spawn( "script_origin", self.origin );
	self.binoculars_hud_item[ "reticle_targetting" ] SetTargetEnt( self.binocular_reticle_target );
	self.binoculars_hud_item[ "reticle_targetting" ] SetWayPoint( true, false );
	
	self.binoculars_hud_item[ "reticle_scanning" ] = maps\_hud_util::createIcon( "cnd_face_recog_reticle_03", 300, 300 );
	self.binoculars_hud_item[ "reticle_scanning" ] set_default_hud_parameters();
	self.binoculars_hud_item[ "reticle_scanning" ].alignX = "center";
	self.binoculars_hud_item[ "reticle_scanning" ].alignY = "middle";
	self.binoculars_hud_item[ "reticle_scanning" ].alpha = 0.0;
	
	self.binoculars_hud_item[ "reticle_scanning_frame" ] = maps\_hud_util::createIcon( "cnd_face_recog_reticle_03a", 300, 300 );
	self.binoculars_hud_item[ "reticle_scanning_frame" ] set_default_hud_parameters();
	self.binoculars_hud_item[ "reticle_scanning_frame" ].alignX = "left";
	self.binoculars_hud_item[ "reticle_scanning_frame" ].alignY = "middle";
	self.binoculars_hud_item[ "reticle_scanning_frame" ].x = -2;
	self.binoculars_hud_item[ "reticle_scanning_frame" ].y = -40;
	self.binoculars_hud_item[ "reticle_scanning_frame" ].alpha = 0.0;
	
	self.binoculars_hud_item[ "reticle_scanning_id" ] = maps\_hud_util::createIcon( "cnd_face_recog_reticle_id", 144, 18 );
	self.binoculars_hud_item[ "reticle_scanning_id" ] set_default_hud_parameters();
	self.binoculars_hud_item[ "reticle_scanning_id" ].alignX = "left";
	self.binoculars_hud_item[ "reticle_scanning_id" ].alignY = "top";
	self.binoculars_hud_item[ "reticle_scanning_id" ].x = 9;
	self.binoculars_hud_item[ "reticle_scanning_id" ].y = -165;
	self.binoculars_hud_item[ "reticle_scanning_id" ].alpha = 0.0;
	
	if ( IsDefined( self.binoculars_vision_set ) )
	{
		self VisionSetNakedForPlayer( self.binoculars_vision_set, 0.0 );
	}
	
	self thread aud_binoculars( "on" );
	self thread aud_binoculars( "bg_loop" );

	self thread binoculars_calculate_range();
	self thread static_overlay();
	self thread binoculars_monitor_scanning();
	self thread monitor_binoculars_zoom();
	self thread binoculars_angles_display();
	self thread binocular_reticle_target_reaction();
	self thread binoculars_scan_for_targets();
	self thread binoculars_zoom_display();
}

binoculars_clear_hud()
{
	if ( IsDefined( self.binoculars_zooming ) && self.binoculars_zooming )
	{
		self waittill( "binoculars_done_zooming" );
	}
	
	self thread aud_binoculars( "off" );
	self notify( "stop_binocular_bg_loop_sound" );

	self.binoculars_clearing_hud = true;
	
	self binoculars_unlock_from_target();
	
	self.binoculars_active = false;
	
	self PlaySound( "item_nightvision_off" );
	
	self static_overlay();
	
	self AllowMelee( true );
	self _enableOffhandWeapons();
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "cg_drawCrosshair", 1 );
	
	self _enableWeapon();
	self _enableWeaponSwitch();
	
	self SwitchToWeapon( self.last_weapon );
	
	keys = getArrayKeys( self.binoculars_hud_item );
	foreach ( key in keys )
	{
		self.binoculars_hud_item[ key ] Destroy();
		self.binoculars_hud_item[ key ] = undefined;
	}
	
	foreach ( targ in Target_GetArray() )
	{
		Target_Remove( targ );
	}
	
	self.binocular_target Delete();
	self.binocular_target = undefined;
	
	self.blend_struct = undefined;
	
	maps\_art::dof_disable_script( 0.0 );
	
	SetSavedDvar( "cg_fov", self.default_fov );
	
	self DisableSlowAim();
	
	if ( IsDefined( self.binoculars_vision_set ) )
	{
		self VisionSetNakedForPlayer( level.default_visionset, 0.0 );
	}
	
	self.binoculars_clearing_hud = false;
}

binoculars_scan_for_targets()
{
	self endon( "stop_using_binoculars" );
	self endon( "binoculars_hud_off" );
	self endon( "take_binoculars" );

	found_target = false;
	self.binoculars_scan_target = undefined;
	
	while ( 1 )
	{
		if ( self.current_binocular_zoom_level == 1 && !self.binocular_zooming && !self.binoculars_linked_to_target )
		{
			if ( IsDefined( self.binoculars_trace[ "entity" ] ) && IsAI( self.binoculars_trace[ "entity" ] ) && self.binoculars_trace[ "entity" ] IsBadGuy() && SightTracePassed( self GetEye(), self.binoculars_trace[ "entity" ] GetTagOrigin( "J_Head" ), false, undefined ) )
			{
				found_target = true;
				
				if ( !IsDefined( self.binoculars_scan_target ) || self.binoculars_scan_target != self.binoculars_trace[ "entity" ] )
				{
					self thread binoculars_scan_target_points( self.binoculars_trace[ "entity" ] );
				}
			}
			else
			{
				best_dot = 0.99997;
				best_target = undefined;
				foreach ( ai in GetAIArray() )
				{
					is_double_agent = IsDefined( ai.binocular_double_agent ) && ai.binocular_double_agent;
					if ( ai.team == "allies" && !is_double_agent )
						continue;
					
					dot = VectorDot( VectorNormalize( ai.origin - self.origin ), AnglesToForward( self GetPlayerAngles() ) );
					
					if ( dot > best_dot )
					{
						if ( SightTracePassed( self GetEye(), ai GetTagOrigin( "J_Head" ), false, undefined ) )
						{
							best_dot = dot;
							best_target = ai;
							found_target = true;
						}
					}
				}
				
				if ( IsDefined( best_target ) && ( !IsDefined( self.binoculars_scan_target ) || self.binoculars_scan_target != best_target ) )
				{
					self thread binoculars_scan_target_points( best_target );
				}
			}
		}
		
		if ( !found_target )
		{
			self.binoculars_scan_target = undefined;
			self notify( "end_scan_target_points" );
			
			self.binoculars_hud_item[ "reticle_targetting" ].alpha = 0.0;
			
			if ( self.binocular_reticle_target IsLinked() )
			{
				self.binocular_reticle_target Unlink();
			}
			
			self EnableSlowAim( 0.5, 0.3 );
		}
		
		found_target = false;
		
		wait 0.05;
	}
}

binoculars_scan_target_points( targ )
{
	self endon( "stop_using_binoculars" );
	self endon( "binoculars_hud_off" );
	self endon( "take_binoculars" );
	
	self notify( "end_scan_target_points" );
	self endon( "end_scan_target_points" );
	
	self.binoculars_hud_item[ "reticle_targetting" ].alpha = 1.0;
	
	self EnableSlowAim( 0.35, 0.1 );
	
	self.binoculars_scan_target = targ;
	
	if ( self.binocular_reticle_target IsLinked() )
	{
		self.binocular_reticle_target Unlink();
	}
	
	SetSavedDvar( "waypointIconHeight", 18 );
	SetSavedDvar( "waypointIconWidth", 18 );
	
	self thread aud_binoculars( "seeker_off" );
	
	if ( RandomInt( 1 ) == 0 )
	{
		bone = self.binocular_body_features_left[ RandomInt( self.binocular_body_features_left.size ) ];
		self.binocular_reticle_target.origin = targ GetTagOrigin( bone );
		wait 0.3;
		
		self thread aud_binoculars( "seeker_move" );
		bone = self.binocular_body_features_right[ RandomInt( self.binocular_body_features_right.size ) ];
		self.binocular_reticle_target.origin = targ GetTagOrigin( bone );
		wait 0.3;
	}
	else
	{
		bone = self.binocular_body_features_right[ RandomInt( self.binocular_body_features_right.size ) ];
		self.binocular_reticle_target.origin = targ GetTagOrigin( bone );
		wait 0.3;
		
		self thread aud_binoculars( "seeker_move" );
		bone = self.binocular_body_features_left[ RandomInt( self.binocular_body_features_left.size ) ];
		self.binocular_reticle_target.origin = targ GetTagOrigin( bone );
		wait 0.3;
	}
	
	self thread aud_binoculars( "seeker_on" );
	self binoculars_reticle_lerp_to_tag( targ, "J_Head", 0.05 );
	self.binocular_reticle_target LinkTo( targ, bone );
	
	SetSavedDvar( "waypointIconHeight", 36 );
	SetSavedDvar( "waypointIconWidth", 36 );
}

binoculars_reticle_lerp_to_tag( targ, bone, time )
{
	self endon( "stop_using_binoculars" );
	self endon( "binoculars_hud_off" );
	self endon( "take_binoculars" );
	
	increments = time / 0.05;
	start_origin = self.binocular_reticle_target.origin;
	
	for ( i = 1; i <= increments; i++ )
	{
		self.binocular_reticle_target.origin = start_origin + ( ( targ GetTagOrigin( bone ) - start_origin - ( 0, 0, 7 ) ) * ( i / increments ) );
		wait 0.05;
	}
}

//binoculars_remove_ai_target_on_death( ai )
//{
//	self endon( "stop_using_binoculars" );
//	self endon( "binoculars_hud_off" );
//	self endon( "take_binoculars" );
//	
//	ai waittillmatch( "single anim", "end" );
//	
//	if ( Target_IsTarget( ai ) )
//	{
//		Target_Remove( ai );
//	}
//}

binoculars_calculate_range()
{
	self endon( "stop_using_binoculars" );
	self endon( "binoculars_hud_off" );
	self endon( "take_binoculars" );
	
	self.binoculars_hud_item[ "range" ] = self maps\_hud_util::createClientFontString( "default", 1.2 );
	self.binoculars_hud_item[ "range" ].x = 70;
	self.binoculars_hud_item[ "range" ].y = -25;
	self.binoculars_hud_item[ "range" ].alignX = "right";
	self.binoculars_hud_item[ "range" ].alignY = "top";
	self.binoculars_hud_item[ "range" ].horzAlign = "center";
	self.binoculars_hud_item[ "range" ].vertAlign = "top";
	self.binoculars_hud_item[ "range" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "range" ].alpha = 1.0;
	self.binoculars_hud_item[ "range" ].glowColor = ( 1, 1, 1 );
	self.binoculars_hud_item[ "range" ].glowAlpha = 0.0;
	
	while ( 1 )
	{
		forward = AnglesToForward( self GetPlayerAngles() );
		
		if ( self IsLinked() && IsDefined( self.linked_world_space_forward ) )
		{
			forward = self.linked_world_space_forward;
		}
		
		self.binoculars_trace = BulletTrace( self GetEye(), self GetEye() + forward * 50000, true, self );
		
		while ( IsDefined( self.binoculars_trace[ "surfacetype" ] ) && self.binoculars_trace[ "surfacetype" ] == "glass" )
		{
			self.binoculars_trace = BulletTrace( self.binoculars_trace[ "position" ] + forward * 20, self.binoculars_trace[ "position" ] + forward * 50000, true, self );
		}
		
		range = Distance( self GetEye(), self.binoculars_trace[ "position" ] );
		range *= 0.0254;
		range = Int( range * 100 ) * 0.01;
		
		if ( range > 1000.0 )
		{
			self.binoculars_hud_item[ "range" ] SetText( "1000+ M" );
		}
		else
		{
			if ( range - Int( range ) == 0.0 )
			{
				self.binoculars_hud_item[ "range" ] SetText( range + ".00 M" );
			}
			else if ( ( range * 10 ) - Int( range * 10 ) == 0.0 )
			{
				self.binoculars_hud_item[ "range" ] SetText( range + "0 M" );
			}
			else
			{
				self.binoculars_hud_item[ "range" ] SetText( range + " M" );
			}
		}
		
		wait 0.05;
	}
}

binoculars_remove_target_on_death( enemy )
{
	self notify( "end_remove_target_on_death" );
	self endon( "end_remove_target_on_death" );
	self endon( "stop_using_binoculars" );
	self endon( "binoculars_hud_off" );
	self endon( "take_binoculars" );
	
	enemy waittill( "death" );
	
	if ( IsDefined( self.binocular_target ) && Target_IsTarget( self.binocular_target ) )
	{
		Target_HideFromPlayer( self.binocular_target, self );
	}
}

binoculars_lock_to_target( enemy )
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
		
		self PlayerLinkToAbsolute( self.player_view_controller, "tag_aim" );
		self.player_view_controller SetTargetEntity( self.binocular_target, self.origin - self GetEye() );
		
		self.binoculars_hud_item[ "reticle" ].alpha = 0.0;
		self.binoculars_hud_item[ "reticle_targetting" ].alpha = 0.0;
		self.binoculars_hud_item[ "reticle_scanning" ].alpha = 1.0;
		self.binoculars_hud_item[ "reticle_scanning_frame" ].alpha = 1.0;
		self.binoculars_hud_item[ "reticle_scanning_id" ].alpha = 1.0;
			
		self binoculars_pip_enable();
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
		
		self.binoculars_hud_item[ "reticle" ].alpha = 0.66;
		self.binoculars_hud_item[ "reticle_targetting" ].alpha = 0.0;
		self.binoculars_hud_item[ "reticle_scanning" ].alpha = 0.0;
		self.binoculars_hud_item[ "reticle_scanning_frame" ].alpha = 0.0;
		self.binoculars_hud_item[ "reticle_scanning_id" ].alpha = 0.0;
			
		self binoculars_pip_disable();
	}
}

binocular_face_scanning( targ )
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	self endon( "stop_scanning" );
	self endon( "scanning_complete" );
	
	self.binoculars_hud_item[ "profile" ] = maps\_hud_util::createIcon( self.binocular_profile_materials[ 0 ], 68, 68 );
	self.binoculars_hud_item[ "profile" ] set_default_hud_parameters();
	self.binoculars_hud_item[ "profile" ].alignX = "left";
	self.binoculars_hud_item[ "profile" ].alignY = "top";
	self.binoculars_hud_item[ "profile" ].horzAlign = "center";
	self.binoculars_hud_item[ "profile" ].vertAlign = "middle";
	self.binoculars_hud_item[ "profile" ].x = 144;
	self.binoculars_hud_item[ "profile" ].y = -135;
	self.binoculars_hud_item[ "profile" ].alpha = 0.9;
	self.binoculars_hud_item[ "profile" ].sort = self.binoculars_hud_item[ "reticle_scanning_frame" ].sort + 1;
	
	while ( 1 )
	{
		self.binocular_profile_materials = array_randomize( self.binocular_profile_materials );
		
		foreach ( material in self.binocular_profile_materials )
		{
			if ( !flag( "scan_target_not_facing" ) )
			{
				if ( IsDefined( targ.binocular_facial_profile ) && targ.binocular_facial_profile == material )
				{
					continue;
				}
				
				self.binoculars_hud_item[ "profile" ] SetShader( material, self.binoculars_hud_item[ "profile" ].width, self.binoculars_hud_item[ "profile" ].height );
				
				wait 0.05;
			}
			else
			{				
				self.binoculars_hud_item[ "profile" ] SetShader( "cnd_binocs_hud_photo_unknown", self.binoculars_hud_item[ "profile" ].width, self.binoculars_hud_item[ "profile" ].height );
				
				wait 0.05;
			}
		}
	}
}

binocular_face_scanning_lines( targ )
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	self endon( "stop_scanning" );
	self endon( "scanning_complete" );
	
	self.binoculars_face_scanning_models = [];
	self.binoculars_face_scanning_models[ 0 ] = [];
	self.binoculars_face_scanning_models[ 1 ] = [];
	
	self.binoculars_face_scanning_models[ 0 ][ 0 ] = Spawn( "script_model", targ GetTagOrigin( "J_Head" ) );
	self.binoculars_face_scanning_models[ 0 ][ 0 ].angles = targ GetTagAngles( "J_Head" );
	self.binoculars_face_scanning_models[ 0 ][ 0 ] SetModel( "cnd_facial_rcg_01_non_hvt" );
	self.binoculars_face_scanning_models[ 0 ][ 0 ] LinkTo( targ, "J_Head" );
	self.binoculars_face_scanning_models[ 0 ][ 0 ] HideAllParts();
	
	self.binoculars_face_scanning_models[ 0 ][ 1 ] = Spawn( "script_model", targ GetTagOrigin( "J_Head" ) );
	self.binoculars_face_scanning_models[ 0 ][ 1 ].angles = targ GetTagAngles( "J_Head" );
	self.binoculars_face_scanning_models[ 0 ][ 1 ] SetModel( "cnd_facial_rcg_02_non_hvt" );
	self.binoculars_face_scanning_models[ 0 ][ 1 ] LinkTo( targ, "J_Head" );
	self.binoculars_face_scanning_models[ 0 ][ 1 ] HideAllParts();
	
	self.binoculars_face_scanning_models[ 0 ][ 2 ] = Spawn( "script_model", targ GetTagOrigin( "J_Head" ) );
	self.binoculars_face_scanning_models[ 0 ][ 2 ].angles = targ GetTagAngles( "J_Head" );
	self.binoculars_face_scanning_models[ 0 ][ 2 ] SetModel( "cnd_facial_rcg_03_non_hvt" );
	self.binoculars_face_scanning_models[ 0 ][ 2 ] LinkTo( targ, "J_Head" );
	self.binoculars_face_scanning_models[ 0 ][ 2 ] HideAllParts();
	
	self.binoculars_face_scanning_models[ 1 ][ 0 ] = Spawn( "script_model", targ GetTagOrigin( "J_Head" ) );
	self.binoculars_face_scanning_models[ 1 ][ 0 ].angles = targ GetTagAngles( "J_Head" );
	self.binoculars_face_scanning_models[ 1 ][ 0 ] SetModel( "cnd_facial_rcg_01" );
	self.binoculars_face_scanning_models[ 1 ][ 0 ] LinkTo( targ, "J_Head" );
	self.binoculars_face_scanning_models[ 1 ][ 0 ] HideAllParts();
	
	self.binoculars_face_scanning_models[ 1 ][ 1 ] = Spawn( "script_model", targ GetTagOrigin( "J_Head" ) );
	self.binoculars_face_scanning_models[ 1 ][ 1 ].angles = targ GetTagAngles( "J_Head" );
	self.binoculars_face_scanning_models[ 1 ][ 1 ] SetModel( "cnd_facial_rcg_02" );
	self.binoculars_face_scanning_models[ 1 ][ 1 ] LinkTo( targ, "J_Head" );
	self.binoculars_face_scanning_models[ 1 ][ 1 ] HideAllParts();
	
	self.binoculars_face_scanning_models[ 1 ][ 2 ] = Spawn( "script_model", targ GetTagOrigin( "J_Head" ) );
	self.binoculars_face_scanning_models[ 1 ][ 2 ].angles = targ GetTagAngles( "J_Head" );
	self.binoculars_face_scanning_models[ 1 ][ 2 ] SetModel( "cnd_facial_rcg_03" );
	self.binoculars_face_scanning_models[ 1 ][ 2 ] LinkTo( targ, "J_Head" );
	self.binoculars_face_scanning_models[ 1 ][ 2 ] HideAllParts();
	
	self.binoculars_hud_item[ "percentage" ] = self maps\_hud_util::createClientFontString( "default", 1.2 );
	self.binoculars_hud_item[ "percentage" ].x = 205;
	self.binoculars_hud_item[ "percentage" ].y = -165;
	self.binoculars_hud_item[ "percentage" ].alignX = "right";
	self.binoculars_hud_item[ "percentage" ].alignY = "top";
	self.binoculars_hud_item[ "percentage" ].horzAlign = "center";
	self.binoculars_hud_item[ "percentage" ].vertAlign = "middle";
	self.binoculars_hud_item[ "percentage" ].color = ( 1.0, 0.0, 0.0 );
	self.binoculars_hud_item[ "percentage" ].alpha = 1.0;
	
	self.binoculars_hud_item[ "percentage_bar" ] = maps\_hud_util::createIcon( "red_block", 1, 6 );
	self.binoculars_hud_item[ "percentage_bar" ] set_default_hud_parameters();
	self.binoculars_hud_item[ "percentage_bar" ].alignX = "left";
	self.binoculars_hud_item[ "percentage_bar" ].alignY = "top";
	self.binoculars_hud_item[ "percentage_bar" ].horzAlign = "center";
	self.binoculars_hud_item[ "percentage_bar" ].vertAlign = "middle";
	self.binoculars_hud_item[ "percentage_bar" ].x = 3;
	self.binoculars_hud_item[ "percentage_bar" ].y = -150;
	self.binoculars_hud_item[ "percentage_bar" ].alpha = 0.0;
	self.binoculars_hud_item[ "percentage_bar" ].sort = self.binoculars_hud_item[ "reticle_scanning_frame" ].sort + 1;
	
	face_model_index = 0;
	if ( IsDefined( targ.binocular_hvt ) && targ.binocular_hvt )
	{
		face_model_index = 1;
	}
	
	face_parts = [];
	num_face_parts = GetNumParts( self.binoculars_face_scanning_models[ face_model_index ][ 0 ].model );
	for ( i = 0; i < num_face_parts; i++ )
	{
		face_parts[ i ] = GetPartName( self.binoculars_face_scanning_models[ face_model_index ][ 0 ].model, i );
	}
	
	num_simultaneous_red_parts = 8;
	cur_index = [];
	cur_index[ 0 ] = 0;
	cur_index[ 1 ] = 0;
	
	while ( face_parts.size > 0 && SightTracePassed( self GetEye(), targ GetTagOrigin( "J_Head" ), false, undefined ) )
	{
		if ( VectorDot( AnglesToForward( self GetPlayerAngles() ), AnglesToForward( targ GetTagAngles( "tag_eye" ) ) ) > 0.0 )
		{
			if ( !flag( "scan_target_not_facing" ) )
			{
				self.binoculars_hud_item[ "percentage_bar" ].alpha = 0.0;
				self.binoculars_hud_item[ "percentage" ] SetText( "" );
				
				self.binoculars_face_scanning_models[ face_model_index ][ 0 ] HideAllParts();
				
				for ( i = 0; i < num_face_parts; i++ )
				{
					face_parts[ i ] = GetPartName( self.binoculars_face_scanning_models[ face_model_index ][ 0 ].model, i );
				}
			}
			
			flag_set( "scan_target_not_facing" );
			self notify( "stop_binocular_scan_loop_sound" );
			
			if ( !IsDefined( self.scan_loop_red_sound ) )
			{
				self thread aud_binoculars( "scan_loop_red" );
			}
			
			for ( i = 0; i <= 1; i++ )
			{
				self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ] ShowPart( GetPartName( self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ].model, cur_index[ i ] ) );
				
				if ( cur_index[ i ] >= num_simultaneous_red_parts )
				{
					self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ] HidePart( GetPartName( self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ].model, cur_index[ i ] - num_simultaneous_red_parts ) );
				}
				else
				{
					self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ] HidePart( GetPartName( self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ].model, GetNumParts( self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ].model ) + cur_index[ i ] -
																										    num_simultaneous_red_parts ) );
				}
				
				cur_index[ i ]++;
				
				if ( cur_index[ i ] >= GetNumParts( self.binoculars_face_scanning_models[ face_model_index ][ i + 1 ].model ) )
				{
					cur_index[ i ] = 0;
				}
			}
			
			wait 0.05;
			continue;
		}
		
		flag_clear( "scan_target_not_facing" );
		
		if ( !IsDefined( self.scan_loop_sound ) )
		{
			self thread aud_binoculars( "scan_loop" );
		}
		
		self notify( "stop_binocular_scan_loop_red_sound" );
		
		randomIndex = RandomInt( face_parts.size );
		self.binoculars_face_scanning_models[ face_model_index ][ 0 ] ShowPart( face_parts[ randomIndex ] );
		
		self.binoculars_face_scanning_models[ face_model_index ][ 1 ] HideAllParts();
		self.binoculars_face_scanning_models[ face_model_index ][ 2 ] HideAllParts();
		
		face_parts = array_remove_index( face_parts, randomIndex );
		
		self.binoculars_hud_item[ "percentage_bar" ] SetShader( "red_block", Int( 205 * ( 1.0 - ( face_parts.size / num_face_parts ) ) ), self.binoculars_hud_item[ "percentage_bar" ].height );
		self.binoculars_hud_item[ "percentage_bar" ].alpha = 1.0;
		
		self.binoculars_hud_item[ "percentage" ] SetText( "" + Int( 100 * ( 1.0 - ( face_parts.size / num_face_parts ) ) ) );
		
		wait 0.1;
	}
	
	if ( face_parts.size == 0 )
	{
		self notify( "binoculars_facial_scan_finished" );
	}
}

binocular_face_scanning_data()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	self notify( "face_scanning_data" );
	self endon( "face_scanning_data" );
	
	num_lines = 35;
	y_pos = 1;
	default_alpha = 0.75;
	
	for ( i = 0; i < num_lines; i++ )
	{
		self.binoculars_hud_item[ "profile_data_line_" + i ] = maps\_hud_util::createIcon( "white", 1, 64 );
		self.binoculars_hud_item[ "profile_data_line_" + i ] set_default_hud_parameters();
		self.binoculars_hud_item[ "profile_data_line_" + i ].alignX = "center";
		self.binoculars_hud_item[ "profile_data_line_" + i ].alignY = "bottom";
		self.binoculars_hud_item[ "profile_data_line_" + i ].horzAlign = "center";
		self.binoculars_hud_item[ "profile_data_line_" + i ].vertAlign = "middle";
		self.binoculars_hud_item[ "profile_data_line_" + i ].x = 144 + i * 2;
		self.binoculars_hud_item[ "profile_data_line_" + i ].y = y_pos;
		self.binoculars_hud_item[ "profile_data_line_" + i ].color = ( 0.123, 0.325, 0.6 );
		self.binoculars_hud_item[ "profile_data_line_" + i ].alpha = default_alpha;
		self.binoculars_hud_item[ "profile_data_line_" + i ].sort = self.binoculars_hud_item[ "reticle_scanning_frame" ].sort - 1;
	}
	
	theta = RandomFloatRange( -90.0, 90.0 );
	thetaFrequency = RandomFloatRange( 10.0, 25.0 );

	while ( !self.binoculars_scanning_complete && !self.binoculars_stop_scanning )
	{
		theta += thetaFrequency * 4;

		if ( flag( "scan_target_not_facing" ) )
		{
			if ( RandomInt( 10 ) > 8 )
			{
				thetaFrequency = RandomFloatRange( 10.0, 25.0 );
			}
			
			for ( i = 0; i < num_lines; i++ )
			{
				self.binoculars_hud_item[ "profile_data_line_" + i ].height = Int( clamp( 6 * ( sin( theta - thetaFrequency * ( i + 1 ) ) + 1.0 ) + Pow( RandomFloatRange( 0.0, 6.0 ), 2 ), 0, 64 ) );
				self.binoculars_hud_item[ "profile_data_line_" + i ] SetShader( "white", self.binoculars_hud_item[ "profile_data_line_" + i ].width, self.binoculars_hud_item[ "profile_data_line_" + i ].height );
			}
		}
		else
		{			
			for ( i = 0; i < num_lines; i++ )
			{
				self.binoculars_hud_item[ "profile_data_line_" + i ].height = Int( clamp( ( sin( theta - thetaFrequency * ( i + 1 ) ) + 1.0 + RandomFloatRange( 0.0, 0.1 ) ) * 32, 0, 64 ) );
				self.binoculars_hud_item[ "profile_data_line_" + i ] SetShader( "white", self.binoculars_hud_item[ "profile_data_line_" + i ].width, self.binoculars_hud_item[ "profile_data_line_" + i ].height );
			}
		}
		
		wait 0.05;
	}
	
	while ( !self.binoculars_stop_scanning )
	{
		for ( i = 0; i < num_lines; i++ )
		{
			self.binoculars_hud_item[ "profile_data_line_" + i ].height *= RandomFloatRange( 0.8, 0.95 );
			
			if (self.binoculars_hud_item[ "profile_data_line_" + i ].height < 1 )
			{
				self.binoculars_hud_item[ "profile_data_line_" + i ].alpha = 0.0;
			}
			else
			{
				if ( self.binoculars_hud_item[ "profile_data_line_" + i ].y != y_pos )
				{
					self.binoculars_hud_item[ "profile_data_line_" + i ].y = y_pos + self.binoculars_hud_item[ "profile_data_line_" + i ].height;
				}
				
				self.binoculars_hud_item[ "profile_data_line_" + i ] SetShader( "white", self.binoculars_hud_item[ "profile_data_line_" + i ].width, Int( self.binoculars_hud_item[ "profile_data_line_" + i ].height ) );
			}
		}
		
		wait 0.05;
	}
	
	for ( i = 0; i < num_lines; i++ )
	{
		self.binoculars_hud_item[ "profile_data_line_" + i ] Destroy();
		self.binoculars_hud_item[ "profile_data_line_" + i ] = undefined;
	}
}

binoculars_monitor_scanning_button()
{
	while ( true )
	{
		while ( !self AttackButtonPressed() )
			waitframe();

		self notify( "scanning" );
		
		while ( self AttackButtonPressed() )
			waitframe();
			
		self notify( "stop_scanning" );
	}
}

binoculars_monitor_scanning()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	self thread binoculars_monitor_scanning_button();
	
	while ( 1 )
	{
		if ( !self AttackButtonPressed() )
		{
			self waittill( "scanning" );
		}
		
		if ( self.current_binocular_zoom_level == 0 )
		{
			self waittill( "binocular_zoom" );
			wait 0.05;
			continue;
		}
		
		if ( IsDefined( self.binoculars_scan_target ) )
		{
			targ = self.binoculars_scan_target;
			
			if ( !SightTracePassed( self GetEye(), targ GetTagOrigin( "J_Head" ), false, undefined ) )
			{
				wait 0.05;
				continue;
			}
			
			self thread binoculars_lock_to_target( targ );
			self thread scan_blur();
					
			while ( self AttackButtonPressed() && IsDefined( targ ) && IsDefined( self.binoculars_linked_to_target ) && self.binoculars_linked_to_target && !Target_IsInCircle( self.binocular_target, self, GetDvarInt( "cg_fov" ), 50 ) &&
				   SightTracePassed( self GetEye(), targ GetTagOrigin( "J_Head" ), false, undefined ) )
			{
				wait 0.05;
			}
			
			if ( !SightTracePassed( self GetEye(), targ GetTagOrigin( "J_Head" ), false, undefined ) )
			{
				wait 0.05;
				targ = undefined;
			}
			
			if ( !self AttackButtonPressed() || !IsDefined( targ ) )
			{
				self binoculars_unlock_from_target();
				self notify( "stop_scanning" );
				continue;
			}

			self notify( "scanning_target" ); //JZ - put this in because "scanning" returns even if you aren't on an enemy target.
			
			self.binoculars_scanning_complete = false;
			self.binoculars_stop_scanning = false;
			
			self thread binocular_face_scanning( targ );
			self thread binocular_face_scanning_lines( targ );
			self thread binocular_face_scanning_data();
			
			
			ret = waittill_any_return( "binoculars_facial_scan_finished", "stop_scanning" );
			
			self notify( "stop_binocular_scan_loop_sound" );
			self notify( "stop_binocular_scan_loop_red_sound" );
			
			time = 0.0;
			
			if ( ret == "binoculars_facial_scan_finished" )
			{
				self notify( "scanning_complete" );
				self.binoculars_scanning_complete = true;
				if ( IsDefined( targ.binocular_facial_profile ) )
				{
					self.binoculars_hud_item[ "profile" ] SetShader( targ.binocular_facial_profile, self.binoculars_hud_item[ "profile" ].width, self.binoculars_hud_item[ "profile" ].height );
				}
				else
				{
					self.binoculars_hud_item[ "profile" ] SetShader( "cnd_binocs_hud_photo_unknown", self.binoculars_hud_item[ "profile" ].width, self.binoculars_hud_item[ "profile" ].height );
				}
				
				while ( self AttackButtonPressed() && time < 0.5 )
				{
					time += 0.05;
					wait 0.05;
				}
			}
			
			if ( time >= 0.5 )
			{
				if ( IsDefined( targ.binocular_hvt ) && targ.binocular_hvt )
				{
					self notify( "hvt_confirmed" );
					flag_set( "hvt_confirmed" );
					self thread aud_binoculars( "positive" );
				}	
				else if ( IsDefined( targ.binocular_double_agent ) && targ.binocular_double_agent )
			    {
			    	flag_set( "double_agent_confirmed" );
					self thread aud_binoculars( "positive" );				
			    }
				else
				{
					self thread aud_binoculars( "negative" );
				}
			
				while ( self AttackButtonPressed() && SightTracePassed( self GetEye(), targ GetTagOrigin( "J_Head" ), false, undefined ) )
				{
					wait 0.05;
				}
			}
			else
			{
				self notify( "stop_scanning" );
			}
			
			foreach ( face_model_array in self.binoculars_face_scanning_models )
			{
				foreach ( face_model in face_model_array )
				{
					face_model Delete();
				}
			}
			
			self.binoculars_face_scanning_models = undefined;
				
			self.binoculars_stop_scanning = true;
			flag_clear( "scan_target_not_facing" );
			
			self.binoculars_hud_item[ "profile" ] Destroy();
			self.binoculars_hud_item[ "profile" ] = undefined;

			if ( IsDefined( self.binoculars_hud_item[ "percentage_bar" ] ) )
			{
				self.binoculars_hud_item[ "percentage_bar" ] Destroy();
				self.binoculars_hud_item[ "percentage_bar" ] = undefined;
			}
			
			if ( IsDefined( self.binoculars_hud_item[ "percentage" ] ) )
			{
				self.binoculars_hud_item[ "percentage" ] Destroy();
				self.binoculars_hud_item[ "percentage" ] = undefined;
			}
			
			self binoculars_unlock_from_target();
		}
		else
		{
			self waittill( "stop_scanning" );
		}
	}
}

static_overlay()
{	
	self.binoculars_hud_item[ "static" ] = newClientHudElem( self );
	self.binoculars_hud_item[ "static" ].x = 0;
	self.binoculars_hud_item[ "static" ].y = 0;
	self.binoculars_hud_item[ "static" ].alignX = "left";
	self.binoculars_hud_item[ "static" ].alignY = "top";
	self.binoculars_hud_item[ "static" ].horzAlign = "fullscreen";
	self.binoculars_hud_item[ "static" ].vertAlign = "fullscreen";
	self.binoculars_hud_item[ "static" ] setshader( "overlay_static", 640, 480 );
	self.binoculars_hud_item[ "static" ].alpha = 0.75;
	self.binoculars_hud_item[ "static" ].sort = -3;
	
	self.binoculars_hud_item[ "static" ] FadeOverTime( 0.05 );
	self.binoculars_hud_item[ "static" ].alpha = 0.9;
	
	wait 0.05;
	
	self.binoculars_hud_item[ "static" ] FadeOverTime( 0.15 );
	self.binoculars_hud_item[ "static" ].alpha = 0.0;
	
	wait 0.15;
	
	self.binoculars_hud_item[ "static" ] Destroy();
	self.binoculars_hud_item[ "static" ] = undefined;
}

monitor_binoculars_zoom()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	self.current_binocular_zoom_level = self.binoculars_default_zoom_level;
	self.binocular_zoom_levels = 2;
	self.first_zoom_level_fov = 2;
	
	while ( 1 )
	{
		self waittill( "binocular_zoom" );
		
		if ( !self AttackButtonPressed() )
		{
			self.binocular_zooming = true;
			
			if ( self.current_binocular_zoom_level == 0 )
			{
				self notify( "binoculars_zoom_lerp" );
				self EnableSlowAim( 0.5, 0.3 );
				self thread aud_binoculars( "zoom_in" );
				self thread zoom_blur( 2.0 );
				
				self.binoculars_zooming = true;
				self LerpFOV( self.first_zoom_level_fov, 1.5 );
				
				wait 1.5;
				
				self.binoculars_zooming = false;
				self notify( "binoculars_done_zooming" );
			}
			else
			{
				self thread zoom_lerp_dof();
				self DisableSlowAim();
				self thread aud_binoculars( "zoom_out" );
				
				SetSavedDvar( "cg_fov", 65 );
			}
			
			self.current_binocular_zoom_level++;
			if ( self.current_binocular_zoom_level >= self.binocular_zoom_levels )
			{
				self.current_binocular_zoom_level = 0;
				self.binoculars_hud_item[ "zoom_level_1" ] SetText( "20" );
				self.binoculars_hud_item[ "zoom_level_2" ] SetText( "10" );
				self.binoculars_hud_item[ "zoom_level_3" ] SetText( "0" );
				self.binoculars_hud_item[ "zoom_level_4" ] SetText( "" );
				self.binoculars_hud_item[ "zoom_level_5" ] SetText( "" );
			}
			else
			{
				self thread max_zoom_dof();
				self.binoculars_hud_item[ "zoom_level_1" ] SetText( "180" );
				self.binoculars_hud_item[ "zoom_level_2" ] SetText( "190" );
				self.binoculars_hud_item[ "zoom_level_3" ] SetText( "200" );
				self.binoculars_hud_item[ "zoom_level_4" ] SetText( "210" );
				self.binoculars_hud_item[ "zoom_level_5" ] SetText( "220" );
			}
			
			self.binocular_zooming = false;
		}
	}
}

zoom_blur( time )
{
	SetBlur( 10, 0.1 );
				
	wait 0.1;
	
	SetBlur( 0, time );
}

scan_blur()
{	
	SetBlur( 5, 0.0 );
	
	self waittill_any( "stop_scanning", "stop_using_binoculars", "take_binoculars", "binoculars_lerp_dof" );
	
	SetBlur( 0, 0.0 );
}

zoom_lerp_dof()
{
	self notify( "binoculars_lerp_dof" );
	self endon( "binoculars_lerp_dof" );
	
	maps\_art::dof_enable_script( 50, 100, 10, 100, 200, 6, 0.0 );
	
	maps\_art::dof_disable_script( 0.5 );
}

max_zoom_dof()
{
	maps\_art::dof_enable_script( level.dof["base"]["current"]["nearStart"], level.dof["base"]["current"]["nearEnd"], 10, 11000, 12000, 10, 0.0 );
}

binoculars_zoom_display()
{
	self.binoculars_hud_item[ "zoom_level_1" ] = self maps\_hud_util::createClientFontString( "default", 0.8 );
	self.binoculars_hud_item[ "zoom_level_1" ].x = 63;
	self.binoculars_hud_item[ "zoom_level_1" ].y = -223;
	self.binoculars_hud_item[ "zoom_level_1" ].alignX = "right";
	self.binoculars_hud_item[ "zoom_level_1" ].alignY = "middle";
	self.binoculars_hud_item[ "zoom_level_1" ].horzAlign = "left";
	self.binoculars_hud_item[ "zoom_level_1" ].vertAlign = "middle";
	self.binoculars_hud_item[ "zoom_level_1" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "zoom_level_1" ].alpha = 0.5;
	self.binoculars_hud_item[ "zoom_level_1" ] SetText( "20" );
	
	self.binoculars_hud_item[ "zoom_level_2" ] = self maps\_hud_util::createClientFontString( "default", 0.9 );
	self.binoculars_hud_item[ "zoom_level_2" ].x = 63;
	self.binoculars_hud_item[ "zoom_level_2" ].y = -112;
	self.binoculars_hud_item[ "zoom_level_2" ].alignX = "right";
	self.binoculars_hud_item[ "zoom_level_2" ].alignY = "middle";
	self.binoculars_hud_item[ "zoom_level_2" ].horzAlign = "left";
	self.binoculars_hud_item[ "zoom_level_2" ].vertAlign = "middle";
	self.binoculars_hud_item[ "zoom_level_2" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "zoom_level_2" ].alpha = 0.5;
	self.binoculars_hud_item[ "zoom_level_2" ] SetText( "10" );
	
	self.binoculars_hud_item[ "zoom_level_3" ] = self maps\_hud_util::createClientFontString( "default", 1.2 );
	self.binoculars_hud_item[ "zoom_level_3" ].x = 64;
	self.binoculars_hud_item[ "zoom_level_3" ].y = -1;
	self.binoculars_hud_item[ "zoom_level_3" ].alignX = "right";
	self.binoculars_hud_item[ "zoom_level_3" ].alignY = "middle";
	self.binoculars_hud_item[ "zoom_level_3" ].horzAlign = "left";
	self.binoculars_hud_item[ "zoom_level_3" ].vertAlign = "middle";
	self.binoculars_hud_item[ "zoom_level_3" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "zoom_level_3" ].alpha = 1.0;
	self.binoculars_hud_item[ "zoom_level_3" ] SetText( "0" );
	
	self.binoculars_hud_item[ "zoom_level_4" ] = self maps\_hud_util::createClientFontString( "default", 0.9 );
	self.binoculars_hud_item[ "zoom_level_4" ].x = 63;
	self.binoculars_hud_item[ "zoom_level_4" ].y = 109;
	self.binoculars_hud_item[ "zoom_level_4" ].alignX = "right";
	self.binoculars_hud_item[ "zoom_level_4" ].alignY = "middle";
	self.binoculars_hud_item[ "zoom_level_4" ].horzAlign = "left";
	self.binoculars_hud_item[ "zoom_level_4" ].vertAlign = "middle";
	self.binoculars_hud_item[ "zoom_level_4" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "zoom_level_4" ].alpha = 0.5;
	self.binoculars_hud_item[ "zoom_level_4" ] SetText( "" );
	
	self.binoculars_hud_item[ "zoom_level_5" ] = self maps\_hud_util::createClientFontString( "default", 0.8 );
	self.binoculars_hud_item[ "zoom_level_5" ].x = 63;
	self.binoculars_hud_item[ "zoom_level_5" ].y = 220;
	self.binoculars_hud_item[ "zoom_level_5" ].alignX = "right";
	self.binoculars_hud_item[ "zoom_level_5" ].alignY = "middle";
	self.binoculars_hud_item[ "zoom_level_5" ].horzAlign = "left";
	self.binoculars_hud_item[ "zoom_level_5" ].vertAlign = "middle";
	self.binoculars_hud_item[ "zoom_level_5" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "zoom_level_5" ].alpha = 0.333;
	self.binoculars_hud_item[ "zoom_level_5" ] SetText( "" );
}

binoculars_angles_display()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	self.binoculars_hud_item[ "angles" ] = self maps\_hud_util::createClientFontString( "default", 1.2 );
	self.binoculars_hud_item[ "angles" ].x = -20;
	self.binoculars_hud_item[ "angles" ].y = -25;
	self.binoculars_hud_item[ "angles" ].alignX = "right";
	self.binoculars_hud_item[ "angles" ].alignY = "top";
	self.binoculars_hud_item[ "angles" ].horzAlign = "center";
	self.binoculars_hud_item[ "angles" ].vertAlign = "top";
	self.binoculars_hud_item[ "angles" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "angles" ].alpha = 1.0;
	self.binoculars_hud_item[ "angles" ].glowColor = ( 1, 1, 1 );
	self.binoculars_hud_item[ "angles" ].glowAlpha = 0.0;
	
	self.binoculars_hud_item[ "angles_degree" ] = self maps\_hud_util::createClientFontString( "default", 1.2 );
	self.binoculars_hud_item[ "angles_degree" ].x = -55;
	self.binoculars_hud_item[ "angles_degree" ].y = -25;
	self.binoculars_hud_item[ "angles_degree" ].alignX = "center";
	self.binoculars_hud_item[ "angles_degree" ].alignY = "top";
	self.binoculars_hud_item[ "angles_degree" ].horzAlign = "center";
	self.binoculars_hud_item[ "angles_degree" ].vertAlign = "top";
	self.binoculars_hud_item[ "angles_degree" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "angles_degree" ].alpha = 1.0;
	self.binoculars_hud_item[ "angles_degree" ].glowColor = ( 1, 1, 1 );
	self.binoculars_hud_item[ "angles_degree" ].glowAlpha = 0.0;
	self.binoculars_hud_item[ "angles_degree" ] SetText( &"CORNERED_BINOCULARS_DEGREE_SYMBOL" );
	
	self.binoculars_hud_item[ "heading" ] = self maps\_hud_util::createClientFontString( "default", 1.2 );
	self.binoculars_hud_item[ "heading" ].x = 0;
	self.binoculars_hud_item[ "heading" ].y = -20;
	self.binoculars_hud_item[ "heading" ].alignX = "center";
	self.binoculars_hud_item[ "heading" ].alignY = "top";
	self.binoculars_hud_item[ "heading" ].horzAlign = "center";
	self.binoculars_hud_item[ "heading" ].vertAlign = "top";
	self.binoculars_hud_item[ "heading" ].color = ( 0.247, 0.651, 0.8 );
	self.binoculars_hud_item[ "heading" ].alpha = 1.0;
	self.binoculars_hud_item[ "heading" ].glowColor = ( 1, 1, 1 );
	self.binoculars_hud_item[ "heading" ].glowAlpha = 0.0;
	
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
		
		self.binoculars_hud_item[ "angles" ] SetText( Int( degrees ) + "  " + minutes_string + "' " + seconds_string + "\"" );
		
		if ( degrees > 337.5 || degrees < 22.5 )
		{
			self.binoculars_hud_item[ "heading" ] SetText( "N" );
		}
		else if ( degrees < 67.5 )
		{
			self.binoculars_hud_item[ "heading" ] SetText( "NE" );
		}
		else if ( degrees < 112.5 )
		{
			self.binoculars_hud_item[ "heading" ] SetText( "E" );
		}
		else if ( degrees < 157.5 )
		{
			self.binoculars_hud_item[ "heading" ] SetText( "SE" );
		}
		else if ( degrees < 202.5 )
		{
			self.binoculars_hud_item[ "heading" ] SetText( "S" );
		}
		else if ( degrees < 247.5 )
		{
			self.binoculars_hud_item[ "heading" ] SetText( "SW" );
		}
		else if ( degrees < 292.5 )
		{
			self.binoculars_hud_item[ "heading" ] SetText( "W" );
		}
		else
		{
			self.binoculars_hud_item[ "heading" ] SetText( "NW" );
		}
		
		wait 0.05;
	}
}

binocular_reticle_target_reaction()
{
	self endon( "stop_using_binoculars" );
	self endon( "take_binoculars" );
	
	target_x = 0;
	target_y = 0;
	target_width = 1;
	target_height = 1;
	
	no_target = false;
	last_target = undefined;
	
	while ( 1 )
	{
		if ( ( !IsDefined( self.binocular_zooming ) || ( IsDefined( self.binocular_zooming ) && !self.binocular_zooming ) ) && ( !self.binocular_target IsLinked() || !self AttackButtonPressed() ) )
		{
			if ( IsDefined( self.binoculars_trace ) && IsDefined( self.binoculars_scan_target ) )
			{
				if ( !IsDefined( last_target ) || last_target != self.binoculars_scan_target )
				{
					no_target = false;
					
					if ( self.binocular_target IsLinked() )
					{
						self.binocular_target Unlink();
					}
					
					self.binocular_target.origin = self.binoculars_scan_target GetTagOrigin( "tag_eye" ) - ( 0, 0, 3 );
					self.binocular_target.angles = self.binoculars_scan_target GetTagAngles( "tag_eye" );
					self.binocular_target LinkTo( self.binoculars_scan_target, "tag_eye" );
						
					self thread binoculars_remove_target_on_death( self.binoculars_scan_target );
					
					last_target = self.binoculars_scan_target;
				}
			}
			else
			{
				no_target = true;
				last_target = undefined;
			}
		}
		
		wait 0.1;
	}
}


binoculars_pip_init()
{
	level.pip = level.player newpip();
	level.pip.enable = 0;
}

binoculars_pip_enable()
{	
	level.pip.enableshadows = true;
	level.pip.tag = "tag_origin";
	level.pip.width = 150;
	level.pip.height = 150;
	level.pip.x = 320 - level.pip.width / 2;
	level.pip.y = 240 - level.pip.height / 2;

//	level.pip.visionsetnight = self.binoculars_vision_set;
//	level.pip.visionsetnaked = self.binoculars_vision_set;
	
	if ( IsDefined( level.pip.entity ) )
	{		
		level.pip.entity Delete();
		level.pip.entity = undefined;
	}
	
	level.pip.entity = Spawn( "script_model", self GetEye() );
	level.pip.entity SetModel( "tag_origin" );
	level.pip.entity.angles = self GetPlayerAngles();
	level.pip.entity LinkToPlayerView( self, "tag_origin", ( ( Distance( self.binocular_target.origin, self GetEye() ) - 300 ), 0, 0 ), ( 0, 0, 0 ), false );

	level.pip.freeCamera = true;

	level.pip.tag = "tag_origin";
	
	level.pip.fov = 5;

	level.pip.enable = true;
	
	self thread binoculars_pip_update_position();
}

binoculars_pip_update_position()
{
	level.pip endon( "pip_disabled" );
	
	while ( IsDefined( self.binocular_target ) )
	{
		level.pip.entity Delete();
		level.pip.entity = Spawn( "script_model", self GetEye() );
		level.pip.entity SetModel( "tag_origin" );
		level.pip.entity.angles = self GetPlayerAngles();
		level.pip.entity LinkToPlayerView( self, "tag_origin", ( ( Distance( self.binocular_target.origin, self GetEye() ) - 300 ), 0, 0 ), ( 0, 0, 0 ), false );
		wait 0.05;
	}
}

binoculars_pip_disable()
{
	level.pip notify( "pip_disabled" );
	
	level.pip.enable = false;
	
	if ( IsDefined( level.pip.entity ) )
	{
		level.pip.entity Delete();
		level.pip.entity = undefined;
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
	self.alpha = 0.65;
}
