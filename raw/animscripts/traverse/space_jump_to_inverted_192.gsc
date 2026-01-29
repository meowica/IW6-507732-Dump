#include maps\_anim;
#include animscripts\utility;
//#include animscripts\traverse\space_shared;
#include maps\_utility;
#include common_scripts\utility;

#using_animtree( "generic_human" );

main()
{
	if ( !isDefined( self.swimmer ) || !self.swimmer )
	{
		AssertMsg( "Traversal space_traversal_jump_180_U being used by a non-space character." );
		return;
	}
	
	//iprintlnbold( "DO TRAVERSE" );
	
	//self.swimmer = false;
	
	// TRAVERSE METHOD
	//traverseData = [];
	//traverseData[ "traverseAnim" ]			 = %space_traversal_jump_180_U;
	
	// Clear goal
	//self setGoalPos( self.origin );
	
	//self traverseMode( "nogravity" );
	self traverseMode( "noclip" );

	startnode = self getnegotiationstartnode();
	self.turnrate = 2000;
		self OrientMode( "face angle 3d", startnode.angles );

	// Play the anim
	self clearanim( %root, 0 );
	self setFlaggedAnimKnoballRestart( "3dtraverseAnim", %space_traversal_jump_180_U, %root, 1, .1, 1 );
	//wait 5.15;
	//self traverseMode( "gravity" );
	self animscripts\shared::DoNoteTracks( "3dtraverseAnim" );

	//self clearAnim( %root, .2 );

	//iprintlnbold( "done" );
	//self.swimmer = true;
}
