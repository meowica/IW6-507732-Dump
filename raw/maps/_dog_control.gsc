#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

#using_animtree( "dog" );

init_dog_control()
{
	CreateThreatBiasGroup( "dog" );
	CreateThreatBiasGroup( "dog_targets" );
	SetIgnoreMeGroup( "dog_targets", "allies" );
	
		level._effect[ "target_marker_yellow" ] 			 = loadfx( "fx/misc/ui_pickup_available" );
	level._effect[ "target_marker_red" ] 				 = loadfx( "fx/misc/ui_pickup_unavailable" );
	
	level.scr_anim[ "dog" ][ "dog_bark" ]	= %iw6_dog_attackidle_bark;
	
	maps\_dog_pip::pip_init();
	flag_init( "enable_dog_pip" );
}

enable_dog_control( dog )
{
	dog.animname = "dog";

	if ( !dog ent_flag_exist( "running_dog_command" ) )
		dog ent_flag_init( "running_dog_command" );

	if ( !dog ent_flag_exist( "pause_dog_command" ) )
		dog ent_flag_init( "pause_dog_command" );
	
	self.controlled_dog = dog;
	self childthread give_laser();
	self childthread listen_for_dog_commands( dog );
	
	self DisableOffhandWeapons();
	
	self.controlled_dog.dog_marker = spawn_tag_origin();
}

disable_dog_control()
{
	self notify( "disable_dog_control" );
	self.controlled_dog = undefined;
	self.controlled_dog.dog_marker delete();
	
	self EnableOffhandWeapons();
}

listen_for_dog_commands( dog )
{
	self endon( "death" );
	dog endon( "death" );
	
	self endon( "disable_dog_control" );
	
	while( 1 )
	{
		self waittill( "issue_dog_command", trace, player, enemy );
		
		if ( dog ent_flag( "pause_dog_command" ) )
		{
			continue;
		}
		
		if ( self isNearGrenade() )
			continue;
			
		if ( isdefined( dog.animnode ) )
		{
			dog StopAnimScripted();
			dog.animnode notify( "stop_loop" );
		}
		dog thread run_dog_command( trace, player, enemy );
	}
}

isNearGrenade()
{
	return false; // should figure out if a grenade is near the player
}

give_laser()
{	
	level.see_enemy_dot = 0.985;
	level.see_enemy_dot_close = 0.99;
	
	self endon( "disable_dog_control" );
	self endon( "remove_laser" );
	
	self.lastUsedWeapon = undefined;
	self.laserForceOn = false;
	
//	self notifyOnPlayerCommand( "use_laser", "+actionslot 4" );
//	self notifyOnPlayerCommand( "fired_laser", "+attack" );

//	self notifyOnPlayerCommand( "use_laser", "+frag" );
	self notifyOnPlayerCommand( "fired_laser", "+frag" );
	self notifyOnPlayerCommand( "cancel_command", "+smoke" );
	
	self childthread laser_designate_target();
	self childthread laser_on_target();
	self childthread listen_for_cancel();
	/*
	for ( ;; )
	{
		self waittill( "use_laser" );
		
		if ( self.laserForceOn )
		{
			self notify( "cancel_laser" );
			self laserForceOff();
			self.laserForceOn = false;
			wait 0.2;
			self allowFire( true );
		}
		else
		{
			self laserForceOn();
			self allowFire( false );
			self.laserForceOn = true;		
			self thread laser_designate_target();
		}
		
		wait 0.05;
	} 
	*/
}

laser_on_target()
{
//	while( 1 )
//	{
//		self waittill( "use_laser" );
//		self laserForceOn();
		self.laserForceOn = true;		
//	}
}

laser_designate_target()
{
//	self endon( "cancel_laser" );
	
	while( 1 )
	{
		self waittill( "fired_laser" );
	
		trace = self get_laser_designated_trace();
		enemy = undefined;
		enemies = getaiarray( "axis" );
		close_enemies = [];
		player = self;
		end = player Get_Eye();
		
		old_dot = level.see_enemy_dot_close;
		foreach ( e in enemies )
		{
			if ( e.type == "dog" )
				continue;
			
			start = e GetTagOrigin( "J_SpineUpper" );
			angles = VectorToAngles( start - end );
			forward = AnglesToForward( angles );
			player_angles = player GetPlayerAngles();
			player_forward = AnglesToForward( player_angles );
		
			new_dot = VectorDot( forward, player_forward );
			if ( new_dot > old_dot )
			{
				close_enemies = array_Add( close_enemies, e );
			}
		}
		
		if ( close_enemies.size > 0 )
		{
			close_enemies = sortByDistance( close_enemies, end );
			foreach ( e in close_enemies )
			{
				if ( test_trace( e getEye() , end , player.controlled_dog ) )
				{
					enemy = e;
					break;
				}
			}
		}
		
		if ( !isdefined( enemy ) )
		{
			old_dot = level.see_enemy_dot;
			
			foreach ( e in enemies )
			{
				if ( e.type == "dog" )
					continue;
			
				start = e GetTagOrigin( "J_SpineUpper" );
				angles = VectorToAngles( start - end );
				forward = AnglesToForward( angles );
				player_angles = player GetPlayerAngles();
				player_forward = AnglesToForward( player_angles );
			
				new_dot = VectorDot( forward, player_forward );
				if ( new_dot > old_dot && test_trace( e getEye() , end , player.controlled_dog ) )
				{
					enemy = e;
					old_dot = new_dot;
				}
			}
		}
		
		self notify( "issue_dog_command", trace, undefined, enemy );
	
		self laserForceOff();
		self.laserForceOn = false;
	}
}

test_trace( start, end, ignore_ent )
{
	trace = BulletTrace( start, end, false, ignore_ent );
	return trace[ "fraction" ] == 1;
}

listen_for_cancel()
{
	while( 1 )
	{
		self waittill( "cancel_command" );
		trace = self get_laser_designated_trace();
		self notify( "issue_dog_command", trace, self );
		wait( 0.1 );
	}
}

get_laser_designated_trace()
{
	eye = self Get_Eye();
	angles = self getplayerangles();
	
	forward = anglestoforward( angles );
	eye = eye + ( forward * 20 );
	end = eye + ( forward * 7000 );
	trace = bullettrace( eye, end, true, self.controlled_dog );
	
	//thread draw_line_for_time( eye, end, 1, 1, 1, 10 );
	//thread draw_line_for_time( eye, trace[ "position" ], 1, 0, 0, 10 );
	
	entity = trace[ "entity" ];
	if ( isdefined( entity ) )
		trace[ "position" ] = entity.origin;
	
	return trace;
}

// self = dog;
run_dog_command( trace, player, enemy )
{
	if ( trace[ "fraction" ] >= 0.98 && !isdefined( player ) )
		return;

	org = trace[ "position" ];
	
	if ( isdefined( enemy ) )
		ai = enemy;
	else
		ai = enemy_near_position( trace[ "position" ] );	
	
	vol = get_flush_volume( org );
	
	if ( !isdefined( enemy ) && !isdefined( player ) && !isdefined( vol ) )
		return;
	
	self notify( "new_dog_command" );
	
//	StopFXOnTag( getfx( "target_marker_red" ), self.dog_marker, "tag_origin" );
//	StopFXOnTag( getfx( "target_marker_yellow" ), self.dog_marker, "tag_origin" );
	wait( 0.05 );
	
	self endon( "new_dog_command" );
	
	self ent_flag_set( "running_dog_command" );
	
	on_color_system = ( isdefined( self.script_forcecolor ) || isdefined( self.script_old_forcecolor ) );
	if ( on_color_system && isdefined( self.script_forcecolor ) )
	{
		self.script_old_forcecolor = self.script_forcecolor;
	}
	
	if ( isdefined( self.current_follow_path ) )
	{
		self.old_path = self.current_follow_path;
		self notify( "stop_path" );
	}
	
	self disable_ai_color();
	
	self.dog_marker unlink();
	self.dog_marker.origin = org;
	self.dog_marker.angles = VectorToAngles( trace[ "normal" ] );

	if ( !isdefined( self.dc_old_moveplaybackrate ) )
		self.dc_old_moveplaybackrate = self.moveplaybackrate;
	self.moveplaybackrate = 1;

	if ( self.a.movement == "walk" )
	{
		self.was_walking = true;
		self clear_run_anim();
	}
	
	if ( !level.pip.enable && flag( "enable_dog_pip" ) )
		thread maps\_dog_pip::dog_pip_init( self, 110 );
	
	if ( isdefined( player ) )
	{
		self play_sound_on_entity( "minefield_click" );
		dog_command_cancel( player );
	}
	else if ( isdefined( vol ) )
	{
		dog_command_flush( vol, trace );
	}
	else if ( isdefined( ai ) )
    {
		self.moveplaybackrate = 1.15; // should tell the dog to sprint instead
		dog_command_attack( ai );
//		StopFXOnTag( getfx( "target_marker_yellow" ), self.dog_marker, "tag_origin" );
//		StopFXOnTag( getfx( "target_marker_red" ), self.dog_marker, "tag_origin" );
		if ( isAlive( ai ) )
		{
			if ( isdefined( ai.syncedmeleetarget ) &&  ai.syncedmeleetarget == self )
				ai waittill( "death" );
		}
    }
	else
	{
		dog_command_goto( trace );
	}

//	StopFXOnTag( getfx( "target_marker_yellow" ), self.dog_marker, "tag_origin" );
//	StopFXOnTag( getfx( "target_marker_red" ), self.dog_marker, "tag_origin" );
	
	// cleanup
	if ( on_color_system && isdefined( self.script_old_forcecolor ) )
	{
		self enable_ai_color();
		self.script_old_forcecolor = undefined;
		self.old_path = undefined;
	} 
	else if ( isdefined( self.old_path ) )
	{
		self thread follow_path_and_animate( self.old_path );
		self.old_path = undefined;
	}
	
	if ( isdefined( self.dc_old_moveplaybackrate ) )
	{
		self waittill_notify_or_timeout( "goal", 5 );
		self.moveplaybackrate = self.dc_old_moveplaybackrate;
		self.dc_old_moveplaybackrate = undefined;
	}
	
	if ( isdefined( self.was_walking ) && self.was_walking )
	{
		self.was_walking = undefined;
		self set_dog_walk_anim();
	}
	
	if ( level.pip.enable )
		thread maps\_dog_pip::dog_pip_close();
	
	self ent_flag_clear( "running_dog_command" );
	
	self notify( "dog_command_complete" );
}

dog_command_flush( vol, trace )
{
	self endon( "new_dog_command" );
	org = trace[ "position" ];
	wait( 0.05 );
	PlayFXOnTag( getfx( "target_marker_yellow" ), self.dog_marker, "tag_origin" );
	self thread play_sound_on_entity( "anml_dog_bark" );
	func = level.dog_flush_functions[ vol.script_noteworthy ];
	self childthread [[ func ]]( vol, trace );
	level waittill( "dog_flush_started" );
	vol.done_flushing = true;
	level waittill( "dog_flush_done" );
}

dog_command_cancel( player )
{
//	StopFXOnTag( getfx( "target_marker_yellow" ), self.dog_marker, "tag_origin" );
//	StopFXOnTag( getfx( "target_marker_red" ), self.dog_marker, "tag_origin" );
	
	if ( isdefined( self.favoriteenemy ) )
	{
		if ( isdefined( self.favoriteenemy.oldignoreme ) )
			self.favoriteenemy.ignoreme = self.favoriteenemy.oldignoreme;
		self.favoriteenemy = undefined;
	}
	
	self.goalradius = 96;
	self setGoalentity( player );
	while( Distance2d( self.origin, player.origin ) > Max( self.goalradius, 196 ) )
	{
		wait( 0.1 );
	}
	self setGoalPos( self.origin );
	wait( 0.5 );
	node = Spawnstruct();
	node.origin = self.origin;
	node.angles = VectorToAngles( player.origin - self.origin );
	node anim_single_solo( self, "dog_bark" );
	wait( 1 );
	if ( isdefined( self.old_moveplaybackrate ) )
	{
		self.moveplaybackrate = self.old_moveplaybackrate;
		self.old_moveplaybackrate = undefined;
	}
}

dog_command_attack( ai )
{
	self endon( "damage" );
	self notify( "dog_command_attack", ai );
	self.dog_marker linkTo( ai, "tag_origin", (0,0,0), (-90,0,-90) );
	wait( 0.05 );
//	PlayFXOnTag( getfx( "target_marker_red" ), self.dog_marker, "tag_origin" );
	ai thread hud_outlineEnable();
	
	ai.old_ignoreme = ai.ignoreme;
	ai.ignoreme = false;
	ai setThreatBiasGroup( "dog_targets" );
	ai set_battlechatter( false );
	self.favoriteenemy = ai;
	self thread play_sound_on_entity( "anml_dog_bark" );
	
	self setGoalEntity( ai, 50 );
	//self setGoalPos( ai.origin );
	ai waittill_either( "dog_attacks_ai", "death" );
}

ai_remove_outline_waiter( dog )
{
	self endon( "death" );
	self endon( "dog_attacks_ai" );
	dog waittill( "new_dog_command" );
	self HudOutlineDisable();
}

dog_command_goto( trace )
{
	org = trace[ "position" ];
	wait( 0.05 );
	PlayFXOnTag( getfx( "target_marker_yellow" ), self.dog_marker, "tag_origin" );

	self thread play_sound_on_entity( "anml_dog_bark" );
	self setGoalPos( org );
	self waittill_notify_or_timeout( "goal", 0.2 );
	if ( isdefined( self.pathgoalpos ) )
	{
		self waittill( "goal" );
	}
	else if ( Distance2d( self.origin, org ) > self.goalradius )
	{
		nodes = GetNodesInRadius( org, 96, 0, 96 );
		nodes = SortByDistance( nodes, level.player get_eye() );
		if ( nodes.size > 0 )
		{
			node = nodes[0];
			self setGoalPos( node.origin );
			self waittill( "goal" );
		}
	}
	wait( RandomFloatRange( 1,3 ) );
}

enemy_near_position( org )
{
	ai = getAIArray( "axis" );
	if ( ai.size > 0 )
	{
		ai = SortByDistance( ai, org );
		if ( Distance( ai[0].origin, org ) < 128 )
			return ai[0];
	}
	return undefined;	
}

get_flush_volume( org )
{
	tag = spawn_tag_origin();
	tag.origin = org;
	
	volumes = getentarray( "dog_flush_volume", "targetname" );
	foreach ( v in volumes )
	{
		if ( isdefined( v.script_noteworthy ) && (!isdefined( v.done_flushing ) || v.done_flushing == false ) )
		{
			if ( tag isTouching( v ) )
			{
				tag delete();
				return v;
			}
		}
	}
	
	tag delete();
	return undefined;
}

/* * * * * * * * * * * * * * * * * * *
 * --------------------------------- *
 * 		DIFFERENT POINTING STYLE 	 *
 * --------------------------------- *
 * * * * * * * * * * * * * * * * * * */
 
 chopper_air_support_activate()
{
	level endon( "air_support_canceled" );
	level endon( "air_support_called" );

	// Make the arrow
	level.chopperAttackArrow = spawn( "script_model", ( 0, 0, 0 ) );
	level.chopperAttackArrow setModel( "tag_origin" );
	level.chopperAttackArrow.angles = ( -90, 0, 0 );
	level.chopperAttackArrow.offset = 4;

//	playfxontag( getfx( "target_marker_red" ), level.chopperAttackArrow, "tag_origin" );

	level.playerActivatedAirSupport = true;

	coord = undefined;

	traceOffset = 15;
	traceLength = 15000;
	minValidLength = 300 * 300;

	trace = [];

	trace[ 0 ] = spawnStruct();
	trace[ 0 ].offsetDir = "vertical";
	trace[ 0 ].offsetDist = traceOffset;

	trace[ 1 ] = spawnStruct();
	trace[ 1 ].offsetDir = "vertical";
	trace[ 1 ].offsetDist = traceOffset * - 1;

	trace[ 2 ] = spawnStruct();
	trace[ 2 ].offsetDir = "horizontal";
	trace[ 2 ].offsetDist = traceOffset;

	trace[ 3 ] = spawnStruct();
	trace[ 3 ].offsetDir = "horizontal";
	trace[ 3 ].offsetDist = traceOffset * - 1;

	rotateTime = 0;

	for ( ;; )
	{
		wait 0.05;

		prof_begin( "spotting_marker" );

		// Trace to where the player is looking
		direction = level.player getPlayerAngles();
		direction_vec = anglesToForward( direction );
		eye = level.player Get_Eye();

		for ( i = 0 ; i < trace.size ; i++ )
		{
			start = eye;
			vec = undefined;
			if ( trace[ i ].offsetDir == "vertical" )
				vec = anglesToUp( direction );
			else if ( trace[ i ].offsetDir == "horizontal" )
				vec = anglesToRight( direction );
			assert( isdefined( vec ) );
			start = start + ( vec * trace[ i ].offsetDist );
			trace[ i ].trace = bullettrace( start, start + ( direction_vec * traceLength ), 0, undefined );
			trace[ i ].length = distanceSquared( start, trace[ i ].trace[ "position" ] );

			if ( getdvar( "village_assault_debug_marker" ) == "1" )
				thread draw_line_for_time( start, trace[ i ].trace[ "position" ], 1, 1, 1, 0.05 );
		}

		validLocations = [];
		validNormals = [];
		for ( i = 0 ; i < trace.size ; i++ )
		{
			if ( trace[ i ].length < minValidLength )
				continue;
			index = validLocations.size;
			validLocations[ index ] = trace[ i ].trace[ "position" ];
			validNormals[ index ] = trace[ i ].trace[ "normal" ];

			if ( getdvar( "village_assault_debug_marker" ) == "1" )
				thread draw_line_for_time( level.player Get_Eye(), validLocations[ index ], 0, 1, 0, 0.05 );
		}

		// if all points are too close just use all of them since none are good
		if ( validLocations.size == 0 )
		{
			for ( i = 0 ; i < trace.size ; i++ )
			{
				validLocations[ i ] = trace[ i ].trace[ "position" ];
				validNormals[ i ] = trace[ i ].trace[ "normal" ];
			}
		}

		assert( validLocations.size > 0 );

		if ( validLocations.size == 4 )
		{
			fxLocation = findAveragePointVec( validLocations[ 0 ], validLocations[ 1 ], validLocations[ 2 ], validLocations[ 3 ] );
			fxNormal = findAveragePointVec( validNormals[ 0 ], validNormals[ 1 ], validNormals[ 2 ], validNormals[ 3 ] );
		}
		else if ( validLocations.size == 3 )
		{
			fxLocation = findAveragePointVec( validLocations[ 0 ], validLocations[ 1 ], validLocations[ 2 ] );
			fxNormal = findAveragePointVec( validNormals[ 0 ], validNormals[ 1 ], validNormals[ 2 ] );
		}
		else if ( validLocations.size == 2 )
		{
			fxLocation = findAveragePointVec( validLocations[ 0 ], validLocations[ 1 ] );
			fxNormal = findAveragePointVec( validNormals[ 0 ], validNormals[ 1 ] );
		}
		else
		{
			fxLocation = validLocations[ 0 ];
			fxNormal = validNormals[ 0 ];
		}

		if ( getdvar( "village_assault_debug_marker" ) == "1" )
			thread draw_line_for_time( level.player Get_Eye(), fxLocation, 1, 0, 0, 0.05 );

		thread drawChopperAttackArrow( fxLocation, fxNormal, rotateTime );

		rotateTime = 0.2;

		prof_end( "spotting_marker" );
	}
}

findAveragePointVec( point1, point2, point3, point4 )
{
	assert( isdefined( point1 ) );
	assert( isdefined( point2 ) );

	if ( isdefined( point4 ) )
	{
		x = findAveragePoint( point1[ 0 ], point2[ 0 ], point3[ 0 ], point4[ 0 ] );
		y = findAveragePoint( point1[ 1 ], point2[ 1 ], point3[ 1 ], point4[ 1 ] );
		z = findAveragePoint( point1[ 2 ], point2[ 2 ], point3[ 2 ], point4[ 2 ] );
	}
	else if ( isdefined( point3 ) )
	{
		x = findAveragePoint( point1[ 0 ], point2[ 0 ], point3[ 0 ] );
		y = findAveragePoint( point1[ 1 ], point2[ 1 ], point3[ 1 ] );
		z = findAveragePoint( point1[ 2 ], point2[ 2 ], point3[ 2 ] );
	}
	else
	{
		x = findAveragePoint( point1[ 0 ], point2[ 0 ] );
		y = findAveragePoint( point1[ 1 ], point2[ 1 ] );
		z = findAveragePoint( point1[ 2 ], point2[ 2 ] );
	}
	return( x, y, z );
}

findAveragePoint( point1, point2, point3, point4 )
{
	assert( isdefined( point1 ) );
	assert( isdefined( point2 ) );

	if ( isdefined( point4 ) )
		return( ( point1 + point2 + point3 + point4 ) / 4 );
	else if ( isdefined( point3 ) )
		return( ( point1 + point2 + point3 ) / 3 );
	else
		return( ( point1 + point2 ) / 2 );
}

drawChopperAttackArrow( coord, normal, rotateTime )
{
	assert( isdefined( level.chopperAttackArrow ) );
	assert( isdefined( coord ) );
	assert( isdefined( normal ) );
	assert( isdefined( rotateTime ) );

	coord += ( normal * level.chopperAttackArrow.offset );
	level.chopperAttackArrow.origin = coord;

	if ( rotateTime > 0 )
		level.chopperAttackArrow rotateTo( vectortoangles( normal ), 0.2 );
	else
		level.chopperAttackArrow.angles = vectortoangles( normal );
}

Get_Eye()
{
	if ( isdefined( self.controlled_dog.controlling_dog ) && self.controlled_dog.controlling_dog )
	{
		org = self.controlled_dog GetTagOrigin( "TAG_CAMERA" );
		return org;
	}
	else
		return self GetEye();
}

hud_outlineEnable()
{
	self HudOutlineEnable( 1 );
	self waittill_either( "death", "dog_attacks_ai" );
	if ( IsDefined( self ) )
	{
		self.no_more_outlines = true;
		self HudOutlineDisable();
	}
}