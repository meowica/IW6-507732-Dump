#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	template_level( "iw6_vehicles" );
	maps\createart\iw6_vehicles_art::main();
	maps\iw6_vehicles_fx::main();
	maps\iw6_vehicles_precache::main();
	maps\_load::main();
	maps\iw6_vehicles_audio::main();
}
