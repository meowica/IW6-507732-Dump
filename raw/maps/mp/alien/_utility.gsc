#include common_scripts\utility;
#include maps\mp\_utility;


HEALTH_PACK_MODEL = "paris_chase_pharmacie_sign_02";

player_healthbar_update()
{
	// player HP bar: rewrite with LUI for HUD
	self endon( "death" );
	
	waittillframeend;
	
	while ( true )
	{
		player_health_ratio = self.health / self.maxhealth;
		
		SetDvar( "alien_player_health", self.health / self.maxhealth );

		while ( player_health_ratio == ( self.health / self.maxhealth ) )
			wait 0.1;
		
		// best if regen notifies when health changes
		// self waittill( "damage" );
	}
}

/*
NONPLAYER_MELEE_DAMAGE = 100;

apply_damage( num_bar, source, apply_player_view_rip )
{
	if ( !isPlayer( self ) )
	{
		self DoDamage( NONPLAYER_MELEE_DAMAGE, source.origin, source );
		return;
	}
	
	self.last_alien_melee_time = GetTime();
	self playRumbleOnEntity ( "damage_light" );
	self PlaySound( "player_hit_sfx_alien" );
	self thread play_damage_overlay();
	damage_amount = ceil ( num_bar * level.health_amount_per_health_bar );
	
	if ( IsDefined( self.damagemultiplier ) )
	{
		damage_amount /= self.damagemultiplier;
	}
	enemy_blocked = self check_for_block( source );
	if ( enemy_blocked )
	{
		return;
	}
	else
	{
	self DoDamage( damage_amount, source.origin, source );
	GetDvarInt ( "enable_player_view_rip" );
		if ( GetDvarInt ( "enable_player_view_rip" ) == 1 )
		{
			if ( isDefined ( apply_player_view_rip ) && apply_player_view_rip == true )
			{
				source thread player_view_rip( self );
			}
		}
	}
}

check_for_block( source )
{
	enemy_blocked = false;
	currentweapon = self GetcurrentWeapon();
	player_is_ADS = isADS();
	enemy_in_front = false;
	melee_in_hand = false;
	melee_weapon_health = 0;
	playerForwardVector = anglesToForward( self.angles );
    playerToEnemyVector = VectorNormalize( source.origin - self.origin );
    dotProduct = VectorDot( playerToEnemyVector, playerForwardVector );
    if ( dotProduct > 0.5 )
    {
        enemy_in_front = true;
    }
    
    if ( currentweapon == "axe_alien" )
	{
		melee_weapon_health = self GetCurrentWeaponClipAmmo();
		melee_in_hand = true;
	}
    
    if ( melee_in_hand && player_is_ADS && enemy_in_front && ( melee_weapon_health > 0 ) )
	{
    	self SetWeaponAmmoClip( "axe_alien", ( melee_weapon_health - 1 ));
		self PlaySound( "crate_impact" );
    	Earthquake( 0.75,0.5,self.origin, 100 );
    	enemy_blocked = true;
    	if ( self GetCurrentWeaponClipAmmo() == 0 )
    	{
    		self TakeWeapon( currentweapon );
    		weapon_list = self GetWeaponsList( "primary" );
    		if ( weapon_list.size > 0 )
    		{
    			self SwitchToWeapon( weapon_list[0] );
    		}
		}
  	}
   	return enemy_blocked;
}

play_damage_overlay()
{
	self endon ( "death" );
	
	self.combatDamageOverlay.alpha = 1;
	self.combatDamageOverlay fadeOverTime( 0.5 );
	self.combatDamageOverlay.alpha = 0;	
}

player_view_rip( enemy )
{
	enemy endon ( "death" );
	enemy notify ( "kill previous player view rip" ); 
	enemy endon ( "kill previous player view rip" );
	
	AssertEx ( isPlayer ( enemy ), "Invalid player" );
	
	if ( !isAlive ( enemy ) )
	{
		return;
	}
	
	//These two values are assumed alien speed and the amount of time which the alien will take to land.  They are used to
	//determine roughly the landing location of the alien
	alien_speed = 200;
	time_after_melee = 1.5;
	
	alien_forward_vector = AnglesToForward ( self.angles );
	alien_position_after_melee = self.origin + alien_forward_vector * alien_speed * time_after_melee;
	//level thread draw_debugLine ( self.origin, alien_position_after_melee, ( 1, 0, 0), 3600 );
	
	player_to_alien_pos_vector = alien_position_after_melee - enemy.origin;
	player_to_alien_pos_yaw = VectorToYaw ( player_to_alien_pos_vector );
	player_forward_yaw = enemy.angles [ 1 ];
	yaw_difference = player_to_alien_pos_yaw - player_forward_yaw;
	yaw_difference = AngleClamp180 ( yaw_difference );
	rip_percent = ( GetDvarFloat ( "percent_player_view_rip" ) ) / 100;
	yaw_difference = yaw_difference * rip_percent;
	
	player_rig = spawn_anim_model( "player_rig", enemy.origin );
	player_rig hide();
	player_rig.angles = player_rig.angles * ( 1, 0, 1 );
	player_yaw = enemy.angles * ( 0, 1, 0 );
	player_rig.angles = player_rig.angles + player_yaw * ( 0, 1, 0 );
	enemy playerlinkto ( player_rig, "tag_origin", 1, 180, 180, 180, 180, true );
	player_rig RotateYaw ( yaw_difference, 0.3, 0, 0 );
	wait ( 0.3 );
	enemy unlink();
	player_rig delete();
}
*/

/*
=============
///ScriptDocBegin
"Name: enable_alien_scripted()"
"Summary: Puts the alien into a scripted state that allows level scripts to set their goals and control them directly"
"Module: Alien"
"CallOn: Alien actor"
"Example: alien enable_alien_scripted()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
enable_alien_scripted()
{
	self.alien_scripted = true;
	self notify( "alien_main_loop_restart" );
}

/*
=============
///ScriptDocBegin
"Name: disable_alien_scripted()"
"Summary: Clears the alien's scripted state"
"Module: Alien"
"CallOn: Alien actor"
"Example: alien disable_alien_scripted()"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
disable_alien_scripted()
{
	self.alien_scripted = false;
}

/*
=============
///ScriptDocBegin
"Name: get_players()"
"Summary: Returns connected players. Preparing for MP transition"
"Module: Alien"
"Example: foreach ( player in get_players() ){ ... }"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
get_players()
{
	return level.players;
}

/*
=============
///ScriptDocBegin
"Name: any_player_nearby()"
"Summary: Returns whether any player is within a certain distance."
"Module: Alien"
"MandatoryArg: <origin> The origin from which to check."
"MandatoryArg: <dist_sqr> Square of max distance."
"Example: result = any_player_nearby( self.origin, MAX_DISTANCE )"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
any_player_nearby( origin, dist_sqr )
{
	foreach ( player in level.players )
	{
		if ( DistanceSquared( player.origin, origin ) < dist_sqr )
		{
			return true;
		}
	}
	return false;		
}



min_dist_from_all_locations( ent, location_array, min_dist )
{
	min_dist_sqr = min_dist * min_dist;
	foreach ( location in location_array )
	{
		if ( Distance2DSquared( ent.origin, location.origin ) < min_dist_sqr )
		{
			return false;
		}
	}
	
	return true;
}


/*
=============
///ScriptDocBegin
"Name: set_vision_set_player( <visionset> , <transition_time> )"
"Summary: Sets the vision set over time for a specific player in coop"
"Module: Utility"
"MandatoryArg: <visionset>: Visionset file to use"
"OptionalArg: <transition_time>: Time to transition to the new vision set. Defaults to 1 second."
"Example: level.player2 set_vision_set_player( "blackout_darkness", 0.5 );"
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
set_vision_set_player( visionset, transition_time )
{
	if ( init_vision_set( visionset ) )
		return;

	Assert( IsDefined( self ) );
	Assert( level != self );

	if ( !isdefined( transition_time ) )
		transition_time = 1;
	self VisionSetNakedForPlayer( visionset, transition_time );
}

init_vision_set( visionset )
{
	level.lvl_visionset = visionset;

	if ( !isdefined( level.vision_cheat_enabled ) )
		level.vision_cheat_enabled = false;

	return level.vision_cheat_enabled;
}

// TEMP: Resides here until flawless, then move to maps\mp\_utility
// Since ent_flag can be called on players who can disconnect, 
// TODO: make sure flag functions end well on player disconnect or game end
// =======================================================================
// 					ENTITY FLAG
// =======================================================================

/*
 =============
///ScriptDocBegin
"Name: ent_flag_wait( <flagname> )"
"Summary: Waits until the specified flag is set on self. Even handles some default flags for ai such as 'goal' and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to wait on"
"Example: enemy ent_flag_wait( "goal" );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_wait( msg )
{
	if ( isplayer( self ) )
		self endon( "disconnect" );
	
	AssertEx( ( !IsSentient( self ) && IsDefined( self ) ) || IsAlive( self ), "Attempt to check a flag on entity that is not alive or removed" );

	while ( IsDefined( self ) && !self.ent_flag[ msg ] )
		self waittill( msg );
}

 /*
 =============
///ScriptDocBegin
"Name: ent_flag_wait_either( <flagname1> , <flagname2> )"
"Summary: Waits until either of the the specified flags are set on self. Even handles some default flags for ai such as 'goal' and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname1> : name of one flag to wait on"
"MandatoryArg: <flagname2> : name of the other flag to wait on"
"Example: enemy ent_flag_wait( "goal", "damage" );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_wait_either( flag1, flag2 )
{
	if ( isplayer( self ) )
		self endon( "disconnect" );
		
	AssertEx( ( !IsSentient( self ) && IsDefined( self ) ) || IsAlive( self ), "Attempt to check a flag on entity that is not alive or removed" );

	while ( IsDefined( self ) )
	{
		if ( ent_flag( flag1 ) )
			return;
		if ( ent_flag( flag2 ) )
			return;

		self waittill_either( flag1, flag2 );
	}
}

 /*
 =============
///ScriptDocBegin
"Name: ent_flag_wait_or_timeout( <flagname> , <timer> )"
"Summary: Waits until either the flag gets set on self or the timer elapses. Even handles some default flags for ai such as 'goal' and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname1: Name of one flag to wait on"
"MandatoryArg: <timer> : Amount of time to wait before continuing regardless of flag."
"Example: ent_flag_wait_or_timeout( "time_to_go", 3 );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_wait_or_timeout( flagname, timer )
{
	if ( isplayer( self ) )
		self endon( "disconnect" );
		
	AssertEx( ( !IsSentient( self ) && IsDefined( self ) ) || IsAlive( self ), "Attempt to check a flag on entity that is not alive or removed" );

	start_time = GetTime();
	while ( IsDefined( self ) )
	{
		if ( self.ent_flag[ flagname ] )
			break;

		if ( GetTime() >= start_time + timer * 1000 )
			break;

		self ent_wait_for_flag_or_time_elapses( flagname, timer );
	}
}

ent_wait_for_flag_or_time_elapses( flagname, timer )
{
	self endon( flagname );
	wait( timer );
}

/*
=============
///ScriptDocBegin
"Name: ent_flag_waitopen( <msg> )"
"Summary: "
"Module: Entity"
"CallOn: An entity"
"MandatoryArg: <param1>: "
"OptionalArg: <param2>: "
"Example: "
"SPMP: singleplayer"
///ScriptDocEnd
=============
*/
ent_flag_waitopen( msg )
{
	AssertEx( ( !IsSentient( self ) && IsDefined( self ) ) || IsAlive( self ), "Attempt to check a flag on entity that is not alive or removed" );

	while ( IsDefined( self ) && self.ent_flag[ msg ] )
		self waittill( msg );
}

ent_flag_assert( msg )
{
	AssertEx( !self ent_flag( msg ), "Flag " + msg + " set too soon on entity" );
}


 /*
 =============
///ScriptDocBegin
"Name: ent_flag_waitopen_either( <flagname1> , <flagname2> )"
"Summary: Waits until either of the the specified flags are open on self. Even handles some default flags for ai such as 'goal' and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname1> : name of one flag to waitopen on"
"MandatoryArg: <flagname2> : name of the other flag to waitopen on"
"Example: enemy ent_flag_waitopen_either( "goal", "damage" );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_waitopen_either( flag1, flag2 )
{
	AssertEx( ( !IsSentient( self ) && IsDefined( self ) ) || IsAlive( self ), "Attempt to check a flag on entity that is not alive or removed" );

	while ( IsDefined( self ) )
	{
		if ( !ent_flag( flag1 ) )
			return;
		if ( !ent_flag( flag2 ) )
			return;

		self waittill_either( flag1, flag2 );
	}
}

 /*
 =============
///ScriptDocBegin
"Name: ent_flag_init( <flagname> )"
"Summary: Initialize a flag to be used. All flags must be initialized before using ent_flag_set or ent_flag_wait.  Some flags for ai are set by default such as 'goal', 'death', and 'damage'"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to create"
"Example: enemy ent_flag_init( "hq_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_init( message )
{
	if ( !isDefined( self.ent_flag ) )
	{
		self.ent_flag = [];
		self.ent_flags_lock = [];
	}

	/#
	if ( IsDefined( level.first_frame ) && level.first_frame == -1 )
		AssertEx( !isDefined( self.ent_flag[ message ] ), "Attempt to reinitialize existing message: " + message + " on entity." );
	#/

	self.ent_flag[ message ] = false;
/#
	self.ent_flags_lock[ message ] = false;
#/
}

 /*
 =============
///ScriptDocBegin
"Name: ent_flag_exist( <flagname> )"
"Summary: checks to see if a flag exists"
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to check"
"Example: if( enemy ent_flag_exist( "hq_cleared" ) );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_exist( message )
{
	if ( IsDefined( self.ent_flag ) && IsDefined( self.ent_flag[ message ] ) )
		return true;
	return false;
}

 /*
 =============
///ScriptDocBegin
"Name: ent_flag_set( <flagname> )"
"Summary: Sets the specified flag on self, all scripts using ent_flag_wait on self will now continue."
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to set"
"Example: enemy ent_flag_set( "hq_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_set( message )
{
/#
 	AssertEx( IsDefined( self ), "Attempt to set a flag on entity that is not defined" );
	AssertEx( IsDefined( self.ent_flag[ message ] ), "Attempt to set a flag before calling flag_init: " + message + " on entity." );
	Assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = true;
#/
	self.ent_flag[ message ] = true;
	self notify( message );
}

 /*
 =============
///ScriptDocBegin
"Name: ent_flag_clear( <flagname> )"
"Summary: Clears the specified flag on self."
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to clear"
"OptionalArg: <remove> : free the flag completely, use this when you want to save a variable after you're never going to use the flag again."
"Example: enemy ent_flag_clear( "hq_cleared" );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag_clear( message, remove )
{
/#
 	AssertEx( IsDefined( self ), "Attempt to clear a flag on entity that is not defined" );
	AssertEx( IsDefined( self.ent_flag[ message ] ), "Attempt to set a flag before calling flag_init: " + message + " on entity." );
	Assert( self.ent_flag[ message ] == self.ent_flags_lock[ message ] );
	self.ent_flags_lock[ message ] = false;
#/
	//do this check so we don't unneccessarily send a notify
	if ( 	self.ent_flag[ message ] )
	{
		self.ent_flag[ message ] = false;
		self notify( message );
	}
	
	if ( IsDefined( remove ) && remove )
		self.ent_flag[ message ] = undefined;
}

 /*
 =============
///ScriptDocBegin
"Name: ent_flag( <flagname> )"
"Summary: Checks if the flag is set on self. Returns true or false."
"Module: Flag"
"CallOn: Any entity (script_origin, script_struct, ai, script_model, script_brushmodel, player)"
"MandatoryArg: <flagname> : name of the flag to check"
"Example: enemy ent_flag( "death" );"
"SPMP: singleplayer"
///ScriptDocEnd
 =============
 */
ent_flag( message )
{
	AssertEx( IsDefined( message ), "Tried to check flag but the flag was not defined." );
	AssertEx( IsDefined( self.ent_flag[ message ] ), "Tried to check flag " + message + " but the flag was not initialized." );

	return self.ent_flag[ message ];
}

 /*
 =============
///ScriptDocBegin
"Name: alien_mode_has( <feature_string> )"
"Summary: Checks to see if alien mode as a specific feature active. Returns true or false."
"Module: Alien"
"MandatoryArg: <feature_string> : airdrop, wave, lurker, collectible, loot (more coming!)"
"Example: if( !alien_mode_has( "airdrop" ) { return; }"
"SPMP: Multiplayer"
///ScriptDocEnd
 =============
 */
alien_mode_has( feature_str )
{
	feature_str = toLower( feature_str );
	
	if ( !isdefined( level.alien_mode_feature ) )
		return false;

	if ( !isdefined( level.alien_mode_feature[ feature_str ] ) )
		return false;
	
	return level.alien_mode_feature[ feature_str ];
}

 /*
 =============
///ScriptDocBegin
"Name: alien_mode_enable( str_1, str_2, str_3, str_4, str_5, str_6, str_7, str_8 )"
"Summary: Enables features in alien mode."
"Module: Alien"
"MandatoryArg: <feature_string> : airdrop, wave, lurker, collectible, loot, mist (more coming!)"
"Example: alien_mode_enable( "airdrop" );"
"SPMP: Multiplayer"
///ScriptDocEnd
 =============
 */
alien_mode_enable( str_1, str_2, str_3, str_4, str_5, str_6, str_7, str_8 )
{
	assertex( isdefined( str_1 ), "alien_mode_enable() called without parameters!" );
	
	if ( !isdefined( level.alien_mode_feature ) )
		level.alien_mode_feature = [];
	
	// list of all supported features, also update: check_feature_dependencies();
	if ( !isdefined( level.alien_mode_feature_strings ) )
		level.alien_mode_feature_strings = [ "kill_resource", "nogame", "airdrop", "loot", "wave", "lurker", "collectible", "mist" ];
	
	// ====== maybe not a good idea, people might not be aware of new features ===========
	if ( str_1 == "all" )
	{
		foreach ( param in level.alien_mode_feature_strings )
			alien_mode_enable_raw( param );
		
		return;
	}
	// ===================================================================================
	
	combined_param = [];
	
	if ( isdefined( str_1 ) )
		combined_param[ combined_param.size ] = toLower( str_1 );
	
	if ( isdefined( str_2 ) )
		combined_param[ combined_param.size ] = toLower( str_2 );

	if ( isdefined( str_3 ) )
		combined_param[ combined_param.size ] = toLower( str_3 );

	if ( isdefined( str_4 ) )
		combined_param[ combined_param.size ] = toLower( str_4 );

	if ( isdefined( str_5 ) )
		combined_param[ combined_param.size ] = toLower( str_5 );

	if ( isdefined( str_6 ) )
		combined_param[ combined_param.size ] = toLower( str_6 );
								
	if ( isdefined( str_7 ) )
		combined_param[ combined_param.size ] = toLower( str_7 );
									
	if ( isdefined( str_8 ) )
		combined_param[ combined_param.size ] = toLower( str_8 );
	
	check_feature_dependencies( combined_param );
	
	foreach ( param in combined_param )
		alien_mode_enable_raw( param );
}

check_feature_dependencies( combined_param )
{
	foreach ( param in combined_param )
	{
		if ( param == "loot" && !array_contains( combined_param, "collectible" ) )
			assertmsg( "Feature [loot] requires [collectible]" );
		
		if ( param == "airdrop" && !array_contains( combined_param, "wave" ) )
			assertmsg( "Feature [airdrop] requires feature [wave]" );
		
		if ( param == "lurker" && !array_contains( combined_param, "wave" ) )
			assertmsg( "Feature [lurker] requires feature [wave]" );
		
		if ( param == "mist" && !array_contains( combined_param, "wave" ) )
			assertmsg( "Feature [mist] requires feature [wave]" );
	}
}

alien_mode_enable_raw( feature_str )
{
	if ( !array_contains( level.alien_mode_feature_strings, feature_str ) )
	{
		supported_mode_strings = "";
		foreach ( feature in level.alien_mode_feature_strings )
			supported_mode_strings = supported_mode_strings + feature + " ";
	
		assertmsg( feature_str + " is not a supported feature. [ " + supported_mode_strings + "]" );
	}
	
	level.alien_mode_feature[ feature_str ] = true;
}

/*
=============
///ScriptDocBegin
"Name: alien_area_init()"
"Summary: Register distinct areas for item spawning management.  Call before _load"
"Module: Alien"
"Example: alien_area_init( areas )"
"SPMP: multiplayer"
///ScriptDocEnd
=============
*/
alien_area_init( area_array, areas_by_cycle_array )
{
	if ( !isdefined( level.world_areas ) )
	{
		level.world_areas = [];
	}

	foreach ( area in area_array )
	{
		area_volume = GetEnt( area, "targetname" );
		assert( IsDefined( area_volume ) );

		level.world_areas[ area ] = area_volume;
	}
	
	level.world_areas_by_cycle = areas_by_cycle_array;	
}

/*
=============
///ScriptDocBegin
"Name: store_weapons_status()"
"Summary: Store the weapon and the ammo status."
"Module: Alien"
"Example: player store_weapons_status()"
"SPMP: multiplayer"
///ScriptDocEnd
=============
*/
store_weapons_status()
{
	//weapons
	self.copy_fullweaponlist = self GetWeaponsListAll();
	self.copy_weapon_current = self GetCurrentWeapon();
	
	//ammo
	foreach( weapon in self.copy_fullweaponlist )
	{
		self.copy_weapon_ammo_clip[ weapon ] = self GetWeaponAmmoClip( weapon );
		self.copy_weapon_ammo_stock[ weapon ] = self GetWeaponAmmoStock( weapon );
	}
}

/*
=============
///ScriptDocBegin
"Name: restore_weapons_status()"
"Summary: Put the weapon and ammo status back to the last time store_weapons_status is called."
"Module: Alien"
"Example: player restore_weapons_status()"
"SPMP: multiplayer"
///ScriptDocEnd
=============
*/
restore_weapons_status()
{
	if( !isDefined( self.copy_fullweaponlist )
	 || !isDefined( self.copy_weapon_current )
	 || !isDefined( self.copy_weapon_ammo_clip )
	 || !isDefined( self.copy_weapon_ammo_stock )
	  )
		AssertMsg( "Call store_weapons_status() before restore_weapons_status()" );
	 
	//weapons
	//remove any they didn't have
	myWeapons = self GetWeaponsListAll();
	foreach( weapon in myWeapons )
	{
		if ( !array_contains( self.copy_fullweaponlist, weapon ) )
		{
			self TakeWeapon( weapon );
		}
	}
	
	//Give weapon and ammo back
	foreach( weapon in self.copy_fullweaponlist )
	{
		if ( !(self HasWeapon( weapon )) )
		{
			self GiveWeapon( weapon );
		}
		
		self SetWeaponAmmoClip( weapon, self.copy_weapon_ammo_clip[ weapon ]  );
		self SetWeaponAmmoStock( weapon, self.copy_weapon_ammo_stock[ weapon ]  );
	}

	self SwitchToWeapon( self.copy_weapon_current );
	
	//clean up
	self.copy_fullweaponlist = undefined;
	self.copy_weapon_current = undefined;
	self.copy_weapon_ammo_clip = undefined;
	self.copy_weapon_ammo_stock = undefined;
}

/*
=============
///ScriptDocBegin
"Name: remove_weapons()"
"Summary: Removes each weapon from the player's primary weaponlist"
"Module: Alien"
"Example: player remove_weapons()"
"SPMP: multiplayer"
///ScriptDocEnd
=============
*/
remove_weapons()
{
	weaponlist = self GetWeaponsListPrimaries();
	
	// now take the weapons
	foreach( weapon in weaponlist )
	{
		weaponTokens = StrTok( weapon, "_" );
	
		if( weaponTokens[0] == "alt" )
			continue;
			
		self TakeWeapon( weapon );
	}
}

/*
=============
///ScriptDocBegin
"Name: get_alien_type()"
"Summary: Gets the type of this alien"
"Module: Alien"
"Example: alien get_alien_type()"
"SPMP: multiplayer"
///ScriptDocEnd
=============
*/
get_alien_type()
{
	AssertEx( isDefined ( self.alien_type ), "self.alien_type is not defined" );
	
	return self.alien_type;
}

/*
=============
///ScriptDocBegin
"Name: is_normal_upright( normal )"
"Summary: Determines if passed in normal is facing up"
"Module: Alien"
"Example: is_normal_upright( upVector )"
"SPMP: multiplayer"
///ScriptDocEnd
=============
*/
is_normal_upright( normal )
{
	UPRIGHT_VECTOR = ( 0, 0, 1 );
	UPRIGHT_DOT = 0.85;
	return ( VectorDot( normal, UPRIGHT_VECTOR ) > UPRIGHT_DOT );
}

// TODO JW: Remove!  These notetracks should be in the animations
always_play_pain_sound( anime )
{
	if ( !AnimHasNotetrack( anime, "alien_pain_light" ) && !AnimHasNoteTrack( anime, "alien_pain_heavy" ) )
	{
		self PlaySound( "alien_pain_light" );
	}
	
}

register_pain( anim_entry )
{
	/# AssertEx( !IsDefined( self.pain_registered ) || !self.pain_registered, "Shouldn't be able to register a pain when one already registered!" ); #/
	self.pain_registered = true;
	self thread pain_interval_monitor( anim_entry );
}

pain_interval_monitor( anim_entry )
{
	self endon ("death" );
	
	alienType = self get_alien_type();
	painInterval = level.alien_types[ alienType ].attributes[ "pain_interval" ];
	wait painInterval + GetAnimLength( anim_entry );
	self.pain_registered = false;
}

is_pain_available()
{
	if ( IsDefined( self.pain_registered ) && self.pain_registered )
		return false;
	
	return true;
}

// MP ents clean up

mp_ents_clean_up()
{
	// wait for padding
	wait 0.5;
	
	// "heli_start" script origins removed
	heli_start_nodes 	= getEntArray( "heli_start", "targetname" );
	foreach( start_node in heli_start_nodes )
		get_linked_nodes_and_delete( start_node );
	
	// "heli_loop_start" script origins removed
	heli_loop_nodes 	= getEntArray( "heli_loop_start", "targetname" );
	foreach( loop_node in heli_loop_nodes )
		get_linked_nodes_and_delete( loop_node );
	
	// "heli_crash_start" script origins removed
	heli_crash_nodes 	= getEntArray( "heli_crash_start", "targetname" );
	foreach( crash_node in heli_crash_nodes )
		get_linked_nodes_and_delete( crash_node );

}

// grab all the nodes chained starting from start_node
get_linked_nodes_and_delete( start_node )
{
	cur_node = start_node;
	
	while ( isdefined( cur_node.target ) )
	{
		next_node = getent( cur_node.target, "targetname" );
		if ( isdefined( next_node ) )
		{
			cur_node delete();
			cur_node = next_node;
		}
		else
		{
			break;
		}
	}
	
	if ( isdefined( cur_node ) )
		cur_node delete();
}