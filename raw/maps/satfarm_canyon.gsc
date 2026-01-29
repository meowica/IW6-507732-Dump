#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;
#include maps\satfarm_code_heli;

canyon_init()
{
	// Relative Speed Flags
	//flag_init( "allies_stop_canyon" );
	
	level.start_point = "canyon";
	
	thread maps\satfarm_audio::checkpoint_canyon();
}

canyon_main()
{
	flag_init( "start_sparks1" );
	flag_init( "start_sparks2" );
	
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "canyon_" );
		
		// setup allies
		spawn_heroes_checkpoint( "canyon_" );
	}
	else
	{
		//get specfic ally tanks to move on
		
		//move hero tanks to new path
		thread switch_node_on_flag( level.herotanks[0], "", "switch_canyon_hero0", "canyon_path_hero0" );
		thread switch_node_on_flag( level.herotanks[1], "", "switch_canyon_hero1", "canyon_path_hero1" );
	}
	
	//thread chase_script();
	thread mortar_script();
	
	flag_wait( "satfarm_canyon_end" );
}

mortar_script()
{
	
	//thread sparks( "start_sparks1", "sparks1" );
	//thread sparks( "start_sparks2", "sparks2" );
	
	allytanks1 = spawn_vehicles_from_targetname_and_drive( "canyon_allytanks1" );
	//allytanks1 move_ally_to_mesh( "tank1_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks1 );
	wait .05;
	allytanks2 = spawn_vehicles_from_targetname_and_drive( "canyon_allytanks2" );
	//allytanks2 move_ally_to_mesh( "tank2_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks2 );
	wait .05;
	allytanks3 = spawn_vehicles_from_targetname_and_drive( "canyon_allytanks3" );
	//allytanks3 move_ally_to_mesh( "tank3_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks3 );
	wait .05;
	array_thread( level.allytanks, ::npc_tank_combat_init );
	array_thread( level.allytanks, ::tank_relative_speed, "mortar_strike_move", "satfarm_canyon_end" );
	
	allytanks1[0] thread tank_relative_speed( "mortar_strike_move", "satfarm_canyon_end", 1000, 25, 10 );
	allytanks2[0] thread tank_relative_speed( "mortar_strike_move", "satfarm_canyon_end", 2000, 25, 20 );
	allytanks3[0] thread tank_relative_speed( "mortar_strike_move", "satfarm_canyon_end", 2000, 25, 20 );
	
	radio_dialog_add_and_go( "satfarm_hqr_enemyaaturretsneed" );
	
	spawn_vehicles_from_targetname_and_drive( "canyon_a10_gun_dive");
	
	//thread train_car_fall( allytanks1[0] );
	
	wait 3;
	
	//thread mortar_strikes();
	
	flag_set( "start_sparks1" );
	
	//IPrintLnBold( "ARTILLERY FIRE INCOMING!" );
	//radio_dialogue( "gnr_mortarfire" );
	//wait 2;
	//IPrintLnBold( "MOVE! MOVE!" );
	//radio_dialogue( "alt_punchit" );
	
	//allytanks2[0] DoDamage( allytanks2[0].health * 3, allytanks2[0].origin );
	//allytanks3[0] DoDamage( allytanks3[0].health * 3, allytanks3[0].origin );
	
	wait 3;
	
	allytanks = spawn_vehicles_from_targetname_and_drive( "complex_allies1" );
	//allytanks move_ally_to_mesh( "tank1_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks );
	wait .05;
	allytanks = spawn_vehicles_from_targetname_and_drive( "complex_allies2" );
	//allytanks move_ally_to_mesh( "tank2_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks );
	wait .05;
	allytanks = spawn_vehicles_from_targetname_and_drive( "complex_allies3" );
	//allytanks move_ally_to_mesh( "tank3_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks );
	wait .05;
	array_thread( level.allytanks, ::npc_tank_combat_init );
	
	helis = spawn_vehicles_from_targetname_and_drive( "apache_ally_spawner2" );
	
}

train_car_fall( tank )
{
	flag_wait( "train_fall" );
	
	traincar 		= getent( "traincar_fall", "targetname" );
	traincar_col 	= getent( "traincar_fall_col", "targetname" );
	traincar_to 	= getstruct( "traincar_fall_to", "targetname" );
	
	traincar 		RotatePitch( -10, 1, .25, .5 );
	traincar_col	RotatePitch( -10, 1, .25, .5 );
	EarthQuake( .4, .5, level.player.origin, 512 );
	PlayRumbleOnPosition( "damage_heavy", traincar_to.origin );
	wait 2;
	
	IPrintLnBold( "IT'S COMING DOWN!" );
	
	traincar 		moveto( traincar_to.origin, 2, 0.25, 1 );
	traincar_col 	moveto( traincar_to.origin, 2, 0.25, 1 );
	wait 1;
	EarthQuake( .4, .5, level.player.origin, 512 );
	PlayRumbleOnPosition( "damage_heavy", traincar_to.origin );
	
	tank DoDamage( tank.health * 3, tank.origin );
	
	flag_set( "start_sparks2" );
	
	wait 1;
	
	tank delete();
}

sparks( flag_name, struct_name )
{
	flag_wait( flag_name );
	
	structs = getstructarray( struct_name, "targetname" );
	
	foreach( struct in structs )
	{
		//create fx tag
		fxTag 			= spawn_tag_origin();
		fxTag.origin 	= struct.origin;
		fxTag.angles	= (-90,0,0);
		
		playfxontag( getfx( "spark" ),  fxTag, "tag_origin" );
	}
}

mortar_strikes()
{	
	while( !flag( "end_art_strikes" ) )
	{
		for( i = 0; i < 3; i++ )
		{
			playerPosition	= level.player GetEye();
			playerAngles 	= level.playertank.angles;
			playerForward 	= AnglesToForward( 	playerAngles );
			playerRight 	= AnglesToRight( 	playerAngles );
			playerSpeed 	= level.playertank Vehicle_GetSpeed();
			
			//strike location
			strikePosition 	= playerPosition + ( playerForward * 2000 );
			
			//strike offset
			offsetx 		= RandomFloatRange( -1000, 1000 );
			if( offsetx < 500  && offsetx >= 0 )
				offsetx 	= RandomFloatRange( 500, 1000 );
			if( offsetx > -500 && offsetx <  0 )
				offsetx 	= RandomFloatRange( -1000, -500 );
			
			offsety 		= RandomFloatRange( -1000, 1000 );
			if( offsety < 500  && offsety >= 0 )
				offsety 	= RandomFloatRange( 500, 1000 );
			if( offsety > -500 && offsety <  0 )
				offsety 	= RandomFloatRange( -1000, -500 );
			
			strikeOffset	= ( offsetx, offsety, 2000 );
			
			//create fx tag
			fxTag 			= spawn_tag_origin();
			fxTag.origin 	= drop_to_ground( strikePosition + strikeOffset );
			fxTag.angles	= (-90,0,0);
			
			//mortar fire
			thread play_sound_in_space( "mortar_incoming_intro", fxTag.origin );
			
			wait RandomFloatRange( .25, .45 );
			
			playfxontag( getfx( "mortar" ), fxTag, "tag_origin" );
			EarthQuake( .2, .5, level.player.origin, 512 );
			thread play_sound_in_space( "mortar_explosion_intro", fxTag.origin );
			PlayRumbleOnPosition( "damage_heavy", fxTag.origin );
			
			wait RandomFloatRange( .25, .45 );
			
			fxTag Delete();
		}
		
		wait RandomFloatRange( .5, 1 );
	}
}

// Old Script

ambush_init()
{
	// Relative Speed Flags
	//flag_init( "allies_stop_canyon" );
	flag_init( "ambush_reverse" );
	
	level.start_point = "ambush";
}

ambush_main()
{
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "ambush_" );
		
		// setup allies
		spawn_heroes_checkpoint( "ambush_" );
		
		allytanks = spawn_vehicles_from_targetname_and_drive( "ambush_allytanks" );
		level.allytanks = array_combine( level.allytanks, allytanks );
		array_thread( level.allytanks, ::npc_tank_combat_init );
	}
	else
	{
		//get specfic ally tanks to move on
		foreach( ally in level.allytanks )
		{
			if( IsDefined( ally ) && ally.script_friendname == "Bryce" )
			{
				thread switch_node_on_flag( ally, "", "switch_ambush_ally2", "ambush_path_ally2" );
				level.allytank2 = ally;
			}
			else if( IsDefined( ally ) && ally.script_friendname == "Brick" )
			{
				thread switch_node_on_flag( ally, "", "switch_ambush_ally1", "ambush_path_ally1" );
				level.allytank1 = ally;
			}
		}
		
		//move hero tanks to new path
		thread switch_node_on_flag( level.herotanks[0], "", "switch_ambush_hero0", "ambush_path_hero0" );
		thread switch_node_on_flag( level.herotanks[1], "", "switch_ambush_hero1", "ambush_path_hero1" );
		//thread switch_node_on_flag( level.allytanks[0], "", "switch_ambush_ally1", "ambush_path_ally1" );
		//thread switch_node_on_flag( level.allytanks[1], "", "switch_ambush_ally2", "ambush_path_ally2" );
	}
	
	level.herotanks[0] thread tank_relative_speed( "complex_big_sat", "chase_checkpoint_hit", -500, 0, -15 );
	level.herotanks[1] thread tank_relative_speed( "complex_big_sat", "chase_checkpoint_hit", -500, 0, -15 );
	foreach( ally in level.allytanks )
	{
		if( IsDefined( ally ) && ally.script_friendname == "Bryce" || ally.script_friendname == "Brick" || 
		  ally.script_friendname == "Babe Ruth" )
		{
			ally thread tank_relative_speed( "complex_big_sat", "chase_checkpoint_hit", 1500, 15, 5 );
		}
	}
	
	//thread ambush_script();
	
	flag_wait( "satfarm_canyon_end" );
	
}

chase_script()
{
	//Chase 	
	autosave_by_name( "chase" );
	
	thread setup_satfarm_chainlink_fence_triggers();
	
	gazs 		= [];
	
	bridgeGazs 	= spawn_vehicles_from_targetname_and_drive( "chase_bridge1" );
	array_thread( bridgeGazs, ::gaz_spawn_setup );
	gazs 		= array_combine( bridgeGazs, gazs );
	array_thread( bridgeGazs, ::gaz_relative_speed, "chase_checkpoint", "chase_checkpoint_hit" );
	//array_thread( bridgeGazs, ::gaz_death_trigger );
	
	wait 5;
	
	bendGazs 	= spawn_vehicles_from_targetname_and_drive( "chase_bend1" );
	array_thread( bendGazs, ::gaz_spawn_setup );
	gazs 		= array_combine( bendGazs, gazs );
	array_thread( bendGazs, ::gaz_relative_speed, "chase_checkpoint", "chase_checkpoint_hit" );
	//array_thread( bendGazs, ::gaz_death_trigger );
	
	flag_wait( "chase_bend_hit" );
	
	bendGazs2 	= spawn_vehicles_from_targetname_and_drive( "chase_bend2" );
	array_thread( bendGazs2, ::gaz_spawn_setup );
	gazs 		= array_combine( bendGazs, gazs );
	array_thread( bendGazs2, ::gaz_relative_speed, "chase_checkpoint", "chase_checkpoint_hit" );
	//array_thread( bendGazs2, ::gaz_death_trigger );
	
	flag_wait( "chase_checkpoint_hit" );
	
	level.herotanks[0] thread tank_relative_speed( "complex_big_sat", "chase_checkpoint_hit", -500, 0, -15 );
	level.herotanks[1] thread tank_relative_speed( "complex_big_sat", "chase_checkpoint_hit", -500, 0, -15 );
	foreach( ally in level.allytanks )
	{
		if( IsDefined( ally ) && ally.script_friendname == "Bryce" || ally.script_friendname == "Brick" || 
		  ally.script_friendname == "Babe Ruth" )
		{
			ally thread tank_relative_speed( "complex_big_sat", "chase_dunes_hit", 2500, 30, 30 );
		}
	}
	
	wait 1;
	cpGazs 	= spawn_vehicles_from_targetname_and_drive( "chase_checkpoint1" );
	array_thread( cpGazs, ::gaz_spawn_setup );
	gazs 		= array_combine( cpGazs, gazs );
	array_thread( gazs, ::gaz_relative_speed, "complex_big_sat", "player_spawn_valley1" );
	//array_thread( cpGazs, ::gaz_death_trigger );
	
	flag_wait( "chase_dunes_hit" );
	
	wait 2;
	
	dunesGazs 	= spawn_vehicles_from_targetname_and_drive( "chase_dunes1" );
	array_thread( dunesGazs, ::gaz_spawn_setup );
	gazs 		= array_combine( dunesGazs, gazs );
	array_thread( dunesGazs, ::gaz_relative_speed, "complex_big_sat", "player_spawn_valley1" );
	//array_thread( dunesGazs, ::gaz_death_trigger );
	
	wait 3;
	
	rabbitGazs 	= spawn_vehicles_from_targetname_and_drive( "chase_rabbit1" );
	array_thread( rabbitGazs, ::gaz_spawn_setup );
	gazs 		= array_combine( rabbitGazs, gazs );
	array_thread( rabbitGazs, ::gaz_relative_speed, "complex_big_sat", "player_spawn_valley1" );
	//array_thread( rabbitGazs, ::gaz_death_trigger );
	
	wait 5;
	
 	rabbitGazs2	= spawn_vehicles_from_targetname_and_drive( "chase_rabbit2" );
	array_thread( rabbitGazs2, ::gaz_spawn_setup );
	gazs 		= array_combine( rabbitGazs2, gazs );
	array_thread( rabbitGazs2, ::gaz_relative_speed, "complex_big_sat", "player_spawn_valley1" );
	//array_thread( rabbitGazs2, ::gaz_death_trigger );
}

ambush_script()
{
	// Chopper mesh setup. Making another call to setup new network.
	maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "heli_nav_mesh3" );
	//thread vehicle_scripts\_m1a1_player_control::precache_tank();
	
	// Ambush
	autosave_by_name( "ambush" );
	
	enemytanksambush = spawn_vehicles_from_targetname_and_drive( "enemytankscanyonambush" );
	level.enemytanks = array_combine( enemytanksambush, level.enemytanks );
	array_thread( enemytanksambush, ::npc_tank_combat_init );
	wait .05;
	array_thread( enemytanksambush, ::set_override_offset, ( 0, 0, 128 ) );
	
	enemytanksa = spawn_vehicles_from_targetname_and_drive( "enemytankscanyona" );
	level.enemytanks = array_combine( enemytanksa, level.enemytanks );
	array_thread( enemytanksa, ::npc_tank_combat_init );
	wait .05;
	array_thread( enemytanksa, ::set_override_offset, ( 0, 0, 128 ) );
	
	thread ambush_kill_ally();
	wait 3;
	thread pop_smoke();
	
    switch_node0 = GetVehicleNode( "reverse_hero0", "targetname" );
    switch_node_now( level.herotanks[0], switch_node0 );
    
    switch_node1 = GetVehicleNode( "reverse_hero1", "targetname" );
    switch_node_now( level.herotanks[1], switch_node1 );
	
	waittilltanksdead( enemytanksambush, 3, 0, "player_spawn_valley2" );
	
	IPrintLnBold( "Move through the smoke." );
	
	flag_set( "player_move_valley1" );
	
    switch_node0 = GetVehicleNode( "ambush_hero0", "targetname" );
    switch_node_now( level.herotanks[0], switch_node0 );
    
    switch_node1 = GetVehicleNode( "ambush_hero1", "targetname" );
    switch_node_now( level.herotanks[1], switch_node1 );
	
    wait 3;
    
	enemytanksb 	 = spawn_vehicles_from_targetname_and_drive( "enemytankscanyonb" );
	level.enemytanks = array_combine( enemytanksb, level.enemytanks );
	array_thread( level.enemytanks, ::npc_tank_combat_init );
		
	IPrintLnBold( "More up ahead." );
	
	waittilltanksdead( enemytanksa, 0, 0, "flag_spawn_valley3" );
	
	if( enemytanksb.size == 3 )
		waittilltanksdead( enemytanksb, 1, 0, "flag_spawn_valley3" );
	
	flag_set( "player_spawn_valley3" );
	
	foreach( enemy in enemytanksb )
	{
		if( IsDefined( enemy ) && enemy.classname != "script_vehicle_corpse" )
		{
			enemy.veh_pathdir = "reverse";
			enemy Vehicle_SetSpeed( 30, 25, 25 );
		}
	}
	
	IPrintLnBold( "Enemies reversing! Follow them." );
	
	wait 2;
	
	helis = spawn_hind_enemies( 3, "heli_nav_mesh_start3" );
	
	wait 3;
	
	IPrintLnBold( "Helis incoming!" );
	
	waittillhelisdead( helis );
	
	IPrintLnBold( "Helis down. The sat complex is up ahead." );
	
	flag_set( "player_move_valley2" );
	
	autosave_by_name( "endvalley" );
}

ambush_kill_ally()
{	
	foreach( ally in level.allytanks )
		if( IsDefined( ally ) && ( ally.script_friendname == "Brick" || ally.script_friendname == "Babe Ruth" ) )
		{
			array_thread( level.enemytanks, ::set_override_target, ally );
			ally thread set_one_hit_kill();
		
			if( IsDefined( ally ) && ally.classname != "script_vehicle_corpse" )
			{
				level.enemytanks[0] fire_now_on_vehicle( ally );
			
				if( IsDefined( ally ) && ally.classname != "script_vehicle_corpse" )
				{
					flag_wait( "kill_ally_now" );
				
					if( IsDefined( ally ) && ally.classname != "script_vehicle_corpse" )
						ally kill();
				}
			}
		}
		
	IPrintLnBold( "Ambush!" );
}

pop_smoke()
{
	wait .5;
	
	IPrintLnBold( "Pop the smoke!" );
	
	wait .5;
			
	smokeLocations = getstructarray( "ambush_smoke_screen", "targetname" );
	
	flag_set( "ambush_reverse" );
	
	foreach( smoke in smokeLocations )
	{
		//level.herotanks[0]	vehicle_scripts\_m1a1_player_control::launch_smoke( smoke.origin );
		//level.herotanks[1]	vehicle_scripts\_m1a1_player_control::launch_smoke( smoke.origin );
		level.playertank 	launch_smoke( smoke.origin );
		PlayFX( getfx( "smokescreen" ), smoke.origin );
		wait randomfloatRange( .05, .25 );
	}
	
	IPrintLnBold( "Reverse!" );
}

c17_drops()
{
	//allyc17_right = spawn_anim_model( "allyc17_right" );
	//sat_farm_intro_org thread anim_single( intro_ents, "intro" );
	//allyc17_right thread allyc17_right_waits();
}

allyc17_right_waits()
{
	self waittillmatch( "single anim", "end" );
	
	wait( 0.05 );
	
	self Delete();
}
