#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\_hud_util;

main()
{
	/* for NxLauncher!
	add_start( "apache_tutorial_fly" );
	add_start( "apache_factory" );
	add_start( "apache_chase" );
	add_start( "apache_escort" );
	add_start( "apache_chopper" );
	add_start( "apache_finale" );
	add_start( "apache_landing" );
	add_start( "infantry" );
	add_start( "infantry_b" );
	add_start( "infantry_upper" );
	add_start( "infantry_elevator" );
	add_start( "infantry_panic_room" );
	*/
	
	maps\oilrocks_apache_landing::_precache();
	maps\oilrocks_apache_code::apache_precache();
	maps\oilrocks_infantry_elevator::_precache();
	maps\oilrocks_slamzoom::precache_zoom();

	
	maps\oilrocks_apache_starts::main();
	maps\oilrocks_infantry_starts::main();
	
	//""Oil Rocks""
	//"Somewhere Cool"
	//"October 9th - 07:42:[{FAKE_INTRO_SECONDS:17}]"
	intro_screen_create( &"OILROCKS_INTROSCREEN_LINE_1", &"OILROCKS_INTROSCREEN_LINE_5", &"OILROCKS_INTROSCREEN_LINE_2" );
	
	maps\createart\oilrocks_art::main();
	maps\oilrocks_fx::main();
	maps\oilrocks_precache::main();

	maps\_load::main();
	maps\oilrocks_audio::main();
}