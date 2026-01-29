#include maps\_utility;
#include common_scripts\utility;
#include maps\_hud_util;
#include maps\oilrocks_infantry_code;

start()
{	
	infantry_teleport_start( "infantry_player_start" );
}

main()
{
	autosave_by_name();
}
