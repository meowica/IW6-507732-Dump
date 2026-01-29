#include maps\mp\agents\_scriptedAgents;
#include maps\mp\agents\alien\_alien_anim_utils;
#include common_scripts\utility;

SWIPT_ATTACK_START_SOUND = "alien_attack";
LEAP_ATTACK_START_SOUND = "alien_attack";
WALL_ATTACK_START_SOUND = "alien_attack";
ALIEN_MELEE_POSTURE_PERCENT = 20;
ALIEN_MELEE_MOVE_SIDE_PERCENT = 60;
MAX_SWIPE_DAMAGE_DIST = 90;
SWIPE_OFFSET_XY = 56; // how far in front of player we want to swipe (so the player can actually see it.)
LEAP_OFFSET_XY = 48;

main()
{
	self endon( "killanimscript" );

	assert( IsDefined( self.enemy ) );
	assert( IsDefined( self.melee_type ) );

	self.enemy thread melee_clean_up( self );
	
	self ScrAgentSetOrientMode( "face enemy" );
	self.playing_pain_animation = false;
	self.melee_jumping = false;
	self.melee_jumping_to_wall = false;
	self.melee_success = false;
	
	startTime = gettime();

	switch( self.melee_type )
	{
	case "swipe":
		self melee_swipe( self.enemy );
		break;
	case "leap":
		self melee_leap( self.enemy );
		break;
	case "wall":
		self melee_wall( self.enemy );
		break;
	case "spit":
		self maps\mp\agents\alien\_alien_spitter::spit_attack( self.enemy );
		break;
	case "charge":
		self maps\mp\agents\alien\_alien_elite::do_charge_attack( self.enemy );
		break;
	case "health_regen":
		self maps\mp\agents\alien\_alien_elite::activate_health_regen();
		break;
	case "explode":
		self maps\mp\agents\alien\_alien_minion::explode( self.enemy );
		break;
	default:
		assertmsg( self.melee_type + " unimplemented." );
		break;
	}

	if ( self.playing_pain_animation )
	{
		self waittill( "pain_finished" );
	}
	
	if ( starttime == gettime() )
	{
		wait 0.05; // Ugh. We have to wait at least one frame to let our calling script start its waittill
	}
	
	self notify( "melee_complete" );
}

end_script()
{
	self.allowpain = true;
	self ScrAgentSetAnimScale( 1, 1 );
	self.previousAnimState = "melee";
	self.melee_in_move_back = false;
}

melee_swipe( enemy )
{
	self endon( "melee_pain_interrupt" );
	animState = "attack_melee_swipe";
	
	result1 = do_single_swipe( animState, 0, enemy, 0.6 );
	
	if ( cointoss() )
	{
		result2 = do_single_swipe( animState, 1, enemy, 0.7 );
	}
	else
	{
		result2 = false;
	}
	
	// If we missed with either
	if ( !result1 || !result2 )
	{
		result3 = do_single_swipe( animState, 2, enemy, 0.8 );
	}
	self move_back( enemy );
}

do_single_swipe( animState, animEntry, enemy, tracking_amount )
{
	result = false;
	if ( !isAlive( enemy ) )
	{
		return false;
	}
	
	attackAnim = self GetAnimEntry( animState, animEntry );
	animLength = GetAnimLength( attackAnim );
	target_pos = self get_melee_position( animLength, SWIPE_OFFSET_XY, enemy, tracking_amount );
	if ( isDefined( target_pos ) && is_valid_swipe_position( target_pos ) )
	{
		self playSound( SWIPT_ATTACK_START_SOUND );
		attackAnim = self GetAnimEntry( animState, animEntry );
		attackTranslation = GetMoveDelta( attackAnim );		
		animXY = Length2D( attackTranslation );
	
		meToTarget = target_pos - self.origin;
		meToTargetDistXY = Max( 0, Length2D( meToTarget ) );
		animXYScale = meToTargetDistXY / animXY;
	
		self ScrAgentSetPhysicsMode( "gravity" );
		self ScrAgentSetAnimScale( animXYScale, 0.0 );
		self ScrAgentSetAnimMode( "anim deltas" );
		self PlayAnimNAtRateUntilNotetrack( animState, animEntry, 0.9, "attack_melee", "start_melee" );
		
		if ( isAlive( enemy ) )
		{
			dist_sqr = DistanceSquared( self.origin, enemy.origin );
		
			if ( DistanceSquared( self.origin, enemy.origin ) < MAX_SWIPE_DAMAGE_DIST * MAX_SWIPE_DAMAGE_DIST )
			{
				self melee_DoDamage( enemy, "swipe" );
				result = true;
			}
		}
		
		self WaitUntilNotetrack( "attack_melee", "end" );
	}
	else
	{
		self move_back( enemy );
	}
	
	return result;
}

is_valid_swipe_position( swipe_pos )
{
	MAX_SWIPE_ANIM_DISTANCE_SQR = 40000.0; // 200.0 * 200.0
	ALIEN_SWIPE_STEP_SIZE = 17.0;
	if ( DistanceSquared( self.origin, swipe_pos ) > MAX_SWIPE_ANIM_DISTANCE_SQR )
	{
		return false;
	}
	
	// Make sure we can get to our enemy
	return CanMovePointToPoint( self.origin, swipe_pos, ALIEN_SWIPE_STEP_SIZE );
}

get_melee_position( timeUntilAttack, offset, enemy, tracking_amount )
{
	assert( IsAlive( enemy ) );
	enemy_to_self = self.origin - enemy.origin;
	
	enemy_to_self *= ( 1, 1, 0 );
	enemy_to_self = VectorNormalize( enemy_to_self ) * offset;
	
	if ( !isDefined( tracking_amount ) )
	{
		tracking_amount = 0.7;
	}
	
	// Calc enemy origin with velocity
	if ( isPlayer( enemy ) )
	{
		velocity = enemy GetVelocity();
		TRACKING_VELOCITY_CAP = 200.0;
		if ( LengthSquared( velocity ) > TRACKING_VELOCITY_CAP * TRACKING_VELOCITY_CAP )
		{
			velocity = VectorNormalize( velocity );
			velocity *= TRACKING_VELOCITY_CAP;
		}
		velocity *= tracking_amount; // Don't follow player perfectly		
		velocity *= timeUntilAttack;
	}
	else
	{
		velocity = (0,0,0);
	}
	
	/*
	// Not far enough!
	if ( LengthSquared( enemy_to_self + velocity ) < meleeOffsetXY * meleeOffsetXY )
	{
		return undefined;
	}*/
	
	leapEndPos = enemy.origin + enemy_to_self + velocity;
	leapEndPos = DropPosToGround( leapEndPos );
	
/#	
	if ( !isDefined( leapEndPos ) )
	{
		println( "get_melee_position: Failed to DropPosToGround: " + enemy.origin );
	}
	else
	{
		if ( GetDvarInt( "alien_debug_melee_position" ) == 1 )
		{
			line ( enemy.origin + ( 0,0,32 ), enemy.origin, (1,0,0), 1, 0, 100 );
			line ( self.origin + ( 0,0,32 ), self.origin, (0,1,0), 1, 0, 100 );
			line ( leapEndPos + ( 0,0,32 ), leapEndPos, (0,0,1), 1, 0, 100 );
			println( "Dist from leapEndPos to enemy: " + Distance( leapEndPos, enemy.origin ) );
		}
	}
	
#/
	return leapEndPos;
}

melee_leap( enemy )
{
	melee_leap_internal( enemy, "leap" );
}
	
melee_leap_internal( enemy, melee_type )
{
	play_leap_start_sound( melee_type );
	
	jumpCBs = SpawnStruct();
	jumpCBs.fnSetAnimStates = ::melee_SetJumpAnimStates;
	jumpCBs.fnLandAnimStateChoice = ::melee_ChooseJumpArrival;
	
	// leapEndPos should have been calculated for us
	assert( IsDefined( self.leapEndPos ) );
	
	leapEndPos = self.leapEndPos;
	
	if ( IsDefined( leapEndPos ) )
	{
		self thread melee_LeapWaitForDamage( enemy, melee_type );
	
		self.melee_jumping = true;
		self maps\mp\agents\alien\_alien_jump::Jump( self.origin, self.angles, leapEndPos, enemy.angles, undefined, jumpCBs );
		self.melee_jumping = false;
		self move_back( enemy );
	}
	else
	{
		// Failed to find good position
/#
		println( "Leap Melee failed" );
#/
		wait 0.05; // We must guarantee that melee takes at least one frame
	}
}

play_leap_start_sound( melee_type )
{
	switch ( melee_type )
	{
	case "leap":
		self playSound( LEAP_ATTACK_START_SOUND );
		break;
	case "wall":
		self playSound( WALL_ATTACK_START_SOUND );
		break;
	default:
		break;
	}
}

melee_LeapWaitForDamage( enemy, melee_type )
{
	self endon( "killanimscript" );
	self endon( "melee_pain_interrupt" );
	self endon( "jump_pain_interrupt" );

	cMeleeDistanceSq = 80 * 80;

	while ( true )
	{
		if ( !IsDefined( enemy ) || !IsAlive( enemy ) )
			break;

		if ( Distance2DSquared( self.origin, enemy.origin ) <= cMeleeDistanceSq )
		{
			self melee_DoDamage( enemy, melee_type );
			break;
		}

		wait( 0.1 );
	}
}

melee_SetJumpAnimStates( jumpInfo, jumpAnimStates )
{
	jumpAnimStates.landAnimState = "attack_leap_swipe";
	jumpAnimStates.landAnimEntry = GetRandomAnimEntry( "attack_leap_swipe" );
}

melee_ChooseJumpArrival( jumpInfo, jumpAnimStates )
{
	COS_45 = 0.707;
	if ( isAlive( self.enemy ) )
	{
		assert( isDefined( jumpInfo.landOrigin ) );
		assert(	isDefined( jumpInfo.endAngles ) );
		landToEnemy = self.enemy.origin - jumpInfo.landOrigin;
		landForward = AnglesToForward( jumpInfo.endAngles );
		forward_dot = VectorDot( landToEnemy, landForward );
		
		if ( forward_dot > COS_45 )
		{
			// Already set to forward attack
			return;
		}
		landRight = AnglesToRight( jumpInfo.endAngles );
		right_dot = VectorDot( landToEnemy, landRight );		
		if ( right_dot > COS_45 )
		{
			jumpAnimStates.landAnimState = "attack_leap_swipe_right";
			jumpAnimStates.landAnimEntry = GetRandomAnimEntry( "attack_leap_swipe_right" );			
		}
		else if ( right_dot < COS_45*-1 )
		{
			jumpAnimStates.landAnimState = "attack_leap_swipe_left";
			jumpAnimStates.landAnimEntry = GetRandomAnimEntry( "attack_leap_swipe_left" );			
		}

	}
}

melee_wall( enemy )
{
	MAX_DIST_WALL_MELEE = 800;
	MIN_DIST_WALL_MELEE = 168;

	assert( IsDefined( self.wall_leap_melee_node ) );

	// We're near the player, find a nearby jump node that works for our purposes
	target_jump_node = self.wall_leap_melee_node;
	
	self.melee_jumping_to_wall = true;
	self maps\mp\agents\alien\_alien_jump::Jump( self.origin, self.angles, target_jump_node.origin, target_jump_node.angles, enemy.origin );
	self.melee_jumping_to_wall = false;
	if ( !isAlive( enemy ) )
	{
		return;
	}
	
	if ( maps\mp\agents\alien\_alien_think::can_leap_melee( enemy, MAX_DIST_WALL_MELEE, MIN_DIST_WALL_MELEE ) )
	{
		melee_leap_internal( enemy, "wall" );
	}
}

melee_DoDamage( enemy, melee_type )
{
	if ( !isAlive( enemy ) )
	{
		return;
	}
	
	self.melee_success = true;
	damage_amount = 1;
	if ( isDefined( self.alien_type ) )
	{
		min_damage = level.alien_types[ self.alien_type ].attributes[ melee_type + "_min_damage" ];
		max_damage = level.alien_types[ self.alien_type ].attributes[ melee_type + "_max_damage" ];
		damage_amount = RandomFloatRange( min_damage, max_damage );
	}
	enemy_blocked = self check_for_block( enemy );
	
	if ( enemy_blocked )
	{
		return;
	}
	else
	{
		if ( IsPlayer( enemy ) )
		{
			enemy set_damage_viewkick( damage_amount );
			enemy PlaySound( "Player_hit_sfx_alien" );
		}
		enemy DoDamage( damage_amount, self.origin, self, self );
	}
}

set_damage_viewkick( damage_amount )
{
	MAX_VIEWKICK = 10;
	BASE_VIEWKICK = 2;
	DAMAGE_SCALE_BASE = 50;	
	
	additional_viewkick_scale = min( 1, damage_amount / DAMAGE_SCALE_BASE );
	additional_viewkick = ( MAX_VIEWKICK - BASE_VIEWKICK ) * additional_viewkick_scale;
	
	viewkick_scale = BASE_VIEWKICK + additional_viewkick;
	self SetViewKickScale( viewkick_scale );
}

move_back( enemy )
{	
	self endon( "melee_pain_interrupt" );
	
	if ( self should_move_back( enemy ) )
	{
		move_back_state = self GetMoveBackState();
		move_back_entry = self GetMoveBackEntry( move_back_state );
		moveBackAnim = self GetAnimEntry( move_back_state, move_back_entry );
		availableMoveBackScale = GetSafeAnimMoveDeltaPercentage( moveBackAnim );
			
		if ( has_room_to_move_back( availableMoveBackScale ) )
		{
			self.melee_in_move_back = true;
			
			self ScrAgentSetAnimMode( "anim deltas" );
			self ScrAgentSetPhysicsMode( "gravity" );
		
			self ScrAgentSetAnimScale( availableMoveBackScale, 1.0 );
			self SetAnimState( move_back_state, move_back_entry, 1.0 );
			//animLength = GetAnimLength( moveBackAnim );
			//wait ( animLength * 0.8 );
			self WaitUntilNotetrack( "move_back", "finish" );
			self.melee_in_move_back = false;
		}
		
		if ( should_posture( enemy ) )
		{
			random_entry = GetRandomAnimEntry( "posture" );
			self SetAnimState( "posture", random_entry, 1.3 ); // Play the "quick" posturing anim
			self ScrAgentSetOrientMode( "face enemy" );
			self WaitUntilNotetrack( "posture", "end" );
			
		}
		else if ( should_move_side( enemy ) )
		{
			self move_side();
		}
	}
}

move_side()
{
	self endon( "melee_pain_interrupt" );
	
	if ( cointoss() )
	{
		if ( !self try_move_side( "melee_move_side_left" ) )
		{
			self try_move_side( "melee_move_side_right" );
		}
	}
	else
	{
		if ( !self try_move_side( "melee_move_side_right" ) )
		{
			self try_move_side( "melee_move_side_left" );
		}
	}
}

try_move_side( animState )
{
	animEntry = GetRandomAnimEntry( animState );
	sideMoveAnim = self GetAnimEntry( animState, animEntry );
	availableSideMoveScale = GetSafeAnimMoveDeltaPercentage( sideMoveAnim );
	if ( availableSideMoveScale > 0.5 )
	{
		self ScrAgentSetAnimMode( "anim deltas" );
		self ScrAgentSetPhysicsMode( "gravity" );
	
		self ScrAgentSetAnimScale( availableSideMoveScale, 1.0 );
		self SetAnimState( animState, animEntry, 1.0 );
		//animLength = GetAnimLength( sideMoveAnim );
		//wait animLength * 1.0;
		self WaitUntilNotetrack( "move_side", "finish" );
		return true;
	}
	
	return false;
}

should_move_back( enemy )
{
	MAX_MOVE_BACK_DISTANCE_SQR = 10000.0; // 100.0 * 100.0
	if ( isAlive( enemy ) && DistanceSquared( self.origin, enemy.origin ) > MAX_MOVE_BACK_DISTANCE_SQR )
	{
		return false;
	}
	return true;
}

should_posture( enemy )
{
	return ( isAlive( enemy ) && RandomInt( 100 ) < ALIEN_MELEE_POSTURE_PERCENT );
}

should_move_side( enemy )
{
	return ( isAlive( enemy ) && RandomInt( 100 ) < ALIEN_MELEE_MOVE_SIDE_PERCENT );
}

has_room_to_move_back( availableMoveBackScale )
{
	MIN_MOVE_BACK_SCALE = 0.5;

	return availableMoveBackScale >= MIN_MOVE_BACK_SCALE;	
}

GetMoveBackState()
{
	return "melee_move_back";
}

GetMoveBackEntry( move_back_state )
{
	randomInteger = RandomIntRange ( 0, 101 );
	runningTotal = 0;
	randomIndex = undefined;
	for ( i = 0 ; i < level.alienAnimData.alienMoveBackAnimChance.size ; i++ )
	{
		runningTotal += level.alienAnimData.alienMoveBackAnimChance[ i ];
		if ( randomInteger <= runningTotal )
		{
			randomIndex = i;
			break;			
		}
	}
	return randomIndex;
}

onDamage( eInflictor, eAttacker, iThatDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( canDoPain() )
		self DoPain( iThatDamage );
}

canDoPain()
{
	switch( maps\mp\alien\_utility::get_alien_type() )
	{
	case "elite":
		return false;
	default:
		painIsAvailable = maps\mp\alien\_utility::is_pain_available();
		return ( painIsAvailable && !self.melee_jumping && !self.melee_jumping_to_wall && !self.playing_pain_animation && !self.stateLocked );
	}
}

DoPain( iDamage )
{
	self endon( "killanimscript" );

	self.playing_pain_animation = true;
	self notify( "melee_pain_interrupt" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	self ScrAgentSetAnimMode( "anim deltas" );

	animStateInfo = get_melee_painState_info( iDamage );
	animIndex = RandomInt( self GetAnimEntryCount( animStateInfo[ "anim_state" ] ) );
	anime = self GetAnimEntry( animStateInfo[ "anim_state" ], animIndex );
	self maps\mp\alien\_utility::always_play_pain_sound( anime );
	self maps\mp\alien\_utility::register_pain( anime );
	
	self PlayAnimNUntilNotetrack( animStateInfo[ "anim_state" ], animIndex, animStateInfo[ "anim_label" ] );
	self.playing_pain_animation = false;
	
	self notify( "pain_finished" );
}

check_for_block( player )
{
	if (!(isPlayer( player )))
	    return false;
	
	enemy_blocked = false;
	weapon = player getcurrentWeapon();
	enemy_in_front = false;
	melee_in_hand = false;
	melee_weapon_health = 0;
	playerForwardVector = anglesToForward( player.angles );
    playerToEnemyVector = VectorNormalize( self.origin - player.origin );
    dotProduct = VectorDot( playerToEnemyVector, playerForwardVector );
    if ( dotProduct > 0.5 )
    {
        enemy_in_front = true;
    }
    
    if ( weapon == "iw5_alienriotshield_mp" )
	{
		melee_weapon_health = player GetCurrentWeaponClipAmmo();
		melee_in_hand = true;
	}
    
    if ( melee_in_hand && enemy_in_front && ( melee_weapon_health > 0 ) )
	{
    	player SetWeaponAmmoClip( "iw5_alienriotshield_mp", ( melee_weapon_health - 1 ));
		player PlaySound( "crate_impact" );
    	Earthquake( 0.75,0.5,player.origin, 100 );
    	enemy_blocked = true;
    	if ( player GetCurrentWeaponClipAmmo() == 0 )
    	{
    		player TakeWeapon( weapon );
    		weapon_list = player GetWeaponsList( "primary" );
    		if ( weapon_list.size > 0 )
    		{
    			player SwitchToWeapon( weapon_list[0] );
    		}
		}
  	}
   	return enemy_blocked;
}

melee_clean_up( attacker )
{
	self endon( "death" );
	
	attacker_alien_type = attacker maps\mp\alien\_utility::get_alien_type();
	
	attacker waittill( "killanimscript" );
	
	//Reset alien melee related flags
	if ( attacker_alien_type == "elite" )
		self.being_charged = false;
}

get_melee_painState_info( iDamage )
{
	result = [];
	
	switch( self.melee_type )
	{
	case "spit": 
		result[ "anim_state" ] = "idle_pain_light";
		result[ "anim_label" ] = "idle_pain";
		break;
	default:
		if ( isDefined ( self.melee_in_move_back ) && self.melee_in_move_back )
		{
			primaryAnimState = "move_back_pain";
			result[ "anim_label" ] = "move_back_pain";	
		}
		else
		{
			primaryAnimState = "melee_pain";
			result[ "anim_label" ] = "melee_pain";
		}
		
		result[ "anim_state" ] = self maps\mp\agents\alien\_alien_anim_utils::getPainAnimState( primaryAnimState, iDamage );
		break;
	}
	
	return result;
}
