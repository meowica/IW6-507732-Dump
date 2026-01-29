#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	template_level( "characters_iw6_construct_black" );
	maps\createart\characters_iw6_construct_black_art::main();
	maps\characters_iw6_construct_black_fx::main();
	maps\characters_iw6_construct_black_precache::main();
	maps\_load::main();
	maps\characters_iw6_construct_black_audio::main();

	level.player TakeAllWeapons();

	SetSavedDvar( "g_speed", 10 );
	level.player LerpFov( 30, 0.05 );
}
