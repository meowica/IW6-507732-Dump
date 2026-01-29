#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Electrical transformer 01
	//---------------------------------------------------------------------
	destructible_create( "electrical_transformer_large", "tag_origin", 1500, undefined, 32, "no_melee" );
		destructible_splash_damage_scaler( 2 );
				destructible_loopsound( "electrical_transformer_sparks" );
				destructible_loopfx( "tag_fx", "fx/explosions/electrical_transformer_spark_runner", 0.8 );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 500, undefined, 32, "no_melee" );
				destructible_loopsound( "electrical_transformer_sparks" );
				destructible_fx( "tag_fx_junction", "fx/explosions/generator_sparks_c", false );
				destructible_loopfx( "tag_fx_junction", "fx/fire/electrical_transformer_blacksmoke_fire", 0.4 );
				destructible_loopfx( "tag_fx", "fx/explosions/electrical_transformer_spark_runner", 0.8 );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 300, undefined, 32, "no_melee" );
				destructible_loopsound( "electrical_transformer_sparks" );
				destructible_loopfx( "tag_fx_junction", "fx/fire/electrical_transformer_blacksmoke_fire", 0.4 );
				destructible_loopfx( "tag_fx", "fx/explosions/electrical_transformer_spark_runner", 0.8 );
				destructible_loopfx( "tag_fx_valve", "fx/explosions/generator_spark_runner", 0.6 );
				destructible_healthdrain( 12, 0.2, 210, "allies" );
			destructible_state( undefined, undefined, 500, undefined, 32, "no_melee" );
				destructible_fx( "tag_death_fx", "fx/explosions/electrical_transformer_explosion", false );
				destructible_sound( "electrical_transformer01_explode" );
				destructible_explode( 6000, 8000, 210, 300, 20, 300, undefined, undefined, 0.3, 500 );
			destructible_state( undefined, "com_electrical_transformer_large_des", undefined, undefined, "no_melee" );

		// door 1
		destructible_part( "tag_door1", "com_electrical_transformer_large_dam_door1", 1500, undefined, undefined, undefined, 0, 1.0, undefined, 1  );
			destructible_sound( "electrical_transformer01_explode_detail" );
			destructible_fx( "tag_door1", "fx/explosions/generator_explosion" );
			destructible_physics();

		// door 2
		destructible_part( "tag_door2", "com_electrical_transformer_large_dam_door2", 150, undefined, undefined, undefined, 0, 1.0, undefined, 1 );
			destructible_physics();

		// door 3
		destructible_part( "tag_door3", "com_electrical_transformer_large_dam_door3", 150, undefined, undefined, undefined, 0, 1.0, undefined, 1 );
			destructible_physics();

		// door 4
		destructible_part( "tag_door4", "com_electrical_transformer_large_dam_door4", 150, undefined, undefined, undefined, 0, 1.0, undefined, 1 );
			destructible_physics();

		// door 5
		destructible_part( "tag_door5", "com_electrical_transformer_large_dam_door5", 1500, undefined, undefined, undefined, 0, 1.0, undefined, 1 );
			destructible_sound( "electrical_transformer01_explode_detail" );
			destructible_fx( "tag_door5", "fx/explosions/generator_explosion" );
			destructible_physics();

		// door 6
		destructible_part( "tag_door6", "com_electrical_transformer_large_dam_door6", 150, undefined, undefined, undefined, 0, 1.0, undefined, 1 );
			destructible_physics();

		// door 7
		destructible_part( "tag_door7", "com_electrical_transformer_large_dam_door7", 150, undefined, undefined, undefined, 0, 1.0, undefined, 1 );
			destructible_loopsound( "electrical_transformer_sparks" );
			destructible_fx( "tag_door7", "fx/props/electricbox4_explode" );
			destructible_physics();

}
