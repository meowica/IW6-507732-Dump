#include maps\_utility;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
override_footsteps()
{
	wait( 0.1 ); // wait for footsteps to be loaded
	
	bubble_fx = level._effect[ "swim_kick_bubble" ];
	
	animscripts\utility::setFootstepEffect( "default", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "asphalt", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "brick", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "carpet", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "cloth",  	bubble_fx );
	animscripts\utility::setFootstepEffect( "concrete", bubble_fx );
	animscripts\utility::setFootstepEffect( "cushion",  bubble_fx );
	animscripts\utility::setFootstepEffect( "dirt", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "foliage", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "grass", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "gravel", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "mud", 		bubble_fx );
	animscripts\utility::setFootstepEffect( "rock", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "sand", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "wood", 	bubble_fx );
	animscripts\utility::setFootstepEffect( "water", 	bubble_fx );

	animscripts\utility::setFootstepEffectSmall( "default", 	bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "asphalt", 	bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "brick", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "carpet", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "cloth", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "concrete", 	bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "cushion", 	bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "dirt", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "foliage", 	bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "grass", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "gravel", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "mud", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "rock", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "sand", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "wood", 		bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "water", 		bubble_fx );	
	
	override_footstep_notetrack_scripts();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
override_water_footsteps()
{
	wait( 0.1 ); // wait for footsteps to be loaded
	
	bubble_fx = level._effect[ "swim_kick_bubble" ];
	
	animscripts\utility::setFootstepEffect( "water", bubble_fx );
	animscripts\utility::setFootstepEffectSmall( "water", bubble_fx );
	
	override_footstep_notetrack_scripts();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
restore_water_footsteps()
{
	animscripts\utility::unsetFootstepEffect( "water" );
	animscripts\utility::unsetFootstepEffectSmall( "water" );
	
	restore_footstep_notetrack_scripts();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
override_footstep_notetrack_scripts()
{
	anim.notetracks[ "footstep_right_large" ] = ::noteTrackFootStep;
	anim.notetracks[ "footstep_right_small" ] = ::noteTrackFootStep;
	anim.notetracks[ "footstep_left_large" ] = ::noteTrackFootStep;
	anim.notetracks[ "footstep_left_small" ] = ::noteTrackFootStep;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
restore_footstep_notetrack_scripts()
{
	anim.notetracks[ "footstep_right_large" ] = animscripts\notetracks::noteTrackFootStep;
	anim.notetracks[ "footstep_right_small" ] = animscripts\notetracks::noteTrackFootStep;
	anim.notetracks[ "footstep_left_large" ] = animscripts\notetracks::noteTrackFootStep;
	anim.notetracks[ "footstep_left_small" ] = animscripts\notetracks::noteTrackFootStep;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
noteTrackFootStep( note, flagName )
{
	is_left = IsSubStr( note, "left" );
	is_large = IsSubStr( note, "large" );

	playFootStep( is_left, is_large );
	
	/*
	run_type = get_notetrack_movement();
	self PlaySound( "gear_rattle" + "_" + run_type );
	*/
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
playFootStep( is_left, is_large )
{
	if ( !IsAI( self ) )
	{
		self PlaySound( "step_run_dirt" );
		return;
	}

	groundType = "water";

	foot = "J_Ball_RI";
	if ( is_left )
	{
		foot = "J_Ball_LE";
	}

	run_type = "run";
	self thread play_sound_on_entity( "foot_flipper_underwater" );

	playBubbleEffect( foot, groundType );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
playBubbleEffect( foot, groundType )
{
	if ( !IsDefined( anim.optionalStepEffects[ groundType ] ) )
			return false;

	org = self GetTagOrigin( foot );
	angles = self.angles;
	forward = AnglesToForward( angles );
	back = forward * - 1;
	up = ( 0, 0, 1 );
	
	PlayFXOnTag( level._effect[ "step_" + groundType ], self, foot );
	return true;
}
