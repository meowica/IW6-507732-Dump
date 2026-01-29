
#include maps\_utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include common_scripts\utility;

#using_animtree( "vehicles" );

init_tank_crush()
{
	SetDvarIfUninitialized( "debug_tankcrush" , "0" );

}

tank_crush( crushedVehicle, endNode, tankAnim, truckAnim, animTree, soundAlias, rate )
{
	if ( !IsDefined( rate ) )
		rate = 1;
	
	// Chad G's tank crushing vehicle script. Self corrects for node positioning errors.
	Assert( IsDefined( crushedVehicle ) );
	Assert( IsDefined( endNode ) );
	Assert( IsDefined( tankAnim ) );
	Assert( IsDefined( truckAnim ) );
	Assert( IsDefined( animTree ) );

	// -----------------------------------------------------------------------------------------
	// Create an animatable tank and move the real tank to the next path and store required info
	// -----------------------------------------------------------------------------------------

	animatedTank = self; //vehicle_to_dummy();
	self Vehicle_SetSpeed( 7 * rate, 5, 5 );


	// --------------------------------------------------------------- 
	// Total time for animation, and correction and uncorrection times
	// --------------------------------------------------------------- 

	animLength	   = GetAnimLength( tankAnim ) / rate;
	move_to_time   = ( animLength / 3 );
	move_from_time = ( animLength / 3 );



	// ---------------------------------------------------------------------------------------
	// Node information used for calculating both starting and ending points for the animation
	// ---------------------------------------------------------------------------------------

	// get node vecs
	node_origin	 = crushedVehicle.origin;
	node_angles	 = crushedVehicle.angles;
	node_forward = AnglesToForward( node_angles );
	node_up		 = AnglesToUp( node_angles );
	node_right	 = AnglesToRight( node_angles );

	// ----------------------------------------------------------------------------------_
	// Calculate Starting Point for the animation from crushedVehicle and create the dummy
	// -----------------------------------------------------------------------------------

	// get anim starting point origin and angle
	anim_start_org = GetStartOrigin( node_origin, node_angles, tankAnim );
	anim_start_ang = GetStartAngles( node_origin, node_angles, tankAnim );

	// get anim starting point vecs
	animStartingVec_Forward = AnglesToForward( anim_start_ang );
	animStartingVec_Up		= AnglesToUp( anim_start_ang );
	animStartingVec_Right	= AnglesToRight( anim_start_ang );

	// get tank vecs
	tank_Forward = AnglesToForward( animatedTank.angles );
	tank_Up		 = AnglesToUp( animatedTank.angles );
	tank_Right	 = AnglesToRight( animatedTank.angles );

	// spawn dummy with appropriate offset
	offset_Vec	   = ( node_origin - anim_start_org );
	offset_Forward = VectorDot( offset_Vec, animStartingVec_Forward );
	offset_Up	   = VectorDot( offset_Vec, animStartingVec_Up );
	offset_Right   = VectorDot( offset_Vec, animStartingVec_Right );
	dummy		   = Spawn( "script_origin", animatedTank.origin );
	dummy.origin += ( tank_Forward * offset_Forward );
	dummy.origin += ( tank_Up * offset_Up );
	dummy.origin += ( tank_Right * offset_Right );

	// set dummy angles to reflect the different in animation starting angles and the tanks actual angles
	offset_Vec	   = AnglesToForward( node_angles );
	offset_Forward = VectorDot( offset_Vec, animStartingVec_Forward );
	offset_Up	   = VectorDot( offset_Vec, animStartingVec_Up );
	offset_Right   = VectorDot( offset_Vec, animStartingVec_Right );
	dummyVec	   = ( tank_Forward * offset_Forward );
	dummyVec += ( tank_Up * offset_Up );
	dummyVec += ( tank_Right * offset_Right );
	dummy.angles = VectorToAngles( dummyVec );



	// -- -- -- -- -- -- -- -- -- -- - 
	// Debug Lines
	// -- -- -- -- -- -- -- -- -- -- - 
	/#
	if ( GetDvar( "debug_tankcrush" ) == "1" )
	{
		// line to where tank1 is
		thread draw_line_from_ent_for_time( level.player, animatedTank.origin, 1, 0, 0, animLength / 2 );

		// line to where tank1 SHOULD be
		thread draw_line_from_ent_for_time( level.player, anim_start_org, 0, 1, 0, animLength / 2 );

		// line to the dummy
		thread draw_line_from_ent_to_ent_for_time( level.player, dummy, 0, 0, 1, animLength / 2 );
	}
	#/


	// ---------------------------------------------------------------------
	// Animate the animatable tank and self correct into the crushed vehicle
	// ---------------------------------------------------------------------

	if ( IsDefined( soundAlias ) )
		level thread play_sound_in_space( soundAlias, node_origin );

	//animatedTank LinkTo( dummy );
	crushedVehicle UseAnimTree( animTree );
	animatedTank UseAnimTree( animTree );

	Assert( IsDefined( level._vehicle_effect[ "tankcrush" ][ "window_med" ] ) );
	Assert( IsDefined( level._vehicle_effect[ "tankcrush" ][ "window_large" ] ) );

											//   tagName 					      fxName 											      soundAlias 			   startDelay   
	crushedVehicle thread tank_crush_fx_on_tag( "tag_window_left_glass_fx"	   , level._vehicle_effect[ "tankcrush" ][ "window_med" ]  , "veh_glass_break_small", 0.2 );
	crushedVehicle thread tank_crush_fx_on_tag( "tag_window_right_glass_fx"	   , level._vehicle_effect[ "tankcrush" ][ "window_med" ]  , "veh_glass_break_small", 0.4 );
	crushedVehicle thread tank_crush_fx_on_tag( "tag_windshield_back_glass_fx" , level._vehicle_effect[ "tankcrush" ][ "window_large" ], "veh_glass_break_large", 0.7 );
	crushedVehicle thread tank_crush_fx_on_tag( "tag_windshield_front_glass_fx", level._vehicle_effect[ "tankcrush" ][ "window_large" ], "veh_glass_break_large", 1.5 );

	crushedVehicle AnimScripted( "tank_crush_anim", node_origin, node_angles, truckAnim );
	animatedTank AnimScripted( "tank_crush_anim", dummy.origin, dummy.angles, tankAnim );

	if ( rate != 1 )
	{
		crushedVehicle SetFlaggedAnim( "tank_crush_anim", truckAnim, 1, 0, rate );
		animatedTank SetFlaggedAnim( "tank_crush_anim", tankAnim, 1, 0, rate );
	}

	dummy MoveTo( node_origin, move_to_time, ( move_to_time / 2 ), ( move_to_time / 2 ) );
	dummy RotateTo( node_angles, move_to_time, ( move_to_time / 2 ), ( move_to_time / 2 ) );
	wait move_to_time;

	animLength -= move_to_time;
	animLength -= move_from_time;

	// --------------------------------------------------------------
	// Tank plays animation in the exact correct location for a while
	// --------------------------------------------------------------
	wait animLength;

	// ------------------------------------------------------------
	// Calculate Ending Point for the animation from crushedVehicle
	// ------------------------------------------------------------

	// get anim ending point origin and angle
	// anim_end_org = anim_start_org + GetMoveDelta( tankAnim, 0, 1 );
	temp			= Spawn( "script_model", ( anim_start_org ) );
	temp.angles		= anim_start_ang;
	anim_end_org	= temp LocalToWorldCoords( GetMoveDelta( tankAnim, 0, 1 ) );
	anim_end_ang	= anim_start_ang + ( 0, GetAngleDelta( tankAnim, 0, 1 ), 0 );
	temp Delete();

	// get anim ending point vecs
	animEndingVec_Forward = AnglesToForward( anim_end_ang );
	animEndingVec_Up	  = AnglesToUp( anim_end_ang );
	animEndingVec_Right	  = AnglesToRight( anim_end_ang );

	// get ending tank pos vecs
	attachPos	 = self GetAttachPos( endNode );
	tank_Forward = AnglesToForward( attachPos[ 1 ] );
	tank_Up		 = AnglesToUp( attachPos[ 1 ] );
	tank_Right	 = AnglesToRight( attachPos[ 1 ] );

	// see what the dummy's final origin will be
	offset_Vec		   = ( node_origin - anim_end_org );
	offset_Forward	   = VectorDot( offset_Vec, animEndingVec_Forward );
	offset_Up		   = VectorDot( offset_Vec, animEndingVec_Up );
	offset_Right	   = VectorDot( offset_Vec, animEndingVec_Right );
	dummy.final_origin = attachPos[ 0 ];
	dummy.final_origin += ( tank_Forward * offset_Forward );
	dummy.final_origin += ( tank_Up * offset_Up );
	dummy.final_origin += ( tank_Right * offset_Right );

	// set dummy angles to reflect the different in animation starting angles and the tanks actual angles
	offset_Vec	   = AnglesToForward( node_angles );
	offset_Forward = VectorDot( offset_Vec, animEndingVec_Forward );
	offset_Up	   = VectorDot( offset_Vec, animEndingVec_Up );
	offset_Right   = VectorDot( offset_Vec, animEndingVec_Right );
	dummyVec	   = ( tank_Forward * offset_Forward );
	dummyVec += ( tank_Up * offset_Up );
	dummyVec += ( tank_Right * offset_Right );
	dummy.final_angles = VectorToAngles( dummyVec );

	// -----------
	// Debug Lines
	// -----------
	/#
	if ( GetDvar( "debug_tankcrush" ) == "1" )
	{
		// line to where tank2 is
		thread draw_line_from_ent_for_time( level.player, self.origin, 1, 0, 0, animLength / 2 );

		// line to where tank2 SHOULD be
		thread draw_line_from_ent_for_time( level.player, anim_end_org, 0, 1, 0, animLength / 2 );

		// line to the dummy
		thread draw_line_from_ent_to_ent_for_time( level.player, dummy, 0, 0, 1, animLength / 2 );
	}
	#/

	// --------------------------------------------------------------
	// Tank uncorrects to the real location of the tank on the spline
	// --------------------------------------------------------------

	dummy MoveTo( dummy.final_origin, move_from_time, ( move_from_time / 2 ), ( move_from_time / 2 ) );
	dummy RotateTo( dummy.final_angles, move_from_time, ( move_from_time / 2 ), ( move_from_time / 2 ) );
	wait move_from_time;

	// --------------------------------------------------------------------------------------------------------------------
	// Tank is done animating now, remove the animatable tank and show the real one( they should be perfectly aligned now )
	// --------------------------------------------------------------------------------------------------------------------

	self AttachPath( endNode );
	// we must wait a frame before unhiding the real vehicle so we dont' see it interpolate.  DontInterpolate() doesn't work.
	waitframe();
	//dummy_to_vehicle();
}

tank_crush_fx_on_tag( tagName, fxName, soundAlias, startDelay )
{
	if ( IsDefined( startDelay ) )
		wait startDelay;
	PlayFXOnTag( fxName, self, tagName );
	if ( IsDefined( soundAlias ) )
		self thread play_sound_on_tag( soundAlias, tagName );
}
