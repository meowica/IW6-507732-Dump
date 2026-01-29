#include maps\_utility;
#include common_scripts\utility;

main()
{
	precacheFX();
	
	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	
	{
		maps\createfx\las_vegas_sound::main();
		maps\createfx\las_vegas_fx::main();
	}
	
}

precacheFX()
{
	level._effect[ "sand_wind_lg" ] 			= LoadFX( "fx/dust/dust_wind_canyon" );
	
	level._effect[ "bar_box_exp" ]			= LoadFX( "fx/_requests/las_vegas/restaurant_cardboard_box_exp" );
	
	level._effect[ "footstep_dust_sandstorm"		] = LoadFX( "fx/impacts/footstep_dust_sandstorm" );
	level._effect[ "footstep_dust_sandstorm_runner" ] = LoadFX( "fx/impacts/footstep_dust_sandstorm_runner" );
	level._effect[ "footstep_sand_decal"		] = LoadFX( "fx/impacts/footstep_sand_decal" );
	
	level._effect[ "ceiling_dust" ]						= LoadFX( "fx/dust/ceiling_dust_default" );
	
	level._effect[ "sand_storm_distant" ] = LoadFX( "fx/weather/sand_storm_distant" );
	level._effect[ "sand_storm_light"	] = LoadFX( "fx/weather/sand_storm_light" );
	
	level._effect[ "sand_ambient"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_ambient_blowing" );
	level._effect[ "sand_blow_flat"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_blowing_flat" );
	level._effect[ "sand_blow_flat_runner"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_blowing_flat_runner" );
	level._effect[ "sand_ceiling_drip"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_ceiling_drip" );
	level._effect[ "sand_dust_falling_runner"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_dust_falling_runner" );
	level._effect[ "sand_dust_room_hang"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_dust_room_hang" );
	level._effect[ "sand_groundspawn_light"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_groundspawn_light" );
	level._effect[ "sand_street_flow"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_street_flow" );
	level._effect[ "vfx_las_vegas_street_flow"	] = LoadFX( "vfx/ambient/weather/sand/vfx_las_vegas_street_flow" );
	level._effect[ "vfx_las_vegas_street_flow_fill"	] = LoadFX( "vfx/ambient/weather/sand/vfx_las_vegas_street_flow_fill" );
	level._effect[ "vfx_sand_blowing_edge_detail"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_blowing_edge_detail" );
	level._effect[ "vfx_sand_window_fall"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_window_fall" );
	level._effect[ "vfx_las_vegas_sand_vortex_runner"	] = LoadFX( "vfx/ambient/weather/sand/vfx_las_vegas_sand_vortex_runner" );
	level._effect[ "vfx_leaf_palm_high_wind"	] = LoadFX( "vfx/ambient/trees/vfx_leaf_palm_high_wind" );
	level._effect[ "headshot_blood"	] = LoadFX( "fx/misc/blood_head_kick" );
	level._effect[ "vfx_sand_trash_spiral_runner"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_trash_spiral_runner" );
	level._effect[ "vfx_sand_streamers_runner"	] = LoadFX( "vfx/ambient/weather/sand/vfx_sand_streamers_runner" );
    level._effect[ "vfx_electrical_spark_drip"	] = LoadFX( "vfx/ambient/sparks/vfx_electrical_spark_drip" );
    level._effect[ "vfx_electrical_spark"	] = LoadFX( "vfx/moments/las_vegas/vfx_train_fall_sparks" );
    level._effect[ "vfx_debris_fall_train" ]						= LoadFX( "vfx/moments/las_vegas/vfx_debris_fall_train" );
    level._effect[ "vfx_bus_win_shtr_front" ]						= LoadFX( "vfx/moments/las_vegas/vfx_bus_win_shtr_front" );
	level._effect[ "dust_motes_interior"	] = LoadFX( "vfx/ambient/dust/particulates/dust_motes_interior" ); 
	level._effect[ "vfx_smk_building_dmg_wind"	] = LoadFX( "vfx/ambient/smoke/vfx_smk_building_dmg_wind" );
	level._effect[ "vfx_fire_car_med"	] = LoadFX( "vfx/ambient/fire/fuel/vfx_fire_car_med" );	
	level._effect[ "vfx_fire_car_large"	] = LoadFX( "vfx/ambient/fire/fuel/vfx_fire_car_large" );
	level._effect[ "vfx_fire_car_small"	] = LoadFX( "vfx/ambient/fire/fuel/vfx_fire_car_small" );
	level._effect[ "vfx_adult_flyers"	] = LoadFX( "vfx/ambient/misc/vfx_adult_flyers" );
	level._effect[ "vfx_smk_building_dmg_sm"	] = LoadFX( "vfx/ambient/smoke/vfx_smk_building_dmg_sm" );
	level._effect[ "vfx_wind_motes"	] = LoadFX( "vfx/ambient/dust/particulates/vfx_wind_motes" );	
 	level._effect[ "vfx_smk_blg_dmg_sm_nofire"	] = LoadFX( "vfx/ambient/smoke/vfx_smk_blg_dmg_sm_nofire" );   

    
	
	
	// raidroom
	level._effect[ "hotel_hallway_sparks" ] = LoadFX( "fx/explosions/sparks_clk" );
	level._effect[ "hotel_hallway_luggage" ] = LoadFX( "fx/_requests/las_vegas/hotel_hallway_luggage" );
	level._effect[ "raidroom_window_glassbreak_fx" ] = LoadFX( "fx/props/highrise_glass_120x110" );
	level._effect[ "raidroom_door_fx"			   ] = LoadFX( "fx/props/wood_plank1" );
	level._effect[ "raidroom_wddoor_bullet_impact" ] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_wddoor_bullet_impact" );
	level._effect[ "raidroom_paper_vortex"		   ] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_room_paper_vortex" );
	level._effect[ "raidroom_paper_vortex_quick"		   ] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_rm_vortex_quick" );
	level._effect[ "raidroom_window_flow"		   ] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_raidroom_window_flow" );
	level._effect[ "raidroom_jump_slide_glass"	   ] = LoadFX( "vfx/moments/las_vegas/vfx_glass_shard_slide" );
	level._effect[ "raidroom_jump_drop_glass"	   ] = LoadFX( "vfx/moments/las_vegas/vfx_glass_shard_drop" );
	level._effect[ "slide_boot_dust"	   ] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_slide_boot_dust" );
 	level._effect[ "vfx_dust_hand_clap" ]						= LoadFX( "vfx/moments/las_vegas/vfx_dust_hand_clap" );
	
	// flashlight
	//level._effect["flashlight"] 						= loadfx( "fx/misc/flashlight" );
	level._effect["flashlight"] 						= loadfx( "fx/_requests/las_vegas/flashlight_vegas" );
	//level._effect["flashlight_spotlight"] 				= loadfx( "fx/misc/flashlight_spotlight" );
	level._effect[ "flashlight_spotlight" ]					= loadfx( "fx/misc/flashlight_prague" );
	level._effect["flashlight_cheap"] 					= loadfx( "fx/_requests/las_vegas/flashlight_cheap_vegas" );
	//level._effect["flashlight_cheap"] 				= loadfx( "fx/misc/flashlight_cheap_prague" );
	level._effect["flashlight_gamblingroom"] 			= loadfx( "fx/_requests/las_vegas/gamblingroom_spotlight" );
	level._effect[ "flashlight_atrium" ]					= loadfx( "fx/lights/cornered_balcony_spotlight" );
	
	level._effect["foliage_dub_potted_spikey_plant"]	= loadfx( "fx/props/foliage_dub_potted_spikey_plant" );
	
	level._effect["car_glass_large"]	= loadfx( "fx/props/car_glass_large" );
	
	level._effect["aerial_explosion_large"]	= loadfx( "fx/explosions/aerial_explosion_large" );
	
	// call this when turning the corner into the first alley way
	level._effect["small_vehicle_explosion_new"]	= loadfx( "fx/explosions/small_vehicle_explosion_new" );
	
	
	level._effect["bridge_explode_prague_cheap"]	= loadfx( "fx/explosions/bridge_explode_prague_cheap" );
	
	level._effect["vfx_sand_stream"]= loadfx( "vfx/moments/las_vegas/vfx_sand_stream" );
	
	level._effect[ "vfx_luxor_glass_smash"	] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_glass_smash" );
	level._effect[ "vfx_luxor_window_flow_runner"	] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_window_flow_runner" );
	level._effect[ "vfx_luxor_room_fill"	] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_room_fill" );	
	level._effect[ "vfx_luxor_room_fill_center"	] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_glass_smash_center" ); 
	level._effect[ "vfx_luxor_room_fill_outter"	] = LoadFX( "vfx/moments/las_vegas/vfx_luxor_glass_smash_outter" );
	
	level._effect["car_headlight_truck_L"]	= loadfx( "fx/misc/car_headlight_truck_L" );
	level._effect["car_headlight_truck_R"]	= loadfx( "fx/misc/car_headlight_truck_R" );
	
//	level._effect["wall_dust_crumble"]	= loadfx( "fx/dust/wall_dust_crumble" );
	
	level._effect["vfx_dust_hang_pulse"]	= loadfx( "vfx/ambient/dust/particulates/vfx_dust_hang_pulse" );
	
		
	level._effect[ "vfx_sand_window_fall"	] 			= LoadFX( "vfx/ambient/weather/sand/vfx_sand_window_fall" );
	level._effect[ "vfx_thick_falling_stream" ]			= LoadFX( "vfx/ambient/weather/sand/vfx_sand_thick_falling_stream" );
	level._effect[ "vfx_sand_thick_fall_tall_thin" ]	= LoadFX( "vfx/ambient/weather/sand/vfx_sand_thick_fall_tall_thin" );
	level._effect[ "vfx_sand_ground_spawn_loop" ]		= LoadFX( "vfx/moments/las_vegas/vfx_sand_ground_spawn_loop" );
	
	
	level._effect["vfx_sand_body_impact"]	= loadfx( "vfx/ambient/weather/sand/vfx_sand_body_impact" );
	level._effect["vfx_sand_blowing_edge_detail_sm"]	= loadfx( "vfx/ambient/weather/sand/vfx_sand_blowing_edge_detail_sm" );
	// add cool smoke fx to the chopper when it gets sniped.
	// vfx_sand_blowing_edge_detail_sm , cool arm stream
	//vfx_sand_body_impact

	// Entrance Section
	level._effect[ "vfx_sand_hand" ] 			= LoadFx( "vfx/moments/las_vegas/vfx_sand_hand" );
	level._effect[ "vfx_sand_forearm" ] 		= LoadFx( "vfx/moments/las_vegas/vfx_sand_forearm" );
	level._effect[ "vfx_hand_clap" ] 		= LoadFx( "vfx/moments/las_vegas/vfx_dust_hand_clap" );
	
	level._effect["smoke_trail_black_heli"]	= loadfx( "fx/smoke/smoke_trail_black_heli" );

	level._effect["smoke_trail_black_heli_streamer"]	= loadfx( "fx/smoke/smoke_trail_black_heli" );
	
	
	level._effect["vfx_dark_sm_emitter"]	= loadfx( "vfx/gameplay/vehicle_destruction/air/vfx_dark_sm_emitter" );
	
	level._effect["vfx_train_fall_impact_a"]	= loadfx( "vfx/moments/las_vegas/vfx_train_fall_impact_a" );
	level._effect["vfx_train_fall_track_impact"]	= loadfx( "vfx/moments/las_vegas/vfx_train_fall_track_impact" );	

	level._effect["vfx_dmg_heli_smk_int"]	= loadfx( "vfx/moments/las_vegas/vfx_dmg_heli_smk_int" );	
	
	level._effect["smoke_geotrail_rpg"]	= loadfx( "fx/smoke/smoke_geotrail_rpg" );	

//	level._effect["dcemp_glass"]	= loadfx( "fx/props/dcemp_glass" );

	level._effect[ "vfx_gnat_swarm" ] 											= LoadFX( "vfx/ambient/animals/vfx_gnat_swarm" );
	level._effect[ "vfx_blurred_insects" ] 									= LoadFX( "vfx/ambient/animals/vfx_blurred_insects" );
	level._effect[ "vfx_blurred_insects_bidirectional" ] 		= LoadFX( "vfx/ambient/animals/vfx_blurred_insects_bidirectional" );
	level._effect[ "vfx_insect_volume" ] 										= LoadFX( "vfx/ambient/animals/vfx_insect_volume" );
	
	level._effect[ "hanging_dust_indoor" ] 									= LoadFX( "vfx/ambient/dust/hanging_dust_indoor" );
	level._effect[ "hanging_dust_indoor_hallway" ] 					= LoadFX( "vfx/ambient/dust/hanging_dust_indoor_hallway" );
	
	
	level._effect[ "vfx_dmg_heli_sparks_runner" ] 					= LoadFX( "vfx/moments/las_vegas/vfx_dmg_heli_sparks_runner" );
	level._effect[ "vfx_sniper_heli_hit_smk_runner" ] 					= LoadFX( "vfx/moments/las_vegas/vfx_sniper_heli_hit_smk_runner" );
	level._effect[ "vfx_sniper_heli_hit_smk" ] 						= LoadFX( "vfx/moments/las_vegas/vfx_sniper_heli_hit_smk" );
	
	// chopper stuff
	level._effect["small_vehicle_explosion_new"]	= loadfx( "fx/explosions/small_vehicle_explosion_new" );
	level._effect["smoke_trail_black_heli"]	= loadfx( "fx/smoke/smoke_trail_black_heli" );
	level._effect["smoke_trail_black_heli_streamer"]	= loadfx( "fx/smoke/smoke_trail_black_heli" );
	level._effect["vfx_dark_sm_emitter"]	= loadfx( "vfx/gameplay/vehicle_destruction/air/vfx_dark_sm_emitter" );
	level._effect["vfx_dmg_heli_smk_int"]	= loadfx( "vfx/moments/las_vegas/vfx_dmg_heli_smk_int" );
	level._effect["small_vehicle_explosion_new"]	= loadfx( "fx/explosions/small_vehicle_explosion_new" );
	level._effect["smoke_geotrail_rpg"] 			= loadfx("fx/smoke/smoke_geotrail_rpg");
	
	// AAS_72X damage FX
	level._effect[ "aas_72x_damage_trail" ] 		= LoadFX( "vfx/_requests/las_vegas/aas_72x_damage_trail" );
	level._effect[ "aas_72x_damage_explosion" ] 	= LoadFX( "fx/explosions/helicopter_explosion_secondary_small" );

	// Enemy chopper crash
	level._effect["choppercrash_initial_explosion"]	= LoadFx( "vfx/moments/las_vegas/vfx_heli_crash_dmg_expl" );
	level._effect["choppercrash_streaming_smoke"]	= LoadFx( "vfx/gameplay/vehicle_destruction/air/vfx_dark_sm_emitter" );
	level._effect["choppercrash_engine_fire"]		= LoadFx( "vfx/moments/las_vegas/vfx_heli_dmg_eng_fire_runner" );
	level._effect["choppercrash_engine_sparks"]		= LoadFx( "vfx/moments/las_vegas/vfx_dmg_heli_sparks_runner" );
	level._effect["choppercrash_tail_explosion"]	= LoadFx( "vfx/moments/las_vegas/vfx_heli_crash_tail_exp" );
	level._effect["choppercrash_tail_smoke"]		= LoadFx( "vfx/gameplay/vehicle_destruction/air/vfx_tail_smk_emitter" );
	level._effect["choppercrash_rotor_hit"]			= LoadFx( "vfx/moments/las_vegas/vfx_heli_crash_rotor_hit" );
	level._effect["choppercrash_ground_hit"]		= LoadFx( "vfx/moments/las_vegas/vfx_heli_crash_hit_sparks" );
	level._effect["choppercrash_ground_scrape"]		= LoadFx( "vfx/moments/las_vegas/vfx_heli_crash_scrape_sparks" );
	level._effect["choppercrash_debris"]			= LoadFx( "vfx/moments/las_vegas/vfx_heli_crash_debris" );
	level._effect["sniped_heli_exlposion"]			= LoadFx( "vfx/moments/las_vegas/vfx_heli_crash_tail_exp" );
//	level._effect["smoke_geotrail_rpg"]				= LoadFx( "vfx/gameplay/vehicle_destruction/air/vfx_rocket_trail" );
}

footStepEffects()
{
	animscripts\utility::setFootstepEffect( "dirt",	level._effect["footstep_sand_decal"] );
	animscripts\utility::setFootstepEffect( "sand",	level._effect["footstep_sand_decal"] );
	//Player Footstep fx
	//level.player thread PlayerSandFootsteps();
}

PlayerSandFootsteps()
{
	while( 1 )
	{
		wait( RandomFloatRange( 0.25, .5 ) );
		start = self.origin + ( 0, 0, 0 );
		end = self.origin - ( 0, 0, 5 );
		
		trace = BulletTrace( start, end, false, undefined );
		forward = AnglesToForward( self.angles );
		mydistance = Distance( self GetVelocity(), ( 0, 0, 0 ) );
		if ( trace[ "surfacetype" ] != "dirt" )
			continue;
		if ( mydistance <= 10 )
			continue;
		
		PlayFX( level._effect["footstep_dust_sandstorm_runner"], trace[ "position" ], trace[ "normal" ], forward );
	}
}

wildlife()
{
	thread mask_gamb_room_birds();
	thread exterior_tumbleweed();
}

// Mask (deactivate) the birds in the gambling room until the player enters, so they aren't frightened away by the gunfire before he gets to see them.
mask_gamb_room_birds()	// nb This fn needs to be run after _precache, although it can be run before or after _load.
{
	gambling_room_fx_volumes = GetEntArray( "gamb_room_birds_volume", "script_noteworthy" );
	mask_interactives_in_volumes( gambling_room_fx_volumes );
	gambling_room_trigger = GetEnt( "trigger_birds_gamblingroom", "targetname" );
	AssertEx( IsDefined( gambling_room_trigger ), "Birds trigger for gambling room not found." );
	gambling_room_trigger waittill( "trigger" );
	foreach ( mask_volume in gambling_room_fx_volumes )
		mask_volume activate_interactives_in_volume();
}

exterior_tumbleweed()
{
	flag_wait( "FLAG_player_slide_complete" );
	delaythread( 17, maps\_vehicle::spawn_vehicles_from_Targetname_and_drive, "entrance_tumbleweed_getup" );
	flag_wait( "FLAG_getup_done" );
	delaythread( 1.5, maps\_vehicle::spawn_vehicles_from_Targetname_and_drive, "entrance_tumbleweed_convoy" );
	delaythread( 15, maps\_vehicle::spawn_vehicles_from_Targetname_and_drive, "entrance_tumbleweed_convoy2" );
}
