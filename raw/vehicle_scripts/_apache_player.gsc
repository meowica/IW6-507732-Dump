#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

/*QUAKED script_vehicle_apache_player (1 0 0) (-16 -16 -24) (16 16 32) USABLE SPAWNER

This will be added to your precache script when compile with Repackage Zone/Script:

vehicle_scripts\_apache_player::main( "apache_cockpit_player", undefined, "script_vehicle_apache_player" );

These will be added to your levels CSV when compile with Repackage Zone/Script:

include,vehicle_apache_player

defaultmdl="apache_cockpit_player"
default:"vehicletype" "apache_player"
default:"script_team" "allies"
*/

#using_animtree( "vehicles" );

main( model, type, classname )
{
	build_template( "apache_player", model, type, classname );
	build_localinit( ::init_local );
	build_team( "allies" );
	
	build_drive( %apache_cockpit_rotor, undefined, 0 );
	
	build_life( 10000, 5000, 15000 );
	build_is_helicopter();
	build_treadfx( classname, "default", "fx/treadfx/heli_dust_default", false );

	
	// JC-ToDo: This turret should be on tag_turret. Move once the turret tag is adjusted by rigging.
	build_turret( "apache_pilot_turret", "tag_barrel", "vehicle_apache_mg", undefined, "manual", undefined, 20, 0 ); //, ( 128, 0, -16 ) );
	
	_precache();
	_fx();
	_flags();
	

}

init_local()
{
	self.originheightoffset = 162;
	_init();
	self DontCastShadows();
}

_precache()
{
	PrecacheDigitalDistortCodeAssets();
	
	PreCacheModel( "apache_cockpit_player" );
	PreCacheModel( "apache_cockpit_player_pipe" );
	
	PreCacheRumble( "heavygun_fire" );
	PreCacheRumble( "damage_heavy" );
	PreCacheRumble( "damage_light" );
	PreCacheRumble( "minigun_rumble" );

	vehicle_scripts\_apache_player_targeting::_precache();
	vehicle_scripts\_chopper_player_missile_defense::_precache();
	vehicle_scripts\_apache_player_pilot::_precache();
	vehicle_scripts\_apache_player_audio::_precache();
	
	post_load_precache( vehicle_scripts\_apache_player_difficulty::difficulty );
//	vehicle_scripts\_apache_player_guncamera::_precache();
}

_init()
{	
	//maps\_helicopter_battlechatter::init();
}

_flags()
{
	flag_init( "FLAG_apache_crashing" );
}

_fx()
{
	// Damage and Death Fx
	level._effect[ "apache_player_dlight_red_flicker" ] = LoadFX( "fx/_requests/apache/dlight_red_flicker" );
	level._effect[ "apache_player_cockpit_smoke"	  ] = LoadFX( "fx/_requests/apache/cockpit_smoke" );
	level._effect[ "apache_player_cockpit_sparks_v1"  ] = LoadFX( "fx/_requests/apache/cockpit_sparks_v1" );
	level._effect[ "apache_player_cockpit_sparks_v2"  ] = LoadFX( "fx/_requests/apache/cockpit_sparks_v2" );
	
	// Not yet in
	level._effect[ "apache_player_cockpit_explosion"  ] = LoadFX( "fx/_requests/apache/cockpit_explosion" );
	level._effect[ "apache_player_cockpit_pipe_hiss"  ] = LoadFX( "vfx/moments/oil_rocks/heli_pipe_snap" );
	
	//enable_treadfx();
}

enable_treadfx()
{
	maps\_treadfx::setallvehiclefx( "player", "fx/treadfx/heli_dust_default" );
	maps\_treadfx::setvehiclefx( "player", "water", "fx/treadfx/heli_water" );
	maps\_treadfx::setvehiclefx( "player", "snow" , "fx/treadfx/heli_snow_default" );
	maps\_treadfx::setvehiclefx( "player", "slush", "fx/treadfx/heli_snow_default" );
	maps\_treadfx::setvehiclefx( "player", "ice"  , "fx/treadfx/heli_snow_default" );
}

_globals()
{
}

DEFAULT_FOV				 = 65;
DEFAULT_SPEED			 = 120;
DEFAULT_ACCEL			 = 60;

_start( player, altitude_control, auto_flares )
{	
	AssertEx( IsDefined( player ) && IsPlayer( player ), "_apache_player::_start() passed invalid player ref." );
	AssertEx( IsDefined( auto_flares ), "_apache_player::_start() call didn't have valid auto_flares param." );
	
	heli		 = SpawnStruct();
	self.heli	 = heli;
	
	player.riding_heli = self;
	heli.owner	 = player;
	heli.vehicle = self;
	
	heli.cover_warnings_disabled 	= level.cover_warnings_disabled;
	heli.treadfx_maxheight			= level.treadfx_maxheight;
	heli.g_friendlyNameDist			= GetDvarInt( "g_friendlyNameDist" );
	heli.hud_showStance				= GetDvarInt( "hud_showStance" );
	heli.compass					= GetDvarInt( "compass" );

	heli.targeting		= vehicle_scripts\_apache_player_targeting::_init( player );
	heli.pilot 			= vehicle_scripts\_apache_player_pilot::_init( self, player );
	heli.audio			= vehicle_scripts\_apache_player_audio::_init( self, player );
//	heli.gunCamera 		= vehicle_scripts\_apache_player_guncamera::_init( self, player );
	heli.missileDefense = vehicle_scripts\_chopper_player_missile_defense::_init( self, player, auto_flares );
	
	heli.cockpit_tubes = spawn( "script_model", self.origin );
	heli.cockpit_tubes.angles = self.angles;
	heli.cockpit_tubes SetModel( "apache_cockpit_player_pipe" );
	heli.cockpit_tubes LinkTo( self, "tag_origin" );
	
	
	level.cover_warnings_disabled 	= true;
	level.treadfx_maxheight 		= 9000;

	SetSavedDvar( "g_friendlyNameDist", 150000 );
	SetSavedDvar( "hud_showStance"	  , 0 );
	SetSavedDvar( "compass"			  , 1 );
	
	heli ent_flag_init( "FLAG_sprinting" );
	heli ent_flag_init( "FLAG_pilot_active" );
	heli ent_flag_init( "FLAG_gunCamera_active" );
	
	player ent_flag_init( "FLAG_apache_player_move_up" );
	player ent_flag_init( "FLAG_apache_player_used_move_up" );
	player ent_flag_init( "FLAG_apache_player_move_down" );
	player ent_flag_init( "FLAG_apache_player_used_move_down" );
	player ent_flag_init( "FLAG_apache_pilot_active" );
	player ent_flag_init( "FLAG_apache_gunCamera_active" );
	
	self aircraft_wash();

	// Removed for now and set flags below this:
//	self thread monitor_pilotAndGunCameraSwitch();
	heli ent_flag_set( "FLAG_pilot_active" );
	heli.owner ent_flag_set( "FLAG_apache_pilot_active" );
	
	self thread monitorMachinegun();
	self thread monitorHealth();
	self thread monitorCockpitAnims();
	
	self thread monitorSprint();

	altitude_control = ter_op( IsDefined( altitude_control ), altitude_control, false );
	if ( altitude_control )
	{
		self thread monitorMoveUp();
		self thread monitorMoveDown();
		
		removeAltituedMesh();
	}
	else
	{
		self thread monitorAltitude();
	}
	//self thread maps\_helicopter_battlechatter::init_chatter();
	
	heli.targeting thread vehicle_scripts\_apache_player_targeting::_start();
	heli.missileDefense thread vehicle_scripts\_chopper_player_missile_defense::_start();
	heli.pilot vehicle_scripts\_apache_player_pilot::_start( !altitude_control );
	heli.audio vehicle_scripts\_apache_player_audio::_start();
	
	//---------------------------------------//
	// Apache Dvars
	//---------------------------------------//
	
	// Dvars which need to be saved
	heli.fov_orig = DEFAULT_FOV;
	player LerpFOV( DEFAULT_FOV, 0.1 );
	
	heli.pitch_offset_ground = 25.0;
	heli.pitch_offset_mid	 = 12.0;
	heli.pitch_offset_air	 = 9.0;
	SetSavedDvar( "vehHelicopterPitchOffset", heli.pitch_offset_ground );
	
	heli.pitch_max = 10.0;
	SetSavedDvar( "vehHelicopterMaxPitch", heli.pitch_max );
	
	// Dvars that need to be set once
	//SetSavedDvar( "vehHelicopterMaxRoll", 20.0 );
	SetSavedDvar( "vehHelicopterSoftCollisions", 1 );
	SetSavedDvar( "vehHelicopterControlSystem", 1 );
	SetSavedDvar( "vehHelicopterDecelerationFwd", 1.0 );
	SetSavedDvar( "vehHelicopterMaxAccel", DEFAULT_ACCEL );
	SetSavedDvar( "vehHelicopterMaxSpeed", DEFAULT_SPEED );
	SetSavedDvar( "vehHelicopterMaxYawAccel", 700.0 );
	SetSavedDvar( "vehHelicopterMaxYawRate", 120.0 );
	SetSavedDvar( "vehHelicopterPitchLock", 0 );
	
	// JC-ToDo: Need to revisit tilt from look vars once a dead zone is added
	SetSavedDvar( "vehHelicopterTiltFromLook", 0.0 );
	SetSavedDvar( "vehHelicopterTiltFromLookRate", 0.0 );
	
	SetSavedDvar( "vehHelicopterTiltSpeed", 1.2 );
	SetSavedDvar( "vehHelicopterTiltFromFwdAndYaw", 50 );
	SetSavedDvar( "vehHelicopterTiltFromFwdAndYaw_VelAtMaxTilt", 0.8 );
	
	
	// Altitude control dependent dvars
	if ( altitude_control )
	{
		SetSavedDvar( "vehHelicopterControlsAltitude", 3 );
		SetSavedDvar( "vehHelicopterLookaheadTime", 1.0 );
		SetSavedDvar( "vehHelicopterMaxAccelVertical", 90.0 );
		SetSavedDvar( "vehHelicopterMaxSpeedVertical", 65.0 );
	}
	else
	{
		SetSavedDvar( "vehHelicopterControlsAltitude", 4 );
		// This is reduced to increased the rate which the chopper adjusts to height mesh
		SetSavedDvar( "vehHelicopterLookaheadTime", 0.4 );
		SetSavedDvar( "vehHelicopterMaxAccelVertical", 200.0 );
		SetSavedDvar( "vehHelicopterMaxSpeedVertical", 300.0 );
	}
	
	player DisableWeaponSwitch();
	player AllowCrouch( false );
	player AllowProne( false );
	player AllowJump( false );
	
	// Before mounting the chopper, make sure the player's yaw matches the chopper's yaw.
	// This fixes the case where the chopper starts adjusting for the player angles as soon
	// as he's placed in the vehicle
	player SetPlayerAngles( ( 0, self.angles[ 1 ], 0 ) );
	
	player player_mount_vehicle( self );
	
}

setMaxHeight_overTime( height, time )
{
	Assert( IsDefined( height ) );
	
	if ( IsDefined( time ) )
	{
		time 	= Max( time, 0.05 );
		min 	= GetDvarFloat( "vehHelicopterMaxAltitude" );
		
		for ( elapsed = 0; elapsed < time; elapsed += 0.05 )
		{
			SetSavedDvar( "vehHelicopterMaxAltitude", min + ( elapsed / time ) * ( height - min ) );
			wait 0.05;
		}
	}
	else
		SetSavedDvar( "vehHelicopterMaxAltitude", height );
}

setMinHeight_overTime( height, time )
{
	Assert( IsDefined( height ) );
	
	if ( IsDefined( time ) )
	{
		time 	= Max( time, 0.05 );
		min 	= GetDvarFloat( "vehHelicopterMinAltitude" );
		
		for ( elapsed = 0; elapsed < time; elapsed += 0.05 )
		{
			SetSavedDvar( "vehHelicopterMinAltitude", min + ( elapsed / time ) * ( height - min ) );
			wait 0.05;
		}
	}
	else
		SetSavedDvar( "vehHelicopterMinAltitude", height );
	
}

_end()
{
	// If the apache is already crashing don't honor calls to _end()
	if ( self ent_flag_exist( "ENT_FLAG_heli_destroyed" ) && self ent_flag( "ENT_FLAG_heli_destroyed" ) )
		return;
	
	heli 	= self.heli;
	owner 	= heli.owner;
	
	
	self notify( "LISTEN_heli_end" );
	heli notify( "LISTEN_heli_end" );
	
	heli.targeting vehicle_scripts\_apache_player_targeting::_end();
	heli.missileDefense vehicle_scripts\_chopper_player_missile_defense::_destroy();
//	heli.gunCamera vehicle_scripts\_apache_player_guncamera::_destroy();
	heli.pilot vehicle_scripts\_apache_player_pilot::_destroy();
	heli.audio vehicle_scripts\_apache_player_audio::_destroy();
	
	heli.cockpit_tubes Delete();
	
	// Make sure fx are cleaned up when the chopper ends
	self monitorHealth_damageStates_cleanUp();
	
	level.cover_warnings_disabled = heli.cover_warnings_disabled;
	level.treadfx_maxheight		  = heli.treadfx_maxheight;
	
	//owner.gs.playerHealth_RegularRegenDelay 	= heli.regularRegenDelay;
	//owner.gs.longregentime					= heli.longregentime;
	
	if ( IsDefined( heli.g_friendlyNameDist ) )
		SetSavedDvar( "g_friendlyNameDist", heli.g_friendlyNameDist );
	if ( IsDefined( heli.hud_showStance ) )
		SetSavedDvar( "hud_showStance", heli.hud_showStance );
	if ( IsDefined( heli.compass ) )
		SetSavedDvar( "compass", heli.compass );
	
	if ( IsDefined( heli.fov_orig ) )
	{
		owner LerpFOV( heli.fov_orig, 1.05 );
		heli.fov_orig = undefined;
	}
	
	//owner ClearThermalFog();
	owner EnableWeaponSwitch();
	owner AllowCrouch( true );
	owner AllowProne( true );
	owner AllowJump( true );
	//owner PlayerClearStreamOrigin();
	
	self notify( "stop_kicking_up_dust" );
	
					  //   message 							    remove   
	owner ent_flag_clear( "FLAG_apache_player_move_up"		 , true );
	owner ent_flag_clear( "FLAG_apache_player_used_move_up"	 , true );
	owner ent_flag_clear( "FLAG_apache_player_move_down"	 , true );
	owner ent_flag_clear( "FLAG_apache_player_used_move_down", true );
	owner ent_flag_clear( "FLAG_apache_pilot_active"		 , true );
	owner ent_flag_clear( "FLAG_apache_gunCamera_active"	 , true );
	
	owner player_dismount_vehicle();
	level.autosave_check_override = undefined;
	self Delete();
	
}

monitor_pilotAndGunCameraSwitch()
{
	self endon( "LISTEN_heli_end" );
	
	heli 			= self.heli;
	pilot 			= heli.pilot;
	gunCamera 		= heli.gunCamera;
	missileDefense 	= heli.missileDefense;
	owner			= heli.owner;
		
	// XBOX: X
	owner NotifyOnPlayerCommand( "LISTEN_pilotAndGunCameraSwitch", "+usereload" );
	
	heli ent_flag_set( "FLAG_pilot_active" );
	owner ent_flag_set( "FLAG_apache_pilot_active" );
	
	for ( ; ; )
	{
		// Switch to Gun Camera
		
		owner waittill( "LISTEN_pilotAndGunCameraSwitch" );
		
		owner thread play_sound_on_entity( "apache_pilot_guncamera_switch" );
		owner fade_out();
		wait 0.2;
		pilot vehicle_scripts\_apache_player_pilot::_end();
		heli ent_flag_clear( "FLAG_pilot_active" );
		owner ent_flag_clear( "FLAG_apache_pilot_active" );
//		gunCamera vehicle_scripts\_apache_player_gunCamera::_start();
		heli ent_flag_set( "FLAG_gunCamera_active" );
		owner ent_flag_set( "FLAG_apache_gunCamera_active" );
		missileDefense vehicle_scripts\_chopper_player_missile_defense::hud_update();
		owner fade_in();
		
		// Switch to Heli Pilot
		
		owner waittill( "LISTEN_pilotAndGunCameraSwitch" );
		
		owner thread play_sound_on_entity( "apache_pilot_guncamera_switch" );
		owner fade_out();
		wait 0.2;
//		gunCamera vehicle_scripts\_apache_player_gunCamera::_end();
		heli ent_flag_clear( "FLAG_gunCamera_active" );
		owner ent_flag_clear( "FLAG_apache_gunCamera_active" );
		pilot vehicle_scripts\_apache_player_pilot::_start();
		heli ent_flag_set( "FLAG_pilot_active" );
		owner ent_flag_set( "FLAG_apache_pilot_active" );
		missileDefense vehicle_scripts\_chopper_player_missile_defense::hud_update();
		owner fade_in();
	}
}

SPRINT_ACCEL	= 180;
SPRINT_SPEED 	= 160;
SPRINT_DURATION = 4.0;
SPRINT_COOLDOWN = 4.0;

monitorSprint()
{	
	heli	= self.heli;
	owner 	= heli.owner;
	
	self endon( "LISTEN_heli_end" );
	
	owner NotifyOnPlayerCommand( "LISTEN_sprinting_start", "+sprint_zoom" );
	owner NotifyOnPlayerCommand( "LISTEN_sprinting_stop", "-sprint_zoom" );
	owner NotifyOnPlayerCommand( "LISTEN_sprinting_start", "+sprint" );
	owner NotifyOnPlayerCommand( "LISTEN_sprinting_stop", "-sprint" );
	owner NotifyOnPlayerCommand( "LISTEN_sprinting_start", "+breath_sprint" );
	owner NotifyOnPlayerCommand( "LISTEN_sprinting_stop", "-breath_sprint" );
	
	lastSprintTime = GetTime();
	
	for ( ; ; )
	{	
		owner waittill( "LISTEN_sprinting_start" );
			
		heli ent_flag_set( "FLAG_sprinting" );
		
		SetSavedDvar( "vehHelicopterMaxSpeed", SPRINT_SPEED );
		SetSavedDvar( "vehHelicopterMaxAccel", SPRINT_ACCEL );
		
		owner waittill_notify_or_timeout( "LISTEN_sprinting_stop", SPRINT_DURATION );
		
		heli ent_flag_clear( "FLAG_sprinting" );
		
		SetSavedDvar( "vehHelicopterMaxSpeed", DEFAULT_SPEED );
		SetSavedDvar( "vehHelicopterMaxAccel", DEFAULT_ACCEL );
		
		wait SPRINT_COOLDOWN;
	}
}

monitorMachineGun()
{
	heli	= self.heli;
	owner 	= heli.owner;
	
	self endon( "LISTEN_heli_end" );
	
	self thread monitorMachineGun_onStop();
	
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_machinegun_fire", "+attack" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_machinegun_stop", "-attack" );
	
	while ( 1 )
	{
		owner waittill( "LISTEN_apache_player_machinegun_fire" );
		
		owner PlayRumbleLoopOnEntity( "minigun_rumble" );
		owner childthread vehicle_scripts\_apache_player_pilot::player_poll_button_release_and_notify( "attack", "LISTEN_apache_player_machinegun_stop" );
		
		owner waittill( "LISTEN_apache_player_machinegun_stop" );
		
		owner StopRumble( "minigun_rumble" );
	}
}

monitorMachineGun_onStop()
{
	heli	= self.heli;
	owner 	= heli.owner;
	
	self waittill( "LISTEN_heli_end" );
	
	owner StopRumble( "minigun_rumble" );
}

// JC-ToDo: Not sure if any of this is needed now that move up and down are removed
monitorMoveUp()
{
	heli	= self.heli;
	owner 	= heli.owner;
	
	self endon( "LISTEN_heli_end" );
	
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_move_up", "+smoke" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_move_up", "-smoke" );
	
	for ( ; ; )
	{
		owner waittill( "LISTEN_apache_player_start_move_up" );
		
		owner ent_flag_set( "FLAG_apache_player_move_up" );
		owner ent_flag_set( "FLAG_apache_player_used_move_up" );
		
		owner waittill( "LISTEN_apache_player_stop_move_up" );
		
		owner ent_flag_clear( "FLAG_apache_player_move_up" );
	}
}

monitorMoveDown()
{
	heli	= self.heli;
	owner 	= heli.owner;
	
	self endon( "LISTEN_heli_end" );
	
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_move_down", "+toggleads_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_move_down", "+speed_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_move_down", "+speed" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_start_move_down", "+ads_akimbo_accessible" );
	
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_move_down", "-toggleads_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_move_down", "-speed_throw" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_move_down", "-speed" );
	owner NotifyOnPlayerCommand( "LISTEN_apache_player_stop_move_down", "-ads_akimbo_accessible" );
	
	for ( ; ; )
	{
		owner waittill( "LISTEN_apache_player_start_move_down" );
		
		owner ent_flag_set( "FLAG_apache_player_move_down" );
		owner ent_flag_set( "FLAG_apache_player_used_move_down" );
		
		owner waittill( "LISTEN_apache_player_stop_move_down" );
		
		owner ent_flag_clear( "FLAG_apache_player_move_down" );
	}
}

removeAltituedMesh()
{
	// If there is no altitude control make sure to delete any placed altitude mesh
	altitude_mesh_ents = GetEntArray( "apache_player_mesh", "targetname" );
	array_call( altitude_mesh_ents, ::Delete );
}

monitorAltitude()
{	
	// The following diagram lays out how the structs should be placed in the level to define the
	// z bounds of the chopper altitude monitoring. The trace end struct is included to allow
	// the chopper to go below the default altitude if the level designer wants it to.
	//		- If the trace ever reaches the trace end altitude the chopper will be set tot the default
	//		altitude.
	//		- In the below example the collision in the sky allows the chopper to flow lower on the
	//		right side of the building than on the left.
	//
	//  <- struct_altitude_trace_start
	//
	//                                           
	//                                           
	//                                           
	//  <- struct_altitude_offset                
	//                                           
	//                                           
	//                                                 ________  
	//  <- struct_altitude_trace_end                  /        \
	//                                               /  ______  \
	//  <- struct_altitude_default               ___/   |     |  \           ___
	//                                                  |     |   \         /
	//                                                             \_______/
	self disable_altitude_control();
	self endon( "monitor_altitude_disable" );
	
	self endon( "LISTEN_heli_end" );
	
	
	alt_trace_start = getstruct( "struct_altitude_trace_start", "targetname" );
	alt_offset		= getstruct( "struct_altitude_offset", "targetname" );
	alt_trace_end	= getstruct( "struct_altitude_trace_end", "targetname" );
	alt_default		= getstruct( "struct_altitude_default", "targetname" );
	
	AssertEx( IsDefined( alt_default )	  , "No default chopper altitude struct defined for level." );
	AssertEx( IsDefined( alt_offset )	  , "No chopper collision altitude offset struct defined for level." );
	AssertEx( IsDefined( alt_trace_start ), "No chopper trace start altitude struct defined for level." );
	AssertEx( IsDefined( alt_trace_end )  , "No chopper trace end altitude struct defined for level." );
	
	if ( !IsDefined( alt_default ) || !IsDefined( alt_offset ) || !IsDefined( alt_trace_start ) || !IsDefined( alt_trace_end ) )
		return;
	
	offset_z_delta = alt_offset.origin[ 2 ] - alt_default.origin[ 2 ];
	offset_z	   = alt_offset.origin[ 2 ];
	trace_z_start  = alt_trace_start.origin[ 2 ];
	trace_z_end	   = alt_trace_end.origin[ 2 ];
	
	// Adjust mesh to line up with the struct altitude offset z
	altitude_mesh_ents = GetEntArray( "apache_player_mesh", "targetname" );
	offset_v = ( 0, 0, offset_z_delta );
	foreach ( mesh in altitude_mesh_ents )
	{
		if ( !IsDefined( mesh.altitude_adjusted ) )
		{
			mesh.origin += offset_v;
			mesh.altitude_adjusted = true;
		}
	}
	
	update_delay = 0.05;
	while ( 1 )
	{
		trace_start = ( self.origin[ 0 ], self.origin[ 1 ], trace_z_start );
		trace_end	= ( self.origin[ 0 ], self.origin[ 1 ], trace_z_end );
		trace		= BulletTrace( trace_start, trace_end, false );
		
		trace_z		= trace[ "position" ][ 2 ];
		
		// If the trace made it to the end there was no collision so use the default chopper altitude
		if ( abs( trace_z - trace_end[ 2 ] ) <= 0.2 )
			trace_z = offset_z;
		
		alt_goal = trace_z - offset_z_delta;
		
		// Adjust the altitude goal by the current min altitude override
		if ( IsDefined( self.alt_override ) )
		{
			alt_goal = max( alt_goal, self.alt_override );
		}
		
		
		if ( GetDvarFloat( "vehHelicopterMinAltitude" ) != alt_goal )
			SetSavedDvar( "vehHelicopterMinAltitude", alt_goal );
		
		if ( GetDvarFloat( "vehHelicopterMaxAltitude" ) != alt_goal )
			SetSavedDvar( "vehHelicopterMaxAltitude", alt_goal );
		
		wait update_delay;
	}
}

// The lowest the apache could fly before the trace fails
// and the apache is set to the default height
get_altitude_min()
{
	alt_offset		= getstruct( "struct_altitude_offset", "targetname" );
	alt_trace_end	= getstruct( "struct_altitude_trace_end", "targetname" );
	alt_default		= getstruct( "struct_altitude_default", "targetname" );
	
	return alt_default.origin[ 2 ] - ( alt_offset.origin[ 2 ] - alt_trace_end.origin[ 2 ] );
}

disable_altitude_control()
{
	self notify( "monitor_altitude_disable" );
}

enable_altitude_control()
{
	self thread monitorAltitude();
}

altitude_override_over_time( z_height, time_sec )
{
	self notify( "altitude_min_override" );
	self endon( "altitude_min_override" );
	
	self endon( "LISTEN_heli_end" );
	
	if ( IsDefined( time_sec ) && time_sec > 0 )
	{
		// If there currently is not an override start from the lowest
		// possible helicopter height and move up from there.
		if ( !IsDefined( self.alt_override ) )
		{
			self.alt_override = get_altitude_min();
		}
		
		time_sec  = max( time_sec, 0.05 );
		alt_start = self.alt_override;
		
		for ( elapsed = 0; elapsed <= time_sec; elapsed += 0.05 )
		{
			self.alt_override = alt_start + ( elapsed / time_sec ) * ( z_height - alt_start );
			wait 0.05;
		}
	}
	
	self.alt_override = z_height;
	
	return true;
}

altitude_min_override( z_height, time_sec )
{
	self altitude_override_over_time( z_height, time_sec );
}

altitude_min_override_remove( time_sec )
{
	AssertEx( IsDefined( self.alt_override ), "altitude_min_override_remove() called on apache_player with no altitude minimum override in place." );
	
	if ( IsDefined( time_sec ) && time_sec > 0 )
	{
		z_height = get_altitude_min();
		
		result = self altitude_override_over_time( z_height, time_sec );
		
		// Clear the alt override if it was successfully set to default
		if ( IsDefined( result ) && result )
			self.alt_override = undefined;
	}
	else
	{
		self.alt_override = undefined;
	}
}

#using_animtree( "script_model" );
monitorCockpitAnims()
{
	heli	= self.heli;
	owner 	= heli.owner;
	
	self endon( "LISTEN_heli_end" );
	self endon( "ENT_FLAG_heli_destroyed" );
	
	// Parts of the tube rig change from jiggle to damage
	// states. When this happens their jiggle is disabled
	// in monitorCockpitAnims_onDamage();
	heli.cockpit_tubes.jiggle_disabled			  = [];
	heli.cockpit_tubes.jiggle_disabled[ "ALL" ]   = false;
	heli.cockpit_tubes.jiggle_disabled[ "RIGHT" ] = false;
	heli.cockpit_tubes.jiggle_disabled[ "LEFT"	] = false;
	
	self childthread monitorCockpitAnims_onDamage();
	
	heli.cockpit_tubes.anims_curr = [];
	heli.cockpit_tubes.anims_curr[ "ALL"   ] = undefined;
	heli.cockpit_tubes.anims_curr[ "RIGHT" ] = undefined;
	heli.cockpit_tubes.anims_curr[ "LEFT"  ] = undefined;
	
	speed_idle = 0.25 * GetDvarFloat( "vehHelicopterMaxSpeed" );
	speed_slow = 0.50 * GetDvarFloat( "vehHelicopterMaxSpeed" );
	speed_fast = 1.0 * GetDvarFloat( "vehHelicopterMaxSpeed" );
	
	anim_keys = [ "ALL", "RIGHT", "LEFT" ];
	
	while ( 1 )
	{
		// clear the new anims each time
		anims_new = [];
		
		speed_curr = heli.vehicle Vehicle_GetSpeed();
		if ( speed_curr <= speed_idle )
		{
			anims_new[ "ALL"   ] = %apache_cockpit_idle_at_rest;
			anims_new[ "RIGHT" ] = %apache_cockpit_tube_right_at_rest;
			anims_new[ "LEFT"  ] = %apache_cockpit_tube_left_at_rest;
		}
		else if ( speed_curr <= speed_slow )
		{
			anims_new[ "ALL"   ] = %apache_cockpit_idle_moving_slow;
			anims_new[ "RIGHT" ] = %apache_cockpit_tube_right_moving_slow;
			anims_new[ "LEFT"  ] = %apache_cockpit_tube_left_moving_slow;
		}
		else if ( speed_curr <= speed_fast )
		{
			anims_new[ "ALL"   ] = %apache_cockpit_idle_moving_fast;
			anims_new[ "RIGHT" ] = %apache_cockpit_tube_right_moving_fast;
			anims_new[ "LEFT"  ] = %apache_cockpit_tube_left_moving_fast;
		}
		else
		{
			anims_new[ "ALL"   ] = undefined;
			anims_new[ "RIGHT" ] = undefined;
			anims_new[ "LEFT"  ] = undefined;
		}
		
		// Don't apply the same animations again
		if ( IsDefined( anims_new[ "ALL" ] ) && ( !IsDefined( heli.cockpit_tubes.anims_curr[ "ALL" ] ) || heli.cockpit_tubes.anims_curr[ "ALL" ] != anims_new[ "ALL" ] ) )
		{
			// Apply shake tube parts that aren't disabled
			heli.cockpit_tubes UseAnimTree( #animtree );
			
			foreach ( key in anim_keys )
			{
				if ( !heli.cockpit_tubes.jiggle_disabled[ key ] )
				{
					if ( IsDefined( heli.cockpit_tubes.anims_curr[ key ] ) )
					{
						heli.cockpit_tubes ClearAnim( heli.cockpit_tubes.anims_curr[ key ], 0.2 );
					}
					
					if ( IsDefined( anims_new[ key ] ) )
					{
						heli.cockpit_tubes SetAnim( anims_new[ key ], 1, 0.2, 1.0 );
					}
				}
			}
			
			heli.cockpit_tubes.anims_curr[ "ALL"   ] = anims_new[ "ALL" ];
			heli.cockpit_tubes.anims_curr[ "RIGHT" ] = anims_new[ "RIGHT" ];
			heli.cockpit_tubes.anims_curr[ "LEFT"  ] = anims_new[ "LEFT" ];
		}
		
		wait 0.25;
	}
}

CONST_COCKPIT_TUBE_ANIM_BLEND_TIME	= 0.5;
monitorCockpitAnims_onDamage()
{
	heli	= self.heli;
	owner 	= heli.owner;
	
	anim_break	= undefined;
	anim_whip	= undefined;
	anim_settle = undefined;
	anim_idle	= undefined;
	tag_fx		= undefined;
	
	tube_break_keys = [ "RIGHT", "LEFT" ];
	
	while ( tube_break_keys.size > 0 )
	{
		// On zero health clear the previous anims (jiggle or at rest) and 
		// apply the spray anims for a random tube
		msg = undefined;
		while ( 1 )
		{
			self waittill( "LISTEN_apache_damage_state_enter", msg );
			
			if ( msg == "health_none" )
				break;
		}
		
		// Choose a tube that hasn't been broken yet
		tube_key		= tube_break_keys[ RandomInt( tube_break_keys.size ) ];
		tube_break_keys = array_remove( tube_break_keys, tube_key );
		
		// Clear the previous speed relative jiggle anim and record
		// this tube disabled
		if ( !heli.cockpit_tubes.jiggle_disabled[ tube_key ] )
		{
			heli.cockpit_tubes ClearAnim( heli.cockpit_tubes.anims_curr[ tube_key ], CONST_COCKPIT_TUBE_ANIM_BLEND_TIME );
			heli.cockpit_tubes.jiggle_disabled[ tube_key ] = true;
		}
		
		if ( tube_key == "RIGHT" )
		{
			anim_break	= %apache_cockpit_tube_right_whip_in;
			anim_whip	= %apache_cockpit_tube_right_whip;
			anim_settle = %apache_cockpit_tube_right_whip_out;
			anim_idle	= %apache_cockpit_tube_right_idle;
			tag_fx		= "r_innertubeend_jnt";
		}
		else if ( tube_key == "LEFT" )
		{
			anim_break	= %apache_cockpit_tube_left_whip_in;
			anim_whip	= %apache_cockpit_tube_left_whip;
			anim_settle = %apache_cockpit_tube_left_whip_out;
			anim_idle	= %apache_cockpit_tube_left_idle;
			tag_fx		= "l_innertubeend_jnt";
		}
		
		childthread monitorCockpitAnims_tube_whip( anim_break, anim_whip, anim_settle, anim_idle, tag_fx );
	}
}

CONST_COCKPIT_ANIM_TUBE_WHIP_TIME		= 1.0;

monitorCockpitAnims_tube_whip( anim_break, anim_whip, anim_settle, anim_idle, tag_fx )
{
	heli	= self.heli;
	owner 	= heli.owner;

	// Play Fx
	PlayFXOnTag( getfx( "apache_player_cockpit_pipe_hiss" ), heli.cockpit_tubes, tag_fx );
	heli.cockpit_tubes thread play_loop_sound_on_tag( "apache_player_tube_hiss", tag_fx, true );
	
	// Play Break Anim
	heli.cockpit_tubes SetAnim( anim_break, 1, CONST_COCKPIT_TUBE_ANIM_BLEND_TIME, 1.0 );
	anim_len = GetAnimLength( anim_break );
	
	wait anim_len - Min( CONST_COCKPIT_TUBE_ANIM_BLEND_TIME, anim_len * 0.1 );
	
	heli.cockpit_tubes ClearAnim( anim_break, CONST_COCKPIT_TUBE_ANIM_BLEND_TIME );
	
	// Play Whip Loop
	heli.cockpit_tubes SetAnim( anim_whip, 1, CONST_COCKPIT_TUBE_ANIM_BLEND_TIME, 1.0 );
	anim_len = GetAnimLength( anim_whip );
	
	wait CONST_COCKPIT_ANIM_TUBE_WHIP_TIME;
	
	heli.cockpit_tubes ClearAnim( anim_whip, CONST_COCKPIT_TUBE_ANIM_BLEND_TIME );
	
	// Play Whip Settle
	heli.cockpit_tubes SetAnim( anim_settle, 1, CONST_COCKPIT_TUBE_ANIM_BLEND_TIME, 1.0 );
	anim_len = GetAnimLength( anim_settle );
	
	wait anim_len - Min( CONST_COCKPIT_TUBE_ANIM_BLEND_TIME, anim_len * 0.1 );
	
	heli.cockpit_tubes ClearAnim( anim_settle, CONST_COCKPIT_TUBE_ANIM_BLEND_TIME );
	
	// Stop Fx
	StopFXOnTag( getfx( "apache_player_cockpit_pipe_hiss" ), heli.cockpit_tubes, tag_fx );
	heli.cockpit_tubes notify( "stop sound" + "apache_player_tube_hiss" );
	
	// Play Idle
	heli.cockpit_tubes SetAnim( anim_idle, 1, CONST_COCKPIT_TUBE_ANIM_BLEND_TIME, 1.0 );
}

// JC-ToDo: Make these variables relative to difficulty
CONST_APACHE_HEALTH_MAX						= 100000;
CONST_APACHE_INVULNERABLE_TIME				= 1.0;
CONST_APACHE_VULNERABLE_TIME				= 4.0;
CONST_APACHE_VULNERABLE_PCT					= 0.15;		// Percent of damage that can be taken during vulnerable state before dying
CONST_APACHE_REGEN_DELAY_BETWEEN			= 0.05;
CONST_APACHE_REGEN_DELAY_BEFORE				= 3.0;
CONST_APACHE_REGEN_START_PCT				= 0.4;
CONST_APACHE_REGEN_TIME						= 10;

monitorHealth()
{
	heli	= self.heli;
	owner 	= heli.owner;
	
	self endon( "LISTEN_heli_end" );
	self endon( "ENT_FLAG_heli_destroyed" );
	
	self apache_health_init( CONST_APACHE_HEALTH_MAX );
	
	self godon();
	self ent_flag_init( "ENT_FLAG_heli_damaged" );
	self ent_flag_init( "ENT_FLAG_heli_health_state_finished" );
	self ent_flag_init( "ENT_FLAG_heli_destroyed" );
	
	self thread monitorHealth_onDamage();
	self thread monitorHealth_onDeath();
	self thread monitorHealth_damageStates();
	
	/#
	//self thread monitorHealth_onDamage_DEBUG();
	#/
	
	// Amount of damage taken while in current state
	state_curr_dmg = 0;
	state_curr = "STATE_FULL";
	
	while ( 1 )
	{
		self waittill_any( "ENT_FLAG_heli_damaged", "ENT_FLAG_heli_health_state_finished" );
		
		// In case multiple notifications happen on the same frame
		waittillframeend;
		
		if ( self ent_flag( "ENT_FLAG_heli_health_state_finished" ) )
		{
			state_curr = apache_health_state_next( state_curr );
			self childthread apache_health_state_think( state_curr );
			
			state_curr_dmg = 0;
			
			self ent_flag_clear( "ENT_FLAG_heli_health_state_finished" );
		}
		
		// Global state logic for damage handling
		
		if ( self ent_flag( "ENT_FLAG_heli_damaged" ) )
		{
			AssertEx( IsDefined( self.apache_dmg_recent ) && self.apache_dmg_recent > 0, 
					 "apache player damage flag set without a recent damage value greather than 0." );
			
			self apache_health_adjust( -1 * self.apache_dmg_recent );
			state_curr_dmg += self.apache_dmg_recent;
			
			// Evaluate a state transition from damage
			state_new = undefined;
			switch ( state_curr )
			{
				case "STATE_FULL":
				case "STATE_PAIN":
				case "STATE_REGEN":
					if ( self apache_health_get() == 0 )
					{
						state_new = "STATE_INVULN";
					}
					else
					{
						state_new = "STATE_PAIN";
					}
					break;
				
				case "STATE_INVULN":
					break;
				
				case "STATE_VULN":
					// If enough damage was taken in the vulnerable state destroy the chopper
					if ( state_curr_dmg / self apache_health_max_get() >= CONST_APACHE_VULNERABLE_PCT )
					{
						/#
						if ( IsGodMode( owner ) )
							break;
						#/
						// Ends all health related threads and triggers monitorHealth_onDeath();
						self ent_flag_set( "ENT_FLAG_heli_destroyed" );
						flag_set( "FLAG_apache_crashing" );
					}
					break;
			}
			
			// If a new state was desired after damage checking, apply it
			if ( IsDefined( state_new ) )
			{
				state_curr = state_new;
				self childthread apache_health_state_think( state_curr );
				
				state_curr_dmg = 0;
			}
			
			// Damage flag and data
			self.apache_dmg_recent = 0;
			self ent_flag_clear( "ENT_FLAG_heli_damaged" );
		}
	}
}

apache_health_state_think( state )
{
	self notify( "apache_health_state_think_new" );
	
	self endon( "apache_health_state_think_new" );
	self endon( "LISTEN_heli_end" );
	
	switch ( state )
	{
		case "STATE_FULL":
			level waittill( "forever" );
			break;
		
		case "STATE_PAIN":
			wait CONST_APACHE_REGEN_DELAY_BEFORE;
			break;
		
		case "STATE_INVULN":
			wait CONST_APACHE_INVULNERABLE_TIME;
			break;
		
		case "STATE_VULN":
			wait CONST_APACHE_VULNERABLE_TIME;
			break;
		
		case "STATE_REGEN":
			
			// Bump the health to an initial percent
			if ( self apache_health_pct_get() < CONST_APACHE_REGEN_START_PCT )
			{
				self apache_health_pct_set( CONST_APACHE_REGEN_START_PCT );
			}
			
			regen_inc = Int( max( ( self apache_health_max_get() - self apache_health_get() )
								 / ( CONST_APACHE_REGEN_TIME / CONST_APACHE_REGEN_DELAY_BETWEEN ), 1 ) );
			
			while ( !self apache_health_at_max() )
			{
				wait CONST_APACHE_REGEN_DELAY_BETWEEN;
				self apache_health_adjust( regen_inc );
			}
			break;
		
		default:
			AssertMsg( "apache_health_state_think() did not handle state: " + state );
			break;
	}
	
	self ent_flag_set( "ENT_FLAG_heli_health_state_finished" );
}

apache_health_state_next( state )
{
	state_next = "";
	
	switch ( state )
	{
		case "STATE_FULL":
			AssertMsg( "apache player health STATE_FULL should never finish" );
			break;
		
		case "STATE_PAIN":
		case "STATE_VULN":
			state_next = "STATE_REGEN";
			break;
		
		case "STATE_INVULN":
			state_next = "STATE_VULN";
			break;
		
		case "STATE_REGEN":
			state_next = "STATE_FULL";
			break;
		
		default:
			AssertMsg( "apache_health_state_next() did not handle state: " + state );
			break;
	}
	
	return state_next;
}




monitorHealth_onDamage()
{
	self endon( "LISTEN_heli_end" );

	heli  = self.heli;
	owner = heli.owner;
	
	self.apache_dmg_recent = 0;
	self.apache_dmg_time   = GetTime();
	
	dmg_bullet	= Int( max( level.apache_player_difficulty.dmg_bullet_pct * self apache_health_max_get(), 1 ) );
	dmg_missile = Int( max( level.apache_player_difficulty.dmg_projectile_pct * self apache_health_max_get(), 1 ) );
	
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, direction, point, damage_type, model, tag, part, dflags, weapon );
		
		/#
		if ( IsGodMode( owner ) )
			continue;
		#/
		
		if ( !IsDefined( attacker ) )
			continue;
		
		if ( self getTeam() == attacker getTeam() )
			continue;
		
		if ( !IsDefined( damage_type ) )
			continue;
		
		time = GetTime();
		
		// If bullet damage check to see if bullet damage is happening too often
		// and if the damage chance needs to be scaled relative to player speed
		if ( damage_type == "MOD_RIFLE_BULLET" || damage_type == "MOD_PISTOL_BULLET" )
		{
			// we don't want ground ai to be as effective shooting hand-weapons.
			ai_attackerTimeOffset = ter_op( IsAI( attacker ), 15, 1);

			// only take bullet damage every so often
			if ( time - self.apache_dmg_time <= level.apache_player_difficulty.dmg_bullet_delay_between_msec * ai_attackerTimeOffset )
				continue;
			
			// If the player apache health is below the specified threshold scale
			// the chance that a bullet will hit relative to the player's speed
			if ( self apache_health_pct_get() <= level.apache_player_difficulty.dmg_player_health_adjust_chance )
			{
				speed_evade_max = level.apache_player_difficulty.dmg_player_speed_evade_min_pct * GetDvarFloat( "vehHelicopterMaxSpeed" );
				speed_evade_min = level.apache_player_difficulty.dmg_player_speed_evade_max_pct * GetDvarFloat( "vehHelicopterMaxSpeed" );
				speed_curr		= clamp( self Vehicle_GetSpeed(), speed_evade_min, speed_evade_max );
				
				// The slower the current speed the higher chance of hitting
				ratio  = 1 - ( ( speed_curr - speed_evade_min ) / ( speed_evade_max - speed_evade_min ) );
				chance = level.apache_player_difficulty.dmg_bullet_chance_player_evade +
					( level.apache_player_difficulty.dmg_bullet_chance_player_static - level.apache_player_difficulty.dmg_bullet_chance_player_static ) * ratio;
				
				if ( RandomFloat( 1.0 ) >= chance )
					continue;
			}
		}

		if ( cointoss() )
			self PlaySound( "apache_impact" );
		
		// adjusted health according to damage type
		dmg_filtered = undefined;
		
		switch ( damage_type )
		{
			case "MOD_RIFLE_BULLET":
			case "MOD_PISTOL_BULLET":
				dmg_filtered = dmg_bullet;
				break;
			case "MOD_PROJECTILE":
			case "MOD_PROJECTILE_SPLASH":
				dmg_filtered = dmg_missile;
				break;
			default:
				IPrintLnBold( "The following damage type not handled by apache: " + damage_type + ". Please bug." );
				dmg_filtered = dmg_bullet;
				break;
		}
		
		// Hack around the enemy hind turret having projectile damage
		// instead of bullet damage. The default turret is set up
		// incorrectly but this vehicle is going to get replaced.
		if ( IsDefined( weapon ) && weapon == "hind_turret" )
			dmg_filtered = dmg_bullet;
		
		// record damage amount and damage time
		self.apache_dmg_time   = time;
		self.apache_dmg_recent = dmg_filtered;
		
	// Notify health system of damage
		self ent_flag_set( "ENT_FLAG_heli_damaged" );
	}
}

/#
monitorHealth_onDamage_DEBUG()
{
	self endon( "LISTEN_heli_end" );
	
	heli  = self.heli;
	owner = heli.owner;
	
	owner NotifyOnPlayerCommand( "LISTEN_DEBUG_DAMAGE_APACHE", "+actionslot 1" );
	
	while ( 1 )
	{
		owner waittill( "LISTEN_DEBUG_DAMAGE_APACHE" );
		
		// record damage amount and damage time
		self.apache_dmg_time   = GetTime();
		self.apache_dmg_recent = max( self apache_health_max_get() * 0.05, 1 );
		
		// Notify health system of damage
		self ent_flag_set( "ENT_FLAG_heli_damaged" );
	}
}
#/

monitorHealth_onDeath_fx()
{
	self endon( "LISTEN_heli_end" );
	
	heli  = self.heli;
	owner = heli.owner;
	
	apache = self;
	
	PlayFXOnTag( getfx( "apache_player_dlight_red_flicker" ), apache, "tag_dial3" );
	
	// Make sure the glass is in its final damage state
	apache HidePart( "tag_glass_damage" );
	apache HidePart( "tag_glass_damage1" );
	apache ShowPart( "tag_glass_damage2" );
	
	apache thread play_sound_on_tag( "apache_player_glass_crack_lrg", "tag_glass_damage1" );
	
	owner DigitalDistortSetParams( 0.4, 1.0 );
}


monitorHealth_onDeath()
{
	self endon( "LISTEN_heli_end" );
	
	msg = self waittill_any_return( "death", "ENT_FLAG_heli_destroyed" );
	
	AssertEx( IsDefined( msg ) && msg != "death", "The apache player should never get the \"death\" notification." );
	
	if ( msg == "ENT_FLAG_heli_destroyed" )
	{
		self monitorHealth_damageStates_cleanUp();
		self monitorHealth_onDeath_fx();
		
		self thread maps\_vehicle_code::death_firesound( "apache_player_dying_alarm" );
		
		// JC-ToDo: The pilot shouldn't get shot and die on every death.
		// Tell the pilot to die
		self notify ( "LISTEN_pilot_death" );
		wait 0.5;
		
		time_before_fail = 2.0;
		self thread monitorHealth_onDeath_apache_crash();
		self thread monitorHealth_onDeath_player_feedback( time_before_fail );
		
		self thread maps\_vehicle_code::death_firesound( "apache_player_dying_loop" );
		
		self waittill_any_timeout_no_endon_death( time_before_fail, "crash_done" );
	}
	
	SetDvar( "ui_deadquote", "" );
	missionFailedWrapper();
}

monitorHealth_onDeath_apache_crash()
{
	heli  = self.heli;
	owner = heli.owner;
	
	// Spawn crash location and make sure the chopper flies to it
	self.perferred_crash_location = SpawnStruct();
	self.perferred_crash_location.script_parameters = "direct";
	self.perferred_crash_location.radius = 60;
	
	// The player chopper moves fast. The vehicle code to move
	// a chopper to a crash location is not customizable so make
	// sure the player chopper isn't going too fast for its
	// speed to be adjusted when crashing
	if ( self Vehicle_GetSpeed() > 40 )
	{
		self Vehicle_SetSpeedImmediate( 40 );
	}
	
	// Check to see if the chopper has room to drop, otherwise go up
	trace_down = 600;
	trace = BulletTrace( self.origin - 160, self.origin - (0,0,trace_down), false, self );
	if ( trace[ "fraction" ] > 0.98 )
	{
		self.perferred_crash_location.origin = self.origin - (0,0,trace_down);
	}
	else
	{
		self.perferred_crash_location.origin = self.origin + (0,0,trace_down);
	}
	
	self maps\_vehicle_code::helicopter_crash_move();
}

monitorHealth_onDeath_player_feedback( time_before_fail )
{
	heli  = self.heli;
	owner = heli.owner;
	
	owner EnableDeathShield( true );
	owner PlayRumbleLoopOnEntity( "damage_heavy" );
	
	while ( 1 )
	{
		owner DoDamage( 40, owner.origin );
		
		Earthquake( 0.3, 1.0, owner.origin, 512 );
		
		delay = max ( min( time_before_fail * 0.5, 1.0 ), 0.25 );
		
		time_before_fail -= delay;
		
		wait delay;
	}
}

monitorHealth_damageStates_cleanUp()
{
	apache = self;
	heli   = self.heli;
	
	foreach ( state in heli.damage_states )
	{
		state damage_state_clear( false );
	}
	
	apache damage_state_tag_ent_clear_all();
}

monitorHealth_damageStates()
{
	self endon( "LISTEN_heli_end" );
	
	heli  = self.heli;
	owner = heli.owner;
	
	// Pre Damage State prep for Cockpit
	self HidePart( "tag_glass_damage1" );
	self HidePart( "tag_glass_damage2" );
	self HidePart( "tag_dial1" );
	
	// Damage States
		// permanent portion on
		// health pct max
		// Array of temporary FX
		// Array of permanent FX
			// fx
			// tag
			// sound
			// loop
		// Visual Distortion
	
	heli.damage_states = [];

	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	// Player at or below 0% health
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	
	state = damage_state_build( 0.01, self, 0.2, 1.0, 0.275, 1.0, 750 );
	state damage_state_notify_add( "health_none" );
	state damage_state_fx_add( "apache_player_cockpit_smoke", "tag_front", false );
	state damage_state_fx_add( "apache_player_dlight_red_flicker", "tag_dial4", false );
	state damage_state_fx_add( "apache_player_cockpit_sparks_v2", "tag_cable_up_front_left", false );
	state damage_state_fx_add( "apache_player_cockpit_sparks_v2", "tag_cable_up_right", false );
	
	state damage_state_prt_add( "tag_glass_damage1", true, "tag_glass_damage", 2, "apache_player_glass_crack_sml" );
	state damage_state_prt_add( "tag_glass_damage2", true, "tag_glass_damage1", 3, "apache_player_glass_crack_lrg" );
	state damage_state_prt_add( "tag_dial1", false, "tag_dial_on", 1 ); // Hide the good screens and show the damaged versions
	
	
	state damage_state_snd_add( "apache_player_damaged_alarm", "tag_player", false, true );
	
	heli.damage_states[ heli.damage_states.size ] = state;
	
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	// Player at or below 25% health
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	
	state = damage_state_build( 0.25, self, 0.1, 1.0, 0.2, 1.0, 1000 );
	state damage_state_fx_add( "apache_player_cockpit_smoke", "tag_front", false );
	state damage_state_fx_add( "apache_player_cockpit_sparks_v1", "tag_cable_up_front_left", false );
	state damage_state_fx_add( "apache_player_cockpit_sparks_v1", "tag_cable_up_right", false );
	
	state damage_state_prt_add( "tag_dial1", false, "tag_dial_on", 1 ); // Hide the good screens and show the damaged versions
	
	heli.damage_states[ heli.damage_states.size ] = state;

	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	// Player at or below 55% health
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	
	state = damage_state_build( 0.55, self, 0.05, 1.0, 0.15, 1.0, 1300 );
	state damage_state_fx_add( "apache_player_cockpit_smoke", "tag_front", false );
	state damage_state_fx_add( "apache_player_cockpit_sparks_v1", "tag_cable_up_front_left", false );
	heli.damage_states[ heli.damage_states.size ] = state;
	
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	// Player at or below 85% health
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	state = damage_state_build( 0.85, self, 0.025, 1.0, 0.1, 1.0, 1500 );
	heli.damage_states[ heli.damage_states.size ] = state;
	
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	// Player at or below 100% health
	// -.-.-.-.-.-.-.-.-.-.-.-.-.-. //
	state = damage_state_build( 1.0, self, 0.0, 1.0, 0.0, 0.0, 0.0 );
	heli.damage_states[ heli.damage_states.size ] = state;
	
	// Make sure states are in order of health pct.
	heli.damage_states = array_sort_by_handler( heli.damage_states, ::damage_state_health_pct_get );
	
	// Make sure no damage states have the same health pct and 
	// the array is sorted from least to greatest health pct
	/#
	foreach ( idx, state in heli.damage_states )
		if ( idx > 0 )
			AssertEx( heli.damage_states[ idx - 1 ].health_pct < state.health_pct, "Damage states either out of order according to health percent or a duplicate health percent was found." );
	#/
		
	// Apply the first state according to the apache's current health
	state_curr = damage_state_choose( heli.damage_states, self apache_health_pct_get() );
	state_curr damage_state_apply( false, true );
	
	health_pct_prev = self apache_health_pct_get();
	quake_time_prev	= GetTime();
	
	// Manage Damage State Changes
	while ( 1 )
	{	
		self waittill( "apache_player_health_updated" );
		
		// Handle health being updated multiple times in one frame
		waittillframeend;
		
		health_pct = self apache_health_pct_get();
		
		state_new = damage_state_choose( heli.damage_states, health_pct );
		
		// Whenever damage occurs try to quake and vibrate. If successful
		// record the time. Each state defines how often dmg shake / vibrate 
		// can occur and how much damage shake / vibrate to do
		if ( health_pct < health_pct_prev || health_pct <= 0 )
		{
			success = state_new damage_state_quake( quake_time_prev );
			if ( success )
			{
				quake_time_prev = GetTime();
			}
		}
		
		health_pct_prev = health_pct;
		
		if ( state_new == state_curr )
		{
			continue;
		}
		
		//IPrintLn( "DAMAGE STATE: " + ( state_new.health_pct * 100.0 ) + "\%" );
		
		// Make sure any skipped states have their permanent settings on
		if ( state_new.health_pct < state_curr.health_pct )
		{
			for ( i = heli.damage_states.size - 1; i >= 0; i-- )
			{
				state = heli.damage_states[ i ];
				if ( state == state_new )
					break;
				
				AssertEx( state.health_pct > state_new.health_pct, "Stepping backwards through the state list a later state was found with more or equal the health pct of the new state. This shouldn't happen." );
				
				state damage_state_apply( true );
			}
		}
		
		state_curr damage_state_clear( true );
		state_curr damage_state_notify_send_exit();
		state_new damage_state_apply( false );
		state_new damage_state_notify_send_enter();
		
		// Record the new state
		state_curr = state_new;
	}
}

damage_state_choose( damage_states, health_pct )
{
	AssertEx( IsDefined( damage_states ) && IsArray( damage_states ) && damage_states.size, "Invalid damage_states array passed to damage_state_choose()" );
	
	state_next = undefined;
	
	foreach ( state in damage_states )
	{
		if ( health_pct <= state.health_pct )
		{
			state_next = state;
			break;
		}
	}
	
	AssertEx( IsDefined( state_next ), "damage_state_choose() could not find a valid damage state from the health percent: " + health_pct );
	
	return state_next;
}

damage_state_build( health_pct, vehicle, distort_pct, distort_time, quake_scale, quake_time, quake_interval_msec )
{
	struct					   = SpawnStruct();
	struct.health_pct		   = health_pct;
	struct.perm_on			   = false;
	struct.temp_on			   = false;
	struct.distort_pct		   = distort_pct;
	struct.distort_time		   = distort_time;
	struct.quake_scale		   = quake_scale;
	struct.quake_time		   = quake_time;
	struct.quake_interval_msec = quake_interval_msec;
	struct.vehicle			   = vehicle;
	struct.notify_msg		   = undefined;
	struct.fx_array			   = [];
	struct.prt_array		   = [];
	struct.snd_array		   = [];
	
	return struct;
}

damage_state_apply( permanent_only, skip_distortion )
{
	if ( !IsDefined( skip_distortion ) )
		skip_distortion = false;
	AssertEx( IsDefined( permanent_only ), "damage_state_apply() called without required parameter: permanent_only" );
	
	// Apply FX
	foreach ( fx_info in self.fx_array )
	{
		// Skip permanent fx application if already on
		if ( fx_info[ "perm" ] && self.perm_on )
				continue;
		
		// Skip temporary fx application if permanent only or already on
		if ( !fx_info[ "perm" ] && ( permanent_only || self.temp_on ) )
				continue;
		
		// Apply the fx
		self damage_state_play_fx_on_tag( fx_info );
	}
	
	// Apply Part Swaps
	foreach ( idx, prt_info in self.prt_array )
	{
		// Skip permanent part swap if already applied
			// Part swap infos store if they've been applied
			// on top of the state storing this info. This is
			// because part infos can wait for multiple state
			// applications before they actually apply
		if ( prt_info[ "perm" ] && prt_info[ "activations" ] <= 0 )
			continue;
		
		// Skip temporary part application if permanent only or already on
		if ( !prt_info[ "perm" ] && ( permanent_only || prt_info[ "activations" ] <= 0 ) )
				continue;
		
		// Decrement the activation counter to see if this part
		// should be swapped. If 0 is reached enough state 
		// entries have occured to apply this part
		self.prt_array[ idx ][ "activations" ]--;
		
		AssertEx( self.prt_array[ idx ][ "activations" ] >= 0, "The state activation count for a damage state part swap should never go below 0." );
		
		if ( self.prt_array[ idx ][ "activations" ] > 0 )
			continue;
		
		// Swap the parts
		if ( IsDefined( prt_info[ "tag_hide" ] ) )
		{
			self.vehicle HidePart( prt_info[ "tag_hide" ] );
		}
		
		self.vehicle ShowPart( prt_info[ "tag_show" ] );
		
		if ( IsDefined( prt_info[ "sound" ] ) )
		{
			self.vehicle thread play_sound_on_tag( prt_info[ "sound" ], prt_info[ "tag_show" ] );
		}
	}
	
	// Apply Sounds
	foreach ( snd_info in self.snd_array )
	{
		// Skip permanent sound application if already on
		if ( snd_info[ "perm" ] && self.perm_on )
			continue;
		
		// Skip temporary sound application if permanent only or already on
		if ( !snd_info[ "perm" ] && ( permanent_only || self.temp_on ) )
			continue;
		
		if ( snd_info[ "loop" ] )
		{
			self.vehicle thread play_loop_sound_on_tag( snd_info[ "alias" ], snd_info[ "tag" ], true, true );
		}
		else
		{
			self.vehicle thread play_sound_on_tag( snd_info[ "alias" ], snd_info[ "tag" ] );
		}
	}
	
	// Apply Distortion. Distortion is never permanent.
	
	if ( !skip_distortion && !permanent_only && IsDefined( self.distort_pct ) && IsDefined( self.distort_time ) )
	{
		self.vehicle.heli.owner DigitalDistortSetParams( self.distort_pct, self.distort_time );
	}
	
	// Record Permanent Settings On
	if ( !self.perm_on )
	{
		self.perm_on = true;
	}
	
	// Record Temporary Settings On
	if ( !permanent_only && !self.temp_on )
	{
		self.temp_on = true;
	}
}

damage_state_clear( ignore_permanent )
{
	AssertEx( IsDefined( ignore_permanent ), "damage_state_clear() called on without required parameter: ignore_permanent" );
	
	// Clear FX
	foreach ( fx_info in self.fx_array )
	{
		// Skip permanent fx if ignoring permanent or if permanent isn't on
		if ( fx_info[ "perm" ] && ( ignore_permanent || !self.perm_on ) )
			continue;
		
		// Skip temporary fx that are not on
		if ( !fx_info[ "perm" ] && !self.temp_on )
			continue;
		
		// Remove the fx
		self damage_state_stop_fx_on_tag( fx_info );
	}
	
	// Clear Parts
	foreach ( idx, prt_info in self.prt_array )
	{
		// Skip permanent part if ignoring permanent or if permanent isn't on
			// Parts have a count of state entries before they can be applied.
			// When that activation count reaches 0 they're applied. Check
			// the activation count here instead of temp_on and perm_on to see
			// if the part is on and needs to be swapped back.
		if ( prt_info[ "perm" ] && ( ignore_permanent || prt_info[ "activations" ] > 0 ) )
			continue;
		
		// Skip temporary part that are not on
		if ( !prt_info[ "perm" ] && prt_info[ "activations" ] > 0 )
			continue;
		
		AssertEx( self.prt_array[ idx ][ "activations" ] >= 0, "The state activation count for a damage state part swap should never go below 0." );
		
		// Increase the activation count here so that 
		// damage_state_apply() knows to re-apply
		self.prt_array[ idx ][ "activations" ]++;
		
		// Swap the parts back
		if ( IsDefined( prt_info[ "tag_hide" ] ) )
		{
			self.vehicle ShowPart( prt_info[ "tag_hide" ] );
		}
		
		self.vehicle HidePart( prt_info[ "tag_show" ] );
	}
	
	// Clear Sounds
	foreach ( snd_info in self.snd_array )
	{
		// Sounds that don't loop don't need to be stopped.
		if ( !snd_info[ "loop" ] )
			continue;
		
		// Don't clear permanent sounds if ignoring permanent or if permanent isn't on
		if ( snd_info[ "perm" ] && ( ignore_permanent || !self.perm_on ) )
			continue;
		
		// Don't clear temporary sounds if temporary settings not on.
		if ( !snd_info[ "perm" ] && !self.temp_on )
			continue;
		
		// Stop the sound
		self.vehicle notify( "stop sound" + snd_info[ "alias" ] );
	}
	
	// Clear distortion
	if ( IsDefined( self.distort_pct ) && IsDefined( self.distort_time ) )
	{
		self.vehicle.heli.owner DigitalDistortSetParams( 0.0, 0.0 );
	}
	
	if ( self.perm_on && !ignore_permanent )
	{
		self.perm_on = false;
	}
	
	if ( self.temp_on )
	{
		self.temp_on = false;
	}
}

damage_state_quake( quake_time_prev )
{
	result = false;
	
	if ( self.quake_scale > 0 && GetTime() - quake_time_prev >= self.quake_interval_msec )
	{
		Earthquake( self.quake_scale, self.quake_time, self.vehicle.heli.owner.origin, 1024 );
		self.vehicle.heli.owner PlayRumbleOnEntity( "damage_light" );
		result = true;
	}
	
	return result;
}

damage_state_health_pct_get()
{
	AssertEx( IsDefined( self ) && IsDefined( self.health_pct ), "damage_state_health_pct_get() called on state struct with no health pct." );
	
	return self.health_pct;
}

damage_state_fx_add( fx, tag, permanent )
{
	AssertEx( IsDefined( self ) && IsDefined( self.fx_array ), "damage_state_fx_add() cannot add fx data to an invalid damage state struct." );
	
	fx_info			  = [];
	fx_info[ "fx"	] = fx;
	fx_info[ "tag"	] = tag;
	fx_info[ "perm" ] = permanent;
	
	self.fx_array[ self.fx_array.size ] = fx_info;
}

damage_state_prt_add( tag_show, permanent, tag_hide, state_activations, sound )
{
	AssertEx( IsDefined( self ) && IsDefined( self.prt_array ), "damage_state_prt_add() cannot add fx data to an invalid damage state struct." );
	
	prt_info			   = [];
	prt_info[ "tag_show" ] = tag_show;
	prt_info[ "perm"	 ] = permanent;
	if ( IsDefined( tag_hide ) )
	{
		prt_info[ "tag_hide" ] = tag_hide;
	}
	
	AssertEx( !IsDefined( state_activations ) || state_activations > 0, "states required for a part to be swapped on the apache must be undefined or at least 1." );
	
	prt_info[ "activations" ] = ter_op( IsDefined( state_activations ), Int( max( state_activations, 1 ) ), 1 );
	
	if ( IsDefined( sound ) )
	{
		prt_info[ "sound" ] = sound;
	}
	
	self.prt_array[ self.prt_array.size ] = prt_info;
}

damage_state_snd_add( alias, tag, permanent, loop )
{
	AssertEx( IsDefined( self ) && IsDefined( self.snd_array ), "damage_state_snd_add() cannot add sound data to an invalid damage state struct." );
	
	snd_info			= [];
	snd_info[ "alias" ] = alias;
	snd_info[ "tag"	  ] = tag;
	snd_info[ "perm"  ] = permanent;
	snd_info[ "loop"  ] = loop;
	
	self.snd_array[ self.snd_array.size ] = snd_info;
}

damage_state_notify_add( msg )
{
	self.notify_msg = msg;
}

damage_state_notify_send_enter()
{
	if ( IsDefined( self.notify_msg ) )
	{
		self.vehicle notify( "LISTEN_apache_damage_state_enter", self.notify_msg );
	}
}

damage_state_notify_send_exit()
{
	if ( IsDefined( self.notify_msg ) )
	{
		self.vehicle notify( "LISTEN_apache_damage_state_exit", self.notify_msg );
	}
}

// Because only 4 fx can be stopped on an entity per frame
// give each unique damage fx tag an ent on request
damage_state_tag_ent_get( tag )
{
	if ( !IsDefined( self.vehicle.damage_state_tag_ents ) )
	{
		self.vehicle.damage_state_tag_ents = [];
	}
	
	if ( !IsDefined( self.vehicle.damage_state_tag_ents[ tag ] ) )
	{
		tag_ent		   = spawn_tag_origin();
		tag_ent.origin = self.vehicle GetTagOrigin( tag );
		tag_ent.angles = self.vehicle GetTagAngles( tag );
		tag_ent LinkTo( self.vehicle, tag );
		
		self.vehicle.damage_state_tag_ents[ tag ] = tag_ent;
	}
	
	return self.vehicle.damage_state_tag_ents[ tag ];
}

damage_state_tag_ent_clear_all()
{
	if ( IsDefined( self.damage_state_tag_ents ) )
	{
		foreach ( ent in self.damage_state_tag_ents )
		{
			ent Delete();
		}
		
		self.damage_state_tag_ents = undefined;
	}
}

damage_state_play_fx_on_tag( fx_info )
{
	tag_ent = self damage_state_tag_ent_get( fx_info[ "tag" ] );
	
	PlayFXOnTag( getfx( fx_info[ "fx" ] ), tag_ent, "tag_origin" );
}

damage_state_stop_fx_on_tag( fx_info )
{
	tag_ent = self damage_state_tag_ent_get( fx_info[ "tag" ] );
	
	StopFXOnTag( getfx( fx_info[ "fx" ] ), tag_ent, "tag_origin" );
}

// Health Access and Update Logic

apache_health_init( health, health_max )
{
	AssertEx( !IsDefined( self.apache_health ), "apache_health_init() called on apache with already defined health value." );
	AssertEx( IsDefined( health ), "apache_health_init() not passed health value" );
	
	// Set health values directly here so that notifications of
	// health changes don't go out
	self.apache_health		= health;
	self.apache_health_max	= ter_op( IsDefined( health_max ), health_max, health );
}

apache_health_get()
{
	return self.apache_health;
}

apache_health_pct_get()
{
	return self apache_health_get() / self apache_health_max_get();
}

apache_health_at_max()
{
	return self apache_health_get() >= self apache_health_max_get();
}

apache_health_set( health )
{
	/#
	if ( IsDefined( self.apache_health_check ) )
	{
		AssertEx( self.apache_health_check == self.apache_health, "apache_health_check != apache_health, health should not be changed outside of apache_health_set()" );
	}
	#/
	
	min_health = ter_op( IsDefined( self.apache_health_min ), self.apache_health_min, 0 );
	
	self.apache_health = Int( clamp( health, min_health, self apache_health_max_get() ) );
	
	self notify( "apache_player_health_updated" );
	
	/#
	self.apache_health_check = self.apache_health;
	#/
}

apache_health_pct_set( pct )
{
	AssertEx( IsDefined( pct ) && pct >= 0 && pct <= 1, "apache health set percent should be greater than 0 and less than or equal to 1" );
	
	self apache_health_set( self apache_health_max_get() * pct );
}

apache_health_pct_min_set( pct )
{
	AssertEx( IsDefined( pct ) && pct > 0 && pct <= 1, "apache health min percent should be greater than 0 and less than or equal to 1" );
	
	self.apache_health_min = Int( self apache_health_max_get() * pct );
}

apache_health_pct_min_clear()
{
	self.apache_health_min = undefined;
}

apache_health_adjust( health )
{
	health_new = self apache_health_get() + health;
	
	self apache_health_set( health_new );
}

apache_health_max_get()
{
	return self.apache_health_max;
}

apache_health_max_set( health )
{
	self.apache_health_max = health;
}

// Player Targeting Wrappers

hud_addAndShowTargets( targets, delay_between_adds )
{
	self.heli.targeting vehicle_scripts\_apache_player_targeting::hud_addTargets( targets, delay_between_adds );
	self.heli.targeting vehicle_scripts\_apache_player_targeting::hud_showTargets( targets );
}

hud_addTargets( targets, delay_between_adds )
{
	self.heli.targeting vehicle_scripts\_apache_player_targeting::hud_addTargets( targets, delay_between_adds );
}

hud_showTargets( targets )
{
	self.heli.targeting vehicle_scripts\_apache_player_targeting::hud_showTargets( targets );
}

hud_hideTargets( targets )
{
	self.heli.targeting vehicle_scripts\_apache_player_targeting::hud_hideTargets( targets );
}

hud_color_ally()
{
	return vehicle_scripts\_apache_player_targeting::hud_color_ally();
}

hud_set_target_locked( target )
{
	vehicle_scripts\_apache_player_targeting::hud_set_target_locked( target );
}

hud_set_target_default( target )
{
	vehicle_scripts\_apache_player_targeting::hud_set_target_default( target );
}

/***********************************/
/************ UTILITY **************/
/***********************************/

// JC-ToDo: This function is duplicated way too often. get_team() in _color should be get_color_team() and these two functions should be added to _utility.gsc
getTeam()
{
	if ( isTurret( self ) && IsDefined( self.script_team ) )
		return self.script_team;
	if ( self maps\_vehicle::IsVehicle() && IsDefined( self.script_team ) )
		return self.script_team;
	if ( IsDefined( self.team ) )
		return self.team;
	return "none";
}

isTurret( obj )
{
	return ( IsDefined( obj ) && IsDefined( obj.classname ) && IsSubStr( obj.classname, "turret" ) );
}

