#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	build_template( "missile_boat", model, type, classname );
	build_localinit( ::init_local );
	build_deathmodel( "vehicle_boat_underneath_2" );
	build_life( 999, 500, 1500 );
	build_team( "axis" );
	build_drive( %ship_graveyard_boat_propellers, undefined, 2 );
	//build_aianims( ::setanims, ::set_vehicle_anims );
	//build_unload_groups( ::Unload_Groups );
	//build_treadfx();  //currently disabled because vehicle type "boat" isn't supported. http://bugzilla.infinityward.net/show_bug.cgi?id=85644

}

init_local()
{
}


/*QUAKED script_vehicle_missile_boat_under (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_missile_boat::main( "vehicle_boat_underneath_2", undefined, "script_vehicle_missile_boat_under" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_missile_boat_underneath
sound,vehicle_zodiac,vehicle_standard,all_sp

defaultmdl="vehicle_boat_underneath_2"
default:"vehicletype" "missile_boat"
default:"script_team" "axis"
*/