#include common_scripts\utility;
#include maps\_anim;
#include maps\_audio;
#include maps\_hud_util;
#include maps\_utility;
#include maps\_vehicle;
#include maps\patriot_crib_proto_code;


main()
{
	template_level( "patriot_crib_proto" );
	maps\createart\patriot_crib_proto_art::main();
	maps\patriot_crib_proto_fx::main();
	maps\patriot_crib_proto_anim::main();
	maps\_patrol_anims::main();
	
	// Precache
	maps\patriot_crib_proto_precache::main();
	
	PreCacheShader( "black" );
	PreCacheItem( "iw5_pecheneg_mp" );
	PreCacheItem( "iw5_mk14_mp" );
	PreCacheItem( "smoke_grenade_american" );
	
	
	armory_precache();
	npcs_precache();
	
	// System Inits
	maps\_drone_ai::init();
	
	// Start functions
	default_start( ::start_func );
	add_start( "start_video_intro", 		::start_func );
	add_start( "start_safehouse_intro",		::start_func );
	add_start( "start_safehouse_explore",	::start_func );
	add_start( "start_safehouse_briefing",	::start_func );
	add_start( "start_safehouse_loadout",	::start_func );
	add_start( "start_safehouse_outro",		::start_func );
	add_start( "start_video_outro", 		::start_func );
	
	maps\_load::main();
	
	maps\patriot_crib_proto_audio::main();
	flags_init();
	player_loadout();
	armory_init();
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Misc. functions used by multiple starts
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

start_common()
{
	SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );
	
	// Set up targets
	group_struct_names =	[ 
	                      	"struct_weapons_test_targets_close_01",
	                      	"struct_weapons_test_targets_close_02",
	                      	"struct_weapons_test_targets_far_01",
	                      	"struct_weapons_test_targets_far_02",
	                      	"struct_weapons_test_targets_thermal_01",
	                      	"struct_weapons_test_targets_thermal_02",
	                      	"struct_weapons_test_targets_thermal_03",
	                      	"struct_weapons_test_targets_repeat_01",
	                      	"struct_weapons_test_targets_repeat_02",
	                      	"struct_weapons_test_targets_repeat_03"
	                     	];
	
	course_target_setup( group_struct_names );
}

start_func()
{
	start_common();
	
	start_name = ter_op( IsDefined( level.start_point ), level.start_point, "default" );
	
	thread player_teleport( start_name );
	thread objective_think( start_name );
	
	switch ( start_name )
	{
		case "default":
		case "start_video_intro":
			thread start_video_intro();
			break;
		
		case "start_safehouse_intro":
			thread start_safehouse_intro();
			break;
		
		case "start_safehouse_explore":
			thread start_safehouse_explore();
			break;
		
		case "start_safehouse_briefing":
			thread start_safehouse_briefing();
			break;
		
		case "start_safehouse_loadout":
			thread start_safehouse_loadout();
			break;
		
		case "start_safehouse_outro":
			thread start_safehouse_outro();
			break;
		
		case "start_video_outro":
			thread start_video_outro();
			break;
		
		default:
			AssertMsg( "Invalid start point of: " + start_name );
			break;
	}
}

player_teleport( start_name )
{
	switch ( start_name )
	{
		case "default":
		case "start_video_intro":
		case "start_safehouse_intro":
			break;
		
		case "start_safehouse_explore":
			level.player teleport_player( getstruct( "struct_player_loc_start_explore", "targetname" ) );
			break;
		
		case "start_safehouse_briefing":
			level.player teleport_player( getstruct( "struct_player_loc_start_briefing", "targetname" ) );
			break;
		
		case "start_safehouse_loadout":
			level.player teleport_player( getstruct( "struct_player_loc_start_loadout", "targetname" ) );
		
			break;
		case "start_safehouse_outro":
			level.player teleport_player( getstruct( "struct_player_loc_start_outro", "targetname" ) );
			break;
		
		case "start_video_outro":
			break;
		
		default:
			AssertMsg( "Invalid start point of: " + start_name );
			break;
	}
}

objective_think( start_name )
{
	switch ( start_name )
	{
		case "default":
		case "start_video_intro":
		case "start_safehouse_intro":
		{
			flag_wait( "safehouse_intro_begin" );
			Objective_Add( obj( "torture" ), "active", &"PATRIOT_CRIB_PROTO_OBJ_TORTURE" );
			Objective_Current( obj( "torture" ) );
		}
		case "start_safehouse_explore":
		{
			flag_wait( "torture_sequence_intro_done" );
			if ( IsDefined( level.obj_array ) && IsDefined( level.obj_array[ "torture" ] ) )
			{
				objective_complete( obj( "torture" ) );
			}
			Objective_Add( obj( "explore" ), "active", &"PATRIOT_CRIB_PROTO_OBJ_EXPLORE" );
			Objective_Current( obj( "explore" ) );
		}
		case "start_safehouse_briefing":
		{
			flag_wait_either( "safehouse_briefing_begin", "safehouse_obj_explore_fail" );
			
			if ( !flag( "safehouse_obj_explore_fail" ) )
			{
				if ( IsDefined( level.obj_array ) && IsDefined( level.obj_array[ "explore" ] ) )
				{
					objective_complete( obj( "explore" ) );
				}
			}
			else
			{
				Objective_State( obj( "explore" ), "failed" );
				
				flag_wait( "safehouse_briefing_begin" );
			}
			
			flag_wait( "safehouse_briefing_handshake_ready" );
			
			Objective_Add( obj( "handshake" ), "active", &"PATRIOT_CRIB_PROTO_OBJ_HANDSHAKE" );
			Objective_Current( obj( "handshake" ) );
		}
		case "start_safehouse_loadout":
		{
			flag_wait( "safehouse_loadout_begin_for_player" );
			if ( IsDefined( level.obj_array ) && IsDefined( level.obj_array[ "handshake" ] ) )
			{
				objective_complete( obj( "handshake" ) );
			}
			Objective_Add( obj( "loadout" ), "active", &"PATRIOT_CRIB_PROTO_OBJ_LOADOUT" );
			Objective_Current( obj( "loadout" ) );
		}
		case "start_safehouse_outro":
		{
			flag_wait( "safehouse_outro_begin" );
			if ( IsDefined( level.obj_array ) && IsDefined( level.obj_array[ "loadout" ] ) )
			{
				objective_complete( obj( "loadout" ) );
			}
			Objective_Add( obj( "exit" ), "active", &"PATRIOT_CRIB_PROTO_OBJ_EXIT" );
			Objective_Current( obj( "exit" ) );
			
			flag_wait( "safehouse_outro_player_reached_chopper" );
			
			objective_complete( obj( "exit" ) );
		}
		case "start_video_outro":
			break;
		
		default:
			AssertMsg( "Invalid start point of: " + start_name );
			break;
	}
}

safehouse_npc_path( ent_name_prefix, ent_look_at, flag_look_clear )
{	
	self endon( "death" );
	
	if ( !IsDefined( self ) || !IsAlive( self ) )
		return;
	
	if ( IsDefined( ent_look_at ) )
	{
		self SetLookAtEntity( ent_look_at );
	}
	
	ent_name = ent_name_prefix + self.targetname;
	
	ent = get_target_ent( ent_name );
	if ( IsDefined( ent ) )
	{
		self thread npc_anim_reach_and_idle_name( ent_name );
	}
	
	if ( IsDefined( ent_look_at ) )
	{
		if ( IsDefined( flag_look_clear ) )
		{
			flag_wait( flag_look_clear );
			
			self SetLookAtEntity();
		}
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Player Loadout (Here instead of muddying up _loadout.gsc with test stuff)
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

player_loadout()
{
	array_call( level.players, ::TakeAllWeapons );
	array_call( level.players, ::GiveWeapon,		"iw5_fnfiveseven_mp" );
	array_call( level.players, ::SwitchToWeapon,	"iw5_fnfiveseven_mp" );
	array_call( level.players, ::SetViewmodel,		"viewhands_delta" );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Flags
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

flags_init()
{
	flag_init( "safehouse_intro_begin" );
	flag_init( "flag_stop_intro" );
	flag_init( "safehouse_intro_door_opening" );
	flag_init( "safehouse_explore_begin" );
	flag_init( "flag_torture_sequence_intro_start" );
	flag_init( "torture_sequence_intro_done" );
	flag_init( "torture_sequence_rock_left" );
	flag_init( "torture_sequence_ambience_done" );
	flag_init( "safehouse_explore_clear_shooting_range" );
	flag_init( "safehouse_explore_rock_reached_table" );
	flag_init( "flag_carlos_attacking_player" );
	flag_init( "flag_player_testing_weapons" );
	flag_init( "safehouse_obj_explore_fail" );
	flag_init( "weapons_testing_weapon_collected" );
	flag_init( "weapons_testing_grinch_complained" );
	flag_init( "safehouse_briefing_begin" );
	flag_init( "safehouse_briefing_handshake_ready" );
	flag_init( "safehouse_briefing_prepare_loadouts" );
	flag_init( "safehouse_loadout_begin" );
	flag_init( "safehouse_loadout_begin_for_player" );
	flag_init( "safehouse_outro_begin" );
	flag_init( "safehouse_outro_chopper_landed" );
	flag_init( "safehouse_outro_player_reached_chopper" );
	flag_init( "safehouse_outro_player_on_chopper" );
	flag_init( "video_outro_begin" );
	flag_init( "flag_stop_outro" );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Start Functions
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

start_video_intro()
{
	thread video_intro();
	thread safehouse_intro();
	thread safehouse_explore();
	thread safehouse_briefing();
	thread safehouse_loadout();
	thread safehouse_outro();
	thread video_outro();
}

start_safehouse_intro()
{
	thread safehouse_intro();
	thread safehouse_explore();
	thread safehouse_briefing();
	thread safehouse_loadout();
	thread safehouse_outro();
	thread video_outro();
	
	flag_set( "safehouse_intro_begin" );
}

start_safehouse_explore()
{
	// Spawn Torture Crowd
	npc_grinch = npc_spawn( "npc_grinch", false, getstruct( "struct_torture_pos_grinch", "targetname" ) );
	npc_rock = npc_spawn( "npc_rock", false, getstruct( "struct_torture_pos_rock", "targetname" ) );
	
	npc_grinch thread npc_anim_reach_and_idle_name( "struct_torture_pos_grinch", true );
	npc_rock thread npc_anim_reach_and_idle_name( "struct_torture_pos_rock", true );
	
	thread safehouse_explore();
	thread safehouse_briefing();
	thread safehouse_loadout();
	thread safehouse_outro();
	thread video_outro();
	
	flag_set( "safehouse_intro_door_opening" );
	flag_set( "safehouse_explore_begin" );
}

start_safehouse_briefing()
{
	// Spawn Grinch
	npc_grinch = npc_spawn( "npc_grinch", false, getstruct( "struct_grinch_loc_start_briefing", "targetname" ) );
	npc_grinch thread npc_interact();
	
	npc_rock = npc_spawn( "npc_rock", false, getstruct( "struct_explore_pos_rock", "targetname" ) );
	
	thread npcs_spawn_no_interact( "npcs" );
	wait 0.05;
	
	thread safehouse_briefing();
	thread safehouse_outro();
	thread safehouse_loadout();
	thread video_outro();
	
	flag_set( "safehouse_briefing_begin" );
}

start_safehouse_loadout()
{
	// Spawn Grinch, Sandman, Truck
	npc_spawn( "npc_grinch", false, getstruct( "loadout_npc_grinch", "targetname" ) );
	npc_spawn( "npc_sandman", true, getstruct( "brief_npc_sandman", "targetname" ) );
	npc_spawn( "npc_truck", true, getstruct( "loadout_npc_truck", "targetname" ) );
	npc_spawn( "npc_rock", false, getstruct( "loadout_npc_rock", "targetname" ) );
	
	thread npcs_spawn_no_interact( "npcs" );
	wait 0.05;
	safehouse_loadout_npc_model_swap();
	wait 0.05;
	
	thread safehouse_loadout();
	thread safehouse_outro();
	thread video_outro();
	
	flag_set( "safehouse_briefing_handshake_ready" );
	flag_set( "safehouse_loadout_begin" );
}

start_safehouse_outro()
{
	// Spawn Grinch, Sandman, Truck
	npc_spawn( "npc_grinch", getstruct( "loadout_npc_grinch", "targetname" ) );
	npc_spawn( "npc_sandman", getstruct( "brief_npc_sandman", "targetname" ), true );
	npc_spawn( "npc_truck", getstruct( "loadout_npc_truck", "targetname" ) );
	
	npc_spawn( "npc_carlos", false, getstruct( "exit_npc_carlos", "targetname" ) );
	npc_spawn( "npc_tommy", false, getstruct( "exit_npc_tommy", "targetname" ) );
	npc_spawn( "npc_lt", false, getstruct( "exit_npc_lt", "targetname" ) );
	
	// Disable weapon hide system on active npcs
	npc_chars_active = npcs_get_array( [ "npc_grinch", "npc_carlos", "npc_lt", "npc_tommy", "npc_truck", "npc_sandman" ] );
	array_thread( npc_chars_active, ::npc_interact_player_weapon_hide_disable );
	
	thread safehouse_outro();
	thread video_outro();
	
	flag_set( "safehouse_outro_begin" );
}

start_video_outro()
{
	// Play Next Mission's Gameplay Intro
	thread video_outro();
	
	flag_set( "video_outro_begin" );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Previous Mission Gameplay Intro Video
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

video_intro()
{
	level.player FreezeControls( true );
	
	prep_cinematic( "safehouse_intro" );
	
	hud_hide();
	
	overlay = get_overlay( "black" );
	overlay.alpha = 1.0;
	
	wait 0.25;
	
	thread play_cinematic( "safehouse_intro", false, "flag_stop_intro" );
	
	thread fade_in( 2.0, "black" );
	
	level.player NotifyOnPlayerCommand( "BUTTON_SKIP", "+gostand" );
	
	msg = level.player waittill_any_timeout( 49.0, "BUTTON_SKIP" );
	
	// If the player pressed the skip button let the play_cinematic()
	// function know to end the cinematic early
	if ( msg == "BUTTON_SKIP" )
	{
		fade_out( 0.5, "black" );
		wait 0.5;
		flag_set( "flag_stop_intro" );
		wait 1.0;
	}
	else
	{
		thread fade_out( 1.0, "black" );
		wait 4.0;
	}
	
	level.player FreezeControls( false );
	
	hud_show();
	
	flag_set( "safehouse_intro_begin" );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Safehouse Intro
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

safehouse_intro()
{
	flag_wait( "safehouse_intro_begin" );
	
	level.player enable_weapons_and_stance( false );
	
	overlay = get_overlay( "black" );
	overlay.alpha = 1.0;
	
	vehicle_lead	= spawn_vehicle_from_targetname( "spawner_veh_intro_lead" );
	vehicle_player	= spawn_vehicle_from_targetname( "spawner_veh_intro_player" );
	vehicle_player.animname = "hummer";
	
	grinch = npc_spawn( "npc_grinch" );
	
	vehicle_player guy_enter_vehicle( grinch );
	grinch thread ai_think_safehouse_intro_grinch();
	
	vehicle_lead thread on_van_arrive_spawn_rock();
	
	ent_player_offset = spawn_tag_origin();
	ent_player_offset LinkTo( vehicle_player, "tag_passenger", (-10, 10, -30), (0, 0, 0) );
	
	// Link the player to the offset entity and wait a frame so that the player's
	// view is updated to match the vehicles view. Then link the player with the
	// ability to look around.
	level.player PlayerLinkToAbsolute( ent_player_offset, "tag_origin" );
	wait 0.1;
	level.player PlayerLinkTo( ent_player_offset, "tag_origin", 1.0, 30, 30, 30, 30, false );
	
	wait 1.0;
	
	thread fade_in( 1.0, "black" );
	
	vehicle_lead thread gopath();
	vehicle_player thread gopath();
	
	grinch dialogue_queue( "safehouse_grn_wakeup" );
	wait 1.1;
	grinch thread dialogue_queue( "safehouse_grn_alreadymoved" );
	wait 1.0;
	
	thread entrance_door( GetEnt( "entrance_door", "targetname" ) );
	
	vehicle_player waittill( "reached_end_node" );
	
	grinch thread dialogue_queue( "safehouse_grn_werelate" );
	
	player_rig = spawn_anim_model( "player_rig", vehicle_player.origin );
	player_rig.angles = vehicle_player.angles;
	player_rig LinkTo( vehicle_player, "tag_origin" );
	
	level.player Unlink();
	level.player PlayerLinkToAbsolute( player_rig, "tag_player" );
	
	ent_player_offset Delete();
	
	intro_ents = [ vehicle_player, player_rig ];
	vehicle_player anim_single( intro_ents, "hummer_exit" );
	
	level.player Unlink();
	player_rig Unlink();
	player_rig Delete();
	
	wait 0.75;
	
	level.player enable_weapons_and_stance( true );
	
	flag_set( "safehouse_explore_begin" );
}

entrance_door( door )
{
	flag_set( "safehouse_intro_door_opening" );
	
	door_pos_final	= door.origin + ( 0, 0, 152 );
	
	door PlaySound( "scn_favela_garage_door" );
	door MoveTo( door_pos_final, 2.0, 0.25, 0.0 );
	
	door ConnectPaths();
}

ai_think_safehouse_intro_grinch()
{
	self endon( "death" );
	
	// Wait until grinch exits hummer
	self waittill( "jumpedout" );
	
	wait 2.0;
	
	// vehicle scripts override goalradius upon jump out
	self.goalradius = 32;
	
	self thread npc_anim_reach_and_idle_name( "struct_torture_pos_grinch" );
	
	ent_look = safehouse_intro_get_look_ent();
	self SetLookAtEntity( ent_look );
	
	flag_wait( "torture_sequence_intro_done" );
	
	self SetLookAtEntity();
}

on_van_arrive_spawn_rock()
{
	self ent_flag_init( "flag_ent_van_arrived" );
	self ent_flag_wait( "flag_ent_van_arrived" );
	
	npc_rock = npc_spawn( "npc_rock" );
	
	npc_rock thread npc_anim_reach_and_idle_name( "struct_torture_pos_rock" );
	
	ent_look = safehouse_intro_get_look_ent();
	npc_rock SetLookAtEntity( ent_look );
	
	flag_wait( "torture_sequence_intro_done" );
	
	npc_rock SetLookAtEntity();
}

safehouse_intro_get_look_ent()
{
	// Spawn tag origin for look ent because a script_origin
	// doesn't work with the SetLookAtEntity()
	if ( !IsDefined( level.safehouse_intro_look_ent ) )
	{
		ent_loc = GetEnt( "ent_grinch_torture_look", "targetname" );
		level.safehouse_intro_look_ent = ent_loc spawn_tag_origin();
		
		thread safehouse_intro_look_ent_delete();
	}
	
	return level.safehouse_intro_look_ent;
}

safehouse_intro_look_ent_delete()
{
	flag_wait( "torture_sequence_intro_done" );
	
	if ( IsDefined( level.safehouse_intro_look_ent ) )
	{
		level.safehouse_intro_look_ent Delete();
	}
	
	level.safehouse_intro_look_ent = undefined;
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Safehouse Exploration
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

safehouse_explore()
{	
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	array_spawn_function_targetname( "npc_carlos", ::safehouse_explore_on_spawn_carlos );
	
	flag_wait( "safehouse_intro_door_opening" );
	thread npcs_spawn( "npcs", "torture_sequence_intro_done" );
	
	npc_axe = npc_spawn( "npc_axe", true, getstruct( "struct_torture_pos_axe", "targetname" ) );
	npc_axe thread npc_anim_reach_and_idle_name( "struct_torture_pos_axe", true );
	
	npc_judge = npc_spawn( "npc_judge", true );
	npc_judge thread npc_anim_reach_and_idle_name( "struct_torture_pos_judge" );
	
	thread safehouse_explore_music();
	thread torture_sequence();
	thread sequence_ace_shooting();
	thread safehoue_explore_npc_disperse();
	thread sequence_weapons_testing();
	
	flag_wait( "safehouse_explore_begin" );
	flag_wait( "torture_sequence_intro_done" );
	
	npc_grinch = npc_get( "npc_grinch" );
	npc_grinch thread ai_think_grinch_safehouse_explore();
	
	wait 5.0;
	
	sound_ent = GetEnt( "ent_torture_sounds", "targetname" );
	
	sequences = [];
	
	sequences[ sequences.size ] = [ "safehouse_hst_youhearme", "safehouse_snd_wronganswer", "safehouse_hst_sm_scrm_01" ];	
	sequences[ sequences.size ] = [ "safehouse_snd_littlegirls", "safehouse_hst_fyou", "safehouse_hst_sm_scrm_01" ];
	sequences[ sequences.size ] = [ "safehouse_trk_wheresgirl", "safehouse_hst_sm_scrm_02" ];
	sequences[ sequences.size ] = [ "safehouse_snd_holdingout", "safehouse_hst_md_scrm_01" ];
	sequences[ sequences.size ] = [ "safehouse_hst_sm_scrm_02" ];
//	sequences[ sequences.size ] = [ "safehouse_hst_lg_scrm_01" ];
	sequences[ sequences.size ] = [ "safehouse_snd_wronganswer", "safehouse_hst_md_scrm_02" ];
	sequences[ sequences.size ] = [ "safehouse_hst_lg_scrm_01" ];
	sequences[ sequences.size ] = [ "safehouse_snd_tellme", "safehouse_hst_md_scrm_03" ];
	sequences[ sequences.size ] = [ "safehouse_hst_md_scrm_02" ];
	sequences[ sequences.size ] = [ "safehouse_snd_pissedyourself", "safehouse_hst_lg_scrm_01" ];
	sequences[ sequences.size ] = [ "safehouse_hst_md_scrm_01" ];
//	sequences[ sequences.size ] = [ "safehouse_hst_md_scrm_02" ];
//	sequences[ sequences.size ] = [ "safehouse_snd_wronganswer", "safehouse_hst_lg_scrm_02" ];
//	sequences[ sequences.size ] = [ "safehouse_hst_sm_scrm_02" ];
//	sequences[ sequences.size ] = [ "safehouse_hst_sm_scrm_01" ];
	sequences[ sequences.size ] = [ "safehouse_snd_tellme", "safehouse_hst_lg_scrm_03" ];
	sequences[ sequences.size ] = [ "safehouse_hst_lg_scrm_02" ];
	sequences[ sequences.size ] = [ "safehouse_hst_lg_scrm_03" ];
	
	for ( seq_idx = 0; seq_idx < sequences.size; seq_idx++ )
	{
		line_idx = 0;
		while ( line_idx < sequences[ seq_idx ].size )
		{
			// The last line is always the scream
			if ( line_idx + 1 == sequences[ seq_idx ].size )
			{
				level notify( "torture_lights_on" );
			}
			
			play_sound_in_space( sequences[ seq_idx ][ line_idx ], sound_ent.origin );
			
			if ( line_idx + 1 == sequences[ seq_idx ].size )
			{
				level notify( "torture_lights_off" );
			}
			
			wait( RandomFloatRange( 0.6, 1.0 ) );
			
			line_idx++;
		}
		
		wait( RandomFloatRange( 2.0, 3.0 ) );
	}
	
	wait 3.0;
	
	// Create some space between existing player activity
	// and the briefing kick off
	time_delay_after_player_busy = 4.0;
	while ( 1 )
	{
		if ( flag( "flag_carlos_attacking_player" ) )
		{
			flag_waitopen( "flag_carlos_attacking_player" );
			wait time_delay_after_player_busy;
			continue;
		}
		else if ( flag( "flag_player_testing_weapons" ) )
		{
			flag_waitopen( "flag_player_testing_weapons" );
			wait time_delay_after_player_busy;
			continue;
		}
		
		break;
	}
	
	flag_set( "torture_sequence_ambience_done" );
	flag_set( "safehouse_briefing_begin" );
}

safehouse_explore_music()
{
	level endon( "safehouse_briefing_begin" );
	
	speaker_ent = GetEnt( "ent_boom_box_loc", "targetname" );
	
	thread safehouse_explore_music_stop( speaker_ent );
	
	flag_wait( "safehouse_explore_begin" );
	
	wait 2.0;
	
	music_array = [ "safehouse_radio_music_01", "safehouse_radio_music_02", "safehouse_radio_music_03", "safehouse_radio_music_04" ];
	
	foreach ( alias in music_array )
	{
		speaker_ent PlaySound( alias, "speaker_sound_interrupt", true );
		
		speaker_ent waittill( "speaker_sound_interrupt" );
	}
}

safehouse_explore_music_stop( speaker_ent )
{
	flag_wait( "safehouse_briefing_begin" );
	
	speaker_ent notify( "explore_music_stop" );
}

safehouse_explore_on_spawn_carlos()
{
	self endon( "death" );
	
	self waittill( "npc_interact_finished" );
	
	self thread safehouse_explore_carlos_attack();	
}

safehouse_explore_carlos_attack()
{
	self endon( "death" );
	
	trigger_radius = Spawn( "trigger_radius", self.origin, 0, 48, 180 );
	trigger_radius EnableLinkTo();
	trigger_radius LinkTo( self, "tag_origin", (0, 0, -1 * 180 * 0.5 ), (0,0,0) );
	
	self thread safehouse_explore_carlos_attack_clean_up_on_death( trigger_radius );
	self thread safehouse_explore_carlos_attack_clean_up_on_level( trigger_radius );
	
	trigger_radius waittill( "trigger" );
	
	if ( flag( "safehouse_briefing_begin" ) )
		return;
	
	flag_set( "flag_carlos_attacking_player" );
	
	level.player _disableWeapon();
	
	anim_origin = ( level.player.origin - self.origin ) * 0.5 + self.origin;
	anim_angles = VectorToAngles( level.player.origin - self.origin );
	struct = SpawnStruct();
	struct.origin = anim_origin;
	struct.angles = anim_angles;
	
	self npc_animate_stop();
	
	self SetLookAtEntity( level.player );
	
	player_rig = maps\_player_rig::get_player_rig();
	level.player thread maps\_player_rig::blend_player_to_arms( 0.3 );
	level.player delayThread( 0.3, maps\_player_rig::link_player_to_arms, 0, 0, 0, 0 );
	
	self thread dialogue_queue( "safehouse_cls_youdeaf" );
	struct anim_single( [ player_rig, self ], "crib_grab" );

	level.player Unlink();
	level.player _enableWeapon();
	
	player_rig Delete();
	
	struct.animation = "crowdsniper_crowdwatchidle_3";
	self thread npc_anim_reach_and_idle( struct, true );
	
	wait 1.0;
	self thread dialogue_queue( "safehouse_cls_rookie" );
	wait 1.0;
	self SetLookAtEntity();
	
	flag_clear( "flag_carlos_attacking_player" );
}

safehouse_explore_carlos_attack_clean_up_on_death( trigger )
{
	level endon( "safehouse_briefing_begin" );
	
	self waittill( "death" );
	
	if ( IsDefined( trigger ) )
	{
		level notify( "carlos_attack_cleaned_on_death" );
		
		trigger Unlink();
		wait 0.05;
		trigger Delete();
	}
}

safehouse_explore_carlos_attack_clean_up_on_level( trigger )
{
	level endon( "carlos_attack_cleaned_on_death" );
	
	level waittill_any( "flag_carlos_attacking_player", "safehouse_briefing_begin" );
	
	if ( IsDefined( trigger ) )
	{
		trigger Unlink();
		wait 0.05;
		trigger Delete();
	}
}

torture_sequence()
{
	trigger_weapon = GetEnt( "trigger_toture_sequence_weapon", "targetname" );
	trigger_weapon thread trigger_player_weapon_hide();
	
	thread torture_sequence_lights();
	
	node_battery				= GetEnt( "torture_node_chair_battery", "targetname" );
	node_door					= GetEnt( "torture_node_door", "targetname" );
	door						= GetEnt( "torture_door", "targetname" );
    
	guys_battery				= [];
	guys_door					= [];
    
	guys_battery[ 0 ]			= npc_spawn( "spawner_hostage", true );
	guys_battery[ 0 ].animname	= "torture_enemy";
    
	guys_battery[ 1 ]			= npc_spawn( "npc_truck", true );
	guys_battery[ 1 ].animname	= "torture_friend1";
    
	guys_door[ 0 ]				= npc_spawn( "npc_sandman", true );
	guys_door[ 0 ].animname		= "torture_friend2";
    
	jumper_cables				= spawn_anim_model( "torture_cables", node_battery.origin );
	guys_battery[ 2 ]			= jumper_cables;
 
	node_battery anim_first_frame( guys_battery, "torture" );
	node_door anim_first_frame( guys_door, "torture" );
	
	guys_door[ 0 ] thread torture_sequence_door( door );
	guys_door[ 0 ] SetLookAtEntity( level.player );

	flag_wait( "safehouse_explore_begin" );
	
	guys_door[ 0 ] dialogue_queue( "safehouse_snd_joinus" );
	
	flag_wait( "flag_torture_sequence_intro_start" );
	
	// Play this dialogue keeping the animation paused
	guys_door[ 0 ] dialogue_queue( "safehouse_snd_loadoff" );
	
	guys_battery[ 0 ] thread play_sound_on_entity( "scn_favela_captive_in_chair" );
	garage_sound_pos = guys_battery[ 0 ].origin;
    
	node_battery thread anim_single( guys_battery, "torture" );
	node_door thread anim_single( guys_door, "torture" );
	
	
	guys_door[ 0 ] dialogue_queue( "safehouse_snd_toolong" );
	guys_door[ 0 ] dialogue_queue( "safehouse_snd_armoryequipment" );
	
	guys_door[ 0 ] dialogue_queue( "safehouse_snd_readytoroll" );
	
	npc_grinch = npc_get( "npc_grinch" );
	npc_grinch dialogue_queue( "safehouse_grn_yessir" );
	
	array_call( guys_battery, ::Delete );
	array_call( guys_door, ::Delete );
	
	//thread play_sound_in_space( "scn_favela_garage_interior", garage_sound_pos );
	
	wait 1.0;
	
	flag_set( "torture_sequence_intro_done" );
	
	trigger_weapon thread trigger_player_weapon_hide_disable();
}

torture_sequence_door( door )
{
	door_pos_final	= door.origin;
	door_pos_start	= door.origin + ( 0, 0, 52 );
	door.origin		= door_pos_start;
    
	flag_wait( "drop_door" );
	
	door PlaySound( "scn_favela_garage_door" );
	door MoveTo( door_pos_final, 1.0, 0.1, 0.0 );
}

CONST_LIGHT_INTENSITY_MIN		= 0.01;
CONST_LIGHT_INTENSITY_MAX_PERC	= 0.75;
CONST_LIGHT_INTENSITY_ON		= 0.35;
CONST_LIGHT_DIM_TIME			= 0.4;

torture_sequence_lights()
{
	level endon( "torture_sequence_ambience_done" );
	
	lights = GetEntArray( "p_light", "targetname" );
	
	lights_dyn_setup( lights );
	thread torture_sequence_lights_on_reset( lights );
	
	torture_lights_on = false;
	while ( 1 )
	{
		if ( !torture_lights_on )
		{
			level waittill( "torture_lights_on" );
		}
		
		thread lights_dyn_adjust_over_time( lights, true, CONST_LIGHT_DIM_TIME );
		
		msg = level waittill_any_return( "torture_lights_adjusted", "torture_lights_off" );
		
		if ( msg == "torture_lights_adjusted" )
		{
//			// Flicker lights randomly for period of time
//			array_thread( lights, ::light_dyn_flicker );
			
			// Flicker lights in synch for a period of time
			thread lights_dyn_flicker( lights );
			
			level waittill( "torture_lights_off" );
			
//			array_notify( lights, "stop_flicker" );
			
			level notify( "lights_stop_flicker" );
		}
		else if ( msg == "torture_lights_off" )
		{
			// There was an interrupt to the adjust so cancel adjust
			level notify( "torture_lights_adjust_cancel" );
		}
		
		array_thread( lights, ::light_dyn_off );
		
		thread lights_dyn_adjust_over_time( lights, false, CONST_LIGHT_DIM_TIME );
		msg = level waittill_any_return( "torture_lights_adjusted", "torture_lights_on" );
		
		// Lights back on either way
		array_thread( lights, ::light_dyn_on );
		
		if ( msg == "torture_lights_on" )
		{
			// There was an interrupt so cancel adjust
			level notify( "torture_lights_adjust_cancel" );
			
			torture_lights_on = true;
			continue;
		}
		
		torture_lights_on = false;
	}
}

torture_sequence_lights_on_reset( lights )
{
	flag_wait( "torture_sequence_ambience_done" );
	
//	// Stop individual light flickering
//	array_notify( lights, "stop_flicker" );
	
	level notify( "lights_stop_flicker" );
	
	lights_dyn_adjust_over_time( lights, false, CONST_LIGHT_DIM_TIME );
}

lights_dyn_setup( lights )
{
	foreach ( light in lights )
	{
		light.intensity_max = light GetLightIntensity();
		
		models = light get_linked_ents();
		
		AssertEx( models.size == 0 || models.size == 2, "Each primary light should have 0 or 2 linked ents for the on and off visuals." );
		
		if ( models.size > 0 )
		{
			light.has_model = true;
		}
		
		foreach ( model in models )
		{
			AssertEx( IsDefined( model.script_noteworthy ), "Linked ent from primary light does not have script_noteworthy defined." );
			
			if ( !IsDefined( model.script_noteworthy ) )
				return;
			
			if ( model.script_noteworthy == "light_model_on" )
			{
				light.model_on = model;
			}
			else if ( model.script_noteworthy == "light_model_off" )
			{
				light.model_off = model;
			}
			else
			{
				AssertMsg( "Invalid script_noteworthy on linked ent from primary light: " + model.script_noteworthy );
			}
		}
		
		light light_dyn_on();
	}
}

lights_dyn_adjust_over_time( lights, turn_off, time_dim )
{
	level notify( "torture_lights_adjust_cancel" );
	level endon( "torture_lights_adjust_cancel" );
	
	while ( time_dim >= 0.0 )
	{
		wait 0.05;
		time_dim -= 0.05;
		
		ratio = ter_op( turn_off, time_dim / CONST_LIGHT_DIM_TIME, 1.0 - time_dim / CONST_LIGHT_DIM_TIME );
		
		foreach ( light in lights )
		{
			intensity = CONST_LIGHT_INTENSITY_MIN + ratio * ( light.intensity_max - CONST_LIGHT_INTENSITY_MIN );
			
			if ( intensity >= 0.25 )
			{
				light light_dyn_on( intensity );
			}
			else
			{
				light light_dyn_off( intensity );
			}
		}
	}
	
	if ( turn_off )
	{
		array_thread( lights, ::light_dyn_off );
	}
	else
	{
		array_thread( lights, ::light_dyn_on );
	}
	
	level notify( "torture_lights_adjusted" );
}

// Flickers all lights in synch
lights_dyn_flicker( lights )
{
	level endon( "lights_stop_flicker" );
	
	intensity_max = 0.0;
	foreach ( light in lights )
	{
		intensity_max = max( intensity_max, light.intensity_max * CONST_LIGHT_INTENSITY_MAX_PERC );
	}
	
	if ( intensity_max < CONST_LIGHT_INTENSITY_ON )
		intensity_max = CONST_LIGHT_INTENSITY_ON + 0.2;
	
	AssertEx( intensity_max > 0.0, "Could not find light with intensity set to greater than 0." );
	
	lights_on = true;
	
	intensity = undefined;
	
	while ( 1 )
	{
		if ( lights_on )
		{
			intensity = RandomFloatRange( CONST_LIGHT_INTENSITY_ON, intensity_max );
		}
		else
		{
			intensity = RandomFloatRange( CONST_LIGHT_INTENSITY_MIN, CONST_LIGHT_INTENSITY_ON );
		}
		
		
		foreach ( light in lights )
		{	
			
			if ( intensity >= CONST_LIGHT_INTENSITY_ON )
			{
				light light_dyn_on( intensity );
			}
			else
			{
				light light_dyn_off( intensity );
			}
		}
		
		wait( RandomFloatRange( 0.05, 0.15 ) );
		
		lights_on = !lights_on;
	}
}

// Flickers one light
light_dyn_flicker()
{
	light = self;
	
	light endon( "stop_flicker" );
	
	while ( 1 )
	{
		intensity = RandomFloatRange( CONST_LIGHT_INTENSITY_MIN, light.intensity_max * CONST_LIGHT_INTENSITY_MAX_PERC );
		if ( intensity >= CONST_LIGHT_INTENSITY_ON )
		{
			light light_dyn_on( intensity );
		}
		else
		{
			light light_dyn_off( intensity );
		}
		wait( RandomFloatRange( 0.05, 0.15 ) );
	}
}

light_dyn_on( intensity_override )
{
	light = self;
	
	if ( IsDefined( intensity_override ) )
	{
		light SetLightIntensity( intensity_override );
	}
	else
	{
		light SetLightIntensity( light.intensity_max );
	}
	
	if ( IsDefined( light.model_on ) )
	{
	    light.model_on show_entity();
	}
	
	if ( IsDefined( light.model_off ) )
	{
		light.model_off hide_entity();
	}
}

light_dyn_off( intensity_override )
{
	light = self;
	
	if ( IsDefined( intensity_override ) )
	{
		light SetLightIntensity( intensity_override );
	}
	else
	{
		light SetLightIntensity( CONST_LIGHT_INTENSITY_MIN );
	}
	
	if ( IsDefined( light.model_on ) )
	{
	    light.model_on hide_entity();
	}
	
	if ( IsDefined( light.model_off ) )
	{
		light.model_off show_entity();
	}
}

ai_think_grinch_safehouse_explore()
{
	flag_wait( "torture_sequence_intro_done" );
	
	wait 0.2;
	
	npc_rock = npc_get( "npc_rock" );
	self SetLookAtEntity( npc_rock );
	
	flag_wait( "torture_sequence_rock_left" );
	
	wait 0.9;
	
	delayCall( 0.5, ::SetLookAtEntity );
	self thread dialogue_queue( "safehouse_grn_justgothere" );
	self thread dialogue_queue( "safehouse_grn_grababeer" );
	
	npc_anim_reach_and_idle_name( "struct_grinch_sit" );
	
	self thread npc_interact();
}

CONST_WEAPONS_TEST_DELAY_BETWEEN_TARGETS = 0.5;
CONST_WEAPONS_TEST_DELAY_BEFORE_COMMENT	 = 0.8;

safehoue_explore_npc_disperse()
{
	flag_wait( "torture_sequence_intro_done" );
	
	npc_axe = npc_get( "npc_axe" );
	npc_axe thread npc_anim_reach_and_idle_name( "struct_explore_pos_axe" );
	
	wait 3.0;
	npc_judge = npc_get( "npc_judge" );
	npc_judge thread npc_anim_reach_and_idle_name( "struct_explore_pos_judge" );
	
}

// JC-ToDo: This should fail the objective
sequence_weapons_testing_on_player_leave()
{
	level endon( "safehouse_briefing_begin" );
	
	flag_wait ( "flag_player_testing_weapons" );
	
	trigger_armory = GetEnt( "trigger_room_armory", "targetname" );
	time_delay_sec_to_end_early = 30.0;
	
	while ( 1 )
	{
		while ( level.player IsTouching( trigger_armory ) )
			wait 0.05;
		
		time_prev = GetTime();
		trigger_armory wait_for_trigger_or_timeout( time_delay_sec_to_end_early );
		
		// If the player has been away from the range for a while exit the loop
		// and end weapons testing
		if ( GetTime() - time_prev >= time_delay_sec_to_end_early * 1000 )
			break;
	}
	
	level notify( "force_end_weapons_testing" );
	
	flag_set( "safehouse_obj_explore_fail" );
	
	course_target_reset();
	flag_clear( "flag_player_testing_weapons" );
	
}

sequence_weapons_testing()
{
	level endon( "safehouse_briefing_begin" );
	level endon( "force_end_weapons_testing" );
	
	AssertEx( IsDefined( level.group_structs ) && level.group_structs.size, "sequence_weapons_testing() has no target group structs." );
	
	weapon_struct = getstruct( "structs_weapon_test_01", "targetname" );
	
	// Spawn weapon but leave not usable
	weapon		  = Spawn( "weapon_iw5_acr_mp_hybrid", weapon_struct.origin );
	weapon.angles = weapon_struct.angles;
	weapon armory_weapon_ent_setup();
	ammo_clip  = WeaponClipSize( "iw5_acr_mp_hybrid" );
	ammo_stock = WeaponMaxAmmo( "iw5_acr_mp_hybrid" );
	weapon ItemWeaponSetAmmo( ammo_clip, ammo_stock );
	weapon MakeUnusable();

	flag_wait( "torture_sequence_intro_done" );
	
	npc_rock = npc_get( "npc_rock" );
	npc_rock thread ai_think_rock_safehouse_explore();
	
	flag_wait( "safehouse_explore_clear_shooting_range" );
	
	npc_rock npc_interact_player_weapon_hide_disable();
	
	npc_rock dialogue_queue( "safehouse_rck_testthesescopes" );
	
	flag_set( "flag_player_testing_weapons" );
	
	// Make the weapons testing skippable mid session
	thread sequence_weapons_testing_on_player_leave();
	
	wait 1.0;
	
	npc_rock dialogue_queue( "safehouse_rck_newshit" );
	
	trigger_range = GetEnt( "trigger_room_range", "targetname" );
	if ( !level.player IsTouching( trigger_range ) )
	{
		npc_rock dialogue_queue( "safehouse_rck_getstarted" );
		
		trigger_range waittill( "trigger" );
	}
	
	flag_wait( "safehouse_explore_rock_reached_table" );
	
	weapon MakeUsable();
	thread sequence_weapons_testing_flag_on_collect( weapon, "weapons_testing_weapon_collected" );
	
	npc_rock dialogue_queue( "safehouse_rck_acr" );
	
	flag_wait( "weapons_testing_weapon_collected" );
	
	npc_rock dialogue_queue( "safehouse_rck_youready" );
	
	npc_rock thread dialogue_queue( "safehouse_rck_lightemup" );
	
	target_group_pop_and_wait_name( "struct_weapons_test_targets_close_01" );
	wait CONST_WEAPONS_TEST_DELAY_BETWEEN_TARGETS;
	target_group_pop_and_wait_name( "struct_weapons_test_targets_close_02" );
	wait CONST_WEAPONS_TEST_DELAY_BEFORE_COMMENT;
	
	if ( level.player GetCurrentWeapon() != "iw5_acr_mp_hybrid" )
	{
		npc_rock thread dialogue_queue( "safehouse_rck_longrange" );
		while ( 1 )
		{
			level.player waittill( "weapon_change", weapon_name );
			if ( weapon_name == "iw5_acr_mp_hybrid" )
			{
				break;
			}
		}
	}
	
	npc_rock dialogue_queue( "safehouse_rck_burstfire" );
	
	target_group_pop_and_wait_name( "struct_weapons_test_targets_far_01" );
	wait CONST_WEAPONS_TEST_DELAY_BETWEEN_TARGETS;
	target_group_pop_and_wait_name( "struct_weapons_test_targets_far_02" );
	wait CONST_WEAPONS_TEST_DELAY_BEFORE_COMMENT;

	// Spawn the next weapon
	weapon_struct = getstruct( "structs_weapon_test_02", "targetname" );
	weapon		  = Spawn( "weapon_iw5_mk14_mp_thermal", weapon_struct.origin );
	weapon.angles = weapon_struct.angles;
	weapon armory_weapon_ent_setup();
	weapon ItemWeaponSetAmmo( WeaponClipSize( "iw5_mk14_mp_thermal" ), WeaponMaxAmmo( "iw5_mk14_mp_thermal" ) );
	
	flag_clear( "weapons_testing_weapon_collected" );
	weapon MakeUsable();
	thread sequence_weapons_testing_flag_on_collect( weapon, "weapons_testing_weapon_collected" );
	
	npc_rock dialogue_queue( "safehouse_rck_sighted" );
	
	npc_rock dialogue_queue( "safehouse_rck_mk14" );

	flag_wait( "weapons_testing_weapon_collected" );

	npc_rock dialogue_queue( "safehouse_rck_popsmoke" );
	wait 0.4;
	
	thread sequene_weapons_testing_spawn_grenades();
	
	npc_rock dialogue_queue( "safehouse_rck_smokeout" );
	
	wait 4.5;
	npc_rock thread dialogue_queue( "safehouse_rck_321fire" );
	wait 2.75;
	
	target_group_pop_and_wait_name( "struct_weapons_test_targets_thermal_01", true );
	wait CONST_WEAPONS_TEST_DELAY_BETWEEN_TARGETS;
	
	thread sequene_weapons_testing_grinch_complain();
	
	target_group_pop_and_wait_name( "struct_weapons_test_targets_thermal_02", true );
	wait CONST_WEAPONS_TEST_DELAY_BETWEEN_TARGETS;
	target_group_pop_and_wait_name( "struct_weapons_test_targets_thermal_03", true );
	wait CONST_WEAPONS_TEST_DELAY_BEFORE_COMMENT;
	
	flag_wait( "weapons_testing_grinch_complained" );
	npc_rock dialogue_queue( "safehouse_rck_tooeasy" );

// JC-ToDo: Add stay focused lines
//	npc_rock dialogue_queue( "safehouse_rck_downrangelong" );
//	npc_rock dialogue_queue( "safehouse_rck_downrange" );
//	npc_rock dialogue_queue( "safehouse_rck_stayfocused" );
//	npc_rock dialogue_queue( "safehouse_rck_waitingfor" );
//	npc_rock dialogue_queue( "safehouse_rck_hitemall" );
//	npc_rock dialogue_queue( "safehouse_rck_missany" );
	
	delayThread( 2.0, ::sequence_weapons_testing_targets_loop );
	
	// Wait until the player leaves the shooting range to fire off the briefing
	// with a timeout of 60 seconds
	time_finished = GetTime();
	while ( level.player IsTouching( trigger_range ) )
	{
		wait 0.05;
		if ( GetTime() - time_finished > 30000 )
			break;
	}
	
	flag_clear( "flag_player_testing_weapons" );
	
	flag_wait( "torture_sequence_ambience_done" );
	
	// All done, make sure rock has his weapon disable turned back on
	npc_rock thread npc_interact_player_weapon_hide();
}

sequence_weapons_testing_targets_loop()
{
	if ( flag( "safehouse_briefing_begin" ) )
		return;
	
	level endon( "force_end_weapons_testing" );
	level endon( "safehouse_briefing_begin" );
	
	idx = 1;
	while ( 1 )
	{
		group_struct_name = "struct_weapons_test_targets_repeat_0" + idx;
		target_group_pop_and_wait_name( group_struct_name, true );
		
		wait 2.0;
		
		idx++;
		if( idx > 3 )
		{
			idx = 1;
		}
	}
}

sequence_weapons_testing_flag_on_collect( weapon_ent, flag_name )
{
	force_alt = weapon_ent.classname == "weapon_iw5_acr_mp_hybrid";
	
	weapon_ent waittill( "trigger" );
	
	if ( force_alt )
	{
		level.player SwitchToWeaponImmediate( "alt_iw5_acr_mp_hybrid" );
	}
	
	flag_set( flag_name );
}

sequene_weapons_testing_grinch_complain()
{
	// Grinch Complains
	npc_grinch = npc_get( "npc_grinch" );
	npc_rock   = npc_get( "npc_rock" );
	
	npc_grinch dialogue_queue( "safehouse_grn_anylouder" );
	wait 0.6;
	npc_rock dialogue_queue( "safehouse_rck_getoverit" );
	
	flag_set( "weapons_testing_grinch_complained" );
}

sequene_weapons_testing_spawn_grenades()
{
	smoke_structs = getstructarray( "structs_weapon_test_smoke", "script_noteworthy" );
	foreach ( idx, struct in smoke_structs )
	{
		//noself_delayCall( ( idx + 1.0 ) * 0.6, ::MagicGrenadeManual, "smoke_grenade_american", struct.origin, ( 0, 0, -1 ), 0.5 + idx * 0.75 );
		//level.player delayCall( ( idx + 1.0 ) * 0.6, ::MagicGrenadeManual, "smoke_grenade_american", struct.origin, ( 0, 0, -1 ), 0.5 + idx * 0.75 );
		MagicGrenadeManual( "smoke_grenade_american", struct.origin, ( 0, 0, -1 ), 0.5 + idx * 0.75 );
		wait 0.6;
	}
}
	
ai_think_rock_safehouse_explore()
{
	flag_wait( "torture_sequence_intro_done" );
	
	self SetLookAtEntity( level.player );
	
	self dialogue_queue( "safehouse_rck_overwith" );
	
	flag_set( "torture_sequence_rock_left" );
	
	self thread npc_anim_reach_and_idle_name( "struct_explore_pos_rock_wait" );
	self thread ai_on_reach_goal( "safehouse_explore_rock_reached_table" );
	
	
	trigger_armory = GetEnt( "trigger_room_armory", "targetname" );
	
	while ( !self IsTouching( trigger_armory ) )
		wait 0.05;
	
	if ( !level.player IsTouching( trigger_armory ) )
	{
		array_nags = [ "safehouse_rck_testweapons", "safehouse_rck_ornot", "safehouse_rck_onmyown" ];
		thread safehouse_npc_nags( "npc_rock", "safehouse_explore_clear_shooting_range", array_nags, GetEnt( "trigger_room_armory_perimeter", "targetname" ) );
	}
	
	while ( !level.player IsTouching( trigger_armory ) )
		wait 0.05;
	
	flag_set( "safehouse_explore_clear_shooting_range" );
	
	// Make sure Rock has made it to the first spot before moving him, prevents anim reach idle from erroring on multiple calls
	flag_wait( "safehouse_explore_rock_reached_table" );
	wait 1.0;
	self set_generic_run_anim( "npc_walk_armed" );
	self thread npc_anim_reach_and_idle_name( "struct_explore_pos_rock" );
	
}

ai_on_reach_goal( flag_name )
{
	self waittill( "goal" );
	
	flag_set( flag_name );
}

sequence_ace_shooting()
{
	anim_struct = getstruct( "struct_shooting_range_ace", "targetname" );
	npc_ace = npc_spawn( "npc_ace", false, anim_struct );
	npc_ace thread ai_think_ace_safehouse_explore();
}

ai_think_ace_safehouse_explore()
{
	level endon( "safehouse_briefing_begin" );
	
	flag_wait( "safehouse_explore_clear_shooting_range" );
	
	wait 1.0;
	
	self npc_animate_stop();
	
	self maps\_patrol::patrol( "struct_patrol_start_after_shoot" );
	
}

ai_think_ace_safehouse_briefing()
{
	self npc_animate_stop();
	
	// Send Ace to the closest point for the briefing.
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Safehouse Briefing
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

safehouse_briefing()
{	
	flag_wait( "safehouse_briefing_begin" );
	
	ent_sandman = getstruct( "brief_npc_sandman_start", "targetname" );
	ent_truck   = getstruct( "brief_npc_truck_start", "targetname" );
    ent_hostage = getstruct( "brief_npc_hostage", "targetname" );
    
    // Spawn Sandman, Truck and Hostage
	npc_sandman		 = npc_spawn( "npc_sandman", true, ent_sandman );
	npc_truck		 = npc_spawn( "npc_truck", false, ent_truck );
	hostage			 = npc_spawn( "spawner_hostage", true );
	hostage.animname = "torture_enemy";
	
	// Override Sandman's run to a power walk.
	npc_sandman set_generic_run_anim( "npc_walk_unarmed_fast" );
	
	// Put hostage in death pose. He's a drone so the last frame
	// of the anim will hold
	ent_hostage thread anim_single_solo( hostage, "torture_exit" );
	
	radio_dialogue( "safehouse_snd_gother" );
	
	thread safehoue_briefing_npc_gather_and_orders();
	
	trigger_armory = GetEnt( "trigger_room_armory", "targetname" );
	
	npc_rock = npc_get( "npc_rock" );
	npc_rock set_generic_run_anim( "npc_jog_armed" );
	npc_rock delayThread( 1.0, ::npc_anim_reach_and_idle_name, "brief_npc_rock" );
	
	if ( level.player IsTouching( trigger_armory ) )
	{
		wait 0.25;
		npc_rock thread dialogue_queue( "safehouse_rck_fussisabout" );
	}
	
	wait 2.0;
	
	// Open the door
	door			= GetEnt( "torture_door_2", "targetname" );
	door_pos_final	= door.origin + ( 0, 0, 96 );
	door PlaySound( "scn_favela_garage_door" );
	door MoveTo( door_pos_final, 1.0, 0.3, 0.1 );
	
	wait 1.1;
	
	door ConnectPaths();
	
	// Send Sandman and Truck to the briefing area
	wait 0.25;
	thread safehouse_briefing_sandman_power_walk();
	wait 1.0;
	
	npc_sandman dialogue_queue( "safehouse_snd_locationofathena" );
	npc_truck thread npc_anim_reach_and_idle_name( "brief_npc_truck" );
	
	npc_sandman SetLookAtEntity( npc_truck );
	npc_sandman dialogue_queue( "safehouse_snd_pronto" );
	npc_truck dialogue_queue( "safehouse_trk_yessir" );
	
	npc_grinch = npc_get( "npc_grinch" );
	npc_sandman SetLookAtEntity( npc_grinch );
	npc_sandman dialogue_queue( "safehouse_snd_weaponloadouts" );
	flag_set( "safehouse_briefing_prepare_loadouts" );
	npc_grinch dialogue_queue( "safehouse_grn_onit" );
	
	wait 1.5;
	npc_sandman SetLookAtEntity( level.player );
	npc_sandman dialogue_queue( "safehouse_snd_gearup2" );
	
	thread safehouse_briefing_npc_gear_up();
	
	wait 0.8;
	head_track_struct = getstruct( "brief_sandman_head_track", "targetname" );
	npc_sandman.brief_head_track_ent = head_track_struct spawn_tag_origin();
	
	npc_sandman SetLookAtEntity( npc_sandman.brief_head_track_ent );
	npc_sandman dialogue_queue( "safehouse_snd_mapofberlin" );
	
	flag_set( "safehouse_briefing_handshake_ready" );
	flag_set( "safehouse_loadout_begin" );
}

safehouse_briefing_npc_gear_up()
{
	// Grinch and Carlos have already been sent
	npc_chars = npcs_get_array( [ "npc_lt", "npc_tommy", "npc_truck", "npc_rock" ] );
	
	foreach( idx, npc in npc_chars )
	{
		npc delayThread( 0.65 + float( idx ) * 0.27, ::safehouse_npc_path, "loadout_" );
	}
	
	// Make sure weapon hide system is disabled on all active npcs
	array_thread( GetAIArray( "allies" ), ::npc_interact_player_weapon_hide_disable );
}

// JC-ToDo: Should probably have a function which has an AI patrol on a path, then do anim reach on last ent on path
safehouse_briefing_sandman_power_walk()
{
	npc_sandman = npc_get( "npc_sandman" );
	
	struct = getstruct( "brief_npc_sandman_orders", "targetname" );
	npc_sandman SetGoalPos( struct.origin );
	npc_sandman waittill( "goal" );
	npc_sandman npc_anim_reach_and_idle_name( "brief_npc_sandman" );
}

safehoue_briefing_npc_gather_and_orders()
{
	ai_array = GetAIArray( "allies" );
	array_thread( ai_array, ::npc_interact_stop );
	// Move NPCs to gather locations
	npc_chars = npcs_get_array( [ "npc_grinch", "npc_carlos", "npc_lt", "npc_tommy" ] );
	
	foreach( idx, npc in npc_chars )
	{
		npc delayThread( 0.65 + float( idx ) * 0.4, ::safehouse_npc_path, "brief_", npc_get( "npc_sandman" ), "safehouse_loadout_begin" );
	}
	
	// Update NPCs on laptops
	npc_catfive = npc_get( "npc_catfive" );
	npc_fletch	= npc_get( "npc_fletch" );
	
	npc_catfive thread npc_anim_reach_and_idle_name( "struct_catfive_active", true );
	npc_fletch thread npc_anim_reach_and_idle_name( "struct_fletch_active", true );
	
	flag_wait( "safehouse_briefing_prepare_loadouts" );
	
	// Send Carlos and Grinch to get weapon loadouts
	npc_chars = npcs_get_array( [ "npc_grinch", "npc_carlos" ] );
	
	foreach( idx, npc in npc_chars )
	{
		npc delayThread( 0.65 + float( idx ) * 0.27, ::safehouse_npc_path, "loadout_" );
	}
	
}

safehouse_npc_nags( npc_targetname, end_notify, array_nags, trig_ent, dist_max, dist_min, fail_mission )
{
	if ( IsDefined( end_notify ) )
	{
		level endon( end_notify );
	}
	
	npc = npc_get( npc_targetname );
	npc endon( "death" );
	
	idx = 0;
	short_wait = false;
	
	while ( idx < array_nags.size )
	{
		if ( short_wait )
		{
			wait 0.1;
			short_wait = false;
		}
		else
		{
			wait 6.0;
		}
		
		if ( IsDefined( trig_ent ) && !level.player IsTouching( trig_ent ) )
		{
			short_wait = true;
			continue;
		}
		
		if ( IsDefined( dist_max ) && DistanceSquared( npc.origin, level.player.origin ) > squared( dist_max ) )
		{
			short_wait = true;
			continue;
		}
		
		if ( IsDefined( dist_min ) && DistanceSquared( npc.origin, level.player.origin ) < squared( dist_min ) )
		{
			short_wait = true;
			continue;
		}
		
		if ( idx >= array_nags.size - 1 && IsDefined( fail_mission ) && fail_mission )
		{
			missionFailedWrapper();
		}
		
		npc dialogue_queue( array_nags[ idx ] );
		
		idx++;
	}
	
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Safehouse Loadout
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

safehouse_loadout()
{
	flag_wait( "safehouse_loadout_begin" );
	
	wait 1.0;
	
	npc_carlos = npc_get( "npc_carlos" );
	npc_carlos thread dialogue_queue( "safehouse_cls_someaction" );
	
	safehouse_loadout_sandman_player_interact();
	thread safehouse_loadout_sandman_general_conversation();
	
	flag_set( "safehouse_loadout_begin_for_player" );
	
	thread safehouse_loadout_npc_split_up();
	thread safehouse_loadout_player_gear_up();
	
	trigger_wait_targetname( "trigger_room_armory" );
	thread safehouse_loadout_on_grinch_equip_dialogue();
	delayThread( 20.0, ::safehouse_loadout_on_player_exit_armory );
	
	msg = level waittill_any_timeout( 70.0, "safehouse_outro_begin" );
	if ( msg == "timeout" )
	{
		flag_set( "safehouse_outro_begin" );
	}
}

CONST_GRINCH_COMMENT_EQUIPMENT_DELAY		= 8;			// Time in milliseconds before Grinch will mention equipment
CONST_GRINCH_COMMENT_LIFETIME_WEAPON		= 2000;			// Time in milliseconds before a line becomes invalid

safehouse_loadout_player_gear_up()
{
	level endon( "missionfailed" );
	level endon( "safehouse_outro_begin" );
	
	if ( flag( "safehouse_outro_begin" ) )
		return;
	
	trigger_wait_targetname( "trigger_room_armory" );
	
	npc_grinch = npc_get( "npc_grinch" );
	
	npc_grinch SetLookAtEntity( level.player );
	npc_grinch thread safehouse_loadout_grinch_chatter();
	npc_grinch thread safehouse_loadout_grinch_chatter_say( "safehouse_grn_loadup" );
	
	lines_grinch					 = [];
	lines_grinch[ "rifle"		   ] = "safehouse_grn_assaultrifle";
	lines_grinch[ "smg"			   ] = "safehouse_grn_submachinegunfan";
	lines_grinch[ "spread"		   ] = "safehouse_grn_shotgunsecondary";
	lines_grinch[ "pistol"		   ] = "safehouse_grn_pistolsecondary";
	lines_grinch[ "machine_pistol" ] = "safehouse_grn_machinepistols";
	
	slot_types_used = [];
	
	directions_given = 0;
	
	while ( 1 )
	{
		level.player waittill( "armory_weapon_collected", weapon_name );
		
		// Record the slot type collected
		slot_type = armory_weapon_slot_type( weapon_name );
		slot_types_used[ slot_type ] = 1;
		
		// If the weapon_type collected has not been commented on, comment
		weapon_type = weapon_type( weapon_name );
		npc_grinch thread safehouse_loadout_grinch_chatter_say( lines_grinch[ weapon_type ], CONST_GRINCH_COMMENT_LIFETIME_WEAPON );
		
		// If the player collected a primary or a secondary for the first time
		// tell him to collect the next slot type
		if ( directions_given == 0 )
		{
			comment = undefined;
			
			if ( slot_type == "slot_primary" )
			{
				comment = "safehouse_grn_nowgrabsecondary";
			}
			else if ( slot_type == "slot_secondary" )
			{
				comment = "safehouse_grn_nowgrabprimary";
			}
			
			if ( IsDefined( comment ) )
			{
				npc_grinch thread safehouse_loadout_grinch_chatter_say( comment );
				directions_given = 1;
			}
		}
		else if ( directions_given == 1 )
		{
			if ( IsDefined( slot_types_used[ "slot_primary" ] ) && IsDefined( slot_types_used[ "slot_secondary" ] ) )
			{
				npc_grinch delayThread( CONST_GRINCH_COMMENT_EQUIPMENT_DELAY, ::safehouse_loadout_grinch_chatter_say, "safehouse_grn_gunsyouwant" );
				npc_grinch delayThread( CONST_GRINCH_COMMENT_EQUIPMENT_DELAY + 0.05, ::safehouse_loadout_grinch_chatter_say, "safehouse_grn_lethalandtactical" );
			
				directions_given = 2;
			}
		}
	}
}

safehouse_loadout_grinch_chatter()
{
	level endon( "safehouse_outro_begin" );
	
	self thread safehouse_loadout_grinch_chatter_clean_up();
	
	dialogue_used = [];
		
	while( 1 )
	{
		if ( IsDefined( self.grinch_lines ) && self.grinch_lines.size )
		{
			struct = self.grinch_lines[ 0 ];
			self.grinch_lines = array_remove_index( self.grinch_lines, 0 );
			
			// Play the dialogue line if it hasn't already been said and if
			// it's still valid meaning it's the last queue line or it hasn't
			// expired
			if ( !IsDefined( dialogue_used[ struct.dialogue_line ] ) && ( self.grinch_lines.size == 0 || !IsDefined( struct.time_invalid ) || GetTime() <= struct.time_invalid ) )
			{
				dialogue_used[ struct.dialogue_line ] = 1;
				self dialogue_queue( struct.dialogue_line );
				level notify( struct.dialogue_line );
			}
		}
		else
		{
			self waittill( "grinch_line_added" );
		}
	}
}

safehouse_loadout_grinch_chatter_say( msg, lifetime )
{
	if ( flag( "safehouse_outro_begin" ) )
		return;
	
	if ( !IsDefined( self.grinch_lines ) )
	{
		self.grinch_lines = [];
	}
	
	struct = SpawnStruct();
	struct.dialogue_line = msg;
	
	if ( IsDefined( lifetime ) )
	{
		struct.time_invalid = GetTime() + lifetime;
	}
	
	self.grinch_lines[ self.grinch_lines.size ] = struct;
	
	self notify( "grinch_line_added" );
}

safehouse_loadout_grinch_chatter_clean_up()
{
	flag_wait( "safehouse_outro_begin" );
	
	self.grinch_lines = undefined;
	self SetLookAtEntity();
}

safehouse_loadout_on_player_exit_armory()
{
	level endon( "missionfailed" );
	level endon( "safehouse_outro_begin" );
	
	if ( flag( "safehouse_outro_begin" ) )
		return;
	
	trigger_wait_targetname( "trigger_room_main" );
	
	flag_set( "safehouse_outro_begin" );
}

safehouse_loadout_on_grinch_equip_dialogue()
{
	level endon( "missionfailed" );
	level endon( "safehouse_outro_begin" );
	
	// Wait until Grinch says his last tactical line
	// then after a delay kick off the outro if it hasn't
	// started already
	level waittill( "safehouse_grn_lethalandtactical"  );
	
	wait 6.0;
	
	flag_set( "safehouse_outro_begin" );
}

safehouse_loadout_sandman_player_interact()
{
	npc_sandman = npc_get( "npc_sandman" );
	npc_sandman endon( "death" );
	
	flag_wait( "safehouse_briefing_handshake_ready" );
	
	nag_array = [ "safehouse_snd_speakwithyou", "safehouse_snd_offthismission" ];
	
	thread safehouse_npc_nags( "npc_sandman", "safehouse_loadout_nags_stop", nag_array, undefined, undefined, 180 );
	
	trigger_wait_targetname( "trigger_loadout_sandman_chat" );
	
	// Player will be locked in so model swap heroes
	thread safehouse_loadout_npc_model_swap();
	
	level.player _disableWeapon();
	
	level notify( "safehouse_loadout_nags_stop" );
	
	npc_sandman SetLookAtEntity( level.player );
	
	structs_player		  = getstructarray( "loadout_player_sandman_chat", "targetname" );
	struct_closest		  = getClosest( level.player.origin, structs_player );
	struct_anim			  = struct_closest get_linked_structs()[ 0 ];
	struct_anim.animation = "crowdsniper_crowdwatchidle_3";
	
	npc_sandman thread npc_anim_reach_and_idle( struct_anim, true );
	
	level.player SetVelocity( (0,0,0) );
	player_rig = maps\_player_rig::get_player_rig();
	level.player thread maps\_player_rig::blend_player_to_arms( 0.5 );
	player_rig Hide();
	level.player delayThread( 0.5, maps\_player_rig::link_player_to_arms, 0, 0, 0, 0 );
	player_rig delayCall( 0.5, ::Show );
	struct_anim anim_first_frame( [ player_rig ], "crib_handshake" );
	
	wait 1.0;
	
	npc_sandman npc_animate_stop();
	struct_anim thread anim_single( [ player_rig, npc_sandman ], "crib_handshake" );
	
	npc_sandman thread dialogue_queue( "safehouse_snd_didwell" );
	npc_sandman thread dialogue_queue( "safehouse_snd_joiningtheteam" );
	
	struct_anim waittill( "crib_handshake" );
	
	level.player Unlink();
	level.player _enableWeapon();
	player_rig Delete();
	
	npc_sandman npc_animate_stop();
	npc_sandman thread npc_anim_reach_and_idle( struct_anim, true );
	
	if ( DistanceSquared( npc_sandman.origin, level.player.origin ) < squared( 180 ) )
	{
		npc_sandman dialogue_queue( "safehouse_snd_regretit" );
		
		if ( DistanceSquared( npc_sandman.origin, level.player.origin ) < squared( 180 ) )
		{
			npc_sandman dialogue_queue( "safehouse_snd_gearup" );
		}
	}
	
	if ( !IsDefined( npc_sandman.brief_head_track_ent ) )
	{
		head_track_struct = getstruct( "brief_sandman_head_track", "targetname" );
		npc_sandman.brief_head_track_ent = head_track_struct spawn_tag_origin();
	}
	
	npc_sandman SetLookAtEntity( npc_sandman.brief_head_track_ent );
}

safehouse_loadout_sandman_general_conversation()
{
	npc_sandman = npc_get( "npc_sandman" );
	npc_catfive = npc_get( "npc_catfive" );
	npc_truck	= npc_get( "npc_truck" );
	
	npc_truck dialogue_queue( "safehouse_trk_choppertransport" );
	
	wait 0.6;
	npc_catfive dialogue_queue( "safehouse_cj1_screentwo" );

	npc_sandman thread npc_anim_reach_and_idle_name( "brief_npc_sandman", true );
	
	wait 0.6;
	play_sound_in_space( "safehouse_gnl_important", npc_catfive.origin );
	
	wait 0.6;
	npc_sandman dialogue_queue( "safehouse_snd_reisdorfhotel" );
	npc_sandman dialogue_queue( "safehouse_snd_faraway" );
	
	wait 0.6;
	play_sound_in_space( "safehouse_gnl_haveit", npc_catfive.origin );
	npc_sandman dialogue_queue( "safehouse_snd_graniteteam" );
	
	wait 0.6;
	play_sound_in_space( "safehouse_gnl_enroute", npc_catfive.origin );
	npc_sandman dialogue_queue( "safehouse_snd_thanksgeneral" );
	
	wait 3.0;
	
	// If the choppers aren't already flying in, complain about them
	if ( !flag( "safehouse_outro_begin" ) )
	{
		npc_sandman dialogue_queue( "safehouse_snd_thosechoppers" );
	}
}

safehouse_loadout_npc_model_swap()
{
	// Delete the characters without gear
	npc_chars = npcs_get_array( [ "npc_carlos", "npc_lt", "npc_tommy" ] );
	array_call( npc_chars, ::Delete );
	
	npc_spawn( "npc_carlos_gear", false, getstruct( "loadout_npc_carlos_ready", "targetname" ) );
	npc_spawn( "npc_lt_gear", false, getstruct( "loadout_npc_lt_ready", "targetname" ) );
	npc_spawn( "npc_tommy_gear", false, getstruct( "loadout_npc_tommy_ready", "targetname" ) );
	
	npc_grinch = npc_get( "npc_grinch" );
	npc_grinch gun_remove();
	npc_grinch forceUseWeapon( "iw5_pecheneg_mp", "primary" );
	
}

safehouse_loadout_npc_split_up()
{
	// Wait until the player comes into the armory before sending all the other NPCs out
	trigger_wait_targetname( "trigger_room_armory" );
	
	// JC-ToDo: The npc_anim_reach func should probably take a traverse type so
	// that it can make a decision on what animation to use
	npc_rock = npc_get( "npc_rock" );
	npc_rock set_generic_run_anim( "npc_jog_armed" );
	
	// Grab the npc's again now that they've been respawned
	npc_chars = npcs_get_array( [ "npc_carlos", "npc_lt", "npc_tommy", "npc_rock" ] );
	
	foreach( idx, npc in npc_chars )
	{
		npc delayThread( 0.75 + float( idx ) * 0.27, ::safehouse_npc_path, "exit_" );
	}
	
	// Make sure weapon hide system is disabled on all active npcs (handles newly created ai
	// from model swaps)
	array_thread( GetAIArray( "allies" ), ::npc_interact_player_weapon_hide_disable );
	
	thread safehouse_loadout_npc_exit_door_conversation();
}

safehouse_loadout_npc_exit_door_conversation()
{
	level endon( "safehouse_outro_begin" );
	
	npc_lt	   = npc_get( "npc_lt" );
	npc_carlos = npc_get( "npc_carlos" );
	npc_truck  = npc_get( "npc_truck" );
	npc_rock   = npc_get( "npc_rock" );
	
	wait 4.0;
	npc_lt delayCall( 0.2, ::SetLookAtEntity, npc_carlos );
	npc_carlos dialogue_queue( "safehouse_cls_sweettime" );
	
	trigger_exit_door_conversation = GetEnt( "trigger_exit_door_conversation", "targetname" );
	trigger_exit_door_conversation wait_for_trigger_or_timeout( 20.0 );
	
	npc_lt SetLookAtEntity( npc_carlos );
	npc_carlos delayCall( 0.2, ::SetLookAtEntity, npc_lt );
	npc_lt dialogue_queue( "safehouse_lt_goingwithus" );
	
	wait 0.6;
	npc_carlos dialogue_queue( "safehouse_cls_whyisthat" );
	
	wait 0.8;
	npc_lt dialogue_queue( "safehouse_lt_complainabout" );
	
	wait 0.5;
	npc_carlos dialogue_queue( "safehouse_cls_veryfunny" );
	
	wait 1.0;
	npc_carlos delayCall( 0.2, ::SetLookAtEntity, npc_truck );
	npc_lt delayCall( 0.4, ::SetLookAtEntity, npc_truck );
	npc_truck dialogue_queue( "safehouse_trk_somethingnew" );
	
	wait 0.6;
	npc_carlos delayCall( 0.4, ::SetLookAtEntity, npc_lt );
	npc_lt dialogue_queue( "safehouse_lt_probablyright" );
	
	wait 0.4;
	npc_carlos SetLookAtEntity( npc_rock );
	wait 0.4;
	
	npc_truck delayCall( 0.4, ::SetLookAtEntity, npc_carlos );
	npc_lt delayCall( 0.6, ::SetLookAtEntity, npc_carlos );
	npc_carlos dialogue_queue( "safehouse_cls_giantgrin" );
	
	// Nags for player if he's still around the exit door
	nag_array = [ "safehouse_trk_loadout", "safehouse_trk_closetoready", "safehouse_trk_secondnow" ];
	thread safehouse_npc_nags( "npc_truck", "safehouse_outro_begin", nag_array, GetEnt( "trigger_exit_door_conversation", "targetname" ) );
}


// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Safehouse Outro
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

safehouse_outro()
{
	level endon( "missionfailed" );
	
	flag_wait( "safehouse_outro_begin" );
	
	thread safehouse_outro_disable_weapon_customize();
	
	// Set up and spawn choppers
	array_spawn_function_noteworthy( "outro_chopper_a", ::on_spawn_chopper_outro );
	array_spawn_function_noteworthy( "outro_chopper_b", ::on_spawn_chopper_outro );
	activate_trigger( "trig_spawn_choppers_outro", "targetname" );
	
	npc_truck = npc_get( "npc_truck" );
	npc_truck dialogue_queue( "safehouse_trk_choppersarehere" );
	
	npc_sandman = npc_get( "npc_sandman" );
	
	if ( IsDefined( npc_sandman.brief_head_track_ent  ) )
	{
		npc_sandman.brief_head_track_ent Delete();
	}
	npc_sandman SetLookAtEntity();
	
	npc_sandman thread npc_anim_reach_and_idle_name( "exit_" + npc_sandman.targetname );
	
	npc_grinch = npc_get( "npc_grinch" );
	npc_grinch thread npc_anim_reach_and_idle_name( "exit_" + npc_grinch.targetname );
	
	// If the player is still in the armory have Grinch say "we gotta go"
	trigger_room_armory = GetEnt( "trigger_room_armory", "targetname" );
	trigger_room_armory_perimeter = GetEnt( "trigger_room_armory_perimeter", "targetname" );
	if ( level.player IsTouching( trigger_room_armory ) || level.player IsTouching( trigger_room_armory_perimeter ) )
	{
		npc_grinch thread dialogue_queue( "safehouse_grn_gottago" );
	}
	
	flag_wait( "safehouse_outro_chopper_landed" );
	
	thread safehouse_outro_npc_chopper();
	
	npc_truck dialogue_queue( "safehouse_trk_movemovemove" );
	
	npc_truck waittill( "goal" );
	
	nag_array = [ "safehouse_trk_alphateamwaiting", "safehouse_trk_getonchopper" ];
	thread safehouse_npc_nags( "npc_truck", "safehouse_outro_player_reached_chopper", nag_array );
	
	flag_wait( "safehouse_outro_player_on_chopper" );
}

safehouse_outro_disable_weapon_customize()
{
	// Once the player exits the armory disable weapon customization
	trigger_wait_targetname( "trigger_room_main" );
	armory_weapon_customize_disable();
}

safehouse_outro_npc_chopper()
{
	npc_chars = npcs_get_array( [ "npc_carlos", "npc_lt", "npc_tommy", "npc_grinch", "npc_sandman", "npc_truck" ] );
	
	foreach( idx, npc in npc_chars )
	{	
		npc npc_interact_stop();
		
		npc delayThread( max( 0.1 + float( idx ) * 0.4, 1.4 ), ::safehouse_npc_path, "chopper_" );
	}
}

CONST_PLAYER_CHOPPER_TEMP_RANGE			= 96;

on_spawn_chopper_outro()
{
	spawner_name_parts = StrTok( self.spawner.script_noteworthy, "_" );
	self.targetname = spawner_name_parts[ 1 ] + "_" + spawner_name_parts[ 2 ];
	
	// Wait for the chopper to land
	self ent_flag_init( "flag_ent_chopper_landed" );
	self ent_flag_wait( "flag_ent_chopper_landed" );
	
	flag_set( "safehouse_outro_chopper_landed" );
	
	trigger_radius = Spawn( "trigger_radius", self.origin, 0, CONST_PLAYER_CHOPPER_TEMP_RANGE, CONST_PLAYER_CHOPPER_TEMP_RANGE );
	trigger_radius EnableLinkTo();
	trigger_radius LinkTo( self, "tag_origin", (0, 0, CONST_PLAYER_CHOPPER_TEMP_RANGE * -0.5 ), (0,0,0) );
	
	trigger_radius waittill( "trigger" );
	
	flag_set( "safehouse_outro_player_reached_chopper" );
	
	dist_left  = DistanceSquared( level.player.origin, self GetTagOrigin( "tag_player_attach_left" ) );
	dist_right = DistanceSquared( level.player.origin, self GetTagOrigin( "tag_player_attach_right" ) );
	
	tag = ter_op( dist_left < dist_right, "tag_player_attach_left", "tag_player_attach_right" );
	thread lerp_player_view_to_tag( level.player, tag, 1.0, 1.0, 30, 30, 30, 30 );
	wait 0.5;
	level.player AllowStand( false );
	level.player AllowProne( false );
	level.player SetStance( "crouch" );
	wait 0.5;
	
	flag_set( "safehouse_outro_player_on_chopper" );
	
	thread radio_dialogue( "safehouse_trk_windemup" );
	
	chopper_a = GetEnt( "chopper_a", "targetname" );
	chopper_b = GetEnt( "chopper_b", "targetname" );
	
	chopper_a thread vehicle_paths( getstruct( "struct_outro_chopper_a", "targetname" ) );
	
	wait 2.0;
	
	chopper_b thread vehicle_paths( getstruct( "struct_outro_chopper_b", "targetname" ) );
	
	wait 3.0;
	
	npc_sandman	= npc_get( "npc_sandman" );
	npc_grinch	= npc_get( "npc_grinch" );
	
	radio_dialogue( "safehouse_snd_afraidof" );
	radio_dialogue( "safehouse_grn_nowsir" );
	radio_dialogue( "safehouse_snd_goodone" );
	
	flag_set( "video_outro_begin" );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Next Mission Gameplay Outro Video
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

video_outro()
{
	flag_wait( "video_outro_begin" );
	
	fade_out( 1.0, "black" );
	
	level.player FreezeControls( true );
	
	prep_cinematic( "safehouse_outro" );
	
	// Make sure the overlay is black and then fade in after a beat
	overlay = get_overlay( "black" );
	overlay.alpha = 1.0;
	
	wait 0.75;
	
	hud_hide();
	
	wait 1.0;
	thread fade_in( 1.0, "black" );
	
	thread play_cinematic( "safehouse_outro", false, "flag_stop_outro" );
	wait 40.0;
	fade_out( 2.0, "black" );
	flag_set( "flag_stop_outro" );
}
