#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\agents\_agent_utility;
#include maps\mp\alien\_utility;

main()
{
	maps\mp\mp_alien_pathing_precache::main();
	maps\createart\mp_alien_pathing_art::main();
	maps\mp\mp_alien_pathing_fx::main();
	
	maps\mp\_load::main();
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";

	//maps\mp\gametypes\aliens::initAliens();
	//level thread maps\mp\gametypes\aliens::runAliens();
	
	//self thread runAliens();
	//level thread path_to_corners();
	//level thread path_to_sides();
	level thread wall_jump_test();
	level thread combat_test();
}

/*runAliens()
{
	spawnpoint = GetStruct( "alien_spawn", "script_noteworthy" );
	goalent = GetEnt( "alien_goal", "script_noteworthy" );
	while ( 1 )
	{
		alien = maps\mp\gametypes\aliens::addAlienAgent( "axis", spawnpoint.origin, spawnpoint.angles );
		alien ScrAgentSetGoalEntity( goalEnt );
		alien ScrAgentSetGoalRadius( 32 );
	}
}*/

// This test will path to a corner, then update the path to a node around that corner.
// Currently the turns nearly always do not play in this case
path_to_corners()
{
	wait 0.05;
	spawnpoint = GetStruct( "alien_spawn", "targetname" );
	mid_goal = GetNode( "alien_turn", "script_noteworthy" );
	end_goal = GetNode( "alien_turn_end", "script_noteworthy" );	
	alien = undefined;
	while ( !isDefined( alien ) )
	{
		alien = maps\mp\gametypes\aliens::addAlienAgent( "axis", spawnpoint.origin, (0,0,0) );
		wait 0.05;
	}
	alien enable_alien_scripted();
	alien.ignoreall = true;
	alien ScrAgentSetGoalRadius( 32 );
	while ( 1 )
	{
		alien ScrAgentSetGoalNode( mid_goal );
		alien waittill( "goal_reached" );
		wait 0.05;
		alien ScrAgentSetGoalNode( end_goal );
		alien waittill( "goal_reached" );		
		wait 0.05;
		alien ScrAgentSetGoalNode( mid_goal );
		alien waittill( "goal_reached" );
		wait 0.05;
		alien ScrAgentSetGoalPos( spawnpoint.origin );
		wait 0.5;
		alien ScrAgentSetGoalRadius( 32 );
		alien waittill( "goal_reached" );		
		wait 0.05;
	}
}

// This test will path around a corner, then update the path to return around that same corner.
// The corner turn will play unreliably.  When updating the path to suddenly going the opposite
// direction, no turn is player.  The alien will slide around 180.

// Note that at the start point there is a slightly raised step - their lookahead will jump around in all four
// directions when starting the path from that location.  They don't seem to be handling steps very well.
path_to_sides()
{
	wait 0.05;
	spawnpoint = GetStruct( "alien_spawn2", "targetname" );
	mid_goal = GetNode( "alien_turn2", "script_noteworthy" );
	end_goal = GetNode( "alien_turn_end2", "script_noteworthy" );	
	alien = undefined;
	while ( !isDefined( alien ) )
	{
		alien = maps\mp\gametypes\aliens::addAlienAgent( "axis", spawnpoint.origin, (0,0,0) );
		wait 0.05;
	}
	alien enable_alien_scripted();
	alien.ignoreall = true;
	alien ScrAgentSetGoalRadius( 32 );
	while ( 1 )
	{
		alien ScrAgentSetGoalNode( mid_goal );
		alien waittill( "goal_reached" );
		wait 0.05;
		alien ScrAgentSetGoalNode( end_goal );
		alien waittill( "goal_reached" );		
		wait 0.05;
	}
}

wall_jump_test()
{
	wait 0.05;
	spawnpoint = GetStruct( "alien_spawn3", "targetname" );
	mid_goal = GetNode( "alien_turn3", "script_noteworthy" );
	end_goal = GetNode( "alien_turn_end3", "script_noteworthy" );	
	alien = undefined;
	while ( !isDefined( alien ) )
	{
		alien = maps\mp\gametypes\aliens::addAlienAgent( "axis", spawnpoint.origin, (0,0,0) );
		wait 0.05;
	}
	alien enable_alien_scripted();
	alien.ignoreall = true;
	alien ScrAgentSetGoalRadius( 32 );
	while ( 1 )
	{
		alien ScrAgentSetGoalNode( mid_goal );
		alien waittill( "goal_reached" );
		wait 0.05;
		alien ScrAgentSetGoalNode( end_goal );
		alien waittill( "goal_reached" );		
		wait 0.05;
	}
}

combat_test()
{
	wait 0.05;
	spawnpoint = GetStruct( "alien_spawn4", "targetname" );
	alien = undefined;
	while ( !isDefined( alien ) )
	{
		alien = maps\mp\gametypes\aliens::addAlienAgent( "axis", spawnpoint.origin, (0,0,0) );	
		wait 0.05;
	}
}
	
	
	