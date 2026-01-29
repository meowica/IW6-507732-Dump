#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_utility;
#include common_scripts\utility;
#using_animtree( "vehicles" );

/*QUAKED script_vehicle_metro_bus (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\metro_bus::main( "vehicle_metro_bus_cabin_front_vegas", undefined, "script_vehicle_metro_bus" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_metro_bus

defaultmdl="vehicle_metro_bus_cabin_front_vegas"
default:"vehicletype" "metro_bus"
default:"script_team" "allies"
*/


main( model, type, classname )
{
	temp_model = "vehicle_iveco_lynx_op_iw6";

	build_template( "metro_bus", temp_model, type, classname );
	build_localinit( ::init_local );
	
	build_drive( %uaz_driving_idle_forward, %uaz_driving_idle_backward, 10 );
	build_treadfx();
	build_life( 999, 500, 1500 );
	build_team( "allies" );
}

init_local()
{
	// TEMP TILL WE GET RIGGED!
	ents = GetEntArray( self.script_linkTo, "script_linkname" );
	array_call( ents, ::LinkTo, self );
	self Hide();
}

unload_groups()
{
	return undefined;
}


#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
}


