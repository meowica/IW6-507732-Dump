#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

init_system()
{
	level.death_model_col = getent( "death_collision_map", "targetname" );
	level.scr_model[ "vehicle_t90_tank_woodland_dt" ] = "vehicle_t90_tank_woodland_dt";
	level.friendly_thermal_Reflector_Effect = LoadFX( "fx/misc/thermal_tapereflect_inverted" );
	
	PreCacheModel( "vehicle_gaz_tigr_base_destroyed_oilrocks" );
}

/*** SYSTEM SCRIPT ***/

//***
//		Init Player Tank Script
//***

//		Drivable Tank: Assumes vehicle type of Tank (initially from tank_proto_iw6)

init_tank( tank, player, wait_flag )
{
	AssertEx( IsDefined( tank ) && IsDefined( tank.code_classname ) && tank.code_classname == "script_vehicle", "Tank not valid script vehicle" );
	
	if ( !IsDefined( player ) || !IsPlayer( player ) )
		player = level.player;
	
	if( IsDefined( wait_flag ) )
		flag_wait( wait_flag );
	
	tank mount_tank( player );
}

mount_tank( player, do_static, static_duration, wait_to_mount_after_static )
{
	if( IsDefined( do_static ) )
	{
		if( !IsDefined( static_duration ) )
			static_duration = 1.0;
		
		level.player thread static_on( static_duration, 1.0 );
		
		if ( IsDefined( wait_to_mount_after_static ) )
		{
			wait static_duration;
		}
	}
		
	tank		= self;
	
	flag_set( "player_in_tank" );
	
	player EnableInvulnerability();
	
	//player EnableSlowAim( 0.35, 0.18);
	player EnableSlowAim( 0.5, .25);
	
	player SetPlayerAngles( tank.angles );
	
	level.player player_mount_vehicle( tank );
	
	tank MakeUnusable();
	
	SetSavedDvar( "cg_viewVehicleInfluence", 0.1 );
	
	// Aim assist/ Auto Aim
	SetSavedDvar( "aim_aimAssistRangeScale", "1" );
	SetSavedDvar( "aim_autoAimRangeScale"  , "0" );
	
	thread tank_zoom();
	level.player thread take_fire_tracking();
	tank thread tank_rumble();
	tank thread tank_quake();
	tank thread tank_health_monitor();
	level.player thread tank_hud( tank, static_duration );
	tank thread on_fire_main_cannon();
	tank thread on_fire_mg();
	tank thread tank_handle_sabot();
	tank thread on_pop_smoke();
	tank thread on_fire_sabot();
	thread kill_in_volume();
	level.player thread toggle_thermal();
	level.player.old_contents = level.player.contents;
	level.player.contents = 0;
	
	level thread maps\satfarm_audio::player_tank_turret_sounds();
	
	player LerpViewAngleClamp( 1, .05, .05, 180, 180, 30, 10 );
	
	tank thread do_damage_from_tank();
}

dismount_tank( player, do_static, static_duration )
{
	if( IsDefined( do_static ) )
	{
		if( !IsDefined( static_duration ) )
			static_duration = 1.0;
		
		player thread static_on( static_duration, 1.0 );
	}
	
	tank		= self;
		
	player player_dismount_vehicle();
		
	// Aim assist/ Auto Aim
	SetSavedDvar( "aim_aimAssistRangeScale", "1" );
	SetSavedDvar( "aim_autoAimRangeScale"  , "1" );
	
	flag_clear( "player_in_tank" );
	
	player DisableInvulnerability();
	
	player DisableSlowAim();
	
	player AllowAds( true );
	
	player tank_clear_hud();

	player uav_thermal_off();

	level.player DigitalDistortSetParams( 0, 0 );
		
	player PainVisionOff();
	
	player 	notify( "tank_dismount" );
	tank 	notify ( "stop_do_damage_from_tank" );
	
	player.contents = player.old_contents;
	
	flag_set( "dismounted_tank" );
}

dismount_tank_for_missile( player, do_static, static_duration )
{
	if( IsDefined( do_static ) )
	{
		if( !IsDefined( static_duration ) )
			static_duration = 1.0;
		
		player thread static_on( static_duration, 1.0 );
	}
	
	tank		= self;
		
	player player_dismount_vehicle();
		
	// Aim assist/ Auto Aim
	//SetSavedDvar( "aim_aimAssistRangeScale", "1" );
	SetSavedDvar( "aim_autoAimRangeScale"  , "1" );
	
	flag_clear( "player_in_tank" );
	
	player DisableInvulnerability();
	
	player DisableSlowAim();
	
	player AllowAds( true );
	
	player tank_clear_hud();

	player uav_thermal_off();

	level.player DigitalDistortSetParams( 0, 0 );
		
	player PainVisionOff();
	
	player 	notify( "missile_tank_dismount" );
	tank 	notify ( "stop_do_damage_from_tank" );
	
	player.contents = player.old_contents;
	
	flag_set( "dismounted_tank" );
	
	thread disable_all_triggers();
}

do_damage_from_tank()
{
	self endon( "stop_do_damage_from_tank" );
	self endon( "death" );
	
	while( 1 )
	{
		RadiusDamage( self.origin + ( 80, 0, 0 ), 100, 999, 500, self, "MOD_RIFLE_BULLET" );
		RadiusDamage( self.origin - ( 80, 0, 0 ), 100, 999, 500, self, "MOD_RIFLE_BULLET" );
		wait( 0.05 );
	}
}

/*** Tank Rumble Control ***/

CONST_TANK_SPEED_MAX						= 50;
CONST_TANK_RUMBLE_RANGE_FOR_MAX_SHAKE		= 400;	// Highest rumble distance
CONST_TANK_RUMBLE_RANGE_FOR_MIN_SHAKE		= 500;	// Lowest rumble distance. Actual rumble range is 750 but that would yield zero rumble.

tank_rumble()
{
	self endon( "death" );
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	tank = self;
	rumble_ent = Spawn( "script_origin", tank.driver.origin + (0.0, 0.0, CONST_TANK_RUMBLE_RANGE_FOR_MIN_SHAKE ) );
	rumble_ent PlayRumbleLoopOnEntity( "subtler_tank_rumble" );
	
	last_quake = GetTime();
	while ( 1 )
	{
		speed = tank Vehicle_GetSpeed();
		ratio = clamp( 1 - speed / CONST_TANK_SPEED_MAX, 0.0, 1.0 );
		
		offset_z = CONST_TANK_RUMBLE_RANGE_FOR_MAX_SHAKE + ( ( CONST_TANK_RUMBLE_RANGE_FOR_MIN_SHAKE - CONST_TANK_RUMBLE_RANGE_FOR_MAX_SHAKE ) * ratio );
		rumble_ent Unlink();
		rumble_ent LinkTo( level.player, "", (0.0, 0.0, offset_z), (0.0, 0.0, 0.0) );
		
		wait 0.1;
	}
}

CONST_TANK_QUAKE_SCALE_FIRE					= 0.4;	// Quake size on cannon fire
CONST_TANK_QUAKE_SCALE_MAX					= 0.10;	// Largest quake size
CONST_TANK_QUAKE_SCALE_MIN					= 0.05; // Smallest quake size, always have some shake just like the idle.
CONST_TANK_QUAKE_LENGTH_SEC					= 0.25; // Length of each quake. Must be short because the quake is played in a location and the player is moving.

tank_quake()
{
	self endon( "death" );
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	tank = self;
//	turret = tank.mgturret[ 0 ];

	last_quake = GetTime();
	level.isFiring = false;
	
	while ( 1 )
	{
		speed = tank Vehicle_GetSpeed();
		ratio = clamp( speed / CONST_TANK_SPEED_MAX, 0.0, 1.0 );
		
		if ( level.isFiring )
		{
			EarthQuake( CONST_TANK_QUAKE_SCALE_FIRE, 1.0, tank.driver.origin, 512 );
			wait 0.9;
			level.isFiring = false;
			continue;
		}
		
		quake_scale = CONST_TANK_QUAKE_SCALE_MIN + ( CONST_TANK_QUAKE_SCALE_MAX - CONST_TANK_QUAKE_SCALE_MIN ) * ratio;
		EarthQuake( quake_scale, CONST_TANK_QUAKE_LENGTH_SEC, tank.driver.origin, 512 );
		
		wait .05;
	}
}

/*** Tank Health Control ***/

CONST_TANK_QUAKE_SCALE_HIT					= 0.5;

tank_health_monitor()
{
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	level endon( "final_hit" );
	
	self.current_hit_count = 0;
	self.max_hit_count = 10;
	
	self.max_health = self.health;
	
	//thread tank_desat_monitor();
		
	while ( !flag( "final_hit" ) )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		
		type = ToLower( type );
			
		/#
		if ( IsGodMode( level.player ) )
		{
			self.health = self.max_health;
			continue;
		}
		#/
			
		if ( ( type != "mod_projectile" ) && ( type != "mod_projectile_splash" ) )
		{
			self.health = self.max_health;
			continue;
		}
		
		self.current_hit_count++;
		
		EarthQuake( CONST_TANK_QUAKE_SCALE_HIT, 1.0, self.origin, 512 );
		level.player PlayRumbleOnEntity( "damage_heavy" );
		level.player ViewKick( 1, point );
		percentage = (1/self.max_hit_count) * (self.current_hit_count - ( .2 * self.current_hit_count ));
		level.player DigitalDistortSetParams( percentage, percentage );
				 
		//level.player PainVisionOn();
		
		
		if ( self.current_hit_count >= self.max_hit_count )
		{
			self MakeUsable();
			self UseBy( level.player );
			level.player DisableInvulnerability();
			level.player Kill();
			//self godoff();
			self Kill();
			return;
		}
		else
		{
			self.health = self.maxhealth;
			self thread tank_health_regen();
		}
	}
}

tank_health_regen()
{
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	level endon( "final_hit" );
	self endon( "damage" );
	self endon( "death" );
	
	regen_time = 5;
	
	while ( self.current_hit_count > 0 )
	{
		wait regen_time;
		self.current_hit_count--;
		self notify( "regen" );
		
		percentage = (1/self.max_hit_count) * (self.current_hit_count - ( .2 * self.current_hit_count ));
		level.player DigitalDistortSetParams( percentage, percentage );
		
		if ( regen_time > 1 )
		{
			regen_time--;
		}
	}
	
	level.player PainVisionOff();
}

/*** Zoom Controls***/

tank_zoom()
{
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	level.player NotifyOnPlayerCommand( "zoomin", "+speed_throw" );
	level.player NotifyOnPlayerCommand( "zoomout", "-speed_throw" );
	
	//thread toggle_zoom();
	level.zoomLevel = 15;
	
	while( !flag( "optics_out" ) )
	{
		level.player waittill( "zoomin" );
		
		if ( !IsDefined( level.player.tank_hud_item[ "current_weapon" ] ) && level.player.tank_hud_item[ "current_weapon" ].weap != "turret" )
		{
			continue;
		}
		
		level.player LerpFOV( level.zoomLevel, 0.15 );
				
		flag_set( "ZOOM_ON" );
				
		level.player waittill( "zoomout" );
		
		if ( !IsDefined( level.player.tank_hud_item[ "current_weapon" ] ) && level.player.tank_hud_item[ "current_weapon" ].weap != "turret" )
		{
			continue;
		}
		
		level.player LerpFOV( 65, 0.15 );
		
		flag_clear( "ZOOM_ON" );
	}
}

toggle_zoom()
{
	level.player NotifyOnPlayerCommand( "zoom", "+actionslot 4" );
	
	while( 1 )
	{		
		IPrintLnBold( "Zoom 20 DEFAULT." );
		
		level.zoomLevel = 20;
		
		wait .05;
		
		level.player waittill( "zoom" );
		
		IPrintLnBold( "Zoom 30." );
		
		level.zoomLevel = 30;
		
		wait .05;
		
		level.player waittill( "zoom" );
		
		IPrintLnBold( "Zoom 40." );
		
		level.zoomLevel = 40;
		
		wait .05;
		
		level.player waittill( "zoom" );
		
		IPrintLnBold( "Zoom 50." );
		
		level.zoomLevel = 50;
		
		wait .05;
		
		level.player waittill( "zoom" );
		
		IPrintLnBold( "Zoom 60." );
			
		level.zoomLevel = 60;
		
		wait .05;
		
		level.player waittill( "zoom" );
		
		IPrintLnBold( "Zoom 65." );
		
		level.zoomLevel = 65;
		
		wait .05;
		
		level.player waittill( "zoom" );
	}
}

// AI kill volume
kill_in_volume()
{
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	playertankvol = getent( "playertank_kill_vol", "targetname" );
	
	//thread kill_gazs_in_vol( playertankvol );
	
	while( 1 )
	{
		// move trigger to position
		playertankvol.origin = level.playertank.origin;	
		playertankvol.angles = level.playertank.angles;	
		
		//print3d( playertankvol.origin, "HERE", (1,0,0), 1, 10, 10 );
		//thread draw_line_from_ent_to_vec_for_time( playertankvol, AnglesToForward( playertankvol.angles ), 1000, 1, 0, 0, 1 );
		
		// kill ai touching vol
		enemies = playertankvol get_ai_touching_volume( "axis", "human", 1 );
		if( IsDefined( enemies ) )
			foreach( enemy in enemies )
			{
				//print3d( enemy.origin, "Dead", (0,0,1), 1, 10, 100 );
				enemy kill();
				
			}
		enemies = undefined;
		
		wait .01;
	}
}

/*** Tank Hud ***/

tank_hud( tank, delay )
{
	if ( IsDefined( delay ) )
	{
		wait delay;
	}
	
	self.tank_hud_item[ "reticle" ] = maps\_hud_util::createIcon( "m1a1_tank_primary_reticle", 400, 200 );
	self.tank_hud_item[ "reticle" ] set_default_hud_parameters();
	self.tank_hud_item[ "reticle" ].alignX = "center";
	self.tank_hud_item[ "reticle" ].alignY = "middle";
	self.tank_hud_item[ "reticle" ].alpha = 0.66;
	
	self.tank_hud_item[ "reticle_center" ] = maps\_hud_util::createIcon( "m1a1_tank_primary_reticle_center", 20, 20 );
	self.tank_hud_item[ "reticle_center" ] set_default_hud_parameters();
	self.tank_hud_item[ "reticle_center" ].alignX = "center";
	self.tank_hud_item[ "reticle_center" ].alignY = "middle";
	self.tank_hud_item[ "reticle_center" ].alpha = 0.66;
	
	self.tank_hud_item[ "reticle_center_red" ] = maps\_hud_util::createIcon( "m1a1_tank_primary_reticle_center_red", 20, 20 );
	self.tank_hud_item[ "reticle_center_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "reticle_center_red" ].alignX = "center";
	self.tank_hud_item[ "reticle_center_red" ].alignY = "middle";
	self.tank_hud_item[ "reticle_center_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "reticle_cross" ] = maps\_hud_util::createIcon( "m1a1_tank_primary_reticle_cross", 88, 88 );
	self.tank_hud_item[ "reticle_cross" ] set_default_hud_parameters();
	self.tank_hud_item[ "reticle_cross" ].alignX = "center";
	self.tank_hud_item[ "reticle_cross" ].alignY = "middle";
	self.tank_hud_item[ "reticle_cross" ].alpha = 0.66;
	
	self.tank_hud_item[ "reticle_cross_red" ] = maps\_hud_util::createIcon( "m1a1_tank_primary_reticle_cross_red", 88, 88 );
	self.tank_hud_item[ "reticle_cross_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "reticle_cross_red" ].alignX = "center";
	self.tank_hud_item[ "reticle_cross_red" ].alignY = "middle";
	self.tank_hud_item[ "reticle_cross_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "compass_heading" ] = maps\_hud_util::createIcon( "m1a1_compass_center", 10, 20 );
	self.tank_hud_item[ "compass_heading" ] set_default_hud_parameters();
	self.tank_hud_item[ "compass_heading" ].alignX = "center";
	self.tank_hud_item[ "compass_heading" ].alignY = "top";
	self.tank_hud_item[ "compass_heading" ].vertAlign = "top";
	self.tank_hud_item[ "compass_heading" ].x = 0;
	self.tank_hud_item[ "compass_heading" ].y = 10;
	self.tank_hud_item[ "compass_heading" ].alpha = 0.9;
	
	self.tank_hud_item[ "turret_state_bg" ] = maps\_hud_util::createIcon( "m1a1_tank_weapon_progress_bar", 96, 12 );
	self.tank_hud_item[ "turret_state_bg" ] set_default_hud_parameters();
	self.tank_hud_item[ "turret_state_bg" ].alignX = "center";
	self.tank_hud_item[ "turret_state_bg" ].alignY = "middle";
	self.tank_hud_item[ "turret_state_bg" ].vertAlign = "bottom";
	self.tank_hud_item[ "turret_state_bg" ].x = 110;
	self.tank_hud_item[ "turret_state_bg" ].y = -50;
	self.tank_hud_item[ "turret_state_bg" ].alpha = 0.9;
	
	self.tank_hud_item[ "turret_state" ] = maps\_hud_util::createIcon( "green_block", 57, 5 );
	self.tank_hud_item[ "turret_state" ] set_default_hud_parameters();
	self.tank_hud_item[ "turret_state" ].alignX = "left";
	self.tank_hud_item[ "turret_state" ].alignY = "middle";
	self.tank_hud_item[ "turret_state" ].vertAlign = "bottom";
	self.tank_hud_item[ "turret_state" ].x = 82;
	self.tank_hud_item[ "turret_state" ].y = -51;
	self.tank_hud_item[ "turret_state" ].alpha = 0.4;
	
	self.tank_hud_item[ "turret_name" ] = maps\_hud_util::createClientFontString( "default", 1.3 );	
	self.tank_hud_item[ "turret_name" ] set_default_hud_parameters();
	self.tank_hud_item[ "turret_name" ].alignX = "center";
	self.tank_hud_item[ "turret_name" ].alignY = "bottom";
	self.tank_hud_item[ "turret_name" ].vertAlign = "bottom";
	self.tank_hud_item[ "turret_name" ].alpha = 0.9;
	self.tank_hud_item[ "turret_name" ].x = 110;
	self.tank_hud_item[ "turret_name" ].y = -57;
	self.tank_hud_item[ "turret_name" ] SetText( "CANNON .120" );
	
	self.tank_hud_item[ "turret_status" ] = maps\_hud_util::createClientFontString( "default", 1.3 );	
	self.tank_hud_item[ "turret_status" ] set_default_hud_parameters();
	self.tank_hud_item[ "turret_status" ].alignX = "center";
	self.tank_hud_item[ "turret_status" ].alignY = "top";
	self.tank_hud_item[ "turret_status" ].vertAlign = "bottom";
	self.tank_hud_item[ "turret_status" ].alpha = 0.9;
	self.tank_hud_item[ "turret_status" ].x = 110;
	self.tank_hud_item[ "turret_status" ].y = -43;
	self.tank_hud_item[ "turret_status" ] SetText( "READY" );
	
	self.tank_hud_item[ "turret_offline" ] = maps\_hud_util::createClientFontString( "default", 1.6 );	
	self.tank_hud_item[ "turret_offline" ] set_default_hud_parameters();
	self.tank_hud_item[ "turret_offline" ].alignX = "center";
	self.tank_hud_item[ "turret_offline" ].alignY = "middle";
	self.tank_hud_item[ "turret_offline" ].vertAlign = "bottom";
	self.tank_hud_item[ "turret_offline" ].alpha = 0;
	self.tank_hud_item[ "turret_offline" ].x = 110;
	self.tank_hud_item[ "turret_offline" ].y = -50;
	self.tank_hud_item[ "turret_offline" ] SetText( &"SATFARM_OFFLINE" );
	
	//smoke
	self.tank_hud_item[ "smoke_state_bg" ] = maps\_hud_util::createIcon( "m1a1_tank_weapon_progress_bar", 96, 12 );
	self.tank_hud_item[ "smoke_state_bg" ] set_default_hud_parameters();
	self.tank_hud_item[ "smoke_state_bg" ].alignX = "center";
	self.tank_hud_item[ "smoke_state_bg" ].alignY = "middle";
	self.tank_hud_item[ "smoke_state_bg" ].vertAlign = "bottom";
	self.tank_hud_item[ "smoke_state_bg" ].x = -300;
	self.tank_hud_item[ "smoke_state_bg" ].y = -50;
	self.tank_hud_item[ "smoke_state_bg" ].alpha = 0.9;
	
	self.tank_hud_item[ "smoke_state" ] = maps\_hud_util::createIcon( "green_block", 57, 5 );
	self.tank_hud_item[ "smoke_state" ] set_default_hud_parameters();
	self.tank_hud_item[ "smoke_state" ].alignX = "left";
	self.tank_hud_item[ "smoke_state" ].alignY = "middle";
	self.tank_hud_item[ "smoke_state" ].vertAlign = "bottom";
	self.tank_hud_item[ "smoke_state" ].x = -328;
	self.tank_hud_item[ "smoke_state" ].y = -51;
	self.tank_hud_item[ "smoke_state" ].alpha = 0.4;
	
	self.tank_hud_item[ "smoke_name" ] = maps\_hud_util::createClientFontString( "default", 1.3 );	
	self.tank_hud_item[ "smoke_name" ] set_default_hud_parameters();
	self.tank_hud_item[ "smoke_name" ].alignX = "center";
	self.tank_hud_item[ "smoke_name" ].alignY = "bottom";
	self.tank_hud_item[ "smoke_name" ].vertAlign = "bottom";
	self.tank_hud_item[ "smoke_name" ].alpha = 0.9;
	self.tank_hud_item[ "smoke_name" ].x = -300;
	self.tank_hud_item[ "smoke_name" ].y = -57;
	self.tank_hud_item[ "smoke_name" ] SetText( "SMOKE" );
	
	self.tank_hud_item[ "smoke_status" ] = maps\_hud_util::createClientFontString( "default", 1.3 );	
	self.tank_hud_item[ "smoke_status" ] set_default_hud_parameters();
	self.tank_hud_item[ "smoke_status" ].alignX = "center";
	self.tank_hud_item[ "smoke_status" ].alignY = "top";
	self.tank_hud_item[ "smoke_status" ].vertAlign = "bottom";
	self.tank_hud_item[ "smoke_status" ].alpha = 0.9;
	self.tank_hud_item[ "smoke_status" ].x = -300;
	self.tank_hud_item[ "smoke_status" ].y = -43;
	self.tank_hud_item[ "smoke_status" ] SetText( "READY" );
	
	self.tank_hud_item[ "smoke_offline" ] = maps\_hud_util::createClientFontString( "default", 1.6 );	
	self.tank_hud_item[ "smoke_offline" ] set_default_hud_parameters();
	self.tank_hud_item[ "smoke_offline" ].alignX = "center";
	self.tank_hud_item[ "smoke_offline" ].alignY = "middle";
	self.tank_hud_item[ "smoke_offline" ].vertAlign = "bottom";
	self.tank_hud_item[ "smoke_offline" ].alpha = 0;
	self.tank_hud_item[ "smoke_offline" ].x = -300;
	self.tank_hud_item[ "smoke_offline" ].y = -50;
	self.tank_hud_item[ "smoke_offline" ] SetText( &"SATFARM_OFFLINE" );
	
	self.tank_hud_item[ "missile_state_bg" ] = maps\_hud_util::createIcon( "m1a1_tank_weapon_progress_bar", 96, 12 );
	self.tank_hud_item[ "missile_state_bg" ] set_default_hud_parameters();
	self.tank_hud_item[ "missile_state_bg" ].alignX = "center";
	self.tank_hud_item[ "missile_state_bg" ].alignY = "middle";
	self.tank_hud_item[ "missile_state_bg" ].vertAlign = "bottom";
	self.tank_hud_item[ "missile_state_bg" ].x = 200;
	self.tank_hud_item[ "missile_state_bg" ].y = -50;
	self.tank_hud_item[ "missile_state_bg" ].alpha = 0.9;
	
	self.tank_hud_item[ "missile_state" ] = maps\_hud_util::createIcon( "green_block", 57, 5 );
	self.tank_hud_item[ "missile_state" ] set_default_hud_parameters();
	self.tank_hud_item[ "missile_state" ].alignX = "left";
	self.tank_hud_item[ "missile_state" ].alignY = "middle";
	self.tank_hud_item[ "missile_state" ].vertAlign = "bottom";
	self.tank_hud_item[ "missile_state" ].x = 172;
	self.tank_hud_item[ "missile_state" ].y = -51;
	self.tank_hud_item[ "missile_state" ].alpha = 0.4;
	
	self.tank_hud_item[ "missile_name" ] = maps\_hud_util::createClientFontString( "default", 1.3 );	
	self.tank_hud_item[ "missile_name" ] set_default_hud_parameters();
	self.tank_hud_item[ "missile_name" ].alignX = "center";
	self.tank_hud_item[ "missile_name" ].alignY = "bottom";
	self.tank_hud_item[ "missile_name" ].vertAlign = "bottom";
	self.tank_hud_item[ "missile_name" ].alpha = 0.25;
	self.tank_hud_item[ "missile_name" ].x = 200;
	self.tank_hud_item[ "missile_name" ].y = -57;
	self.tank_hud_item[ "missile_name" ] SetText( "PATRIOT-XM11" );
	
	self.tank_hud_item[ "missile_status" ] = maps\_hud_util::createClientFontString( "default", 1.3 );	
	self.tank_hud_item[ "missile_status" ] set_default_hud_parameters();
	self.tank_hud_item[ "missile_status" ].alignX = "center";
	self.tank_hud_item[ "missile_status" ].alignY = "top";
	self.tank_hud_item[ "missile_status" ].vertAlign = "bottom";
	self.tank_hud_item[ "missile_status" ].alpha = 0.25;
	self.tank_hud_item[ "missile_status" ].x = 200;
	self.tank_hud_item[ "missile_status" ].y = -43;
	self.tank_hud_item[ "missile_status" ] SetText( "IDLE" );
	
	self.tank_hud_item[ "missile_offline" ] = maps\_hud_util::createClientFontString( "default", 1.6 );	
	self.tank_hud_item[ "missile_offline" ] set_default_hud_parameters();
	self.tank_hud_item[ "missile_offline" ].alignX = "center";
	self.tank_hud_item[ "missile_offline" ].alignY = "middle";
	self.tank_hud_item[ "missile_offline" ].vertAlign = "bottom";
	self.tank_hud_item[ "missile_offline" ].alpha = 0;
	self.tank_hud_item[ "missile_offline" ].x = 200;
	self.tank_hud_item[ "missile_offline" ].y = -50;
	self.tank_hud_item[ "missile_offline" ] SetText( &"SATFARM_OFFLINE" );
	
	self.tank_hud_item[ "current_weapon" ] = maps\_hud_util::createIcon( "m1a1_tank_weapon_select_arrow", 12, 12 );
	self.tank_hud_item[ "current_weapon" ] set_default_hud_parameters();
	self.tank_hud_item[ "current_weapon" ].alignX = "center";
	self.tank_hud_item[ "current_weapon" ].alignY = "top";
	self.tank_hud_item[ "current_weapon" ].vertAlign = "bottom";
	self.tank_hud_item[ "current_weapon" ].x = 110;
	self.tank_hud_item[ "current_weapon" ].y = -26;
	self.tank_hud_item[ "current_weapon" ].alpha = 0.9;
	self.tank_hud_item[ "current_weapon" ].weap = "turret";
	
	self.tank_hud_item[ "weapon_separator" ] = maps\_hud_util::createIcon( "white", 1, 48 );
	self.tank_hud_item[ "weapon_separator" ] set_default_hud_parameters();
	self.tank_hud_item[ "weapon_separator" ].alignX = "center";
	self.tank_hud_item[ "weapon_separator" ].alignY = "middle";
	self.tank_hud_item[ "weapon_separator" ].vertAlign = "bottom";
	self.tank_hud_item[ "weapon_separator" ].x = 251;
	self.tank_hud_item[ "weapon_separator" ].y = -50;
	self.tank_hud_item[ "weapon_separator" ].alpha = 0.9;
	
	self.tank_hud_item[ "mg_state_bg" ] = maps\_hud_util::createIcon( "m1a1_tank_weapon_progress_bar_infinite", 96, 12 );
	self.tank_hud_item[ "mg_state_bg" ] set_default_hud_parameters();
	self.tank_hud_item[ "mg_state_bg" ].alignX = "center";
	self.tank_hud_item[ "mg_state_bg" ].alignY = "middle";
	self.tank_hud_item[ "mg_state_bg" ].vertAlign = "bottom";
	self.tank_hud_item[ "mg_state_bg" ].x = 300;
	self.tank_hud_item[ "mg_state_bg" ].y = -50;
	self.tank_hud_item[ "mg_state_bg" ].alpha = 0.9;
	
	self.tank_hud_item[ "mg_state" ] = maps\_hud_util::createIcon( "green_block", 57, 5 );
	self.tank_hud_item[ "mg_state" ] set_default_hud_parameters();
	self.tank_hud_item[ "mg_state" ].alignX = "left";
	self.tank_hud_item[ "mg_state" ].alignY = "middle";
	self.tank_hud_item[ "mg_state" ].vertAlign = "bottom";
	self.tank_hud_item[ "mg_state" ].x = 272;
	self.tank_hud_item[ "mg_state" ].y = -51;
	self.tank_hud_item[ "mg_state" ].alpha = 0.4;
	
	self.tank_hud_item[ "mg_name" ] = maps\_hud_util::createClientFontString( "default", 1.3 );	
	self.tank_hud_item[ "mg_name" ] set_default_hud_parameters();
	self.tank_hud_item[ "mg_name" ].alignX = "center";
	self.tank_hud_item[ "mg_name" ].alignY = "bottom";
	self.tank_hud_item[ "mg_name" ].vertAlign = "bottom";
	self.tank_hud_item[ "mg_name" ].alpha = 0.9;
	self.tank_hud_item[ "mg_name" ].x = 300;
	self.tank_hud_item[ "mg_name" ].y = -57;
	self.tank_hud_item[ "mg_name" ] SetText( "HMG .50" );
	
	self.tank_hud_item[ "mg_offline" ] = maps\_hud_util::createClientFontString( "default", 1.6 );	
	self.tank_hud_item[ "mg_offline" ] set_default_hud_parameters();
	self.tank_hud_item[ "mg_offline" ].alignX = "center";
	self.tank_hud_item[ "mg_offline" ].alignY = "middle";
	self.tank_hud_item[ "mg_offline" ].vertAlign = "bottom";
	self.tank_hud_item[ "mg_offline" ].alpha = 0;
	self.tank_hud_item[ "mg_offline" ].x = 300;
	self.tank_hud_item[ "mg_offline" ].y = -50;
	self.tank_hud_item[ "mg_offline" ] SetText( &"SATFARM_OFFLINE" );
	
	self.tank_hud_item[ "speed_bar_bg" ] = maps\_hud_util::createIcon( "m1a1_tank_weapon_progress_bar", 96, 12 );
	self.tank_hud_item[ "speed_bar_bg" ] set_default_hud_parameters();
	self.tank_hud_item[ "speed_bar_bg" ].alignX = "center";
	self.tank_hud_item[ "speed_bar_bg" ].alignY = "middle";
	self.tank_hud_item[ "speed_bar_bg" ].vertAlign = "bottom";
	self.tank_hud_item[ "speed_bar_bg" ].x = -200;
	self.tank_hud_item[ "speed_bar_bg" ].y = -50;
	self.tank_hud_item[ "speed_bar_bg" ].alpha = 0.9;
	
	self.tank_hud_item[ "speed_bar" ] = maps\_hud_util::createIcon( "green_block", 57, 5 );
	self.tank_hud_item[ "speed_bar" ] set_default_hud_parameters();
	self.tank_hud_item[ "speed_bar" ].alignX = "left";
	self.tank_hud_item[ "speed_bar" ].alignY = "middle";
	self.tank_hud_item[ "speed_bar" ].vertAlign = "bottom";
	self.tank_hud_item[ "speed_bar" ].x = -228;
	self.tank_hud_item[ "speed_bar" ].y = -51;
	self.tank_hud_item[ "speed_bar" ].alpha = 0.4;
	
	self.tank_hud_item[ "speed" ] = maps\_hud_util::createClientFontString( "default", 1.0 );	
	self.tank_hud_item[ "speed" ] set_default_hud_parameters();
	self.tank_hud_item[ "speed" ].alignX = "left";
	self.tank_hud_item[ "speed" ].alignY = "bottom";
	self.tank_hud_item[ "speed" ].vertAlign = "bottom";
	self.tank_hud_item[ "speed" ].alpha = 0.9;
	self.tank_hud_item[ "speed" ].x = -200;
	self.tank_hud_item[ "speed" ].y = -57;
	self.tank_hud_item[ "speed" ] SetText( "mph" );
	
	self.tank_hud_item[ "speed_label" ] = maps\_hud_util::createClientFontString( "default", 1.7 );	
	self.tank_hud_item[ "speed_label" ] set_default_hud_parameters();
	self.tank_hud_item[ "speed_label" ].alignX = "right";
	self.tank_hud_item[ "speed_label" ].alignY = "bottom";
	self.tank_hud_item[ "speed_label" ].vertAlign = "bottom";
	self.tank_hud_item[ "speed_label" ].alpha = 0.9;
	self.tank_hud_item[ "speed_label" ].x = -200;
	self.tank_hud_item[ "speed_label" ].y = -57;
	self.tank_hud_item[ "speed_label" ] SetText( "0" );
	
	self.tank_hud_item[ "min_speed" ] = maps\_hud_util::createClientFontString( "default", 1.0 );	
	self.tank_hud_item[ "min_speed" ] set_default_hud_parameters();
	self.tank_hud_item[ "min_speed" ].alignX = "right";
	self.tank_hud_item[ "min_speed" ].alignY = "top";
	self.tank_hud_item[ "min_speed" ].vertAlign = "bottom";
	self.tank_hud_item[ "min_speed" ].alpha = 0.9;
	self.tank_hud_item[ "min_speed" ].x = -232;
	self.tank_hud_item[ "min_speed" ].y = -57;
	self.tank_hud_item[ "min_speed" ] SetText( "0" );
	
	max_speed = 50;
	
	self.tank_hud_item[ "max_speed" ] = maps\_hud_util::createClientFontString( "default", 1.0 );	
	self.tank_hud_item[ "max_speed" ] set_default_hud_parameters();
	self.tank_hud_item[ "max_speed" ].alignX = "center";
	self.tank_hud_item[ "max_speed" ].alignY = "top";
	self.tank_hud_item[ "max_speed" ].vertAlign = "bottom";
	self.tank_hud_item[ "max_speed" ].alpha = 0.9;
	self.tank_hud_item[ "max_speed" ].x = -161;
	self.tank_hud_item[ "max_speed" ].y = -57;
	self.tank_hud_item[ "max_speed" ] SetText( max_speed );
	
	
	
	self.tank_hud_item[ "sabot_overlay" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_grid_overlay", 640, 480 );
	self.tank_hud_item[ "sabot_overlay" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_overlay" ].alignX = "left";
	self.tank_hud_item[ "sabot_overlay" ].alignY = "top";
	self.tank_hud_item[ "sabot_overlay" ].horzAlign = "fullscreen";
	self.tank_hud_item[ "sabot_overlay" ].vertAlign = "fullscreen";
	self.tank_hud_item[ "sabot_overlay" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_overlay" ].sort -= 5;
	
	self.tank_hud_item[ "sabot_vignette" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_vignette", 640, 480 );
	self.tank_hud_item[ "sabot_vignette" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_vignette" ].alignX = "left";
	self.tank_hud_item[ "sabot_vignette" ].alignY = "top";
	self.tank_hud_item[ "sabot_vignette" ].horzAlign = "fullscreen";
	self.tank_hud_item[ "sabot_vignette" ].vertAlign = "fullscreen";
	self.tank_hud_item[ "sabot_vignette" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_vignette" ].sort -= 5;
	
	self.tank_hud_item[ "sabot_reticle" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_reticle_center", 75, 75 );
	self.tank_hud_item[ "sabot_reticle" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_red" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_reticle_center_red", self.tank_hud_item[ "sabot_reticle" ].width, self.tank_hud_item[ "sabot_reticle" ].height );
	self.tank_hud_item[ "sabot_reticle_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_red" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_red" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_upper_left" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_top_left", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_upper_left" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_upper_left" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_upper_left" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_upper_left" ].x = self.tank_hud_item[ "sabot_reticle" ].width * -1.25;
	self.tank_hud_item[ "sabot_reticle_upper_left" ].y = self.tank_hud_item[ "sabot_reticle" ].height * -0.5;
	self.tank_hud_item[ "sabot_reticle_upper_left" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_upper_left_red" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_top_left_red", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_upper_left_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_upper_left_red" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_upper_left_red" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_upper_left_red" ].x = self.tank_hud_item[ "sabot_reticle" ].width * -1.25;
	self.tank_hud_item[ "sabot_reticle_upper_left_red" ].y = self.tank_hud_item[ "sabot_reticle" ].height * -0.5;
	self.tank_hud_item[ "sabot_reticle_upper_left_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_upper_right" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_top_right", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_upper_right" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_upper_right" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_upper_right" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_upper_right" ].x = self.tank_hud_item[ "sabot_reticle" ].width * 1.25;
	self.tank_hud_item[ "sabot_reticle_upper_right" ].y = self.tank_hud_item[ "sabot_reticle" ].height * -0.5;
	self.tank_hud_item[ "sabot_reticle_upper_right" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_upper_right_red" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_top_right_red", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_upper_right_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_upper_right_red" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_upper_right_red" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_upper_right_red" ].x = self.tank_hud_item[ "sabot_reticle" ].width * 1.25;
	self.tank_hud_item[ "sabot_reticle_upper_right_red" ].y = self.tank_hud_item[ "sabot_reticle" ].height * -0.5;
	self.tank_hud_item[ "sabot_reticle_upper_right_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_bottom_left" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_bottom_left", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_bottom_left" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_bottom_left" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_bottom_left" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_bottom_left" ].x = self.tank_hud_item[ "sabot_reticle" ].width * -1.25;
	self.tank_hud_item[ "sabot_reticle_bottom_left" ].y = self.tank_hud_item[ "sabot_reticle" ].height * 0.5;
	self.tank_hud_item[ "sabot_reticle_bottom_left" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_bottom_left_red" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_bottom_left_red", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_bottom_left_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].x = self.tank_hud_item[ "sabot_reticle" ].width * -1.25;
	self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].y = self.tank_hud_item[ "sabot_reticle" ].height * 0.5;
	self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_bottom_right" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_bottom_right", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_bottom_right" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_bottom_right" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_bottom_right" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_bottom_right" ].x = self.tank_hud_item[ "sabot_reticle" ].width * 1.25;
	self.tank_hud_item[ "sabot_reticle_bottom_right" ].y = self.tank_hud_item[ "sabot_reticle" ].height * 0.5;
	self.tank_hud_item[ "sabot_reticle_bottom_right" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_bottom_right_red" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_bottom_right_red", 20, 20 );
	self.tank_hud_item[ "sabot_reticle_bottom_right_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].x = self.tank_hud_item[ "sabot_reticle" ].width * 1.25;
	self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].y = self.tank_hud_item[ "sabot_reticle" ].height * 0.5;
	self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_outer_left" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_reticle_outer_left", 40, 320 );
	self.tank_hud_item[ "sabot_reticle_outer_left" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_outer_left" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_outer_left" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_outer_left" ].x = self.tank_hud_item[ "sabot_reticle" ].width * -2;
	self.tank_hud_item[ "sabot_reticle_outer_left" ].y = 0;
	self.tank_hud_item[ "sabot_reticle_outer_left" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_outer_left_red" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_reticle_outer_left_red", 40, 320 );
	self.tank_hud_item[ "sabot_reticle_outer_left_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_outer_left_red" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_outer_left_red" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_outer_left_red" ].x = self.tank_hud_item[ "sabot_reticle" ].width * -2;
	self.tank_hud_item[ "sabot_reticle_outer_left_red" ].y = 0;
	self.tank_hud_item[ "sabot_reticle_outer_left_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_outer_right" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_reticle_outer_right", 40, 320 );
	self.tank_hud_item[ "sabot_reticle_outer_right" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_outer_right" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_outer_right" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_outer_right" ].x = self.tank_hud_item[ "sabot_reticle" ].width * 2;
	self.tank_hud_item[ "sabot_reticle_outer_right" ].y = 0;
	self.tank_hud_item[ "sabot_reticle_outer_right" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_reticle_outer_right_red" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_reticle_outer_right_red", 40, 320 );
	self.tank_hud_item[ "sabot_reticle_outer_right_red" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_reticle_outer_right_red" ].alignX = "center";
	self.tank_hud_item[ "sabot_reticle_outer_right_red" ].alignY = "middle";
	self.tank_hud_item[ "sabot_reticle_outer_right_red" ].x = self.tank_hud_item[ "sabot_reticle" ].width * 2;
	self.tank_hud_item[ "sabot_reticle_outer_right_red" ].y = 0;
	self.tank_hud_item[ "sabot_reticle_outer_right_red" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_target_range" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_target_range", 20, 320 );
	self.tank_hud_item[ "sabot_target_range" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_target_range" ].alignX = "center";
	self.tank_hud_item[ "sabot_target_range" ].alignY = "middle";
	self.tank_hud_item[ "sabot_target_range" ].x = self.tank_hud_item[ "sabot_reticle" ].width * 3;
	self.tank_hud_item[ "sabot_target_range" ].y = 0;
	self.tank_hud_item[ "sabot_target_range" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_fuel_gauge" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_fuel_gauge", Int( self.tank_hud_item[ "sabot_target_range" ].height * 0.6 * 0.0625 ), Int( self.tank_hud_item[ "sabot_target_range" ].height * 0.6 ) );
	self.tank_hud_item[ "sabot_fuel_gauge" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_fuel_gauge" ].alignX = "center";
	self.tank_hud_item[ "sabot_fuel_gauge" ].alignY = "middle";
	self.tank_hud_item[ "sabot_fuel_gauge" ].x = self.tank_hud_item[ "sabot_target_range" ].x + self.tank_hud_item[ "sabot_target_range" ].width * 2;
	self.tank_hud_item[ "sabot_fuel_gauge" ].y = 0;
	self.tank_hud_item[ "sabot_fuel_gauge" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_fuel_range" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_fuel_range", Int( self.tank_hud_item[ "sabot_fuel_gauge" ].height * 0.5 * 0.125 ), Int( self.tank_hud_item[ "sabot_fuel_gauge" ].height * 0.5 ) );
	self.tank_hud_item[ "sabot_fuel_range" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_fuel_range" ].alignX = "center";
	self.tank_hud_item[ "sabot_fuel_range" ].alignY = "middle";
	self.tank_hud_item[ "sabot_fuel_range" ].x = self.tank_hud_item[ "sabot_fuel_gauge" ].x + self.tank_hud_item[ "sabot_fuel_gauge" ].width * 2;
	self.tank_hud_item[ "sabot_fuel_range" ].y = 0;
	self.tank_hud_item[ "sabot_fuel_range" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_ROT" ] = maps\_hud_util::createClientFontString( "default", 1.1 );	
	self.tank_hud_item[ "sabot_ROT" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_ROT" ].alignX = "right";
	self.tank_hud_item[ "sabot_ROT" ].alignY = "middle";
	self.tank_hud_item[ "sabot_ROT" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_ROT" ].x = self.tank_hud_item[ "sabot_target_range" ].x - self.tank_hud_item[ "sabot_target_range" ].width * 0.6;
	self.tank_hud_item[ "sabot_ROT" ].y = 0;
	self.tank_hud_item[ "sabot_ROT" ] SetText( &"SATFARM_RANGE_ON_TARGET" );
	
	self.tank_hud_item[ "sabot_fuel_range_text" ] = maps\_hud_util::createClientFontString( "default", 0.8 );	
	self.tank_hud_item[ "sabot_fuel_range_text" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_fuel_range_text" ].alignX = "left";
	self.tank_hud_item[ "sabot_fuel_range_text" ].alignY = "middle";
	self.tank_hud_item[ "sabot_fuel_range_text" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_fuel_range_text" ].x = self.tank_hud_item[ "sabot_fuel_range" ].x + self.tank_hud_item[ "sabot_fuel_range" ].width;
	self.tank_hud_item[ "sabot_fuel_range_text" ].y = -5;
	self.tank_hud_item[ "sabot_fuel_range_text" ] SetText( &"SATFARM_FUELRANGE" );
	
	self.tank_hud_item[ "sabot_range_highlight" ] = maps\_hud_util::createIcon( "white", Int( self.tank_hud_item[ "sabot_target_range" ].width * 1.25 ), Int( self.tank_hud_item[ "sabot_target_range" ].height * 0.0625 ) );
	self.tank_hud_item[ "sabot_range_highlight" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_range_highlight" ].alignX = "left";
	self.tank_hud_item[ "sabot_range_highlight" ].alignY = "middle";
	self.tank_hud_item[ "sabot_range_highlight" ].x = self.tank_hud_item[ "sabot_target_range" ].x;
	self.tank_hud_item[ "sabot_range_highlight" ].y = 0 + self.tank_hud_item[ "sabot_target_range" ].height * 0.23;
	self.tank_hud_item[ "sabot_range_highlight" ].alpha = 0.0;
	
	self.tank_hud_item[ "sabot_range_1" ] = maps\_hud_util::createClientFontString( "default", 0.8 );	
	self.tank_hud_item[ "sabot_range_1" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_range_1" ].alignX = "left";
	self.tank_hud_item[ "sabot_range_1" ].alignY = "middle";
	self.tank_hud_item[ "sabot_range_1" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_range_1" ].x = self.tank_hud_item[ "sabot_target_range" ].x;
	self.tank_hud_item[ "sabot_range_1" ].y = 0 + self.tank_hud_item[ "sabot_target_range" ].height * 0.23;
	self.tank_hud_item[ "sabot_range_1" ] SetText( &"SATFARM_RANGE_1" );
	
	self.tank_hud_item[ "sabot_range_2" ] = maps\_hud_util::createClientFontString( "default", 0.8 );	
	self.tank_hud_item[ "sabot_range_2" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_range_2" ].alignX = "left";
	self.tank_hud_item[ "sabot_range_2" ].alignY = "middle";
	self.tank_hud_item[ "sabot_range_2" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_range_2" ].x = self.tank_hud_item[ "sabot_target_range" ].x;
	self.tank_hud_item[ "sabot_range_2" ].y = 0 + self.tank_hud_item[ "sabot_target_range" ].height * 0.125;
	self.tank_hud_item[ "sabot_range_2" ] SetText( &"SATFARM_RANGE_2" );
	
	self.tank_hud_item[ "sabot_range_3" ] = maps\_hud_util::createClientFontString( "default", 0.8 );	
	self.tank_hud_item[ "sabot_range_3" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_range_3" ].alignX = "left";
	self.tank_hud_item[ "sabot_range_3" ].alignY = "middle";
	self.tank_hud_item[ "sabot_range_3" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_range_3" ].x = self.tank_hud_item[ "sabot_target_range" ].x;
	self.tank_hud_item[ "sabot_range_3" ].y = 0;
	self.tank_hud_item[ "sabot_range_3" ] SetText( &"SATFARM_RANGE_3" );
	
	self.tank_hud_item[ "sabot_range_4" ] = maps\_hud_util::createClientFontString( "default", 0.8 );	
	self.tank_hud_item[ "sabot_range_4" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_range_4" ].alignX = "left";
	self.tank_hud_item[ "sabot_range_4" ].alignY = "middle";
	self.tank_hud_item[ "sabot_range_4" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_range_4" ].x = self.tank_hud_item[ "sabot_target_range" ].x;
	self.tank_hud_item[ "sabot_range_4" ].y = 0 - self.tank_hud_item[ "sabot_target_range" ].height * 0.125;
	self.tank_hud_item[ "sabot_range_4" ] SetText( &"SATFARM_RANGE_4" );
	
	self.tank_hud_item[ "sabot_range_5" ] = maps\_hud_util::createClientFontString( "default", 0.8 );	
	self.tank_hud_item[ "sabot_range_5" ] set_default_hud_parameters();
	self.tank_hud_item[ "sabot_range_5" ].alignX = "left";
	self.tank_hud_item[ "sabot_range_5" ].alignY = "middle";
	self.tank_hud_item[ "sabot_range_5" ].alpha = 0.0;
	self.tank_hud_item[ "sabot_range_5" ].x = self.tank_hud_item[ "sabot_target_range" ].x;
	self.tank_hud_item[ "sabot_range_5" ].y = 0 - self.tank_hud_item[ "sabot_target_range" ].height * 0.23;
	self.tank_hud_item[ "sabot_range_5" ] SetText( &"SATFARM_RANGE_5" );
	
	self thread tank_update_primary_reticle();
	self thread tank_update_speed( tank, max_speed );
	self thread tank_compass( tank );
	self thread tank_compass_vehicle_positions( tank );
	self thread tank_compass_objective_positions( tank );
	self thread tank_update_weapon_hud( tank );
	thread hide_normal_hud_elements();
//	self thread tank_compass_scanline( tank );
}

hide_normal_hud_elements()
{
	SetSavedDvar( "compass", "0" );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
}

show_normal_hud_elements()
{
	SetSavedDvar( "compass", "1" );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
}

tank_clear_hud()
{
	level notify( "clear_tank_hud" );
	
	keys = getArrayKeys( self.tank_hud_item );
	foreach ( key in keys )
	{
		self.tank_hud_item[ key ] Destroy();
		self.tank_hud_item[ key ] = undefined;
	}
	
	foreach ( vehicle in getVehicleArray() )
	{
		if ( IsDefined( vehicle.hud_compass_elem ) )
		{
			vehicle.hud_compass_elem Destroy();
			vehicle.hud_compass_elem = undefined;
		}
	}
	
	foreach ( objective in level.compass_objectives )
	{
		if ( IsDefined( objective.hud_compass_elem ) )
		{
			objective.hud_compass_elem Destroy();
			objective.hud_compass_elem = undefined;
		}
	}
	
	thread show_normal_hud_elements();
}

tank_hud_offline( weap_name )
{
	level endon( "clear_tank_hud" );
	
	if ( IsDefined( self.tank_hud_item[ weap_name + "_status" ] ) )
	{
		self.tank_hud_item[ weap_name + "_status" ].alpha = 0;
		self.tank_hud_item[ weap_name + "_status" ].offline = true;
	}
	
	self.tank_hud_item[ weap_name + "_name" ].alpha = 0.25;
	self.tank_hud_item[ weap_name + "_state" ].alpha = 0.25;
	self.tank_hud_item[ weap_name + "_state" ] SetShader( "white", self.tank_hud_item[ weap_name + "_state" ].width, self.tank_hud_item[ weap_name + "_state" ].height );
	
	while ( 1 )
	{
		self.tank_hud_item[ weap_name + "_offline" ] FadeOverTime( 0.25 );
		self.tank_hud_item[ weap_name + "_offline" ].alpha = 1;
		
		wait 0.4;
		
		self.tank_hud_item[ weap_name + "_offline" ] FadeOverTime( 0.25 );
		self.tank_hud_item[ weap_name + "_offline" ].alpha = 0;
		
		wait 0.25;
		
		if ( self.tank_hud_item[ weap_name + "_offline" ].color == ( 1, 1, 1 ) )
		{
			self.tank_hud_item[ weap_name + "_offline" ].color = ( 1, 0, 0 );
		}
		else
		{
			self.tank_hud_item[ weap_name + "_offline" ].color = ( 1, 1, 1 );
		}
	}
}

tank_update_primary_reticle()
{
	level endon( "clear_tank_hud" );
	
	while ( 1 )
	{
		if ( self.tank_hud_item[ "current_weapon" ].weap == "turret" )
		{
			trace = BulletTrace( self GetEye(), self GetEye() + AnglesToForward( self GetPlayerAngles() ) * 36000, true, self );
			
			if ( IsDefined( trace[ "entity" ] ) && ( ( IsDefined( trace[ "entity" ].script_team ) && trace[ "entity" ].script_team == "axis" ) || ( IsDefined( trace[ "entity" ].red_crosshair ) && trace[ "entity" ].red_crosshair ) ) )
			{
				self.tank_hud_item[ "reticle_center_red" ].alpha = 0.66;
				self.tank_hud_item[ "reticle_cross_red" ].alpha = 0.66;
				self.tank_hud_item[ "reticle_center" ].alpha = 0.0;
				self.tank_hud_item[ "reticle_cross" ].alpha = 0.0;
			}
			else
			{
				self.tank_hud_item[ "reticle_center" ].alpha = 0.66;
				self.tank_hud_item[ "reticle_cross" ].alpha = 0.66;
				self.tank_hud_item[ "reticle_center_red" ].alpha = 0.0;
				self.tank_hud_item[ "reticle_cross_red" ].alpha = 0.0;
			}
		}
		
		wait 0.05;
	}
}

tank_update_speed( tank, max_speed )
{
	level endon( "clear_tank_hud" );
	
	bar_width = self.tank_hud_item[ "speed_bar" ].width;
	bar_alpha = self.tank_hud_item[ "speed_bar" ].alpha;
	
	while ( 1 )
	{
		self.tank_hud_item[ "speed_label" ] SetText( Int( tank Vehicle_GetSpeed() ) );
		
		new_width = Int( Int( tank Vehicle_GetSpeed() ) / max_speed * bar_width );
		if ( new_width == 0 )
		{
			self.tank_hud_item[ "speed_bar" ].alpha = 0.0;
		}
		else
		{
			self.tank_hud_item[ "speed_bar" ].alpha = bar_alpha;
			self.tank_hud_item[ "speed_bar" ] SetShader( "green_block", new_width, self.tank_hud_item[ "speed_bar" ].height );
		}
		
		wait 0.05;
	}
}

add_ent_objective_to_compass( ent, wait_flag )
{
	if( IsDefined( wait_flag ) )
		flag_wait( wait_flag );
	
	if( !IsDefined( ent ) )
		return;
	
	if ( !IsDefined( level.compass_objectives ) )
	{
		level.compass_objectives = [];
	}
	
	level.compass_objectives = array_add( level.compass_objectives, ent );
}

remove_ent_objective_from_compass( ent )
{
	if ( IsDefined( level.compass_objectives ) )
	{
		level.compass_objectives = array_remove( level.compass_objectives, ent );
		
		if ( IsDefined( ent.hud_compass_elem ) )
		{
			ent.hud_compass_elem Destroy();
			ent.hud_compass_elem = undefined;
		}
	}
}

tank_watch_for_vehicle_death()
{
	level endon( "clear_tank_hud" );
	
	self waittill( "death" );
	
	self.dead = true;
	
	if ( IsDefined( self.hud_compass_elem ) )
	{
		self.hud_compass_elem notify( "stop_pulse" );
		self.hud_compass_elem Destroy();
		self.hud_compass_elem = undefined;
	}
	
	if ( Target_IsTarget( self ) )
	{
		Target_Remove( self );
}
}

tank_compass( tank )
{
	level endon( "clear_tank_hud" );
	
	default_compass_tickmark_increments_angle = 10;
	default_compass_tickmark_label_angle = 45;
	angleRange = 360;

	x = -200;
	y = 0;
	width = 400;
	height = 30;
	alpha = 0.8;

	numTickMarks = Int( angleRange / default_compass_tickmark_increments_angle );
	tickMarkSpacing = width / numTickMarks;
	
	for ( i = 0; i < numTickMarks; i++ )
	{
		self.tank_hud_item[ "compass_tick_mark_" + i ] = maps\_hud_util::createIcon( "white", 1, 1 );
		self.tank_hud_item[ "compass_tick_mark_" + i ] set_default_hud_parameters();
		self.tank_hud_item[ "compass_tick_mark_" + i ].alignX = "center";
		self.tank_hud_item[ "compass_tick_mark_" + i ].alignY = "top";
		self.tank_hud_item[ "compass_tick_mark_" + i ].vertAlign = "top";
		self.tank_hud_item[ "compass_tick_mark_" + i ].x = 0;
		self.tank_hud_item[ "compass_tick_mark_" + i ].y = 0;
		self.tank_hud_item[ "compass_tick_mark_" + i ].alpha = alpha;
	}
	
	for ( i = 0; i < Int( angleRange / default_compass_tickmark_label_angle ); i++ )
	{
		self.tank_hud_item[ "compass_label_mark_" + i ] = maps\_hud_util::createClientFontString( "default", 1.0 );
		self.tank_hud_item[ "compass_label_mark_" + i ] set_default_hud_parameters();
		self.tank_hud_item[ "compass_label_mark_" + i ].alignX = "center";
		self.tank_hud_item[ "compass_label_mark_" + i ].alignY = "top";
		self.tank_hud_item[ "compass_label_mark_" + i ].vertAlign = "top";
		self.tank_hud_item[ "compass_label_mark_" + i ].alpha = alpha;
		self.tank_hud_item[ "compass_label_mark_" + i ].x = 0;
		self.tank_hud_item[ "compass_label_mark_" + i ].y = 0;
	}
	
	while ( 1 )
	{
		if ( self.tank_hud_item[ "current_weapon" ].weap != "turret" )
		{
			for ( i = 0; i < numTickMarks; i++ )
			{	
				self.tank_hud_item[ "compass_tick_mark_" + i ].alpha = 0;
			}
			
			for ( i = 0; i < Int( angleRange / default_compass_tickmark_label_angle ); i++ )
			{
				self.tank_hud_item[ "compass_label_mark_" + i ].alpha = 0;
			}
			
			self waittill( "cycle_weapon" );
		}
		
		tapeRotation = self GetPlayerAngles()[ 1 ] - GetNorthYaw();
		tickMarkStartX = x + ( 1.0 - ( modulus( abs( tapeRotation ), default_compass_tickmark_increments_angle ) / default_compass_tickmark_increments_angle ) ) * tickMarkSpacing;
	
		curAngle = Int( ( tapeRotation / default_compass_tickmark_increments_angle ) - ( numTickMarks / 2 ) ) * default_compass_tickmark_increments_angle;
		
		cur_label_index = 0;
	
		for ( i = 0; i < numTickMarks; i++ )
		{
			curAngle += default_compass_tickmark_increments_angle;
			
			tempHeight = max( 0.15, pow( ter_op( i < numTickMarks / 2, i, numTickMarks - i ) / ( numTickMarks / 2 ), 1.1 ) ) * height * 0.5;

			self.tank_hud_item[ "compass_tick_mark_" + i ].x = tickMarkStartX + ( i * tickMarkSpacing );
			self.tank_hud_item[ "compass_tick_mark_" + i ].y = y + ( tempHeight - ( height * 0.15 * 0.5 ) ) * 0.75;
			self.tank_hud_item[ "compass_tick_mark_" + i ].height = Int( tempHeight );
	
			if ( modulus( curAngle, default_compass_tickmark_label_angle ) == 0 )
			{
				if ( curAngle >= 360 )
				{
					curAngle -= 360;
				}
				else if ( curAngle < 0 )
				{
					curAngle += 360;
				}
	
				if ( curAngle == 0 )
				{
					angleString = "00";
				}
				else
				{
					angleString = "" + curAngle;
				}
	
				
				self.tank_hud_item[ "compass_tick_mark_" + i ].width = 2;
				self.tank_hud_item[ "compass_tick_mark_" + i ].alpha = tempHeight / ( height * 0.5 );
				
				self.tank_hud_item[ "compass_label_mark_" + cur_label_index ].x = tickMarkStartX + ( i * tickMarkSpacing );
				self.tank_hud_item[ "compass_label_mark_" + cur_label_index ].y = y + height;
				self.tank_hud_item[ "compass_label_mark_" + cur_label_index ].alpha = tempHeight / ( height * 0.5 );
				self.tank_hud_item[ "compass_label_mark_" + cur_label_index ] SetText( angleString );
				
				cur_label_index++;
			}
			else
			{
				self.tank_hud_item[ "compass_tick_mark_" + i ].width = 1;
				self.tank_hud_item[ "compass_tick_mark_" + i ].alpha = max( 0.15, ( alpha / 4.0 ) * ( tempHeight / ( height * 0.5 ) ) );
			}
			
			self.tank_hud_item[ "compass_tick_mark_" + i ] SetShader( "white", self.tank_hud_item[ "compass_tick_mark_" + i ].width, self.tank_hud_item[ "compass_tick_mark_" + i ].height );
		}
		
		wait 0.05;
	}
}

tank_compass_vehicle_positions( tank )
{
	level endon( "clear_tank_hud" );
	
	pulse = false;
	
	while ( 1 )
	{
		foreach ( vehicle in getVehicleArray() )
		{
			if ( vehicle.script_team == "axis" && vehicle isTank() && ( !IsDefined( vehicle.dead ) || !vehicle.dead ) )
			{
				if ( !IsDefined( vehicle.hud_compass_elem ) )
				{
					vehicle.hud_compass_elem = maps\_hud_util::createIcon( "m1a1_compass_enemy", 16, 16 );
					vehicle.hud_compass_elem set_default_hud_parameters();
					vehicle.hud_compass_elem.alignX = "center";
					vehicle.hud_compass_elem.alignY = "middle";
					vehicle.hud_compass_elem.vertAlign = "top";
					vehicle.hud_compass_elem.x = 0;
					vehicle.hud_compass_elem.y = 0;
					vehicle.hud_compass_elem.alpha = 0.0;
					vehicle.hud_compass_elem.visible = false;
					
					if ( pulse && IsDefined( vehicle.compass_flash ) && vehicle.compass_flash )
					{
						vehicle.hud_compass_elem thread tank_compass_pulse( 4, 2 );
					}
					
					if ( !Target_IsTarget( vehicle ) )
					{
						Target_Set( vehicle );
						Target_HideFromPlayer( vehicle, level.player );
					}
					
					vehicle thread tank_watch_for_vehicle_death();
				}
				
				if ( level.player.tank_hud_item[ "current_weapon" ].weap != "turret" )
				{
					vehicle.hud_compass_elem notify( "stop_pulse" );
					vehicle.hud_compass_elem.pulsing = false;
					vehicle.hud_compass_elem.alpha = 0;
					
					continue;
				}

				dist = Distance2D( level.player.origin, vehicle.origin );
				
				if ( dist < 36000 )
				{				
					yaw = VectorToYaw( vehicle.origin - level.player.origin );
					yawDiff = AngleClamp180( yaw - level.player GetPlayerAngles()[ 1 ] );
					
					vehicle.hud_compass_elem.x = -200 * yawDiff / 180;
					vehicle.hud_compass_elem.y = pow( 1.0 - ( abs( yawDiff ) / 180.0 ), 1.1 ) * 15;
					if ( !IsDefined( vehicle.hud_compass_elem.pulsing ) || !vehicle.hud_compass_elem.pulsing )
					{
						vehicle.hud_compass_elem.alpha = 0.9;
						vehicle.hud_compass_elem.visible = true;
						size = Int( ( 1 - ( dist / 36000 ) ) * 16 );
						vehicle.hud_compass_elem SetShader( "m1a1_compass_enemy", size, size );
					}
				}
				else if ( !IsDefined( vehicle.hud_compass_elem.pulsing ) || !vehicle.hud_compass_elem.pulsing )
				{
					vehicle.hud_compass_elem.alpha = 0.0;
					vehicle.hud_compass_elem.visible = false;
				}
			}
		}
		
		pulse = true;
		
		if ( level.player.tank_hud_item[ "current_weapon" ].weap != "turret" )
		{
			level.player waittill( "cycle_weapon" );
		}
		
		wait 0.05;
	}
}

tank_compass_objective_positions( tank )
{
	level endon( "clear_tank_hud" );
	
	if ( !IsDefined( level.compass_objectives ) )
	{
		level.compass_objectives = [];
	}
	
	pulse = false;
	
	while ( 1 )
	{
		foreach ( objective in level.compass_objectives )
		{
			if ( !IsDefined( objective.hud_compass_elem ) )
			{
				objective.hud_compass_elem = maps\_hud_util::createIcon( "m1a1_compass_objective", 24, 24 );
				objective.hud_compass_elem set_default_hud_parameters();
				objective.hud_compass_elem.alignX = "center";
				objective.hud_compass_elem.alignY = "middle";
				objective.hud_compass_elem.vertAlign = "top";
				objective.hud_compass_elem.x = 0;
				objective.hud_compass_elem.y = 0;
				objective.hud_compass_elem.alpha = 0.0;
				objective.hud_compass_elem.sort += 1;
				objective.hud_compass_elem.visible = false;
				
				if ( pulse )
				{
					objective.hud_compass_elem thread tank_compass_pulse( 4, 2 );
				}
			}
				
			if ( level.player.tank_hud_item[ "current_weapon" ].weap != "turret" )
			{
				objective.hud_compass_elem notify( "stop_pulse" );
				objective.hud_compass_elem.pulsing = false;
				objective.hud_compass_elem.alpha = 0;
				
				continue;
			}

			dist = Distance2D( level.player.origin, objective.origin );
			
			if ( dist < 36000 )
			{				
				yaw = VectorToYaw( objective.origin - level.player.origin );
				yawDiff = AngleClamp180( yaw - level.player GetPlayerAngles()[ 1 ] );
				
				objective.hud_compass_elem.x = -200 * yawDiff / 180;
				objective.hud_compass_elem.y = pow( 1.0 - ( abs( yawDiff ) / 180.0 ), 1.1 ) * 15;
				if ( !IsDefined( objective.hud_compass_elem.pulsing ) || !objective.hud_compass_elem.pulsing )
				{
					objective.hud_compass_elem.alpha = 0.9;
					objective.hud_compass_elem.visible = true;
					size = Int( Max( ( 1 - ( dist / 36000 ) ) * 24, 12 ) );
					objective.hud_compass_elem SetShader( "m1a1_compass_objective", size, size );
				}
			}
			else if ( !IsDefined( objective.hud_compass_elem.pulsing ) || !objective.hud_compass_elem.pulsing )
			{
				objective.hud_compass_elem.alpha = 0.0;
				objective.hud_compass_elem.visible = false;
			}
		}
		
		pulse = true;
		
		if ( level.player.tank_hud_item[ "current_weapon" ].weap != "turret" )
		{
			level.player waittill( "cycle_weapon" );
		}
		
		wait 0.05;
	}
}

tank_compass_pulse( num_blinks, time )
{
	level endon( "clear_tank_hud" );
	self endon( "stop_pulse" );
	
	self.pulsing = true;
	
	pulse_time = time / ( num_blinks * 2 );
	
	max_size = self.width;
	min_size = Int( max_size / 2 );
	
	for ( i = 0; i < num_blinks; i++ )
	{
		self ScaleOverTime( pulse_time, min_size, min_size );
		self FadeOverTime( pulse_time );
		self.alpha = 0.0;
		
		wait pulse_time;
		
		self ScaleOverTime( pulse_time, max_size, max_size );
		self FadeOverTime( pulse_time );
		self.alpha = 0.9;
		
		wait pulse_time;
	}
	
	self.pulsing = false;
}

tank_compass_scanline( tank )
{
	level endon( "clear_tank_hud" );
	
	self.tank_hud_item[ "compass_scanline" ] = maps\_hud_util::createIcon( "m1a1_compass_scanline", 18, 72 );
	self.tank_hud_item[ "compass_scanline" ] set_default_hud_parameters();
	self.tank_hud_item[ "compass_scanline" ].alignX = "center";
	self.tank_hud_item[ "compass_scanline" ].alignY = "top";
	self.tank_hud_item[ "compass_scanline" ].vertAlign = "top";
	self.tank_hud_item[ "compass_scanline" ].x = 200;
	self.tank_hud_item[ "compass_scanline" ].y = -15;
	self.tank_hud_item[ "compass_scanline" ].alpha = 1.0;
	
	pause_scan_time = 0.0;
	
	while ( 1 )
	{
		foreach ( vehicle in getVehicleArray() )
		{
			if ( vehicle.script_team == "axis" )
			{
				if ( IsDefined( vehicle.hud_compass_elem ) && IsDefined( vehicle.hud_compass_elem.visible ) && vehicle.hud_compass_elem.visible )
				{
					vehicle.hud_compass_elem FadeOverTime( 0.05 );
					vehicle.hud_compass_elem.alpha *= 0.95;
				}
			}
		}
		
		if ( pause_scan_time > 0.0 )
		{
			pause_scan_time -= 0.05;
			wait 0.05;
			continue;
		}
		
		scanline_max_angle = AngleClamp180( ( self.tank_hud_item[ "compass_scanline" ].x / 200.0 * 180.0 ) + 5 );
		
		new_x_pos = self.tank_hud_item[ "compass_scanline" ].x - 15;
		if ( new_x_pos < -220 )
		{
			self.tank_hud_item[ "compass_scanline" ].x = 200;
			self.tank_hud_item[ "compass_scanline" ].alpha = 0.0;
			pause_scan_time = 1;
		}
		else
		{
			self.tank_hud_item[ "compass_scanline" ] MoveOverTime( 0.05 );
			self.tank_hud_item[ "compass_scanline" ].x = new_x_pos;
			self.tank_hud_item[ "compass_scanline" ].alpha = 1.0;
		}
		
		scanline_min_angle = AngleClamp180( ( new_x_pos / 200.0 * 180.0 ) - 5 );
		
		foreach ( vehicle in getVehicleArray() )
		{
			if ( IsDefined( vehicle.hud_compass_elem ) && IsDefined( vehicle.hud_compass_elem.visible ) && vehicle.hud_compass_elem.visible )
			{
				angle_to_vehicle = VectorToYaw( vehicle.origin - self GetEye() );
				angle_diff = AngleClamp180( self GetPlayerAngles()[ 1 ] - angle_to_vehicle );
				
				if ( scanline_max_angle < scanline_min_angle )
				{
					if ( angle_diff < scanline_max_angle )
					{
						vehicle.hud_compass_elem.alpha = 1.0;
					}
				}
				else if ( angle_diff < scanline_max_angle && angle_diff > scanline_min_angle )
				{
					vehicle.hud_compass_elem.alpha = 1.0;
				}
			}
		}
		
		wait 0.05;
	}
}

tank_update_weapon_hud( tank )
{
	level endon( "clear_tank_hud" );

	reticle_alpha = self.tank_hud_item[ "reticle" ].alpha;
	
	while ( !flag( "tow_out" ) )
	{
		self waittill( "cycle_weapon" );
		
		self.tank_hud_item[ "reticle" ].alpha = 0.0;
		self.tank_hud_item[ "reticle_center" ].alpha = 0.0;
		self.tank_hud_item[ "reticle_center_red" ].alpha = 0.0;
		self.tank_hud_item[ "reticle_cross" ].alpha = 0.0;
		self.tank_hud_item[ "reticle_cross_red" ].alpha = 0.0;
		self.tank_hud_item[ "compass_heading" ].alpha = 0.0;
		self.tank_hud_item[ "current_weapon" ].x = 200;
		self.tank_hud_item[ "current_weapon" ].weap = "missile";
		
		update_weapon_status( "turret", "IDLE" );
		update_weapon_status( "missile", "READY" );
		
		self.tank_hud_item[ "sabot_overlay" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_vignette" ].alpha = 0.9;
		self.tank_hud_item[ "sabot_reticle" ].alpha = 0.666;
//		self.tank_hud_item[ "sabot_reticle_red" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_reticle_upper_left" ].alpha = 0.666;
//		self.tank_hud_item[ "sabot_reticle_upper_left_red" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_reticle_upper_right" ].alpha = 0.666;
//		self.tank_hud_item[ "sabot_reticle_upper_right_red" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_reticle_bottom_left" ].alpha = 0.666;
//		self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_reticle_bottom_right" ].alpha = 0.666;
//		self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_reticle_outer_left" ].alpha = 0.666;
//		self.tank_hud_item[ "sabot_reticle_outer_left_red" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_reticle_outer_right" ].alpha = 0.666;
//		self.tank_hud_item[ "sabot_reticle_outer_right_red" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_target_range" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_fuel_gauge" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_fuel_range" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_ROT" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_fuel_range_text" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_range_1" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_range_2" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_range_3" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_range_4" ].alpha = 0.666;
		self.tank_hud_item[ "sabot_range_5" ].alpha = 0.666;
		
		flag_clear( "ZOOM_ON" );
		self AllowAds( false );
		SetSavedDvar( "cg_fov", 20 );
		
		self thread tank_missile_targeting();
		
		self waittill( "cycle_weapon" );
		
		SetSavedDvar( "cg_fov", 65 );
		self AllowAds( true );

		self.tank_hud_item[ "reticle" ].alpha = reticle_alpha;
		self.tank_hud_item[ "reticle_center" ].alpha = reticle_alpha;
		self.tank_hud_item[ "reticle_cross" ].alpha = reticle_alpha;
		self.tank_hud_item[ "compass_heading" ].alpha = 0.9;
		self.tank_hud_item[ "current_weapon" ].x = 110;
		self.tank_hud_item[ "current_weapon" ].weap = "turret";
		
		update_weapon_status( "missile", "IDLE" );
		update_weapon_status( "turret", "READY" );		
		
		self.tank_hud_item[ "sabot_overlay" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_vignette" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_red" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_upper_left" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_upper_left_red" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_upper_right" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_upper_right_red" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_bottom_left" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_bottom_right" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_outer_left" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_outer_left_red" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_outer_right" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_reticle_outer_right_red" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_target_range" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_fuel_gauge" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_fuel_range" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_ROT" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_fuel_range_text" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_range_1" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_range_2" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_range_3" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_range_4" ].alpha = 0.0;
		self.tank_hud_item[ "sabot_range_5" ].alpha = 0.0;
	}
}

update_weapon_status( weap, status )
{
	if ( level.player.tank_hud_item[ "current_weapon" ].weap != weap )
	{
		level.player.tank_hud_item[ weap + "_name" ].alpha = 0.25;
		level.player.tank_hud_item[ weap + "_status" ].alpha = 0.25;
	}
	else
	{
		level.player.tank_hud_item[ weap + "_name" ].alpha = 0.9;
		level.player.tank_hud_item[ weap + "_status" ].alpha = 0.9;
	}
	
	if ( !IsDefined( level.player.tank_hud_item[ weap + "_status" ].loading ) || !level.player.tank_hud_item[ weap + "_status" ].loading )
	{
		if ( status == "READY" && level.player.tank_hud_item[ "current_weapon" ].weap != weap )
		{
			level.player.tank_hud_item[ weap + "_status" ] SetText( "IDLE" );
		}
		else
	{
			level.player.tank_hud_item[ weap + "_status" ] SetText( status );
		}
	}
}

update_weapon_state( time )
{
	level endon( "clear_tank_hud" );
	
	curTime = 0;
	full_width = self.width;
	
	while ( curTime < time )
	{
		self SetShader( "red_block", Int( Max( curTime / time * full_width, 1 ) ), self.height );
		wait 0.05;
		curTime += 0.05;
	}
	
	self SetShader( "green_block", full_width, self.height );
}

tank_missile_targeting()
{
	level endon( "clear_tank_hud" );
	self endon( "cycle_weapon" );
	
	mph_to_ips = 63360 / 3600;

	while ( 1 )
	{
		target_in_sights = undefined;
		
		foreach ( vehicle in getVehicleArray() )
		{
			if ( vehicle.script_team == "axis" && vehicle isTank() && ( !IsDefined( vehicle.dead ) || !vehicle.dead ) )
			{
				if ( !Target_IsTarget( vehicle ) )
				{
					Target_Set( vehicle );
					Target_HideFromPlayer( vehicle, level.player );
				}
				
				if ( Target_IsInRect( vehicle, self, GetDvarFloat( "cg_fov" ), self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].x, self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].y ) && SightTracePassed( self GetEye(), vehicle.origin, false, vehicle, level.playertank ) )
				{
					target_in_sights = vehicle;
					break;
				}
			}
		}
		
		if ( IsDefined( target_in_sights ) )
		{
			if ( self.tank_hud_item[ "sabot_reticle_red" ].alpha == 0.0 )
			{
				self.tank_hud_item[ "sabot_reticle_red" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_upper_left_red" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_upper_right_red" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_range_highlight" ].alpha = 0.66;
				
				self.tank_hud_item[ "sabot_reticle" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_upper_left" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_upper_right" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_bottom_left" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_bottom_right" ].alpha = 0.0;
			}
				
			dist = Distance( target_in_sights.origin, self.origin );
			if ( dist <= 200 * mph_to_ips )
			{
				self.tank_hud_item[ "sabot_range_highlight" ].y = self.tank_hud_item[ "sabot_range_1" ].y;
			}
			else if ( dist <= 400 * mph_to_ips )
			{
				self.tank_hud_item[ "sabot_range_highlight" ].y = self.tank_hud_item[ "sabot_range_2" ].y;
			}
			else if ( dist <= 600 * mph_to_ips )
			{
				self.tank_hud_item[ "sabot_range_highlight" ].y = self.tank_hud_item[ "sabot_range_3" ].y;
			}
			else if ( dist <= 800 * mph_to_ips )
			{
				self.tank_hud_item[ "sabot_range_highlight" ].y = self.tank_hud_item[ "sabot_range_4" ].y;
			}
			else
			{
				self.tank_hud_item[ "sabot_range_highlight" ].y = self.tank_hud_item[ "sabot_range_5" ].y;
			}
		}
		else
		{
			if ( self.tank_hud_item[ "sabot_reticle" ].alpha == 0.0 )
			{
				self.tank_hud_item[ "sabot_reticle" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_upper_left" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_upper_right" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_bottom_left" ].alpha = 0.66;
				self.tank_hud_item[ "sabot_reticle_bottom_right" ].alpha = 0.66;
				
				self.tank_hud_item[ "sabot_reticle_red" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_upper_left_red" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_upper_right_red" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_bottom_left_red" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_reticle_bottom_right_red" ].alpha = 0.0;
				self.tank_hud_item[ "sabot_range_highlight" ].alpha = 0.0;
			}
		}
		
		wait 0.05;
	}
}

static_on( duration, alpha, fade_in_time, fade_out_time )
{
	black = newClientHudElem( self );
	black.x = 0;
	black.y = 0;
	black.alignX = "left";
	black.alignY = "top";
	black.horzAlign = "fullscreen";
	black.vertAlign = "fullscreen";
	black.sort = 200;
	black setshader( "black", 640, 480 );
	
	static = newClientHudElem( self );
	static.x = 0;
	static.y = 0;
	static.alignX = "left";
	static.alignY = "top";
	static.horzAlign = "fullscreen";
	static.vertAlign = "fullscreen";
	static.sort = black.sort + 1;
	static setshader( "overlay_static", 640, 480 );
	
	if ( IsDefined( fade_in_time ) )
	{
		static.alpha = 0.0;
		static FadeOverTime( fade_in_time );
		static.alpha = alpha;
		
		black.alpha = 0.0;
		black FadeOverTime( fade_in_time );
		black.alpha = alpha;
		
		wait fade_in_time;
	}
	else
	{
		static.alpha = alpha;
		black.alpha = alpha;
	}
	
	wait duration;
	
	if ( IsDefined( fade_out_time ) )
	{
		static FadeOverTime( fade_out_time );
		static.alpha = 0.0;
		
		black FadeOverTime( fade_out_time );
		black.alpha = 0.0;
		
		wait fade_out_time;
	}
	
	static Destroy();
	black Destroy();
}

set_default_hud_parameters()
{
	self.alignx = "left";
	self.aligny = "top";
	self.horzAlign = "center";
	self.vertAlign = "middle";
	self.hidewhendead = false;
	self.hidewheninmenu = false;
	self.sort = 205;
	self.foreground = true;
	self.alpha = 0.65;
}

modulus( dividend, divisor )
{
	q = Int( dividend / divisor );
	return dividend - ( q * divisor );
}

/*** Tank Fire Controls ***/

on_fire_main_cannon()
{
	tank = self;
	
	tank endon( "death" );
	level.player endon( "death" );
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	level.player NotifyOnPlayerCommand( "BUTTON_FIRE_CANNON", "+attack" );
	
	while ( !flag( "all_guns_out" ) )
	{
		level.player waittill( "BUTTON_FIRE_CANNON" );
		
		if ( !tank IsTurretReady() )
			continue;
		
		level.isFiring = true;

		if ( IsDefined( level.player.tank_hud_item[ "current_weapon" ] ) && level.player.tank_hud_item[ "current_weapon" ].weap == "turret" )
		{
			tank shoot_anim();
			level.player thread play_fire_bcs();
			level.player playsound ("m1a1_abrams_antitank_fire_plr");
			thread maps\satfarm_audio::reload();
			
			
			if( isdefined( level.player.tank_hud_item[ "turret_status" ] ) )
			{
				level.player.tank_hud_item[ "turret_state" ] thread update_weapon_state( 2.0 );
				update_weapon_status( "turret", "LOADING" );
				level.player.tank_hud_item[ "turret_status" ].loading = true;
			}
		
			// Play tank reload sounds
			// Controlled in the GDT: m1a1_turret_player_drivable_relative
			//tank.ent_sound PlaySound( "m1a1_reload", "reload_sound_finished" );
			//tank.ent_sound waittill( "reload_sound_finished" );
			wait 2;
			
			level.player thread play_reload_bcs();
			
			if( isdefined( level.player.tank_hud_item[ "turret_status" ] ) )
			{
				level.player.tank_hud_item[ "turret_status" ].loading = false;
				update_weapon_status( "turret", "READY" );
			}
		}
		else
		{
			tank shoot_anim();
			level.player thread play_fire_bcs();
			level.player playsound ("m1a1_abrams_antitank_fire_plr");
			thread maps\satfarm_audio::reload();
			
			wait 2;
			
			level.player thread play_reload_bcs();
		}
	}
	
	
	if( isdefined( level.player.tank_hud_item[ "turret_status" ] ) )
		level.player.tank_hud_item[ "turret_status" ] SetText( "OFFLINE" );
}

play_fire_bcs()
{
	event = createEvent( "inform_firing", "inform_firing" );	
	self thread play_chatter( event );
}

play_reload_bcs()
{
	event = createEvent( "inform_loaded", "inform_loaded" );	
	self thread play_chatter( event );
}

//*** MG Gun Fire ***//

on_fire_mg()
{
	tank = self;
	
	tank endon( "death" );
	level.player endon( "death" );
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	level.player NotifyOnPlayerCommand( "BUTTON_FIRE_MG", "+frag" );
	level.player NotifyOnPlayerCommand( "BUTTON_STOP_MG", "-frag" );
	
	if( IsDefined( tank.mgturret ) )
	{
		tank.mgturret[0] TurretFireDisable();
		
		tank thread handle_mg_firing();
		
		while ( 1 )
		{
			level.player waittill( "BUTTON_FIRE_MG" );
			
			flag_set( "MG_FIRE" );
			
			level.player waittill( "BUTTON_STOP_MG" );
				
			flag_clear( "MG_FIRE" );
		}
	}
}

handle_mg_firing()
{
	tank = self;
	
	tank endon( "death" );
	level.player endon( "death" );
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	wait_between_rounds = WeaponFireTime( "minigun_m1a1" );
	firetime = gettime() - wait_between_rounds;
	
	while( 1 )
	{
		if( flag( "MG_FIRE" ) && firetime < gettime() )
		{
			source_pos 		= tank GetTagOrigin( "tag_coax_mg" );
			player_angles 	= level.player GetPlayerAngles();
			forward_vec 	= AnglesToForward( 	player_angles );
			to_right 		= AnglesToRight( 	player_angles );
			
			mg_loc = self.mgturret[0] GetTagOrigin( "tag_flash" );
			
			trace = BulletTrace( level.player GetEye(), level.player GetEye() + ( forward_vec * 12 * 2000 ), true, level.player );
			
			target_pos = trace[ "position" ];
			
			bullet = magicbullet( "minigun_m1a1", mg_loc + ( forward_vec * 32 ), target_pos, level.player );
			level.player PlaySound( "satfarm_turret_temp_plr" );
			playfxontag( getfx( "grenade_muzzleflash" ), self.mgturret[0], "tag_flash"  );
			level.player playrumbleonentity( "minigun_rumble" );
			
			firetime = gettime() + wait_between_rounds * 1000; // level.speedfast determines how quickly the gun will fire
		}
		
		wait .05;
	}
}

//*** Smoke fire ***//

on_pop_smoke()
{
	tank = self;
	
	tank endon( "death" );
	level.player endon( "death" );
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	level.player NotifyOnPlayerCommand( "BUTTON_POP_SMOKE", "+smoke" );
	
	while ( !flag( "smoke_out" ) )
	{
		level.player waittill( "BUTTON_POP_SMOKE" );
		
		flag_set( "POPPED_SMOKE" );
		
		player_angles 	= level.player GetPlayerAngles();
		forward_vec 	= AnglesToForward( 	player_angles );
		to_right 		= AnglesToRight( 	player_angles );
		
		trace = BulletTrace( level.player GetEye(), level.player GetEye() + ( forward_vec * 12 * 300 ), true, level.player );
			
		target_pos = trace[ "position" ];
		
		tank launch_smoke( target_pos );
		
		if( isdefined( level.player.tank_hud_item[ "smoke_status" ] ) )
			pop_smoke_hud();
		
		flag_clear( "POPPED_SMOKE" );
	}
	
	if( isdefined( level.player.tank_hud_item[ "smoke_status" ] ) )
	{
    	level.player.tank_hud_item[ "smoke_status" 		] SetText( "OFFLINE" );
		level.player.tank_hud_item[ "smoke_status" 		].alpha = 0.0;
		level.player.tank_hud_item[ "smoke_name" 		].alpha = 0.0;
		level.player.tank_hud_item[ "smoke_state_bg" 	].alpha = 0.0;
		level.player.tank_hud_item[ "smoke_state" 		].alpha = 0.0;
	}
}

pop_smoke_hud()
{
	level.player.tank_hud_item[ "smoke_state" ] thread update_weapon_state( 6.0 );
	level.player.tank_hud_item[ "smoke_status" ] SetText( "LOADING" );

	wait 6;
	
	if( isdefined( level.player.tank_hud_item[ "smoke_status" ] ) )
		level.player.tank_hud_item[ "smoke_status" ] SetText( "READY" );
}

launch_smoke( destination )
{
	self thread smoke_launcher_sound();
	if ( !IsDefined( destination ) )
		destination = trace_to_forward( 1000 )[ "position" ];
	tags =	[ 
			["tag_canister_left", 1000 ],
			["tag_canister_left", 0 ],
			["tag_canister_right", -1000]
			];
	
	rightvec = VectorToAngles( destination - self GetCentroid() );
	rightvec = vectornormalize ( anglestoright( rightvec ) );
	
	foreach( tag in tags )
		thread launch_smoke_from_tag( tag[ 0 ], destination + ( rightvec * tag[ 1 ] ) );

	return destination;
}

launch_smoke_from_tag( tag, destination )
{
	org = self GetTagOrigin( tag );
	angle = self GetTagAngles( tag );

	destination = drop_to_ground( destination );
	
	PlayFXOnTag( level._effect[ "smoke_start" ], self, tag );

	fake_grenade = Spawn( "script_model", org );
	fake_grenade SetModel( "projectile_m203grenade" );
	fake_grenade.origin = org;
	fake_grenade.angles = VectorToAngles( vectornormalize( destination - org ) );
	
	PlayFXOnTag( level._effect[ "rpg_trail" ], fake_grenade, "tag_origin" );

	fake_grenade move_with_rate( destination, fake_grenade.angles, 12000 );

	StopFXOnTag( level._effect[ "rpg_trail" ], fake_grenade, "tag_origin" );
	
	PlayFX( level._effect[ "smoke_screen_flash" ], destination, AnglesToForward( fake_grenade.angles ) );
	PlayFX( level._effect[ "smoke_screen" ], destination, AnglesToForward( fake_grenade.angles ) );
	
	//fake_grenade thread smoke_screen_vis_blocker( destination ); //commenting this out because block sight is set on the fx, i think our sightcone trace is just always passing

	fake_grenade Delete();
}

smoke_launcher_sound()
{
	Sdelay = RandomFloatRange( 0.1, 0.2 );
	org1 = self GetTagOrigin( "antenna1_jnt" );
	org2 = self GetTagOrigin( "antenna2_jnt" );
	thread play_sound_in_space( "satf_smoke_launcher", org1 );
	wait( Sdelay );
	thread play_sound_in_space( "satf_smoke_launcher", org2 );
}

trace_to_forward( forward_dist )
{
	if ( !IsDefined( forward_dist ) )
		forward_dist = 1000;
	pos = level.player GetEye();
	angles = level.player GetPlayerAngles();
	forward = AnglesToForward( angles );
	pos = pos + ( forward * 250 );
	target_pos = pos + ( forward * forward_dist );
	return BulletTrace( pos, target_pos, true, self );
}

smoke_screen_vis_blocker( destination )
{
	smoke_screen_ref_model = Spawn( "script_model", destination );
	smoke_screen_ref_model.angles = ( smoke_screen_ref_model.angles[ 0 ], self.angles[ 1 ] + 90, smoke_screen_ref_model.angles[ 2 ] );
	smoke_screen_ref_model CloneBrushmodelToScriptmodel( GetEnt( "smoke_screen_vis_blocker", "targetname" ) );
	
	wait( 6.0 );
	
	smoke_screen_ref_model Delete();
}

turret_reset()
{
	vect = ( 0, 0, 32 ) + self.origin + ( AnglesToForward( self.angles ) * 3000 );
	self SetTurretTargetVec( vect );
	self waittill( "turret_on_target" );
	self ClearTurretTarget();
}

//*** TOW fire ***//

on_fire_sabot()
{
	level.player endon( "remove_sabot" );
	level.playertank endon( "death" );
	level.player endon( "death" );
	level.player endon( "tank_dismount" );

	level.player waittill( "launch_sabot" );
	
	loc = self GetTagOrigin( "tag_flash" );
	ang = self GetTagAngles( "tag_flash" );
	loc += AnglesToForward( ang ) * 50;
	
	level thread maps\satfarm_audio::tow_missile_launch(loc);
	
	level.player init_sabot_for_player( loc, ang, self );
	level.player give_player_missile_control();
	level.player thread remove_player_missile_control();
}

tank_handle_sabot()
{	
	self endon( "death" );
	level.player endon( "tank_dismount" );
	level.player endon( "missile_tank_dismount" );
	
	level.player NotifyOnPlayerCommand( "cycle_weapon", "weapnext" );
	level.player NotifyOnPlayerCommand( "fire_sabot", "+attack" );
			
	while( !flag( "tow_out" ) )
	{
		level.player waittill( "cycle_weapon" );
		
		level.player playsound ("satf_change_view_tow");
		
		//flag_set( "guided_round_enabled" );
		
		ret = level.player waittill_any_return( "cycle_weapon", "fire_sabot" );
		
		level.player playsound ("satf_change_view_normal");
		
		if ( ret == "fire_sabot" )
		{
			level.player notify( "launch_sabot" );
			flag_set( "player_fired_guided_round" );
		}
	}
	
	if( isdefined( level.player.tank_hud_item[ "missile_status" ] ) )
    	level.player.tank_hud_item[ "missile_status" ] SetText( "OFFLINE" );
}

//*** NPC Tank Combat Script ***//

generic_tank_spawner_setup()
{
	array_spawn_function_noteworthy( "generic_tank_spawner", ::npc_tank_combat_init );
	array_spawn_function_noteworthy( "generic_tank_spawner", ::add_to_enemytanks_until_dead );
}

add_to_enemytanks_until_dead()
{
	level.enemytanks = array_add( level.enemytanks, self );
	
	self waittill( "death" );
	
	if( IsDefined( self ) )
	{
		level.enemytanks = array_remove( level.enemytanks, self );
	}
}

npc_tank_combat_init( mesh )
{
	if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		self endon( "death" );
			
		self.numwaits = 0;
		
		self thread handle_hit();
		self thread handle_death();
		self thread toggle_thermal_npc();
		
		if( !self isHelicopter() )
			self thread do_damage_from_tank(); //this does damage to choppers, this is a hack until we get physics vehicles doing damage to breakables
		
		if( self.script_team == "axis" )
		{
			thread handle_damage();
			self EnableAimAssist();
			self thread toggle_aim_assist();
			
			if( self istank() )
			{
				//self thread playerhaslineofsight();
				//self thread spawn_death_collision_phys( mesh );
			}
		}
		
		if( self istank() )
		{
			//self thread proxmity_check();
			self thread spawn_death_collision_phys( mesh );
			self thread manage_target_loc( mesh );
			
			waittillframeend;
			
			if( !IsDefined( mesh ) && !IsDefined( self.relative_speed ) )
				self thread proxmity_check_stop_loop();
		}
		
	}
}

toggle_aim_assist()
{
	//level.player NotifyOnPlayerCommand( "assist", "+actionslot 2" );
	
	while( 1 )
	{
//		level.player waittill( "assist" );
//		
//		IPrintLnBold( "Aim Assist on." );
//		
//		self EnableAimAssist();
//		
//		//IPrintLnBold( "Aim Assist off DEFAULT." );
//		
//		wait .05;
//		
		level.player waittill( "assist" );
		
		if( IsDefined( self ) )
			self DisableAimAssist();
		
		wait .05;
	}
	
}

//***
//		NPC Tank Firing (initially from tank_proto_iw6)
//***

manage_target_loc( mesh )
{
	self endon( "death" );
	
	wait RandomFloatRange( 0.5, 2.0 );
	
	if( !IsDefined( self.targetingOffset ) )
	self.targetingOffset = (0,0,64);
		
	while ( !flag( "all_tanks_stop_firing" ) )
	{
		// Grab the closest target
		if( !IsDefined( mesh ) ) 
			manage_closest_target();
		
		if( !isDefined( self.tank_target ) )
		{
			wait 05;
			continue;
		}
			
		self SetTurretTargetEnt( self.tank_target, self.targetingOffset );
		
		wait RandomFloatRange( .5, 1.0 );
			
		if( !IsDefined( self.disable_turret_fire ) )
		{
			if( IsDefined( self.override_target ) && self.override_target.classname != "script_vehicle_corpse" )
			{
				self SetTurretTargetEnt( self.override_target, self.targetingOffset );
				
				msg = self.override_target common_scripts\utility::waittill_any_timeout( 1 , "death" );
				if ( msg == "death" || 
				    ( IsDefined( self.override_target ) && self.override_target.classname == "script_vehcile_corpse" ) )
				{
					self.override_target = undefined;
					self ClearTurretTarget();
				} 
				else
					self attempt_fire_loc();
			}
			else if( IsDefined( self.tank_target ) && self.tank_target.classname != "script_vehicle_corpse" )
			{
				self SetTurretTargetEnt( self.tank_target, self.targetingOffset );
				
				msg = self.tank_target common_scripts\utility::waittill_any_timeout( 1 , "death" );
				if ( msg == "death" ||
					( IsDefined( self.tank_target ) && self.tank_target.classname == "script_vehcile_corpse" ) )
				{
					self.tank_target = undefined;
					self ClearTurretTarget();
				} 
				else
					self attempt_fire_loc();
			}
			else
			{
				self.tank_target = undefined;
				self ClearTurretTarget();
			}
		}
		
		wait RandomFloatRange( .5, 1.0 );
	}
}

attempt_fire_loc()
{
	if ( !IsDefined( self.tank_target ) )
	{
		return false;
	}
	else if ( self.classname != "script_vehicle_corpse" && //self check_fire_angle() &&
			  self.tank_target SightConeTrace( self.origin + (0, 0, 32), self ) && self isTank() )
	{
		//part of if: BulletTracePassed( self.origin + (0, 0, 32), self.tank_target.origin + (0, 0, 32), true, self )
		
		//IPrintLnBold( "Fx_vis: " + GetFXVisibility( self.origin + ( 0, 0, 32), self.tank_target.origin + ( 0, 0, 32) ) 
		//			  + " to: " +  self.tank_target.classname );
		
		if( GetFXVisibility( self.origin + ( 0, 0, 32), self.tank_target.origin + ( 0, 0, 32) ) < .5 )
			self set_override_offset( ( 0, 0, 192 ) );
		else
			self set_override_offset( ( 0, 0, 0 ) );
			
		self shoot_anim();

		msg = self.tank_target common_scripts\utility::waittill_any_timeout( 1 , "death" );
		if ( msg == "death" )
		{
			self.tank_target = undefined;
		} 
		
				return true;
	}
	return false;
}
			
check_fire_angle()
{
	for( i = 0; i < 20; i ++ )
	{
		if( !IsDefined( self.tank_target ) )
			return 0;
		
		flash 	= self GetTagAngles( "tag_flash" );
		flash 	= VectorNormalize( flash );
		vector 	= self.origin - self.tank_target.origin;
		vector	= VectorNormalize( vector );
				
		dot 	= VectorDot( flash, vector );
		
		if( dot > .7 )
		{
			println( "Dot: " + dot + " for " + self.classname );
			return 1;
		}
		wait .1;
	}
		
	return 0;
	
}

#using_animtree( "vehicles" );
tank_death_anim()
{
	self waittill ( "death" );
	if ( !IsDefined( self ) )
		return;
	self SetAnim( %hamburg_tank_explosion );
}

#using_animtree( "vehicles" );
shoot_anim()
{
	//IPrintLnBold( "Firing: " +  self.tank_target.classname );
	self FireWeapon();
	self ClearAnim( %abrams_shoot_kick, 0 );
	self SetAnimRestart( %abrams_shoot_kick );
	self thread tank_play_traced_effect();
}

do_decal_square( position )
{
	vects = [ ( 1, 0, 0 ), ( 0, 1, 0 ), ( -1, 0, 0 ), ( 0, -1, 0 ), ( 0, 0, 1 ), ( 0, 0, -1 ) ];
	foreach ( vec in vects )
	{
		trace = BulletTrace( position, position + ( vec * 256 ), false, self );
		if ( trace[ "fraction" ] == 1.0 )
			continue;
		if ( !IsDefined( trace[ "surfacetype" ] ) )
			continue;
			
		surfacetype = trace[ "surfacetype" ];
		
		angle = VectorToAngles( trace[ "normal" ] );
		PlayFX( getfx( "tank_blast_decal_" + surfacetype ), trace[ "position" ]  , AnglesToForward( angle ), AnglesToUp( angle ) );
	}
}

tank_play_traced_effect()
{
	start = self GetTagOrigin( "tag_flash" );
	end = tag_project( "tag_flash", 999999 );
	trace = BulletTrace( start, end, true, self );
	surfacetype = trace[ "surfacetype" ];
	
	hit_entity = IsDefined( trace[ "entity" ] );
	
	//if ( !IsDefined( surfacetype ) )
	//	return trace;
	
	//if ( trace[ "fraction" ] == 1 )
	//	return trace;
	

//	between_angle = trace[ "normal" ] + ( -1 * AnglesToForward( self GetTagAngles( "tag_flash" ) ) );
	between_angle = ( -1 * AnglesToForward( self GetTagAngles( "tag_flash" ) ) );
	
	angle = VectorToAngles( trace[ "normal" ] );
	
	the_trace_to_decal = trace;
	if ( hit_entity )
	{
		down_trace = BulletTrace( trace[ "position" ], trace[ "position" ] + ( 0, 0, -10000 ), false, trace[ "entity" ] );
		the_trace_to_decal = trace;
		
		if ( trace[ "entity" ].origin[ 2 ] - down_trace[ "position" ][ 2 ]     < 54 )
		{
			angle = VectorToAngles( down_trace[ "normal" ] );
			the_trace_to_decal = down_trace;
		}
	}

	if ( IsDefined(  level.playertank ) && self == level.playertank )
	{	
		do_decal_square( the_trace_to_decal[ "position" ] + VectorNormalize( the_trace_to_decal[ "normal" ] ) * 77 );
		PlayFX( getfx( "tank_blast_decal_" + surfacetype ), the_trace_to_decal[ "position" ]  , AnglesToForward( angle ), AnglesToUp( angle ) );
	}
	
	
	range = 500;
	PhysicsExplosionSphere( trace[ "position" ], range + 300, range * 0.25, 1 );
	
	angle = VectorToAngles( between_angle );
	PlayFX( getfx( "tank_blast_" + surfacetype ), trace[ "position" ]  , AnglesToForward( angle ), AnglesToUp( angle ) );
	thread play_sound_in_space( "grenade_explode_default", trace[ "position" ] );
	//return trace;
}

set_override_target( tank )
{
	if( IsDefined( self ) && IsDefined( tank ) && IsDefined( self.script_team )
 	    && IsDefined( tank.script_team ) && self.script_team != tank.script_team )
		self.override_target = tank;
}

set_override_offset( vector )
{
	self.targetingOffset = vector;
}

set_one_hit_kill( )
{
	while( IsDefined( self ) && self.classname != "script_vehicle_corpse")
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		
		if( IsDefined( self.script_team ) && IsDefined( attacker.script_team ) &&
			self.script_team != attacker.script_team && amount > 50 )
			self DoDamage( self.health + 200, self.origin );
	}
}

/*
=============
///ScriptDocBegin
"Name: fire_on_non_vehicle( <fireon> , <offset> )"
"Summary: Fire on a non_vehicle object with a direct shot."
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <fireon>: the targetname of the object, can only be an entity."
"MandatoryArg: <offset>: offset to fire on target."
"Example: tank fire_on_non_vehicle( "missile_defense_base", (0,0,1) );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
fire_on_non_vehicle( fireon, offset )
{
	self.disable_turret_fire = 1;
	
	targetObject 	= getent( fireon, "targetname" );
	
	if( !IsDefined( targetObject ) )
	{
	   AssertMsg ( "Target entity could not be found." );
	   return;
	}
	
	if( !IsDefined( offset ) )
		offset = (0,0,0);
	
	self SetTurretTargetEnt( targetObject, offset );
	
	wait 1;
	
	if( IsDefined( targetObject ) )
	{
	MagicBullet( "tankfire_straight_fast", self GetTagOrigin( "tag_flash" ), targetObject.origin + offset, level.player );
	PlayFXOnTag( getfx( "tank_muzzleflash" ), self, "tag_flash" );
	self JoltBody( self.origin, 1000, 1, .5 );
		self ClearAnim( %abrams_shoot_kick, 0 );
		self SetAnimRestart( %abrams_shoot_kick );
	}
	
	wait 1;
	
	self.disable_turret_fire = undefined;
}

fire_now_on_vehicle( fireon, offset )
{
	self.disable_turret_fire = 1;
	
	if( !IsDefined( fireon ) )
	   AssertMsg ( "Target entity could not be found." );
	
	if( !IsDefined( offset ) )
		offset = (0,0,0);
	
	self SetTurretTargetEnt( fireon, offset );
	
	wait 1;
	
	if( IsDefined( fireon ) )
	{
		MagicBullet( "tankfire_straight_fast", self GetTagOrigin( "tag_flash" ), fireon.origin + offset );
		PlayFXOnTag( getfx( "tank_muzzleflash" ), self, "tag_flash" );
		self JoltBody( self.origin, 1000, 1, .5 );
		self ClearAnim( %abrams_shoot_kick, 0 );
		self SetAnimRestart( %abrams_shoot_kick );
	}
	
	wait 1;
	
	self.disable_turret_fire = undefined;
}

handle_damage()
{
	self endon( "death" );

	health_original = self.health - self.healthbuffer;
	
	self waittill( "damage", amount, attacker, direction_vec, point, type );
	
	distanceToAttacker = distance_2d_squared( self.origin, attacker.origin );
	
	// Kill tank if range is 3000 units
	if( distanceToAttacker < 9000000 && amount > 250 )
	{
		health = self.health - self.healthbuffer;
		self DoDamage( health * 3, self.origin );
		return;
	}
	
	eforward = AnglesToForward( self.angles );
	vNormal	 = VectorNormalize( direction_vec );
	dot 	 = abs( vectordot( eforward, vNormal ) );
	
	// Kill tank if shot is not in front
	if( dot < .9 && amount > 250 )
	{
		health = self.health - self.healthbuffer;
		self DoDamage( health * 3, self.origin );
		return;
	}
	
	// A quick hack to reduce the tank's health once it has gone
	// below 80%. This is to insure the tank dies in two hits.
	health_hacked = false;
	
	while ( isdefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		health = self.health - self.healthbuffer;
		
		if ( health <= health_original * 0.8 )
		{
			if ( !health_hacked )
			{
				self.health = self.healthbuffer + 100;
				health_hacked = true;
			}
			
			PlayFXOnTag( getfx( "tank_heavy_smoke" ), self, "tag_turret" );
		}
		
		wait 0.1;
	}
}

handle_hit()
{
	while( isdefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		
		self set_override_target( attacker );
		
		if( IsDefined( level.playertank ) && attacker == level.playertank )
		{
			if( self.script_team == "allies" )
			{
				//add_dialogue_line( "Badger", "Friendly Fire!" );
			}
			else
			{
				if (self.health < self.healthbuffer)
				{
					level thread maps\satfarm_audio::tank_death_player(self.origin);
				}
				else
				{
					level thread maps\satfarm_audio::tank_damage_player(self.origin);	
				}
				event = createEvent( "inform_enemy_hit", "inform_hit" );	
				level.player play_chatter( event );
			}
		}
		else
		{
				if (self.health < self.healthbuffer)
				{
					level thread maps\satfarm_audio::tank_death_allies(self.origin);
				}
				else
				{
					level thread maps\satfarm_audio::tank_damage_allies(self.origin);	
				}
		}
		
		wait .05;	
	}
}

handle_death()
{
	steam 	= self.script_team;
	sclass 	= self.classname;
	while( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
		wait .01;
	
	if( IsDefined( steam ) && steam == "allies" )
	{
		//add_dialogue_line( "Badger", "Friendly tank down!" );		
	}
	else
	{
		if( IsDefined( self ) && sclass != "t90_sand" && Target_IsTarget( self ) )
			Target_Remove( self );
		event = createEvent( "killfirm", "killfirm" );	
		level.player play_chatter( event );
	}
}

/*
=============
///ScriptDocBegin
"Name: spawn_death_collision()"
"Summary: Spawn in death collision for vehicle destroyed model and attach it to the model."
"Module: Entity"
"CallOn: An entity"
"Example: tank spawn_death_collision"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
spawn_death_collision( mesh )
{
	while( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
		wait .05;
	
	if( IsDefined( self ) )
	{
		self notify( "death" );
		self SetContents( 0 );
		
		if( IsDefined( self.deathfx_ent ) )
		{
			self.deathfx_ent CloneBrushmodelToScriptmodel( level.death_model_col );
		
			if( IsDefined( mesh ) )
			{
				crushTrigger = Spawn( "trigger_radius", self.origin, 16, 8, 256 );
				crushTrigger.angles = self.angles;
				
				crushTrigger waittill( "trigger" );
				
				if( IsDefined( self ) ) 
				{
					self.deathfx_ent delete();
					self delete();
					crushTrigger delete();
				}
			}
		}
	}
}

spawn_death_collision_phys( mesh )
{
	while( IsDefined( self ) && ( self.model != "vehicle_t90_tank_woodland_d" ) ) //IsAlive( self ) || self.classname != "script_vehicle_corpse" ||
		wait .05;
	
	if( IsDefined( self ) )
	{
		self SetContents( 0 );
		
		tank = spawn( "script_model", self.origin );
		tank.angles = self.angles;
		tank SetModel( "vehicle_t90_tank_woodland_d" );
		//print3d( self.origin, "tank", (0,0,1), 1, 10, 1000 );
		col = spawn( "script_model", self.origin );
		col CloneBrushmodelToScriptmodel( level.death_model_col );
		col.angles = self.angles;
		self delete();
		
		if( IsDefined( mesh ) )
		{
			crushTrigger = Spawn( "trigger_radius", tank.origin, 16, 8, 256 );
			crushTrigger.angles = tank.angles;
			
			crushTrigger waittill( "trigger" );
			
			if( IsDefined( tank ) ) 
			{
				//tank delete();
				tank moveto( tank.origin - ( 0,0,16 ), .25 );
				col delete();
				crushTrigger delete();
			}
		}
	}
}

//***
//		Player Targeting Items
//***

playerhaslineofsight()
{
	self endon( "death" );
	
	self thread toggle_npc_target();
		
	while( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		if( IsDefined( self ) && self.classname != "script_vehicle_corpse" &&
		  	self SightConeTrace( level.player.origin + (0, 0, 32), level.player ) )
		{
			if( !level.isTargetingOff ) 
			{
				shader = "ac130_hud_enemy_vehicle_target_s_w";
				color = ( 1, 0, 0 );	
				thread target_enable( self, shader, color, 128 );
			}
		}
		else
		{
			if( Target_IsTarget( self ) )
				Target_Remove( self );
		}
		wait .01;
	}
}

toggle_npc_target()
{
	level.player NotifyOnPlayerCommand( "target", "+actionslot 3" );
	
	level.isTargetingOff = 0;
	
	while( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		//IPrintLnBold( "Targeting off." );
		
		if( Target_IsTarget( self ) )
			Target_Remove( self );
		
		level.isTargetingOff = 1;
		
		wait .05;
		
		level.player waittill( "target" );
		
		//IPrintLnBold( "Targeting on DEFAULT." );
		
		shader = "ac130_hud_enemy_vehicle_target_s_w";
		color = ( 1, 0, 0 );
			
		if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
			thread target_enable( self, shader, color, 128 );
			
		level.isTargetingOff = 0;
		
		wait .05;
		level.player waittill( "target" );
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

//*** BATTLECHATTER (from iw6 prototype) ***//

init_chatter()
{
	if ( isdefined( anim.tank_bc ) )
		return;

	level.tank_chatter_enabled = true;
		
	anim.tank_bc = spawnstruct();  // holds all of our SO-specific bc stuff
	anim.tank_bc.bc_isSpeaking = false;
	
	anim.tank_bc.numTankVoices = 1;
	anim.tank_bc.currentAssignedVoice = 0;
	
	anim.tank_bc.lastAlias = [];
	
	anim.tank_bc.bc_eventTypeLastUsedTime = [];
	anim.tank_bc.bc_eventTypeLastUsedTimePlr = [];
		
	anim.tank_bc.eventTypeMinWait = [];
	anim.tank_bc.eventTypeMinWait[ "same_alias" ]			= 15;
	anim.tank_bc.eventTypeMinWait[ "callout_clock" ]		= 10;
	anim.tank_bc.eventTypeMinWait[ "killfirm" ]				= 3;
	anim.tank_bc.eventTypeMinWait[ "inform_firing" ]		= 10;
	anim.tank_bc.eventTypeMinWait[ "inform_taking_fire" ]	= 30;
	anim.tank_bc.eventTypeMinWait[ "inform_reloading" ]		= 5;
	anim.tank_bc.eventTypeMinWait[ "inform_loaded" ]		= 0.5;
	anim.tank_bc.eventTypeMinWait[ "inform_enemy_hit" ]		= 5;
	anim.tank_bc.eventTypeMinWait[ "inform_enemy_retreat" ]	= 5;
	
	anim.tank_bc.bcPrintFailPrefix = "^3***** BCS FAILURE: ";
	
	if ( isPlayer( self ) )
	{
		self.voiceID = "plr";
		self.bc_isSpeaking = false;
		
		// Player only
		self thread enemy_callout_tracking_plr();
	}
	else
	{
		return; // AI battlechatter not ready
		//self.voiceID = anim.tank_bc.currentAssignedVoice + 1;
		//anim.tank_bc.currentAssignedVoice = ( anim.tank_bc.currentAssignedVoice + 1 )%anim.tank_bc.numHeliVoices;
	}

	self.bc_enabled = true;
}

createEvent( eventType, alias )
{
	event = SpawnStruct();
	event.eventType = eventType;
	event.alias = alias;
	
	return event;
}

play_chatter( event, check_alias )
{
	self endon( "death" );
		
	if( !self can_say_event_type( event.eventType ) )
	{
		return false;
	}

	soundalias = get_team_prefix() + self.voiceID + "_" + event.alias;
	// soundalias = check_overrides( eventType, soundalias );
	
	if( !IsDefined( soundalias ) )
	{
		return false;
	}
	
	if( !SoundExists( soundalias ) )
	{
		PrintLn( anim.tank_bc.bcPrintFailPrefix + "soundalias " + soundalias + " doesn't exist." );
		return false;
	}
	
	if ( !isdefined( check_alias ) )
		check_alias = false;
			
	if ( check_alias && !can_say_soundalias( soundalias ) )
		return false;
	
	if ( isPlayer( self ) )
		self.bc_isSpeaking = true;
	else
		anim.tank_bc.bc_isSpeaking = true;
	iprintln( "tank bcs: " + soundalias );
	self PlaySound( soundalias, "bc_done", true );
	self waittill( "bc_done" );
	if ( isPlayer( self ) )
		self.bc_isSpeaking = false;
	else
		anim.tank_bc.bc_isSpeaking = false;
	
	self update_event_type( event.eventType, event.alias );
	
	return true;
}

can_say_event_type( eventType )
{
	if ( !isdefined( level.tank_chatter_enabled ) || !level.tank_chatter_enabled )
	{
		return false;
	}
	
	//if ( !isdefined( self.bc_enabled) && !self.bc_enabled ) // old script
	if ( isdefined( self.bc_enabled) && !self.bc_enabled )
	{
		return false;
	}
	
	if ( !isPlayer( self ) && anim.tank_bc.bc_isSpeaking )
	{
		return false;
	}
	else if ( isPlayer( self ) && self.bc_isSpeaking )
	{
		return false;
	}
	
	if( isPlayer( self ) && !IsDefined( anim.tank_bc.bc_eventTypeLastUsedTimePlr[ eventType ] ) )
	{
		return true;
	}
	else if( !isPlayer( self ) && !IsDefined( anim.tank_bc.bc_eventTypeLastUsedTime[ eventType ] ) )
	{
		return true;
	}
	
	if ( isPlayer( self ) )
		lastUsedTime = anim.tank_bc.bc_eventTypeLastUsedTimePlr[ eventType ];
	else
		lastUsedTime = anim.tank_bc.bc_eventTypeLastUsedTime[ eventType ];
	
	minWaitTime = anim.tank_bc.eventTypeMinWait[ eventType ] * 1000;
		
	if( ( GetTime() - lastUsedTime ) >= minWaitTime )
	{
		return true;
	}
	
	return false;
}

can_say_soundalias( alias )
{
	if ( isDefined( anim.tank_bc.lastAlias[ "alias" ] ) && anim.tank_bc.lastAlias[ "alias" ] == alias )
	{
		lastUsedTime = anim.tank_bc.lastAlias[ "time" ];
		minWaitTime = anim.tank_bc.eventTypeMinWait[ "same_alias" ] * 1000;
			
		if( ( GetTime() - lastUsedTime ) < minWaitTime )
		{
			return false;
		}
	}
	
	return true;
}

update_event_type( eventType, alias )
{
	if ( isPlayer( self ) )
		anim.tank_bc.bc_eventTypeLastUsedTimePlr[ eventType ] = GetTime();
	else
		anim.tank_bc.bc_eventTypeLastUsedTime[ eventType ] = GetTime();
	
	anim.tank_bc.lastAlias[ "time" ] = GetTime();
	anim.tank_bc.lastAlias[ "alias" ] = alias;
}

check_overrides( soundtype, defaultAlias )
{
	return defaultAlias;
}

get_team_prefix()
{
	return "tank_";
}

take_fire_tracking()
{
	self endon( "death" );
	level.player endon( "tank_dismount" );
	while( 1 )
	{
		self waittill( "damage", amount, attacker );
		self.request_move = true;
		if ( isdefined( attacker ) )
		{
			if ( !isPlayer( attacker ) )
			{
				event = createEvent( "inform_taking_fire", "inform_taking_fire" );	
				play_chatter( event );
			}
		}
	}
}

MAX_THREAT_CALLOUT_DIST = 8000;
MIN_THREAT_CALLOUT_REPEAT = 9 * 5000;

enemy_callout_tracking_plr()
{
	self endon( "death" );
	level.player endon( "tank_dismount" );
	while( 1 )
	{
		target = undefined;
		targets = [];
		vehicles = getvehiclearray();
		
		foreach ( v in vehicles )
		{
			if ( v.script_team != "allies" )
			{
				targets = array_add( targets, v );
			}
		}
		
		targets = sortbydistance( targets, self.origin );
		
		foreach ( t in targets )
		{
			if ( isdefined( t.lastPlayerCalloutTime ) && ( GetTime() - t.lastPlayerCalloutTime < MIN_THREAT_CALLOUT_REPEAT ) )
				continue;
				
			if ( Distance2d( self.origin, t.origin ) > MAX_THREAT_CALLOUT_DIST )
				break;
			
			target = t;
			break;
		}
		
		if ( !isdefined( target ) )
		{
			targets = getAIArray( "axis" );
			targets = array_combine( getAIArray( "team3" ), targets );
			targets = SortByDistance( targets, self.origin );
			foreach ( t in targets )
			{
				if ( isdefined( t.lastPlayerCalloutTime ) && ( GetTime() - t.lastPlayerCalloutTime < MIN_THREAT_CALLOUT_REPEAT ) )
					continue;
					
				if ( Distance2d( self.origin, t.origin ) > MAX_THREAT_CALLOUT_DIST )
					break;
				
				target = t;
				break;
			}
		}
		
		if ( isdefined( target ) )
		{
			event = createEvent( "callout_clock", self getThreatAlias( target ) );
			if ( self play_chatter( event ) )
			{
				if ( isdefined( target ) )
					target.lastPlayerCalloutTime = GetTime();
			}
		}
		wait( 1 );
	}
}

getThreatAlias( threat )
{
	if ( isPlayer( self ) )
		clockface = animscripts\battlechatter::getDirectionFacingClock( self getplayerangles(), self.origin, threat.origin );
	else
		clockface = animscripts\battlechatter::getDirectionFacingClock( self.angles, self.origin, threat.origin );
	str = "callout_targetclock_" + clockface;
	
	if ( cointoss() )
	{
		if ( isAI( threat ) )
		{
			str = str + "_troops";
		}
		if ( threat isVehicle() )
		{
			if ( threat isHelicopter() )
			{
				str = str + "_bird";
			}
			if ( threat isTank() )
			{
				str = str + "_tank";
			}
		}
	}
	
	return str;
}

/***
 * 		DYNAMIC ENEMY MOVEMENT ON MESH INIT
 ***/
 
DISTANCE_FAR_FROM_PLAYER_SQUARED	= 1500 * 1500;
CONST_MIN_DIST_FROM_PLAYER_SQUARED	= 1000 * 1000;
 
nav_mesh_build()
{
	level.pos_info_array = [];
	
	nodes = GetVehicleNodeArray( "tank_enemy_nodes", "script_noteworthy" );
	foreach ( node in nodes )
	{
		if ( node is_path_start_node() )
		{
			node.nav_type = "path_start";
			add_path_start_and_end_refs( node );
		}
		else if ( node is_path_end_node() )
		{
			node.nav_type = "path_end";
		}
		else
		{
			node.nav_type = "path";
		}
	}
	
	/#
	foreach( node in nodes )
	{
		if ( node is_path_end_node() )
		{
			AssertEx( IsDefined( node.path_start ), "Path end node without path start reference at origin: " + node.origin );
		}
		else if ( node is_path_start_node() )
		{
			AssertEx( IsDefined( node.path_end ), "Path start node without path end reference at origin: " + node.origin );
		}
	}
	#/
	
	foreach ( node in nodes )
	{
		// Mid path nodes don't need nav mesh info
		if ( node is_path_mid_node() )
			continue;
		
		// Continue if the node is already set up
		if ( IsDefined( node.pos_info ) )
			continue;
		
		pos_info = SpawnStruct();
		pos_info.nodes_start = [];
		pos_info.nodes_end = [];
		
		level.pos_info_array[ level.pos_info_array.size ] = pos_info;
		
		// Add all nodes linked to this (including this node) to
		// either the pos_info.nodes_start array or the pos_info.nodes_end array
		for ( i = 0; i < nodes.size; i++ )
		{
			exitNode = undefined;
			// if compare node has both, exit node
			if( IsDefined( nodes[ i ].script_linkname ) && IsDefined( nodes[ i ].script_linkto ) )
			{
				exitNode = 1;
			}
			
			// if compare node does not have a linkto, bail out.
			if( !IsDefined( nodes[ i ].script_linkto ) )
			{
				// if compare node does not have a linkname check if it has a script_linkto
				if( !IsDefined( nodes[ i ].script_linkname ) )
					continue;
				// Compare node has linkname, if the compare node and the current node do not equal each other, bail out.
				else if( IsDefined( node.script_linkto ) && nodes[ i ].script_linkname != node.script_linkto )
					continue;
				// Compare node has linkname, if the compare node and the current node do not equal each other, bail out.
				else if( IsDefined( node.script_linkname) && nodes[ i ].script_linkname != node.script_linkname )
					continue;
			}
			// Compare node has a linkto, if the compare node and the current node do not equal each other, bail out.
			else if( IsDefined( node.script_linkname ) && nodes[ i ].script_linkto != node.script_linkname )
				continue;
			// Compare node has a linkto, if the compare node and the current node do not equal each other, bail out.
			else if( IsDefined( node.script_linkto) && nodes[ i ].script_linkto != node.script_linkto )
				continue;

	
			if ( nodes[ i ] is_path_start_node() )
			{
				AssertEx( !array_contains( pos_info.nodes_start, nodes[ i ] ), "A tank nav mesh node array had the same node added twice. This shouldn't happen." );
				pos_info.nodes_start[ pos_info.nodes_start.size ] = nodes[ i ];
			}
			else if ( nodes[ i ] is_path_end_node() )
			{
				AssertEx( !array_contains( pos_info.nodes_end, nodes[ i ] ), "A tank nav mesh node array had the same node added twice. This shouldn't happen." );
				pos_info.nodes_end[ pos_info.nodes_end.size ] = nodes[ i ];
			}
			else
			{
				AssertMsg( "Invalid Node Position - Mid path node found at start of path at origin: " + nodes[ i ].origin );
				continue;
			}
			
			nodes[ i ].pos_info 	= pos_info;
			nodes[ i ].exit_node 	= exitNode;
		}
	}
}

is_path_end_node()
{
	if ( IsDefined( self.nav_type ) )
		return self.nav_type == "path_end";
	
	is_targetting = IsDefined( self.target ) && IsDefined( GetVehicleNode( self.target, "targetname" ) );
	is_targetted = IsDefined( self.targetname ) && IsDefined( GetVehicleNode( self.targetname, "target" ) );
	
	return !is_targetting && is_targetted;
}

is_path_start_node()
{
	if ( IsDefined( self.nav_type ) )
		return self.nav_type == "path_start";
	
	return IsDefined( self.spawnflags ) && self.spawnflags & 1 == 1;
}

is_path_mid_node()
{
	if ( IsDefined( self.nav_type ) )
		return self.nav_type == "path";
	
	return !self is_path_start_node() && !self is_path_end_node();
}

add_path_start_and_end_refs( start_node )
{
	start_node.path_end = start_node get_path_end_node();
	
	start_node.path_end.path_start = start_node;
}

get_path_end_node()
{
	AssertEx( self is_path_start_node(), "Adding a path start reference requires a path start node." );
	
	node_curr = self;
	
	while ( IsDefined( node_curr.target ) )
	{
		node_curr = GetVehicleNode( node_curr.target, "targetname" );
	}
	
	AssertEx( node_curr != self, "Path in nav mesh with only one node found at location: " + node_curr.origin );
	
	return node_curr;
}

nav_mesh_pathing( first_node, exitFlag )
{
	self endon( "death" );

	if( !isDefined( exitFlag ) )
		exitFlag = "nostopping";

	if( !IsDefined( self ) )
		return; 
	
	self thread proxmity_check_stop_loop( exitFlag, "", 1 );
	self.stuck = 0;
						
	// Right now the tank could be on a path or it could have just spawned
	// in. Until it decides to move, run a simpler loop of logic. This should
	// be rolled into the main loop but I don't have time.
	self thread manage_position_in_use_loc( first_node );
	self.pastswitch = first_node;
	
	// Start the vehicle on first path
	switch_node_now( self, first_node );
	self waittill( "reached_end_node" );
//	
//	while ( !flag( exitFlag ) )
//	{
//		path_node = self get_optimal_next_path_loc( first_node.path_end.pos_info );
//		if ( !IsDefined( path_node ) )
//		{
//			wait .5;
//			continue; 
//		}
//		else
//		{
//			switch_node_now( self, path_node );
//			self waittill( "reached_end_node" );
//			break;
//		}
//	}
//	
	// Delay the initial path to prevent other tanks from spawning
	// in on top of this one. The correct fix would be to keep a previous
	// node in use until this tank has had time to move off of it.
	//wait 1.5;
	
	// Let's the maps\_vehicle::vehicle_paths() function update the	.currentnode
	wait .05;
	
	switch_path	= undefined;
	
	while ( !flag( exitFlag ) )
	{
//		//prof_begin( "SF_nav_mesh" );
		if ( !IsDefined( switch_path ) )
		{
//			//prof_begin( "SF_nav_mesh1" );			
			pos_info			= self.currentnode.pos_info;
			actual_current_node	= self.currentnode;
			
			// if the tank just reversed the node it is on top
			// of is the attachedpath node, not the current node
			if ( self.veh_pathdir == "reverse" )
			{
				pos_info			= self.attachedpath.pos_info;
				actual_current_node = self.attachedpath;
			}
			
			if( !IsDefined( pos_info ) )
			{
//				//prof_end( "SF_nav_mesh1" );
//				//prof_end( "SF_nav_mesh" );
				wait .5;
				continue;
			}
			
//			//prof_end( "SF_nav_mesh1" );
//			//prof_end( "SF_nav_mesh" );
			path_node = self get_optimal_next_path_loc( pos_info );
//			//prof_begin( "SF_nav_mesh1" );
//			//prof_begin( "SF_nav_mesh" );

			if ( !IsDefined( path_node ) )
			{
//				//prof_end( "SF_nav_mesh1" );
//				//prof_end( "SF_nav_mesh" );
				wait .5;
				continue;
			}
			
			// ESCHMIDT: try blocking here
			// Node is choosen, lock it from use.
			self thread manage_position_in_use_loc( path_node.path_end );
			
			goal_pos_info = path_node.path_end.pos_info;
			
			// Check to see if the chosen path start node's path end node could
			// be reached by reversing on the tank's current path
			if ( actual_current_node is_path_end_node() && actual_current_node.path_start.origin == path_node.path_end.origin )
			{
				path_node = actual_current_node;	
			}
			
			is_path_end = path_node is_path_end_node();
			
			if ( is_path_end )
			{
				path_node = path_node.path_start;
			}
			
			is_same_path = same_path( path_node );
			
			if ( is_same_path && is_path_end )
				self.veh_transmission = "reverse";
			else
				self.veh_transmission = "forward";
			
			if ( is_path_end )
				self.veh_pathdir = "reverse";
			else
				self.veh_pathdir = "forward";
			
			if ( !is_same_path )
			{
				switch_node_now( self, path_node );
			    self Vehicle_SetSpeed( 20, 25, 25 ); //needed to get the vehicle moving
		    	self ResumeSpeed( 25 );
			}
			else
			{
				self StartPath();
			    self Vehicle_SetSpeed( 20, 25, 25 ); //needed to get the vehicle moving
		    	self ResumeSpeed( 25 );
			}
			//prof_end( "SF_nav_mesh1" );
		}
		else
		{
			////prof_begin( "SF_nav_mesh2" );
			//self thread manage_switching_vehicle_speed_loc( switch_path );
			switch_node_now( self, switch_path );
		    self Vehicle_SetSpeed( 20, 25, 25 ); //needed to get the vehicle moving
	    	self ResumeSpeed( 25 );
	    	////prof_end( "SF_nav_mesh" );
	    	////prof_end( "SF_nav_mesh2" );
			self waittill( "reached_end_node" );
			////prof_begin( "SF_nav_mesh" );
			switch_path 	= undefined;
		}
		
		// If the tank is moving forward, check ahead to see
		// if the tank can skip the path end and continue right on another path
		if ( self.veh_pathdir == "forward" && !self.currentnode is_path_end_node() )
		{
			nextnode = undefined;
			while ( !flag( exitFlag ) )
			{	
				////prof_begin( "SF_nav_mesh3" );
				if( !( self.currentnode is_path_end_node() ) && IsDefined( self.currentnode ) && IsDefined( self.currentnode.target ) )
				{
					if( IsDefined( nextnode ) && self.currentnode.target != nextnode.targetname )
						nextnode = GetVehicleNode( self.currentnode.target, "targetname" );
					else if( !IsDefined( nextnode ) )
						nextnode = GetVehicleNode( self.currentnode.target, "targetname" );
					//Print3d( next_node.origin, "current", ( 0, 1, 0 ), 1, 10, 200 );
					
					if ( IsDefined( nextnode ) && nextnode is_path_end_node() )
					{
						//if ( DistanceSquared( self.origin, level.player.origin ) > DISTANCE_FAR_FROM_PLAYER_SQUARED )
						//{
						
							////prof_end( "SF_nav_mesh" );
							////prof_end( "SF_nav_mesh3" );
							switch_path = self get_optimal_next_path_loc( nextnode.pos_info );
							////prof_begin( "SF_nav_mesh" );
							////prof_begin( "SF_nav_mesh3" );
						//}
						
						if( IsDefined( switch_path ) && IsDefined( switch_path.pos_info.prev_in_use) 
						    && switch_path.pos_info.prev_in_use == self )
						{
							////prof_end( "SF_nav_mesh" );
							////prof_end( "SF_nav_mesh3" );
							wait 2;
						}
						
						////prof_end( "SF_nav_mesh" );
						////prof_end( "SF_nav_mesh3" );
						// ESCHMIDT: wait here
						break;
					}
				}
				else	
				{
					// ESCHMIDT: code clean!
//					Assert( self.currentnode is_path_end_node() );
					if( self.currentnode is_path_end_node() )
					{
						//if ( DistanceSquared( self.origin, level.player.origin ) > DISTANCE_FAR_FROM_PLAYER_SQUARED )
						//{
							////prof_end( "SF_nav_mesh" );
							////prof_end( "SF_nav_mesh3" );
							switch_path = self get_optimal_next_path_loc( self.currentnode.pos_info );
							////prof_begin( "SF_nav_mesh" );
							////prof_begin( "SF_nav_mesh3" );
						//}
						
						if( IsDefined( switch_path ) && IsDefined( switch_path.pos_info.prev_in_use) 
						    && switch_path.pos_info.prev_in_use == self )
						{
							//prof_end( "SF_nav_mesh" );
							//prof_end( "SF_nav_mesh3" );
							wait 2;
						}
						
						//prof_end( "SF_nav_mesh" );
						//prof_end( "SF_nav_mesh3" );
						// ESCHMIDT: wait here
						break;
					}
					
					//prof_end( "SF_nav_mesh" );
					//prof_end( "SF_nav_mesh3" );
					AssertMsg( "No target for pathnode." );
					// ESCHMIDT: wait here
					break;
				}
				//prof_end( "SF_nav_mesh" );
				//prof_end( "SF_nav_mesh3" );
				nextnode waittill_any_timeout( 4, "trigger" );
				//prof_begin( "SF_nav_mesh" );
			}
		}
		
		if ( IsDefined( switch_path ) )
		{
			self thread manage_position_in_use_loc( switch_path.path_end );
			//prof_end( "SF_nav_mesh" );
			// ESCHMIDT: wait here
			continue;
		}
		//prof_end( "SF_nav_mesh" );
		self waittill( "reached_end_node" );
			
		wait .5;
	}
	
	if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
		self nav_mesh_exit( self.currentnode );
	//prof_end( "SF_nav_mesh" );
}

same_path( path_node )
{
	if( IsDefined( self.attachedpath ) ) 
		if( self.attachedpath == path_node )
			return 1;
	else if( IsDefined( self.attachedpath.script_linkname ) && IsDefined( path_node.script_linkname ) )
		{
			attachedpathlinkname = StrTok( self.attachedpath.script_linkname, 	"_" );
			pathnodelinkname 	 = StrTok( path_node.script_linkname,		  	"_" );
			if( attachedpathlinkname[1] == pathnodelinkname[1] )
				return 1;
			if( IsDefined( path_node.script_linkto ) )
			{
				pathnodelinkto = StrTok( path_node.script_linkto,				"_" );
				if( attachedpathlinkname[1] == pathnodelinkto[1] )
					return 1;
			}
		}
	return 0;
}

nav_mesh_exit( currentNode )
{
	self endon( "death" );
	
	level.inc 			= 0;
	self.shortestdepth 	= 0;
	
	// find the exit node
	array 			= [];
	array[ 0 ] 		= currentNode;
	//Print3d( currentNode.origin, "c", (0,0,1), 1, 3, 1000 );
	nodeExitArray 	= [];
	nodeExitArray 	= self nav_mesh_exit_recursive( array );
		
	if( !IsDefined( nodeExitArray ) )
	{
		//IPrintLnBold( "Undefined Array" );
		return undefined; 	
	}
	   	
	if( nodeExitArray.size == 0 )
	{
		//IPrintLnBold( "No Array" );
		return undefined; 
	}
	
	//IPrintLnBold( "Array! " + nodeExitArray.size );
		
	wait .05;
	
	// move to exit node
	nodeExit 	= undefined;
	isfirstnode = true;
	foreach( node in nodeExitArray )
	{
		nodeExit = node;
		if( isDefined( node.path_start ) && isDefined( node.path_start.path_end ) )
			if( !IsDefined( node.path_start.path_end.pos_info.in_use ) ||
			    ( IsDefined( node.path_start.path_end.pos_info.in_use ) &&
			      node.path_start.path_end.pos_info.in_use == self ) )
				if( !IsDefined( node.path_start.path_end.pos_info.prev_in_use ) )
				{
					self thread manage_position_in_use_loc( node.path_start.path_end );
					
					switch_node_now( self, node.path_start );
					cscriptlinkto 	= StrTok( node.path_start.script_linkname, "_" );
					comparelinkto 	= cscriptlinkto[1];
					//Print3d( node.path_start.origin, comparelinkto, (0,0,1), 1, 3, 1000 );
				}
				else if( node.path_start.path_end.pos_info.prev_in_use == self )
				{
					self thread manage_position_in_use_loc( node.path_start.path_end );
					
					switch_node_now( self, node.path_start );
					cscriptlinkto 	= StrTok( node.path_start.script_linkname, "_" );
					comparelinkto 	= cscriptlinkto[1];
					//Print3d( node.path_start.origin, comparelinkto, (0,0,1), 1, 3, 1000 );
				}
				else
					continue;
			else
				continue;
		else
			continue;
		
		wait .05;
		self waittill( "reached_end_node" );
		wait .05;
	}
	
	// exit mesh
	targetNode = GetVehicleNode( self.exitNodeName , "targetname" );	
	if( IsDefined( targetNode ) )
		switch_node_now( self, targetNode );
}

nav_mesh_exit_recursive( array )
{
	shortestArray = [];
	
	if( IsDefined( array[ array.size - 1 ].exit_node ) )
	{
		if( self.shortestdepth > array.size || self.shortestdepth == 0)
			self.shortestdepth = array.size;
		return array;
	}
	else if( array.size > 15 ) // prevent infinite recursion
	{
		return shortestArray;  // returns an empty array
	}
	else
	{
		lastNode = array[ array.size - 1 ];
		foreach ( n in lastNode.pos_info.nodes_start )
		{
			if( !array_contains_script_linkto( array, n.path_end ) )
			{			
				newarray 					= array;
				newarray[ newarray.size ] 	= n.path_end;
				holderArray 				= nav_mesh_exit_recursive( newarray );
			
				if( holderArray.size == self.shortestdepth ) // || array.size == 0 ) )
				{
					shortestArray	= holderArray;

					//level.inc++;
					//Print3d( n.origin, 			level.inc, (1,0,0), 1, 3, 1000 );
					//level.inc++;
					//Print3d( n.path_end.origin, level.inc, (0,1,0), 1, 3, 1000 );	
				}
			}
		}
	}
	
	return shortestArray;
}

array_contains_script_linkto( array, compare )
{
	if ( array.size <= 0 )
		return false;
	
	comparelinkto = "";
	
	if( IsDefined( compare.script_linkto ) )
	{
		cscriptlinkto 	= StrTok( compare.script_linkto, "_" );
		comparelinkto 	= cscriptlinkto[1];
	}
	else if( IsDefined( compare.script_linkname ) )
	{
		cscriptlinkto 	= StrTok( compare.script_linkname, "_" );
		comparelinkto 	= cscriptlinkto[1];
	}
	
	foreach ( member in array )
	{
		if( IsDefined( member.script_linkto ) )
		{
			mscriptlinkto 	= StrTok( member.script_linkto, "_"  );
			memberlinkto 	= mscriptlinkto[1];
			if( memberlinkto == comparelinkto )
				return true;
		}
		else if( IsDefined( member.script_linkname ) )
		{
			mscriptlinkto 	= StrTok( member.script_linkname, "_"  );
			memberlinkto 	= mscriptlinkto[1];
			if( memberlinkto == comparelinkto )
				return true;
		}
	}

	return false;
}

get_optimal_next_path_loc( pos_info )
{
	//prof_begin( "SF_get_optimal" );
	////prof_begin( "SF_get_optimal1" );
	// Grab available start nodes
	node_end_options = [];
	foreach ( n in pos_info.nodes_start )
	{
		if ( !IsDefined( n.path_end.pos_info.in_use ) )
			//if( !IsDefined( n.path_end.pos_info.prev_in_use ) )
				node_end_options[ node_end_options.size ] = n.path_end;
			/*else if( n.path_end.pos_info.prev_in_use == self )
				node_end_options[ node_end_options.size ] = n.path_end;
			else
			{
				Print3d( n.path_end.pos_info.prev_in_use.origin, "me", (0,0,1), 1, 3, 100 );
				Print3d( n.path_end.origin, "here", (0,0,1), 1, 3, 100 );
			}*/
		else
		{
			//Print3d( n.path_end.pos_info.in_use.origin, "me", (0,1,0), 1, 3, 100 );
			//Print3d( n.path_end.origin, "here", (0,1,0), 1, 3, 100 );
		}
	}
	
	////prof_end( "SF_get_optimal1" );
	if ( !node_end_options.size )
	{
		//prof_end( "SF_get_optimal" );
		return undefined;
	}
	
	//prof_end( "SF_get_optimal" );
	// Grab the closest target and place in self.tank_target
	manage_closest_target();
	//prof_begin( "SF_get_optimal" );
	
	if( !isDefined( self.tank_move_target ) )
	{
		//prof_end( "SF_get_optimal" );
		return undefined;
	}	
	
	//prof_begin( "SF_get_optimal2" );
	// Sort start nodes by their end nodes distance from player
	node_end_options 	= SortByDistance( node_end_options, self.tank_move_target.origin );
	//node_end_options 	= array_sort_by_handler_parameter( node_end_options, ::distance_squared_from_player_loc, self.tank_move_target );
	
	current_node = pos_info.nodes_start[ 0 ];
	tank_dist_squared_player = DistanceSquared( current_node.origin, self.tank_move_target.origin );

	optimal_node = undefined;
	optimal_node_dist_squared_player = undefined;
	
	foreach ( node_end in node_end_options )
	{
		player_dist_squared_node_end = DistanceSquared( self.tank_move_target.origin, node_end.origin );
		
		// Nodes super close to the player are ignored
		if ( player_dist_squared_node_end < CONST_MIN_DIST_FROM_PLAYER_SQUARED )
			continue;
		
		tank_dist_squared_node_end = DistanceSquared( current_node.origin, node_end.origin );
		
		// Ignore nodes on the other side of the player from the tank
		if ( player_dist_squared_node_end < tank_dist_squared_node_end && tank_dist_squared_player < tank_dist_squared_node_end )
			continue;
		
		// Ignore nodes that do not have line of sight on the target
//		if ( IsDefined( self.tank_move_target ) && !( self.tank_move_target SightConeTrace( node_end.origin + (0, 0, 64) ) ) )
//		    continue;
		
		if ( !IsDefined( optimal_node ) || player_dist_squared_node_end < optimal_node_dist_squared_player )
		{
			optimal_node = node_end;
			optimal_node_dist_squared_player = player_dist_squared_node_end;
		}
	}

	//prof_end( "SF_get_optimal2" );
	
	// Return if no node is available.
	if ( !IsDefined( optimal_node ) )
	{
		self.numwaits++;

		//prof_end( "SF_get_optimal" );
		return undefined;
//		if( self.numwaits > 2 )
//		{
//			if( get_optimal_next_path_los_check( current_node ) )
//				return undefined;
//			else // promote movement
//			{
//				optimal_node 	= node_end_options[ 0 ];
//				self.numwaits 	= 0;
//				return optimal_node.path_start;
//			}
//		}
//		else
//		{
//			optimal_node 	= node_end_options[ 0 ];
//			self.numwaits 	= 0;
//			return optimal_node.path_start;	
//		}
	}
	
	// If the tank is stationary after two checks, move it.
	if( IsDefined( self.numwaits ) && self.numwaits >= 5 )
	{
		self.numwaits = 0;
		//prof_end( "SF_get_optimal" );
		return optimal_node.path_start;
	}
	
	// Check to see if the current postion is better than the chosen node.
	// This could be worked in earlier to allow for an early out
	if ( tank_dist_squared_player > CONST_MIN_DIST_FROM_PLAYER_SQUARED && ( !IsDefined( optimal_node ) || optimal_node_dist_squared_player > tank_dist_squared_player ) )
	{
		self.numwaits++;
		//prof_end( "SF_get_optimal" );
		return undefined;
	}
	
	self.numwaits = 0;
	//prof_end( "SF_get_optimal" );
	return optimal_node.path_start;
}

get_optimal_next_path_los_check( currentNode )
{
	self endon( "death" );
	
	level.inc 			= 0;
	self.shortestdepth 	= 0;
	
	// find the exit node
	array 			= [];
	array[ 0 ] 		= currentNode;
	//Print3d( currentNode.origin, "c", (0,0,1), 1, 3, 1000 );
	nodeLOSArray 	= [];
	nodeLOSArray 	= self get_optimal_next_path_recursive( array );
		
	if( !IsDefined( nodeLOSArray ) )
	{
		//IPrintLnBold( "Undefined Array" );
		self.numwaits++;
		wait .5;
		return false;
	}
	   	
	if( nodeLOSArray.size == 0 )
	{
		//IPrintLnBold( "No Array" );
		self.numwaits++;
		wait .5;
		return false;
	}
	
	//IPrintLnBold( "Array! " + nodeLOSArray.size );
		
	wait .05;
	
	// move to LOS node
	nodeLOS 	= undefined;
	isfirstnode = true;
	foreach( node in nodeLOSArray )
	{		
		nodeLOS = node;
		if( isDefined( node.path_start ) && isDefined( node.path_start.path_end ) )
			if( !IsDefined( node.path_start.path_end.pos_info.in_use ) ||
			    ( IsDefined( node.path_start.path_end.pos_info.in_use ) &&
			      node.path_start.path_end.pos_info.in_use != self ) )
				if( !IsDefined( node.path_start.path_end.pos_info.prev_in_use ) )
				{
					self thread manage_position_in_use_loc( node.path_start.path_end );
					
					switch_node_now( self, node.path_start );
					cscriptlinkto 	= StrTok( node.path_start.script_linkname, "_" );
					comparelinkto 	= cscriptlinkto[1];
					//Print3d( node.path_start.origin, comparelinkto, (0,0,1), 1, 3, 1000 );
				}
				else if( node.path_start.path_end.pos_info.prev_in_use == self )
				{
					self thread manage_position_in_use_loc( node.path_start.path_end );
					
					switch_node_now( self, node.path_start );
					cscriptlinkto 	= StrTok( node.path_start.script_linkname, "_" );
					comparelinkto 	= cscriptlinkto[1];
					//Print3d( node.path_start.origin, comparelinkto, (0,0,1), 1, 3, 1000 );
				}
				else
					continue;
			else
				continue;
		else
			continue;
		
		wait .05;
		self waittill( "reached_end_node" );
		wait .05;
	}
	
	wait .5;
	
	self.numwaits = 0;
	return true;
}

get_optimal_next_path_recursive( array )
{
	shortestArray = [];
	
	if( self.tank_move_target SightConeTrace( array[ array.size - 1 ].origin + (0, 0, 64) ) && 
	    !IsDefined( array[ array.size - 1 ].pos_info.in_use ) )
	{
		if( self.shortestdepth > array.size || self.shortestdepth == 0)
			self.shortestdepth = array.size;
		return array;
	}
	else if( array.size > 4 || IsDefined( array[ array.size - 1 ].pos_info.in_use ) ) 	// prevent infinite recursion
	{
		return shortestArray;  	// returns an empty array
	}
	else
	{
		lastNode = array[ array.size - 1 ];
		foreach ( n in lastNode.pos_info.nodes_start )
		{
			if( !array_contains_script_linkto( array, n.path_end ) )
			{			
				newarray 					= array;
				newarray[ newarray.size ] 	= n.path_end;
				holderArray 				= get_optimal_next_path_recursive( newarray );
			
				if( holderArray.size == self.shortestdepth ) // || array.size == 0 ) )
				{
					shortestArray	= holderArray;

					//level.inc++;
					//Print3d( n.origin, 			level.inc, (1,0,0), 1, 3, 1000 );
					//level.inc++;
					//Print3d( n.path_end.origin, level.inc, (0,1,0), 1, 3, 1000 );	
				}
			}
		}
	}
	
	return shortestArray;
}


/*
=============
///ScriptDocBegin
"Name: array_sort_by_handler( <array> , <compare_func> )"
"Summary: Returns the sorted version of the passed array according to the passed function handler. Exchange sort is used to order the array. Items in the array are compared using the passed compare_func"
"Module: Array"
"CallOn: "
"MandatoryArg: <array>: Array to be sorted"
"MandatoryArg: <compare_func>: Function that returns a value that useable with the comparison operator, specifically the less than operator: <"
"Example: vehicle_nodes = array_sort_by_handler( vehicle_nodes, ::distance_from_player )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
array_sort_by_handler_parameter( array, compare_func, parameter )
{
	AssertEx( IsDefined( array ), "Array not defined." );
	AssertEx( IsDefined( compare_func ), "Compare function not defined." );
	
	if( IsDefined( self ) )
	for ( i = 0; i < array.size - 1; i++ )
	{
			if( IsDefined( self ) && IsDefined( array[ i ] ) )
		for ( j = i + 1; j < array.size; j++ )
		{
					if( IsDefined( self ) && IsDefined( array[ j ] ) && IsDefined( array[ i ] ) )
			if ( array[ j ] [[ compare_func ]](parameter) < array[ i ] [[ compare_func ]](parameter) )
			{
				ref = array[ j ];
				array[ j ] = array[ i ];
				array[ i ] = ref;	
			}
		}
	}
	
	return array;
}

distance_squared_from_player_loc( target )
{
	return DistanceSquared( self.origin, target.origin );
}

get_hinds_enemy_active()
{
	return GetEntArray( "lockon_targets", "script_noteworthy" );
}

manage_closest_target()
{
	//prof_begin( "SF_manage_c" );
	self endon( "death" );
	
	if( IsDefined( self.tank_target ) && self.tank_target.classname == "script_vehicle_corpse" )
	{
		self.tank_target = undefined;			
	}
	
	if( IsDefined( self.tank_move_target ) && self.tank_move_target.classname == "script_vehicle_corpse" )
	{
		self.tank_move_target = undefined;			
	}
	
	enemies = [];
	
	if ( self.script_team == "allies" )
	{
		if ( IsDefined( level.enemytanks ) && level.enemytanks.size )
		{
			enemies = array_combine( enemies, level.enemytanks );
			hinds 	= get_hinds_enemy_active();
			if( IsDefined( hinds ) )
				enemies = array_combine( enemies, hinds );
		}
		
		if ( IsDefined( level.enemygazs )  && level.enemygazs.size )
		{
			enemies = array_combine( level.enemygazs, enemies );
		}
		
		manage_closest_target_ally( enemies );
	}
	else if ( self.script_team == "axis" )
	{
		enemies = array_insert( level.allytanks, level.playertank, level.allytanks.size );
		
		edistance 				= DistanceSquared( level.playertank.origin, self.origin );
		//self.tank_target		= level.playertank;
		self.tank_move_target	= level.playertank;
		
		manage_closest_target_axis( enemies );
	}
	else
	{
		AssertMsg( "Invalid tank team: " + self.team );
	}
	
	//prof_end( "SF_manage_c" );
}

manage_closest_target_ally( enemies )
{
	
	enemies = clean_tank_array( enemies );
	
	//prof_begin( "SF_manage_c_ally" );
	
	edistance = 1000000000;
	
	if ( enemies.size && IsDefined( self ) )
	{
		newenemies 	= SortByDistance( enemies, self.origin );
		//newenemies 	= array_sort_by_handler_parameter( enemies, ::distance_squared_from_player_loc, self );
		if( IsDefined( newenemies ) )
			foreach( enemy in newenemies )
		{
				//prof_begin( "SF_manage_c_ally1" );
			if( IsDefined( enemy ) )
			{
				newdistance		= DistanceSquared( enemy.origin, self.origin );
				playerdistance 	= DistanceSquared( enemy.origin, level.player.origin );
				
				if( newdistance < 1000000 ) // Within 1000 units of ally
				{
					if( newdistance < edistance && IsDefined( enemy ) && enemy.classname != "script_vehicle_corpse" &&
					   self.classname != "script_vehicle_corpse" )
					{
						edistance = newdistance;
						self.tank_move_target = enemy;
							//prof_begin( "SF_manage_c_ally2" );
						if( enemy SightConeTrace( self.origin + (0, 0, 32), self ) )
							self.tank_target = enemy;
							//prof_end( "SF_manage_c_ally2" );
					}
				}
				else // Otherwise, target enemies closer to player
				{
					if( playerdistance < edistance && IsDefined( enemy ) && enemy.classname != "script_vehicle_corpse" &&
					   self.classname != "script_vehicle_corpse" )
					{
						edistance = playerdistance;
						self.tank_move_target = enemy;
							//prof_begin( "SF_manage_c_ally2" );
						if( enemy SightConeTrace( self.origin + (0, 0, 32), self ) )
							self.tank_target = enemy;
							//prof_end( "SF_manage_c_ally2" );
					}
				}
			}
				//prof_end( "SF_manage_c_ally1" );
		}
	}
	//prof_end( "SF_manage_c_ally" );
}

manage_closest_target_axis( enemies )
{
	
	enemies = clean_tank_array( enemies );
	
	//prof_begin( "SF_manage_c_axis" );
	
	edistance = 1000000000;
	
	if ( enemies.size && IsDefined( self ) )
	{
		newenemies 	= SortByDistance( enemies, self.origin );
//		newenemies 	= array_sort_by_handler_parameter( enemies, ::distance_squared_from_player_loc, self );
		if( IsDefined( newenemies ) )
			foreach( enemy in newenemies )
		{
				//prof_begin( "SF_manage_c_axis1" );
			if( IsDefined( enemy ) )
			{
				newdistance = DistanceSquared( enemy.origin, self.origin );
				if( newdistance < edistance && IsDefined( enemy ) && enemy.classname != "script_vehicle_corpse" &&
				   self.classname != "script_vehicle_corpse" )
				{
					edistance = newdistance;
					self.tank_move_target = enemy;
						//prof_begin( "SF_manage_c_axis2" );
					if( enemy SightConeTrace( self.origin + (0, 0, 32), self ) )
						self.tank_target = enemy;
						//prof_end( "SF_manage_c_axis2" );
				}
			}
				//prof_end( "SF_manage_c_axis1" );
		}
	}
	//prof_end( "SF_manage_c_axis" );
}

manage_position_in_use_loc( endNode )
{
	self notify( "clear_last_position" );
	
	self endon( "death" );
		
	if( IsDefined( endNode.pos_info.in_use ) && endNode.pos_info.in_use != self )
	{
		//AssertMsg( "The tank path end node was already in use." );
		return false;
	}
	
	self thread manage_clear_dead( endNode );
		
	//endNode.pos_info.in_use 		= self;
	//print3d( endNode.origin, self.classname, (1,0,0), 1, 3, 100 );
	
	if( IsDefined( endNode.pos_info.nodes_end ) )
	{	
		foreach( node in endNode.pos_info.nodes_end )
		{
			// Last check to see if someone grabbed the node between your optimal node check.
			if( IsDefined( node.pos_info.in_use ) && node.pos_info.in_use != self )
				return false;
			else
				node.pos_info.in_use 		= self;
			//print3d( node.origin, self.classname, (1,0,0), 1, 3, 100 );
		}
	}
	
	self waittill( "clear_last_position" );
	
	//endNode.pos_info.in_use 		= undefined;
	//print3d( endNode.origin, "0", (1,0,0), 1, 3, 100 );
	//endNode.pos_info.prev_in_use 	= self;
	//print3d( endNode.origin, self.classname, (0,0,1), 1, 3, 100 );
	
	if( IsDefined( endNode.pos_info.nodes_end ) )
	{
		foreach( node in endNode.pos_info.nodes_end )
		{
			node.pos_info.in_use 		= undefined;
			//print3d( node.origin, "0", (1,0,0), 1, 3, 10 );
			node.pos_info.prev_in_use 	= self;
			//print3d( node.origin, self.classname, (0,0,1), 1, 3, 100 );
		}
	}
	
	self waittill( "clear_last_position" );
	
	//endNode.pos_info.prev_in_use 	= undefined;
	//print3d( endNode.origin, "0", (0,0,1), 1, 3, 100 );
	
	if( IsDefined( endNode.pos_info.nodes_end ) )
	{
		foreach( node in endNode.pos_info.nodes_end )
		{
			node.pos_info.prev_in_use 	= undefined;
			//print3d( node.origin, "0", (0,0,1), 1, 3, 100 );
		}
	}
}

manage_clear_dead( endNode )
{
	self waittill( "death" );
	
	//endNode.pos_info.in_use 		= undefined;
	//endNode.pos_info.prev_in_use 	= undefined;
	
	if( IsDefined( endNode.pos_info.nodes_end ) )
	{
		foreach( node in endNode.pos_info.nodes_end )
		{
			node.pos_info.in_use 		= undefined;
			node.pos_info.prev_in_use 	= undefined;
		}
	}
}

manage_switching_vehicle_speed_loc( switch_path )
{
	self endon( "death" );
	
	self notify( "switching_path_speed_update" );
	self endon( "switching_path_speed_update" );
	
	speed = self Vehicle_GetSpeed();
	if( speed == 0 )
		self Vehicle_SetSpeedImmediate( speed, 1 );
	else
		self Vehicle_SetSpeedImmediate( speed, speed );

	next_node = GetVehicleNode( switch_path.target, "targetname" );
	next_node waittillmatch( "trigger", self );
	self ResumeSpeed( 20 );
	
}

generic_tank_dynamic_path_spawner_setup()
{
	array_spawn_function_noteworthy( "generic_tank_dynamic_path_spawner", ::generic_spawn_node_based_enemy_tank );
	array_spawn_function_noteworthy( "generic_tank_dynamic_path_spawner", ::add_to_enemytanks_until_dead );
}

generic_spawn_node_based_enemy_tank()
{
	node_ref = self.spawner get_linked_vehicle_node();
	
	self.origin = node_ref.origin;
	
	self thread init_tank_enemy_loc( node_ref.pos_info.nodes_start[ 0 ] );
}

move_ally_to_mesh( targetname, exitNodeName, exitFlag )
{
	tank = self;
	
	if( !isDefined( exitFlag ) )
		exitFlag = "nostopping";

	tank.exitNodeName = exitNodeName;
	
	endnode 	= getvehiclenode( targetname, "targetname" );
	node_ref 	= endnode get_linked_vehicle_node();
	
	switch_node( tank, endnode, node_ref );
			
	tank thread nav_mesh_pathing( node_ref.pos_info.nodes_start[ 0 ], exitFlag );
}

/***
 * 		DYNAMIC ALLY TANK SPEED
 ***/

CONST_INTRO_ALLIES_ACCEL					 = 25;
CONST_INTRO_ALLIES_DECEL					 = 25;
CONST_INTRO_ALLIES_SPEED_MAX				 = 60;
CONST_INTRO_ALLIES_SPEED_MIN				 = 5;
CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX		 = 2000;
CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX_STOP	 = CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX + 500;
CONST_INTRO_ALLIES_DIST_PLAYER_2D_MIN		 = 500;
CONST_INTRO_ALLIES_DIST_PLAYER_2D_CONTINUE	 = 6000;

/*
=============
///ScriptDocBegin
"Name: tank_relative_speed( <tanks> , <struct_name> , <stopflag_name> )"
"Summary: Setups tank speed relative to the player."
"Module: Entity"
"MandatoryArg: <struct_name>: targetname of struct that is in the destination area. Pass "" to skip."
"MandatoryArg: <stopflag_name>: string for a flag to stop the function. Passing nothing will mean no stopping the function."
"MandatoryArg: <add_distance>: Number to increase or decrease the max stopping distance. Pass 0 to skip."
"MandatoryArg: <add_accel>: Number to increase or decrease the acceleration speed. Pass 0 to skip."
"Example: thread tank_relative_speed( "secondencounter", "allies_stop_canyon", 0, 5 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
tank_relative_speed( struct_name, stopflag_name, add_distance, add_accel, add_speed )
{
	level.player endon( "tank_dismount" );
	
	if( IsDefined( self ) )
	{
		tank = self;
		tank.relative_speed = 1;
	}
	else
		return 0;
	
	if( !IsDefined( struct_name ) || struct_name == "" )
		level.alliedtanktarget = level.playertank;
	else
	{
		target = getstruct( struct_name, "targetname" );
		level.alliedtanktarget = target;
	}
	
	if( IsDefined( stopflag_name ) && stopflag_name != "" )
		thread tank_relative_speed_stop( tank, stopflag_name );
	else
	{
		// placeholder if the player doesn't specify a flag.
		stopflag_name = "nostopping";
	}
	
	if( !IsDefined( add_distance ) )
		add_distance = 0;
		
	if( !IsDefined( add_accel ) )
		add_accel = 0;
	
	if( !IsDefined( add_speed ) )
		add_speed = 0;
	
	playertank = level.playertank;
	
	dist_2d_sqrd_max_stop	= squared( CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX_STOP + add_distance );
	dist_2d_sqrd_max		= squared( CONST_INTRO_ALLIES_DIST_PLAYER_2D_MAX );
	dist_2d_sqrd_min		= squared( CONST_INTRO_ALLIES_DIST_PLAYER_2D_MIN );
	dist_2d_sqrd_continue	= squared( CONST_INTRO_ALLIES_DIST_PLAYER_2D_CONTINUE );
	dist_2d_sqrd_range_diff = dist_2d_sqrd_max - dist_2d_sqrd_min;
	
	AssertEx( dist_2d_sqrd_range_diff > 0, "The difference between the max range and the min distance evaluation should always be positive." );
	
	update_delay = 0.05;
	
	speed_prev = undefined;
	nextnode 	= undefined;
	while ( !flag( stopflag_name ) )
	{
		skip 				 	= 0; // if node speed is less than 30, we want to skip the rest of the loop.
		isNextNodeFlagged 	 	= 0; // if next node is flagged, the code will wait till the flag is hit
		flagtowait 			 	= "";
		dist_2d_sqrd_closest 	= undefined;
		dist_2d_sqrd_atotarget	= undefined;
		dist_2d_sqrd_ptotarget	= undefined;
		
		// Break if tank is dead
		if( !IsDefined( tank ) )
		{
			return;
		}
		
		if( tank.classname == "script_vehicle_corpse" )
		{
			return;
		}	
		
		// Get next node
		if( tank.classname != "script_vehicle_corpse" && IsDefined( tank.currentnode ) && IsDefined( tank.currentnode.target ) )
			if( IsDefined( nextnode ) && self.currentnode.target != nextnode.targetname )
				nextnode = GetVehicleNode( tank.currentnode.target, "targetname" );
			else if( !IsDefined( nextnode ) )
			nextnode = GetVehicleNode( tank.currentnode.target, "targetname" );
		
		// Prechecks to see what the tank speed should be
		
		// tell the tank to stop relative tank movement if next node has a flag wait 
		// or if the speed is less than 30.
		if( isdefined( nextnode ) )
		{
			if ( isdefined( nextnode.script_flag_wait ) && !flag( nextnode.script_flag_wait ) )
			{
		   		flagtowait = nextnode.script_flag_wait;
				isNextNodeFlagged = 1;
			}
		   	
		   	if( IsDefined( nextnode.speed ) && nextnode.speed <= 30 ) 
		   		skip = 1;
		}
		
		// If player distance to target is greater than the tank's, the tank is ahead.
		dist_2d_sqrd_atotarget	 = Distance2DSquared( level.alliedtanktarget.origin, tank.origin );
		dist_2d_sqrd_ptotarget	 = Distance2DSquared( level.alliedtanktarget.origin, playertank.origin );
		
		ahead = 0;
		if( dist_2d_sqrd_atotarget < dist_2d_sqrd_ptotarget )
		{
		   ahead = 1;
		}
		else if( dist_2d_sqrd_atotarget > dist_2d_sqrd_ptotarget + (dist_2d_sqrd_min * 2) ) //If player is min distance units ahead,
		{
			skip = 0; // Ignore speeds less than 30 if tank is behind.	
			//isNextNodeFlagged = 0; // Ignore flags if tank is behind. This could be bad, commenting out.
		}
		
		// Calculate values distance between player and tank.
		if ( !IsDefined( dist_2d_sqrd_closest ) )
		{
			dist_2d_sqrd_closest 	 = Distance2DSquared( playertank.origin, tank.origin );
		}
		else
		{
			dist_2d_sqrd_compare = Distance2DSquared( playertank.origin, tank.origin );
			if ( dist_2d_sqrd_compare < dist_2d_sqrd_closest )
			{
				dist_2d_sqrd_closest 	 = dist_2d_sqrd_compare;
			}
		}
		
		// Manage speed after all prechecks are done.
		speed = undefined;
		
		// Don't do anything if the player is front of tank.
		tank proxmity_check_stop_relative( isNextNodeFlagged, skip );
		
		// Tank should resume normal path movement until the flag is triggered
		if( isNextNodeFlagged )
		{
			if( tank.classname != "script_vehicle_corpse" )
			{
				//if( !IsDefined( tank.flagtowait ) )
				if( !IsDefined( tank.isObstructed ) )
					tank ResumeSpeed( CONST_INTRO_ALLIES_ACCEL + add_accel );
				
				//println( tank.script_friendname + " : script_flag " + tank.veh_speed );
					
				tank.flagtowait = flagtowait;
			}
		}
						
		// Normal movement if flagtowait exists on the tank and is not set.
		if( IsDefined( tank.flagtowait ) )
		{
			// If the flag in flagtowait is set, allow the tank to continue on it's path.
			if( flag( tank.flagtowait ) )
				tank.flagtowait = undefined;
		}
		else if( !IsDefined( tank.isObstructed ) ) // Skip movement if tank is obstructed by player
		{
			// Skip everything if the player is on a node with a less than 30 speed.
			if( !skip )
			{
				if( tank.classname != "script_vehicle_corpse" )
				{
					// If the allies are really far ahead tell them to stop and wait (speed of 0)
					if ( dist_2d_sqrd_closest >= dist_2d_sqrd_max_stop && ahead )
					{
						if( dist_2d_sqrd_closest < dist_2d_sqrd_continue )
					   		speed = 0;
					}
					else if ( ahead ) // if ahead but not at max, scale speed.
					{
						dist_2d_sqrd = clamp( dist_2d_sqrd_closest, dist_2d_sqrd_min, dist_2d_sqrd_max );
						
						// Ratio is subtracted from 1 because the closer the player the faster
						// the tanks need to go
						ratio = 1 - ( dist_2d_sqrd - dist_2d_sqrd_min ) / dist_2d_sqrd_range_diff;
						
						speed = CONST_INTRO_ALLIES_SPEED_MIN + ( CONST_INTRO_ALLIES_SPEED_MAX + add_speed - CONST_INTRO_ALLIES_SPEED_MIN ) * ratio;
					}
					else // handles the case the tank is behind
					{
						//dist_2d_sqrd = clamp( dist_2d_sqrd_closest, dist_2d_sqrd_min, dist_2d_sqrd_max );
						
						// Go your fastest to catch up if behind min distance.
						//if ( dist_2d_sqrd > dist_2d_sqrd_min )
						//{
							speed = CONST_INTRO_ALLIES_SPEED_MAX + add_speed;
						//}
						/*else // Continue standard logic when closer than min.
						{
							ratio = 1 - ( dist_2d_sqrd - dist_2d_sqrd_min ) / dist_2d_sqrd_range_diff;
							speed = CONST_INTRO_ALLIES_SPEED_MIN + ( CONST_INTRO_ALLIES_SPEED_MAX + add_speed - CONST_INTRO_ALLIES_SPEED_MIN ) * ratio;
						}*/
					}
					
					if( IsDefined( speed ) )
					{
						percent = undefined;
						if( IsDefined( speed_prev ) )
							percent =  Abs( speed - speed_prev ) / max( speed_prev, 0.001 );
						
						// Adjust the tanks speed only if there was an N% change in speed or if tank should stop
						if ( ( !IsDefined( speed_prev ) || ( IsDefined( percent ) && percent > 0.1 )
							  || speed == 0 ) && !IsDefined( tank.isObstructed ) )
						{
							//println( tank.script_friendname + " : " + speed );
							tank Vehicle_SetSpeed( speed, CONST_INTRO_ALLIES_ACCEL + add_accel, CONST_INTRO_ALLIES_DECEL );
							speed_prev = speed; 
						} 
						else if ( speed == CONST_INTRO_ALLIES_SPEED_MAX + add_speed && !IsDefined( tank.isObstructed ) )
						{
							//println( tank.script_friendname + " : " + speed );
							tank Vehicle_SetSpeed( speed, CONST_INTRO_ALLIES_ACCEL + add_accel, CONST_INTRO_ALLIES_DECEL );
							speed_prev = speed; 
						}
					}
				}
			}
			else 
			{
				if( tank.classname != "script_vehicle_corpse" && !IsDefined( tank.isObstructed ) )
				{
					// if the tank should stop due to distance,
					// then stopping overrides resuming speed if going slower than 30.
					if ( dist_2d_sqrd_closest >= dist_2d_sqrd_max_stop && ahead )
					{
						if( dist_2d_sqrd_closest < dist_2d_sqrd_continue )
						{
					   		speed = 0;
							//println( tank.script_friendname + " : stop " + tank.veh_speed );
							tank Vehicle_SetSpeed( speed, CONST_INTRO_ALLIES_ACCEL + add_accel, CONST_INTRO_ALLIES_DECEL );
							speed_prev = speed; 
						}
						else
						{
							tank ResumeSpeed( CONST_INTRO_ALLIES_ACCEL +add_accel );
							//println( tank.script_friendname + " : resume " + tank.veh_speed );
						}
					}
					else
					{
						tank ResumeSpeed( CONST_INTRO_ALLIES_ACCEL + add_accel);
						//println( tank.script_friendname + " : resume " + tank.veh_speed );
					}
				}
			}
		}
		wait update_delay;
	}
	
	if( IsDefined( tank ) )
	{
		tank ResumeSpeed( CONST_INTRO_ALLIES_ACCEL );
		tank.relative_speed = undefined;
	}
}

tank_relative_speed_stop( tank, stopflag_name )
{
	flag_wait( stopflag_name );
	
	if( !IsDefined( tank ) )
	{
		return;
	}
	
	if( tank.classname == "script_vehicle_corpse" )
	{
		return;
	}
	
	tank ResumeSpeed( CONST_INTRO_ALLIES_ACCEL );
}

/*
=============
///ScriptDocBegin
"Name: proxmity_check() deprecated"
"Summary: Check the proxmity of player vehicle. If in path, stop. Run this if not running tank_relative_speed."
"Module: Entity"
"CallOn: A vehicle"
"Example: tank proximity_check_stop( "checkpoint_end" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
proxmity_check_stop_loop( stop_flag, other_vehicle, on_mesh )
{
	//PrintLn("proxmity_check_stop_loop");
	self endon( "death" );
	level.player endon( "tank_dismount" );
	
	if( !isDefined( stop_flag ) || stop_flag == "" )
		stop_flag = "nostopping";
		
	if( !IsDefined( other_vehicle ) || other_vehicle == "" )
		stopVehicle = level.playerTank;
	else
		stopVehicle = other_vehicle;
	
	if( IsDefined( on_mesh ) )
		checkVector = .7;
	else
		checkVector = .98;
	
	nextnode 			= undefined;
	flagtowait 			= undefined;
		
	while( !flag( stop_flag ) )
	{
		////prof_begin( "SF_proximity_check" );
		isNextNodeFlagged 	= 0;
		
		// Clean tank arrays
		if( !IsDefined( self ) )
		{
			////prof_end( "SF_proximity_check" );
			return;
		}
		
		if( self.classname == "script_vehicle_corpse" )
		{
			////prof_end( "SF_proximity_check" );
			return;
		}	
		
		////prof_begin( "SF_node" );
		if( self.classname != "script_vehicle_corpse" && IsDefined( self.currentnode ) && IsDefined( self.currentnode.target ) )
			if( IsDefined( nextnode ) && self.currentnode.target != nextnode.targetname )
				nextnode = GetVehicleNode( self.currentnode.target, "targetname" );
			else if( !IsDefined( nextnode ) )
			nextnode = GetVehicleNode( self.currentnode.target, "targetname" );
			
		////prof_end( "SF_node" );
		
		////prof_begin( "SF_checks" );
		// Prechecks to see what the tank speed should be
		
		// tell the tank to stop relative tank movement if next node has a flag wait 
		// or if the speed is less than 30.
		if( isdefined( nextnode ) )
		{
			if ( isdefined( nextnode.script_flag_wait ) && !flag( nextnode.script_flag_wait ) )
			{
		   		flagtowait = nextnode.script_flag_wait;
			}
		   	
		   	//if( IsDefined( nextnode.speed ) && nextnode.speed <= 30 ) 
		   	//	skip = 1;
		}
		
		// calculate the velocity vector
		selfVelocity 	 = self Vehicle_GetVelocity();
		if( selfVelocity == ( 0,0,0 ) )
			normalVelocity = AnglesToForward( self.angles );
		else
			normalVelocity = VectorNormalize( selfVelocity );
		
		// calculate the angle vector to the player
		//selfForward			= AnglesToForward( self.angles );
		//normalForward		= VectorNormalize( selfForward );
		//dotForwardVelocity	= VectorDot( normalVelocity, normalForward );
		vectorToPlayer 		= VectorNormalize( stopVehicle.origin - self.origin );
		
		// calculate if the player is in the way of the tank.
		directionVector = VectorDot( normalVelocity, vectorToPlayer ); //abs( VectorDot( normalVelocity, vectorToPlayer ) );
		
		// check to see if vehicle is stopped
		speed 			= self Vehicle_GetSpeed();
				
		////prof_end( "SF_checks" );
		////prof_begin( "SF_speed" );
		// If player is in cone in front of ally,
		if( directionVector >= checkVector )
		{
			distanceToPlayer = distance_2d_squared( stopVehicle.origin, self.origin);
			// check to see how close the ally is to the player
			if( distanceToPlayer <= 1000000 ) 
			{
				// if within 1000 units, stop the vehicle.
//				if( IsDefined( self.script_friendname ) )
//					println( self.script_friendname + " : " + directionVector );
//				else
//					println( self.classname + " : " + directionVector );
				self Vehicle_SetSpeed( 0, CONST_INTRO_ALLIES_ACCEL / 2, CONST_INTRO_ALLIES_DECEL * 10 );
				self.isObstructed = 1;
			}
			else if( distanceToPlayer <= 4000000 ) 
			{
				// if within 2000 units, slow the vehicle.
//				if( IsDefined( self.script_friendname ) )
//					println( self.script_friendname + " : " + directionVector );
//				else
//					println( self.classname + " : " + directionVector );
				self Vehicle_SetSpeed( 10, CONST_INTRO_ALLIES_ACCEL / 2, CONST_INTRO_ALLIES_DECEL * 10 );
				self.isObstructed = 1;
			}
			else if( speed < 5  )
			{
				// if stopped, resume speed unless at flag
				if( !IsDefined( flagtowait ) )
				{
					self ResumeSpeed( 10 );
				}
				else
				{
					if( flag( flagtowait ) )
					{
						flagtowait = undefined;
						self ResumeSpeed( 10 );
					}
				}
				self.isObstructed = undefined;
			}
			else
			{
				self.isObstructed = undefined;
			}
		}
		else if( speed < 5 )
		{
			// if stopped, resume speed unless at flag
			if( !IsDefined( flagtowait ) )
			{
				flagtowait = undefined;
				self ResumeSpeed( 10 );
			}
			else
			{
				if( flag( flagtowait ) )
				{
					flagtowait = undefined;
					self ResumeSpeed( 10 );
				}
			}
			self.isObstructed = undefined;
		}
		else
		{
			self.isObstructed = undefined;
		}
		
		////prof_end( "SF_speed" );
		////prof_end( "SF_proximity_check" );
		wait .25;
	}
}

proxmity_check_stop_relative( isNextNodeFlagged, skip )
{
	self endon( "death" );
	
	// Clean tank arrays
	if( !IsDefined( self ) )
	{
		return;
	}
	
	if( self.classname == "script_vehicle_corpse" )
	{
		return;
	}	

	// check to see if vehicle is stopped
	speed 			= self Vehicle_GetSpeed();
	
	// calculate the velocity vector
	selfVelocity 	= self Vehicle_GetVelocity();
	//thread draw_line_from_ent_to_vec_for_time( self, selfVelocity, 2000, 0, 1, 0, 1 );
	if( speed < 1 )
	{
		selfVelocity 	= self.angles;
		normalVelocity	= AnglesToForward( self.angles );
		//IPrintLnBold( "ZERO " + self.script_friendname);
		//thread draw_line_from_ent_to_vec_for_time( self, selfVelocity, 2000, 0, 1, 0, 1 );
	}
	else
		normalVelocity	 = VectorNormalize( selfVelocity );
	
	//thread draw_line_from_ent_to_vec_for_time( self, selfVelocity, 2000, 1, 0, 0, 1 );
	//thread draw_line_from_ent_to_vec_for_time( self, normalVelocity, 2000, 0, 0, 1, 1 );
	
	// calculate the angle vector to the player
	//selfForward			= AnglesToForward( self.angles );
	//normalForward			= VectorNormalize( selfForward );
	//dotForwardVelocity	= VectorDot( normalVelocity, normalForward );
	vectorToPlayer 		= VectorNormalize( level.playertank.origin - self.origin );
	
	// calculate if the player is in the way of the tank.
	directionVector = VectorDot( normalVelocity, vectorToPlayer );
	//directionVector = VectorDot( selfVelocity, vectorToPlayer );
	
	// check to see if vehicle is stopped
	speed 			= self Vehicle_GetSpeed();

	// If player is in cone in front of ally,
	if( directionVector >= .95 )
	{
		distanceToPlayer = distance_2d_squared( level.playertank.origin, self.origin);
		// check to see how close the ally is to the player
		if( distanceToPlayer <= 4000000 ) 
		{
			// if within 1000 units, stop the vehicle.
			println( self.script_friendname + " : Vector " + directionVector );
			self Vehicle_SetSpeed( 0, CONST_INTRO_ALLIES_ACCEL / 2, CONST_INTRO_ALLIES_DECEL * 10 );
			self.isObstructed = 1;
		}
		else if( distanceToPlayer <= 9000000 ) 
		{
			// if within 2000 units, slow the vehicle.
			println( self.script_friendname + " : Vector " + directionVector );
			self Vehicle_SetSpeed( 10, CONST_INTRO_ALLIES_ACCEL / 2, CONST_INTRO_ALLIES_DECEL * 10 );
			self.isObstructed = 1;
		}
		else if( IsDefined( self.isObstructed ) && speed < 5  )
		{
			// if stopped, resume speed unless at flag
			if( !isNextNodeFlagged )
			{
				if( skip )
				{
					self ResumeSpeed( 10 );
				}
			}
			self.isObstructed = undefined;
		}
		else
		{
			self.isObstructed = undefined;
		}
	}
	else if( IsDefined( self.isObstructed ) && speed < 5 )
	{
		// if stopped, resume speed unless at flag
		if( !isNextNodeFlagged )
		{
			if( skip )
			{
				self ResumeSpeed( 10 );
			}
		}
		self.isObstructed = undefined;
	}
	else
	{
		self.isObstructed = undefined;
	}
}

/*** GAZ CODE ***/


generic_gaz_dynamic_path_spawner_setup()
{
	array_spawn_function_noteworthy( "generic_gaz_dynamic_path_spawner", ::gaz_spawn_setup );
	array_spawn_function_noteworthy( "generic_gaz_dynamic_path_spawner", ::generic_spawn_node_based_enemy_gaz );
}

generic_gaz_spawner_setup()
{
	array_spawn_function_noteworthy( "generic_gaz_spawner", ::gaz_spawn_setup );
}

generic_spawn_node_based_enemy_gaz()
{
	node_ref = self.spawner get_linked_vehicle_node();
	
	self.origin = node_ref.origin;
	
	wait .05;
	
	self thread nav_mesh_pathing( node_ref.pos_info.nodes_start[ 0 ] );
}

gaz_spawn_setup()
{
	self thread gaz_kill();
	self thread gaz_damage_watcher();
	self thread add_to_enemygazs_until_dead();
	//self thread gaz_death_trigger();
	self thread trigger_kill_gazs();
	
	if( IsDefined( self.targetname ) && IsSubStr( self.targetname, "complex" ) )
		self Vehicle_SetSpeed( 60, 25, 25 );
	
	self.numwaits 	= 0;
}

CONST_INTRO_GAZ_ACCEL					 = 25;
CONST_INTRO_GAZ_DECEL					 = 25;
CONST_INTRO_GAZ_SPEED_MAX				 = 85;
CONST_INTRO_GAZ_SPEED_MIN				 = 20;
CONST_INTRO_GAZ_DIST_PLAYER_2D_MAX		 = 6000;
CONST_INTRO_GAZ_DIST_PLAYER_2D_MAX_STOP	 = CONST_INTRO_GAZ_DIST_PLAYER_2D_MAX;
CONST_INTRO_GAZ_DIST_PLAYER_2D_MIN		 = 1000;
CONST_INTRO_GAZ_DIST_PLAYER_2D_CONTINUE	 = 6000;

gaz_relative_speed( struct_name, stopflag_name )
{
	self endon( "death" );
	
	gaz = self;
	
	if( !IsDefined( struct_name ) || struct_name == "" )
		level.alliedtanktarget = level.player;
	else
	{
		target = getstruct( struct_name, "targetname" );
		level.alliedtanktarget = target;
	}
	
	if( IsDefined( stopflag_name ) )
		thread gaz_relative_speed_stop( gaz, stopflag_name );
	else
	{
		// placeholder if the player doesn't specify a flag.
		stopflag_name = "nostopping";
	}
	
	playertank = level.playertank;
	
	dist_2d_sqrd_max_stop	= squared( CONST_INTRO_GAZ_DIST_PLAYER_2D_MAX_STOP );
	dist_2d_sqrd_max		= squared( CONST_INTRO_GAZ_DIST_PLAYER_2D_MAX );
	dist_2d_sqrd_min		= squared( CONST_INTRO_GAZ_DIST_PLAYER_2D_MIN );
	dist_2d_sqrd_continue	= squared( CONST_INTRO_GAZ_DIST_PLAYER_2D_CONTINUE );
	dist_2d_sqrd_range_diff = dist_2d_sqrd_max - dist_2d_sqrd_min;
	
	AssertEx( dist_2d_sqrd_range_diff > 0, "The difference between the max range and the min distance evaluation should always be positive." );
	
	update_delay = 0.25;
	
	speed_prev = undefined;
	while ( !flag( stopflag_name ) )
	{
		skip 				 	= 0; // if node speed is less than 30, we want to skip the rest of the loop.
		isNextNodeFlagged 	 	= 0; // if next node is flagged, the code will wait till the flag is hit
		flagtowait 			 	= "";
		nextnode 			 	= undefined;
		dist_2d_sqrd_closest 	= undefined;
		dist_2d_sqrd_atotarget	= undefined;
		dist_2d_sqrd_ptotarget	= undefined;
		
		// Clean tank arrays
		if( !IsDefined( gaz ) )
		{
			break;
		}
		
		if( gaz.classname == "script_vehicle_corpse" )
		{
			break;
		}	
		
		if( gaz.classname != "script_vehicle_corpse" && IsDefined( gaz.currentnode.target ) )
			nextnode = GetVehicleNode( gaz.currentnode.target, "targetname" );
		
		// Prechecks to see what the tank speed should be
		
		// If player distance to target is greater than the gaz's, the gaz is ahead.
		dist_2d_sqrd_atotarget	 = Distance2DSquared( level.alliedtanktarget.origin, gaz.origin );
		dist_2d_sqrd_ptotarget	 = Distance2DSquared( level.alliedtanktarget.origin, playertank.origin );
		
		ahead = 0;
		if( dist_2d_sqrd_atotarget < dist_2d_sqrd_ptotarget )
		{
		   ahead = 1;
		}
		
		// Calculate values distance between player and gaz.
		if ( !IsDefined( dist_2d_sqrd_closest ) )
		{
			dist_2d_sqrd_closest 	 = Distance2DSquared( playertank.origin, gaz.origin );
		}
		else
		{
			dist_2d_sqrd_compare = Distance2DSquared( playertank.origin, gaz.origin );
			if ( dist_2d_sqrd_compare < dist_2d_sqrd_closest )
			{
				dist_2d_sqrd_closest 	 = dist_2d_sqrd_compare;
			}
		}
		
		// Manage speed after all prechecks are done.
		speed = undefined;
		
		if( gaz.classname != "script_vehicle_corpse" )
		{
			// If the allies are really far ahead tell them to stop and wait (speed of 0)
			if ( dist_2d_sqrd_closest >= dist_2d_sqrd_max_stop && ahead )
			{
				if( dist_2d_sqrd_closest < dist_2d_sqrd_continue )
			   		speed = CONST_INTRO_GAZ_SPEED_MIN;
			}
			else if ( ahead ) // if ahead but not at max, scale speed.
			{
				dist_2d_sqrd = clamp( dist_2d_sqrd_closest, dist_2d_sqrd_min, dist_2d_sqrd_max );
				
				// Ratio is subtracted from 1 because the closer the player the faster
				// the tanks need to go
				ratio = 1 - ( dist_2d_sqrd - dist_2d_sqrd_min ) / dist_2d_sqrd_range_diff;
				
				speed = CONST_INTRO_GAZ_SPEED_MIN + ( CONST_INTRO_GAZ_SPEED_MAX - CONST_INTRO_GAZ_SPEED_MIN ) * ratio;
			}
			else // handles the case the tank is behind
			{
				speed = CONST_INTRO_GAZ_SPEED_MAX;
			}
			
			if( IsDefined( speed ) )
			{
				percent = undefined;
				if( IsDefined( speed_prev ) )
					percent =  Abs( speed - speed_prev ) / max( speed_prev, 0.001 );
				
				// Adjust the tanks speed only if there was an N% change in speed or if tank should stop
				if ( ( !IsDefined( speed_prev ) || ( IsDefined( percent ) && percent > 0.1 ) ) )
				{
					//println( gaz.script_friendname + " : " + speed );
					gaz Vehicle_SetSpeed( speed, CONST_INTRO_GAZ_ACCEL, CONST_INTRO_GAZ_DECEL );
					speed_prev = speed; 
				} 
				else if ( speed == CONST_INTRO_GAZ_SPEED_MAX )
				{
					//println( gaz.script_friendname + " : " + speed );
					gaz Vehicle_SetSpeed( speed, CONST_INTRO_GAZ_ACCEL, CONST_INTRO_GAZ_DECEL );
					speed_prev = speed; 
				}
			}
		}
		wait update_delay;
	}
	
	if( IsDefined( gaz ) && gaz.classname != "script_vehicle_corpse")
	{
		gaz ResumeSpeed( CONST_INTRO_GAZ_ACCEL );
	}
}

gaz_relative_speed_stop( gaz, stopflag_name )
{
	flag_wait( stopflag_name );
	
	if( IsDefined( gaz ) && gaz.classname != "script_vehicle_corpse")
	{
		gaz ResumeSpeed( CONST_INTRO_GAZ_ACCEL );
	}
}

add_to_enemygazs_until_dead()
{
	level.enemygazs = array_add( level.enemygazs, self );
	
	self waittill( "death" );
	
	if( IsDefined( self ) )
	{
		level.enemygazs = array_remove( level.enemygazs, self );
	}
}

gaz_damage_watcher()
{
	self endon( "death" );
	
	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		if( IsDefined( type ) )
		{
			type = ToLower( type );
			
			if ( ( type == "mod_projectile" ) || ( type == "mod_projectile_splash" ) )
			{
				if( amount > 150 )
					self kill();
			}
		}
	}
}

gaz_kill()
{
	self waittill( "death" );
	
	if( IsDefined( self ) )
	{
		self SetContents( 0 );
		
		wait RandomFloatRange( 0.25, 1.0 );
		
		if( IsDefined( self ) )
			PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin );
		wait .05;
		if( IsDefined( self ) )
			self delete();
	}
}

//gaz_death_trigger()
//{
//	while( 1 )
//	{
//		self waittill( "veh_collision", other );
//		
//		//wait 1;
//		
//		//self waittill( "veh_collision", other );
//		
//		self PlaySound( "scn_hamburg_npc_tank_crush1" );
//		
//		PlayFX( level._effect[ "vehicle_tank_crush" ], self.origin, AnglesToForward( self.angles ), AnglesToUp( self.angles ) );
//		
//		self kill();
//	}
//}

gaz_crushable_setup()
{
	gaz_crush_triggers = GetEntArray( "gaz_crush_trigger", "targetname" );
	
	array_thread( gaz_crush_triggers, ::gaz_crush_trigger_wait );
}

gaz_crush_trigger_wait()
{
	gaz = GetEnt( self.target, "targetname" );
	
	gaz_targets = GetEntArray( gaz.target, "targetname" );
	
	gaz_crush_vehicle_clip = undefined;
	gaz_crush_nosight_clip = undefined;
		
	foreach( gaz_target in gaz_targets )
	{
		if( IsDefined( gaz_target.script_parameters ) && gaz_target.script_parameters == "gaz_crush_vehicle_clip" )
		{
			gaz_crush_vehicle_clip = gaz_target;
		}
		else
		{
			gaz_crush_nosight_clip = gaz_target;
			gaz_crush_vehicle_clip linkto( gaz );
		}
	}
	
	self waittill( "trigger" );
	
	gaz PlaySound( "satf_tank_crush" );
	
	PlayFX( level._effect[ "vehicle_tank_crush" ], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
	
	gaz RotatePitch( 10, 0.1 );
	
	gaz_crush_vehicle_clip MoveZ( -16, 0.25 );
	
	wait( 0.1 );
	
	gaz RotatePitch( -10, 0.25 );
	
	gaz MoveZ( -16, 0.25 );
	
	//gaz PlaySound( "barrel_mtl_explode" );
	
	PlayFX( level._effect[ "vehicle_tank_crush" ], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
}

trigger_kill_gazs()
{
	self endon( "Death" );
	
	gaz_trigger = Spawn( "trigger_radius", self.origin, 16, 200, 90 );
	
	gaz_trigger thread update_kill_trigger( self );
	
	while( 1 )
	{
		gaz_trigger waittill("trigger", other);
		
		if( other.script_team == "allies" )
		{
			self thread crush_mobile_gaz();
			gaz_trigger delete();
		}
	}
}

update_kill_trigger( vehicle )
{
	self endon( "death" );
	
	while( IsDefined( vehicle ) )
	{
		self.origin = vehicle.origin;
		//print3d( self.origin, "HERE", (1,0,0), 1, 10, 10 );
		
		wait .01;
	}
	
	self delete();
}

crush_mobile_gaz()
{
	gazcrush = getent( "gaz_crush_clip", "targetname" );
	
	gaz = spawn( "script_model", self.origin );
	gaz.angles = self.angles;
	gaz SetModel( "vehicle_gaz_tigr_base_destroyed_oilrocks" );
	//print3d( self.origin, "gaz", (0,0,1), 1, 10, 1000 );
	col = spawn( "script_model", self.origin );
	col CloneBrushmodelToScriptmodel( gazcrush );
	col.angles = self.angles;
	self delete();
	
	// gaz explosion
	PlayFX( level._effect[ "gazfire"	], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
	PlayFX( level._effect[ "gazexplode" ], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
	PlayFX( level._effect[ "gazcookoff" ], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
	PlayFX( level._effect[ "gazsmfire"	], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
	
	// gaz crunch
	gaz PlaySound( "satf_tank_crush" );
	PlayFX( level._effect[ "vehicle_tank_crush" ], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
	gaz RotatePitch( 10, 0.1 );
	//gaz_crush_vehicle_clip MoveZ( -16, 0.25 );
	
	wait( 0.1 );
	
	gaz RotatePitch( -10, 0.25 );
	gaz MoveZ( -16, 0.25 );
	//gaz PlaySound( "barrel_mtl_explode" );
	PlayFX( level._effect[ "vehicle_tank_crush" ], gaz.origin, AnglesToForward( gaz.angles ), AnglesToUp( gaz.angles ) );
}

//***
//		Destruct funcs
//***

setup_satfarm_chainlink_fence_triggers()
{
	triggers = GetEntArray( "satfarm_chainlink_fence_trigger", "targetname" );
	
	foreach( trigger in triggers )
	{
		trigger thread satfarm_chainlink_fence_trigger_animate();
	}
}

satfarm_chainlink_fence_trigger_animate()
{
	fence = GetEnt( self.target, "targetname" );
	
	fence SetContents( 0 );
	
	self waittill( "trigger", tank );

	tread_dist			 = 64.0;
	tank_velocity_vector = tank Vehicle_GetVelocity();
	speed				 = VectorDot( tank_velocity_vector, AnglesToForward( fence.angles ) );
	                
	if ( speed != 0.0 )
	{
	    rotate_time = tread_dist / abs( speed );
	                    
	    if ( speed > 0 )
	    {
	        fence RotatePitch( 90, rotate_time );
	    }
	    else
	    {
	        fence RotatePitch( -90, rotate_time );
	    }
	}

}

//***
//		Utility funcs
//***

/*
=============
///ScriptDocBegin
"Name: spawn_player_checkpoints( <checkpoint_name> )"
"Summary: Spawn player at checkpoint"
"Module: Entity"
"MandatoryArg: <checkpoint_name>: the name associated with a checkpoint: "array_"; "base_array". "
"Example: spawn_player_checkpoints( "array_" )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/

spawn_player_checkpoint( checkpoint_name, wait_flag )
{
	if( !IsDefined( wait_flag ) )
		wait_flag = undefined;
	
	// init arrays
	level.allytanks 		= [];
	level.herotanks			= [];
	level.othertanks		= [];
	level.enemytanks 		= [];
	level.enemygazs 		= [];
	
	if( checkpoint_name == "tower" || checkpoint_name == "air_strip_secured" || checkpoint_name == "warehouse" )
	{
		player_start = getstruct( checkpoint_name + "_player", "targetname" );
		level.player SetOrigin( player_start.origin );
		level.player SetPlayerAngles( player_start.angles );
	}
	else
	{
		// spawn player
		level.playertank 		= spawn_vehicle_from_targetname( checkpoint_name + "playertank" );
		level.player.tank 		= level.playertank;
		level.playertank.driver = level.player;
		level.playertank notify( "nodeath_thread" );
		level.playertank godon();
		
		// init player
		level.lock_on			= 0;
		level.player.script_team = "allies";
		level.player thread init_chatter();	
		thread init_tank( level.playertank, level.player, wait_flag );
	}
}

/*
=============
///ScriptDocBegin
"Name: spawn_heroes_checkpoint( <checkpoint_name> )"
"Summary: Spawn heroes at checkpoint"
"Module: Entity"
"MandatoryArg: <checkpoint_name>: the name associated with a checkpoint: "array_"; "base_array"."
"Example: spawn_heroes_checkpoint( "array_" )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
spawn_heroes_checkpoint( checkpoint_name )
{
	level.herotanks[ 0 ] = spawn_vehicle_from_targetname_and_drive( checkpoint_name + "hero0" );
	level.bobcat 		 = level.herotanks[ 0 ];
	level.herotanks[ 1 ] = spawn_vehicle_from_targetname_and_drive( checkpoint_name + "hero1" );
	level.badger 		 = level.herotanks[ 1 ];
	
	level.allytanks = array_combine( level.allytanks, level.herotanks );
}

spawn_node_based_enemy_tanks_targetname( targetname )
{	
	spawners = GetEntArray( targetname, "targetname" );
	
	tanks = [];
	
	foreach( spawner in spawners )
	{
		tank = spawner spawn_node_based_enemy_tank();
		tanks = add_to_array( tanks, tank );
	}
	
	return tanks;
}

spawn_node_based_enemy_tank()
{
	spawner = self;
	node_ref = spawner get_linked_vehicle_node();
	
	tank = vehicle_spawn( spawner );
	tank.origin = node_ref.origin;
	
	tank thread init_tank_enemy_loc( node_ref.pos_info.nodes_start[ 0 ] );
	
	return tank;
}

init_tank_enemy_loc( first_node )
{
	self.exitNodeName = "defend_exit_node"; // temp
	self thread npc_tank_combat_init( true );
	self thread nav_mesh_pathing( first_node );
	
}

/*
=============
///ScriptDocBegin
"Name: waittilltanksdead( <tanks> , <num> , <timeoutLength> , <endflag> )"
"Summary: Pass an array of tanks to waittill they are dead."
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <tanks>: array of tanks to wait till they are dead."
"MandatoryArg: <num>: number to kill."
"MandatoryArg: <timeoutLength>: an integer to wait."
"MandatoryArg: <endflag>: flag to end function."
"Example: waittilltanksdead( level.enemytanks, 2, 10, "player_move1" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
waittilltanksdead( tanks, num, timeoutLength, endflag )
{
	i = 0;
	
	if( !IsDefined( tanks ) )
		return 1;
	
	if( !IsDefined( num ) || num == 0 )
		num = tanks.size;
	
	ent = SpawnStruct();
	if ( IsDefined( timeoutLength ) && timeoutLength != 0 )
	{
		ent endon( "thread_timed_out" );
		ent thread waittill_dead_timeout( timeoutLength );
	}
	 
	if( !IsDefined( endflag ) )
	{
		while( tanks.size && num > i )
		{
			foreach( tank in tanks )
			{
				if( IsDefined( tank ) && tank.classname == "script_vehicle_corpse" )
				{
					tanks = array_remove( tanks, tank );
					i++;
				}
				else if ( !IsDefined( tank ) )
				{
					tanks = array_remove( tanks, tank );
					i++;
				}
			}
			wait .05;
		}
	}
	else
	{
		while( tanks.size && num > i && !flag( endflag ) )
		{
			foreach( tank in tanks )
			{
				if( IsDefined( tank ) && tank.classname == "script_vehicle_corpse" )
				{
					tanks = array_remove( tanks, tank );
					i++;
				}
				else if ( !IsDefined( tank ) )
				{
					tanks = array_remove( tanks, tank );
					i++;
				}
			}
			wait .05;
		}
	}
	
	return 1;
}

waittillhelisdead( helis, num, timeoutLength, endflag )
{
	if( !IsDefined( helis ) )
		return 1;
	
	helis = array_removeDead( helis );
	
	if( helis.size > 0 )
	{
		ent = SpawnStruct();
		if ( IsDefined( timeoutLength ) && timeoutLength != 0 )
		{
			ent endon( "thread_timed_out" );
			ent thread waittill_dead_timeout( timeoutLength );
		}

		ent.count = helis.size;
		if ( IsDefined( num ) && num < ent.count )
			ent.count = num;
		array_thread( helis, ::waittill_dead_thread, ent );
		
		if( IsDefined( endflag ) )
		{
			while ( ent.count > 0 && !flag( endflag ) )
				wait .05;
		}
		else
		{
			while ( ent.count > 0 )
				ent waittill( "waittill_dead guy died" );
		}
	}
	
	return 1;
}

radio_dialog_add_and_go( alias, timeout, overlap )
{
	radio_add( alias );
	if ( IsDefined( overlap ) )
		radio_dialogue_overlap( alias );
	else
	radio_dialogue( alias,timeout );
}

char_dialog_add_and_go( alias )
{
	level.scr_sound[ self.animname ][ alias ] = alias;
	self dialogue_queue( alias );
}

isTank()
{
	if ( issubstr( self.classname, "t90" ) )
		return true;
	if ( issubstr( self.classname, "t72" ) )
		return true;
	if ( issubstr( self.classname, "m1a1" ) )
		return true;
	
	return false;
}

clean_tank_array( tanks )
{
	tanks = common_scripts\utility::array_removeUndefined( tanks );
	foreach ( tank in tanks )
	{
		if( tank.classname == "script_vehicle_corpse" )
			tanks = array_remove( tanks, tank );
	}
	return tanks;
}

disable_arrivals_and_exits( onoff )
{
	if( !isdefined( onoff ) )
		onoff = true;
	
	self.disablearrivals = onoff;
	self.disableexits = onoff;
}

/*
=============
///ScriptDocBegin
"Name: switch_node_on_flag( <vehicle> , <flag_name> , <switch_node_name> , <target_node_name> )"
"Summary: "Call to have a vehicle switch paths. Able to have the vehicle wait for a flag before changing paths.	Will do nothing if no node is found for either the switch or target nodes."
"Module: Entity"
"MandatoryArg: <vehicle>: "Vechile that will switch paths"
"MandatoryArg: <flag_name>: "A flag that triggers when the enemy should switch paths. Pass "" if you don't want to wait at a flag"
"MandatoryArg: <switch_node_name>: "The node on the vehicles current path that the switch should happen"
"MandatoryArg: <target_node_name>: "The node the vehicles should switch to on the new path"
"Example: "switch_node_on_flag( badguybike, "enemyswitchpaths1", "switch1", "target1" );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*
switch_node_on_flag( vehicle, flag_name, switch_node_name, target_node_name )
{
	if( IsDefined( flag_name ) && flag_name != "" )
		flag_wait( flag_name );

    switch_node = GetVehicleNode( switch_node_name, "targetname" );
    target_node = GetVehicleNode( target_node_name, "targetname" );
    
    if( !IsDefined( switch_node ) )
        return;
    
    if( !IsDefined( target_node ) )
        return;
    
    vehicle SetSwitchNode( switch_node, target_node );
    vehicle.attachedpath = target_node;
    
    flag_wait( target_node.script_flag_set );
    
	vehicle thread vehicle_paths();
}
*/
//start_new_path( vehicle, flag_name, switch_node_name, target_node_name )
switch_node_on_flag( vehicle, flag_name, switch_node_name, target_node_name )
{
	vehicle endon( "death" );
	
	if( IsDefined( flag_name ) && flag_name != "" )
		flag_wait( flag_name );

    switch_node = GetVehicleNode( switch_node_name, "targetname" );
    target_node = GetVehicleNode( target_node_name, "targetname" );
    
    if( !IsDefined( switch_node ) )
    {
    	AssertMsg( "No switch node found: " + switch_node_name );
        return;
    }
    
    if( !IsDefined( target_node ) )
    {
    	AssertMsg( "No target node found: " + target_node_name );
        return;
    }
    
    flag_wait( switch_node.script_flag_set );
    
	vehicle.attachedpath = undefined;
    vehicle notify( "newpath" );
    vehicle thread vehicle_paths( target_node );
    vehicle StartPath( target_node );
    vehicle Vehicle_SetSpeed( 45, 30, 30 ); //needed to get the vehicle moving
    vehicle ResumeSpeed( 30 );
}

switch_node( vehicle, switch_node, target_node )
{
	vehicle endon( "death" );
	
    if( !IsDefined( switch_node ) )
        return;
    
    if( !IsDefined( target_node ) )
        return;
    
    flag_wait( switch_node.script_flag_set );
    
	vehicle.attachedpath = undefined;
    vehicle notify( "newpath" );
    vehicle thread vehicle_paths( target_node );
    vehicle StartPath( target_node );
    vehicle Vehicle_SetSpeed( 45, 30, 30 ); //needed to get the vehicle moving
    vehicle ResumeSpeed( 30 );
}

switch_node_now( vehicle, target_node )
{
	vehicle endon( "death" );
	
    if( !IsDefined( target_node ) )
        return;
    
	vehicle.attachedpath = undefined;
    vehicle notify( "newpath" );
    vehicle thread vehicle_paths( target_node );
    vehicle StartPath( target_node );
}

/*** Missile Overlay ***/

/*
 * Init the targeting effects
 */
reconuavinit()
{
	level.uav_sort = -5;
	level.uav_fontscale = 1.25;
	level.uav_fake_elevation = 16500 * 12;
	
	PrecacheShader( "gasmask_overlay_delta2" );
	PrecacheShader( "uav_crosshair" );
	PrecacheShader( "uav_vertical_meter" );
	PrecacheShader( "uav_horizontal_meter" );
	PreCacheShader( "overlay_grain" );
	PrecacheShader( "uav_arrow_up" );
	PrecacheShader( "uav_arrow_left" );
	PrecacheShader( "ac130_thermal_overlay_bar" );
	PreCacheShader( "dpad_killstreak_remote_uav" );
	PreCacheShader( "remote_chopper_hud_target_enemy" );
	PreCacheShader( "remote_chopper_hud_target_friendly" );
	PreCacheTurret( "player_view_controller" );
	PreCacheTurret( "player_view_controller_uav" );
	PreCacheModel( "tag_turret" );
	PreCacheString( &"UAV_ABOVE_TEMP_NUMBERS" );
	PreCacheString( &"UAV_ACFT" );
	PreCacheString( &"UAV_ALT_MSL" );
	PreCacheString( &"UAV_ALT_NEL" );
	PreCacheString( &"UAV_BLK" );
	PreCacheString( &"UAV_BLK_WHT" );
	PreCacheString( &"UAV_BRG" );
	PreCacheString( &"UAV_DEGREE" );
	PreCacheString( &"UAV_ELV" );
	PreCacheString( &"UAV_F" );
	PreCacheString( &"UAV_HAT" );
	PreCacheString( &"UAV_KIAS" );
	PreCacheString( &"UAV_M" );
	PreCacheString( &"UAV_MSL" );
	PreCacheString( &"UAV_N" );
	PreCacheString( &"UAV_N2" );
	PreCacheString( &"UAV_NAR" );
	PreCacheString( &"UAV_NM" );
	PreCacheString( &"UAV_QUOTE" );
	PreCacheString( &"UAV_RATE" );
	PreCacheString( &"UAV_RATIO" );
	PreCacheString( &"UAV_RNG" );
	PreCacheString( &"UAV_TEMP" );
	PreCacheString( &"UAV_W" );
	PreCacheString( &"UAV_W2" );
	PreCacheString( &"UAV_WHT" );
	PreCacheString( &"UAV_WTR_DVR_ON" );

	SetSavedDvar( "thermalBlurFactorNoScope", 50 );

	flag_init( "uav_hud_enabled" );
	flag_init( "recon_uav_in_use" );
}

missile_overlays()
{
	level.player enable_view( 0.05, true );
}

enable_view( time, skip_thermal )
{
//	level.uav_hud_color = ( 0.338, 0.637, 0.344 );
	level.uav_hud_color = ( 1, 1, 1 );
	//uav_disable_playerhud();
	self.uav_huds = [];
//	self.uav_huds[ "static_hud" ] 	= create_hud_static_overlay( time );
	self.uav_huds[ "scanline" ]		= create_hud_scanline_overlay( time );
	self.uav_huds[ "horz_meter" ] 	= create_hud_horizontal_meter( time );
	self.uav_huds[ "vert_meter" ] 	= create_hud_vertical_meter( time );
	self.uav_huds[ "crosshair" ] 	= create_hud_crosshair( time );

	self.uav_huds[ "upper_left" ]	= create_hud_upper_left( time );
	self.uav_huds[ "upper_right" ]	= create_hud_upper_right( time );
	self.uav_huds[ "lower_right" ]	= create_hud_lower_right( time );
	self.uav_huds[ "arrow_left" ]   = create_hud_arrow( "left", time );
	self.uav_huds[ "arrow_up" ]   = create_hud_arrow( "up", time );

	// Store some settings
	self.uav_huds[ "vert_meter" ].meter_size = 96;
	self.uav_huds[ "vert_meter" ].min_value = 10;
	self.uav_huds[ "vert_meter" ].max_value = 90;
	self.uav_huds[ "vert_meter" ].range = self.uav_huds[ "vert_meter" ].max_value - self.uav_huds[ "vert_meter" ].min_value;

	self.uav_huds[ "horz_meter" ].meter_size = 96;
	self.uav_huds[ "horz_meter" ].min_value = -180;
	self.uav_huds[ "horz_meter" ].max_value = 180;
	self.uav_huds[ "horz_meter" ].range = self.uav_huds[ "horz_meter" ].max_value - self.uav_huds[ "horz_meter" ].min_value;;

	SetSavedDvar( "sm_sunsamplesizenear", "1" );
	SetSavedDvar( "sm_cameraoffset", "3400" );

	flag_set( "uav_hud_enabled" );

	if ( !IsDefined( skip_thermal ) )
	{
		self uav_thermal_on( time );
	}
}

toggle_thermal()
{
	level.player endon( "tank_dismount" );
	level.player endon( "thermal_off" );
	
	level.player NotifyOnPlayerCommand( "thermal", "+usereload" );
	
	while( !flag( "thermal_out" ) )
	{
		level.player waittill( "thermal" );
		
		self uav_thermal_on();
		
		level thread maps\satfarm_audio::thermal();
		
		wait 1;
		
		level.player waittill( "thermal" );
		
		self uav_thermal_off();
		
		wait 1;
	}
	
}

toggle_thermal_npc()
{
	level.player endon( "tank_dismount" );
	self endon( "Death" );
	level.player NotifyOnPlayerCommand( "thermal", "+usereload" );
	
	if( IsDefined( level.player.is_in_thermal_Vision ) && level.player.is_in_thermal_Vision ) 
	{
		self ThermalDrawEnable();
		
		if( IsDefined( self.script_team ) && self.script_team == "allies" )
			self thread ally_strobe();
		
		level.player waittill( "thermal" );
		
		if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
			self ThermalDrawDisable();
		
		level notify( "thermal_fx_off" );
		
		wait 1;
	}
		
	while( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		
		level.player waittill( "thermal" );
		
		if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
		{
			self ThermalDrawEnable();
			
			if( IsDefined( self.script_team ) && self.script_team == "allies" )
				self thread ally_strobe();
		}
		
		wait 1;
		
		level.player waittill( "thermal" );
		
		if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
			self ThermalDrawDisable();
		
		level notify( "thermal_fx_off" );
		
		wait 1;
	}
	
	if( IsDefined( self ) )
		self ThermalDrawDisable();
}

ally_strobe()
{
	level endon( "thermal_fx_off" );
	self endon( "death" );

	for ( ;; )
	{
		PlayFXOnTag( level.friendly_thermal_Reflector_Effect, self, "antenna1_jnt" );

		wait( 0.2 );
	}
}

uav_thermal_on( time, vision )
{
	if( !IsDefined( vision ) )
		vision = "ac130_inverted";
	
	SetThermalBodyMaterial( "thermalbody_snowlevel" );
	if ( IsDefined( time ) )
	{
//		self VisionSetThermalForPlayer( "ac130", time );
		self VisionSetThermalForPlayer( vision, time );
	}
	else
	{
		self VisionSetThermalForPlayer( vision, 0.25 );
	}

	self maps\_load::thermal_EffectsOn();
//	friendlies = level.allytanks;
//	foreach ( guy in friendlies )
//	{
//		if ( IsDefined( guy.has_thermal_fx ) )
//			continue;
//
//		guy.has_thermal_fx = true;
//		//guy thread tank_thermal_effects( self.unique_id, self );
//	}
	
	self ThermalVisionOn();
	
	flag_set( "THERMAL_ON" );
}

uav_thermal_off()
{
	self maps\_load::thermal_EffectsOff();
//	friendlies = level.allytanks;
//	for ( index = 0; index < friendlies.size; index++ )
//	{
//		friendlies[ index ].has_thermal_fx = undefined;
//	}
	self ThermalVisionOff();
	flag_clear( "THERMAL_ON" );
}

tank_thermal_effects( player_id, onlyForThisPlayer )
{
	level endon( "thermal_fx_off" + player_id );
	self endon( "death" );

	for ( ;; )
	{
		if ( IsDefined( onlyForThisPlayer ) )
			PlayFXOnTagForClients( level.friendly_thermal_Reflector_Effect, self, "tag_turret", onlyForThisPlayer );
		else
			PlayFXOnTag( level.friendly_thermal_Reflector_Effect, self, "tag_turret" );

		//"tag_reflector_arm_ri"

		wait( 0.2 );
	}	
}

hud_fade_in_time( time, val )
{
	if ( !IsDefined( time ) )
	{
		return false;
	}

	if ( !IsDefined( val ) )
	{
		val = 1;
	}

	self.alpha = 0;
	self FadeOverTime( time );
	self.alpha = val;

	return true;
}
create_hud_scanline_overlay( time )
{
	hud = NewHudElem();
	hud.x = 0;
	hud.y = 0;
	hud.sort = level.uav_sort + 1;
	hud.horzAlign = "fullscreen";
	hud.vertAlign = "fullscreen";
	hud SetShader( "ac130_thermal_overlay_bar", 640, 100 );

	if ( !hud hud_fade_in_time( time, 1 ) )
	{
		hud.alpha = 1;
	}

	return hud;
}

create_hud_horizontal_meter( time )
{
	hud = NewHudElem();
	hud.x = 320;
	hud.y = 40;
	hud.sort = level.uav_sort;
	hud.alignX = "center";
	hud.alignY = "bottom";
	hud.color = level.uav_hud_color;
	hud SetShader( "uav_horizontal_meter", 96, 16 );

	hud hud_fade_in_time( time );

	return hud;
}

create_hud_vertical_meter( time )
{
	hud = NewHudElem();
	hud.x = 40;
	hud.y = 240;
	hud.sort = level.uav_sort;
	hud.alignX = "right";
	hud.alignY = "middle";
	hud.color = level.uav_hud_color;

	if ( GetDvarInt( "widescreen" ) != 1 )
	{
		hud.horzalign = "left";
		hud.vertalign = "top";
	}

	hud SetShader( "uav_vertical_meter", 16, 96 );

	hud hud_fade_in_time( time );

	return hud;
}

create_hud_crosshair( time )
{
	hud = NewHudElem();
	hud.x = 320;
	hud.y = 240;
	hud.sort = level.uav_sort;
	hud.alignX = "center";
	hud.alignY = "middle";

	hud SetShader( "uav_crosshair", 320, 240 );

	hud hud_fade_in_time( time );

	return hud;
}

create_hud_upper_left( time )
{
	data = [];
	data[ "nar" ]  		= [ &"UAV_NAR", "none" ];	//
	data[ "white" ]  	= [ &"UAV_WHT", "none" ];	//
	data[ "rate" ] 		= [ &"UAV_RATE", "none" ];	//
	data[ "angle" ] 	= [ &"UAV_RATIO", "none" ];	//
	data[ "numbers" ] 	= [ &"UAV_ABOVE_TEMP_NUMBERS", "none" ];	//
	data[ "temp" ] 		= [ &"UAV_TEMP", "none" ];	//

	huds = create_hud_section( data, 10, 80, "left", time );

	if ( GetDvarInt( "widescreen" ) != 1 )
	{
		foreach ( hud in huds )
		{
			hud.horzalign = "left";
			hud.vertalign = "top";
		}
	}
	
	return huds;
}

create_hud_upper_right( time )
{
	data = [];
	data[ "acft" ]  	= [ &"UAV_ACFT", "none" ];	//
	data[ "lat" ] 		= [ &"UAV_N", "none" ];	//
	data[ "long" ]  	= [ &"UAV_W", "none" ];	//
	data[ "angle" ] 	= [ &"UAV_HAT", "none" ];	//

	huds = create_hud_section( data, 510, 80, "left", time );

	deg_huds = [ huds[ "lat" ], huds[ "long" ] ];
	create_degree_values( deg_huds );

	return huds;
}

create_hud_lower_right( time )
{
	y_offset = 30;

	data = [];
	data[ "lat" ] 		= [ &"UAV_N", "none" ];	//
	data[ "long" ]  	= [ &"UAV_W", "none" ];	//

	huds = create_hud_section( data, 500, 335 - y_offset, "left", time );
	create_degree_values( huds );

	data = [];
	data[ "brg" ] 		= [ &"UAV_BRG", "" ];			// Bearing
	data[ "rng_m" ]  	= [ &"UAV_RNG", &"UAV_M" ];		// Range Meters
	data[ "rng_nm" ] 	= [ &"UAV_RNG", &"UAV_NM" ];	// Range Nautical Miles
	data[ "elv" ] 	 	= [ &"UAV_ELV", &"UAV_F" ];		// Elevation Feet

	huds2 = create_hud_section( data, 510, 360 - y_offset, "right", time );

	foreach ( idx, hud in huds2 )
	{
		huds[ idx ] = hud;
	}

	return huds;
}

create_hud_section( data, x, y, align_x, time )
{
	huds = [];

	spacing = 10 * level.uav_fontscale;
	foreach ( i, item in data )
	{
		hud = NewHudElem();
		hud.x = x;
		hud.y = y;
		hud.sort = level.uav_sort;
		hud.alignX = align_x;
		hud.alignY = "middle";
		hud.fontscale = level.uav_fontscale;
		hud.color = level.uav_hud_color;
		hud SetText( item[ 0 ] );

		if ( IsDefined( item[ 1 ] ) )
		{
			if ( !string_is_valid( item[ 1 ], "none" ) )
			{
				hud create_hud_data_value( item[ 1 ], time );
			}
		}
		else
		{
			hud create_hud_data_value( undefined, time );
		}

		hud hud_fade_in_time( time );

		huds[ i ] = hud;

		y += spacing;
	}

	return huds;
}

create_degree_value( val, is_string, x_offset )
{
	hud = NewHudElem();
	hud.x = self.x + 30 + x_offset;
	hud.y = self.y;
	hud.sort = level.uav_sort;
	hud.alignX = "right";
	hud.alignY = "middle";
	hud.fontscale = level.uav_fontscale;
	hud.color = level.uav_hud_color;

	if ( is_string )
	{
		hud SetText( val );
	}
	else
	{
		hud SetValue( val );
	}

	return hud;
}

create_degree_values( huds )
{
	foreach ( hud in huds )
	{
		hud.degrees = [];

		hud.degrees[ "deg" ] 		= hud create_degree_value( 0, false, 0 );
		hud.degrees[ "deg_str" ] 	= hud create_degree_value( &"UAV_DEGREE", true, 2 );
		hud.degrees[ "min" ] 		= hud create_degree_value( 0, false, 20 );
		hud.degrees[ "min_str" ] 	= hud create_degree_value( &"UAV_DEGREE", true, 20 + 2 );
		hud.degrees[ "sec" ] 		= hud create_degree_value( 0, false, 60 );
		hud.degrees[ "sec_str" ] 	= hud create_degree_value( &"UAV_QUOTE", true, 60 + 3 );
	}
}

string_is_valid( str, test )
{
	if ( IsString( str ) )
	{
		if ( str == test )
		{
			return true;
		}
	}

	return false;
}

create_hud_data_value( suffix, time )
{
	x_add = 75;

	if ( IsDefined( suffix ) && !string_is_valid( suffix, "" ) )
	{
		data_value_suffix = NewHudElem();
		data_value_suffix.x = self.x + x_add;
		data_value_suffix.y = self.y;
		data_value_suffix.alignX = "right";
		data_value_suffix.alignY = "middle";
		data_value_suffix.fontscale = level.uav_fontscale;
		data_value_suffix.color = level.uav_hud_color;
		data_value_suffix.sort = level.uav_sort;
		data_value_suffix SetText( suffix );

		self.data_value_suffix = data_value_suffix;

		size = 1;
		if ( suffix == &"UAV_NM" )
		{
			size = 2;
		}

		data_value_suffix hud_fade_in_time( time );

		x_add -= 10 * size;	
	}

	data_value = NewHudElem();
	data_value.x = self.x + x_add;
	data_value.y = self.y;
	data_value.alignX = "right";
	data_value.alignY = "middle";
	data_value.fontscale = level.uav_fontscale;
	data_value.color = level.uav_hud_color;
	data_value.sort = level.uav_sort;
	data_value SetValue( 0 );

	data_value hud_fade_in_time( time );

	self.data_value = data_value;
}

create_hud_arrow( dir, time )
{
	if ( dir == "up" )
	{
		shader = "uav_arrow_up";
		parent_hud = self.uav_huds[ "horz_meter" ];
		x = 320;
		y = parent_hud.y + 10;
		x_align = "center";
		y_align = "top";
	}
	else
	{
		shader = "uav_arrow_left";
		parent_hud = self.uav_huds[ "vert_meter" ];
		x = parent_hud.x + 10;
		y = 240;
		x_align = "left";
		y_align = "middle";
	}

	hud = NewHudElem();
	hud.x = x;
	hud.y = y;
	hud.alignX = x_align;
	hud.alignY = y_align;
	hud.sort = level.uav_sort;
	hud SetShader( shader, 16, 16 );

	if ( GetDvarInt( "widescreen" ) != 1 )
	{
		if ( dir == "left" )
		{
			hud.horzalign = "left";
			hud.vertalign = "top";
		}
	}

	hud hud_fade_in_time( time );

	hud create_hud_arrow_value( dir, time );

	return hud;	
}

create_hud_arrow_value( dir, time )
{
	if ( dir == "up" )
	{
		x = self.x;
		y = self.y + 16;
		x_align = "center";
		y_align = "top";
	}
	else
	{
		x = self.x + 16;
		y = self.y;
		x_align = "left";
		y_align = "middle";
	}

	data_value = NewHudElem();
	data_value.x = x;
	data_value.y = y;
	data_value.alignX = x_align;
	data_value.alignY = y_align;
	data_value.sort = level.uav_sort;
	data_value SetValue( 0 );


	if ( GetDvarInt( "widescreen" ) != 1 )
	{
		if ( dir == "left" )
		{
			data_value.horzalign = "left";
			data_value.vertalign = "top";
		}
	}

	data_value hud_fade_in_time( time );

	self.data_value = data_value;
}

enemytank_cleanup()
{
	self endon( "death" );
	
	wait( RandomFloatRange( 2.0, 6.0 ) );
	
	if( IsDefined( self ) && IsAlive( self ) )
		self Kill();
}

flag_wait_god_mode_off( flag_to_wait_for )
{
	flag_wait( flag_to_wait_for );
	
	if( IsDefined( self ) && IsAlive( self ) )
	{
		self godoff();
	}
}

crawling_guys_spawnfunc()
{
	self gun_remove();
    self.health = 1;
    self.ignoreExplosionEvents = true;
    self.ignoreme = true;
    self.ignoreall = true;
    self.IgnoreRandomBulletDamage = true;
    self.grenadeawareness = 0;
    self.no_pain_sound = true;
    self.noragdoll = 1;
    self.a.nodeath = true;
    
    num_crawls = RandomIntRange( 4, 10 );
    crawl_array = ter_op( RandomInt( 2 ), level.scr_anim[ "crawl_death_1" ], level.scr_anim[ "crawl_death_2" ] );
    
    self force_crawling_death( self.spawner.angles[1] , num_crawls , crawl_array, true );
    self DoDamage( 1, self.origin, level.player );
}

limping_guys_spawnfunc()
{
	self endon( "death" );
	
    self.ignoreExplosionEvents = true;
    //self.ignoreme = true;
    self.ignoreall = true;
    self.IgnoreRandomBulletDamage = true;
    self.grenadeawareness = 0;
    
	self.animname = "wounded_ai";
	self disable_arrivals_and_exits( true );
	
	if( cointoss() )
	{
		self set_run_anim( "wounded_limp_jog", true );
		self.moveplaybackrate = RandomFloatRange( .8, 1.0 );
	}
	else
	{
		self set_run_anim( "wounded_limp_run", true );
		self.moveplaybackrate = RandomFloatRange( .8, 1.0 );
	}
	
	self waittill( "goal" );
	
	if( IsDefined( self ) && IsAlive( self ) )
		self Kill();
}

delayed_show( delay )
{
	wait( delay );
	
	self Show();
}

delayed_kill( delay, wait_flag_before_delay )
{
	self endon( "death" );
	
	if( IsDefined( wait_flag_before_delay ) )
	{
		flag_wait( wait_flag_before_delay );
	}
	
	wait( delay );
	
	if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		self kill();
	}
}

random_wait_and_kill( min, max )
{
	self endon( "death" );
	
	wait( RandomFloatRange( min, max ) );
	
	if( IsDefined( self ) && self.classname != "script_vehicle_corpse" )
	{
		self kill();
	}
}

flag_wait_delete( flagname )
{
	flag_wait( flagname );
	
	if( IsDefined( self ) )
		self Delete();
}

delete_all_vehicles()
{
	vehicles = Vehicle_GetArray();
	
	foreach( vehicle in vehicles )
		vehicle Delete();
}

//pass in a struct to play a mortar impact on
//cause damage will do explosion damage
mortar_fire_on_struct( struct, cause_damage )
{
	//create fx tag
	fxTag 			= spawn_tag_origin();
	fxTag.origin 	= struct.origin;
	fxTag.angles	= (-90,0,0);
	
	//mortar fire
	thread play_sound_in_space( "mortar_incoming_intro", fxTag.origin );
	
	wait RandomFloatRange( .25, .45 );
	
	playfxontag( getfx( "mortar" ), fxTag, "tag_origin" );
	
	if( IsDefined( cause_damage ) )
		RadiusDamage( fxTag.origin, 170, 500, 250 );
	
	EarthQuake( .2, .5, level.player.origin, 512 );
	thread play_sound_in_space( "mortar_explosion_intro", fxTag.origin );
	
	wait RandomFloatRange( .25, .45 );
	
	fxTag Delete();
}

/*** Test Functions ***/
/#

count_vehicles()
{
	level.max_vehicles_in_session = 0;
	
	while ( true )
	{
		vehicles = Vehicle_GetArray();
		
		if ( vehicles.size > level.max_vehicles_in_session )
			level.max_vehicles_in_session = vehicles.size;
		
		waitframe();
	}
}

#/

//
//kill_gazs_in_vol( playertankvol )
//{
//	while( 1 ) 
//	{
//		// kill gazs touching vol
//		if( IsDefined( level.enemygazs ) )
//			foreach( enemy in level.enemygazs )
//				if( enemy.driver istouching( playertankvol ) )
//					enemy kill();
//		
//		wait .01;
//	}
//}

get_a10_player_start()
{
	a10_player_start = GetStruct( "a10_player_start", "targetname" );

	return a10_player_start;
}

init_sabot_for_player( loc, ang, tank )
{
	if ( IsDefined( level.missile ) )
	{
		level.missile Delete();
	}

	level.missile = spawn_tag_origin();
	level.missile.origin = loc;
	level.missile.angles = ang;
	
	level.missile.speed = 200;
	level.missile.acceleration = 200;
	level.missile.deceleration = 10;
	level.missile.launch_speed = 200;
	level.missile.launch_delay = 0.5;
//	level.missile.roll_max = 180;
	level.missile.pitch_max = 180;
//	level.missile.roll_speed_max = 90;
	level.missile.pitch_speed_max = 25;
//	level.missile.strafe_max_speed_angle = 90;
//	level.missile.roll_current = 0;
	level.missile.yaw_speed_max = 55;
	level.missile.mph_to_ips = 63360 / 3600;
	level.missile.fov = 75;
	level.missile.acceleration_fov = 100;
	level.missile.weap = "sabot_guided";
	level.missile.weap_detonate = "sabot_guided_detonate";
	level.missile.lifetime = 5;
	
	level.missile.tank = tank;
}

init_bunker_buster_missile_for_player( loc, ang )
{
	if ( IsDefined( level.missile ) )
	{
		level.missile Delete();
	}
	
	level.missile = spawn_tag_origin();
	level.missile.origin = loc;
	level.missile.angles = ang;

	level.missile.speed = 250;
	level.missile.acceleration = 250;
	level.missile.launch_speed = 250;
	level.missile.launch_delay = 0.0;
//	level.missile.roll_max = 180;
	level.missile.pitch_max = 180;
//	level.missile.roll_speed_max = 90;
	level.missile.pitch_speed_max = 15;
//	level.missile.strafe_max_speed_angle = 90;
//	level.missile.roll_current = 0;
	level.missile.yaw_speed_max = 15;
	level.missile.mph_to_ips = 63360 / 3600;
	level.missile.fov = 100;
	level.missile.weap = undefined;
	level.missile.weap_detonate = undefined;
	level.missile.lifetime = undefined;
	
	level.missile.tank = undefined;
}
	
give_player_missile_control()
{
	self notify( "give_player_missile_control" );
	self endon( "give_player_missile_control" );
	self endon( "remove_player_missile_control" );
	
	flag_set( "player_guiding_round" );
	
	self.prev_angles = self GetPlayerAngles();
/*	
	level.missile.missile_hud_item[ "black" ] = NewHudElem();
	level.missile.missile_hud_item[ "black" ].hidewheninmenu = false;
	level.missile.missile_hud_item[ "black" ].hidewhendead = true;
	level.missile.missile_hud_item[ "black" ] SetShader( "black", 640, 480 );
	level.missile.missile_hud_item[ "black" ].alignX = "left";
	level.missile.missile_hud_item[ "black" ].alignY = "top";
	level.missile.missile_hud_item[ "black" ].horzAlign = "fullscreen";
	level.missile.missile_hud_item[ "black" ].vertAlign = "fullscreen";
	level.missile.missile_hud_item[ "black" ].alpha = 1;
	level.missile.missile_hud_item[ "black" ].sort = 250;
	
	wait 0.05;
*/
	if ( IsDefined( level.missile.tank ) )
	{
		level.missile.tank dismount_tank_for_missile( self );
	}

	self SetStance( "stand" );
	self AllowProne( false );
	self AllowCrouch( false );
	self AllowStand( true );
	self AllowAds( false );
	
	self HideViewModel();
	self DisableWeaponSwitch();
	self DisableOffhandWeapons();
	self EnableHealthShield( true );
	self EnableDeathShield( true );
	self EnableInvulnerability();
	SetSavedDvar( "cg_fov", level.missile.fov );
	SetSavedDvar( "ammoCounterHide", "1" );
	SetSavedDvar( "actionSlotsHide", "1" );
	SetSavedDvar( "compass", 0 );
	self DisableWeapons();
	
	self SetOrigin( level.missile.origin );
	self SetPlayerAngles( level.missile.angles );
		
	self PlayerLinkToDelta( level.missile, "tag_origin", 1, 0, 0, 0, 0, true );
		
	self PlayerLinkedOffsetEnable();
/*	
	wait 0.05;
	
	level.missile.missile_hud_item[ "black" ] FadeOverTime( 0.25 );
	level.missile.missile_hud_item[ "black" ].alpha = 0;
*/	
	level.missile.missile_hud_item[ "static" ] = NewHudElem();
	level.missile.missile_hud_item[ "static" ].hidewheninmenu = false;
	level.missile.missile_hud_item[ "static" ].hidewhendead = true;
	level.missile.missile_hud_item[ "static" ] SetShader( "overlay_static", 640, 480 );
	level.missile.missile_hud_item[ "static" ].alignX = "left";
	level.missile.missile_hud_item[ "static" ].alignY = "top";
	level.missile.missile_hud_item[ "static" ].horzAlign = "fullscreen";
	level.missile.missile_hud_item[ "static" ].vertAlign = "fullscreen";
	level.missile.missile_hud_item[ "static" ].alpha = 0.25;
	
	level.missile.missile_hud_item[ "overlay" ] = NewHudElem();
	level.missile.missile_hud_item[ "overlay" ].hidewheninmenu = false;
	level.missile.missile_hud_item[ "overlay" ].hidewhendead = true;
	level.missile.missile_hud_item[ "overlay" ] SetShader( "ugv_screen_overlay", 640, 480 );
	level.missile.missile_hud_item[ "overlay" ].alignX = "left";
	level.missile.missile_hud_item[ "overlay" ].alignY = "top";
	level.missile.missile_hud_item[ "overlay" ].horzAlign = "fullscreen";
	level.missile.missile_hud_item[ "overlay" ].vertAlign = "fullscreen";
	level.missile.missile_hud_item[ "overlay" ].alpha = 0.75;
	
	level.missile.missile_hud_item[ "vignette" ] = NewHudElem();
	level.missile.missile_hud_item[ "vignette" ].hidewheninmenu = false;
	level.missile.missile_hud_item[ "vignette" ].hidewhendead = true;
	level.missile.missile_hud_item[ "vignette" ] SetShader( "ugv_vignette_overlay", 640, 480 );
	level.missile.missile_hud_item[ "vignette" ].alignX = "left";
	level.missile.missile_hud_item[ "vignette" ].alignY = "top";
	level.missile.missile_hud_item[ "vignette" ].horzAlign = "fullscreen";
	level.missile.missile_hud_item[ "vignette" ].vertAlign = "fullscreen";
	level.missile.missile_hud_item[ "vignette" ].alpha = 0.5;
	
	level.missile.missile_hud_item[ "scanline" ] = NewHudElem();
	level.missile.missile_hud_item[ "scanline" ].hidewheninmenu = false;
	level.missile.missile_hud_item[ "scanline" ].hidewhendead = true;
	level.missile.missile_hud_item[ "scanline" ] SetShader( "m1a1_tank_sabot_scanline", 1000, 75 );
	level.missile.missile_hud_item[ "scanline" ].alignX = "center";
	level.missile.missile_hud_item[ "scanline" ].alignY = "middle";
	level.missile.missile_hud_item[ "scanline" ].horzAlign = "center";
	level.missile.missile_hud_item[ "scanline" ].vertAlign = "middle";
	level.missile.missile_hud_item[ "scanline" ].alpha = 0.75;
	level.missile.missile_hud_item[ "scanline" ] thread missile_update_scanline();
	
	level.missile.missile_hud_item[ "sabot_reticle" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_reticle_center", 25, 25 );
	level.missile.missile_hud_item[ "sabot_reticle" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_reticle" ].alignX = "center";
	level.missile.missile_hud_item[ "sabot_reticle" ].alignY = "middle";
	level.missile.missile_hud_item[ "sabot_reticle" ].alpha = 0.666;
	
	level.missile.missile_hud_item[ "sabot_reticle_upper_left" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_top_left", 20, 20 );
	level.missile.missile_hud_item[ "sabot_reticle_upper_left" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_reticle_upper_left" ].alignX = "center";
	level.missile.missile_hud_item[ "sabot_reticle_upper_left" ].alignY = "middle";
	level.missile.missile_hud_item[ "sabot_reticle_upper_left" ].x = level.missile.missile_hud_item[ "sabot_reticle" ].width * -2.5;
	level.missile.missile_hud_item[ "sabot_reticle_upper_left" ].y = level.missile.missile_hud_item[ "sabot_reticle" ].height * -1;
	level.missile.missile_hud_item[ "sabot_reticle_upper_left" ].alpha = 0.666;
	
	level.missile.missile_hud_item[ "sabot_reticle_upper_right" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_top_right", 20, 20 );
	level.missile.missile_hud_item[ "sabot_reticle_upper_right" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_reticle_upper_right" ].alignX = "center";
	level.missile.missile_hud_item[ "sabot_reticle_upper_right" ].alignY = "middle";
	level.missile.missile_hud_item[ "sabot_reticle_upper_right" ].x = level.missile.missile_hud_item[ "sabot_reticle" ].width * 2.5;
	level.missile.missile_hud_item[ "sabot_reticle_upper_right" ].y = level.missile.missile_hud_item[ "sabot_reticle" ].height * -1;
	level.missile.missile_hud_item[ "sabot_reticle_upper_right" ].alpha = 0.666;
	
	level.missile.missile_hud_item[ "sabot_reticle_bottom_left" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_bottom_left", 20, 20 );
	level.missile.missile_hud_item[ "sabot_reticle_bottom_left" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_reticle_bottom_left" ].alignX = "center";
	level.missile.missile_hud_item[ "sabot_reticle_bottom_left" ].alignY = "middle";
	level.missile.missile_hud_item[ "sabot_reticle_bottom_left" ].x = level.missile.missile_hud_item[ "sabot_reticle" ].width * -2.5;
	level.missile.missile_hud_item[ "sabot_reticle_bottom_left" ].y = level.missile.missile_hud_item[ "sabot_reticle" ].height * 1;
	level.missile.missile_hud_item[ "sabot_reticle_bottom_left" ].alpha = 0.666;
	
	level.missile.missile_hud_item[ "sabot_reticle_bottom_right" ] = maps\_hud_util::createIcon( "m1a1_tank_missile_reticle_inner_bottom_right", 20, 20 );
	level.missile.missile_hud_item[ "sabot_reticle_bottom_right" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_reticle_bottom_right" ].alignX = "center";
	level.missile.missile_hud_item[ "sabot_reticle_bottom_right" ].alignY = "middle";
	level.missile.missile_hud_item[ "sabot_reticle_bottom_right" ].x = level.missile.missile_hud_item[ "sabot_reticle" ].width * 2.5;
	level.missile.missile_hud_item[ "sabot_reticle_bottom_right" ].y = level.missile.missile_hud_item[ "sabot_reticle" ].height * 1;
	level.missile.missile_hud_item[ "sabot_reticle_bottom_right" ].alpha = 0.666;
	
	level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ] = maps\_hud_util::createIcon( "m1a1_tank_sabot_fuel_range_horizontal", Int( level.missile.missile_hud_item[ "sabot_reticle" ].width * 4 ), Int( level.missile.missile_hud_item[ "sabot_reticle" ].width * 4 * 0.25 ) );
	level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].alignX = "center";
	level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].alignY = "bottom";
	level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].y = level.missile.missile_hud_item[ "sabot_reticle" ].height * -3;
	level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].alpha = 0.666;
	
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ] = maps\_hud_util::createIcon( "red_block", Int( level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].width * 0.625 ), Int( level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].height * 0.32 ) );
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].alignX = "left";
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].alignY = "middle";
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].x = level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].width * -0.5 - 1;
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].y = level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].y - level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].height * 0.38;
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].alpha = 0.666;
	level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].start_width = level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].width;
	
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ] = maps\_hud_util::createClientFontString( "default", 1.0 );	
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ] set_default_hud_parameters();
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ].alignX = "center";
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ].alignY = "bottom";
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ].alpha = 0.666;
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ].x = 0;
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ].y = level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].y - level.missile.missile_hud_item[ "sabot_fuel_range_bracket" ].height * 0.666;
	level.missile.missile_hud_item[ "sabot_fuel_range_text" ] SetText( &"SATFARM_FUEL_RANGE" );

//	level.missile thread missile_timeout( self );
	
	VisionSetNaked( "satfarm_sabot_view", 0 );
	
	level.missile thread player_missile_control( self );
//	self thread update_altitude();
	
/*	foreach ( enemy in level.enemytanks )
	{
		Target_Set( enemy, ( 0, 0, 0 ) );
		Target_SetShader( enemy, "veh_hud_target" );
		Target_ShowToPlayer( enemy, self );
		Target_SetScaledRenderMode( enemy, false );
	
		enemy thread remove_target_on_death();
	}*/
}

missile_update_scanline()
{
	level.player endon( "remove_player_missile_control" );
	
	while ( IsDefined( self ) )
	{
		self.y = -400;
		self MoveOverTime( 2 );
		self.y = 400;
		wait 2;
	}
}
	
remove_target_on_death()
{
	self waittill( "death" );
	
	if ( IsDefined( self ) && Target_IsTarget( self ) )
	{
		Target_Remove( self );
	}
}
	
remove_player_missile_control()
{
	self waittill( "remove_player_missile_control" );
	
	flag_set("tow_cam_sound_off");
	
	self remove_player_missile_control_internal();
}

remove_player_missile_control_internal()
{
/*	foreach ( targ in Target_GetArray() )
	{
		Target_Remove( targ );
	}
*/	

	flag_clear( "player_guiding_round" );
	flag_clear( "player_fired_guided_round" );
	
	self Unlink();
	self ShowViewModel();
	self EnableWeaponSwitch();
	self EnableOffhandWeapons();
	self EnableWeapons();
	self EnableHealthShield( false );
	self EnableDeathShield( false );
	
	self SetStance( "stand" );
	self AllowProne( true );
	self AllowCrouch( true );
	self AllowStand( true );
	self AllowAds( true );
	
	SetSavedDvar( "cg_fov", 65 );
	
	if( IsDefined( level.missile ) )
	{
		keys = getArrayKeys( level.missile.missile_hud_item );
		foreach ( key in keys )
		{
			level.missile.missile_hud_item[ key ] Destroy();
			level.missile.missile_hud_item[ key ] = undefined;
		}
		
		if( IsDefined( level.missile.tank ) )
		{
			level.missile.tank mount_tank( self, true, 0.25, true );
			self SetPlayerAngles( self.prev_angles );
			self FreezeControls( true );
		
//			self notify( "cycle_weapon" );
		}
		VisionSetNaked( "satfarm", 0 );
		
		level.missile Delete();
		level.missile = undefined;
		
		wait 1;
		
		self FreezeControls( false );
	}
	else
	{
		self DisableInvulnerability();
		SetSavedDvar( "ammoCounterHide", "0" );
		SetSavedDvar( "actionSlotsHide", "0" );
		SetSavedDvar( "compass", 1 );
		
		VisionSetNaked( "satfarm", 0 );
	}
	
	level.player notify( "reenable_triggers" );
}

missile_timeout( player )
{
	player endon( "give_player_missile_control" );
	player endon( "remove_player_missile_control" );

	if( IsDefined( level.missile.tank ) )
		player NotifyOnPlayerCommand( "early_det", "+attack" );
	
	waittill_any_timeout( self.lifetime, "early_det" );
	//wait self.lifetime;

	if ( IsDefined( self ) )
	{
		player notify( "missile_timeout" );
	
		player missile_explode( true );
	}
}
	
missile_remove_blur( delay_time, fade_time )
{
	wait delay_time;
	SetBlur( 0, fade_time );
}
	
player_missile_control( player )
{
	player endon( "give_player_missile_control" );
	player endon( "remove_player_missile_control" );
	
	dist = 0;
	
	if ( IsDefined( self.max_distance ) )
	{
		dist = self.max_distance;
	}
	
	thread missile_trigger_explode( player );
	
	cur_speed = self.launch_speed;
	life = self.lifetime;
	launch_delay = self.launch_delay;
	changed_fov = !IsDefined( self.acceleration_fov );
	
	while ( IsDefined( self ) )
	{
		self player_missile_yaw_control( player );
		self player_missile_pitch_control( player );

//		strafe = AnglesToRight( ( self.angles[ 0 ], self.angles[ 1 ], 0 ) ) * clamp( self.angles[ 2 ] / self.strafe_max_speed_angle, -1.0, 1.0 ) * level.missile.speed * 0.25 * self.mph_to_ips * 0.05;
		
		if ( launch_delay <= 0 )
		{
			if ( !changed_fov )
			{
				SetBlur( 10, 0 );
				player LerpFOV( self.acceleration_fov, 0.25 );
				changed_fov = true;
				thread missile_remove_blur( 0.05, 0.25 );
				Earthquake( 1, 0.25, self.origin, 500 );
				self ScreenShakeOnEntity( RandomFloatRange( 0.25, 0.35 ), RandomFloatRange( 0.25, 0.35 ), RandomFloatRange( 0.25, 0.35 ), self.lifetime, 0, 0, 100, RandomFloatRange( 15, 20 ), RandomFloatRange( 15, 20 ), RandomFloatRange( 15, 20 ) );
			}

		cur_speed += self.acceleration * self.mph_to_ips * 0.05;
		
		cur_speed = Min( cur_speed, self.speed );
		}
		else
		{
			cur_speed -= self.deceleration * self.mph_to_ips * 0.05;
//			self.angles = ( self.angles[ 0 ] + 35 * ( ( self.speed - cur_speed ) / self.speed ) * 0.05, self.angles[ 1 ], self.angles[ 2 ] );
			launch_delay -= 0.05;
		}

		new_origin = ( self.origin + AnglesToForward( self.angles ) * cur_speed * self.mph_to_ips * 0.05 /*+ strafe*/ );
		
		if ( launch_delay <= 0 && IsDefined( self.lifetime ) )
		{
			life -= 0.05;
			if ( Int( 100 * life / self.lifetime ) < 1 )
			{
				level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].alpha = 0;
			}
			else
			{
				level.missile.missile_hud_item[ "sabot_fuel_range_bar" ] SetShader( "red_block", Int( level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].start_width * life / self.lifetime ), level.missile.missile_hud_item[ "sabot_fuel_range_bar" ].height );
			}
		}
		
		if ( flag( "missile_out_of_bounds" ) || life < 0 )
		{
			flag_clear( "missile_out_of_bounds" );
			player missile_explode( true );
			return;
		}
		
		self.origin_diff = new_origin - self.origin;
		
		trace = BulletTrace( player GetEye() + ( 0, 0, 10 ), player GetEye() + ( 0, 0, 10 ) + self.origin_diff, false, self );
		trace2 = BulletTrace( player GetEye() - ( 0, 0, 10 ), player GetEye() - ( 0, 0, 10 ) + self.origin_diff, false, self );
		
		if ( trace[ "fraction" ] < 1 || trace2[ "fraction" ] < 1 )
		{
			player missile_explode();
			return;
		}
		
		self MoveTo( new_origin, 0.05, 0, 0 );
		
		wait 0.05;
	}
}

missile_trigger_explode( player )
{
	player endon( "give_player_missile_control" );
	player endon( "remove_player_missile_control" );

	if( IsDefined( level.missile.tank ) )
		player NotifyOnPlayerCommand( "early_det", "+attack" );
	
	player waittill( "early_det" );
	//waittill_any_timeout( self.lifetime, "early_det" );
	//wait self.lifetime;

	if ( IsDefined( self ) )
	{
		player notify( "missile_timeout" );
	
		player missile_explode( true );
	}
}

player_missile_roll_control( player )
{
	roll_speed = 0;
	yaw_speed = 0;
	
	self.old_angles = self.angles;
	
	roll = player GetNormalizedCameraMovement()[1];

	if ( roll > 0 && roll < 0.25 )
	{
		roll = 0;
	}
	else if ( roll < 0 && roll > -0.25 )
	{
		roll = 0;
	}
	
	desired_roll = self.angles[ 2 ];
	
	if ( desired_roll > 180 )
	{
		desired_roll -= 360;
	}
	
	if ( roll == 0 )
	{
		if ( desired_roll > 0 )
		{
			roll_speed -= 0.25 * self.roll_speed_max * 0.05;
		}
		else
		{
			roll_speed += 0.25 * self.roll_speed_max * 0.05;
		}
		
		roll_speed = clamp( roll_speed, ( 0 - self.roll_speed_max / 4 ) * 0.05, ( self.roll_speed_max / 4 ) * 0.05 );
		
		roll_speed *= min( 1.0, squared( abs( desired_roll ) / ( self.roll_max / 2 ) ) );
		
		if ( abs( roll_speed ) > abs( desired_roll ) )
		{
			roll_speed = 0 - desired_roll;
		}
		
		self.roll_current -= self.roll_current * 0.05;
		
		yaw_speed *= 0.75;
	}
	else
	{			
		roll_speed += roll * ( self.roll_speed_max * 4 ) * 0.05;
		roll_speed = clamp( roll_speed, ( 0 - self.roll_speed_max ) * abs( roll ) * 0.05, self.roll_speed_max * abs( roll ) * 0.05 );
		
		yaw_speed += roll * ( self.yaw_speed_max / 10 ) * 0.05;
		yaw_speed = clamp( yaw_speed, ( 0 - self.yaw_speed_max ) * abs( roll ) * 0.05, self.yaw_speed_max * abs( roll ) * 0.05 );
		
		if ( abs( desired_roll ) / self.roll_max > 0.5 )
		{
			if ( desired_roll < 0 && roll_speed < 0 || desired_roll > 0 && roll_speed > 0 )
			{
				multiplier = squared( ( self.roll_max - abs( desired_roll ) ) / ( self.roll_max - ( self.roll_max * 0.5 ) ) );
				roll_speed *= multiplier;
			}
		}
		
		self.roll_current = roll_speed / ( self.roll_speed_max * 0.05 );
	}

	desired_roll += roll_speed;
	desired_roll = clamp( desired_roll, ( 0 - self.roll_max ), self.roll_max );

	self AddRoll( desired_roll - self.angles[ 2 ] );
	
	if ( !self.flight_controls )
	{
		self.angles = ( self.angles[ 0 ], self.angles[ 1 ] - yaw_speed, self.angles[ 2 ] );
	}
}

player_missile_yaw_control( player )
{
	yaw = player GetNormalizedCameraMovement()[1];
		
	if ( yaw > 0 && yaw < 0.25 )
	{
		yaw = 0;
	}
	else if ( yaw < 0 && yaw > -0.25 )
	{
		yaw = 0;
	}
	
	yaw_current = self.angles[ 1 ];

	if ( yaw != 0.0 )
	{
		yaw_current += ( self.yaw_speed_max * yaw * 0.05 );
	}
	
	self AddYaw( self.angles[ 1 ] - yaw_current );
}

player_missile_pitch_control( player )
{
	pitch_speed = 0;
	pitch = player GetNormalizedCameraMovement()[0];
		
	if ( pitch > 0 && pitch < 0.25 )
	{
		pitch = 0;
	}
	else if ( pitch < 0 && pitch > -0.25 )
	{
		pitch = 0;
	}
	
	desired_pitch = self.angles[ 0 ];
	
	if ( desired_pitch > 180 )
	{
		desired_pitch -= 360;
	}
		
	pitch_speed -= pitch * self.pitch_speed_max * 0.05;
	pitch_speed = clamp( pitch_speed, ( 0 - self.pitch_speed_max ) * abs( pitch ) * 0.05, self.pitch_speed_max * abs( pitch ) * 0.05 );
	
	if ( abs( desired_pitch ) / self.pitch_max > 0.5 )
	{
		if ( desired_pitch < 0 && pitch_speed < 0 || desired_pitch > 0 && pitch_speed > 0 )
		{
			multiplier = squared( ( self.pitch_max - abs( desired_pitch ) ) / ( self.pitch_max - ( self.pitch_max * 0.5 ) ) );
			pitch_speed *= multiplier;
		}
	}

	desired_pitch += pitch_speed;
	desired_pitch = clamp( desired_pitch, ( 0 - self.pitch_max ), self.pitch_max );
	
	self AddPitch( desired_pitch - self.angles[ 0 ] );
}
		
missile_explode( detonate_early )
{
/*	if ( IsDefined( detonate_early ) && detonate_early )
	{
		if ( IsDefined( level.missile.weap_detonate ) )
		{
			MagicBullet( level.missile.weap_detonate, self GetEye(), self GetEye() + AnglesToForward( self GetPlayerAngles() ) * 1000, self );
		}
	}
	else if ( IsDefined( level.missile.weap ) )
	{
		MagicBullet( level.missile.weap, self GetEye(), self GetEye() + AnglesToForward( self GetPlayerAngles() ) * 1000, self );
//		RadiusDamage( self GetEye(), 500, 1000, 500, self, "MOD_PROJECTILE", level.missile.weap );
//		PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin );
	}
*/	
	RadiusDamage( self GetEye(), 500, 1000, 500, self, "MOD_PROJECTILE", level.missile.weap );
	PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin );
	PhysicsExplosionSphere( self GetEye(), 300, 150, 1 );
	self notify( "remove_player_missile_control" );
}
//
//missile_explode_air()
//{
//	if ( IsDefined( level.missile.weap ) )
//	{
//		//MagicBullet( level.missile.weap, self GetEye(), self GetEye() + AnglesToForward( self GetPlayerAngles() ) * 1000, self );
//		RadiusDamage( self GetEye(), 500, 1000, 500, self, "MOD_PROJECTILE", level.missile.weap );
//		PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin );
//	}
//		
//	self remove_player_missile_control_internal();
//}

update_altitude()
{
	level endon( "remove_player_missile_control" );
	
	while ( 1 )
	{
		self.altitude = ( self.origin[ 2 ] - self groundpos( self.origin )[ 2 ] ) / 12;

		wait 0.05;
	}
}

spawn_allies()
{
	level.allies						 = [];
	//level.allies[ 0 ]					 = spawn_script_noteworthy( "atc_ghost1", true );
	level.allies[ 0 ]					= spawn_ally( "ghost1" );
	level.allies[ 0 ] .animname			 = "merrick";
	//level.allies[ 1 ]					 = spawn_script_noteworthy( "atc_ghost2", true );
	level.allies[ 1 ]					= spawn_ally( "ghost2" );
	level.allies[ 1 ] .animname			 = "hesh";
/*
	foreach ( ally in level.allies )
	{
	    ally make_hero();
   		if ( !IsDefined( ally.magic_bullet_shield ) )
 	   	{
    		ally magic_bullet_shield();
		}	
   		ally.grenadeammo = 0;
	}	
*/
}

spawn_ally( allyName, overrideSpawnPointName )
{
	spawnname = undefined;
    if ( !IsDefined( overrideSpawnPointName ) )
    {
        spawnname = level.start_point + "_" + allyName;
    }
    else
    {
        spawnname = overrideSpawnPointName + "_" + allyName;
    	
    }

    ally = spawn_targetname_at_struct_targetname( allyName, spawnname );
    if ( !IsDefined( ally ) )
    {
    	return undefined;
    }
    ally make_hero();
    if ( !IsDefined( ally.magic_bullet_shield ) )
    {
    	ally magic_bullet_shield();
	}
    ally.grenadeammo = 0;
	
    return ally;
}

spawn_targetname_at_struct_targetname( tname, sname )
{
    spawner = GetEnt( tname, "targetname" );
	sstart = getstruct( sname, "targetname" );
	if ( IsDefined( spawner ) && IsDefined( sstart ) )
	{
		spawner.origin = sstart.origin;
		if ( IsDefined( sstart.angles ) )
		{
			spawner.angles = sstart.angles;
		}
		spawned = spawner spawn_ai( true );
	    return spawned;
	}
	if ( IsDefined( spawner ) )
	{
		spawned = spawner spawn_ai( true );
    	IPrintLnBold( "Add a script struct called: " + sname + " to spawn him in the correct location." );
    	spawned Teleport( level.player.origin, level.player.angles );
    	return spawned;
		
	}
	IPrintLnBold( "failed to spawn " + tname + " at " + sname );
	
	return undefined;
}

ai_array_killcount_flag_set( guys, killcount, flag, timeout )
{
	waittill_dead_or_dying( guys, killcount, timeout );
	flag_set( flag );
}

cleanup_enemies( flag_to_wait_on, enemies )
{
	flag_wait( flag_to_wait_on );
	enemies = array_removeDead_or_dying( enemies );
	if ( enemies.size > 0 )
	{
		foreach ( enemy in enemies )
		{
			if ( IsDefined( enemy ) )
			{
				enemy Kill();
			}
		}
	}	
}

waittill_goal( radius, kill_me )
{
	self endon( "death" );
	
	if( isdefined( radius ) )
		self.goalradius = radius;
	
	self waittill( "goal" );
	
	if( IsDefined( kill_me ) )
	{
		if( IsDefined( self ) )
		{
			self Kill();
		}
	}
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

rotate_big_sat()
{
	big_dish = getent( "big_dish", "targetname" );
	
	big_dish RotateRoll( 50, .05 );
	
	flag_wait( "spawn_front" );
	
	big_dish RotateRoll( -50, 20 );
	
}

kill_vehicle_spawners_now( number )
{
	array_delete( level.vehicle_killspawn_groups[ number ] );
	level.vehicle_killspawn_groups[ number ] = [];	
}

kill_spawners_per_checkpoint( checkpoint_name )
{
	if( checkpoint_name == "intro" )
		return;
	
	maps\_spawner::killspawner( 10 );
    kill_vehicle_spawners_now( 10 );
    maps\satfarm_intro::intro_cleanup();
	
	if( checkpoint_name == "crash_site" )
		return;
	
	maps\_spawner::killspawner( 20 );
    kill_vehicle_spawners_now( 20 );
    maps\satfarm_crash_site::crash_site_cleanup();

	if( checkpoint_name == "base_array" )
		return;
	
	maps\_spawner::killspawner( 30 );
    kill_vehicle_spawners_now( 30 );
    maps\satfarm_base_array::base_array_cleanup();
	
	if( checkpoint_name == "air_strip" )
		return;
	
	maps\_spawner::killspawner( 40 );
    kill_vehicle_spawners_now( 40 );
    maps\satfarm_air_strip::air_strip_cleanup();
	
	if( checkpoint_name == "air_strip_secured" )
		return;
	
	maps\_spawner::killspawner( 200 );
	kill_vehicle_spawners_now( 200 );
	
	if( checkpoint_name == "tower" )
		return;

	maps\_spawner::killspawner( 201 );
	kill_vehicle_spawners_now( 201 );
	
	if( checkpoint_name == "warehouse" )
		return;
	
	maps\_spawner::killspawner( 202 );
	
	if( checkpoint_name == "bridge_deploy" )
		return;
	
	maps\_spawner::killspawner( 300 );
	kill_vehicle_spawners_now( 300 );
	
	if( checkpoint_name == "bridge" )
		return;

	maps\_spawner::killspawner( 301 );
	kill_vehicle_spawners_now( 301 );
		
	if( checkpoint_name == "complex" )
		return;

	maps\_spawner::killspawner( 302 );
	kill_vehicle_spawners_now( 302 );
	maps\_spawner::killspawner( 303 );
	kill_vehicle_spawners_now( 303 );
		
	if( checkpoint_name == "final" )
		return;
}

//temp stuff to drive over

saf_streetlight_dynamic_setup(  checkpoint_name, ender_and_cleanup_flag )
{
	orgs = getstructarray( "saf_streetlight_dynamic_" + checkpoint_name, "targetname" );

	foreach( org in orgs )
		org thread saf_streetlight_dynamic_func( ender_and_cleanup_flag );
}

saf_streetlight_dynamic_func( ender_and_cleanup_flag )
{
	level endon( ender_and_cleanup_flag );
	
	ent		   = Spawn( "script_model", self.origin );
	ent.angles = self.angles;
	ent SetModel( "london_streetlight_01" );
	ent thread flag_wait_delete( ender_and_cleanup_flag );
	
    trig = Spawn( "trigger_radius", self.origin, 112, 32, 128 );
	trig thread flag_wait_delete( ender_and_cleanup_flag );
	
	trig waittill( "trigger", triggerer );
	
	if( IsDefined( trig ) )
		trig Delete();
	
	yaw = VectorToYaw( triggerer Vehicle_GetVelocity() );
	
	tread_dist				  = 64.0;
	triggerer_velocity_vector = triggerer Vehicle_GetVelocity();
	speed					  = VectorDot( triggerer_velocity_vector, AnglesToForward( ent.angles ) );
	
	ent.angles = ( ent.angles[ 0 ], yaw, ent.angles[ 2 ] );
	
	if ( speed != 0.0 )
	{
	    rotate_time = tread_dist / abs( speed );
	    ent RotatePitch( 90, rotate_time );
	    
	    ent waittill( "rotatedone" );
	    
	    wait( 5.0 );
	    
	    if( IsDefined( ent ) )
	    	ent Delete();
	}
}

saf_concrete_barrier_dynamic_setup( checkpoint_name, ender_and_cleanup_flag )
{
	orgs = getstructarray( "saf_concrete_barrier_dynamic_" + checkpoint_name, "targetname" );

	foreach( org in orgs )
		org thread saf_concrete_barrier_dynamic_func( ender_and_cleanup_flag );
}

saf_concrete_barrier_dynamic_func( ender_and_cleanup_flag )
{
	level endon( ender_and_cleanup_flag );
	
	ent		   = Spawn( "script_model", self.origin );
	ent.angles = self.angles;
	ent SetModel( "fac_metal_barrier_post" );
	ent thread flag_wait_delete( ender_and_cleanup_flag );
	
    trig = Spawn( "trigger_radius", self.origin, 112, 32, 128 );
	trig thread flag_wait_delete( ender_and_cleanup_flag );
	
	trig waittill( "trigger", triggerer );
	
	if( IsDefined( trig ) )
		trig Delete();
	
	yaw = VectorToYaw( triggerer Vehicle_GetVelocity() );
	
	tread_dist				  = 64.0;
	triggerer_velocity_vector = triggerer Vehicle_GetVelocity();
	speed					  = VectorDot( triggerer_velocity_vector, AnglesToForward( ent.angles ) );
	
	ent.angles = ( ent.angles[ 0 ], yaw, ent.angles[ 2 ] );
	
	if ( speed != 0.0 )
	{
	    rotate_time = tread_dist / abs( speed );
	    ent RotatePitch( 90, rotate_time );
	    
	    ent waittill( "rotatedone" );
	    
	    wait( 5.0 );
	    
	    if( IsDefined( ent ) )
	    	ent Delete();
	}
}

disable_all_triggers()
{
	trigger_multiple 	= getentarray( "trigger_multiple", "classname" );
	trigger_radius		= getentarray( "trigger_radius", "classname" );
	trigger_flag	 	= getentarray( "trigger_multiple_flag_set", "classname" );
	trigger_damage	 	= getentarray( "trigger_damage", "classname" );
	
	foreach( trigger in trigger_multiple )
		if( isdefined( trigger.trigger_off ) )
			trigger_multiple = array_remove( trigger_multiple, trigger );
		else
			trigger trigger_off();
	foreach( trigger in trigger_radius )
		if( isdefined( trigger.trigger_off ) )
			trigger_radius = array_remove( trigger_radius, trigger );
		else
			trigger trigger_off();
	foreach( trigger in trigger_flag )
		if( isdefined( trigger.trigger_off ) )
			trigger_flag = array_remove( trigger_flag, trigger );
		else
			trigger trigger_off();
//	foreach( trigger in trigger_damage )
//		if( isdefined( trigger.trigger_off ) )
//			trigger_damage = array_remove( trigger_damage, trigger );
//		else
//			trigger trigger_off();
	
	level.player waittill( "reenable_triggers" );
	
	foreach( trigger in trigger_multiple )
	{
		if( IsDefined( trigger ) )
			trigger trigger_on();
	}
	foreach( trigger in trigger_radius )
	{
		if( IsDefined( trigger ) )
			trigger trigger_on();
	}
	foreach( trigger in trigger_flag )
	{
		if( IsDefined( trigger ) )
			trigger trigger_on();
	}
//	foreach( trigger in trigger_damage )
//	{
//		if( IsDefined( trigger ) )
//			trigger trigger_on();
//	}		trigger trigger_on();
}

//ambient tank drop
//place prefabs/satfarm/satfarm_ambient_tank_drop and give it a unique targetname
//call this function and pass in the targetname
//set fake to true if you want it to be just a script_model instead of a real vehicle
//set tank_combat to true if you want to run npc_tank_combat_init on it
#using_animtree( "vehicles" );
setup_ambient_tank_drop( targetname_of_prefab, fake, tank_combat, delete_on_flag )
{
	org = getstruct( targetname_of_prefab, "targetname" );
	ents = [];
	
	tank_ambient = undefined;
	c17_ambient = undefined;
	
	if( IsDefined( fake ) && fake == true )
	{
		tank_ambient = spawn_anim_model( "tank_ambient" );
		ents = add_to_array( ents, tank_ambient );
		
		c17_ambient = spawn_anim_model( "c17_ambient" );
		ents = add_to_array( ents, c17_ambient );
	}
	else
	{
		vehicle_spawners = getvehiclespawnerarray( targetname_of_prefab );
		foreach( vehicle_spawner in vehicle_spawners )
		{
			if( IsDefined( vehicle_spawner.script_parameters ) )
			{
				if( vehicle_spawner.script_parameters == "tank" )
				{
					tank_ambient		  = vehicle_spawner spawn_vehicle();
					tank_ambient.animname = "tank_ambient";
					tank_ambient UseAnimTree( level.scr_animtree[ tank_ambient.animname ] );
					ents			= add_to_array( ents, tank_ambient );
					level.allytanks = array_add( level.allytanks, tank_ambient );
					if( IsDefined( delete_on_flag ) )
						tank_ambient thread flag_wait_delete( delete_on_flag );
				}
				if( vehicle_spawner.script_parameters == "c17" )
				{
					c17_ambient = vehicle_spawner spawn_vehicle();
					c17_ambient.animname = "c17_ambient" ;
					c17_ambient useAnimTree( level.scr_animtree[ c17_ambient.animname ] );
					ents = add_to_array( ents, c17_ambient );
				}
			}
		}

	}
	
	org thread anim_single( ents, "ambient_drop" );
	tank_ambient thread tank_ambient_deploy_chutes( org, true ); //tank_relative is only on temp. until the anims are exported to be scripted node based
	tank_ambient thread tank_ambient_waits( tank_combat, targetname_of_prefab );
	
	if( IsDefined( fake ) && fake == true )
	{
		c17_ambient waittillmatch( "single anim", "end" );
		c17_ambient Delete();
	}
	else
	{
		start_node = GetVehicleNode( targetname_of_prefab + "_c17_start", "targetname" );
		
		c17_ambient waittillmatch( "single anim", "end" );
	
		wait( 0.05 );
	
		c17_ambient useAnimTree( #animtree );
		
		c17_ambient attach_path_and_drive( start_node, 180 );
	}
}

tank_ambient_waits( tank_combat, targetname_of_prefab )
{
	self endon( "death" );
	
	self waittillmatch( "single anim", "end" );
	
	wait( 0.05 );
	
	self useAnimTree( #animtree );
	
	start_node = GetVehicleNode( targetname_of_prefab + "_tank_start", "targetname" );
	self thread attach_path_and_drive( start_node );
	
	if( IsDefined( tank_combat ) )
		self thread npc_tank_combat_init();
}

#using_animtree( "animated_props" );
tank_ambient_deploy_chutes( org, tank_relative )
{
	model = "pilot_chute" + "_tank_ambient";
	pilot_chute = spawn_anim_model( model );

	if( IsDefined( tank_relative ) && tank_relative == true )
		org = self;
	
	pilot_chute Hide();
	
	if( IsDefined( tank_relative ) && tank_relative == true )
		pilot_chute linkto( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	main_chutes = [];
	for( i = 0; i <= 2; i++ )
	{
		model = "main_chute" + i + "_tank_ambient";
		main_chutes[ i ] = spawn_anim_model( model );
		main_chutes[ i ] Hide();
		
		if( IsDefined( tank_relative ) && tank_relative == true )
			main_chutes[ i ] linkto( self, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	}
	
	org thread anim_first_frame_solo( pilot_chute, "pilot_chute_deploy", "tag_origin" );
	
	org thread anim_first_frame( main_chutes, "main_chute_deploy", "tag_origin" );
	
	self waittillmatch( "single anim", "spawn_pilot_chute" );
	
	pilot_chute Show();
	org thread anim_single_solo( pilot_chute, "pilot_chute_deploy", "tag_origin" );
	
	level thread maps\satfarm_audio::deploychutes1();
	
	self waittillmatch( "single anim", "spawn_main_chutes" );
	
	foreach ( chute in main_chutes )
	{
		chute Show();
	}
	
	level thread maps\satfarm_audio::deploychutes2();
	org anim_single( main_chutes, "main_chute_deploy", "tag_origin" );
	
	pilot_chute Unlink();
	
	foreach ( chute in main_chutes )
		chute Unlink();
	
	wait( 5.0 );
	
	pilot_chute Delete();
	
	foreach ( chute in main_chutes )
		chute Delete();
}

attach_path_and_drive( node, immediate_speed, accelleration )
{
	if( !IsDefined( immediate_speed ) )
		immediate_speed = 45;
	if( !IsDefined( accelleration ) )
		accelleration = 15;
	
	self AttachPath( node );
	self StartPath( node );
	self thread vehicle_paths( node );	
	if( IsDefined( immediate_speed ) )
		self Vehicle_SetSpeedImmediate( immediate_speed, accelleration );
}

create_missile_attractor()
{
	level.playertank endon( "death" );
	
	level.missilefire 		= spawn_tag_origin();
	level.missilehit		= spawn_tag_origin();
	level.missilehit 		linkto( level.playertank, "tag_flash", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	//attractor 				= Missile_CreateAttractorEnt( missilehit, 10000, 10000, level.missilefire );
}
