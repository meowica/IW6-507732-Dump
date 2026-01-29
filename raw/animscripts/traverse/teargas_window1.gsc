// Fence_climb.gsc
// Makes the character climb a 48 unit fence
// TEMP - copied wall dive until we get an animation
// Makes the character dive over a low wall

#include animscripts\traverse\shared;

main()
{
	if ( self.type == "dog" )
		dog_wall_and_window_hop( "wallhop", 40 );
	else
		teargas_traverse_window();
}

#using_animtree( "generic_human" );
teargas_traverse_window()
{
	random_int = RandomIntRange(1, 6);
		
	switch( random_int )
	{
		case 1:
			traverseData = [];
			traverseData[ "traverseAnim" ]			= %teargas_window_1;
			//traverseData[ "traverseStopsAtEnd" ]	= true;
			traverseData[ "traverseHeight" ]		= 36.0;
			DoTraverse( traverseData );
			break;
			
		case 2:
			
			traverseData = [];
			traverseData[ "traverseAnim" ]			= %teargas_window_2;
			//traverseData[ "traverseStopsAtEnd" ]	= true;
			traverseData[ "traverseHeight" ]		= 36.0;
			DoTraverse( traverseData );
			break;
			
		case 3:
			
			traverseData = [];
			traverseData[ "traverseAnim" ]			= %teargas_window_3;
			//traverseData[ "traverseStopsAtEnd" ]	= true;
			traverseData[ "traverseHeight" ]		= 36.0;
			DoTraverse( traverseData );
			break;
			
		case 4:
			traverseData = [];
			traverseData[ "traverseAnim" ]			= %teargas_window_4;
			//traverseData[ "traverseStopsAtEnd" ]	= true;
			traverseData[ "traverseHeight" ]		= 36.0;
			DoTraverse( traverseData );
			break;
			
		case 5:
			traverseData = [];
			traverseData[ "traverseAnim" ]			= %teargas_window_5;
			//traverseData[ "traverseStopsAtEnd" ]	= true;
			traverseData[ "traverseHeight" ]		= 36.0;
			DoTraverse( traverseData );
			break;
			
		case 6:
			traverseData = [];
			traverseData[ "traverseAnim" ]			= %teargas_window_6;
			//traverseData[ "traverseStopsAtEnd" ]	= true;
			traverseData[ "traverseHeight" ]		= 36.0;
			DoTraverse( traverseData );
			break;
	}
		
	
}