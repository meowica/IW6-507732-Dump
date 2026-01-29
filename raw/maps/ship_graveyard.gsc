#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

#include maps\ship_graveyard_util;
#include maps\ship_graveyard_code;

main()
{
	level.shark_functions = [];
	level.shark_functions[ "init" ] = animscripts\shark\shark_init::main;
	level.shark_functions[ "move" ] = animscripts\shark\shark_move::main;
	level.shark_functions[ "stop" ] = animscripts\shark\shark_stop::main;
	level.shark_functions[ "pain" ] = animscripts\shark\shark_pain::main;
	level.shark_functions[ "scripted" ] = animscripts\shark\shark_scripted::main;
	level.shark_functions[ "scripted_init" ] = animscripts\shark\shark_scripted::init;
	level.shark_functions[ "reactions" ] = animscripts\shark\shark_reactions::main;
	level.shark_functions[ "flashed" ] = animscripts\shark\shark_flashed::main;
	level.shark_functions[ "death" ] = animscripts\shark\shark_death::main;
	level.shark_functions[ "combat" ] = animscripts\shark\shark_combat::main;
	
	maps\_player_rig::init_player_rig( "viewhands_player_udt" );
	intro_screen_create( &"SHIP_GRAVEYARD_INTROSCREEN_LINE_1", &"SHIP_GRAVEYARD_INTROSCREEN_LINE_5", &"SHIP_GRAVEYARD_INTROSCREEN_LINE_2" );
	intro_screen_custom_func( ::custom_intro_screen_func );
	
	level.debris = [ "shpg_machinery_baggage_container_dmg" ];
	foreach ( item in level.debris )
		PreCacheModel( item );

	PrecacheItem( "remote_torpedo_tablet" );
	PrecacheItem( "underwater_torpedo" );
	
	PreCacheModel( "vehicle_boat_underneath_1" );
	PreCacheModel( "vehicle_boat_underneath_2" );
	PreCacheModel( "vehicle_mini_sub_iw6" );
	PreCacheModel( "body_seal_udt_dive_a" );
	PreCacheModel( "vehicle_lcs" );
	PreCacheModel( "vehicle_lcs_flir" );
	PreCacheModel( "vehicle_lcs_destroyed_front" );
	PreCacheModel( "vehicle_lcs_destroyed_back" );

	PreCacheModel( "shpg_udt_headgear_player_a" );                       
	
	PreCacheModel( "fullbody_tigershark" );	
	PreCacheModel( "vehicle_mi_28_destroyed" );		
	PreCacheModel( "weapon_parabolic_knife" );
	PreCacheModel( "viewmodel_knife" );
	PreCacheModel( "com_barrel_benzin2" );
	PreCacheModel( "shpg_wrkdoor_a1_obj" );
	
	PreCacheModel( "shpg_lighthouse_top" );
	PreCacheModel( "shpg_lighthouse_glass" );
	PreCacheModel( "shpg_lighthouse_glass_broken" );
	
	PreCacheModel( "weapon_underwater_torch" );
	PreCacheModel( "old_wood_churnstick_01" );
	PreCacheModel( "props_scuba_hose_a" );
	PreCacheModel( "viewmodel_torpedo" );
	
	PreCacheModel( "shpg_dbreach_pipe_a" );
	
	PreCacheModel( "shpg_viewmodel_scuba_mask_cr01" );
	PreCacheModel( "shpg_viewmodel_scuba_mask_cr02" );
	PreCacheModel( "shpg_viewmodel_scuba_mask_cr03" );
	
	PreCacheModel( "viewmodel_underwater_torch" );
	
	PreCacheModel( "shpg_wrkdoor_a1_normal" );
	PreCacheModel( "shpg_wrkdoor_a1_broken01" );
	PreCacheModel( "shpg_wrkdoor_a1_broken02" );
	
	PreCacheModel( "torpedo_crtplane" );
	
	PreCacheShellShock( "depth_charge_hit" );
	PreCacheShellShock( "sonar_ping" );
	PreCacheShellShock( "sonar_ping_light" );
	PreCacheShellShock( "nearby_crash_underwater" );
	PreCacheShellShock( "shipg_player_drown" );
	
	PreCacheRumble( "damage_light" );
	PreCacheRumble( "damage_heavy" );
	PreCacheRumble( "tank_rumble_fading" );
	PreCacheRumble( "subtle_tank_rumble" );
	PreCacheRumble( "littoral_ship_rumble" );
	PreCacheRumble( "heavy_3s" );
	PreCacheRumble( "light_1s" );
	
	PrecacheString( &"SHIP_GRAVEYARD_HINT_TORPEDO" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_DROWN" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_X" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_RT" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_SPRINT" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_DOWN" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_UP" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_DOWN2" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_UP2" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_TRENCH" );
	PrecacheString( &"SHIP_GRAVEYARD_E3_TIME" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_FLASHLIGHT" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_WELD" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_DIVE" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_TGT_NOTFOUND" );
	PrecacheString( &"SHIP_GRAVEYARD_HINT_TGT_BLOCKED" );
	
	Precacheshader( "gasmask_overlay" );
	Precacheshader( "halo_overlay_scuba_steam" );
	Precacheshader( "halo_overlay_water" );

	PreCacheShader( "overlay_grain" );
	PreCacheShader( "torpedo_center" );
	PreCacheShader( "torpedo_centerbox" );
	PreCacheShader( "torpedo_centerline" );
	PreCacheShader( "torpedo_databit_1" );
	PreCacheShader( "torpedo_databit_2" );
	PreCacheShader( "torpedo_databit_3" );
	PreCacheShader( "torpedo_frame_center" );
	PreCacheShader( "torpedo_frame_center_bottom" );
	PreCacheShader( "torpedo_frame_edge" );
	PreCacheShader( "torpedo_frame_edge_l" );
	PreCacheShader( "torpedo_frame_edge_r" );
	PreCacheShader( "torpedo_frame_lines_ll" );
	PreCacheShader( "torpedo_frame_lines_lr" );
	PreCacheShader( "torpedo_frame_lines_ul" );
	PreCacheShader( "torpedo_frame_lines_ur" );
	PreCacheShader( "torpedo_horizonline" );
	PreCacheShader( "torpedo_sidebracket_l" );
	PreCacheShader( "torpedo_sidebracket_r" );
	PreCacheShader( "apache_targeting_circle" );
	PreCacheShader( "white" );
	
	maps\_swim_player::init_player_swim();
	maps\_swim_ai::init_ai_swim();
	maps\_drone_ai::init();
		
	template_level( "ship_graveyard" );
	
	add_hint_string( "hint_down", &"SHIP_GRAVEYARD_HINT_DOWN2", ::hintDown_test );
	add_hint_string( "hint_up", &"SHIP_GRAVEYARD_HINT_UP2", ::hintUp_test );
	add_hint_string( "hint_sprint", &"SHIP_GRAVEYARD_HINT_SPRINT", ::hintSprint_test );
	add_hint_string( "hint_flashlight", &"SHIP_GRAVEYARD_HINT_FLASHLIGHT", ::hintFlashlight_test );
	add_hint_string( "hint_notfound", &"SHIP_GRAVEYARD_HINT_TGT_NOTFOUND" );
	add_hint_string( "hint_blocked", &"SHIP_GRAVEYARD_HINT_TGT_BLOCKED" );
	
		   //   msg 				    func 				    loc_string    optional_func

	add_start( "start_above_water", ::start_test_above_1	, undefined, ::above_water_start_setup );
	add_start( "start_above_water_nofx", ::start_test_above_2	, undefined );
	add_start( "start_greenlight"	 , ::start_greenlight	 , undefined   );		   
	add_start( "e3", ::start_e3	, undefined );
	add_start( "start_tutorial"		 , ::start_tutorial		 , undefined   , ::tutorial_setup );
	add_start( "start_swim"			 , ::start_swim			 , undefined   , ::intro_setup );
	add_start( "start_wreck_approach", ::start_wreck_approach, undefined   , ::wreck_approach_setup );
	add_start( "start_small_wreck"	 , ::start_small_wreck	 , undefined   , ::small_wreck_setup );
	add_start( "start_stealth_1"	 , ::start_stealth_1	 , undefined   , ::stealth_area_1_setup );
	add_start( "start_stealth_2"	 , ::start_stealth_2	 , undefined   , ::stealth_area_2_setup );
	add_start( "start_cave"			 , ::start_cave			 , undefined   , ::cave_setup );
	add_start( "start_sonar"		 , ::start_sonar		 , undefined   , ::sonar_setup );
	add_start( "start_sonar_mines"	 , ::start_sonar_mines	 , undefined   , ::sonar_mine_setup );
	
	add_start( "start_new_trench"		 , ::start_new_trench		 , undefined   , ::new_trench_setup );
	add_start( "start_new_canyon"		 , ::start_new_canyon		 , undefined   , ::new_canyon_setup );
	add_start( "start_depth_charges"	 , ::start_depth_charges	 , undefined   , ::depth_charges_setup );
	
	add_start( "start_big_wreck"	 , ::start_big_wreck	 , undefined   , ::big_wreck_setup );
	add_start( "start_big_wreck_2"	 , ::start_big_wreck_2	 , undefined   , ::big_wreck_2_setup );
	
	add_start( "end_tunnel_swim"	 , ::start_end_tunnel_swim	 , undefined   , ::end_tunnel_swim );
	add_start( "end_surface" 		 , ::start_end_surface	 , undefined   , ::end_surface );

	//   msg 		      func 			    loc_string   
	add_start( "test_area_1"   , ::start_test_1	 , undefined );
	add_start( "test_area_2"   , ::start_test_2	 , undefined );
	
	if ( greenlight_check() )
		set_default_start( "e3" );
	else
		set_default_start( "start_above_water" );
	
	maps\ship_graveyard_anim::main();
	
	if ( GetDvar( "createfx", "" ) == "on" )
	{
		level.struct_class_names = undefined;
		struct_class_init();
		node = getstruct( "lighthouse_node", "targetname" );
		
		front = spawn( "script_model", (0,0,0) );
		front setModel( "vehicle_lcs_destroyed_front" );
		front.animname = "lcs_front";
		front setAnimTree();
		
		back = spawn( "script_model", (0,0,0) );
		back setModel( "vehicle_lcs_destroyed_back" );
		back.animname = "lcs_back";
		back setAnimTree();
	
		node anim_first_frame( [ front, back ], "lighthouse_fall" );
		level.struct_class_names = undefined;
	}

	maps\createart\ship_graveyard_art::main();
	maps\ship_graveyard_fx::main();
	maps\ship_graveyard_precache::main();
	thread maps\ship_graveyard_fx::mask_interactives();
	maps\_load::main();

	maps\ship_graveyard_audio::main();
	
	init_level_flags();
	paired_death_restart();
	thread set_dof_for_player_mask();
	
	maps\_swim_player::init_player_swim_anims();

	level.water_level_z = get_target_ent( "water_level_org" );
	level.water_level_z = level.water_level_z.origin[2];	
	level.default_goalradius = 64;
	
	maps\ship_graveyard_stealth::stealth_init();
	level.player thread maps\ship_graveyard_stealth::player_stealth();
	
	level.balloon_count = 0;
	
	array_thread( getentarray( "salvage_cargo", "script_noteworthy" ), ::salvage_cargo_setup );
	array_thread( getentarray( "moveup_when_clear", "targetname" ), ::move_up_when_clear );
	array_thread( getentarray( "trigger_depth_charges", "targetname" ), ::trigger_depth_charges );
	array_thread( getentarray( "dyn_balloon", "targetname" ), ::dyn_balloon_think );
	array_thread( getentarray( "dyn_balloon_new", "targetname" ), ::new_dyn_balloon_think );
	array_thread( getentarray( "shark_go", "targetname" ), ::shark_go_trig );
	array_thread( getEntArray( "trigger_multiple_fx_volume_off", "classname" ), ::trigger_multiple_fx_volume_off_target );
	
	array_spawn_function( Vehicle_GetSpawnerArray(), ::vehicle_setup );
	array_spawn_function( GetSpawnerArray(), ::make_swimmer );
	array_spawn_function( GetSpawnerArray(), ::add_headlamp );
	array_spawn_function( GetSpawnerArray(), maps\ship_graveyard_stealth::ai_stealth_init );
	array_spawn_function( GetSpawnerArray(), ::track_death );
	array_spawn_function( GetSpawnerArray(), ::read_parameters );
	array_spawn_function( getEntArray( "actor_test_enemy_shark_dog", "classname" ), ::teleport_to_target );
	array_spawn_function( getEntArray( "actor_test_enemy_shark_dog", "classname" ), maps\_swim_ai::underwater_blood );
		
	array_spawn_function_noteworthy( "jumper", ::jump_into_water );
	
	array_spawn_function_noteworthy( "ground_hug_sdv", ::sdv_silt_kickup );
	array_spawn_function_targetname( "sdv_follow", ::sdv_follow_spotted_react );
	array_spawn_function_targetname( "sdv_follow", ::sdv_patrol_setup );
	array_spawn_function_targetname( "sdv_follow", ::flag_set, "small_wreck_sdv_spawned" );
	array_spawn_function_targetname( "sdv_follow", ::sdv_play_sound_on_entity );
	array_spawn_function_targetname( "sdv_follow_2", ::sdv_patrol_setup );
	array_spawn_function_targetname( "sdv_follow_2", ::sdv_follow_2_passby_audio );
	array_spawn_function_targetname( "stealth_2_sub_1", ::sdv_stealth_2_sub_1_passby_audio );
	array_spawn_function_targetname( "a1_patrol_1", ::a1_patrol_1_setup );
	array_spawn_function_targetname( "a1_patrol_2", ::a1_patrol_1_setup );
	array_spawn_function_targetname( "stealth_1_riser", ::teleport_to_target );
	array_spawn_function_targetname( "stealth_1_zodiac", ::stealth_1_zodiac_setup );
	array_spawn_function_targetname( "stealth_1_riser", ::set_moveplaybackrate, 0.85 );
	array_spawn_function_targetname( "stealth_2_guys", ::teleport_to_target );
	array_spawn_function_targetname( "stealth_2_guys_b", ::teleport_to_target );
	array_spawn_function_targetname( "stealth_2_backup", ::teleport_to_target );
	array_spawn_function_targetname( "sonar_boat_cave", ::littoral_ship_lights );
	array_spawn_function_targetname( "sonar_boat_cave", ::sonar_ping_light_think );
	array_spawn_function_targetname( "sonar_boat_cave", ::sonar_boat_cave_think );
	array_spawn_function_targetname( "sonar_boat_cave", ::sonar_boat_cave_quake );
	array_spawn_function_targetname( "sonar_boat_cave", ::sonar_boat_think );
	//array_spawn_function_targetname( "sonar_boat_cave", ::sonar_boat_audio );
	//array_spawn_function_targetname( "sonar_boat_late", ::sonar_boat_audio );
	array_spawn_function_targetname( "sonar_boat", ::sonar_boat_audio_e3 );
	
	array_spawn_function_targetname( "sonar_boat", ::lcs_setup );
	array_spawn_function_targetname( "sonar_boat_cave", ::lcs_setup );
	array_spawn_function_targetname( "sonar_boat_late", ::lcs_setup );
	
	array_spawn_function_targetname( "intro_shark_model_veh", ::shark_vehicle );
	array_spawn_function_targetname( "big_wreck_shark_model_veh", ::shark_vehicle );
	
	array_spawn_function_targetname( "nc_enemies_1", ::teleport_to_target );
	//array_spawn_function_targetname( "nc_enemies_2", ::teleport_to_target );
	array_spawn_function_targetname( "new_canyon_jump_1", ::canyon_jumper_setup );
	array_spawn_function_targetname( "dc_enemies_1", ::teleport_to_target );

	add_earthquake( "small", 0.3, 0.6, 2048 );
	add_earthquake( "med", 0.6, 0.7, 2048 );
	add_earthquake( "large", 0.7, 1.4, 2048 );
	
	spawn_baker();
	underwater_setup();
	
	CreateThreatBiasGroup( "ignoring_baker" );
	CreateThreatBiasGroup( "baker" );
	
	SetIgnoreMeGroup( "baker", "ignoring_baker" );
	
	level.baker setThreatBiasGroup( "baker" );
	
	
	/#
//		thread music_toggle();
//		thread weapon_toggle();
	#/

	thread sonar_wreck_think();
	thread stealth_2_middle_boat_think();
	thread baker_weld_door();
	thread cave_flashlight_logic();
	
	level.sonar_wreck_crash_after = getentarray( "sonar_wreck_crash_after" ,"targetname" );
	array_call( level.sonar_wreck_crash_after, ::Hide );
	
	maps\_colors::add_cover_node( "Path 3D" );
	maps\_colors::add_cover_node( "Cover Stand 3D" );
	maps\_colors::add_cover_node( "Cover Right 3D" );
	maps\_colors::add_cover_node( "Cover Left 3D" );
	maps\_colors::add_cover_node( "Cover Up 3D" );
	
	CreateThreatBiasGroup( "easy_kills" );
	SetThreatBias( "easy_kills", "allies", 500 );
	CreateThreatBiasGroup( "not_a_threat" );
	SetThreatBias( "not_a_threat", "axis", 10 );
	
	battlechatter_off( "axis" );
	battlechatter_off( "allies" );
	
	level.player notifyOnPlayerCommand( "fire weapon", "+attack" );
	level.oldff_block = getDvar( "ai_friendlyFireBlockDuration" );
	
	level.player notifyOnPlayerCommand( "melee_button_pressed", "+melee" );
	level.player notifyOnPlayerCommand( "melee_button_pressed", "+melee_breath" );
	level.player notifyOnPlayerCommand( "melee_button_pressed", "+melee_zoom" );
	
	level.shark_attack_playbackrate = 6;
	
	// JS: for underwater pained breathing
	level.player.gs.custombreathingtime = 0.85;
	
	torpedo_use_trig = getent("grab_torpedo","targetname");
	torpedo_use_trig trigger_off();
	
}

set_dof_for_player_mask()
{
	level.player SetViewModelDepthOfField( 0, 17.0112 );	
}

custom_intro_screen_func()
{
	flag_Wait( "start_swim" );

	{
		wait( 6 );
		maps\_introscreen::introscreen( true );	
	}		
}

init_level_flags()
{
	flag_init(	"pause_dynamic_dof" );
	flag_init( "greenlight_next_phase" );
	
	flag_init( "start_swim" );
	flag_init( "baker_at_wreck" );
	flag_init( "wreck_approach_guys_dead" );
	flag_init( "clear_to_enter_wreck" );
	flag_init( "small_wreck_sdv_spawned" );
	flag_init( "baker_at_small_wreck" );
	flag_init( "move_to_stealth_1" );
	flag_init( "clear_to_enter_cave" );
	flag_init( "cave_sonar" );
	flag_init( "start_sonar_pings" );
	flag_init( "sonar_clear_to_go" );
	flag_init( "welding_done" );
	flag_init( "start_trench" );
	flag_init( "start_big_wreck" );
	flag_init( "depth_charge_muffle" );
	flag_init( "sonar_boat_explode" );
	flag_init( "mine_moveup" );
	flag_init( "first_damage_state" );
	flag_init( "wreck_tilt" );
	flag_init( "pause_sonar_pings" );
	
	flag_init( "start_new_trench" );
	flag_init( "trench_allow_things_to_crash" );
	
	flag_init( "shark_a_clear" );
	flag_init( "shark_b_clear" );
	flag_init( "shark_a_clear_comeback" );
	flag_init( "shark_b_clear_comeback" );
	flag_init( "shark_b_clear_2" );
	flag_init( "shark_room_player_can_go" );
	flag_init( "shark_eating_player" );
	flag_init( "shark_always_eat_front" );
		
	flag_init( "player_can_rise" );
	flag_init( "player_can_fall" );
	flag_init( "player_can_sprint" );
	flag_init( "ai_ready_to_weld" );
	flag_init( "player_ready_to_weld" );
	
	flag_init( "player_on_torpedo" );
	flag_init( "player_holding_torpedo" );
	
	flag_init("go_to_surface");
	flag_init( "baker_past_sharks" );
	
	flag_init("grabbed_torpedo");
	flag_init("go_into_cave_vo");
	flag_init("to_cave_vo_begin");
	
	flag_init("stop_npc_weld_sfx_loop");
	flag_init("stop_player_weld_sfx_loop");
	
	flag_init("fade_sound_player_torch1");
	flag_init("fade_sound_player_torch2");
	flag_init("fade_sound_player_torch3");
	flag_init("fade_sound_player_torch4");
	flag_init("fade_sound_player_torch5");
	
	flag_init("big_wreck_wait_turnaround");
	flag_init("turn_on_bubbles_after_torpedo");
	

	level.deadly_sharks = [];
	
	//thread greenlight_logic();
}
	
/***************************************************/


start_test_1()
{
	set_start_positions( "test_area_1" );
	flag_set( "start_swim" );
	
	spawn_vehicle_from_targetname_and_drive( "test_sub" );
}

start_test_2()
{
	set_start_positions( "shoot_mines" );
	flag_set( "start_swim" );	
	
	level.player vision_set_fog_changes( "shpg_lcs_detonation", 1 );
	
	thread lcs_exploder_loop();
}

lcs_exploder_loop()
{
	while( 1 )
	{
		exploder( "lighthouse_lcs_detonation" );
		
		wait( 5 );
	}
}

start_test_above_1()
{
//	vision_set_changes("shpg_start_abovewater", 0);
		
	set_start_positions( "test_abovewater_start" );
}

start_e3()
{
//	vision_set_changes("shpg_start_abovewater", 0);
	start_overlay( "white" );
	//thread fade_in(1, "white");
	level.player thread play_sound_on_entity( "scn_player_dive_in" );
		
	SetDvar ("e3", 1);
	SetDvar ("music_enable", 1);

	set_start_positions( "start_tutorial" );
	flag_set( "start_swim" );	
	
	while (level.player.origin[1] < -63523)
		wait 0.1;
	
	fade_out(2, "black");
	
	level notify ("stop_for_e3");
	
	set_start_positions( "sonar_event" );
	level.baker notify( "stop_path" );
	level.baker SetGoalPos(level.baker.origin);
		
	flag_set( "start_swim" );
	flag_set( "inside_cave" );
	
	//thread sonar_setup();
	
	flag_set( "start_sonar" );
	
	thread sonar_boat_e3();
	
	fade_in(2, "black");
}

start_test_above_2()
{
	set_start_positions( "test_abovewater_start" );
	
	level.player DisableWeapons();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player AllowJump( false );
	level.player player_speed_percent( 10, 0.1 );

	
	level.baker set_generic_idle_anim( "surface_swim_idle" );
	level.player_view_pitch_down = getDvar( "player_view_pitch_down" );
	level.player maps\_underwater::player_scuba_mask();
	setSavedDvar( "player_view_pitch_down", 5 );
	level.player EnableSlowAim( 0.5, 0.5 );
	
	bobbers = getentarray( "bobbing_object", "targetname" );
	array_thread( bobbers, maps\ship_graveyard_surface::pitch_and_roll );
	
	level.ground_ref_ent = spawn_Tag_origin();
	level.player PlayerSetGroundReferenceEnt( level.ground_ref_ent );
	level.ground_ref_ent.script_max_left_angle = 8;
	level.ground_ref_ent.script_duration = 2;
	level.ground_ref_ent thread maps\ship_graveyard_surface::pitch_and_roll();
	
	boat = get_target_ent( "start_fishing_boat" );
	boat.script_max_left_angle = 8;
	boat.script_duration = 4;
	boat thread maps\ship_graveyard_surface::pitch_and_roll();
	
	wait( 0.1 );
	level.player FreezeControls( false );
	
}

start_greenlight()
{
//	level.player vision_set_fog_changes("shpg_start_abovewater", 0);
	start_overlay( "black" );
	setDvar( "greenlight", 1 );
	set_start_positions( "start_tutorial" );
	flag_set( "start_swim" );
}

greenlight_logic()
{
	flag_wait( "greenlight_next_phase" );
	
	if ( greenlight_check() )
	{		
		thread new_trench_setup();
		new_canyon_setup();
		depth_charges_setup();
		big_wreck_setup();
		big_wreck_2_setup();
	}
}

start_tutorial()
{
//	level.player vision_set_fog_changes("shpg_start_dive", 0.1);
	
	start_overlay( "white" );
	setDvar( "greenlight", 0 );
	set_start_positions( "start_tutorial" );
	flag_set( "start_swim" );	
}

start_swim()
{
//	level.player vision_set_fog_changes("shpg_start_beautyarea_shallow", 0.1);
		
	set_start_positions( "start_swim" );
	flag_set( "start_swim" );	
}

start_wreck_approach()
{
//	level.player vision_set_fog_changes("shpg_main2", 0.1);
		
	set_start_positions( "start_wreck_approach" );
	flag_set( "start_swim" );

	thread wreck_zodiac_event();
	
	wait( 1 );
	
	while( Distance2d( level.player.origin, level.baker.origin ) < 300 )
		wait( 0.05 );
	
	flag_set( "baker_at_wreck" );
}

start_small_wreck()
{
	set_start_positions( "start_small_wreck" );
	flag_set( "start_swim" );	
	flag_set( "clear_to_enter_wreck" );
}

start_stealth_1()
{
//	level.player vision_set_fog_changes("shpg_main2", 0.1);
		
	set_start_positions( "stealth_area_1" );
	flag_set( "start_swim" );
	flag_set( "move_to_stealth_1" );
	level.baker thread follow_path_and_animate( get_target_ent( "baker_stealth_1_path" ) );
}

start_stealth_2()
{
//	level.player vision_set_fog_changes("shpg_main2", 0.1);
	
	set_start_positions( "stealth_area_2" );
	flag_set( "start_swim" );
	thread baker_move_to_stealth_2();
}

start_cave()
{
//	level.player vision_set_fog_changes("shpg_main2", 0.1);
		
	set_start_positions( "cave_event" );
	flag_set( "start_swim" );
	flag_set( "clear_to_enter_cave" );
}

start_sonar()
{
//	level.player vision_set_fog_changes("shpg_main2", 0.1);
		
	set_start_positions( "sonar_event" );
	
	flag_set( "start_swim" );
	flag_set( "inside_cave" );
	
	thread sonar_boat_e3();
		
	thread sardines_path_sound( "lighthouse_sardines" );	
}


start_sonar_mines()
{
//	level.player vision_set_fog_changes("shpg_main2", 0.1);
		
	set_start_positions( "shoot_mines" );
	flag_set( "start_swim" );
	flag_set( "sonar_clear_to_go" );
	delayThread( 1, ::flag_clear, "sonar_clear_to_go" );
	boat = spawn_vehicle_from_targetname( "sonar_boat_late" );
	boat thread littoral_ship_lights();
	level.sonar_boat = boat;
}

start_trench()
{
	set_start_positions( "trench" );
	flag_set( "start_swim" );

	thread maps\_hud_util::fade_out( 0 );
	delayThread( 0.2, ::flag_set, "start_trench" );
}

start_canyon()
{
	set_start_positions( "canyon" );
	flag_set( "start_swim" );
	maps\ship_graveyard_stealth::stealth_disable();
}

start_big_wreck()
{
//	level.player vision_set_fog_changes("shpg_cruiseshp_ext", 0.1);
		
	set_start_positions( "big_wreck" );
	flag_set( "start_swim" );	

	maps\ship_graveyard_stealth::stealth_disable();
	level.baker.moveplaybackrate = 1.5;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker thread follow_path_and_animate( get_target_ent( "baker_enter_big_wreck_middle" ) );
}

start_big_wreck_2()
{
//	level.player vision_set_fog_changes("shpg_cruiseshp_corridor", 0.1);
		
	set_start_positions( "big_wreck_2" );
	flag_set( "start_swim" );	
	flag_set( "inside_big_wreck" );
	maps\ship_graveyard_stealth::stealth_disable();
//	spawn_vehicles_from_targetname_and_drive( "big_wreck_shark_model_veh" );
	level.baker.moveplaybackrate = 1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	spawner = get_target_ent( "dead_body_spawner" );
	spawner thread dead_body_spawner();
	thread big_wreck_fake_shake();
}

start_new_trench()
{
//	level.player vision_set_fog_changes("shpg_start_chasm_lessfog", 0.1);
		
	set_start_positions( "new_trench" );
	flag_set( "start_swim" );
//	level.player thread vision_set_fog_changes( "shpg_start_chasm", 0.05 );
	thread maps\_hud_util::fade_out( 0 );
	delayThread( 0.2, ::flag_set, "start_new_trench" );
}

start_new_canyon()
{
//	level.player vision_set_fog_changes("shpg_start_chasm_combat", 0.1);
		
	set_start_positions( "new_canyon" );
	flag_set( "start_swim" );
	maps\ship_graveyard_stealth::stealth_disable();
	level.baker thread follow_path_and_animate( get_Target_ent( "new_canyon_start_path" ) , 0 );
}

start_depth_charges()
{
//	level.player vision_set_fog_changes("shpg_cruiseshp_ext", 0.1);
		
	set_start_positions( "depth_charges" );
	flag_set( "start_swim" );
	maps\ship_graveyard_stealth::stealth_disable();
	level.baker set_force_color( "r" );
}

start_end_tunnel_swim()
{
//	level.player vision_set_fog_changes("shpg_cruiseshp_corridor", 0.1);
		
	set_start_positions( "end_tunnel_swim" );
	flag_set( "start_swim" );
	maps\ship_graveyard_stealth::stealth_disable();
	//level.baker set_force_color( "r" );
	
	level.baker.goalradius = 128;
	level.baker.moveplaybackrate = 1.1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker.pathrandompercent = 0;
	level.baker disable_exits();
	level.baker thread anim_generic_run( level.baker, "swimming_idle_to_aiming_move_180" );
	//level.baker setGoalNode( get_target_ent( "baker_prepare_to_leave" ) );
	//trigger_wait_targetname( "baker_prepare_to_leave_trig" );
	wait (0.5);
	level.baker thread dyn_swimspeed_enable();
	level.baker thread follow_path_and_animate( get_target_ent( "baker_end_level_path_start" ) );
	level.baker delayThread( 2, ::enable_exits );
	thread end_dialogue();
	
}

start_end_surface()
{
//	level.player vision_set_fog_changes( "shpg_start_abovewater", 0.1 );
	
	set_start_positions( "end_tunnel_above_surface" );
	maps\ship_graveyard_stealth::stealth_disable();
	//level.baker set_force_color( "r" );
	flag_set( "go_to_surface" );
}

/***************************************************/

above_water_start_setup()
{
	maps\ship_graveyard_surface::main();
}

tutorial_setup()
{
	flag_wait( "start_swim" );
	level.player vision_set_fog_changes("", 0.1);
	
	level.player unlink();
	
	level.baker unlink();
	level.baker anim_stopanimscripted();
	level.baker notify ("kill surface unlink");
	
	if (isdefined(level.player_rig))
	{
		level.player_rig delete();
	}
	    
	setSavedDvar( "player_swimSpeed", 75 );
	
	level.player disableWeapons();
	
	wait( 0.1 );
	//PlayFXOnTag( getfx( "player_dive_bubbles" ), level.player.playerFxOrg, "tag_origin" );
	// put back in if we start underwater for e3
//	if ( greenlight_check() )
//	{
//		wait( 3 );
//	}
	
	thread wreck_zodiac_event();
	
	wait( 0.1 );

	thread tutorial_player_recover();
	
	wait( 0.1 );
	
	thread intro_track_player_gunfire();
	thread sardines_path_sound( "sardines_first_path" );
	
	//level.player setBlurForPlayer( 8, 0 );
	level.player SetWaterSheeting( 1, 2 );
	delaythread( 0.2, ::fade_in_blue, 1, "white" );
//	PlayFXOnTag( getfx( "player_dive_bubbles" ), level.player.playerFxOrg, "tag_origin" );
//	noself_delayCall( 0.5, ::PlayFXOnTag, getfx( "player_dive_bubbles" ), level.player.playerFxOrg, "tag_origin" );
//	noself_delayCall( 1, ::PlayFXOnTag, getfx( "player_dive_bubbles" ), level.player.playerFxOrg, "tag_origin" );
	//level.player delayCall( 1.2, ::setBlurForPlayer, 0, 0.5 );
	level.baker.goalradius = 128;
	level.baker.goalheight = 128;
	level.baker.moveplaybackrate = 1;
	level.baker thread follow_path_and_animate( get_target_ent( "tutorial_path" ) );
	wait( 3 );
	smart_radio_dialogue( "shipg_hsh_descending" );
	wait( 1.5 );
	level.baker.moveplaybackrate = 0.8;
	smart_radio_dialogue( "shipg_hsh_fiftymeters" );
	wait( 3 );
	baker_glint_on();
	smart_radio_dialogue( "shipg_bkr_approach" );
	thread music_play( "mus_shipgrave_stealth1" );		
	level.baker.moveplaybackrate = 1;
		
	
	level.shark_heartbeat_distances = [ 650, 250, 200, 150 ];
}

fade_in_blue( trans_time, shader )
{
	hud = get_optional_overlay( shader );
	hud FadeoverTime( trans_time );
	hud.color = ( 0, 0, 0.4 );
	hud.alpha = 0;
}

intro_setup()
{
	flag_wait( "start_intro" );

	level.baker.moveplaybackrate = 1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker thread dyn_swimspeed_enable();
	
	thread intro_dialgue();
	thread baker_path_to_wreck();
}

wreck_approach_setup()
{
	level endon ("stop_for_e3");
	
	flag_wait( "start_small_wreck" );
	flag_clear( "allow_killfirms" );

	thread delete_fish_in_volume( "fish_start_area" );
	
	level.shark_heartbeat_distances = [ 400, 250, 200, 150 ];
	
	thread baker_approach();
	thread baker_wreck_cleanup();
	thread baker_enter_wreck();
	thread wreck_hint_up();
}

small_wreck_setup()
{
	level endon ("stop_for_e3");
		
	flag_wait( "entering_small_wreck" );
	
	thread wreck_spotted_reaction();
	thread wreck_cargo_surprise();
	thread transition_to_stealth_1();
}

stealth_area_1_setup()
{
	level endon ("stop_for_e3");
		
	if (greenlight_check())
		return;
	
	flag_wait( "start_stealth_area_1" );
	level.baker dyn_swimspeed_disable();
	flag_set( "allow_killfirms" );
	delayThread( 1, ::flag_clear, "no_shark_heartbeat" );
	spawn_vehicle_from_targetname_and_drive( "sdv_follow_2" );
	
	thread stealth_1_encounter();
	thread stealth_1_dialogue();
}

stealth_area_2_setup()
{
	level endon ("stop_for_e3");
		
	if (greenlight_check())
		return;
	
	flag_wait( "start_stealth_area_2" );
	autosave_stealth();
	
	thread stealth_2_encounter();
	thread stealth_2_dialogue();
}

cave_setup()
{
	level endon ("stop_for_e3");
		
	if (greenlight_check())
		return;
	
		
	flag_wait( "clear_to_enter_cave" );	
	autosave_stealth();
	
	level.baker.moveplaybackrate = 1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	
	thread cave_dialogue();
	thread sonar_approach();
	thread cave_dust();
	thread setup_lcs_audio();
}

setup_lcs_audio()
{
	flag_Wait( "cave_sonar" );
	thread sonar_boat_audio();
}

sonar_setup()
{
	flag_wait( "start_sonar" );
	
	foreach( shark in level.deadly_sharks )
	{
		shark delete();
	}
	
	vehicles = getVehicleArray();
	foreach ( v in vehicles )
	{
		if (v.vehicletype != "lcs")
			v delete();
	}
	
	level.baker.pathrandompercent = 0;
	
	SetSavedDvar( "glass_linear_vel", "100 300" );
	thread first_sonar_ping();
	thread weaponized_sonar_pings();
	thread sonar_door_think();
	//thread sonar_boat();
}

sonar_mine_setup()
{
	flag_wait( "start_sonar_mines" );
	array_thread( getentarray( "dyn_balloon", "targetname" ), ::dyn_balloon_delete );
//	thread sonar_mines_dialogue();
//	thread sonar_mines();
	thread torpedo_the_ship();
	waitframe();
	autosave_by_name( "sonar_mines" );
}

new_trench_setup()
{
	flag_wait( "start_new_trench" );	
	
	thread delete_fish_in_volume( "area_1_fx_vol" );
	
	//set_audio_zone("ship_graveyard_rescue", 6 );
	level.player SetClientTriggerAudioZone( "ship_graveyard_rescue", 6 );	
	setsaveddvar( "ai_friendlyFireBlockDuration", 0 );
	thread maps\ship_graveyard_new_trench::main();
	thread base_alarm();
	thread sardines_path_sound( "sardines_after_helicrash", "scn_fish_swim_away_silent");
}

new_canyon_setup()
{
	flag_wait( "start_new_canyon" );	
	setsaveddvar( "ai_friendlyFireBlockDuration", level.oldff_block );
	thread maps\ship_graveyard_new_trench::canyon_main();
}

depth_charges_setup()
{
	flag_wait( "start_depth_charges" );
	setsaveddvar( "ai_friendlyFireBlockDuration", 0 );
	level.baker.baseaccuracy = 3;
	thread depth_charges();
	thread boat_fall_trigs();
	thread sardines_path_sound( "sardines_depthcharges_path", "scn_fish_swim_away_silent" );
}

big_wreck_setup()
{
	flag_wait( "start_big_wreck" );
	
	foreach ( shark in level.deadly_sharks )
		shark delete();
	
	level.deadly_sharks = [];
	
	SetSavedDvar( "glass_linear_vel", "20 40" );
	flag_clear( "_stealth_spotted" );
	setSavedDvar( "player_swimSpeed", 75 );
	flag_set( "depth_charge_muffle" );
	flag_set( "shark_always_eat_front" );
	level.baker.moveplaybackrate = 1;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	
	spawner = get_target_ent( "dead_body_spawner" );
	spawner thread dead_body_spawner();
	
	thread big_wreck_dialogue();
	thread big_wreck_fake_shake();
	thread big_wreck_kill_when_outside();
//	thread big_wreck_encounter();
	thread big_wreck_baker_stealth();
}

big_wreck_2_setup()
{
	level.baker set_battlechatter( false );
	
	thread big_wreck_shark();
	thread shark_room();
	
	flag_wait( "start_big_wreck_2" );	
	flag_set( "shark_always_eat_front" );

	autosave_stealth_silent();
	
	setSavedDvar( "player_swimVerticalSpeed", 55 );	
	
	thread big_wreck_2_dialogue();
	thread big_wreck_collapse();
	
	flag_wait( "player_past_sharks" );
	SetSavedDvar( "glass_linear_vel", "100 300" );
	flag_clear( "depth_charge_muffle" );
	wait( 1 );
	thread random_depth_charges( "depth_charge_constant_2", 4, 8 );
//	thread big_wreck_tilt();
}


