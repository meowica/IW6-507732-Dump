main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\loki_fx::main();
		maps\createfx\loki_sound::main();
	}

	level._effect[ "explosion"		 ] = LoadFX( "fx/explosions/space_explosion" );
	level._effect[ "explosion_small" ] = LoadFX( "fx/explosions/space_explosion_small" );
	level._effect[ "sniper_glint" ]	   = LoadFX( "fx/misc/scope_glint" );
	
	level._effect[ "steam_small" ]	   = LoadFX( "fx/impacts/pipe_steam_small" );

	// ROG sequence, may need to be culled
	level._effect[ "ROG_single_geotrail" ]			= LoadFX( "fx/smoke/smoke_geotrail_hellfire_cheap" );
	level._effect[ "ROG_single_explosion" ]			= LoadFX( "fx/explosions/bomb_explosion_large_ac130" );
	level._effect[ "ROG_cam_static" ]				= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_snakecam_static" );
	level._effect[ "thick_dark_smoke_giant_ny" ]	= LoadFX( "fx/smoke/thick_dark_smoke_giant_nyharbor" );
	level._effect[ "thick_dark_smoke_giant_paris" ] = LoadFX( "fx/smoke/thick_dark_smoke_giant_paris" );
	level._effect[ "field_fire_smolder_500x500" ]	= LoadFX( "fx/fire/field_fire_smolder_500x500" );
	level._effect[ "thick_black_smoke_l" ]			= LoadFX( "fx/smoke/thick_black_smoke_l" );
	level._effect[ "shockwave" ]					= LoadFX( "vfx/moments/black_ice/vfx_exfil_xplosion_shockwave" );
	level._effect[ "explosion_01" ]					= LoadFX( "vfx/moments/black_ice/vfx_rig_fire_exfil_xplosion_huger" );
	level._effect[ "smoke_01" ]						= LoadFX( "vfx/moments/odin/rog_smoke_odin" );
	level._effect[ "shockwave_02" ]					= LoadFX( "vfx/moments/loki/vfx_rog_shockwave_loki" );
	level._effect[ "building_collapse_01" ]			= LoadFX( "fx/explosions/cave_mouth_wall_blast_rescue" );
	level._effect[ "building_collapse_blast_01" ]	= LoadFX( "fx/maps/ny_harbor/ny_harbor_buildingchunkfall" );
	level._effect[ "space_jet_small" ]				= loadfx( "vfx/gameplay/space/space_jet_small" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ROG_cam_fx()
{
	create_view_particle_source();
				
	PlayFXOnTag( level._effect[ "ROG_cam_static" ], level.view_particle_source, "tag_origin" );
	
	//level waittill( "DONE!" );
	
	//stop_exploder ( "ROG_cam_static" );
	
	//StopFXOnTag( GetFX( "ROG_cam_static" ), level.view_particle_source, "tag_origin" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//object to attach view particles to
create_view_particle_source()
{
	if ( !IsDefined( level.view_particle_source )  )
	{
		level.view_particle_source = spawn( "script_model", ( 0, 0, 0 ) );
		level.view_particle_source setmodel( "tag_origin" );
		
		level.view_particle_source.origin = level.player.origin;
		
		level.view_particle_source LinkToPlayerView( level.player, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
	}
	
}
