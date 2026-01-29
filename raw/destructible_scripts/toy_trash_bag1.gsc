#include common_scripts\_destructible;

toy_trashbag1( color )
{
	//---------------------------------------------------------------------
	// trashbag1 toy
	//---------------------------------------------------------------------
	destructible_create( "toy_trashbag1_" + color, "tag_origin", 120, undefined, 32, "no_melee" );
		destructible_fx( "tag_fx", "fx/props/trashbag_" + color );
		//destructible_sound( "exp_trashcan_sweet" );															 
		destructible_state( undefined, "com_trashbag1_" + color + "_dsr", undefined, undefined, undefined, undefined, undefined, false );

}