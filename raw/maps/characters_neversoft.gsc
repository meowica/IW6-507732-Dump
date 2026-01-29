#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	template_level( "characters_neversoft" );
	maps\createart\characters_neversoft_art::main();
	maps\characters_neversoft_fx::main();
	maps\characters_neversoft_precache::main();
	maps\_load::main();
	maps\characters_neversoft_audio::main();
	loadBarnesHands();
	
}
loadBarnesHands()
{
	precache("viewhands_gs_hostage");
	level.player SetViewModel("viewhands_gs_hostage");
}