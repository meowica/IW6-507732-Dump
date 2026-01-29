#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\cornered_code;

#using_animtree( "animated_props" );

cornered_start_rappel( rope_origin_targetname, ground_ref_targetname, rappel_params )
{
	rpl			= SpawnStruct();
	level.rpl	= rpl;
	
	cnd_plyr_rpl_move_setup( rpl, rope_origin_targetname, ground_ref_targetname, rappel_params );
	cnd_plyr_rpl_setup_globals( rpl, rappel_params, rope_origin_targetname );
	cnd_plyr_rpl_legs_setup( rpl, rappel_params );
	cnd_plyr_rpl_setup_dvars( rpl, rappel_params );
	cnd_plyr_rpl_setup_player( rpl, rappel_params );

	thread cnd_plyr_rpl_move( rpl, rope_origin_targetname, ground_ref_targetname, rappel_params );
}

cornered_stop_rappel()
{
	if ( IsDefined( level.rpl ) )
		flag_set( "stop_manage_player_rappel_movement" );
}

cnd_plyr_rpl_move( rpl, rope_origin_targetname, ground_ref_targetname, rappel_params )
{
	thread cnd_plyr_rpl_handle_jump( rappel_params, rpl );
		
	while ( !flag( "stop_manage_player_rappel_movement" ) )
	{
		cnd_rpl_calc_move( rpl, rappel_params );
		cnd_rpl_do_vertical_move( rpl, rappel_params );
		cnd_rpl_do_lateral_move( rpl, rappel_params );
		cnd_rpl_do_stop_sway( rpl, rappel_params );
		cnd_rpl_do_wind( rpl, rappel_params );
		cnd_rpl_do_rope( rpl, rappel_params );
		cnd_rpl_do_weapon_bob( rpl, rappel_params );
		cnd_rpl_do_move_bob( rpl, rappel_params );
		cnd_rpl_do_legs( rpl, rappel_params );
//		cnd_rpl_debug();
		
		wait( rpl.time_slice );
	}
	
	cnd_rpl_cleanup( rappel_params );
}

cornered_start_random_wind()
{
	if ( IsDefined( level.rpl ) )
		level.rpl.wind_random = true;
}

cornered_stop_random_wind()
{
	if ( IsDefined( level.rpl ) )
		level.rpl.wind_random = false;
}


// ****************************
// * Rappel Setup             *
// *********************************************************************************************************************************************************************

cnd_rpl_stealth_ckpt( rappel_params )
{
	if ( rappel_params.rappel_type != "stealth" )
		return;
	
	if ( !IsDefined( level.start_point ) || level.start_point != "rappel_stealth" )
		return;
	
	// If we are starting at the "rappel_stealth" checkpoint and this is the rappel_stealth section, 
	// then the initial angles should be the endpoint of the zipline animation (since the player starts on the wall)
	
	arms_and_legs[ 0 ] = level.cornered_player_arms;
	level.zipline_anim_struct thread anim_single( arms_and_legs, "cornered_zipline_player" );
	wait 0.1;
	level.zipline_anim_struct anim_set_time( arms_and_legs, "cornered_zipline_player", 1.0 );
	wait 0.1;
	
	level.player PlayerLinkToAbsolute( level.cornered_player_arms, "tag_player" );
	wait 0.1;
}

cnd_plyr_rpl_move_setup( rpl, rope_origin_targetname, ground_ref_targetname, rappel_params )
{
	// Description of entities involved in rappel
	// ----------------------------
	// *rope_origin* is a originally a script origin that was placed in radiant as the origin point for all the player rappel animations
	// In script we convert it into a tag_origin, so it can be used as the pivot point for all player movement.
	// Rotating or moving it will move the player around the side of the building
	//
	// *level.rpl_rope_anim_origin* is a script model spawned at rope_origin's location.  It uses different angles, to match the animations that can be played on it
	// Its purpose is to play specific animations on the rope.  For example, to make the player jump off the building (with 'A'),
	//  the animation %rappel_movement_player_jump_rotate is played on this entity
	// It has a physical representation in the world: level.rappel_player_rope, which is a model that is linked to it (in the same manner that we use any generic_prop_raven)
	// It needs to be attached to rope_origin, so that the "jump_away" anim works relative to the rope_origin, i.e. it works
	//	 regardless of where you are on the building (left, center, or right side)
	// It needs to be a part of the link chain so the player movement can be relative to the rope when we animate it for the "jump_away" / "jump_down" / etc.
	//
	// *level.rpl_jump_anim_origin* is a script model spawned at the player's location.  It uses different angles, to match the animations that can be played on it
	// Its purpose is to play jump animations on the player.  For example, to make the player jump down a level.
	// It needs to be attached to level.rpl_rope_anim_origin so that when the rope moves, the player can move relative to the rope
	// It needs to be a part of the link chain so that the player ground reference and location move along with it when it is animated around
	//
	// *level.rpl_plyr_anim_origin* is a script model spawned at the player's location.  It uses different angles, to match the animations that can be played on it
	// Its purpose is to play additive animations on the player, to move the player around on the building, and the legs are 'attached' to the tag origin.
	// It needs to be attached to level.rpl_jump_anim_origin so that when the player jumps this model's tag origin is translated as well.
	// It needs to be a part of the link chain so that the player ground reference and location move along with it when it is animated around
	//
	// *level.plyr_rpl_groundref* is a script origin that was placed in radiant, to use as the ground reference for the player
	// The location of this entity doesn't really matter (it gets teleported onto the player) but the angles determine the player's ground
	// It needs to be attached to level.rpl_plyr_anim_origin so that when the rope or the player animate, the ground reference moves with them
	// It needs to be a part of the link chain so the player's origin/angles and the ground ref's origin/angles stay in sync

	// The chain of entities goes like this: (<- = "is linked to")
	// rope_origin <- level.rpl_rope_anim_origin <- level.rpl_jump_anim_origin <- level.rpl_plyr_anim_origin <- level.plyr_rpl_groundref <- player
	
	cnd_rpl_stealth_ckpt( rappel_params );
	
	// We need to make sure there is no popping when we start the rappel movement. To achieve this, we spawn a tag origin at the player's location.
	// Then when we link the player to it, the view won't pop.
	player_origin_ent		 = level.player spawn_tag_origin();
	player_origin_ent.angles = level.player GetPlayerAngles();

	rope_origin_placed	= getstruct( rope_origin_targetname, "targetname" );
	rpl.rope_origin = rope_origin_placed spawn_tag_origin();
	if ( rappel_params.rappel_type == "stealth" )
		rpl.rope_origin.origin = rpl.rope_origin.origin + ( -16, 0, 0 ); // move the rotation point to line up with where the player lands on the building

	level.rpl_rope_anim_origin		= Spawn( "script_model", rpl.rope_origin.origin );
	level.rpl_rope_anim_origin.angles = rpl.rope_origin.angles + ( 0, -90, 0 );	// Needs to be offset for animations
	level.rpl_rope_anim_origin SetModel( "generic_prop_raven" );
	level.rpl_rope_anim_origin UseAnimTree(#animtree );
	level.rpl_rope_anim_origin LinkTo( rpl.rope_origin, "tag_origin" );
	
	level.rpl_physical_rope_origin = rope_origin_placed spawn_tag_origin();
	level.rpl_physical_rope_anim_origin	= Spawn( "script_model", rpl.rope_origin.origin );
	level.rpl_physical_rope_anim_origin.angles = rpl.rope_origin.angles + ( 0, -90, 0 );	// Needs to be offset for animations
	level.rpl_physical_rope_anim_origin SetModel( "generic_prop_raven" );
	level.rpl_physical_rope_anim_origin UseAnimTree(#animtree );
	level.rpl_physical_rope_anim_origin LinkTo( level.rpl_physical_rope_origin, "tag_origin" );
	
	// perpendicular to the wall
	anim_origin_angles = ( 0, 90, 0 ); // wall angle is ( 0, 0, 0 )
	if ( rappel_params.lateral_plane == 2 ) // approximate YZ plane
		anim_origin_angles = ( 0, 325, 0 ); // wall angle is ( 0, 235, 0 );
		
	level.rpl_jump_anim_origin		  = player_origin_ent spawn_tag_origin();
	level.rpl_jump_anim_origin.angles = anim_origin_angles;								// Needs to be offset for animations
	level.rpl_jump_anim_origin SetModel( "generic_prop_raven" );
	level.rpl_jump_anim_origin UseAnimTree(#animtree );
	level.rpl_jump_anim_origin LinkTo( level.rpl_rope_anim_origin, "J_prop_1" );
	
	level.rpl_plyr_anim_origin		  = player_origin_ent spawn_tag_origin();
	level.rpl_plyr_anim_origin.angles = anim_origin_angles;								// Needs to be offset for animations
	level.rpl_plyr_anim_origin SetModel( "generic_prop_raven" );
	level.rpl_plyr_anim_origin UseAnimTree(#animtree );
	level.rpl_plyr_anim_origin LinkTo( level.rpl_jump_anim_origin, "J_prop_1" );
	
	level.plyr_rpl_groundref		 = GetEnt( ground_ref_targetname, "targetname" );
	level.plyr_rpl_groundref.origin = player_origin_ent.origin;	// move on top of player so no popping
	if ( rappel_params.rappel_type == "inverted" )
		level.plyr_rpl_groundref.angles = ( 90, 270, 0 );
	level.plyr_rpl_groundref SetModel( "tag_origin" );
	level.player PlayerSetGroundReferenceEnt( level.plyr_rpl_groundref );
	level.plyr_rpl_groundref LinkTo( level.rpl_plyr_anim_origin, "J_prop_1" );
	level.player.dof_ref_ent = level.plyr_rpl_groundref;
	
	entity_player_link = level.plyr_rpl_groundref;
	
	// the ground reference ent tilts and moves the camera so it is not over the legs, this puts the player over the legs so 
	// you can't see the torso
	if ( rappel_use_plyr_legs( rappel_params ) )
	{
		wall_vector = AnglesToForward( anim_origin_angles );
		x_offset = wall_vector[0] * 30;
		y_offset = wall_vector[1] * 30;
		z_offset = 8;
		if ( rappel_params.rappel_type == "combat" )
		{
			x_offset = wall_vector[0] * 15;
			y_offset = wall_vector[1] * 15;
			z_offset = 5;
		}
		level.player_torso_offset_origin = level.plyr_rpl_groundref spawn_tag_origin();
		level.player_torso_offset_origin.origin += ( x_offset, y_offset, z_offset );
		level.player_torso_offset_origin LinkTo( level.plyr_rpl_groundref );
		entity_player_link = level.player_torso_offset_origin;
	}
    
	// If this is the inverted rappel, don't need to do any special linking - player is already in the right position / rotation
	if ( rappel_params.rappel_type == "combat" )
	{
		// Very hacky: spawn new ent on the player origin ent, and manipulate it to get the player in the right position and orientation
		player_force_origin_ent = player_origin_ent spawn_tag_origin();
		player_down_dir			= -1 * AnglesToUp( level.player GetPlayerAngles() );
		player_force_origin_ent.origin += ( player_down_dir * 60 );
		player_force_origin_ent.origin += ( 0, 0, 60 );
		
		level.player PlayerLinkToAbsolute( player_force_origin_ent, "tag_origin" );
	}
	
	wait( 0.1 );	// Wait two frames for the player to be linked to the entity
	if ( rappel_params.rappel_type == "inverted" )
		level.player PlayerLinkTo( entity_player_link, "tag_origin", 1, rappel_params.right_arc, rappel_params.left_arc, rappel_params.top_arc, rappel_params.bottom_arc, false );
	else
		level.player PlayerLinkToDelta( entity_player_link, "tag_origin", 1, rappel_params.right_arc, rappel_params.left_arc, rappel_params.top_arc, rappel_params.bottom_arc, true );
	level.player PlayerLinkedUseLinkedVelocity( true );
	
	cnd_rpl_rope_setup( rpl, rappel_params );
		
	if ( rappel_use_plyr_legs( rappel_params ) )
	{
		level.rappel_player_legs = spawn_anim_model( "player_rappel_legs" );
		level.rappel_player_legs.origin = level.rpl_plyr_anim_origin.origin;
		level.rappel_player_legs.angles = level.rpl_plyr_anim_origin.angles;
		
		level.rpl_plyr_legs_link_ent = level.rpl_plyr_anim_origin;
		
		if ( rappel_params.rappel_type == "stealth" )
		{
			wall_vector = AnglesToForward( anim_origin_angles );
			x_offset = wall_vector[0] * 15;
			y_offset = wall_vector[1] * 15;
			z_offset = -5;
			level.rpl_plyr_legs_link_ent = level.rpl_plyr_anim_origin spawn_tag_origin();
			level.rpl_plyr_legs_link_ent.origin += ( x_offset, y_offset, z_offset );
			level.rpl_plyr_legs_link_ent LinkTo( level.rpl_plyr_anim_origin );
		}
		
		level.rappel_player_legs DontCastShadows();
		level.rappel_player_legs LinkTo( level.rpl_plyr_legs_link_ent );
	}
}

cnd_rpl_rope_setup( rpl, rappel_params )
{
	// Link up physical rope model
	
	if ( rappel_params.rappel_type == "inverted" )
	{
//		level.rappel_player_rope LinkTo( level.rpl_rope_anim_origin, "J_prop_1" );		
//		return;
	}
	else // special ropes
	{
		
		if ( rappel_params.rappel_type == "stealth" )
		{
			rpl.player_rope_unwind_anim = %cnd_rappel_stealth_top_rope_unwind;
			rpl.player_rope_unwind_length = 990.8;
		}
		else if ( rappel_params.rappel_type == "combat" )
		{
			rpl.player_rope_unwind_anim = %cnd_rappel_combat_top_rope_unwind;
			rpl.player_rope_unwind_length = 1600.334;
		}
		
		level.cnd_rappel_tele_rope			= spawn_anim_model( "cnd_rappel_tele_rope" );
		level.cnd_rappel_tele_rope.origin 	= level.rpl_physical_rope_anim_origin.origin;
		level.cnd_rappel_tele_rope.angles	= ( 0, 0, 0 );
		level.cnd_rappel_tele_rope LinkTo( level.rpl_physical_rope_anim_origin, "J_prop_1" );
		
		if ( !IsDefined( level.cnd_rappel_player_rope ) )
		{
			level.cnd_rappel_player_rope 		= spawn_anim_model( "cnd_rappel_player_rope" );
			level.cnd_rappel_player_rope.origin = level.cnd_rappel_tele_rope GetTagOrigin( "J_Tele_50" );
			level.cnd_rappel_player_rope.angles	= level.cnd_rappel_tele_rope GetTagAngles( "J_Tele_50" );
		}
		
		// how much to turn the rope so it is perpendicular to the wall
		player_rope_angle_offset = ( 0, 0, 0 );
//		if ( rappel_params.rappel_type == "combat" )
//			player_rope_angle_offset = ( 0, 235, 0 );
		
		if ( rappel_params.rappel_type == "stealth" )
			level.cnd_rappel_player_rope LinkTo( level.cnd_rappel_tele_rope, "J_Tele_50", ( 0, 0, 0 ), player_rope_angle_offset );
		else // "combat"
			thread cnd_delay_rope_link();
		
		level.cnd_rappel_tele_rope SetAnim( rpl.player_rope_unwind_anim, 1, 0, 0 );
		cnd_plyr_rope_set_idle();
		
		one_unit_anim_time = 1.0 / rpl.player_rope_unwind_length; // how much time to scrub for 1 unit
		next_time = ( 33 * one_unit_anim_time );
		level.cnd_rappel_tele_rope SetAnimTime( rpl.player_rope_unwind_anim, next_time );
		
		level.cnd_rappel_player_rope DontCastShadows();
		level.cnd_rappel_tele_rope DontCastShadows();
		
		if ( rappel_params.rappel_type == "combat" )
			level.rpl_physical_rope_origin.angles += ( -1.2, 0, 0 ); // pitch the rope from the wall a bit
		
//		/#thread debug_draw_rope_ends();#/
	}
}

cnd_delay_rope_link()
{
	waitframe();
	level.cnd_rappel_player_rope LinkTo( level.cnd_rappel_tele_rope, "J_Tele_50" );
}

cnd_plyr_rope_set_idle()
{
	level.cnd_rappel_player_rope SetAnim( %cnd_rappel_idle_rope_player, 1, 0, 1 );
}

///#
//debug_draw_rope_ends()
//{
//	while ( true )
//	{
//		origin = level.cnd_rappel_tele_rope GetTagOrigin( "J_Tele_50" );
//		
//		debug_star( origin, (0, 1, 0) );
//		debug_star( level.rpl_rope_anim_origin GetTagOrigin( "tag_origin" ) + (0, 0, 1 ), (0, 0, 1 ) );
//		debug_star( level.rpl_rope_anim_origin GetTagOrigin( "J_prop_1" ) + (0, 0, 3 ), (0, 1, 1 ) );
//		debug_star( level.rpl_jump_anim_origin GetTagOrigin( "J_prop_1" ) + (0, 0, 4 ), (0, 1, 0 ) );
//		debug_star( level.rpl_plyr_anim_origin GetTagOrigin( "J_prop_1" ) + (0, 0, 5 ), (1, 0, 1 ) );
////		debug_star( level.rappel_player_rope GetTagOrigin( "tag_origin" ) + (0, 0, 2 ), (1,1,0) );
//		
//		waitframe();
//	}
//}
//#/

cnd_plyr_rpl_legs_setup( rpl, rappel_params )
{
	if ( !rappel_use_plyr_legs( rappel_params ) )
		return;

	rpl.legs_idle_anim 				= rpl_get_legs_idle_anim();
	rpl.legs_move_parent_node 	= rpl_legs_get_parent_node_move();

	rpl.move = [];

	rpl.move["down"] 		= SpawnStruct();
	rpl.move["up"] 			= SpawnStruct();
	rpl.move["right"] 		= SpawnStruct();
	rpl.move["left"] 		= SpawnStruct();
	rpl.move["right_down"] 	= SpawnStruct();
	rpl.move["right_up"] 	= SpawnStruct();
	rpl.move["left_down"] 	= SpawnStruct();
	rpl.move["left_up"] 	= SpawnStruct();

	rpl.move["down"].vector 		= ( 0, 1, 0 );
	rpl.move["up"].vector 			= ( 0, -1, 0 );
	rpl.move["right"].vector 		= ( 1, 0, 0 );
	rpl.move["left"].vector 		= ( -1, 0, 0 );
	rpl.move["right_down"].vector 	= VectorNormalize( ( 1, 1, 0 ) );
	rpl.move["right_up"].vector 	= VectorNormalize( ( 1, -1, 0 ) );
	rpl.move["left_down"].vector 	= VectorNormalize( ( -1, 1, 0 ) );
	rpl.move["left_up"].vector 		= VectorNormalize( ( -1, -1, 0 ) );

	rpl.move["down"].playing 		= false;
	rpl.move["up"].playing 			= false;
	rpl.move["right"].playing 		= false;
	rpl.move["left"].playing 		= false;
	rpl.move["right_down"].playing 	= false;
	rpl.move["right_up"].playing 	= false;
	rpl.move["left_down"].playing 	= false;
	rpl.move["left_up"].playing 	= false;
		
	rpl.cosine90 	= Cos( 90 );
	rpl.cosine45 	= Cos( 45 );
	rpl.cosine22_5 	= Cos( 22.5 );
	rpl.cosine15 	= Cos( 15 );
	rpl.cosine11_25 = Cos( 11.25 );
	
	rpl.MOVE_STATE_IDLE 		= 0;
	rpl.MOVE_STATE_START 		= 1;
	rpl.MOVE_STATE_LOOP 		= 2;
	rpl.MOVE_STATE_LOOP_RUN		= 3;
	rpl.MOVE_STATE_STOP 		= 4;
	rpl.MOVE_STATE_IDLE_SHIFT	= 5;
	rpl.MOVE_STATE_SHIFT_BACK	= 6;
	rpl.MOVE_STATE_JUMP			= 7;
		
	rpl.ANIMTYPE_PARENT			= 0;
	rpl.ANIMTYPE_IDLE			= 1;
	rpl.ANIMTYPE_START			= 2;
	rpl.ANIMTYPE_LOOP			= 3;
	rpl.ANIMTYPE_LOOP_RUN		= 4;
	rpl.ANIMTYPE_STOP			= 5;
	rpl.ANIMTYPE_RUN_STOP	 	= 6;
	rpl.ANIMTYPE_IDLE_SHIFT		= 7;
	rpl.ANIMTYPE_SHIFT_BACK		= 8;
	
	rpl.move_state = rpl.MOVE_STATE_IDLE;
	rpl.last_move_state = rpl.MOVE_STATE_IDLE;
		
	rpl.state_anim_percent_complete = 0.9;
		
	rpl.leg_anim_blend_time = 0.2;
	rpl.leg_anim_blend_time_fast = 0.05;
	rpl.leg_clear_anim_blend_time = 0.2;
	rpl.leg_clear_anim_blend_time_fast = 0.05;
	rpl.leg_idle_anim_blend_time = 0.4;
	rpl.leg_idle_trans_anim_blend_time = 0.2;
	rpl.leg_jump_anim_blend_time = 0.5;
		
	SetDvarIfUninitialized( "rappel_legs_scale_horizontal", 1.5 );
	SetDvarIfUninitialized( "rappel_legs_scale_run", 1.0 );
	SetDvarIfUninitialized( "rappel_legs_scale_up", 1.2 );
	SetDvarIfUninitialized( "rappel_legs_scale_down", 1.2 );
	
	rpl.legs_flag_name 		= "rappel_legs";
	notetrack_foot_left 	= "left_down";
	notetrack_foot_right 	= "right_down";

	thread cnd_rpl_legs_notetracks( rpl, notetrack_foot_left, notetrack_foot_right );
}
	
cnd_plyr_rpl_setup_globals( rpl, rappel_params, rope_origin_targetname )
{
	rpl.move_vel			= 0;	 // Current velocity value
	
	rpl.time_slice		  = 0.05;
	
	rpl.rope_start_rot = rpl.rope_origin.angles[ 2 ];
	rpl.vertical_change_this_update = 0;
	
	rpl.farthest_distance_down = Distance( level.rpl_plyr_anim_origin.origin, rpl.rope_origin.origin );
	
	rpl.clearing_bob_anim = false;
	rpl.current_foot = "left";
	rpl.jumpComplete = true;
	rpl.glass_broken_under_player = false;
	rpl.current_dist_to_top = 0;
	rpl.at_edge = false;
	
	rpl.maxRopeJumpAngle = 5.8362;
	rpl.tangentJump	= Tan( rpl.maxRopeJumpAngle );
	
	rpl.walk_up_amount = 35; // Amount player can walk up after descending
	
	rpl.wind_random = false;
	rpl.wind_random_delay_min = 4000;
	rpl.wind_random_delay_max = 10000;
	rpl.wind_random_next_time = 0;
	rpl.wind_strength = 0;
	rpl.wind_state = "calm";
	rpl.wind_last_state = "calm";
	rpl.wind_pushing_player = false;
	
	rpl.player_anim_origin = cnd_get_plyr_anim_origin();
	rpl.player_anim_origin SetAnim( %rappel_player_look_center, 1.0, 0, 1 );
	rpl.player_anim_origin thread watch_footstep_notetrack();
	
	// Get the worldspace directions, relative to the building
	if ( rope_origin_targetname == "rope_ref_stealth" )
	{
		// For stealth / inverted sections, use the original stealth ref
		building_angle_ref = GetEnt( "player_rappel_ground_ref_stealth", "targetname" );
	}
	else if ( rope_origin_targetname == "rope_ref_combat" )
	{
		// For combat section, use the combat ref
		building_angle_ref = GetEnt( "player_rappel_ground_ref_combat", "targetname" );
	}
	else
	{
		AssertMsg( "cornered_player_rappel_setup_globals was given an invalid rope_origin_targetname: " + rope_origin_targetname );
		building_angle_ref = GetEnt( "player_rappel_ground_ref_stealth", "targetname" );
	}
	
	rpl.forward_direction_worldspace = VectorNormalize( AnglesToForward( building_angle_ref.angles * ( 0, 1, 0 ) ) );	// Forward = towards the building
	rpl.right_direction_worldspace	 = VectorNormalize( AnglesToRight( building_angle_ref.angles * ( 0, 1, 0 ) ) );
	rpl.up_direction_worldspace		 = VectorNormalize( AnglesToUp( building_angle_ref.angles * ( 0, 1, 0 ) ) );
}
	
cnd_plyr_rpl_setup_dvars( rpl, rappel_params )
{
//	// dvars to modify the approximate speed in game units rather than these internal units
///#
//	SetDvar( "rappel_max_lateral_speed", level.rappel_max_lateral_speed );
//	SetDvar( "rappel_max_downward_speed", level.rappel_max_downward_speed );
//	SetDvar( "rappel_max_upward_speed", level.rappel_max_upward_speed );
//#/
//	SetDvarIfUninitialized( "rappel_use_idle_transitions", "0" );
	SetDvarIfUninitialized( "rappel_use_stop_momentum", "0" );
	SetDvarIfUninitialized( "rappel_stop_momentum_initial", "0.6" );
	SetDvarIfUninitialized( "rappel_stop_momentum_time", "0.7" );
	SetDvarIfUninitialized( "rappel_use_relative_controls", "1" );
//	SetDvarIfUninitialized( "rappel_wind", "0" );
	
	// let the footsteps/bob cycle continue as long as the player is moving has some velocity
	SetSavedDvar( "player_moveThreshhold", 1.0 ); // original: 10.0
	// make weapon bob more pronounced
	SetSavedDvar( "bg_weaponBobAmplitudeStanding", "0.072 0.033" ); // original: 0.055, 0.025 (standing)
	// make the player's lateral plane the XZ plane
	SetSavedDvar( "player_lateralPlane", rappel_params.lateral_plane ); // original: 0 = XY plane
	// let AI shoot the player through glass
	SetSavedDvar( "bullet_penetrationHitsClients", 1 );
	// let AI shoot AI through glass
	SetSavedDvar( "bullet_penetrationActorHitsActors", 1 );
	
	rpl.bg_weaponBobAmplitudeBase = GetDvarFloat( "bg_weaponBobAmplitudeBase" );
	rpl.g_speed = GetDvarFloat( "g_speed" );
	rpl.bg_viewBobMax = GetDvarFloat( "bg_viewBobMax" );
}

cnd_plyr_rpl_death( rpl, rappel_params )
{
	level endon( "stop_manage_player_rappel_movement" );
	
	level.player waittill( "death" );
	
	level.rappel_player_legs Hide();
}

cnd_plyr_rpl_setup_player( rpl, rappel_params )
{
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	if ( IsDefined( rappel_params.allow_sprint ) && rappel_params.allow_sprint )
		level.player AllowSprint( true );
	else
		level.player AllowSprint( false );
	level.player EnableMouseSteer( true );
//	level.level_specific_dof = true;
//	level.player thread cnd_plyr_rpl_plyr_set_dof();
	
	thread cnd_plyr_rpl_death( rpl, rappel_params );
}

/*cnd_plyr_rpl_plyr_set_dof()
{
	// this is a copy of the real dof management in _art.gsc - it is necessary since the GetPlayerAngles function gives relative angles when the player is linked to something
	level endon( "stop_manage_player_rappel_movement" );
	
	for ( ;; )
	{
		waitframe();

		if ( GetDvarInt( "scr_dof_enable" ) )
		{
			updateDoF();
			continue;
		}

		self maps\_art::setDefaultDepthOfField();
	}
}*/

/*updateDoF()
{
	Assert( IsPlayer( self ) );
	adsFrac = self PlayerAds();

	traceDist = getdvarfloat( "ads_dof_tracedist", 4096 );
	nearStartScale = getdvarfloat( "ads_dof_nearStartScale", 0.25 );
	nearEndScale = getdvarfloat( "ads_dof_nearEndScale", 0.85 );
	farStartScale = getdvarfloat( "ads_dof_farStartScale", 1.15 );
	farEndScale = getdvarfloat( "ads_dof_farEndScale", 3 );
	nearBlur = getdvarfloat( "ads_dof_nearBlur", 4 );
	farBlur = getdvarfloat( "ads_dof_farBlur", 2.5 );
	
	alwaysOn = getDvarInt( "ads_dof_debug", 0 );
	
	if ( ( adsFrac == 0.0 && !alwaysOn ) || !IsDefined( level.plyr_rpl_groundref ) )
	{
		self maps\_art::setDefaultDepthOfField();
		return;
	}
	
	// Combine player angles with lookref angles to get player's worldspace angles
	player_angles_relative = self GetPlayerAngles();
	player_angles_worldspace = CombineAngles( level.plyr_rpl_groundref.angles, player_angles_relative );

	playerEye = self GetEye();
	playerAngles = player_angles_worldspace;
	playerForward = VectorNormalize( AnglesToForward( playerAngles ) );

	trace = BulletTrace( playerEye, playerEye + ( playerForward * traceDist ), true, self, true );
	enemies = GetAIArray( "axis" );

	weapon = self getcurrentweapon();
	if ( isdefined( level.special_weapon_dof_funcs[ weapon ] ) )
	{
		[[ level.special_weapon_dof_funcs[ weapon ] ]]( trace, enemies, playerEye, playerForward, adsFrac );
		return;
	}

	if ( trace[ "fraction" ] == 1 )
	{
		traceDist = 2048;
		nearEnd = 256;
		farStart = traceDist * farStartScale * 2;
	}
	else
	{
		traceDist = Distance( playerEye, trace[ "position" ] );
		nearEnd = traceDist * nearStartScale;
		farStart = traceDist * farStartScale;
	}

	for ( index = 0; index < enemies.size; index++ )
	{
		enemyDir = VectorNormalize( enemies[ index ].origin - playerEye );

		dot = VectorDot( playerForward, enemyDir );
		if ( dot < 0.923 )// 45 degrees
			continue;

		distFrom = Distance( playerEye, enemies[ index ].origin );

		if ( distFrom - 30 < nearEnd )
			nearEnd = distFrom - 30;

		if ( distFrom + 30 > farStart )
			farStart = distFrom + 30;
	}
	
	if ( nearEnd > farStart )
	{
		nearEnd = farStart - 256;
	}

	if ( nearEnd > traceDist )
		nearEnd = traceDist - 30;

	if ( nearEnd < 1 )
		nearEnd = 1;

	if ( farStart < traceDist )
		farSTart = traceDist;
		
	self maps\_art::setDoFTarget( adsFrac, nearEnd*nearStartScale, nearEnd, farStart, farStart * farEndScale, nearBlur, farBlur );
}*/



// ****************************
// * Rappel LOGIC             *
// *********************************************************************************************************************************************************************

		
cnd_rpl_calc_move( rpl, rappel_params )
{
	// Any downwards movement greater than these amounts will zero out lateral movement
	stick_down_deadzone_narrow = 0.78;	// smallest the deadzone can be
	stick_down_deadzone_wide = 0.65;	// widest the deadzone can be

	rpl.jumping = flag( "player_jumping" );
	
	// Player left stick input.  (1,0,0) is up and (0,1,0) is right
	player_stick_input = level.player GetNormalizedMovement();
	
	// Magnitude of player left stick input (how strong is the player pushing the stick)  0 means nothing, 1 means pushed all the way
	rpl.player_stick_magnitude = max( abs( player_stick_input[ 0 ] ), abs( player_stick_input[ 1 ] ) );
	
	// Note: player angles are relative to the entity we are attached to
	player_angles_relative = level.player GetPlayerAngles();
	
	// Combine player angles with lookref angles to get player's worldspace angles
	rpl.player_angles_worldspace = CombineAngles( level.plyr_rpl_groundref.angles, player_angles_relative );
	
	use_relative_controls = GetDvarInt( "rappel_use_relative_controls", 0 );
	
	if ( !use_relative_controls )
	{
		if ( IsDefined( rpl.last_player_angles_worldspace ) && rpl.player_stick_magnitude > 0 )
			rpl.player_angles_worldspace = rpl.last_player_angles_worldspace;
	}
	
	// Get player directions (in worldspace)
	player_forward_worldspace = AnglesToForward( rpl.player_angles_worldspace );
	player_right_worldspace	  = AnglesToRight( rpl.player_angles_worldspace );
	player_up_worldspace	  = AnglesToUp( rpl.player_angles_worldspace );
	
	level.player.linked_world_space_forward = player_forward_worldspace;
	
	// Calculate if the player is at the vertical limits
	rpl.dist_player_to_top = rpl_calc_dist_player_to_top( rpl, true );
//	rpl.modified_lower_limit = rpl_get_angle_modified_lower_limit( rpl.rope_origin );
	rpl.player_at_lower_limit	 = IsDefined( level.rappel_lower_limit ) && ( rpl.dist_player_to_top > level.rappel_lower_limit );
	rpl.player_at_upper_limit	 = IsDefined( level.rappel_upper_limit ) && ( rpl.dist_player_to_top < level.rappel_upper_limit );
	
	distance_from_top_to_end_of_rope = Distance( level.rpl_plyr_anim_origin.origin, rpl.rope_origin.origin );
	vertical_cap_dist_from_top		 = rpl.farthest_distance_down - rpl.walk_up_amount;
	rpl.vert_dist_to_vert_cap		 = distance_from_top_to_end_of_rope - vertical_cap_dist_from_top;
	rpl.player_at_vertical_upper_cap = abs( rpl.vert_dist_to_vert_cap ) < 2;
	
	at_any_vertical_limit = rpl.player_at_lower_limit || rpl.player_at_upper_limit || rpl.player_at_vertical_upper_cap;

	
	// *******************************************
	// * Player Right/Left movement calculations *
	// *******************************************
	
	// Scale player forward and right vectors according to the stick input
	
	// Weight the player forward direction with the magnitude of the stick forward direction.
	// I.e. if the stick is pushed all the way up, then the forward direction should have a 100% weight
	player_forward_weighted = player_forward_worldspace * player_stick_input[ 0 ];
	
	// Weight the player right direction with the magnitude of the stick right direction.
	// I.e. if the stick is pushed all the way right, then the right direction should have a 100% weight
	player_right_weighted = player_right_worldspace * player_stick_input[ 1 ];
	
	// Combine the two weighted vectors to get the combined worldspace movement vector - the direction that the player is trying to move with the left stick
	move_vector = VectorNormalize( player_forward_weighted + player_right_weighted );
	
	// This is the percent we are trying to move right.  1 means full right movement, -1 means full left movement
	right_move_percent = VectorDot( move_vector, rpl.right_direction_worldspace );
	
	// 1 if moving right, -1 if moving left
	right_or_left_sign = sign( right_move_percent );
	
	// Combine the right percentage with the stick magnitude to determine final amount of right/left movement, and multiply in the sign to get the correct direction
	// This is a scalar from -1 to 1 that is used to determine the full rappel lateral speed (with rappel_accel_speed)
	rpl.right_move_strength = rpl.player_stick_magnitude * right_or_left_sign * sqrt( abs( right_move_percent ) );	//sqrt to make the direction more forgiving
	
	// *****************************************
	// * Player Vertical movement calculations *
	// *****************************************
	
	// For downward movement, we need to do slightly different calculations
	
	// dot_player_forward_world_forward is used to determine if the player is looking toward (or away) from the building
	// 1.0 means the player is looking directly at the building, or directly away from the building
	// 0.0 means looking 90 degrees from the building (looking down the side of the building, toward the player's allies)
	// This is needed because the meaning of the left stick up/down value changes depending on which direction the player is looking
	// If the player is looking directly toward (or away from) the building, player_stick_input[0] means "up/down"
	// If the player is looking down the side of the building, player_stick_input[0] means "forward/backward"
	dot_player_forward_world_forward = abs( VectorDot( player_forward_worldspace, rpl.forward_direction_worldspace ) );
	
	// Calculate the "up" portion of the desired player movement
	player_forward_weighted_up = player_up_worldspace * player_stick_input[ 0 ] * dot_player_forward_world_forward;
	
	// Calculate the "forward" portion of the desired player movement
	player_forward_weighted_forward = player_forward_worldspace * player_stick_input[ 0 ] * ( 1 - dot_player_forward_world_forward );
	
	// Calculate the new movement vector, with the up/forward weights above applied
	move_vector_calculated_for_downward = VectorNormalize( player_forward_weighted_up + player_forward_weighted_forward + player_right_weighted );
	
	// This is the percent we are trying to move down.  1 means full downward movement, 0 or less means no downward movement
	down_move_percent = VectorDot( move_vector_calculated_for_downward, ( -1 * rpl.up_direction_worldspace ) );
	
	// Scale downward speed by the way the player is facing, since if you are looking sideways, you can only get up to 0.5 for
	// down_move_percent (since the player is slightly rolled) but if you are looking straight on towards the building, you can get to 1.0
	// This will provide a consisent vertical speed regardless of the direction the player is looking
	down_move_percent *= ( 2 - dot_player_forward_world_forward );
	down_move_percent = clamp( down_move_percent, -1.0, 1.0 );
	
	// Combine the down percentage with the stick magnitude to determine the final amount of vertical movement.
	// No need to multiply a sign since the percentage already incorporates the direction.
	rpl.down_move_strength = clamp( down_move_percent, -1.0, 1.0 ) * rpl.player_stick_magnitude;
	
//	if ( abs( right_move_percent ) > 0.85 )
//	{
//		// If the player is mostly trying to move left or right, zero out vertical movement so he doesn't "slip" down while moving horizontally
//		rpl.down_move_strength = 0;
//	}
	
	// If the player is pushing forward and trying to move right/left - i.e. he is looking left or right and pushing up on the stick,
	// then we don't ever want to zero out lateral movement, since there would be edge cases where the player is pushing on the stick and not moving
	player_pushing_forward_and_trying_to_move_right = ( abs( player_stick_input[0] ) > 0.9 ) && ( abs( right_move_percent ) > 0.7 );
	if ( !at_any_vertical_limit && abs( rpl.down_move_strength ) > 0 && !player_pushing_forward_and_trying_to_move_right )
	{
		// If player is trying to move down, see if we need to zero out right/left movement
		
		// Deadzone lerps from narrow to wide depending on how close the player's view is to world forward
		// I.e. if he is facing the building, the deadzone is narrow.  If he is facing to the side, the deadzone is wide
		stick_down_deadzone = stick_down_deadzone_wide + dot_player_forward_world_forward * ( stick_down_deadzone_narrow - stick_down_deadzone_wide );
		zero_out_right_move = abs( down_move_percent ) > stick_down_deadzone;
		
		if ( rappel_params.rappel_type == "inverted" )
			zero_out_right_move = zero_out_right_move & abs( rpl.right_move_strength ) < 0.4;
			
		if ( zero_out_right_move )
		{
			// If the player is mostly trying to move up or down, zero out right/left movement to keep the player moving straight
			rpl.right_move_strength = 0;
		}
		else if ( abs( down_move_percent ) > (stick_down_deadzone - 0.1) )
		{
			rpl.right_move_strength *= 0.5;
		}
		else if ( abs( down_move_percent ) > (stick_down_deadzone - 0.2) )
		{
			rpl.right_move_strength *= 0.75;
		}
	}
	
	cnd_rpl_plyr_too_close_to_allies( rpl );
}

cnd_rpl_plyr_too_close_to_allies( rpl )
{
	stop_player = false;
	
	// ally + player radius
	IDLE = 60 * 60;
	MOVE_BACK = 130 * 130;
	TURN = 160 * 160;
	ANIMATING = 80 * 80;
	
	check_radius_sq = IDLE;
	lat_change = rpl.lateral_change_this_update; // really the change last update
	if ( !IsDefined( lat_change ) )
		lat_change = 0;
	
	foreach ( ally in level.allies )
	{
		if ( ally.animname == "rorke" )
			ally.player_moving_toward_me = ( rpl.right_move_strength != 0 && sign( rpl.right_move_strength ) > 0 ) || ( lat_change != 0 && sign( lat_change ) > 0 );
		else // == "baker"
			ally.player_moving_toward_me = ( rpl.right_move_strength != 0 && sign( rpl.right_move_strength ) < 0 ) || ( lat_change != 0 && sign( lat_change ) < 0 );
	
		if ( !IsDefined( ally.move_type ) )
			continue;
		
		dist_sq = ally maps\cornered_code_rappel_allies::ally_rappel_Distance2DSquared_to_player();
		
		if ( ally.move_type == "idle" || IsSubStr( ally.move_type, "move_away" ) )
			check_radius_sq = IDLE;
		else if ( IsSubStr( ally.move_type, "move_back" ) )
			check_radius_sq = MOVE_BACK;
		else if ( ally.move_type == "turn_away" )
			check_radius_sq = TURN;
		else // ally.move_type == "animating"
			check_radius_sq = ANIMATING;
			
		if ( ally.player_moving_toward_me && dist_sq <= check_radius_sq )
		{
			stop_player = true;
//			Sphere( ally_org, sqrt( check_radius_sq ), ( 1, 0, 0 ) );
//			/#debug_star( player_org, ( 1, 0, 0 ) );#/
			break;
		}
//		else
//		{
//			Sphere( ally_org, sqrt( check_radius_sq ), ( 0, 1, 0 ) );
//			/#debug_star( player_org, ( 0, 1, 0 ) );#/
//		}
	}
	
	if ( stop_player )
	{
		rpl.right_move_strength = 0;
		rpl.down_move_strength = 0;
		rpl.player_stick_magnitude = 0;
		rpl.too_close_to_ally = 1;
	}
	else
	{
		rpl.too_close_to_ally = 0;
	}
}
		
cnd_rpl_do_vertical_move( rpl, rappel_params )
{
	// ****************************
	// * Player vertical movement *
	// ****************************
	
	if ( !flag( "player_allow_rappel_down" ) )
	{
		// Player downward movement is not allowed, so clear the "player_moving_down" flag in case it was previously set
		flag_clear( "player_moving_down" );
		return;
	}
	
	vertical_change_last_update 	= rpl.vertical_change_this_update;
	rpl.vertical_change_this_update = 0;
	rpl.glass_broken_under_player	= false;
	
	rope_up_dir = AnglesToUp( level.rpl_rope_anim_origin GetTagAngles( "J_prop_1" ) );
	
	// Check if player should slide down because the glass that he was standing on is broken
	if ( !rpl.jumping && IsDefined( rappel_params.allow_glass_break_slide ) && rappel_params.allow_glass_break_slide )
	{
		// Trace to glass in front of player.  If broken, slide player down until he reaches a solid section of the wall
		trace_start = level.player.origin + ( 0, 0, 25 );
		trace_end	= trace_start + rpl.forward_direction_worldspace * 70;
		//line( trace_start, trace_end, (0,0,1), 1.0, true, 1);
		trace = BulletTrace( trace_start, trace_end, false );
		
		if ( trace[ "surfacetype" ] == "none" )
		{
			// Not standing on anything, so move down until we are
			rpl.glass_broken_under_player = true;
			rpl.down_move_strength	  = 1;
		}
	}
	
	if ( rpl.jumping && IsDefined( level.rappel_jump_land_struct ) && IsDefined( level.player.forcing_rappel_jump_to_struct ) )
	{
		// Player is jumping and needs to land on the defined struct
		
		// level.player.forcing_rappel_jump_to_struct gets set in player_rappel_force_jump_away(), if the scripter wants the forced jump to land on the struct
		// Or it is set in in cornered_player_rappel_handle_jump, if the player jumps and level.rappel_jump_land_struct is defined.
		jump_origin = cnd_get_rope_anim_origin();
		
		percent_of_anim_is_landed = 0.7;
		
		total_anim_length = GetAnimLength( level.rappel_jump_anim ) * percent_of_anim_is_landed;

		cur_anim_time = jump_origin GetAnimTime( level.rappel_jump_anim );
		
		anim_length_time_left = (1 - cur_anim_time) * total_anim_length;			// in seconds
		anim_length_frames_left = Int( anim_length_time_left / rpl.time_slice );	// in script frames
		
		vert_dist_to_dest_struct = level.rappel_jump_land_struct.origin[2] - level.player.origin[2];
		
		if ( anim_length_frames_left )
			rpl.vertical_change_this_update = vert_dist_to_dest_struct / anim_length_frames_left;
	}
	else if ( ( rpl.down_move_strength > 0 ) || ( rpl.down_move_strength < 0 && !rpl.jumping ) )
	{
		// Allow vertical movement if the player is trying to move down, or he is trying to move up and is not jumping
		
		// Calculate the amount that the z-value is changing this update
		if ( rpl.down_move_strength > 0 )
		{
			// Moving down
			rpl.vertical_change_this_update = -1 * rpl.down_move_strength * rpl_get_max_downward_speed();
			
			if ( rpl.jumping )
			{
				// If jumping and moving down, allow faster downward movement
				rpl.vertical_change_this_update *= 1.5;
			}
			
			if ( rpl.glass_broken_under_player )
			{
				// If sliding down due to glass breaking, allow faster downward movement
				rpl.vertical_change_this_update *= 4.2;
			}
		}
		else if ( IsDefined( rappel_params.allow_walk_up ) && rappel_params.allow_walk_up )
		{
			rpl.vertical_change_this_update = -1 * rpl.down_move_strength * rpl_get_max_upward_speed();
			
			// check how close player is to the vertical limit.  If he is close, limit his movement so he doesn't cross it
			if ( rpl.player_at_vertical_upper_cap )
			{
				percent_toward_vert_cap = 1.0;
				rpl.vertical_change_this_update = 0.0;
			}
			else
			{
				rpl.vertical_change_this_update = min( rpl.vertical_change_this_update, rpl.vert_dist_to_vert_cap );
				
				// Apply a bit of friction the closer you get to the top
				percent_toward_vert_cap = 1 - min( ( rpl.vert_dist_to_vert_cap / rpl.walk_up_amount ), 1.0 );
				
				rpl.vertical_change_this_update *= ( 1 - percent_toward_vert_cap * percent_toward_vert_cap );
			}
		}
	}
	
	if ( rpl.jumping && !IsDefined( level.player.forcing_rappel_jump_to_struct ) && vertical_change_last_update < 0 )
	{
		// If player is jumping, and he is not being force to jump to a struct, and last frame he was moving down, then apply
		// at least a fraction of last frame's movement, so the jump doesn't just abruptly stop when the player lets up on the stick
		
		rpl.vertical_change_this_update = min(rpl.vertical_change_this_update, vertical_change_last_update * 0.9);
	}
	
	if ( IsDefined( level.rappel_lower_limit ) && rpl.vertical_change_this_update < 0 )
	{
		// Lower limit is defined and player is moving down
		
		if ( rpl.player_at_lower_limit )
		{
			// Player made it past the lower limit, so don't allow any downwards movement
			rpl.vertical_change_this_update = 0;
		}
		else
		{
			// Don't allow vertical change to move player past the lower limit
			rpl.vertical_change_this_update = max( rpl.vertical_change_this_update, ( rpl.dist_player_to_top - level.rappel_lower_limit ) );
		}
	}
	else if ( IsDefined( level.rappel_upper_limit ) && rpl.vertical_change_this_update > 0 )
	{
		// Upper limit is defined and player is moving up
		
		if ( rpl.player_at_upper_limit )
		{
			// Player made it past the upper limit, so don't allow any upwards movement
			rpl.vertical_change_this_update = 0;
		}
		else
		{
			// Don't allow vertical change to move player past the upper limit
			rpl.vertical_change_this_update = min( rpl.vertical_change_this_update, ( rpl.dist_player_to_top - level.rappel_upper_limit ) );
		}
	}

// push the player up with dynamic modified lower limits - handled another way for now
//	if ( IsDefined( rpl.modified_lower_limit ) && rpl.dist_player_to_top > rpl.modified_lower_limit && rpl.vertical_change_this_update < 1.5 )
//		rpl.vertical_change_this_update = 1.5;
	
	if ( abs( rpl.vertical_change_this_update ) < 0.05 )
		rpl.vertical_change_this_update = 0;
	
	if ( abs( rpl.vertical_change_this_update ) > 0 )
	{
		level.rpl_plyr_anim_origin Unlink();
		level.rpl_plyr_anim_origin.origin += ( rope_up_dir * rpl.vertical_change_this_update );
		level.rpl_plyr_anim_origin LinkTo( level.rpl_jump_anim_origin, "J_prop_1" );
	}
	
	if ( rpl.vertical_change_this_update < 0 )
	{
		flag_set( "player_moving_down" );
		/* Temporarily commenting this out to allow player to walk all the way back up (if rappel_params.allow_walk_up is true)
		if ( distance_from_top > rpl.farthest_distance_down )
		{
			rpl.farthest_distance_down = distance_from_top;
		}
		*/
	}
	else
	{
		flag_clear( "player_moving_down" );
	}
}
		
cnd_rpl_do_lateral_move( rpl, rappel_params )
{
	// ***************************
	// * Player lateral movement *
	// ***************************
	friction_scalar_min = 0.70;
	friction_scalar_max = 0.85;
	gravity_dead_zone = 5;
	
	if ( rappel_params.rappel_type == "combat" )
		gravity_dead_zone = 2;
	
	current_rope_rot = ( rpl.rope_origin.angles[ 2 ] - rpl.rope_start_rot );
	
	if ( rpl.jumping && IsDefined( level.rappel_jump_land_struct ) && IsDefined( level.player.forcing_rappel_jump_to_struct ) )
	{
		// Player is jumping and needs to land on the defined struct
		
		// level.player.forcing_rappel_jump_to_struct gets set in player_rappel_force_jump_away(), if the scripter wants the forced jump to land on the struct
		// Or it is set in in cornered_plyr_rappel_handle_jump, if the player jumps and level.rappel_jump_land_struct is defined.
		jump_origin = cnd_get_rope_anim_origin();
		
		percent_of_anim_is_landed = 0.7;
		
		total_anim_length = GetAnimLength( level.rappel_jump_anim ) * percent_of_anim_is_landed;

		cur_anim_time = jump_origin GetAnimTime( level.rappel_jump_anim );
		
		anim_length_time_left = (1 - cur_anim_time) * total_anim_length;				// in seconds
		level.anim_length_frames_left = Int( anim_length_time_left / rpl.time_slice );	// in script frames
		
		rope_roll = rpl.rope_origin.angles[2];
		
		plane_normal_left = rappel_get_plane_normal_left( rappel_params.rappel_type );
		plane_left_d = rappel_get_plane_d( plane_normal_left, rpl.rope_origin.origin );
		hypotenuse	  = Distance( level.rappel_jump_land_struct.origin, rpl.rope_origin.origin );
		opposite	  = ( VectorDot( plane_normal_left, level.rappel_jump_land_struct.origin ) + plane_left_d ); 
		level.new_rope_roll = -1 * ASin( opposite / hypotenuse );	
		
		level.roll_diff = level.new_rope_roll - rope_roll;
		
		if ( level.anim_length_frames_left > 0 )
			rpl.lateral_change_this_update = level.roll_diff / level.anim_length_frames_left;
	}
	else
	{	
		if ( rpl.jumping )
		{
			right_move_normalized 	= 0;
			friction				= 1.0;
		}
		else
		{
			right_move_normalized 	= clamp( rpl.right_move_strength, -1.0, 1.0 );
			friction					= linear_interpolate( sqrt( abs( right_move_normalized ) ), friction_scalar_min, friction_scalar_max );
		}
		
		accel_speed				= 1.95;
		rappel_gravity_strength = 1.95;	// Gravity needs to be less than or equal to accel speed, else you may not reach the edge
		max_yaw_r				= rpl_calc_max_yaw_right( rpl );
		max_yaw_l				= rpl_calc_max_yaw_left( rpl );
		rpl.max_rotation_speed	= rpl_calc_max_rot_speed( rpl, rappel_params );
		
		if ( rappel_params.rappel_type == "combat" )
		{
			accel_speed				= 4;
			rappel_gravity_strength = 4;
		}
		
		rpl.on_right_side = ( current_rope_rot >= 0 );
		
		if ( level.player IsSprinting() )
		{
			accel_speed *= 1.5;
		}
		
		// When moving "uphill" add a gravity force to slow you down the further you get from the center
		yaw_dist_from_dead_zone = abs( current_rope_rot ) - gravity_dead_zone;
		if ( yaw_dist_from_dead_zone >= 0 )
		{
			gravity_dir = -1 * sign( current_rope_rot );
			
			// gravity_force_normalized ramps from 0-1 based on how close the player is to the max yaw
			if ( rpl.on_right_side )
			{
				rpl.player_percent_toward_max_yaw = yaw_dist_from_dead_zone / ( max_yaw_r - gravity_dead_zone );
			}
			else
			{
				rpl.player_percent_toward_max_yaw = yaw_dist_from_dead_zone / ( abs( max_yaw_l ) - gravity_dead_zone );
			}
			gravity_force_normalized = gravity_dir * rpl.player_percent_toward_max_yaw;
			
			if ( !rpl.jumping )
			{
				// If you are not jumping, scale gravity by lateral movement strength, so gravity won't pull you unless you're actually moving.			
				gravity_force_normalized *= abs( right_move_normalized );
			}
		}
		else
		{
			// Within the dead zone, don't pull you to center
			gravity_force_normalized = 0;
		}
		
		// Total force that gravity is adding to the velocity this frame
		gravity_force = gravity_force_normalized * rappel_gravity_strength;
		
		// Total force that the player's lateral movement is adding to the velocity this frame
		lateral_move_force = right_move_normalized * accel_speed;
		
		// Add input and gravity into our current velocity, and then apply friction to get our new velocity
		rpl.move_vel = ( rpl.move_vel + lateral_move_force + gravity_force ) * friction;
		
		// Clamp our velocity to the maximum if it is over
		rpl.move_vel = clamp( rpl.move_vel, -1 * rpl.max_rotation_speed, rpl.max_rotation_speed );
		
		// Determine if we are already beyond the max yaw and change our move velocity to get us out of it
		beyond_max_yaw_r = ( current_rope_rot > ( rpl.rope_start_rot + max_yaw_r ) );
		beyond_max_yaw_l = ( current_rope_rot < ( rpl.rope_start_rot + max_yaw_l ) );
		beyond_l_but_doing_nothing = beyond_max_yaw_l && rpl.player_stick_magnitude > 0 && rpl.right_move_strength <= 0;
		beyond_r_but_doing_nothing = beyond_max_yaw_r && rpl.player_stick_magnitude > 0 && rpl.right_move_strength >= 0;
		
		// Calculate the target rotation
		if ( beyond_l_but_doing_nothing )
		{
			target_yaw = rpl.rope_start_rot + max_yaw_l;
		}
		else if ( beyond_r_but_doing_nothing )
		{
			target_yaw = rpl.rope_start_rot + max_yaw_r;
		}
		else
		{
			target_yaw = current_rope_rot + ( rpl.move_vel * rpl.time_slice );
		
			// Clamp the rotation to the left/right limits
			target_yaw = min( target_yaw, rpl.rope_start_rot + max_yaw_r );
			target_yaw = max( target_yaw, rpl.rope_start_rot + max_yaw_l );
		}
		
		// Amount yaw is changing this update
		rpl.lateral_change_this_update = target_yaw - current_rope_rot;
		rpl.lateral_dist_change = Sin( abs( rpl.lateral_change_this_update ) ) * rpl.dist_player_to_top;
		
		// Always move if beyond the maximum yaw
		if ( !beyond_l_but_doing_nothing && !beyond_r_but_doing_nothing )
		{
			dist_current_rot_from_edge_r = abs( (rpl.rope_start_rot + max_yaw_r) - current_rope_rot );
			dist_current_rot_from_edge_l = abs( (rpl.rope_start_rot + max_yaw_l) - current_rope_rot );
			
			if ( rpl.right_move_strength == 0 && dist_current_rot_from_edge_r <= dist_current_rot_from_edge_l )
				dist_current_rot_from_edge = dist_current_rot_from_edge_r;
			else if ( rpl.right_move_strength == 0 )
				dist_current_rot_from_edge = dist_current_rot_from_edge_l;
			else if ( sign( rpl.right_move_strength ) == 1 )
				dist_current_rot_from_edge = dist_current_rot_from_edge_r;
			else // if ( sign( rpl.right_move_strength ) == -1 )
				dist_current_rot_from_edge = dist_current_rot_from_edge_l;
				
			rpl.approx_dist_from_edge = Sin( abs( dist_current_rot_from_edge ) ) * rpl.dist_player_to_top;
				
			diff = abs( rpl.lateral_dist_change - rpl.approx_dist_from_edge );
			
			if ( rpl.at_edge )
			{
				 rpl.at_edge = sign( rpl.lateral_change_this_update ) == rpl.at_edge_sign;
			}
			
			too_close_to_edge = rpl.at_edge || diff < 5;
			if ( too_close_to_edge )
			{
				// If the player is really close to the left/right edge...
				if ( sign( rpl.lateral_change_this_update ) == sign( rpl.right_move_strength ) || rpl.right_move_strength == 0 )
				{
					// And he is trying to move to the edge, and the movement is really small, then zero it out.
					// This prevents bouncing at the edges due to a bug in RotateRoll where it overshoots very small rotations (< 0.2 or so)
					rpl.lateral_change_this_update = 0;
					rpl.move_vel = 0;
					rpl.at_edge = true;
					if ( rpl.lateral_change_this_update == 0 )
						rpl.at_edge_sign = 0;
					else
						rpl.at_edge_sign = sign( rpl.lateral_change_this_update );
				}
			}
			
			dist_change_to_zero_move = 0.2;
			if ( rappel_params.rappel_type == "inverted" )
				dist_change_to_zero_move = 0.5;
			
			if ( rpl.lateral_dist_change < dist_change_to_zero_move )
			{
				rpl.lateral_change_this_update = 0;
				rpl.move_vel = 0;
			}
		}
		else
		{
			max_unit_lerp_per_frame = 2;
			if ( rpl.dist_player_to_top == 0 )
				max_angle_lerp_per_frame = max_unit_lerp_per_frame;
			else
				max_angle_lerp_per_frame = ASin( max_unit_lerp_per_frame / rpl.dist_player_to_top );
			rpl.lateral_change_this_update = clamp( rpl.lateral_change_this_update, -1 * max_angle_lerp_per_frame, max_angle_lerp_per_frame );
		}
				
		if ( IsDefined( rpl.stop_momentum ) && abs( rpl.stop_momentum ) > 0.01 )
		{
			rpl.lateral_change_this_update = rpl.stop_momentum;
			rpl.stop_momentum -= rpl.stop_momentum_change;
		}
		
		use_relative_controls = GetDvarInt( "rappel_use_relative_controls", 0 );
		was_move = abs( rpl.lateral_change_this_update ) > 0.01 || abs( rpl.vertical_change_this_update ) > 0;
		
		if ( !use_relative_controls && was_move )
			rpl.last_player_angles_worldspace = rpl.player_angles_worldspace;
		else
			rpl.last_player_angles_worldspace = undefined;
	}
	
	cnd_rpl_handle_jumping_toward_allies( rpl );
		    
	// Rotate the rope origin to the new target yaw calculated above
	if ( abs( rpl.lateral_change_this_update ) > 0 )
	{
		rpl.rope_origin RotateRoll( rpl.lateral_change_this_update, rpl.time_slice, 0, 0 );
//		rpl.rope_origin.angles += ( 0, 0, rpl.lateral_change_this_update );
	}
}

cnd_rpl_handle_jumping_toward_allies( rpl )
{
	if ( !rpl.jumping )
		return;
	
	foreach ( ally in level.allies )
	{
		if ( ally.animname == "rorke" )
			ally.player_moving_toward_me = rpl.lateral_change_this_update != 0 && sign( rpl.lateral_change_this_update ) > 0;
		else // == "baker"
			ally.player_moving_toward_me = rpl.lateral_change_this_update != 0 && sign( rpl.lateral_change_this_update ) < 0;
	}
}

cnd_rpl_do_stop_sway( rpl, rappel_params )
{
	is_swaying_l = rpl.player_anim_origin GetAnimWeight( %rappel_player_stop_l ) > 0;
	is_swaying_r = rpl.player_anim_origin GetAnimWeight( %rappel_player_stop_r ) > 0;
	is_swaying = is_swaying_l || is_swaying_r;
	player_trying_to_move = abs( rpl.down_move_strength ) > 0.2 || abs( rpl.right_move_strength ) > 0.2;
	
	if ( is_swaying && player_trying_to_move && !IsDefined( rpl.clearing_sways ) )
	{
		sway_anim = %rappel_player_stop_l;
		if ( is_swaying_r )
			sway_anim = %rappel_player_stop_r;
		
		rpl.player_anim_origin ClearAnim( sway_anim, 0.4 );
		rpl.clearing_sways = true;
	}
	
	if ( IsDefined( rpl.clearing_sways ) && rpl.clearing_sways && !is_swaying )
	{
		rpl.clearing_sways = undefined;
	}
	
	if ( !IsDefined( rpl.begin_sway ) )
		return;
		
	if ( _rpl_legs_is_horizontal( rpl.stop_anim_direction ) )
	{
		sway_anim = %rappel_player_stop_l;
		if ( rpl.stop_anim_direction == "right" )
			sway_anim = %rappel_player_stop_r;
		
		blend_time = 0.2;
		rpl.player_anim_origin SetAnimRestart( sway_anim, 1.0,blend_time, 1.0 );
		if ( rpl.player_anim_origin GetAnimWeight( %rappel_player_wind_push ) > 0 )
			rpl.player_anim_origin ClearAnim( %rappel_player_wind_push, blend_time );
		rpl.clearing_sways = undefined;
	}
		
	rpl.begin_sway = undefined;
}

cnd_rpl_do_wind( rpl, rappel_params )
{
	if ( rappel_params.rappel_type != "stealth" )
		return;
		
	if ( !rpl.wind_random )
	{
		rpl.wind_state = "stop";
		return;
	}

//	if ( GetDvar( "rappel_wind" ) == "0" )
//		return;
		
	rpl.wind_last_state = rpl.wind_state;
	
	if ( rpl.wind_random_next_time > GetTime() )
		return;
	
	wind_ramp_up_sec			 = 2;
	wind_ramp_down_sec			 = 2;
	wind_ramp_up_speed			 = 1 / ( wind_ramp_up_sec / 0.05 );
	wind_ramp_down_speed		 = 1 / ( wind_ramp_down_sec / 0.05 );
	wind_strong_steady_delay_sec = 1.8;

	// transitioning states
	if ( rpl.wind_state == "strong" )
	{
		rpl.wind_state = "down";
	}
	else if ( rpl.wind_state == "stop" || rpl.wind_state == "calm" )
	{
		rpl.wind_state = "up";
		exploder( "6111" );
	}
	
	// change wind strength
	if ( rpl.wind_state == "up" )
		rpl.wind_strength += wind_ramp_up_speed;
	else if ( rpl.wind_state == "down" )
		rpl.wind_strength -= wind_ramp_down_speed;
		
	if ( rpl.wind_strength >= 1 && rpl.wind_state == "up" )
	{
		rpl.wind_random_next_time = GetTime() + ( 0.2 * 1000 );
		rpl.wind_state	= "steady";
		rpl.wind_strength = 1;
	}
	else if ( !rpl.wind_pushing_player && rpl.wind_strength >= 0.7 )
	{
		blend_time = 0.2;
		rpl.wind_pushing_player = true;
		rpl.player_anim_origin SetAnimRestart( %rappel_player_wind_push, 1.0, blend_time, 1.0 );
		rpl.player_anim_origin PlayRumbleOnEntity( "light_in_out_2s" );
		if ( rpl.player_anim_origin GetAnimWeight( %rappel_player_stop_l ) > 0 )
			rpl.player_anim_origin ClearAnim( %rappel_player_stop_l, blend_time );
		if ( rpl.player_anim_origin GetAnimWeight( %rappel_player_stop_r ) > 0 )
			rpl.player_anim_origin ClearAnim( %rappel_player_stop_r, blend_time );
	}
	else if ( rpl.wind_pushing_player && rpl.wind_strength >= 1 && rpl.wind_state == "steady" )
	{
		rpl.wind_random_next_time = GetTime() + ( wind_strong_steady_delay_sec * 1000 );
		rpl.wind_strength		  = 1;
		rpl.wind_state			  = "strong";
	}
	else if ( rpl.wind_strength <= 0 && rpl.wind_state == "down" )
	{
		rpl.wind_random_next_time = GetTime() + RandomFloatRange( rpl.wind_random_delay_min, rpl.wind_random_delay_max );
		rpl.wind_strength		  = 0;
		rpl.wind_state			  = "calm";
		rpl.wind_pushing_player   = false;
	}
	
	thread maps\cornered_audio::aud_do_wind( rpl.wind_state );
}

cnd_rpl_do_rope( rpl, rappel_params )
{
	if ( rappel_params.rappel_type == "inverted" )
		return;
	
	// this will happen when the rope needs to be under automatic control rather than scripted control
	if ( !IsDefined( level.rpl_physical_rope_origin ) )
		return;
	
	// Extend the rope based on the player's vertical change
	if ( abs( rpl.vertical_change_this_update ) > 0 )
	{
		one_unit_anim_time = 1.0 / rpl.player_rope_unwind_length; // how much time to scrub for 1 unit
		current_time = level.cnd_rappel_tele_rope GetAnimTime( rpl.player_rope_unwind_anim );
		next_time = current_time + ( -1 * rpl.vertical_change_this_update * one_unit_anim_time );
		next_time = clamp( next_time, 0, 0.9999 ); // can not set it directly to 1
		level.cnd_rappel_tele_rope SetAnimTime( rpl.player_rope_unwind_anim, next_time );
	}
	
	// Rotate the rope
	if ( abs( rpl.lateral_change_this_update ) > 0 )
	{
//		level.rpl_physical_rope_origin.angles += ( 0, 0, rpl.lateral_change_this_update );
		level.rpl_physical_rope_origin RotateRoll( rpl.lateral_change_this_update, rpl.time_slice, 0, 0 );
	}
	
	if ( rpl.jumping )
		return;
	
	started_running = rpl.move_state == rpl.MOVE_STATE_LOOP_RUN && rpl.last_move_state != rpl.MOVE_STATE_LOOP_RUN;
	stopped_running = rpl.move_state != rpl.MOVE_STATE_LOOP_RUN && rpl.last_move_state == rpl.MOVE_STATE_LOOP_RUN;
	
	wind_blowing = rpl.wind_state == "up" || rpl.wind_state == "down" || rpl.wind_state == "steady" || rpl.wind_state == "strong";
	wind_starting = rpl.wind_state == "up" && rpl.wind_last_state != "up";
	wind_idle = rpl.wind_state == "calm";
	wind_stopped = rpl.wind_state == "stop" && level.cnd_rappel_player_rope GetAnimWeight( %cnd_rappel_wind_shake_rope_player ) > 0;
	constant_wind_stength = 0.06;
	rope_lag_r_time = level.cnd_rappel_player_rope GetAnimTime( %cnd_rappel_lag_r_rope_player );
	rope_lag_l_time = level.cnd_rappel_player_rope GetAnimTime( %cnd_rappel_lag_l_rope_player );
	rope_stop_shake_time = level.cnd_rappel_player_rope GetAnimTime( %cnd_rappel_shake_rope_player );
	rope_jump_shake_time = level.cnd_rappel_player_rope GetAnimTime( %cnd_rappel_jump_shake_rope_player );
	rope_lagging_r = rope_lag_r_time > 0 && rope_lag_r_time < 1;
	rope_lagging_l = rope_lag_l_time > 0 && rope_lag_l_time < 1;
	rope_stop_shaking = rope_stop_shake_time > 0 && rope_stop_shake_time < 1;
	rope_jump_shaking = rope_jump_shake_time > 0 && rope_jump_shake_time < 1;
	no_wind = rope_lagging_r || rope_lagging_l || rope_stop_shaking || rope_jump_shaking;
	
	// Play additive animations on the rope
	if ( started_running )
	{
		if ( rpl.stop_anim_direction == "left" )
			level.cnd_rappel_player_rope SetAnimKnobRestart( %cnd_rappel_lag_l_rope_player, 1, 0.2, 1 );
		else
			level.cnd_rappel_player_rope SetAnimKnobRestart( %cnd_rappel_lag_r_rope_player, 1, 0.2, 1 );
	}
	else if ( stopped_running )
	{
		// Play additive rope jiggle animation when player stops after running
		level.cnd_rappel_player_rope SetAnimKnobRestart( %cnd_rappel_shake_rope_player, 1, 0.2, 1 );
	}
	else if ( no_wind )
	{
		// do nothing
	}
	else if ( wind_starting )
	{
		level.cnd_rappel_player_rope SetAnimKnob( %cnd_rappel_wind_shake_rope_player, 1.0, 0.2, rpl.wind_strength );
	}
	else if ( wind_blowing )
	{
		level.cnd_rappel_player_rope SetAnimKnob( %cnd_rappel_wind_shake_rope_player, 1.0, 0.2, rpl.wind_strength );
	}
	else if ( wind_stopped )
	{
		level.cnd_rappel_player_rope SetAnimKnob( %cnd_rappel_idle_rope_player_add, 1.0, 0.2, 1.0 );
	}
	else if ( wind_idle )
	{
		level.cnd_rappel_player_rope SetAnimKnob( %cnd_rappel_wind_shake_rope_player, 1.0, 0.2, constant_wind_stength );
	}
}

cnd_rpl_do_weapon_bob( rpl, rappel_params )
{
	// ***********************
	// * Weapon bob			 *
	// ***********************
	
	// calculate the movement percentage in each direction to aid with animation rates & weapon bob
	rpl.down_leg_move_percent 	= abs( rpl.vertical_change_this_update ) / rpl_get_max_downward_speed();
	rpl.up_leg_move_percent 	= abs( rpl.vertical_change_this_update ) / rpl_get_max_upward_speed();
	if ( rpl.max_rotation_speed > 0 )
		rpl.horz_leg_move_percent 	= abs( rpl.lateral_change_this_update ) / ( rpl.max_rotation_speed * rpl.time_slice );
	else
		rpl.horz_leg_move_percent = 0;
	
	TARGET_BOB_SPEED = 22.4;
	
	if ( rpl.jumping )
	{
		// no weapon bob
		if ( rpl.bg_weaponBobAmplitudeBase != 0 )
		{
			SetSavedDvar( "bg_weaponBobAmplitudeBase", 0 );  // 0.16 is the original value
			SetSavedDvar( "g_speed", 0 );
			rpl.bg_weaponBobAmplitudeBase = 0;
		}
	}
	else if ( abs( rpl.vertical_change_this_update ) > 0 || abs( rpl.lateral_change_this_update ) > 0 )
	{
		MAX_AMP_CHANGE		= 0.05;
		MAX_SPEED_CHANGE	= 5;

		if ( sign( rpl.vertical_change_this_update ) == -1 )
		{
			verticalWeaponBobAmplitudeBase = TARGET_BOB_SPEED / rappel_vertical_speed_to_world_units( rpl_get_max_downward_speed() ); // 22.4 / 60 = 0.37 (for stealth rappel)
			verticalMaxSpeedForBob = rappel_vertical_speed_to_world_units( rpl_get_max_downward_speed() ) + 40;
		}
		else
		{
			verticalWeaponBobAmplitudeBase = TARGET_BOB_SPEED / rappel_vertical_speed_to_world_units( rpl_get_max_upward_speed() ); // 22.4 / 40 = 0.56 (for stealth rappel)
			verticalMaxSpeedForBob = rappel_vertical_speed_to_world_units( rpl_get_max_upward_speed() ) + 40;
		}
		
		lateralWeaponBobAmplitudeBase = TARGET_BOB_SPEED / rappel_lateral_speed_to_world_units( rpl_get_max_lateral_speed() ); // 22.4 / 140 = 0.16 (for stealth rappel)
		lateralMaxSpeedForBob = rappel_lateral_speed_to_world_units( rpl_get_max_lateral_speed() );
		lateralPercent = 1;
		verticalPercent = 0;
		
		if ( rappel_params.rappel_type == "inverted" )
			verticalPercent = rpl.down_leg_move_percent;
		else
			lateralPercent = rpl.horz_leg_move_percent;
		
		if ( abs( rpl.vertical_change_this_update ) == 0 )
			lateralPercent = 1.0;
		else if ( abs( rpl.lateral_change_this_update ) == 0 )
			lateralPercent = 0.0;
			
		if ( rappel_params.rappel_type == "inverted" )
			lateralPercent = 1 - verticalPercent;
		else
			verticalPercent = 1 - lateralPercent;
		
		weaponBobAmplitudeBase = verticalWeaponBobAmplitudeBase * verticalPercent + lateralWeaponBobAmplitudeBase * lateralPercent;
		maxSpeedForBob = verticalMaxSpeedForBob * verticalPercent + lateralMaxSpeedForBob * lateralPercent;
		
		currentWeaponBobAmplitudeBase = rpl.bg_weaponBobAmplitudeBase;
		currentMaxSpeedForBob = rpl.g_speed;
		
		diffAmp = weaponBobAmplitudeBase - currentWeaponBobAmplitudeBase;
		if ( abs( diffAmp ) > MAX_AMP_CHANGE )
			weaponBobAmplitudeBase = currentWeaponBobAmplitudeBase + ( sign( diffAmp ) * MAX_AMP_CHANGE );
			
		diffSpeed = maxSpeedForBob - currentMaxSpeedForBob;
		if ( abs( diffSpeed ) > MAX_SPEED_CHANGE )
			maxSpeedForBob = currentMaxSpeedForBob + ( sign( diffSpeed ) * MAX_SPEED_CHANGE );
		
		if ( rpl.g_speed != maxSpeedForBob )
		{
			SetSavedDvar( "g_speed", maxSpeedForBob ); // original: 190 (normal ground speed )
			rpl.g_speed = maxSpeedForBob;
		}
		
		// change the player's maximum speed so the bob cycle goes faster
		if ( rpl.bg_weaponBobAmplitudeBase != weaponBobAmplitudeBase )
		{
			SetSavedDvar( "bg_weaponBobAmplitudeBase", weaponBobAmplitudeBase );  // 0.16 is the original value
			rpl.bg_weaponBobAmplitudeBase = weaponBobAmplitudeBase;
		}
	}
	
//	PrintLn( "** lateral:   " + rpl.lateral_change_this_update );
//	PrintLn( "** vertical:  " + rpl.vertical_change_this_update );
//	PrintLn( "** lateralp:  " + rpl.horz_leg_move_percent );
//	PrintLn( "** verticalp: " + (1 - rpl.horz_leg_move_percent) );
//	PrintLn( "** bob amp:   " + GetDvarFloat( "bg_weaponBobAmplitudeBase" ) );
//	PrintLn( "** g_speed:   " + GetDvarFloat( "g_speed" ) );
//	PrintLn( "******************************" );
}

cnd_rpl_do_move_bob( rpl, rappel_params )
{
	// ***********************
	// * Player movement bob *
	// ***********************
	bob_anim_horz 	= %rappel_movement_player_bob;
	bob_anim_vert 	= %rappel_movement_player_bob_descend;
	bob_rate	  	= 4.0;
	
	bMoving			= abs( rpl.lateral_change_this_update ) > 0.1 || abs( rpl.vertical_change_this_update ) > 0.1;
	bMovingOnlyHorz = abs( rpl.lateral_change_this_update ) > 0.1 && abs( rpl.vertical_change_this_update ) < 0.1;
	bMovingOnlyVert = abs( rpl.lateral_change_this_update ) < 0.1 && abs( rpl.vertical_change_this_update ) > 0.1;
	
	// disable programmatic view bob during jump
	if ( rpl.jumpComplete && rpl.bg_viewBobMax == 0 )
	{
		SetSavedDvar( "bg_viewBobMax", 8 ); // original: 8 (programmatic view bob)
		rpl.bg_viewBobMax = 8;
	}
	else if ( !rpl.jumpComplete && rpl.bg_viewBobMax == 8 )
	{
		SetSavedDvar( "bg_viewBobMax", 0 ); // original: 8 (programmatic view bob)
		rpl.bg_viewBobMax = 0;
	}
	
	if ( bMoving && rpl.jumpComplete && !rpl.glass_broken_under_player )
	{
		rpl.clearing_bob_anim = false;
		
		bob_anim = bob_anim_horz;
		other_bob_anim = bob_anim_vert;
		if ( bMovingOnlyVert )
		{
			bob_anim = bob_anim_vert;
			other_bob_anim = bob_anim_horz;
		}
			
		bobscale = 0.7;
		if ( level.player GetStance() == "crouch" )
		{
			bobscale = 0.5;
		}
		
		// Percentage of full horizontal movement, from 0 - 1
		if ( rpl.max_rotation_speed > 0 )
			avg_move_horz = abs( rpl.lateral_change_this_update ) / ( rpl.max_rotation_speed * rpl.time_slice );
		else
			avg_move_horz = 0;
		
		// Percentage of full vertical movement, from 0 - 1 then scaled by half (so the animation will play slower while descending)
		avg_move_vert = ( abs( rpl.vertical_change_this_update ) / rpl_get_max_downward_speed() ) * 0.45;
		
		// Percent of full movement, for scaling the bob anim
		avg_move = max( avg_move_horz, avg_move_vert );
		
		// weight is the absolute scale times the percentage of full movement, but must be at least 0.01
		bob_anim_weight = max( 0.01, ( bobscale * avg_move ) );
		
		if ( rpl_get_max_downward_speed() > 10 )
		{
			// Moving downwards very fast, so increase the weight
			bob_anim_weight = 1.0;
		}
		
		// rate is the absolute rate times the percentage of full movement
		rate = bob_rate * avg_move;

		// Play bob animation
		if ( rate > 0 )
			rpl.player_anim_origin SetFlaggedAnim( "bobanim", bob_anim, bob_anim_weight, 0.15, rate );
		else
			rpl.player_anim_origin ClearAnim( bob_anim, 0.2 );
		
		rpl.player_anim_origin ClearAnim( other_bob_anim, 0.2 );
		
		// Loop it
		if ( rpl.player_anim_origin GetAnimTime( bob_anim ) == 1 )
			rpl.player_anim_origin SetAnimTime( bob_anim, 0 );
	}
	else if ( !rpl.clearing_bob_anim && IsDefined( rpl.last_bob_anim ) )
	{
		// Clear bob animation if not moving or if jumping
		rpl.clearing_bob_anim = true;
		
		rpl.player_anim_origin ClearAnim( bob_anim_horz, 0.2 );
		rpl.player_anim_origin ClearAnim( bob_anim_vert, 0.2 );
	}
}

cnd_rpl_legs_notetracks( rpl, notetrack_foot_left, notetrack_foot_right )
{
	while ( true )
	{
		level.rappel_player_legs waittill( rpl.legs_flag_name, note );

		if ( !isDefined( note ) )
			continue;

		if ( note == notetrack_foot_left )
			rpl.current_foot = "left";
		else if ( note == notetrack_foot_right )
			rpl.current_foot = "right";
		
		if (note == "ps_step_run_plr_rappel")
		{
			thread maps\cornered_audio::aud_rappel( "foot" );
		}
		
//		PrintLn( "Foot notetrack: " + note );
	}
}

cnd_rpl_do_legs( rpl, rappel_params )
{
	// ***************
	// * Player legs *
	// ***************
/#
	run_debug_anim_blender = rpl_legs_debug_anim_blender( rpl, rappel_params );
	if ( run_debug_anim_blender )
		return;
#/
	
	if ( !rappel_use_plyr_legs( rappel_params ) || !IsDefined( level.rappel_player_legs ) )
		return;
	
	rpl_legs_set_anim_move_strength( rpl );
	rpl.cur_move_vect_norm = VectorNormalize( ( rpl.anim_right_move_strength, rpl.anim_down_move_strength, 0 ) );
	player_trying_to_move = abs(rpl.anim_down_move_strength) > 0 || abs(rpl.anim_right_move_strength) > 0;
	rpl.last_move_vect_norm = rpl.cur_move_vect_norm;
	rpl.last_move_state = rpl.move_state;
		
	if ( rpl.jumping && rpl.move_state != rpl.MOVE_STATE_JUMP )
	{
		rpl.move_state = rpl.MOVE_STATE_JUMP;
	}
	
	if ( rpl.move_state == rpl.MOVE_STATE_IDLE )
	{
//		direction = rpl_legs_idle_transition( rpl );
		if ( player_trying_to_move && rpl_legs_is_idle_ready( rpl ) )
		{
			rpl.move_state = rpl.MOVE_STATE_START;
		}
//		else if ( !player_trying_to_move && direction == "forward" && IsDefined( rpl.idle_transition_direction ) )
//		{
//			rpl.move_state = rpl.MOVE_STATE_SHIFT_BACK;
//		}
//		else if ( GetDvar( "rappel_use_idle_transitions" ) == "1" && !player_trying_to_move && direction != "none" && direction != "forward" )
//		{
//			rpl.idle_transition_direction = direction;
//			rpl.move_state = rpl.MOVE_STATE_IDLE_SHIFT;
//		}
	}
//	else if ( rpl.move_state == rpl.MOVE_STATE_IDLE_SHIFT )
//	{
//		state_complete = rpl_legs_is_idle_transition_state_complete( rpl );
//		
//		if ( player_trying_to_move )
//		{
//			rpl.move_state = rpl.MOVE_STATE_START;
//		}		
//		else if ( state_complete )
//		{
//			rpl.move_state = rpl.MOVE_STATE_IDLE;
//		}
//	}
//	else if ( rpl.move_state == rpl.MOVE_STATE_SHIFT_BACK )
//	{
//		state_complete = rpl_legs_is_transition_back_state_complete( rpl );
//		
//		if ( player_trying_to_move )
//		{
//			rpl.move_state = rpl.MOVE_STATE_START;
//		}		
//		else if ( state_complete )
//		{
//			rpl.move_state = rpl.MOVE_STATE_IDLE;
//			rpl.idle_transition_direction = undefined;
//		}
//	}
	else if ( rpl.move_state == rpl.MOVE_STATE_JUMP )
	{
		if ( !rpl.jumping )
			rpl.move_state = rpl.MOVE_STATE_IDLE;
	}
	else if ( rpl.move_state == rpl.MOVE_STATE_START )
	{
//		rpl.idle_transition_direction = undefined;
		state_complete = rpl_legs_is_start_state_complete( rpl, player_trying_to_move );
		
		if ( state_complete && player_trying_to_move )
		{
			rpl.move_state = rpl.MOVE_STATE_LOOP;
		}
		else if ( !player_trying_to_move )
		{
			rpl.move_state = rpl.MOVE_STATE_IDLE;
		}
	}
	else if ( rpl.move_state == rpl.MOVE_STATE_STOP )
	{
		state_complete = rpl_legs_is_stop_state_complete( rpl );
		if ( state_complete && !player_trying_to_move )
		{
			rpl.move_state = rpl.MOVE_STATE_IDLE;
		}
		else if ( player_trying_to_move )
		{
			rpl.move_state = rpl.MOVE_STATE_LOOP;
		}
	}
	else if ( rpl.move_state == rpl.MOVE_STATE_LOOP_RUN )
	{
		changing_direction = rpl_legs_is_loop_state_changing_direction( rpl, player_trying_to_move );
		should_be_running = rpl_legs_should_use_run_loop( rpl );
		travel_horizontal = rpl_legs_traveling_horizontal( rpl, player_trying_to_move );
		
		if ( !player_trying_to_move )
		{
			rpl.move_state = rpl.MOVE_STATE_STOP;
		}
		else if ( changing_direction )
		{
			rpl.move_state = rpl.MOVE_STATE_IDLE;
		}
		else if ( !should_be_running || !travel_horizontal )
		{
			rpl.move_state = rpl.MOVE_STATE_LOOP;
		}
	}
	else // Loop state
	{
		changing_direction = rpl_legs_is_loop_state_changing_direction( rpl, player_trying_to_move );
		should_be_running = rpl_legs_should_use_run_loop( rpl );
		travel_horizontal = rpl_legs_traveling_horizontal( rpl, player_trying_to_move );
		if ( !player_trying_to_move )
		{
//			rpl.move_state = rpl.MOVE_STATE_IDLE;
			rpl.move_state = rpl.MOVE_STATE_STOP; // disable general stops for now (if enabled remove long blend in rpl_legs_get_clear_blend_time)
		}
		else if ( changing_direction )
		{
			rpl.move_state = rpl.MOVE_STATE_IDLE;
		}
		else if ( should_be_running && travel_horizontal )
		{
			rpl.move_state = rpl.MOVE_STATE_LOOP_RUN;
		}
	}
	
	plyr_rappel_legs_set_origin( rpl );
	
	if ( IsDefined( rappel_params.allow_sprint ) && rappel_params.allow_sprint )
		level.player AllowSprint( !rpl.jumping && rpl_legs_traveling_horizontal( rpl, player_trying_to_move ) );
		
	rpl_legs_process_state( rpl );
}

rpl_legs_is_idle_ready( rpl )
{
	idle_anim = rpl_legs_get_idle_anim( rpl );
	weight = level.rappel_player_legs GetAnimWeight( idle_anim );
	if ( weight >= 0.4 )
		return true;
	 
	return false;
}

rpl_legs_set_anim_move_strength( rpl )
{
	rpl.anim_right_move_strength = rpl.right_move_strength;
	if ( abs( rpl.lateral_change_this_update ) < 0.01 )
		rpl.anim_right_move_strength = 0;
	
	rpl.anim_down_move_strength = rpl.down_move_strength;
	if ( abs( rpl.vertical_change_this_update ) < 0.01 )
		rpl.anim_down_move_strength = 0;
}

rpl_legs_process_state( rpl )
{
	transitioning_states = rpl.last_move_state != rpl.move_state;
	
	if ( rpl.move_state == rpl.MOVE_STATE_IDLE )
	{
		rpl_legs_set_idle( rpl );
		if ( transitioning_states )
		{
//			rpl_legs_clear_unused_idle_anims( rpl );
//			rpl_legs_clear_all_idle_transition_anims( rpl );
			rpl_legs_clear_all_move_anims( rpl );
			rpl.was_running = undefined;
		}
	}
//	else if ( rpl.move_state == rpl.MOVE_STATE_IDLE_SHIFT )
//	{
//		rpl_legs_set_idle_transition( rpl );
//		if ( transitioning_states )
//		{
//			rpl_legs_clear_all_idle_anims( rpl );
//			rpl_legs_clear_all_move_anims( rpl );
//		}
//	}
//	else if ( rpl.move_state == rpl.MOVE_STATE_SHIFT_BACK )
//	{
//		rpl_legs_set_transition_back( rpl );
//		if ( transitioning_states )
//		{
//			rpl_legs_clear_all_idle_anims( rpl );
//			rpl_legs_clear_all_move_anims( rpl );
//		}
//	}
	else if ( rpl.move_state == rpl.MOVE_STATE_JUMP )
	{
		if ( transitioning_states )
		{
			rpl_legs_clear_all_idle_anims( rpl );
//			rpl_legs_clear_all_idle_transition_anims( rpl );
			rpl_legs_clear_all_move_anims( rpl );
		}
	}
	else if ( rpl.move_state == rpl.MOVE_STATE_START || rpl.move_state == rpl.MOVE_STATE_STOP )
	{
		restart_anim = false;
		
		// if the start/stop animation is not blended out from previously, restart it
		if ( transitioning_states )
		{
			restart_anim = true;
			
			if ( rpl.move_state == rpl.MOVE_STATE_STOP && GetDvarInt( "rappel_use_stop_momentum" ) == 1 )
			{
				rpl.stop_momentum = GetDvarFloat( "rappel_stop_momentum_initial" ) * sign( rpl.lateral_change_this_update );
				num_seconds = GetDvarFloat( "rappel_stop_momentum_time" );
				rpl.stop_momentum_change = rpl.stop_momentum / ( num_seconds * 20.0 );
			}
			
			if ( rpl.move_state == rpl.MOVE_STATE_STOP )
			{
				rpl.was_running = rpl.last_move_state == rpl.MOVE_STATE_LOOP_RUN;
				rpl.begin_sway = true;
			}
			else
			{
				rpl.was_running = undefined;
			}
		}

		if ( rpl.move_state == rpl.MOVE_STATE_STOP )
		{
			direction = rpl.stop_anim_direction;
		}
		else
		{
			direction = rpl_legs_get_start_move_direction( rpl );
			rpl.last_start_anim_direction = direction;
			rpl.stop_anim_direction = direction;
		}

		current_directions = [];
		current_directions[direction] = 1.0;
		
		anim_type = rpl_legs_get_anim_type( rpl );
		
		direction_anim = rpl_get_state_anim( rpl, anim_type, direction );
		weight = 1.0;
		blend_time = rpl_legs_get_blend_time( rpl, anim_type, direction );
		animation_rate = rpl_legs_get_animation_rate( rpl, direction, anim_type );
		rpl.move[direction].playing = true;
		
		rpl_legs_set_anim( direction_anim, weight, blend_time, animation_rate, restart_anim, rpl.legs_flag_name );
		
		if ( transitioning_states )
		{
			rpl_legs_clear_anim( rpl.legs_move_parent_node, rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_PARENT, undefined ) );
			rpl_legs_clear_unused_anims( rpl, current_directions );
		}
	}
	else // Loop or Loop Run States
	{
		// use movement strengths to calculate animation direction and weights
		is_run_state = rpl.move_state == rpl.MOVE_STATE_LOOP_RUN;
		current_directions = rpl_legs_get_move_directions( rpl, is_run_state );
		weights = rpl_legs_get_direction_weights( current_directions );
		// save the current direction for when the player releases the stick
		rpl.stop_anim_direction = rpl_legs_get_stop_move_direction( rpl );
		changed_directions = rpl_legs_changed_directions( rpl, current_directions );
			
		all_direction_keys = GetArrayKeys( rpl.move );
		foreach ( direction in all_direction_keys )
		{
			if ( IsDefined( current_directions[ direction ] ) )
			{
				anim_type = rpl_legs_get_anim_type( rpl );
				direction_anim = rpl_get_state_anim( rpl, anim_type, direction );
				weight = weights[ direction ];
				blend_time = rpl_legs_get_blend_time( rpl, anim_type, direction );
				animation_rate = rpl_legs_get_animation_rate( rpl, direction, anim_type );
				rpl.move[direction].playing = true;
				rpl_legs_set_anim( direction_anim, weight, blend_time, animation_rate, false, rpl.legs_flag_name );
			}
		}

		if ( transitioning_states || changed_directions )
			rpl_legs_clear_unused_anims( rpl, current_directions );
		
		if ( transitioning_states )
			rpl.current_foot = "left";
	}
}

rpl_legs_changed_directions( rpl, current_directions )
{
	direction_keys = GetArrayKeys( current_directions );
	foreach ( direction in direction_keys )
	{
		if ( !rpl.move[direction].playing )
			return true;
	}
	
	return false;
}

//rpl_legs_shift_body_direction( rpl )
//{
//	shift_yaw = 60;
//	
//	player_yaw = AngleClamp180( level.player GetPlayerAngles()[1] );
//					
//	if ( player_yaw > shift_yaw )
//		return "left";
//	else if ( player_yaw < (-1 * shift_yaw) )
//		return "right";
//	else
//		return "forward";	
//}
//
//rpl_legs_idle_transition( rpl )
//{
//	direction = rpl_legs_shift_body_direction( rpl );
//		
//	if ( IsDefined( rpl.idle_transition_direction ) && direction != rpl.idle_transition_direction )
//		return direction;
//	else if ( IsDefined( rpl.idle_transition_direction ) )
//		return "none";
//	else
//		return direction;
//}

rpl_legs_should_use_run_loop( rpl )
{
	loop_run_transition_speed_percent = 0.8;
	
	// if we are not at full movement, do not use run loop
	if ( rpl.horz_leg_move_percent < loop_run_transition_speed_percent )
		return false;
	
	return true;
}

rpl_legs_traveling_horizontal( rpl, player_trying_to_move )
{
	if ( !player_trying_to_move )
		return false;

	// if we are not mostly going left/right then do not use run loop
	current_directions = rpl_legs_get_move_directions( rpl, true );
	assert( current_directions.size == 1 );
	direction_keys = GetArrayKeys( current_directions );
	if ( _rpl_legs_is_horizontal( direction_keys[0] ) )
		return true;
	
	return false;
}

//rpl_legs_is_idle_transition_state_complete( rpl )
//{
//	idle_transition_anim = rpl_legs_get_transition_anim( rpl.idle_transition_direction );
//	animation_time = level.rappel_player_legs GetAnimTime( idle_transition_anim );
//	if ( animation_time < 1.0 )
//		return false;
//	return true;
//}
//
//rpl_legs_is_transition_back_state_complete( rpl )
//{
//	transition_back_anim = rpl_legs_get_transition_back_anim( rpl.idle_transition_direction );
//	animation_time = level.rappel_player_legs GetAnimTime( transition_back_anim );
//	if ( animation_time < 1.0 )
//		return false;
//	return true;
//}

rpl_legs_is_loop_state_changing_direction( rpl, player_trying_to_move )
{
	vec_dot = VectorDot( rpl.last_move_vect_norm, rpl.cur_move_vect_norm );
	if ( vec_dot <= rpl.cosine90 )
		return true;
		
	return false;
}

rpl_legs_is_start_state_complete( rpl, player_trying_to_move )
{	
	// two ways the state can be complete, either the player is trying to go in a different direction or the animation is finished
	if ( player_trying_to_move )
	{
		current_direction = rpl_legs_get_start_move_direction( rpl );
		previous_directions = rpl_legs_get_previous_move_directions( rpl );
		previous_direction = previous_directions[0];
		if ( IsDefined( previous_direction ) && current_direction != previous_direction )
			return true;
	}
		
	direction_keys = GetArrayKeys( rpl.move );
	foreach ( direction in direction_keys )
	{
		anim_type = rpl_legs_get_anim_type( rpl );
		direction_anim = rpl_get_state_anim( rpl, anim_type, direction );
		animation_time = level.rappel_player_legs GetAnimTime( direction_anim );
		if ( animation_time > 0 && animation_time < rpl.state_anim_percent_complete )
			return false;
	}

	return true;
}

rpl_legs_is_stop_state_complete( rpl )
{
	anim_type = rpl_legs_get_anim_type( rpl );
	direction_anim = rpl_get_state_anim( rpl, anim_type, rpl.stop_anim_direction );
	animation_time = level.rappel_player_legs GetAnimTime( direction_anim );
	return animation_time == 1;
}

rpl_legs_get_previous_move_directions( rpl )
{
	closest_directions = [];
	
	direction_keys = GetArrayKeys( rpl.move );
	foreach ( direction in direction_keys )
	{
		if ( rpl.move[direction].playing )
			closest_directions[closest_directions.size] = direction;
	}
	
	assert( closest_directions.size > 0 && closest_directions.size <= 2 );
	
	return closest_directions;
}

rpl_legs_get_animation_rate( rpl, direction, anim_type )
{
	if ( anim_type == rpl.ANIMTYPE_STOP || anim_type == rpl.ANIMTYPE_RUN_STOP )
		return 1.0;
		
	// Move up - 				Actual Speed =  25 units/sec -- while Anim speed = 39 units/sec so scale to 0.77 at max speed.
	// Move Down - 				Actual Speed =  60 units/sec -- while Anim speed = 30 units/sec so scale to 2.0 at max speed.
	// Move Left and Right -	Actual Speed = 140 units/sec -- while Anim speed = 40 units/sec so we should let the walk get up to 1.5 play speed before we switch to the run
	// Move Up left 										 –- while Anim speed = 42 units/sec 
	// Move Up right 										 –- while Anim speed = 39 units/sec
	// Move Down left 										 –- while Anim speed = 31 units/sec
	// Move Down right 										 –- while Anim speed = 34 units/sec
	
	animation_scale_move_horizontal	= GetDvarFloat( "rappel_legs_scale_horizontal" );
	animation_scale_move_up			= GetDvarFloat( "rappel_legs_scale_up" );
	animation_scale_move_down		= GetDvarFloat( "rappel_legs_scale_down" );
		
	if ( anim_type == rpl.ANIMTYPE_LOOP_RUN )
		animation_scale_move_horizontal = GetDvarFloat( "rappel_legs_scale_run" );
	
	if ( direction == "down" )
	{
		return rpl.down_leg_move_percent * animation_scale_move_down;
	}
	else if ( direction == "up" )
	{
		return rpl.up_leg_move_percent * animation_scale_move_up;
	}
	else if ( direction == "left" || direction == "right" )
	{
		return rpl.horz_leg_move_percent * animation_scale_move_horizontal;
	}
	else if ( direction == "left_down" || direction == "right_down" )
	{
		diagonal_move_percent = Length( ( rpl.horz_leg_move_percent, rpl.down_leg_move_percent, 0 ) );
		animation_scale_diagonal = animation_scale_move_down;
		
		return diagonal_move_percent * animation_scale_diagonal;
	}
	else // "left_up" ||  "right_up":
	{
		diagonal_move_percent = Length( ( rpl.horz_leg_move_percent, rpl.up_leg_move_percent, 0 ) );
		animation_scale_diagonal = animation_scale_move_up;
		
		return diagonal_move_percent * animation_scale_diagonal;
	}
}

rpl_legs_get_direction_weights( closest_directions )
{
	assert( closest_directions.size > 0 && closest_directions.size <= 2 );
	
	direction_keys = GetArrayKeys( closest_directions );
	
	sum = 0;
	foreach ( direction in direction_keys )
		sum += closest_directions[ direction ];
		
	weights = [];
	foreach ( direction in direction_keys )
		weights[ direction ] = closest_directions[ direction ] / sum;
		
	return weights;
}

_rpl_legs_is_diagonal( direction )
{
	return direction == "left_up" || direction == "left_down" || direction == "right_up" || direction == "right_down";
}

_rpl_legs_is_horizontal( direction )
{
	return direction == "left" || direction == "right";
}

rpl_legs_get_start_move_direction( rpl )
{
	closest_directions = [];
	diagonal = undefined;
	
	// find the one closest direction for the start animation since this will not be blended
	direction_keys = GetArrayKeys( rpl.move );
	foreach ( direction in direction_keys )
	{
		vec_dot = VectorDot( rpl.cur_move_vect_norm, rpl.move[direction].vector );
		
		if ( vec_dot <= rpl.cosine22_5 )
			continue;
		
		if ( _rpl_legs_is_diagonal( direction ) )
			diagonal = direction;
		
		closest_directions[closest_directions.size] = direction;
	}
	
	assert( closest_directions.size > 0 && closest_directions.size <= 2 );
	
	// if perfectly between two directions just drop the diagonal
	if ( closest_directions.size == 2 )
		closest_directions = array_remove( closest_directions, diagonal );
	
	return closest_directions[0];
}

rpl_legs_get_stop_move_direction( rpl )
{
	current_directions = rpl_legs_get_move_directions( rpl, true );
	assert( current_directions.size == 1 );
	
	direction_keys = GetArrayKeys( current_directions );
	return direction_keys[0];
}

rpl_legs_get_move_directions( rpl, filter_for_run_move_state )
{
	closest_directions = [];
	
	// find the one or two animation directions we will blend to next since we are within 45 degrees of at most two of the eight directions
	direction_keys = GetArrayKeys( rpl.move );
	foreach ( direction in direction_keys )
	{
		vec_dot = VectorDot( rpl.cur_move_vect_norm, rpl.move[direction].vector );
		
		// if it is not within 45 degrees of the movement vector then it is not a valid direction
		if ( vec_dot <= rpl.cosine45 )
			continue;
		
		closest_directions[direction] = vec_dot;
	}
	
	assert( closest_directions.size > 0 && closest_directions.size <= 2 );
	
	// if we are within 15 degrees to any anim direction just use it directly rather than blending the two 
	if ( closest_directions.size == 2 )
	{
		within_no_blend_range_dirs = [];
		
		direction_keys = GetArrayKeys( closest_directions );
		foreach ( direction in direction_keys )
		{
			vec_dot = closest_directions[direction];
			
			// if the movement direction is not within 15 degrees of the direction, just blend the two directions
			if ( vec_dot <= rpl.cosine15 )
				continue;
			
			within_no_blend_range_dirs[direction] = vec_dot;		
		}
		
		assert( within_no_blend_range_dirs.size == 0 || within_no_blend_range_dirs.size == 1 );
		
		if ( within_no_blend_range_dirs.size == 1 )
			return within_no_blend_range_dirs;
	}
	
	// special case: because of the crossing legs the blend between left & down/left as well as right and down/right
	// will have feet on top of each other, instead play the left or right
	if ( closest_directions.size == 2 )
	{
		direction_keys = GetArrayKeys( closest_directions );
		if ( array_contains( direction_keys, "left" ) && array_contains( direction_keys, "left_down" ) )
			closest_directions["left_down"] = undefined;
		else if ( array_contains( direction_keys, "right" ) && array_contains( direction_keys, "right_down" ) )
			closest_directions["right_down"] = undefined; 
	}
					
	// special case: if we are in the running state that means we are mostly moving right or left so just use that direction rather than blending
	if ( closest_directions.size == 2 && filter_for_run_move_state )
	{
		closest_directions["left_down"] = undefined;
		closest_directions["right_down"] = undefined;
		closest_directions["left_up"] = undefined;
		closest_directions["right_up"] = undefined;
	}
	
	return closest_directions;
}
					
rpl_legs_get_blend_time( rpl, anim_type, direction )
{
	// if playing a looping anim and we're blending out of a start animation that is close to complete then blend quickly
	if ( anim_type == rpl.ANIMTYPE_LOOP || anim_type == rpl.ANIMTYPE_LOOP_RUN )
	{
		if ( rpl_legs_is_state_direction_anim_complete( rpl, rpl.ANIMTYPE_START, direction ) )
			return rpl.leg_anim_blend_time_fast;
	}
	
	return rpl.leg_anim_blend_time;
}
					
rpl_legs_get_clear_blend_time( rpl, anim_type, direction )
{
	if ( rpl.move_state == rpl.MOVE_STATE_JUMP )
	{
		return rpl.leg_jump_anim_blend_time;
	}
	else if ( anim_type == rpl.ANIMTYPE_START )
	{
		// if we are on the start state and clearing some other start anim, we don't want it to play at the same time so let it snap out quick
		if ( rpl.move_state == rpl.MOVE_STATE_START )
			return rpl.leg_clear_anim_blend_time_fast; //return 0;
	}
	else if ( anim_type == rpl.ANIMTYPE_LOOP || anim_type == rpl.ANIMTYPE_LOOP_RUN || anim_type == rpl.ANIMTYPE_PARENT )
	{
		// for now we are not using stops and just blending to idle so blend at the same time as idle to make it looks smoother, remove if we add non run stops
		if ( rpl.move_state == rpl.MOVE_STATE_IDLE )
			return rpl.leg_idle_anim_blend_time;
		// if we well into the start state, clear out the looping anims completely
		if ( rpl.move_state == rpl.MOVE_STATE_START && rpl_legs_is_start_anim_ready_to_blend_out_loops( rpl, rpl.last_start_anim_direction ) )
			return 0;
	}
					
	return rpl.leg_clear_anim_blend_time;	
}
				
rpl_legs_is_start_anim_ready_to_blend_out_loops( rpl, direction )
{
	state_anim_percent_half = 0.5;
	direction_anim = rpl_get_state_anim( rpl, rpl.ANIMTYPE_START, direction );
	animation_time = level.rappel_player_legs GetAnimTime( direction_anim );
	if ( animation_time >= state_anim_percent_half )
		return true;
	
	return false;	
}
				
rpl_legs_is_state_direction_anim_complete( rpl, anim_type, direction )
{
	direction_anim = rpl_get_state_anim( rpl, anim_type, direction );
	animation_time = level.rappel_player_legs GetAnimTime( direction_anim );
	animation_weight = level.rappel_player_legs GetAnimWeight( direction_anim );
	if ( animation_time >= rpl.state_anim_percent_complete && animation_weight > 0 )
		return true;
	
	return false;
}
					
//rpl_legs_clear_unused_idle_anims( rpl )
//{
//	if ( IsDefined( rpl.idle_transition_direction ) )
//	{
//		idle_forward = rpl.legs_idle_anim;
//		rpl_legs_clear_anim( rpl.legs_idle_anim, rpl.leg_clear_anim_blend_time );
//	}
//	if ( !IsDefined( rpl.idle_transition_direction ) || rpl.idle_transition_direction != "left" )
//	{
//		idle_left = rpl_get_idle_anim( "left" );
//		rpl_legs_clear_anim( idle_left, rpl.leg_clear_anim_blend_time );
//	}
//	if ( !IsDefined( rpl.idle_transition_direction ) || rpl.idle_transition_direction != "right" )
//	{
//		idle_right = rpl_get_idle_anim( "right" );
//		rpl_legs_clear_anim( idle_right, rpl.leg_clear_anim_blend_time );
//	}
//}
				
rpl_legs_clear_all_idle_anims( rpl )
{
	blend_time = rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_IDLE, undefined );
		
	idle_forward = rpl.legs_idle_anim;
	rpl_legs_clear_anim( idle_forward, blend_time );
//	idle_left = rpl_get_idle_anim( "left" );
//	rpl_legs_clear_anim( idle_left, blend_time );
//	idle_right = rpl_get_idle_anim( "right" );
//	rpl_legs_clear_anim( idle_right, blend_time );
}

//rpl_legs_clear_all_idle_transition_anims( rpl )
//{
//	blend_time = rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_IDLE, undefined );
//	
//	trans_left = rpl_legs_get_transition_anim( "left" );
//	rpl_legs_clear_anim( trans_left, blend_time );
//	trans_right = rpl_legs_get_transition_anim( "right" );
//	rpl_legs_clear_anim( trans_right, blend_time );
//	trans_left = rpl_legs_get_transition_back_anim( "left" );
//	rpl_legs_clear_anim( trans_left, blend_time );
//	trans_right = rpl_legs_get_transition_back_anim( "right" );
//	rpl_legs_clear_anim( trans_right, blend_time );
//}

rpl_legs_clear_all_move_anims( rpl, blend_override )
{
	rpl_legs_clear_anim( rpl.legs_move_parent_node, rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_PARENT, undefined ) );
	
	direction_keys = GetArrayKeys( rpl.move );
	foreach ( direction in direction_keys )
	{
		rpl.move[direction].playing = false;
		if ( IsDefined( blend_override ) )
		{
			rpl_legs_clear_anim( rpl_get_walk_start_anim( direction ), blend_override );
			rpl_legs_clear_anim( rpl_get_walk_loop_anim( direction ), blend_override );
			rpl_legs_clear_anim( rpl_get_walk_stop_anim( direction ), blend_override );
			if ( _rpl_legs_is_horizontal( direction ) )
			{
				rpl_legs_clear_anim( rpl_get_run_loop_anim( direction ), blend_override );
				rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "left" ), blend_override );
				rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "right" ), blend_override );
			}
		}
		else
		{
			rpl_legs_clear_anim( rpl_get_walk_start_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_START, direction ) );
			rpl_legs_clear_anim( rpl_get_walk_loop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_LOOP, direction ) );
			rpl_legs_clear_anim( rpl_get_walk_stop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_STOP, direction ) );
			if ( _rpl_legs_is_horizontal( direction ) )
			{
			    rpl_legs_clear_anim( rpl_get_run_loop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_LOOP_RUN, direction ) );
			    rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "left" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );
				rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "right" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );
			}
		}
	}
}
					
rpl_legs_clear_unused_anims( rpl, current_directions )
{
	rpl_legs_clear_all_idle_anims( rpl );	
//	rpl_legs_clear_all_idle_transition_anims( rpl );
					
	direction_keys = GetArrayKeys( rpl.move );
	foreach ( direction in direction_keys )
	{
		// if not headed that direction, clear all anims
		if ( !IsDefined( current_directions[direction] ) )
		{
			rpl.move[direction].playing = false;
			rpl_legs_clear_anim( rpl_get_walk_start_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_START, direction ) );
			rpl_legs_clear_anim( rpl_get_walk_loop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_LOOP, direction ) );
			rpl_legs_clear_anim( rpl_get_walk_stop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_STOP, direction ) );
			if ( _rpl_legs_is_horizontal( direction ) )
			{
				rpl_legs_clear_anim( rpl_get_run_loop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_LOOP_RUN, direction ) );
				rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "left" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );
				rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "right" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );
			}
		}
		else
		{
			// otherwise only clear the states that we are not already playing
			if ( rpl.move_state != rpl.MOVE_STATE_START )
				rpl_legs_clear_anim( rpl_get_walk_start_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_START, direction ) );
			if ( rpl.move_state != rpl.MOVE_STATE_LOOP )
				rpl_legs_clear_anim( rpl_get_walk_loop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_LOOP, direction ) );
			if ( rpl.move_state != rpl.MOVE_STATE_LOOP_RUN && _rpl_legs_is_horizontal( direction ) )
				rpl_legs_clear_anim( rpl_get_run_loop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_LOOP_RUN, direction ) );
			if ( rpl.move_state != rpl.MOVE_STATE_STOP )
			{
				rpl_legs_clear_anim( rpl_get_walk_stop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_STOP, direction ) );
				if ( _rpl_legs_is_horizontal( direction ) )
				{
					rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "left" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );
					rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "right" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );
				}
			}
			else
			{
				was_running = ( IsDefined( rpl.was_running ) && rpl.was_running );
				on_right_foot = ( IsDefined( rpl.current_foot ) && rpl.current_foot == "right" );
				on_left_foot = ( IsDefined( rpl.current_foot ) && rpl.current_foot == "left" );
				if ( was_running )
					rpl_legs_clear_anim( rpl_get_walk_stop_anim( direction ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_STOP, direction ) );
				if ( !was_running && !on_right_foot && _rpl_legs_is_horizontal( direction ) )
					rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "right" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );
				if ( !was_running && !on_left_foot && _rpl_legs_is_horizontal( direction ) )
					rpl_legs_clear_anim( rpl_get_run_stop_anim( direction, "left" ), rpl_legs_get_clear_blend_time( rpl, rpl.ANIMTYPE_RUN_STOP, direction ) );

			}
		}
	}
}

//_rpl_legs_get_other_foot( foot )
//{
//	if ( foot == "left" )
//		return "right";
//	else
//		return "left";
//}
//
//rpl_legs_set_idle_transition( rpl )
//{
//	idle_transition_anim = rpl_legs_get_transition_anim( rpl.idle_transition_direction );
//	level.rappel_player_legs SetAnim( idle_transition_anim, 1.0, rpl.leg_idle_trans_anim_blend_time, 1.0 );
//}
//
//rpl_legs_set_transition_back( rpl )
//{
//	transition_back_anim = rpl_legs_get_transition_back_anim( rpl.idle_transition_direction );
//	level.rappel_player_legs SetAnim( transition_back_anim, 1.0, rpl.leg_idle_trans_anim_blend_time, 1.0 );
//}

rpl_legs_get_idle_anim( rpl )
{
	idle_anim = rpl.legs_idle_anim;
//	if ( IsDefined( rpl.idle_transition_direction ) )
//		idle_anim = rpl_get_idle_anim( rpl.idle_transition_direction );
	
	return idle_anim;
}

rpl_legs_set_idle( rpl )
{
	idle_anim = rpl_legs_get_idle_anim( rpl );
	level.rappel_player_legs SetAnim( idle_anim, 1.0, rpl.leg_idle_anim_blend_time, 1.0 );
}

rpl_legs_set_anim( direction_anim, goal_weight, blend_time, animation_rate, restart, anim_flag )
{
	do_restart = IsDefined( restart ) && restart;
	do_flagged = IsDefined( anim_flag );
	
	if ( do_restart && do_flagged )
		level.rappel_player_legs SetFlaggedAnimRestart( anim_flag, direction_anim, goal_weight, blend_time, animation_rate );
	else if ( do_restart )
		level.rappel_player_legs SetAnimRestart( direction_anim, goal_weight, blend_time, animation_rate );
	else if ( do_flagged )
		level.rappel_player_legs SetFlaggedAnim( anim_flag, direction_anim, goal_weight, blend_time, animation_rate );
	else
		level.rappel_player_legs SetAnim( direction_anim, goal_weight, blend_time, animation_rate );
}
		
rpl_legs_clear_anim( direction_anim, blend_time )
{
	level.rappel_player_legs ClearAnim( direction_anim, blend_time );
}
	
rpl_legs_get_anim_type( rpl )
{
	if ( rpl.move_state == rpl.MOVE_STATE_START )
		return rpl.ANIMTYPE_START;
	else if ( rpl.move_state == rpl.MOVE_STATE_IDLE )
		return rpl.ANIMTYPE_IDLE;
	else if ( rpl.move_state == rpl.MOVE_STATE_STOP && IsDefined( rpl.was_running ) && rpl.was_running )
		return rpl.ANIMTYPE_RUN_STOP;
	else if ( rpl.move_state == rpl.MOVE_STATE_STOP )
		return rpl.ANIMTYPE_STOP;
	else if ( rpl.move_state == rpl.MOVE_STATE_LOOP )
		return rpl.ANIMTYPE_LOOP;
	else if ( rpl.move_state == rpl.MOVE_STATE_LOOP_RUN )
		return rpl.ANIMTYPE_LOOP_RUN;
	else if ( rpl.move_state == rpl.MOVE_STATE_IDLE_SHIFT )
		return rpl.ANIMTYPE_IDLE_SHIFT;
	else if ( rpl.move_state == rpl.MOVE_STATE_SHIFT_BACK )
		return rpl.ANIMTYPE_SHIFT_BACK;
	else
		AssertMsg( "rpl_legs_get_anim_type determined that rpl.move_state is in an invalid state: " + rpl.move_state );
}

rpl_get_state_anim( rpl, anim_type, direction )
{
	if ( anim_type == rpl.ANIMTYPE_START )
		return rpl_get_walk_start_anim( direction );
	else if ( anim_type == rpl.ANIMTYPE_LOOP )
		return rpl_get_walk_loop_anim( direction );
	else if ( anim_type == rpl.ANIMTYPE_LOOP_RUN )
		return rpl_get_run_loop_anim( direction );
	else if ( anim_type == rpl.ANIMTYPE_STOP )
		return rpl_get_walk_stop_anim( direction );
	else if ( anim_type == rpl.ANIMTYPE_RUN_STOP )
		return rpl_get_run_stop_anim( direction, rpl.current_foot );
	else if ( anim_type == rpl.ANIMTYPE_IDLE )
		return rpl_get_idle_anim( direction );
//	else if ( anim_type == rpl.ANIMTYPE_IDLE_SHIFT )
//		return rpl_legs_get_transition_anim( direction );
	else
		AssertMsg( "Passed in an invalid anim type to rpl_get_state_anim: " + anim_type );
}

#using_animtree( "player" );
// Need separate functions to get these anims since they are part of the player animtree, not animated_props like everything else in this file
//rpl_legs_get_transition_anim( direction )
//{
//	switch ( direction )
//	{
//		case "right":
//			return %cnd_rappel_look_transition_right_playerlegs;
//		case "left":
//			return %cnd_rappel_look_transition_left_playerlegs;
//		default:
//			AssertMsg( "Passed in an invalid movement direction to rpl_legs_get_transition_anim: " + direction );
//			break;
//	}
//}
//
//rpl_legs_get_transition_back_anim( direction )
//{
//	switch ( direction )
//	{
//		case "right":
//			return %cnd_rappel_look_transition_right_return_playerlegs;
//		case "left":
//			return %cnd_rappel_look_transition_left_return_playerlegs;
//		default:
//			AssertMsg( "Passed in an invalid movement direction to rpl_legs_get_transition_back_anim: " + direction );
//			break;
//	}	
//}

rpl_get_idle_anim( direction )
{
	switch ( direction )
	{
		case "up":
		case "down":
			return %cnd_rappel_idle_playerlegs;
//		case "left":
//			return %cnd_rappel_idle_playerlegs_l;
//		case "right":
//			return %cnd_rappel_idle_playerlegs_r;
		default:
			AssertMsg( "Passed in an invalid movement direction to rpl_get_idle_anim: " + direction );
			break;
	}
}

rpl_legs_get_parent_node_move()
{
	return %cnd_rappel_playerlegs_movement;
}

rpl_get_run_loop_anim( direction )
{
	switch ( direction )
	{
		case "right_down":
		case "right_up":
		case "right":
			return %cnd_rappel_move_run_right_loop_playerlegs;
		case "left_down":
		case "left_up":
		case "left":
			return %cnd_rappel_move_run_left_loop_playerlegs;
		default:
			AssertMsg( "Passed in an invalid movement direction to rpl_get_run_loop_anim: " + direction );
			break;
	}
}

rpl_get_walk_loop_anim( direction )
{
	switch ( direction )
	{
		case "down":
			return %cnd_rappel_move_down_loop_playerlegs;
		case "up":
			return %cnd_rappel_move_up_loop_playerlegs;
		case "right":
		return %cnd_rappel_move_right_loop_playerlegs;
		case "left":
			return %cnd_rappel_move_left_loop_playerlegs;
		case "right_down":
			return %cnd_rappel_move_down_right_loop_playerlegs;
		case "right_up":
			return %cnd_rappel_move_up_right_loop_playerlegs;
		case "left_down":
			return %cnd_rappel_move_down_left_loop_playerlegs;
		case "left_up":
			return %cnd_rappel_move_up_left_loop_playerlegs;
		default:
			AssertMsg( "Passed in an invalid movement direction to rpl_get_walk_loop_anim: " + direction );
			break;
	}
}

rpl_get_walk_start_anim( direction )
{
	switch ( direction )
	{
		case "down":
			return %cnd_rappel_move_down_start_playerlegs;
		case "up":
			return %cnd_rappel_move_up_start_playerlegs;
		case "right":
			return %cnd_rappel_move_right_start_playerlegs;
		case "left":
			return %cnd_rappel_move_left_start_playerlegs;
		case "right_down":
			return %cnd_rappel_move_down_right_start_playerlegs;
		case "right_up":
			return %cnd_rappel_move_up_right_start_playerlegs;
		case "left_down":
			return %cnd_rappel_move_down_left_start_playerlegs;
		case "left_up":
			return %cnd_rappel_move_up_left_start_playerlegs;
		default:
			AssertMsg( "Passed in an invalid movement direction to rpl_get_walk_loop_anim: " + direction );
			break;
	}
}

rpl_get_walk_stop_anim( direction )
{
	return %cnd_rappel_move_stop;
	
//	switch ( direction )
//	{
//		case "down":
//			return %cnd_rappel_move_down_stop_playerlegs;
//		case "up":
//			return %cnd_rappel_move_up_stop_playerlegs;
//		case "right":
//			return %cnd_rappel_move_right_stop_playerlegs;
//		case "left":
//			return %cnd_rappel_move_left_stop_playerlegs;
//		case "right_down":
//			return %cnd_rappel_move_down_right_stop_playerlegs;
//		case "right_up":
//			return %cnd_rappel_move_up_right_stop_playerlegs;
//		case "left_down":
//			return %cnd_rappel_move_down_left_stop_playerlegs;
//		case "left_up":
//			return %cnd_rappel_move_up_left_stop_playerlegs;
//		default:
//			AssertMsg( "Passed in an invalid movement direction to rpl_get_walk_stop_anim: " + direction );
//			break;
//	}
}

rpl_get_run_stop_anim( direction, foot )
{
	return %cnd_rappel_move_stop;

//	Assert( IsDefined( foot ) );
//	
//	if ( direction == "left" )
//	{
//		if ( foot == "left" )
//			return %cnd_rappel_move_run_left_stop_l_playerlegs;
//		else
//			return %cnd_rappel_move_run_left_stop_r_playerlegs;
//	}
//	else if ( direction == "right" )
//	{
//		if ( foot == "left" )
//			return %cnd_rappel_move_run_right_stop_l_playerlegs;
//		else
//			return %cnd_rappel_move_run_right_stop_r_playerlegs;
//	}
//	else
//	{
//		AssertMsg( "Passed in an invalid movement direction to rpl_get_run_stop_anim: " + direction );
//	}
}

rpl_get_legs_idle_anim()
{
	return %cnd_rappel_idle_playerlegs;
}

rpl_get_legs_jump_anim()
{
	if ( IsDefined( level.rappel_legs_jump_anim ) )
		return level.rappel_legs_jump_anim;
	else
		return %cnd_rappel_jump_playerlegs;
}

// --JZ commented these out as they cause load errors.  I assume they're not used since the anims are commented out in the csv.--
/*rpl_get_garden_entry_prejump_legs_anim()
{
	return %cornered_combat_rappel_garden_entry_prejump_playerlegs;
}

rpl_get_garden_entry_prejump_arms_anim()
{
	return %cornered_combat_rappel_garden_entry_prejump_playerarms;
}

rpl_get_garden_entry_jump_anim()
{
	return %cornered_combat_rappel_garden_entry_playerlegs;
}*/

rpl_get_garden_entry_legs_static_anim()
{
	return %cornered_combat_rappel_garden_entry_static_playerlegs;
}

rpl_get_garden_entry_arms_static_anim()
{
	return %cornered_combat_rappel_garden_entry_static_playerarms;
}

#using_animtree( "animated_props" );
watch_footstep_notetrack()
{
//	self notify("watch_footstep_notetrack");
//	self endon("watch_footstep_notetrack");
	flag_wait("player_has_exited_the_building");
	
	while( !flag( "inverted_rappel_finished" ) )
//	while( !flag( "stop_manage_player_rappel_movement" ) )
	{
		self waittill( "bobanim", note );
		if ( note == "ps_step_run_plr_rappel" )
		{
			maps\cornered_audio::aud_rappel( "foot" );
			wait(0.2);
		}
	}
}

cnd_rpl_cleanup( rappel_params )
{
	level.rappel_jump_land_struct = undefined;
	level.player.forcing_rappel_jump_to_struct = undefined;
	level.player.linked_world_space_forward = undefined;
	level.rappel_jump_anim = undefined;
	
	level.player AllowCrouch( true );
	level.player AllowSprint( true );
	level.player AllowProne( true );
	level.player EnableMouseSteer( false );
	level.level_specific_dof = false;
	level.player.dof_ref_ent = undefined;
	
	SetSavedDvar( "player_moveThreshhold", 10.0 ); // original: 10.0
	SetSavedDvar( "bg_weaponBobAmplitudeStanding", "0.055 0.025" ); // original: 0.055, 0.025 (standing)
	SetSavedDvar( "player_lateralPlane", 0 ); // original: 0 = XY plane
	SetSavedDvar( "bg_weaponBobAmplitudeBase", 0.16 );  // 0.16 is the original value
	SetSavedDvar( "g_speed", 190.0 ); // original: 190 (normal ground speed)
	SetSavedDvar( "bg_viewBobMax", 8 ); // original: 8 (programmatic view bob)
	SetSavedDvar( "bullet_penetrationHitsClients", 0 );
	SetSavedDvar( "bullet_penetrationActorHitsActors", 0 );
	
	level.rpl = undefined;
	
	flag_clear( "stop_manage_player_rappel_movement" );
}

//cnd_rpl_debug()
//{
/////#
////		debug_axis( level.player GetEye(), level.player GetPlayerAngles() );
////	debug_star( level.rpl_plyr_anim_origin.origin, (0,0,1) );
////	debug_star( level.player GetOrigin() + (0,0,0.5), (0,1,0) );
////	debug_star( level.rpl_jump_anim_origin.origin, (1,0,0) );
////	vel = VectorNormalize( level.player GetVelocity() );
////	debug_star( ( level.rpl_plyr_anim_origin.origin + ( 0, 0, 30 ) ) + ( vel * 30 ), ( 1, 1, 0 ) );
////	line( level.player.origin, level.player.origin + ( vel * 200 ), ( 0, 1, 0 ) );
////	debug_star( level.plyr_rpl_groundref.origin, (1,0,0) );
////#/
//}

rappel_limit_vertical_move( relative_lower_limit, relative_upper_limit )
{
	// NOTE: These limits are measured along the rope, so it ends up being an arc instead of a horizontal band
	
	// relative_lower_limit is the distance from the player to the lower limit, measured along the rope.
	// For example, (-10) would place the lower limit 10 units below the player's current position, along the rope.
	// relative_upper_limit is the distance from the player to the upper limit, measured along the rope.
	// For example, (100) would place the upper limit 100 units above the player's current position, along the rope.
	
	dist_player_to_top = rpl_calc_dist_player_to_top( level.rpl, true );
	
	level.rappel_lower_limit = dist_player_to_top - relative_lower_limit;
	level.rappel_upper_limit = dist_player_to_top - relative_upper_limit;
}

rappel_clear_vertical_limits()
{
	level.rappel_lower_limit = undefined;
	level.rappel_upper_limit = undefined;
}

//rpl_get_angle_modified_lower_limit( rope_origin )
//{
//	// just return undefined if the lower limit is not defined
//	if ( !IsDefined( level.rappel_lower_limit ) )
//		return level.rappel_lower_limit;
//	
//	rope_roll = rope_origin.angles[2];
//	lower_limit_origin = rope_origin.origin + ( 0, 0, -1 * level.rappel_lower_limit );
//	
//	// do right triangle math to determine what the longest you could on the go down on the hypotenuse to not violate the lowest vertical limit
//	adjacent = Distance( rope_origin.origin, lower_limit_origin );
//	hypotenuse = adjacent / Cos( rope_roll );
//	adjusted_lower_offset = hypotenuse - adjacent;
//	
//	return level.rappel_lower_limit + adjusted_lower_offset;
//}

rpl_calc_max_yaw_right( rpl )
{
	dist_player_to_top = rpl_calc_dist_player_to_top( rpl );
	if ( ( level.rappel_max_lateral_dist_right / dist_player_to_top ) > 1 )
	{
		return 60;
	}
	max_yaw = ASin( level.rappel_max_lateral_dist_right / dist_player_to_top );
	return max_yaw;
}

rpl_calc_max_yaw_left( rpl )
{
	dist_player_to_top = rpl_calc_dist_player_to_top( rpl );
	if ( ( level.rappel_max_lateral_dist_left / dist_player_to_top ) > 1 )
	{
		return -60;
	}
	max_yaw = ASin( ( -1 * level.rappel_max_lateral_dist_left ) / dist_player_to_top );
	return max_yaw;
}

rpl_calc_max_rot_speed( rpl, rappel_params )
{
	max_lateral_speed = rpl_get_max_lateral_speed();
	
	if ( rappel_use_plyr_legs( rappel_params ) )
	{
		// this is an approximate pre-calculation since lateral change has not been calculated yet
		rpl.anim_right_move_strength = rpl.right_move_strength;
		rpl.anim_down_move_strength = rpl.down_move_strength;
		if ( abs( rpl.vertical_change_this_update ) == 0 )
			rpl.anim_down_move_strength = 0;
		rpl.cur_move_vect_norm = VectorNormalize( ( rpl.anim_right_move_strength, rpl.anim_down_move_strength, 0 ) );
		player_trying_to_move = abs(rpl.anim_down_move_strength) > 0 || abs(rpl.anim_right_move_strength) > 0;
		travel_horizontal = rpl_legs_traveling_horizontal( rpl, player_trying_to_move );
		
		if ( !travel_horizontal && player_trying_to_move && sign( rpl.vertical_change_this_update ) == -1 )
			max_lateral_speed = rpl_get_max_downward_speed();
//		else if ( !travel_horizontal && player_trying_to_move )
//			max_lateral_speed = rpl_get_max_upward_speed();
	}
	
	dist_player_to_top = rpl_calc_dist_player_to_top( rpl );
	rot_speed_max = ( max_lateral_speed * 1000 ) / dist_player_to_top;
	
	if ( !rpl.jumping && level.player isADS() )
	{
		rot_speed_max *= 0.25;
	}
	
	if ( level.player IsSprinting() )
	{
		rot_speed_max *= 1.5;
	}
	
	if ( rpl.too_close_to_ally )
	{
		rot_speed_max = 0;
	}
	
	return rot_speed_max;
}

rpl_calc_dist_player_to_top( rpl, ignore_cache )
{
	dist_player_to_top = Distance( level.player.origin, level.rpl_rope_anim_origin.origin );
	
	if ( IsDefined( ignore_cache ) && ignore_cache )
	{
		return dist_player_to_top;
	}
	
	if ( abs( rpl.current_dist_to_top - dist_player_to_top ) > 10 )
	{
		// Only change current dist to top if it has changed more than 10 units.  Otherwise it slightly changes every frame and produces inconsistent results
		rpl.current_dist_to_top = dist_player_to_top;
	}
	
	return rpl.current_dist_to_top;
}

player_rappel_force_jump_away( land_struct )
{
	// if land_struct is defined, player will land on the struct when this jump is forced
	if ( IsDefined( land_struct ) )
	{
		level.player.forcing_rappel_jump_to_struct = true;
		level.rappel_jump_land_struct = land_struct;
	}
	
	level.player notify( "playerforcejump" );
}

cnd_plyr_rpl_handle_jump( rappel_params, rpl )
{
	level endon( "stop_manage_player_rappel_movement" );

	base_rotate_anim = %rappel_movement_player_jump_still;
	
	flag_clear( "player_jumping" );

	NotifyOnCommand( "playerjump", "+gostand" );
	NotifyOnCommand( "playerjump", "+moveup" );
	
	jump_origin = cnd_get_rope_anim_origin();
	start_pitch = jump_origin.angles[ 0 ];
			
	rpl.initial_dist_z_from_top = abs( level.player.origin[2] - rpl.rope_origin.origin[2] );
	
	while ( 1 )
	{
		level.player waittill_either( "playerjump", "playerforcejump" );
		
		if ( !flag( "force_jump" ) && !flag( "disable_rappel_jump" ) )
		{
			level.player AllowJump( false );
			landing_on_struct = IsDefined( level.player.forcing_rappel_jump_to_struct ) && level.player.forcing_rappel_jump_to_struct;
			
			flag_set( "player_jumping" );
			rpl.jumpComplete = false;
			rotate_jump_anim = rpl_get_rotate_jump_anim( rappel_params );
			level.rappel_jump_anim = rotate_jump_anim;
			
			jump_anim_length = GetAnimLength( rotate_jump_anim );
			thread rappel_rope_additive_jump_animations( rappel_params, jump_anim_length );
			
			thread maps\cornered_audio::aud_rappel( "jump" );
			
			rappel_rope_animate_rotate( rpl, jump_origin, rotate_jump_anim, base_rotate_anim );
			
			if ( rappel_use_plyr_legs( rappel_params ) )
			{
				legs_jump_anim = rpl_get_legs_jump_anim();
				level.rappel_player_legs SetAnimRestart( legs_jump_anim, 1.0, rpl.leg_jump_anim_blend_time, 1.0 );
			}
			
			modified_jump_anim_length = jump_anim_length * rpl_get_jump_percent_considered_complete( rappel_params );
			ending_length = jump_anim_length - modified_jump_anim_length;
			
			if ( !landing_on_struct )
				wait ( modified_jump_anim_length );	//end the official jump a little earlier so it feels a little more sticky
			else
				wait jump_anim_length;
			
			flag_clear( "player_jumping" );	
			level.player AllowJump( true );
			
			if ( landing_on_struct )
			{
				level notify( "player_force_jump_landed" );
				thread end_legs_jump_anim( rpl );
			}
			else if ( rappel_use_plyr_legs( rappel_params ) )
			{
				thread end_legs_jump_anim( rpl, ending_length );
			}
		}
	}
}

//rappel_jump_anim_complete( rappel_params )
//{
//	jump_type = rappel_params.jump_type;
//	jump_percent_complete = rpl_get_jump_percent_considered_complete( rappel_params );
//	jump_origin = cornered_get_rope_anim_origin();
//	
//	return jump_origin GetAnimTime( level.rappel_jump_anim ) >= jump_percent_complete;
//}

rpl_get_jump_percent_considered_complete( rappel_params )
{
	jump_type = rappel_params.jump_type;
	
	if ( IsDefined( level.rappel_rotate_jump_anim ) || jump_type == "jump_small" )
		return 1.0;
	else // jump_type == "jump_normal"
		return 0.65;
}

rpl_get_rotate_jump_anim( rappel_params )
{
	jump_type = rappel_params.jump_type;
	
	if ( IsDefined( level.rappel_rotate_jump_anim ) )
		return level.rappel_rotate_jump_anim;
	else if ( jump_type == "jump_small" )
		return %rappel_movement_player_jump_rotate_sm;
	else // jump_type == "jump_normal"
		return %rappel_movement_player_jump_rotate;
}

rappel_rope_additive_jump_animations( rappel_params, jump_anim_length )
{
	if ( rappel_params.rappel_type == "inverted" )
		return;
	
	level.cnd_rappel_player_rope SetAnimKnobRestart( %cnd_rappel_idle_rope_player_add, 1.0, 0.5, 1.0 );
			
	wait ( jump_anim_length - 0.3 );
	
	level.cnd_rappel_player_rope SetAnimKnobRestart( %cnd_rappel_jump_shake_rope_player, 1, 0, 1 );
}

rappel_rope_animate_rotate( rpl, jump_origin, rotate_anim, base_rotate_anim )
{
	current_dist_z_from_top = abs( level.player.origin[2] - rpl.rope_origin.origin[2] );
	dist_ratio = rpl.initial_dist_z_from_top / current_dist_z_from_top;
	desired_angle = ATan( dist_ratio * rpl.tangentJump );
	rotate_weight = desired_angle / rpl.maxRopeJumpAngle;
	rotate_weight = clamp( rotate_weight, 0, 1.0 );
	stil_weight = 1.0 - rotate_weight;
	
//	thread debug_jump_rotate_angle( rpl, jump_origin, rotate_anim );
	
	jump_origin SetAnim( rotate_anim, rotate_weight, 0, 1 );
	jump_origin SetAnimTime( rotate_anim, 0 );
	level.rpl_physical_rope_anim_origin SetAnim( rotate_anim, rotate_weight, 0, 1 );
	level.rpl_physical_rope_anim_origin SetAnimTime( rotate_anim, 0 );
	
	jump_origin SetAnim( base_rotate_anim, stil_weight, 0, 1 );
	jump_origin SetAnimTime( base_rotate_anim, 0 );
	level.rpl_physical_rope_anim_origin SetAnim( base_rotate_anim, stil_weight, 0, 1 );
	level.rpl_physical_rope_anim_origin SetAnimTime( base_rotate_anim, 0 );
}

//debug_jump_rotate_angle( rpl, jump_origin, rotate_anim )
//{
//	vec1 = VectorNormalize( level.player.origin - rpl.rope_origin.origin );
//	
//	while ( flag( "player_jumping" ) )
//	{
//		vec2 = VectorNormalize( level.player.origin - rpl.rope_origin.origin );
//		dot = VectorDot( vec1, vec2 );
//		angle = 0;
//		if ( dot != 1 )
//			angle = ACos( dot );
//		weight = jump_origin GetAnimWeight( rotate_anim );
//		
//		PrintLn( "Rotate weight: " + weight );
//		Println( "Rotate angle: " + angle );
//		
//		waitframe();
//	}
//}

end_legs_jump_anim( rpl, time )
{
	level endon( "stop_manage_player_rappel_movement" );
	
	// This is necessary because we allow the player to jump again when the jump animation still has 'time' left.
	// So we need to wait for the jump anim to finish before clearing the anim and going back to idle
	// But if a new jump anim was started in that time, we need to make sure to not clear it.
	
	if ( IsDefined( time ) )
		wait( time );
	
	legs_jump_anim = rpl_get_legs_jump_anim();
	
	if ( level.rappel_player_legs GetAnimTime( legs_jump_anim ) > 0.9 )
	{
		// If animation finished, clear it
		level.rappel_player_legs ClearAnim( legs_jump_anim, 0.2 );
		rpl.jumpComplete = true;
	}
}

plyr_is_moving_up( rpl )
{
	if ( rpl.move_state != rpl.MOVE_STATE_START && rpl.move_state != rpl.MOVE_STATE_LOOP )
		return false;
	
	if ( rpl.move_state == rpl.MOVE_STATE_START )
	{
		direction = rpl_legs_get_start_move_direction( rpl );
		
		if ( direction == "up" || direction == "left_up" || direction == "right_up" )
			return true;
	}
	else // rpl.move_state == rpl.MOVE_STATE_LOOP
	{
		directions = rpl_legs_get_move_directions( rpl, false );
		direction_keys = GetArrayKeys( directions );
		if ( array_contains( direction_keys, "up" ) || array_contains( direction_keys, "left_up" ) || array_contains( direction_keys, "right_up" ) )
			return true;
	}
	
	return false;
}

plyr_rappel_legs_set_origin( rpl )
{
	max_location_offset = GetDvarInt( "move_up_offset", 20 );
	max_legs_lerp_unit_per_frame = GetDvarFloat( "move_up_lerp", 5.0 );
		
	level.rappel_player_legs Unlink();
		
	legs_origin = level.rpl_plyr_legs_link_ent.origin;
	legs_offset = 0;
	
	if ( !IsDefined( rpl.last_legs_offset ) )
		rpl.last_legs_offset = 0;
				
	// offset the torso if you moving up to hide sliding
	if ( plyr_is_moving_up( rpl ) )
		legs_offset += max_location_offset;
	
	// lerp the legs rather than teleport them
	legs_offset_diff = legs_offset - rpl.last_legs_offset;
	if ( abs( legs_offset_diff ) > 0 && abs( legs_offset_diff ) > max_legs_lerp_unit_per_frame )
	{
		legs_offset = rpl.last_legs_offset + ( sign( legs_offset_diff ) * max_legs_lerp_unit_per_frame );
	}
	rpl.last_legs_offset = legs_offset;
	
	if ( abs( legs_offset ) > 0 )
	{
		rope_down_dir = -1 * AnglesToUp( level.rpl_rope_anim_origin GetTagAngles( "J_prop_1" ) );
		legs_origin_offset = VectorNormalize( rope_down_dir ) * legs_offset;
		legs_origin += legs_origin_offset;
	}

	level.rappel_player_legs.origin = legs_origin;
	
	level.rappel_player_legs LinkTo( level.rpl_plyr_legs_link_ent );
}

plyr_rappel_jump_down( rappel_params, jump_away )
{
	flag_set( "force_jump" );
	flag_clear( "player_jumping" );
	
	if ( IsDefined( jump_away ) )
		CMPP_JUMP_ANIM = %rappel_movement_player_jump_rotate;		// jump away
	else
		CMPP_JUMP_ANIM = %rappel_movement_player_jump_rotate2;		// jump down
	
	base_rotate_anim = %rappel_movement_player_jump_still;
	
	jump_origin = cnd_get_rope_anim_origin();
	start_pitch = jump_origin.angles[ 0 ];

	level.player SetStance( "stand" );
	level.player AllowJump( false );
		
	flag_set( "player_jumping" );
	level.rpl.jumpComplete = false;
	thread maps\cornered_audio::aud_rappel_jump_down(0.5, 1.6);
	
	jump_anim_length = GetAnimLength( CMPP_JUMP_ANIM );
	thread rappel_rope_additive_jump_animations( rappel_params, jump_anim_length );

	rappel_rope_animate_rotate( level.rpl, jump_origin, CMPP_JUMP_ANIM, base_rotate_anim );

	legs_jump_anim = rpl_get_legs_jump_anim();
	if ( rappel_use_plyr_legs( rappel_params ) )
	{
		level.rappel_player_legs SetAnim( legs_jump_anim, 1.0, 0.2, 1.0 );
		level.rappel_player_legs SetAnimTime( legs_jump_anim, 0.0 );
	}
	
	wait( jump_anim_length );
	
	if ( rappel_use_plyr_legs( rappel_params ) )
	{
		level.rappel_player_legs ClearAnim( legs_jump_anim, 0.2 );
	}
	
	level.player AllowJump( true );
	flag_clear( "player_jumping" );
	flag_clear( "force_jump" );
	level.rpl.jumpComplete = true;
	level.player_jump_down_finished = true;
}

//rappel_rope_extend_rope_on_jump_down_anim( rpl, rappel_params, jump_down_anim_length )
//{
//	level endon( "stop_manage_player_rappel_movement" );
//	
//	if ( rappel_params.rappel_type == "inverted" )
//		return;
//	
//	current_time = GetTime();
//	end_time = current_time + ( jump_down_anim_length * 1000 ) + 500;
//	
//	last_player_z = level.rpl_plyr_anim_origin.origin[2];
//	
//	one_unit_anim_time = 1.0 / level.rpl.player_rope_unwind_length; // how much time to scrub for 1 unit
//	
//	while ( current_time <= end_time )
//	{
//		current_time = GetTime();
//		current_player_z = level.rpl_plyr_anim_origin.origin[2];
//		
//		vertical_change = abs( current_player_z - last_player_z );
//		
//		if ( abs( vertical_change ) == 0 )
//		{
//			waitframe();
//			continue;
//		}
//		
//		anim_time = level.cnd_rappel_tele_rope GetAnimTime( level.rpl.player_rope_unwind_anim );
//		next_time = anim_time + ( vertical_change * one_unit_anim_time );
//		next_time = clamp( next_time, 0, 0.9999 ); // can not set it directly to 1
//		level.cnd_rappel_tele_rope SetAnimTime( rpl.player_rope_unwind_anim, next_time );
//		
//		last_player_z = current_player_z;
//		
//		waitframe();
//	}
//}


// ****************************
// * Utility Functions        *
// *********************************************************************************************************************************************************************


rappel_use_plyr_legs( rappel_params )
{
	if ( !rappel_params.show_legs )
		return false;
		
	return true;
}

cnd_get_rope_anim_origin()
{
	return level.rpl_rope_anim_origin;
}

cnd_get_plyr_anim_origin()
{
	return level.rpl_plyr_anim_origin;
}

//cornered_get_plyr_jump_anim_origin()
//{
//	return level.rpl_jump_anim_origin;
//}

rappel_lateral_speed_to_world_units( speed )
{
	return ( ( speed * 140 ) / 8.0 );	
}

rappel_vertical_speed_to_world_units( speed )
{
	return ( speed * 20 );	
}

rpl_get_max_lateral_speed()
{
//	/# return GetDvarFloat( "rappel_max_lateral_speed", level.rappel_max_lateral_speed ); #/
	
	return level.rappel_max_lateral_speed;
}

rpl_get_max_upward_speed()
{
//	/# return GetDvarFloat( "rappel_max_upward_speed", level.rappel_max_upward_speed ); #/
	
	return level.rappel_max_upward_speed;
}

rpl_get_max_downward_speed()
{
//	/# return GetDvarFloat( "rappel_max_downward_speed", level.rappel_max_downward_speed ); #/
	
	return level.rappel_max_downward_speed;
}


// ****************************
// * Debug Functions          *
// *********************************************************************************************************************************************************************


/#
rpl_legs_debug_anim_blender( rpl, rappel_params )
{
	if ( !rappel_use_plyr_legs( rappel_params ) )
		return false;
		
	SetDvarIfUninitialized( "debug_rl_anims", "0" );
	
	if ( !IsDefined( level.debug_rl_anims ) )
	{
		level.debug_rl_anims = false;
		SetDvarIfUninitialized( "debug_rl_u_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_d_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_l_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_r_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_ul_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_ur_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_dl_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_dr_weight", 0 );
		SetDvarIfUninitialized( "debug_rl_blend_into_time", 0.2 );
		SetDvarIfUninitialized( "debug_rl_blend_clear_time", 0.2 );
		SetDvarIfUninitialized( "debug_rl_anim_rate", 1.0 );
		SetDvarIfUninitialized( "debug_rl_clear_weights", 0 );
		SetDvarIfUninitialized( "debug_rl_follow_player", 0 );
		SetDvarIfUninitialized( "debug_rl_run", 0 );
	}
	
	if ( GetDvar( "debug_rl_anims" ) == "0" && level.debug_rl_anims )
	{
		rpl_legs_set_idle( rpl );
		rpl_legs_clear_all_move_anims( rpl );
		level.debug_rl_anims = false;
	}
	
	// test blending between the leg anims
	if ( GetDvar( "debug_rl_anims" ) != "1" )
		return false;
		
	clear_weights = GetDvarFloat( "debug_rl_clear_weights" );
	if ( clear_weights )
	{
		SetDvar( "debug_rl_u_weight", 0 );
		SetDvar( "debug_rl_d_weight", 0 );
		SetDvar( "debug_rl_l_weight", 0 );
		SetDvar( "debug_rl_r_weight", 0 );
		SetDvar( "debug_rl_ul_weight", 0 );
		SetDvar( "debug_rl_ur_weight", 0 );
		SetDvar( "debug_rl_dl_weight", 0 );
		SetDvar( "debug_rl_dr_weight", 0 );
		SetDvar( "debug_rl_clear_weights", 0 );
	}
	
	weights = [];
	weights["up"] 			= GetDvarFloat( "debug_rl_u_weight" );
	weights["down"] 		= GetDvarFloat( "debug_rl_d_weight" );
	weights["left"] 		= GetDvarFloat( "debug_rl_l_weight" );
	weights["right"] 		= GetDvarFloat( "debug_rl_r_weight" );
	weights["left_up"] 		= GetDvarFloat( "debug_rl_ul_weight" );
	weights["right_up"] 	= GetDvarFloat( "debug_rl_ur_weight" );
	weights["left_down"] 	= GetDvarFloat( "debug_rl_dl_weight" );
	weights["right_down"] 	= GetDvarFloat( "debug_rl_dr_weight" );
	blend_time 				= GetDvarFloat( "debug_rl_blend_into_time" );
	blend_clear_time		= GetDvarFloat( "debug_rl_blend_clear_time" );
	anim_rate				= GetDvarFloat( "debug_rl_anim_rate" );
	follow_player			= GetDvarFloat( "debug_rl_follow_player" );
	should_run				= GetDvarFloat( "debug_rl_run" );
	
	if ( !level.debug_rl_anims )
	{
		level.debug_rl_anims = true;
	}
	
	if ( follow_player )
	{
		level.rappel_player_legs.origin = rpl.player_anim_origin.origin;
	}
	
	if ( !weights["up"] && !weights["down"] && !weights["left"] && !weights["right"] && !weights["left_up"] && !weights["right_up"] && !weights["left_down"] && !weights["right_down"] )
	{
		rpl_legs_set_idle( rpl );
		rpl_legs_clear_all_move_anims( rpl, blend_clear_time );
	}
	else
	{
		rpl_legs_set_anim( rpl.legs_move_parent_node, 1.0, 0.2, 1.0 );
		rpl_legs_clear_anim( rpl.legs_idle_anim, blend_clear_time );
		
		direction_keys = GetArrayKeys( rpl.move );
		foreach ( direction in direction_keys )
		{
			if ( _rpl_legs_is_horizontal( direction ) )
			{
				anim_type = rpl.ANIMTYPE_LOOP_RUN;
				if ( should_run )
					weight = weights[direction];
				else
					weight = 0;
					
				direction_anim = rpl_get_state_anim( rpl, anim_type, direction );

				if ( weight == 0 )
					rpl_legs_clear_anim( direction_anim, blend_clear_time );
				else
					rpl_legs_set_anim( direction_anim, weight, blend_time, anim_rate );
			}
			
			anim_type = rpl.ANIMTYPE_LOOP;
			if ( !should_run )
				weight = weights[direction];
			else
				weight = 0;
				
			direction_anim = rpl_get_state_anim( rpl, anim_type, direction );

			if ( weight == 0 )
				rpl_legs_clear_anim( direction_anim, blend_clear_time );
			else
				rpl_legs_set_anim( direction_anim, weight, blend_time, anim_rate );
		}
	}
	
	return true;
}
#/
