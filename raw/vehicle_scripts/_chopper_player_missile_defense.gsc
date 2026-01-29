#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;
#include vehicle_scripts\_chopper_missile_defense_utility;

_precache()
{
	PreCacheModel( "angel_flare_rig" );
	PreCacheShader( "heli_warning_missile_red" );
	PreCacheShader( "apache_flare_back" );
	PreCacheShader( "apache_btn_flare_xenon" );
	PreCacheShader( "apache_btn_flare_flash_xenon" );
	PreCacheShader( "apache_ammo" );
	PreCacheShader( "apache_warn_incoming_left" );
	PreCacheShader( "apache_warn_incoming_right" );
	PreCacheShader( "apache_warn_lock_left" );
	PreCacheShader( "apache_warn_lock_right" );
	
	_fx();
	
	flare_rig_anims();
}

_fx()
{
	level._effect[ "FX_chopper_flare" ]				= LoadFX( "fx/_requests/apache/apache_flare" );
	level._effect[ "FX_chopper_flare_explosion" ]	= LoadFX( "fx/_requests/apache/apache_trophy_explosion" );
}

#using_animtree( "script_model" );
flare_rig_anims()
{
	level.scr_animtree[ "flare_rig" ] 				= #animtree;
	level.scr_model[ "flare_rig" ] 					= "angel_flare_rig";

	level.scr_anim[ "flare_rig" ][ "flare" ][ 0 ]	= %ac130_angel_flares01;
	level.scr_anim[ "flare_rig" ][ "flare" ][ 1 ]	= %ac130_angel_flares02;
}

_init( vehicle, owner, auto_flares )
{
	Assert( IsDefined( owner ) && IsPlayer( owner ) );
	Assert( IsDefined( vehicle.heli ) && IsDefined( vehicle.heli.targeting ) );
	
	missile_defense = SpawnStruct();
	
	// Generic Missile Defense Settings
	missile_defense.owner						= owner;
	missile_defense.vehicle						= vehicle;
	missile_defense.vehicle.missile_defense		= missile_defense;
	missile_defense.type						= "missile_defense";
	missile_defense.lockedOnToMe				= [];
	missile_defense.firedOnMe					= [];
	missile_defense.flareIndex					= 0;
	missile_defense.flares						= [];
	missile_defense.flareNumPairs				= 2;
	missile_defense.flareCooldown				= ter_op( auto_flares, 5, 1 );
	missile_defense.flareReloadTime				= 8.0;
	missile_defense.flareActiveRadius			= 4000;
	missile_defense.flareFx						= getfx( "FX_chopper_flare" );
	missile_defense.flareFxExplode				= getfx( "FX_chopper_flare_explosion" );
	missile_defense.missileTargetFlareRadius 	= 2000;
	missile_defense.flareDestroyMissileRadius	= 192;
	missile_defense.flareSpawnMaxPitchOffset	= 20;
	missile_defense.flareSpawnMinPitchOffset	= 10;
	missile_defense.flareSpawnMaxYawOffset		= 80;
	missile_defense.flareSpawnMinYawOffset		= 55;
	missile_defense.flareSpawnOffsetRight		= 104;
	missile_defense.flareRig_name				= "flare_rig";
	missile_defense.flareRig_animRate			= 3;
	missile_defense.flareRig_link				= true;
	missile_defense.flareRig_tagOrigin			= undefined;
	missile_defense.flareRig_tagAngles			= undefined;
	missile_defense.flareSound					= "chopper_flare_fire";
	
	// Player Specific Missile Defense Settings
	missile_defense.missileIcons				= [];
	missile_defense.targeting					= vehicle.heli.targeting;
	missile_defense.HUD_currentState			= "none";
	missile_defense.HUD_lastState				= "none";
	missile_defense.flareAuto					= auto_flares;
	
	missile_defense hud_init();
	
	return missile_defense;
}

RED						  = ( 1, 0, 0 );
CONST_COLOR_TEXT_LOCKING  = ( 1.0, 1.0, 1.0 ); // ( 0.281, 0.898, 0.804 );
CONST_COLOR_TEXT_INCOMING = ( 1.0, 1.0, 1.0 ); // ( 0.6, 0.2, 0.2 );

FLARES_MAX_AMMO	   = 2;
NAME_AMMO_OFFSET_Y = 76;

hud_init()
{	
	owner 			= self.owner;
	pilot_masterHud = self.vehicle.heli.pilot.hud;
	
	hud = [];
	
	hud[ "warning" ] = [];
	
	hud[ "warning" ][ "bg_lock_left" ] = owner createClientIcon( "apache_warn_lock_left", 128, 128 );
	hud[ "warning" ][ "bg_lock_left" ] setPoint( "CENTER", "CENTER", -185, 0 );
	hud[ "warning" ][ "bg_lock_left" ].alpha = 1.0;
	
	hud[ "warning" ][ "bg_lock_right" ] = owner createClientIcon( "apache_warn_lock_right", 128, 128 );
	hud[ "warning" ][ "bg_lock_right" ] setPoint( "CENTER", "CENTER", 185, 0 );
	hud[ "warning" ][ "bg_lock_right" ].alpha = 1.0;
	
	
	hud[ "warning" ][ "bg_inc_left" ] = owner createClientIcon( "apache_warn_incoming_left", 128, 128 );
	hud[ "warning" ][ "bg_inc_left" ] setPoint( "CENTER", "CENTER", 0, 0 );
	hud[ "warning" ][ "bg_inc_left" ].alpha = 1.0;
	hud[ "warning" ][ "bg_inc_left" ] setParent( hud[ "warning" ][ "bg_lock_left" ] );
	
	hud[ "warning" ][ "bg_inc_right" ] = owner createClientIcon( "apache_warn_incoming_right", 128, 128 );
	hud[ "warning" ][ "bg_inc_right" ] setPoint( "CENTER", "CENTER", 0, 0 );
	hud[ "warning" ][ "bg_inc_right" ].alpha = 1.0;
	hud[ "warning" ][ "bg_inc_right" ] setParent( hud[ "warning" ][ "bg_lock_right" ] );

	hud[ "warning" ][ "msg_left" ] = owner createClientFontString( "objective", 0.8 );
	hud[ "warning" ][ "msg_left" ] setPoint( "CENTER", "CENTER", 4, 0 );
	hud[ "warning" ][ "msg_left" ] SetText( "ENEMY LOCK" );
	hud[ "warning" ][ "msg_left" ].alpha = 0.0;
	hud[ "warning" ][ "msg_left" ] setParent( hud[ "warning" ][ "bg_lock_left" ] );
	
	hud[ "warning" ][ "msg_right" ] = owner createClientFontString( "objective", 0.8 );
	hud[ "warning" ][ "msg_right" ] setPoint( "CENTER", "CENTER", -4, 0 );
	hud[ "warning" ][ "msg_right" ] SetText( "ENEMY LOCK" );
	hud[ "warning" ][ "msg_right" ].alpha = 0.0;
	hud[ "warning" ][ "msg_right" ] setParent( hud[ "warning" ][ "bg_lock_right" ] );
	
	hud[ "flares" ] = [];
	hud[ "flares" ][ "back" ] = owner createClientIcon( "apache_flare_back", 64, 32 );
	hud[ "flares" ][ "back" ] setPoint( "CENTER", "CENTER", -180, NAME_AMMO_OFFSET_Y );
	hud[ "flares" ][ "back" ].alpha = 1.0;
	
	// JC-ToDo: Button prompt specific to consoles / pc
	hud[ "flares" ][ "flare_btn" ] = owner createClientIcon( "apache_btn_flare_xenon", 48, 32 );
	hud[ "flares" ][ "flare_btn" ] setPoint( "TOP", "BOTTOM", 0, -6 );
	hud[ "flares" ][ "flare_btn" ].alpha = 1.0;
	hud[ "flares" ][ "flare_btn" ] setParent( hud[ "flares" ][ "back" ] );

	hud[ "flares" ][ "flare_btn_flash" ] = owner createClientIcon( "apache_btn_flare_flash_xenon", 48, 32 );
	hud[ "flares" ][ "flare_btn_flash" ] setPoint( "TOP", "BOTTOM", 0, -6 );
	hud[ "flares" ][ "flare_btn_flash" ].alpha = 0;
	hud[ "flares" ][ "flare_btn_flash" ] setParent( hud[ "flares" ][ "back" ] );
	
	// Name commented out to test graphic skewing to further sell helmet
//	hud[ "flares" ][ "name" ] = owner createClientFontString( "objective", 0.8 );
//	hud[ "flares" ][ "name" ] setPoint( "BOTTOM", "TOP", 0, 5 );
//	hud[ "flares" ][ "name" ] SetText( "FLARES" );
//	hud[ "flares" ][ "name" ].alpha = 1.0;
//	hud[ "flares" ][ "name" ] setParent( hud[ "flares" ][ "back" ] );
	
	hud[ "flares" ][ "ammo" ] = [];
	
	for ( i = 0; i < FLARES_MAX_AMMO; i++ )
	{
		item = owner createClientIcon( "apache_ammo", 16, 16 );
		item setPoint( "RIGHT", "CENTER", 20, -4 + i * 8 );
		item.alpha 				= 1.0;
		item.isAvailable 		= true;
		item setParent( hud[ "flares" ][ "back" ] );
		hud[ "flares" ][ "ammo" ][ i ] = item;
	}
	
	self.hud = hud;
}

hud_update()
{
	heli = self.vehicle.heli;
	
	if ( heli ent_flag( "FLAG_pilot_active" ) )
	{
		switch ( self.HUD_currentState )
		{
			case "none":
			{
				self.hud[ "warning" ][ "msg_left"	   ].alpha = 0.0;
				self.hud[ "warning" ][ "msg_right"	   ].alpha = 0.0;
				self.hud[ "warning" ][ "bg_lock_left"  ].alpha = 0.0;
				self.hud[ "warning" ][ "bg_lock_right" ].alpha = 0.0;
				self.hud[ "warning" ][ "bg_inc_left"   ].alpha = 0.0;
				self.hud[ "warning" ][ "bg_inc_right"  ].alpha = 0.0;
				break;
			}
			case "warning":
			case "incoming":
			{
				self.hud[ "warning" ][ "msg_left"  ].alpha = 1.0;
				self.hud[ "warning" ][ "msg_right" ].alpha = 1.0;
				if ( self.HUD_currentState == "warning" )
				{
					self.hud[ "warning" ][ "bg_lock_left"  ].alpha = 1.0;
					self.hud[ "warning" ][ "bg_lock_right" ].alpha = 1.0;
					self.hud[ "warning" ][ "bg_inc_left"   ].alpha = 0.0;
					self.hud[ "warning" ][ "bg_inc_right"  ].alpha = 0.0;
				}
				else
				{
					self.hud[ "warning" ][ "bg_lock_left"  ].alpha = 0.0;
					self.hud[ "warning" ][ "bg_lock_right" ].alpha = 0.0;
					self.hud[ "warning" ][ "bg_inc_left"   ].alpha = 1.0;
					self.hud[ "warning" ][ "bg_inc_right"  ].alpha = 1.0;
				}
				break;
			}
		}
		
//		self.hud[ "flares" ][ "name" ].alpha = 1;
	}
}

_start()
{
	owner = self.owner;
	
	owner endon( "LISTEN_end_missile_defense" );
	
	self hud_start();
	
	// Common defense system logic
	self childthread monitorEnemyMissileLockOn( ::hud_enemy_missile_lockOn );
	self childthread monitorEnemyMissileFire();
	
	if ( !IsDefined( self.flareAuto ) || self.flareAuto )
	{
		self childthread monitorFlareRelease_auto( ::hud_makeUsed_flares, ::hud_makeFree_flares );
	}
	else
	{
		self childthread monitorFlareRelease_input( ::hud_makeUsed_flares, ::hud_makeFree_flares );
	}
	
	self childthread monitorFlares();
	
	// Player specific defense system logic
	self childthread monitorStatesHUD();
	
	
}

hud_start()
{
	heli = self.vehicle.heli;
	
	if ( heli ent_flag( "FLAG_pilot_active" ) )
	{
		self.hud[ "warning" ][ "msg_left"	   ].alpha = 0.0;
		self.hud[ "warning" ][ "msg_right"	   ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_lock_left"  ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_lock_right" ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_inc_left"   ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_inc_right"  ].alpha = 0.0;
		self.hud[ "warning" ][ "msg_right"	   ].alpha = 0.0;
//		self.hud[ "flares"	][ "name"		   ].alpha = 1.0;
	}
}

monitorStatesHUD()
{
	owner = self.owner;
	
	while ( 1 )
	{
		// Let other systems gather up missiles first
		waittillframeend;
		
		// Update the state of the defense system and determine
		// if the hud is updated
		
		// Figure out current state
		if ( self isAnyMissileFiredOnMe() )
		{
			self.HUD_currentState = "incoming";			
		}
		else if ( self isAnyEnemyLockedOnToMe() && !( self isAnyMissileFiredOnMe() ) )
		{
			self.HUD_currentState = "warning";
		}
		else
		{
			self.HUD_currentState = "none";
		}
		
		// If a state change occured clean up old, apply new
		if ( self.HUD_currentState != self.HUD_lastState )
		{
			// Clean up previous state
			if ( self.HUD_lastState == "warning" )
			{
				owner stop_loop_sound_on_entity( "missile_locking" );
			}
			else if ( self.HUD_lastState == "incoming" )
			{
				owner stop_loop_sound_on_entity( "missile_incoming" );
			}
			
			// Add new state
			if ( self.HUD_currentState == "none" )
			{
				self thread hud_hint_flares_reset();
				if ( self.HUD_lastState == "warning" )
				{
					owner thread play_sound_on_entity( "missile_locking_failed" );
				}
				self hud_turnOffMissileWarning();
			}
			if ( self.HUD_currentState == "warning" )
			{
				self thread hud_hint_flares();
				owner thread play_loop_sound_on_entity( "missile_locking" );
				self hud_missile_warning();
			}
			else if ( self.HUD_currentState == "incoming" )
			{
				owner thread play_loop_sound_on_entity( "missile_incoming" );
				self hud_missile_incoming();
				self thread hud_hint_flares();
			}
		}
		
		self.HUD_lastState = self.HUD_currentState;
		
		wait 0.05;
	}
}

hud_hint_flares()
{
	self notify ( "hint_flares_change" );
	self endon ( "hint_flares_change" );
	buttonHudElem		  = self.hud[ "flares" ][ "flare_btn" ];
	buttonHudElemFlashing = self.hud[ "flares" ][ "flare_btn_flash" ];
	hud_buttonHelp( buttonHudElem, buttonHudElemFlashing );
}

hud_hint_flares_reset()
{
	self notify ( "hint_flares_change" );
	self.hud[ "flares" ][ "flare_btn" ].alpha = 1;
	self.hud[ "flares" ][ "flare_btn_flash" ].alpha = 0;
}

hud_enemy_missile_lockOn( enemy )
{
	owner = self.owner;
	
	missileIcon = NewClientHudElem( owner );
	missileIcon SetShader( "heli_warning_missile_red", 256, 128 );
	//missileIcon.color = RED;
	missileIcon.alpha = 0.7;
	missileIcon SetWayPoint( true, true, true );
	missileIcon SetTargetEnt( enemy );
	missileIcon thread hud_flashAlpha( 1, 0.1 );
	
	
	self.missileIcons = array_removeUndefined( self.missileIcons );
	self.missileIcons[ self.missileIcons.size ] = missileIcon;
		
	enemy waittill_any( "death", "deathspin", "LISTEN_missile_fire_self", "LISTEN_missile_lockOnFailed" );
	
	self.lockedOnToMe = array_removeUndefined( self.lockedOnToMe );
	if ( IsDefined( enemy ) )
		self.lockedOnToMe = array_remove( self.lockedOnToMe, enemy );
	missileIcon notify( "death" );
	missileIcon Destroy();
}

hud_buttonHelp( hudelement, flash_hud_element )
{
	self endon( "death" );
	while ( true )
	{
		hudelement.alpha = 0;
		flash_hud_element.alpha = 1;
		wait 0.15;
		hudelement.alpha = 1;
		flash_hud_element.alpha = 0;
		wait 0.15;
	}
	
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


hud_missile_warning()
{
	heli = self.vehicle.heli;
	
	if ( heli ent_flag( "FLAG_pilot_active" ) )
	{
		self.hud[ "warning" ][ "msg_left"  ] SetText( "ENEMY LOCK" );
		self.hud[ "warning" ][ "msg_left"  ].color = CONST_COLOR_TEXT_LOCKING;
		self.hud[ "warning" ][ "msg_right" ] SetText( "ENEMY LOCK" );
		self.hud[ "warning" ][ "msg_right" ].color = CONST_COLOR_TEXT_LOCKING;
		
		self.hud[ "warning" ][ "msg_left"	   ].alpha = 1.0;
		self.hud[ "warning" ][ "msg_right"	   ].alpha = 1.0;
		self.hud[ "warning" ][ "bg_lock_left"  ].alpha = 1.0;
		self.hud[ "warning" ][ "bg_lock_right" ].alpha = 1.0;
		self.hud[ "warning" ][ "bg_inc_left"   ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_inc_right"  ].alpha = 0.0;
	}
}

hud_missile_incoming()
{
	heli = self.vehicle.heli;
	
	if ( heli ent_flag( "FLAG_pilot_active" ) )
	{
		self.hud[ "warning" ][ "msg_left"  ] SetText( "INCOMING" );
		self.hud[ "warning" ][ "msg_left"  ].color = CONST_COLOR_TEXT_INCOMING;
		self.hud[ "warning" ][ "msg_right" ] SetText( "INCOMING" );
		self.hud[ "warning" ][ "msg_right" ].color = CONST_COLOR_TEXT_INCOMING;
		
		self.hud[ "warning" ][ "msg_left"	   ].alpha = 1.0;
		self.hud[ "warning" ][ "msg_right"	   ].alpha = 1.0;
		self.hud[ "warning" ][ "bg_lock_left"  ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_lock_right" ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_inc_left"   ].alpha = 1.0;
		self.hud[ "warning" ][ "bg_inc_right"  ].alpha = 1.0;
	}
}

hud_turnOffMissileWarning()
{
	heli = self.vehicle.heli;
	
	if ( heli ent_flag( "FLAG_pilot_active" ) )
	{
		self.hud[ "warning" ][ "msg_left"	   ].alpha = 0.0;
		self.hud[ "warning" ][ "msg_right"	   ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_lock_left"  ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_lock_right" ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_inc_left"   ].alpha = 0.0;
		self.hud[ "warning" ][ "bg_inc_right"  ].alpha = 0.0;
		self.hud[ "warning" ][ "msg_right"	   ].alpha = 0.0;
	}
}

hud_makeUsed_flares()
{
	ammo = self hud_countFree_flares();
	result = ammo > 0;
	
	// Adjust ammo, scrub array while we're at it
	if ( result )
	{
		ammo--;
		self hud_updateAmmo_flares( ammo );
	}
	
	return result;
}

hud_makeFree_flares( delay )
{
	if ( IsDefined( delay ) && delay > 0 )
		wait delay;
	
	// Adjust ammo, scrub array while we're at it
	ammo = self hud_countFree_flares();
	result = ammo < FLARES_MAX_AMMO;
	
	if ( result )
	{
		ammo++;
		self hud_updateAmmo_flares( ammo );
	}
	
	return result;
}

hud_updateAmmo_flares( ammo )
{
	foreach ( idx, item in self.hud[ "flares" ][ "ammo" ] )
	{
		if ( idx + 1 <= ammo )
		{
			item.isAvailable = true;
			item.alpha		 = 1.0;
		}
		else
		{
			item.isAvailable = false;
			item.alpha		 = 0.0;
		}
	}
}

hud_countFree_flares()
{
	count = 0;
	foreach ( item in self.hud[ "flares" ][ "ammo" ] )
	{
		if ( item.isAvailable )
			count++;
	}
	
	return count;
}

_end()
{
	owner = self.owner;
	
	owner notify( "LISTEN_end_missile_defense" );
	
	array_thread( self.hud, ::set_key, [ 0, "alpha" ] );
	
	owner stop_loop_sound_on_entity( "missile_locking" );
	owner stop_loop_sound_on_entity( "missile_incoming" );
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

_destroy()
{
	self _end();
	
	// clean up circular reference to missile defense struct
	self.vehicle.missile_defense = undefined;
	
	deep_array_call( self.hud, ::Destroy );
	deep_array_call( self.missileIcons, ::Destroy );
}

