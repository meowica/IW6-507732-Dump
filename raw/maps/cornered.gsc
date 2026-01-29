#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;

main()
{
	cornered_starts();
	
	template_level( "cornered" );
	
	maps\createart\cornered_art::main();
	maps\cornered_fx::main();
	maps\cornered_precache::main();
	maps\cornered_lighting::main();
	setup_trig_constants();
	
	transient_init( "cornered_start_tr" );
	transient_init( "cornered_end_tr" );
	
	/#thread createfx_load_transients();#/
	
	maps\_load::main();
	maps\cornered_anim::main();
	precache_for_startpoints();
	maps\_stealth::main();
	maps\_patrol_anims::main();
	maps\_patrol_anims_gundown::main();
	maps\_patrol_anims_creepwalk::main();
	maps\cornered_fx::treadfx_override();

	maps\_rv_vfx::init(); // Global breakable system
	maps\cornered_audio::main();
	maps\cornered_lighting::init_post_main();
    
		  //   num   
	exploder( 10 );//Light FX on top of main heli building
	exploder( 20 );//Blue flood FX on buildings
	exploder( 22 );//Light FX on buildings
	exploder( 56 );//Light FX on buildings
	exploder( 23 );//Helipad lights
	exploder( 67 );//FX at start area
	
	level.respawn_friendlies_force_vision_check = true;
	
	
	/#
//	level thread show_ai_health();
//	level thread show_stealth_events();
//	level thread debug_player_visible();
	enable_stealth_debugging();
	#/
	
	thread maps\cornered_fx::fx_checkpoint_states(); //FX checkpoint loading states
	thread maps\cornered_building_entry::festival_spotlights();
	thread maps\cornered_building_entry::ambient_building_lights();
}

cornered_starts()
{
	default_start( maps\cornered_intro::setup_intro );
	set_default_start( "intro" );
		   //   msg 			   func 											    loc_string 			   optional_func 									    transient 		    
	add_start( "intro"			, maps\cornered_intro::setup_intro					 , "Intro"				, maps\cornered_intro::begin_intro						, "cornered_start_tr" );
	add_start( "zipline"		, maps\cornered_intro::setup_zipline				 , "Zipline"			, maps\cornered_intro::begin_zipline					, "cornered_start_tr" );
	add_start( "rappel_stealth" , maps\cornered_infil::setup_rappel_stealth			 , "Rappel Stealth"		, maps\cornered_infil::begin_rappel_stealth				, "cornered_start_tr" );
	add_start( "building_entry" , maps\cornered_building_entry::setup_building_entry , "Building Entry"		, maps\cornered_building_entry::begin_building_entry	, "cornered_start_tr" );
	add_start( "shadow_kill"	, maps\cornered_building_entry::setup_shadow_kill	 , "Shadow Kill"		, maps\cornered_building_entry::begin_shadow_kill		, "cornered_start_tr" );
	add_start( "inverted_rappel", maps\cornered_building_entry::setup_inverted_rappel, "Inverted Rappel"	, maps\cornered_building_entry::begin_inverted_rappel	, "cornered_start_tr" );
	add_start( "courtyard"		, maps\cornered_interior::setup_courtyard			 , "Courtyard"			, maps\cornered_interior::begin_courtyard				, "cornered_start_tr" );
	add_start( "bar"			, maps\cornered_interior::setup_bar					 , "Bar"				, maps\cornered_interior::begin_bar						, "cornered_end_tr" );
	add_start( "junction"		, maps\cornered_interior::setup_junction			 , "Junction"			, maps\cornered_interior::begin_junction				, "cornered_end_tr" );
	add_start( "rappel"			, maps\cornered_rappel::setup_rappel				 , "Rappel Combat"		, maps\cornered_rappel::begin_rappel					, "cornered_end_tr" );
	add_start( "garden"			, maps\cornered_garden::setup_garden				 , "Garden"				, maps\cornered_garden::begin_garden					, "cornered_end_tr" );
	add_start( "hvt_capture"	, maps\cornered_destruct::setup_capture				 , "HVT Capture"		, maps\cornered_destruct::begin_capture					, "cornered_end_tr" );
	add_start( "stairwell"		, maps\cornered_destruct::setup_stairwell			 , "Stairwell"			, maps\cornered_destruct::begin_stairwell				, "cornered_end_tr" );
	add_start( "atrium"			, maps\cornered_destruct::setup_atrium				 , "Atrium"				, maps\cornered_destruct::begin_atrium					, "cornered_end_tr" );

}

precache_for_startpoints()
{
	maps\cornered_intro::cornered_intro_pre_load();
	maps\cornered_infil::cornered_infil_pre_load();
	maps\cornered_building_entry:: cornered_building_entry_pre_load();
	maps\cornered_interior::cornered_interior_pre_load();
	maps\cornered_rappel::cornered_rappel_pre_load();
	maps\cornered_garden::cornered_garden_pre_load();
	maps\cornered_destruct::cornered_destruct_pre_load();
	
	obj_flags();
	
	maps\_drone_ai::init();
	
	thread post_load();
}

post_load()
{	
	//Add / call your post load stuff here.
	//level waittill ( "load_finished" );
	
	setsaveddvar_cg_ng( "fx_alphathreshold", 9, 2 );
	
	// Intro
	level.player maps\cornered_binoculars::binoculars_init( "cornered" );
	
	// HVT Capture
	thread setup_object_friction_mass();
	thread maps\cornered_destruct::vista_tilt_setup();
	
	// Atrium
	maps\cornered_code_slide::building_fall_slide_setup();
		
	end_bldg = getEntArray( "end_broken_bldg", "targetname" );
	array_thread( end_bldg, ::hide_entity );

	bldg_tiran_dmg = GetEntArray( "vista_building_tiran_dmg", "targetname" );
	array_thread( bldg_tiran_dmg, ::hide_entity );
}

//objective stuff
obj_flags()
{
	flag_init( "obj_confirm_id_complete" );
	flag_init( "obj_capture_complete" );
	flag_init( "obj_fire_zipline" );
	flag_init( "obj_upload_virus_complete" );
	flag_init( "obj_disable_elevators_complete" );
	flag_init( "obj_escape_complete" );
	flag_init( "obj_optional_agent_complete" );
}

obj_confirm_id()
{
	objective_number = 1;
	//"Confirm target's identity."
	Objective_Add( objective_number, "active", &"CORNERED_OBJ_CONFIRM_ID" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_confirm_id_complete" );

	Objective_State( objective_number, "done" );
}

obj_fire_zipline()
{
	objective_number = 2;
	//"Fire the zipline launcher."
	Objective_Add( objective_number, "active", &"CORNERED_OBJ_FIRE_ZIPLINE" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_fire_zipline" );

	Objective_State( objective_number, "done" );
}

obj_capture_hvt()
{
	objective_number = 3;
	//"Capture the HVT."
	Objective_Add( objective_number, "active", &"CORNERED_OBJ_CAPTURE" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_capture_complete" );

	Objective_State( objective_number, "done" );
}

obj_upload_virus()
{
	objective_number = 4;
	//"Upload virus to the power system."
	Objective_Add( objective_number, "active", &"CORNERED_OBJ_UPLOAD_VIRUS" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_upload_virus_complete" );

	Objective_State( objective_number, "done" );
}

//obj_disable_elevators()
//{
//	objective_number = 5;
//	//"Disable the elevator power grid."
//	Objective_Add( objective_number, "active", &"CORNERED_OBJ_DISABLE_ELEVATORS" );
//	Objective_State( objective_number, "current" );
//
//	flag_wait( "obj_disable_elevators_complete" );
//
//	Objective_State( objective_number, "done" );
//}

obj_escape()
{
	objective_number = 6;
	//"Escape the building."
	Objective_Add( objective_number, "active", &"CORNERED_OBJ_ESCAPE" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_escape_complete" );

	Objective_State( objective_number, "done" );
}

obj_optional_double_agent()
{
	objective_number = 7;
	//"Escape the building."
	Objective_Add( objective_number, "active", &"CORNERED_OBJ_OPTIONAL" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_optional_agent_complete" );

	Objective_State( objective_number, "done" );
}

/#
createfx_load_transients()
{
	createfxon = GetDvar( "createfx" ) != "";
	
	if ( createfxon )
	{
		LoadTransient( "cornered_start_tr" );
		SetDvarIfUninitialized( "toggle_transient", "0" );
	}
	else
	{
		return;
	}
	
	cur_trans = "cornered_start_tr";
	next_trans = "cornered_end_tr";
	
	while ( true )
	{
		toggle = GetDvar( "toggle_transient" );
		
		if ( toggle == "0" )
		{
			wait 0.1;
			continue;
		}
				
		UnloadTransient( cur_trans );
		wait 0.2;
		LoadTransient( next_trans );
		
		while( !IsTransientLoaded( next_trans ) )
			wait 0.05;
		
		if ( cur_trans == "cornered_start_tr" )
		{
			cur_trans = "cornered_end_tr";
			next_trans = "cornered_start_tr";
		}
		else
		{
			cur_trans = "cornered_start_tr";
			next_trans = "cornered_end_tr";
		}
		
		SetDvar( "toggle_transient", "0" );
		wait 0.1;
	}
}
#/
