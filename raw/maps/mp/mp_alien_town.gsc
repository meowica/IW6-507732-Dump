/*QUAKED mp_alien_spawn_group0_start (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
Team 0 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_alien_spawn_group1_start (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
Team 1 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_alien_spawn_group2_start (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
Team 2 players spawn at one of these positions at the start of a round.*/

/*QUAKED mp_alien_spawn_group3_start (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
Team 3 players spawn at one of these positions at the start of a round.*/

main()
{
	
		// enables mist for this level, a level needs mist setup to work
	//level.alien_player_spawn_group = true;

    // switches for alien mode systems
    maps\mp\alien\_utility::alien_mode_enable( "kill_resource", "mist", "wave", "airdrop", "lurker", "collectible", "loot" );
    alien_areas = [ "lodge", "city", "lake" ];
    alien_areas_by_cycle = [ "lodge", "lodge", "lodge", "city", "city", "city", "lake", "lake", "lake" ];
    maps\mp\alien\_utility::alien_area_init( alien_areas, alien_areas_by_cycle );
    //maps\mp\alien\_utility::alien_mode_enable( "collectible" );
    
	maps\mp\mp_alien_town_precache::main();
	maps\createart\mp_alien_town_art::main();
	maps\mp\mp_alien_town_fx::main();
	
	maps\mp\_load::main();
	
//	AmbientPlay( "ambient_mp_setup_template" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_alien_town" );
	
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game[ "allies_outfit" ] = "woodland";
 //   game[ "axis_outfit" ] = "desert";
 
	level thread maps\mp\_breach::main();
	
	//Adding start points
	/#
	maps\mp\alien\_debug::add_start( "police_station" );
	//maps\mp\alien\_debug::add_start( "kennel" );
	//maps\mp\alien\_debug::add_start( "cdc" );
	maps\mp\alien\_debug::add_start( "lodging" );
	maps\mp\alien\_debug::add_start( "cabin" );
	//maps\mp\alien\_debug::add_start( "cave_a" );
	//maps\mp\alien\_debug::add_start( "cave_b" );
	#/
	//thread test_meteoroid();	

    if ( !maps\mp\alien\_utility::alien_mode_has( "wave" ) )
		run_alien_mp_combat_prototype();
}

test_meteoroid()
{
	wait 10;
	
	thread maps\mp\alien\_spawnlogic::spawn_alien_meteoroid( "minion" );
	wait 2;
	thread maps\mp\alien\_spawnlogic::spawn_alien_meteoroid( "minion" );
	wait 10;
	thread maps\mp\alien\_spawnlogic::spawn_alien_meteoroid( "minion" );
}

run_alien_mp_combat_prototype()
{
	maps\mp\gametypes\aliens::initAliens();
	level thread maps\mp\gametypes\aliens::runAliens();
}