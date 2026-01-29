#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\homecoming_drones;

#using_animtree( "generic_human" );

// MISC UTIL STUFF

// Dog first moves with handler using "SetDogHandler" function
// Then when handler gets close enough to his goal and can see his goal
// he will send the dog there. This changes the dogs move animation from trotting
// to running.
SEND_DOG_TO_GOAL_DIST = 250;
heroes_move( key )
{
	level notify( "hero_move" );
	level endon( "hero_move" );
	
	self thread move_to_goal( key );
	
//	wait( 1 );
//	
//	level.dog SetDogHandler( level.hesh );
//	level.dog setgoalentity( level.hesh );
//	
//	nodes = getnodearray( key, "targetname" );
//	heshNode = undefined;
//	dogNode = undefined;
//	foreach( node in nodes )
//	{
//		if( !isdefined( node.script_noteworthy ) )
//			continue;
//		
//		if( node.script_noteworthy == "hesh" )
//		{
//			heshNode = node;
//			continue;;
//		}
//		else if( node.script_noteworthy == "dog" )
//			dogNode = node;
//	}
//	
//	while( 1 )
//	{
//		wait( .1 );
//		
//		if( distance2d( heshNode.origin, level.hesh.origin ) > SEND_DOG_TO_GOAL_DIST )
//			continue;
//		break;
//	}

//	if( isdefined( dogNode ) )
//	{
//		level.dog SetDogHandler( undefined );
//		level.dog move_to_goal( key );
//	}
}

move_to_goal( key, value, type )
{
	AssertEx( isdefined( key ), "key must be defined" );

	if( !isdefined( value ) )
		value = "targetname";
	
	if( !isdefined( type ) )
		type = "node";
	
	goals = undefined;
	moveFunc = undefined;
	switch( type )
	{
		case "node" : 
			goals = getnodearray( key, value );
			moveFunc = ::set_goal_node;
			break;
		case "struct" : 
			goals = getstructarray( key, value );
			moveFunc = ::set_goal_pos_think;
			break;
		case "ent" : 
			goals = getentarray( key, value );
			moveFunc = ::set_goal_ent;
			break;
	}
	
	AssertEx( isdefined( goals ), "goals not defined: type OR key could be bad" );
	
	dudes = [];
	if( !isarray( self ) )
		dudes[ 0 ] = self;
	else
		dudes = self;
	
	foreach( guy in dudes )
	{
		AssertEx( isdefined( guy.script_noteworthy ), "script_noteworthy must be defined" );
		
		goal = undefined;
		foreach( thing in goals )
		{
			if( thing.script_noteworthy == guy.script_noteworthy )
			{
				goal = thing;		
				break;	
			}
		}
		
		AssertEx( isdefined( goal ), "actor has no goal" );
		
		guy thread move_to_goal_think( moveFunc, goal );
		
	}
}

move_to_goal_think( moveFunc, goal )
{
	self notify( "new_move_path" );
	self endon( "new_move_path" );
	
	while( isdefined( goal ) )
	{
		goal script_delay();
		
		if( self.type == "dog" )
			self Dog_AttackRadius_Check( goal );
		
		self childthread [[ moveFunc ]]( goal );
		
		if( isdefined( goal.radius ) && goal.radius != 0 )
			self.goalradius = goal.radius;
		if ( self.goalradius < 16 )
			self.goalradius = 16;
		if ( IsDefined( goal.height ) && goal.height != 0 )
			self.goalheight = goal.height;
		
		current_goalradius = self.goalradius;
		
		// make sure the "goal" is acutally the goal we set 
		while( 1 )
		{
			self waittill( "goal" );
			if( Distance( goal.origin, self.origin ) < current_goalradius + 10 )
				break;
		}
		
		if( isdefined( goal.script_parameters ) )
		{
			strings = strtok( goal.script_parameters, " " );
			{
				foreach( part in strings )
				{
					if( self.type == "dog" )
					{
					}
					else
					{
						
					}
				}
			}
		}
		
		if( !isdefined( goal.target ) )
			break;
		
		goal = goal get_target_ent();
	}
}

set_goal_pos_think( goal )
{
	self childthread set_goal_pos( goal.origin );
}

Dog_AttackRadius_Check( goal )
{
	if( isdefined( goal.script_parameters ) )
	{
		strings = strtok( goal.script_parameters, " " );
		foreach( word in strings )
		{
			if( word == "attack_radius" )
			{
				assert( isdefined( goal.radius ) );
				self.DogAttackRadius = goal.radius;
				self SetDogAttackRadius( goal.radius );
			}
		}
	}
}

move_up_when_clear()
{
	volume = self get_target_ent();
	trigger = volume get_target_ent();
	
	trigger endon( "trigger" );
	
	self waittill( "trigger" );
	
	volume_waittill_no_axis( volume.targetname, volume.script_count );
	
	trigger thread activate_trigger();
}

volume_waittill_no_axis( targetname, tolerance )
{
	volume = get_target_ent( targetname );
	
	while ( 1 )
	{
		if ( volume_is_empty( volume, tolerance ) )
			break;
		wait ( 0.2 );
	}	
}

volume_is_empty( volume, tolerance )
{
	if ( !isdefined( tolerance ) )
		tolerance = 0;
	
	enemies = GetAIArray( "axis" );
	num = 0;
	
	ignoreDying = false;
	if( volume parameters_check( "ignore_dying" ) )
		ignoreDying = true;
	
	foreach ( e in enemies )
	{
		if ( e IsTouching( volume ) )
		{
			// WON'T COUNT AS ALIVE IF IN LONG DEATH
			if( ignoreDying == true )
			{
				if( e doingLongDeath() )
					continue;
			}
			
			num += 1;
			if ( num > tolerance )
				return false;
		}
	}
	
	return true;
}

alliesTeletoStartSpot( name )
{
	spotarray = getstructarray( name, "targetname" );
	
	foreach( spot in spotarray )
	{
		if( spot.script_noteworthy == "player" )
			level.player teletospot( spot );
		else
		{
			foreach( ai in level.heroes )
			{
				if( spot.script_noteworthy == ai.script_noteworthy )
					ai teletospot( spot );
			}
		}
	}
}

TeletoSpot( spot )
{
	if( IsPlayer( self ) )
	{
		self SetOrigin( spot.origin );
		self SetPlayerAngles( spot.angles );
	}
	else
		self forceteleport( spot.origin, spot.angles );
}

waittill_trigger( trigger, func, ender )
{
	if( isdefined( ender ) )
		level endon( "ender" );

	if( isString( trigger ) )
		trigger = getent( trigger, "targetname" );
	
	trigger waittill( "trigger" );

	if( isdefined( func ) )
		self thread [[ func ]]();
}

func_waittill_msg( thing, msg, func, param1, param2 )
{
	thing endon( "death" );
	
	thing waittill( msg );

	if( isdefined( param1 ) )
		thing thread [[ func ]]( param1 );
	else if( isdefined( param2 ) )
		param2 thread [[ func ]]( param1 );
	else
		thing thread [[ func ]]( );
}

notify_trigger( trigger )
{
	if( isString( trigger ) )
		trigger = getent( trigger, "targetname" );

	trigger notify( "trigger" );
}

smoke_trigger()
{
	structs = self get_linked_structs();
	smokeStructs = [];
	foreach( struct in structs )
	{
		if( struct parameters_check( "smoke" ) )
			smokeStructs[ smokeStructs.size ] = struct;
	}
	
	self waittill( "trigger" );

	foreach( struct in smokeStructs )
	{
		
		timeOut = 5;
		
		if( struct parameters_check( "infinite" ) )
			timeOut = undefined;
		
		if( isdefined( struct.script_timeout ) )
		{
			AssertEx( isdefined( timeOut ), "Infinite and script_timeout is set" );
			timeOut = struct.script_timeout;
		}
		
		struct thread playLoopingFX( "smoke_grenade", 5.5, timeOut );
	}

}

smoke_stop_trigger()
{
	structs = self get_linked_structs();
	smokeStructs = [];
	foreach( struct in structs )
	{
		if( struct parameters_check( "smoke" ) )
			smokeStructs[ smokeStructs.size ] = struct;
	}
	
	self waittill( "trigger" );
	
	array_notify( smokeStructs, "stop_looping_fx" );
}

get_target_chain_array( nextspot )
{
	assertex( isdefined( nextspot ), "nextspot is not defined" );
	
	array = [];
	
	while( isdefined( nextspot ) )
	{
		array[ array.size ] = nextspot;
		
		if( !isdefined( nextspot.target ) )
			break;
	
		nextspot = getent_or_struct_or_node( nextspot.target, "targetname" );
		
		wait(.05);
	}
	
	return array;
}

playLoopingFX( fx, fxDelay, timeOut, tag )
{
	self endon( "stop_looping_fx" );
	self endon( "death" );
	
	if( !isdefined( fxDelay ) )
		fxDelay = .05;
	
	startTime = undefined;
	if( isdefined( timeOut ) )
	   startTime = gettime();
	
	while( isdefined( self ) )
	{
		if( isdefined( timeOut ) )
		{
			if( gettime() - startTime >= timeOut )
				break;
		}
		
		origin = self.origin;
		fwd = undefined;
		if( isdefined( tag ) )
		{
			origin = self gettagorigin( tag );
			fwd = anglestoforward( self gettagangles( tag ) );
		}
		
		if( isdefined( fwd ) )
			PlayFX( getfx( fx ), origin + ( 0,0,0 ), fwd );
		else
			PlayFX( getfx( fx ), origin + ( 0,0,0 ) );
		wait( fxDelay );
	}	
}

postion_dot_check( cspot, mspot )
{
	// cspot = spot we are checking if mspot is infront or behind
	
	fwdangles = anglestoforward( cspot.angles );
	othervec = VectorNormalize( cspot.origin - mspot.origin );

	dot = VectorDot( fwdangles, othervec );
		
	if( dot > 0  )
		return "behind";
	else
		return "infront";

}

noteworthy_check( sCheck, tok )
{
	if( !isdefined( self.script_noteworthy ) )
		return false;
	
	if( !isdefined( tok ) )
		tok = " ";
	
	strings = strTok( self.script_noteworthy, tok );
	foreach( param in strings )
	{
		if( param == sCheck )
			return true;
	}
	
	return false;
}

parameters_check( sCheck, tok )
{
	if( !isdefined( self.script_parameters ) )
		return false;
	
	if( !isdefined( tok ) )
		tok = " ";
	
	strings = strTok( self.script_parameters, tok );
	foreach( param in strings )
	{
		if( param == sCheck )
			return true;
	}
	
	return false;
}

get_midpoint( points, findZ )
{
	x = 0;
	y = 0;
	z = 0;
	for( i=0; i<points.size; i++ )
	{
		x = x + points[i][0];
		y = y + points[i][1];
		if( isdefined( findZ ) )
			z = z + points[i][2];
	}
	
	if( isdefined( findZ ) )
		z = z/points.size;
	return( x/points.size, y/points.size, z );
}

// For default accuracy I can get the 2D distance between the two points and then have a point
// for every so many units
calculate_bezier_curve( startOrigin, endOrigin, midPoint, accuracy )
{
	startX = startOrigin[ 0 ];
	startY = startOrigin[ 1 ];
	startZ = startOrigin[ 2 ];
	
	endX = startOrigin[ 0 ];
	endY = startOrigin[ 1 ];
	endZ = startOrigin[ 2 ];	
	
	// This is for a perfect curve
	if( !isdefined( midPoint ) )
	{
		points = [ startOrigin, endOrigin ];
		midPoint = get_midpoint( points, true );
	}
	midX = midPoint[ 0 ];
	midY = midPoint[ 1 ];
	midZ = midPoint[ 2 ];		
	
	curveArray = [];
	for( i=0; i<accuracy; i++ )
	{
		x = int( (  (1-i)*(1-i)*startX + 2*(1-i)*i*midX+i*i*endX) );
		y = int( (  (1-i)*(1-i)*startY + 2*(1-i)*i*midY+i*i*endY) );
		z = int( (  (1-i)*(1-i)*startZ + 2*(1-i)*i*midZ+i*i*endZ) );
		
		curveArray[ i ] = ( x,y,z );
	}

	return curveArray;
}

getClosest2D( org, array, maxdist )
{
	if ( !IsDefined( maxdist ) )
		maxdist = 500000; // twice the size of the grid
	
	ent = undefined;
	foreach ( item in array )
	{
		newdist = Distance2DSquared( item.origin, org );
		if ( newdist >= squared( maxdist ) )
			continue;
		maxdist = newdist;
		ent = item;
	}
	return ent;
}

// returns a random point in a circle
return_point_in_circle( spot, radius, height )
{
	rSquared = squared( radius );
	
	// figures out random X and Y in a radius
	x = randomfloatrange( ( radius * -1 ), radius );
	y = randomfloatrange( -1,1 ) * sqrt( rSquared-X*X );
	z = 0;
	if( isdefined( height ) )
		z = randomfloatrange( ( height * -1 ), height );
	
	
	x = x + spot[0];
	y = y + spot[1];	
	z = z + spot[2];
	
	return( x, y, z );
}

array_remove_when_dead( array, ent )
{
	ent waittill( "death" );
	array_remove( array, ent );
}

isEntity( thing )
{
	return IsDefined( thing.classname );
}

cinematicmode_on( hud )
{
	level.player disableweapons();
	level.player AllowCrouch( false );
	level.player allowprone( false );
	level.player allowjump( false );
	level.player AllowSprint( false );
	
	if( isdefined( hud ) && hud == true )
		hud_hide();
}

cinematicmode_off( hud )
{
	level.player enableweapons();
	level.player AllowCrouch( true );
	level.player allowprone( true );
	level.player allowjump( true );
	level.player AllowSprint( true );

	if( isdefined( hud ) && hud == true )
		hud_show();	
}

hud_hide()
{
	setsavedDvar( "g_friendlyNameDist", 0 );
	SetSavedDvar( "compass", "0" );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
}

hud_show()
{
	setsavedDvar( "g_friendlyNameDist", 15000 );
	SetSavedDvar( "compass", "1" );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
}

waittill_forever()
{
	/#
		level waittill( "forever" );
	#/		
}

ambient_aa( name, fxName )
{
	if( !isdefined( fxName ) )
		fxName = "antiair_runner_flak_day";
	
	spots = getstructarray( name, "targetname" );
	foreach( spot in spots )
	{
		ent = spawn( "script_model", spot.origin );
		ent setmodel( "tag_origin" );
		ent.angles = ( 270, 0, 0 );
		ent.fxRef = getfx( fxName );
		
		PlayFXOnTag( ent.fxRef, ent, "tag_origin" );
		
		if( isdefined( spot.target ) )
			ent thread waittill_trigger( spot.target, ::ambient_aa_cleanup );
	}
}

set_mortar_on( group )
{
	flag_wait( "load_setup_complete" );

	triggers = getentarray( "mortar_on", "targetname" );
	foreach( trig in triggers )
	{
		if( isdefined( trig.script_mortargroup ) )
		{
			if( trig.script_mortargroup == string( group ) )
				trig notify( "trigger" );
		}
	}
}

ambient_aa_cleanup()
{
	stopfxontag( self.fxRef, self, "tag_origin" );
	waitframe();
	self delete();
}

fire_fake_javelin( target, explosionFX, wep )
{	
	if( !isdefined( wep ) )
		wep = "javelin_no_explode"; //javelin_no_explode
	if( !isdefined( explosionFX ) )
		explosionFx = getfx( "javelin_explosion_cheap" );
	
	start = undefined;
	if( isAlive( self ) )
	{
		start = self.javelin gettagorigin( "tag_flash" );
		playfxontag( getfx( "javelin_muzzle" ), self.javelin, "tag_flash" );
	}
	else
		start = self.origin;
	
	end = target.origin;
	missile = magicbullet( wep, start, end );
	
	smartTargeting = false;
	if( isEntity( target ) )
		smartTargeting = true;
	
	if( smartTargeting )
	{
		target notify( "javelin_targeted", missile );
		missile Missile_SetTargetEnt( target );
	}
	else
		missile Missile_SetTargetPos( end );
	missile Missile_SetFlightmodeTop();
	
	missile waittill( "death" );
	
	org = missile.origin;
	if( isdefined( org ) )
		playfx( explosionFX, org );
	
	
	if( isdefined( missile ) && IsValidMissile( missile ) )
		missile delete();

}

default_mg_guy()
{
	self thread magic_bullet_shield();

	turret = getent( self.target, "targetname" );
	self maps\_spawner::use_a_turret( turret );
	
	if( !isdefined( turret.script_linkTo ) )
		return;
	
	turret setmode( "manual_ai" );
	
	target = getent( turret.script_linkTo, "script_linkname" );
	turret TurretFireEnable(); 
	turret SetTargetEntity( target );
	
}

#using_animtree( "generic_human" );
wounded_carry_guy()
{	
	spawner = self.spawner;	
	drone = spawner spawnDrone();
	drone UseAnimTree( #animtree );
	self thread magic_bullet_shield();
	self.disablearrivals = true;
	self.disableexits = true;
	self.nododgemove = true;
	self pathrandompercent_set( 0 );
	self pushplayer( true );
	self ignore_everything();
	self set_generic_run_anim( "wounded_carry_carrier" );
	self thread anim_generic_loop( drone, "wounded_carry_wounded", "stop_anim", "tag_origin" );
	drone linkto( self, "tag_origin" );
	
	struct = getstruct( spawner.target, "targetname" );
	self ForceTeleport( struct.origin, struct.angles );
	while( 1 )
	{
		self.goalradius = 5;
		self setgoalpos( struct.origin );
		self waittill( "goal" );
		
		if( !isdefined( struct.target ) )
			break;
		struct = getstruct( struct.target, "targetname" );
	}
	
	putdownSpot = getstruct( struct.script_linkto, "script_linkname" );
	self.goalradius = 5;
	self setgoalpos( putdownSpot.origin );
	while ( distance( putdownSpot.origin, self.origin ) > 5 )
	{
		self.goalradius = 5;
		wait(.05 );
	}

	drone unlink();
	putdownSpot thread anim_generic( self, "wounded_carry_putdown_carrier" );
	
	self notify( "stop_anim" );
	drone StopAnimScripted();
	putdownSpot anim_generic( drone, "wounded_carry_putdown_wounded" );
	
	putdownSpot thread anim_generic_loop( self, "wounded_carry_idle_carrier" );
	putdownSpot thread anim_generic_loop( drone, "wounded_carry_idle_wounded" );
}

fake_shooter_think()
{
	self endon( "stop_fake_behavior" );
	self endon( "death" );
	
	self thread fake_shooter_death();
	
	spot = getstruct( self.target, "targetname" );
	self.animSpot = spot;
	
	animType = "coverstand";
	if( self parameters_check( "crouch" ) )
		animType = "covercrouch";
	
	idle = animType + "_hide_idle";
	reload = animType + "_reload"; 
	hide2aim = animType + "_hide_2_aim"; 
	aim = animType + "_aim";  
	aim2hide = animType + "_aim_2_hide";
	
	aimModifier = %exposed_aim_2;
	
	looping = false;
	while( 1 )
	{	
		if( !looping )
		{
			spot thread anim_generic_loop( self, idle );
			looping = true;
		}
		wait( randomintrange( 1, 3 ) );
		
		if( cointoss() )
		{
			spot notify( "stop_loop" );
			self StopAnimScripted();
			looping = false; 
			
			if( cointoss() )
				spot anim_generic( self, reload );
			
			spot anim_generic( self, hide2aim );	
			self thread fake_shooter_shoot();			
			self thread anim_generic_loop( self, aim );
			self setAnimKnobRestart( aimModifier, 1, .2, 1.0 );
			wait( randomintrange( 4, 8 ) );
			self notify( "stop_loop" );
			self notify( "stop_shooting" );
			self StopAnimScripted();
			self anim_generic( self, aim2hide );
		}
	}
}

fake_shooter_shoot()
{
	self endon( "stop_shooting" );
	self endon( "death" );
	
	while( 1 )
	{
		wait( randomfloatrange( .2, .6 ) );
		self ShootBlank();
	}
}

fake_shooter_death()
{
	self endon( "stop_fake_behavior" );
	
	self set_allowdeath( true );
	
	self waittill( "death" );
	
	self stopanimscripted();
	self.animSpot notify( "stop_loop" );
	self notify( "stop_loop" );

}

set_ai_array()
{
	assert( isdefined( self.script_parameters ) );
	stringSet = self.script_parameters;
	
	if( !isdefined( level.aiArray[ stringSet ] ) )
		level.aiArray[ stringSet ] = [];
	
	level.aiArray[ stringSet ] = array_add( level.aiArray[ stringSet ], self );
}

get_ai_array( stringGet )
{
	level.aiArray[ stringGet ] = array_removeDead( level.aiArray[ stringGet ] );
	return level.aiArray[ stringGet ];
}

// VISION SET UTILS
blackOut( duration, blur )
{
	self fadeOverlay( duration, 1, blur );
}

grayOut( duration, blur )
{
	self fadeOverlay( duration, 0.6, blur );
}

restoreVision( duration, blur )
{
	self fadeOverlay( duration, 0, blur );
}

fadeOverlay( duration, alpha, blur )
{
	self fadeOverTime( duration );
	self.alpha = alpha;
	setblur( blur, duration );
	wait duration;
}

// AI STUFF

ignore_everything()
{
	self.ignoreall = true;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	self disable_pain();
	
	self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
	self.newEnemyReactionDistSq = 0;
}

clear_ignore_everything()
{
	self.ignoreall = false;
	self.grenadeawareness = 1;
	self.ignoreexplosionevents = false;
	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.fixednode = true;
	self.disableBulletWhizbyReaction = false;
	self enable_pain();
	
	if( IsDefined( self.og_newEnemyReactionDistSq ) )
	{
		self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
	}
}

move_on_path( chainStart, deleteme )
{
	self endon( "stop_path" );
	self endon( "death" );
	
	self disable_arrivals_and_exits();
	
	chain = get_target_chain_array( chainStart );
	foreach( spot in chain )
	{
		if( isdefined( spot.script_animation ) )
		{
			spot anim_generic_reach( self, spot.script_animation );
			spot anim_generic( self, spot.script_animation );
		}
		else
		{
			
			radius = undefined;
			if( isdefined( spot.radius ) )
				radius = spot.radius;
			else
				radius = 56;
		
			self childthread force_goalradius( radius );
			
			self setgoalpos( spot.origin );
			
			while( DistanceSquared( spot.origin, self.origin ) > squared( self.goalradius ) )
				wait( .1 );
		}
		
		if( isdefined( spot.script_noteworthy ) )
			self notify( spot.script_noteworthy );
		
	}	
	
	if( isdefined( deleteme ) )
		self delete_safe();
}

delete_safe()
{	
	if( isdefined( self.magic_bullet_shield ) && self.magic_bullet_shield == true )
		self stop_magic_bullet_shield();
	
	self delete();
}

ambient_runner_think()
{
	self endon( "death" );
	
	self disable_arrivals_and_exits();
	self ignore_everything();
	self pathrandompercent_zero();
	self.fixedNode = false;
	self.interval = 0;
	self.pushable = false;
	self.badplaceawareness = 0;
	
	spot = getstruct( self.target, "targetname" );
	while( isdefined( spot ) )
	{
		gRadius = 56;
		if( isdefined( spot.radius ) )
			gRadius = spot.radius;
		
		self setgoalpos( spot.origin );
		self waittill_goal( gRadius );
		
		if( !Isdefined( spot.target ) )
			break;
		
		array = getstructarray( spot.target, "targetname" );
		if( array.size > 1 )
			spot = array[ randomint( array.size )];
		else
			spot = array[0];
	}
	
	self delete();	
}

waittill_goal( radius, deleteme )
{
	self endon( "death" );
	
	if( isdefined( radius ) )
		self.goalradius = radius;
	self waittill( "goal" );
	
	if( isdefined( deleteme ) )
		self delete();
}

waittill_real_goal( goal, deleteMe )
{
	self endon( "death" );
	self notify( "setting_new_goal" );
	self endon( "setting_new_goal" );
	
	while( 1 )
	{
		self waittill( "goal" );
		
		gDistance = self.goalradius;
		if( isdefined( goal.radius ) )
			gDistance = goal.radius;

		if( Distance( goal.origin, self.origin ) < gDistance + 10 )
			break;
	}
	
	if( isdefined( deleteMe ) )
		self delete();
	
	if( !isdefined( goal.script_noteworthy ) )
		return;
	
	switch( goal.script_noteworthy )
	{
		case "deleteme" : 
			self delete();
			break;
			
		case "deleteme_safe" : 
			break;
		
		case "killme" :
			self kill();
			break;
	}
}

force_goalradius( radius )
{
	self notify( "force_goal_radius" );
	self endon( "force_goal_radius" );
	self endon( "death" );
	
	while( 1 )
	{
		self.goalradius = radius;
		wait( .1 );
	}
}


waittill_death_respawn( spawner, minT, maxT )
{
	spawner endon( "stop_spawning" );
	
	ai = self;
	
	assert( isdefined( ai ) );
	assert( isdefined( spawner ) );
	
	while( 1 )
	{
		ai waittill_any( "death", "dying" );
		
		wait( randomfloatrange( minT, maxT ) );
		
		ai = spawner spawn_ai();
	}
}

// needs to be called before spawners spawn AI
waittill_spawners_empty( spawners, totalDeathCounter )
{
	watcher = spawnStruct();
	
	array_thread( spawners, ::waittill_spawner_spawns, watcher );
	
	if( !isdefined( totalDeathCounter ) )
	{
		foreach( spawner in spawners )
			totalDeathCounter = totalDeathCounter + spawner.count;
	}
	
	while( watcher.deathCounter < totalDeathCounter )
		wait( .1 );
	
	iprintlnbold( "killed enough" );
}

waittill_spawner_spawns( watcher )
{
	while( isdefined( self ) )
	{
		if( self.count < 1 )
			break;
		
		self waittill( "spawned", ai );
		watcher.deathCounter++;
	}
}

waittill_stealth_notify()
{
	self endon( "death" );
	level endon( "stealth_event_notify" );
	
    self addAIEventListener( "grenade danger" );
    self addAIEventListener( "projectile_impact" );
    self addAIEventListener( "silenced_shot" );
    self addAIEventListener( "bulletwhizby" );
    self addAIEventListener( "gunshot" );
	self addAIEventListener( "gunshot_teammate" );
	self addAIEventListener( "explode" );
    
    self waittill( "ai_event", eventtype );
    
    level notify( "stealth_event_notify", self );

}

disable_arrivals_and_exits( onoff )
{
	if( !isdefined( onoff ) )
		onoff = true;
	
	self.disablearrivals = onoff;
	self.disableexits = onoff;
}

set_all_ai_targetnames( spawner )
{
	if( !isdefined( spawner.targetname ) )
		return;
	self.targetname = spawner.targetname;
}

enemy_rpg_unlimited_ammo( ender )
{
	Assert( IsDefined( self.a.rockets ) );
	
	if( isdefined( ender ) )
		self endon( ender );
	
	self endon( "death" );
	
	max_ammo = 1;
	
	for ( ; ; )
	{
	    if ( IsDefined( self.a.rockets ) )
	    	self.a.rockets  = max_ammo;
		wait 0.05;
	}
}

goal_radius_constant( radius )
{
	self endon( "death" );
	
	while( 1 )
	{
		self set_goal_radius( radius );
		wait( .1 );
	}
}

// VEHICLE STUFF

#using_animtree( "vehicles" );

vehicle_to_model()
{
	model = spawn( "script_model", self.origin );
	model.angles = self.angles;
	model setmodel( self.model );
	model UseAnimTree(#animtree );
	self.fakeModel = model;
	self hide();
	
	self maps\_vehicle::move_riders_here( self.fakeModel );
	self maps\_vehicle_code::move_turrets_here( self.fakeModel );
	
	return model;	
}

model_to_vehicle()
{
	assert( isdefined( self.fakeModel ) );
	self Vehicle_Teleport( self.fakeModel.origin, self.fakeModel.angles );
	self show();
	
	self maps\_vehicle_code::move_turrets_here( self );
	
	// move_turrets_here + move_riders_here were not working together
	if(	isdefined( self.mgturret ) && isdefined( self.riders ) )
	{
		if( isdefined( self.mgturret[1] ) && isdefined( self.riders[0] ) )
		{
			guy = self.riders[0];
			guy unlink();
			guy linkto( self.mgturret[1], "tag_origin", ( 0,0,-25 ), ( 0,0,0 ) );
		}
	}
	
	self.fakeModel delete();
	self.fakeModel = undefined;
}

create_default_targetEnt( tag )
{
	if( !isdefined( tag ) )
		tag = "tag_flash";
	
	fwd = anglestoforward( self gettagangles( tag ) );
	targetent = spawn( "script_origin", self gettagorigin( tag ) + ( fwd * 50 ) );
	targetent linkto( self );
	
	self.defaultTarget = targetent;
}

vehicle_fire_at_targets( targets, times, minT, maxT )
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	self notify( "engaging_new_targets" );
	self endon( "engaging_new_targets" );
	
	if( !isdefined( times ) )
		times = 1;
	
	if( !isdefined( minT ) )
		minT = .5;
	if( !isdefined( maxT ) )
		maxT = 1;
	
	turnTime = 1;
	if( isdefined( self.turretTurnTime ) )
		turnTime = self.turretTurnTime;
	
	lastTarget = undefined;
	while( 1 )
	{
		count = 0;
	
		cTargets = targets;
		if( isdefined( lastTarget ) )
			cTargets = array_remove( targets, lastTarget );
		target = cTargets[ randomint( cTargets.size ) ];
		
		// only define last target if vehicles targets is greater than 1
		if( cTargets.size > 1 )
			lastTarget = target;
		
		self SetTurretTargetVec( target.origin );
		
		wait( turnTime );
		
		delay = 0;
		while( count < times )
		{
			wait( delay );
			self vehicle_fire();
			count++;
			delay = .2;
		}
		
		wait( randomfloatrange( minT, maxT ) );
	}
}

vehicle_fire_loop( tag, minT, maxT )
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	if( !isdefined( minT ) )
		minT = .5;
	if( !isdefined( maxT ) )
		maxT = 1;
	
	while( 1 )
	{
		wait( randomfloatrange( minT, maxT ) );
		self vehicle_fire( tag );
	}	
}

vehicle_fire( tag )
{
	if( !isdefined( tag ) )
		tag = "tag_flash";
	
	self fireweapon( tag );
}

attach_path_and_drive( node )
{
	self AttachPath( node );
	self StartPath( node );
	self thread vehicle_paths( node );	
}

BULLET_HINT_WAIT_TIME = 6000; // Time waited ( miliseconds ) before allowing another bullet hint
BULLET_HITS_BEFORE_HINT = 5; // Bullet hit amount before hint is displayed
MG_PLAYER_HITS_KILL = 25;
VEHICLE_PROJECTILE_DAMAGE = 9999;
VEHICLE_MG_DAMAGE = 10;
VEHICLE_30MM_DAMAGE = 200;
vehicle_allow_player_death( bulletHint )
{	
	self endon( "death" );
	
	self.bulletCount = 0;
	self godon();
	self setcandamage( true ); 
	
	MGPlayerHitsKill = MG_PLAYER_HITS_KILL;
	switch( self.classname )
	{
		case "script_vehicle_t90ms_trophy" :
			self.fakeHealth = 2000;
			break;
			
		case "script_vehicle_nh90" :
			self.fakeHealth = 250;
			break;
			
		case "script_vehicle_hovercraft_cheap" :
			self.fakehealth = 1000;
			self hovercraft_allow_death();
			
			break;
		
		case "script_vehicle_hind_battle" :
			self.fakehealth = 1000;
			break;
	}
	
	startHealth = self.fakehealth;
	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );
		
		if ( !IsPlayer( attacker ) )
			continue;
		
		type = ToLower( type );
		weapon = ToLower( weapon );
		
		switch( weapon )
		{
			case "mod_projectile" :
				self.fakehealth = self.fakehealth - VEHICLE_PROJECTILE_DAMAGE;
				break;
			case "stinger" :
				self.fakehealth = self.fakehealth - VEHICLE_PROJECTILE_DAMAGE;
				break;
			case "dshk_turret_homecoming" :
				self.fakehealth = self.fakehealth - VEHICLE_MG_DAMAGE;
				break;
				
			case "a10_30mm_player_homecoming" :
				self.fakehealth = self.fakehealth - VEHICLE_30MM_DAMAGE;
				break;
		}
		
		if( self.fakehealth <= 0 )
		{
			self godoff();
			self force_kill();				
		}
		
		
		if( isdefined( self.beachLander ) )
		{
			if( self.fakehealth <= int( startHealth/2 ) )
				self ent_flag_set( "unload_interrupted" );
		}
	
	}
}

javelin_target_set( ent, offset )
{
	target_set( ent, offset );
	target_setJavelinOnly( ent, true );
	Target_SetAttackMode( ent, "top" );
	
	ent thread javelin_target_death();
}

javelin_target_death()
{
	self waittill( "death" );
	if( isdefined( self ) && isAlive( self ) )
		Target_Remove( self );
}

javelin_check_decent( missile )
{
	missile endon( "death" );
	wait( 2 ); // give it time to start going up
	
	while( 1 )
	{
		oldZ = missile.origin[2];
		wait( .1 );
		currentZ = missile.origin[2];
		if( oldZ > currentZ )
			break;
	}
	
}

turret_shoot_targets( targets )
{
	self notify( "turret_shoot_targets" );
	self endon( "turret_shoot_targets" );
	
	turret = self;
	turret setmode( "manual" );
	//turret SetBottomArc( 180 );
	//turret TurretFireEnable();
	
	currentTargets = targets;
	
	while( 1 )
	{
		target = currentTargets[ randomint( currentTargets.size ) ];
		currentTargets = array_remove( targets, target );
		
		turret SetTargetEntity( target );
		turret thread turret_startfiring();
		wait( randomfloatrange( .5, 3 ) );
		turret thread turret_stopfiring();
		wait( randomfloatrange( .5, 3 ) );
	}
}

turret_startfiring()
{
	self endon( "stop_firing_turret" );
	
	while( 1 )
	{
		self ShootTurret();
		wait( .15 );
	}
}

turret_stopfiring()
{
	self notify( "stop_firing_turret" );	
}

vehicle_path_notifications()
{
	self endon( "death" );

	while( 1 )
	{
		self waittill( "noteworthy", msg );
		
		if( self isHelicopter() )
		{
			self thread heli_path_notifications( msg );
			continue;
		}
		
		///////////////////////////////////////////////
		
		currentNode = self.currentNode;
		switch( msg )
		{
		
			case "target_nothing" :
				self notify( "stop_firing" );
				// TODO : reset turret back to it's default position
				break;
			
			case "fire_at_targets" :
				structs = currentNode get_linked_structs();
				assertEX( isdefined( structs ), "msg set, but no structs linked" );
			
				shots = undefined;
				if( isdefined( self.script_shotcount ) )
					shots = self.script_shotcount;
				
				minT = undefined;
				maxT = undefined;
				if( isdefined( self.fireTime ) )
				{
					minT = self.fireTime[0];
					maxT = self.fireTime[1];
				}
				self thread vehicle_fire_at_targets( structs, shots, minT, maxT );
				break;
				
			case "strafe_start" :
				self thread a10_strafe_run();
				break;
		}
	}
}

heli_path_notifications( msg )
{
	self endon( "death" );
	
	currentNode = self.currentNode;
	
	if( msg == "target_nothing" )
	{
		self notify( "stop_firing" );
		self clearLookAtEnt();
		// TODO : reset turret back to it's default position
	}
	else if( msg == "fire_at_targets" )
	{
		ents = currentNode get_linked_ents();
		assertEX( isdefined( ents ), "msg set, but no ents linked" );
		
		tags = [];
		tags[ 0 ] = "tag_missile_left";
		tags[ 1 ] = "tag_missile_right";
		nextMissileTag = -1;
		additiveDelay = 0;
		
		foreach( ent in ents )
		{
			if( isdefined( ent.script_turret ) )
			{
				lookAt = undefined;
				if( ent parameters_check( "lookat" ) )
					lookAt = true;
				
				self thread heli_fire_turret( ent, lookAt );
			}
			else
			{
				delay = undefined;
				if( isdefined( ent.delay ) )
					delay = ent.delay;
				
				shots = 1;
				if( isdefined( ent.script_shotcount ) )
					shots = ent.script_shotcount;
						
				missileType = undefined;
				if( isdefined( ent.script_noteworthy ) )
					missileType = ent.script_noteworthy;
				
				delayTime = 0;
				if( isdefined( ent.script_delay ) )
					delayTime = ent.script_delay;
				
				if( ent parameters_check( "add_delay" ) )
				{
					additiveDelay = delayTime + additiveDelay;
					delayTime = additiveDelay;
				}
				
				nextMissileTag++;
				if ( nextMissileTag >= tags.size )
					nextMissileTag = 0;
					
				self delaythread( delayTime, ::heli_fire_missiles, ent, shots, tags[ nextMissileTag ], delay, missileType );	
			}  
		}
	}
}

heli_enable_rocketDeath( bool )
{
	if( !isdefined( bool ) )
		bool = true;
	
	self.enableRocketDeath = bool;
	self.alwaysRocketDeath = bool;	
}

heli_fire_missiles( target, shots, tag, delay, missileType )
{
	weaponName = "missile_attackheli";
	if ( isdefined( missileType ) )
		weaponName = missileType;
	
	if( !isdefined( delay ) )
		delay = 1;
	
	defaultWeapon = "minigun_littlebird_quickspin";
	if( isdefined( self.defaultWeapon ) )
		defaultWeapon = self.defaultWeapon;
	
	self.firingMissiles = true;
	
	for( i=0; i<shots; i++ )
	{	
		self SetVehWeapon( weaponName );
		missile = self FireWeapon( tag, target );
		
		if( i < shots - 1 )
			wait( delay );
	}

	self SetVehWeapon( defaultWeapon );
	
	self.firingMissiles = false;
}

heli_fire_turret( target, lookatEnt )
{
	self endon( "death" );
	self notify( "switching_targets" );
	self endon( "switching_targets" );
	self endon( "stop_firing" );
	
	if( isEntity( target ) )
	{
		self SetTurretTargetEnt( target );
		
		if( isdefined( lookatEnt ) )
			self SetLookAtEnt( target );
	}
	else
		self SetTurretTargetVec( target.origin );
	
	burstMin = 30;
	burstMax = 50;
	if( isdefined( self.script_burst_min ) && isdefined( self.script_burst_max ) )
	{
		burstMin = self.script_burst_min;
		burstMax = self.script_burst_max;
	}
	
	fireWait = .05;
	if( isdefined( self.fireWait ) )
		fireWait = self.fireWait;
	
	while( 1 )
	{
		self thread heli_fire_turret_sound();
		
		burst = randomintrange( burstMin, burstMax );
		
		for( i=0; i<burst; i++ )
		{
			if( isdefined( self.firingMissiles ) && self.firingMissiles == true )
				continue;
		
			self fireweapon();
			wait( fireWait );
		}
		
		self notify( "stop_minigun_sound" );
		
		wait( randomfloatrange( .4, .9 ) );
	}
}

heli_fire_turret_sound()
{	
	sEnt = spawn( "script_origin", self.origin );
	sEnt linkto( self );
	
	//sEnt thread play_sound_on_entity( "minigun_heli_gatling_spinup" + randomintrange( 1,4 ) );
	//sEnt delaythread( 1, ::play_loop_sound_on_entity, "minigun_heli_gatling_fire" );
	SEnt thread play_loop_sound_on_entity( "minigun_heli_gatling_fire" );
	self waittill_any( "death", "switching_targets", "stop_firing", "stop_minigun_sound" );
	sEnt stop_loop_sound_on_entity( "minigun_heli_gatling_fire" );
	sEnt delete();
}

heli_beach_lander_init()
{
	self endon( "death" );
	
	self ent_flag_init( "unload_interrupted" );
	self.beachLander = true;
	
	if( self parameters_check( "instant_landing" ) )
	{
		self.currentNode = getStruct( self.script_linkto, "script_linkname" );
		self Vehicle_Teleport( self.currentNode.origin, self.currentNode.angles );
		self SetAnimRestart( %nh90_landing_gear_down, 1, 1, 999 );
	}
	else
	{
		msg = self waittill_any_return( "landing_gear", "reached_dynamic_path_end" );
	
		if( msg == "landing_gear" )
		{
			self SetAnimRestart( %nh90_landing_gear_down, 1, 1, .5 );
			self waittill( "reached_dynamic_path_end" );
		}
	}
	
	self heli_enable_rocketDeath();
	
	currentSpot = self.currentNode;
	self SetNearGoalNotifyDist( 5 );
	self SetHoverParams( 0, 0, 0 );
	self SetVehGoalPos( currentSpot.origin, true );
	self ClearGoalYaw();
	self SetTargetYaw( flat_angle( self.angles )[ 1 ] );
	
	self waittill( "near_goal" );
	
	self delayCall( randomfloatrange( .1, .3 ), ::setanim, %nh90_left_door_open );
	self delayCall( randomfloatrange( .1, .3 ), ::setanim, %nh90_right_door_open );
	
	self.unloaded = 0;
	spawners = currentSpot get_linked_ents();
	foreach( spawner in spawners )
	{
		wait( randomfloatrange( .5, 1 ) );
		
		sAmount = 3;
		if( isdefined( spawner.script_index ) )
			sAmount = spawner.script_index;
		
		spot = getstruct( spawner.script_linkto, "script_linkname" );
		spawner thread heli_beach_lander_ai_jumpout( spot, sAmount, self );
	}
	while( self.unloaded != 2 )
		wait( .1 );
	
	self notify( "unload_complete" );
	self thread heli_beach_lander_leave( currentSpot );
}

heli_beach_lander_leave( currentSpot )
{
	self heli_enable_rocketDeath( false );
	struct = currentSpot get_linked_structs();
	self thread vehicle_paths( struct[0] );
	
	self SetAnimRestart( %nh90_landing_gear_up, 1, 1, .3 );
}

heli_beach_lander_ai_jumpout( spot, sAmount, lander )
{
	lander endon( "death" );
	
	count = 0;
	while( count < sAmount )
	{
		ai = self spawn_ai();
		if( !isdefined( ai ) )
		{
			wait( .05 );
			continue;
		}
		
		ai maps\homecoming_beach::beach_enemy_default();
		ai set_baseaccuracy( 3 );
		
		if( cointoss() )
			ai.favoriteenemy = level.player;
		
		assert( isdefined( spot.script_animation ) );
		
		spot anim_generic( ai, spot.script_animation );
		wait( randomfloatrange( .5, .9 ) );
		count++;
		
		if( lander ent_flag( "unload_interrupted" ) )
			break;
	}

	lander.unloaded++;
}

CONST_MISSILE_DEFENSE_POP_FLARES_DIST = 600;
CONST_MISSILE_DEFENSE_FLARES_EXPLODE_DIST = 200;
heli_missile_defense_init()
{
	self endon( "death" );
	
	level.javelinTargets[ level.javelinTargets.size ] = self;
	
	while( 1 )
	{
		self waittill( "javelin_targeted", missile );
		
		javelin_check_decent( missile );
		
		while( IsValidMissile( missile ) )
		{
			if( distance_2d_squared( self.origin, missile.origin ) < squared( CONST_MISSILE_DEFENSE_POP_FLARES_DIST ) )
				break;
			
			wait( .05 );
		}
		
		if( !isdefined( missile ) || !isValidMissile( missile ) )
			continue;
		
		self thread shootFlares();
		
		while( !isdefined( self.flares ) )
			wait( .05 );
		
		if( !isdefined( missile ) || !isValidMissile( missile ) )
			continue;		

		flare = getclosest( missile.origin, self.flares );
		missile missile_settargetent( flare );
		
		
		while( IsValidMissile( missile ) )
		{
			if( distance_2d_squared( flare.origin, missile.origin ) < squared( CONST_MISSILE_DEFENSE_FLARES_EXPLODE_DIST ) )
				break;
			
			wait( .05 );
		}
		
		flareExplodeFx = getFx( "chopper_flare_explosion" );
		
		missile notify( "death" );
		PlayFXOnTag( flareExplodeFx, flare, "tag_origin" );
		flare delete();
	}
}

shootFlares()
{
	rig = spawn_anim_model( "flare_rig" );
	rig.origin = self gettagorigin( "tag_flare" );
	rig.angles = self gettagangles( "tag_flare" );
	//rig linkto(	self, "tag_flare", ( 0,0,0 ), ( 0,0,0 ) );
	
	flares = [];
	tags = [ "flare_right_top", "flare_left_bot", "flare_right_bot" ];
	
	foreach( tag in tags )
	{
		flare = spawn_tag_origin();
		flare linkto( rig, tag, ( 0,0,0 ), ( 0,0,0 ) );
		flare thread flare_trackVelocity();
		flares[ tag ] = flare;
	}
	
	self.flares = flares;
	
	count = level.scr_anim[ "flare_rig" ][ "flare" ].size;
	anime = level.scr_anim[ "flare_rig" ][ "flare" ][ 2 ];
	rig SetFlaggedAnim( "flare_anim", anime, 1, 0, 1 );
	
	flareFx = getFx( "chopper_flare" );
	
	flares = array_randomize( flares );
	
	foreach( tag, flare in flares )
	{
		if( IsDefined( flare ) )
			PlayFXOnTag( flareFx, flares[ tag ], "tag_origin" );
	}
	
	rig waittillmatch( "flare_anim", "end" );
	
	foreach( tag, flare in flares )
	{
		if( IsDefined( flare ) )
			StopFXOnTag( flareFx, flares[ tag ], "tag_origin" );
	}
	
	rig Delete();
	
	flares = array_removeUndefined( flares );
	array_thread( flares, ::flare_doBurnOut );
	
	return flares;
}

flare_trackVelocity()
{
	self endon( "death" );
	
	self.velocity 	= 0;
	lastPos 		= self.origin;
	
	for ( ; ; wait 0.05 )
	{
		self.velocity 	= self.origin - lastPos;
		lastPos 		= self.origin;
	}
}

FLARE_BURN_OUT_TIME 	= 0.2;
FLARE_VELOCITY_SCALE 	= 14;
flare_doBurnOut()
{
	self endon( "death" );
	
	self MoveGravity( FLARE_VELOCITY_SCALE * self.velocity, FLARE_BURN_OUT_TIME );
	wait FLARE_BURN_OUT_TIME;
	
	// Don't delete flares which are undefined or paired with a missile.
	// Paired flares are cleaned up by the missile logic
	if ( !IsDefined( self ) || IsDefined( self.myTarget ) )
		return;
	
	self Delete();
}

get_helicopter_crash_location( noteworthy )
{
	foreach( spot in level.helicopter_crash_locations )
	{
		if( isdefined( spot.script_noteworthy ) )
		{
			if( spot.script_noteworthy == noteworthy )
				return spot;
		}
	}
}

// a10 warthog stuff
a10_strafe_run()
{
	self thread play_sound_on_entity( "a10_flyby_short" );
	
	self.firing_sound_ent = Spawn( "script_origin", (0, 0, 0) );
	self.firing_sound_ent linkto( self );
	self.firing_sound_ent thread play_loop_sound_on_entity( "a10p_gatling_loop" );
	
	self thread a10_strafe_impacts();
	self waittill( "strafe_end" );
	self.impactMover delete();
	self.firing_sound_ent thread sound_fade_and_delete( 0.05 );
}

STRAFE_IMPACT_RADIUS = 275;
STRAFE_IMPACT_FORWARD = 2500;
a10_strafe_impacts()
{
	self endon( "strafe_end" );
	
	fwd = anglestoforward( self.angles );
	origin = self.origin + ( fwd * STRAFE_IMPACT_FORWARD );
	impactMover = spawn( "script_origin", origin );
	impactMover linkto( self );
	self.impactMover = impactMover;
	
	
	radius = STRAFE_IMPACT_RADIUS;
	if( isdefined( self.impactRadius ) )
		radius =  self.impactRadius;
	
	rSquared = squared( radius );
	
	while( 1 )
	{
		
		playfxontag( getfx( "a10_muzzle_flash" ), self, "tag_gun" );
		
		num = randomintrange( 2, 4 ); // give it some extra
		for( i=0; i<num; i++ )
		{
			// figures out random X and Y in a radius
			x = randomfloatrange( ( radius * -1 ), radius );
			y = randomfloatrange( -1,1 ) * sqrt( rSquared-X*X );
		
			// figures out the Z
			trace = BulletTrace( ( x, y, impactMover.origin[2] ), ( x, y, -99999 ), false );
			tPos = trace[ "position" ];
			z = tPos[2];
		
			x = x + impactMover.origin[0];
			y = y + impactMover.origin[1];
		
			playfx( getfx( "a10_sand_impact" ), ( x,y,z ), ( 0,0,1 ) );
		}
		
		trace = BulletTrace( impactMover.origin, ( impactMover.origin[0], impactMover.origin[1], -99999 ), false );
		self RadiusDamage( trace[ "position" ], radius, 9999, 9999, self );
		playfxontag( getfx( "a10_muzzle_flash" ), self, "tag_gun" );

		wait( .05 );
	}
}

// slamraam stuff
slamraam_think( fireLoop, ender, weaponOverride )
{
	slamraam = self;
	
	tags = [];
	tags[ tags.size ] = "tag_missle1";
	tags[ tags.size ] = "tag_missle2";
	tags[ tags.size ] = "tag_missle3";
	tags[ tags.size ] = "tag_missle4";
	tags[ tags.size ] = "tag_missle5";
	tags[ tags.size ] = "tag_missle6";
	tags[ tags.size ] = "tag_missle7";
	tags[ tags.size ] = "tag_missle8";
	
	slamraam.missileTags = tags;
	slamraam.missiles = [];
	
	foreach( tag in tags )
	{
		model = Spawn( "script_model", ( 0, 0, 0 ) );
		model.origin = slamraam GetTagOrigin( tag );
		model.angles = slamraam GetTagAngles( tag );
		model SetModel( "projectile_slamraam_missile" );
		model LinkTo( slamraam, tag );		
		slamraam.missiles[ slamraam.missiles.size ] = model;
		
	}

	fwd = AnglesToForward( slamraam.angles );
	slamraam.targetEnt = spawn( "script_origin", ( slamraam.origin + ( fwd * 50 ) ) + ( 0,0,115 ) );
	slamraam setturrettargetent( slamraam.targetEnt );
	
	if( isdefined( fireLoop ) && fireLoop == true )
		slamraam thread slamraam_fire_missiles( fireLoop, ender, weaponOverride );	
}

slamraam_fire_missiles( loop, fireSpeed, weaponOverride )
{
	slamraam = self;
	slamraam endon( "stop_firing" );
	
	tags = slamraam.missileTags;
	
	if( !isdefined( fireSpeed ) )
	{
		fireSpeed[ 0 ] = .4;
		fireSpeed[ 1 ] = .8;
	}
	
	while( 1 )
	{
		foreach( index, tag in tags )
		{
			if( isdefined( slamraam.missiles[ index ] ) )
				continue;

			model = Spawn( "script_model", ( 0, 0, 0 ) );
			model.origin = slamraam GetTagOrigin( tag );
			model.angles = slamraam GetTagAngles( tag );
			model SetModel( "projectile_slamraam_missile" );
			model LinkTo( slamraam );		
			slamraam.missiles[ slamraam.missiles.size ] = model;
			
		}
		
		missiles = array_randomize( slamraam.missiles );
		
		wait( randomfloatrange( .2, 1.2 ) );
		
		foreach( index, missile in missiles ) 
		{
			slamraam slamraam_fire_missile( tags[ index ], missile, weaponOverride );
			wait( randomfloatrange( fireSpeed[ 0 ], fireSpeed[ 1 ] ) );
		}
		
		if( !isdefined( loop ) )
			break;
		
		wait( randomintrange( 1, 4 ) );
	}	
}


slamraam_fire_missile( tag, missile, weaponOverride )
{
	weapon = "slamraam_missile";
	if( isdefined( weaponOverride ) )
	   weapon = weaponOverride;
	
	start = self gettagorigin( tag );
	angles = self GetTagAngles( tag );
	forward = AnglesToForward( angles );
	end = start + ( forward * 50000 );
	MagicBullet( weapon, start, end );
	delaythread( .05, ::deleteEnt, missile );
}

artemis_think( targets )
{
	self notify( "new_targets" );
	self endon( "new_targets" );
	
	if( !isdefined( targets ) )
		targets = self get_linked_structs();
	
	self thread artemis_fire();
	
	while( 1 )
	{
		foreach( target in targets )
		{
			origin = target.origin + ( 0,0,randomintrange( -25, 25 ) );
			self setturrettargetvec( origin );
			wait( 5 );
		}
	}
}

artemis_fire()
{
	self notify( "stop_firing" );
	self endon( "stop_firing" );
	
	tags = [ "tag_flash_left", "tag_flash_right" ];
	
	while( 1 )
	{
		foreach( tag in tags )
		{
			self fireweapon( tag );
			wait( .2 );
		}
	}
}

// HOVERCRAFT LOGIC
hovercraft_init()
{
	level.hovercrafts[ level.hovercrafts.size ] = self;
	
	if( self hovercraft_set_unloaded() )
		return;
	
	// FLAGS
	self ent_flag_init( "hovercraft_unload_complete" );
	self ent_flag_init( "hovercraft_continue_path" );
	self ent_flag_init( "hovercraft_animations_done" );
	
	self.cleanupEnts = [];
	
	self thread hovercraft_anim_logic();
	self thread hovercraft_missile_fire();
	
	// VEHICLE CHECK
	vSpawners = [];
	linkedEnts = self get_linked_ents();
	foreach( ent in linkedEnts )
	{
		// check to see if it is a vehicle
		if( ent isVehicle() )
		{
			// need to check to see if this is a starter hovercraft
			if( ent parameters_check( "starter" ) )
				continue;
			
			vSpawners[ vSpawners.size ] = ent;
			break;
		}
	}
	
	if( vSpawners.size > 0 )
	{
		self hovercraft_tanks_setup( vSpawners );
		self thread hovercraft_tanks_unload();
	}
	
	// DRONE CHECK
	if( self parameters_check( "droneUnloader" ) )
		self.droneUnloader = true;
	
	if( self parameters_check( "infiniteDrones" ) )
		self.infiniteDrones = true;
		
	if( isdefined( self.droneUnloader ) && self.droneUnloader == true )
	{
		self ent_flag_init( "hovercraft_drone_setup_complete" );
		self thread hovercraft_drone_setup();
		self ent_flag_wait( "hovercraft_drone_setup_complete" );
	}
	
	thread gopath( self );
	
	self waittill( "hovercraft_unload" );
	
	if( self ent_flag_exist( "hovercraft_tank_unload_complete" ) )
		self ent_flag_wait( "hovercraft_tank_unload_complete" );
	if( self ent_flag_exist( "hovercraft_drone_unload_complete" ) )
		self ent_flag_wait( "hovercraft_drone_unload_complete" );
	
	self ent_flag_set( "hovercraft_unload_complete" );
	
	// wait for hovercraft to inflate
	self ent_flag_wait( "hovercraft_animations_done" );
	
	self ent_flag_set( "hovercraft_continue_path" );
	
	self hovercraft_cleanup();
}

hovercraft_anim_logic()
{
	self SetAnim( %hovercraft_rocking );
	
	self waittill( "hovercraft_unload" );
	
	self clearanim( %hovercraft_rocking, 0.2 );
	
	deflateRate = 1;
	deflateTime = 12;
	if( isdefined( self.deflateRate ) )
	{
		deflateRate = self.deflateRate;
		deflateTime = deflateTime / deflateRate;
	}
	self.deflateRate = deflateRate;
	self SetAnim( %lcac_deflate, 1.0, 0.2, deflateRate );
	wait( deflateTime );
	
	//self delayCall( deflateTime, ::SetFlaggedAnim, "anim", %lcac_deflate, 1, 0, 0 );	
	self SetFlaggedAnim( "anim", %lcac_deflate, 1, 0, 0 );
	
	self ent_flag_wait( "hovercraft_unload_complete" );
	
	self SetFlaggedAnim( "anim", %lcac_deflate, 1, 1, 1 );
	self waittillmatch( "anim", "end" );
	
	self SetAnim( %hovercraft_rocking );
	self ent_flag_set( "hovercraft_animations_done" );
	
}

hovercraft_missile_fire()
{
	self endon( "death" );
	
	ents = self get_linked_ents();
	missileSpots = [];
	foreach( ent in ents )
	{
		if( ent parameters_check( "missile_spot" ) )
		{
			ent linkto( self );
			missileSpots[ missileSpots.size ] = ent;
			array_add( self.cleanupEnts, ent );
		}
	}
	
	weapon = "hovercraft_missile_guided";
	
	while( 1 )
	{
		self waittill( "fire_missiles" );
		currentNode = self.currentNode;
	
		shots = 3;
		if( isdefined( currentNode.script_count ) )
			shots = currentNode.script_count;
		
		// start on a random side
		missileSpots = array_randomize( missileSpots );
		
		count = 0;
		while( count <= shots )
		{
			foreach( spot in missileSpots )
			{
				count++;
				if( count > shots )
					break;
				
				start = spot.origin;
				forward = AnglesToForward( ( 330, 0, 0 ) );
				end = start + ( forward * 50000 );
				missile = MagicBullet( weapon, start, end );
				fwd = anglestoforward( ( 0,0,0 ) );
				end = start + ( fwd * 20000 );
				missile delaycall( randomfloatrange( 4, 6 ), ::Missile_SetTargetPos, end );
				
				wait( randomfloatrange( .4, .8 ) );
			}
		}
	}
}

// HOVERCRAFT DRONE LOGIC
hovercraft_drone_setup()
{
	self ent_flag_init( "hovercraft_drone_unload_complete" );
	
	ents = self get_linked_ents();
	foreach( ent in ents )
	{
		if( ent parameters_check( "hovercraft_drone_clip" ) )
		{
			ent linkto( self, "tag_detach" );
			self.droneClip = ent;
			array_add( self.cleanupEnts, ent );
		}
	}
	
	structs = self get_linked_structs();
	foreach( struct in structs )
	{
		if( struct parameters_check( "hovercraft_drone_row" ) )
		{
			
			self.droneRowStart = spawn( "script_origin", struct.origin );
			self.droneRowStart.angles = struct.angles;
			self.droneRowStart linkto( self, "tag_detach" );
			array_add( self.cleanupEnts, self.droneRowStart );
			
			rowEnd = getstruct( struct.target, "targetname" );
			self.droneRowEnd = spawn( "script_origin", rowEnd.origin );
			self.droneRowEnd.origin = rowEnd.origin;
			self.droneRowEnd.angles = rowEnd.angles;
			self.droneRowEnd linkto( self, "tag_detach" );
			array_add( self.cleanupEnts, self.droneRowEnd );
			
		}
	}
	
	
	self hovercraft_load_fake_drones();
	
	self ent_flag_set( "hovercraft_drone_setup_complete" );
	
	self.unloadDrones = [];
	
	//self waittill( "reached_end_node" );
	self waittill( "hovercraft_unload" );
	
	if( !isdefined( level.hovercraftDroneUnloader ) )
		level.hovercraftDroneUnloader = 0;
	
	level.hovercraftDroneUnloader++;
	
	self hovercraft_unloader_init();
	
	if( isdefined( self.droneSmoke ) )
		self thread hovercraft_deploy_smoke();
	
	array_delete( self.fakeDrones );
	
	loopCount = 4;
	if( isdefined( self.infiniteDrones ) )
		loopCount = 1;
	else
	{
		if( isdefined( self.script_drone_repeat_count ) )
			loopCount = self.script_drone_repeat_count;
	}
	
	runoutWait = randomfloatrange( 1.8, 2.3 );
	loopWait = 5;
	
	tankUnload = undefined;
	if( isdefined( self.tanks ) )
		tankUnload = true;
	
	while( loopCount != 0 )
	{
		self hovercraft_load_drones();
		wait( runoutWait );
		self hovercraft_dday_runout();
		
		wait( loopWait );
		self.script_drones_max = 10;
		
		if( !isdefined( self.infiniteDrones ) )
			loopCount--;
		runoutWait = 0;
		loopWait = 3;
		
		if( isdefined( tankUnload ) )
		{
			if( isdefined( self.delayTankUnload ) )
				continue;
			
			tankUnload = undefined;
			self ent_flag_wait( "hovercraft_tank_unload_complete" );
			wait( 2 );
		}
	}
	
	self ent_flag_set( "hovercraft_drone_unload_complete" );
	self notify( "drone_runout_done" );
}

hovercraft_unloader_init()
{
	waitframe(); // needs a frame to update currentNode
	currentSpot = self.currentNode;
	
	self.dronePathStarts = [];
	self.droneFightSpots = [];
	self.droneSmoke = undefined;
	
	ents = currentSpot get_linked_ents();
	structs = currentSpot get_linked_structs();
	
	stuff = array_combine( ents, structs );
	foreach( thing in stuff )
	{
		if( isSpawner( thing ) )
		{
			self.droneSpawner = thing;
			continue;
		}
		
		if( isEntity( thing ) )
			thing linkto( self, "tag_detach" );
		
		if( isdefined( thing.targetname ) )
		{
			switch( thing.targetname )
			{
//				case "hovercraft_drone_row" :
//					self.droneRowStart = spawn( "script_origin", thing.origin );
//					self.droneRowStart.angles = thing.angles;
//					self.droneRowStart linkto( self, "tag_detach" );
//					
//					self.droneRowEnd = getstruct( thing.target, "targetname" );
//					break;
//					
				case "hovercraft_drone_smoke" :
					// Smoke grenade dischargers on Leclerc tank
					if( !isdefined( self.droneSmoke ) )
						self.droneSmoke = [];

					self.droneSmoke[ self.droneSmoke.size ] = thing;
					break;
			}
		}
		
		if( !isdefined( thing.script_noteworthy ) )
			continue;
		
		switch( thing.script_noteworthy )
		{
			case "hovercraft_drone_pathstarts" :
				self.dronePathStarts[ self.dronePathStarts.size ] = thing;
				break;				
		}
	}
	
	
}

DRONE_SPACING_DIST_MIN = 40; // 20
DRONE_SPACING_DIST_MAX = 80; // 40
DRONE_ROW_DIST = 24;
DRONE_ROWS_AMOUNT = 7;
DRONES_DEFAULT_AMOUNT = 20;
hovercraft_load_drones()
{
	assertEx( isdefined( self.droneRowStart ), "NO DRONE ROW SPOTS EXIST" );
	
	row = spawnStruct();
	row.origin = self.droneRowStart.origin;
	row.angles = self.droneRowStart.angles;
	rowEnd = self.droneRowEnd;
	//rowLength = distance2d( row.origin, rowEnd.origin );
	
	backVec = AnglesToForward( row.angles ) * -1;
	rowVec = AnglesToRight( row.angles );
	
	droneRowsAmount = DRONE_ROWS_AMOUNT;
	if( isdefined( self.droneRowsAmount ) )
		droneRowsAmount = self.droneRowsAmount;
	
	//dronesAmount = 45;
	//dronesPerRow = dronesAmount/droneRowsAmount;
	//spacing = rowLength/dronesPerRow;
	
	if( !isdefined( self.script_drones_max ) )
		self.script_drones_max = DRONES_DEFAULT_AMOUNT;
	
	self.droneRows = [];
	rowCount = 0;
	currentDrones = [];
	
	grantedDrones = drones_request( self.script_drones_max );
	
//	for( i=0; i<droneRowsAmount; i++ )
	while( currentDrones.size < grantedDrones )
	{
		
		currentOrigin = SpawnStruct();
		currentOrigin.origin = row.origin;
		currentOrigin.origin = row.origin + ( rowVec * randomintrange( 10, 40 ) );
		
		self.droneRows[ rowCount ] = [];
		
		while( postion_dot_check( rowEnd, currentOrigin ) == "behind" )
		{
			if( currentDrones.size >= grantedDrones )
				return;
						
			num = self.droneRows[ rowCount ].size;
			
			drone = self.droneSpawner spawn_ai();
			drone thread drones_death_watcher();
			drone.origin = currentOrigin.origin;
			drone.angles = row.angles;
			drone linkto( self, "tag_detach" );
			currentDrones = array_add( currentDrones, drone );
			self.unloadDrones = array_add( self.unloadDrones, drone );
			self.droneRows[ rowCount ][ num ] = drone;

			
			// Inheriting linkname from spawner, so next hovercraft would link all of the corpses
			drone.script_linkname = undefined;
			
			//spacing = spacing + randomintrange( -2, 2 );
			spacing = randomIntRange( DRONE_SPACING_DIST_MIN, DRONE_SPACING_DIST_MAX );
			currentOrigin.origin = currentOrigin.origin + ( rowVec * spacing );
			
			// Want to make a more robust version of this later that adjust spacing
			// based on self.script_drones_max. This is so I can still have a bunch of rows,
			// making the runout event longer

			if( currentDrones.size >= self.script_drones_max )
				return;
			
		}
		
		row.origin = row.origin + ( backVec * DRONE_ROW_DIST );
		rowCount++;
		
	}
}

hovercraft_load_fake_drones()
{
	
	row = spawnStruct();
	row.origin = self.droneRowStart.origin;
	row.angles = self.droneRowStart.angles;
	rowEnd = self.droneRowEnd;
	
	backVec = AnglesToForward( row.angles ) * -1;
	rowVec = AnglesToRight( row.angles );
	
	rowCount = 0;
	self.fakeDrones = [];
	
	while( rowCount < DRONE_ROWS_AMOUNT )
	{
		
		currentOrigin = SpawnStruct();
		currentOrigin.origin = row.origin + ( rowVec * randomintrange( 10, 40 ) );
		
		
		while( postion_dot_check( rowEnd, currentOrigin ) == "behind" )
		{
			fakeDrone = spawn( "script_model", currentOrigin.origin );
			fakeDrone.angles = ( 0, 90, 0 );
			fakeDrone setmodel( "mw_test_soldier" );
			fakeDrone linkto( self, "tag_detach" );
			
			self.fakeDrones[ self.fakeDrones.size ] = fakeDrone;

			//spacing = spacing + randomintrange( -2, 2 );
			spacing = randomIntRange( DRONE_SPACING_DIST_MIN, DRONE_SPACING_DIST_MAX );
			currentOrigin.origin = currentOrigin.origin + ( rowVec * spacing );
		}
		row.origin = row.origin + ( backVec * DRONE_ROW_DIST );
		rowCount++;
	}	
}

hovercraft_dday_runout()
{
	assertEx( isdefined( self.dronePathStarts ), "NO DRONE PATH STARTS EXIST" );
	
	rowDelay = 0;
	foreach( row in self.droneRows )
	{
		// Get the middle drone in the row
		num = row.size / 2;
		num = int( num );
		testDrone = row[ num ];
		
		startStruct = undefined;
		sortedArray = sortbydistance( self.dronePathStarts, testDrone.origin );
		foreach( struct in sortedArray )
		{
			assertEx( isdefined( struct.targetname ), "drone_path_start structs MUST have a targetname" );
			if( postion_dot_check( struct, testDrone ) == "behind" )
			{
				startStruct = struct;
				break;				
			}		
		}
		
		assertEx( isdefined( startStruct ), "All startSpots are behind this drone" );
		
		foreach( drone in row )
		{
			if( !isdefined( startStruct ) )
				continue;
			
			droneDelay = randomfloatrange( 0, .4 );
			droneDelay = droneDelay + rowDelay;
			
			drone delayCall( droneDelay, ::unlink );
			drone delayThread( droneDelay, maps\homecoming_drones::drone_move_custom, startStruct.targetname );
			drone thread notify_delay( "hovercraft_runout", droneDelay );

			drone thread hovercraft_drone_random_die( droneDelay + 2, 14 );
		}
		rowDelay = rowDelay + randomfloatrange( .2, .4 );
	}
}

DRONE_PATHSTART_DIST = 60;
hovercraft_ai_pathStarts()
{
	pathStart = self.dronePathStarts[0];
	backVec = anglestoforward( pathStart.angles ) * -1;
	
	self.dronePathStarts = [];
	
	//assertEX( isdefined( self.targetname ), "HOVERCRAFT MUST HAVE A TARGETNAME" );
	
	num = int( self.droneRows.size / 2 );
	for( i=0; i<num; i++ )
	{
		self.dronePathStarts[ self.dronePathStarts.size ] = pathStart;
		iprintlnbold( "created" );
		newPathStart = SpawnStruct();
		newPathStart.origin = pathStart.origin + ( backVec * DRONE_PATHSTART_DIST );
		newPathStart.angles = pathStart.angles;
		newPathStart.target = pathStart.targetname;
		newPathStart.targetname = "hovercraft_" + level.hovercraftDroneUnloader + "_dronepathstart_" + i;
		
		//iprintlnbold( pathStart.target );
		
		pathStart = newPathStart;
	}
}


hovercraft_deploy_smoke()
{
	//self endon( "drone_runout_done" );
	self endon( "hovercraft_drone_unload_complete" );
	self endon( "stop_deploying_smoke" );
	
	foreach( spot in self.droneSmoke )
	{
		//if( spot parameters_check( "looping" ) )
			spot childthread playLoopingFX( "hovercraft_smoke", 5.5 );
		//else
			//playFX( getFx( "hovercraft_smoke" ), spot.origin, AnglesToForward( spot.angles ) );	
	}
	
	self notify( "hovercraft_smoke_deployed" );
}

hovercraft_drone_default()
{
	level.hovercraftDrones[ level.hovercraftDrones.size ] = self;
	
	self.name = "";
	self setlookattext( "", &"" );
	self.team = "axis";
	self.health = 1;
	
	// every other drones has ragdoll on so they fall through the world
	// This is to minimize animated bones
	if( !isdefined( level.defaultDroneRagDoll ) )
		 level.defaultDroneRagDoll = 0;
	level.defaultDroneRagDoll++;
	if( level.defaultDroneRagDoll == 6 )
	{
		self.noragdoll = true;
		level.defaultDroneRagDoll = 0;
	}
	
	//self.noragdoll = undefined;
	self.drone_lookAhead_value = 350;
	self give_drone_deathAnim();
	
	self.weaponsound = "drone_ak47_fire_npc";
	runAnims = [ "run_n_gun", "run", "sprint" ];
	runAnim = random( runAnims );
	
	if( runAnim == "sprint" )
		self set_moveplaybackrate( 1.3 );
	else if( runAnim == "run_n_gun" )
	{
		if( cointoss() )
			runAnim = "run";
		else
			thread func_waittill_msg( self, "hovercraft_runout", ::drone_fire_randomly_loop );
	}
	
	self.runanim = level.drone_anims[ self.team ][ "stand" ][ runAnim ];
}

hovercraft_drone_random_die( mmin, mmax )
{
	self endon( "death" );
	self endon( "drone_random_death" );
	wait( randomfloatrange( mmin, mmax ) );
	self die();
}

// HOVERCRAFT TANK LOGIC
hovercraft_tanks_setup( vSpawners )
{
	tanks = [];
	foreach( index, spawner in vSpawners )
		tanks[ index ] = vehicle_spawn( spawner );
	
	self.tanks = tanks;
	self ent_flag_init( "hovercraft_allow_tank_unload" );
	self ent_flag_init( "hovercraft_tank_unload_complete" );
	
	paramCheck = [ "front", "back" ];
	tags = [ "TAG_TANK_FORWARD", "TAG_TANK_BACK" ];
	unloadAnims = [ "lcac_tank_exit_01", "lcac_tank_exit_02" ];
	
	foreach( index, tank in tanks )
	{	
		tank ent_flag_init( "hovercraft_unload_complete" );
		
		tank.lights = undefined;
		fakeTank = tank vehicle_to_model();
		
		if( isdefined( tank.script_parameters ) )
		{
			if( tank parameters_check( "forward" ) )
			{
				fakeTank.tag = "TAG_TANK_FORWARD";
				fakeTank.unloadAnim = "lcac_tank_exit_01";
			}
			else if( tank parameters_check( "back" ) )
			{
				fakeTank.tag = "TAG_TANK_BACK";
				fakeTank.unloadAnim = "lcac_tank_exit_02";
			}
			
		}
		
		if( !isdefined( fakeTank.tag ) )
		{
			fakeTank.tag = tags[ index ];
			fakeTank.unloadAnim = unloadAnims[ index ];
		}
		
		fakeTank LinkTo( self, fakeTank.tag, ( 0,0,0 ), ( 0,0,0 ) );
		
		gopath( tank );
	}
}

hovercraft_tanks_unload()
{
	self waittill ( "hovercraft_unload" );
	
	// allow defalteRate to become defined
	waitframe();
	
	if( isdefined( self.delayTankUnload ) )
		self ent_flag_wait( "hovercraft_allow_tank_unload" );
	
	foreach( index, tank in self.tanks )
	{
		fakeTank = tank.fakeModel;
		
		self thread anim_generic( fakeTank, fakeTank.unloadAnim, fakeTank.tag );
		aanim = getanim_generic( fakeTank.unloadAnim );
		fakeTank SetFlaggedAnim( "single anim", aanim, 1, 0, self.deflateRate );
		animTime = getanimlength( aanim );
		animTime = animTime / self.deflateRate;
			
		delaythread( animTime, ::hovercraft_tanks_unload_logic, tank, fakeTank );

	}
	
	foreach( tank in self.tanks )
		tank add_wait( ::ent_flag_wait, "hovercraft_unload_complete" );
	do_wait();
	
	self notify( "unloaded" );
	self ent_flag_set( "hovercraft_tank_unload_complete" );
	
}

hovercraft_tanks_unload_logic( tank, fakeTank )
{
	tank model_to_vehicle();
	
	// This flag is what tells the tank to continue moving
	tank ent_flag_set( "hovercraft_unload_complete" );
}

hovercraft_set_unloaded()
{
	if( !self parameters_check( "unloaded" ) )
		return false;
	
	self SetAnim( %lcac_deflate );
	self SetAnimTime( %lcac_deflate, .5 );
	self SetFlaggedAnim( "single anim", %lcac_deflate, 1, 0, 0 );
	return true;
}

hovercraft_allow_death()
{
	ents = self get_linked_ents();
	self.weaponClip = undefined;
	
	foreach( ent in ents )
	{
		if( ent parameters_check( "weaponclip" ) )
		{
			ent setcandamage( true ); 
			ent linkto( self, "tag_origin", ( 0,0,0 ), ( 0,0,0 ) );
			self.weaponClip = ent;
			break;
		}
	}
	
	while( 1 )
	{
		self.weaponClip waittill( "damage", amount, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );
		
		if ( !IsPlayer( attacker ) )
			continue;
		
		if( weapon == "a10_30mm_player_homecoming" )
			self.fakehealth = self.fakehealth - VEHICLE_30MM_DAMAGE;
		
		if( self.fakehealth <= 0 )
			break;
	} 
	
	// sink stuff
	self godoff();
	self notify( "death" );
}

hovercraft_cleanup()
{
	array_delete( self.cleanupEnts );
}


// DEBUG
debug_ai_drone_amounts()
{	
	level.player NotifyOnPlayerCommand( "BUTTON_AI_DRONE_AMOUNT_DEBUG", "+actionslot 4" );
	
	while( 1 )
	{
		if( !GetDvarInt( "daniel" ) )
		{
			wait( .2 );
			continue;
		}
		
		
		level.player waittill( "BUTTON_AI_DRONE_AMOUNT_DEBUG" );
		
		vehicleText = maps\_hud_util::createFontString( "default", 1.5 );
		vehicleText.x = 580;
		vehicleText.y = 80;
		aiText = maps\_hud_util::createFontString( "default", 1.5 );
		aiText.x = 580;
		aiText.y = 95;
		droneTxt = maps\_hud_util::createFontString( "default", 1.5 );
		droneTxt.x = 580;
		droneTxt.y = 110;
		queueTxt = maps\_hud_util::createFontString( "default", 1.5 );
		queueTxt.x = 580;
		queueTxt.y = 125;
		totalTxt = maps\_hud_util::createFontString( "default", 1.5 );
		totalTxt.x = 580;
		totalTxt.y = 140;
		
		thread debug_ai_drone_amounts_logic( vehicleText, droneTxt, aiText, queueTxt, totalTxt );
		
		level.player waittill( "BUTTON_AI_DRONE_AMOUNT_DEBUG" );
		
		
		level notify( "stop_ai_drone_debug" );
		droneTxt destroy();
		aiText destroy();
		queueTxt destroy();
		vehicleText destroy();
		totalTxt destroy();
	}
}

debug_ai_drone_amounts_logic( vehicleText, droneTxt, aiText, queueTxt, totalTxt )
{
	level endon( "stop_ai_drone_debug" );
	
	defaultColor = droneTxt.color;
	
	while( 1 )
	{

		vehicles = level.vehicles[ "allies" ];
		vehicles = array_combine( vehicles, level.vehicles[ "axis" ] );
		
		totalAi = getaiarray();
		
		totalDrones = [];
		array = [ level.drones[ "allies" ], level.drones[ "axis" ], level.drones[ "team3" ],level.drones[ "neutral" ] ];
		foreach( thing in array )
			totalDrones = array_combine( totalDrones, thing.array );
		
		vehicleText settext( "Vehicles : " + vehicles.size );
		aiText settext( "AI : " + totalAi.size );
		droneTxt settext( "Drones : " + totalDrones.size );
		queueTxt settext( "Available : " + level.availableDrones );
		
		totalTxt settext( "Total : " + ( level.availableDrones + totalDrones.size ) );
		
		if( totalDrones.size > 50 )
			droneTxt.color = ( 1, 0, 0 );
		else
			droneTxt.color = defaultColor;
		
		wait( .05 );
	}
}

end_of_scripting( AdditionalString )
{
	countTo = 7;
	count = 0;
	while( 1 )
	{
		if( count == countTo )
			break;
		
		iprintlnbold( "end of scripting" );
		if( isdefined( AdditionalString ) )
			iprintlnbold( AdditionalString );
		
		count++;
		wait( 3 );
	}
}
