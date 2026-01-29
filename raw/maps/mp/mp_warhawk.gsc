#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	maps\mp\mp_warhawk_precache::main();
	maps\createart\mp_warhawk_art::main();
	maps\mp\mp_warhawk_fx::main();
	maps\mp\mp_warhawk_events::precache();
	
	maps\mp\_load::main();
	
	thread maps\mp\_fx::func_glass_handler(); // Text on glass 
	
//	AmbientPlay( "ambient_mp_setup_template" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_warhawk" );
	
	SetDvar( "r_lightGridEnableTweaks", 1 );
	SetDvar( "r_li9ghtGridIntensity"	  , 1.33 );
	setdvar( "r_diffuseColorScale", 1.5);
    setdvar( "r_specularColorScale", 1.5); 
	
	
	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
		
	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit"	] = "woodland";
	
	min_wait_time = 90.0;
	max_wait_time = 180.0;


	level thread maps\mp\mp_warhawk_events::random_destruction( min_wait_time, max_wait_time );
	level thread maps\mp\mp_warhawk_events::plane_crash();
	level thread maps\mp\mp_warhawk_events::air_raid();
	level thread maps\mp\mp_warhawk_events::heli_anims();
	level thread maps\mp\mp_warhawk_events::chain_gate();
	level thread maps\mp\_breach::main();
	
	/#
	SetDvarIfUninitialized("allow_dynamic_events", "1");
	level thread watch_allow_dynamic_events();
	#/
}

watch_allow_dynamic_events()
{
	while(GetDvarInt("allow_dynamic_events"))
	{
		wait .05;
	}
	
	level notify("stop_dynamic_events");
}
