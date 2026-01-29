#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\skyway_util;

main()
{
	level.timestep = 0.05;
	
	template_level( "skyway" );
	maps\createart\skyway_art::main();
	maps\skyway_fx::main();
	maps\skyway_anim::main();
	
	// setup dev starts
	set_default_start( "hangar" );
	default_start( ::start_hangar );
	
	// Player starts: train not moving
	
	add_start( "hangar_nomove"			 , ::start_hangar_nomove	 , "hangar_nomove"			 , ::main_hangar );
	add_start( "sat_nomove"				 , ::start_sat_nomove		 , "sat_nomove"				 , ::main_sat );
	add_start( "sat_end_nomove"			 , ::start_sat_nomove		 , "sat_end_nomove"			 , ::main_sat );
	add_start( "rooftops_nomove"		 , ::start_rt_nomove		 , "rooftops_nomove"		 , ::main_rooftops );
	add_start( "locomotive_nomove"		 , ::start_loco_nomove		 , "locomotive_nomove"		 , ::main_loco );
	add_start( "locomotive_breach_nomove", ::start_loco_breach_nomove, "locomotive_breach_nomove", ::main_loco_breach );
	
	// Player starts: train moving
	
	add_start( "hangar"			  , ::start_hangar	   , "hangar"			, ::main_hangar );
	add_start( "sat"			  , ::start_sat		   , "sat"				, ::main_sat );
	add_start( "sat_end"		  , ::start_sat		   , "sat_end"			, ::main_sat );
	add_start( "rooftops"		  , ::start_rooftops   , "rooftops"			, ::main_rooftops );
	add_start( "locomotive"		  , ::start_loco	   , "locomotive"		, ::main_loco );
	add_start( "locomotive_breach", ::start_loco_breach, "locomotive_breach", ::main_loco_breach );
	
	// precache
	mission_precache();
	
	// play intro screen
	intro_screen_create( &"SKYWAY_INTROSCREEN_TITLE", &"SKYWAY_INTROSCREEN_LOC", &"SKYWAY_INTROSCREEN_TIME" );
//	intro_screen_custom_func( ::introscreen );
	
	// inital load
	maps\_load::main();
	mission_flag_inits();
	mission_global_inits();
	
	// init 
	maps\skyway_audio::main();
	
	// Player sway, quake, and rumble
	thread player_sway();
	thread player_const_quake();
	thread player_rumble();
	//thread player_train_rythme_rumble_quake();
	
	// build train
	cars = [ "train_hangar", "train_sat_1", "train_rt1", "train_rt2", "train_rt3", "train_rt4", "train_loco" ];
	level._train = train_build( cars, "player_train_new_anim" );
	
	// Start train pathing
	level._train thread train_pathing();
	
	// Objectives
	thread objectives();
	
	// DObj show/hide manager
	thread dobj_manager();
	
	// post load setup
	spawn_allies();
	spawn_boss();
	mission_post_inits();

	// Add vignette struct to all spawners
	array_thread( GetSpawnerArray(), maps\skyway_vignette::vignette_setup );	
	
	// Each car gets a kill plane for if the player falls off
	thread kill_plane_death();
	
	//skyfog
	SetSavedDvar("r_sky_fog_intensity","0.32");
	SetSavedDvar("r_sky_fog_min_angle","49.19");
	SetSavedDvar("r_sky_fog_max_angle","80.17");
	//set default DOF
	maps\_art::dof_set_base( 0, 1, 1, 2731.23, 81000, 1.0, 0);	
	
	
	//temp for testing dynamic scenarios
	maps\skyway_util::test_func_on_button();
}

mission_precache()
{		
	// init section precache
	maps\skyway_hangar_intro::section_precache();
	maps\skyway_sat::section_precache();
	maps\skyway_rooftops::section_precache();
	maps\skyway_loco::section_precache();
	
	// init level precache
	maps\skyway_precache::main();
	
	// precache viewmodels and weapons
	PreCacheItem( "m4_grunt_reflex");
	
	// precache shellshock
	PreCacheShellShock( "default_nosound" );
	
	// precache rumble
	// PreCacheRumble( "tank_rumble" );
	PreCacheRumble( "steady_rumble" );
	
	// precache objective strings
	// PrecacheString( &"SKYWAY_OBJ_EXAMPLE" );
}

mission_flag_inits()
{
	// init section flags
	maps\skyway_hangar_intro::section_flag_inits();
	maps\skyway_sat::section_flag_inits();	
	maps\skyway_rooftops::section_flag_inits();
	maps\skyway_loco::section_flag_inits();
	
	// init global mission flags
	flag_init( "flag_quake" );
	flag_init( "flag_kill_plane" );
}

mission_post_inits()
{
	// run section post
	maps\skyway_hangar_intro::section_post_inits();
	maps\skyway_sat::section_post_inits();
	maps\skyway_rooftops::section_post_inits();
	maps\skyway_loco::section_post_inits();
}

mission_global_inits()
{
	// ini level vars
	level._allies = [];	
	level._enemies = [];
	
	//level.wheelanimrate = 10;
	
	// init threatbias groups
	CreateThreatBiasGroup( "player" );
	level.player SetThreatBiasGroup( "player" );
}

//*******************************************************************
//																	*
//		HANGAR CAR													*
//*******************************************************************

start_hangar()
{		
	maps\skyway_hangar_intro::start();
}

start_hangar_nomove()
{
	level.debug_no_move = true;
	thread player_sway_blendto( 0,0,0 );
	maps\skyway_hangar_intro::start();
}

main_hangar()
{
	maps\skyway_hangar_intro::main();
}

//*******************************************************************
//																	*
//		SATELLITE CARS												*
//*******************************************************************

start_sat()
{			
	maps\skyway_sat::start();
}

start_sat_nomove()
{
	level.debug_no_move = true;
	thread player_sway_blendto( 0,0,0 );
	start_sat();
}

main_sat()
{
	// autosave_by_name( "sat" );
	maps\skyway_sat::main();	
}

//*******************************************************************
//																	*
//		ROOFTOPS													*
//*******************************************************************

start_rooftops()
{		
	maps\skyway_rooftops::start();
}

start_rt_nomove()
{
	level.debug_no_move = true;
	thread player_sway_blendto( 0,0,0 );
	maps\skyway_rooftops::start();
}

main_rooftops()
{
	maps\skyway_rooftops::main();
}

//*******************************************************************
//																	*
//		LOCOMOTIVE													*
//*******************************************************************

start_loco()
{		
	maps\skyway_loco::start_loco();
}

start_loco_breach()
{		
	maps\skyway_loco::start_breach();
}

start_loco_nomove()
{
	level.debug_no_move = true;
	thread player_sway_blendto( 0,0,0 );
	maps\skyway_loco::start_loco();
}

start_loco_breach_nomove()
{
	level.debug_no_move = true;
	thread player_sway_blendto( 0,0,0 );
	maps\skyway_loco::start_breach();
}

main_loco()
{
	maps\skyway_loco::main_loco();
}

main_loco_breach()
{
	maps\skyway_loco::main_loco_breach();
}

//*******************************************************************
//																	*
//		OBJECTIVES													*
//*******************************************************************

objectives()
{
	switch( level.start_point )
	{		
		case "hangar":
			
			// Wait for introscreen
			flag_wait( "introscreen_complete" );		
				
		case "hangar_nomove":
			
			objective_add( obj( "obj_find_vargas" ), "current", "Find Rorke (temp)" );
			
		case "sat_nomove":
		case "sat":
		case "sat_end_nomove":
		case "sat_end":
		case "rooftops_nomove":
		case "rooftops":
			
			flag_wait( "flag_rooftops_combat_end" );
			objective_complete( obj( "obj_find_vargas" ));
			
		case "locomotive_nomove":
		case "locomotive":
		case "locomotive_breach_nomove":
		case "locomotive_breach":
		
	}
}

//*******************************************************************
//																	*
//		Train Pathing												*
//*******************************************************************

train_pathing()
{
	wait( 0.2 );
	
	// debug no_move
	if( IsDefined( level.debug_no_move ) && level.debug_no_move )
		return;
	
	// init train path teleport triggers
	thread train_setup_teleport_triggers( self );
	
	// Start train pathing after a frame (to allow for queues to happen
	self DelayThread( 0.05, ::train_path );
	
	// Start paths
	switch( level.start_point )
	{		
		case "hangar_nomove":
		case "hangar":
			
			self train_queue_path_anim_loop( [ "loop_a1", "loop_a2" ], "anim_track_loop_a_start", "anim_track_loop_a_end" );
			flag_wait( "flag_hangar_door_open" );
			
		case "sat_nomove":
		case "sat":
			
			self train_queue_path_anim( "bc_1", "anim_track_bc_start", "anim_track_bc_end", "clear", true, false );					
			self train_queue_path_anim( "bc_2", "anim_track_bc_start", "anim_track_bc_end" );	
			
		case "sat_end_nomove":
		case "sat_end":
			
			self train_queue_path_anim( "bc_3", "anim_track_bc_start", "anim_track_bc_end" );
			
		case "rooftops_nomove":
		case "rooftops":
		case "locomotive_nomove":
		case "locomotive":
		case "locomotive_breach_nomove":
		case "locomotive_breach":
			
			self train_queue_path_anim_loop( [ "loop_a1", "loop_a2" ], "anim_track_loop_a_start", "anim_track_loop_a_end" );			
	}
}

//*******************************************************************
//																	*
//		Show / Hide geo												*
//*******************************************************************

dobj_manager()
{	
	// Give a frame for post-init scripts to run	
	wait( 0.05 );
	
	switch( level.start_point )
	{			
		case "hangar_nomove":
		case "hangar":
		case "sat_nomove":
		case "sat":
			
			show_train_geo( [ "train_hangar", "train_sat_1" ], [ "script_model" ] );
			flag_wait( "flag_rooftops_start" );
			
		case "sat_end_nomove":
		case "sat_end":
		case "rooftops_nomove":
		case "rooftops":
		case "locomotive_nomove":
		case "locomotive":
		case "locomotive_breach_nomove":
		case "locomotive_breach":
			
			show_train_geo( [ "train_sat_1",  "train_rt1", "train_rt2", "train_rt3", "train_rt4", "train_loco" ], [ "script_model" ] );
	}	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

introscreen()
{
	maps\_introscreen::introscreen( undefined, 1 );
}

//*******************************************************************
//																	*
//		TEST ANIM													*
//*******************************************************************

//start_test_anim()
//{		
//	maps\skyway_test_anim::start();
//}
//
//main_test_anim()
//{
//	maps\skyway_test_anim::main();
//}