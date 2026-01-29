#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	template_level( "iw6_character_raven" );
	maps\createart\iw6_character_raven_art::main();
	maps\iw6_character_raven_fx::main();
	maps\iw6_character_raven_precache::main();
	maps\_load::main();
	maps\iw6_character_raven_audio::main();
}
