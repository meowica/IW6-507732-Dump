#include maps\_utility;
#include common_scripts\utility;
#include maps\loki_util;
#include maps\_vehicle;
#include maps\_anim;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
	
section_flag_inits()
{
	flag_init( "infil_done" );
	flag_init( "first_wave_spawned" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infil_start()
{
	player_move_to_checkpoint_start( "infil" );
	spawn_allies();
}

infil()
{
	autosave_by_name_silent( "infil" );
	
//	level thread infil_shuttle_movement();
//	level thread infil_shuttle_squad_attach_detach();
	array_spawn_function( GetSpawnerTeamArray( "axis" ), ::enemy_marker );
	
	level thread infil_vignette();
	
	flag_wait( "infil_done" );
}

infil_vignette()
{
	start_node = GetEnt( "infil_vignette", "targetname" );
	
	level.player FreezeControls( true );
	level.player DisableWeapons();
	level.player HideViewModel();

	shuttle = spawn_anim_model( "infil_shuttle" );

	seat_0 = spawn_anim_model( "infil_shuttle_chair0", shuttle GetTagOrigin( "tag_seat_fp" ) );
	seat_0 LinkTo( shuttle );
	
	seat_1 = spawn_anim_model( "infil_shuttle_chair1", shuttle GetTagOrigin( "tag_seat_001" ) );
	seat_1 LinkTo( shuttle );

	seat_2 = spawn_anim_model( "infil_shuttle_chair2", shuttle GetTagOrigin( "tag_origin_002" ) );
	seat_2 LinkTo( shuttle );

	seat_3 = spawn_anim_model( "infil_shuttle_chair3", shuttle GetTagOrigin( "tag_seat_003" ) );
	seat_3 LinkTo( shuttle );

	seat_4 = spawn_anim_model( "infil_shuttle_chair4", shuttle GetTagOrigin( "tag_origin_003" ) );
	seat_4 LinkTo( shuttle );

	seat_5 = spawn_anim_model( "infil_shuttle_chair5", shuttle GetTagOrigin( "tag_seat_005" ) );
	seat_5 LinkTo( shuttle );

	seat_6 = spawn_anim_model( "infil_shuttle_chair6", shuttle GetTagOrigin( "tag_origin_006" ) );
	seat_6 LinkTo( shuttle );

	seat_7 = spawn_anim_model( "infil_shuttle_chair7", shuttle GetTagOrigin( "tag_seat_007" ) );
	seat_7 LinkTo( shuttle );
	
//	for( i = 1; i < 8; i++ )
//	{
//		seat_1 = Spawn( "script_model", shuttle GetTagOrigin( "tag_seat_00" + i ) );
//		seat_1 SetModel( "vehicle_space_shuttle_seat" );
//		seat_1.angles = shuttle GetTagAngles( "tag_seat_00" + i );
//		seat_1 LinkTo( shuttle, "tag_seat_00" + i, ( 0, 0, 0 ), ( 0, 90, 0 ) );
//	}
	
	player_rig = spawn_anim_model( "player_rig", shuttle GetTagOrigin( "tag_seat_fp" ) );
	player_rig.angles = shuttle GetTagAngles( "tag_seat_fp" );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 32, 32, 32, 32, 1 );
	
	thread infil_ally( start_node, level.allies[ 0 ], "cover_one_ally0_node1" );
	thread infil_ally( start_node, level.allies[ 1 ], "cover_one_ally1_node1" );
	thread infil_ally( start_node, level.allies[ 2 ], "cover_one_ally2_node1" );
	
	level.redshirts = create_redshirts();
	foreach( redshirt in level.redshirts )
		start_node thread maps\_anim::anim_single_solo( redshirt, "infil" );
	
//	start_node thread maps\_anim::anim_single_solo( seat_0, "infil" );
//	start_node thread maps\_anim::anim_single_solo( seat_1, "infil" );
	
	guys			  = [];
	guys[ "player"	] = player_rig;
	guys[ "shuttle" ] = shuttle;
	
	start_node maps\_anim::anim_single( guys, "infil" );

	player_rig Delete();
	level.player Unlink();
	level.player FreezeControls( false );
	level.player EnableWeapons();
	level.player ShowViewModel();

	flag_set( "infil_done" );

	ais = maps\loki_combat_one::cool_spawn( "combat_one_wave1_top", 5 );
	foreach( ai in ais )
		ai thread maps\loki_combat_one::enemy_attack_player_when_in_open();
	flag_set( "first_wave_spawned" );
}

infil_ally( start_node, guy, goal_node )
{
	self endon( "death" );
	
	goal_node = GetNode( goal_node, "targetname" );
	guy SetGoalNode( goal_node );
	guy set_force_color( "r" );
	guy.ignoresuppression = 0;
	// health

	start_node maps\_anim::anim_single_solo( guy, "infil" );
}

create_redshirts()
{
	redshirts = [];
	redshirts[ 0 ] = spawn_space_ai_from_targetname( "infil_redshirt_0" );
	redshirts[ 0 ].animname = "redshirt_0";
	redshirts[ 0 ].first_goal_node = "cover_one_redshirt0_node1";
	redshirts[ 1 ] = spawn_space_ai_from_targetname( "infil_redshirt_1" );
	redshirts[ 1 ].animname = "redshirt_1";
	redshirts[ 1 ].first_goal_node = "cover_one_redshirt1_node1";
	redshirts[ 2 ] = spawn_space_ai_from_targetname( "infil_redshirt_2" );
	redshirts[ 2 ].animname = "redshirt_2";
	redshirts[ 2 ].first_goal_node = "cover_one_redshirt2_node1";
	redshirts[ 3 ] = spawn_space_ai_from_targetname( "infil_redshirt_3" );
	redshirts[ 3 ].animname = "redshirt_3";
	redshirts[ 3 ].first_goal_node = "cover_one_redshirt3_node1";

	foreach( redshirt in redshirts )
	{
		redshirt.ignoresuppression = 0;
		redshirt.forcesuppression = 1;
		redshirt set_force_color( "r" );
		redshirt.health = 300;
		
		goal_node = GetNode( redshirt.first_goal_node, "targetname" );
		redshirt SetGoalNode( goal_node );
	}
	
	return redshirts;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infil_shuttle_movement()
{
	level.shuttle = GetEnt ( "infil_shuttle", "targetname" );
	shuttle_platform = GetEnt ( "shuttle_platform", "targetname" );
	infil_shuttle_vehicle = GetEnt ( "infil_shuttle_vehicle", "targetname" );
	
	level.shuttle LinkTo( infil_shuttle_vehicle );
	shuttle_platform LinkTo( level.shuttle );
	infil_start_node = GetVehicleNode ( "infil_start_node", "targetname" );	
	infil_shuttle_vehicle AttachPath ( infil_start_node );
	infil_shuttle_vehicle gopath();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infil_shuttle_squad_attach_detach()
{
	shuttle_platform	  = GetEnt ( "shuttle_platform", "targetname" );
	player_shuttle_attach = Spawn( "script_model", level.player.origin );
	ally_0_shuttle_attach = Spawn( "script_model", level.allies[ 0 ].origin );
	ally_1_shuttle_attach = Spawn( "script_model", level.allies[ 1 ].origin );
	ally_2_shuttle_attach = Spawn( "script_model", level.allies[ 2 ].origin );
	
	shuttle_platform SetModel( "tag_origin" );
	player_shuttle_attach SetModel( "tag_origin" );
	ally_0_shuttle_attach SetModel( "tag_origin" );
	ally_1_shuttle_attach SetModel( "tag_origin" );
	ally_2_shuttle_attach SetModel( "tag_origin" );
	
	player_shuttle_attach LinkTo( shuttle_platform, "tag_origin", ( -56, -200, 68 ), ( 0, 0, 0 ) );
	ally_0_shuttle_attach LinkTo( shuttle_platform, "tag_origin", ( 56, -200, 68 ), ( 0, 0, 0 )  );
	ally_1_shuttle_attach LinkTo( shuttle_platform, "tag_origin", ( -56, -50, 68 ), ( 0, 0, 0 )  );
	ally_2_shuttle_attach LinkTo( shuttle_platform, "tag_origin", ( 56, -50, 68 ), ( 0, 0, 0 )  );
	
	level.allies[ 0 ] LinkTo( ally_0_shuttle_attach, "tag_origin" );
	level.allies[ 1 ] LinkTo( ally_1_shuttle_attach, "tag_origin" );
	level.allies[ 2 ] LinkTo( ally_2_shuttle_attach, "tag_origin" );
	level.player PlayerLinkToDelta( player_shuttle_attach, "tag_origin" );
	
	wait( 5.0 );
	// not working
	shuttle_platform MoveZ( 100, 3 );
	
	wait( 12.0 );
	
	player_shuttle_attach Unlink();
	ally_0_shuttle_attach Unlink();
	ally_1_shuttle_attach Unlink();
	ally_2_shuttle_attach Unlink();
	
	player_combat_one_start = GetEnt( "combat_one", "targetname" );
	ally_0_combat_one_start = GetStruct( "combat_one_ally_0", "targetname" );
	ally_1_combat_one_start = GetStruct( "combat_one_ally_1", "targetname" );
	ally_2_combat_one_start = GetStruct( "combat_one_ally_2", "targetname" );
	
	player_shuttle_attach MoveTo( player_combat_one_start.origin, 7, .1, 2 );
	ally_0_shuttle_attach MoveTo( ally_0_combat_one_start.origin, 7, .1, 2 );
	ally_1_shuttle_attach MoveTo( ally_1_combat_one_start.origin, 7, .1, 2 );
	ally_2_shuttle_attach MoveTo( ally_2_combat_one_start.origin, 7, .1, 2 );
	
	delayThread( 4, maps\loki_combat_one::cool_spawn, "combat_one_wave1_top", 5 );
	delayThread( 7, ::flag_set, "first_wave_spawned" );
	
	wait( 7.0 );
	
	level.allies[ 0 ] Unlink();
	level.allies[ 1 ] Unlink();
	level.allies[ 2 ] Unlink();
	level.player Unlink();

	flag_set( "infil_done" );
}