#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
//#include maps\_stealth_utility;

main()
{
	template_level( "iw6_characters_gl" );
	maps\createart\iw6_characters_gl_art::main();
	maps\iw6_characters_gl_fx::main();
	maps\iw6_characters_gl_precache::main();
	maps\_load::main();
	maps\iw6_characters_gl_audio::main();
	
	maps\_idle::idle_main();
	maps\_idle_phone::main();
	maps\_patrol_anims::main();
	
	// Silence! I kill you!
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	thread spawn_guys();
}

spawn_guys()
{
	wait 0.05;
	
	bad_guys 	= getentarray( "bad_guys", "targetname" );
	good_guys 	= getentarray( "good_guys", "targetname" );
	
	foreach( bad_guy in bad_guys )
	{
		//bad_guy.script_forcespawn = 1;
		guy 			= bad_guy spawn_AI( true, true );
		guy.ignoreall 	= 1;
	}
	
	foreach( good_guy in good_guys )
	{
		//good_guy.script_forcespawn = 1;
		guy 			= good_guy spawn_AI( true, true );
		guy.ignoreall 	= 1;
	}	
}