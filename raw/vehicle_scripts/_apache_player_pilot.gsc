#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

_precache()
{
	PreCacheShader( "apache_compass_back" );
	PreCacheShader( "apache_hint_back" );
	PreCacheShader( "apache_speed_arrow" );
	PreCacheShader( "apache_speed_back" );
	PreCacheShader( "apache_altitude_arrow" );
	PreCacheShader( "apache_altitude_back" );
	PreCacheShader( "apache_roll_back" );
	PreCacheShader( "apache_roll_marker" );
	PreCacheShader( "apache_roll_marker_left1" );
	PreCacheShader( "apache_roll_marker_left2" );
	PreCacheShader( "apache_roll_marker_right1" );
	PreCacheShader( "apache_roll_marker_right2" );
	PreCacheShader( "apache_reticle" );
	PreCacheShader( "apache_zoom_overlay" );
	PreCacheShader( "apache_mg_heat_back" );
	PreCacheShader( "apache_mg_heat_warn" );
	PreCacheShader( "apache_bottom_mark" );
	PreCacheShader( "apache_enemy_thermalbody" );//Objective texture that pulses
	PreCacheShader( "apache_enemy_thermalbody_no_pulse" );//Regular texture that does not pulse
	
	PreCacheModel( "viewmodel_prototype_apache_visor" );
	
	vehicle_scripts\_apache_player_missile_hydra_and_lockon::_precache();
	//vehicle_scripts\_apache_player_lockon_missile::_precache();
	//vehicle_scripts\_apache_player_hydra_rocket_launcher::_precache();
	//vehicle_scripts\_apache_player_raining_missile::_precache();
	//vehicle_scripts\_apache_player_shotgun_missile::_precache();
	//vehicle_scripts\_apache_player_mini_drone::_precache();
	
	_fx();
	_anim();
}

_fx()
{
	level._effect[ "FX_apache_pilot_turret_projectile" ] = LoadFX( "fx/_requests/apache/apache_pilot_turret_projectile" );
	level._effect[ "FX_apache_pilot_turret_flash_view" ] = LoadFX( "fx/_requests/apache/apache_pilot_turret_flash_view" );
	level._effect[ "FX_apache_pilot_shot_blood"		   ] = LoadFX( "fx/_requests/apache/apache_pilot_shot_blood" );
}

#using_animtree( "generic_human" );
_anim()
{
	level.scr_animtree[ "generic" ] 										= #animtree;
	level.scr_anim[ "generic" ][ "helicopter_pilot1_idle" ]					= %helicopter_pilot1_idle;
	level.scr_anim[ "generic" ][ "helicopter_pilot1_twitch_lookback" ]		= %helicopter_pilot1_twitch_lookback;
	level.scr_anim[ "generic" ][ "helicopter_pilot1_twitch_lookoutside" ]	= %helicopter_pilot1_twitch_lookoutside;
	level.scr_anim[ "generic" ][ "helicopter_pilot1_twitch_clickpannel" ]	= %helicopter_pilot1_twitch_clickpannel;
	level.scr_anim[ "generic" ][ "apache_cockpit_copilot_death" ]			= %apache_cockpit_copilot_death;
}

CONST_COLOR_TEXT_ALTITUDE = ( 1.0, 1.0, 1.0 ); // ( 0.789, 0.535, 0.261 );

_init( apache, owner )
{
	Assert( IsDefined( apache ) );
	Assert( IsDefined( owner ) && IsPlayer( owner ) );
	
	pilot_ai_spawner = GetEnt( "apache_pilot", "targetname" );
	AssertEx( IsDefined( pilot_ai_spawner ), "_apache_player_pilot::_init() assumes a spawner exists for the co-pilot with a target name of \"apache_pilot\"" );
	
	pilot_ai_spawner.origin = apache GetTagOrigin( "tag_passenger" );
	pilot_ai_spawner.angles = apache GetTagAngles( "tag_passenger" );
	
	pilot_ai = pilot_ai_spawner SpawnDrone();
	pilot_ai DontCastShadows();
	Assert( IsDefined( pilot_ai ), "_apache_player_pilot::_init() failed to spawn the player co-pilot ai" );
	pilot_ai.animname = "generic";
	pilot_ai setAnimTree();

	pilot_ai LinkTo( apache, "tag_passenger" );
	pilot_ai thread pilot_ai_start( owner, self, "tag_passenger" ); 
	
	pilot					= SpawnStruct();
	pilot.owner				= owner;
	pilot.vehicle			= apache;
	pilot.pilot_ai_spawner 	= pilot_ai_spawner;
	pilot.pilot_ai			= pilot_ai;
	pilot.type				= "pilot";
	pilot.weapon 			= [];
	
	pilot hud_init();
	
	pilot.weapon[ "hydra_lockOn_missile" ]	  = vehicle_scripts\_apache_player_missile_hydra_and_lockon::_init( owner, apache, pilot.hud );
	//pilot.weapon[ "lockOn_missile" ]		  = vehicle_scripts\_apache_player_lockon_missile::_init( owner, pilot.hud );
	//pilot.weapon[ "hydra_rocket_launcher" ] = vehicle_scripts\_apache_player_hydra_rocket_launcher::_init( owner, cockpit, pilot.hud );
	//pilot.weapon[ "raining_missile" ]		  = vehicle_scripts\_apache_player_raining_missile::_init( owner, pilot.hud );
	//pilot.weapon[ "shotgun_missile" ]		  = vehicle_scripts\_apache_player_shotgun_missile::_init( owner );
	//pilot.weapon[ "drone" ]				  = vehicle_scripts\_apache_player_mini_drone::_init( owner );
	
	pilot.currentWeapon = "hydra_lockOn_missile";
	
	pilot.vehicle.mgturret[ 0 ] ent_flag_init( "FLAG_turret_init" );
		
	pilot.vehicle.mgturret[ 0 ] thread turret_init( pilot.vehicle, pilot.owner );
	
	owner ent_flag_init( "FLAG_apache_pilot_has_changed_weapons" );
	owner ent_flag_init( "FLAG_apache_pilot_changed_weapons" );
	owner ent_flag_init( "FLAG_apache_pilot_ADS" );
	
	return pilot;
}

pilot_ai_start( owner, apache, tag )
{
	self endon( "death" );
	
	self childthread pilot_ai_anim( apache, tag );
	self thread pilot_ai_death( apache, tag );
	
	for ( ; ; )
	{
		self waittill( "LISTEN_end_pilot" );
		self HideOnClient( owner );
		self waittill( "LISTEN_start_pilot" );
		self ShowOnClient( owner );
	}
}

pilot_ai_anim( apache, tag )
{
	// End if the apache_player death requests a pilot death
	apache endon( "LISTEN_pilot_death" );
	
	for ( ; ; )
	{
						 //   guy    anime 								     tag   
		apache anim_generic( self , "helicopter_pilot1_idle"			  , tag );
		apache anim_generic( self , "helicopter_pilot1_twitch_lookback"	  , tag );
		apache anim_generic( self , "helicopter_pilot1_twitch_lookoutside", tag );
		apache anim_generic( self , "helicopter_pilot1_twitch_clickpannel", tag );
	}
}

pilot_ai_death( apache, tag )
{
	// Make sure this thread is cleaned up when the apache is deleted
	apache endon( "death" );
	
	// The apache main script sends this notification when it wants the pilot to die
	apache waittill( "LISTEN_pilot_death" );
	
	thread play_sound_in_space( "apache_player_pilot_death", self GetTagOrigin( "tag_eye" ) );
	apache thread anim_generic( self, "apache_cockpit_copilot_death", tag );
	
	// JC-ToDo: Apache pilot headshot blood fx should be on a notetrack
	wait 0.1;
	PlayFXOnTag( getfx( "FX_apache_pilot_shot_blood" ), self, "j_head" );
}

CONST_SPEED_ARROW_OFFSET_Y_MIN	= -118;
CONST_SPEED_ARROW_OFFSET_Y_MAX	= -400;

CONST_ELEVAT_ARROW_OFFSET_Y_MIN	= -119;
CONST_ELEVAT_ARROW_OFFSET_Y_MAX	= -395;
CONST_APACHE_Z_MIN				= 500;		// 128 - Good min value if you want the meter to represent the bounds of the level
CONST_APACHE_Z_MAX				= 3500;		// 4400 - Good max value if you want the meter to represent the bounds of the level

CONST_APACHE_OWNER_PITCH_MAX	= -30;
CONST_APACHE_OWNER_PITCH_MIN	= 30;


hud_init()
{	
	owner = self.owner;
	
	hud = [];
	
	// Reticle
	
	hud[ "mg_reticle" ] = owner createClientIcon( "apache_reticle", 128, 128 );
	hud[ "mg_reticle" ] setPoint( "CENTER", undefined, 0, 0 );
	hud[ "mg_reticle" ].alpha = 1.0;
	
	hud[ "mg_bar" ] = owner createClientIcon( "apache_mg_heat_back", 64, 6 );
	hud[ "mg_bar" ] setPoint( "BOTTOM", "BOTTOM", 0, -5 );
	hud[ "mg_bar" ].alpha = 1.0;
	hud[ "mg_bar" ] setParent( hud[ "mg_reticle" ] );
	
	hud[ "mg_warn" ] = owner createClientIcon( "apache_mg_heat_warn", 32, 32 );
	hud[ "mg_warn" ] setPoint( "TOP", "BOTTOM", 0, -9 );
	hud[ "mg_warn" ].alpha = 1.0;
	hud[ "mg_warn" ] setParent( hud[ "mg_bar" ] );
	
	// Compass
	
//	hud[ "compass_bg" ] = owner createClientIcon( "apache_compass_back", 512, 128 );
//	hud[ "compass_bg" ] setPoint( "BOTTOM", "TOP", 0, 42 );
//	hud[ "compass_bg" ].alpha = 1.0;
	
	// Hint
	
//	hud[ "compass_bg" ] = owner createClientIcon( "apache_hint_back", 1024, 128 );
//	hud[ "compass_bg" ] setPoint( "BOTTOM", "TOP", 0, 45 );
//	hud[ "compass_bg" ].alpha = 1.0;
	
	// Zoom
	
	hud[ "zoom_overlay" ] = owner createClientIcon( "apache_zoom_overlay", 256, 256 );
	hud[ "zoom_overlay" ] setPoint( "CENTER", undefined, 0, 0 );
	hud[ "zoom_overlay" ].alpha = 0.0;
	
	// Missile Roll
	
	hud[ "missile_roll" ] = [];
	
	// -- Roll BG
	
	hud[ "roll" ][ "bg" ] = owner createClientIcon( "apache_roll_back", 128, 32 );
	hud[ "roll" ][ "bg" ] setPoint( "TOP", "TOP", 0, 42 );
	hud[ "roll" ][ "bg" ].alpha = 1;
	
	// -- Roll Marker
	
	hud[ "roll" ][ "marker" ] = owner createClientIcon( "apache_roll_marker", 64, 64 );
	hud[ "roll" ][ "marker" ] setPoint( "TOP", "TOP", 0, 40 );
	hud[ "roll" ][ "marker" ].alpha = 1;
	
	// Speed
	
	hud[ "speed" ] = [];
	
	// -- Speed BG
	
	hud[ "speed" ][ "bg" ] = owner createClientIcon( "apache_speed_back", 128, 512 );
	hud[ "speed" ][ "bg" ] setPoint( "RIGHT", "RIGHT", 0, 0 );
	hud[ "speed" ][ "bg" ].alpha = 1.0;
	
	// -- Speed Arrow
	
	hud[ "speed" ][ "arrow" ] = owner createClientIcon( "apache_speed_arrow", 64, 32 );
	hud[ "speed" ][ "arrow" ] setPoint( "LEFT", "BOTTOM", -24, CONST_SPEED_ARROW_OFFSET_Y_MIN );
	hud[ "speed" ][ "arrow" ].alpha = 1.0;
	hud[ "speed" ][ "arrow" ] setParent( hud[ "speed" ][ "bg" ] );
	
	// -- Speed Arrow Number
	
	hud[ "speed" ][ "number" ] = owner createClientFontString( "objective", 1.0 );
	hud[ "speed" ][ "number" ] setPoint( "LEFT", "RIGHT", -10, 0 );
	hud[ "speed" ][ "number" ].color = CONST_COLOR_TEXT_ALTITUDE;
	hud[ "speed" ][ "number" ].alpha = 1.0;
	hud[ "speed" ][ "number" ].sort = -1;
	hud[ "speed" ][ "number" ] setParent( hud[ "speed" ][ "arrow" ] );
	hud[ "speed" ][ "number" ] SetText( "0" );
	
	hud[ "altitude" ] = [];
	
	// -- Line
	
	hud[ "altitude" ][ "line" ] = owner createClientIcon( "apache_altitude_back", 128, 512 );
	hud[ "altitude" ][ "line" ] setPoint( "LEFT", "LEFT", 0, 0 );
	hud[ "altitude" ][ "line" ].alpha = 1.0;
	
	// -- Arrow
	
	hud[ "altitude" ][ "arrow" ] = owner createClientIcon( "apache_altitude_arrow", 64, 32 );
	hud[ "altitude" ][ "arrow" ] setPoint( "RIGHT", "BOTTOM", 33, CONST_ELEVAT_ARROW_OFFSET_Y_MIN );
	hud[ "altitude" ][ "arrow" ].alpha = 1.0;
	hud[ "altitude" ][ "arrow" ] setParent( hud[ "altitude" ][ "line" ] );
	
	// -- Bottom Mark
	
	hud[ "bottom_mark" ] = owner createClientIcon( "apache_bottom_mark", 128, 6 );
	hud[ "bottom_mark" ] setPoint( "CENTER", "CENTER", 0, 120 );
	hud[ "bottom_mark" ].alpha = 1;
	
	self.hud = hud;
	
	self thread hud_update();
}

HUD_X_SHIFT 	= 8;
HUD_Y_SHIFT 	= 8;
HUD_SHIFT_TIME 	= 0.15;
HUD_SETTLE_TIME = 0.3;

HUD_MIN_SPEED = 1;

hud_update()
{
	self endon( "LISTEN_destroy_pilot" );
	
	owner 	= self.owner;
	hud 	= self.hud;
	vehicle = self.vehicle;
	
	// Roll logic does a lot of initial set up so it runs its own thread
	self childthread hud_update_roll();
	
	hud[ "speed" ][ "number" ].lastSpeed = Int( Floor( vehicle Vehicle_GetSpeed() ) );
	hud[ "speed" ][ "number" ] SetValue( hud[ "speed" ][ "number" ].lastSpeed );
	
	for ( ; ; wait 0.05 )
	{
		self hud_update_speed();
		//self hud_update_elevation();
		self hud_update_look_meter();
		
		// If HUD movement relative to player look is desired the targetting logic
		// will need to use 3D angles of the reticle position instead of GetPlayerAngles().
		// Otherwise weapons won't be aiming where the reticle is aiming.
//		rightStick = owner GetNormalizedCameraMovement();
//		
//		if ( rightStick[ 0 ] != lastPitch || rightStick[ 1 ] != lastYaw )
//		{
//			lastPitch 	= rightStick[ 0 ];
//			lastYaw 	= rightStick[ 1 ];
//			
//			time = ter_op( lastPitch == 0 && lastYaw == 0, HUD_SETTLE_TIME, HUD_SHIFT_TIME );
//	
//			hud[ "mg_reticle" ] setPoint( "CENTER", undefined, lastYaw * HUD_X_SHIFT, -1 * lastPitch * HUD_Y_SHIFT, time );
//		}
	}
}

MAX_MARKER_YAW 	= 44;
MAX_MARKER_ROLL = 35;

hud_update_roll()
{
	self endon( "LISTEN_destroy_pilot" );
	
	owner 	= self.owner;
	hud 	= self.hud;
	vehicle = self.vehicle;
	
	roll_max		= GetDvarFloat( "vehHelicopterMaxRoll" );
	roll_min		= -1 * roll_max;
	roll_range		= roll_max - roll_min;
	tick_range		= roll_range / 4.0;
	tick_range_half = ceil( tick_range * 0.5 );
	
	shaders =	[
					"apache_roll_marker_left2",
					"apache_roll_marker_left1",
					"apache_roll_marker",
					"apache_roll_marker_right1",
					"apache_roll_marker_right2"
				];
	
	shaders_by_tick = [];
	for ( i = 0; i < shaders.size; i++ )
	{
		shaders_by_tick[ Int( roll_min + ( tick_range * i ) ) ] = shaders[ i ];
	}
	
	shaders = undefined;
	
	shader_prev = "";
	
	while ( 1 )
	{
		roll			= clamp( vehicle.angles[ 2 ], roll_min, roll_max );
		roll_range_curr = Int( linear_interpolate( 1.0 - ( roll - roll_min ) / ( roll_range ), roll_min, roll_max ) );
		
		//DR: for audio purposes
		level.audio_roll = roll;		
		
		shader = undefined;
		
		foreach ( tick_curr, shader_curr in shaders_by_tick )
		{
			if ( roll_range_curr >= tick_curr - tick_range_half && roll_range_curr <= tick_curr + tick_range_half )
			{
				shader = shader_curr;
				break;
			}
		}
		
		AssertEx( IsDefined( shader ), "hud_update_roll() failed to find a valid roll shader." );
		
		if ( shader != shader_prev )
		{
			hud[ "roll" ][ "marker" ] SetShader( shader, 64, 64 );
			shader_prev = shader;
		}
		
		wait 0.05;
	}
}

hud_update_speed()
{	
	vehicle = self.vehicle;
	hud 	= self.hud;
	
	lastSpeed = hud[ "speed" ][ "number" ].lastSpeed;
	
	maxSpeed 		= GetDvarFloat( "vehHelicopterMaxSpeed" );
	
	// Make the arrow chunky by only updating n times out of the total 
	currentSpeed = Int( vehicle Vehicle_GetSpeed() );
	
	diff = abs( CONST_SPEED_ARROW_OFFSET_Y_MAX ) - abs( CONST_SPEED_ARROW_OFFSET_Y_MIN );	
	// Arrow
	offset_y = CONST_SPEED_ARROW_OFFSET_Y_MIN + -1 * Int( Max( 0, ( currentSpeed / maxSpeed ) * diff ) );
	offset_y = clamp( offset_y, CONST_SPEED_ARROW_OFFSET_Y_MAX, CONST_SPEED_ARROW_OFFSET_Y_MIN );
	
	interval = diff * 0.04;
	offset_y = Int( offset_y / interval ) * interval;
	
	hud[ "speed" ][ "arrow" ] setPoint( "LEFT", "BOTTOM", -24, offset_y, 0 );
	
	// Number
	if ( lastSpeed != currentSpeed )
	{	
		hud[ "speed" ][ "number" ] SetValue( currentSpeed );
		hud[ "speed" ][ "number" ].lastSpeed = currentSpeed;
	}
}

hud_update_look_meter()
{
	vehicle = self.vehicle;
	hud		= self.hud;
	owner	= self.owner;
	
	pitch_curr = owner GetPlayerAngles()[ 0 ];
	
	// Arrow
	ratio = 1 - ( pitch_curr - CONST_APACHE_OWNER_PITCH_MIN ) / ( CONST_APACHE_OWNER_PITCH_MAX - CONST_APACHE_OWNER_PITCH_MIN );
	
	diff = abs( CONST_ELEVAT_ARROW_OFFSET_Y_MAX ) - abs( CONST_ELEVAT_ARROW_OFFSET_Y_MIN );
	offset_y = CONST_ELEVAT_ARROW_OFFSET_Y_MIN + -1 * Max( 0, ratio * diff );
	offset_y = Int( clamp( offset_y, CONST_ELEVAT_ARROW_OFFSET_Y_MAX, CONST_ELEVAT_ARROW_OFFSET_Y_MIN ) );
	// Make the arrow chunky by only updating n times out of the total
	interval = diff * 0.04;
	offset_y = Int( offset_y / interval ) * interval;
	
	hud[ "altitude" ][ "arrow" ] setPoint( "RIGHT", "BOTTOM", 33, offset_y, 0 );
}


_start( ads_enabled )
{
	owner = self.owner;
	
	self.pilot_ai notify( "LISTEN_start_pilot" );
	
	self.weapon[ "hydra_lockOn_missile" ] thread vehicle_scripts\_apache_player_missile_hydra_and_lockon::_start();
	//self.weapon[ "hydra_rocket_launcher" ] thread vehicle_scripts\_apache_player_hydra_rocket_launcher::_start();
	//self.weapon[ "lockOn_missile" ] thread vehicle_scripts\_apache_player_lockon_missile::_start();
	//self.weapon[ "raining_missile" ] thread vehicle_scripts\_apache_player_raining_missile::_start();
	//self.weapon[ "shotgun_missile" ] thread vehicle_scripts\_apache_player_shotgun_missile::_start();
	//self.weapon[ "drone" ] thread vehicle_scripts\_apache_player_mini_drone::_start();
	
	// Give the player a mask
	self.hud_mask_model = Spawn( "script_model", owner GetEye() );
	self.hud_mask_model SetModel( "viewmodel_prototype_apache_visor" );
	self.hud_mask_model LinkToPlayerView( owner, "tag_origin", ( 7.5, 0.0, 0.3 ), ( 0, 0, 0 ), true );
	
	//self thermal_start();
	self hud_start();
	
	self thread monitorSaveRecentlyLoaded();
	
	self thread monitorTurretFire();
	self thread monitorWeaponChange();
	
	if ( ads_enabled )
	{
		self thread monitorADS();
	}
	self thread monitorThermalVision();
}

monitorSaveRecentlyLoaded()
{
	self endon( "LISTEN_end_pilot" );
	
	while( true ) 
	{
		if ( IsSaveRecentlyLoaded() )
			self.owner notify ( "SAVGAME_RELEASES_BUTTONS" );
		wait 0.05;
	}
}

// This thermal set up does it's best to make thermal vision look
// just like regular except guys are in thermal
//thermal_start()
//{
//	owner = self.owner;
//	
//	vision_set = GetDvar( "vision_set_current" );
//	if ( IsDefined( vision_set ) )
//	{
//		SetThermalBodyMaterial( "apache_enemy_thermalbody" );
//		
//		SetSavedDvar( "thermalBlurFactorNoScope", 0 );
//		
//		ent = get_vision_set_fog( vision_set );
//		if ( IsDefined( ent ) )
//		{
//			duration		  = 0.0;
//			color			  = ( 0, 0, 0 );
//			if ( IsDefined( ent.red ) && IsDefined( ent.green ) && IsDefined( ent.blue ) )
//				color = ( ent.red, ent.green, ent.blue );
//			hdr_color_intensity = ter_op( IsDefined( ent.HDRColorIntensity ), ent.HDRColorIntensity, 1 );
//			startDist		  = ter_op( IsDefined( ent.startDist ), ent.startDist, 0.01 );
//			halfwayDist		  = ter_op( IsDefined( ent.halfwayDist ), ent.halfwayDist, 0.02 );
//			maxOpacity		  = ter_op( IsDefined( ent.maxOpacity ), ent.maxOpacity, 0.01 );
//			sunColor		  = ( 0, 0, 0 );
//			if ( IsDefined( ent.sunRed ) && IsDefined( ent.sunGreen ) && IsDefined( ent.sunBlue ) )
//				sunColor = ( ent.sunRed, ent.sunGreen, ent.sunBlue );
//			hdr_sun_color_intensity = ter_op( IsDefined( ent.HDRSunColorIntensity ), ent.HDRSunColorIntensity, 1 );
//			sunDir			  = ter_op( IsDefined( ent.sunDir ), ent.sunDir, ( 0, 0, 0 ) );
//			sunBeginFadeAngle = ter_op( IsDefined( ent.sunBeginFadeAngle ), ent.sunBeginFadeAngle, 0 );
//			sunEndFadeAngle	  = ter_op( IsDefined( ent.sunEndFadeAngle ), ent.sunEndFadeAngle, 0 );
//			normalFogScale	  = ter_op( IsDefined( ent.normalFogScale ), ent.normalFogScale, 0 );
//
//			owner SetThermalFog(
//							duration,
//							color,
//							hdr_color_intensity,
//							startDist,
//							halfwayDist,
//							maxOpacity,
//							sunColor,
//							hdr_sun_color_intensity,
//							sunDir,
//							sunBeginFadeAngle,
//							sunEndFadeAngle,
//							normalFogScale
//						);
//		}
//		
//		owner VisionSetThermalForPlayer( vision_set, 0 );
//	}
//}

hud_start()
{
	deep_array_thread( self.hud, ::set_key, [ 1, "alpha" ] );
}

TURRET_PROJ_FLASH_SPAWN_OFFSET_UP = 0;

turret_init( vehicle, owner )
{
	Assert( IsDefined( vehicle ) );
	
	self DontCastShadows();
	
	self.owner = owner;
	
	self ent_flag_set( "FLAG_turret_init" );
}

// TODO: When new apache cockpit comes in. try to move this back into .gdt

TURRET_PROJ_TRAIL_SPAWN_OFFSET_RIGHT 	= 8;
TURRET_PROJ_TRAIL_SPAWN_OFFSET_UP		= 8;
TURRET_PROJ_FLASH_SPAWN_OFFSET_FWD		= 0;

monitorTurretFire()
{
	owner	= self.owner;
	vehicle = self.vehicle;
	turret	= vehicle.mgturret[ 0 ];
	
	owner endon( "LISTEN_end_pilot" );
	
	turret ent_flag_wait( "FLAG_turret_init" );
	
	self childthread monitorTurretEarthquake();
	self childthread monitorTurretLookAt();
	
	projFX 	= getfx( "FX_apache_pilot_turret_projectile" );
	flashFX = getfx( "FX_apache_pilot_turret_flash_view" );
	
	for ( ; ; )
	{
		vehicle waittill( "turret_fire" );

		turret ShootTurret();
		
		angles 		= turret GetTagAngles( "tag_flash" );
		fwd 		= AnglesToForward( angles );
		right		= AnglesToRight( angles );
		up			= AnglesToUp( angles );
		
		offsetRight = RandomFloatRange( -1 * TURRET_PROJ_TRAIL_SPAWN_OFFSET_RIGHT, TURRET_PROJ_TRAIL_SPAWN_OFFSET_RIGHT );
		offsetUp	= RandomFloatRange( -1 * TURRET_PROJ_TRAIL_SPAWN_OFFSET_UP, TURRET_PROJ_TRAIL_SPAWN_OFFSET_UP );
		
		PlayFX( projFX, turret GetTagOrigin( "tag_flash" ) + offsetRight * right + offsetUp * up, fwd );
		
		// JC-ToDo: Potentially offset this in the effect to be pushed forward and up. Also the turret link point should be more forward.
		PlayFXOnTag( flashFX, turret, "tag_flash" );
	}
}

CONST_APACHE_TURRET_MIN_TRACE_DIST	= 512;
CONST_APACHE_TURRET_TRACE_LENGTH	= 10000;

monitorTurretLookAt( vehicle, owner )
{
	owner	= self.owner;
	vehicle = self.vehicle;
	turret	= vehicle.mgturret[ 0 ];
	
	angles 		= owner GetPlayerAngles();
	origin 		= owner GetEye();
	fwd 		= AnglesToForward( angles );
	dist 		= CONST_APACHE_TURRET_TRACE_LENGTH;
	lastPos 	= origin + dist * fwd;
	myTarget 	= Spawn( "script_model", lastPos );
	myTarget SetModel( "tag_origin" );
	
	lastTraceTime = GetTime();
	
	turret.myTarget = myTarget;
	
	turret SetTargetEntity( myTarget );
	
	for ( ; ; wait 0.05 )
	{
		angles		  = owner GetPlayerAngles();
		fwd			  = AnglesToForward( angles );
		eyePos		  = owner GetEye();
		start		  = eyePos + CONST_APACHE_TURRET_MIN_TRACE_DIST * fwd;
		end			  = start + CONST_APACHE_TURRET_TRACE_LENGTH * fwd;
		trace		  = BulletTrace( start, end, false, vehicle );
		dist		  = trace[ "fraction" ] * CONST_APACHE_TURRET_TRACE_LENGTH;
		lastTraceTime = GetTime();
		myTarget.origin = eyePos + ( CONST_APACHE_TURRET_MIN_TRACE_DIST + dist ) * fwd;
	}
}

monitorTurretEarthquake()
{
	owner = self.owner;
	
	owner NotifyOnPlayerCommand( "LISTEN_startTurretFire", "+attack" );
	owner NotifyOnPlayerCommand( "LISTEN_stopTurretFire" , "-attack" );
	
	for ( ; ; )
	{
		owner waittill( "LISTEN_startTurretFire" );
		
		self childthread doTurretEarthQuake();
		owner childthread player_poll_button_release_and_notify( "attack", "LISTEN_stopTurretFire" );
		
		owner waittill( "LISTEN_stopTurretFire" );
	}
}

doTurretEarthQuake()
{
	owner = self.owner;
	
	owner endon( "LISTEN_stopTurretFire" );
	
	wait 0.1;
	
	for( ; ; wait 0.1 )
		Earthquake( 0.1, 0.5, owner.origin, 512 );
}


// The button must be: "frag", "ads", "attack", "melee", "use", "vehicle_attack", "secondary_attack_off_hand"
player_poll_button_release_and_notify( button, player_notify )
{
	AssertEx( IsDefined( player_notify ) && IsString( player_notify ), "player_poll_button_release_and_notify() not passed notify string." );
	AssertEx( IsDefined( self ) && IsPlayer( self ), "player_poll_button_release_and_notify() called on non-player." );
	
	self endon( "death" );
	self endon( player_notify );
	
	// Wait first in case the function waiting for this notification is called after this
	// function is threaded off
	waittillframeend;

	while ( 1 )
	{
		
		if ( !self button_pressed_from_string( button ) )
		{
			self notify( player_notify );
			break;
		}
		wait 0.05;
	}
}

// Valid Button Strings Are: "frag,ads,attack,melee,use,vehicle_attack,secondary_attack_off_hand"
button_pressed_from_string( button )
{
	/#
	button_names_str = "frag,ads,attack,melee,use,vehicle_attack,secondary_attack_off_hand";
	button_names	 = StrTok( button_names_str, "," );
	button_valid	 = IsDefined( button ) && IsString( button ) && array_contains( button_names, button );
	AssertEx( button_valid, "player_poll_button_release_and_notify() passed invalid valid button string. Valid strings are: " + button_names_str );
	#/
	
	func = undefined;
	param = undefined;
	switch ( button )
	{
		case "frag":
			func = ::FragButtonPressed;
			break;
		case "ads":
			func = ::AdsButtonPressed;
			param = true;
			break;
		case "attack":
			func = ::AttackButtonPressed;
			break;
		case "melee":
			func = ::MeleeButtonPressed;
			break;
		case "use":
			func = ::UseButtonPressed;
			break;
		case "vehicle_attack":
			func = ::VehicleAttackButtonPressed;
			break;
		case "secondary_attack_off_hand":
			func = ::SecondaryOffhandButtonPressed;
			break;
		default:
			AssertMsg( "button_pressed_func_from_string() switch didn't handle button string: " + button );
			break;
	}
	
	result = undefined;
	if ( IsDefined( param ) )
	{
		result = self call [[ func ]]( param );
	}
	else
	{
		result = self call [[ func ]]();
}

	return result;
}

DEFAULT_FOV				 = 65;
DEFAULT_FOV_ADS			 = 15;
DEFAULT_FOV_ADS_TIME_IN	 = 0.15;
DEFAULT_FOV_ADS_TIME_OUT = 0.2;

fov_get_default()
{
	return DEFAULT_FOV;
}

fov_get_ads()
{
	return DEFAULT_FOV_ADS;
}

monitorADS()
{
	owner 	= self.owner;
	
	self endon( "LISTEN_end_pilot" );
	self.adsToggled					 = false;
	self.adsZoomed					 = false;
	zoomStart = false;
	self.hud[ "zoom_overlay" ].alpha = 0.0;
	thread monitorADSHold();
	thread monitorADSToggle();
	msg = "LISTEN_apache_player_stop_ADS";
	
	while ( 1 )
	{
		skipWait = false;
		if( self.adsZoomed && zoomStart && !owner AdsButtonPressed() )
		{
			msg = "LISTEN_apache_player_stop_ADS";
			skipWait = true;
		}
		if ( !skipWait )
			msg = owner waittill_any_return( "LISTEN_apache_player_toggle_ADS", "LISTEN_apache_player_start_ADS", "LISTEN_apache_player_stop_ADS", "SAVGAME_RELEASES_BUTTONS" );
		if ( msg == "SAVGAME_RELEASES_BUTTONS" )
			continue;
		toggleCMd = ( msg == "LISTEN_apache_player_toggle_ADS" );
		zoomStart = ( msg == "LISTEN_apache_player_start_ADS" );
		zoomEnd = ( msg == "LISTEN_apache_player_stop_ADS" );
		if ( self.adsZoomed )
		{
			if ( self.adsToggled )
			{
				if ( toggleCMd || zoomEnd)
				{
					self.adsToggled = false;
					self.adsZoomed	= false;
					self monitorADS_zoom_out();
				}
			}
			else if ( zoomEnd )
			{
				self monitorADS_zoom_out();
				self.adsZoomed = false;
			}
		}
		else
		{
			self.adsToggled = false;
			if ( toggleCMd )
			{
				self.adsToggled = true;
				self.adsZoomed	= true;
				self monitorADS_zoom_in();
			}
			else if ( zoomStart )
			{
				self.adsZoomed = true;
				self monitorADS_zoom_in();
			}
		}
	}
}

monitorADSToggle()
{
	owner 	= self.owner;
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_toggle_ADS", "+sprint_zoom" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_toggle_ADS", "+sprint" );
	//owner NotifyOnPlayerCommand( "LISTEN_apache_player_toggle_ADS", "+breath_sprint" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_toggle_ADS", "+toggleads_throw" );
	
}

monitorADSHold()
{
	owner 	= self.owner;

	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_ADS", "+speed" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_ADS", "+speed_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_ADS", "+ads_akimbo_accessible" );
	
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_ADS", "-speed" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_ADS", "-speed_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_ADS", "-ads_akimbo_accessible" );
}

monitorADS_blend_dof( zoom_in )
{
	owner = self.owner;
	
	AssertEx( !is_coop(), "Depth of Field should not be adjusted when in coop." );
	
	// Clear previous calls to blend dof
	self notify ( "monitorADS_blend_dof" );
	self endon( "monitorADS_blend_dof" );
	
	self endon( "LISTEN_end_pilot" );
	
	// Flag the ADS at the end of zoom in and
	// at the beginning of the zoom out. Keeps
	// the circle at least as big as the player's
	// visual circle, never smaller.
	if ( zoom_in )
	{
		maps\_art::dof_enable_script( 0, 207, 5.4, 70000, 130000, 0.0, DEFAULT_FOV_ADS_TIME_IN );
		wait DEFAULT_FOV_ADS_TIME_IN;
		owner ent_flag_set( "FLAG_apache_pilot_ADS" );
}
	else
	{
		maps\_art::dof_disable_script( DEFAULT_FOV_ADS_TIME_OUT );
		owner ent_flag_clear( "FLAG_apache_pilot_ADS" );
	}
}

monitorADS_zoom_elem_offset( offset_x, offset_y )
{
	if ( !IsDefined( self.xOffset_default ) )
		self.xOffset_default = self.xOffset;
	if ( !IsDefined( self.yOffset_default ) )
		self.yOffset_default = self.yOffset;
	
	offset_x = ter_op( IsDefined( offset_x ), offset_x, self.xOffset_default );
	offset_y = ter_op( IsDefined( offset_y ), offset_y, self.yOffset_default );
	
	self setPoint( self.point, self.relativePoint, offset_x, offset_y );
}

monitorADS_zoom_elem_reset()
{
	if ( IsDefined( self.xOffset_default ) && IsDefined( self.yOffset_default ) )
	{
		self setPoint( self.point, self.relativePoint, self.xOffset_default, self.yOffset_default );
		
		self.xOffset_default = undefined;
		self.yOffset_default = undefined;
	}
}

monitorADS_zoom_hud_delay( turn_on, delay_sec )
{
	self notify( "monitorADS_zoom_overlay_delay" );
	self endon( "monitorADS_zoom_overlay_delay" );
	
	// Grab needed struct references to access hud elems
	defense_info = self.vehicle.heli.missileDefense;
	weapon_info	 = self.weapon[ self.weapon_curr ];
	
	if ( turn_on )
	{
		if ( IsDefined( delay_sec ) )
		{
			wait delay_sec;
		}
		
		deep_array_thread( self.hud, ::set_key, [ 0.0, "alpha" ] );	
		self.hud[ "mg_reticle" ].alpha = 1.0;
		
		self.hud[ "zoom_overlay" ].alpha = 1.0;
		
		// Update Missile Ammo HUD location
		if ( IsDefined( weapon_info.hud ) && IsDefined( weapon_info.hud[ "missile_bg" ] ) )
		{
			weapon_info.hud[ "missile_bg" ] monitorADS_zoom_elem_offset( 230, 101 );
			weapon_info.hud[ "missile_straight_bg" ] monitorADS_zoom_elem_offset( 230, 61 );

		}
		
		// Update Flare Ammo and Warning HUD location
		if ( IsDefined( defense_info.hud ) )
		{
			if ( IsDefined( defense_info.hud[ "flares" ] ) && IsDefined( defense_info.hud[ "flares" ][ "back" ] ) )
			{
				defense_info.hud[ "flares" ][ "back" ] monitorADS_zoom_elem_offset( -230, 101 );
			}
			
			if ( IsDefined( defense_info.hud[ "warning" ] ) && IsDefined( defense_info.hud[ "warning" ][ "bg_lock_left" ] ) )
			{
				defense_info.hud[ "warning" ][ "bg_lock_left" ] monitorADS_zoom_elem_offset( -230 );
			}
			
			if ( IsDefined( defense_info.hud[ "warning" ] ) && IsDefined( defense_info.hud[ "warning" ][ "bg_lock_right" ] ) )
			{
				defense_info.hud[ "warning" ][ "bg_lock_right" ] monitorADS_zoom_elem_offset( 230 );
			}
		}
		
		// Let reticle overlap for a frame to create a pop
		wait 0.05;
		self.hud[ "mg_reticle" ].alpha = 0.0;
	}
	else
	{
		if ( IsDefined( delay_sec ) )
		{
			wait delay_sec;
		}
		
		deep_array_thread( self.hud, ::set_key, [ 1.0, "alpha" ] );
		
		// Update Missile Ammo HUD location
		if ( IsDefined( weapon_info.hud ) && IsDefined( weapon_info.hud[ "missile_bg" ] ) )
		{
			weapon_info.hud[ "missile_bg" ] monitorADS_zoom_elem_reset();
			weapon_info.hud[ "missile_straight_bg" ] monitorADS_zoom_elem_reset();
		}
		
		// Update Flare Ammo and Warning HUD location
		if ( IsDefined( defense_info.hud ) )
		{
			if ( IsDefined( defense_info.hud[ "flares" ] ) && IsDefined( defense_info.hud[ "flares" ][ "back" ] ) )
			{
				defense_info.hud[ "flares" ][ "back" ] monitorADS_zoom_elem_reset();
			}
			
			if ( IsDefined( defense_info.hud[ "warning" ] ) && IsDefined( defense_info.hud[ "warning" ][ "bg_lock_left" ] ) )
			{
				defense_info.hud[ "warning" ][ "bg_lock_left" ] monitorADS_zoom_elem_reset();
			}
			
			if ( IsDefined( defense_info.hud[ "warning" ] ) && IsDefined( defense_info.hud[ "warning" ][ "bg_lock_right" ] ) )
			{
				defense_info.hud[ "warning" ][ "bg_lock_right" ] monitorADS_zoom_elem_reset();
			}
		}
		
		// Let zoom overlay overlap for a frame to create a pop
		wait 0.05;
		self.hud[ "zoom_overlay" ].alpha = 0.0;
	}
}

monitorADS_zoom_in()
{
	owner = self.owner;
	owner LerpFOV( DEFAULT_FOV_ADS, DEFAULT_FOV_ADS_TIME_IN );
	
	if ( !is_coop() )
	{
		self monitorADS_blend_dof( true );
	}

	self thread monitorADS_zoom_hud_delay( true );
}

monitorADS_zoom_out() 
{
	owner = self.owner;
	
	owner LerpFOV( DEFAULT_FOV, DEFAULT_FOV_ADS_TIME_OUT );
	if ( !is_coop() )
	{
		self monitorADS_blend_dof( false );
	}

	self thread monitorADS_zoom_hud_delay( false );
}

monitorThermalVision()
{
	self endon( "LISTEN_end_pilot" );
	owner = self.owner;
	self.thermal_state = "ON_PULSE";
	//owner ThermalVisionOn();
}

monitorWeaponChange()
{
	self endon( "LISTEN_end_pilot" );
	
	owner 	= self.owner;
	
	weapons = [];
	i 		= 0;
	
	foreach ( weaponName, weapon in self.weapon )
	{
		weapons[ weapons.size ] = weaponName;
		
		if ( weaponName == self.currentWeapon )
		{
			i = weapons.size - 1;
			self activateWeapon( weaponName );
		}
	}

	numWeapons = weapons.size;
	
	// Don't monitor weapon change if there's only 1 weapon
	if ( numWeapons == 1 )
		return;
	
	// XBOX: Y - Must be below early out otherwise missile systems
	// will think a weapon switch occurred
	owner NotifyOnPlayerCommand( "LISTEN_pilot_weaponSwitch", "weapnext" );
	
	for ( ; ; wait 0.1 )
	{
		owner ent_flag_clear( "FLAG_apache_pilot_changed_weapons" );
		owner waittill( "LISTEN_pilot_weaponSwitch" );
		owner ent_flag_set( "FLAG_apache_pilot_has_changed_weapons" );
		owner ent_flag_set( "FLAG_apache_pilot_changed_weapons" );
		
		self deActivateWeapon( self.currentWeapon );
		
		i++;
		i 					= i % numWeapons;
		self.currentWeapon 	= weapons[ i ];
		
		self activateWeapon( self.currentWeapon );
	}
}

activateWeapon( weaponName )
{
	Assert( IsDefined( self.weapon[ weaponName ] ) );
	
	switch ( weaponName )
	{
		case "hydra_lockOn_missile":
			self.weapon[ weaponName ] vehicle_scripts\_apache_player_missile_hydra_and_lockon::activate();
			break;
//		case "lockOn_missile":
//			self.weapon[ weaponName ] vehicle_scripts\_apache_player_lockon_missile::activate();
//			break;
//		case "hydra_rocket_launcher":
//			self.weapon[ weaponName ] vehicle_scripts\_apache_player_hydra_rocket_launcher::activate();
//			break;
//		case "raining_missile":
//			self.weapon[ weaponName ] vehicle_scripts\_apache_player_raining_missile::activate();
//			break;
		default:
			AssertMsg( "Invalid apache weapon name: " + weaponName );
			break;
	}
	
	self.weapon_curr = weaponName;
}

deActivateWeapon( weaponName )
{
	Assert( IsDefined( self.weapon[ weaponName ] ) );
	
	switch ( weaponName )
	{
		case "hydra_lockOn_missile":
			self.weapon[ weaponName ] vehicle_scripts\_apache_player_missile_hydra_and_lockon::deActivate();
			break;
//		case "lockOn_missile":
//			self.weapon[ weaponName ] vehicle_scripts\_apache_player_lockon_missile::deActivate();
//			break;
//		case "hydra_rocket_launcher":
//			self.weapon[ weaponName ] vehicle_scripts\_apache_player_hydra_rocket_launcher::deActivate();
//			break;
//		case "raining_missile":
//			self.weapon[ weaponName ] vehicle_scripts\_apache_player_raining_missile::deActivate();
//			break;
		default:
			AssertMsg( "Invalid apache weapon name: " + weaponName );
			break;
	}
}

_end()
{
	owner = self.owner;
	
	self notify( "LISTEN_end_pilot" );
	owner notify( "LISTEN_end_pilot" );
	self.pilot_ai notify( "LISTEN_end_pilot" );
	
	deep_array_thread( self.hud, ::set_key, [ 0, "alpha" ] );
	owner ThermalVisionOff();
	
	self.weapon[ "hydra_lockOn_missile" ] vehicle_scripts\_apache_player_missile_hydra_and_lockon::_end();
	
	maps\_art::dof_disable_script( DEFAULT_FOV_ADS_TIME_OUT );
	
	//self.weapon[ "hydra_rocket_launcher" ] vehicle_scripts\_apache_player_hydra_rocket_launcher::_end();
	//self.weapon[ "lockOn_missile" ]  vehicle_scripts\_apache_player_lockon_missile::_end();
	//self.weapon[ "raining_missile" ]  vehicle_scripts\_apache_player_raining_missile::_end();
	//self.weapon[ "shotgun_missile" ]  vehicle_scripts\_apache_player_shotgun_missile::_end();
	//self.weapon[ "drone" ]  vehicle_scripts\_apache_player_mini_drone::_end();
	
}

_destroy()
{
	owner = self.owner;
	
	self _end();
	
	owner ent_flag_clear( "FLAG_apache_pilot_has_changed_weapons",true );
	owner ent_flag_clear( "FLAG_apache_pilot_changed_weapons",true );
	owner ent_flag_clear( "FLAG_apache_pilot_ADS",true );
	
	self.pilot_ai notify( "death" );
	self notify( "LISTEN_destroy_pilot" );
	owner notify( "LISTEN_destroy_pilot" );
	
	deep_array_call( self.hud, ::Destroy );
	
	self.pilot_ai Delete();
	self.vehicle.mgturret[ 0 ].myTarget Delete();
	
	self.weapon[ "hydra_lockOn_missile" ]  vehicle_scripts\_apache_player_missile_hydra_and_lockon::_destroy();
	//self.weapon[ "lockOn_missile" ]  vehicle_scripts\_apache_player_lockon_missile::_destroy();
	//self.weapon[ "hydra_rocket_launcher" ] vehicle_scripts\_apache_player_hydra_rocket_launcher::_destroy();
	//self.weapon[ "raining_missile" ]  vehicle_scripts\_apache_player_raining_missile::_destroy();
	//self.weapon[ "shotgun_missile" ]  vehicle_scripts\_apache_player_shotgun_missile::_destroy();
	//self.weapon[ "drone" ]  vehicle_scripts\_apache_player_mini_drone::_destroy();
	
	self.hud_mask_model Delete();
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
