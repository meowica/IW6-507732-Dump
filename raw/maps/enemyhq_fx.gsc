main()
{

	if ( !getdvarint( "r_reflectionProbeGenerate" ) )
	{
		maps\createfx\enemyhq_fx::main();
		maps\createfx\enemyhq_sound::main();
	}

	level._effect[ "cage_smoke" ] = LoadFX( "fx/smoke/teargas_grenade" );
	level._effect[ "sparks_car_scrape_point" ] = LoadFX( "fx/misc/sparks_car_scrape_point" );

	level._effect[ "glowstick" ] = LoadFX("fx/lights/clockwork_glowstick" );

	level._effect[ "blood_small" ]									= loadfx( "fx/misc/blood_head_kick" );
	level._effect[ "blood_medium" ]									= loadfx( "fx/misc/blood_back_stab" );
	level._effect[ "blood_heavy" ]									= loadfx( "fx/misc/blood_large_gush" );
	
	// Dog FX
	level._effect[ "dog_bite" ][1]									= loadfx( "fx/misc/blood_head_kick" );
	level._effect[ "dog_bite" ][2]									= loadfx( "fx/misc/blood_back_stab" );
	level._effect[ "dog_bite" ][4]									= loadfx( "fx/misc/blood_large_gush" );
	
	
	level._effect[ "bottles_misc1_destruct" ]						    	= loadfx( "fx/props/bottles_misc1_destruct" );
	level._effect[ "bottles_misc2_destruct" ]						    	= loadfx( "fx/props/bottles_misc2_destruct" );
	level._effect[ "bottles_misc3_destruct" ]						    	= loadfx( "fx/props/bottles_misc3_destruct" );
	level._effect[ "bottles_misc4_destruct" ]						    	= loadfx( "fx/props/bottles_misc4_destruct" );
	level._effect[ "bottles_misc5_destruct" ]						    	= loadfx( "fx/props/bottles_misc5_destruct" );

	level._effect[ "field_smoke_stack_small" ]						    	= loadfx( "fx/smoke/thick_black_smoke_mp");
	level._effect[ "field_smoke_stack_thick" ]						    = loadfx( "fx/smoke/thick_black_smoke_l");
	
	level._effect[ "finale_explosion" ]								= loadfx("fx/explosions/vehicle_explosion_gaz");

}
