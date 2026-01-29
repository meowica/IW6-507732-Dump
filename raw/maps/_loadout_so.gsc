#include maps\_utility;
#include common_scripts\utility;
#include maps\_loadout_code;

init_loadout()
{
	if ( !IsDefined( level.campaign ) )
		level.campaign = "american";

	if ( !IsDefined( level.dodgeloadout ) )
		give_loadout();
	loadout_complete();
}

// checks if character switched in coop mode, if so returns true, call once.
char_switcher()
{
	level.coop_player1 = level.player;
	level.coop_player2 = level.player2;

	if ( IsDefined( level.character_switched ) && level.character_switched )
	{
		if ( is_coop() )
		{
			array_thread( level.players, ::init_player );
			level.character_switched = true;
			return true;
		}
		else
		{
			level.player init_player();
			level.character_switched = true;
			return true;
		}
	}
	return false;
}

give_loadout()
{
    loadout_name = get_loadout();

	level.player SetDefaultActionSlot();
	if ( is_coop() )
		level.player2 SetDefaultActionSlot();

    loadout_name = get_loadout();

	if ( loadout_name == "so_nyse_ny_manhattan" )
	{
		level.so_campaign = "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "m4_hybrid_grunt_optim";
			secondary = "xm25";
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();			
		
		return;
	}
	
	if ( loadout_name == "so_stealth_warlord" )
	{
		level.so_campaign		= "delta";
		level.coop_incap_weapon = level.so_warlord_secondary;
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			so_player_giveWeapon( level.so_warlord_primary );
			so_player_giveWeapon( level.so_warlord_secondary );
			so_player_set_switchToWeapon( level.so_warlord_primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
		
	if ( loadout_name == "so_littlebird_payback" )
	{
		level.so_campaign	= "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			so_player_giveWeapon( level.so_payback_primary );
			so_player_giveWeapon( level.so_payback_secondary );
			so_player_set_switchToWeapon( level.so_payback_primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
		
	if ( loadout_name == "so_ied_berlin" )
	{
		level.so_campaign = "delta";
		
		if ( is_coop() )
		{
			if ( GetDvar( "coop_start" ) == "so_char_host" )
			{
				jugg_player	  = 0;
				sniper_player = 1;
			}
			else
			{
				jugg_player	  = 1;
				sniper_player = 0;
			}
		}
		else
		{
			jugg_player	  = 0;
			sniper_player = 1;
		}
		// Juggernaut guy
		so_player_num( jugg_player );

		so_player_giveWeapon( "fraggrenade" );
		so_player_giveWeapon( "flash_grenade" );
		so_player_set_setOffhandSecondaryClass( "flash" );
		so_player_giveWeapon( "sa80lmg_fastreload_reflex" );
		so_player_giveWeapon( "m320" );
		so_player_set_switchToWeapon( "sa80lmg_fastreload_reflex" );
		
		so_player_setup_body( jugg_player );

		// Support guy
		so_player_num( sniper_player );
		
		so_player_giveWeapon( "fraggrenade" );
		so_player_giveWeapon( "semtex_grenade" );
		so_player_set_setOffhandSecondaryClass( "semtex_grenade" );
		so_player_giveWeapon( "barrett" );
		so_player_giveWeapon( "scar_h_thermal_silencer" );
		so_player_set_switchToWeapon( "barrett" );
		
//		so_player_giveWeapon("claymore");
//		
		so_player_setup_body( sniper_player );
		
		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_assault_rescue_2" )
	{
		default_weapon	  = "m4_grunt_acog";
		level.so_campaign = "delta";

		foreach ( i, player in level.players )
		{
			so_player_num( i );	
				
			so_player_giveWeapon( default_weapon );
			so_player_set_maxammo( default_weapon );
			so_player_giveWeapon( "g36c_reflex" );
			so_player_set_maxammo( "g36c_reflex" );
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );								
			so_player_setup_body( i );	
			so_player_set_switchToWeapon( default_weapon );
					
		}	
		
		so_players_give_loadout();		
		return;
	}	
	
	if ( loadout_name == "so_heliswitch_berlin" )
	{
		level.so_campaign = "delta";	
		
		foreach ( i, player in level.players )
		{

			so_player_num( i );
			
			Assert( IsDefined( level.primary_weapon ) );
			Assert( IsDefined( level.secondary_weapon ) );
			
			so_player_giveWeapon( level.primary_weapon );
			so_player_giveWeapon( level.secondary_weapon );
			so_player_set_switchToWeapon( level.primary_weapon );


			so_player_giveWeapon( "fraggrenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			so_player_giveWeapon( "flash_grenade" );
			
			so_player_setup_body( i );
		}

		so_players_give_loadout();
		
		return;
	}

	if ( loadout_name == "so_killspree_paris_a" )
	{
		level.so_campaign = "ranger";
	
		so_player_num( 0 );
		so_player_giveWeapon( "fraggrenade" );
		so_player_giveWeapon( "flash_grenade" );
		so_player_set_setOffhandSecondaryClass( "flash" );
		so_player_giveWeapon( "pecheneg_so_fastreload" );
		so_player_giveWeapon( "m320" );
		so_player_set_switchToWeapon( "pecheneg_so_fastreload" );
		so_player_setup_body( 0 );

		so_player_num( 1 );
		so_player_giveWeapon( "fraggrenade" );
		so_player_giveWeapon( "flash_grenade" );
		so_player_set_setOffhandSecondaryClass( "flash" );
		so_player_giveWeapon( "pecheneg_so_fastreload" );
		so_player_giveWeapon( "m320" );
		so_player_set_switchToWeapon( "m320" );
		so_player_setup_body( 1 );
		

		
		so_players_give_loadout();
		
		return;
	}

	
	if ( loadout_name == "so_zodiac2_ny_harbor" )
	{
		level.so_campaign = "delta";
		
		
		foreach ( i, player in level.players )
		{

			so_player_num( i );
			
			Assert( IsDefined( level.primary_weapon ) );
			Assert( IsDefined( level.secondary_weapon ) );
			
			so_player_giveWeapon( level.primary_weapon );
			so_player_giveWeapon( level.secondary_weapon );
			so_player_set_switchToWeapon( level.primary_weapon );

			so_player_giveWeapon( "fraggrenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			so_player_giveWeapon( "flash_grenade" );
			
			so_player_setup_body( i );
		}

		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_jeep_paris_b" )
	{
		level.so_campaign = "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "m320";
			secondary = "scar_h_grenadier_reflex";
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_awolf" )
	{
		level.so_campaign = "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
		
			primary	  = "m4m203_reflex";
			secondary = "fnfiveseven";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_stealth_prague" )
	{
		level.so_campaign		= "sas";
		level.so_stealth		= true;
		level.coop_incap_weapon = "usp_silencer";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "rsass_silenced";
			secondary = "usp_silencer";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}

	if ( loadout_name == "so_stealth_london" )
	{
		level.so_campaign = "sas";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "mp5_silencer_eotech";
			secondary = "usp_silencer";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}

	if ( loadout_name == "so_timetrial_london" )
	{
		level.so_campaign = "sas";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "mp5";
			secondary = "spas12_silencer";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_assaultmine" )
	{
		level.so_campaign = "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "rsass";
			secondary = "acr_hybrid";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_deltacamp" )
	{
		level.so_campaign = "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "acr";
			secondary = "usp";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_trainer2_so_deltacamp" )
	{
		level.so_campaign = "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "mp5";
			secondary = "usp";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
	if ( loadout_name == "so_milehigh_hijack" )
	{
		level.so_campaign = "hijack";
	
		for ( i = 0; i < level.players.size; i++ )
		{
			so_player_num( i );
	
			so_player_giveWeapon( "flash_grenade" );
			so_player_set_setOffhandSecondaryClass( "flash" );
	
			so_player_giveWeapon( "ak47" );
			so_player_giveWeapon( "fnfiveseven" );
			so_player_set_switchToWeapon( "ak47" );
	
			so_player_setup_body( i );
		}
	
		so_players_give_loadout();
		return;
	}

	if ( loadout_name == "so_rescue_hijack" )
	{
		level.so_campaign		= "fso";
		level.coop_incap_weapon = "usp_silencer_so";

		foreach ( i, player in level.players )
		{
			so_player_num( i );
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "usp_silencer_so" );
			so_player_set_switchToWeapon( "usp_silencer_so" );
			so_player_setup_body( i );
		}
		so_players_give_loadout();
		return;
	}
		
	
	if ( loadout_name == "so_javelin_hamburg" )
	{
		level.so_campaign = "delta";
		
		foreach ( i, player in level.players )
		{
			so_player_num( i );
			
			primary	  = "javelin";
			secondary = "scar_h_acog";
			
			so_player_giveWeapon( primary );
			so_player_giveWeapon( secondary );
			so_player_set_switchToWeapon( primary );
			
			so_player_giveWeapon( "fraggrenade" );
			so_player_giveWeapon( "flash_grenade" );
			
			so_player_setup_body( i );
		}
		
		so_players_give_loadout();
		
		return;
	}
	
	if ( loadout_name == "so_assassin_payback" )
	{
		level.so_campaign = "delta";
		
		// primary player is sniper
		so_player_num( 0 );
		so_player_giveWeapon( level.sniper_primary );
		so_player_giveWeapon( level.sniper_secondary );
		so_player_set_switchToWeapon( level.sniper_primary );
		so_player_giveWeapon( "fraggrenade" );
		so_player_giveWeapon( "flash_grenade" );
		so_player_setup_body( 0 );
		
		// secondary player is heavy
		so_player_num( 1 );
		so_player_giveWeapon( level.heavy_primary );
		so_player_giveWeapon( level.heavy_secondary );
		so_player_set_switchToWeapon( level.heavy_primary );
		so_player_giveWeapon( "fraggrenade" );
		so_player_giveWeapon( "flash_grenade" );
		so_player_setup_body( 1 );

		so_players_give_loadout();
		
		return;
	}
	
	// third mode levels
	if ( loadout_name == "so_coop_greenlight_alien_demo" )
	{
		level.so_campaign = "thirdmode";
		alien_loadout();
		return;
	}

	if ( is_survival() )
	{
		level.so_campaign = "delta";
		
		// default for survival to have fnfiveseven_mp as last stand pistol
		// per level loadout pistol will override this
		level.coop_incap_weapon = "fnfiveseven_mp";
		
		// give default for now, option to be replaced later by survival script
		give_default_loadout();
		return;
	}

	// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	/#
	PrintLn( "loadout.gsc:     No level listing in _loadout::give_loadout_specialops(), giving default guns" );
	#/
	level.map_without_loadout	  = true;
	level.so_campaign = "ranger";
	
	give_default_loadout();
}

alien_loadout()
{
	if ( is_coop() || is_survival() )
	{
		switch_char = char_switcher();

		foreach ( i, player in level.players )
			give_default_loadout_coop( i );

		so_players_give_loadout();
		return;
	}

//	level.player GiveWeapon( "fraggrenade" );
//	level.player SetOffhandSecondaryClass( "flash" );
//	level.player GiveWeapon( "flash_grenade" );
//	if ( is_specialop() )
//		level.player GiveWeapon( "ak47_alien" );
//	level.player GiveWeapon( "aa12_alien" );
//	level.player SwitchToWeapon( "aa12_alien" );
	level.player SetViewModel( "viewhands_gs_hostage" );
}

give_default_loadout()
{
	if ( is_coop() || is_survival() )
	{
		switch_char = char_switcher();

		foreach ( i, player in level.players )
			give_default_loadout_coop( i );

		so_players_give_loadout();
		return;
	}

//	level.player GiveWeapon( "fraggrenade" );
//	level.player SetOffhandSecondaryClass( "flash" );
//	level.player GiveWeapon( "flash_grenade" );
//	if ( is_specialop() )
//		level.player GiveWeapon( "ak47_alien" );
//	level.player GiveWeapon( "aa12_alien" );
//	level.player SwitchToWeapon( "aa12_alien" );
//	level.player SetViewModel( "viewmodel_base_viewhands" );
}

give_default_loadout_coop( num )
{
	so_player_num( num );
//	so_player_giveWeapon( "fraggrenade" );
//	so_player_giveWeapon( "flash_grenade" );
//	so_player_set_setOffhandSecondaryClass( "flash" );
//	so_player_giveWeapon( "ak47_alien" );
//	so_player_giveWeapon( "aa12_alien" );
//	if ( num == 0 )
//		so_player_set_switchToWeapon( "ak47_alien" );
//	else
//		so_player_set_switchToWeapon( "aa12_alien" );
	so_player_setup_body( num );
}

//======================prototype=======================
// coop character selection script:

coop_gamesetup_menu()
{
	Assert( is_coop() );
		
	// update difficulty:
	maps\_gameskill::setGlobalDifficulty();

	array_thread( level.players, maps\_gameskill::setDifficulty );

	// character selection: 
	level.character_switched = false;
	flag_init( "character_selected" );

	
	// TODO: This crap even exist anymore?
	char_select_coop_ac130 = "so_ac130_co_hunted co_hunted co_ac130";
	levels_array_ac130	   = [];
	levels_array_ac130	   = StrTok( char_select_coop_ac130, " " );

	foreach ( level_string in levels_array_ac130 )
	{
		if ( is_coop() && ( level_string == level.script ) )
		{
			pilot_num = GetDvar( "ui_ac130_pilot_num" );
			
			if ( IsDefined( pilot_num ) && pilot_num != "0" )
				level.character_switched = true;
			
			flag_set( "character_selected" );
		}
	}
}

give_default_loadout_specialops()
{
	foreach ( i, player in level.players )
	{
		so_player_num( i );
		so_player_giveWeapon( "fraggrenade" );
		so_player_giveWeapon( "flash_grenade" );
		so_player_set_setOffhandSecondaryClass( "flash" );
		so_player_giveWeapon( "mp5" );
		so_player_giveWeapon( "m1014" );
		so_player_set_switchToWeapon( "mp5" );
		so_player_setup_body( i );
	}
	so_players_give_loadout();
}

so_player_num( num )
{
	level.so_player_num							 = num;
	level.so_player_add_player_giveWeapon[ num ] = [];

	// level vars if this becomes more commmonly used should put the init somewhere above the loadout section.	
	if ( !IsDefined( level.so_player_set_maxammo ) )
		level.so_player_set_maxammo = [];
	if ( !IsDefined( level.so_player_set_setViewmodel ) )
		level.so_player_set_setViewmodel = [];
	if ( !IsDefined( level.so_player_add_player_giveWeapon ) )
		level.so_player_add_player_giveWeapon = [];
	if ( !IsDefined( level.so_player_set_setOffhandSecondaryClass ) )
		level.so_player_set_setOffhandSecondaryClass = [];
	if ( !IsDefined( level.so_player_set_switchToWeapon ) )
		level.so_player_set_switchToWeapon = [];
	if ( !IsDefined( level.so_player_SetModelFunc ) )
		level.so_player_SetModelFunc = [];
	if ( !IsDefined( level.so_player_SetModelFunc_precache ) )
		level.so_player_SetModelFunc_precache = [];
	if ( !IsDefined( level.so_player_SetActionSlot ) )
		level.so_player_SetActionSlot = [];

	level.so_player_set_maxammo					[ num ] = [];
	level.so_player_set_setOffhandSecondaryClass[ num ] = [];
	level.so_player_add_player_giveWeapon		[ num ] = [];
}

so_player_giveWeapon( weapon )
{
	Assert( IsDefined( level.so_player_num ) );
	num = level.so_player_num;
	PreCacheItem( weapon );
	level.so_player_add_player_giveWeapon[ num ][ weapon ] = 1;
}

so_player_set_maxammo( weapon )
{
	Assert( IsDefined( level.so_player_num ) );
	level.so_player_set_maxammo[ level.so_player_num ][ weapon ] = 1;
}

so_player_set_setOffhandSecondaryClass( weapon )
{
	Assert( IsDefined( level.so_player_num ) );
	level.so_player_set_setOffhandSecondaryClass[ level.so_player_num ] = weapon;
}

so_player_set_switchToWeapon( weapon )
{
	Assert( IsDefined( level.so_player_num ) );
	level.so_player_set_switchToWeapon[ level.so_player_num ] = weapon;
}

so_player_set_setViewmodel( model )
{
	Assert( IsDefined( level.so_player_num ) );
	PreCacheModel( model );
	level.so_player_set_setViewmodel[ level.so_player_num ] = model;
}

so_player_SetModelFunc( func, precache_func )
{
	Assert( IsDefined( level.so_player_num ) );
	level.so_player_SetModelFunc[ level.so_player_num ] = func;
	Assert( IsDefined( precache_func ) );
	[[ precache_func ]]();

}

#using_animtree( "multiplayer" );


so_player_give_loadout( num )
{
	player = self;

	if ( IsDefined( level.so_player_SetModelFunc[ num ] ) )
	{
		player maps\_specialops::so_setmodelfunc( level.so_player_SetModelFunc[ num ] );
		player SetAnim( %code, 1, 0 );
	}

	weapons = GetArrayKeys( level.so_player_add_player_giveWeapon[ num ] );
	foreach ( weapon in weapons )
	{
		player GiveWeapon( weapon );
		if ( IsDefined( level.so_player_set_maxammo[ num ][ weapon ] ) )
			player GiveMaxAmmo( weapon );
	}

	if ( IsDefined( level.so_player_set_setOffhandSecondaryClass[ num ] ) )
		player SetOffhandSecondaryClass( "flash" );

	if ( IsDefined( level.so_player_SetActionSlot[ num ] ) )
		player so_players_give_action( num );

	if ( IsDefined( level.so_player_set_switchToWeapon[ num ] ) )
		player SwitchToWeapon( level.so_player_set_switchToWeapon[ num ] );

	if ( IsDefined( level.so_player_set_setViewmodel[ num ] ) )
		player SetViewModel( level.so_player_set_setViewmodel[ num ] );
}

so_players_give_action( num )
{
	player = self;
	
	foreach ( struct in level.so_player_SetActionSlot[ num ] )
	{
		if ( IsDefined( struct.parm2 ) )
			player SetActionSlot( struct.slot, struct.parm1, struct.parm2 );
		else
			player SetActionSlot( struct.slot, struct.parm1 );
	}
}

so_players_give_loadout()
{
	foreach ( playerIndex, player in level.players )
	{
		player so_player_give_loadout( playerIndex );
	}
}

UpdateModel( modelFunc )
{

	self notify( "newupdatemodel" );

	if ( !IsDefined( modelFunc ) )
	{
		self DetachAll();
		self SetModel( "" );
		return;
	}

	self.last_modelfunc = modelFunc;

	if ( IsDefined( self.is_hidden ) && self.is_hidden )
		return;

	self endon( "newupdatemodel" );

	for ( ;; )
	{
		self DetachAll();

		[[ modelFunc ]]();

		self UpdatePlayerModelWithWeapons();

		self waittill_any_return( "weapon_change", "weaponchange", "player_update_model", "player_downed", "not_in_last_stand" );
	}
}

so_player_setup_body( num )
{
	so_player_set_setViewmodel( so_player_get_hands() );
	
	// survival is added to condition due to sentry gun PIP seeing player
	if ( is_coop() || is_survival() )
		so_player_SetModelFunc( so_player_get_bodyfunc( num ), so_player_get_bodyfunc_precache( num ) );
}

so_player_get_bodyfunc( num )
{
	switch ( level.so_campaign )
	{
		case "ranger"		:		return ::so_body_player_ranger;
		case "seal"			:		return ::so_body_player_seal;
		case "arctic"		:		return ::so_body_player_arctic;
		case "woodland"		:		return ::so_body_player_woodland;
		case "desert"		:		return ::so_body_player_desert;
		case "ghillie"		:		return ::so_body_player_ghillie;
		case "delta"		:		return ::so_body_player_delta;
		case "sas"			:		return ::so_body_player_sas;
		case "thirdmode"	: 		return ::so_body_player_thirdmode;
		case "hijack":
			if ( num == 0 )
			{
				return ::so_body_player_hijack_1;
			}
			else
			{
				return ::so_body_player_hijack_2;
			}
		case "fso":
			if ( num == 0 )
			{
				return ::so_body_player_fso_1;
			}
			else
			{
				return ::so_body_player_fso_2;
			}
		default:			AssertEx( false, "Special Ops requires level.campaign to be set to a valid value in order to setup the character body." );	
	}
	return;
}

so_player_get_bodyfunc_precache( num )
{
	switch ( level.so_campaign )
	{
		case "ranger"		:		return ::so_body_player_ranger_precache;
		case "seal"			:		return ::so_body_player_seal_precache;
		case "arctic"		:		return ::so_body_player_arctic_precache;
		case "woodland"		:		return ::so_body_player_woodland_precache;
		case "desert"		:		return ::so_body_player_desert_precache;
		case "ghillie"		:		return ::so_body_player_ghillie_precache;
		case "delta"		:		return ::so_body_player_delta_precache;
		case "sas"			:		return ::so_body_player_sas_precache;
		case "thirdmode"	:		return ::so_body_player_thirdmode_precache;
		case "hijack":
			if ( num == 0 )
			{
				return ::so_body_player_hijack_precache_1;
			}
			else
			{
				return ::so_body_player_hijack_precache_2;
			}
		case "fso":
			if ( num == 0 )
			{
				return ::so_body_player_fso_precache_1;
			}
			else
			{
				return ::so_body_player_fso_precache_2;
			}
	}
	return;
}

so_player_get_hands()
{
	switch ( level.so_campaign )
	{
		case "ranger"		:		return "viewmodel_base_viewhands";
		case "seal"			:		return "viewhands_udt";
		case "arctic"		:		return "viewhands_arctic";
		case "woodland"		:		return "viewhands_sas_woodland";
		case "desert"		:		return "viewhands_tf141";
		case "ghillie"		:		return "viewhands_marine_sniper";
		case "delta"		:		return "viewhands_delta";
		case "sas"			:		return "viewhands_sas";
		case "hijack"		:		return "viewhands_henchmen";
		case "fso"			:		return "viewhands_fso";
		case "thirdmode"	:		return "viewhands_gs_hostage"; //temp until new survivalist characters are chosen
	}
}

so_body_player_thirdmode()			{ self SetModel( "mp_body_russian_military_assault_a_woodland" ); self Attach( "head_russian_military_a", "", true ); }
so_body_player_ranger()				{ self SetModel( "coop_body_us_army" );				self Attach( "coop_head_us_army", "", true ); }
so_body_player_seal()				{ self SetModel( "coop_body_seal_udt" );			self Attach( "coop_head_seal_udt", "", true ); }
so_body_player_arctic()				{ self SetModel( "coop_body_tf141_arctic" );		self Attach( "coop_head_tf141_arctic", "", true ); }
so_body_player_woodland()			{ self SetModel( "coop_body_tf141_forest" );		self Attach( "coop_head_tf141_forest", "", true ); }
so_body_player_desert()				{ self SetModel( "coop_body_tf141_desert" );		self Attach( "coop_head_tf141_desert", "", true ); }
so_body_player_ghillie()			{ self SetModel( "coop_body_ghillie_forest" );		self Attach( "coop_head_ghillie_forest", "", true ); }
so_body_player_delta()				{ self SetModel( "mp_body_delta_elite_assault_bb" ); self Attach( "head_delta_elite_a", "", true ); }
so_body_player_sas()				{ self SetModel( "mp_body_delta_elite_assault_bb" ); self Attach( "head_delta_elite_a", "", true ); } // This was changed from old cod4 SAS to something that works with the new rig
so_body_player_hijack_1()			{ self SetModel( "mp_body_henchmen_assault_d" ); self Attach( "head_henchmen_a", "", true ); }
so_body_player_hijack_2()			{ self SetModel( "mp_body_henchmen_shotgun_a" ); self Attach( "head_henchmen_c", "", true ); }
so_body_player_fso_1()				{ self SetModel( "mp_body_fso_vest_c_dirty" ); self Attach( "head_fso_e_dirty", "", true );	}
so_body_player_fso_2()				{ self SetModel( "mp_body_fso_vest_d_dirty" ); self Attach( "head_fso_d_dirty", "", true );	}

so_body_player_thirdmode_precache()	{ PreCacheModel( "mp_body_russian_military_assault_a_woodland" ); PreCacheModel( "head_russian_military_a" ); }
so_body_player_ranger_precache()	{ PreCacheModel( "coop_body_us_army" );				PreCacheModel( "coop_head_us_army" ); }
so_body_player_seal_precache()		{ PreCacheModel( "coop_body_seal_udt" );			PreCacheModel( "coop_head_seal_udt" ); }
so_body_player_arctic_precache()	{ PreCacheModel( "coop_body_tf141_arctic" );		PreCacheModel( "coop_head_tf141_arctic" ); }
so_body_player_woodland_precache()	{ PreCacheModel( "coop_body_tf141_forest" );		PreCacheModel( "coop_head_tf141_forest" ); }
so_body_player_desert_precache()	{ PreCacheModel( "coop_body_tf141_desert" );		PreCacheModel( "coop_head_tf141_desert" ); }
so_body_player_ghillie_precache()	{ PreCacheModel( "coop_body_ghillie_forest" );		PreCacheModel( "coop_head_ghillie_forest" ); }
so_body_player_delta_precache()		{ PreCacheModel( "mp_body_delta_elite_assault_bb" ); PreCacheModel( "head_delta_elite_a" ); }
so_body_player_sas_precache()		{ PreCacheModel( "body_mp_sas_urban_specops" ); }
so_body_player_hijack_precache_1()	{ PreCacheModel( "mp_body_henchmen_assault_d" );	PreCacheModel( "head_henchmen_a" ); }
so_body_player_hijack_precache_2()	{ PreCacheModel( "mp_body_henchmen_shotgun_a" );	PreCacheModel( "head_henchmen_c" ); }
so_body_player_fso_precache_1()		{ PreCacheModel( "mp_body_fso_vest_c_dirty" );	PreCacheModel( "head_fso_e_dirty" ); }
so_body_player_fso_precache_2()		{ PreCacheModel( "mp_body_fso_vest_d_dirty" );	PreCacheModel( "head_fso_d_dirty" ); }