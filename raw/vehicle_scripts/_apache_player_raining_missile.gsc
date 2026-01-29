#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

_precache()
{
	PrecacheItem( "apache_lockon_raining_missile_phase_2" );
	PrecacheItem( "apache_raining_missile" );
	
	PreCacheShader( "apache_missile_icon" );
	PreCacheShader( "apache_missile_icon_lock" );
	
	_fx();
}

_fx()
{
	level._effect[ "FX_apache_raining_missile_spawn" ] = LoadFX( "fx/_requests/apache/apache_raining_missile_spawn" );
}

_init( owner, masterHud )
{
	Assert( IsDefined( owner ) && IsPlayer( owner ) );
	Assert( IsDefined( masterHud ) );
	
	raining_missile = SpawnStruct();
	
	raining_missile.owner		= owner;
	raining_missile.type		= "raining_missile";
	raining_missile.masterHud	= masterHud;
	raining_missile.target		= undefined;
	raining_missile.isActive	= undefined;
	
	raining_missile hud_init();
	
	return raining_missile;
}

RED 	= ( 1, 0, 0 );
GREEN 	= ( 0, 1, 0 );

hud_init()
{	
	owner 		= self.owner;
	masterHud 	= self.masterHud;
	
	hud = [];
	
	hud[ "missile_name" ] = owner createClientFontString( "objective", 1.0 );
	hud[ "missile_name" ] setPoint( "CENTER", undefined, 142, 92 );
	hud[ "missile_name" ].alpha = 0.0;
	hud[ "missile_name" ].color	= GREEN;
	hud[ "missile_name" ] SetText( "PREACHR:" );
	hud[ "missile_name" ] setParent( masterHud[ "mg_reticle" ] );
	
	hud[ "missile" ] = owner createClientIcon( "apache_missile_icon", 16, 16 );
	hud[ "missile" ] setPoint( "CENTER", undefined, 176, 92 );
	hud[ "missile" ].alpha 				= 1.0;
	hud[ "missile" ].color				= GREEN;
	hud[ "missile" ].isAvailable 		= true;
	hud[ "missile" ].isLockedOnTarget	= undefined;
	hud[ "missile" ] setParent( masterHud[ "mg_reticle" ] );
	
	self.hud = hud;
}

_start()
{
	owner = self.owner;
	
	owner endon( "LISTEN_end_raining_missile" );
	
	self hud_start();
	
	// XBOX: Right Bumper
	owner NotifyOnPlayerCommand( "LISTEN_raining_missile_startLockOn", "+frag" );
	owner NotifyOnPlayerCommand( "LISTEN_raining_missile_startFire", "-frag" );

	self.target = undefined;
	
	self childthread monitorReloading();
	
	for( ; ; )
	{
		if ( !IsDefined( self.isActive ) )
		{
			wait 0.05;
			continue;
		}
		
		owner waittill( "LISTEN_raining_missile_startLockOn" );
		
		if ( !IsDefined( self.isActive ) )
		{
			wait 0.05;
			continue;
		}
		
		self childthread lockOnTarget();
		
		owner waittill( "LISTEN_raining_missile_startFire" );
		
		self childthread _fire();
	}
}

ACTIVE_ALPHA 	= 1.0;
DEACTIVE_ALPHA 	= 0.2;

activate()
{
	hud = self.hud;
	
	self.isActive = true;
	
	if ( IsDefined( hud[ "missile" ].isAvailable ) )
		hud[ "missile" ].alpha = ACTIVE_ALPHA;
	else
		hud[ "missile" ].alpha = 0;
		
	hud[ "missile_name" ].alpha = ACTIVE_ALPHA;
}

deActivate()
{
	hud = self.hud;
	
	self.isActive = undefined;
	
	if ( IsDefined( hud[ "missile" ].isAvailable ) )
		hud[ "missile" ].alpha = DEACTIVE_ALPHA;
	else
		hud[ "missile" ].alpha = 0;
	
	hud[ "missile_name" ].alpha = DEACTIVE_ALPHA;
}

hud_start()
{
	hud = self.hud;
	
	if ( IsDefined( hud[ "missile" ].isAvailable ) )
		hud[ "missile" ].alpha = ter_op( IsDefined( self.isActive ), ACTIVE_ALPHA, DEACTIVE_ALPHA );
	else
		hud[ "missile" ].alpha = 0;
	
	if ( IsDefined( hud[ "missile" ].isLockedOnTarget ) )
		hud[ "missile" ] SetShader( "apache_missile_icon_lock", 16, 16 );
	else
		hud[ "missile" ] SetShader( "apache_missile_icon", 16, 16 );
	
	hud[ "missile_name" ].alpha = ter_op( IsDefined( self.isActive ), ACTIVE_ALPHA, DEACTIVE_ALPHA );
}

RELOAD_INTERVAL = 10;

monitorReloading()
{
	owner = self.owner;
	
	item = self.hud[ "missile" ];
		
	for ( ; ; wait 0.05 )
	{
		if ( !IsDefined( item.isAvailable ) )
		{
			wait RELOAD_INTERVAL;
			//owner thread play_sound_on_entity( "ac130_40mm_reload" );
			//wait self.reloadSoundDelay;
			item SetShader( "apache_missile_icon", 16, 16 );
			item.alpha 				= 1;
			item.color 				= GREEN;
			item.isAvailable 		= true;
			item.isLockedOnTarget 	= undefined;
		}
	}
}

TARGET_ACQUIRE_RADIUS 	= 96;
TARGET_LOST_RADIUS		= 128;

lockOnTarget()
{
	owner = self.owner;
	
	owner endon( "LISTEN_raining_missile_startFire" );
	
	//owner thread play_loop_sound_on_entity( "heli_missile_locking" );
	
	// TODO: Handle Ads
	
	self.target = undefined;
	
	for ( ; ; wait 0.05 )
	{
		targets = Target_GetArray();
		
		// Check to see if player is looking too far away from targets
		// "Un" Lock On the target
		
		foreach ( target in targets )
		{
			if ( target target_isLockedOn( owner ) )
			{
				if ( !Target_IsInCircle( target, owner, 65, TARGET_LOST_RADIUS ) )
				{
					self removeLockedOnTarget( target );
				}
			}
		}
		
		// Search for more valid targets
			
		if ( self hasAmmoForTargets() && !hud_isLockedOnTarget( self.hud[ "missile" ] ) )
		{
			targets	= SortByDistance( targets, owner GetEye() );
			
			target = self getTargetClosestToReticule( targets );
			
			self addLockedOnTarget( target );			
		}
	}
}

getTargetClosestToReticule( targets )
{
	owner = self.owner;
	
	targetFound = false;
	radius 		= TARGET_ACQUIRE_RADIUS;
	
	for ( ; !targetFound && radius > 16; )
	{
		foreach ( target in targets )
		{
			if ( !( target isVehicle() ) || target target_isLockedOn( owner ) || !Target_IsInCircle( target, owner, 65, radius ) )
				targets = array_remove( targets, target );
		}
		
		if ( targets.size <= 2 )
			targetFound = true;
		radius *= 0.75;
	}
	
	return array_randomize( targets )[ 0 ];
}

hud_flashAlpha( initialAlpha, fadeTime, waitTime )
{
	Assert( IsDefined( initialAlpha ) );
	Assert( IsDefined( fadeTime ) );
	
	self endon( "death" );
	
	self.alpha = initialAlpha;
	
	for ( ; ; )
	{
		self FadeOverTime( fadeTime );
		self.alpha = 0;
		wait fadeTime;
		
		if ( IsDefined( waitTime ) && waitTime > 0 )
			wait waitTime;
		
		self FadeOvertime( fadeTime );
		self.alpha = initialAlpha;
		wait fadeTime;
	}
}

target_isLockedOn( owner )
{
	return IsDefined( self._target.weapon[ "lockOn_missile" ].isLockedOn[ owner GetEntityNumber() ] );
}

isLockedOnTarget( target )
{
	return array_contains( self.targets, target );
}

hasAmmoForTargets()
{
	return IsDefined( self.hud[ "missile" ].isAvailable );
}

addLockedOnTarget( target )
{
	owner			= self.owner;
	self.target 	= target;
	
	if ( !IsDefined( target ) )
		return;
	
	if ( !isDummyTarget( target ) )
	{
		if ( !( target target_isLockedOnByAnyWeaponSystem( owner ) ) )
			Target_SetColor( target, RED );
		target target_set_isLockedOn( owner );
	}
	
	// Update hud
	self hud_markUsed_freeMissileIcon();
	
	// Do lock on sounds
	/*
	if ( !isDummyTarget( target ) )
	{
		owner play_sound_on_entity( "heli_missile_tag" );
	}
	*/
}

dummy_getRealTarget()
{
	return self.realTarget;
}

target_set_isLockedOn( owner )
{
	self._target.weapon[ "raining_missile" ].isLockedOn[ owner GetEntityNumber() ] = true;
}

isDummyTarget( target )
{
	return IsDefined( target.isDummyTarget );
}

hud_markUsed_freeMissileIcon()
{
	item = self.hud[ "missile" ];
	
	if ( !hud_isLockedOnTarget( item ) )
	{
		item SetShader( "apache_missile_icon_lock", 16, 16 );
		item.isLockedOnTarget 	= true;
		item.color 				= RED;
	}
}

hud_isLockedOnTarget( hudItem )
{
	return IsDefined( hudItem.isLockedOnTarget );
}

removeLockedOnTarget( target )
{
	self.target = undefined;
	
	owner = self.owner;

	target target_unset_isLockedOn( owner );
	
	// TODO: need a priority system between weapon systems ... this way a shader
	// or color on the target with be dominant for a particular weapon system
	
	if ( !( target target_isLockedOnByAnyWeaponSystem( owner ) ) )
		Target_SetColor( target, GREEN );
	
	// Update hud
	self hud_markFree_usedMissileIcon();
}

target_isLockedOnByAnyWeaponSystem( owner, entNumOverride )
{
	entNum = undefined;
	
	if ( IsDefined( entNumOverride ) )
		entNum = entNumOverride;
	else
		entNum = owner GetEntityNumber();
	
	foreach ( weaponSystem in self._target.weapon )
		if ( IsDefined( weaponSystem.isLockedOn[ entNum ] ) )
			return true;
	return false;
}

target_unset_isLockedOn( owner, entNumOverride )
{
	entNum = undefined;
	
	if ( IsDefined( entNumOverride ) )
		entNum = entNumOverride;
	else
		entNum = owner GetEntityNumber();
	
	if ( IsDefined( self._target ) )
		self._target.weapon[ "raining_missile" ].isLockedOn[ entNum ] = undefined;
}

hud_markFree_usedMissileIcon()
{
	item = self.hud[ "missile" ];
	
	if ( hud_isLockedOnTarget( item ) )
	{
		item.isLockedOnTarget 	= undefined;
		item.color 				= GREEN;
	}
}

SPAWN_OFFSET_Z 		= -160;
SPAWN_OFFSET_FWD 	= 10;
DELAY_TO_LOCK		= 0.05;
DIST_TO_LOCK		= 10000;
DUMMY_DIST			= 6000;

_fire()
{
	owner = self.owner;
	
	if ( !( self hasAmmoForTargets() ) )
		return;
	
	//owner stop_loop_sound_on_entity( "heli_missile_locking" );
	//owner thread play_sound_on_entity( "heli_missile_locked" );
		
	// If no locked on targets, spawn dummy targets ahead of the player
	
	dummyTarget = undefined;
	
	if ( !IsDefined( self.target ) )
	{
		angles 	= owner GetPlayerAngles();
		fwd 	= AnglesToForward( angles );
			
		dummyTarget = Spawn( "script_model", owner GetEye() + DUMMY_DIST * fwd );
		dummyTarget SetModel( "tag_origin" );
		dummyTarget.isDummyTarget = true;
		
		self addLockedOnTarget( dummyTarget );
	}
	
	if ( !isDummyTarget( self.target ) )
	{
		dummyTarget = Spawn( "script_model", self.target.origin );
		dummyTarget SetModel( "tag_origin" );
		dummyTarget LinkTo( self.target );
		dummyTarget.isDummyTarget 	= true;
	}
	
	self hud_makeNotAvailable_availableMissileIcon();	
		
	// Shoot the missile slightly offset from our target so we can see the missile curve more
	// TODO: change this to two missile spawn technique. Jav is weird. so I need to spawn and set it immediately
	
	start 		= owner GetEye() + ( 0,0, SPAWN_OFFSET_Z );
	angles 		= owner GetPlayerAngles();
	end 		= start + SPAWN_OFFSET_FWD * AnglesToForward( angles );
	
	missile 		= MagicBullet( "apache_lockon_raining_missile_phase_2", start, end, owner );
	missile.owner 	= owner;
	
	// Scale delay based on distance to target
	
	delay 		= ( DELAY_TO_LOCK / DIST_TO_LOCK ) * Distance( start, self.target.origin );

	if ( delay < 0.05 )
		missile missile_setTargetAndFlightMode( dummyTarget, "top" );
	else
		missile delaythread( delay, ::missile_setTargetAndFlightMode, dummyTarget, "top" );
	
	self thread deployRainingMissiles( missile, dummyTarget, self.target );
	
	owner PlayRumbleOnEntity( "heavygun_fire" );
	Earthquake( 0.3, 0.6, owner.origin, 5000 );
	
	self.target thread target_monitorFreeLockedOn( owner, missile, dummyTarget );
}

hud_makeNotAvailable_availableMissileIcon()
{
	item = self.hud[ "missile" ];
	
	if ( IsDefined( item.isAvailable ) )
	{
		item.isAvailable 	= undefined;
		item.alpha			= 0;
	}
}

_UP 	= ( 0, 0, 1 );
_DOWN 	= ( 0, 0, -1 );
_BACK	= ( -1, 0, 0 );

COS_45	= 0.70710678; //Cos( 45 );

SECONDARY_AMMO 					= 16;
SECONDARY_SPAWN_MIN_RADIUS 		= 256;
SECONDARY_SPAWN_MAX_RADIUS		= 292;
SECONDARY_LOCK_MIN_RADIUS		= 5120;
SECONDARY_LOCK_MAX_RADIUS		= 6400;
SECONDARY_DEST_MAX_RADIUS		= 640;
SECONDARY_SPAWN_MIN_DELAY		= 0;
SECONDARY_SPAWN_MAX_DELAY 		= 0.5;
SECONDARY_MIN_DELAY_TO_LOCK		= 0.5;
SECONDARY_MAX_DELAY_TO_LOCK		= 4;
SECONDARY_SPAWN_RADIAL_SPREAD 	= 3;
SECONDARY_DEST_LOCK_OFFSET_Z	= -256;
SPAWN_RAINING_MISSILE_HEIGHT	= 2048;

deployRainingMissiles( missile, dummyTarget, realTarget )
{
	Assert( IsDefined( missile ) );
	Assert( IsDefined( dummyTarget ) );
	Assert( IsDefined( realTarget ) );
		
	range = SPAWN_RAINING_MISSILE_HEIGHT;
	
	missile thread missile_trackRealTarget( realTarget );
	
	waittill_ent_moving_dir_world_relative( missile, _UP, COS_45 );
	if ( IsDefined( missile ) )
		waittill_ent_moving_dir_world_relative( missile, _DOWN );
	if ( IsDefined( missile ) )
		waittill_ent1_in_z_range_of_ent2( missile, dummyTarget, range );
	
	if ( !IsDefined( missile ) )
		return;
	
	origin 				= missile.origin;
	angles 				= missile.angles;
	realTargetOrigin 	= missile.realTargetOrigin;
	owner = missile.owner;
	missile Delete();
	
	fwd = AnglesToForward( angles );
	
	PlayFX( getfx( "FX_apache_raining_missile_spawn" ), origin, -1 * fwd );
	owner PlayRumbleOnEntity( "heavygun_fire" );
	Earthquake( 0.2, 0.4, owner.origin, 5000 );
	
	// Spawn Raining Missiles
	
	n 		= _UP; //VectorNormalize( p2.origin - p1.origin );
	angles 	= VectorToAngles( n );
	up 		= AnglesToUp( angles );
	vcross 	= VectorCross( n, up );
	
	sides 		= SECONDARY_AMMO;
	angleFrac 	= 360 / sides;
	cosA 		= [];
	sinA		= [];
	
	// Spawn Radius
	
	r1Points 	= [];
	
	for ( i = 0; i < sides; i++ )
	{
		r			= RandomFloatRange( SECONDARY_SPAWN_MIN_RADIUS, SECONDARY_SPAWN_MAX_RADIUS );
		angleSpread = RandomFloatRange( -1 * SECONDARY_SPAWN_RADIAL_SPREAD, SECONDARY_SPAWN_RADIAL_SPREAD );
		cosA[ i ] 	= Cos( angleFrac * i + angleSpread );
		sinA[ i ] 	= Sin( angleFrac * i + angleSpread );
		
		r1Points[ i ] = origin + r * cosA[ i ] * up + r * sinA[ i ] * vcross;
	}
	
	// Destination before Locking Radius
	
	r2Points	= [];
	offsetZ		= SECONDARY_DEST_LOCK_OFFSET_Z;
	
	for ( i = 0; i < sides; i++ )
	{
		r 				= RandomFloatRange( SECONDARY_LOCK_MIN_RADIUS, SECONDARY_LOCK_MAX_RADIUS );
		r2Points[ i ] 	= origin + ( 0, 0, offsetZ ) + r * cosA[ i ] * up + r * sinA[ i ] * vcross;
	}
	
	// Destination
	
	dPoints	= [];
	origin	= realTargetOrigin;
	
	for ( i = 0; i < sides; i++ )
	{
		r 				= RandomFloatRange( 0, SECONDARY_DEST_MAX_RADIUS );
		dPoints[ i ]	= origin + r * cosA[ i ] * up + r * sinA[ i ] * vcross;
	}
	
	// Randomize the locations with an index array ( want to maintain a 1-1 relationship between the arrays )
	
	indices = [];
	
	for ( i = 0; i < sides; i ++ )
		indices[ i ] = i;
	
	indices = array_randomize( indices );
	
	for ( i = 0; i < sides; i++ )
	{
		delayToSpawn 	= RandomFloatRange( SECONDARY_SPAWN_MIN_DELAY, SECONDARY_SPAWN_MAX_DELAY );
		delayToLock		= RandomFloatRange( SECONDARY_MIN_DELAY_TO_LOCK, SECONDARY_MAX_DELAY_TO_LOCK );
		
		index 	= indices[ i ];

		target = Spawn( "script_model", dPoints[ i ] );
		target SetModel( "tag_origin" );
		
		thread missile_spawnAndLockOnToTarget( delayToSpawn, r1Points[ index ], r2Points[ index ], owner, delayToLock, target );
	}
}

missile_trackRealTarget( realTarget )
{
	self endon( "death" );
	
	for ( ; IsDefined( realTarget ); wait 0.05 )
		self.realTargetOrigin = realTarget.origin;
}

missile_spawnAndLockOnToTarget( delayToSpawn, start, end, owner, delayToLock, target )
{
	if ( delayToSpawn > 0.05 )
		wait delayToSpawn;
	
	missile 		= MagicBullet( "apache_raining_missile", start, end, owner );
	missile.owner 	= owner;
	
	//missile delayThread( delayToLock, ::missile_setTargetAndFlightMode, target, "direct" );
	missile missile_setTargetAndFlightMode( target, "direct" );
	missile thread missile_onDeathDeleteTarget( target );
}

missile_onDeathDeleteTarget( target )
{
	owner = self.owner;
	self waittill( "death" );
	target Delete();
	
	owner PlayRumbleOnEntity( "heavygun_fire" );
	Earthquake( 0.15, 0.3, owner.origin, 5000 );
}

waittill_ent_moving_dir_world_relative( ent, dir, dot )
{
	Assert( IsDefined( ent ) );
	Assert( IsDefined( dir ) );
	
	if ( !IsDefined( dot ) )
		dot = 0;
	
	ent endon( "death" );
	
	lastPos = ent.origin;
	
	for ( ; ; )
	{
		wait 0.05;
		
		if ( !IsDefined( ent ) )
			return;
		v = VectorNormalize( ent.origin - lastPos );
		
		if ( VectorDot( dir, v ) > 0 )
			break;
		lastPos = ent.origin;
	}
}

target_monitorFreeLockedOn( owner, missile, dummyTarget )
{
	Assert( IsDefined( owner ) );
	Assert( IsDefined( missile ) );
	Assert( IsDefined( dummyTarget ) );
	
	entNum = owner GetEntityNumber();
		
	missile waittill( "death" );
	
	if ( IsDefined( self ) )
	{	
		// Free the target from being locked on. An _onDeath function should handle
		// if the target is valid target anymore
		
		if ( !isDummyTarget( self ) )
		{
			self target_unset_isLockedOn( owner, entNum );
			
			if ( Target_IsTarget( self ) && !( self target_isLockedOnByAnyWeaponSystem( owner, entNum ) ) )
				Target_SetColor( self, GREEN );
		}
	}
	dummyTarget Delete();
}

_end()
{
	owner = self.owner;
	
	owner notify( "LISTEN_end_raining_missile" );
	
	override_array_thread( self.hud, ::set_key, [ 0, "alpha" ] );
}

_destroy()
{
	self _end();
	
	override_array_call( self.hud, ::Destroy );
}

/***********************************/
/************ UTILITY **************/
/***********************************/

set_key( value, key )
{
	if ( !IsDefined( self ) || !IsDefined( key ) )
		return;
    
    switch ( key )
    {
    	case "alpha":
    		self.alpha = value;
    		break; 
    }
}

override_array_thread( ents, process, args )
{
	Assert( IsDefined( ents ) );
	Assert( IsDefined( process ) );
	
	if ( !IsDefined( args ) )
	{
		foreach ( ent in ents )
			if ( IsDefined( ent ) )
				if ( IsDefined( ent ) && IsArray( ent ) )
					override_array_thread( ent, process );
				else
					ent thread [[ process ]]();
		return;
	}
	
	Assert( IsArray( args ) );
				
	switch( args.size )
	{
		case 0:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_thread( ent, process, args );
					else
						ent thread [[ process ]]();
			break;
		case 1:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_thread( ent, process, args );
					else
						ent thread [[ process ]]( args[ 0 ] );
			break;
		case 2:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_thread( ent, process, args );
					else
						ent thread [[ process ]]( args[ 0 ], args[ 1 ] );
			break;
		case 3:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_thread( ent, process, args );
					else
						ent thread [[ process ]]( args[ 0 ], args[ 1 ], args[ 2 ] );
			break;
		case 4:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_thread( ent, process, args );
					else
						ent thread [[ process ]]( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ] );
			break;
		case 5:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_thread( ent, process, args );
					else
						ent thread [[ process ]]( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ] );
			break;
	}
	return;
}

override_array_call( ents, process, args )
{
	Assert( IsDefined( ents ) );
	Assert( IsDefined( process ) );
	
	if ( !IsDefined( args ) )
	{
		foreach ( ent in ents )
			if ( IsDefined( ent ) )
				if ( IsArray( ent ) )
					override_array_call( ent, process );
				else
					ent call [[ process ]]();
		return;
	}
	
	Assert( IsArray( args ) );
				
	switch( args.size )
	{
		case 0:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_call( ent, process, args );
					else
						ent call [[ process ]]();
			break;
		case 1:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_call( ent, process, args );
					else
						ent call [[ process ]]( args[ 0 ] );
			break;
		case 2:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_call( ent, process, args );
					else
						ent call [[ process ]]( args[ 0 ], args[ 1 ] );
			break;
		case 3:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_call( ent, process, args );
					else
						ent call [[ process ]]( args[ 0 ], args[ 1 ], args[ 2 ] );
			break;
		case 4:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_call( ent, process, args );
					else
						ent call [[ process ]]( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ] );
			break;
		case 5:
			foreach ( ent in ents )
				if ( IsDefined( ent ) )
					if ( IsArray( ent ) )
						override_array_call( ent, process, args );
					else
						ent call [[ process ]]( args[ 0 ], args[ 1 ], args[ 2 ], args[ 3 ], args[ 4 ] );
			break;
	}
	return;
}

gt_op( a, b, _default )
{
	if ( IsDefined( a ) && IsDefined( b ) )
		return ter_op( a > b, a, b );
	if ( IsDefined( a ) && !IsDefined( b ) )
		return a;
	if ( !IsDefined( a ) && IsDefined( b ) )
		return b;
	return _default;		
}

waittill_ent1_in_z_range_of_ent2( ent1, ent2, range )
{
	Assert( IsDefined( ent1 ) );
	Assert( IsDefined( ent2 ) );
	
	for( range = gt_op( range, 0 ); dsq_z_ents_gt( ent1, ent2, range ); wait 0.05 ){}
}

dsq_z_ents( a, b )
{
	return LengthSquared( ( 0, 0, a.origin[ 2 ] - b.origin[ 2 ] ) );
}

dsq_z_ents_gt( ent1, ent2, z, _default )
{
	if ( IsDefined( ent1 ) && IsDefined( ent2 ) && IsDefined( z ) )
		return ter_op ( dsq_z_ents( ent1, ent2 ) > Squared( z ), true, false );
	return ( ter_op( IsDefined( _default ), _default, false ) );
}