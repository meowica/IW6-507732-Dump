#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\cornered_code_rappel;
#include maps\cornered_code_rappel_allies;
#include maps\cornered_binoculars;
#include maps\cornered_lighting;
#include maps\player_scripted_anim_util;


cornered_building_entry_pre_load()
{
	//Glass cutting
	flag_init( "player_out_of_rorkes_way" );
	flag_init( "player_looking_towards_rorke" );
	flag_init( "rorke_started_cutting_glass" );
	flag_init( "player_finished_cutting" );
	flag_init( "player_jumped_into_building" );
	
	//Building entry
	flag_init( "enter_building_ready" );
	flag_init( "player_in_building" );
	flag_init( "rorke_at_wave_node" );
	flag_init( "move_rorke_to_power_junction_entrance" );
	flag_init( "rorke_reached_power_junction_room_node" );
	flag_init( "player_entering_building" );
	
	//Virus upload
	flag_init( "player_can_upload_virus" );
	flag_init( "rorke_at_virus_upload" );
	flag_init( "virus_upload_loop" );
	flag_init( "player_started_virus_upload" );
	flag_init( "player_started_uploading" );
	flag_init( "player_start_upload" );
	flag_init( "player_stop_upload" );
	flag_init( "player_leave_upload" );
	flag_init( "spawn_power_junction_patrol" );
	flag_init( "start_power_junction_patrol_chatter" );
	//flag_init( "start_power_junction_patrol" );
	flag_init( "start_power_junction_patrol_wave_1" );
	flag_init( "start_power_junction_patrol_wave_2" );
	flag_init( "start_power_junction_patrol_shadowkill_enemy" );
	flag_init( "rorke_in_guard_loop" );
	flag_init( "virus_upload_bar_almost_complete" );
	flag_init( "force_virus_upload_bar_complete" );
	flag_init( "virus_upload_bar_complete" );
	//flag_init( "virus_upload_anims_complete" );
	flag_init( "force_player_to_end_virus_upload" );
	flag_init( "finish_upload" );
	
	//Shadow kill
	//flag_init( "let_them_pass_trigger" );
	flag_init( "rorke_in_alcove" );
	flag_init( "enemy_at_shadow_kill_node" );
	flag_init( "shadowkill_phone_on" );
	flag_init( "shadow_kill_enemy_phone_out" );
	flag_init( "shadow_kill_start" );
	flag_init( "shadow_kill_goggles_on" );
	flag_init( "shadow_kill_stab" );
	flag_init( "shadow_kill_done" );
	
	//Power junction patrol
	flag_init( "start_patrol_vo" );
	flag_init( "patrol_out_of_start_hallway" );
	flag_init( "patrol_out_of_shadow_kill_volume" );
	flag_init( "last_patroller_out_of_shadow_kill_volume" );
	flag_init( "patrol_out_of_power_junction_hallway" );
	flag_init( "power_junction_patrol_killed" );
	flag_init( "enemies_aware" );
	flag_init( "all_in" );
	
	//Building exit
	flag_init( "rorke_at_building_exit_node" );
	flag_init( "player_has_exited_the_building" );
	flag_init( "exit_building_ready" );
	flag_init( "player_exiting_building" );
	
	//Inverted rappel
	flag_init( "player_ready_to_deploy_virus" );
	flag_init( "player_deployed_virus" );
	flag_init( "spawn_balcony_enemies" );
	flag_init( "balcony_enemies_on_balcony" );
	flag_init( "player_shot" );
	flag_init( "kill_balcony_enemies" );
	flag_init( "player_is_past_balcony_and_enemies_are_alive" );
	flag_init( "balcony_enemies_killed" );
	//flag_init( "player_is_past_balcony" );
	flag_init( "player_is_past_sleeping_enemy_below" );
	flag_init( "sleeping_enemy_below_dead" );
	flag_init( "inverted_rorke_done" );
	flag_init( "inverted_baker_done" );
	
	//Inverted kill
	flag_init( "player_can_start_inverted_kill" );
	flag_init( "player_not_in_inverted_kill_volume" );
	flag_init( "inverted_kill_fail" );
	flag_init( "player_initiated_pounce" );
	flag_init( "player_pounce" );
	flag_init( "inverted_kill_enemy_started_turning_around" );
	flag_init( "inverted_kill_enemy_turned_around" );
	flag_init( "player_inverted_kill_enemy_pounce_fail_end" );
	flag_init( "player_knife_throw_enemy_dead" );
	flag_init( "inverted_kill_knife_rorke" );
	flag_init( "rorke_inverted_kill" );
	flag_init( "knife_is_touching_enemy" );
	
	//Knife throw kill
	flag_init( "start_knife_throw" );
	flag_init( "player_aims_knife_at_enemy" );
	flag_init( "player_not_aiming_at_enemy" );
	flag_init( "player_throws_knife" );
	flag_init( "player_throws_knife_fail" );
	flag_init( "player_failed_to_throw_knife" );
	
	PreCacheModel( "cnd_laser_cutter" );
	PreCacheModel( "cnd_window_pane_fx" );
	PreCacheModel( "cnd_window_pane_cutout_player" );
	PreCacheModel( "cnd_window_cutout_shattered_player" );
	PreCacheModel( "cnd_window_pane_cutout_ally" );
	PreCacheModel( "cnd_window_cutout_shattered_ally" );
	PreCacheModel( "cnd_window_cut_ribbon" );
	PreCacheModel( "cnd_rappel_tele_rope" );
	PreCacheModel( "cnd_rappel_tele_rope_obj" );
	PreCacheModel( "cnd_hand_held_device_bink" );
	PreCacheModel( "cnd_server_rack_anim" );
	PreCacheModel( "cnd_server_rack_anim_obj" );
	PreCacheModel( "cnd_server_rack_anim_drive_obj" );
	PreCacheModel( "hjk_laptop_animated_on" );
	PreCacheModel( "cnd_cellphone_01_on_anim" );
	PreCacheModel( "cnd_cellphone_01_off_anim" );
	PreCacheModel( "weapon_bolo_knife" );
	PreCacheModel( "weapon_parabolic_knife" );
	PreCacheModel( "viewmodel_lg_push_knife" );
	PreCacheModel( "projectile_lg_push_knife" );
	
	PreCacheItem( "computer_idf" );
	PreCacheItem( "push_knife" );
	PreCacheItem( "throwing_push_knife" );
	PreCacheItem( "m14ebr_hide_acog_silenced_cornered" );
	
	//"Press and hold [{+activate}] to enter building"
	PreCacheString( &"CORNERED_ENTER_BUILDING" );
	//"Press and hold [{+activate}] to start virus upload"
	PreCacheString( &"CORNERED_START_UPLOAD_VIRUS" );
	//"Hold [{+attack}] to upload the virus"
	PreCacheString( &"CORNERED_UPLOAD_VIRUS" );
	//"Press and hold [{+activate}] to hook up to rappel"
	PreCacheString( &"CORNERED_EXIT_BUILDING" );
	//"Press [{+melee}] to use knife"
	PreCacheString( &"CORNERED_INVERTED_KILL" );
	//"Press [{+attack}] to throw knife"
	PreCacheString( &"CORNERED_KNIFE_THROW" );
	
	//"Hold [{+attack}] to upload the virus"
	add_hint_string( "virus_upload", &"CORNERED_UPLOAD_VIRUS", ::should_break_virus_upload_hint );
	//"Hold [{+attack}] to deploy the virus"
	add_hint_string( "virus_deploy", &"CORNERED_DEPLOY_VIRUS" );
	//"Press and hold [{+activate}] to enter building"
	add_hint_string( "enter_building", &"CORNERED_ENTER_BUILDING", ::should_break_enter_building_hint );
	//"Press [{+forward}], [{+back}], [{+moveleft}], or [{+moveright}] to move."
	add_hint_string( "inverted_rappel_movement", &"PLATFORM_HINT_MOVE" );
	//"Press [{+melee}] to use knife"
	add_hint_string( "inverted_kill", &"CORNERED_INVERTED_KILL", ::should_break_inverted_kill_hint );
	//"Press [{+attack}] to throw knife"
	add_hint_string( "knife_throw", &"CORNERED_KNIFE_THROW" ); //, ::should_break_knife_throw_hint );
	
	level.clean_window_player = GetEnt( "clean_window_player", "targetname" );
	level.clean_window_rorke  = GetEnt( "clean_window_rorke", "targetname" );
	
	level.start_inverted_rappel_trigger = GetEnt( "start_inverted_rappel_trigger", "targetname" );
	level.start_inverted_rappel_trigger trigger_off();
	
	level.balcony_enemies_clip = GetEnt( "balcony_enemies_clip", "targetname" );
	level.balcony_enemies_clip NotSolid();
	level.balcony_enemies_clip ConnectPaths();
	
	level.inverted_kill_balcony_door_clip = GetEnt( "inverted_kill_balcony_door_clip", "targetname" );
	level.inverted_kill_balcony_door_clip NotSolid();
	level.inverted_kill_balcony_door_clip ConnectPaths();
	
	level.move_rorke_to_window_trigger = GetEnt( "move_rorke_to_window_trigger", "targetname" );
	level.move_rorke_to_window_trigger trigger_off();
	
	flag_init( "building_entry_finished" );
	flag_init( "shadow_kill_finished" );
	flag_init( "inverted_rappel_finished" );
	
  //level.rappel_rope_rig				= undefined;
  //level.rappel_max_lateral_dist_right = 300;
  //level.rappel_max_lateral_dist_left	= 250;
  //level.rappel_max_lateral_speed		= 9.0;
  //level.rappel_max_downward_speed		= 4.0;
  //level.rappel_max_upward_speed		= 3.0;
}

setup_building_entry()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.building_entry_startpoint = true;
	setup_player();
	spawn_allies();
	thread handle_intro_fx();
	thread fireworks_stealth_rappel();
	thread maps\cornered_audio::aud_check( "building_entry" );
	
	thread delete_window_reflectors();
	level.player thread player_flap_sleeves();
	
	flag_set( "fx_screen_raindrops" );	
	thread maps\cornered_fx::fx_screen_raindrops();
	do_specular_sun_lerp( true );
}

setup_shadow_kill()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.shadow_kill_startpoint = true;
	setup_player();
	spawn_allies();
	thread handle_intro_fx();
	thread fireworks_stealth_rappel();
	
	thread maps\cornered::obj_upload_virus(); //objective 3 start
	thread maps\cornered_audio::aud_check( "shadow_kill" );

	thread delete_window_reflectors();
	thread maps\cornered_fx::fx_screen_raindrops();
}

setup_inverted_rappel()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.inverted_rappel_startpoint = true;
	thread maps\cornered_audio::aud_check( "inverted" );
	thread handle_intro_fx();
	thread fireworks_stealth_rappel();
	setup_player();
	spawn_allies();
	
	thread delete_building_glow();
	thread delete_window_reflectors();
	thread maps\cornered_fx::fx_screen_raindrops();
}

begin_building_entry()
{
	//--use this to run your functions for an area or event.--
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	thread building_entry();
	
	flag_wait( "building_entry_finished" );	
	thread autosave_tactical();
}

begin_shadow_kill()
{
	//--use this to run your functions for an area or event.--
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	thread shadow_kill();
	
	flag_wait( "shadow_kill_finished" );	
	thread autosave_tactical();
}

begin_inverted_rappel()
{
	//--use this to run your functions for an area or event.--
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	thread inverted_rappel();

	flag_wait( "inverted_rappel_finished" );	
	thread autosave_tactical();
}

building_entry()
{
	if ( IsDefined( level.building_entry_startpoint ) )
	{
		level.player thread unlimited_ammo();
	
		rappel_params						  = SpawnStruct();
		rappel_params.right_arc				  = 120;
		rappel_params.left_arc				  = 120;
		rappel_params.top_arc				  = 60;
		rappel_params.bottom_arc			  = 50;
		rappel_params.allow_walk_up			  = true;
		rappel_params.allow_glass_break_slide = true;
		rappel_params.allow_sprint			  = true;
		rappel_params.jump_type				  = "jump_normal";
		rappel_params.show_legs				  = true;
		rappel_params.lateral_plane			  = 1; // XZ plane
		rappel_params.rappel_type			  = "stealth";
		level.rappel_params					  = rappel_params;
		cornered_start_rappel( "rope_ref_stealth", "player_rappel_ground_ref_stealth", rappel_params );
		foreach ( ally in level.allies )
				ally ally_rappel_start_rope( rappel_params.rappel_type );
		
		level.player thread player_flap_sleeves();
	}

	thread handle_building_entry();
	thread building_entry_combat();
	thread allies_building_entry_vo();
	
	waitframe();
	level.allies[ level.const_rorke ] thread allies_building_entry_movement(	 );
	level.allies[ level.const_baker ] thread allies_building_entry_movement(	 );
}

shadow_kill()
{
	thread handle_shadow_kill();
	thread shadow_kill_combat();
	thread allies_shadow_kill_vo();
	
	waitframe();
	level.allies[ level.const_rorke ] thread allies_shadow_kill_movement();
	level.allies[ level.const_baker ] thread allies_shadow_kill_movement();
}

inverted_rappel()
{
	thread handle_rappel_inverted();
	thread inverted_rappel_combat();
	thread allies_inverted_rappel_vo();
	
	waitframe();
	level.allies[ level.const_rorke ] thread allies_inverted_rappel_movement();
	level.allies[ level.const_baker ] thread allies_inverted_rappel_movement();
	if ( IsDefined( level.inverted_rappel_startpoint ) )
	{
								//   clean_window 			    window_model 				    
		thread setup_window_cutout( level.clean_window_player, "cnd_window_pane_cutout_player" );
		thread setup_window_cutout( level.clean_window_rorke , "cnd_window_pane_cutout_ally" );
	}
}

setup_window_cutout( clean_window, window_model )
{
	window = Spawn( "script_model", clean_window.origin );
	clean_window Delete();
	window SetModel( window_model );
	window Show();
	
	window thread entity_cleanup( "player_pounce" );
}

should_break_enter_building_hint()
{
	Assert( IsPlayer( self ) );

	return flag( "player_pressed_use_button" );
}

handle_building_entry()
{
	level.shadowkill_struct				  = getstruct( "shadow_kill_anim_struct", "targetname" );
	level.rappel_entry_anim_struct		  = getstruct( "rappel_entry_anim_struct_stealth", "targetname" );
	level.building_entry_exit_anim_struct = getstruct( "rappel_stealth_building_entry_exit_anim_struct", "targetname" );
	
	cornered_stop_random_wind();
	thread maps\cornered_audio::aud_stop_wind();
	flag_wait( "enter_building_ready" );
	level.rappel_window_frame_obj Show();
	level.rappel_window_frame_obj glow();
	
	look_at		= getstruct( "entry_look_at", "targetname" );
	use_trigger = GetEnt( "player_enter_building_trigger", "targetname" );
	//"Press and hold [{+activate}] to enter building"
	use_trigger SetHintString( &"CORNERED_ENTER_BUILDING" );
	waittill_trigger_activate_looking_at( use_trigger, look_at, Cos( 50 ), false, true, level.plyr_rpl_groundref );
	flag_set( "player_entering_building" );
	rappel_clear_vertical_limits();
	
	thread maps\cornered_audio::aud_rappel( "enter" );
	
	level.rappel_window_frame_obj stopGlow();
	level.rappel_window_frame_obj Delete();
	player_enter_building();
	
	delete_building_glow();
	
	flag_set( "player_in_building" );
	
	//this is here in case the player activated the enter trigger while jumping
	flag_clear( "player_jumping" );
	level.player AllowJump( true );

	//thread upload_virus_setup();
}

player_enter_building()
{	
	level.building_entry_exit_anim_struct thread anim_first_frame( level.arms_and_legs, "rappel_stealth_cut" );
	fake_rope = spawn_anim_model( "cnd_rappel_player_rope" );
	fake_rope Hide();
	level.building_entry_exit_anim_struct thread anim_first_frame_solo( fake_rope, "cornered_rappel_stealth_enterbldg_cut_playerline" );
	 
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
	}
	
	cornered_stop_rappel();
//	foreach ( ally in level.allies )
//		ally ally_rappel_stop_rope();
	level.allies[ 0 ] ally_rappel_stop_rope();
	wait( 0.1 );
	level.player FreezeControls( true );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player _disableWeapon();
	level.player player_stop_flap_sleeves();
	
	level.player Unlink();
	level.rappel_player_legs Unlink();
	level.cnd_rappel_player_rope Unlink();
	wait( 0.1 );
	blend_time = 0.5;
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", blend_time );
	level.rappel_player_legs MoveTo( level.cornered_player_legs.origin, blend_time, 0, 0 );
	level.rappel_player_legs RotateTo( level.cornered_player_legs.angles, blend_time, 0, 0 );
	level.cnd_rappel_player_rope MoveTo( fake_rope.origin, blend_time, 0, 0 );
	level.cnd_rappel_player_rope RotateTo( fake_rope.angles, blend_time, 0, 0 );
	wait( 0.5 );
	
	level.rappel_player_legs Delete();
	fake_rope Delete();
	show_player_arms();
	level.cornered_player_legs Show();
	level.cornered_player_arms player_flap_sleeves();
	
														  //   guys 					     anime 											    
	level.building_entry_exit_anim_struct thread anim_single( level.arms_and_legs		, "rappel_stealth_cut" );
	level.building_entry_exit_anim_struct thread anim_single_solo( level.cnd_rappel_player_rope, "cornered_rappel_stealth_enterbldg_cut_playerline" );
	
	level.cornered_player_arms thread glass_cutting_fx_notetrack_handler();
	
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	
	flag_set( "player_finished_cutting" );
	
	level.player PlayerLinkToDelta( level.cornered_player_arms, "tag_player", 1, 60, 60, 60, 15 );
//	hide_player_arms();
														//   guys 						   anime 											    ender 			   
	level.building_entry_exit_anim_struct thread anim_loop( level.arms_and_legs			, "rappel_stealth_idle"								, "stop_player_loop" );
	level.building_entry_exit_anim_struct thread anim_loop_solo( level.cnd_rappel_player_rope, "cornered_rappel_stealth_enterbldg_idle_playerline", "stop_player_loop" );
/*	
	level.player NotifyOnPlayerCommand( "player_jump_through_window", "+gostand" );
	level.player NotifyOnPlayerCommand( "player_jump_through_window", "+moveup" );
	level.player NotifyOnPlayerCommand( "player_jump_through_window", "+melee" );
	level.player NotifyOnPlayerCommand( "player_jump_through_window", "+melee_breath" );
	level.player NotifyOnPlayerCommand( "player_jump_through_window", "+melee_zoom" );
	
	level.player waittill_notify_or_timeout( "player_jump_through_window", 20 );
*/		
	thread maps\cornered_audio::aud_rappel( "enter2" );
	
	flag_set( "player_jumped_into_building" );
	flag_clear( "fx_screen_raindrops" );
	do_specular_sun_lerp( false );
	
	level.building_entry_exit_anim_struct notify( "stop_player_loop" );
	waittillframeend;
	
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
														  //   guys 					     anime 												 
	level.building_entry_exit_anim_struct thread anim_single( level.arms_and_legs		, "rappel_stealth_jump" );
	level.building_entry_exit_anim_struct thread anim_single_solo( level.cnd_rappel_player_rope, "cornered_rappel_stealth_enterbldg_jump_playerline" );
	
	wait( 0.03 );
	level.player PlayerSetGroundReferenceEnt( undefined );
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	level.player Unlink();
	level.player FreezeControls( false );
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	hide_player_arms();
	level.cornered_player_legs Hide();
	level.cornered_player_arms player_stop_flap_sleeves();
}

/*
killGlassImpactmarks()
{
	wait( 1.5);
	KillFXOnTag( level._effect[ "torch_cutting_glass_spark_crack_rev" ]	 , self, "tag_knife_attach" );
}

*/
glass_cutting_fx_notetrack_handler( ent )
{
	rorke_crack_location_array	= [];
	player_crack_location_array = [];
	while ( 1 )
	{
		self waittill( "single anim", notetrack ); //rorke
		switch( notetrack )
		{
			//case "start_fx_trail_1":
			//case "start_fx_trail_2":
			case "start_fx_trail_3":
			case "start_fx_trail_4":
			case "start_fx_trail_5":
			case "start_fx_trail_6":
			case "start_fx_trail_7":
			case "start_fx_trail_8":
			case "start_fx_trail_9":
			case "start_fx_trail_10":
			case "start_fx_trail_11":
			case "start_fx_trail_12":
			//case "start_fx_trail_13":
			case "start_fx_trail_14":
			case "start_fx_trail_15":
				if ( self.animname == "rorke" )
				{
					PlayFXOnTag( level._effect[ "torch_cutting_glass_spark_ondeath" ], self, "tag_shield_back" );
					PlayFXOnTag( level._effect[ "torch_cutting_glass_spark_crack" ]	 , self, "tag_shield_back" );
				}
				else
				{
					PlayFXOnTag( level._effect[ "torch_cutting_glass_spark_ondeath2" ] , self, "tag_knife_attach" );
					PlayFXOnTag( level._effect[ "torch_cutting_glass_spark_crack" ]	   , self, "tag_knife_attach" );
					PlayFXOnTag( level._effect[ "torch_cutting_glass_spark_crack_rev" ], self, "tag_knife_attach" );
				}
				break;
		}
	}
}

spawn_glass_cutter( ent )
{
	if ( ent.animname == "rorke" )
	{
		level.rorke_glass_cutter = Spawn( "script_model", ent GetTagOrigin( "tag_weapon_chest" ) );
		level.rorke_glass_cutter SetModel( "cnd_laser_cutter" );
		level.rorke_glass_cutter LinkTo( ent, "tag_weapon_chest", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		
		//Spawning this here since Rorke's anim starts first
		level.window_fx_model = Spawn( "script_model", level.clean_window_rorke.origin );
		level.window_fx_model SetModel( "cnd_window_pane_fx" );
		level.window_fx_model thread entity_cleanup( "player_pounce" );
	}
	else //it's the player rig
	{
		level.player_glass_cutter = Spawn( "script_model", ent GetTagOrigin( "tag_weapon_right" ) );
		level.player_glass_cutter SetModel( "cnd_laser_cutter" );
		level.player_glass_cutter LinkTo( ent, "tag_weapon_right", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	}
}

glass_cutter_on( ent )
{
	if ( ent.animname == "rorke" )
	{
		PlayFXOnTag( level._effect[ "torch_cutting_glass_beam" ]	  , level.rorke_glass_cutter, "tag_fx" );
		PlayFXOnTag( level._effect[ "torch_cutting_glass_spark" ]	  , ent						, "tag_inhand" );
		PlayFXOnTag( level._effect[ "torch_cutting_glass_heatribbon" ], ent						, "tag_inhand" );
		//PlayFXOnTag( level._effect[ "torch_cutting_glass_heatribbon_bottom" ], ent				, "tag_inhand" );

		level.window_ribbon_rorke = Spawn( "script_model", ( 0, 0, 0 ) );
		level.window_ribbon_rorke SetModel( "cnd_window_cut_ribbon" );
		level.window_ribbon_rorke.animname = "window_ribbon";
		level.window_ribbon_rorke SetAnimTree();
		level.window_ribbon_rorke Hide();
		
		level.building_entry_exit_anim_struct anim_first_frame_solo( level.window_ribbon_rorke, "cnd_rappel_stealth_enter_bldg_ribbon1" );
		level.window_ribbon_rorke Show();
		level.building_entry_exit_anim_struct anim_single_solo( level.window_ribbon_rorke, "cnd_rappel_stealth_enter_bldg_ribbon1" );
	}
	else //it's the player rig
	{
		PlayFXOnTag( level._effect[ "torch_cutting_glass_beam_player" ]		 , level.player_glass_cutter, "tag_fx" );
		PlayFXOnTag( level._effect[ "torch_cutting_glass_spark" ]			 , ent						, "tag_weapon_left" );
		PlayFXOnTag( level._effect[ "torch_cutting_glass_heatribbon_player" ], ent						, "tag_weapon_left" );
		//PlayFXOnTag( level._effect[ "torch_cutting_glass_heatribbon_bottom" ], ent						, "tag_weapon_left" );

		level.window_ribbon_player = Spawn( "script_model", ( 0, 0, 0 ) );
		level.window_ribbon_player SetModel( "cnd_window_cut_ribbon" );
		level.window_ribbon_player.animname = "window_ribbon";
		level.window_ribbon_player SetAnimTree();
		level.window_ribbon_player Hide();
		
		level.building_entry_exit_anim_struct anim_first_frame_solo( level.window_ribbon_player, "cnd_rappel_stealth_enter_bldg_ribbon2" );
		level.window_ribbon_player Show();
		level.building_entry_exit_anim_struct anim_single_solo( level.window_ribbon_player, "cnd_rappel_stealth_enter_bldg_ribbon2" );
	}
}

glass_cutter_off( ent )
{
	if ( ent.animname == "rorke" )
	{
		StopFXOnTag( level._effect[ "torch_cutting_glass_beam" ]	  , level.rorke_glass_cutter, "tag_fx" );
		StopFXOnTag( level._effect[ "torch_cutting_glass_spark" ]	  , ent						, "tag_inhand" );
		StopFXOnTag( level._effect[ "torch_cutting_glass_heatribbon" ], ent						, "tag_inhand" );
		//KillFXOnTag( level._effect[ "torch_cutting_glass_heatribbon_bottom" ]		, ent						, "tag_inhand" );
	}
	else //it's the player rig
	{
		StopFXOnTag( level._effect[ "torch_cutting_glass_beam_player" ]		 , level.player_glass_cutter, "tag_fx" );
		StopFXOnTag( level._effect[ "torch_cutting_glass_spark" ]			 , ent						, "tag_weapon_left" );
		StopFXOnTag( level._effect[ "torch_cutting_glass_heatribbon_player" ], ent						, "tag_weapon_left" );
		//KillFXOnTag( level._effect[ "torch_cutting_glass_heatribbon_bottom" ]		, ent						, "tag_weapon_left" );
	}
}

delete_glass_cutter( ent )
{
	if ( ent.animname == "rorke" )
	{
		level.rorke_glass_cutter Delete();
	}
	else //it's the player rig
	{
		level.player_glass_cutter Delete();
	}
}

punch_glass( ent )
{
	if ( ent.animname == "rorke" )
	{
		level.window_ribbon_rorke Delete();
		
		level.cut_window_rorke = Spawn( "script_model", level.clean_window_rorke.origin );
		level.cut_window_rorke SetModel( "cnd_window_pane_cutout_ally" );
		
		level.window_cutout_shattered_rorke = Spawn( "script_model", level.clean_window_rorke.origin );
		level.window_cutout_shattered_rorke SetModel( "cnd_window_cutout_shattered_ally" );
		
		level.clean_window_rorke Delete();
		level.cut_window_rorke Show();
		level.window_cutout_shattered_rorke Show();
		
		exploder( 87421 ); // paper blowing
		
		level.window_cutout_shattered_rorke.animname = "window_cutout_shattered_rorke";
		level.window_cutout_shattered_rorke SetAnimTree();
		level.window_cutout_shattered_rorke anim_single_solo( level.window_cutout_shattered_rorke, "cnd_rappel_stealth_enter_bldg_window1" );
		level.window_cutout_shattered_rorke thread entity_cleanup( "player_pounce" );
		level.cut_window_rorke thread entity_cleanup( "player_pounce" );
	}
	else //it's the player rig
	{
		level.window_ribbon_player Delete();
		
		level.cut_window_player = Spawn( "script_model", level.clean_window_player.origin );
		level.cut_window_player SetModel( "cnd_window_pane_cutout_player" );
		
		level.window_cutout_shattered_player = Spawn( "script_model", level.clean_window_player.origin );
		level.window_cutout_shattered_player SetModel( "cnd_window_cutout_shattered_player" );
		
		level.clean_window_player Delete();
		level.cut_window_player Show();
		level.window_cutout_shattered_player Show();
		
		exploder( 87422 ); // paper blowing
		
		level.window_cutout_shattered_player.animname = "window_cutout_shattered_player";
		level.window_cutout_shattered_player SetAnimTree();
		level.window_cutout_shattered_player anim_single_solo( level.window_cutout_shattered_player, "cnd_rappel_stealth_enter_bldg_window2" );
		level.window_cutout_shattered_player thread entity_cleanup( "player_pounce" );
		level.cut_window_player thread entity_cleanup( "player_pounce" );
	}
	//Turn off all light FX on top
	stop_exploder( 10 );
}

building_entry_gun_up( ent )
{
	flag_set( "move_rorke_to_power_junction_entrance" );
	level.player _enableWeapon();
}

upload_virus_setup()
{
	level.laptop = spawn_anim_model( "laptop" );
	level.laptop SetModel( "hjk_laptop_animated_on" );
	level.laptop.animname = "laptop";
	level.shadowkill_struct anim_first_frame_solo( level.laptop, "virus_upload_laptop_enter" );
	
	level.device = spawn_anim_model( "handheld_device" );
	level.device SetModel( "cnd_hand_held_device_bink" );
	level.device.animname = "handheld_device";
	level.device Hide();
	
	level.rack = spawn_anim_model( "rack" );
	level.rack SetModel( "cnd_server_rack_anim" );
	level.rack.animname = "rack";
	
	rack_clip = GetEnt( "server_rack_clip", "targetname" );
	rack_clip LinkTo( level.rack, "j_rack", ( 0, 0, 0 ), ( 0, 90, 0 ) );
	
	level.virus_upload_anim_array	   = [];
	level.virus_upload_anim_array[ 0 ] = level.cornered_player_arms;
	level.virus_upload_anim_array[ 1 ] = level.device;
	level.virus_upload_anim_array[ 2 ] = level.rack;
	
	level.shadowkill_struct anim_first_frame( level.virus_upload_anim_array, "virus_upload_enter" );
	
	flag_wait( "player_can_upload_virus" );
	thread virus_upload_bink_start();
	
	level.rack SetModel( "cnd_server_rack_anim_obj" );
	
	level.virus_upload_trigger	= GetEnt( "player_upload_virus_trigger", "targetname" );
	level.virus_upload_trigger trigger_off();
	level.virus_upload_lookat	= getstruct( "player_upload_virus_lookat", "targetname" );
	level.rack_pull_out_trigger = GetEnt( "player_pulling_out_rack_trigger_old", "targetname" );
	level.rack_pull_out_lookat	= getstruct( "pulling_out_rack_lookat", "targetname" );
	
	old_trigger = GetEnt( "player_pulling_out_rack_trigger", "targetname" );
	old_trigger Delete();
	
	//"Press and hold [{+activate}] to start virus upload"
	level.rack_pull_out_trigger SetHintString( &"CORNERED_START_UPLOAD_VIRUS" );
	
	waittill_trigger_activate_looking_at( level.rack_pull_out_trigger, level.rack_pull_out_lookat, Cos( 40 ) );
	
	flag_set( "player_started_virus_upload" );
	
	thread maps\cornered_audio::aud_virus( "plant" );
	
	level.rack SetModel( "cnd_server_rack_anim" );
	
	level.player _disableWeapon();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
	}
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", .5 );
	wait( 0.5 );
	level.player player_HideViewModelSleeveFlaps();
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
	show_player_arms();
	level.device Show();
	
	level.bink_is_paused = undefined;
	
	thread force_player_to_end_upload();
	thread watch_player_button_press();
	
	level.player.is_in_upload = true;
	level.shadowkill_struct anim_single( level.virus_upload_anim_array, "virus_upload_enter" );
	
	level.player PlayerLinkToDelta( level.cornered_player_arms, "tag_player", 0, 15, 15, 15, 10 );

	thread player_upload_virus_hint();
	thread upload_virus_loop();
	
	level.upload_progress = 1;
	level.max_upload	  = 100;
	
	thread inverted_rappel_setup();
	
	flag_wait( "spawn_power_junction_patrol" );
	thread gun_down_trigger();
	thread shut_server_rack();
	
	flag_wait( "player_exiting_building" );
	level.rack Delete();
	level.laptop Delete();
	SetSavedDvar( "aim_aimAssistRangeScale", "1" );
}

player_upload_virus_hint()
{	
	//thread time_to_pass_before_hint( 3, "virus_upload", "player_started_uploading" );
	//flag_wait_any( "player_start_upload", "player_leave_upload" );
	//flag_set( "player_started_uploading" );
	
	level endon( "virus_upload_bar_complete" );
	
	while ( 1 )
	{
		flag_clear( "player_started_uploading" );
		
		thread time_to_pass_before_hint( 3, "virus_upload", "player_started_uploading" );
		
		flag_wait_any( "player_start_upload", "player_leave_upload" );
		flag_set( "player_started_uploading" ); //stop displaying hint
		
		flag_wait( "player_leave_upload" ); //player left the rig
		
		flag_wait( "virus_upload_loop" ); //player is now back in the rig, restart loop
	
		waitframe();
	}
}

should_break_virus_upload_hint()
{
	Assert( IsPlayer( self ) );

	return flag( "player_started_uploading" );
}

upload_virus_enter()
{
	level endon( "force_player_upload_end" );
	level endon( "enemies_aware" );
	
	if ( IsDefined( level.rack_shut ) )
	{
		level.rack SetModel( "cnd_server_rack_anim_obj" );
		
		level.rack_pull_out_trigger trigger_on();
		//"Press and hold [{+activate}] to start virus upload"
		level.rack_pull_out_trigger SetHintString( &"CORNERED_START_UPLOAD_VIRUS" );

		waittill_trigger_activate_looking_at( level.rack_pull_out_trigger, level.rack_pull_out_lookat, Cos( 40 ) );
		
		level.rack SetModel( "cnd_server_rack_anim" );
		
		level.shadowkill_struct anim_first_frame( level.virus_upload_anim_array, "virus_upload_enter" );
		
	}
	else
	{
		level.rack SetModel( "cnd_server_rack_anim_drive_obj" );
	
		level.virus_upload_trigger trigger_on();
		//"Press and hold [{+activate}] to start virus upload"
		level.virus_upload_trigger SetHintString( &"CORNERED_START_UPLOAD_VIRUS" );

		waittill_trigger_activate_looking_at( level.virus_upload_trigger, level.virus_upload_lookat, Cos( 40 ) );
		
		thread maps\cornered_audio::aud_virus( "restart" );
	
		level.rack SetModel( "cnd_server_rack_anim" );
	}
	
	level.player _disableWeapon();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
	}
	level.player.is_in_upload = true;
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", .5 );
	wait( 0.5 );
	level.player player_HideViewModelSleeveFlaps();
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
	show_player_arms();
	level.device Show();
	
	thread upload_virus_anims();
}

upload_virus_anims()
{
	thread watch_player_button_press();
	if ( IsDefined( level.rack_shut ) )
	{
		level.shadowkill_struct anim_single( level.virus_upload_anim_array, "virus_upload_enter" );
		level.rack_shut = undefined;
	}
	else
	{
		level.shadowkill_struct thread anim_single_solo( level.virus_upload_anim_array[ 0 ], "virus_upload_enter_fast" );
		level.shadowkill_struct anim_single_solo( level.virus_upload_anim_array[ 1 ], "virus_upload_enter_fast" );
	}
	
	level.player PlayerLinkToDelta( level.cornered_player_arms, "tag_player", 0, 15, 15, 15, 10 );
	
	if ( flag( "force_player_to_end_virus_upload" ) )
	{
		upload_virus_exit();
	}
	else
	{
		upload_virus_loop();
	}
}

upload_virus_loop()
{
	flag_set( "virus_upload_loop" );
	thread watch_player_left_stick();
	thread virus_upload_bink();
	//thread virus_upload_vo_nags();
	
	thread upload_virus_loop_anims();

	flag_wait_any( "virus_upload_bar_complete", "player_leave_upload", "force_player_to_end_virus_upload" );
	flag_clear( "virus_upload_loop" );
	level.shadowkill_struct notify( "stop_player_virus_upload_loop" );

	upload_virus_exit();	
}

upload_virus_loop_anims()
{
	level endon( "virus_upload_bar_complete" );
	level endon( "player_leave_upload" );
	level endon( "force_player_to_end_virus_upload" );
	
	if ( flag( "player_start_upload" ) )
	{
		flag_one = "player_stop_upload";
		flag_two = "player_start_upload";
		level.shadowkill_struct thread anim_loop( level.virus_upload_anim_array, "virus_upload_active_loop", "stop_player_virus_upload_loop" );
	}
	else
	{
		flag_one = "player_start_upload";
		flag_two = "player_stop_upload";
		level.shadowkill_struct thread anim_loop( level.virus_upload_anim_array, "virus_upload_loop", "stop_player_virus_upload_loop" );
	}
	
	while ( flag( "virus_upload_loop" ) )
	{
		flag_wait( flag_one );
		level.shadowkill_struct notify( "stop_player_virus_upload_loop" );
		level.shadowkill_struct thread anim_loop( level.virus_upload_anim_array, "virus_upload_active_loop", "stop_player_virus_upload_loop" );
		
		flag_wait( flag_two );
		level.shadowkill_struct notify( "stop_player_virus_upload_loop" );
		level.shadowkill_struct thread anim_loop( level.virus_upload_anim_array, "virus_upload_loop", "stop_player_virus_upload_loop" );
	}
}

watch_player_button_press()
{
	level endon( "force_player_to_end_virus_upload" );
	level endon( "virus_upload_bar_complete" );
	level endon( "force_virus_upload_bar_complete" );
	
	flag_wait( "virus_upload_loop" );
	
	while ( flag( "virus_upload_loop" ) )
	{
		wait( 0.05 );		

		if ( level.player AttackButtonPressed() )
		{
			buttonTime = 0;
			while ( level.player AttackButtonPressed() )
			{
				flag_set( "player_start_upload" );
				flag_clear( "player_stop_upload" );
				
				wait( 0.05 );
			}
			
			if ( flag( "player_start_upload" ) )
			{
				flag_set( "player_stop_upload" );
				flag_clear( "player_start_upload" );
			}
		}
	}
}

watch_player_left_stick()
{
	level endon( "force_player_to_end_virus_upload" );
	level endon( "virus_upload_bar_complete" );
	level endon( "force_virus_upload_bar_complete" );
	
	flag_clear( "player_leave_upload" );
	while ( flag( "virus_upload_loop" ) )
	{
		left_stick = level.player GetNormalizedMovement();
		
		if ( left_stick[ 0 ] < 0 )
		{
			if ( flag( "player_stop_upload" ) || ( !flag( "player_start_upload" ) ) )
			{
				flag_set( "player_leave_upload" );
			}
		}
		
		wait( 0.05 );
	}
}

upload_virus_exit()
{
	if ( flag( "virus_upload_bar_complete" ) )
	{
		level.shadowkill_struct notify( "stop_player_virus_upload_loop" );
		
		level.player LerpViewAngleClamp( 0.5, 0, 0, 0, 0, 0, 0 );
		level.shadowkill_struct anim_single( level.virus_upload_anim_array, "virus_upload_end" );
	
		level.player Unlink();
		level.player _enableWeapon();
		level.player player_ShowViewModelSleeveFlaps();
		level.player AllowCrouch( true );
		level.player AllowProne( true );
		hide_player_arms();
		level.device Hide();
		wait( 0.5 );
		level.player.is_in_upload = undefined;
	}
	else // flag("player_stop_upload") of flag("force_player_to_end_virus_upload")
	{
		level.shadowkill_struct notify( "stop_player_virus_upload_loop" );
	
		thread maps\cornered_audio::aud_virus( "stop" );
		
		level.player LerpViewAngleClamp( 0.5, 0, 0, 0, 0, 0, 0 );
		level.shadowkill_struct thread anim_single_solo( level.virus_upload_anim_array[ 0 ], "virus_upload_end_fast" );
		level.shadowkill_struct anim_single_solo( level.virus_upload_anim_array[ 1 ], "virus_upload_end_fast" );
		
		level.player Unlink();

		level.player AllowCrouch( true );
		level.player AllowProne( true );
		hide_player_arms();
		level.device Hide();
		wait( 0.5 );		
		level.player.is_in_upload = undefined;	
		
		if ( flag( "force_player_to_end_virus_upload" ) )
		{
			if ( level.player GetCurrentWeapon() == "computer_idf" )
			{
				level.player SwitchToWeapon( level.player.currentweapon );
				level.player _enableWeapon();
				level.player player_ShowViewModelSleeveFlaps();
				wait( 0.5 );
				level.player TakeWeapon( "computer_idf" );
				level.player _enableWeaponSwitch();
			}
			else
			{
				level.player _enableWeapon();
				level.player player_ShowViewModelSleeveFlaps();
			}
		}
		else
		{
			level.player.currentweapon = level.player GetCurrentWeapon();
			level.player GiveWeapon( "computer_idf" );
			level.player SwitchToWeaponImmediate( "computer_idf" );
			level.player _disableWeaponSwitch();
			waitframe();
			level.player _enableWeapon();
			level.player player_ShowViewModelSleeveFlaps();
			
			thread player_in_upload_volume();
			upload_virus_enter();
		}	
	}
}

player_in_upload_volume()
{
	level endon( "force_player_upload_end" );
	
	volume = GetEnt( "player_virus_upload_volume", "targetname" );
	
	level.player AllowFire( false );
	
	while ( level.player IsTouching( volume ) && ( !IsDefined( level.player.is_in_upload ) ) )
	{
		wait( 0.05 );
	}
	
	level.player AllowFire( true );
	level.player SwitchToWeapon( level.player.currentweapon );
	wait( 0.5 );
	level.player TakeWeapon( "computer_idf" );
	level.player _enableWeaponSwitch();
}

virus_upload_bink_start()
{
	if ( IsDefined( level.start_point ) && level.start_point == "shadow_kill" )
		wait 2;
	
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	
	CinematicInGame( "cornered_pda_upload" );
//	thread length_test();

	while ( CinematicGetFrame() <= 20 )
		waitframe();

	PauseCinematicInGame( 1 );
}

//length_test()
//{
//	while ( !IsCinematicPlaying() )
//		waitframe();
//	
//	start = GetTime();
//	while ( IsCinematicPlaying() )
//	{
////		if ( IsDefined( level.bink_is_paused ) )
////			waitframe();
//		
  //	  level.bink_current_time2 = GetTime();
  //	  elapsed_time			   = level.bink_current_time2 - start;
  //	  level.bink_percentage2   = elapsed_time / 22000;//17000;
//
//		waitframe();
//	}
  //  end	  = GetTime();
  //  elapsed = end - start;
  //  dummy	  = 0;
//}

virus_upload_bink()
{
	virus_upload_bink_internal();
	
	if ( !flag( "force_virus_upload_bar_complete" ) )
	{
		if ( !IsDefined( level.bink_is_paused ) )
		{
			PauseCinematicInGame( 1 );
			level.bink_is_paused = true;
		}
	}
}

virus_upload_bink_internal()
{
	level endon( "virus_upload_bar_complete" );
	level endon( "player_leave_upload" );
	level endon( "force_player_to_end_virus_upload" );
	level endon( "force_virus_upload_bar_complete" );
	
	//commented this out below because if you were at 95 or 96 and were forced out of the 
	//upload you would never get past this when allowed to upload again
	//while ( !IsCinematicPlaying() )
		//waitframe();
	
	while ( ( flag( "virus_upload_loop" ) ) )
	{
		flag_wait( "player_start_upload" );
		if ( flag( "virus_upload_loop" ) )
		{
			PauseCinematicInGame( 0 );
			level.bink_start_time = GetTime();
			level.bink_is_paused  = undefined;
			thread virus_upload_bink_progress();
		}
	
		flag_wait_any( "virus_upload_bar_complete", "player_stop_upload", "force_player_to_end_virus_upload" );
		if ( flag( "virus_upload_loop" ) )
		{
			PauseCinematicInGame( 1 );
			level.bink_is_paused = true;
			wait( 0.05 );
		}
	}
}

virus_upload_bink_progress()
{
	while ( !IsDefined( level.bink_is_paused ) )
	{
		level.bink_current_time = CinematicGetTimeInMsec();
		level.bink_percentage	= level.bink_current_time / 22000;
		
		if ( level.bink_percentage == 0 )
			level.bink_percentage = 1.0;
		
		if ( level.bink_percentage >= 0.2 )
		{
			if ( !flag( "spawn_power_junction_patrol" ) )
			{
				flag_set( "spawn_power_junction_patrol" );
			}
		}
		
		if ( level.bink_percentage >= 0.92 )
		{
			if ( !flag( "virus_upload_bar_almost_complete" ) )
			{
				flag_set( "virus_upload_bar_almost_complete" );
			}
		}
		
		if ( level.bink_percentage >= 0.93 )
		{
			if ( !flag( "force_virus_upload_bar_complete" ) )
			{
				flag_set( "force_virus_upload_bar_complete" );
			}
		}
		
		if ( level.bink_percentage >= 1.0 )
		{
			if ( !flag( "virus_upload_bar_complete" ) )
			{			
				flag_set( "virus_upload_bar_complete" );
			}
			break;
		}
		
		wait( 0.05 );
	}
}

force_player_to_end_upload()
{
	level endon( "virus_upload_bar_complete" );
	
	flag_wait_either( "force_player_upload_end", "enemies_aware" );
	
	if ( IsDefined( level.player.is_in_upload ) )
	{
		if ( !flag( "force_virus_upload_bar_complete" ) )
		{
			level.player waittill( "damage" );
			flag_set( "force_player_to_end_virus_upload" );
		}
	}
	else
	{	
		if ( IsDefined( level.rack_shut ) )
		{
			level.rack_pull_out_trigger trigger_off();
		}
		else
		{
			level.virus_upload_trigger trigger_off();
		}
		level.rack SetModel( "cnd_server_rack_anim" );
		
		if ( level.player GetCurrentWeapon() == "computer_idf" )
		{
			level.player SwitchToWeapon( level.player.currentweapon );
			wait( 0.5 );
			level.player TakeWeapon( "computer_idf" );
			level.player _enableWeaponSwitch();
			level.player AllowFire( true );
		}
	}
	
	if ( !flag( "force_virus_upload_bar_complete" ) )
	{
		flag_wait_any( "finish_upload", "enemies_aware" );
		if ( !flag( "power_junction_patrol_killed" ) )
		{
			thread watch_player_after_shadow_kill();
		}

		delayThread( 2, ::flag_clear, "force_player_to_end_virus_upload" );
		if ( !flag( "enemies_aware" ) )
		{
			upload_virus_enter();
			thread maps\cornered_audio::aud_virus( "replant" );
		}
	}
}

watch_player_after_shadow_kill()
{
	level endon( "virus_upload_bar_complete" );
	
	flag_wait( "enemies_aware" );
	
	if ( IsDefined( level.rack_shut ) )
	{
		level.rack_pull_out_trigger trigger_off();
	}
	else
	{
		level.virus_upload_trigger trigger_off();	
	}
	level.rack SetModel( "cnd_server_rack_anim" );
	
	flag_wait( "power_junction_patrol_killed" );
	upload_virus_enter();
}

inverted_rappel_setup()
{
	flag_wait( "virus_upload_bar_complete" );
	
	level.player_exit_to_inverted_rope = spawn_anim_model( "cnd_rappel_tele_rope" );
	level.building_entry_exit_anim_struct anim_first_frame_solo( level.player_exit_to_inverted_rope, "rappel_stealth_exit" );
	
	//turning on balcony light fx
	exploder( 5001 );
	exploder( 5002 );
	exploder( 5003 );
	exploder( 5004 );
	
	//turning on crowd
	exploder( 3456 ); //FX crowd
}

gun_down_trigger()
{	
	flag_wait( "spawn_power_junction_patrol" );
	SetSavedDvar( "aim_aimAssistRangeScale", "0" );
	
	gun_down_trigger_internal();

	if ( flag( "gun_down_trigger" ) )
	{
		level.player AllowSprint( true );
		level.player AllowFire( true );
	
		stock_amt = level.player GetWeaponAmmoStock( level.player.regular_weapon );
		clip_amt  = level.player GetWeaponAmmoClip( level.player.regular_weapon );
		
		level.player SwitchToWeapon( level.player.regular_weapon );
		wait( 0.3 );
		level.player TakeWeapon( level.player.hide_weapon );
		level.player SetWeaponAmmoStock( level.player.regular_weapon, stock_amt );
		level.player SetWeaponAmmoClip( level.player.regular_weapon, clip_amt );
		level.player _enableWeaponSwitch();
	}
}

gun_down_trigger_internal()
{
	level endon( "shadow_kill_stab" );
	level endon( "enemies_aware" );
	
	while ( true )
	{
		flag_wait( "gun_down_trigger" );
		level.player AllowSprint( false );
		
		//this is temp and is here to prevent issues with setting ammo stock and clips on two diff weapons
		//if ( level.player GetCurrentWeapon() != "m14ebr_acog_silenced_cornered" )
		if ( level.player GetCurrentWeapon() != "imbel+acog_sp+silencer_sp" )
		{
			//level.player SwitchToWeaponImmediate( "m14ebr_acog_silenced_cornered" );
			level.player SwitchToWeaponImmediate( "imbel+acog_sp+silencer_sp" );
			wait( 0.5 );
		}
		
		level.player.regular_weapon = level.player GetCurrentWeapon();
		
		level.player.hide_weapon = determine_hide_weapon();
		
		stock_amt = level.player GetWeaponAmmoStock( level.player.regular_weapon );
		clip_amt  = level.player GetWeaponAmmoClip( level.player.regular_weapon );
		
		level.player GiveWeapon( level.player.hide_weapon );
		level.player SwitchToWeapon( level.player.hide_weapon );
		//level.player TakeWeapon( level.player.regular_weapon );
		level.player SetWeaponAmmoStock( level.player.hide_weapon, stock_amt );
		level.player SetWeaponAmmoClip( level.player.hide_weapon, clip_amt );
		level.player _disableWeaponSwitch();		
		
		thread hold_fire_unless_ads();
		
		flag_waitopen( "gun_down_trigger" );
		level.player AllowSprint( true );
		
		stock_amt = level.player GetWeaponAmmoStock( level.player.hide_weapon );
		clip_amt  = level.player GetWeaponAmmoClip( level.player.hide_weapon );
		
		level.player GiveWeapon( level.player.regular_weapon );
		level.player SwitchToWeapon( level.player.regular_weapon );
		wait( 0.3 );
		level.player TakeWeapon( level.player.hide_weapon );
		level.player SetWeaponAmmoStock( level.player.regular_weapon, stock_amt );
		level.player SetWeaponAmmoClip( level.player.regular_weapon, clip_amt );
		level.player _enableWeaponSwitch();
	}
}

determine_hide_weapon()
{
	level endon( "shadow_kill_stab" );
	level endon( "enemies_aware" );
	
	//if ( level.player.regular_weapon == "m14ebr_acog_silenced_cornered" )
	if ( level.player.regular_weapon == "imbel+acog_sp+silencer_sp" )
	{
		hide_weapon = "m14ebr_hide_acog_silenced_cornered";
	}
	else //when we have the final guns check other guns
	{
		hide_weapon = "m14ebr_hide_acog_silenced_cornered";
	}
	
	return hide_weapon;
}

hold_fire_unless_ads()
{
	level endon( "shadow_kill_stab" );
	level endon( "enemies_aware" );
	
	while ( flag( "gun_down_trigger" ) )
	{
		level.player AllowFire( false );
		if ( level.player PlayerAds() == 1 )
		{
			wait 0.1;
			level.player AllowFire( true );
			while ( level.player PlayerAds() == 1 )
			{
				
				if ( level.player IsFiring() )
				{
					while ( level.player PlayerAds() == 1 )
					{
						wait( 0.05 );
					}
					
					level.player AllowFire( false );
					
				}
				
				wait( 0.05 );
			}
		}
		wait( 0.05 );
	}
	level.player AllowFire( true );
	//IPrintLnBold( "hold fire done" );
}

shut_server_rack()
{
	level endon( "virus_upload_bar_complete" );
	level endon( "enemies_aware" );
	
	flag_wait( "force_player_upload_end" );
	
	while ( 1 )
	{
		flag_wait( "gun_down_trigger" );
		
		if ( !level.player player_looking_at( level.virus_upload_lookat.origin, Cos( 40 ) ) )
		{
			level.shadowkill_struct anim_first_frame_solo( level.rack, "virus_upload_enter" );
			level.rack_shut = true;
			break;
		}
		wait( 0.05 );
	}
}

festival_spotlights()
{
	festival_spotlight_struct_array = getstructarray( "festival_spotlight", "targetname" );

	festival_spotlight_anim_model_array = [];
	
	foreach ( spotlight_struct in festival_spotlight_struct_array )
	{
		festival_spotlight_anim_model		= spawn_anim_model( "festival_spotlight", spotlight_struct.origin );
		festival_spotlight_anim_model_array = add_to_array( festival_spotlight_anim_model_array, festival_spotlight_anim_model );
	}
	
	foreach ( festival_spotlight_anim_model in festival_spotlight_anim_model_array )
	{
		PlayFXOnTag( level._effect[ "vfx_festival_spot_cnd" ], festival_spotlight_anim_model, "J_prop_1" );
		PlayFXOnTag( level._effect[ "vfx_festival_spot_cnd" ], festival_spotlight_anim_model, "J_prop_2" );
		
		wait( RandomFloatRange( 0.1, .8 ) );
		festival_spotlight_anim_model thread anim_loop_solo( festival_spotlight_anim_model, "cornered_festival_spotlight_1", "stop_loop" );
	}
	
	flag_wait( "baker_security_vo" );
	
	foreach ( festival_spotlight_anim_model in festival_spotlight_anim_model_array )
	{
		StopFXOnTag( level._effect[ "vfx_festival_spot_cnd" ], festival_spotlight_anim_model, "J_prop_1" );
		StopFXOnTag( level._effect[ "vfx_festival_spot_cnd" ], festival_spotlight_anim_model, "J_prop_2" );
		
		festival_spotlight_anim_model notify( "stop_loop" );
		
		festival_spotlight_anim_model Delete();
	}
}

ambient_building_lights()
{	
	//cnd_building_c.map
	window_light_1a = GetEnt( "window_light_1a", "targetname" );
	window_light_1b = GetEnt( "window_light_1b", "targetname" );
	window_light_1c = GetEnt( "window_light_1c", "targetname" );
	window_light_1d = GetEnt( "window_light_1d", "targetname" );
	
	//cnd_building_a.map
	window_light_2a = GetEnt( "window_light_2a", "targetname" );
	window_light_2b = GetEnt( "window_light_2b", "targetname" );
	
	//cnd_building_d.map
	//window_light_3a = GetEnt( "window_light_3a", "targetname" );  //TODO: Uncomment when building D is resolved.
		
	//cnd_vista_building_large_15.map
	window_light_4a = GetEnt( "window_light_4a", "targetname" );
	window_light_4b = GetEnt( "window_light_4b", "targetname" );
	
	window_light_1a thread ambient_building_lights_internal( 5, 15 );
	window_light_1b thread ambient_building_lights_internal( 0, 10 );
	window_light_1c thread ambient_building_lights_internal( 5, 15 );
	window_light_1d thread ambient_building_lights_internal( 0, 10 );
	
	window_light_2a thread ambient_building_lights_internal( 5, 15 );
	window_light_2b thread ambient_building_lights_internal( 0, 10 );
	
	//window_light_3a thread ambient_building_lights_internal( 5, 8 ); //TODO: Uncomment when building D is resolved.
	
	window_light_4a thread ambient_building_lights_internal( 5, 15 );
	window_light_4b thread ambient_building_lights_internal( 0, 10 );

	//cnd_vista_elevator.map in cnd_building_j.map
	vista_elevator_a = GetEnt( "vista_elevator_a", "targetname" );
	//cnd_vista_elevator_02.map in cnd_building_j.map
	vista_elevator_b = GetEnt( "vista_elevator_b", "targetname" );
	
	//cnd_vista_elevator_03.map in cnd_start_building_01.map
	vista_elevator_c = GetEnt( "vista_elevator_c", "targetname" );
	//cnd_vista_elevator_04.map in cnd_start_building_01.map
	vista_elevator_d = GetEnt( "vista_elevator_d", "targetname" );
	
	vista_elevator_a thread ambient_building_elevators( 19184, 29680 );
	vista_elevator_b thread ambient_building_elevators( 19184, 29680 );
	vista_elevator_c thread ambient_building_elevators( 7138, 23298 );
	vista_elevator_d thread ambient_building_elevators( 7138, 23298 );
}

ambient_building_lights_internal( min, max )
{
	if ( cointoss() )
	{
		self Hide();
		self.is_hidden = true;
	}
	else
	{
		self.is_hidden = undefined;
	}
	
	while ( !flag( "baker_security_vo" ) )
	{
	
		wait( RandomFloatRange( min, max ) );
		
		if ( IsDefined( self.is_hidden ) )
		{
			self Show();
			self.is_hidden = undefined;
		}
		else
		{
			self Hide();
			self.is_hidden = true;
		}
	}
	
	if ( IsDefined( self ) )
	{
		self Delete();
	}
}

ambient_building_elevators( min, max )
{
	
	while ( !flag( "baker_security_vo" ) )
	{
		if ( cointoss() )
		{
			self.going_up = true;
		}
		else
		{
			self.going_up = undefined;
		}
		
		//the height of the elevator is 180
		move_distance = 180 * ( RandomIntRange( 5, 40 ) );
		
		//elevator should take 1 second to move up one floor (180 units)
  //so 1/180 = .005 seconds per unit
		time	= move_distance * 0.005;
		
		if ( ( self.origin[ 2 ] + move_distance ) > max && IsDefined( self.going_up ) )
		{
  //move_distance = move_distance * -1;
  //self.going_up = undefined;
			
  //diff		  = ( self.origin[ 2 ] + move_distance ) - max;
  //move_distance = ( self.origin[ 2 ] + move_distance ) - diff;
			
			continue;
		}
		if ( ( ( self.origin[ 2 ] - move_distance ) ) < min && ( !IsDefined( self.going_up ) ) )
		{
  //move_distance = move_distance * 1;
  //self.going_up = true;
			
  //diff		  = min - ( self.origin[ 2 ] - move_distance );
  //move_distance = ( self.origin[ 2 ] - move_distance ) + diff;
			
			continue;
		}
		
		if ( IsDefined( self.going_up ) )
		{
			self MoveTo( self.origin + ( 0, 0, move_distance ), time, .5, .5 );
			self.going_up = undefined;
			wait( time );
		}
		else
		{
			self MoveTo( self.origin + ( 0, 0, ( move_distance * -1 ) ), time, .5, .5 );
			self.going_up = true;
			wait( time );
		}
		
		wait( RandomFloatRange( 5, 10 ) );
	}
	
	if ( IsDefined( self ) )
	{
		self Delete();
	}	
}

building_entry_combat()
{
	volume = GetEnt( "player_out_rorke_building_entry_volume", "targetname" );
	thread watch_player_in_volume( volume, "player_out_of_rorkes_way" );
	
	flag_wait( "player_out_of_rorkes_way" );
	level.rappel_max_lateral_dist_right = 200;
	level.rappel_max_lateral_dist_left	= 370;
	waittill_player_looking_at_rorke( 10 );
	flag_set( "player_looking_towards_rorke" );
}

allies_building_entry_vo()
{	
	//Merrick: Control center is on this floor.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_rke_targetfloor" );
	
	if ( !IsDefined( level.building_entry_startpoint ) )
	{
		thread player_in_rorkes_way();
	}
	
	flag_wait( "rorke_started_cutting_glass" );
	
	wait( 1 );
	flag_set( "enter_building_ready" );
	
	flag_wait( "player_finished_cutting" );
//	thread nag_player_to_jump();
	
	flag_wait( "player_in_building" );
	
	//Merrick: Power system is in the back.  Let's go.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_powersystemisin" );
	music_play( "mus_cornered_entry" );
	thread maps\cornered::obj_upload_virus(); //objective 3 start
	
	flag_set( "building_entry_finished" );
}

player_in_rorkes_way()
{
	level endon( "player_out_of_rorkes_way" );
	
	wait( 3 );
	if ( !flag( "player_out_of_rorkes_way" ) )
	{
		//Merrick: You're in my way, kid.
		level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_youreinmyway" );
	}
	//Merrick: MOVE.
	//Merrick: You're in my way, kid.
	nag_lines	= make_array( "cornered_mrk_move", "cornered_mrk_youreinmyway" );
	thread nag_until_flag( nag_lines, "player_out_of_rorkes_way", 10, 15, 5 );	
}

nag_player_to_jump()
{
	wait( 1 );
	if ( !flag( "player_jumped_into_building" ) )
	{
		temp_dialogue( "Rorke", "Rook, kick that glass in and get in here!" );
	}
}

allies_building_entry_movement()
{
	if ( IsDefined( level.building_entry_startpoint ) )
	{
		level.building_entry_exit_anim_struct = getstruct( "rappel_stealth_building_entry_exit_anim_struct", "targetname" );
		waitframe();
	}
	
	if ( self.animname == "rorke" )
	{
		if ( !IsDefined( level.building_entry_startpoint ) )
		{
			self ally_rappel_stop_aiming();
			self ally_rappel_stop_shooting();
			self rorke_move_to_building_entry();
		}
		
		self rorke_building_entry_movement();

	}
	else //( self.animname == "baker" )
	{
		if ( IsDefined( level.building_entry_startpoint ) )
		{
			level.building_entry_exit_anim_struct thread anim_loop_solo( self, "cnd_rappel_inverted_idle_" + self.animname, "stop_loop" );
		}
		else
		{
			self ally_rappel_stop_aiming();
			self ally_rappel_stop_shooting();
			self baker_building_entry_movement();
		}	
	}
}

baker_building_entry_movement()
{
	self notify( "stop_loop" );
	waittillframeend;
	self StopAnimScripted();	
		
	//volume = GetEnt( self.animname + "_enter_building_volume", "targetname" );
	
	//if ( !( self IsTouching( self.out_volume ) ) )
	if ( !( self IsTouching( self.out_volume ) ) && self.last_volume != self.out_volume )
	{
		//if we're not already touching this volume, move towards it
		self anim_single_solo( self, "move_away_start" );
		self thread anim_loop_solo( self, "move_away", "stop_loop" );
		while ( 1 )
		{
			if ( self IsTouching( self.out_volume ) )
			{
				self notify( "stop_loop" );
				waittillframeend;
				self anim_single_solo( self, "move_away_stop" );
				break;
			}
			wait( 0.05 );
		}
	}
	ally_rappel_start_aiming( "stealth" );
}

rorke_move_to_building_entry()
{
	self notify( "stop_loop" );
	waittillframeend;
	self StopAnimScripted();	
	
	if ( !flag( "player_out_of_rorkes_way" ) )
	{
		volume = GetEnt( self.animname + "_stealth_out", "targetname" );
		
		if ( !( self IsTouching( volume ) ) && self.last_volume != volume )
		//if ( !( self IsTouching( volume ) ) )
		{
			//if we're not already touching this volume, move towards it
			self anim_single_solo( self, "move_away_start" );
			self thread anim_loop_solo( self, "move_away", "stop_loop" );
			while ( 1 )
			{
				if ( self IsTouching( volume ) )
				{
					self notify( "stop_loop" );
					waittillframeend;
					self anim_single_solo( self, "move_away_stop" );
					break;
				}
				wait( 0.05 );
			}
		}
		
		ally_rappel_start_aiming( "stealth" );
		
		flag_wait( "player_out_of_rorkes_way" );
		
		ally_rappel_stop_aiming();
		
	}
	/*
	volume = GetEnt( "rorke_enter_building_horizontal_volume", "targetname" );
	
	if ( !( self IsTouching( volume ) ) )
	{
		//if the ally is not already touching this volume, move towards it
		self anim_single_solo( self, "move_down_start" );
		self thread anim_loop_solo( self, "move_down", "stop_loop" );
		while ( 1 )
		{
			if ( self IsTouching( volume ) )
			{
				self notify( "stop_loop" );
				waittillframeend;
				self anim_single_solo( self, "move_down_stop" );
				break;
			}
			wait( 0.05 );
		}
	}
	*/	
	volume = GetEnt( "rorke_enter_building_vertical_volume", "targetname" );
	
	if ( !( self IsTouching( volume ) ) )
	{
		//if we're not already touching this volume, move towards it
		//self anim_single_solo( self, "move_back_start" );
		
		if ( self.origin[ 0 ]                                 > volume.origin[ 0 ] )
		{
			self thread anim_loop_solo( self, "move_back", "stop_loop" );
		}
		else
		{
			self thread anim_loop_solo( self, "move_away", "stop_loop" );
		}
		
		//self thread anim_loop_solo( self, "move_back", "stop_loop" );
		while ( 1 )
		{
			if ( self IsTouching( volume ) )
			{
				self notify( "stop_loop" );
				waittillframeend;
				//self anim_single_solo( self, "move_back_stop" );
				break;
			}
			wait( 0.05 );
		}
	}
}

rorke_building_entry_movement()
{
	self.cnd_rappel_tele_rope.animname = "building_entry_rope_rorke";
	
	rope_and_rorke		= [];
	rope_and_rorke[ 0 ] = self;
	rope_and_rorke[ 1 ] = self.cnd_rappel_tele_rope;
	
	level.building_entry_exit_anim_struct anim_first_frame( rope_and_rorke, "building_entry_rorke" );
	
	ally_rappel_start_aiming( "stealth" );
	flag_wait( "player_looking_towards_rorke" );

	ally_rappel_stop_aiming();
	thread maps\cornered_audio::aud_rappel( "r_glass" );

	self ally_rappel_stop_rope();
	level.building_entry_exit_anim_struct thread anim_single( rope_and_rorke, "building_entry_rorke" );
	self thread glass_cutting_fx_notetrack_handler();
	wait( 2.25 );
	flag_set( "rorke_started_cutting_glass" );
	self waittillmatch( "single anim", "end" );
	
	self.ignoreall = 1;
	//self enable_cqbwalk();
/*
	if ( !flag( "player_jumped_into_building" ) )
	{
		node = GetNode( "rorke_player_jump_node", "targetname" );
		self thread send_to_node_and_set_flag_if_specified_when_reached( node, "rorke_at_wave_node" );
		
		flag_wait( "rorke_at_wave_node" );
		if ( !flag( "player_finished_cutting" ) )
		{
			flag_wait( "player_finished_cutting" );
			wait( 1 );
			if ( !flag( "player_jumped_into_building" ) )
			{
				self thread anim_single_solo( self, "scout_sniper_price_wave" );
				wait( 1 );
				temp_dialogue( "Rorke", "Rook, kick that glass in and get in here!", 2 );
				self waittillmatch( "single anim", "end" );
			}
		}
		else
		{
			wait( 1 );
			if ( !flag( "player_jumped_into_building" ) )
			{
				self thread anim_single_solo( self, "scout_sniper_price_wave" );
				wait( 1 );
				temp_dialogue( "Rorke", "Rook, kick that glass in and get in here!", 2 );
				self waittillmatch( "single anim", "end" );
			}
		}
	}
*/	
	//move to building entry cover
	node = GetNode( "rorke_entry_node", "targetname" );
	self thread send_to_node_and_set_flag_if_specified_when_reached( node );
	
	flag_wait( "move_to_power_junction_room_entrance" );
	
	//move to power junction room entrance cover
	node = GetNode( "rorke_power_junction_entrance_node", "targetname" );
	self thread send_to_node_and_set_flag_if_specified_when_reached( node );
	
	flag_wait( "move_into_power_junction_room" );
	flag_set( "player_can_upload_virus" );
}

handle_shadow_kill()
{
	if ( IsDefined( level.shadow_kill_startpoint ) )
	{	
								//   clean_window 			    window_model 				    
		thread setup_window_cutout( level.clean_window_player, "cnd_window_pane_cutout_player" );
		thread setup_window_cutout( level.clean_window_rorke , "cnd_window_pane_cutout_ally" );

		flag_set( "player_can_upload_virus" );	
		trigger = GetEnt( "move_into_power_junction_room_trigger", "targetname" );
		trigger Delete();
		trigger = GetEnt( "move_to_power_junction_room_entrance_trigger", "targetname" );
		trigger Delete();
		
		level.shadowkill_struct				  = getstruct( "shadow_kill_anim_struct", "targetname" );
		level.rappel_entry_anim_struct		  = getstruct( "rappel_entry_anim_struct_stealth", "targetname" );
		level.building_entry_exit_anim_struct = getstruct( "rappel_stealth_building_entry_exit_anim_struct", "targetname" );
	}
		
	level.force_rorke_pathing_clip = GetEnt( "force_rorke_pathing_clip", "targetname" );
	level.force_rorke_pathing_clip NotSolid();
	level.force_rorke_pathing_clip ConnectPaths();
	
	thread upload_virus_setup();
}

shadow_kill_combat()
{
	level.patrol_react_anim_count = 1;
	array_spawn_function_targetname( "power_junction_patrollers"	, ::power_junction_patrollers );
	flag_clear( "enemies_aware" );
	
	level.first_two_patrollers_at_goal	= 0;
	level.second_two_patrollers_at_goal = 0;
	
	flag_wait( "spawn_power_junction_patrol" );
	power_junction_patrollers = array_spawn_targetname( "power_junction_patrollers" );
	
	thread manage_power_junction_patrol();
	
	thread shadow_kill_patrol_vo();
	
	level.patroller_deleted = 0;
	thread check_patrol_in_volume( power_junction_patrollers );
	
	thread watch_for_player_to_break_stealth( power_junction_patrollers );
	
	flag_wait_either( "all_in", "enemies_aware" );

	power_junction_patrollers = array_removeDead_or_dying( power_junction_patrollers );
	waittill_dead( power_junction_patrollers );
	flag_set( "power_junction_patrol_killed" );
}

manage_power_junction_patrol()
{
	level endon( "enemies_aware" );
	
	wait( 2.0 );
	flag_set( "start_power_junction_patrol_chatter" );
	wait( 2.0 );
	flag_set( "start_power_junction_patrol_wave_1" );
	wait( 2.0 );
	flag_set( "start_power_junction_patrol_wave_2" );
}

power_junction_patrollers()
{
	self endon( "death" );
	self.ignoreall		  = 1;
	self.animname		  = "generic";
	self.allowdeath		  = true;
	self.patrol_walk_anim = "cornered_shadowkill_patrol_walk";
	
	if ( self.script_noteworthy == "shadow_kill_enemy" )
	{
		self thread shadow_kill_enemy_setup();
	}
	else
	{
		self thread wait_till_shot( undefined, "enemies_aware" );
		self thread stealth_is_broken();
		self thread alert_all_on_death();
	}
	
	self.volume = GetEnt( "power_junction_patrollers_start_hallway_volume", "targetname" );
	self thread watch_for_death_and_alert_all_in_volume( "enemies_aware", "enemies_aware" );
	
	//this is for vo
	if ( self.script_noteworthy == "enemy_1" )
	{
		level.first_patroller = self;
		flag_wait( "start_power_junction_patrol_wave_1" );
		self thread waittill_goal_and_animate();
	}
	if ( self.script_noteworthy == "enemy_2" )
	{
		level.second_patroller = self;
		flag_wait( "start_power_junction_patrol_wave_1" );
		self thread waittill_goal_and_animate();
	}
	if ( self.script_noteworthy == "enemy_3" )
	{
		flag_wait( "start_power_junction_patrol_wave_2" );
		self thread waittill_goal_and_animate();
	}
	if ( self.script_noteworthy == "enemy_4" )
	{
		flag_wait( "start_power_junction_patrol_wave_2" );
		self thread waittill_goal_and_animate();
		
		volume = GetEnt( "power_junction_post_shadow_kill_volume", "targetname" );
		self thread handle_volume_touching ( volume, "last_patroller_out_of_shadow_kill_volume", "last_patroller_out_of_shadow_kill_volume" );
	}
}

waittill_goal_and_animate()
{
	self endon( "death" );
	level endon( "enemies_aware" );
	
	//self thread set_patrol_walk_rate();
	
	//self waittill( "goal" );
	self waittill( "reached_path_end" );
	if ( self.script_noteworthy == "enemy_1" || self.script_noteworthy == "enemy_2" )
	{
		level.first_two_patrollers_at_goal++;
		while ( level.first_two_patrollers_at_goal < 2 )
		{
			wait( 0.05 );
		}	
	}
	
	if ( self.script_noteworthy == "enemy_3" || self.script_noteworthy == "enemy_4" )
	{
		level.second_two_patrollers_at_goal++;
		while ( level.second_two_patrollers_at_goal < 2 )
		{
			wait( 0.05 );
		}	
	}
	
	
	level.shadowkill_struct thread anim_single_solo( self, "cornered_shadowkill_" + self.script_noteworthy );
	//wait( 0.1 );
	//anim_set_rate_internal( "cornered_shadowkill_" + self.script_noteworthy, 0.75 );
	//self thread set_patrol_anim_rate();
	
	self waittillmatch( "single anim", "end" );
	
	struct		= getstruct( "resume_patrol_" + self.script_noteworthy, "targetname" );
	self.target = struct.targetname;
	
	self notify( "end_patrol" );
	self thread maps\_patrol::patrol( self.target );
	/*
	self clear_run_anim();
	self set_run_anim( "cornered_shadowkill_patrol_walk" );
	
	goal_node = GetNode( "patrol_end_" + self.script_noteworthy, "targetname" );
	self set_goalradius( 16 );
	self SetGoalNode( goal_node );
	*/
}

//set_patrol_walk_rate()
//{
//	self set_moveplaybackrate( 0.75 );
//	
//	flag_wait_either( "rorke_in_guard_loop", "enemies_aware" );
//	
//	self set_moveplaybackrate( 1.0 );
//}
//
//set_patrol_anim_rate()
//{
//	flag_wait( "force_player_upload_end" );
//	anim_set_rate_internal( "cornered_shadowkill_" + self.script_noteworthy, 1 );
//}

shadow_kill_enemy_setup()
{
	self endon( "death" );
	level endon( "enemies_aware" );
	
	level.shadow_kill_enemy = self;
	self thread wait_till_shot( "shadow_kill_stab", "enemies_aware" );
	self thread stealth_is_broken( "shadow_kill_stab" );
	self thread alert_all_on_death();

	flag_wait( "start_power_junction_patrol_wave_2" );
	
	wait( 0.5 );
	
	self waittill( "goal" );
	
	level.shadowkill_struct anim_reach_solo( self, "shadowkill_end_enemy" );
	level.shadowkill_struct thread anim_single_solo( self, "shadowkill_end_enemy" );
	
//	level.rorke_knife = Spawn( "script_model", ( 0, 0, 0 ) );
//	level.rorke_knife SetModel( "weapon_bolo_knife" );
//	level.rorke_knife Hide();
//	level.rorke_knife LinkTo( self, "tag_stowed_back", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	self thread shadow_kill_enemy();
}

alert_all_on_death()
{
	level endon( "shadow_kill_stab" );
	
	self waittill( "death" );
	
	if ( !flag( "enemies_aware" ) )
	{
		flag_set( "enemies_aware" );
	}
}

shadow_kill_enemy()
{
	flag_wait( "shadow_kill_stab" );
	self.allowdeath = false;
	self.team		= "neutral";
	self SetCanDamage( false );
	self.ignoreme = true;
	
	self waittillmatch( "single anim", "end" );
	self.a.nodeath			= true;
	self.diequietly			= true;
	self.allowdeath			= true;
	self.noragdoll			= true;
	self.a.disableLongDeath = true;
	self Kill();
}

//patrol_react_anims()
//{
//	self endon( "death" );
//	
//	self.animname = "generic";
//	
//	//flag_wait( "enemies_aware" );
//	
//	if ( self.reactanim == "patrol_react_1" )
//	{
//		self thread anim_single_solo( self, "patrol_react_1" );
//		animation = self getanim( "patrol_react_1" );
//		while ( self GetAnimTime( animation ) < 0.65 )
//		{
//			wait( 0.05 );
//		}
//		self StopAnimScripted();
//	}
//	if ( self.reactanim == "patrol_react_2" )
//	{
//		self thread anim_single_solo( self, "patrol_react_2" );
//		animation = self getanim( "patrol_react_2" );
//		while ( self GetAnimTime( animation ) < 0.45 )
//		{
//			wait( 0.05 );
//		}
//		self StopAnimScripted();
//	}
//	if ( self.reactanim == "patrol_react_3" )
//	{
//		self thread anim_single_solo( self, "patrol_react_3" );
//		animation = self getanim( "patrol_react_3" );
//		while ( self GetAnimTime( animation ) < 0.45 )
//		{
//			wait( 0.05 );
//		}
//		self StopAnimScripted();
//	}
//		
  //  //self.ignoreall	   = false;
  //  //self.favoriteenemy = level.player;
//}

shadow_kill_patrol_vo()
{
	level.first_patroller endon( "death" );
	level.second_patroller endon( "death" );
	level endon( "enemies_aware" );

	//flag_wait( "start_patrol_vo" );
	flag_wait( "start_power_junction_patrol_chatter" );
	//Federation Soldier 1: Casi se acabó mi guardia. ¿Qué hay esta noche?
	level.first_patroller smart_dialogue( "cornered_saf1_imalmostdonewith" );
	//Federation Soldier 2: Dicen que van a jugar truco en el piso de arriba.
	level.second_patroller smart_dialogue( "cornered_saf2_iheartheresa" );
	//Federation Soldier 1: A lo mejor me apunto.
	level.first_patroller smart_dialogue( "cornered_saf1_maybeilldothat" );
	//Federation Soldier 2: No le conviene. Esteban monta la partida. Y hace trampas.
	level.second_patroller smart_dialogue( "cornered_saf2_youdontwantto" );
	//Federation Soldier 1: <laughing>
	level.first_patroller smart_dialogue( "cornered_saf1_laughter" );
	//Federation Soldier 2: <Laughter>
	level.second_patroller smart_dialogue( "cornered_saf2_laughter" );
	
	flag_wait( "force_player_upload_end" );
	//Federation Soldier 1: Tal vez vaya a la pachanga de afuera.
	level.first_patroller smart_dialogue( "cornered_saf1_maybeillgoto" );
	//Federation Soldier 2: Ojalá pudiera acompañarle. Hay muchas jevas buenas por allá.
	level.second_patroller smart_dialogue( "cornered_saf2_iwishicould" );
	//Federation Soldier 1: Váyase antes. ¿Quién se va a enterar?
	level.first_patroller smart_dialogue( "cornered_saf1_leaveearlywhosgonna" );
	//Federation Soldier 2: ¿Y si nos pillan?
	level.second_patroller smart_dialogue( "cornered_saf2_whatifweget" );
	//Federation Soldier 1: No nos pillarán. Confíe en mí.
	level.first_patroller smart_dialogue( "cornered_saf1_wewontgetcaught" );
	//Federation Soldier 2: OK. Vámonos.
	level.second_patroller smart_dialogue( "cornered_saf2_allrightletsgo" );
	maps\cornered_audio::aud_filter_off();
	level.player SetEqLerp( 1, 1 );
}

stealth_is_broken( flag_to_end_on )
{
	self endon( "death" );
	if ( IsDefined( flag_to_end_on ) )
	{
		level endon( flag_to_end_on );
	}
	
	flag_wait( "enemies_aware" );
	self anim_stopanimscripted();
	self notify( "end_patrol" );

	self set_moveplaybackrate( 1.0 );
/*
	if ( flag( "last_patroller_out_of_shadow_kill_volume" ) )
	{
		if ( level.patrol_react_anim_count <= 3 )
		{
			if ( level.patrol_react_anim_count == 1 )
			{
				self.reactanim = "patrol_react_1";
			}
			else if ( level.patrol_react_anim_count == 2 )
			{
				self.reactanim = "patrol_react_2";
			}
			else if ( level.patrol_react_anim_count == 3 )
			{
				self.reactanim = "patrol_react_3";
			}
			level.patrol_react_anim_count++;
			self patrol_react_anims();
		}
	}
*/
	self.ignoreall	   = false;
	self.favoriteenemy = level.player;
	
	self set_baseaccuracy( 15 );
	self player_seek_cnd();
}

player_seek_cnd()
{
	self endon( "death" );
	self endon( "stop_player_seek" );
	
	self.goalradius = 100;
	
	wait( RandomFloatRange( 0, 2 ) );
	
	while ( true )
	{
		node = GetNodesInRadiusSorted( level.player.origin, 500, 0, 128 );
		if ( IsDefined( node ) && node.size > 0 )
		{
			self SetGoalNode( node[ 0 ] );
			wait( RandomFloatRange( 2, 5 ) );
		}
		else
		{
			self SetGoalPos( level.player.origin );
			wait( RandomFloatRange( 1, 2 ) );
		}
	}
}

check_patrol_in_volume( patrol_array )
{
	level endon( "enemies_aware" );
	
	volume						   = GetEnt( "delete_power_junction_patrol_volume", "targetname" );
	patrol_array_minus_shadow_kill = [];
	foreach ( patrol in patrol_array )
	{
		if ( IsAlive( patrol ) && patrol.script_noteworthy != "shadow_kill_enemy" )
		{
			patrol_array_minus_shadow_kill = add_to_array( patrol_array_minus_shadow_kill, patrol );
		}
	}
	
	while ( 1 )
	{
		alltouching = true;
		foreach ( guy in patrol_array_minus_shadow_kill )
		{
			if ( IsAlive( guy ) && !guy IsTouching( volume ) )
			{
				alltouching = false;
			}
		}
		if ( alltouching )
		{
			//flag_set( "all_in" );
			foreach ( guy in patrol_array_minus_shadow_kill )
			{
				if ( IsAlive( guy ) )
					guy thread wait_till_offscreen_then_delete();
			}
			break;
		}
		wait( 0.05 );
	}
	
	while ( level.patroller_deleted < patrol_array_minus_shadow_kill.size )
	{
		wait( 0.05 );
	}
	
	flag_set( "all_in" );
}

wait_till_offscreen_then_delete()
{
	level endon( "enemies_aware" );
	
	ai_is_offscreen = false;
	while ( !ai_is_offscreen )
	{
		
		//if ( !within_fov_2d( level.player.origin, level.player.angles, self.origin, Cos( 45 ) ) )
		if ( !player_can_see_ai( self ) )
		{
			ai_is_offscreen = true;
		}
		else
		{
			wait( 0.1 );
		}
	}
	
	self Delete();
	
	level.patroller_deleted++;
	
}

watch_for_player_to_break_stealth( patrol_array )
{
	level endon( "all_in" );
	
	volume = GetEnt( "watch_for_player_shoot_volume", "targetname" );
	array_thread( patrol_array, ::watch_for_player_to_shoot_while_enemy_in_volume, volume, "enemies_aware", "all_in" );
	
	//Watching if player enters the volume where patrollers spawn
	//Stop watching when one patroller has left this volume
	volume					= GetEnt( "power_junction_patrollers_start_hallway_volume", "targetname" );
	level.player thread handle_volume_touching( volume, "enemies_aware", "patrol_out_of_start_hallway" );
	volume = GetEnt( "power_junction_shadow_kill_volume", "targetname" );
	array_thread( patrol_array, ::handle_volume_touching, volume, "patrol_out_of_start_hallway", "patrol_out_of_start_hallway" );
	
	flag_wait( "patrol_out_of_start_hallway" );
	
	//Watching if player enters the volume where the shadow kill takes place before the shadow kill happens
	//Stops watching when shadow kill anim has started
	volume					= GetEnt( "power_junction_shadow_kill_volume", "targetname" );
	level.player thread handle_volume_touching( volume, "enemies_aware", "shadow_kill_stab" );
	
	//Regardless of shadow kill, watches for when the patrol (minus the shadow kill enemy) is out of the shadow kill volume
	patrol_array_minus_shadow_kill = [];
	foreach ( patrol in patrol_array )
	{
		if ( patrol.script_noteworthy != "shadow_kill_enemy" )
		{
			patrol_array_minus_shadow_kill = add_to_array( patrol_array_minus_shadow_kill, patrol );
		}
	}
	volume = GetEnt( "power_junction_post_shadow_kill_volume", "targetname" );
	array_thread( patrol_array_minus_shadow_kill, ::handle_volume_touching, volume, "patrol_out_of_shadow_kill_volume", "patrol_out_of_shadow_kill_volume" );
	
	flag_wait( "patrol_out_of_shadow_kill_volume" );
	
	//Once the patrol (minus the shadow kill enemy) is out of the shadow kill volume, check for how close the player gets to the patrol
	volume					= GetEnt( "power_junction_post_shadow_kill_volume", "targetname" );
	array_thread( patrol_array_minus_shadow_kill, ::handle_volume_touching, volume, "enemies_aware", "enemies_aware", true );

	//Watches for when one member of the patrol is out of the power junction hall way
	volume = GetEnt( "power_junction_weapons_free_volume", "targetname" );
	array_thread( patrol_array, ::handle_volume_touching, volume, "patrol_out_of_power_junction_hallway", "enemies_aware" );
	
	flag_wait( "patrol_out_of_power_junction_hallway" );
	
	volume					= GetEnt( "outside_power_junction_hallway_volume", "targetname" );
	level.player thread handle_volume_touching( volume, "enemies_aware", "enemies_aware" );
}

watch_for_player_to_shoot_while_enemy_in_volume( volume, flag_to_set, flag_to_end_while_loop )
{
	self endon( "death" );
	
	while ( !flag( flag_to_end_while_loop ) )
	{
		if ( self IsTouching( volume ) && level.player IsTouching( volume ) )
		{
			if ( level.player AttackButtonPressed() && !IsDefined( level.player.is_in_upload ) && level.player GetCurrentWeapon() != "computer_idf" )
			{	
				if ( !flag( flag_to_set ) )
				{
					flag_set( flag_to_set );
				}
				break;
			}
		}
		wait( 0.01 );
	}
}

handle_volume_touching( volume, flag_to_set, flag_to_end_on, distance_check )
{
	self endon( "death" );
	level endon( "enemies_aware" );
	
	if ( IsDefined( flag_to_end_on ) )
	{
		level endon( flag_to_end_on );
	}
	
	while ( 1 )
	{
		if ( self IsTouching( volume ) )
		{
			if ( IsDefined( distance_check ) )
			{
				if ( level.player IsTouching( volume ) )
				{
					distance_between = Distance( level.player.origin, self.origin );
					if ( distance_between < 100 )
					{
						flag_set( flag_to_set );
						break;
					}
				}
			}
			else
			{
				flag_set( flag_to_set );
				break;
			}
		}
		wait( 0.05 );
	}
}

allies_shadow_kill_vo()
{
	thread rorke_shadow_kill_vo();
	thread stealth_break_rorke_vo();
	
	//flag_wait( "power_junction_patrol_killed" );
	//temp_dialogue( "Rorke", "Targets down.", 1.5 );
	//wait( 1 );
	
	flag_wait_any( "all_in", "enemies_aware" );
	
	if ( flag( "enemies_aware" ) && !flag( "all_in" ) )
	{
		flag_wait( "power_junction_patrol_killed" );
	}
	
	if ( !flag( "virus_upload_bar_complete" ) )
	{
		flag_wait( "virus_upload_bar_complete" );
	}
	
	wait( 1 );

	//Merrick: Let’s get to the ropes and hook up.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_letsgettothe" );	
	
	flag_set( "obj_upload_virus_complete" ); //objective 3 complete
	
	level.start_inverted_rappel_trigger trigger_on();
	flag_wait( "start_inverted_rappel" );

	flag_set( "shadow_kill_finished" );
}

rorke_shadow_kill_vo()
{
	level endon( "enemies_aware" );
	
	flag_wait( "player_in_power_junction_hallway" );
	
	//This line is being played in: cornered_virus_upload_enter_rorke
	//Merrick: Patch in. 
	//level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_patchin" );	
	
	if ( !flag( "rorke_at_virus_upload" ) )
	{
		flag_wait( "rorke_at_virus_upload" );
		if ( !flag( "player_started_virus_upload" ) )
		{
			//Merrick: Upload the virus.
			level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_uploadthevirus" );
		}
	}	

	//Merrick: Plant the virus.  We gotta move.
	//Merrick: Move your ass, c'mon.
	nag_lines = make_array( "cornered_mrk_planttheviruswe", "cornered_mrk_moveyourasscmon" );
	thread nag_until_flag( nag_lines, "player_started_virus_upload", 10, 15, 5 );		

	//These two lines are being played in: cornered_virus_upload_enter_rorke
	//Merrick: Tangos coming. Finish up.
	//level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_tangoscomingfinishup" );
	//Merrick: Finish or hide.
	//level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_finishorhide" );
	//This line is being played in: cornered_virus_upload_guard_to_hide_rorke
	//Merrick: Quick, hide in the alcove.
	//level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_quickhideinthe" );
	
	thread weapon_down_vo();
	
	flag_wait( "let_them_pass" );
	wait( 0.5 );
	//Merrick: Let them pass…
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_letthempass" );
	
	/*
	flag_wait_either( "shadowkill_rorke_lookat", "start_patrol_vo" );
	//"Rorke: Stay in the shadows."
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_rke_stayintheshadows" );

	flag_wait( "patrol_out_of_start_hallway" );
	wait( 0.5 );
	//"Rorke: Do not engage."
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_rke_donotengage" );
	*/
	
	//This line is being played in: cornered_shadowkill_end_enemy
	//Federation Soldier 1: What?
	//level.shadow_kill_enemy smart_radio_dialogue( "cornered_saf1_que" );
	//Federation Soldier 1: <<Muffled death grunt>>
	//level.shadow_kill_enemy smart_radio_dialogue( "cornered_saf1_muffleddeathgrunt" );
		
	flag_wait( "shadow_kill_done" );
	
	if ( !flag( "virus_upload_bar_complete" ) )
	{
		//Merrick: I've got your back. Finish the upload.
		level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_ivegotyourback" );
		flag_set( "finish_upload" );
		thread virus_upload_vo_nags();
		flag_wait( "virus_upload_bar_complete" );
		wait( 1.5 );
	}
	else
	{
		//Merrick: Hold. Let them pass.
		level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_holdletthempass" );
		music_play( "mus_cornered_takedown" );
	}
}

virus_upload_vo_nags()
{	
	//Merrick: Plant the virus.  We gotta move.
	//Merrick: Move your ass, c'mon.
	nag_lines = make_array( "cornered_mrk_planttheviruswe", "cornered_mrk_moveyourasscmon" );
	thread nag_until_flag( nag_lines, "player_start_upload", 10, 15, 5 );	
}

weapon_down_vo()
{
	level endon( "enemies_aware" );
	level endon( "let_them_pass" );
	
	flag_wait( "rorke_in_alcove" );
	
	alcove_volume	= GetEnt( "player_shadow_kill_volume", "targetname" );
  //backup_volume = GetEnt( "player_shadow_kill_backup_volume", "targetname" );
	
	while ( 1 )
	{
		if ( level.player IsTouching( alcove_volume ) )
		{
			//Merrick: Weapon down.
			level.allies[ level.const_rorke ] thread smart_radio_dialogue( "cornered_mrk_weapondown" );
			break;
		}
		
		wait( 0.05 );
	}
}

stealth_break_rorke_vo()
{
	level endon( "all_in" );
	
	flag_wait( "enemies_aware" );
	//Merrick: Shit!  What are you doin?!
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_shitwhatareyou" );
	
	flag_wait( "power_junction_patrol_killed" );
	//Merrick: Targets down.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_targetsdown" );
	
	if ( !flag( "virus_upload_bar_complete" ) )
	{
		wait( 1 );
		//Merrick: Finish the upload. 
		level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_finishtheupload" );
		flag_set( "finish_upload" );
		thread virus_upload_vo_nags();
	}
}

allies_shadow_kill_movement()
{
	if ( !IsDefined( level.building_entry_exit_anim_struct ) )
	{
		level.building_entry_exit_anim_struct = getstruct( "rappel_stealth_building_entry_exit_anim_struct", "targetname" );
		waitframe();
	}
	
	if ( self.animname == "rorke" )
	{
		
		self thread shadow_kill_leadup();
		self thread rorke_react_to_stealth_break( "shadow_kill_stab" );
		
		flag_wait( "power_junction_patrol_killed" );
		
		if ( flag( "shadow_kill_stab" ) || flag( "enemies_aware" ) )
		{
			self enable_surprise();
			self.ignoresuppression			 = false;
			self.disableBulletWhizbyReaction = false;
			self.disableFriendlyFireReaction = false;
			self.disableReactionAnims		 = false;
			self set_baseaccuracy( 1 );
		}
		
		if ( !flag( "virus_upload_bar_complete" ) )
		{
			if ( flag( "enemies_aware" ) )
			{
				node = GetNode( "rorke_wait_for_virus_upload_node", "targetname" );
				self thread send_to_node_and_set_flag_if_specified_when_reached( node );
			}
			
			flag_wait( "virus_upload_bar_complete" );
			wait( 2 );
		}
		
		self thread allies_building_exit_hookup();
	}
	else //( self.animname == "baker" )
	{
		if ( IsDefined( level.shadow_kill_startpoint ) )
		{
			//level.building_entry_exit_anim_struct thread anim_single_solo( self, "cnd_rappel_stealth_exit_bldg_" + self.animname );
			//waitframe();
			//self SetAnimTime( getanim( "cnd_rappel_stealth_exit_bldg_" + self.animname ), 1.0 );
			level.building_entry_exit_anim_struct thread anim_loop_solo( self, "cnd_rappel_inverted_idle_" + self.animname, "stop_loop" );
		}
		else
		{
			flag_wait( "player_started_virus_upload" );
			ally_rappel_stop_aiming();
			level.building_entry_exit_anim_struct notify( "stop_loop" );
			level.building_entry_exit_anim_struct thread anim_loop_solo( self, "cnd_rappel_inverted_idle_" + self.animname, "stop_loop" );
		}	
	}
}

shadow_kill_leadup()
{
	level endon( "enemies_aware" );
	
	self.ignoreall = 1;
	
	if ( !IsDefined( level.shadow_kill_startpoint ) )
	{
		flag_wait( "move_into_power_junction_room" );
	}
	
	thread maps\cornered_audio::aud_virus( "r_approach" );
	
	level.shadowkill_struct anim_reach_solo( self, "virus_upload_enter_rorke" );
	level.shadowkill_struct anim_single_solo( self, "virus_upload_enter_rorke" );
	
	flag_set( "rorke_at_virus_upload" );
	
	thread maps\cornered_audio::aud_virus( "r_loop" );
	
	level.shadowkill_struct thread anim_loop_solo( self, "virus_upload_loop_rorke", "stop_loop" );
	
	flag_wait( "start_power_junction_patrol_chatter" );
	level.shadowkill_struct notify( "stop_loop" );

	thread maps\cornered_audio::aud_virus( "r_end" );
	level.shadowkill_struct anim_single_solo( self, "virus_upload_end_rorke" );
	
	flag_set( "rorke_in_guard_loop" );
	
	level.shadowkill_struct thread anim_loop_solo( self, "virus_upload_guard_loop_rorke", "stop_loop" );
	
	flag_wait_any( "virus_upload_bar_almost_complete", "force_player_upload_end" );
	level.shadowkill_struct notify( "stop_loop" );

	level.shadowkill_struct anim_single_solo( self, "virus_upload_guard_hide_rorke" );
	flag_set( "rorke_in_alcove" );
	
	level.shadowkill_struct thread anim_loop_solo( self, "shadowkill_front_idle", "stop_loop" );
	
	flag_wait( "let_them_pass" );
	wait( 1 );
	level.shadowkill_struct notify( "stop_loop" );
	waittillframeend;
	self StopAnimScripted();
	
	level.shadowkill_struct anim_single_solo( self, "shadowkill_front_to_back" );
	
	level.shadowkill_struct thread anim_loop_solo( self, "shadowkill_back_idle", "stop_loop" );
	
	flag_wait( "shadow_kill_start" );
	level.shadowkill_struct notify( "stop_loop" );
	level.allies[ level.const_rorke ] StopAnimScripted();
	
	level.rorke_knife = Spawn( "script_model", ( 0, 0, 0 ) );
	level.rorke_knife SetModel( "weapon_bolo_knife" );
	level.rorke_knife Hide();
	level.rorke_knife LinkTo( level.allies[ level.const_rorke ], "tag_stowed_back", ( 0, 0, 0 ), ( 0, 0, 0 ) );

	thread maps\cornered_audio::aud_virus( "kill" );
	level.shadowkill_struct thread anim_single_solo( level.allies[ level.const_rorke ], "shadowkill_end" );
	thread rorke_shadow_kill();
	
	flag_wait( "shadow_kill_done" );
	
	node = GetNode( "rorke_post_shadow_kill_node", "targetname" );
	level.allies[ level.const_rorke ] thread send_to_node_and_set_flag_if_specified_when_reached( node );
}

rorke_shadow_kill()
{
	level endon( "enemies_aware" );
	
	level.shadowkill_struct waittill( "shadowkill_end" );
	
	flag_set( "shadow_kill_done" );
	thread rorke_react_to_stealth_break( "power_junction_patrol_killed" );
}

laptop_open( rorke )
{
	level.shadowkill_struct anim_single_solo( level.laptop, "virus_upload_laptop_enter" );
}

laptop_on( rorke )
{
	//level.laptop_fx		= level._effect[ "cell_screen_glow_bright" ];
	exploder( "cell_screen_glow" );
	//laptop_fx_struct	= getstruct( "laptop_fx", "targetname" );
	
	//level.laptop_fx_tag = laptop_fx_struct spawn_tag_origin();
	//PlayFXOnTag( level.laptop_fx, level.laptop_fx_tag, "tag_origin" );
}

laptop_close( rorke )
{
	level.shadowkill_struct anim_single_solo( level.laptop, "virus_upload_laptop_end" );
}

laptop_off( rorke )
{
	stop_exploder( "cell_screen_glow" );
	//StopFXOnTag( level.laptop_fx, level.laptop_fx_tag, "tag_origin" );
	//level.laptop_fx_tag Delete();
}

//Rorke notetrack functions
shadowkill_goggles_off( rorke )
{
	rorke thread ally_goggle_glow_off();
}

shadowkill_knife_show( rorke )
{
	level.rorke_knife Show();
}

shadowkill_knife_delete( rorke )
{
	if ( IsDefined( level.rorke_knife ) )
		level.rorke_knife Delete();
}

shadowkill_knife_stab( rorke )
{
	flag_set( "shadow_kill_stab" );
	
	rorke disable_surprise();
	rorke.ignoresuppression			  = true;
	rorke.disableBulletWhizbyReaction = true;
	rorke.disableFriendlyFireReaction = true;
	rorke.disableReactionAnims		  = true;
	rorke set_baseaccuracy( 5 );
}

shadowkill_goggles_on( rorke )
{
	rorke thread ally_goggle_glow_on();
	flag_set( "shadow_kill_goggles_on" );
}

//shadowkill enemy notetrack functions
rorke_start_shadowkill( shadowkill_enemy )
{
	flag_set( "shadow_kill_start" );
}

shadowkill_phone_show( shadowkill_enemy )
{
	flag_set( "shadow_kill_enemy_phone_out" );
	
	level.shadowkill_enemy_phone_array		= [];

	level.shadowkill_enemy_phone_array[ 0 ] = Spawn( "script_model", ( 0, 0, 0 ) );
	level.shadowkill_enemy_phone_array[ 0 ] SetModel( "cnd_cellphone_01_off_anim" );
	level.shadowkill_enemy_phone_array[ 0 ].animname = "shadowkill_enemy_phone_off";
	level.shadowkill_enemy_phone_array[ 0 ] SetAnimTree(	 );
	level.shadowkill_enemy_phone_array[ 0 ] Hide		 (	 );
	
	level.shadowkill_enemy_phone_array[ 1 ] = Spawn( "script_model", ( 0, 0, 0 ) );
	level.shadowkill_enemy_phone_array[ 1 ] SetModel( "cnd_cellphone_01_on_anim" );
	level.shadowkill_enemy_phone_array[ 1 ].animname = "shadowkill_enemy_phone_on";
	level.shadowkill_enemy_phone_array[ 1 ] SetAnimTree(	 );
	level.shadowkill_enemy_phone_array[ 1 ] Hide		 (	 );
	
	thread shadowkill_phone();
	
	thread handle_phone_if_stealth_is_broken();
}

shadowkill_phone()
{
	level endon( "enemies_aware" );
	
	level.shadowkill_struct anim_first_frame( level.shadowkill_enemy_phone_array, "shadowkill_enter_enemy" );
	level.shadowkill_enemy_phone_array[ 0 ] Show(); //show phone off model
	level.shadowkill_struct anim_single( level.shadowkill_enemy_phone_array, "shadowkill_enter_enemy" );
	
	foreach ( phone in level.shadowkill_enemy_phone_array )
	{
		phone thread entity_cleanup( "player_exiting_building" );
	}
}

handle_phone_if_stealth_is_broken()
{
	level endon( "shadow_kill_stab" );
	
	flag_wait( "enemies_aware" );
	
	if ( flag( "shadowkill_phone_on" ) )
	{
		level.shadowkill_enemy_phone_array[ 0 ] Show(); //show phone off model
		level.shadowkill_enemy_phone_array[ 1 ] Hide(); //hide phone on model
	
		StopFXOnTag( level._effect[ "cell_screen_glow" ]	  , level.shadowkill_enemy_phone_array[ 1 ], "tag_fx" );
	}
	
	foreach ( phone in level.shadowkill_enemy_phone_array )
	{
		phone thread entity_cleanup();
	}
}

shadowkill_phone_on( shadowkill_enemy )
{
	level.shadowkill_enemy_phone_array[ 1 ] Show(); //show phone on model
	level.shadowkill_enemy_phone_array[ 0 ] Hide(); //hide phone off model
	
	wait( 0.5 );
	if ( IsDefined( level.shadowkill_enemy_phone_array[ 1 ] ) )
	{
		PlayFXOnTag( level._effect[ "cell_screen_glow" ], level.shadowkill_enemy_phone_array[ 1 ], "tag_fx" );
	}
	
	flag_set( "shadowkill_phone_on" );
}

shadowkill_phone_off( shadowkill_enemy )
{
	level.shadowkill_enemy_phone_array[ 0 ] Show(); //show phone off model
	level.shadowkill_enemy_phone_array[ 1 ] Hide(); //hide phone on model
	
	if ( IsDefined( level.shadowkill_enemy_phone_array[ 1 ] ) )
	{
		StopFXOnTag( level._effect[ "cell_screen_glow" ], level.shadowkill_enemy_phone_array[ 1 ], "tag_fx" );
	}
}

allies_building_exit_hookup()
{
	level endon( "player_exiting_building" );
	
	if ( !IsDefined( level.inverted_rappel_startpoint ) )
	{
		self enable_cqbwalk();
		
		level.move_rorke_to_window_trigger trigger_on();
		level.force_rorke_pathing_clip Solid();
		level.force_rorke_pathing_clip DisconnectPaths();
		
		node = GetNode( "rorke_wait_at_end_of_hall_node", "targetname" );
		self thread send_to_node_and_set_flag_if_specified_when_reached( node );
		
		flag_wait( "move_rorke_to_window" );
		self disable_exits();
		
		node = GetNode( "rorke_building_exit_wait_node", "targetname" );
		self thread send_to_node_and_set_flag_if_specified_when_reached( node, "rorke_at_building_exit_node" );
		
		wait( 1.0 );
		//Merrick: Clear.
		level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_clear_2" );
		
		wait( 5 );
		self enable_exits();
		self disable_cqbwalk();
		level.force_rorke_pathing_clip NotSolid();
		level.force_rorke_pathing_clip ConnectPaths();
		level.force_rorke_pathing_clip Delete();
	}
		
	flag_wait( "rorke_at_building_exit_node" );	
	
	if ( !IsDefined( level.building_entry_exit_anim_struct ) )
	{
		level.building_entry_exit_anim_struct = getstruct( "rappel_stealth_building_entry_exit_anim_struct", "targetname" );
	}
	
	level.building_entry_exit_anim_struct anim_single_solo( self, "cnd_rappel_stealth_exit_bldg_hookup_" + self.animname );
	level.building_entry_exit_anim_struct thread anim_loop_solo( self, "cnd_rappel_stealth_exit_bldg_wait_loop_" + self.animname, "stop_loop" );
}

rorke_react_to_stealth_break( flag_to_end_on )
{
	//level endon( "shadow_kill_stab" );
	level endon( flag_to_end_on );
	
	flag_wait( "enemies_aware" );

	level.shadowkill_struct notify( "stop_loop" );
	waittillframeend;
	self StopAnimScripted();
	
	self.ignoreall = 0;
	self set_baseaccuracy( 0.2 );
	self disable_surprise();
	self.ignoresuppression			 = true;
	self.disableBulletWhizbyReaction = true;
	self.disableFriendlyFireReaction = true;
	self.disableReactionAnims		 = true;
	
	if ( flag( "shadow_kill_start" ) )
	{
		node		= GetNode( "rorke_post_shadow_kill_node", "targetname" );
		self thread send_to_node_and_set_flag_if_specified_when_reached( node );
	}
	else
	{
		node		= GetNode( "rorke_stealth_broke_node", "targetname" );
		self thread send_to_node_and_set_flag_if_specified_when_reached( node );
	}

}

handle_rappel_inverted()
{
	if ( IsDefined( level.inverted_rappel_startpoint ) )
	{
		if ( !IsDefined( level.player_exit_to_inverted_rope ) )
		{
			level.player_exit_to_inverted_rope = spawn_anim_model( "cnd_rappel_tele_rope" );
		}
		
		level.rappel_entry_anim_struct		  = getstruct( "rappel_entry_anim_struct_stealth", "targetname" );
		level.building_entry_exit_anim_struct = getstruct( "rappel_stealth_building_entry_exit_anim_struct", "targetname" );
		
		level.building_entry_exit_anim_struct anim_first_frame_solo( level.player_exit_to_inverted_rope, "rappel_stealth_exit" );
		
		//turning on balcony light fx
		exploder( 5001 );
		exploder( 5002 );
		exploder( 5003 );
		exploder( 5004 );
	}
	
	if ( flag( "rappel_down_ready" ) )
	{
		flag_clear( "rappel_down_ready" );
	}
	if ( flag( "player_allow_rappel_down" ) )
	{
		flag_clear( "player_allow_rappel_down" );
	}
	
	level.player_exit_to_inverted_rope SetModel( "cnd_rappel_tele_rope_obj" );
	
	flag_wait( "exit_building_ready" );
	thread virus_deploy_bink();
	
	use_trigger = GetEnt( "player_exit_building_trigger", "targetname" );
	//"Press and hold [{+activate}] to hook up to rappel"
	use_trigger SetHintString( &"CORNERED_EXIT_BUILDING" );
	look_at = getstruct( "inverted_look_at", "targetname" );
	waittill_trigger_activate_looking_at( use_trigger, look_at, Cos( 40 ), false, true );
	flag_set( "player_exiting_building" );
	
	level.player_exit_to_inverted_rope SetModel( "cnd_rappel_tele_rope" );
	
	thread maps\cornered_audio::aud_invert( "start" );
	player_exit_building();
	
	thread virus_deploy();
	thread detonate_lights_off();
	flag_wait( "rappel_down_ready" );
	level.player display_hint( "inverted_rappel_movement" );
	
	flag_set( "player_allow_rappel_down" );
	rappel_limit_vertical_move( -10000, 0 );
	
	flag_wait( "spawn_inverted_kill_enemies" );
	level.player AllowFire( false );
	level.player AllowMelee( false );
	level.player AllowAds( false );
	wait( 0.5 );
	level.player.currentweapon = level.player GetCurrentWeapon();
	level.player GiveWeapon( "push_knife" );
	level.player SwitchToWeapon( "push_knife" );
	level.player _disableWeaponSwitch();
	
	thread maps\cornered_audio::aud_invert( "knife" );
	
	level.rappel_max_downward_speed = 4.0;
	level.rappel_max_lateral_speed	= 3.0;
	
	thread funnel_player();
	
	//flag_wait( "stop_for_inverted_kill" );
	//rappel_limit_vertical_movement( 0, 0 );
	exploder( 12 ); // Ambient fx inside hallway
	
	flag_wait( "start_inverted_kill_prompting" );
	level.rappel_max_downward_speed = 2.0;
	level.rappel_max_lateral_speed	= 2.0;
	
	player_inverted_kill();
	
	//--JZ Moving these functions to here in case player moves around allies and sprints down hall.--
	thread maps\cornered_interior::courtyard_intro_elevator();
	thread maps\cornered_interior::courtyard_directory();
	thread maps\cornered_interior::courtyard_intro_elevator_guys();
		
	cornered_stop_rappel();
	foreach ( ally in level.allies )
		ally ally_rappel_stop_rope();
	
	//player_rappel_stealth_jump_and_land();
	flag_clear( "disable_rappel_jump" );
	level.player AllowJump( true );
	level.player thread player_handle_outside_effects();
	
	flag_wait( "start_courtyard" );
	
	//flag_wait_all( "inverted_rorke_done", "inverted_baker_done" );
	flag_wait( "inverted_rorke_done" );
	
	flag_set( "inverted_rappel_finished" );
	
			   //   num   
	stop_exploder( 23 );//turn off helipad lights
	stop_exploder( 3456 );//turn off crowd
}

player_handle_outside_effects()
{
	level endon( "junction_entrance_close" );
	
	balcony = GetEnt( "inverted_kill_balcony", "targetname" );
	
//	if ( !IsDefined( balcony ) )
//	{
//		level.player player_stop_flap_sleeves();
//		flag_clear( "fx_screen_raindrops" );
//		do_specular_sun_lerp( false );
//		return;
//	}
	
	is_outside = true;
	
	while ( true )
	{
		if ( !is_outside )
			balcony waittill ( "trigger" );
		
		if ( level.player IsTouching( balcony ) )
		{
			if ( !is_outside )
			{
				is_outside = true;
				self player_flap_sleeves();
				flag_set( "fx_screen_raindrops" );
				do_specular_sun_lerp( true );
			}
		}
		else
		{
			if ( is_outside )
			{
				is_outside = false;
				level.player player_stop_flap_sleeves();
				flag_clear( "fx_screen_raindrops" );
				do_specular_sun_lerp( false );
			}
		}
		
		waitframe();
	}
}

player_exit_building()
{	
//	level.reflection_window_inverted Show();
	
	level.building_entry_exit_anim_struct thread anim_first_frame( level.arms_and_legs, "rappel_stealth_exit" );
	
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
	}
	
	level.player FreezeControls( true );
	level.player _disableWeapon();
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", .5 );
	wait( 0.5 );
	
	show_player_arms();
	level.cornered_player_legs Show();
	
														  //   guys 							   anime 				 
	level.building_entry_exit_anim_struct thread anim_single( level.arms_and_legs				, "rappel_stealth_exit" );
	level.building_entry_exit_anim_struct thread anim_single_solo( level.player_exit_to_inverted_rope, "rappel_stealth_exit" );
	
	level.player.currentweapon = level.player GetCurrentWeapon();
	level.player GiveWeapon( "computer_idf" );
	level.player SwitchToWeapon( "computer_idf" );
	level.player _disableWeaponSwitch();
	
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	hide_player_arms();
	level.cornered_player_legs Hide();
	flag_set( "player_has_exited_the_building" );
	flag_set( "fx_screen_raindrops" );
	do_specular_sun_lerp( true );
		
	level.player FreezeControls( false );
	level.player _enableWeapon();
	level.player AllowFire( false );
	level.player thread player_flap_sleeves();
	
  //level.rappel_max_lateral_dist_right = 70;
	level.rappel_max_lateral_dist_right = 20;
	level.rappel_max_lateral_dist_left	= 250;
	level.rappel_max_downward_speed		= 7.0;
	level.rappel_max_lateral_speed		= 7.0;
	level.rappel_max_upward_speed		= 3.0;
	
	rappel_params				= SpawnStruct();
	rappel_params.right_arc		= 80;
	rappel_params.left_arc		= 80;
	rappel_params.top_arc		= 60;
	rappel_params.bottom_arc	= 60;
	rappel_params.allow_sprint	= false;
	rappel_params.jump_type		= "jump_small";
	rappel_params.allow_walk_up = true;
	rappel_params.show_legs		= false;
	rappel_params.lateral_plane = 1; // XZ plane
	rappel_params.rappel_type	= "inverted";
	level.rappel_params			= rappel_params;
	cornered_start_rappel( "rope_ref_stealth", "player_rappel_ground_ref_upside_down_stealth", rappel_params );
	foreach ( ally in level.allies )
		ally ally_rappel_start_rope( rappel_params.rappel_type );
	level.player_exit_to_inverted_rope Delete();
	
	flag_wait( "player_ready_to_deploy_virus" );
	wait( 0.25 );
	level.player AllowFire( true );
}

virus_deploy_bink()
{
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGame( "cornered_pda_activate" );
	
	while ( CinematicGetFrame() <= 1 )
	waitframe();

	PauseCinematicInGame( 1 );
}

virus_deploy()
{
	level.player NotifyOnPlayerCommand( "deploy", "+attack" );
	level.player thread time_to_pass_before_hint( 3, "virus_deploy" );
	
	level.player waittill( "deploy" );
	PauseCinematicInGame( 0 );
	thread maps\cornered_audio::aud_virus( "activate" );
	flag_set( "player_deployed_virus" );
	
	level.player _disableWeapon();
	wait( 1.5 );
	level.player TakeWeapon( "computer_idf" );
	level.player SwitchToWeaponImmediate( level.player.currentweapon );
	level.player _enableWeaponSwitch();
	level.player _enableWeapon();
}

detonate_lights_off()
{
	flag_wait( "player_deployed_virus" );
	
	wait( 2 );
	
	//cnd_roof_neon_on = GetEnt( "cnd_roof_neon_on", "targetname" );
	//cnd_roof_neon_on Delete();
//	level.cnd_roof_neon_off Show();

	//turn off floors above inverted rappel
	emissive_window_brushes = GetEntArray( "emissive_windows_9", "targetname" );
	turn_lights_off( emissive_window_brushes, "brushes" );
	
	for ( i = 10; i <= 35; i++ )
	{	
		wait( 0.2 );
		lights = GetEntArray( "lights_floor_" + i, "targetname" );
		turn_lights_off( lights, "lights" );
		emissive_window_brushes = GetEntArray( "emissive_window_brush_" + i, "targetname" );
		turn_lights_off( emissive_window_brushes, "brushes" );
		
		//turning off balcony light fx
		if ( i == 13 )
		{
			stop_exploder( 5001 );
		}
		if ( i == 21 )
		{
			stop_exploder( 5002 );
		}
		if ( i == 25 )
		{
			stop_exploder( 5003 );
		}
		if ( i == 28 )
		{
			stop_exploder( 5004 );
		}
	    if ( i == 28 )
		{
			stop_exploder( 56 );
		}
	}
}

turn_lights_off( array, array_type )
{
	if ( array_type == "lights" )
	{
		foreach ( light in array )
		{
			light SetLightIntensity( 0.01 );
		}
	}
	else
	{
		foreach ( brush in array )
		{
			brush Delete();
		}
	}
}

funnel_player()
{
  //level.rappel_max_lateral_dist_right = 150;
  //level.rappel_max_lateral_dist_left	= 250;
  //level.rappel_max_lateral_dist_right = -120;
  //level.rappel_max_lateral_dist_left	= 210;
	
	inverted_rappel_z_max = getstruct( "inverted_rappel_z_max", "targetname" );
	
	level.z_min = level.player.origin		  [ 2 ];
	level.z_max = inverted_rappel_z_max.origin[ 2 ];
	
	current_right_limit_x = level.rappel_max_lateral_dist_right;
	desired_right_limit_x = -120;
	
	current_left_limit_x = level.rappel_max_lateral_dist_left;
	desired_left_limit_x = 210;
	
							   //   current_limit_x 	   desired_limit_x 	      side 	  
	thread funnel_player_internal( current_right_limit_x, desired_right_limit_x, "right" );
	thread funnel_player_internal( current_left_limit_x , desired_left_limit_x , "left" );
}

funnel_player_internal( current_limit_x, desired_limit_x, side )
{	
	start_limit_x = current_limit_x;
	diff		  = start_limit_x - desired_limit_x;
	z_distance	  = level.z_max - level.z_min;
	
	while ( 1 )
	{
		if ( current_limit_x <= desired_limit_x )
		{
			break;
		}
		else
		{
			desired_player_z		   = level.rpl_plyr_anim_origin GetTagOrigin( "j_prop_1" )[ 2 ];
			player_distance_from_z_min = desired_player_z - level.z_min;
			percent					   = player_distance_from_z_min / z_distance;
			
			current_limit_x = start_limit_x - ( percent * diff );
			
			if ( side == "right" )
			{
				level.rappel_max_lateral_dist_right = current_limit_x;
			}
			else
			{
				level.rappel_max_lateral_dist_left = current_limit_x;	
			}
		}
		
		waitframe();
	}
}

player_inverted_kill()
{
	thread player_inverted_kill_fail();
	
	level.player_push_knife = Spawn( "script_model", ( 0, 0, 0 ) );
	level.player_push_knife SetModel( "viewmodel_lg_push_knife" );
	level.player_push_knife Hide();
	level.player_push_knife LinkTo( level.cornered_player_arms, "tag_weapon_right", ( 0, 0, 0 ), ( 0, 0, 0 ) );

	level.rappel_entry_anim_struct thread anim_first_frame( level.arms_and_legs, "pounce_player" );
	
	
	flag_wait( "player_can_start_inverted_kill" );
	
	player_initiates_inverted_kill();
	
	if ( flag( "inverted_kill_fail_kill_player" ) || flag( "inverted_kill_enemy_turned_around" ) )
	{
		flag_set( "player_not_in_inverted_kill_volume" );
		return;
	}
	
	flag_set( "player_initiated_pounce" );
	thread maps\cornered_audio::aud_invert( "ready" );

	level.player _disableWeapon();
	
	if ( flag( "inverted_kill_fail_trigger" ) )
	{
		level.rappel_entry_anim_struct thread anim_first_frame( level.arms_and_legs, "pounce_player_fail" );
		flag_set( "inverted_kill_fail" );
	}
	
	player_lerp_to_anim_start();
	
	flag_set( "player_pounce" );
	thread maps\cornered_audio::aud_invert( "pounce" );
	
	level.player Unlink();
	thread clear_groundref();
	
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
	
	thread player_pounce_anim();

	flag_wait( "start_knife_throw" );
	level.cornered_player_arms player_stop_flap_sleeves();
	hide_player_arms_sleeve_flaps();
	level.player player_HideViewModelSleeveFlaps();
	
	reticle = get_knife_reticle();
	thread flag_if_player_aims_knife_at_enemy( reticle, false );
	
	level.rappel_entry_anim_struct thread anim_first_frame_solo( level.cornered_player_arms, "knife_throw" );
	level.player PlayerLinkToDelta( level.cornered_player_arms, "tag_player", 1, 15, 15, 5, 10 );
	level.player EnableSlowAim();
	
	wait( 0.5 );
	
	thread flag_if_player_aims_knife_at_enemy( reticle, true );
	
	player_throws_knife();

	if ( flag( "player_failed_to_throw_knife" ) )
	{
		reticle Destroy();
		SetSlowMotion( 0.1, 1.0, 0.05 );
		level.player DisableSlowAim();
	}
	else if ( flag( "player_throws_knife" ) )
	{	
		thread maps\cornered_audio::aud_invert( "slow_end" );
		
		level.player _disableWeapon();
		level.player TakeWeapon( "throwing_push_knife" );
		level.player_push_knife Unlink();
		level.player_push_knife Delete();

		level.player_push_knife_projectile = Spawn( "script_model", ( 0, 0, 0 ) );
		level.player_push_knife_projectile SetModel( "projectile_lg_push_knife" );
		level.player_push_knife_projectile Hide();
		level.player_push_knife_projectile LinkTo( level.cornered_player_arms, "tag_weapon_right", ( 5, 0, 0 ), ( 0, 0, 0 ) );
		level.rappel_entry_anim_struct thread anim_first_frame_solo( level.cornered_player_arms, "knife_throw" );
		
		level.player_push_knife_projectile Show();
		show_player_arms();
		
		thread watch_push_knife_throw();
		level.rappel_entry_anim_struct thread anim_single_solo( level.cornered_player_arms, "knife_throw" );
		thread do_knife_throw_blood();
		reticle Destroy();
		wait( 0.25 );
		SetSlowMotion( 0.25, 1.0, 0.5 );
		level.player DisableSlowAim();
		
		level.cornered_player_arms waittillmatch( "single anim", "end" );
		
		level.player Unlink();
		hide_player_arms();
		level.cornered_player_legs Hide();
		level.cornered_player_arms player_stop_flap_sleeves();
		level.player player_stop_flap_sleeves();
		wait( 3 );
		level.player player_ShowViewModelSleeveFlaps();
		level.player SwitchToWeapon( level.player.currentweapon );
		level.player AllowFire( true );
		level.player AllowMelee( true );
		level.player AllowAds( true );
		level.player _enableWeapon(	 );
		level.player _enableWeaponSwitch();
	}
	else if ( flag( "player_throws_knife_fail" ) )
	{
		reticle Destroy();
		SetSlowMotion( 0.25, 1.0, 0.5 );
		level.player DisableSlowAim();
		wait( 0.8 );
		level.player player_HideViewModel();
		level.player _disableWeapon();
	}	
}

do_knife_throw_blood()
{
	wait 0.53; // should be a notetrack
	
	blood_ent = Spawn( "script_model", ( 0, 0, 0 ) );
	blood_ent SetModel( "tag_origin" );
	blood_ent.angles = VectorToAngles( ( 1, 0, 1 ) );
	blood_ent LinkTo( level.player_knife_throw_enemy, "tag_weapon_chest", ( 0, -6, 0 ), ( 0, -90, 0 ) );
	
	PlayFXOnTag( getfx( "neck_stab_blood" ), blood_ent, "tag_origin" );
		
	wait 5;
	
	blood_ent Delete();
}

weapon_anim_start( ent )
{
	hide_player_arms();
	level.player_push_knife Hide();
	wait( 0.25 );
	level.player TakeWeapon( "push_knife" );
	level.player GiveWeapon( "throwing_push_knife" );
	level.player SwitchToWeapon( "throwing_push_knife" );
	level.player _enableWeapon();
	flag_set( "start_knife_throw" );
}

player_inverted_kill_fail()
{	
	level endon( "player_initiated_pounce" );
	
	flag_wait( "inverted_kill_fail_trigger" );
	
	flag_wait( "inverted_kill_fail_stop_player" );
	rappel_limit_vertical_move( 0, 0 );
}

player_pounce_anim()
{
	if ( flag( "inverted_kill_fail" ) )
	{
		level.rappel_entry_anim_struct thread anim_single( level.arms_and_legs, "pounce_player_fail" );
	}
	else
	{
		level.rappel_entry_anim_struct thread anim_single( level.arms_and_legs, "pounce_player" );
		level thread do_inverted_kill_blood();
	}
	
	wait( 0.1 );
	show_player_arms();
	level.cornered_player_legs Show();
	level.player_push_knife Show();
	
	level.cornered_player_arms waittillmatch( "single anim", "player_land_balcony" );
//	level.reflection_window_inverted Delete();
	level.player AllowFire( true );
	
	wait( 2.5 );
	level.player AllowCrouch( true );
	level.player SetStance( "crouch" );
	level.player AllowStand( false );
	thread maps\cornered_audio::aud_invert( "slow" );
	SetSlowMotion( 1.0, 0.25, 0.05 );
	//thread inverted_kill_balcony_door();
	
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	level.player AllowStand( true );
	level.player SetStance( "stand" );
}

do_inverted_kill_blood()
{
	wait 1.9; // should be a notetrack
	
	knife_origin = level.player_push_knife GetTagOrigin( "j_gun" );
	knife_angles = level.player_push_knife GetTagAngles( "j_gun" );
	
	// no bone on tip of knife
	knife_vector = VectorNormalize( AnglesToForward( knife_angles ) );
	blood_origin = knife_origin + ( knife_vector * 6 );
	
	PlayFX( getfx( "neck_stab_blood" ), blood_origin, ( 0, 0, 1 ), ( 1, 0, 0 ) );
	
//	/#thread debug_star_time( blood_origin, ( 1, 0, 0 ), 1000 );#/
}

watch_push_knife_throw()
{
	while ( 1 )
	{
		if ( IsDefined( level.player_knife_throw_enemy ) && level.player_push_knife_projectile IsTouching( level.player_knife_throw_enemy ) )
		{
			//IPrintLnBold( "TOUCHING!" );
			//flag_set( "knife_is_touching_enemy" );
			break;
		}
		wait( 0.05 );
	}
	
	level.player_push_knife_projectile Unlink();
	
	if ( IsDefined( level.player_knife_throw_enemy ) )
	{
		level.player_push_knife_projectile LinkTo( level.player_knife_throw_enemy, "tag_weapon_chest", ( 0, -6, 0 ), ( 0, -90, 0 ) );
	}
		
	flag_wait( "courtyard_intro_goto_elevator" );
	level.player_push_knife_projectile Delete();
}

/*inverted_kill_balcony_door()
{
	level.inverted_kill_balcony_door_clip Solid();
	level.inverted_kill_balcony_door_clip DisconnectPaths();
	
	inverted_kill_balcony_door = GetEntArray( "inverted_kill_balcony_door", "targetname" );
	foreach ( brush in inverted_kill_balcony_door )
	{
		brush MoveTo( brush.origin + ( -100, 0, 0 ), .5, 0, 0 );
	}
}*/

player_initiates_inverted_kill()
{	
	level endon( "inverted_kill_fail_kill_player" );
	level endon( "inverted_kill_enemy_turned_around" );
	
	volume = GetEnt( "inverted_kill_start_volume", "targetname" );
	flag_set( "player_not_in_inverted_kill_volume" );
	
	while ( 1 )
	{
		if ( level.player IsTouching( volume ) )
		{
			if ( flag( "player_not_in_inverted_kill_volume" ) )
			{
				flag_clear( "player_not_in_inverted_kill_volume" );
				level.player display_hint_timeout( "inverted_kill", 5 );
			}
			if ( level.player MeleeButtonPressed() )
			{
				if ( !flag( "player_jumping" ) )
				{
					if ( !flag( "inverted_kill_fail_kill_player" ) )
					{
						break;
					}
				}
			}
		}
		else
		{
			if ( !flag( "player_not_in_inverted_kill_volume" ) )
			{
				flag_set( "player_not_in_inverted_kill_volume" );
			}
		}
		wait( 0.05 );
	}	
	flag_set( "player_not_in_inverted_kill_volume" );
}

should_break_inverted_kill_hint()
{
	Assert( IsPlayer( self ) );

	return flag( "player_not_in_inverted_kill_volume" );
}

clear_groundref()
{
	wait( 0.5 );
	level.player PlayerSetGroundReferenceEnt( undefined );
}

player_lerp_to_anim_start()
{
	player_anim_start  = level.cornered_player_arms GetTagOrigin( "tag_camera" ) - ( 0, 0, 60 );
	player_anim_angles = level.cornered_player_arms GetTagAngles( "tag_camera" );
	
	distance_from_anim_start = Distance( level.player.origin, player_anim_start );
	
	distance_per_second	= 432; //36 units * 12 feet
								 //distance_per_second = 288; //24 units * 12 feet
	
	lerptime = distance_from_anim_start / distance_per_second;
	
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_origin", lerptime );
	wait( lerptime );
}

flag_if_player_aims_knife_at_enemy( reticle, allow_fire )
{	
	level notify( "flag_if_player_aims_knife_at_enemy" );
	level endon( "flag_if_player_aims_knife_at_enemy" );
	
	level.player_knife_throw_enemy endon( "death" );
	level endon( "player_throws_knife" );
	level endon( "player_throws_knife_fail" );
	level endon( "player_failed_to_throw_knife" );

	//thread knife_throw_hint();
	
	while ( 1 )
	{
		// Note: player angles are relative to the entity we are attached to
		player_angles_relative = level.player GetPlayerAngles();
		    
		// Combine player angles with lookref angles to get player's worldspace angles
		forward	= AnglesToForward( level.player GetPlayerAngles() );
		
		trace = BulletTrace( level.player GetEye() + forward * 20, level.player GetEye() + forward * 50000, true, level.player_inverted_kill_enemy );
		//Line( level.player GetEye() + forward * 20, level.player GetEye() + forward * 50000, ( 1, 0, 0 ), 1.0, false, 1 );
		
		if ( IsDefined( trace[ "entity" ] ) && trace[ "entity" ] == level.player_knife_throw_enemy )
		{
			flag_set( "player_aims_knife_at_enemy" );
			reticle.color = ( 1, 0, 0 );
			level.player AllowFire( false );
		}
		else
		{
			flag_clear( "player_aims_knife_at_enemy" );
			reticle.color = ( 1, 1, 1 );
			if ( allow_fire )
				level.player AllowFire( true );
		}
		wait( 0.05 );
	}
}

/*
knife_throw_hint()
{
	flag_wait( "player_aims_knife_at_enemy" );
	level.player display_hint( "knife_throw" );
}

*/
/*
should_break_knife_throw_hint()
{
	Assert( IsPlayer( self ) );

	return ( !flag( "player_aims_knife_at_enemy" ) );
}

*/
get_knife_reticle()
{
	if ( !IsDefined( level.knife_reticle ) )
	{
		knife_reticle			= NewClientHudElem( level.player );
		knife_reticle.x			= 0;
		knife_reticle.y			= 0;
		knife_reticle.alignx	= "center";
		knife_reticle.aligny	= "middle";
		knife_reticle.horzAlign = "center";
		knife_reticle.vertAlign = "middle";
		knife_reticle SetShader( "reticle_center_cross", 32, 32 );
		knife_reticle.hidewhendead	 = true;
		knife_reticle.hidewheninmenu = true;
		knife_reticle.sort			 = 205;
		knife_reticle.foreground	 = true;
		knife_reticle.color			 = ( 1, 1, 1 );
		knife_reticle.alpha			 = 1;
	
		level.knife_reticle = knife_reticle;
	}

	return level.knife_reticle;
}

player_throws_knife()
{
	level endon( "player_failed_to_throw_knife" );
	
	level.player NotifyOnPlayerCommand( "throw", "+attack" );
	level.player NotifyOnPlayerCommand( "throw", "+melee" );
	level.player NotifyOnPlayerCommand( "throw", "+melee_breath" );
	level.player NotifyOnPlayerCommand( "throw", "+melee_zoom" );
	level.player NotifyOnPlayerCommand( "throw", "+frag" );
	
	
	while ( 1 )
	{
		level.player waittill( "throw" );
		if ( flag( "player_aims_knife_at_enemy" ) )
		{

			flag_set( "player_throws_knife" );
			break;
		}
		else
		{
			flag_set( "player_throws_knife_fail" );
			break;
		}
		
	}
}

inverted_rappel_combat()
{
	flag_wait( "player_exiting_building" );
	flag_clear( "enemies_aware" );
	flag_clear( "player_shot" );
	
	array_spawn_function_targetname( "sleeping_enemy_below", ::sleeping_enemy_below_setup );
	sleeping_enemy_below = array_spawn_targetname( "sleeping_enemy_below" );
	
	array_spawn_function_targetname( "rappel_balcony_enemies", ::rappel_balcony_setup );
	
	flag_wait( "spawn_balcony_enemies" );
	level.rappel_balcony_enemies = array_spawn_targetname( "rappel_balcony_enemies" );
	old_ragdoll_max_life		 = GetDvar( "ragdoll_max_life" );
	SetSavedDvar( "ragdoll_max_life", 20000 ); // so balcony shot ragdolls don't stop in mid air
	
	thread allies_help_when_player_shoots_balcony_enemies();
	
	level.rappel_balcony_enemies = array_removeDead_or_dying( level.rappel_balcony_enemies );
	waittill_dead( level.rappel_balcony_enemies );
	flag_set( "balcony_enemies_killed" );
	flag_clear( "enemies_aware" );
	
	flag_wait( "spawn_inverted_kill_enemies" );
	array_spawn_function_targetname( "inverted_kill_enemies", ::inverted_kill_enemies_setup );
	inverted_kill_enemies = array_spawn_targetname( "inverted_kill_enemies" );
	
	wait 10;
	
	SetSavedDvar( "ragdoll_max_life", old_ragdoll_max_life );
}

allies_help_when_player_shoots_balcony_enemies()
{
	level endon( "balcony_enemies_killed" );
	
	flag_wait( "balcony_enemies_on_balcony" );
	thread player_shoots();
	//flag_wait_or( "player_shot" );
	flag_wait_or_timeout( "player_shot", 8 );
	
	level.player waittill_notify_or_timeout( "damage", 1 );
	
	thread ally_to_magicbullet( level.allies[ level.const_rorke ], level.rappel_balcony_enemies );
	wait( 2 );
	thread ally_to_magicbullet( level.allies[ level.const_rorke ], level.rappel_balcony_enemies );
}

player_shoots( flag_to_wait_on )
{
	
	if ( IsDefined( flag_to_wait_on ) )
	{
		flag_wait( flag_to_wait_on );
	}
	
	while ( 1 )
	{
		if ( level.player AttackButtonPressed() )
		{	
			flag_set( "player_shot" );
			break;
		}
		wait( 0.05 );
	}
}

#using_animtree( "generic_human" );
rappel_balcony_setup()
{
	self endon( "death" );
	
	self.animname  = "generic";
	self.ignoreall = 1;
	self.health	   = 50;

	self thread if_player_passes_balcony_before_killing();
	
	self thread wait_till_shot( undefined, "enemies_aware" );
	
	self thread balcony_anims();
	
	if ( self.script_noteworthy == "cornered_inv_balcony_walkin_enemy2" )
	{
		volume = GetEnt( "inverted_rappel_balcony_volume", "targetname" );
		while ( 1 )
		{
			if ( self IsTouching( volume ) )
			{
				flag_set( "balcony_enemies_on_balcony" );
				break;
			}
			wait( 0.05 );
		}
	}
	
	flag_wait( "balcony_enemies_on_balcony" );
	
	self.allowdeath = 1;
	
	level.balcony_enemies_clip Solid();
	level.balcony_enemies_clip DisconnectPaths();
	
	flag_wait( "enemies_aware" );
	self.ignoreall = 0;
	level.rappel_entry_anim_struct notify( "stop_loop" );
	waittillframeend;
	self anim_stopanimscripted();
	self.favoriteenemy = level.player;
	
	if ( self.script_noteworthy == "cornered_inv_balcony_walkin_enemy1" )
	{
		self clear_deathanim();
	}
}

balcony_anims()
{
	self endon( "death" );
	level endon( "enemies_aware" );
	
	level.rappel_entry_anim_struct thread anim_single_solo( self, self.script_noteworthy );
	if ( self.script_noteworthy == "cornered_inv_balcony_walkin_enemy1" )
	{
		wait( 4 );
		self.deathanim = %cornered_inv_balcony_death_enemy1;
	}
	self waittillmatch( "single anim", "end" );
	level.rappel_entry_anim_struct thread anim_loop_solo( self, self.script_noteworthy + "_loop", "stop_loop" );
}

if_player_passes_balcony_before_killing()
{
	self endon( "death" );
	
	flag_wait( "player_is_past_balcony" );
	if ( !flag( "player_is_past_balcony_and_enemies_are_alive" ) )
	{
		flag_set( "player_is_past_balcony_and_enemies_are_alive" );
	}
	
	wait( RandomFloatRange( 0.25, 0.75 ) );
	
	ally_head  = level.allies[ level.const_rorke ] GetTagOrigin( "j_head" );
	enemy_head = self GetTagOrigin( "j_head" );
		
	vector		= VectorNormalize( enemy_head - ally_head );
	start		= ally_head + vector * ( Distance( enemy_head, ally_head ) - 10 );
	self.health = 1;
	MagicBullet( level.allies[ level.const_rorke ].weapon, start, enemy_head );
	
	wait( 1 );
	self Kill();
}

#using_animtree( "generic_human" );
sleeping_enemy_below_setup()
{
	self.ignoreall	= true;
	self.animname	= "generic";
	self.diequietly = true;
	self.noragdoll	= true;
	self.health		= 10;
	self.deathanim	= %cnd_rappel_stealth_3rd_floor_sleeping_enemy_death;

	chair = GetEnt( "sleeping_enemy_below_chair", "targetname" );
	Assert( IsDefined( chair ) );
	chair.animname = "chair";
	chair SetAnimTree();
	
	guy_and_chair[ 0 ] = self;
	guy_and_chair[ 1 ] = chair;
	
	self.struct			= getstruct( "sleeping_enemy_below_struct", "targetname" );
	self.struct thread anim_loop( guy_and_chair, "sleep_idle", "stop_loop" );

	flag_wait( "player_is_past_balcony" );
	waitframe();
	self.allowdeath = true;
	self thread sleeping_enemy_below_alerted_or_killed( guy_and_chair, chair );
	level thread cleanup_sleeping_enemy( self, chair );

	self thread wait_till_shot( "enemies_aware", undefined, "enemy_aware" );
	self thread alert_all();
}

sleeping_enemy_below_alerted_or_killed( guy_and_chair, chair )
{
	level endon ( "start_inverted_kill_prompting" );
	
	self waittill_any( "enemy_aware", "death" );
	
	if ( IsAlive( self ) )
	{
		self.struct notify( "stop_loop" );
		waittillframeend;
		self.deathAnim = %exposed_death_headshot;
		self.struct anim_single( guy_and_chair, "sleep_react" );
		self.ignoreall	   = false;
		self.noragdoll	   = false;
		self.favoriteenemy = level.player;
	}
	else if ( !IsAlive( self ) )
	{
		chair thread anim_single_solo( chair, "sleep_death" );
	}
}

cleanup_sleeping_enemy( guy, chair )
{
	flag_wait( "start_courtyard" );
	
	if ( IsDefined( guy ) )
		guy Delete();
	if ( IsDefined( chair ) )
		chair Delete();
}

inverted_kill_enemies_setup()
{
	self.ignoreall			= true;
	self.animname			= "generic";
	self.a.nodeath			= true;
	self.diequietly			= true;
	self.allowdeath			= true;
	self.noragdoll			= true;
	self.a.disableLongDeath = true;
	
	if ( self.script_noteworthy == "guy1" )
	{
		level.player_inverted_kill_enemy = self;
		//level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_walkin" );
		//wait( 0.1 ); //this wait must be here for the anim_set_rate_single to work
		//anim_set_rate_single( self, "player_inverted_kill_enemy_walkin", 1.75 );
		//self waittillmatch( "single anim", "end" );
		
		//level.rappel_entry_anim_struct anim_single_solo( self, "player_inverted_kill_enemy_walkin" );
		//flag_set( "player_can_start_inverted_kill" );
		
		self player_inverted_kill_enemy_anims();
		//level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_walkin" );
		//self waittillmatch( "single anim", "end" );
		//level.rappel_entry_anim_struct thread anim_loop_solo( self, "player_inverted_kill_enemy_idle", "stop_player_inverted_kill_enemy_idle" );
		//flag_wait( "player_pounce" );
		
		if ( IsDefined( self.walkin_anim ) )
		{
			self StopAnimScripted();
		}
		else
		{
			level.rappel_entry_anim_struct notify( "stop_player_inverted_kill_enemy_idle" );
			waittillframeend;
		}
		
		if ( flag( "inverted_kill_fail_trigger" ) )
		{
			if ( !flag( "player_pounce" ) )
			{
				self player_inverted_kill_enemy_fail_anim();
				if ( flag( "player_pounce" ) )
				{
					//if the enemy has started turning, the player gets once last chance to pounce
					if ( flag( "inverted_kill_enemy_started_turning_around" ) )
					{
						if ( !flag( "inverted_kill_enemy_turned_around" ) )
						{
							self StopAnimScripted();
							level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_pounce_fail2" );
							wait( 1 );
							self gun_remove();
							self waittillmatch( "single anim", "end" );
							self Kill();
						}
						else
						{
							self.ignoreall	   = false;
							self.favoriteenemy = level.player;
						}
					}
					else
					{
						self StopAnimScripted();
						level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_pounce_fail" );
						wait( 1 );
						self gun_remove();
						self waittillmatch( "single anim", "end" );
						self Kill();
					}
				}
				else
				{
					self.ignoreall	   = false;
					self.favoriteenemy = level.player;
				}
			}
			else
			{
				level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_pounce" );
				wait( 1 );
				self gun_remove();
				self waittillmatch( "single anim", "end" );
				self Kill();
			}
		}
		else
		{
			level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_pounce" );
			wait( 1 );
			self gun_remove();
			self waittillmatch( "single anim", "end" );
			self Kill();
		}

	}
	if ( self.script_noteworthy == "guy2" )
	{
		level.player_knife_throw_enemy = self;
		level.rappel_entry_anim_struct anim_first_frame_solo( self, "player_knife_throw_enemy_pounce" );
		self Hide();
		flag_wait( "player_pounce" );
		self Show();
		thread player_knife_throw_enemy();
		
		flag_wait_any( "player_throws_knife", "player_failed_to_throw_knife", "player_throws_knife_fail" );
		
		if ( flag( "player_throws_knife" ) )
		{
		
			thread maps\cornered_audio::aud_invert( "throw" );
			self StopAnimScripted();
			node = GetNode( "knife_throw_enemy_node", "targetname" );
			self set_goal_radius( 8 );
			self SetGoalNode( node );
			self.deathanim	= %cornered_inv_tkdn_death_guy2;
			thread maps\cornered_audio::aud_invert( "hit" );
			wait( 0.5 );
			//flag_wait( "knife_is_touching_enemy" );
			self Kill();
			flag_set( "player_knife_throw_enemy_dead" );
		}
		else
		{
			wait( 1 );
			self Shoot(	 );
			wait( 0.2 );
			self Shoot(	 );
			wait( 0.1 );
			self Shoot(	 );
			wait( 0.1 );
			level.player Unlink();
			level.player Kill();

		}
	}
	if ( self.script_noteworthy == "guy3" )
	{
		self Hide();
		level.rappel_entry_anim_struct anim_first_frame_solo( self, "rorke_inverted_kill_enemy_pounce" );
		flag_wait( "player_pounce" );
		self Show();
		thread rorke_inverted_kill_enemy();
		
		flag_wait( "rorke_inverted_kill" );
		self StopAnimScripted();
		waitframe();
		self.deathanim	= %cornered_inv_tkdn_death_guy3;
		self Kill();
	}	
}

allow_inverted_kill( ent )
{
	flag_set( "player_can_start_inverted_kill" );
}

player_inverted_kill_enemy_anims()
{	
	level endon( "player_pounce" );
	level endon( "inverted_kill_fail_trigger" );
	
	self.walkin_anim = true;
	level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_walkin" );
	wait( 0.1 ); //this wait must be here for the anim_set_rate_single to work
	self anim_self_set_time( "player_inverted_kill_enemy_walkin", .12 );
	anim_set_rate_single( self, "player_inverted_kill_enemy_walkin", 1.65 );
	//flag_wait( "player_can_start_inverted_kill" );
	//anim_set_rate_single( self, "player_inverted_kill_enemy_walkin", 1 );
	self waittillmatch( "single anim", "end" );
	self.walkin_anim = undefined;
	level.rappel_entry_anim_struct thread anim_loop_solo( self, "player_inverted_kill_enemy_idle", "stop_player_inverted_kill_enemy_idle" );
	flag_wait( "player_pounce" );
}

player_inverted_kill_enemy_fail_anim()
{
	//level endon( "player_initiated_pounce" );
	level endon( "player_pounce" );
	
	level.rappel_entry_anim_struct thread anim_single_solo( self, "player_inverted_kill_enemy_pounce_alert" );
	wait( 0.01 );
	thread player_pushes_too_far();
	//anim_set_rate_internal( "player_inverted_kill_enemy_pounce_alert", .5 );
	
	animation = self getanim( "player_inverted_kill_enemy_pounce_alert" );
	while ( self GetAnimTime( animation ) < 0.35 )
	{
		wait( 0.05 );
	}
	
	flag_set( "inverted_kill_enemy_started_turning_around" );
	
	while ( self GetAnimTime( animation ) < 0.45 )
	{
		wait( 0.05 );
	}
	
	flag_set( "inverted_kill_enemy_turned_around" );
	
	thread inverted_kill_enemy_kills_player();
	
	self waittillmatch( "single anim", "end" );
	
	flag_set( "player_inverted_kill_enemy_pounce_fail_end" );
	level.rappel_entry_anim_struct thread anim_last_frame_solo( self, "player_inverted_kill_enemy_pounce_alert" );
}

player_pushes_too_far()
{
	level endon( "player_pounce" );
	level endon( "player_inverted_kill_enemy_pounce_fail_end" );
	
	//flag_wait_either( "inverted_kill_fail_kill_player", "inverted_kill_enemy_started_turning_around" );
	flag_wait( "inverted_kill_fail_kill_player" );
	anim_set_rate_internal( "player_inverted_kill_enemy_pounce_alert", 1.5 );
}

inverted_kill_enemy_kills_player()
{
	MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), level.player.origin + ( 0, 0, 64 ) );
	wait 0.2;
	MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), level.player.origin + ( 0, 0, 64 ) );
	wait 0.2;
	MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), level.player.origin + ( 0, 0, 64 ) );
	wait 0.2;
	MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), level.player.origin + ( 0, 0, 64 ) );
				
	level.player Kill();
}

player_knife_throw_enemy()
{
	level endon( "player_throws_knife" );
	
	wait( 1 );
	level.rappel_entry_anim_struct thread anim_single_solo( self, "player_knife_throw_enemy_pounce" );
	wait( 4 );
	flag_set( "player_failed_to_throw_knife" );
	
	self waittillmatch( "single anim", "end" );
	node = GetNode( "knife_throw_enemy_node", "targetname" );
	self SetGoalNode( node );
}

rorke_inverted_kill_enemy()
{
	level endon( "rorke_inverted_kill" );
	
	wait( 1 );
	level.rappel_entry_anim_struct anim_single_solo( self, "rorke_inverted_kill_enemy_pounce" );
	node = GetNode( "rorke_inverted_kill_enemy_node", "targetname" );
	self SetGoalNode( node );
}

autosave_past_balcony()
{
	flag_wait( "balcony_enemies_killed" );
	thread autosave_now_silent();
}

allies_inverted_rappel_vo()
{
	//Merrick: Hook up to the ropes.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_hookuptothe" );
	
	//Merrick: Move it, kid.
	//Merrick: Come on, hook up!
	nag_lines = make_array( "cornered_mrk_moveitkid", "cornered_mrk_comeonhookup" );
	thread nag_until_flag( nag_lines, "player_exiting_building", 10, 15, 5 );
	
	flag_set( "exit_building_ready" );
	flag_wait( "player_has_exited_the_building" );
	
	flag_wait( "player_ready_to_deploy_virus" );
	//Merrick: Kill the lights.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_killthelights" );
	
	//Merrick: Activate the virus.
	//Merrick: Kill the lights.
	nag_lines	= make_array( "cornered_mrk_activatethevirus",  "cornered_mrk_killthelights" );
	thread nag_until_flag( nag_lines, "player_deployed_virus", 10, 15, 5 );
	
	flag_wait( "player_deployed_virus" );
	wait( 3 );
	flag_set( "spawn_balcony_enemies" );
	flag_set( "rappel_down_ready" );

	//Hesh: Beautiful.
	level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_beautiful" );
	
	flag_wait( "balcony_enemies_on_balcony" );
	//Hesh: Two on the left balcony.
	level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_twoontheleft" );
	//Merrick: Move down and take 'em out.
	level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_mrk_movedownandtake" );
	
	flag_wait_either( "balcony_enemies_killed", "player_is_past_balcony" );
	wait( 0.25 );
	if ( flag( "player_is_past_balcony" ) )
	{
		if ( flag( "player_is_past_balcony_and_enemies_are_alive" ) )
		{
			//Merrick: I've got 'em. 
			level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_ivegotem" );
		}
	}
	else if ( flag( "balcony_enemies_killed" ) )
	{
		//Hesh: Targets down.
		level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_targetsdown" );
	}
	
	thread sleeping_enemy_below_vo();
	thread autosave_past_balcony();
	
	flag_wait( "spawn_inverted_kill_enemies" );
	wait( 0.25 );
	//Merrick: One right below you.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_onerightbelowyou" );
	wait( 0.5 );
	//Merrick: Move above him.  We'll do this quietly.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_movedownabovehim" );
	
	flag_wait( "start_inverted_kill_prompting" );
	//Merrick: Alright, take him out.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_alrighttakehimout" );
	/*
	if ( flag( "player_not_in_inverted_kill_volume" ) )
	{
		temp_dialogue( "Rorke", "Get into position above him.", .5 );
	}
	else
	{
		temp_dialogue( "Rorke", "Alright, take him out.", .5 );
	}
	*/
	thread inverted_kill_too_close_vo();
	
	flag_wait( "player_knife_throw_enemy_dead" );
	//flag_wait( "knife_is_touching_enemy" );
	wait( 5 );
	
	//--IN NOTETRACKS NOW
	//Merrick: Remember, we gotta shut down the elevators, seal off his chance to bolt
	//level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_rememberwegottashut" );
	//Hesh: I know the plan. I’ve got the main bank in the west wing.
	//level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_iknowtheplan" );
	//Merrick: We’ll rendezvous in the junction to cut the secondaries.
	//level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_wellrendezvousinthe" );
	//Merrick: Rook, on me.
	//level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_mrk_rookonme" );
}

sleeping_enemy_below_vo()
{
//	level endon( "start_inverted_kill_prompting" );
//	
//	temp_dialogue( "Rorke", "Last Call.", 2 );
}

inverted_kill_too_close_vo()
{
	level endon( "player_initiated_pounce" );
	
	flag_wait( "inverted_kill_too_close_vo" );
	
	//Merrick: Not too close.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_nottooclose" );

}

allies_inverted_rappel_movement()
{
	if ( !IsDefined( level.rappel_anim_struct ) )
	{
		level.rappel_anim_struct = GetEnt( "allies_rappel_struct_stealth", "targetname" );
	}
	if ( !IsDefined( level.building_entry_exit_anim_struct ) )
	{
		level.building_entry_exit_anim_struct = getstruct( "rappel_stealth_building_entry_exit_anim_struct", "targetname" );
	}
	
	if ( IsDefined( level.inverted_rappel_startpoint ) )
	{
		if ( self.animname == "baker" )
		{
			//level.building_entry_exit_anim_struct thread anim_single_solo( self, "cnd_rappel_stealth_exit_bldg_" + self.animname );
			//waitframe();
			//self SetAnimTime( getanim( "cnd_rappel_stealth_exit_bldg_" + self.animname ), 1.0 );
			level.building_entry_exit_anim_struct thread anim_loop_solo( self, "cnd_rappel_inverted_idle_" + self.animname, "stop_loop" );
		}
	}
	
	flag_wait( "player_has_exited_the_building" );

	level.building_entry_exit_anim_struct notify( "stop_loop" ); //this stops both rorke and baker's anims
	
	if ( self.animname == "rorke" )
	{
		self inverted_rappel_movement_rorke();
	}
	else
	{
		self inverted_rappel_movement_baker();
	}
	
}

inverted_rappel_movement_rorke()
{
	inverted_rappel_start_rorke_struct = getstruct( "inverted_rappel_start_rorke", "targetname" );
	inverted_rappel_start_rorke_struct thread anim_single_solo( self, "cornered_inv_run_stop" );
	wait( 0.25 );
	flag_set( "player_ready_to_deploy_virus" );	
	self waittillmatch( "single anim", "end" );
	
	self thread anim_loop_solo( self, "cornered_inv_idle", "stop_loop" );
	
	flag_wait( "player_deployed_virus" );
	wait( 3 );
	self notify( "stop_loop" );			
	self anim_single_solo( self, "cornered_inv_run_start" );
	self thread anim_loop_solo( self, "cornered_inv_run", "stop_loop" );
	wait( 0.5 );
	self notify( "stop_loop" );
	self anim_single_solo( self, "cornered_inv_run_stop_aim_left" );
	
	self thread anim_loop_solo( self, "cornered_inv_idle_rorke", "stop_loop" );
	
	flag_wait_either( "balcony_enemies_killed", "player_is_past_balcony" );
	if ( flag( "player_is_past_balcony" ) )
	{
		self notify( "stop_loop" );
		waittillframeend;	
		inverted_rappel_balcony_teleport_rorke = getstruct( "inverted_rappel_balcony_teleport_rorke", "targetname" );
		inverted_rappel_balcony_teleport_rorke anim_first_frame_solo( self, "cornered_inv_run_start" );
	}
	else if ( flag( "balcony_enemies_killed" ) )
	{
		wait( 1 );
		self notify( "stop_loop" );
		waittillframeend;
	}
	
	self inverted_rappel_ally_movement();
	
	if ( flag( "player_initiated_pounce" ) )
	{
		self notify( "stop_loop" );
		waittillframeend;
		self StopAnimScripted();
		level.rappel_entry_anim_struct anim_first_frame_solo( self, "cornered_inv_tkdn_pounce_rorke" );
	}
	else
	{
		self knife_out_rorke_anims();
		if ( flag( "player_initiated_pounce" ) )
		{
			self notify( "stop_loop" );
			waittillframeend;
			self StopAnimScripted();
			level.rappel_entry_anim_struct anim_first_frame_solo( self, "cornered_inv_tkdn_pounce_rorke" );
		}
	}
	
	flag_wait( "player_knife_throw_enemy_dead" );
	//flag_wait( "knife_is_touching_enemy" );
	self notify( "stop_loop" );
	waittillframeend;
	self StopAnimScripted();
	
	if ( !flag( "inverted_kill_knife_rorke" ) )
	{
		level.rorke_inverted_kill_knife = Spawn( "script_model", ( 0, 0, 0 ) );
		level.rorke_inverted_kill_knife SetModel( "weapon_parabolic_knife" );
		level.rorke_inverted_kill_knife LinkTo( level.allies[ level.const_rorke ], "TAG_INHAND", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	}
	
	self.ignoreall = 1;
	self.ignoreme  = 1;
	level.rappel_entry_anim_struct anim_single_solo( self, "cornered_inv_tkdn_pounce_rorke" );
	
	flag_set( "inverted_rorke_done" );
}

knife_out_rorke_anims()
{
	level endon( "player_initiated_pounce" );
	
	self notify( "stop_loop" );
	waittillframeend;
	level.rappel_entry_anim_struct anim_single_solo( self, "cornered_inv_run_drift_right_rorke" );
	self thread anim_loop_solo( self, "cornered_inv_idle", "stop_loop" );
	
	if ( flag( "spawn_inverted_kill_enemies" ) )
	{
		self notify( "stop_loop" );
		waittillframeend;
		self anim_single_solo( self, "cornered_inv_knife_out_rorke" );
		self thread anim_loop_solo( self, "cornered_inv_knife_idle_rorke", "stop_loop" );
		
	}
	else
	{
		flag_wait( "spawn_inverted_kill_enemies" );
		wait( 1 );
		self notify( "stop_loop" );
		waittillframeend;
		self anim_single_solo( self, "cornered_inv_knife_out_rorke" );
		self thread anim_loop_solo( self, "cornered_inv_knife_idle_rorke", "stop_loop" );
	}
}

spawn_rorke_inverted_kill_knife( ent )
{
	//self Attach( "weapon_parabolic_knife", "TAG_INHAND" );
	level.rorke_inverted_kill_knife = Spawn( "script_model", ( 0, 0, 0 ) );
	level.rorke_inverted_kill_knife SetModel( "weapon_parabolic_knife" );
	level.rorke_inverted_kill_knife LinkTo( level.allies[ level.const_rorke ], "TAG_INHAND", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	flag_set( "inverted_kill_knife_rorke" );
}

inverted_rappel_movement_baker()
{	
					   //   guy    anime 						    
	self anim_single_solo( self , "cornered_inv_run_start" );
	self anim_single_solo( self , "cornered_inv_run_stop_aim_left" );
	
	self inverted_rappel_ally_idles( "balcony_enemies_on_balcony", "cornered_inv_idle", "cornered_inv_idle_fidgit_1" );
	self notify( "stop_loop" );
	
	self thread anim_loop_solo( self, "cornered_inv_idle_baker", "stop_loop" );
	flag_wait( "balcony_enemies_killed" );
	self notify( "stop_loop" );
	self thread anim_loop_solo( self, "cornered_inv_idle", "stop_loop" );
	
	flag_wait_either( "balcony_enemies_killed", "player_is_past_balcony" );
	if ( flag( "player_is_past_balcony" ) )
	{
		self notify( "stop_loop" );
		waittillframeend;	
		inverted_rappel_balcony_teleport_baker = getstruct( "inverted_rappel_balcony_teleport_baker", "targetname" );
		inverted_rappel_balcony_teleport_baker anim_first_frame_solo( self, "cornered_inv_run_start" );
	}
	else if ( flag( "balcony_enemies_killed" ) )
	{
		wait( 2 );
		self notify( "stop_loop" );
		waittillframeend;
	}

	self inverted_rappel_ally_movement();
	
	if ( flag( "player_initiated_pounce" ) )
	{
		self notify( "stop_loop" );
		waittillframeend;
		self StopAnimScripted();
		level.rappel_entry_anim_struct anim_first_frame_solo( self, "cornered_inv_tkdn_pounce_baker" );
	}
	
	flag_wait( "player_knife_throw_enemy_dead" );
	//flag_wait( "knife_is_touching_enemy" );
	self notify( "stop_loop" );
	waittillframeend;

	self.ignoreall = 1;
	self.ignoreme  = 1;
	level.rappel_entry_anim_struct anim_single_solo( self, "cornered_inv_tkdn_pounce_baker" );

	flag_set( "inverted_baker_done" );
	
}

inverted_rappel_ally_idles( flag_to_end_on, idle, fidget )
{
	level endon( flag_to_end_on );

	while ( 1 )
	{
		self thread anim_loop_solo( self, idle, "stop_loop" );
		wait( RandomFloatRange( 0.5, 2.0 ) );
		self notify( "stop_loop" );
		waittillframeend;
		self anim_single_solo( self, fidget );
	}
}

inverted_rappel_ally_movement()
{
	level endon( "player_initiated_pounce" );
	
	self anim_single_solo( self, "cornered_inv_run_start" );
	self thread anim_loop_solo( self, "cornered_inv_run", "stop_loop" );
	
	volume = GetEnt( "inverted_rappel_stop_volume_1", "targetname" );
	self move_to_volume( volume );
	
	if ( !flag( "inverted_rappel_start_ally_move_1" ) )
	{
		self notify( "stop_loop" );
		waittillframeend;
		self anim_single_solo( self, "cornered_inv_run_stop" );
		self thread anim_loop_solo( self, "cornered_inv_idle", "stop_loop" );
		
		flag_wait( "inverted_rappel_start_ally_move_1" );
		wait( RandomFloatRange( 0.0, 0.25 ) );
		self notify( "stop_loop" );
		waittillframeend;
		
		self anim_single_solo( self, "cornered_inv_run_start" );
		self thread anim_loop_solo( self, "cornered_inv_run", "stop_loop" );
	}
	
	if ( self.animname == "rorke" )
	{
		volume = GetEnt( "inverted_rappel_rorke_stop_volume", "targetname" );
		self move_to_volume( volume );
	}
	else
	{
	
		volume = GetEnt( "inverted_rappel_stop_volume_2", "targetname" );
		self move_to_volume( volume );
		
		if ( !flag( "inverted_rappel_start_ally_move_2" ) )
		{
			self notify( "stop_loop" );
			waittillframeend;
			self anim_single_solo( self, "cornered_inv_run_stop" );
			self thread anim_loop_solo( self, "cornered_inv_idle", "stop_loop" );
			
			flag_wait( "inverted_rappel_start_ally_move_2" );
			wait( RandomFloatRange( 0.0, 0.25 ) );
			self notify( "stop_loop" );
			waittillframeend;
			
			self anim_single_solo( self, "cornered_inv_run_start" );
			self thread anim_loop_solo( self, "cornered_inv_run", "stop_loop" );
		}
		
		volume = GetEnt( "inverted_rappel_stop_volume", "targetname" );
		self move_to_volume( volume );
	
		self notify( "stop_loop" );
		waittillframeend;
		self anim_single_solo( self, "cornered_inv_run_stop" );
		self thread anim_loop_solo( self, "cornered_inv_idle", "stop_loop" );
	}
}

move_to_volume( volume )
{
	if ( !( self IsTouching( volume ) ) )
	{
		while ( 1 )
		{
			if ( self IsTouching( volume ) )
			{
				break;
			}
			wait( 0.05 );
		}
	}
}

/*
inverted_rappel_ally_movement()
{
	self anim_single_solo( self, "cornered_inv_run_start" );
	self thread anim_loop_solo( self, "cornered_inv_run", "stop_loop" );
	
	volume = GetEnt( "inverted_rappel_stop_volume", "targetname" );

	if ( !( self IsTouching( volume ) ) )
	{
		while ( 1 )
		{
			if ( self IsTouching( volume ) )
			{
				break;
			}
			wait( 0.05 );
		}
	}
	
	self notify( "stop_loop" );
	waittillframeend;
	self anim_single_solo( self, "cornered_inv_run_stop" );
	self thread anim_loop_solo( self, "cornered_inv_idle", "stop_loop" );
}

*/
rorke_inverted_kill( rorke )
{
	flag_set( "rorke_inverted_kill" );
	thread maps\cornered_audio::aud_invert( "r_pounce" );
	
	if ( GetDvar( "raven_demo" ) == "1" )
	{
		wait 4;
		
		SetSavedDvar( "ui_nextMission", "0" );
		ChangeLevel( "", false, 2 );
	}
}

rorke_inverted_kill_knife_putaway( rorke )
{
	level.rorke_inverted_kill_knife thread entity_cleanup();
	
	fireworks_stop();
	waitframe();
	thread fireworks_courtyard();
}

inverted_baker_door( baker )
{
	rig = spawn_anim_model( "courtyard_entry" );
	
	door1		 = GetEnt( "cy_entry_door1", "targetname" );
	door1_handle = GetEnt( "cy_entry_door1_handle", "targetname" );
	door2		 = GetEnt( "cy_entry_door2", "targetname" );
	
	door1_handle LinkTo( door1 );
	
	level.rappel_entry_anim_struct anim_first_frame_solo( rig, "cornered_inv_tkdn_doors" );
	
	door1 LinkTo( rig, "j_prop_1" );
	door2 LinkTo( rig, "j_prop_2" );
	
	level.rappel_entry_anim_struct anim_single_solo( rig, "cornered_inv_tkdn_doors" );
}