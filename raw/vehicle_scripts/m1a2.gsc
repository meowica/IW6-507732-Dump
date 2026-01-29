#include maps\_vehicle_aianim;
#include maps\_vehicle;
#include maps\_utility;
#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "m1a2", model, type, classname );
    build_localinit( ::init_local );
    build_deathmodel( "vehicle_m1a2_abrams_iw6", "vehicle_m1a1_abrams_dmg");
    build_drive( %m1a2_abrams_driving_idle_forward, %m1a2_abrams_driving_idle_backward, 10 );
    build_exhaust( "fx/distortion/abrams_exhaust" );
    build_deckdust( "fx/dust/abrams_deck_dust" );
    build_treadfx();
    build_deathfx( "fx/explosions/vehicle_explosion_m1a1",             "tag_deathfx",             "exp_armor_vehicle",         undefined,             undefined,         undefined,         0, undefined, undefined, undefined, 10 );
//    build_Turret( "m1a1_coaxial_mg", "tag_coax_mg", "vehicle_m1a2_abrams_remote_gun", undefined, undefined, 0.0, 0, 0 );
    build_Turret( "dshk_gaz", "tag_coax_mg", "vehicle_m1a2_abrams_remote_gun", undefined, "auto_nonai", 0.0, 0, 0 );
    build_life( 999, 500, 1500 );
    build_rumble( "tank_rumble", 0.15, 4.5, 900, 1, 1 );
    build_shoot_shock( "tankblast" );
    build_team( "allies" );
    build_mainturret();
    build_aianims( ::setanims, ::set_vehicle_anims );
    build_frontarmor( 0.33 ); // regens this much of the damage from attacks to the front
    
}

init_local()
{
}

set_vehicle_anims( positions )
{
    return positions;
}

#using_animtree( "generic_human" );

setanims()
{
    positions = [];
    for ( i = 0;i < 11;i++ )
        positions[ i ] = SpawnStruct();

    positions[ 0 ].getout_delete = true;


    return positions;
}




/*QUAKED script_vehicle_m1a2 (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\m1a2::main( "vehicle_m1a2_abrams_iw6", undefined, "script_vehicle_m1a2" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_m1a2
sound,vehicle_abrams,vehicle_standard,all_sp

defaultmdl="vehicle_m1a2_abrams_iw6"
default:"vehicletype" "m1a2"
default:"script_team" "allies"
*/
