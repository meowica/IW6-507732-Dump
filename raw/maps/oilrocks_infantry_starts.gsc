#include maps\_utility;

main()
{
		   //   msg 				   func 								     loc_string    optional_func 						   
	add_start( "infantry"			, maps\oilrocks_infantry::start			  , undefined	, maps\oilrocks_infantry::main );
	add_start( "infantry_b"			, maps\oilrocks_infantry_b::start		  , undefined	, maps\oilrocks_infantry_b::main );
	add_start( "infantry_upper"		, maps\oilrocks_infantry_upper::start	  , undefined	, maps\oilrocks_infantry_upper::main );
	add_start( "infantry_elevator"	, maps\oilrocks_infantry_elevator::start  , undefined	, maps\oilrocks_infantry_elevator::main );
	add_start( "infantry_panic_room", maps\oilrocks_infantry_panic_room::start, undefined	, maps\oilrocks_infantry_panic_room::main );
}