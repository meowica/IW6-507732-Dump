#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


section_precache()
{
	PreCacheRumble( "light_1s" );
	PreCacheRumble( "heavy_1s" );
	/// PreCacheModel( "viewmodel_bowie_knife" );
}

section_flag_init()
{
	// PreSAT
	flag_init( "presat_bravo_in_position" );
	flag_init( "presat_charlie_in_position" );
	flag_init( "presat_open_revolving_door" );
	flag_init( "presat_door_anim_done" );
	flag_init( "presat_revolving_door_opened" );
	flag_init( "presat_revolving_door_closed" );
	flag_init( "presat_started" );
	flag_init( "presat_go_loud" );
	flag_init( "alert_platform_guards" );
	flag_init( "presat_done" );
	flag_init( "player_finsh_presat" );
	flag_init( "presat_locked" );
	flag_init( "presat_synctransients" );
	flag_init( "open_sat_entrance" );

	// SAT
	flag_init( "start_moving_satellite_pieces" );
	flag_init( "sat_room_allies_move_in" );
	flag_init( "sat_room_approach_drawbridge" ); // ?
	flag_init( "sat_room_bridge_down" );
	flag_init( "sat_room_alpha_found_it" );
	flag_init( "sat_room_alpha_enter_done" );
	flag_init( "sat_room_player_knifed" );
	flag_init( "sat_room_player_pulled" );
	flag_init( "sat_room_alpha_get_down" );
	flag_init( "sat_room_saw_board_front" );
	flag_init( "sat_room_player_flipped" );
	flag_init( "sat_room_continue" );
	flag_init( "sat_room_exiting" );
	flag_init( "sat_room_clear" );
	flag_init( "lgt_weapon_room_jump" ); // Turns on vision set when jumping to SAT room
	flag_init( "lgt_weapon_sequencing" );
	flag_init( "railgun_reveal_setup" ); // Old flag but still used
	flag_init( "sat_raise_rod_01" );
	flag_init( "sat_raise_rod_02" );
	flag_init( "sat_raise_cpu_cover" );

	// Camera
	flag_init( "start_camera_moment" );
	flag_init( "give_use_hint_if_needed" );
	flag_init( "player_using_camera" );
	flag_init( "sat_begin_looking_for_A" );
	flag_init( "sat_begin_looking_for_B" );
	flag_init( "sat_begin_looking_for_C" );
	flag_init( "cam_A_confirmed" );
	flag_init( "cam_B_confirmed" );
	flag_init( "cam_C_confirmed" );
	flag_init( "sat_allow_scan" );
	flag_init( "cam_A_scanned" );
	flag_init( "cam_B_scanned" );
	flag_init( "sat_drawbridge_up" );
}



// =====================================
// PreSAT Room
// =====================================
presat_room_start()
{
	level.player maps\factory_util::move_player_to_start_point( "playerstart_presat_room" );

	// Move squad here
	maps\factory_util::actor_teleport( level.squad[ "ALLY_ALPHA" ]	, "ws_start_alpha" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_BRAVO" ]	, "ws_start_bravo" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_CHARLIE" ], "ws_start_charlie" );

	// Allies post up on door
	maps\factory_util::safe_trigger_by_targetname( "sca_ps_final_kills_done" );
	
	maps\factory_powerstealth::squad_stealth_on();
	
	// Setup the revolving door
	flag_set( "entered_factory_1" );
	thread presat_init_revolving_door();

	// Player sneaking speed
	player_speed_percent( 65 );

	//thread set_audio_zone("factory_wh1_int");
	
	level thread maps\factory_powerstealth::factory_stealth_settings();
	maps\_stealth_utility::stealth_set_default_stealth_function( "factory_stealth", maps\factory_powerstealth::factory_stealth_settings );
	
	flag_set( "powerstealth_end" );
	flag_set( "ps_alpha_done" );
	flag_set( "presat_bravo_in_position" );
	flag_set( "presat_charlie_in_position" );
	
	battlechatter_off();
	
	thread maps\_weather::rainNone ( 8 );
	
	// Deletes script models
	thread maps\factory_powerstealth::train_cleanup();
}

// Main
presat_room()
{
	
	// Wait for player to get to the entrance door
	flag_wait( "presat_entrance" );
	autosave_by_name( "presat_room" );

	// Wait for all 3 allies to get in position
	flag_wait_all( "ps_alpha_done", "presat_bravo_in_position", "presat_charlie_in_position" );

	// Ally setup
	foreach( ally in level.squad )
	{
		//ally.moveplaybackrate = 0.8;
		ally disable_surprise();
		ally.disableplayeradsloscheck = true;
	}

	// CHAD TESTS FOR PC GOD RAYS
	thread maps\factory_util::god_rays_round_door_open();

	// Kick off the presat door anim
	thread maps\factory_anim::presat_door_open();

	// PreSAT Logic threads
	thread presat_dialogue();
	thread presat_ally_movement();
	thread presat_enemies();
	thread presat_airlock_doors();
	thread presat_moving_platform();
	thread presat_moving_platform_02();
	thread presat_transient_load();
	wait 0.1;
	thread presat_agvs();
	thread presat_glass_decals( "presat_decal_left_office_L" );
	thread presat_glass_decals( "presat_decal_left_office_R" );
	thread presat_glass_decals( "presat_decal_right_office_L" );
	thread presat_glass_decals( "presat_decal_right_office_R" );
	thread presat_fans( "presat_fan_1", 16 );
	thread presat_fans( "presat_fan_2", 22 );

	flag_wait( "presat_allies_go_loud" );

	// Return player to full move speed
	player_speed_percent( 100, 5 );
	
	// Increase player threat
	orig_bias = level.player.threatbias;
	level.player.threatbias = 1400;

	// Give player genades back
	level.player GiveWeapon( "flash_grenade" );
	level.player GiveWeapon( "fraggrenade" );

	flag_set( "_stealth_spotted" );
	maps\_stealth_utility::disable_stealth_system();

	// Wait for all PreSAT enemies to be dead
	waittill_aigroupcleared( "presat_enemies" );
	
	// Reset threat bias
	level.player.threatbias = orig_bias;
	
	flag_set( "presat_done" );
	autosave_by_name( "sat_room" );

	// End of section
	flag_wait( "railgun_reveal_setup" );

	// Cleanup
	thread presat_cleanup();
}

presat_transient_load()
{
	flag_wait( "presat_revolving_door_closed" );

	// CF - LOADING UP NEXT TRANSIENT FASTFILE WHICH INCLUDES SATELLITE ROOM AND AMBUSH ITEMS
	transient_unloadall_and_load( "factory_mid_tr" );

	// making sure all transient FF items are loaded before getting to sat room
	flag_wait( "presat_synctransients");
	maps\factory_util::sync_transients();
}

// Section dialogue
presat_dialogue()
{
	// Merrick: Oldboy, we've reached the south vault door. It's a big one. Whatever's in there they want to keep it safe.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_oldboywevereachedthe" );

	// Oldboy: No cameras in Black Zone. You're on your own inside. Starting override procedure...
	smart_radio_dialogue( "factory_oby_nocamerasinblack" );

	// Turn off the rain - No windows in presat or sat room.
	thread maps\_weather::rainNone( 8 );

	// Merrick: Adam take point, Hesh clear right, Keegan left.
	//level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_adamtakepointhesh" );
	wait 3.5;
	
	// Merrick: Heading in...
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_headingin" );

	// Went loud
	flag_wait( "presat_allies_go_loud" );

	// Merrick: Multiple tangos! Go hot!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_multipletangosgohot" );

	wait 0.2;

	// Merrick: Keep moving!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_keepmoving" );

	wait 1.6;

	// Merrick: More contacts! Structure at 10 o'clock!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_morecontactsstructureat" );

	// Encounter over
	waittill_aigroupcleared( "presat_enemies" );
	waittill_aigroupcleared( "presat_enemies_backup" );
	wait 0.45;

	// Hesh: Clear
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_hsh_clear" );
	
	// Oldboy: Lots of chatter on enemy comms, sounds like they know somethings up.
	smart_radio_dialogue( "factory_oby_nochatteronenemy" );
	
	// Merrick: Copy, Oldboy.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_copyoldboy" );
	
	// Merrick: House Main, we are inside Black Zone. They're making something big here. No ID on LOKI yet.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_housemainweare" );
	
	// Overlord: Roger Jericho1-1, continue searching for LOKI.
	smart_radio_dialogue( "factory_hqr_rogerjericho11continue" );

	// Arrived at SAT entrance door
	flag_wait( "sat_open_moment" );

	// Merrick: Pressure locked door. This must be it. Oldboy?
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_pressurelockeddoorthis" );

	// Oldboy: Roger.
	smart_radio_dialogue( "factory_oby_roger" );

	flag_set( "open_sat_entrance" );

	wait 0.35;

	//flag_set("lgt_weapon_room_jump");
	
	// Merrick: Bingo.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_bingo" );
}


// =========================
// Ally movement
// =========================
presat_ally_movement()
{
	// Wait for door to fully open
	//flag_wait( "presat_revolving_door_opened" );
	flag_wait( "presat_door_anim_done" );
	
	// Push into the room
	maps\factory_util::safe_trigger_by_targetname( "presat_allies_enter" );

	// The allies should not flinch or react to fire when moving through the tunnel
	foreach( ally in level.squad )
	{
		ally.ignoresuppression = true;
		ally.disableplayeradsloscheck = true;
		ally.suppressionwait_old = ally.suppressionwait;
		ally.suppressionwait = 0;
		ally disable_surprise();
		ally.IgnoreRandomBulletDamage = true;
		ally disable_bulletwhizbyreaction();
		ally disable_danger_react();
		ally.disableFriendlyFireReaction = true;
		level.ai_friendlyFireBlockDuration = getdvarfloat( "ai_friendlyFireBlockDuration" );
		setsaveddvar( "ai_friendlyFireBlockDuration", 0 );
	}
	thread presat_disable_ally_noreact();

	flag_wait( "presat_allies_go_loud" );

	// Allies go loud and stop being as stealthy
	foreach( ally in level.squad )
	{
		// No push in compbat
		ally PushPlayer( false );

		// Reset speed
		ally.moveplaybackrate = 1.0;

		// Keep the pathing tight
		ally.goalradius = 4;
		ally.fixednodesaferadius = 512;

		ally enable_ai_color_dontmove();
		ally enable_cqbwalk();

		ally.ignoreall = false;

		// Slight delay before enemies attack, so it looks like allies got the jump on them
		ally delayThread( 1.5, ::set_ignoreme, false );
		
		ally delayThread( 2.0, ::enable_surprise );
	}

	// Turn on battlechatter
	battlechatter_on();

	// One ally goes the long way around
	level.squad[ "ALLY_BRAVO" ] thread presat_ally_walk_around();

	// Allies will hold in office if all enemies dead
	thread presat_allies_wait_in_office();
	
	// Wait for player to reach the back office
	flag_wait( "presat_office" );

	waittill_aigroupcleared( "presat_enemies" );
	waittill_aigroupcleared( "presat_enemies_backup" );

	flag_wait( "presat_office" );

	// Move allies to SAT entrance door
	maps\factory_util::safe_trigger_by_targetname( "presat_allies_wait_at_sat_door" );

	level waittill( "open_sat_entrance" );
	wait 0.45;

	// Move to SAT room initial positions
	maps\factory_util::safe_trigger_by_targetname( "sat_allies_initial_position" );

	// Reset ally params
	foreach( ally in level.squad )
	{
		ally PushPlayer( true );
		ally.moveplaybackrate = 1.0;
		ally.goalradius = 0;
		ally enable_cqbwalk();
		ally.ignoreall = false;
		ally.ignoreme = false;

		ally.ignoresuppression = false;
		ally.disableplayeradsloscheck = false;
		ally.suppressionwait = ally.suppressionwait_old;
		ally enable_surprise();
		ally.IgnoreRandomBulletDamage = false;
		ally enable_bulletwhizbyreaction();
		ally.disableFriendlyFireReaction = false;
		setsaveddvar( "ai_friendlyFireBlockDuration", level.ai_friendlyFireBlockDuration ); 
	}
}

// When the player enters the room, disable ally no react
presat_disable_ally_noreact()
{
	flag_wait( "presat_close_revolving_door" );
	foreach( ally in level.squad )
	{
		ally enable_surprise();
		ally.disableplayeradsloscheck = false;
		ally.IgnoreRandomBulletDamage = false;
		ally enable_bulletwhizbyreaction();
		ally.disableFriendlyFireReaction = false;
	}
}

// One ally walks around the back of the moving platform
presat_ally_walk_around()
{
	level endon( "presat_stop_walk_around" );

	self.goalradius = 0;
	
	// Node 1
	node = GetNode( "presat_walk_around_node", "targetname" );
	self SetGoalPos( node.origin );
	self waittill( "goal" );

	// Node 2
	node = GetNode( node.target, "targetname" );
	self SetGoalPos( node.origin );
	self waittill( "goal" );

	// Node 3
	node = GetNode( node.target, "targetname" );
	self SetGoalPos( node.origin );
	self waittill( "goal" );

	// Node 4
	maps\factory_util::safe_trigger_by_targetname( "presat_walk_around_node_01" );
	self waittill( "goal" );
	wait 1.5;

	// Node 5
	maps\factory_util::safe_trigger_by_targetname( "presat_walk_around_node_02" );
	self waittill( "goal" );
	wait 1.5;

	// Node 6
	maps\factory_util::safe_trigger_by_targetname( "presat_walk_around_node_03" );
}

// Allies move into the office and wait if all enemies are dead and player is slow
presat_allies_wait_in_office()
{
	alive = 10;
	while( alive > 2 )
	{
		wait 0.1;
		alive = ( get_ai_group_count( "presat_enemies" ) + get_ai_group_count( "presat_enemies_backup" ) );
	}

	// If all the enemies are dead, move allies up into the office
	//flag_set( "presat_office" );
	level notify( "presat_stop_walk_around" );
	maps\factory_util::safe_trigger_by_targetname( "presat_allies_clear_office" );

	// Remove color trigger in case player backtracks
	maps\factory_util::safe_delete_targetname( "presat_allies_enter" );
	maps\factory_util::safe_delete_targetname( "presat_allies_move_in" );
	maps\factory_util::safe_delete_targetname( "presat_allies_on_office" );
}

// =========================
// Enemy logic
// =========================
presat_enemies()
{
	flag_wait( "presat_open_revolving_door" );
	
	// Group 2 - Back office area
	presat_spawners_02 = GetEntArray( "presat_initial_enemies_02", "targetname" );
	foreach ( spawner in presat_spawners_02 )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			//iprintln( "PreSAT enemies 02: Spawn failed" );
			spawner delete();
			continue;
		}
		guy thread presat_office_guards_react();
		guy.health = 1;
	}
	
	// Wait for door to fully open
	flag_wait_any( "presat_revolving_door_opened", "presat_started" );

	// Group 1 - Walk with the moving platform
	presat_spawners_01 = GetEntArray( "presat_initial_enemies_01", "targetname" );
	foreach ( spawner in presat_spawners_01 )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			//iprintln( "PreSAT enemies 01: Spawn failed" );
			spawner delete();
			continue;
		}

		guy.animname = "generic";
		guy.disablearrivals = true;
		guy.disableexits = true;
		guy.ignoreall = true;
		guy.dontevershoot = true;
		guy.a.disableLongDeath = true;
		guy.health = 1;
		guy.moveplaybackrate = 1.1;
		
		// If allies get shot in the tight corridor they cause blockage and look bad.
		// So make sure the enemies miss
		//guy.script_accuracy = 0.1;

		guy set_generic_run_anim_array( "walk_gun_unwary" );

		if( IsDefined( guy.target ) )
		{
			guy thread maps\_patrol::patrol( guy.target );
		}

		guy thread presat_react_stop_patrol( "surprise_stop_v1" );
	}
	
	// Spawn backup after a few kills
	waittill_aigroupcount( "presat_enemies", 5 );

	// Group 3 - Small wave of backup
	presat_spawners_03 = GetEntArray( "presat_backup_enemies", "targetname" );
	foreach( spawner in presat_spawners_03 )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			spawner delete();
			continue;
		}
		guy.health = 1;
		guy.a.disableLongDeath = true;
	}
}

// Guards stop patrolling and go aggro
presat_react_stop_patrol( reaction_anim )
{
	self endon( "death" );
	flag_wait( "alert_platform_guards" );

	wait RandomFloatRange( 0.0, 0.35 );

	// Stop patrol
	self.ignoreall = false;
	self StopAnimScripted();
	self clear_generic_run_anim();

	// Play surprise anim
	if( isDefined( reaction_anim ))
	{
		self.animname = "enemy";
		self anim_single_solo( self, reaction_anim );
	}

	wait 1.0;

	// Return to normal behavior
	self.dontevershoot = undefined;
}

// Handle guards in back area of PreSAT
presat_office_guards_react()
{
	self.ignoreall = true;
	flag_wait( "presat_allies_go_loud" );
	wait RandomFloatRange( 0.5, 2.5 );
	self.ignoreall = false;
}



// =========================
// Moving platform
// =========================
presat_moving_platform()
{
	level endon( "presat_locked" );
	
	// Setup the loader platform
	loader_platform = create_loader_platform( "loading_platform_node", "loading_platform" );
	loader_platform thread platform_enemies();

	flag_wait ( "presat_open_revolving_door" );

	loader_platform thread platform_warning_lights( "platform_warning_light_01" );
	loader_platform thread path_disconnector();
	
	// Teleport it into place
	start = GetEnt( "moving_platform_start_position", "targetname" );
	loader_platform moveTo( start.origin, 0.1 );
	loader_platform waittill( "movedone" );
	
	loader_platform thread maps\factory_audio::moving_platform_warning_beeps_sfx(start.origin);
	loader_platform thread maps\factory_audio::moving_platform_movement_loop_sfx(start.origin, 42.8);
	
	loader_platform notify( "spawn_enemies" );

	// Speed changer
	end = GetEnt( "moving_platform_end_position", "targetname" );
	loader_platform thread platform_speed_changer( start, end );
	loader_platform thread platform_stop_for_actors();

	// Squash watcher
	loader_platform thread platform_squash();

	// Start the slow move
	loader_platform MoveX( 1500, 90, 5, 5 ); // 16.6 u/s
	loader_platform waittill( "movedone" );
	loader_platform notify( "stop_scripts" );
}

// Second platform for testing
presat_moving_platform_02()
{
	level endon( "presat_locked" );

	// Setup the loader platform
	loader_platform_02 = create_loader_platform( "loading_platform_02_node", "loading_platform_02" );

	flag_wait ( "presat_open_revolving_door" );

	loader_platform_02 thread platform_warning_lights( "platform_warning_light_02" );
	loader_platform_02 thread path_disconnector();

	// Teleport it into place
	start = GetEnt( "moving_platform_02_start_position", "targetname" );
	loader_platform_02 moveTo( start.origin, 0.1 );
	loader_platform_02 waittill( "movedone" );
	
	// Speed changer
	end_node = GetEnt( "moving_platform_02_end_position", "targetname" );

	// Squash watcher
	loader_platform_02 thread platform_squash();

	// How much to move?
	move_dist = abs( start.origin[0] - end_node.origin[0] );

	//loader_platform_02 thread maps\factory_audio::moving_platform_warning_beeps_sfx(start.origin);
	loader_platform_02 thread maps\factory_audio::moving_platform_movement_loop_sfx(start.origin, 26);
	
	// Start the slow move		
	loader_platform_02 MoveX( move_dist, 30, 5, 5 );
	loader_platform_02 waittill( "movedone" );
	loader_platform_02 notify( "stop_scripts" );
}

// Grabs all the parts, glues them together
create_loader_platform( node_name, parts_name )
{
	node = GetEnt( node_name, "targetname" );

	// Get all the parts and link them
	parts = GetEntArray( parts_name, "targetname" );
	foreach( part in parts )
	{
		if( isDefined( part.script_noteworthy ))
		{
			if( part.script_noteworthy == "connector_node" )
			{
				node.connector_node = part;
			}
			else if( part.script_noteworthy == "disconnector_node" )
			{
				node.disconnector_node = part;
			}
			else if( part.script_noteworthy == "ally_detector_node" )
			{
				node.ally_detector_node = part;
			}
		}
		part LinkTo( node );
	}
	return node;
}

// Cleans up the huge platform
delete_loader_platform()
{
	// Delete the parts
	maps\factory_util::safe_delete_targetname( "loading_platform" );
}

platform_enemies()
{
	self waittill( "spawn_enemies" );

	// Spawn the guys
	spawners = GetEntArray( "presat_platform_enemies", "targetname" );
	nodes = GetEntArray( "platform_guard_node", "script_noteworthy" );
	guys = [];
	foreach( i, spawner in spawners )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			AssertMsg( "Error platform_enemies failed to spawn guy" );
			return;
		}
		guy ForceTeleport( nodes[i].origin, nodes[i].angles );
		guy LinkTo( self );
		guy.ignoreall = true;
		guys[guys.size] = guy;
		guy thread alert_on_death();
		
		// If allies get shot in the tight corridor they cause blockage and look bad.
		// So make sure the enemies miss
		//guy.script_accuracy = 0.1;
	}

	thread alert_platform_guards( guys );
	thread alert_platform_guards_on_sight( guys );

	flag_wait( "presat_revolving_door_opened" );
	wait 2.1;
	flag_set( "alert_platform_guards" );
}

// If this guard dies, other guards get alerted
alert_on_death()
{
	self waittill( "damage" );
	flag_set( "alert_platform_guards" );

	// No ragdoll on moving platform
	self.noragdoll = true;
}

alert_platform_guards( guys )
{
	flag_wait( "alert_platform_guards" );

	foreach( guy in guys )
	{
		wait RandomFloatRange( 0.25, 0.45 );
	
		// Safety check - after wait he could be dead
		if( !isDefined( guy ))
		{
			continue;
		}

		// Stop patrol
		guy.ignoreall = false;
		guy StopAnimScripted();
		//guy SetLookAtEntity( level.player );
		guy.favoriteenemy = level.player;
	}
}

// The guards will become alerted automatically 2 seconds after entering the hallway
alert_platform_guards_on_sight( guys )
{
	flag_wait( "presat_started" );
	wait 1.0;
	flag_set( "alert_platform_guards" );
}

// Disconnects path nodes in front of the platform
path_disconnector( front_node_name, back_node_name )
{
	self endon( "death" );
	self endon( "stop_scripts" );
	level endon( "presat_locked" );
	
	// Get all the trigger brushes
	triggers = GetEntArray( "moving_platform_path_trigger", "targetname" );
	foreach( trig in triggers )
	{
		trig.connected = false;
		if( !isDefined( trig.script_parameters ))
		{
			trig ConnectPaths();
			trig.connected = true;
		}
		trig NotSolid();
	}

	// Get the probe node
	front_probe = self.disconnector_node;
	back_probe = self.connector_node;
	
	// Watch for the platform to run into each volume
	while( 1 )
	{
		foreach( trig in triggers )
		{
			if ( trig.connected && front_probe IsTouching( trig ) )
			{
				trig Solid();
				trig DisconnectPaths();
				trig.connected = false;
				trig NotSolid();
			}
			else if ( !trig.connected && back_probe IsTouching( trig ) )
			{
				trig Solid();
				trig ConnectPaths();
				trig.connected = true;
				trig NotSolid();
			}
		}
		wait 0.2;
	}
}

// Spinning lights for the platform
platform_warning_lights( node_name )
{
	node = GetEnt( node_name, "script_noteworthy" );
    if( !isDefined( node ))
    {
    	AssertMsg( "Error: platform_warning_lights() failed to get FX node - " + node_name );
    	return;
    }
    
	beam = node spawn_tag_origin();
	beam.origin = ( node.origin );
    beam LinkTo( node ); // JR - Uncomment this and the lights will rotate, but not move
    PlayFXOnTag( level._effect[ "amber_light_45_beacon_nolight_beam" ], beam, "tag_origin" );

    glow = node spawn_tag_origin();
	glow.origin = ( node.origin );
    glow LinkTo( node ); // JR - Uncomment this and the lights will rotate, but not move
    PlayFXOnTag( level._effect[ "amber_light_45_beacon_glow" ], glow, "tag_origin" );

    flag_wait( "presat_locked" );
   	StopFXOnTag( level._effect[ "amber_light_45_beacon_nolight_beam" ], beam, "tag_origin" );
   	StopFXOnTag( level._effect[ "amber_light_45_beacon_glow" ], glow, "tag_origin" );
   	
   	beam delete();
    glow delete();
}

/*
warning_light_rotate_solo()
{
	self endon( "death" );
	self endon( "presat_locked" );
	wait RandomFloatRange (0.1, 1.7);
	rotatetime = RandomFloatRange (1.4, 2.6);
	while( 1 )
	{
		self RotateYaw( 360, rotatetime );
	    wait rotatetime;
	}
}
*/

// Speed the platform up when the player hops on
// Normal speed = 16.6 u/s
// Fast speed = 32 u/s
platform_speed_changer( start, end )
{
	self endon( "stop_scripts" );
	level endon( "presat_locked" );

	flag_wait( "player_on_platform" );

	// Safety check
	if( !isDefined( self ))
	{
		return;
	}

	// Calculate new move time based on distance to target
	dist = abs( self.origin[0] - end.origin[0] );
	new_time = dist / 32.0;

	// Apply the new speed
	if( new_time > 10.0 )
	{
		self MoveTo( end.origin, new_time, 5.0, 5.0 );
	}
}

platform_stop_for_actors()
{
	self endon( "stop_scripts" );
	level endon( "presat_locked" );

	if( !isDefined( self.ally_detector_node ))
	{
		return;
	}

	while( 1 )
	{
		// Check distance to closest actor
		closest = get_closest_ai( self.origin );
		d = distance( closest.origin, self.ally_detector_node.origin );
		
		if( d < self.ally_detector_node.radius )
		{
			self MoveTo( self.origin + ( 15,0,0), 1.0, 0.5, 0.5 );
			return;
		}

		wait 0.25;
	}
}

// This kills the player if they get stuck in the moving objects
platform_squash()
{
	self endon( "stop_scripts" );
	level endon( "presat_locked" );
	
	// Dont start untill the player is in the room
	level waittill( "presat_close_revolving_door" );
	
	level.player waittill( "unresolved_collision" );
	RadiusDamage( level.player.origin, 1000, 1000, 1000 );
	wait 0.25;
	//"Keep clear of moving machinery."
	SetDvar( "ui_deadquote", &"FACTORY_MACHINE_DEATH_HINT" );
	thread missionFailedWrapper();
}


// =========================
// Automated doors
// =========================
presat_airlock_doors()
{
	// Setup the revolving door
	thread presat_revolving_door();
	
	// Setup the presat tunnel automatic sliding doors
	thread maps\factory_util::create_automatic_sliding_door( "sliding_door_sat_enter_01", 0.75, 0.1, "lock_presat_01" );
	thread maps\factory_util::create_automatic_sliding_door( "sliding_door_sat_enter_02", 0.75, 0.1, "lock_presat_02", "open_sat_entrance" );
	
	// Setup the gas spray FX when walking through the white tubes
	thread presat_tube_cleanser( "sat_tube_1_cleanse", "stop_tube_1_cleanse" );
	//thread presat_tube_cleanser( "sat_tube_2_cleanse", "stop_tube_2_cleanse" );
}

// Put the door in position
presat_init_revolving_door()
{
	flag_wait( "entered_factory_1" );

	// Get the door origin
	door = GetEnt( "revolving_door_origin", "targetname" );
	door_parts = GetEntArray( door.target, "targetname" );
	foreach( part in door_parts )
	{
		part LinkTo( door );
		part ConnectPaths();
	}
	level.presat_door = door;

	// Close the door initially
	//level.presat_door RotateYaw( -90, 0.1 );

	// Get the sliders
	level.presat_door_slider_01 = GetEnt( "revolving_door_slider_01", "targetname" );
	level.presat_door_slider_02 = GetEnt( "revolving_door_slider_02", "targetname" );

	// Close the sliders initially
	if( isDefined( level.presat_door_slider_01 ))
	{
		level.presat_door_slider_01 MoveX( 110, 0.1 );
	}
	if( isDefined( level.presat_door_slider_02 ))
	{
		level.presat_door_slider_02 MoveX( -110, 0.1 );
	}
}

// Entrance door to preSAT room
presat_revolving_door()
{
	flag_wait ( "presat_open_revolving_door" );

	// Make sure any left over powerstealth stuff is cleaned up
	thread cleanup_all_axis();
	
	thread maps\factory_audio::sfx_revolving_door_open(level.presat_door);
	thread maps\factory_fx::fx_sat_revolving_door_light_setup();
	Exploder( "presat_ambient" );
	
	// Open the door
	level.presat_door RotateYaw( 90, 4.83 );

	// Setup slider to protect against bad collision
	level.presat_door_slider_01 MoveX( -110, 4.83 );
	level.presat_door_slider_02 MoveX( 110, 4.83 );

	//presat_door waittill( "rotatedone" );
	wait 5.0; // Use wait instead of waittill rotate so they move out early

    flag_set( "presat_revolving_door_opened" );

	// Close the door to prevent back tracking
	flag_wait( "presat_close_revolving_door" );

	// Make sure player and allies are far enough away from the door
	safe_vol = GetEnt( "presat_door_safe_vol", "targetname" );
	while( 1 )
	{
		touching = safe_vol get_ai_touching_volume( "allies" );
		if( touching.size >= 3 && level.player isTouching( safe_vol ))
		{
			break;
		}
		wait 1.0;
	}
    level.presat_door RotateYaw( -90, 2 );
    level.presat_door waittill( "rotatedone" );
    wait 0.25;

    // Can't go back to powerstealth, so shutdown the conveyors
    level notify( "stop_box_conveyor_system" );
    flag_set( "presat_revolving_door_closed" );
}

// Plays an FX that sprays gas
presat_tube_cleanser( trigger_flag, end_notify )
{
	level endon( end_notify );
	
	while( 1 )
	{
		flag_wait( trigger_flag );
		exploder ("presat_air_cleanse");
		wait 6.5;
		pauseexploder ("presat_air_cleanse");
		wait 4.0;
	}
}

// =========================
// Automated forklifts
// =========================
// TODO - hook these up again
presat_agvs()
{
	flag_wait ( "presat_started" );
	
	// Spawn the first forklift

	spawner = GetEnt( "presat_forklift_01_spawner", "targetname" );
	spawner add_spawn_function( maps\factory_util::forklift_run_over_monitor, "presat_forklift_02" );
	
	spawner = GetEnt( "presat_forklift_02_spawner", "targetname" );
	spawner add_spawn_function( maps\factory_util::forklift_run_over_monitor );

	spawner = GetEnt( "presat_forklift_03_spawner", "targetname" );
	spawner add_spawn_function( maps\factory_util::forklift_run_over_monitor );

	// Wait for the door to start opening
	flag_wait( "presat_open_revolving_door" );
	maps\factory_util::safe_trigger_by_targetname( "presat_forklift_01" );
	maps\factory_util::safe_trigger_by_targetname( "presat_forklift_02" );
	maps\factory_util::safe_trigger_by_targetname( "presat_forklift_03" );

	// Only allow AGV3 to move once AGV1 has gone past - prevents head on collision
	flag_wait( "presat_agv_allow_agv2" );
	maps\factory_util::safe_trigger_by_targetname( "presat_forklift_01" );
}

// =========================
// Cleanup
// =========================
// Cleanup scripts and objects from Pre-SAT Room
presat_cleanup( force_cleanup )
{
	if( !isDefined( force_cleanup ))
	{
		level waittill( "presat_locked" );
	}
	
	// Kill any leftover enemies
	thread cleanup_all_axis();
	
	// Kill enemy spawners
	maps\factory_util::safe_delete_targetname( "presat_initial_enemies_01" );
	maps\factory_util::safe_delete_targetname( "presat_initial_enemies_02" );
	maps\factory_util::safe_delete_targetname( "presat_backup_enemies" );
	maps\factory_util::safe_delete_targetname( "presat_platform_enemies" );
	
	// Kill forklifts
	UGV = get_vehicle( "presat_forklift_01_spawner", "targetname" );
	maps\factory_util::safe_delete( UGV );

	// Kill moving platform
	thread delete_loader_platform();
	
	// Kill the fans
	maps\factory_util::safe_delete_targetname( "presat_fan_1" );
	maps\factory_util::safe_delete_targetname( "presat_fan_2" );

	// Kill the rotating door
	maps\factory_util::safe_delete_targetname( "revolving_door_origin" );
	maps\factory_util::safe_delete_targetname( "presat_room_door" );
}


// =========================
// Misc.
// =========================
// Cleanup some leftovers from powerstealth that may break weapon security
cleanup_all_axis()
{
	enemies = GetAISpeciesArray( "axis", "all" );
	foreach( guy in enemies )
	{
		if( isDefined( guy ) && isAlive( guy ))
		{
			if( !isDefined( guy.magic_bullet_shield ))
			{
				guy thread maps\factory_ambush::kill_after_time( 0.0, 1.0 );
			}
		}
	}
}

// Kills the decals when glass breaks
presat_glass_decals( targetname )
{
	level endon( "lock_presat_01" );

	glass = GetGlass( targetname );
	decal = GetEnt( targetname, "targetname" );

	while( 1 )
	{
		if( IsGlassDestroyed( glass ))
		{
			if( isDefined( decal ))
			{
				decal delete();
				//iprintlnbold( "DECAL DELETE" );
			}
			break;
		}
		wait 0.05;
	}
}

// Make em spin
presat_fans( targetname, time )
{
	level endon( "presat_locked" );

	// Get the fans
	fan = GetEnt( targetname, "targetname" );

	// Spin
	while( 1 )
	{
		fan RotatePitch( 360, time, 0, 0 );
		wait time;
	}
}


// ===============================================================================================================
// SAT Room
// ===============================================================================================================
sat_room_start()
{
	maps\factory_util::actor_teleport( level.squad[ "ALLY_ALPHA" ]	, "ALLY_ALPHA_weapon_room_teleport" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_BRAVO" ]	, "ALLY_BRAVO_weapon_room_teleport" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_CHARLIE" ], "ALLY_CHARLIE_weapon_room_teleport" );
	maps\factory_util::safe_trigger_by_targetname( "sat_allies_initial_position" );
	level.player maps\factory_util::move_player_to_start_point( "playerstart_weapon_room_alt" );

	level.squad[ "ALLY_ALPHA"	]thread enable_cqbwalk(	 );
	level.squad[ "ALLY_BRAVO"	]thread enable_cqbwalk(	 );
	level.squad[ "ALLY_CHARLIE" ]thread enable_cqbwalk(	 );

	//thread set_audio_zone("factory_wh1_tunnel");
	
	// Setup the entrance doors
	thread maps\factory_util::create_automatic_sliding_door( "sliding_door_sat_enter_01", 0.75, 0.1, "lock_presat_01" );
	thread maps\factory_util::create_automatic_sliding_door( "sliding_door_sat_enter_02", 0.75, 0.1, "lock_presat_02" );

	// Close previous doors
	level notify( "lock_presat_01" );
}

sat_room()
{
	// JR - Allows for faster debugging of the SAT interact anims
	if( isDefined( level.do_sat_shortcut ))
	{
		flag_wait( "sat_room_clear" );
		return;
	}

	// Do SAT anims or no?
	level.do_sat_anims = false;

	// Setup moving satellite pieces
	thread sat_room_move_pieces();

	// Setup camera event
	thread maps\factory_camera::sat_room_camera();

	// Start the assembly line and start heartbeat control room sound
	thread maps\factory_anim::factory_assembly_line_play();
	thread maps\factory_audio::sfx_play_heartbeat_sound();
	thread sat_room_doors();
	
	// Ally movement
	thread sat_room_ally_movement();

	// Setup the exit door
	thread setup_assembly_room_door();
	thread maps\_weather::rainNone ( 2 );

	// Setup the SAT hud target dummy models
	dummy_models = array_combine( GetEntArray( "sat_target_A_tag_nodes", "targetname" ), GetEntArray( "sat_target_B_tag_nodes", "targetname" ));
	foreach( model in dummy_models )
	{
		model Hide();
		model NotSolid();
	}

	// Save
	autosave_by_name( "sat_room" );
	flag_set( "lgt_weapon_room_jump" );
	
	// Setup the SAT board anim model
	// thread maps\factory_anim::sat_interact_setup_panel();
	
	// Don't let this trigger get hit early
	trigger_off( "sat_player_anim_trigger", "targetname" );

	//level thread sat_rod_cover_01();
	//level thread sat_rod_cover_02();
	//level thread sat_cpu_cover();
	level thread sat_automated_bridge();

	// Dialogue
	thread sat_room_dialogue();

	flag_wait( "sat_room_continue" );
	
	// Get ready for section cleanup
	thread sat_cleanup();
	
	flag_wait( "reveal_room_player_at_exit" );

	// Wait for the allies to arrive at the door
	level.squad[ "ALLY_ALPHA" ] PushPlayer( true );
	level.squad[ "ALLY_ALPHA" ].goalradius = 0;
	level.squad[ "ALLY_ALPHA" ] waittill( "goal" );
	level.squad[ "ALLY_ALPHA" ].goalradius = 2048;

	level.squad[ "ALLY_CHARLIE" ] PushPlayer( true );
	level.squad[ "ALLY_CHARLIE" ].goalradius = 0;
	level.squad[ "ALLY_CHARLIE" ] waittill( "goal" );
	level.squad[ "ALLY_CHARLIE" ].goalradius = 2048;

	flag_set( "sat_room_exiting" );

	// Open the ambush room doors
	level thread maps\factory_util::open_door( "ambush_door_pivot_left", -160, 0.5, true );
	level thread maps\factory_util::open_door( "ambush_door_pivot_right", 145, 0.5, true );

	// Allies post up on door
	wait 3.0;

	// Setup ambush stuff before the door opens
	thread maps\factory_ambush::ambush_setup();

	maps\factory_anim::reveal_room_exit_door();
	//wait 0.1;

	// Move allies to ambush room
	maps\factory_util::safe_trigger_by_targetname( "ambush_intro_ally01_position" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_intro_ally02_position" );
	maps\factory_util::safe_trigger_by_targetname( "ambush_intro_ally03_position" );

	// If player rushed, move guys into next room
	if( flag( "entered_pre_ambush_room" ))
	{
		wait 0.1;
		maps\factory_util::safe_trigger_by_targetname( "ambush_room_ally_positions" );
		level.squad[ "ALLY_ALPHA" ] set_generic_idle_anim( "casual_stand_idle" );
	}

	// Section done
	flag_set( "sat_room_clear" );
}

// New dialogue including the camera sequence
sat_room_dialogue()
{
	// Enter room
	flag_wait( "weapon_room_dialogue_trigger" );

	// Make sure the allies are in the room also
	safe_vol = GetEnt( "sat_room_alpha_start_vol", "targetname" );
	while( !safe_vol isTouching( level.squad[ "ALLY_ALPHA" ] ))
	{
		wait 0.1;
	}
	
	//wait 0.2;
	flag_set( "lgt_weapon_sequencing" );
	// Hesh: Now that's big! Are they really that big?
	//level.squad[ "ALLY_CHARLIE" ] smart_dialogue( "factory_hsh_whistlesnowthatsbig" );
	level.squad[ "ALLY_BRAVO" ] smart_dialogue( "factory_rgs_holy" );

	// Keegan moves in early
	//delayThread( 0.45, maps\factory_util::safe_trigger_by_targetname, "sat_room_bravo_move_in" );
	delayThread( 0.45, maps\factory_util::safe_trigger_by_targetname, "sat_ally_bravo_crouch" );

	// Merrick: Touchdown House Main. RECCE was spot on, LOKI is confirmed.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_touchdownhousemainrecce" );
	
	// Open the SAT tubes
	flag_set( "sat_raise_rod_01" );
	flag_set( "sat_raise_rod_02" );

	// Overlord: Copy. Jericho, we need confirmation of the RCS pods, weapons payload and guidance systems.
	//smart_radio_dialogue( "factory_hqr_rogerjerichopipingin" );
	smart_radio_dialogue( "factory_hqr_copyjerichoweneed" );

	// Merrick: Adam, get your eyes patched in. Hesh, you too.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_adamgetyoureyes" );

	// Allies move in while player does Camera
	delayThread( 0.25, ::flag_set, "sat_room_allies_move_in" );
	
	flag_set( "start_camera_moment" );
	wait 0.5;
	flag_set( "give_use_hint_if_needed" );
	
	// Merrick: Keegan, get the main heat shield open.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_keegangetthemain" );

	// Player does Camera
	flag_wait( "player_using_camera" );
	wait 0.2;
	
	// Overlord: Visual feed is up, you're coming in clear.
	smart_radio_dialogue( "factory_hqr_visualfeedisup" );
	
	// Merrick: Copy House Main. Send your traffic.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_copyhousemainsend" );

	// Overlord: Adam, pan up to the top of the satellite. You should see the RCS cluster.
	smart_radio_dialogue( "factory_hqr_adampanupto" );
	flag_set( "sat_begin_looking_for_A" );
	
	// Player scanned target 1
	flag_wait( "cam_A_confirmed" );

	wait 0.8;

	//------ REQUIRE SCAN -------
	if( isDefined( level.camera_require_scan ) && level.camera_require_scan == true )
	{
		thread maps\factory_util::add_debug_dialogue( "House-Main", "Good, now send us a scan.", "r" );
		flag_set( "sat_allow_scan" );
		flag_wait( "cam_A_scanned" );
		flag_clear( "sat_allow_scan" );
		wait 0.4;
	}
	//------ REQUIRE SCAN -------
	

	// Overlord: Ok, that's the main RCS control. It looks autonomous.
	smart_radio_dialogue( "factory_hqr_okthatsthemain" );
	
	wait 0.5;

	// Overlord: Scan over to the payload. Let's see what this platform is capable of.
	smart_radio_dialogue( "factory_hqr_scanovertothe" );
	flag_set( "sat_begin_looking_for_B" );

	// Player scanned target 2
	flag_wait( "cam_B_confirmed" );

	//------ REQUIRE SCAN -------
	if( isDefined( level.camera_require_scan ) && level.camera_require_scan == true )
	{
		thread maps\factory_util::add_debug_dialogue( "House-Main", "Upload a scan.", "r" );
		flag_set( "sat_allow_scan" );
		flag_wait( "cam_B_scanned" );
		flag_clear( "sat_allow_scan" );
	}
	//------ REQUIRE SCAN -------

	// Start the drawbridge going down so allies can exit
	delayThread( 4.2, ::flag_set, "sat_drawbridge_up" );
	delayThread( 5.0, ::flag_set, "sat_raise_cpu_cover" );

	wait 1.1;

	// Overlord: Damn... 12 rods, tungsten. Looks very similar to the ODIN design, a lot bigger.
	smart_radio_dialogue( "factory_hqr_damn12rodstungsten" );

	if( isDefined( level.do_sat_anims ) && level.do_sat_anims == true )
	{
		// Overlord: Let's get confirmation. Open the exterior access panels. Find the guidance controls.
		smart_radio_dialogue( "factory_hqr_letsgetconfirmationopen" );

		flag_wait( "sat_room_bridge_down" );
	
		//thread maps\factory_util::add_debug_dialogue( "Keegan", "Ok... I raised the exterior heat shield, it should be in there.", "g" );
		//wait 4.0;

		// Wait for ALPHA to get over near the satellite
		flag_wait( "sat_room_alpha_found_it" );

		// Player SAT interaction - Thread this early, incase player triggers it early
		// thread maps\factory_anim::sat_interact_player_controlled();

		// Merrick: Yup, I think I found it.
		level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_yupithinki" );
		flag_set( "sat_begin_looking_for_C" );

		wait 1.2;

		// Merrick: Adam, get footage of this guidance module.
		level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_adamgetfootageof" );
	
		// Tell the player to come over to the exposed part
		thread maps\factory_camera::sat_nag_come_to_C();
	}
		sat_room_anim_dialogue();
}

sat_room_anim_dialogue()
{
	if( isDefined( level.do_sat_anims ) && level.do_sat_anims == true )
	{
		flag_wait( "sat_do_player_anim" );

		wait 1.25;

		// Overlord: Pry it open.
		smart_radio_dialogue( "factory_hqr_pryitopen" );

		flag_wait( "sat_room_player_knifed" );

		wait 1.25;

		// Overlord: Careful...
		smart_radio_dialogue( "factory_hqr_careful" );

		wait 3.2;

		// Merrick: Alright, I'm looking at the guidance panels.
		level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_alrightimlookingat" );

		// Overlord: The panel on the right... pull it out and show it to me
		smart_radio_dialogue( "factory_hqr_thepanelonthe" );

		flag_wait( "sat_room_saw_board_front" );

		// Overlord: Ok, let's see the other side...
		smart_radio_dialogue( "factory_hqr_okletsseethe" );
		level notify( "sat_board_player_start_flip" );

		flag_wait( "sat_room_player_flipped" );
		wait 0.25;

		// Overlord: We have visuals on the serial numbers of the chips. That's what we needed.
		smart_radio_dialogue( "factory_hqr_wehavevisualson" );

		flag_set( "cam_C_confirmed" );
	
		// Overlord: Take the board wth you, we'll want to look at is closer.
		smart_radio_dialogue( "factory_hqr_taketheboardwth" );	
	}

	// Overlord: Good work, Jericho, this was a big find.
	smart_radio_dialogue( "factory_hqr_goodworkjerichothis" );
	
	// Allies move out while Overlord responds
	flag_set( "sat_room_continue" );

	// Merrick: Let's move!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_letsmove" );

	// Force camera off and take it away
	if( level.player.has_binoculars == true )
	{
		maps\factory_camera::disable_camera();
	}

	// Overlord: Arclight, you are confirmed for bomb-run.
	smart_radio_dialogue( "factory_hqr_arclightyouareconfirmed" );

	// Arclight: Copy Overlord - Genesis confirmed - 40 klicks out.
	smart_radio_dialogue( "factory_arc_copyoverlordgenesis" );

	// Overlord: Arclight 2-4, 2-5 and 2-6 are completing refuel and are en-route for bomb-run.
	smart_radio_dialogue( "factory_hqr_arclight2425and" );

	// Overlord: Rip any and all files from the computers and get out of there.
	smart_radio_dialogue( "factory_hqr_ripanyandall" );

	// Merrick: Copy that House Main.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_copythathousemain" );

	// Merrick: Oldboy - You copy that? Arclight is en route - this entire factory is going to disappear very soon.
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_mrk_oldboyyoucopythat" );

	// Oldboy: Copy - we're on it!
	level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_oby_copywereonit" );

	// Oldboy: Next hallway is clear - take a right, control room is the first door on your left.
	//smart_radio_dialogue( "factory_diz_hallwayisclear" );

	flag_wait( "sat_room_exiting" );

	//thread maps\factory_util::add_debug_dialogue( "Baker", "Airstrikes are incoming, make this quick.", "g" );
	//wait 2.5;

	// Merrick: Let's go.
	//level.squad[ "ALLY_ALPHA" ] smart_dialogue( "factory_bkr_letsgo3" );
}


// Handles ally movement through the SAT room
sat_room_ally_movement()
{
	// Enter room
	flag_wait( "sat_room_allies_move_in" );
	
	// Move into the room
	// Alpha and Charlie use computers
	level.squad[ "ALLY_ALPHA" ] thread maps\factory_anim::sat_room_alpha_typing();
	level.squad[ "ALLY_BRAVO" ] thread maps\factory_anim::sat_room_bravo_typing_01();
	maps\factory_util::safe_trigger_by_targetname( "sat_room_charlie_move_in" );
	
	// Wait for confirm 1
	flag_wait( "cam_A_confirmed" );
	wait 0.2;
	
	// Move to draw bridge
	maps\factory_util::safe_trigger_by_targetname( "sat_room_ally_wait_for_bridge" );

	// Wait for the bridge to go down
	flag_wait( "sat_room_bridge_down" );
	wait 0.1;
	/*
	if( isDefined( level.do_sat_anims ) && level.do_sat_anims == true )
	{
		// Move up to CPU
		maps\factory_util::safe_trigger_by_targetname( "sat_room_ally_wait_for_cpu" );
	
		// Bravo idle again
		//level.squad[ "ALLY_BRAVO" ] thread maps\factory_anim::sat_room_bravo_typing_02();
	
		// Wait for player to approach
		level.squad[ "ALLY_ALPHA" ] thread maps\factory_anim::sat_interact_ally();
	}*/

	// And wait for the section to finish
	flag_wait( "sat_room_continue" );
	level notify( "stop_nag" );
	wait 0.25;
	
	// In a hurry now, no CQB
	foreach( ally in level.squad )
	{
		//ally.moveplaybackrate = 1.0;
		ally disable_cqbwalk();
	}

	// Allies leave the room
	maps\factory_util::safe_trigger_by_targetname( "weapon_room_exit_positions" );
}

// Camera is forced on after a short period
sat_delayed_force_camera()
{
	if( isDefined( level.player.binoculars_active ) && level.player.binoculars_active && level.player.current_binocular_zoom_level != 0 )
	{
		// Force no zoom
		level.player.current_binocular_zoom_level = 0;
		level.player thread maps\factory_camera::binoculars_zoom();
	}

	wait 2.5;

	// If the camera isn't on, turn it on
	if( isDefined( level.player.binoculars_active ) && !level.player.binoculars_active )
	{
		force = true;
		level.player notify( "use_binoculars", force );
	}
}

// Alpha shoots the sattelite CPU just in case
sat_alpha_shoot_sat()
{
	//self.forceSideArm = true;

	flag_wait( "sat_shoot_cpu" );
	
	// Get the array of shoot pos
	pos = GetEnt( "sat_shoot_pos", "script_noteworthy" );

	while( isDefined( pos.target ))
	{
		self SetEntityTarget( pos );
		
		//if( isDefined( pos.script_parameters ))
		//{
		//	iprintlnbold( "waiting " + pos.script_parameters );
		//	wait 10; //float( pos.script_parameters );
		//}
		//else
		//{
			wait 0.1;
		//}
		
		self.shootPos = pos.origin;
		self thread animscripts\utility::shootPosWrapper( self.shootPos, false );

		// Get next pos
		pos = GetEnt( pos.target, "targetname" );
	}
	self ClearEntityTarget();

	//self.forceSideArm = false;
	
	wait 0.64;
}

// Handle the doors
sat_room_doors()
{
	// Setup exit doors
	thread maps\factory_util::create_automatic_sliding_door( "sliding_door_sat_exit_01", 0.75, 0.1, "lock_sat", "sat_room_continue" );
	thread maps\factory_util::create_automatic_sliding_door( "sliding_door_sat_exit_02", 0.75, 0.1, "lock_sat" );

	flag_wait( "sat_room_player_down_stairs" );

	// Make sure all allies are in the room!
	safe_vol = GetEnt( "sat_room_vol", "targetname" );	
	while( safe_vol get_ai_touching_volume( "allies" ).size < 3 )
	{
		wait 1.0;
	}

	// Lock the entrance door
	level notify( "lock_presat_01" );
	level notify( "lock_presat_02" );
	flag_set( "presat_locked" );

	// Lock the exit doors
	flag_wait( "sat_room_exiting" );
	level notify( "lock_sat" );
}

// SAT room object cleanup
sat_cleanup( force_cleanup )
{
	if( !isDefined( force_cleanup ))
	{
		// Wait untill the doors in the final gowning room lock closed
		level waittill( "lock_sat" );
	}
	
	// Clean up any left over nag scripts
	level notify( "stop_nag" );

	
	if( !isDefined( force_cleanup ))
	{
		// Set allies back to normal
		foreach( ally in level.squad )
		{
			ally.moveplaybackrate = 1.0;
		}
	}

	// Delete the bridge
	maps\factory_util::safe_delete_targetname( "sat_automated_bridge_right" );
	maps\factory_util::safe_delete_targetname( "sat_automated_bridge_left" );
	maps\factory_util::safe_delete_targetname( "sat_automated_bridge_right_org" );
	maps\factory_util::safe_delete_targetname( "sat_automated_bridge_left_org" );

	// Delete nodes
	maps\factory_util::safe_delete_noteworthy( "sat_cleanup_object" );
	maps\factory_util::safe_delete_noteworthy( "sat_shoot_pos" );
	
	if( !isDefined( force_cleanup ))
	{
		// Once ambush locks the door, more stuff can be cleaned up
		flag_wait( "ambush_triggered" );
	}
	
	// Delete SAT Parts
	maps\factory_util::safe_delete_targetname( "sat_rod_tube_01_cover" );
	maps\factory_util::safe_delete_targetname( "sat_rod_tube_02_cover" );
	//maps\factory_util::safe_delete_targetname( "sat_cpu_cover" );
		
	// Delete the doors
	maps\factory_util::safe_delete_noteworthy( "sliding_door_sat_enter_02" );
	maps\factory_util::safe_delete_noteworthy( "sliding_door_sat_exit_01" );
	maps\factory_util::safe_delete_noteworthy( "sliding_door_sat_exit_02" );
	maps\factory_util::safe_delete_noteworthy( "sliding_door_sat_enter_01" );
}

setup_assembly_room_door()
{
	// Get the door model
	door = GetEnt( "factory_assembly_room_door", "targetname" );
	
	// Get the door connector
	door_connector = GetEnt( "reveal_room_exit_door_connector", "targetname" );
	
	// Link them together
	door_connector LinkTo( door );

	// Save it
	door.connector = door_connector;
	level.assembly_room_door = door;
	thread maps\factory_fx::fx_show_hide( "assembly_cardreader_lock", "assembly_cardreader_unlock" );
	Stop_Exploder( "assembly_cardreader_unlock" );
	Exploder( "assembly_cardreader_lock" );
}

// Uncover the rods
sat_rod_cover_01()
{
	// Get the parts
	node = GetEnt( "sat_rod_tube_01_cover_node", "targetname" );
	parts = GetEntArray( node.target, "targetname" );
	foreach( part in parts )
	{
		part LinkTo( node );
	}

	// Wait for the lights to go on
	flag_wait( "sat_raise_rod_01" );
	node moveZ( 250, 12.0, 0.5, 0.5 );
}

// Uncover the rods
sat_rod_cover_02()
{
	// Get the parts
	node = GetEnt( "sat_rod_tube_02_cover_node", "targetname" );
	parts = GetEntArray( node.target, "targetname" );
	foreach( part in parts )
	{
		part LinkTo( node );
	}

	// 2nd salvo uncovers after first salvo
	flag_wait( "sat_raise_rod_01" );
	wait 5.5;
	node moveZ( 250, 12.0, 0.5, 0.5 );
}

// Uncover the satellite CPU
sat_cpu_cover( fast )
{
	maps\factory_util::safe_delete_targetname( "sat_cpu_cover" );
	/*
	// Get the parts
	node = GetEnt( "sat_cpu_cover_node", "targetname" );
	parts = GetEntArray( node.target, "targetname" );
	foreach( part in parts )
	{
		part LinkTo( node );
	}
	
	time = 8.0;
	if( isDefined( fast ))
	{
		time = 2.0;
	}

	// Wait for rod camera moment to finish
	flag_wait( "sat_raise_cpu_cover" );
	wait 2.0;
	node moveZ( 250, time, 0.5, 1.0 );
	*/
}

// Drawbridge platform mover
sat_automated_bridge()
{
	// Setup Right half
	bridge_right_org = GetEnt ( "sat_automated_bridge_right_org", "targetname" );
	parts			 = GetEntArray( "sat_automated_bridge_right", "targetname" );
	foreach ( part in parts )
	{
		part LinkTo( bridge_right_org );
	}
	
	// Setup the struts
	thread sat_automated_bridge_struts();

	// Setup Left half
	//bridge_left_org = GetEnt( "sat_automated_bridge_left_org", "targetname" );
	//parts			= GetEntArray( "sat_automated_bridge_left", "targetname" );
	//foreach ( part in parts )
	//{
	//	part LinkTo( bridge_left_org );
	//}

	// Raise the bridge initially
	bridge_right_org RotatePitch ( 80, 5 );
	//bridge_left_org RotatePitch ( 80, 5 );

	// Lower the bridge
	flag_wait( "sat_drawbridge_up" );
	bridge_right_org RotatePitch ( -80, 6 );
	//bridge_left_org RotatePitch ( -80, 6 );
	
	//Bridge lower SFX
	thread maps\factory_audio::sfx_bridge_lower( bridge_right_org );
	
	wait 4.0;
	
	// Bridge is done moving
	flag_set( "sat_room_bridge_down" );

	// TODO - player may be able to see that this has dissapeared
	// Cleanup when we leave
	flag_wait( "sat_room_exiting" );
	maps\factory_util::safe_delete( bridge_right_org );

	//bridge_left_org Delete();
}

// Lifter struts
sat_automated_bridge_struts()
{
	strut_org = GetEnt( "sat_automated_bridge_right_struts_org", "targetname" );
	strut_models = GetEntArray( "sat_automated_bridge_right_lifts", "targetname" );

	foreach( part in strut_models )
	{
		part LinkTo( strut_org );
	}
	flag_wait( "sat_drawbridge_up" );
	//strut_org RotatePitch( 15, 6 );
}

// Tooltip hint for SAT anims
sat_interact_activate_hint( hint_array, ender, waittime )
{
	level endon( ender );

	if( isDefined( waittime ))
	{
		wait( waittime );
	}

	// Determine stick config
	config = GetSticksConfig();
	if ( level.player is_player_gamepad_enabled() )
	{
		if ( config == "thumbstick_southpaw" || config == "thumbstick_legacy" )
			hintstring = hint_array["gamepad_l"];
		else
			hintstring = hint_array["gamepad"];
	}
	else
	{
		if ( config == "thumbstick_southpaw" || config == "thumbstick_legacy" )
			hintstring = hint_array["hint_l"];
		else
			hintstring = hint_array["hint"];
	}

	level.player thread display_hint( hintstring );

	// Keep showing the hint untill the ender is set
	while ( 1 )
	{
		wait( 5.0 );
		level.player thread display_hint( hintstring );
	}
}

sat_room_move_pieces()
{
	nosecone = GetEnt( "satellite_room_nosecone_org", "targetname" );
	vert_sections = GetEnt( "satellite_room_vert1_org", "targetname" );
	rog_holder = GetEnt( "satellite_room_rog_holder_org", "targetname" );
	rack_system = GetEnt( "satellite_room_rog_rack_system_org", "targetname" );
	satellite_ROG_01 = GetEnt( "satellite_ROG_01_org", "targetname" );
	satellite_ROG_02 = GetEnt( "satellite_ROG_02_org", "targetname" );
	satellite_ROG_03 = GetEnt( "satellite_ROG_03_org", "targetname" );
	satellite_ROG_04 = GetEnt( "satellite_ROG_04_org", "targetname" );
	satellite_ROG_05 = GetEnt( "satellite_ROG_05_org", "targetname" );
	satellite_ROG_06 = GetEnt( "satellite_ROG_06_org", "targetname" );
	destination = GetEnt( "satellite_room_dest_org", "targetname" );
	
	// Get the parts out of the prefabs and links them to the base entity
	nosecone_parts = GetEntArray( nosecone.target, "targetname" );
	foreach ( piece in nosecone_parts )
		piece LinkTo( nosecone );
	
	vert_sections_parts = GetEntArray( vert_sections.target, "targetname" );
	foreach ( piece in vert_sections_parts )
		piece LinkTo( vert_sections );
	
	rog_holder_parts = GetEntArray( rog_holder.target, "targetname" );
	foreach ( piece in rog_holder_parts )
		piece LinkTo( rog_holder );
	
	rack_system_parts = GetEntArray( rack_system.target, "targetname" );
	foreach ( piece in rack_system_parts )
		piece LinkTo( rack_system );
	
	satellite_ROG_01_parts = GetEntArray( satellite_ROG_01.target, "targetname" );
	foreach ( piece in satellite_ROG_01_parts )
		piece LinkTo( satellite_ROG_01 );
	
	satellite_ROG_02_parts = GetEntArray( satellite_ROG_02.target, "targetname" );
	foreach ( piece in satellite_ROG_02_parts )
		piece LinkTo( satellite_ROG_02 );
	
	satellite_ROG_03_parts = GetEntArray( satellite_ROG_03.target, "targetname" );
	foreach ( piece in satellite_ROG_03_parts )
		piece LinkTo( satellite_ROG_03 );
	
	satellite_ROG_04_parts = GetEntArray( satellite_ROG_04.target, "targetname" );
	foreach ( piece in satellite_ROG_04_parts )
		piece LinkTo( satellite_ROG_04 );
	
	satellite_ROG_05_parts = GetEntArray( satellite_ROG_05.target, "targetname" );
	foreach ( piece in satellite_ROG_05_parts )
		piece LinkTo( satellite_ROG_05 );
	
	satellite_ROG_06_parts = GetEntArray( satellite_ROG_06.target, "targetname" );
	foreach ( piece in satellite_ROG_06_parts )
		piece LinkTo( satellite_ROG_06 );
	
	destination_parts = GetEntArray( destination.target, "targetname" );
	foreach ( piece in destination_parts )
		piece LinkTo( destination);
	
	satellite_ROG_02 LinkTo( satellite_ROG_01);
	satellite_ROG_03 LinkTo( satellite_ROG_02);
	satellite_ROG_04 LinkTo( satellite_ROG_03);
	satellite_ROG_05 LinkTo( satellite_ROG_04);
	satellite_ROG_06 LinkTo( satellite_ROG_05);

	rack_system LinkTo(rog_holder);
	
	// SYSTEM SETUP -------------------------
	// Get the System to the Correct Starting Location
	vert_sections MoveTo ((destination.origin[0], vert_sections.origin[1], vert_sections.origin[2] ),1);
	rog_holder MoveTo ((destination.origin[0], rog_holder.origin[1], rog_holder.origin[2] ),1);
	satellite_ROG_01 MoveTo ((destination.origin[0], satellite_ROG_01.origin[1], satellite_ROG_01.origin[2] ),1);

	//IPrintLnBold ("waiting for door open");
	//flag_wait( "sat_room_allies_move_in" );
	//flag_wait( "start_moving_satellite_pieces" );
	//IPrintLnBold ("door open");

	// cap the nosecone piece
	nosecone MoveZ (205, 20, 0, 6);

	wait 5;
	
	// Audio: Rod mvmt sfx
	thread maps\factory_audio::sfx_rods_move();
	
	// MOVE SYSTEM TO SATELLITE -------------------------
	// move the pieces to loading location
	//IPrintLnBold ("moving pieces 1");
	rog_holder MoveTo ((satellite_ROG_01.origin[0], satellite_ROG_01.origin[1], destination.origin[2] ),10,0,3);
	satellite_ROG_01 MoveTo ((satellite_ROG_01.origin[0], satellite_ROG_01.origin[1], destination.origin[2] ),10,0,3);
	//rog_holder waittill ("movedone");
	wait 6;
	//IPrintLnBold ("moving pieces 2");
	vert_sections MoveTo ((destination.origin[0], destination.origin[1]+80, vert_sections.origin[2] ),10,0,3);
	rog_holder MoveTo ((destination.origin[0], destination.origin[1]+80, destination.origin[2] ),10,0,3);
	satellite_ROG_01 MoveTo ((destination.origin[0], destination.origin[1]+80, destination.origin[2] ),10,0,3);
	rog_holder waittill ("movedone");
	wait 1;

	// LOAD THE SATELLITE -------------------------
	rack_system Unlink();
	loader_dist = satellite_ROG_02.origin[1] - satellite_ROG_01.origin[1];
	rack_system MoveTo ((rack_system.origin[0], satellite_ROG_01.origin[1]+loader_dist, rack_system.origin[2] ),3,0.3,0.3);
	rack_system waittill ("movedone");
	// start rotation process
	// rinse and repeat ROG loading
	ROG_Move_and_Rotate ( satellite_ROG_01, satellite_ROG_02, satellite_ROG_01, rack_system, loader_dist, destination );
	ROG_Move_and_Rotate ( satellite_ROG_02, satellite_ROG_03, satellite_ROG_01, rack_system, loader_dist, destination );
	ROG_Move_and_Rotate ( satellite_ROG_03, satellite_ROG_04, satellite_ROG_01, rack_system, loader_dist, destination );
	ROG_Move_and_Rotate ( satellite_ROG_04, satellite_ROG_05, satellite_ROG_01, rack_system, loader_dist, destination );
	ROG_Move_and_Rotate ( satellite_ROG_05, undefined, satellite_ROG_01, rack_system, loader_dist, destination );

	// MOVE SYSTEM AWAY -------------------------
		wait 1;
	satellite_ROG_06 Unlink();
	satellite_ROG_06 LinkTo (rack_system);
	rack_system Unlink();
	rack_system MoveTo ((rack_system.origin[0], satellite_ROG_06.origin[1]+loader_dist*2, rack_system.origin[2] ),3,0.3,0.3);
	rack_system waittill ("movedone");
	rack_system LinkTo (rog_holder);
	vert_sections MoveTo ((vert_sections.origin[0], vert_sections.origin[1]+loader_dist*2, vert_sections.origin[2] ),10,3,3);
	rog_holder MoveTo ((rog_holder.origin[0], rog_holder.origin[1]+loader_dist*2, rog_holder.origin[2]-loader_dist ),10,3,3);

	// CLEAN UP -------------------------
	// clean up the pieces
	flag_wait( "player_used_computer" );
	//IPrintLnBold ("cleaning up pieces");
	moving_satellite_parts = GetEntArray( "satellite_room_moving_parts", "script_noteworthy" );
	foreach ( satellite_part in moving_satellite_parts  )
	{
		if ( IsDefined( satellite_part ) )
		{
			satellite_part Delete();
		}
	}
}

ROG_Move_and_Rotate ( loading_ROG, next_ROG, main_ROG, loader, dist, end_destination )
{
	loader LinkTo(loading_ROG);
	loading_ROG MoveTo ((end_destination.origin[0], end_destination.origin[1], end_destination.origin[2] ),3,0.3,0.3);
	loading_ROG waittill ("movedone");
	if ( IsDefined (next_ROG) )
	{
		next_ROG Unlink();
		loader Unlink();
		loader MoveTo ((loader.origin[0], next_ROG.origin[1]+dist, loader.origin[2] ),3,0.3,0.3);
		wait 1;
		
		if ( main_ROG != loading_ROG)
			loading_ROG LinkTo( main_ROG);
		else
			end_destination LinkTo( main_ROG);
		
		main_ROG RotateYaw (-72, 3, 0.5, 0.5);
		main_ROG waittill ("rotatedone");
	}
}