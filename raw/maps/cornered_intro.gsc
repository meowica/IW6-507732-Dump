#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\cornered_code_rappel;
#include maps\cornered_code_rappel_allies;
#include maps\cornered_binoculars;
#include maps\cornered_zipline_turret;
#include maps\cornered_lighting;
#include maps\player_scripted_anim_util;
//#include maps\_hud_util;

cornered_intro_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//Intro
	flag_init( "player_falling" );
	
	flag_init( "intro_id_scan" );
	flag_init( "fade_in_done" );
	flag_init( "start_introtext" );
	flag_init( "swap_ally_intro_gun" );
	flag_init( "helicopter_spawned" );
	flag_init( "introscreen_done" );
	flag_init( "intro_vo_begin" );
	flag_init( "intro_baker_move" );
	flag_init( "vip_heli_approach" );
	flag_init( "intro_heli_landed" );
	flag_init( "looking_at_roof" );
	//flag_init( "intro_done" );
	flag_init( "zipline_launcher_setup" );
	flag_init( "player_fired_zipline" );
	flag_init( "intro_baker_done" );
	flag_init( "intro_rorke_done" );
	//flag_init( "open_roofdoor1" );
	//flag_init( "open_roofdoor2" );
	flag_init( "start_hvt_scene" );
	flag_init( "hvt_greeter_meet" );
	flag_init( "hvt_chopper_leave" );
	
	
	flag_init( "give_player_binoculars" );
	flag_init( "give_binocular_hint_if_needed" );
	flag_init( "player_using_binoculars" );
	
	//Zipline
	flag_init( "rorke_launcher_aim_loop_start" );
	flag_init( "baker_launcher_aim_loop_start" );
	flag_init( "player_on_turret" );
	flag_init( "player_can_use_zipline" );
	flag_init( "player_is_starting_zipline" );
	flag_init( "player_is_ziplining" );
	flag_init( "fx_screen_raindrops" );
	flag_init( "player_detach" );
	flag_init( "do_specular_sun_lerp" );
	
	flag_init( "intro_finished" );
	flag_init( "zipline_finished" );
	
	flag_init( "rorke_ready_to_setup_zipline" );
	flag_init( "baker_ready_to_setup_zipline" );
	
	//PreCacheItem( "optical_scanner_on" );
	
	PreCacheModel( "generic_prop_raven" );
	PreCacheModel( "head_cnd_test_goggles_glow" );
	PreCacheModel( "cnd_briefcase_01_shell" );
	//PreCacheModel( "weapon_m14_sp_iw5" );
	PreCacheModel( "weapon_imbel_ia2" );
	PreCacheModel( "vehicle_nh90_interior_only" );
	PreCacheModel( "cnd_rappel_device" );
	PreCacheModel( "cnd_rappel_device_obj" );
	PreCacheModel( "cnd_zipline_rope" );
	PreCacheModel( "cnd_rappel_tele_rope_noclip" );
	PreCacheModel( "cnd_rappel_window_frame_obj" );
	PreCacheModel( "weapon_zipline_rope_launcher_alt_obj" );

	PreCacheRumble( "light_1s" );
	PreCacheRumble( "heavy_2s" );
	PreCacheRumble( "chopper_flyover" );
	PreCacheRumble( "light_in_out_2s" );
	
	PreCacheShader( "reticle_center_cross" );
	
	PreCacheTurret( "player_view_controller_binoculars_slow" );
	
	//"Press [{+actionslot 1}] to activate Optic Scanner."
	PreCacheString( &"CORNERED_BINOCULARS_USE_HINT" );
	//"Press [{+changezoom}] to toggle zoom."
	PreCacheString( &"CORNERED_BINOCULARS_ZOOM_HINT" );
	//"Press and hold [{+attack}] to activate facial recognition."
	PreCacheString( &"CORNERED_BINOCULARS_SCAN_HINT" );
	//"Target out of identification range."
	PreCacheString( &"CORNERED_BINOCULARS_RANGE_HINT" );
	//"HVT was not identified."
	PreCacheString( &"CORNERED_BINOCULARS_FAIL" );
	//"Press [{+actionslot 1}] to deactivate Optic Scanner."
	PreCacheString( &"CORNERED_BINOCULARS_REMOVE_HINT" );
	//"Press and hold [{+activate}] to deploy zipline launcher. "
	PreCacheString( &"CORNERED_DEPLOY_ZIPLINE_TURRET" );
	//"Press and hold [{+activate}] to zipline"
	PreCacheString( &"CORNERED_START_ZIPLINE" );
	
	//"Press [{+actionslot 1}] to activate Optic Scanner."
	add_hint_string( "binoc_use", &"CORNERED_BINOCULARS_USE_HINT" );
	//"Press [{+changezoom}] to toggle zoom."
	add_hint_string( "binoc_zoom", &"CORNERED_BINOCULARS_ZOOM_HINT", ::binoculars_hide_hint );
	//"Press and hold [{+attack}] to activate facial recognition."
	add_hint_string( "binoc_scan", &"CORNERED_BINOCULARS_SCAN_HINT", ::scan_hide_hint );
	//"Target out of identification range."
	add_hint_string( "binoc_range", &"CORNERED_BINOCULARS_RANGE_HINT" );
	//"Press [{+actionslot 1}] to deactivate Optic Scanner."
	add_hint_string( "binoc_deactivate", &"CORNERED_BINOCULARS_REMOVE_HINT" );
	//"Press [{+attack}] to fire the zipline"
	add_hint_string( "fire_zipline", &"CORNERED_ZIPLINE_FIRE" );
	
	level.cornered_player_arms = spawn_anim_model( "cornered_player_arms" );
	level.cornered_player_arms player_flap_sleeves_setup( true );
	hide_player_arms();
	
	level.cornered_player_legs = spawn_anim_model( "cornered_player_legs" );
	level.cornered_player_legs Hide();
	
	level.arms_and_legs = [];
	level.arms_and_legs = add_to_array( level.arms_and_legs, level.cornered_player_arms );
	level.arms_and_legs = add_to_array( level.arms_and_legs, level.cornered_player_legs );
		
	level.zipline_trolley_obj = GetEnt( "zipline_trolley_obj", "targetname" );
	level.zipline_trolley_obj Hide();
	
	level.rappel_window_frame_obj = GetEnt( "rappel_window_frame_obj", "targetname" );
	level.rappel_window_frame_obj Hide();
	
	level.zipline_window_player_hit = GetEnt( "zipline_window_player_hit", "targetname" );
	level.zipline_window_player_hit Hide();
	
//	level.cnd_roof_neon_off = GetEnt( "cnd_roof_neon_off", "targetname" );
//	level.cnd_roof_neon_off Hide();
	
//	level.reflection_window_inverted = GetEnt( "reflection_window", "targetname" );
//	level.reflection_window_inverted Hide();
	
	SetDvarIfUninitialized( "raven_demo", "0" );
}

setup_intro()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "intro";
	setup_player();
	spawn_allies();
	thread handle_intro_fx();
	thread maps\cornered_audio::aud_check( "intro" );
}

setup_zipline()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.zipline_startpoint = true;
	setup_player();
	spawn_allies();
	
	thread zipline_setup();
	thread handle_intro_fx();
	thread maps\cornered_audio::aud_check( "zipline" );
	thread fireworks_intro_post();
	flag_set( "rorke_ready_to_setup_zipline" );
	
	flag_set( "fx_screen_raindrops" );	
	thread maps\cornered_fx::fx_screen_raindrops();
}

begin_intro()
{
	//--use this to run your functions for an area or event.--
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	thread intro_save_check( "intro_done", "intro_finished" );
	thread intro();
	thread fireworks_intro();
	flag_set( "fx_screen_raindrops" );	
	thread maps\cornered_fx::fx_screen_raindrops();
	//thread zipline();
	flag_wait( "intro_finished" );	
	//thread autosave_tactical(); //look at intro_save_check above - will save if player isn't trying to jump off building
}

begin_zipline()
{
	//--use this to run your functions for an area or event.--
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	flag_wait( "rorke_ready_to_setup_zipline" );
	thread zipline();
	flag_wait( "zipline_finished" );	
	thread autosave_tactical();
}

intro()
{
	thread introscreen_display();
	thread intro_handler();
	thread intro_allies_vo();
	thread zipline_setup();
	//thread zipline_anims_setup();
}

introscreen_display()
{
	//""Federation Day""
	//"Caracas, Venezuela\n"
	//"November 12th - 12:41:[{FAKE_INTRO_SECONDS:09}]"
	intro_screen_create( &"CORNERED_INTROSCREEN_LINE_1", &"CORNERED_INTROSCREEN_LINE_5", &"CORNERED_INTROSCREEN_LINE_2" );
	flag_wait( "start_introtext" );
	//wait( 5.5 );
	level maps\_introscreen::introscreen( true );
}

intro_handler()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	level thread intro_chopper_fx();
	thread intro_enemy_scene();
	
	death_vol = GetEnt( "start_building_fall_volume", "targetname" );
	death_vol thread cornered_falling_death();
	
	level.intro_struct	= getstruct( "stealth_intro_struct", "targetname" );
	//level.intro_black = thread maps\_introscreen::introscreen_generic_black_fade_in( 2 );
	level.intro_black	= thread maps\_introscreen::introscreen_generic_black_fade_in( 8 );
			 //   timer    func 	   param1 			 
	delayThread( 7		, ::flag_set, "fade_in_done" );
	delayThread( 1		, ::flag_set, "start_introtext" );
		
	//stuff while we're still at black
	thread intro_player();
	
	wait( 6 );
	
	level.allies[ level.const_rorke ].animname = "rorke";
	level.allies[ level.const_baker ].animname = "baker";

	level.allies[ level.const_rorke ] thread intro_rorke();	
	wait( 0.2 );
	thread intro_rorke_gun();
	thread intro_baker();

	wait( 8.5 ); //timing up Rorke's look to heli flyover
	
	intro_heli = spawn_vehicles_from_targetname_and_drive( "intro_helis" );
	flag_set( "helicopter_spawned" );
	
	foreach ( chopper in intro_heli )
	{
		chopper godon();
	}
	level.vip_heli = get_vehicle( "vip_heli", "script_noteworthy" );
//	thread maps\cornered_audio::aud_intro_choppers( intro_heli );
//	thread maps\cornered_audio::aud_hvt_chopper( level.vip_heli );
	array_thread( intro_heli, ::vehicle_lights_on, "running" );
	level.vip_heli thread intro_heli_land();
		
	wait 1.2;
	flag_set( "intro_vo_begin" );
	wait 2.5;
	level.player PlayRumbleOnEntity( "chopper_flyover" );
	Earthquake( 0.08, 30, level.player.origin, 1000 );
	
	if ( GetDvar( "raven_demo" ) == "0" )
	{
		//one heli lands
		flag_wait( "intro_heli_landed" );
		
		//binocular sequence
		wait( 1.75 );
		intro_binocular_scene();
		thread intro_optional_objective();
	}

	//hand off to zipline
	wait( 0.5 );
	flag_set( "intro_finished" );
}

intro_optional_objective()
{
	level endon( "player_is_starting_zipline" );
	
	flag_wait( "double_agent_confirmed" );
	
	thread maps\cornered::obj_optional_double_agent();
}

intro_player()
{
	level endon( "player_falling" );
	
	level.player FreezeControls( true );
	level.player _disableWeapon();
	
	wait( 0.2 );
	level.player SetStance( "crouch" );

	//--NEW--
	thread intro_player_stand();
	
	//player_speed_percent( 0 ); //freeze player in place
	
	rig		   = level.player spawn_tag_origin();
	rig.origin = rig.origin + ( 0, 0, .3 ); //to deal with rotation?
	rig.angles = level.player.angles + ( -8, 0, 0 );
	waittillframeend;
	level.player PlayerLinkToAbsolute( rig, "tag_origin" );	
	
	flag_wait( "fade_in_done" );
	wait( 1.5 );
	level.player Unlink();
	//player_speed_percent( 100 );
	level.player FreezeControls( false );
	rig Delete();
	
//	wait( 15.6 );
//	thread intro_player_binoc_anim();
//	level.player _enableWeapon();
	
	//--END NEW--
	
	/*intro_player_arms = spawn_anim_model( "cornered_player_arms" );
	level.intro_struct anim_first_frame_solo( intro_player_arms, "cornered_intro_player" );

	level.player PlayerLinkTo( intro_player_arms, "tag_origin", 0, 0, 0, 0, 0 );
	waittillframeend;
	level.player LerpViewAngleClamp( 0.05, 0, 0, 45, 45, 25, 15 );
	level.player FreezeControls( false );
	level.player AllowStand( false );
	level.player AllowProne( false );
	level.intro_struct anim_single_solo( intro_player_arms, "cornered_intro_player" );

	level.player Unlink();
	intro_player_arms Delete();
	level.player AllowStand( true );
	level.player AllowProne( true );
	waitframe();
	level.player SetStance( "stand" );*/
	
	if ( GetDvar( "raven_demo" ) == "0" )
	{
		flag_wait( "give_player_binoculars" );
		level.player give_binoculars();
		wait( 0.25 );
		//level.player binoculars_set_default_zoom_level( 0 );
		level.player thread intro_binocs_check_look_target(	 );
		level.player thread intro_binocs_check_look_target_for_render(	);
		level.player thread handle_binocular_zoom_magnet();
		thread intro_binocular_monitor();
		//level.player _enableWeapon();
		
		wait( 0.5 );
		thread intro_binocs_not_target_vo();
		thread intro_binocs_oracle_scanning_vo();
		
		flag_wait( "hvt_confirmed" );
		
		level.player _enableWeapon();
	}
	else
	{
		flag_set( "hvt_confirmed" );
	}
}

handle_binocular_zoom_magnet()
{
	self endon( "take_binoculars" );

	bottom_left = getstruct( "binoculars_zone_bottom_left", "targetname" ).origin;
	top_right	= getstruct( "binoculars_zone_top_right", "targetname" ).origin;
	
	while ( 1 )
	{
		self waittill( "binoculars_zoom_lerp" );
		
		player_yaw	 = self GetPlayerAngles()[ 1 ];
		player_pitch = self GetPlayerAngles()[ 0 ];
		
		left_yaw	 = VectorToYaw( bottom_left - self GetEye() );
		right_yaw	 = VectorToYaw( top_right - self GetEye() );
		bottom_pitch = VectorToAngles( bottom_left - self GetEye() )[ 0 ];
		top_pitch	 = VectorToAngles( top_right - self GetEye() )[ 0 ];
		
		if ( AngleClamp180( player_yaw - left_yaw ) <= 0 && AngleClamp180( player_yaw - right_yaw ) >= 0 )
		{
			plane_normal		   = VectorNormalize( VectorCross( ( 0, 0, 1 ), ( top_right - bottom_left ) ) );
			dist_to_plane		   = VectorDot( bottom_left - self GetEye(), plane_normal ) / VectorDot( AnglesToForward( self GetPlayerAngles() ), plane_normal );
			closest_point_on_plane = self GetEye() + AnglesToForward( self GetPlayerAngles() ) * dist_to_plane;
	
			if ( closest_point_on_plane[ 2 ]  > top_right[ 2 ]  && closest_point_on_plane[ 2 ] - top_right[ 2 ] < 500 )
			{
				opposite_corner_pos = ( bottom_left[ 0 ], bottom_left[ 1 ], top_right[ 2 ] );
				norm				= VectorNormalize( bottom_left - top_right );
				look_at_pos			= top_right + norm * VectorDot( norm, closest_point_on_plane - top_right );
				self adjust_player_view( closest_point_on_plane, look_at_pos );
			}
			else if ( closest_point_on_plane[ 2 ] < bottom_left[ 2 ]  && bottom_left[ 2 ] - closest_point_on_plane[ 2 ] < 500 )
			{
				opposite_corner_pos = ( top_right[ 0 ], top_right[ 1 ], bottom_left[ 2 ] );
				norm				= VectorNormalize( top_right - bottom_left );
				look_at_pos			= bottom_left + norm * VectorDot( norm, closest_point_on_plane - bottom_left );
				self adjust_player_view( closest_point_on_plane, look_at_pos );
			}
		}
	}
}

adjust_player_view( snap_pos, look_at_pos )
{
	player_view_controller_model = Spawn( "script_model", self.origin );
	player_view_controller_model SetModel( "tag_origin" );
	player_view_controller_model.origin = self.origin;
	player_view_controller_model.angles = self GetPlayerAngles();
	
	player_view_controller = get_player_view_controller( player_view_controller_model, "tag_origin", ( 0, 0, 0 ), "player_view_controller_binoculars_slow" );
	
	turret_snap_ent = Spawn( "script_model", snap_pos );
	turret_snap_ent SetModel( "tag_origin" );
	
	player_view_controller SnapToTargetEntity( turret_snap_ent );
	
	prev_origin = self.origin;
	
	turret_look_at_ent = Spawn( "script_model", look_at_pos );
	turret_look_at_ent SetModel( "tag_origin" );
	
	self PlayerLinkToAbsolute( player_view_controller, "tag_aim" );
	player_view_controller SetTargetEntity( turret_look_at_ent, self.origin - self GetEye() );
	
	wait 1;
	
	self Unlink();
	
	self SetOrigin( prev_origin );
	
	player_view_controller Delete();
	player_view_controller_model Delete();
	turret_snap_ent Delete();
	turret_look_at_ent Delete();
}

intro_player_stand()
{
	flag_wait( "player_stand" );
	
	if ( level.player GetStance() == "crouch" || level.player GetStance() == "prone" )
	{
		level.player SetStance( "stand" );
	}
}

//intro_player_binoc_anim()
//{
//	level endon( "death" );
//	//level.player DisableWeaponSwitch();
//	//level.player DisableUsability();
//	//level.player DisableOffhandWeapons();
//	
//	level.player _disableWeaponSwitch();
//	level.player _disableUsability();
//	level.player _disableOffhandWeapons();
//	
//	wait( 0.25 );
//	level.player.last_weapon = level.player GetCurrentWeapon();
//	//level.player _disableWeapon();
//	wait( 0.5 );
//	
//	stock_amt = undefined;
//	clip_amt  = undefined;
//	
//	if ( level.player.last_weapon != "none" )
//	{
//		stock_amt = level.player GetWeaponAmmoStock( level.player.last_weapon );
//		clip_amt  = level.player GetWeaponAmmoClip( level.player.last_weapon );
//	}
//		
//	level.player TakeWeapon( level.player.last_weapon );
//	level.player GiveWeapon( "optical_scanner_on" );
//	level.player _enableWeapon();
//	level.player SwitchToWeapon( "optical_scanner_on" );
//
//	wait( 1.45 );
//	level.player TakeWeapon( "optical_scanner_on" );
//	level.player GiveWeapon( level.player.last_weapon );
//	
//	if ( level.player.last_weapon != "none" )
//	{
//		level.player SetWeaponAmmoStock( level.player.last_weapon, stock_amt );
//		level.player SetWeaponAmmoClip( level.player.last_weapon, clip_amt );
//		level.player SwitchToWeapon( level.player.last_weapon );
//	}
//	
//	//level.player EnableUsability();
//	//level.player EnableWeaponSwitch();	
//	//level.player EnableOffhandWeapons();
//	
//	level.player _enableWeaponSwitch();
//	level.player _enableUsability();
//	level.player _enableOffhandWeapons();
//}

intro_rorke()
{
	level.intro_hideTagList = GetWeaponHideTags( self.weapon );
	
	//self gun_remove();
	wait( 0.2 );
	
	level.intro_struct thread anim_single_solo( self, "cornered_intro_rorke_2_start" );
	thread maps\cornered_audio::aud_intro( "r_jump" );
	
	wait( 0.1 );
	self gun_remove();
	
	self waittillmatch( "single anim", "anim_gunhand = \"right\"" );
	flag_set( "swap_ally_intro_gun" );
	self gun_recall();
	
	self waittillmatch( "single anim", "end" );
	
	if ( GetDvar( "raven_demo" ) == "0" )
	{
		level.intro_struct anim_first_frame_solo( self, "cornered_intro_rorke_2_end" );
		
		flag_wait( "hvt_confirmed" );
		
		if ( IsDefined( level.player.binoculars_active ) && level.player.binoculars_active )
		{
			level.player waittill( "stop_using_binoculars" );
		}
	}
	
	level.intro_struct thread anim_single_solo( self, "cornered_intro_rorke_2_end" );
	
	self waittillmatch( "single anim", "visor_on" );
	self thread ally_goggle_glow_on();
	thread maps\cornered_audio::aud_intro( "r_goggles" );
	
	if ( GetDvar( "raven_demo" ) == "0" )
	{
		wait 1.0;
		
		//Merrick: Hard copy, Oracle. Black Knight out.
		level.allies[ level.const_rorke ] smart_dialogue( "cornered_rke_hardcopyoracleblack" );
	}
	else
	{
		wait 2;
		level.player _enableWeapon();
	}
	
	self waittillmatch( "single anim", "end" );
	
	level.intro_struct thread anim_loop_solo( self, "cornered_intro_rorke_loop", "stop_rorke_intro_loop" );
	
	flag_set( "rorke_ready_to_setup_zipline" );
}

intro_rorke_gun()
{
	rig = spawn_anim_model( "intro_gun" );
	
	level.intro_struct thread anim_first_frame_solo( rig, "cornered_intro_rorke_gun" );
	
	org = rig GetTagOrigin( "J_prop_1" );
	ang = rig GetTagAngles( "J_prop_1" );
	
	gun = Spawn( "script_model", org );
	//gun SetModel( "weapon_m14_sp_iw5" );
	gun SetModel( "weapon_imbel_ia2" );
	gun.origin = org;
	gun.angles = ang;
	
	for ( i = 0; i < level.intro_hideTagList.size; i++ )
	{
		//gun HidePart( level.intro_hideTagList[ i ], "weapon_m14_sp_iw5" );
		gun HidePart( level.intro_hideTagList[ i ], "weapon_imbel_ia2" );
	}
	
	gun LinkTo( rig, "J_prop_1" );
	
	level.intro_struct thread anim_single_solo( rig, "cornered_intro_rorke_gun" );
	
	flag_wait( "swap_ally_intro_gun" );
	
	gun Unlink();
	gun Delete();
	rig Delete();	
}

start_baker( rorke )
{
	flag_set( "intro_baker_move" );
}

intro_baker()
{
	level.intro_struct thread anim_loop_solo( level.allies[ level.const_baker ], "cornered_intro_baker_loop1", "stop_baker_intro_loop" );
	
	flag_wait( "intro_baker_move" );
	level.intro_struct notify( "stop_baker_intro_loop" );
	waittillframeend;
	level.intro_struct thread anim_single_solo( level.allies[ level.const_baker ], "cornered_intro_baker" );
	
	level.allies[ level.const_baker ] waittillmatch( "single anim", "visor_on" );
	level.allies[ level.const_baker ] thread ally_goggle_glow_on();
	
	level.allies[ level.const_baker ] waittillmatch( "single anim", "end" );
	
	level.intro_struct thread anim_loop_solo( level.allies[ level.const_baker ], "cornered_intro_baker_loop2", "stop_baker_intro_loop" );
	
	flag_set( "baker_ready_to_setup_zipline" );
}

intro_chopper_fx()
{
	exploder( 7389 );
	level thread bird_fx();
	flag_wait( "vip_heli_approach" );
	wait( 0.5 );
	stop_exploder( 7389 );
}

bird_fx()
{
	wait( 0.7 );
	exploder( 22271 );
}

intro_heli_land()
{
	self.path_gobbler = true;
	self.animname	  = "nh90";
	self SetMaxPitchRoll( 10, 10 );
	self thread vehicle_lights_on( "running" );
	self thread vehicle_lights_on( "interior" );
	
	window_block  = GetEnt( "vip_heli_window_block", "targetname" );
	rt_door_block = GetEnt( "vip_heli_right_door_block", "targetname" );
	lf_door_block = GetEnt( "vip_heli_left_door_block", "targetname" );

	window_block LinkTo( self, "tag_origin" );
	rt_door_block LinkTo( self, "door_r" );
	lf_door_block LinkTo( self, "door_l" );

	org = self GetTagOrigin( "tag_origin" );
	ang = self GetTagAngles( "tag_origin" );
	
	interior		= Spawn( "script_model", org );
	interior.angles = ( 0, 90, 0 );
	interior LinkTo( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	interior SetModel( "vehicle_nh90_interior_only" );
	
	flag_wait( "vip_heli_move_to_anim" );
	self vehicle_detachfrompath();
	
 	flag_set( "vip_heli_approach" ); //used to be on node.
	
	intro_roof_node = getstruct( "intro_hvt_roof_animnode", "targetname" );
	intro_roof_node anim_single_solo( self, "cornered_roof_arrival_land_nh90" );
	flag_set( "intro_heli_landed" );
		
	self SetGoalYaw( self.angles[ 1 ] );
	self SetTargetYaw( self.angles[ 1 ] );	
	self SetHoverParams( 0, 0, 0 );
	self SetVehGoalPos( self.origin, 1 );
	
	if ( !flag( "looking_at_roof" ) )
	{
		intro_roof_node thread anim_loop_solo( self, "cornered_roof_arrival_wait_nh90", "stop_loop" );
	}
	
	if ( GetDvar( "raven_demo" ) == "0" )
		flag_wait( "looking_at_roof" );
	
	intro_roof_node notify( "stop_loop" );
	intro_roof_node anim_single_solo( self, "cornered_roof_arrival" );
	intro_roof_node thread anim_loop_solo( self, "cornered_roof_arrival_wait_nh90", "stop_loop" );
	//intro_roof_node thread anim_last_frame_solo( self, "cornered_roof_arrival" );
	
	flag_wait( "hvt_chopper_leave" );
	intro_roof_node notify( "stop_loop" );
	waittillframeend;
	
	self thread maps\_vehicle_code::animate_drive_idle();
	self SetMaxPitchRoll( 10, 35 );
	
	node = getstruct( "vip_heli_exit_path", "targetname" );
	self thread maps\_vehicle::vehicle_paths( node );
	
	flag_wait( "vip_heli_delete_blockers" );
	
	interior Delete();
	window_block Delete();
	rt_door_block Delete();
	lf_door_block Delete();
	
	//node = getstruct( "vip_heli_exit_path", "targetname" );
	
	//self vehicle_paths( node );
}

intro_enemy_setup()
{
	self.ignoreall = true;
	self.ignoreme  = true;
	self magic_bullet_shield( true );
	
	if ( self.script_noteworthy == "intro_hvt" )
	{
		level.intro_hvt = self;
		self.animname	= "hvt";
		waitframe();
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 0 ];
		self.binocular_hvt			  = true;
		
		self.script_startingposition = 2;
		
		self gun_remove();
		ang				= self GetTagAngles( "tag_weapon_left" );
		level.briefcase = Spawn( "script_model", self GetTagOrigin( "tag_weapon_left" ) );
		level.briefcase SetModel( "cnd_briefcase_01_shell" );
		level.briefcase.angles = ang;
		level.briefcase LinkTo( self, "tag_weapon_left", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	}
	if ( self.script_noteworthy == "intro_cmdr" )
	{
		level.intro_cmdr			  = self;
		self.animname				  = "cmdr";
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 1 ];
		self gun_remove();
		self thread debug_death();
	}
	if ( self.script_noteworthy == "intro_agent" )
	{
		level.intro_agent = self;
		self.animname	  = "agent";
		self gun_remove();
		
		//no binoc profile
	}
	if ( self.script_noteworthy == "intro_enemy2" )
	{
		level.intro_enemy2 = self;
		self.animname	   = "enemy2";
		
		self.script_startingposition = 3;
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 2 ];
	}
	if ( self.script_noteworthy == "intro_enemy3" )
	{
		level.intro_enemy3 = self;
		self.animname	   = "enemy3";
		self.binocular_double_agent = true;
		
		self.script_startingposition = 4;
		
		self.binocular_facial_profile = "cnd_binocs_hud_photo_012";
	}
	if ( self.script_noteworthy == "intro_enemy5" )
	{
		level.intro_enemy5 = self;
		self.animname	   = "enemy5";
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 5 ];
	}
	if ( self.script_noteworthy == "intro_enemy7" )
	{
		level.intro_enemy7 = self;
		self.animname	   = "enemy7";
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 6 ];
	}
	if ( self.script_noteworthy == "intro_enemy8" )
	{
		level.intro_enemy8 = self;
		self.animname	   = "enemy8";
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 7 ];
	}
	if ( self.script_noteworthy == "intro_enemy9" )
	{
		level.intro_enemy9 = self;
		self.animname	   = "enemy9";
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 8 ];
	}
	if ( self.script_noteworthy == "intro_enemy10" )
	{
		level.intro_enemy10 = self;
		self.animname		= "enemy10";
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 9 ];
	}
	
	if ( self.script_noteworthy == "intro_enemy11" )
	{
		level.intro_enemy11 = self;
		self.animname		= "enemy11";
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 10 ];
	}
	if ( self.script_noteworthy == "intro_enemy12" )
	{
		level.intro_enemy12 = self;
		self.animname		= "enemy12";
		
		self.script_startingposition = 5;
		
		self.binocular_facial_profile = level.player.binocular_profile_materials[ 3 ];
	}
}

debug_death()
{
	self waittill( "damage", damage, attacker, direction_vec, point, type );
}

intro_enemy_scene()
{
	level.intro_roof_node = getstruct( "intro_hvt_roof_animnode", "targetname" );
	thread intro_roof_door2();
	
	enemies0 = array_spawn_function_targetname( "intro_roof_guys_0", ::intro_enemy_setup ); //enemy 7 & 8, just loop
	enemies1 = array_spawn_function_targetname( "intro_roof_guys_1", ::intro_enemy_setup ); //enemy 5, agent, cmdr, start looping, play scene
	enemies2 = array_spawn_function_targetname( "intro_roof_guys_2", ::intro_enemy_setup ); //enemy hvt, 2, 3, 12, start in chopper, play scene
	enemies3 = array_spawn_function_targetname( "intro_roof_guys_3", ::intro_enemy_setup );//enemy 9 & 10, move through scene mid
	enemies3 = array_spawn_function_targetname( "intro_roof_guys_4", ::intro_enemy_setup );//enemy 11, move through scene late

	enemies0 = array_spawn_targetname( "intro_roof_guys_0", true );
	enemies1 = array_spawn_targetname( "intro_roof_guys_1", true );
	
	//guys on roof all looping.
	guys	  = [];
	guys[ 0 ] = level.intro_agent;
	guys[ 1 ] = level.intro_cmdr;
	guys[ 2 ] = level.intro_enemy5;
	
	//guys on roof looping forever.
	loop_guys	   = [];
	loop_guys[ 0 ] = level.intro_enemy7;
	loop_guys[ 1 ] = level.intro_enemy8;
	
										//   guys 	    anime 					      ender 			    
	level.intro_roof_node thread anim_loop( guys	 , "cornered_roof_arrival_wait", "stop_loop" );
	level.intro_roof_node thread anim_loop( loop_guys, "cornered_roof_arrival_wait", "stop_loop_guys_loop" );
	
	if ( GetDvar( "raven_demo" ) == "0" )
		flag_wait_all( "intro_heli_landed", "looking_at_roof" );
	else
		flag_wait( "intro_heli_landed" );
	level.intro_roof_node notify( "stop_loop" );
	
	//guys in helicopter
	enemies2	= array_spawn_targetname( "intro_roof_guys_2", true );
	
	guys[ 3 ] = level.intro_hvt;
	guys[ 4 ] = level.intro_enemy2;
	guys[ 5 ] = level.intro_enemy3;
	guys[ 6 ] = level.intro_enemy12;
	
	level.intro_roof_node thread anim_single( guys, "cornered_roof_arrival" );

	level.intro_hvt waittillmatch( "single anim", "nh90_takeoff" );
	flag_set( "hvt_chopper_leave" );
	
	level.intro_hvt waittillmatch( "single anim", "start_enemy9_and_10" );
	
	//guys come from right, move to back
	enemies	= array_spawn_targetname( "intro_roof_guys_3", true );
	
	waitframe();
	
	guys2	   = [];
	guys2[ 0 ] = level.intro_enemy9;
	guys2[ 1 ] = level.intro_enemy10;
	
	level.intro_roof_node thread anim_single( guys2, "cornered_roof_arrival_mid" );
	
	level.intro_enemy2 waittillmatch( "single anim", "end" );
											 //   guy 	     anime 					   ender 	   
	level.intro_roof_node thread anim_loop_solo( guys[ 2 ], "cornered_roof_end_loop", "stop_loop" );
	level.intro_roof_node thread anim_loop_solo( guys[ 4 ], "cornered_roof_end_loop", "stop_loop" );
	level.intro_roof_node thread anim_loop_solo( guys[ 5 ], "cornered_roof_end_loop", "stop_loop" );
	
	level.intro_hvt waittillmatch( "single anim", "start_enemy11" );
	
	//guy comes from right, speaks to HVT, exits right back
	enemies	= array_spawn_targetname( "intro_roof_guys_4", true );
	
	waitframe();
	
	guys3	   = [];
	guys3[ 0 ] = level.intro_enemy11;
	
	level.intro_roof_node thread anim_single( guys3, "cornered_roof_arrival_late" );
	
	level.intro_hvt waittillmatch( "single anim", "end" );
	
	if ( !flag( "hvt_confirmed" ) )
	{
		level notify( "scanning_failed" );
	}
			
	waitframe();
	level.briefcase Delete();
	guys = array_remove( guys, level.intro_enemy5 );//enemy5
	guys = array_remove( guys, level.intro_enemy2 );//enemy2
	guys = array_remove( guys, level.intro_enemy3 );//enemy3
	wait( 0.05 );
	array_delete( guys );
	
	level.intro_enemy11 waittillmatch( "single anim", "end" );
	array_delete( guys3 );
	
	flag_wait( "zipline_finished" );
	level.intro_roof_node notify( "stop_loop" );
	waittillframeend;
	array_delete( guys2 );
	array_delete( loop_guys );
	level.intro_enemy2 Delete();
	level.intro_enemy3 Delete();
	level.intro_enemy5 Delete();
}

//exit_roof()
//{
//	node = GetNode( self.script_noteworthy + "_exit", "targetname" );
//	
//	self thread follow_path( node );
//	self waittill( "reached_path_end" );
//	
//	if ( self.script_noteworthy == "intro_hvt" && !flag( "hvt_confirmed" ) )
//	{
//		level notify( "scanning_failed" );
//	}
//		
//	waitframe();
//	if ( self.script_noteworthy == "intro_hvt" && !flag( "hvt_confirmed" ) )
//	{
//		level.briefcase Delete();
//	}
//	self Delete();
//}
//
//intro_generic_enemies()
//{
//	self waittill( "reached_path_end" );
//	
//	struct = getstruct( self.script_noteworthy + "_anim", "targetname" );
//	struct anim_generic_reach( self, struct.animation );
//	struct anim_generic( self, struct.animation );
//	
//	node = GetNode( struct.target, "targetname" );
//	self thread follow_path( node );
//	self waittill( "reached_path_end" );
//	
//	waitframe();
//	self Delete();
//}

intro_binocular_scene()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	thread intro_target_monitor();
	
	level.player waittill( "hvt_confirmed" );
	flag_set( "obj_confirm_id_complete" ); //objective 1 complete
	
	//Price: Target confirmed. Mission is a go.
	smart_radio_dialogue( "cornered_orc_missionisago" );

	level notify( "intro_succeed" );
}

intro_binocular_monitor()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	intro_check_binocular_activate();
	//thread intro_binocs_blend_to_target();
	
	level.player waittill( "hvt_confirmed" );
	intro_check_binocular_deactivate();
}

intro_binocs_check_look_target()
{
	level endon( "binoculars_deactivated" );
	
	intro_roof_node = getstruct( "intro_hvt_roof_animnode", "targetname" );
	level.binoc_target	= getstruct( "intro_binoc_target", "targetname" );
	
	while ( !IsDefined( self.current_binocular_zoom_level ) )
	{
		wait( 0.05 );
	}
	
	thread intro_check_binocular_zoom();
	
	//wait while not zoomed in and looking in the right place.
	while ( !( level.player WorldPointInReticle_Circle( level.binoc_target.origin, 65, 100 ) ) || self.current_binocular_zoom_level == 0 )
	{
		waitframe();
	}
	
	flag_set( "looking_at_roof" );
	
	intro_check_binocular_scan();
	thread intro_check_binocular_range();
	
	level.binoc_target = undefined;
}

intro_binocs_check_look_target_for_render()
{
	level endon( "binoculars_deactivated" );
	
	intro_roof_node = getstruct( "intro_hvt_roof_animnode", "targetname" );
	binoc_target	= getstruct( "intro_binoc_target", "targetname" );
	
	while ( !IsDefined( self.current_binocular_zoom_level ) )
	{
		wait( 0.05 );
	}
	
	while ( 1 )		
	{		
		if ( level.player WorldPointInReticle_Circle( binoc_target.origin, 2, 3500 ) && self.current_binocular_zoom_level != 0 )
		{
			level.player PlayerSetStreamOrigin( intro_roof_node.origin + ( 0, 256, 64 ) );
			SetSavedDvar( "sm_sunShadowCenter", intro_roof_node.origin );	
			//exploder( 666 ); //turn on lens flares on helicopter roof - not working
		}
		else
		{
			level.player PlayerClearStreamOrigin();
			SetSavedDvar( "sm_sunShadowCenter", ( 0, 0, 0 ) );
			//stop_exploder( 666 ); //turn off lens flares on helicopter roof - not working
		}
		
		wait( 0.05 );
	}
}

//intro_binocs_blend_to_target()
//{
//	linker		 = level.player spawn_tag_origin();
//	binoc_target = getstruct( "intro_binoc_target", "targetname" );
//	
//	// getting vector between tag origin and desired target
//	angle_to_roof = VectorToAngles( binoc_target.origin - linker.origin );
//	
//	// setting tag origin angle to desired angle
//	linker.angles = angle_to_roof;
//	
//	// where is player looking
//	player_angles = level.player GetGunAngles();
//	
//	// determining how far off player's view is from desired angle to adjust blend time
//	view_diff = abs( angle_to_roof[ 1 ] - player_angles[ 1 ] );
//	//IPrintLnBold( view_diff + " is yaw difference between player view and desired view." );
//	
//	if ( view_diff <= 10 )
//	{
//		blend_time = 1;
//	}
//	else
//	{
//		blend_time = 1;
//		for ( i	   = 0; i < view_diff; i++ )
//		{
//			blend_time += 0.0115;		
//		}
//	}
//		
//	waittillframeend;
//	old_origin = level.player.origin;	
//	level.player PlayerLinkToBlend( linker, "tag_origin", blend_time );
//	wait( blend_time + 0.25 );
//	
//	waittillframeend;
//	level.player Unlink();
//	level.player SetOrigin( old_origin );
//	
//	waittillframeend;
//	linker Delete();
//}
	
intro_check_binocular_activate()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	if ( !level.player.binoculars_active )
	{
		thread intro_binoculars_use_hint( 0.25, "binoc_use", "give_binocular_hint_if_needed", "binoculars_used" );
		level.player waittill( "use_binoculars" );
	}
	level notify( "binoculars_used" );
	flag_set( "player_using_binoculars" );
}

intro_check_binocular_zoom()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	thread intro_binoculars_hint( 0, "binoc_zoom", undefined, "binoculars_zoomed" );
	
	level.player waittill( "binocular_zoom" );
	level notify( "binoculars_zoomed" );
}

binoculars_hide_hint()
{
	if ( !level.player.binoculars_active )
		return true;
	
	if ( !( level.player WorldPointInReticle_Circle( level.binoc_target.origin, 65, 120 ) ) )
		return true;
		
	if ( level.player.current_binocular_zoom_level > 0 )
		return true;

	return false;
}

intro_check_binocular_scan()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	thread intro_binoculars_hint( 2, "binoc_scan", undefined, "binoculars_scanned" );
	level.player waittill( "scanning_target" );
	level notify( "binoculars_scanned" );
}

scan_hide_hint()
{
	if ( !level.player.binoculars_active )
		return true;
		
	if ( level.player.current_binocular_zoom_level == 0 )
		return true;
	
	if ( !( level.player WorldPointInReticle_Circle( level.binoc_target.origin, 65, 100 ) ) )
		return true;
		
	if ( IsDefined( level.player.binoculars_scan_target ) )
		return true;

	return false;
}

intro_check_binocular_range()
{
	level endon( "intro_fail" );
	level endon( "intro_succeed" );
	level endon( "player_falling" );
	
	//valid zooms are 0-3.  
	
	while ( 1 )
	{
		while ( level.player.binoculars_active == false )
		{
			waitframe();
		}
		level.player waittill( "scanning_complete" );
		
		// if you're scan a target but are not in range
		if ( level.player.current_binocular_zoom_level != level.player.binocular_zoom_levels - 1 )
		{
			level.player thread display_hint( "binoc_range" );
			wait( 4 );
		}
		wait( 0.05 );
	}
}

waittill_binocular_deactivate_hint()
{
	level.player endon( "stop_using_binoculars" );
	
	waittill_notify_or_timeout( "double_agent_confirmed", 10 );
}

intro_check_binocular_deactivate()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	if ( level.player.binoculars_active )
		thread intro_binoculars_use_hint( 2, "binoc_deactivate", undefined, "binoculars_deactivated" );
	
	if ( !flag( "double_agent_confirmed" ) )
		waittill_binocular_deactivate_hint();
	level notify( "binoculars_deactivated" );
	
	wait_for_binoculars = true;
		
	if ( !flag( "double_agent_confirmed" ) && !flag( "player_is_starting_zipline" ) )
	{
		msg = flag_wait_either_return( "double_agent_confirmed", "player_is_starting_zipline" );
		if ( msg == "player_is_starting_zipline" )
			wait_for_binoculars = false;
	}
	
	if ( wait_for_binoculars )
		level.player waittill( "stop_using_binoculars" );
	
	level.player PlayerClearStreamOrigin();
	SetSavedDvar( "sm_sunShadowCenter", ( 0, 0, 0 ) );
	
	level.player take_binoculars();
	waitframe();
	if ( !flag( "zipline_launcher_setup" ) )
	{
		//level.player SwitchToWeapon( "m14ebr_acog_silenced_cornered" );
		level.player SwitchToWeapon( "imbel+acog_sp+silencer_sp" );
	}
}

intro_binoculars_use_hint( waittime, hintstring, flagname, endon_string )
{
	level endon( endon_string );
	
	//this is so you can start the hint function when binoculars are given, not show the hint till needed, but kill the function if the player uses them before the hint.
	if ( IsDefined( flagname ) )
	{
		flag_wait( flagname );
	}
	
	wait( waittime );
	
	while ( 1 )
	{
		level.player thread display_hint( hintstring );

		wait( 7.0 );
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
	
	waittill_binoculars_active();
		
	while ( 1 )
	{
		level.player ent_flag_waitopen( "global_hint_in_use" );
		
		waittill_binoculars_active();
		waitframe();
		
		level.player thread display_hint( hintstring );
	}
}

waittill_binoculars_active()
{
	while ( !level.player.binoculars_active )
	{
		waitframe();
	}
}

//intro_roof_door1()
//{
//	door1 = GetEnt( "roof_door1", "targetname" );
//	
//	//flag_wait( "open_roofdoor1" );
//	door1 RotateYaw( -85, .75, .25, .25 );
//	wait( 0.5 );
//	door1 ConnectPaths();
//}

intro_roof_door2()
{
	door2_l = GetEnt( "roof_door2_l", "targetname" );
	door2_r = GetEnt( "roof_door2_r", "targetname" );
	
	//flag_wait( "open_roofdoor2" );
	//wait( 2.0 );
	door2_l RotateYaw( 95, .05 );
	door2_r RotateYaw( -95, .05 );
	wait( 0.35 );
	door2_l ConnectPaths();
	door2_r ConnectPaths();
}

intro_target_monitor()
{
	level.player endon( "hvt_confirmed" );
	level endon( "player_falling" );
	
	level waittill( "scanning_failed" );
	//"HVT was not identified."
	SetDvar( "ui_deadquote", &"CORNERED_BINOCULARS_FAIL" );
	missionFailedWrapper();
}

intro_building_check()
{
	level endon( "player_falling" );
	level endon( "player_is_starting_zipline" );
	
	volume = GetEnt( "off_building_vol", "targetname" );
	
	while ( 1 )
	{
		if ( !level.player IsTouching( volume ) )
		{
			flag_clear( "off_start_building" );
		}
		wait( 0.05 );
	}
}

intro_save_check( autosave_name, flag )
{
	level endon( "stop_save_attempt" );
	
	flag_wait( flag );
	
	//will attempt to save for 1 second.
	
	for ( i = 0; i < 10; i++ )
	{
		if ( !flag( "off_start_building" ) )
		{
			thread autosave_by_name( autosave_name );
			level notify( "stop_save_attempt" );
		}
		
		wait( 0.1 );
	}	
}

intro_allies_vo()
{
	level endon( "player_falling" );
	
	thread intro_building_check();
	thread intro_save_check( "intro_scanning_seq", "intro_id_scan" );
	
	flag_wait( "intro_vo_begin" );
	//Merrick: He's right on time.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_rke_heretheycomestay" );
	
	flag_wait( "vip_heli_approach" );
	wait( 0.5 );
	
	if ( GetDvar( "raven_demo" ) == "0" )
	{
		thread maps\cornered::obj_confirm_id();
		flag_set( "give_player_binoculars" );
		flag_set( "give_binocular_hint_if_needed" );
	}
	
	//Merrick: There’s our target.
	level.allies[ level.const_baker ] smart_dialogue( "cornered_bkr_ourtarget" );
	
	if ( GetDvar( "raven_demo" ) == "1" )
		return;
	
	flag_set( "intro_id_scan" ); //attempting a save here.
	
	wait( 0.75 );
	//Merrick: Confirm visual ID.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_rke_confirmvisual" );
//	thread maps\cornered::obj_confirm_id();
//	flag_set( "give_player_binoculars" );
//	flag_set( "give_binocular_hint_if_needed" );
	
	wait( 0.35 );
	//Merrick: Oracle, this is Black Knight Actual. Prepare to receive optical feed.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_rke_preparetoreceive" );
	
	//Price: Copy, Black Knight.
	smart_radio_dialogue( "cornered_orc_copyblackknight" );
		
	while ( level.player.binoculars_active == false )
	{
		waitframe();
	}
	wait( 0.5 );
	//Price: Receiving transmission. Cleaning up the signal.
	smart_radio_dialogue( "cornered_orc_receivingtransmissionup" );
	thread intro_binocs_inactive_nag_vo();
}

intro_binocs_inactive_nag_vo()
{
	level endon( "intro_succeed" );
	level endon( "intro_fail" );
	level.player endon( "hvt_confirmed" );
	level endon( "kill_binoc_nags" );
	level endon( "player_falling" );

	//Price: We’ve lost the feed.
	//Price: Signal isn't active.
	nag_lines_array = make_array( "cornered_orc_wevelostthefeed", "cornered_orc_signalisnotactive" );
	last_line		= -1;
	
	while ( 1 )
	{
		vo_index = RandomInt( nag_lines_array.size );
		if ( vo_index == last_line )
		{
			vo_index++;
			if ( vo_index >= nag_lines_array.size )
				vo_index = 0;
		}
		random_vo = nag_lines_array[ vo_index ];
		
		if ( level.player.binoculars_active == false )
		{
			smart_radio_dialogue_interrupt( random_vo );
			wait( 3.0 );
		}
		last_line = vo_index;
		waitframe();
	}
}

intro_binocs_not_target_vo()
{
	level endon( "intro_fail" );
	level endon( "player_falling" );
	
	//Price: Negative. That's not the target.
	//Price: Negative ID.
	//Price: Incorrect target.
	nag_lines_array = make_array( "cornered_orc_negativethatisnot", "cornered_orc_negativeid", "cornered_orc_incorrecttarget" );
	last_line		= -1;
	double_agent_line = false;
	
	while ( 1 )
	{
		while ( !IsDefined( level.player.current_binocular_zoom_level ) && !IsDefined ( level.player.binocular_zoom_levels ) )
		{
			wait( 0.05 ); //this is to give binocular script time to set up variables
		}
		if ( level.player.current_binocular_zoom_level == level.player.binocular_zoom_levels - 1 )
		{
			level.player waittill( "scanning_complete" );
			vo_index = RandomInt( nag_lines_array.size );
			if ( vo_index == last_line )
			{
				vo_index++;
				if ( vo_index >= nag_lines_array.size )
					vo_index = 0;
			}
			random_vo = nag_lines_array[ vo_index ];
			
			wait( 0.55 ); // put this in because "binoculars_monitor_scanning" waits .5 after "scanning_complete" to set this flag.
			
			if ( flag( "double_agent_confirmed" ) && !double_agent_line )
			{
				double_agent_line = true;
				smart_radio_dialogue( "cornered_eli_gotitsecondary" );
				if ( !flag( "hvt_confirmed" ) )
					thread smart_radio_dialogue( "cornered_eli_keepscanningfor" );
			}
			else if ( !flag( "hvt_confirmed" ) )
			{
				smart_radio_dialogue_interrupt( random_vo );
			}
			last_line = vo_index;
		}
		
		if ( flag( "hvt_confirmed" ) && flag( "double_agent_confirmed" ) )
			break;
		
		waitframe();
	}
}

intro_binocs_oracle_scanning_vo()
{
	level endon( "intro_succeed" );
	level endon( "intro_fail" );
	level.player endon( "hvt_confirmed" );
	level endon( "kill_binoc_nags" );
	level endon( "player_falling" );
		
	//Price: Receiving data.
	//Price: Receiving uplink.
	//Price: Uploading image.
	nag_lines_array = make_array( "cornered_orc_receivingdata", "cornered_orc_receivinguplink", "cornered_orc_uploadingimage" );
	last_line		= -1;
	
	//Price: No good. Need a better angle. 
	//Price: Negative ID. Wait until he's facing you.
	wrong_angle_array = make_array( "cornered_pri_nogoodneeda", "cornered_pri_negativeidwaituntil" );
	last_angle_line	  = -1;
	
	while ( 1 )
	{
		while ( !IsDefined( level.player.current_binocular_zoom_level ) && !IsDefined ( level.player.binocular_zoom_levels ) )
		{
			wait( 0.05 ); //this is to give binocular script time to set up variables
		}
		
		if ( !level.player AttackButtonPressed() )
		{
			level.player waittill( "scanning_target" );
		}

		if ( level.player.current_binocular_zoom_level == level.player.binocular_zoom_levels - 1 )
		{
			wait( 0.05 );
			
			// --checking to see if player is trying to scan but can't because enemy isn't facing correctly.
			if ( level.player AttackButtonPressed() && flag( "scan_target_not_facing" ) )
			{
				angle_vo_index = RandomInt( wrong_angle_array.size );
				
				if ( angle_vo_index == last_angle_line )
				{
					angle_vo_index++;
					if ( angle_vo_index >= wrong_angle_array.size )
					angle_vo_index = 0;
				}
				
				random_angle_vo = wrong_angle_array[ angle_vo_index ];
				
				smart_radio_dialogue_interrupt( random_angle_vo ); // could thread this if we want it more spammy
				
				last_angle_line	= angle_vo_index;				
			}
			
			// --player is sucessfully scanning a target.  Sending random upload VO.
			else
			{
				vo_index = RandomInt( nag_lines_array.size );
				
				if ( vo_index == last_line )
				{
					vo_index++;
					if ( vo_index >= nag_lines_array.size )
						vo_index = 0;
				}
				
				random_vo = nag_lines_array[ vo_index ];
				
				smart_radio_dialogue_interrupt( random_vo ); // could thread this if we want it more spammy
				
				last_line	= vo_index;
			}
		
			while ( level.player AttackButtonPressed() )
			{
				wait( 0.05 ); //waiting for player to stop current scan.
			}
		}
		
		waitframe();
	}
}

zipline_setup()
{	
	level.zipline_anim_struct = getstruct( "zipline_anim_struct", "targetname" );

	//LAUNCHERS
	//Player's zipline launcher
	level.zipline_launcher_player		= GetEnt( "zipline_launcher_player", "targetname" );
	level.zipline_launcher_player SetDefaultDropPitch( -10 );
	level.zipline_launcher_player MakeTurretInoperable();
	level.zipline_launcher_player MakeUnusable();
	level.zipline_launcher_player Hide();
	
	level.fake_turret = Spawn( "script_model", level.zipline_launcher_player.origin );
	level.fake_turret SetModel( level.zipline_launcher_player.model );
	level.fake_turret.angles	 = level.zipline_launcher_player.angles;
	level.fake_turret.animname	 = "zipline_launcher";
	level.fake_turret.targetname = "zipline_launcher_player";
	level.fake_turret SetAnimTree();
	level.zipline_anim_struct thread anim_first_frame_solo( level.fake_turret, "zipline_launcher_setup_player" );
	
	//level.player thread player_handle_zipline_turret( level.zipline_launcher_player );
	
	//Rorke's zipline launcher
	level.zipline_launcher_rorke		  = GetEnt( "zipline_launcher_rorke", "targetname" );
	level.zipline_launcher_rorke.animname = "zipline_launcher";
	level.zipline_launcher_rorke SetAnimTree();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_launcher_rorke, "zipline_launcher_setup_rorke" );
	
	//Baker's zipline launcher
	level.zipline_launcher_baker		  = GetEnt( "zipline_launcher_baker", "targetname" );
	level.zipline_launcher_baker.animname = "zipline_launcher";
	level.zipline_launcher_baker SetAnimTree();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_launcher_baker, "zipline_launcher_setup_baker" );
	
	//ROPES
	//Player's zipline rope
	level.zipline_rope			= spawn_anim_model( "cnd_zipline_rope" );
	level.zipline_rope Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_rope, "cornered_zipline_playerline_launched" );
	
	//Player's zipline detach rope
	level.detach_rope_player			= spawn_anim_model( "cnd_zipline_rope" );
	level.detach_rope_player Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.detach_rope_player, "cornered_zipline_player" );	
	
	//Rorke's zipline rope
	level.zipline_rope_rorke			= spawn_anim_model( "cnd_zipline_rope" );
	level.zipline_rope_rorke Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_rope_rorke, "cornered_zipline_rorkeline_launched" );
	
	//Rorke's zipline detach rope
	level.detach_rope_rorke			= spawn_anim_model( "cnd_rappel_tele_rope_noclip" );
	level.detach_rope_rorke Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.detach_rope_rorke, "zipline_rorke" );
	
	//Baker's zipline rope
	level.zipline_rope_baker			= spawn_anim_model( "cnd_zipline_rope" );
	level.zipline_rope_baker Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_rope_baker, "cornered_zipline_bakerline_launched" );
	
	//Baker's zipline detach rope
	level.detach_rope_baker			= spawn_anim_model( "cnd_rappel_tele_rope_noclip" );
	level.detach_rope_baker Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.detach_rope_baker, "zipline_baker" );
	
	//TROLLEYS
	//Player's zipline trolley
	level.zipline_trolley_player			= spawn_anim_model( "cnd_rappel_device" );
	level.zipline_trolley_player Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_trolley_player, "cornered_zipline_trolley_player" );
	
	//Rorke's zipline trolley
	level.zipline_trolley_rorke			= spawn_anim_model( "cnd_rappel_device" );
	level.zipline_trolley_rorke Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_trolley_rorke, "zipline_trolley_fire_rorke" );
	
	//Baker's zipline trolley
	level.zipline_trolley_baker			= spawn_anim_model( "cnd_rappel_device" );
	level.zipline_trolley_baker Hide();
	level.zipline_anim_struct thread anim_first_frame_solo( level.zipline_trolley_baker, "zipline_trolley_fire_baker" );
}

zipline()
{
	thread zipline_objective();
	level.player thread player_handle_zipline_turret( level.zipline_launcher_player );
	thread zipline_allies_vo();
	thread zipline_allies_anims();
	thread zipline_player_anims();
	thread zipline_equipment_anims();
}

zipline_objective()
{
	if ( !( IsDefined( level.zipline_startpoint ) ) )
	{
		if ( GetDvar( "raven_demo" ) == "0" )
			level.player waittill( "stop_using_binoculars" );
	}
	thread maps\cornered::obj_fire_zipline();
}

zipline_nag( nag_lines_array, ender_flag, min_wait, max_wait, increment )
{
	if ( flag( ender_flag )	 ) // don't play lines if flag already set
	{
		return;
	}
	
	last_line = -1;
		
	while ( !flag( ender_flag ) )
	{	
		wait_time = RandomFloatRange( min_wait, max_wait );
		wait ( wait_time );
		vo_index = RandomInt( nag_lines_array.size );
		if ( vo_index == last_line )
		{
			vo_index++;
			if ( vo_index >= nag_lines_array.size )
				vo_index = 0;
		}
		random_vo = nag_lines_array[ vo_index ];

		if ( flag( ender_flag ) )
		{
			break;
		}
		
		if ( IsDefined( level.player.binoculars_active ) && level.player.binoculars_active )
			continue;
		
		thread smart_radio_dialogue( random_vo );
		
		last_line = vo_index;
		min_wait  = min_wait + increment;
		max_wait  = max_wait + increment;
	}
}

zipline_allies_vo()
{
	if ( !( IsDefined( level.zipline_startpoint ) ) )
	{
		if ( GetDvar( "raven_demo" ) == "0" )
		{
			wait( 1.5 );
			if ( IsDefined( level.player.binoculars_active ) && level.player.binoculars_active )
			{
				level.player waittill( "stop_using_binoculars" );
			}
			wait( 0.5 );
		}
		
		flag_wait( "rorke_ready_to_setup_zipline" );
	}	
	
	if ( !flag( "zipline_launcher_setup" ) )
	{
		//Merrick: Setup your launchers.
		level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_setupyourlaunchers" );
		//Merrick: Setup your launchers.
		//Merrick: Adam, get your zipline set up.
		nag_lines	= make_array( "cornered_mrk_setupyourlaunchers", "cornered_mrk_adamgetyourzipline" );
		thread zipline_nag( nag_lines, "zipline_launcher_setup", 10, 15, 5 );	
	}
	
	flag_wait( "player_on_turret" );
	wait( 0.5 );
	//Merrick: Fire the line, Adam.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_firethelineadam" );
	
	flag_wait( "player_fired_zipline" );
	wait( 5 );

	//Merrick: Hook up.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_rke_everyonehook" );
	wait( 3.0 );
	
	//Merrick: Line's set. We're clear to hook on.
	//Merrick: Let's go. Hook up.
	nag_lines	= make_array( "cornered_mrk_linessetwereclear", "cornered_mrk_letsgohookup" );
	thread zipline_nag( nag_lines, "player_is_starting_zipline", 10, 15, 5 );	
}

zipline_allies_anims()
{
	level.zipline_launcher_baker_count		   = 0;
	level.allies[ level.const_baker ].animname = "baker";
	level.allies[ level.const_baker ] thread zipline_baker_anims();
	level.zipline_launcher_rorke_count		   = 0;
	level.allies[ level.const_rorke ].animname = "rorke";
	level.allies[ level.const_rorke ] thread zipline_rorke_anims();
}

zipline_rorke_anims()
{
	if ( !( IsDefined( level.zipline_startpoint ) ) )
	{
		if ( IsDefined( level.player.binoculars_active ) && level.player.binoculars_active )
		{
			level.player waittill( "stop_using_binoculars" );
		}
		
		flag_wait( "rorke_ready_to_setup_zipline" );
		waittillframeend;
		
		level.intro_struct notify( "stop_rorke_intro_loop" );
	}
		
	ally_zipline_array		= [];
	ally_zipline_array[ 0 ] = self;
	ally_zipline_array[ 1 ] = level.zipline_launcher_rorke;
	
	self zipline_launcher_setup_anims( "zipline_launcher_setup_rorke" );
	if ( flag( "player_on_turret" ) )
	{
		self StopAnimScripted();
		level.zipline_launcher_rorke_count++;
		
		while ( level.zipline_launcher_rorke_count < 2 )
		{
			wait( 0.05 );
		}
		level.zipline_launcher_rorke_count = 0;
	}

	self zipline_launcher_aim_anims( ally_zipline_array );

	flag_wait( "player_fired_zipline" );
	level.zipline_anim_struct notify( "stop_launcher_loop_rorke" );
	
	self zipline_launcher_fire_anims( ally_zipline_array );
	if ( flag( "player_is_starting_zipline" ) )
	{
		foreach ( item in ally_zipline_array )
		{
			item StopAnimScripted();
		}
		
		if ( IsDefined( level.zipline_trolley_rorke.is_out ) )
		{
			level.zipline_launcher_rorke_count++;
			
			while ( level.zipline_launcher_rorke_count < 2 )
			{
				wait( 0.05 );
			}
		}
		else
		{
			level.zipline_trolley_rorke Show();
		}
	}

	ally_zipline_array[ 1 ] = level.zipline_trolley_rorke;
	ally_zipline_array[ 2 ] = level.zipline_rope_rorke;
	ally_zipline_array[ 3 ] = level.detach_rope_rorke;
	
	self zipline_wait_anims( ally_zipline_array );
	
	flag_wait( "player_is_starting_zipline" );
	level.zipline_anim_struct notify( "stop_zipline_wait_loop_rorke" );
	level.zipline_anim_struct notify( "stop_cornered_zipline_rorkeline_at_rest_loop" );
	
	self.zipline = true;
	
	self zipline_anims( ally_zipline_array );
	
	self.zipline = false;
}

zipline_rope_swap_ally( ally )
{
	if ( ally.animname == "rorke" )
	{
		level.detach_rope_rorke Delete();
	}
	else
	{
		level.detach_rope_baker Delete();
	}
	
	ally ally_rappel_start_rope( "stealth" );
}

setup_launcher_rorke( rorke )
{
	thread maps\cornered_audio::aud_zipline( "unfold3", ( -29040, -4710, 27232 ) );
	
	level.zipline_launcher_rorke zipline_launcher_setup_anims( "zipline_launcher_setup_rorke" );
	
	if ( flag( "player_on_turret" ) )
	{
		level.zipline_launcher_rorke StopAnimScripted();
		level.zipline_launcher_rorke_count++;
	}
}

zipline_baker_anims()
{
	if ( !( IsDefined( level.zipline_startpoint ) ) )
	{
		if ( IsDefined( level.player.binoculars_active ) && level.player.binoculars_active )
		{
			if ( GetDvar( "raven_demo" ) == "0" )
				level.player waittill( "stop_using_binoculars" );
		}
		
		flag_wait( "baker_ready_to_setup_zipline" );
		waittillframeend;
		
		level.intro_struct notify( "stop_baker_intro_loop" );
	}

	ally_zipline_array		= [];
	ally_zipline_array[ 0 ] = self;
	ally_zipline_array[ 1 ] = level.zipline_launcher_baker;
	
	thread setup_launcher_baker();
	
	self zipline_launcher_setup_anims( "zipline_launcher_setup_baker" );
	if ( flag( "player_on_turret" ) )
	{
		self StopAnimScripted();
		level.zipline_launcher_baker_count++;
		
		while ( level.zipline_launcher_baker_count < 2 )
		{
			wait( 0.05 );
		}
		level.zipline_launcher_baker_count = 0;
	}

	self zipline_launcher_aim_anims( ally_zipline_array );
	
	flag_wait( "player_fired_zipline" );
	level.zipline_anim_struct notify( "stop_launcher_loop_baker" );
	
	self zipline_launcher_fire_anims( ally_zipline_array );
	if ( flag( "player_is_starting_zipline" ) )
	{
		foreach ( item in ally_zipline_array )
		{
			item StopAnimScripted();
		}
		if ( IsDefined( level.zipline_trolley_baker.is_out ) )
		{
			level.zipline_launcher_baker_count++;
			
			while ( level.zipline_launcher_baker_count < 2 )
			{
				wait( 0.05 );
			}
		}
		else
		{
			level.zipline_trolley_baker Show();
		}
	}

	ally_zipline_array[ 1 ] = level.zipline_trolley_baker;
	ally_zipline_array[ 2 ] = level.zipline_rope_baker;
	ally_zipline_array[ 3 ] = level.detach_rope_baker;
	
	self zipline_wait_anims( ally_zipline_array );
	
	flag_wait( "player_is_starting_zipline" );
	level.zipline_anim_struct notify( "stop_zipline_wait_loop_baker" );
	level.zipline_anim_struct notify( "stop_cornered_zipline_bakerline_at_rest_loop" );
	
	self.zipline = true;
	
	self zipline_anims( ally_zipline_array );
	
	self.zipline = false;
}

setup_launcher_baker()
{
	thread maps\cornered_audio::aud_zipline( "unfold2", ( -29203, -4622, 27232 ) );
	
	level.zipline_launcher_baker zipline_launcher_setup_anims( "zipline_launcher_setup_baker" );
	
	if ( flag( "player_on_turret" ) )
	{
		level.zipline_launcher_baker StopAnimScripted();
		level.zipline_launcher_baker_count++;
	}
}

front_left_anchor_impact( launcher )
{
	//PlayFXOnTag(level._effect["zipline_launcher_foot_impact"],launcher,"");
	if ( launcher.targetname == "zipline_launcher_rorke" )
	{
		activate_exploder( "launcher_foot_R1" );
		//activate_exploder("launcher_foot_R2");
		//activate_exploder("launcher_foot_R3");
		//activate_exploder("launcher_foot_R4");
		//IPrintLnBold( "rorke anchor_line_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_baker" )
	{
		activate_exploder( "launcher_foot_L1" );
		//activate_exploder("launcher_foot_L2");
		//activate_exploder("launcher_foot_L3");
		//activate_exploder("launcher_foot_L4");
		//IPrintLnBold( "baker anchor_line_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_player" )
	{
		activate_exploder( "launcher_foot_C1" );
		//activate_exploder("launcher_foot_C2");
		//activate_exploder("launcher_foot_C3");
		//activate_exploder("launcher_foot_C4");
		//IPrintLnBold( "player anchor_line_impact" );
	}
}

front_right_anchor_impact( launcher )
{
	if ( launcher.targetname == "zipline_launcher_rorke" )
	{
		activate_exploder( "launcher_foot_R2" );
		//IPrintLnBold( "rorke front_right_anchor_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_baker" )
	{
		activate_exploder( "launcher_foot_L2" );
		//IPrintLnBold( "baker front_right_anchor_impact" );
	}
	else if ( self.targetname == "zipline_launcher_player" )
	{
		activate_exploder( "launcher_foot_C2" );
		//IPrintLnBold( "player front_right_anchor_impact" );
	}
}

rear_left_anchor_impact( launcher )
{
	if ( launcher.targetname == "zipline_launcher_rorke" )
	{
		activate_exploder( "launcher_foot_R3" );
		//IPrintLnBold( "rorke rear_left_anchor_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_baker" )
	{
		activate_exploder( "launcher_foot_L3" );
		//IPrintLnBold( "baker rear_left_anchor_impact" );
	}
	else if ( self.targetname == "zipline_launcher_player" )
	{
		activate_exploder( "launcher_foot_C3" );
		//IPrintLnBold( "player rear_left_anchor_impact" );
	}
}

rear_right_anchor_impact( launcher )
{
	if ( launcher.targetname == "zipline_launcher_rorke" )
	{
		activate_exploder( "launcher_foot_R4" );
		//IPrintLnBold( "rorke rear_right_anchor_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_baker" )
	{
		activate_exploder( "launcher_foot_L4" );
		//IPrintLnBold( "baker rear_right_anchor_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_player" )
	{
		activate_exploder( "launcher_foot_C4" );
		//IPrintLnBold( "player rear_right_anchor_impact" );
	}
}

anchor_line_impact( launcher )
{
	if ( launcher.targetname == "zipline_launcher_rorke" )
	{
		activate_exploder( "launcher_anchor_R" );
		//IPrintLnBold( "rorke anchor_line_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_baker" )
	{
		activate_exploder( "launcher_anchor_L" );
		//IPrintLnBold( "baker anchor_line_impact" );
	}
	else if ( launcher.targetname == "zipline_launcher_player" )
	{
		activate_exploder( "launcher_anchor_C" );
		//IPrintLnBold( "player anchor_line_impact" );
	}
}

zipline_launcher_setup_anims( anim_alias )
{
	level endon( "player_on_turret" );
	
	level.zipline_anim_struct anim_single_solo( self, anim_alias );
}

zipline_launcher_aim_anims( ally_zipline_array )
{
	level.zipline_anim_struct thread anim_loop( ally_zipline_array, "zipline_launcher_aim_loop_" + self.animname, "stop_launcher_loop_" + self.animname );
}

zipline_launcher_fire_anims( ally_zipline_array, anim_alias )
{
	level endon( "player_is_starting_zipline" );
	
	if ( IsDefined( ally_zipline_array ) )
	{
		if ( self.animname == "rorke" )
		{
			//something weird is going on when playing these two anims in anim_single
			level.zipline_anim_struct thread anim_single_solo( ally_zipline_array[ 1 ], "zipline_launcher_fire_" + self.animname );
			level.zipline_anim_struct anim_single_solo( ally_zipline_array[ 0 ], "zipline_launcher_fire_" + self.animname );
		}
		else
		{
														   //   guy 				     anime 									  
			level.zipline_anim_struct thread anim_single_solo( ally_zipline_array[ 1 ], "zipline_launcher_fire_" + self.animname );
			level.zipline_anim_struct thread anim_single_solo( ally_zipline_array[ 0 ], "zipline_launcher_fire_" + self.animname );
			wait( 0.1 );
			self anim_self_set_time( "zipline_launcher_fire_" + self.animname, .3 );
			self waittillmatch( "single anim", "end" );
		}
	}
	else
	{
		level.zipline_anim_struct anim_single_solo( self, anim_alias );
	}
}

zipline_wait_anims( ally_zipline_array )
{
	level.zipline_anim_struct thread anim_loop( ally_zipline_array, "zipline_wait_loop_" + self.animname, "stop_zipline_wait_loop_" + self.animname );
}

zipline_anims( ally_zipline_array )
{
												   //   guy 				     anime 					    
	level.zipline_anim_struct thread anim_single_solo( ally_zipline_array[ 1 ], "zipline_" + self.animname );
	
	level.zipline_anim_struct thread anim_first_frame_solo( ally_zipline_array[ 2 ], "zipline_" + self.animname );
												   //   guy 				     anime 					    
	level.zipline_anim_struct thread anim_single_solo( ally_zipline_array[ 2 ], "zipline_" + self.animname );
	level.zipline_anim_struct thread anim_single_solo( ally_zipline_array[ 3 ], "zipline_" + self.animname );

	level.zipline_anim_struct anim_single_solo( ally_zipline_array[ 0 ], "zipline_" + self.animname );
}

spawn_trolley_ally( ally )
{
	if ( ally.animname == "rorke" )
	{
		level.zipline_trolley_rorke.is_out = true;
		level.zipline_trolley_rorke Show();
		
		if ( !flag( "player_is_starting_zipline" ) )
		{
			level.zipline_trolley_rorke zipline_launcher_fire_anims( undefined, "zipline_trolley_fire_rorke" );
		}

		if ( flag( "player_is_starting_zipline" ) )
		{
			level.zipline_launcher_rorke_count++;
		}
	}
	else // it's baker
	{
		level.zipline_trolley_baker.is_out = true;
		level.zipline_trolley_baker Show();
		if ( !flag( "player_is_starting_zipline" ) )
		{
			level.zipline_trolley_baker zipline_launcher_fire_anims( undefined, "zipline_trolley_fire_baker" );
		}
		if ( flag( "player_is_starting_zipline" ) )
		{
			level.zipline_launcher_baker_count++;
		}
	}
}

delete_trolley_ally( ally )
{
	if ( ally.animname == "rorke" )
	{
		level.zipline_trolley_rorke Delete();
	}
	else // it's baker
	{
		level.zipline_trolley_baker Delete();
	}
	
}

detach_rope_ally( ally )
{
	if ( ally.animname == "rorke" )
	{
		//level.zipline_anim_struct thread anim_single_solo( level.detach_rope_rorke, "cornered_zipline_rorkeline_detached" );
		level.detach_rope_rorke Show();
	}
	else // it's baker
	{
		//level.zipline_anim_struct thread anim_single_solo( level.detach_rope_baker, "cornered_zipline_bakerline_detached" );
		level.detach_rope_baker Show();
	}
}

zipline_player_anims()
{
	flag_wait( "player_can_use_zipline" );

	level.zipline_trolley_obj Show();
	level.zipline_trolley_obj glow();
	
	zipline_trigger = GetEnt( "zipline_trigger", "targetname" );
	//"Press and hold [{+activate}] to zipline"
	zipline_trigger SetHintString( &"CORNERED_START_ZIPLINE" );
	
	zipline_lookat = getstruct( "zipline_lookat", "targetname" );
	waittill_trigger_activate_looking_at( zipline_trigger, zipline_lookat, Cos( 40 ), false, true );
	
	level.zipline_trolley_obj stopGlow();
	level.zipline_trolley_obj Delete();
	
	thread maps\cornered_audio::aud_zipline( "start" );
	
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
	}
	level.player AllowCrouch( false );
	level.player AllowProne( false );

	level.player _disableWeaponSwitch();
	level.player _disableUsability();
	level.player _disableOffhandWeapons();
	level.player _disableWeapon();	
	level.player.last_weapon			= level.player GetCurrentWeapon();

	level.zipline_gunup_count  = 1;
	level.constrict_view_count = 1;
	level.release_view_count   = 1;
	
	if ( IsDefined( level.player.binoculars_active ) && level.player.binoculars_active )
		level.player notify( "use_binoculars" );
	
	level.zipline_anim_struct thread anim_first_frame( level.arms_and_legs, "cornered_zipline_player" );
	
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", .5 );
	
	wait( 0.5 );
	
	show_player_arms();
	level.cornered_player_legs Show();
	
	level.cornered_player_arms player_flap_sleeves();
	
	flag_set( "player_is_starting_zipline" );
	level notify( "player_is_starting_zipline" );
	
											  //   guys 				     anime 					   
	level.zipline_anim_struct thread anim_single( level.arms_and_legs	  , "cornered_zipline_player" );
	level.zipline_anim_struct thread anim_single_solo( level.detach_rope_player, "cornered_zipline_player" );
	
	level.player PlayerLinkToDelta( level.cornered_player_arms, "tag_player", 1, 0, 70, 60, 50 );
	wait( 3.0 );
	level.player LerpViewAngleClamp( 0.5, 0, 0, 70, 70, 60, 50 );
	flag_set( "player_is_ziplining" );
		
	// no longer need falling volume for start building
	death_vol = GetEnt( "start_building_fall_volume", "targetname" );
	death_vol Delete();
	
	wait( 1.0 );
	
	thread maps\cornered_audio::aud_zipline( "detach" );
	
	hide_player_arms();
	/*
	// Wait till 2 seconds are left in the current animation
	anim_reference		 = level.scr_anim[ level.arms_and_legs[ 0 ].animname ][ "cornered_zipline_player" ];
	anim_current_percent = level.arms_and_legs[ 0 ] GetAnimTime( anim_reference );
	anim_length			 = GetAnimLength( anim_reference );
	anim_current_time	 = anim_current_percent * anim_length;
	anim_stop_time		 = anim_length - 2;
	wait_time			 = anim_stop_time - anim_current_time;
	wait( wait_time );
	
	// At this point there should be 2 seconds left.  Make sure that by the time the animation is over the player is exactly locked into place
	// This is to avoid popping when transitioning to the rappel (see cornered_code_rappel.gsc cornered_player_rappel_movement_setup() for more information)
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", 1.9 );
	*/
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	
	thread maps\cornered_infil::rappel_stealth();
	
	level.player _enableUsability();
	level.player _enableWeaponSwitch();	
	level.player _enableOffhandWeapons();
	
	hide_player_arms();
	level.cornered_player_legs Hide();
	level.cornered_player_arms player_stop_flap_sleeves();

	flag_set( "zipline_finished" );
}

zipline_gun_up( player )
{	
	if ( level.zipline_gunup_count == 2 )
	{
		level.player _enableWeapon();
		flag_clear( "player_is_ziplining" );
	}
	level.zipline_gunup_count++;
}

constrict_view( player )
{
	level.player LerpViewAngleClamp( 0.5, 0, 0, 5, 5, 5, 0 );
	if ( level.constrict_view_count == 1 )
	{
		wait( 1 );
		thread delete_window_reflectors();
}

	level.constrict_view_count++;
}

rope_detach( player )
{
	do_specular_sun_lerp( true );
	
	flag_set( "player_detach" );
	level.detach_rope_player Show();
	level.player LerpFOV( 80, 1 );
	level.detach_rope_player waittillmatch( "single anim", "end" );
	level.detach_rope_player Delete();
}

gun_down( player )
{
	show_player_arms();
}

release_view( player )
{
	if ( level.release_view_count == 1 )
	{
		level.player LerpViewAngleClamp( 0.5, 0, 0, 70, 40, 60, 50 );
		level.release_view_count++;
	}
}

glass_impact( player )
{
	Earthquake( 0.25, 1, level.player.origin, 800 );
	level.player PlayRumbleOnEntity( "heavy_2s" );
	
	level.zipline_window_player_hit Show();
	zipline_window_player = GetEnt( "zipline_window_player", "targetname" );
	zipline_window_player Delete();
	
	thread maps\cornered_audio::aud_zipline( "landing" );
	stop_exploder( 67 ); // stop FX at start area
	
	level.player LerpFOV( 65, 1 );
	
	level.player LerpViewAngleClamp( 0.5, 0, 0, 0, 0, 0, 0 );
	level.player FreezeControls( true );
	wait( 0.5 );
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
	wait( 0.5 );
	level.player FreezeControls( false );
}

zipline_equipment_anims()
{
	flag_wait( "player_fired_zipline" );
	thread maps\cornered::obj_capture_hvt(); //objective 3 start
	
	//ZIPLINE TROLLEY ANIMATE
	flag_wait( "player_is_starting_zipline" );
	level.zipline_trolley_player Show();
	level.zipline_anim_struct thread anim_single_solo( level.zipline_trolley_player, "cornered_zipline_trolley_player" );
	
	level.zipline_trolley_player waittillmatch( "single anim", "end" );
	level.zipline_trolley_player Delete();
}

launch_rope_ally( zipline_launcher )
{
	if ( zipline_launcher.targetname == "zipline_launcher_rorke" )
   {
   		thread maps\cornered_audio::aud_zipline( "rope_shot_ally", ( -29056, -4719, 27276 ) );
		level.zipline_rope_rorke Show();
		PlayFXOnTag( level._effect[ "zipline_shot" ]	  , zipline_launcher		, "tag_flash" );
		PlayFXOnTag( level._effect[ "vfx_zipline_tracer" ], level.zipline_rope_rorke, "J_zip_1" );
		launch_rope( level.zipline_anim_struct, level.zipline_rope_rorke, "cornered_zipline_rorkeline_launched", "cornered_zipline_rorkeline_at_rest_loop" );
   }
   else //( self.targetname == "zipline_launcher_baker" )
   {
  		thread maps\cornered_audio::aud_zipline( "rope_shot_verb", ( -29204, -4620, 27276 ) );
		level.zipline_rope_baker Show();
		PlayFXOnTag( level._effect[ "zipline_shot" ]	  , zipline_launcher		, "tag_flash" );
		PlayFXOnTag( level._effect[ "vfx_zipline_tracer" ], level.zipline_rope_baker, "J_zip_1" );
		launch_rope( level.zipline_anim_struct, level.zipline_rope_baker, "cornered_zipline_bakerline_launched", "cornered_zipline_bakerline_at_rest_loop" );
   }
}
