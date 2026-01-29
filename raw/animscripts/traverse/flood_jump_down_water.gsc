// flood_jump_across_and_down.gsc
// Flood specific traversal across a gap
#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	// do not do code prone in this script
	self.desired_anim_pose = "stand";
	animscripts\utility::UpdateAnimPose();

	self endon( "killanimscript" );
	self traverseMode( "nogravity" );
	self traverseMode( "noclip" );

	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %flood_rooftop_traversal_ally02_secondjump;

	DoTraverse( traverseData );
}
