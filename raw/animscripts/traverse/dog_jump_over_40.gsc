#include animscripts\utility;
#include animscripts\traverse\shared;
#include animscripts\dog\dog_kill_traversal;
#using_animtree( "dog" );

main()
{
	if ( self.type == "dog" )
	{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = "dog_jump_over_40";
	traverseData[ "linkMe" ] 				 = 1;
	

		if( !check_kill_traversal( traverseData ) )
			return dog_wall_and_window_hop( "window_40", 40 );
	}
	else
		low_wall_human();
// When the traversal code goes out for general consumption, put this assert in place of the human handler.	
//	AssertMsg( "Traversal dog_jump_over_40 being used by a non-dog character." );

}

#using_animtree( "generic_human" );
low_wall_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %traverse40;
	traverseData[ "traverseToCoverAnim" ]	 = %traverse40_2_cover;
	traverseData[ "coverType" ]				 = "Cover Crouch";
	traverseData[ "traverseHeight" ]		 = 40.0;
	traverseData[ "interruptDeathAnim" ][ 0 ]	 = array( %traverse40_death_start, %traverse40_death_start_2 );
	traverseData[ "interruptDeathAnim" ][ 1 ]	 = array( %traverse40_death_end, %traverse40_death_end_2 );

	DoTraverse( traverseData );
}

