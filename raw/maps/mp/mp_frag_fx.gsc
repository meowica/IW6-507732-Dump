main()
{
	level._effect[ "vfx_frag_mist_distant" ] = loadfx( "vfx/ambient/atmospheric/vfx_frag_mist_distant" );
	level._effect[ "drips_frag_drops" ] = loadfx( "fx/water/drips_frag_drops" );
	level._effect[ "vfx_fire_furnace" ] = loadfx( "vfx/ambient/fire/fuel/vfx_fire_furnace" );
	level._effect[ "vfx_fire_barrel_small_nolight" ] = loadfx( "vfx/ambient/fire/vfx_fire_barrel_small_nolight" );
	level._effect[ "vfx_light_util_square" ] = loadfx( "fx/lights/vfx_light_util_square" );
	level._effect[ "vfx_glow_red_light_blink_frag" ] = loadfx( "vfx/ambient/lights/vfx_glow_red_light_blink_frag" );
	level._effect[ "vfx_godray_frag_anim_solid_long" ] = loadfx( "vfx/ambient/lights/vfx_godray_frag_anim_solid_long" );
	level._effect[ "vfx_godray_frag_anim_window" ] = loadfx( "vfx/ambient/lights/vfx_godray_frag_anim_window" );
	level._effect[ "vfx_glow_red_light_noblink_frag" ] = loadfx( "vfx/ambient/lights/vfx_glow_red_light_noblink_frag" );
	level._effect[ "vfx_glow_red_light_frag" ] = loadfx( "vfx/ambient/lights/vfx_glow_red_light_frag" );
	level._effect[ "vfx_godray_frag_anim_streak" ] = loadfx( "vfx/ambient/lights/vfx_godray_frag_anim_streak" );
	level._effect[ "vfx_steam_escape" ] = loadfx( "vfx/ambient/steam/vfx_steam_escape" );
	level._effect[ "vfx_smk_puffy_white_01" ] = loadfx( "vfx/ambient/smoke/vfx_smk_puffy_white_01" );
	level._effect[ "vfx_steam_wispy_nitro" ] = loadfx( "vfx/ambient/steam/vfx_steam_wispy_nitro" );
	level._effect[ "amb_int_haze_frag" ] = loadfx( "fx/smoke/amb_int_haze_frag" );
	level._effect[ "amb_smk_dark_frag" ] = loadfx( "fx/smoke/amb_smk_dark_frag" );
	level._effect[ "vfx_steam_wispy_frag" ] = loadfx( "vfx/ambient/steam/vfx_steam_wispy_frag" );
	level._effect[ "vfx_trash_frag" ] = loadfx( "vfx/ambient/misc/vfx_trash_frag" );
	level._effect[ "vfx_spiral_trash" ] = loadfx( "vfx/ambient/misc/vfx_spiral_trash" );
	level._effect[ "vfx_godray_frag_anim_solid" ] = loadfx( "vfx/ambient/lights/vfx_godray_frag_anim_solid" );
	level._effect[ "vfx_dust_indoor_frag" ] = loadfx( "vfx/ambient/dust/vfx_dust_indoor_frag" );
	level._effect[ "vfx_godray_frag_anim" ] = loadfx( "vfx/ambient/lights/vfx_godray_frag_anim" );
	level._effect[ "vfx_glow_sign_frag" ] = loadfx( "vfx/ambient/lights/vfx_glow_sign_frag" );
	level._effect[ "vfx_sparks_sign" ] = loadfx( "vfx/ambient/sparks/vfx_sparks_sign" );
	level._effect[ "snow_light_mp" ] 	   = loadfx( "fx/snow/snow_light_mp" );
	    level._effect[ "vfx_smk_stack_white" ] = loadfx( "vfx/ambient/smoke/vfx_smk_stack_white" );
	    level._effect[ "fire_generic_atlas_small" ] = loadfx( "fx/fire/fire_generic_atlas_small" );
	    level._effect[ "vfx_smk_stack_vista" ] = loadfx( "vfx/ambient/smoke/vfx_smk_stack_vista" );
	level._effect[ "fluorescent_glow" ] = loadfx( "fx/misc/fluorescent_glow" );
	
	level._effect["mp_frag_button_off"] = loadfx("fx/lights/lights_green_sm");
	level._effect["mp_frag_button_on"] = loadfx("fx/lights/lights_red_sm");
	
/#
    if ( getdvar( "clientSideEffects" ) != "1" )
        maps\createfx\mp_frag_fx::main();
#/

}
