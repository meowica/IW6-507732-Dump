
main()
{
	
			// enables mist for this level, a level needs mist setup to work
	//level.alien_player_spawn_group = true;

    // switches for alien mode systems
    maps\mp\alien\_utility::alien_mode_enable( "mist", "wave", "airdrop", "lurker", "collectible", "loot" );
    
	maps\mp\mp_alien_spawn_precache::main();
	maps\createart\mp_alien_spawn_art::main();
	maps\mp\mp_alien_spawn_fx::main();
	
	maps\mp\_load::main();
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game[ "allies_outfit" ] = "woodland";
 //   game[ "axis_outfit" ] = "desert";
 
	level thread maps\mp\_breach::main();
       
    if ( !maps\mp\alien\_utility::alien_mode_has( "wave" ) )
		run_alien_mp_combat_prototype();
}

run_alien_mp_combat_prototype()
{
	maps\mp\gametypes\aliens::initAliens();
	level thread maps\mp\gametypes\aliens::runAliens();
}