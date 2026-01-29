ALIEN_CHARGE_ATTACK_DISTANCE_MAX = 400;
ELITE_ATTACK_START_SOUND = "alien_queen_attack";
CHARGE_HIT_SOUND = "alien_queen_hit";
CHARGE_ATTACK_START_SOUND = "alien_queen_roar";

elite_approach( enemy, attack_counter )
{
	/# maps\mp\agents\alien\_alien_think::debug_alien_ai_state( "elite_approach" ); #/
	/# maps\mp\agents\alien\_alien_think::debug_alien_attacker_state( "attacking" ); #/
			
	// Run near enemy
	self maps\mp\agents\alien\_alien_think::run_near_enemy( ALIEN_CHARGE_ATTACK_DISTANCE_MAX, enemy );
	
	if ( should_do_health_regen() )
	{
		return go_for_health_regen( enemy );
	}
	else if ( maps\mp\agents\_scriptedagents::CanMovePointToPoint( self.origin, enemy.origin )  
	  && self maps\mp\alien\_utility::is_normal_upright( anglesToUp( self.angles ) )
	   )
	{
		return "charge";
	}
	else
	{
		self PlaySound(ELITE_ATTACK_START_SOUND);
		return maps\mp\agents\alien\_alien_think::go_for_swipe( enemy );
	}
}

charge_attack( enemy )
{
	/# maps\mp\agents\alien\_alien_think::debug_alien_ai_state( "charge_attack" ); #/
		
	if ( enemy being_charged() )
	{
		wait 0.2;
		return;
	}
	
	self.melee_type = "charge";
	maps\mp\agents\alien\_alien_think::alien_melee( enemy );
	enemy.being_charged = false;
}

health_regen( enemy )
{
	/# maps\mp\agents\alien\_alien_think::debug_alien_ai_state( "health_regen" ); #/
			
	self.melee_type = "health_regen";
	maps\mp\agents\alien\_alien_think::alien_melee( enemy );
}

do_charge_attack( enemy )
{		
	self endon( "death" );
	
	enemy.being_charged = true;
	self maps\mp\agents\alien\_alien_anim_utils::turnTowardsEntity( enemy );
	
	self playSound( CHARGE_ATTACK_START_SOUND );
	
	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetPhysicsMode( "gravity" );
	self ScrAgentSetOrientMode( "face enemy" );
	
	charge_start_index = get_charge_start_index();
	self maps\mp\agents\_scriptedagents::SafelyPlayAnimNAtRateUntilNotetrack( "charge_attack_start", charge_start_index, 1.15, "charge_attack_start", "end" );
	
	if ( isAlive( enemy ) && can_see_enemy( enemy ) )
	{
		self thread track_enemy( enemy );
		self SetAnimState( "charge_attack", undefined, 1.2);
		
		result = watch_charge_hit( enemy );
		self notify( "charge_complete" );
		self ScrAgentSetOrientMode( "face angle abs", self.angles );
		
		switch ( result )
		{
		case "success":
			if ( IsAlive( enemy ) )
				enemy playSound( CHARGE_HIT_SOUND );
			self maps\mp\agents\_scriptedagents::SafelyPlayAnimAtRateUntilNotetrack( "charge_attack_bump", 1.0, "charge_attack_bump", "end" );
			break;
		case "fail":
			self play_stop_anim();
			break;
		default:
			assertmsg( "Unknown charge hit result: " + result );
			break;
		}
		self ScrAgentSetAnimMode( "code_move" );
	}
}

can_see_enemy( enemy )
{
	return SightTracePassed( self getEye(), enemy getEye(), false, self );	
}

track_enemy( enemy )
{
	self endon( "death" );
	self endon( "charge_complete" );
	
	STOP_TRACKING_DISTANCE_SQ = 350 * 350;
	self.charge_tracking_enemy = true;
	
	while ( true )
	{
		if ( DistanceSquared( self.origin, enemy.origin ) < STOP_TRACKING_DISTANCE_SQ )
			break;
		
		wait 0.05;	
	}
	
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	self.charge_tracking_enemy = false;
}

play_stop_anim()
{
	FORWARD_CLEARANCE = 120;	
	
	if ( hit_geo( FORWARD_CLEARANCE ) )   
		go_hit_geo();
	else
		self maps\mp\agents\_scriptedagents::SafelyPlayAnimAtRateUntilNotetrack( "charge_attack_stop", 1.0, "charge_attack_stop", "end" );
}

go_hit_geo()
{
	hit_geo_index = get_hit_geo_index();
	hit_geo_anim = self GetAnimEntry( "charge_hit_geo", hit_geo_index );
	notetrack_time = GetNotetrackTimes( hit_geo_anim, "forward_end" );
	forward_delta = length( GetMoveDelta( hit_geo_anim, 0.0, notetrack_time[ 0 ] ) );
	
	while ( true )
	{
		if ( hit_geo( forward_delta ) )
			break;
		
		common_scripts\utility::waitframe();
	}
	self maps\mp\agents\_scriptedagents::SafelyPlayAnimNAtRateUntilNotetrack( "charge_hit_geo", hit_geo_index, 1.0, "charge_hit_geo", "end" );
}

watch_charge_hit( enemy )
{
	self endon( "death" );
	enemy endon( "death" );
	
	MIN_CHARGE_TIME = 3.0;
	MAX_CHARGE_TIME = 6.0;
	FRAME_TIME = 0.05;
	
	chargeStopAnim = self GetAnimEntry( "charge_attack_stop", 0 );
	num_loops = int( randomFloatRange( MIN_CHARGE_TIME, MAX_CHARGE_TIME ) / FRAME_TIME );
	animDistance = Length( GetMoveDelta( chargeStopAnim ) );
	animLength = GetAnimLength( chargeStopAnim );
	lookAheadDistance = (animDistance / animLength) * FRAME_TIME * 3;
	
	for ( i = 0; i < num_loops; i++ )
	{
		if ( hit_player() )
			return "success";
		
		if ( hit_geo( lookAheadDistance  ) )
			return "fail";
		
		if ( !self.charge_tracking_enemy && missed_enemy( enemy ) )
			return "fail";
		
		common_scripts\utility::waitframe();
	}
	return "fail";  //time out
}

hit_player( hitAnimLength )
{	
	CHARGE_HIT_DIST = 140;
	
	foreach( player in level.players )
	{
		if ( distanceSquared ( self.origin, player.origin ) < CHARGE_HIT_DIST * CHARGE_HIT_DIST 
		  && might_hit_enemy( player )
		   )
		{
			self maps\mp\agents\alien\_alien_melee::melee_DoDamage( player, "charge" );
			player thread player_fly_back( vectorNormalize( player.origin - self.origin ));
			return true;
		}
	}
	return false;
}

hit_geo( lookAheadDistance  )
{	
	OFFSET_HEIGHT = 18.0;
	COS_30 = 0.866;
	
	traceStart = self.origin + ( 0, 0, OFFSET_HEIGHT );
	traceEnd = traceStart + AnglesToForward(self.angles ) * lookAheadDistance;
	
	hitInfo = self AIPhysicsTrace( traceStart, traceEnd, self.radius, self.height - OFFSET_HEIGHT, true, true );
	return hitInfo["fraction"] < 1.0 && hitInfo["normal"][2] < COS_30;
}

player_fly_back( direction )
{	
	IMPLUSE_FORCE = 1200;
	
	original_velocity = self GetVelocity();
	impluse_velocity = direction * IMPLUSE_FORCE;
	
	final_velocity = ( original_velocity + impluse_velocity ) * ( 1, 1, 0 );
	
	self SetVelocity( final_velocity );
}

might_hit_enemy( enemy )
{
	CONE_LIMIT = 0.866; //cos( 30 )

	can_see_enemy = can_see_enemy( enemy );
	
	self_to_enemy = vectorNormalize ( enemy.origin - self.origin );
	self_forward = anglesToForward( self.angles);
	enemy_in_front_cone = VectorDot( self_to_enemy, self_forward ) > CONE_LIMIT;
	
	return ( can_see_enemy && enemy_in_front_cone );
}

missed_enemy( enemy )
{
	pastEnemyDistance = -256;
	can_see_enemy = can_see_enemy( enemy );

	if ( !can_see_enemy ) 
		return true;
	
	self_to_enemy = enemy.origin - self.origin;
	self_forward = anglesToForward( self.angles);
	distancePast = VectorDot( self_to_enemy, self_forward );

	if ( distancePast > 0 )
		return false;
	
	return distancePast < pastEnemyDistance;
}

being_charged()
{
	return ( isDefined( self.being_charged ) && self.being_charged );
}

get_charge_start_index()
{
	animWeights = [ 50 /*alien_queen_charge_start*/, 
				    25 /*alien_queen_charge_start_v2*/,
					25 /*alien_queen_charge_start_v3*/				    
				  ];
	return get_weighted_index( "charge_attack_start", animWeights );
}

get_hit_geo_index()
{
	animWeights = [ 15 /*alien_drone_run_bump_heavy*/, 
				    25 /*alien_drone_run_bump_medium*/,
					60 /*alien_drone_run_bump_light*/				    
				  ];
	return get_weighted_index( "charge_hit_geo", animWeights );
}

get_weighted_index( animState, animWeights )
{
	nEntries = self GetAnimEntryCount( animState );
	assert( animWeights.size == nEntries );
	return maps\mp\agents\alien\_alien_move::GetRandomIndex( animWeights );
}

load_queen_fx()
{
	level._effect[ "queen_shield_impact" ] 	= Loadfx( "fx/impacts/large_metalhit_1" );
	level._effect[ "queen_shield" ] 	    = Loadfx( "vfx/moments/alien/shield_bubble" );
}

hitQueenBodyPartImmuneToDamage( vPoint, vDir, sHitLoc )
{	
	if ( head_shield_activated() )
	{
		switch ( sHitLoc )
		{
		//<TODO JC> When the new Queen model is checked in, we need to double check those hit locations to make sure they match the part of the body that is immune to damages
		case "head":
		case "neck":
		case "torso_upper":
		case "left_arm_upper":
		case "right_arm_upper":
			thread play_shield_impact_fx( vPoint, vDir ); //<TODO JC> Remove this as the impact effect will eventually be played from the character model's surface type	
			return true;
		default:
			return false;
		}
	}
	else
	{
		return false;
	}	
}

head_shield_activated()
{
	return self.head_shield_activated;
}

queen_init()
{
	self.head_shield_activated = true;
	self.next_health_regen_time = getTime();
}

activate_health_regen()
{
	level endon ( "game_ended" );
	self endon ( "death" );
	
	CONST_HEALTH_REGEN_TIME = 10.0; // in sec
	CONST_HEALTH_REGEN_COOL_DOWN = 60000; // in ms
	
	self.next_health_regen_time = getTime() + CONST_HEALTH_REGEN_COOL_DOWN;
	
	thread play_health_regen_anim();
	
	activate_health_regen_shield();
	thread queen_health_regen( CONST_HEALTH_REGEN_TIME );
	
	self common_scripts\utility::waittill_any_timeout( CONST_HEALTH_REGEN_TIME, "stop_queen_health_regen" );
	
	disable_health_regen_shield();
}

play_health_regen_anim()
{
	level endon ( "game_ended" );
	self endon ( "death" );
	self endon ( "stop_queen_health_regen" );
	
	self ScrAgentSetAnimMode( "anim deltas" );
	self ScrAgentSetOrientMode( "face angle abs", self.angles );
	
	anim_state = "minion_explode"; 
		
	while ( true )
	{
		maps\mp\agents\_scriptedagents::PlayAnimUntilNotetrack( anim_state, anim_state, "end" );
	}
}

queen_health_regen( CONST_HEALTH_REGEN_TIME )
{
	level endon ( "game_ended" );
	self endon ( "death" );
	self endon ( "stop_queen_health_regen" );
	
	CONST_HEALTH_REGEN_INTERVAL = 1.0;  // in sec
	
	num_of_regen = int ( CONST_HEALTH_REGEN_TIME / CONST_HEALTH_REGEN_INTERVAL );
	total_health_to_regen = ( self.maxhealth - self.health ) / 2;  // regen only to up the midpoint between current health and max health
	health_each_regen = int ( total_health_to_regen / num_of_regen );  
	
	for ( i = 0; i < num_of_regen; i++ )
	{
		wait ( CONST_HEALTH_REGEN_INTERVAL );
		self.health += health_each_regen;
	}
}

activate_health_regen_shield()
{
	self.shield_model = deploy_health_regen_shield();
	self.shield_FX = PlayLoopedFX ( level._effect[ "queen_shield" ], 10.0, self.origin );
	
	self.shield_model thread clean_up_on_owner_death( self );
	self.shield_FX thread clean_up_on_owner_death( self );
}

disable_health_regen_shield()
{
	self.shield_model delete();
	self.shield_FX delete();
}

clean_up_on_owner_death( owner )
{
	level endon ( "game_ended" );
	self endon ( "death" );
	owner endon ( "stop_queen_health_regen" );
	
	owner waittill ( "death" );
	self delete();
}

deploy_health_regen_shield()
{
	shield = spawn ( "script_model", self.origin );
	shield setModel ( "alien_shield_bubble_distortion" );
	shield linkTo ( self, "tag_origin" );
	shield setCanDamage ( true );
	
	return shield;
}

//<TODO JC> Remove this as the impact effect will eventually be played from the character model's surface type	
play_shield_impact_fx( vPoint, vDir )
{
	forward_vector = vDir * -1;
	up_vector = anglesToUp ( vectorToAngles ( forward_vector ) );
	PlayFX( level._effect[ "queen_shield_impact" ], vPoint, forward_vector, up_vector );
}

should_do_health_regen()
{
	QUEEN_LOW_HEALTH_RATIO = 0.5;
	
	if ( ( self.health / self.maxhealth ) > QUEEN_LOW_HEALTH_RATIO )
		return false;
	
	if ( getTime() < self.next_health_regen_time )
		return false;
	
	return true;
}

go_for_health_regen( enemy )
{
	health_regen_node = get_best_health_regen_node ( enemy );
	
	if ( isDefined ( health_regen_node ) )
	{
		self ScrAgentSetGoalNode( health_regen_node );
		self ScrAgentSetGoalRadius( 64 );
		self waittill( "goal_reached" );
	}
	
	return "regen_health";
}

get_best_health_regen_node( enemy )
{	
	target_nodes = GetNodesInRadius( self.origin, 1500, 800, 250, "path" );
		
	if ( target_nodes.size == 0 )
		return undefined;
	
	filters = [];
	filters[ "direction" ] = "alien_forward";
	filters[ "direction_weight" ] = 2.0;
	filters[ "min_height" ] = 0.0;
	filters[ "max_height" ] = 250.0;
	filters[ "height_weight" ] = 2.0;
	filters[ "enemy_los" ] = false;
	filters[ "enemy_los_weight" ] = 0.0;
	filters[ "min_dist_from_enemy" ] = 800.0;
	filters[ "max_dist_from_enemy" ] = 1500.0;
	filters[ "desired_dist_from_enemy" ] = 1500.0;
	filters[ "dist_from_enemy_weight" ] = 10.0;
	filters[ "min_dist_from_all_enemies" ] = 1000.0;
	filters[ "min_dist_from_all_enemies_weight" ] = 10.0;
	filters[ "not_recently_used_weight" ] = 4.0;
	filters[ "random_weight" ] = 1.0;
	
	result = maps\mp\agents\alien\_alien_think::get_retreat_node_rated( enemy, filters, target_nodes );
	
	return result;
}

queenDamageProcessing( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( shouldStopQueenHealthRegen( sMeansOfDeath ) )
		self notify ( "stop_queen_health_regen" );
}

shouldStopQueenHealthRegen( sMeansOfDeath )
{
	switch ( sMeansOfDeath )
	{
	case "MOD_EXPLOSIVE":
	case "MOD_EXPLOSIVE_BULLET":
	case "MOD_GRENADE_SPLASH":
		return true;
	default:
		return false;
	}
}

on_jump_impact()
{
	DAMAGE_RADIUS = 256;
	DAMAGE_RADIUS_SQUARED = DAMAGE_RADIUS * DAMAGE_RADIUS;
	MAX_DAMAGE = 30;
	MIN_DAMAGE = 10;
	
	alienUp = anglesToUp( self.angles );
	if ( !maps\mp\alien\_utility::is_normal_upright( alienUp ) )
		return;
	
	RadiusDamage( self.origin, DAMAGE_RADIUS, MAX_DAMAGE, MIN_DAMAGE, self );
	
    foreach ( player in level.players )
    {
        if ( DistanceSquared( self.origin, player.origin ) > DAMAGE_RADIUS_SQUARED )
            continue;
        
        pushDirection = VectorNormalize(player.origin - self.origin );
        player thread player_fly_back( pushDirection );
    }
}
