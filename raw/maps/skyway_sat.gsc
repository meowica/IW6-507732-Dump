#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\skyway_util;
#include maps\skyway_util_ai;

//*******************************************************************
//																	*
//																	*
//*******************************************************************

section_flag_inits()
{
	flag_init( "flag_sat_end" );	
}

section_precache()
{
}

section_post_inits()
{	
	level._sat				  = SpawnStruct();
	level._sat.ally_start_1	  = GetEnt( "ally1_start_sat1", "targetname" );
	level._sat.player_start_1 = GetEnt( "player_start_sat1", "targetname" );
	level._sat.ally_start_2	  = GetEnt( "ally_start_sat2", "targetname" );
	level._sat.player_start_2 = GetEnt( "player_start_sat2", "targetname" );
	
	if( IsDefined( level._sat.player_start_1 ))
	{
		// SAT anims
		sat1_accessories =
		[
			"model_sat_1_satellite_1", 
			"model_sat_1_satellite_2",			
			"model_sat_1_satellite_4", 
			"model_sat_1_satellite_5", 
			"model_sat_1_satellite_6"
		];
		
		// TODO Brushmodels for cargo pieces, first frame, link, hide models
		foreach( accessory in [ "model_sat_1_satellite_1", "model_sat_1_satellite_2" ] )
		{		
			ent = GetEnt( accessory, "targetname" );
			ent.animname = accessory;
			ent SetAnimTree();
			ent anim_first_frame_solo( ent, "sway" );
			ent HideNoShow();
			array_call( GetEntArray( ent.target, "targetname" ), ::LinkTo, ent, "j_chainbase" );
		}		
		
		level._sat.satellites = maps\skyway_util::train_init_accessories_sway( sat1_accessories );	
	}
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

start()
{
	IPrintLn( level.start_point );	
	
	player_start = undefined;
	ally_start = undefined;
	
	if( IsSubStr( level.start_point, "sat_end" ) )
	{
		// SAT end
		player_start = level._sat.player_start_2;
		ally_start = level._sat.ally_start_2;
	}
	else
	{
		// SAT front
		player_start = level._sat.player_start_1;
		ally_start = level._sat.ally_start_1;
	}
		
	// Player
	player_start( player_start );	

	// Allies		
	level._allies[ 0 ] ForceTeleport( ally_start.origin, ally_start.angles );
	level._allies[ 0 ] set_force_color( "r" );	
		
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

main()
{	
	// Setup force mantle
	level.player thread flag_watcher( "flag_rt_mantle", ::EnableForceMantle );
	
	// Skip if end of sat
	if( IsSubStr( level.start_point, "sat_end" ) )
		return;
	
	thread allies();
	thread enemies();		
	
	// Trigger detection sat start
	array_call( level._train.cars[ "train_sat_1" ].trigs, ::SetMovingPlatformTrigger );		
	
	//
	// End
	//
	
	flag_wait( "flag_sat_end" );	
}

EnableForceMantle()
{
	self ForceMantle();
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

allies()
{
	ally = level._allies[ 0 ];	
	ally set_ignoresuppression( true );	
	ally disable_pain();
	ally disable_cqbwalk();	
	ally ignore_everything();
	
	//
	// SAT 1
	//
	ally thread ally_advance_watcher( "trig_sat_1_allies_1", "sat1" );	
	
	trigger_wait_targetname( "trig_sat_enemy_spawn" );
	
	wait( 7 );
	
	ally unignore_everything();
	
	flag_wait( "flag_sat_end" );
	
	ally set_goal_node( GetNode( "node_rt_traverse_1", "targetname" ) );
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

enemies()
{
	// Spawnfuncs
	array_spawn_function_targetname( "actor_sat1_1", ::spawnfunc_enemies_ignore, "sat1" );		
}

//*******************************************************************
//																	*
//																	*
//*******************************************************************

spawnfunc_enemies_ignore( group )
{
	self add_to_group( group );
	self.script_forcegoal = 1;
	self.maxFaceEnemyDist = 128;
	
	self thread ignore_until_goal();
}

spawnfunc_enemies_generic( group )
{
	self add_to_group( group );
	self.script_forcegoal = 1;
	self.maxFaceEnemyDist = 128;
}	

//*******************************************************************
//																	*
//																	*
//*******************************************************************
