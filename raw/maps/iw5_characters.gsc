#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	maps\createart\iw5_characters_art::main();
	maps\iw5_characters_fx::main();
	maps\iw5_characters_precache::main();
	maps\_load::main();

	battlechatter_off();

	SetDvarIfUninitialized( "filter", "" );
	SetDvarIfUninitialized( "filterout", "" );

	level.player TakeWeapon( "flash_grenade" );

	maps\_modelspawner::init_modelspawner();
}
	
	