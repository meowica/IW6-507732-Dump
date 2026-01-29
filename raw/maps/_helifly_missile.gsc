#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

HUD_ALPHA = 0.9;

precache_guided_missiles()
{
	PrecacheItem( "tomahawk_missile" );
	
	PreCacheShader( "heli_ammo_missile_red" );
	PreCacheShader( "heli_ammo_missile_grn" );
	PreCacheShader( "heli_circle" );
	PreCacheShader( "heli_missile_roll" );

	PreCacheShader( "ac130_hud_friendly_vehicle_diamond_s_w" );
	PreCacheShader( "ac130_hud_enemy_vehicle_target_s_w" );
}

init_missiles()
{
	add_hint_string( "hint_lockon", "Hold RB to lock on", ::should_break_lockon_hint );
	add_hint_string( "hint_rocket", "Release RB to fire missiles", ::should_break_rocket_hint );

	flag_init( "player_locked_on" );
	flag_init( "player_fired_rocket" );
	flag_init( "_guided_missiles_enabled" );
	
	level.lockon_targets = [];
	targets = getentarray( "lockon_targets", "script_noteworthy" );
	array_thread( targets, ::enable_lockon );

	thread wait_for_fire_flag();
	thread wait_for_lockon_flag();
}

player_missile_init()
{
	self.heli_hud[ "missile_roll" ] = self createClientIcon( "heli_missile_roll", 320, 160 );
	self.heli_hud[ "missile_roll" ] setPoint( "CENTER", undefined, 0, -80 );

	self.heli_hud[ "missile_range" ] = self createClientIcon( "heli_circle", 320, 320 );
	self.heli_hud[ "missile_range" ] setPoint( "CENTER", undefined, 0, 0 );
}

MAX_MISSILE_AMMO = 4;
MISSILE_RELOAD_TIME = 2;

init_rockets()
{
	self NotifyOnPlayerCommand( "lock_rockets", "+frag" );
	self NotifyOnPlayerCommand( "fire_rockets", "-frag" );
//	self.targeting_ent = spawn_tag_origin();
//	self thread follow_trace( self.targeting_ent );
	
	self.missile_ammo = MAX_MISSILE_AMMO;
	self.max_missile_ammo = MAX_MISSILE_AMMO;
}

enable_rockets()
{
	self endon( "disable_rockets" );
	
	flag_set( "_guided_missiles_enabled" );
	
	self.lockon = [];
	self childthread hud_track_missile_ammo();
	self childthread missile_reload();
	
	while( 1 )
	{
		self waittill( "lock_rockets" );
		
		
		if ( self.missile_ammo > 0 )
		{
			self notify( "stop_reload" );
			self childthread lock_targets_think();
		}
		else
			continue;
		
		self waittill( "fire_rockets" );
		self stop_loop_sound_on_entity( "heli_missile_locking" );
		
		self.heli_hud[ "missile_range" ].alpha = 0;
		
		if ( self.missile_ammo <= 0 )
		{
			self childthread missile_reload();
			continue;
		}

		// self missile_fire( self.targeting_ent );
		
		if ( self.lockon.size <= 0 )
		{	// no lock on
			temp = spawn_tag_origin();
			trace = get_laser_designated_trace();
			temp.origin = trace[ "position" ];
			temp.delete_me = true;
			self thread missile_fire( temp );
			self thread missile_reload();
		}
		else
		{
			self notify( "player_fired_rocket" );
			foreach( target in self.lockon )
			{
				self thread missile_fire( target );
				self thread missile_lock_cleanup( target );
				wait( 0.15 );
			}
			self childthread missile_reload();
		}

		self childthread lock_targets_remove();
		
		wait( 0.2 );
	}
}

disable_rockets()
{
	self notify( "disable_rockets" );
	self notify( "stop_reload" );
	
	flag_clear( "_guided_missiles_enabled" );
	
	while( self.missile_hud.size > 0 )
	{
		hud_remove_missile();
	}
}

lock_targets_think()
{
	self endon( "fire_rockets" );
	self endon( "done_locking" );
	
	wait( 0.2 );
	
	self.heli_hud[ "missile_range" ].alpha = HUD_ALPHA;
	
	self thread play_loop_sound_on_entity( "heli_missile_locking" );
	foreach ( target in level.lockon_targets )
	{
		self target_invalid( target );
	}
	
	self childthread manage_target_validity();
	wait( 0.5 );
	while( 1 )
	{
		targets = SortByDistance( level.lockon_targets, self.origin );
		found_target = false;
		
		if ( self isADS() )
			dot = 0.991;
		else
			dot = 0.983;		
		
		foreach ( target in targets )
		{
			if ( self.lockon.size < self.missile_ammo )
				if ( is_valid_target( target, dot ) && !array_contains( self.lockon, target ) )
				{
					self target_valid( target );
					found_target = true;
					self hud_add_red();
					if ( self.lockon.size == self.missile_ammo )
					{
						self play_sound_on_entity( "heli_missile_locked" );
						thread display_hint( "hint_rocket" );
					}
					else
						self play_sound_on_entity( "heli_missile_tag" );
					wait( 0.5 );
					break;
				}
		}
		if ( found_target )
			continue;
			
		foreach ( target in targets )
		{
			if ( self.lockon.size < self.missile_ammo )
				if ( is_valid_target( target ) && !array_contains( self.lockon, target ) )
				{
					self target_valid( target );
					self hud_add_red();
					if ( self.lockon.size == self.missile_ammo )
					{
						self play_sound_on_entity( "heli_missile_locked" );
						thread display_hint( "hint_rocket" );
					}
					else
						self play_sound_on_entity( "heli_missile_tag" );
					wait( 0.5 );
					break;
				}
		}
		
		wait( 0.05 );
	}
}

manage_target_validity()
{
	while( 1 )
	{
		if ( self isADS() )
			dot = 0.99;
		else
			dot = 0.85;
		
		foreach( target in self.lockon )
		{
			if ( self is_valid_target( target, dot, true ) == false )
			{
				self target_invalid( target );
				self hud_add_green();
			}
		}
		wait( 0.1 );
	}
}

MIN_TARGET_DISTANCE = 128;
MAX_TARGET_DISTANCE = 15000;

is_valid_target( target, dot, dot_only )
{
	if ( !isdefined( target ) )
		return false;
		
	if ( !isdefined( dot ) )
		if ( self isADS() )
			dot = 0.993;
		else
			dot = 0.965;
	dist = Distance( target.origin, self.origin );
	if ( dist < MIN_TARGET_DISTANCE )
		return false;
	if ( dist > MAX_TARGET_DISTANCE )
		return false;
	return player_looking_at( target.origin, dot, dot_only, target );
}

lock_targets_remove()
{
	self endon( "fire_rockets" );
	self endon( "done_locking" );
	
	foreach ( target in level.lockon_targets )
	{
		if ( Target_IsTarget( target ) )
			Target_Remove( target );
	}
	
	self.lockon = [];
	self hud_add_green();
}

target_valid( target )
{
	self notify( "player_locked_on" );
	
	shader = "ac130_hud_friendly_vehicle_diamond_s_w";
	color = ( 1, 0, 0 );
	target_enable( target, shader, color, 192 );
	self.lockon = array_add( self.lockon, target );
}

target_invalid( target )
{
	shader = "ac130_hud_enemy_vehicle_target_s_w";
	color = ( 0, 0.3, 0 );
	target_enable( target, shader, color, 128 );
	self.lockon = array_removeUndefined( self.lockon );
	if ( IsDefined( target ) )
	{
		self.lockon = array_remove( self.lockon, target );
	}
}

target_enable( target, shader, color, radius )
{
	if ( !IsDefined( target ) )
		return;
	
	offset = ( 0,0,0 );
	
	Target_Alloc( target, offset );
	Target_SetShader( target, shader );
	
	Target_SetScaledRenderMode( target, true );	
	/*
	Target_DrawSquare( target );
	Target_DrawSingle( target );
	Target_DrawCornersOnly( target, true );	
	*/
	
	if ( IsDefined( color ) )
		Target_SetColor( target, color );
	Target_SetMaxSize( target, 24 );
	Target_SetMinSize( target, 16, false );
	
	Target_Flush( target );
}


missile_reload()
{
	self endon( "stop_reload" );
	while( self.missile_ammo < self.max_missile_ammo )
	{
		wait( MISSILE_RELOAD_TIME - 0.5 );
		self thread play_sound_on_entity( "ac130_40mm_reload" );
		wait( 0.5 );
		self.missile_ammo += 1;
		self hud_add_missile();
	}
}

MISSILE_OFFSET_Z = -64;
MISSILE_OFFSET_Y = 128;

missile_fire( target )
{
	self notify( "firing_missile" );
	self notify( "done_locking" );
	
	self PlayRumbleOnEntity( "heavygun_fire" );
	self hud_remove_missile();
	
	self.missile_ammo -= 1;
	missile_origin = self.origin - ( 0,0,MISSILE_OFFSET_Z );
	
	angles = self getPlayerAngles();
	
	if ( self.missile_ammo % 2 == 0 )
		missile_origin += AnglesToRight( angles )*MISSILE_OFFSET_Y;
	else
		missile_origin -= AnglesToRight( angles )*MISSILE_OFFSET_Y;
	
	missile_target = missile_origin + ( AnglesToForward( angles )*10 );
	
	Earthquake( 0.3, 0.6, self.origin, 5000 );
	
	newMissile = MagicBullet( "tomahawk_missile", missile_origin, missile_target, self );	
	newMissile Missile_SetTargetEnt( target );
	newMissile Missile_SetFlightmodeDirect();
	
	target notify( "incoming_missile", newMissile );
	
	if ( isdefined( target.delete_me ) )
	{
		newMissile waittill( "death" );
		target delete();
	}
}

missile_lock_cleanup( target )
{
	target waittill( "death" );
	self target_invalid( target );
	if ( Target_isTarget( target ) )
		Target_Remove( target );
	self hud_add_green();
}

follow_trace( entity )
{
	while( true )
	{
		trace = self get_laser_designated_trace();
		viewpoint = trace[ "position" ];
		entity.origin = viewpoint;
		wait( 0.1 );
	}
}

get_laser_designated_trace()
{
	eye = self geteye();
	angles = self getplayerangles();
	
	forward = anglestoforward( angles );
	end = eye + ( forward * 7000 );
	trace = bullettrace( eye, end, true, self );

	return trace;
}

enable_lockon()
{
	level.lockon_targets[ level.lockon_targets.size ] = self;
	self waittill( "death" );
	level.lockon_targets = array_remove( level.lockon_targets, self );
	if ( Target_isTarget( self ) )
		Target_Remove( self );
}

hud_track_missile_ammo()
{
	self.missile_hud = [];
	
	for ( i=0; i<self.missile_ammo; i++ )
	{
		hud_add_missile();
	}
}

hud_add_missile()
{
	icon_width = 20;
	icon_dip = 10;
	
	xSpread = 140;
	yOffset = 64;
	
	i = self.missile_hud.size;
	
	switch ( i )
	{
		case 0:
			i = 3;
			break;
		case 1:
			i = 0;
			break;
		case 2:
			i = 2;
			break;
		case 3:
			i = 1;
			break;
	}
	
	elem = self createClientIcon( "heli_ammo_missile_grn", 32, 48 );	
	
	xOffset = (-1*(self.max_missile_ammo/2)*icon_width) + (icon_width * i) + (icon_width/2);
	
	if ( i < 2 )
		xOffset = xOffset - xSpread;
	else
		xOffset = xOffset + xSpread;
		
	if ( i == 0 || i == 3 )
		yOffset = yOffset + icon_dip;
		
	elem setPoint( "CENTER", undefined, xOffset, yOffset );
	elem.status = "green";
	elem.alpha = HUD_ALPHA;
	elem.color = ( 0, 1, 0 );
	self.missile_hud = array_add( self.missile_hud, elem );
}

hud_remove_missile()
{
	icon = self.missile_hud[ self.missile_hud.size - 1 ];
	self.missile_hud = array_remove( self.missile_hud, icon );
	icon destroy();
}

hud_add_red()
{
	locked = self.lockon.size;
	ammo = self.missile_hud.size - 1;
	
	for ( i=0; i<locked; i++ )
	{
		icon = self.missile_hud[ ammo - i ];
		if ( icon.status == "green" )
		{
			icon.status = "red";
			icon.color = ( 1, 0, 0 );
		}
	}
}

hud_add_green()
{
	locked = self.lockon.size;
	ammo = self.missile_hud.size;
	change = ammo - locked;
	
	for ( i=0; i<change; i++ )
	{
		icon = self.missile_hud[ i ];
		if ( icon.status == "red" )
		{
			icon.status = "green";
			icon.color = ( 0, 1, 0 );
		}
	}
}

should_break_lockon_hint()
{
	return flag( "player_locked_on" );
}

should_break_rocket_hint()
{
	return ( flag( "player_locked_on" ) && flag( "player_fired_rocket" ) );
}

wait_for_lockon_flag()
{
	level.player waittill( "player_locked_on" );
	flag_Set( "player_locked_on" );
}

wait_for_fire_flag()
{
	level.player waittill( "player_fired_rocket" );
	flag_Set( "player_fired_rocket" );
}