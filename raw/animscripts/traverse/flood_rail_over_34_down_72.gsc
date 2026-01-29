#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	if ( self.type == "dog" )
	{
		dog_wall_and_window_hop( "flood_rail_over_34_down_72", 34 );
	}
	else
	{
		low_wall_human();
	}
}

low_wall_human()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %flood_rail_over_34_down_72;
	traverseData[ "traverseHeight" ]		 = 34.0;

	DoTraverse( traverseData );
}

