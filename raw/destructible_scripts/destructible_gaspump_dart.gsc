#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Gas Pump 01
	//---------------------------------------------------------------------
	destructible_create( "destructible_gaspump_dart", "tag_origin", 150, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 15 );
				destructible_loopfx( "tag_death_fx", "fx/smoke/car_damage_whitesmoke", 0.4 );
			destructible_state( undefined, undefined, 150, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_death_fx", "fx/smoke/car_damage_blacksmoke", 0.4 );
			destructible_state( undefined, undefined, 250, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_death_fx", "fx/fire/gas_pump_fire_damage", .4 );
				destructible_sound( "gaspump01_flareup_med" );
				destructible_loopsound( "gaspump01_fire_med" );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 300, undefined, 32, "no_melee" );
				destructible_loopfx( "tag_death_fx", "fx/fire/gas_pump_fire_damage", .4 );
				destructible_loopsound( "gaspump01_fire_med" );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
				destructible_sound( "gaspump01_flareup_med" );
				destructible_loopfx( "tag_fx", "fx/fire/gas_pump_fire_handle", 0.05 );
				destructible_anim( %gaspump01_hose, #animtree, "setanimknob", undefined, undefined, "gaspump01_hose" );
			destructible_state( undefined, undefined, 400, undefined, 5, "no_melee" );
				destructible_fx( "tag_death_fx", "vfx/ambient/props/vfx_gas_pump_exp", false );
				destructible_sound( "gaspump01_explode" );
				destructible_explode( 6000, 8000, 210, 300, 50, 300, undefined, undefined, 0.3, 500 );
			destructible_state( undefined, "mp_dart_furniture_gaspump01_destroyed", undefined, undefined, "no_melee" );

		// Large Front Bottom panel
		destructible_part( "tag_panel_front01", "mp_dart_furniture_gaspump01_panel01", 80, undefined, undefined, undefined, 1.0, 1.0, undefined, 1.0 );
			destructible_physics();
		// Medium Front Middle panel
		destructible_part( "tag_panel_front02", "mp_dart_furniture_gaspump01_panel02", 40, undefined, undefined, undefined, 1.0, 1.0 );
			destructible_physics();
		// Small Front Top Panel
		destructible_part( "tag_panel_front03", "mp_dart_furniture_gaspump01_panel03", 40, undefined, undefined, undefined, 1.0, 1.0 );
			destructible_sound( "exp_gaspump_sparks" );
			destructible_fx( "tag_panel_front03", "fx/props/electricbox4_explode" );
			destructible_physics();

		// Large Back Bottom panel
		destructible_part( "tag_panel_back01", "mp_dart_furniture_gaspump01_panel01", 110, undefined, undefined, undefined, 1.0, 1.0, undefined, 1.0 );
			destructible_physics();
		// Medium Back Middle panel
		destructible_part( "tag_panel_back02", "mp_dart_furniture_gaspump01_panel02", 40, undefined, undefined, undefined, 1.0, 1.0 );
			destructible_physics();
		// Small Back Top Panel
		destructible_part( "tag_panel_back03", "mp_dart_furniture_gaspump01_panel03", 40, undefined, undefined, undefined, 1.0, 1.0 );
			destructible_sound( "exp_gaspump_sparks" );
			destructible_fx( "tag_panel_back03", "fx/props/electricbox4_explode" );
			destructible_physics();

}
