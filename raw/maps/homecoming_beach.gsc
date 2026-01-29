#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\homecoming_beach_ambient;
#include maps\homecoming_util;
#include maps\homecoming_drones;

#using_animtree( "generic_human" );
beach_spawn_functions()
{
	// AI \\
	
	array_spawn_function_noteworthy( "default_beach_enemy", ::beach_enemy_default );
	
	// bunker
	//getent( "bunker_javelin_guy", "script_noteworthy" ) add_spawn_function( ::bunker_javelin_guy );
	array_spawn_function_noteworthy( "beach_javelin_drone", ::bunker_javelin_drones );
	array_spawn_function_targetname( "beach_n90_spawners", ::bunker_beach_attackers_think );
	array_spawn_function_targetname( "beach_n90_spawners", ::beach_enemy_default );
	//array_spawn_function_targetname( "initial_beach_runners", ::bunker_beach_attackers_think );
	array_spawn_function_noteworthy( "bunker_minigun_guy", ::bunker_mg_guy );
	
	// trench
	array_spawn_function_targetname( "hovercraft_drone_spawner", ::hovercraft_drone_default );
	array_spawn_function_noteworthy( "trench_friendly_orange_guy", ::trench_friendly_orange_guy );
	array_spawn_function_noteworthy( "trench_bridge_ai", ::trench_bridge_ai );
	array_spawn_function_targetname( "trenches_shack_flooder", ::trench_shack_ai );
	//array_spawn_function_targetname( "trench_nest_rpg_flooders", ::trench_enemy_nest_ai );
	
	// VEHICLES \\
	
	// bunker
	getent( "bunker_flyby_hind", "targetname" ) add_spawn_function( ::vehicle_path_notifications );
	//array_spawn_function_noteworthy( "default_beach_vehicle", ::beach_vehicle_default );
	array_spawn_function_noteworthy( "bunker_landers_group1", ::bunker_reinforcement_helis );
	array_spawn_function_noteworthy( "bunker_landers_group2", ::bunker_reinforcement_helis );
	array_spawn_function_targetname( "beach_lander", ::heli_beach_lander_init );
	array_spawn_function_noteworthy( "hovercraft_tanks", ::beach_hovercraft_tanks_default );
	array_spawn_function_targetname( "hovercraft_unloader", ::hovercraft_init );
	
	array_thread( getentarray( "beach_mg_spawners", "targetname" ), maps\_mgturret::mg42_think );
	
	// trench
	getent( "tower_rappel_nh90", "targetname" ) add_spawn_function( ::tower_rappel_nh90 );
	getent( "trench_hovercraft_drones", "script_noteworthy" ) add_spawn_function( ::trench_hovercraft_drones );
	getent( "trench_hovercraft_a10", "script_noteworthy" ) add_spawn_function( ::trench_hovercraft_a10 );
	array_spawn_function_targetname( "trench_hovercraft", ::trench_hovercraft );
	getent( "trench_tower_hind", "targetname" ) add_spawn_function( ::trench_tower_hind );
	
	//thread beach_a10_strafe_test();

}

// BUNKER SEQUENCE
beach_sequence_bunker_new()
{
	flag_wait( "FLAG_start_bunker" );
	
	/*-----------------------
	BEACH AMBIENT
	-------------------------*/
	thread init_beach_ambient();
	
	/*-----------------------
	BEACH ENEMY HOVERCRAFTS
	-------------------------*/
	hovercrafts = getentarray( "beach_hovercraft_loopers", "script_noteworthy" );
	array_thread( hovercrafts, ::beach_hovercraft_looper );
	
	/*-----------------------
	BEACH ENEMY TANKS
	-------------------------*/
	vSpawners = getentarray( "bunker_enemy_tanks", "targetname" );
	foreach( spawner in Vspawners )
	{
		tank = spawner spawn_vehicle_and_gopath();
		tank.fireTime[0] = 3;
		tank.fireTime[1] = 8;
		level.javelinTargets = array_add( level.javelinTargets, tank );
		level.strafeVehicles = array_add( level.strafeVehicles, tank );
		
		tank thread vehicle_allow_player_death();
	}
	
	/*-----------------------
	BEACH ENEMY AI BEHAVIOR
	-------------------------*/
	array_thread( getnodearray( "beach_front_nodes", "targetname" ), ::beach_front_nodes_think );
	
	//maps\_spawner::flood_spawner_scripted( getentarray( "trench_nest_rpg_flooders", "targetname" ) );
	
	attackerSpawners = getentarray( "beach_front_attackers", "targetname" );
	array_thread( attackerSpawners, ::bunker_beach_attackers );	
	
	/*-----------------------
	BEACH ENEMY DRONE BEHAVIOR
	-------------------------*/
	droneSpawners = getentarray( "bunker_enemy_cover_drones", "targetname" );
	array_thread( droneSpawners, ::bunker_enemy_cover_drones );
	
	runnerSpawners = getentarray( "beach_front_runners", "targetname" );
	foreach( spawner in runnerSpawners )
	{
		time = 0;
		if( isdefined( spawner.script_wait ) )
			time = spawner.script_wait;
		spawner delaythread( time, ::beach_path_drones );
	}
	
	references = getstructarray( "hovercraft_drone_fightspots_reference", "targetname" );
	foreach( reference in references )
	{
		fighSpots = reference get_linked_structs();
		array_thread( fighSpots, ::hovercraft_drone_fightspots );
	}
	
	/*-----------------------
	BEACH ALLY DRONE BEHAVIOR
	-------------------------*/
	thread bunker_trench_drone_runners();
	
	droneSpawners = getentarray( "beach_frontline_drones", "targetname" );
	foreach( spawner in droneSpawners )
	{
		granted = drones_request( 1 );
		if( granted )
		{
			drone = spawner spawn_ai();
			drone thread drones_death_watcher();
		}
	}
	
	/*-----------------------
	BEACH ALLY FAKE JAVELINS
	-------------------------*/
	jSpots = getstructarray( "fake_beach_javelins", "targetname" );
	foreach( spot in jSpots )
	{
		targets = undefined;
		if( isdefined( spot.target ) )
			targets = getstructarray( spot.target, "targetname" );
		
		if( spot parameters_check( "target_tanks" ) )
			spot.javelin_smartTargeting = true;
		
		spot thread drone_fire_fake_javelin_loop( targets );
	}
	
	
	//delaythread( 50, ::end_of_scripting, "Use StartPoint *trench* to continue" );
	
	/*-----------------------
	START PLAYER A10 MECHANIC
	-------------------------*/
	flag_wait( "TRIGFLAG_player_at_balcony" );
	
	wait( .5 );
	thread add_dialogue_line( "Hesh", "Enemy tanks!" );
	wait( .4 );
	thread add_dialogue_line( "Hesh", "Overlord! We need airsupport on our position!" );
	wait( .5 );
	thread add_dialogue_line( "Overlord", "Roger that. A10 drones are entering your airspace now." );
	wait( .4 );
	thread add_dialogue_line( "Overlord", "A10 drone ready to use on your mark." );
	
	thread maps\homecoming_a10::a10_strafe_mechanic( "bunker_player_a10_strafe_1" );
	
	flag_wait( "DEATHFLAG_bunker_tanks_destroyed" );
	
	/*-----------------------
	SHUT OFF A10 MECHANIC
	-------------------------*/
	level notify( "A10_MECHANIC_OFF" );
	
	/*-----------------------
	BUNKER BALCONY JUMP DOWN
	-------------------------*/
	getent( "beach_balcony_broken", "targetname" ) show_entity();
	getent( "beach_balcony_intact", "targetname" ) delete();
	array_delete( getentarray( "beach_balcony_intact_models", "targetname" ) );
	
	jumpSpot = getstruct( "bunker_hesh_jumpdown", "targetname" );
	jumpSpot anim_single_solo( level.hesh, "bunker_jumpdown_1" );
	jumpSpot = getstruct( "bunker_hesh_jumpdown_2", "targetname" );
	jumpSpot anim_single_solo( level.hesh, "bunker_jumpdown_2" );
	
	dogTele = getstruct( "bunker_dog_jumpdown_tele", "targetname" );
	level.dog ForceTeleport( dogTele.origin, dogTele.angles );
	
	// Wait for player to jump down
	flag_wait( "TRIGFLAG_player_jumped_down_balcony" );
	
	/*-----------------------
	TURN OFF MOST OF BEACH STUFF
	-------------------------*/
	level notify( "beach_attacker_logic_off" );
	beachAttackers = get_living_ai_array( "beach_front_attackers", "targetname" );
	array_kill( beachAttackers );
	
	flag_set( "FLAG_stop_trench_drones" );
	
	/*-----------------------
	START TRENCHES
	-------------------------*/
	flag_set( "FLAG_start_trenches" );
	
}

#using_animtree( "vehicles" );
beach_hovercraft_looper()
{
	// ENDER
	
	spawner = self;
	ents = spawner get_linked_ents();
	starter = undefined;
	foreach( ent in ents )
	{
		if( ent parameters_check( "starter" ) )
		{
			starter = ent;
			break;			
		}
	}
	
	if( isdefined( starter ) )
		hovercraft = starter spawn_vehicle_and_gopath();
	else
		hovercraft = spawner spawn_vehicle_and_gopath(); 

	while( 1 )
	{
		array_add( level.mortarExcluders, hovercraft );
		thread array_remove_when_dead( level.mortarExcluders, hovercraft );
		hovercraft waittill( "hovercraft_spawn" );
		hovercraft = spawner spawn_vehicle_and_gopath(); 

	}
}

bunker_enemy_cover_drones()
{
	// ENDER
	
	while( 1 )
	{
		granted = drones_request( 1 );	
		if( granted )
		{
			drone = self spawn_ai();
			drone drones_death_watcher();
		}
		wait( randomintrange( 2, 3 ) );
	}
}

bunker_beach_attackers()
{
	level endon( "beach_attacker_logic_off" );
	
	laneSpot = getstruct( self.target, "targetname" );
	if( !isdefined( laneSpot.aiAmount ) )
		laneSpot.aiAmount = 0;
	
	laneSpot.aiAmount = laneSpot.aiAmount + self.script_index;
	laneSpot.aliveAI = [];
	while( 1 )
	{
//		spawnNum = laneSpot.aiAmount - laneSpot.aliveAI.size;
		// Helicopters can add to lane AI, so if there are more AI in lane than laneAmount
		// don't spawn more AI
//		if( spawnNum < 1 )
//		{
//			wait( 1 );
//			continue;
//		}
		
		laneSpot.aliveAI = remove_dead_from_array( laneSpot.aliveAI );
		if( laneSpot.aiAmount - laneSpot.aliveAI.size < 1 )
		{
			wait( 1 );
			continue;
		}
			
		
		while( laneSpot.aiAmount - laneSpot.aliveAI.size > 0 )
		{
			ai = self spawn_ai();
			if( !isdefined( ai ) )
			{
				wait( .05 );
				continue;
			}
			laneSpot.aliveAI[ laneSpot.aliveAI.size ] = ai;
			ai thread bunker_beach_attackers_think( laneSpot );
			waitframe();
			wait( .1 );
			laneSpot.aliveAI = remove_dead_from_array( laneSpot.aliveAI );
		}
		
		wait( randomintrange( 5, 10 ) );
		
	}
}

bunker_beach_attackers_think( target )
{	
	self endon( "death" );
	
	if( !isdefined( target ) )
		target = getstruct( self.target, "targetname" );
	if( !isdefined( target ) )
		return;
	
	self.grenadeawareness = 0;
	
	self setgoalpos( target.origin );
	self thread waittill_real_goal( target );
	//self thread bunker_beach_attackers_death( target );
	
	if( !parameters_check( "ignore_nodes" ) )
		level.beachFrontGuys[ level.beachFrontGuys.size ] = self;
	
	level.bunker_beach_ai[ level.bunker_beach_ai.size ] = self;
	
//	self waittill( "setting_new_goal" );
//	self waittill( "goal" );
//	
//	wait( randomintrange( 10, 20 ) );
//	
//	self setgoalpos( target.origin );
//	self thread waittill_real_goal( target );
}

// Randomness when AI dies
KILL_RUNNERS_DIST_MAX = 400;
bunker_beach_attackers_death( target )
{
	self endon( "death" );
	
	deathDist = randomintrange( 25, KILL_RUNNERS_DIST_MAX );
	deathDist = squared( deathDist );
	while( 1 )
	{
		aiDist = Distance2DSquared( self.origin, target.origin );
		
		if( aiDist <= deathDist )
			self kill();
		
		wait( .1 );
	}
}

beach_sequence_bunker()
{
	flag_wait( "FLAG_start_bunker" );
	
	waittill_trigger( "player_inside_bunker" );
	
	spawners = getentarray( "bunker_trench_drones", "script_noteworthy" );
	foreach( spawner in spawners )
	{
		if( spawner parameters_check( "respawner" ) )
			spawner thread bunker_trench_drones();
		else
			spawner spawn_ai();
	}
	
	thread bunker_beach_defend_sequence();
	//thread beach_bunker_drones();
	//thread beach_ship_phalanx_system();
	thread bunker_trench_drone_runners();
	thread beach_battlehinds_start();

}

beach_a10_strafe_test()
{
	while( 1 )
	{
		spawners = getentarray( "beach_strafe_a10s", "targetname" );
		foreach( spawner in spawners )
		{
			a10 = spawner spawn_vehicle_and_gopath();
			a10 waittill( "reached_end_node" );
			a10 delete();
		}
	}
}

bunker_beach_defend_sequence()
{
	thread add_dialogue_line( "Hesh", "Up the stairs! MOVE MOVE!" );
	
	array_spawn( getentarray( "bunker_landers_group1", "script_noteworthy" ) );
	
	array_thread( getnodearray( "beach_front_nodes", "targetname" ), ::beach_front_nodes_think );
	waittill_trigger( "player_top_bunker_trig" );
	
	thread add_dialogue_line( "Hesh", "Adam get on that minigun!" );
	delayThread( 1.5, ::add_dialogue_line, "Hesh", "Adam target the advancing enemies in the back!" );

	flag_wait( "NODEFLAG_first_hovercraft_arrived" );
	
	thread add_dialogue_line( "Hesh", "Get ready! Enemy hovercraft lowering it's ramp!" );
	
	wait( 3 );
	
	thread add_dialogue_line( "Hesh", "Adam! Mow them DOWN!" );
	
	flag_wait( "NODEFLAG_wave1_final_hovercraft_goal" );

	array_spawn( getentarray( "bunker_landers_group2", "script_noteworthy" ) );
	
	wait( 20 );
	
	// Kill things over time for silence
	level.bunker_beach_vehicles = array_removeDead( level.bunker_beach_vehicles );
	level.bunker_beach_ai = array_removeDead_or_dying( level.bunker_beach_ai );
	
	array = array_combine( level.bunker_beach_ai, level.bunker_beach_vehicles );
	
	foreach( thing in array )
	{
		if( thing isVehicle() )
			thing notify( "death" );
		
		thing delaythread( randomfloatrange( 1, 5 ), ::die );
	}
	
	wait( 10 );
	
	thread add_dialogue_line( "Marine", "Targets? Anyone see have any targets?" );
	
	wait( 2 );
	
	flag_set( "FLAG_start_artillery_sequence" );	
}

bunker_beach_defend_wave2_sequence()
{
	flag_wait( "FLAG_artillery_sequence_done" );	
	
	//thread beach_flyover_helis();
	
	/*-----------------------
	CLEANUP REMAINING VEHICLES FROM THE LAST WAVE
	-------------------------*/	
	foreach( hovercraft in level.hovercrafts )
		hovercraft hovercraft_cleanup();
	array_delete( level.beachHinds );
	level notify( "stop_beach_hinds" );
	
	array_spawn( getentarray( "bunker_landers_wave2", "script_noteworthy" ) );
	array_spawn( getentarray( "hovercraft_wave_2", "script_noteworthy" ) );

	wait( 12 );
	
	spawn_vehicles_from_targetname_and_drive( "beach_strafe_a10s" );
	
	wait( 3 );
	
	bunker_hesh_exit();
	
	flag_set( "FLAG_start_trenches" );
}

bunker_beach_artillery_sequence()
{		
	flag_wait( "FLAG_start_artillery_sequence" );
	
	// artillery hit events
	//thread artillery_lynx_blowup();
	thread artillery_shack_blowup();
	thread artillery_bunker_mg_blowup();
	thread artillery_bunker_roof_blowup();
	
	vehicles = spawn_vehicles_from_targetname_and_drive( "wave2_preartillery_vehicles" );
	
	wait( 1.5 );
	
	thread add_dialogue_line( "Marine", "Here comes the next wave! Get ready!" );
	
	wait( 3.5 );
	
	structs = getstructarray( "bunker_artillery_fire_sequence", "targetname" );
	array_thread( structs, ::fire_artillery );
	
	wait( 1 );
	
	thread add_dialogue_line( "Marine", "INCOMING!" );
	wait( 1 );
	thread add_dialogue_line( "Hesh", "ENEMY RAIL GUN FIRE!" );
	
	while( 1 )
	{
		artilleryDone = 0;
		
		foreach( struct in structs )
		{
			if( isdefined( struct.artilleryDone ) )
				artilleryDone++;
		}
		
		if( artilleryDone == structs.size )
			break;
		
		wait( .1 );
	}
	
	array_delete( vehicles );
}

fire_artillery()
{
	startStruct = self;
	currentStruct = startStruct;
	
	while( isdefined( currentStruct ) )
	{
		//assert( isdefined( sortedStructs[i] ) );
		if ( IsDefined( currentStruct.script_delay ) )
			currentStruct script_delay();
		else
			wait( .05 );
		
		thread fire_artillery_shell( currentStruct );
		
		if( isdefined( currentStruct.script_linkto ) )
			currentStruct = getstruct( currentStruct.script_linkto, "script_linkname" );
		else
			currentStruct = undefined;
	}
	
	startStruct.artilleryDone = true;
	
}

fire_artillery_shell( struct )
{	
	target = getstruct( struct.target, "targetname" );
	assertEX( isdefined( target ), "TARGET IS NOT DEFINED" );
	
	playfx( getfx( "battleship_artillery_flash" ), struct.origin, anglestoforward( ( 0,0,0 ) ) );
	delayThread( .5, ::play_sound_in_space, "artillery_fire_distant", struct.origin );
	
	wait( 2 );
	
	moveTime = .9; // 1.1
	shell = create_artillery_shell( struct );
	shell moveto( target.origin, moveTime, .7, 0 );
	shell rotateto( target.angles, moveTime );
	
	wakeTarget = ( target.origin[0], target.origin[1], shell.wake.origin[2] );
	shell.wake moveto( wakeTarget, moveTime, .7, 0 );
	
	thread artillery_shell_wake_watcher( shell );
	
	thread play_sound_in_space( "artillery_incoming", target.origin );
	shell thread playLoopingFX( "artillery_trail_2" );
	
	shell waittill( "movedone" );
	
	if( isdefined( target.script_flag_set ) )
		flag_set( target.script_flag_set );
	
	thread play_sound_in_space( "artillery_explosion", target.origin );
	
	if( !target parameters_check( "no_explosion" ) )
	{
		Earthquake( randomfloatrange( .4, .6 ), 2, target.origin, 10000 );
		playfx( getfx( "artillery_explosion" ), target.origin );
		
		thread shell_screen_effects( shell );
	}
	
	shell delete();
}

SHELL_MAX_DISTANCE = 1000;
SHELL_FADETIME = .25;
SHELL_RESTORETIME = .4;
shell_screen_effects( shell )
{
	if( flag( "artillery_roof_blowup" ) )
		return;
	
	level.player notify( "shell_screen_effect" );
	level.player endon( "shell_screen_effect" );
	
	if( !isdefined( level.player.shellScreenEffect ) )
	{
		level.player.shellScreenEffect = maps\_hud_util::create_client_overlay( "black", 0, level.player );
		level.player.lastShellEffectTime = 0;
	}
	
	shellOrigin = shell.origin;
	playRumbleOnPosition( "artillery_rumble", shellOrigin );
	
	pDistance = distance_2d_squared( level.player.origin, shellOrigin );
	if( pDistance > squared( SHELL_MAX_DISTANCE ) )
		return;
	
	if( level.player.health > 50 )
		level.player dodamage( 100, level.player.origin );
	
	level.player ShellShock( "homecoming_bunker", SHELL_RESTORETIME );
	level.player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
	
	level.player.lastShellEffectTime = gettime();
	fadeTime = SHELL_FADETIME;
	
	thread set_blur( randomintrange( 3,5 ), SHELL_FADETIME );
	level.player.shellScreenEffect thread maps\_hud_util::fade_over_time( .1, SHELL_FADETIME );
	wait( SHELL_FADETIME );
	thread set_blur( 0, SHELL_FADETIME );
	level.player.shellScreenEffect thread  maps\_hud_util::fade_over_time( 0, SHELL_RESTORETIME );
												 
}

create_artillery_shell( spot )
{
	shell = spawn( "script_model", spot.origin );
	shell.angles = ( 0, 0, 0 );
	shell setmodel( "tag_origin" );
	
	shell.wake = spawn( "script_model", shell.origin - ( 0,0,790 ) );
	shell.wake.angles = ( 0, 0, 0 );
	shell.wake setmodel( "tag_origin" );

	playfxontag( getfx( "artillery_tracer" ), shell, "tag_origin" );
	playfxontag( getfx( "artillery_trail" ), shell, "tag_origin" );
	playfxontag( getfx( "artillery_mist" ), shell.wake, "tag_origin" );
	
	return shell;
}

artillery_shell_wake_watcher( shell )
{
	while( isdefined( shell ) )
	{
		if( shell.origin[0] > -7000 )
			break;
		wait( .05 );
	}

	shell.wake delete();
}

artillery_lynx_blowup()
{
	flag_wait( "artillery_humvee_blowup" );
	
	humvee = spawn_vehicle_from_targetname( "bunker_artillery_humvee" );
	dummy = spawn( "script_model", humvee.origin );
	dummy.angles = humvee.angles;
	dummy setmodel( "vehicle_gaz_tigr_harbor_destroyed" );
	dummy thread playLoopingFX( "artillery_humvee_smoke_trail" );
	
	PlayFX( getfx( "artillery_humvee_explosion" ), humvee.origin );
	humvee delete();

	currentspot = getstruct( "humvee_blowup_start", "targetname" );

	time = .3;
	while( isdefined( currentspot ) )
	{
		dummy moveto( currentspot.origin, time );
		dummy rotateto( currentspot.angles, time );
		
		wait( time );
		
		
		if( isdefined( currentspot.target ) )
			currentspot = getstruct( currentspot.target, "targetname" );
		else
			currentspot = undefined;

	}
	
	dummy delete();
}

artillery_shack_blowup()
{
	flag_wait( "artillery_shack_blowup" );
	
	origin = ( -5024, 4848, 180 );
	playfx( getfx( "artillery_shack_blowup" ), origin );
}

artillery_bunker_mg_blowup()
{
	turret = getent( "bunker_turret", "targetname" );
	nonBroken = getent( "bunker_mg_nonbroken", "targetname" );
	broken = getent( "bunker_mg_broken", "targetname" );
	
	flag_wait( "artillery_mg_blowup" );
	
	vec = anglestoforward( turret.angles ) * -1;
	playfx( getfx( "artillery_mg_blowup" ), turret.origin, vec );
	
	nonBroken delete();
	broken show();
	turret notify( "stopfiring" );
	turret delete();
}

artillery_bunker_roof_blowup()
{
	nonBroken = getent( "bunker_roof_nonbroken", "targetname" );
	broken = getent( "bunker_roof_broken", "targetname" );
	
	broken show();
	nonBroken delete();
	
	structs = getstructarray( "bunker_heroes_stumble_1", "targetname" );
	heshSpot = undefined;
	dogSpot = undefined;
	playerSPot = undefined;
	foreach( struct in structs )
	{
		if( !isdefined( struct.script_noteworthy ) )
		{
			heshSpot = struct;
			continue;
		}
		
		if( struct.script_noteworthy == "dog" )
			dogSpot = struct;
		else if( struct.script_noteworthy == "player" )
			playerSpot = struct;
	}
	
	flag_wait( "artillery_roof_blowup" );
	
	level.player.shellScreenEffect maps\_hud_util::fade_over_time( 1, 0 );
	teleport_player( playerSpot );
	array_call( getCorpseArray(), ::delete );
	cinematicmode_on();
	wait( 2 );
	cinematicmode_off();
	//level.player ShellShock( "homecoming_bunker", 7 );
	level.player player_speed_percent( 10, .05 );
	level.player.shellScreenEffect thread maps\_hud_util::fade_over_time( 0, 3 );
	level.player thread player_speed_percent( 100, 7 );
	
	//SetTimeScale( 0.7 );
	dogSpot thread anim_first_frame_solo( level.dog, "bunker_stumble" );
	heshSpot thread anim_single_solo( level.hesh, "bunker_stumble" );
	level.hesh delaycall( 2, ::stopanimscripted );
	dogSpot delaythread( 1, ::anim_single_solo, level.dog, "bunker_stumble" );
	
	level.heroes move_to_goal( "movespot_bunker" );
	
	//heshSpot waittill( "bunker_stumble" );
	wait( 2 );
	
	//SetTimeScale( 1 );
	
	flag_set( "FLAG_artillery_sequence_done" );
}

bunker_javelin_guy()
{
	originalWep = self.primaryweapon;
	self attach( "weapon_javelin", "tag_inhand" );
	self thread magic_bullet_shield( true );
	self.ignoreall = true;
	self.ignoreme = true;
	self disable_pain();
	fireNode = getnode( self.target, "targetname" );

	fireNode thread anim_generic( self, "javelin_idle" );
	
	waittill_trigger( "player_inside_bunker" );
	
	tank = spawn_vehicle_from_targetname_and_drive( "bunker_javelin_tank" );
	tank thread vehicle_fire_at_targets( tank get_linked_structs(), 1, 1, 2 );
	
	fireNode thread anim_generic( self, "javelin_fire" );
	wait( .6 );
	newMissile = MagicBullet( "javelin_dcburn", self gettagorigin( "tag_inhand" ), tank.origin );
	playfxontag( getfx( "javelin_muzzle" ), self, "TAG_FLASH" );
	newMissile Missile_SetTargetEnt( tank );
	newMissile Missile_SetFlightmodeTop();
	
	wait( 2 );
	
	self detach( "weapon_javelin", "tag_inhand" );
	fakeJavelin = spawn( "script_model", self gettagorigin( "tag_inhand" ) );
	fakeJavelin.angles = self gettagangles( "tag_inhand" );
	fakeJavelin setmodel( "weapon_javelin" );
	
	self stopanimscripted();
	
	self enable_pain();
	self.ignoreall = false;
	self.ignoreme = false;
	self forceuseweapon( originalWep, "primary" );	
	
	self setgoalnode( getnode( fireNode.script_linkto, "script_linkname" ) );
}

#using_animtree( "generic_human" );
bunker_mg_guy()
{
	self magic_bullet_shield();
	self.ignorerandombulletdamage = true;
	self.deathAnim = %stand_death_headshot_slowfall;
	
	turret = getent( "bunker_turret", "targetname" );
	self maps\_spawner::use_a_turret( turret );
	
	waittill_trigger( "player_top_bunker_trig" );
	
	wait( randomfloatrange( 0, .2 ) );
	
	vec = AnglesToForward( self GetTagAngles( "j_head" ) );
	playfx( getfx( "headshot_blood" ), self gettagorigin( "j_head" ), vec * -1 );
	
	self stop_magic_bullet_shield();
	self notify( "stop_using_built_in_burst_fire" );
	self die();
}

#using_animtree( "vehicles" );
bunker_reinforcement_helis()
{
	thread bunker_vehicle_javelin_watcher( self );
	thread javelin_target_set( self, ( 0,0,-100 ) );
	self thread vehicle_allow_player_death();
	self.perferred_crash_location = get_helicopter_crash_location( "beach_heli_crash_loc" );
	
	thread func_waittill_msg( self, "rocket_death", ::heli_enable_rocketDeath );
}

bunker_hesh_exit()
{
	trigger_on( "player_leaving_bunker_trig", "targetname" );
		
	node = getstruct( "bunker_exit_left_door_node", "targetname" );
	door = getent( node.target, "targetname" );
	
	node anim_reach_solo( level.hesh, "bunker_leave" );
	node thread anim_single_solo( level.hesh, "bunker_leave" );
	level.hesh delaycall( 1.5, ::stopanimscripted );
	
	level.hesh set_force_color( "r" );
	level.dog SetDogHandler( level.hesh );
	level.dog setgoalentity( level.hesh );
	level.dog SetDogAttackRadius( 56 );
	
	wait( .6 );
	door rotateto( door.angles + ( 0,95,0 ), .5, 0, .2 );
	door connectpaths();
	
	thread heroes_move( "movespot_leaving_bunker" );
	
	flag_wait( "TRIGFLAG_player_leaving_bunker" );
}

DIST_FROM_NODE_CHECK = 350;
beach_front_nodes_think()
{
	node = self;
	
	distCheck = squared( DIST_FROM_NODE_CHECK );
	
	while( 1 )
	{
		if( isdefined( node.currentOwner ) )
		{
			node.currentOwner waittill( "death" );
			node.currentOwner = undefined;
		}
		
		// get a new owner
		while( 1 )
		{
			level.beachFrontGuys = array_removeDead_or_dying( level.beachFrontGuys );
			array = SortByDistance( level.beachFrontGuys, node.origin );
			
			guy = undefined;
			foreach( ai in array )
			{			
				
				if( isdefined( ai.hasNode ) )
					continue;
				
				if( postion_dot_check( node, ai ) == "infront" )
					continue;
				
				if( Distance2Dsquared( node.origin, ai.origin ) <= distCheck )
				{
				   	zCheck = ai.origin[2] - node.origin[2];
					if( zCheck > 80 )
					{
						iprintlnbold( "hi" );
						continue;
					}
					guy = ai;
					break;
				}
			}
			
			if( isdefined( guy ) && isalive( guy ) )
			{
				guy setgoalnode( node );
				guy thread goal_radius_constant( 16 );
				guy notify( "setting_new_goal" );
				node.currentOwner = guy;
				guy.hasNode = true;
				break;
			}
			
			wait( .1 );
		}
	}
}

bunker_vehicle_javelin_watcher( vehicle )
{
	vehicle endon( "unload_complete" );
	vehicle endon( "death" );
	
	while( 1 )
	{
		level.player waittill ( "missile_fire", missile, weaponName );	
		if( weaponName == "javelin_dcburn" && level.javelinLockFinalized == true )
		{
			target = level.javelinTarget;
			if( vehicle == target )
			{
				wait( 2.5 );
				vehicle ent_flag_set( "unload_interrupted" );
				return;	
			}
		}
	}
	
}

beach_hovercraft_tanks_default()
{
	//self.health = 5000;
	self.fireTime = [ 2.5, 5 ];
	self thread vehicle_path_notifications();
	self thread vehicle_allow_player_death();
	self ent_flag_wait( "hovercraft_unload_complete" );
	thread javelin_target_set( self, ( 0,0,80 ) );
	
	if( !isdefined( level.hovercraftTanks ) )
		level.hovercraftTanks = [];
	level.hovercraftTanks[ level.hovercraftTanks.size ] = self;
	
	level.bunker_beach_vehicles[ level.bunker_beach_vehicles.size ] = self;
}

beach_vehicle_default()
{
	self thread vehicle_allow_player_death();
	thread javelin_target_set( self, ( 0,0,80 ) );
	self thread vehicle_path_notifications();
}

// Beach Defend Helicopter Managing
beach_battlehinds_start()
{
	level.beachHinds = [];
	
	hinds = spawn_vehicles_from_targetname_and_drive( "beach_starting_hinds" );
	foreach( hind in hinds )
	{
		if( isdefined( hind.script_linkto ) )
			hind thread beach_battlehinds_manager();
	}
}

beach_battlehinds_manager()
{
	level waittill( "stop_beach_hinds" );
	
	hind = self;
	vRespawners = hind get_linked_ents();
	
	while( 1 )
	{
		hind thread beach_battlehind_default();
		
		hind waittill( "death" );
		
		wait( randomintrange( 1, 3 ) );
		
		vSpawner = vRespawners[ randomint( vRespawners.size ) ];
		hind = vSpawner spawn_vehicle_and_gopath();
	}
}

beach_battlehind_default()
{
	level.beachHinds[ level.beachHinds.size ] = self;
	
	thread javelin_target_set( self, ( 0,0,-100 ) );
	self thread vehicle_path_notifications();
	self thread vehicle_allow_player_death();
	self thread heli_missile_defense_init();
	
	self.enableRocketDeath = true;
	self.alwaysRocketDeath = true;
	
	self waittill( "death" );
	
	level.beachHinds = array_remove( level.beachHinds, self );
}

#using_animtree( "generic_human" );

beach_bunker_drones()
{
	dSpawners = getentarray( "bunker_beach_drones", "targetname" );
	foreach( spawner in dSpawners )
	{
		drone = spawner spawn_ai();
		drone.drone_idle_custom = true;
		drone.drone_idle_override = ::drone_fight_smart;
		drone thread waittill_death_respawn( spawner, 1.2, 2.4 );
	}
}

#using_animtree( "generic_human" );
// Drones that are in the trench and refill when they die
bunker_trench_drones()
{
	level endon( "FLAG_stop_trench_drones" );

	//respawner = getent( self.script_linkto, "script_linkname" );
	respawner = self;
	while( 1 )
	{
		granted = drones_request( 1 );
		if( !granted )
		{
			wait( .05 );
			continue;
		}

		drone = respawner spawn_ai();
		
		wait( randomintrange( 15, 25 ) );
		
		// drone_fight resets drone .deathAnim, making sure this is set after fight starts 
		array = [ %stand_death_tumbleback, %stand_death_headshot_slowfall, %stand_death_shoulderback ];
		drone.deathAnim = array[ randomint( array.size ) ];
		
		drone DoDamage( drone.health + 10, drone.origin );
		wait( randomintrange( 4, 8 ) );
	}
}

// Drones that run from the houses down to the trench
bunker_trench_drone_runners()
{
	spawners = getentarray( "bunker_trench_runners", "targetname" );
	runAnims = [ "run" ];
	weaponSounds = [ "drone_m16_fire_npc", "drone_m4carbine_fire_npc" ];
	spawnTime = [ 3.2, 5 ];
	
	spawners thread drone_infinite_runners( "FLAG_stop_trench_drones", spawnTime, runAnims, weaponSounds );
	
}

bunker_javelin_drones()
{	
	spawner = self.spawner;
	if( isdefined( spawner.script_linkTo ) )
		self.javTargets = getentarray( spawner.script_linkTo, "script_linkname" );
	self.javelin_smartTargeting = true;
	self.drone_idle_custom = true;
	self.drone_idle_override = ::drone_fire_fake_javelin_loop;
	self thread magic_bullet_shield();
	
}

beach_enemy_default( volume )
{
	if( !isdefined( self ) )
		return;
	
	self.health = 200;
	//self enable_sprint();
	self.IgnoreRandomBulletDamage = true;
	self.disableBulletWhizbyReaction = true;
	self.ignoresuppression = true;
	self.noRunNGun = true;
	self.a.disableLongDeath = true;	
	self.goalradius = 56;
	self set_baseaccuracy( .5 );
	
	level.bunker_beach_ai[ level.bunker_beach_ai.size ] = self;
	
}

raining_missiles_test()
{
	fadein = maps\_hud_util::create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_inside_bunker" );
	fadein thread maps\_hud_util::fade_over_time( 0, 1 );
	
	wait( 2 );
	
	missiles = spawn_vehicles_from_targetname_and_drive( "raining_missile_test" );
	
	foreach( missile in missiles )
	{
		if( !isdefined( missile.script_noteworthy ) )
			continue;
		
		if( missile.script_noteworthy != "slomoer" )
			continue;
		
		missile waittill( "slowmo" );
		SetTimeScale( .2 );
		missile waittill( "reached_end_node" );
		SetTimeScale( 1 );
	}

}

// TRENCHES SEQUENCE
beach_sequence_trenches()
{
	flag_wait( "FLAG_start_trenches" );
	
	autosave_by_name( "trenches" );
	
	flag_set( "FLAG_stop_trench_drones" );
	
	SetSavedDvar( "ai_friendlysuppression", 1 );
	SetSavedDvar( "ai_friendlyfireblockduration", 1 );
	
	// Drone stuff in trenches from bunker sequence
	trenchDrones = getentarray( "bunker_trench_drones", "script_noteworthy" );
	foreach( drone in trenchDrones )
	{
		if( isdefined( drone ) )
			drone delete();
	}
	
	droneClip = getent( "bunker_trench_drone_clip", "targetname" );
	droneClip connectPaths();
	droneClip delete();
	
	level.dog set_moveplaybackrate( .75 );
	level.dog.meleeAlwaysWin = true;
	level.dog SetDogHandler( level.hesh );
	level.hesh.ignoreall = false;
	level.hesh.ignoreme = false;
	
	thread beach_trenches_combat();
	
}

beach_trenches_combat()
{
	/*-----------------------
	TRENCH THREADS
	-------------------------*/	
	thread trenches_combat_right_path();
	thread initial_trench_enemies();
	
	/*-----------------------
	TRENCH FRIENDLY TURRET
	-------------------------*/	
	turret = getent( "trench_friendly_turret", "script_noteworthy" );
	targets = getentarray( "trench_entrance_turret_targets", "targetname" );
	turret thread turret_shoot_targets( targets );
	
	/*-----------------------
	START TRENCH FRIENDLIES + HESH MOVEMENT
	-------------------------*/	
	level.hesh set_force_color( "r" );
	level.dog set_force_color( "b" );
	activate_trigger( "trench_start_friendlies", "targetname" );
	
	level endon( "TRIGFLAG_player_entering_nest" );
	
	waittill_trigger( "trench_start_combat" );

	/*-----------------------
	BRIDGE TRENCH DRONES
	-------------------------*/	
	runnerSpawner = getent( "trenches_bridge_runner", "targetname" );
	runnerSpawner.randomDeath = [ 7, 15 ]; // sets the min and max time for random death
	runnerSpawner.drone_lookAhead_value = 128;
	runnerSpawner add_spawn_function( ::set_noragdoll );
	runnerSpawner add_spawn_function( ::drone_bloodFX );
	//runnerSpawner add_spawn_function( ::drone_EnableAimAssist );
	runnerSpawner delaythread( 3, ::beach_path_drones );
	
	hovercraftRunners = getentarray( "trenches_hovercraft_runners", "targetname" );
	foreach( spawner in hovercraftRunners )
	{
		spawner.randomDeath = [ 5, 20 ]; // sets the min and max time for random death
		spawner.drone_lookAhead_value = 128;
		spawner thread beach_path_drones();
	}
		
	//maps\_spawner::flood_spawner_scripted( getentarray( "trench_nest_rpg_flooders", "targetname" ) );
	
	waittill_trigger( "trenches_street_trig" );
	
	maps\_spawner::flood_spawner_scripted( getentarray( "trench_enemies_1_flooders", "targetname" ) );
	
	waittill_trigger( "trench_chargers_1_trig" );
	
	chargerSpawners = getentarray( "trench_chargers_1", "targetname" );
	target = getstruct( chargerSpawners[0].target, "targetname" );
	thread trench_chargers( chargerSpawners, target, 1.8, 3.5 );
	//array_thread( getentarray( "trench_chargers_1", "targetname" ), ::trench_chargers );
	maps\_spawner::flood_spawner_scripted( getentarray( "trench_hescotower_lower_enemies", "targetname" ) );
	
	waittill_trigger( "trenches_entrance_trig" );
	
	maps\_spawner::flood_spawner_scripted( getentarray( "trench_enemy_flooders_2", "targetname" ) );
	
	/*-----------------------
	BEACH PERPENDICULAR DRONES
	-------------------------*/	
	beachRunners = getentarray( "trenches_beach_runners", "targetname" );
	foreach( spawner in beachRunners )
	{
		spawner.randomDeath = [ 4, 9 ];
		spawner.drone_lookAhead_value = 256;
		spawner thread beach_path_drones();
	}
	
	waittill_trigger( "trenches_moveup_trig1" );
	
	/*-----------------------
	TRENCH FRIENDLY TURRET SHOOT AT HOVERCRAFT DROENES
	-------------------------*/	
	targets = getentarray( "trench_hovercraft_turret_targets", "targetname" );
	turret thread turret_shoot_targets( targets );
	
	activate_trigger( "trench_moveup_watcher_namer", "script_noteworthy" ); // starts next move up watcher
	runnerSpawner notify( "stop_drone_runners" ); // stop bridge drone runners
	
	waittill_trigger( "trenches_rightpath_start_check" );
	
	/*-----------------------
	RIGHT PATH START IF PLAYER SKIPPED
	-------------------------*/	
	trigger = getent( "trenches_rightpath_trig", "targetname" );
	if( isdefined( trigger ) )
	{
		trigger notify( "trigger" );
		activate_trigger( "trenches_rightpath_moveup_watcher", "script_noteworthy" );
	}
	waittill_trigger( "trenches_moveup_trig3" );
	
	maps\_spawner::flood_spawner_scripted( getentarray( "trench_flooders_tank", "targetname" ) );
}

beach_trenches_combat_part2()
{
	//spawn_vehicle_from_targetname_and_drive( "tower_mig" );
	
	/*-----------------------
	START TRENCHES PART2
	-------------------------*/	
	flag_wait( "TRIGFLAG_start_trenches_part2" );
	
	//thread maps\homecoming_a10::a10_strafe_mechanic( "tower_player_a10_strafe_1" );
	
	/*-----------------------
	GREEN SMOKE ON TOWER
	-------------------------*/	
	smokeSpot = getstruct( "tower_green_smoke_spot", "targetname" );
	smokeSpotEnt = spawn_tag_origin();
	smokeSpotEnt.origin = smokeSpot.origin;
	smokeSpotEnt.angles = smokeSpot.angles;
	playfxontag( getfx( "tower_green_smoke" ), smokeSpotEnt, "tag_origin" );
	
	waittill_trigger( "start_tower_entrance_battle" );
	
	delaythread( 2,  ::add_dialogue_line, "Hesh", "Enemy hind targeting our position!" );
	delaythread( 5, ::notify_trigger, "trenches_moveup_trig5" );
	
	flag_wait( "FLAG_tower_hind_destroyed" );
	
	notify_trigger( getent( "trenches_moveup_trig6", "script_noteworthy" ) );
	
	array_spawn( getentarray("tower_entrance_garage_guys", "targetname" ) );

	door = getent( "trench_tower_garage_entrance", "targetname" );
	door connectPaths();
	door delete();
	
	flag_wait( "TRIGFLAG_player_entering_tower" );
	flag_set( "FLAG_start_tower_retreat" );

}

trenches_combat_right_path()
{
	flag_wait( "TRIGFLAG_player_entering_nest" );
	
	// need to move up the friendlies significantly so that they can catch up with player
	notify_trigger( "trenches_moveup_trig3" );
	
	maps\_spawner::flood_spawner_scripted( getentarray( "trenches_shack_flooder", "targetname" ) );
	
	// just in case the player backtracks
	add_wait( ::waittill_trigger, "trenches_moveup_trig3" );
	do_wait_any();
	//heroes_move( "trenches_5_paths" );
}

trench_friendly_orange_guy()
{
	self thread magic_bullet_shield();
	waittill_trigger( "trenches_entrance_trig" );
	self set_force_color( "g" );
	
	waittill_trigger( "trenches_moveup_trig1" );
	self set_force_color( "o" );
	
	waittill_trigger( "trenches_moveup_trig4" );
	self set_force_color( "g" );
}

trench_artemis()
{
	artemis = getent( "trench_artemis", "targetname" );
	defaultTarget = getstruct( artemis.script_linkto, "script_linkname" );
	artemis setturrettargetvec( defaultTarget.origin );
}

trench_chargers( spawners, target, minT, maxT )
{
	spawners = array_randomize( spawners );
	
	while( spawners.size > 0 )
	{
		foreach( spawner in spawners )
		{
			// If spawner gets deleted by script_killspawner
			if( !isdefined( spawner ) )
			{
				spawners = array_remove( spawners, spawner );
				continue;
			}
			
			ai = spawner spawn_ai();
			ai thread trench_chargers_think( target );
			
			if( spawner.count == 0 )
				spawners = array_remove( spawners, spawner );		
			
			wait( randomfloatrange( minT, maxT ) );
		}
	}
}

trench_chargers_think( target )
{
	self endon( "death" );
	
	self.grenadeawareness = 0;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	self.ignorerandombulletdamage = true;
	//self.ignoreall = true;
	self setgoalpos( target.origin );
	self.goalradius = target.radius;
	self waittill( "goal" );
	wait( randomfloatrange( .2, .8 ) );
	self die();
}

trench_balcony_ai()
{
	self endon( "death" );
	
	self thread magic_bullet_shield();
	
	if( !isdefined( self.script_linkTo ) )
		return;
	
	target = getent( self.script_linkTo, "script_linkname" );
	
	self setentitytarget( target );
	
}

tower_rappel_nh90()
{
	towerDoor = getent( "tower_midlevel_door", "targetname" );
	towerDoor hide();
	towerDoor connectPaths();
	
	node = getnode( "tower_rappelers_node", "targetname" );
	
	riders = self.riders;
	self waittill( "unloaded" );
	
	foreach( rider in riders )
	{
		// ignore pilots
		if( isdefined( rider.script_startingposition ) )
		{
			riders = array_remove( riders, rider );
			continue;
		}
		
		rider thread waittill_real_goal( node, true );
	}
	
	while( 1 )
	{
		riders = array_removeDead_or_dying( riders );
		if( riders.size == 0 )
			break;
		wait( 1 );
	}
	
	towerDoor show();
	towerDoor disconnectPaths();
}

initial_trench_enemies()
{
	array_spawn( getentarray( "initial_trench_enemies", "targetname" ) );
	
	spawners = getentarray( "initial_trench_flooders", "targetname" );
	maps\_spawner::flood_spawner_scripted( spawners );
	
	waittill_trigger( "trench_start_combat" );
	
	foreach( spawner in spawners )
	{
		if( !isdefined( spawner.script_index ) )
		{
			spawner.count = 0;
			continue;
		}
		
		spawner.count = spawner.script_index;
	}
}

trench_enemy_nest_ai()
{
	self endon( "death" );
	
	spawner = self.spawner;
	self.ignoreme = true;
	self.a.disableLongDeath = true;
	
	self thread enemy_rpg_unlimited_ammo( "stop_rpg_ammo" );
	
	targets = spawner get_linked_ents();
	while( !flag( "TRIGFLAG_player_entering_nest" ) )
	{	
		if( self.weapon != "rpg" )
			 self forceUseWeapon( "rpg" , "primary" );
		
		target = targets[ randomint( targets.size ) ];
		self setEntityTarget( target );
		
		self add_wait( ::waittill_msg, "shooting" );
		add_wait( ::flag_wait, "TRIGFLAG_player_entering_nest" );
		do_wait_any();
		
		if( flag( "TRIGFLAG_player_entering_nest" ) )
			break;
	}
	
	self notify( "stop_rpg_ammo" );
	self.a.rockets = 0;
	self.ignoreme = false;
	self ClearEntityTarget();
	
	//self forceUseWeapon( "ak47" , "primary" );

}

trench_hovercraft_drones()
{
	self.droneSmoke = self get_linked_structs();
	self thread hovercraft_deploy_smoke();
	
}

trench_hovercraft_a10()
{
	self.deflateRate = 1.5;
	self.delayTankUnload = true;
	
	while( !isdefined( self.tanks ) )
		wait( .05 );
	
	tank = self.tanks[0];
	tank.turretTurnTime = 2;
	tank.fireTime = [ 3.5, 6 ];
	tank.mgturret[1] TurretFireDisable(); 
	tank.riders[0] thread magic_bullet_shield();
	
	tank thread vehicle_allow_player_death();
	tank thread maps\_vehicle_code::damage_hint_bullet_only();
	
	self waittill( "hovercraft_smoke_deployed" );
	
	//delaythread( 3, ::array_spawn, getentarray( "trench_hovecraft_ai", "targetname" ) );
	//delaythread( 2, ::spawn_vehicle_from_targetname_and_drive, "trench_hovercraft_a10" );
	
	tank ent_flag_wait( "hovercraft_unload_complete" );
	
	if( !isdefined( tank.riders[0] ) )
		return;
	
	rider = tank.riders[0];
	rider thread stop_magic_bullet_shield();
	
	tank.mgturret[1] setmode( "manual_ai" );
	tank.mgturret[1] TurretFireEnable(); 
	target = getent( "trench_buildings_target", "targetname" );
	tank.mgturret[1] settargetentity( target );
	
	tank waittill( "reached_end_node" );
	

	target = spawn( "script_origin", level.player geteye() );
	
	while( isdefined( rider ) && isalive( rider ) )
	{
		tank.mgturret[1] settargetentity( target );
		point = return_point_in_circle( level.player geteye(), 64 );
		target.origin = point;
		wait( .2 );
	}
	
	target delete();
}

trench_shack_ai()
{
	self endon( "death" );
	target = getent( "trench_buildings_target", "targetname" );
	self SetEntityTarget( target );
}

trench_bridge_ai()
{
	self endon( "death" );
	
	spawner = self.spawner;
	self.ignoreme = true;
	
	target = getent( "trench_buildings_target", "targetname" );
	self SetEntityTarget( target );
	
	goal = getnode( spawner.target, "targetname" );
	self waittill_true_goal( goal.origin, goal.radius );
	self die();
}

trench_hovercraft()
{
	fxSpot = spawn( "script_model", self.origin );
	fxSpot setmodel( "tag_origin" );
	fxSpot.origin = ( self.origin[0], self.origin[1], -120 );
	fxSpot linkto( self );
	//PlayFXOnTag( getfx( "trench_hovercraft_kickup" ), fxSpot, "tag_origin" );
	fxSpot thread playloopingfx(  "trench_hovercraft_kickup", .05 );
	
	self waittill( "stopfx" );
	
	fxSpot notify( "stop_looping_fx" );
	fxSpot delete();
}

trench_tower_hind()
{
	hind = self;
	
	hind thread trench_tower_hind_targetEnt();
	hind thread vehicle_allow_player_death();
	hind thread maps\_vehicle_code::damage_hint_bullet_only();	
	
	hind thread vehicle_path_notifications();
	
	hind waittill( "reached_dynamic_path_end" );
	
	//play_loopsound_in_space( "minigun_heli_gatling_spinloop", level.player.origin );
	
	hind.script_burst_min = 9;
	hind.script_burst_max = 21;
	hind.fireWait = .15;
	
	hind thread tower_hind_targetPlayer();
	hind thread trench_tower_hind_pathlogic();
	
	hind waittill( "death" );
	
	flag_set( "FLAG_tower_hind_destroyed" );
	
}

trench_tower_hind_targetEnt()
{
	targetEnt = spawn( "script_origin", self.origin );
	targetEnt linkto( self, "tag_origin", ( 0,0,-125 ), ( 0,0,0 ) );
	target_set( targetEnt, ( 0,0,0 ) );
	Target_HideFromPlayer( targetEnt, level.player );
	self waittill( "death" );
	targetEnt delete();
}

trench_tower_hind_pathlogic()
{
	self endon( "death" );
	
	// back, front, left, right
	paths = getstructarray( "tower_hind_dynamic_paths", "targetname" );
	triggers = getentarray( "tower_hind_trigs", "targetname" );
	
	pathGroups = [];
	pathTrigs = [];
	foreach( index, path in paths )
	{
		assert( isdefined( path.script_noteworthy ) );
		pathLinks = path get_linked_structs();
		pathGroup = [];
		pathGroup[ 0 ] = path;
		pathGroup = array_combine( pathGroup, pathLinks );
		pathGroups[ path.script_noteworthy ] = pathGroup;
		
		assert( isdefined( triggers[ index ].script_noteworthy ) );
		pathTrigs[ triggers[ index ].script_noteworthy ] = triggers[ index ];
	}
	
	defaultPath = "back";
	setDefault = undefined;
	while( 1 )
	{
		
		currentTrig = undefined;
		foreach( trig in pathTrigs )
		{
			if( level.player istouching( trig ) )
			{
				currentTrig = trig;
				break;
			}
		}
		
		if( !isdefined( currentTrig ) )
		{
			setDefault = true;
			currentTrig = pathTrigs[ defaultPath ];
		}
		else if( isdefined( setDefault ) )
			setDefault = undefined;
		
		noteworthy = currentTrig.script_noteworthy;
		self thread trench_tower_hind_gopath( pathGroups[ noteworthy ], noteworthy );
		
		if( isdefined( setDefault ) )
		{
			// Player must touch the back trigger before he can touch any other
			while( !level.player istouching( currentTrig ) )
				wait( .1 );
		}
		
		for( ;; )
		{
			while( level.player istouching( currentTrig ) )
				wait( .1 );
			
			// Give time to see if player is actually moving to another area
			// He could just be at the edge of two triggers
			wait( 1.5 );
			
			if( !level.player istouching( currentTrig ) )
				break;
		}
	}
}

trench_tower_hind_gopath( pathGroup, noteworthy )
{
	self endon( "death" );
	
	self notify( "new_tower_path" );
	self endon( "new_tower_path" );
	
	currentNode = getClosest( self.origin, pathGroup );
	
	//iprintlnbold( "change path : " + noteworthy );
	self Vehicle_SetSpeed( 25, 25, 5 );
	self SetNearGoalNotifyDist( 64 );
	self SetLookAtEnt( level.player );;
	
	while( 1 )
	{
		pathChoices = array_remove( pathGroup, currentNode );
		currentNode = pathChoices[ randomint( pathChoices.size ) ];
		
//		self Vehicle_HeliSetAI( origin, speed, accel, decel, nextpoint.script_goalyaw, nextpoint.script_anglevehicle, yaw, airResistance, hasDelay, stopnode, unload, flag_wait, endOfPath );
		self Vehicle_HeliSetAI( currentNode.origin, undefined, undefined, undefined, currentNode.script_goalyaw, undefined, currentNode.angles[ 1 ], 0, 0, 0, 0, 0, 1 );
		self waittill ( "near_goal" );
		
		self Vehicle_SetSpeed( 15, 5, 5 );
		
		wait( randomfloat( 2 ) );
	
	}
	
}

tower_hind_targetPlayer()
{
	targetEnt = spawn( "script_origin", level.player.origin );
	self thread heli_fire_turret( targetEnt );
	
	while( 1 )
	{
		//wait( .4 );
		//targetEnt.origin = level.player.origin + ( 0,0,25 );
		spot = level.player.origin + ( 0,0,25 );
		point = return_point_in_circle( spot, 25 );
		targetEnt.origin = point;
		wait( .2 );
	}
}

//TOWER SEQUENCE

tower_sequence()
{
	flag_wait( "FLAG_start_tower_sequence" );
	waittill_trigger( getent( "tower_bottom_enemy_trig", "script_noteworthy" ) );
	thread bottom_tower_enemies();

	/*-----------------------
	HESH MOVE UP TOWER
	-------------------------*/	
	flag_wait( "FLAG_hesh_move_through_tower" );
	level.hesh enable_cqbwalk();
	thread heroes_move( "tower_top_path" );
	
	/*-----------------------
	SETUP TOWER TOP TOWER ENEMIES
	-------------------------*/	
	flag_wait( "TRIGFLAG_player_entering_top_tower" );
	towerEnemies = array_spawn( getentarray( "top_tower_enemies", "targetname" ) );
	array_thread( towerEnemies, ::top_tower_enemies );
	
	/*-----------------------
	BEGIN A10 MECHANIC
	-------------------------*/		
	flag_wait( "top_tower_enemies_dead" );
	thread maps\homecoming_a10::a10_strafe_mechanic( "bunker_player_a10_strafe_1" );
	
	/*-----------------------
	BEGIN FIGHT BELOW TOWER
	-------------------------*/	
	dogNode = getnode( "tower_entrance_dog_node", "targetname" );
	dogNode DisconnectNode();
	
	maps\_spawner::flood_spawner_scripted( getentarray( "tower_level2_marines", "targetname" ) );
	maps\_spawner::flood_spawner_scripted( getentarray( "tower_enemy_attackers", "targetname" ) );

	/*-----------------------
	HESH GOES OVER TO CONSOLE
	-------------------------*/	
	node = getnode( "tower_hesh_a10_node", "targetname" );
	node anim_reach_solo( level.hesh, "a10_console_interact" );
	node thread anim_loop_solo( level.hesh, "a10_console_interact" );
	
	flag_wait( "used_a10_strafe" );
	
	end_of_scripting();
}

bottom_tower_enemies()
{
	/*-----------------------
	AI STAY IN COVER UNTIL EITHER ONE IN ARRAY HAS DIED OR PLAYER HAS MOVED INTO TOWER
	-------------------------*/	
	spawners = getentarray( "tower_bottom_enemies", "targetname" );
	aiArray = array_spawn( spawners );
	
	spawnTime = gettime();
	
	while( !flag( "TRIGFLAG_player_entering_tower" ) && aiArray.size > 2 )
	{
		wait( .1 );
		aiArray = array_removeDead_or_dying( aiArray );
	}
	
	/*-----------------------
	MAKE SURE WE WAITED AT LEAST FIVE SECONDS FROM SPAWN BEFORE RETREAT
	-------------------------*/	
	while( gettime() - spawnTime < 5000 )
		wait( .1 );

	flag_set( "FLAG_hesh_move_through_tower" );
	
	nodes = getnodearray( "tower_top_runner_nodes", "targetname" );
	
	foreach( index, ai in aiArray )
	{
		wait( randomfloatrange( 0, .8 ) );
		
		if( !isdefined( ai ) || !isalive( ai ) )
			continue;
		
		ai.ignoreall = true;
		ai.goalradius = 56;
		ai setgoalnode( nodes[ index ] );
	}
	
	volume = getent( "tower_bottom_enemies_volume", "targetname" );
	
	while( aiArray.size > 0 )
	{
		wait( .1 );
		aiArray = array_removeDead_or_dying( aiArray );		
		
		foreach( ai in aiArray )
		{
			if( !ai istouching( volume ) )
				continue;
			
			if( level.player player_can_see_ai( ai ) )
				continue;
			
			ai delete();
		}
	}
	
}

top_tower_enemies()
{
	self endon( "death" );
	
	self.ignoreall = true;
	self.ignoreme = true;
	originalHP = self.health;
	self.health = 2;
	self disable_long_death();
	
	self thread waittill_stealth_notify();
	
	/*-----------------------
	WAITTILL PLAYER SHOOTS OR GETS TOO CLOSE
	-------------------------*/	
	add_wait( ::flag_wait, "TRIGFLAG_alert_tower_enemies" );
	level add_wait( ::waittill_msg, "stealth_event_notify" );
	do_wait_any();
	
	/*-----------------------
	REMAINING TOWER ENEMIES FIGHT PLAYER
	-------------------------*/	
	wait( randomfloatrange( .4, .8 ) );
	
	self stopanimscripted();
	self.animSpot notify( "stop_loop" );
	self notify( "stop_loop" );
	
	self notify( "stop_fake_behavior" );
	self.ignoreall = false;
	self.ignoreme = false;
	self.health = originalHP;
}

preacher_test()
{
	fadein = maps\_hud_util::create_client_overlay( "black", 1, level.player );
	alliesTeletoStartSpot( "start_preacher_test" );
	level.player takeAllweapons();
	level.player giveweapon( "javelin" );
	fadein thread maps\_hud_util::fade_over_time( 0, 1 );
	
	struct = getstruct( "preacher_jav_lockon", "targetname" );
	lockon = spawn( "script_model", struct.origin );
	lockon setmodel( "tag_origin" );
	thread javelin_target_set( lockon, ( 0,0,0 ) );
	
	hitSpots = getstructarray( "ship_phalanx_system", "targetname" );
	
	while( 1 )
	{
		level.player waittill( "missile_fire", missile );
		javelin_check_decent( missile );
		wait( 1.1 );
		start = missile.origin;
		missile delete();
		foreach( spot in hitSpots )
		{
			rpg = magicbullet( "rpg", start, spot.origin );
			rpg thread precacher_explosion(  spot );
		}
		
	}
	
}

precacher_explosion( spot )
{
	wait( randomfloatrange( 3.5, 4 ) );
	playfx( getfx( "battleship_explosion" ), spot.origin + ( 0,0, randomintrange( -200, -150 ) ) );
	if( isdefined( self ) )
		self delete();
}
