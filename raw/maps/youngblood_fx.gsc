main()
{

	level._effect[ "ygb_rod_impact_earth_a" ] 						= loadfx( "vfx/_requests/youngblood/ygb_rod_impact_earth_a" );
	level._effect[ "mall_rooftop_collapse_dust_medium" ] 			= loadfx( "vfx/moments/flood/mall_rooftop_collapse_dust_medium" );
	level._effect[ "vfx_heli_crash_hit_sparks" ] 					= loadfx( "vfx/moments/las_vegas/vfx_heli_crash_hit_sparks" );
	level._effect[ "vfx_sparks_sign_ch" ] 							= loadfx( "vfx/ambient/sparks/vfx_sparks_sign_ch" );
	level._effect[ "ygb_powerline_sparks_a" ] 						= loadfx( "vfx/_requests/youngblood/ygb_powerline_sparks_a" );
	level._effect[ "ygb_chunk_fall_a" ] 							= loadfx( "vfx/_requests/youngblood/ygb_chunk_fall_a" );
	level._effect[ "ygb_chaos_cloud_a" ] 							= loadfx( "vfx/_requests/youngblood/ygb_chaos_cloud_a" );
	level._effect[ "ygb_water_pipe_gush_lg" ] 						= loadfx( "vfx/_requests/youngblood/ygb_water_pipe_gush_lg" );
	level._effect[ "ygb_earth_wall_fall_a" ] 						= loadfx( "vfx/_requests/youngblood/ygb_earth_wall_fall_a" );
	level._effect[ "ygb_crack_chunk_emitter_a" ] 					= loadfx( "vfx/_requests/youngblood/ygb_crack_chunk_emitter_a" );
	level._effect[ "ygb_tree_shake_leaf_fall_a" ] 					= loadfx( "vfx/_requests/youngblood/ygb_tree_shake_leaf_fall_a" );
	level._effect[ "ygb_ground_move_dust_a" ] 						= loadfx( "vfx/_requests/youngblood/ygb_ground_move_dust_a" );
	level._effect[ "ygb_rog_bak_mover_a" ] 							= loadfx( "vfx/_requests/youngblood/ygb_rog_bak_mover_a" );
	level._effect[ "ygb_birds_start_panicked" ] 					= loadfx( "vfx/_requests/youngblood/ygb_birds_start_panicked" );
	level._effect[ "ygb_wind_light_a" ] 							= loadfx( "vfx/_requests/youngblood/ygb_wind_light_a" );
	level._effect[ "ygb_birds_flee_cloud_a" ] 						= loadfx( "vfx/_requests/youngblood/ygb_birds_flee_cloud_a" );
	level._effect[ "ygb_pool_splash_a" ] 							= loadfx( "vfx/_requests/youngblood/ygb_pool_splash_a" );
	level._effect[ "ygb_bubbles_pool_crack_a" ] 					= loadfx( "vfx/_requests/youngblood/ygb_bubbles_pool_crack_a" );
	level._effect[ "ygb_bubbles_pool_crack_b" ] 					= loadfx( "vfx/_requests/youngblood/ygb_bubbles_pool_crack_b" );
	level._effect[ "ygb_wood_explosion_a" ] 						= loadfx( "vfx/_requests/youngblood/ygb_wood_explosion_a" );
	level._effect[ "ygb_fireball_explosion" ] 						= loadfx( "vfx/_requests/youngblood/ygb_fireball_explosion" );
	level._effect[ "ygb_cliff_fall_a" ] 							= loadfx( "vfx/_requests/youngblood/ygb_cliff_fall_a" );
	level._effect[ "ygb_cliff_fall_a_long" ] 						= loadfx( "vfx/_requests/youngblood/ygb_cliff_fall_a_long" );
	level._effect[ "ygb_ground_move_dust_b_lite" ] 					= loadfx( "vfx/_requests/youngblood/ygb_ground_move_dust_b_lite" );
	level._effect[ "vfx_fire_grounded_xtralarge_nxglight" ] 		= loadfx( "vfx/ambient/fire/vfx_fire_grounded_xtralarge_nxglight" );
	level._effect[ "ygb_chaos_cloud_b_sml" ] 						= loadfx( "vfx/_requests/youngblood/ygb_chaos_cloud_b_sml" );
	level._effect[ "light_beam_glow_wide_underwater" ] 				= loadfx( "vfx/ambient/lights/light_beam_glow_wide_underwater" );
	level._effect[ "ygb_debris_basement_a" ] 						= loadfx( "vfx/_requests/youngblood/ygb_debris_basement_a" );
	level._effect[ "ygb_dust_basement_a" ] 							= loadfx( "vfx/_requests/youngblood/ygb_dust_basement_a" );
	level._effect[ "ygb_debris_earth_chunk_med_a" ] 				= loadfx( "vfx/_requests/youngblood/ygb_debris_earth_chunk_med_a" );
	level._effect[ "ygb_debris_earth_chunk_med_b" ] 				= loadfx( "vfx/_requests/youngblood/ygb_debris_earth_chunk_med_b" );
										
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\youngblood_fx::main();
		maps\createfx\youngblood_sound::main();
		
	
	}
}
