#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	template_level( "iw6_characters_whiteroom" );
	maps\createart\iw6_characters_whiteroom_art::main();
	maps\iw6_characters_whiteroom_fx::main();
	maps\iw6_characters_whiteroom_precache::main();
	maps\_load::main();
	maps\iw6_characters_whiteroom_audio::main();
	
	battlechatter_off();

	level.player TakeWeapon( "flash_grenade" );
	level.player TakeWeapon( "fraggrenade" );
	maps\_modelspawner::init_modelspawner();
	
//	level.use_behavior = "Change_Walls";
	
	// custom use behavior
//	list = [ "Change_Walls" ];
//	level.custom_use_func = ::custom_use_func;
	thread change_walls_thread();
	
}

change_walls_thread()
{
	black_walls = GetEnt( "black_walls", "targetname" );
	black_walls Hide();
	level.current_walls = "white_walls";

	while ( 1 )
	{
		if ( level.player FragButtonPressed() )
		{
			change_walls();
			wait( 0.2 );
		}
		
		wait( 0.1 );
	}
}

change_walls()
{
	white_walls = GetEnt( "white_walls", "targetname" );
	black_walls = GetEnt( "black_walls", "targetname" );

	if ( level.current_walls == "white_walls" )
	{
		level.current_walls = "black_walls";
		white_walls Hide();
		black_walls Show();
	}
	else if ( level.current_walls == "black_walls" )
	{
		level.current_walls = "white_walls";
		white_walls Show();
		black_walls Hide();			
	}
}
