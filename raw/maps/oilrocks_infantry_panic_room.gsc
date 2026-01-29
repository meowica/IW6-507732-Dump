#include maps\_utility;
#include common_scripts\utility;
#include maps\oilrocks_infantry_code;

start()
{
	infantry_teleport_start( "infantry_panic_room_start" );
}

main()
{
	tempEND = GetEnt( "TEMP_end_infantry_upper", "targetname" );
	tempEND waittill ( "trigger" );
	wait 3;
	nextmission();
}