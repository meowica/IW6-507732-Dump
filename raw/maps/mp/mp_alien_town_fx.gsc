main()
{

/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_alien_town_fx::main();
#/
		level._effect[ "embers_burst_runner_cheap" ] = loadfx( "vfx/moments/mp_warhawk/embers_burst_runner_cheap" );
		level._effect[ "vfx_fire_car_large_mp" ] = loadfx( "vfx/ambient/fire/fuel/vfx_fire_car_large_mp" );
		level._effect[ "vfx_perif_smk_plume_huge_forestfire" ] = loadfx( "vfx/ambient/skybox/vfx_perif_smk_plume_huge_forestfire" );
		level._effect[ "ground_swamp_mist" ] = loadfx( "fx/weather/mist_icbm" );

}
