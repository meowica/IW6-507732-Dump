#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

bridge_deploy_init()
{
	level.start_point = "bridge_deploy";
}

bridge_deploy_main()
{
	kill_spawners_per_checkpoint( "bridge_deploy" );
	
	flag_init( "bridge_deploy_player_mount_tank" );
	flag_init( "bridge_deploy_kill_gaz" );
	// clean-up previous checkpoints
	level.player notify( "remove_tow" );

	// allow for script deletions to occur
	wait 0.05;
	
	if ( !IsDefined( level.playertank ) )
	{
		if ( level.start_point == "bridge_deploy" )
		{
			player_start = getstruct( "bridge_deploy_player", "targetname" );
		}
		else
		{
			level.player Unlink();
			player_start = level.player;
		}
		level.player SetOrigin( player_start.origin );
		level.player SetPlayerAngles( player_start.angles );
		
		spawn_player_checkpoint( "bridge_deploy_", "bridge_deploy_player_mount_tank" );
		
		// setup allies
		spawn_heroes_checkpoint( "bridge_deploy_" );
		
		thread rotate_big_sat();
	}
	
	level.herotanks[ 0 ] thread tank_relative_speed( "bridge_deploy_relative_speed", "bridge_deploy_end", 1000, 20, 10 );
	level.herotanks[ 1 ] thread tank_relative_speed( "bridge_deploy_relative_speed", "bridge_deploy_end", 1000, 20, 10 );
	
	foreach ( hero in level.herotanks )
	{
		if ( IsDefined( hero.mgturret ) )
			hero.mgturret[ 0 ] TurretFireDisable();
	}
	
	spawn_bridge_deploy_allies( "bridge_deploy_" );
	
	thread bridge_deploy_begin();
	
	flag_wait( "bridge_deploy_end" );
	
	maps\_spawner::killspawner( 300 );
	kill_vehicle_spawners_now( 300 );
}

spawn_bridge_deploy_allies( checkpoint_name )
{
	level.bridge_allies = [];
	
	//array_spawn_function_noteworthy( "bridge_allies", ::npc_tank_combat_init );
	
//	level.bridge_allies[ 0 ]   = spawn_vehicle_from_targetname_and_drive( checkpoint_name + "ally0" );
  //level.bridge_allies[ 1 ] = spawn_vehicle_from_targetname_and_drive( checkpoint_name + "ally1" ); //this is the guy who crosses the bridge
	//allies					   = spawn_vehicles_from_targetname_and_drive( checkpoint_name + "allies" );
	
//	foreach ( ally in allies )
//	{
//		if ( IsDefined( ally.mgturret ) )
//			ally.mgturret[ 0 ] TurretFireDisable();
//	}
	
	level.allies2 = spawn_vehicles_from_targetname_and_drive( checkpoint_name + "allies2" );
			  //   entities       process 				 
	array_thread( level.allies2, ::npc_tank_combat_init );
	array_thread( level.allies2, ::set_one_hit_kill );
	
//	for( i = 0; i != 1; i ++ )
//	{
//		level.bridge_allies[ i ] thread flag_wait_god_mode_off( "bridge_deploy_player_mount_tank" );
//	}
//	
	//level.bridge_allies = array_combine( allies, level.bridge_allies );
	level.allytanks		= array_combine( level.allytanks, level.bridge_allies );
}

bridge_deploy_begin()
{
//	enemies = GetAIArray( "axis" );
//	thread AI_delete_when_out_of_sight( enemies, 2048 );
//	
//	enemytanks = getVehicleArray();
//	
//	foreach( enemytank in enemytanks )
//	{
//		if( IsDefined( enemytank.script_team ) && enemytank.script_team == "axis" )
//		{
//			enemytank thread enemytank_cleanup();
//		}
//	}
	
//	hangar_door_breakable = GetEnt( "hangar_door_breakable", "targetname" );
//	if( IsDefined( hangar_door_breakable ) )
//		hangar_door_breakable Delete();
	
	level.player thread tower_to_bridge_deploy();
	
	wait 5;
	array_thread( level.allytanks, ::npc_tank_combat_init );
	
	thread setup_bridge_deploy_choppers();
	thread bridge_deploy_enemy_tanks_setup();
	
	wait 1;
	
	autosave_by_name( "deploy" );
	Objective_Add( obj( "satellite" ), "active", "Take down the Loki Defense Satellite." );
	
	//Overlord: Badger One One, what is your sitrep?
	radio_dialog_add_and_go( "satfarm_hqr_badgeroneonewhat" );
	//Badger: Overlord, we need air support at the bridge.
	radio_dialog_add_and_go( "satfarm_bgr_overlordweneedair" );
	
	wait 0.5;
	
	foreach ( ally in level.allytanks )
	{
		if ( IsDefined( ally.mgturret ) )
			ally.mgturret[ 0 ] TurretFireEnable();
	}
	
	//Overlord:  Roger. A-10’s are en route.
	radio_dialog_add_and_go( "satfarm_hqr_rogera10sareen" );
	
	flag_wait_or_timeout( "assualt_bridge", 3 );
	flag_set( "assualt_bridge" );
	
	thread bridge_deploy_enemy_a10_gun_dives();
	
	wait 2;
	
	//Badger: Enemy lines have been broken, Overlord.
	radio_dialog_add_and_go( "satfarm_bgr_enemylineshavebeen" );
	//Overlord: Mop it up. Take out anything that moves.
	radio_dialog_add_and_go( "satfarm_hqr_mopituptake" );
	radio_dialog_add_and_go( "tankdrive_alt_punchit" );
	
	flag_wait( "bridge_end" );
	
	foreach ( ally in level.bridge_allies )
	{
		if ( IsDefined( ally ) )
			ally Delete();
	}
}

setup_bridge_deploy_choppers()
{
	//maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "heli_nav_mesh_air_strip_array" );
	//spawn_hind_enemies( 3, "heli_nav_mesh_start_air_strip_array" );
	//waittillhelisdead( get_hinds_enemy_active(), 2 );
	
	//wait( 1.0 );
	
	flag_set( "bridge_layer_choppers_dead" );
	
	choppers = get_hinds_enemy_active();
	
	foreach ( chopper in choppers )
	{
		chopper Kill();
	}
}

bridge_deploy_enemy_tanks_setup()
{
	array_spawn_function_targetname( "air_strip_bridge_enemies", ::npc_tank_combat_init );
	array_spawn_function_targetname( "air_strip_bridge_enemies", ::flag_wait_god_mode_off, "bridge_deploy_player_mount_tank" );
	
	//enemy_helis = spawn_vehicles_from_targetname_and_drive( "heli_ride_enemy_heli_1" );
	
	level.enemytanksbri1 = spawn_vehicles_from_targetname_and_drive( "air_strip_bridge_enemies" );
	level.enemytanks	 = array_combine( level.enemytanks, level.enemytanksbri1 );
	
	level.enemytanksbri2 = spawn_vehicles_from_targetname_and_drive( "air_strip_bridge_enemies2" );
	level.enemytanks	 = array_combine( level.enemytanks, level.enemytanksbri2 );
	
	enemy_gazs = spawn_vehicles_from_targetname_and_drive( "dday_gazs" );
	array_thread( enemy_gazs, ::gaz_spawn_setup );
	level.enemygazs = array_combine( level.enemygazs, enemy_gazs );
	array_thread( enemy_gazs, ::flag_wait_god_mode_off, "bridge_deploy_kill_gaz" );
	
	level.enemytanksdday	= spawn_vehicles_from_targetname_and_drive( "dday_firstwave_tank" );
	level.enemytanks 		= array_combine( level.enemytanks, level.enemytanksdday );
	enemytanks2		 		= spawn_vehicles_from_targetname_and_drive( "dday_secondwave_tank" );
	level.enemytanks 		= array_combine( level.enemytanks, enemytanks2 );
	wait 4;
	
	enemysup  		= array_spawn_targetname( "dday_enemies_tanksup" );
	
	wait 2;
	
	flag_set( "bridge_deploy_kill_gaz" );

	i = 0;
	
	array_thread( level.enemytanks, ::npc_tank_combat_init );
	foreach ( tank in level.enemytanks )
	{
		tank no_target_player_and_heros( i );
		if( i == level.allies2.size )
			i = 0;
		else
			i++;
	}
	
	
	waittilltanksdead( level.enemytanksdday, 3, 0, "assualt_bridge" );
	
	flag_set( "assualt_bridge" );
	
	array_thread( level.enemytanksdday, ::set_one_hit_kill );
	
	wait 3;
	
	foreach ( tank in level.enemytanksdday )
	{
		if ( IsDefined( tank ) )
			tank Kill();
		
		wait RandomFloatRange( 0.1, .5 );;
	}
	
//	foreach( enemy in enemysup )
//	{
//		if( IsDefined( enemy ) )
//			enemy kill();
//	}
	
	flag_wait( "a10_bridge" );
	
	wait 3;
	
	foreach ( tank in enemytanks2 )
	{
		if ( IsDefined( tank ) )
			tank Kill();
		
		wait RandomFloatRange( 0.1, .5 );;
	}
}

no_target_player_and_heros( i )
{
	self set_override_target( level.allies2[ i ] );
	
	level.allies2[ i ] waittill( "death" );
	
	if( IsDefined( level.allies2[ 0 ] ) )
		self set_override_target( level.allies2[ 0 ] );
	else if( IsDefined( level.allies2[ 1 ] ) )
		self set_override_target( level.allies2[ 1 ] );
	else if( IsDefined( level.allies2[ 2 ] ) )
		self set_override_target( level.allies2[ 2 ] );
}

bridge_deploy_enemy_a10_gun_dives()
{
	spawn_vehicle_from_targetname_and_drive( "bridge_a10_gun_dive_1c" );
	
	wait( 0.05 );
	
	spawn_vehicle_from_targetname_and_drive( "bridge_a10_gun_dive_1d" );
	
	wait 1;
	
	spawn_vehicle_from_targetname_and_drive( "bridge_a10_gun_dive_1a" );
	
	wait( 0.25 );
	
	spawn_vehicle_from_targetname_and_drive( "bridge_a10_gun_dive_1b" );
	
	wait 2;
	
	foreach( tank in level.enemytanksdday )
	{
		if ( IsDefined( tank ) )
			tank Kill();
		
		wait RandomFloatRange( 0.1, .5 );
	}
	
	flag_wait( "a10_bridge" );
	
	spawn_vehicle_from_targetname_and_drive( "bridge_a10_gun_dive_2a" );
	
	wait( 0.5 );
	
	spawn_vehicle_from_targetname_and_drive( "bridge_a10_gun_dive_2b" );
	
	wait 2;
	
	foreach ( tank in level.enemytanksbri1 )
	{
		if ( IsDefined( tank ) )
			tank Kill();
		
		wait RandomFloatRange( 0.1, .5 );
	}
	
	bridgeKill = spawn_vehicles_from_targetname( "bridge_kill" );
	foreach ( tank in bridgeKill )
	{
		if ( IsDefined( tank ) )
			tank Kill();
		
		wait RandomFloatRange( 0.1, .5 );
	}
	
//	spawn_vehicle_from_targetname_and_drive( "bridge_enemy_a10_gun_dive_1" );
	
	wait( 0.25 );
	
//	spawn_vehicle_from_targetname_and_drive( "bridge_enemy_a10_gun_dive_2" );
	
	wait 2;
	
	foreach ( tank in level.enemytanksbri2 )
	{
		if ( IsDefined( tank ) )
			tank Kill();
		
		wait RandomFloatRange( 0.1, .5 );
	}
	
	//helis = spawn_vehicles_from_targetname_and_drive( "apache_ally_spawner1" );
	
	//flag_wait( "bridge_end" );
	
	//wait 10;
	
	//helis[0] kill();
	
	//wait 6;
	
	//helis = spawn_vehicles_from_targetname_and_drive( "apache_ally_spawner2" );
}

tower_to_bridge_deploy()
{
	// disable controls
	self FreezeControls( true );
	self EnableInvulnerability();
	self DisableWeapons();
	self DisableOffhandWeapons();
	level.player AllowProne( false );
   	level.player AllowCrouch( false );
   	level.player AllowSprint( false );
   	level.player AllowJump( false );

	travel_time = 1.75;
	zoomHeight	= 15000;

	//Overlord: Foxtrot-9 HVA has cleared, divert units to forward area.
	thread radio_dialog_add_and_go( "satfarm_hqr_foxtrot9hvahascleared" );
	//ComUnit3: Heavy fighting in sectors 3 and 4, rallying 14th division.
	level.player thread play_sound_on_entity( "satfarm_cu3_heavyfightinginsectors" );
	thread static_on( 0.25, 1, .05, .25 );
	
	// setup player origin
	origin = self.origin;
	self PlayerSetStreamOrigin( origin );
	
	self.origin = origin;

	// create rig to link player view to
	ent = Spawn( "script_model", ( 0, 0, 0 ) );
	ent SetModel( "tag_origin" );
	ent.origin = self.origin;
	ent.angles = self.angles;
	ent.angles = ( ent.angles[ 0 ], ent.angles[ 1 ] + 180, ent.angles[ 2 ] );
	
	// link player
	self PlayerLinkTo( ent, undefined, 1, 0, 0, 0, 0 );
	ent.angles = ( ent.angles[ 0 ] + 89, ent.angles[ 1 ], 0 );
	
	ent MoveTo( origin + ( 0, 0, zoomHeight ), travel_time, 0, travel_time );
	
	// delay so sound would play
	wait 0.05;
	
	// SHUUUUUU
	self PlaySound( "survival_slamzoom_out" );
	
	level.introscreen.lines = [ "The Harder They Fall", "April 1st", "Major Nelson", "B Armored Division", "White Sands, Venezula" ];
	thread maps\_introscreen::introscreen( false, 0 );
	
	thread static_on( 0.25, 1, .1, .05 );
	level.player uav_thermal_on( 0, "ac130" );
	
	wait( 2 );
	
	//thread radio_dialog_add_and_go( "satfarm_cu3_heavyfightinginsectors" );
	level.player.ignoreme = 1;
	
	wait( 1.0 );
	
	static_on( 0.25, .25, .1, .05 );
	//Overlord: Prime the payload Eagle-Two, we’re closing in.
	thread radio_dialog_add_and_go( "satfarm_hqr_primethepayloadeagletwo" );
	xy_move_time = 3;
	
	tank_player_link_org = Spawn( "script_model", ( level.playertank.origin[ 0 ], level.playertank.origin[ 1 ], ent.origin[ 2 ] ) );
	tank_player_link_org SetModel( "tag_origin" );
	tank_player_link_org.angles = ( 90, 0, 0 );
	tank_player_link_org LinkTo( level.playertank );
	
	ent MoveTo( ( tank_player_link_org.origin[ 0 ], tank_player_link_org.origin[ 1 ], self.origin[ 2 ] ), xy_move_time );
	//level.player PlayerLinkToblend( tank_player_link_org, "tag_origin", 2.0 );
	
	thread static_on( 2.5, 1, .1, .05 );
	
	wait( xy_move_time + 2.0 );
	
	tank_player_link_org = Spawn( "script_model", level.playertank GetTagOrigin( "tag_player" ) );
	tank_player_link_org SetModel( "tag_origin" );
	angles = level.playertank GetTagAngles( "tag_player" );
	tank_player_link_org LinkTo( level.playertank, "tag_origin", ( 0, 0, 0 ), ( 90, angles[ 1 ], angles[ 2 ] ) );
	
	self PlaySound( "survival_slamzoom" );
	
	level.player PlayerLinkToBlend( tank_player_link_org, "tag_player", 0.75 );
	
	wait( 0.5 );
	
	thread static_on( 0.25, 1, .1, .05 );
	wait 0.1;
	level.player uav_thermal_off();
	
	wait 0.2;
	
	//mount to tank
	self Unlink();
	
	flag_set( "bridge_deploy_player_mount_tank" );
	
	self FreezeControls( false );
	self PlayerClearStreamOrigin();
	level.player.ignoreme = 0;
}