#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include vehicle_scripts\_a10_warthog;

setup_planes()
{
	carrier_planes_precache();
	thread mig29_gun_dives();
	thread mig29_missile_dives();
}

carrier_planes_precache()
{
	PreCacheItem( "AGM_65" );
	PreCacheItem( "a10_30mm_player" );
	PreCacheRumble( "ac130_25mm_fire" );
	
	level._effect[ "a10_muzzle_flash" ]							= LoadFX( "fx/muzzleflashes/a10_muzzle_flash");
	level._effect[ "a10_shells" ]								= LoadFX( "fx/shellejects/a10_shell");
	level._effect[ "a10_impact" ]								= LoadFX( "fx/explosions/a10_explosion");
}

mig29_gun_dives()
{
	array_spawn_function_noteworthy( "mig29_gun", ::setup_mig29_waits );
}

mig29_missile_dives()
{
	array_spawn_function_noteworthy( "mig29_missile", ::setup_mig29_waits );
}

setup_mig29_waits()
{
//	self godon();
//	self SetContents( 0 );
	
	if ( IsDefined( self.script_noteworthy ) )
	{
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

random_wait_and_kill( min, max )
{
	self endon( "death" );
	
	wait( RandomFloatRange( min, max ) );
		
	self Kill();
}


mig29_wait_start_firing()
{
	self endon( "death" );
	
	self ent_flag_init( "start_firing" );
	self ent_flag_wait( "start_firing" );
	self ent_flag_clear( "start_firing" );
	
	self thread mig29_fire();
}

mig29_wait_stop_firing()
{
	self endon( "death" );
	
	self ent_flag_init( "stop_firing" );
	self ent_flag_wait( "stop_firing" );
	
	self StopLoopSound( "a10p_gatling_loop" );
	
	self PlaySound( "a10p_gatling_tail" );
	
	self ent_flag_clear( "stop_firing" );
}

mig29_wait_fire_missile()
{
	self endon( "death" );
	
	self ent_flag_init( "fire_missile" );
	self ent_flag_wait( "fire_missile" );
	
	if ( IsDefined( self.script_parameters ) )
	{
		target = getent( self.script_parameters, "targetname" );
		self thread mig29_fire_missiles( target );	
	}
	else
	{	
		self thread mig29_fire_missiles();
	}
	
	self ent_flag_clear( "fire_missile" );
}

mig29_missile_set_target( target )
{
	wait 0.2;
	
	self Missile_SetTargetEnt( target );
	
	if ( IsDefined( target.godmode ) && target.godmode == true )
	{
		target godoff();
	}
}

mig29_fire_missiles( target, monitor_distance )
{	
	self PlaySound( "a10p_missile_launch" );
	forward	   = AnglesToForward( self.angles );
	offset = 1000; //so we don't shoot ourselves in the foot
	maverick_hardpoint = self GetTagOrigin( "tag_origin" ) + forward * offset;
	end_point		   = maverick_hardpoint + AnglesToForward( self GetTagAngles( "tag_origin" ) + ( 0, 0, 30 ) ) * 100;
	maverick		   = MagicBullet( "AGM_65", maverick_hardpoint, end_point );
	maverick.angles	   = self GetTagAngles( "tag_origin" );
	
	missile_owner = self;
	
	if ( IsDefined( target ) )
	{
		maverick thread mig29_missile_set_target( target );
		
		if( IsDefined( monitor_distance ) )
			maverick thread monitor_missile_distance( 260000, target, missile_owner );
	}
}

monitor_missile_distance( distance_to_explode, target, missile_owner )
{
	while( IsDefined( self ) && ( DistanceSquared( self.origin, target.origin ) > distance_to_explode ) )
	{
		wait( 0.05 );
	}
	
	PlayFXOnTag( level._effect[ "vehicle_explosion_slamraam_no_missiles" ], target, "tag_origin" );
	
	if( IsDefined( self ) )
		self Delete();
	
	wait( 0.1 );
	
	if( IsDefined( missile_owner.kill_target ) && missile_owner.kill_target == true )
	{
		PlayFXOnTag( level._effect[ "aerial_explosion_mig29" ], target, "tag_origin" );
		wait( 0.1 );
		PlayFXOnTag( level._effect[ "jet_crash_dcemp" ], target, "tag_origin" );

		target godoff();
		target Kill();
		
		wait( 0.25 );
		
		if( IsDefined( target ) )
			target Delete();
	}
	
	else
	{
		PlayFXOnTag( level._effect[ "airplane_damage_blacksmoke_fire" ], target, "tag_engine_right" );
		
		wait( 0.1 );
		
		StopFXOnTag( level._effect[ "vehicle_explosion_slamraam_no_missiles" ], target, "tag_origin" );
	}
}

mig29_fire()
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	self.firing_sound_ent = Spawn( "script_origin", ( 0, 0, 0 ) );
	
	while ( 1 )
	{		
		forward	   = AnglesToForward( self.angles );
		
		gun_offset = 1000; //so we don't shoot ourselves in the foot
		gun_origin = self GetTagOrigin( "tag_flash" ) + forward * gun_offset;
		end_point  = gun_origin + forward * 999999999;
		MagicBullet( "a10_30mm_player", gun_origin + forward, end_point );

		PlayFXOnTag( level._effect[ "a10_muzzle_flash" ], self, "tag_flash" );

		Earthquake( 0.2, 0.05, self.origin, 1000 );
		self PlayLoopSound( "a10p_gatling_loop" );
		
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

mig29_monitor_projectile_death()
{
	self endon( "deleted" );
	
	while ( 1 )
	{
		self waittill( "damage", amount, attacker, dir_vec, point, type );
		
		if ( type != "MOD_PROJECTILE" )
		{
			continue;
		}
		
		fx = getfx( "FX_mig29_on_fire" );
		PlayFXOnTag( fx, self, "tag_origin" );
		wait RandomFloatRange( 0.33, .75 );
		
		if ( !IsDefined( self ) )
		{
			return;	
		}
		
		fx = getfx( "FX_mig29_air_explosion" );
		pos = self.origin;
		fwd = AnglesToForward( self.angles );
		PlayFX( fx, pos, fwd );
		self stop_loop_sound_on_entity( "veh_f15_dist_loop" );
		self Delete();
		self notify( "death" );
	}
}

//plane_monitor_end_path()
//{
//	self endon( "death" );
//	self waittill( "reached_dynamic_path_end" );
//	
//}