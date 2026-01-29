main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\iplane_fx::main();
		maps\createfx\iplane_sound::main();
	}
	
	fx();
}

fx()
{
	level._effect["explosion_1"]	= loadfx( "fx/explosions/small_vehicle_explosion_new" );
	level._effect["big"]	= loadfx( "fx/explosions/aerial_explosion_large" );
	
	level._effect["dirt_blow_by"]	= loadfx( "vfx/ambient/sand/iplane_blowing_motes" );
	level._effect["dirt_two"]       = loadfx( "vfx/ambient/sand/iplane_blowing_motes_two" );
	
	level._effect["metal"]	= loadfx( "vfx/ambient/misc/falling_metal_debris_iplane_burst" );
	
	level._effect[ "spark_one" ] = loadfx( "vfx/ambient/sparks/electrical_sparks" );
	
	// green
	level._effect[ "green_small_front" ] = loadfx( "fx/misc/ship_pad_light_green_1" ); // this is the small light in front of the button
	level._effect[ "green_large_glow" ] = loadfx( "fx/lights/fxlight_green" ); // this is the glow that goes around the light
	level._effect[ "green_new" ] = loadfx( "vfx/ambient/lights/vfx_glow_green_light_30_nolight" ); // this is the glow that goes around the light
	
	level._effect[ "green_new_2" ] = loadfx( "vfx/ambient/lights/vfx_glow_green_light_15_nolight" ); // this is the glow that goes around the light
	
	
	// red
	level._effect[ "red_large_glow" ] = loadfx( "fx/misc/red_dlight" ); // this is the glow that goes around the light
	level._effect[ "red_small_front" ] = loadfx( "vfx/ambient/lights/vfx_glow_red_light_15_nolight" ); // this is the glow that goes around the light fx,vfx/ambient/lights/vfx_glow_red_light_15_nolight
	
	// dlight glows
	level._effect[ "dlight_glow_medium_red" ] = loadfx( "vfx/ambient/lights/dlight_glow_medium_red" ); // this is the glow that goes around the light
	level._effect[ "dlight_glow_medium_green" ] = loadfx( "vfx/ambient/lights/dlight_glow_medium_green" ); // this is the glow that goes around the light fx,vfx/ambient/lights/vfx_glow_red_light_15_nolight
	
	level._effect[ "jet_engine" ] = loadfx( "fx/fire/jet_afterburner" ); // this is the glow that goes around the light fx,vfx/ambient/lights/vfx_glow_red_light_15_nolight
	
	level._effect[ "wing_explosion" ] = loadfx( "fx/maps/hijack/tail_ambient_explosion" ); 
	
	level._effect[ "sparks_seperate_plane" ] = loadfx( "fx/maps/hijack/fuselage_break_sparks1" ); // tail riping off fx
	
	level._effect[ "scrap_plane_on_ground" ] = loadfx( "fx/misc/hijack_scrape_airplane" ); 
	
	level._effect[ "metal_chunks_explode" ] = loadfx( "fx/explosions/hijack_airplane_collapse_debri_blast" ); 
	
	level._effect[ "escape_dust_hijack0" ] = loadfx( "fx/dust/decompression_cabin_dust" ); 
	level._effect[ "escape_dust_hijack1" ] = loadfx( "fx/dust/decompression_cabin_fastwind" ); 

	level._effect[ "gash_volumetric" ] = loadfx( "fx/maps/hijack/plane_gash_volumetric" ); // these play with the sparks as the tail is ripped off.
	level._effect[ "gash_volumetric_long" ] = loadfx( "fx/maps/hijack/plane_gash_volumetric_long" ); // these play with the sparks as the tail is ripped off.
	
	// smoke in room
	level._effect[ "smoke" ] = loadfx( "fx/maps/hijack/conference_room_smoke" ); 
	level._effect[ "smoke_ambience" ] = loadfx( "fx/smoke/fog_ground_200_red_rvn" );
	
	
	level._effect[ "clouds" ] = loadfx( "fx/maps/hijack/cloud_tunnel" ); // be sure to spawn them off of a script model. so you turn them off later.
	
	
	// trail on wing tips
	level._effect[ "contrail" ] = loadfx( "fx/smoke/contrail" );
	
//	// light fx
	level._effect["window_volumetric_o"] = loadfx( "fx/maps/hijack/window_volumetric_open" );
	level._effect["window_volumetric_l"] = loadfx( "fx/maps/hijack/window_volumetric_long" );
	level._effect["window_volumetric"] = loadfx( "fx/maps/hijack/window_volumetric" );
	

//	// hijack_window_glow
//	level._effect[ "hijack_window_glow" ]						= loadfx( "fx/maps/hijack/hijack_window_glow");
}
