#include maps\_vehicle;
#include maps\_vehicle_aianim;
#using_animtree( "vehicles" );
main( model, type, classname )
{
	vehicle_scripts\hind::main( model, type, classname );
	build_turret( "apache_turret", "tag_turret", "vehicle_apache_mg", undefined, "auto_nonai", 0.0, 20, -14 );

}

/*QUAKED script_vehicle_hind_battle_oilrocks (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\hind_battle_oilrocks::main( "vehicle_battle_hind", "hind_battle_oilrocks", "script_vehicle_hind_battle_oilrocks" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_hind_battle_oilrocks
sound,vehicle_hind,vehicle_standard,all_sp

defaultmdl="vehicle_battle_hind"
default:"vehicletype" "hind_battle_oilrocks"
default:"script_team" "axis"
*/
