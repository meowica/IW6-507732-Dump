#include maps\_global_fx_code;
#include maps\_utility;
#include common_scripts\_createfx;
#include common_scripts\utility;

main()
{

	level._effect[ "glow_red_light_400_strobe" ]	   				= LoadFX( "vfx/ambient/lights/vfx_glow_red_light_400_strobe" );
	level._effect[ "light_blue_steady_FX" ]			   			= LoadFX( "fx/misc/tower_light_blue_steady" );
	level._effect[ "wall_collapse_dust_wave_hamburg" ] 			= LoadFX( "fx/dust/wall_collapse_dust_wave_hamburg" );
	level._effect[ "airstrip_explosion" ]			   				= LoadFX( "fx/explosions/airstrip_explosion" );
	level._effect[ "ambient_explosion" ]			   				= LoadFX( "fx/explosions/ambient_explosion" );
	level._effect[ "steam_jet_loop" ]				   				= LoadFX( "vfx/ambient/steam/vfx_steam_jet_med_loop" );    
	level._effect[ "electrical_spark_loop" ]                        		= LoadFX( "vfx/moments/ODIN/electrical_sparks_zeroG_runner" );
	level._effect[ "circuit_breaker" ]								= LoadFX( "fx/explosions/circuit_breaker" );
	level._effect[ "xm25_explosion" ]								= LoadFX( "fx/explosions/xm25_explosion" );
	level._effect[ "steam_pipe_burst" ] 							= LoadFX( "fx/explosions/steam_pipe_burst" );
	level._effect[ "space_jet_small" ]							= LoadFX( "vfx/gameplay/space/space_jet_small" );

	level._effect[ "rog_flash_odin" ]					  			= LoadFX( "vfx/moments/odin/rog_flash_odin" );
	level._effect[ "rog_explosion_odin" ]				  			= LoadFX( "vfx/moments/odin/rog_explosion_odin" );
	level._effect[ "rog_shockwave_odin" ]						= LoadFX( "vfx/moments/odin/rog_shockwave_odin" );
	level._effect[ "rog_ambientfire_odin" ]						= LoadFX( "vfx/moments/odin/rog_ambientfire_odin" );
	level._effect[ "rog_smoke_odin" ]					  		= LoadFX( "vfx/moments/odin/rog_smoke_odin" );
	level._effect[ "rog_launch_barrel" ]							= LoadFX( "vfx/moments/odin/rog_launch_barrel" );
	level._effect[ "amber_light_45_beacon_nolight_beam" ] 		= LoadFX( "vfx/ambient/lights/amber_light_45_beacon_nolight_beam" );
	level._effect[ "amber_light_45_beacon_nolight_glow" ] 		= LoadFX( "vfx/ambient/lights/amber_light_45_beacon_nolight_glow" );
	level._effect[ "strobe_flash_distant" ]				  		= LoadFX( "vfx/moments/odin/strobe_flash_distant" );
	level._effect[ "explosive_decompression_1" ]		  			= LoadFX( "vfx/moments/odin/explosive_decompression_1" );
	level._effect[ "vfx_fire_burning_zeroG" ]			  			= LoadFX( "vfx/moments/odin/vfx_fire_burning_zeroG" );
	level._effect[ "debris_ambient_particulates" ]					= LoadFX( "vfx/moments/odin/debris_ambient_particulates" );
	level._effect[ "debris_ambient_shell_casings" ]				= LoadFX( "vfx/moments/odin/debris_ambient_shell_casings" );
	level._effect[ "sp_blood_float" ]								= LoadFX( "vfx/moments/odin/sp_blood_float" );
	level._effect[ "sp_blood_float_static" ]						= LoadFX( "vfx/moments/odin/sp_blood_float_static" );
	
	level._effect[ "ac130_smoke_geotrail_missile_large" ] 			= LoadFX( "fx/smoke/ac130_smoke_geotrail_missile_large" );
	level._effect[ "smoke_geotrail_ssnmissile" ]		  			= LoadFX( "fx/smoke/smoke_geotrail_ssnmissile" );
	level._effect[ "jet_afterburner_ignite" ]			  			= LoadFX( "fx/fire/jet_afterburner_ignite" );

level._effect[ "lens_flare_test_01" ] = loadfx( "vfx/test/lens_flare_test_01" );

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\odin_fx::main();
		maps\createfx\odin_sound::main();
	}
    
    lgt_vision_fog_init();
}

lgt_vision_fog_init()
{
	maps\_utility::vision_set_fog_changes( "odin", 0 );
}



fx_odin_airlock01_lights_setup()
{
	array_thread( GetEntArray( "fx_odin_airlock01_lights", "targetname" ), ::fx_odin_airlock01_lights );
}

fx_odin_airlock01_lights()
{
	// Don't link effects tag object to light because rotation doesn't work.
	
	// Beam.
	beam = spawn_tag_origin();
	beam.origin = self.origin - ( 0, 0, 5 );
	beam.angles = self.angles - ( 0, 90, 0 );
	beam LinkTo( self );
	
	PlayFXOnTag( level._effect[ "amber_light_45_beacon_nolight_beam" ], beam, "tag_origin" );

	// Glow.	
	glow = spawn_tag_origin();
	glow.origin = self.origin - ( 0, 0, 5 );
	glow.angles = self.angles;
	glow LinkTo( self );
	
	PlayFXOnTag( level._effect[ "amber_light_45_beacon_nolight_glow" ], glow, "tag_origin" );

	self thread fx_odin_airlock01_lights_rotate();

	flag_wait( "flag_fx_turn_off_airlock01_lights" );

	beam Delete();
	glow Delete();
}

fx_odin_airlock01_lights_rotate()
{
	self endon( "death" );
	level endon( "flag_fx_turn_off_airlock01_lights" );

	while( 1 )
	{
		self RotateYaw( 360, 1.5 );
	    wait 1.5;
	}
}