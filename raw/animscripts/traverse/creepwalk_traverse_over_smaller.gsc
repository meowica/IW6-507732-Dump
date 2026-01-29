#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	creepwalk_traverse_over_smaller();
}

creepwalk_traverse_over_smaller()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %creepwalk_traverse_over_smaller;

	DoTraverse( traverseData );
}
