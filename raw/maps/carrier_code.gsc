#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
//#include maps\_vehicle_code;
//#include maps\_vehicle_spline;
#include maps\_audio;

carrier_init()
{
	PreCacheModel( "viewhands_player_udt" );
	PreCacheModel( "viewlegs_generic" );
	
	PreCacheItem( "honeybadger" );
	PreCacheItem( "m9a1" );
	PreCacheItem( "rpg_straight" );	

}

setup_common()
{
	thread setup_front_elevator();
	thread setup_rod_of_god();
	thread run_emergency_lights();
	thread update_sun();
	thread update_deck_post_intro();
	thread setup_ocean_vista_tilt();
	
	/#
	thread run_debug();
	#/

	//if(!isdefined(level.variable_scope_weapons))
	//	level.variable_scope_weapons = [];
	//level.variable_scope_weapons[level.variable_scope_weapons.size]= "barrett";	
	//thread maps\_shg_common::monitorScopeChange();
	
	setup_player();
}

setup_player()
{
	tp			= level.start_point + "_start";
	startstruct = getstruct( tp, "targetname" );
	
	if ( IsDefined( startstruct ) )
	{
		level.player SetOrigin( startstruct.origin );
		if ( IsDefined( startstruct.angles ) )
			level.player SetPlayerAngles( startstruct.angles );
		else
			IPrintLnBold( "Your script_struct " + level.start_point + "_start has no angles! Set some." );			
	}
	else
	{
	/#
		IPrintLn( "Add scriptstruct with targetname " + level.start_point + "_start to set player start pos." );
	#/
	}
}

spawn_allies()
{
	level.allies						= [];
	level.allies[ level.allies.size ]	= spawn_ally( "merrick"  );
	level.allies[ level.allies.size -1 ].animname = "merrick";
	level.merrick = level.allies[ level.allies.size -1 ];
	level.merrick make_hero();
	//level.scr_sound[ "merrick" ] =[];
	level.allies[ level.allies.size ]	= spawn_ally( "hesh" );
	level.allies[ level.allies.size-1 ].animname = "hesh";
	level.hesh = level.allies[ level.allies.size -1 ];
	level.hesh make_hero();
	//level.scr_sound[ "hesh" ] =[];	
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
	
    return ally;
}





/*-----------------------------------------------*/
/*------------------ ELEVATORS ------------------*/
/*-----------------------------------------------*/
setup_front_elevator()
{	
	level.front_elevator = getent( "carrier_elevator_front_scripted", "targetname" );
	level.front_elevator.lowered = true;
	level.front_elevator.height = 512 + 6;
	level.front_elevator.time = 14;
	level.front_elevator.pre_set = false;
	level.front_elevator_vol = getent( "elevator_touching_vol", "targetname" );
	attachments = getentarray( "carrier_elevator_front_scripted_attachments", "targetname" );
	
	foreach( a in attachments )
	{
		a LinkTo( level.front_elevator );
	}	
	
	
	level.front_elevator_path = getent( "front_elevator_path", "targetname" );	
}

raise_front_elevator()
{	
	if ( level.front_elevator.lowered )
	{
		ai = level.front_elevator_vol get_ai_touching_volume();
		foreach ( guy in ai )
		{
			guy LinkTo( level.front_elevator );
		}
		height = level.front_elevator.height;
		time = level.front_elevator.time;
		if ( level.front_elevator.pre_set )
		{
			height /= 2;
			time /= 2;
			level.front_elevator.pre_set = false;
		}
		level.front_elevator MoveTo( level.front_elevator.origin + (0, 0, height), time, 2, 2 );
		wait time;
		level.front_elevator.lowered = false;
		foreach ( guy in ai )
		{
			if ( IsDefined( guy ) && IsAlive( guy ) )
			{
				guy Unlink();
			}
		}			
		flag_set("elevator_up_ding_ding");
	}
}

//sets elevator mid-way
pre_set_front_elevator()
{
	if ( level.front_elevator.lowered )
	{
		level.front_elevator MoveTo( level.front_elevator.origin + (0, 0, level.front_elevator.height / 2), .01 );
	}
	else
	{
		level.front_elevator MoveTo( level.front_elevator.origin - (0, 0, level.front_elevator.height / 2), .01 );
	}
	level.front_elevator.pre_set = true;
}


/*-------------------------------------------------*/
/*------------------ OCEAN WATER ------------------*/
/*-------------------------------------------------*/
setup_ocean_vista_tilt()
{
	level.ocean_water = getEnt( "ocean_water", "targetname" );
	
	vista = getEntArray( "vista_terrain", "targetname" );
	foreach( object in vista )
	{
		object LinkTo( level.ocean_water );
	}
	
	level.outro_animnode = GetEnt( "outro_animnode", "targetname" );
	level.outro_animnode LinkTo( level.ocean_water );
	
	level.tilt_sky = GetEnt( "carrier_tilt_sky", "targetname" );
	level.tilt_sky LinkTo( level.ocean_water );
	level.tilt_sky Hide();
	
	level.tilt_ground_ref = GetEnt( "player_ref_ent", "targetname" );
	level.tilt_ground_ref LinkTo( level.ocean_water );
	
	foreach( object in level.outro_zodiacs )
	{
		object LinkTo( level.ocean_water );
	}
	
	//--END OF INTRO--
	flag_wait( "slow_intro_finished" );
	level.tilt_sky Show();
	
	//--ROD OF GOD HITS CARRIER--
	flag_wait( "start_main_odin_strike" );
	boats = GetEntArray( "all_boats", "script_noteworthy" );
	foreach( boat in boats )
	{
		boat linkTo( level.ocean_water );
	}
	
	thread maps\carrier_outro::outro_corpses();
	thread maps\carrier_outro::outro_helis();
	
	level.player playerSetGroundReferenceEnt( level.tilt_ground_ref );	
	
	level.rog_carrier_clouds linkto( level.ocean_water );
	//TODO: tilt clouds w/ sky - currrently can't find fx
	//	level.rog_victory_cloud_fx linkto( level.tilt_sky );
	//	level.rog_carrier_cloud_fx linkto( level.tilt_sky );
}

vista_tilt()
{		
	if( level.start_point == "outro" )
	{
		// ship listing variables
		shift_time = .05;
		decel  = 0;
	}
	else
	{
		// ship listing variables
		shift_time = 20;
		decel  = 3;
	}

	rotation = ( -16.5, 2, 0 );
	move_Z = 400;
	
	level.sun_angles_deck_tilt_end = ( -30.5, -73, 0 );

	level.ocean_water RotateTo( rotation, shift_time, decel );
	level.ocean_water MoveZ( move_Z, shift_time, decel );
	
	LerpSunAngles( level.sun_angles_deck_tilt, level.sun_angles_deck_tilt_end, shift_time ); 
}

ocean_death()
{
	level endon( "death" );
	level endon( "no_water_death" );
	
	while(1)
	{
		if( level.player IsTouching( self ))
		{
			level.player DoDamage( level.player.health + 100, level.player.origin);
		}
		else
		{
			wait(.05);
		}
	}
}

/*-------------------------------------------------*/
/*------------------ RODS OF GOD ------------------*/
/*-------------------------------------------------*/
setup_rod_of_god()
{
	level.rod_of_god_start = getstruct( "rod_of_god_start", "targetname" );
}

rod_of_god( target_origin )
{
	rod_of_god		  = spawn_tag_origin();
	rod_of_god.origin = level.rod_of_god_start.origin;
	rod_of_god MoveTo( target_origin, 2.5 );
	PlayFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	wait( 2.5 );
	StopFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	waitframe();
	rod_of_god Delete();
	
	PlayFX( getfx( "building_explosion_mega_gulag" ), target_origin );
}

rod_of_god_victory()
{	
	start  = getstruct( "rog_victory_fx_start", "targetname" );
	target = getstruct( "rog_target_victory", "targetname" );
	
	//flashes
	thread rog_victory_flashes();

	thread play_sound_in_space( "elm_quake_sub_rumble", start.origin );
	thread play_sound_in_space( "rog_thunder", start.origin );
	//stop music
	flag_set( "victory_music_stop" );	
	
	wait 2;
	
	//sun/flash
	sun		   = spawn_tag_origin();
	sun.origin = start.origin;
	PlayFXOnTag( getfx( "dcemp_sun" ), sun, "tag_origin" );
	PlayFX( getfx( "vfx_lens_flare" ), start.origin );
	wait 0.3;
	StopFXOnTag( getfx( "dcemp_sun" ), sun, "tag_origin" );	

	
	//projectile
	rod_of_god		  = spawn_tag_origin();
	rod_of_god.origin = start.origin;
	rod_of_god MoveTo( target.origin, 2 );
	level.player PlaySound( "nymn_mortar_incoming" );
	PlayFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	wait( 2 );
	StopFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	
	//impact
	PlayFX( getfx( "building_explosion_mega_gulag" ), target.origin );
	thread play_sound_in_space( "scn_odin_pod_explosion", target.origin );
	//shockwave
	thread rog_victory_shockwave( target );
	
	//water	
	thread rog_victory_splashes( target );
	
	//screen shake / rumble / shock
	ScreenShake( level.player.origin, 4, 3, 3, 4, 0, 3, 256, 8, 15, 12, 1.8 );
	level.player PlayRumbleOnEntity( "ac130_40mm_fire" );
	level.player ShellShock( "hijack_engine_explosion", 3 );
	
	//sink ship
	us_destroyer_5 = GetEnt( "us_destroyer_5", "targetname" );
	us_destroyer_5 MoveTo( us_destroyer_5.origin - ( 0, 0, 500 ), 10, 5 );
	us_destroyer_5 RotateTo( ( 350, 270, 0 ), 10, 5 );	
	
	waitframe();
	rod_of_god Delete();	
}

rog_victory_clouds()
{
	//wait for transition out of sparrow to hide pop
	level.player waittill( "remove_sam_control" );
	level.rog_victory_clouds show_entity();
	start  = getstruct( "rog_victory_fx_start", "targetname" );
//	clouds_cumulus_far
	clouds		   = spawn_tag_origin();
	clouds.origin = start.origin - (0,0,2000);
	clouds.angles = (90,0,0);
	level.rog_victory_cloud_fx = PlayFXOnTag( getfx( "clouds_moving" ), clouds, "tag_origin" );
	
	flag_wait( "rog_reaction" );
	wait 5;
	StopFXOnTag( getfx( "clouds_moving" ), clouds, "tag_origin" );
	flag_wait( "start_main_odin_strike" );
	level.rog_victory_clouds hide_entity();	
}

rog_victory_flashes()
{
	flash_array = getstructarray( "rog_victory_fx_flash", "targetname" );
	
	playfx( getfx( "aa_explosion_clouds" ), flash_array[0].origin );
	wait 1.0;
	playfx( getfx( "lightning_cloud_a_persona_mp" ), flash_array[1].origin );
	wait 0.5;
	playfx( getfx( "aa_explosion_clouds" ), flash_array[2].origin );
	
	for( i = 0; i < 10; i++ )
	{
		foreach( fx in flash_array ) 
		{
			if ( cointoss() )
			{
				playfx( getfx( "lightning_cloud_a_persona_mp" ), fx.origin );
			}
			else
			{
				playfx( getfx( "aa_explosion_clouds" ), fx.origin );
			}
			waitframe();
		}
		wait 0.5;
	}
}

rog_victory_splashes( target )
{
	for( i = 0; i < 3; i++ )
	{
		offset_x = -2000 * i;
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), target.origin + (offset_x, 0, 0) );
		waitframe();
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), target.origin + (offset_x,1000,0) );
		waitframe();
		playfx( getfx( "water_splash_large_eiffel_tower_bigger" ), target.origin - (offset_x,1000,0) );	
		wait 0.5;
	}
}

rog_victory_shockwave( target )
{
	wait 0.75;
	playfx( getfx( "sw_rog_strike_shockwave" ), target.origin - (0,0,2000) );	
}





rod_of_god_victory_vista()
{	
	start  = level.rod_of_god_start;
	target = getstruct( "rog_target_2", "targetname" );
	
	//flashes
	thread rog_victory_flashes();

	thread play_sound_in_space( "elm_quake_sub_rumble", start.origin );
	thread play_sound_in_space( "rog_thunder", start.origin );
	
	wait 2;
	
	//projectile
	rod_of_god		  = spawn_tag_origin();
	rod_of_god.origin = start.origin;
	rod_of_god MoveTo( target.origin, 2 );
	level.player PlaySound( "nymn_mortar_incoming" );
	PlayFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	wait( 2 );
	StopFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	
	//impact
	PlayFX( getfx( "building_explosion_mega_gulag" ), target.origin );
	thread play_sound_in_space( "harb_uw_explosions", target.origin );
	//shockwave
	thread rog_victory_shockwave( target );
	
	//screen shake / rumble / shock
	ScreenShake( level.player.origin, 2, 1.5, 1.5, 3, 0, 3, 256, 8, 15, 12, 1.8 );
	level.player PlayRumbleOnEntity( "ac130_40mm_fire" );
	level.player ShellShock( "hijack_engine_explosion", 1 );
	
	waitframe();
	rod_of_god Delete();	
}

rod_of_god_victory_vista_2()
{	
	start  = level.rod_of_god_start;
	target = getstruct( "rog_target_3", "targetname" );
	
	//projectile
	rod_of_god		  = spawn_tag_origin();
	rod_of_god.origin = start.origin;
	rod_of_god MoveTo( target.origin, 2 );
	level.player PlaySound( "nymn_mortar_incoming" );
	PlayFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	wait( 2 );
	StopFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	
	//impact
	PlayFX( getfx( "building_explosion_mega_gulag" ), target.origin );
	thread play_sound_in_space( "harb_uw_explosions", target.origin );
	//shockwave
	thread rog_victory_shockwave( target );
	
	//screen shake / rumble / shock
	ScreenShake( level.player.origin, 2, 1.5, 1.5, 3, 0, 3, 256, 8, 15, 12, 1.8 );
	level.player PlayRumbleOnEntity( "ac130_40mm_fire" );
	level.player ShellShock( "hijack_engine_explosion", 1 );
	
	waitframe();
	rod_of_god Delete();	
}


rod_of_god_carrier()
{
	target = getstruct( "rog_target_carrier", "targetname" );
	
	//projectile
	rod_of_god		  = spawn_tag_origin();
	rod_of_god.origin = level.rod_of_god_start.origin;
	rod_of_god MoveTo( target.origin, 2.5 );
	level.player PlaySound( "nymn_mortar_incoming" );
	PlayFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	wait( 2.4 );
	StopFXOnTag( level._effect[ "sw_rog_strike_big_tail" ], rod_of_god, "tag_origin" );
	
	//impact
	PlayFX( getfx( "building_explosion_mega_gulag" ), target.origin );
	thread play_sound_in_space( "scn_odin_pod_explosion", target.origin );
	//shockwave
	thread rog_victory_shockwave( target );
	
	//water	
	//thread rog_victory_splashes( target );
	org = getEnt( "carrier_odin_water_impact", "targetname" );
	org linkTo( level.ocean_water );
	PlayFX( level._effect[ "water_splash_large_eiffel_tower_bigger" ], org.origin );
	PlayFX( level._effect[ "water_splash_large_eiffel_tower_bigger" ], org.origin + ( -16, 14, 12 ) );
	PlayFX( level._effect[ "water_splash_large_eiffel_tower_bigger" ], org.origin + ( 16, -14, 20 ) );
	
	//screen shake / rumble / shock
	ScreenShake( level.player.origin, 4, 3, 3, 4, 0, 3, 256, 8, 15, 12, 1.8 );
	level.player PlayRumbleOnEntity( "ac130_40mm_fire" );
	level.player ShellShock( "hijack_engine_explosion", 3 );
	
	waitframe();
	rod_of_god Delete();	
}

rog_carrier_clouds()
{
	level.rog_carrier_clouds show_entity();
	start  = getstruct( "rog_carrier_fx_start", "targetname" );
	clouds		   = spawn_tag_origin();
	clouds.origin = start.origin - (0,0,2000);
	clouds.angles = (90,0,0);
	level.rog_carrier_cloud_fx = PlayFXOnTag( getfx( "clouds_moving" ), clouds, "tag_origin" );
	thread play_sound_in_space( "rog_rumble", start.origin );
	thread play_sound_in_space( "rog_thunder", start.origin );	
	flag_wait( "start_main_odin_strike" );
	StopFXOnTag( getfx( "clouds_moving" ), clouds, "tag_origin" );		
}

rog_carrier_flashes()
{
	level endon( "start_main_odin_strike" );
	flash_array = getstructarray( "rog_carrier_fx_flash", "targetname" );
	
	playfx( getfx( "aa_explosion_clouds" ), flash_array[0].origin );
	wait 1.0;
	playfx( getfx( "lightning_cloud_a_persona_mp" ), flash_array[1].origin );
	wait 0.5;
	playfx( getfx( "aa_explosion_clouds" ), flash_array[2].origin );
	
	while(1)
	{
		foreach( fx in flash_array ) 
		{
			if ( cointoss() )
			{
				playfx( getfx( "lightning_cloud_a_persona_mp" ), fx.origin );
			}
			else
			{
				playfx( getfx( "aa_explosion_clouds" ), fx.origin );
			}
			waitframe();
		}
		wait 0.5;
	}
}

/*----------------------------------------------------*/
/*------------------ PLAYER SLIDING ------------------*/
/*----------------------------------------------------*/
///////////////////
// Player Sliding
//
// Attempt to Push player in a direction
// Let player counter push with facing and stick input
// Determine result and do player movement
//
// As angle of carrier increases, make countering push more difficult
//
///////////////////

player_slide_manager()
{
	level.x_slide_incr = 0;
	level.damage_slide_incr = 0;
	level.damage_slide_time = 0;
	
	while(1)
	{
		if( !flag( "damage_slide" ))
		{
			level.player PushPlayerVector( ( level.x_slide_incr, 0, 0 ) );
			//SetSavedDvar("bg_playerSlideVector", level.x_slide_incr + " 0 0");
			wait( .05 ) ;
		}
		else
		{
			level.player PushPlayerVector( ( level.damage_slide_incr + level.x_slide_incr, 0, 0 ) );
			//SetSavedDvar("bg_playerSlideVector", (level.damage_slide_incr + level.x_slide_incr) + " 15 0");
			wait level.damage_slide_time;
			level.player PushPlayerVector( ( level.x_slide_incr, 0, 0 ) );
			//SetSavedDvar("bg_playerSlideVector", level.x_slide_incr + " 0 0");
			level.damage_slide_incr = 0;
			level.damage_slide_time = 0;
			flag_clear( "damage_slide" );
		}
		
	}
}

player_gravity_slide()
{
	level endon( "player_in_heli" );
	
	//initial pitch = -4 0 0
	//after first explosion = -8 0 0
	//end of run = -17 15 0
	
	//time of run = 27, see flight_deck main function for changes.
	
	// net pitch change is 9 degrees (8 to 17) over 27 seconds or 1 degree every 3 seconds.
	
	while( abs(level.tilt_ground_ref.angles[0]) < 10 )
	{
		movement = level.player GetNormalizedMovement(); //strength of movement
		if( abs(movement[0]) > .1 )
		{
			level.x_slide_incr = 2;
		}
		else
		{
			level.x_slide_incr = 0;
		}
		wait( .05 );
	}
	
	level.x_slide_incr = 2;
	
	while( abs(level.tilt_ground_ref.angles[0]) <= 15 )
	{
		level.x_slide_incr += .075;
		wait( .1 ); //this should iterate ~150 times
	}
	
	// x should now be ~13.25
	
	while( abs(level.tilt_ground_ref.angles[0]) <= 16 )
	{
		level.x_slide_incr += .15;
		wait( .1 ); //this should iterate ~60 times
	}
	
	// x should now be ~22.25
	wait( 3 );

	while( level.x_slide_incr <= 20 )
	{
		level.x_slide_incr += .15;
		wait( .1 ); 
	}
	
	wait( 8 );
	
	while( level.x_slide_incr <= 30 )
	{
		level.x_slide_incr += .15;
		wait( .1 ); 
	}
	
	//level.player_gravity_slide_punish_trigger trigger_on();
	//trigger_wait_targetname( "player_gravity_slide_punish_trigger" );
	
	//thread player_gravity_slide_punish();
}

player_gravity_slide_punish()
{
	level endon( "end_player_slide" );
	
	while( abs(level.tilt_ground_ref.angles[0]) <= 17 ) //which will never be reached
	{
		level.x_slide_incr += .15;
		wait( .1 );
	}
	/*
	level.x_slide_incr = 20;
	
	while( level.x_slide_incr <= 50 )
	{
		level.x_slide_incr += .15;
		wait( .1 ); 
	}
	wait(5);
	*/
}

player_slide_fall()
{
	level endon( "player_in_heli" );
	
	level.player SetStance( "stand" );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player DisableWeapons();
	level.player FreezeControls( true );		
	//level.player ShellShock( "hijack_door_explosion", 5);
	
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	player_rig.angles = (0, 90, 0);
	//level.player PlayerLinkTo( player_rig, "tag_player", 1, 0, 0, 0, 0, true );
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.3 );
	player_rig anim_single_solo( player_rig, "carrier_player_slide");	
}



/*------------------------------------------------*/
/*------------------ RED LIGHTS ------------------*/
/*------------------------------------------------*/
#using_animtree( "animated_props" );
run_emergency_lights()
{
 	level thread redlights();
 	level thread redlight_spinner();
 	level thread wall_lights();
 	level thread wall_light_spinner();	
}

redlights()
{
	light = getentarray( "redlight", "targetname" );
	array_thread( light, ::redlights_think );
}

redlights_think()
{
	time = 5000;

	while ( true )
	{
		self rotatevelocity( ( 0, 360, 0 ), time );
		wait time;
	}
}

redlight_spinner()
{
	horizonal_spinners = getentarray( "horizonal_spinner", "targetname" );
	array_thread( horizonal_spinners, ::horizonal_spinners_think );
}

horizonal_spinners_think()
{
	self useanimtree( #animtree );
	self setanim( %launchfacility_b_emergencylight, 1, 0.1, 1.0 );
}

wall_lights()
{
	light = getentarray( "wall_light", "targetname" );
	array_thread( light, ::wall_lights_think );
}

wall_lights_think()
{
	time = 5000;

	while ( true )
	{
		self rotatevelocity( ( 360, 0, 0 ), time );
		wait time;
	}
}

wall_light_spinner()
{
	vertical_spinners = getentarray( "vertical_spinner", "targetname" );
	array_thread( vertical_spinners, ::vertical_spinners_think );
}

vertical_spinners_think()
{
	self useanimtree( #animtree );
	self setanim( %launchfacility_b_emergencylight, 1, 0.1, 1.0 );

}


/*------------------------------------------------*/
/*------------------ ENEMY UTIL ------------------*/
/*------------------------------------------------*/
ai_cleanup( script_noteworthy_value )
{
	ai_cleanup_array = GetEntArray( script_noteworthy_value, "script_noteworthy" );
	
	foreach( guy in ai_cleanup_array )
	{				
		if( IsAI( guy ) && IsAlive( guy ) )
		{
			if ( IsDefined( guy.script_noteworthy ) && ( guy.script_noteworthy == script_noteworthy_value ) )
			{
				guy Delete();
			}
		}
	}
}

ai_cleanup_fake_death( script_noteworthy_value )
{
	ai_cleanup_array = GetEntArray( script_noteworthy_value, "script_noteworthy" );
	
	foreach( guy in ai_cleanup_array )
	{				
		if( IsAI( guy ) && IsAlive( guy ) )
		{
			if ( IsDefined( guy.script_noteworthy ) && ( guy.script_noteworthy == script_noteworthy_value ) )
			{
				guy thread maps\ss_util::fake_death_bullet( 1.5 );
			}
		}
	}
}

get_random_enemy( noteworthy )
{	
	enemies = GetAIArray( "axis" );	
	
	enemies = array_removeDead( enemies );
	
	new_enemies = [];
	
	if ( IsDefined( noteworthy ) )
	{
		foreach ( enemy in enemies )
		{
			if ( IsDefined( enemy.script_noteworthy ) && enemy.script_noteworthy == noteworthy )
			{
				new_enemies = array_add( new_enemies, enemy );
			}
		}
	}
	else
	{
		new_enemies = enemies;	
	}
	
	if ( new_enemies.size )
	{
		return new_enemies[ RandomInt( new_enemies.size ) ];		
	}
	return undefined;
}

array_spawn_targetname_allow_fail( targetname, bForceSpawn )
{
	spawners = GetEntArray( targetname, "targetname" );
	AssertEx( spawners.size, "Tried to spawn spawners with targetname " + targetname + " but there are no spawners" );
	
	spawned = array_spawn_allow_fail( spawners );
	
	return spawned;
}

array_spawn_allow_fail( spawners, bForceSpawn )
{
	guys = [];
	foreach ( spawner in spawners )
	{
		spawner.count	= 1;
		guy				= spawner spawn_ai( bForceSpawn );
		if ( IsDefined( guy ) )
		{
			guys[ guys.size ] = guy;
		}
	}
	return guys;
}



retreat_from_vol_to_vol( from_vol, retreat_vol, delay_min, delay_max)
{
	AssertEx (  ((IsDefined(retreat_vol)  && IsDefined( from_vol ) ) ), "Need the two info volume names ." );

	checkvol = getEnt( from_vol , "targetname" );
	retreaters = checkvol get_ai_touching_volume(  "axis" );
	goalvolume = getEnt( retreat_vol , "targetname" );
	goalvolumetarget = getNode( goalvolume.target , "targetname" );
	foreach( retreater in retreaters )
	{
		if(IsDefined(retreater) && IsAlive(retreater))
		{
			retreater.fixednode = 0;
			retreater.pathRandomPercent = randomintrange( 75, 100 );
			retreater SetGoalNode( goalvolumetarget );
//			retreater SetGoalVolumeAuto( goalvolume );		
					
		}
	}
	
}

ai_array_killcount_flag_set( guys , killcount , flag , timeout )
{
	waittill_dead_or_dying( guys , killcount , timeout );
	flag_set( flag );
}

man_turret( turret_name )
{
	self.pathenemyfightdist = 10000;
	self setengagementmaxdist(10000,10000);
	self setEngagementMinDist( 1300, 1000 );
	self SetEntityTarget(level.player_blackhawk);

	mg = GetEnt(turret_name, "targetname");
	mg SetTurretIgnoreGoals(true);
	if ( IsDefined( level.player_blackhawk ) )
	{
		mg SetTargetEntity(level.player_blackhawk);
	}
	mg SetTopArc(45);
	mg SetRightArc(90);
	mg SetLeftArc(90);
	mg StartFiring();	
}

run_to_volume_and_delete( vol_targetname )
{
	self endon( "death" );
	self SetGoalVolumeAuto( getent( vol_targetname, "targetname" ) );	
	self waittill( "goal" );
	wait 2;
	self Delete();
}


rpg_guy_wait_and_fire_at_target( mytarget, wait_for_flag )
{
	self endon( "death" );

	flag_wait( wait_for_flag );
	//random delay
	wait RandomFloatRange( 0, 1 );
	self SetEntityTarget( mytarget );	
}

ignore_everything(timer)
{
	self endon("death");
	
    self.ignoreall = true;
    self.ignoreme = true;
    self.grenadeawareness = 0;
    self.ignoreexplosionevents = true;
    self.ignorerandombulletdamage = true;
    self.ignoresuppression = true;
    self.disableBulletWhizbyReaction = true;
    self disable_pain();
    self.dontavoidplayer = true;
    self.og_newEnemyReactionDistSq = self.newEnemyReactionDistSq;
    self.newEnemyReactionDistSq = 0;
    
    if(IsDefined(timer) && timer != 0.0)
    {
        wait(timer);
    
        self clear_ignore_everything();
    }
}

clear_ignore_everything()
{
    self.ignoreall = false;
    self.ignoreme = false;
    self.grenadeawareness = 1;
    self.ignoreexplosionevents = false;
    self.ignorerandombulletdamage = false;
    self.ignoresuppression = false;
    self.disableBulletWhizbyReaction = false;
    self enable_pain();
    self.dontavoidplayer = false;
    self.script_dontpeek = 0;
    if( IsDefined( self.og_newEnemyReactionDistSq ) )
    {
        self.newEnemyReactionDistSq = self.og_newEnemyReactionDistSq;
    }
}


/*------------------------------------------*/
/*------------------ UTIL ------------------*/
/*------------------------------------------*/
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
		spawned = spawner spawn_ai();
	    return spawned;
	}
	if ( IsDefined( spawner ) )
	{
		spawned = spawner spawn_ai();
    	IPrintLnBold( "Add a script struct called: " + sname + " to spawn him in the correct location." );
    	spawned Teleport( level.player.origin, level.player.angles );
    	return spawned;
		
	}
	IPrintLnBold( "failed to spawn " + tname + " at " + sname );
	
	return undefined;
}

targetname_spawn( targetname )
{	
	enemies = GetEntArray( targetname, "targetname" );		
	array_thread( enemies, ::spawn_ai );
}

array_combine_unique( array1, array2 )
{
	array3 = [];
	foreach ( item in array1 )
	{
		if (!isdefined(array_find(array3, item)))
			array3[ array3.size ] = item;
	}
	foreach ( item in array2 )
	{
		if (!isdefined(array_find(array3, item)))
			array3[ array3.size ] = item;
	}
	return array3;
}

show_msg( msg, time )
{
	while ( IsDefined( self.showing_msg ) && self.showing_msg )
	{
		waitframe();
	}
	
	if ( !IsDefined( time ) )
	{
		time = 2;	
	}
	
	if ( !IsDefined( self.msg_textelem ) )
	{
		self.msg_textelem = NewClientHudElem( self );
		self.msg_textelem.x = 0; //higher value = further right screen pos
		self.msg_textelem.y = 0; //higher value = lower screen pos
		self.msg_textelem.alignX = "center";
		self.msg_textelem.alignY = "middle";
		self.msg_textelem.horzAlign = "center";
		self.msg_textelem.vertAlign = "middle";
		self.msg_textelem.fontscale = 1.5;		
		self.msg_textelem.font = "objective";
	}
	self.showing_msg = true;
	self.msg_textelem.alpha = 1;	
	self.msg_textelem setText( msg );		
	if ( time >= 0 )
	{
		wait time;
		self.showing_msg = false;
		self.msg_textelem FadeOverTime( .5 );
		self.msg_textelem.alpha = 0;
	}
}

set_black_fade( black_amount, fade_duration )
{
	level notify("set_black_fade", black_amount, fade_duration);
	level endon("set_black_fade");

	if ( !IsDefined( black_amount ) )
	{
		black_amount = 1;
	}
	black_amount = max(0.0, min(1.0, black_amount));
	
	if ( !IsDefined( fade_duration ) )
	{
		fade_duration = 1;
	}
	fade_duration = max(0.01, fade_duration);
	
	if ( !IsDefined( level.hud_black ) )
	{
		level.hud_black = NewHudElem();
		level.hud_black.x = 0;
		level.hud_black.y = 0;
		level.hud_black.horzAlign = "fullscreen";
		level.hud_black.vertAlign = "fullscreen";
		level.hud_black.foreground = true;
		level.hud_black.sort = -999; // in front of everything
		level.hud_black SetShader("black", 650, 490);
		level.hud_black.alpha = 0.0;
	}
	
	level.hud_black FadeOverTime(fade_duration);
	level.hud_black.alpha = max(0.0, min(1.0, black_amount));
	if ( black_amount <= 0 )
	{
		wait fade_duration;
		level.hud_black destroy();
		level.hud_black = undefined;
	}
}

modulus( dividend, divisor )
{
	q = Int( dividend / divisor );
	return dividend - ( q * divisor );
}


/*--------------------------------------------*/
/*------------------ PLAYER ------------------*/
/*--------------------------------------------*/
player_hurt_breathing( rate )
{
	self endon( "death" );
	
	if ( !IsDefined( rate ) )
	{
		rate = 2;	
	}
	
	sounds = [];
	sounds[ sounds.size ] = "breathing_limp_better";
	//TODO: get curr vision set rather than hardcoding below
	level.originalVisionSet = "carrier_intro";
	
	while( !flag( "disable_hurt_breathing" ) )
	{
		sound = random( sounds );
		//thread set_blur( 2, .5 );
//		thread set_vision_set( "aftermath_nodesat", .5 );
		self play_sound_on_entity( sound );
		//thread set_blur( 0, .5 );
//		thread set_vision_set( level.originalVisionSet, 1 );
		
		timer = RandomFloatRange( rate - 1, rate + 1 );
		wait( timer );		
	}
	
//	thread set_vision_set( level.originalVisionSet, 1 );
}

fast_jog( enable )
{
	if ( enable == true )
	{
		self.animname = "generic";
		self set_run_anim( "clock_jog", 1 );
		self.moveplaybackrate = 1;
	}
	else
	{
		self clear_run_anim();
		self.moveplaybackrate = 1;
	}
}


/*---------------------------------------------*/
/*------------------ SPARROW ------------------*/
/*---------------------------------------------*/
sam_give_control()
{
	self endon( "remove_sam_control" );
	level.sam_launchers = [];
	level.sam_launchers	= array_add( level.sam_launchers, GetEnt( "sparrow_launcher", "targetname" ) );
	
	level.sam_launcher_index = 0;
	level.sam_lockon_targets = [];
	level.sam_lockon_range = 30000;
	
	switch_to_sam( 0 );

//	self setWeaponHudIconOverride( "actionslot3", "dpad_laser_designator" );
	self setWeaponHudIconOverride( "actionslot4", "dpad_laser_designator" );

//	self notifyOnPlayerCommand( "manual_lock_on", "+actionslot 3" );
	self notifyOnPlayerCommand( "use_sam", "+actionslot 4" );

	while ( 1 )
	{
		self waittill( "use_sam" );
		
		if ( IsDefined( self.using_sam ) && self.using_sam )
		{			
			self sam_exit();
		}
		else
		{
			self.lastUsedWeapon = self GetCurrentWeapon();
			self GiveWeapon( "sparrow_targeting_device" );
			self SwitchToWeapon( "sparrow_targeting_device" );
			self FreezeControls( true );
			self.using_sam = true;
			
			wait 0.5;
			
			level.black_overlay = maps\_hud_util::create_client_overlay( "black", 0, self );
			level.black_overlay FadeOverTime( 0.25 );
			level.black_overlay.alpha = 1;
			
			wait( 0.25 );
			
			self.prev_origin = self.origin;
			self.prev_angles = self GetPlayerAngles();
			self.prev_stance = self GetStance();
			
			self TakeWeapon( "sparrow_targeting_device" );
			
			self store_players_weapons( "sam" );
			self TakeAllWeapons();
			
			self SetStance( "stand" );
			self AllowCrouch( false );
			self AllowJump( false );
			self AllowProne( false );
			self EnableInvulnerability();
			
			SetSavedDvar( "ammoCounterHide", "1" );
			SetSavedDvar( "actionSlotsHide", "1" );
			SetSavedDvar( "compass", 0 );

			self SetOrigin( level.sam_launchers[ level.sam_launcher_index ] GetTagOrigin( "tag_barrel" ) - AnglesToForward( level.sam_launchers[ level.sam_launcher_index ] GetTagAngles( "tag_barrel" ) ) * 40 +
						  AnglesToUp( level.sam_launchers[ level.sam_launcher_index ] GetTagAngles( "tag_barrel" ) ) * 15 );
			self SetPlayerAngles( level.sam_launchers[ level.sam_launcher_index ] GetTagAngles( "tag_barrel" ) + ( 5, 0, 0 ));
			
			self PlayerLinkToDelta( level.sam_launchers[ level.sam_launcher_index ], "tag_player", 1, 0, 0, 0, 0 );
			self PlayerLinkedOffsetEnable();
			
			clear_sam_missiles();
			load_sam_missiles();
			
			self thread sam_control();
			
			level.black_overlay FadeOverTime( 0.25 );
			level.black_overlay.alpha = 0;
			
			self thread sam_use_auto_lock_on();
			self thread sam_ads();
		}
	}
}

sam_exit()
{
	self notify( "exit_sam" );
			
	level.black_overlay FadeOverTime( 0.25 );
	level.black_overlay.alpha = 1;
	
	wait 0.25;
	
	self sam_clear_hud();
	
	count = 0;
	
	foreach( target in Target_GetArray() )
	{
		if ( !IsDefined( target ) )
		{
			continue;	
		}
		
		Target_HideFromPlayer( target, self );
		Target_SetShader( target, "veh_hud_target" );
		count++;
		
		if ( count > 5 )
		{
			count = 0;
			wait 0.05;
		}
	}
	
	level.sam_lockon_targets = [];
	
	level.black_overlay FadeOverTime( 0.25 );
	level.black_overlay.alpha = 0;
	
	self Unlink();
	self restore_players_weapons( "sam" );
	self SwitchToWeapon( self.lastUsedWeapon );
	
	self SetOrigin( self.prev_origin );
	self SetPlayerAngles( self.prev_angles );
	
	self SetStance( self.prev_stance);
	
	self AllowProne( true );
	self AllowCrouch( true );
	self AllowJump( true );
	
	self DisableInvulnerability();
	
	SetSavedDvar( "cg_fov", 65 );
	SetSavedDvar( "ammoCounterHide", "0" );
	SetSavedDvar( "actionSlotsHide", "0" );
	SetSavedDvar( "compass", 1 );
	
	self.using_sam = false;
}

sam_remove_control()
{
	self notify( "remove_sam_control" );
	
	self setWeaponHudIconOverride( "actionslot4", "" );
	
	if ( IsDefined( self.using_sam ) && self.using_sam )
	{
		self sam_exit();
	}
	
	level.sam_targets = [];
}

sam_hud()
{
	self endon( "remove_sam_control" );
	self endon( "exit_sam" );
	self endon( "death" );
	
	self.sam_hud_elements = [];
	
	self.sam_hud_elements[ "screen_overlay" ] = newClientHudElem( self );
	self.sam_hud_elements[ "screen_overlay" ].x = 0;
	self.sam_hud_elements[ "screen_overlay" ].y = 0;
	self.sam_hud_elements[ "screen_overlay" ].alignX = "left";
	self.sam_hud_elements[ "screen_overlay" ].alignY = "top";
	self.sam_hud_elements[ "screen_overlay" ].horzAlign = "fullscreen";
	self.sam_hud_elements[ "screen_overlay" ].vertAlign = "fullscreen";
	self.sam_hud_elements[ "screen_overlay" ].alpha = 1;
	self.sam_hud_elements[ "screen_overlay" ] setshader( "ugv_screen_overlay", 640, 480 );
	
	self.sam_hud_elements[ "scanline" ] = newClientHudElem( self );
	self.sam_hud_elements[ "scanline" ].x = 0;
	self.sam_hud_elements[ "scanline" ].y = 0;
	self.sam_hud_elements[ "scanline" ].alignX = "center";
	self.sam_hud_elements[ "scanline" ].alignY = "middle";
	self.sam_hud_elements[ "scanline" ].horzAlign = "center";
	self.sam_hud_elements[ "scanline" ].vertAlign = "middle";
	self.sam_hud_elements[ "scanline" ].alpha = 1;
	self.sam_hud_elements[ "scanline" ] setshader( "m1a1_tank_sabot_scanline", 1000, 75 );
	self.sam_hud_elements[ "scanline" ] thread sam_update_scanline();
	
	self.sam_hud_elements[ "screen_vignette" ] = newClientHudElem( self );
	self.sam_hud_elements[ "screen_vignette" ].x = 0;
	self.sam_hud_elements[ "screen_vignette" ].y = 0;
	self.sam_hud_elements[ "screen_vignette" ].alignX = "left";
	self.sam_hud_elements[ "screen_vignette" ].alignY = "top";
	self.sam_hud_elements[ "screen_vignette" ].horzAlign = "fullscreen";
	self.sam_hud_elements[ "screen_vignette" ].vertAlign = "fullscreen";
	self.sam_hud_elements[ "screen_vignette" ].alpha = 1;
	self.sam_hud_elements[ "screen_vignette" ] setshader( "ugv_vignette_overlay", 640, 480 );
	
	self.sam_hud_elements[ "reticle" ] = self maps\_hud_util::createClientIcon( "a10_hud_reticle_large", 128, 128 );
	self.sam_hud_elements[ "reticle" ].alignx = "center";
	self.sam_hud_elements[ "reticle" ].aligny = "middle";
	self.sam_hud_elements[ "reticle" ].horzAlign = "center";
	self.sam_hud_elements[ "reticle" ].vertAlign = "middle";
	self.sam_hud_elements[ "reticle" ].alpha = 1;
}

sam_clear_hud()
{
	keys = getArrayKeys( self.sam_hud_elements );
	foreach ( key in keys )
	{
		self.sam_hud_elements[ key ] Destroy();
		self.sam_hud_elements[ key ] = undefined;
	}
	
	self.sam_hud_elements = [];
}

sam_update_scanline()
{
	level.player endon( "remove_sam_control" );
	level.player endon( "exit_sam" );
	level.player endon( "death" );
	
	while ( 1 )
	{
		self.y = -400;
		self MoveOverTime( 2 );
		self.y = 400;
		wait 2;
	}
}

sam_control()
{
	self endon( "remove_sam_control" );
	self endon( "exit_sam" );
	self endon( "death" );
	
	self sam_hud();
	
	while ( 1 )
	{
		movement = self GetNormalizedCameraMovement();
		
		if ( abs( movement[ 0 ] ) < 0.1 )
		{
			movement = ( 0.0, movement[ 1 ], movement[ 1 ] );
		}
		
		if ( abs( movement[ 1 ] ) < 0.1 )
		{
			movement = ( movement[ 0 ], 0.0, movement[ 1 ] );
		}
		
		level.sam_launchers[ level.sam_launcher_index ].angles -= ( movement[ 0 ] * ter_op( GetDvarFloat( "cg_fov" ) >= 65, 3, .85 ), movement[ 1 ] * ter_op( GetDvarFloat( "cg_fov" ) >= 65, 3, .85 ), 0 );
		
		level.sam_launchers[ level.sam_launcher_index ].angles = ( Clamp( AngleClamp180( level.sam_launchers[ level.sam_launcher_index ].angles[ 0 ] ), -30, 30 ), level.sam_launchers[ level.sam_launcher_index ].angles[ 1 ], level.sam_launchers[ level.sam_launcher_index ].angles[ 2 ] );
		
		wait 0.05;
	}
}

sam_use_manual_lock_on()
{
	self endon( "exit_sam" );
	self endon( "remove_sam_control" );
	
	self.lockon_sequence_active = false;
	
	while ( level.sam_missiles.size > 0 )
	{
		while ( !self AdsButtonPressed() )
		{
			wait 0.05;
		}
		
		self thread sam_start_missile_lockon();
		
		while ( self AdsButtonPressed() )
		{
			wait 0.05;
		}
		
		self notify( "sam_missile_lockon_end" );
		
		if ( self.lockon_sequence_active )
		{
			self notify( "end_lockon_sequence" );
			self.lockon_sequence_active = false;
		}
/*		
		foreach ( target in Target_GetArray() )
		{
			Target_ShowToPlayer( target, self );
		}
*/		
		self sam_fire_missiles();
	}
}

sam_use_auto_lock_on()
{
	self endon( "exit_sam" );
	self endon( "remove_sam_control" );
	
	self NotifyOnPlayerCommand( "fire_missiles", "+attack" );
	
	while ( 1 )
	{
		self.lockon_sequence_active = false;
		
		self thread sam_start_missile_lockon();
	
		self waittill( "fire_missiles" );
		
		self notify( "sam_missile_lockon_end" );
		
		if ( self.lockon_sequence_active )
		{
			self notify( "end_lockon_sequence" );
			self.lockon_sequence_active = false;
		}
		
		self sam_fire_missiles();
	}
}

sam_ads()
{
	self endon( "exit_sam" );
	self endon( "remove_sam_control" );
	
	self NotifyOnPlayerCommand( "ads_on", "+speed_throw" );
	self NotifyOnPlayerCommand( "ads_off", "-speed_throw" );
	
	self.sam_ads = false;
	
	while ( 1 )
	{
		if ( !self AdsButtonPressed() )
		{
			self waittill( "ads_on" );
		}
		
		self LerpFOV( 15, 0.25 );
		self.sam_ads = true;
		
		wait 0.25;
		
		if ( self AdsButtonPressed() )
		{
			self waittill( "ads_off" );
		}
		
		self LerpFOV( 65, 0.25 );
		self.sam_ads = false;
		
		wait 0.25;
	}
}

sam_start_missile_lockon()
{
	self endon( "exit_sam" );
	self endon( "remove_sam_control" );
	self endon( "sam_missile_lockon_end" );
	
	current_lockon_target = self;
	lockon_time = 0.0;
	lockon_flash_interval = 0.0;
	lockon_showing_target = false;
	
	lockon_radius = 64;
	lockon_max_dist_sq = 30000 * 30000;
	
	self.lockon_sequence_active = false;
	
	if ( !IsDefined( level.sam_targets ) )
	{
		level.sam_targets = [];
	}
	
	while ( 1 )
	{
		if ( current_lockon_target == self )
		{
			closest_target = undefined;
			closest_target_dist = 999999999;
			
			foreach ( targ in level.sam_targets )
			{
				if ( IsDefined( targ ) && IsAlive( targ ) && !array_contains( level.sam_lockon_targets, targ ) && Target_IsTarget( targ ) && Target_IsInCircle( targ, self, GetDvarFloat( "cg_fov" ), lockon_radius ) )
				{
					dist_sq = DistanceSquared( targ.origin, self.origin );
					if ( !IsDefined( closest_target ) || dist_sq < closest_target_dist )
					{
						//don't lockon to far away targets if not in ADS
						if ( self.sam_ads || dist_sq < lockon_max_dist_sq )
						{
							closest_target = targ;
							closest_target_dist = dist_sq;
						}
					}
				}
			}
			
			current_lockon_target = closest_target;
			
			if ( IsDefined( current_lockon_target ) )
			{
				lockon_time = 0.25;
				lockon_flash_interval = 0.0;
				lockon_showing_target = false;
				Target_HideFromPlayer( current_lockon_target, self );
				if ( !self.lockon_sequence_active )
				{
					self notify( "start_lockon_sequence" );
					self.lockon_sequence_active = true;
				}
			}
			else
			{
				current_lockon_target = self;
				
				if ( self.lockon_sequence_active )
				{
					self notify( "end_lockon_sequence" );
					self.lockon_sequence_active = false;
				}
			}
		}
		else
		{
			if ( !IsDefined( current_lockon_target ) || !Target_IsTarget( current_lockon_target ) )
			{
				current_lockon_target = self;
				continue;
			}
			
			lockon_time -= 0.05;
			lockon_flash_interval += 0.05;
			
			if ( lockon_time < 0.0 )
			{
//				Target_SetShader( current_lockon_target, "veh_hud_target_marked" );
				Target_ShowToPlayer( current_lockon_target, self );
				current_lockon_target.lased = true;
				level.sam_lockon_targets = array_add( level.sam_lockon_targets, current_lockon_target );
				current_lockon_target = self;
				self playLocalSound( "recondrone_tag" );
			}
			else if ( !Target_IsInCircle( current_lockon_target, self, GetDvarFloat( "cg_fov" ), lockon_radius ) )
			{
				Target_HideFromPlayer( current_lockon_target, self );
				current_lockon_target = self;
			}
			else if ( lockon_flash_interval == 0.1 )
			{
				lockon_flash_interval = 0.0;
				
				lockon_showing_target = !lockon_showing_target;
				
				if ( lockon_showing_target )
				{
					Target_ShowToPlayer( current_lockon_target, self );
				}
				else
				{
					Target_HideFromPlayer( current_lockon_target, self );
				}
			}
		}
		
		wait 0.05;
	}
}

sam_fire_missiles()
{
	missiles_fired = false;
	
	foreach( target in level.sam_lockon_targets )
	{
		if ( IsDefined( target ) && Target_IsTarget( target ) && IsAlive( target ) && level.sam_missiles.size > 0 )
		{
			Target_SetAttackMode( target, "direct" );
			missile = self sam_fire_missile( true );
			missile thread sam_missile_lockon( target );
			Target_HideFromPlayer( target, self );
			
			missiles_fired = true;
			
			earthquake( 0.4, 0.15, self.origin, 999999999 );
			self PlayRumbleOnEntity( "ac130_40mm_fire" );
			
			wait RandomFloatRange( 0.05, 0.15 );
		}
	}
	
	level.sam_targets = array_remove_array( level.sam_targets, level.sam_lockon_targets );
	
	level.sam_lockon_targets = [];
	
	if ( !missiles_fired && level.sam_missiles.size > 0 )
	{
		missile = self sam_fire_missile( false );
				
		earthquake( 0.4, 0.15, self.origin, 999999999 );
		self PlayRumbleOnEntity( "ac130_40mm_fire" );
	}
}

sam_fire_missile( locked )
{
//	thread aud_missile_go();
	missile_model = level.sam_missiles[ 0 ];
	
	if ( locked )
	{
		missile = MagicBullet( "sparrow_missile", missile_model.origin, missile_model.origin + AnglesToForward( missile_model.angles ) * 100000 );
	}
	else
	{
		missile = MagicBullet( "sparrow_missile_flak", missile_model.origin, missile_model.origin + AnglesToForward( missile_model.angles ) * 100000 );
	}
	
	level.sam_missiles = array_remove_index( level.sam_missiles, 0 );
	
	wait 0.05;
	
	missile_model Hide();
	missile_model thread sam_reload_missile();
	
	return missile;
}

sam_reload_missile()
{
	wait 1;
	
	dist = 120;
	
	self Unlink();
	
	while ( dist >= 0 )
	{
		self.angles = get_current_sam() GetTagAngles( "tag_missle" + self.missile_index );
		self.origin = get_current_sam() GetTagOrigin( "tag_missle" + self.missile_index ) - AnglesToForward( self.angles ) * dist;
		
		wait 0.05;
		
		self Show();
		
		dist -= 10;
	}
	
	self.angles = get_current_sam() GetTagAngles( "tag_missle" + self.missile_index );
	self.origin = get_current_sam() GetTagOrigin( "tag_missle" + self.missile_index );
	
	self LinkTo( get_current_sam() );
	
	level.sam_missiles[ level.sam_missiles.size ] = self;
}

get_current_sam()
{
	return level.sam_launchers[ level.sam_launcher_index ];
}

switch_to_sam( index )
{
	AssertEx( level.sam_launcher_index >= 0 && level.sam_launcher_index < level.sam_launchers.size, "Invalid level.sam_launcher_index" );
	level.sam_launcher_index = index;
	num = index + 1;
	clear_sam_missiles();
	load_sam_missiles();	
}

load_sam_missiles()
{
	level.sam_missiles = [];
	
	missile_order = [];
	missile_order[ missile_order.size ] = 1;
	missile_order[ missile_order.size ] = 4;
	missile_order[ missile_order.size ] = 5;
	missile_order[ missile_order.size ] = 8;
	missile_order[ missile_order.size ] = 2;
	missile_order[ missile_order.size ] = 3;
	missile_order[ missile_order.size ] = 6;
	missile_order[ missile_order.size ] = 7;
	
	missile_index = 1;
	
	for ( i = 0; i < 8; i++ )
	{
		org = get_current_sam() GetTagOrigin( "tag_missle" + missile_index );
		ang = get_current_sam() GetTagAngles( "tag_missle" + missile_index );
		
		level.sam_missiles[ i ] = Spawn( "script_model", org );
		level.sam_missiles[ i ] SetModel( "projectile_slamraam_missile" );
		level.sam_missiles[ i ].angles = ang;
		level.sam_missiles[ i ] LinkTo( get_current_sam() );
		level.sam_missiles[ i ].missile_index = missile_index;
		
		if ( modulus( missile_index, 2 ) == 0 )
		{
			missile_index += 1;
		}
		else
	{
			missile_index += 3;
		}
		
		if ( missile_index > 8 )
		{
			missile_index = 2;
		}
	}	
}

clear_sam_missiles()
{
	if ( IsDefined( level.sam_missiles ) && level.sam_missiles.size > 0 )
	{
		foreach ( missile in level.sam_missiles )
		{
			missile Unlink();
			missile Delete();
		}
	}
}


sam_add_target()
{
	if ( !IsDefined( level.sam_targets ) )
	{
		level.sam_targets = [];
	}
	
	if ( !array_contains( level.sam_targets, self ) )
	{
		level.sam_targets[ level.sam_targets.size ] = self;
		add_target( self );
	}
	
	foreach ( targ in level.sam_targets )
	{
		if ( IsDefined( targ ) )
		{
			targ thread remove_sam_target_on_death();
		}
	}
}

add_target( targ )
{
	targ EnableAimAssist();
	Target_Set( targ );
	Target_SetShader( targ, "veh_hud_target" );
	Target_SetScaledRenderMode( targ, true );
	Target_HideFromPlayer( targ, level.player );
	Target_DrawCornersOnly( targ, false );
	Target_SetMaxSize( targ, 160 );	
}

remove_sam_target_on_death()
{
	self notify( "remove_on_death_call" );
	self endon( "remove_on_death_call" );
	level.player endon( "stop_using_sam" );

	self waittill_any( "death", "delete" );	
	
	if ( IsDefined( self ) && Target_IsTarget( self ) )
	{
		Target_Remove( self );
		level.sam_targets = array_remove( level.sam_targets, self );
		if ( IsDefined( level.sam_lockon_targets ) )
		{
			level.sam_lockon_targets = array_remove( level.sam_lockon_targets, self );
		}				
	}
	
	if ( IsDefined( level.sam_targets ) )
	{
		level.sam_targets = array_removeUndefined( level.sam_targets );
	}
	
	if ( IsDefined( level.sam_lockon_targets ) )
	{
		level.sam_lockon_targets = array_removeUndefined( level.sam_lockon_targets );
	}
}

sam_tracking()
{
	self endon( "stop_using_sam" );
	self endon( "exit_sam" );
				
	while ( 1 )
	{
		average_loc = ( 0, 0, 0 );
		num_targets = 0;
		
		foreach ( targ in level.sam_lockon_targets )
		{
			if ( !IsDefined( array_find( level.sam_targets, targ ) ) )
			{
				continue;
			}
			
			num_targets++;
			average_loc += targ.origin;
		}
		
		if ( num_targets > 0 )
		{
			average_loc /= num_targets;
			
			desired_angles = VectorToAngles( average_loc - get_current_sam().origin );

			get_current_sam() RotateTo( (0, desired_angles[ 1 ], 0 ), 1.0, 0.25, 0.25 );
				
			wait 1;
		}
		else
		{
			wait 0.05;
		}
	}
}

sam_missile_lockon( targ )
{
	targ endon( "death" );
	self endon( "death" );
	
	wait 0.25;
	
	if ( IsDefined( targ ) )
	{	
		//project forward based on vehicle type
		offset = ( 0, 0, 0 );
		if ( IsDefined( targ.vehicletype ) && targ isHelicopter() )
		{
			offset = AnglesToForward( targ.angles ) * 80;
		}
		else if ( IsDefined( targ.vehicletype ) && targ isAirplane() )
		{
			offset = AnglesToForward( targ.angles ) * 256;	
		}
		self Missile_SetTargetEnt( targ, offset );
//		thread drawline_target( targ, offset, 4 );
	}
	
	
	//HACK: force explode target if missile gets close or time elapses
	CLOSE_ENOUGH_DIST = 512;
	FORCE_KILL_TIME = 4;
	
	timer = gettime() + ( FORCE_KILL_TIME * 1000 );
	while ( GetTime() < timer && IsDefined( self ) && IsDefined( targ ) )
	{
		if ( DistanceSquared( self.origin, targ.origin ) < CLOSE_ENOUGH_DIST * CLOSE_ENOUGH_DIST )
		{
			break;
		}
		waitframe();
	}
		
	self kill_target( targ );
}

kill_target( targ )
{
	//blow up missile
	if ( IsDefined( self ) )
	{
		self kill();
	}
	
	//blow up target
	if ( IsDefined( targ.vehicletype ) && targ isHelicopter() )
	{	
		targ kill();
	}
	else if ( IsDefined( targ.vehicletype ) && targ isAirplane() )
	{
		targ notify( "damage", 5000, level.player, (0,0,0), (0,0,0), "MOD_PROJECTILE" );
	}
}

drawline_target( targ, offset, timer )
{
	targ endon( "death" );
	timer = gettime() + ( timer * 1000 );
	while ( gettime() < timer )
	{
		line( level.player.origin, targ.origin + offset, ( 1, 0, 0 ), 1 );
		wait .05;
	}
}

fire_single_sparrow_missile( fire_loc, target )
{
	missile	= MagicBullet( "sparrow_missile", fire_loc.origin, fire_loc.origin + AnglesToForward( fire_loc.angles ) * 100000 );
	missile thread sam_missile_lockon( target );	
}



/*-----------------------------------------------*/
/*------------------ BLACKHAWK ------------------*/
/*-----------------------------------------------*/
setup_blackhawk( targetname )
{
	level.player_blackhawk = spawn_vehicle_from_targetname_and_drive( targetname );
	level.player_blackhawk.dont_crush_player = 1;
	level.player_blackhawk.path_gobbler = true;
	level.player_blackhawk godon();
	level.player_blackhawk.lookat_ent = Spawn( "script_origin", level.player_blackhawk.origin );

	init_player_on_blackhawk( level.player, targetname + "_seat" );
}

setup_blackhawk_heli_ride( targetname )
{
  	level.player_blackhawk = spawn_vehicle_from_targetname_and_drive ( "heli_ride_blackhawk_player" );  	
  	level.player_blackhawk thread maps\carrier_blackhawk::setup_carrier_blackhawk( true );
	level.player_blackhawk.mgturret[0] setmode ( "manual" );
	level.player_blackhawk.godmode = true;	
}

init_player_on_blackhawk( player, seat_location )
{
	if( !IsDefined(player) )
	{
		return;
	}

	// create an offset tag to the blackhawk
	seat_tag 		= spawn_tag_origin();

	// link the new tag to the heli and link the player to the new tag
	seat_tag LinkTo( level.player_blackhawk, "tag_guy7", ( 4, -16, -48 ), ( 0, -30, 0 ) );
	level.player PlayerLinkToDelta( seat_tag, "tag_player", 0.8, 25, 28, 30, 20, false );
	level.player SetPlayerAngles( ( 0, level.player_blackhawk.angles[ 1 ] - 30, 0 ) );

	player AllowJump( false );
	player AllowSprint( false );
	player AllowProne( false );
	player AllowCrouch( false );
	player DisableWeapons();
	
	player.is_on_heli = true;
}

init_player_on_blackhawk_heli_ride()
{
	level.player DisableWeapons();
	level.player_blackhawk lerp_player_view_to_tag( level.player, "tag_player1", 1, .8, 70, 70, 40, 55 );
	level.player EnableWeapons();
	
	level.player.seat_tag 		= spawn_tag_origin();
	level.player.seat_tag LinkTo( level.player_blackhawk, "tag_player1", (4,-16,-16), (0,0,0) );
	level.player PlayerLinkToDelta( level.player.seat_tag, "tag_origin", .8, 70, 70, 40, 55 );
//	level.player SetPlayerAngles( ( 0, level.player_blackhawk.angles[ 1 ] - 90, 0 ) );
	
	level.player AllowJump( false );
	level.player AllowSprint( false );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
}

player_switch_to_blackhawk_minigun()
{
	playertag = "tag_player1";
	level.player_blackhawk.turret_model.animname = "turret";
	level.player_blackhawk.turret_model SetAnimTree();
	level.player_blackhawk.turret_model unlink();
	level.player_blackhawk.turret_model linkto( level.player_blackhawk, playertag );
	thread lerp_fov_overtime(2, 55);
	level.player_blackhawk.turret_model linkto( level.player_blackhawk, "tag_turret_npc" );
	maps\carrier_blackhawk::player_lerped_onto_blackhawk_sideturret(false);
	self notify("player_entered_blackhawk");
}

blackhawk_own_target( target_ent )
{
	self endon( "stop_firing" );
	self endon( "death" );
	
	self thread blackhawk_shell_ejects_fx( "stop_fx" );
	
	//handle dumb firing (no target)
	if ( !IsDefined( target_ent ) )
	{
		spot = self.origin + AnglesToRight( self.angles ) * 2000;
		shot_amount = randomintrange( 30, 50 );
		for(i = 0; i< shot_amount; i++ )
		{
			magicbullet( "dshk_turret_sp", self GetTagOrigin( "tag_flash" ), spot );
			wait( RandomFloatRange( .05, .15) );
		}
		self notify( "stop_fx" );
		return;
	}	
	
	//handle targetting non-AI - e.g. script_origin
	if ( !IsAI( target_ent ) )
	{
		spot = target_ent.origin +( 0,0,50);
		shot_amount = randomintrange( 30, 50 );
		for(i = 0; i< shot_amount; i++ )
		{
			magicbullet( "dshk_turret_sp", self GetTagOrigin( "tag_flash" ), spot );
			wait( RandomFloatRange( .05, .15) );
		}
		self notify( "stop_fx" );
		return;
	}
	
	//otherwise handle targetting AI	
//	self blackhawk_rotate_gun_to_target( target_ent );
	
	if( isalive( target_ent )  )
	{		
		spot = target_ent.origin +( 0,0,50);
		shot_amount = randomintrange( 15, 20 );
		for(i = 0; i< shot_amount; i++ )
		{
			if ( IsDefined( self ) )
			{
				//thread draw_line_from_ent_to_ent_for_time(self, target_ent, 1, 0, 0, 1); //RED
				magicbullet( "dshk_turret_sp", self GetTagOrigin( "tag_flash" ), spot );
				magicbullet( "dshk_turret_sp", self GetTagOrigin( "tag_flash" ) + (0,0,4), spot + (0,0,4) );
				wait( RandomFloatRange( .05, .15) );
			}
		}
	}
	
	if(isalive( target_ent) )
	{
		target_ent die();
	}
	
	self notify( "stop_fx" );
}

//grabs angle off of heli struct and uses that to set lookat ent
set_lookat_targetname( targetname, yaw )
{
	heli_struct = getstruct( targetname, "targetname" );
	lookat_ent = spawn_tag_origin();
	lookat_ent.origin = heli_struct.origin + AnglesToForward( heli_struct.angles ) * 2000;
	if ( IsDefined( yaw ) && yaw )
	{
		self ClearLookAtEnt();
		self SetGoalYaw( lookat_ent.angles[1] );
	}
	else
	{
		self ClearGoalYaw();
		self SetLookAtEnt( lookat_ent );
	}
}

//DEBUG
monitor_speed()
{
	level.player_blackhawk endon( "death" );
	while(1)
	{
		level.player_blackhawk.speed = level.player_blackhawk Vehicle_GetSpeed();
		wait .05;
	}
}

heli_lands( land_node )
{
    // we can afford the treadfx now, so turn them on.
//    maps\_treadfx::setvehiclefx( "script_vehicle_mi17_woodland_landing", "snow", "fx/treadfx/heli_snow_hijack");
//    maps\_treadfx::setvehiclefx( "script_vehicle_mi17_woodland_landing", "ice", "fx/treadfx/heli_snow_hijack");
//    maps\_treadfx::setvehiclefx( "script_vehicle_mi17_woodland_landing", "slush", "fx/treadfx/heli_snow_hijack");
    
    self.originheightoffset = Distance( self GetTagOrigin( "tag_origin" ), self GetTagOrigin( "tag_ground" ) );
    
    self vehicle_detachfrompath();
    
    self SetGoalYaw( land_node.angles[ 1 ] );
    self SetTargetYaw( land_node.angles[ 1 ] );
    self SetHoverParams( 0, 0, 0 );
    self SetVehGoalPos( land_node.origin, 1 );
    
    self waittill( "goal" );
    
    wait( 0.25 );
    self Vehicle_Teleport( land_node.origin, land_node.angles );
    flag_set( "heli_landed" );
}

blackhawk_shell_ejects_fx( stopFiringOnNotify )
{
	self endon( "death" );
	self endon( stopFiringOnNotify );
	fx = getfx( "a10_shells" );

	while ( 1 )
	{
		PlayFXOnTag( fx, self, "tag_turret" );		
		wait 0.05;
	}
}


run_player_blackhawk_automated_minigun()
{
	self.mgturret[0] SetMode( "auto_nonai" );
	self.mgturret[0] StartFiring();	
	target_vol = getent( "blackhawk_minigun_target_vol", "targetname" );
	ai = GetAIArray( "axis" );
	foreach( guy in ai )
	{
		if ( IsAlive( guy ) && guy IsTouching( target_vol ) )
		{
			self SetTurretTargetEnt( guy );
			wait .5;
		}		
	}	
}

run_blackhawk_minigun()
{
	self endon( "stop_firing" );
	self ent_flag_init( "stop_firing" );
	flag_wait( "blackhawk_minigun_fire" );	
	target_vol = getent( "blackhawk_minigun_target_vol", "targetname" );
	ai = GetAIArray( "axis" );
	foreach( guy in ai )
	{
		if ( IsAlive( guy ) && guy IsTouching( target_vol ) )
		{
			self blackhawk_own_target( guy );
			wait .5;
		}		
	}
	
	default_target = getent( "blackhawk_minigun_target", "targetname" );
	self blackhawk_own_target( default_target );
}

waittill_blackhawk_minigun_finished()
{
	while ( 1 )
	{
		target_vol = getent( "blackhawk_minigun_target_vol", "targetname" );
		ai = target_vol get_ai_touching_volume( "axis" );
		if ( ai.size <= 1 )
		{
			return;	
		}
		waitframe();
	}
}


/*----------------------------------------------*/
/*------------------ SUNLIGHT ------------------*/
/*----------------------------------------------*/
update_sun()
{
	level.sun_angles_default = GetMapSunAngles(); //( -28, 10, 0 );
	level.sun_angles_intro = ( -13, -159, 0 );
	level.sun_angles_intro_deck = ( -10, 88, 0 );
	level.sun_angles_deck_combat = ( -10, 24, 0 );
	level.sun_angles_deck_tilt = ( -14, -73, 0 );
	
	LerpSunAngles(level.sun_angles_default, level.sun_angles_intro, .05 );
	intensity = 1.0;
	SetSunLight( 0.9 * intensity, 0.6 * intensity, 0 * intensity );
	SetSavedDvar( "r_diffuseColorScale" , 3.0 );
	SetSavedDvar( "r_specularcolorscale", 3.0 );
    
    flag_wait( "fb_01" );
    //ResetSunDirection();
    //ResetSunLight();
    
	flag_wait( "slow_intro_deck" );
	LerpSunAngles(level.sun_angles_default, level.sun_angles_intro_deck, .05 );
	intensity = 0.75;
	SetSavedDvar( "r_diffuseColorScale" , 0.85 );
	SetSavedDvar( "r_specularcolorscale", 0.85 );
	
	flag_wait( "slow_intro_finished" );
	LerpSunAngles(level.sun_angles_default, level.sun_angles_deck_combat, .05 );
	intensity = 0.83;
	SetSunLight( 0.85 * intensity, .77 * intensity, .6 * intensity );
	SetSavedDvar( "r_diffuseColorScale" , 2.4 );
	SetSavedDvar( "r_specularcolorscale", 3 );
    
	flag_wait( "heli_ride" );	
	LerpSunAngles(level.sun_angles_deck_combat, level.sun_angles_deck_tilt, 60, 5, 5 );
}

set_sun_post_heli_ride()
{
	waitframe(); //is this needed?
	intensity = 0.83;
	SetSunLight( .85 * intensity, .77 * intensity, .6 * intensity );
	setsaveddvar( "r_diffuseColorScale", 2.4 );
    setsaveddvar( "r_specularcolorscale", 3 );	
	LerpSunAngles(level.sun_angles_deck_combat, level.sun_angles_deck_tilt, .05 );
}

update_deck_post_intro()
{
	level.sliding_jet2 = getEnt( "sliding_jet2", "targetname" );
	level.sliding_jet2 Hide();
	
	level.sliding_jet3 = getEnt( "sliding_jet3", "targetname" );
	level.sliding_jet3 Hide();
	
	flag_wait( "slow_intro_finished" );
	
	level.sliding_jet2 Show();
	level.sliding_jet3 Show();
}


/*------------------------------------------*/
/*------------------ UTIL ------------------*/
/*------------------------------------------*/
generic_prop_raven_anim( animnode, animmodel, anime, ent1, ent2, match_angles, flag_to_wait, delete_on_end )
{
	//This is for objects attached to generic_prop_raven that play one animation and are done.
	//It handles attaching items to either joint (j_prop_1 or j_prop_2).
	//It assumes you are doing a setup and waiting for a flag to get set.
	//It does cleanup at the end of the ents and rig or just the rig.
	
	AssertEx( IsDefined( animnode )	   , "generic_prop_xmodel() - Must have an animnode defined." );
	AssertEx( IsDefined( animmodel )   , "generic_prop_xmodel() - Must have an animmodel defined." );
	AssertEx( IsDefined( anime )	   , "generic_prop_xmodel() - Must have an animation defined." );
	AssertEx( IsDefined( flag_to_wait ), "generic_prop_xmodel() - Must have an flag_wait defined." );
	
	obj1 = undefined;
	obj2 = undefined;
	
	if ( !IsDefined( match_angles ) )
	{
		match_angles = true;
	}
		
	rig = spawn_anim_model( animmodel );
	if ( IsDefined( ent1 ) )
	{
		obj1 = GetEnt( ent1, "targetname" );	
	}
	if ( IsDefined( ent2 ) )
	{
		obj2 = GetEnt( ent2, "targetname" );
	}
	
	animnode anim_first_frame_solo( rig, anime );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	j2_origin = rig GetTagOrigin( "J_prop_2" );
	j2_angles = rig GetTagAngles( "J_prop_2" );
	
	waitframe();
	
	if ( IsDefined( ent1 ) && obj1.classname == "script_model" )
	{
		obj1.origin = j1_origin;
		if ( match_angles == true )
		{
			obj1.angles = j1_angles;
		}
	}
	if ( IsDefined( ent2 ) && obj2.classname == "script_model" )
	{
		obj2.origin = j2_origin;
		if ( match_angles == true )
		{
			obj2.angles = j2_angles;
		}
	}
	
	waitframe();

	if ( IsDefined( ent1 ) )
	{
		obj1 LinkTo( rig, "J_prop_1" );
	}
	if ( IsDefined( ent2 ) )
	{
		obj2 LinkTo( rig, "J_prop_2" );
	}
	
	flag_wait( flag_to_wait );
	
	if ( IsDefined( self.script_delay ) )
	{
		wait( self.script_delay );
	}
	
	animnode anim_single_solo( rig, anime );
	
	if ( IsDefined( delete_on_end ) && delete_on_end == true )
	{
		if ( IsDefined( ent1 ) )
		{
			obj1 Delete();
		}
		if ( IsDefined( ent2 ) )
		{
			obj2 Delete();
		}
		rig Delete();
	}
	else
	{
		if ( IsDefined( ent1 ) )
		{
			obj1 Unlink();
		}
		if ( IsDefined( ent2 ) )
		{
			obj2 Unlink();
		}
		rig Delete();
	}
}

player_animate( anim_name )
{
	level.player SetStance( "stand" );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player DisableWeapons();
	level.player FreezeControls( true );		
	
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	player_rig.angles = (0, 90, 0);
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.3 );
	self anim_single_solo( player_rig, anim_name );	
	player_rig Delete();
}

spawn_animate_delete( targetname, anim_name )
{
	spawner = getent( targetname, "targetname" );
	ai = spawner spawn_ai( true, false );
	ai.animname = "generic";	
	self anim_single_solo( ai, anim_name );
	ai Delete();
}


/*----------------------------------------------------------*/
/*------------------ Temp Dialogue set up ------------------*/
/*----------------------------------------------------------*/

// temp_dialogue() - mock subtitle for a VO line not yet recorded and processed
//   <speaker>: Who is saying it?
//   <text>: What is being said?
//   <duration>: [optional] How long is to be shown? (default 4 seconds)

temp_dialogue( speaker, text, duration )
{
	level notify( "temp_dialogue", speaker, text, duration );
	level endon( "temp_dialogue" );
	
	if ( !IsDefined( duration ) )
	{
		duration = 4;
	}
	
	if ( IsDefined( level.tmp_subtitle ) )
	{
		level.tmp_subtitle Destroy();
		level.tmp_subtitle = undefined;
	}
	
	level.tmp_subtitle	 = NewHudElem();
	level.tmp_subtitle.x = -60;
	level.tmp_subtitle.y = -62;
	level.tmp_subtitle SetText( "^2" + speaker + ": ^7" + text );
	level.tmp_subtitle.fontScale   = 1.46;
	level.tmp_subtitle.alignX	   = "center";
	level.tmp_subtitle.alignY	   = "middle";
	level.tmp_subtitle.horzAlign   = "center";
	level.tmp_subtitle.vertAlign   = "bottom";
	//level.tmp_subtitle.vertAlign = "middle";
	level.tmp_subtitle.sort		   = 1;

	wait duration;

	thread temp_dialogue_fade();
}

temp_dialogue_fade()
{
	level endon( "temp_dialogue" );
	for ( alpha = 1.0; alpha > 0.0; alpha -= 0.1 )
	{
		level.tmp_subtitle.alpha = alpha;
		wait 0.05;
	}
	level.tmp_subtitle Destroy();
}




/*-------------------------------------------*/
/*------------------ BOATS ------------------*/
/*-------------------------------------------*/

spawn_zodiacs( targetname )
{
	array_spawn_function_targetname( targetname, ::zodiac_setup );
	zodiacs = spawn_vehicles_from_targetname_and_drive( targetname );
	level.zodiacs = array_combine( level.zodiacs, zodiacs );
}

zodiac_setup()
{
//	self thread zodiac_customdeath();
	self thread zodiac_treadfx();	
}

zodiac_customdeath()
{
	self waittill( "death" );
	//TODO: needs zodiac_physics to work I believe
	if ( IsDefined( self ) && cointoss() )
	{
		boatvelocity = self Vehicle_GetVelocity();
		forward		 = AnglesToForward( self.angles );
		right		 = AnglesToRight( self.angles );
		offset		 = boatvelocity * 0.15 - 12 * forward + 48 * right;
		exp_origin	 = self.origin + offset;
		PhysicsExplosionSphere ( exp_origin, 125, 120, 0.1 );		
	}
}

zodiac_treadfx()
{
	chaser = Spawn( "script_model", self.origin );
	chaser SetModel( self.model );
	chaser.angles = ( 0, self.angles[ 1 ], 0 );
	chaser thread zodiac_treadfx_chaser( self );
}

ZODIAC_TREADFX_MOVETIME = .2;
ZODIAC_TREADFX_MOVETIMEFRACTION = 1 / ( ZODIAC_TREADFX_MOVETIME + .05 );
ZODIAC_TREADFX_HEIGHTOFFSET = ( 0, 0, 16 );

zodiac_treadfx_chaser( chaseobj )
{
	// self here is the invisible boat for playing leveled wake fx.
	PlayFXOnTag( getfx( "zodiac_wake_geotrail" ), self, "tag_origin" );
	self NotSolid();
	self Hide();
	self endon( "death" );
	chaseobj endon( "death" );

	// needs to be it's own thread so can cleanup after the thing dies.
	thread zodiac_treadfx_chaser_death( chaseobj );

	chaseobj ent_flag_init( "in_air" );
	chaseobj ent_flag_init( "tread_active" );
	chaseobj ent_flag_set( "tread_active" );

	childthread zodiac_treadfx_stop_notify( chaseobj );
	childthread zodiac_treadfx_toggle( chaseobj );

	while ( IsAlive( chaseobj ) )
	{
//		self DontInterpolate();
		self MoveTo( chaseobj GetTagOrigin( "tag_origin" ) + ZODIAC_TREADFX_HEIGHTOFFSET + ( chaseobj Vehicle_GetVelocity() / ZODIAC_TREADFX_MOVETIMEFRACTION ), ZODIAC_TREADFX_MOVETIME );
		self RotateTo( ( 0, chaseobj.angles[ 1 ], 0 ), ZODIAC_TREADFX_MOVETIME ) ;
		wait ZODIAC_TREADFX_MOVETIME + .05;// + .05 to get rid of silly jiggle at the end when issueing back to back moveto's. Code bug I believe.
		waittillframeend;
	}
	self Delete();
}

zodiac_treadfx_toggle( chaseobj )
{
	chaseobj endon("death");
	active = true;
	prv_active = true;
	prv_in_air = chaseobj ent_flag( "in_air" );
	while ( 1 )
	{
		msg = chaseobj waittill_any_return( "zodiac_treadfx_stop", "zodiac_treadfx_go", "veh_leftground", "veh_landed" );
		
		if ( msg == "veh_leftground" )
			chaseobj ent_flag_set( "in_air" );
		if ( msg == "veh_landed" )
			chaseobj ent_flag_clear( "in_air" );
		if ( msg == "zodiac_treadfx_go" )
			active = true;
		if ( msg == "zodiac_treadfx_stop" )
			active = false;
		in_air = chaseobj ent_flag( "in_air" );
		
		// see if we were previously playing an fx and now we shouldn't be
		if ((prv_active && !prv_in_air) && // we should have been playing an fx
			(!active || in_air) )			// we now shouldn't be playing an fx
			StopFXOnTag( getfx( "zodiac_wake_geotrail" ), self, "tag_origin" );
		else if ((!prv_active || prv_in_air) &&	// we weren't playing an fx
				 (active && !in_air))			// and we should be playing it now
			PlayFXOnTag( getfx( "zodiac_wake_geotrail" ), self, "tag_origin" );
		prv_active = active;
		prv_in_air = in_air;
	}
}

zodiac_treadfx_stop_notify( chaseobj )
{
	chaseobj endon("death");
	while ( 1 )
	{
		vel = chaseobj Vehicle_GetVelocity();
		forward = AnglesToForward( chaseobj.angles );
		dp = VectorDot( vel, forward );
		if ( dp < -10 )
		{	// no treadfx if going in reverse
			if (chaseobj ent_flag( "tread_active" ))
				chaseobj notify( "zodiac_treadfx_stop" );
		}
		else if ( chaseobj Vehicle_GetSpeed() < 4 )
		{
			if (chaseobj ent_flag( "tread_active" ))
				chaseobj notify( "zodiac_treadfx_stop" );
		}
		else if ( ! chaseobj ent_flag( "in_air" ) )
		{
			if (chaseobj ent_flag( "tread_active" ))
				chaseobj notify( "zodiac_treadfx_go" );
		}
		wait .1;
	}
}

zodiac_treadfx_chaser_death( chaseobj )
{
	chaseobj waittill_any( "stop_bike", "death", "kill_treadfx" );
	self Delete();
}

spawn_zodiacs_rappel( targetname )
{
	array_spawn_function_targetname( targetname, ::zodiac_setup );
	array_spawn_function_targetname( targetname, ::zodiac_rappel_logic, targetname );
	zodiacs = spawn_vehicles_from_targetname_and_drive( targetname );
	level.zodiacs = array_combine( level.zodiacs, zodiacs );
}
	
zodiac_rappel_logic( targetname )
{	
	self waittill( "reached_dynamic_path_end" );
	
	foreach ( guy in self.riders )
	{
		if ( IsDefined( guy ) && isalive( guy ) )
		{
//			guy AllowedStances( "crouch", "prone", "stand" );
			guy Delete();
			thread spawn_rappel( targetname + "_rappel" );
			wait RandomFloatRange( 3, 5 );
		}
	}	
}


spawn_rappel( targetname )
{	
	spawner = getent( targetname, "targetname" );
	guy = spawner spawn_ai( true );	
	guy endon( "death" );
	
	//rope model
	ref_node = getstruct( spawner.target, "targetname" );
//	fwd = AnglesToForward( ref_node.angles );
//	right = AnglesToRight( ref_node.angles );
//	vec = fwd + right;
//	offset = ( 24 * vec[0], 20 * vec[1], -168 );
	offset = (0,0,-168);
	
	rope_model = spawn( "script_model", ref_node.origin + offset );
	rope_model SetModel( "cnd_rappel_rope" );		
	
	guy ForceTeleport( ref_node.origin, ref_node.angles );	
//drone only
//	guy.origin = ref_node.origin;
//	guy.angles = ref_node.angles;
	guy.animname = "generic";
	ref_node thread anim_single_solo( guy, "zodiac_ascend" );	
	waitframe();
	
	start_time = 0.14; //normalized (2.5 seconds)
	
	if ( IsDefined( guy.script_parameters ) && guy.script_parameters == "low" )
	{
		start_time = 0.45;	
	}
	else if ( IsDefined( guy.script_parameters ) && guy.script_parameters == "middle" )
	{
		start_time = 0.20;	
	}	
	
	guy anim_self_set_time( "zodiac_ascend", start_time );
	
	guy thread rappel_death();
	animlength = GetAnimLength( guy getanim( "zodiac_ascend" ) );
	wait animlength - start_time * animlength;
	guy notify( "end_rappel" );
	
	wait 10;
	rope_model Delete();	
}

rappel_death()
{
	self endon( "end_rappel" );
	self waittill( "damage" );
	self StopAnimScripted();
	self kill();	
}

spawn_gunboat( targetname )
{
	gunboat = spawn_vehicle_from_targetname_and_drive( targetname );
	gunboat.health = 25000;
	gunboat.currenthealth = gunboat.health;
	level.gunboats = array_add( level.gunboats, gunboat );
}







/*--------------------------------------------------*/
/*------------------ VEHICLE UTIL ------------------*/
/*--------------------------------------------------*/
vehicles_loop_until_endon( targetname, endon_flag, min_delay, max_delay )
{
	level endon( endon_flag );
	while(1)
	{
		vehicles = spawn_vehicles_from_targetname_and_drive( targetname );
		//all vehicle reached end
		foreach ( vehicle in vehicles )
		{
			if ( IsDefined( vehicle ) && IsAlive( vehicle ) )
			{
				vehicle waittill_any( "reached_dynamic_path_end", "death" );
			}
		}
		
		if ( !IsDefined( min_delay ) )
		{
			min_delay = 3;
		}
		if ( !IsDefined( max_delay ) )
		{
			max_delay = 7;
		}		
		wait RandomFloatRange( min_delay, max_delay );
	}
}

vehicle_randomly_explode_after_duration( chance, min_delay, max_delay )
{
	self endon( "death" );
	
	if ( !IsDefined( chance ) )
	{
		chance = 10;
	}	
	
	if ( RandomInt( 100 ) > chance )
	{
		return;	
	}
	
	if ( !IsDefined( min_delay ) )
	{
		min_delay = 10;
	}
	if ( !IsDefined( max_delay ) )
	{
		max_delay = 20;
	}		
	wait RandomFloatRange( min_delay, max_delay );
	self vehicle_kill_carrier();
}

vehicle_kill_carrier()
{
	//blow up
	if ( IsDefined( self.vehicletype ) && self isHelicopter() )
	{	
		self kill();
	}
	else if ( IsDefined( self.vehicletype ) && self isAirplane() )
	{
		self notify( "damage", 5000, level.player, (0,0,0), (0,0,0), "MOD_PROJECTILE" );
	}	
}

heli_fast_explode( chance_override )
{	
	if ( self isVehicle() && self isHelicopter() && ( ( IsDefined( self.script_parameters ) && self.script_parameters == "fast_explode" ) || ( IsDefined( chance_override ) && RandomInt( 100 ) <= chance_override ) ) )
	{
		self waittill( "death" );
		if (IsDefined(self))
		{
			PlayFX( getfx( "aerial_explosion_hind_woodland" ), self.origin, AnglesToForward( self.angles ) );
			self Delete();
		}
	}
}

drone_delete_on_unload()
{
	if ( IsDefined( self.riders ) )
	{
		foreach ( guy in self.riders )
		{
			guy.drone_delete_on_unload = true;
		}
	}
}

//track_fly_in_progress( fly_in_progress, fly_in_progress_target, fly_in_progress_dist )
//{
//
//	if ( self != level.player_blackhawk )
//	{
//		thread modify_speed_to_match_player_heli( fly_in_progress_dist );
//	}
//
//	self.start_dif = 0;
//	for ( ;; )
//	{
//		progress_array = get_progression_between_points( self.origin, fly_in_progress.origin, fly_in_progress_target.origin );
//		self.progress = progress_array[ "progress" ];
//		//Print3d( self.origin + (0,0,32), self.progress + " " + self.start_dif, (1,0.5,1), 1, 2 );
//		wait( 0.05 );
//	}
//}
//
//modify_speed_to_match_player_heli( fly_in_progress_dist )
//{
//	max_speed = 80;
//	min_speed = 70;
//	min_units = -125;
//	max_units = 125;
//
//	range_speed = max_speed - min_speed;
//	range_units = max_units - min_units;
//
//	waittillframeend;// wait for all progressess to get set once at least
//
//	start_dif = self.progress - level.player_blackhawk.progress;
//	start_dif *= 5;
//	self.start_dif = start_dif;
//
//	for ( ;; )
//	{
//		my_progress = self.progress - start_dif;
//		my_progress -= 50;
//		// dif is the difference in units of progress between player and me
//		dif = level.player_blackhawk.progress - my_progress;
//
//		if ( dif < min_units )
//			dif = min_units;
//		else
//		if ( dif > max_units )
//			dif = max_units;
//
//		dif += min_units * -1;
//
//		speed = dif * range_speed / range_units;
//		speed += min_speed;
//		speed += RandomFloat( 4 ) - 2;
//		//assert( speed <= max_speed && speed >= min_speed );
////		our_units	x
////		range_units	range_speed
//
//		self Vehicle_SetSpeed( speed, 15, 15 );
//		wait( 0.05 );
//	}
//}






/*-------------------------------------------*/
/*------------------ DEBUG ------------------*/
/*-------------------------------------------*/
/#
run_debug()
{
	thread show_ai_health();
}
show_ai_health()
{
	SetDevDvarIfUninitialized( "show_ai_health", 0 );
	while(1)
	{
		dvar_value = getDebugDvarInt( "show_ai_health" );
		if(dvar_value == 0)
		{
			level notify("stop_ai_show_health");
			wait .25;
			continue;
		}
		
		player = level.players[0];
		ai_array = GetAIArray( "axis" );

		for(i=0;i<ai_array.size;i++)
		{
			ai = ai_array[i];
			
			ai thread ai_record_damage_history();
			
			text = "" + ai.health + "/" + ai.maxhealth;
			
			right = anglestoright(player.angles);
			right = -1 * right * ((text.size / 2) * 8); //Roughly center text
			up = (0,0,70);
			
			color = (0,1,0); //Green
			historySize = ai.damageHistory.size;
			if(historySize>0 && ai.damageHistory[historySize-1].time+1000>GetTime())
			{
				color = (1,0,0); //red
			}

			print3d( ai.origin+right+up, text, color, 1, .75 );
			
			//Print damage history
			k=0;
			for(j=ai.damageHistory.size-1; j>=0 && k<dvar_value-1; j--)
			{
				up = up + (0,0,-10);
				print3d( ai.origin+right+up, ai.damageHistory[j].text, color, 1, .75 );
				k++;
			}
		
			
		}
		wait( 0.05 );
	}
}

ai_record_damage_history()
{
	level endon("stop_ai_show_health");
	self endon("death");
	
	if(IsDefined(self.record_damage_time_active) && self.record_damage_time_active)
	{
		return;
	}
	
	self.damageHistory = [];
	self.record_damage_time_active = true;
	while(1)
	{
		self waittill("damage", damage, attacker, direction, point, type );
		
		s 			= spawnStruct();
		s.time 		= GetTime();
		s.damage 	= damage;
		s.attacker	= attacker;
		s.type		= type;
		if(IsDefined(self.damageLocation))
		{
			s.loc		= self.damageLocation;
			s.text		= "-" + damage + " " + self.damageLocation + " " + type;
		}
		s.text		= "-" + damage + " " + type;
		
		self.damageHistory[self.damageHistory.size] = s;
	}
}
#/