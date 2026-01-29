#include animscripts\utility;
#include animscripts\traverse\shared;

#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
		dog_jump_up( 24.0, 5, "jump_up_24", true );
	else
		low_wall_human();
}

low_wall_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %ch_pragueb_7_5_crosscourt_aimantle_A;
	traverseData[ "traverseHeight" ]		 = 32.0;

	DoTraverse( traverseData );
}
