#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_stealth_utility;

// CONST_MPHTOIPS = 17.6;

/*
main()
{
	intro(	);
	intro_train(  );
	powerstealth();
}
*/

section_precache()
{
	//precacheitem( "m14_scoped_silencer" );	
	// PreCacheItem( "mp5_silencer_eotech" );
	// PreCacheItem( "iw5_m4flir2_sp_reflexflir2" );
	//precacheitem( "iw5_ak47_sp_reflex_silencerunderbarrel" );
	
	PreCacheItem( "factory_knife" );
	PreCacheModel( "Viewmodel_knife_iw6" );

	// Unique heads for Hero's
	PreCacheModel( "head_opforce_russian_urban_sniper" );
	PreCacheModel( "head_cnd_test_head_a" );
	
	// Heads for enemies
	PreCacheModel( "head_russian_military_c" );
	
	PreCacheModel( "com_flashlight_on" );
	PreCacheModel( "shipping_frame_50cal" );
	// Single instance was removed from maps. Replaced below with crates version
	//PreCacheModel( "shipping_frame_bomb" );
	PreCacheModel( "shipping_frame_crates" );
	PreCacheModel( "shipping_frame_minigun" );
	PreCacheModel( "vld_playing_card_deck" );
	PreCacheModel( "cnd_cellphone_01_on_anim" );
	PreCacheModel( "com_folding_chair" );
	PreCacheModel( "weapon_usp45_sp_iw5" );
	PreCacheModel( "fac_ambush_desk_search_chair" );
	PreCacheModel( "trash_cup_tall2" );
	//"Press [{+changezoom}] to drop kill"
	PreCacheString( &"FACTORY_DROP_KILL_HINT" );
}

factory_intro_tr_precache()
{
	//PrecacheModel( "viewmodel_binoculars" );
}

section_flag_init()
{
	flag_init( "introkill_weapon_switched" );
	flag_init( "factory_introkill_jungle" );
	//flag_init( "player_start_to_ledge" );
	//flag_init( "player_approach_ledge" );
	//flag_init( "player_at_start_ledge" );
	//flag_init( "player_jump_from_ledge" );
	//flag_init( "playerkill_start_to_ledge" );
	flag_init( "playerkill_approach_ledge" );
	flag_init( "playerkill_at_start_ledge" );
	flag_init( "playerkill_jump_from_ledge" );
	flag_init( "playerkill_R3_Pressed" );
	flag_init( "player_starts_moving" );
	flag_init ( "intro_drop_kill_done" );
	flag_init( "approaching_mid_reveal" );
	flag_init( "approaching_reveal" );
	flag_init( "intro_start_slide" );
	flag_init( "ally_start_sliding" );
	flag_init ( "ally_done_sliding" );
	flag_init( "ally_at_first_reveal" );
	flag_init( "infil_water_splash" );
	flag_init( "player_at_first_reveal" );
	flag_init( "factory_exterior_reveal" );
	flag_init( "factory_exterior_reveal_between_trains" );
	flag_init( "factory_exterior_approach_infil" );
	flag_init( "intro_infil_done" );
	flag_init( "exit_train" );
	flag_init( "kill_train" );
	flag_init( "player_exited_train" );
	flag_init( "player_exited_mission_warning" );
	flag_init( "player_exited_mission" );
	flag_init( "player_mantle_train" );
	flag_init( "trig_intro_vignette" );
	flag_init( "ally_mantle_train" );
	flag_init( "intro_kill_sequence_done" );
	flag_init( "trainyard_kill_sequence_used" );
	flag_init( "initial_enemy_alerted" );
	flag_init( "first_enemy_dead" );
	flag_init( "intro_checkpoint_done" );
	flag_init( "factory_entrance_setup" );
	flag_init( "factory_entrance_start" );
	flag_init( "intro_truck_driver_dead" );
	flag_init( "truck_kill_timed_out" );
	flag_init( "player_entered_awning" );
	flag_init( "factory_entrance_reveal" );
	flag_init( "all_allies_at_entrance" );
	flag_init( "kill_tank_lights" );
	flag_init( "truck_kills_done" );
	flag_init( "start_search" );
	flag_init( "outer_perim_cleared" );
	flag_init( "card_swiped" );
	flag_init( "first_door_guard_shot" );
	flag_init( "enter_factory" );
	flag_init( "entered_factory_1" );
	flag_init( "ingress_dialogue_kickoff" );
	flag_init( "through_convevyor" );
	flag_init( "loading_area_guards_dead" );
	flag_init( "conveyor_guards" );
	flag_init( "entered_conveyor" );
	flag_init( "powerstealth_ready" );
	flag_init( "powerstealth_split" );
	flag_init( "ps_first_wave_in_position" );
	flag_init( "ps_first_kills_done" );
	flag_init( "ps_rogers_first_kill_done" );
	flag_init( "ps_second_wave_start" );
	flag_init( "ps_second_wave_dialogue_done" );
	flag_init( "ps_bravo_second_pos_ready" );
	flag_init( "ps_charlie_second_enemy_alerted" );
	flag_init( "tunnel_guard_arrived" );
	flag_init( "guard_tunnel_alerted" );
	flag_init( "catwalk_guard_dead" );
	flag_init( "keegan_killed_window_guard" );
	flag_init( "ps_foreman_office_entry" );
	flag_init( "second_charlie_kill_arrived" );
	flag_init( "throat_stab" );
	flag_init( "throat_stab_sequence_aborted" );
	flag_init( "ps_alpha_kill_second" );
	flag_init( "ps_second_kill_made" );
	flag_init( "ps_second_kills_done" );
	flag_init( "bravo_second_kill_arrived" );
	flag_init( "ps_final_wave_start" );
	flag_init( "start_break_area_kill" );
	flag_init( "ps_final_kill_made" );
	flag_init( "ps_final_kills_done" );
	flag_init( "ps_right_path_a" );
	flag_init( "ps_alpha_second_pos_ready" );
	flag_init( "ps_charlie_second_pos_ready" );
	flag_init( "ps_alpha_tunnel_approach" );
	flag_init( "ps_alpha_final_pos_ready" );
	flag_init( "ps_final_kill_bravo_ready" );
	flag_init( "player_broke_break_area" );
	flag_init( "ps_baker_at_final_kill" );
	flag_init( "ps_break_area_triggered" );
	flag_init( "break_area_first_dead" );
	flag_init( "ps_break_area_done" );
	flag_init( "ps_alert_chair_guard" );
	flag_init( "ps_alpha_done" );
	flag_init( "ps_bravo_done" );
	flag_init( "ps_charlie_done" );
	flag_init( "railing_tumble_kill_ready" );
	flag_init( "bravo_final_kill_arrived" );
	flag_init( "start_final_rogers_kill" );
	flag_init( "smoker_arrived" );
	flag_init( "powerstealth_midpoint" );
	flag_init( "speed_100" );
	flag_init( "ps_end_setup" );
	flag_init( "powerstealth_end" );
	flag_init( "open_exit_doors" );
	flag_init( "lgt_playerkill_jumpdown" );
	flag_init( "lgt_playerkill_done" );
	flag_init( "lgt_intro_reveal" );
}

section_hint_string_init()
{
	//"Press [{+actionslot 3}] to equip suppressor"
	// add_hint_string( "hint_silencer_toggle", &"FACTORY_HINT_SILENCER_TOGGLE", ::silencer_hint_breakout );
	//"Press [{+melee}] to take out the guard."
	add_hint_string( "neck_stab_hint", &"SCRIPT_PLATFORM_OILRIG_HINT_STEALTH_KILL" );
	//"Press [{+changezoom}] to drop kill"
	add_hint_string( "drop_kill_hint", &"FACTORY_DROP_KILL_HINT" );
	
}

// =====================================
// INTRO
// =====================================
intro_start()
{
	// Start player without weapons in order to use knife
	level.player DisableWeapons();
	level.player TakeWeapon( "flash_grenade" );
	level.player TakeWeapon( "fraggrenade" );
	
	flag_clear ( "trig_intro_vignette" );
	flag_clear ( "kill_train" );
		
	thread intro_truck_setup();
		
	battlechatter_off();
}

intro()
{	
	// Setting rim lights
	light_set_intro_rim_lights();
	// These 2 guys are needed for the intro - spawn them now
	maps\factory_util::squad_add_ally( "ALLY_DELTA", "ally_delta", "ally_delta" );//GREEN
	maps\factory_util::squad_add_ally( "ALLY_ECHO" , "ally_echo" , "ally_echo" );//YELLOW
	level.squad[ "ALLY_DELTA" ].ignoreall = true;
	level.squad[ "ALLY_DELTA" ].ignoreme  = true;
	level.squad[ "ALLY_ECHO"  ].ignoreall = true;
	level.squad[ "ALLY_ECHO"  ].ignoreme  = true;
	thread intro_infil();
	//thread spawn_intro_scripted_spotlight_choppers();
	
	SetSavedDvar( "compass"			, 0 );
	SetSavedDvar( "hud_showStance", 0 );
	
	thread intro_animated_chopper_spotlight();
	thread factory_reveal_activity();
	thread maps\factory_fx::fx_intro_rain();
	
	thread handle_player_leaving_mission();
	
	flag_wait( "intro_infil_done" );
	
}

intro_infil()
{
	player_start = GetEnt( "PLAYERkill_start_teleport", "targetname" );
	//level.player setOrigin( player_start.origin );
	//level.player setPlayerAngles( player_start.angles );

	thread maps\_weather::rainHard ( 10 );
	thread maps\factory_audio::audio_factory_intro_mix();
	
	//trigger temp distant horn sfx
	//thread maps\factory_audio::audio_distant_train_horn();
	//Start player intro sounds
	thread maps\factory_audio::audio_player_intro();
	
	// Don't let player move until fade in from black
	level.player FreezeControls( true );
	// player_speed_percent( 0 );
	
	// Make the initial enemies ignore the player
	level.player.ignoreme = true;
	
	thread plant_reaction_rain();
	
	// Disable all color orders for now, except on initial ally
	foreach ( guy in level.squad )
	{
		guy disable_ai_color();		
		guy.ignoreall = true;
	}
	
	// start Baker's inital animation
	thread intro_ally_startanim();
	
	level.player thread maps\factory_fx::splash_on_player( "player_entered_awning" );
	
	wait 2.4;
	
	//Keegan: Jericho 1-1 and 1-2, watch your step – you have two contacts approaching low
	level.squad[ "ALLY_BRAVO" ] thread smart_radio_dialogue( "factory_kgn_jericho11and12" );

	// Wait until fade from black before scene begins
	flag_wait( "introscreen_complete" );

	// CHAD TESTS FOR PC GOD RAYS!!!!!
	thread maps\factory_util::god_rays_intro();
	
 	// start a heavy rain on Merrick
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_ALPHA" ], "player_at_first_reveal", 0.03 );
	
 	// start splashes on player viewmodel

	node = getstruct( "factorykill_baker_introstart1", "script_noteworthy" );
	node anim_first_frame_solo( level.squad[ "ALLY_ALPHA" ], "factory_intro_jungle_drop_ally01" );

	// create blocker so player cannot pass Merrick
	thread introkill_playerblocker();
	
	//THE ENEMY THAT THE PLAYER KILLS
	spawner_start_enemies = GetEnt( "startkill_enemy2", "targetname" );
	spawner_start_enemies add_spawn_function( ::start_enemy_enemy_logic, "introkill_enemy2", "stop_loop2", "factory_intro_jungle_drop_opfor02", "factory_intro_jungle_drop_opfor02_loop" );
	Start_Enemy_Moveto_01			  = spawner_start_enemies spawn_ai();
	level.infil_dropkill_player_enemy = Start_Enemy_Moveto_01;

	//THE ENEMY THAT MERRICK KILLS
	spawner_start_enemies = GetEnt( "startkill_enemy1", "targetname" );
	spawner_start_enemies add_spawn_function( ::start_enemy_enemy_logic, "introkill_enemy1", "stop_loop1", "factory_intro_jungle_drop_opfor01", "factory_intro_jungle_drop_opfor01_loop", "factory_intro_jungle_drop_kill_opfor01" );
	Start_Enemy_Moveto_02			 = spawner_start_enemies spawn_ai();
	level.infil_dropkill_ally_enemy = Start_Enemy_Moveto_02;
	
	flag_set( "factory_introkill_jungle" );
	
	thread maps\factory_anim::factory_introkill_jungle_player( );
	
 	level.player SetWaterSheeting( 1, 3.75 );
	//level.player dirtEffect( level.player.origin );
	thread water_splash_player();

	// level.player FreezeControls( false );
	// Give the player an initial "sneaking" speed
	player_speed_percent( 0, .1 );
	level.player AllowSprint( false );
	level.player AllowJump( false );
	level.player AllowStand( false );
	level.player AllowProne( false );
	
	level.squad[ "ALLY_ALPHA" ]set_generic_run_anim( "crouch_fastwalk_F" );
	level.squad[ "ALLY_ALPHA" ]disable_cqbwalk	   (  );
//	level.squad[ "ALLY_ALPHA" ].script_pushable = false;  // Keeps player from bumping Merrick into a stand

	thread lightning_flashes();
	thread introkill_enemy_vo();
	thread check_for_infil_kill();
	exploder( "intro_hero_rain" );

	flag_wait ( "factory_introkill_jungle" );

	wait 1.05;
	
	player_speed_percent( 20, 10 );

 	//Starting second half of infil script
// 	level.squad[ "ALLY_ALPHA" ] thread intro_infil_part2();
//	level.squad[ "ALLY_ALPHA" ] thread maps\factory_audio::audio_baker_intro();
//	node anim_single_solo( level.squad[ "ALLY_ALPHA" ], "factory_intro_jungle_drop_ally01" );
//	//IPrintLnBold( "Baker passed 0" );
//	if ( !flag( "playerkill_jump_from_ledge" ) ) // && !flag ( "playerkill_approach_ledge" )
//		node thread anim_loop_solo( level.squad[ "ALLY_ALPHA" ], "factory_intro_jungle_drop_ally01_loop01", "stop_loop01" );

	level.squad[ "ALLY_ALPHA" ] infil_creep_up( node );

	flag_wait( "playerkill_at_start_ledge" );
	//IPrintLnBold( "stop_loop01" );
	node notify( "stop_loop01" );
	level.squad[ "ALLY_ALPHA" ] StopAnimScripted();
	
	level.squad[ "ALLY_ALPHA" ] intro_infil_part2( node );
	//IPrintLnBold( "Baker passed 0.5" );
}

infil_creep_up( node )
{
	level endon( "playerkill_jump_from_ledge" );
	
	self thread maps\factory_audio::audio_baker_intro();
	node anim_single_solo( self, "factory_intro_jungle_drop_ally01" );
	//IPrintLnBold( "Baker passed 0" );
	if ( !flag( "playerkill_jump_from_ledge" ) ) // && !flag ( "playerkill_approach_ledge" )
		node thread anim_loop_solo( self, "factory_intro_jungle_drop_ally01_loop01", "stop_loop01" );	
}

lightning_flashes()
{
	dir = ( -20, 60, 0 );
	SetSavedDvar( "sm_sunSampleSizeNear", 0.025 );
	thread maps\factory_fx::lightning_flash( dir, 3, 0 );
	wait 2.7;
	
	lgt = GetEnt( "lightning_flash_01", "script_noteworthy" );	
	//thread maps\factory_fx::lightning_flash_primary( lgt, RandomIntRange( 2, 4 ) );	
	maps\factory_fx::lightning_flash( dir, RandomIntRange( 2, 4 ), 1 );
	wait 1.0;	
	//thread maps\factory_fx::lightning_flash_primary( lgt, RandomIntRange( 4, 6 ) );	
	maps\factory_fx::lightning_flash( dir, RandomIntRange( 4, 6 ), 0 );
	wait 0.6;
	thread maps\factory_fx::lightning_flash( dir, 3 );
	wait 1.8;
		
	lgt = GetEnt( "lightning_flash_02", "script_noteworthy" );
	thread maps\factory_fx::lightning_flash_primary( lgt, RandomIntRange( 3, 5 ) );
	SetSavedDvar( "sm_sunSampleSizeNear", 0.25 );
	
	while ( !flag( "lgt_playerkill_jumpdown" ) )
	{
		maps\factory_fx::lightning_flash( dir, RandomIntRange( 2, 4 ) );
		wait RandomFloatRange( 0.3, 3.6 );
	}
	
	wait 0.2;
	//lightning on kill
	for ( i = 0; i < RandomIntRange( 2, 4 ); i++ )
	{
		thread maps\factory_fx::lightning_flash( dir, RandomIntRange( 3, 5 ), 4 );
		wait RandomFloatRange( 0.4, 4.3 );
	}
	wait 1.0;
	SetSavedDvar( "sm_sunSampleSizeNear", 0.25 );
	wait 1.0;
	delayThread( 0.7, maps\_weather::lightningThink, maps\factory_fx::lightning_normal, maps\factory_fx::lightning_flash );

}



/*
player_pull_knife()
{
	wait 0.3;
	// TRYING OUT GIVING THE PLAYER A KNIFE FROM THE BEGINNING
	level.player TakeAllWeapons();
	level.player GiveWeapon( "factory_knife" );
	level.player EnableWeapons();
	level.player SwitchToWeapon( "factory_knife" );
	level.player.active_anim = false;
}
*/

player_movement_reset()
{
	level endon( "intro_infil_done" );
	
	flag_wait( "playerkill_jump_from_ledge" );
	
	player_speed_percent( 75 );
	
	level.player AllowJump( true );
	level.player AllowStand( true );
	level.player AllowProne( true );
	level.player AllowSprint( true );
}

intro_infil_part2( node )
{
	thread intro_infil_part2_dialog();
	
	flag_set( "playerkill_approach_ledge" );
	
	thread player_movement_reset();
	
	if ( !IsDefined( self.has_knife ) )
		self thread ally_knife();
	
	if ( !flag ( "playerkill_jump_from_ledge" ) )
	{
		self thread ally_introkill_knife_anim();
	}

	flag_wait( "playerkill_jump_from_ledge" );

	// turning on trains after player jumps down
	thread loop_train( 2.40, 8000, 30.0 );

	node notify( "stop_loop02" );
	self StopAnimScripted();

	// wait a bit only if the player does the R3 version of the kill
	if ( flag( "playerkill_R3_Pressed" ) )
	{
		level.player thread maps\factory_audio::audio_player_intro_jump_kill();
		wait 0.1;
		flag_set( "lgt_playerkill_jumpdown" );
		wait 7.9;
	}
		
	player_speed_percent( 75 );
	level.player AllowJump( true );
	level.player AllowStand( true );
	level.player AllowProne( true );
	level.player AllowSprint( true );
	
	autosave_by_name( "intro_kill_done" );
	
	flag_wait ( "intro_start_slide" );
	
	thread maps\factory_audio::sfx_plr_mudslide();
	level.player thread slide_orient_player( );
	    
	flag_set( "lgt_intro_reveal" );
	
	//set a flag for an audio change that happens during the slide
	flag_set( "music_jungle_slide" );
	flag_set( "kill_train" );
	 
	// allies enter scene
	fence_infil_teleport = GetNode( "ALLY_BRAVO_wallhopstart_teleport", "targetname" );
	level.squad[ "ALLY_BRAVO" ] teleport_ai( fence_infil_teleport );	
	fence_infil_teleport = GetNode( "ALLY_CHARLIE_wallhopstart_teleport", "targetname" );
	level.squad[ "ALLY_CHARLIE" ] teleport_ai( fence_infil_teleport );	
	fence_infil_teleport = GetNode( "ALLY_DELTA_wallhopstart_teleport", "targetname" );
	level.squad[ "ALLY_DELTA" ] teleport_ai( fence_infil_teleport );	
	thread intro_allied_entrance();
	
	flag_wait ( "intro_end_slide" );
	
	// tagTJ - Should get the weapon to default to the silencer, but this'll do for now
	/*
	weapon = level.player GetCurrentWeapon();
	if ( weapon == level.default_weapon )
		level delayThread ( 2, ::display_hint_timeout, "hint_silencer_toggle", 4 );
	*/
	if ( !flag ( "ally_start_sliding" ))
	{
		thread ally_slide_now();
	}
	
	level.player SetMoveSpeedScale ( 1.0 );
	
	flag_wait ( "player_near_train_kill" );
	
	flag_set( "intro_infil_done" );
}

slide_orient_player()
{
	self EnableSlowAim();
	while ( !flag ("intro_end_slide" ) )
	{
		angles = self GetPlayerAngles();
		// iprintln ( "angles: " + angles );
		if ( angles [1] > -60)
			self SetPlayerAngles( (angles[0], angles[1] - 5, angles[2]) );
		else if ( angles [1] < -120)
			self SetPlayerAngles( (angles[0], angles[1] + 5, angles[2]) );
		wait 0.05;
	}
	self DisableSlowAim();
}

intro_infil_part2_dialog()
{
	level endon ( "intro_infil_done" );
	
	flag_wait( "playerkill_jump_from_ledge" );

	// enemies react via dialogue to player jumping down
	radio_dialogue_stop();
	
	wait 7.9;
	
	//Merrick: They’re down Creeper 1-1, we’re moving to Entry A
	self thread smart_dialogue ( "factory_mrk_theyredowncreeper11" );
	thread maps\factory_audio::audio_distant_train_horn();

	wait 5.0;
	
	//Merrick: House Main. We have eyes on the factory. Over.
	self smart_dialogue( "factory_mrk_housemainwehave" );	
	// Overlord: Roger Jericho, move to Black Zone, get confirmation of LOKI then evac, ARCLIGHT will follow directly.
	
	//Overlord: Roger Jericho, move to Black Zone, get confirmation of LOKI then evac, ARCLIGHT will follow directly.
	self smart_radio_dialogue( "factory_hqr_rogerjerichomoveto" );

	// Only playing this line if player is not going too fast
	// Merrick: Copy that. Approaching entry.
	if ( !flag ( "approaching_reveal" ) )
	{
		//Merrick: Copy that. Approaching entry.
		self thread smart_dialogue( "factory_mrk_copythatapproachingentry" );
	}
	
	flag_wait ( "approaching_reveal" );

	if ( !flag ( "player_at_first_reveal" ) )
	{
		//Merrick: Jericho at Entry A
		self smart_dialogue( "factory_mrk_jerichoatentrya" );
	}
	//Keegan: Creeper at Entry B
	level.squad[ "ALLY_CHARLIE" ] thread smart_radio_dialogue( "factory_kgn_creeperatentryb" );
	//level.squad[ "ALLY_BRAVO" ] thread smart_radio_dialogue( "factory_diz_eyesonyou" );	
	
	flag_wait( "player_at_first_reveal" );
	
	// fixme - !!!! FIX FOR REVEAL BUILD - NEEDS TO BE REVMOVED
	// second part of fix for the flickering that occurs when vision sets are transitioned between using client riggers
	//thread maps\_utility::vision_set_fog_changes( "", 1 );

	if ( !flag ( "intro_end_slide" ))
	{
		//Merrick: Copy – moving. Regroup… fifty meters
		self thread smart_radio_dialogue( "factory_mrk_copymovingregroupfifty" );
	}
	flag_wait ( "intro_end_slide" );

	// CHAD TESTS FOR PC GOD RAYS!!!!!
	//thread maps\factory_util::god_rays_train_passing();

	//Merrick: We see you, Creeper – moving to RV
	self thread smart_dialogue( "factory_mrk_weseeyoucreeper" );

}

ally_introkill_knife_anim()
{
	level endon( "playerkill_jump_from_ledge" );
	
	node = getstruct( "factorykill_baker_introstart1", "script_noteworthy" );
	
	node anim_single_solo( self, "factory_intro_jungle_drop_ally01_ptr02" );
	node thread anim_loop_solo( self, "factory_intro_jungle_drop_ally01_loop02", "stop_loop02" );
}

ally_knife()
{
	self endon( "knife_done" );
	
	flag_wait( "playerkill_at_start_ledge" );
	
	self thread maps\factory_audio::audio_ally_intro_knife_pullout();
	wait 0.1;
	//IPrintLnBold( "spawning knife" );
	self Attach( "Viewmodel_knife_iw6", "tag_inhand", true );
	self.has_knife = true;
	flag_wait( "playerkill_jump_from_ledge" );
	//if ( flag( "playerkill_R3_Pressed" ) )
		//wait 0.7;
	//if( IsAlive( level.infil_dropkill_baker_enemy ) )
		wait 7.2;
	//IPrintLnBold( "deleting knife" );
	self Detach( "Viewmodel_knife_iw6", "tag_inhand", true );
	self.has_knife = undefined;
	
	self notify( "knife_done" );
}

introkill_playerblocker()
{
	playerblocker		 = GetEnt( "introkill_playerblocker", "targetname" );
	playerblocker.origin = level.squad[ "ALLY_ALPHA" ].origin + ( 0, 15, 0 );
	//playerblocker LinkTo ( level.squad[ "ALLY_ALPHA" ] );
	while ( 1 )
	{
		playerblocker.origin = level.squad[ "ALLY_ALPHA" ].origin + ( 0, 15, 0 );
		if ( flag( "playerkill_at_start_ledge" ) )
			break;
		wait 1.05;
	}
	//remove blocker so player can move forward
	playerblocker Delete();
}

introkill_enemy_vo()
{
	level endon( "playerkill_jump_from_ledge" );
	wait 2.3;
	while ( true )
	{
		if ( !flag( "playerkill_jump_from_ledge" ) )
			//Venezuelan2: I see that.  I had the same thing happen last time I came through.  This shipment is temperature controlled, but as long as I've got petrol I can wait.
			level.infil_dropkill_player_enemy smart_dialogue ( "factory_vs2_seethat" );
		//wait 6.0;
		if ( !flag( "playerkill_jump_from_ledge" ) )
			//Venezuelan3: Yeah, sorry.  We've been contemplating building more loading ramps.  Just need to get some funds in new bank accounts, if you know what I mean.
			level.infil_dropkill_player_enemy smart_dialogue ( "factory_vs3_yeahsorry" );
		//wait 6.0;
		if ( !flag( "playerkill_jump_from_ledge" ) )
			//Venezuelan2: Yeah, totally.  I have a secret account that I keep hidden.  Hey, what's the upcoming schedule look like?  Am I gonna be needed?
			level.infil_dropkill_player_enemy smart_dialogue ( "factory_vs2_secretaccount" );
		//wait 6.0;
		if ( !flag( "playerkill_jump_from_ledge" ) )
			//Venezuelan3: Yeah, we have more raw materials coming in from the new territories.  Should easily double the workload.
			level.infil_dropkill_player_enemy smart_dialogue ( "factory_vs3_doubleworkload" );
		//wait 6.0;
		if ( !flag( "playerkill_jump_from_ledge" ) )
			//Venezuelan1: (short whistle) - OK, hold on!  Stop!...Pull up!....Right...there, right there!  OK!
			level.infil_dropkill_player_enemy smart_dialogue ( "factory_vs1_holdon" );
		//wait 6.0;
	}
}

check_for_infil_kill()
{
	level.player endon( "death" );
	level endon( "intro_infil_done" );
	
	thread check_for_player_fall();

	wait 2;
	while ( true )
	{
		if ( level.player.angles[ 1 ] < -13 && level.player.angles[ 1 ]  > -80 && flag( "playerkill_at_start_ledge" ) && !flag( "playerkill_jump_from_ledge" ) && ( level.player IsTouching( GetEnt( "vol_player_at_jumpdown", "script_noteworthy" ) ) ) )
		{
			//self ready_to_stab();
			level.player AllowMelee( false );
			level.player thread display_hint( "drop_kill_hint" );
			// IPrintLnBold( "ready!"+level.player.angles[1] );

			/*			
			if ( !flag ( "introkill_weapon_switched" ) )
			{
	 			level.player TakeAllWeapons();
				level.player GiveWeapon( "factory_knife" );
				level.player SwitchToWeapon( "factory_knife" );
				flag_set( "introkill_weapon_switched" );
			}
			*/
			
			//if ( level.player MeleeButtonPressed() )
			if ( level.player MeleeButtonPressed() && IsAlive( level.infil_dropkill_player_enemy ) && !level.player IsMeleeing() && !level.player IsThrowingGrenade() )
			{
				//IPrintLnBold( "R3 pressed" );
				flag_set( "playerkill_R3_Pressed" );
				flag_set( "playerkill_jump_from_ledge" );
				flag_set( "playerkill_approach_ledge" );
				flag_set( "playerkill_at_start_ledge" );
				stop_exploder( "intro_hero_rain" );
				thread introkill_player_splash();
				level.player.in_stab_animation = true;
				
				player_rig = player_start_stabbing();
				
				// level.player SetStance( "crouch" );
			
				anim_org = getstruct( "factorykill_baker_introstart1", "script_noteworthy" );	

				// player_rig = spawn_anim_model( "player_rig" );
				// player_rig Hide();
				//IPrintLnBold( "Hiding Rig" );
				
				guys		= [];
				guys[ 0 ]	= player_rig;
				guys[ 1 ]	= level.infil_dropkill_player_enemy;
				//guys[ 1 ] = "introkill_enemy1";
			
				// move ents to first frame of anim
				anim_org anim_first_frame_solo( player_rig, "factory_intro_jungle_drop_kill_player" );
			
				// interpolate player to anim start
				blend_time = 0.15;
				arc		   = 30;
				level.player PlayerLinkToBlend( player_rig, "tag_player", blend_time, 0.25, 0.25 );
				wait blend_time;
				level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, true );
				player_rig Show();
				//wait blend_time;
			
				if ( IsAlive( level.infil_dropkill_player_enemy ) )
				{
					// show knife
					player_rig Show();
					player_rig Attach( "weapon_parabolic_knife", "tag_weapon_right", true );
				
					// play anims
					level.infil_dropkill_player_enemy thread flashlight_drop_detail();
					level.infil_dropkill_player_enemy delayThread( 2, maps\factory_anim::kill_no_react );
//					level.infil_dropkill_player_enemy notify( "stop_animating" );
					level.infil_dropkill_player_enemy StopAnimScripted();
					
					anim_org anim_single( guys, "factory_intro_jungle_drop_kill_player" );
					//AssertEx( !IsAlive( level.infil_dropkill_player_enemy ), "victim not killed during animation." );
				
					// clean up
					player_rig Detach( "weapon_parabolic_knife", "tag_weapon_right", true );
					player_rig Hide();
				}
				// teleport player up to make him not be stuck in ground, then force to crouch
				//level.player.origin = level.player.origin + (0, -20, 0);
				//level.player SetStance( "crouch" );

				level.player Unlink();
				player_rig Delete();	

				//wait( blend_time );
				
				level.player.in_stab_animation = undefined;
				//level.player SetStance( "crouch" );

				wait 0.8;
				
				flag_clear ( "introkill_weapon_switched" );
				player_done_stabbing();
				
				/*
				level.player thread maps\factory_util::thermal_vision();
				level thread maps\factory_fx::fx_track_thermal();
				
				SetSavedDvar( "compass"			, 0 );	
				SetSavedDvar( "hud_showStance", 0 );
				*/
				flag_set ( "intro_drop_kill_done" );
				
				return;
			}
		}
		else
		{
			level.player AllowMelee( true );
		
			/*
			if ( flag ( "introkill_weapon_switched" ) )
			{
				flag_clear ( "introkill_weapon_switched" );
	 			level.player TakeAllWeapons();
				level.player GiveWeapon( level.default_weapon );
				level.player SwitchToWeapon ( level.default_weapon );
				level.player GiveWeapon( "uspflir2_silencer" );
				level.player SetOffhandPrimaryClass( "frag" );
				level.player setOffhandSecondaryClass( "flash" );
			}
			*/
		}
		
		wait 0.02;
	}
	
}

check_for_player_fall()
{
	level.player endon( "death" );
	level endon( "intro_infil_done" );
	flag_wait( "playerkill_jump_from_ledge" );
	wait 0.5;
	if ( !flag( "playerkill_R3_Pressed" ) )
	{
		flag_clear ( "introkill_weapon_switched" );
		level.old_weapon = "uspflir2_silencer";
		player_done_stabbing();
		// level.player AllowStand( true );
		// level.player AllowSprint( true );
		while ( isAlive ( level.infil_dropkill_player_enemy ))
		{
			wait .1;	   	
		}
		
		// Switching player to default weapon if they dropped down and took on the enemies
		if ( !flag( "playerkill_R3_Pressed" ) )
		{
			wait 0.5;
			level.player SwitchToWeapon( level.default_weapon );
			level.player TakeWeapon( "factory_knife" );
		}
	}
	else
	{
		while ( isdefined (level.player.in_stab_animation ) )
		{
			   wait .1;
		}
	}
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
				
	SetSavedDvar( "compass"			, 1 );	
	SetSavedDvar( "hud_showStance", 1 );
	
	flag_set ( "intro_drop_kill_done" );
	
}

player_start_stabbing()
{
	level.player HideViewModel();
	level.player.active_anim = true; // Prevents thermal toggle
	// level.player GiveWeapon ("factory_knife");
	// level.player SwitchToWeapon ( "factory_knife" );
	
	level.old_weapon = level.player GetCurrentWeapon();
	
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player FreezeControls ( true );
	
	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();
	
	return player_rig;
}

player_done_stabbing( )
{
	level.player.active_anim = false; // Allows thermal toggle
	level.player TakeWeapon ("factory_knife");
	level.player EnableWeapons();
	level.player EnableWeaponswitch();
	if ( !flag( "playerkill_R3_Pressed" ) )
	{
		level.player SwitchToWeapon ( level.old_weapon );
	}
	else
	{
		level.player SwitchToWeapon ( level.default_weapon );	
	}
	level.player EnableOffhandWeapons();
	level.player ShowViewModel();
	
	level.player AllowMelee ( true );
	level.player FreezeControls ( false );
}

introkill_player_splash()
{
	//IPrintLnBold ( "lightning" );
	dir = ( 45, 45, 0 );
	thread maps\factory_fx::lightning_flash( dir, 4 );
	wait 1.05;
	// JEREMY - ADDED TEMP SOUND HERE
	//thread maps\factory_audio::sfx_introkill_splash_player();
	wait 0.33;
	//IPrintLnBold ( "splash!" );
	exploder( "intro_kill_splash_01" );
	level.player PlayRumbleOnEntity( "artillery_rumble" );
	wait 0.97;
	//IPrintLnBold ( "lightning" );
	dir = ( 45, 45, 0 );
	thread maps\factory_fx::lightning_flash( dir, 4 );
}

introkill_ally_splash()
{
	wait 3.05;
	//IPrintLnBold ( "splash!" );
	// JEREMY - ADDED TEMP SOUND HERE
	wait 0.23;
	//thread maps\factory_audio::sfx_introkill_splash_baker();
	exploder( "intro_kill_splash_02" );
	wait 0.95;
	exploder( "intro_kill_splash_02a" );
	wait 0.52;
	//IPrintLnBold ( "lightning" );
	dir = ( 45, 45, 0 );
	thread maps\factory_fx::lightning_flash( dir, 4 );
//	Exploder( "intro_kill_splash_03" );							// Blood should go here.
}

start_enemy_enemy_logic( animname, stop_loop, introanim, idleanim, deathanim )
{
	self endon( "death" );
//	level endon( "playerkill_jump_from_ledge" );

	// Set up our enemy
	//IPrintLnBold( "enemy created!" );
	thread maps\factory_fx::rain_on_actor( self, "player_at_first_reveal", 0.1 );
	//thread maps\factory_fx::splash_on_actor( self, "player_at_first_reveal", 3 );
	self.animname = animname;

	self.script_grenades	= 0;
	self.disablearrivals	= true;
	self.disableexits		= true;
	self.allowdeath			= true;
	self.health				= 1;
	//self.moveplaybackrate = 2.2;
	
	self.ignoreall = true;
	self.ignoreme  = true;

	if ( !IsDefined( deathanim ) )
	{
		self attach_flashlight( true );
		//IPrintLnBold( "attach flashlight " + animname );
	}

	if ( IsDefined( deathanim ) )
		thread introkill_ally_enemy_killcheck();
	else
		thread introkill_player_enemy_killcheck();
		
	node = getstruct( "factorykill_baker_introstart1", "script_noteworthy" );

	// CF - holding back enemy with flashlight for a bit to see in distance, then getting him close very quickly
	delayThread( 0.5, ::anim_set_rate_single, self, introanim, 0.6 );

	if ( !IsDefined( deathanim ) )
		delayThread( 6.1, ::anim_set_rate_single, self, introanim, 1.2 );
	else
		delayThread( 8.1, ::anim_set_rate_single, self, introanim, 1.6 );

	// HACK: Need to be very careful with this line.  It currently "resurrects" any animations we've 
	// stopped if this delay thread triggers after the dropdown kill has been initiated.  Setting the delay 
	// any longer will cause the walk up animation to try and play at the same time as the dropdown death
	delayThread( 10, ::anim_set_rate_single, self, introanim, 1 );

	self thread start_enemy_anims( node, introanim, idleanim, stop_loop );
	
	self waittill( "stop_animating" );
	
//	flag_wait( "playerkill_jump_from_ledge" );
	
	node notify( stop_loop );
	self StopAnimScripted();
}

start_enemy_anims( node, introanim, idleanim, stop_loop )
{
	level endon( "playerkill_jump_from_ledge" );
	self endon( "stop_animating" );
	
	node anim_single_solo( self, introanim );
	
	//IPrintLnBold ( "idle " + idleanim );
	node anim_loop_solo( self, idleanim, stop_loop );	
}

introkill_ally_enemy_killcheck()
{
	flag_wait( "playerkill_jump_from_ledge" );
	// wait a bit only if the player does the R3 version of the kill
	if ( IsAlive( level.infil_dropkill_ally_enemy ) )
	{
		level.infil_dropkill_ally_enemy.health = 1000;
//		if ( flag( "playerkill_R3_Pressed" ) )
			//wait 0.7;

		thread introkill_ally_splash();
		node = getstruct( "factorykill_player_introstart1", "script_noteworthy" );
		node notify( "stop_loop02" );
		level.squad[ "ALLY_ALPHA" ] StopAnimScripted();
		node notify( "stop_loop" );
		
		level.squad[ "ALLY_ALPHA" ] thread maps\factory_audio::audio_ally_intro_jump_kill();
		
//		node anim_first_frame_solo( level.infil_dropkill_ally_enemy, "factory_intro_jungle_drop_kill_opfor01" );
		node thread anim_single_solo( level.squad[ "ALLY_ALPHA" ], "factory_intro_jungle_drop_kill_ally01" );
		level.infil_dropkill_ally_enemy delayThread( 5.8, maps\factory_anim::kill_no_react );
		node anim_single_solo( level.infil_dropkill_ally_enemy, "factory_intro_jungle_drop_kill_opfor01" );
	}
	else
	{
		wait 2;
		temp_teleport = GetNode( "StartKill_Enemy_Moveto_02", "targetname" );
		level.squad[ "ALLY_ALPHA" ] teleport_ai( temp_teleport );	
	}
}

introkill_player_enemy_killcheck()
{
	flag_wait( "playerkill_jump_from_ledge" );
	
	if ( !flag( "playerkill_R3_Pressed" ) )
	{
		node = getstruct( "factorykill_player_introstart1", "script_noteworthy" );
		node notify( "stop_loop2" );
		waittillframeend;
		level.infil_dropkill_player_enemy StopAnimScripted();
		level.infil_dropkill_player_enemy.ignoreall		= false;
		level.infil_dropkill_player_enemy.ignoreme		= false;
		level.player.ignoreme							= false;
		level.infil_dropkill_player_enemy.favoriteenemy = level.player;
		level.infil_dropkill_player_enemy.see_player	= true;
		//level.infil_dropkill_player_enemy SetGoalPos( self.origin );
		level.infil_dropkill_player_enemy GetEnemyInfo( level.player );
		//self thread flashlight_drop_detail();
		//IPrintLnBold( "activating player enemy" );
	}
}

water_splash_player()
{
	level endon( "intro_truck_driver_dead" );
	while ( 1 )
	{
		
		if ( flag ( "infil_water_splash" ) )
		{
			level.player SetWaterSheeting( 1, 1.75 );
			level.player dirtEffect( level.player.origin );
			wait RandomFloatRange ( 0.2, 0.5 );
		}
		wait 0.5;
	}
}

plant_reaction_rain()
{
	level endon( "music_jungle_slide" );
	while ( 1 )
	{
		thread maps\factory_fx::fx_set_wind( RandomFloatRange ( 0.5, 1.5 ), RandomFloatRange ( 0.5, 1.5 ), 1.8, RandomFloatRange ( 1.2, 1.9 ) );
		wait RandomFloatRange ( 0.8, 1.5 );
		thread	maps\factory_fx::fx_set_wind( level.defaultReactiveWind[ "strength" ], level.defaultReactiveWind[ "amplitudeScale" ], level.defaultReactiveWind[ "frequencyScale" ], 3.0 );
		wait RandomFloatRange ( 8.5, 15.5 );
	}
}

intro_ally_startanim()
{
	// start Baker in low crouched walk	
	level.squad[ "ALLY_ALPHA" ] set_generic_run_anim( "crouch_fastwalk_F" );
	thread intro_ally_wait_then_slide();
}

intro_ally_wait_then_slide()
{
	level endon ( "ally_start_sliding" );
	flag_wait( "playerkill_jump_from_ledge" );
	
	level.squad[ "ALLY_ALPHA" ] SetLookAtEntity();
	
	flag_set( "lgt_playerkill_done" );
	
	thread intro_keep_ally_ahead();

	level.squad[ "ALLY_ALPHA" ].goalradius = 8;
	node = getstruct( "factory_baker_slidestart", "script_noteworthy" );
	node anim_reach_solo( level.squad[ "ALLY_ALPHA" ], "factory_intro_jungle_slide_baker_exit" );
	node anim_first_frame_solo( level.squad[ "ALLY_ALPHA" ], "factory_intro_jungle_slide_baker_exit" );

	flag_set( "ally_at_first_reveal" );
	
	flag_wait( "player_at_first_reveal" );
	
	thread ally_slide_now();
}

ally_slide_now()
{
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_ALPHA" ], "player_entered_awning", 0.1 );
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_BRAVO" ], "player_entered_awning", 0.1 );
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_CHARLIE" ], "player_entered_awning", 0.1 );
	
	node = getstruct( "factory_baker_slidestart", "script_noteworthy" );
	
	level.squad[ "ALLY_ALPHA" ] SetGoalPos ( level.squad[ "ALLY_ALPHA" ].origin );
	
	level.squad[ "ALLY_ALPHA" ] clear_run_anim();
	level.squad[ "ALLY_ALPHA" ] enable_cqbwalk();
	level.squad[ "ALLY_ALPHA" ] disable_sprint(	);
	level.squad[ "ALLY_ALPHA" ].moveplaybackrate = 1.0; // return to normal speed

	node notify( "stop_loop" );
	
	waittillframeend;
	
	thread maps\factory_audio::sfx_bak_mudslide();
	
	flag_set( "ally_start_sliding" );
	
	node anim_single_solo( level.squad[ "ALLY_ALPHA" ], "factory_intro_jungle_slide_baker_exit" );
	
	level.squad[ "ALLY_ALPHA" ] enable_ai_color_dontmove();
	self.disableplayeradsloscheck = true;
	
	flag_wait( "intro_end_slide" );
	
	// Move ally up to the staging area for the train kill
	self enable_ai_color();
	maps\factory_util::safe_trigger_by_targetname( "intro_infil_train_kill_staging" );
	
	flag_set( "ally_done_sliding" );
}

intro_keep_ally_ahead()
{
	level endon( "ally_at_first_reveal" );
	wait 15;
	//IPrintLnBold( "intro_keep_Baker_ahead" );
	/*
	if ( level.player GetStance() == "stand" )
	{
		level.squad[ "ALLY_ALPHA" ]clear_run_anim(	);
		level.squad[ "ALLY_ALPHA" ]enable_cqbwalk(	);
	}
	else
	{
		level.squad[ "ALLY_ALPHA" ]set_generic_run_anim( "crouch_fastwalk_F" );
		level.squad[ "ALLY_ALPHA" ]disable_cqbwalk	   (  );
	}
	*/
	slow = 0.6;
	med = 0.7;
	normal = 0.75;
	while ( 1 )
	{
		if ( flag ( "approaching_reveal" ) )
		{
			//IPrintLnBold( "approaching_reveal" );
			// ramp up speeds to regular
			//if (current_speed < desired_speed)
			//	current_speed = current_speed + 0.1;
			if (slow < 1.0)
				slow = slow + 0.1;
			if (med < 1.0)
				med = med + 0.1;
			if (normal < 1.0)
				normal = normal + 0.1;
		}
		if ( level.player.origin[ 1 ] < level.squad[ "ALLY_ALPHA" ].origin[ 1 ] - 0 )
		{
			//IPrintLnBold( "Player is past Baker" );
			level.squad[ "ALLY_ALPHA" ].moveplaybackrate = 1.1;
			level.squad[ "ALLY_ALPHA" ]disable_sprint(	);
			level.squad[ "ALLY_ALPHA" ]enable_cqbwalk(	);
			level.squad[ "ALLY_ALPHA" ]clear_run_anim(	);
			if ( level.player.origin[ 1 ] < level.squad[ "ALLY_ALPHA" ].origin[ 1 ] - 100 )
			{
				//IPrintLnBold( "Player is WAY past Baker" );
				level.squad[ "ALLY_ALPHA" ].moveplaybackrate = 1.1;
				level.squad[ "ALLY_ALPHA" ]enable_sprint  (	 );
				level.squad[ "ALLY_ALPHA" ]disable_cqbwalk(	 );
			}
		}
		else
		{
			if ( level.player.origin[ 1 ]  > level.squad[ "ALLY_ALPHA" ].origin[ 1 ] + 400 )
			{
				//IPrintLnBold( "Baker is way far ahead" );
				level.squad[ "ALLY_ALPHA" ].moveplaybackrate = slow; // 
				level.squad[ "ALLY_ALPHA" ]set_generic_run_anim( "crouch_fastwalk_F" );
				level.squad[ "ALLY_ALPHA" ]disable_sprint	   (  );
				level.squad[ "ALLY_ALPHA" ]disable_cqbwalk	   (  );
			}
			else
			{
				if ( level.player.origin[ 1 ]  > level.squad[ "ALLY_ALPHA" ].origin[ 1 ] + 190 )
				{
					//IPrintLnBold( "Baker is kinda far ahead" );
					if ( level.player GetStance() == "stand" )
					{
						level.squad[ "ALLY_ALPHA" ].moveplaybackrate = med;
						level.squad[ "ALLY_ALPHA" ]disable_sprint(	);
						level.squad[ "ALLY_ALPHA" ]enable_cqbwalk(	);
					}
					else
					{
						level.squad[ "ALLY_ALPHA" ].moveplaybackrate = med;
						level.squad[ "ALLY_ALPHA" ]set_generic_run_anim( "crouch_fastwalk_F" );
						level.squad[ "ALLY_ALPHA" ]disable_sprint	   (  );
						level.squad[ "ALLY_ALPHA" ]disable_cqbwalk	   (  );
					}
				}
				else
				{
					//IPrintLnBold( "Baker is the pocket" );
					if ( level.player GetStance() == "stand" )
					{
						level.squad[ "ALLY_ALPHA" ]disable_sprint(	);
						level.squad[ "ALLY_ALPHA" ]enable_cqbwalk(	);
						level.squad[ "ALLY_ALPHA" ].moveplaybackrate = normal;
					}
					else
					{
						//level.squad[ "ALLY_ALPHA" ].moveplaybackrate = 1.1; // return to normal speed
						level.squad[ "ALLY_ALPHA" ]set_generic_run_anim( "crouch_fastwalk_F" );
						level.squad[ "ALLY_ALPHA" ]disable_sprint	   (  );
						level.squad[ "ALLY_ALPHA" ]disable_cqbwalk	   (  );
						level.squad[ "ALLY_ALPHA" ].moveplaybackrate = normal;
					}
				}
			}
		}
		wait 0.2;
	}
}

intro_allied_entrance()
{
	// allies drop down from wall then they all move forward
	level.squad[ "ALLY_BRAVO"	]thread intro_allied_entrance_bravo	 (	);
	level.squad[ "ALLY_CHARLIE" ]thread intro_allied_entrance_charlie(	);
	level.squad[ "ALLY_DELTA"	]thread intro_allied_entrance_delta	 (	);
}

intro_allied_entrance_bravo()
{
	node = getstruct( "factory_infil_wallhop_01", "script_noteworthy" );
	node anim_first_frame_solo( self, "factory_intro_jungle_wallhop" );
	wait 3.5;
	node anim_single_solo( self, "factory_intro_jungle_wallhop" );
	self SetGoalNode( GetNode( "ALLY_BRAVO_wallhop_teleport", "targetname" ) );
	self.goalradius = 8;
	self waittill( "goal" );	
	self enable_ai_color();
}

intro_allied_entrance_charlie()
{
	node = getstruct( "factory_infil_wallhop_02", "script_noteworthy" );
	node anim_first_frame_solo( self, "factory_intro_jungle_wallhop" );
//	wait 1.3;
	node anim_single_solo( self, "factory_intro_jungle_wallhop" );
//	self SetGoalNode( GetNode( "ALLY_CHARLIE_wallhop_teleport", "targetname" ) );
//	self.goalradius = 8;
//	self waittill( "goal" );	
	self enable_ai_color();
	
	maps\factory_util::safe_trigger_by_targetname( "sca_train_kill_charlie_position" );
}

intro_allied_entrance_delta()
{
	self endon( "death" );
	level endon( "player_entered_awning" );
	
	node = getstruct( "factory_infil_wallhop_03", "script_noteworthy" );
	node anim_first_frame_solo( self, "factory_intro_jungle_wallhop" );
	wait 2.2;
	node anim_single_solo( self, "factory_intro_jungle_wallhop" );
	self SetGoalNode( GetNode( "ALLY_DELTA_wallhop_teleport", "targetname" ) );
	self.goalradius = 8;
	self waittill( "goal" );	
	self enable_ai_color();
}

loop_train( train_delay, train_distance, train_time )
{
	//sfx for looping train

	thread maps\factory_audio::audio_train_constant_loop();
	thread maps\factory_audio::audio_start_train_click_clacks();

	train_01 = GetEnt( "train_reveal_01_org", "targetname" );
	train_02 = GetEnt( "train_reveal_02_org", "targetname" );
	train_03 = GetEnt( "train_reveal_03_org", "targetname" );
	train_04 = GetEnt( "train_reveal_04_org", "targetname" );
	train_05 = GetEnt( "train_reveal_05_org", "targetname" );
	train_06 = GetEnt( "train_reveal_06_org", "targetname" );
	train_07 = GetEnt( "train_reveal_07_org", "targetname" );
	train_08 = GetEnt( "train_reveal_08_org", "targetname" );
	train_09 = GetEnt( "train_reveal_09_org", "targetname" );
	train_10 = GetEnt( "train_reveal_10_org", "targetname" );
	train_11 = GetEnt( "train_reveal_11_org", "targetname" );
	train_12 = GetEnt( "train_reveal_12_org", "targetname" );
	train_13 = GetEnt( "train_reveal_13_org", "targetname" );

	// Get the parts out of the prefabs and links them to the base entity
	train_01_parts = GetEntArray( train_01.target, "targetname" );
	foreach ( piece in train_01_parts )
		piece LinkTo( train_01 );
	
	train_02_parts = GetEntArray( train_02.target, "targetname" );
	foreach ( piece in train_02_parts )
		piece LinkTo( train_02 );
	
	train_03_parts = GetEntArray( train_03.target, "targetname" );
	foreach ( piece in train_03_parts )
		piece LinkTo( train_03 );
	
	train_04_parts = GetEntArray( train_04.target, "targetname" );
	foreach ( piece in train_04_parts )
		piece LinkTo( train_04 );
	
	train_05_parts = GetEntArray( train_05.target, "targetname" );
	foreach ( piece in train_05_parts )
		piece LinkTo( train_05 );
	
	train_06_parts = GetEntArray( train_06.target, "targetname" );
	foreach ( piece in train_06_parts )
		piece LinkTo( train_06 );
	
	train_07_parts = GetEntArray( train_07.target, "targetname" );
	foreach ( piece in train_07_parts )
		piece LinkTo( train_07 );
	
	train_08_parts = GetEntArray( train_08.target, "targetname" );
	foreach ( piece in train_08_parts )
		piece LinkTo( train_08 );
	
	train_09_parts = GetEntArray( train_09.target, "targetname" );
	foreach ( piece in train_09_parts )
		piece LinkTo( train_09 );
	
	train_10_parts = GetEntArray( train_10.target, "targetname" );
	foreach ( piece in train_10_parts )
		piece LinkTo( train_10 );
	
	train_11_parts = GetEntArray( train_11.target, "targetname" );
	foreach ( piece in train_11_parts )
		piece LinkTo( train_11 );
	
	train_12_parts = GetEntArray( train_12.target, "targetname" );
	foreach ( piece in train_12_parts )
		piece LinkTo( train_12 );
	
	train_13_parts = GetEntArray( train_13.target, "targetname" );
	foreach ( piece in train_13_parts )
		piece LinkTo( train_13 );

	// used to line up train cars at 1 spot so they can all run same script from same place
	train_01 MoveX( -636 * 0, 0.1, 0, 0 );
	train_02 MoveX( -636 * 1, 0.1, 0, 0 );
	train_03 MoveX( -636 * 2, 0.1, 0, 0 );
	train_04 MoveX( -636 * 3, 0.1, 0, 0 );
	train_05 MoveX( -636 * 4, 0.1, 0, 0 );
	train_06 MoveX( -636 * 5, 0.1, 0, 0 );
	train_07 MoveX( -636 * 6, 0.1, 0, 0 );
	train_08 MoveX( -636 * 7, 0.1, 0, 0 );
	train_09 MoveX( -636 * 8, 0.1, 0, 0 );
	train_10 MoveX( -636 * 9, 0.1, 0, 0 );
	train_11 MoveX( -636 * 10, 0.1, 0, 0 );
	train_12 MoveX( -636 * 11, 0.1, 0, 0 );
	train_13 MoveX( -636 * 12, 0.1, 0, 0 );
	wait 1;

	if ( IsDefined( train_01 ) )
	{
		train_01 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_02 ) )
	{
		train_02 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_03 ) )
	{
		train_03 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_04 ) )
	{
		train_04 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_05 ) )
	{
		train_05 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_06 ) )
	{
		train_06 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_07 ) )
	{
		train_07 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_08 ) )
	{
		train_08 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_09 ) )
	{
		train_09 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_10 ) )
	{
		train_10 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_11 ) )
	{
		train_11 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_12 ) )
	{
		train_12 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	wait train_delay;
	if ( IsDefined( train_13 ) )
	{
		train_13 thread loop_train_car( train_distance, train_time, 0.1 );
	}
	
	flag_wait( "intro_checkpoint_done" );
	train_parts = GetEntArray( "fac_intro_trains", "script_noteworthy" );
	foreach ( train_part in train_parts )
	{
		if ( IsDefined( train_part ) )
		{
			train_part Delete();
		}
	}
}

loop_train_car( dist, time, time2 )
{
	self endon( "death" );
	
	// add the rocking motion
	thread wiggle_train_car();
	thread check_train_car_for_stopping();
	// adjust the height for the tracks
	self MoveZ( 11.0, 0.1, 0, 0 );
	self waittill( "movedone" );

	// start looping the train
	for ( ;; )
	{
//		prof_begin( "fac_train_animation" );
		
		self MoveX( 0.0 - dist, time );
		self waittill( "movedone" );
		// drop below ground, return to roiginal position, come back up
		{
			if ( flag( "trig_intro_vignette" ) )
			{
//				prof_end( "fac_train_animation" );
				break;
			}
		}
		self MoveZ( -250, 0.1 );
		self waittill( "movedone" );
		{
			if ( flag( "trig_intro_vignette" ) )
			{
//				prof_end( "fac_train_animation" );
				break;
			}
		}
		self MoveX( dist, time2 );
		self waittill( "movedone" );
		{
			if ( flag( "trig_intro_vignette" ) )
			{
//				prof_end( "fac_train_animation" );
				break;
			}
		}
		self MoveZ( 250, 0.1 );
		self waittill( "movedone" );
		{
			if ( flag( "trig_intro_vignette" ) )
			{
//				prof_end( "fac_train_animation" );
				break;
			}
		}
		
//		prof_end( "fac_train_animation" );
	}
}

check_train_car_for_stopping()
{
	self endon( "death" );
	flag_wait( "trig_intro_vignette" );
	flag_wait( "first_enemy_dead" );
	//for( ;; )
	//{
	//	if ( flag( "trig_intro_vignette" ) )
	//		break;
	//	wait 0.1;
	//}
	if ( flag ( "trainyard_kill_sequence_used" ) )
		wait 1.1;
	//IPrintLnBold( "stopping trains" );
	if ( self.origin[ 0 ] < 4100 )
	{
		//IPrintLnBold( "I'm visible to player so I won't stop" );
		self waittill( "movedone" );
		self MoveX( -8000, 20 );
		self waittill( "movedone" );
	}
	if ( self.origin[ 0 ]  > 4100 )
	{
		//IPrintLnBold( "I'm not visibible - get me outta here" );
		self MoveX( 8000, 0.1 );
		self waittill( "movedone" );
	}
}

wiggle_train_car()
{
	level endon( "entered_factory_1" );
	self endon( "death" );
	
	for ( ;; )
	{
		self RotateTo( ( 0, 0, RandomFloatRange( 0.8, 2.5 ) ), RandomFloatRange( 0.3, 1.2 ) );
		wait RandomFloatRange( 0.3, 1.5 );
		self RotateTo( ( 0, 0, RandomFloatRange( 0.8, 2.5 ) * -1 ), RandomFloatRange( 0.3, 1.2 ) );
		wait RandomFloatRange( 0.3, 1.5 );
	}
}

factory_reveal_activity()
{
	// Roving guards out in the distance
	spawners = GetEntArray( "intro_reveal_pmcs", "targetname" );
	foreach ( spawner in spawners )
		spawner add_spawn_function( ::intro_reveal_pmc_think );
	
	// Vehicles that populate the vista
	veh_spawners = GetEntArray( "reveal_vehicles", "targetname" );
	foreach ( spawner in veh_spawners )
		spawner add_spawn_function( ::reveal_vehicles_think_veh );
	
	veh_riders = GetEntArray( "intro_reveal_vehicle_pmcs", "targetname" );
	foreach ( spawner in veh_riders )
		spawner add_spawn_function( ::reveal_vehicles_think_pmc );
}

reveal_vehicles_think_veh()
{
	self.ignoreall = true;
	self thread detect_player_shot();
	
	PlayFXOnTag( level._effect[ "car_headlight_gaz_l_night" ], self, "TAG_HEADLIGHT_LEFT" );
	PlayFXOnTag( level._effect[ "car_headlight_gaz_r_night" ], self, "TAG_HEADLIGHT_RIGHT" );
	PlayFXOnTag( level._effect[ "car_taillight_btr80_eye" ], self, "TAG_BRAKELIGHT_LEFT" );
	PlayFXOnTag( level._effect[ "car_taillight_btr80_eye" ], self, "TAG_BRAKELIGHT_RIGHT" );
}
	
reveal_vehicles_think_pmc()
{
	self.ignoreall = true;	
	self thread detect_player_shot();
}

intro_reveal_pmc_think()
{
	self endon( "death" );
	
	self.animname		 = "generic";
	self.disablearrivals = true;
	self.disableexits	 = true;
	self.health			 = 1;
	self.ignoreall		 = true;
	
	self.patrol_walk = [ "walk_gun_unwary"	  , "patrol_bored_patrolwalk", "patrol_bored_patrolwalk_twitch" ];
	self.patrol_idle = [ "patrol_idle_stretch", "patrol_idle_smoke"		 , "patrol_idle_checkphone" ];

	self set_generic_run_anim_array( random( self.patrol_walk ) );
	self set_generic_idle_anim( random( self.patrol_idle ) );
	
	if ( IsDefined( self.target ) )
	{
		self start_patrol( self.target );
	}

	self thread detect_player_shot();
	
	flag_wait( "player_exited_train" );
	
	self Delete();
}

detect_player_shot()
{
	level endon( "entered_factory_1" );
	while ( 1 )
	{
		self waittill( "damage" , amount , who  );
		if ( who == level.player )
		{
			SetDvar( "ui_deadquote", "You alerted the enemy and compromised the mission." );	
			
			missionFailedWrapper();
		}
	}
}

light_set_intro_rim_lights()
{ 
    
	SetSavedDvar("r_rimLightDiffuseIntensity","32.5");
 	SetSavedDvar("r_rimLightSpecIntensity","12.8");
	SetSavedDvar("r_rimLightPower","2.5");
	SetSavedDvar("r_rimLightBias","0.13");
    SetSavedDvar("r_rimLight0Pitch","-72.1");
    SetSavedDvar("r_rimLight0Heading","0");
    SetSavedDvar("r_rimLight0Color","0.55 0.55 0.69 1");
    
	//IPrintLnBold("set rim lights");

}

// =====================================
// INTRO HELO SECTION
// =====================================

// Animated version of the spotlight chopper
intro_animated_chopper_spotlight()
{
	intro_ally_moveto_trig = GetEnt( "trig_intro_ally_moveto_reveal", "targetname" );
	intro_ally_moveto_trig waittill( "trigger" );

	//IPrintLnBold( "**Spawning Chopper**" );
	level thread maps\factory_anim::intro_chopper();
	thread maps\factory_fx::fx_set_wind( 4.0, 3.5, 1.8, 1 );
	exploder( "intro_helicopter_debris" );
	PlayFXOnTag(  level._effect[ "factory_intro_helicopter_raindrops" ], level.screenRain, "tag_origin" );

	wait 1.2;
	level.player PlayRumbleOnEntity( "artillery_rumble" );
	
	wait 1.0;
//	level.squad[ "ALLY_ALPHA" ] SetLookAtEntity();  // tagTJ: Disabling because it doesn't interact with the other animations in the scene well at all
	thread maps\factory_fx::fx_set_wind( 2.0, 2.0, 1.0, 1 );
	wait 2.2;
	thread	maps\factory_fx::fx_set_wind( level.defaultReactiveWind[ "strength" ], level.defaultReactiveWind[ "amplitudeScale" ], level.defaultReactiveWind[ "frequencyScale" ], 3.0 );
}

// =====================================
// INTRO TRAIN SECTION
// =====================================
intro_train_start()
{
	level.player SwitchToWeapon( level.default_weapon ); //Old val: mp5_silencer_eotech
	level.player GiveMaxAmmo( level.default_weapon );
	level.player TakeWeapon( "flash_grenade" );
	level.player TakeWeapon( "fraggrenade" );
	 
	player_speed_percent( 65 );
	//level.player AllowSprint( false );
	
	thread intro_truck_setup();
	
	flag_clear ( "trig_intro_vignette" );
	flag_clear ( "kill_train" );

	thread maps\factory_audio::audio_trainpass_chkpt();
	thread loop_train( 2.40, 8000, 30.0 );
	// thread maps\factory_util::make_it_rain( "rain_heavy", "open_exit_doors" );
	// Teleport Baker down to the area below the fence
	fence_infil_teleport_org = GetNode( "ALLY_ALPHA_fence_infil_teleport", "targetname" );
	level.squad[ "ALLY_ALPHA" ]teleport_ai	  ( fence_infil_teleport_org );
	level.squad[ "ALLY_ALPHA" ]enable_ai_color(	 );
	maps\factory_util::squad_add_ally( "ALLY_DELTA", "ally_delta", "ally_delta" );//GREEN
	maps\factory_util::squad_add_ally( "ALLY_ECHO" , "ally_echo" , "ally_echo" );//YELLOW
	level.squad[ "ALLY_DELTA" ].ignoreall = true;
	level.squad[ "ALLY_DELTA" ].ignoreme  = true;
	level.squad[ "ALLY_ECHO"  ].ignoreall = true;
	level.squad[ "ALLY_ECHO"  ].ignoreme  = true;
	thread intro_allied_entrance();
	
	level.player thread maps\factory_fx::splash_on_player( "player_entered_awning" );

	thread handle_player_leaving_mission();

	// Give the player a tease of the inside of the factory from a distance
//	thread open_factory_door();
	
	//teleport_squadmember( "intro_train", "ALLY_ALPHA" );
	
	battlechatter_off();
	
	thread maps\_weather::rainHard ( 1 );
	thread maps\factory_fx::fx_intro_rain();

}

intro_train()
{
	//IPrintLnBold( "intro_train" );
	
	// Make sure everybody is ignoring enemies for the rest of the intro
	foreach ( guy in level.squad )
	{	
		guy.ignoreall = true;
	}
		
	// Level variables
	level.cosine[ "70" ]						= Cos( 70 );
	level.goodFriendlyDistanceFromPlayerSquared = 250 * 250;
	
	thread intro_train_pass();
	thread maps\factory_audio::sfx_train_sound();
	
	flag_wait_any( "intro_checkpoint_done", "player_entered_awning" );
}

wait_for_intro_vignette_use()
{
	level.player endon( "mantle_used" );
	
	coupling_org = GetEnt( "train_coupling", "targetname" );
	NotifyOnCommand( "mantle", "+gostand" );
	
	for ( ;; )
	{
		if ( flag( "trig_intro_vignette" ) && player_looking_at( coupling_org.origin, 0.3 ) && level.player GetStance() == "stand" )
		{
			SetSavedDvar( "hud_forceMantleHint", 1 );
			level.player AllowJump( false );
			level.player thread player_mantle_wait();
			while ( flag( "trig_intro_vignette" ) && player_looking_at( coupling_org.origin, 0.3 ) && level.player GetStance() == "stand" )
			{
				if ( level.player GetStance() != "stand" )
					break;
				wait( 0.05 );
			}
		}
		else
		{
			level.player notify( "not_active" );
			SetSavedDvar( "hud_forceMantleHint", 0 );
			level.player AllowJump( true );
		}
			
		wait( 0.05 );
	}
}

player_mantle_wait()
{
	self endon( "not_active" );
	
	self waittill( "mantle" );

	SetSavedDvar( "hud_forceMantleHint", 0 );
	self notify( "mantle_used" );
	///flag_set("audio_endofclacks");
}

intro_train_pass()
{	
	thread maps\factory_fx::lgt_intro_train_light();
	//IPrintLnBold( "intro_train_pass" );
	
	// Setting up soldiers for patrol with base scripts
	// IPrintLnBold( "Spwaning enemy" );

	// stop previous line(s)
	wait 0.3;
	radio_dialogue_stop();

	if ( !flag( "first_enemy_dead" ) )
		//Baker: Hold… tango.
		level.squad[ "ALLY_ALPHA" ] thread smart_radio_dialogue( "factory_bkr_twoapproaching" );

	wait 0.7;
	spawner_infil_kill = GetEnt( "infil_kill", "targetname" );
	spawner_infil_kill add_spawn_function( ::initial_enemy_logic );
	infil_kill = spawner_infil_kill spawn_ai();

	//wait_for_intro_vignette_use();
	
	thread factory_entrance_setup(); // Spawning truck kills early
	thread intro_kill_vignette();
	
	//wait 0.3;

	//wait 1.5;
	// BAKER: Rook, he's yours…keep it quiet.
	// doing this as radio dialogue because I need it to stop if kill happens
	if ( !flag( "first_enemy_dead" ) )
		//Baker: Rook, he's yours…keep it quiet.
		level.squad[ "ALLY_ALPHA" ] thread smart_radio_dialogue( "factory_bkr_gotthem" ); // doign this as radio dialogue because I need it to stop if kill happens
	
	//wait 2.0;
	thread train_kill_ally_second_pos();

	flag_wait( "first_enemy_dead" );

	// stop previous line(s)
	//wait 1.5;
	if ( flag ( "trainyard_kill_sequence_used" ) )
		wait 1.0;
	radio_dialogue_stop();
	
	wait 0.5;
	//Merrick: Let's move!
	level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_letsmove" ); //***

	flag_set( "audio_endofclacks" );
	//flag_set("music_stealth_intro");

	flag_wait( "intro_kill_sequence_done" );

	// Keep allies ahead of the player
	foreach ( guy in level.squad )
	{
		guy thread friendly_adjust_movement_speed();
		guy disable_cqbwalk();
	}
	
	maps\factory_util::safe_trigger_by_targetname( "intro_allies_first_moveout" ); // Move kick all allies towards their first positions
	
	//make enemies see the player again
	level.player.ignoreme = false;
	
	level.squad[ "ALLY_ALPHA" ].ignoreall = false;
		
	thread intro_scene();		
	
	wait 1.0;
	//Merrick: Oldboy and Pick – peel-off and tap into security, watch for squirters.
	level.squad[ "ALLY_ALPHA" ] smart_radio_dialogue( "factory_mrk_oldboyandpickpeeloff" ); // DIAZ
	
	//wait 2.0;
	// Oldboy: we're on it!
	//Diaz: Copy - we're on it!
	level.squad[ "ALLY_CHARLIE" ] thread smart_radio_dialogue( "factory_diz_wereonit" );	//*
	wait 2.0;
	radio_dialogue_stop();

	//Merrick: Everyone else, we’re moving left to infil and then to Black Zone to find LOKI.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_everyoneelseweremoving" ); // BAKER	
}

train_kill_ally_second_pos()
{
	wait 4;
	if ( !flag( "first_enemy_dead" ) )
	maps\factory_util::safe_trigger_by_targetname( "sca_train_kill_second_pos" );
	// adding some nags
	if ( !flag( "first_enemy_dead" ) )
		wait 4;
	// Rook, on you..
	if (( !flag( "first_enemy_dead" ) ) && ( !flag( "trainyard_kill_sequence_used" ) ))
		level.squad[ "ALLY_ALPHA" ] thread smart_radio_dialogue( "factory_bkr_rookonyou" ); // doing this as radio dialogue because I need it to stop if kill happens
	if ( !flag( "first_enemy_dead" ) )
		wait 4;
	// Take him..
	if (( !flag( "first_enemy_dead" ) ) && ( !flag( "trainyard_kill_sequence_used" ) ))
		level.squad[ "ALLY_ALPHA" ] thread smart_radio_dialogue( "factory_mrk_takehim" ); // doing this as radio dialogue because I need it to stop if kill happens

}

initial_enemy_logic()
{
	level endon ( "initial_enemy_alerted" );
	self endon( "death" );

	// Set up our enemy
	//IPrintLnBold( "enemy created!" );
	thread maps\factory_fx::rain_on_actor( self, "initial_enemy_alerted", 0.1 );
	self.animname = "initial_enemy";

	self.script_grenades	= 0;
	self.disablearrivals	= true;
	self.disableexits		= true;
	self.allowdeath			= true;
	self.health				= 1;
	//self.moveplaybackrate = 1.8;
	
	self.ignoreall = true;
	self.ignoreme  = true;

	self attach_flashlight( true );

	// Get our base node to send off to other functions
	node = getstruct( "opfor_trainyard_walk", "script_noteworthy" );
	
	self thread initial_enemy_breakout_early();
	thread initial_enemy_logic_wait_too_long();
	
	// Kick off his first sequence
	initial_enemy_logic_start( node );
	thread initial_enemy_logic_dialogue();
	
	if ( !flag( "initial_enemy_alerted" ) )
	{
		thread initial_enemy_logic_wait( node );
		node anim_loop_solo( self, "factory_opfor_trainyard_patrol_loop", "stop_loop" );
	}

	// Clean up the enemy regardless of how he broke out	
	self disable_surprise(); // Don't want the enemy to do a double take reaction
	self.favoriteenemy = level.player;
	self GetEnemyInfo( level.player );

	flag_wait( "initial_enemy_alerted" );
	
	level.squad[ "ALLY_ALPHA" ].ignoreall	  = false;
	level.squad[ "ALLY_ALPHA" ].favoriteenemy = self;
	
	/*
	 * This looks to be unnecessary.  The flashlight functions above all handle turning off the flashlight stuff.
	 * Keeping this in place for now just in case.
	wait 0.1;
	self StopAnimScripted();
	self flashlight_light( false );
	self detach_flashlight();
	
	wait 5;
	
	StopFXOnTag( level._effect[ "flashlight_spotlight" ], self, "tag_weapon_right" );
	*/
}

initial_enemy_breakout_early()
{
	level endon( "trainyard_kill_sequence_used" );;
	self endon( "death" );
	
	flag_wait( "player_exited_train" );
	
	while ( 1 )
	{
		if ( self.origin[ 0 ] < level.player.origin[ 0 ] )
			break;
		wait 0.25;
	}
	
	//IPrintLnBold ("initial_enemy_alerted");
	flag_set( "initial_enemy_alerted" );
	
	// Wake the guard up and let him loose
	self disable_surprise(); // Don't want the enemy to do a double take reaction
	self.favoriteenemy = level.player;
	self GetEnemyInfo( level.player );
	self StopAnimScripted();
	self flashlight_light( false );
	self detach_flashlight();
	
	self.ignoreall = false;
	self.ignoreme  = false;
	self SetGoalPos( self.origin );
	self.goalradius						  = 8;
	level.player.ignoreme				  = false;
	level.squad[ "ALLY_ALPHA" ].ignoreall = false;
}

initial_enemy_logic_start( node )
{
	self endon( "death" );
	level endon( "initial_enemy_alerted" );
	
			 //   timer    func 				   param1    param2 							     param3   
	delayThread( 0.1	, ::anim_set_rate_single, self	  , "factory_opfor_trainyard_patrol_enter", 1.5 );
	delayThread( 1.0	, ::anim_set_rate_single, self	  , "factory_opfor_trainyard_patrol_enter", 1.1 );
	delayThread( 4.9	, ::anim_set_rate_single, self	  , "factory_opfor_trainyard_patrol_enter", 1.5 );
	node anim_single_solo( self, "factory_opfor_trainyard_patrol_enter" );
	
	//IPrintLnBold ("initial_enemy_in_position");
	level notify( "initial_enemy_in_position" );
}

initial_enemy_logic_dialogue()
{
	self endon( "death" );
	level endon( "initial_enemy_alerted" );
	wait 4;
	// ENEMY: (translated) Trains are clear...
	//self thread radio_dialogue( "factory_vs1_trainsareclear" );	
	// ENEMY RADIO: (translated) Roger patrol
	if ( IsAlive( self ) )
	    //Venezuelan2: Roger patrol
	    self thread smart_radio_dialogue( "factory_vs2_rogerpatrol" );
}

initial_enemy_logic_wait_too_long()
{
	// Used for when player waits too long - force Baker to do the kill
	self endon( "death" );
//	self endon( "initial_kill_alerted" );
	
	flag_wait_or_timeout ( "initial_enemy_alerted", 18 );
	// if ( !flag( "trig_intro_vignette" ) )
   //  {
	    //IPrintLnBold( "Baker gets bored" );
		level.squad[ "ALLY_ALPHA" ]enable_cqbwalk(	);
		level.squad[ "ALLY_ALPHA" ]SetGoalNode	 ( GetNode( "ALLY_ALPHA_post_kill_node", "targetname" ) );
		level.squad[ "ALLY_ALPHA" ].goalradius = 64;
		level.squad[ "ALLY_ALPHA" ] waittill( "goal" );	
		wait 0.6;
		//IPrintLnBold( "Baker shoots enemy" );
		start_pos = level.squad[ "ALLY_ALPHA" ] GetTagOrigin( "tag_flash" );
		end_pos	  = self GetShootAtPos();
		level.squad[ "ALLY_ALPHA" ] cqb_aim( self );
		//flag_set( "trig_intro_vignette" ); // Set this now before this thread gets killed by the endon
		flag_set( "intro_kill_sequence_done" );
		
		// TODO Need a VO line here indicating that Merrick is displeased with the player's performance
		
		level.squad[ "ALLY_ALPHA" ] safe_magic_bullet( start_pos, end_pos );
		self Kill();
	// }
}

initial_enemy_logic_wait( node )
{
	//self endon( "death" );
	level endon( "initial_enemy_alerted" );
	
	// PLAYER MANTLES OVER COUPLING
	//flag_wait( "player_mantle_train" );
	flag_wait( "trig_intro_vignette" );
	//flag_wait("audio_endofclacks");
	
	// ENEMY: (translated) Moving to loading docks
	if ( IsAlive( self ) )
	    //Venezuelan3: Moving to loading docks…
	    self thread smart_radio_dialogue( "factory_vs3_movingtoloadingdocks" );

	// ENEMY RADIO: (translated) Copy that...
	if ( IsAlive( self ) )
	    //Venezuelan2: Copy that.
	    self thread smart_radio_dialogue( "factory_vs2_copythat" );
	//wait 1.6;
	
	flag_wait( "player_exited_train" );
	
	//IPrintLnBold ("starting to wait for special kill");
	wait_time = 2.0;
	while ( wait_time > 0 )
	{
		wait_time = wait_time - 0.1;
		wait 0.1;
		if ( IsAlive( self ) && level.player.origin[ 0 ] < self.origin[ 0 ]  && level.player.origin[ 0 ]  > self.origin[ 0 ] - 150 )
		{
			//IPrintLnBold ("close on X");
			if ( level.player.origin[ 1 ] < self.origin[ 1 ] + 35 && level.player.origin[ 1 ]  > self.origin[ 1 ] - 35 )
			{
				//IPrintLnBold ("close on Y");
				//IPrintLnBold ("Angle = " + level.player.angles[1]);
				if ( level.player.angles[ 1 ] < 20 && level.player.angles[ 1 ]  > -20 )
				{
					level.player display_hint( "neck_stab_hint" );
					//IPrintLnBold ("in angle");
					level.player AllowMelee( false );
					if ( level.player MeleeButtonPressed() && !level.player IsMeleeing() && !level.player IsThrowingGrenade() )
					{
						//IPrintLnBold ("ATTACK!!!!");
						level.player.in_stab_animation = true;
						level.player SetStance ( "stand" );
						player_rig = player_start_stabbing();
					
						anim_org = getstruct( "opfor_trainyard_walk", "script_noteworthy" );	
		
						// player_rig = spawn_anim_model( "player_rig" );
						// player_rig Hide();
						//IPrintLnBold( "Hiding Rig" );
						
						guys	  = [];
						guys[ 0 ] = player_rig;
						guys[ 1 ] = self;
					
						// move ents to first frame of anim
						anim_org anim_first_frame_solo( player_rig, "factory_opfor_trainyard_melee_death" );
						thread maps\factory_audio::audio_player_train_track_stealth_kill();

						// interpolate player to anim start
						blend_time = 0.15;
						level.player PlayerLinkToBlend( player_rig, "tag_player", blend_time, 0.25, 0.25 );
						wait blend_time;
						level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
						player_rig Show();
						//wait blend_time;
					
						if ( IsAlive( self ) )
						{
							
							//IPrintLnBold ("trainyard_kill_sequence_used");
							flag_set( "trainyard_kill_sequence_used" );
							// show knife
							player_rig Show();
							player_rig Attach( "weapon_parabolic_knife", "tag_weapon_right", true );
						
							// play anims
							self thread flashlight_drop_detail();
										  //   timer    func 								      param1   
							self delayThread( 0.5	 , maps\factory_fx::fx_intro_kill_ally_stab, self );
							self delayThread( 2.5	 , maps\factory_fx::fx_intro_kill_ally_stab, self );
							self delayThread( 2.6, maps\factory_anim::kill_no_react );
							//level.infil_dropkill_player_enemy maps\factory_anim::kill_no_react();
							anim_org anim_single( guys, "factory_opfor_trainyard_melee_death" );
							//AssertEx( !IsAlive( level.infil_dropkill_player_enemy ), "victim not killed during animation." );
						
							// clean up
							player_rig Detach( "weapon_parabolic_knife", "tag_weapon_right", true );
							player_rig Hide();
						}
		
						level.player Unlink();
						player_rig Delete();	
					
						level.player.in_stab_animation = undefined;

						player_done_stabbing();
						return;

					}
				}
				else
				{
					level.player AllowMelee( true );
				}
			}
		}
		
	}
	//IPrintLnBold ("done waiting for special kill");
	level.player AllowMelee( true );

	if ( IsAlive( self ) )
	{
		self.ignoreme						  = false;
		self.ignoreall						  = false;
		self.favoriteenemy					  = level.player;
		level.player.ignoreme				  = false;
		level.squad[ "ALLY_ALPHA" ].ignoreall = false;
		
		node notify( "stop_loop" );
		self StopAnimScripted();
		node thread anim_single_solo( self, "factory_opfor_trainyard_patrol_reaction" );
		self thread flashlight_drop_detail();
		
		self waittill( "damage" );
	}
	
}

flashlight_drop_detail()
{
	wait 0.6;
	self detach_flashlight();
	wait 1.5;
	self flashlight_light( false );
}

intro_ally_moveout()
{
	flag_wait( "trig_intro_vignette" );
	
	thread intro_ally_charlie_train_rollout();
	
	flag_wait( "first_enemy_dead" );

	// CHAD TESTS FOR PC GOD RAYS
	thread maps\factory_util::god_rays_trainyard();

	// level.squad[ "ALLY_ALPHA" ] StopAnimScripted();
	
	foreach ( guy in level.squad )
		guy enable_ai_color();
}

intro_ally_charlie_train_rollout()
{
	node = getstruct( "factory_intro", "script_noteworthy" );
	level.squad[ "ALLY_CHARLIE" ].a.pose = "crouch";
	node anim_first_frame_solo( level.squad[ "ALLY_CHARLIE" ], "factory_intro_ally03" );
	
	flag_wait_all( "first_enemy_dead" );
	
	if ( flag ( "trainyard_kill_sequence_used" ) )
		wait 1.0;
	node anim_single_solo( level.squad[ "ALLY_CHARLIE" ], "factory_intro_ally03" );
	waittillframeend;
	level.squad[ "ALLY_CHARLIE" ]StopAnimScripted(	);
	level.squad[ "ALLY_CHARLIE" ]enable_ai_color (	);
	level.squad[ "ALLY_CHARLIE" ]disable_cqbwalk (	);
	
	maps\factory_util::safe_trigger_by_targetname( "sca_post_rollout_charlie" );
	
}

intro_kill_vignette()
{	
	level.squad[ "ALLY_ALPHA" ] notify( "intro_kill_sequence_start" );
	waittillframeend; // wait for alpha's idle animation to end
	
	thread intro_ally_moveout();
	
	flag_wait_all( "first_enemy_dead", "trig_intro_vignette", "player_exited_train" );

	foreach ( squadmember in level.squad )
		squadmember disable_cqbwalk();
			
	//IPrintLnBold ("teleporting!");
	level.squad[ "ALLY_BRAVO" ]StopAnimScripted(  );
	level.squad[ "ALLY_DELTA" ]StopAnimScripted(  );
	level.squad[ "ALLY_ECHO"  ]StopAnimScripted(  );
					  //   checkpoint_name    squad_name   
	teleport_squadmember( "intro"		   , "ALLY_BRAVO" );
	teleport_squadmember( "intro"		   , "ALLY_DELTA" );
	teleport_squadmember( "intro"		   , "ALLY_ECHO" );

//	thread move_outside_crane(); // tagTJ: Paul's removing the asset so this needs to be disabled (likely permanently)
	
	level.squad[ "ALLY_ALPHA"	]PushPlayer( true );
	level.squad[ "ALLY_CHARLIE" ]PushPlayer( true );
	
	level.squad[ "ALLY_ALPHA" ].disableplayeradsloscheck = false;
	
	foreach ( guy in level.squad )
		guy enable_ai_color();
	
	flag_set( "intro_kill_sequence_done" );
}

move_outside_crane()
{
	//IPrintLnBold( "outside crane check" );
	flag_wait( "intro_checkpoint_done" );
	outside_crane01 = GetEntArray( "outside_crane", "targetname" );	
    //wait 4.0;
	foreach ( piece in outside_crane01 )
		piece MoveY( -500, 18, 2, 6 );
	
}

/*
unlink_player_from_intro_vignette( guard )
{
	level.player Unlink();
	
	level.player_rig Delete();

	level.player FreezeControls( false );
	//level.player AllowStand( true );
	level.player AllowCrouch( true );
	level.player AllowProne( true );	
	level.player AllowJump( true );
	level.player EnableWeapons();
	player_speed_percent( 65 );
	level.player AllowSprint( true );
	level.player.active_anim = false;
	
	level.player notify( "player_exit_intro_vignette" );
}
*/

kill_initial_guard( guard )
{
	//guard.health = 1;
	guard gun_remove();	
	//guard.ragdoll_immediate = true;
	guard.allowDeath		  = true;
	guard.a.nodeath			  = true;
	guard set_battlechatter( false );
	guard Kill( level.squad[ "ALLY_BRAVO" ].origin, level.squad[ "ALLY_BRAVO" ] );
}

intro_scene()
{
	flag_wait( "player_exited_train" );
	
	thread delta_splitup();
	
	flag_wait( "factory_exterior_reveal" );
	//level thread smart_radio_dialogue( "factory_diz_youreclear" );	
	//thread intro_scene_tweak_ally_runs();
	level.squad[ "ALLY_ALPHA"	]disable_cqbwalk(  );
	level.squad[ "ALLY_BRAVO"	]disable_cqbwalk(  );
	level.squad[ "ALLY_CHARLIE" ]disable_cqbwalk(  );
	maps\factory_util::safe_trigger_by_targetname( "intro_allies_leave_trains" ); // Kick all allies out from the trains

	flag_wait( "factory_exterior_reveal_between_trains" );
	wait 1;
	// CHAD TESTS FOR PC GOD RAYS!!!!!
	thread maps\factory_util::god_rays_factory_awning();
			
	maps\factory_util::safe_trigger_by_targetname( "intro_allies_past_trains1" ); // 
	//level.squad[ "ALLY_ALPHA" ] enable_cqbwalk();
	//level.squad[ "ALLY_CHARLIE" ] enable_cqbwalk();

	//Merrick: Keep moving!
	level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_keepmoving" );

	flag_wait( "factory_exterior_approach_infil" );
	wait 0.1;

	maps\factory_util::safe_trigger_by_targetname( "intro_allies_past_trains2" ); // 
			
	wait 3.1;
	// Merrick: Through here...
	//Baker: Through here.
	level.squad[ "ALLY_BRAVO" ] thread smart_dialogue( "factory_bkr_throughhere" ); //**

	level.squad[ "ALLY_BRAVO"	]enable_cqbwalk(  );
	level.squad[ "ALLY_CHARLIE" ]enable_cqbwalk(  );

	flag_wait( "intro_checkpoint_done" );
	
	level.squad[ "ALLY_ALPHA"	]PushPlayer( false );
	level.squad[ "ALLY_CHARLIE" ]PushPlayer( false );
}

intro_scene_tweak_ally_runs()
{
	level endon ( "factory_exterior_reveal_between_trains" );
	level.squad[ "ALLY_BRAVO" ] enable_cqbwalk();
	wait 3.5;
	level.squad[ "ALLY_BRAVO" ] disable_cqbwalk();
	wait 3.8;
	level.squad[ "ALLY_BRAVO" ] enable_cqbwalk();
	wait 0.8;
	level.squad[ "ALLY_CHARLIE" ] enable_cqbwalk();
}

close_factory_door()
{
	factory_entrance_door = GetEnt( "factory_entrance_door", "script_noteworthy" );
	
	factory_entrance_door MoveZ( -184, 14, 1, 5 );
}

delta_splitup()
{
	
	level endon ( "intro_truck_driver_dead");
	level endon ( "truck_kill_timed_out" );
	
	// delta_node = GetEnt( "engine_jump_ally01", "script_noteworthy" );
	// echo_node  = GetEnt( "engine_jump_ally02", "script_noteworthy" );
	
	// level.squad[ "ALLY_DELTA" ] thread buddy_boost( delta_node, "factory_engine_jump_ally01", 0.0 );
	// level.squad[ "ALLY_ECHO" ] buddy_boost( echo_node, "factory_engine_jump_ally02", 1.3 );
	thread buddy_boost_delta();
	thread buddy_boost_echo();
	
	vol = GetEnt( "vol_delete_squad_splinter", "targetname" );
	while ( !( level.squad[ "ALLY_DELTA" ] IsTouching( vol ) ) || !( level.squad[ "ALLY_ECHO" ] IsTouching( vol ) ) )
	{
		wait 1.0;
	}
	
	thread delete_squad_splinter();
	
	flag_wait( "factory_exterior_reveal" );
	flag_wait( "intro_checkpoint_done" );
}

buddy_boost_delta()
{
	level.squad[ "ALLY_DELTA" ] maps\factory_rooftop::ally_vignette_traversal( "engine_jump_ally01", "factory_engine_jump_ally01" );

	maps\factory_util::safe_trigger_by_targetname( "squad_splitup" );
}

buddy_boost_echo()
{
	level.squad[ "ALLY_ECHO" ] maps\factory_rooftop::ally_vignette_traversal( "engine_jump_ally02", "factory_engine_jump_ally02" );

	maps\factory_util::safe_trigger_by_targetname( "squad_splitup" );
}

// Removes Keegan and Fuentes from the world for now
delete_squad_splinter()
{
	level.squad[ "ALLY_ECHO" ].goalradius = 8;
	level.squad[ "ALLY_DELTA" ]SetGoalNode( GetNode( "node_keegan_delete", "targetname" ) );
	level.squad[ "ALLY_ECHO"  ]SetGoalNode( GetNode( "node_fuentes_delete", "targetname" ) );
	level.squad[ "ALLY_ECHO"  ]waittill	  ( "goal" );

// tagTJ - Need a way better solution than what is here.  The problem is that the string indices we use to access the squad array
// get blown away if we use any of the array functions that would remove entries.  The interim solution is to literally rebuild the 
// squad array which is what you see below
	
	alph	= level.squad[ "ALLY_ALPHA" ];
	bravo	= level.squad[ "ALLY_BRAVO" ];
	charlie = level.squad[ "ALLY_CHARLIE" ];
	delta	= level.squad[ "ALLY_DELTA" ];
	echo	= level.squad[ "ALLY_ECHO" ];
			
//	level.squad = array_remove( level.squad, delta );
//	level.squad = array_remove( level.squad, echo );
	
	if ( IsDefined( level.squad[ "ALLY_DELTA" ] ) )
	{
//		level.squad[ "ALLY_DELTA" ] stop_magic_bullet_shield();  
		level.squad[ "ALLY_DELTA" ] Delete();
	}
	if ( IsDefined( level.squad[ "ALLY_ECHO" ] ) )
	{
//		level.squad[ "ALLY_ECHO" ] stop_magic_bullet_shield();
		level.squad[ "ALLY_ECHO" ] Delete();
	}
	
	level.squad = undefined;
	
	level.squad[ "ALLY_ALPHA"	] = alph;
	level.squad[ "ALLY_BRAVO"	] = bravo;
	level.squad[ "ALLY_CHARLIE" ] = charlie;
	
//	level.squad = array_removeUndefined( level.squad );
//	level.squad = array_removeDead( level.squad );

}

handle_player_leaving_mission()
{
	level endon( "railgun_reveal_setup" );
	
	flag_wait( "player_exited_mission_warning" );
	
	vol = GetEnt( "vol_player_exited_mission_warning", "targetname" );
	
	while ( IsDefined( vol ) )
	{
		if ( level.player IsTouching( vol ) )
		{
			if ( !flag( "player_exited_mission" ) )
			{
				// Give player a warning before they're going to hit the final trigger
				//Merrick: Adam, get back here!
				smart_radio_dialogue( "factory_mrk_adamgetbackhere" );	
				wait 1.0;
			}
			else
			{
				SetDvar( "ui_deadquote", "You abandoned the mission." );	
		
				missionFailedWrapper();
			}
		}
		wait 1.0;
	}
}

#using_animtree( "generic_human" );
intro_truck_setup()
{
	// Spawn Truck
	intro_truck_cab				 = spawn_vehicle_from_targetname ( "factory_truck_cab_spawner" );
	intro_truck_cab.animname	 = "het_cab";
	level.intro_truck_cab		 = intro_truck_cab;
	intro_truck_trailer			 = spawn_vehicle_from_targetname ( "factory_truck_trailer_spawner" );
	intro_truck_trailer.animname = "het_trailer";
	
	// intro_truck_cab thread maps\factory_fx::fx_het_cab_lights_on();
	// intro_truck_trailer thread maps\factory_fx::fx_het_trailer_lights_on();
	
	intro_truck_trailer vehicle_lights_on ( "running" );
//	intro_truck_cab vehicle_lights_on ( "headlights" );					This is supposed to be off for the factory reveal.
	intro_truck_cab vehicle_lights_on ( "running" );
	
	// Drive truck
	flag_wait ( "factory_exterior_reveal" );
	
	intro_truck_cab StartPath();
	intro_truck_trailer StartPath();
	
	node					   = GetEnt( "truck_sequence_node", "script_noteworthy" );
	intro_truck_driver_spawner = GetEnt( "intro_truck_driver", "script_noteworthy" );
	intro_truck_driver		   = intro_truck_driver_spawner spawn_ai();
	intro_truck_driver LinkTo( node );
	intro_truck_driver.ignoreall = true;
	intro_truck_driver AllowedStances( "stand" );
	
	intro_truck_driver.animname	 = "enemy";
	intro_truck_driver.noragdoll = true;
	intro_truck_driver.deathanim = %factory_truck_driver_death;
	
	intro_truck_driver thread handle_driver_death();
	
	intro_pmcs = GetEntArray( "intro_pmcs", "targetname" );
	
	//DR: also start the temp distant dialog stuff	
	thread maps\factory_audio::audio_sfx_truck_chatter( intro_pmcs, intro_truck_cab );
	
	node thread factory_truck_entrance( intro_truck_cab, intro_truck_trailer, intro_truck_driver );
	
	/*
	// intro_truck_cab	  = GetEnt( "intro_truck_cab", "targetname" );
	headlight_left_org	  = GetEnt( "headlight_left", "targetname" );
	headlight_right_org	  = GetEnt( "headlight_right", "targetname" );
	headlight_dynamic_org = GetEnt( "headlight_dynamic", "targetname" );
	
	headlight_left = headlight_left_org spawn_tag_origin();
	headlight_left LinkTo( intro_truck_cab );
	PlayFXOnTag( level._effect[ "flashlight" ], headlight_left, "tag_origin" );
	
	headlight_right = headlight_right_org spawn_tag_origin();
	headlight_right LinkTo( intro_truck_cab );
	PlayFXOnTag( level._effect[ "flashlight" ], headlight_right, "tag_origin" );

	headlight_dynamic = headlight_dynamic_org spawn_tag_origin();
	headlight_dynamic LinkTo( intro_truck_cab );
	PlayFXOnTag( level._effect[ "flashlight_spotlight" ], headlight_dynamic, "tag_origin" );
	*/
	//intro_pmcs = GetEntArray( "intro_pmcs", "targetname" );

	//DR: also start the temp distant dialog stuff	
	//thread maps\factory_audio::audio_sfx_truck_chatter( intro_pmcs, intro_truck_cab );
	//DR: play the temp truck move sound
	//thread maps\factory_audio::audio_sfx_truck_in_start();
	
	/*
	intro_truck = GetEntArray( "entrance_reveal_18wheeler", "script_noteworthy" );
	foreach( piece in intro_truck )
		piece MoveX( 1050, 7, 1, 3 );	
	*/
	
	intro_truck_driver thread intro_truck_failsafe();
	
	flag_wait( "entered_factory_1" );
	
	// StopFXOnTag( level._effect[ "flashlight_spotlight" ], headlight_dynamic, "tag_origin" );
}

handle_driver_death()
{
	self endon( "entered_factory_1" );
	
	self waittill( "damage" );
	
	self LinkTo( level.intro_truck_cab );
}

factory_truck_entrance( intro_truck_cab, intro_truck_trailer, intro_truck_driver )
{

	// Spawn a brand-new cab and trailer, since animating the one from the path causes the tires to behave bizarrely
	flag_wait( "factory_entrance_reveal" );
	
	level.intro_truck_cab = spawn_vehicle_from_targetname ( "factory_truck_cab_spawner" );
	level.intro_truck_trailer = spawn_vehicle_from_targetname ( "factory_truck_trailer_spawner" );
	
	level.intro_truck_cab.animname	 = "het_cab";
	level.intro_truck_trailer.animname = "het_trailer";
	
	level.intro_truck_cab vehicle_lights_on ( "running" );
	level.intro_truck_trailer vehicle_lights_on ( "running" );
	
	intro_truck_cab delete();
	intro_truck_trailer delete();
	
	// waittillframeend;
	//DR: play the temp truck move sound
	thread maps\factory_audio::audio_sfx_truck_in_start();
	
	self thread anim_single_solo( intro_truck_driver, "factory_truck_driver_loop" );	
	level.intro_truck_cab	 notify ( "suspend_drive_anims" );	
	level.intro_truck_trailer	 notify ( "suspend_drive_anims" );
	
	node = GetVehicleNode ( "truck_entrance_path_end", "targetname");
	
	// Truck movement
	guys	  = [];
	guys[ 0 ] = level.intro_truck_cab;
	guys[ 1 ] = level.intro_truck_trailer;
	self thread anim_single ( guys, "factory_truck_entrance" );
	
}
/*
silencer_hint_breakout()
{
	weapon	= level.player GetCurrentWeapon();
	
	if ( weapon != level.default_weapon )
		return true;

	alt_ = StrTok( weapon, "_" );
	if ( IsDefined( alt_.size ) )
	{	
		if ( alt_[ 0 ] == "alt" )
	   	{
	   		return true;
	   	}
	   	else
	   	{
	   		return false;
	   	}
	}
}
*/
// =====================================
// FACTORY INGRESS
// =====================================
factory_ingress_start()
{
	level.player SwitchToWeapon( level.default_weapon ); //mp5_silencer_eotech, iw5_m4flir2_sp_reflexflir2_silencerunderflir2
	level.player TakeWeapon( "flash_grenade" );
	level.player TakeWeapon( "fraggrenade" );
	
	flag_set( "intro_checkpoint_done" );
	flag_set( "player_entered_awning" );
	
	teleport_squad( "factory_ingress", "deltaecho" );
	
	// Catch the player up in player speed progression
	flag_set( "intro_kill_sequence_done" );
	
	player_speed_percent( 65 );
		
//	thread move_outside_crane();
	thread factory_entrance_setup();
	thread handle_player_leaving_mission();
	
	battlechatter_off();	
	
	thread intro_truck_setup();
	flag_set ( "factory_exterior_reveal" );
	
	trigger = GetEnt( "sca_trainyard_exit", "targetname" );
	trigger trigger_off();
	
	thread maps\_weather::rainNone( 3 ); // HACK tagTJ: turning rain off here until bug is fixed on PC
	
}

factory_ingress()
{
	thread factory_entrance_dialogue_management();
	thread factory_entrance_reveal();
	thread conveyor_container_setup();
	
//	thread maps\_weather::rainLight ( 1 );  // HACK tagTJ: turning rain off here until bug is fixed on PC
	
	// Level variables
	level.cosine[ "70" ]						= Cos( 70 );
	level.goodFriendlyDistanceFromPlayerSquared = 250 * 250;
	
	// tagTJ - Should get the weapon to default to the silencer, but this'll do for now
	// level delayThread ( 3, ::display_hint_timeout, "hint_silencer_toggle", 4 );
	
	// Keep allies from mowing through guards until we want them to
	foreach ( squadmate in level.squad )
		squadmate.ignoreall = true;
	
	intro_pmcs = get_living_ai_array( "intro_pmcs", "targetname" );
	foreach ( guy in intro_pmcs )
		guy.ignoreall = true;
	
	flag_set( "factory_entrance_setup" );
	
	foreach ( guy in level.squad )
	{
		guy enable_cqbwalk();
		guy disable_sprint();
		guy.accuracy = 100;
	}
	
	flag_wait( "enter_factory" );
}

factory_entrance_setup()
{
	intro_pmcs = GetEntArray( "intro_pmcs", "targetname" );
	
	// Spawn and then make all soldiers ignorant
	foreach ( guy in intro_pmcs )
	{
		spawned			  = guy spawn_ai();
		spawned.ignoreall = true;
	}
	
	thread maps\factory_fx::fx_show_hide( "intro_cardreader_lock", "intro_cardreader_unlock" );
	stop_exploder( "intro_cardreader_unlock" );
	exploder( "intro_cardreader_lock" );
}

entrance_first_kill()
{
	maps\factory_util::safe_trigger_by_targetname( "move_from_entrance_kill" );
}

factory_entrance_enc()
{
	entrance_kill_alpha						  = get_living_ai( "entrance_enemy_03", "script_noteworthy" );
	level.squad[ "ALLY_ALPHA" ].favoriteenemy = entrance_kill_alpha;

	entrance_kill_bravo						  = get_living_ai( "entrance_enemy_02", "script_noteworthy" );
	level.squad[ "ALLY_BRAVO" ].favoriteenemy = entrance_kill_bravo;

	entrance_kill_charlie						= get_living_ai( "entrance_enemy_01", "script_noteworthy" );
	level.squad[ "ALLY_CHARLIE" ].favoriteenemy = entrance_kill_charlie;
	
	foreach ( guy in level.squad )
	{
		guy.disableplayeradsloscheck = true;
		guy PushPlayer( true );
	}

	truck_enemy_array = [ entrance_kill_alpha, entrance_kill_bravo, entrance_kill_charlie ];
		
	thread handle_player_exposing( truck_enemy_array );
	thread setup_factory_entrance_enc( truck_enemy_array );
	level.squad[ "ALLY_BRAVO"	]thread bravo_ingress_detail  (	 );
	level.squad[ "ALLY_CHARLIE" ]thread charlie_ingress_detail(	 );

	level.squad[ "ALLY_ALPHA" ] thread strafe_entrance();
	
	thread detect_allies_at_entrance();
	
	flag_wait_all( "factory_entrance_reveal" );
	
	wait 0.5;
	
	level thread set_flag_on_player_action( "intro_truck_driver_dead" );
	level thread truck_kill_timeout();
	
	/*
	//Baker: Get a target… Rook, we're on you…
	thread smart_radio_dialogue( "factory_bkr_getatarget" );
	level.squad[ "ALLY_ALPHA" ] SetLookAtEntity( level.player );
	
	wait 1.0;
	level.squad[ "ALLY_ALPHA" ] SetLookAtEntity();
	*/
	
	flag_wait_any( "intro_truck_driver_dead", "truck_kill_timed_out" );
	
	// Cycling through all enemies and kill them
	eliminate_all_targets( truck_enemy_array );
	
	//stoping truck chatter sounds

	/*
	// If player let things timeout, have Baker give new orders
	if ( flag( "truck_kill_timed_out" ) )
	{
		//Baker: Drop ‘em.
		level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_dropem" );
//		wait 1.0;
	}
	
	
	// Admonish the player if they didn't keep things moving
	if ( flag( "truck_kill_timed_out" ) )
	{
		//Merrick: Don't have all day, Adam.
		level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_donthaveallday" );
		wait 1.5;
	}
	*/
	flag_set( "truck_kills_done" );
	
	wait 1.2;	

	//Merrick: All clear, Hesh grab a security badge. I got right.
	// level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_allclearheshgrab" );

	level.squad[ "ALLY_CHARLIE" ]thread charlie_search_body		 ( entrance_kill_bravo );
	level.squad[ "ALLY_ALPHA"	]thread alpha_post_truck_sequence(	);
	
	wait 2.0;
	
	thread factory_entrance_reveal_animate_pieces();
	
	wait 2.0;

	//Keegan: Cover Left.
	// level.squad[ "ALLY_BRAVO" ] thread smart_dialogue( "factory_kgn_coverleft" );
	
	flag_wait( "outer_perim_cleared" );
	
	flag_wait( "card_swiped" );

	//Rogers: Opening…
	// 	smart_radio_dialogue( "factory_rgs_opening" );

	//first play a beep from the keypad	
	wait 0.15;
	thread maps\factory_audio::audio_play_unlock_sound();
	// CHAD TESTS FOR PC GOD RAYS!!!!!
	thread maps\factory_util::god_rays_factory_open();
	
	thread open_factory_door();	
	//play a temp sound from the door
	thread maps\factory_audio::audio_factory_door_open();	
	thread factory_ingress_dialogue();
//	thread move_forklifts();  // tagTJ: disabling this until we're ready for real vehicle implementation
//	thread move_crates(); // tagTJ: disabling until art is more settled
	
	flag_set( "music_factory_reveal" );
	
	factory_door_kill();
	
//	wait 4.5;
	maps\factory_util::safe_trigger_by_targetname( "sca_stairway_post" );
	
	// Set up anim scene for rogers
	waittillframeend;
//	level.squad[ "ALLY_CHARLIE" ] thread charlie_ingress_go();
	level.squad[ "ALLY_ALPHA" ]thread alpha_ingress_go(	 );
	level.squad[ "ALLY_BRAVO" ]thread bravo_ingress_go(	 );
	
	flag_set( "outer_perim_cleared" );
	
	// Wake up the squad and reset some settings
	foreach ( guy in level.squad )
	{
		guy.ignoreall				 = true;
		guy.disableplayeradsloscheck = false;
		guy PushPlayer( false );
	}
}

eliminate_all_targets( aEnemy )
{
	level endon( "entered_factory_1" );
	if ( isdefined ( level.squad["ALLY_DELTA"]) && isdefined ( level.squad["ALLY_ECHO"])  )
	{
		delete_squad_splinter();	
	}
	level.truck_kills = 0;
	// Setting allies to ignore friendlyfire for a moment
	level.ai_friendlyFireBlockDuration = GetDvarFloat( "ai_friendlyFireBlockDuration" );
	
	SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );
	// Thread off each ally to fire upon their respective targets
	foreach ( ally in level.squad )
	{
		ally thread eliminate_my_target();
		wait .5;
	}
	while ( level.truck_kills < 3 )
	{
		wait .1;	
	}
	// Set friendly fire setting back to normal
	SetSavedDvar( "ai_friendlyFireBlockDuration", level.ai_friendlyFireBlockDuration );
}

eliminate_my_target()
{
	self endon ( "death" );
	self disable_pain();
	self detect_ally_at_entrance();
	
	if ( IsAlive( self.favoriteenemy ) )
	{
		start_pos = self GetTagOrigin( "tag_flash" );
		end_pos	  = self.favoriteenemy GetShootAtPos();
		
		self thread fire_on_target( self.favoriteenemy, start_pos, end_pos );
		
		if ( self.favoriteenemy.script_noteworthy != "entrance_enemy_02" )
		{
			self.favoriteenemy Kill();	
		}
		else 
		{
			self.favoriteenemy DoDamage( 1, (0,0,0) );
		}
	}
	level.truck_kills = level.truck_kills + 1;
	self enable_pain();	
}

detect_ally_at_entrance()
{
	vol = GetEnt( "vol_entrance_squad_count", "script_noteworthy" );
	while ( !self IsTouching ( vol ) )
	{
	 	wait .1;		
	}
}

fire_on_target( enemy, start_pos, end_pos )
{
	wait RandomFloatRange( 0.1, 0.7 );
	
	for ( i = 0; i <= RandomIntRange( 2, 3 ); i++ )
	{
		self safe_magic_bullet( start_pos, end_pos );
		wait 0.2;
	}
}

detect_allies_at_entrance()
{
	level endon ("truck_kills_done");
	vol = GetEnt( "vol_entrance_squad_count", "script_noteworthy" );	
	
	while ( true )
	{
		aAllies = vol get_ai_touching_volume( "allies" );

		if ( aAllies.size > 2 )
			break;
		
		wait 0.5;
	}
		
	flag_set( "all_allies_at_entrance" );
}

// Set the master flag for everything else to progress if the player doesn't do anything at the truck kill
truck_kill_timeout()
{
	level endon( "intro_truck_driver_dead" );
	
	flag_wait_or_timeout( "intro_truck_driver_dead", 12 );
	
	flag_set( "truck_kill_timed_out" );
	wait 1.5; // Wait and give a chance for Merrick to give the kill order
	flag_set( "intro_truck_driver_dead" );
}

alpha_post_truck_sequence()
{
	level endon( "entered_factory_1" );
	
	level.squad[ "ALLY_BRAVO" ] thread bravo_post_truck_sequence();
	
	node = GetNode( "alpha_after_truck_kill", "script_noteworthy" );
	self SetGoalNode( node );
	self waittill( "goal" );
	
	flag_wait( "start_search" );

	wait 4.5; // Waiting until Rogers says he's got a badge
	
	//Merrick: On the door…
	// level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_onthedoor" );
	
	self.goalradius = 64;
	self.disablearrivals = true;
	self.disableexits	= true;
	node = GetNode( "alpha_path_to_dock", "script_noteworthy" );
	self follow_path( node );
	
	maps\factory_util::safe_trigger_by_targetname( "allies_factory_entrance" ); // Move other allies into position
	
	self waittill( "goal" );
	self.disablearrivals = false;
	self.disableexits	 = false;
}

bravo_post_truck_sequence()
{
	level endon( "entered_factory_1" );
	
	// Move Keegan to first position
//	maps\factory_util::safe_trigger_by_targetname( "post_truck_search" );  // Move Keegan around to cover Rogers
	self.goalradius = 8;
	node			= GetNode( "bravo_truck_search_1st_pos", "script_noteworthy" );
	self SetGoalNode( node );
	self waittill( "goal" );
	
	wait 3.0; // Waiting a bit till he moves to second position

//	// Move Keegan to a second position
//	node = GetNode( "bravo_truck_search_2nd_pos", "script_noteworthy" );
//	self SetGoalNode( node );
}

factory_door_kill()
{
	spawner_stationary = GetEnt( "factory_door_kill_stationary", "script_noteworthy" );
	spawner_mobile = GetEnt( "factory_door_kill_mobile", "script_noteworthy" );
	
	spawner_stationary add_spawn_function( ::factory_door_guard_stationary );
	spawner_mobile add_spawn_function( ::factory_door_guard_mobile );
	
	guard_stationary = spawner_stationary spawn_ai();
	guard_mobile	 = spawner_mobile spawn_ai();
	
	// Spawning forklift blocker to slow player down
	agv_spawner = GetEnt( "agv_fac_ent_blocker", "targetname" );
	agv_spawner add_spawn_function( maps\factory_util::forklift_run_over_monitor );
//	agv = agv_spawner spawn_vehicle_and_gopath();
//	
//	parts = GetEntArray( "guncrate", "targetname" );
//	foreach( part in parts )
//	{
////		part LinkTo( agv );
//		part Delete();
//	}
	
//	setup_loading_area_guards();
			
	wait 1.45;
	
	//Keegan: Two ahead.
	level.squad[ "ALLY_BRAVO" ] thread smart_dialogue( "factory_kgn_twoahead" );
	
	flag_wait_or_timeout( "first_door_guard_shot", 1.9 ); // Timing window to allow player action
	
	//Baker: Drop ‘em.
	level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_bkr_dropem" );

	if ( !flag( "first_door_guard_shot" ) )
		wait 0.5;
	
	if ( IsAlive( guard_stationary ) )
	{
		MagicBullet( level.squad[ "ALLY_BRAVO" ].weapon, level.squad[ "ALLY_BRAVO" ] GetTagOrigin( "tag_flash" ), guard_stationary GetShootAtPos() );
		guard_stationary StopAnimScripted();
		guard_stationary Kill();
	}
	
	wait 1.0;
	
	if ( IsAlive( guard_mobile ) )
	{
		MagicBullet( level.squad[ "ALLY_ALPHA" ].weapon, level.squad[ "ALLY_ALPHA" ] GetTagOrigin( "tag_flash" ), guard_mobile GetShootAtPos() );
		guard_mobile StopAnimScripted();
		guard_mobile Kill();
	}
	
	wait 0.5;
	
	//Hesh: Clear to move.
	level.squad[ "ALLY_CHARLIE" ] thread smart_dialogue( "factory_hsh_cleartomove" );
	
	flag_set( "enter_factory" );
		
//	thread loading_area_enc();
}

setup_loading_area_guards()
{
	spawners = GetEntArray( "loading_area_guards", "targetname" );
	
	foreach ( guard in spawners )
	{
		guard add_spawn_function( ::loading_area_guards_think );
		guard spawn_ai();
	}
}

loading_area_guards_think()
{
	self.ignoreall = true;
	self setup_patrol();
	
	flag_wait( "first_door_guard_shot" );
	
	self.ignoreall = false;
	
	vol = GetEnt( "vol_loading_area", "targetname" );
	
	if ( level.player IsTouching( vol ) )
	{
		self.favoriteenemy = level.player;
		self SetGoalPos( level.player.origin );
	}
	else
	{
		self SetGoalPos( self.origin );
	}
}

loading_area_enc()
{
	foreach ( guy in level.squad )
	{
		guy.ignoreall = false;
		guy disable_pain();
		guy.ignoresuppression = true;
	}
	
	flag_wait( "loading_area_guards_dead" );
	
	foreach ( guy in level.squad )
	{
		guy.ignoreall		  = true;
		guy.ignoresuppression = false;
	}
}

safe_magic_bullet( start_pos, end_pos )
{
	fake_it = false;

	trace = BulletTrace( start_pos, end_pos, true );
	
	// Check to be sure that allies are also not in the way
	hit_ally = false;
	foreach ( ally in level.squad )
	{
		if ( IsDefined( trace[ "entity" ] ) && trace[ "entity" ] == ally )
			hit_ally = true;
	}
	
	if ( IsDefined( trace[ "entity" ] ) && trace[ "entity" ] == level.player || hit_ally == true )
	{
		fake_it = true;
	}

	if ( IsDefined( trace[ "fraction" ] ) < 0.8 )
	{
		fake_it = true;
	}

	PlayFXOnTag( getfx( "silencer_flash" ), self, "tag_flash" );

	if ( fake_it )
	{
		angles	  = VectorToAngles( end_pos - start_pos );
		forward	  = AnglesToForward( angles );
		start_pos = end_pos + ( forward * -10 );
	}

	MagicBullet( self.weapon, start_pos, end_pos );
}

factory_door_guard_stationary()
{
	self endon( "death" );
	
	self thread factory_door_guard_player_spotted();
	
	self.animname	= "enemy";
	self.ignoreall	= true;
	self.allowdeath = true;
	
	node = GetEnt( "factory_door_kill_stationary_node", "targetname" );
	
	node anim_reach_solo( self, "factory_truck_enemy02_loop" );
	node thread anim_loop_solo( self, "factory_truck_enemy02_loop", "stop_loop" );
	
	self waittill( "damage" );
	
	flag_set( "first_door_guard_shot" );
	
	node notify( "stop_loop" );
	self StopAnimScripted();
	
	buddy = get_living_ai( "factory_door_kill_mobile", "script_noteworthy" );
	
	if ( IsDefined( buddy ) )
		buddy anim_single_solo( buddy, "prague_intro_dock_guard_reaction_02" );
}

factory_door_guard_mobile()
{
	self endon( "death" );
	
	self thread factory_door_guard_player_spotted();
	
	self.animname	= "enemy";
	self.ignoreall	= true;
	self.allowdeath = true;
	
	node = GetEnt( "factory_door_kill_mobile_node", "targetname" );
	
	self thread anim_single_solo( self, "factory_truck_enemy01_enter" );
//	node thread anim_loop_solo( self, "factory_truck_enemy01_loop" );
	
	self waittill( "damage" );
	
	flag_set( "first_door_guard_shot" );
	
	buddy = get_living_ai( "factory_door_kill_stationary", "script_noteworthy" );
	
	if ( IsDefined( buddy ) )
		buddy anim_single_solo( buddy, "surprise_stop_v1" );
}

factory_door_guard_player_spotted()
{
	self endon ( "death" );
	// self setup_patrol();
	
	flag_wait( "first_door_guard_shot" );
	
	if ( self CanSee( level.player ) )
	{
		self anim_single_solo ( self, "exposed_idle_reactB");
	}
}

strafe_entrance()
{
	level endon( "truck_kills_done" );
	
	self.goalradius		  = 64;
	alpha_node			  = GetNode( "alpha_after_first_kill", "script_noteworthy" );
	alpha_path			  = GetNode( "alpha_truck_path", "script_noteworthy" );
	self.maxFaceEnemyDist = 1024;
	self follow_path( alpha_path );
	self.moveplaybackrate = 0.5;
	self SetGoalNode( alpha_node );
	self.moveplaybackrate = 1.0;
}

charlie_search_body( guard )
{
	level endon( "entered_factory_1" );
	
	self PushPlayer( true );

	// Break out of previous loop
	node = GetEnt( "fac_ent_stand_forklift_org", "targetname" );
	node StopAnimScripted();
	node notify( "stop_loop" );
	
	// Setting up search scene
	node = GetEnt( "truck_sequence_node_alt", "script_noteworthy" );
	guard.animname	= "enemy";
	self.goalradius = 8;
	
	node anim_reach_solo( self, "factory_truck_ally02_search" );
	flag_set( "start_search" );
	node thread anim_single_solo( self, "factory_truck_ally02_search" );
	// node thread anim_single_solo( guard, "factory_truck_enemy02_death_searched" );
	
	thread maps\factory_audio::audio_factory_search_body();
	
	wait 2.0;
	
	exploder( "body_roll_dust" );
	
	wait 1.5;

	//Hesh: Got one.
	self thread smart_dialogue( "factory_rgs_gotone" );
	
	// Create and link the security card asset
	keycard = GetEnt( "security_card", "targetname" );
	keycard.origin = level.squad[ "ALLY_CHARLIE" ] GetTagOrigin( "tag_inhand" );
	keycard LinkTo( level.squad[ "ALLY_CHARLIE" ], "tag_inhand", ( 0.6, 0, 1 ), ( -50, 0, 0 ) );
	
//	self PushPlayer( true );
//	self anim_changes_pushplayer( false );
	self.goalradius = 8;
	
	self thread charlie_ingress_go();
	
	flag_wait( "card_swiped" );
	
	keycard Delete();
	
//	self PushPlayer( false );
//	self anim_changes_pushplayer( true );
}

bravo_ingress_detail()
{
	flag_wait( "factory_entrance_reveal" );
	
	self SetGoalNode( GetNode( "bravo_truck_kill_node", "script_noteworthy" ) );
}

charlie_ingress_detail()
{
	level endon( "intro_truck_driver_dead" );
	
	flag_wait( "factory_entrance_reveal" );
	
	/*
	self SetLookAtEntity( level.player );
//	self handsignal( "enemy" );
	wait 2.0;
	self SetLookAtEntity();
	*/
	
	while ( 1 )
	{
		if ( players_within_distance( 48, GetNode( "fac_ent_charlie_node", "targetname" ).origin ) )
		{
			self.goalradius = 8;
			node = GetEnt( "fac_ent_stand_forklift_org", "targetname" );
			node thread anim_reach_and_idle_solo( self, "cqb_walk_2_creepwalk", "cqb_aim", "stop_loop" );
			
			break;
		}
		wait 1.0;
	}
}

handle_player_exposing( aEnemy )
{
	level endon( "truck_kills_done" );
	// level endon( "intro_truck_driver_dead" );
	
	flag_wait_any ( "player_scene_interrupt", "intro_truck_driver_dead" );
	
	level.player.ignoreme = false;
	
	battlechatter_on( "axis" );

	foreach ( pmc in aEnemy )
	{
		if ( IsAlive( pmc ) )
		{
		  	pmc.ignoreall = false;
//			pmc.dontEverShoot = true;
			pmc.favoriteenemy = level.player;
			
			// We don't want to stop the searched enemy if he is playing an animated death
			// He will be set to the neutral team if he is.
			if ( pmc.team == "axis" )
				pmc StopAnimScripted();
			
			pmc SetGoalPos( pmc.origin );
			pmc cqb_aim( level.player );
		}
	}
	
	// flag_wait ( "all_allies_at_entrance" );
	
	//Baker: Drop ‘em.
	// thread smart_radio_dialogue( "factory_bkr_dropem" );

	wait 1.0;
	
	battlechatter_off();
	
	flag_set( "intro_truck_driver_dead" );

	wait 1.0;
	
}

setup_factory_entrance_enc( aEnemy )
{
	level endon( "intro_truck_driver_dead" );
	
	aEnemy[ 0 ] endon( "death" );
	aEnemy[ 1 ] endon( "death" );
	aEnemy[ 2 ] endon( "death" );
	
	flag_wait( "factory_entrance_reveal" );
	
	aEnemy[ 0 ] thread ingress_enc_think_enemy01();
	aEnemy[ 1 ] thread ingress_enc_think_enemy02();
	aEnemy[ 2 ] thread ingress_enc_think_enemy03();
}

ingress_enc_think_enemy01()
{
	self endon( "death" );
	level endon( "entered_factory_1" );
	
	self.allowdeath = true;
// 	self.deathanim = %factory_truck_enemy01_death;
	self.noragdoll = true;
	self.animname  = "enemy";
	self.fixednode = 1;
	
	node = GetEnt( "truck_sequence_node", "script_noteworthy" );
	node anim_single_solo( self, "factory_truck_enemy01" );
	node thread anim_loop_solo( self, "factory_truck_enemy01_loop", "stop_loop" );
}

ingress_enc_enemy01_kill( node )
{
//	self wait_for_damage_or_flag( "intro_truck_driver_dead" );
	self waittill( "damage" );
	
	// Give Baker a moment to give the order if player didn't shoot
	if ( flag( "truck_kill_timed_out" ) )
	    wait 1.0;
}

ingress_enc_think_enemy02()
{
	self endon ( "death" );
	level endon( "entered_factory_1" );
//	level endon( "intro_truck_driver_dead" );
	
	self.health = 999;
	self.allowdeath = true;
	self.a.nodeath = true;
	self.ignoreme = true;
	self.animname = "enemy";
	self magic_bullet_shield();
	self disable_surprise();
	self.fixednode = 1;
	self.dontmelee = 1;
	self.delete_on_death = false;
	
	clipboard = spawn_anim_model ( "factory_intro_clipboard" );
	guys	  = [];
	guys[ 0 ] = self;
	guys[ 1 ] = clipboard;
		
	node = GetEnt( "truck_sequence_node_alt", "script_noteworthy" );
	
	self thread ingress_enc_enemy02_kill( guys, node );
	
	// node anim_reach_solo( self, "factory_truck_enemy02" );
	node thread anim_single( guys, "factory_truck_enemy02" );
	wait 0.05;
	node anim_set_time( guys, "factory_truck_enemy02", 0.1 );
//	node thread anim_loop_solo( self, "factory_truck_enemy02_loop", "stop_loop" );
}

ingress_enc_enemy02_kill( guys, node )
{
	self endon ( "death" );
	
//	self wait_for_damage_or_flag( "intro_truck_driver_dead" );
	self waittill( "damage" );
	
	// Give Baker a moment to give the order if player didn't shoot
//	if ( flag( "truck_kill_timed_out" ) )
//	    wait 2.0;
	
	self.team = "neutral";
	self.no_pain_sound = true;
	self.allowdeath = false;
	self.allowpain = false;
	self.diequietly = true;
	self.nocorpsedelete = true;
    	
	node thread anim_single( guys, "factory_truck_enemy02_death" );
	wait 2;
	self ThermalDrawDisable();
	wait ( GetAnimLength ( self getanim ( "factory_truck_enemy02_death" )  ) - 2);
	node anim_first_frame_solo( self, "factory_truck_enemy02_death_searched" );
	
	flag_wait( "start_search" );
	
	node anim_single_solo( self, "factory_truck_enemy02_death_searched" );
	
	self stop_magic_bullet_shield();
   	self maps\factory_anim::kill_no_react();
}

wait_for_damage_or_flag( flag_to_wait_on )
{
	self endon( "death" );
	
	while ( !flag( flag_to_wait_on ) )
	{
		self waittill_notify_or_timeout_return( "damage", 0.1 );
	}
}

ingress_enc_think_enemy03()
{
	self endon( "death" );
	level endon( "entered_factory_1" );
	
	self.allowdeath = true;
// 	self.deathanim = %factory_truck_enemy03_death; 
//	self.noragdoll = true;
	self.animname  = "enemy";
	self.fixednode = 1;
	
	node = GetEnt( "truck_sequence_node", "script_noteworthy" );
	node anim_single_solo( self, "factory_truck_enemy03" );
	node thread anim_loop_solo( self, "factory_truck_enemy03_loop", "stop_loop" );
}

intro_truck_failsafe()
{
	level endon( "entered_factory_1" );

	flag_wait( "intro_truck_driver_dead" );
	
	if ( IsAlive( self ) )
	{
		self StopAnimScripted();
		MagicBullet( level.squad[ "ALLY_ALPHA" ].weapon, level.squad[ "ALLY_ALPHA" ] GetTagOrigin( "tag_flash" ), self GetShootAtPos() );
		self Kill();
	}
}

open_factory_door()
{
	factory_entrance_door = GetEnt( "factory_entrance_door", "script_noteworthy" );	
	factory_entrance_door MoveZ( 184, 8, 1, 3 );
	//delayThread( 8.5, ::close_rolling_gate ); // Timed to allow forklift to get through before closing
	exploder( "door_open" );
	
	//thread maps\factory_audio::garage_sfx_reveal();
	thread maps\factory_audio::sfx_garage_reveal_crane();
	
	wait 4;
	factory_entrance_door ConnectPaths();
}

factory_entrance_reveal()
{
	flag_wait( "player_entered_awning" );
		
	thread maps\_weather::rainNone( 3 ); // HACK tagTJ: turning rain off here until bug is fixed on PC
	
	thread maps\factory_audio::sfx_garage_reveal_filtered();
	
	// allies no longer have splats but still drip water
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_ALPHA" ]	, "entered_factory_1", 0.2, true );
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_BRAVO" ]	, "entered_factory_1", 0.2, true );
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_CHARLIE" ], "entered_factory_1", 0.2, true );

	entrance_first_kill();
	factory_entrance_enc();

	flag_wait( "outer_perim_cleared" );
	
	flag_wait( "entered_factory_1" );
	// allies no longer have splats but still drip water
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_ALPHA" ]	, "powerstealth_end", 0.5, true );
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_BRAVO" ]	, "powerstealth_end", 0.5, true );
	thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_CHARLIE" ], "powerstealth_end", 0.5, true );
}

factory_ingress_dialogue()
{
	level endon( "entered_conveyor" );
	
	flag_wait( "entered_factory_1" );	
	
	wait 0.5;
	
	thread maps\factory_audio::audio_factory_reveal_mix( "one" );
	
	wait 0.5;
	
	thread maps\factory_audio::audio_factory_wait_for_mix_change();
	
	flag_wait( "ingress_dialogue_kickoff" );

	//Merrick: Keep your eyes out…
	level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_keepyoureyesout" );
	
	wait 0.5;
	
	//Merrick: Oldboy – how are those cameras coming?
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_oldboyhowarethose" );
	
	//Oldboy: Merrick – eyes on your next zone - lots of targets, no good advantage.
	smart_radio_dialogue( "factory_oby_merrickeyesonyour" );
	
	//Merrick: …we'll make our own advantage.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_wellmakeourown" );
}

charlie_ingress_go()
{
	level endon( "powerstealth_end" );
	
	self notify( "stop_adjust_movement_speed" );
	
	self.goalradius = 8;
	node = GetNode( "factory_ingress_node_ally01", "script_noteworthy" );
	node anim_reach_and_approach_solo( self, "factory_allies_enter_factory_ally_01", undefined );
//	node anim_first_frame_solo( self, "factory_allies_enter_factory_ally_01" );
	
	self SetGoalNode( node );

	flag_wait( "outer_perim_cleared" );
	
	wait 1.0;
	
	// Play the rising cover anim as the door opens
//	node thread anim_single_solo( self, "factory_allies_enter_factory_ally_01" );
		
	flag_set( "card_swiped" );
	
	flag_wait( "enter_factory" );
	
	self disable_cqbwalk();
	self thread friendly_adjust_movement_speed();
	
	node = GetNode( "charlie_anim1", "targetname" );
	self.goalradius = 16;
//	self SetGoalNode( node );
//	self waittill( "goal" );
	node anim_reach_solo( self, "combatwalk_F_spin" );

	flag_set( "ingress_dialogue_kickoff" );
	
	if ( !flag( "entered_loading_area" ) )
	{
		node anim_single_solo( self, "combatwalk_F_spin" );
		self SetGoalPos( self.origin );
	}
	
	self SetGoalNode( GetNode( "charlie_anim1_end", "targetname" ) );
	self enable_ai_color();

	self waittill( "goal" );
//	flag_wait( "ps_begin" );
	
	self.moveplaybackrate = 1.0;
	self notify( "stop_adjust_movement_speed" );
	
	maps\factory_util::safe_trigger_by_targetname( "sca_powerstealth_regroup" );
}

bravo_ingress_go()
{
	level endon( "exited_conveyor" );
	
	self notify( "stop_adjust_movement_speed" );
	
	self.goalradius = 8;
	
	self disable_cqbwalk();	
	self thread friendly_adjust_movement_speed();
//	self.moveplaybackrate = 1.2;
	
	node = GetNode( "stairway_post_bravo", "targetname" );
	self SetGoalNode( node );

	self waittill( "goal" );

	flag_wait( "ps_begin" );
	
	self.moveplaybackrate = 1.0;
	self notify( "stop_adjust_movement_speed" );
}

alpha_ingress_go()
{
	level endon( "exited_conveyor" );
	
	self notify( "stop_adjust_movement_speed" );
	
	self.moveplaybackrate = 1.2;
	self.goalradius		  = 128;
	self disable_cqbwalk();
	self manage_ally_cqb();
	
	self disable_cqbwalk();
	self thread friendly_adjust_movement_speed();
	
	self SetGoalNode( GetNode( "alpha_ingress_path2", "script_noteworthy" ) );
	self waittill( "goal" );
	
	self.moveplaybackrate = 1.0;
	self notify( "stop_adjust_movement_speed" );
}

manage_ally_cqb()
{
	self endon( "stop_cqb_management" );
	
	vol = GetEnt( "vol_ps_staircase", "targetname" );
	
	while ( self IsTouching( vol ) )
	{
		self enable_cqbwalk();
		self.moveplaybackrate = 1.0;
		self notify( "stop_adjust_movement_speed" );
		wait 0.5;
	}
	
	self disable_cqbwalk();
	
	self notify( "stop_cqb_management" );
}

factory_entrance_dialogue_management()
{
	level endon( "entered_factory_1" );
	
	flag_wait( "player_entered_awning" );
	//Baker: Targets ahead.
	level.squad[ "ALLY_ALPHA" ] radio_dialogue( "factory_bkr_targetsahead" );
	
	flag_wait ("factory_entrance_reveal") ;
	flag_wait_any ( "all_allies_at_entrance", "intro_truck_driver_dead", "player_scene_interrupt" );
	
	if ( ! flag ( "intro_truck_driver_dead" ))
	{
		//Baker: Get a target… Rook, we're on you…
		thread smart_radio_dialogue( "factory_bkr_getatarget" );
	}
	
	flag_wait_any( "intro_truck_driver_dead", "truck_kill_timed_out" );
	
	//Baker: Drop ‘em.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_dropem" );
	
	// Admonish the player if they didn't keep things moving
	if ( flag( "truck_kill_timed_out" ) )
	{
		//Merrick: Don't have all day, Adam.
		level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_donthaveallday" );
		wait 1.5;
	}
	
	if ( flag ( "player_scene_interrupt" ))
	{
		//Merrick: Adam, what're you doing!?
		smart_radio_dialogue( "factory_mrk_adamwhatreyoudoing" );
	}
	
	flag_wait ( "truck_kills_done" );
	
	//Merrick: All clear, Hesh grab a security badge. I got right.
	level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_allclearheshgrab" );
	
	wait 4.5;
	
	//Keegan: Cover Left.
	level.squad[ "ALLY_BRAVO" ] thread smart_dialogue( "factory_kgn_coverleft" );
	
	flag_wait( "start_search" );

	wait 4.5; // Waiting until Rogers says he's got a badge
	
	//Merrick: On the door…
	level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_mrk_onthedoor" );
	
	flag_wait( "card_swiped" );

	//Rogers: Opening…
	smart_radio_dialogue( "factory_rgs_opening" );
	
	flag_wait( "outer_perim_cleared" );
}

friendly_adjust_movement_speed()
{
	self notify( "stop_adjust_movement_speed" );
	self endon( "death" );
	self endon( "stop_adjust_movement_speed" );
	
	for ( ;; )
	{
		wait RandomFloatRange( 0.5, 1.0 );
		
		while ( friendly_should_speed_up() )
		{
//			IPrintLnBold( "friendlies speeding up" );
			self.moveplaybackrate = 2.5;
			wait 0.02;
		}
		
		self.moveplaybackrate = 1.0;
	}
}

friendly_should_speed_up()
{
//	prof_begin( "friendly_movement_rate_math" );
	
	if ( DistanceSquared( self.origin, level.player.origin ) <= level.goodFriendlyDistanceFromPlayerSquared )
	{
//		prof_end( "friendly_movement_rate_math" );
		return false;
	}
	
	// check if AI is visible in player's FOV
	if ( within_fov( level.player.origin, level.player GetPlayerAngles(), self.origin, level.cosine[ "70" ] ) )
	{
//		prof_end( "friendly_movement_rate_math" );
		return false;
	}
//	else
//	{
//		if ( self == level.squad[ "ALLY_CHARLIE" ] )
//			IPrintLnBold( "CAN'T SEE ME" );
//	}
	
//	prof_end( "friendly_movement_rate_math" );
	
	return true;
}

// =====================================
// POWERSTEALTH
// =====================================
powerstealth_start()
{
	level.player SwitchToWeapon( level.default_weapon );
	level.player TakeWeapon( "flash_grenade" );
	level.player TakeWeapon( "fraggrenade" );

	flag_set( "intro_checkpoint_done" );
	flag_set( "player_entered_awning" );
	flag_set( "outer_perim_cleared" );
	flag_set( "entered_factory_1" );
	flag_set( "factory_entrance_setup" );
	flag_set( "intro_kill_sequence_done" );
	
	teleport_squad( "powerstealth", "deltaecho" );
	
	player_speed_percent( 65 );
	
//	thread factory_entrance_setup();
	thread conveyor_container_setup();
	
	battlechatter_off();	
		
	// tagTJ - Should get the weapon to default to the silencer, but this'll do for now
//	weapon = level.player GetCurrentWeapon();
//	if ( weapon == level.default_weapon )
	//	level delayThread ( 3, ::display_hint_timeout, "hint_silencer_toggle", 4 );
	
	thread maps\_weather::rainNone( 3 );
}

powerstealth()
{
	
	level.player GiveMaxAmmo( level.default_weapon );
	
	// Player still at stealth/CQB speed
	player_speed_percent( 65 );
	
	thread train_cleanup();
	
	powerstealth_setup();
	powerstealth_enc();
	
	// Reset squad back to defaults
	foreach ( guy in level.squad )
	{
		guy.disableplayeradsloscheck = false;
		guy PushPlayer( false );
		guy.moveplaybackrate = 1.0;
		guy enable_pain();
	}
	
	// Wait for everyone to die before continuing on with door opening
	flag_wait_all( "ps_alpha_done", "ps_bravo_done", "ps_charlie_done" );
}

powerstealth_setup()
{
	flag_wait( "through_conveyor" );
	
	// Keep allies from shooting everything and from being shot
//	squad_stealth_on();
	foreach ( guy in level.squad )
	{
		guy.ignoreall	 = true;
		guy.ignoreme = true;
		guy.disableplayeradsloscheck = true;
		guy PushPlayer( true );
	}
	
	level thread factory_stealth_settings();	
	stealth_set_default_stealth_function( "factory_stealth", ::factory_stealth_settings );

	// Setup platform guard with flashlight
	ps_guard_1_platform_spawner = GetEnt( "ps_guard_1_platform", "script_noteworthy" );
	ps_guard_1_platform_spawner add_spawn_function( ::ps_guard_platform_think );
	level.guard_platform = ps_guard_1_platform_spawner spawn_ai();
	
	// Setup tunnel guard
	ps_guard_2_tunnel_spawner = GetEnt( "ps_guard_2_tunnel", "script_noteworthy" );
	ps_guard_2_tunnel_spawner add_spawn_function( ::ps_guard_tunnel_think );
	level.guard_tunnel = ps_guard_2_tunnel_spawner spawn_ai();
	
	// Setup silhouetted window guards
	spawner_window_01 = GetEnt( "ps_guard_window_01", "script_noteworthy" );
	spawner_window_01 add_spawn_function( ::ps_guard_window_01_think );
	level.guard_window_01 = spawner_window_01 spawn_ai();
	
	spawner_window_02 = GetEnt( "ps_guard_window_02", "script_noteworthy" );
	spawner_window_02 add_spawn_function( ::ps_guard_window_02_think );
	level.guard_window_02 = spawner_window_02 spawn_ai();
	
	// Setup final kills for Rogers
	ps_final_rogers_kill_spawner = GetEnt( "ps_final_rogers_kill", "script_noteworthy" );
	ps_final_rogers_kill_spawner add_spawn_function( ::ps_final_rogers_kill_think );
	level.guard_office_sleeper = ps_final_rogers_kill_spawner spawn_ai();

	powerstealth_final_kills = GetEntArray( "powerstealth_final_kills", "targetname" );
	foreach ( spawner in powerstealth_final_kills )
		spawner add_spawn_function( ::final_alpha_kill_think );
	maps\factory_util::safe_trigger_by_targetname( "powerstealth_final_kills_spawner" );
	
	thread maps\factory_weapon_room::presat_init_revolving_door();
}

ps_guard_platform_think()
{
	self endon( "death" );
	level endon( "ps_charlie_second_enemy_alerted" );
	
	self ps_guard_standard_settings();
	
	self.patrol_walk	  = [ "walk_gun_unwary" ];
	self.moveplaybackrate = 0.6;
	self set_generic_run_anim_array( random( self.patrol_walk ) );
	self attach_flashlight( true, true );
	
	node = GetNode( self.target, "script_noteworthy" );
	node anim_reach_solo( self, "flashlight_search_loop" );
	node thread anim_loop_solo( self, "flashlight_search_loop", "stop_loop" );
	
	self thread ps_guard_platform_think_breakout( node );
	
	flag_wait( "powerstealth_split" );
	
	waittill_entity_in_range_or_timeout( level.player, 475, 2.5 ); // Used for timing the window for the player shot	
	
	self.dontdrop_flashlight = true; // Used to tell flashlight system that we're not dropping the flashlight here
	self detach_flashlight();
	wait 0.1;

	self attach_flashlight( true, false );
	self.dontdrop_flashlight = undefined; // Let the guard drop the flashlight from here on out
	
	self StopAnimScripted();
	node notify( "stop_loop" );
	
	self.goalradius = 8;
	
	node = GetEnt( "guard_platform_walk_and_search", "script_noteworthy" );
	node anim_reach_solo( self, "active_patrolwalk_v4" );
	node anim_single_solo( self, "active_patrolwalk_v4" );
	
	// Now playing directly off the current entity instead of the node
	self anim_single_solo( self , "active_patrolwalk_v5" );
	self anim_single_solo( self , "active_patrolwalk_v5" );
	self anim_single_solo( self , "active_patrolwalk_pause" );
}

ps_guard_platform_think_breakout( node )
{
	self endon( "death" );
	
	self thread watch_for_player( 160, "ps_charlie_second_enemy_alerted" );
	
	self waittill( "ps_charlie_second_enemy_alerted" );
	flag_set( "ps_charlie_second_enemy_alerted" );
	
	// Wake the entity up and let him loose
	self.goalradius = 8;
	self StopAnimScripted();
	node notify( "stop_loop" );
	self SetGoalPos( self.origin );
	self.ignoreall = false;
	self.see_player = true;
	self.favoriteenemy = level.player;
	self SetGoalPos( level.player.origin );
	
	self detach_flashlight();
}

ps_guard_tunnel_think()
{
	self endon( "death" );
	
	self ps_guard_standard_settings( true );
	self thread watch_for_player( 25, undefined, true, true );	
	self thread notify_alpha_on_alert();
	
	node = GetEnt( "ps_guard_2_tunnel_start_node", "script_noteworthy" );
	
	node anim_reach_solo( self, "casual_stand_idle" );
	node thread anim_loop_solo( self, "casual_stand_idle", "stop_loop" );
	
	flag_wait( "ps_alpha_second_pos_ready" );

//	node anim_first_frame_solo( self, "active_patrolwalk_turn_180" );
	
	self waittill_either( "baker_in_position", "ps_charlie_second_pos_ready" );
	
	node StopAnimScripted();
	node notify( "stop_loop" );
	node anim_reach_solo( self, "active_patrolwalk_turn_180" );	
	delayThread( 0.01, ::anim_set_rate_single, self, "active_patrolwalk_turn_180", 0.75 );
	node anim_single_solo( self, "active_patrolwalk_turn_180" );

	if ( !self.see_player )
	{
		self attach_flashlight( true );
		
		node = GetEnt( "ps_guard_2_tunnel_node", "script_noteworthy" );
		delayThread( 0.01, ::anim_set_rate_single, self, "active_patrolwalk_v2", 0.75 );
		node thread anim_single_solo( self, "active_patrolwalk_v2" );
		
		anim_time = self GetAnimTime( %active_patrolwalk_v2 );
		
		while ( anim_time < 0.94 )
		{
			anim_time = self GetAnimTime( %active_patrolwalk_v2 );
			wait 0.05;
		}
		
		self.goalradius = 8;
		self StopAnimScripted();
		self.see_player = true;
		self.favoriteenemy = level.player;
		self SetGoalPos( level.player.origin );
		self.ignoreall = false;	
		self clear_generic_run_anim();
		self clear_generic_idle_anim();
		self detach_flashlight();
		
		level.squad[ "ALLY_ALPHA" ] notify( "second_kill_ready" );
		
		self waittill( "damage" );
	}
}

notify_alpha_on_alert()
{
	self endon( "death" );
	
	self.alerted = false;
	
	while ( !self.alerted )
	{
		wait 0.5;
	}
	
	flag_set( "guard_tunnel_alerted" );
	level.squad[ "ALLY_ALPHA" ] notify( "guard_tunnel_alerted" );
}

watch_for_player( sight_cone, notify_to_self, no_quarter, has_flashlight )
{
	self endon( "death" );
	self endon( "in_animation" );
	level endon( "railgun_reveal_setup" );
	
	fov	= Cos( sight_cone );
	self.see_player = false;
	
	while ( IsAlive( self ) )
	{
		wait 0.1;
				
		// Is the player within a reasonable distance
		d = Distance( level.player.origin, self.origin );
		
		if ( IsDefined( d ) )
		{
			if ( d > 200 )
				continue;
			else
			{
				// Is the player within sight
				withinFOV = within_fov( self.origin, self.angles, level.player.origin, fov );
				
				if ( !withinFOV )
				{
					// If the player has gotten extraordinarily close, let's break him out
					if ( d < 80 )
						break;
					else
						continue;
				}
				else
				{
					// Give the player a chance to duck back behind cover, but only if we don't override it 
					if ( !IsDefined( no_quarter ) )
						wait d / 100; // Decreases re-check time the closer the player is
					else
						wait d / 175; // Shorten the reaction time
					
					check_again = within_fov( self.origin, self.angles, level.player.origin, fov );
					
					if ( !check_again )
						continue;
					else
					{
//						self StopAnimScripted();
//						self.ignoreall	= false;
//						self.see_player = true;
//						
//						self SetGoalPos( self.origin );
						break;
					}
				}
			}
		}
	}

	// Check to see if other things need to get kicked off
	if ( IsDefined( notify_to_self ) )
	{
		self notify( notify_to_self );
	}
	else
	{
		// Wake the entity up and let him loose
		self.goalradius = 8;
		self StopAnimScripted();
		self SetGoalPos( self.origin );
		self.ignoreall	   = false;
		self.see_player	   = true;
		self.favoriteenemy = level.player;
		self clear_generic_run_anim();
		self clear_generic_idle_anim();
		
		if ( IsDefined( has_flashlight ) )
			self detach_flashlight();
//			StopFXOnTag( level._effect[ "flashlight_spotlight" ], self, "tag_inhand" );
	}
	
	self.alerted = true;
}

ps_final_rogers_kill_think()
{
	self endon( "death" );
	
	self ps_guard_standard_settings();
	self.animname = "generic";
	
	level.sleeping_guard = self;
	
	// Guarantee the same model used so that animation can keep back from poking through back of the chair
	self SetModel( "body_elite_pmc_assault_b" );
	self maps\factory_util::swap_head( "head_russian_military_c" );
	
	cellphone = Spawn( "script_model", ( 0, 0, 0 ) );
	cellphone SetModel( "cnd_cellphone_01_on_anim" );
	cellphone.origin = self GetTagOrigin( "tag_inhand" );
	cellphone LinkTo( self, "tag_inhand", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	node = GetEnt( "sleeping_guard_node", "script_noteworthy" );
//	node anim_reach_solo( self, "sleep_enter" );
	node anim_first_frame_solo( self, "sleep_enter" );
	
	self waittill( "done_waking_up" );
	
	node notify( "stop_loop" );
	self StopAnimScripted();
//	self thread monitor_player_distance();
}

final_alpha_kill_think()
{
	level endon( "railgun_reveal_setup" );
	
//	self.health = 1;
	self.allowdeath = true;
//	self.noragdoll = true;
	self magic_bullet_shield();
	
	// Guarantee the same model used so that animation can keep back from poking through back of the chair
	self SetModel( "body_elite_pmc_assault_b" );
	self maps\factory_util::swap_head( "head_russian_military_c" );

	node = getstruct( "rest_area_kills", "script_noteworthy" );
	info_node = GetEnt( self.script_noteworthy + "_org", "script_noteworthy" );
	
	actors = [];
	
	if ( info_node.script_noteworthy == "ps_break_area_a_org" )
	{
		chair = spawn_anim_model( "chair_opfor01" );
		chair_col = GetEnt( "col_chair_breakarea_01", "script_noteworthy" );
		chair_col NotSolid();
		actors[ "chair_opfor01" ] = chair;
		actors[ "opfor01" ] = self;
		self.animname = "opfor01";
		level.guard_breakarea_01 = self;
		friend = get_living_ai( "ps_break_area_b", "script_noteworthy" ); // store this info for later
		node = GetEnt( "ps_break_area_a_org", "script_noteworthy" );
	}
	else
	{
		chair = spawn_anim_model( "chair_opfor02" );
		chair_col = GetEnt( "col_chair_breakarea_02", "script_noteworthy" );
		chair_col NotSolid();
		actors[ "chair_opfor02" ] = chair;
		actors[ "opfor02" ] = self;
		self.animname = "opfor02";
		level.guard_breakarea_02 = self;
		friend = get_living_ai( "ps_break_area_a", "script_noteworthy" ); // store this info for later
		node = GetEnt( "ps_break_area_b_org", "script_noteworthy" );
	}
	
	node thread anim_first_frame_solo( chair, "rest_area_kills" );
	
	node thread anim_loop_solo( self, self.animation, "stop_loop" );

	self thread watch_for_player( 320, "player_broke_break_area" );
	
	msg = self waittill_any_return( "damage", "friend_is_dead", "player_broke_break_area", "ps_baker_at_final_kill" );
	
	flag_set( "ps_break_area_triggered" );
	
	if ( msg == "damage" )
	{
		// If this enemy took damage then he is the first of the pair to die.  We kill him and notify his buddy to react appropriately
		
		friend notify( "friend_is_dead" ); // Notifying opposite guard that shooting has occurred
		
		self.allowdeath = false;
		self.noragdoll = true;
		if ( self.animname == "opfor01" )
		{
			level.guard_breakarea_01 thread maps\factory_audio::stealth_kill_table_right_sfx();
		}
		else
		{
			level.guard_breakarea_02 thread maps\factory_audio::stealth_kill_table_left_sfx();
		}

		node anim_single( actors, "rest_area_kills" );
		chair thread do_chair_collision( chair_col );
		
		if ( IsDefined( self.magic_bullet_shield ) )
		{
			self stop_magic_bullet_shield();
		}

		if ( IsAlive( self ) )
			self maps\factory_anim::kill_no_react();
	}
	else if ( msg == "friend_is_dead" )
	{
		// If we get into here, either Baker or the player has killed his buddy already
		
		// Play this if the player is nearby to experience it
		if ( flag( "ps_alpha_final_pos_ready" ) )
		{
			// SOLDIER: En la madre!  (Spanish exclamation) 
			//Federation Soldier 1: Holy shit!
			self thread smart_dialogue( "factory_sp1_enlamadre" );
		}	

		// Check to see if Baker is in position already to play his pistol shots.  
		// Otherwise, we play different reactions that lead to the enemies getting up and engaging the player
		if ( flag( "ps_baker_at_final_kill" ) )
		{
			self stop_magic_bullet_shield();
			self disable_surprise();
			self.allowdeath = false;
			self.noragdoll = true;
			
			if ( self.animname == "opfor01" )
			{
				level.guard_breakarea_01 thread maps\factory_audio::stealth_kill_table_right_sfx();
				node anim_single( actors, "rest_area_kills" );
				chair thread do_chair_collision( chair_col );
			}
			else
			{
				level.guard_breakarea_02 thread maps\factory_audio::stealth_kill_table_left_sfx();
				node anim_single( actors, "rest_area_kills" );
				chair thread do_chair_collision( chair_col );
			}
			
			self maps\factory_anim::kill_no_react();
		}
		else
		{
			self stop_magic_bullet_shield();
			self disable_surprise();
			
			if ( self.animname == "opfor01" )
			{
				level.guard_breakarea_01 thread maps\factory_audio::stealth_kill_table_alert_right_sfx();
				node thread anim_single_solo( chair, "break_area_react_a_chair" );
				node anim_single_solo( self, "break_area_react_a" );
			}
			else
			{
				level.guard_breakarea_02 thread maps\factory_audio::stealth_kill_table_alert_left_sfx();
				node thread anim_single_solo( chair, "break_area_react_b_chair" );
				node anim_single_solo( self, "break_area_react_b" );
			}
			
			chair thread do_chair_collision( chair_col );
			aEnemies = [ level.squad[ "ALLY_ALPHA" ], level.player ];
			enemy = get_closest_living( self.origin, aEnemies );
			self.favoriteenemy = enemy;
		}
	}
	else if ( msg == "player_broke_break_area" )
	{
		// Getting this messages means that the player has gotten too close to the enemies and has been detected
		// We run both enemies through their reaction animations and let them die naturally
		self StopAnimScripted();
		self stop_magic_bullet_shield();
		self disable_surprise();
		
		// Play this reaction if the player is around
		if ( flag( "ps_alpha_final_pos_ready" ) )
		{
			// SOLDIER: Who the hell (the fuck) are you!
			//Federation Soldier 1: Who the hell are you!
			self thread smart_dialogue( "factory_sp1_quienchingadoson" );
		}	
		
		if ( self.animname == "opfor01" )
		{
			level.guard_breakarea_01 thread maps\factory_audio::stealth_kill_table_alert_right_sfx();
			node thread anim_single_solo( chair, "break_area_react_a_chair" );
			node thread anim_single_solo( self , "break_area_react_a" );
		}
		else
		{
			level.guard_breakarea_02 thread maps\factory_audio::stealth_kill_table_alert_left_sfx();
			node thread anim_single_solo( chair, "break_area_react_b_chair" );
			node thread anim_single_solo( self , "break_area_react_b" );
		}
		
		chair thread do_chair_collision( chair_col );
		
		friend notify( "player_broke_break_area" );
		
		// Constantly check for closest enemy and engage them
		aEnemies = [ level.squad[ "ALLY_ALPHA" ], level.player ];
		while ( IsAlive( self ) )
		{
			enemy = get_closest_living( self.origin, aEnemies );
			self.favoriteenemy = enemy;
			wait 0.2;
		}
	}	
	else if ( msg == "ps_baker_at_final_kill" )
	{
		// If this is the first message that has gotten through, it means the player didn't engage in any way
		// Baker will run through his paces and execute the guards via pistol
		self stop_magic_bullet_shield();
		self.allowdeath = false;
		self.noragdoll	= true;

		level.guard_breakarea_01 thread maps\factory_audio::stealth_kill_table_right_sfx();
		level.guard_breakarea_02 thread maps\factory_audio::stealth_kill_table_left_sfx();
		node anim_single( actors, "rest_area_kills" );
		chair thread do_chair_collision( chair_col );
		self maps\factory_anim::kill_no_react();
	}
}

do_chair_collision( chair_col )
{
	self endon( "done_with_collision" );
	
	while ( 1 )
	{
		// Leave things without collision until the player is safely out of the way.  Then teleport the collision to the proper point
		if ( !players_within_distance( 32, self.origin ) )
		{
			chair_col LinkTo( self, "tag_chair_collision", ( 0,0, 0 ), self.angles );
			chair_col Solid();
			break;
		}
		
		wait 0.1;
	}
	
	self notify( "done_with_collision" );
}

ps_guard_window_01_think()
{
	self endon( "death" );

	self ps_guard_standard_settings();
	
	self set_generic_run_anim( "walk_gun_unwary" );
	self set_generic_idle_anim( "patrol_idle_stretch" );
	
	flag_wait_any( "ps_bravo_second_pos_ready", "ps_alpha_second_pos_ready", "ps_charlie_second_pos_ready" );
	
	self.goalradius = 8;
	node			= GetNode( "ps_guard_window_01_idle", "script_noteworthy" );
	node anim_reach_solo( self, "dufflebag_casual_idle" );
//	self SetGoalNode( node );
//	self waittill( "goal" );
	
	self.animname = "enemy";
	self.deathanim = %factory_power_stealth_console_death;
	
	node thread anim_loop_solo( self, "dufflebag_casual_idle" );
	
	self waittill( "damage" );
	
	flag_set( "guard_window_01_dead" );
}

ps_guard_window_02_think()
{
	self endon( "death" );
	self.goalradius = 8;
	self ps_guard_standard_settings();
	
	flag_wait_any( "guard_window_01_dead", "start_break_area_kill" );
}	
	
monitor_player_distance()
{
	while ( IsAlive( self ) )
	{
		d = Distance( level.player.origin, self.origin );
		
		if ( d > 100 )
			continue;
		else
		{
			// Give the player a chance to duck back behind cover
			wait 3.0; // Decreases re-check time the closer the player is
			
			self StopAnimScripted();
			self.ignoreall	= false;
			self.see_player = true;
			
			flag_set( "ps_final_kill_made" );
			
			break;		
		}
		
		wait 0.4;
	}
}

ps_guard_standard_settings( enable_patrol_anims )
{
	self.goalradius = 8;
	self.allowdeath = true;
	self.animname = "enemy";
	self.health = 1;
	self.ignoreall = true;
	
	if ( IsDefined( enable_patrol_anims ) )
	{
		self.patrol_walk = [ "walk_gun_unwary", "patrol_bored_patrolwalk", "patrol_bored_patrolwalk_twitch" ];
		self.patrol_idle = [ "patrol_idle_stretch", "patrol_idle_smoke", "patrol_idle_checkphone" ];
	
		self set_generic_run_anim_array( random( self.patrol_walk ) );
		self set_generic_idle_anim( random( self.patrol_idle ) );
	}
}

factory_stealth_settings()
{
	factory_hidden			   = [];
	factory_hidden[ "prone"	 ] = 70; //70
	factory_hidden[ "crouch" ] = 350;//600 450
	factory_hidden[ "stand"	 ] = 512;//1024
		
	factory_spotted				= [];
	factory_spotted[ "prone"  ] = 512; //512;
	factory_spotted[ "crouch" ] = 3000;//5000;
	factory_spotted[ "stand"  ] = 4000;//8000;
	
	maps\_stealth_utility::stealth_detect_ranges_set( factory_hidden, factory_spotted );

	array				  	= [];
	array[ "player_dist" ] 	= 750;//1500;// this is the max distance a player can be to a corpse
	array[ "sight_dist" ] 		= 750;//1500;// this is how far they can see to see a corpse
	array[ "detect_dist" ] 	= 128;//256;// this is at what distance they automatically see a corpse
	array[ "found_dist" ] 	= 96; //96;// this is at what distance they actually find a corpse
	array[ "found_dog_dist" ]	= 50; //50;// this is at what distance they actually find a corpse

	maps\_stealth_utility::stealth_corpse_ranges_custom( array );
}

powerstealth_enc()
{
	thread ps_begin();
	thread ps_first_wave();
	thread ps_second_wave();
	thread ps_final_wave();
	
	flag_wait( "powerstealth_midpoint" );
	
	flag_wait( "powerstealth_end" );
	
	foreach ( ally in level.squad )
	{
//		ally.dontavoidplayer = true;
		ally.script_pushable = false;
	}
	
	flag_clear( "_stealth_spotted" );	
}

ps_begin()
{
	level endon( "ps_second_wave_start" ); // If player rushes this, just break out and get moving

	foreach ( ally in level.squad )
	{
		ally notify( "stop_adjust_movement_speed" );
		ally.script_pushable = false;
		ally disable_pain();
	}
	
	level.ai_friendlyFireBlockDuration = GetDvarFloat( "ai_friendlyFireBlockDuration" );
	SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );
	
	level.squad[ "ALLY_ALPHA" ]thread alpha_ps_animation(  );
	level.squad[ "ALLY_BRAVO" ]thread bravo_ps_movement (  );
	
	flag_wait( "entered_conveyor" );
	
	flag_wait( "ps_begin" );
	
	//Merrick: All right, multiple routes - split up - sweep and clear
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_allrightmultipleroutes" );
	
	thread maps\factory_audio::audio_factory_reveal_mix( "three" );
	
	wait 0.1;

	//Baker: Go.
	level thread smart_radio_dialogue( "factory_bkr_go" );	
	
	flag_set( "powerstealth_ready" );
	
	maps\factory_util::safe_trigger_by_targetname( "sca_powerstealth_start" );

	wait 1.2;

	// Remove player barrier
	barrier = GetEnt( "ps_player_barrier", "script_noteworthy" );
	barrier Delete();
	
	foreach ( guy in level.squad )
		guy PushPlayer( false );

	wait 1.2; // Waits for bravo and charlie to get going so they can stay ahead

	level.squad[ "ALLY_ALPHA" ] thread alpha_ps_start_settings();

	flag_wait( "exited_conveyor" );
	
	thread maps\_weather::rainNone( 8 );
	thread ps_end();
}

alpha_ps_animation()
{
	node = GetEnt( "ps_begin_alpha", "script_noteworthy" );
	node anim_reach_solo( self, "factory_power_stealth_ally_intro" );
	node anim_first_frame_solo( self, "factory_power_stealth_ally_intro" );
	
	flag_wait( "entered_conveyor" );
	
	node anim_single_solo( self, "factory_power_stealth_ally_intro" );
	node thread anim_loop_solo( self, "factory_power_stealth_ally_intro_loop", "stop_loop" );

	flag_wait( "ps_begin" );
	
	// HACK: temp fix to keep animation relative to dialogue
//	anim_set_rate_single( level.squad[ "ALLY_ALPHA" ], "factory_power_stealth_ally_intro_talk", 0.50 );
	
	delayThread( 0.1, ::anim_set_rate_single, self, "factory_power_stealth_ally_intro_talk", 0.50 );
	
	node notify( "stop_loop" );
	node anim_single_solo( self, "factory_power_stealth_ally_intro_talk" );
	node thread anim_loop_solo( self, "factory_power_stealth_ally_exit_loop", "stop_loop" );
	
	flag_wait( "powerstealth_ready" );
	
	wait 1.5;
	
	node notify( "stop_loop" );
	node StopAnimScripted();
	node anim_single_solo( self, "factory_power_stealth_ally_intro_exit" );
}

alpha_ps_start_settings()
{
	self enable_ai_color_dontmove();
	self SetGoalNode( GetNode( "ps_first_wave_alpha_node", "script_noteworthy" ) );
	self disable_pain();
	self PushPlayer( true );
	self disable_bulletwhizbyreaction();
	self.ignoresuppression			 = true;
	self.IgnoreRandomBulletDamage	 = true;
	self.disableFriendlyFireReaction = true;
	self.disablePlayerADSLOSCheck	 = true;
}

bravo_ps_movement()
{
	self enable_cqbwalk();
	
	flag_wait( "powerstealth_ready" );
	
	self disable_cqbwalk();
	self.moveplaybackrate = 1.1;
	
	flag_wait( "powerstealth_split" );
	
	self.moveplaybackrate = 1.0;
}

ps_first_wave()
{
	level endon( "railgun_reveal_setup" );
	
	enemies_left = get_ai_group_count( "ps_first_wave" );
//	thread wait_for_player_to_shoot( "ps_first_wave", "ps_first_kills_done", enemies_left - 1 );
	thread ps_first_wave_dialogue();
	
	level.squad[ "ALLY_ALPHA" ] thread wait_for_alpha_arrival();

	thread maps\factory_util::check_trigger_flagset( "sca_ps_low_path_start" ); // Enabling checks on the trigger leading down the staircase to the low path
	
	flag_wait( "exited_conveyor" );
		
	//Baker: Eyes open – keep moving…
	thread smart_radio_dialogue( "factory_bkr_keepmoving" );
	
	if ( IsDefined( GetEnt( "sca_ps_first_kills_done", "targetname" ) ) )
		maps\factory_util::safe_trigger_by_targetname( "sca_ps_first_kills_done" );	
}

wait_for_alpha_arrival()
{
	node = GetNode( "ps_first_wave_alpha_node", "script_noteworthy" );
	
	self waittill_entity_in_range( node, 200 );
	
	flag_set( "ps_first_wave_in_position" );
}

ps_first_wave_dialogue()
{
	level endon( "ps_first_kills_done" );
	
	flag_wait( "ps_first_wave_in_position" );
	
	wait 0.1;
	
//	smart_radio_dialogue( "factory_bkr_dropem" );
	
	flag_set( "ps_first_kills_done" );
}

/*
wait_for_player_to_shoot( aigroup, flag_to_notify, aigroupcount_to_wait_for )
{
	level endon( flag_to_notify );
	
	waittill_aigroupcount( aigroup, aigroupcount_to_wait_for );
	level notify( flag_to_notify );
}

*/


ps_first_kill_progression()
{
	level endon( "ps_second_wave_start" );
	
	kill_count = 0;
	
	foreach ( ally in level.squad )
	{
		if ( IsAlive( ally.favoriteenemy ) )
		{
			ally cqb_aim( ally.favoriteenemy );
			wait 0.1;
			MagicBullet( ally.weapon, ally GetTagOrigin( "tag_flash" ), ally.favoriteenemy GetShootAtPos() );
			ally.favoriteenemy Kill( ally.origin, ally );
			kill_count = kill_count + 1;
		}
	}
	
	// Check to see if the player killed any guards
	if ( kill_count > 2 )
	{
		//Rogers: That's a kill..
		smart_radio_dialogue( "factory_rgs_thatsakill" );
		wait 0.1;
	}
	
	flag_set( "ps_first_kills_done" );
}

ps_second_wave()
{
	level.squad[ "ALLY_ALPHA" ]thread ps_second_wave_alpha();
	level.squad[ "ALLY_BRAVO" ]thread ps_second_wave_bravo();
	level.squad[ "ALLY_CHARLIE" ]thread ps_second_wave_charlie();
	
	flag_wait( "ps_second_wave_start" );

	flag_set( "ps_second_wave_dialogue_done" );
	
	maps\factory_util::safe_trigger_by_targetname( "sca_ps_bravo_second_position" );
	
//	thread wait_for_player_to_shoot( "ps_second_wave", "ps_second_kill_made", 2 );
	
	flag_wait( "ps_charlie_second_pos_ready" );
	
	flag_set( "ps_second_kills_done" );
		
	maps\factory_util::safe_trigger_by_targetname( "sca_ps_second_kills_done" );		
}

ps_second_wave_alpha()
{
	level endon( "railgun_reveal_setup" );
		
	flag_wait( "powerstealth_split" );
	
	// If the player is with us, play the anims to tell them to hold up.  Otherwise, simply send Alpha to his cover position
	if ( !flag( "guard_tunnel_dead" ) )
		self tunnel_first_position();
	else
	{
		node = GetNode( "baker_first_position_node", "script_noteworthy" );
		self SetGoalNode( node );
	}
	
	// Dialogue for the break area guys up ahead.  Kicking them off early
	thread break_area_dialogue( level.guard_breakarea_01, level.guard_breakarea_02 );
	
	// If the player is with us and the guard is still not dead, continue with the scene, moving Alpha to the other side of the hall
	if ( !flag( "guard_tunnel_dead" ) )
		self tunnel_second_position();

	// Check to see that the guard is still alive and that the player is with us before bothering with instructions on the kill	
	vol = GetEnt( "vol_ps_with_baker", "targetname" );
	if ( flag( "ps_player_with_alpha_second" ) && IsAlive( level.guard_tunnel ) && level.player IsTouching( vol ) )
	{
		self tunnel_melee_scene();
	}
	else
	{
		// Player isn't with us, so Alpha just pops out into a shooting position
		// Alpha sets up to shoot the enemy if nothing else happens
		node = GetNode( "alpha_quick_kill", "script_noteworthy" );
		
		// Move on to whichever node is the appropriate one
		self.goalradius = 8;
		self SetGoalNode( node );
		self waittill( "goal" );
	}
	
	// If the player hasn't killed this guard, Alpha does
	if ( IsAlive( level.guard_tunnel ) )
	{
//		level.guard_tunnel.ignoreall = false;
		self ps_second_wave_alpha_execute( level.guard_tunnel );
	}
	
	// Reset Baker to normal
	self SetLookAtEntity();
	
	// Push Keegan forward
//	maps\factory_util::safe_trigger_by_targetname( "sca_ps_bravo_second_position" );
	
	// Continue on to next engagement
	self ps_final_wave_alpha();
}

tunnel_first_position()
{
	level endon( "ps_second_kill_made" );
	
	self.goalradius = 8;
	first_node		= GetNode( "baker_first_position_node", "script_noteworthy" );
	first_node anim_reach_solo( self, "factory_power_stealth_lower_hallway_enter_ally" );
	
	if ( flag( "ps_player_with_alpha_second" ) ) // Check to see if player is with us before bothering with animating
		first_node anim_single_solo( self, "factory_power_stealth_lower_hallway_enter_ally" );
	
//	self SetGoalPos( self.origin );
//	self waittill( "goal" );  // Wait to make sure Baker gets into first position one way or another
}

tunnel_second_position()
{
	level endon( "guard_tunnel_dead" );
	self endon( "guard_tunnel_alerted" );
	
	// Baker crosses to a better position
	self.goalradius = 8;
	node			= GetNode( "baker_first_position_node", "script_noteworthy" );
	second_node		= GetNode( "baker_second_position", "script_noteworthy" );
	
	d	= Distance( level.player.origin, second_node.origin );
	vol = GetEnt( "vol_ps_with_baker", "targetname" );

	level.guard_tunnel notify( "baker_in_position" );
	
	self thread tunnel_interrupt();
	
	if ( d > 80 && level.player IsTouching( vol ) )
	{
		node anim_single_solo( self, "factory_power_stealth_lower_hallway_cross_ally" );
		
		second_node = GetNode( "baker_second_position", "script_noteworthy" );
		self SetGoalNode( second_node );
	}
	else
	{
		node = GetNode( "baker_first_position_node", "script_noteworthy" );
		
		self SetGoalNode( node );
//		self waittill( "goal" );
	}
}

tunnel_interrupt()
{
	level endon( "guard_tunnel_dead" );
	
	flag_wait( "guard_tunnel_alerted" );
	
	self StopAnimScripted();
	node = GetNode( "baker_second_position", "script_noteworthy" );
	self SetGoalNode( node );
}

tunnel_melee_scene()
{
//	level endon( "ps_second_kill_made" );
	self endon( "guard_tunnel_alerted" );
	level endon( "guard_tunnel_dead" );
	
//	self thread handsignal( "enemy" );
	self SetLookAtEntity( level.player );
	wait 0.5;	
//	thread add_dialogue_line( "BAKER", "He's coming to you...get ready...", "blue" );
	self SetLookAtEntity( level.guard_tunnel );
//	wait 6.0;
	self waittill( "second_kill_ready" );
//	thread add_dialogue_line( "BAKER", "Take him!", "blue" );
	wait 0.5;

//	level.player display_hint( "neck_stab_hint" ); // TODO: reenable this if we ever decide to add a unique melee kill here

	wait 1.0;
}

ps_second_wave_alpha_execute( guard )
{
	level endon( "railgun_reveal_setup" );
	
	guard.allowdeath = true;
	guard.noragdoll	 = false;
	
	if ( IsAlive( guard ) )
	{
		self.favoriteenemy = guard;
		self disable_surprise();
		self.no_pistol_switch = true;

		self.ignoreall = false;
		
		guard waittill( "death" );
		self.ignoreall		  = true;
		self.no_pistol_switch = false;
//		MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), guard GetShootAtPos() );
//		guard kill( self.origin, self );
		
		//Merrick: Another.
		thread smart_radio_dialogue( "factory_mrk_another" );
	}
}

ps_second_wave_bravo()
{
	level endon( "railgun_reveal_setup" );
	
	flag_wait_any( "ps_bravo_second_pos_ready", "guard_tunnel_dead" );

	// Pushing the other two paths forward	
	flag_set( "ps_charlie_second_pos_ready" );
	flag_set( "ps_alpha_second_pos_ready" );
	
	flag_wait_any( "ps_second_wave_start", "guard_tunnel_dead" );
	
	wait 2.0; // Giving Hesh path some time to catch up
	
	node = GetEnt( "ps_bravo_office_approach", "script_noteworthy" );
	
	level thread bravo_office_lights();
	self bravo_sneak( node );
	
	flag_wait_any( "ps_final_kill_bravo_ready", "ps_alert_chair_guard", "start_break_area_kill" ); // Waiting either for player to get into position or for other paths to progress far enough 
	
	// Break out of the loop
	self StopAnimScripted();
	node notify( "stop_loop" );
	
	// Keegan kills the guy at the window
	if ( IsAlive( level.guard_window_01 ) )
	{
		self ps_second_wave_bravo_execute( level.guard_window_01, node );
		
		// Keegan berates the player for inaction if player is on this path
//		if ( flag( "ps_bravo_second_pos_ready" ) )
//			thread add_dialogue_line( "KEEGAN", "Rook, are you paying attention?", "red" );
	}
	else
	{
		// If first guard is already dead, we send Keegan on to his idle node to wait for the second kill
		self SetGoalNode( GetNode( "bravo_final_kill_start", "script_noteworthy" ) );
	}
	
	self ps_final_wave_bravo();
}

bravo_office_lights()
{
	// Turn on the light in the office
	light_list = GetEntArray( "office_light_right_path", "script_noteworthy" );	
	foreach ( light in light_list )
	{
		thread bravo_office_lights_flicker( light );
	}
}

bravo_office_lights_flicker( light )
{
	intensity = 0.5;
	if ( IsDefined( light ) )
	{
		// Let's flicker the lights a little first
		for ( i = 0; i <= 3; i++ )
		{
			light SetLightIntensity( 0.5 );
			wait 0.02;
			light SetLightIntensity( 0 );
			wait RandomFloatRange( 0.01, 0.04 );
		}
		
		// Then bump up the intensity little by little until we're at a nice bright value
		targetIntensity = 0.9;
		if (is_gen4())
			targetIntensity = 1.9;

		while ( intensity <= targetIntensity )
		{
			light SetLightIntensity( intensity );
			wait 0.06;
			intensity = intensity + 0.25;
		}
	}
}

bravo_sneak( node )
{
	level endon( "keegan_killed_window_guard" );
	level.guard_window_01 endon( "death" );
	
	node anim_reach_solo( self, "keegan_office_kill_enter" );
	
	self thread bravo_sneak_dialogue();

	node anim_single_solo( self, "keegan_office_kill_enter" );
	node thread anim_loop_solo( self, "keegan_office_kill_loop", "stop_loop" );
}

bravo_sneak_dialogue()
{
	level.guard_window_01 endon( "death" );
	
	vol = GetEnt( "vol_ps_with_keegan", "targetname" );
	
	// Check to see if player is with us, otherwise go through the paces
	if ( level.player IsTouching( vol ) && IsAlive( level.guard_window_01 ) )
	{
		//Keegan: Get down!  Wait for a clear shot on this guy
		self thread smart_dialogue( "factory_kgn_getdownwaitfor" );
	
		wait 3.5; // Give player a window of opportunity to act

		//Keegan: Take him!
		self thread smart_dialogue( "factory_kgn_takehim" );
	}	
}

bravo_shoot_office_guard( guy )
{
	if ( IsAlive( level.guard_window_01 ) )
	{
		guy cqb_aim( level.guard_window_01 );
		wait 0.2;
		MagicBullet( guy.weapon, guy GetTagOrigin( "tag_flash" ), level.guard_window_01 GetShootAtPos() );
	}
}

ps_second_wave_bravo_execute( guard, node )
{
	// Simple shot for Keegan to make
	if ( IsAlive( guard ) )
	{
		node anim_single_solo( self, "keegan_office_kill_shoot" );
		
		self thread anim_generic_loop( self, "exposed_crouch_idle_twitch_v2", "stop_loop" );
	}
	else
	{
		// Player already shot guard so just continue on

		//Keegan: Good kill.
		self thread smart_dialogue( "factory_kgn_goodkill" );
		node anim_single_solo( self, "keegan_office_kill_exit" );
	}
	
	flag_set( "keegan_killed_window_guard" );
}

ps_second_wave_charlie()
{
	level endon( "railgun_reveal_setup" );
	
	flag_wait( "powerstealth_split" ); // ps_second_wave_start
	
	thread handle_sleeping_guy( level.sleeping_guard ); // Setting up the next kill early
//	self thread ps_second_wave_breakout(); // Monitors the situation and breaks out Rogers if enemy is alerted
	
	self.goalradius = 64;
	
//	self waittill( "goal" );
	
	node = GetEnt( "ps_corner_kill_charlie_org", "targetname" );
	node anim_reach_solo( self, "factory_power_stealth_ally_corner_entrance" );
	node anim_single_solo( self, "factory_power_stealth_ally_corner_entrance" );
	node thread anim_loop_solo( self, "factory_power_stealth_ally_corner_idle", "stop_loop" );
	
	self enable_cqbwalk();
	
	if ( level.player IsTouching( GetEnt( "vol_ps_top_level", "script_noteworthy" ) ) )
	{
		flag_wait_or_timeout( "ps_charlie_second_enemy_alerted", 7.0 );
	}
	
	node notify( "stop_loop" );
	node StopAnimScripted();
	node anim_single_solo( self, "factory_power_stealth_ally_corner_exit" );
	
	if ( IsAlive( level.guard_platform ) )
	{
		self ps_second_wave_charlie_execute( level.guard_platform );
	}
	
	flag_set( "ps_second_kill_made" );

	self thread ps_final_wave_charlie();
}

ps_second_wave_charlie_execute( guard )
{
	level endon( "railgun_reveal_setup" );
//	level endon( "ps_rogers_first_kill_done" );
	
	self.goalradius = 200;
	kill_node = GetNode( "charlie_quick_kill", "script_noteworthy" );
	self SetGoalNode( kill_node );
	self waittill( "goal" );
	
	// Double checking status of guard
	if ( IsAlive( guard ) )
	{
		self cqb_aim( guard );
		wait 0.2;
		MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), guard GetShootAtPos() );
		guard Kill();
		
		if ( !( level.player IsTouching( GetEnt( "vol_ps_top_level", "script_noteworthy" ) ) ) )
			//Hesh: Got one.
			thread smart_radio_dialogue( "factory_hsh_gotone" );
	}
}

ps_second_wave_breakout()
{
	level endon( "ps_rogers_first_kill_done" );
	
	level.guard_platform waittill( "ps_charlie_second_enemy_alerted" );
	
	// Notifies
	
	// Wake Rogers up and set him to kill
	self StopAnimScripted();
	self.goalradius = 64;
	self SetGoalPos( level.guard_platform.origin );
//	self waittill( "goal" );
	self.ignoreall	   = false;
	self.favoriteenemy = level.guard_platform;
	
	level.guard_platform waittill( "death" );
	
	//Hesh: Got one.
	thread smart_radio_dialogue( "factory_hsh_gotone" );
	
	self.ignoreall = true;
	self.favoriteenemy = undefined;
}

ps_final_wave()
{
	flag_wait( "ps_second_kills_done" );
	
	foreach ( guy in level.squad )
	{
		guy PushPlayer( false ); // Shouldn't need this anymore
	}
	
	flag_wait_all( "powerstealth_end", "ps_break_area_done" );
	
	flag_set( "ps_final_kills_done" );
	
	foreach ( guy in level.squad )
	{
		guy enable_ai_color_dontmove();
	}
	
	maps\factory_util::safe_trigger_by_targetname( "sca_ps_final_kills_done" );	
}

ps_final_wave_alpha()
{
	level endon( "railgun_reveal_setup" );
	
	// Check to see if player is on Rogers' path and slow things down a tad
	vol1 = GetEnt( "vol_ps_top_level", "script_noteworthy" );
	vol2 = GetEnt( "vol_ps_rogers_wait_for_melee_kill", "script_noteworthy" );
	
	if ( level.player IsTouching( vol1 ) || level.player IsTouching( vol2 ) )
		flag_wait_or_timeout( "ps_foreman_office_entry", 12.0 );
	
	flag_set( "start_break_area_kill" );
	
	self ps_final_wave_alpha_execution_scene();
	
	if ( !flag( "ps_break_area_triggered" ) )
		self ps_final_wave_alpha_execute();
	else
		self ps_final_wave_alpha_breakout();
	
	node = GetNode( "ALLY_ALPHA_weapon_security_node", "targetname" );
	self SetGoalNode( node );
	self PushPlayer( true ); // Cramped quarters, don't let the player keep him standing in place
	self enable_ai_color_dontmove();
	self waittill( "goal" );
	
	// Set Alpha back to defaults
	self PushPlayer( false );
	self enable_bulletwhizbyreaction();
	self.ignoresuppression = false;
	self.IgnoreRandomBulletDamage = false;
	self.disableFriendlyFireReaction = false;
	self.disablePlayerADSLOSCheck = false;
	SetSavedDvar( "ai_friendlyFireBlockDuration", level.ai_friendlyFireBlockDuration );
	
	//Merrick: Bottom clear.
	thread smart_radio_dialogue( "factory_mrk_bottomclear" );
	
	flag_set( "ps_alpha_done" );
}

ps_final_wave_alpha_execution_scene()
{
	level endon( "ps_break_area_triggered" );
	
	self.goalradius = 8;
	node			= GetEnt( "alpha_final_kill_origin", "script_noteworthy" );
	node anim_reach_solo( self, "factory_power_stealth_breakarea_ally_shoot" );
	node thread anim_single_solo( self, "factory_power_stealth_breakarea_ally_shoot" );
}

break_area_dialogue( guard1, guard2 )
{
	level endon( "ps_break_area_triggered" );
	level endon( "break_area_first_dead" );
	guard1 endon( "death" );
	guard2 endon( "death" );

	//Federation Soldier 1: ..look, I don't care what Carlos says, that thing isn't going to be ready anytime soon…
	guard1 dialogue_queue( "factory_sp1_miranomeimporta" );
	
	wait 0.5;

	//Federation Soldier 2: But we've already finished the firing test.  It just needs to get into orbit.
	guard2 dialogue_queue( "factory_sp2_peroyaterminaronlas" );
	
	wait 0.5;
	
	//Federation Soldier 1: And when's that supposed to happen?
	guard1 dialogue_queue( "factory_sp1_ycuandosesupone" );
	
	wait 0.5;
	
	//Federation Soldier 2: Roberto said they were prepping the rocket outside of Mexico City…
	guard2 dialogue_queue( "factory_sp2_elseorventuradijo" );
	
	wait 0.5;
	
	//Federation Soldier 1: Well I hope they do something soon.  I'm tired of sitting around here.  I can't stand all this noise.
	guard1 dialogue_queue( "factory_sp1_puesesperoquelo" );
	
	wait 0.5;
	
	//Federation Soldier 2: Me neither!
	guard2 dialogue_queue( "factory_sp2_yoandoigual" );
	
	wait 0.8;
	
	//Federation Soldier 1: Hey, what time is it?
	guard1 dialogue_queue( "factory_sp1_quhoratienes" );
	
	wait 0.5;
	
	//Federation Soldier 2: I've got 2:30.
	guard2 dialogue_queue( "factory_sp2_dosymedia" );
	
	wait 0.5;
	
	//Federation Soldier 1: Dammit, we've got another 5 hours before our watch is done.
	guard1 dialogue_queue( "factory_sp1_putamadrenosquedan" );
}

ps_alpha_pistol_switch( guy )
{
	pistol = Spawn( "script_model", ( 0, 0, 0 ) );
	pistol SetModel( "weapon_usp45_sp_iw5" );
	pistol LinkTo( guy, "tag_inhand", ( 10, 0, 2 ), ( 0, 0, 0 ) );
	
	level.pistol = pistol;
	
	wait 1.7;
	
	pistol Delete();
}

ps_alpha_pistol_fire( guy )
{
	if ( !flag( "break_area_first_dead" ) )
	{
		MagicBullet( "usp_silencer", level.pistol GetTagOrigin( "tag_flash" ), level.break_area_guard_array[ 0 ] GetShootAtPos() );
		
		flag_set( "break_area_first_dead" );
	}
	else
	{
		MagicBullet( "usp_silencer", level.pistol GetTagOrigin( "tag_flash" ), level.break_area_guard_array[ 1 ] GetShootAtPos() );
	}
}

ps_final_wave_alpha_breakout()
{
	level endon( "ps_break_area_done" );
	
	self StopAnimScripted();
	
	node = GetNode( "alpha_final_kill_node", "script_noteworthy" );
	self SetGoalNode( node );
	self waittill( "goal" );
	self.ignoreall = false;
	
	enemies = [ level.guard_breakarea_01, level.guard_breakarea_02 ];
	
	foreach ( guard in enemies )
	{
		if ( IsAlive( guard ) )
		{
			self.favoriteenemy = guard;
			guard waittill( "death" );
		}
	}
	
	wait 0.5;
	
	//Merrick : Break's over.
	self thread smart_dialogue( "factory_mrk_breaksover" );
	
	self.ignoreall = true;
}

ps_final_wave_alpha_execute()
{
	level endon( "railgun_reveal_setup" );
//	level endon( "ps_break_area_triggered" );
	
	guard						 = get_living_ai( "ps_break_area_a", "script_noteworthy" );
	guard2						 = get_living_ai( "ps_break_area_b", "script_noteworthy" );
	level.break_area_guard_array = [ guard, guard2 ];

	wait 0.8;

	vol = GetEnt( "vol_ps_baker_final_kill", "script_noteworthy" );
		
	// Only play dialogue if the player is with us on this path and both guards have not been engaged
	if ( level.player IsTouching( vol ) && !flag( "ps_break_area_triggered" ) )
	{
		//Merrick : Break's over.
		self thread smart_dialogue( "factory_mrk_breaksover" );
		wait 0.3;
	}
	
	wait 0.65;
	
	flag_set( "ps_baker_at_final_kill" );
	
	foreach ( guard in level.break_area_guard_array )
	{
		if ( IsDefined( guard ) )
		{
			self cqb_aim( guard );
			MagicBullet( "usp_silencer", self GetTagOrigin( "tag_inhand" ), guard GetShootAtPos() );
		}
		wait 0.3;
	}
	
	self enable_pain();
	
	flag_set( "ps_break_area_done" );
}

ps_final_wave_bravo()
{
	level endon( "railgun_reveal_setup" );
	
//	flag_wait( "start_break_area_kill" );
	
	self ps_final_wave_bravo_execute( level.guard_window_01 );
	
	self enable_ai_color_dontmove();
	self thread ps_bravo_at_door();
	
	//Keegan: Right's clear.
	thread smart_radio_dialogue( "factory_kgn_rightclear" );
	
	flag_set( "ps_bravo_done" );
}

// Set a flag when bravo arrives at the door - Needed to smooth out the door anim
ps_bravo_at_door()
{
	node = GetNode( "ALLY_BRAVO_weapon_security_node", "targetname" );
	self.goalradius = 8;
	self SetGoalNode( node );
	self waittill( "goal" );
	flag_set( "presat_bravo_in_position" );
}

ps_final_wave_bravo_execute( guard )
{
	level endon( "railgun_reveal_setup" );

	flag_wait_any( "guard_window_01_dead", "ps_break_area_triggered", "keegan_killed_window_guard" );
	
	node = GetEnt( "ps_guard_window_02_death", "script_noteworthy" );
	
	if ( IsAlive( level.guard_window_02 ) )
	{
		level.guard_window_02 thread railing_tumble_scene();
		node anim_reach_solo( level.guard_window_02, "keegan_top_stairway_kill" );
	}
	
	if ( IsAlive( level.guard_window_02 ) )
	{
		node thread anim_single_solo( level.guard_window_02, "keegan_top_stairway_kill" );
		
		// We want him to animate, not ragdolll, right now
		level.guard_window_02.noragdoll	 = true;
		level.guard_window_02.allowdeath = false;
		
		self cqb_aim( level.guard_window_02 );
		self.favoriteenemy = level.guard_window_02;

		wait 2.2;		
		
		for ( i = 0; i < 3; i++ )
		{
			MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), level.guard_window_02 GetShootAtPos() );	
			wait RandomFloatRange( 0.05, 0.3 );
		}
		
		// HACK: Need to activate the proper notetrack here
		wait 1.7;
		level.guard_window_02 maps\factory_anim::kill_no_react();
		
		//Keegan: EKIA.
		self thread powerstealth_dialogue_call( 200, "factory_kgn_ekia" );
	}

	self anim_stopanimscripted();
}

railing_tumble_scene()
{
	level.guard_window_02 endon( "death" );
	
	level.guard_window_02.noragdoll = true;
	
	wait 1.5;
	thread custom_door_open( "door_ps_right_path_org", 100, 0.3 );

	level.guard_window_02 thread maps\factory_audio::stealth_kill_railing_sfx();
	flag_set( "railing_tumble_kill_ready" );
}

ps_final_wave_charlie()
{
	level endon( "presat_started" );
	
	self enable_ai_color_dontmove();
	
	self thread throat_stab_abort_monitor();
	
	if ( !flag( "throat_stab" ) )
		self charlie_signal();
	
	// Wait and see if player is advancing on the sleeper
	vol = GetEnt( "vol_ps_rogers_wait_for_melee_kill", "script_noteworthy" );
	if ( level.player IsTouching( vol ) && IsAlive( level.sleeping_guard ) )
	{
		wait 0.5;
		
		//Hesh: He's all yours, Adam.
		level.squad[ "ALLY_CHARLIE" ] thread smart_dialogue( "factory_hsh_hesallyoursadam" );
		
		// Give the player a chance to make the kill
		if ( Distance( level.player.origin, level.sleeping_guard.origin ) < 400 )
			wait 8.0;
	}
	else
	{
		// Player isnt' with us, but we need charlie to hold up on progression until the hallway guard is dealt with
		flag_wait( "guard_tunnel_dead" );
	}
	
	if ( !flag( "throat_stab" ) )
		self charlie_finish_office();
	else
	{
		if ( IsDefined( level.sleeping_guard ) )
		{
			self.ignoreall	   = false;
			self.favoriteenemy = level.sleeping_guard;
		
			level.sleeping_guard waittill( "death" );
		
			self.ignoreall = true;
		}
	}
	
	// Go ahead and move Charlie to a better exit position within the room, but only if player is with him
	if ( level.player IsTouching( GetEnt( "vol_ps_chair_office", "script_noteworthy" ) ) )
	{
		self.goalradius = 8;
		self enable_cqbwalk();
		node = GetNode( "charlie_post_office_idle", "script_noteworthy" );
		self SetGoalNode( node );
//		self waittill( "goal" );
	}
	
	self enable_ai_color_dontmove();
	self disable_cqbwalk();
	
	//Hesh: Top clear.
	smart_radio_dialogue( "factory_hsh_topclear" );

	self thread ps_charlie_at_door();
	
	flag_set( "ps_charlie_done" );
}

// Set a flag when charlie arrives at the door - Needed to smooth out the door anim
ps_charlie_at_door()
{
	node = GetNode( "ALLY_CHARLIE_weapon_security_node", "targetname" );
	self.goalradius = 8;
	self SetGoalNode( node );
	self waittill( "goal" );
	flag_set( "presat_charlie_in_position" );
}

throat_stab_abort_monitor()
{
	level.sleeping_guard endon( "death" );
	
	flag_wait( "throat_stab_sequence_aborted" );
	
	flag_set( "throat_stab" );
	
	if ( IsDefined( level.sleep_guard ) )
	{
		self.ignoreall	   = false;
		self.favoriteenemy = level.sleeping_guard;
		
		self.goalradius = 8;
		self SetGoalPos( level.sleeping_guard.origin );
		
		level.sleeping_guard waittill( "death" );
		
		self.ignoreall = true;
	}
}

charlie_signal()
{
	level endon( "presat_started" );
	level.sleeping_guard endon( "death" );
	level endon( "throat_stab" );
	
	self.goalradius = 8;
	node = GetNode( "charlie_final_kill_post", "script_noteworthy" );
	node anim_reach_and_approach_solo( self, "CornerStndR_alert_signal_enemy_spotted" );
//	self SetGoalNode( node );
	self disable_cqbwalk();
	self waittill( "goal" );

	self enable_cqbwalk();
	
	// Only play this anim if the player is in a good place for it
	vol = GetEnt( "vol_ps_rogers_signal_player", "script_noteworthy" );
	if ( level.player IsTouching( vol ) )
	{
		self anim_generic( self, "CornerStndR_alert_signal_enemy_spotted" );
	}
	
	self SetGoalNode( node );
	
	wait 0.5;
}

charlie_finish_office()
{
	level endon( "presat_started" );
	level.sleeping_guard endon( "death" );
	level endon( "throat_stab" );
	level endon( "throat_stab_sequence_aborted" );
	
	vol = GetEnt( "vol_ps_chair_office", "script_noteworthy" );
	
	if ( IsAlive( level.sleeping_guard ) && !( level.player IsTouching( vol ) ) )
	{
		self.goalradius = 300;
		self SetGoalNode( GetNode( "charlie_post_office_idle", "script_noteworthy" ) );
		wait 1.0;
	}
	
	if ( IsAlive( level.sleeping_guard ) )
	{
		self ps_final_wave_charlie_execute( level.sleeping_guard );
	}
}

ps_final_wave_charlie_execute( guard )
{
	level endon( "presat_started" );
//	level endon( "railgun_reveal_setup" );
	
	if ( IsAlive( guard ) && !IsDefined( level.player.in_stab_animation ) )
	{
		self cqb_aim( guard );
		wait 0.2;		
		self thread flash();
		self safe_magic_bullet( self GetTagOrigin( "tag_flash" ), guard GetShootAtPos() );	
		guard Kill();

		// Check to see if the player has joined the party
		if ( flag( "ps_foreman_office_entry" ) )
		{
			wait 0.8;
			
			//Hesh: C'mon, Adam, let's keep moving.
			level.squad[ "ALLY_CHARLIE" ] thread smart_dialogue( "factory_hsh_cmonadamletskeep" );
		}
	}
}

ps_end()
{
	flag_wait_any( "ps_alpha_done", "ps_bravo_done", "ps_charlie_done" );
	
	aTriggers = GetEntArray( "sca_ps_delete", "script_noteworthy" );
	
	foreach ( trig in aTriggers )
	{
		trig trigger_off();
	}
}

flash()
{
	PlayFXOnTag( getfx( "office_muzzle_flash" ), self, "tag_flash" );
}

setup_patrol()
{
	self endon( "death" );
	
	self.animname		  = "generic";
	self.disablearrivals  = true;
	self.disableexits	  = true;
	self.health			  = 1;
	self.moveplaybackrate = 1.4; // Trying to get a slightly faster stealth movement with this
	
	self.patrol_walk = [ "walk_gun_unwary"	  , "patrol_bored_patrolwalk", "patrol_bored_patrolwalk_twitch" ];
	self.patrol_idle = [ "patrol_idle_stretch", "patrol_idle_smoke"		 , "patrol_idle_checkphone" ];

	self set_generic_run_anim_array( random( self.patrol_walk ) );
	self set_generic_idle_anim( random( self.patrol_idle ) );
	
	self maps\_stealth_utility::stealth_default();
	
	if ( IsDefined( self.target ) )
	{
		self start_patrol( self.target );
	}
}

start_patrol( targetname, delay )
{
	if ( IsDefined( delay ) )
		wait delay;

	self thread maps\_patrol::patrol( targetname );
}

// Nags player until they get the lead out and move through the conveyor belt opening
nag_player_for_conveyor()
{
	self endon( "entered_conveyor" );
	
	// Set up array of possible nags to use
	nag = [];
	//Baker: Rook, let’s go!
	nag[ 0 ] = "factory_bkr_letsgo";
	//Baker: Through here.
	nag[ 1 ] = "factory_bkr_throughhere";
	//Baker: Rook, let’s go!
	nag[ 2 ] = "factory_bkr_letsgo";
	
	time_since_nag = 3.0;
	
	wait time_since_nag;
	
	while ( 1 )
	{
		level.squad[ "ALLY_ALPHA" ] radio_dialogue( random( nag ) );
		
		wait time_since_nag;
		time_since_nag = time_since_nag + 1.0;
	}
}

powerstealth_dialogue_call( dist, dialogue )
{
	if ( !players_within_distance( dist, self.origin ) )
	{
		smart_radio_dialogue( dialogue );
	}
}

// =====================================
// SLEEPER MELEE KILL
// =====================================

handle_sleeping_guy( guy )
{
	if ( !IsDefined( guy ) )
	{
		return;
	}
	
	guy.allowdeath	  = 1;
	guy.ignoreme	  = 1;
	guy.ignoreall	  = 1;
	guy.dontevershoot = 1;
	guy.health		  = 50;
	guy.animname	  = "generic";
//	guy gun_remove();
	guy set_battlechatter( false );
	guy.deathanim = %factory_power_stealth_opfor_console_death_shot;
	
	chair			= spawn_anim_model( "chair" );
	level.chair_col = GetEnt( "col_chair_rolling", "script_noteworthy" );
	level.chair_col LinkTo( chair, "tag_chair_collision", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	chair_col_setup();
	
//	chair thread knock_over_chair_default( guy );
	
	guy thread check_for_melee_stab( chair );
	guy thread anim_sleep( chair );
	guy thread wake_guy_up( chair );

	if ( IsAlive( guy ) )
	{
		guy waittill( "death" );
//		flag_set( "sleeping_guy_dead" );
	}
	
	if ( IsDefined( level.player.in_stab_animation ) )
	{
		level.player waittill( "stab_finished" );
	}
	else
	{
		chair thread maps\factory_audio::stealth_kill_console_sfx( guy );
		chair thread knock_over_chair( "sleeper_shot" );
	}
	clean_up_stab();	
}

ready_to_stab()
{
	level.player AllowMelee( false );
	level.player.ready_to_neck_stab = true;
	
	withinFOV = within_fov( self.origin, self.angles, level.player.origin, 280 );
	
	if ( !withinFOV )
		level.player display_hint( "neck_stab_hint" );
}

clean_up_stab()
{
	if ( IsDefined( level.player.ready_to_neck_stab ) && level.player.ready_to_neck_stab )
	{
		level.player.ready_to_neck_stab = undefined;
		level.player AllowMelee( true );
	}
}

check_for_melee_stab( chair )
{
	self endon( "death" );
	level.player endon( "death" );
	self endon( "guy_waking_up" );
	
	max_stab_distance_sq = 150 * 150;
	while ( true )
	{
		distance_from_player = DistanceSquared( level.player.origin, self.origin );
		angle_diff			 = abs( AngleClamp180( level.player.angles[ 1 ] - self.angles[ 1 ] ) );
		if ( angle_diff < 45 && distance_from_player < max_stab_distance_sq )
		{
			self ready_to_stab();
			
			if ( level.player MeleeButtonPressed() && IsAlive( self ) && !level.player IsMeleeing() && !level.player IsThrowingGrenade() )
			{
				self thread throat_stab_me( chair );
				return;
			}
		}
		else
		{
			clean_up_stab();
		}
		
		wait 0.05;
	}
}

throat_stab_me( chair )
{
	level.player.in_stab_animation = true;	
	
	thread maps\factory_audio::stealth_kill_throat_stab_sfx();
	
	// not using SetUpPlayerForAnimations as arbitrary waits in it
	//   can cause issues
	player_rig = player_start_stabbing();
	
	anim_org		= SpawnStruct();
	anim_org.origin = self.origin;
	anim_org.angles = self.angles;
	
	// player_rig = spawn_anim_model( "player_rig" );
	// player_rig Hide();
	
	flag_set( "throat_stab" );

	guys	  = [];
	guys[ 0 ] = player_rig;
	guys[ 1 ] = self;

	// move ents to first frame of anim
	node = GetEnt( "sleeping_guard_node", "script_noteworthy" );
	node anim_first_frame_solo( player_rig, "throat_stab" );

	// interpolate player to anim start
	blend_time = 0.4; // 0.3
	level.player PlayerLinkToBlend( player_rig, "tag_player", blend_time, 0.3, 0.08 );
	wait blend_time;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
	player_rig Show();
	//wait blend_time;

	if ( IsAlive( self ) )
	{
		// show knife
		player_rig Show();
		player_rig Attach( "Viewmodel_knife_iw6", "tag_weapon_right", true );
		
		// play anims
		chair thread knock_over_chair( "throat_stab" );
		node anim_single( guys, "throat_stab" );
		self maps\factory_anim::kill_no_react();
		//AssertEx( !IsAlive( self ), "victim not killed during animation." );
	
		// clean up
		player_rig Detach( "Viewmodel_knife_iw6", "tag_weapon_right", true );
		player_rig Hide();
	}

	level.player Unlink();
	player_rig Delete();	

	player_done_stabbing();
	
	level.player.in_stab_animation = undefined;
	level.player notify( "stab_finished" );
	
	//Hesh: Nice one, bro.
	level.squad[ "ALLY_CHARLIE" ] thread smart_dialogue( "factory_hsh_niceonebro" );
}

anim_sleep( chair )
{
	self endon( "death" );
	self endon( "guy_waking_up" );
	
	node = GetEnt( "sleeping_guard_node", "script_noteworthy" );
	node anim_first_frame_solo( chair, "sleep_enter" );
	
	flag_wait( "powerstealth_midpoint" ); // OLD VAL: start_final_rogers_kill
	
	node thread anim_single_solo( chair, "sleep_enter" );
	node anim_single_solo( self, "sleep_enter" );

	node thread anim_loop_solo( self, "sleep_idle", "stop_loop" );
}

wake_guy_up( chair )
{
	self endon( "death" );
//	level endon( "throat_stab" );

	self thread detect_player_proximity();	
	self wait_for_waking_event();
	
	// waking up, no throat stab allowed
	self notify( "guy_waking_up" );
	flag_set( "throat_stab_sequence_aborted" );
	
	self StopAnimScripted();
	clean_up_stab();

	self.deathanim = undefined; // Earlier than other settings since you can still catch him in mid react anim
	
	// wake guy up!
	org = GetEnt( "sleeping_guard_node", "script_noteworthy" );
	chair thread knock_over_chair( "sleep_react" );
	org anim_single_solo( self, "sleep_react" );
	self notify( "done_waking_up" );
	
	self disable_surprise();
	self.ignoreme	   = false;
	self.ignoreall	   = false;
	self.dontevershoot = undefined;
	self.goalradius	   = 8;
	self SetGoalPos( level.player.origin );
	self.health = 1;
	self thread set_battlechatter( true );
	self thread gun_recall();
}

detect_player_proximity()
{
	self endon( "death" );
	self endon( "guy_waking_up" );
	
	flag_wait( "ps_alert_chair_guard" );
	
	self notify( "guy_waking_up" );
}

// wait for something to wake you up
wait_for_waking_event()
{
	self endon( "death" );
	self endon( "flashbang" );
	self endon( "guy_waking_up" );
	
	flag_wait( "start_final_rogers_kill" );
	
//	self AddAIEventListener( "gunshot" );
	self AddAIEventListener( "bulletwhizby" );
	self AddAIEventListener( "explode" );
	self AddAIEventListener( "projectile_impact" );
	
	while ( true )
	{
		self waittill( "ai_event", event_type );
		
		if ( event_type == "gunshot" || event_type == "bulletwhizby" || event_type == "explode" )
			return;
	}
}

knock_over_chair( chair_anim )
{
	if ( !IsDefined( self.knocked_over ) )
	{
		self.knocked_over = true;
		org				  = GetEnt( "sleeping_guard_node", "script_noteworthy" );
		self thread maps\factory_audio::stealth_kill_console_chair_sfx();
		org anim_single_solo( self, chair_anim );
		
		self thread chair_col( chair_anim );
	}
}

chair_col( chair_anim )
{
	self endon( "done_with_collision" );

	while ( 1 )
	{
		if ( !players_within_distance( 64, self.origin ) )
		{
			chair = "";
			
			switch( chair_anim )
			{
				case "sleeper_shot":
					chair = "_shot";
					break;
				case "throat_stab":
					chair = "_stabbed";
					break;
				case "sleep_react":
					chair = "_react";
					break;
			}

			// Make the correct version of the chair collision active
			chair_col = GetEnt( "col_chair_rolling" + chair, "script_noteworthy" );
			chair_col Solid();
			
			// Get rid of moving collision
//			chair_col_animated = GetEnt( "col_chair_rolling", "script_noteworthy" );
//			chair_col_animated Unlink();
//			chair_col_animated Delete();
			
			level.chair_col Unlink();
			level.chair_col Delete();
			
			self.knocked_over = true;
			
			break;
		}
		
		wait 0.1;
	}
	
	self notify( "done_with_collision" );
}

chair_col_setup()
{
	chair_shot	  = GetEnt( "col_chair_rolling_shot", "script_noteworthy" );
	chair_stabbed = GetEnt( "col_chair_rolling_stabbed", "script_noteworthy" );
	chair_react	  = GetEnt( "col_chair_rolling_react", "script_noteworthy" );
	
	chair_shot NotSolid();
	chair_stabbed NotSolid();
	chair_react NotSolid();
}

knock_over_chair_default( guy )
{
	guy endon( "done_waking_up" );
	
	guy waittill( "damage", amount, attacker, direction_vec, point, type );
	
	self.knocked_over = false;
	self thread knock_over_chair( "sleeper_shot" );
}

custom_door_open( orgTargetname, rotAngle, rotTime, close, close_waittime )
{
	if ( !IsDefined( rotTime ) )
	    rotTime = 1;
	    
	door			 = GetEnt	  ( orgTargetname, "targetname" );
	door_attachments = GetEntArray( door.target	 , "targetname" );
	
	for ( i = 0; i < door_attachments.size; i++ )
	{
		door_attachments[ i ] LinkTo( door );
	}
	
	old_angles = door.angles;
	door RotateTo( door.angles + ( 0, rotAngle, 0 ), rotTime );
	
	// Connect paths in the doorway
	for ( i = 0; i < door_attachments.size; i++ )
	{
		if ( door_attachments[ i ].classname != "script_model" )
			door_attachments[ i ] ConnectPaths();
	}

	
	door waittill( "rotatedone" );
	
	if ( IsDefined( close ) )
	{
		if ( !IsDefined( close_waittime ) )
			close_waittime = 3.5;
			
		wait close_waittime;
		door RotateTo( old_angles, rotTime / 4 );

		// Disconnect the paths
		for ( i = 0; i < door_attachments.size; i++ )
		{
			if ( door_attachments[ i ].classname != "script_model" )
				door_attachments[ i ] DisconnectPaths();
		}
	}
}

train_cleanup()
{
	train_parts = GetEntArray( "fac_intro_trains", "script_noteworthy" );
	foreach ( train_part in train_parts )
	{
		if ( IsDefined( train_part ) )
		{
			train_part Delete();
		}
	}
}

//================================================================================================
//	UTIL
//================================================================================================
// Generic function to teleport squad members to start point origins and assign them an initial node to move to
//  SAMPLE KVPs:
//		On origin --> ALLY_BRAVO_powerstealth_teleport
//  		On node --> ALLY_BRAVO_powerstealth_node
teleport_squad( checkpoint_name, deltaecho )
{
	if ( !IsDefined( deltaecho ) )
	{
		squad_names = [ "ALLY_ALPHA", "ALLY_BRAVO", "ALLY_CHARLIE", "ALLY_DELTA", "ALLY_ECHO" ];
	}
	else
	{
		squad_names = [ "ALLY_ALPHA", "ALLY_BRAVO", "ALLY_CHARLIE" ];
	}
	
	for ( i = 0; i < squad_names.size; i++ )
	{
		maps\factory_util::actor_teleport( level.squad[ squad_names[ i ] ], squad_names[ i ] + "_" + checkpoint_name + "_teleport" );
		intro_node = GetNode( squad_names[ i ] + "_" + checkpoint_name + "_node", "targetname" );
		level.squad[ squad_names[ i ] ] SetGoalNode( intro_node );
	}
}

teleport_squadmember( checkpoint_name, squad_name )
{
	maps\factory_util::actor_teleport( level.squad[ squad_name ], squad_name + "_" + checkpoint_name + "_teleport" );
	intro_node = GetNode( squad_name + "_" + checkpoint_name + "_node", "targetname" );
	level.squad[ squad_name ] SetGoalNode( intro_node );
}

squad_stealth_on()
{
	foreach ( guy in level.squad )
	{
		guy.ignoreall = true;
		guy.ignoreme  = true;
		guy enable_cqbwalk();
	}
}

squad_stealth_off()
{
	foreach ( guy in level.squad )
	{
		guy.ignoreall = false;
		guy.ignoreme  = false;
		guy disable_cqbwalk();
		guy.moveplaybackrate = 1.0;
	}
}

// Animate all moving containers on conveyors in the facility
conveyor_container_setup()
{
	level.conveyor1l_boxtoggle = false;
	level.conveyor1r_boxtoggle = true;
	level.conveyor2l_boxtoggle = false;
	level.conveyor2r_boxtoggle = true;
	
	level.audio_conveyor_crate_move_down	  = [];
	level.audio_conveyor_crate_move_down[ 0 ] = "conveyor_org_12";
	level.audio_conveyor_crate_move_down[ 1 ] = "conveyor_org_18";
	level.audio_conveyor_crate_move_down[ 2 ] = "pf5466_auto257";
	level.audio_conveyor_crate_move_down[ 3 ] = "pf5466_auto279";
	level.audio_conveyor_crate_move_down[ 4 ] = "conveyor2l_org";
	level.audio_conveyor_crate_move_down[ 5 ] = "conveyor2r_org";
	level.audio_conveyor_crate_move_down[ 6 ] = "conveyor1r_org";
	level.audio_conveyor_crate_move_down[ 7 ] = "conveyor1l_org";

	
	level.audio_conveyor_crate_move_up		= [];
	level.audio_conveyor_crate_move_up[ 0 ] = "conveyor_org_13";
	level.audio_conveyor_crate_move_up[ 1 ] = "conveyor_org_29";
	level.audio_conveyor_crate_move_up[ 2 ] = "pf5466_auto266";
	level.audio_conveyor_crate_move_up[ 3 ] = "pf5466_auto270";
	
	level.audio_conveyor_crate_stop_loop	= [];
	level.audio_conveyor_crate_stop_loop[ 0 ] = "pf5466_auto253";
	level.audio_conveyor_crate_stop_loop[ 1 ] = "pf5466_auto275";
	level.audio_conveyor_crate_stop_loop[ 2 ] = "conveyor_org_31";
	level.audio_conveyor_crate_stop_loop[ 3 ] = "conveyor_org_33";

	

	//boxes = GetEntArray( "conveyor_box", "script_noteworthy" );
	//foreach( box in boxes )
	//{
		//box thread container_move();
	//}

	thread spawn_container_above_round_door();
	
	spawners = GetEntArray( "container_spawn", "script_noteworthy" );
	foreach ( spawner in spawners )
	{
		spawner thread spawn_containers();
	}
}

spawn_containers()
{
	// The sorting system should shutdown once player gets to weapon room
	level endon( "presat_locked" );
	level endon( "stop_box_conveyor_system" );

	while ( 1 )
	{
		box_type = RandomIntRange ( 0, 3 );
		
		if ( box_type == 0 )
			model = "shipping_frame_boxes"; //shipping_frame_50cal
		else
			if ( box_type == 1 )
				model = "shipping_frame_boxes"; //shipping_frame_bomb, ctl_pallet_boxes
			else
				if ( box_type == 2 )
					model = "shipping_frame_boxes"; //shipping_frame_minigun
				else
					model = "shipping_frame_boxes"; //shipping_frame_crates
		
		Box = Spawn( "script_model", self.origin );
		Box SetModel( model );
		Box.target = self.target;
		Box thread container_move();
		Box thread maps\factory_audio::audio_container_move();
		
		wait 3.0;
	}
}

spawn_container_above_round_door()
{
	// The sorting system should shutdown once player gets to weapon room
	level endon( "presat_locked" );
	level endon( "stop_box_conveyor_system" );

	while ( 1 )
	{
		box_type = RandomIntRange ( 0, 3 );
		if ( box_type == 0 )
			model = "shipping_frame_50cal"; //ctl_pallet_boxes
		else
			if ( box_type == 1 )
				model = "shipping_frame_crates"; //ctl_pallet_boxes
			else
				if ( box_type == 2 )
					model = "shipping_frame_minigun"; //ctl_pallet_boxes
				else
					model = "shipping_frame_crates"; //ctl_pallet_boxes
		Box = Spawn( "script_model", ( 6421, 1703, 550 ) );
		Box SetModel( model );
		Box thread box_above_round_door_move();
		Box thread maps\factory_audio::audio_container_move_above_door();
		//box.target = self.target;
		//box thread container_move();
		//box thread maps\factory_audio::audio_container_move();
		
		wait RandomFloatRange ( 1.2, 5.0 );
	}
}

box_above_round_door_move()
{
	self RotateTo ( ( 6, 0, 0 ), 0.1 );
	self MoveTo( ( 8229, 1703, 348 ), 28 );
	self waittill ( "movedone" );
	self Delete();
}

get_next_conveyor_target( target_name )
{
	targetorg = GetEnt( target_name, "targetname" );
	
	if ( IsDefined( targetorg.target ) )
	{
		new_target = targetorg.target;
	}
	else
	{
		switch( target_name )
		{
			case "conveyor1l_org":
				if ( level.conveyor1l_boxtoggle )
				{
					new_target = "conveyor1l_org_a";
				}
				else
				{
					new_target = "conveyor1l_org_b";
				}
				break;
			case "conveyor1r_org":
				if ( level.conveyor1r_boxtoggle )
				{
					new_target = "conveyor1r_org_a";
				}
				else
				{
					new_target = "conveyor1r_org_b";
				}
				break;
			case "conveyor2l_org":
				if ( level.conveyor2l_boxtoggle )
				{
					new_target = "conveyor2l_org_a";
				}
				else
				{
					new_target = "conveyor2l_org_b";
				}
				break;
			case "conveyor2r_org":
				if ( level.conveyor2r_boxtoggle )
				{
					new_target = "conveyor2r_org_a";
				}
				else
				{
					new_target = "conveyor2r_org_b";
				}
				break;
			default:
				new_target = "";
				AssertMsg( "Unknown conveyor box target name" );
				break;
		}
	}
	
	return new_target;
}

update_conveyor_toggle_if_necessary( target_name )
{
	switch( target_name )
	{
		case "conveyor1l_org":
			level.conveyor1l_boxtoggle = !level.conveyor1l_boxtoggle;
			break;
		case "conveyor1r_org":
			level.conveyor1r_boxtoggle = !level.conveyor1r_boxtoggle;
			break;
		case "conveyor2l_org":
			level.conveyor2l_boxtoggle = !level.conveyor2l_boxtoggle;
			break;
		case "conveyor2r_org":
			level.conveyor2r_boxtoggle = !level.conveyor2r_boxtoggle;
			break;
	}
}

container_set_speed_accel( old_targetorg, targetorg )
{
	CONTAINER_ACCEL = 0.4;
	
	if ( !IsDefined( old_targetorg.script_noteworthy ) )
	{
		self.accel = CONTAINER_ACCEL;
	}
	else
	{
		switch( old_targetorg.script_noteworthy )
		{
			case "stacking":
				self.accel = CONTAINER_ACCEL;
				break;
			case "conveyor":
				self.accel = 0;
				break;
			default:
				AssertMsg( "Unknown conveyor box target noteworthy" );
		}
	}
	if ( !IsDefined( targetorg.script_noteworthy ) )
	{
		self.speed = 50;
		self.decel = CONTAINER_ACCEL;
	}
	else
	{
		switch( targetorg.script_noteworthy )
		{
			case "stacking":
				self.speed = 50;
				self.decel = CONTAINER_ACCEL;
				break;
			case "conveyor":
				self.speed = 75;
				self.decel = 0;
				break;
			case "container_path_end":
				self.speed = 75;
				self.decel = 0;
				break;
			default:
				AssertMsg( "Unknown conveyor box target noteworthy" );
		}
	}
}

container_move()
{
//	prof_begin( "fac_container_move" );
	
	DIST_THRESHOLD = 8;	
	
	if ( !IsDefined( self.target ) )
	{
		return;
	}
	
	target_name = self.target;
	targetorg	= GetEnt( target_name, "targetname" );
	path_dist	= Distance( targetorg.origin, self.origin );
	self container_set_speed_accel( self, targetorg );
	self.accel = 0;
	if ( path_dist / self.speed < self.decel )
	{
		self.decel = path_dist / self.speed;
	}
	if ( IsDefined( targetorg.script_angles ) )
	{
		self.angles = targetorg.script_angles;
	}
	else
	{
		self.angles = ( 0, 0, 0 );
	}
	self thread conveyor_box_adjust_angles( target_name );
	self MoveTo( targetorg.origin, path_dist / self.speed, self.accel, self.decel );
	
	while ( 1 )
	{
		dist = Distance( targetorg.origin, self.origin );
		if ( dist <= DIST_THRESHOLD )
		{
			old_target	  = target_name;
			old_targetorg = targetorg;
			
			if ( IsDefined( old_targetorg.script_wait ) )
			{
				wait( old_targetorg.script_wait );
			}
			
			if ( old_targetorg.script_noteworthy == "container_path_end" )
			{
				self Delete();
//				prof_end( "fac_container_move" );
				break;
			}
					
			target_name = self get_next_conveyor_target( old_target );
			self update_conveyor_toggle_if_necessary( old_target );
			targetorg = GetEnt( target_name, "targetname" );

			//Contact audio if there are any significant changes to the path nodes
			for ( index = 0; index < level.audio_conveyor_crate_move_down.size; index++ )
			{
				if ( IsDefined( level.audio_conveyor_crate_move_down[ index ] ) )
				{
					if ( target_name == level.audio_conveyor_crate_move_down[ index ] )
					{
						//play crate down sound here
						self thread maps\factory_audio::sfx_play_stacker_down();
//						prof_end( "fac_container_move" );
						break;
					}
				}
				if ( IsDefined( level.audio_conveyor_crate_move_up[ index ] ) )
				{
					if ( target_name == level.audio_conveyor_crate_move_up[ index ] )
					{
						//play crate up sound here
						self thread maps\factory_audio::sfx_play_stacker_up();
//						prof_end( "fac_container_move" );
						break;
					}
				}
				if ( IsDefined(level.audio_conveyor_crate_stop_loop[ index ]))
				{
					if ( target_name == level.audio_conveyor_crate_stop_loop[ index ] )
					{
						self StopLoopSound("emt_factory_rollers");
						self StopLoopSound("emt_factory_rollers_low");
						break;
					}
				}
				//todo: setup sound for the crates that move from left to right
			}
		
			path_dist = Distance( targetorg.origin, self.origin );
			self container_set_speed_accel( old_targetorg, targetorg );	
			if ( self.accel + self.decel > path_dist / self.speed )
			{
				self.accel = ( path_dist / self.speed ) / 2;
				self.decel = ( path_dist / self.speed ) / 2;
			}
			
			self thread conveyor_box_adjust_angles( target_name );
			
			self MoveTo( targetorg.origin, path_dist / self.speed, self.accel, self.decel );
		}
		
		wait( 0.05 );
	}
	
//	prof_end( "fac_container_move" );
}

conveyor_box_adjust_angles( target_name )
{
	self endon( "death" );
	
	CURVE_DIST = 30;
	
	old_targetorg = GetEnt( target_name, "targetname" );	
	if ( old_targetorg.script_noteworthy == "container_path_end" )
	{
		return;
	}
	
	new_target_name = self get_next_conveyor_target( target_name );
	targetorg		= GetEnt( new_target_name, "targetname" );
	
	if ( IsDefined( targetorg.script_angles ) )
	{
		new_angles = targetorg.script_angles;
	}
	else
	{
		new_angles = ( 0, 0, 0 );
	}
			
	while ( 1 )
	{
		dist = Distance( old_targetorg.origin, self.origin );
		if ( dist <= CURVE_DIST )
		{
			self RotateTo( new_angles, 0.5 );
			break;
		}
		
		wait( 0.05 );
	}
}

// Sets up cargo containers that move back and forth on the ancra loading system
moving_container( container_name, dist, time, offset )
{
	self.audio_org		= undefined;	
	//level waittill( "container_shift_done" );
	
	// Get the node
	container_org = GetEnt( container_name + "_origin", "targetname" );
	
	// Get the parts
	parts = [];
	parts = GetEntArray( container_org.target, "targetname" );
	
	foreach ( part in parts )
	{
		part LinkTo( container_org );
	}

	//DR: temp audio for these moving parts - create an origin then link it to the rest of them
	self.audio_org = Spawn( "script_origin", container_org.origin );
	self.audio_org LinkTo( container_org );	

	wait offset;	

	container_org thread targetMoveX( dist, time, self.audio_org );	
	
}

// Generic function for looping a back and forth motion along the X axis
targetMoveX( dist, time, audio_org )
{
	for ( ;; )
	{
		//start a looping sound as it travels	
		//audio_org playloopsound("emt_movingcover2_rolling2_loop_B");	

		self MoveX( dist, time );
		self waittill( "movedone" );


		//for now, keeping the loop going - the scripting seems to be really weird 
		//and not functioning correctly.  it stops the looping sound midway through...
		//maybe something to do with the "movedone" notifies?
		//so now the sound will loop, even when its standing still
		//stop the looping sound when it stops
		//audio_org stoploopsound("emt_movingcover2_rolling2_loop");	
		
		wait 2.0;

		//start a looping sound as it travels	
		//audio_org playloopsound("emt_movingcover2_rolling2_loop");	
		
		self MoveX( 0.0 - dist, time );
		self waittill( "movedone" );

		//stop the looping sound when it stops
		//audio_org stoploopsound("emt_movingcover2_rolling2_loop");	
		
		wait 2.0;
	}
}

// Does a one time move that shifts a container over and then sets it to load into the back of a truck
moving_container_custom( container_name, rack_name )
{
	// Get the nodes
	container_org = [];
	container_org = GetEnt( container_name + "_origin", "targetname" );
	rack_org	  = GetEnt( rack_name + "_origin", "targetname" );
	
	// Get the parts
	container_parts = [];
	container_parts = GetEntArray( container_org.target, "targetname" );
	rack_part		= GetEnt( rack_org.target, "targetname" );
	
	// Link the parts to the origin we'll be moving
	foreach ( part in container_parts )
	{
		part LinkTo( container_org );
	}
	
	rack_part LinkTo( container_org );	

	//DR: temp audio for these moving parts - create an origin then link it to the rest of them
	level.audio_custom_org = Spawn( "script_origin", rack_org.origin );
	level.audio_custom_org LinkTo( container_org );

	//start a looping sound as it travels	
	//level.audio_custom_org playloopsound("emt_movingcover2_rolling1_loop_B");	
	
	container_org MoveY( 216, 5 );
	container_org waittill( "movedone" );
	//level.audio_custom_org stoploopsound("emt_movingcover2_rolling1_loop_B");	
		
	// Need to leave the rack in place
	rack_part Unlink();
	
	wait 3.0;
	level notify( "container_shift_done" );
	container_org MoveX( -736, 25 );

	//start a looping sound as it travels	
	//level.audio_custom_org playloopsound("emt_movingcover2_rolling1_loop_B");	

	wait 25;

	//level.audio_custom_org stoploopsound("emt_movingcover2_rolling1_loop_B");	
}

//================================================================================================
//	UTIL
//================================================================================================
set_flag_on_player_action( flag_str, flash, grenade )
{
	level notify( "kill_action_flag" );
	level endon( "kill_action_flag" );
	level endon( flag_str );

	if ( flag( flag_str ) )
		return;

	while ( true )
	{
		msg = level.player waittill_any_return( "weapon_fired", "fraggrenade", "flash_grenade", "smoke_grenade_american" );
		if ( !IsDefined( msg ) )
			break;
		if ( msg == "weapon_fired" )
			break;
		if ( msg == "fraggrenade" && IsDefined( grenade ) )
			break;
		if ( msg == "flash_grenade" && IsDefined( flash ) )
			break;
	}

	flag_set( flag_str );
}

attach_flashlight( state, spotlight )
{
	if ( !IsDefined( spotlight ) )
		spotlight = true;
	
	self Attach( "com_flashlight_on", "tag_inhand", true );
	self.have_flashlight = true;
	self flashlight_light( state, spotlight );
	self thread detach_flashlight_on_death();
}

detach_flashlight_on_death()
{
	self waittill( "death" );
	
	if ( IsDefined( self ) )
	{
		self detach_flashlight();
		wait 0.25;
	}
}

detach_flashlight()
{
	if ( !IsDefined( self.have_flashlight ) )
		return;
	self Detach( "com_flashlight_on", "tag_inhand" );
	self flashlight_light( false );
	self.have_flashlight = undefined;
}

flashlight_light( state, spotlight )
{
	flash_light_tag = "tag_light";

	if ( state )
	{
		flashlight_fx_ent = Spawn( "script_model", ( 0, 0, 0 ) );
		flashlight_fx_ent SetModel( "tag_origin" );
		flashlight_fx_ent Hide();
		flashlight_fx_ent LinkTo( self, flash_light_tag, ( 0, 0, 0 ), ( 0, 0, 0 ) );

		self thread flashlight_light_death( flashlight_fx_ent );
		
		if ( spotlight )
			PlayFXOnTag( level._effect[ "flashlight_spotlight" ], flashlight_fx_ent, "tag_origin" );
		else
			PlayFXOnTag( level._effect[ "flashlight" ], flashlight_fx_ent, "tag_origin" );
	}
	else if ( IsDefined( self.have_flashlight ) )
		self notify( "flashlight_off" );
}

flashlight_light_death( flashlight_fx_ent )
{
	self waittill_either( "death", "flashlight_off" );

	flashlight_fx_ent Delete();
	self.have_flashlight = undefined;
	
	// Give flashlight_spotlight time to disable
	waittillframeend;
	wait 0.1;
	
	// Now play flashlight dropping effect with real light attached
	if ( !IsDefined( self.dontdrop_flashlight ) )
	{
		PlayFXOnTag( level._effect[ "dropped_flashlight_spotlight_runner" ], self, "tag_inhand" );
	}
}

ignore_move_suppression( note )
{
	self endon( "death" );
	if ( IsDefined( note ) )
		self endon( note );
	
	while ( 1 )
	{
		if ( self IsMoveSuppressed() )
		{
			self set_ignoreSuppression( true );
			wait( 4 );
		}
		else if ( IsDefined( self.ignoreSuppression ) && self.ignoreSuppression )
			self set_ignoreSuppression( false );
		
		wait( 0.25 );
	}
}

//================================================================================================
//	UTIL - FACTORY ANIMATIONS
//================================================================================================

move_warning_light( positionx, positiony, positionz )
{
	//IPrintLnBold( "attaching light" );
	level endon( "presat_locked" );
   	new_model = spawn_tag_origin();
    	PlayFXOnTag( level._effect[ "glow_red_light_400_strobe" ], new_model, "tag_origin" );

    	// Use this next thread if we want to rotate the lights
    	//new_model thread rotate_warning_light();

	// if we don;t need to rotate the light we can just do a linkto rather than constantly reseting the origin
	//new_model.origin = ( level.tank_crane_soundorg_loop.origin + (positionx, positiony, positionz) );
    	//new_model linkTo( level.tank_crane_soundorg_loop );

	crane_org = GetEnt( "reveal_crane_org", "targetname" );

	while ( 1 )
    	{
		new_model.origin = ( crane_org.origin + ( positionx, positiony, positionz ) );
	    	//new_model.origin = ( level.tank_crane_soundorg_loop.origin + (positionx, positiony, positionz) );
	    	wait 0.05;
    	}
}

rotate_warning_light()
{
	level endon( "presat_locked" );
	//IPrintLnBold( "rotating strobe1" );
    	while ( 1 )
    	{
		self RotateYaw( 360, 2 );
	    	wait 2;
		//IPrintLnBold( "rotate" );
    	}
}

animate_tank_crane()
{
	factory_entrance_tank = GetEntArray( "factory_entrance_tank_loading", "script_noteworthy" );	

	//DR: temp sound org solution for moving crane
	level.tank_crane_soundorg_loop		 = Spawn ( "script_origin", ( 5400, 3044, 478 ) );
	level.tank_crane_soundorg_start_stop = Spawn ( "script_origin", ( 5400, 3044, 478 ) );

  	thread move_warning_light( -125, 0, -85 );
   	thread move_warning_light( 65, 0, -85 );
    	wait 4.0;
	
	foreach ( piece in factory_entrance_tank )
		piece MoveX( -675, 18, 2, 6 );
	
	
	level.tank_crane_soundorg_loop MoveX( -675, 18, 2, 6 );	
	level.tank_crane_soundorg_start_stop MoveX( -675, 18, 2, 6 );		
	thread maps\factory_audio::audio_crane_movement_factory_reveal_01( 18, 2, 6 );

	wait 18.0;
	
	foreach ( piece in factory_entrance_tank )
		piece MoveZ( -60, 10, 2, 6 );

	level.tank_crane_soundorg_loop MoveZ( -44, 10, 2, 6 );
	level.tank_crane_soundorg_start_stop MoveZ( -44, 10, 2, 6 );
	//thread maps\factory_audio::audio_crane_movement_factory_reveal_02(10, 2, 6);
}

CRANE_DROP1_MOVE_TIME		= 17.0;
CRANE_RAISELOWER_TIME		= 10.0;
CRANE_QUICK_RAISELOWER_TIME = 0.7;
PLATFORM_MOVE_TIME			= 45.0;

factory_entrance_reveal_animate_pieces()
{
	//thread moving_container( "loading_container_01", -1024, 30, 11.0 );
	//thread moving_container( "loading_container_02", -512, 15, 6 );
	//thread moving_container_custom( "loading_container_03", "ancra_rack_03" );
		
	//while( 1 )
	//{
		thread factory_entrance_reveal_animate_crane();
//		thread factory_entrance_reveal_animate_loading_container01a();
//		thread factory_entrance_reveal_animate_loading_container02();
//		thread factory_entrance_reveal_animate_loader01();
		
		//level waittill( "factory_entrance_reveal_loop_complete" );
	//}
}

factory_entrance_reveal_animate_crane()
{	
	thread maps\factory_anim::allies_enter_factory_cranes();
	
//	crane_org = GetStruct( "allies_enter_factory", "script_noteworthy" );
//	crane	  = Spawn( "script_model", crane_org.origin );
//	crane SetModel( "factory_crane_loader_01" );
//	
//	crane_org anim_single_solo( crane, "factory_crane_rear" );
	
	
	// OLD SCENE
	/*
	crane_org		= GetEnt( "reveal_crane_org", "targetname" );
	crane_init_org	= Spawn( "script_origin", crane_org.origin );
	crane_drop1_org = GetEnt( "reveal_crane_01_drop01", "targetname" );
	
	flag_wait( "card_swiped" );
	
							   //   positionx    positiony    positionz   
		thread move_warning_light( -125		  , 115		   , 10 );
		thread move_warning_light( 65		  , 115		   , 10 );

    	crane_parts = [];
	crane_parts = GetEntArray( crane_org.target, "targetname" );
	
	foreach( crane_part in crane_parts )
	{
		crane_part linkTo( crane_org );
	}
	
	wait( CRANE_QUICK_RAISELOWER_TIME );
	
	crane_org MoveTo( crane_drop1_org.origin, CRANE_DROP1_MOVE_TIME, 1.0, 1.0 );
	
	wait( CRANE_DROP1_MOVE_TIME );
	
	wait( 2 * CRANE_RAISELOWER_TIME );
	
	crane_org MoveTo( crane_init_org.origin, CRANE_DROP1_MOVE_TIME, 1.0, 1.0 );
	
	wait( CRANE_DROP1_MOVE_TIME );
	
	wait( CRANE_RAISELOWER_TIME );
	
	level notify( "factory_entrance_reveal_loop_complete" );
	*/
	
}

factory_entrance_reveal_animate_loading_container01a()
{	
	container1a_org = GetEnt( "loading_container_01a_org", "targetname" );
												//   positionx    positiony    positionz   
	container1a_org thread loading_platform_lights( 95		   , 70			, 40 );
	container1a_org thread loading_platform_lights( -95		   , 70			, 40 );
	
	container1a_path2_org = GetEnt( "loading_container01a_path02", "targetname" );
	
	container_parts = [];
	container_parts = GetEntArray( container1a_org.target, "targetname" );
	foreach ( container_part in container_parts )
	{
		container_part LinkTo( container1a_org );
	}
	
	//large_missiles = GetEntArray( "entrance_large_missiles", "targetname" );
	//foreach( missile_part in large_missiles )
	//{
	//	missile_part.origin = ( missile_part.origin + (0, 0, 0) );
	//	missile_part linkTo( container1a_org );
	//}

//	large_missiles		  = GetEnt( "entrance_large_missiles", "targetname" );
//	large_missiles.origin = ( container1a_org.origin + (-300, 0, -70) );
//	large_missiles LinkTo ( container1a_org );

	wait( CRANE_QUICK_RAISELOWER_TIME );
	
	wait( CRANE_DROP1_MOVE_TIME );
	
	container1a_org MoveTo( container1a_path2_org.origin, PLATFORM_MOVE_TIME, 1.0, 1.0 );
}

factory_entrance_reveal_animate_loading_container02()
{	
	container2a_org = GetEnt( "loading_container_02a_origin", "targetname" );
	
	container2_path1_org  = GetEnt( "loading_container02_path01", "targetname" );
	container2a_path2_org = GetEnt( "loading_container02a_path02", "targetname" );
	container2a_path3_org = GetEnt( "loading_container02a_path03", "targetname" );
	container2a_path4_org = GetEnt( "loading_container02a_path04", "targetname" );
	
	container_parts = [];
	container_parts = GetEntArray( container2a_org.target, "targetname" );
	foreach ( container_part in container_parts )
	{
		container_part LinkTo( container2a_org );
	}
	
	container2a_org MoveTo( container2_path1_org.origin, CRANE_QUICK_RAISELOWER_TIME, 0.3, 0.3 ); //CRANE_QUICK_RAISELOWER_TIME, 0.0, 0.0); //CRANE_RAISELOWER_TIME, 0.5, 0.5 );
	
	wait( CRANE_QUICK_RAISELOWER_TIME );
	
	container2a_org MoveTo( container2a_path2_org.origin, CRANE_DROP1_MOVE_TIME, 1.0, 1.0 );
	
	wait( CRANE_DROP1_MOVE_TIME );
	
	container2a_org MoveTo( container2a_path3_org.origin, CRANE_RAISELOWER_TIME, 0.5, 0.5 );
	
	wait( CRANE_RAISELOWER_TIME );
	
	container2a_org MoveTo( container2a_path4_org.origin, PLATFORM_MOVE_TIME, 1.0, 1.0 );
	
	wait( CRANE_RAISELOWER_TIME );
	
	wait( CRANE_DROP1_MOVE_TIME );
}

factory_entrance_reveal_animate_loader01()
{	
	loader_platform01_org = GetEnt( "loader_platform01_org", "targetname" );
													  //   positionx    positiony    positionz   
	loader_platform01_org thread loading_platform_lights( 95		 , 70		  , 40 );
	loader_platform01_org thread loading_platform_lights( -95		 , 70		  , 40 );
	container2a_path3_org = GetEnt( "loading_container02a_path03", "targetname" );
	container2a_path4_org = GetEnt( "loading_container02a_path04", "targetname" );
	// attach the platform to a script origin
	loader_parts = [];
	loader_parts = GetEntArray( loader_platform01_org.target, "targetname" );
	foreach ( loader_part in loader_parts )
	{
		loader_part LinkTo( loader_platform01_org );
	}
	// attach the missilesto a script origin
	loading_container_02a_origin = GetEnt( "loading_container_02a_origin", "targetname" );
	missile_parts				 = [];
	missile_parts				 = GetEntArray( loading_container_02a_origin.target, "targetname" );
	foreach ( missile_part in missile_parts )
	{
		missile_part LinkTo( loading_container_02a_origin );
	}
	loading_container_02a_origin.origin = ( loader_platform01_org.origin + ( 0, 0, -15 ) );
	loading_container_02a_origin LinkTo ( loader_platform01_org );
	loader_platform01_org.origin = ( loader_platform01_org.origin + ( 0, 0, 0 ) );
	wait 20.8;
	
	//loader_platform01_org MoveZ (-55, 6);

	//loader_platform01_org waittill ( "movedone" );
	
	loader_platform01_org MoveTo( container2a_path4_org.origin, PLATFORM_MOVE_TIME, 1.0, 1.0 );
}

loading_platform_lights( positionx, positiony, positionz )
{
    new_model = spawn_tag_origin();
    PlayFXOnTag( level._effect[ "factory_moving_piece_light" ], new_model, "tag_origin" );
    new_model.origin = ( self.origin + ( positionx, positiony, positionz ) );
    new_model LinkTo ( self );
	flag_wait ( "open_exit_doors" );
	StopFXOnTag( level._effect[ "factory_moving_piece_light" ], new_model, "tag_origin" );
	IPrintLnBold( "killing platform tag_origin" );
    new_model Delete();
}

//================================================================================================
//	CRATES
//================================================================================================
move_crates()
{
	loader_platform01_org = GetEnt( "loader_platform01_org", "targetname" );
	entrance_crate1		  = GetEnt( "entrance_crate_01", "targetname" );
	entrance_crate2		  = GetEnt( "entrance_crate_02", "targetname" );
	entrance_crate3		  = GetEnt( "entrance_crate_03", "targetname" );
	entrance_crate4		  = GetEnt( "entrance_crate_04", "targetname" );
	entrance_crate1 thread loading_platform_lights( 0, 46, 90 );
	entrance_crate2 thread loading_platform_lights( 0, 46, 90 );
	entrance_crate3 thread loading_platform_lights( 0, 46, 90 );
	entrance_crate4 thread loading_platform_lights( 0, 46, 90 );
	wait 2;
	entrance_crate1 MoveX ( -440, 13 );
	entrance_crate2 MoveX ( -440, 13 );
	entrance_crate3 MoveX ( -900, 20 );
	entrance_crate4 MoveX ( -900, 20 );
	entrance_crate1 waittill ( "movedone" );
	entrance_crate1 MoveX ( -130, 4 );
	entrance_crate2 MoveY ( -200, 5 );
	entrance_crate2 waittill ( "movedone" );
	entrance_crate1 MoveY ( -200, 5 );
	entrance_crate2 MoveX ( -130, 4 );
	entrance_crate3 MoveX ( 900, 20 );
	entrance_crate4 MoveX ( 900, 20 );
	entrance_crate2 waittill ( "movedone" );
	entrance_crate3 MoveX ( -900, 20 );
	entrance_crate4 MoveX ( -900, 20 );
}

//================================================================================================
//	FORKLIFTS
//================================================================================================
move_forklifts()
{

	forklift_entrance01 = GetEnt( "forklift_entrance01", "targetname" );
	new_model			= spawn_tag_origin(	 );
	new_model.origin	=				  ( forklift_entrance01.origin + ( 0, 0, 70 ) );
    new_model LinkTo ( forklift_entrance01 );
    PlayFXOnTag( level._effect[ "light_blink_forklift" ], new_model, "tag_origin" );
//    thread forkilft_movement();  // tagTJ: disabling while art is in progress
    flag_wait ( "open_exit_doors" );
	StopFXOnTag( level._effect[ "light_blink_forklift" ], new_model, "tag_origin" );
}

forkilft_movement()
{
	forklift_entrance01 = GetEnt( "forklift_entrance01", "targetname" );
	location0			= GetEnt( "forklift_loc_00" , "targetname" );
	location0a			= GetEnt( "forklift_loc_00a", "targetname" );
	location1			= GetEnt( "forklift_loc_01" , "targetname" );
	location1a			= GetEnt( "forklift_loc_01a", "targetname" );
	location2			= GetEnt( "forklift_loc_02" , "targetname" );
	location2a			= GetEnt( "forklift_loc_02a", "targetname" );
	location3			= GetEnt( "forklift_loc_03" , "targetname" );
	location3a			= GetEnt( "forklift_loc_03a", "targetname" );
	location4			= GetEnt( "forklift_loc_04" , "targetname" );
	location4a			= GetEnt( "forklift_loc_04a", "targetname" );
    while ( 1 )
    {
		forklift_turnandmoveto ( location1 );
		forklift_turnandmoveto ( location1a );
		forklift_turnandmoveto ( location1 );
		forklift_turnandmoveto ( location4 );
		forklift_turnandmoveto ( location4a );
		forklift_turnandmoveto ( location4 );
		forklift_turnandmoveto ( location0 );
		forklift_turnandmoveto ( location0a );
		forklift_turnandmoveto ( location0 );
		forklift_turnandmoveto ( location2 );
		forklift_turnandmoveto ( location2a );
		forklift_turnandmoveto ( location2 );
		forklift_turnandmoveto ( location0 );
		forklift_turnandmoveto ( location0a );
		forklift_turnandmoveto ( location0 );
		forklift_turnandmoveto ( location3 );
		forklift_turnandmoveto ( location3a );
		forklift_turnandmoveto ( location3 );
    }
}

forklift_turnandmoveto ( location )
{
	forklift_entrance01 = GetEnt( "forklift_entrance01", "targetname" );
	forklift_entrance01 MoveTo ( location.origin, 3 );
	forklift_entrance01 waittill( "movedone" );
}

//================================================================================================
//	UTIL - CONVEYORS
//================================================================================================

/*
conveyor_setup( first_node_noteworthy, last_node_noteworthy, platform_noteworthy, piece_length, conveyor_speed )
{    
	platforms = GetEntArray( platform_noteworthy, "script_noteworthy" );
	for( ii	  = 0; ii < platforms.size; ii++ )
    {
       platforms[ii].linked = false;
    }
   	
   	array_call( platforms, ::Hide );
   	array_thread( platforms, ::conveyor_unlink_belt_piece, last_node_noteworthy );
    
    level thread conveyor_add_belt_pieces( first_node_noteworthy, last_node_noteworthy, platform_noteworthy, piece_length, conveyor_speed );
}

conveyor_unlink_belt_piece( last_node_noteworthy )
{
    last_node = getent( last_node_noteworthy, "targetname" );
    
    target_radius = 5;
    if( IsDefined( last_node.radius ) )
        target_radius = last_node.radius;
    
    last_node_org = ( last_node.origin[ 0 ], last_node.origin[ 1 ], 0 );
    
    while( 1 )
    {
        if( self.linked )
        {
			platform_org = ( self.origin[ 0 ], self.origin[ 1 ], 0 );
			dist		 = Distance( last_node_org, platform_org );
                            
            if( dist <= target_radius )
            {
				self.linked = false;
				self.origin = (10000,10000,10000);
            }
        }
        
        wait( 0.05 );
    }
}

conveyor_add_belt_pieces( first_node_noteworthy, last_node_noteworthy, platform_noteworthy, piece_length, conveyor_speed )
{
	first_node = getent( first_node_noteworthy, "targetname" );
	last_node  = getent( last_node_noteworthy, "targetname" );
	dist	   = Distance( last_node.origin, first_node.origin );
    
    while(1)
    {
		platforms = GetEntArray( platform_noteworthy, "script_noteworthy" );
		for( ii	  = 0; ii < platforms.size; ii++ )
         {
            if( !platforms[ii].linked )
            {
				platforms[ii].origin = first_node.origin;
				platforms[ii] MoveTo( last_node.origin, dist / ( CONST_MPHTOIPS * conveyor_speed ), .01, .01 );
                platforms[ii].linked = true;
                break;
            }
        }
        
        wait( piece_length / ( CONST_MPHTOIPS * conveyor_speed ) );
    }
}

wait_for_mantle_trigger()
{
	trigger = GetEnt( "trig_conveyor_mantle", "script_noteworthy" );

	while( 1 )
	{
		trigger waittill( "trigger", ent );

		if( ent != level.player && !( ent IsLinked() ) )
		{
			platforms = GetEntArray( "conveyor_platform_player", "script_noteworthy" );
			closest	  = getClosest( ent.origin, platforms );
			
			ent Teleport( closest.origin + ( 0, 0, 5 ), (0,0,0) ); 
			ent LinkTo( closest );
			
			ent.baseaccuracy = 100; 
			
			// JR - Commenting this out because this script never dies or undoes these changes
			//ent.cqbEnabled = true;
			//ent allowedstances( "crouch" );
		}
	}
} 

wait_for_conveyor_dismount()
{
	trigger = GetEnt( "trig_conveyor_dismount", "script_noteworthy" );
	
	while( 1 )
	{
		trigger waittill( "trigger", ent );
		
		if( ent != level.player && ( ent IsLinked() ) )
		{
			ent Unlink();
			
			ent enable_ai_color();
			//ent SetGoalVolumeAuto( GetEnt( "vol_conveyor_regroup_01", "script_noteworthy" ) );
		}
	}
}

*/
