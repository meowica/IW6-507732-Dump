#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\oilrocks_code;

CONST_APACHE_HINT_MIN_TIME_MSEC = 1000;

apache_hints_move()
{
	return flag( "FLAG_apache_tut_fly_stop_control_hint" );
}

apache_hints_break_ads()
{
	return self AdsButtonPressed();
}

apache_hints_break_mg()
{
	return self AttackButtonPressed();
}

apache_hints_break_flares()
{
	return self SecondaryOffhandButtonPressed();
}

apache_hints_break_missile_straight()
{
	return self FragButtonPressed();
}

apache_hints_break_missile_straight_hold()
{
	return self FragButtonPressed();
}

MISSILE_NAG_TIME = 1000;

apache_hints_break_missile_lockon()
{
	apache_weapon = get_players_apache_weapon();

	if( !IsDefined( apache_weapon ) )
		return true; // this helps ends rogue hint thread when the player 
	
	return ( IsDefined( apache_weapon.targets_tracking ) && apache_weapon.targets_tracking.size );
}

get_players_apache_weapon()
{
	if ( !IsDefined( level.player.riding_heli ) )
		return;
	apache = level.player.riding_heli;
	if ( !IsDefined( apache.heli ) )
		return;
	heli_info = apache.heli;
	if ( !IsDefined( heli_info ) )
		return;
	if ( !IsDefined( heli_info.pilot ) )
		return;
	pilot = heli_info.pilot;
	if ( !IsDefined( pilot.weapon ) )
		return;
	return pilot.weapon ["hydra_lockOn_missile"];
}


apache_hints_released_homing()
{
	return !level.player FragButtonPressed();
}
