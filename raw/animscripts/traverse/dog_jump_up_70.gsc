#include animscripts\utility;
#include animscripts\traverse\shared;

#using_animtree( "dog" );

main()
{
	assertex( self.type == "dog", "Only dogs can do this traverse currently." );

	dog_jump_up( 70, 5, "jump_up_80", true );
}
