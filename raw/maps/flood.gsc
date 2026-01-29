#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	checkpoint_setup();

	template_level( "flood" );
	maps\createart\flood_art::main();
	maps\flood_fx::main();
	maps\flood_precache::main();
	thread common_scripts\_pipes::main();
	
	transient_init( "flood_intro_tr" );
	transient_init( "flood_mid_tr" );
	transient_init( "flood_end_tr" );	
	
	maps\_load::main();
	maps\flood_audio::main();
	maps\flood_anim::main();
	maps\flood_fx::treadfx_override();
	
	//for mocap stage use - should only run on test
	/#
	maps\_mocap_ar::main();
	#/
	
	// Internal Initialization
	mission_flag_inits();
	mission_precache();
	mission_mains();
	thread maps\flood_fx::fx_checkpoint_states();
	
	// Set this for the trees
	set_wind( 100, 0.1, 0.1 );
	
	thread maps\flood_util::setup_palm_trees_in_rushing_water();
	
	thread maps\flood_coverwater::init_coverwater();
	
	// for jason debugging purposes
	level.JKUdebug = 0;

	level.cw_vision_under	 = "flood_underwater";
	level.cw_bloom_under	 = "flood_bloom";
	level.cw_fog_under		 = "flood_underwater_murky";
	level.cw_waterwipe_above = "waterline_above";
	level.cw_waterwipe_under = "waterline_under";

	// kill grenades that get thrown into raging water
	thread maps\flood_util::kill_grenades();
	
	thread mission_objectives();
	thread mission_object_control();
	
	// Introscreen
	// Opening Gambit
	// Caracas, Venezuela
	// 12:46:16
	intro_screen_create( &"FLOOD_INTROSCREEN_LINE_1", &"FLOOD_INTROSCREEN_LINE_5", &"FLOOD_INTROSCREEN_LINE_2" );
	intro_screen_custom_func( ::introscreen );
//	intro_screen_custom_timing( 1, 2 );
	//level thread maps\flood_util::play_fullscreen_splash_cinematic( "flood_splash" );
}

checkpoint_setup()
{
	// Prep for E3 start
//	if( GetDvarInt( "demo_enabled" ) )
//	{
	default_start( ::infil_start );
	set_default_start( "infil" );
//	}
//	else
//	{
//	default_start( ::E3_section_start );
//	set_default_start( "e3" );
//	}

	// FOR E3	
		   //   msg      func 		    loc_string    optional_func    transient 	    
	add_start( "E3"	  , ::E3_section_start	 , "dam"		   , ::E3_section			, "flood_intro_tr" );

	// for E3 ending testing	
//	add_start( "E3"	  , ::E3_section_start	 , "mall"		   , ::E3_section			, "flood_mid_tr" );
	
		   //   msg 			    func 				      loc_string 	      optional_func       transient 	   
	add_start( "infil"			 , ::infil_start		   , "Infil"		   , ::infil		   , "flood_intro_tr" );
	add_start( "streets_to_dam"	 , ::streets_to_dam_start  , "Streets to Dam"  , ::streets_to_dam  , "flood_intro_tr" );
	add_start( "streets_to_dam_2", ::streets_to_dam_2_start, "Streets to Dam 2", ::streets_to_dam_2, "flood_intro_tr" );
	add_start( "dam"			 , ::dam_start			   , "Dam"			   , ::dam			   , "flood_intro_tr" );
	add_start( "flooding_ext"	 , ::flooding_ext_start	   , "Exterior Flood"  , ::flooding_ext	   , "flood_intro_tr" );
	add_start( "flooding_int"	 , ::flooding_int_start	   , "Interior Flood"  , ::flooding_int	   , "flood_intro_tr" );
	add_start( "mall"			 , ::mall_start			   , "Mall"			   , ::mall			   , "flood_mid_tr" );
	add_start( "swept"			 , ::swept_start		   , "Swept Away Event", ::swept		   , "flood_mid_tr" );
	add_start( "roof_stealth"	 , ::roof_stealth_start	   , "Stealth Moment"  , ::roof_stealth	   , "flood_mid_tr" );
	add_start( "skybridge"		 , ::skybridge_start	   , "Skybridge Event" , ::skybridge	   , "flood_end_tr" );
	add_start( "rooftops"		 , ::rooftops_start		   , "Rooftops"		   , ::rooftops		   , "flood_end_tr" );
	add_start( "rooftop_water"	 , ::rooftop_water_start   , "Rooftop Water"   , ::rooftop_water   , "flood_end_tr" );
	add_start( "debrisbridge"	 , ::debrisbridge_start	   , "Debris Bridge"   , ::debrisbridge	   , "flood_end_tr" );
	add_start( "garage"			 , ::garage_start		   , "Garage"		   , ::garage		   , "flood_end_tr" );
	add_start( "ending"			 , ::ending_start		   , "Ending"		   , ::ending		   , "flood_end_tr" );
	add_start( "fly_around"		, ::fly_around_start	, "Fly Around"		, ::fly_around );

	// Combined with Infil
	//	add_start( "streets"		 , ::streets_start		   , "Streets"		   , ::streets,				"flood_intro_tr" );
}


mission_mains()
{
	// Per section main
	level thread maps\flood_infil::section_main();
	level thread maps\flood_streets::section_main();
	level thread maps\flood_chopper::section_main();
	level thread maps\flood_flooding::section_main();
	level thread maps\flood_mall::section_main();
	level thread maps\flood_swept::section_main();
	level thread maps\flood_roof_stealth::section_main();
	level thread maps\flood_rooftops::section_main();
	level thread maps\flood_garage::section_main();
	level thread maps\flood_ending::section_main();
}

mission_precache()
{
	//maps\_weapon_selection_proto::loadout_selection_precache();
	
	PreCacheItem( "cz805bren" );
	PreCacheItem( "m9a1" );
	PreCacheShader( "cinematic" );
	PreCacheShader( "black" );
	objective_string_precache();
	
	// Per section precache
	level thread maps\flood_infil::section_precache();
	level thread maps\flood_streets::section_precache();
	level thread maps\flood_chopper::section_precache();
	level thread maps\flood_flooding::section_precache();
	level thread maps\flood_mall::section_precache();
	level thread maps\flood_swept::section_precache();
	level thread maps\flood_roof_stealth::section_precache();
	level thread maps\flood_rooftops::section_precache();
	level thread maps\flood_garage::section_precache();
	level thread maps\flood_ending::section_precache();
	level thread maps\flood_anim::anim_precache();
}

mission_flag_inits()
{
	// Per section flag inits
	level thread maps\flood_infil::section_flag_inits();
	level thread maps\flood_streets::section_flag_inits();
	level thread maps\flood_chopper::section_flag_inits();
	level thread maps\flood_flooding::section_flag_inits();
	level thread maps\flood_mall::section_flag_inits();
	level thread maps\flood_swept::section_flag_inits();
	level thread maps\flood_roof_stealth::section_flag_inits();
	level thread maps\flood_rooftops::section_flag_inits();
	level thread maps\flood_garage::section_flag_inits();
	level thread maps\flood_ending::section_flag_inits();
}

objective_string_precache()
{
	PrecacheString( &"FLOOD_OBJ_FIND_LAUNCHERS" );
	PrecacheString( &"FLOOD_OBJ_DISABLE_LAUNCHER" );
	PrecacheString( &"FLOOD_OBJ_HIGHER_GROUND" );
	PrecacheString( &"FLOOD_OBJ_REGROUP" );
	PrecacheString( &"FLOOD_OBJ_FIND_BOSS" );
	PrecacheString( &"FLOOD_OBJ_CAPTURE_BOSS" );
}

mission_objectives()
{
	switch( level.start_point )
	{
		case "infil":		
			
			wait( 16.0 );
//			Objective_Add( obj( "obj_capture_boss" ), "current", &"FLOOD_OBJ_CAPTURE_BOSS" );
//			wait( 29.0 );
//			Objective_State( obj( "obj_capture_boss" ), "active" );
			//"Locate the Mobile Rocket Launchers"
			Objective_Add( obj( "obj_find_launchers" ), "current", &"FLOOD_OBJ_FIND_LAUNCHERS" );
			
		case "streets":
		case "streets_to_dam":	

			if ( level.start_point == "streets_to_dam" )
				//"Locate the Mobile Rocket Launchers"
				Objective_Add( obj( "obj_find_launchers" ), "current", &"FLOOD_OBJ_FIND_LAUNCHERS" );
			level waittill( "objective_disable_launcher_1" );	

			objective_complete( obj( "obj_find_launchers" ) );
			wait(3.0);

			//"Disable the Mobile Rocket Launcher"
			Objective_Add( obj( "obj_disable_launcher" ), "current", &"FLOOD_OBJ_DISABLE_LAUNCHER" );
			
			level waittill("end_of_streets_to_dam");
			objective_complete( obj( "obj_disable_launcher" ) );			
			
		case "streets_to_dam_2":
		case "e3":
		case "dam":
			if( level.start_point == "e3" )
			{
				wait( 5.5 );
			}
			flag_wait( "missiles_ready" );
			//"Disable the Mobile Rocket Launcher"
			// CF - Removing specific lines but leaving for reference
			// wait was added here so the objective would wait until the fade up from black was done
			// DK Temp delay for greenlight
			////if ( getdvar( "greenlight" ) == "1" )
			//if( level.start_point == "dam" )
			//	wait( 3.0 );			
			Objective_Add( obj( "obj_disable_launcher" ), "current", &"FLOOD_OBJ_DISABLE_LAUNCHER" );
			flag_wait( "start_flood" );
			
//			Objective_Delete( obj( "obj_disable_launcher" ) );
			
			// Too Corny and/or distracting?
			Objective_State( obj( "obj_disable_launcher" ), "failed" );
			wait( 3.0 );
			//"Get to Higher Ground"
			Objective_Add( obj( "obj_higher_ground" ), "current", &"FLOOD_OBJ_HIGHER_GROUND" );
			wait( 10.0 );
			Objective_Delete( obj( "obj_higher_ground" ) );
			
		case "flooding_ext":		
		case "flooding_int":		
		case "mall":	
		case "swept":
		case "roof_stealth":
		case "skybridge":
		case "rooftops":
			
			flag_wait( "rooftops_vo_check_drop" );
			//"Regroup with Team"
			Objective_Add( obj( "obj_regroup" ), "current", &"FLOOD_OBJ_REGROUP" );			
			
		case "rooftop_water":		
		case "debrisbridge":
			
//			if ( !IsDefined( obj( "obj_regroup" ) ) )
			if ( level.start_point == "debrisbridge" )
			    //"Regroup with Price."
			    Objective_Add( obj( "obj_regroup" ), "current", &"FLOOD_OBJ_REGROUP" );
			
			flag_wait( "debrisbridge_encounter_death" );
			objective_complete( obj( "obj_regroup" ) );
			
			//"Locate Garcia."
			Objective_Add( obj( "obj_find_boss" ), "current", &"FLOOD_OBJ_FIND_BOSS" );
			level waittill( "xxxxxx" );
			objective_complete( obj( "obj_find_boss" ) );				
			
		case "garage":
		case "ending":
			
	}
}

mission_object_control()
{
	mission_hide_at_start();
	thread maps\flood_rooftops::rooftops_cleanup_jumpto();

	switch( level.start_point )
	{
		case "infil":
			level waittill( "infil_done" );
		case "streets":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_util::hide_models_by_targetname( "angry_flood_backstop", true );
			level waittill( "end_streets" );
		case "streets_to_dam":
			thread maps\flood_infil::infil_cleanup();		
			thread maps\flood_util::hide_models_by_targetname( "angry_flood_backstop", true );
    		level waittill("end_of_streets_to_dam");
		case "streets_to_dam_2":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_util::hide_models_by_targetname( "angry_flood_backstop", true );
    		level waittill("end_of_streets_to_dam_2");
    	case "e3":
		case "dam":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_models_by_targetname( "angry_flood_backstop", true );
			flag_wait("end_of_dam");
		case "flooding_ext":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::show_models_by_targetname( "angry_flood_backstop", true );
			flag_wait( "player_warehouse_mantle" );
		case "flooding_int":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname( "angry_flood_water_model" );
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
//			thread flood_interactives_cleanup( "streets_interactives_cleanup" );
			//thread maps\flood_mall::mallroof_firstframe();	
			thread maps\flood_util::show_models_by_targetname( "angry_flood_backstop", true );
			// Got to stairs
			flag_wait( "player_at_stairs_stop_nag" );			
		case "mall":	
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_util::show_models_by_targetname( "angry_flood_backstop", true );
			
			wait( 0.05 );
			
			// TFF delete vehicles before unloading
			vehicles = Vehicle_GetArray();
			array_delete( vehicles );
			
			// TFF clean up any script vehicles
			streets_script_vehicle_cleanup();
			
			if ( !flag( "flood_mid_tr_loaded" ) )
			{
				// Load Mid Transient
				thread transient_unloadall_and_load( "flood_mid_tr" );
	
				// In the hall
				flag_wait( "mall_breach_start" );			
				flag_wait( "flood_mid_tr_loaded" );
			}
			
			level waittill( "swept_away" );			
		case "swept":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			level waittill( "swept_success" );
		case "roof_stealth":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			
			// TFF delete vehicles before unloading
			all_iveco = GetEntArray( "script_vehicle_iveco_lynx", "classname" );
			array_delete( all_iveco );
			
			// TFF delete skybridge pieces before unloading
			if( IsDefined( level.skybridge_sections ) )
			{
				array_delete( level.skybridge_sections );
				level.skybridge_sections = [];
			}
				
			//level waittill( "player_done_stealth_mantle" );
			//level waittill( "player_done_stealth_kill" );
			
			level.player waittill( "mantle" );
			
			// clean up the dead
			dead_cleanup_array = GetCorpseArray();
			array_delete( dead_cleanup_array );
			
			// Load End Transient
			thread transient_unloadall_and_load( "flood_end_tr" );
			
			flag_wait( "skybridge_heli_go" );
			flag_wait( "flood_end_tr_loaded" );
		case "skybridge":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			flag_wait( "skybridge_done" );
		case "rooftops":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			thread maps\flood_roof_stealth::roof_stealth_cleanup();
			flag_wait( "rooftops_done" );
		case "rooftop_water":	
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			thread maps\flood_roof_stealth::roof_stealth_cleanup();
			flag_wait( "rooftop_water_done" );			
		case "debrisbridge":	
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			thread maps\flood_roof_stealth::roof_stealth_cleanup();
			flag_wait( "debrisbridge_done" );			
		case "garage":	
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_util::hide_scriptmodel_by_targetname_array( "embassy_hide" );
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			thread maps\flood_roof_stealth::roof_stealth_cleanup();
			flag_wait( "garage_done" );
		case "ending":
			thread maps\flood_infil::infil_cleanup();
			thread maps\flood_infil::tanks_cleanup();
			thread maps\flood_flooding::flooding_cleanup();
			thread maps\flood_mall::mall_delete_warehouse_ents();
			thread maps\flood_mall::mall_delete_rooftop_ents();
			thread maps\flood_roof_stealth::roof_stealth_cleanup();
		case "fly_around":
			thread maps\flood_infil::tanks_cleanup();
	}
}

mission_hide_at_start()
{
	thread maps\flood_mall::mallroof_firstframe( "hide" );
	thread maps\flood_util::hide_scriptmodel_by_targetname_array( "missile_launcher_2" );
}

streets_script_vehicle_cleanup()
{
	script_vehicle_array = [];
	script_vehicle_array = add_to_array( script_vehicle_array, GetEnt( "streets_static_iveco_01", "script_noteworthy" ) );
	script_vehicle_array = add_to_array( script_vehicle_array, GetEnt( "flood_street_car_5", "script_noteworthy" ) );
	script_vehicle_array = add_to_array( script_vehicle_array, GetEnt( "crashed_truck", "targetname" ) );
	script_vehicle_array = add_to_array( script_vehicle_array, GetEnt( "flood_street_car_1", "script_noteworthy" ) );
	script_vehicle_array = add_to_array( script_vehicle_array, GetEnt( "flood_street_truck_01", "script_noteworthy" ) );
	script_vehicle_array = add_to_array( script_vehicle_array, GetEnt( "flood_street_car_1_cleanup", "targetname" ) );
	script_vehicle_array = add_to_array( script_vehicle_array, GetEnt( "flood_ally_car", "script_noteworthy" ) );
	
	array_delete( script_vehicle_array );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flood_interactives_cleanup( volume_targetname )
{
    vols = GetEntArray( volume_targetname, "targetname" );
    
	delete_destructibles_in_volumes( vols );
	delete_exploders_in_volumes( vols );
	delete_interactives_in_volumes( vols );
}

introscreen()
{
	maps\_introscreen::introscreen( true, 10.75 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

E3_section_start()
{
	level.player SetClientTriggerAudioZone( "flood_fade_e3", 0.01 );
	level.start_point = "dam";
	maps\flood_streets::dam_start();

// for E3 ending testing
//	level.start_point = "mall";
//	maps\flood_mall::mall_start();
}

E3_section()
{
	// fade in
	black_overlay = maps\_hud_util::create_client_overlay( "black", 1, level.player );
	level thread E3_fadein( black_overlay );
	
// All E3 checkpoints
	maps\flood_streets::dam();
	maps\flood_flooding::flooding_ext();
	maps\flood_flooding::flooding_int();
	maps\flood_mall::mall();
	level thread maps\flood_swept::swept();

// Wait until near end of swept
	wait( 24.0 );
	
// Fade to black
	E3_fadeout( black_overlay );

// Give enough time for the fadeout to complete
	wait( 2.0 );

// Next mission
	nextmission();

// Wait here until next mission is started
	while( 1 )
		wait( 1.0 );
}

E3_fadein( black_overlay )
{
	
	level.player EnableInvulnerability();
	
	wait( 2.0 );
	
	level.player ClearClientTriggerAudioZone( 4 );
	
	black_overlay FadeOverTime( 4.0 );
	black_overlay.alpha = 0;
	
	wait( 3.0 );
	
	level.player DisableInvulnerability();
}

E3_fadeout( black_overlay )
{
	level.player EnableInvulnerability();
	level.player SetClientTriggerAudioZone( "flood_fade_e3", 1.8 );
	
	black_overlay FadeOverTime( 1.0 );
	black_overlay.alpha = 1;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infil_start()
{
	maps\flood_infil::infil_start();
}

infil()
{
	maps\flood_infil::infil();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_start()
{
	maps\flood_infil::streets_start();
	
	maps\flood_audio::sfx_flood_streets_emitters();
}

streets()
{
	maps\flood_infil::streets();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_to_dam_start()
{
	maps\flood_streets::streets_to_dam_start();
	
	maps\flood_audio::sfx_flood_streets_emitters();
}

streets_to_dam()
{
	maps\flood_streets::streets_to_dam();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_to_dam_2_start()
{
	maps\flood_streets::streets_to_dam_2_start();
	
	maps\flood_audio::sfx_flood_streets_emitters();
}

streets_to_dam_2()
{
	maps\flood_streets::streets_to_dam_2();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dam_start()
{
	maps\flood_streets::dam_start();
}

dam()
{
	maps\flood_streets::dam();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flooding_ext_start()
{
	maps\flood_flooding::flooding_ext_start();
}

flooding_ext()
{
	maps\flood_flooding::flooding_ext();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flooding_int_start()
{
	maps\flood_flooding::flooding_int_start();
}

flooding_int()
{
	maps\flood_flooding::flooding_int();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mall_start()
{
	maps\flood_mall::mall_start();
}

mall()
{
	maps\flood_mall::mall();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

swept_start()
{
	maps\flood_swept::swept_start();
}

swept()
{
	maps\flood_swept::swept();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

roof_stealth_start()
{
	maps\flood_roof_stealth::roof_stealth_start();
}

roof_stealth()
{
	maps\flood_roof_stealth::roof_stealth();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_start()
{
	maps\flood_rooftops::skybridge_start();
}

skybridge()
{
	maps\flood_rooftops::skybridge();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_start()
{
	maps\flood_rooftops::rooftops_start();
}

rooftops()
{
	maps\flood_rooftops::rooftops();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftop_water_start()
{
	maps\flood_rooftops::rooftop_water_start();
}


rooftop_water()
{
	maps\flood_rooftops::rooftop_water();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_start()
{
	maps\flood_rooftops::debrisbridge_start();
}


debrisbridge()
{
	maps\flood_rooftops::debrisbridge();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

garage_start()
{
	maps\flood_garage::garage_start();
}

garage()
{
	maps\flood_garage::garage();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_start()
{
	maps\flood_ending::ending_start();
}

ending()
{
	maps\flood_ending::ending();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//================================================================================================
//	FLY AROUND ( TEST TRANSIENTS)
//================================================================================================
fly_around_start()
{
	IPrintLnBold ( "Press X to cycle transient fastfiles" );
	maps\flood_util::player_move_to_checkpoint_start( "flyaround_start" );
}

fly_around()
{
	while ( 1 )
	{
		while ( !level.player ButtonPressed( "BUTTON_X" ) )
		{
			wait 0.05;
		}

		thread transient_unloadall_and_load( "flood_intro_tr" );
		flag_wait("flood_intro_tr_loaded");
		flag_clear("flood_intro_tr_loaded");
		wait(1.0);
		IPrintLn ( "flood_intro_tr transient fastfile loaded" );
		
		while ( !level.player ButtonPressed( "BUTTON_X" ) )
		{
			wait 0.05;
		}

		thread transient_unloadall_and_load( "flood_mid_tr" );
		flag_wait("flood_mid_tr_loaded");
		flag_clear("flood_mid_tr_loaded");
		wait(1.0);
		IPrintLn ( "flood_mid_tr transient fastfile loaded" );
				
		while ( !level.player ButtonPressed( "BUTTON_X" ) )
		{
			wait 0.05;
		}

		thread transient_unloadall_and_load( "flood_end_tr" );
		flag_wait("flood_end_tr_loaded");
		flag_clear("flood_end_tr_loaded");
		wait(1.0);
		IPrintLn ( "flood_end_tr transient fastfile loaded" );
		
	}
}