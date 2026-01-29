#include common_scripts\utility;
#include maps\mp\_utility;

waterShallowFx()
{
	level._effect[ "water_bubbles"		 ] = LoadFX( "fx/water/bubble_trail01" );
	level._effect[ "water_wake"			 ] = LoadFX( "fx/water/player_water_wake" );
	level._effect[ "water_splash_emerge" ] = LoadFX( "fx/water/zodiac_splash_bounce_small" );
	level._effect[ "water_splash_enter"	 ] = LoadFX( "fx/water/body_splash" );
}

waterShallowInit()
{
	trigUnderWater = GetEnt( "trigger_underwater", "targetname" );
	trigAboveWater = GetEnt( "trigger_abovewater", "targetname" );
	trigUnderWater thread watchPlayerEnterWater( trigAboveWater );
	level thread clearWaterVarsOnSpawn( trigUnderWater );	
}

clearWaterVarsOnSpawn( underWater )
{
	level endon ( "game_ended" );

	while ( true )
	{
		level waittill( "player_spawned", player );

		if ( !player IsTouching( underWater ) )
		{
			player.inWater	  = undefined;
			player.underWater = undefined;
			player notify( "out_of_water" );
		}
	}
}

watchPlayerEnterWater( aboveWater )
{
	level endon( "game_ended" );

	while ( true )
	{
		self waittill( "trigger", ent );

		if ( !IsAlive( ent ) )
			continue;

		if ( !IsDefined( ent.inWater ) )
		{
			ent.inWater = true;
			ent thread playerInWater( self, aboveWater );
		}
	}
}

playerInWater( underWater, aboveWater )
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	
	self thread inWaterWake();
	self thread playerWaterClearWait();
	self notify( "force_cancel_placement" );
	
	while ( true )
	{
		if ( !self IsTouching( underWater ) )
		{
			self.inWater	= undefined;
			self.underWater = undefined;
			self notify( "out_of_water" );
			break;
		}
		
		if ( !IsDefined( self.underWater ) && !self IsTouching( aboveWater ) )
		{
			// if we do want remotes to function in water, we'll need to filter by type
			if( self.classname == "script_vehicle" )
			{
				self notify( "death" );
			}
			else
			{
				self.underWater = true;
				self thread clearSelectingLocationOnRemoteDeathSpawn();
				self thread playerUnderWater();
			}
		}
			
		if ( IsDefined( self.underWater ) && self IsTouching( aboveWater ) )
		{
			self.underWater = undefined;	
			self notify( "above_water" );
			stopWaterVisuals();
			self PlayLocalSound( "breathing_better" );
			PlayFX( level._effect[ "water_splash_emerge" ], self.origin * ( 1, 1, 0 ) + ( 0, 0, 2213 ) );
		}
		
	 	if ( IsDefined( self.underWater ) || IsActiveKillstreakPoolRestricted( self ) )
			self.selectingLocation = true;	// disable killstreak activation
		else if ( !IsDefined( self.underWater ) )
			self.selectingLocation = undefined;	// re-enable killstreak activation

		wait ( 0.05 );
	}
}

IsActiveKillstreakPoolRestricted( player )
{
	if ( IsDefined( player.killstreakIndexWeapon ) )
	{
		streakName = self.pers[ "killstreaks" ][ self.killstreakIndexWeapon ].streakName;
		if ( IsDefined( streakName ) )
		{
			switch ( streakName )
			{
				case "remote_uav":
				case "remote_mg_turret":
				case "minigun_turret":
				case "ims":
				case "sentry":
				case "remote_tank":
				case "sam_turret":
					return true;	
			}
		}
	}
	
	return false;
}

playerWaterClearWait()
{
	self waittill_any( "death", "disconnect", "out_of_water" );
	self.inWater		   = undefined;
	self.underWater		   = undefined;
	self.selectingLocation = undefined; //re-enable killstreak activation
}

inWaterWake()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "out_of_water" );
	
	PlayFX( level._effect[ "water_splash_enter" ], self.origin );
	
	while ( true )
	{
		PlayFX( level._effect[ "water_wake" ], self.origin * ( 1, 1, 0 ) + ( 0, 0, 2213 ) );
		wait( 0.75 );		
	}	
}


playerUnderWater()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "stopped_using_remote" );
	self endon( "disconnect" );
	self endon( "above_water" );
	
	if ( !self maps\mp\_utility::isUsingRemote() )
	{
		startWaterVisuals();
		self thread underWaterBubbles();
		//	players can glitch into a remote after going underwater
		self thread stopWaterVisualsOnRemote();
	}	
		
	wait( 2 );	
	self thread onPlayerDrowned();	
	
	while ( true )
	{
		RadiusDamage( self.origin + AnglesToForward( self.angles ) * 5, 16, 20, 20, undefined, "MOD_TRIGGER_HURT" );
		wait( 1 );		
	}	
}

onPlayerDrowned()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "above_water" );
	
	self waittill( "death" );
	
	self.inWater	= undefined;
	self.underWater = undefined;
}

underWaterBubbles()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "using_remote" );
	self endon( "stopped_using_remote" );
	self endon( "disconnect" );
	self endon( "above_water" );
	
	while ( true )
	{
		PlayFX( level._effect[ "water_bubbles" ], self GetEye() + ( AnglesToUp( self.angles ) * -13 ) + ( AnglesToForward( self.angles ) * 25 ) );
		wait( 0.75 );		
	}	
}

startWaterVisuals()
{
	self ShellShock( "default", 8 );
	if ( IsPlayer( self ) )
		self SetBlurForPlayer( 10, 0.0 );
}

stopWaterVisuals()
{
	self StopShellShock();
	if ( IsPlayer( self ) )
		self SetBlurForPlayer( 0, 0.85 );
}

stopWaterVisualsOnRemote()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "stopped_using_remote" );
	self endon( "disconnect" );
	self endon( "above_water" );
	
	self waittill( "using_remote" );
	self stopWaterVisuals();
}

clearSelectingLocationOnRemoteDeathSpawn()
{
	level endon( "game_ended" );
	self endon( "disconnect" );	
	self endon( "above_water" );
	
	self waittill( "spawned_player" );
	self.selectingLocation = undefined;
}