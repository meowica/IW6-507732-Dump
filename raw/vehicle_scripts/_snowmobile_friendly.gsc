main( model, type, classname )
{
	vehicle_scripts\_snowmobile::main( model, "snowmobile_friendly",classname );
}


/*QUAKED script_vehicle_snowmobile_friendly (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_snowmobile_friendly::main( "vehicle_snowmobile_alt", undefined, "script_vehicle_snowmobile_friendly" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_snowmobile_snowmobile
sound,vehicle_snowmobile,vehicle_standard,all_sp


defaultmdl="vehicle_snowmobile_alt"
default:"vehicletype" "snowmobile_friendly"
default:"script_team" "allies"
*/