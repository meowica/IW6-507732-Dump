#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

_precache()
{
	PreCacheShader( "apache_friendly_ai_diamond_s_w" );
	PreCacheShader( "apache_target_vehicle" );
	
	// JC-ToDo: These are currently not used. Remove in next clean up pass.
	PreCacheShader( "apache_enemy_ai_target_s_w" );
	PreCacheShader( "apache_friendly_vehicle_diamond_s_w" );
	PreCacheShader( "apache_enemy_vehicle_target_empty" );
}

_init( owner )
{
	Assert( IsDefined( owner ) && IsPlayer( owner ) );
	
	targeting = SpawnStruct();
	
	targeting.owner	= owner;
	targeting.type	= "targeting";
	
	return targeting;
}

_start()
{
}

WHITE							= ( 1.0, 1.0, 1.0 );
COLOR_ALLY						= ( 0.3, 0.3, 0.3 );
ENEMY_MIN_SIZE					= 16;
ENEMY_MIN_SIZE_LOCK				= 32;
ENEMY_TRACK_DELAY_RATIO			= 0.6;
ENEMY_TRACK_DELAY_RATIO_LOCK	= 0.0;
ENEMY_TRACK_DELAY_RADIUS_INNER	= 10;
ENEMY_TRACK_DELAY_RADIUS_OUTER	= 25;
ENEMY_TRACK_DELAY_HOLD_TIME_MIN = 1.25;
ENEMY_TRACK_DELAY_HOLD_TIME_MAX = 2.75;

hud_color_ally()
{
	return COLOR_ALLY;
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
// JC-ToDo: These target hud update funcs duplicate the logic that exists in the hud_addTargets func below. Should share logic, no time.

hud_set_target_locked( target )
{
	// Only vehicles handled currently
	if ( target isVehicle() )
	{
		Target_SetDelay( target, ENEMY_TRACK_DELAY_RATIO_LOCK, 1, 1, 0.0 );
		Target_SetMinSize( target, ENEMY_MIN_SIZE_LOCK, false );
	}
}

hud_set_target_default( target )
{
	// Only vehicles handled currently
	if ( target isVehicle() )
	{
		Target_SetDelay( target, ENEMY_TRACK_DELAY_RATIO, ENEMY_TRACK_DELAY_RADIUS_INNER, ENEMY_TRACK_DELAY_RADIUS_OUTER, RandomFloatRange( ENEMY_TRACK_DELAY_HOLD_TIME_MIN, ENEMY_TRACK_DELAY_HOLD_TIME_MAX ) );
		Target_SetMinSize( target, ENEMY_MIN_SIZE, ter_op( IsDefined( target.hud_player_target_hide_at_min ), target.hud_player_target_hide_at_min, true ) );
	}
}
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

// JC-ToDo: Clean up hud_addTargets() - unecessarily large and gross function
hud_addTargets( targets, delay )
{
	if( !IsDefined( targets ) || !IsArray( targets ) )
		return;
	
	delay = ter_op( IsDefined( delay ), delay, 0.0 );
	
	shader		 			= "apache_friendly_ai_diamond_s_w";
	offscreen_shader 		= undefined;
	offscreen_shader_blink 	= undefined;
    offset 					= ( 0, 0, 0 );
    active_mode 			= "both";
    active 					= false;
    draw_corners 			= false;
    draw_single 			= false;
    min_size 				= -1;
	max_size 				= -1;
	hide_at_min_size		= true;
    scaled_target 			= true;
    draw_square 			= false;
    color 					= undefined;
    radius 					= -1;
    update_delay			= undefined;
    
	foreach ( target in targets )
	{
		if ( !IsDefined( target ) || IsDefined( target.shader ) || Target_IsTarget( target ) ||
			 Target_GetArray().size >= 64 )
			continue;
	
		if ( isMissile( target ) )
		{
			shader 		= "apache_friendly_vehicle_diamond_s_w";
			active 		= true;
			draw_single = true;
			draw_square = true;
//			color 		= hud_color_enemy();
			radius 		= 60;
		}
		else
		if ( IsAI( target ) )
		{
			if ( target onTeam( "allies" ) )
			{
				shader 						= "apache_friendly_ai_diamond_s_w";
				//offscreen_shader 			= ;
				//offscreen_shader_blink 	= ;
				active 						= true;
				//draw_corners 				= true;
				offset 						= ( 0, 0, 32 );
				draw_single 				= true;
				draw_square 				= true;
				radius 						= 45;
				color 						= hud_color_ally();
			}
			// axis
			else
			{
				shader		= "apache_enemy_ai_target_s_w";
				active_mode = "enhanced";
				offset		= ( 0, 0, 32 );
				draw_single = true;
				draw_square = true;
				max_size = 24;
//				radius		= 35;
//				color_from_photoshop = ( 78, 142, 107 );
//				color		= VectorNormalize( color_from_photoshop ) * 0.8;
			}
		}
		else
		if ( target isVehicle() )
		{
			if  ( target onTeam( "allies" ) )
			{
				shader 						= "apache_friendly_vehicle_diamond_s_w";
				//offscreen_shader 			= ;
				//offscreen_shader_blink 	= ;
				active 						= true;
				//draw_corners 				= true;
				draw_single 				= true;
				draw_square 				= true;
				color 						= hud_color_ally();
				
				if ( IsSubStr( target.classname, "apache" ) )
				{
					offset = ( 0, 0, -72 );
					radius = 100;
				}
			}
			// axis
			else
			{
				if( !hudOutLineEnabledForPlatform() )
					shader			= "apache_target_vehicle";
				active_mode 	= "enhanced";
				offset 			= ( 0, 0, 64 );
				draw_square 	= true;
				draw_single 	= true;
				draw_corners 	= false;
				color 			= undefined; // hud_color_enemy();
				ter_op( hudOutLineEnabledForPlatform(), 10000, ENEMY_MIN_SIZE );
				max_size		= 64;
				radius			= 150;
				update_delay	= ENEMY_TRACK_DELAY_RATIO;
				
				if ( IsSubStr( target.classname, "hind" ) )
 				{
					offset 			 = ( 0, 0, -72 );
					hide_at_min_size = IsDefined( target.script_parameters ) && IsSubStr( target.script_parameters, "target_hide_at_min" );
 				}
			}
		}
		else
		if ( isScriptModel( target ) )
		{
			if ( target onTeam( "allies" ) )
			{
				shader 						= "apache_friendly_vehicle_diamond_s_w";
				//offscreen_shader 			= ;
				//offscreen_shader_blink 	= ;
				active 						= true;
				draw_single					= true;
				draw_square 				= true;
				//draw_corners 				= true;
//				color 						= hud_color_enemy();
				radius 						= 150;
			}
			else
			{
				shader 			= "apache_enemy_ai_target_s_w";
				color 			= ( 0.5, 0.15, 0.15 ) ;
				active_mode 	= "enhanced";
				offscreen_shader 			= "apache_enemy_ai_target_s_w";
				offset 			= ( 0, 0, 32 );
				//draw_single 	= true;
				draw_square		= true;
				radius 			= 60;
				
				if ( IsDefined( target.model ) )
				{
					shader 			= "apache_enemy_vehicle_target_empty";
					active_mode 	= "enhanced";
					draw_square 	= true;
					draw_corners 	= true;
//					color 			= hud_color_enemy();
					
					if ( IsSubStr( target.model, "t72" ) )
					{
						radius = 150;
					}
				}
			}
		}
		else
		{
			// default
			
			shader = "apache_friendly_ai_diamond_s_w";
   			offset = ( 0, 0, 32 );
		}
		
		_target = SpawnStruct();
		
		_target.active_mode 			= active_mode;
		_target.active 					= active;
		_target.offscreen_shader 		= offscreen_shader;
		_target.offscreen_shader_blink 	= offscreen_shader_blink;
		
		if ( scaled_target )
		{
			Target_Alloc( target, offset );
		    Target_SetShader( target, shader );
		    Target_SetScaledRenderMode( target, false );
		    
		    if ( draw_single )
		    	Target_DrawSingle( target );
		    if ( draw_square )
		    	Target_DrawSquare( target, radius );
		    if ( draw_corners )
		    	Target_DrawCornersOnly( target, true );
		    if ( IsDefined( color ) )
		    	Target_SetColor( target, color );
		    if ( IsDefined( update_delay ) )
		    	Target_SetDelay( target, update_delay, ENEMY_TRACK_DELAY_RADIUS_INNER, ENEMY_TRACK_DELAY_RADIUS_OUTER, RandomFloatRange( ENEMY_TRACK_DELAY_HOLD_TIME_MIN, ENEMY_TRACK_DELAY_HOLD_TIME_MAX ) );
		    
		    Target_SetMaxSize( target, max_size );
		    Target_SetMinSize( target, min_size, hide_at_min_size );
		    
			Target_Flush( target );
			
			if ( !hide_at_min_size )
			{
				target.hud_player_target_hide_at_min = hide_at_min_size;
			}
		}
		else
		{
			Target_Set( target, offset );
			Target_SetShader( target, shader );
		}
		/*
		if ( active )
		{
			foreach ( player in level.players )
				if ( player == level.ac130player )
					Target_ShowToPlayer( target, level.ac130player );
				else
					Target_HideFromPlayer( target, player );
		}
		else
		*/
			foreach ( player in level.players )
				Target_HideFromPlayer( target, player );
		
		// Track which players can see the target			
		_target.visibleTo = [];
		foreach ( player in level.players )
			_target.visibleTo[ player GetEntityNumber() ] = undefined;
		
		if ( !IsDefined( _target.weapon ) )
			_target.weapon = [];
		
		// -- Lock On Missiles
		
		_target.weapon[ "lockOn_missile" ] 				= SpawnStruct();
		_target.weapon[ "lockOn_missile" ].isLockedOn 	= [];
		
//		foreach ( player in level.players )
//			_target.weapon[ "lockOn_missile" ].isLockedOn[ player GetEntityNumber() ] = undefined;
		
//		// -- Raining Missiles
//		
//		_target.weapon[ "raining_missile" ] 			= SpawnStruct();
//		_target.weapon[ "raining_missile" ].isLockedOn 	= [];
		
//		foreach ( player in level.players )
//			_target.weapon[ "raining_missile" ].isLockedOn[ player GetEntityNumber() ] = undefined;
		
		target._target = _target;
		
		self thread hud_target_onDeath( target );
		
		if ( delay > 0 )
		{
			wait delay;
		}
	}
}

isMissile( ent )
{
	if ( IsDefined( ent ) && IsDefined( ent.classname ) && IsSubStr( ent.classname, "rocket" ) )
		return true;
	return false;
}

isScriptModel( ent )
{
	if ( IsDefined( ent ) && IsDefined( ent.classname ) && ent.classname == "script_model" )
		return true;
	return false;
}
	
hud_showTargets( targets )
{
	owner = self.owner;
	
	AssertEx( IsDefined( targets ) && IsArray( targets ), "targets must be defined and an array" );
	
	foreach ( target in targets )
	{	
		if ( IsDefined( target ) && Target_IsTarget( target ) )
		{
			_target = target._target;
			
			_target.visibleTo[ owner GetEntityNumber() ] = true;
			
			// Thermal on for enemies
			if ( ( IsDefined( target.team ) && target.team == "axis" ) || ( IsDefined( target.script_team ) && target.script_team == "axis" ) )
			{
				if( hudOutLineEnabledForPlatform() )
					target thread hud_outlineEnable();
				else
					target ThermalDrawEnable();
					
				
			}
			else
			{
				if( hudOutLineEnabledForPlatform() )
					target HudOutlineDisable();
				else 
					target ThermalDrawDisable();
			}
			
			// Target box on enemy vehicles and ally ai
			if ( target isVehicle() || ( IsAI( target ) ) /* && IsDefined( target.team ) && target.team == "allies" )*/ )
			{
				if( !hudOutLineEnabledForPlatform() )
					Target_ShowToPlayer( target, owner );
			}
		}
	}
}

hudOutLineEnabledForPlatform()
{
	return is_gen4() && GetDvarInt( "r_hudoutlineenable") == 1;
}

hud_outlineEnable()
{
	self HudOutlineEnable( 1 );
	self waittill( "death" );
	if ( IsDefined( self ) )
		self HudOutlineDisable();
}

hud_hideTargets( targets )
{
	owner = self.owner;
	
	AssertEx( IsDefined( targets ) && IsArray( targets ), "targets must be defined and an array" );
	
	foreach ( target in targets )
	{
		if ( IsDefined( target ) && Target_IsTarget( target ) )
		{
			_target = target._target;
			
			_target.visibleTo[ owner GetEntityNumber() ] = undefined;
			
			// Thermal off for enemies
			if ( ( IsDefined( target.team ) && target.team == "axis" ) || ( IsDefined( target.script_team ) && target.script_team == "axis" ) )
			{
				if( hudOutLineEnabledForPlatform() )
					target HudOutlineDisable();
				else
					target ThermalDrawDisable();
			}
			
			Target_HideFromPlayer( target, owner );
		}
	}
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

hud_target_onDeath( target )
{
	target waittill( "death" );
	
	if ( IsDefined( target ) && Target_IsTarget( target ) )
	{
		// Don't hide AI targetting. It looks better if they stay in
		// thermal as they fly through the air.
		if ( !IsAI( target ) )
		{
			// Hide on vehicles to disable thermal
			self hud_hideTargets( [ target ] );
		}
		
		Target_Remove( target );
	}
		
}

target_isLockedOnToMe( player )
{
	Assert( IsDefined( player ) && IsPlayer( player ) );
	
	if ( !IsDefined( self._target ) )
		return false;
	
	entNum		= player GetEntityNumber();
	isLockedOn 	= false;
	
	foreach ( weapon in self._target.weapon )
		if ( IsDefined( weapon.isLockedOn[ entNum ] ) )
			return true;
	return false;
}

_end()
{
	owner = self.owner;
	
	owner notify( "LISTEN_end_targeting" );
	
	targets = Target_GetArray();
	entNum	= owner GetEntityNumber();
	
	if ( level.players.size > 1 )
	{
		foreach ( target in targets )
		{
			Target_Remove( target );
			
			if ( IsDefined( target._target ) )
					target._target = undefined;
		}
	}
	else
	{
		foreach ( target in targets )
		{
			Target_HideFromPlayer( target, owner );
			
			if ( IsDefined( target._target ) )
				foreach ( weapon in target._target.weapon )
					weapon.isLockedOn[ entNum ] = undefined;
		}
	}
}

/***********************************/
/************ UTILITY **************/
/***********************************/

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