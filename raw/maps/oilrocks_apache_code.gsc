#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_vo;

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Mission Fail Helpers
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

on_death_mission_fail( nofity_cancel, quote_fail, radio_fail )
{
	if ( IsDefined( nofity_cancel ) )
		level endon( nofity_cancel );
	
	self waittill( "death", attacker );
	
	mission_fail( quote_fail, radio_fail );
}

mission_fail( quote_fail, radio_fail )
{
	Assert( IsDefined( quote_fail ) );
	SetDvar( "ui_deadquote", quote_fail );
	if ( IsDefined( radio_fail ) )
		thread smart_radio_dialogue( radio_fail );
	missionFailedWrapper();
}

on_damage_turret_push_friendly_fire( damage_override )
{
	
	self endon( "death" );
	
	while ( 1 )
	{
		damage	  = undefined;
		attacker  = undefined;
		direction = undefined;
		point	  = undefined;
		type	  = undefined;
		
		self waittill( "damage", damage, attacker, direction, point, type );
		
		player_turret = IsDefined( attacker ) && isTurret( attacker ) && IsDefined( attacker.owner ) && IsPlayer( attacker.owner );
		
		if ( player_turret )
		{
			// The weapon param in the above waittill was coming back undefined. _friendlyFire takes an undefined weapon
			// and sets it to attackee.damageWeapon which in this case is none. This causes the damage to be ignored because
			// "none" damage is assumed to be a barrel. Set this to turret to get the damage through the friendly fire system.
			weapon = "turret";
			
			damage = ter_op( IsDefined( damage_override ), damage_override, damage );
			
			self notify( "friendlyfire_notify", damage, attacker.owner, direction, point, type, weapon );
		}
	}
}


// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Helicopter Path Attack Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

CONST_APACHE_PLAYER_MAX_HEIGHT		   = 4096;
CONST_APACHE_PLAYER_MIN_HEIGHT_TUT_FLY = 0;
CONST_APACHE_PLAYER_MIN_HEIGHT_DEFAULT = 1024;

CONST_APACHE_ALLY_ATTACK_TIME_MG_SEC = 6;
CONST_APACHE_ALLY_ATTACK_LOC_RANGE	 = 5000;

apache_ally_path_attack_func( path_ent )
{
	self notify( "apache_ally_path_attack_func" );
	self endon( "apache_ally_path_attack_func" );
	
	// Don't start firing until half way through the delay
	if ( IsDefined( path_ent.script_delay ) )
		wait( path_ent.script_delay * 0.5 );
	
	// If attacking is being overridden, don't fire
	if ( self ent_flag( "apache_ally_attack_override" ) )
		return;
	self endon( "apache_ally_attack_override" );
	
	target_area_ent = GetEnt( path_ent.script_linkto, "script_linkname" );
	AssertEx( IsDefined( target_area_ent ), "Ally chopper path ent flagged for fireLink but a linked ent could not be found." );
	
	// If the target_area_ent has a script_noteworthy, look for an
	// available target with that script_noteworthy
	if ( IsDefined( target_area_ent.script_noteworthy ) )
	{
		entities = GetEntArray( target_area_ent.script_noteworthy, "script_noteworthy" );
		target	 = undefined;
		foreach ( ent in entities )
		{
			if ( IsDefined( ent ) && ent != target_area_ent && !IsSpawner( ent ) )
			{
				target = ent;
				break;
			}
		}
		
		if ( IsDefined( target ) )
		{
			self vehicle_attack_missile( target, true );
		}
	}
	else
	{
		ignore_targets = false;
		if ( IsDefined( target_area_ent.script_parameters ) && IsSubStr( target_area_ent.script_parameters, "ignoretargets" ) )
		{
			ignore_targets = true;
		}
		
		self childthread apache_ally_path_attack_internal( target_area_ent, true, CONST_APACHE_ALLY_ATTACK_LOC_RANGE, ignore_targets );
	}
}

apache_ally_path_attack_internal( target_area_ent, homing, dist_max, ignore_targets )
{
	target_ent = target_area_ent;
	
	// Search for targets around the targeted area
	if ( !IsDefined( ignore_targets ) || !ignore_targets )
	{
		target_array = Target_GetArray();
		
		if ( target_array.size )
		{
			target_array = apache_ally_path_attack_filter_targets( target_area_ent.origin, target_array, dist_max );
		}
		
		// If no targets were found, just hit the target_area_ent
		target_ent = ter_op( target_array.size, target_array[ 0 ], target_area_ent );
	}
	
	if ( IsAI( target_ent ) )
	{
		self heli_attack_mg( target_ent, CONST_APACHE_ALLY_ATTACK_TIME_MG_SEC );
	}
	else
	{
		self vehicle_attack_missile( target_ent, homing );
	}
}

heli_attack_mg_veh_weapon( target, time )
{
	self endon( "death" );
	
	self notify( "heli_attack_mg_stop" );
	self endon( "heli_attack_mg_stop" );
	
	self SetTurretTargetEnt( target );
	
	fire_delay = 0.1;
	
	while ( 1 )
	{
		
		self FireWeapon();
		wait fire_delay;
		
		time -= fire_delay;
		if ( time <= 0 )
			break;
	}
	
	self ClearTurretTarget();
}

heli_attack_mg( target, time )
{
	self endon( "death" );
	
	self notify( "heli_attack_mg_stop" );
	self endon( "heli_attack_mg_stop" );
	
	array_call( self.mgturret, ::TurretFireEnable );
	array_call( self.mgturret, ::SetTargetEntity, target, ( 0, 0, 24 ) );
	
	fire_delay = 0.1;
	
	while ( 1 )
	{
		array_call( self.mgturret, ::ShootTurret );
		wait fire_delay;
		
		time -= fire_delay;
		if ( time <= 0 )
			break;
	}
	
	array_call( self.mgturret, ::TurretFireDisable );
	array_call( self.mgturret, ::SetMode, "manual" );
}

vehicle_attack_missile( target, homing, ammo_override )
{
	AssertEx( IsDefined( target ), "vehicle_attack_missile() called with undefined taret" );
	AssertEx( IsDefined( homing ), "vehicle_attack_missile() called without specifying homing missile or not." );
	
	if ( !IsDefined( target ) || !IsDefined( homing ) )
		return;
	
	self notify ( "new_vehicle_attack_missile" );
	self endon ( "new_vehicle_attack_missile" );
	
	i			 = cointoss();
	ammo		 = undefined;
	weapon_name	 = undefined;
	tag_fire_l	 = undefined;
	tag_fire_r	 = undefined;
	fire_delay	 = undefined;
	magic_bullet = undefined;
	
	if ( IsSubStr( self.classname, "apache" ) )
	{
		ammo		   = ter_op( homing, 2, 4 );
		weapon_name	   = ter_op( homing, "apache_lockon_missile_ai", "apache_hellfire_missile_ai" );
		weapon_default = undefined;
		tag_fire_l	   = ter_op( homing, "tag_flash_11", "tag_flash_3" );
		tag_fire_r	   = ter_op( homing, "tag_flash_2", "tag_flash_22" );
		fire_delay	   = ter_op( homing, 0.6, 0.05 );
		magic_bullet   = false;
	}
	else if ( IsSubStr( self.classname, "hind" ) )
	{
		ammo		   = ter_op( homing, 1, 2 );
		weapon_name	   = ter_op( homing, "apache_lockon_missile_ai_enemy", "apache_hellfire_missile_ai" );
		weapon_default = "hind_turret";
		
//		tag_fire_l	   = ter_op( homing, "tag_flash_left", "tag_flash_4" );
//		tag_fire_r	   = ter_op( homing, "tag_flash_right", "tag_flash_3" );
		
		tag_fire_l	   = "tag_flash_left";
		tag_fire_r	   = "tag_flash_right";
		fire_delay	   = ter_op( homing, 0.6, 0.05 );
		magic_bullet   = false;
	}
	else if ( IsSubStr( self.classname, "_gunboat" ) )
	{
		AssertEx( homing, "Gunboat asked to fire non homing missile." );
		
		ammo		   = 1;
		weapon_name	   = "apache_lockon_missile_ai_enemy";
		weapon_default = undefined;
		tag_fire_l	   = "tag_turret";
		tag_fire_r	   = "tag_turret";
		fire_delay	   = 0.6;
		magic_bullet   = true;
	}
	else
	{
		AssertMsg( "Unhandled classname for AI controlled vehicle: " + self.classname );
		return;
	}
	
	ammo = ter_op( IsDefined( ammo_override ), ammo_override, ammo );
	
	fire_time	= WeaponFireTime( weapon_name );
	
	target_dummy = target spawn_tag_origin();
	target_dummy SetCanDamage( false );
	
	// If this is a helicopter, don't shoot at the origin because this
	// tag is up at the rotor
	if ( IsDefined( target.vehicletype ) )
	{
		link_offset = undefined;
		if ( target isHelicopter() )
		{
			if ( target == get_apache_player() )
			{
				link_offset = ( 0, 0, -96 );
			}
			else
			{
				link_offset = ( 0, 0, -48 );
			}
		}
		else
		{
			link_offset = ( 0, 0, 48 );
		}
		
		target_dummy LinkTo( target, "tag_origin", link_offset, ( 0, 0, 0 ) );
	}
	else if ( IsAI( target ) )
	{
		link_offset = ( 0, 0, 24 );
		target_dummy LinkTo( target, "tag_origin", link_offset, ( 0, 0, 0 ) );
	}
	else
	{
		target_dummy LinkTo( target );
	}
	
	target_dummy.missiles_waiting = ammo;
	target_dummy.missiles_chasing = 0;
	
	if ( !magic_bullet )
	{
		self SetVehWeapon( weapon_name );
	}
	
	while ( ammo )
	{
		fire_tag = ter_op( ( ammo + i ) % 2, tag_fire_l, tag_fire_r );
		
		missile = undefined;
		if ( !magic_bullet )
		{
			missile = self FireWeapon( fire_tag, target_dummy );
		}
		else
		{
			tag_origin = self GetTagOrigin( fire_tag );
			direction  = VectorNormalize( target.origin - tag_origin );
			missile	   = MagicBullet( weapon_name, tag_origin + direction * 60, tag_origin + direction * 120 );
		}
		missile missile_setTargetAndFlightMode( target_dummy, "direct" );
		
		// Play flash fx
		PlayFX( getfx( "FX_apache_ai_hydra_rocket_flash_wv" ), self GetTagOrigin( fire_tag ), AnglesToForward( self GetTagAngles( fire_tag ) ) );
		
		self attack_missile_set_up_and_notify( missile, target, homing, target_dummy );
		
		missile thread vehicle_attack_missile_dummy_delete( target_dummy );
		ammo--;
		
		if ( ammo > 0 )
			wait fire_time + fire_delay;
	}
	
	if ( IsDefined( weapon_default ) )
	{
		self SetVehWeapon( weapon_default );
	}
}

attack_missile_set_up_and_notify( missile, target, homing, target_dummy )
{
	if ( homing )
		missile.type_missile = "guided";
	else
		missile.type_missile = "straight";
	
	// handle the missile missing its target
	missile thread vehicle_scripts\_chopper_missile_defense_utility::missile_monitorMissTarget( target, false, undefined, "LISTEN_missile_missed_target", "LISTEN_missile_attached_to_flare" );
	
	missile childthread earthquake_on_death_missile();
	
	// This tells the player missile defense systems that the enemy fired
	self notify( "LISTEN_missile_fire_self", missile );
	
	if ( IsDefined( target.heli ) && IsDefined( target.heli.owner ) && IsPlayer( target.heli.owner ) )
	{
		target.heli.owner notify( "LISTEN_missile_fire", missile );
	}
	else
	{
		target notify( "LISTEN_missile_fire", missile );
	}
}

ai_attack_missile( target, homing )
{
	eye = self GetTagOrigin( "tag_eye" );
	dir = VectorNormalize( target.origin - eye );
	
	start = eye + dir * 36;
	end	  = eye + dir * 120;
	
	offset = ( 0, 0, 0 );
	if ( target isVehicle() && target isHelicopter() )
	{
		if ( target == get_apache_player() )
		{
			offset = ( 0, 0, -96 );
		}
		else
		{
			offset = ( 0, 0, -48 );
		}
	}
	
	missile	= MagicBullet( "apache_lockon_missile_ai_enemy", start, end );
	missile missile_setTargetAndFlightMode( target, "top", offset );
	
	PlayFX( getfx( "FX_apache_ai_hydra_rocket_flash_wv" ), start, VectorNormalize( end - start ) );
	
	self attack_missile_set_up_and_notify( missile, target, homing );
}

vehicle_attack_missile_dummy_delete( dummy )
{
	missile = self;
	
	dummy.missiles_waiting--;
	dummy.missiles_chasing++;
	
	missile waittill( "death" );
	
	dummy.missiles_chasing--;
	
	if ( dummy.missiles_waiting > 0 )
		return;
	
	if ( dummy.missiles_chasing <= 0 )
	{
		dummy Unlink();
		wait 0.05;
		dummy Delete();
	}
}

apache_ally_path_attack_filter_targets( origin, targets, max_dist )
{
	if ( !targets.size )
		return targets;
	
	return get_array_of_closest( origin, targets, undefined, undefined, max_dist );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Helicopter Ally Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

spawn_apache_allies( struct_base_name )
{
	Assert( IsDefined( struct_base_name ) );
	level.helicopter_fireLinkFunk = ::apache_ally_path_attack_func;

	apaches	   = [];
	apache_ids = [ 1, 2 ];
	origin	   = undefined;
	angles	   = undefined;
	
	foreach ( id in apache_ids )
	{
		struct					= getstruct( struct_base_name + id, "targetname" );
		apaches[ apaches.size ] = spawn_apache_ally( id, struct.origin, struct.angles );
	}
	return apaches;
}

spawn_apache_ally( id, origin, angles )
{
	targetname = "apache_ally_spawner_0" + id;
	out_vehicle_targetname = "apache_ally_0" + id;
	return spawn_apache_ally_targetname( targetname, out_vehicle_targetname, origin, angles );
}

spawn_apache_ally_targetname( targetname, out_vehicle_targetname, origin, angles )
{
	spawner = GetEnt( targetname, "targetname" );
	
	spawner.origin = ter_op( IsDefined( origin ), origin, spawner.origin );
	spawner.angles = ter_op( IsDefined( angles ), angles, spawner.angles );
	
	apache					 = vehicle_spawn( spawner );
	apache.targetname		 = out_vehicle_targetname;
	apache.script_noteworthy = "apache_allies";
	
	apache.godmode			 = true;
	
	apache ent_flag_init( "apache_ally_attack_override" );
	
	apache heli_ai_collision_cylinder_add();
	
	// These choppers fly way too high for this to ever look good
	apache notify ( "stop_kicking_up_dust" );
	
	apache.mgturret[ 0 ] TurretFireDisable(	 );
	apache.mgturret[ 0 ] SetMode( "manual" );
	
	apache.missileDefense = vehicle_scripts\_chopper_ai_missile_defense::_init( apache, 3 );
	apache.missileDefense thread vehicle_scripts\_chopper_ai_missile_defense::_start();
	
	return apache;
	
}

get_apache_players()
{
	apaches = [];
	
	foreach ( player in level.players )
	{
		if ( IsDefined( player.drivingVehicle ) && player.drivingVehicle isHelicopter() )
		{
			apaches[ apaches.size ] = player.drivingVehicle;
		}
	}
	
	return apaches;
}

get_apache_allies()
{
	apaches = GetEntArray( "apache_allies", "script_noteworthy" );
	
	return apaches;
}

get_apache_ally( id )
{
	apache = GetEnt( "apache_ally_0" + id, "targetname" );
	AssertEx( IsDefined( apache ), "No ally apache could be found with ID: " + id );
	
	return apache;
}

get_apache_ally_id()
{
	return Int( GetSubStr( self.targetname, self.targetname.size - 1 ) );
}

get_apache_player()
{
	return GetEnt( "apache_player", "targetname" );
}

is_apache_player( target )
{
	apache_player = get_apache_player();
	return IsDefined( target ) && IsDefined( apache_player ) && apache_player == target;
}

friendly_setup_apache_section( turret_damage_override )
{
	self thread on_damage_turret_push_friendly_fire( turret_damage_override );
}

spawn_blackhawk_ally( struct_name, optional_position, optional_angles, spawn_riders )
{
	if ( !IsDefined( spawn_riders ) )
		spawn_riders = true;
	
	struct = undefined;
	if ( IsDefined( struct_name ) )
		struct	= getstruct( struct_name, "targetname" );
	if ( IsDefined( optional_position ) )
	{
		struct = SpawnStruct();
		struct.origin = optional_position;
	}
	
	if ( IsDefined( optional_angles ) )
	{
	   	struct.angles = optional_angles;
	}
	
	spawner = GetEnt( "blackhawk_ally_spawner", "targetname" );
	
	spawner.origin = struct.origin;
	spawner.angles = struct.angles;
	
	blackhawk					= vehicle_spawn( spawner );
	blackhawk.targetname		= "blackhawk_ally";
	blackhawk.script_noteworthy = "blackhawk_ally";
	blackhawk godon();
	
	blackhawk heli_ai_collision_cylinder_add();
	
	blackhawk notify ( "stop_kicking_up_dust" );
	

	ride_spawners =	GetEntArray( "blackhawk_riders", "script_noteworthy" );
	array_thread( ride_spawners, ::add_spawn_function, ::asign_blackhawk_riders );
	
	if ( spawn_riders )
		spawn_infantry_in_blackhawk();
	
	return blackhawk;
}

spawn_infantry_in_blackhawk()
{
	blackhawk = get_blackhawk_ally();
	// Add infantry team a in positions to fastrope down
	spawners = GetEntArray( "team_a", "targetname" );
	spawners = array_keep_key_values( spawners, "script_noteworthy", [ "blackhawk_riders" ] );
	foreach ( idx, spawner in spawners )
	{
		spawner.count = 1; // replenish the count because I spawn these guys a couple times right now.
		ai = spawner spawn_ai( true );
		spawner.script_friendname = ai.name;
		ai friendly_setup();
		ai friendly_setup_apache_section( 10 );
		ai set_ignoreme( true );
		ai ThermalDrawDisable();
		ai.script_startingposition = idx + 2;
		blackhawk guy_enter_vehicle( ai );
	}
}

asign_blackhawk_riders()
{
	if ( !IsDefined( level.infantry_guys ) )
		level.infantry_guys = [];
	else
		level.infantry_guys = array_remove_undefined_dead_or_dying( level.infantry_guys ); // for the second spawning of the blackhawk.
	if ( IsDefined( self.script_friendName ) && self.script_friendName == "HeroGuy" )
		level.HeroGuy = self;
	level.infantry_guys = array_add( level.infantry_guys, self );
}

get_blackhawk_ally()
{
	blackhawk = GetEnt( "blackhawk_ally", "targetname" );
	return blackhawk;
}

get_apaches_ally_and_player()
{
	return array_combine( get_apache_allies(), get_apache_players() );
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Helicopter Enemy Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

get_hinds_enemy_active()
{
	enemy_hinds_active = GetEntArray( "enemy_hinds_active", "script_noteworthy" );
	if ( !enemy_hinds_active.size )
	{
		foreach ( vehicle in Vehicle_GetArray() )
			if( IsAlive(vehicle) )
				if ( IsDefined( vehicle.script_team ) && vehicle.script_team == "axis" )
					enemy_hinds_active[ enemy_hinds_active.size ] = vehicle;
	}
	return enemy_hinds_active;
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Helicopter AI Logic: Enemy and Friendly
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

heli_ai_collision_cylinder_setup()
{
	level.heli_collision_ai = GetEntArray( "heli_collision_ai_mesh", "targetname" );
	
	foreach ( ent in level.heli_collision_ai )
	{
		ent.start_origin = ent.origin;
		ent.start_angles = ent.angles;
		ent.in_use		 = false;
	}
}

heli_ai_collision_cylinder_add()
{
	AssertEx( IsDefined( level.heli_collision_ai ) && level.heli_collision_ai.size, "heli_ai_collision_cylinder_add() called without initiallizing the cylinder collision logic." );
	
	Cylinder = undefined;
	
	foreach ( ent in level.heli_collision_ai )
		if ( !ent.in_use )
			Cylinder = ent;
	
	AssertEx( IsDefined( Cylinder ), "heli_ai_collision_cylinder_add() failed to grab a valid heli ai collision brush model." );
	
	if ( IsDefined( Cylinder ) )
	{
		Cylinder.in_use = true;
		Cylinder.origin = self.origin;
		Cylinder.angles = self.angles;
		Cylinder LinkTo( self, "tag_origin" );
		self thread heli_ai_collision_cylinder_on_death_remove( Cylinder );
	}
}

heli_ai_collision_cylinder_on_death_remove( Cylinder )
{
	self waittill( "death" );
	
	Cylinder Unlink();
	Cylinder.origin = Cylinder.start_origin;
	Cylinder.angles = Cylinder.start_angles;
	Cylinder.in_use = false;
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		AI Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

add_as_apache_target_on_spawn()
{
	self thread _add_as_apache_target_on_spawn_iternal();
}

_add_as_apache_target_on_spawn_iternal()
{
	if ( IsDefined( self.script_parameters ) && IsSubStr( self.script_parameters, "addastargetonflag" ) )
	{
		self endon( "death" );
		ent_flag_init( "ENT_FLAG_add_as_target" );
		ent_flag_wait( "ENT_FLAG_add_as_target" );
	}
	
	if ( IsAI( self ) && IsDefined( self.script_vehicleride ) )
	{
		self endon( "death" );
		self ai_waittill_entered_vehicle();
		self waittill( "jumping_out" );
		wait 3.5;
	}
	
	self add_as_apaches_target();
}

add_as_apaches_target( delay )
{
	lock( "add_apache_target_lock" );
	if( !IsDefined( level.apache_target_manager ) )
		level.apache_target_manager = [];
	level.apache_target_manager[ level.apache_target_manager.size ] = self;
	level.apache_target_manager = array_remove_undefined_dead_or_dying( level.apache_target_manager );
	
	apaches = get_apache_players();
	foreach ( apache in apaches )
	{
		self thread addAsApacheHudTarget( apache, delay );
	}
	unlock( "add_apache_target_lock" );
}

update_targets( delay )
{
	if ( !IsDefined( level.apache_target_manager ) )
		return;
	level.apache_target_manager = array_remove_undefined_dead_or_dying( level.apache_target_manager );
		apaches = get_apache_players();
	foreach ( apache in apaches )
	{
		foreach( guy in level.apache_target_manager )
			guy addAsApacheHudTarget( apache, delay );
	}
}

ai_waittill_entered_vehicle()
{
	if ( !IsDefined( self.ridingvehicle ) )
		self waittill_any( "death", "enteredvehicle" );
	
	while ( IsAlive( self ) && !IsDefined( self.ridingvehicle ) )
		wait 0.05;
	
	if ( !IsAlive( self ) )
		return false;
	
	return true;
}

ai_rider_invulnerable_until_vehicle_death()
{
	entered = self ai_waittill_entered_vehicle();
	
	if ( !entered )
		return;
	
	AssertEx( IsDefined( self.ridingvehicle ), "The enemy should be assigned to a vehicle at this point." );
	
	self endon( "death" );
	self endon( "jumping_out" );
	
	self deletable_magic_bullet_shield();
	
	// If this guy jumps out, remove the magic_bullet_shield
	self thread ai_rider_invulnerable_until_vehicle_death_or_jumping_out();
	
	self.ridingvehicle waittill( "death" );
	
	self stop_magic_bullet_shield();
}

ai_rider_invulnerable_until_vehicle_death_or_jumping_out()
{
	self endon( "death" );
	self endon( "stop_magic_bullet_shield" );
	
	self waittill( "jumping_out" );
	
	self stop_magic_bullet_shield();
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Ground Vehicle Logic: Attack and Setup
//			- ZPU, GAZ
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
vehicle_spawners_adjust_health_and_damage_targetname( targetname )
{
	spawners = GetEntArray( targetname, "targetname" );
	foreach ( spawner in spawners )
	{
		spawner vehicle_spawner_adjust_health_and_damage();
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		AI Vehicle Stats
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

CONST_ENEMY_HIND_DAMAGE_STATES				= 1;		 //Number of damage states for the chopper including the starting healthy state
CONST_ENEMY_HIND_DAMAGE_ROCKET_ADJUST_DELAY = 1.0;		 //Number of seconds to delay after missile damage before allowing another missile's damage to be scaled. Prevents two quick rockets from blowing up hind.


vehicle_spawner_adjust_health_and_damage()
{
	AssertEx( IsDefined( self ) && IsSpawner( self ), "vehicle_spawner_adjust_health_and_damage() with self that is not a spawner." );
	AssertEx( IsDefined( self ) && IsDefined( self.code_classname ) && self.code_classname == "script_vehicle", "vehicle_spawner_adjust_health_and_damage() with self that is not a vehicle spawner." );
	
	dmg_adjust = false;
	dmg_states = 1;
	dmg_delay  = undefined;
	health	   = undefined;
	
	if ( IsSubStr( self.classname, "_hind_" ) )
	{
		health	   = level.apache_difficulty.enemy_hind_health;
		dmg_states = CONST_ENEMY_HIND_DAMAGE_STATES;
		dmg_delay  = CONST_ENEMY_HIND_DAMAGE_ROCKET_ADJUST_DELAY;
		dmg_adjust = true;
	}
	else if ( IsSubStr( self.classname, "_gaz_" ) )
	{
		health	   = level.apache_difficulty.enemy_gaz_health;
		dmg_adjust = true;
	}
	else if ( IsSubStr( self.classname, "_zpu4" ) )
	{
		health	   = level.apache_difficulty.enemy_zpu_health;
		dmg_adjust = true;
	}
	else if ( IsSubStr( self.classname, "_gunboat" ) )
	{
		health	   = level.apache_difficulty.enemy_gunboat_health;
		dmg_adjust = true;
	}
	else
	{
		AssertMsg( "vehicle_spawner_adjust_health_and_damage() did not recognize spawner classname: " + self.classname );
		return;
	}
	
	// Only adjust health on spawners without an existing starting health set
	if ( !IsDefined( self.script_startinghealth ) )
	{
		self.script_startinghealth = health;
	}
	
	if ( dmg_adjust )
	{
		self add_spawn_function( ::enemy_adjust_missile_damage, dmg_states, dmg_delay );
	}
	
	self add_spawn_function( ::earthquake_on_death );
}

// Missiles in the gdt can only do a max of 2000 damgage. Hinds should go down in two hits
// which would put them at 4000 health. The problem with this is that the player's mini-gun
// would kill them way too fast. Instead of adding health back on mini-gun damage give the
// hind a lot of starting health and then take more health away on missile damage.
	// Works with any enemy vehicle
enemy_adjust_missile_damage( num_states, delay_after )
{
	self endon( "death" );
	self endon( "deathspin" );
	
	health_original	 = self.health - self.healthbuffer;
	health_per_state = ( health_original / num_states ) + 1; // Add 1 because taking away exact health leaves the ai with one more hit in vehicle script
	
	while ( 1 )
	{
		self waittill( "damage", dmg_amount, attacker, dir_vec, point, type );
		
		// If a missile hit the vehicle, apply enough damage to transition to the next damage state
		if ( IsDefined( attacker ) && IsPlayer( attacker ) && IsDefined( type ) && ( type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH" ) )
		{
			dmg_add		= max( 0, health_per_state - dmg_amount );
			dmg_add_loc = ter_op( IsDefined( point ), point, self.origin );
			
			if ( dmg_add )
			{
				// If this is a helicopter and this damage is going to destroy it
				// switch to rocket death because DoDamage() doesn't take a type
				if	(
						self.health - self.healthbuffer - dmg_add <= 0
					&&	self isVehicle() && self isHelicopter()
					 )
				{
					self.enableRocketDeath = true;
					self.alwaysRocketDeath = true;
				}
				
				self DoDamage( dmg_add, dmg_add_loc, attacker );
				
				if ( IsDefined( delay_after ) )
					wait delay_after;
			}
		}
	}
}

vehicle_zpu_think()
{
	self endon( "death" );
	
	while ( 1 )
	{
		target = vehicle_zpu_get_target();
		
		if ( IsDefined( target ) )
		{
			self thread vehicle_zpu_register_target( target );
			self vehicle_zpu_shoot_target( target );
			self notify( "LISTEN_zpu_finished_targeting" );
			
			wait 0.9;
		}
		else
		{
			wait( RandomFloatRange( 0.4, 0.6 ) );
		}
	}
}

vehicle_zpu_get_target()
{
	// If the player apache is in range and can be targetted, prefer it
	apache_player = get_apache_player();
	if ( self vehicle_zpu_can_target( apache_player, 3 ) )
	{
		target_found = apache_player;
	}
	else
	{
		air_targets = get_apaches_ally_and_player();
		air_targets = SortByDistance( air_targets, self.origin );
		
		target_found = undefined;
		
		for ( max_targeting = 1; max_targeting <= 3; max_targeting++ )
		{
			foreach ( target in air_targets )
			{
				if ( self vehicle_zpu_can_target( target, max_targeting ) )
				{
					target_found = target;
					break;
				}
			}
		}
	}
	
	return target_found;
}

vehicle_zpu_can_target( target, max_targeting )
{
	if ( !IsDefined( target ) )
		return false;
	
	if ( IsDefined( target.zpus_targeting ) && target.zpus_targeting >= max_targeting )
		return false;
	
	if ( DistanceSquared( self.origin, target.origin ) > level.apache_difficulty.zpu_range_squared )
		return false;
	
	return true;
}

vehicle_zpu_register_target( target )
{
	if ( !IsDefined( target.zpus_targeting ) )
	{
		target.zpus_targeting = 0;
	}
	
	target.zpus_targeting++;
	
	self waittill_either( "death", "LISTEN_zpu_finished_targeting" );
	
	// Target died during wait
	if ( !IsDefined( target ) )
		return;
	
	target.zpus_targeting--;
	
	AssertEx( target.zpus_targeting >= 0, "ZPU targeting count should never go below zero." );
	
	if ( target.zpus_targeting <= 0 )
	{
		target.zpus_targeting = undefined;
	}
}

vehicle_zpu_shoot_target( target )
{
	target endon( "death" );
	self endon( "death" );
	
	self SetTurretTargetEnt( target );
	
	shoot_fake	= false;
	shoot_delay = 0.05;
	
	apache_player = get_apache_player();
	if ( IsDefined( apache_player ) && apache_player != target )
	{
		shoot_fake = true;
	}
	
	if ( shoot_fake )
	{
		shots		= RandomIntRange( 25, 35 );
		shoot_delay = 0.15;
	}
	else
	{
		shots = 55;
	}
	
	for ( i = 0; i < shots; i++ )
	{
		if ( shoot_fake )
		{
			shoot_origin = self GetTagOrigin( "tag_flash" );
			shoot_angles = self GetTagAngles( "tag_flash" );
			shoot_dir	 = AnglesToForward( shoot_angles );
			
			BulletTracer( shoot_origin, shoot_origin + shoot_dir * 10000, true );
			PlayFXOnTag( getfx( "FX_oilrocks_turret_flash_zpu" ), self, "tag_flash" );
			
		}
		else
		{
			self FireWeapon();
		}
		
		wait shoot_delay;
	}
}

vehicle_ai_turret_think( gunner_vulnerable, gunner_reloads, preferred_target_type, bullets_for_all )
{
	self endon( "death" );
	
	gunner_vulnerable = ter_op( IsDefined( gunner_vulnerable ), gunner_vulnerable, true );
	gunner_reloads	  = ter_op( IsDefined( gunner_reloads ), gunner_reloads, true );
	bullets_for_all	  = ter_op( IsDefined( bullets_for_all ), bullets_for_all, true );
	
	turret		 = undefined;
	use_missiles = undefined;
	pos			 = undefined;
	
	// Handle different vehicle turrets
	if ( IsSubStr( self.classname, "_gaz_" ) )
	{
		turret		 = self.mgturret[ 0 ];
		use_missiles = false;
		pos			 = 3;
	}
	else if ( IsSubStr( self.classname, "_gunboat" ) )
	{
		use_missiles = true;
		turret		 = self.mgturret[ 0 ];
	}
	
	AssertEx( IsDefined( turret ), "vehicle_ai_turret_think() did not recognize the following vehicle classname: " + self.classname );
	
	turret SetTopArc( 90 );
	
	gunner = undefined;
	if ( IsDefined( pos ) )
	{
		foreach ( rider in self.riders )
		{
			if	(
					( IsDefined( rider.vehicle_position ) && rider.vehicle_position == pos )
				||	( IsDefined( rider.script_startingposition ) && rider.script_startingposition == pos )
				 )
			{
				gunner = rider;
				break;
			}
		}
		
		if ( IsDefined( gunner ) )
		{
			gunner endon( "death" );
			
			if ( !gunner_vulnerable )
			{
				gunner thread ai_rider_invulnerable_until_vehicle_death();
			}
		}
		else
		{
			AssertEx( gunner_vulnerable, "Gunner set as invulnerable when there was no gunner." );
		}
	}
	
	if ( !gunner_reloads )
	{
		turret.disableReload = true;
	}
	
	if ( IsDefined( gunner ) )
	{
		gunner thread vehicle_ai_turret_gunner_ignore_all_until_unload();
	}
	
	turret SetMode( "manual" );
	
	while ( IsDefined( self ) )
	{
		target = vehicle_ai_turret_get_target( preferred_target_type );
		
		if ( IsDefined( target ) )
		{
			clear_for_launch = use_missiles;
			if ( use_missiles )
			{
				if ( IsDefined( self.vehicle_ai_turret_think_next_missile_time ) && GetTime() < self.vehicle_ai_turret_think_next_missile_time )
				{
					// Don't fire missiles too often
					clear_for_launch = false;
				}
				else if ( IsDefined( target.veh_missiles_targeting ) && target.veh_missiles_targeting > 0 )
				{
					// Don't lock onto a target that's already locked onto
					clear_for_launch = false;
				}
				else if ( !is_apache_player( target ) && RandomFloat( 1.0 ) <= level.apache_difficulty.gunboat_chance_fire_missile_at_ai )
				{
					// If the target is not the player there is a chance it'll be a missile
					clear_for_launch = false;
				}
			}
			
			self thread vehicle_ai_turret_register_target( target, clear_for_launch );
			
			if ( clear_for_launch )
			{
				if ( is_apache_player( target ) )
				{
					self missile_attack_notify_target_of_lock_and_delay( target );
				}
				
				self vehicle_attack_missile( target, true );
				
				self.vehicle_ai_turret_think_next_missile_time = GetTime() + level.apache_difficulty.gunboat_time_between_missiles_msec;
			}
			else
			{
				turret TurretFireEnable();
				
				self vehicle_ai_turret_shoot_target( target, turret, gunner, bullets_for_all );
				
				turret TurretFireDisable();
			}
			
			self notify( "LISTEN_veh_turret_finished_targeting" );
		}
		
		wait( RandomFloatRange( 0.2, 0.4 ) );
	}
}

missile_attack_notify_target_of_lock_and_delay( target )
{
	AssertEx( IsDefined( target ) && IsDefined( target.heli ) && IsDefined( target.heli.owner ), "missile_attack_notify_target_of_lock_and_delay() called on target with no owner." );
	
	owner = target.heli.owner;
			
	owner notify( "LISTEN_missile_lockOn", self );
	
	msg = self waittill_any_timeout( level.apache_difficulty.vehicle_vs_player_lock_on_time, "death", "deathspin" );
	
	if ( msg == "death" || msg == "deathspin" )
	{
		// The missile lock on hud logic handles death and deathspin
		// so this notify may not be necessary
		self notify( "LISTEN_missile_lockOnFailed" );
		
		return false;
	}
}

vehicle_ai_turret_gunner_ignore_all_until_unload()
{
	self endon( "death" );
	
	self.ignoreall = true;
	
	self waittill( "unload" );
	
	self.ignoreall = false;
}

vehicle_ai_turret_get_target( type_prefer )
{
	type_prefer = ter_op( IsDefined( type_prefer ), type_prefer, "none" );
	AssertEx( array_contains( vehicle_ai_turret_get_target_types(), type_prefer ), "vehicle_ai_turret_get_target() passed invalid target type: " + type_prefer );
	
	// Grab all possible targets according to vehicle team
	targets = [];
	
	team = self getTeam();
	AssertEx( team != "none", "vehicle_ai_turret_get_target() could not get valid team." );
	
	if ( team == "axis" )
	{
		targets = array_combine( targets, get_apaches_ally_and_player() );
		targets = array_combine( targets, GetAIArray( "allies" ) );
	}
	else if ( team == "allies" )
	{
		targets = array_combine( targets, get_hinds_enemy_active() );
		targets = array_combine( targets, GetAIArray( "axis" ) );
	}
	
	// Collect valid targets
	targets_valid = [];
	foreach ( target in targets )
	{
		if ( self vehicle_ai_turret_can_target( target ) )
		{
			targets_valid[ targets_valid.size ] = target;
		}
	}
	
	// Build target by type array using valid targets and the desired target type
	targets_by_type = [];
	
	// In the case of none, all targets go into one array
	if ( type_prefer == "none" )
	{
		targets_by_type[ type_prefer ] = targets_valid;
	}
	else
	{
		// Fill type order, putting the preferred type first
		type_order = [ type_prefer ];
		
		// Grab the possible types not including none
		types_possible = vehicle_ai_turret_get_target_types( false );
		// Remove the preferred type as it's already been added to type order
		types_possible = array_remove( types_possible, type_prefer );
		// Put the rest of the possible types at the end of the type order array
		type_order = array_combine( type_order, types_possible );
		
		// Build the target by type array using the type order array
		foreach ( type in type_order )
		{
			if ( !IsDefined( targets_by_type[ type ] ) )
			{
				targets_by_type[ type ] = [];
			}
			
			foreach ( target in targets_valid )
			{
				if ( type == target vehicle_ai_turret_get_target_type() )
				{
					targets_by_type[ type ][ targets_by_type[ type ].size ] = target;
				}
			}
		}
	}
	
	// Now finally pick a target using the preferred target type. If no target can be found
	// in the preferred type, then move onto the next type.
	target_optimal = undefined;
	foreach ( type, array_targets in targets_by_type )
	{
		if ( !array_targets.size )
			continue;
		
		// Sort by distance and by vehicles targetting
		array_targets = SortByDistance		 ( array_targets, self.origin );
		array_targets = array_sort_by_handler( array_targets, ::get_vehicle_turrets_targeting );
		
		// Find the target with the least amount of vehicle turrets tracking it
		
		// If the type is not ai, prefer the player apache first
		if ( type != "ai" )
		{
			apache_player = get_apache_player();
			
			// Start the minimum at 1 in case there's a target that
			// has 0 vehicles targeting it and the player has only 1.
			min_veh_targeting = 1;
			
			// Check and see if the player is one of the least targeted,
			// if so, set the player to the target.
			foreach ( target in array_targets )
			{
				veh_targeting = target get_vehicle_turrets_targeting();
				
				if ( !IsDefined( min_veh_targeting ) )
				{
					min_veh_targeting = veh_targeting;
				}
				else if ( veh_targeting > min_veh_targeting )
				{
					// The player was not found in the first group of targets
					// with the minimum found vehicles targeting count
					break;
				}
				
				if ( IsDefined( apache_player ) && target == apache_player )
				{
					// The player was found in the first group of targets
					// with the minimum found vehicles targeting count
					target_optimal = target;
					break;
				}
			}
		}
		
		// If the player wasn't found in the subset of the array_targets
		// array that has the mimimum found vehicle targetting count just
		// use the first entry in array_targets
		if ( !IsDefined( target_optimal ) )
		{
			target_optimal = array_targets[ 0 ];
		}
		
		if ( IsDefined( target_optimal ) )
		{
			break;
		}
	}

	return target_optimal;
}

vehicle_ai_turret_get_target_type()
{
	type = undefined;
	if ( self isVehicle() )
		type = "vehicle";
	else if ( IsAI( self ) )
		type = "ai";
	else
		AssertMsg( "Type could not be determined." );
	
	return type;
}

vehicle_ai_turret_get_target_types( include_none )
{
	include_none = ter_op( IsDefined( include_none ), include_none, true );
	
	types = [ "ai", "vehicle" ];
	
	if ( include_none )
	{
		types[ types.size ] = "none";
	}
	
	return types;
}

vehicle_ai_turret_can_target( target )
{
	if ( !IsDefined( target ) )
		return false;
	
	if ( IsDefined( target.ignoreme ) && target.ignoreme )
		return false;
	
	if ( IsDefined( target.ridingvehicle ) )
		return false;
	
	if ( DistanceSquared( self.origin, target.origin ) > level.apache_difficulty.veh_turret_range_squared )
		return false;
	
	return true;
}

get_vehicle_turrets_targeting()
{
	return ter_op( IsDefined( self.veh_turrets_targeting ), self.veh_turrets_targeting, 0 );
}

vehicle_ai_turret_register_target( target, using_missile )
{
	if ( !IsDefined( target.veh_turrets_targeting ) )
	{
		target.veh_turrets_targeting = 0;
	}
	
	if ( !IsDefined( target.veh_missiles_targeting ) )
	{
		target.veh_missiles_targeting = 0;
	}
	
	// Both counts are incremented and decremented if a missile is fired
	// because the turret count is what's used in the targeting logic
	// to see if a vehicle can target.
	target.veh_turrets_targeting++;
	
	if ( using_missile )
	{
		target.veh_missiles_targeting++;
	}
	
	self waittill_either( "death", "LISTEN_veh_turret_finished_targeting" );
	
	// Target died during wait
	if ( !IsDefined( target ) )
		return;
	
	target.veh_turrets_targeting--;
	
	if ( using_missile )
	{
		target.veh_missiles_targeting--;
	}
	
	AssertEx( IsDefined( target.veh_turrets_targeting ) && target.veh_turrets_targeting >= 0, "Vehicle turret targeting count should never go below zero." );
	if ( using_missile )
	{
		AssertEx( IsDefined( target.veh_missiles_targeting ) && target.veh_missiles_targeting >= 0, "Vehicle missile targeting count should never go below zero." );
	}
	
	if ( IsDefined( target.veh_turrets_targeting ) && target.veh_turrets_targeting <= 0 )
	{
		target.veh_turrets_targeting = undefined;
	}
	
	if ( IsDefined( target.veh_missiles_targeting ) && target.veh_missiles_targeting <= 0 )
	{
		target.veh_missiles_targeting = undefined;
	}
}

vehicle_ai_turret_shoot_target( target, turret, gunner, bullets_for_all )
{
	self endon( "death" );
	target endon( "death" );
	
	if ( IsDefined( gunner ) )
		gunner endon( "death" );
	
	// Bullet rate and bullet count change if the target is the player
	apache_player	 = get_apache_player();
	target_is_player = false;
	if ( IsPlayer( target ) || ( IsDefined( apache_player ) && apache_player == target ) )
	{
		target_is_player = true;
	}
	
	turret SetTargetEntity( target );
	
	fire_count = 0;
	if ( target_is_player )
	{
		fire_count = 70;
	}
	else
	{
		fire_count = RandomIntRange( 25, 35 );
	}
	
	// Need turret index to grab weapon info
	turret_index = undefined;
	foreach ( idx, veh_turret in self.mgturret )
	{
		if ( veh_turret == turret )
		{
			turret_index = idx;
			break;
		}
	}
	
	// Figure out turret fire time relative to fire count using weapon info
	fire_time = 0.05;
	if ( IsDefined( turret_index ) )
	{
		weapon_info = level.vehicle_mgturret[ self.classname ][ turret_index ];
		if ( IsDefined( weapon_info ) )
		{
			fire_time = WeaponFireTime( weapon_info.info );
		}
	}
	
	// If bullets for all is false, just use visual tracers on ai targets
	// and ajust the fire rate to be a maximum of 10 shots per second
	shoot_tracer = undefined;
	shoot_flash	 = undefined;
	if ( !bullets_for_all && !target_is_player )
	{
		shoot_flash = self vehicle_ai_turret_get_fx_shoot_flash();
	}
	
	// If fake shooting fx are defined use those
	if ( IsDefined( shoot_flash ) )
	{
		fire_time = max( fire_time, 0.15 );
		
		tag_angles = turret GetTagAngles( "tag_flash" );
		for ( i	= 0; i < fire_count; i++ )
		{
			shoot_origin = turret GetTagOrigin( "tag_flash" );
			shoot_angles = turret GetTagAngles( "tag_flash" );
			shoot_dir	 = AnglesToForward( shoot_angles );
			
			BulletTracer( shoot_origin, shoot_origin + shoot_dir * 10000, true );
			
			// Muzzle flash every 2
			if ( i % 2 == 0 )
			{
				//PlayFX( getfx( shoot_flash ), shoot_origin, shoot_dir, AnglesToUp( shoot_angles ) );
				PlayFXOnTag( getfx( shoot_flash ), turret, "tag_flash" );
			}
			
			wait fire_time;
		}
	}
	else
	{
		if ( IsDefined( gunner ) )
		{
			fire_time = max( fire_time, 0.1 );
			
			for ( i = 0; i < fire_count; i++ )
			{
				turret ShootTurret();
				
				wait fire_time;
			}
		}
		else
		{
			turret StartFiring();
			wait fire_count * fire_time;
			turret StopFiring();
		}
	}
}

vehicle_ai_turret_get_fx_shoot_flash()
{
	flash = undefined;
	
	if ( IsSubStr( self.classname, "_gaz_" ) )
	{
		flash = "FX_oilrocks_turret_flash_gaz";
	}
	else if ( IsSubStr( self.classname, "_gunboat" ) )
	{
		flash = "FX_oilrocks_turret_flash_gunboat";
	}
	else if ( IsSubStr( self.classname, "_zpu4" ) )
	{
		flash = "FX_oilrocks_turret_flash_zpu";
	}
	else
	{
		AssertMsg( "vehicle_ai_turret_get_fx_shoot_flash() did not handle vehicle of classname: " + self.classname );
	}
	
	return flash;
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Helicopter AI Setup
//			- Allies and Enemies
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

chopper_ai_init()
{
	PreCacheItem( "apache_lockon_missile_ai" );
	PreCacheItem( "apache_lockon_missile_ai_enemy" );

	// Chopper mesh setup
	maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "heli_nav_mesh" );
	
	// Chopper stats and funcs
	maps\_chopperboss::init();
	
	level.chopperboss_const[ "default" ][ "max_target_dist2d" ]		= 12072; // Chopper wants to be closer than this to the target

	create_lock("add_apache_target_lock");
	add_global_spawn_function( "axis", ::add_as_apache_target_on_spawn );
	
}

CONST_MANAGE_HIND_FORCED_TARGET_DELAY		= 3; // Seconds between changing the forced target of an active hind to being the player.

manage_active_hind_forced_targets()
{
	apache_player = self;
	
	apache_player endon( "death" );
	self endon( "death" );
	
	while ( 1 )
	{
		// if there are active hinds make sure one of them always
		// has the player as a forced target
		hinds = get_hinds_enemy_active();
		if ( hinds.size )
		{
			hind_optimal = undefined;
			
			// If there's only 1 hind call the dot compare func on it as array_sort_by_handler
			// early outs with only 1 entry
			if ( hinds.size == 1 )
			{
				hinds[ 0 ] dot_to_apache_player_facing_2d();
			}
			else
			{
				// Sort the hinds by how directly the player is looking at them
				hinds = array_sort_by_handler( hinds, ::dot_to_apache_player_facing_2d_inverse );
			}
			
			foreach ( hind in hinds )
			{
				// If there is a hind in front of the player that is within range of
				// attacking set his forced target to the player
				if ( hind.dot_to_apache_player_facing_2d >= 0.25 )
				{
					hind_optimal = hind;
					break;
				}
			}
			
			if ( !IsDefined( hind_optimal ) )
			{
				hinds		 = SortByDistance( hinds, apache_player.origin );
				hind_optimal = hinds[ 0 ];
			}
			
			hind_optimal maps\_chopperboss_utility::chopper_boss_forced_target_set( apache_player );
			waittill_any_timeout( CONST_MANAGE_HIND_FORCED_TARGET_DELAY, "death", "deathspin", "chopper_done_shooting" );
			
			if ( IsDefined( hind_optimal ) )
			{
				hind_optimal maps\_chopperboss_utility::chopper_boss_forced_target_clear();
				continue;
			}
		}
		
		wait 0.05;
	}
}

dot_to_apache_player_facing_2d_inverse()
{
	dot_inverse_2d = 0;
	
	apache_player = get_apache_player();
	
	AssertEx( IsDefined( apache_player ), "dot_to_apache_player_facing_2d_inverse() called with no valid apache_player" );
	if ( IsDefined( apache_player ) )
	{
		dot_inverse_2d = -1.0 * self dot_to_apache_player_facing_2d();
	}
	
	return dot_inverse_2d;
}

dot_to_apache_player_facing_2d()
{
	self.dot_to_apache_player_facing_2d = 0;
	
	apache_player = get_apache_player();
	
	AssertEx( IsDefined( apache_player ), "dot_to_apache_player_facing_2d() called with no valid apache_player" );
	if ( IsDefined( apache_player ) )
	{
		vec_apache_fwd_flat = AnglesToForward( ( 0, apache_player.angles[ 1 ], 0 ) );
		vec_to_self_flat	= VectorNormalize( ( self.origin[ 0 ], self.origin[ 1 ], 0 ) - ( apache_player.origin[ 0 ], apache_player.origin[ 1 ], 0 ) );
		
		self.dot_to_apache_player_facing_2d = VectorDot( vec_apache_fwd_flat, vec_to_self_flat );
	}
	
	return self.dot_to_apache_player_facing_2d;
}

heli_ai_gather_targets()
{
	targets = [];
	
	if ( self.script_team == "allies" )
	{
		targets = array_combine( targets, get_hinds_enemy_active() );
		
		// Allies also shoot at AI but prefer enemy air
		if ( !targets.size )
		{
			ai_targets		 = GetAIArray( "axis" );
			ai_targets_valid = [];
			foreach ( ai in ai_targets )
			{
				if ( IsDefined( ai.ignoreme ) && ai.ignoreme )
					continue;
				
				ai_targets_valid[ ai_targets_valid.size ] = ai;
			}
			
			targets = array_combine( targets, ai_targets_valid );
		}
	}
	else
	{
		// A thread is running when the player is in the apache that sets
		// forced targets on enemy hinds. This function is called
		// manage_active_hind_forced_targets(). If a forced target is set
		// for a hind this logic does not get called in _chopperboss.gsc
		targets = array_combine( targets, get_apaches_ally_and_player() );
	}
	
	return targets;
}

heli_ai_can_hit_target( chopper_origin, target_origin )
{
	if( IsDefined( self.mgturret ) && self.mgturret.size > 0 )
		return maps\_chopperboss_utility::chopper_boss_can_hit_from_mgturret( chopper_origin, target_origin );
	return true;
}

heli_decides_to_shoot_missile_at_ai( target )
{
	if ( !IsDefined( level.last_heli_decides_to_shoot_missile_at_ai_time ) )
		level.last_heli_decides_to_shoot_missile_at_ai_time = GetTime();
	if ( GetTime() - level.last_heli_decides_to_shoot_missile_at_ai_time < 5000 )
		return false;
	if ( cointoss() )
		return false;
	if ( Distance2DSquared( level.player.origin, target.origin ) < 9000000 )
		return false;
	level.last_heli_decides_to_shoot_missile_at_ai_time = GetTime();
	return true;
}

heli_ai_shoot_target( target )
{
	// Don't use missiles if the target is an AI or if missiles were used recently
	use_missile = true;
	if ( IsAI( target ) && !heli_decides_to_shoot_missile_at_ai( target ) )
	{
		use_missile = false;
	}
	else if ( IsDefined( self.heli_ai_shoot_missile_time_next ) && GetTime() < self.heli_ai_shoot_missile_time_next )
	{
		use_missile = false;
	}
	else if ( distance_2d_squared( self.origin, target.origin ) <= level.apache_difficulty.heli_vs_heli_mg_range_2d_squared )
	{
		use_missile = false;
	}
	
	if ( use_missile )
	{
		if ( is_apache_player( target ) )
		{
			self missile_attack_notify_target_of_lock_and_delay( target );
		}
		
		self vehicle_attack_missile( target, true, 1 );
		
		// Record last missile fire time
		self.heli_ai_shoot_missile_time_next = GetTime() + RandomFloatRange( level.apache_difficulty.heli_vs_heli_min_shoot_time_msec , level.apache_difficulty.heli_vs_heli_max_shoot_time_msec );
	}
	else
	{
		if ( IsDefined( self.mgturret ) )
		{
			AssertEx( self.mgturret.size, "heli_ai_shoot_target() asked heli to shoot mg with empty mg turret array." );
			self heli_attack_mg( target, 3.0 );
		}
		else
		{
			self heli_attack_mg_veh_weapon( target, 3.0 );
		}
	}
	
	return true;
}

heli_ai_pre_move_func()
{
	if ( IsDefined( self maps\_chopperboss_utility::chopper_boss_forced_target_get() ) )
	{
		self SetLookAtEnt( self maps\_chopperboss_utility::chopper_boss_forced_target_get() );
	}
	else if ( IsAlive( self.heli_target ) )
	{
		self SetLookAtEnt( self.heli_target );
		self.last_heli_lookat_origin = self.heli_target.origin;
	}
	else
	{
		self ClearLookAtEnt();
	}
}

// Uses chopper boss movement and shooting along with Chetan's
// missile defense logic
spawn_hind_enemy( ent_start )
{
	spawner = GetEnt( "hind_enemy", "targetname" );
	spawner vehicle_spawner_adjust_health_and_damage();

	while ( IsDefined( spawner.vehicle_spawned_thisframe ) )
		wait 0.05;
	
	if ( IsDefined( ent_start ) )
	{
		spawner.origin = ent_start.origin;
		if ( IsDefined( ent_start.angles ) )
			spawner.angles = ent_start.angles;
	}
	
	hind = vehicle_spawn( spawner );
	
	hind.script_noteworthy = "enemy_hinds_active";
	hind.enableRocketDeath = true;
	
	hind.missileDefense	= vehicle_scripts\_chopper_ai_missile_defense::_init( hind );
	hind.missileDefense thread vehicle_scripts\_chopper_ai_missile_defense::_start();
	
	hind Vehicle_SetSpeed( 188, 190, 190 );
	
	hind thread add_as_apache_target_on_spawn();
	hind thread hind_manage_damage_states();
	
	hind heli_ai_collision_cylinder_add();
	
	return hind;
}

choper_fly_in_think( start_struct )
{
	self endon( "death" );
	self SetLookAtEnt( level.player );
	self thread vehicle_paths( start_struct );
	self waittill( "reached_dynamic_path_end" );
	self self_make_chopper_boss();
}

self_make_chopper_boss( path_start, fly_to_path )
{
	self endon( "death" );
	
	if ( !IsDefined( path_start ) )
	{
		while ( 1 )
		{
			path_start = maps\_chopperboss_utility::chopper_boss_get_closest_available_path_struct_2d( self.origin );
			
			if ( IsDefined( path_start ) )
				break;
			
			wait 0.05;
		}
	}
	
	fly_to_path = ter_op( IsDefined( fly_to_path ), fly_to_path, false );
	
	if ( fly_to_path )
	{
		path_start.in_use = true;
		
		self thread vehicle_paths( path_start );
		self waittill( "reached_dynamic_path_end" );
	
		path_start.in_use = undefined;
	}
	
	// Make sure overrides are set for the hind
	if ( !IsDefined( level.chopperboss_const[ self.classname ] ) )
	{
		self maps\_chopperboss_utility::build_data_override( "min_target_dist2d", 2048 );
		self maps\_chopperboss_utility::build_data_override( "max_target_dist2d", 8192 );
		
		self maps\_chopperboss_utility::build_data_override( "get_targets_func", ::heli_ai_gather_targets );
		self maps\_chopperboss_utility::build_data_override( "tracecheck_func" , ::heli_ai_can_hit_target );
		self maps\_chopperboss_utility::build_data_override( "fire_func"	   , ::heli_ai_shoot_target );
		self maps\_chopperboss_utility::build_data_override( "pre_move_func"   , ::heli_ai_pre_move_func );
	}
	
	self thread maps\_chopperboss::chopper_boss_think( path_start, true );
	self thread maps\_chopperboss::chopper_boss_agro_chopper();
}



// Right now there is just one
hind_manage_damage_states()
{
	self endon( "death" );
	self endon( "deathspin" );

	health_original = self.health - self.healthbuffer;
	state			= 0;
	
	while ( 1 )
	{
		health = self.health - self.healthbuffer;
		
		if ( health <= health_original * 0.5 )
		{
			PlayFXOnTag( getfx( "FX_hind_damaged_smoke_heavy" ), self, "tag_deathfx" );
		}
		
		wait 0.05;
	}
}

CONST_AI_RETURN_TO_SPAWN_DIST_MAX = 1600;
CONST_AI_RETURN_TO_SPAWN_TIME_SEC = 25;
ai_clean_up( Delete, wait_look_away )
{
	// In case multiple calls to ai_clean_up happen
	self notify( "ai_clean_up" );
	self endon( "ai_clean_up" );
	
	self endon( "death" );

	// Both default to true
	Delete		   = ter_op( IsDefined( Delete ), Delete, true );
	wait_look_away = ter_op( IsDefined( wait_look_away ), wait_look_away, true );
	
	run_to_spawn = true;
	if	(
		!IsDefined( self.ai_pos_start )
	||	!IsAI( self )
	||	IsDefined( self.script_vehicleride )
	||	IsDefined( self.ridingvehicle	   )
	||	distance_2d_squared( self.origin, self.ai_pos_start ) > squared( CONST_AI_RETURN_TO_SPAWN_DIST_MAX )
		 )
	{
		run_to_spawn = false;
	}
	
	if ( run_to_spawn )
	{
		// In case this AI still still running to his spawn target node
		self notify( "stop_going_to_node" );
		
		self.ignoreall	= true;
		self.goalradius = 32;
		self SetGoalPos( self.ai_pos_start );
		
		self waittill_any_timeout( CONST_AI_RETURN_TO_SPAWN_TIME_SEC, "goal", "bad_path" );
	}
	
	if ( wait_look_away )
	{
		// in case the player is looking at the AI
		while ( player_looking_at( self.origin, undefined, true ) )
			wait 0.05;
	}
	
	apache_player = get_apache_player();
	if ( IsDefined( apache_player ) )
	{
		apache_player thread vehicle_scripts\_apache_player::hud_hideTargets( [ self ] );
	}
	
	if ( Delete )
	{
		self Delete();
	}
	else
	{
		self Kill( self.origin );
	}
}

escort_encounter_think( struct_encounter_first, ai_targetname )
{
	// Get Encounter Structs
	struct_encounter = struct_encounter_first;
	encounters		 = [];
	
	while ( IsDefined( struct_encounter ) )
	{
		encounters[ encounters.size ] = struct_encounter;
		
		if ( IsDefined( struct_encounter.target ) )
			struct_encounter = get_target_ent( struct_encounter.target );
		else
			struct_encounter = undefined;
	}
	
	// Set Up Encounter Data
	foreach ( enc in encounters )
	{
		enc.spawners_ai		  = [];
		enc.spawners_veh	  = [];
		enc.ai_alive		  = [];
		enc.veh_alive		  = [];
		enc.flag_set_on_start = undefined;
		enc.flag_set_on_end	  = undefined;
		enc.flag_wait_ally	  = undefined;
		enc.flood_during_prev = true;
		enc.spawning_ai		  = false;
		enc.spawning_veh	  = false;
		enc.trig_color		  = undefined;
		enc.volume			  = undefined;
		
		// Record flag to be set once an encounter has started
			// If there is an ally trigger, this flag waits for that
			// before starting
		if ( IsDefined( enc.script_flag ) )
		{
			enc.flag_set_on_start = enc.script_flag;
		}
		
		// Record flag to be set once an encounter has started
			// This gets set as soon as the encounter ends, no delay
		if ( IsDefined( enc.script_flag_set ) )
		{
			enc.flag_set_on_end = enc.script_flag_set;
		}
		
		if ( IsDefined( enc.script_parameters ) )
		{
			if ( IsSubStr( enc.script_parameters, "nopreflood" ) )
			{
				enc.flood_during_prev = false;
			}
		}
		
		linked_ents = enc get_linked_ents();
		foreach ( link in linked_ents )
		{
			if ( IsSpawner( link ) )
			{
				if ( IsSubStr( link.classname, "vehicle" ) )
					enc.spawners_veh[ enc.spawners_veh.size ] = link;
				else
					enc.spawners_ai[ enc.spawners_ai.size ] = link;
			}
			
			if ( link.classname == "info_volume" )
			{
				enc.volume = link;
			}
			
			if ( link.classname == "trigger_multiple_flag_set" )
			{
				AssertEx( IsDefined( link.script_flag ), "Ally color trigger linked to trigger_multiple_flag_set without script_flag field." );
				enc.flag_wait_ally = link.script_flag;
			}
			
			if ( IsSubStr( link.classname, "trigger_" ) && IsDefined( link.script_color_allies ) )
			{
				enc.trig_color = link;
			}
		}
		
		// Figure out how many ai should remain before kicking off the next round
		enc.ai_count_for_spawn = ter_op( IsDefined( enc.script_index ), enc.script_index, max( 0, Int( 0.6 * enc.spawners_ai.size ) ) );
	}
	
	// Set Up Spawn Logic for AI and vehicles
	foreach ( enc in encounters )
	{
		// Add ai spawn functions
		foreach ( spawner in enc.spawners_ai )
		{
			if ( IsDefined( ai_targetname ) )
			{
				spawner add_spawn_function( ::add_targetname, ai_targetname );
			}
									//   function 						   param1
			spawner add_spawn_function( ::ai_record_spawn_pos			, undefined );
			spawner add_spawn_function( ::add_as_apache_target_on_spawn , undefined );
			spawner add_spawn_function( ::enemy_infantry_set_up_on_spawn, undefined );
			spawner add_spawn_function( ::enemy_infantry_record			, enc );
			spawner add_spawn_function( ::enemy_infantry_on_death		, enc );
			
			if ( IsSubStr( spawner.classname, "_rpg" ) )
			{
				spawner add_spawn_function( ::enemy_infantry_rpg_only );
				spawner add_spawn_function( ::rpg_ai_record_ready );
			}
		}
		
		// Adjust vehicle start health and add spawn functions
		foreach ( spawner in enc.spawners_veh )
		{
			spawner vehicle_spawner_adjust_health_and_damage();
									//   function 					      param1
			spawner add_spawn_function( ::add_as_apache_target_on_spawn, undefined );
			spawner add_spawn_function( ::enemy_vehicle_record		   , enc );
			spawner add_spawn_function( ::enemy_vehicle_on_death	   , enc );
	
			if ( !IsSubStr( spawner.classname, "zpu4" ) && !IsSubStr( spawner.classname, "hind" ) )
				spawner add_spawn_function( ::vehicle_ai_turret_think, false, false, "ai" );
			
			if ( IsSubStr( spawner.classname, "zpu4" ) )
				spawner add_spawn_function( ::vehicle_zpu_think );
			
			
		}
	}
	
	// Run Color Trigger and Enemy Spawn Logic
	foreach ( idx, enc in encounters )
	{
		enc_prev = undefined;
		enc_next = undefined;
		
		if ( idx > 0 )
			enc_prev = encounters[ idx - 1 ];
		
		if ( idx + 1 < encounters.size )
			enc_next = encounters[ idx + 1 ];
		
		// If a previous encounter existed, grab any remaining ai from that encounter
		// and have them retreat to this encounter's volume. Also add these AI to the
		// current encounters ai tracking. Ignore enemies set to no retreat
		if ( IsDefined( enc_prev ) )
		{
			enc_prev.ai_alive = array_remove_undefined_dead_or_dying( enc_prev.ai_alive );
			if ( enc_prev.ai_alive.size )
			{
				foreach ( ai in enc_prev.ai_alive )
				{
					clean_up_after_wave = IsDefined( ai.script_parameters ) && IsSubStr( ai.script_parameters, "cleanafterwave" );
					if ( clean_up_after_wave )
					{
						ai thread ai_clean_up( true, true );
					}
					else if ( IsDefined( enc.volume ) )
					{
						retreat	= !IsDefined( ai.script_parameters ) || !IsSubStr( ai.script_parameters, "noretreat" );
						if ( retreat )
						{
							ai enemy_infantry_retreat( enc.volume );
							ai enemy_infantry_record( enc );
							ai thread enemy_infantry_on_death( enc );
						}
					}
				}
			}
		}
		
		// Flood spawn the next encounter if it exists
		if ( IsDefined( enc_next ) && enc_next.flood_during_prev )
		{
			enemy_encounter_spawn_ai_flood( enc_next );
		}
		
		// Flood spawn the current encounter if it's not already spawning
		if ( !enc.spawning_ai )
		{
			enemy_encounter_spawn_ai_flood( enc );
		}
		
		// Spawn the current encounter's vehicles
		enemy_encounter_spawn_vehicles( enc );

		// Move friendlies
		if ( IsDefined( enc.trig_color ) )
		{
			enc.trig_color activate_trigger();
		}
		
		spawn_time = GetTime();
		
		// If a flag set trigger exists for allies, wait until it's triggered before
		// checking enemy counts
		if ( IsDefined( enc.flag_wait_ally ) )
		{
			flag_wait( enc.flag_wait_ally );
		}
		
		// If a flag for the encounter start exists, set it
		if ( IsDefined( enc.flag_set_on_start ) )
		{
			flag_set( enc.flag_set_on_start );
		}
		
		// If the encounter struct has a delay on it, wait. This will cause the ally
		// infantry to wait at their current location a minimum amount of time before
		// checking enemy ai counts. This should be used with a flag_wait_ally set.
		enc script_delay();
		
		// Make sure enemy infantry and enemy vehicles have had a chance to spawn
		if ( GetTime() == spawn_time )
		{
			wait 0.05;
		}
		
		// Stop front line flood spawners
		enemy_encounter_spawn_ai_stop( enc );
		
		// Once all vehicles have died and enough enemies have died, call move to the next trigger
		while ( 1 )
		{
			enc waittill_any_timeout(
				1.0, "enemy_infantry_dead", "enemy_vehicle_dead" );
			
			waittillframeend; // In case multiple enemies die on the same frame
			
			// Clean arrays
			if ( enc.veh_alive.size )
				enc.veh_alive = array_remove_undefined_dead_or_dying( enc.veh_alive );
			if ( enc.ai_alive.size )
				enc.ai_alive = array_remove_undefined_dead_or_dying( enc.ai_alive );
			
			// Never push forward when a vehicle is alive
			if ( enc.veh_alive.size )
				continue;
			
			if ( enc.ai_alive.size <= enc.ai_count_for_spawn )
				break;
		}
		
		if ( IsDefined( enc.flag_set_on_end ) )
		{
			flag_set( enc.flag_set_on_end );
		}
	}
	
	ai_remaining = [];
	foreach ( enc in encounters )
	{
		ai_remaining = array_combine( ai_remaining, enc.ai_alive );
	}
	
	// Grab remaining AI to be returned
	ai_remaining = array_remove_undefined_dead_or_dying( ai_remaining );
	ai_remaining = array_remove_duplicates			   ( ai_remaining );
	
	// Scrub encounter structs
	foreach ( enc in encounters )
	{
		enc.spawners_ai		  = undefined;
		enc.spawners_veh	  = undefined;
		enc.ai_alive		  = undefined;
		enc.veh_alive		  = undefined;
		enc.flag_set_on_start = undefined;
		enc.flag_set_on_end	  = undefined;
		enc.flag_wait_ally	  = undefined;
		enc.spawning_ai		  = undefined;
		enc.spawning_veh	  = undefined;
		enc.trig_color		  = undefined;
		enc.volume			  = undefined;
	}
	
	return ai_remaining;
}

enemy_encounter_spawn_ai_stop( struct_encounter )
{
	if ( !struct_encounter.spawning_ai )
		return;
	
	if ( struct_encounter.spawners_ai.size )
	{
		array_thread( struct_encounter.spawners_ai, maps\_spawner::flood_spawner_stop );
	}
}

enemy_encounter_spawn_vehicles( struct_encounter )
{
	AssertEx( !struct_encounter.spawning_veh, "Encounter asked to spawn vehicles when already spawning vehicles." );
	if ( struct_encounter.spawning_veh )
		return;
	
	if ( struct_encounter.spawners_veh.size )
	{
		struct_encounter.spawning_veh = true;
		
		foreach ( spawner in struct_encounter.spawners_veh )
		{
			veh = vehicle_spawn( spawner );
			if ( IsSubStr( veh.classname, "hind" ) )
			{
				veh thread choper_fly_in_think();
				continue;
			}
			
			if ( ! IsSubStr( veh.classname, "zpu" ) )
				thread gopath( veh );
			
		}
	}
}

enemy_encounter_spawn_ai_flood( struct_encounter )
{
	AssertEx( !struct_encounter.spawning_ai, "Encounter asked to spawn ai when already spawning ai." );
	if ( struct_encounter.spawning_ai )
		return;
	
	if ( struct_encounter.spawners_ai.size )
	{
		struct_encounter.spawning_ai = true;
		
		// Spawn AI
		spawners_not_riding = [];
		foreach ( spawner in struct_encounter.spawners_ai )
		{
			// Don't spawn ai riding in vehicles, let the vehicle spawn handle this
			if ( IsDefined( spawner.script_vehicleride ) )
				continue;
			
			spawner.count									= 999;
			spawners_not_riding[ spawners_not_riding.size ] = spawner;
		}
		
		maps\_spawner::flood_spawner_scripted( spawners_not_riding );
	}
}

enemy_infantry_retreat( volume )
{
	// Increase enemy accuracy against these guys
	self.attackeraccuracy = 10.0;
	
	self SetGoalVolumeAuto( volume );
}

enemy_vehicle_on_death( ent_notify )
{
	self waittill( "death" );
	
	ent_notify notify( "enemy_vehicle_dead" );
}

enemy_vehicle_record( struct_encounter )
{
	struct_encounter.veh_alive[ struct_encounter.veh_alive.size ] = self;
}

rpg_ai_record_ready()
{
	if ( IsDefined( self.script_forcegoal ) )
	{
		self endon( "death" );
		self waittill( "goal" );
	}
	
	self.rpg_ai_in_position = true;
}

enemy_infantry_rpg_only()
{
	// Make sure RPG guys have unlimited ammo and
	// they don't have a secondary to switch to
	self.secondaryweapon = "none";
	self thread giveUnlimitedRPGAmmo();
}

enemy_infantry_on_death( ent_notify )
{
	self notify( "new_enemy_infantry_on_death" );
	self endon( "new_enemy_infantry_on_death" );
	
	self waittill( "death" );
	
	ent_notify notify( "enemy_infantry_dead" );
}

enemy_infantry_record( struct_encounter )
{
	struct_encounter.ai_alive[ struct_encounter.ai_alive.size ] = self;
}

enemy_infantry_set_up_on_spawn()
{
	self disable_long_death();
}

ai_record_spawn_pos()
{
	// Don't record a spawn location for AI riding in cars
	self.ai_pos_start = self.origin;
}

add_targetname( name )
{
	self.targetname = name;
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Common Mission Start Logic
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

start_apache_common()
{
	maps\oilrocks_apache_difficulty::apache_mission_difficulty();
	apache_mission_heli_ai_collision();
	
	thread apache_mission_vo_player_crashing();
}

array_spawn_function_flag_on_death_all( value, key, level_flag )
{
	array = GetEntArray( value, key );
	
	struct								  = SpawnStruct();
	struct.encounter_spawners_death_count = array.size;
	
	array_spawn_function( array, ::ent_on_death_set_flag, struct, level_flag );
}

ent_on_death_set_flag( struct, level_flag )
{
	self waittill( "death" );
	
	struct.encounter_spawners_death_count--;
	
	if ( struct.encounter_spawners_death_count <= 0 )
	{
		flag_set( level_flag );
	}
}

// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Mission Destructibles
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //


destructible_quakes_on()
{
	level.fast_destructible_explode = true;
	vehicles						= GetEntArray( "destructible_vehicle", "targetname" );
	array_thread( vehicles, ::destructible_force_explode_on );
	thread earthquake_player_missile_monitor( "LISTEN_heli_end" );
	thread earthquake_destructibles_monitor( "LISTEN_heli_end" );
	self waittill ( "LISTEN_heli_end" );
	destructible_quakes_off();
}

destructible_quakes_off()
{
	vehicles = GetEntArray( "destructible_vehicle", "targetname" );
	array_thread( vehicles, ::destructible_force_explode_off );
	level.fast_destructible_explode = false;
}

destructible_force_explode_on()
{
	self.forceExploding = true;
}

destructible_force_explode_off()
{
	self.forceExploding = undefined;
}

earthquake_destructibles_monitor( level_endon )
{
	self endon( level_endon );
	
	while ( 1 )
	{
		level waittill( "destructible_exploded", destructible, attacker );
		
		if ( !IsDefined( attacker ) || !IsDefined( destructible ) )
			continue;
		
		if ( !earthquake_valid_entity( destructible, attacker ) )
			continue;
		
		earthquake_player( destructible.origin );
	}
}

CONST_DESTRUCTIBLE_QUAKE_DIST_SQRD_MAX = 9600 * 9600; //800 FEET
CONST_DESTRUCTIBLE_QUAKE_DIST_SQRD_MIN = 1200 * 1200; //100 FEET
CONST_DESTRUCTIBLE_QUAKE_AT_MAX_DIST   = 0.155;
CONST_DESTRUCTIBLE_QUAKE_AT_MIN_DIST   = 0.225;

earthquake_player( origin )
{
	player_origin = level.player GetEye();
	
	dist_sqrd = clamp( DistanceSquared( player_origin, origin ), CONST_DESTRUCTIBLE_QUAKE_DIST_SQRD_MIN, CONST_DESTRUCTIBLE_QUAKE_DIST_SQRD_MAX );
	ratio	  = 1 - ( dist_sqrd - CONST_DESTRUCTIBLE_QUAKE_DIST_SQRD_MIN ) / ( CONST_DESTRUCTIBLE_QUAKE_DIST_SQRD_MAX - CONST_DESTRUCTIBLE_QUAKE_DIST_SQRD_MIN );
	quake	  = linear_interpolate( ratio, CONST_DESTRUCTIBLE_QUAKE_AT_MAX_DIST, CONST_DESTRUCTIBLE_QUAKE_AT_MIN_DIST );
	
	Earthquake( quake, 0.6, player_origin, 3072 );
}

earthquake_valid_entity( ent, attacker )
{
	if ( !IsDefined( ent ) || !IsDefined( ent.origin ) || !IsDefined( attacker ) )
		return false;
	
	is_player = IsPlayer( attacker ) || ( IsDefined( attacker.owner ) && IsPlayer( attacker.owner ) );
	can_see	  = false;
	valid_ent = false;
	
	if ( IsDefined( ent.destructible_type ) )
	{
		// Don't add camera shake to non tank or non vehicle destructibles
		valid_ent = IsSubStr( ent.destructible_type, "tank" ) || IsSubStr( ent.destructible_type, "vehicle_" );
	}
	else if ( IsDefined( ent.classname ) )
	{
		// Spawned vehicles in oilrocks throw the "destructible_exploded" flag on death
		valid_ent = IsSubStr( ent.classname, "script_vehicle_" );
	}
	else if ( IsValidMissile( ent ) )
	{
		valid_ent = true;
	}
	
	// Only check to see if the player can see the
	// destroyed ent if the player didn't destroy it
	if ( !is_player )
	{
		can_see = level.player player_looking_at( ent.origin, undefined, true );
	}
	
	// If the destroyed ent is valid and the player destroyed
	// it or the player is looking at the destroyed ent
	return valid_ent && ( is_player || can_see );
}

earthquake_on_death()
{
	self waittill( "death", attacker, type, weapon );
	
	if ( self isVehicle() && isHelicopter() && !maps\_vehicle_code::vehicle_should_do_rocket_death( self.model, attacker, type ) )
	{
		msg = self waittill_any_timeout( 40, "crash_done" );
		if ( IsDefined( msg ) && msg == "timeout" )
			return;
	}
	
	if ( IsDefined( attacker ) && IsDefined( self ) && earthquake_valid_entity( self, attacker ) )
	{
		earthquake_player( self.origin );
	}
}

earthquake_player_missile_monitor( level_endon )
{
	self endon( level_endon );
	
	while ( 1 )
	{
		level waittill( "LISTEN_apache_player_missile_fire", missile );
		
		if ( IsValidMissile( missile ) )
		{
			missile childthread earthquake_on_death_missile();
		}
	}
}

earthquake_on_death_missile()
{
	self waittill( "death" );
	
	if ( IsDefined( self ) && IsDefined( self.origin ) )
	{
		earthquake_player( self.origin );
	}
}




apache_mission_heli_ai_collision()
{
	heli_ai_collision_cylinder_setup();
}

manage_all_rpg_ai_attack_player_think( targetname, level_endon )
{
	//  targetname can be undefined.
	level endon( level_endon );
	
	while ( 1 )
	{
		fired = undefined;
		
		ai_rpg = rpg_ai_get_ready_array( targetname );
		if ( ai_rpg.size )
		{
			target = manage_all_rpg_ai_get_target();
			if ( IsDefined( target ) )
			{
				shooter = rpg_ai_pick_shooter( ai_rpg, target );
				if ( IsDefined( shooter ) )
				{
					fired = shooter rpg_ai_attack( target, true );
				}
			}
		}
		
		if ( IsDefined( fired ) && fired )
		{
			wait RandomFloatRange( level.apache_difficulty.ai_rpg_attack_delay_min , level.apache_difficulty.ai_rpg_attack_delay_max  );
		}
		else
		{
			wait 0.1;
		}
	}
}

rpg_ai_attack( target, homing )
{
	self notify( "rpg_ai_attack" );
	self endon( "rpg_ai_attack" );
	self endon( "death" );
	
	self ClearEnemy();
	self AllowedStances( "stand" );
	self enable_dontevershoot();
	self disable_pain();
	self.combatmode_old = self.combatmode;
	self.combatmode		= "no_cover";
	
	track_ent		 = spawn_tag_origin();
	track_ent.origin = target.origin;
	track_ent LinkTo( target );
	self SetEntityTarget( track_ent );
	
	time_to_fail = GetTime() + 4000;
	while ( 1 )
	{
		reloading = ( IsDefined( self.IsReloading ) && self.IsReloading ) || ( IsDefined( self.a.exposedReloading ) && self.a.exposedReloading );
		if ( !reloading )
			break;
		
		if ( GetTime() >= time_to_fail )
			return false;
		
		wait 0.05;
	}
	
	// Give the ai a chance to aim at the target
	wait 1.0;
	
	if ( !IsDefined( target ) )
	{
		return false;
	}
	
	// If the AI is crouched or prone he won't track the target
	if ( IsDefined( self.a.pose ) && self.a.pose != "stand" )
	{
		return false;
	}
	
	if ( is_apache_player( target ) )
	{
		self missile_attack_notify_target_of_lock_and_delay( target );
	}
	
	if ( !IsDefined( target ) || !self CanShoot( target.origin ) )
	{
		if ( IsDefined( target ) && is_apache_player( target ) )
		{
			self notify( "LISTEN_missile_lockOnFailed" );
		}
		
		return false;
	}
		
	self ai_attack_missile( target, homing );
	
	// Delay allowing the ai to shoot so he doesn't
	// fire another missile right after
	self thread rpg_ai_attack_clear_no_shoot( 3.5, "rpg_ai_attack", track_ent );
	
	return true;
}

rpg_ai_attack_clear_no_shoot( delay, self_endon, track_ent )
{
	self endon( "death" );
	
	if ( delay > 0 )
	{
		if ( IsDefined( self_endon ) )
		{
			self endon( self_endon );
		}
		wait delay;
	}
	
	self AllowedStances( "stand", "crouch" );
	self disable_dontevershoot();
	self enable_pain();
	
	if ( IsDefined( self.combatmode_old ) )
	{
		self.combatmode		= self.combatmode_old;
		self.combatmode_old = undefined;
	}
	
	if ( IsDefined( track_ent ) )
	{
		self ClearEntityTarget();
		track_ent Delete();
	}
}

rpg_ai_pick_shooter( ai_array, target )
{
	AssertEx( IsArray( ai_array ) && ai_array.size, "Invalid or empty array passed to rpg_ai_pick_shooter()" );
	
	ai_valid = [];
	foreach ( ai in ai_array )
	{
		if ( IsDefined( ai.a.pose ) && ai.a.pose == "stand" && ai CanShoot( target.origin ) )
			ai_valid[ ai_valid.size ] = ai;
	}
	
	shooter = undefined;
	if ( ai_valid.size )
	{
		shooter = ai_valid[ RandomInt( ai_valid.size ) ];
	}
	
	return shooter;
}

manage_all_rpg_ai_get_target()
{
	return get_apache_player();
}

rpg_ai_get_ready_array( targetname )
{
	if ( IsDefined( targetname ) )
		ai_all = get_living_ai_array( targetname, "targetname" );
	else
		ai_all = GetAIArray();
	ai_rpg = [];
	foreach ( ai in ai_all )
		if ( IsDefined( ai.rpg_ai_in_position ) && ai.rpg_ai_in_position )
			ai_rpg[ ai_rpg.size ] = ai;
	return ai_rpg;
}

apache_precache()
{
	
	PreCacheItem( "rpg" );
	PreCacheItem( "rpg_straight" );
	PreCacheItem( "rpg_player" );
	PreCacheItem( "apache_lockon_missile_ai" );
	PreCacheItem( "apache_lockon_missile_ai_enemy" );
	
	PreCacheModel( "viewhands_player_delta" );
	
	PreCacheString( &"OILROCKS_OBJ_APACHE_ATTACK" );
	PreCacheString( &"OILROCKS_OBJ_APACHE_CHASE" );
	PreCacheString( &"OILROCKS_OBJ_APACHE_ESCORT" );
	PreCacheString( &"OILROCKS_OBJ_APACHE_CHOPPER" );
	PreCacheString( &"OILROCKS_OBJ_APACHE_GARAGE" );
	PreCacheString( &"OILROCKS_OBJ_INFANTRY" );
	
	PreCacheString( &"OILROCKS_QUOTE_CAESAR_KILLED" );
	PreCacheString( &"OILROCKS_QUOTE_ESCORT_INFANTRY_DIED" );
	
		// Apache Section Precache
	maps\oilrocks_apache_hints::apache_hints_precache();
	vehicle_scripts\_chopper_ai_missile_defense::_precache();

	level.dronesThermalTeamSelect = "axis";
	
	post_load_precache( ::post );

}

post()
{
	start_apache_common();
		// Apache Section Init
	maps\oilrocks_apache_code::chopper_ai_init();
	maps\_drone_ai::init();
	
	add_global_spawn_function( "axis", ::visualize_ai_for_helicopter );
	level.struct = undefined;
	_globals();
	_flags();
	
	level.apache_savecheck = ::apache_autosave_check;
}

apache_autosave_check()
{
	AssertEX( IsDefined( level.player.riding_heli ), "overriding autosave without player helicopter" );
	
	health_percent = level.player.riding_heli vehicle_scripts\_apache_player::apache_health_pct_get();
	if( health_percent < 0.5 )
		return false;
	if( level.player.riding_heli.missile_defense vehicle_scripts\_chopper_missile_defense_utility::isAnyEnemyLockedOnToMe() )
		return false;
	if( level.player.riding_heli.missile_defense vehicle_scripts\_chopper_missile_defense_utility::isAnyMissileFiredOnMe() )
		return false;
	return true;
}

visualize_ai_for_helicopter()
{
	self waittill ( "death" );
	if( IsDefined( self ) )
	{
		self ThermalDrawDisable();
	}
}

_globals()
{
	level.guy1		= undefined;
	level.guy2		= undefined;
	level.guy3		= undefined;
	level.guy4		= undefined;
	level.enemy_pool	= [];
}

_flags()
{
	flag_init( "FLAG_apache_tut_fly_stop_control_hint" );
	flag_init( "FLAG_apache_tut_fly_stop_auto_pilot" );
	flag_init( "FLAG_apache_tut_fly_quarter" );
	flag_init( "FLAG_apache_tut_fly_half" );
	flag_init( "FLAG_apache_tut_fly_targets" );
	flag_init( "FLAG_apache_tut_fly_finished" );
	
	flag_init( "FLAG_apache_factory_exit_canyon" );
	flag_init( "FLAG_apache_factory_allies_close" );
	flag_init( "FLAG_apache_factory_player_close" );
	flag_init( "FLAG_apache_factory_hint_missiles" );
	flag_init( "FLAG_apache_factory_hint_mg" );
	flag_init( "FLAG_apache_factory_hind_take_off_dead" );
	flag_init( "FLAG_apache_factory_destroyed_ai" );
	flag_init( "FLAG_apache_factory_destroyed_vehicles" );
	flag_init( "FLAG_apache_factory_destroyed" );
	flag_init( "FLAG_apache_factory_finished" );
	
	flag_init( "FLAG_apache_chase_player_close_to_island" );
	flag_init( "FLAG_apache_chase_caesar_close_to_island" );
	flag_init( "FLAG_apache_chase_caesar_arrived_to_island" );
	flag_init( "FLAG_apache_chase_vo_done" );
	
	flag_init( "FLAG_apache_chase_finished" );
	flag_init( "FLAG_apache_escort_blackhawk_dropping_off" );

	flag_init( "FLAG_apache_antiairfinished" );
	
	flag_init( "FLAG_apache_escort_allies_enc_start_01" );
	flag_init( "FLAG_apache_escort_allies_enc_start_02" );
	flag_init( "FLAG_apache_escort_allies_enc_start_03" );
	flag_init( "FLAG_apache_escort_allies_enc_start_04" );
	flag_init( "FLAG_apache_escort_allies_enc_start_05" );
	flag_init( "FLAG_apache_escort_allies_enc_start_06" );
	
	flag_init( "FLAG_apache_escort_allies_enc_end_01" );
	flag_init( "FLAG_apache_escort_allies_enc_end_02" );
	flag_init( "FLAG_apache_escort_allies_enc_end_03" );
	flag_init( "FLAG_apache_escort_allies_enc_end_04" );
	flag_init( "FLAG_apache_escort_allies_enc_end_05" );
	flag_init( "FLAG_apache_escort_allies_enc_end_06" );
	
	flag_init( "FLAG_apache_escort_allies_enc_02_jeeps_dead" );
	flag_init( "FLAG_apache_escort_allies_enc_04_jeeps_dead" );
	flag_init( "FLAG_apache_escort_allies_inside" );
	
	flag_init( "FLAG_apache_chopper_vo_take_it_done" );
	flag_init( "FLAG_apache_chopper_hind_destroyed_two" );
	flag_init( "FLAG_apache_chopper_hind_remaining_three" );
	flag_init( "FLAG_apache_chopper_hind_remaining_one" );
	flag_init( "FLAG_apache_chopper_vo_done" );
	flag_init( "FLAG_apache_chopper_finished" );
	
	flag_init( "FLAG_apache_garage_sequence_player_looked" );
	flag_init( "FLAG_apache_garage_sequence_anim_started" );
	flag_init( "FLAG_apache_garage_sequence_rpgs" );
	flag_init( "FLAG_apache_garage_sequence_anim_done" );
	flag_init( "FLAG_apache_garage_sequence_jeep_crash_vo_done" );
	flag_init( "FLAG_apache_garage_sequence_jeep_moving_again" );
	flag_init( "FLAG_apache_garage_sequence_jeep_path_mid" );
	flag_init( "FLAG_apache_garage_sequence_jeep_path_done" );
	flag_init( "FLAG_apache_garage_finished" );
	
	flag_init( "FLAG_apache_finale_enemy_vehicle_wave_done_01" );
	flag_init( "FLAG_apache_finale_ally_jeep_inside_tennis_area" );
	flag_init( "FLAG_apache_finale_enemy_vehicle_waves_done" );
	flag_init( "FLAG_apache_finale_allies_enc_start_02" );
	flag_init( "FLAG_apache_finale_allies_enc_start_03" );
	flag_init( "FLAG_apache_finale_allies_enc_start_04" );
	flag_init( "FLAG_apache_finale_allies_enc_end_01" );
	flag_init( "FLAG_apache_finale_allies_enc_end_02" );
	flag_init( "FLAG_apache_finale_allies_enc_end_03" );
	flag_init( "FLAG_apache_finale_allies_enc_end_04" );
	flag_init( "FLAG_apache_finale_finished" );
	
	flag_init( "FLAG_transition_to_infantry_finished" );
	
	flag_init( "FLAG_infantry_section_finished" );
}
