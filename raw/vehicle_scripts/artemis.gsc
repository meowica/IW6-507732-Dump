#include maps\_vehicle_aianim;
#include maps\_vehicle;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "artemis", model, type, classname );
	build_localinit( ::init_local );

	build_deathmodel( "vehicle_artemis_30", "vehicle_artemis_30_dest" );

	artemis_death_fx = [];
	artemis_death_fx[ "vehicle_artemis_30" ] = "fx/explosions/vehicle_explosion_bmp";

	build_deathfx( artemis_death_fx[ model ], undefined, "exp_armor_vehicle", undefined, undefined, 	undefined, 0 );

	build_mainturret( "tag_flash_left", "tag_flash_right" );
	build_radiusdamage( ( 0, 0, 53 ), 512, 300, 20, false );

	build_life( 999, 500, 1500 );

	build_team( "allies" );
	build_aianims( ::setanims );
	//build_aianims( ::setanims, ::set_vehicle_anims );
}

init_local()
{
}

set_vehicle_anims( positions )
{
	//positions[ 0 ].vehicle_turret_fire = %zpu_gun_fire_a;
	//return positions;
}


#using_animtree( "generic_human" );

setanims()
{
	positions = [];
	for ( i = 0;i < 1;i++ )
		positions[ i ] = spawnstruct();

	positions[ 0 ].sittag = "tag_gunner";
	positions[ 0 ].idle = %abrams_gunner_idle;

	return positions;
}


/*QUAKED script_vehicle_artemis (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\artemis::main( "vehicle_artemis_30", undefined, "script_vehicle_artemis" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_artemis
sound,vehicle_zpu,vehicle_standard,all_sp



defaultmdl="vehicle_artemis_30"
default:"vehicletype" "artemis"
*/

