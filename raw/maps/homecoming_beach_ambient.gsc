#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\homecoming_util;
#include maps\homecoming_drones;

// THIS FILE TAKES CONTROL OF BEACH ACTIVITY WHEN PLAYER IS TOLD TO LEAVE BUNKER
init_beach_ambient()
{
	/*-----------------------
	BEACH MORTAR STUFF
	-------------------------*/
	thread set_mortar_on( 0 );
	thread set_mortar_on( 1 );
	
	/*-----------------------
	FRIENDLY TURRETS
	-------------------------*/
	turrets = getentarray( "beach_ally_turrets", "targetname" );
	foreach( turret in turrets )
	{
		targets = turret get_linked_ents();
		turret thread turret_shoot_targets( targets );
	}
	
	/*-----------------------
	SHIP PHALANX SYSTEM
	-------------------------*/
	phalanxStructs = getstructarray( "ship_phalanx_structs", "targetname" );
	time = 0;
	foreach( struct in phalanxStructs )
	{
		struct delayThread( time, ::beach_ship_phalanx_system );
		time = time + randomintrange( 1,3 );
	}
	
	/*-----------------------
	SKY AMBIENT
	-------------------------*/
	thread beach_ambient_helicopters();
	
}

beach_ambient_helicopters()
{
	vSpawners = getentarray( "beach_ambient_landers", "targetname" );
	shipHelis = [];
	skyHelis = [];
	foreach( spawner in Vspawners )
	{
		if( spawner.script_noteworthy == "ship" )
			shipHelis[ shipHelis.size ] = spawner;
		else
			skyHelis[ skyHelis.size ] = spawner;
	}

	thread ambient_nh90_landers( shipHelis, 6, 8 );
	thread ambient_nh90_landers( skyHelis, 4, 6 );	
}

ambient_nh90_landers( vSpawners, minT, maxT )
{
	while( 1 )
	{
		foreach( spawner in vSpawners )
		{
			wait( randomintrange( minT, maxT ) );
			spawner spawn_vehicle_and_gopath();
		}
	}
}

ambient_hinds( spawner )
{
	while( 1 )
	{
		self script_delay();
		spawner spawn_vehicle_and_gopath();
	}
}

// PHALANX
beach_ship_phalanx_system()
{
	structs = getstructarray( self.target, "targetname" );
	//array_thread( structs, ::beach_ship_phalanx_think );
	while( 1 )
	{
		structs = array_randomize( structs );
		
		foreach( struct in structs )
		{
			struct thread beach_ship_phalanx_think();
			wait( randomfloatrange( 1.5, 2 ) );
		}
	}
}

beach_ship_phalanx_think()
{
	phalanx = spawn( "script_origin", self.origin );
	
	originalAngles = ( 270, 0, 90 );
	//phalanx.angles = originalAngles;
	//while( 1 )
	//{
		//wait( randomintrange( 1, 2 ) );
		newAngles = ( 270 + randomintrange( 30, 50 ), 0, 90 );
		phalanx.angles = newAngles;
		phalanx thread phalanx_fire();
		time = randomfloatrange( .4, .8 );
		phalanx thread phalanx_incoming_hit( time );
		phalanx rotateto( originalAngles, time );
		phalanx waittill( "rotatedone" );
		phalanx notify( "stop_fire" );
	//}
	phalanx delaycall( 2, ::delete );
}

phalanx_fire()
{
	self endon( "stop_fire" );
	self endon( "death" );
	
	while( 1 )
	{
		fwd = anglestoforward( self.angles );
		playfx( getfx( "phalanx_tracer" ), self.origin, fwd );
		wait( .05 );
	}
}

phalanx_incoming_hit( time )
{
	wait( time - randomfloatrange( .2, .3 ) );
	fwd = AnglesToForward( self.angles );
	origin = self.origin + ( fwd * randomintrange( 2000, 8000 ) );
	playfx( getfx( "phalanx_missile_explosion" ), origin );
}

CONST_PHALANX_WAIT_TIME_MIN = 1.1;
CONST_PHALANX_WAIT_TIME_MAX = 1.3;
CONST_PHALANX_ENGAGE_DIST_MIN = -9000;
CONST_PHALANX_ENGAGE_DIST_MAX = -8000;
CONST_PHALANX_HIT_DIST_MIN = -13500;
CONST_PHALANX_HIT_DIST_MAX = -10500;
CONST_PHALANX_LOOKAHEAD_DIST = -500; // -3000
beach_ship_phalanx_system_complex()
{
	structs = getstructarray( "ship_phalanx_system", "targetname" );
	foreach( struct in structs )
		struct.used = false;
	
	vSpawner = getent( "anti_battleship_missiles", "targetname" );
	vStarts = getvehiclenodeArray( "anti_battleship_missile_starts", "targetname" );
	
	last_Vstart = undefined;
	while( 1 )
	{	
		missile = vSpawner spawn_vehicle();
		
		start = undefined;
		while( 1 )
		{	
			start = vStarts[ randomint( vStarts.size ) ];
			
			if( !isdefined( last_Vstart ) )
				break;
			
			if( start != last_Vstart )
				break;
		}
		
		last_Vstart = start;
		
		missile attach_path_and_drive( start );
		missile thread phalanx_missile_think( structs );
		wait( randomfloatrange( CONST_PHALANX_WAIT_TIME_MIN, CONST_PHALANX_WAIT_TIME_MAX ) );
		
	}
}

phalanx_missile_think( structs )
{
	missile = self;
	
	engageDist = randomintrange( CONST_PHALANX_ENGAGE_DIST_MIN, CONST_PHALANX_ENGAGE_DIST_MAX );
	while( missile.origin[0] > engageDist )
		wait( .1 );
	
	usable = structs;
	while( 1 )
	{
		phalanx = SortByDistance( usable, missile.origin );
		//phalanx = phalanx[ randomint( 2 ) ];
		phalanx = phalanx[0];
		
		if( phalanx.used )
			usable = array_remove( usable, phalanx );
		else
			break;
		wait( .05 );
	}
	
	phalanx.used = true;
	
	wTime = 0;
	vector = undefined;
	
	hitDist = randomintrange( CONST_PHALANX_HIT_DIST_MIN, CONST_PHALANX_HIT_DIST_MAX );
	while( missile.origin[0] > hitDist )
	{
		vector = VectorNormalize( missile.origin - phalanx.origin + ( CONST_PHALANX_LOOKAHEAD_DIST, 0, 0 ) );
		//noself_delaycall( wTime, ::playfx, getfx( "phalanx_tracer" ), phalanx.origin, vector );
		missile thread phalanx_fire( wTime, phalanx.origin, vector );
		wTime = wTime + randomfloatrange( 0, .05 );
		wait( .05 );
	}
	
	// one last shot for kicks
	playfx( getfx( "phalanx_tracer" ), phalanx.origin, VectorNormalize( missile.origin - phalanx.origin ) );
	
	playfx( getfx( "phalanx_missile_explosion" ), missile.origin );
	missile delete();
	phalanx.used = false;	
}

phalanx_fire_complex( wTime, org, vector )
{
	self endon( "death" );
	
	wait( wTime );
	playfx( getfx( "phalanx_tracer" ), org, vector );
}