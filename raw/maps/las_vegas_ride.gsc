#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\las_vegas_code;

main_init()
{
}

//---------------------------------------------------------
// starts
//---------------------------------------------------------
start_ride()
{
	set_start_locations( "ride_startspot" );
	spawn_bus();
}

//---------------------------------------------------------
// Spawn Functions
//---------------------------------------------------------
spawn_functions()
{
	array_spawn_function_targetname( "bus", ::postspawn_bus );
}

//---------------------------------------------------------
// ride section
//---------------------------------------------------------
spawn_bus()
{
	spawner = GetEnt( "bus", "targetname" );
	spawner.target = "bus_start";
	spawner spawn_vehicle();
}

postspawn_bus()
{
	self.godmode = true;
	level.bus = self;
}

ride()
{
	wait( 5 );
	level.bus thread gopath();
}