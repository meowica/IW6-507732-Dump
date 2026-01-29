#include common_scripts\utility;

ALIEN_SPIT_ATTACK_DISTANCE_MAX = 1200;
MIN_SPIT_TIMES = 3;
MAX_SPIT_TIMES = 6;
SPIT_ATTACK_START_SOUND = "alien_spitter_attack";
SPIT_ATTACK_HIT_SOUND = "alien_spitter_hit";

SPITTER_NODE_DURATION = 20;   // Max length of time they stay at one spit node
SPITTER_FIRE_INTERVAL_MIN = 4.0;	// Min amount of time in between a projectile fire
SPITTER_FIRE_INTERVAL_MAX = 7.0;	// Max amount of time in between a projectile fire
SPITTER_PROJECTILE_BARRAGE_SIZE = 3;	// Number of small projectiles to shoot at a time when not shooting a gas cloud

SPITTER_GAS_CLOUD_FIRE_INTERVAL_MIN = 15.0;	// Min amount of time in between a gas cloud projectile fire
SPITTER_GAS_CLOUD_FIRE_INTERVAL_MAX = 20.0;	// Max amount of time in between a gas cloud projectile fire
SPITTER_GAS_CLOUD_MAX_COUNT = 3; // Max number of active gas clouds in a level

SPITTER_NODE_DAMAGE_DELAY = 1.5;    // How long they wait to move from a spit node after getting damaged
SPITTER_MIN_PLAYER_DISTANCE_SQ = 90000.0;	// If player gets within 300 units, they'll move to a new spit node
SPITTER_MOVE_MIN_PLAYER_DISTANCE_SQ = 40000.0;  // If player gets within 200 units while alien is moving, they'll stop and spit a projectile at them
SPITTER_NODE_INITIAL_FIRE_DELAY_SCALE = 0.5;	// Initial scale on delay before a spitter can spit after getting to a node

SPITTER_AOE_HEIGHT = 128;	// Height of gas cloud
SPITTER_AOE_RADIUS = 128;	// Radius of gas cloud
SPITTER_AOE_DURATION = 10.0;	// How long the gas cloud lasts
SPITTER_AOE_DELAY = 2.0;	// How long after projectile explodes before gas cloud damage is applied
SPITTER_AOE_DAMAGE_PER_SECOND = 4.0;	// Damage per second at center of gas cloud

load_spitter_fx()
{
	level._effect[ "spit_AOE" ] 					= LoadFX( "vfx/gameplay/alien/vfx_alien_spitter_gas_cloud" );	
}

spitter_init()
{
	self.gas_cloud_available = true;
}

spitter_approach( enemy, attack_counter )
{
	/# maps\mp\agents\alien\_alien_think::debug_alien_ai_state( "spitter_approach" ); #/
	/# maps\mp\agents\alien\_alien_think::debug_alien_attacker_state( "attacking" ); #/
		
	self endon( "alien_main_loop_restart" );
			
	// Run near enemy
	if ( attack_counter == 0 )
		self maps\mp\agents\alien\_alien_think::run_near_enemy( ALIEN_SPIT_ATTACK_DISTANCE_MAX, enemy );

	self.spit_node = get_spit_node ( enemy, attack_counter );
	
	if ( isDefined( self.spit_node ))
	{		
		self ScrAgentSetGoalNode( self.spit_node );
		self ScrAgentSetGoalRadius( 64 );
		self waittill( "goal_reached" );
		
		return "spit";
	}
	else
	{	
		return maps\mp\agents\alien\_alien_think::go_for_swipe( enemy );
	}
}

spit_projectile( enemy )
{
	self.melee_type = "spit";
	maps\mp\agents\alien\_alien_think::alien_melee( enemy );
}

spit_attack( targetedEnemy )
{
	/# maps\mp\agents\alien\_alien_think::debug_alien_ai_state( "spit_attack" ); #/	
	self endon( "melee_pain_interrupt" );

	targetedEnemy endon( "death" );
	
	self playSound( SPIT_ATTACK_START_SOUND );
	self.spit_target = targetedEnemy;
	self.spit_target_location = targetedEnemy.origin;
	self.spit_fire_pos = get_spit_fire_pos( targetedEnemy );
	self.looktarget = targetedEnemy;
	
	if ( IsDefined ( self.current_spit_node ) && !maps\mp\alien\_utility::is_normal_upright( self.current_spit_node.angles ) )
	{
		self ScrAgentSetOrientMode( "face angle abs", self.angles );	
	}
	else if ( targetedEnemy == self.enemy )
	{
		self ScrAgentSetOrientMode( "face enemy" );
	}
	else
	{
		angleToFace = VectorToAngles( targetedEnemy.origin - self.origin );
		self ScrAgentSetOrientMode( "face angle abs", angleToFace );
	}
		
	self ScrAgentSetAnimMode( "anim deltas" );
	
	self maps\mp\agents\_scriptedagents::PlayAnimUntilNotetrack( "spit_attack", "spit_attack", "end", ::handleAttackNotetracks );
	self.looktarget = undefined;
}

getBestSpitTarget( targeted_enemy )
{
	if ( cointoss() )
	{
		griefTargets = get_grief_targets();
		
		foreach ( griefTarget in griefTargets )
		{
			if ( is_valid_spit_target( griefTarget ) )
				return griefTarget;
		}
		wait 0.05;
	}
	
	if ( IsDefined( targeted_enemy ) )
	{
		isInvalidPlayer = IsPlayer( targeted_enemy ) && !IsAlive( targeted_enemy );
		if ( !isInvalidPlayer && is_valid_spit_target( targeted_enemy ) )
			return targeted_enemy;
	}
	
	foreach ( player in level.players )
	{
		if ( !IsAlive( player ) )
			continue;
		
		if ( IsDefined( targeted_enemy ) && player == targeted_enemy )
			continue;
		
		if ( is_player_valid_spit_target( player ) )
			return player;
	}
	
	return undefined;
}

get_grief_targets()
{
	griefTargets = [];
	
	foreach( player in level.players )
	{
		if ( !IsAlive( player ) )
			continue;
		
		if ( IsDefined( player.inLastStand ) && player.inLastStand )
			griefTargets[griefTargets.size] = player;
	}
	
	if ( IsDefined( level.bomb ) && (!IsDefined( level.bomb.attackable) || !level.bomb.attackable) )
		griefTargets[griefTargets.size] = level.bomb;
	
	return array_randomize( griefTargets );
}

is_valid_spit_target( spit_target )
{
	if ( !isAlive( spit_target ) )
	{
		return false;
	}
	
	self.looktarget = spit_target;
	self maps\mp\agents\alien\_alien_anim_utils::turnTowardsEntity( spit_target );

	if ( !isAlive( spit_target ) )
	{
		return false;
	}
	
	if ( isPlayer( spit_target ) )
		endPos = spit_target getEye();
	else
		endPos = spit_target.origin;

	spitFirePos = get_spit_fire_pos( spit_target );
	return BulletTracePassed( spitFirePos, endPos, false, self );
}

get_spit_fire_pos( spit_target )
{
	tagOrigin = self GetTagOrigin( "TAG_BREATH" );
	firePos = tagOrigin + VectorNormalize( spit_target.origin - self.origin ) * 20; // 20 units forward to make sure the projectile is not fired inside the alien
					
	return ( firePos[0], firePos[1], Max( tagOrigin[2], firePos[2] ) );
}

is_player_valid_spit_target( player )
{
	maxValidAttackerValue = level.maxAlienAttackerDifficultyValue - level.alien_types[ self.alien_type ].attributes[ "attacker_difficulty" ];
	maxValidDistanceSq = ALIEN_SPIT_ATTACK_DISTANCE_MAX * ALIEN_SPIT_ATTACK_DISTANCE_MAX;
	
	flatDistanceToPlayerSquared = Distance2DSquared( self.origin, player.origin );
	if ( flatDistanceToPlayerSquared > maxValidDistanceSq )
		return false;
	
	targetedAttackerScore = maps\mp\agents\alien\_alien_think::get_current_attacker_value( player );
	if ( targetedAttackerScore > maxValidAttackerValue )
		return false;
	
	return is_valid_spit_target( player );
}

handleAttackNotetracks( note, animState, animIndex, animTime )
{
	if ( note == "spit" )
		return self fire_spit_projectile();
}

fire_spit_projectile()
{	
	if ( !IsDefined( self.spit_target ) && !IsDefined( self.spit_target_location ) )
		return;

	hasValidTarget = IsAlive( self.spit_target );
	if ( hasValidTarget )
		targetLocation = self.spit_target.origin;
	else
		targetLocation = self.spit_target_location;
	
	if ( can_spit_gas_cloud() )
	{
		spit_gas_cloud_projectile( targetLocation );
	}
	else if (hasValidTarget )
	{
		PROJECTILE_SPEED = 1400;
		for ( spitIndex = 0; spitIndex < SPITTER_PROJECTILE_BARRAGE_SIZE; spitIndex++ )
		{
			// TODO: Lead the target a bit?
			targetLocation = get_lookahead_target_location( PROJECTILE_SPEED, self.spit_target );
			spit_basic_projectile( targetLocation );
			wait 0.5;
		}
	}
	
	self.spit_target = undefined;
	self.spit_target_location = undefined;
}

get_lookahead_target_location( projectile_speed, target )
{
	if ( !IsPlayer( target ) )
		return target.origin;
	
	LOOK_AHEAD_PERCENTAGE = 0.5;
	
	distanceToTarget = Distance( self.origin, target.origin);
	timeToImpact = distanceToTarget / projectile_speed;
	targetVelocity = target GetVelocity();
	
	return target.origin + targetVelocity * LOOK_AHEAD_PERCENTAGE * timeToImpact;
}

can_spit_gas_cloud()
{
	if ( !self.gas_cloud_available )
		return false;
	
	return level.spitter_gas_cloud_count < SPITTER_GAS_CLOUD_MAX_COUNT;
}

spit_basic_projectile( targetLocation )
{
	spitProjectile = MagicBullet( "alienspit_mp", self.spit_fire_pos, targetLocation );	
}

spit_gas_cloud_projectile( targetLocation )
{
	spitProjectile = MagicBullet( "alienspit_gas_mp", self.spit_fire_pos, targetLocation );
	
	if ( IsDefined( spitProjectile ) )
		spitProjectile thread spit_projectile_impact_monitor( self );
	
	self thread gas_cloud_available_timer();
}

gas_cloud_available_timer()
{
	self endon( "death" );
	
	self.gas_cloud_available = false;
	cloudInterval = RandomFloatRange( SPITTER_GAS_CLOUD_FIRE_INTERVAL_MIN, SPITTER_GAS_CLOUD_FIRE_INTERVAL_MAX );
	wait cloudInterval;
	self.gas_cloud_available = true;
}

spit_projectile_impact_monitor( owner )
{	
	self waittill( "explode", explodeLocation );
	
	if ( !IsDefined( explodeLocation ) )
		return;
	
	trigger = Spawn( "trigger_radius", explodeLocation, 0, SPITTER_AOE_RADIUS, SPITTER_AOE_HEIGHT  );
	// sanity check. Need to come up with more robust fallback
	if ( !IsDefined( trigger ) )
		return;
	
	level.spitter_gas_cloud_count++;
	trigger.onPlayer = true;
	PlayFx( level._effect[ "spit_AOE" ], explodeLocation + (0,0,32) );
	thread spit_aoe_cloud_damage( explodeLocation, trigger );
	
	wait SPITTER_AOE_DURATION;
	trigger Delete();
	level.spitter_gas_cloud_count--;
}

spit_aoe_cloud_damage( impact_location, trigger )
{
	trigger endon( "death" );
	
	wait SPITTER_AOE_DELAY;
	
	while ( true )
	{
		trigger waittill( "trigger", player );
		
		if ( !IsPlayer( player ) )
			continue;
		
		if ( !IsAlive( player ) )
			continue;
		
		disorient_player( player );
		damage_player( player, trigger );
	}
}

damage_player( player, trigger )
{
	DAMAGE_INTERVAL = 0.5; 
	
	currentTime = GetTime();
	
	if ( !IsDefined( player.last_spitter_gas_damage_time ) )
	{
		elapsedTime = DAMAGE_INTERVAL;		
	}
	else if (player.last_spitter_gas_damage_time + DAMAGE_INTERVAL * 1000.0 > currentTime )
	{	
		return;
	}
	else
	{
		elapsedTime = Min( DAMAGE_INTERVAL, (currentTime - player.last_spitter_gas_damage_time) * 0.001 );
	}
	
	damageAmount = int(SPITTER_AOE_DAMAGE_PER_SECOND * elapsedTime);
	player thread [[ level.callbackPlayerDamage ]]( trigger, trigger, damageAmount, 0, "MOD_SUICIDE", "alienspit_mp", trigger.origin, ( 0,0,0 ), "none", 0 );	
	player.last_spitter_gas_damage_time = currentTime;
}

disorient_player( player )
{
	player ShellShock( "alien_spitter_gas_cloud", 0.5 );
}

get_spit_node ( enemy, attack_counter )
{
	ENEMY_TOO_CLOSE_DIST = 400;
	
	if( attack_counter == 0 
	  || ( DistanceSquared ( self.origin, enemy.origin ) < ENEMY_TOO_CLOSE_DIST * ENEMY_TOO_CLOSE_DIST )
	  )
	{
		return get_distant_spit_node ( enemy );
	}
	else
	{
		return get_nearby_spit_node( enemy );
	}
}

get_distant_spit_node ( enemy )
{	
	target_nodes = get_good_spit_nodes( ( enemy.origin + self.origin ) / 2, 800, 400, 256 );
		
	if ( target_nodes.size == 0 )
		return;
	
	target_direction = get_RL_toward( enemy );
	
	filters = [];
	filters[ "direction" ] = "override";
	filters[ "direction_override" ] = target_direction;
	filters[ "direction_weight" ] = 2.0;
	filters[ "min_height" ] = 64.0;
	filters[ "max_height" ] = 400.0;
	filters[ "height_weight" ] = 4.0;
	filters[ "enemy_los" ] = true;
	filters[ "enemy_los_weight" ] = 10.0;
	filters[ "min_dist_from_enemy" ] = 400.0;
	filters[ "max_dist_from_enemy" ] = 800.0;
	filters[ "desired_dist_from_enemy" ] = 600.0;
	filters[ "dist_from_enemy_weight" ] = 8.0;
	filters[ "min_dist_from_all_enemies" ] = 200.0;
	filters[ "min_dist_from_all_enemies_weight" ] = 1.0;
	filters[ "not_recently_used_weight" ] = 4.0;
	filters[ "random_weight" ] = 1.0;
	
	result = maps\mp\agents\alien\_alien_think::get_retreat_node_rated( enemy, filters, target_nodes );
	
	return result;
}

get_nearby_spit_node( enemy )
{
	nearby_spit_nodes = get_good_spit_nodes( self.origin, 150, 50, 5 );
	
	if ( nearby_spit_nodes.size == 0 )
		return;
	
	target_direction = get_RL_toward( enemy );
	
	filters = [];
	filters[ "direction" ] = "override";
	filters[ "direction_override" ] = target_direction;
	filters[ "direction_weight" ] = 1.0;
	filters[ "min_height" ] = 0.0;
	filters[ "max_height" ] = 100.0;
	filters[ "height_weight" ] = 1.0;
	filters[ "enemy_los" ] = true;
	filters[ "enemy_los_weight" ] = 4.0;
	filters[ "min_dist_from_enemy" ] = 400.0;
	filters[ "max_dist_from_enemy" ] = 800.0;
	filters[ "desired_dist_from_enemy" ] = 600.0;
	filters[ "dist_from_enemy_weight" ] = 3.0;
	filters[ "min_dist_from_all_enemies" ] = 200.0;
	filters[ "min_dist_from_all_enemies_weight" ] = 1.0;
	filters[ "not_recently_used_weight" ] = 4.0;
	filters[ "random_weight" ] = 1.0;
	
	result = maps\mp\agents\alien\_alien_think::get_retreat_node_rated( enemy, filters, nearby_spit_nodes );
	
	return result;
}

get_good_spit_nodes( targetPos, maxRadius, minRadius, maxHeight )
{
	nodes = GetNodesInRadius( targetPos, maxRadius, minRadius, maxHeight, "jump" ); 
	
	if ( nodes.size == 0 )
		nodes = GetNodesInRadius( targetPos, maxRadius, minRadius, maxHeight );  
	
	return nodes;
}

get_RL_toward( target )
{
	//Return the right/left vector toward target
	self_to_target_angles = VectorToAngles( target.origin - self.origin );
	target_direction = anglesToRight( self_to_target_angles );
	
	if ( common_scripts\utility::cointoss())
		target_direction *= -1;
	
	return target_direction;
}

get_spitter_attack_num()
{
	return RandomIntRange( MIN_SPIT_TIMES, MAX_SPIT_TIMES );
}

should_spitter_retreat()
{
	return false;
}

spitter_combat( enemy )
{
	self endon( "bad_path" );
	self endon( "death" );
	
	while ( true )
	{
		attackNode = find_spitter_attack_node( self.enemy );
		
		if ( IsDefined( attackNode ) )
		{
			move_to_spitter_attack_node( attackNode );
			spitter_attack( self.enemy );
		}
		else
		{
			wait 0.05;
		}

	}
}

move_to_spitter_attack_node( attack_node )
{
	self endon( "player_proximity_during_move" );
	
	if ( IsDefined( self.current_spit_node ) )
	{
		self.current_spit_node.claimed = false;
		self.current_spit_node = undefined;
	}
	
	self ScrAgentSetGoalNode( attack_node );
	self ScrAgentSetGoalRadius( 64 );
	self thread enemy_proximity_during_move_monitor();
	self waittill( "goal_reached" );

	self.current_spit_node = attack_node;
	attack_node.claimed = true;	
}

enemy_proximity_during_move_monitor()
{
	self endon( "death" );
	self endon( "goal_reached" );
	
	while ( true )
	{
		wait 0.05;
		
		if ( !self maps\mp\agents\alien\_alien_think::melee_okay() )
			continue;
		
		if ( IsDefined( self.valid_moving_spit_attack_time ) && GetTime() < self.valid_moving_spit_attack_time )
			continue;
		
		closePlayer = find_player_within_distance( SPITTER_MOVE_MIN_PLAYER_DISTANCE_SQ );
		if ( IsDefined( closePlayer ) )
			break;
	}
	
	self notify( "player_proximity_during_move" );
	self ScrAgentSetGoalEntity( closePlayer );
	self ScrAgentSetGoalRadius( 2048.0 );
	self waittill( "goal_reached" );
}

get_possible_spitter_attack_nodes( target_entity )
{
	attackNodes = GetNodesInRadius( target_entity.origin, 1000, 300, 512, "jump attack" );
	validNodes = [];
	
	foreach( attackNode in attackNodes )
	{
		if ( IsDefined( attackNode.claimed) && attackNode.claimed )
			continue;
		
		validNodes[validNodes.size] = attackNode;
	}
	
	return validNodes;
	
}

find_spitter_attack_node( target_enemy )
{
	nearbySpitNodes = [];
	if ( IsDefined( target_enemy ) )
		nearbySpitNodes = get_possible_spitter_attack_nodes( target_enemy );
	
	if ( nearbySpitNodes.size == 0 )
	{
		foreach ( player in level.players )
		{
			if ( !IsAlive( player ) )
				continue;
			
			if ( IsDefined( target_enemy ) &&  player == target_enemy )
				continue;
			
			wait 0.05;
			nearbySpitNodes = get_possible_spitter_attack_nodes( player );
			if ( nearbySpitNodes.size > 0 )
			{
				target_enemy = player;
				break;
			}
		}
	}
	
	if ( nearbySpitNodes.size == 0 )
		nearbySpitNodes = get_possible_spitter_attack_nodes( self );
	
	if ( nearbySpitNodes.size == 0 )
		return undefined;
	
	target_direction = get_RL_toward( target_enemy );
	
	filters = [];
	filters[ "direction" ] = "override";
	filters[ "direction_override" ] = target_direction;
	filters[ "direction_weight" ] = 1.0;
	filters[ "min_height" ] = 64.0;
	filters[ "max_height" ] = 400.0;
	filters[ "height_weight" ] = 4.0;
	filters[ "enemy_los" ] = true;
	filters[ "enemy_los_weight" ] = 6.0;
	filters[ "min_dist_from_enemy" ] = 300.0;
	filters[ "max_dist_from_enemy" ] = 800.0;
	filters[ "desired_dist_from_enemy" ] = 600.0;
	filters[ "dist_from_enemy_weight" ] = 8.0;
	filters[ "min_dist_from_all_enemies" ] = 300.0;
	filters[ "min_dist_from_all_enemies_weight" ] = 5.0;
	filters[ "not_recently_used_weight" ] = 10.0;
	filters[ "recently_used_time_limit" ] = 30.0;
	filters[ "random_weight" ] = 1.0;
	
	result = maps\mp\agents\alien\_alien_think::get_retreat_node_rated( target_enemy, filters, nearbySpitNodes );
	
	return result;	
}

spitter_attack( enemy )
{
	self endon( "spitter_node_move_requested" );
	
	if ( !IsDefined( self.current_spit_node ) )
	{
		spit_projectile( enemy );
		self.valid_moving_spit_attack_time = GetTime() + RandomFloatRange( SPITTER_FIRE_INTERVAL_MIN, SPITTER_FIRE_INTERVAL_MAX ) * 1000.0;
		return;
	}
	
	set_up_attack_node_watchers();
	wait RandomFloatRange( SPITTER_FIRE_INTERVAL_MIN, SPITTER_FIRE_INTERVAL_MAX ) * SPITTER_NODE_INITIAL_FIRE_DELAY_SCALE;
	
	while ( true )
	{
		targetedEnemy = undefined;
		while ( !IsDefined( targetedEnemy ) )
		{
			wait 0.2;
			targetedEnemy = getBestSpitTarget( enemy );
		}
		
		spit_projectile( targetedEnemy );
		wait RandomFloatRange( SPITTER_FIRE_INTERVAL_MIN, SPITTER_FIRE_INTERVAL_MAX );
	}
}

set_up_attack_node_watchers()
{
	self thread spitter_node_duration_monitor( SPITTER_NODE_DURATION );
	self thread spitter_node_attacked_monitor( SPITTER_NODE_DAMAGE_DELAY );
	self thread spitter_node_player_proximity( SPITTER_MIN_PLAYER_DISTANCE_SQ );
}

spitter_node_duration_monitor( duration )
{
	self endon( "spitter_node_move_requested" );
	self endon( "death" );
	
	wait duration;
	
	self notify( "spitter_node_move_requested" );
}

spitter_node_attacked_monitor( damage_delay )
{
	self endon( "spitter_node_move_requested" );
	self endon( "death" );
	
	self waittill( "damage" );
	wait damage_delay;
	
	self notify( "spitter_node_move_requested" );
}

spitter_node_player_proximity( min_player_distances_sq )
{
	self endon( "spitter_node_move_requested" );
	self endon( "death" );
	
	while ( true )
	{
		closePlayer = find_player_within_distance( min_player_distances_sq );
		if ( IsDefined( closePlayer ) )
			break;
		
		wait 0.2;
	}
	
	self notify( "spitter_node_move_requested" );
}

find_player_within_distance( distance_sq )
{
	foreach( player in level.players )
	{
		if ( !IsAlive( player ) )
			continue;
		
		flatDistanceToPlayerSq = Distance2DSquared( self.origin, player.origin ); 
		if ( flatDistanceToPlayerSq < distance_sq )
			return player;
	}

	return undefined;	
}