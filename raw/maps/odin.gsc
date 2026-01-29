#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

// THIS MAIN FILE SHOULD ONLY BE CALLED WHEN RUNNING ODIN ALONE
// IF ODIN IS RUN THROUGH PROLOGUE, THIS MAIN WILL NOT GET CALLED
main()
{
	template_level( "odin" );
	maps\createart\odin_art::main();
	maps\odin_fx::main();
	maps\odin_precache::main();

	// If this is Odin alone, add starts
	default_start();
	add_start( "odin_intro"		, ::start_odin_intro		, "Odin Intro"		, ::odin_intro );
	add_start( "odin_ally"		, ::start_odin_ally			, "Odin Ally"		, ::odin_ally );
	add_start( "odin_escape"	, ::start_odin_escape		, "Odin Escape"   	, ::odin_escape );
	add_start( "odin_spin"		, ::start_odin_spin			, "Odin Spin"		, ::odin_spin );
	add_start( "odin_spacejump"	, ::start_odin_spacejump	, "Odin Spacejump"	, ::odin_spacejump );
	add_start( "odin_satellite"	, ::start_odin_satellite	, "Odin Satellite"	, ::odin_satellite );
	add_start( "odin_end"		, ::start_odin_end			, "Odin End"		, ::odin_end );
	add_start( "odin_test"		, ::start_odin_test			, "Odin Test Area"	, ::odin_test );

	maps\_load::main();
	maps\odin_anim::main();
	maps\odin_audio::main();
	
	// Odin Initialization
	maps\odin::odin_precache();
	maps\odin::odin_flag_inits();
	maps\odin::odin_hint_string_init();
	
	// Setup space movement and zero-g
	maps\odin::odin_script_setup();
}

odin_precache()
{
	maps\_space::precache();
	maps\odin_intro::section_precache();
	maps\odin_ally::section_precache();
	maps\odin_escape::section_precache();
	maps\odin_spin::section_precache();
	maps\odin_spacejump::section_precache();
	maps\odin_satellite::section_precache();
	maps\odin_end::section_precache();
}

odin_flag_inits()
{
	maps\odin_intro::section_flag_init();
	maps\odin_ally::section_flag_init();
	maps\odin_escape::section_flag_init();
	maps\odin_spin::section_flag_init();
	maps\odin_spacejump::section_flag_init();
	maps\odin_satellite::section_flag_init();
	maps\odin_end::section_flag_init();
}

odin_hint_string_init()
{
	maps\odin_intro::section_hint_string_init();
	maps\odin_ally::section_hint_string_init();
	maps\odin_escape::section_hint_string_init();
	maps\odin_spin::section_hint_string_init();
	maps\odin_spacejump::section_hint_string_init();
	maps\odin_satellite::section_hint_string_init();
	maps\odin_end::section_hint_string_init();
}

// Setup for global space stuff
odin_script_setup()
{
	// This should only run once
	if( isDefined( level.odin_script_setup ))
	{
		return;
	}
	level.odin_script_setup = true;
	
	//Set _space_player variable to true because our CSV has player push off anims
	level.player.has_pushanims = true;
	
	// Don't call this here from prologue
	// Because the space stuff happens after the mission is already loaded and inited
	if( !isDefined( level.prologue ) || ( isDefined( level.prologue ) && level.prologue == false ))
	{
		// Space movement init
		thread maps\_space_player::init_player_space();
		thread maps\_space_ai::init_ai_space();
	}

	//Add 3D nodes to the color system
	maps\_colors::add_cover_node( "Path 3D" );
	maps\_colors::add_cover_node( "Cover Stand 3D" );
	maps\_colors::add_cover_node( "Cover Right 3D" );
	maps\_colors::add_cover_node( "Cover Left 3D" );
	maps\_colors::add_cover_node( "Cover Up 3D" );
	maps\_colors::add_cover_node( "Exposed 3D" );
	
	SetSavedDvar( "player_spaceViewHeight", 11 );
	SetSavedDvar( "player_spaceCapsuleHeight", 30 );

	// Wall friction
	level.wall_friction_enabled = true;
	level.wall_friction_trace_dist = 5;
	level.wall_friction_offset_dist = 2;

	// Sprinting view bob reduction
	SetSavedDvar( "bg_viewBobAmplitudeStanding"	  , "0.0 0.0" );
	SetSavedDvar( "bg_viewBobAmplitudeStandingAds", "0.0 0.0" );
	SetSavedDvar( "bg_viewBobAmplitudeDucked"	  , "0.0 0.0" );
	SetSavedDvar( "bg_viewBobAmplitudeDuckedAds"  , "0.0 0.0" );
	SetSavedDvar( "bg_viewBobAmplitudeSprinting"  , "0.0 0.0" );
	SetSavedDvar( "bg_weaponBobAmplitudeStanding" , "0.0 0.0" );
	SetSavedDvar( "bg_weaponBobAmplitudeDucked"	  , "0.0 0.0" );
	SetSavedDvar( "bg_weaponBobAmplitudeSprinting", "0.0 0.0" );
	SetSavedDvar( "bg_weaponBobAmplitudeBase"	  , 0.0 );
	SetSavedDvar( "bg_viewBobMax"				  , 0 );

	thread maps\_space_player::init_player_space_anims();
	level.water_level_z = level.player.origin[2];
	level.default_goalradius = 64;
	level.player thread maps\_space_player::enable_player_space();
	level.player thread maps\_space::player_space_helmet();
	level.player thread maps\_space::space_hud_enable( true );
	level.player thread give_weapons();
	level.player notify( "stop_space_breathe" );
	
	//Spawn Ally
	spawner = GetEnt( "ally_0" , "targetname" );
	level.ally = spawner spawn_ai( true );
	level.squad[0] = level.ally;
	level.ally thread magic_bullet_shield();
	level.ally thread set_force_color("r");
	level.ally thread maps\_space_ai::enable_space();
	level.ally thread maps\_space_ai::handle_angled_nodes();
	
	// Speed her up
	level.ally.moveplaybackrate = 1.5;
	
	//play temp space ambience
	maps\odin_audio::audio_set_initial_ambience();

	thread maps\odin_util::set_mission_view_tweaks();
	wait .1;
}

give_weapons()
{
	self TakeAllWeapons();
//	self giveWeapon( "spaceaps" );
//	self giveWeapon( "spaceshotgun" );
//	self giveWeapon( "spacexm25" );
	self GiveWeapon( "kriss_space+eotechsmg_sp" );
	self GiveWeapon( "fp6_space" );
	self GiveWeapon( "kriss_space_projectile+eotechsmg_sp" );
	self GiveWeapon( "microtar_space" );
	self SwitchToWeapon( "microtar_space" );
	self DisableWeaponPickup();
}

//================================================================================================
//	ODIN INTRO
//================================================================================================
start_odin_intro()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_intro::intro_start();
}

odin_intro()
{
	maps\odin_intro::intro_main();
}


//================================================================================================
//	ODIN ALLY
//================================================================================================
start_odin_ally()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_ally::ally_start();
}

odin_ally()
{
	maps\odin_ally::ally_main();
}


//================================================================================================
//	ODIN ESCAPE
//================================================================================================
start_odin_escape()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_escape::escape_start();
}

odin_escape()
{
	maps\odin_escape::escape_main();
}


//================================================================================================
//	ODIN SPINNING ROOM
//================================================================================================
start_odin_spin()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_spin::spin_start();
}

odin_spin()
{
	maps\odin_spin::spin_main();
}


//================================================================================================
//	ODIN SPACE JUMP
//================================================================================================
start_odin_spacejump()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_spacejump::spacejump_start();
}

odin_spacejump()
{
	maps\odin_spacejump::spacejump_main();
}

//================================================================================================
//	ODIN SATELLITE
//================================================================================================
start_odin_satellite()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_satellite::satellite_start();
}

odin_satellite()
{
	maps\odin_satellite::satellite_main();
}

//================================================================================================
//	ODIN END
//================================================================================================
start_odin_end()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_end::end_start();
}

odin_end()
{
	maps\odin_end::end_main();
}

//================================================================================================
//	ODIN TEST AREA
//================================================================================================
start_odin_test()
{
	// Force cleanup on previous checkpoints
	jump_to_cleanup();

	maps\odin::odin_script_setup();
	maps\odin_test::test_start();
}

odin_test()
{
	maps\odin_test::test_main();
}


// This script runs the cleanup for previous checkpoints when using jump-to.
// Mostly in order to save on ent count
jump_to_cleanup()
{
	// Do nothing for now.
	return;

	/*
	// The switch statement is in reverse order so we can use fall through
	switch ( level.start_point )
	{
		case "odin_test":
			thread maps\odin_test::test_cleanup( true );
		case "odin_satellite":
			thread maps\odin_satellite::satellite_cleanup( true );
		case "odin_spacejump":
			thread maps\odin_spacejump::spacejump_cleanup( true );
		case "odin_spin":
			thread maps\odin_spin::spin_cleanup( true );
		case "odin_escape":
			thread maps\odin_escape::escape_cleanup( true );
		case "odin_ally":
			thread maps\odin_ally::ally_cleanup( true );
		case "odin_intro":
			thread maps\odin_intro::intro_cleanup( true );
		case "default":
		default:
	}
	*/
}