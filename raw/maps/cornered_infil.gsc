#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\cornered_code_rappel;
#include maps\cornered_code_rappel_allies;
#include maps\cornered_binoculars;
#include maps\cornered_lighting;
//#include maps\_hud_util;

cornered_infil_pre_load()
{
	//--use this to init flags or precache items for an area.--

	//Rappel movement flags - player
	flag_init( "player_moved_during_rappel" );
	flag_init( "player_jumped_during_rappel" );
	flag_init( "rappel_down_ready" );
	flag_init( "first_jump_start_stealth" );
	flag_init( "first_jump_done_stealth" );
	flag_init( "second_jump_start_stealth" );
	flag_init( "second_jump_done_stealth" );
	flag_init( "final_jump_start_stealth" );
	flag_init( "floor_clear" );
	flag_init( "force_jump" );
	flag_init( "disable_rappel_jump" );
	flag_init( "player_jumping" );
	flag_init( "player_pressed_use_button" );
	flag_init( "start_manage_player_rappel_movement" );
	flag_init( "stop_manage_player_rappel_movement" );
	flag_init( "player_allow_rappel_down" );
	flag_init( "player_moving_down" );
	
	//Rappel vertical movement flags - allies
	flag_init( "rorke_reached_combat_floor" );
	flag_init( "baker_reached_combat_floor" );
	
	//Rappel movement flags - allies
	//flag_init( "baker_secure" );
	flag_init( "team_ready" );
	//flag_init( "rorke_away" );
	//flag_init( "baker_away" );
	flag_init( "rorke_back" );
	flag_init( "baker_back" );
	flag_init( "rorke_is_moving" );
	flag_init( "baker_is_moving" );
	flag_init( "stop_anim_move" );
	flag_init( "rorke_stop_anim_move" );
	flag_init( "baker_stop_anim_move" );
	flag_init( "allies_ready_first_combat_floor" );
	flag_init( "rorke_stealth_broken" );
	flag_init( "baker_stealth_broken" );
	
	//Rappel
	flag_init( "stop_look_up_nags" );
	flag_init( "nag_reset" );
	flag_init( "nag_timeout_reset" );
	flag_init( "jump_down_nag_vo" );
	flag_init( "move_into_building" );
	
	//Rappel Stealth flags used on more than one floor
	flag_init( "intro_vo_done" );
	flag_init( "shot_at_left_guys" );
	flag_init( "shot_at_middle_guys" );
	flag_init( "shot_at_right_guys" );
	flag_init( "player_shot_in_left_volume" );
	flag_init( "player_shot_in_middle_volume" );
	flag_init( "player_shot_in_right_volume" );
	flag_init( "enemies_on_left_next" );
	flag_init( "enemies_on_right_next" );
	flag_init( "enemies_in_middle_next" );
	flag_init( "allies_stealth_behavior_end" );
	
	//Rappel stealth first floor combat
	flag_init( "player_threw_grenade" );
	flag_init( "all_clear" );
	flag_init( "first_floor_combat_weapons_free" );
	//flag_init( "player_shot" );
	flag_init( "first_floor_enemies_dead" );
	flag_init( "first_floor_patroller_1_in_place" );
	flag_init( "first_floor_first_enemy_dead" );
	flag_init( "killed_out_of_order" );
	
	//Rappel stealth first floor death flags
	flag_init( "first_floor_sitting_laptop_guy_dead" );
	flag_init( "first_floor_patroller_1_dead" );
	flag_init( "first_floor_patroller_2_dead" );
	
	//Rappel stealth second floor combat
	flag_init( "start_elevator_anims" );
	flag_init( "elevator_doors_ready_to_open" );
	flag_init( "elevator_doors_opening" );
	flag_init( "elevator_doors_open" );
	flag_init( "elevator_doors_ready_to_close" );
	flag_init( "elevator_doors_shut" );
	flag_init( "elevator_gone" );
	flag_init( "second_floor_kitchenette_guy_out_of_elevator" );
	flag_init( "second_floor_kitchenette_guy_out_middle_volume" );
	flag_init( "second_floor_kitchenette_guy_leave_elevator" );
	flag_init( "second_floor_kitchenette_guy_patrol_vo_said" );
	flag_init( "second_floor_kitchenette_guy_heading_to_kitchen" );
	flag_init( "second_floor_kitchenette_guy_in_kitchen" );
	flag_init( "second_floor_kitchenette_guy_alert_node" );
	flag_init( "second_floor_kitchenette_guy_will_be_alerted" );
	flag_init( "second_floor_kitchenette_guy_will_be_alerted_2" );
	flag_init( "second_floor_kitchenette_guy_at_stir_node" );
	flag_init( "fridge_guy_alerted_or_dead" );
	flag_init( "second_floor_fridge_guy_killed_too_soon" );
	flag_init( "second_floor_left_enemies_taken_out" );
	flag_init( "kitchen_alerted" );
	flag_init( "poker_table_alerted" );
	flag_init( "poker_table_spooked" );
	flag_init( "poker_table_enemy_1_standing" );
	flag_init( "poker_table_game_continues" );
	flag_init( "spook_fridge_guy" );
	flag_init( "second_floor_fridge_guy_spooked" );
	flag_init( "fridge_guy_leaving_fridge" );
	flag_init( "second_floor_fridge_guy_start_patrol" );
	flag_init( "second_floor_fridge_guy_end_patrol" );
	flag_init( "second_floor_fridge_guy_in_middle_volume" );
	flag_init( "second_floor_fridge_guy_leaving_kitchen" );
	flag_init( "second_floor_fridge_guy_will_be_alerted" );
	flag_init( "take_the_shot_vo" );
	flag_init( "second_floor_fridge_guy_out_of_middle_volume" );
	flag_init( "second_floor_enemies_dead" );
	flag_init( "stealth_broken_vo_said" );
	flag_init( "second_floor_stealth_broken" );
	
	//Rappel stealth second floor death flags
	flag_init( "second_floor_fridge_guy_dead" );
	flag_init( "second_floor_kitchenette_guy_dead" );
	
	flag_init( "allies_reached_target_floor" );
		
	PreCacheModel( "bo_p_glo_beer_bottle01_world" );
	
	//"Press movement keys to rappel"
	PreCacheString( &"CORNERED_RAPPEL_HINT_PC" );
	//"&&"BUTTON_MOVE" to rappel"
	PreCacheString( &"CORNERED_RAPPEL_HINT_GAMEPAD" );
	//"&&"BUTTON_LOOK" to rappel"
	PreCacheString( &"CORNERED_RAPPEL_HINT_GAMEPAD_L" );
	//"Press [{+gostand}] to jump"
	PreCacheString( &"CORNERED_RAPPEL_JUMP" );
		
	//"Press movement keys to rappel"
	add_hint_string( "rappel_movement_pc", &"CORNERED_RAPPEL_HINT_PC", ::should_break_rappel_movement_hint );
	//"&&"BUTTON_MOVE" to rappel"
	add_hint_string( "rappel_movement_gamepad", &"CORNERED_RAPPEL_HINT_GAMEPAD", ::should_break_rappel_movement_hint );
	//"Press movement keys to rappel"
	add_hint_string( "rappel_movement_gamepad_l", &"CORNERED_RAPPEL_HINT_PC", ::should_break_rappel_movement_hint );
	//"Press [{+gostand}] to jump"
	add_hint_string( "jump"	, &"CORNERED_RAPPEL_JUMP" ); //, ::should_break_rappel_jump_hint );
	
	//TEMP
	rappel_rope_stealth = GetEnt( "player_rappel_rope_stealth", "targetname" );
	rappel_rope_stealth Hide();

	level.first_floor_shift_right_trigger = GetEnt( "first_floor_shift_right_trigger", "targetname" );
	level.first_floor_shift_right_trigger trigger_off();
	
	level.laptop_destroyed = GetEnt( "laptop_sit_react_laptop_destroyed", "targetname" );
	level.laptop_destroyed Hide();
	
	level.second_floor_shift_left_trigger = GetEnt( "second_floor_shift_left_trigger", "targetname" );
	level.second_floor_shift_left_trigger trigger_off();
		
	//level.worklight_on = GetEnt( "worklight_on", "targetname" );
	//level.worklight_on Hide();
	
	flag_init( "rappel_stealth_finished" );
	
	level.rappel_rope_rig				= undefined;
	level.rappel_max_lateral_dist_right = 300;
	level.rappel_max_lateral_dist_left	= 250;
	level.rappel_max_lateral_speed		= 9.0;
	level.rappel_max_downward_speed		= 4.0;
	level.rappel_max_upward_speed		= 3.0;
	
	/#
	SetDevDvarIfUninitialized( "rappel_ignore_first_two_encounters", 0 );	// If true will ignore the first two encounters
	#/
}

rappel_ignore_first_two_encounters()
{
	/#
	if ( GetDvar( "rappel_ignore_first_two_encounters" ) == "1" )
		return true;
	#/
	
	return false;
}

setup_rappel_stealth()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	setup_player();
	spawn_allies();
	thread handle_intro_fx();
	level.rappel_stealth_checkpoint = true;
	thread maps\cornered_audio::aud_check( "rappel_stealth" );
	thread rappel_stealth();
	
	thread delete_window_reflectors();
	
	level.player thread player_flap_sleeves();
	
	flag_set( "fx_screen_raindrops" );	
	thread maps\cornered_fx::fx_screen_raindrops();
	do_specular_sun_lerp( true );
/#
	thread ally_debug_aim_blender();
#/
}

begin_rappel_stealth()
{
	//--use this to run your functions for an area or event.--
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
//	thread fireworks_stop();
	
	thread maps\cornered_audio::aud_rappel( "event1" );
	thread fireworks_stealth_rappel();
	
	flag_wait( "rappel_stealth_finished" );	
	thread autosave_tactical();
}

rappel_stealth()
{
	thread handle_rappel_stealth();
	thread rappel_stealth_combat();
	thread allies_rappel_stealth_vo();
	
	//waitframe();
	level.ally_zipline_count		 = 0;
	level.reached_target_floor_count = 0;
	level.allies[ level.const_rorke ] thread allies_rappel_stealth_anims();
	level.allies[ level.const_baker ] thread allies_rappel_stealth_anims();
}

player_move_on_rappel_hint()
{	
	config = GetSticksConfig();
//	IPrintLn( config );
	
	if ( level.player is_player_gamepad_enabled() )
	{
		if ( config == "thumbstick_southpaw" || config == "thumbstick_legacy" )
			thread time_to_pass_before_hint( 3, "rappel_movement_gamepad_l", "player_moved_during_rappel" );
		else
			thread time_to_pass_before_hint( 3, "rappel_movement_gamepad", "player_moved_during_rappel" );
	}
	else
	{
		thread time_to_pass_before_hint( 3, "rappel_movement_pc", "player_moved_during_rappel" );
	}
	
	while ( true )
	{
		wait( 0.05 );
		movement = level.player GetNormalizedMovement();	//needs to move stick forward to learn
		if ( movement[ 0 ] < -0.1 || movement[ 0 ]																																																																																																																																																																																																																						> 0.1	  )
		if ( movement[ 0 ] < -0.1 || movement[ 0 ]																																																																																																																																																																																																															> 0.1								  )
		if ( movement[ 0 ] < -0.1 || movement[ 0 ]																																																																																																																																																																																																																							> 0.1 )
			break;
	}
	flag_set( "player_moved_during_rappel" );
}

#using_animtree( "animated_props" );
handle_rappel_stealth()
{

	if ( !IsDefined( level.zipline_anim_struct ) )
	{
		level.zipline_anim_struct = getstruct( "zipline_anim_struct", "targetname" );	
	}

	level.player thread unlimited_ammo();

	rappel_params						  = SpawnStruct();
	rappel_params.right_arc				  = 120;
	rappel_params.left_arc				  = 120;
	rappel_params.top_arc				  = 60;
	rappel_params.bottom_arc			  = 50;
	rappel_params.allow_walk_up			  = true;
	rappel_params.allow_glass_break_slide = true;
	rappel_params.allow_sprint			  = true;
	rappel_params.jump_type				  = "jump_normal";
	rappel_params.show_legs				  = true;
	rappel_params.lateral_plane			  = 1; // XZ plane
	rappel_params.rappel_type			  = "stealth";
	level.rappel_params					  = rappel_params;
	cornered_start_rappel( "rope_ref_stealth", "player_rappel_ground_ref_stealth", rappel_params );
	cornered_start_random_wind();
	
	level.player thread player_flap_sleeves();

	//level thread player_jump_on_rappel_hint();
	
	if ( !rappel_ignore_first_two_encounters() )
	{
		flag_wait( "rappel_down_ready" );
		level player_move_on_rappel_hint();
		wait( 0.5 );
		flag_clear( "rappel_down_ready" );
		flag_set( "player_allow_rappel_down" );
		thread watch_vertical_limit( "first_floor_enemies_dead", "stop_for_first_floor_combat", "stop_at_first_combat_floor_trigger" );
		flag_wait_either( "stop_for_first_floor_combat", "first_floor_enemies_dead" );
		//flag_clear( "rappel_down_ready" );
		level.rappel_max_lateral_dist_right = 500;
		level.rappel_max_lateral_dist_left	= 330;
		
		flag_wait( "rappel_down_ready" );
		wait( 0.5 );
		flag_clear( "rappel_down_ready" );
		flag_set( "player_allow_rappel_down" );
		rappel_clear_vertical_limits();
		thread watch_vertical_limit( "second_floor_enemies_dead", "stop_for_second_floor_combat", "stop_at_second_combat_floor_trigger" );
		flag_wait_either( "stop_for_second_floor_combat", "second_floor_enemies_dead" );
		//flag_clear( "rappel_down_ready" );
	}
	else
	{
		//ONLY NEED THIS HERE WHEN THE FIRST ENCOUNTER IS COMMENTED OUT
		level.rappel_max_lateral_dist_right = 500;
		level.rappel_max_lateral_dist_left	= 330;
	}
	
	flag_wait( "rappel_down_ready" );
	wait( 0.5 );
	flag_set( "player_allow_rappel_down" );
	rappel_clear_vertical_limits();
	flag_wait( "stop_for_third_floor_combat" );
	dist_player_to_top = rpl_calc_dist_player_to_top( level.rpl, true );
	rappel_limit_vertical_move( -95, dist_player_to_top );
	
	triggers = GetEntArray( "stop_at_third_combat_floor_trigger", "targetname" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}
	
	flag_wait( "allies_reached_target_floor" );
	flag_set( "rappel_stealth_finished" );
}

should_break_rappel_movement_hint()
{
	Assert( IsPlayer( self ) );

	return flag( "player_moved_during_rappel" );
}

//player_jump_on_rappel_hint()
//{	
//	flag_wait( "player_moved_during_rappel" );
//	thread time_to_pass_before_hint( 3, "jump", "player_jumped_during_rappel" );
//	level.player waittill( "playerjump" );
//	flag_set( "player_jumped_during_rappel" );
//}
//
//should_break_rappel_jump_hint()
//{
//	Assert( IsPlayer( self ) );
//
//	return flag( "player_jumped_during_rappel" );
//}

watch_vertical_limit( flag_to_end_on, flag_to_wait_on, trigger_targetname )
{
	level endon( flag_to_end_on );
	
	flag_wait( flag_to_wait_on );
	
	dist_player_to_top = rpl_calc_dist_player_to_top( level.rpl, true );
	rappel_limit_vertical_move( -125, dist_player_to_top );
	//rappel_limit_vertical_movement( -95, 0 );
	
	triggers = GetEntArray( trigger_targetname, "targetname" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}
	
}

rappel_stealth_combat()
{
	//Spawn functions for first floor enemies
								 //   key 							    func 								   
	array_spawn_function_noteworthy( "first_floor_patroller_1"		 , ::first_floor_patroller_1_setup );
	array_spawn_function_noteworthy( "first_floor_patroller_2"		 , ::first_floor_patroller_2_setup );
	array_spawn_function_noteworthy( "first_floor_sitting_laptop_guy", ::first_floor_sitting_laptop_guy_setup );
						   
	//Spawn functions for second floor enemies
								 //   key 						      func 								    
	array_spawn_function_targetname( "second_floor_enemies_poker_table"	, ::second_floor_poker_table_guys_setup );														
								 //   key 						      func 								   
	array_spawn_function_noteworthy( "second_floor_fridge_guy"	   , ::second_floor_fridge_guy_setup );
	array_spawn_function_noteworthy( "second_floor_kitchenette_guy", ::second_floor_kitchenette_guy_setup );
	array_spawn_function_noteworthy( "second_floor_elevator_guy_1" , ::second_floor_elevator_guy_setup );
	array_spawn_function_noteworthy( "second_floor_elevator_guy_2" , ::second_floor_elevator_guy_setup );
		
	if ( !rappel_ignore_first_two_encounters() )
	{
		//FIRST ENEMY ENCOUNTER
		level.first_floor_combat_enemies_right = [];
		
		flag_wait( "empty_floor_1" );
		first_floor_enemies = array_spawn_targetname( "first_floor_enemies", true );
		
		thread allies_help_when_player_shoots_first_floor();
		
		//thread player_shoots( "first_floor_shift_right" );
		
		thread check_ai_array_for_death( first_floor_enemies, "first_floor_enemies_dead" );
		
		flag_wait( "first_floor_enemies_dead" );
		flag_clear( "enemies_aware" );
		flag_clear( "player_shot_in_right_volume" );
		
		//SECOND ENEMY ENCOUNTER
		level.second_floor_anim_struct = getstruct( "second_floor_anim_struct", "targetname" );
		
		level.second_floor_left_enemies	  = [];
		level.second_floor_middle_enemies = [];
		
		second_floor_enemies			 = array_spawn_targetname( "second_floor_enemies", true );
		second_floor_enemies_poker_table = array_spawn_targetname( "second_floor_enemies_poker_table", true );
		level.second_floor_enemies		 = array_combine( second_floor_enemies, second_floor_enemies_poker_table );
		
		thread open_elevator_doors();
		thread allies_help_when_player_shoots_second_floor_left();
		thread allies_help_when_player_shoots_second_floor_middle_or_right();
		//thread rappel_stealth_second_floor_combat_stealth_broken();
		
		thread check_ai_array_for_death( level.second_floor_enemies, "second_floor_enemies_dead" );
		flag_wait( "second_floor_enemies_dead" );
		
		flag_clear( "enemies_aware" );
		flag_clear( "intro_vo_done" );
		flag_clear( "shot_at_left_guys" );
		flag_clear( "shot_at_middle_guys" );
		flag_clear( "shot_at_right_guys" );
		flag_clear( "player_shot_in_left_volume" );
		flag_clear( "player_shot_in_middle_volume" );
		flag_clear( "player_shot_in_right_volume" );
		flag_clear( "enemies_on_left_next" );
		flag_clear( "stealth_broken_vo_said" );
	}
}

////////
//FIRST ENEMY ENCOUNTER DURING STEALTH RAPPEL
////////

#using_animtree( "generic_human" );
first_floor_sitting_laptop_guy_setup()
{
	self endon( "death" );
		
	self.ignoreall	= true;
	self.animname	= "generic";
	self.allowdeath = true;
	self.diequietly = true;
	self.noragdoll	= true;
	self.health		= 50;
	self.deathanim	= %cnd_rappel_stealth_chair_death_rear;
	
	self childthread wait_till_shot( "enemies_aware", undefined, "enemy_aware" );
	self childthread alert_all();
	
	self.struct			= getstruct( self.script_noteworthy + "_struct", "targetname" );
	self.struct thread anim_loop_solo( self, "laptop_sit_idle_calm", "stop_loop" );
	
	self thread first_floor_sitting_laptop_guy_react();
}

first_floor_sitting_laptop_guy_react()
{
	self endon( "death" );
	
	chair_rig = spawn_anim_model( "laptop_sit_react_props" );
	chair_rig thread entity_cleanup( "player_entering_building" );
	laptop_rig = spawn_anim_model( "laptop_sit_react_props" );
	laptop_rig thread entity_cleanup( "player_entering_building" );

	chair = GetEnt( "laptop_sit_react_chair", "targetname" );
	chair thread entity_cleanup( "player_entering_building" );
	
	laptop = GetEnt( "laptop_sit_react_laptop", "targetname" );
	laptop SetCanDamage( true );
	laptop thread entity_cleanup( "player_entering_building" );
	laptop thread watch_for_damage();
	
	level.laptop_destroyed thread entity_cleanup( "player_entering_building" );
	
								   //   guy 	    anime 			   
	self.struct anim_first_frame_solo( chair_rig , "laptop_sit_react" );
	self.struct anim_first_frame_solo( laptop_rig, "laptop_sit_react" );
	
	chair LinkTo( chair_rig, "J_prop_1" );
	laptop LinkTo( laptop_rig, "J_prop_2" );
	level.laptop_destroyed LinkTo( laptop_rig, "J_prop_2" );
	
	level.laptop_hdr  = GetEnt( "laptop_hdr", "targetname" );
	laptop_tag_origin = laptop spawn_tag_origin();
	laptop_tag_origin LinkTo( laptop_rig, "J_prop_2" );
	level.laptop_hdr LinkTo( laptop_tag_origin, "tag_origin" );
	
	level.laptop_hdr thread entity_cleanup( "player_entering_building" );
	laptop_tag_origin thread entity_cleanup( "player_entering_building" );
	
	sitting_guy_react_array		 = [];
	sitting_guy_react_array[ 0 ] = self;
	sitting_guy_react_array[ 1 ] = chair_rig;
	
	self waittill( "enemy_aware" );
	self thread first_floor_sitting_laptop_guy_react_laptop( laptop_rig );
	self clear_deathanim();
	
	self.struct thread anim_single( sitting_guy_react_array, "laptop_sit_react" );
	wait( 2.5 );
	self.allowdeath = false;
	wait(1.0);
	self.allowdeath = true;
	
	
	self waittillmatch( "single anim", "end" );
	
	self disable_surprise();
	self.disableBulletWhizbyReaction = true;
	self.disableReactionAnims		 = true;
	self.ignoreall					 = false;
	self.noragdoll					 = false;
	self.struct notify( "stop_loop" );
	waittillframeend;
	self anim_stopanimscripted();
}

watch_for_damage()
{
	self waittill( "damage" );
	
	self Hide();
	level.laptop_hdr Hide();
	level.laptop_destroyed Show();
	PlayFXOnTag( level._effect[ "powerlines_c" ], level.laptop_destroyed, "tag_fx" );
}

first_floor_sitting_laptop_guy_react_laptop( laptop_rig )
{
	wait( 2.25 );
	if ( IsAlive( self ) )
	{
		self.struct anim_single_solo( laptop_rig, "laptop_sit_react_laptop" );
	}
}

first_floor_patroller_1_setup()
{
	self endon( "death" );
		
	self.ignoreall		  = true;
	self.animname		  = "generic";
	self.allowdeath		  = true;
	self.diequietly		  = true;
	self.health			  = 50;
	self.patrol_walk_anim = "active_patrolwalk_gundown";
	
	self thread wait_till_shot( "enemies_aware", undefined, "enemy_aware" );
	self thread alert_all();
	self thread watch_patrollers( "first_floor_patroller_2_dead" );
	
	level.first_floor_combat_enemies_right = add_to_array( level.first_floor_combat_enemies_right, self );
	self thread two_guys_talking_patrol();
	
	self waittill( "enemy_aware" );
	
	if ( flag( "first_floor_patroller_1_in_place" ) )
	{
		self notify( "stop_loop" );
		self thread anim_single_solo( self, "so_hijack_texting_reaction" );
		wait( 0.5 );

		if ( IsDefined( level.enemy_patrol_phone ) )
		{
			level.enemy_patrol_phone Delete();
		}
		self waittillmatch( "single anim", "end" );	
	}
	else
	{
		self thread anim_single_solo( self, "patrol_react" );
	}
	
	self.ignoreall = false;
	
	if ( !flag( "enemies_aware" ) )
	{
		flag_set( "enemies_aware" );
	}
}

first_floor_patroller_2_setup()
{
	self endon( "death" );
		
	self.ignoreall	= true;
	self.animname	= "generic";
	self.allowdeath = true;
	self.diequietly = true;
	self.health		= 50;
	
	self thread wait_till_shot( "enemies_aware", undefined, "enemy_aware" );
	self thread alert_all();
	self thread watch_patrollers( "first_floor_patroller_1_dead" );
	
	level.first_floor_combat_enemies_right = add_to_array( level.first_floor_combat_enemies_right, self );
	self thread two_guys_talking_patrol();
	
	self waittill( "enemy_aware" );
	if ( IsDefined( self.struct ) )
	{
		self.struct notify( "stop_loop" );
	}
	else
	{
		self notify( "stop_loop" );
	}
	waittillframeend;
	self anim_stopanimscripted();
	
	self anim_single_solo( self, "exposed_idle_reactA" );
	
	self.ignoreall = false;
	
	if ( !flag( "enemies_aware" ) )
	{
		flag_set( "enemies_aware" );
	}
}

watch_patrollers( flag_to_wait_on )
{
	self endon( "death" );
	level endon( "enemies_aware" );
	
	flag_wait( flag_to_wait_on );
	//flag_set( "enemies_aware" );
	self notify( "enemy_aware" );
}

two_guys_talking_patrol()
{
	self endon( "death" );
	self endon( "enemy_aware" );
	level endon( "enemies_aware" );
	
	if ( self.script_noteworthy == "first_floor_patroller_1" )
	{
		flag_wait( "first_floor_patroller_1_in_place" );
//		self.struct = getstruct( "first_floor_patrol_talking_struct", "targetname" );
//		self.struct thread anim_loop_solo( self, "first_floor_patroller_2", "stop_loop" );
		
		level.enemy_patrol_phone = Spawn( "script_model", ( 0, 0, 0 ) );
		level.enemy_patrol_phone LinkTo( self, "tag_inhand", ( 0, -1, 0 ), ( 0, 0, 0 ) );
		level.enemy_patrol_phone SetModel( "cnd_cellphone_01_off_anim" );
		self thread anim_loop_solo( self, "so_hijack_search_texting_loop", "stop_loop" );
		
	}
	else
	{
		self.struct = getstruct( "first_floor_patrol_talking_struct", "targetname" );
		self.struct thread anim_loop_solo( self, "first_floor_patroller_2", "stop_loop" );
	}
}

allies_help_when_player_shoots_first_floor()
{
	flag_wait( "first_floor_shift_right" );
	//flag_wait( "player_shot" );
	if ( flag( "first_floor_combat_weapons_free" ) )
	{
		volume = GetEnt( "first_floor_right_volume_player", "targetname" );
		level.player childthread watch_for_player_to_shoot_while_in_volume( volume, "player_shot_in_right_volume", "first_floor_enemies_dead" );
		level.player childthread coordinated_kills( level.allies[ level.const_rorke ], level.first_floor_combat_enemies_right, "player_shot_in_right_volume", "first_floor_enemies_dead" );
	}

}

////////
//SECOND ENEMY ENCOUNTER DURING STEALTH RAPPEL
////////
open_elevator_doors()
{
	elevator_doors		= GetEntArray( "rappel_stealth_elevator_doors", "targetname" );
	elevator_clip_right = GetEnt( "elevator_door_clip_right", "targetname" );
	elevator_clip_left	= GetEnt( "elevator_door_clip_left", "targetname" );
	
	level.door_shut_x = 0;
	level.door_open_x = 0;
		
	foreach ( door in elevator_doors )
	{
		if ( door.script_noteworthy == "right" )
		{	
			level.door_shut_x = door.origin[ 0 ];
			level.door_open_x = door.origin[ 0 ] + 58;
		}
	}
	
	flag_wait( "elevator_doors_ready_to_open" );
	foreach ( door in elevator_doors )
	{
		if ( door.script_noteworthy == "right" )
		{
			elevator_clip_right LinkTo( door );
			door MoveTo( door.origin + ( 58, 0, 0 ), 2.5, .5, .5 );
			elevator_clip_right ConnectPaths();
		}
		else
		{
			elevator_clip_left LinkTo( door );
			door MoveTo( door.origin + ( -58, 0, 0 ), 2.5, .5, .5 );
			elevator_clip_left ConnectPaths();
		}
	}
	wait( 2 );
	flag_set( "elevator_doors_open" );

	flag_wait_all( "elevator_doors_ready_to_close", "second_floor_kitchenette_guy_out_of_elevator" );
	wait( 1 );
	thread open_elevator_doors_if_stealth_broken( elevator_doors, elevator_clip_right, elevator_clip_left );
	thread close_elevator_doors( elevator_doors, elevator_clip_right, elevator_clip_left );
}

close_elevator_doors( elevator_doors, elevator_clip_right, elevator_clip_left )
{
	level endon( "second_floor_stealth_broken" );
	
	foreach ( door in elevator_doors )
	{
		if ( door.script_noteworthy == "right" )
		{
			door MoveTo( door.origin + ( -58, 0, 0 ), 2.5, .5, .5 );
			//elevator_clip_right delayThread( 2, ::DisconnectPaths );
			//elevator_clip_right DisconnectPaths();
		}
		else
		{
			door MoveTo( door.origin + ( 58, 0, 0 ), 2.5, .5, .5 );
			//elevator_clip_left delayThread( 2, ::DisconnectPaths );
			//elevator_clip_left DisconnectPaths();
		}
	}
	
	wait( 1.5 );
	elevator_clip_right DisconnectPaths();
	elevator_clip_left DisconnectPaths();
	wait( 1.5 );
	//wait( 3 );
	flag_set( "elevator_doors_shut" );
	wait( 3 );
	flag_set( "elevator_gone" );
	//elevator_clip_right Delete();
	//elevator_clip_left Delete();		
}

open_elevator_doors_if_stealth_broken( elevator_doors, elevator_clip_right, elevator_clip_left )
{
	level endon( "elevator_gone" );
	
	flag_wait( "second_floor_stealth_broken" );
	x_units_to_move = 0;
	seconds_to_move = 0;
	
	foreach ( door in elevator_doors )
	{
		if ( door.script_noteworthy == "right" )
		{	
			level.door_current_x = door.origin[ 0 ];
			x_units_to_move		 = level.door_open_x - level.door_current_x;
			
		}
	}
		
	foreach ( door in elevator_doors )
	{
		//if ( level.door_current_x > level.door_shut_x )
		//{
			if ( door.script_noteworthy == "right" )
			{	
				door MoveTo( door.origin + ( x_units_to_move, 0, 0 ), 2 );
				//elevator_clip_right ConnectPaths();
			}
			else
			{
				door MoveTo( door.origin + ( ( x_units_to_move * -1 ), 0, 0 ), 2 );
				//elevator_clip_left ConnectPaths();
			}
		//}
	}
	
	wait( 2 );
	elevator_clip_right ConnectPaths();
	elevator_clip_left ConnectPaths();
	//wait( 3 );
	//elevator_clip_right Delete();
	//elevator_clip_left Delete();
}

#using_animtree( "generic_human" );
second_floor_poker_table_guys_setup()
{
	self endon( "death" );
	
	self.ignoreall	= true;
	self.animname	= "generic";
	self.allowdeath = true;
	self.diequietly = true;
	self.noragdoll	= true;
	self.health		= 50;
	
	level.second_floor_middle_enemies = add_to_array( level.second_floor_middle_enemies, self );
	
	if ( self.script_noteworthy == "enemy_1" )
	{
		self.struct			 = getstruct( "enemy_1", "targetname" );
		self.animation		 = "enemy_1_cards_idle";
		self.interruptedanim = "enemy_1_cards_interrupted";
		self.reactanim		 = "enemy_1_cards_alert";
		self.deathanim		 = %cnd_rappel_stealth_chair_death_right;
		self thread chair_death_right();
	}
	
	if ( self.script_noteworthy == "enemy_2" )
	{
		self.struct			 = getstruct( "enemy_2", "targetname" );
		self.animation		 = "enemy_2_cards_idle";
		self.interruptedanim = "enemy_2_cards_interrupted";
		self.reactanim		 = "enemy_2_cards_alert";
		self.deathanim		 = %cnd_rappel_stealth_chair_death_rear;
	}
	
	if ( self.script_noteworthy == "enemy_3" )
	{
		self.struct			 = getstruct( "enemy_3", "targetname" );
		self.animation		 = "enemy_3_cards_idle";
		self.interruptedanim = "enemy_3_cards_interrupted";
		self.reactanim		 = "enemy_3_cards_alert";
		self.deathanim		 = %cnd_rappel_stealth_chair_death_left_1;
	}
	
	self.struct thread anim_loop_solo( self, self.animation, "stop_loop" );
	self thread poker_table_spooked();
	
	self thread wait_till_shot( "enemies_aware", undefined, "enemy_aware" );
	self thread handle_alerted();
	self thread alert_all( "poker_table_alerted", "second_floor_stealth_broken" );
	
	self.volume = GetEnt( "second_floor_middle_volume", "targetname" );
	self thread watch_for_death_and_alert_all_in_volume();
	
	self waittill( "enemy_aware" );
	self.noragdoll = false;
	self clear_deathanim();
	if ( !flag( "poker_table_alerted" ) )
	{
		flag_set( "poker_table_alerted" );
	}
}

poker_table_spooked()
{
	self endon( "death" );
	self endon( "enemy_aware" );
	
	level endon( "enemies_aware" );
	level endon( "second_floor_fridge_guy_in_middle_volume" );
	//level endon( "second_floor_fridge_guy_killed_too_soon" );
	level endon( "second_floor_enemies_dead" );
	
	flag_wait_any( "player_shot_in_left_volume", "second_floor_left_enemies_taken_out" );
	delayThread( 1, ::flag_set, "poker_table_spooked" );
	
	// player is away from the side and looking at the poker table
	volume = GetEnt( "second_floor_left_volume_player", "targetname" );
	while ( level.player IsTouching( volume ) )
		waitframe();
	table = getstruct( "enemy_2", "targetname" );
	waittill_player_looking_at_ent( table, 10 );

	self.struct notify( "stop_loop" );
	waittillframeend;
	self anim_stopanimscripted();
	
	if ( self.script_noteworthy == "enemy_1" )
	{
		self.struct thread anim_single_solo( self, self.interruptedanim );
		flag_wait( "poker_table_enemy_1_standing" );
		self.reactanim = undefined;
		self clear_deathanim();
		
		flag_waitopen( "poker_table_enemy_1_standing" );
		self.reactanim = "enemy_1_cards_alert";
		self.deathanim = %cnd_rappel_stealth_chair_death_right;
		self waittillmatch( "single anim", "end" );
		self.struct thread anim_loop_solo( self, self.animation, "stop_loop" );
	}
	else
	{
		self.struct anim_single_solo( self, self.interruptedanim );
		self.struct thread anim_loop_solo( self, self.animation, "stop_loop" );
	}
}

chair_death_right()
{
	self endon( "enemy_aware" );
	
	self waittill( "death" );
	if ( flag( "poker_table_enemy_1_standing" ) )
	{
		return;
	}
	chair = GetEnt( "chair_death_right", "targetname" );
	Assert( IsDefined( chair ) );
	chair.animname = "chair";
	chair SetAnimTree();
	
	chair thread anim_single_solo( chair, "chair_death_right" );
}

enemy_1_standing( ent )
{
	flag_set( "poker_table_enemy_1_standing" );
}

enemy_1_sitting( ent )
{
	flag_clear( "poker_table_enemy_1_standing" );
	flag_set( "poker_table_game_continues" );
}

second_floor_fridge_guy_setup()
{
	self endon( "death" );
	
	self.ignoreall		  = true;
	self.animname		  = "generic";
	self.allowdeath		  = true;
	self.diequietly		  = true;
	self.health			  = 50;
	self.patrol_walk_anim = "cornered_stealth_loop_fridge_guy";

	level.second_floor_left_enemies = add_to_array( level.second_floor_left_enemies, self );
	
	self thread fridge_anims();
	
	self thread wait_till_shot( "enemies_aware", undefined, "enemy_aware" );
	self thread alert_all( "second_floor_stealth_broken" );
	
	self.volume = GetEnt( "second_floor_left_volume", "targetname" );
	//self thread watch_for_player_to_shoot_while_in_enemy_volume( "spook_fridge_guy" );
	//self thread notify_spooked_for_vo( "second_floor_fridge_guy_spooked" );
	//self thread watch_kitchenette_guy();

	self thread watch_for_death_and_alert_all_in_volume( "second_floor_fridge_guy_out_of_middle_volume" );
	
	self waittill( "enemy_aware" );
	if ( flag( "second_floor_kitchenette_guy_in_kitchen" ) )
	{
		if ( !flag( "kitchen_alerted" ) )
		{
			flag_set( "kitchen_alerted" );
		}
	}
}

fridge_anims()
{
	self endon( "death" );
	
	fridge = GetEnt( "fridge", "targetname" );
	Assert( IsDefined( fridge ) );
	fridge.animname = "fridge";
	fridge SetAnimTree();
	
	thread handle_beer_bottles();

	level.guy_fridge_beers[ 0 ] = self;
	level.guy_fridge_beers[ 1 ] = fridge;
				   
	level.second_floor_anim_struct thread anim_first_frame_solo( level.guy_fridge_beers[ 1 ], "cornered_stealth_fridge_anims" );

	level.second_floor_anim_struct thread anim_loop_solo( self, "fridge_idle", "stop_loop" );
	
	self thread fridge_guy_alerted();
	
	self thread second_floor_fridge_guy_path();
}

second_floor_fridge_guy_path()
{
	self endon( "death" );
	self endon( "enemy_aware" );
	self endon( "enemy_spooked" );
	
	self.skip_start_transition = true;
	
	flag_wait( "second_floor_kitchenette_guy_at_stir_node" );
	flag_wait( "second_floor_shift_left" );
	level.second_floor_anim_struct notify( "stop_loop" );
	waittillframeend;
	self StopAnimScripted();
	
	flag_set( "fridge_guy_leaving_fridge" );
	level.second_floor_anim_struct anim_single( level.guy_fridge_beers, "cornered_stealth_fridge_anims" );
	
	flag_set( "second_floor_fridge_guy_start_patrol" );
	self.reactanim		= "patrol_react";
	
	flag_wait( "second_floor_fridge_guy_leaving_kitchen" );
	if ( flag( "second_floor_poker_guys_dead" ) )
	{
		flag_set( "second_floor_fridge_guy_will_be_alerted" );
	}
	else
	{
		volume = GetEnt( self.volume.targetname + "_player", "targetname" );
		if ( level.player IsTouching( volume ) )
		{
			flag_set( "take_the_shot_vo" );
		}
	}
	
	flag_wait( "second_floor_fridge_guy_in_middle_volume" );
	self.volume = GetEnt( "second_floor_middle_volume", "targetname" );
	if ( flag( "second_floor_poker_guys_dead" ) )
	{
		self thread second_floor_fridge_guy_spooked();
//		self thread wait_for_death_of_spooked_fridge_guy();
		flag_set( "second_floor_fridge_guy_spooked" );
	}
	else
	{
		flag_wait( "second_floor_fridge_guy_end_patrol" );
		self Delete();
	}
}

fridge_light_off( fridge_guy )
{
	fridge_lights = GetEntArray( "rappel_stealth_fridge_light", "targetname" );
	foreach ( light in fridge_lights )
	{
		light SetLightIntensity( 0.1 );
	}
}

second_floor_fridge_guy_spooked()
{
	self endon( "death" );
	self endon( "enemy_aware" );
	
	self notify( "end_patrol" );
	
	self clear_run_anim();
	self set_run_anim( "cqb_walk" );
	self.patrol_walk_anim = "cqb_walk";
	self set_moveplaybackrate( 0.5 );
	
	struct		= getstruct( "second_floor_fridge_guy_middle_spook_patrol_start", "targetname" );
	self.target = struct.targetname;
	
	self thread maps\_patrol::patrol( self.target );
	
	flag_wait( "second_floor_fridge_guy_middle_spook_patrol_end" );
	
	self thread anim_loop_solo( self, "stationary_look_around", "stop_loop" );
	
	wait( RandomFloatRange( 1.0, 2.5 ) );
	self notify( "stop_loop" );
	waittillframeend;
	flag_set( "enemies_aware" );
}

//wait_for_death_of_spooked_fridge_guy()
//{
//	self waittill( "death" );
//	if ( !flag( "second_floor_kitchenette_guy_dead" ) )
//	{
//		if ( !flag( "enemies_aware" ) )
//		{
//			temp_dialogue( "Rorke"	, "One left.", 2 );
//		}
//		else
//		{
//			temp_dialogue( "Rorke"	, "One left.  Clean up your mess, Rook.", 2 );
//		}
//	}
//}

fridge_guy_alerted()
{
	self endon( "enemy_spooked" );
	
	self waittill_any( "enemy_aware", "death" );
	flag_set( "fridge_guy_alerted_or_dead" );
	
	if ( IsAlive( self ) )
	{
		if ( flag( "fridge_guy_leaving_fridge" ) && !flag( "second_floor_fridge_guy_start_patrol" ) )
		{
			//if "fridge_guy_leaving_fridge" has been set this means the fridge guy has started his anim to leave the fridge
			//if "second_floor_fridge_guy_start_patrol" is not yet set this means that anim is not over and he hasn't started his patrol
		    level.second_floor_anim_struct notify( "stop_loop" );
			waittillframeend;
			self StopAnimScripted();
			level.guy_fridge_beers[ 1 ] StopAnimScripted();
			self.ignoreall = false;	
		}
		else if ( flag( "fridge_guy_leaving_fridge" ) && flag( "second_floor_fridge_guy_start_patrol" ) )
		{
			//if "fridge_guy_leaving_fridge" has been set this means the fridge guy has started his anim to leave the fridge
			//if "second_floor_fridge_guy_start_patrol" has been set this means that his fridge leaving anim is over and he has started his patrol
			self notify( "end_patrol" );
			self.ignoreall = false;	
		}
		else if ( !flag( "fridge_guy_leaving_fridge" ) )
		{
			//guy is still looking through fridge
			level.second_floor_anim_struct notify( "stop_loop" );
			waittillframeend;
			self StopAnimScripted();
	
			level.guy_fridge_beers[ 1 ] anim_single_solo( self, "fridge_react" );
			self.ignoreall = false;
		}
	}
}

handle_beer_bottles()
{
	beer_bottle_array = [];
	
	beer_bottle_array[ 0 ] = Spawn( "script_model", ( 0, 0, 0 ) );
	beer_bottle_array[ 0 ] SetModel( "bo_p_glo_beer_bottle01_world" );
	beer_bottle_array[ 0 ] LinkTo( self, "tag_weapon_left", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	beer_bottle_array[ 1 ] = Spawn( "script_model", ( 0, 0, 0 ) );
	beer_bottle_array[ 1 ] SetModel( "bo_p_glo_beer_bottle01_world" );
	beer_bottle_array[ 1 ] LinkTo( self, "tag_shield_back", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	beer_bottle_array[ 2 ] = Spawn( "script_model", ( 0, 0, 0 ) );
	beer_bottle_array[ 2 ] SetModel( "bo_p_glo_beer_bottle01_world" );
	beer_bottle_array[ 2 ] LinkTo( self, "tag_stowed_back", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	beer_bottle_array[ 3 ] = Spawn( "script_model", ( 0, 0, 0 ) );
	beer_bottle_array[ 3 ] SetModel( "bo_p_glo_beer_bottle01_world" );
	beer_bottle_array[ 3 ] LinkTo( self, "tag_inhand", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	beer_bottle_array[ 4 ] = Spawn( "script_model", ( 0, 0, 0 ) );
	beer_bottle_array[ 4 ] SetModel( "bo_p_glo_beer_bottle01_world" );
	beer_bottle_array[ 4 ] LinkTo( self, "tag_weapon_chest", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	
	flag_wait_any( "fridge_guy_alerted_or_dead", "second_floor_fridge_guy_end_patrol", "second_floor_fridge_guy_spooked" );
	if ( flag( "second_floor_fridge_guy_end_patrol" ) )
	{
		foreach ( beer_bottle in beer_bottle_array )
		{
			if ( IsDefined( beer_bottle ) )
			{
				beer_bottle Delete();
			}
		}
	}
	else
	{
		foreach ( beer_bottle in beer_bottle_array )
		{
			if ( IsDefined( beer_bottle ) )
			{
				beer_bottle Unlink();
				beer_bottle PhysicsLaunchClient( self.origin + ( 0, 0, 2 ), ( 0, 0, -10 ) );
			}
		}
		
		flag_wait( "stop_for_third_floor_combat" );
		foreach ( beer_bottle in beer_bottle_array )
		{
			if ( IsDefined( beer_bottle ) )
			{
				beer_bottle Delete();
			}
		}
	}
}

second_floor_kitchenette_guy_setup()
{
	self endon( "death" );
	
	self.ignoreall		  = true;
	self.animname		  = "generic";
	self.allowdeath		  = true;
	self.diequietly		  = true;
	self.health			  = 50;
	self.patrol_walk_anim = "active_patrolwalk_gundown";
	self disable_pain();
	self disable_surprise();
	self.disableBulletWhizbyReaction = true;
	self set_ignoreSuppression( true );
	
	level.second_floor_left_enemies = add_to_array( level.second_floor_left_enemies, self );
	
	self thread second_floor_kitchenette_guy();
	
	self thread wait_till_shot( "enemies_aware", undefined, "enemy_aware" );
	self thread handle_alerted();
	self thread alert_all( "second_floor_stealth_broken" );
	
	volume = GetEnt( "elevator_volume", "targetname" );
	self thread watch_while_in_volume_and_set_flag_when_out( volume, "second_floor_kitchenette_guy_out_of_elevator" );
	
	flag_wait_all( "elevator_doors_open", "second_floor_combat_vo" );
	flag_set( "second_floor_kitchenette_guy_leave_elevator" );
	
	flag_wait( "second_floor_kitchenette_guy_out_of_elevator" );
	self.reactanim = "patrol_react";
	self enable_pain();
	self enable_surprise();
	self.disableBulletWhizbyReaction = false;
	self set_ignoreSuppression( false );
	
	//this wakes up everyone in the volume in the middle room, if anyone in the middle volume is killed
	volume = GetEnt( "second_floor_middle_volume", "targetname" );
	self thread watch_while_in_volume_and_set_flag_when_out( volume, "second_floor_kitchenette_guy_out_middle_volume" );
	self.volume = GetEnt( "second_floor_middle_volume", "targetname" );
	self thread watch_for_death_and_alert_all_in_volume( "second_floor_kitchenette_guy_out_middle_volume" );
	
	volume		= GetEnt( "second_floor_left_volume", "targetname" );
	self.volume = GetEnt( "second_floor_left_volume", "targetname" );
	self thread watch_for_death_and_alert_all_in_volume( "intro_vo_done" );
	
	self waittill( "enemy_aware" );
	if ( flag( "second_floor_kitchenette_guy_in_kitchen" ) )
	{
		if ( !flag( "kitchen_alerted" ) )
		{
			flag_set( "kitchen_alerted" );
		}
	}
	
	if ( flag( "second_floor_kitchenette_guy_at_stir_node" ) )
	{
		if ( IsDefined( level.enemy_patrol_phone ) )
		{
			level.enemy_patrol_phone Delete();
		}
	}
}

second_floor_kitchenette_guy()
{
	self endon( "death" );
	self endon( "enemy_aware" );
	
	flag_wait( "second_floor_kitchenette_guy_heading_to_kitchen" );
	if ( flag( "second_floor_fridge_guy_dead" ) )
	{
		//This is for vo for warning the player
		flag_set( "second_floor_kitchenette_guy_will_be_alerted" );
	}
	
	flag_wait( "second_floor_kitchenette_guy_in_kitchen" );
	if ( flag( "second_floor_fridge_guy_dead" ) )
	{
		//This is for vo for warning the player
		flag_set( "second_floor_kitchenette_guy_will_be_alerted_2" );
	}
	
	flag_wait( "second_floor_kitchenette_guy_alert_node" );
	if ( flag( "second_floor_fridge_guy_dead" ) )
	{
		self thread kitchenette_guy_spooked();
	}
	else
	{
		self thread kitchenette_guy_continue();
	}
}

kitchenette_guy_spooked()
{
	self endon( "death" );
	self endon( "enemy_aware" );
	
	self thread anim_loop_solo( self, "stationary_look_around", "stop_loop" );
	
	wait( RandomFloatRange( 2.0, 3.5 ) );
	self notify( "stop_loop" );
	waittillframeend;
	
	self notify( "end_patrol" );
	
	self notify( "enemy_aware" );
}

kitchenette_guy_continue()
{
	self endon( "death" );
	self endon( "enemy_aware" );
	
	flag_wait( "second_floor_kitchenette_guy_at_stir_node" );
	
	self.reactanim = "patrol_bored_react_look_retreat";
	level.enemy_patrol_phone = Spawn( "script_model", ( 0, 0, 0 ) );
	level.enemy_patrol_phone LinkTo( self, "tag_inhand", ( 0, 1, 0 ), ( 0, 0, 0 ) );
	level.enemy_patrol_phone SetModel( "cnd_cellphone_01_off_anim" );
	
//	self gun_remove();
//	self.weapon_removed = true;
	
//	self.struct = getstruct( "second_floor_kitchenette_guy_struct", "targetname" );
//	self.struct thread anim_loop_solo( self, "hijack_intro_kitchenette_guy1_loop", "stop_loop" );
	self thread anim_loop_solo( self, "patrol_bored_idle_cellphone", "stop_loop" );
}

#using_animtree( "generic_human" );
second_floor_elevator_guy_setup()
{
	self endon( "death" );
	
	self.ignoreall = true;
	self.animname  = "generic";
	self.deathanim = %exposed_death;

	self thread wait_till_shot( "enemies_aware", "second_floor_stealth_broken", "enemy_aware" );
	self thread alert_all( "second_floor_stealth_broken" );
	self thread elevator_guys_react();
	
	if ( self.script_noteworthy == "second_floor_elevator_guy_1" )
	{
		self thread elevator_anims( "cornered_stealth_elevator_enemy1" );
	}
	else
	{
		self thread elevator_anims( "cornered_stealth_elevator_enemy2" );
	}
}

elevator_anims( elevator_anim )
{
	self endon( "death" );
	self endon( "enemy_aware" );
	
	level.second_floor_anim_struct anim_first_frame_solo( self, elevator_anim );
	flag_wait( "start_elevator_anims" );
	level.second_floor_anim_struct thread anim_single_solo( self, elevator_anim );
	wait( 0.05 );
	self anim_self_set_time( elevator_anim, .4 );
	
	//flag_wait( "elevator_doors_shut" );
	flag_wait( "elevator_gone" );
	self Delete();
}

elevator_door_close( ent )
{
	flag_set( "elevator_doors_ready_to_close" );
}

elevator_guys_react()
{
	self endon( "death" );
	
	self waittill( "enemy_aware" );
	self StopAnimScripted();
	self.ignoreall		= false;
  //self.favoriteenemy = level.player;
	
	volume = GetEnt( "second_floor_middle_volume", "targetname" );
	self SetGoalVolumeAuto( volume );
}

allies_help_when_player_shoots_second_floor_left()
{

	level endon( "second_floor_fridge_guy_in_middle_volume" );
	level endon( "second_floor_fridge_guy_killed_too_soon" );
	level endon( "second_floor_stealth_broken" );
	level endon( "second_floor_enemies_dead" );
	
	flag_wait( "second_floor_kitchenette_guy_out_middle_volume" );
	flag_wait_any( "intro_vo_done", "enemies_on_left_next" );
	
	volume = GetEnt( "second_floor_left_volume_player", "targetname" );
	level.player childthread watch_for_player_to_shoot_while_in_volume( volume, "player_shot_in_left_volume", "second_floor_enemies_dead" );
	level.player childthread coordinated_kills( level.allies[ level.const_baker ], level.second_floor_left_enemies, "player_shot_in_left_volume", "second_floor_enemies_dead", "shot_at_left_guys" );
}

allies_help_when_player_shoots_second_floor_middle_or_right()
{
	level endon( "second_floor_stealth_broken" );
	level endon( "second_floor_enemies_dead" );
	
	flag_wait_any( "intro_vo_done", "second_floor_fridge_guy_killed_too_soon" );
	if ( flag( "second_floor_fridge_guy_killed_too_soon" ) )
	{
		//if fridge guy is killed before he should be
		if ( !flag( "second_floor_kitchenette_guy_in_kitchen" ) )
		{
			//and kitchenette guy isn't in the kitchen yet
			flag_wait( "second_floor_kitchenette_guy_in_kitchen" );
		}
	}
	
	volume = GetEnt( "second_floor_middle_volume_player", "targetname" );
	level.player childthread watch_for_player_to_shoot_while_in_volume( volume, "player_shot_in_middle_volume", "second_floor_enemies_dead" );
	level.player childthread coordinated_kills( level.allies[ level.const_rorke ], level.second_floor_middle_enemies, "player_shot_in_middle_volume", "second_floor_enemies_dead", "shot_at_middle_guys" );
	
	volume = GetEnt( "second_floor_right_volume_player", "targetname" );
	level.player childthread watch_for_player_to_shoot_while_in_volume( volume, "player_shot_in_right_volume", "second_floor_enemies_dead" );
	level.player childthread coordinated_kills( level.allies[ level.const_rorke ], level.second_floor_middle_enemies, "player_shot_in_right_volume", "second_floor_enemies_dead", "shot_at_middle_guys" );
}

////////
//FUNCTIONS USED BY ALL THREE STEALTH ENCOUNTERS
////////


watch_while_in_volume_and_set_flag_when_out( volume, flag_to_set )
{
	self endon( "death" );
	
	touched_volume = undefined;
	
	while ( 1 )
	{
		if ( self IsTouching( volume ) && !IsDefined( touched_volume ) )
		{
			touched_volume = true;
		}
		if ( !( self IsTouching( volume ) ) && IsDefined( touched_volume ) && touched_volume == true )
		{
			touched_volume = false;
		}
		if ( IsDefined( touched_volume ) && touched_volume == false )
		{
			flag_set( flag_to_set );
			break;
		}
		wait( 0.05 );
	}
}

handle_alerted( flag_to_set )
{
	self endon( "death" );
	
	self waittill( "enemy_aware" );
	
	if ( IsDefined( flag_to_set ) )
	{
		if ( !flag( flag_to_set ) )
		{
			flag_set( flag_to_set );
		}
	}

	if ( IsDefined( self.struct ) )
	{
		self.struct notify( "stop_loop" );
		waittillframeend;
		self StopAnimScripted();
		self.favoriteenemy = level.player;
	}
	else
	{
		self notify( "stop_loop" );
		waittillframeend;
		self StopAnimScripted();
		self.favoriteenemy = level.player;
	}
	
	if ( IsDefined( self.reactanim ) )
	{
		self anim_single_solo( self, self.reactanim );
		//self OrientMode( "face point", self.favoriteenemy.origin );
		//self SetFlaggedAnimKnobRestart( "reactanim", self.reactanim, 1, 0.2, 1 );
		//self animscripts\shared::DoNoteTracks( "reactanim" );
	}
	
	if ( IsDefined( self.weapon_removed ) )
	{
		self gun_recall();
	}
	
	self.ignoreall = false;
}

//notify_spooked_for_vo( flag_to_set )
//{
//	self endon( "death" );
//	
//	self waittill( "enemy_spooked" );
//	
//	flag_set( flag_to_set );
//}

allies_rappel_stealth_vo()
{	
	level endon( "rorke_killed" );
	level endon( "baker_killed" );
	
	wait( 0.25 );
	//flag_set( "rappel_down_ready" );
	flag_wait( "rappel_down_ready" );

	//Merrick: Line’s secure. Let’s move down.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_linessecureletsmove" );
	
	//Hesh: Let's head down, bro.
	//Merrick: Come on, drop down.
	nag_lines	= make_array( "cornered_hsh_letsheaddownbro", "cornered_mrk_comeondropdown" );
	thread nag_until_flag( nag_lines, "approaching_first_combat_floor", 10, 15, 5 );

	if ( !rappel_ignore_first_two_encounters() )
	{
		flag_wait( "approaching_first_combat_floor" );
		thread rappel_stealth_first_floor_combat_vo();
		thread rappel_stealth_first_floor_combat_stealth_broken_vo();
		thread first_floor_enemies_shot_out_of_order();
	
		flag_wait( "first_floor_enemies_dead" );
		if ( flag( "first_floor_combat_weapons_free" ) && !flag( "enemies_aware" ) )
		{
			//Merrick: Targets down.  We're clear.
			level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_targetsdownwereclear" );
			wait( 0.5 );
		}
		else
		{
			//Merrick: Targets down.  We're clear.
			level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_targetsdownwereclear" );
			wait( 0.5 );
			flag_wait( "allies_stealth_behavior_end" );
			flag_clear( "allies_stealth_behavior_end" );
		}
		
		//Merrick: Move to the next floor.
		level.allies[ level.const_rorke ] thread smart_radio_dialogue( "cornered_mrk_movetothenext" );

		flag_set( "rappel_down_ready" );
		
		thread autosave_now();
		wait( 0.5 );
		
		flag_wait( "approaching_second_floor_combat" );
		//Hesh: More enemies below.
		level.allies[ level.const_rorke ] thread smart_radio_dialogue( "cornered_hsh_moreenemiesbelow" );
		wait( 0.5 );
		flag_set( "elevator_doors_ready_to_open" );
		thread rappel_stealth_second_floor_combat_vo();
		thread rappel_stealth_second_floor_combat_stealth_broken_vo();
		
		flag_wait( "second_floor_enemies_dead" );
		if ( flag( "second_floor_stealth_broken" ) )
		{
			//Hesh: Clear.
			level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_clear" );
			wait( 0.5 );
			//Merrick: Let's get movin'.
			level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_letsgetmovin" );
			
			flag_wait( "allies_stealth_behavior_end" );
			flag_clear( "allies_stealth_behavior_end" );
		}
		else
		{
			//Hesh: Clear.
			level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_clear" );
			wait( 0.5 );
			//Merrick: Keep it movin'.
			level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_keepitmovin" );
		}
		
		flag_set( "rappel_down_ready" );
		
		thread autosave_now();
	}
	
//	flag_wait( "approaching_third_combat_floor" );
}

rappel_stealth_first_floor_combat_vo()
{
	level endon( "enemies_aware" );
	level endon( "killed_out_of_order" );
	level endon( "first_floor_enemies_dead" );
	
	flag_set( "first_floor_patrol_start" );
	
	//Hesh: Enemies below.
	level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_enemiesbelow" );
	if ( !flag( "first_floor_combat_vo" ) )
	{
		//Merrick: The lights inside will keep them blind to us.
		level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_rke_noquick" );
		wait( 1 );
	}
	
	flag_wait( "first_floor_combat_vo" );

	//Merrick: Guy at the table.  Take him out.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_guyatthetable" );
	flag_set( "first_floor_combat_weapons_free" );
	
	flag_wait( "first_floor_sitting_laptop_guy_dead" );
	flag_set( "allies_ready_first_combat_floor" );
	
	//Merrick: Good.  Shift right.  Let's take care of the other two.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_goodshiftrightlets" );
	flag_clear( "first_floor_combat_weapons_free" );
	level.first_floor_shift_right_trigger trigger_on();
	
	flag_wait( "first_floor_shift_right" );
	flag_set( "first_floor_combat_weapons_free" );
	
	//Merrick: On you, kid.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_onyoukid" );
}

rappel_stealth_first_floor_combat_stealth_broken_vo()
{
	level endon( "first_floor_enemies_dead" );
	
	flag_wait( "enemies_aware" );
	if ( !flag( "first_floor_combat_weapons_free" ) )
	{
		//Merrick: Shit!  What are you doin?!
		level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_shitwhatareyou" );
		//temp_dialogue( "Rorke", "What are you doing Rook?", 2 );
		//wait( 0.5 );
		//temp_dialogue( "Rorke", "Quick, take them out!", 2 );
	}

}

first_floor_enemies_shot_out_of_order()
{	
	flag_wait_any( "first_floor_patroller_1_dead", "first_floor_patroller_2_dead" );
	if ( !flag( "first_floor_sitting_laptop_guy_dead" ) )
	{
		flag_set( "killed_out_of_order" );
		
		if ( flag( "first_floor_patroller_1_dead" ) )
		{
			if ( !flag( "enemies_aware" ) )
			{
				flag_set( "enemies_aware" );
				//Merrick: Shit!  What are you doin?!
				level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_shitwhatareyou" );
				//temp_dialogue( "Rorke", "What are you doing Rook?", 2 );
				//wait( 0.5 );
				//temp_dialogue( "Rorke", "Hurry up and take the other two out.", 2 );
			}
		}
		else if ( flag( "first_floor_patroller_2_dead" ) )
		{
			if ( !flag( "enemies_aware" ) )
			{
				flag_set( "enemies_aware" );
				//Merrick: Shit!  What are you doin?!
				level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_shitwhatareyou" );
				//temp_dialogue( "Rorke", "What are you doing Rook?", 2 );
				//wait( 0.5 );
				//temp_dialogue( "Rorke", "Hurry up and take the other two out.", 2 );
			}
		}
	}
}

rappel_stealth_second_floor_combat_vo()
{
	level endon( "enemies_aware" );
	level endon( "second_floor_enemies_dead" );
	
	thread second_floor_combat_intro_vo();
	thread second_floor_combat_left_enemies_down();
	thread second_floor_combat_middle_enemies_down();
	
	//Merrick: Got movement in the center.
	vo_to_say = "cornered_mrk_gotmovementinthe";
	thread notify_patrol_movement_vo( "poker_table_spooked"												, level.allies[ level.const_rorke ]		, vo_to_say, "poker_table_alerted" );
	
	//Merrick: Alright.  Smoke these guys.
	vo_to_say = "cornered_mrk_alrightsmoketheseguys";
	thread notify_patrol_movement_vo( "poker_table_game_continues"										, level.allies[ level.const_rorke ]		, vo_to_say, "poker_table_alerted" );
	
	//Merrick: Another on the way.  Take him out when he's in the kitchen.
	vo_to_say = "cornered_mrk_anotherontheway";
	thread notify_patrol_movement_vo( "second_floor_kitchenette_guy_will_be_alerted"					, level.allies[ level.const_rorke ]		, vo_to_say, "second_floor_kitchenette_guy_dead" );
	
	//Merrick: Drop him!  Quick!
	vo_to_say = "cornered_mrk_drophimquick";
	thread notify_patrol_movement_vo( "second_floor_kitchenette_guy_will_be_alerted_2"					, level.allies[ level.const_rorke ]		, vo_to_say, "second_floor_kitchenette_guy_dead" );
	
	//Hesh: Got a guy on the move here.
	vo_to_say = "cornered_hsh_gotaguyon";
	thread notify_patrol_movement_vo( "second_floor_fridge_guy_start_patrol"							, level.allies[ level.const_baker ]		, vo_to_say, "second_floor_fridge_guy_dead" );
	
	//Merrick: He's going to see the bodies.  Take him down!
	vo_to_say = "cornered_mrk_hesgoingtosee";
	thread notify_patrol_movement_vo( "second_floor_fridge_guy_will_be_alerted"							, level.allies[ level.const_rorke ]		, vo_to_say, "second_floor_fridge_guy_dead" );
	
	//Hesh: Take the shot.
	vo_to_say = "cornered_hsh_taketheshot";
	thread notify_patrol_movement_vo( "take_the_shot_vo"												, level.allies[ level.const_baker ]		, vo_to_say, "second_floor_fridge_guy_dead" );
	
	//Hesh: Take him out now.
	vo_to_say = "cornered_hsh_takehimoutnow";
	thread notify_patrol_movement_vo( "second_floor_fridge_guy_middle_spook_patrol_near_end"			, level.allies[ level.const_baker ]		, vo_to_say, "second_floor_fridge_guy_dead" );
	
	//Merrick: Hold your fire!
	thread watch_for_death_to_notify_vo( "second_floor_kitchenette_guy_dead", "second_floor_fridge_guy_dead", "second_floor_kitchenette_guy_in_kitchen", level.allies[ level.const_rorke ], "cornered_mrk_holdyourfire", "second_floor_fridge_guy_killed_too_soon" );
}

rappel_stealth_second_floor_combat_stealth_broken_vo()
{
	level endon( "second_floor_enemies_dead" );
	
	thread pre_elevator_doors_shut();
	
	flag_wait( "elevator_doors_shut" );
	
	level.second_floor_shift_left_trigger trigger_on();
	
	thread second_floor_stealth_broken_middle_vo();
	thread second_floor_stealth_broken_left_vo();
}

pre_elevator_doors_shut()
{
	//level endon( "elevator_doors_shut" );
	level endon( "elevator_gone" );
	
	flag_wait( "poker_table_alerted" );
	//Merrick: Shit!  What are you doin?!
	level.allies[ level.const_rorke ] thread smart_radio_dialogue( "cornered_mrk_shitwhatareyou" );
	flag_set( "second_floor_stealth_broken" );
}

second_floor_stealth_broken_middle_vo()
{
	level endon( "second_floor_enemies_dead" );
	level endon( "second_floor_stealth_broken" );
	
	flag_wait( "poker_table_alerted" );
	
	if ( !flag( "intro_vo_done" ) )
	{
		//the intro vo was interrupted before it finished
		if ( !flag( "stealth_broken_vo_said" ) )
		{
			flag_set( "stealth_broken_vo_said" );
			//Merrick: Shit!  What are you doin?!
			level.allies[ level.const_rorke ] thread smart_radio_dialogue( "cornered_mrk_shitwhatareyou" );
			//thread temp_dialogue( "Rorke", "What are you doing, Rook?", 2 );
		}
		wait( 5 );
		//if after x seconds any of the alerted are still alive, then most likely everyone else has been alerted
		level.second_floor_middle_enemies = array_removeDead( level.second_floor_middle_enemies );
		if ( level.second_floor_middle_enemies.size > 0 )
		{
//			if ( flag( "stealth_broken_vo_said" ) )
//			{
//				thread temp_dialogue( "Rorke", "Rook, take them out!", 2 );	
//			}
			flag_set( "second_floor_stealth_broken" );
		}
	}
	else
	{
		//the intro vo was said
		wait( 5 );
		//if after x seconds any of the alerted are still alive, then most likely everyone else has been alerted
		level.second_floor_middle_enemies = array_removeDead( level.second_floor_middle_enemies );
		if ( level.second_floor_middle_enemies.size > 0 )
		{
//			thread temp_dialogue( "Rorke", "Rook, take them out!", 2 );
			flag_set( "second_floor_stealth_broken" );
		}
	}
}

second_floor_stealth_broken_left_vo()
{
	level endon( "second_floor_enemies_dead" );
	level endon( "second_floor_stealth_broken" );
	
	flag_wait( "kitchen_alerted" );
	
	if ( !flag( "intro_vo_done" ) )
	{
		//the intro vo was interrupted before it finished
		if ( !flag( "stealth_broken_vo_said" ) )
		{
			flag_set( "stealth_broken_vo_said" );
			//Merrick: Shit!  What are you doin?!
			level.allies[ level.const_rorke ] thread smart_radio_dialogue( "cornered_mrk_shitwhatareyou" );
			//thread temp_dialogue( "Rorke", "What are you doing, Rook?", 2 );
		}
		wait( 5 );
		//if after x seconds any of the alerted are still alive, then most likely everyone else has been alerted
		level.second_floor_left_enemies = array_removeDead( level.second_floor_left_enemies );
		if ( level.second_floor_left_enemies.size > 0 )
		{
//			if ( flag( "stealth_broken_vo_said" ) )
//			{
//				thread temp_dialogue( "Rorke", "Rook, take them out!", 2 );	
//			}
			flag_set( "second_floor_stealth_broken" );
		}
	}
	else
	{
		//the intro vo was said
		
		wait( 5 );
		//if after x seconds any of the alerted are still alive, then most likely everyone else has been alerted
		level.second_floor_left_enemies = array_removeDead( level.second_floor_left_enemies );
		if ( level.second_floor_left_enemies.size > 0 )
		{
//			thread temp_dialogue( "Rorke", "Rook, take them out!", 2 );
			flag_set( "second_floor_stealth_broken" );
		}
	}
}

second_floor_combat_intro_vo()
{
	level endon( "enemies_aware" );
	level endon( "second_floor_fridge_guy_spooked" );
	level endon( "second_floor_fridge_guy_killed_too_soon" );
	level endon( "poker_table_alerted" );
	level endon( "player_shot_in_middle_volume" );
	level endon( "player_shot_in_right_volume" );
	level endon( "second_floor_enemies_dead" );
	
	flag_wait( "second_floor_combat_vo" );
	triggers = GetEntArray( "second_floor_combat_vo_trigger", "targetname" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}

	flag_set( "start_elevator_anims" );
	wait( 0.5 );
	
	//Merrick: Hold your fire.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_holdyourfire_2" );
	//Merrick: Got three at the poker table over here.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_gotthreeatthe" );
	wait( 0.5 );
	//Hesh: Left side. One in the kitchen. One on the way.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_hsh_leftsideonein" );
	wait( 0.5 );
	//Merrick: Shift left. Hit the kitchen first.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_shiftlefthitthe" );
	wait( 0.5 );
	//Merrick: Waint until he's in the kitchen then take them both out.
	level.allies[ level.const_rorke ] smart_radio_dialogue( "cornered_mrk_waintuntilhesin" );	
	
	flag_set( "intro_vo_done" );
	
	level.second_floor_shift_left_trigger trigger_on();
	flag_wait_all( "second_floor_shift_left", "second_floor_kitchenette_guy_in_kitchen" );
	
	//Hesh: On you, bro.
	level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_hsh_onyoubro" );
}

second_floor_combat_left_enemies_down()
{
	level endon( "enemies_aware" );
	level endon( "poker_table_alerted" );
	level endon( "second_floor_poker_guys_dead" );
	level endon( "second_floor_enemies_dead" );
	
	flag_wait_either( "second_floor_fridge_guy_dead", "second_floor_kitchenette_guy_dead" );
	if ( flag( "second_floor_fridge_guy_dead" ) )
	{
		//if fridge guy is first to die
		if ( flag( "second_floor_fridge_guy_killed_too_soon" ) )
		{
			//if the fridge guy is killed before he should be
			flag_wait( "second_floor_kitchenette_guy_dead" );
			//wait( 0.5 );
			//thread temp_dialogue( "Rorke", "Sloppy, Rook.  Let's take out the others.", 3 );
		}
		else
		{
			flag_wait( "second_floor_kitchenette_guy_dead" );
			//wait( 0.5 );
			//thread temp_dialogue( "Rorke", "Good.  Now let's take out the rest.", 3 );
		}
	}
	else if ( flag( "second_floor_kitchenette_guy_dead" ) )
	{
		//if kitchenette guy is first to die
		flag_wait( "second_floor_fridge_guy_dead" );
		//wait( 0.5 );
		//thread temp_dialogue( "Rorke", "Good.  Now let's take out the rest.", 3 );
	}
	
	flag_set( "second_floor_left_enemies_taken_out" );
}

second_floor_combat_middle_enemies_down()
{
	level endon( "enemies_aware" );
	level endon( "second_floor_fridge_guy_dead" );
	level endon( "second_floor_kitchenette_guy_dead" );
	level endon( "second_floor_enemies_dead" );
	
	flag_wait( "second_floor_poker_guys_dead" );
	flag_set( "enemies_on_left_next" );
	if ( flag( "stealth_broken_vo_said" ) )
	{
		wait( 0.5 );
		//Merrick: Messy, kid.  Now take out the rest of 'em.
		level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_mrk_messykidnowtake" );		
	}
	else
	{
		wait( 0.5 );

		//Merrick: Nice. Let's hit the other two.
		level.allies[ level.const_baker ] smart_radio_dialogue( "cornered_mrk_nicenowletshit" );
	}
}

watch_for_death_to_notify_vo( death_flag_to_end_on, death_flag_to_wait_on, flag_to_check_if_set, who_says_vo, vo_to_say, flag_to_set )
{
	level endon( death_flag_to_end_on );
	
	flag_wait( death_flag_to_wait_on );
	
	//if (some flag indicates that this is the right or wrong time to kill this dude)
	if ( !flag( flag_to_check_if_set ) )
	{
		if ( IsDefined( flag_to_set ) )
		{
			flag_set( flag_to_set );
		}
		wait( 0.5 );
		//temp_dialogue( who_says_vo, vo_to_say, 3 );
		who_says_vo smart_radio_dialogue( vo_to_say );
	}
}

notify_patrol_movement_vo( flag_to_wait_on, who_says_vo, vo_to_say, flag_to_end_on, flag_to_set )
{
	level endon( "enemies_aware" );
	level endon( flag_to_end_on );

	flag_wait( flag_to_wait_on );
	wait( 0.5 );
	//temp_dialogue( who_says_vo, vo_to_say, 3 );
	who_says_vo smart_radio_dialogue( vo_to_say );
	if ( IsDefined( flag_to_set ) )
	{
		flag_set( flag_to_set );
	}
}

allies_rappel_stealth_anims()
{	
	ally_rappel_movement_setup( "stealth", "first_floor_enemies_dead" );
	
	if ( IsDefined( level.rappel_stealth_checkpoint ) )
	{
		level.zipline_anim_struct = getstruct( "zipline_anim_struct", "targetname" );
		waitframe();
		level.zipline_anim_struct thread anim_single_solo( self, "zipline_" + self.animname );
		waitframe();
		self SetAnimTime( getanim( "zipline_" + self.animname ), 1.0 );
		waitframe();
		self ally_rappel_start_rope( level.rappel_params.rappel_type );
	}
	else
	{
		while ( 1 )		
		{
			if ( IsDefined( self.zipline ) && self.zipline == false )
			{
				break;
			}
			
			wait( 0.05 );
		}
	}
		
	level.ally_zipline_count++;
	
	if ( level.ally_zipline_count == 2 )
	{
		flag_set( "rappel_down_ready" );
	}
	
	self.stealth_broken_flag = self.animname + "_stealth_broken";	
	
	self ally_rappel_start_movement_horizontal( "stealth", "first", "player_moving_down" );	

	flag_wait( "player_moving_down" );
	
/#
	if ( GetDvar( "debug_ally_aim", "0" ) != "0" )
		level waittill( "debug_ally_aim_complete" );
#/
		
	ally_stop_calm_idle();
	
	level.allies_stealth_behavior_end_count = 0;
	
	if ( !rappel_ignore_first_two_encounters() )
	{
		allies_move_down_to_first_floor_combat();
		
		flag_wait( "first_floor_enemies_dead" );
		
		if ( flag( self.stealth_broken_flag ) )
		{
			while ( 1 )
			{
				if ( IsDefined( self.stealth_behavior_over ) )
				{
					self.stealth_behavior_over = undefined;
					break;
				}
				wait( 0.05 );
			}
			flag_clear( self.stealth_broken_flag );
			self set_baseaccuracy( 1 );
			self.accuracy			= 1;
		}
		else
		{
			level notify( "floor_complete_end_stealth_threads" );
		}
		
		if ( !flag( "rappel_down_ready" ) )
		{
			flag_wait( "rappel_down_ready" );
		}
		if ( !flag( "player_moving_down" ) )
		{
			flag_wait( "player_moving_down" );
		}
		
		allies_move_down_to_second_floor_combat();
		
		flag_wait( "second_floor_enemies_dead" );
		
		if ( flag( self.stealth_broken_flag ) )
		{
			while ( 1 )
			{
				if ( IsDefined( self.stealth_behavior_over ) )
				{
					self.stealth_behavior_over = undefined;
					break;
				}
				wait( 0.05 );
			}
			flag_clear( self.stealth_broken_flag );	
			self set_baseaccuracy( 1 );
			self.accuracy		= 1;
		}
		else
		{
			level notify( "floor_complete_end_stealth_threads" );
		}
		
		flag_wait( "rappel_down_ready" );
		
		flag_wait( "player_moving_down" );
		
	}
	
	allies_move_down_to_third_floor_combat();
		
	level.reached_target_floor_count++;
	if ( level.reached_target_floor_count == 2 )
	{
		flag_set( "allies_reached_target_floor" );
	}
}

allies_move_down_to_first_floor_combat()
{
	level endon( self.stealth_broken_flag );
	
	//Allies move down to first combat floor
	level.last_goal_struct	   = 0;
	level.vertical_struct	   = [];
	level.vertical_struct[ 0 ] = getstruct( "first_empty_floor", "targetname" );
	level.vertical_struct[ 1 ] = getstruct( "first_combat_floor", "targetname" );
	
	self ally_rappel_stealth_movement_vertical( "first_floor_enemies_dead" );

	if ( !flag( "first_floor_enemies_dead" ) )
	{
		self thread handle_allies_if_stealth_broken( "first_floor_enemies_dead", "enemies_aware", "first" );
		self ally_rappel_start_movement_horizontal( "stealth", "first", "rappel_down_ready" );
		//self allies_first_floor_combat_behavior( "rappel_down_ready", "allies_ready_first_combat_floor" );
	}
	
	self notify( "stop_loop" );
	
	if ( IsDefined( self.hiding ) )
	{
		self anim_single_solo( self, "hide_exit_" + self.animname );
		self.hiding = undefined;
	}
	ally_start_calm_idle( "stealth" );
}

allies_move_down_to_second_floor_combat()
{
	level endon( self.stealth_broken_flag );
	
	//Allies move down to second combat floor
	level.last_goal_struct	   = 0;
	level.vertical_struct	   = [];
	level.vertical_struct[ 0 ] = getstruct( "second_combat_floor", "targetname" );
	
	self ally_rappel_stealth_movement_vertical( "second_floor_enemies_dead" );
	
	if ( !flag( "second_floor_enemies_dead" ) )
	{
		self thread handle_allies_if_stealth_broken( "second_floor_enemies_dead", "second_floor_stealth_broken", "second" );
		self ally_rappel_start_movement_horizontal( "stealth", "second", "rappel_down_ready" );
	}

	self notify( "stop_loop" );
	
	if ( IsDefined( self.hiding ) )
	{
		self anim_single_solo( self, "hide_exit_" + self.animname );
		self.hiding = undefined;
	}
	ally_start_calm_idle( "stealth" );
}

allies_move_down_to_third_floor_combat()
{
	level endon( self.stealth_broken_flag );
	
	//Allies move down to third combat floor
	level.last_goal_struct	   = 0;
	level.vertical_struct	   = [];
	level.vertical_struct[ 0 ] = getstruct( "second_empty_floor", "targetname" );
	level.vertical_struct[ 1 ] = getstruct( "third_combat_floor", "targetname" );
	
	self ally_rappel_stealth_movement_vertical();
}

handle_allies_if_stealth_broken( flag_to_end_on, flag_to_wait_on, section )
{
	level endon( "floor_complete_end_stealth_threads" );
	
	if ( !flag( flag_to_wait_on ) )
	{
		flag_wait( flag_to_wait_on );
	}
	
	wait 1;
	waitframe(); // give the player time to shoot them
	
	flag_set( self.stealth_broken_flag );
	
	self set_baseaccuracy ( 5000000 );
	self.accuracy		= 5000000;

	if ( flag( flag_to_end_on ) )
	{
		self.stealth_behavior_over = true;
		level.allies_stealth_behavior_end_count++;
		if ( level.allies_stealth_behavior_end_count == 2 )
		{
			flag_set( "allies_stealth_behavior_end" );
			level.allies_stealth_behavior_end_count = 0;
		}
		return;
	}
/*
	self notify( "stop_loop" );
	
	volume = GetEnt( self.animname + "_stealth_cover", "targetname" );
	
	//if ( !( self IsTouching( volume ) ) && self.last_volume != volume )
	if ( !( self IsTouching( volume ) ) )
	{
		//if we're not already touching this volume, move towards it
		//self anim_single_solo( self, "move_away_start" );
		self thread anim_loop_solo( self, "move_away", "stop_loop" );
		while ( 1 )
		{
			if ( self IsTouching( volume ) )
			{
				self notify( "stop_loop" );
				waittillframeend;
				//self anim_single_solo( self, "move_away_stop" );
				break;
			}
			wait( 0.05 );
		}
	}
	
	if ( !IsDefined( self.starting_to_hide ) )
	{
		if ( !IsDefined( self.hiding ) )
		{
			self anim_single_solo( self, "hide_enter_" + self.animname );
		}
	}
	else
	{
		while ( 1 )
		{
			if ( !IsDefined( self.starting_to_hide ) )
			{
				break;
			}
			wait( 0.05 );
		}
	}

	//while ( !flag( flag_to_end_on ) )
	while ( 1 )
	{
		if ( !flag( flag_to_end_on ) )
		{
			self ally_hiding( flag_to_end_on );
		}
		
		if ( flag( flag_to_end_on ) )
		{				
			self notify( "stop_loop" );
			self.hiding = undefined;
			self anim_single_solo( self, "hide_exit_" + self.animname );
			break;
		}
		
		//exits ally from hide idle and puts them into combat idle position
		self anim_single_solo( self, "peek_enter_" + self.animname );
		
		if ( !flag( flag_to_end_on ) )
		{
			self ally_peeking_and_shooting( flag_to_end_on );
		}
		
		if ( flag( flag_to_end_on ) )
		{	
			self ally_rappel_stop_aiming();
			self ally_rappel_stop_shooting();
			self.peeking = undefined;
			break;
		}
		
		//exits ally from peek idle and puts them into hiding position
		self anim_single_solo( self, "peek_exit_" + self.animname );
	}	
	
	self ally_rappel_start_aiming( "stealth" );
	self.stealth_behavior_over = true;
	level.allies_stealth_behavior_end_count++;
	if ( level.allies_stealth_behavior_end_count == 2 )
	{
		flag_set( "allies_stealth_behavior_end" );
		level.allies_stealth_behavior_end_count = 0;
	}
*/
	
	self ally_rappel_start_movement_horizontal( "stealth", "first", flag_to_end_on );
	
	self ally_rappel_stop_aiming();
	self ally_rappel_stop_shooting();
	
	self ally_rappel_start_aiming( "stealth" );
	
	self.stealth_behavior_over = true;
	level.allies_stealth_behavior_end_count++;
	if ( level.allies_stealth_behavior_end_count == 2 )
	{
		flag_set( "allies_stealth_behavior_end" );
		level.allies_stealth_behavior_end_count = 0;
	}
}

//ally_hiding( flag_to_end_on )
//{
//	level endon( flag_to_end_on );
//	
//	self.hiding = true;
//	self thread anim_loop_solo( self, "hide_idle_" + self.animname, "stop_loop" );
//	wait( RandomFloatRange( 1.0, 3.5 ) );
//	self notify( "stop_loop" );
//	self.hiding = undefined;
//}
//
//ally_peeking_and_shooting( flag_to_end_on )
//{
//	level endon( flag_to_end_on );
//	
//	self.peeking = true;
//	self ally_rappel_start_aiming( "stealth" );
//	self ally_rappel_start_shooting();
//	wait( RandomFloatRange( 2.0, 3.5 ) );
//	while ( ally_is_reloading() )
//		wait 1;
//	self ally_rappel_stop_aiming();
//	self ally_rappel_stop_shooting();
//	self.peeking = undefined;
//}

ally_rappel_moving_change_direction( direction )
{
	Assert( direction == "down" || direction == "away" || direction == "down_away" || direction == "back" || direction == "down_back" );
	
	if ( direction == self.rappel_move_direction )
		return;
	
	start_anim = "move_" + direction + "_start";
	loop_anim  = "move_" + direction;
	
	if ( self ally_is_aiming() )
		self ally_rappel_stop_aiming();
	else if ( self ally_is_calm_idling() )
		self ally_stop_calm_idle();
	self.rappel_move_direction = direction;
	self notify( "stop_loop" );
	self anim_single_solo( self, start_anim );
	self thread anim_loop_solo( self, loop_anim, "stop_loop" );
}

ally_rappel_moving_stop_idle()
{
	self.rappel_move_direction = "idle";
	self notify( "stop_loop" );
	self ally_start_calm_idle( "stealth" );
}

ally_rappel_stealth_movement_vertical( flag_to_end_on )
{
	//I don't know if this is needed
	//It's here because right now it is possible to kill everyone in the first encounter, before the "reached_combat_floor" flag is set
	//which means the ally will stay in this function
	if ( IsDefined( flag_to_end_on ) )
	{
		level endon( flag_to_end_on );
	}
	
	reached_combat_floor = self.animname + "_reached_combat_floor";
	if ( flag( reached_combat_floor ) )
	{
		flag_clear( reached_combat_floor );
	}
	
	self.rappel_move_direction = "";
	
  //desired_distance_squared_close = self.close_distance * self.close_distance;
  //desired_distance_squared_far   = self.far_distance * self.far_distance;
	
	desired_distance_too_close_sq = 100 * 100;
	desired_distance_close_sq	  = 220 * 220;
	desired_distance_far_sq		  = 420 * 420;
	
	desired_angles = ( 0, 90, 0 );
	self ForceTeleport( self.origin, desired_angles );
	
	self.out_volume = GetEnt( self.animname + "_stealth_out", "targetname" );
	self.in_volume	= GetEnt( self.animname + "_stealth_in", "targetname" );
	
	while ( !flag( reached_combat_floor ) )
	{
		goal_struct_z			= find_closest_struct_below_player();
		distance_from_player_sq = distance_2d_squared( self.origin, level.player.origin );
		higher_than_goal_z		= self.origin[ 2 ] > goal_struct_z;
		lower_than_goal_z		= self.origin[ 2 ] <= goal_struct_z;
		furthest_away			= self IsTouching( self.out_volume );
		furthest_back			= self IsTouching( self.in_volume );
		at_combat_floor			= goal_struct_z == level.vertical_struct[ level.vertical_struct.size - 1 ].origin[ 2 ];		
		
		if ( distance_from_player_sq < desired_distance_too_close_sq )
		{
			// player is really close so run away
			if ( !furthest_away )
			{
				ally_rappel_moving_change_direction( "away" );
			}
			else if ( higher_than_goal_z )
			{
				ally_rappel_moving_change_direction( "down" );
			}
			else if ( lower_than_goal_z )
			{
				ally_rappel_moving_stop_idle();
				if ( at_combat_floor )
					flag_set( reached_combat_floor );
			}
		}
		else if ( distance_from_player_sq < desired_distance_close_sq )
		{
			// player is close, but not too close so move away slowly when going down
			if ( !furthest_away )
			{
				if ( higher_than_goal_z )
					ally_rappel_moving_change_direction( "down_away" );
				else if ( lower_than_goal_z )
					ally_rappel_moving_change_direction( "away" );
			}
			else
			{
				if ( higher_than_goal_z )
				{
					ally_rappel_moving_change_direction( "down" );
				}
				else if ( lower_than_goal_z )
				{
					ally_rappel_moving_stop_idle();
					if ( at_combat_floor )
						flag_set( reached_combat_floor );
				}
			}
		}
		else if ( distance_from_player_sq >= desired_distance_far_sq )
		{
			// player is too far away, move back
			if ( !furthest_back )
			{
				if ( higher_than_goal_z )
					ally_rappel_moving_change_direction( "down_back" );
				else if ( lower_than_goal_z )
					ally_rappel_moving_change_direction( "back" );
			}
			else
			{
				if ( higher_than_goal_z )
					ally_rappel_moving_change_direction( "down" );
				else if ( lower_than_goal_z )
				{
					ally_rappel_moving_stop_idle();
					if ( at_combat_floor )
						flag_set( reached_combat_floor );
				}
			}
		}
		else if ( higher_than_goal_z )
		{
			ally_rappel_moving_change_direction( "down" );
		}
		else if ( lower_than_goal_z )
		{
			ally_rappel_moving_stop_idle();
			if ( at_combat_floor )
				flag_set( reached_combat_floor );
		}
		
		waitframe();
	}
}

//allies_first_floor_combat_behavior( flag_to_end_on, flag_for_cover_anims_to_end_on )
//{
//	level endon( flag_to_end_on );
//	level endon( self.stealth_broken_flag );
//	
//	if ( !flag( "allies_ready_first_combat_floor" ) )
//	{
//		if ( !flag( "enemies_aware" ) )
//		{
//			self thread allies_to_rappel_stealth_cover( flag_for_cover_anims_to_end_on );
//			flag_wait( "allies_ready_first_combat_floor" );
//		}
//	}
//	
//	if ( IsDefined( self.starting_to_hide ) )
//	{
//		while ( 1 )
//		{
//			if ( !IsDefined( self.starting_to_hide ) )
//			{
//				self.hiding = true;
//				break;
//			}
//			wait( 0.05 );
//		}
//	}
//	
//	if ( IsDefined( self.hiding ) )
//	{
//		self anim_single_solo( self, "hide_exit_" + self.animname );
//		self.hiding = undefined;
//	}
//	
//	self notify( "stop_loop" );
//	
//	//self ally_rappel_start_movement_horizontal( "stealth", "first", "first_floor_enemies_dead" );
//	self ally_rappel_start_movement_horizontal( "stealth", "first", "rappel_down_ready" );
//}

find_closest_struct_below_player()
{	
	goal_struct = undefined;
	
	for ( i = 0; i < level.vertical_struct.size; i++ )
	{
			if ( level.vertical_struct[ i ].origin[ 2 ] <= level.player.origin[ 2 ] )
			{
				goal_struct			   = level.vertical_struct[ i ].origin[ 2 ];
				level.last_goal_struct = goal_struct;
				break;
			}
	}
	if ( !IsDefined( goal_struct ) )
	{
		goal_struct =	level.last_goal_struct;
	}
	return goal_struct;
}

//allies_to_rappel_stealth_cover( flag_to_end_on )
//{
//	level endon( flag_to_end_on );
//	level endon( self.stealth_broken_flag );
//	level endon( "killed_out_of_order" );
//	
//	self notify( "stop_loop" );
//	self ally_stop_calm_idle();
//	
//	volume = GetEnt( self.animname + "_stealth_cover", "targetname" );
//	
//	//if ( !( self IsTouching( volume ) ) && self.last_volume != volume )
//	if ( !( self IsTouching( volume ) ) )
//	{
//		//if we're not already touching this volume, move towards it
//		//self anim_single_solo( self, "move_away_start" );
//		self thread anim_loop_solo( self, "move_away", "stop_loop" );
//		while ( 1 )
//		{
//			if ( self IsTouching( volume ) )
//			{
//				self notify( "stop_loop" );
//				//self anim_single_solo( self, "move_away_stop" );
//				break;
//			}
//			wait( 0.05 );
//		}
//	}
//	self thread rappel_stealth_cover_allies( flag_to_end_on );
//}
//
//rappel_stealth_cover_allies( flag_to_end_on )
//{
//	//level endon( flag_to_end_on );
//	//level endon( self.stealth_broken_flag );
//	
//	self.starting_to_hide			= true;
//	self anim_single_solo( self, "hide_enter_" + self.animname );
//	self.starting_to_hide = undefined;
//	
//	if ( !flag( flag_to_end_on ) && !flag( self.stealth_broken_flag ) && !flag( "killed_out_of_order" ) )
//	{
//		self thread rappel_stealth_cover_allies_internal( flag_to_end_on );
//	}
//}
//
//rappel_stealth_cover_allies_internal( flag_to_end_on )
//{
//	level endon( flag_to_end_on );
//	level endon( self.stealth_broken_flag );
//	level endon( "killed_out_of_order" );
//	
//	self.hiding = true;
//	
//	while ( 1 )
//	{
//		self thread anim_loop_solo( self, "hide_idle_" + self.animname, "stop_loop" );
//		wait( RandomFloatRange( 1.0, 3.5 ) );
//		self notify( "stop_loop" );
//		self anim_single_solo( self, "hide_peek_" + self.animname );
//		
//		wait( 0.05 );
//	}
//}