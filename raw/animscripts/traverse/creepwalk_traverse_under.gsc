#include animscripts\utility;
#include animscripts\traverse\shared;
#using_animtree( "generic_human" );

main()
{
	creepwalk_traverse_under();
}

creepwalk_traverse_under()
{
	traverseData = [];
	traverseData[ "traverseAnim" ]			 = %creepwalk_traverse_under;
	
	DoTraverse( traverseData );
}

