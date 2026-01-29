#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

_precache()
{
	PreCacheItem( "apache_hydra_missile" );
	PreCacheItem( "apache_lockon_missile" );
	PreCacheItem( "apache_lockon_missile_ai_enemy" );
	
	PreCacheModel( "projectile_javelin_missile" );
	
	PreCacheShader( "apache_targeting_circle" );
	PreCacheShader( "apache_missile_back" );
	PreCacheShader( "apache_missile_back_selected" );
	PreCacheShader( "apache_homing_missile_back" );
	PreCacheShader( "apache_homing_missile_back_selected" );
	PreCacheShader( "apache_btn_missile_xenon" );
	PreCacheShader( "apache_ammo" );
	PreCacheShader( "apache_ammo_lock" );
	PreCacheShader( "apache_target_lock" );
	PreCacheShader( "apache_target_lock_01" );
	PreCacheShader( "apache_target_lock_02" );
	PreCacheShader( "apache_target_lock_03" );
	
	PreCacheRumble( "smg_fire" );
	
	_fx();
	
	/#
		SetDvarIfUninitialized( "apachePlayer_lockOnMissile", 0 );
		//SetDvar( "apachePlayer_lockOnMissile", 1 );
	#/
}

_fx()
{
	add_fx( "FX_apache_missile_flash_view", "vfx/moments/oil_rocks/vfx_apache_player_rocket_flash" );
}

MAX_LOCKING_ON = 2;
MAX_AMMO	   = 2;
MAX_AMMO_STRAIGHT	   = 2;

_init( owner, apache, masterHud )
{
	Assert( IsDefined( owner ) && IsPlayer( owner ) );
	Assert( IsDefined( masterHud ) );
	
	hydra_lockOn_missile = SpawnStruct();
	
	hydra_lockOn_missile.owner						= owner;
	hydra_lockOn_missile.type						= "hydra_lockOn_missile";
	hydra_lockOn_missile.apache						= apache;
	hydra_lockOn_missile.masterHud					= masterHud;
	hydra_lockOn_missile.ammo						= [];
	hydra_lockOn_missile.ammo[ "missile"		  ] = MAX_AMMO;
	hydra_lockOn_missile.ammo[ "missile_straight" ] = MAX_AMMO;

	hydra_lockOn_missile.targets   = [];
	hydra_lockOn_missile.isActive  = undefined;
	hydra_lockOn_missile.side_last = "left";
	
	hydra_lockOn_missile hud_init();
	
	return hydra_lockOn_missile;
}

NAME_AMMO_OFFSET_Y = 76;

MISSILE_SELECTED_ALPHA	 = 1.0;
MISSILE_DESELECTED_ALPHA = 0.05;

hud_init()
{	
	owner	  = self.owner;
	masterHud = self.masterHud;
	
	hud = [];
	
	hud[ "missile_range" ] = owner createClientIcon( "apache_targeting_circle", 256, 256 );
	hud[ "missile_range" ] setPoint( "CENTER", undefined, 0, 0 );
	hud[ "missile_range" ].alpha = 0.0;
	
	hud[ "missile_bg" ] = owner createClientIcon( "apache_missile_back", 64, 32 );
	hud[ "missile_bg" ] setPoint( "CENTER", "CENTER", 180, NAME_AMMO_OFFSET_Y );
	hud[ "missile_bg" ].alpha = MISSILE_DESELECTED_ALPHA;

	hud[ "missile_straight_bg" ] = owner createClientIcon( "apache_missile_back", 64, 32 );
	hud[ "missile_straight_bg" ] setPoint( "CENTER", "CENTER", 180, NAME_AMMO_OFFSET_Y - 35 );
	hud[ "missile_straight_bg" ].alpha = MISSILE_SELECTED_ALPHA;

	// JC-ToDo: Button prompt specific to consoles / pc
	hud[ "missile_btn" ] = owner createClientIcon( "apache_btn_missile_xenon", 48, 32 );
	hud[ "missile_btn" ] setPoint( "TOP", "BOTTOM", 0, -6 );
	hud[ "missile_btn" ].alpha = 1.0;
	hud[ "missile_btn" ] setParent( hud[ "missile_bg" ] );
	
	// Name commented out to test graphic skewing to further sell helmet
//	hud[ "missile_name" ] = owner createClientFontString( "objective", 0.8 );
//	hud[ "missile_name" ] setPoint( "BOTTOM", "TOP", 0, 5 );
//	hud[ "missile_name" ].alpha = 1.0;
//	hud[ "missile_name" ] SetText( "HOMING" );
//	hud[ "missile_name" ] setParent( hud[ "missile_bg" ] );
	
//	hud[ "missile_straight_name" ] = owner createClientFontString( "objective", 0.8 );
//	hud[ "missile_straight_name" ] setPoint( "BOTTOM", "TOP", 0, 5 );
//	hud[ "missile_straight_name" ].alpha = 1.0;
//	hud[ "missile_straight_name" ] SetText( "STRAIGHT" );
//	hud[ "missile_straight_name" ] setParent( hud[ "missile_straight_bg" ] );
	
	hud[ "missile" ] = [];
	
	for ( i = 0; i < MAX_AMMO; i++ )
	{
		item = owner createClientIcon( "apache_ammo", 16, 16 );
		item setPoint( "RIGHT", "CENTER", -5, -4 + i * 8 );
		item.alpha			  = 0.0;
		item.isAvailable	  = true;
		item.isLockedOnTarget = false;
		item setParent( hud[ "missile_bg" ] );
		hud[ "missile" ][ i ] = item;
	}
		
	for ( i = 0; i < MAX_AMMO_STRAIGHT; i++ )
	{
		item = owner createClientIcon( "apache_ammo", 16, 16 );
		item setPoint( "RIGHT", "CENTER", -5, -4 + i * 8 );
		item.alpha			  = 0.0;
		item.isAvailable	  = true;
		item.isLockedOnTarget = false;
		item setParent( hud[ "missile_straight_bg" ] );
		hud[ "missile_straight" ][ i ] = item;
	}
	
	
	self.hud = hud;
}

_start()
{
	owner = self.owner;
	
	owner endon( "LISTEN_end_hydra_lockOn_missile" );
	
	self hud_start();

	owner NotifyOnPlayerCommand( "LISTEN_hydra_lockOn_missile_fire_press"  , "+frag" );
	owner NotifyOnPlayerCommand( "LISTEN_hydra_lockOn_missile_fire_release", "-frag" );

	self.targets = [];
	
	self childthread monitorReload();
	self childthread monitorReload( "missile_straight" );
	
	for ( ;; )
	{
		if ( !IsDefined( self.isActive ) )
		{
			wait 0.05;
			continue;
		}
		
		has_straight_missiles = has_ammo_for_missile( "missile_straight" ) ;
		has_homing_missiles = has_ammo_for_missile( "missile" ) ;
		
		if ( !has_straight_missiles )
			hud_highlight_no_missiles();
		else 
			hud_highlight_straight_missile();
		
		
		if( !has_straight_missiles && !has_homing_missiles )
		{
			wait 0.05;
			continue;
		}
		
		// If the missile button isn't already pressed wait for press
		already_pressed = owner vehicle_scripts\_apache_player_pilot::button_pressed_from_string( "frag" );
		if ( !already_pressed )
			owner waittill( "LISTEN_hydra_lockOn_missile_fire_press" );
		
		self childthread lockOnTargets();
		
		// Handle script missing release notifications because of a paused game or a game save
		owner childthread vehicle_scripts\_apache_player_pilot::player_poll_button_release_and_notify( "frag", "LISTEN_hydra_lockOn_missile_fire_release" );
		
		msg = owner waittill_any_return( "LISTEN_hydra_lockOn_missile_fire_release", "LISTEN_pilot_weaponSwitch" );
		if ( msg == "LISTEN_pilot_weaponSwitch" )
		{
			wait 0.05;
			continue;
		}
		
		// Intentionally not threaded so that firing finishes before
		// ammo is checked above
		self _fire();
		
		self lockOnTargets_stop();
	}
}

has_ammo_for_missile( missile_name )
{
	return ( IsDefined( self.ammo[ missile_name ] ) && self.ammo[ missile_name ] );
}

_fire()
{
	owner = self.owner;
	
	self.targets = array_removeUndefined( self.targets );
	
	if ( self.targets.size )
	{
		self fire_lockOn();
		self hud_highlight_straight_missile();
	}
	else
	{
		if(  self.ammo["missile_straight"] )
			self fire_hydra( false );
	}
}

get_side_next_missile()
{
	if ( !IsDefined( self.side_last ) )
		self.side_last = "left";
	
	self.side_last = ter_op( self.side_last == "left", "right", "left" );
	return self.side_last;
}

ACTIVE_ALPHA   = 1.0;
DEACTIVE_ALPHA = 0.2;

activate()
{
	hud = self.hud;
	
	self.isActive = true;
	
	foreach ( item in hud[ "missile" ] )
	{
		if ( item.isAvailable )
			item.alpha = ACTIVE_ALPHA;
		else
			item.alpha = 0;
	}
	
	foreach ( item in hud[ "missile_straight" ] )
	{
		if ( item.isAvailable )
			item.alpha = ACTIVE_ALPHA;
		else
			item.alpha = 0;
	}
	
//	hud[ "missile_name" ].alpha = ACTIVE_ALPHA;
}

deActivate()
{
	hud = self.hud;
	
	self.isActive = undefined;
	
	foreach ( item in hud[ "missile" ] )
	{
		if ( item.isAvailable )
			item.alpha = DEACTIVE_ALPHA;
		else
			item.alpha = 0;
	}
	
	foreach ( item in hud[ "missile_straight" ] )
	{
		if ( item.isAvailable )
			item.alpha = DEACTIVE_ALPHA;
		else
			item.alpha = 0;
	}
//	hud[ "missile_name" ].alpha = DEACTIVE_ALPHA;
}

RELOAD_INTERVAL	   = 1.5;
RELOAD_SOUND_DELAY = 0.5;

monitorReload( missile_ammo )
{
	if ( !IsDefined( missile_ammo ) )
		missile_ammo = "missile";
	
	owner = self.owner;
	
	while ( 1 )
	{
		// Find empty slot
		empty_slot = false;
		foreach ( item in self.hud[ missile_ammo ] )
		{
			if ( !item.isAvailable )
			{
				empty_slot = true;
				break;
			}
		}
		
		// If empty slot, play sounds and delay, then update ammo slot farthest to the right
		if ( !empty_slot )
		{
			wait 0.05;
			continue;
		}
		wait RELOAD_INTERVAL;
		owner thread play_sound_on_entity( "apache_missile_reload" );
		wait RELOAD_SOUND_DELAY;
		
		for ( i = self.hud[ missile_ammo ].size - 1; i >= 0; i-- )
		{
			item = self.hud[ missile_ammo ][ i ];
			if ( !item.isAvailable )
			{
				self hud_markAvailable_firstUsedMissileIcon( missile_ammo );
				self.ammo[missile_ammo]++;
				hud_highlight_straight_missile();
				break;
			}
		}
	}
}

hud_start()
{
	hud = self.hud;
	
	foreach ( item in hud[ "missile" ] )
	{
		if ( item.isLockedOnTarget )
		{
			item SetShader( "apache_ammo_lock", 16, 16 );
		}
		else
		{
			item SetShader( "apache_ammo", 16, 16 );
		}
			
		if ( item.isAvailable )
			item.alpha = ter_op( IsDefined( self.isActive ), ACTIVE_ALPHA, DEACTIVE_ALPHA );
		else
			item.alpha = 0;
	}
//	hud[ "missile_name" ].alpha = ter_op( IsDefined( self.isActive ), ACTIVE_ALPHA, DEACTIVE_ALPHA );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Targetting Lock On Missiles
//			// JC-ToDo: apache player lock on could use some refactoring. I've bandaided a few times. Here are the issues:
//			//	- targets_tracking is an array indexed by the targets unique id. Makes checking whether something is tracked fast and everything else a pain in the ass
//			//	- The lock on dummy logic and the tracking logic are serperate which leads to frame issues
//			//	- Targets have on death threads which attempt to clean up things and they have polling loops which also do clean up. One should just be picked.
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

MISSILE_LOCKON_MAX_COUNT			 = 2;
MISSILE_LOCKON_DELAY_BEFORE_LOCK	 = 0.15;
MISSILE_LOCKON_TARGET_ACQUIRE_RADIUS = 48;
MISSILE_LOCKON_TARGET_LOST_RADIUS	 = 80;

lockOnTargets()
{
	owner = self.owner;
	
	owner endon( "LISTEN_hydra_lockOn_missile_fire_release" );
	owner endon( "LISTEN_pilot_weaponSwitch" );
	
	self.targets		  = [];
	self.targets_tracking = [];
	
	// A small delay to prevent lock on visuals from showing when the player taps
	wait 0.2;
	
	self.hud[ "missile_range" ].alpha = 1.0;
	
	owner thread play_loop_sound_on_entity( "apache_lockon_missile_locking" );
	
	for ( ;; wait 0.05 )
	{
		
		// Let death notifies clean out targets from tracking and locked
		waittillframeend;
		
		
		// Make sure targets no longer in the target system are cleaned out
		targets_tracking = self.targets_tracking;
		foreach ( target in targets_tracking )
		{
			if ( IsDefined( target ) && !Target_IsTarget( target ) )
			{
				self removeTrackingTarget( target );
			}
		}
		
		targets_locked = self.targets;
		foreach ( target in targets_locked )
		{
			if ( IsDefined( target ) && !Target_IsTarget( target ) )
			{
				self removeLockedOnTarget( target );
			}
		}
		
		// Handle current targets to see if any that are being tracked or locked should
		// be removed because of screen position
		targets = Target_GetArray();
		
		// Check to see if player is looking too far away from locked or tracking targets
		foreach ( target in targets )
		{
			// Ignore targets without a unique_id defined
			if ( !IsDefined( target ) || !IsDefined( target.unique_id ) )
				continue;
			
			// Ignore targets with a missile already tracking
			if ( IsDefined( target.missiles_chasing ) && target.missiles_chasing > 0 )
				continue;
			
			locked	 = target target_isLockedOn( owner );
			tracking = self isTrackingTarget( target );
			
			AssertEx( ( !locked && !tracking ) || locked != tracking, "A target should never be both locked on and being tracked." );
			
			if ( locked || tracking )
			{
				fov = undefined;
				if ( owner ent_flag( "FLAG_apache_pilot_ADS" ) )
				{
					fov = vehicle_scripts\_apache_player_pilot::fov_get_ads();
				}
				else
				{
					fov = vehicle_scripts\_apache_player_pilot::fov_get_default();
				}
				
				if ( !Target_IsInCircle( target, owner, fov, MISSILE_LOCKON_TARGET_LOST_RADIUS )
				     || !target_trace_to_owners_eyes( target, owner )
				     || !target_in_range_for_lock( target, owner )
				    )
				{
					if ( locked )
					{
						self removeLockedOnTarget( target );
					}
					
					if ( tracking )
					{
						self removeTrackingTarget( target );
					}
				}
			}
		}
		
		// Search for targets to track or lock onto existing target
		
		if ( self hasAmmoForLockOnTarget() )
		{
			// If a target is being tracked check to see if this target should be locked on to
			if ( getTrackingTargetCount() > 0 )
			{
				// Array is indexed by target id, foreach is the only way to get it :-/
				target_curr = undefined;
				foreach ( target in self.targets_tracking )
				{
					if ( !IsAlive( target ) )
						continue;
					target_curr = target;
					break;
				}
				
				// If the target has been tracked long enough, lock
				//adding isdefined( target_curr ) - lazily -nate
				if ( IsDefined( target_curr ) && GetTime() - target_curr.tracking_time_start >= MISSILE_LOCKON_DELAY_BEFORE_LOCK * 1000 )
				{
					self removeTrackingTarget( target_curr, false );
					self addLockedOnTarget( target_curr );
				}
			}
			else
			{
				track_options = targets;
				track_options = array_remove_array( track_options, self.targets );
				
				foreach ( target in targets )
				{
					if ( IsDefined( target.missiles_chasing ) && target.missiles_chasing > 0 )
						continue;
					
					track_options[ track_options.size ] = target;
				}
				
				track_options = targetsFilter( owner, track_options );
				track_options = targetsSortByDot( track_options, owner GetEye(), owner GetPlayerAngles() );
//				track_options	= SortByDistance( track_options, owner GetEye() );
				
				// Only track 1 thing at ag time
				if ( IsDefined( track_options[ 0 ] ) )
				{
					self addTrackingTarget( track_options[ 0 ], MISSILE_LOCKON_DELAY_BEFORE_LOCK );
				}
			}
		}
		if( self.targets.size )
			hud_highlight_homing_missile();
		else
			hud_highlight_straight_missile();
	}
}

target_trace_to_owners_eyes( target, owner )
{
	if ( !IsDefined( target.target_trace_to_owners_eyes ) )
		target.target_trace_to_owners_eyes = GetTime();
	
	if( GetTime() - target.target_trace_to_owners_eyes < 750 )
		return true;
	
	eyepos	  = owner GetEye();
	targetOrg = target GetCentroid();
	traceOrg  = VectorNormalize( targetOrg - eyepos );
	traceOrg *= 500;
	traceOrg += eyepos;
	
	bullet_trace = BulletTrace( traceOrg, targetOrg, false, owner.riding_vehicle );
	success  =   bullet_trace[ "fraction" ] == 1
		|| ( IsDefined( bullet_trace[ "entity" ] ) && bullet_trace[ "entity" ] == target );
	
	if( success )
		target.target_trace_to_owners_eyes = GetTime();
	
	return success;
}

target_in_range_for_lock( target, owner )
{
	return DistanceSquared( owner GetEye(), target GetCentroid() ) < level.apache_player_difficulty.in_range_for_homing_missile_sqrd;
}

lockOnTargets_stop()
{
	owner = self.owner;
	
	owner stop_loop_sound_on_entity( "apache_lockon_missile_locking" );
	self.hud[ "missile_range" ].alpha = 0;
	
	// Clear locked on targets that do not have a missile after them	
	foreach ( target in self.targets )
	{
		// Ignore removed entities
		if ( !IsDefined( target ) )
			continue;
		
		if ( target target_isLockedOn( owner ) && ( !IsDefined( target.missiles_chasing ) || target.missiles_chasing <= 0 ) )
		{
			self removeLockedOnTarget( target );
		}
	}
	
	// Clean up targets that were being tracked
	foreach ( target in self.targets_tracking )
	{
		// Ignore removed entities
		if ( !IsDefined( target ) )
			continue;
		
		removeTrackingTarget( target );
	}

	self.targets		  = [];
	self.targets_tracking = [];
}

targetsFilter( owner, array )
{
	Assert( IsDefined( owner ) && IsPlayer( owner ) );
	Assert( IsDefined( array ) && IsArray( array ) );
	
	_array = [];
	
	fov = undefined;
	if ( owner ent_flag( "FLAG_apache_pilot_ADS" ) )
	{
		fov = vehicle_scripts\_apache_player_pilot::fov_get_ads();
	}
	else
	{
		fov = vehicle_scripts\_apache_player_pilot::fov_get_default();
	}
	
	foreach ( item in array )
	{
		if (
				item IsVehicle()
			&&	!onSameTeam( owner, item )
			&&	!( item target_isLockedOn( owner ) )
			&&	Target_IsInCircle( item, owner, fov, MISSILE_LOCKON_TARGET_ACQUIRE_RADIUS )
			 )
		{
			_array[ _array.size ] = item;
		}
	}
	
	return _array;
}

onSameTeam( ent1, ent2 )
{
	Assert( IsDefined( ent1 ) );
	Assert( IsDefined( ent2 ) );
	
	return ( ent1 getTeam() == ent2 getTeam() );
}

getTeam()
{
	if ( isTurret( self ) && IsDefined( self.script_team ) )
		return self.script_team;
	if ( self IsVehicle() && IsDefined( self.script_team ) )
		return self.script_team;
	if ( IsDefined( self.team ) )
		return self.team;
	return "none";
}

isTurret( obj )
{
	return ( IsDefined( obj ) && IsDefined( obj.classname ) && IsSubStr( obj.classname, "turret" ) );
}

onTeam( team )
{
	Assert( IsDefined( team ) );
	
	if ( self IsVehicle() )
		return ( IsDefined( self.script_team ) && self.script_team == team );
	else
		return( IsDefined( self.team ) && self.team == team );
	return false;
}

hud_flashAlpha( initialAlpha, fadeTime, waitTime )
{
	Assert( IsDefined( initialAlpha ) );
	Assert( IsDefined( fadeTime ) );
	
	self.alpha = initialAlpha;
	
	for ( ;; )
	{
		self FadeOverTime( fadeTime );
		self.alpha = 0;
		wait fadeTime;
		
		if ( IsDefined( waitTime ) && waitTime > 0 )
			wait waitTime;
		
		self FadeOverTime( fadeTime );
		self.alpha = initialAlpha;
		wait fadeTime;
	}
}

target_isLockedOn( owner )
{
	if ( IsDefined( self._target ) )
		return IsDefined( self._target.weapon[ "lockOn_missile" ].isLockedOn[ owner GetEntityNumber() ] );
	else
		return false;
}

isLockedOnTarget( target )
{
	return array_contains( self.targets, target );
}

isTrackingTarget( target )
{
	return IsDefined( self.targets_tracking ) && IsDefined( self.targets_tracking[ target.unique_id ] );
}

getTrackingTargetCount()
{
	return ter_op( IsDefined( self.targets_tracking ) && self.targets_tracking.size, self.targets_tracking.size, 0 );
}

hasAmmoForLockOnTarget()
{	
	return min( MISSILE_LOCKON_MAX_COUNT, self.ammo["missile"] ) - self.targets.size > 0;
}

addLockedOnTarget( target )
{
	owner		 = self.owner;
	self.targets = array_add( self.targets, target );
	
	if ( !isDummyTarget( target ) )
	{
		target target_set_isLockedOn( owner );
		if ( Target_IsTarget( target ) )
		{
			vehicle_scripts\_apache_player::hud_set_target_locked( target );
		}
	}
	
	if ( !IsDefined( target.lock_dummy ) )
	{
		self lock_dummy_add( target );
	}
	
	// Update visuals and sound
	self thread addLockedOnTarget_update( target );
	
	// Update hud
	self hud_markLocked_firstAvailableMissileIcon( "missile" );
	
	// Do lock on sounds
	
	if ( !isDummyTarget( target ) )
	{
		owner thread play_sound_on_entity( "apache_lockon_missile_locked" );
	}
	
	if ( target isVehicle() )
	{
		target.request_move = true; // make choppter boss squeemish.
	}
	
}

addLockedOnTarget_update( target )
{
	self.owner endon( "LISTEN_end_hydra_lockOn_missile" );
	
	Assert( IsDefined( target ) );
	
	target endon( "death" );
	target endon( "lock_dummy_remove" );
	
	Target_SetShader( target.lock_dummy, "apache_target_lock" );
	Target_DrawSquare( target.lock_dummy, 200 );
	Target_SetMinSize( target.lock_dummy, 48, false );
	Target_SetMaxSize( target.lock_dummy, 96 );
	Target_ShowToPlayer( target.lock_dummy, self.owner );
	
	while ( 1 )
	{
		Target_ShowToPlayer( target.lock_dummy, self.owner );
		wait 0.1;
		Target_HideFromPlayer( target.lock_dummy, self.owner );
		wait 0.05;
	}
}

target_set_isLockedOn( owner )
{
	if ( IsDefined( self._target ) )
		self._target.weapon[ "lockOn_missile" ].isLockedOn[ owner GetEntityNumber() ] = true;
}

isDummyTarget( target )
{
	return IsDefined( target.isDummyTarget );
}

removeLockedOnTarget( target )
{
	if ( self isLockedOnTarget( target ) )
		self.targets = array_remove( self.targets, target );
	
	owner = self.owner;

	target target_unset_isLockedOn( owner );
	
	if ( Target_IsTarget( target ) )
	{
		vehicle_scripts\_apache_player::hud_set_target_default( target );
	}
	
	self lock_dummy_remove( target );
	
	// Update hud
	self hud_markUnlocked_firstLockedMissileIcon( false, "missile" );
}

target_unset_isLockedOn( owner )
{
	if ( IsDefined( self._target ) )
		self._target.weapon[ "lockOn_missile" ].isLockedOn[ owner GetEntityNumber() ] = undefined;
}

hud_markUnlocked_firstLockedMissileIcon( use, missile_ammo )
{
	Assert( IsDefined( missile_ammo ) );

	unlocked = false;
	
	for ( i = self.hud[ missile_ammo ].size - 1; i >= 0; i-- )
	{
		item = self.hud[ missile_ammo ][ i ];
		
		if ( item.isLockedOnTarget )
		{
			item SetShader( "apache_ammo", 16, 16 );
			item.isLockedOnTarget	= false;
			
			if ( IsDefined( use ) && use )
			{
				item.isAvailable = false;
				item.alpha		 = 0;
			}
			
			unlocked = true;
			
			break;
		}
	}
	
	return unlocked;
}

hud_markLocked_firstAvailableMissileIcon( missile_ammo )
{
	Assert( IsDefined( missile_ammo ) );
	
	locked = false;
	
	for ( i = self.hud[ missile_ammo ].size - 1; i >= 0; i-- )
	{
		item = self.hud[ missile_ammo ][ i ];
		
		if ( item.isAvailable && !item.isLockedOnTarget )
		{
			item SetShader( "apache_ammo_lock", 16, 16 );
			item.isLockedOnTarget	= true;
			
			locked = true;
			
			break;
		}
	}
	
	if( locked ) 
	{
		hud_highlight_homing_missile();
	}
	else
	{
		hud_highlight_straight_missile();
	}
	
	return locked;
}

hud_highlight_homing_missile()
{
	self.hud[ "missile_straight_bg" ] SetShader( "apache_missile_back"		   , 64, 32 );
	self.hud[ "missile_bg"			] SetShader( "apache_homing_missile_back_selected", 64, 32 );
}

hud_highlight_straight_missile()
{
	if ( ! has_ammo_for_missile( "missile_straight" ) )
		return;
	self.hud[ "missile_straight_bg" ] SetShader( "apache_missile_back_selected", 64, 32 );
	self.hud[ "missile_bg"			] SetShader( "apache_homing_missile_back"  , 64, 32 );
}

hud_highlight_no_missiles()
{
	self.hud[ "missile_straight_bg" ] SetShader( "apache_missile_back", 64, 32 );
	self.hud[ "missile_bg"			] SetShader( "apache_homing_missile_back", 64, 32 );
}

hud_markUsed_firstAvailableMissileIcon(missile_ammo)
{
	Assert( IsDefined( missile_ammo ) );
	
	for ( i = self.hud[missile_ammo].size - 1; i >= 0; i-- )
	{
		item = self.hud[ missile_ammo ][ i ];
		
		if ( item.isAvailable )
		{
			item.isAvailable = false;
			item.alpha		 = 0;
			break;
		}
	}
	
}

hud_markAvailable_firstUsedMissileIcon(missile_ammo)
{
	Assert( IsDefined( missile_ammo ) );
	
	for ( i = self.hud[ missile_ammo ].size - 1; i >= 0; i-- )
	{
		item = self.hud[ missile_ammo ][ i ];
		
		if ( !item.isAvailable )
		{
			item SetShader( "apache_ammo", 16, 16 );
			item.alpha			  = ter_op( IsDefined( self.isActive ), ACTIVE_ALPHA, DEACTIVE_ALPHA );
			item.isAvailable	  = true;
			item.isLockedOnTarget = false;
			break;
		}
	}
}

addTrackingTarget( target, locking_time )
{
	AssertEx( IsAlive( target ), "shouldn't be finding dead or removed targets!" );
	AssertEx( !self isTrackingTarget( target ), "Adding tracking on a target that's already being tracked." );
	
	target.tracking_time_start				  = GetTime();
	self.targets_tracking[ target.unique_id ] = target;
	
	// Add waypoint shader to be cycled
	self lock_dummy_add( target );
	
	// Visuals and sounds
	self thread addTrackingTarget_update( target, locking_time );
	self thread addTrackingTarget_onDeath( target );
}

addTrackingTarget_update( target, locking_time )
{
	self.owner endon( "LISTEN_end_hydra_lockOn_missile" );
	
	target endon( "removeTrackingTarget" );
	target endon( "death" );
	
	wait 0.05;
	
	Target_ShowToPlayer( target.lock_dummy, self.owner );
	
	shaders = [ "apache_target_lock_01", "apache_target_lock_02", "apache_target_lock_03" ];
	mins	= [ 128					   , 96						, 64 ];
	maxes	= [ 192					   , 160					, 128 ];
	
	for ( i = 0; i < shaders.size; i++ )
	{
		Target_SetShader( target.lock_dummy, shaders[ i ] );
		Target_DrawSquare( target.lock_dummy, 200 );
		Target_SetMinSize( target.lock_dummy, mins[ i ], false );
		Target_SetMaxSize( target.lock_dummy, maxes[ i ] );
		
		wait locking_time / 3.0;
	}
}

addTrackingTarget_onDeath( target )
{
	target endon( "removeTrackingTarget" );
	
	self waittill( "death" );
	
	self removeTrackingTarget( target );
}

lock_dummy_add_onDeath( target )
{
	target endon( "lock_dummy_remove" );
	
	target waittill( "death" );
	
	lock_dummy_remove( target );
}

lock_dummy_add( target )
{
	AssertEx( !IsDefined( target.lock_dummy ), "lock_dummy_add() called on target with already defined lock_dummy reference." );
	
	// JC-ToDo: This dupes logic from _apache_player_targeting(), ideally this would be refactored to have all these settings in one place.
	offset = ( 0, 0, 64 );
	if ( target isHelicopter() )
	{
		offset = ( 0, 0, -72 );
	}
	
	target.lock_dummy = target spawn_tag_origin();
	// JC-ToDo: Tag origin model doesn't have a model so the radius logic doesn't work in the target system. Set to FX for now.
	target.lock_dummy SetModel( "fx" ); // For some reason calls to Target_DrawSquare() with a script model set to the tag_origin causes it not to draw - bugged
	
	target.lock_dummy LinkTo( target, "tag_origin", ( 0, 0, 0 ), target.angles );
	
	Target_Alloc( target.lock_dummy, offset );
	
	Target_SetShader( target.lock_dummy, "apache_target_lock" );
	Target_SetScaledRenderMode( target.lock_dummy, false );
	Target_DrawSingle( target.lock_dummy );
	
	Target_Flush( target.lock_dummy );
	
	Target_ShowToPlayer( target.lock_dummy, self.owner );
	
	// Catch clean up on death
	self thread lock_dummy_add_onDeath( target );
}

lock_dummy_remove( target )
{
	// The lock_dummy reference may have been already 
	// removed in _onDeath func
	if ( IsDefined( target.lock_dummy ) )
	{
		Target_Remove( target.lock_dummy );
		
		target.lock_dummy Delete();
		
		// Remove shader before notify in case
		// notify would kill this thread
		target notify( "lock_dummy_remove" );
	}
}

removeTrackingTarget( target, remove_dummy )
{
	remove_dummy = ter_op( IsDefined( remove_dummy ), remove_dummy, true );
	
	if ( self isTrackingTarget( target ) )
	{
		target.tracking_time_start				  = undefined;
		self.targets_tracking[ target.unique_id ] = undefined;
		
		remove_targets_tracking_undefined();
		
		if ( remove_dummy )
		{
			lock_dummy_remove( target );
		}
		
		target notify( "removeTrackingTarget" );
	}
}

remove_targets_tracking_undefined()
{
	targets_scrub = [];
	foreach ( idx, target in self.targets_tracking )
	{
		if ( IsDefined( target ) )
		{
			targets_scrub[ idx ] = target;
		}
	}
	
	self.targets_tracking = targets_scrub;
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Fire Lock On Missiles
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

MISSILE_LOCKON_FIRE_INTERVAL	= 0.15;
MISSILE_LOCKON_SPAWN_OFFSET_FWD = 60;
MISSILE_LOCKON_END_OFFSET_FWD	= 60;

fire_lockOn()
{
	AssertEx( self.targets.size, "fire_lockOn() should never be called with zero targets" );
	
	owner  = self.owner;
	apache = self.apache;
	
	idx_target = 0;
	
	ammo_to_fire = Int( min( min( MISSILE_LOCKON_MAX_COUNT, self.ammo["missile"] ), self.targets.size ) );
	
	AssertEx( self.targets.size <= ammo_to_fire, "There should never be more locked on targets than the min between MISSILE_LOCKON_MAX_COUNT and self.ammo" );
	
	fx_flash = getfx( "FX_apache_missile_flash_view" );
	
	while ( ammo_to_fire > 0 )
	{
		target = self.targets[ idx_target ];
		
		angles	= owner GetPlayerAngles();
		side	= self get_side_next_missile();
		sign	= ter_op( side == "right", 1, -1 );
		tag	  = ter_op( side == "right", "tag_homing_rocket_right", "tag_homing_rocket_left" );
		start = apache GetTagOrigin( tag );
		fwd	  = AnglesToForward( angles );
		
		missile				 = MagicBullet( "apache_lockon_missile", start + MISSILE_LOCKON_SPAWN_OFFSET_FWD * fwd, start + ( MISSILE_LOCKON_SPAWN_OFFSET_FWD + MISSILE_LOCKON_END_OFFSET_FWD ) * fwd, owner );
		missile.owner		 = owner;
		missile.type_missile = "guided";
		
		target notify( "LISTEN_missile_fire", missile );
		level notify( "LISTEN_apache_player_missile_fire", missile );
		
		// Move flash fx forward 10 ft so it's more visible
		PlayFX( fx_flash, start + fwd * 120, fwd );
		
		missile delayThread( 0.1, ::passive_missile_setTargetAndFlightMode, target, "direct" );
		
		owner PlayRumbleOnEntity( "heavygun_fire" );
		Earthquake( 0.3, 0.6, owner.origin, 5000 );
		
		missile thread vehicle_scripts\_chopper_missile_defense_utility::missile_monitorMissTarget( target, false, undefined, "LISTEN_missile_missed_target", "LISTEN_missile_attached_to_flare" );
		target thread target_monitorFreeLockedOn( owner, missile );
		
		if ( !self hud_markUnlocked_firstLockedMissileIcon( true, "missile" ) )
		{
			self hud_markUsed_firstAvailableMissileIcon( "missile" );
		}
		owner.last_lockon_fire_time = GetTime();

		self.ammo["missile"]--;
		ammo_to_fire--;
		
		idx_target++;
		if ( idx_target >= self.targets.size )
		{
			idx_target = 0;
		}
		
		if ( ammo_to_fire > 0 )
		{
			wait MISSILE_LOCKON_FIRE_INTERVAL;
		}
	}
}

passive_missile_setTargetAndFlightMode(target, mode )
{
	if ( !IsDefined( target ) )
		return;
	missile_setTargetAndFlightMode( target, mode );
}

target_monitorFreeLockedOn( owner, missile )
{
	Assert( IsDefined( owner ) );
	Assert( IsDefined( missile ) );
	
	self endon( "death" );
	
	if ( !IsDefined( self.missiles_chasing ) )
		self.missiles_chasing = 0;
	
	self.missiles_chasing++;
	
	entNum = owner GetEntityNumber();
	
	missile waittill_any( "death", "LISTEN_missile_attached_to_flare", "LISTEN_missile_missed_target" );
	
	if ( !IsDefined( self ) )
		return;
	
	self.missiles_chasing--;
	
	if ( self.missiles_chasing <= 0 )
	{
		// Check to see if the target was a dummy target
		
		if ( isDummyTarget( self ) )
		{
			self Delete();
			return;
		}
		
		// Free the target from being locked on. An _onDeath function should handle
		// if the target is valid target anymore
		
		if ( IsDefined( owner ) )
			self target_unset_isLockedOn( owner );
		
		if ( IsDefined( self.lock_dummy ) )
		{
			lock_dummy_remove( self );
			if ( Target_IsTarget( self ) )
			{
				vehicle_scripts\_apache_player::hud_set_target_default( self );
			}
		}
	}
}

ownerIsInHeli()
{
	return IsDefined( self.owner.heli );
}

fireMissile( model, trail_fx, speed, trace_length, life_time, start, end )
{
	Assert( IsDefined( model ) );
	Assert( IsDefined( trail_fx ) );
	Assert( IsDefined( speed ) );
	Assert( IsDefined( trace_length ) );
	Assert( IsDefined( life_time ) );
	Assert( IsDefined( start ) );
	Assert( IsDefined( end ) );
	
	missile		   = Spawn( "script_model", start );
	missile.angles = VectorToAngles( end - start );
	missile SetModel( model );
	PlayFXOnTag( getfx( trail_fx ), missile, "tag_fx" );
	
	missile.life_time	 = life_time;
	missile.speed		 = speed;
	missile.trace_length = trace_length;
	
	missile thread missile_move_fireMissile();
	
	return missile;
}

missile_move_fireMissile()
{
	self endon( "death" );
	
	for ( ;; self.life_time -= 0.05 )
	{
		fwd	   = AnglesToForward( self.angles );
		origin = self.origin;
		
		if ( !IsDefined( self.homing ) )
			self MoveTo( origin + 0.1 * self.speed * fwd, 0.1 );
	
		passed	= BulletTracePassed( origin, origin + self.trace_length * fwd, true, self );
		
		if ( self.life_time <= 0 )
		{
			self Delete();
			return;
		}
		
		if ( !passed )
		{
			//PlayFX( exp_fx, missile.origin, -1 * AnglesToForward( angles ) );
			
			owner = level;
			if ( IsDefined( self.owner ) )
				owner = self.owner;
			RadiusDamage( self.origin, 512, 4000, 1000, owner, "MOD_EXPLOSIVE" );
				
			self Delete();
			return;
		}
		wait 0.05;
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Fire Hydra Missiles
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

MISSILE_HYDRA_MAX_COUNT				   = 2;
MISSILE_HYDRA_YAW_SPREAD			   = 0.0;
MISSILE_HYDRA_PITCH_SPREAD			   = 0.0;
MISSILE_HYDRA_FX_SPAWN_OFFSET_FWD	   = 120;
MISSILE_HYDRA_SPAWN_OFFSET_FWD		   = 0;
MISSILE_HYDRA_SPAWN_OFFSET_UP_RANGE	   = 14;
MISSILE_HYDRA_SPAWN_OFFSET_RIGHT_RANGE = 14;
MISSILE_HYDRA_IMPACT_DIST_MAX		   = 15000;
MISSILE_HYDRA_IMPACT_DIST_MIN		   = 1000;
MISSILE_HYDRA_IMPACT_OFFSET_RIGHT	   = 48;
MISSILE_HYDRA_FIRE_INTERVAL			   = 0.1;

fire_hydra( one_hud_item_for_all )
{
	owner  = self.owner;
	apache = self.apache;
	hud	   = self.hud;
	
	// Fire the missiles
	
	ammo_to_fire = undefined;
	if ( !one_hud_item_for_all )
		ammo_to_fire = Int( min( MISSILE_HYDRA_MAX_COUNT, self.ammo["missile_straight"] ) );
	else
		ammo_to_fire = MISSILE_HYDRA_MAX_COUNT;
	
	fx_flash = getfx( "FX_apache_missile_flash_view" );
	
	// Initial trace to get an accurate intentional impact point
	// so that the missiles know what location to move towards.
	eye_pos		 = owner GetEye();
	eye_fwd		 = AnglesToForward( owner GetPlayerAngles() );
	eye_trace	 = BulletTrace( eye_pos + eye_fwd * 360, eye_pos + eye_fwd * MISSILE_HYDRA_IMPACT_DIST_MAX, false, apache );
	eye_end_dist = max( MISSILE_HYDRA_IMPACT_DIST_MIN, eye_trace[ "fraction" ] * MISSILE_HYDRA_IMPACT_DIST_MAX );
	
	// Do earthquake before firing because firing is so fast
	Earthquake( 0.15, ammo_to_fire * MISSILE_HYDRA_FIRE_INTERVAL + 0.5, owner.origin, 5000 );
	
	for ( i = 0; i < ammo_to_fire; i++ )
	{
		// Alternate fire between left and right
		// -- even = 1, right : odd = -1, left
		
		side	= get_side_next_missile();
		sign	= ter_op( side == "right", 1, -1 );
		tag		   = ter_op( side == "right", "tag_straight_rocket_right", "tag_straight_rocket_left" );
		eyePos	   = owner GetEye();
		yaw_flat   = flat_angle_yaw( apache.angles );
		fwd_flat   = AnglesToForward( yaw_flat );
		right_flat = AnglesToRight( yaw_flat );
		up_flat	   = AnglesToUp( yaw_flat );
		
		rightRange	= 0.0;
		if ( MISSILE_HYDRA_SPAWN_OFFSET_RIGHT_RANGE > 0.0 )
			rightRange	= RandomFloatRange( -1 * MISSILE_HYDRA_SPAWN_OFFSET_RIGHT_RANGE, MISSILE_HYDRA_SPAWN_OFFSET_RIGHT_RANGE );
		upRange		= 0.0;
		if ( MISSILE_HYDRA_SPAWN_OFFSET_UP_RANGE > 0.0 )
			upRange		= RandomFloatRange( -1 * MISSILE_HYDRA_SPAWN_OFFSET_UP_RANGE, MISSILE_HYDRA_SPAWN_OFFSET_UP_RANGE );
	
		start  = apache GetTagOrigin( tag );
		angles = owner GetPlayerAngles();
		
		pitchSpread = 0.0;
		if ( MISSILE_HYDRA_PITCH_SPREAD > 0.0 )
			pitchSpread = RandomFloatRange( -1 * MISSILE_HYDRA_PITCH_SPREAD, MISSILE_HYDRA_PITCH_SPREAD );
		yawSpread	= 0.0;
		if ( MISSILE_HYDRA_YAW_SPREAD > 0.0 )
			yawSpread	= RandomFloatRange( -1 * MISSILE_HYDRA_YAW_SPREAD, MISSILE_HYDRA_YAW_SPREAD );
		
		angles		+= ( pitchSpread, yawSpread, 0 );
		fwd		= AnglesToForward( angles );
		
		// Offset to the right (or the left) of the reticle but keep the up at zero. This keeps the missiles seperated while 
		// getting them to impact to the right and left of the reticle
		end	= eyePos + sign * MISSILE_HYDRA_IMPACT_OFFSET_RIGHT * right_flat + eye_end_dist * fwd;
		
		// Move flash fx forward 10 ft so it's more visible
		PlayFX( fx_flash, start + fwd * 120, fwd );
		
		// Missile spawned forward 60 to help stop apache running into it
		missile				 = MagicBullet( "apache_hydra_missile", start + fwd * 60, end, owner );
		missile.type_missile = "straight";
		
		level notify( "LISTEN_apache_player_missile_fire", missile );
		
		owner PlayRumbleOnEntity( "smg_fire" );
		
		if ( !one_hud_item_for_all )
		{
			self hud_markUsed_firstAvailableMissileIcon( "missile_straight");
			self.ammo["missile_straight"]--;
		}
		
		if ( i + 1 < ammo_to_fire )
		{
			wait MISSILE_HYDRA_FIRE_INTERVAL;
		}
	}
	
	if ( one_hud_item_for_all )
	{
		self hud_markUsed_firstAvailableMissileIcon( "missile_straight" );
		self.ammo["missile_straight"]--;
	}
}

_end()
{
	owner = self.owner;
	
	owner notify( "LISTEN_end_hydra_lockOn_missile" );
	
	deep_array_thread( self.hud, ::set_key, [ 0, "alpha" ] );
	
	owner stop_loop_sound_on_entity( "apache_lockon_missile_locking" );
}

_destroy()
{
	self _end();
	
	deep_array_call( self.hud, ::Destroy );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Utility
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

targetsSortByDot( array, origin, angles )
{
	Assert( IsDefined( array ) && IsArray( array ) );
	Assert( IsDefined( origin ) );
	Assert( IsDefined( angles ) );
	
	fwd	   = AnglesToForward( angles );
	_array = [];
	dots   = [];
	
	foreach ( item in array )
	{
		Assert( IsDefined( item.origin ) );
		
		dots[ dots.size ] = VectorDot( fwd, VectorNormalize( item.origin - origin ) );
	}
	
	return doubleReverseBubbleSort( dots, array );
}

doubleReverseBubbleSort( compareArray, returnArray )
{
	n = compareArray.size;
  
  	for ( i = ( n - 1 ); i > 0; i-- )
    {
    	for ( j = 1; j <= i; j++ )
        {
        	if ( compareArray[ j - 1 ] < compareArray[ j ] )
           	{
				temp				  = compareArray[ j ];
				compareArray[ j ]	  = compareArray[ j - 1 ];
				compareArray[ j - 1 ] = temp;
				
				temp				 = returnArray[ j ];
				returnArray[ j ]	 = returnArray[ j - 1 ];
				returnArray[ j - 1 ] = temp;
        	}
        }
    }
  	return returnArray;
}

dsq_ents_lt( ent1, ent2, r, _default )
{
	if ( IsDefined( ent1 ) && IsDefined( ent2 ) && IsDefined( r ) )
		return ter_op ( DistanceSquared( ent1.origin, ent2.origin ) < squared( r ), true, false );
	return ( ter_op( IsDefined( _default ), _default, false ) );
}

are_opposite_sign( x, y )
{
	Assert( IsDefined( x ) );
	Assert( IsDefined( y ) );
	
	if ( ( x < 0 && y > 0 ) || ( x > 0 && y < 0 ) || ( x == 0 && y != 0 ) || ( x != 0 && y == 0 ) )
		return true;
	return false;
}

get_sign( x )
{
	Assert( IsDefined( x ) );
	
	if ( x == 0 )
		return 0;
	if ( x < 0 )
		return -1;
	if ( x > 0 )
		return 1;
}

get_angle_delta( angle1, angle2 )
{
	Assert( IsDefined( angle1 ) );
	Assert( IsDefined( angle2 ) );
	
	mag		 = ter_op( angle2 - angle1 > 0, 1, -1 );
	deltaYaw = angle2 - angle1;
	return( ter_op( abs( deltaYaw ) > 180, -1 * mag * ( 360 - abs( deltaYaw ) ), mag * abs( deltaYaw ) ) );
}

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

flat_angle_yaw( angle )
{
	Assert( IsDefined( angle ) );
	return ( 0, angle[ 1 ], 0 );
}