#include common_scripts\utility;
#include maps\_utility;

main()
{
	pre_sp_load();
	
	maps\_load::main();
	
	post_sp_load();
}

pre_sp_load()
{
	AssertEx( is_specialop(), "maps/_load_so::main() called with special ops not enabled." );
	
	// used by _load::main() to check and see if this load was used for so_ maps.	
	level.so_pre_sp_load = true;
	
	maps\_specialops::clear_custom_eog_summary();
	
	maps\_specialops::specialops_remove_unused();

	// set solo_play dvar correctly upon returning from a friend's game in which you were invited while playing solo play mode previously
	if (  IsSplitScreen() || ( GetDvar( "coop" ) == "1" ) )
		SetSavedDvar( "solo_play", "" );
	
	// survival dvar desync catch
	if ( issubstr( level.script, "so_survival_" ) )
	{
		/# if( getdvar( "so_survival" ) != "1" ) 
				println( "^3WARNING: ^7dvar so_survival is not set while loading a survival map!" ); 
		#/
	}
	else
	{
		/# if( getdvar( "so_survival" ) != "0" ) 
				println( "^3WARNING: ^7dvar so_survival is set while loading non-survival map!" ); 
		#/
	}
	
	// Enable XP
	level.xp_enable	= true;
	if ( in_alien_mode() )
		level.xp_enable	= false;
	
	level.xp_give_func = maps\_rank::updatePlayerScore;
	level.xp_ai_func   = maps\_rank::AI_xp_init;
	
	// Enable Laststand
	level.laststand_player_func = maps\_laststand::player_laststand_proc;
	if ( is_survival() )
	{
		level.laststand_type = 2;
		//setsaveddvar( "so_auto_shared_ammo", 1 );
	}
	else
	{
		level.laststand_type = 1;
	}

// Moved these calls to happen post load because they require the level.players be
// initialized and that happens in _load::main(). This means that these will not
// run if compiling reflections or connecting paths. This shouldn't be an issue.
//	if ( is_coop() )
//		maps\_coop::main();
//		
//	if ( laststand_enabled() )
//		maps\_laststand::main();

	// Add Spec Ops specific _endmission function
	level.endmission_main_func = maps\_endmission_so::main;
}

post_sp_load()
{
	level.so_pre_sp_load = undefined;
	
	maps\_loadout_so::init_loadout();
	
	if ( is_coop() )
		maps\_coop::main();
		
	if ( laststand_enabled() )
		maps\_laststand::main();
	
	// JC-ToDo: Potentially move this into _loadout_so::init_loadout(), right now it happens hear and in _load:main() after load out set
	SetSavedDvar( "ui_campaign", level.campaign );// level.campaign is set in maps\_loadout_so::init_loadout
	
	if ( is_coop() )
		thread maps\_loadout_so::coop_gamesetup_menu();
	
	maps\_specialops::specialops_init();
	
	level notify( "load_finished_so" );
}