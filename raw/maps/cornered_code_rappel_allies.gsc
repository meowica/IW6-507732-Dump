#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include animscripts\shared;
#include animscripts\combat_utility;
#include maps\cornered_code;

#using_animtree( "generic_human" );

AIM_TYPE_UP		  = 2;
AIM_TYPE_LEFT	  = 4;
AIM_TYPE_STRAIGHT = 5;
AIM_TYPE_RIGHT	  = 6;
AIM_TYPE_DOWN	  = 8;

ally_rappel_start_aiming( rappel_type )
{
	Assert( IsAI( self ) );

	if ( IsDefined( self.is_aiming ) && self.is_aiming )
	{
		Assert( IsDefined( self.rappel_type_aim ) && self.rappel_type_aim == rappel_type );
		return;
	}
	
	ally_rappel_stop_aiming();
	
	self.isRappelShooting = false;
	self.is_aiming		  = true;
	self.no_ai			  = true;
	self.rappel_type_aim  = rappel_type;
	self disable_pain();

	self AnimCustom( maps\cornered_code_rappel_allies::custom_aim );
}

ally_rappel_stop_aiming()
{
	if ( !IsDefined( self.is_aiming ) || !self.is_aiming )
		return;

	self notify( "stop_rappel_aim" );
	self notify( "stop_rappel_aim_track" );
	self notify( "stop_rappel_aim_shoot" );

	self.isRappelShooting		 = undefined;
	self.is_aiming				 = undefined;
	self.no_ai					 = undefined;
	self.rappel_type_aim		 = undefined;
	self.angle_facing_wall		 = undefined;
	self.rappel_aim_idle_thread	 = undefined;
	self.rappel_shooting_loop	 = undefined;
	self.aim2_target			 = undefined;
	self.aim4_target			 = undefined;
	self.aim6_target			 = undefined;
	self.aim8_target			 = undefined;
	self.pitch_target			 = undefined;
	self.yaw_target				 = undefined;
	self.rappel_enemy			 = undefined;
	self.rappel_last_enemy_timer = undefined;
	self.rappel_reloading		 = undefined;
	self enable_pain();
	self.lastEnemy = undefined;
	self ClearAnim( %exposed_modern, 0.2 );
	self ClearAnim( %exposed_aiming, 0.2 );
	self ClearAnim( %rappel_aim	   , 0.2 );
	self ClearAnim( %rappel_fire   , 0.2 );
	self ClearAnim( %rappel_idle   , 0.2 );
	self.upaimlimit	   = 45;
	self.downaimlimit  = -45;
	self.rightaimlimit = 45;
	self.leftaimlimit  = -45;
}

ally_rappel_start_shooting()
{
	self.isRappelShooting = true;
}

ally_rappel_stop_shooting()
{
	self.isRappelShooting = false;
}

//ally_is_reloading()
//{
//	return ( IsDefined( self.rappel_reloading ) && self.rappel_reloading );
//}

ally_is_aiming()
{
	return ( IsDefined( self.is_aiming ) && self.is_aiming );
}

ally_is_calm_idling()
{
	return ( IsDefined( self.is_calm_idling ) && self.is_calm_idling );
}

ally_rappel_start_rope( rappel_type )
{
	start_pos = ally_rappel_get_rope_start( rappel_type );
	
	if ( !IsDefined( start_pos ) )
		return;
		
	self.is_on_rope = true;
		
	ally_rappel_setup_rope( rappel_type, start_pos );
	self thread ally_rappel_rope( rappel_type, start_pos );
}

ally_rappel_stop_rope()
{
	if ( !IsDefined( self.is_on_rope ) || !self.is_on_rope )
		return;
		
	self.is_on_rope = undefined;
	
	self notify( "stop_rope_management" );
	
	self.cnd_rappel_tele_rope Unlink();
}

//ally_rappel_delete_rope()
//{
//	if ( IsDefined( self.rappel_physical_rope_origin ) )
//		self.rappel_physical_rope_origin Delete();
//	if ( IsDefined( self.rappel_physical_rope_animation_origin ) )
//		self.rappel_physical_rope_animation_origin Delete();
//	if ( IsDefined( self.cnd_rappel_tele_rope ) )
//		self.cnd_rappel_tele_rope Delete();
//	
//	self.rope_unwind_anim	= undefined;
//	self.rope_unwind_length = undefined;
//}

ally_rappel_start_movement_horizontal( rappel_type, section, flag_to_end_on )
{
	ally_rappel_movement_setup( rappel_type, flag_to_end_on );
	ally_rappel_start_movement_horizontal_internal( rappel_type, section, flag_to_end_on );
}

ally_start_calm_idle( rappel_type )
{
	if ( IsDefined( self.is_calm_idling ) && self.is_calm_idling )
	{
		Assert( IsDefined( self.rappel_type_aim ) && self.rappel_type_aim == rappel_type );
		return;
	}
	
	self.is_calm_idling	 = true;
	self.no_ai			 = true;
	self.rappel_type_aim = rappel_type;
	self disable_pain();
		
	self AnimCustom( maps\cornered_code_rappel_allies::ally_calm_idle_internal );
}

ally_stop_calm_idle()
{
	if ( !IsDefined( self.is_calm_idling ) || !self.is_calm_idling )
		return;
	
	self notify( "stop_calm_idle" );
	
	self.is_calm_idling	   = undefined;
	self.no_ai			   = false;
	self.angle_facing_wall = undefined;
	self.rappel_type_aim   = undefined;
	self enable_pain();
}

// ****************************
// * Stealth Idle             *
// *********************************************************************************************************************************************************************
ally_calm_idle_internal()
{
	self endon( "stop_calm_idle" );
	
	base_idle			   = ally_rappel_get_aim_anim( AIM_TYPE_STRAIGHT );
	self.angle_facing_wall = rappel_get_angle_facing_wall( self.rappel_type_aim );
	
	self AnimMode( "nogravity" );
	self OrientMode( "face angle", self.angle_facing_wall );
	
	calm_idle_anim_ref = undefined;
	
	while ( true )
	{
		// do an additive idle fidgit
		self SetAnimKnob( %rappel_aim, 1, 0.2, 1.0 );
		self SetAnimKnob( base_idle	 , 1, 0.2, 1.0 );
		wait 0.1;
		
		self SetAnim( %rappel_idle, 1, 0.2, 1.0 );
		flagname = self.animname + "_idle";
		idleanim = aim_idle_get_random();
		self SetFlaggedAnimKnobLimitedRestart( flagname, idleanim, 1, 0.2, 1.0 );
		self waittillmatch( flagname, "end" );
		
		// do a full body idle fidgit
		calm_idle_anim_ref = calm_idle_get_random( calm_idle_anim_ref );
		calm_idle_anim	   = level.scr_anim[ self.animname ][ calm_idle_anim_ref ];
		self SetFlaggedAnimKnobLimitedRestart( flagname, calm_idle_anim, 1.0, 0.2, 1.0 );
		self waittillmatch( flagname, "end" );
	}
}

calm_idle_get_random( last_anim )
{
	min = 1;
	max = 4;
	num = RandomIntRange( min, ( max + 1 ) );
	
	anim_ref = "cnd_rappel_stealth_fidgit_" + num;
	
	if ( IsDefined( last_anim ) && last_anim == anim_ref )
	{
		num += 1;
		if ( num == ( max + 1 ) )
			num	 = min;
		anim_ref = "cnd_rappel_stealth_fidgit_" + num;
	}
	
	return anim_ref;
}

// ****************************
// * Ally Aim Setup           *
// *********************************************************************************************************************************************************************


// Aim Animation Zones ( ex: anim #2 is aiming 'up' )
//	7		8		9
//
//	4		5		6
//
// 	1		2		3

ally_setup_aim( transTime )
{
	Assert( IsDefined( transTime ) );
	setRappelAim = true;
/#
	if ( GetDvarInt( "debug_aim_use_exposed" ) == 1 )
	{
		self SetAnim( %exposed_modern, 1, .2 );
		self SetAnim( %exposed_aiming, 1, .2 );
		self ClearAnim( %scripted, 0.1 );
		setRappelAim = false;
	}
#/
	if ( setRappelAim )
		self SetAnimKnob( %rappel_aim, 1, .2 );
	self SetAnimKnob( ally_rappel_get_aim_anim( AIM_TYPE_STRAIGHT ), 1, transTime );
	self SetAnimKnob( ally_rappel_get_aim_anim( AIM_TYPE_UP )	   , 1, transTime );
	self SetAnimKnob( ally_rappel_get_aim_anim( AIM_TYPE_DOWN )	   , 1, transTime );
	self SetAnimKnob( ally_rappel_get_aim_anim( AIM_TYPE_LEFT )	   , 1, transTime );
	self SetAnimKnob( ally_rappel_get_aim_anim( AIM_TYPE_RIGHT )   , 1, transTime );
	self SetAnimLimited( rappel_aim_get_parent_node( AIM_TYPE_UP )	 , 0, transTime );
	self SetAnimLimited( rappel_aim_get_parent_node( AIM_TYPE_DOWN ) , 0, transTime );
	self SetAnimLimited( rappel_aim_get_parent_node( AIM_TYPE_LEFT ) , 0, transTime );
	self SetAnimLimited( rappel_aim_get_parent_node( AIM_TYPE_RIGHT ), 0, transTime );
}

aim_idle_thread()
{
	self endon( "end_aim_idle_thread" );
	
/#
		if ( GetDvar( "debug_ally_aim", "0" ) != "0" )
			return;
#/
	
	if ( IsDefined( self.rappel_aim_idle_thread ) )
		return;
	self.rappel_aim_idle_thread = true;
	
	// wait a bit before starting idle since firing will end the idle thread
	wait 0.1;
	
	// this used to be setAnim, but it caused problems with turning on its parent nodes when they were supposed to be off (like during pistol pullout).
	self SetAnimLimited( %rappel_idle, 1, .2 );
	
	for ( i = 0;; i++ )
	{
		flagname = "idle" + i;

		idleanim = aim_idle_get_random();
		
		self SetFlaggedAnimKnobLimitedRestart( flagname, idleanim, 1, 0.2 );
		
		self waittillmatch( flagname, "end" );

/#
		if ( GetDvar( "debug_ally_aim", "0" ) != "0" )
			return;
#/
	}
	
	self ClearAnim( %rappel_idle, .1 );
}

aim_idle_get_random()
{
	is_shooting	  = ( IsDefined( self.isRappelShooting ) && self.isRappelShooting );
	do_not_fidgit = ( IsDefined( self.rappel_disable_fidgit ) && self.rappel_do_not_fidgit );
	
	if ( is_shooting || do_not_fidgit )
	{
		return %cnd_rappel_idle;
	}
	else
	{
		num = RandomIntRange( 0, 3 );
		
		switch ( num )
		{
			case 0:
				return %cnd_rappel_idle;
			case 1:
				return %cnd_rappel_idle_fidgit_1;
			case 2:
				return %cnd_rappel_idle_fidgit_2;
		}
	}
}

ally_rappel_get_enemy()
{
	cur_time	 = GetTime();
	next_time	 = cur_time + 5000;
	has_enemy	 = IsDefined( self.rappel_enemy );
	see_enemy	 = has_enemy && self CanSee( self.rappel_enemy );
	new_enemy	 = false;
	player_enemy = undefined;
	
	if ( has_enemy )
	{
		player_enemy = level.player player_get_favorite_enemy( 1500 );
		if ( IsDefined( player_enemy ) && self.rappel_enemy == player_enemy )
			new_enemy = true;
	}
	
	if ( see_enemy )
		self.rappel_last_enemy_timer = next_time;
	
	timer_out = has_enemy && self.rappel_last_enemy_timer < cur_time;
		
	switch_enemy = !has_enemy || timer_out || new_enemy;
	
	if ( switch_enemy )
	{
		enemies		  = GetAIArray( "axis" );
		closest_sq	  = -1;
		closest_enemy = undefined;
		if ( !IsDefined( player_enemy ) )
			player_enemy = level.player player_get_favorite_enemy( 1500 );
		
		foreach ( enemy in enemies )
		{
			if ( !self CanSee( enemy ) )
				continue;
				
			if ( IsDefined( enemy.ignoreme ) && enemy.ignoreme )
				continue;
				
			if ( IsDefined( player_enemy ) && enemy == player_enemy )
				continue;
			
			dist_sq = DistanceSquared( self.origin, enemy.origin );
			if ( closest_sq == -1 || dist_sq < closest_sq )
			{
				closest_enemy = enemy;
				closest_sq	  = dist_sq;
			}
		}
		
		self.rappel_last_enemy_timer = next_time;
		self.rappel_enemy			 = closest_enemy;
	}
	
	return self.rappel_enemy;
}

end_aim_idle_thread()
{
	self notify( "end_aim_idle_thread" );
	self.rappel_aim_idle_thread = undefined;
	self ClearAnim( %rappel_idle, .1 );
}

// ****************************
// * Ally Aim Logic           *
// *********************************************************************************************************************************************************************


custom_aim()
{
	self endon( "stop_rappel_aim" );
	self endon( "death" );
	
	self notify( "stop_loop" );
	
	custom_aim_internal();
	
	self waittill( "forever" );
}

custom_aim_internal()
{
	self.angle_facing_wall = rappel_get_angle_facing_wall( self.rappel_type_aim );

/#
	if ( GetDvarInt( "debug_ally_aim" ) == 1 )
		self.angle_facing_wall = rappel_get_angle_facing_wall( "stealth" );
#/
	
	self AnimMode( "nogravity" );
	self OrientMode( "face angle", self.angle_facing_wall );
	
	ally_setup_aim( 0.2 );
	self childthread aim_idle_thread();
	
/#
	if ( GetDvarInt( "debug_ally_aim" ) == 1 )
	{
		level endon( "debug_ally_aim_complete" );
		level waittill( "forever" );
	}
#/
	
	self.upaimlimit	   = 89.8;
	self.downaimlimit  = -19.6;
	self.rightaimlimit = 89.2;
	self.leftaimlimit  = -90.2;
	
	up	  = rappel_aim_get_parent_node( AIM_TYPE_UP );
	left  = rappel_aim_get_parent_node( AIM_TYPE_LEFT );
	right = rappel_aim_get_parent_node( AIM_TYPE_RIGHT );
	down  = rappel_aim_get_parent_node( AIM_TYPE_DOWN );
	
	self thread trackLoop( down, left, right, up );
	if ( !IsDefined( self.rappel_shooting_loop ) || !self.rappel_shooting_loop )
		self thread ally_shooting_loop();
}

trackLoop( aim2, aim4, aim6, aim8 )
{
	self endon( "stop_rappel_aim_track" );
	self endon( "death" );
	
	angleDeltas		  = ( 0, 0, 0 );
	aimPitchAdd		  = 0;
	aimYawAdd		  = 0;
	aimAddAngles	  = ( aimPitchAdd, aimYawAdd, 0 );
	zeroIfNotInLimits = false;
	
	while ( true )
	{
		shootFromPos = self GetEye();
		
		enemy = ally_rappel_get_enemy();
		if ( IsDefined( enemy ) )
		{
			self.shootEnt = enemy;
			self.shootPos = self.shootEnt GetShootAtPos();
		}
		
		shootPos = undefined;
		if ( IsDefined( self.shootPos ) )
			shootPos = self.shootPos;
		if ( IsDefined( self.shootEnt ) )
			shootPos = self.shootEnt GetShootAtPos();
	
		useShootAtPos = IsDefined( shootPos );
		shootPosParam = ( 0, 0, 0 );
		if ( useShootAtPos )
			shootPosParam = shootPos;
		
		stepOutYaw	  = 0;
		useStepOutYaw = IsDefined( self.stepOutYaw );
		if ( useStepOutYaw )
			stepOutYaw = self.stepOutYaw;
		
		angleDeltas = self GetAimAngle( shootFromPos, shootPosParam, useShootAtPos, aimAddAngles, stepOutYaw, useStepOutYaw, zeroIfNotInLimits );
		
		pitchDelta	= angleDeltas[ 0 ];
		yawDelta	= angleDeltas[ 1 ];
		angleDeltas = undefined;
/#
		if ( GetDvar( "debug_ally_aim_direction", "0" ) == "1" )
		{
			start	   = self GetTagOrigin( "tag_flash" );
			aim_vector = VectorNormalize( AnglesToForward( self GetTagAngles( "tag_flash" ) ) );
			end		   = start + ( aim_vector * 2000 );
			Line( start, end, ( 0, 1, 0 ), 1 );
			if ( IsDefined( self.rappel_enemy ) && self CanSee( self.rappel_enemy ) )
				debug_star( shootFromPos, ( 0, 1, 1 ) );
			if ( useShootAtPos )
				Line( shootFromPos, shootPos, ( 1, 1, 0 ) );
		}
#/		
		trackLoop_setAnimWeights( aim2, aim4, aim6, aim8, pitchDelta, yawDelta );

		waitframe();
	}
}

trackLoop_setAnimWeights( aim2, aim4, aim6, aim8, pitchDelta, yawDelta )
{
	enemy = self.rappel_enemy;
	
	reloading  = IsDefined( self.rappel_reloading ) && self.rappel_reloading;
	new_enemy  = !reloading && IsDefined( enemy ) && ( !IsDefined( self.lastEnemy ) || enemy != self.lastEnemy );
	has_target = ( IsDefined( self.pitch_target ) && IsDefined( self.yaw_target ) );
	
	if ( reloading )
	{
		pitchDelta = 0;
		yawDelta   = 0;
		if ( !IsDefined( self.reload_aim_active ) )
		{
			self.reload_aim_active = true;
			has_target			   = true;
		}
	}

	if ( new_enemy || has_target ) // use a formula to quickly get aim close to the enemy
	{
		self.lastEnemy = enemy;
		ally_set_initial_weights( aim2, aim4, aim6, aim8, pitchDelta, yawDelta );
		ally_transition_to_target_weights( aim2, aim4, aim6, aim8 );
	}
	else if ( reloading )
	{
		self.reload_aim_active = undefined;
		ally_reset_weights();
		self notify( "aimed_forward" );
	}
	else if ( IsDefined( enemy ) ) // dynamically try to aim closer while still pointed at the same enemy
	{
		ally_aim_closer_to( aim2, aim4, aim6, aim8, pitchDelta, yawDelta );
	}
}

ally_reset_weights()
{
	self ClearAnim( %rappel_aim, 0.2 );
}

ally_rappel_get_aim_yaw()
{
	Assert( IsDefined( self.angle_facing_wall ) );
	
	aim_yaw = self.angle_facing_wall - AngleClamp180( self GetTagAngles( "tag_flash" )[ 1 ] );
	
	return aim_yaw;
}

ally_rappel_get_aim_pitch()
{
	aim_pitch = -1 * AngleClamp180( self GetTagAngles( "tag_flash" )[ 0 ] );
	
	return aim_pitch;
}

get_weight_change( aim_type, degree_change )
{
	if ( aim_type == AIM_TYPE_UP )
		return ( ( degree_change / 8.7 ) * 0.1 );
	else if ( aim_type == AIM_TYPE_DOWN )
		return ( ( degree_change / 2.2 ) * 0.1 );
	else if ( aim_type == AIM_TYPE_LEFT )
		return ( ( degree_change / 8.8 ) * 0.1 );
	else if ( aim_type == AIM_TYPE_RIGHT )
		return ( ( degree_change / 9.1 ) * 0.1 );
}

ally_aim_closer_to( aim2, aim4, aim6, aim8, pitchDelta, yawDelta )
{
	yawTolerance   = 0.1;
	pitchTolerance = 0.1;
	fastChange	   = true;
	
	Assert( IsDefined( self.angle_facing_wall ) );
	
	aim_yaw		 = ally_rappel_get_aim_yaw();
	aim_yaw_diff = yawDelta - aim_yaw;
	
	if ( abs( aim_yaw_diff ) < 1 )
		fastChange = false;
	
	aim_pitch	   = ally_rappel_get_aim_pitch();
	aim_pitch_diff = pitchDelta - aim_pitch;
	
	if ( abs( aim_pitch_diff ) < 1 )
		fastChange = false;
	
	yawChanged				= abs( yawDelta ) > 0;
	yawChangedMorethanPitch = abs( aim_yaw_diff ) > abs( aim_pitch_diff );
	yawChangedEnough		= abs( aim_yaw_diff ) > yawTolerance;
	
	pitchChanged	   = abs( pitchDelta	 )> 0;
	pitchChangedEnough = abs( aim_pitch_diff )> pitchTolerance;
	
	weight = 0;
	
	if ( yawChanged && yawChangedMorethanPitch && yawChangedEnough )
	{
		if ( yawDelta > 0 )
		{
			Assert( yawDelta <= self.rightAimLimit );
			self _ally_aim_closer_set_anim_weight( aim6, AIM_TYPE_RIGHT, aim4, aim_yaw_diff, fastChange );
		}
		else if ( yawDelta < 0 )
		{
			Assert( yawDelta >= self.leftAimLimit );
			self _ally_aim_closer_set_anim_weight( aim4, AIM_TYPE_LEFT, aim6, aim_yaw_diff, fastChange );
		}
	}
	else if ( pitchChanged && pitchChangedEnough )
	{
		if ( pitchDelta > 0 )
		{
			Assert( pitchDelta <= self.upAimLimit );
			self _ally_aim_closer_set_anim_weight( aim8, AIM_TYPE_UP, aim2, aim_pitch_diff, fastChange );
		}
		else if ( pitchDelta < 0 )
		{
			Assert( pitchDelta >= self.downAimLimit );
			self _ally_aim_closer_set_anim_weight( aim2, AIM_TYPE_DOWN, aim8, aim_pitch_diff, fastChange );
		}
	}
}

_ally_aim_closer_set_anim_weight( aim, aim_type, other_aim, aim_percent_diff, fast )
{
	aimBlendTime  = 0.1;
	degree_change = 2;
	
	if ( !fast )
		degree_change = 0.5;
	
	currentWeight = self GetAnimWeight( aim );
	weightChange  = get_weight_change( aim_type, degree_change );
	weightChange *= sign( aim_percent_diff );
	if ( aim_type == AIM_TYPE_LEFT || aim_type == AIM_TYPE_DOWN )
		weightChange *= -1;
	weight = currentWeight + weightChange;
	weight = clamp( weight, 0, 1 );
	
	self SetAnimLimited( other_aim, 0	  , aimBlendTime, 1, true );
	self SetAnimLimited( aim	  , weight, aimBlendTime, 1, true );
}

ally_transition_to_target_weights( aim2, aim4, aim6, aim8 )
{
	if ( IsDefined( self.aim2_target ) && _ally_transition_to_weight( aim2, AIM_TYPE_DOWN, aim8, AIM_TYPE_UP, self.aim2_target ) )
		self.aim2_target = undefined;
	if ( IsDefined( self.aim4_target ) && _ally_transition_to_weight( aim4, AIM_TYPE_LEFT, aim6, AIM_TYPE_RIGHT, self.aim4_target ) )
		self.aim4_target = undefined;
	if ( IsDefined( self.aim6_target ) && _ally_transition_to_weight( aim6, AIM_TYPE_RIGHT, aim4, AIM_TYPE_LEFT, self.aim6_target ) )
		self.aim6_target = undefined;
	if ( IsDefined( self.aim8_target ) && _ally_transition_to_weight( aim8, AIM_TYPE_UP, aim2, AIM_TYPE_DOWN, self.aim8_target ) )
		self.aim8_target = undefined;
		
	if ( !IsDefined( self.aim2_target ) && !IsDefined( self.aim4_target ) && !IsDefined( self.aim6_target ) && !IsDefined( self.aim8_target ) )
	{
		self.pitch_target = undefined;
		self.yaw_target	  = undefined;
	}
}

_ally_transition_to_weight( aim, aim_type, other_aim, other_aim_type, targetWeight )
{
	weightChange	= 0.1;
	weightTolerance = 0.1;
	aimBlendTime	= 0.1;
	weight			= 0;
	weightDiff		= 0;
	degree_change	= 15;
	
	// if there is weight in the wrong direction, transition that out first to 0
	currentWeight = self GetAnimWeight( other_aim );
	if ( currentWeight > 0 )
	{
		weightDiff	 = 0 - currentWeight;
		weightChange = get_weight_change( other_aim_type, degree_change );
		aim			 = other_aim;
	}
	else
	{
		currentWeight = self GetAnimWeight( aim );
		weightDiff	  = targetWeight - currentWeight;
		
		if ( abs( weightDiff ) <= weightTolerance )
			return true;
		
		weightChange = get_weight_change( aim_type, degree_change );
	}
		
	weightChange *= sign( weightDiff );
	if ( weightChange > 0 )
		weightChange = min( weightChange, weightDiff );
	else
		weightChange = max( weightChange, weightDiff );
		
	weight = currentWeight + weightChange;
	
	self SetAnimLimited( aim, weight, aimBlendTime, 1, true );
	
	return false;
}

ally_set_initial_weights( aim2, aim4, aim6, aim8, pitchDelta, yawDelta )
{
	if ( yawDelta >= 0 )
	{
		Assert( yawDelta <= self.rightAimLimit );
		self.aim6_target = _ally_get_yaw_right_aim_weight( yawDelta );
		self.aim4_target = undefined;
		
	}
	else if ( yawDelta < 0 )
	{
		Assert( yawDelta >= self.leftAimLimit );
		self.aim4_target = _ally_get_yaw_left_aim_weight( yawDelta );
		self.aim6_target = undefined;
	}
	
	if ( pitchDelta >= 0 )
	{
		Assert( pitchDelta <= self.upAimLimit );
		self.aim8_target = _ally_get_pitch_up_aim_weight( pitchDelta );
		self.aim2_target = undefined;
	}
	else if ( pitchDelta < 0 )
	{
		Assert( pitchDelta >= self.downAimLimit );
		self.aim2_target = _ally_get_pitch_down_aim_weight( pitchDelta );
		self.aim8_target = undefined;
	}
	
	self.pitch_target = pitchDelta;
	self.yaw_target	  = yawDelta;
}

_ally_get_pitch_down_aim_weight( pitchDelta )
{
	return clamp( ( ( abs( pitchDelta ) * 0.0517 ) - 0.0138 ), 0, 1.0 ); // y = 0.0517x - 0.0138
}

_ally_get_pitch_up_aim_weight( pitchDelta )
{
	return clamp( ( ( abs( pitchDelta ) * 0.0111 ) + 0.0032 ), 0, 1.0 ); // y = 0.0111x + 0.0032
}

_ally_get_yaw_right_aim_weight( yawDelta )
{
	return clamp( ( ( abs( yawDelta ) * 0.0112 ) - 0.0025 ), 0, 1.0 ); // y = 0.0112x - 0.0025
}

_ally_get_yaw_left_aim_weight( yawDelta )
{
	return clamp( ( ( abs( yawDelta ) * 0.011 ) + 0.0031 ), 0, 1.0 ); // y = 0.011x + 0.0031
}

// ****************************
// * Animations               *
// *********************************************************************************************************************************************************************


rappel_aim_get_parent_node( aimType )
{
/#
	if ( GetDvarInt( "debug_aim_use_exposed" ) == 1 )
	{
		return rappel_aim_get_parent_node_exposed( aimType );
	}
#/
	if ( aimType == AIM_TYPE_UP )
		return %rappel_aim_8;
	else if ( aimType == AIM_TYPE_LEFT )
		return %rappel_aim_4;
	else if ( aimType == AIM_TYPE_RIGHT )
		return %rappel_aim_6;
	else if ( aimType == AIM_TYPE_DOWN )
		return %rappel_aim_2;
	else
		AssertMsg( "rappel_aim_get_parent_node encountered an unknown aimType: " + aimType );
}

ally_rappel_get_aim_anim( aimType )
{
/#
	if ( GetDvarInt( "debug_aim_use_exposed" ) == 1 )
	{
		return rappel_get_aim_anim_exposed( aimType );
	}
#/
	if ( aimType == AIM_TYPE_UP )
		return %cnd_rappel_stealth_aim_8_baker_add;
	else if ( aimType == AIM_TYPE_LEFT )
		return %cnd_rappel_stealth_aim_4_baker_add;
	else if ( aimType == AIM_TYPE_STRAIGHT )
		return %cnd_rappel_stealth_aim_5_baker_add;
	else if ( aimType == AIM_TYPE_RIGHT )
		return %cnd_rappel_stealth_aim_6_baker_add;
	else if ( aimType == AIM_TYPE_DOWN )
		return %cnd_rappel_stealth_aim_2_baker_add;
	else
		AssertMsg( "ally_rappel_get_aim_anim encountered an unknown aimType: " + aimType );
}

// ****************************
// * Fire Logic		          *
// *********************************************************************************************************************************************************************


ally_shooting_loop()
{
	self endon( "stop_rappel_aim_shoot" );
	self endon( "death" );
	
	self.rappel_shooting_loop = true;
	
/#
	SetDvarIfUninitialized( "ally_debug_shooting", "0" );
#/
		
	while ( true )
	{
		waitframe();
		
/#
		if ( GetDvarInt( "ally_debug_shooting" ) && self == level.allies[ 0 ] )
		{
			self.isRappelShooting = 1;
			
			start		  = self GetTagOrigin( "tag_flash" );
			aim_vector	  = VectorNormalize( AnglesToForward( self GetTagAngles( "tag_flash" ) ) );
			end			  = start + ( aim_vector * 2000 );
			self.shootPos = end;
		}
#/
		
		if ( !IsDefined( self.isRappelShooting ) || !self.isRappelShooting )
			continue;
			
		has_shoot_ent = IsDefined( self.shootEnt );
		
/#
		if ( GetDvarInt( "ally_debug_shooting" ) && self == level.allies[ 0 ] )
			has_shoot_ent = true;
#/
		
		self ally_rappel_reload();
		
		if ( aimed_at_shoot_ent_or_pos() && has_shoot_ent )
		{
			self.shootStyle = "burst";
			self.fastBurst	= false;
			self ally_shoot_at_enemy();
			self hide_fire_show_aim_idle();
		}
	}
}

aimed_at_shoot_ent_or_pos()
{
	aimYawDiffTolerance	  = 5;
	aimPitchDiffTolerance = 5;

	if ( !IsDefined( self.shootPos ) )
	{
		Assert( !IsDefined( self.shootEnt ) );

		return false;
	}

	weaponAngles	 = self GetMuzzleAngle();
	shootFromPos	 = self GetMuzzlePos();
	anglesToShootPos = VectorToAngles( self.shootPos - shootFromPos );

	absyawdiff = AbsAngleClamp180( weaponAngles[ 1 ] - anglesToShootPos[ 1 ] );

	if ( absyawdiff > aimYawDiffTolerance )
		return false;

	return AbsAngleClamp180( weaponAngles[ 0 ] - anglesToShootPos[ 0 ] ) <= aimPitchDiffTolerance;
}

ally_shoot_at_enemy()
{
	self endon( "shoot_behavior_change" );
	self endon( "stopShooting" );
		
	fireAnim = ally_get_fire_animation();

	if ( aimButDontShoot() )
		return;
	
	if ( self.shootStyle == "full" )
	{
		self ally_fire_until_out_of_ammo( fireAnim, true, animscripts\shared::decideNumShotsForFull() );
	}
	else if ( self.shootStyle == "burst" || self.shootStyle == "semi" )
	{
		numShots = 4; // the animation fires 4 times
		self ally_fire_until_out_of_ammo( fireAnim, true, numShots );
	}
	else if ( self.shootStyle == "single" )
	{
		self ally_fire_until_out_of_ammo( fireAnim, true, 1 );
	}
	else
	{
		Assert( self.shootStyle == "none" );
		self waittill( "hell freezes over" ); // waits for the endons to happen
	}
}

ally_fire_until_out_of_ammo( fireAnim, stopOnAnimationEnd, maxshots )
{
	animName = "fireAnim_" + getUniqueFlagNameIndex();

	// reset our accuracy as we aim
	maps\_gameskill::resetMissTime();

	self show_fire_hide_aim_idle();

	rate = 1.0;
	if ( IsDefined( self.shootRateOverride ) )
		rate = self.shootRateOverride;
	else if ( self.shootStyle == "full" )
		rate = animscripts\weaponList::autoShootAnimRate() * RandomFloatRange( 0.5, 1.0 );
	else if ( self.shootStyle == "burst" )
		rate = animscripts\weaponList::burstShootAnimRate();
	else if ( usingSidearm() )
		rate = 3.0;
	else if ( usingShotGun() )
		rate = shotgunFireRate();

	self SetFlaggedAnimKnobRestart( animName, fireAnim, 1, .2, rate );

	ally_fire_until_out_of_ammo_internal( animName, fireAnim, stopOnAnimationEnd, maxshots );

	self hide_fire_show_aim_idle();
}

ally_fire_until_out_of_ammo_internal( animName, fireAnim, stopOnAnimationEnd, maxshots )
{
	self endon( "enemy" ); // stop shooting if our enemy changes, because we have to reset our accuracy and stuff

	if ( stopOnAnimationEnd )
	{
		self thread NotifyOnAnimEnd( animName, "fireAnimEnd" );
		self endon( "fireAnimEnd" );
	}

	if ( !IsDefined( maxshots ) )
		maxshots = -1;

	numshots = 0;

	hasFireNotetrack = AnimHasNotetrack( fireAnim, "fire" );

	self thread FireUntilOutOfAmmo_WaitTillEnded();

	while ( numshots < maxshots && maxshots > 0 ) // note: maxshots == -1 if no limit
	{
		if ( hasFireNotetrack )
			self waittillmatch( animName, "fire" );

		if ( !self.bulletsInClip )
		{
			if ( !cheatAmmoIfNecessary() )
				break;
		}
		
		self shoot_at_shoot_ent_or_pos();

		AssertEx( self.bulletsInClip >= 0, self.bulletsInClip );
		self.bulletsInClip--;
		
		numshots++;

		self thread shotgunPumpSound( animName );

		if ( self.fastBurst && numshots == maxshots )
			break;

 		if ( !hasFireNotetrack || ( maxShots == 1 && self.shootStyle == "single" ) )
			self waittillmatch( animName, "end" );
	}

	self ShootStopSound();

	if ( stopOnAnimationEnd )
		self notify( "fireAnimEnd" ); // stops NotifyOnAnimEnd()
}

shoot_at_shoot_ent_or_pos()
{
	if ( IsDefined( self.shootPos ) )
	{
		Assert( IsDefined( self.shootPos ) );
		
		start = self GetMuzzlePos();
		end = self.shootPos;
		spread = 4;

		endpos = BulletSpread( start, end, spread );
		
//		Line( start, endpos, ( 1, 0, 0 ), 1.0, false, 60 );
	
		self.a.lastShootTime = GetTime();
	
		self notify( "shooting" );
		self Shoot( 1, endPos, true );
	}
}

start_fire_and_aim_idle_thread()
{
	if ( !IsDefined( self.rappel_aim_idle_thread ) )
	{
		self.lastEnemy = undefined; // force the aim to set initial weight
		self thread custom_aim_internal();
	}
}

end_fire_and_anim_idle_thread()
{
	end_aim_idle_thread();
	self ClearAnim( %rappel_fire, .1 );
	self notify( "stop_rappel_aim_track" );
}

show_fire_hide_aim_idle()
{
	if ( IsDefined( self.rappel_aim_idle_thread ) )
		self SetAnim( %rappel_idle, 0, .2 );
		
	self SetAnim( %rappel_fire, 1, .1 );
}

hide_fire_show_aim_idle()
{
	if ( IsDefined( self.rappel_aim_idle_thread ) )
		self SetAnim( %rappel_idle, 1, .2 );
		
	self SetAnim( %rappel_fire, 0, .1 );
}

ally_get_fire_animation()
{
	return %cnd_rappel_stealth_fire_baker_add;
}

ally_rappel_reload()
{
	if ( !NeedToReload( 0.1 ) )
		return false;
	
	self.rappel_reloading = true;
	self waittill_notify_or_timeout_return( "aimed_forward", 5.0 );
	self end_fire_and_anim_idle_thread();
	
	reloadAnim = %cnd_rappel_fire_reload_1;

	self.finishedReload = false;

	// pistol reload looks weird pointing at fixed current angle
	if ( WeaponClass( self.weapon ) == "pistol" )
		self OrientMode( "face default" );
		
	self ally_do_reload_anim( reloadAnim ); // this will return at the time when we should start aiming
	self notify( "abort_reload" ); // make sure threads that doReloadAnim() started finish

	if ( self.finishedReload )
		self animscripts\weaponList::RefillClip();

	self ClearAnim( %cnd_rappel_fire_reload_1, .2 );
	self.keepClaimedNode = false;

	self.rappel_reloading = undefined;
	self notify( "rappel_done_reloading" );

	self.finishedReload = undefined;
	
	self start_fire_and_aim_idle_thread();
	
	waitframe(); // wait here so the aim thread can get running

	return true;
}

ally_do_reload_anim( reloadAnim )
{
	self endon( "abort_reload" );

	animRate = 1;
	
	if ( !self usingSidearm() && !isShotgun( self.weapon ) && IsDefined( self.rappel_enemy ) && self CanSee( self.rappel_enemy ) && DistanceSquared( self.rappel_enemy.origin, self.origin ) < 1024 * 1024 )
		animRate = 1.2;

	flagName = "reload_" + getUniqueFlagNameIndex();

	self ClearAnim( %root, 0.2 );
	self SetFlaggedAnimRestart( flagName, reloadAnim, 1, .2, animRate );
	self DoNoteTracks( flagName );

	self.finishedReload = true;
}

// ****************************
// * Movement		          *
// *********************************************************************************************************************************************************************


ally_rappel_start_movement_horizontal_internal( rappel_type, section, flag_to_end_on )
{
	level endon( flag_to_end_on );
	if ( rappel_type == "stealth" )
		level endon( self.stealth_broken_flag );
		
	move_back_delay = 2;

	movement_flag = self.animname + "_is_moving";
	flag_clear( movement_flag );
	
	stop_flag = self.animname + "_stop_anim_move";
	flag_clear( stop_flag );
	
	self.movement_back	= false;
	self.move_type		= "idle"; // also "move_back", "move_away", "turn_away"
	self.last_move_time = 0;
	
	self thread animate_after_movement( movement_flag, rappel_type );
	
	while ( 1 )
	{
		dist_to_player_sq		= ally_rappel_Distance2DSquared_to_player();
		player_moving_toward_me = !IsDefined( self.player_moving_toward_me ) || self.player_moving_toward_me;
		above_or_inside_me		= dist_to_player_sq <= ( 60 * 60 );
		should_move				= player_moving_toward_me || above_or_inside_me;
		
		if ( dist_to_player_sq < self.close_distance_sq )
		{
			if ( !flag( movement_flag ) && player_moving_toward_me && _ally_is_current_volume( self.in_volume ) ) //their center and volume closest to the player
			{
				self thread animate_til_volume( "away", movement_flag, self.center_volume, self.out_volume, flag_to_end_on, rappel_type );
			}
			else if ( !flag( movement_flag ) && player_moving_toward_me && _ally_is_current_volume( self.center_volume ) ) //volume in between being closest and farthest away from player
			{
				self thread animate_til_volume( "away", movement_flag, self.out_volume, undefined, flag_to_end_on, rappel_type );
			}
			else if ( !flag( movement_flag ) && player_moving_toward_me && _ally_is_current_volume( self.out_volume ) ) //volume farthest away from player's center
			{
				//do nothing, dude is as far out as he is allowed to go
			}
			else //dude is moving
			{
				if ( self.movement_back )
					self thread animate_opposite_direction( movement_flag, flag_to_end_on, rappel_type, flag( movement_flag ) );
			}
		}
		else if ( dist_to_player_sq > self.far_distance_sq )
		{
			elapsedTime = GetTime() - self.last_move_time;
			
			// wait at least 5 seconds until you move back
			if ( flag( movement_flag ) || ( elapsedTime < ( move_back_delay * 1000 ) ) || player_moving_toward_me )
			{
				waitframe();
				continue;
			}
	
			if ( _ally_is_current_volume( self.out_volume ) ) //volume farthest away from player's center
			{
				should_move = false;
				
				next_volume = self.center_volume;
				Assert( IsDefined( next_volume ) );
				
				// combat version with structs can probably be replaced with the centriod version but i didn't want to change too much at once
				if ( rappel_type == "combat" )
				{
					struct				= getstruct( self.center_volume.targetname + "_struct_" + section, "targetname" );
					distance_between_sq = Distance2DSquared( level.player.origin, struct.origin );
					should_move			= distance_between_sq > self.distance_from_next_volume_sq;
				}
				else
				{
					distance_between_sq = Distance2DSquared( level.player.origin, next_volume GetCentroid() );
					should_move			= distance_between_sq > self.distance_from_next_volume_sq;
				}
				
				//only move back if the distance between the next volume in and the player is greater than 
				//their self.distance_from_next_volume_sq, otherwise the dude will keep going back and forth
				if ( should_move )
				{
					self thread animate_til_volume( "back", movement_flag, self.center_volume, self.in_volume, flag_to_end_on, rappel_type );
				}
			}
			else if ( _ally_is_current_volume( self.center_volume ) ) //volume in between being closest and farthest away from player
			{
				should_move = false;
				
				next_volume = self.in_volume;
				Assert( IsDefined( next_volume ) );

				if ( rappel_type == "combat" )
				{
					struct				= getstruct( self.in_volume.targetname + "_struct_" + section, "targetname" );
					distance_between_sq = Distance2DSquared( level.player.origin, struct.origin );
					should_move			= distance_between_sq > self.distance_from_next_volume_sq;
				}
				else
				{
					distance_between_sq = Distance2DSquared( level.player.origin, next_volume GetCentroid() );
					should_move			= distance_between_sq > self.distance_from_next_volume_sq;
				}
				
				//only move back if the distance between the next volume in and the player is greater than 
				//their self.distance_from_next_volume_sq, otherwise the dude will keep going back and forth
				if ( should_move )
				{
					self thread animate_til_volume( "back", movement_flag, self.in_volume, undefined, flag_to_end_on, rappel_type );
				}
			}
			else if ( _ally_is_current_volume( self.in_volume ) ) //their center and volume closest to the player
			{
				//do nothing, dude is as far in as he is allowed to go
			}
			else //dude isn't touching a volume
			{
				self thread animate_til_volume( "back", movement_flag, self.center_volume, self.in_volume, flag_to_end_on, rappel_type );
			}
		}
		waitframe();
	}
}

ally_rappel_Distance2DSquared_to_player()
{
	ally_org = self GetTagOrigin( "J_MainRoot" );
	if ( IsDefined( level.rpl_plyr_anim_origin ) )
		player_org = level.rpl_plyr_anim_origin.origin;
	else
		player_org = level.player.origin;

	dist_sq = Distance2DSquared( ally_org, player_org );
	return dist_sq;
}

_ally_is_current_volume( volume )
{
	return ( IsDefined( volume ) && ( self IsTouching( volume ) || self.last_volume == volume ) );
}

_ally_set_last_volume()
{
	Assert( IsDefined( self.in_volume ) || IsDefined( self.center_volume ) || IsDefined( self.out_volume ) );
	
	closest_dist_sq	 = -1;
	self.last_volume = undefined;
	
	if ( IsDefined( self.in_volume ) )
	{
		self.last_volume = self.in_volume;
		if ( self IsTouching( self.in_volume ) )
			return;
		closest_dist_sq = Distance2DSquared( self.origin, self.in_volume GetCentroid() );
	}
	
	if ( IsDefined( self.center_volume ) )
	{
		dist_sq = Distance2DSquared( self.origin, self.center_volume GetCentroid() );
		if ( closest_dist_sq == -1 || dist_sq < closest_dist_sq || self IsTouching( self.center_volume ) )
		{
			self.last_volume = self.center_volume;
			closest_dist_sq	 = dist_sq;
		}
		
		if ( self IsTouching( self.center_volume ) )
			return;
	}
	
	if ( IsDefined( self.out_volume ) )
	{
		if ( self IsTouching( self.out_volume ) )
			self.last_volume = self.out_volume;
	}
	
	Assert( IsDefined( self.last_volume ) );
}

ally_rappel_movement_setup( rappel_type, flag_to_end_on )
{
	// setup volumes
	if ( rappel_type == "stealth" )
	{
		self.center_volume = GetEnt( self.animname + "_stealth_in", "targetname" );
		self.out_volume	   = GetEnt( self.animname + "_stealth_out", "targetname" );
		self.in_volume	   = GetEnt( self.animname + "_stealth_center", "targetname" );
		/*
		/#
							   //   ent 		     time_sec    color 	   
		thread draw_entity_bounds( self.out_volume, 999, (0, 0, 1) );
		thread draw_entity_bounds( self.in_volume , 999, (0, 1, 0) );
		thread draw_entity_bounds( self, 999, ( 1, 1, 0 ), true );
		#/
		*/
		_ally_set_last_volume();
	}
	else
	{
		self.center_volume = GetEnt( self.animname + "_center_combat", "targetname" );
		self.in_volume	   = GetEnt( self.animname + "_in_combat", "targetname" );
		self.out_volume	   = GetEnt( self.animname + "_out_combat", "targetname" );
		
		//the allies' center volume
		self.last_volume = GetEnt( self.animname + "_in_combat", "targetname" );
	}

	// setup distances
	if ( self.animname == "rorke" )
	{			
		if ( rappel_type == "stealth" )
		{
			self.close_distance_sq			  = 220 * 220;
			self.far_distance_sq			  = 420 * 420;
			self.distance_from_next_volume_sq = 245 * 245;
		}
		else
		{
			//Rorke starts at a distance of 230.307 units away from you
			self.close_distance_sq			  = 225 * 225;
			self.far_distance_sq			  = 425 * 225;
			self.distance_from_next_volume_sq = 245 * 245;
		}
	}
	else	
	{	
		if ( rappel_type == "stealth" )
		{
			self.close_distance_sq			  = 220 * 220;
			self.far_distance_sq			  = 420 * 420;
			self.distance_from_next_volume_sq = 245 * 245;
		}
		else
		{
			//Baker starts at a distance of 174.044 units away from you
			self.close_distance_sq			  = 170 * 170;
			self.far_distance_sq			  = 370 * 370;
			self.distance_from_next_volume_sq = 190 * 190;
		}
	}
	
	//thread ally_rappel_movement_cleanup( rappel_type, flag_to_end_on );
}

//ally_rappel_movement_cleanup( rappel_type, flag_to_end_on )
//{
//	if ( rappel_type == "stealth" )
//		flag_wait_either( flag_to_end_on, self.stealth_broken_flag );
//	else
//		flag_wait( flag_to_end_on );
//	
//	self.close_distance_sq = undefined;
//	self.far_distance_sq   = undefined;
//	self.distance_from_next_volume_sq	= undefined;
////	self.center_volume = undefined;
////	self.in_volume	   = undefined;
////	self.out_volume						= undefined;
//	self.last_volume			   = undefined;
//	self.movement_back			   = undefined;
//	self.last_move_time			   = undefined;
//	self.player_right_movment_sign = undefined;
//}

animate_til_volume( direction, movement_flag, first_volume, second_volume, flag_to_end_on, rappel_type, do_start )
{
	level endon( flag_to_end_on );
	if ( rappel_type == "stealth" )
		level endon( self.stealth_broken_flag );
	level endon( self.animname + "_stop_anim_move" );
	
	if ( !IsDefined( do_start ) )
		do_start = true;

	self notify( "stop_loop" );
	ally_rappel_stop_shooting();
	ally_rappel_stop_aiming();
	ally_stop_calm_idle();
	
	flag_set( movement_flag );	
	
	if ( direction == "away" )
	{
		self.movement_back = false;
		self.move_type	   = "move_away_start";
		if ( do_start )
			self anim_single_solo( self, "move_away_start" );
		self thread anim_loop_solo( self, "move_away", "stop_loop" );
		self.move_type = "move_away";
	}
	else if ( direction == "back" )
	{
		self.movement_back = true;
		self.move_type	   = "move_back_start";
		if ( do_start )
			self anim_single_solo( self, "move_back_start" );
		self thread anim_loop_solo( self, "move_back", "stop_loop" );
		self.move_type = "move_back";
	}
	
	Assert( IsDefined( first_volume ) || IsDefined( second_volume ) );
	
	if ( !IsDefined( first_volume ) && IsDefined( second_volume ) )
	{
		first_volume  = second_volume;
		second_volume = undefined;
	}
	
	while ( 1 )
	{
		if ( self IsTouching( first_volume ) )
		{
			dist_to_player_sq = ally_rappel_Distance2DSquared_to_player();
			
			if ( direction == "away" )
			{			
				if ( dist_to_player_sq < self.close_distance_sq )
				{
					if ( IsDefined( second_volume ) )
					{
						first_volume  = second_volume;
						second_volume = undefined;
						
						self.last_volume = first_volume;
					}
					else
					{
						self notify( "stop_loop" );
						waittillframeend;
						self.move_type = "move_away_stop";
						self anim_single_solo( self, "move_away_stop" );
						break;
					}
				}
				else
				{
					self notify( "stop_loop" );
					waittillframeend;
					self.move_type = "move_away_stop";
					self anim_single_solo( self, "move_away_stop" );
					break;
				}
			}
			else // if(direction == "back")
			{
				if ( dist_to_player_sq > self.far_distance_sq )
				{		
					if ( IsDefined( second_volume ) )
					{
						first_volume  = second_volume;
						second_volume = undefined;
						
						self.last_volume = first_volume;
					}
					else
					{
						self.movement_back = false;
						self notify( "stop_loop" );
						waittillframeend;
						self.move_type = "move_back_stop";
						self anim_single_solo( self, "move_back_stop" );
						break;
					}
				}
				else
				{
					self.movement_back = false;
					self notify( "stop_loop" );
					waittillframeend;
					self.move_type = "move_back_stop";
					self anim_single_solo( self, "move_back_stop" );
					break;
				}
			}
		}
		wait( 0.05 );
	}
	
	self.last_volume = first_volume;
	
	flag_clear( movement_flag );

	self.last_move_time = GetTime();
	
	self thread animate_after_movement( movement_flag, rappel_type );
}

animate_opposite_direction( movement_flag, flag_to_end_on, rappel_type, is_moving )
{
	level endon( flag_to_end_on );
	if ( rappel_type == "stealth" )
		level endon( self.stealth_broken_flag );
	
	flag_set( self.animname + "_stop_anim_move" );
    flag_clear( movement_flag );
	flag_set( movement_flag );
	self.movement_back = false;
	
	if ( is_moving )
	{
		self.move_type = "turn_away";
		self notify( "stop_loop" );
		self anim_single_solo( self, "turn_away" );
		self.movement_back = false;
	}
	
//	flag_clear( movement_flag );
	flag_clear( self.animname + "_stop_anim_move" );
	
	self.last_move_time = GetTime();
	
	if ( IsDefined( self.in_volume ) && self.last_volume == self.in_volume )
	{
		self thread animate_til_volume( "away", movement_flag, self.center_volume, self.out_volume, flag_to_end_on, rappel_type, !is_moving );	
	}
	else if ( IsDefined( self.center_volume ) && self.last_volume == self.center_volume )
	{
		self thread animate_til_volume( "away", movement_flag, self.out_volume, undefined, flag_to_end_on, rappel_type, !is_moving );
	}
	else if ( IsDefined( self.out_volume ) && self.last_volume == self.out_volume )
	{
		self thread animate_til_volume( "away", movement_flag, self.out_volume, undefined, flag_to_end_on, rappel_type, !is_moving );
	}
	else
	{
		AssertMsg( "Shouldn't get here since a 'last_volume' should always be defined" );
	}
}

animate_after_movement( movement_flag, rappel_type )
{
	if ( rappel_type == "stealth" )
	{
		if ( flag( self.stealth_broken_flag ) )
		{
			self ally_stop_calm_idle();
			self ally_rappel_start_aiming( rappel_type );
			self ally_rappel_start_shooting();
		}
		else
		{
			self ally_rappel_stop_aiming();
			self ally_start_calm_idle( "stealth" );
		}
	}
	else // ( rappel_type == "combat" )
	{
		if ( IsDefined( level.flag_to_check ) && !flag( level.flag_to_check ) )
		{
			if ( level.flag_to_check == "all_rappel_one_enemies_in_front_dead" )
			{
				self ally_rappel_start_aiming( rappel_type );
				self ally_rappel_start_shooting();
			}
			else if ( level.flag_to_check == "all_rappel_two_enemies_in_front_dead" )
			{
				self ally_rappel_start_aiming( rappel_type );
				self ally_rappel_start_shooting();
			}			
		}
		else
		{
			self notify( "stop_loop" );
			self ally_rappel_start_aiming( rappel_type );
		}
	}
	
	self.move_type = "idle";
}

//random_rappel_anims( flag_to_end_on, movement_flag, anim_start, rappel_type )
//{
//	//level endon( "final_jump_start" );
//	end_flag = "final_jump_start_" + rappel_type;
//	level endon( "c_rappel_second_jump_starting" );//test
//	level endon( "c_rappel_final_jump_starting" );//test
//	level endon( end_flag );
//	level endon( flag_to_end_on );
//	if ( IsDefined( movement_flag ) )
//	{
//		level endon( movement_flag );
//	}
//	
//	
//	self notify( "stop_loop" );
//	self StopAnimScripted();
//	fire_ender = "stop_loop_" + self.animname + "fire";
//	self notify( fire_ender );
//	idle_ender = "stop_loop_" + self.animname + "idle";
//	self notify( idle_ender );
//	waittillframeend;
//
//	// ----JZ - want them to idle for a couple of seconds so player can shoot
//	self thread anim_loop_solo( self, anim_start + "idle_" + self.animname, idle_ender );
//	wait RandomFloatRange( 1.5, 2.5 );
//	self notify( idle_ender );
//	waittillframeend;
//	
//	while ( 1 )
//	{
//		random_fire_anim_num = RandomIntRange( 1, 4 );
//		self thread anim_loop_solo( self, anim_start + "fire_" + self.animname + "_" + random_fire_anim_num, fire_ender );
//		wait RandomFloatRange( 4.0, 8.0 );
//		self notify( fire_ender );
//		
//		num = RandomIntRange( 1, 3 );
//		if ( num == 1 )
//		{
//			random_reload_anim_num = RandomIntRange( 1, 4 );
//			self thread anim_single_solo( self, anim_start + "reload_" + self.animname + "_" + random_reload_anim_num );
//			self waittillmatch( "single anim", "end" );
//		}
//		else
//		{
//			self thread anim_loop_solo( self, anim_start + "idle_" + self.animname, idle_ender );
//			wait RandomFloatRange( 2.0, 4.0 );
//			self notify( idle_ender );
//		}
//	}
//}

// ****************************
// * Rope Logic		          *
// *********************************************************************************************************************************************************************


#using_animtree( "animated_props" );

ally_rappel_get_rope_start( rappel_type )
{
	if ( rappel_type == "stealth" )
	{
		if ( self.animname == "rorke" )
		{
			rope_start = getstruct( "rorke_rope_ref_stealth", "targetname" );
			return rope_start;
		}
		else // "baker"
		{
			rope_start = getstruct( "baker_rope_ref_stealth", "targetname" );
			return rope_start;
		}
	}
	else if ( rappel_type == "inverted" )
	{
		if ( self.animname == "rorke" )
		{
			rope_start = getstruct( "rorke_rope_ref_inverted", "targetname" );
			return rope_start;
		}
		else // "baker"
		{
			rope_start = getstruct( "baker_rope_ref_inverted", "targetname" );
			return rope_start;
		}
	}
	else if ( rappel_type == "combat" )
	{
		if ( self.animname == "rorke" )
		{
			rope_start = getstruct( "rorke_rope_ref_combat", "targetname" );
			return rope_start;
		}
		else // "baker"
		{
			rope_start = getstruct( "baker_rope_ref_combat", "targetname" );
			return rope_start;
		}
	}
}

ally_rappel_setup_rope( rappel_type, start_pos )
{
	rope_physical_origin_spawned			 = start_pos spawn_tag_origin();
	rope_physical_anim_origin_spawned		 = Spawn( "script_model", rope_physical_origin_spawned.origin );
	rope_physical_anim_origin_spawned.angles = start_pos.angles + ( 0, -90, 0 );
	rope_physical_anim_origin_spawned SetModel( "generic_prop_raven" );
	rope_physical_anim_origin_spawned UseAnimTree(#animtree );
	rope_physical_anim_origin_spawned LinkTo( rope_physical_origin_spawned, "tag_origin" );
	self.rappel_physical_rope_animation_origin = rope_physical_anim_origin_spawned;
	self.rappel_physical_rope_origin		   = rope_physical_origin_spawned;
	
	self.rope_unwind_anim = %cnd_rappel_inv_top_rope_unwind;
	self.rope_unwind_length = 2254.0;
	
	rope_angle_offset = ( 0, 0, 0 );
	if ( rappel_type == "combat" )
		rope_angle_offset = ( 0, 235, 0 );

	self.cnd_rappel_tele_rope		 = spawn_anim_model( "cnd_rappel_tele_rope" );
	self.cnd_rappel_tele_rope.origin = self.rappel_physical_rope_animation_origin.origin;
	self.cnd_rappel_tele_rope.angles = ( 0, 0, 0 );
	self.cnd_rappel_tele_rope LinkTo( self.rappel_physical_rope_animation_origin, "J_prop_1", ( 0, 0, 0 ), rope_angle_offset );
			
	self.cnd_rappel_tele_rope SetAnim( self.rope_unwind_anim, 1, 0, 0 );
}

ally_rappel_rope( rappel_type, start_pos )
{
	self endon( "stop_rope_management" );
	
	// on checkpoint allies need to teleport into position
	if ( IsDefined( level.start_point ) && ( level.start_point == "rappel_stealth" ) && rappel_type == "stealth" )
		wait 0.5;
	
	starting_length	   = 46;
	one_unit_anim_time = 1.0 / self.rope_unwind_length; // how much time to scrub for 1 unit
	
	// determine plane normal of attachment point (to know if the rope is on the right or left)
	plane_normal_left = rappel_get_plane_normal_left( rappel_type );
	plane_normal_out  = rappel_get_plane_normal_out( rappel_type );
	
	plane_left_d = rappel_get_plane_d( plane_normal_left, start_pos.origin ); // d in plane equation
	plane_out_d	 = rappel_get_plane_d( plane_normal_out, start_pos.origin ); // d in plane equation
	
	while ( true )
	{
		waist_origin = self GetTagOrigin( "tag_stowed_back" );
//		hand_origin = self GetTagOrigin( "tag_weapon_left" );
//		/#
//			debug_star( waist_origin, (0, 1, 0) );
//			debug_star( hand_origin, (0, 1, 0) );
//		#/
		
		// calculate the roll (left/right on the wall)
		hypotenuse	  = Distance( waist_origin, start_pos.origin );
		opposite	  = ( VectorDot( plane_normal_left, waist_origin ) + plane_left_d ); // vec is normalized / Length( plane_normal_left ); // shortest distance from rope plane to waist point
		new_rope_roll = -1 * ASin( opposite / hypotenuse );
		
		// calculate the pitch (out from the wall)
		opposite	   = ( VectorDot( plane_normal_out, waist_origin ) + plane_out_d ); // vec is normalized / Length( plane_normal_out ); // shortest distance from rope plane to waist point
		new_rope_pitch = -1 * ASin( opposite / hypotenuse );
		
		self.rappel_physical_rope_origin.angles = ( new_rope_pitch, self.rappel_physical_rope_origin.angles[ 1 ], new_rope_roll );
	
		// recalculate the distance and set the unwind anim
		cur_dist	 = hypotenuse;
		new_dist	 = cur_dist - starting_length;
		new_time	 = new_dist * one_unit_anim_time;
		new_time	 = clamp( new_time, 0, 0.9999 ); // can not set it directly to 1
		current_time = self.cnd_rappel_tele_rope GetAnimTime( self.rope_unwind_anim );
		
		if ( new_time == current_time )
		{
			waitframe();
			continue;
		}
		
		self.cnd_rappel_tele_rope SetAnimTime( self.rope_unwind_anim, new_time );
		
		waitframe();
	}
}

// ****************************
// * Debug Functions          *
// *********************************************************************************************************************************************************************
#using_animtree( "generic_human" );
/#

rappel_aim_get_parent_node_exposed( aimType )
{
	if ( aimType == AIM_TYPE_UP )
		return %aim_8;
	else if ( aimType == AIM_TYPE_LEFT )
		return %aim_4;
	else if ( aimType == AIM_TYPE_RIGHT )
		return %aim_6;
	else if ( aimType == AIM_TYPE_DOWN )
		return %aim_2;
	else
		AssertMsg( "rappel_aim_get_parent_node_exposed encountered an unknown aimType: " + aimType );
}

rappel_get_aim_anim_exposed( aimType )
{
	if ( aimType == AIM_TYPE_UP )
		return %exposed_aim_8;
	else if ( aimType == AIM_TYPE_LEFT )
		return %exposed_aim_4;
	else if ( aimType == AIM_TYPE_STRAIGHT )
		return %exposed_aim_5;
	else if ( aimType == AIM_TYPE_RIGHT )
		return %exposed_aim_6;
	else if ( aimType == AIM_TYPE_DOWN )
		return %exposed_aim_2;
	else
		AssertMsg( "rappel_get_aim_anim_exposed encountered an unknown aimType: " + aimType );
}

ally_do_nothing()
{
	
}

ally_debug_aim_blender()
{
	SetDvarIfUninitialized( "debug_ally_aim"	   , "0" );
	SetDvarIfUninitialized( "debug_aim_use_exposed", 0 );
	
	parent_nodes				   = [];
	parent_nodes[ AIM_TYPE_UP	 ] = rappel_aim_get_parent_node( AIM_TYPE_UP );
	parent_nodes[ AIM_TYPE_LEFT	 ] = rappel_aim_get_parent_node( AIM_TYPE_LEFT );
	parent_nodes[ AIM_TYPE_RIGHT ] = rappel_aim_get_parent_node( AIM_TYPE_RIGHT );
	parent_nodes[ AIM_TYPE_DOWN	 ] = rappel_aim_get_parent_node( AIM_TYPE_DOWN );
	
	flag_wait( "player_moving_down" );
	
	while ( true )
	{
		if ( IsDefined( level.allies ) && IsDefined( level.allies[ 0 ] ) && IsDefined( level.allies[ 0 ].animname ) )
			break;
		
		waitframe();
	}
	
	ally		   = level.allies[ 0 ];
	ally_animname  = ally.animname;
	last_aim_value = 0;
	
	while ( true )
	{
		if ( !IsDefined( level.debug_aa_anims ) )
		{
			level.debug_aa_anims = false;
//			level.debug_aa_anims_up = false;
			SetDvarIfUninitialized( "debug_aa_u_weight", 0 );
			SetDvarIfUninitialized( "debug_aa_d_weight", 0 );
			SetDvarIfUninitialized( "debug_aa_l_weight", 0 );
			SetDvarIfUninitialized( "debug_aa_r_weight", 0 );
//			SetDvarIfUninitialized( "debug_aa_ul_weight", 0 );
//			SetDvarIfUninitialized( "debug_aa_ur_weight", 0 );
//			SetDvarIfUninitialized( "debug_aa_dl_weight", 0 );
//			SetDvarIfUninitialized( "debug_aa_dr_weight", 0 );
			SetDvarIfUninitialized( "debug_aa_blend_into_time", 0.1 );
//			SetDvarIfUninitialized( "debug_aa_blend_clear_time", 0.2 );
			SetDvarIfUninitialized( "debug_aa_clear_weights", 0 );
//			SetDvarIfUninitialized( "debug_aa_up_anims", 0 );
		}
	
		if ( GetDvarInt( "debug_ally_aim" ) != last_aim_value && level.debug_aa_anims )
		{
			last_aim_value		 = GetDvarInt( "debug_ally_aim" );
			level.debug_aa_anims = false;
			
			if ( GetDvarInt( "debug_ally_aim" ) == 0 )
			{
				ally.animname		   = ally_animname;
				ally.no_ai			   = undefined;
				ally.custom_animscript = undefined;
				
				ally ally_rappel_stop_aiming();
				level notify( "debug_ally_aim_complete" );
			}
		}
		
		// test blending between the leg anims
		if ( GetDvar( "debug_ally_aim" ) == "0" )
		{
			waitframe();
			continue;
		}
			
		clear_weights = GetDvarFloat( "debug_aa_clear_weights" );
		if ( clear_weights )
		{
			SetDvar( "debug_aa_u_weight", 0 );
			SetDvar( "debug_aa_d_weight", 0 );
			SetDvar( "debug_aa_l_weight", 0 );
			SetDvar( "debug_aa_r_weight", 0 );
//			SetDvar( "debug_aa_ul_weight", 0 );
//			SetDvar( "debug_aa_ur_weight", 0 );
//			SetDvar( "debug_aa_dl_weight", 0 );
//			SetDvar( "debug_aa_dr_weight", 0 );
			SetDvar( "debug_aa_clear_weights", 0 );
		}
		
		weights					  = [];
		weights[ AIM_TYPE_UP	] = GetDvarFloat( "debug_aa_u_weight" );
		weights[ AIM_TYPE_DOWN	] = GetDvarFloat( "debug_aa_d_weight" );
		weights[ AIM_TYPE_LEFT	] = GetDvarFloat( "debug_aa_l_weight" );
		weights[ AIM_TYPE_RIGHT ] = GetDvarFloat( "debug_aa_r_weight" );
//		weights["left_up"]	 = GetDvarFloat( "debug_aa_ul_weight" );
//		weights["right_up"]	 = GetDvarFloat( "debug_aa_ur_weight" );
//		weights["left_down"] = GetDvarFloat( "debug_aa_dl_weight" );
//		weights["right_down"] 		= GetDvarFloat( "debug_aa_dr_weight" );
		blend_time					= GetDvarFloat( "debug_aa_blend_into_time" );
//		blend_clear_time = GetDvarFloat( "debug_aa_blend_clear_time" );
//		up_anims		 = GetDvarInt( "debug_aa_up_anims" );
		
//		if ( up_anims != level.debug_aa_anims_up )
//		{
//			level.debug_aa_anims_up = up_anims;
//			level.debug_aa_anims	= false;
//		}
		
		if ( !level.debug_aa_anims )
		{
			if ( GetDvarInt( "debug_ally_aim" ) == 1 )
				ally.animname = "baker";
			else
				ally.animname = "rorke";
			
			ally ally_rappel_stop_aiming();
			ally.no_ai						 = true;
			level.debug_aa_anims			 = true;
			ally.custom_animscript			 = [];
			ally.custom_animscript[ "move" ] = ::ally_do_nothing;
			rappel_type						 = "stealth";
//			if ( up_anims )
//				rappel_type = "combat";
			ally ally_rappel_start_aiming( rappel_type );
			waitframe();
		}
		
		aim_type_keys = GetArrayKeys( weights );
		foreach ( aim_type in aim_type_keys )
		{
			weight = weights[ aim_type ];
			ally SetAnimLimited( parent_nodes[ aim_type ], weight, blend_time, 1 );
		}
				
		waitframe();
	}
}

//monitor_players_engagement( player )
//{
//	level.monitor_players_engagement = true;
//	
//	SetDvarIfUninitialized( "rappel_player_favorite_enemy", "0" );
//	SetDvarIfUninitialized( "rappel_player_fov_angles"	  , "0" );
//	
//	while ( true )
//	{
//		waitframe();
//		
//		fov_angle = GetDvarInt( "rappel_player_fov_angles" );
//		
//		if ( fov_angle != 0 )
//		{
//			player player_rappel_draw_custom_angle_fov( fov_angle );
//		}
//		
//		enemy = player player_get_favorite_enemy( 1500 );
//		
//		if ( !IsDefined( enemy ) )
//		{
//			continue;
//		}
//		
//		if ( GetDvar( "rappel_player_favorite_enemy" ) != "0" )
//		{
//			start = enemy.origin;
//			end	  = start + ( 0, 0, 100 );
//			Line( start, end, ( 1, 0, 0 ), 1, true );
//			Print3d( end, "" + enemy GetEntNum(), ( 1, 0, 0 ), 1, 1 );
//		}
//	}
//}

#/