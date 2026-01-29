#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\_hud_util;
#include maps\homecoming_util;

init_a10()
{
	PrecacheModel( "com_laptop_rugged_open_obj" );
	PrecacheModel( "vehicle_mig29_missile_alamo" );
	
	PrecacheItem( "a10_30mm_player_homecoming" );
	PrecacheItem( "remote_chopper_gunner" );
	PrecacheItem( "AGM_65" );
	
	PrecacheShader( "apache_reticle" );
	PrecacheShader( "apache_zoom_overlay" );	
	PreCacheShader( "remote_chopper_hud_target_enemy" );
	PreCacheShader( "remote_chopper_hud_target_friendly" );
	PreCacheShader( "remote_chopper_hud_target_e_vehicle" );
	PreCacheShader( "apache_warn_lock_left" );
	PreCacheShader( "apache_warn_lock_right" );
	
	level.strafeVehicles = [];
	
	flag_init( "used_a10_strafe" );
	
	array_thread( getentarray( "strafe_fov_trig", "targetname" ), ::a10_fov_trig );
}

a10_strafe_mechanic( spawnerName )
{
	level endon( "A10_MECHANIC_OFF" );
	
	level.player NotifyOnPlayerCommand( "BEGIN_A10_STRAFE", "+actionslot 4" );
	
	/*-----------------------
	WAITTILL A10 LAPTOP PICKED UP
	-------------------------*/	
	//a10_laptop_pickup();
	
	/*-----------------------
	ALLOW A10 MECHANIC
	-------------------------*/
	display_hint( "hint_a10" );
	
	vSpawners = getentarray( spawnerName, "targetname" );
	i = 0;
	while( 1 )
	{
		level.player waittill( "BEGIN_A10_STRAFE" );
		flag_set( "used_a10_strafe" );
	
		if( !isdefined( vSpawners[i] ) )
			i = 0;
		vSpawner = vSpawners[i];
		i++;
		
		a10_warthog_strafe( vSpawner );
	}
}

a10_laptop_pickup()
{
	laptop = getent( "tower_a10_laptop", "targetname" );
	laptop setmodel( "com_laptop_rugged_open_obj" );
	
	trigger = getent( laptop.target, "targetname" );
	trigger usetriggerrequirelookat();
	trigger SetHintString( &"PLATFORM_HOLD_TO_USE" );
	trigger waittill( "trigger" );
	
	laptop delete();
}

a10_destroyer_test()
{
	missile = spawn_vehicle_from_targetname_and_drive( "a10_destroyer" );
	model = spawn( "script_model", missile.origin );
	model.angles = missile.angles;
	model setmodel( "vehicle_mig29_missile_alamo" );
	model linkto( missile, "tag_origin" );
	//playfxontag( getfx( "alamo_missile_trail" ), model, "tag_fx" );
}

a10_warthog_strafe( vSpawner )
{
	/*-----------------------
	TAKE PLAYER WEAPONS
	-------------------------*/
	lastWeapon = level.player GetCurrentWeapon();
	
	level.player DisableWeaponSwitch();
	level.player giveweapon( "remote_chopper_gunner" );
	level.player SwitchToWeapon( "remote_chopper_gunner" );
	
	wait( 1.5 );
	
	fadein = maps\_hud_util::create_client_overlay( "black", 0, level.player );
	fadein maps\_hud_util::fade_over_time( 1, .4 );
	
	/*-----------------------
	SETUP STRAFE PLAYER
	-------------------------*/
	cinematicmode_on( true );
	level.player EnableInvulnerability();
	//level.player LerpFOV( 85, .05 );
	playerSpot = spawnStruct();
	playerSpot.origin = level.player.origin;
	playerSpot.angles = level.player.angles; 
	
	allies = getaiarray( "allies" );
	foreach( ally in allies )
		ally.no_friendly_fire_penalty = true;
	
	drones = level.drones[ "allies" ].array;
	foreach( drone in drones )
		drone.no_friendly_fire_penalty = true;
	
	/*-----------------------
	SETUP PLAYER WARTHOG
	-------------------------*/
	warthog = a10_player_init( vSpawner );
	
	/*-----------------------
	SETUP STRAFE TARGETS
	-------------------------*/
	warthog thread a10_create_fake_ai();
	warthog thread a10_enable_targets();
	//warthog thread a10_fov_change();
	
	/*-----------------------
	SETUP END RUN WARTHOGS
	-------------------------*/
	squadron = [];
	squadron[ squadron.size ] = warthog;
	endRun_spawners = [];
	foreach( i, warthog in squadron )
	{
		if( isdefined( warthog.script_linkto ) )
			endRun_spawners[i] = getent( warthog.script_linkto, "script_linkname" );
	}
	
	/*-----------------------
	SETUP STRAFE AMBIENT
	-------------------------*/
	//warthog thread a10_ambient_clouds();
	
//	vehicles = spawn_vehicles_from_targetname_and_drive( "a10_strafe1_vehicles" );
//	foreach( vehicle in vehicles )
//	{
//		if( vehicle isHelicopter() )
//			vehicle heli_enable_rocketDeath();
//		
//		vehicle thread a10_enable_targets();
//	}
//	
//	squadron = spawn_vehicles_from_targetname_and_drive( "a10_squadron_strafe1" );
//	foreach( v in squadron )
//		v thread playloopingfx( "a10_muzzle_flash", .05, undefined, "tag_gun" );
//	
	wait( 1 );
	fadein thread maps\_hud_util::fade_over_time( 0, 1 );
	
	thread gopath( warthog );
	
	thread a10_destroyer_test();
	
	warthog waittill( "end_run" );
	
	warthog a10_player_cleanup( playerSpot, fadein, lastWeapon );
	array_delete( squadron );
	wait( randomfloatrange( .6, .9 ) );
	level.player a10_do_shots();
	
	foreach( vSpawner in endRun_spawners )
	{
		vSpawner spawn_vehicle_and_gopath();
		
		waitNum = 0;
		if( isdefined( vSpawner.script_duration ) )
			waitNum = vSpawner.script_duration;	  
		delaythread( waitNum, ::play_sound_in_space, "a10_flyby_short", vSpawner.origin );
	}
}

a10_fov_change()
{
	
	level.player LerpFOV( 25, .05 );
	waitframe();
	level.player LerpFov( 65, 10 );
}

a10_ambient_clouds()
{
	fwd = AnglesToForward( self.angles );
	origin = self.origin + ( fwd * 5000 );
	model = spawn_tag_origin();
	
	playfxontag( getfx( "a10_clouds" ), model, "tag_origin" );
	
	self waittill( "end_run" );
	
	model delete();
}

a10_do_shots()
{
	// self = level.player	
	array = self.storeShots;

	foreach( shotSet in array )
	{
		//iprintlnbold( shotSet[ "time" ]/1000 );
		wait( shotSet[ "time" ]/1000 );
		
		foreach( spot in shotSet[ "origins" ] )
		{
			thread play_sound_in_space( "a10p_impact", spot );
			playfx( getfx( "a10_impact" ), spot );
			RadiusDamage( spot, 256, 500, 500, self, undefined, "a10_30mm_player_homecoming" );
			wait( .05 );
		}
	}
	
	self play_sound_on_entity( "a10_strafe_roar" );
}

// PLAYER LOGIC
a10_player_init( vSpawner )
{
	level.player.a10Reticle = level.player maps\_hud_util::createClientIcon( "apache_zoom_overlay", 512, 512 );
	level.player.a10Reticle maps\_hud_util::setPoint( "CENTER", undefined, 0, 0 );
	//level.player ThermalVisionOn();
	
	warthog = vSpawner spawn_vehicle();
	
	tagName = "tag_camera2";
	warthog.linker = warthog spawn_tag_origin();
	warthog.linker.angles = warthog gettagangles( tagname );
	warthog.linker linkto( warthog, tagName, ( 0,0,-55 ), ( 0,0,0 ) );

	level.player SetPlayerAngles( warthog gettagAngles( tagName ) );
	level.player playerlinktoDelta( warthog.linker, "tag_origin", 0, 30, 30, 15, 15, 1 );
	
	level.player thread a10_player_30mm( warthog );
	
	level.player thread play_loop_sound_on_entity( "a10p_jet_whine" );	
	
	PlayFXOnTag( getfx( "flying_face_fx" ), warthog.linker, "tag_origin" );
	
	return warthog;
}

a10_player_30mm( a10 )
{
	self endon( "player_warthog_finished" );
	
	self notifyOnPlayerCommand( "a10_fire_30mm", "+attack" );
	self notifyOnPlayerCommand( "a10_stop_fire_30mm", "-attack" );
	
	//self thread a10_player_targeting( a10 );
	
	self.storeShots = [];
	
	startTime = gettime();
	time = 0;
	first = true;
	while( 1 )
	{
		self waittill( "a10_fire_30mm" );
		
		if( !isdefined( first ) )
			time = gettime() - startTime;
		first = undefined;
		self childthread a10_player_30mm_fire( a10, time );
		
		self waittill( "a10_stop_fire_30mm" );
		
		startTime = gettime();
		
		a10.firing_sound_ent thread sound_fade_and_delete( 0.05 );
		thread aud_30mm_tail();
	}
}

a10_player_30mm_fire( a10, time )
{
	self endon( "a10_stop_fire_30mm" );
	
	a10.firing_sound_ent = Spawn( "script_origin", (0, 0, 0));
	a10.firing_sound_ent thread play_loop_sound_on_entity( "a10p_gatling_loop" );
	
	num = self.storeShots.size;
	//iprintlnbold( num );
	self.storeShots[ num ] = [];
	self.storeShots[ num ][ "time" ] = time;
	self.storeShots[ num ][ "origins" ] = [];
	
	lastShotTime = 0;
	while( 1 )
	{
		fwd = anglestoforward( a10 gettagangles( "tag_gun" ) );
		start = a10 gettagorigin( "tag_gun" ) + ( fwd * 500 );
		
		if( !isdefined( self.a10Target ) )
		{
			fwd = AnglesToForward( self GetPlayerAngles() );
			end = self geteye() + ( fwd * 99999 );	
		}
		else
		{
			targetOrigin = self.a10Target gettagorigin( "tag_origin" );
			fwd = anglestoforward( self.a10Target.angles );
			end = targetOrigin + ( fwd * 150 );
			//end = end + ( 0,0,50 );
		}
		
		//magicbullet( "a10_30mm_player_homecoming", start, end, level.player );
		trace = BulletTrace( start, end, false );
		playfx( getfx( "a10_impact" ), trace[ "position" ] );
		otherNum = self.storeShots[ num ][ "origins" ].size;
		self.storeShots[ num ][ "origins" ][ otherNum ] = trace[ "position" ];
		
		playfxontag( getfx( "a10_muzzle_flash" ), a10, "tag_gun" );
		
		earthquake( 0.22, 0.05, self.origin, 999999 );
		
		self PlayRumbleOnEntity( "ac130_25mm_fire" );
		
		wait( .05 );
	}
}

aud_30mm_tail()
{
	loc2 = Spawn( "script_origin", (0, 0, 0));
	loc2 playsound("a10p_gatling_tail", "soundone");
	loc2 waittill("sounddone");
	loc2 delete();
}

A10_TARGETER_FOVCHECK = 7;
A10_MAX_TARGET_DIST = 10000;
a10_player_targeting( a10 )
{
	self endon( "player_warthog_finished" );
	
	targeter = spawn_tag_origin();
	targeter linktoplayerview( self, "tag_origin", ( 200,0,0 ), ( 0,0,0 ), false );
	playerLinked = true;
	self.a10Targeter = targeter;
	//Target_Set( targeter );
	//target_setdelay( targeter, 1 );
	fovCheck = cos( A10_TARGETER_FOVCHECK );
	
	//waittill_forever();
	while( 1 )
	{
		wait( .05 );
		
		pAngles = self getPlayerAngles();
		
		// Check to see if we even need to check other targets 
		if( isdefined( self.a10Target ) )
		{	
			if( self.a10Target within_fov( self.origin, pAngles, self.a10Target.origin, fovCheck ) )
				continue;	
		}
		
		fovVehicles = [];
		foreach( vehicle in level.strafeVehicles )
		{
			if( vehicle within_fov( self.origin, pAngles, vehicle.origin, fovCheck ) )
				fovVehicles[ fovVehicles.size ] = vehicle;
		}
		
		if( fovVehicles.size > 0 )
		{
			vehicle = getClosest2D( self.origin, fovVehicles, A10_MAX_TARGET_DIST );
			if( isdefined( vehicle ) )
			{
				// Need to check if targeter is linked to player or not
				if( playerLinked )
				{
					targeter UnlinkFromPlayerView( self );
					playerLinked= false;
				}
				else
					targeter unlink();
				
				//targeter linkto( vehicle, "tag_origin", ( 0,0,0 ), ( 0,0,0 ) );
				//targeter thread targeter_moveTo_target( vehicle );
				self.a10Target = vehicle;
			}
		}
		else
		{
			targeter unlink();
			self.a10Target = undefined;
		}
		
		if( isdefined( self.a10Target ) )
			continue;
		
		if( playerLinked == false )
		{
			targeter unlink();

			self notify( "new_target" );
			targeter linktoplayerview( self, "tag_origin", ( 200,0,0 ), ( 0,0,0 ), false );
			playerLinked = true;	
		}
		
		//fwd = AnglesToForward( pAngles );
		//targeter.origin = self geteye() + ( fwd * 300 );
	}
}

targeter_moveTo_target( target )
{
	self notify( "new_target" );
	self endon( "new_target" );
	
	target endon( "death" );
	
	moveDist = 800;
	 
	while( DistanceSquared( self.origin, target.origin ) > squared( moveDist*2 ) )
	{
		fwd = vectorNormalize( target.origin - self.origin );
		newOrigin = self.origin + ( fwd * moveDist );
		
		self.origin = newOrigin;
		wait( .05 );
	}
	
	self linkto( target, "tag_origin", ( 0,0,0 ), ( 0,0,0 ) );
}

a10_enable_targets()
{
	level.player endon( "player_warthog_finished" );
	
	while( 1 )
	{
		// VEHICLE TARGETS
		vehicleArray = level.strafeVehicles;
		
		// AI+DRONE TARGETS
		dronesArray = array_combine( level.drones[ "allies" ].array, level.drones[ "axis" ].array );
		targetsArray = array_combine( getAIArray( "allies", "axis" ), dronesArray );
		targetsArray = array_combine( self.fakeAI, targetsArray );

		targetsArray = array_combine( targetsArray, vehicleArray );
		
		foreach( thing in targetsArray )
		{
			
			if( isdefined( thing.alreadyTarget ) )
				continue;
			
			if( thing isVehicle() )
			{
				thing.alreadyTarget = true;
				Target_Set( thing, ( 0, 0, 32 ) );
				Target_SetScaledRenderMode( thing, true );
				Target_SetShader( thing, "remote_chopper_hud_target_e_vehicle" );
				
				thing thread Remove_Target_On_Death();
			}
			else if( IsAI( thing ) )
			{
				if( isdefined( thing.team ) && thing.team == "axis" )
				{
					thing.alreadyTarget = true;
					
					//Target_Alloc( thing, ( 0, 0, 32 ) );
					Target_set( thing, ( 0, 0, 32 ) );
					//Target_SetShader( thing, "remote_chopper_hud_target_enemy" );
				
					Target_DrawSquare( thing, 24 );
				
					//Target_SetColor( thing, ( 1, 0, 0 ) );
				
					Target_SetMaxSize( thing, 15 );
					Target_SetMINSize( thing, 5, false );
				
					//Target_Flush( thing );
					//Target_SetShader( thing, "remote_chopper_hud_target_enemy" );

					//Target_SetOffscreenShader( ai, "veh_hud_target_offscreen" );	
					
					thing thread Remove_Target_On_Death();
				}
			}
			
			wait( .05 );
		}
		
		wait( .05 );
	}
}

Remove_Target_On_Death()
{
	self add_wait( ::waittill_msg, "death" );
	self add_wait( ::waittill_msg, "ragdoll" );
	level.player add_wait( ::waittill_msg, "player_warthog_finished" );
	do_wait_any();
	
	if ( IsDefined( self ) && Target_IsTarget( self ) )
	{
		Target_Remove( self );
	}
}

a10_create_fake_ai()
{
	spots = getstructarray( "beach_a10_fake_ai", "targetname" );
	model = "mw_test_soldier";
	self.fakeAI = [];
	
	foreach( spot in spots )
	{
		amount = randomintrange( 10, 15 );
		for( i=0; i<amount; i++ )
		{
			point = return_point_in_circle( spot.origin, spot.radius );
			fakeAI = spawn( "script_model", point );
			fakeAI setmodel( "mw_test_soldier" );
			fakeAI.angles = ( 0,0,0 );
			
			fakeAI thread a10_fake_ai_death();
			
			
			self.fakeAI[ self.fakeAI.size ] = fakeAI;
		}
	}
}

a10_fake_ai_death()
{
	trigger = spawn( "trigger_radius", self.origin, 0, 28, 56 );
	trigger SetCanDamage( true );
	
	level.player add_wait( ::waittill_msg, "player_warthog_finished" );
	trigger add_wait( ::waittill_msg, "damage" );
	do_wait_any();
	
	self delete();	
	trigger delete();
}

a10_enable_targets_old()
{
	level.player endon( "player_warthog_finished" );
	
	//self ThermalDrawEnable();
	self HudOutlineEnable();
	self childthread target_enable_targeting();
	
	self add_wait( ::waittill_msg, "death" );
	//self add_wait( ::waittill_msg, "out_of_range" );
	do_wait_any();
	
	level.strafeVehicles = array_remove( level.strafeVehicles, self );
	
	if( Target_IsTarget( self ) )
		Target_Remove( self );
	
	self HudOutlineDisable();
	//self ThermalDrawDisable();
	
	if( isdefined( level.player.a10Target ) )
	{
		if( self == level.player.a10Target )
			level.player.a10Target = undefined;
	} 
}

target_enable_targeting()
{
	self endon( "death" );
	
	maxTargetDist = squared( A10_MAX_TARGET_DIST );
	while( DistanceSquared( level.player.origin, self.origin ) > maxTargetDist )
		wait( .05 );
	
	self childthread target_outofrange_check();
	
	level.strafeVehicles[ level.strafeVehicles.size ] = self;

	Target_Set( self );
	Target_SetScaledRenderMode( self, true );
	//Target_SetColor( self, ( 0,0,0 ) );	
}

A10_OUTOFRANGE_DIST = 1500;
target_outofrange_check()
{
	outofrangeDist = squared( A10_OUTOFRANGE_DIST );
	while( 1 )
	{
		dist = DistanceSquared( self.origin, level.player.origin );
		if( dist <= outofrangeDist )
			break;
		
		wait( .05 );
	}
	
	self notify( "out_of_range" );
}

a10_fov_trig()
{
	self waittill( "trigger" );
	
	iprintln( "fov change" );
	
	goalFov = self.script_count;
	time = self.script_timer;
	
	assert( isdefined( goalFov ) );
	assert( isdefined( time ) );
	
	level.player LerpFOV( goalFov, time );
}

a10_missile_lockon()
{
	lockonHudLeft = level.player createClientIcon( "apache_warn_lock_left", 128, 128 );
	lockonHudLeft setPoint( "CENTER", "CENTER", -185, 0 );
	lockonHudLeft.alpha = 0;
	
	lockonHudRight = level.player createClientIcon( "apache_warn_lock_right", 128, 128 );
	lockonHudRight setPoint( "CENTER", "CENTER", 185, 0 );
	lockonHudRight.alpha = 0;
	
	
}

a10_player_cleanup( playerSpot, fadein, lastWeapon )
{
	fadein thread maps\_hud_util::fade_over_time( 1, .3 );
	
	level.player notify( "player_warthog_finished" );
	
	wait( .3 );

	/*-----------------------
	CLEANUP HUD
	-------------------------*/
	//level.player ThermalVisionOff();
	level.player.a10Reticle destroy();
	level.player LerpFOV( 65, .05 );
	level.player unlink();
	self.linker delete();
	//level.player.a10Targeter delete();
	
	/*-----------------------
	CLEANUP A10 SOUND STUFF
	-------------------------*/
	if( isdefined( self.firing_sound_ent ) )
		self.firing_sound_ent thread sound_fade_and_delete( 0.05 );
	level.player thread stop_loop_sound_on_entity( "a10p_jet_whine" );	
	
//	foreach( vehicle in level.strafeVehicles )
//		vehicle delete();
	
	teleport_player( playerSpot );	
	cinematicmode_off( true );
	
	level.player DisableInvulnerability();
	fadein thread maps\_hud_util::fade_over_time( 0, .3 );
	
	/*-----------------------
	GIVE BACK WEAPONS
	-------------------------*/
	level.player switchtoweapon( lastWeapon );
	level.player delaycall( 1, ::takeweapon, "remote_chopper_gunner" );
	level.player delaycall( 1, ::EnableWeaponSwitch, "remote_chopper_gunner" );
}

a10_hint_func()
{
	return flag( "used_a10_strafe" );
}