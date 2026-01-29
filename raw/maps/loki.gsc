#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\loki_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{
	checkpoint_setup();

	template_level( "loki" );
	maps\createart\loki_art::main();
	maps\loki_fx::main();
	maps\loki_precache::main();

	transient_init( "loki_section_1_tr" );
	transient_init( "loki_section_2_tr" );
	transient_init( "loki_rog_tr" );

	maps\_load::main();
	maps\loki_audio::main();
	maps\loki_anim::main();

	mission_flag_inits();
	mission_precache();
	mission_mains();

	level thread mission_objectives();
	level thread mission_object_control();
	intro_screen_create( &"LOKI_INTROSCREEN_LINE_0", &"LOKI_INTROSCREEN_LINE_1", &"LOKI_INTROSCREEN_LINE_2" );
	intro_screen_custom_func( ::introscreen );
	
	level.JKUdebug = 1;
	
	level.player player_space_helmet();
	space_script_setup();
	
	thread common_scripts\_pipes::main();
	level.pipesDamage = false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

space_script_setup()
{
	// This should only run once
	if( isDefined( level.script_setup ))
	{
		return;
	}
	level.script_setup = true;

	maps\_space_player::init_player_space();
	maps\_space_ai::init_ai_space();
	level.player loki_give_weapons();

	maps\_colors::add_cover_node( "Path 3D" );
	maps\_colors::add_cover_node( "Cover Stand 3D" );
	maps\_colors::add_cover_node( "Cover Right 3D" );
	maps\_colors::add_cover_node( "Cover Left 3D" );
	maps\_colors::add_cover_node( "Cover Up 3D" );
	maps\_colors::add_cover_node( "Exposed 3D" );
	
	maps\_space_player::init_player_space_anims();
	level.water_level_z = level.player.origin[2];	
	level.default_goalradius = 64;
	level.player maps\_space_player::enable_player_space();
	level.player notify( "stop_space_breathe" );
	
	// Turn off all view bob in space
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
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_space_helmet()
{
	SetHUDLighting( true );

	self.hud_space_helmet_rim = self maps\_hud_util::create_client_overlay( "scubamask_overlay_delta", 1, self );
	self.hud_space_helmet_rim.foreground = false;
	self.hud_space_helmet_rim.sort = -99;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

loki_give_weapons()
{
	self thread maps\loki_util::watchADS( "m4m203_space" );
	self TakeAllWeapons();
	self giveWeapon( "m4m203_space" );
	self SwitchToWeapon( "m4m203_space" );
	self DisableWeaponPickup();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

checkpoint_setup()
{
	default_start( ::infil_start );
	set_default_start( "infil" );	

		   //   msg 		    func 			      loc_string      optional_func    transient 		   
	add_start( "infil"		 , ::infil_start	   , "Infil"	   , ::infil		, "loki_section_1_tr" );
	add_start( "combat_one"	 , ::combat_one_start  , "Combat One"  , ::combat_one	, "loki_section_1_tr" );
	add_start( "moving_cover", ::moving_cover_start, "Moving Cover", ::moving_cover , "loki_section_1_tr" );
	add_start( "combat_two"	 , ::combat_two_start  , "Combat Two"  , ::combat_two	, "loki_section_2_tr" );
	add_start( "space_breach", ::space_breach_start, "Space Breach", ::space_breach , "loki_section_2_tr" );
	add_start( "rog"		 , ::rog_start		   , "R.O.G."	   , ::rog			, "loki_rog_tr" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_flag_inits()
{
	// Per section flag inits
	level thread maps\loki_infil::section_flag_inits();
	level thread maps\loki_combat_one::section_flag_inits();
	level thread maps\loki_moving_cover::section_flag_inits();
	level thread maps\loki_combat_two::section_flag_inits();
	level thread maps\loki_space_breach::section_flag_inits();
	level thread maps\loki_rog::section_flag_inits();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_precache()
{
	objective_string_precache();

	PreCacheItem( "acr_space" );
	PreCacheItem( "acr_space_overlay" );
	PreCacheItem( "acr_space_overlay_projectile" );
	PrecacheShader( "hud_xm25_temp" );	
	PrecacheShader( "hud_xm25_scanlines" );	
	PreCacheShader( "apache_target_lock" );
	PreCacheShader( "veh_hud_target_invalid" );

	level thread 	maps\_space::precache();
	
	// Per section precache
	level thread maps\loki_infil::section_precache();
	level thread maps\loki_combat_one::section_precache();
	level thread maps\loki_moving_cover::section_precache();
	level thread maps\loki_combat_two::section_precache();
	level thread maps\loki_space_breach::section_precache();
	level thread maps\loki_rog::section_precache();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_mains()
{
	// Per section main
	level thread maps\loki_infil::section_main();
	level thread maps\loki_combat_one::section_main();
	level thread maps\loki_moving_cover::section_main();
	level thread maps\loki_combat_two::section_main();
	level thread maps\loki_space_breach::section_main();
	level thread maps\loki_rog::section_main();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

objective_string_precache()
{
	PrecacheString( &"LOKI_INTROSCREEN_LINE_0" );
	PrecacheString( &"LOKI_INTROSCREEN_LINE_1" );
	PrecacheString( &"LOKI_INTROSCREEN_LINE_2" );
	PrecacheString( &"LOKI_OBJ_LAND" );
	PrecacheString( &"LOKI_OBJ_ADVANCE" );
	PrecacheString( &"LOKI_OBJ_space_breach" );
	PrecacheString( &"LOKI_OBJ_CLEAR" );
	PrecacheString( &"LOKI_OBJ_PUSH" );
	PrecacheString( &"LOKI_OBJ_SAVE_DAY" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_objectives()
{
	switch( level.start_point )
	{
		case "infil":
			Objective_Add( obj( "obj_land" ), "current", &"LOKI_OBJ_LAND" );
			flag_wait( "infil_done" );

		case "combat_one":
			Objective_Add( obj( "obj_advance" ), "current", &"LOKI_OBJ_ADVANCE" );
			flag_wait( "combat_one_done" );

		case "moving_cover":
			Objective_Add( obj( "obj_space_breach" ), "current", &"LOKI_OBJ_space_breach" );
			flag_wait( "moving_cover_done" );

		case "combat_two":
			Objective_Add( obj( "obj_clear" ), "current", &"LOKI_OBJ_CLEAR" );
			flag_wait( "combat_two_done" );

		case "space_breach":
			Objective_Add( obj( "obj_push" ), "current", &"LOKI_OBJ_PUSH" );
			flag_wait( "space_breach_done" );

		case "rog":
			Objective_Add( obj( "obj_save_day" ), "current", &"LOKI_OBJ_SAVE_DAY" );
			flag_wait( "rog_done" );

	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

mission_object_control()
{
	maps\loki_space_breach::move_controlroom_to_new_location();
	switch( level.start_point )
	{
		case "infil":
			flag_wait( "infil_done" );

		case "combat_one":
			flag_wait( "combat_one_done" );

		case "moving_cover":
			flag_wait( "moving_cover_done" );

		case "combat_two":
			flag_wait( "combat_two_done" );

		case "space_breach":
			flag_wait( "space_breach_done" );

		case "rog":
			flag_wait( "rog_done" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

introscreen()
{
	maps\_introscreen::introscreen( true, 1 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infil_start()
{
	maps\loki_infil::infil_start();
}
infil()
{
	maps\loki_infil::infil();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

combat_one_start()
{
	maps\loki_combat_one::combat_one_start();
	maps\loki_audio::audio_set_initial_ambience();
	
}
combat_one()
{
	maps\loki_combat_one::combat_one();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

moving_cover_start()
{
	maps\loki_moving_cover::moving_cover_start();
}
moving_cover()
{
	maps\loki_moving_cover::moving_cover();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

combat_two_start()
{
	maps\loki_combat_two::combat_two_start();
}
combat_two()
{
	maps\loki_combat_two::combat_two();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

space_breach_start()
{
	maps\loki_space_breach::space_breach_start();
}
space_breach()
{
	maps\loki_space_breach::space_breach();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rog_start()
{
	maps\loki_rog::rog_start();
}
rog()
{
	maps\loki_rog::rog();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
