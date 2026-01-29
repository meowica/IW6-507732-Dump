#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_hints_code;
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Apache: Hints
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

apache_hints_precache()
{
	level.oilrocks_apache_hint_timers = [];
	
//	// level.Console and level.player are not set yet so is_player_gamepad_enabled()() can't be used here.
//	if ( GetEntArray( "player", "classname" )[ 0 ] usinggamepad() )
//	{
		//"Take control of the Apache."
		add_hint_string( "hint_apache_move", &"OILROCKS_HINT_APACHE_MOVE", ::apache_hints_move );
		//"Press [{+toggleads_throw}] to zoom camera."
		add_hint_string( "hint_apache_ads", &"OILROCKS_HINT_APACHE_ADS", ::apache_hints_break_ads );
		//"Press [{+speed_throw}] to zoom camera."
		add_hint_string( "hint_apache_ads_hold", &"OILROCKS_HINT_ADS_HOLD", ::apache_hints_break_ads );
		//"Press [{+attack}] to fire machine gun."
		add_hint_string( "hint_apache_mg", &"OILROCKS_HINT_APACHE_MG", ::apache_hints_break_mg );
		//"Press [{+frag}] to fire straight missiles"
		add_hint_string( "hint_apache_missile_straight", &"OILROCKS_HINT_APACHE_MISSILE_STRAIGHT", ::apache_hints_break_missile_straight );
		//"Press [{+smoke}] to release flares."
		add_hint_string( "hint_apache_flares", &"OILROCKS_HINT_APACHE_FLARES", ::apache_hints_break_flares );
		//"Press and Hold [{+frag}] to obtain missile lock"
		add_hint_string( "hint_apache_missile_lockon", &"OILROCKS_HINT_APACHE_MISSILE_LOCKON", ::apache_hints_break_missile_lockon );
		//"Release [{+frag}] to fire homing missile."
		add_hint_string( "hint_apache_missile_lockon_release", &"OILROCKS_HINT_APACHE_MISSILE_LOCKON_RELEASE", ::apache_hints_released_homing );
//	}
//	else
//	{
//		//"Take control of the Apache."
//		add_hint_string( "hint_apache_move", &"OILROCKS_HINT_APACHE_MOVE_PC", ::apache_hints_move );
//		//"Press [{+sprint}] to toggle camera zoom."
//		add_hint_string( "hint_apache_ads", &"OILROCKS_HINT_APACHE_ADS_PC", ::apache_hints_break_ads );
//		//"Press [{+attack}] to fire machine gun."
//		add_hint_string( "hint_apache_mg", &"OILROCKS_HINT_APACHE_MG_PC", ::apache_hints_break_mg );
//		//"Press [{+toggleads_throw}] to fire straight missiles"
//		add_hint_string( "hint_apache_missile_straight", &"OILROCKS_HINT_APACHE_MISSILE_STRAIGHT_PC", ::apache_hints_break_missile_straight );
//		//"Press [{+speed_throw}] to fire straight missiles"
//		add_hint_string( "hint_apache_missile_straight_hold", &"OILROCKS_HINT_APACHE_MISSILE_STRAIGHT_PC_HOLD", ::apache_hints_break_missile_straight_hold );
//		//"Press [{+smoke}] to release flares."
//		add_hint_string( "hint_apache_flares", &"OILROCKS_HINT_APACHE_FLARES_PC", ::apache_hints_break_flares );
//		//"Press and Hold [{+toggleads_throw}] to obtain missile lock"
//		add_hint_string( "hint_apache_missile_lockon", &"OILROCKS_HINT_APACHE_MISSILE_LOCKON_PC", ::apache_hints_break_missile_lockon );
}

apache_hints_display_hint_timeout( hint, timeout )
{
	self display_hint_timeout_mintime( hint, timeout,1 );
}

apache_hints_tutorial()
{
	flag_wait( "introscreen_complete" );
	
	flag_wait_or_timeout( "FLAG_apache_tut_fly_stop_auto_pilot", 3.5 );
	
	if ( !flag( "FLAG_apache_tut_fly_stop_auto_pilot" ) )
	{
		level.player apache_hints_display_hint_timeout( "hint_apache_move", 5.0 );
	}
}

apache_hints_factory()
{
	wait 0.15; // this to allow gamepad to detect
	thread missile_nagging();
	timer = GetTime();
	
	flag_wait( "FLAG_apache_factory_hint_mg" );
	
	wait_for_buffer_time_to_pass( timer, 10 );
	
	level.player apache_hints_display_hint_timeout( "hint_apache_mg", 5.0 );
	
	flag_wait ( "FLAG_apache_factory_player_close" );
	
	flag_wait_or_timeout( "FLAG_apache_factory_hint_missiles", 5.0 );
	
	// If on PC and ads toggle is not bound and the ads hold is bound show ads hold command (+speed_throw) as the hint.
	ads_pc_hold = !level.player is_player_gamepad_enabled() && GetKeyBinding( "+toggleads_throw" )[ "count" ] == 0 && GetKeyBinding( "+speed_throw" )[ "count" ]   > 0;
	
	if ( ads_pc_hold )
	{
		level.player apache_hints_display_hint_timeout( "hint_apache_missile_straight_hold", 5.0 );
	}
	else
	{
		level.player apache_hints_display_hint_timeout( "hint_apache_missile_straight", 5.0 );
	}
}

apache_hints_chase()
{
	if ( level.apache_difficulty.flares_auto )
		return;
	
	flag_wait( "FLAG_apache_factory_finished" );
	wait 3.0;

	level.player apache_hints_display_hint_timeout( "hint_apache_flares", 5.0 );
}

apache_hints_escort()
{
	flag_wait( "FLAG_apache_escort_allies_01" );
	
	if ( GetKeyBinding( "+toggleads_throw" )[ "count" ]  > 0 )
		level.player apache_hints_display_hint_timeout( "hint_apache_ads", 5.0 );
	else
		level.player apache_hints_display_hint_timeout( "hint_apache_ads_hold", 5.0 );
}

apache_hints_chopper()
{
	level endon( "FLAG_apache_chopper_finished" );
	
	flag_wait( "FLAG_apache_chopper_vo_take_it_done" );
	thread missile_nagging();
}

hint_missile_lock()
{
	level notify ( "new_hint_missile_lock" );
	level endon ( "new_hint_missile_lock" );
	
	
	hintstring =  "hint_apache_missile_lockon" ;
	hintstringRelease =  "hint_apache_missile_lockon_release" ;
	
	level.player apache_hints_display_hint_timeout( hintstring, 5.0 );
	
	
	// self killing missile nag thread.
	thread missile_nagging();
	
	while( !check_hint_condition( hintstring ) )
	{
		wait 0.05;
		if( !IsDefined( level.player.riding_heli ) )
			return;
	}
	
	display_hint_timeout_mintime( hintstringRelease, 5 );
	
}

apache_hints_finale()
{
	
}

MISSILE_NAG_TIME = 40000;

missile_nagging()
{
	level notify ( "new_missile_nag_thread" );
	level endon ( "new_missile_nag_thread" );
	
	level.player endon ( "death" );
	
	if ( !IsDefined( level.last_missile_nagging_nagged_time ) )
		level.last_missile_nagging_nagged_time = GetTime() - 20000; //track locally since the last_lockon_fire_time can be unset for a while.
	
	while ( true )
	{
		wait 0.05;
		if ( !IsDefined( level.player.riding_heli ) )
			continue;
		
		if ( GetTime() - level.last_missile_nagging_nagged_time < 20000 )
			continue;
	
		//walk up the struct tree and find out if the player is firing hydra's.
		//basically if the player hasn't fired the hydra in a while, and something is targetting throw up a hint!
		if ( !IsDefined( level.player.last_lockon_fire_time ) || GetTime() - level.player.last_lockon_fire_time > MISSILE_NAG_TIME )
		{
			if ( IsDefined( level.player.riding_heli ) )
			{
				apache = level.player.riding_heli;
				
				if ( IsDefined( apache.heli ) )
				{
					heli_info = apache.heli;
					if ( IsDefined( heli_info ) )
					{
						if ( IsDefined( heli_info.pilot ) )
						{
							pilot = heli_info.pilot;
							if ( IsDefined( pilot.weapon ) )
							{
								weapon_info = pilot.weapon ["hydra_lockOn_missile"];
								if ( Target_GetArray().size )
								{
									level.last_missile_nagging_nagged_time = GetTime();
									thread hint_missile_lock();
								}
							}
						}
					}
				}
			}
		}
	}
}

