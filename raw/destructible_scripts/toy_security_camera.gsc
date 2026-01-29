#include common_scripts\_destructible;
#using_animtree( "destructibles" );

main()
{
	//---------------------------------------------------------------------
	// Rotating security camera
	//---------------------------------------------------------------------
	destructible_create( "toy_security_camera", "tag_camera_tilt", 0, undefined, 32 );
			destructible_anim( %security_camera_idle, #animtree, "setanimknob", undefined, undefined, "security_camera_idle" );
		destructible_state( "tag_camera_tilt", "com_security_camera_tilt_animated", 75 );
			destructible_anim( %security_camera_destroy, #animtree, "setanimknob", undefined, undefined, "security_camera_destroy" );
			destructible_fx( "tag_fx", "fx/props/security_camera_explosion_moving" );
			destructible_sound( "security_camera_sparks" );
		destructible_state( undefined, "com_security_camera_d_tilt_animated", undefined, undefined, "no_melee" );
}
