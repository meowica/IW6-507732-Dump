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

	anims = [];
	anims[ anims.size ] = %flood_traverse_stepup_32_v1;
	anims[ anims.size ] = %flood_traverse_stepup_32_v2;
	anims[ anims.size ] = %flood_traverse_stepup_32_v3;

	traverseData					 = [];
	//traverseData[ "traverseHeight" ] = 32.0;
	traverseData[ "traverseAnim" ]	 = anims[ RandomInt( anims.size ) ];

	DoTraverse( traverseData );
}
