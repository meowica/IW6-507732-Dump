#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );


/*QUAKED script_vehicle_y_8 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\y_8::main( "vehicle_y_8",undefined, "script_vehicle_y_8" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_y_8

defaultmdl="vehicle_y_8"
default:"vehicletype" "y_8"
default:"script_team" "axis"
*/

main( model, type, classname)
{
	build_template( "y_8", model, type, classname );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_y_8" );

	build_deathfx( "fx/explosions/large_vehicle_explosion", undefined, "explo_metal_rand" );
	build_life( 999, 500, 1500 );
	build_treadfx();
	build_team( "axis" );
	build_is_airplane();
	
			 //   model      name 		      tag 			      effect 							   group      delay   
//	build_light( classname, "wingtip_green", "tag_light_L_wing", "fx/misc/aircraft_light_wingtip_green", "running", 0.0 );
//	build_light( classname, "wingtip_red"  , "tag_light_R_wing", "fx/misc/aircraft_light_wingtip_red"	, "running", 0.05 );
//	build_light( classname, "tail_red"	   , "tag_light_tail"  , "fx/misc/aircraft_light_white_blink"	, "running", 0.05 );
//	build_light( classname, "white_blink"  , "tag_light_belly" , "fx/misc/aircraft_light_red_blink"	, "running", 1.0 );
	
}

init_local()
{

}

#using_animtree( "vehicles" );
set_vehicle_anims( positions )
{
	return positions;
}


#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 1;i++ )
		positions[ i ] = spawnstruct();

	return positions;
}
