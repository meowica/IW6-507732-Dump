#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\_anim;
#include maps\cornered_binoculars;
#include maps\cornered_lighting;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GARDEN
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

cornered_garden_pre_load()
{
	flag_init( "garden_finished" );
	
	// garden
	flag_init( "garden_spawn_first_enemies" );
	flag_init( "garden_player_in_garden" );	
	flag_init( "garden_baker_to_105" );
	flag_init( "garden_baker_to_110" );
	flag_init( "garden_baker_to_115" );
	flag_init( "garden_baker_to_120" );
	flag_init( "garden_baker_to_125" );
	flag_init( "garden_baker_to_130" );
	flag_init( "garden_rorke_to_105" );
	flag_init( "garden_rorke_to_110" );
	flag_init( "garden_rorke_to_115" );
	flag_init( "garden_rorke_to_120" );
	flag_init( "garden_rorke_to_125" );
	flag_init( "garden_rorke_to_130" );	
	
	level.garden_IDF_yellow_needed = 0; // yellow IDF head down the far left
	level.garden_IDF_orange_needed = 0; // orange IDF head down the middle
	level.garden_IDF_guys_yellow = [];
	level.garden_IDF_guys_orange = [];
	
	level.garden_enemies_cyan_needed = 0; // cyan are on the platform/right
	level.garden_enemies_yellow_needed = 0; // yellow are on the left/ground level
	level.garden_enemy_guys_yellow = [];
	level.garden_enemy_guys_cyan = [];
	
	level.yellow_enemy_replenishers = [];
	level.current_yellow_enemy_replenisher = undefined;
}

setup_garden()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	setup_player();
	spawn_allies();
	thread handle_intro_fx();
	thread maps\cornered_audio::aud_check( "garden" );
	
	flag_set( "fx_screen_raindrops" );
	thread maps\cornered_fx::fx_screen_raindrops();
	do_specular_sun_lerp( true );
	
	//level.player give_binoculars();
	//level.player binoculars_set_vision_set( "cornered_laser_tagger" );
	//level.player binoculars_enable_zoom( false );

	//level.player SwitchToWeapon( "mp5_silencer_eotech" );
	level.player SwitchToWeapon( "kriss+eotechsmg_sp+silencer_sp" );
	
	delete_building_glow();

	maps\cornered_rappel::setup_garden_entry();
	maps\cornered_rappel::combat_rappel_spawn_garden_entry_enemies();
	waitframe();

	maps\cornered_rappel::combat_rappel_garden_entry();
}

begin_garden()
{
	//--use this to run your functions for an area or event.--
	thread garden_transient_sync();
	
 	thread garden_entity_cleanup();
 	thread fireworks_garden();
	
	thread handle_garden();
	flag_wait( "garden_finished" );
}

fireworks_garden()
{
	trigger = GetEnt( "trig_grdn_enter", "targetname" );
	trigger waittill( "trigger" );
	
	thread fireworks_start( "garden" );
	
	flag_wait( "go_to_stairwell" );
	
	fireworks_stop();
}

// ensure sync of previously loaded cornered_end_tr
garden_transient_sync()
{
	// before HVT office
	flag_wait( "garden_transient_sync" );	
	while ( !synctransients() )
	{
		wait( 0.01 );
	}
}

// high from any checkpoint: 1889, 92%;
// high from beginning of map: 1944, 95% -- during rappel
// start of player_in_garden current: 1802, 88%;
// end of garden current: <1890, 93%;
// rest of map current: 1880

garden_entity_cleanup()
{
	// entities from cornered_food_court_script.map
	get_verify_and_delete_ent( "office_a_chopper", "targetname" );
	get_verify_and_delete_ent( "courtyard_reception_office_a_chopper", "targetname" );
	
	get_verify_and_delete_ent_array( "stealth_broken_backup", "targetname" );
	get_verify_and_delete_ent_array( "courtyard_intro_guys", "targetname" );
	get_verify_and_delete_ent_array( "courtyard_panel_fix_guys", "targetname" );
	get_verify_and_delete_ent_array( "courtyard_catwalk_background_guys", "targetname" );
	
	// entities from cornered_scripts_rappel.map:
	get_verify_and_delete_ent( "cr_rorke_side", "targetname" );
	get_verify_and_delete_ent( "cr_baker_side", "targetname" );	
	get_verify_and_delete_ent( "p1_junction_volume", "targetname" );	
	get_verify_and_delete_ent( "baker_out_combat", "targetname" );	
	get_verify_and_delete_ent( "baker_center_combat", "targetname" );	
	get_verify_and_delete_ent( "baker_in_combat", "targetname" );	
	get_verify_and_delete_ent( "rorke_out_combat", "targetname" );	
	get_verify_and_delete_ent( "rorke_center_combat", "targetname" );		
	get_verify_and_delete_ent( "rorke_in_combat", "targetname" );		
	get_verify_and_delete_ent( "p1_upper_volume", "targetname" );		
	get_verify_and_delete_ent( "p1_lower_volume", "targetname" );		
	get_verify_and_delete_ent( "copymachine_window_event_volume", "targetname" );		
	get_verify_and_delete_ent( "rappel_combat_two_volume_downstairs", "targetname" );		
	get_verify_and_delete_ent( "rappel_combat_two_volume_upstairs", "targetname" );		
	get_verify_and_delete_ent( "grenade_volume", "targetname" );		
	get_verify_and_delete_ent( "copier_dude", "targetname" );		
	get_verify_and_delete_ent( "copymachine_clip", "targetname" );			
	get_verify_and_delete_ent( "lower_drone", "targetname" );
	get_verify_and_delete_ent( "p2_second_wave_upstairs", "targetname" );
	get_verify_and_delete_ent( "player_rappel_angles_combat", "targetname" );
	get_verify_and_delete_ent( "player_rappel_ground_ref_combat", "targetname" );
	get_verify_and_delete_ent( "player_rappel_ground_ref_upside_down", "targetname" );
	get_verify_and_delete_ent( "player_rappel_trigger", "targetname" );
		
	get_verify_and_delete_ent_array( "p1_ahead_volume", "targetname" );		
	get_verify_and_delete_ent_array( "enemies_above_junction_floor", "targetname" );
	get_verify_and_delete_ent_array( "enemies_above_upper_floor", "targetname" );
	get_verify_and_delete_ent_array( "enemies_above_lower_floor", "targetname" );
	get_verify_and_delete_ent_array( "enemies_above_ahead_floor", "targetname" );
	get_verify_and_delete_ent_array( "hallway_talker_drone", "targetname" );
	get_verify_and_delete_ent_array( "hallway_runner_drone", "targetname" );
	get_verify_and_delete_ent_array( "lower_drone_runners", "targetname" );
	get_verify_and_delete_ent_array( "p2_first_wave_upstairs", "targetname" );
	get_verify_and_delete_ent_array( "p2_first_wave_downstairs", "targetname" );
	get_verify_and_delete_ent_array( "p2_second_wave_downstairs", "targetname" );
}

get_verify_and_delete_ent( value, key )
{
	ent_to_remove = getEnt( value, key );
	if( IsDefined( ent_to_remove ) )
	{
		ent_to_remove Delete();
	}
}

get_verify_and_delete_ent_array( value, key )
{
	ents_to_remove = GetEntArray( value, key );
	if( IsDefined( ents_to_remove ) )
	{
		foreach( ent in ents_to_remove )
		{
			ent Delete();
		}
	}
}

handle_garden()
{
	thread battlechatter_on( "allies" );
	thread battlechatter_on( "axis" );

	thread garden_gameplay();
	
	flag_wait( "garden_finished" );// -- handled by a trigger_multiple_flag_set in the .map file	
	thread garden_enemies_delete();
}

//Allies
garden_gameplay()
{		
	flag_wait( "garden_spawn_first_enemies" );

	// grab any currently existing enemy AI to be deleted once the player is in the garden
	enemies_to_be_deleted = GetAIArray( "axis" );
		
	pre_garden_spawn();
	
	level.allies[ level.const_rorke] enable_ai_color();
	level.allies[ level.const_baker] enable_ai_color();	
		
	flag_wait( "garden_player_in_garden" );	

	// clean up any guys that might be lingering around
	foreach( guy in enemies_to_be_deleted )
	{
		if ( IsDefined( guy ) && IsAlive( guy ) && !IsDefined( guy.entry ) )
			guy delete();
	}
	
	level.allies[ level.const_baker] thread garden_baker_movement();
	level.allies[ level.const_rorke] thread garden_rorke_movement();
	level thread garden_platform_enemies();
	level thread garden_left_path_enemies();	
	level thread garden_right_path_enemies();
	level thread garden_left_to_right_enemy_motion();
	level thread garden_fallback_enemies();
	level thread garden_window_break();
	level thread garden_vo();
	level thread garden_turn_off_rain_fx();
	do_specular_sun_lerp( false );
	
	//	Hand off to rescue section
	//flag_wait( "go_to_stairwell" );
	//flag_set( "garden_finished" );

}

pre_garden_spawn()
{
	// spawn in the enemies that will be there upon the player's arrival
	array_spawn_targetname( "pre_garden_spawners_enemies", true );
}

// self is baker
garden_baker_movement()
{
	baker_triggers = GetEntArray( "baker_triggers", "script_noteworthy" );
	array_thread( baker_triggers, ::trigger_off );
	
	triggers_100s = GetEntArray( "garden_baker_r100s", "targetname" );
	array_thread( triggers_100s, ::trigger_on );

	flag_wait( "garden_baker_to_105" );

	array_thread( triggers_100s, ::delete_wrapper );
	
	triggers_105s = GetEntArray( "garden_baker_r105s", "targetname" );
	array_thread( triggers_105s, ::trigger_on );
	
	flag_wait( "garden_baker_to_110" );
	
	array_thread( triggers_105s, ::delete_wrapper );

	triggers_110s = GetEntArray( "garden_baker_r110s", "targetname" );
	array_thread( triggers_110s, ::trigger_on );

	flag_wait( "garden_baker_to_115" );

	array_thread( triggers_110s, ::delete_wrapper );

	triggers_115s = GetEntArray( "garden_baker_r115s", "targetname" );
	array_thread( triggers_115s, ::trigger_on );
	
	flag_wait( "garden_baker_to_120" );

	array_thread( triggers_115s, ::delete_wrapper );

	triggers_120s = GetEntArray( "garden_baker_r120s", "targetname" );
	array_thread( triggers_120s, ::trigger_on );
	
	flag_wait( "garden_baker_to_125" );

	array_thread( triggers_120s, ::delete_wrapper );

	triggers_125s = GetEntArray( "garden_baker_r125s", "targetname" );
	array_thread( triggers_125s, ::trigger_on );
	
	flag_wait( "garden_baker_to_130" );
	
	array_thread( triggers_125s, ::delete_wrapper );
}
 
// self is rorke
garden_rorke_movement()
{
	rorke_triggers = GetEntArray( "rorke_triggers", "script_noteworthy" );
	array_thread( rorke_triggers, ::trigger_off );
	
	triggers_100s = GetEntArray( "garden_rorke_g100s", "targetname" );
	array_thread( triggers_100s, ::trigger_on );

	flag_wait( "garden_rorke_to_105" );

	array_thread( triggers_100s, ::delete_wrapper );
	
	triggers_105s = GetEntArray( "garden_rorke_g105s", "targetname" );
	array_thread( triggers_105s, ::trigger_on );
	
	flag_wait( "garden_rorke_to_110" );
	
	array_thread( triggers_105s, ::delete_wrapper );

	triggers_110s = GetEntArray( "garden_rorke_g110s", "targetname" );
	array_thread( triggers_110s, ::trigger_on );

	flag_wait( "garden_rorke_to_115" );

	array_thread( triggers_110s, ::delete_wrapper );
	

	triggers_115s = GetEntArray( "garden_rorke_g115s", "targetname" );
	array_thread( triggers_115s, ::trigger_on );
	
	flag_wait( "garden_rorke_to_120" );

	array_thread( triggers_115s, ::delete_wrapper );

	triggers_120s = GetEntArray( "garden_rorke_g120s", "targetname" );
	array_thread( triggers_120s, ::trigger_on );
	
	flag_wait( "garden_rorke_to_125" );

	array_thread( triggers_120s, ::delete_wrapper );
/*
	triggers_125s = GetEntArray( "garden_rorke_g125s", "targetname" );
	array_thread( triggers_125s, ::trigger_on );
	
	flag_wait( "garden_rorke_to_130" );
	
	array_thread( triggers_125s, ::trigger_off );
*/	
}

garden_platform_enemies()
{	
	// if the number of AI in the room drops below threshold or if the player crosses a trigger, spawn the guys on the platform
	enemy_threshold = 7;
	while ( 1 )
	{
		enemies = GetAIArray( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		if( flag( "garden_spawn_platform_enemies" ) || flag( "garden_player_under_platform" ) ) // set in map
		{
			break;
		}
		wait( 0.1 );
	}

	array_spawn_function_targetname( "garden_platform_spawner", ::garden_platform_spawnfunc );
	array_spawn_targetname( "garden_platform_spawner", true );

	flag_wait_any( "garden_platform_enemies_accurate", "garden_player_under_platform" ); // set in map

	initial_volume = GetEnt( "vol_garden_platform_far", "targetname" );
	enemies = initial_volume get_ai_touching_volume( "axis" );
	fight_volume = GetEnt( "vol_garden_platform_fight", "targetname" );

	foreach( guy in enemies )
	{
		guy.baseaccuracy = 1;
	}

	level thread garden_platform_spawn_fallback_guys();
	
	flag_wait_any( "garden_platform_enemies_retreat", "garden_player_under_platform" ); // set in map

	enemies = initial_volume get_ai_touching_volume( "axis" );
	foreach( guy in enemies )
	{
		guy SetGoalVolumeAuto( fight_volume );
	}
	
	flag_wait_any( "garden_spawn_platform_fill", "garden_player_under_platform" );

	thread autosave_tactical();
	
	if( !flag( "garden_player_under_platform" ))
	{
		// if there are fewer than 3 guys on the platform when the player arrives, spawn in a few below to run up the stairs
		max_platform_enemies = 6;
		enemies = fight_volume get_ai_touching_volume( "axis" );
		platform_fill_spawners = GetEntArray( "garden_platform_fill_spawner", "targetname" );
		for( i=0; i < (max_platform_enemies - enemies.size); i++ )
		{
			platform_fill_spawners[i] spawn_ai( true );
		}
		
		wait( 6.0 );
		
		enemy_threshold = 2;	
		while ( 1 )
		{
			enemies = fight_volume get_ai_touching_volume( "axis" );
			if( enemies.size < enemy_threshold )
			{
				break;
			}
			if( flag( "garden_player_under_platform" ) )
			{
				break;
			}
			wait( 0.5 );
		}
	}
	
	thread autosave_tactical();
	
	platform_retreat_volume = GetEnt( "vol_garden_back_right", "targetname" );
	foreach( guy in enemies )
	{
		guy SetGoalVolumeAuto( platform_retreat_volume );
	}
}
 
garden_platform_spawnfunc()
{	
	self.baseaccuracy = 0;
}

garden_platform_spawn_fallback_guys()
{
	level endon( "garden_player_under_platform" );
	level endon( "garden_enemies_fallback" );
	
	flag_wait( "garden_platform_spawn_fallback_guys" );

	fallback_area_spawners = GetEntArray( "garden_fallback_spawner", "targetname" );
	
	num_fallback_area_runners = 4;
	activity_volume = GetEnt( "vol_garden_activity_from_platform", "targetname" );
	
	for( i=0; i < num_fallback_area_runners; i++ )
	{
		guy = fallback_area_spawners[i] spawn_ai( true );
		guy SetGoalVolumeAuto( activity_volume );
	}
}
	
garden_left_path_enemies()
{
	// if there are under threshold enemies in vol_garden_left_stairs, have them fallback to vol_garden_path_left
	// and spawn in the reinforcements

	level endon( "garden_enemies_fallback" );
	
	wait( 5 ); // start checking after a few seconds to give guys time to arrive
	
	enemy_threshold = 2;
	close_volume = GetEnt( "vol_garden_left_stairs", "targetname" );	
	while ( 1 )
	{
		enemies = close_volume get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		wait( 0.5 );
	}	

	left_mid_front = GetEnt( "vol_garden_left_mid_front", "targetname" );
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( left_mid_front );
	}

	flag_set( "garden_baker_to_105" );
	activate_trigger_with_targetname( "garden_r105" ); // move baker

	thread autosave_tactical();
	
	if( enemies.size < 3 )
	{
		array_spawn_targetname( "left_mid_front_spawner", true );
	}	
	
	wait( 8 );
	enemy_threshold = 2;	
	while ( 1 )
	{
		enemies = left_mid_front get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		wait( 0.5 );
	}		
	
	left_volume = GetEnt( "vol_garden_path_left", "targetname" );
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( left_volume );
	}	
	
	flag_set( "garden_baker_to_110" );
	activate_trigger_with_targetname( "garden_r110" ); // move baker

	thread autosave_tactical();	
	
	if( enemies.size < 3 )
	{
		array_spawn_targetname( "garden_path_left_spawner", true );
	}
	
	wait( 8 );
	enemy_threshold = 2;
	while( 1 )
	{
		enemies = left_volume get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		wait( 0.5 );
	}
	
	back_left_volume = GetEnt( "vol_garden_back_left", "targetname" );
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( back_left_volume );
	}	
	
	flag_set( "garden_baker_to_115" );
	activate_trigger_with_targetname( "garden_r115" ); // move baker

	thread autosave_tactical();	
	
	if( enemies.size < 3 )
	{
		array_spawn_targetname( "garden_back_left_spawner", true );
	}

	wait( 8 );
	enemy_threshold = 3;
	fallback_volume = GetEnt( "vol_garden_last_stand_1", "targetname" );
	while( 1 )
	{
		enemies = fallback_volume get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		wait( 0.5 );
	}	

	flag_set( "garden_enemies_fallback" );
}

garden_right_path_enemies()
{
	// if there are under threshold enemies in vol_garden_left_stairs, have them fallback to vol_garden_path_left
	// and spawn in the reinforcements
	
	level endon( "garden_enemies_fallback" );
	
	wait( 5 ); // start checking after a few seconds to give guys time to arrive
	
	enemy_threshold = 2;
	close_volume = GetEnt( "vol_garden_right_stairs", "targetname" );	
	while ( 1 )
	{
		enemies = close_volume get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		if( flag( "garden_path_right_front_retreat" ) ) // set in map
		{
			break;
		}
		wait( 0.5 );
	}	

	right_mid_front = GetEnt( "vol_garden_right_mid_front", "targetname" );
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( right_mid_front );
	}

	flag_set( "garden_rorke_to_105" );
	activate_trigger_with_targetname( "garden_g105" ); // move rorke

	thread autosave_tactical();
	
	if( enemies.size < 3 )
	{
		array_spawn_targetname( "right_mid_front_spawner", true );
	}

	wait( 10 );
	enemy_threshold = 2;
	while ( 1 )
	{
		enemies = right_mid_front get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		wait( 0.5 );
	}	

	right_path = GetEnt( "vol_garden_path_right", "targetname" );
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( right_path );
	}
	
	flag_set( "garden_rorke_to_110" );
	activate_trigger_with_targetname( "garden_g110" ); // move rorke

	thread autosave_tactical();
	
	if( enemies.size < 3 )
	{
		array_spawn_targetname( "garden_path_right_spawner", true );		
	}

	wait( 6 );
	enemy_threshold = 2;
	while ( 1 )
	{
		enemies = right_path get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		wait( 0.5 );
	}	

	back_right = GetEnt( "vol_garden_back_right", "targetname" );
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( back_right );
	}
	
	flag_set( "garden_rorke_to_115" );
	activate_trigger_with_targetname( "garden_g115" ); // move rorke

	thread autosave_tactical();	

	if( enemies.size < 3 )
	{
		array_spawn_targetname( "garden_back_right_spawner", true );		
	}

}

garden_left_to_right_enemy_motion()
{
	initial_wait = 5.0;
	wait( initial_wait );
	left_volume = GetEnt( "vol_garden_left_stairs", "targetname" );
	right_volume = GetEnt( "vol_garden_right_stairs", "targetname" );
	far_right_volume = GetEnt( "vol_garden_right_right", "targetname" );
	while( 1 )
	{
		if( flag( "garden_platform_enemies_retreat" ) || flag( "garden_path_right_front_retreat" ) || flag( "garden_spawn_path_left_enemies" ) )
		{
			break;
		}

		left_enemies = left_volume get_ai_touching_volume( "axis" );
		right_enemies = right_volume get_ai_touching_volume( "axis" );

		if( ( left_enemies.size > 0 ) && ( left_enemies.size > right_enemies.size ) )
		{
			left_enemies[0] SetGoalVolumeAuto( far_right_volume );
		}
		else if( right_enemies.size > 0 )
		{
			right_enemies[0] SetGoalVolumeAuto( left_volume );
		}
		else
		{
			break; // no enemies!
		} 
		wait( 3 );
	}
}

garden_back_enemy_motion()
{
	initial_wait = 5.0;
	wait( initial_wait );
	left_volume = GetEnt( "vol_garden_back_movement", "targetname" );
	right_volume = GetEnt( "vol_garden_last_stand_2", "targetname" );
	while( 1 )
	{
		if( flag( "garden_baker_to_130" ) )
		{
			break;
		}

		left_enemies = left_volume get_ai_touching_volume( "axis" );
		right_enemies = right_volume get_ai_touching_volume( "axis" );

		if( ( left_enemies.size < 2 ) && ( right_enemies.size > 2 ) )
		{
			right_enemies[0] SetGoalVolumeAuto( left_volume );
		}
		else if( left_enemies.size > 0 )
		{
			left_enemies[0] SetGoalVolumeAuto( right_volume );
		} 
		wait( 3 );
	}
}
	
garden_fallback_enemies()
{
	flag_wait( "garden_enemies_fallback" );

	first_fallback_volume = GetEnt( "vol_garden_last_stand_1", "targetname" );
	
	// all enemies fall back to vol_garden_last_stand
	enemies = GetAIArray( "axis" );
/*	
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( first_fallback_volume );
	}
*/
	thread garden_staggered_fallback( enemies, first_fallback_volume );

	flag_set( "garden_baker_to_120" ); // needs to happen sooner
	flag_set( "garden_rorke_to_120" );		
	activate_trigger_with_targetname( "garden_r120" ); // move baker	
	activate_trigger_with_targetname( "garden_g120" ); // move rorke

	max_fallback_enemies = 6;
	enemies = GetAIArray( "axis" );
	enemies_in_fallback_volume = first_fallback_volume get_ai_touching_volume( "axis" );
	garden_fallback_spawners = GetEntArray( "garden_fallback_spawner", "targetname" );
	for( i=0; i < ( max_fallback_enemies - enemies_in_fallback_volume.size ); i++ )
	{
		guy = garden_fallback_spawners[i] spawn_ai( true );
		guy SetGoalVolumeAuto( first_fallback_volume );
	}	

	
	wait( 8 );
	
	level thread garden_back_enemy_motion();
	
	enemy_threshold = 4;
	while ( 1 )
	{
		enemies = first_fallback_volume get_ai_touching_volume( "axis" );
		if( enemies.size < enemy_threshold )
		{
			break;
		}
		wait( 0.5 );
	}
	
	final_fallback_volume = GetEnt( "vol_garden_last_stand_2", "targetname" );
	
	enemies = GetAIArray( "axis" );
/*	
	foreach( enemy in enemies )
	{
		enemy SetGoalVolumeAuto( final_fallback_volume );
	}	
*/
	thread garden_staggered_fallback( enemies, final_fallback_volume );
	
	flag_set( "garden_baker_to_125" );	
	flag_set( "garden_rorke_to_125" );	
	activate_trigger_with_targetname( "garden_r125" ); // move baker
	activate_trigger_with_targetname( "garden_g125" ); // move rorke
	
	max_fallback_enemies = 8;
	enemies = GetAIArray( "axis" );
	garden_fallback_spawners = GetEntArray( "garden_fallback_spawner", "targetname" );
	for( i=0; i < ( max_fallback_enemies - enemies.size ); i++ )
	{
		garden_fallback_spawners[i] spawn_ai( true );
	}	
	
	delayThread( 5.75, ::close_hvt_office_doors, 1.25 );
	level thread garden_move_allies_to_end();	
}

close_hvt_office_doors( time )
{
	door1 = getEnt( "hvt_office_entry_door_left", "targetname" );
	door2 = getEnt( "hvt_office_entry_door_right", "targetname" );
	
	door1_dest = getstruct( "hvt_office_entry_door_left_dest", "targetname" );
	door2_dest = getstruct( "hvt_office_entry_door_right_dest", "targetname" );
	
	door1 MoveTo( door1_dest.origin, time );
	door2 MoveTo( door2_dest.origin, time );
	
	wait( .5 );
	door1 DisconnectPaths();
	door2 DisconnectPaths();
}

// set enemies' goal volume in three groups over a short period of time
garden_staggered_fallback( enemies, volume )
{
	enemies = array_randomize( enemies );
	counter = 0;
	foreach( guy in enemies )
	{
		if( counter < ( enemies.size * .3 ) )
		{
			guy SetGoalVolumeAuto( volume );
		}
		else if( counter < ( enemies.size * .6 ) )
		{
			guy delayThread( enemies.size, ::delayed_setgoalvolumeauto, volume );
		}
		else
		{
			guy delayThread( enemies.size * 2, ::delayed_setgoalvolumeauto, volume );
		}
		counter++;
	}
}

delayed_setgoalvolumeauto( volume )
{
	self SetGoalVolumeAuto( volume );
}

garden_move_allies_to_end()
{
	level endon( "garden_finished" );
		
	enemies = GetAIArray( "axis" );
	while( enemies.size > 0 )
	{
		wait( 0.5 );
		enemies = GetAIArray( "axis" );
	}

	//--flag sets delete color triggers to prevent backtracking by allies.
	flag_set( "garden_baker_to_130" );	
	flag_set( "garden_rorke_to_130" );
	
	wait 0.1;
	
	rorke_node = GetNode( "rorke_cover_hvt", "targetname" );
	baker_node = GetNode( "baker_cover_hvt", "targetname" );
	level.allies[level.const_rorke] SetGoalNode( baker_node );
	level.allies[level.const_baker] SetGoalNode( rorke_node );
	
	waittill_ally_goals( 10 );
	level.player waittill_entity_in_range( level.allies[level.const_rorke], 150 );
	
//	--gets Rorke to run to back door.  Baker will do anim_reach in cornered_destruct::hvt_office_baker
//	activate_trigger_with_targetname( "garden_allies130" );
	
	thread autosave_tactical();
	flag_set( "garden_finished" );
}

waittill_ally_goals( timeout )
{
	baker = level.allies[level.const_baker];
	rorke = level.allies[level.const_rorke];
	
	baker thread ally_goal_mark();
	rorke thread ally_goal_mark();

	end_time = GetTime() + ( timeout * 1000 );
	
	while ( GetTime() < end_time )
	{
		baker_at_goal = IsDefined( baker.at_goal_node ) && baker.at_goal_node;
		rorke_at_goal = IsDefined( rorke.at_goal_node ) && rorke.at_goal_node;
		
		if ( baker_at_goal && rorke_at_goal )
			break;
		
		waitframe();
	}
	
	baker.at_goal_node = undefined;
	rorke.at_goal_node = undefined;
}

ally_goal_mark()
{
	self waittill( "goal" );
	self.at_goal_node = true;
}

garden_window_break()
{
	flag_wait( "garden_window_break" );
	
	glass_pane = GetEnt( "garden_glass", "targetname" );
	
	array_spawn_function_targetname( "garden_glass_breaker_spawners", ::garden_glass_room_guy_spawnfunc );
	array_spawn_targetname( "garden_glass_breaker_spawners", true );
	
	wait( 1.5 );

	breakers = getstructarray( "garden_glass_breaker_struct", "targetname" );
	foreach( breaker in breakers )
	{		
		GlassRadiusDamage( breaker.origin, 40, 100, 100 );
		random_wait = RandomFloatRange( 0.1, 0.3 );
		wait( random_wait );
	}
	
	blocker = GetEnt( "garden_glass_breaker_blocker", "targetname" );
	blocker NotSolid();
	blocker ConnectPaths();
	blocker Delete();	
}

garden_turn_off_rain_fx()
{
	flag_clear( "fx_screen_raindrops" );
	waittillframeend;
	level notify( "fx_screen_raindrops_done" );
}

garden_glass_room_guy_spawnfunc()
{
	self endon( "death" );
	
	self.ignoreall = true;
	wait( 3.0 );
	self.ignoreall = false;
}

garden_enemies_delete()
{
	wait(2);
	//Kill any remaining enemies
	enemies = GetEntArray( "garden_enemies", "script_noteworthy" );
	enemies_remaining = [];
	if ( IsDefined( enemies ) && enemies.size > 0 )
	{
		enemies_remaining = array_removeDead_or_dying( enemies );
	}

	if ( enemies_remaining.size > 0 )
	{
		foreach( ai_enemy in enemies_remaining )
		{
			ai_enemy kill();
		}
	}
}

garden_vo()
{
	//Merrick: Move!  Move!
	smart_radio_dialogue( "cornered_mrk_movemove" );
	
	flag_wait_or_timeout( "garden_spawn_platform_enemies", 4 );
	
	//Merrick: We have to get to the HVT!
	smart_radio_dialogue( "cornered_mrk_wehavetoget" );	
	
	thread garden_vo_option1();
	thread garden_vo_option2();
	level waittill( "garden_vo_option_complete" );
	
	flag_wait_or_timeout( "garden_enemies_fallback", 20 );
	
	//Merrick: We can't let Ramos get away!
	smart_radio_dialogue( "cornered_mrk_wecantletramos" );
	
	flag_wait_or_timeout( "garden_window_break", 20 );
	wait 2;
	
	//Merrick: Don't stop!  Keep moving!
	smart_radio_dialogue( "cornered_mrk_dontstopkeepmoving" );
	
	flag_wait_or_timeout( "go_to_stairwell", 20 );
	
	//Merrick: Come on!  Go!
	smart_radio_dialogue( "cornered_mrk_comeongo" );
}

garden_vo_option1()
{
	level endon( "garden_vo_option2" );
	
	flag_wait_or_timeout( "garden_player_under_platform", 21 );
	
	level notify( "garden_vo_option1" );
	
	//Merrick: Push through!
	smart_radio_dialogue( "cornered_mrk_pushthrough" );

	level notify( "garden_vo_option_complete" );
}

garden_vo_option2()
{
	level endon( "garden_vo_option1" );
	
	flag_wait_or_timeout( "garden_spawn_platform_fill", 20 );
	
	level notify( "garden_vo_option2" );
	
	//Merrick: Keep pushing!
	smart_radio_dialogue( "cornered_mrk_keeppushing" );

	level notify( "garden_vo_option_complete" );
}
