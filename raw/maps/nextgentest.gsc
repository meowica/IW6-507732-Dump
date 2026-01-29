#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

main()
{
	template_level( "nextgentest" );
	maps\createart\nextgentest_art::main();
	maps\nextgentest_fx::main();
	maps\nextgentest_precache::main();
	maps\_load::main();
	maps\nextgentest_audio::main();
}
