#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	creepwalk_traverse_over_small();
}

creepwalk_traverse_over_small()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %creepwalk_traverse_over_small;

	DoTraverse( traverseData );
}
