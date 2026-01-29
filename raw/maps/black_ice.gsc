#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;
#include maps\black_ice_util_ai;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main()
{	
	// const, don't change
	level.TIMESTEP = 0.05;
	template_level( "black_ice" );
	maps\createart\black_ice_art::main();
	maps\black_ice_fx::main();
	
	//for mocap stage use - should only run on test
	/#
	maps\_mocap_ar::main();
	#/
	

	set_default_start( "swim" );
	default_start( ::start_swim );
		
//	set_default_start( "swim" );
//	default_start( ::start_swim );
	
		   //   msg 			   func 				    loc_string 			      optional_func 	 
	add_start( "swim"			, ::start_swim			 , "Swim"				   , ::main_swim );
	add_start( "camp"			, ::start_camp			 , "Camp"				   , ::main_camp );
	add_start( "ascend"			, ::start_ascend		 , "Ascend"				   , ::main_ascend );
	add_start( "catwalks"		, ::start_catwalks		 , "Catwalks"			   , ::main_catwalks );
	add_start( "catwalks_end"	, ::start_catwalks_end	 , "Catwalks End"		   , ::main_catwalks_end );
	add_start( "barracks"		, ::start_barracks		 , "Barracks"			   , ::main_barracks );
	add_start( "common_room"	, ::start_common		 , "Common Room"		   , ::main_common );
	add_start( "flarestack"		, ::start_flarestack	 , "Flarestack"			   , ::main_flarestack );
	add_start( "refinery"		, ::start_refinery		 , "Refinery"			   , ::main_refinery );
	add_start( "tanks"			, ::start_tanks			 , "Tanks"				   , ::main_tanks );
	add_start( "engine_room"	, ::start_engine_room	 , "Engine Room"		   , ::main_engine_room );
	add_start( "mudpumps"		, ::start_mudpumps		 , "Mudpumps"			   , ::main_mudpumps );
	add_start( "pipe_deck"		, ::start_pipe_deck		 , "Pipe Deck"			   , ::main_pipe_deck );
	add_start( "command_outside", ::start_command_outside, "Command Center Outside", ::main_command );
	add_start( "command_inside" , ::start_command		 , "Command Center Inside" , ::main_command );
	add_start( "exfil"			, ::start_exfil			 , "Exfil"				   , ::main_exfil );
		
	mission_precache();
	
	intro_screen_create( &"BLACK_ICE_INTROSCREEN_LINE_1", &"BLACK_ICE_INTROSCREEN_LINE_5", &"BLACK_ICE_INTROSCREEN_LINE_2" );
	intro_screen_custom_func( ::introscreen );	
	
	maps\_load::main();
	//Set Spec colorscale dvar to make up for differentials between CG and NG
	setsaveddvar_cg_ng( "r_specularColorScale", 2.5, 9.01 );
	//Shootable Steam Pipes
	thread common_scripts\_pipes::main();
	level.pipesDamage = false;
	
	A_globals();
	
	setup_retreat_vols();
					
	mission_flag_inits();
	
	maps\black_ice_audio::main();
	maps\black_ice_anim::main();
	maps\_hand_signals::initHandSignals();
	// maps\black_ice_util::trig_stairs_setup();
	
	threat_group_inits();

	// Add vignette struct to all spawners
	array_thread( GetSpawnerArray(), maps\black_ice_vignette::vignette_setup );
	
	spawn_allies();	
	player_setup();
	
	mission_post_inits();
	vision_sets();
	
	thread objectives();
	
	thread oil_pumps_animate();
	
	// Turn on the detailed flare stack
	thread flarestack_swap();
	
	thread maps\black_ice_fx::fx_init();	
}

mission_flag_inits()
{
	maps\black_ice_swim::section_flag_inits();
	maps\black_ice_camp::section_flag_inits();
	maps\black_ice_ascend::section_flag_inits();
	maps\black_ice_catwalks::section_flag_inits();
	maps\black_ice_flarestack::section_flag_inits();	
	maps\black_ice_refinery::section_flag_inits();
	maps\black_ice_tanks_to_mud_pumps::section_flag_inits();
	maps\black_ice_pipe_deck::section_flag_inits();
	maps\black_ice_command::section_flag_inits();
	maps\black_ice_exfil::section_flag_inits();
}

mission_post_inits()
{
	maps\black_ice_swim::section_post_inits();
	maps\black_ice_flarestack::section_post_inits();
	maps\black_ice_refinery::section_post_inits();
	maps\black_ice_tanks_to_mud_pumps::section_post_inits();	
	maps\black_ice_pipe_deck::section_post_inits();
	maps\black_ice_command::section_post_inits();	
	maps\black_ice_exfil::section_post_inits();	
}

mission_precache()
{
	//maps\_weapon_selection_proto::loadout_selection_precache();
	PreCacheItem( "m4_grunt_reflex");
	PreCacheItem( "p99_tactical");
	PreCacheItem( "aps_underwater" );
	//PreCacheItem( "firegrenade" );
	PreCacheItem( "test_detonator_black_ice" );		
	
	precacheshellshock( "blackice_nosound" );
	PreCacheShellShock( "default" );
	precacheshellshock( "slowview" );
	
	PreCacheRumble( "tank_rumble" );
	PreCacheRumble( "helo_ladder_swing" );
	PreCacheRumble( "hind_flyover" );
	PreCacheRumble( "lever_feedback_light" );
	PreCacheRumble( "lever_feedback_heavy" );
	
	PreCacheItem( "hellfire_missile_af_caves" );	
	
	PrecacheModel( "weapon_walther_p99_iw5" );	
	PreCacheModel( "viewhands_ranger_dirty" );
	
	objective_string_precache();
	maps\black_ice_precache::main();
	maps\black_ice_swim::section_precache();
	maps\black_ice_camp::section_precache();	
	maps\black_ice_ascend::section_precache();
	maps\black_ice_catwalks::section_precache();
	maps\black_ice_flarestack::section_precache();	
	maps\black_ice_refinery::section_precache();	
	maps\black_ice_tanks_to_mud_pumps::section_precache();
	maps\black_ice_pipe_deck::section_precache();	
	maps\black_ice_command::section_precache();	
	maps\black_ice_exfil::section_precache();	
}

A_globals()
{
	level._enemies = [];
	level._allies = [];
	level._bravo = [];
	level._vehicles = [];	
}

threat_group_inits()
{
	// create bias groups
	CreateThreatBiasGroup( "bravo" );
	CreateThreatBiasGroup( "player" );
	CreateThreatBiasGroup( "bc_lmg" );
	CreateThreatBiasGroup( "cw_low_balcony" );
	
	// Group to ignore player's team
	CreateThreatBiasGroup( "ignore_allies" );
	SetIgnoreMeGroup( "allies", "ignore_allies" );
	SetIgnoreMeGroup( "ignore_allies", "allies" );
	
	// Group to ignore bravo team
	CreateThreatBiasGroup( "ignore_bravo" );
	SetIgnoreMeGroup( "bravo", "ignore_bravo" );
}

//*******************************************************************
// 		                                                   			*
//                                                                  *
//*******************************************************************

vision_sets()
{				
	vision_watcher( "flag_vision_campinteriors"	, "black_ice_tent_interior", 1.5, "black_ice_basecamp", 1.5 );
	vision_watcher( "flag_vision_refinery_to_tanks"	, "", 0, "", 0 ); 
		
	thread flag_watcher( "flag_vision_engine_room", ::vision_engine_room_start, ::vision_engine_room_end );
	thread flag_watcher( "flag_vision_mudpumps", ::vision_mudpumps_start   , ::vision_mudpumps_end );		
	
	// TODO: <BMARV> Need to transition properly into the proximity heat stuff!
//	thread flag_watcher( "flag_vision_pipedeck_heat_start", maps\black_ice_fx::heat_column_fx );
	
	vision_watcher( "flag_vision_pipedeck_off"	, "", 0, "", 0 ); 
	vision_watcher( "flag_vision_pipedeck_on"	, "black_ice_pipedeck", 0, "black_ice_pipedeck", 0 );
	vision_watcher( "flag_vision_command"	, "black_ice_command"	, 3.0	   , "black_ice"	   , 3.0 );
	vision_watcher( "flag_vision_exfil_deck", "black_ice_exfil_deck", 1.5	   , "black_ice_flyout", 2.0 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vision_engine_room_start()
{	
	level.player thread maps\black_ice_tanks_to_mud_pumps::player_smoke_duck();	
}

vision_engine_room_end()
{		
	level.player thread maps\black_ice_tanks_to_mud_pumps::player_smoke_duck_end();		
}

vision_mudpumps_start()
{		
	// piggy back fx
	exploder ( "mud_pumps" );
	exploder ( "mud_pumps_lights" );
	stop_exploder ( "engineroom_01" );
}
	
vision_mudpumps_end()
{		
	// piggy back fx
	stop_exploder ( "mud_pumps" );
	stop_exploder ( "mud_pumps_lights" );
	stop_exploder ( "engineroom_02" );
}

//*******************************************************************
// swim		                                                   		*
//                                                                  *
//*******************************************************************

start_swim()
{		
	maps\black_ice_swim::start();	
//	level.player maps\_weapon_selection_proto::loadout_selection_menu();
	weapon_alt_check();
}

main_swim()
{
	// Turn on the optimized flare stack
	thread flarestack_swap( true );
	
	maps\black_ice_swim::main();
}

//*******************************************************************
// camp		                                                   		*
//                                                                  *
//*******************************************************************

start_camp()
{
	// Turn on the optimized flare stack
	thread flarestack_swap( true );
	
	maps\black_ice_camp::start();
	weapon_alt_check();
}

main_camp()
{		
	maps\black_ice_camp::main();
}

//*******************************************************************
// ascend		                                                   	*
//                                                                  *
//*******************************************************************

start_ascend()
{
	maps\black_ice_ascend::start();
	weapon_alt_check();
}

main_ascend()
{
	maps\black_ice_ascend::main();
}

//*******************************************************************
// catwalks		                                                   	*
//                                                                  *
//*******************************************************************

start_catwalks()
{
	maps\black_ice_catwalks::start_catwalks();
	weapon_alt_check();
}

main_catwalks()
{
	maps\black_ice_catwalks::main_catwalks();
}

start_catwalks_end()
{
	maps\black_ice_catwalks::start_catwalks_end();
	weapon_alt_check();
}

main_catwalks_end()
{
	maps\black_ice_catwalks::catwalks_end();
}

//*******************************************************************
// barracks		                                                   	*
//                                                                  *
//*******************************************************************

start_barracks()
{
	maps\black_ice_catwalks::start_barracks();
	weapon_alt_check();
}

main_barracks()
{
	maps\black_ice_catwalks::main_barracks();
}

//*******************************************************************
// common room	                                                   	*
//                                                                  *
//*******************************************************************

start_common()
{
	maps\black_ice_catwalks::start_common();
	weapon_alt_check();
}

main_common()
{
	maps\black_ice_catwalks::main_common();
}


//*******************************************************************
// flarestack                                                			*
//                                                                  *
//*******************************************************************

start_flarestack()
{
	// CF - removing GL speciifc calls
	// CF - removing demigod if starting at GL CP
	//if( level.start_point == "flarestack" )
	//{
	//	level.player enabledeathshield (true);
	//}
	maps\black_ice_flarestack::start();
	weapon_alt_check();
}

main_flarestack()
{
	autosave_by_name( "flarestack" );
	
	maps\black_ice_flarestack::main();
}

//*******************************************************************
// refinery                                                			*
//                                                                  *
//*******************************************************************

start_refinery()
{
	maps\black_ice_refinery::start();
	weapon_alt_check();
}

main_refinery()
{
	autosave_by_name( "refinery" );
	maps\black_ice_refinery::main();
}

//*******************************************************************
// tanks                                                			*
//                                                                  *
//*******************************************************************

start_tanks()
{
	maps\black_ice_tanks_to_mud_pumps::start_tanks();
	weapon_alt_check();
	maps\black_ice_audio::sfx_fire_tower_spawn();
	maps\black_ice_refinery::util_derrick_destroy_quick();
}

main_tanks()
{
	autosave_by_name( "tanks" );
	maps\black_ice_tanks_to_mud_pumps::main_tanks();
}

//*******************************************************************
// engine room                                             			*
//                                                                  *
//*******************************************************************

start_engine_room()
{
	maps\black_ice_tanks_to_mud_pumps::start_engine_room();
	weapon_alt_check();
	
	//AUDIO: spawning all the fire tower and metal sounds
	thread maps\black_ice_audio::sfx_fire_tower_spawn();
	
	//AUDIO: also calling all the correct volume and filter settings as well
	thread maps\black_ice_audio::sfx_fire_tower_trigger_logic( 6, 1 );
	
	maps\black_ice_refinery::util_derrick_destroy_quick();
}

main_engine_room()
{
	autosave_by_name( "engine_room" );
	maps\black_ice_tanks_to_mud_pumps::main_engine_room();
}

//*******************************************************************
// mudpumps                                             			*
//                                                                  *
//*******************************************************************

start_mudpumps()
{
	maps\black_ice_tanks_to_mud_pumps::start_mudpumps();
	weapon_alt_check();
	//spawning all the fire tower and metal sounds
	maps\black_ice_audio::sfx_fire_tower_spawn();
	//also calling all the correct volume and filter settings as well
	maps\black_ice_audio::sfx_fire_tower_trigger_logic( 6, 1 );
	maps\black_ice_refinery::util_derrick_destroy_quick();
}

main_mudpumps()
{
	autosave_by_name( "mudpumps" );
	maps\black_ice_tanks_to_mud_pumps::main_mudpumps();
}

//*******************************************************************
// Pipe Deck			                                 			*
//                                                                  *
//*******************************************************************

start_pipe_deck()
{
	maps\black_ice_pipe_deck::start();
	weapon_alt_check();
	
	//AUDIO: spawning tower of fire sounds
	thread maps\black_ice_audio::sfx_fire_tower_spawn();
	
	maps\black_ice_refinery::util_derrick_destroy_quick();
}

main_pipe_deck()
{
	autosave_by_name( "pipe_deck" );
	maps\black_ice_pipe_deck::main();
}

//*******************************************************************
// command center outside                              				*
//                                                                  *
//*******************************************************************

start_command_outside()
{
	maps\black_ice_command::start_outside();
	weapon_alt_check();
	
	//AUDIO: spawning tower of fire sounds
	thread maps\black_ice_audio::sfx_fire_tower_spawn();
	
	maps\black_ice_refinery::util_derrick_destroy_quick();
}

//*******************************************************************
// command center                                   				*
//                                                                  *
//*******************************************************************

start_command()
{
	maps\black_ice_command::start_inside();
	weapon_alt_check();
	
	//AUDIO: spawning tower of fire sounds
	thread maps\black_ice_audio::sfx_fire_tower_spawn();
	
	maps\black_ice_refinery::util_derrick_destroy_quick();
}

main_command()
{
	autosave_by_name( "command" );
	maps\black_ice_command::main();
}

//*******************************************************************
// exfil		                                                   	*
//                                                                  *
//*******************************************************************

start_exfil()
{
	maps\black_ice_exfil::start();
	weapon_alt_check();
	
	maps\black_ice_refinery::util_derrick_destroy_quick();
}

main_exfil()
{
	autosave_by_name( "exfil" );
	maps\black_ice_exfil::main();
}

//*******************************************************************
// 		                                                   			*
//                                                                  *
//*******************************************************************

weapon_alt_check()
{
	// Make sure scope is down
	if( level.default_weapon == "m4_hybrid_grunt_optim" )
	{
		level.default_weapon = "alt_" + level.default_weapon;
		level.player SwitchToWeaponImmediate( level.default_weapon );
	}
}

//*******************************************************************
// 		                                                   			*
//                                                                  *
//*******************************************************************

objective_string_precache()
{
	PrecacheString( &"BLACK_ICE_OBJ_SWIM_DETONATE" );
	PrecacheString( &"BLACK_ICE_OBJ_CAMP_CLEAR_CAMP" );
	PrecacheString( &"BLACK_ICE_OBJ_ASCEND_ASCEND" );
	PrecacheString( &"BLACK_ICE_OBJ_FLARESTACK_FIGHT_TO" );
	PrecacheString( &"BLACK_ICE_OBJ_FLARESTACK_SHUT_OFF" );
	PrecacheString( &"BLACK_ICE_OBJ_COMMAND_FIGHT_TO" );
	PrecacheString( &"BLACK_ICE_OBJ_COMMAND_DISABLE_SUPPRESSION" );
	PrecacheString( &"BLACK_ICE_OBJ_EXFIL_GET_TO_HELI" );
}
	
objectives()
{
	switch( level.start_point )
	{
		case "swim":
			
			// Destroy ice
			level waittill( "notify_swim_dialog5_1" );
			objective_add( obj( "obj_swim_detonate_charges" ), "current", &"BLACK_ICE_OBJ_SWIM_DETONATE" );
			flag_wait( "flag_swim_breach_detonate");
			objective_complete( obj( "obj_swim_detonate_charges" ));					
			
		case "camp":
			
			// Fight to ascend point
			level waittill( "bc_player_ready" );
			objective_add( obj( "obj_camp_clear_camp" ), "current", &"BLACK_ICE_OBJ_CAMP_CLEAR_CAMP" );
			level waittill( "stop_ascend_fic" );
			objective_complete( obj( "obj_camp_clear_camp" ));
		
		case "ascend":
			
			// Ascend
			objective_add( obj( "obj_ascend_ascend" ), "current", &"BLACK_ICE_OBJ_ASCEND_ASCEND" );	
			flag_wait( "flag_bravo_ascend_complete" );
			objective_complete( obj( "obj_ascend_ascend" ));				
			
		case "catwalks":
		case "barracks":
		case "common_room":
			
			// Fight to flarestack room
			objective_add( obj( "obj_flarestack_fight_to" ), "current", &"BLACK_ICE_OBJ_FLARESTACK_FIGHT_TO" );	
			flag_wait( "flag_flarestack_scene_start" );
			objective_complete( obj( "obj_flarestack_fight_to" ));
						
		case "flarestack":
			
			// Shut off flarestack
			level waittill( "notify_activate_flarestack_console" );
			objective_add( obj( "obj_flarestack_shut_off" ), "current", &"BLACK_ICE_OBJ_FLARESTACK_SHUT_OFF" );
			level waittill( "notify_flare_stack_off" );
			objective_complete( obj( "obj_flarestack_shut_off" ));	
			flag_wait( "flag_flarestack_end" );			
			
		case "refinery":			
		case "tanks":
		case "engine_room":
		case "pipe_deck":
			
			// Fight to command center
			objective_add( obj( "obj_command_fight_to_command_center" ), "current", &"BLACK_ICE_OBJ_COMMAND_FIGHT_TO" );
			level waittill( "notify_pipedeck_final_battle_start" );
			objective_complete( obj( "obj_command_fight_to_command_center" ));
			
			// Take out MGs
			objective_add( obj( "obj_command_take_out_mgs" ), "current", &"BLACK_ICE_OBJ_PIPEDECK_TURRETS" );
			flag_wait( "flag_pipe_deck_end" );
			objective_complete( obj( "obj_command_take_out_mgs" ));
			
		case "command_outside":
		case "command_inside":
			
			// Disable fire suppression
			flag_wait( "flag_objective_fire_supression" );
			objective_add( obj( "obj_command_disable_suppression" ), "current", &"BLACK_ICE_OBJ_COMMAND_DISABLE_SUPPRESSION" );
			flag_wait( "flag_command_done" );
			objective_complete( obj( "obj_command_disable_suppression" ));			
			
		case "exfil":
			
			// Get to the heli			
			objective_add( obj( "obj_exfil_get_to_heli" ), "current", &"BLACK_ICE_OBJ_EXFIL_GET_TO_HELI" );
			level waittill( "player_ladder_success" );
			objective_complete( obj( "obj_exfil_get_to_heli" ));
			
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
oil_pumps_animate()
{
	oil_pumps = GetEntArray( "oil_pump", "targetname" );
	
	foreach ( pump in oil_pumps )
	{
		pump.animname = "oil_pump";
		pump maps\_utility::assign_animtree();
		
		// Randomize the rate
		rate = RandomFloatRange( 0.5, 2.0 );
		
		pump SetAnim( level.scr_anim[ "oil_pump" ][ "motion" ], 1.0, 0.1, rate );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
trains_periph_logic( wait_time, delete_on_completion )
{	
	NUM_TRAINS = 6;
	
	for ( i = 0; i < NUM_TRAINS; i++ )
	{
		trains = GetEntArray( "train_" + i, "targetname" );
		train_control_node = GetEnt( "train_control_node_" + i, "targetname" );
		
		train_control_node.init_origin = train_control_node.origin;
	
		train_control_node.trains = [];
		
		foreach( train in trains )
		{
			train Show();
			
			train LinkTo( train_control_node );
			
			train_control_node.trains[ train_control_node.trains.size ] = train;
		}
	
		thread trains_move( wait_time, train_control_node, delete_on_completion );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
trains_move( wait_time, train_control_node, delete_on_completion )
{
	wait wait_time;
	
	TRAIN_SPEED = 288.0;
	DIST_SQ_CHECK = 100.0;
	
	train_target_node = GetEnt( "train_target_node", "targetname" );
	
	// d = vt
	d = TRAIN_SPEED * level.TIMESTEP;
	
	vect = ( train_target_node.origin - train_control_node.origin );
	while ( LengthSquared( vect ) > DIST_SQ_CHECK )
	{
		vect = ( train_target_node.origin - train_control_node.origin );
		vect_n = VectorNormalize( vect );
	
		train_control_node.origin += ( vect_n * d );
		
		wait level.TIMESTEP;
	}
	
	if ( delete_on_completion )
	{
		// Once the train gets to the destination, stop the motion and destroy it
		foreach( train in train_control_node.trains )
		{
			train Delete();
		}
		
		train_control_node Delete();
	}
	else
	{
		// Otherwise, hide, then reset the positions back to original
		foreach( train in train_control_node.trains )
		{
			train Hide();
		}
				
		train_control_node.origin = train_control_node.init_origin;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flarestack_swap( optimize )
{
	flarestack = GetEntArray( "flamestack_anim", "targetname" );
	flarestack_optimized = GetEntArray( "flarestack_optimized", "targetname" );
	
	if ( IsDefined( optimize ) && optimize )
	{
		// Hide the detailed flarestack and unhide the budget version
		foreach ( ent in flarestack )
		{
			ent Hide();
		}
		
		foreach ( ent in flarestack_optimized )
		{
			ent Show();
		}
	}
	else
	{
		// Show the detailed flarestack and hide the budget version
		foreach ( ent in flarestack_optimized )
		{
			ent Hide();
		}
		
		foreach ( ent in flarestack )
		{
			ent Show();
		}
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

introscreen()
{
	maps\_introscreen::introscreen( undefined, 2 );
}