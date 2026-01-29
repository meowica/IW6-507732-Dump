//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  Factory Ambush												**
//                                                                          **
//    Created: 	8/5/12	Neversoft											**
//                                                                          **
//****************************************************************************

#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


start()
{
	maps\factory_util::actor_teleport( level.squad[ "ALLY_ALPHA" ]	, "ambush_start_alpha" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_BRAVO" ]	, "ambush_start_bravo" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_CHARLIE" ], "ambush_start_charlie" );
	
	level.squad[ "ALLY_ALPHA"	]thread enable_cqbwalk(	 );
	level.squad[ "ALLY_BRAVO"	]thread enable_cqbwalk(	 );
	level.squad[ "ALLY_CHARLIE" ]thread enable_cqbwalk(	 );
	
	//level thread maps\factory_util::debug_kill_counter_enable();

	maps\factory_util::safe_trigger_by_targetname( "ambush_intro_ally01_position" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_intro_ally02_position" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_intro_ally03_position" );

	level.player maps\factory_util::move_player_to_start_point( "playerstart_ambush" );

	flag_set("lgt_ambush_jump");
	
	// Start the assembly line
	thread maps\factory_anim::factory_assembly_line_play();

	// Open the ambush room doors
	level thread maps\factory_util::open_door( "ambush_door_pivot_left", -160, 0.5, true );
	level thread maps\factory_util::open_door( "ambush_door_pivot_right", 145, 0.5, true );

	// Various setup
	thread ambush_setup();


	// Give allies the silent rifle
	/*
	foreach ( guy in level.squad )
	{
		guy forceUseWeapon( "mp5_silencer_eotech", "primary" );  // OLD VAL: m14_scoped_silencer
	}
	*/
	// Deletes script models
	thread maps\factory_powerstealth::train_cleanup();
	
	wait 0.1;
}

section_precache()
{
	PreCacheModel( "fac_keyboard_obj" );
	PreCacheModel( "factory_ambush_monitor_obj" );
	PreCacheModel( "fac_io_device_obj" );
	PreCacheModel( "factory_assembly_automated_arm_damaged" );
	PrecacheItem( "smoke_grenade_factory" );
	PreCacheShader( "nightvision_overlay_goggles" );
	precacheshellshock( "flashbang" );
	//PreCacheItem ( "rpg_straight" );
	//PreCacheItem ( "rpg_nodamage" );
}

section_flag_init()
{
	flag_init( "factory_assembly_line_resume_speed_front" );
	flag_init( "factory_assembly_line_resume_speed_back" );
	flag_init( "enable_ambush_use" );
	flag_init( "player_used_computer" );
	flag_init( "ambush_start_fx" );
	flag_init( "ambush_vignette_done" );
	flag_init( "ambush_moment_clear" );
	flag_init( "ambush_prep_smoke_01" );
	flag_init( "ambush_smoke_01" );
	flag_init( "ambush_used_thermal" );
	flag_init( "walking_cough_guy_done" );
	flag_init( "ambush_thermal_flashed" );
	flag_init( "ambush_arm_malfunction" );
	flag_init( "ambush_thermal_allies_movedup_01" );
	flag_init( "ambush_wave_3_done" );
	flag_init( "ambush_lower_back_clear" );
	flag_init( "thermal_battle_clear" );
	flag_init( "stop_smoke_penalty" );
	flag_init( "stop_assembly_line" );
	flag_init("lgt_ambush_jump");
}

// Objective specific add_hint_string() calls
section_hint_string_init()
{
	//"Press [{+actionslot 4}] to activate Thermal"
	add_hint_string( "HINT_THERMAL", &"FACTORY_HINT_THERMAL", ::hint_thermal_timeout );

	//"Press [{+actionslot 4}] to de-activate Thermal"
	add_hint_string( "HINT_THERMAL_OFF", &"FACTORY_HINT_THERMAL_OFF", ::hint_thermal_off_timeout );

	//"[{+actionslot 4}] Thermal On"
	add_hint_string( "HINT_THERMAL_SHORT", &"FACTORY_HINT_THERMAL_SHORT", ::hint_thermal_timeout );

	//"[{+actionslot 4}] Thermal Off"
	add_hint_string( "HINT_THERMAL_OFF_SHORT", &"FACTORY_HINT_THERMAL_OFF_SHORT", ::hint_thermal_off_timeout );
}

//================================================================================================
//	MAIN
//================================================================================================
main()
{
	// Save
	autosave_by_name( "ambush" );

	// Start dialogue thread
	level thread ambush_dialogue();
	
	// To prevent helicopter appearing if the player rushes ambush
	thread maps\factory_rooftop::rooftop_heli();
	
	thread maps\factory_audio::ambush_line_emitter_create();

	// Ambush moment and encounter
	level thread ambush_moment_logic();
	
	// Audio: Cue up pa bursts for next section
	thread maps\factory_audio::sfx_pa_bursts();
	
	// Thermal encounter to escape the room
	level thread thermal_battle_logic();
	
	flag_wait( "thermal_battle_clear" );
	
	//Cleanup!
	ambush_cleanup();
	
	// Turn off assembly line
	flag_set( "stop_assembly_line" );
	level notify( "stop_assembly_line" );
	
	// Delay so VO doesnt overlap with next section starting
	wait 2.5;
}

//================================================================================================
//================================================================================================
// Section setup
ambush_setup()
{
	level.ambush_threat_boost = 2600;  // <- Controls overall difficulty
	level.player.maxvisibledist = 1280; //8192

	foreach ( ally in level.squad )
	{
		ally.fixednodesaferadius = 256;
		ally.script_accuracy = 0.5; // Allies have sniper rifles, dont let them kill everyone
		ally.suppressionwait = 3500;
		ally.attackeraccuracy = 0.1; // Enemies are ELITES and so have 5x accuracy.
		ally.useChokePoints = false;
		ally PushPlayer( true );
	}

	// Hide all the post breach props
	post_breach_props = GetEntArray( "ambush_desk_prop_post", "targetname" );
	foreach( ent in post_breach_props )
	{
		if( isDefined( ent.script_parameters ))
		{
			ent ConnectPaths();
		}
		ent NotSolid();
		ent hide();
	}
	
	// Hide the grenade canisters
	cans = GetEntArray( "smoke_canister", "script_noteworthy" );
	foreach( can in cans )
	{
		can hide();
	}

	// Hide the PDA bink poly
	usb_screen_poly = GetEnt( "ambush_breach_player_pda", "targetname" );
	usb_screen_poly hide();
	
	// Tweak grenade params
	set_custom_gameskill_func( ::factory_ambush_grenade_params );
	
	// Disable the mantles
	mantles = GetEntArray( "ambush_window_mantle", "targetname" );
	foreach( mantle in mantles )
	{
		mantle MoveZ( -100, 0.1 );
	}
	
	// Spin some fans
	fans = [];
	fans = GetEntArray( "ambush_fan", "targetname" );
	foreach( fan in fans )
	{
		fan thread ambush_fan_spin();
	}

	// Get the ambush anim props in position
	thread maps\factory_anim::ambush_anim_setup();

	// Effects
	maps\factory_fx::fx_assembly_setup();

	if ( !level.player.thermal ) {
		Exploder( "assembly_ambient_off_in_thermal" );
	}

	// Setup shootable monitor screens
	level thread ambush_dest_screens();

	// This makes the lasers green
	SetLaserMaterial( "fac_gfx_laser", "fac_gfx_laser_light" );
	
	// Setup the smoke anim archetype
	maps\factory_anim::setup_smoke_archetype();

	// Put smoke reaction script on enemies who fight in the smoke
	smoke_volume = GetEnt( "ambush_smoke_volume", "targetname" );
	array_spawn_function_targetname( "ambush_groundtroops_01", ::enemy_smoke_reaction, smoke_volume );
	array_spawn_function_targetname( "ambush_groundtroops_02", ::enemy_smoke_reaction, smoke_volume );
	array_spawn_function_noteworthy( "ambush_fastropers", ::enemy_smoke_reaction, smoke_volume );

	// Smoke effect on allies
	level.squad[ "ALLY_ALPHA" ] thread ally_smoke_reaction_vision( smoke_volume );
	level.squad[ "ALLY_BRAVO" ] thread ally_smoke_reaction_vision( smoke_volume );
	level.squad[ "ALLY_CHARLIE" ] thread ally_smoke_reaction_vision( smoke_volume );

	// This spawns 2 choppers when you enter the security office
	// They are used in the ambush escape checkpoint, but must be spawned early
	flag_wait( "ambush_escape_spawn_helis" );
	// level thread maps\factory_ambush_escape::spawn_scripted_spotlight_choppers();
}

// Checkpoint dialogue
ambush_dialogue()
{
	flag_wait( "start_ambush_moment" );

	office_volume = GetEnt( "ambush_office_volume", "targetname" );
	while( !level.squad[ "ALLY_ALPHA" ] isTouching( office_volume ))
	{
		wait 0.2;
	}

	// Alpha: "This is it.  Rogers, Rook, grab the data quickly, we need to move"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_grabthedata" );

	flag_set( "enable_ambush_use" );

	flag_wait( "ambush_triggered" );
	
	wait 2.1;
	
	// Alpha: "Overlord, we're pulling the manufacturing data now."
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_overlordwerepullingthe" );

	wait 1.03;
	
	// Bravo: "We got a problem, Rook, are you seeing this?"
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_diz_wegotaproblem" );
	
	wait 0.5;
	
	// Alpha: "What is it?"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_whatisit" );
	
	wait 0.633;
	
	// Bravo: "There's nothing here.  The drives have been wiped!"
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_diz_theresnothingherethe" );
	
	wait 0.3;
	
	// Alpha: "Dammit…"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_dammit" );
	
	wait 0.5;
	
	//Oldboy: Baker!  We've got movement out here!  Lot's of it!  Grab the data and get out of there!
	smart_radio_dialogue( "factory_kgn_wholebattalion" );

	flag_wait( "ambush_vignette_done" );

	wait 1.0;

	// Extra dialog for pinned moment.  Can be skipped if the player leaves the room early.
	level thread ambush_dialogue_pinned_reactions();

	// Wait for dialogue to play out, or for player to advance scene by leaving the office
	flag_wait_any( "ambush_prep_smoke_01", "player_left_ambush_room" );


	//Merrick: OK – we blind ‘em and move! Ready smoke!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_okweblindem" );
	
	wait 0.85;

	//Hesh: Smoke Ready!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_hsh_smokeready" );
	
	//Keegan: Smoke Ready!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_kgn_smokeready" );
	
	//Merrick: Pop smoke!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_popsmoke" );

	wait 1.2;
	
	flag_set( "ambush_smoke_01" );
	level thread ambush_dialogue_flashbangs(); // This is called early in case a player rushes to the trigger

	//Keegan: Smoke out!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_kgn_smokeout_2" );

	//Merrick: Smoke is out!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_mrk_smokeisout" );

	wait 1.4;
	
	// Baker: "Go to thermals!"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_gotothermals" );

	level thread show_thermal_tooltip( true, true );
	level thread thermal_off_tooltip_handler();

	flag_wait( "ambush_thermal_allies_movedup_01" );
	
	// Baker: "Move forward!  Go!"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_totheoffices" );

	wait 1.0;

	// Turn on battlechatter for combat
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	
	// VO to emphasize the push forward
	level thread ambush_thermal_push_dialog();
	level thread ambush_smoke_clear_dialog();

	// Encounter over, stop the music
	flag_wait( "thermal_battle_clear" );
	wait 0.55;
	
	// Rogers: "Clear!"
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_rgs_clear" );
	
	wait 0.25;

	// Keegan: "Clear!"
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_diz_clear2" );
	
	//wait 0.55;
	
	// Baker: "Diaz – we’re almost out! We need exfil!"
	//level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_needexfil" );
	
	//wait 0.1;
	
	// Diaz: "Copy that! We’re securing a vehicle. RV at the parking lot to the South"
	//smart_radio_dialogue( "factory_diz_securingvehicle" );
}

ambush_dialogue_pinned_reactions()
{
	// The scene advances and skips all this if the player leaves the room early
	level endon( "player_left_ambush_room" );
	if( flag( "player_left_ambush_room" ))
	{
		return;
	}

	wait 1.2;

	// Baker: "Rook, stay down!"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_rookstaydown" );

	// Baker: "Hold this position!"
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_holdthisposition" );

	wait 0.8;

	//Merrick: House Main! We are pinned – we need a divert on Arclight!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_housemainweare_2" );

	wait 0.2;

	//Overlord: Negative Jericho – Arclight is 20 klicks out and past PNR - Genesis cannot be diverted.
	smart_radio_dialogue( "factory_hqr_negativejerichoarclightis" );

	wait 0.15;

	//Hesh: Shit! We do not want to be here!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_hsh_shitwedonot" );

	//Keegan: We've got more incoming!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_kgn_wevegotmoreincoming" );

	//Diaz: Make your shots count!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_diz_shotscount" );

	wait 1.1;
	
	// CF - trying out an RPG flying into the room - hits inside back right of room
	//MagicBullet ( "rpg_nodamage", ( 5612, -2311, 300 ), ( 5669, -505, 354 ) );

	//Rogers: RPG!!
	//level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_rgs_rpg" );

	wait 1.5;
	
	//Rogers: They keep coming!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_rgs_keepcoming" );
	
	wait 0.66;

	// CF - trying out an RPG flying into the room - hits outside left of room
	//MagicBullet ( "rpg_straight", ( 4410, -1262, 521 ), ( 5838, -1094, 342) );

	wait 0.8;
	
	//Hesh: We need an exit!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_hsh_weneedanexit" );

	wait 0.4;
	flag_set( "ambush_moment_clear" );
}

// Ally VO for the advance forward
ambush_thermal_push_dialog()
{
	level endon( "ambush_smoke_off_tooltip" ); // Only play these lines untill the flashbangs event

	//Keegan: Two down!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_kgn_twodown" );

	flag_wait( "ambush_progress_flag_1" );
	
	//Keegan: Three more, ekia!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_kgn_threemoreekia" );
	
	wait 2.5;
	
	//Baker: Keep pushing forward!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_keeppushingforward" );
	
	wait 4.1;

	//Hesh: Dropping em!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_hsh_droppingem" );

	wait 4.6;

	//Merrick: Going down!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_mrk_goingdown" );

	wait 2.25;

	//Baker: Don’t stop!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_dontstop" );
}

ambush_smoke_clear_dialog()
{
	level endon( "thermal_battle_clear" );
	flag_wait( "ambush_thermal_flashed" );
	while( level.player isFlashed())
	{
		wait 0.1;
	}
	wait 6.5;

	//Hesh: My thermals are fried!
	level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_hsh_mythermalsarefried" );

	wait 0.2;

	//Keegan: Mine too!
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_kgn_minetoo" );

	//Merrick: Go visors off! Lose the Thermal!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_govisorsofflose" );

	wait 8.0;
	
	//Merrick: Don't stop - we have the advantage!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_dontstopwehave" );
}

ambush_dialogue_flashbangs()
{
	flag_wait( "ambush_smoke_off_tooltip" );

	//Hesh: Flash bang!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_hsh_flashbang" );

	// Baker: Flashbangs, get down!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_flashbangsgetdown" );
}

// Special difficulty settings for ambush grenades
factory_ambush_grenade_params()
{
	level.difficultySettings[ "playerGrenadeBaseTime" ][ "easy" ] = 48000; // default: 40000
	level.difficultySettings[ "playerGrenadeBaseTime" ][ "normal" ] = 42000; // default: 35000
	level.difficultySettings[ "playerGrenadeBaseTime" ][ "hardened" ] = 25000; // default: 25000
	level.difficultySettings[ "playerGrenadeBaseTime" ][ "veteran" ] = 25000; // default: 25000
	
	level.difficultySettings[ "playerGrenadeRangeTime" ][ "easy" ] = 24000; // default: 20000
	level.difficultySettings[ "playerGrenadeRangeTime" ][ "normal" ] = 18000; // default: 15000
	level.difficultySettings[ "playerGrenadeRangeTime" ][ "hardened" ] = 10000;
	level.difficultySettings[ "playerGrenadeRangeTime" ][ "veteran" ] = 10000;

	// No double grenade on normal
	level.difficultySettings[ "double_grenades_allowed" ][ "easy" ] = false;
	level.difficultySettings[ "double_grenades_allowed" ][ "normal" ] = false;
	level.difficultySettings[ "double_grenades_allowed" ][ "hardened" ] = true;
	level.difficultySettings[ "double_grenades_allowed" ][ "veteran" ] = true;
}

//================================================================================================
//	AMBUSH MOMENT
//================================================================================================
ambush_moment_logic()
{
	flag_wait( "entered_pre_ambush_room" );
	maps\factory_util::safe_trigger_by_targetname( level.default_weapon );
	//level.squad[ "ALLY_ALPHA" ] set_generic_idle_anim( "casual_stand_idle" );

	// TEMP FIX GIVE AMMO
	level.player GiveMaxAmmo( level.default_weapon );

	// Send Diaz and Baker to computers
	level.squad[ "ALLY_ALPHA"	]thread maps\factory_anim::ambush_get_on_computer_player_nag(  );
	level.squad[ "ALLY_BRAVO"	]thread maps\factory_anim::ambush_bravo_computer_use		(  );
	level.squad[ "ALLY_CHARLIE" ]thread maps\factory_anim::ambush_charlie_computer_use		(  );
	
	// Save
	autosave_tactical();

	// Wait for player to get close
	flag_wait( "start_ambush_moment" );

	// Delay to allow next move order to process
	wait 0.1;

	// Wait for Baker to get into position
	prev_radius = level.squad[ "ALLY_ALPHA" ].goalradius;
	level.squad[ "ALLY_ALPHA" ].goalradius = 16;
	level.squad[ "ALLY_ALPHA" ] waittill( "goal" );
	level.squad[ "ALLY_ALPHA" ].goalradius = prev_radius;

	thread setup_computer_use_hint();

	// Start some Nag VO
	nag_lines =
	[
		//Merrick: Adam, use the computer.
		//Merrick: Adam, give me a hand.
		//Merrick: Adam, over here.
		"factory_mrk_adamusethecomputer", "factory_mrk_adamgivemea", "factory_mrk_adamoverhere"
	];
	level.squad[ "ALLY_ALPHA" ] thread maps\factory_util::nag_line_generator( nag_lines, "player_used_computer" );

	flag_wait( "player_used_computer" );
	
	//level.player playsound("scn_factory_ambush_door_breach_lr");
	
	// Start the ambush anim
	flag_set( "ambush_triggered" );
	
	// Reset ally idle
	level.squad[ "ALLY_ALPHA" ] clear_generic_idle_anim();

	// TEMP AMMO FIX
	level.player GiveMaxAmmo( level.default_weapon );

	// Close the entrance doors
	level thread maps\factory_util::open_door( "ambush_door_pivot_left", 160, 0.5, true );
	level thread maps\factory_util::open_door( "ambush_door_pivot_right", -145, 0.5, true );

	// Trigger breach slowmo
	thread ambush_slowmo();
	
	// Open the door
	thread breach_door();
	
	// Make all the glass windows break
	thread break_ambush_glass();
	
	// Spawn in the breach enemies
	thread ambush_door_breacher();
	
	// If the player leaves the room early make them a primary target
	thread ambush_leave_room_early();

	//===============
	// Spawn wave 1
	//===============
	thread ambush_groundtroops_01();
	
	level waittill( "ambush_start_fx" );
	// Try to save so the anim can be skipped if they die
	autosave_by_name_silent( "ambush" );
	
	// Make sure the glass pane on the desk is broken
	glass = GetGlass( "desk_glass_panel" );
	DestroyGlass( glass );

	//wait level.ambush_window_breach_delay;
	level waittill( "ambush_glass_break" );
	
	flag_set( "ambush_vignette_done" );

	// Enable player crush for the machines
	level.player thread maps\factory_anim::assembly_line_squash();
	
	thread ambush_fastropers_01();

	// More dangerous for the player
	level.player.threatbias = level.ambush_threat_boost; 

	wait 5.0;

	// Turn off CQB
	level.squad[ "ALLY_ALPHA"	]thread disable_cqbwalk(  );
	level.squad[ "ALLY_BRAVO"	]thread disable_cqbwalk(  );
	level.squad[ "ALLY_CHARLIE" ]thread disable_cqbwalk(  );

	// Turn off grenade reactions so the allies don't run out of the room
	level.squad[ "ALLY_ALPHA"	].grenadeawareness = 0;
	level.squad[ "ALLY_BRAVO"	].grenadeawareness = 0;
	level.squad[ "ALLY_CHARLIE" ].grenadeawareness = 0;
}

setup_computer_use_hint()
{
	flag_wait( "enable_ambush_use" );
	level notify( "show_ambush_use_hint" );

	// Make the keyboard glowy
	kb = GetEnt( "ambush_desk_kb", "targetname" );
	//kb glow();

	// Get the glow monitor and glow device
	monitor = GetEnt( "ambush_monitor_glow", "targetname" );
	device = GetEnt( "ambush_device_glow", "targetname" );

	// Make the monitor glowy
	//monitor show();
	//monitor glow();

	// Make the device glowy
	//device show();
	//device glow();

	// Create the use trigger
	control_panel_trigger = GetEnt( "ambush_console_use", "targetname" );
	control_panel_trigger UseTriggerRequireLookAt();
	control_panel_trigger SetHintString( &"FACTORY_HINT_AMBUSH_TRIGGER" ); //"Press [{+usereload}] to copy data"
	control_panel_trigger trigger_off();

	// Turn the trigger on and off based on where player is standing
	control_panel_trigger thread ambush_use_loop();
	
	// Make sure the thermal anim is not still playing
	while( 1 )
	{
		control_panel_trigger waittill( "trigger" );
		if( level.player.thermal_anim_active )
		{
			continue;
		}
		else if( level.player IsThrowingGrenade() || level.player IsMeleeing() )
		{
			continue;
		}
		else
		{
			break;
		}
		wait 0.1;
	}
	
	flag_set( "player_used_computer" );
	control_panel_trigger Delete();
	kb delete();
	monitor delete();
	device delete();
}

// Turns the use trigger on and off to avoid timing issues
ambush_use_loop( kb )
{
	trigger_on = false;
	vol = GetEnt( "ambush_use_volume", "targetname" );
	room_vol = GetEnt( "ambush_office_volume", "targetname" );
	while( isDefined( self ))
	{
		// Disable if player isnt in the right spot
		if( level.player isTouching( vol ) && !trigger_on )
		{
			self trigger_on();
			trigger_on = true;
		}
		else if( !level.player isTouching( vol ) && trigger_on )
		{
			self trigger_off();
			trigger_on = false;
		}
		
		// Disable the trigger when thermal anim is playing
		if( level.player.thermal_anim_active && trigger_on )
		{
			self trigger_off();
			trigger_on = false;
		}

		// Disable the trigger if all 3 allies arent in the room
		if( !level.squad[ "ALLY_ALPHA"	 ] isTouching(  room_vol ) ||
		  	!level.squad[ "ALLY_BRAVO"	 ] isTouching(  room_vol ) ||
		  	!level.squad[ "ALLY_CHARLIE" ] isTouching(  room_vol ) && trigger_on )
		{
			self trigger_off();
			trigger_on = false;	
		}

		if( level.player IsThrowingGrenade() || level.player IsMeleeing() )
		{
			self trigger_off();
			trigger_on = false;
		}
		
		wait 0.1;
	}
}

// Trigger some breach moment slowmo
ambush_slowmo()
{
	level waittill( "ambush_start_fx" );
	
	//audio - starts the ambience change and calls the breach sound
	thread maps\factory_audio::ambush_battle_start_ambience_change();
	Exploder( "ambush_start_fx" );

	level waittill( "ambush_door_breached" );

	if ( is_gen4() )
	{
		ent = maps\_utility::create_sunflare_setting( "default" );
		ent.position = (13.8701, -144.781, 0);
		maps\_art::sunflare_changes( "default", 0 );
	}

	thread maps\_utility::vision_set_fog_changes( "factory_ambush_breach_explosion", 0 );
	
	wait 0.05;
	
	maps\_art::dof_enable_script( 30, 200, 4, 200, 500, 3, 0.2 );
	thread maps\_utility::vision_set_fog_changes( "factory_ambush_breach_explosion_1", 0.2 );
	
	wait 0.15;
	slowmo_setspeed_slow( 0.15 );
	slowmo_setlerptime_in( 0.2 );
	thread slowmo_lerp_in();

	level.player PlayRumbleOnEntity( "artillery_rumble" );

	wait 0.1;
	thread maps\_utility::vision_set_fog_changes( "factory_ambush_breach_explosion_2", 0.1 );

	wait 0.15;
	thread maps\_utility::vision_set_fog_changes( "factory_ambush_breach_explosion_3", 0.5 );
	
	wait 0.15;
	slowmo_setspeed_slow( 0.3 );
	slowmo_setlerptime_in( 1 );
	thread slowmo_lerp_in();
	
	wait 1;
	thread maps\_utility::vision_set_fog_changes( "factory_ambush_breach", 1.4 );
	maps\_art::dof_disable_script( 1.4 );
	
	wait 0.25;

	//cue the music flag
	flag_set ( "music_ambush_battle" );

	slowmo_setlerptime_out( 2.0 );
	thread slowmo_lerp_out();

	//audio - the end of the slomo sound, going back to real time
	thread maps\factory_audio::sfx_end_slomo_sound();
	thread maps\factory_audio::sfx_ambush_alarm_sound();
}

// Ambush room door gets breached
breach_door()
{
	level waittill( "ambush_start_fx" );
	
	door_connector = GetEnt( "ambush_breach_door_connector", "targetname" );
	door_connector ConnectPaths();
	door_connector NotSolid();
	door_connector Delete();

	// Slight delay needed to allow the exploding door anim to start
	wait 0.2;
	Exploder( "ambush_door_exploder" );
	
	wait 0.5;
	Exploder( "ambush_door_exploder_sparks" );
	
	level waittill ( "ambush_glass_break" );
	wait 1.2;
	Exploder( "ambush_door_exploder_strobe" );
}

// Shatter the glass on the ambush room and skylights
break_ambush_glass()
{
	level waittill( "ambush_glass_break" );

	// Remove the bulletproof glass
	ambush_glass_bp = GetEntArray( "ambush_room_window_glass_bp", "targetname" );
	foreach ( glass in ambush_glass_bp )
	{
		glass NotSolid();
		glass Hide();
	}
	
	// Show and break the func_glass
	maps\factory_util::break_glass( "ambush_room_window_glass_right" , ( 1, 0, 0 ) );
	maps\factory_util::break_glass( "ambush_room_window_glass_angled" , ( 1, 0, 0 ) );
	
	// Wait for the move up command
	flag_wait( "ambush_thermal_allies_movedup_01" );
	
	// Turn on the window traversals
	foreach ( glass in ambush_glass_bp )
	{
		glass ConnectPaths();
	}
}

// Spawn the ambush door breacher
ambush_door_breacher()
{
	level waittill( "ambush_door_breached" );
	wait 0.45;
	
	// Spawn door breach guy
	door_breach_guy_spawner			 = GetEnt( "door_breach_guy", "targetname" );
	door_breach_guy					 = door_breach_guy_spawner spawn_ai ( 1 );
	door_breach_guy.animname		 = "generic";
	door_breach_guy.dontmelee		 = 1;
	door_breach_guy.fixednode		 = 1;
	door_breach_guy.goalradius		 = 0;
	door_breach_guy.attackeraccuracy = 3;
	door_breach_guy.favoriteenemy	 = level.player;
	door_breach_guy.ignoreme		 = true;
	door_breach_guy.threatBias		 = 5000;
	//door_breach_guy SetLookAtEntity( level.player );
	door_breach_guy enable_cqbwalk();

	door_breach_guy delayThread( 4, maps\factory_util::factory_set_ignoreme, false );

	// Spawn some extra breach enemies
	spawners = GetEntArray( "ambush_window_breacher_extra", "targetname" );
	foreach( spawner in spawners )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			continue;
		}
		guy.dontmelee = 1;
		guy.fixednode = 1;
		guy.goalradius = 0;
		guy.attackeraccuracy = 2.0;
		guy.ignoreme = true;
		//guy enable_cqbwalk();
		guy delayThread( randomFloatRange( 6, 8 ), maps\factory_util::factory_set_ignoreme, false );
	}
}

// If the player leaves the room early crank up the danger
ambush_leave_room_early()
{
	// Note this script cant have an endon because it sets player threat
	// and accuracy stuff on enemies.  It needs to reset the values before returning

	flag_wait( "player_left_ambush_room" );
	flag_set( "ambush_moment_clear" );
	flag_set( "ambush_thermal_allies_movedup_01" );
	flag_set( "walking_cough_guy_done" );
	orig_acc = level.player.attackeraccuracy;
	
	break_loop = false;
	while( !break_loop )
	{
		array_thread( getaiarray( "axis" ), ::set_favoriteenemy, level.player );
		level.player.threatbias = 10000;
		level.player set_player_attacker_accuracy( 4.0 );

		if( flag( "ambush_smoke_01" ) || flag( "thermal_battle_clear" ) || flag( "ambush_thermal_flashed" ) )
		{
			break_loop = true;
		}

		wait 0.25;
	}

	// Set things back to normal
	level.player.threatbias = level.ambush_threat_boost;
	level.player set_player_attacker_accuracy( orig_acc );
}

// Spawns fast roper enemies from the roof
ambush_fastropers_01()
{
	// Break glass
	maps\factory_util::break_glass( "ambush_glass_ropers_1", ( 0, 0, -1 ) );

	level.ambush_fast_ropers_mid									  = [];
	level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_1", undefined, false, 0, 0.75 );
	level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_2", undefined, false, 0, 0.75 );
	//level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_3", undefined, false, 0, 0.75 );
	level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_4", undefined, false, 0, 0.75 );
	//level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_5", undefined, false, 0, 0.75 );
	level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_6", undefined, false, 3, 4 );
	//level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_7", undefined, false, 3, 4 );
	//level.ambush_fast_ropers_mid[ level.ambush_fast_ropers_mid.size ] = ambush_fastrope( "ambush_fastroper_mid_8", undefined, false, 3, 4 );
	
	//level.ambush_fast_ropers_mid_dead_count = 0;
	//array_thread( level.ambush_fast_ropers_mid, ::ropers_mid_death_count );

	//level.ambush_fast_ropers_far_dead_count = 0;
	//array_thread( level.ambush_fast_ropers_far, ::ropers_far_death_count );
}

// Spawn and animate a fast roper
ambush_fastrope( guy_targetname, node_targetname, Kill, min_delay, max_delay )
{
	guy		   = GetEnt( guy_targetname, "targetname" );
	fast_roper = guy spawn_ai( true, false );

	// Safety
	if( spawn_failed( fast_roper ))
	{
		//iprintln( "ambush_fastrope failed to spawn guy with targetname: " + guy_targetname );
		return;
	}

	if ( !IsDefined( node_targetname ) )
	{
		node_targetname = ( guy_targetname + "_node" );
	}
	else
	{
		node_targetname = ( node_targetname + "_node" );
	}

	// Play the anim
	fast_roper thread maps\factory_anim::ambush_fastrope_do_anim( node_targetname, Kill, min_delay, max_delay );
	return fast_roper;
}

// Spawns lots of enemies from ground level
ambush_groundtroops_01()
{
	// Spawn these guys 2 seconds before the window breach occurs
	// This gives the enemies time to run up into position
	//wait level.ambush_window_breach_delay - 2;
	level waittill( "ambush_door_breached" );
	
	// Spawn the groundtroop
	maps\factory_util::safe_trigger_by_noteworthy( "ambush_groundtroops_01_trigger" );
	
	// Enemies fall back a little when smoke pops
	flag_wait( "ambush_smoke_01" );

	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_01_far_killspawner" );

	flag_wait( "ambush_thermal_allies_movedup_01" );

	/*
	// Make all enemies fallback when smoke pops
	enemies = getaiarray( "axis" );
	thread maps\factory_util::safe_set_goal_volume( enemies, "ambush_back_half_volume" );
	wave_1_spawners = GetEntArray( "ambush_groundtroops_01", "targetname" );
	foreach( spawner in wave_1_spawners )
	{
		spawner.script_goalvolume = "ambush_back_half_volume";
	}
	*/
	          
	// Trigger killspawner for ambush enemies wave 1
	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_01_killspawner" );
}

// Allow the monitor screens to dissapear when shot
// Basically a crappy destructible
ambush_dest_screens()
{
	screens = GetEntArray( "ambush_tv_screen", "script_noteworthy" );
	foreach( screen in screens )
	{
		screen thread ambush_dest_screen();
	}
}

// Hide the screen when shot
ambush_dest_screen()
{
	self SetCanDamage( true );
	self waittill( "damage" );
	self Hide();
	self NotSolid();
}

//================================================================================================
// THERMAL BATTLE
//================================================================================================
thermal_battle_logic()
{
	flag_wait( "ambush_moment_clear" );

	// Start the smoke throw scene
	flag_set( "ambush_prep_smoke_01" );
	thread ambush_allies_throw_smoke();
	thread ambush_thermal_off_flashbangs();

	// Wait for the dialogue to play
	flag_wait( "ambush_smoke_01" );
	thread maps\factory_fx::fx_ambush_spawn_assembly_smoke();

	// Make play specific smoke reaction anims
	thread maps\factory_anim::force_smoke_reaction_anims();

	wait 1.0;
	
	// Attempt a save
	autosave_by_name_silent( "ambush" );

	// Apply smoke accuracy penalty to enemies
	thread ambush_smoke_penalty();
	
	// Make enemies close to player more aggressive
	//thread ambush_smoke_close_enemies();

	// Allow combat in thermal for a while, or untill player leaves the room
	level thread thermal_battle_elongate();
	
	// Smoke is active, move allies up and out of the room
	flag_wait_any( "ambush_thermal_allies_movedup_01", "player_left_ambush_room" );
	
	// Dont let allies run out untill the walking cough anim is over
	flag_wait( "walking_cough_guy_done" );

	// Allies had no react for a short period after the smoke toss - set them back to normal
	foreach( ally in level.squad )
	{
		ally StopAnimScripted();
		ally maps\factory_util::enable_awareness();
		ally enable_ai_color();
		ally.useChokePoints = true;
		ally PushPlayer( false ); // No pushing in combat
	}
	waittillframeend;

	// Slight delay for the cough anims to play out before moving allies up
	wait 3.0;

	// Allies move up to next position
	maps\factory_util::safe_trigger_by_targetname( "ambush_allies_move_up" );

	// More aggressive movement for this advance
	array_thread( level.squad, ::ally_start_aggressive_advance );

	thread ambush_riotshield_smoke();

	// Clean up far guys so player isnt pulled in 2 directions
	thread wait_and_kill_guys_in_volume( 2, "ambush_far_kill_volume" );
	
	wait 3.0;
	
	//Merrick: Clean house! We need to move!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_cleanhouseweneed" );
	
	//===============
	// Spawn wave 2
	//===============
	thread ambush_groundtroops_02();
	
	// Handle allie movement down the 2 lanes
	thread ambush_allies_move_down_lanes();

	wait 5;
	
	flag_wait_any( "ambush_progress_flag_1", "ambush_groundtroops_02_clear" );
	level.player GiveMaxAmmo( level.default_weapon );

	// Create a badplace to prevent enemies from looping around and backstabbing you
	badplace = GetEnt( "assembly_lanes_backstab_prevention", "targetname" );
	BadPlace_Brush( "assembly_lane_backstab_preventer", 0, badplace, "axis" );

	wait 3.0;
	
	// Cleanup the left room
	thread ambush_cleanup_left_room();

	// More saves
	autosave_by_name_silent( "ambush" );
	
	//===============
	// Spawn wave 3
	//===============
	maps\factory_util::safe_trigger_by_noteworthy( "ambush_groundtroops_03_trigger" );
	
	// Third wave of riot shield guys
	thread ambush_riotshield_back();

	thread ambush_set_lower_back_clear();

	// Wait for enough of wave 3 to die, or if the player runs ahead
	thread ambush_wave_03_killcounter();
	flag_wait_any( "ambush_wave_3_done", "ambush_player_approaching_mezzanine" );

	// Move allies up, but only if the area is clear of riotshielders
	thread ambush_allies_move_up_stairs();
	
	// Try to save
	autosave_by_name_silent( "ambush" );

	//===============
	// Spawn wave 4
	//===============
	flag_wait_any( "ambush_player_on_mezzanine_right", "ambush_player_on_mezzanine_left" );

	// Kill downstairs wave 3 spawners and cleanup guys
	thread wait_and_kill_guys_in_volume( 0.5, "ambush_back_corner_lower" );

	if( flag( "ambush_player_on_mezzanine_left" ))
	{
		thread ambush_wave_4_left_path();
	}
	else
	{
		thread ambush_wave_4_right_path();
	}

	// When only 2 enemies are left, move allies up, and make the enemies expose themselves
	waittill_aigroupcount( "ambush_groundtroops_04", 2 );
	maps\factory_util::safe_trigger_by_targetname( "ambush_sec_office_allies_postup" );
	guys = get_ai_group_ai( "ambush_groundtroops_04" );
	foreach( guy in guys )
	{
		guy thread maps\factory_util::playerseek();
		guy.aggressivemode = true;
	}
	
	// Wait for all enemies to be dead
	flag_wait( "ambush_groundtroops_04_clear" );

	// Move allies to office
	maps\factory_util::safe_trigger_by_targetname( "ambush_escape_allies_goto_office" );

	// Thermal battle done
	flag_set( "thermal_battle_clear" );
}

// Show allies throwing the smoke grenades
ambush_allies_throw_smoke()
{
	// Lower player threat bias a little so they dont get killed while watching the anims
	level.player.threatbias = -1000;
	
	level.squad[ "ALLY_ALPHA"	] thread maps\factory_anim::ambush_ally_throw_smoke( "throw_smoke_node_03", "alpha_smoke_throw_node", "pop_smoke_ally01", undefined, 4 );
	level.squad[ "ALLY_BRAVO"	] thread maps\factory_anim::ambush_ally_throw_smoke( "throw_smoke_node_02", "ambush_anim_node", "pop_smoke_ally02", undefined, 2.5, "pop_smoke_enter_ally02" );
	level.squad[ "ALLY_CHARLIE"	] thread maps\factory_anim::ambush_ally_throw_smoke( "throw_smoke_node_01", "ambush_anim_node", "pop_smoke_ally03", undefined, 2.0, "pop_smoke_enter_ally03" );
}

// Fight in thermal
thermal_battle_elongate()
{
	// Fight through smoke for a while
	wait 8;
	flag_set( "ambush_thermal_allies_movedup_01" );
}

// Clean up the enemies and spawners in the left room
ambush_cleanup_left_room()
{
	// Kill spawners in room
	maps\factory_util::safe_trigger_by_targetname( "ambush_left_room_killspawner" );

	// Kill guys in room
	thread wait_and_kill_guys_in_volume( 0, "left_room_cleanup_vol" );
}

// Spawn wave 2
ambush_groundtroops_02()
{
	maps\factory_util::safe_trigger_by_noteworthy( "ambush_groundtroops_02_trigger" );

	waittill_aigroupcount( "ambush_groundtroops_02", 3 );
	flag_set( "ambush_groundtroops_02_clear" );
}

ambush_allies_move_down_lanes()
{
	flag_wait( "ambush_allies_move_down_lanes" );
	flag_wait( "ambush_riotshield_smoke_clear" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_allies_move_down_lanes" );

	flag_wait( "ambush_corner_allies_push" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_corner_allies_push" );

	// More aggressive movement for this advance
	array_thread( level.squad, ::ally_start_aggressive_advance );
}

ambush_set_lower_back_clear()
{
	level endon( "ambush_lower_back_clear" );
	level endon( "thermal_battle_clear" );

	vol = GetEnt( "ambush_back_corner_lower", "targetname" );
	guys = [];
	while( 1 )
	{
		guys = vol get_ai_touching_volume( "axis" );
		shield_count = get_ai_group_count( "riotshield_back" );

		// If the player is defensive and stays way back, make sure he gets flashed
		if( !flag( "ambush_smoke_off_tooltip" ) && ( shield_count < 2 || guys.size < 4 ))
		{
			flag_set( "ambush_smoke_off_tooltip" );
		}

		// Back area is clear when 0 riot shield guys are alive,
		// and 2 or less normal guys are alive
		if( guys.size <= 2 && shield_count < 1 )
		{
			flag_set( "ambush_lower_back_clear" );
			return;
		}
		wait 0.2;
	}
}

ambush_allies_move_up_stairs()
{
	flag_wait_any( "ambush_lower_back_clear", "ambush_player_on_mezzanine_right", "ambush_player_on_mezzanine_left" );
	flag_set( "ambush_lower_back_clear" );

	// Delete previous color trigger, incase the back corner gets cleared early
	maps\factory_util::safe_delete_targetname( "ambush_corner_allies_push" );

	// Move allies up
	maps\factory_util::safe_trigger_by_targetname( "ambush_back_corner_allies_push" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_03_killspawner" );
	
	// Stop the music
	delayThread( 3.0, ::flag_set, "music_ambush_battle_ends" );

	wait 2.2;
	// Baker: Up the stairs!
	level.squad[ "ALLY_ALPHA" ] thread smart_dialogue( "factory_bkr_upthestairs" );
}

// Remaining guys fall back a little to allow allies to move up
ambush_groundtroops_02_fallback()
{
	bad_vol = GetEnt( "ambush_groundtroops_02_cleanup_a", "targetname" );
	enemies = bad_vol get_ai_touching_volume( "axis" );
	thread maps\factory_util::safe_set_goal_volume( enemies, "ambush_groundtroops_02_cleanup_b" );
}

ambush_wave_03_killcounter()
{
	waittill_aigroupcount( "ambush_wave_03", 3 );

	// Another wave
	maps\factory_util::safe_trigger_by_noteworthy( "ambush_groundtroops_035_trigger" );

	waittill_aigroupcount( "ambush_wave_035", 2 );
	waittill_aigroupcount( "ambush_wave_03", 1 );

	// Kill any remaining spawners
	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_03_killspawner" );
	
	// Make leftover guys run out
	volume = GetEnt( "ambush_back_corner_volume", "targetname" );
	enemies = volume get_ai_touching_volume( "axis" );
	array_thread( enemies, maps\factory_util::playerseek );
	
	wait 2.0;
	flag_set( "ambush_wave_3_done" );

	// triggering VFX of some stuff blowing up and fx for next top room
	//IPrintLnBold( "trig fx - ambush_wave_3_done" );
	flag_set( "ambush_expl_03" );

}

// Final wave - left stairs
ambush_wave_4_left_path()
{
	// Push allies towards security office
	maps\factory_util::safe_trigger_by_targetname( "ambush_sec_office_allies_push" );

	maps\factory_util::safe_trigger_by_noteworthy( "ambush_groundtroops_04_trigger" );
}

// Final wave - right stairs
ambush_wave_4_right_path()
{
	// Move allies up farther
	maps\factory_util::safe_trigger_by_targetname( "ambush_back_corner_allies_right_path" );
	
	// Reset spawners target node for alternate location
	spawners = GetEntArray( "ambush_groundtroops_04", "targetname" );
	foreach( spawner in spawners )
	{
		if( isDefined( spawner.script_parameters ))
		{
			spawner.target = spawner.script_parameters;
		}
	}
	
	// Trigger the spawn
	maps\factory_util::safe_trigger_by_noteworthy( "ambush_groundtroops_04_trigger" );
}

// Toss flashbangs to make the player turn off thermal
ambush_thermal_off_flashbangs()
{
	flag_wait( "ambush_smoke_off_tooltip" );

	wait 2.2;

	// Get the start nodes
	start_nodes = GetEntArray( "flash_node_start", "targetname" );
	
	foreach( i, start_node in start_nodes )
	{
		target_node = GetEnt( start_node.target, "targetname" );
		thread wait_and_flashbang( start_node, target_node );
	}
	
	level.player thread ambush_thermal_player_flash();
	flag_set( "ambush_stop_smoke" );
	
	// Lengthen grenade timer a little so player isn't grenaded while flashed ( cheap death )
	level.player.grenadeTimers[ "fraggrenade" ] += randomIntRange( 6000, 12000 );
	anim.grenadeTimers[ "AI_fraggrenade" ] += randomIntRange( 6000, 12000 );
	
	// triggering VFX of some stuff blowing up
	flag_set( "ambush_expl_01" );
	wait 9;
	thread maps\factory_audio::sfx_explo_after_flashbang();
	flag_set( "ambush_expl_02" );
	RadiusDamage( ( 5378, -2197, 262 ), 200, 400, 100 );

	//thread maps\factory_audio::ambush_start_fx_sounds();
}

wait_and_flashbang( org, targ )
{
	wait RandomFloatRange( 0, 0.25 );
	g = MagicGrenade( "flash_grenade", org.origin, targ.origin, 2.5 );
	
	if( isDefined( g ))
	{
		g waittill( "death" );
		level.player notify( "flashed" );
	}
}

// Grace period
ambush_thermal_player_flash()
{
	level endon( "thermal_battle_clear" );
	self waittill_any( "flashbang", "flashed" );
	flag_set( "ambush_thermal_flashed" );
	self StopShellShock();
	self ShellShock( "flashbang", 2.5 );

	// Swap to malfunctioning robot arm while flashed
	flag_set( "ambush_arm_malfunction" );
	
	self EnableHealthShield( true );
	self.threatbias = -2000;
	wait 7.0;

	self EnableHealthShield( false );
	wait 5.0;

	self.threatbias = -750;
	wait 5.0;

	self.threatbias = level.ambush_threat_boost;
}

// Spawn 4 riotshield guys that block the lanes
ambush_riotshield_smoke()
{
	riot_spawners = GetEntArray( "ambush_riotshield_02", "targetname" );
	guys = [];
	foreach( spawner in riot_spawners )
	{
		guy = spawner spawn_ai( true );
		guy.destination = GetEnt( spawner.target, "targetname" );
		// TEMP FIX BY CF TO LOWER HEALTH - TOO HARD RIGHT NOW - CHAD
		guy.health = 100;
		guys[guys.size] = guy;
	}
	waittillframeend;

	// Make them move up - riotshielders dont use nodes the same way normal AI do
	foreach( guy in guys )
	{
		if( isAlive( guy ) && isDefined( guy.destination ))
		{
			guy.goalradius = 16;
			guy SetGoalPos( guy.destination.origin );
		}
	}

	// If the player pushes in far enough, cleanup any remaining riotshield guys
	msg = flag_wait_any_return( "riotshield_cleanup_left", "riotshield_cleanup_right" );

	// If player clears one lane, cleanup other lane
	if( msg == "riotshield_cleanup_left" )
	{
		guys = get_ai_group_ai( "riotshield_right" );
	}
	else
	{
		guys = get_ai_group_ai( "riotshield_left" );
	}

	foreach( guy in guys )
	{
		guy thread kill_after_time( 1, 3 );
	}
}

// Spawn a group of riot shield guys to block off the back area
ambush_riotshield_back()
{
	riot_spawners = GetEntArray( "ambush_riotshield_03", "targetname" );
	guys = [];
	foreach( spawner in riot_spawners )
	{
		guy = spawner spawn_ai();
		if( !spawn_failed( guy ))
		{
			guy.fixednode = true;
			// TEMP FIX BY CF TO LOWER HEALTH - TOO HARD RIGHT NOW - CHAD
			guy.health = 100;
			guys[guys.size] = guy;
		}
	}

	thread ambush_riotshield_back_cleanup( guys );
	
	// Auto kill the last riotshielder after a while
	waittill_aigroupcount( "riotshield_back", 1 );

	// JR - Should this only trigger for EASY and NORMAL?
	foreach( guy in guys )
	{
		guy thread kill_after_time( 12 );
	}
}

// Cleanup if the player rushes..
ambush_riotshield_back_cleanup( guys )
{
	// Reduce their health if the player rushes
	flag_wait_any( "ambush_player_on_mezzanine_right", "ambush_player_on_mezzanine_left" );

	foreach( guy in guys )
	{
		if( isDefined( guy ) && isAlive( guy ))
		{
			// Low health so allies kill them quickly
			guy.health = 1;

			// Auto kill them anyway if they dont get shot
			guy thread kill_after_time( 20 );
		}
	}
}


//================================================================================================
// MISC.
//================================================================================================
// Tooltip hint display
show_thermal_tooltip( on, short )
{
	level endon( "thermal_battle_clear" );

	// Choose the string
	if( isDefined( on ) && on == true )
	{
		level.show_thermal_hint = true;
		if( isDefined( short ))
		{
			hint_string = "HINT_THERMAL_SHORT";
			level.trigger_hint_func[ "HINT_THERMAL_SHORT" ] = ::thermal_hint_func_on;
		}
		else
		{
			hint_string = "HINT_THERMAL";
		}
	}
	else
	{
		level.show_thermal_off_hint = true;
		if( isDefined( short ))
		{
			hint_string = "HINT_THERMAL_OFF_SHORT";
			level.trigger_hint_func[ "HINT_THERMAL_OFF_SHORT" ] = ::thermal_hint_func_off;
		}
		else
		{
			hint_string = "HINT_THERMAL_OFF";
		}
	}

	// Show the hint
	level.player thread display_hint( hint_string );

	// Let the hint time out
	wait 10;
	level.show_thermal_hint = false;
	level.show_thermal_off_hint = false;
	//level notify( "stop_showing_thermal_hint" );
}

// If true, DONT display hint
thermal_hint_func_on()
{
	return level.player.thermal;
}

// If false, DONT display hint
thermal_hint_func_off()
{
	return !(level.player.thermal);
}

// Handles turning off the thermal ON tooltip
hint_thermal_timeout()
{
	if ( !level.show_thermal_hint )
	{
		return true;
	}
	return false;
}

// Handles turning off the thermal OFF tooltip
hint_thermal_off_timeout()
{
	if ( !level.show_thermal_off_hint )
	{
		return true;
	}
	return false;
}

// Dislpay the thermal off tooltip when leaving smoke
thermal_off_tooltip_handler()
{
	flag_wait( "ambush_thermal_flashed" );
	wait 0.5;
	level thread show_thermal_tooltip( false, true );
}

// Reduce attacker accuracy while in smoke
ambush_smoke_penalty()
{
	level endon( "stop_smoke_penalty" );

	smoke_vol = GetEnt( "ambush_smoke_volume", "targetname" );
	room_vol  = GetEnt( "ambush_cleanup_volume", "targetname" );
	end_flag  = "ambush_stop_smoke";
	player_original_maxvisibledist = level.player.maxvisibledist;
	original_attacker_accuracy = level.player.attackeraccuracy;

	while( 1 )
	{
		// Handle player
		if( isDefined( smoke_vol ) && level.player IsTouching( smoke_vol ))
		{
			level.player.threatbias = -300;
			level.player.maxvisibledist = 475;
			level.player.attackeraccuracy = 0.15; // <- Controls difficulty while in smoke
		}
		else
		{
			level.player.threatbias = level.ambush_threat_boost;
			level.player.ignoreme = false;
			level.player.maxvisibledist = player_original_maxvisibledist;
			level.player.attackeraccuracy = original_attacker_accuracy;
		}

		// Handle enemies
		enemies = room_vol get_ai_touching_volume( "axis" );
		foreach( enemy in enemies )
		{
			// Save their original accuracy
			if( !isDefined( enemy.ambush_original_accuracy ))
			{
				enemy.ambush_original_accuracy = enemy.script_accuracy;
			}

			// Reduce the accuracy if in smoke
			if( isDefined( smoke_vol ) && enemy IsTouching( smoke_vol ))
			{
				enemy.script_accuracy = 0.08;
			}
			// Restore accuracy when out of smoke
			else
			{
				enemy.script_accuracy = enemy.ambush_original_accuracy;
			}
		}

		// Exit condition
		if( flag( end_flag ) && isDefined ( smoke_vol ))
		{
			smoke_vol delete();

			// Kill this script in 5 seconds
			delayThread( 5, ::flag_set, "stop_smoke_penalty" );
		}

		wait 0.25;
	}
}

// Enemies randomly cant see and play confused anims while in smoke
enemy_smoke_reaction( volume )
{
	// Turn on CQB so they walk carefully while in smoke
	self enable_cqbwalk();

	self thread enemy_smoke_reaction_vision( volume );
	self thread enemy_smoke_reaction_anim( volume );
}

// Enemy cant see in smoke
enemy_smoke_reaction_vision( volume )
{
	self endon( "death" );
	flag_wait( "ambush_smoke_01" );
	original_maxsightdist = self.maxsightdistsqrd;

	while( 1 )
	{
		wait RandomFloatRange( 0.25, 1.5 );

		// Exit condition if the smoke goes away
		if( !IsDefined( volume ))
		{
			return;
		}

		// Do random flashbang
		if( self IsTouching( volume ))
		{
			self.maxsightdistsqrd = 64*64;
			wait randomfloatrange( 1.0, 4.0 );
			self.maxsightdistsqrd = original_maxsightdist;
		}
	}
}

// Enemy gets confused in smoke
enemy_smoke_reaction_anim( volume )
{
	self endon( "death" );
	level endon( "ambush_stop_smoke" );
	flag_wait( "ambush_smoke_01" );

	// Turn on the anim archetype
	self.animArchetype = "factory_smoke";

	while( 1 )
	{
		wait RandomFloatRange( 1.5, 3.0 );

		// Exit condition if the smoke goes away
		if( !IsDefined( volume ))
		{
			return;
		}

		// Do random smoke reaction animation
		if( self IsTouching( volume ) && !isDefined( self.smoke_immune ))
		{
			if( isDefined( self.node ))
			{
				self.animname = "generic";
				self.allowdeath = true;
				self.claimed_node = self.node;
				self.keepClaimedNode = true;

				switch( self.script )
				{
					case "cover_crouch":
						anim_single_solo( self, random( [ "factory_ambush_smoke_CornerCr_01", "factory_ambush_smoke_CornerCr_02" ] ));
						break;
					case "cover_right":
						anim_single_solo( self, random( [ "factory_ambush_smoke_CornerCrR_01", "factory_ambush_smoke_CornerCrR_02", "factory_ambush_smoke_CornerCrR_03" ] ));
						break;
					case "cover_left":
						anim_single_solo( self, random( [ "factory_ambush_smoke_CornerCrL_01", "factory_ambush_smoke_CornerCrL_02", "factory_ambush_smoke_CornerCrL_03" ] ));
						break;
					case "cover_stand":
						//anim_single_solo( self, random( [ "factory_ambush_smoke_stand_01", "factory_ambush_smoke_stand_02", /*"factory_ambush_smoke_stand_03"*/ ] ));
						anim_single_solo( self, random( [ "factory_ambush_smoke_stand_01", "factory_ambush_smoke_stand_02" ] ));
						break;
				}
				self.keepClaimedNode = false;
			}
		}
	}
}

// Enemies cant see ally in smoke
ally_smoke_reaction_vision( volume )
{
	self endon( "death" );
	flag_wait( "ambush_smoke_01" );
	original_maxvisibledist = self.maxvisibledist;

	while( 1 )
	{
		wait RandomFloatRange( 1.0, 3.0 );

		// Safety check everything
		if( !isDefined( self ) || !isAlive( self ))
		{
			return;
		}

		// Exit condition if the smoke goes away
		if( !IsDefined( volume ))
		{
			self.ignoreme = false;
			self.maxvisibledist = original_maxvisibledist;
			return;
		}

		// Do random flashbang
		if( self IsTouching( volume ))
		{
			self.maxvisibledist = 256;
			wait randomfloatrange( 1.0, 3.0 );
			if( !isDefined( self ) || !isAlive( self ))
			{
				self.maxvisibledist = original_maxvisibledist;
			}
		}
	}
}

// Make the closest enemies to player more aggressive
ambush_smoke_close_enemies()
{
	flag_wait( "player_left_ambush_room" );
	
	while( !flag( "ambush_stop_smoke") )
	{
		// Get nearest enemies
		guy = get_closest_ai( level.player.origin, "axis" );
		if( IsAlive( guy ) && players_within_distance( 512, guy.origin ))
		{
			guy thread player_seek();
			guy thread set_favoriteenemy( level.player );
			guy.dontEverShoot = true;
			guy.smoke_immune = true;
			guy.maxvisibledist = 128;
			
			guy waittill_any_timeout( 10, "death" );
		}
		wait 1;
	}
}

// Kills an actor after an amount of time
kill_after_time( min, max )
{
	self endon( "death" );
	
	if ( IsDefined( max ) )
	{
		wait RandomFloatRange( min, max );
	}
	else
	{
		wait min;
	}
	
	if ( IsDefined( self ) && IsAI( self ) && IsAlive( self ) )
	{
		self Kill();
	}
}

// Kills off any leftover wave 1 guys
wait_and_kill_guys_in_volume( wait_time, volume_targetname )
{
	if ( wait_time > 0 )
	{
		wait wait_time;
	}

	volume	= GetEnt( volume_targetname, "targetname" );
	enemies = volume get_ai_touching_volume( "axis" );
	
	foreach ( guy in enemies )
	{
		guy thread kill_after_time( 0.0, 3.0 );
	}
}

// Makes some fans spin slowly
ambush_fan_spin( fan )
{
	level endon ( "stop_assembly_line" );
	while ( 1 )
	{
		// Safety check
		if( !isDefined( self ))
		{
			return;
		}

		self RotatePitch ( 360, 12 );
		wait 12;
	}
}

// Make sure the AI get to their goal even when under heavy fire
ally_start_aggressive_advance()
{
	// Safety check
	if( !isDefined( self ) || !IsSentient( self ) || !isAlive ( self ))
	{
		return;
	}

	old_radius = self.goalradius;
	self.goalradius = 4;

	self.ignoreall = true;
	self.ignoreSuppression = true;
	self.IgnoreRandomBulletDamage = true;
	self disable_bulletwhizbyreaction();
	self disable_pain();
	self disable_danger_react();
	self.grenadeawareness = 0;

	self waittill( "goal" );

	self.goalradius = old_radius;
	self ally_end_aggressive_advance();
}

ally_end_aggressive_advance()
{
	// Safety check
	if( !isDefined( self ) || !IsSentient( self ) || !isAlive ( self ))
	{
		return;
	}

	//self.awareness = 1;
	self.ignoreall = false;
	self.ignoreSuppression = false;
	self.IgnoreRandomBulletDamage = false;
	self enable_bulletwhizbyreaction();
	self enable_pain();
	//self enable_danger_react( 8 );
	self.grenadeawareness = 1;
}


//================================================================================================
// CLEANUP
//================================================================================================
ambush_cleanup( force_cleanup )
{
	if( !isDefined( force_cleanup ))
	{
		// Kill any remaining enemies in the room
		cleanup_volume = GetEnt( "ambush_cleanup_volume", "targetname" );
		enemies		   = cleanup_volume get_ai_touching_volume( "axis" );
		foreach ( guy in enemies )
		{
			if ( IsDefined( guy ) && IsAI( guy ) && guy.team == "axis" )
			{
				guy Kill();
			}
		}
	}

	// Make certain these flags get set
	flag_set( "ambush_smoke_01" );
	flag_set( "thermal_battle_clear" );
	flag_set( "ambush_thermal_flashed" );
	
	// Shut off all spawners
	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_01_killspawner" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_02_killspawner" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_03_killspawner" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_groundtroops_04_killspawner" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_fastropers_killspawner" );
	
	// Clean up spawners
	maps\factory_util::safe_delete_noteworthy( "ambush_fastropers" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_01" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_02" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_03" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_035" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_04" );
	maps\factory_util::safe_delete_targetname( "ambush_riotshield_01" );
	maps\factory_util::safe_delete_targetname( "ambush_riotshield_02" );
	maps\factory_util::safe_delete_targetname( "ambush_riotshield_03" );
	maps\factory_util::safe_delete_targetname( "ambush_window_breacher_extra" );
	maps\factory_util::safe_delete_targetname( "ambush_window_breacher_extra" );
	
	// Cleanup any leftover triggers
	maps\factory_util::safe_delete_targetname( "ambush_trigger_cleanup" );
	maps\factory_util::safe_delete_noteworthy( "ambush_groundtroops_02_trigger" );
	maps\factory_util::safe_delete_noteworthy( "ambush_groundtroops_04_trigger" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_02_killspawner" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_03_killspawner" );
	maps\factory_util::safe_delete_targetname( "ambush_groundtroops_04_killspawner" );
	
	// Cleanup misc triggers, and nodes
	maps\factory_util::safe_delete_linkname( "ambush_cleanup_object" );

	if( !isDefined( force_cleanup ))
	{
		// Cleanup badplace
		BadPlace_Delete( "assembly_lane_backstab_preventer" );
	
		// Turn battlechatter back off
		battlechatter_off();
	
		foreach ( ally in level.squad )
		{
			ally notify( "cleanup_grenade_throw" );
			//ally.fixednodesaferadius = 128;
			ally.suppressionwait = 3000; // Default
			ally.script_accuracy = 1.0; // Default
			ally.useChokePoints = true;
		}
	
		// Reset threatbias & accuracy
		level.player.threatbias = 0;
		level.player.attackeraccuracy = 1.0;
		level.player.maxvisibledist = 8192;
		
		// Reset difficulty modifications
		clear_custom_gameskill_func();
	}

	// Cleanup all assembly line anim models at some later point
	level thread maps\factory_anim::factory_assembly_line_cleanup( force_cleanup );
}

//================================================================================================
// Moving Objects
//================================================================================================
// Attaches a free mover prefab to self
attach_mover_prefab()
{
	if ( !IsDefined( level.mover_prefabs ) )
	{
		create_ambush_mover_prefabs();
	}
	
	// Get first available mover prefab in list
	for ( i = 0; i < level.mover_prefabs.size; i++ )
	{
		if ( level.mover_prefabs[ i ].in_use == false )
		{
			// Link the prefab to the anim model
			level.mover_prefabs[ i ].in_use = true;
			tag_org							= self GetTagOrigin( "J_anim_jnt_top_arm_holder" );
			level.mover_prefabs[ i ].origin = tag_org;
			level.mover_prefabs[ i ] LinkTo( self, "J_anim_jnt_top_arm_holder" );
			
			// Save the ID
			self.mover_prefab_id = i;

			return;
		}
	}
	
	AssertMsg( "Error: get_ambush_mover_prefab() couldn't find a free mover" );
}

// Detaches the mover prefab from self
detach_mover_prefab()
{
	level.mover_prefabs[ self.mover_prefab_id ].in_use = false;
	self Unlink();
}

// Sets up the array of mover prefabs ( collision and audio nodes )
create_ambush_mover_prefabs()
{
	level.mover_prefabs = [];
	num_movers			= 8;

	// Loop through and create X number of mover prefabs
	for ( i = 0; i < num_movers; i++ )
	{
		level.mover_prefabs[ level.mover_prefabs.size ] = create_mover_prefab( "ambush_mover_prefab", i + 1 );
	}
}

// Creates one mover prefab ( collision brush and audio nodes )
create_mover_prefab( sTargetName, num )
{
	main_org  = undefined;//Main object origin
	audio_org = undefined;//SFX origin
	brushes	  = [];
	
	// Get all the objects
	new_targetname = ( sTargetName + "_" + num );
	ents		   = GetEntArray( new_targetname, "targetname" );
	
	// Sort through all the objects
	foreach ( ent in ents )
	{
		// If the entity is a script_brushmodel
		if ( ent.code_classname == "script_brushmodel" )
		{
			brushes[ brushes.size ] = ent;
			continue;
		}
		// If the entity is a script_origin
		if ( ent.code_classname == "script_origin" )
		{
			// Only the audio origin has a noteworthy
			if ( IsDefined( ent.script_noteworthy ) )
			{
				audio_org = ent;				
			}
			// Main origin has no noteworthy
			else
			{
				main_org		   = ent;
				main_org.audio_org = undefined; // Make room for the audio origin
			}
			continue;
		}
	}
	
	// Link everything to the origin so it moves together as one object
	foreach ( brush in brushes )
		brush LinkTo( main_org );	

	// Link the audio origin as well
	if ( IsDefined( audio_org ) )
	{
		audio_org LinkTo( main_org );		
		main_org.audio_org = audio_org;					
	}
	
	// Not in use yet
	main_org.in_use = false;
		
	// Return the finished product
	return main_org;
}