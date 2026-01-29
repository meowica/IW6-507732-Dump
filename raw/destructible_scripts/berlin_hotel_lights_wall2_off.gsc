#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	// nb I skinned all the geo to tag_fx because if the sound plays at tag_origin, the game thinks it's occluded by the wall.
	destructible_create("berlin_hotel_lights_wall2_off", "tag_fx", 20, undefined, 32 );
		destructible_fx( "tag_fx", "fx/props/light_off_glass_smash");
		destructible_sound( "dst_small_glass_wall_lights" );
	destructible_state( "tag_origin", "berlin_hotel_lights_wall2_smashed", 150, undefined, undefined, "splash" );
	destructible_state( "tag_origin", "berlin_hotel_lights_wall2_destroyed" );
}


