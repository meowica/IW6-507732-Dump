main()
{
	level._effect[ "embers_burst_runner_cheap" ] = loadfx( "vfx/moments/mp_warhawk/embers_burst_runner_cheap" );
	level._effect[ "explosion_war_bg_runner" ] = loadfx( "vfx/moments/mp_warhawk/explosion_war_bg_runner" );
	level._effect[ "vfx_fire_car_large_mp" ] = loadfx( "vfx/ambient/fire/fuel/vfx_fire_car_large_mp" );
	level._effect[ "vfx_battle_smoke" ] = loadfx( "vfx/ambient/atmospheric/vfx_battle_smoke" );
	level._effect[ "hanging_dust_outdoor_mp" ] = loadfx( "vfx/ambient/dust/hanging_dust_outdoor_mp" );
	level._effect[ "vfx_fire_grounded_med_nxglight" ] = loadfx( "vfx/ambient/fire/vfx_fire_grounded_med_nxglight" );
	level._effect[ "vfx_fire_grounded_xtralarge_nxglight_mp" ] = loadfx( "vfx/ambient/fire/vfx_fire_grounded_xtralarge_nxglight_mp" );
	level._effect[ "distant_fire" ] = loadfx( "vfx/moments/mp_warhawk/distant_fire" );
	level._effect[ "vfx_smk_stack_thick_vista" ] = loadfx( "vfx/ambient/smoke/vfx_smk_stack_thick_vista" );
	level._effect[ "vfx_perif_smk_war_vista" ] = loadfx( "vfx/ambient/skybox/vfx_perif_smk_war_vista" );
	level._effect[ "vfx_perif_smk_plume_huge_forestfire" ] = loadfx( "vfx/ambient/skybox/vfx_perif_smk_plume_huge_forestfire" );
	level._effect[ "cloud_ash_embers_mp" ] = loadfx( "vfx/moments/mp_warhawk/cloud_ash_embers_mp" );

	level._effect[ "smoke_plume"   ] = loadfx( "fx/smoke/bg_smoke_plume_mp" );
	
	level._effect[ "explode"   ] = loadfx( "fx/explosions/building_missilehit_mp" );
	level._effect["random_mortars_impact"] = loadfx("fx/maps/mp_warhawk/mortar_impact");
	level._effect["random_mortars_trail"] = loadfx("fx/smoke/smoke_geotrail_rpg");
	
	level._effect[ "afterburner" ] = loadfx("fx/fire/jet_afterburner");

	level._effect["osprey_trail"] = loadfx("fx/maps/hijack/hijack_engine_trail");
/#
    if ( GetDvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_warhawk_fx::main();
#/

}
