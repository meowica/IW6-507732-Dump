#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	template_level( "iw6_characters" );
	maps\createart\iw6_characters_art::main();
	maps\iw6_characters_fx::main();
	maps\iw6_characters_precache::main();
	maps\_load::main();
	maps\iw6_characters_audio::main();
	
	battlechatter_off();

	level.player TakeWeapon( "flash_grenade" );
	level.player TakeWeapon( "fraggrenade" );
	maps\_modelspawner::init_modelspawner();
}