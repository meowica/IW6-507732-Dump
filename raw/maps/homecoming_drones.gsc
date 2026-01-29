#include maps\_utility;
#include common_scripts\utility;
#include maps\homecoming_util;
#include maps\_drone;

#using_animtree( "generic_human" );

drones_request( dronesAmount )
{
	struct = spawnStruct();
	struct.requestAmount = dronesAmount;
	level.droneQueue[ level.droneQueue.size ] = struct;
	struct waittill( "drones_granted", grantedAmount );
	
	if( GetDvarInt( "daniel" ) )
		iprintln( "drones granted : " + grantedAmount );
	
	return grantedAmount;
}

drones_request_queue()
{
	while( 1 )
	{
		while( level.droneQueue.size == 0 )
			wait( .05 );
		
		currentRequest = level.droneQueue[0];
		drones_request_think( currentRequest );
		level.droneQueue = array_remove( level.droneQueue, currentRequest );
	}
}

// logic for killing off killable drones goes here
// 
drones_request_think( struct )
{
	requestAmount = struct.requestAmount;
	
	if( GetDvarInt( "daniel" ) )
		iprintln( "drones requested : " + requestAmount );
			
	// first check availableDrones 
	num = level.availableDrones - requestAmount;
	
	// If num < 0 that means there weren't enough availableDrones, lets try to kill some
	if( num < 0 )
	{
		grantedAmount = level.availableDrones;
		level.availableDrones = 0;
	}
	else
	{
		level.availableDrones = level.availableDrones - requestAmount;
		grantedAmount = requestAmount;
	}
	
	// grantedAmount may be less than requested amount
	struct notify( "drones_granted", grantedAmount );
}

drones_death_watcher()
{
	self waittill_any( "death", "deleted" );
	level.availableDrones++;
}

CONST_MAX_DRONES = 60;
CONST_MAX_DRONES_NG = 85;
drones_request_init()
{
	level.droneQueue = [];
	level.availableDrones = CONST_MAX_DRONES;
	thread drones_request_queue();	
}

TRACE_HEIGHT = 100;
drone_move_custom( startStruct )
{
	self endon( "death" );
	self endon( "drone_stop" );

	// Wait a little so idle threads can initiate.
	wait( 0.05 );
	
	nodes = self Getpatharray( startStruct, self.origin );
	assert( isdefined( nodes ) );
	assert( isdefined( nodes[ 0 ] ) );

	prof_begin( "drone_math" );

	runAnim = level.drone_anims[ self.team ][ "stand" ][ "run" ];
	if ( isdefined( self.runanim ) )
	{
		runAnim = self.runanim;
	}
	
	struct = get_anim_data( runAnim );	
	run_speed = struct.run_speed;
	anim_relative = struct.anim_relative;
	
	if ( IsDefined( self.drone_move_callback ) )
	{
		struct = [[ self.drone_move_callback ]]();

		if ( IsDefined( struct ) )
		{
			runAnim = struct.runanim;
			run_speed = struct.run_speed;
			anim_relative = struct.anim_relative;
		}

		struct = undefined;
	}

	if ( !anim_relative )
	{
		self thread drone_move_z(run_speed);
	}
	
	self drone_play_looping_anim( runAnim, self.moveplaybackrate );
	
	loopTime = 0.5;
	currentNode_LookAhead = 0;
	self.started_moving = true;
	self.cur_node = nodes[ currentNode_LookAhead ];

	did_stairs = false;
	do_stairs = undefined;
	
	for ( ;; )
	{
		if ( !isdefined( nodes[ currentNode_LookAhead ] ) )
			break;

		// Calculate how far and what direction the lookahead path point should move
		//--------------------------------------------------------------------------

		// find point on real path where character is
		vec1 = nodes[ currentNode_LookAhead ][ "vec" ];
		vec2 = ( self.origin - nodes[ currentNode_LookAhead ][ "origin" ] );
		distanceFromPoint1 = vectorDot( vectorNormalize( vec1 ), vec2 );

		// check if this is the last node (wont have a distance value)
		if ( !isdefined( nodes[ currentNode_LookAhead ][ "dist" ] ) )
			break;
		
		drone_lookAhead_value = level.drone_lookAhead_value;
		if( isdefined( self.drone_lookAhead_value ) )
			drone_lookAhead_value = self.drone_lookAhead_value;
				
		lookaheadDistanceFromNode = ( distanceFromPoint1 + drone_lookAhead_value );
		assert( isdefined( lookaheadDistanceFromNode ) );

		assert( isdefined( currentNode_LookAhead ) );
		assert( isdefined( nodes[ currentNode_LookAhead ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "dist" ] ) );

		while ( lookaheadDistanceFromNode > nodes[ currentNode_LookAhead ][ "dist" ] )
		{
			// moving the lookahead would pass the node, so move it the remaining distance on the vector of the next node
			lookaheadDistanceFromNode = lookaheadDistanceFromNode - nodes[ currentNode_LookAhead ][ "dist" ];
			currentNode_LookAhead++ ;

			self.cur_node = nodes[ currentNode_LookAhead ];
			
			if ( !isdefined( nodes[ currentNode_LookAhead ][ "dist" ] ) )
			{
				//last node on the chain
				self rotateTo( vectorToAngles( nodes[ nodes.size - 1 ][ "vec" ] ), loopTime );
				d = distance( self.origin, nodes[ nodes.size - 1 ][ "origin" ] );
				timeOfMove = ( d / ( run_speed * self.moveplaybackrate ) );

				traceOrg1 = nodes[ nodes.size - 1 ][ "origin" ] + ( 0, 0, TRACE_HEIGHT );
				traceOrg2 = nodes[ nodes.size - 1 ][ "origin" ] - ( 0, 0, TRACE_HEIGHT );
				moveToDest = physicstrace( traceOrg1, traceOrg2 );

				if ( getdvar( "debug_drones" ) == "1" )
				{
					thread draw_line_for_time( traceOrg1, traceOrg2, 1, 1, 1, loopTime );
					thread draw_line_for_time( self.origin, moveToDest, 0, 0, 1, loopTime );
				}
				self moveTo( moveToDest, timeOfMove );
				
				wait timeOfMove;
				prof_end( "drone_math" );
				self notify( "goal" );
				
				if( IsDefined(  self.cur_node[ "script_noteworthy" ] ) )
	   				self drone_traverse_check();
				
				if( !isdefined( self.skipDelete ) )
					self thread check_delete();
				self thread drone_idle( nodes[ nodes.size - 1 ], moveToDest );
				return;
			}
			
			if ( !isdefined( nodes[ currentNode_LookAhead ] ) )
			{
				prof_end( "drone_math" );
				self notify( "goal" );
				
				if( IsDefined(  self.cur_node[ "script_noteworthy" ] ) )
	   				self drone_traverse_check();
				
				self thread drone_idle();
				return;
			}

			assert( isdefined( nodes[ currentNode_LookAhead ] ) );
		}
		
		//-------------------------------------------------------------------------
		
		//Override animation if callback is specified
		//-------------------------------------------
		if ( IsDefined( self.drone_move_callback ) )
		{
			struct = [[ self.drone_move_callback ]]();

			if ( IsDefined( struct ) )
			{
				runAnim = struct.runanim;

				if ( struct.runanim != runAnim )
				{
					run_speed = struct.run_speed;
					anim_relative = struct.anim_relative;
				
					if ( !anim_relative )
					{
						self thread drone_move_z( run_speed );
					}
					else
					{
						self notify( "drone_move_z" );
					}

					self drone_play_looping_anim( runAnim, self.moveplaybackrate );
				}
			}
		}
		

		
		// Move the lookahead point down along it's path
		//----------------------------------------------
		self.cur_node = nodes[ currentNode_LookAhead ];
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ][ 0 ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ][ 1 ] ) );
		assert( isdefined( nodes[ currentNode_LookAhead ][ "vec" ][ 2 ] ) );
		desiredPosition = ( nodes[ currentNode_LookAhead ][ "vec" ] * lookaheadDistanceFromNode );
		desiredPosition = desiredPosition + nodes[ currentNode_LookAhead ][ "origin" ];
		lookaheadPoint = desiredPosition;
		// trace the lookahead point to the ground
		traceOrg1 = lookaheadPoint + ( 0, 0, TRACE_HEIGHT );
		traceOrg2 = lookaheadPoint - ( 0, 0, TRACE_HEIGHT );
		lookaheadPoint = physicstrace( traceOrg1, traceOrg2 );
		
		if ( !anim_relative )
		{
			self.drone_look_ahead_point = lookaheadPoint;
		}
		
		if ( getdvar( "debug_drones" ) == "1" )
		{
			thread draw_line_for_time( traceOrg1, traceOrg2, 1, 1, 1, loopTime );
			thread draw_point( lookaheadPoint, 1, 0, 0, 16, loopTime );
			println( lookaheadDistanceFromNode + "/" + nodes[ currentNode_LookAhead ][ "dist" ] + " units forward from node[" + currentNode_LookAhead + "]" );
		}
		//---------------------------------------------


		//Rotate character to face the lookahead point
		//--------------------------------------------
		assert( isdefined( lookaheadPoint ) );
		characterFaceDirection = VectorToAngles( lookaheadPoint - self.origin );
		assert( isdefined( characterFaceDirection ) );
		assert( isdefined( characterFaceDirection[ 0 ] ) );
		assert( isdefined( characterFaceDirection[ 1 ] ) );
		assert( isdefined( characterFaceDirection[ 2 ] ) );
		self rotateTo( ( 0, characterFaceDirection[ 1 ], 0 ), loopTime );
		//--------------------------------------------


		//Move the character in the direction of the lookahead point
		//----------------------------------------------------------
		characterDistanceToMove = ( run_speed * loopTime * self.moveplaybackrate );
		moveVec = vectorNormalize( lookaheadPoint - self.origin );
		desiredPosition = ( moveVec * characterDistanceToMove );
		desiredPosition = desiredPosition + self.origin;
		if ( getdvar( "debug_drones" ) == "1" )
			thread draw_line_for_time( self.origin, desiredPosition, 0, 0, 1, loopTime );
		self moveTo( desiredPosition, loopTime );
		//----------------------------------------------------------

		wait loopTime;
		
//		if( IsDefined(  self.cur_node[ "script_noteworthy" ] ) )
//		   self drone_traverse_check();
		
	}
	
	if( IsDefined(  self.cur_node[ "script_noteworthy" ] ) )
	   self drone_traverse_check();
	
	self thread drone_idle();
	prof_end( "drone_math" );
}

drone_traverse_check()
{
	noteworthy = self.cur_node[ "script_noteworthy" ];
	sArray = StrTok( noteworthy, "_" );
	if( sArray[0] != "traverse" )
		return;
	
	struct = [];
	//assertEX( isdefined(  self.cur_node[ "vec" ] ), "drone traverse struct must have angles");
	//angles = VectorToAngles( self.cur_node[ "vec" ] );
	struct[ "origin" ] = self.cur_node[ "origin" ];
	struct[ "angles" ] = ( 0, 180, 0 ); //self.cur_node[ "angles" ];
	
	droneAnim = level.drone_anims[ self.team ][ "traverse" ][ noteworthy ];

	self drone_play_anim( droneAnim, struct );
	
}

drone_set_runanim()
{
	if( !isdefined( self.drone_runAnim ) )
		return;
	
	struct = spawnStruct();
	struct = maps\_drone::get_anim_data( self.drone_runAnim );
	struct.runanim = self.drone_runAnim;
	
	return struct;
}

DIST_FROM_FIGHTSPOT = 128;
hovercraft_drone_fightspots()
{
	fightSpotDist = Squared( DIST_FROM_FIGHTSPOT );

	while( 1 )
	{
		drones = array_removeDead( level.hovercraftDrones );
		if( drones.size == 0 )
		{
			wait( .1 );
			continue;
		}
		
		sortedDrones = SortByDistance( drones, self.origin );
		foreach( drone in sortedDrones )
		{
			if( isdefined( drone.hasSpot ) )
				sortedDrones = array_remove( sortedDrones, drone );
		}
		
		if( sortedDrones.size == 0 )
			break;
		
		drone = sortedDrones[0];
		
		if( Distance2DSquared( drone.origin, self.origin ) <= fightSpotDist )
		{
			drone.hasSpot = true;
			drone.skipDelete = true;
			drone notify( "drone_stop" );
			drone notify( "drone_random_death" );
			drone.drone_lookAhead_value = 50;
			drone thread drone_move_custom( self.targetname );
			drone.drone_idle_custom = true;
			drone.drone_idle_override = ::drone_fight_smart;
			drone waittill( "death" );
		}
		
		wait( .1 );
	}
}

DRONE_IDLE_TIME_MIN = 2;
DRONE_IDLE_TIME_MAX = 3.5;
drone_fight_smart( goal )
{
	self endon( "death" );
	
	// GOAL THING IS BROKEN
	if( isdefined( goal ) )
		self waittill( "goal" );
	
	sArray = [];
	if( self.team == "axis" )
		sArray = [ "ak47", "g36c", "fnp90" ];
	else
		sArray = [ "m4carbine", "m16", "m249saw" ];
	
	self.weaponsound = "drone_" + sArray[ randomint( sArray.size ) ] + "_fire_npc";
	
	currentNode = self.cur_node;
	assert( isdefined( currentNode ) );
	assert( isdefined( currentNode[ "script_noteworthy" ] ) );
	
	animType = currentNode[ "script_noteworthy" ];

	self.animset = animType;
	team = self.team;
	
	while( 1 )
	{
		num = randomint( level.drone_anims[ team ][ animType ][ "idle" ].size );
		self drone_play_anim( level.drone_anims[ team ][ animType ][ "idle" ][num], currentNode );
		
		if( cointoss() )
		{
			self drone_play_anim( level.drone_anims[ team ][ animType ][ "hide_2_aim" ], currentNode );
			
			if( animType == "coverprone" )
				self drone_play_anim( level.drone_anims[ team ][ animType ][ "fire_exposed" ] );
			else
				self drone_play_anim( level.drone_anims[ team ][ animType ][ "fire" ] );
			self maps\_drone::drone_fire_randomly();

			self drone_play_anim( level.drone_anims[ team ][ animType ][ "aim_2_hide" ] );
		}
	}
}

drone_play_anim( droneAnim, spot, deathplant )
{
	self clearAnim( %body, 0.2 );
	self stopAnimScripted();

	mode = "normal";
	if ( isdefined( deathplant ) )
		mode = "deathplant";
	
	if( isdefined( spot ) )
	{
		origin = spot[ "origin" ];
		angles = spot[ "angles" ];
		spot = spawnStruct();
		spot.origin = origin;
		spot.angles = angles;
	}
	else
		spot = self;
	
	flag = "drone_anim";
	self animscripted( flag, spot.origin, spot.angles, droneAnim, mode );
	//self animRelative( "drone_anim", self.origin, self.angles, droneAnim );
	self waittillmatch( "drone_anim", "end" );
}

drone_infinite_runners( flagEnder, spawnTime, runAnims, weaponSounds )
{
	spawners = undefined;
	if( !isarray( self ) )
		spawners = make_array( self );
	else
		spawners = self;
	
	while( !flag( flagEnder ) )
	{
		granted = drones_request( 1 );
		if( granted == 0 )
		{
			wait( .05 );
			continue;
		}
		
		spawner = spawners[ randomint( spawners.size ) ];
		drone = spawner spawn_ai();
		
		drone thread drones_death_watcher();
		
		runAnim = runAnims[ randomint( runAnims.size ) ];
		drone.runanim = level.drone_anims[ "allies" ][ "stand" ][ runAnim ];
		
		if( isdefined( weaponSounds )  )
			drone.weaponsound = weaponSounds[ randomint( weaponSounds.size ) ];
		
		if( runAnim == "run_n_gun" )
			drone thread drone_fire_randomly_loop();
		else if( runAnim == "sprint" )
			drone set_moveplaybackrate( 1.4 );
			
		drone notify( "move" );
		
		if( flag( flagEnder ) )
			break;
		
		wait( randomfloatrange( spawnTime[0], spawnTime[1] ) );
	}
}

beach_path_drones()
{
	self endon( "stop_drone_runners" );
	
	spawner = self;
	startStruct = getstruct( self.script_linkTo, "script_linkname" );
	maxSquadSize = 2;
	if( isdefined( spawner.script_count ) )
		maxSquadSize = spawner.script_count;
	
	if( !isdefined( self.script_wait_min ) )
	{
		self.script_wait_min = 8;	
		self.script_wait_max = 16;	
	}
	
	randomDeathTimeMin = 5;
	randomDeathTimeMax = 9;
	if( isdefined( self.randomDeath ) )
	{
		randomDeathTimeMin = self.randomDeath [0];
		randomDeathTimeMax = self.randomDeath [1];
	}
	
	while( 1 )
	{
		squadSize = randomint( maxSquadSize );
		squadSize = squadSize + 1;
		squadSize = drones_request( squadSize );
		for( i=0; i<squadSize; i++ )
		{
			drone = spawner spawn_ai();
			
			if( spawner parameters_check( "random_death" ) )
				drone delaythread( randomfloatrange( randomDeathTimeMin, randomDeathTimeMax ), ::drone_die );
			
			drone thread drones_death_watcher();
			
			if( isdefined( spawner.drone_lookAhead_value ) )
				drone.drone_lookAhead_value = spawner.drone_lookAhead_value;
			else
				drone.drone_lookAhead_value = 56;
			array = [ %stand_death_tumbleback, %stand_death_headshot_slowfall, %stand_death_shoulderback ];
			drone.deathAnim = array[ randomint( array.size ) ];
			
			drone thread drone_move_custom( startStruct.targetname );
			//ai thread ambient_runner_think();
			wait( randomfloatrange( .6, .9 ) );
		}
		
		//wait( randomintrange( 8, 16 ) );
		spawner script_wait();
	}
}

drone_fire_randomly_loop()
{
	self endon( "death" );
	
	//self waittill( "move" );
	
	while( 1 )
	{
		wait( randomfloatrange( .8, 1.2 ) );
		self thread maps\_drone::drone_fire_randomly();
	}
}

drone_fire_fake_javelin_loop( targets, smartTargeting, waitTime, explosionFX, wep )
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	if( !isdefined( level.fakeJavelinFireEnts ) )
		level.fakeJavelinFireEnts = [];
	
	minT = 4;
	maxT = 9;
	if( isdefined( waitTime ) )
	{
		minT = waitTime[0];
		maxT = waitTime[1];
	}
	
	if( !isdefined( self.javTargets ) )
		self.javTargets = [];
	if( isdefined( targets ) )
		self.javTargets = array_combine( self.javTargets, targets );

	if( !isdefined( self.javelin_smartTargeting ) )
	{
		if( isdefined( smartTargeting ) && smartTargeting == true )
			self.javelin_smartTargeting = true;
		else
		{
			assertEx( isdefined( self.javTargets ), "Not Targets are Defined" );
			self.javelin_smartTargeting = false;
		}
	}
		
	if( isAlive( self ) )
	{
		javelin = spawn( "script_model", self.origin );
		javelin setmodel( "weapon_javelin" );
		javelin linkto( self, "tag_inhand", ( 0,0,0 ), ( 0,0,0 ) );
		self.javelin = javelin;
	}
	
	while( 1 )
	{
		
		if( isAlive( self ) )
		{
			self drone_play_anim( getGenericAnim( "javelin_idle" ) );
			self thread drone_play_anim( getGenericAnim( "javelin_fire" ) );
		}
		else	
			wait( randomfloatrange( minT, maxT ) );
		
		if( self.javelin_smartTargeting == true )
		{
			level.javelinTargets = array_removeDead( level.javelinTargets );
			level.javelinTargets = array_removeUndefined( level.javelinTargets );
			targets = array_combine( self.javTargets, level.javelinTargets );
			//targets = level.javelinTargets;
		}
		
		if( level.javelinTargets.size > 0 )
			target = level.javelinTargets[ randomint( level.javelinTargets.size ) ];
		else
		{
			if( self.javTargets.size == 0 )
				return;
			
			self.javTargets = array_removeUndefined( self.javTargets );
			target = self.javTargets[ randomint( self.javTargets.size ) ];
		}
		
		self fire_fake_javelin( target, explosionFX, wep );
	}
}

drone_javelin_smart_targeting()
{
	
}

DEATH_DELETE_FOV = 0.5; // cos(60)
drone_death_handler( deathanim )
{
	if ( !IsDefined( level.drone_bodies ) )
		level.drone_bodies = 0;
		
	level.drone_bodies++;
	
	self maps\_drone::drone_play_scripted_anim( deathanim, "deathplant" );
	
	if( !isdefined( self.noragdoll ) )
		self startragdoll();;
	
	self notsolid();
	
	self thread maps\_drone::drone_thermal_draw_disable( 2 );
	
	if( isdefined( self ) && isdefined( self.nocorpsedelete ) )
		return;
	
	wait 1;
	while( isdefined( self ) )
	{
		wait( 2 );
		if ( drone_should_delete() )
			self delete();
	}
	
	level.drone_bodies--;
}

drone_should_delete()
{
	if( DistanceSquared( level.player.origin, self.origin ) > 1000000 )
		return true;
	if ( !within_fov( level.player.origin, level.player.angles, self.origin, DEATH_DELETE_FOV ) )
		return true;
	if( level.drone_bodies > 5 )
		return true;
	return false;
}

drone_die()
{
	if( !isdefined( self.dronebloodFX ) )
	{
		self die();
		return;
	}
	
	tags = [ "j_shoulder_ri", "j_shoulder_le", "j_head" ];
	tag = tags[ randomint( tags.size ) ];
	self dodamage( 99999, self gettagorigin( tag ) );
}

drone_bloodFX( playerOnly )
{
	self.dronebloodFX = true;
	
	if( !isdefined( playerOnly ) )
		playerOnly = false;
	
	while( isdefined( self ) && isalive( self ) )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		
		if( playerOnly )
		{
			if( attacker != level.player )
				continue;
		}
		
		playfx( getfx( "drone_blood_impact" ), point );
	}
}

set_noragdoll()
{
	self.noragdoll = true;
}

drone_EnableAimAssist()
{
	self EnableAimAssist();
}

give_drone_deathAnim()
{
	array = [ %stand_death_tumbleback, %stand_death_headshot_slowfall, %stand_death_shoulderback ];
	self.deathAnim = array[ randomint( array.size ) ];
}