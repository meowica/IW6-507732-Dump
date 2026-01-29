#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

 /***********************************/
 /*********** * UTILITY**************/
 /***********************************/

array_keep_values( array, keys, values, op )
{
	Assert( IsDefined( array ) && IsArray ( array ) );
	
	if ( !IsDefined( keys ) || !IsDefined( values ) )
		return array;
	Assert( IsArray( keys ) && IsArray( values ) && keys.size == values.size );
	
	op = ToLower( ter_op( IsDefined( op ), op, "and" ) );
	switch( op )
	{
		case "and":
		case "or":
			break;
		default:
			op = "and";
	}
	
	_array = [];
	keep   = 1;
	
	foreach ( item in array )
	{
		switch( op )
		{
			case "and":
				keep = 1;
				foreach ( i, key in keys )
				{
					value = item get_key( key );
					if ( !compare( value, values[ i ] ) )
					{
						keep *= 0;
						break;
					}
				}
				break;
			case "or":
				keep = 0;
				foreach ( i, key in keys )
				{
					value = item get_key( key );
					if ( compare( value, values[ i ] ) )
					{
						keep = 1;
						break;
					}
				}
				break;
		}
		if ( keep )
			_array[ _array.size ] = item;
	}
	return _array;
}

array_keep_key_values( array, key, values )
{
	Assert( IsDefined( array ) && IsArray ( array ) );
	Assert( IsDefined( key ) );
	Assert( IsDefined( values ) && IsArray( values ) );
	
	_array = [];
	
	foreach ( item in array )
	{
		keep = 0;
		foreach ( value in values )
		{
			if ( item compare_value( key, value ) )
			{
				keep = 1;
				break;
			}
		}
		
		if ( keep )
			_array[ _array.size ] = item;
	}
	return _array;
}

compare_value( key, value )
{
	if ( !IsDefined( self ) || !IsDefined( value ) )
		return false;
	return compare( self get_key( key ), value );
}

compare( a, b )
{
	if ( IsDefined( a ) && IsDefined( b ) )
		return ter_op( a == b, true, false );
	if ( IsDefined( a ) && !IsDefined( b ) )
		return false;
	if ( !IsDefined( a ) && IsDefined( b ) )
		return false;
	if ( !IsDefined( a ) && !IsDefined( b ) )
		return false;
}

get_key( key, _default )
{
    value = undefined;
    
    if ( !IsDefined( self ) || !IsDefined( key ) )
		return ter_op( IsDefined( _default ) && !IsDefined( value ), _default, value );
    	
    switch ( key )
    {
    	case "alpha":
    		value = self.alpha;
    		break;
        case "angles":
            value = ter_op( IsDefined( self.angles ), self.angles, ( 0, 0, 0 ) );
            break;
       	case "classname":
            value = self.classname;
            break;
        case "health":
        	value = self.health;
        	break;
        case "magic_bullet_shield":
        	value = self.magic_bullet_shield;
        	break;
        case "maxhealth":
        	value = self.maxhealth;
        	break;
        case "origin":
        	value = self.origin;
        	break;
       	case "script_drone":
       		value = self.script_drone;
       		break;
       	case "script_friendname":
       		value = self.script_friendname;
       		break;
       	case "script_group":
       		value = self.script_group;
       		break;
        case "script_index":
        	value = self.script_index;
        	break;
        case "script_linkName":
        	value = self.script_linkName;
        	break;
        case "script_linkTo":
        	value = self.script_linkTo;
        	break;
        case "script_noteworthy":
            value = self.script_noteworthy;
            break;
        case "script_parameters":
        	value = self.script_parameters;
        	break;
        case "script_specialops":
        	value = self.script_specialops;
        	break;
        case "script_team":
        	value = self.script_team;
        	break;
        case "script_vehicleride":
        	value = self.script_vehicleride;
        	break;
        case "spawnflags":
        	value = self.spawnflags;
        	break;
        case "speed":
        	value = self.speed;
        	break;
        case "target":
            value = self.target;
            break;
        case "targetname":
            value = self.targetname;
            break;
        case "team":
        	value = self.team;
        	break;
    }
    return ter_op( IsDefined( _default ) && !IsDefined( value ), _default, value );
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

getTeam()
{
	if ( isTurret( self ) && IsDefined( self.script_team ) )
		return self.script_team;
	if ( self maps\_vehicle::isVehicle() && IsDefined( self.script_team ) )
		return self.script_team;
	if ( IsDefined( self.team ) )
		return self.team;
	return "none";
}

isTurret( obj )
{
	return ( IsDefined( obj ) && IsDefined( obj.classname ) && IsSubStr( obj.classname, "turret" ) );
}

array_remove_undefined_dead_or_dying( array )
{
	_array = [];
	foreach ( item in array )
	{
		if ( !IsDefined( item ) )
			continue;
		if ( !IsAlive( item ) )
			continue;
		if ( IsAI( item ) && item doingLongDeath() )
			continue;
		_array[ _array.size ] = item;
	}
	return _array;
}

giveUnlimitedRPGAmmo()
{
	self endon( "death" );
	
	for ( ;; wait 1.0 )
		self.a.rockets = 5;
}

addAsApacheHudTarget( apache, delay_before_add )
{
	
	Assert( IsDefined( apache ), "apache must be defined" );
	
	self endon( "death" );
	
	if ( IsDefined( delay_before_add ) && delay_before_add > 0 )
		wait delay_before_add;
	
	apache vehicle_scripts\_apache_player::hud_addAndShowTargets( [ self ] );
}

apache_sun_settings()
{
	level.apache_sun_settings = [];
	sunsettings				  = [
				   [ "sm_sunenable", 1.0 ],
				   [ "sm_sunsamplesizenear", 2.8 ],
				   [ "sm_sunShadowScale", 1 ]
				  ];
	
	foreach ( dvarvalue in sunsettings )
	{
		level.apache_sun_settings[ dvarvalue[ 0 ]] = GetDvarFloat( dvarvalue[ 0 ] );
		SetSavedDvar( dvarvalue[ 0 ], dvarvalue[ 1 ] );
	}
}

apache_sun_settings_restore()
{
	foreach ( dvar, value in level.apache_sun_settings )
		SetSavedDvar( dvar, value );
}

spawn_apache_player( section, height_max, height_min )
{
		Assert( IsDefined( section ) );
		apache_start		= get_apache_spawn_struct( section );
		return spawn_apache_player_at_struct( apache_start, height_max, height_min );
}

spawn_apache_player_at_struct( apache_start, height_max, height_min )
{
	apache_sun_settings();
	// Spawn the drivable apache and put in the player in it.
	
	apache_player = undefined;
	
	apache_spawner = GetEnt( "vehicle_apache_player", "targetname" );
	Assert( IsDefined( apache_spawner ) );
	
	apache_spawner.origin = apache_start.origin + ( 0, 0, 128 );
	apache_spawner.angles = apache_start.angles;
	
	apache_player = vehicle_spawn( apache_spawner );
	Assert( IsDefined( apache_player ) );
	apache_player.targetname = "apache_player";
	
	apache_player MakeEntitySentient( "allies" );
	
	altitude_control = IsDefined( height_max ) && IsDefined( height_min );
	
	//level.player PlayerSetStreamOrigin( apache_start.origin );
	
	// For all apache starts the difficulty struct is defined on level. For things like the transition start it is not.
	flares_auto = true;
	if ( IsDefined( level.apache_difficulty ) && IsDefined( level.apache_difficulty.flares_auto ) )
	{
		flares_auto = level.apache_difficulty.flares_auto;
	}
	apache_player vehicle_scripts\_apache_player::_start( level.player, altitude_control, flares_auto );
	
	apache_player thread apache_mission_impact_water_think();
	apache_player thread maps\oilrocks_apache_code::destructible_quakes_on();
	
	apache_player maps\oilrocks_apache_code::update_targets();
	
	if ( altitude_control )
	{
		if ( IsDefined( height_max ) )
			SetSavedDvar( "vehHelicopterMaxAltitude", height_max );
		
		if ( IsDefined( height_min ) )
			SetSavedDvar( "vehHelicopterMinAltitude", height_min );
	}
	
	apache_player childthread maps\oilrocks_apache_code::manage_active_hind_forced_targets();
	
	if ( IsDefined( level.apache_savecheck ) )
		level.autosave_check_override = level.apache_savecheck;
	

	return apache_player;
}

apache_mission_impact_water_think()
{
	level.apache_missile_water_z		= -320;
	level.apache_missile_water_z_actual = -352;
	self thread apache_mission_impact_water_missiles();
	
	self waittill ( "LISTEN_heli_end" );
	
	level.apache_missile_water_z		= undefined;
	level.apache_missile_water_z_actual = undefined;
}

apache_mission_impact_water_missiles()
{
	self endon( "LISTEN_heli_end" );
	while ( 1 )
	{
		level waittill( "LISTEN_apache_player_missile_fire", missile );
		
		if ( IsDefined( missile ) && IsValidMissile( missile ) )
		{
			missile childthread apache_mission_impact_water_missile_think();
		}
	}
}

apache_mission_impact_water_missile_think()
{
	self endon( "death" );
	
	while ( IsValidMissile( self ) && self.origin[ 2 ]   >= level.apache_missile_water_z )
		wait 0.05;
	
	if ( IsValidMissile( self ) && IsDefined( self.origin ) )
	{
		if ( self.origin[ 2 ] < level.apache_missile_water_z )
		{
			PlayFX(
				getfx( "FX_vfx_apache_missile_water_impact" ),
				( self.origin[ 0 ], self.origin[ 1 ], level.apache_missile_water_z_actual + 5 ),
				( 0				, 0				, 1										 ),
				AnglesToForward( ( 0, RandomInt( 360 ), 0 ) )
			 );
		}
		self Delete();
	}
}

get_apache_spawn_struct( section )
{
	apache_starts = getstructarray( "apache", "targetname" );
	Assert( apache_starts.size );
	keys		 = [ "script_noteworthy", "script_parameters" ];
	values		 = [ "player"			, section ];
	apache_start = array_keep_values( apache_starts, keys, values )[ 0 ];
	Assert( IsDefined( apache_start ) );
	
	return apache_start;
}

friendly_setup()
{
	self deletable_magic_bullet_shield();
}

get_obj_ent_hvt()
{
	if ( !IsDefined( level.obj_ent_hvt ) )
		level.obj_ent_hvt = spawn_tag_origin();
	level.obj_ent_hvt Unlink();
	return level.obj_ent_hvt;
}

camlanding_from_apache( targetname, slomo_in, blend_to_tag_time, tailflash )
{
	if ( IsDefined( level.player.riding_heli ) )
	{
		origin = level.player.riding_heli.origin;
		angles = level.player.riding_heli.angles;
		
		foreach( guy in level.apache_target_manager )
			level.player.riding_heli thread vehicle_scripts\_apache_player::hud_hideTargets( [ guy ] );
		
		level notify ( "new_missile_nag_thread" ); // stop the nagging thread about missiles.
		level.player.riding_heli vehicle_scripts\_apache_player::_end();
		
		apache_sun_settings_restore();
		level.player.riding_heli = undefined;
		
		level.player_apache_standin = maps\oilrocks_apache_code::spawn_apache_ally_targetname( "apache_player_standin","apache_player_standin", origin,angles);
		level.player_apache_standin thread maps\oilrocks_apache_code::self_make_chopper_boss( undefined, true );
	}
	else if ( IsDefined( level.player_apache_standin ) )
	{
		level.player_apache_standin Delete();
		level.player_apache_standin = undefined;
	}
	
	maps\oilrocks_slamzoom::vehicle_spline_cam( targetname, slomo_in, blend_to_tag_time,tailflash );
}