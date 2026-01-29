#include maps\mp\agents\_scriptedAgents;

//=======================================================
//				initAlienAnims
//=======================================================
initAlienAnims()
{
	level.alienAnimData = SpawnStruct();

	initAlienCannedTraverses( level.alienAnimData );
	
	initAlienJumpTraverses( level.alienAnimData );
	
	initAlienPain( level.alienAnimData );
	
	initAlienDeath( level.alienAnimData );
	
	initMoveBackAnims();
	
	//<NOTE JC> The following values are hard-coded here.  Need to run calculateAnimData() if the specific animation assets are
	//          changed.
	level.alienAnimData.jumpLaunchArrival_maxMoveDelta = 107.659;
	level.alienAnimData.stopSoon_NotifyDist = 99.4488;
}

calculateAnimData()
{
	//<NOTE JC> The reason for this function is that we can only GetAnimEntry running on an agent. Only need to run this when 
	//          specific animation set is updated
	
	calculate_jumpLaunchArrivalMaxMoveDelta();
	calculate_stopSoonNotifyDist();
}

calculate_jumpLaunchArrivalMaxMoveDelta()
{
	iprintln( "level.alienAnimData.jumpLaunchArrival_maxMoveDelta = " + calculate_maxMoveDeltaInAnimState( "jump_launch_arrival" ) );
}

calculate_stopSoonNotifyDist()
{	
	iprintln( "level.alienAnimData.stopSoon_NotifyDist = " + calculate_maxMoveDeltaInAnimState( "run_stop" ) );
}

calculate_maxMoveDeltaInAnimState( animState )
{
	maxMoveDeltaSq = 0;
	animCount = self GetAnimEntryCount( animState );
		
	for ( i = 0; i < animCount; i++ )
	{
		animEntry = self GetAnimEntry( animState, i );
		moveDelta = GetMoveDelta( animEntry, 0, 1 );

		deltaDistSq = LengthSquared( moveDelta );
		if ( deltaDistSq > maxMoveDeltaSq )
			maxMoveDeltaSq = deltaDistSq;
	}
	
	return sqrt( maxMoveDeltaSq );
}

initAlienCannedTraverses( alienAnimData )
{
	alienAnimData.cannedTraverseAnims = [];
	
	// Canned traversals
	// Group 1 --- Each group can hold 32 animations
	alienAnimData.cannedTraverseAnims[ "alien_crawl_door" ] 					  = registerTraverseData( "traverse_group_1", 0 );
	alienAnimData.cannedTraverseAnims[ "alien_jump_sidewall_l" ] 				  = registerTraverseData( "traverse_group_1", 1 );
	alienAnimData.cannedTraverseAnims[ "alien_jump_sidewall_r" ] 				  = registerTraverseData( "traverse_group_1", 2 );
	alienAnimData.cannedTraverseAnims[ "alien_leap_clear_height_54" ] 			  = registerTraverseData( "traverse_group_1", 3 );
	alienAnimData.cannedTraverseAnims[ "alien_drone_traverse_corner_wall_crawl" ] = registerTraverseData( "traverse_group_1", 4 );
	alienAnimData.cannedTraverseAnims[ "alien_mantle_36" ] 						  = registerTraverseData( "traverse_group_1", 5 );
	alienAnimData.cannedTraverseAnims[ "alien_leap_clear_height_36" ] 			  = registerTraverseData( "traverse_group_1", 6 );
	alienAnimData.cannedTraverseAnims[ "alien_drone_traverse_climb_vault_8" ] 	  = registerTraverseData( "traverse_group_1", 7 );
	alienAnimData.cannedTraverseAnims[ "climb_up_light_signal" ] 				  = registerTraverseData( "traverse_group_1", 8 );
	alienAnimData.cannedTraverseAnims[ "alien_leap_tree" ] 						  = registerTraverseData( "traverse_group_1", 9 );
	alienAnimData.cannedTraverseAnims[ "alien_drone_traverse_climb_over_fence" ]  = registerTraverseData( "traverse_group_1", 10 );
	alienAnimData.cannedTraverseAnims[ "alien_crawl_under_car" ] 				  = registerTraverseData( "traverse_group_1", 11 );
	alienAnimData.cannedTraverseAnims[ "alien_crawl_on_car" ] 					  = registerTraverseData( "traverse_group_1", 12 );
	alienAnimData.cannedTraverseAnims[ "alien_crawl_off_car" ] 					  = registerTraverseData( "traverse_group_1", 13 );
	alienAnimData.cannedTraverseAnims[ "alien_step_up_56" ] 					  = registerTraverseData( "traverse_group_1", 14 );
	alienAnimData.cannedTraverseAnims[ "alien_step_down_56" ] 					  = registerTraverseData( "traverse_group_1", 15 );
	alienAnimData.cannedTraverseAnims[ "alien_crawl_deadtree" ] 				  = registerTraverseData( "traverse_group_1", 16 );
	alienAnimData.cannedTraverseAnims[ "alien_crawl_rail_vault_lodge" ] 		  = registerTraverseData( "traverse_group_1", 17 );
	alienAnimData.cannedTraverseAnims[ "alien_jump_rail_lodge" ] 				  = registerTraverseData( "traverse_group_1", 18 );
	alienAnimData.cannedTraverseAnims[ "alien_roof_to_ceiling" ] 				  = registerTraverseData( "traverse_group_1", 19 );
	alienAnimData.cannedTraverseAnims[ "alien_climb_over_fence_88" ] 			  = registerTraverseData( "traverse_group_1", 20 );
	alienAnimData.cannedTraverseAnims[ "alien_jump_down_100" ] 					  = registerTraverseData( "traverse_group_1", 21 );	
	alienAnimData.cannedTraverseAnims[ "alien_jump_down_500" ] 					  = registerTraverseData( "traverse_group_1", 22 );	
	alienAnimData.cannedTraverseAnims[ "alien_jump_up_70" ] 					  = registerTraverseData( "traverse_group_1", 23 );	
	alienAnimData.cannedTraverseAnims[ "alien_jump_up_200" ] 					  = registerTraverseData( "traverse_group_1", 24 );	
	alienAnimData.cannedTraverseAnims[ "alien_crawl_back_humvee" ] 				  = registerTraverseData( "traverse_group_1", 25 );	
	alienAnimData.cannedTraverseAnims[ "alien_crawl_car" ] 						  = registerTraverseData( "traverse_group_1", 26 );	
	alienAnimData.cannedTraverseAnims[ "alien_crawl_humvee" ] 					  = registerTraverseData( "traverse_group_1", 27 );	
	alienAnimData.cannedTraverseAnims[ "alien_crawl_sidecar" ] 					  = registerTraverseData( "traverse_group_1", 28 );
	alienAnimData.cannedTraverseAnims[ "alien_crawl_sidehumvee" ] 				  = registerTraverseData( "traverse_group_1", 29 );
	alienAnimData.cannedTraverseAnims[ "alien_under_fence" ] 					  = registerTraverseData( "traverse_group_1", 30 );
	alienAnimData.cannedTraverseAnims[ "alien_climb_up_spiral_tree" ] 			  = registerTraverseData( "traverse_group_1", 31 );
	
	// Group 2 --- Each group can hold 32 animations
	alienAnimData.cannedTraverseAnims[ "alien_climb_fence_up_172" ] 			  = registerTraverseData( "traverse_group_2", 0 );
	alienAnimData.cannedTraverseAnims[ "alien_climb_fence_down_88" ] 			  = registerTraverseData( "traverse_group_2", 1 );
	alienAnimData.cannedTraverseAnims[ "alien_climb_fence_up_88" ] 			  	  = registerTraverseData( "traverse_group_2", 2 );
	alienAnimData.cannedTraverseAnims[ "alien_climb_fence_down_172" ] 			  = registerTraverseData( "traverse_group_2", 3 );
	alienAnimData.cannedTraverseAnims[ "alien_climb_up_gutter_L" ] 			  	  = registerTraverseData( "traverse_group_2", 4 );
	alienAnimData.cannedTraverseAnims[ "alien_climb_up_gutter_R" ] 			  	  = registerTraverseData( "traverse_group_2", 5 );
	alienAnimData.cannedTraverseAnims[ "alien_jump_down_straight" ] 			  = registerTraverseData( "traverse_group_2", 6 );
	alienAnimData.cannedTraverseAnims[ "alien_roof_to_ground" ] 			  	  = registerTraverseData( "traverse_group_2", 7 );
	alienAnimData.cannedTraverseAnims[ "alien_jump_fence_high_to_low" ] 		  = registerTraverseData( "traverse_group_2", 8 );
	alienAnimData.cannedTraverseAnims[ "alien_jump_fence_low_to_high" ] 		  = registerTraverseData( "traverse_group_2", 9 );
	
	// Special traversals
	alienAnimData.cannedTraverseAnims[ "alien_climb_up" ] 						  = registerTraverseData( "traverse_climb_up" );
	alienAnimData.cannedTraverseAnims[ "alien_climb_down" ] 					  = registerTraverseData( "traverse_climb_down" );
	alienAnimData.cannedTraverseAnims[ "alien_climb_up_over_56" ] 				  = registerTraverseData( "traverse_climb_up_over_56" );
	alienAnimData.cannedTraverseAnims[ "alien_climb_over_56_down" ] 			  = registerTraverseData( "traverse_climb_over_56_down" );
	alienAnimData.cannedTraverseAnims[ "climb_up_end_jump_side_l" ] 			  = registerTraverseData( "climb_up_end_jump_side_l" );
	alienAnimData.cannedTraverseAnims[ "climb_up_end_jump_side_r" ] 			  = registerTraverseData( "climb_up_end_jump_side_r" );
	alienAnimData.cannedTraverseAnims[ "alien_climb_up_ledge_18_run" ] 			  = registerTraverseData( "traverse_climb_up_ledge_18_run" );
	alienAnimData.cannedTraverseAnims[ "alien_climb_up_ledge_18_idle" ] 		  = registerTraverseData( "traverse_climb_up_ledge_18_idle" );
}

initAlienJumpTraverses( alienAnimData )
{
	level.alienAnimData.jumpGravity = 20.0 / 0.02205; // cScrAgent_JumpGravity
	
	level.alienAnimData.jumpLaunchGroundDelta = 16.8476;
	level.alienAnimData.jumpLaunchInAirAnimLength = 0.111111;
	
	level.alienAnimData.jumpLaunchDirection = [];
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_up" ] 		= [];
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_level" ]	= [];
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_down" ]	= [];

	level.alienAnimData.jumpLaunchDirection[ "jump_launch_up" ][0]		= (0.338726, 0, 0.940885);
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_up" ][1]		= (0.688542, 0, 0.725196);
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_up" ][2]		= (0.906517, 0, 0.422169);

	level.alienAnimData.jumpLaunchDirection[ "jump_launch_level" ][0]	= (0.248516, 0, 0.968628);
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_level" ][1]	= (0.579155, 0, 0.815218);
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_level" ][2]	= (0.906514, 0, 0.422177);

	level.alienAnimData.jumpLaunchDirection[ "jump_launch_down" ][0] 	= (0.333125, 0, 0.942883);
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_down" ][1] 	= (0.518112, 0, 0.855313);
	level.alienAnimData.jumpLaunchDirection[ "jump_launch_down" ][2] 	= (0.892489, 0, 0.451068);
		
	level.alienAnimData.inAirAnimEntry = [];
	level.alienAnimData.inAirAnimEntry[ "jump_launch_up" ] = [];
	level.alienAnimData.inAirAnimEntry[ "jump_launch_level" ] = [];
	level.alienAnimData.inAirAnimEntry[ "jump_launch_down" ] = [];
	
	level.alienAnimData.inAirAnimEntry[ "jump_launch_up" ][ "jump_land_up" ] 			= 0;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_up" ][ "jump_land_level" ] 		= 1;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_up" ][ "jump_land_down" ] 		= 2;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_level" ][ "jump_land_up" ] 		= 3;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_level" ][ "jump_land_level" ] 	= 4;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_level" ][ "jump_land_down" ] 	= 5;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_down" ][ "jump_land_up" ] 		= 6;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_down" ][ "jump_land_level" ] 	= 7;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_down" ][ "jump_land_down" ] 		= 8;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_up" ][ "jump_land_sidewall_high" ]		= 9;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_level" ][ "jump_land_sidewall_high" ]	= 9;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_down" ][ "jump_land_sidewall_high" ]	= 9;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_up" ][ "jump_land_sidewall_low" ]		= 9;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_level" ][ "jump_land_sidewall_low" ]	= 9;
	level.alienAnimData.inAirAnimEntry[ "jump_launch_down" ][ "jump_land_sidewall_low" ]	= 9;
}

initAlienPain( alienAnimData )
{
	alienAnimData.painAnims = [];
	
	//Idle, anim states are: idle_pain_light, idle_pain_heavy
	idlePainAnims = [];
	idlePainAnims [ "front" ][ "head" ] 	  = [ 0 ];
	idlePainAnims [ "front" ][ "up_chest" ]   = [ 1 ];
	idlePainAnims [ "front" ][ "low_chest" ]  = [ 1 ];
	idlePainAnims [ "front" ][ "up_body_L" ]  = [ 1 ];
	idlePainAnims [ "front" ][ "up_body_R" ]  = [ 2 ];
	idlePainAnims [ "front" ][ "low_body_L" ] = [ 2 ];
	idlePainAnims [ "front" ][ "low_body_R" ] = [ 2 ];
	idlePainAnims [ "right" ][ "head" ] 	  = [ 0 ];
	idlePainAnims [ "right" ][ "up_chest" ]   = [ 3 ];
	idlePainAnims [ "right" ][ "low_chest" ]  = [ 3 ];
	idlePainAnims [ "right" ][ "up_body_L" ]  = [ 3 ];
	idlePainAnims [ "right" ][ "up_body_R" ]  = [ 2 ];
	idlePainAnims [ "right" ][ "low_body_L" ] = [ 2 ];
	idlePainAnims [ "right" ][ "low_body_R" ] = [ 2 ];
	idlePainAnims [ "left" ][ "head" ] 		  = [ 0 ];
	idlePainAnims [ "left" ][ "up_chest" ]    = [ 1 ];
	idlePainAnims [ "left" ][ "low_chest" ]   = [ 1 ];
	idlePainAnims [ "left" ][ "up_body_L" ]   = [ 1 ];
	idlePainAnims [ "left" ][ "up_body_R" ]   = [ 2 ];
	idlePainAnims [ "left" ][ "low_body_L" ]  = [ 2 ];
	idlePainAnims [ "left" ][ "low_body_R" ]  = [ 2 ];
	idlePainAnims [ "back" ][ "head" ] 		  = [ 0 ];
	idlePainAnims [ "back" ][ "up_chest" ]    = [ 1 ];
	idlePainAnims [ "back" ][ "low_chest" ]   = [ 1 ];
	idlePainAnims [ "back" ][ "up_body_L" ]   = [ 1 ];
	idlePainAnims [ "back" ][ "up_body_R" ]   = [ 2 ];
	idlePainAnims [ "back" ][ "low_body_L" ]  = [ 2 ];
	idlePainAnims [ "back" ][ "low_body_R" ]  = [ 2 ];
	alienAnimData.painAnims[ "idle" ] = idlePainAnims;
	
	//Run, anim states are: run_stumble_light, run_stumble_heavy
	/*
	0  alien_drone_run_pain_upbody_f_light
	1  alien_drone_run_pain_upbody_f_medium
	2  alien_drone_run_pain_upbody_v2_f_medium
	3  alien_drone_run_pain_Lshoulder_f_heavy
	4  alien_drone_run_pain_Rshoulder_f_heavy
	5  alien_drone_run_pain_Lupbody_l_light
	6  alien_drone_run_pain_Llowbody_l_light
	7  alien_drone_run_pain_Rupbody_r_light
	8  alien_drone_run_pain_Lupbody_f_light
	9  alien_drone_run_pain_Rupbody_f_light
	10 alien_drone_run_pain_lowbody_f_light
	11 alien_drone_run_pain_Rlowbody_r_light
	12 alien_drone_run_pain_upbody_b_light
	13 alien_drone_run_pain_lowbody_b_light
	*/
	runPainAnims = [];
	runPainAnims [ "front" ][ "head" ] 	  	 = [ 0 ];
	runPainAnims [ "front" ][ "up_chest" ]   = [ 9 ];
	runPainAnims [ "front" ][ "low_chest" ]  = [ 8 ];
	runPainAnims [ "front" ][ "up_body_L" ]  = [ 8 ];
	runPainAnims [ "front" ][ "up_body_R" ]  = [ 9 ];
	runPainAnims [ "front" ][ "low_body_L" ] = [ 10 ];
	runPainAnims [ "front" ][ "low_body_R" ] = [ 10 ];
	runPainAnims [ "right" ][ "head" ] 	 	 = [ 7 ];
	runPainAnims [ "right" ][ "up_chest" ]   = [ 7 ];
	runPainAnims [ "right" ][ "low_chest" ]  = [ 11 ];
	runPainAnims [ "right" ][ "up_body_L" ]  = [ 7 ];
	runPainAnims [ "right" ][ "up_body_R" ]  = [ 7 ];
	runPainAnims [ "right" ][ "low_body_L" ] = [ 11 ];
	runPainAnims [ "right" ][ "low_body_R" ] = [ 11 ];
	runPainAnims [ "left" ][ "head" ] 		 = [ 5 ];
	runPainAnims [ "left" ][ "up_chest" ]    = [ 5 ];
	runPainAnims [ "left" ][ "low_chest" ]   = [ 6 ];
	runPainAnims [ "left" ][ "up_body_L" ]   = [ 5 ];
	runPainAnims [ "left" ][ "up_body_R" ]   = [ 5 ];
	runPainAnims [ "left" ][ "low_body_L" ]  = [ 6 ];
	runPainAnims [ "left" ][ "low_body_R" ]  = [ 6 ];
	runPainAnims [ "back" ][ "head" ] 		 = [ 12 ];
	runPainAnims [ "back" ][ "up_chest" ]    = [ 12 ];
	runPainAnims [ "back" ][ "low_chest" ]   = [ 13 ];
	runPainAnims [ "back" ][ "up_body_L" ]   = [ 12 ];
	runPainAnims [ "back" ][ "up_body_R" ]   = [ 12 ];
	runPainAnims [ "back" ][ "low_body_L" ]  = [ 13 ];
	runPainAnims [ "back" ][ "low_body_R" ]  = [ 13 ];
	alienAnimData.painAnims[ "run" ] = runPainAnims;
	
	//Jump, anim states are: jump_pain_light, jump_pain_heavy
	jumpPainAnims = [];
	jumpPainAnims [ "front" ][ "head" ] 	  = [ 0 ];
	jumpPainAnims [ "front" ][ "up_chest" ]   = [ 1 ];
	jumpPainAnims [ "front" ][ "low_chest" ]  = [ 1 ];
	jumpPainAnims [ "front" ][ "up_body_L" ]  = [ 2 ];
	jumpPainAnims [ "front" ][ "up_body_R" ]  = [ 3 ];
	jumpPainAnims [ "front" ][ "low_body_L" ] = [ 4 ];
	jumpPainAnims [ "front" ][ "low_body_R" ] = [ 4 ];
	jumpPainAnims [ "right" ][ "head" ] 	  = [ 7 ];
	jumpPainAnims [ "right" ][ "up_chest" ]   = [ 7 ];
	jumpPainAnims [ "right" ][ "low_chest" ]  = [ 8 ];
	jumpPainAnims [ "right" ][ "up_body_L" ]  = [ 7 ];
	jumpPainAnims [ "right" ][ "up_body_R" ]  = [ 7 ];
	jumpPainAnims [ "right" ][ "low_body_L" ] = [ 8 ];
	jumpPainAnims [ "right" ][ "low_body_R" ] = [ 8 ];
	jumpPainAnims [ "left" ][ "head" ] 		  = [ 5 ];
	jumpPainAnims [ "left" ][ "up_chest" ]    = [ 5 ];
	jumpPainAnims [ "left" ][ "low_chest" ]   = [ 6 ];
	jumpPainAnims [ "left" ][ "up_body_L" ]   = [ 5 ];
	jumpPainAnims [ "left" ][ "up_body_R" ]   = [ 5 ];
	jumpPainAnims [ "left" ][ "low_body_L" ]  = [ 6 ];
	jumpPainAnims [ "left" ][ "low_body_R" ]  = [ 6 ];
	jumpPainAnims [ "back" ][ "head" ] 		  = [ 9 ];
	jumpPainAnims [ "back" ][ "up_chest" ]    = [ 9 ];
	jumpPainAnims [ "back" ][ "low_chest" ]   = [ 10 ];
	jumpPainAnims [ "back" ][ "up_body_L" ]   = [ 9 ];
	jumpPainAnims [ "back" ][ "up_body_R" ]   = [ 9 ];
	jumpPainAnims [ "back" ][ "low_body_L" ]  = [ 10 ];
	jumpPainAnims [ "back" ][ "low_body_R" ]  = [ 10 ];
	alienAnimData.painAnims[ "jump" ] = jumpPainAnims;
	
	combinedHitLoc = [];
	combinedHitLoc [ "head" ] = "head";
	combinedHitLoc [ "neck" ] = "head";
	combinedHitLoc [ "torso_upper" ] = "up_chest";
	combinedHitLoc [ "none" ] = "up_chest";
	combinedHitLoc [ "torso_lower" ] = "low_chest";
	combinedHitLoc [ "left_arm_upper" ] = "up_body_L";
	combinedHitLoc [ "left_arm_lower" ] = "up_body_L";
	combinedHitLoc [ "left_hand" ] = "up_body_L";
	combinedHitLoc [ "right_arm_upper" ] = "up_body_R";
	combinedHitLoc [ "right_arm_lower" ] = "up_body_R";
	combinedHitLoc [ "right_hand" ] = "up_body_R";
	combinedHitLoc [ "left_leg_upper" ] = "low_body_L";
	combinedHitLoc [ "left_leg_lower" ] = "low_body_L";
	combinedHitLoc [ "left_foot" ] = "low_body_L";
	combinedHitLoc [ "right_leg_upper" ] = "low_body_R";
	combinedHitLoc [ "right_leg_lower" ] = "low_body_R";
	combinedHitLoc [ "right_foot" ] = "low_body_R";
	alienAnimData.painAnims[ "hitLoc" ] = combinedHitLoc;
	
	hitDirection = [];
	hitDirection[ 0 ] = "back";
	hitDirection[ 1 ] = "back";
	hitDirection[ 2 ] = "right";
	hitDirection[ 3 ] = "right";
	hitDirection[ 4 ] = "front";
	hitDirection[ 5 ] = "left";
	hitDirection[ 6 ] = "left"; 
	hitDirection[ 7 ] = "back";
	hitDirection[ 8 ] = "back";
	alienAnimData.painAnims[ "hitDirection" ] = hitDirection;
	
	jumpPainIdleToImpactMap = [];
	//                 *idle index   *Impact index
	jumpPainIdleToImpactMap[ 0 ] = [ 0 ];
	jumpPainIdleToImpactMap[ 1 ] = [ 1 ];
	jumpPainIdleToImpactMap[ 2 ] = [ 2 ];
	jumpPainIdleToImpactMap[ 3 ] = [ 3 ];
	jumpPainIdleToImpactMap[ 4 ] = [ 4 ];
	jumpPainIdleToImpactMap[ 5 ] = [ 5 ];
	jumpPainIdleToImpactMap[ 6 ] = [ 6 ];
	jumpPainIdleToImpactMap[ 7 ] = [ 7 ];
	jumpPainIdleToImpactMap[ 8 ] = [ 8 ];
	jumpPainIdleToImpactMap[ 9 ] = [ 9 ];
	jumpPainIdleToImpactMap[ 10 ] = [ 10 ];
	alienAnimData.painAnims[ "idleToImpactMap" ] = jumpPainIdleToImpactMap;
}

initAlienDeath( alienAnimData )
{
	alienAnimData.deathAnims = [];
	
	//Idle, anim states are: idle_death_light, idle_death_heavy
	idleDeathAnims = [];
	idleDeathAnims [ "front" ][ "head" ] 	   = [ 0 ];
	idleDeathAnims [ "front" ][ "up_chest" ]   = [ 1 ];
	idleDeathAnims [ "front" ][ "low_chest" ]  = [ 1 ];
	idleDeathAnims [ "front" ][ "up_body_L" ]  = [ 1 ];
	idleDeathAnims [ "front" ][ "up_body_R" ]  = [ 2 ];
	idleDeathAnims [ "front" ][ "low_body_L" ] = [ 2 ];
	idleDeathAnims [ "front" ][ "low_body_R" ] = [ 2 ];
	idleDeathAnims [ "right" ][ "head" ] 	   = [ 0 ];
	idleDeathAnims [ "right" ][ "up_chest" ]   = [ 3 ];
	idleDeathAnims [ "right" ][ "low_chest" ]  = [ 3 ];
	idleDeathAnims [ "right" ][ "up_body_L" ]  = [ 3 ];
	idleDeathAnims [ "right" ][ "up_body_R" ]  = [ 2 ];
	idleDeathAnims [ "right" ][ "low_body_L" ] = [ 2 ];
	idleDeathAnims [ "right" ][ "low_body_R" ] = [ 2 ];
	idleDeathAnims [ "left" ][ "head" ] 	   = [ 0 ];
	idleDeathAnims [ "left" ][ "up_chest" ]    = [ 1 ];
	idleDeathAnims [ "left" ][ "low_chest" ]   = [ 1 ];
	idleDeathAnims [ "left" ][ "up_body_L" ]   = [ 1 ];
	idleDeathAnims [ "left" ][ "up_body_R" ]   = [ 2 ];
	idleDeathAnims [ "left" ][ "low_body_L" ]  = [ 2 ];
	idleDeathAnims [ "left" ][ "low_body_R" ]  = [ 2 ];
	idleDeathAnims [ "back" ][ "head" ] 	   = [ 0 ];
	idleDeathAnims [ "back" ][ "up_chest" ]    = [ 1 ];
	idleDeathAnims [ "back" ][ "low_chest" ]   = [ 1 ];
	idleDeathAnims [ "back" ][ "up_body_L" ]   = [ 1 ];
	idleDeathAnims [ "back" ][ "up_body_R" ]   = [ 2 ];
	idleDeathAnims [ "back" ][ "low_body_L" ]  = [ 2 ];
	idleDeathAnims [ "back" ][ "low_body_R" ]  = [ 2 ];
	alienAnimData.deathAnims[ "idle" ] = idleDeathAnims;
	
	//Run, anim states are: run_death_light, run_death_heavy
	runDeathAnims = [];
	runDeathAnims [ "front" ][ "head" ] 	  = [ 0 ];
	runDeathAnims [ "front" ][ "up_chest" ]   = [ 1 ];
	runDeathAnims [ "front" ][ "low_chest" ]  = [ 3 ];
	runDeathAnims [ "front" ][ "up_body_L" ]  = [ 4 ];
	runDeathAnims [ "front" ][ "up_body_R" ]  = [ 5 ];
	runDeathAnims [ "front" ][ "low_body_L" ] = [ 4 ];
	runDeathAnims [ "front" ][ "low_body_R" ] = [ 3 ];
	runDeathAnims [ "right" ][ "head" ] 	  = [ 2 ];
	runDeathAnims [ "right" ][ "up_chest" ]   = [ 1 ];
	runDeathAnims [ "right" ][ "low_chest" ]  = [ 0 ];
	runDeathAnims [ "right" ][ "up_body_L" ]  = [ 1 ];
	runDeathAnims [ "right" ][ "up_body_R" ]  = [ 2 ];
	runDeathAnims [ "right" ][ "low_body_L" ] = [ 3 ];
	runDeathAnims [ "right" ][ "low_body_R" ] = [ 4 ];
	runDeathAnims [ "left" ][ "head" ] 		  = [ 5 ];
	runDeathAnims [ "left" ][ "up_chest" ]    = [ 5 ];
	runDeathAnims [ "left" ][ "low_chest" ]   = [ 6 ];
	runDeathAnims [ "left" ][ "up_body_L" ]   = [ 5 ];
	runDeathAnims [ "left" ][ "up_body_R" ]   = [ 5 ];
	runDeathAnims [ "left" ][ "low_body_L" ]  = [ 6 ];
	runDeathAnims [ "left" ][ "low_body_R" ]  = [ 6 ];
	runDeathAnims [ "back" ][ "head" ] 		  = [ 1 ];
	runDeathAnims [ "back" ][ "up_chest" ]    = [ 5 ];
	runDeathAnims [ "back" ][ "low_chest" ]   = [ 4 ];
	runDeathAnims [ "back" ][ "up_body_L" ]   = [ 3 ];
	runDeathAnims [ "back" ][ "up_body_R" ]   = [ 2 ];
	runDeathAnims [ "back" ][ "low_body_L" ]  = [ 1 ];
	runDeathAnims [ "back" ][ "low_body_R" ]  = [ 4 ];
	alienAnimData.deathAnims[ "run" ] = runDeathAnims;
	
	//Jump, anim states are: jump_death_light, jump_death_heavy
	jumpDeathAnims = [];
	jumpDeathAnims [ "front" ][ "head" ] 	   = [ 1 ];
	jumpDeathAnims [ "front" ][ "up_chest" ]   = [ 0 ];
	jumpDeathAnims [ "front" ][ "low_chest" ]  = [ 0 ];
	jumpDeathAnims [ "front" ][ "up_body_L" ]  = [ 2 ];
	jumpDeathAnims [ "front" ][ "up_body_R" ]  = [ 3 ];
	jumpDeathAnims [ "front" ][ "low_body_L" ] = [ 4 ];
	jumpDeathAnims [ "front" ][ "low_body_R" ] = [ 4 ];
	jumpDeathAnims [ "right" ][ "head" ] 	   = [ 7 ];
	jumpDeathAnims [ "right" ][ "up_chest" ]   = [ 7 ];
	jumpDeathAnims [ "right" ][ "low_chest" ]  = [ 8 ];
	jumpDeathAnims [ "right" ][ "up_body_L" ]  = [ 7 ];
	jumpDeathAnims [ "right" ][ "up_body_R" ]  = [ 7 ];
	jumpDeathAnims [ "right" ][ "low_body_L" ] = [ 8 ];
	jumpDeathAnims [ "right" ][ "low_body_R" ] = [ 8 ];
	jumpDeathAnims [ "left" ][ "head" ] 	   = [ 5 ];
	jumpDeathAnims [ "left" ][ "up_chest" ]    = [ 5 ];
	jumpDeathAnims [ "left" ][ "low_chest" ]   = [ 6 ];
	jumpDeathAnims [ "left" ][ "up_body_L" ]   = [ 5 ];
	jumpDeathAnims [ "left" ][ "up_body_R" ]   = [ 5 ];
	jumpDeathAnims [ "left" ][ "low_body_L" ]  = [ 6 ];
	jumpDeathAnims [ "left" ][ "low_body_R" ]  = [ 6 ];
	jumpDeathAnims [ "back" ][ "head" ] 	   = [ 9 ];
	jumpDeathAnims [ "back" ][ "up_chest" ]    = [ 9 ];
	jumpDeathAnims [ "back" ][ "low_chest" ]   = [ 10 ];
	jumpDeathAnims [ "back" ][ "up_body_L" ]   = [ 9 ];
	jumpDeathAnims [ "back" ][ "up_body_R" ]   = [ 9 ];
	jumpDeathAnims [ "back" ][ "low_body_L" ]  = [ 10 ];
	jumpDeathAnims [ "back" ][ "low_body_R" ]  = [ 10 ];
	alienAnimData.deathAnims[ "jump" ] = jumpDeathAnims;
	
	combinedHitLoc = [];
	combinedHitLoc [ "head" ] = "head";
	combinedHitLoc [ "neck" ] = "head";
	combinedHitLoc [ "torso_upper" ] = "up_chest";
	combinedHitLoc [ "none" ] = "up_chest";
	combinedHitLoc [ "torso_lower" ] = "low_chest";
	combinedHitLoc [ "left_arm_upper" ] = "up_body_L";
	combinedHitLoc [ "left_arm_lower" ] = "up_body_L";
	combinedHitLoc [ "left_hand" ] = "up_body_L";
	combinedHitLoc [ "right_arm_upper" ] = "up_body_R";
	combinedHitLoc [ "right_arm_lower" ] = "up_body_R";
	combinedHitLoc [ "right_hand" ] = "up_body_R";
	combinedHitLoc [ "left_leg_upper" ] = "low_body_L";
	combinedHitLoc [ "left_leg_lower" ] = "low_body_L";
	combinedHitLoc [ "left_foot" ] = "low_body_L";
	combinedHitLoc [ "right_leg_upper" ] = "low_body_R";
	combinedHitLoc [ "right_leg_lower" ] = "low_body_R";
	combinedHitLoc [ "right_foot" ] = "low_body_R";
	alienAnimData.deathAnims[ "hitLoc" ] = combinedHitLoc;
	
	hitDirection = [];
	hitDirection[ 0 ] = "back";
	hitDirection[ 1 ] = "back";
	hitDirection[ 2 ] = "right";
	hitDirection[ 3 ] = "right";
	hitDirection[ 4 ] = "front";
	hitDirection[ 5 ] = "left";
	hitDirection[ 6 ] = "left"; 
	hitDirection[ 7 ] = "back";
	hitDirection[ 8 ] = "back";
	alienAnimData.deathAnims[ "hitDirection" ] = hitDirection;
	
	//Special death
	specialDeathAnims = [];
	specialDeathAnims [ "electric_shock_death" ] = [ 0 ];
	alienAnimData.deathAnims[ "special" ] =	specialDeathAnims;
}

initMoveBackAnims()
{
	level.alienAnimData.alienMoveBackAnimChance[ 0 ] = 40;
	level.alienAnimData.alienMoveBackAnimChance[ 1 ] = 40;
	level.alienAnimData.alienMoveBackAnimChance[ 2 ] = 20;
}

registerTraverseData( animState, animIndex, traverseSound, traverseAnimRate )
{
	assertEx( isDefined( animState));
	
	traverseData = [];
	traverseData [ "animState" ] = animState;
	
	if ( isDefined ( animIndex ) )
		traverseData [ "animIndex" ] = animIndex;
	
	if ( isDefined ( traverseSound ) )
		traverseData [ "traverseSound" ] = traverseSound;
	
	if ( isDefined ( traverseAnimRate ) )
		traverseData [ "traverseAnimRate" ] = traverseAnimRate;
	
	return traverseData;
}

turnTowardsEntity( entity )
{
	targetVector = entity.origin - self.origin;
	return turnTowardsVector( targetVector );
}

turnTowardsVector( targetVector )
{
	turnIndex = getTurnInPlaceIndex( AnglesToForward( self.angles ), targetVector, AnglesToUp( self.angles ) );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	if ( turnIndex != 4 )
	{
		self.stateLocked = true;
		self ScrAgentSetAnimMode( "anim deltas" );
		self PlayAnimNUntilNotetrack( "turn_in_place", turnIndex, "turn_in_place", "code_move" );
		self.stateLocked = false;
		return true;
	}
	return false;
}

getTurnInPlaceIndex ( inVector, outVector, surfaceNormal )
{
	turnAnim = undefined;
	index = undefined;
	
	projData = getProjectionData( inVector, outVector, surfaceNormal );
	rotatedYaw = projData.rotatedYaw;
	projInToOutRight = projData.projInToOutRight;

	// favor underturning, unless you're within <threshold> degrees of the next one up.
	threshold = 10; 
	
	if ( projInToOutRight > 0 )  //Entering from the right
	{
		index = int( ceil( ( 180 - rotatedYaw - threshold ) / 45 ) );
	}
	else //Entering from the left
	{
		index = int( floor( ( 180 + rotatedYaw + threshold ) / 45 ) );
	}
	index = int( clamp( index, 0, 8 ));  //the threshold in getTurnInPlaceIndex might cause the index to be out of range
	return index;
}

getProjectionData( inVector, outVector, surfaceNormal )
{
	projectionData = SpawnStruct();
	
	inVectorNoNormal = vectorNormalize( projectVectorToPlane( inVector, surfaceNormal));
	outVectorNoNormal = vectorNormalize( projectVectorToPlane( outVector, surfaceNormal ));
	
	outVectorRight = VectorCross ( outVectorNoNormal, surfaceNormal );
	outVectorRightNoNormal = VectorNormalize ( projectVectorToPlane( outVectorRight, surfaceNormal ) );	
	projInToOutRight = VectorDot ( inVectorNoNormal * -1, outVectorRightNoNormal );

	ratio = vectorDot( outVectorNoNormal, inVectorNoNormal );
	
	// Need to make sure the value is within the domain of Acos
	ratio = clamp( ratio, -1, 1 );
	
	rotatedYaw = Acos ( ratio );
	
	projectionData.rotatedYaw = rotatedYaw;
	projectionData.projInToOutRight = projInToOutRight;
	
	return projectionData;
}

projectVectorToPlane( vector, planeUp )
{
	dotResult = VectorDot( vector, planeUp );
	projVector = vector - ( planeUp * dotResult );
	return projVector;
}

pain_getCombinedHitLoc( hitLoc )
{
	return ( level.alienAnimData.painAnims[ "hitLoc" ][ hitLoc ] );
}

pain_getIncomingDirection( direction )
{
	directionIndex = maps\mp\agents\_scriptedagents::GetAngleIndexFromSelfYaw( direction );
	return ( level.alienAnimData.painAnims[ "hitDirection" ][ directionIndex ] );
}

death_getCombinedHitLoc( hitLoc )
{
	return ( level.alienAnimData.deathAnims[ "hitLoc" ][ hitLoc ] );
}

death_getIncomingDirection( direction )
{
	directionIndex = maps\mp\agents\_scriptedagents::GetAngleIndexFromSelfYaw( direction );
	return ( level.alienAnimData.deathAnims[ "hitDirection" ][ directionIndex ] );
}

getPainAnimState( state, iDamage )
{
	secondaryState = getDamageDegree( iDamage );
	return ( state + "_" + secondaryState );
}

getDamageDegree( iDamage )
{
	alienType = self maps\mp\alien\_utility::get_alien_type();
	damageThreshold = level.alien_types[ alienType ].attributes[ "heavy_damage_threshold" ];
	
	if ( iDamage < damageThreshold)
		return "light";
	else
		return "heavy";
}

getPainAnimIndex( state, damageDirection, hitLoc )
{
	damageDirection = pain_getIncomingDirection( damageDirection * -1 );
	hitLoc = pain_getCombinedHitLoc( hitLoc );
	return getPainDeathAnimIndex_Internal( state, damageDirection, hitLoc, level.alienAnimData.painAnims );
}

GetImpactPainAnimIndex( jump_pain_index )
{
	available_impact = level.alienAnimData.painAnims[ "idleToImpactMap" ][ jump_pain_index ];
	random_impact_index = randomIntRange( 0, available_impact.size );
	return available_impact [ random_impact_index ];
}

getDeathAnimState( state, iDamage )
{
	secondaryState = getDamageDegree( iDamage );
	return ( state + "_" + secondaryState );
}

getDeathAnimIndex( state, damageDirection, hitLoc )
{
	damageDirection = death_getIncomingDirection( damageDirection * -1 );
	hitLoc = death_getCombinedHitLoc( hitLoc );
	return getPainDeathAnimIndex_Internal( state, damageDirection, hitLoc, level.alienAnimData.deathAnims );
}

getPainDeathAnimIndex_Internal( state, damageDirection, hitLoc, animArray )
{
	availableIndexList = animArray[ state ][ damageDirection ][ hitLoc ];
	return ( availableIndexList[ randomInt ( availableIndexList.size ) ] );
}

getSpecialDeathAnimIndex( state )
{
	availableIndexList = level.alienAnimData.deathAnims[ "special" ][ state ];
	return ( availableIndexList[ randomInt ( availableIndexList.size ) ] );
}