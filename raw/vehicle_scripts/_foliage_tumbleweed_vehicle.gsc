#include maps\_vehicle;
#using_animtree( "vehicles" );

// This is the lightest ground vehicle type I could make that still has a model and plays an animation.
// Note that the model needs tag_origin, tag_body and tag_wheel_back_left, back_right, front_left and front_right, or else it won't work.
// Also any custom animation has to be on other joints.  The abovementioned tags are controlled by code.

/*QUAKED script_vehicle_tumbleweed (1 0 0) (-16 -16 -24) (16 16 32) x SPAWNER
 * 
This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_foliage_tumbleweed_vehicle::main( "foliage_tumbleweed", undefined, "script_vehicle_tumbleweed" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_foliage_tumbleweed

defaultmdl="foliage_tumbleweed"
default:"vehicletype" "foliage_tumbleweed_vehicle"
default:"script_team" "neutral"
*/

main( model, type, classname )
{
	build_template( "foliage_tumbleweed_vehicle", model, type, classname );
	build_localinit( ::init_local );	// Apparently you need this or _vehicle_code::precachesetup() thinks the vehicle isn't set up right.
	build_drive( %foliage_tumbleweed_roll_loop1, undefined, 25 );
	build_life( 1 );
}

init_local()
{
	// To investigate: Maybe I can set self.script_cheap = 1 here.
}