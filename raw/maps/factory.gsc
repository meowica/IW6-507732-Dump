#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_vignette_util;

main()
{
	template_level( "factory" );
	maps\createart\factory_art::main();
	maps\factory_fx::main();
	maps\_riotshield::init_riotshield();
	maps\factory_precache::main();
	
	//for mocap stage use - should only run on test
	/#
	maps\_mocap_ar::main();
	#/

	// Setup starts
	default_start( );
		   //   msg 			   func 				    loc_string 		    optional_func 		transient_name
	add_start( "intro"			, ::intro_start			 , "Infil"			 , ::intro,				"factory_intro_tr" );
	add_start( "intro_train"	, ::intro_train_start	 , "Train Pass"		 , ::intro_train,		"factory_intro_tr" );
	add_start( "factory_ingress", ::factory_ingress_start, "Factory Entrance", ::factory_ingress,	"factory_intro_tr" );
	add_start( "powerstealth"	, ::powerstealth_start	 , "Power Stealth"	 , ::powerstealth,		"factory_intro_tr" );
	add_start( "presat_room"	, ::presat_room_start	 , "Pre-SAT Room"	 , ::presat_room,		"factory_intro_tr" );
	add_start( "sat_room"		, ::sat_room_start		 , "SAT Room"		 , ::sat_room,			"factory_mid_tr" );
	add_start( "ambush"			, ::ambush_start		 , "Ambush"			 , ::ambush,			"factory_mid_tr" );
	add_start( "ambush_escape"	, ::ambush_escape_start	 , "Ambush Escape"	 , ::ambush_escape,		"factory_mid_tr" );
	add_start( "rooftop"		, ::rooftop_start		 , "Rooftop"		 , ::rooftop,			"factory_mid_tr" );
	add_start( "parking_lot"	, ::parking_lot_start	 , "Parking Lot"	 , ::parking_lot,		"factory_outro_tr" );
	add_start( "chase"			, ::chase_start			 , "Vehicle Chase"	 , ::chase,				"factory_outro_tr" );
	add_start( "fly_around"		, ::fly_around_start	 , "Fly Around"		 , ::fly_around );
	
	// Initialization
	mission_flag_inits();
	mission_precache();
	maps\factory_audio::audio_flag_inits();	
	mission_hint_string_init();
	maps\_drone_ai::init();
	common_scripts\_pipes::main();
	level.pipesdamage = false;
	
	// Introscreen
	
	//"Maquiladora"
	//"Outside Medellin, Colombia\n"
	//"August 17th - 02:17:[{FAKE_INTRO_SECONDS:16}]"
	intro_screen_create( &"FACTORY_INTROSCREEN_LINE_1", &"FACTORY_INTROSCREEN_LINE_5", &"FACTORY_INTROSCREEN_LINE_2" );
	// intro_screen_custom_timing( 3, 3.5 );	

	transient_init( "factory_intro_tr" );
	transient_init( "factory_mid_tr" );
	transient_init( "factory_outro_tr" );
	 
	maps\_load::main();
	
	//Set Spec colorscale dvar to make up for differentials between CG and NG
    setsaveddvar_cg_ng( "r_specularColorScale", 2.5, 9.01 );

	maps\factory_anim::main();
	maps\_hand_signals::initHandSignals();

	// Mision objectives
	thread mission_objective_logic();

	// Setup the player squad
	maps\factory_util::squad_add_ally( "ALLY_ALPHA"	 , "ally_alpha"	 , "ally_alpha" );//BLUE
	maps\factory_util::squad_add_ally( "ALLY_BRAVO"	 , "ally_bravo"	 , "ally_bravo" );//RED
	maps\factory_util::squad_add_ally( "ALLY_CHARLIE", "ally_charlie", "ally_charlie" );//PURPLE
	
	// TJ - temp script call to globally turn off battlechatter until we get new audio assets
	battlechatter_off();
	thread set_team_bcvoice( "allies", "american" );
	
	// Stealth setup
	maps\_stealth::main();
	maps\_patrol_anims::main();
//	level.player maps\_stealth_utility::stealth_default();
	
	// Setup the SAT room camera
	level.player maps\factory_camera::binoculars_init( "factory" );
	
	// Give the player weapons
	level.player TakeAllWeapons();
	level.default_weapon = "honeybadger+reflex_sp"; // Old value: mp5_silencer_eotech
	level.player GiveWeapon( level.default_weapon );
	level.player SwitchToWeaponImmediate( level.default_weapon );
	level.player GiveMaxAmmo( level.default_weapon );
	level.player GiveWeapon( "uspflir2_silencer" );
	level.player SetOffhandPrimaryClass( "frag" );
	level.player SetOffhandSecondaryClass( "flash" );
//	level.player GiveWeapon( "flash_grenade" );
//	level.player GiveWeapon( "fraggrenade" );
	
	// Setup assembly line anims
	//thread maps\factory_anim::factory_assembly_line_delete();
	
	//thread audio scripts
	thread maps\factory_audio::audio_main();	
	//mission music thread
	thread maps\factory_audio::mission_music();
	
	thread maps\factory_fx::lgt_vision_fog_init();
	thread maps\factory_fx::fx_init();
	
	// DEBUG DONT CHECK IN
	//thread maps\factory_util::player_debug_safety();
	//level.player thread maps\factory_util::test_slowmovermode();
	

}

mission_precache()
{
	//maps\_weapon_selection_proto::loadout_selection_precache();
	
	PreCacheShellShock( "factory_revbreach" );
	PreCacheRumble( "silencer_fire" ); // Added to resolve JIRA IWSIX-8129
	
	// PreCacheItem( "iw5_m4flir2_sp_reflexflir2_silencerunderflir2" );
	PreCacheItem( "honeybadger" );
	PreCacheItem( "uspflir2_silencer" );
	// PreCacheItem( "smoke_grenade_american" );
	precacheshader( "hud_icon_nvg" ); 

	// SECTION SPECIFIC PRECACHE
	//intro*
	maps\factory_powerstealth::section_precache();
	maps\factory_weapon_room::section_precache();
	maps\factory_ambush::section_precache();
	maps\factory_ambush_escape::section_precache();
	maps\factory_rooftop::section_precache();
	maps\factory_chase::section_precache();
}

mission_flag_inits()
{
	
	// SECTION SPECIFIC FLAGS
	//intro
	maps\factory_powerstealth::section_flag_init();
	maps\factory_weapon_room::section_flag_init();
	maps\factory_ambush::section_flag_init();
	maps\factory_ambush_escape::section_flag_init();
	maps\factory_rooftop::section_flag_init();
	maps\factory_parking_lot::section_flag_init();
	maps\factory_chase::section_flag_init();
	
	flag_init ("intel_proto_flag");
}

mission_hint_string_init()
{
	// Objective-specific hint-string initializations
	maps\factory_powerstealth::section_hint_string_init();
	maps\factory_ambush::section_hint_string_init();
}

//================================================================================================
//	INTRO
//================================================================================================
intro_start()
{
	
	// KM- Uncomment the below two lines to initialize the intel prototype. Do not check in uncommented!
	// flag_set ("intel_proto_flag");
	// thread maps\proto_intel_system::main();
	
	thread maps\factory_audio::intro_ambience_changes();
	
	level.player maps\factory_util::move_player_to_start_point( "playerstart_intro" );
	
	level maps\factory_powerstealth::intro_start();
}

intro()
{
	level maps\factory_powerstealth::intro();
}

//================================================================================================
//	INTRO TRAIN SECTION
//================================================================================================
intro_train_start()
{
		
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level.player maps\factory_util::move_player_to_start_point( "playerstart_intro_train" );
	
	level maps\factory_powerstealth::intro_train_start();

}

intro_train()
{
	level maps\factory_powerstealth::intro_train();
}

//================================================================================================
//	FACTORY INGRESS
//================================================================================================
factory_ingress_start()
{
		
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level.player maps\factory_util::move_player_to_start_point( "playerstart_factory_ingress" );
	
	level maps\factory_powerstealth::factory_ingress_start();

}

factory_ingress()
{
	level maps\factory_powerstealth::factory_ingress();
}

//================================================================================================
//	POWERSTEALTH
//================================================================================================
powerstealth_start()
{
	
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level.player maps\factory_util::move_player_to_start_point( "playerstart_powerstealth" );
	
	level maps\factory_powerstealth::powerstealth_start();

}

powerstealth()
{
	level maps\factory_powerstealth::powerstealth();
}

//================================================================================================
//	PRESAT ROOM
//================================================================================================
presat_room_start()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level maps\factory_weapon_room::presat_room_start();


}

presat_room()
{
	level maps\factory_weapon_room::presat_room();
}

//================================================================================================
//	SAT ROOM
//================================================================================================
sat_room_start()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	// Give player grenades
	level.player GiveWeapon( "flash_grenade" );
	level.player GiveWeapon( "fraggrenade" );
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();

	level maps\factory_weapon_room::sat_room_start();
}

sat_room()
{
	level maps\factory_weapon_room::sat_room();
}

//================================================================================================
//	AMBUSH
//================================================================================================
ambush_start()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	// Give player grenades
	level.player GiveWeapon( "flash_grenade" );
	level.player GiveWeapon( "fraggrenade" );
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();

	level maps\factory_ambush::start();

}

ambush()
{
	level maps\factory_ambush::main();
}

//================================================================================================
//	AMBUSH ESCAPE
//================================================================================================
ambush_escape_start()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	// Give player grenades
	level.player GiveWeapon( "flash_grenade" );
	level.player GiveWeapon( "fraggrenade" );
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level maps\factory_ambush_escape::start();

}

ambush_escape()
{
	level maps\factory_ambush_escape::main();
}

//================================================================================================
//	ROOFTOP
//================================================================================================
rooftop_start()
{
	
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	// Give player grenades
	level.player GiveWeapon( "flash_grenade" );
	level.player GiveWeapon( "fraggrenade" );
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level maps\factory_rooftop::start();

}

rooftop()
{
	level maps\factory_rooftop::main();
}

//================================================================================================
//	PARKING LOT
//================================================================================================
parking_lot_start()
{
	
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	// Give player grenades
	level.player GiveWeapon( "flash_grenade" );
	level.player GiveWeapon( "fraggrenade" );
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level maps\factory_parking_lot::start();

}

parking_lot()
{
	level maps\factory_parking_lot::main();
}

//================================================================================================
//	CHASE
//================================================================================================
chase_start()
{
	
	// Force cleanup on previous checkpoints
	jump_to_cleanup();
	
	// Give player grenades
	level.player GiveWeapon( "flash_grenade" );
	level.player GiveWeapon( "fraggrenade" );
	
	level.player thread maps\factory_util::thermal_vision();
	level thread maps\factory_fx::fx_track_thermal();
	
	level maps\factory_chase::start();

}

chase()
{
	level maps\factory_chase::main();
}

//================================================================================================
//	FLY AROUND ( TEST TRANSIENTS)
//================================================================================================
fly_around_start()
{
	IPrintLnBold ( "Press X to cycle transient fastfiles" );
	level.player maps\factory_util::move_player_to_start_point( "playerstart_intro" );
}

fly_around()
{
	while ( 1 )
	{
		while ( !level.player ButtonPressed( "BUTTON_X" ) )
		{
			wait 0.05;
		}
		maps\factory_util::load_transient( "factory_intro_tr" );
		while ( !IsTransientLoaded( "factory_intro_tr" ) )
		{
			wait 0.05;
		}
		
		while ( !level.player ButtonPressed( "BUTTON_X" ) )
		{
			wait 0.05;
		}
		maps\factory_util::load_transient( "factory_mid_tr" );
		while ( !IsTransientLoaded( "factory_mid_tr" ) )
		{
			wait 0.05;
		}
		
		while ( !level.player ButtonPressed( "BUTTON_X" ) )
		{
			wait 0.05;
		}
		maps\factory_util::load_transient( "factory_outro_tr" );
		while ( !IsTransientLoaded( "factory_outro_tr" ) )
		{
			wait 0.05;
		}

	}
}


//================================================================================================
//	OBJECTIVES
//================================================================================================
mission_objective_logic()
{
	// Setup objective indices
	obj( "OBJ_INFILTRATE" );
	obj( "OBJ_FIND_PROOF" );
	obj( "OBJ_INVESTIGATE" );
	obj( "OBJ_SCAN_1" );
	obj( "OBJ_SCAN_2" );
	obj( "OBJ_ESCAPE" );

	// Wait for setup stuff to complete
	waittillframeend;

	// Used a jump to start?
	jumped_to_start = false;
	if ( level.start_point != "default" )
	{
		jumped_to_start = true;
	}

	// Objective flow
	switch ( level.start_point )
	{
		case "default":
		case "intro":
			flag_wait ( "intro_drop_kill_done" );
		case "intro_train":
		case "factory_ingress":
			//"Infiltrate the factory."
			Objective_Add( obj( "OBJ_INVESTIGATE" ), "active", &"FACTORY_OBJ_ENTER_FACTORY" );
			flag_wait( "entered_factory_1" );
			Objective_State( obj( "OBJ_INVESTIGATE" ), "done" );		
		case "powerstealth":
		case "presat_room":
		case "sat_room":
			//"Find evidence of orbital weapon manufacturing."
			Objective_Add( obj( "OBJ_FIND_PROOF" ), "active", &"FACTORY_OBJ_FIND_EVIDENCE" );

			flag_wait( "start_camera_moment" );
			Objective_State( obj( "OBJ_FIND_PROOF" ), "done" );
			//"Upload visuals scans of the satellite payload."
			Objective_Add( obj( "OBJ_SCAN_1" ), "active", &"FACTORY_OBJ_SCAN_1" );
			//"Upload visuals scans of the satellite main control module."
			Objective_Add( obj( "OBJ_SCAN_2" ), "active", &"FACTORY_OBJ_SCAN_2" );

			// Scan 1
			flag_wait( "cam_A_confirmed" );
			//"Upload visuals scans of the satellite payload."
			Objective_Add( obj( "OBJ_SCAN_1" ), "done", &"FACTORY_OBJ_SCAN_1" );

			// Scan 2
			flag_wait( "sat_room_continue" );
			//"Upload visuals scans of the satellite main control module."
			Objective_Add( obj( "OBJ_SCAN_2" ), "done", &"FACTORY_OBJ_SCAN_2" );

			// Done
			flag_wait( "sat_room_continue" );

	
		case "ambush":
			// If jumping
			if ( jumped_to_start )
			{
				//"Find evidence of orbital weapon manufacturing."
				Objective_Add( obj( "OBJ_FIND_PROOF" ), "done", &"FACTORY_OBJ_FIND_EVIDENCE" );
			}

			//"Investigate the factory record."
			Objective_Add( obj( "OBJ_INVESTIGATE" ), "current", &"FACTORY_OBJ_INVESTIGATE_RECORDS" );
			//"Upload visuals scans of the satellite payload."
			Objective_Add( obj( "OBJ_SCAN_1" ), "invisible", &"FACTORY_OBJ_SCAN_1" );
			//"Upload visuals scans of the satellite main control module."
			Objective_Add( obj( "OBJ_SCAN_2" ), "invisible", &"FACTORY_OBJ_SCAN_2" );
	
			// Display a use button on the computer ( Replace this later with glowing keyboard )
			level waittill( "show_ambush_use_hint" );
			hint_obj = GetEnt( "ambush_console_node", "targetname" );
			//Objective_Position( obj( "OBJ_INVESTIGATE"), hint_obj.origin );
			//setSavedDvar( "ObjectiveFadeTooFar", 5 );
			//Objective_SetPointerTextOverride( obj( "OBJ_INVESTIGATE" ), &"FACTORY_COPY_DATA" );

			flag_wait( "player_used_computer" );
			Objective_State( obj( "OBJ_INVESTIGATE" ), "invisible" );
			//dvar - "OjbectiveHideIcon"

			
			flag_wait( "ambush_thermal_allies_movedup_01" );
			Objective_State( obj( "OBJ_INVESTIGATE" ), "empty" );

		// Fall through on purpose here - "Escape" objective remains for rest of mission
		case "ambush_escape":
		case "rooftop":
		case "parking_lot":
		case "chase":
			// If jumping
			if ( jumped_to_start )
			{
				//"Find evidence of orbital weapon manufacturing."
				Objective_Add( obj( "OBJ_FIND_PROOF" ), "done", &"FACTORY_OBJ_FIND_EVIDENCE" );
			}

			//"Escape the factory."
			Objective_Add( obj( "OBJ_ESCAPE" ), "active", &"FACTORY_OBJ_ESCAPE_FACTORY" );
		default:
	}
}

// This script runs the cleanup for previous checkpoints when using jump-to.
jump_to_cleanup()
{
	// The switch statement is in reverse order so we can use fall through
	switch ( level.start_point )
	{
		case "chase":
		case "parking_lot":
		case "rooftop":
		case "ambush_escape":
			// Ambush cleanup
			maps\factory_ambush::ambush_cleanup( true );
		case "ambush":
			// Sat cleanup
			maps\factory_weapon_room::sat_cleanup( true );
		case "sat_room":
			// Presat cleanup
			maps\factory_weapon_room::presat_cleanup( true );
		case "presat_room":
		case "powerstealth":
		case "factory_ingress":
		case "intro_train":
		case "intro":
		case "default":
		default:
	}
}