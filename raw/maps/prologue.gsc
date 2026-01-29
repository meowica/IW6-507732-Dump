#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

//Youngblood includes
#include maps\youngblood_util;

//Odin includes
#include maps\odin_util;

main()
{
	template_level( "prologue" );
	maps\createart\prologue_art::main();
	maps\prologue_fx::main();
	maps\prologue_precache::main();
	
	// This bool allows us to make the distinction between the combined Youngblood/Odin map,
	// and just running Youngblood or Odin on their own.
	// This would be undefined or false when running Odin or Youngblood on its own.
	level.prologue = true;

	// Art main
	maps\createart\youngblood_art::main();
	maps\createart\odin_art::main();
	
	// FX main
	maps\youngblood_fx::main();
	maps\odin_fx::main();
	
	// Precache
	//maps\youngblood_precache::main();
	//maps\odin_precache::main();
	maps\odin::odin_precache();


	// Setup starts
	default_start();
	
	// Start in youngblood
	add_start( "start_deer"		   , maps\youngblood::start_deer		 , undefined );
	add_start( "start_woods"	   , maps\youngblood::start_woods		 , undefined );
	add_start( "start_neighborhood", maps\youngblood::start_neighborhood, undefined );
	add_start( "start_mansion_ext" , maps\youngblood::start_mansion_ext , undefined );
	add_start( "start_mansion"	   , maps\youngblood::start_mansion		, undefined );

	// Up to odin
	add_start( "start_odin_intro"	 , maps\odin::start_odin_intro	  , "Odin Intro"	, maps\odin::odin_intro );
	add_start( "start_odin_ally"	 , maps\odin::start_odin_ally	  , "Odin Ally"		, maps\odin::odin_ally );
	add_start( "start_odin_escape"	 , maps\odin::start_odin_escape	  , "Odin Escape"	, maps\odin::odin_escape );
	add_start( "start_odin_spin"	 , maps\odin::start_odin_spin	  , "Odin Spin"		, maps\odin::odin_spin );
	add_start( "start_odin_spacejump", maps\odin::start_odin_spacejump, "Odin Spacejump", maps\odin::odin_spacejump );
	add_start( "start_odin_satellite", maps\odin::start_odin_satellite, "Odin Satellite", maps\odin::odin_satellite );
	add_start( "start_odin_end"		 , maps\odin::start_odin_end	  , "Odin End"		, maps\odin::odin_end );
	
	// Back to youngblood
	add_start( "start_chaos_a"	  , maps\youngblood::start_chaos_a	  , undefined );
	add_start( "start_chaos_b"	  , maps\youngblood::start_chaos_b	  , undefined );
	add_start( "start_test"		  , maps\youngblood::start_test		  , undefined );
	add_start( "start_test_area_a", maps\youngblood::start_test_area_a, undefined );
	add_start( "start_test_area_b", maps\youngblood::start_test_area_b, undefined );

	// Post add_start main
	maps\_load::main();

	// Audio
	maps\prologue_audio::main();
	maps\youngblood_audio::main();
	maps\odin_audio::main();

	// Anim
	//maps\youngblood_anim::main(); // Doesnt exist yet
	maps\odin_anim::main();

	// Odin Initialization
	maps\odin::odin_flag_inits();
	maps\odin::odin_hint_string_init();

	// Space movement init
	thread maps\_space_player::init_player_space();
	thread maps\_space_ai::init_ai_space();

	// Youngblood Initialization
	maps\youngblood::youngblood_earthquake_setup();
	maps\youngblood::youngblood_script_setup();

	// Youngblood -> Odin -> Youngblood transition logic
	thread prologue_transition_to_odin();
	thread prologue_transition_back_to_youngblood();
	
	trigger_off( "player_push_trigger", "script_noteworthy" );
}

// All the checkpoint start scripts are in Youngblood.gsc and Odin.gsc
// ...


// Initial transition up from Youngblood to Odin
prologue_transition_to_odin()
{
	flag_wait( "start_transition_to_odin" );
	fade_out( 1.0 );
	level.player FreezeControls( true );
	maps\odin::odin_script_setup();
	flag_set( "do_transition_to_odin" );
	wait 1.0;
	fade_in( 1.0 );
	level.player FreezeControls( false );
}

prologue_transition_back_to_youngblood()
{
	flag_wait( "start_transition_to_youngblood" );
	fade_out( 1.0 );
	level.player FreezeControls( true );
	level.player maps\_space_player::disable_player_space();
	maps\odin_util::move_player_to_start_point( "player_back_to_earth_tp" );

	// Give knife back
	level.player TakeAllWeapons();
	level.player GiveWeapon( "noweapon_youngblood" );
	level.player SwitchToWeapon( "noweapon_youngblood" );

	// Reset all view bob params to default
	SetSavedDvar( "bg_viewBobAmplitudeStanding"	  , "0.007 0.007" );
	SetSavedDvar( "bg_viewBobAmplitudeStandingAds", "0.007 0.007" );
	SetSavedDvar( "bg_viewBobAmplitudeDucked"	  , "0.0075 0.0075" );
	SetSavedDvar( "bg_viewBobAmplitudeDuckedAds"  , "0.0075 0.0075" );
	SetSavedDvar( "bg_viewBobAmplitudeSprinting"  , "0.02 0.014" );
	SetSavedDvar( "bg_weaponBobAmplitudeStanding" , "0.055 0.025" );
	SetSavedDvar( "bg_weaponBobAmplitudeDucked"	  , "0.045 0.025" );
	SetSavedDvar( "bg_weaponBobAmplitudeSprinting", "0.02 0.014" );
	SetSavedDvar( "bg_weaponBobAmplitudeBase"	  , 0.16 );
	SetSavedDvar( "bg_viewBobMax"				  , 8.0 );

	// Stop earthquakes
	Earthquake( 0.1, 0.1 , (0,0,0) , 1 );

	wait 1.0;
	level.player FreezeControls( false );
	fade_in( 1.0 );
}
