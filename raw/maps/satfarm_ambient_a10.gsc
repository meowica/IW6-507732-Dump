#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include vehicle_scripts\_a10_warthog;

a10_precache()
{
	PreCacheItem( "AGM_65_satfarm" );
	PreCacheItem( "a10_30mm_player_satfarm" );
	PreCacheRumble( "ac130_25mm_fire" );
	
	level._effect[ "a10_muzzle_flash" ]							= LoadFX( "fx/muzzleflashes/a10_muzzle_flash");
	level._effect[ "a10_shells" ]								= LoadFX( "fx/shellejects/a10_shell");
	level._effect[ "a10_impact" ]								= LoadFX( "fx/explosions/a10_explosion");
}

a10_spawn_funcs()
{
	thread a10_gun_dives();
	thread mig29_gun_dives();
	thread a10_missile_dives();
	thread mig29_missile_dives();
}

a10_gun_dives()
{
	array_spawn_function_noteworthy( "a10_gun", ::setup_a10_waits );
}

mig29_gun_dives()
{
	//array_spawn_function_noteworthy( "mig29_gun", ::setup_mig29_waits ); //commented out, none exist
}

a10_missile_dives()
{
	array_spawn_function_noteworthy( "a10_missile", ::setup_a10_waits );
}

mig29_missile_dives()
{
	array_spawn_function_noteworthy( "mig29_missile", ::setup_mig29_waits );
}

//the script_ent_flags need to be set up on the a10's nodes where you want those things to happen
//script_flag_start_firing
//script_flag_stop_firing
//script_flag_start_afterburner
setup_a10_waits()
{
	self godon();
	self SetContents( 0 );
	
	if ( IsDefined( self.script_noteworthy ) )
	{
		self thread wait_kill_me();
		
		if ( self.script_noteworthy == "a10_gun" )
		{
			self thread a10_wait_start_firing();
			self thread a10_wait_stop_firing();
		}
		
		else if ( self.script_noteworthy == "a10_missile" )
		{
			self thread a10_wait_fire_missile();
		}
	}
}

setup_mig29_waits()
{
	self godon();
	self SetContents( 0 );
	
	if ( IsDefined( self.script_noteworthy ) )
	{
		self thread wait_kill_me();
		
		if ( self.script_noteworthy == "mig29_gun" )
		{
			self thread mig29_wait_start_firing();
			self thread mig29_wait_stop_firing();
		}
		
		else if ( self.script_noteworthy == "mig29_missile" )
		{
			self thread mig29_wait_fire_missile();
		}
	}
}

a10_wait_start_firing()
{
	self endon( "death" );
	
	self ent_flag_init( "start_firing" );
	self ent_flag_wait( "start_firing" );
	self ent_flag_clear( "start_firing" );
	
	self thread a10_30mm_fire();
	
	if( IsDefined( self.script_parameters ) )
	{
		switch( self.script_parameters )
		{
			case "bridge_enemy_a10_gun_dive_2":
			{
				foreach( enemytank in level.enemytanks )
				{
					if( IsDefined( enemytank.script_noteworthy ) && isalive( enemytank ) && ( ( enemytank.script_noteworthy == "bridge_enemy_tank" ) ) )
					{
						enemytank thread maps\satfarm_code::random_wait_and_kill( 1.0, 2.0 );
					}
				}
			}
		}
	}
}

mig29_wait_start_firing()
{
	self endon( "death" );
	
	self ent_flag_init( "start_firing" );
	self ent_flag_wait( "start_firing" );
	self ent_flag_clear( "start_firing" );
	
	self thread mig29_fire();
}

a10_wait_stop_firing()
{
	self endon( "death" );
	
	self ent_flag_init( "stop_firing" );
	self ent_flag_wait( "stop_firing" );
	
	self StopLoopSound( "satf_gatling_loop" );
	
	self PlaySound( "satf_gatling_tail" );
	
	self ent_flag_clear( "stop_firing" );
}

mig29_wait_stop_firing()
{
	self endon( "death" );
	
	self ent_flag_init( "stop_firing" );
	self ent_flag_wait( "stop_firing" );
	
	self StopLoopSound( "satf_gatling_loop" );
	
	self PlaySound( "satf_gatling_tail" );
	
	self ent_flag_clear( "stop_firing" );
}

a10_wait_fire_missile()
{
	self endon( "death" );
	
	self ent_flag_init( "fire_missile" );
	self ent_flag_wait( "fire_missile" );
	
	if( IsDefined( self.script_parameters ) )
	{
		if( self.script_parameters == "sat_array_a10_missile_dive_1" )
		{
				foreach( enemytank in level.enemytanks )
				{
					if( IsDefined( enemytank.script_noteworthy ) && !enemytank maps\_vehicle_code::is_corpse() && ( ( enemytank.script_noteworthy == "sat_array_enemy_01" ) ) )
					{
						self thread a10_fire_missiles( enemytank );
						
						wait( 0.2 );
					}
				}
		}
		
		else if( self.script_parameters == "crash_site_a10_missile_dive_1" )		
		{
			foreach( enemytank in level.crash_site_background_enemies )
			{
				if( IsDefined( enemytank.script_noteworthy ) && !enemytank maps\_vehicle_code::is_corpse() && ( ( enemytank.script_noteworthy == "crash_site_background_enemy_01" ) || ( enemytank.script_noteworthy == "crash_site_background_enemy_02" ) ) )
				{
					self thread a10_fire_missiles( enemytank );
					
					wait( 0.2 );
				}
			}
		}
	}
	
	else
	{
		self thread a10_fire_missiles();
	}
	
	self ent_flag_clear( "fire_missile" );
}

mig29_wait_fire_missile()
{
	self endon( "death" );
	
	self ent_flag_init( "fire_missile" );
	self ent_flag_wait( "fire_missile" );
	
	if( IsDefined( self.script_parameters ) )
	{
		if( self.script_parameters == "crash_site_mig29_gun_dive_1" )
		{
			foreach( allytank in level.allytanks )
			{
				if( IsDefined( allytank.script_noteworthy ) && !allytank maps\_vehicle_code::is_corpse() && ( allytank.script_noteworthy == "intro_ally0" || allytank.script_noteworthy == "crash_site_ally0" || allytank.script_noteworthy == "intro_ally0" || allytank.script_noteworthy == "crash_site_ally0" ) )
				{
					self thread mig29_fire_missiles( allytank );
					
					wait( 0.2 );
				}
			}
		}
				
		else if( self.script_parameters == "air_strip_mig29_missile_entrance" )
		{
			if( IsDefined( level.air_strip_a10_gun_dive_entrance ) && !level.air_strip_a10_gun_dive_entrance maps\_vehicle_code::is_corpse() )
			{
				self thread mig29_fire_missiles( level.air_strip_a10_gun_dive_entrance, true );
			}
		}
			
		else if( self.script_parameters == "crash_site_mig29_gun_dive_2" )
		{
			if( IsDefined( level.crash_site_a10_missile_dive_1 ) && !level.crash_site_a10_missile_dive_1 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.crash_site_a10_missile_dive_1, true );
			}
		}
				
		else if( self.script_parameters == "crash_site_mig29_gun_dive_3" )
		{
			if( IsDefined( level.crash_site_a10_gun_dive_1 ) && !level.crash_site_a10_gun_dive_1 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.crash_site_a10_gun_dive_1, true );
			}
		}
			
		else if( self.script_parameters ==  "intro_mig29_missile_c17_01" )
		{
			if( IsDefined( level.crashedc17_missile_org ) )
			{
				self thread mig29_fire_missiles( level.crashedc17_missile_org, true );
			}
		}

		else if( self.script_parameters ==  "intro_mig29_missile_c17_02" )
		{
			foreach( allytank in level.intro_allies_killed_by_mig )
			{
					self thread mig29_fire_missiles( allytank );
					
					wait( 0.2 );
			}
		}
		else if( self.script_parameters == "air_strip_ambient_mig29_missile_dive_1" )
		{
			if( IsDefined( level.air_strip_ambient_a10_gun_dive_1 ) && !level.air_strip_ambient_a10_gun_dive_1 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.air_strip_ambient_a10_gun_dive_1, true );
			}
		}
		else if( self.script_parameters == "air_strip_ambient_mig29_missile_dive_2" )
		{
			if( IsDefined( level.air_strip_ambient_a10_gun_dive_2 ) && !level.air_strip_ambient_a10_gun_dive_2 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.air_strip_ambient_a10_gun_dive_2, true );
			}
		}
		else if( self.script_parameters == "air_strip_ambient_mig29_missile_dive_3" )
		{
			if( IsDefined( level.air_strip_ambient_a10_gun_dive_3 ) && !level.air_strip_ambient_a10_gun_dive_3 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.air_strip_ambient_a10_gun_dive_3, true );
			}
		}
		else if( self.script_parameters == "base_array_ambient_mig29_missile_dive_1" )
		{
			if( IsDefined( level.base_array_ambient_a10_gun_dive_1 ) && !level.base_array_ambient_a10_gun_dive_1 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.base_array_ambient_a10_gun_dive_1, true );
			}
		}
		else if( self.script_parameters == "base_array_ambient_mig29_missile_dive_2" )
		{
			if( IsDefined( level.base_array_ambient_a10_gun_dive_2 ) && !level.base_array_ambient_a10_gun_dive_2 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.base_array_ambient_a10_gun_dive_2, true );
			}
		}
		else if( self.script_parameters == "base_array_ambient_mig29_missile_dive_3" )
		{
			if( IsDefined( level.base_array_ambient_a10_gun_dive_3 ) && !level.base_array_ambient_a10_gun_dive_3 maps\_vehicle_code::is_corpse() )
			{
				self.kill_target = true;
				self thread mig29_fire_missiles( level.base_array_ambient_a10_gun_dive_3, true );
			}
		}			
	}
	
	else
	{
		self thread mig29_fire_missiles();
	}
	
	self ent_flag_clear( "fire_missile" );
}

a10_missile_set_target( target )
{
	target endon( "death" );
	
	wait 0.2;
	
	self Missile_SetTargetEnt( target );
	
	if ( IsDefined( target.godmode ) && target.godmode == true )
	{
		target godoff();
	}
}

mig29_missile_set_target( target )
{
	target endon( "death" );
	
	wait 0.2;
	
	self Missile_SetTargetEnt( target );
	
	if ( IsDefined( target.godmode ) && target.godmode == true )
	{
		target godoff();
	}
}

a10_fire_missiles( target )
{
	target endon( "death" );
	
	self PlaySound( "satf_missile_launch" );
	maverick_hardpoint = self GetTagOrigin( "tag_origin" );
	end_point		   = maverick_hardpoint + AnglesToForward( self GetTagAngles( "tag_origin" ) + ( 0, 0, 30 ) ) * 100;
	maverick		   = MagicBullet( "AGM_65_satfarm", maverick_hardpoint, end_point );
	maverick.angles	   = self GetTagAngles( "tag_origin" );
	
	if ( IsDefined( target ) )
	{
		maverick thread a10_missile_set_target( target );
	}
}

mig29_fire_missiles( target, monitor_distance )
{
	target endon( "death" );

	self PlaySound( "satf_missile_launch" );
	maverick_hardpoint = self GetTagOrigin( "tag_origin" );
	end_point		   = maverick_hardpoint + AnglesToForward( self GetTagAngles( "tag_origin" ) + ( 0, 0, 30 ) ) * 100;
	maverick		   = MagicBullet( "AGM_65_satfarm", maverick_hardpoint, end_point );
	maverick.angles	   = self GetTagAngles( "tag_origin" );
	
	missile_owner = self;
	
	if ( IsDefined( target ) )
	{
		maverick thread mig29_missile_set_target( target );
		
		if( IsDefined( monitor_distance ) )
		{
			maverick thread monitor_missile_distance( 14400, target, missile_owner );
		}
	}
}

monitor_missile_distance( distance_to_explode, target, missile_owner )
{
	target endon( "death" );
	
	while( IsDefined( self ) && IsDefined( target ) && DistanceSquared( self.origin, target.origin ) > distance_to_explode )
	{
		wait( 0.05 );
	}
	
	if( !IsDefined( target ) )
		return;
	
	PlayFXOnTag( level._effect[ "vehicle_explosion_slamraam_no_missiles" ], target, "tag_origin" );
	
	if( IsDefined( self ) )
		self Delete();
	
	wait( 0.1 );
	
	if( IsDefined( missile_owner.kill_target ) && missile_owner.kill_target == true )
	{
		PlayFXOnTag( level._effect[ "aerial_explosion_mig29" ], target, "tag_origin" );
		wait( 0.1 );
		PlayFXOnTag( level._effect[ "jet_crash_dcemp" ], target, "tag_origin" );

		if( !IsDefined( target ) )
		return;
			
		target PlaySound( "satf_agm65_impact" );
		
		if( target isVehicle() )
		{
			target godoff();
			
			target Kill();
		}
		
		wait( 0.25 );
		
		if( IsDefined( target ) )
			target Delete();
	}
	
	else
	{
		if( !IsDefined( target ) )
			return;
			
		if( IsDefined( level.crashedc17_missile_org ) && target == level.crashedc17_missile_org )
		{
			PlayFXOnTag( level._effect[ "airplane_damage_blacksmoke_fire" ], target, "tag_origin" );
		}
		else
		{
			PlayFXOnTag( level._effect[ "airplane_damage_blacksmoke_fire" ], target, "tag_engine_right" );
			
			wait( 0.1 );
			
			StopFXOnTag( level._effect[ "vehicle_explosion_slamraam_no_missiles" ], target, "tag_origin" );
		}
	}
}

a10_30mm_fire()
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	if ( IsDefined( self.script_parameters ) && self.script_parameters == "no_magic_bullet" )
		self.no_magic_bullet = true;
	
	self PlayLoopSound( "satf_gatling_loop" );
	
	while ( 1 )
	{		
		forward	= AnglesToForward( self.angles );
		
		gun_origin = self GetTagOrigin( "tag_gun" );
		end_point  = gun_origin + forward * 999999999;
		
		if ( !IsDefined( self.no_magic_bullet ) )
			MagicBullet( "a10_30mm_player_satfarm", gun_origin + forward, end_point );

		PlayFXOnTag( level._effect[ "a10_muzzle_flash" ], self, "tag_gun" );

		Earthquake( 0.2, 0.05, self.origin, 1000 );
		
		wait( 0.1 );
	}
}

mig29_fire()
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	self PlayLoopSound( "satf_gatling_loop" );
	
	if ( IsDefined( self.script_parameters ) && self.script_parameters == "no_magic_bullet" )
		self.no_magic_bullet = true;
	
	while ( 1 )
	{		
		forward	= AnglesToForward( self.angles );
		
		gun_origin = self GetTagOrigin( "tag_flash" );
		end_point  = gun_origin + forward * 999999999;
		
		if ( !IsDefined( self.no_magic_bullet ) )
			MagicBullet( "a10_30mm_player_satfarm", gun_origin + forward, end_point );

		PlayFXOnTag( level._effect[ "a10_muzzle_flash" ], self, "tag_flash" );

		Earthquake( 0.2, 0.05, self.origin, 1000 );
		
		wait( 0.1 );
	}
}

mig29_afterburners_node_wait()
{
	self endon( "death" );
	
	self ent_flag_init( "start_afterburners" );

	self ent_flag_wait( "start_afterburners" );
	
	self PlaySound( "veh_mig29_sonic_boom" );
	self thread vehicle_scripts\_mig29::playAfterBurner();
}

wait_kill_me()
{
	ent_flag_init( "kill_me" );
	ent_flag_wait( "kill_me" );
	
	if( !IsDefined( self ) )
		return;
	
	PlayFXOnTag( level._effect[ "aerial_explosion_mig29" ], self, "tag_origin" );
	
	wait( 0.1 );
	
	if( !IsDefined( self ) )
		return;
	
	PlayFXOnTag( level._effect[ "jet_crash_dcemp" ], self, "tag_origin" );

	if( !IsDefined( self ) )
		return;
		
	self PlaySound( "satf_agm65_impact" );
	
	if( self isVehicle() )
	{
		self godoff();
		
		self Kill();
	}
	
	wait( 0.25 );
	
	if( IsDefined( self ) )
		self Delete();
}