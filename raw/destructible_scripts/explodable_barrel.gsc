#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	destructible_create( "explodable_barrel", "tag_origin", 55 );
			destructible_state( "tag_origin", undefined, 44, undefined, 32, "no_melee" );
				destructible_fx( "TAG_TOP", "fx/props/barrel_ignite", true );
				destructible_loopfx( "TAG_TOP", "fx/props/barrel_fire_top", 0.4 );
				destructible_healthdrain( 15, 0.05, 128 );
			destructible_state( "tag_origin", undefined, 100, undefined, 32, "no_melee" );
				destructible_fx( "tag_origin", "fx/props/barrelExp", false );
				destructible_sound( "barrel_mtl_explode" );
				destructible_explode( 4000, 5000, 210, 250, 50, 300, undefined, undefined, 0.3, 500 );
			destructible_state( undefined,"com_barrel_piece2_1" );
}
