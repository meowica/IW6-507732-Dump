// Bannerfish - those little zebra-striped tropical fish with the long, trailing, yellow dorsal fin.
#include maps\interactive_models\_fish;
#using_animtree( "animals" );

main()
{
	info							   = SpawnStruct();
	info.animtree					   = #animtree;
	info.anims[ "idle"			][ 0 ] = %bannerfish_idle1;
	info.anims[ "idle"			][ 1 ] = %bannerfish_idle_fast;
	info.anims[ "idleweight"	][ 0 ] = 4;
	info.anims[ "idleweight"	][ 1 ] = 1;
	info.anims[ "flee_straight" ][ 0 ] = %bannerfish_flee_straight;
	info.anims[ "flee_left"		][ 0 ] = %bannerfish_flee_left;
	info.anims[ "flee_right"	][ 0 ] = %bannerfish_flee_right;
	info.anims[ "flee_continue"	][ 0 ] = %bannerfish_idle_fast;
	info.anims[ "turn_left"		   ]   = %bannerfish_turn_left;
	info.anims[ "turn_left_child"  ]   = %bannerfish_turn_left_add;	// Need two entries for each turn because primitive animations can't be additive.
	info.anims[ "turn_right"	   ]   = %bannerfish_turn_right;
	info.anims[ "turn_right_child" ]   = %bannerfish_turn_right_add;
	info.default_wander_radius		   = 20;
	info.wander_redirect_time		   = 2;		// Average time spent moving in the same direction before script turns the model
	info.react_distance				   = 36;
	
	// Define functions for removing entities when they're not needed.
	info.saveToStructFn = ::single_fish_saveToStruct;
	info.loadFromStructFn =::single_fish_loadFromStruct;

	if ( !IsDefined ( level._interactive ) )
		level._interactive = [];
	level._interactive[ "fish_bannerfish" ] = info;
	
	thread fish();
}
	
