#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	maps\mp\mp_warhead_precache::main();
	maps\createart\mp_warhead_art::main();
	maps\mp\mp_warhead_fx::main();
	
	maps\mp\_load::main();
	
	// The tunnel moves, the elevator does not, once it 'reaches' ground level we extend some platforms out to fill in the gaps
	warheadElevator();
	
//	AmbientPlay( "ambient_mp_setup_template" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_mp_warhead" );
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game[ "allies_outfit" ] = "urban";
	game[ "axis_outfit" ] = "woodland";
	
}

ELEVATOR_RIDE_SEC	= 120.0;
DOOR_TIMER_SEC 		= 10.0;

warheadElevator()
{
	flag_init( "shuttle_fire" );
	flag_init( "warhead_mover_done" );
	flag_init( "doors_closed" );
	
	
	level.dynamicSpawns = ::warheadSpawnsValidGet;
	
	level thread warheadElevatorSequence();
}

warheadSpawnsValidGet( spawn_points )
{
	if ( flag( "warhead_mover_done" ) )
		return spawn_points;
	
	volume = GetEnt( "elevator_spawns_volume", "targetname" );
	
	valid_spawns = [];
	
	foreach ( point in spawn_points )
	{
		if ( !IsDefined( point.warheadSpawnOnElevator ) )
		{
			point.warheadSpawnOnElevator = IsPointInVolume( point.origin, volume );
		}
		
		if ( point.warheadSpawnOnElevator )
		{
			valid_spawns[ valid_spawns.size ] = point;
		}
	}
	
	return valid_spawns;
}

warheadElevatorSequence()
{
	waitframe(); // give load::main time to init
	
	disableAllStreaks();
	
	gameFlagWait( "prematch_done" );
	
	tunnel = GetEnt( "tunnel", "targetname" );
	tunnel_clips = GetEnt( "tunnel_clip", "targetname" );
	
	model_sec = GetEntArray( "fans", "targetname" );
	
	foreach( model_piece in model_sec )
	{
		model_piece linkto( tunnel );
	}
			
	tunnel_dest = GetEnt( tunnel.target, "targetname" );

	wait( 10 );

	tunnel MoveTo( tunnel_dest.origin, ELEVATOR_RIDE_SEC, 5, 3 );

	tunnel waittill ( "movedone" );
	
	flag_set( "warhead_mover_done" );
	
	enableAllStreaks();
	
	tunnel_clips Delete();
	
	thread shuttle_setup();
}

shuttle_setup()
{
	// Shuttle stuff - play smoke, alarms etc, countdown, 10,9,8,7  - shut the blast doors, start the fire and kill any left over players - then open the doors
	exhaust_kill_trig = getEnt( "exhaust_trigger", "targetname" );
	exhaust_kill_trig thread blaster();
	
	thread shuttle_launch();
}

blaster()
{	
	
	engines = getStructArray( "engine", "targetname" );
	
	Earthquake( .3, 20, (1328, 14616, 1668), 6400 );
	
	foreach ( engine in engines )
	{
		afterburner = spawn( "script_model", engine.origin );
		afterburner setModel( "tag_origin" );
		
				
		afterburner.angles = ( 270, 0, 0 );
		afterburner = PlayLoopedFX( level._effect[ "engine_fire" ], 10, afterburner.origin );
		
		//PlayFXOnTag( getfx( "engine_fire" ), afterburner, "tag_origin" );
		//afterburner linkto( engine );
		//thread loop_blaster_fx( afterburner );
		
		//afterburner Delete();
		
	}
		
	// killing players in the fire
	while ( flag( "shuttle_fire" ) != true )
	{
		foreach ( player in level.players )
		{
			if ( player IsTouching( self ) )
			{
				player _suicide();
			}
		}
		
		wait (0.5);
	}
	
	flag_wait( "shuttle_fire" );
	
	foreach( engine in engines )
		engine delete();
}

loop_blaster_fx( afterburner )
{
	while( 1 )
	{
		PlayFXOnTag( getfx( "engine_fire" ), afterburner, "tag_origin" );
		wait( 10 );
	}
}

shuttle_launch()
{
	shuttle = getEnt( "shuttle", "targetname" );
	space = getEnt( "space", "targetname" );

	flag_wait( "warhead_mover_done" );
	
	// Give time to blast some people
	
	wait( 10 );
	
	flag_set( "shuttle_fire" );
	
	shuttle MoveTo( space.origin, 15, 2, 1 );
	
	wait( 5 );
	
	// shuttle Delete();
	
	external_doors();
}

external_doors()
{
	doors = getEntArray( "blast_door", "targetname" );
	
	foreach ( door in doors )
	{
		target = door get_target_ent();
		door thread door_move( target.origin );
	}
}

DOOR_MOVE_TIME_P1 = 5;
DOOR_PAUSE_TIME = 0.5;
DOOR_MOVE_TIME_P2 = 0.5;
DOOR_MOVE_LENGTH_P2 = 8;
door_move( origin )
{
	door = self;
	
	moveVec = origin - door.origin;
	moveLength = Length( moveVec );
	moveDir = VectorNormalize( moveVec );
	
	Assert( DOOR_MOVE_LENGTH_P2 < moveLength );
	
	moveVecP1 = moveDir * ( moveLength - DOOR_MOVE_LENGTH_P2 );
	moveVecP2 = moveDir * DOOR_MOVE_LENGTH_P2;
	
	endPosP1 = door.origin + moveVecP1;
	endPosP2 = endPosP1 + moveVecP2;
	
	door MoveTo( endPosP1, DOOR_MOVE_TIME_P1, 2 );
	wait( DOOR_PAUSE_TIME );
	door MoveTo( endPosP2, DOOR_MOVE_TIME_P2 );
}









