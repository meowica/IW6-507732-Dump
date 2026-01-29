#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	maps\mp\mp_skeleton_precache::main();
	maps\createart\mp_skeleton_art::main();
	maps\mp\mp_skeleton_fx::main();
	
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_skeleton" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_skeleton" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";	

	game[ "allies_outfit" ] = "woodland";
	game[ "axis_outfit" ] = "desert";
}