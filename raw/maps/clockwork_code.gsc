#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_vehicle_spline_zodiac;
#include maps\_hud_util;

// CONSTANTS
ICEHOLE_RADIUS	= 50;
ICEHOLE_HEIGHT	= 50;

clockwork_init()
{
	PreCacheModel( "viewhands_yuri" );
	PreCacheModel( "clk_watch_viewhands" );
	PreCacheModel( "clk_watch_viewhands_off" );
//	PreCacheModel( "viewmodel_helmet_goggles" );
	//PreCacheModel( "clk_ice_hole01" );
	PreCacheModel( "weapon_sentry_smg_animated_collapsed" );
	
	// Defend
//	PreCacheShader( "dpad_killstreak_hellfire_missile" );
//	PreCacheShader( "remote_chopper_hud_target_enemy" );
//	PreCacheShader( "veh_hud_target_offscreen" );
//	PreCacheShader( "remote_chopper_hud_target_friendly" );
	PreCacheShader( "overlay_static" );
	PreCacheShader( "ac130_overlay_pip_vignette" );
	PreCacheShader( "ac130_overlay_pip_static_a" );
	PreCacheShader( "ac130_overlay_pip_static_b" );
	PreCacheShader( "ac130_overlay_pip_static_c" );
//	PreCacheShader( "compass_map_clockwork_defend" );
//	PreCacheModel( "head_henchmen_aaa" );
//	PreCacheModel( "head_henchmen_bbb" );
//	PreCacheModel( "head_chemwar_russian_b" );
//	PreCacheModel( "head_opforce_arab_c" );
//	PreCacheItem( "throwbot" );
	PreCacheItem( "thermobaric_mine" );
	PreCacheItem( "teargas_grenade" );
	PreCacheItem( "shockwave" );
	PrecacheMinimapSentryCodeAssets();
	
	common_scripts\_sentry::main();
	
	SetNorthYaw( 255 );
	
//	maps\clockwork_pip::pip_init();
}
	
setup_common()
{
	level.player SetViewModel( "viewhands_yuri" );
	level.player TakeAllWeapons();

	level.player GiveWeapon( "m14_scoped_silencer_arctic" );
	
	
	level.player GiveWeapon( "ak47_silencer_reflex_iw6" );
	level.player SwitchToWeaponImmediate( "ak47_silencer_reflex_iw6" );
		
	level.player SetOffhandPrimaryClass( "frag" );
	level.player SetOffhandSecondaryClass( "flash" );

	level.player GiveWeapon( "fraggrenade" );
	level.player GiveWeapon( "flash_grenade" );
	//maps\_blizzard::blizzard_main();
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
	setup_common();
	
}

spawn_allies()
{
	level.allies						= [];
	level.allies[ level.allies.size ]	= spawn_ally( "baker"  );
	level.allies[ level.allies.size -1 ].animname = "baker";
	//level.scr_sound[ "baker" ] =[];
	level.allies[ level.allies.size ]	= spawn_ally( "keegan" );
	level.allies[ level.allies.size-1 ].animname = "keegan";
	//level.scr_sound[ "keegan" ] =[];
	level.allies[ level.allies.size ]	= spawn_ally( "cipher" );
	level.allies[ level.allies.size-1 ].animname = "cypher";
	//level.scr_sound[ "cypher" ] =[];
	
	setup_dufflebag_anims();
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
    //BCS hack.
    ally.countryid = "US";
    
    
    return ally;
}


/*
 * Creates timer using milliseconds.
 */
clockwork_timer( iSeconds, sLabel, bUseTick )
{	
	level endon( "kill_timer" );
	
	if ( getdvar( "notimer" ) == "1" )
		return;

	if ( !isdefined( bUseTick ) )
		bUseTick = false;
		
	// -- timer setup --	
	level.hudTimerIndex = 20;
	level.timer = maps\_hud_util::get_countdown_hud( -250 );
	level.timer SetPulseFX( 30, 900000, 700 );
	level.timer.label = sLabel;
	level.timer settenthstimer( iSeconds );
	level.start_time = gettime();
			
	// -- timer expired --
	//if ( bUseTick == true )
		//thread maps\clockwork_intro::timer_tick();
		
	while( IsDefined( level.timer ) )
	{
		if( level.start_time + iSeconds > GetTime() )
			killTimer();
		wait 1;
	}
}
/*
timer_tick()
{
	level endon( "kill_timer" );
	while ( true )
	{
		wait( 1 );
		level.player thread play_sound_on_entity( "countdown_beep" );
	}
}
*/

#using_animtree( "generic_human" );

setup_dufflebag_anims()
{
    duffle_bag_anims_archetype = [];
	duffle_bag_anims_archetype[ "cqb" ][ "straight" ] = %dufflebag_cqb_run;
	duffle_bag_anims_archetype[ "cqb" ][ "straight_v2" ] = %dufflebag_cqb_run_alt;
	duffle_bag_anims_archetype[ "cqb" ][ "move_f" ] = %dufflebag_cqb_walk;
	duffle_bag_anims_archetype[ "run" ][ "straight" ] = %dufflebag_lowready_run;

	register_archetype( "dufflebag", duffle_bag_anims_archetype );
	
	duffel_bags_idle_anims_array = [];
	duffel_bags_idle_anims_array[ "stand" ] = [];
	duffel_bags_idle_anims_array[ "stand" ][ 0 ] = %dufflebag_casual_idle;
	duffel_bags_idle_anims_array[ "stand" ][ 1 ] = %dufflebag_casual_idle_fidget_01;
	duffel_bags_idle_anims_array[ "stand" ][ 2 ] = %dufflebag_casual_idle_fidget_02;
	duffel_bags_idle_anims_array[ "stand" ][ 3 ] = %dufflebag_casual_idle_fidget_03;
	duffel_bags_idle_anims_weights = [];
	duffel_bags_idle_anims_weights[ "stand" ] = [];
	duffel_bags_idle_anims_weights[ "stand" ][ 0 ] = 2;
	duffel_bags_idle_anims_weights[ "stand" ][ 1 ] = 1;
	duffel_bags_idle_anims_weights[ "stand" ][ 2 ] = 1;
	duffel_bags_idle_anims_weights[ "stand" ][ 3 ] = 1;
	
	level.allies[ 0 ].customIdleAnimSet  = duffel_bags_idle_anims_array;
    level.allies[ 0 ].customIdleAnimWeights = duffel_bags_idle_anims_weights;
    level.allies[ 0 ].animarchetype = "dufflebag";
    
	
	duffel_bags_keegan_idle_anims_array = [];
	duffel_bags_keegan_idle_anims_array[ "stand" ] = [];
	duffel_bags_keegan_idle_anims_array[ "stand" ][ 0 ] = %dufflebag_casual_keegan_idle;
	duffel_bags_keegan_idle_anims_array[ "stand" ][ 1 ] = %dufflebag_casual_keegan_idle_fidget_01;
	duffel_bags_keegan_idle_anims_array[ "stand" ][ 2 ] = %dufflebag_casual_keegan_idle_fidget_02;
	duffel_bags_keegan_idle_anims_array[ "stand" ][ 3 ] = %dufflebag_casual_keegan_idle_fidget_03;
	duffel_bags_keegan_idle_anims_weights = [];
	duffel_bags_keegan_idle_anims_weights[ "stand" ] = [];
	duffel_bags_keegan_idle_anims_weights[ "stand" ][ 0 ] = 2;
	duffel_bags_keegan_idle_anims_weights[ "stand" ][ 1 ] = 1;
	duffel_bags_keegan_idle_anims_weights[ "stand" ][ 2 ] = 1;
	duffel_bags_keegan_idle_anims_weights[ "stand" ][ 3 ] = 1;
	
	level.allies[ 1 ].customIdleAnimSet  = duffel_bags_idle_anims_array;
    level.allies[ 1 ].customIdleAnimWeights = duffel_bags_idle_anims_weights;
    level.allies[ 1 ].animarchetype = "dufflebag";
    
	duffel_bags_cypher_idle_anims_array = [];
	duffel_bags_cypher_idle_anims_array[ "stand" ] = [];
	duffel_bags_cypher_idle_anims_array[ "stand" ][ 0 ] = %dufflebag_casual_cypher_idle;
	duffel_bags_cypher_idle_anims_array[ "stand" ][ 1 ] = %dufflebag_casual_cypher_idle_fidget_01;
	duffel_bags_cypher_idle_anims_array[ "stand" ][ 2 ] = %dufflebag_casual_cypher_idle_fidget_02;
	duffel_bags_cypher_idle_anims_array[ "stand" ][ 3 ] = %dufflebag_casual_cypher_idle_fidget_03;
	duffel_bags_cypher_idle_anims_weights = [];
	duffel_bags_cypher_idle_anims_weights[ "stand" ] = [];
	duffel_bags_cypher_idle_anims_weights[ "stand" ][ 0 ] = 2;
	duffel_bags_cypher_idle_anims_weights[ "stand" ][ 1 ] = 1;
	duffel_bags_cypher_idle_anims_weights[ "stand" ][ 2 ] = 1;
	duffel_bags_cypher_idle_anims_weights[ "stand" ][ 3 ] = 1;
	
	level.allies[ 2 ].customIdleAnimSet  = duffel_bags_idle_anims_array;
    level.allies[ 2 ].customIdleAnimWeights = duffel_bags_idle_anims_weights;
    level.allies[ 2 ].animarchetype = "dufflebag";
}
	
	
init_animated_dufflebags()
{
	if ( !IsDefined(level.bags) || !IsDefined(level.bags[0]) )
	{
		level.bags = [];
		
		level.bags[0] = spawn_anim_model("baker_bag"); 
		level.bags[0].animname = "baker_bag";
		level.allies[0].animatedDuffle = level.bags[0];
		
		level.bags[1] = spawn_anim_model("keegan_bag"); 
		level.bags[1].animname = "keegan_bag";
		level.allies[1].animatedDuffle = level.bags[1];
		
		level.bags[2] = spawn_anim_model("cipher_bag"); 	
		level.bags[2].animname = "cipher_bag";
		level.allies[2].animatedDuffle = level.bags[2];
	}
	
	if ( !IsDefined(level.player_bag) )
	{
		level.player_bag = spawn_anim_model("player_bag");
	}
}

get_bag_parts()
{
	bag_part = [];
	bag_part[ bag_part.size ] = "J_Cog";
	bag_part[ bag_part.size ] = "J_Strap_Base";
	bag_part[ bag_part.size ] = "J_Strap_End";
	bag_part[ bag_part.size ] = "J_Strap_1";
	bag_part[ bag_part.size ] = "J_Strap_2";
	bag_part[ bag_part.size ] = "J_Strap_3";
	bag_part[ bag_part.size ] = "J_Strap_4";
	bag_part[ bag_part.size ] = "J_Strap_5";
	bag_part[ bag_part.size ] = "J_Strap_6";
	bag_part[ bag_part.size ] = "J_Strap_7";
	bag_part[ bag_part.size ] = "J_Strap_8";
	bag_part[ bag_part.size ] = "J_Strap_9";
	bag_part[ bag_part.size ] = "J_Strap_10";
	bag_part[ bag_part.size ] = "J_Strap_11";
	bag_part[ bag_part.size ] = "J_Strap_12";
	bag_part[ bag_part.size ] = "J_Strap_13";
	bag_part[ bag_part.size ] = "J_Strap_14";
	
	return bag_part;
	
}

show_dufflebags(hideAnimatedDuffles)
{
	foreach( ally in level.allies )
	{
		bag_parts = get_bag_parts();
		foreach( part in bag_parts )
			ally ShowPart( part );
	}
	
	if (IsDefined(hideAnimatedDuffles) && hideAnimatedDuffles == true)
	{
		foreach (bag in level.bags)
		{
			bag Hide();
		}
	}
}

hide_dufflebags(showAnimatedDuffles)
{
	foreach( ally in level.allies )
	{
		bag_parts = get_bag_parts();
		foreach( part in bag_parts )
			ally HidePart( part );
	}
	
	if (IsDefined(showAnimatedDuffles) && showAnimatedDuffles == true )
	{
		foreach (bag in level.bags)
		{
			bag Show();
		}
	}
}

hide_dufflebag(showAnimatedDuffle)
{
	bag_parts = get_bag_parts();
	foreach( part in bag_parts )
		self HidePart( part );

	if ( IsDefined( showAnimatedDuffle) && showAnimatedDuffle && IsDefined(self.animatedDuffle) )
	{
		self.animatedDuffle Show();
	}
}

show_dufflebag(hideAnimatedDuffle)
{
	bag_parts = get_bag_parts();
	foreach( part in bag_parts )
		self ShowPart( part );
	
	if ( IsDefined( hideAnimatedDuffle  ) && hideAnimatedDuffle && IsDefined(self.animatedDuffle) )
	{
		self.animatedDuffle Hide();
	}
}



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

ai_array_killcount_flag_set( enemies, killcount, flag, timeout )
{
	waittill_dead_or_dying( enemies, killcount, timeout );
	flag_set( flag );
}

array_spawn_targetname_allow_fail( targetname, bForceSpawn )
{
//	IPrintLnBold("array spawn: "+targetname);
	spawners = GetEntArray( targetname, "targetname" );
	AssertEx( spawners.size, "Tried to spawn spawners with targetname " + targetname + " but there are no spawners" );
	
	spawned = array_spawn_allow_fail( spawners );
	/**
	/#
	if( IsDefined( level.kingfish_debug_ai ) && level.kingfish_debug_ai )
		IPrintLn( targetname + " " + spawners.size +" spawners. " +spawned.size +  " spawned" );
		
	level.kingfish_num_spawners += spawners.size;
	level.kingfish_num_spawned += spawned.size;
	if(	spawners.size !=	spawned.size )
		IPrintLnBold( "SPAWNED MISMATCH- had " + spawners.size +" spawners, but only " +spawned.size +  " spawned" );
	#/
	*/
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

/**
 * Moves guys to volume_name
 */
reassign_goal_volume( guys, volume_name )
{
	//IPrintLnBold("revolume: "+ volume_name);
	
	if ( !IsArray( guys ) )
	{
		guys = make_array( guys );
	}
	
	guys	= array_removeDead_or_dying( guys );
	vol		= GetEnt( volume_name, "targetname" );

	foreach ( guy in guys )
	{
		guy SetGoalVolumeAuto( vol );
	}
}

safe_activate_trigger_with_targetname( msg )
{
	trigger = GetEnt( msg, "targetname" );
	if ( IsDefined( trigger ) && !IsDefined(trigger.trigger_off) )
		trigger activate_trigger();
}
safe_disable_trigger_with_targetname( msg )
{
	trigger = GetEnt( msg, "targetname" );
	if( IsDefined(trigger))
	{
		trigger trigger_off();
	}
}
safe_delete_trigger_with_targetname( msg )
{
	trigger = GetEnt( msg, "targetname" );
	if( IsDefined(trigger))
	{
		trigger Delete();
	}
}
// self = model starting anim on
//start_anim_on_object(animname,name_of_animation,delay)
//{
//	self endon("deleted_through_script");
//	
//	if ( isdefined(delay) )
//	{
//		wait(delay);
//	}
//	self.animname = animname;
//	self useAnimTree( level.scr_animtree[ self.animname ] );
//	//self thread anim_loop_solo(self, name_of_animation, "stop_looping_anims");
//	self setAnimRestart( level.scr_anim[self.animname][name_of_animation], 1, 0, 1 );
//}

// gun down until player fires while adsing.
hold_fire_unless_ads( flagname, guntogive )
{	
	level endon( "ads_done" );
	
	thread hold_fire_unless_ads_hint();
	
	if( !IsDefined( guntogive ) )
		guntogive = "ak47_silencer_reflex_iw6"; 
		
	if ( !level.player HasWeapon( guntogive ) )
	{
		level.player GiveWeapon( guntogive );
	}
		
	if(level.player GetCurrentWeapon() != "ak47_disguise_acog")
	{
		//level.player TakeAllWeapons();
		level.player DisableWeaponSwitch();
		level.player GiveWeapon("ak47_disguise_acog");
		level.player SwitchToWeapon( "ak47_disguise_acog" );
	}
	
	while( !flag(flagname) )
	{
		level.player allowfire(false);
		//level.player DisableWeaponPickup();
		if( level.player isADS())
		{
			level.player allowfire(true);
			while( level.player isADS() )
			{
				if( level.player IsFiring())
				{
					while( level.player isADS() )
					{
						wait .05;
					}
					
					level.player DisableWeapons();
					level.player TakeWeapon("ak47_disguise_acog");
					level.player SwitchToWeaponImmediate( guntogive );
					level.player enableWeapons();
					//level.player EnableWeaponPickup();					
					return;
				}
				wait .05;
			}
		}
		wait .05;
	}
	
	level.player enableWeaponSwitch();
	level.player SwitchToWeaponImmediate( guntogive );
	level.player allowfire( true );
	//level.player EnableWeaponPickup();
	level notify( "ads_done" );
	wait 3;
	//hack for nvg area. wait one so the nvg_down anim has a chance to play on the weapon.
	level.player TakeWeapon("ak47_disguise_acog");
}

hold_fire_unless_ads_hint()
{
	level endon( "ads_done" );
	level.player notifyOnPlayerCommand( "fire", "+attack" );
	
	level.player waittill( "fire" );
	
	if( !(level.player isADS() ) )
		thread hint( &"CLOCKWORK_HINT_SAFETY_ON", 5 );
}	

//*** Airport Player/Ally Movement Code ***//

blend_movespeedscale_custom( percent, time )
{
	player = self;
	if ( !isplayer( player ) )
	{
		player = level.player;
	}

	player notify( "blend_movespeedscale_custom" );
	player endon( "blend_movespeedscale_custom" );

	if ( !isdefined( player.baseline_speed ) )
		player.baseline_speed = 1.0;

	goalspeed = percent * .01;
	currspeed = player.baseline_speed;

	if ( IsDefined( time ) )
	{
		range = goalspeed - currspeed;
		interval = .05;
		numcycles = time / interval;
		fraction = range / numcycles;

		while ( abs( goalspeed - currspeed ) > abs( fraction * 1.1 ) )
		{
			currspeed += fraction;
			player.baseline_speed = currspeed;
			if ( !flag( "player_dynamic_move_speed" ) )
				level.player SetMoveSpeedScale( player.baseline_speed );
			wait interval;
		}
	}

	player.baseline_speed = goalspeed;
	if ( !flag( "player_dynamic_move_speed" ) )
		level.player SetMoveSpeedScale( player.baseline_speed );
}

player_dynamic_move_speed()
{
	
	player_dynamic_move_speed_block();
	
	wait 0.1;
	level.player SetMoveSpeedScale( 1.0 );
	level.player AllowSprint( true );
	level.player AllowJump( true );
	
}


player_dynamic_move_speed_block()
{
	level notify( "starting_new_player_dyn_move" );
	level endon( "starting_new_player_dyn_move" );
	flag_waitopen( "friendly_fire_warning" );
	level endon( "friendly_fire_warning" );

	flag_set( "player_dynamic_move_speed" );

	current = 1;
	actor = undefined;

	foreach ( member in level.allies )
		member.plane_origin = SpawnStruct();

	SetDvarIfUninitialized( "debug_playerDMS", 0 );

	while ( flag( "player_dynamic_move_speed" ) )
	{
		//if we're close enough to an actor to be significant - then just use him
		//otherwise go through a series of complicated steps to figure out where 
		//we are in relation to the whole team
		guy = getClosest( level.player.origin, level.allies );
		ahead = false;

		//we dont have distance2d SQUARED...so here's a hack
		origin1 = ( level.player.origin[ 0 ], level.player.origin[ 1 ], 0 );
		origin2 = ( guy.origin[ 0 ], guy.origin[ 1 ], 0 );

		if ( DistanceSquared( origin1, origin2 ) < squared( 200 ) )
		{
			ahead = guy player_DMS_ahead_test();

			guy.plane_origin.origin = guy player_DMS_get_plane();

			actor = guy.plane_origin;

			/#
			if ( GetDvarInt( "debug_playerDMS" ) )
				Line( actor.origin, level.player.origin, ( 1, 0, 0 ), 1 );
			#/
		}
		else
		{
			//calculate if we are ahead of anyone
			foreach ( member in level.allies )
			{
				//for this level, this function is so aggressive that we'll never get this far 
				//ahead of someone - so don't count it
				if ( DistanceSquared( level.player.origin, member.origin ) > squared( 250 ) )
					continue;
				ahead = member player_DMS_ahead_test();
				if ( ahead )
					break;
			}
			//calculate a facing plane based on everyone's angles, then get the closest point on the closest
			//plane to us - and use that point to decide how close we are to the average of the group
			planes = [];
			foreach ( member in level.allies )
			{
				member.plane_origin.origin = member player_DMS_get_plane();

				planes[ planes.size ] = member.plane_origin;
			}

			actor = getClosest( level.player.origin, planes );

			/#
			if ( GetDvarInt( "debug_playerDMS" ) )
				Line( actor.origin, level.player.origin, ( 0, 1, 0 ), 1 );
			#/
		}
		/#
		if ( GetDvarInt( "debug_playerDMS" ) )
			Print3d( actor.origin, "dist: " + Distance( level.player.origin, actor.origin ), ( 1, 1, 1 ), 1 );
		#/
		//if he's way out in front - really slow him down
		if ( DistanceSquared( level.player.origin, actor.origin ) > squared( 100 ) && ahead )
		{
			/#
			if ( GetDvarInt( "debug_playerDMS" ) )
				PrintLn( "TOOO FAR AHEAD!!!!!!!!!!!" );
			#/
			if ( current > .55 )
				current -= .015;
		}
		//if he's too close - take him as much as 20% under his baseline
		else
		if ( DistanceSquared( level.player.origin, actor.origin ) < squared( 50 ) || ahead )
		{
			if ( current < .78 )
				current += .015;

			if ( current > .8 )
				current -= .015;
		}
		//if he's REALLY far away - take him as much as 75% over his baseline ( as long as total speed doesn't reach 110%, capped below )
		else
		if ( DistanceSquared( level.player.origin, actor.origin ) > squared( 300 ) )
		{
			if ( current < 1.75 )
				current += .02;
		}
		//if he's far away - take him as much as 35% over his baseline
		else
		if ( DistanceSquared( level.player.origin, actor.origin ) > squared( 100 ) )
		{
			if ( current < 1.35 )
				current += .01;
		}
		//if he's in range - take him back to his baseline
		else
		if ( DistanceSquared( level.player.origin, actor.origin ) < squared( 85 ) )
		{
			if ( current > 1.0 )
				current -= .01;
			if ( current < 1.0 )
				current += .01;
		}

		if( current > 1.65 || flag( "player_DMS_allow_sprint" ) )
		{
			level.player AllowSprint( true );
			level.player AllowJump( true );
		}
		else
		{
			level.player AllowSprint( false );
			level.player AllowJump( false );
		}

		//set his speed based on baseline and this ratio
		level.player.adjusted_baseline = level.player.baseline_speed * current;
		if ( level.player.adjusted_baseline > 1.1 )
			level.player.adjusted_baseline = 1.1;

		/#
		if ( GetDvarInt( "debug_playerDMS" ) )
			PrintLn( "baseline: " + level.player.baseline_speed + ", 	adjusted: " + level.player.adjusted_baseline );
		#/

		level.player SetMoveSpeedScale( ( level.player.adjusted_baseline ) );
		wait .05;
	}
}

player_DMS_get_plane()
{
	P = level.player.origin;
	A = self.origin + ( AnglesToRight( self.angles ) * -5000 );
	B = self.origin + ( AnglesToRight( self.angles ) * 5000 );
	/#
	if ( GetDvarInt( "debug_playerDMS" ) )
		Line( A, B, ( 0, 0, 1 ), 1 );
	#/
	return PointOnSegmentNearestToPoint( A, B, P );
}

player_DMS_ahead_test()
{
	ahead = false;
	//this is a test to see if we're closer to their goal than they are
	if ( IsDefined( self.last_set_goalent ) )
		ahead = self [[ level.drs_ahead_test ]]( self.last_set_goalent, 50 );
	else if ( IsDefined( self.last_set_goalnode ) )
		ahead = self [[ level.drs_ahead_test ]]( self.last_set_goalnode, 50 );

	return ahead;
}

/*** Grenade and MG turret code ***/
/**
 *  Script to switch between grenades and turret.
 * 	Starts with grenade func.
 */
switch_active()
{
	self notifyOnPlayerCommand( "switchturret", "weapnext" );
	wait .05;
	self endon( "switchtoturret" );
	
	while( 1 ) 
	{
		foreach( turret in level.playerJeep.mgturret )
			turret TurretFireDisable();
		
		level.switchactive = 1; // Fire grenade
		//IPrintLnBold( "Grenade" );
				
		self waittill( "switchturret" );
				
		foreach( turret in level.playerJeep.mgturret )
			turret TurretFireEnable();
		
		level.switchactive = 0; // Fire turret
		//IPrintLnBold( "Turret" );
		
		self waittill( "switchturret" );
		
		wait .25;
	}
}

fire_grenade()
{
	level.player thread switch_active();
	volley_wait = 2;
	wait_between_rounds = 1;
	grenade_auto_reload = gettime();
	grenade_round_delay = gettime();
	grenadenotshotcount = 0;
	reminder = 0;
	
	while( !isdefined( level.missionend ) )
	{
		if( level.switchactive )
		{
			if( level.player AttackButtonPressed() && grenade_round_delay < gettime() )
			{
				grenadenotshotcount = 0;
		
				source_pos = level.player GetEye();
				player_angles = level.player GetPlayerAngles();
				forward_vec = AnglesToForward( player_angles );
				to_right = anglestoRight( player_angles );
				target_pos = source_pos + ( forward_vec * 12 * 2000 );
				
				grenade_launcher_loc = self.mgturret[0] GetTagOrigin( "TAG_LAUNCHER" );
				
				if( flag( "en_headon_road" ) )
				{
					if( flag( "enemy_cave_spawn" ) )
						maars_grenade = magicbullet( "xm25_fast", grenade_launcher_loc + ( forward_vec * 32 ) + ( 0, 0, 16 ), target_pos, level.player );
					else
						maars_grenade = magicbullet( "xm25_fast", grenade_launcher_loc + ( forward_vec * 32 ), target_pos, level.player );
				}
				else
					maars_grenade = magicbullet( "xm25_fast", grenade_launcher_loc + ( forward_vec * 32 ) + ( 0, 0, 16 ), target_pos, level.player );
				
				playfxontag( getfx( "grenade_muzzleflash" ), self.mgturret[0], "tag_flash"  );
				level.player playrumbleonentity( "damage_light" );
				thread screenshakeFade( 0.03, .5, .01, .20  );
				thread maps\clockwork_audio::chase_concussion();
				
				grenade_auto_reload = gettime() + ( volley_wait * 1000 );
				grenade_round_delay = gettime() + ( wait_between_rounds * 1000 );
			}
			else
			{
				wait( .05 );
				
				// grenade reminder
				grenadenotshotcount++;
				if( !flag( "rpg_spawn" ) )
				{
					grenadenotshotcount = 0;
				}
				else if( grenadenotshotcount > 200 && !flag("enemy_cave_spawn") )
				{
					grenadenotshotcount = 0;
					if( reminder )
					{
						level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_shoottheice" );
						reminder = 0;
					}
					else
					{
						//"Baker: Use the grenades."
						level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_usegrenades" );
						reminder = 1;
					}
				}
			}
		}
		wait .01;
	}	
}

// gather all the drift triggers in the level.
vehicle_hit_drift()
{
	drifts = GetEntArray( "exfil_drift_trigger", "targetname" );
	
	foreach( drift in drifts )
	{
		drift thread drift_hit();
	}
}

// play fx if drift is hit.
drift_hit()
{
	for ( ;; )
	{
		self waittill("trigger", other);
		
		if ( other isVehicle() && IsDefined( other ) && IsAlive( other ) ) 
		{
			playfx( loadfx("fx/treadfx/bigjump_land_snow_night"), other.origin );
		}
		
		wait .75;
	}
}

/*** Exfil Icehole Code ***/

handle_grenade_launcher()
{
	level endon( "death" );
	
	flag_wait("start_icehole_shooting");
	
	for ( ;; )
	{
    	self waittill( "missile_fire", grenade, weaponName );
        thread handle_grenade_explode( grenade );        
        wait .01;
	}
}

handle_grenade_explode( grenade )
{
    level notify( "cancel_my_grenade" );
    level endon( "cancel_my_grenade" );

    grenade waittill( "explode", org );
    thread add_ice_radius( ICEHOLE_RADIUS, org );
    thread maps\clockwork_audio::chase_crack_icehole( org );
}


add_ice_radius( radius, origin )
{	
	level endon( "death" );

	icehole_origin = drop_to_ground( origin, origin[2] ); // try bullet trace
	icehole_origin_z = icehole_origin[2];
	
	// Don't create an icehole in midair, on rocks, etc.
	if( icehole_origin_z < 224 && origin[2] < 300 )
	{
		vehicles = getVehicleArray();
		
		r2 = radius * radius;
		
		// rotate between brushmodels
		if( level.icehole_to_move < 4)
		{
			level.icehole_to_move++;
		} 
		else
		{
			level.icehole_to_move = 1;
		}
		
		icehole_name = "icehole_" + level.icehole_to_move;
		icehole_brush = getent( icehole_name, "targetname" );
		icehole_brush MoveTo( icehole_origin, .01);
		
		if( level.icehole_to_move == 1 )
		{
			ice_hole_model = spawn_anim_model( "cw_icehole", icehole_origin );
			ice_hole_model thread anim_single_solo( ice_hole_model, "ice_a" );
		}
		else if( level.icehole_to_move == 2 )
		{
			ice_hole_model = spawn_anim_model( "cw_icehole", icehole_origin );
			ice_hole_model thread anim_single_solo( ice_hole_model, "ice_b" );
		}
		else if( level.icehole_to_move == 3 )
		{
			ice_hole_model = spawn_anim_model( "cw_icehole", icehole_origin );
			ice_hole_model thread anim_single_solo( ice_hole_model, "ice_c" );
		}
		else
		{
			ice_hole_model = spawn_anim_model( "cw_icehole", icehole_origin );
			ice_hole_model thread anim_single_solo( ice_hole_model, "ice_b" );
		}
		
		playfx( level._effect[ "mortar" ][ "water" ], icehole_origin );
				
		foreach (vehicle in vehicles)
		{
			d2 = DistanceSquared( vehicle.origin, icehole_origin );
			if ( r2 > d2 )
			{
				if ( IsDefined( vehicle ) && IsAlive( vehicle ) && vehicle == level.playerJeep) // && vehicle != level.allyJeep )
				{
					if( !flag( "enemy_cave_spawn" ) ) // don't kill player after vehicles should be in front of him
					{
						level.player DisableInvulnerability();
						wait .01;
						level.player kill();
					    thread play_sound_in_space( "clkw_scn_ice_chase_hole", icehole_origin );
					    thread maps\clockwork_audio::chase_pileup_counter();
						dynamic_player_crash( vehicle, 1 );
					}
				}
				else if ( IsDefined( vehicle ) && IsAlive( vehicle ) )
				{
					if( IsDefined( level.endingjeep ) && vehicle == level.endingjeep && !flag( "kill_endingjeep" ))
					{
					}
					else
					{
						vehicle thread play_crash_anim( icehole_origin );
						thread play_sound_in_space( "clkw_scn_ice_chase_hole", icehole_origin );
						thread maps\clockwork_audio::chase_pileup_counter();
					}						
				}
			}
		}
		
		icehole_trigger = Spawn( "trigger_radius", icehole_origin, 16, radius, ICEHOLE_HEIGHT );
		icehole_trigger.angles = level.playerJeep.angles;
		icehole_trigger thread handle_vehicles_near_iceholes();
		
		wait 10;
		
		icehole_trigger delete();
		if( IsDefined( ice_hole_model ) )
			ice_hole_model 	delete();
	}
	else // to crash if player hits vehicle
	{
		vehicles = getVehicleArray();
		
		r2 = ( radius + radius ) * ( radius + radius );
		
		foreach (vehicle in vehicles)
		{
			d2 = DistanceSquared( vehicle.origin, icehole_origin );
			if ( r2 > d2 )
			{
				vehicle_origin_z = vehicle.origin[2];
				if ( IsDefined( vehicle ) && IsAlive( vehicle ) && vehicle == level.playerJeep) // && vehicle != level.allyJeep )
				{
					if( vehicle_origin_z < 224 )
					{
						if( !flag( "enemy_cave_spawn" ) ) // don't kill player after vehicles should be in front of him
						{
							level.player DisableInvulnerability();
							wait .01;
							level.player kill();
						    thread play_sound_in_space( "clkw_scn_ice_chase_hole", icehole_origin );
						    thread maps\clockwork_audio::chase_pileup_counter();
							dynamic_player_crash( vehicle, 1 );
						}
					}
				}
				else if ( IsDefined( vehicle ) && IsAlive( vehicle ) )
				{
					if( vehicle_origin_z < 224 )
					{
						if( IsDefined( level.endingjeep ) && vehicle == level.endingjeep && !flag( "kill_endingjeep" ))
						{
						}
						else
						{
							vehicle thread play_crash_anim( icehole_origin );
							thread play_sound_in_space( "clkw_scn_ice_chase_hole", icehole_origin );
							thread maps\clockwork_audio::chase_pileup_counter();
						}						
					}
				}
			}
		}
	}
}

// Trigger for vehicle hitting icehole.
handle_vehicles_near_iceholes()
{
	level endon( "death" );
	
	for ( ;; )
	{
		self waittill("trigger", other);

		notcrashed = 1;
		
		foreach( vehicle in level.allcrashes )
		{
			if( vehicle == other )
				notcrashed = 0;
		}
		
		if ( other isVehicle() && notcrashed && IsDefined( other ) && IsAlive( other ) && other == level.playerJeep) 
		{
			if( !flag( "enemy_cave_spawn" ) ) // don't kill player after vehicles should be in front of him
			{
				level.allcrashes[level.allcrashes.size] = other;
				level.player DisableInvulnerability();
				wait .01;
				level.player kill();
				thread play_sound_in_space( "clkw_scn_ice_chase_hole", other.origin );
				thread maps\clockwork_audio::chase_pileup_counter();
				dynamic_player_crash( other, 1 );
			}
		}
		else if (other isVehicle() && notcrashed ) // && other != level.playerJeep && other != level.allyJeep)
		{
			if( IsDefined( level.endingjeep ) && other == level.endingjeep && !flag( "kill_endingjeep" ))
			{
			} 
			else
			{
				level.allcrashes[level.allcrashes.size] = other;
				other thread play_icehole_anim( self );
				thread play_sound_in_space( "clkw_scn_ice_chase_hole", other.origin );
				thread maps\clockwork_audio::chase_pileup_counter();
			}
		}
	}
}

// Play vehicle icehole crash anim for initial hit. Call on entity.
play_crash_anim( origin )
{
	self notify("icehole_occured");
	if( isdefined( self ) && self.model == "vehicle_snowmobile" )
	{
		array_thread( self.riders, ::vehicle_crash_guy, self );
		expl_origin = self gettagorigin( "tag_passenger" );
		PhysicsExplosionCylinder( expl_origin, 300, 300, .25 );
		if( IsDefined( self.attachedguys[0] ))
			self.attachedguys[0] kill();
	}
	
	// bikes will just crash after riders die.
	if( self.model == "vehicle_chinese_brave_warrior_anim" || self.model == "vehicle_gaz_tigr_base" )
	{
		if( isdefined( self ) )
		{
			array_thread( self.riders, ::vehicle_crash_guy, self );
			expl_origin = self gettagorigin( "tag_guy1" );
			PhysicsExplosionCylinder( expl_origin, 300, 300, .25 );
		}
		
		velocity 	= self Vehicle_GetVelocity();
		norvelocity = VectorNormalize( velocity );
		
		forward 	= AnglesToForward( self.angles );
		norforward	= VectorNormalize( forward );
		
		dot 		= VectorDot( norforward, norvelocity );
		
		if( dot > .9 )
		{
			rand = RandomIntRange( 1, 4 );
			if( rand == 1 && !level.justplayed ) // check to see if long crash should be played
			{
 				self play_long_crash();
				level.justplayed = 1;
			}
			else
			{
				dynamic_icehole_crash( self, 2 );
				level.justplayed = 0;
			}
		}
		else
		{
			// calculate the right dot product
			angles 		= VectorToAngles( origin - self.origin );
			right 		= AnglesToRight( angles );
			norright	= VectorNormalize( right );
	    	rightdot 	= VectorDot( norright, norvelocity);
	    	
			if ( rightdot > 0 ) 
			{
				// right
				dynamic_icehole_crash( self, 0 );
				/*
 				self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_longc" );
				ice = spawn_anim_model("cw_ice_shards_longc", self.origin );
				ice thread anim_single_solo( ice, "ice_crash" );
				self delete();
				*/
			}
			else			
			{
				// left
				dynamic_icehole_crash( self, 1 );
				/*
				self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_longb" );
				ice = spawn_anim_model("cw_ice_shards_longb", self.origin );
				ice thread anim_single_solo( ice, "ice_crash" );
				self delete();
				*/
			}
		}
	}
}

// Play vehicle icehole crash anim for driving in. Call on entity.
play_icehole_anim( icehole )
{
	self notify("icehole_occured");
	if( isdefined( self ) && self.model == "vehicle_snowmobile" )
	{
		array_thread( self.riders, ::vehicle_crash_guy, self );
		expl_origin = self gettagorigin( "tag_passenger" );
		PhysicsExplosionCylinder( expl_origin, 300, 300, .25 );
		if( IsDefined( self.attachedguys[0] ))
			self.attachedguys[0] kill();
	}
	
	// bikes will just crash after riders die.
	if( self.model == "vehicle_chinese_brave_warrior_anim" || self.model == "vehicle_gaz_tigr_base" )
	{
		if( isdefined( self ) )
		{
			array_thread( self.riders, ::vehicle_crash_guy, self );
			expl_origin = self gettagorigin( "tag_guy1" );
			PhysicsExplosionCylinder( expl_origin, 300, 300, .25 );
		}
		
		wait .01;
		
		// calculate the car vector to velocity of car
		velocity 	= self Vehicle_GetVelocity();
		norvelocity	= VectorNormalize( velocity );
		forward 	= AnglesToForward( self.angles );
		norforward	= VectorNormalize( forward );
		cardot 		= VectorDot( norforward, norvelocity );
		
		//IPrintLnBold( "LDot: " + cardot );
				
		// calculate the cars directional dot in relation to the icehole
		noricehole	= VectorNormalize( icehole.origin - self.origin );
		dirdot 		= vectordot( norvelocity, noricehole );
		
		//IPrintLnBold( "DirDot: " + dirdot );
		
		bool = randomint(2);
		
		if ( dirdot >= .9 ) 
		{
			rand = RandomIntRange( 1, 4 );
			if( rand == 1 && !level.justplayed ) // check to see if long crash should be played
			{
				self play_long_crash();
				level.justplayed = 1;
			}
			else
			{
				dynamic_icehole_crash( self, 2 );
				level.justplayed = 0;
			}
			/*
			// head on crash.
			playfx( level._effect[ "mortar" ][ "water" ], icehole.origin );
			self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_1" );
			self delete();
			*/
		}
		else if( dirdot < .9 )
		{
			// calculate the right dot product
			angles 		= VectorToAngles( icehole.origin - self.origin );
			right 		= AnglesToRight( angles );
			norright	= VectorNormalize( right );
	    	rightdot 	= VectorDot( norright, norvelocity);
	    	
			//IPrintLnBold( "RDot: " + rightdot );
			
			if( rightdot > 0 )
			{
				if( cardot < .95 )
				{
					// if the angle of entry is less than .95, change crash.
					if ( rightdot > 0 )
					{
						
							dynamic_icehole_crash( self, 0 );
						/*
							// right side crash.					
							self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_2" );
							self delete();	
						*/
					}
					else if ( dirdot > .965 )
					{
							dynamic_icehole_crash( self, 2 );
						/*
							// head-on crash
							self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_1" );
							self delete();	
						*/
					}
					else
					{
						dynamic_icehole_crash( self, 1 );
						/*
						// left side crash.
						self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_5" );
						self delete();
						*/
					}
				}
				else
				{
						dynamic_icehole_crash( self, 1 );
						/*
					// left side crash.
					self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_2" );
					self delete();	
					*/
				}
			}
			else
			{
				if( cardot < .95 )
				{
					// if the angle of entry is less than .95, change crash.
					if ( rightdot > 0 )
					{
						dynamic_icehole_crash( self, 1 );
						/*
						// left side crash.
						self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_3" );
						self delete();	
						*/
					}
					else if ( dirdot > .965 )
					{
						dynamic_icehole_crash( self, 2 );
						/*
						// head on crash.
						self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_1" );
						self delete();	
						*/
					}
					else
					{
						dynamic_icehole_crash( self, 0 );
						/*
						// right side crash.
						self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_4" );
						self delete();
						*/	
					}
				}
				else
				{
					dynamic_icehole_crash( self, 0 );
						/*
					// right side crash.
					self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_3" );
					self delete();	
					*/
				}
			}
		}
	}
}

play_long_crash( )
{
	forward 	= AnglesToForward( self.angles );
	startpos 	= self.origin;
	endpos 		= self.origin + ( forward * 100000 );
	
	trace 		= bulletTrace( startpos, endpos, true, self );
	dist 		= DistanceSquared( self.origin, trace["position"] );
	if( dist > 20000 ) // if no object exists within 1000 units, play long crash.
	{
		thread maps\clockwork_audio::chase_sink(self.origin);
		self anim_spawn_replace_with_model( self.model, "icehole_crashes", "icehole_crash_longa" );
		iceorigin = ( self.origin[0], self.origin[1], 200 );
		ice = spawn_anim_model("cw_ice_shards_longa", iceorigin );
		ice.angles = ( 0, self.angles[1], 0 );
		ice thread anim_single_solo( ice, "ice_crash" );
		self delete();	
	}
	else
		dynamic_icehole_crash( self, 1 );
}

dynamic_icehole_crash( vehicle, direction )
{
	if( IsDefined(vehicle) )
	{
		vehicle notify( "dying" );
		vehicle.dontunloadonend = true;
	
		array_thread( vehicle.riders, ::vehicle_crash_guy, vehicle );
		vehicle thread vehicle_crash_launch_guys();
		
		if ( direction == 0 ) // right
		{
			dir = ( RandomInt( 45 ) + 45 );
		}
		else if ( direction == 1 ) // left
		{
			dir = ( 45 - RandomInt( 90 ) );
		}
		else // straight
		{
			if( randomInt( 1 ) )
				dir = RandomInt(90);
			else
				dir = RandomInt(90) + 270;
		}
		
		vehicle VehPhys_EnableCrashing();
		vector = rotate_vector( ( 0, dir, 0 ), vehicle.angles );
		vehicle VehPhys_launch( vector, 1.0 );
		
		vehicle.spline = 0;
			
		foreach ( jeep in level.enemy_jeep_s )
		{
			if ( jeep == vehicle )
			{
				vehicle.spline = 1;
				break;
			}
		}
		
		if ( vehicle.spline == 1 )
		{
			if( IsDefined( vehicle ) )
				vehicle maps\_vehicle::godoff();
			if( IsDefined( vehicle ) )
				vehicle maps\_vehicle::force_kill();
		}
		else
		{
			if( IsDefined( vehicle ) )
				vehicle waittill_still( (RandomInt( 3 ) + 1), 200 );
			if( IsDefined( vehicle ) )
				vehicle maps\_vehicle::godoff();
			if( IsDefined( vehicle ) )
				if ( randomInt( 4 ) > 3 )
					vehicle maps\_vehicle::force_kill();
		}
	}	
}

dynamic_player_crash( vehicle, direction )
{
	if ( direction == 0 ) // right
	{
		dir = ( RandomInt( 180 ) - 180 );
	}
	else if ( direction == 1 ) // left
	{
		dir = ( 0 - RandomInt( 180 ) );
	}
	else // straight
	{
		if( randomInt( 1 ) )
			dir = RandomInt(90);
		else
			dir = RandomInt(90) + 270;
	}
	
	vehicle VehPhys_EnableCrashing();
	vector = rotate_vector( ( 0, dir, 0 ), vehicle.angles );
	vehicle VehPhys_launch( vector, 1.0 );
}

#using_animtree("vehicles");
// Replace a vehicle with a model and play an animation on it.
anim_spawn_replace_with_model( model, animname, anime )
{
	org = self.origin ;
		angles = angles_clamp(self.angles);
	
	spawned = Spawn( "script_model", org );
	spawned SetModel( model );
	spawned.angles = angles;
	spawned useAnimTree( #animtree );
	spawned.animname = animname;
	spawned thread anim_single_solo( spawned, anime);
	
	return spawned;
}

angles_clamp(v)
{
	return (0, v[1], 0);
}

// Adaptation of spline code to spawn vehicle at spawner instead of using the spline spawn logic.
spawn_enemy_bike_at_spawer(targetname)
{
	player_targ = get_player_targ();
	player_progress = get_player_progress();
	spawn_array = get_spawn_position( player_targ, player_progress - 1000 - level.POS_LOOKAHEAD_DIST );
	
	targ = spawn_array["targ"];
	
	snowmobile_spawner = getent( targetname, "targetname" );
	
	bike = vehicle_spawn( snowmobile_spawner );
	bike.offset_percent = spawn_array["offset"];
	bike VehPhys_SetSpeed( 90 );
	
	bike thread crash_detection();
	bike.left_spline_path_time = gettime() - 3000;
	targ thread bike_drives_path( bike );
	
	return bike;
}

// driver kill code
driver_dies( vehicle )
{
	if( IsDefined(vehicle) && IsDefined(vehicle.driver))
	{
		vehicle.driver waittill("death");
	
		if( IsDefined(vehicle) )
		{
			vehicle notify( "dying" );
			vehicle.dontunloadonend = true;
		
			array_thread( vehicle.riders, ::vehicle_crash_guy, vehicle );
			vehicle thread vehicle_crash_launch_guys();
			
			vehicle VehPhys_EnableCrashing();
			vector = rotate_vector( ( 64, ( RandomInt( 512 ) - 256 ), 0 ), vehicle.angles );
			vehicle VehPhys_launch( (vector * 2), 1.0 );
			
			if( vehicle.spline == 1 )
			{				
				wait 1;
				
				if( IsDefined( vehicle ) )
					vehicle maps\_vehicle::godoff();
				if( IsDefined( vehicle ) )
					vehicle maps\_vehicle::force_kill();
			}
			else
			{
				if( IsDefined( vehicle ) )
					vehicle waittill_still( (RandomInt( 3 ) + 1), 200 );
				if( IsDefined( vehicle ) )
					vehicle maps\_vehicle::godoff();
				if( IsDefined( vehicle ) )
					if ( randomInt( 4 ) >= 3 )
						vehicle maps\_vehicle::force_kill();
			}
		}
	}
}

vehicle_crash_guy( vehicle )
{
	if ( !IsDefined( self ) || self.vehicle_position == 0 )
	{
		return;
	}
	else 
	{
		self.deathanim = undefined;
		self.noragdoll = undefined;
		vehicle.riders = array_remove( vehicle.riders, self );

		self.ragdoll_immediate = true;
		
		if( IsDefined( self ) )
		{
			if( !IsDefined( self.magic_bullet_shield ) )
				self kill();
		}
	}
}

vehicle_crash_launch_guys()
{
	wait 0.1;  // .1 longer wait then the one in vehicle_crash_guy
	if( IsDefined( self ) )
	{
		expl_origin = self gettagorigin( "tag_guy1" );
		PhysicsExplosionCylinder( expl_origin, 300, 300, .25 );
	}
}

waittill_still( timeout, still_point )
{
	mytimeOutEnt( timeout ) endon ( "timeout" );

	if ( !isdefined( still_point ) )
		still_point = 50;

	velocity = self Vehicle_GetVelocity();
	velocity = abs( velocity[0] ) + abs( velocity[1] ) + abs( velocity[2] );

	while( velocity > still_point )
	{
		if( IsDefined( self ) )
			velocity = self Vehicle_GetVelocity();
		else
			break;
		velocity = abs( velocity[0] ) + abs( velocity[1] ) + abs( velocity[2] );
		wait 0.05;
	}
}

rotate_vector( vector, rotation )
{
	right = anglestoright( rotation ) * -1;
	forward = anglestoforward( rotation );
	up = anglestoup( rotation );
	new_vector = forward * vector[ 0 ] + right * vector[ 1 ] + up * vector[ 2 ];
	return new_vector;
}

mytimeOutEnt( timeOut )
{
	ent = spawnstruct();
	ent delaythread( timeOut, ::send_notify, "timeout" );
	return ent;
}

#using_animtree( "vehicles" );
player_viewhands_minigun( turret, viewhands_model )
{
	level.player endon( "missionend" );
	/*
	viewhands = spawn_anim_model( "suburban_hands", turret getTagOrigin( "tag_player" ) );
	viewhands.angles = turret getTagAngles( "tag_player" );
	viewhands linkto( turret, "tag_player" );
	
	viewhands setAnim( viewhands getanim( "idle_L" ), 1, 0, 1 );
	viewhands setAnim( viewhands getanim( "idle_R" ), 1, 0, 1 );
	
	viewhands thread player_viewhands_minigun_hand( "LEFT" );
	viewhands thread player_viewhands_minigun_hand( "RIGHT" );
	*/
	if (!isdefined(viewhands_model))
		viewhands_model = "viewhands_player_us_army";
	
	turret useAnimTree( #animtree );
	turret.animname = "suburban_hands";
	turret.has_hands = false;
	turret show_hands(viewhands_model);
	turret set_idle();
	
	turret thread player_viewhands_minigun_hand( "LEFT" );
	turret thread player_viewhands_minigun_hand( "RIGHT" );
	turret thread handle_mounting(viewhands_model);
}

set_idle()
{
	self setAnim( %player_suburban_minigun_idle_L, 1, 0, 1 );
	self setAnim( %player_suburban_minigun_idle_R, 1, 0, 1 );
	
}

handle_mounting(viewhands_model)
{
    turret = self;
    turret endon ( "death" );
    while( true )
    {
        turret waittill ( "turretownerchange" );
        owner = turret GetTurretOwner();
        if ( !IsAlive( owner ) )
            hide_hands(viewhands_model);
        else
            show_hands(viewhands_model);
    }
    
}

show_hands( viewhands_model )
{
	if (!isdefined(viewhands_model))
		viewhands_model = "viewhands_player_us_army";
    turret = self;
    Assert( turret.code_classname == "misc_turret" );
    Assert( IsDefined( turret.has_hands ) );
    if( turret.has_hands )
        return;
    turret DontCastShadows();
	turret.has_hands = true;
	turret attach( viewhands_model, "tag_player" );
}

hide_hands(viewhands_model)
{
	if (!isdefined(viewhands_model))
		viewhands_model = "viewhands_player_us_army";
    turret = self;
    Assert( turret.code_classname == "misc_turret" );
    Assert( IsDefined( turret.has_hands ) );
    if( ! turret.has_hands )
        return;
	turret CastShadows();        
	turret.has_hands = false;
	turret detach( viewhands_model, "tag_player" );
    
}

#using_animtree( "vehicles" );
//anim_minigun_hands()
//{
//	level.scr_animtree[ "suburban_hands" ] 							 		= #animtree;
//	level.scr_model[ "suburban_hands" ] 									= "viewhands_player_us_army";
//	level.scr_anim[ "suburban_hands" ][ "idle_L" ]						 	= %player_suburban_minigun_idle_L;
//	level.scr_anim[ "suburban_hands" ][ "idle_R" ]						 	= %player_suburban_minigun_idle_R;
//	level.scr_anim[ "suburban_hands" ][ "idle2fire_L" ]						= %player_suburban_minigun_idle2fire_L;
//	level.scr_anim[ "suburban_hands" ][ "idle2fire_R" ]						= %player_suburban_minigun_idle2fire_R;
//	level.scr_anim[ "suburban_hands" ][ "fire2idle_L" ]						= %player_suburban_minigun_fire2idle_L;
//	level.scr_anim[ "suburban_hands" ][ "fire2idle_R" ]						= %player_suburban_minigun_fire2idle_R;
//	
//	//
//	//
//}

player_viewhands_minigun_hand( hand )
{
	self endon( "death" );
	level.player endon( "missionend" );
	checkFunc = undefined;
	if ( hand == "LEFT" )
		checkFunc = ::spinButtonPressed;
	else if ( hand == "RIGHT" )
		checkFunc = ::fireButtonPressed;
	assert( isdefined( checkFunc ) );
	
	animHand = undefined;
	if ( hand == "LEFT" )
		animHand = "L";
	else if ( hand == "RIGHT" )
		animHand = "R";
	assert( isdefined( animHand ) );
	
	for(;;)
	{
		if( flag("hand_wait") )
		{
			self clearAnim( self getanim( "fire2idle_" + animHand ), 0.2 );
			flag_clear("hand_wait"); // clear flag before waiting
			flag_wait("hand_wait");
			flag_clear("hand_wait"); // clear flag before leaving to prevent this from happening again
		}
		if( level.player [[checkFunc]]() )
		{
			thread player_viewhands_minigun_presed( hand );
			while( level.player [[checkFunc]]() )
				wait 0.05;
		}
		else
		{
			thread player_viewhands_minigun_idle( hand );
			while( !level.player [[checkFunc]]() )
				wait 0.05;
		}
	}
}

spinButtonPressed()
{
	if ( level.player AdsButtonPressed() )
		return true;
	if ( level.player AttackButtonPressed() )
		return true;
	return false;
}

fireButtonPressed()
{
	return level.player AttackButtonPressed();
}

player_viewhands_minigun_idle( hand )
{
	level.player endon( "missionend" );
	animHand = undefined;
	if ( hand == "LEFT" )
		animHand = "L";
	else if ( hand == "RIGHT" )
		animHand = "R";
	assert( isdefined( animHand ) );
	
	self clearAnim( self getanim( "idle2fire_" + animHand ), 0.2 );
	self setFlaggedAnimRestart( "anim", self getanim( "fire2idle_" + animHand ) );
	self waittillmatch( "anim", "end" );
	self clearAnim( self getanim( "fire2idle_" + animHand ), 0.2 );
	self setAnim( self getanim( "idle_" + animHand ) );
}

player_viewhands_minigun_presed( hand )
{
	level.player endon( "missionend" );
	animHand = undefined;
	if ( hand == "LEFT" )
		animHand = "L";
	else if ( hand == "RIGHT" )
		animHand = "R";
	assert( isdefined( animHand ) );
	
	self clearAnim( self getanim( "idle_" + animHand ), 0.2 );
	self setAnim( self getanim( "idle2fire_" + animHand ) );
}

//*** Ice Effects for Vehicles ***//
// init ice effects for vehicles
ice_effects_init()
{
	if ( !IsDefined( anim._effect ) )
		anim._effect = [];
	
	anim._effect[ "snowmobile_leftground" ] = LoadFX( "fx/treadfx/bigair_snow_night_emitter" );
	anim._effect[ "snowmobile_bumpbig"	  ] = LoadFX( "fx/treadfx/bigjump_land_snow_night" );
	anim._effect[ "snowmobile_bump"		  ] = LoadFX( "fx/treadfx/smalljump_land_snow_night" );
	anim._effect[ "snowmobile_sway_left"	] = loadfx( "fx/treadfx/leftturn_snow_night" );
	anim._effect[ "snowmobile_sway_right"	] = loadfx( "fx/treadfx/rightturn_snow_night" );
	anim._effect[ "snowmobile_collision"	] = loadfx( "fx/treadfx/bigjump_land_snow_night" );	
}

snowmobile_sounds()
{
	self thread sm_listen_leftground();
	self thread sm_listen_landed();
	self thread sm_listen_jolt();
	self thread sm_listen_collision();
}

sm_listen_leftground()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_leftground" );
		thread maps\clockwork_audio::chase_sm_leftground(self.origin);
		
		if ( self.kill_my_fx == 0 )
		{
			self.event_time						= GetTime();
			
			wait 1;
		}
	}
}

sm_listen_landed()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_landed" );
		if ( self.kill_my_fx == 0 )
		{
			if ( self.event_time + self.bigjump_timedelta < GetTime() )
			{
				thread maps\clockwork_audio::chase_sm_collision(self.origin);
			}
			else
			{
				thread maps\clockwork_audio::chase_sm_collision(self.origin);
			}
		}
	}
}

sm_listen_jolt()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_jolt", jolt );
		if ( self.kill_my_fx == 0 )
		{
			if ( jolt[ 1 ]  >= 0 )
			{
				thread maps\clockwork_audio::chase_sm_collision(self.origin);
			}
			else
			{
				thread maps\clockwork_audio::chase_sm_collision(self.origin);
			}
		}
	}
}

sm_listen_collision()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_collision", collision, start_vel );
				
		if ( self.kill_my_fx == 0 )	
		{
			thread maps\clockwork_audio::chase_sm_collision(self.origin);
		}
	}
}


// call on each vehicle
start_ice_effects()
{
	self.bigjump_timedelta = 500;
	self.event_time		   = -1;

	self thread listen_leftground();
	self thread listen_landed();
	self thread listen_jolt();
	self thread listen_collision();
	self thread listen_vehicle_roof();
	self thread listen_vehicle_death();
}

listen_vehicle_roof()
{
	pos1 = spawn_tag_origin();
	pos1.angles  = self GetTagAngles( "tag_turret" );
	pos1.origin  = self GetTagOrigin( "tag_turret" );
	pos1.origin  = pos1.origin + ( 32, 32, 0 );
	pos1 LinkTo( self, "tag_turret" );
	
	pos2 = spawn_tag_origin();
	pos2.angles  = self GetTagAngles( "tag_turret" );
	pos2.origin  = self GetTagOrigin( "tag_turret" );
	pos2.origin  = pos2.origin + ( -32, 32, 0 );
	pos2 LinkTo( self, "tag_turret" );
	
	pos3 = spawn_tag_origin();
	pos3.angles  = self GetTagAngles( "tag_turret" );
	pos3.origin  = self GetTagOrigin( "tag_turret" );
	pos3.origin  = pos3.origin + ( 32, -32, 0 );
	pos3 LinkTo( self, "tag_turret" );
	
	pos4 = spawn_tag_origin();
	pos4.angles  = self GetTagAngles( "tag_turret" );
	pos4.origin  = self GetTagOrigin( "tag_turret" );
	pos4.origin  = pos4.origin + ( -32, -32, 0 );
	pos4 LinkTo( self, "tag_turret" );	
	
	wait 5;
	
	while( isalive(self) && IsDefined(self) && self.veh_speed > 5 )
	{
		/*if( pos1.origin[2] < 224 && pos2.origin[2] < 224 && pos3.origin[2] < 224 && pos4.origin[2] < 224 )
	{
			thread maps\clockwork_audio::chase_land_roof(pos1.origin);
			fxplayfrom = drop_to_ground( pos1.origin, 224, 0 );
			playfx( loadfx( "fx/explosions/grenadeExp_snow" ), fxplayfrom );
			//PlayFXOnTag( loadfx( "fx/explosions/grenadeExp_snow" )	, pos1, "tag_origin" );
		}
		else */
		if( pos1.origin[2] < 224 )
		{
			thread maps\clockwork_audio::chase_land_roof(pos1.origin);
			fxplayfrom = drop_to_ground( pos1.origin, 224, 0 );
			playfx( loadfx( "fx/treadfx/smalljump_land_snow_night" ), fxplayfrom );
			//PlayFXOnTag( loadfx( "fx/explosions/grenadeExp_snow" )	, pos1, "tag_origin" );
		}
		else if( pos2.origin[2] < 224 )
		{
			thread maps\clockwork_audio::chase_land_roof(pos2.origin);
			fxplayfrom = drop_to_ground( pos2.origin, 224, 0 );
			playfx( loadfx( "fx/treadfx/smalljump_land_snow_night" ), fxplayfrom );
			//PlayFXOnTag( loadfx( "fx/explosions/grenadeExp_snow" )	, pos2, "tag_origin" );			
		}
		else if( pos3.origin[2] < 224 )
		{
			thread maps\clockwork_audio::chase_land_roof(pos3.origin);
			fxplayfrom = drop_to_ground( pos3.origin, 224, 0 );
			playfx( loadfx( "fx/treadfx/smalljump_land_snow_night" ), fxplayfrom );
			//PlayFXOnTag( loadfx( "fx/explosions/grenadeExp_snow" )	, pos3, "tag_origin" );
		}
		else if( pos4.origin[2] < 224 )
		{
			thread maps\clockwork_audio::chase_land_roof(pos4.origin);
			fxplayfrom = drop_to_ground( pos4.origin, 224, 0 );
			playfx( loadfx( "fx/treadfx/smalljump_land_snow_night" ), fxplayfrom );
			//PlayFXOnTag( loadfx( "fx/explosions/grenadeExp_snow" )	, pos4, "tag_origin" );
		}
		wait .5;
	}
	
	self notify( "kill_tread" );
	
	pos1 delete();
	pos2 delete();
	pos3 delete();
	pos4 delete();
	
	wait( 10 );
	if ( isdefined( self ) )
	{
		self delete();
	}
}

snowmobile_fx( fxName )
{
	if( self.model == "vehicle_chinese_brave_warrior_anim" )
		if ( IsDefined( anim._effect[ fxName ] ) )
			PlayFXOnTag( anim._effect[ fxName ], self, "tag_deathfx" );
			//println( fxName );
			
	if( self.model == "vehicle_gaz_tigr_base" )
		if ( IsDefined( anim._effect[ fxName ] ) )
			PlayFXOnTag( anim._effect[ fxName ], self, "tag_guy0" );
			//println( fxName );
}

listen_leftground()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_leftground" );
		thread maps\clockwork_audio::chase_leftground(self.origin);
		if ( !isdefined( self.kill_my_fx ) )
		{
			self.event_time						= GetTime();
			snowmobile_fx( "snowmobile_leftground" );
		}
	}
}

listen_vehicle_death()
{
	max_dist = 2000;
	self waittill("death");
	
	if(isDefined(self))
	{
		dist = Distance(level.player.origin, self.origin);
		if(dist < max_dist)
		{
			thread maps\clockwork_audio::chase_crashmix(self.origin);
		}
	}
	else
	{
		//nada
	}
}

listen_landed()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_landed" );
		if ( !isdefined( self.kill_my_fx ) )
		{
			if ( self.event_time + self.bigjump_timedelta < GetTime() )
			{
				thread maps\clockwork_audio::chase_land_tires_big(self.origin);
				snowmobile_fx( "snowmobile_bumpbig" );
			}
			else
			{
				thread maps\clockwork_audio::chase_land_tires_small(self.origin);
				snowmobile_fx( "snowmobile_bump" );
			}
		}
	}
}

listen_jolt()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_jolt", jolt );
		if ( !isdefined( self.kill_my_fx ) )
		{
			if ( jolt[ 1 ]  >= 0 )
			{
				snowmobile_fx( "snowmobile_sway_left" );
				thread maps\clockwork_audio::chase_collision(self.origin);
			}
			else
			{
				snowmobile_fx( "snowmobile_sway_right" );
				thread maps\clockwork_audio::chase_collision(self.origin);
			}
		}
	}
}

listen_collision()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "veh_collision", collision, start_vel );
		thread maps\clockwork_audio::chase_collision(self.origin);
		
		if ( !isdefined( self.kill_my_fx ) )	
		{
			snowmobile_fx( "snowmobile_collision" );
		}
	}
}

listen_player_collision()
{
	while( 1 )
	{
		self waittill( "veh_collision", collision, start_vel );
		thread maps\clockwork_audio::chase_player_collision();
		
		if ( !isdefined( self.kill_my_fx ) )	
		{
			snowmobile_fx( "snowmobile_collision" );
			screenshakeFade( .35, 1 );
		}
	}
}

listen_player_jolt()
{
	while( 1 )
	{
		self waittill( "veh_jolt", jolt );
		if ( !isdefined( self.kill_my_fx ) )
		{
			if ( jolt[ 1 ]  >= 0 )
			{
				thread maps\clockwork_audio::chase_player_jolt();
				snowmobile_fx( "snowmobile_sway_left" );
				snowmobile_fx( "sparks" );
				thread screen_shake_exfil();
			}
			else
			{
				thread maps\clockwork_audio::chase_player_jolt();
				snowmobile_fx( "snowmobile_sway_right" );
				snowmobile_fx( "sparks" );
				thread screen_shake_exfil();
			}
		}
			}
		}

screen_shake_exfil()
{
	thread play_rumble_seconds( "damage_heavy", 1 );
	screenshakefade( 0.08, .75, .01, .25 );
	screenshakefade( 0.05, .25 );
	screenshakefade( 0.08, .5, .25,  .01 );
}

play_rumble_seconds( damage_name, seconds )
{
	for ( i = 0; i < ( seconds * 20 ); i++ )
	{
		level.player PlayRumbleOnEntity( damage_name );	
		wait 0.05;
	}
}

//throwbot_use()
//{
//	/*
//	throwbots = GetEntArray( "grenade", "classname" );
//			
//	foreach ( throwbot in throwbots )
//	{
//		if ( throwbot.model == "vehicle_scooter_vespa_wheel" )
//		{
//			level.throwbot = throwbot;
//			break;
//		}
//	}
//	
//	self.old_origin = self.origin;
//	self.old_angles = self.angles;
//	self.old_stance = self GetStance();
//	self.origin = level.throwbot.origin;
//	self.angles = ( 0, level.throwbot.angles[ 1 ], 0 );
//	
//	level.throwbot Delete();
//	
//	slideModel = Spawn( "script_origin", self.origin );
//	slideModel.angles = self.angles;
//	self.slideModel = slideModel;
//
//	level.throwbot_wheel_left = spawn_tag_origin();
//	level.throwbot_wheel_left SetModel( "vehicle_scooter_vespa_wheel" );
//	level.throwbot_wheel_left Show();
//	level.throwbot_wheel_left.slideModel = slideModel;
//	level.throwbot_wheel_left.origin = ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] + 32 ) + AnglesToForward( self.angles ) * 10  -
//		AnglesToRight( self.angles ) * 15;
//	level.throwbot_wheel_left.angles = ( self.angles[ 0 ], self.angles[ 1 ] + 180, self.angles[ 2 ] );
//	
//	level.throwbot_wheel_right = spawn_tag_origin();
//	level.throwbot_wheel_right SetModel( "vehicle_scooter_vespa_wheel" );
//	level.throwbot_wheel_right Show();
//	level.throwbot_wheel_right.slideModel = slideModel;
//	level.throwbot_wheel_right.origin = ( self.origin[ 0 ], self.origin[ 1 ], self.origin[ 2 ] + 32 ) + AnglesToForward( self.angles ) * 10  +
//		AnglesToRight( self.angles ) * 15;
//	level.throwbot_wheel_right.angles = ( self.angles[ 0 ], self.angles[ 1 ], self.angles[ 2 ] );
//	
//	self setstance( "crouch" );
//	self allowProne( false );
//	self allowCrouch( true );
//	self allowStand( false );
//	
//	self HideViewModel();
//	self DisableWeaponSwitch();
//	self DisableOffhandWeapons();
//	self EnableHealthShield( true );
//	self EnableDeathShield( true );
//	self EnableInvulnerability();	
//	self.last_weapon = self GetCurrentWeapon();
//	SetSavedDvar( "cg_fov", 90 );
//	SetSavedDvar( "ammoCounterHide", "1" );
//	SetSavedDvar( "actionSlotsHide", "1" );
//	SetSavedDvar( "compass", 0 );
//	self DisableWeapons();
//	self.using_throwbot = true;
//	
//	self PlayerLinkToDelta( slideModel, undefined, 1, 0, 0, 0, 0, true );
//	level.throwbot_wheel_left LinkTo( slideModel );
//	level.throwbot_wheel_right LinkTo( slideModel );
//	self.slideModel MoveSlide( ( 0, 0, 15 ), 15, ( 0, 0, 0 ) );
//	
//	self Show();
//	
//	self thread throwbot_drive_thread();
//	self thread throwbot_demolition_thread();
//	self thread throwbot_watch_exit();
//	self thread throwbot_hud();
//	self thread throwbot_detonate_timer();
//	*/
//}
//
//throwbot_exit()
//{
//	self notify( "exit_throwbot" );
//	level notify( "exit_throwbot" );
//	
//	self.using_throwbot = undefined;
//	
//	if ( IsDefined( level.player.timer_textelem ) )
//	{
//		level.player.timer_textelem Destroy();
//	}
//	
//	if ( IsDefined( level.player.timer_bar ) )
//	{
//		level.player.timer_bar Destroy();
//	}
//	
//	self Unlink();
//	if ( IsDefined( self.throwbot_exploded ) && self.throwbot_exploded )
//	{
//		self SetPlayerAngles( VectorToAngles( self.origin - self.old_origin ) );
//		self.throwbot_exploded = undefined;
//	}
//	else
//	{
//		self SetPlayerAngles( self.old_angles );
//	}
//	self SetOrigin( self.old_origin );
//	self ShowViewModel();
//	self SwitchToWeaponImmediate( self.last_weapon );
//	self EnableWeaponSwitch();
//	self EnableOffhandWeapons();
//	self EnableWeapons();
//	self EnableHealthShield( false );
//	self EnableDeathShield( false );
//	self DisableInvulnerability();
//	SetSavedDvar( "cg_fov", 65 );
//	SetSavedDvar( "ammoCounterHide", "0" );
//	SetSavedDvar( "actionSlotsHide", "0" );
//	SetSavedDvar( "compass", 1 );
//	
//	self setstance( self.old_stance );
//	self allowProne( true );
//	self allowCrouch( true );
//	self allowStand( true );
//	
//	self Hide();
//	
//	if ( IsDefined( level.throwbot_wheel_left ) )
//	{
//		level.throwbot_wheel_left Delete();
//		level.throwbot_wheel_left = undefined;
//	}
//	
//	if ( IsDefined( level.throwbot_wheel_right ) )
//	{
//		level.throwbot_wheel_right Delete();
//		level.throwbot_wheel_right = undefined;
//	}
//}
//
//throwbot_hud()
//{
//	/*
//	// Hint
//	thread throwbot_hint();
//	
//	// Target shaders
//	thread update_throwbot_targets();
//
//	// Vision set and overlays	
//	self VisionSetNakedForPlayer( "ac130_enhanced", 0.0 );
//	hud_elem = newClientHudElem( self );
//	hud_elem.x = 0;
//	hud_elem.y = 0;
//	hud_elem.alignX = "left";
//	hud_elem.alignY = "top";
//	hud_elem.horzAlign = "fullscreen";
//	hud_elem.vertAlign = "fullscreen";
//	hud_elem setshader( "remote_chopper_overlay_scratches", 640, 480 );
//	hud_elem.alpha = 0.4;
//	hud_elem.sort = -3;
//	
//	level waittill( "exit_throwbot" );
//	
//	// Remove target shaders
//	foreach ( target in Target_GetArray() )
//	{
//		Target_Remove( target );
//		target.has_target_shader = undefined;
//	}
//	
//	// Restore visionset and remove overlays
//	self VisionSetNakedForPlayer( "clockwork", 0.0 );
//	hud_elem Destroy();
//	*/
//}
//
//throwbot_hint()
//{
//	level notify( "watch_remove_hint" );
//	
//	level.player ForceUseHintOff();
//	
//	wait 0.5;
//		
//	level.player.force_hint = "throwbot";
//	level.player ForceUseHintOn( &"CLOCKWORK_HINT_DETONATE" );
//	
//	wait 3;
//	
//	level.player ForceUseHintOff();
//	level.player.force_hint = undefined;
//}
//
//update_throwbot_targets()
//{
//	level endon( "exit_throwbot" );
//	
//	while ( 1 )
//	{
//		foreach ( ai in GetAIArray() )
//		{
//			if ( !IsDefined( ai ) || ( IsDefined( ai.has_target_shader ) && ai.has_target_shader ) )
//			{
//				continue;
//			}
//
//			ai.has_target_shader = true;
//			Target_Set( ai, ( 0, 0, 0 ) );
//			
//			if ( ai.team == "axis" )
//			{
//				Target_SetShader( ai, "remote_chopper_hud_target_enemy" );
//				Target_SetOffscreenShader( ai, "veh_hud_target_offscreen" );
//			}
//			else
//			{
//				Target_SetShader( ai, "remote_chopper_hud_target_friendly" );
//			}
//			
//			Target_ShowToPlayer( ai, level.player );
//			Target_SetScaledRenderMode( ai, true );
//			
//			ai thread remove_throwbot_target_on_death();
//			
//			wait 0.05;
//		}
//		
//		wait 0.05;
//	}
//}
//
//remove_throwbot_target_on_death()
//{
//	level endon( "exit_throwbot" );
//	
//	self waittill( "death" );
//	
//	if ( IsDefined( self ) && Target_IsTarget( self ) )
//	{
//		Target_Remove( self );
//	}
//}
//
//throwbot_drive_thread()
//{
//	self endon( "exit_throwbot" );
//	
//	max_speed = 616; // 35 mph
//	max_turn_rate = 270; // 270 degrees per second
//	
//	velocity = AnglesToForward( self.angles ) * 200 - ( 0, 0, 200 );
//	grav_velocity = 0;
//	old_z = self.origin[ 2 ] + 800;
//	
//	while ( self.origin[ 2 ] != old_z )
//	{
//		self.slideModel.slideVelocity = velocity;
//		
//		grav_velocity += 1600 * 0.05;
//		
//		velocity -= ( 0, 0, grav_velocity );
//		
//		old_z = self.origin[ 2 ];
//
//		wait 0.05;
//	}
//	
//	while ( 1 )
//	{
//		left_stick = self GetNormalizedMovement();
//		right_stick = self GetNormalizedCameraMovement();
//		
//		speed = max_speed * left_stick[ 0 ];
//		new_yaw = ( 0 - right_stick[ 1 ] ) * max_turn_rate * 0.05;
//		
//		velocity = speed * AnglesToForward( self.slideModel.angles );
//		
//		self.slideModel AddYaw( new_yaw );
//		self.slideModel.slideVelocity = velocity - ( 0, 0, 800 );
///*		
//		level.throwbot_wheel_left Unlink();
//		level.throwbot_wheel_right Unlink();
//		level.throwbot_wheel_left AddPitch( left_stick[ 0 ] * -360 * 0.05 );
//		level.throwbot_wheel_right AddPitch( left_stick[ 0 ] * 360 * 0.05 );
//		level.throwbot_wheel_left LinkTo( self.slideModel );
//		level.throwbot_wheel_right LinkTo( self.slideModel );
//*/
//		wait 0.05;
//	}
//}
//
//throwbot_damage_thread()
//{
//	self endon( "exit_throwbot" );
//	
//}
//
//throwbot_demolition_thread()
//{
//	self endon( "exit_throwbot" );
//	
//	self NotifyOnPlayerCommand( "throwbot_explode", "+attack" );
//	
//	self waittill( "throwbot_explode" );
//	
//	RadiusDamage( self.origin, 240, 500, 10, self );
//	PlayFX( getfx( "throwbot_explode" ), self.origin );
//	
//	self.throwbot_exploded = true;
//	
//	self notify( "throwbot_exploded" );
//}
//
//throwbot_detonate_timer()
//{
//	self endon( "exit_throwbot" );
//	
//	time = 5.0;
//	x = -5;
//	y = -40;
//	
//	level.player.timer_textelem = newHudElem();
//	level.player.timer_textelem.x = x;
//	level.player.timer_textelem.y = y;
//	level.player.timer_textelem.alignX = "left";
//	level.player.timer_textelem.alignY = "bottom";
//	level.player.timer_textelem.horzAlign = "center";
//	level.player.timer_textelem.vertAlign = "bottom";
//	level.player.timer_textelem setText( time );
//
//	level.player.timer_bar = newHudElem();
//	level.player.timer_bar.x = 0;
//	level.player.timer_bar.y = y + 20;
//	level.player.timer_bar.alignX = "center";
//	level.player.timer_bar.alignY = "bottom";
//	level.player.timer_bar.horzAlign = "center";
//	level.player.timer_bar.vertAlign = "bottom";
//	level.player.timer_bar setshader( "black", 1, 8 );
//	
//	timeleft = time;
//	updateText = false;
//	
//	while ( timeleft > 0.0 )
//	{
//		wait 0.05;
//		timeleft -= 0.05;
//	
//		width = max( timeleft * 10, 1 );
//		width = int( width );
//
//		if ( updateText )
//		{
//			if ( timeleft < 1 )
//			{
//				timeleft = int( timeleft * 10 ) / 10;
//			}
//			
//			level.player.timer_textelem setText( timeleft );
//			updateText = false;
//		}
//		else
//		{
//			updateText = true;
//		}
//		
//		level.player.timer_bar setShader( "black", width, 8 );
//	}
//	
//	level.player.timer_textelem Destroy();
//	level.player.timer_bar Destroy();
//	level.player.timer_textelem = undefined;
//	level.player.timer_bar = undefined;
//	
//	RadiusDamage( self.origin, 240, 500, 10, self );
//	PlayFX( getfx( "throwbot_explode" ), self.origin );
//	
//	self.throwbot_exploded = true;
//	
//	self notify( "throwbot_exploded" );
//}
//
//throwbot_watch_exit()
//{
//	self waittill( "throwbot_exploded" );
//	
//	self throwbot_exit();
//}
//
//autobot_use()
//{
//	throwbots = GetEntArray( "grenade", "classname" );
//			
//	foreach ( throwbot in throwbots )
//	{
//		if ( throwbot.model == "vehicle_scooter_vespa_wheel" )
//		{
//			level.autobot = throwbot;
//			break;
//		}
//	}
///*
//	level.autobot = spawn_tag_origin();
//	level.autobot SetModel( "vehicle_scooter_vespa_wheel" );
//	level.autobot Show();
//	level.autobot.origin = self.origin + AnglesToForward( self.angles ) * 30 + ( 0, 0, 60 );
//	level.autobot.angles = self.angles;
//	
//	level.autobot PhysicsLaunchServer( level.autobot.origin, ( AnglesToForward( self.angles ) + AnglesToUp( self.angles ) ) * 7500.0 );
//*/	
//	level.autobot thread autobot_wait_for_landing();
//	level.autobot thread autobot_drive_thread();
//	
//	level.player notify( "used_autobot" );
//}
//
//autobot_wait_for_landing()
//{
//	old_origin = self.origin;
//	
//	wait 0.05;
//	
//	while ( old_origin[ 2 ] != self.origin[ 2 ] )
//	{
//		old_origin = self.origin;
//		wait 0.05;
//	}
//	
//	self notify( "drive" );
//}
//
//autobot_drive_thread()
//{
//	/*
//	self waittill( "drive" );
//	
//	autobot_ai_spawner = GetEnt( "throwbot_ai_spawner", "targetname" );
//	
//	autobot_ai = autobot_ai_spawner spawn_ai( true, true );
//	autobot_ai.moveplaybackrate = 2.5;
//	autobot_ai.grenadeawareness = 0;
//	autobot_ai.ignoreexplosionevents = true;
//	autobot_ai.ignorerandombulletdamage = true;
//	autobot_ai.ignoresuppression = true;
//	autobot_ai.fixednode = false;
//	autobot_ai.disableBulletWhizbyReaction = true;
//	autobot_ai disable_pain();
//	autobot_ai.newEnemyReactionDistSq = 0;
//	autobot_ai Hide();
//	ground_pos = PhysicsTrace( self.origin, self.origin - ( 0, 0, 500 ) );
//	level.autobot = spawn_tag_origin();
//	level.autobot SetModel( "vehicle_scooter_vespa_wheel" );
//	level.autobot Show();
//	level.autobot.origin = ground_pos;
//	level.autobot.angles = self.angles;
//	self Delete();
//	autobot_ai Teleport_Ent( level.autobot );
//	level.autobot LinkTo( autobot_ai, "", ( 0, 0, 10 ), ( 0, 0, 0 ) );
//	
//	autobot_ai.target_enemy = autobot_ai autobot_find_enemy();
//	
//	autobot_ai.goalRadius = 50;
//	
//	while ( IsDefined( autobot_ai.target_enemy ) && DistanceSquared( autobot_ai.origin, autobot_ai.target_enemy.origin ) > 2500 )
//	{
//		wait 0.05;
//	}
//
//	autobot_ai stop_magic_bullet_shield();
//	autobot_ai Delete();
//	
//	if ( IsDefined( autobot_ai.target_enemy ) )
//	{
//		RadiusDamage( level.autobot.origin + ( 0, 0, 30 ), 240, 500, 75 );
//		PlayFX( getfx( "throwbot_explode" ), level.autobot.origin );
//	}
//	
//	level.autobot Delete();
//	*/
//}
//
//autobot_find_enemy()
//{
//	enemies = GetAIArray( "axis" );
//	
//	allies = GetAIArray( "allies" );
//	
//	closest_distance = -1;
//	target_enemy = undefined;
//	
//	foreach ( enemy in enemies )
//	{
//		if ( enemy.origin[ 2 ] - self.origin[ 2 ] < 10 )
//		{
//			too_close_to_allies = false;
//			
//			foreach ( ally in allies )
//			{
//				if ( DistanceSquared( ally.origin, enemy.origin ) < 2500 )
//				{
//					too_close_to_allies = true;
//					break;
//				}
//			}
//			
//			if ( !too_close_to_allies )
//			{
//				dist = DistanceSquared( self.origin, enemy.origin );
//				
//				if ( closest_distance == -1 || dist < closest_distance )
//				{
//					closest_distance = dist;
//					target_enemy = enemy;
//				}
//			}
//		}
//	}
//	
//	if ( IsDefined( target_enemy ) )
//	{	
//		self SetGoalEntity( target_enemy, 5 );
//		
//		self thread autobot_monitor_enemy_target( target_enemy );
//	
//		return target_enemy;
//	}
//	
//	return undefined;
//}
//
//autobot_monitor_enemy_target( target_enemy )
//{
//	self endon(	"death" );
//	
//	target_enemy waittill( "death" );
//	
//	self.target_enemy = self autobot_find_enemy();
//}
//
//look_at_watch( anim_root, anim_name, cinematic_name, anim_root_tag, clock_intro )
//{
//	SetSavedDvar( "cg_cinematicFullScreen", "0" );
//	
//	
//	player_arms = spawn_anim_model( "player_rig" );
//	watch = spawn_anim_model( "player_rig" );
//	watch SetModel( "clk_watch_viewhands" );
////	watch SetModel( "viewmodel_helmet_goggles" );
//
//	thread watch_light_fx( player_arms, watch );
//	thread watch_tick( watch );
//	
//	root = anim_root;
//	
//	if ( IsDefined( anim_root_tag ) )
//	{		
//		root = Spawn( "script_origin", anim_root.origin );
//		root.origin = anim_root GetTagOrigin( anim_root_tag );
//		root.angles = level.player GetPlayerAngles();
//		root LinkTo( anim_root, anim_root_tag );
//		
//		player_arms.origin = root.origin;
//		player_arms.angles = root.angles;
//		player_arms LinkTo( anim_root, anim_root_tag );
//		
//		watch.origin = root.origin;
//		watch.angles = root.angles;
//		watch LinkTo( anim_root, anim_root_tag );
//	}
//	
//	watch_actors = [];
//	watch_actors[0] = player_arms;
//	watch_actors[1] = watch;
//			
//	level.player DisableWeapons();
//	player_arms Show();
//	watch Show();
//	level.player PlayerLinkToDelta( player_arms, "tag_player", 0.5, 30, 12, 30, 30, false );
//	
//	root anim_single( watch_actors, anim_name );
//		
//	//level.player SetStance("crouch");
//	level.player Unlink();
//	player_arms Delete();
//	watch Delete();
//	
//	if(!clock_intro)
//	{
//		level.player EnableWeapons();
//		level.player EnableOffhandWeapons();
//	}
//	
//	
//	/*
//	if(clock_intro == true)
//	{
//		thread maps\clockwork_intro::intro_anims_player();
//	}
//	*/
//}

watch_tick( watch )
{
	level endon( "stop_watch_tick" );
	
	base_part_name = "J_Watch_Face_Time_2";
	for ( i = 2; i < 10; i++ )
	{
		part_name = base_part_name + i;
		watch HidePart( part_name );
	}
	
	flag_wait("intro_watch_on");

	for ( i = 2; i < 10; i++ )
	{
		part_name = base_part_name + i;
		watch ShowPart( part_name );
	}

	cur_part_num = 2;
	while ( 1 )
	{
		wait 1;
	
		part_name = base_part_name + cur_part_num;
		cur_part_num++;
		
		watch HidePart( part_name );
	}
}

watch_light_fx( player_arms, watch )
{ 
	//flag_wait on notetrack when light turns on 
	flag_wait("intro_watch_on");
//	CinematicInGameSync( cinematic_name );
	PlayFXOnTag(getfx("vfx/moments/clockwork/vfx_intro_watch_glow"), player_arms, "tag_gasmask2");	// start watch glow
	
	flag_wait("intro_watch_off");
	
	level notify( "stop_watch_tick" );
	
	base_part_name = "J_Watch_Face_Time_2";
	for ( i = 2; i < 10; i++ )
	{
		part_name = base_part_name + i;
		watch HidePart( part_name );
	}
	
	StopFXOnTag(getfx("vfx/moments/clockwork/vfx_intro_watch_glow"), player_arms, "tag_gasmask2");	// stop watch glow
//	StopCinematicInGame();
}

//jeep_watch_sync( player_arms, anim_root, anim_name, cinematic_name, anim_root_tag, clock_intro )
//{
////	SetSavedDvar( "cg_cinematicFullScreen", "0" );
//	
////	CinematicInGameSync( cinematic_name );
//	
//	watch = spawn_anim_model( "player_rig" );
//	watch SetModel( "clk_watch_viewhands" );
//
//	root = anim_root;
//	
//	if ( IsDefined( anim_root_tag ) )
//	{		
//		root = Spawn( "script_origin", anim_root.origin );
//		root.origin = anim_root GetTagOrigin( anim_root_tag );
//		root.angles = level.player GetPlayerAngles();
//		root LinkTo( anim_root, anim_root_tag );
//		
//		player_arms.origin = root.origin;
//		player_arms.angles = root.angles;
//		player_arms LinkTo( anim_root, anim_root_tag );
//		
//		watch.origin = root.origin;
//		watch.angles = root.angles;
//		watch LinkTo( anim_root, anim_root_tag );
//	}
//	
//	watch_actors = [];
//	watch_actors[0] = player_arms;
//	watch_actors[1] = watch;
//			
//	level.player DisableWeapons();
//	player_arms Show();
//	watch Show();
//	level.player PlayerLinkToAbsolute( player_arms, "tag_player" );
//	
//	root anim_single( watch_actors, anim_name );
//	
//	level.player Unlink();
//	player_arms Delete();
//	watch Delete();
//	
//	if(!clock_intro)
//	{
//		level.player EnableWeapons();
//		level.player EnableOffhandWeapons();
//	}
////	StopCinematicInGame();
//	
//	/*
//	if(clock_intro == true)
//	{
//		thread maps\clockwork_intro::intro_anims_player();
//	}
//	*/
//}

waittill_movement(distance_threshhold)
{
	self endon("death");
	
	distance_threshold2 = 0;

	if ( IsDefined(distance_threshhold) )
	{
		distance_threshhold2 = distance_threshhold * distance_threshhold;
	}
	
	original_pos = self.origin;
	dist2 = -1;
	
	while ( dist2 < distance_threshold2 )
	{
		waitframe();
		
		if ( self.origin != original_pos )
		{
			dist2 = DistanceSquared( self.origin, original_pos );
		}
	}
}

delete_on_path_end(endon_notify, complete_func)
{
	if ( IsDefined(endon_notify) )
	{
		level endon(endon_notify);
	}
	
	self waittill( "reached_path_end" );
	
	if ( IsDefined(complete_func) )
	{
		self thread [[ complete_func ]]();
	}
	
	if ( !raven_player_can_see_ai(self) )
	{
		self delete();
	}
}

killTimer()
{
	level notify( "kill_timer" );
	
	if ( IsDefined( level.timer ) )
	{
		level.timer Destroy();
	}
}

cool_walk(enable)
{
	self.ignoreall = enable;
	self.disablearrivals = enable;
	self.disableexits = enable;
	
	if (enable == true)
	{
		self.animname = "generic";
		self set_run_anim("walk_gun_unwary");
	}
	else
	{
		self clear_run_anim();
	}
}

fast_walk(enable)
{
	if (enable == true)
	{
		self.animname = "generic";
		self set_run_anim("clock_walk", 1 );
		//self set_run_anim("walk_gun_unwary");
		//self set_run_anim("active_patrolwalk_gundown");
		self.moveplaybackrate = 1;
	}
	else
	{
		self clear_run_anim();
		self.moveplaybackrate = 1;
	}
}

fast_jog(enable)
{
	if (enable == true)
	{
		self.animname = "generic";
		self set_run_anim("clock_jog");
		self.moveplaybackrate = 1; 
	}
	else
	{
		self clear_run_anim();
		self.moveplaybackrate = 1; // quickens walk
	}
}

walkout_idle( animation_name )
{
	while( !flag( "exfil_fire_fail" ) )
	{
		self waittill( "idle" );
		
		self clear_generic_idle_anim();
		self.animname = "generic";
		self set_generic_idle_anim( animation_name );
		
		wait .05;
	}
}

die_quietly()
{
	if ( IsDefined(self.magic_bullet_shield) && self.magic_bullet_shield == true )
	{
		self stop_magic_bullet_shield();
	}
	self.no_pain_sound = true;
    self.diequietly = true;
    self die();
}

fight_back(waittime)
{
	if ( !IsDefined(waittime))
	{
		waittime = 3;
	}
	
	self endon("death");
	wait waittime;
	self.ignoreall = false;
}

attack_targets(attackers, targets, delay_between_targets_min, delay_between_targets_max , snipe, notrace_sniping)
{
	if ( !IsDefined(notrace_sniping) )
{
		notrace_sniping = false;
	}
	if ( !IsDefined(delay_between_targets_min) )
	{
		delay_between_targets_min = 0;
	}
	
	
	if ( !IsDefined(delay_between_targets_max) )
	{
		delay_between_targets_max = 0;
	}
	
	if ( !IsDefined(snipe) )
	{
		snipe = false;
	}
	
	cur_targ = 0;
	cur_attacker = 0;
	while (cur_targ < targets.size)
	{
		if ( IsDefined(targets[cur_targ]) && IsAlive(targets[cur_targ]) && !IsDefined(targets[cur_targ].fake_dead) )
		{
			if ( snipe == true)
			{
				targets[cur_targ].ignoreme = false;
				thread snipe_till_dead(attackers[cur_attacker], targets[cur_targ], notrace_sniping);
			}
			else
			{
				targets[cur_targ].ignoreme = false;
				attackers[cur_attacker] GetEnemyInfo(targets[cur_targ]);
				targets[cur_targ] thread fight_back();
			}
		
			if ( delay_between_targets_max > 0)
			{
				waittime = delay_between_targets_max;
				
				if  (delay_between_targets_min < delay_between_targets_max)
				{
					waittime = RandomFloatRange(delay_between_targets_min, delay_between_targets_max);
				}
				
				wait(waittime);
			}
			
			cur_attacker++;
				
			if (cur_attacker >= attackers.size)
			{
				cur_attacker = 0;
			}
		}
		
		cur_targ++;
	}
}

snipe_till_dead(attacker, targ, notrace)
{
	aimtime = .3;
	
	attacker cqb_aim(targ);
		
	wait aimtime;
	
	while ( IsAlive(targ) && !IsDefined(targ.fake_dead) )
	{
		start = attacker GetTagOrigin( "tag_flash" );
		end = targ GetTagOrigin( "j_head" );
		
		traceok = true;
		
		if ( !notrace )
		{
		traceok = SightTracePassed(start, end, true, attacker, targ);
		}
		if ( traceok )
		{
			attacker cqb_aim(targ);
			MagicBullet( attacker.weapon, start, end );
			
			if (RandomInt(100) > 50)
			{
				// 50% chance of a double shot for coolness
				wait 0.1;
				MagicBullet( attacker.weapon, start, end );
			}
		}
		wait 0.25;

		attacker cqb_aim( undefined );
	}
}
// Ryan's code to handle spawning / animating guys.
ambient_animate(delete_on_complete, shoot_me_notify, spawn_drone, civilian)
{
	
	struct = undefined;
	target_node = undefined;

	if ( !IsDefined(civilian) )
	{
		civilian = true;
	}
	
	if (IsDefined(spawn_drone) && spawn_drone == true)
	{
		guy = dronespawn_bodyonly(self);
	}
	else
	{
		spawn_drone = false;
		guy = self spawn_ai();
	}
	
	if ( IsDefined(guy) )
	{
		guy endon("death");

		if (spawn_drone == false)
		{
			if ( IsDefined(shoot_me_notify) )
			{
				guy thread prepare_to_be_shot(shoot_me_notify, civilian);
			}
			
			guy set_allowdeath(true);
		}
		
		if ( IsDefined(self.animation) )
		{
			guy.animname = "generic";
			
			if (spawn_drone == false && civilian == true)
			{
				guy set_generic_idle_anim("scientist_idle");
			}

			if ( IsDefined(self.target) )
			{
				struct = GetStruct(self.target, "targetname");
				if ( !IsDefined(Struct) )
				{
					target_node = GetNode(self.target, "targetname");
				}
				if (IsDefined(struct))
				{
					struct thread anim_generic_loop(guy, self.animation);
				}
				if (IsDefined(target_node))
				{
					guy disable_arrivals();
					guy disable_turnAnims();
					guy disable_exits();
					guy set_run_anim(self.animation);
					
					if ( IsDefined(delete_on_complete) && delete_on_complete == true)
					{
						guy thread delete_on_complete(true);
					}
				}
			}
			else
			{
				if ( IsArray(level.scr_anim["generic"][self.animation]) )
				{
					guy thread anim_generic_loop(guy, self.animation);
				}
				else
				{
					guy disable_turnAnims();
					guy.ignoreall = true;
					if (spawn_drone == false)
					{
						guy.allowdeath = true;
					}

					guy thread anim_single_solo(guy, self.animation);
					if ( IsDefined(delete_on_complete) && delete_on_complete == true )
					{
						guy thread delete_on_complete(false);
					}
				}
			}
		}
	}
	return guy;
}
		
delete_on_complete(on_goal)
{
	if ( !on_goal )
		{
       	self waittillmatch("single anim", "end");
       	self notify( "killanimscript" );
		}
	else
	{
		self waittill("reached_path_end");
	}

	if ( !raven_player_can_see_ai(self) )
	{
		self delete();
	}
}


prepare_to_be_shot(shoot_me_notify, civilian)
{
	self endon("death");
	
	level waittill(shoot_me_notify);
		
	self.ignoreme = false;
	self.ignoreall = false;
	self anim_stopanimscripted();
	
	if (civilian == true)
	{
		self set_generic_idle_anim("scientist_idle");
	}
	
	self enable_arrivals();
	self enable_exits();
	self enable_turnAnims();
}

waittill_no_radio_dialog()
{
	while ( radio_dialog_playing() )
		waitframe();
}

radio_dialog_playing()
{
	return IsDefined( level.player_radio_emitter ) && IsDefined( level.player_radio_emitter.function_stack ) && level.player_radio_emitter.function_stack.size > 0;
}

waittill_no_char_dialog()
{
	while ( allies_dialog_playing() )
		waitframe();
}

allies_dialog_playing()
{
	ally_0_playing = IsDefined( level.allies[0].function_stack ) && level.allies[0].function_stack.size > 0;
	ally_1_playing = IsDefined( level.allies[1].function_stack ) && level.allies[1].function_stack.size > 0;
	ally_2_playing = IsDefined( level.allies[2].function_stack ) && level.allies[2].function_stack.size > 0;
	
	return ally_0_playing || ally_1_playing || ally_2_playing;
}

radio_dialog_add_and_go( alias, timeout )
{
	waittill_no_char_dialog();
	radio_add( alias );
	radio_dialogue( alias,timeout );
}

char_dialog_add_and_go( alias )
{
	waittill_no_radio_dialog();
	level.scr_sound[ self.animname ][ alias ] = alias;
	self dialogue_queue( alias );
}

//refresh_minimap()
//{
//	if ( GetDvar( "minimap_sp" ) || SetDvar( "minimap_full_sp" ) )
//	{
//		SetNorthYaw( 255 );
//    	maps\_compass::setupMiniMap( "compass_map_clockwork_defend", "clockwork_defend_minimap_corner" );
//	}
//}
//	
//minimap_on()
//{
//	SetNorthYaw( 255 );
//    maps\_compass::setupMiniMap( "compass_map_clockwork_defend", "clockwork_defend_minimap_corner" );
//    SetDvar( "minimap_sp", 0 );
//    SetDvar( "minimap_full_sp", 1 );
//    SetSavedDvar( "bg_compassShowEnemies", 1 );
//    thread reset_minimap_handler();
//}
//
//minimap_off()
//{
//    SetDvar( "minimap_sp", 0 );
//    SetDvar( "minimap_full_sp", 0 );
//    SetSavedDvar( "bg_compassShowEnemies", 0 );
//    level notify( "minimap_turned_off" );
//	level.minimap_active = 0;
//    
////    SetDvar( "compassRotation", 1 );
//}
//
//reset_minimap_handler()
//{
//	level endon( "minimap_turned_off" );
//	level.minimap_active = 1;
//	level.reset_minimap = 0;
//	
//	minimap_player_death();
//	minimap_off();
//	
//	
//}
//
//minimap_player_death()
//{
//	level.player endon( "death" );
//	while( 1 )
//	{
//		result = GetDvar( "minimap_full_sp", "0");
//		//result = GetDvar( "minimap_sp", "0");
//		if( result != "1" ) 
//		{
//			minimap_on();
//		}
//		
//		wait 0.05;
//	}
//	
//}
//
//get_player_speed()
//{
//	vel = level.player GetVelocity();
//	// figure out the length of the vector to get the speed (distance from world center = length)
//	speed = Distance( ( vel[ 0 ], vel[ 1 ], 0 ), ( 0, 0, 0 ) );  // don't care about Z velocity
//	
//	return speed;
//}


RUMBLE_FRAMES_PER_SEC = 10;
screenshakeFade( scale, duration, fade_in, fade_out)
{
	if ( !isdefined( fade_in ) )
		fade_in = 0;
	if ( !isdefined( fade_out ) )
		fade_out = 0;

	assert( ( fade_in + fade_out ) <= duration );

	frame_count = duration * RUMBLE_FRAMES_PER_SEC;
	fade_in_frame_count = fade_in * RUMBLE_FRAMES_PER_SEC;
	if ( fade_in_frame_count > 0 )
		fade_in_scale_step = scale / fade_in_frame_count;
	else
		fade_in_scale_step = scale;

	fade_out_frame_count = fade_out * RUMBLE_FRAMES_PER_SEC;
	fade_out_start_frame = frame_count - fade_out_frame_count;
	if ( fade_out_frame_count > 0 )
		fade_out_scale_step = scale / fade_out_frame_count;
	else
		fade_out_scale_step = scale;

	delay = 1/RUMBLE_FRAMES_PER_SEC;
	scale = 0;
	for ( i = 0; i < frame_count; i++ )
	{
		if ( i <= fade_in_frame_count )
			scale += fade_in_scale_step;

		if ( i > fade_out_start_frame )
			scale -= fade_out_scale_step;

		earthquake( scale, delay, level.player.origin, 500 );
		wait delay;
	}
}

introscreen_generic_black_fade_in_on_flag( flg, fade_time, fade_in_time )
{
	introscreen_generic_fade_in_on_flag( "black", flg, fade_time, fade_in_time );
}

introscreen_generic_fade_in_on_flag( shader, flagwait, fade_out_time, fade_in_time )
{
	if ( !IsDefined( fade_out_time ) )
		fade_out_time	= 1.5;
		
	if ( !IsDefined( fade_in_time ) )
		start_overlay();	
	else
		fade_out( fade_in_time );
	
	flag_wait(flagwait);
	//wait pause_time;
	fade_in( fade_out_time );
	wait fade_out_time;
	SetSavedDvar( "com_cinematicEndInWhite", 0 );
}

//destroy all glass with given targetname.
glass_destroy_targetname( glassname )
{
	glasstodestroy = GetGlassArray( glassname );
	
	foreach ( glass in glasstodestroy )
	{
		DestroyGlass( glass );
	}
}


//nvg_teleport(lights_off, additional_ents)
//{
//	offset = (0, 9216, 0);
//	
//	if ( !lights_off )
//	{
//		offset *= -1;
//	}
//
//	
//	level.player SetOrigin( level.player.origin + offset );
//
//	if ( IsDefined(additional_ents) )
//	{
//		if ( !IsArray(additional_ents) )
//		{
//			additional_ents = make_array(additional_ents);
//		}
//		
//		foreach (ent in additional_ents)
//		{
//			ent.origin = ent.origin + offset;
//		}
//	}
//	
//	allguys = GetAiArray();
//	foreach (guy in allguys)
//	{
//		
//		if ( IsDefined(guy.looping_anim) )
//		{
//			guy thread teleport_looping_guy(offset);
//		}
//		else if ( IsDefined(guy.animated_scene) )
//		{
//			guy thread teleport_animated_guy(offset);
//		}
//		else
//		{
//			guy ForceTeleport(guy.origin + offset, guy.angles);
//			guy SetGoalPos( guy.origin );
//		}
//	}
//}
//
//teleport_looping_guy(offset)
//{
//	self anim_stopanimscripted();
//	self ForceTeleport(self.origin + offset, self.angles);
//	self SetGoalPos( self.origin );
//	self thread anim_generic_loop( self, self.looping_anim );
//}
//
//teleport_animated_guy(offset)
//{
//	if ( IsDefined( level.scr_anim[self.animname][self.animated_scene] ) )
//	{
//		anim_time = self GetAnimTime( level.scr_anim[self.animname][self.animated_scene] );
//		if ( IsDefined(anim_time) )
//		{
//			cur_animname = self.animname;
//			self anim_stopanimscripted();
//			
//			self ForceTeleport(self.origin + offset, self.angles);
//			self SetGoalPos( self.origin );
//			
//			scene_org = self.animated_scene_org;
//			scene_org thread anim_single_solo(self, self.animated_scene);
//			wait 0.05;
//			self SetAnimTime(level.scr_anim[cur_animname][self.animated_scene], anim_time);
//		}
//	}
//}

nvg_goggles_off()
{
	if ( maps\_nightvision::nightVision_check(level.player) )
	{
		level.player PlaySound("item_nightvision_off");
		current_weapon = level.player GetCurrentWeapon();
	    level.player ForceViewmodelAnimation( current_weapon , "nvg_up" );
		level.player NightVisionGogglesForceOff();
		level.player notify("night_vision_off");
	}
}

nvg_goggles_on()
{
	if ( !maps\_nightvision::nightVision_check(level.player) )
	{
		level.player PlaySound("item_nightvision_on");
		current_weapon = level.player GetCurrentWeapon();
	    level.player ForceViewmodelAnimation( current_weapon , "nvg_down" );
		level.player NightVisionGogglesForceOn();
		level.player notify("night_vision_on");
	}
}

overheard_radio_chatter(alias, delay, skip_flag)
{
	// turning this off
	if (true)
		return;
	
	flag_wait_or_timeout(skip_flag, delay);
	
	if ( flag(skip_flag) )
		return;
	
	//this is so we have a universal entity to stack radio dialogue on without worrying about
	//any other scripts dirtying up the stack with functions not related to radio_dialogue
	if ( !isdefined( level.background_radio_emitter ) )
	{
		ent = Spawn( "script_origin", ( 0, 0, 0 ) );
		ent LinkTo( level.player, "", ( 0, 0, 0 ), ( 0, 0, 0 ) );
		level.background_radio_emitter = ent;
	}

	bcs_scripted_dialogue_start();

	success = level.background_radio_emitter function_stack( ::play_sound_on_tag, alias, undefined, true );

	return success;
}

glowstick_hacking_on(actor)
{
	PlayFXOnTag( level._effect[ "glowstick" ], actor, "J_prop_1" );
	flag_wait("thermite_start");
	glowstick_off(actor);
}

glowstick1_on(actor)
{
	PlayFXOnTag( level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick1" ], actor, "J_prop_1" );
	flag_wait("thermite_start");
	//glowstick_off(actor);
	StopFXOnTag(level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick1" ], actor, "J_prop_1" );
	PlayFXOnTag( level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick1_fade" ], actor, "J_prop_1" );
}

glowstick2_on(actor)
{
	PlayFXOnTag( level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick2" ], actor, "J_prop_1" );
	flag_wait("thermite_start");
	//glowstick_off(actor);
	StopFXOnTag(level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick2" ], actor, "J_prop_1" );
	PlayFXOnTag( level._effect[ "vfx/moments/clockwork/vfx_vault_glowstick2_fade" ], actor, "J_prop_1" );
}

glowstick_off(actor)
{
	StopFXOnTag(level._effect[ "glowstick" ], actor, "J_prop_1" );
}

unhide_prop(actor)
{
	showed = false;
	switch (actor.animname)
	{
		case "vault_spool_prop":
			level.spool Show();
			showed = true;
			break;
		case "vault_glowstick1_prop":
			level.glowstick1 Show();
			showed = true;
			break;
		case "vault_glowstick2_prop":
			level.glowstick2 Show();
			showed = true;
			break;
		case "vault_tablet_prop":
			level.tablet Show();
			showed = true;
			break;
		case "vault_drill_prop":
			array_thread(level.drill_pickup, ::show_entity);
			showed = true;
			wait 2;
			flag_set("drill_pickup_ready");
	}
	if (!showed)
	{
		actor Show();
	}
}

// temporary until main function works
raven_player_can_see_ai( ai, latency )
{
	currentTime = getTime();

	if ( !isdefined( latency ) )
		latency = 0;

	if ( isdefined( ai.playerSeesMeTime ) && ai.playerSeesMeTime + latency >= currentTime )
	{
		assert( isdefined( ai.playerSeesMe ) );
		return ai.playerSeesMe;
	}

	ai.playerSeesMeTime = currentTime;

	if ( !within_fov( level.player.origin, level.player.angles, ai.origin, 0.766 ) )
	{
		ai.playerSeesMe = false;
		return false;
	}

	playerEye = level.player GetEye();

	feetOrigin = ai.origin;
	if ( SightTracePassed( playerEye, feetOrigin, false, level.player ) )
	{
		ai.playerSeesMe = true;
		return true;
	}

	eyeOrigin = ai GetEye();
	if ( SightTracePassed( playerEye, eyeOrigin, false, level.player ) )
	{
		ai.playerSeesMe = true;
		return true;
	}

	midOrigin = ( eyeOrigin + feetOrigin ) * 0.5;
	if ( SightTracePassed( playerEye, midOrigin, false, level.player ) )
	{
		ai.playerSeesMe = true;
		return true;
	}

	ai.playerSeesMe = false;
	return false;
}


toggle_visibility(targetname, visible)
{
	vault_damage = GetEntArray(targetname, "targetname");
	foreach (bit in vault_damage)
	{
		if (visible)
		{
			bit Show();
		}
		else
		{
			bit Hide();
		}
	}
}

waittill_player_close_to_or_aiming_at( enemy, close_radius, aim_radius )
{
	Assert( IsDefined( enemy ) && IsAI( enemy ) );
	
	radius_sq = close_radius * close_radius;
	
	while ( IsDefined( enemy ) && IsAlive( enemy ) )
	{
		dist_sq = Distance2DSquared( level.player.origin, enemy.origin );
		if ( dist_sq < radius_sq )
			break;
		
		start = level.player GetEye();
		end = enemy GetEye();
		trace = BulletTrace( start, end, true, level.player, false, false );
		if ( IsDefined( trace["entity"] ) && trace["entity"] == enemy )
			break;
			
		if ( level.player WorldPointInReticle_Circle( end, 65, aim_radius ) )
			break;
		
		waitframe();
	}
}

// temp_dialogue() - mock subtitle for a VO line not yet recorded and processed
//   <speaker>: Who is saying it?
//   <text>: What is being said?
//   <duration>: [optional] How long is to be shown? (default 4 seconds)

//temp_dialogue( speaker, text, duration )
//{
//	level notify( "temp_dialogue", speaker, text, duration );
//	level endon( "temp_dialogue" );
//	
//	if ( !IsDefined( duration ) )
//	{
//		duration = 4;
//	}
//	
//	if ( IsDefined( level.tmp_subtitle ) )
//	{
//		level.tmp_subtitle Destroy();
//		level.tmp_subtitle = undefined;
//	}
//	
//	level.tmp_subtitle	 = NewHudElem();
//	level.tmp_subtitle.x = -60;
//	level.tmp_subtitle.y = -62;
//	level.tmp_subtitle SetText( "^2" + speaker + ": ^7" + text );
//	level.tmp_subtitle.fontScale   = 1.46;
//	level.tmp_subtitle.alignX	   = "center";
//	level.tmp_subtitle.alignY	   = "middle";
//	level.tmp_subtitle.horzAlign   = "center";
//	level.tmp_subtitle.vertAlign   = "bottom";
//	//level.tmp_subtitle.vertAlign = "middle";
//	level.tmp_subtitle.sort		   = 1;
//
//	wait duration;
//
//	thread temp_dialogue_fade();
//}
//
//temp_dialogue_fade()
//{
//	level endon( "temp_dialogue" );
//	for ( alpha = 1.0; alpha > 0.0; alpha -= 0.1 )
//	{
//		level.tmp_subtitle.alpha = alpha;
//		wait 0.05;
//	}
//	level.tmp_subtitle Destroy();
//}
