#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
		dog_jump_down( 5, 1.0 );
	else
		low_wall_human();
}

low_wall_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %flood_garage_jump_opfor_02;

	DoTraverse( traverseData );
}
