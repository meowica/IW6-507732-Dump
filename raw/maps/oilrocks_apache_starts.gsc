#include maps\_utility;
main()
{
		   //   msg 				   func 							     loc_string    optional_func 					   
	add_start( "apache_tutorial_fly", maps\oilrocks_apache_tutorial::start, undefined	, maps\oilrocks_apache_tutorial::main );
	add_start( "apache_factory"		, maps\oilrocks_apache_factory::start , undefined	, maps\oilrocks_apache_factory::main );
	add_start( "apache_chase"		, maps\oilrocks_apache_chase::start	  , undefined	, maps\oilrocks_apache_chase::main );
	add_start( "WIP_clear_antiair"	, maps\oilrocks_apache_antiair::start , undefined	, maps\oilrocks_apache_antiair::main );
	add_start( "apache_escort"		, maps\oilrocks_apache_escort::start  , undefined	, maps\oilrocks_apache_escort::main );
	add_start( "apache_chopper"		, maps\oilrocks_apache_chopper::start , undefined	, maps\oilrocks_apache_chopper::main );
	add_start( "apache_finale"		, maps\oilrocks_apache_finale::start  , undefined	, maps\oilrocks_apache_finale::main );
	add_start( "apache_landing"		, maps\oilrocks_apache_landing::start , undefined	, maps\oilrocks_apache_landing::main );
}