#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	maps\mp\mp_dart_precache::main();
	maps\createart\mp_dart_art::main();
	maps\mp\mp_dart_fx::main();
	
	level thread maps\mp\mp_dart_events::breach();
	level thread maps\mp\mp_dart_events::gas_station();
	//level thread maps\mp\mp_dart_events::ceiling_rubble();
	thread maps\mp\mp_dart_scriptlights::main();
	
	maps\mp\_load::main();
	thread maps\mp\_fx::func_glass_handler(); // Text on glass
	
	AmbientPlay( "ambient_mp_dart" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_dart" );
	
      if ( level.ps3 )
      {
      setdvar( "sm_sunShadowScale", "0.6" ); // ps3 optimization
      }
      else
      {
	setdvar( "sm_sunShadowScale", "0.7" ); // optimization	
      }
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );

	setdvar_cg_ng( "r_specularColorScale", 1.5, 19.45 );	
  	setdvar_cg_ng( "r_diffuseColorScale", 1.42, 1.7325 ); 
	 
  	//setdvar( "r_specularColorScale", 19.45 );  // old
	//setdvar( "r_diffuseColorScale", 1.7325 );  // old


	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	
	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit" ] = "desert";

	level thread maps\mp\mp_dart_events::broken_walls();
}
