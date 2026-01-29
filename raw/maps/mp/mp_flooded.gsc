
main()
{
	maps\mp\mp_flooded_precache::main();
	maps\createart\mp_flooded_art::main();
	maps\mp\mp_flooded_fx::main();
	maps\mp\_water::waterShallowFx();
	
	maps\mp\_load::main();
	
//	AmbientPlay( "ambient_mp_setup_template" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_flooded" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit" ] = "woodland";
	
	maps\mp\_water::waterShallowInit();
}