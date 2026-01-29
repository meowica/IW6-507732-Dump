#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	creepwalk_traverse_over_large();
}

creepwalk_traverse_over_large()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %creepwalk_traverse_over_large;

	DoTraverse( traverseData );
}
