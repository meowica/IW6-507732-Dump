#include animscripts\dog\dog_init;
#include animscripts\dog\dog_kill_traversal;


initDogVestAnimations()
{
	// Initialization that should happen once per level
	if ( isDefined( anim.NotFirstTimeDogVests ) )// Use this to trigger the first init
		return;
	anim.NotFirstTimeDogVests = 1;

	//setup our function pointer to do additional kill animations.
	level.dog_alt_melee_func = animscripts\dog\dog_kill_traversal::dog_alt_combat_check;
	
	//initialize the standard dog anims.	
	animscripts\dog\dog_init::initDogAnimations();
	
	
}