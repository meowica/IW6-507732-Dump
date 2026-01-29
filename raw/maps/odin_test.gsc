#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


test_start()
{
	wait.1;
	//maps\odin_util::actor_teleport( level.ally, "odin_test_ally_tp" );
	//maps\odin_util::move_player_to_start_point( "start_odin_test" );
	//thread z_test();
}

section_precache()
{
}

section_flag_init()
{
	//flag_init( "test_clear" );
}

section_hint_string_init()
{
}


//================================================================================================
//	MAIN
//================================================================================================
test_main()
{
	//iprintlnbold( "Escape Main" );

	//maps\odin_util::safe_trigger_by_targetname( "escape_test_ally_init_pos" );

	//level thread escape_test_enemies();

	// Halt to prevent auto fallthrough into next checkpoint
	//flag_wait( "escape_clear" );
}

test_setup()
{
}

escape_dialogue()
{
}

escape_test_enemies()
{
	//thread escape_test_rotating_patrol();
	//thread escape_test_rotating_cover();
	//thread escape_test_outdoor_guys();
	//thread escape_test_traversal();
	//thread test_corpses();

	//wait 2.0;

	// Remove the ally
	//level.ally thread stop_magic_bullet_shield();
	//level.ally delete();
}

/*
escape_test_rotating_patrol()
{
	array_spawn_function_targetname( "escape_test_rotating_patrol", maps\odin_util::teleport_to_target );
	spawner = GetEnt( "escape_test_rotating_patrol", "targetname" );
	guy = spawner StalinGradSpawn();
	if ( spawn_failed( guy ) )
	{
		iprintlnbold( "spawn failed" );
		return;
	}
	guy thread maps\_space_ai::enable_space();
	//guy.ignoreall = true;
	guy.ignoreme = true;
	//guy thread magic_bullet_shield( true );
	guy.jumping = true;
	guy.approachType = "";
	
	next_node = GetEnt( "rotating_patrol_start", "script_noteworthy" );
	while( isAlive( guy ))
	{
		guy SetGoalPos( next_node.origin );
		guy delayThread( 0.5, maps\odin_util::doing_in_air_rotation, guy.angles, next_node.angles, 90 );
		guy waittill( "goal" );
		guy notify( "stop_rotation" );
		guy thread maps\odin_util::doing_in_air_rotation( guy.angles, next_node.angles, 30 );
		wait RandomIntRange( 6, 8 );
		
		next_node = GetEnt( next_node.target, "targetname" );
	}
}
*/

/*
escape_test_rotating_cover()
{
	array_spawn_function_targetname( "escape_test_rotating_cover", maps\odin_util::teleport_to_target );	
	spawner = GetEnt( "escape_test_rotating_cover", "targetname" );
	guy = spawner StalinGradSpawn();
	if ( spawn_failed( guy ) )
	{
		iprintlnbold( "spawn failed" );
		return;
	}
	guy thread maps\_space_ai::enable_space();
	//guy.ignoreall = true;
	guy.ignoreme = true;
	//guy thread magic_bullet_shield( true );
	guy.jumping = true;
	guy.approachType = "";
	guy.goalradius = 128;
	guy.fixednode = false;
	
	test_vol = GetEnt( "escape_test_volume", "targetname" );
	guy SetGoalVolumeauto( test_vol );

	guy thread maps\_space_ai::handle_angled_nodes();
}
*/

/*
// Spawn the outdoor test guys
escape_test_outdoor_guys()
{
	// Outdoor guys
	spawners = GetEntArray( "escape_test_outdoor_guys", "targetname" );
	foreach( spawner in spawners )
	{
		guy = spawner spawn_ai();
		if( spawn_failed( guy ))
		{
			return;
		}
		guy thread maps\_space_ai::enable_space();
		//guy.ignoreall = true;
		guy.ignoreme = true;
		//guy thread magic_bullet_shield( true );
		guy.jumping = true;
		guy.approachType = "";
		guy.goalradius = 128;
		guy.fixednode = false;
		
		// Teleport to the target
		org = spawner get_target_ent();
		if ( !isdefined( org.angles ) )
			org.angles = spawner.angles;
		guy ForceTeleport( org.origin, org.angles );
		
		// Set goal volume on targets target
		vol = org get_target_ent();
		guy SetGoalVolumeauto( vol );
		
		// Start angled node behavior
		guy thread maps\_space_ai::handle_angled_nodes();
	}
}
*/

/*
// Spawn a bunch of bodies to test pushable ragdolls
test_corpses()
{
	spawners = GetEntArray( "odin_test_corpses", "targetname" );
	foreach( spawner in spawners )
	{
		guy = spawner spawn_ai( true );
		if( spawn_failed( guy ))
		{
			iprintlnbold( "Test corpse spawn failed." );
		}
		guy.forceRagdollImmediate = true;
		guy kill();
	}

	// Give the player a physics aura
	count = 0;
	while( 1 )
	{
		PhysicsExplosionSphere( level.player.origin, 45, 32, 0.15 );
		wait 0.05;
	}
}

Z_test()
{
	maps\odin_util::actor_teleport( level.ally, "test_z_ally_tp" );
	animNode = GetEnt( "test_z_animnode" , "targetname" );
	animNode_org = animNode.origin;
	
	
	level.ally.animname = "hall_escape_turn01_ally";
	
	guys = [];
	guys["hall_escape_turn01_ally"] = level.ally;
	animNode anim_reach( guys , "odin_hall_escape_turn01_ally" );
	animNode anim_first_frame( guys , "odin_hall_escape_turn01_ally" );
	
	origin = GetEnt( "z_trans_test_origin" , "targetname" );
	animNode LinkTo( origin );
	z_trans = GetEntArray( "z_trans_test" , "targetname" );
	space = getEnt( "space_mover" , "targetname" );
	wait 1;
	space Unlink();
	space_origin = space.origin;
	foreach ( piece in z_trans)
	{
		if( piece.classname == "script_brushmodel" || piece.classname == "script_model" )
		{
			piece LinkTo( origin );
		}
	}
	
	flag_wait( "z_anim_test_trig" );
	level.ally LinkTo( origin );
	animNode thread anim_single( guys , "odin_hall_escape_turn01_ally" );
	flag_wait( "z_trans_test_trig" );
	player_origin = level.player.origin;
	level.player SetOrigin( (player_origin[0] , player_origin[1] , ( player_origin[2] - 9640 ) ) );
	origin RotateRoll( 90 , 3 , 1.5 , 1 );
	wait 3;
	space Unlink();
}
*/

//================================================================================================
//	CLEANUP
//================================================================================================
// force_immediate_cleanup - When true, cleanup everything instantly, don't wait or block
test_cleanup( force_immediate_cleanup )
{
}

