#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;

init_player_swim()
{
	PreCacheShellShock( "underwater_swim" );
	PreCacheModel( "shpg_viewmodel_scuba_mask" );
	
	PrecacheItem( "aps_underwater" );
	
	level._effect[ "swim_flashlight_plr" ]			= LoadFX( "vfx/moments/ship_graveyard/vfx_flashlight_underwater" );
	level._effect[ "swim_flashlight_particles" ]	= LoadFX( "vfx/moments/ship_graveyard/ocean_particulate_player_light" );
}

#using_animtree( "generic_human" );
init_player_swim_anims()
{
	// anims
	player_swim_anims();
	level.scr_anim[ "generic" ][ "scuba_swimfwd" ][0] = %ny_harbor_wetsub_npc_swim_fwd;
	
	level.scr_anim[ "playerlegs" ][ "scuba_swimfwd" ][0] = %ny_harbor_wetsub_npc_swim_fwd;
	level.scr_anim[ "playerlegs" ][ "scuba_swimlt" ][0] = %ny_harbor_wetsub_npc_swim_lt;
	level.scr_anim[ "playerlegs" ][ "scuba_swimrt" ][0] = %ny_harbor_wetsub_npc_swim_rt;
	level.scr_animtree[ "playerlegs" ] 	= #animtree;
	level.scr_model[ "playerlegs" ] 	= "body_seal_udt_dive_a";
}

give_underwater_weapon()
{
	self TakeAllWeapons();
	self giveWeapon( "aps_underwater+swim" );
	self GiveMaxAmmo( "aps_underwater+swim" );
	self SwitchToWeapon( "aps_underwater+swim" );
	self thread flashlight();
	self DisableWeaponPickup();
}

shellshock_forever()
{
	/*
	self notify( "underwater_shellshock" );
	self endon( "underwater_shellshock" );
	while( 1 )
	{
		self shellshock( "underwater_swim", 9999 );
		wait( 9998 );
	}
	*/
}

enable_player_swim()
{
	SetSavedDvar( "cg_footsteps", 0 );
	SetSavedDvar( "cg_equipmentSounds", 0 );
	SetSavedDvar( "cg_landingSounds", 0 );

	self give_underwater_weapon();
	self thread shellshock_forever();
	
	self EnableSlowAim( 0.5, 0.5 );
	
	// Global for water current
	level.water_current = (0,0,0);

	// Global for drift vectors
	level.drift_vec = (0,0,0);

	// Flags for water movement
	thread moving_water();
	
	self.player_mover = self spawn_tag_origin();
	
	self maps\_underwater::player_scuba_mask();
	self thread maps\_underwater::player_scuba();
	self maps\_underwater::underwater_hud_enable( true );
	self thread dynamic_dof( 250 );
	self allowSwim( true );
}

disable_player_swim()
{
//	SetSavedDvar( "cg_footsteps", 0 );
//	SetSavedDvar( "cg_equipmentSounds", 0 );
//	SetSavedDvar( "cg_landingSounds", 0 );
//
//	self give_underwater_weapon();
//	self thread shellshock_forever();
//	
//	self EnableSlowAim( 0.5, 0.5 );
//	
//	// Global for water current
//	level.water_current = (0,0,0);
//
//	// Global for drift vectors
//	level.drift_vec = (0,0,0);
//
//	// Flags for water movement
//	thread moving_water();
//	
//	self.player_mover = self spawn_tag_origin();
//	
//	self maps\_underwater::player_scuba_mask();
//	self thread maps\_underwater::player_scuba();
//	self maps\_underwater::underwater_hud_enable( true );
	
	self allowSwim( false );
}

moving_water()
{
	moving_water_flags = GetEntArray( "moving_water_flags", "script_noteworthy" );
	foreach( flag in moving_water_flags )
	{
		thread moving_water_flag( flag );
	}
}

moving_water_flag( flag_ent )
{
	CURRENT_STRENGTH = 4;
	
	water_direction_ent = GetEnt( flag_ent.target, "targetname" );
	water_direction_vec = AnglesToForward( water_direction_ent.angles ) * CURRENT_STRENGTH; 

	while( 1 )
	{
		flag_wait( flag_ent.script_flag );
		level.water_current = water_direction_vec;
		flag_waitopen( flag_ent.script_flag );
		level.water_current = (0,0,0);
	}
}

#using_animtree( "player" );
player_swim_anims()
{
	level.scr_anim[ "playerhands" ][ "scuba_idle" ][0] = %scuba_player_idle;
	level.scr_anim[ "playerhands" ][ "scuba_forward" ][0] = %scuba_player_forward;
	level.scr_anim[ "playerhands" ][ "scuba_idle2forward" ] = %scuba_player_idle2forward;
	level.scr_anim[ "playerhands" ][ "scuba_forward2idle" ] = %scuba_player_forward2idle;	
	
	level.scr_animtree[ "playerhands" ] 	= #animtree;
	level.scr_model[ "playerhands" ] 	= "viewhands_player_udt";
}

flashlight()
{
	wait( 0.1 );
	
	if ( !isdefined( self.playerfxOrg ) )
	{
		self.fxtag = self spawn_tag_origin();
		self.fxtag.origin = self getEye();
		self.fxtag.origin -= ( 0,0,32 );
		self.fxtag LinktoPlayerView( level.player, "tag_origin", (0,0,0), (0,0,0), true );
	}
	else
	{
		self.fxtag = self.playerfxOrg;
	}
	self thread flashlight_toggle();	
}

flashlight_toggle()
{
	self.fxtag endon( "death" );
	
	//self notifyOnPlayerCommand( "toggle_flashlight", "+actionslot 2" );
	if ( !ent_flag_exist( "flashlight_on" ) )
		self ent_flag_init( "flashlight_on" );
	self thread particle_loop();
	
	self endon( "death" );
	
	while( 1 )
	{
		self waittill_either( "toggle_flashlight", "toggle_flashlight_on" );
		//sound ON here		
		self playsound("shipg_plyr_flashlight_on");
		PlayFXOnTag( getfx( "swim_flashlight_plr" ), self.fxtag, "tag_origin" );
		self ent_flag_set( "flashlight_on" );
		
		
		wait( 0.5 );
		self waittill_either( "toggle_flashlight", "toggle_flashlight_off" );
		//sound OFF here
		self playsound("shipg_plyr_flashlight_off");
		StopFXOnTag( getfx( "swim_flashlight_plr" ), self.fxtag, "tag_origin" );
		self ent_flag_clear( "flashlight_on" );
		
		wait( 1 );
	}
}

particle_loop()
{
	self.fxtag endon( "death" );
	
	while( 1 )
	{
		if ( self ent_flag( "flashlight_on" ) )
		{
			PlayFXOnTag( getfx( "swim_flashlight_particles" ), self.fxtag, "tag_origin" );
			wait( 0.3 );
		}
		else
		{
			self ent_flag_wait( "flashlight_on" );
		}
	}
}

dynamic_dof( dist_cutoff )
{
	//self = player
	self endon( "stop_dynamic_dof" );
	
	//Same as ADS process but without ADS requirement. Pauses if player is ADS'd.
	while(1)
	{
		wait(.05);
		
		if( flag( "pause_dynamic_dof" ) )
		{
			//Dont want to disable script_dof in case other script funcs are doing their own DOF
			wait( .05 );
			continue;
		}
		
		adsFrac = self PlayerAds();
		
		//Don't do this if we're ADSing
		if ( adsFrac > 0.0 )
		{
			continue;
		}
		
		traceDist 		= getdvarfloat( "ads_dof_tracedist", 		4096 );
		nearStartScale 	= getdvarfloat( "ads_dof_nearStartScale", 	0.25 );
		nearEndScale 	= getdvarfloat( "ads_dof_nearEndScale", 	0.85 );
		farStartScale 	= getdvarfloat( "ads_dof_farStartScale", 	1.15 );
		farEndScale 	= getdvarfloat( "ads_dof_farEndScale", 		3 );
		nearBlur 		= getdvarfloat( "ads_dof_nearBlur", 		4 );
		farBlur 		= getdvarfloat( "ads_dof_farBlur", 			2.5 );
		
		playerEye = self GetEye();
		playerAnglesRel = self GetPlayerAngles();
		if ( IsDefined( self.dof_ref_ent ) )
			playerAngles = CombineAngles( self.dof_ref_ent.angles, playerAnglesRel );
		else
			playerAngles = playerAnglesRel;
		playerForward = VectorNormalize( AnglesToForward( playerAngles ) );
	
		trace = BulletTrace( playerEye, playerEye + ( playerForward * traceDist ), true, self, true );
		enemies = GetAIArray( "axis" );

		if ( trace[ "fraction" ] == 1 )
		{
			traceDist = 2048;
			nearEnd = 256;
			farStart = traceDist * farStartScale * 2;
		}
		else
		{
			traceDist = Distance( playerEye, trace[ "position" ] );
					
			if( traceDist > dist_cutoff )
			{
				//Need to Disable the script DOF layer so the "base" layer takes effect. "base" gets set by DOF trigs
				maps\_art::dof_disable_script( .5 );
				continue;	
			}
			nearEnd = traceDist * nearStartScale;	// mkornkven: Shouldn't this be nearEndScale? 
			farStart = traceDist * farStartScale;
		}
			
		foreach( enemy in enemies )
		{
			enemyDir = VectorNormalize( enemy.origin - playerEye );
			
			dot = VectorDot( playerForward, enemyDir );
			if ( dot < 0.923 ) // 45 degrees
				continue;
			
			distFrom = Distance( playerEye, enemy.origin );
			
			if ( distFrom - 30 < nearEnd )
				nearEnd = distFrom - 30;
			
			if ( distFrom + 30 > farStart )
				farStart = distFrom + 30;
		}
		
		if ( nearEnd > farStart )
			nearEnd = farStart - 256;
	
		if ( nearEnd > traceDist )
			nearEnd = traceDist - 30;
	
		if ( nearEnd < 1 )
			nearEnd = 1;
	
		if ( farStart < traceDist )
			farStart = traceDist;
			
		nearStart 	= nearEnd * nearStartScale;
		farEnd 		= farStart * farEndScale;
		
		maps\_art::dof_enable_script( nearStart, nearEnd, nearBlur, farStart, farEnd, farBlur, .5 );	
	}
	wait(.05);
}

