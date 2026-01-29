#include maps\mp\agents\_agent_utility;
#include common_scripts\utility;

/#
//===========================================
// 			debugDvars()
//===========================================
debugDvars()
{
	SetDvarIfUninitialized( "debug_nuke", "off" );
	
	while ( true )
	{
		if ( GetDvar( "debug_nuke" ) != "off" )
		{
			thread debug_nuke();
		}
		
		wait 0.05;
	}	
}

//===========================================
// 			debugNuke()
//===========================================
debug_nuke()
{
	dvar = GetDvar( "debug_nuke" );
	
	if ( dvar == "on" )
	{
		aliens = getAgentsOfType( "alien" );
		
		// give first player money!
		if ( aliens.size )
		{
			level.players[ 0 ] maps\mp\alien\_collectibles::give_loot( "loot_blood_small", aliens.size * 100 );
		}
		
		foreach ( alien in aliens )
			alien suicide();
	}
	
	SetDvar( "debug_nuke", "off" );
}


alienDebugVelocity()
{
	self endon( "death" );
	self.average_velocity = [];
	self.max_vel = 0;
	while ( 1 )
	{
		average_vel = get_average_velocity();
		if ( average_vel > self.max_vel )
		{
			self.max_vel = average_vel;
		}
		
		text = "Vel: " + average_vel;
		print3d( self.origin + ( 0, 0, 64 ), text, (.9, .5, .3), 1.5, 1.0 );		
		text = "Max Vel: " + self.max_vel;
		print3d( self.origin + ( 0, 0, 32 ), text, (.9, .5, .3), 1.5, 1.0 );		
		wait 0.05;
	}
}

get_average_velocity()
{
	cur_vel = Length( self GetVelocity() );
	if ( self.average_velocity.size < 10 )
	{
		self.average_velocity[ self.average_velocity.size ] = cur_vel;
	}
	else
	{
		for ( i = self.average_velocity.size - 1; i>=0; i-- )
		{
			self.average_velocity[i+1] = self.average_velocity[i];
		}
		self.average_velocity[0] = cur_vel;
	}
	
	total_vel = 0;
	foreach ( vel in self.average_velocity )
	{
		total_vel += vel;	
	}
	
	return total_vel / self.average_velocity.size;
}

//===========================================
// 			alienNavTest()
//===========================================
alienNavTest()
{
	while ( !isDefined( level.players ) || level.players.size == 0 )
	{
		wait 0.05;
	}
	level.players[0] thread alienNavTest_watchBullets();
	level.testalien = undefined;
	while ( 1 )
	{
		dvar = GetDvarInt( "scr_aliennavtest" );
		while ( dvar == 0 )
		{
			wait 0.05;
			dvar = GetDvarInt( "scr_aliennavtest" );
		}
		
		while ( !isAlive( level.testAlien ) )
		{
			level.testAlien = maps\mp\gametypes\aliens::addAlienAgent( "axis", level.players[0].origin, level.players[0].angles );
		}
		
		if ( isAlive( level.testAlien ) )
		{
			alien = level.testalien;
			alien maps\mp\alien\_utility::enable_alien_scripted();
			if ( !isDefined( level.goalposition ) )
			{
				while ( !isDefined( level.goalposition ) )
				{
					wait 0.05;
				}
			}
			else
			{
				alien ScrAgentSetGoalPos( level.goalposition );
				alien ScrAgentSetGoalRadius( 64 );
				alien common_scripts\utility::waittill_any( "goal_reached", "death" );
			}
		}
		wait 0.05;
	}	
}


alienNavTest_watchBullets()
{
	while ( 1 )
	{
		self waittill( "weapon_fired" );
		eye = self GetEye();
		player_angles = self GetPlayerAngles();
		aim_dir = AnglesToForward( player_angles );
		aim_dir *= 1000;
		trace = BulletTrace( eye, eye + aim_dir, false, self, false );
		//line( eye, eye + aim_dir, ( 0,1,0 ), 1, 0, 20 );
		level.goalposition = trace[ "position" ] + (0,0,6);
		self thread alienNavTest_showGoal( level.goalposition );
		if ( isAlive( level.testAlien ) )
		{
			level.testAlien ScrAgentSetGoalPos( level.goalposition );
		}
	}
}

alienNavTest_showGoal( pos )
{
	self notify( "stop_show_goal" );
	self endon( "stop_show_goal" );
	while ( 1 )
	{
		line( pos, pos + (0,0,64), (0,1,0), 1, 0, 2 );
		wait 0.05;
	}
}

//===========================================
// 			runStartPoint()
//===========================================
NUM_LOC_PER_START_POINT = 4;
runStartPoint()
{
	if( !startPointEnabled() )
		return;
	
	startPoint = getDvar( "alien_start_point" );
	if( !isValidStartPoint( startPoint ) )
	{
		AssertMsg( startPoint + " is not a valid start point." );
		return;
	}
	
	grabStartPointLocations( startPoint );
	level thread startPointWatchPlayerSpawn( startPoint );
	//level thread triggerBombDefendSequence();
}

//===========================================
// 			startPointEnabled()
//===========================================
startPointEnabled()
{
	if( getDvar( "alien_start_point" ) == "" )
		return false;
	return true;
}

//===========================================
// 			isValidStartPoint()
//===========================================
isValidStartPoint( startPointName )
{
	foreach( index, value in level.startPoints )
	{
		if( startPointName == value )
			return true;
	}
	return false;
}


//===========================================
// 			grabStartPointLocations()
//===========================================
grabStartPointLocations( startPointName )
{
	level.startPointLocations = [];
	
	for( i = 0; i < NUM_LOC_PER_START_POINT; i++ )
	{
		kvp = "start_point_" + startPointName + "_" + i;
		location = getStruct( kvp, "targetname" );
		level.startPointLocations[ level.startPointLocations.size ] = location;
	}
}

//===========================================
// 			startPointWatchPlayerSpawn()
//===========================================
startPointWatchPlayerSpawn( startPoint )
{
	level endon( "game_ended" );

	StartPointCounter = 0;
	
	while( true )
	{
		level waittill( "player_spawned", player );
		player thread moveToStartPoint( startPoint, StartPointCounter );
		StartPointCounter++;
	}
}

//===========================================
// 			triggerBombDefendSequence()
//===========================================
triggerBombDefendSequence()
{
	level endon( "game_ended" );
	
	wait( level.alien_pregame_delay );

	fakeBombCarrier = level.player;

	level.bomb_carrier = fakeBombCarrier;
	level.bomb_carrier maps\mp\alien\_airdrop::set_drill_icon( true );
	level notify( "drill_pickedup", fakeBombCarrier );
	fakeBombCarrier thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "sentry" );
	waitframe();
	
	hiveLoc = getClosestHiveLoc();
	hiveLoc notify( "trigger", fakeBombCarrier );
}

//===========================================
// 			getClosestHiveLoc()
//===========================================
getClosestHiveLoc()
{
	playerLoc = level.player.origin;  //Use host player's location for now
	
	closesthHiveLoc = undefined;
	closestDist = 999999999;
	
	foreach( hive in level.stronghold_hive_locs )
	{
		hiveDist = distanceSquared( hive.origin, playerLoc );
		if( hiveDist < closestDist )
		{
			closesthHiveLoc = hive;
			closestDist = hiveDist;
		}
	}
	return closesthHiveLoc;
}

//===========================================
// 			moveToStartPoint()
//===========================================
moveToStartPoint( startPoint, index )
{
	locationIndex = index % NUM_LOC_PER_START_POINT;
	startPointLoc = level.startPointLocations[ locationIndex ];
	self setOrigin( startPointLoc.origin );
	self setPlayerAngles( startPointLoc.angles );
}

//===========================================
// 			add_start()
//===========================================
add_start( startPointName )
{
	checkExistInLevel( startPointName );
		
	if ( !isDefined( level.startPoints ) )
		level.startPoints = [];
	
	level.startPoints[ level.startPoints.size ] = startPointName;
}

//===========================================
// 			checkExistInLevel()
//===========================================
checkExistInLevel( startPointName )
{
	for( i = 0; i < NUM_LOC_PER_START_POINT; i++ )
	{
		kvp = "start_point_" + startPointName + "_" + i;
		pos = getStruct( kvp, "targetname" );
		
		if( !isDefined( pos ) )
			AssertMsg( "Unable to get the entity with the following KVP: " + kvp + ", targetname" );
	}
}

//===========================================
// 			debug_collectible()
//===========================================
debug_collectible( item )
{
	string 			= maps\mp\alien\_collectibles::get_item_name( item.item_ref );
	string			= "[LOOT] " + GetSubStr( string, 6 );
	color 			= ( 1, 1, 0.25 );
	alpha 			= 1;
	scale 			= 3;
	ent_endon_msg 	= "death";
	ent				= item.item_ent;

	thread debug_print3d( string, color, alpha, scale, ent, ent_endon_msg );
}

//===========================================
// 			debug_print3d()
//===========================================
debug_print3d( string, color, alpha, scale, ent, endon_msg )
{
	ent endon( endon_msg );
	level endon ( "game_ended" );

	while ( 1 )
	{
		Print3d( ent.origin, string, color, alpha, scale, 1 );
		wait( 0.05 );
	}
}


//===========================================
// 			debugTrackDamage()
//===========================================
DPS_MS_TO_TRACK = 10000;

debugTrackDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( !GetDvarInt( "scr_debugdps", 0 ) )
	{
		return;
	}
	
	if ( isPlayer( eAttacker ) && eAttacker GetCurrentPrimaryWeapon() == sWeapon )
	{
		iprintlnBold( "Damage: " + iDamage );
		// Add to DPS
		if ( !isDefined( eAttacker.dps ) )
		{
			eAttacker init_debug_dps();
		}
		
		new_dps_struct = SpawnStruct();
		new_dps_struct.damage = iDamage;
		new_dps_struct.time = gettime();
		
		dps_array = [];
		foreach( dps_struct in eAttacker.dps_array )
		{
			if ( dps_struct.time + DPS_MS_TO_TRACK < new_dps_struct.time )
			{
				continue;
			}
			dps_array[ dps_array.size ] = dps_struct;
		}
		dps_array[ dps_array.size ] = new_dps_struct;
		
		eAttacker.dps_array = dps_array;
	}
}

calc_dps()
{
	total_damage = 0;
	current_time = gettime();
	foreach( dps_struct in self.dps_array )
	{
		if ( dps_struct.time + DPS_MS_TO_TRACK < current_time )
		{
			continue;
		}
		total_damage += dps_struct.damage;
	}

	currently_tracked_ms = min( current_time - self.first_dps_time, DPS_MS_TO_TRACK );
	dps_seconds_to_track = currently_tracked_ms / 1000;
	
	if ( dps_seconds_to_track > 0 )
	{
		self.dps = total_damage / dps_seconds_to_track;
	}
	else
	{
		self.dps = 0;
	}
}

init_debug_dps()
{
	self.dps_array = [];
	self.dps = 0;
	self.first_dps_time = gettime();
	
	create_dps_hud();
	self thread update_dps();
}

update_dps()
{
	while ( 1 )
	{
		if ( !GetDvarInt( "scr_debugdps", 0 ) )
		{
			return;
		}
		
		self calc_dps();
		self.dps_hud setValue( self.dps );
		self.dps_hud.alpha = 1;
		wait 0.2;		
	}
}

create_dps_hud()
{
	hud_counter = self maps\mp\gametypes\_hud_util::createFontString( "objective", 1.25 );
	hud_counter maps\mp\gametypes\_hud_util::setPoint( "LEFT", "TOP", 180, 44 );
	hud_counter.alpha = 0;
	hud_counter.color = (1,1,1);
	hud_counter.glowAlpha = 1;
	hud_counter.sort = 1;
	hud_counter.hideWhenInMenu = true;
	hud_counter.archived = true;
	
	self.dps_hud = hud_counter;
}

debug_progression_upgrade( notify_message, button_assignment )
{
	self thread send_fake_lui_notify( notify_message );
	self NotifyOnPlayerCommand( notify_message, button_assignment );
}

send_fake_lui_notify( notify_message )
{
	while ( true )
	{
		self waittill ( notify_message );
		self notify ( "luinotifyserver", notify_message );
	}
}

#/