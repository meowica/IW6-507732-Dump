#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\las_vegas_code;
#include maps\_hud_util;

#using_animtree( "generic_human" );
main()
{
	precacheStuff();
	template_level( "las_vegas" );
	
	SetDvarIfUninitialized( "debug_choppers", "0" );

	maps\createart\las_vegas_art::main();
	maps\las_vegas_fx::main();
	
	set_default_start( "entrance" );					    
	add_start( "interrogation", 	maps\las_vegas_casino::start_casino_interrogation_sequence, "casino interrogation", maps\las_vegas_casino::casino_interrogation_sequence, 	"las_vegas_transient_hotel_tr" );
	add_start( "bar", 				maps\las_vegas_casino::start_casino_bar, 					"casino bar", 			maps\las_vegas_casino::casino_bar, 						"las_vegas_transient_hotel_tr" );
	add_start( "kitchen", 			maps\las_vegas_casino::start_casino_kitchen, 				"casino kitchen", 		maps\las_vegas_casino::casino_kitchen, 					"las_vegas_transient_hotel_tr" );
	add_start( "hallway", 			maps\las_vegas_casino::start_casino_hallway, 				"casino hallway", 		maps\las_vegas_casino::casino_hallway, 					"las_vegas_transient_hotel_tr" );
	add_start( "floor", 			maps\las_vegas_casino::start_casino_floor_sequence, 		"casino floor", 		maps\las_vegas_casino::casino_floor_sequence, 			"las_vegas_transient_hotel_tr" );
	add_start( "hotel", 			maps\las_vegas_casino::start_casino_hotel_sequence, 		"casino hotel", 		maps\las_vegas_casino::casino_hotel_sequence, 			"las_vegas_transient_hotel_tr" );
	add_start( "jumpout", 			maps\las_vegas_casino::start_casino_jumpout_sequence, 		"jumpout", 				maps\las_vegas_casino::casino_jumpout_sequence, 		"las_vegas_transient_hotel_tr" );
	add_start( "slide", 			maps\las_vegas_casino::start_casino_slide_sequence, 		"slide", 				maps\las_vegas_casino::player_slide );
	add_start( "entrance", 			maps\las_vegas_entrance::start_entrance, 					"entrance", 			maps\las_vegas_entrance::entrance );
	add_start( "entrance_combat", 	maps\las_vegas_entrance::start_entrance_combat, 			"entrance combat", 		maps\las_vegas_entrance::entrance_combat, 				"las_vegas_transient_crasharea_tr" );
//	add_start( "sprint", 			maps\las_vegas_entrance::start_strip_sprint, 				"strip sprint", 		maps\las_vegas_entrance::strip_sprint, 					"las_vegas_transient_crasharea_tr" );
	add_start( "ride", 				maps\las_vegas_ride::start_ride, 							"ride", 				maps\las_vegas_ride::ride, 								"las_vegas_transient_crasharea_tr" );
	add_start( "chopper_crash", 	maps\las_vegas_entrance::chopper_crash_loop, 				"chopper crash only" );

//	intro_screen_create( &"LAS_VEGAS_INTROSCREEN_LINE_1", &"LAS_VEGAS_INTROSCREEN_LINE_5", &"LAS_VEGAS_INTROSCREEN_LINE_2" );
//	intro_screen_custom_func( ::custom_intro_screen_func );

	init_level_flags();
	
	transient_init( "las_vegas_transient_hotel_tr" );
	transient_init( "las_vegas_transient_crasharea_tr" );
	
//	createart_transient_volume( "las_vegas_transient_hotel_tr", ( -32500, -31800, 0 ), ( -25900, -25600, 3100 ) );
//	createart_transient_volume( "las_vegas_transient_crasharea_tr", ( -21000, -86000, -432 ), ( 24688, -35600, 1600 ) );
	
	add_destructible_type_transient( "toy_lv_slot_machine", 		"las_vegas_transient_hotel_tr" );
	add_destructible_type_transient( "toy_lv_slot_machine_flicker", "las_vegas_transient_hotel_tr" );

	maps\las_vegas_precache::main();
	maps\las_vegas_fx::wildlife();
	maps\_load::main();

//	if ( is_start_point_before( "entrance" ) )
//	{
//		thread transient_unloadall_and_load( "las_vegas_transient_hotel_tr" );
//	}
	
	maps\las_vegas_audio::main();
	maps\las_vegas_anim::main();
	maps\las_vegas_fx::footStepEffects();

	maps\_player_limp::init_player_limp();
	maps\las_vegas_player_hurt::init_player_hurt();
	maps\las_vegas_adrenaline::init_adrenaline();
	
	SoundSetTimeScaleFactor( "music", 0 );
	battlechatter_off( "axis" );	

	thread init_player();
	
	init_spawn_functions();
	init_threatbias_groups();
	//player_loadout();
	
	init_mainAI();
	
	thread end_of_scripting();
}

move_object()
{
	while ( 1 )
	{
		self MoveTo( self.origin + ( 0, 100, 0 ), 10 );
		self waittill( "movedone" );
		self MoveTo( self.origin + ( -100, -100, 0 ), 10 );
		self waittill( "movedone" );
	}
}

//---------------------------------------------------------
// Level Setup
//---------------------------------------------------------

precacheStuff()
{
	precacheItem( "p99" );
	precacheItem( "as50_keegan" );
	precacheItem( "ak47" );
	precacheItem( "rpg" );
	precacheItem( "iw5_p99wounded_sp_swim" );
	precacheItem( "rpg_straight" );
	precacheItem( "missile_attackheli" );
	
	precachemodel( "com_vending_can_new3_destroyed" );
	precachemodel( "weapon_ak47_clip" );
	precachemodel( "weapon_walther_p99_sp_iw5" );
	precachemodel( "com_flashlight_on" );
	precachemodel( "com_flashlight_off" );
	precachemodel( "weapon_commando_knife_bloody" );
	precachemodel( "com_cardboardbox_dusty_01" );
	precachemodel( "com_hand_radio" );
	precachemodel( "oilrig_rappelrope_50ft" );
	precachemodel( "weapon_as50" );
	precachemodel( "viewhands_player_gs_hostage" );
	precachemodel( "viewlegs_generic" );
	precachemodel( "lv_windowshatter" );
	precachemodel( "vehicle_hellfire_missle_animated" );
	precachemodel( "vehicle_aas_72x_destructible" );
	precachemodel( "lv_drapery_03_animated" );
	precachemodel( "rat" );
	
	precachemodel( "lv_palmtree_straight" );
	precachemodel( "foliage_tree_palm_bushy_1" );
	precachemodel( "foliage_pacific_tropic_shrub01_animated" );
	precachemodel( "payback_foliage_tree_palm_bushy_3" );
	precachemodel( "payback_sstorm_dwarf_palm" );
	precachemodel( "lv_palmtree_dead_1" );
	precachemodel( "foliage_desertbrush_1_animated" );
	precachemodel( "foliage_pacific_fern02_animated" );
	
	precacheShader( "burlap_sack_overlay" );
	precacheShader( "buried_sand_screen" );
	
	PreCacheShellShock ( "westminster_truck_crash" );
	PreCacheShellShock ( "las_vegas_getup" );
	
	// sandstorm stuff
	precachemodel( "foliage_tree_palm_bushy_1" );
	
//	PreCacheString ( &"LAS_VEGAS_INTROSCREEN_LINE_1" );
//	PreCacheString ( &"LAS_VEGAS_INTROSCREEN_LINE_2" );
//	PreCacheString ( &"LAS_VEGAS_INTROSCREEN_LINE_3" );
//	PreCacheString ( &"LAS_VEGAS_INTROSCREEN_LINE_4" );
//	PreCacheString ( &"LAS_VEGAS_INTROSCREEN_LINE_5" );
}

custom_intro_screen_func()
{
	flag_wait( "intro_lines" );
	maps\_introscreen::introscreen( true );	
}

init_level_flags()
{

	flag_init( "intro_lines" );

	// bar
	//flag_init( "TRIGFLAG_bar_keegan_start_move" ); - trigger
	//flag_init( "TRIGFLAG_player_moving_through_bar" ); - trigger
	//flag_init( "TRIGFLAG_player_inside_bar_room2" ); - trigger
	flag_init( "FLAG_humanshield_leader_inposition" );
	flag_init( "FLAG_start_human_shield_scene" );
	flag_init( "FLAG_humanshield_baker_nod" );
	flag_init( "FLAG_humanshield_checkdoor" );
	//flag_init( "DEATHFLAG_enemies_dead" ); - deathflag
	flag_init( "FLAG_grab_radio_done" );
	flag_init( "FLAG_bar_humanshield_done" );
	flag_init( "FLAG_diaz_stepdown_for_humanshield" );
	
	// kitchen
	//flag_init( "TRIGFLAG_player_entering_kitchen" ); - trigger
	//flag_init( "TRIGFLAG_kitchen_player_in_pantry" ); - trigger
	flag_init( "FLAG_casino_start_kitchen" );
	flag_init( "FLAG_kitchen_event_start" ); // flashlight event
	flag_init( "FLAG_walkers_entering_kitchen" );
	flag_init( "FLAG_baker_kitchen_walkthrough_done" );
	flag_init( "FLAG_kitchen_ambush_setup" );
	flag_init( "FLAG_walkers_done" );
	
	
	//flag_init( "TRACKFLAG_kitchen_exit_double_doors_open" ); - Notetrack_flag
	//flag_init( "TRACKFLAG_kitchen_event_attach_cart" ); - Notetrack_flag
	//flag_init( "TRACKFLAG_kitchen_event_detach_cart" ); - Notetrack_flag
	
	// atrium
	//flag_init( "FLAG_casino_start_hallway" ); //- trigger
	flag_init( "cleared_atrium_no_fight" );
	flag_init( "FLAG_start_atrium_combat" );
	flag_init( "FLAG_gt_at_the_gate" );
	//flag_init( "player_in_hallway_bathroom" );
	
	// gambling floor
	//flag_init( "TRACKFLAG_floor_open_gate" ); - Notetrack_flag
	//flag_init( "TRACKFLAG_floor_gate_lifed" ); - Notetrack_flag
	//flag_init( "TRACKFLAG_floor_close_gate" ); - Notetrack_flag
	
	// Escalator Room
	//flag_init( "TRIGFLAG_casino_player_in_atrium" ); - trigger
	
	// Hotel
	//flag_init( "TRIGFLAG_player_in_hotel_room" ); - trigger
	flag_init( "FLAG_end_hallway_anims_done" );
	flag_init( "FLAG_everyone_in_raid_room" );
	flag_init( "FLAG_player_start_slide" );
	flag_init( "FLAG_player_slide_complete" );
	flag_init( "raid_exit_complete" );
	flag_init( "FLAG_start_slide_birds" );
	flag_init( "FLAG_stop_feet_slide_fx" );
	
	flag_init( "player_attacked_cas_ambush" );

	// Outside 
	flag_init( "courtyard_battle_done" );
	
	flag_init( "FLAG_getup_done" );
	flag_init( "casino_entrance_convoy_passed" );
	flag_init( "player_attacked_convoy" );
	flag_init( "FLAG_traincrash_start" );
	flag_init( "flag_player_on_chopper" );
	flag_init( "vegas_strip_convoy_passed" );
	flag_init( "entrance_combat_start" );
	
	// Chopper
	flag_init( "choose_heli_anim" );
	flag_init( "choose_heli_anim_keegan" );
	flag_init( "player_off_chopper" );
	flag_init( "stop_custom_anim_run" );	
}

init_spawn_functions()
{
	
	spawners = getspawnerarray();
	foreach( spawner in spawners )
		spawner thread add_spawn_function( ::set_all_ai_targetnames, spawner );
	
	maps\las_vegas_casino::casino_spawn_functions();
	maps\las_vegas_entrance::spawn_functions();
	maps\las_vegas_ride::spawn_functions();
}

init_threatbias_groups()
{
	CreateThreatBiasGroup( "heroes" );
	level.player setThreatBiasGroup( "heroes" );
	
	maps\las_vegas_casino::casino_threatbias_groups();
}

init_player()
{
//	level.player vision_set_fog_changes( "las_vegas", 0 );
	level.player player_speed_default( 0.05 );
}

player_loadout()
{
	startPoint = GetDVar("start");

	if( startpoint == "hallway" || startpoint == "floor" )
	{
		level.player giveweapon( "kriss+acogsmg_sp" );
		level.player SwitchToWeapon( "kriss+acogsmg_sp" );	
	}
	
	else if( startpoint != "bar" && startpoint != "hallway" ) 
	{
		level.player TakeAllWeapons();
		level.player giveweapon( "ak12" );
		level.player SwitchToWeapon( "ak12" );
	}
}

init_mainAI()
{
	level.heroes = [];
	
	// ninja = keegan
	// leader = baker
	// scrub = diaz
	
	spawners = getentarray( "heroes", "targetname" );
	foreach( spawner in spawners )
	{
		
		ai = spawner spawn_ai( true, true );
	
		level.heroes[ level.heroes.size ] = ai;
		
		if( spawner.script_noteworthy == "wounded_ai" )
		{
			ai.name = "Hesh";
			level.wounded_ai = ai;
			ai forceuseweapon( "ak47", "primary" ); // ak12_eotech
		}
		else if( spawner.script_noteworthy == "ninja" )
		{
			 level.ninja = ai;
			 ai.name = "Keegan";
			 ai forceuseweapon( "kriss", "primary" ); //as50 // rsass // dragunovgl
			 ai.disable_sniper_glint = true;
			 //ai PushPlayer( true );
			 
//			 ai.sniper = spawn( "script_model", ai.origin );
//			 ai.sniper setmodel( "weapon_as50" );
//			 ai.sniper HidePart_AllInstances( "tag_silencer", "tag_heartbeat", "tag_acog_2",
//			 							    "tag_thermal_scope", "tag_flash_silenced" );
//			 ai.sniper linkto( ai, "TAG_STOWED_BACK", ( 0,0,0 ), ( 0,0,0 ) );
			 
			 //ai Attach( "weapon_as50", "TAG_STOWED_BACK" );
			 
		}
		else if( spawner.script_noteworthy == "leader" )
		{
			level.leader = ai;
			ai.name = "Merrick";
			ai forceuseweapon( "ak47", "primary" );
		}

		//ai.name = spawner.script_noteworthy;
		ai.script_noteworthy = spawner.script_noteworthy;
		ai.animname = spawner.script_noteworthy;
		ai make_hero();
		ai.ignoreSuppression = true;
		ai.suppressionwait = 0;
		ai disable_surprise();
		ai.IgnoreRandomBulletDamage = true;
		ai.disableplayeradsloscheck = true;
		ai.grenadeawareness = 0;
		ai.script_grenades = 0;
		ai.originalbasaccuracy = ai.baseaccuracy;
		ai setThreatBiasGroup( "heroes" );
	}
	
}
