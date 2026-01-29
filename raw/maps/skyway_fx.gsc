main()
{
	if ( !GetDvarInt( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\skyway_fx::main();
		maps\createfx\skyway_sound::main();
	}
	
	// General
	level._effect[ "flesh_hit" ]			= LoadFX( "fx/impacts/flesh_hit" );
	
	// Intro pip
	//	level._effect[ "pip_static" ] 				= LoadFX( "vfx/moments/skyway/tv_static" );
	level._effect[ "pip_static" ] 				= LoadFX( "vfx/moments/skyway/tv_static_scroll_lines" );
	
	// SAT 2 hit
	level._effect[ "sathit_rog" ]			= LoadFX( "vfx/moments/skyway/sw_rog_strike_big" );
	level._effect[ "sathit_rog_huge" ]		= LoadFX( "vfx/moments/skyway/sw_rog_strike_huge" );
	level._effect[ "sathit_rog_shockwave" ] = LoadFX( "vfx/moments/skyway/sw_rog_strike_shockwave" );
	level._effect[ "sathit_sat_explode" ]	= LoadFX( "fx/explosions/skyway_satcar_explode" );
	level._effect[ "player_flash" ]			= LoadFX( "vfx/gameplay/screen_effects/vfx_scrnfx_fiery_bokeh_flash_01" );
	
	// Rooftops
	level._effect[ "rooftops_steam" ]			  = LoadFX( "fx/maps/skyway/outside_steam" );
	level._effect[ "roofhit_helo_explode" ]		  = LoadFX( "vfx/moments/skyway/explosion_large_moving" );
	level._effect[ "roofhit_helo_smoke" ]		  = LoadFX( "vfx/moments/skyway/firey_smoke_moving" );
	level._effect[ "roofhit_train_fire" ]		  = LoadFX( "vfx/moments/skyway/firey_thick_smoke_moving" );
	level._effect[ "roofhit_wheel_sparks" ]		  = LoadFX( "vfx/moments/skyway/sw_sparks_wheel_emit_big" );
	level._effect[ "roofhit_wheel_break" ]		  = LoadFX( "vfx/moments/skyway/sw_sparks_wheel_break" );
	level._effect[ "roofhit_wheel_sparks_small" ] = LoadFX( "vfx/moments/skyway/sw_sparks_wheel_emit_small" );
	level._effect[ "rooftops_wall_drag" ]		  = LoadFX( "vfx/moments/skyway/wall_drag_debris_moving" );
}

// this will link a fx origin to an entity, but play relative to the moving traincar so it will feel like the wind is being blown back.
// the position is very accurate, but the angles are less accurate.  This can cause the angles to be too influnced by the linked entity.
fx_origin_link_with_train_angles( link_ent, parent_traincar, link_ent_tag, ender )
{
	self.origin = link_ent GetTagOrigin( link_ent_tag );
	self LinkTo( link_ent, link_ent_tag );
	
	self endon( "death" );
	
	while ( 1 )
	{
		self Unlink();
		self.angles = parent_traincar GetTagAngles( "j_mainroot" );
		self LinkTo( link_ent, link_ent_tag );
		
		wait level.timestep;
	}
}

// this will align an fx origin to an entity every frame, but play relative to the moving traincar so it will feel like the wind is being blown back.
// the position is less accurate, but the angles are equally inarccurate.
fx_origin_with_train_angles( link_ent, parent_traincar, link_ent_tag, ender )
{
	self endon( "death" );
	
	while ( 1 )
	{
		self.angles = parent_traincar GetTagAngles( "j_mainroot" );
		self.origin = link_ent GetTagOrigin( link_ent_tag );

		wait level.timestep;
	}
}