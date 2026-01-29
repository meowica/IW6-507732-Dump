// Hanging light that swings when shot and smashes
#include common_scripts\_destructible;

main()
{
	if( common_scripts\utility::isSP() )
	{
		destructible_create( "toy_lv_light_fixture_01", "tag_origin", 0 );
			destructible_function( maps\interactive_models\hanging_light_off::hanging_light_off );
		destructible_state( "tag_origin",undefined, 10 );
			destructible_fx( "tag_fx", "props/lv_light_fixture_01_smash" );
			//TODO destructible_sound( "dst_small_glass_wall_lights" );
		destructible_state( "tag_origin", "lv_light_fixture_01_d" );
	}
	else
	{
		destructible_create( "toy_lv_light_fixture_01", "tag_origin", 10 );
			destructible_fx( "tag_fx", "props/lv_light_fixture_01_smash" );
			//TODO destructible_sound( "dst_small_glass_wall_lights" );
		destructible_state( "tag_origin", "lv_light_fixture_01_d" );
	}
}