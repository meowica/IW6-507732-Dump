

main()
{
	//exploder
	level._effect[ "halon_gas_jet" ] = loadfx( "vfx/ambient/smoke/vfx_halon_gas" );
	level._effect[ "vfx_sparks_tank_sov" ] = loadfx( "vfx/ambient/sparks/vfx_sparks_tank_sov" );
	level._effect[ "vfx_dust_impact_sov" ] = loadfx( "vfx/moments/mp_sovereign/vfx_dust_impact_sov" );
	
	//placed ambient
	level._effect[ "vfx_security_mon_small_runner" ] = loadfx( "vfx/ambient/misc/vfx_security_mon_small_runner" );
	level._effect[ "vfx_hologram_sov" ] = loadfx( "vfx/ambient/misc/vfx_hologram_sov" );
	level._effect[ "vfx_security_monitor_dualstrip" ] = loadfx( "vfx/ambient/misc/vfx_security_monitor_dualstrip" );
	level._effect[ "vfx_security_monitor_strip" ] = loadfx( "vfx/ambient/misc/vfx_security_monitor_strip" );
	level._effect[ "vfx_security_monitor_small" ] = loadfx( "vfx/ambient/misc/vfx_security_monitor_small" );
	level._effect[ "vfx_security_monitor_large" ] = loadfx( "vfx/ambient/misc/vfx_security_monitor_large" );
	level._effect[ "vfx_security_monitors" ] = loadfx( "vfx/ambient/misc/vfx_security_monitors" );
	level._effect[ "vfx_steam_jet_pipes_runner" ] = loadfx( "vfx/ambient/steam/vfx_steam_jet_pipes_runner" );
	level._effect[ "vfx_steam_jet_assembly" ] = loadfx( "vfx/ambient/steam/vfx_steam_jet_assembly" );
	level._effect[ "drip_5x5" ] = loadfx( "vfx/ambient/water/drip_5x5" );
	level._effect[ "vfx_sov_hall_haze_uv1" ] = loadfx( "vfx/ambient/atmospheric/vfx_sov_hall_haze_uv1" );
	level._effect[ "vfx_sov_assembly_haze_uv" ] = loadfx( "vfx/ambient/atmospheric/vfx_sov_assembly_haze_uv" );
	level._effect[ "vfx_smoky_flourescent_sov" ] = loadfx( "vfx/ambient/lights/vfx_smoky_flourescent_sov" );
	level._effect[ "smoky_fluorescent_light_200_soft" ] = loadfx( "vfx/ambient/lights/smoky_fluorescent_light_200_soft" );
	level._effect[ "vfx_sov_int_haze_ceil_uv" ] = loadfx( "vfx/ambient/atmospheric/vfx_sov_int_haze_ceil_uv" );
	level._effect[ "vfx_glow_ceil_light_sov" ] = loadfx( "vfx/ambient/lights/vfx_glow_ceil_light_sov" );
	level._effect[ "lights_defend_ceil" ] = loadfx( "fx/lights/lights_defend_ceil" );
	level._effect[ "vfx_sov_int_haze_uv1" ] = loadfx( "vfx/ambient/atmospheric/vfx_sov_int_haze_uv1" );
	level._effect[ "vfx_fire_server_glass_sov" ] = loadfx( "vfx/ambient/fire/electrical/vfx_fire_server_glass_sov" );
	level._effect[ "vfx_smk_glassplume_sov" ] = loadfx( "vfx/ambient/smoke/vfx_smk_glassplume_sov" );
	level._effect[ "vfx_sparks_server_sov" ] = loadfx( "vfx/ambient/sparks/vfx_sparks_server_sov" );
	level._effect[ "vfx_steam_vent_sov" ] = loadfx( "vfx/ambient/steam/vfx_steam_vent_sov" );
	level._effect[ "vfx_fire_server_sov" ] = loadfx( "vfx/ambient/fire/electrical/vfx_fire_server_sov" );
	level._effect[ "vfx_fire_barrel_small_nolight" ] = loadfx( "vfx/ambient/fire/vfx_fire_barrel_small_nolight" );


	


/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_sovereign_fx::main();
#/
}


		
		


