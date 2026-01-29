#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;
#include maps\_stealth_utility;

cull_distance_logic()
{
	switch ( level.start_point )
	{
		case "default":
		case"jungle_corridor":
		case "parachute":
		case "e3":	
			SetCullDist( 3000 );
			
			flag_wait("jungle_entrance");			
			SetCullDist( 4000 );
			
			flag_wait("hill_pos_1");	
			
		case "jungle_hill":
			
			SetCullDist( 13000 );	
			
			//back to infinite cull at waterfall rescue
			flag_wait_any("waterfall_approach", "e3_warp");
			SetCullDist(0);
				
	}

}

game_is_PC()
{
	//level.ps3 level.ps4 level.xb3 level.xenon
	if( level.xenon )
		return false;
	if( level.ps3 )
		return false;
	if( level.ps4 )
		return false;
	if( level.xb3 )
		return false;
	
	return true;
}

stream_waterfx( endflag, soundalias )
{
// currently using these devraw fx:
//	level._effect[ "water_stop" ]						= LoadFX( "fx/misc/parabolic_water_stand" );
//	level._effect[ "water_movement" ]					= LoadFX( "fx/misc/parabolic_water_movement" );

	self endon( "death" );

	play_sound = false;
	if ( IsDefined( soundalias ) )
		play_sound = true;

	if ( IsDefined( endflag ) )
	{
		flag_assert( endflag );
		level endon( endflag );
	}
	for ( ;; )
	{
		wait( RandomFloatRange( 0.15, 0.3 ) );
		start = self.origin + ( 0, 0, 150 );
		end = self.origin - ( 0, 0, 150 );
		trace = BulletTrace( start, end, false, undefined );
		if ( trace[ "surfacetype" ] != "water"  )
			continue;

		fx = "water_movement";
		
		if ( IsPlayer( self ) )
		{
			if ( Distance( self GetVelocity(), ( 0, 0, 0 ) ) < 5 )
			{
				fx = "water_stop";
			}
		}
		else if ( IsDefined( level._effect[ "water_" + self.a.movement ] ) )
		{
			fx = "water_" + self.a.movement;
		}

		water_fx = getfx( fx );
		start = trace[ "position" ];
		//angles = vectortoangles( trace[ "normal" ] );
		angles = (0,self.angles[1],0);
		forward = anglestoforward( angles );
		up = anglestoup( angles );
		PlayFX( water_fx, start, up, forward );
		
		if ( fx != "water_stop" && play_sound )
			thread play_sound_in_space( soundalias, start );
	}
}

player_leaps( trig, jump_forward, goodDot, checkIsOnGround )
{
	if( !IsDefined( goodDot ) )
	{
		goodDot = 0.965;
	}
	
	if( !IsDefined( checkIsOnGround ) )
	{
		checkIsOnGround = true;
	}
	
	if( !level.player IsTouching( trig ) )
	{
		return false;
	}
	
	if ( level.player GetStance() != "stand" )
	{
		return false;
	}
	
	if( checkIsOnGround && level.player IsOnGround() )
	{
		return false;
	}

	// gotta jump straight
	player_angles = level.player GetPlayerAngles();
	player_angles = ( 0, player_angles[ 1 ], 0 );
	player_forward = anglestoforward( player_angles );
	dot = vectordot( player_forward, jump_forward );
	if ( dot < goodDot )
	{
		return false;
	}

	vel = level.player GetVelocity();
	// figure out the length of the vector to get the speed (distance from world center = length)
	velocity = Distance( ( vel[ 0 ], vel[ 1 ], 0 ), ( 0, 0, 0 ) );  // don't care about Z velocity
	if ( velocity < 162 )
	{
		return false;
	}

	//level.player setVelocity( ( vel[ 0 ] * 1.5, vel[ 1 ] * 1.5, vel[ 2 ] ) );
	return true;
}

player_jump_watcher()
{
	level endon( "player_jump_watcher_stop" );
	
	jumpflag = "player_jumping";
	if( !flag_exist( jumpflag ) )
	{
		flag_init( jumpflag );
	}
	else
	{
		flag_clear( jumpflag );
	}
	
	NotifyOnCommand( "playerjump", "+gostand" );
	NotifyOnCommand( "playerjump", "+moveup" );
	
	while( 1 )
	{
		level.player waittill( "playerjump" );
		level.player SetClientTriggerAudioZone( "jungle_ghosts_escape_jump", 0.5 );		
		wait( 0.1 );  // jumps don't happen immediately
		
		if( !level.player IsOnGround() )
		{
			flag_set( jumpflag );
			println( "jumping" );
		}
		
		while( !level.player IsOnGround() )
		{
			wait( 0.05 );
		}
		flag_clear( jumpflag );
		println( "not jumping" );
	}
}

bigjump_player_blend_to_anim( player_rig )
{
	wait( 0.3 );
//	Print3d( level.player.origin, "x", (1,1,1), 1, 2, 500 );
//	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.6, 0.2, 0.4 );
//	level.player PlayerLinkToDelta(player_rig, "tag_player", 0, 25, 25, 15, 90, 0);
	
	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.6, 0.2, 0.2 );
	wait( 0.5 );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0 );
	time = 4;
	level.player LerpViewAngleClamp( 2, 0, 0, 35, 35, 30, 40 );
}

player_has_weapon_with_ammo( weapon )
{
	guns = level.player GetWeaponsList("primary");
	if( guns.size )
	{
		foreach( gun in guns )
		{
			if( gun == weapon )
			{
				if( player_has_ammo( weapon )!= 0 )
				{
					return true;					
				}
			}
		}
	}
	
	return false;
}

player_has_ammo( weapon )
{
	ammo = level.player GetWeaponAmmoClip( weapon );
	if( ammo != 0 )
		return ammo;
	
	ammo = level.player GetWeaponAmmoStock( weapon );
	if( ammo != 0 )
		return ammo;
	
	return 0;	
}

do_bokeh( _endon, bokeh_fx, duration, wait_min, wait_max )
{
	//stop existing instances of this func
	level.player notify( "stop_bokeh" );
	level.player endon( "stop_bokeh" );
	
	if( isdefined( _endon ) )
	{
	   level endon( _endon );
	}
	   
	if( isdefined( duration ) )
	{
		level.player thread notify_delay( "stop_bokeh", duration );
	}

	if( !isdefined( wait_min ) )
	{
		wait_min = 5;
	}

	if( !isdefined( wait_max ) )
	{
		wait_max = 7;
	}

	
	//spawn and link tag_origin at players face
	if(!IsDefined( level.player.bokeh_ent ) )
	{
		_fwd = AnglesToForward( level.player.angles);
		spot = level.player.origin + (_fwd * 60 );
		eye_height = level.player geteye();
		level.player.bokeh_ent = spawn( "script_model", spot  );
		level.player.bokeh_ent setmodel("tag_origin");
		level.player.bokeh_ent LinkToPlayerView( level.player, "tag_origin", (5, 0, 0), (0,0,0), true );
	//	level.player.bokeh_ent thread Print3d_on_me( "!" );
	//	thread draw_line_from_ent_to_ent_for_time(level.player, level.player.bokeh_ent, 1, 0, 0, 60);
	}
	
	//default fx if none specified	
	if(!isdefined( bokeh_fx ) )
		bokeh_fx = "vfx_atmos_bokeh_jungle";
	
	while(1)
	{
		//IPrintLn( "bokeh on player" );
		PlayFXOnTag( getfx( bokeh_fx ), level.player.bokeh_ent, "tag_origin" );
		wait( randomfloatrange( wait_min, wait_max ) );
	}

}

get_spot_in_front_of_player( dist )
{
	angles = level.player getplayerangles();
	angles = ( 0, angles[1], 0 );
	fwd = anglestoforward( angles );

	front = (fwd) * dist;
	spot = level.player.origin + front;
	return spot;	
}

player_is_surrounded()
{
	guys = getaiarray("axis");
	min_dist = 1500*1500;
	guys_in_front = 0;
	guys_behind = 0;
	
	foreach( guy in guys )
	{
	    spotangles = anglestoforward( guy.angles );
	    othervec = VectorNormalize( guy.origin - level.player.origin );
	    dot = VectorDot( spotangles, othervec );
	    dist = DistanceSquared( guy.origin, level.player.origin );
	    
	    if( dist < min_dist )
	    {
		    if( dot > 0  )
		        //iprintln( "behind" );
		    	guys_behind = 1;
		    else
		       // iprintln( "infront" );
		   		guys_in_front = 1;
		    
		    if( guys_behind == 1 && guys_in_front == 1 )
		    	return true;
	    }
	}
	
	return false;	
}

set_flag_on_notify( notification, the_flag )	
{
	self waittill ( notification );
	if( !flag( the_flag ) )
		flag_set( the_flag );	
}


squad_does_water_run()
{
	num = 1;
	foreach ( guy in level.squad )
	{
		runanim = "water_run_";
		guy set_generic_run_anim( runanim + num, true );
		num++;
		if( num > 2 )
			num = 1;
	}	
}

squad_does_water_walk()
{
	num = 1;
	foreach ( guy in level.squad )
	{
		runanim = "water_walk_";
		guy set_generic_run_anim( runanim + num, true );
		num++;
		if( num > 2 )
			num = 1;
	}	
}

kill_me_from_closest_enemy()
{
	self endon( "death" );
	guys = GetAIArray( "allies" );
	guys = SortByDistance( guys, self.origin);
	
	wait randomFloatrange( .5, 2.5 );
	foreach( guy in guys )
	{
		if( BulletTracePassed( guy gettagorigin( "tag_flash" ), self geteye(), true, self ) )
		{
			magicbullet( "ak47", guy gettagorigin( "tag_flash" ), self geteye() );
			self die();
			return;
		}		
	}
	
	if( IsAlive( self ) )
		self die();	
}

kill_player_from_closest_enemy()
{
	//*hangs head in shame*
	
	level.player endon( "death" );
	guys = GetAIArray( "axis" );
	guys = SortByDistance( guys, level.player.origin);
	
	foreach( guy in guys )
	{
		if( BulletTracePassed( guy gettagorigin( "tag_flash" ), level.player geteye(), true, level.player ) )
		{
			magicbullet( "ak47", guy gettagorigin( "tag_flash" ), level.player geteye() );
			wait .10;
			level.player die();
			return;
		}		
	}
	
	if( IsAlive( level.player ) )
		level.player die();	
}


stream_trig_logic()
{
	level endon( "tall_grass_begin" );
	
	while ( 1 )
	{
		if( level.player IsTouching( self ) )
		{			
			level.player AllowProne( false );			
		}	
		else
		{
			level.player AllowProne( true );	
		}
		wait .05;			
	}
	
}

escape_earthquake_on_missile_impact()
{
	//self - missile
	while( isdefined( self ) )
		wait .05;
	
	earthquake( .3, .5, level.player.origin, 300 );
	
}


set_flag_when_x_remain(  guys, amount, the_flag )
{
	level endon( the_flag );
	
	while( guys.size > amount )
	{
		guys = array_removeDead_or_dying( guys );
		if( guys.size == 1 )
			if( !isdefined( guys[0].imminent_death ) )
				guys[0] thread timeout_death( 10 );
		
		wait 1;
	}
	
	if( !flag( the_flag ) )
		flag_set( the_flag );	
}

timeout_death( time )
{
	self endon("death");
	if( isdefined( self.imminent_death ) )
		return;
	
	self.imminent_death = 1;
	
	wait time;
	
	self thread kill_me_from_closest_enemy();	
}

start_raining()
{
	if(!isdefined( level.rain_effect ) )
		level.rain_effect = getfx( "rain_light" );
	
	level endon( "stop_rain");
	
	while( 1 )
	{
		PlayFX( level.rain_effect, level.player.origin + (0,0,1024) );
		wait( 1.0/3.0 );
	}		
}

thunder_and_lightning( min_time, max_time )
{
	//stop existing instances
	level notify("stop_lighning");
	level endon("stop_lighning");
	
	while(1)
	{
		do_lightning();
		wait( randomintrange( min_time, max_time ) );		
	}
}

do_lightning()
{
	if( flag("doing_lightning" ) )
		return;
	
	flag_set("doing_lightning");
	fwd = AnglesToForward( level.player.angles );
	up = AnglesToUp( level.player.angles );
	current_sunlight = GetMapSunLight();
	
	playfx( getfx( "lightning" ), level.player.origin, fwd, up );
	SetSunLight( 2, 2, 2 );
	wait(.25 );
	SetSunLight( current_sunlight[0], current_sunlight[1], current_sunlight[2] );//todo next gen sun settings for flash
	
	wait( RandomFloatRange( .5, 1 ) );
	level.player thread play_sound_on_entity("thunder_strike") ;
	
	flag_clear("doing_lightning");	
}


manually_alert_me()
{
	self maps\_stealth_shared_utilities::group_flag_set( "_stealth_spotted" );
}

blend_wind_setting_internal( new_val, dvar )
{
	
	current_val = GetDvarFloat( dvar, 0 ); //return 0 if undefined
	
	if( current_val == new_val )
		return;
	
	//need to increase the value ?
	if( new_val > current_val )
	{
		//while new_val is LESS, blend current_val UP to the new_val
		while( new_val >= current_val )
		{
			current_val +=.02;
			//IPrintLn( "increasing " +dvar+  " to " +current_val );
			SetSavedDvar( dvar, current_val );
			wait.05;
		}		
		//IPrintLn( "done blending " +dvar );
	}
	//need to decrease value ?
	else if( new_val < current_val )
	{
		//while new_val is MORE, blend current_val DOWN to the new_val
		while( new_val <= current_val )
		{
			current_val -=.02;
			//IPrintLn( "decreasing " +dvar+  " to " +current_val );
			SetSavedDvar( dvar, current_val );
			wait.05;
		}		
		//IPrintLn( "done blending " +dvar );
	}
		
}

has_script_noteworthy( noteworthy )
{
	if( ! isdefined( self.script_noteworthy ) )
		return false;
	if( self.script_noteworthy != noteworthy )
		return false;
	
	return true;	
}

has_script_parameters( parameter )
{
	if( !isdefined( self.script_parameters ) )
		return false;
	if( self.script_parameters != parameter )
		return false;
	
	return true;	
}

adjust_moving_grass( WindStrength, WindAreaScale, WindAmplitudeScale, WindFrequencyScale )
{
	if( isdefined( WindAreaScale ) )
		SetSavedDvar( "r_reactiveMotionWindAreaScale", WindAreaScale );
	
	if( isdefined( WindStrength ) )
		thread blend_wind_setting_internal( WindStrength, "r_reactiveMotionWindStrength" );
	
	if( isdefined( WindAmplitudeScale ) )
		thread blend_wind_setting_internal( WindAmplitudeScale, "r_reactiveMotionWindAmplitudeScale" );
	
	if( isdefined( WindFrequencyScale ) )
		thread blend_wind_setting_internal( WindFrequencyScale, "r_reactiveMotionWindFrequencyScale" );

}

stealth_ai_idle( guy, idle_anim, tag, no_gravity )
{	
	if ( IsDefined( no_gravity ) )
		AssertEx( no_gravity, "no_gravity must be true or undefined" );
	
	guy stealth_insure_enabled();

	spotted_flag = guy maps\_stealth_shared_utilities::group_get_flagname( "_stealth_spotted" );

	if ( flag( spotted_flag ) )
		return;

	ender = "stop_loop";

	guy.allowdeath = true;
	
	if( !isdefined( no_gravity ) )
		self thread maps\_anim::anim_generic_custom_animmode_loop( guy, "gravity", idle_anim, tag );
	else
		self thread maps\_anim::anim_generic_loop( guy, idle_anim, tag );
		
	//guy maps\_stealth_shared_utilities::ai_set_custom_animation_reaction( self, reaction_anim, tag, ender );

	self add_wait( ::waittill_msg, "stop_idle_proc" );
	self add_func( ::stealth_ai_clear_custom_idle_and_react );
	
	self thread do_wait_thread();
}

arm_player( weapons, nades, attach_motiontracker )
{
	level.player TakeAllWeapons();
	foreach( gun in weapons )
	{
		level.player GiveWeapon( gun );	
		level.player GiveMaxAmmo( gun );
	}
	
	level.player SwitchToWeapon( weapons[0] );
	
	if(IsDefined( nades ) )
		level.player GiveWeapon( "fraggrenade" );
	
}

fail_trig_logic( _endon, optional_fail_string )
{
	level endon(_endon );	
	self waittill( "trigger" );
	wait 1;
	
	if( isdefined( optional_fail_string ) )
		string = optional_fail_string;
	else 
		string =  &"JUNGLE_GHOSTS_FAIL_LEFT_SQUAD"; //"UCMJ ARTICLE 86: Do not abondon your squad or mission."
	
	level notify( "new_quote_string" );
	setdvar( "ui_deadquote", string );	
	
	MissionFailedWrapper();
           
}


first_guy_leap_frog_logic()
{
	//self = enemy
	self endon("death");	
	self notify ("go_to_new_volume");	
	wait(.5); //time to get new node assigned
	self.ignoreme = true;
	self endon("go_to_new_volume");	
	half_way = undefined;
	my_goal = undefined;
	
	//store where the enemy is going to and get the halfway point
	if( isdefined( self.node ) )
	{
		half_way = distance(self.origin, self.node.origin) *.5;	
		my_goal = self.node.origin;
	}
	else if( isdefined( self.goalpos ) )	
	{
		half_way = distance(self.origin, self.goalpos) *.5;	
		my_goal = self.goalpos;
	}
	
	assertex( isdefined( half_way ), "Enemy has no goalnode or goalpos to calculate halfway point from" );	 		
	
	//wait for enemy to get to halfway point
	while( distance( self.origin, my_goal ) > half_way )
	{
		wait(.5);	
	}	
	
	//Clear his current goal
	self cleargoalvolume();	

	//stay put!
	self.goalradius = 200;
	//spot = self.origin +( 1, 1, 0 );
	self.old_fightdist = self.pathenemyfightdist;
	self.pathenemyfightdist = 8;
	self setgoalpos( self.origin );
	self allowedstances( "crouch" );
	self thread Print3d_on_me( "Covering Fire!" );
	
	//camp for a bit
	wait( randomintrange( 8, 14 ) );
	
	//get back and go to the volume
	self.pathenemyfightdist = self.old_fightdist;
	self.ignoreme = false;
	self notify( "stop_print3d_on_ent" );
	self allowedstances("stand", "crouch", "prone" );
	self setgoalvolumeauto( level.current_enemy_vol );
}	

move_player_to_start( struct_targetname )
{
	assert( isdefined( struct_targetname ) );
	start = getstruct( struct_targetname, "targetname" );
	
	if(!isdefined( start ) )
	{
			start = getent( struct_targetname, "targetname" );
			if(!isdefined( start ) )
				return;			
	}
		
	level.player SetOrigin( start.origin );
	
	lookat = undefined;
	if ( isdefined( start.target ) )
	{
		lookat = getent( start.target, "targetname" );
		assert( isdefined( lookat ) );
	}
	
	if ( isdefined( lookat ) )
		level.player setPlayerAngles( vectorToAngles( lookat.origin - start.origin ) );
	else
		level.player setPlayerAngles( start.angles );
	wait(.10);
}

grenade_ammo_probability( num )	
{
	//self = ai
	self endon ("death");
	if( randomint( 100 ) > num )
	{
		self.grenadeammo = 0;
	}
}		


make_array_hud_targets(array, shader, _ender )
{
	foreach( ent in array)
	{
		if( isdefined( ent.targetname ) && !isdefined( ent.classname ) ) //is a struct 
		{
			ent = spawn("script_model", ent.origin );
			ent setmodel( "tag_origin" );
		}	
			
		Target_Set( ent );
		Target_SetShader( ent, shader );
		wait(.05);
	}	

}	

remove_hud_targets( array )
{
	foreach( ent in array)
	{
		Target_Remove( ent );
		wait(.05);
	}
}		    

spawn_player_ai_on_player( spawner )
{
	guy = spawner stalingradspawn();
	wait(.05);
	guy spawn_failed();
	guy hide();
	guy ForceTeleport( level.player.origin, level.player getplayerangles() );
	guy.ignoreall = 1;
	guy.ignoreall= 1;	
	wait(.10);
	guy show();
	
	return guy;	
}	



//MikeD Steez
Print3d_on_me( msg ) 
 { 
 /# 
	self endon( "death" );  
	self endon("go_to_new_volume");	
	self notify( "stop_print3d_on_ent" );  
	self endon( "stop_print3d_on_ent" );  
	while( 1 ) 
	{ 
		print3d( self.origin + ( 0, 0, 40 ), msg );  
		wait( 0.05 );  
	} 
 #/ 
 }

player_visibility_debug()
{
	self.saw_player = 0;
	while( 1 )
	{
		if( self cansee( level.player ) && self.saw_player == 0  )
		{
			self thread print3d_on_me( "!" );
			self.saw_player =1;
		}
		else 
		{
			self notify( "stop_print3d_on_ent" );	
			self.saw_player = 0;
		}
		wait.05;
	}			
}

get_world_relative_offset( origin, angles, offset )
{
	cos_yaw = cos( angles[ 1 ] );
	sin_yaw = sin( angles[ 1 ] );

	// Rotate offset by yaw
	x = ( offset[ 0 ] * cos_yaw ) - ( offset[ 1 ] * sin_yaw );
	y = ( offset[ 0 ] * sin_yaw ) + ( offset[ 1 ] * cos_yaw );

	// Translate to world position
	x += origin[ 0 ];
	y += origin[ 1 ];
	return ( x, y, origin[ 2 ] + offset[ 2 ] );
}

restore_player_weapons()
{	
	level.player takeallweapons();
	
	foreach(weapon in level.current_player_loadout)
	{	
		if (issubstr( tolower( weapon ), "alt_" ) )
		{			
			//if its the 203, only give ammo, dont actually give the weapon.
			println("Giving altweapon ammo for:"  +weapon);
			level.player setweaponammoclip( weapon, 1 );
			level.player setweaponammostock( weapon, 2);
			continue;
		}
		else
		{
			//otherwsise give the weapon and fill the ammo
			println("Giving weapon and max ammo for:"  +weapon);
			level.player giveWeapon(weapon);	
			level.player givemaxammo(weapon);		
		}			 
	}	
		
	primaryweapons = level.player GetWeaponsListPrimaries();	
	level.player switchtoweapon(primaryweapons[0]);
}

fade_out_in( fade_color, fadeup_notify, time, time_to_fade )
{
	overlay = newHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay setshader( fade_color, 640, 480 );//"black", "white"
	overlay.alignX = "left";
	overlay.alignY = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha = 1;
	overlay.sort = -2;

	if(isdefined( fadeup_notify ) )
	{
		level waittill( fadeup_notify );
	}
	else
	{	
		wait( time );
	}	

	if (!isdefined(time_to_fade))
	{ 
		time_to_fade = 0.5;
	}
	
	overlay fadeOverTime( time_to_fade );
	overlay.alpha = 0;	
	wait(1);

	overlay destroy();
}

uav_hud_elem_destroy( hudelem )
{
	time = .5;
	hudelem FadeOverTime( time );
	hudelem.alpha = 0;
	wait time;
	hudelem notify( "destroy" );
	hudelem Destroy();
}

flush_current_targets()
{	
	current_targets = target_getarray();
	{
		foreach( target in current_targets )
		{
			target_remove( target );
		}
	}
}

	

Array_spawn_return_when_X_remain( spawners, amount )
{
	baddies = array_spawn( spawners, 1, 1 );
	wait(.10);
	
	while( baddies.size > amount )
	{
		baddies = array_removedead_or_dying( baddies );
		wait(1);
	}		
	//iprintln( "dudes are dead" );
	return;
	
}	

play_generic_anim_off_me(actor, optitonal_delay, shorten, shorten_amount)
{
	//self = script_origin;
	//scene = script_noteworthy on ent
	if ( IsDefined( optitonal_delay ) )
	{
		wait ( optitonal_delay );
	}	
	
	scene = self.script_noteworthy;
	wait( 0.05 );
	actor Show();
	if ( IsDefined( shorten ) )
	{
		self thread anim_single_solo( actor, scene, undefined, undefined, "generic" );
		wait(.05);
		actor anim_self_set_time( scene, shorten_amount);
	}		
	else
	{
		self anim_single_solo( actor, scene, undefined, undefined, "generic"  );
	}
	
	if( IsDefined( actor.old_animname ) )
	{
		actor.animname = actor.old_animname;
	}

}

play_looping_anim_off_me( spawner, anim_name )
{
	actor = spawner stalingradspawn();
	actor.animname = anim_name;
	actor hide();
	scene = self.script_noteworthy;
	self thread anim_loop_solo (actor, scene);
	actor show();
	return actor;	
}

#using_animtree("generic_human");
create_pipcam_on_ent(ent, shoulder_cam, optional_offset )
{	
	level.scr_anim[ "generic" ][ "setup_pose" ] 		= %casual_stand_idle;
	
	//if ent is an actual ai, setup the cam pos with proper offset	
	if(issentient(ent))
	{
		//put guy in generic pose while attaching the cam to him
		ent.current_animname = ent.animname;		
		ent.animname = "generic";
		ent maps\_anim::anim_first_frame_solo(ent, "setup_pose");
				
		if(!isDefined (shoulder_cam) )
		{
			//PSUEDO FIRST-PERSON POV:
			spot = get_world_relative_offset(ent.origin, ent.angles, (12, 0, 0) );	
			eye = ent geteye();
			cam = spawn ("script_model", (spot[0], spot[1], eye[2]) );	
			cam setmodel ("tag_origin");
			cam.angles = ent.angles;
			cam linkto(ent, "j_neck" );//j_head		
		}
		else
		{
			// SHOULDER CAM 
			offset = (-14, -17, 63);
			spot = get_world_relative_offset(ent.origin, ent.angles, offset);	
			cam = spawn ("script_model", spot );
			cam setmodel ("tag_origin");
			cam.angles = ent.angles +(0, 26, 0); //roate towards him a tad
			cam linkto(ent, "j_neck" );//j_head			
		}	
		
		//finish anim and release him back intot he wILD
		ent thread maps\_anim::anim_single_solo ( ent, "setup_pose" );
		ent delaycall(.05, ::setanimtime, %casual_stand_idle, .99);
		
		ent.animname = ent.current_animnam;	
	}		
	// ent is just a static ent
	else
	{
		//use offset param if passed in
		if(isdefined(optional_offset))
		{
			spot = ent.origin + optional_offset;
			cam = spawn ("script_model", spot);
		}
		//else spawn at origin of ent
		else 
		{
			cam = spawn ("script_model", ent.origin);
		}		
		cam setmodel ("tag_origin");
		cam.angles = ent.angles;	
		cam linkto(ent);		
	}
	
	return cam;
	
}	

#using_animtree( "generic_human" );
play_hand_signal_for_player()
{		
	self.did_handsignal = undefined;
	
	//self = trig
			
	self waittill("trigger");
			
	if( isdefined( self.did_handsignal ) )
		return;
	
	//make sure we're not already running this func from another trig
	if( isdefined ( level.doing_hand_signal ) && level.doing_hand_signal )
	{
		return;
	}
	else
	{
		level.doing_hand_signal = 1;
	}
	
	self.did_handsignal = 1;
	
	allies = getaiarray( "allies" );
	
	if( allies.size == 0 )
		return;
	
	closest_guy = get_closest_to_player_view( allies, level.player, 1 );
			
	closest_guy disable_ai_color();
	closest_guy do_hand_signal();
	closest_guy enable_ai_color();
	
	wait( 5 );
	
	level.doing_hand_signal = 0;
	
}

notify_end_of_scripting()
{
	baddies = GetAIArray( "axis" );
	
	while( baddies.size > 0 )
	{
		baddies = remove_dead_from_array( baddies );
		wait( 2 );
	}
	IPrintLnBold( "end of scripting" );	
}

do_hand_signal()
{
	//cover node
	if( isdefined( self.node )  )
	{
		node_type = self.node.type;	
		
		//COVER RIGHT
		if( ToLower( node_type) == "cover right" )
		{			
			hand_signal =  "signal_enemy_coverR";//signal_enemy_coverR signal_onme_coverR	
		}
		//COVER LEFT
		else if( ToLower( node_type) == "cover left")
		{
			hand_signal =  "signal_moveout_coverL";
		}
				
		//STAND
		else
		{
			hand_signal = "signal_go";	
		}
	}
		
	//CQB
	else 
	{	
		hand_signal =  "signal_onme_cqb";
	}
	

	//store current animname 
	if( isdefined( self.animname ) )
	{	
		if( self.animname != "generic" )
		{
			self.old_animname = self.animname;
		}		
	}
	
	//assign generic animname
	self.animname = "generic";
		
	//pause color_chain stuff, play anim, resume color _chain stuff
	//thread draw_line_from_ent_to_ent_for_time( closest_guy, level.player, 1, 0, 0, 3 );
		
	self anim_single_solo( self, hand_signal );	

	//restore old animname
	if(isdefined( self.old_animname ) )
	{
		self.animname = self.old_animname;
	}
}
	
delete_ai_array_safe( array )
{
	if( isdefined( array ) )
	{
		array = array_removeDead_or_dying( array );
		//IPrintLn( "deleting AI array of " +array.size );
		foreach(ent in array)
		{
			if (isdefined_and_alive(ent))
			{	
				ent notify("deleted");
				wait(.05);
				ent delete();
			}
		}
		//array_delete( array );	
		array = undefined;		
	}
}
	
origin_is_below_player( _origin )
{ 
	diff =  abs( level.player.origin[2] - _origin[2] );
	//IPrintLn( "height diff is " +diff );
	if ( diff >= 75 )
	{
		//IPrintLn( "friendly goalpos is too far down" );
		return true;
	}	
	return false;	
}
				
ent_is_close_to_enemy( _origin, optional_distance )
{
	if ( !IsDefined( optional_distance ) )		
	{
		optional_distance = 160 * 160;	
	}
	
	baddies = GetAIArray( "axis" );
	foreach ( guy in baddies )
	{
		dist =  DistanceSquared(_origin, guy.origin);
		if (dist <= optional_distance ) 
		{
			return guy;
		}		
	}	
	return undefined;	
}

isdefined_and_alive( ent )
{
	if ( !IsDefined( ent ) )
	{
		return false;
	}

	if ( !IsAlive( ent ) )
	{
		return false;
	}
	
	if( !ent isVehicle() )
	{
		if ( ent doinglongdeath() )
		{
			return false;
		}
	}

	return true;
}

delete_if_player_cant_see_me()
{
	if(!isdefined_and_alive( self ) )
		return;
	
	while( player_can_see_ai( self ) )
	{
		//IPrintLn( "Cant delete AI, player can see him!" );
		wait(.15);
	}

	self delete();
	
}


get_ai_by_noteworthy( noteworthy )
{
	//used to filter out spawner
	//intended to be used with one instance of the ai 
	ents = getentarray( noteworthy, "script_noteworthy" );
	foreach( ent in ents )
	{
		if( IsAI( ent ) )
		   return ent;
	}	
}

spawn_ai_throttled_targetname( targetname, interval_min, interval_max )
{
	//to avoid having to change script_delay KVPs in radiant all the time
	spawners = GetEntArray( targetname, "targetname" );
	array = [];
	
	foreach ( s in spawners )
	{
		guy = s spawn_ai( 1 );
		array = array_add( array, guy );
		wait( randomfloatrange( interval_min, interval_max )  );
	}
	level notify ("done_throttled_spawn" );
	return array;	
}

spawn_ai_from_spawner_send_to_volume( spawner, amount, volume )
{
	array = [];
	spawner.count = amount;
	for ( i = 0; i < amount; i++ )
	{
		guy = spawner StalingradSpawn();
		wait(.05);
		guy SetGoalVolumeAuto( volume );
		guy LaserForceOn();
		array = add_to_array( array, guy );
	}
	
	return array;
}

do_nags_til_flag( flag_ender, min_time, max_time, alias0, alias1, alias2, alias3, alias4 )
{
	//self = ai doing the radio lines
	if(flag( flag_ender ) )
	{
		return;
	}	
	level endon (flag_ender);
	
	lines = [];
	lines[0] = alias0;
	
	if(isdefined(alias1))
	{
		lines[1] = alias1;
	}
	
	if(isdefined(alias2))
	{
		lines[2] = alias2;
	}
	
	if(isdefined(alias3))
	{
		lines[3] = alias3;
	}
	
	if(isdefined(alias4))
	{
		lines[4] = alias4;
	}
	
	//lines = array_randomize( lines );
	
	while(!flag(flag_ender))
	{
		foreach ( vo_line in lines)
		{
			self maps\jungle_ghosts_jungle::do_story_line(vo_line);
			wait(randomintrange ( min_time, max_time ) );
		}	
		wait(.15);
	}
}



anim_reach_custom( guys, anime, tag, animname_override, start_func, end_func, arrival_type )
{
// 	PrintLn( guy[ 0 ].animname, " doing animation ", anime );
	start_func = ::reach_with_standard_adjustments_begin_custom;
	end_func =  maps\_anim::reach_with_standard_adjustments_end;
	
	array = get_anim_position( tag );
	org = array[ "origin" ];
	angles = array[ "angles" ];

	if ( IsDefined( arrival_type ) )
	{
		AssertEx( !isdefined( self.type ), "type already defined" );
		self.type = arrival_type;
		self.arrivalStance = "stand";
	}

	ent = SpawnStruct();
	debugStartpos = false;
	/#
	debugStartpos = GetDebugDvar( "debug_animreach" ) ==  "on";
	#/
	threads = 0;
	foreach ( guy in guys )
	{
		// If there is an animation with this anime then reach the starting spot for that animation
		// otherwise run to the node

		if ( IsDefined( arrival_type ) )
			guy.scriptedarrivalent = self;

		if ( IsDefined( animname_override ) )
			animname = animname_override;
		else
			animname = guy.animname;

		if ( IsDefined( level.scr_anim[ animname ][ anime ] ) )
		{
			if ( IsArray( level.scr_anim[ animname ][ anime ] ) )
				startorg = GetStartOrigin( org, angles, level.scr_anim[ animname ][ anime ][ 0 ] );
			else
				startorg = GetStartOrigin( org, angles, level.scr_anim[ animname ][ anime ] );
		}
		else
		{
			startorg = org;
		}

		/#
		if ( debugStartpos )
			thread debug_message_clear( "x", startorg, 1000, "clearAnimDebug" );
		#/
			
		//=-=-=-=- putting start pos on ground if its within acceptable range
		adjusted_anim_start_position = anim_start_point_is_close_to_ground( guy, startorg );		
		
		if( !isdefined( adjusted_anim_start_position)  )
		{
			//ABORT THE REACH BECAUSE THE START POINT IS NOT CLOSE ENOUGH TO THE GROUND
			threads--;
			//guy.goalradius = guy.oldgoalradius;
			guy.scriptedarrivalent = undefined;
			guy.stopAnimDistSq = 0;
			
			if ( IsDefined( arrival_type ) )
				self.type = undefined;
			
			guy notify ("abort_takedown");
			PrintLn( "aborting reach. Start point is to far fromt he ground" );
			return "abort_takedown";
		}
		else
		{
			//MAKE THE START POINT ADJUSTED TO THE GROUND
			startOrg = adjusted_anim_start_position;
		}
		
		//=-=-=-=-==--=  end of function mod
		
		threads++;
		guy thread maps\_anim::begin_anim_reach( ent, startOrg, start_func, end_func );
	}

	while ( threads )
	{
		ent waittill( "reach_notify" );
		threads--;
	}
	/#
	if ( debugStartpos )
		level notify( "x" + "clearAnimDebug" );
	#/

	foreach ( guy in guys )
	{
		if ( !isalive( guy ) )
			continue;

		guy.goalradius = guy.oldgoalradius;
		guy.scriptedarrivalent = undefined;
		guy.stopAnimDistSq = 0;
	}

	if ( IsDefined( arrival_type ) )
		self.type = undefined;
}

reach_with_standard_adjustments_begin_custom( startorg )
{
	self.oldgoalradius = self.goalradius;
	self.oldpathenemyFightdist = self.pathenemyFightdist;
	self.oldpathenemyLookahead = self.pathenemyLookahead;
	self.pathenemyfightdist = 4;
	self.pathenemylookahead = 128;
	disable_ai_color();
	self anim_changes_pushplayer( true );
	self.nododgemove = true;
	self.fixedNodeWasOn = self.fixedNode;
	self.fixednode = false;
	
	if ( !isdefined( self.scriptedArrivalEnt ) )
	{
		self.old_disablearrivals = self.disablearrivals;
		self.disablearrivals = true;
	}
	self.reach_goal_pos = undefined;
	return startorg;
}

anim_start_point_is_close_to_ground( guy, point )
{
	acceptable_diff = 30;
	
	desired_z = point[2];
	ground_z = groundpos( point );
	
	z_difference = ( desired_z - ground_z[2] );
	
	absolutle_difference = abs( z_difference );
	PrintLn( "anim start pos is " +z_difference+ " units from its ground pos" );
	
	if( absolutle_difference < acceptable_diff )
	{
		thread draw_line_from_ent_for_time( guy, point, 1, 0, 0, 1 );
		thread draw_line_from_ent_for_time( guy, ground_z, 0, 1, 0, 1 );
		return ground_z;
	}
	
	return undefined;	
}

//=-=-=-=-=-==-=-=
//AI SQUAD STUFF
//=-=-=-=-=-=-=-=

squad_manager( squad )
{
	//monitors squad deaths, replaces leader when hes killed
	assert( squad.size > 0 );	
	current_count = squad.size;
	while( 1 )
	{
		squad = array_removeDead_or_dying( squad );		
		
		if( squad.size != current_count )
		{
			if(!IsDefined( squad["leader"] ) )
			{
				foreach ( guy in squad )
				{
					if( isdefined_and_alive( guy ) )
					{
						guy notify( "elected_squad_leader" );
						squad["leader"] = guy;
						guy thread squad_leader_logic();
						//IPrintLn( "promoted new squad leader" );
						array_thread( squad, ::reset_my_leader, guy );
						break;
					}
				}
			}
		
			if( squad.size == 0 )
			{
				//IPrintLnBold( "squad wiped out" );
				return;
			}
			
			current_count = squad.size;
		}
		wait(.5);	
	}

}

create_a_squad_from_spawner( spawner, squad, amount )
{ 	
	squad_count = amount; 
	spawner.count = squad_count;
	spawned_leader = undefined;

	for ( i = 0; i < squad_count; i++ )
	{
		//spawn sqaud leader
		if(!isdefined( spawned_leader ) )
		{
			guy = spawner StalingradSpawn();
			wait(.05);
			squad["leader"] = guy;
			guy thread squad_leader_logic();
			squad = add_to_array( squad, guy );
			wait( 1.5 );// since were using the same spawner give him time to unclutter spawn area
			spawned_leader = 1;		
			continue;
		}	
		//spawn rest of squad 		
		guy = spawner StalingradSpawn();		
		wait(.05);
		guy thread squad_member_logic( squad );
		squad = add_to_array( squad, guy );
	}
		
	return squad;	
}


reset_my_leader( new_leader )
{
	self.leader = new_leader;
}
	

squad_leader_logic()	
{
	//self thread Print3d_on_me("!");
	//self delayThread( 2, ::flashlight_on);
	self LaserForceOn();
	self.baseaccuracy = 3;	
	self disable_long_death();

	while( IsAlive( self ) )
	{
		self.goalradius = randomintrange( 800, 1200);
		self setgoalpos( level.player.origin );	
		wait randomintrange ( 3, 5 );
	}	
	
}


squad_member_logic( squad )
{
	self endon( "death" );
	self LaserForceOn();
	self disable_long_death();
	self endon("elected_squad_leader");
	self.fixednode = false;	
	self.goalradius = randomintrange( 200, 500 );
	self.leader = squad["leader"];
			
	while ( 1 )
	{
		if( isdefined( self.leader ) )
		{
			//thread draw_line_from_ent_to_ent_for_time( self, squad["leader"], 1, 0, 0, 1); 
			self SetGoalPos( self.leader.origin );
			wait( randomfloatrange( 2.5, 3 ) );
		}
		else
		{
			IPrintLn( "squad member has no leader to follow" );
			wait(1);
		}
	}

}

//END OF SQUAD STUFF

//Swim stuff from prague:

player_swim_think()
{
	
//	level.player FreezeControls( true );
//	level.player DisableWeapons();
//	time = 0.1;
//	//level.player thread play_sound_on_entity( "scn_prague_plr_break_surface" );
//	thread fade_out( time );
	//thread player_leaves_water();
	level.player setBlurForPlayer( 6, 0.2 );
	wait( 0.3 );
	thread enable_player_swim();
//	level.player SetWaterSheeting( 1, 3.0 );
	//fwd = AnglesToForward( level.player.angles );
	//playfx( getfx( "body_splash_prague" ), level.player geteye() + fwd );
	level.player setBlurForPlayer( 0, 0.8 );
	//thread fade_in( 0.3 );
	level.player player_speed_percent( 20, 0.1 );
	//level.player FreezeControls( false );
	
	flag_wait( "player_out_of_water" );
	//disable_player_swim();
}

enable_player_swim()
{
	setSavedDvar( "hud_showStance", "0" );
	setSavedDvar( "compass", "0" );
	level.player_view_pitch_down = getDvar( "player_view_pitch_down" );
	level.bg_viewBobMax = getDvar( "bg_viewBobMax" );
	level.player_sprintCameraBob = getDvar( "player_sprintCameraBob" );
	setSavedDvar( "player_view_pitch_down", 5 );
	setSavedDvar( "bg_viewBobMax", 0 );
	//setSavedDvar( "player_sprintCameraBob", 0 );
	
	//level.ground_ref_ent = spawn_tag_origin();
	//level.player playerSetGroundReferenceEnt( level.ground_ref_ent );
	
	//level.player SetMoveSpeedScale(.1 );
	
	level.player AllowStand( true );
	level.player AllowCrouch(false);
	level.player AllowProne(false);
	level.player AllowJump( false );
	level.player DisableWeapons();
	level.player AllowSprint( false );
	level.player AllowMelee( false );
	

//	level.player EnableSlowAim();
	
	//player_speed_percent( 20, 0.05 );
	//level.player ShellShock( "prague_swim", 999999 );	
	//level.player endon( "stop_swimming" );
	//level.player thread custom_waterfx( "player_out_of_water" );

	//childthread check_stick_movement( 0.4 );
	//childthread player_water_wade();
	//childthread player_water_death();
	
//	time = 4;
//	wait( 3 );
//	while( 1 )
//	{
//		level.ground_ref_ent rotatePitch( -2, time, time/2, time/2 );
//		level.ground_ref_ent waittill( "rotatedone" );
//		level.ground_ref_ent rotatePitch( 2, time, time/2, time/2 );
//		level.ground_ref_ent waittill( "rotatedone" );
//	}
}

player_water_wade()
{
	while ( 1 )
	{
		flag_wait( "player_is_moving" );
		childthread player_water_wade_sounds();
		childthread player_water_wade_speed();
		wait( 0.1 );
		flag_waitopen( "player_is_moving" );
		level.player notify( "stop_water_sounds" );
	}
}

player_water_wade_sounds()
{
	level.player endon( "stop_water_sounds" );
	wait( RandomFloatRange( 0,1 ) );
	while( 1 )
	{
		level.player play_sound_on_entity( "scn_prague_swim_slow_plr" );
		wait( RandomFloatRange( 0.5,1.5 ) );
	}
}

player_water_wade_speed()
{
	level endon( "player_swim_faster" );
	level.player endon( "stop_water_sounds" );
	while( !flag( "player_swim_faster" ) )
	{
		level.player thread play_sound_on_entity( "scn_prague_swim_slow_plr" );
		thread player_speed_percent( 27, 1 );
		wait( 1 );
		thread player_speed_percent( 18, 0.3 );
		wait( 0.5 );
	}
}

check_stick_movement( min_dist )
{	
	while( 1 )
	{
		dist = level.player GetNormalizedMovement();
		if ( Distance( ( 0, 0, 0 ), dist ) > min_dist )
		{
			level.player.moving = true;
			flag_set( "player_is_moving" );
		}
		else
		{
			level.player.moving = false;
			flag_clear( "player_is_moving" );
		}
		waitframe();
	}
}

custom_waterfx( endflag, offset )
{
// currently using these devraw fx:
//	level._effect[ "water_stop" ]						= LoadFX( "fx/misc/parabolic_water_stand" );
//	level._effect[ "water_movement" ]					= LoadFX( "fx/misc/parabolic_water_movement" );

	self endon( "death" );

	if ( IsDefined( endflag ) )
	{
		flag_assert( endflag );
		level endon( endflag );
	}
	
	if ( !IsDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	
	for ( ;; )
	{
		wait( RandomFloatRange( 0.15, 0.3 ) );
		start = self.origin + ( 0, 0, 150 );
		end = self.origin - ( 0, 0, 150 );
		trace = BulletTrace( start, end, false, undefined );
		if ( trace[ "surfacetype" ] != "water" )
			continue;

		fx = "water_movement";
		if ( IsPlayer( self ) )
		{
			if ( Distance( self GetVelocity(), ( 0, 0, 0 ) ) < 5 )
			{
				fx = "water_stop";
			}
		}
		else
		if ( IsDefined( level._effect[ "water_" + self.a.movement ] ) )
		{
			fx = "water_" + self.a.movement;
		}

		water_fx = getfx( fx );
		start = trace[ "position" ] + offset;
		//angles = vectortoangles( trace[ "normal" ] );
		angles = (0,self.angles[1],0);
		forward = anglestoforward( angles );
		up = anglestoup( angles );
		PlayFX( water_fx, start, up, forward );
	}
}

disable_player_swim()
{
	setSavedDvar( "player_view_pitch_down", level.player_view_pitch_down );
	setSavedDvar( "bg_viewBobMax", level.bg_viewBobMax );
	//setSavedDvar( "player_sprintCameraBob", level.player_sprintCameraBob );
	
	setSavedDvar( "hud_showStance", "1" );
	setSavedDvar( "compass", "1" );
		
	level.player playerSetGroundReferenceEnt( undefined );
	
	level.player AllowJump( true );
	level.player AllowMelee( true );
	level.player AllowSprint( true );
//	level.player DisableSlowAim();
	level.player StopShellShock();
	
	level.player notify( "stop_swimming" );
}


enable_ai_swim()
{
	
	//self gun_remove();
	self.animname = "generic";
	self disable_cqbwalk();
	self disable_sprint();
	self StopAnimScripted();
	self set_generic_idle_forever( "swim_idle" );
	self set_moveplaybackrate( 1 );
	self set_generic_run_anim( "swim_fast", true );
	
	self pushplayer( true );
	self.disableExits = true;
	self.disableArrivals = true;
	self.a.disablePain = true;
	self.ignoreAll = true;
	self thread custom_waterfx( "player_out_of_water", (0,0,-0.5) );
	self thread ai_swim_sound();
	self putGunAway();
}

disable_ai_swim()
{
	self notify( "stop_swimming" );
	self notify( "clear_idle_anim" );
	self clear_generic_idle_anim();
	self set_moveplaybackrate( 1 );
	self clear_run_anim();
	self.disableExits = false;
	self.disableArrivals = false;
	self.a.disablePain = false;
	self.animplaybackrate = 1;
}

ai_swim_sound()
{
	self endon( "stop_swimming" );
	childthread ai_swim_sound_idle();
	
	while( 1 )
	{
		self waittill( "moveanim", notetrack ); 
		if ( notetrack == "ps_scn_prague_swim_slow_npc" || notetrack == "end" ) // using "end" notetrack because it doesn't seem to detect the notetrack on the first frame after the first instance
			self play_sound_on_entity( "scn_prague_swim_slow_npc" );
		wait( 0.2 );
	}
}

ai_swim_sound_idle()
{
	self endon( "stop_swimming" );
	
	while( 1 )
	{
		self waittill( "Special_idle", notetrack ); 
		if ( notetrack == "ps_scn_prague_swim_idle_npc" || notetrack == "end" ) // using "end" notetrack because it doesn't seem to detect the notetrack on the first frame after the first instance
			self play_sound_on_entity( "scn_prague_swim_idle_npc" );
		wait( 0.2 );
	}
}

set_generic_idle_forever( idle_anim )
{
	thread set_generic_idle_internal( idle_anim );
}

set_generic_idle_internal( idle_anim )
{
	self endon( "death" );
	self endon( "clear_idle_anim" );
	
	while ( 1 )
	{
		self set_generic_idle_anim( idle_anim );

		self waittill( "clearing_specialIdleAnim" );
	}
}

// jesse - stolen from ship graveyard
pitch_and_roll()
{
	self endon( "stop_bob" );
	self endon( "death" );
	node = self;
	old = (0, node.angles[1], 0);
	
	maxdist = 20;
	if ( isdefined( node.script_max_left_angle ) )
	{
		maxdist = node.script_max_left_angle;
	}
	mindist = maxdist * 0.5;
	
	maxtime = 4;
	if ( isdefined( node.script_duration ) )
	{
		maxtime = node.script_duration;
	}
	mintime = maxtime * 0.5;
	
	node = undefined;
	
	while( 1 )
	{
		dist = ( RandomFloatRange( mindist, maxdist ), 0, RandomFloatRange( mindist, maxdist ) );
		time = RandomFloatRange( mintime,maxtime );
		
		self rotateTo( old + dist, time, time*0.2, time*0.2 );
		self waittill( "rotatedone" );
		self rotateTo( old - dist, time, time*0.2, time*0.2 );

		self waittill( "rotatedone" );
	}
}

friendly_squad_ignore_all(set_ignore)
{
	foreach (guy in level.bravo)
		guy.ignoreall = set_ignore;
	
	foreach (guy in level.alpha)
		guy.ignoreall = set_ignore;
}