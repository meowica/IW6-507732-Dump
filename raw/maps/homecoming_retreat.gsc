#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\homecoming_util;
#include maps\homecoming_drones;

#using_animtree( "generic_human" );
retreat_spawn_functions()
{
	
	
	// TOWER RETREAT
	
	// ELIAS STREET
	
	// ELIAS HOUSE
	
	// VEHICLES
	
	getent( "tower_retreat_vista_tank", "targetname" ) add_spawn_function( ::tower_vista_retreat_tank );
	
	
}

tower_retreat_sequence()
{
	flag_wait( "FLAG_start_tower_retreat" );
	
	level.heroes thread heroes_move( "movespot_tower_retreat_1" );	
	
	waittill_trigger( "tower_mid_player_trig" );
	
	/*-----------------------
	DOOR KICK OUT OF TOWER
	-------------------------*/
	kickSpot = getstruct( "tower_door_kick_spot", "targetname" );
	kickSpot anim_reach_solo( level.hesh, "tower_leave" );
	kickSpot thread anim_single_solo( level.hesh, "tower_leave" );
	wait( .65 );
	
	doors = getentarray( "tower_mid_doors", "targetname" );
	foreach( door in doors )
	{
		num = 90;
		if( door noteworthy_check( "right" ) )
			num = -90;
		
		door rotateto( door.angles + ( 0,num,0 ), .5, 0, .2 );
		
		door connectpaths();
	}
	
	flag_set( "FLAG_player_leaving_tower" );	
	
	/*-----------------------
	RETREATING U.S. VISTA
	-------------------------*/
	level.heroes thread heroes_move( "movespot_tower_retreat_2" );
	
	waittill_trigger( "player_leaving_tower_trig" );
	
	thread tower_ally_retreaters_wave1();
	
	level.heroes thread heroes_move( "movespot_tower_retreat_3" );
	
	garageDoors = getent( "trench_tower_garage_exit", "targetname" );
	garageDoors connectpaths();
	garageDoors delete();
	
	waitframe();
	advancers = get_ai_array( "tower_exit_advancing_enemies" );
	waittill_dead_or_dying( advancers, advancers.size );
	
	/*-----------------------
	COVER RETREATING U.S.
	-------------------------*/
	
	waittill_trigger( "player_leaving_tower_trig_2" );
	
	level notify( "stop_tower_ally_retreaters_wave1" );
	
	thread add_dialogue_line( "Hesh",  "Let's Go! Let's Go!" );
	
	level.heroes thread heroes_move( "movespot_tower_retreat_4" );
	
	waittill_trigger( "player_leaving_tower_trig_3" );
	
	/*-----------------------
	START ELIAS STREET
	-------------------------*/
	flag_set( "FLAG_start_elias_street" );
	
}

tower_vista_retreat_tank()
{
	self.fireTime = [];
	self.fireTime[0] = .5;
	self.fireTime[1] = 1;
	
	struct = getstruct( self.script_linkto, "script_linkname" );
	self SetTurretTargetVec( struct.origin );
	
	flag_wait( "FLAG_player_leaving_tower" );
	gopath( self );
}

tower_ally_retreaters_wave1()
{
	level endon( "stop_tower_ally_retreaters_wave1" );
	
	spawners = getentarray( "tower_exit_ally_retreater", "targetname" );
	
	//while( 1 )
	//{
		//spawners = array_randomize( spawners );
		foreach( spawner in spawners )
		{
			ai = spawner spawn_ai();
			struct = getstruct( spawner.target, "targetname" );
			ai thread move_on_path( struct, true );
			//wait( randomfloatrange( .5, 1 ) );
		}
	//}
	
	array_spawn( getentarray( "tower_exit_enemy_advancers", "targetname" ) );
}

// ELIAS STREET SEQUENCE
elias_street_sequence()
{
	flag_wait( "FLAG_start_elias_street" );

	level.heroes thread heroes_move( "movespot_elias_street_1" );	

	thread green_house_ladder();
	thread elias_street_helicopter_flyover();
	thread elias_street_retreaters();
	
	waittill_trigger( "elias_street_trig_1" );
	
	level.heroes thread heroes_move( "movespot_elias_street_2" );	
	
	/*-----------------------
	STREET FLEE GUYS
	-------------------------*/
	add_wait( ::flag_wait, "elias_street_heli_unload" );
	add_wait( ::waittill_trigger, "elias_street_flee_guys_trig" );
	do_wait_any();
	
	thread elias_street_dragging_wounded();
	thread elias_street_flee_guys_enemies();
	array_thread( getentarray( "elias_street_scared_runners", "targetname" ), ::elias_street_flee_guys );
	
	/*-----------------------
	WAITTILL STREET ENEMIES ARE MOSTLY DEAD
	-------------------------*/
	flag_wait( "FLAG_elias_street_ground_enemies" );
	
	thread add_dialogue_line( "Hesh",  "Enemies! End of the street!" );
	delaythread( 1.2, ::add_dialogue_line, "Hesh", "Watch your fire for retreating friendlies" );
	
	streetEnemies = get_ai_array( "elias_street_enemies" );
	waittill_dead_or_dying( streetEnemies, streetEnemies.size - 2 );
	
	level.hesh set_ignoreSuppression( true );
	level.hesh thread heroes_move( "movespot_elias_street_3" );
	
	/*-----------------------
	DOG GOES IN FOR THE FINAL KILLS
	-------------------------*/
	thread add_dialogue_line( "Hesh",  "Cairo! Go!" );
	
	streetEnemies = get_ai_array( "elias_street_enemies" );
	enemy = getClosest( level.dog.origin, streetEnemies );
	level.dog setgoalentity( enemy );
	level.dog SetDogAttackRadius( 512 );
	level.dog.meleeAlwaysWin = true;
	
	/*-----------------------
	WAITTILL THE REST OF STREET ENEMIES ARE DEAD
	-------------------------*/
	
	streetEnemies = get_ai_array( "elias_street_enemies" );
	waittill_dead_or_dying( streetEnemies, streetEnemies.size );
	
	level.hesh set_ignoreSuppression( false );
	
	/*-----------------------
	START ELIAS HOUSE
	-------------------------*/
	flag_set( "FLAG_start_elias_house" );
}

green_house_ladder()
{
	waittill_trigger( "green_house_ladder_guy_trig" );
	
	spawner = getent( "green_house_ladder_spawner", "targetname" );
	
	climber = spawner spawn_ai();
	
	climbon = getstruct( spawner.target, "targetname" );
	climbon anim_generic_reach( climber, "ladder_climbon" );
	climbon thread anim_generic( climber, "ladder_climbon" );
	
	// setup second AI
	slider = spawner spawn_ai();
	slider.animname = "generic";
	slider hide();
	slidedown = getstruct( climbon.target, "targetname" );
	slidedown thread anim_generic( slider, "ladder_slide" );
	waitframe();
	slider setanimtime( getanim_generic( "ladder_slide" ), .17 );
	thread anim_set_rate_single( slider, "ladder_slide", 0 );
	
	wait( .65 );
	
	if( !isdefined( climber ) && !isalive( climber ) )
	{
		slider delete();
		return;		
	}	
	
	slider show();
	climber delete();
	thread anim_set_rate_single( slider, "ladder_slide", .62 );
	wait( 1 );
	thread anim_set_rate_single( slider, "ladder_slide", 1 );
	wait( 1.15 );
	slider stopanimscripted();
	
	slider endon( "death" );
	
	goal = getstruct( slider.script_linkTo, "script_linkname" );
	slider setgoalpos( goal.origin );
	slider.goalradius = 56;
	slider waittill( "goal" );
	slider delete();
}

elias_street_helicopter_flyover()
{
	waittill_trigger( "elias_street_flyover" );
	volume = getent( "helicopter_check_volume", "targetname" );
	
	vSpawners = getentarray( "elias_street_flyover_choppers", "targetname" );
	foreach( vSpawner in Vspawners )
	{
		waitTime = 0;
		if( isdefined( vSpawner.script_wait ) )
			waitTime = vSpawner.script_wait;
		
		delaythread( waittime, ::elias_street_helicopter_spawn, vSpawner, volume );
	}
}

elias_street_helicopter_spawn( vSpawner, volume )
{
	while( !level.player istouching( volume ) )
		wait( .05 );
	
	//while ( player_looking_at( vSpawner.origin, 0.6 ) )
	
	vSpawner spawn_vehicle_and_gopath();
}

elias_street_flee_guys()
{
	spawner = self;
	if( isdefined( spawner.script_wait ) )
		wait( spawner.script_wait );
	
	ai = spawner spawn_ai();
	ai ignore_everything();
	ai.ignoreme = true;
	ai magic_bullet_shield();
	ai pathrandompercent_zero();
	
	struct = getstruct( ai.target, "targetname" );
	if( spawner noteworthy_check( "shoot_behind" ) )
	{
		ai set_generic_deathanim( "run_death_roll" );
		
		struct anim_generic_reach( ai, "flee_run_shoot_behind" );
		struct thread anim_generic( ai, "flee_run_shoot_behind" );
		
		wait( 1.3 );
		
		playfxontag( getfx( "headshot_blood" ), ai, "j_head" );
		
		ai stopanimscripted();
		ai stop_magic_bullet_shield();
		ai die();
	}
	else
	{
		//ai set_generic_run_anim( "scared_run" );
		
		ai setgoalpos( struct.origin );
		ai.goalradius = 56;
		ai waittill( "goal" );
		ai stop_magic_bullet_shield();
		ai delete();
	}
						
}

elias_street_flee_guys_enemies()
{
	spawners = getentarray( "street_flee_guys_enemy_spawner", "targetname" );
	
	thread elias_street_flee_guys_enemies_fakeShots( spawners );
	level thread notify_delay( "stop_fake_street_shots", 2.5 );
	wait( 2.2 );
	
	waitTime = 0;
	foreach( spawner in spawners )
	{
		wait( waitTime );
		ai = spawner spawn_ai();
		ai ignore_everything();	
		ai magic_bullet_shield();
//		ai.ignoreall = true;
		ai delaythread( 1, ::clear_ignore_everything );
		ai delaythread( 1, ::stop_magic_bullet_shield );
		
		waitTime = randomfloatrange( .4, .6 );
	}
	
	flag_set( "FLAG_elias_street_ground_enemies" );
}

// long ass function name for the win
elias_street_flee_guys_enemies_fakeShots( spawners )
{
	level endon( "stop_fake_street_shots" );
	
	spot = getstruct( "elias_street_shoot_spot", "targetname" );
	weapons = [ "sc2010", "honeybadger" ];
	
	while( 1 )
	{
		spawner = spawners[ randomint( spawners.size ) ];
		
		burst = randomintrange( 6,8 );
		for( i=0; i<burst; i++ )
		{
			point = return_point_in_circle( spot.origin, spot.radius, spot.height );
		
			weaponName = weapons[ randomint( weapons.size ) ];
			MagicBullet( weaponName, spawner.origin + ( 0,0,46 ), point );
			wait( .1 );
		}
		
		wait( randomfloatrange( .3, .6 ) );
	}
}

#using_animtree( "generic_human" );
elias_street_dragging_wounded()
{
	spawner = getent( "elias_street_dragger_spawner", "targetname" );
	struct = getstruct( spawner.script_linkto, "script_linkname" );
	
	dragger = spawner spawn_ai();
	dragger.animname = "dragger";
	dragger.deathAnim = %stand_death_tumbleback;
	dragger magic_bullet_shield();
	wounded = spawner spawn_ai();
	wounded.animname = "wounded";
	wounded magic_bullet_shield();
	wounded.deathAnim = %airport_civ_dying_groupB_wounded_death;
	
	scene = [ dragger, wounded ];

	struct thread anim_single( scene, "elias_street_drag_wounded_drag" );
	foreach( guy in scene )
		guy setanimtime( guy getanim( "elias_street_drag_wounded_drag" ), .2 );
	
	struct waittill( "elias_street_drag_wounded_drag" );
	
	playfxontag( getfx( "headshot_blood" ), dragger, "j_head" );
	foreach( guy in scene )
	{
		guy.noragdoll = true;
		guy stop_magic_bullet_shield();	
		guy die();
	}
}

elias_street_retreaters()
{
	spawners = getentarray( "elias_street_ambient_retreaters", "targetname" );
	runAnims = [ "run" ];
	spawnTime = [ 2.5, 5 ];
	
	array_thread( spawners, ::drone_infinite_runners, "FLAG_stop_elias_street_ambient_retreaters", spawnTime, runAnims );	
}

// ELIAS HOUSE SEQUENCE
elias_house_sequence()
{
	flag_wait( "FLAG_start_elias_house" );
	
	level.dog thread heroes_move( "movespot_elias_street_3" );
	
	/*-----------------------
	HESH GET TO GARAGE DOOR
	-------------------------*/
	garageSpot = getstruct( "elias_garage_hesh_spot", "targetname" );
	level.hesh setgoalpos( ( -1039, 11685, 16 ) );
	level.hesh.goalradius = 56;
	level.hesh waittill( "goal" );
	
	/*-----------------------
	ATTACKERS AT OPPOSITE END OF STREET
	-------------------------*/
	thread add_dialogue_line( "Hesh",  "Enemies advancing behind us! We gotta get inside!" );
	maps\_spawner::flood_spawner_scripted( getentarray( "elias_street_advancing_enemy_spawner", "targetname" ) );
	
	delaythread( .5, ::spawn_vehicle_from_targetname_and_drive, "elias_street_enemy_heli_2" );
	
	/*-----------------------
	HESH LIFT GARAGE DOORS
	-------------------------*/
	
	garageDoor = getent( "elias_house_garage_door", "targetname" );
	
	garageSpot thread anim_single_solo( level.hesh, "elias_garage_lift" );
	waitframe();
	level.hesh setanimtime( level.hesh getanim( "elias_garage_lift" ), .2 );
	
	wait( 2 );
	
	originalOrigin = garageDoor.origin;
	garageDoor moveto( originalOrigin + ( 0,0,44 ), 1.8 );
	
	wait( 1 );
	
	garageDoor connectPaths();
	
	thread add_dialogue_line( "Hesh",  "Cairo! In!" );
	
	level.dog thread heroes_move( "movespot_elias_house_1" );
	
	garageSpot waittill( "elias_garage_lift" );	
	
	garageSpot thread anim_loop_solo( level.hesh, "elias_garage_idle" );
	
	thread garage_door_nag();
	
	// wait for player to get through the garage doors
	garageTrigger = getent( "elias_house_trig_1", "targetname" );
	waittill_trigger( garageTrigger );
	
	level notify( "player_in_elias_garage" );
	
	while( !level.dog istouching( garageTrigger ) )
		wait( .05 );
	
	garageSpot notify( "stop_loop" );
	garageSpot thread anim_single_solo( level.hesh, "elias_garage_thru" );
	
	wait( 3 );
	
	garageDoor moveto( originalOrigin, 1 );
	garageDoor DisconnectPaths();
	
	wait( 1 );
	
	level.hesh StopAnimScripted();
	
	level.heroes thread heroes_move( "movespot_elias_house_2" );
	
	/*-----------------------
	DELETE ENEMIES/ALLIES STILL ON THE STREET
	-------------------------*/
	flag_set( "FLAG_stop_elias_street_ambient_retreaters" );
	maps\_spawner::killspawner( 405 );
	array_delete( get_ai_array( "elias_street_advancing_enemies" ) );
	
	/*-----------------------
	MOVE UPSTAIRS
	-------------------------*/
	flag_wait( "TRIGFLAG_player_leaving_elias_garage" );

	level.heroes thread heroes_move( "movespot_elias_house_3" );
	
	flag_wait( "TRIGFLAG_player_elias_secondfloor" );
	
	thread add_dialogue_line( "Hesh",  "We gotta make sure dad got out!" );
	wait( 1.4 );
	thread add_dialogue_line( "Hesh",  "Check upstairs!" );
	
	/*-----------------------
	TOP FLOOR EVENT
	-------------------------*/
	delaythread( 5, ::end_of_scripting );
}

garage_door_nag()
{
	level endon( "player_in_elias_garage" );
	
	dialogueLines = [];
	dialogueLines[0] = "Get inside!";
	dialogueLines[1] = "Come on Adam! We won't last out here!";
	dialogueLines[2] = "Adam! We need to make sure Dad got out!";
	dialogueLines[3] = "Adam! Get in here!";
	
	usableLines = dialogueLines;
	while( 1 )
	{
		dLine = usableLines[ randomint( usableLines.size ) ];
		thread add_dialogue_line( "Hesh",  dLine );
		wait( randomintrange( 4, 7 ) );
		
		usableLines = dialogueLines;
		usableLines = array_remove( dialogueLines, dLine );
	}
}

