#include common_scripts\utility;
#include common_scripts\_fx;

main()
{
	level._effect[ "explosion_war_background_runner" ]	   = LoadFX( "vfx/moments/satfarm/explosion_war_background_runner" );
	level._effect[ "antiair_single_tracer01_cloudy_loop" ] = LoadFX( "vfx/moments/satfarm/antiair_single_tracer01_cloudy_loop" );
	level._effect[ "vfx_perif_smk_war_vista" ]			   = LoadFX( "vfx/ambient/skybox/vfx_perif_smk_war_vista" );
	level._effect[ "wreckage_smoke" ]					   = LoadFX( "vfx/moments/satfarm/wreckage_smoke" );
	level._effect[ "smk_plume_black_lrg" ]				   = LoadFX( "vfx/moments/satfarm/smk_plume_black_lrg" );
	level._effect[ "vfx_perif_smk_plume_huge_satfarm" ]	   = LoadFX( "vfx/ambient/skybox/vfx_perif_smk_plume_huge_satfarm" );
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\satfarm_fx::main();
		maps\createfx\satfarm_sound::main();
	}
		
	precache_create_fx();
	precache_scripted_fx();
}

precache_create_fx()
{
	level._effect[ "falling_debris_small" ]						= LoadFX( "fx/misc/falling_debris_small" );
}

precache_scripted_fx()
{
	level._effect[ "smoke_large_cheap_grey" ]				  = LoadFX( "fx/smoke/smoke_large_cheap_grey" );
	level._effect[ "firelp_large_pm_nolight_cheap" ]		  = LoadFX( "fx/fire/firelp_large_pm_nolight_cheap" );
	level._effect[ "vehicle_explosion_t90_cheap" ]			  = LoadFX( "fx/explosions/vehicle_explosion_t90_cheap" );
	level._effect[ "bg_smoke_plume" ]						  = LoadFX( "fx/smoke/bg_smoke_plume" );
	level._effect[ "tank_heavy_smoke" ]						  = LoadFX( "fx/smoke/smoke_trail_black_heli" );
	level._effect[ "grenade_muzzleflash" ]					  = LoadFX( "fx/muzzleflashes/m203_flshview" );
	level._effect[ "tank_muzzleflash" ]						  = LoadFX( "fx/muzzleflashes/abrams_flash_wv_no_tracer" );
	level._effect[ "aerial_explosion_mig29" ]				  = LoadFX( "fx/explosions/aerial_explosion_mig29" );
	level._effect[ "jet_crash_dcemp" ]						  = LoadFX( "fx/explosions/jet_crash_dcemp" );
	level._effect[ "airplane_damage_blacksmoke_fire" ]		  = LoadFX( "fx/smoke/airplane_damage_blacksmoke_fire" );
	level._effect[ "generic_explosion_large" ]				  = LoadFX( "fx/explosions/generic_explosion_large" );
	level._effect[ "vehicle_explosion_slamraam_no_missiles" ] = LoadFX( "fx/explosions/vehicle_explosion_slamraam_no_missiles" );
	level._effect[ "vehicle_tank_crush" ]					  = LoadFX( "fx/explosions/vehicle_tank_crush" );
	level._effect[ "vehicle_explosion_medium" ]				  = LoadFX( "fx/explosions/vehicle_explosion_medium" );
	level._effect[ "sat_dish_sand_impact" ]					  = LoadFX( "fx/maps/satfarm/sat_dish_sand_impact" );
	level._effect[ "air_strip_bunker_explosion_main" ]		  = LoadFX( "fx/maps/satfarm/air_strip_bunker_explosion_main" );
	level._effect[ "signal_smoke_green" ]					  = LoadFX( "fx/smoke/signal_smoke_green" );
	
	// Mortar fx
	level._effect[ "mortar" ]									= LoadFX( "fx/explosions/mortarexp_mud_nofire" );
	
	// Spark fx
	level._effect[ "spark" ]									= LoadFX( "fx/misc/spark_fountain_l" );
	
	// Smoke Event FX
	level._effect[ "smokescreen" ]		  = LoadFX( "fx/smoke/factory_ambush_smoke_grenade" );
	level._effect[ "smoke_start" ]		  = LoadFX( "fx/muzzleflashes/tiger_flash" );
	level._effect[ "smoke_screen" ]		  = LoadFX( "fx/smoke/hamburg_cover_smoke_runner" );
	level._effect[ "smoke_screen_flash" ] = LoadFX( "fx/smoke/smoke_screen_flash" );
	level._effect[ "rpg_trail" ]		  = LoadFX( "fx/smoke/smoke_geotrail_rpg" );
	
	level._effect[ "hamburg_tank_red_light" ]				= LoadFX( "fx/misc/hamburg_tank_red_light" );
	
	//Javelin
	level._effect[ "javelin_muzzle" ] 							= LoadFX( "fx/muzzleflashes/javelin_flash_wv" );
	
	//Control Tower Building fx
	level._effect[ "ceiling_dust" ]		 = LoadFX( "fx/dust/ceiling_dust_bunker" );

	//Nuke effects from Airlift
	level._effect[ "nuke_explosion" ]			  = LoadFX( "fx/explosions/nuke_explosion_prague_esc" );
	level._effect[ "nuke_flash" ]				  = LoadFX( "fx/explosions/nuke_flash_prague_esc" );
	level._effect[ "nuke_dirt_shockwave" ]		  = LoadFX( "fx/explosions/nuke_dirt_shockwave_prague_esc" );
	level._effect[ "nuke_smoke_fill" ]			  = LoadFX( "fx/explosions/nuke_smoke_fill_prague_esc" );
	level._effect[ "sand_wall_payback_still_md" ] = LoadFX( "fx/sand/sand_wall_payback_still_md" );
	
	//sidewinder
	level._effect[ "f15_missile" ] 								= LoadFX( "fx/smoke/smoke_geotrail_sidewinder" );
	
	// these are the tank effects, you can make it do different stuff on different types of surfaces
	level._effect[ "tank_blast_brick" ] 		= LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_bark" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_carpet" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_cloth" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_concrete" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_dirt" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_flesh" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_foliage" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_glass" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_grass" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_gravel" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_ice" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_metal" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_mud" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_paper" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_plaster" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_rock" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_sand" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_snow" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_water" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_wood" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_asphalt" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_ceramic" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_plastic" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_rubber" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_cushion" ]	   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_fruit" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_paintedmetal" ] = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_riotshield" ]   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_slush" ]		   = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
 	level._effect[ "tank_blast_default" ] 		= LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	level._effect[ "tank_blast_none" ] 			= LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	
	// decals are seperate from the effect, so I can always point them towards the wall.
	level._effect[ "tank_blast_decal_brick" ] 			= LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_bark" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_carpet" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_cloth" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_concrete" ]	 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_dirt" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_flesh" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_foliage" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_glass" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_grass" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_gravel" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_ice" ]			 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_metal" ]		 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_mud" ]			 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_paper" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_plaster" ]		 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_rock" ]		 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_sand" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_snow" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_water" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_wood" ]		 = LoadFX( "fx/explosions/wood_explosion_1_decal" );
	level._effect[ "tank_blast_decal_asphalt" ]		 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_ceramic" ]		 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_plastic" ]		 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_rubber" ]		 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_cushion" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_fruit" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_blast_decal_paintedmetal" ] = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_riotshield" ]	 = LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_slush" ]		 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
 	level._effect[ "tank_blast_decal_default" ] 		= LoadFX( "fx/explosions/tank_concrete_explosion_decal" );
	level._effect[ "tank_blast_decal_none" ]	 = LoadFX( "fx/explosions/tank_impact_dirt_hamburg_decal" );
	level._effect[ "tank_shell_impact_hamburg" ] = LoadFX( "fx/explosions/tank_shell_impact_hamburg" );
	
	//hangar
	level._effect[ "hangar_wall_destroy" ]			 = LoadFX( "fx/maps/satfarm/hangar_wall_destroy" );
	level._effect[ "hangar_propane_tank_explosion" ] = LoadFX( "vfx/moments/satfarm/hangar_propane_tank_explosion" );
	
	// screenfx
	level._effect[ "vfx_scrnfx_pixelsplit" ]		= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_pixelsplit" );
	
	level._effect[ "sw_rog_strike_big_tail" ] 	= loadfx( "vfx/moments/skyway/sw_rog_strike_big_tail" );
	level._effect[ "sw_rog_strike_big_impact" ] = loadfx( "vfx/moments/skyway/sw_rog_strike_big_impact" );	
}

//object to attach view particles to
create_view_particle_source()
{
	
	if ( !IsDefined( level.view_particle_source ) )
	{
		level.view_particle_source = Spawn( "script_model", ( 0, 0, 0 ) );
		level.view_particle_source SetModel( "tag_origin" );
		
		level.view_particle_source.origin = level.player.origin;
		
		level.view_particle_source LinkToPlayerView( level.player, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
	}
	
}

overlord_transition_fx()
{
	create_view_particle_source();
	
	PlayFXOnTag( getfx( "vfx_scrnfx_pixelsplit" ), level.view_particle_source, "tag_origin" );
}