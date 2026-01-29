#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_vehicle_code;
#include maps\_vehicle_aianim;
#include maps\clockwork_code;
#include maps\_vehicle_spline_zodiac;
#include animscripts\hummer_turret\common;

clockwork_exfil_pre_load()
{
	PreCacheItem( "rpg_straight" );
	PreCacheItem( "xm25_fast" );
	PreCacheItem( "ak47_silencer_reflex_iw6" );
	PreCacheItem( "minigun_m1a1" );
	PreCacheItem( "minigun_m1a1_fast" );
	//PreCacheModel( "vehicle_russian_oscar2_sub" );
	
	ice_effects_init();
	
	// Global Flags
	flag_init( "player_dynamic_move_speed" );
	flag_init( "player_DMS_allow_sprint" );
	
	// Section Flags
	flag_init( "exfil_finished" );
	flag_init( "chaos_finished" );
	
	// Local Flags
	flag_init( "spawn_jeeps" );
	flag_init( "elevator_open" );
	flag_init( "elevator_enemies_start" );
	//flag_init( "elevator_weapons_down" );
	//flag_init( "elevator_limp" );
	//flag_init( "door_close" );
	//flag_init( "door_open" );
	
	flag_init( "ele_anim_done");
	flag_init( "start_exfil_ride" );
	flag_init( "exfil_fire_fail" );
	flag_init( "scientist_interview" );
	flag_init( "chaos_garage_move" );
	flag_init( "chaos_meetupvo_start" );
	flag_init( "chaos_commandervo_done" );
	flag_init( "meetup_vo_done" );
	flag_init( "punchit_go" );
	flag_init( "punchit_exfil_hot" );
	flag_init( "chase_punch_it" );
	flag_init( "punchit_car_one" );
	flag_init( "punchit_car_two" );
	flag_init( "gate_crash_player" );
	flag_init( "exfil_blockade_ram" );
	flag_init( "hand_wait" );
	flag_init( "baker_in_jeep" );
	flag_init( "baker_ready" );
	flag_init( "exfil_player_land" );
	flag_init( "kill_endingjeep" );
	flag_init( "allies_finished_defend_anims");
	// fx stopped working
	flag_init( "cagelight" );
	flag_init( "tubelight_parking" );
	flag_init( "in_elevator_ally_01" );
	flag_init( "in_elevator_ally_02" );
	flag_init( "in_elevator_ally_03" );
	PreCacheModel("viewhands_player_yuri");
	level.player_viewhand_model = "viewhands_player_yuri"; // required for dog code
	
	level.switchactive 	= 1;
	level.justplayed 	= 0;
}

setup_chaos()
{
	level.start_point = "chaos";
	
	setup_player();
	spawn_allies();
	
	array_thread( level.allies, ::set_ignoreall, true );
	flag_set( "to_cqb" );
	flag_set( "defend_finished" );
	flag_set( "cypher_defend_close_door" );
		
	battlechatter_off( "allies" );
	vision_set_changes( "clockwork_indoor", 0 );
	flag_set( "allies_finished_defend_anims");
	
	maps\clockwork_audio::checkpoint_chaos();
	
	hide_dufflebags();
	exploder( 5 );
}

begin_chaos()
{
								 //   key 			      func 				   
	array_spawn_function_noteworthy( "chaos_patrollers", ::exfil_alert_handle );
	array_spawn_function_noteworthy( "exfil_patrollers", ::exfil_alert_handle );
	
	//cam = GetEnt( "pip_cam_walkout1", "targetname" );
	//thread maps\clockwork_pip::pip_enable( cam );
	
	thread maps\clockwork_interior_nvg::control_nvg_staticscreens_on();
	
	flag_clear( "player_DMS_allow_sprint" );
	level.drs_ahead_test = maps\_utility_code::dynamic_run_ahead_test;
	
	thread fire_fail_exfil_vo();
	thread elevator_movement();
	thread security_room_transition();
	
	toggle_visibility("vault_frame_destroyed_hotmetal", false);  
		
	//Wait for this section to finish.
	flag_wait( "chaos_finished" );
}

setup_exfil()
{
	level.start_point = "exfil";
	
	setup_player();
	spawn_allies();
	level.exfil_checkpoint = 1;
	 
			  //   entities      process 	      var1   
	array_thread( level.allies, ::set_ignoreall, true );
	array_thread( level.allies, ::set_ignoreme , true );
	
	flag_set( "defend_finished" );
		
	battlechatter_off( "allies" );
	vision_set_changes( "clockwork_indoor_security", 0 );
	
	hide_dufflebags();

	maps\_treadfx::setvehiclefx( "script_vehicle_gaz_tigr_turret_physics", "snow", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_gaz_tigr_turret_physics", "ice", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_gaz_tigr_turret_physics", "slush", "fx/treadfx/tread_snow_night_clk" );
	
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics_turret", "snow", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics_turret", "ice", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics_turret", "slush", 	"fx/treadfx/tread_snow_night_clk" );
	
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics", "snow", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics", "ice", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics", "slush", "fx/treadfx/tread_snow_night_clk" );

	maps\clockwork_audio::checkpoint_exfil();
}

begin_exfil()
{
	// spline setup
	level.POS_LOOKAHEAD_DIST = 200;
	level.DODGE_DISTANCE	 = 50;
	init_vehicle_splines();
	level.enemy_snowmobiles_max = 0;  //number of free snowmobiles to spawn. 0 due to randomn behaviors.
	level.player.offset			= 525;//spline variable to kill off enemies.
	
	level.icehole_to_move = 0; // which icehole to use first.
		
	// vehicle array setup
	level.enemy_jeep_a		= [];//path a jeeps0
	level.enemy_jeep_b		= [];//path b jeeps
	level.enemy_jeep_s		= [];//spline jeeps
	level.enemy_snowmobile	= [];
	level.enemy_jeep_turret = [];
	level.otherallies		= [];
	level.allcrashes		= [];
	
	flag_set( "punchit_exfil_hot" );
	
	array_spawn_function_noteworthy( "exfil_snowmobile", ::snowmobile_sounds );
		
	// spawn a proxy jeep if level.jeep doesn't exist.
	if ( !IsDefined( level.jeep ) )
		level.jeep = spawn_vehicle_from_targetname( "chaos_level_jeep_proxy" );
	
	// only if chaos was not played
	if ( IsDefined( level.exfil_checkpoint ) )
	{
		array_spawn_function_noteworthy( "exfil_patrollers", ::exfil_alert_handle );
		flag_set( "elevator_open" );
		thread fire_fail_exfil_vo();
		thread hold_fire_unless_ads( "ally_start_path_exfil" );
	}
	
	level.crashed_trucks = getent( "crashed_trucks", "targetname" );
	level.crashed_truck1 = getent( "crashed_truck1", "targetname" );
	level.crashed_truck2 = getent( "crashed_truck2", "targetname" );
	level.crashed_trucks hide();
	level.crashed_truck1 hide();
	level.crashed_truck2 hide();
	
	thread in_to_jeep();
	thread crash_event();
	thread headon_event();
	thread canal_event();
	thread tank_event();
	thread bridge_event();
	thread new_cliff_moment();
	thread new_nxsub_breach_moment();
	//thread sub_breach_moment();
	
	//Wait for this section to finish.
	flag_wait( "exfil_finished" );
	
	nextmission();
}

// Subcheckpoints

setup_exfil_alt()
{
	maps\_treadfx::setvehiclefx( "script_vehicle_gaz_tigr_turret_physics", "snow", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_gaz_tigr_turret_physics", "ice", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_gaz_tigr_turret_physics", "slush", "fx/treadfx/tread_snow_night_clk" );
	
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics_turret", "snow", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics_turret", "ice", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics_turret", "slush", 	"fx/treadfx/tread_snow_night_clk" );
	
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics", "snow", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics", "ice", 	"fx/treadfx/tread_snow_night_clk" );
	maps\_treadfx::setvehiclefx( "script_vehicle_warrior_physics", "slush", "fx/treadfx/tread_snow_night_clk" );

	setup_player();
	spawn_allies();
	thread vision_set_changes( "clockwork_outdoor_exfill_02", 1 );
	hide_dufflebags();
}

begin_exfil_tank()
{
	level endon( "exfil_finished" );
	thread maps\clockwork_audio::checkpoint_tank();
		
	// spline setup
	level.POS_LOOKAHEAD_DIST = 200;
	level.DODGE_DISTANCE	 = 50;
	init_vehicle_splines();
	level.enemy_snowmobiles_max = 0;
	level.player.offset			= 525;
	level.icehole_to_move		= 0;
	
	// vehicle array setup
	level.enemy_jeep_a		= [];//path a jeeps
	level.enemy_jeep_b		= [];//path b jeeps
	level.enemy_jeep_s		= [];//spline jeeps
	level.enemy_jeep_turret = [];
	level.enemy_snowmobile	= [];
	level.allcrashes		= [];
	level.allyJeep			= 1;
	
	// spawn jeeps
	playerJeep		 = spawn_vehicles_from_targetname_and_drive( "jeep_exfil_tank_ride_player" );
	level.playerJeep = playerJeep[ 0 ];
	
	wait 0.01;
	
	place_allies_in_jeep();
	
	thread enemy_zodiacs_spawn_and_attack();
	
	level.player.progress += 14750;
	
	// test switch functions
	level.crashed_trucks = getent( "crashed_trucks", "targetname" );
	level.crashed_truck1 = getent( "crashed_truck1", "targetname" );
	level.crashed_truck2 = getent( "crashed_truck2", "targetname" );
	level.crashed_trucks hide();
	level.crashed_truck1 hide();
	level.crashed_truck2 hide();
	
	thread tank_event();
	thread bridge_event();
	thread new_cliff_moment();
	thread new_nxsub_breach_moment();
		
	//Wait for this section to finish.
	flag_wait( "exfil_finished" );
}

begin_exfil_bridge()
{
	level endon( "exfil_finished" );
	thread maps\clockwork_audio::checkpoint_bridge();
	
	if ( IsDefined( "level.exfil_checkpoint" ) )
	
	// spline setup
	level.POS_LOOKAHEAD_DIST = 200;
	level.DODGE_DISTANCE	 = 50;
	init_vehicle_splines();
	level.enemy_snowmobiles_max = 0;
	level.player.offset			= 525;
	level.icehole_to_move		= 0;
	
	// vehicle array setup
	level.enemy_jeep_a		= [];//path a jeeps
	level.enemy_jeep_b		= [];//path b jeeps
	level.enemy_jeep_s		= [];//spline jeeps
	level.enemy_jeep_turret = [];
	level.enemy_snowmobile	= [];
	level.allcrashes		= [];
	level.allyJeep			= 1;
	
	// spawn jeeps
	playerJeep		 = spawn_vehicles_from_targetname_and_drive( "jeep_exfil_bridge_ride_player" );
	level.playerJeep = playerJeep[ 0 ];
	
	wait 0.01;
	
	place_allies_in_jeep();
	
	thread enemy_zodiacs_spawn_and_attack();
	
	level.player.progress += 34000;
	
	level.crashed_trucks = getent( "crashed_trucks", "targetname" );
	level.crashed_truck1 = getent( "crashed_truck1", "targetname" );
	level.crashed_truck2 = getent( "crashed_truck2", "targetname" );
	level.crashed_trucks hide();
	level.crashed_truck1 hide();
	level.crashed_truck2 hide();
	
	thread tank_event();
	thread bridge_event();
	thread new_cliff_moment();
	thread new_nxsub_breach_moment();
		
	//Wait for this section to finish.
	flag_wait( "exfil_finished" );
}

begin_exfil_cave()
{
	level endon( "exfil_finished" );
	thread maps\clockwork_audio::checkpoint_cave();
	
	if ( IsDefined( "level.exfil_checkpoint" ) )
	
	// spline setup
	level.POS_LOOKAHEAD_DIST = 200;
	level.DODGE_DISTANCE	 = 50;
	init_vehicle_splines();
	level.enemy_snowmobiles_max = 0;
	level.player.offset			= 525;
	level.icehole_to_move		= 0;
	
	level.turret_rounds	= 3;
	
	// vehicle array setup
	level.enemy_jeep_a		= [];//path a jeeps
	level.enemy_jeep_b		= [];//path b jeeps
	level.enemy_jeep_s		= [];//spline jeeps
	level.enemy_jeep_turret = [];
	level.enemy_snowmobile	= [];
	level.allcrashes		= [];
	level.allyJeep			= 1;
	
	// spawn jeeps
	playerJeep		 = spawn_vehicles_from_targetname_and_drive( "jeep_exfil_cave_ride_player" );
	level.playerJeep = playerJeep[ 0 ];
	
	wait 0.01;
	
	place_allies_in_jeep();
	
	thread enemy_zodiacs_spawn_and_attack();
	
	level.player.progress += 61000;
	
	level.crashed_trucks = getent( "crashed_trucks", "targetname" );
	level.crashed_truck1 = getent( "crashed_truck1", "targetname" );
	level.crashed_truck2 = getent( "crashed_truck2", "targetname" );
	level.crashed_trucks hide();
	level.crashed_truck1 hide();
	level.crashed_truck2 hide();
	
	thread new_cliff_moment();
	thread new_nxsub_breach_moment();
		
	//Wait for this section to finish.
	flag_wait( "exfil_finished" );
}

//begin_exfil_sub()
//{
//	level endon( "exfil_finished" );
//	thread maps\clockwork_audio::checkpoint_sub();
//	
//	if ( IsDefined( "level.exfil_checkpoint" ) )
//	
//	// spline setup
//	level.POS_LOOKAHEAD_DIST = 200;
//	level.DODGE_DISTANCE	 = 50;
//	init_vehicle_splines();
//	level.enemy_snowmobiles_max = 0;
//	level.player.offset			= 525;
//	level.icehole_to_move		= 0;
//	
//	// vehicle array setup
//	level.enemy_jeep_a		= [];//path a jeeps
//	level.enemy_jeep_b		= [];//path b jeeps
//	level.enemy_jeep_s		= [];//spline jeeps
//	level.enemy_jeep_turret = [];
//	level.enemy_snowmobile	= [];
//	level.allcrashes		= [];
//	level.allyJeep			= 1;
//	
//	// spawn jeeps
//	playerJeep		 = spawn_vehicles_from_targetname_and_drive( "jeep_exfil_sub_ride_player" );
//	level.playerJeep = playerJeep[ 0 ];
//	
//	wait 0.01;
//	
//	place_allies_in_jeep();
//	
//	level.crashed_trucks = getent( "crashed_trucks", "targetname" );
//	level.crashed_truck1 = getent( "crashed_truck1", "targetname" );
//	level.crashed_truck2 = getent( "crashed_truck2", "targetname" );
//	level.crashed_trucks hide();
//	level.crashed_truck1 hide();
//	level.crashed_truck2 hide();
//	
//	flag_set( "enemy_cave_spawn" );
//	
//	thread new_nxsub_breach_moment();
//}

place_allies_in_jeep()
{	
	level.passallies[ 0 ]					  = level.allies[ 0 ]; //baker
	level.allies[ 0 ].script_startingposition = 1;
	level.passallies[ 1 ]					  = level.allies[ 1 ]; //keegan
	level.allies[ 1 ].script_startingposition = 0;
	level.passplayer[ 0 ]					  = level.allies[ 2 ]; //cipher
	level.allies[ 2 ].script_startingposition = 2;
	
	wait 0.01;
	
	// place guys in jeep.
	foreach ( guy in level.allies )
	{
		level.playerJeep thread maps\_vehicle_aianim::guy_enter( guy );
	}
	
	wait 0.01;
	
	// place player in jeep
	level.player PlayerLinkTo( level.playerJeep, "tag_guy_turret", .5 );
	level.player SetStance( "stand" );
	
	//make ally in your jeep crouch attack
    level.allies[ 2 ] notify( "newanim" );
	level.allies[ 2 ].desired_anim_pose = "crouch";
	level.allies[ 2 ]AllowedStances							   ( "crouch" );
	level.allies[ 2 ]thread animscripts\utility::UpdateAnimPose(  );
	level.allies[ 2 ]AllowedStances							   ( "crouch" );

	level.allies[ 2 ].baseaccuracy			= 0.1;
	level.allies[ 2 ].accuracystationarymod = 0.5;
	
	flag_set( "start_icehole_shooting" );
	
	level.player thread handle_grenade_launcher();
	level.player PlayerLinkToDelta( level.playerJeep, "tag_guy_turret", 0.1, 360, 360, 30, 20, true );
	level.playerJeep.mgturret[ 0 ] UseBy( level.player );
	level.player DisableTurretDismount();
	level.playerJeep thread fire_grenade();
	thread player_viewhands_minigun( level.playerJeep.mgturret[ 0 ], "viewhands_player_yuri" );
	
	thread kill_player();
}

      /*** Event Code** */
//*** Start of Chaos Transition Code ***//

#using_animtree( "generic_human" );
elevator_movement()
{	
	elevator   		= GetEnt( "elevator_to_exfil", "targetname" );
	startrdoor 		= GetEnt( "start_stop_exfil_elevator_rdoor", "targetname" );
	startldoor 		= GetEnt( "start_stop_exfil_elevator_ldoor", "targetname" );
	startpoint 		= getstruct_delete( "start_stop_exfil_elevator", "targetname" );
	endpoint   		= getstruct_delete( "end_stop_exfil_elevator", "targetname" );
	blocker	   		= GetEnt( "chaos_elevator_block", "targetname" );
	elevator_models = GetEntArray( "elevator_to_exfil_models", "targetname" );
		
	blocker NotSolid();
	
	array_spawn_function_noteworthy( "chaos_patrollers", ::disable_aim_assist );
	
	// Open door to garage
	if ( !IsDefined( level.tunnel_door ) )
	{
		level.tunnel_door		= spawn_anim_model( "vault_door" );
		level.tunnel_door_scene = GetEnt( "lights_out_scene", "targetname" );
		level.tunnel_door_scene thread anim_first_frame_solo( level.tunnel_door, "tunnel_vault" );
		
		level.tunnel_door_clip = GetEnt( "entrance_door_clip", "targetname" );
		level.tunnel_door_clip LinkTo( level.tunnel_door );		
		level.tunnel_door_clip ConnectPaths();
	}
	else
	{
		level.tunnel_door_scene thread anim_first_frame_solo( level.tunnel_door, "tunnel_vault" );
		level.tunnel_door_clip ConnectPaths();
	}
	
	head_model = "head_elite_pmc_head_b";
	bloodstains = GetEntArray( "chaos_decals", "targetname" );
	foreach( blood in bloodstains )
	{
		blood show();
		
		if( IsDefined( blood.animation ) )
		{
			blood.animname = "dead"; 
			blood UseAnimTree( #animtree );
			blood thread anim_loop_solo( blood, blood.animation );
			
			blood Attach( head_model, "j_spine4", true );
		}
	}
	
	collision = getent( "chaos_collision", "targetname" );
	collision_struct = getstruct( "chaos_collision_origin", "targetname" );
	
	collision moveto( collision_struct.origin, .05 );
	
	//collision DisconnectPaths();
	//wait 05;
	//collision ConnectPaths();
	

	
	flag_set("lights_on");
	
	
		
	
	if ( level.start_point == "chaos" || level.start_point == "defend" || level.start_point == "defend_plat" || level.start_point == "defend_blowdoors1" || level.start_point == "defend_blowdoors2" || level.start_point == "defend_fire_blocker"  || level.start_point == "interior_cqb" || level.start_point == "interior_combat" )  
    {
		maps\clockwork_interior::setup_vault_door();
		maps\clockwork_interior::open_vault( true );
	}
	
	// start elevator a floor up.
	foreach( model in elevator_models )
		model linkto( elevator );
	elevator MoveTo( startpoint.origin, .01 );
	
	startrdoor_move = startrdoor.origin - ( 54, 0, 0 );
	startrdoor MoveTo( startrdoor_move, 2, .25, .25 );
	startldoor_move = startldoor.origin + ( 54, 0, 0 );
	startldoor MoveTo( startldoor_move, 2, .25, .25 );
	
	startrdoor ConnectPaths();
	startldoor ConnectPaths();
	
	thread elevator_vo();
	
	flag_wait( "chaos_moving_to_elevator" );
	flag_wait( "cypher_defend_close_door" );
	
	level.player DisableOffhandWeapons();
	
	//cam = GetEnt( "pip_cam_walkout1", "targetname" );
	//maps\clockwork_pip::pip_set_entity( cam, undefined, undefined, undefined, 80 );
	
	// get in ele anims
	thread baker_enter( startpoint );
	thread keegan_enter( startpoint );
	thread cypher_enter( startpoint );
	
	// Wait until the player and allies all walk on the elevator.
	flag_wait_all( "in_elevator_ally_01", "in_elevator_ally_02", "in_elevator_ally_03" );
	
	//this is a trigger_multiple_flag_set_touching, so it needs to be waited on AFTER the allies are in position.
	flag_wait( "inpos_player_elevator" );
	
	elevator_flag = GetEnt( "inpos_player_elevator", "targetname" );
	
	while ( !( level.player IsTouching( elevator_flag ) ) || anyone_touching_blocker( blocker ) )
	{
		wait 0.05;	
	}
	
	blocker Solid();
	
	array_thread( level.allies, ::disable_cqbwalk );
	array_thread( level.allies, ::cqb_walk, "off" );
	array_thread( level.allies, ::fast_walk, false ); // clear out run anim
	wait .05;
	array_thread( level.allies, ::fast_walk, true );
	
	wait .05;
	allenemies = GetAIArray( "axis" );
	foreach ( enemy in allenemies )
	{
		enemy Delete();
	}
	
			  //   entities      process 		    
	array_thread( level.allies, ::disable_arrivals );
	array_thread( level.allies, ::disable_exits );
			  //   entities      process 	      var1   
	array_thread( level.allies, ::set_ignoreall, true );
	array_thread( level.allies, ::set_ignoreme , true );
	foreach ( guy in level.allies )
		guy.alertlevel = "noncombat";
	
	wait .05;
	
	// start elevator movement
	thread elevator_anims( startpoint, endpoint );
	
	SetSavedDvar( "aim_aimAssistRangeScale", "0" );
	SetSavedDvar( "aim_autoAimRangeScale"  , "0" );
	
	//level.allies[ 0 ].animname = "generic";
	//startpoint anim_reach_solo( level.allies[ 0 ] , "ele_baker" );
	//startpoint thread anim_single_solo( level.allies[ 0 ] , "ele_baker" );
	
	//wait 3.25;
	
	flag_wait( "door_close" );
	
	thread maps\clockwork_audio::elevator_door_close();
	
	startrdoor_move = startrdoor.origin + ( 54, 0, 0 );
	startrdoor MoveTo( startrdoor_move, 2, .25, .25 );
	startldoor_move = startldoor.origin - ( 54, 0, 0 );
	startldoor MoveTo( startldoor_move, 2, .25, .25 );
	
	startrdoor ConnectPaths();
	startldoor ConnectPaths();
	
	wait 2;
	
	// using allies would link all allies to the elevator.
	alpha[ 0 ] = level.allies[ 0 ];
	alpha[ 1 ] = level.allies[ 1 ];
	alpha[ 2 ] = level.allies[ 2 ];
	
	array_call( alpha, ::LinkTo, elevator );
	
	startrdoor LinkTo( elevator );
	startldoor LinkTo( elevator );
	
	// move to the top floor
	elevator MoveTo( endpoint.origin, 11, 1, 1 );
	thread maps\clockwork_audio::elevator();
	screenshakeFade( 0.05, .5 );
	
	//baker_enemy			 = spawn_targetname( "chaos_baker_enemy", 1 );
	//baker_enemy.animname = "generic";
	
	foreach ( guy in level.allies )
		guy.alertlevel = "noncombat";
	
	flag_wait( "elevator_enemies_start" );
	
	flag_set( "start_chaos" );
	thread hold_fire_unless_ads( "ally_start_path_exfil" );
	autosave_by_name( "holdfire" );
	
	wait 1;
	
	startrdoor Unlink( elevator );
	startldoor Unlink( elevator );
	
	//screenshakeFade( 0.1, .5 );
	flag_wait( "door_open" );
	screenshakeFade( 0.1, .5 );

	thread maps\clockwork_audio::elevator_door_open();
	
	startrdoor_move = startrdoor.origin - ( 54, 0, 0 );
	startrdoor MoveTo( startrdoor_move, 2, .25, .25 );
	startldoor_move = startldoor.origin + ( 54, 0, 0 );
	startldoor MoveTo( startldoor_move, 2, .25, .25 );
		
	startrdoor ConnectPaths();
	startldoor ConnectPaths();
	
	array_call( alpha, ::Unlink, elevator );
	
	level.player EnableWeapons();
	thread stop_ads_moment();
	flag_set( "elevator_open" );
	
	//endpoint thread anim_reach_solo( level.allies[ 0 ], "exit_baker" );
	//endpoint anim_reach_solo( baker_enemy, "exit_guard" );
		
								  //   guy 			      anime 	   
	//endpoint thread anim_single_solo( baker_enemy	   , "exit_guard" );
	//endpoint anim_single_solo( level.allies[ 0 ], "exit_baker" );
	
	wait .5;
	
	flag_wait( "ele_anim_done");
	
	array_thread( level.allies, ::disable_ai_color );
	keeganpath = GetNode( "keeganpath", "targetname" );
	cypherpath = GetNode( "cypherpath", "targetname" );
	bakerpath  = GetNode( "bakerpath", "targetname" );
	level.allies[ 2 ] thread follow_path( cypherpath );
	wait .75;
	level.allies[ 1 ] thread follow_path( keeganpath );
	
	wait .25;
	
	//nodeend = GetNode( "chaos_end_of_hall_node3", "targetname" );
	//baker_enemy SetGoalNode( nodeend );
	
	level.allies[ 0 ] set_goal_radius( 32 );
	level.allies[ 0 ] set_goal_node( bakerpath );
	level.allies[ 0 ] set_forcegoal();
	level.allies[ 0 ] thread follow_path( bakerpath );
	
	blocker Delete();
	thread chaos_kill_player();
	
	thread ally_idles();
}

anyone_touching_blocker( blocker )
{
	if ( level.player IsTouching( blocker ) )
		return true;
	
	foreach ( ally in level.allies )
	{
		if ( ally IsTouching( blocker ) )
			return true;
	}
	
	return false;
}

elevator_vo()
{
	flag_wait( "chaos_moving_to_elevator" );
	
//	//"Baker: We're going out disguised just like we came in."
//	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_goingoutdisguised" );
	//Oldboy: Copy. Neptune will be on station in three mikes.
	radio_dialog_add_and_go( "clockwork_oby_copyneptunewillbe" );
	
	//Oldboy: We’re hearing chatter on the emergency frequencies.  Not long before they're on to you.
	radio_dialog_add_and_go( "clockwork_oby_werehearingchatteron" );
	
	// Wait until the player and allies all walk on the elevator.
	flag_wait_all( "in_elevator_ally_01", "in_elevator_ally_02", "in_elevator_ally_03" );
	
	//this is a trigger_multiple_flag_set_touching, so it needs to be waited on AFTER the allies are in position.
	flag_wait( "inpos_player_elevator" );
	
	thread maps\clockwork_audio::chaos_music();
	
	flag_wait( "elevator_weapons_down" );
	
	level.player DisableWeapons();
	
	flag_wait( "elevator_limp" );
	
	level.player thread limp();
	/*
	//"Baker: Copy. Time check 23:56"
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_timecheck2356" );
	//"Diaz: Check."
	thread radio_dialog_add_and_go( "clockwork_diz_check" );
	
	wait 2;
	
	//Merrick: We’re going out the same way we came in.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_weregoingoutthe" );
	//Merrick: Keep your weapons low but ready.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_keepyourweaponslow" );
	
	level.player DisableWeapons();
	
	//Merrick: Time to blend in.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_timetoblendin" );
	//Merrick: Leg… help him.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_leghelphim" );
	//Merrick: Limp.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_limp" );
	
	level.player thread limp();
	
	//Merrick: Here we go.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_herewego" );
		
//	//"Baker: Do not fire unless I give the order."
//	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_igiveorder" );	
//	//"Baker: Secure your weapons, keep 'em low but ready."
//	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_lowbutready" );	
*/
}

baker_enter( startpoint )
{
	level.allies[ 0 ].animname = "generic";
	startpoint	anim_reach_solo(  level.allies[ 0 ], "enter_ele_mer" );
	startpoint	anim_single_solo( level.allies[ 0 ], "enter_ele_mer" );
	flag_set( "in_elevator_ally_01" );
	if( !flag( "start_chaos" ) )
		startpoint	anim_loop_solo(   level.allies[ 0 ], "wait_ele_mer", "end_loop"  );
}

keegan_enter( startpoint )
{
	level.allies[ 1 ].animname = "generic";
	startpoint	anim_reach_solo(  level.allies[ 1 ], "enter_ele_kee" );
	startpoint	anim_single_solo( level.allies[ 1 ], "enter_ele_kee" );
	flag_set( "in_elevator_ally_02" );
	if( !flag( "start_chaos" ) )
		startpoint	anim_loop_solo(   level.allies[ 1 ], "wait_ele_kee", "end_loop"  );
}

cypher_enter( startpoint )
{
	level.allies[ 2 ].animname = "generic";
	startpoint	anim_reach_solo(  level.allies[ 2 ], "enter_ele_cyp" );
	startpoint	anim_single_solo( level.allies[ 2 ], "enter_ele_cyp" );
	flag_set( "in_elevator_ally_03" );
	if( !flag( "start_chaos" ) )
		startpoint	anim_loop_solo(   level.allies[ 2 ], "wait_ele_cyp", "end_loop" );
}

elevator_anims( startpoint, endpoint )
{
	startpoint notify( "end_loop" );
	
	startpoint	thread anim_single_solo( level.allies[ 0 ], "exit_ele_mer" );
	startpoint	thread anim_single_solo( level.allies[ 1 ], "exit_ele_kee" );
	startpoint	thread anim_single_solo( level.allies[ 2 ], "exit_ele_cyp" );	
	
	flag_wait( "elevator_enemies_start" );
	
	ele_enemy1			 = spawn_targetname( "chaos_ele_enemy1", 1 );
	level.ele_enemy1	 = ele_enemy1;
	ele_enemy1.animname  = "generic";
	ele_enemy2			 = spawn_targetname( "chaos_ele_enemy2", 1 );
	level.ele_enemy2	 = ele_enemy2;
	ele_enemy2.animname  = "generic";
	ele_enemy3			 = spawn_targetname( "chaos_ele_enemy3", 1 );
	ele_enemy3.animname  = "generic";
	wounded 			 = spawn_targetname( "chaos_wounded2" );
	wounded.animname  	 = "generic";
	
	if( !flag( "exfil_fire_fail" ) )
	{
		endpoint thread anim_single_solo( ele_enemy1, "exit_ele_g1" );
		endpoint thread anim_single_solo( ele_enemy2, "exit_ele_g2" );
		endpoint thread anim_loop_solo( wounded, "rev_ele_vic" );
		endpoint anim_single_solo( ele_enemy3, "exit_ele_g3" );
	}
	else
	{
		reassign_goal_volume( ele_enemy1, "chaos_lab_vol" );
		reassign_goal_volume( ele_enemy2, "chaos_lab_vol" );
		reassign_goal_volume( ele_enemy3 , "chaos_vault_vol" );
	}
	
	if( !flag( "exfil_fire_fail" ) )
	{
		endpoint thread anim_loop_solo( ele_enemy3, "rev_ele_g3" );
	}
	else
	{
		reassign_goal_volume( ele_enemy1, "chaos_lab_vol" );
		reassign_goal_volume( ele_enemy2, "chaos_lab_vol" );
		reassign_goal_volume( ele_enemy3 , "chaos_vault_vol" );
	}
	
	flag_set( "ele_anim_done");
	
	if( !flag( "exfil_fire_fail" ) )
	{
		nodeend = GetNode( "elevator_node_1", "targetname" );
		node4 	= GetNode( "chaos_end_of_hall_node1", "targetname" );
		if( IsDefined( ele_enemy1 ) && IsAlive( ele_enemy1 ) )
			ele_enemy1 SetGoalNode( nodeend );
		if( IsDefined( ele_enemy2 ) && IsAlive( ele_enemy2 ) )
			ele_enemy2 SetGoalNode( nodeend );
		if( IsDefined( ele_enemy3 ) && IsAlive( ele_enemy3 ) )
			ele_enemy3 SetGoalNode( node4 );
	}
	else
	{
		reassign_goal_volume( ele_enemy1, "chaos_lab_vol" );
		reassign_goal_volume( ele_enemy2, "chaos_lab_vol" );
		reassign_goal_volume( ele_enemy3 , "chaos_vault_vol" );
	}
	
	flag_wait( "chaos_ally_run" );

	if( IsDefined( ele_enemy1 ) && IsAlive( ele_enemy1 ) )
		ele_enemy1 delete();
	if( IsDefined( ele_enemy2 ) && IsAlive( ele_enemy2 ) )
		ele_enemy2 delete();
	if( IsDefined( ele_enemy3 ) && IsAlive( ele_enemy3 ) )
		ele_enemy3 delete();
	if( IsDefined( wounded ) && IsAlive( wounded ) )
		wounded delete();
	
}

disable_aim_assist()
{
	//self DisableAimAssist();
	
	flag_wait( "exfil_fire_fail" );
	
	//if( IsDefined( self ) )
	//	self EnableAimAssist();
}

limp()
{
	stumble = 0;
	alt = 0;
	
	level.baseangles = level.player.angles;
	level.player_speed = 80;
	level.ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	level.player playerSetGroundReferenceEnt( level.ground_ref_ent );
	
	wait .05;
	
	while ( !flag( "chaos_keegan_move" ) )
	{
		velocity = level.player getvelocity();
		player_speed = abs( velocity [ 0 ] ) + abs( velocity[ 1 ] );

		if ( player_speed < 10 )
		{
			wait 0.05;
			continue;
		}

		speed_multiplier = player_speed / level.player_speed;

		p = randomfloatrange( .5, 2 );
		if ( randomint( 100 ) < 20 )
			p *= 3;
		r = randomfloatrange( .5, 2 );
		y = randomfloatrange( -2, 0 );

		stumble_angles = ( p, y, r );
		stumble_angles = vector_multiply( stumble_angles, speed_multiplier );

		stumble_time = randomfloatrange( .25, .35 );
		recover_time = randomfloatrange( .55, .65 );

		stumble++;
		if ( speed_multiplier > 1.3 )
			stumble++ ;

		thread stumble( stumble_angles, stumble_time, recover_time );

		level waittill( "recovered" );
	}
	
	level.player playerSetGroundReferenceEnt( undefined );
	thread blend_movespeedscale_custom( 50, 1 );
}

stumble( stumble_angles, stumble_time, recover_time, no_notify )
{
	level endon( "stop_stumble" );

//	if ( flag( "collapse" ) )
//		return;

	stumble_angles = adjust_angles_to_player( stumble_angles );

	level.ground_ref_ent rotateto( stumble_angles, stumble_time, ( stumble_time / 4 * 3 ), ( stumble_time / 4 ) );
	level.ground_ref_ent waittill( "rotatedone" );

//	if ( level.player getstance() == "stand" )
//		level.player PlayRumbleOnEntity( "damage_light" );

	base_angles = ( randomfloat( 4 ) - 4, randomfloat( 5 ), 0 );
	base_angles = adjust_angles_to_player( base_angles );

	level.ground_ref_ent rotateto( base_angles, recover_time, 0, recover_time / 2 );
	level.ground_ref_ent waittill( "rotatedone" );

 	if ( !isdefined( no_notify ) )
		level notify( "recovered" );
}

adjust_angles_to_player( stumble_angles )
{
	pa = stumble_angles[ 0 ];
	ra = stumble_angles[ 2 ];

	rv = anglestoright( level.player.angles );
	fv = anglestoforward( level.player.angles );

	rva = ( rv[ 0 ], 0, rv[ 1 ] * - 1 );
	fva = ( fv[ 0 ], 0, fv[ 1 ] * - 1 );
	angles = vector_multiply( rva, pa );
	angles = angles + vector_multiply( fva, ra );
	return angles + ( 0, stumble_angles[ 1 ], 0 );
}

vector_multiply( vector, number )
{
	return (vector[0] * number, vector[1] * number, vector[2] * number );
}

chaos_kill_player()
{
	//while( !flag( "chaos_kill_player" ) )
	//{
		flag_wait( "chaos_kill_player_warn" );
		
		level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_gettojeep" );
	//}
	
	flag_wait( "chaos_kill_player" );

    flag_set( "exfil_fire_fail" );
    
    wait 3;
    
	SetDvar( "ui_deadquote", &"CLOCKWORK_QUOTE_FOLLOW" );
    maps\_utility::missionFailedWrapper();
	//level.player Kill();
}

ally_idles()
{
	level.allies[ 0 ] thread walkout_idle( "idle_r" );
	level.allies[ 0 ] notify( "idle" );
	level.allies[ 1 ] thread walkout_idle( "idle_l" );
	level.allies[ 1 ] notify( "idle" );
	level.allies[ 2 ] thread walkout_idle( "idle_l" );
	level.allies[ 2 ] notify( "idle" );
}

security_room_transition()
{	
	flag_wait( "start_chaos" );
	
	thread walkout_vo();
	
	thread blend_movespeedscale_custom( 50, 1 );
	//thread player_dynamic_move_speed(); //temp change because issue with follow_path
	
	//thread walkstairsanim();
	
	//FX ON

	thread maps\clockwork_fx::turn_effects_on( "cagelight", "fx/lights/lights_cone_cagelight" );
   	thread maps\clockwork_fx::turn_effects_on( "tubelight_parking", "fx/lights/lights_flourescent" );
	
	if ( !flag("lights_on") )
    {
		thread maps\clockwork_interior_nvg::nvg_area_lights_on_fx();
    }

	exploder( 300 ); //turn on ambient garage smoke
	
	thread autosave_now();

	computer_start	   = getstruct( "chaos_computer_guys", "targetname" );
	computer_low_start = getstruct( "chaos_computer_low_loc", "targetname" );
	drag_start		   = getstruct( "chaos_drag_loc", "targetname" );
	balcony_loc		   = getstruct( "chaos_balcony", "targetname" );
	
	thread vaultguys();
	battlechatter_off( "allies" );
	thread runnerguys();

	flag_wait( "elevator_open" );
	thread tendwounded();
	
	flag_wait( "chaos_ally_run" );
	thread drag_interrogate_scene();
	
	//level.allies[2] thread transitionToStopLeft( "chaos_cypher_stop", "chaos_footstairs_anims" );
	
	flag_wait( "chaos_meetup_follow_spawn" );
	thread meetuptalkscene();
	
	flag_wait( "spawn_more_chaos1" );
	thread computer_guys_runin();
	thread help_near_comps();
	thread bugfinders();
	thread cypher_helps_out();
	
	balcony	 = spawn_targetname( "chaos_balcony" );
	talker	 = spawn_targetname( "chaos_talker" );
	typer	 = spawn_targetname( "chaos_typer" );
	typerlow = spawn_targetname( "chaos_typer_lower" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		balcony.animname	= "generic";
		balcony_loc	thread anim_loop_solo( balcony, "balcony_talk" );	
		
		typer.animname	= "generic";
		talker.animname = "generic";
										   //   guy     anime 		   
		computer_start	thread anim_loop_solo( typer , "typer_start" );
		computer_start	thread anim_loop_solo( talker, "talker_start" );
		
		typerlow.animname		= "generic";
		computer_low_start	thread anim_loop_solo( typerlow, "typer_start" );	
	}
	else
	{
						  //   guys      volume_name 		  
		reassign_goal_volume( balcony , "chaos_security_vol" );
		reassign_goal_volume( talker  , "chaos_security_vol" );
		reassign_goal_volume( typer	  , "chaos_security_vol" );
		reassign_goal_volume( typerlow, "chaos_security_vol" );
	}
		
	flag_wait( "chaos_upstairs_anims" );
		
	flag_set( "scientist_interview" );
	
	// wait for the other ai to be deleted
	wait 0.01;
	
	thread carry_in();
	thread dieing_revival();
	thread stumbler_upstairs();
	thread commander_moment();
	thread direction_group();
	
	flag_wait( "chaos_outside_glass_room" );
		
	thread drag_metal_detector();
	
	flag_set( "chaos_finished" );
	
	flag_wait( "spawn_jeeps" );
	
	if ( IsAlive( talker ) || IsDefined( talker ) )
		talker		Delete();
	if ( IsAlive( typer ) || IsDefined( typer ) )
		typer		Delete();
	if ( IsAlive( typerlow ) || IsDefined( typerlow ) )
		typerlow	Delete();
}

walkout_vo()
{
	level endon( "exfil_fire_fail" );
	
	flag_wait( "elevator_open" );
	/*
	//Federation Soldier 1: Stop, all of you, ID’s and emergency code now!
	level.ele_enemy1 thread char_dialog_add_and_go( "clockwork_saf1_stopallofyou" );
	wait 1;
	//Merrick: Don’t shoot!
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_dontshoot" );
	//Merrick: We’re hurt.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_werehurt" );
	//Merrick: We got 6 or 7 of them cornered in the lab but they’re ripping us up, we need more men down there!
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_wegot6or" );
	//Federation Soldier 1: Okay, we’ll get them, (beat) let’s go, move it!
	level.ele_enemy1 thread char_dialog_add_and_go( "clockwork_saf1_okaywellgetthem" );
	wait 3;
	//Federation Soldier 2: Yes sir!
	level.ele_enemy2 char_dialog_add_and_go( "clockwork_saf2_yessir" );
	*/
	flag_wait( "chaos_ally_run" );
	//Oldboy: They found the snowmobile patrol. They know you’re in uniform.
	//radio_dialog_add_and_go( "clockwork_oby_theyfoundthesnowmobile" );
	//Hesh: They’ve got the drill.
	//level.allies[ 0 ] char_dialog_add_and_go( "clockwork_hsh_theyvegotthedrill" );
	radio_dialog_add_and_go( "clockwork_hsh_theyvegotthedrill" );
	
	flag_wait( "chaos_meetup_follow_spawn" );
	//Oldboy: They’re starting to round up their own guys.
	radio_dialog_add_and_go( "clockwork_oby_theyrestartingtoround" );
	//Merrick: We can see that.
	//level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_wecanseethat" );
	radio_dialog_add_and_go( "clockwork_mrk_wecanseethat" );
	//Oldboy: Suggest you start moving a little quicker, Voodoo.
	thread radio_dialog_add_and_go( "clockwork_oby_suggestyoustartmoving" );
	
	flag_wait( "spawn_more_chaos1" );
	//Federation Soldier 1: Hey you! What you looking at?
	level.heyyouguy thread char_dialog_add_and_go( "clockwork_saf1_heyyouwhatyou" );
	wait 2;
	//Merrick: We need to secure the perimeter.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_weneedtosecure" );
	//Federation Soldier 1: Hurry up then. Keep moving!
	level.heyyouguy thread char_dialog_add_and_go( "clockwork_saf1_hurryupthenkeep" );
		
	flag_wait( "chaos_stairstop_player" );
	//Oldboy: Just lost our eyes.
	radio_dialog_add_and_go( "clockwork_oby_justlostoureyes" );
	//Keegan: They have the plant.
	//level.allies[ 1 ] char_dialog_add_and_go( "clockwork_kgn_theyhavetheplant" );
	radio_dialog_add_and_go( "clockwork_kgn_theyhavetheplant" );
				
	flag_wait( "chaos_outside_glass_room" );
	//Merrick: Pick up the pace.
	//level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_pickupthepace" );
	radio_dialog_add_and_go( "clockwork_mrk_pickupthepace" );
	
	flag_set( "chaos_garage_move" );
}

//transitionToStopLeft( struct_name, flag_name )
//{
//	if( !flag( flag_name ) )
//	{
//		self.animname = "generic";
//		
//		struct = getstruct( struct_name, "targetname" );
//		
//		struct anim_reach_solo( self, "enter_idle_l" );
//		struct anim_single_solo( self, "enter_idle_l" );
//		
//		flag_wait( flag_name );
//		
//		struct anim_single_solo( self, "exit_idle_l" );
//	}
//}
//
//walkstairsanim()
//{
//	if ( !flag( "exfil_fire_fail" ) )
//	{
//		stairs_run = GetEnt( "chaos_ally_walk_volume", "targetname" );
//		// repeat until all allies are in volume
//		while ( 1 )
//		{
//			allies = stairs_run get_ai_touching_volume( "allies" );
//			array_thread( allies, ::fast_walk, false );
//			
//			foreach ( ally in allies )
//			{
//				if ( !IsDefined( ally.isrunning ) )
//				{
//					ally.isrunning = 1;
//					ally thread backtowalkanim();
//				}
//			}
//			
//			wait 0.5;
//		}
//	}
//}
//
//backtowalkanim()
//{
//	if ( !flag( "exfil_fire_fail" ) )
//	{
//		stairs_run = GetEnt( "chaos_ally_walk_volume", "targetname" );
//		// repeat until all allies are out of volume
//		while ( 1 )
//		{
//			matchfound			  = 0;
//			allies				  = stairs_run get_ai_touching_volume( "allies" );
//			self.moveplaybackrate = 0.5; // slow down run up stairs
//			
//			foreach ( ally in allies )
//			{
//				if ( self == ally )
//				{
//					matchfound = 1;
//				}
//			}
//			
//			if ( !matchfound )
//			{
//				if ( !flag( "exfil_fire_fail" ) )
//					self fast_walk( true );
//				return;
//			}
//			wait 0.05;
//		}
//	}
//}

drag_metal_detector()
{
	drag_start		   = getstruct( "chaos_drag_loc", "targetname" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{				
		dragger			 = spawn_targetname( "chaos_dragger" );
		dragged			 = spawn_targetname( "chaos_dragged" );
		dragger.animname = "generic";
		dragged.animname = "generic";
		
		dragged gun_remove();
		
										 //   guy 	   anime 		 
		drag_start	thread anim_loop_solo( dragger, "dragger_loop", "kill_me" );
		drag_start	thread anim_loop_solo( dragged, "dragged_loop", "kill_me" );
		
		wait 2;
		
		losthope	= spawn_targetname( "chaos_lost_hope" );
	
		losthope.animname		= "generic";
		losthope	thread anim_single_solo( losthope, "lost_hope" );
		
		wait 2;
		
		drag_start notify( "kill_me" );
		
		wait .05;
		
		drag_start	thread anim_single_solo( dragger, "dragger_sin" );
		drag_start	thread anim_single_solo( dragged, "dragged_sin" );
		
	}
	
}

losthope_vo( talker, losthope )
{
	level endon( "exfil_fire_fail" );
	talker endon( "death" );
	losthope endon( "death" );
	
	flag_wait( "chaos_exit_vo" );
		
	//"Siberian Soldier 1: They rerouted to an outside transponder."
	talker char_dialog_add_and_go( "clockwork_ru1_rerouted" );
	//"Siberian Soldier 1: How many were there?"
	losthope char_dialog_add_and_go( "clockwork_ru1_howmany" );
	//"Scientist 1: It was so dark. No."
	losthope char_dialog_add_and_go( "clockwork_sc1_sodark" );
}

additionalexit_vo( guy1, guy2 )
{
	level endon( "exfil_fire_fail" );
	guy1 endon( "death" );
	guy2 endon( "death" );
	
	flag_wait( "chaos_exit_vo" );
	
	//"Russian Soldier 1: Explain to me how they got through security."
	guy1 char_dialog_add_and_go( "clockwork_rs1_gotthroughsecurity" );
	//"Russian Soldier 2: All I know is that I was in the office, the lights went off and the muzzle flashes started."
	guy2 char_dialog_add_and_go( "clockwork_rs2_intheoffice" );
	//"Russian Soldier 1: Did you see anything?"
	guy1 char_dialog_add_and_go( "clockwork_rs1_seeanything" );
	//"Russian Soldier 2: No."
	guy2 char_dialog_add_and_go( "clockwork_rs2_no" );
	
	//"Russian Soldier 3: How did they cut the power?"
	guy1 char_dialog_add_and_go( "clockwork_rs3_cutthepower" );
	//"Russian Soldier 4: There was another team that took out the power station."
	guy2 char_dialog_add_and_go( "clockwork_rs4_tookoutpower" );
	//"Russian Soldier 3: It's like they knew exactly when the backup power would come on."
	guy1 char_dialog_add_and_go( "clockwork_rs3_kneweactly" );
	//"Russian Soldier 4: They timed it out perfectly."
	guy2 char_dialog_add_and_go( "clockwork_rs4_timeditperfectly" );
}

runnerguys()
{	
	pointer = spawn_targetname( "chaos_pointer" );
	runner	= spawn_targetname( "chaos_runner" );
	runner2 = spawn_targetname( "chaos_runner2" );
	runner4 = spawn_targetname( "chaos_runner4" );
	runner5 = spawn_targetname( "chaos_runner5" );
	runner6 = spawn_targetname( "chaos_runner6" );
	
	node1 = GetNode( "send_guy_node_1", "targetname" );
	node2 = GetNode( "send_guy_node_2", "targetname" );
	node3 = GetNode( "send_guy_node_3", "targetname" );
	node4 = GetNode( "chaos_end_of_hall_node1", "targetname" );
	node5 = GetNode( "chaos_end_of_hall_node2", "targetname" );
		
	if ( !flag( "exfil_fire_fail" ) )
	{
		pointer.animname = "generic";
		runner.animname	 = "generic";
		runner2.animname = "generic";
		
		wait 0.75;
		
		pointer thread anim_single_solo( pointer, "pointer_start" );
		
		wait 0.35;
		runner5 set_goal_node( node5 );
		runner6 set_goal_node( node5 );
		runner4 set_goal_node( node4 );
		runner2 thread anim_single_solo( runner2, "runner_start" );
		thread runner_vo( pointer, runner );
		
		wait 0.45;
		runner thread anim_single_solo( runner, "runner_start" );
		
		wait 0.01;
		pointer set_goal_node( node1 );
		runner set_goal_node( node2 );
		runner2 set_goal_node( node4 );
	}
	else
	{
						  //   guys     volume_name 	  
		reassign_goal_volume( pointer, "chaos_lab_vol" );
		reassign_goal_volume( runner , "chaos_vault_vol" );
		reassign_goal_volume( runner2, "chaos_lab_vol" );
		reassign_goal_volume( runner4, "chaos_lab_vol" );
		reassign_goal_volume( runner5, "chaos_lab_vol" );
		reassign_goal_volume( runner6, "chaos_lab_vol" );
	}
	
	
	flag_wait( "spawn_more_chaos1" );
	
	if ( IsAlive( runner4 ) )
		runner4 Delete();
	if ( IsAlive( runner5 ) )
		runner5 Delete();
	if ( IsAlive( runner6 ) )
		runner6 Delete();
	
	flag_wait( "spawn_jeeps" );
	
	if ( IsAlive( runner2 ) || IsDefined( runner2 ) )
		runner2	Delete();
	if ( IsAlive( pointer ) || IsDefined( pointer ) )
		pointer	Delete();
}

runner_vo( pointer, runner )
{
	level endon( "exfil_fire_fail" );
	pointer endon( "death" );
	runner endon( "death" );
	
	wait 2;
	//"Siberian Commander: Send more troops to the labs."
	pointer char_dialog_add_and_go( "clockwork_ruc_moretroops" );
	//"Russian Soldier 1: You! With me."
	pointer char_dialog_add_and_go( "clockwork_rs1_withme" );
	//"Siberian Soldier 1: Yes sir."
	runner char_dialog_add_and_go( "clockwork_ru1_yessir" );
	//"Russian Soldier 1: You know your orders. Move to your sectors."
	pointer char_dialog_add_and_go( "clockwork_rs1_movetosectors" );
}

vaultguys()
{	
	vault_door_talk = getstruct( "vault_door_talk_guy", "targetname" );
	vault_door_idle = getstruct( "vault_door_idle_guy", "targetname" );
	bug_start		= getstruct( "vault_door_drill_guy", "targetname" );
	
	directionb1vault = spawn_targetname( "chaos_direction_b1_vault" );
	directionb2vault = spawn_targetname( "chaos_direction_b2_vault" );
	directionb3vault = spawn_targetname( "chaos_direction_b3_vault" );
	vaultdoor		 = spawn_targetname( "chaos_vault_door" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		directionb1vault.animname = "generic";
		directionb2vault.animname = "generic";
		directionb3vault.animname = "generic";
		vaultdoor.animname		  = "generic";
		
		directionb1vault gun_remove();
		directionb2vault gun_remove();
		directionb3vault gun_remove();
		vaultdoor gun_remove();		
		
		thread vaultguys_vo( directionb2vault, directionb1vault );
		
										   //   guy 		     	anime 		   
		vault_door_talk thread anim_loop_solo( directionb1vault, 	"direction_give" );
		vault_door_talk thread anim_loop_solo( directionb2vault, 	"direction_take" );
		vault_door_idle thread anim_loop_solo( directionb3vault, 	"direction_loop" );
		bug_start		thread anim_loop_solo( vaultdoor, 			"vault_door_loop" );
		
		drill 	= spawn_anim_model( "chaos_drill", 		vaultdoor.origin );
		joint 	= spawn_anim_model( "chaos_drill_j", 	vaultdoor.origin);
		drill linkto( joint , "J_prop_1" );
		vaultdoor thread anim_loop_solo( joint, "drill" );
				
		flag_wait_any( "chaos_upstairs_anims", "exfil_fire_fail" );
		
		if ( IsAlive( directionb1vault ) )
		{
			directionb1vault anim_stopanimscripted();
			directionb1vault gun_recall();
			reassign_goal_volume( directionb1vault, "chaos_vault_vol" );
		}
		if ( IsAlive( directionb2vault ) )
		{
			directionb2vault anim_stopanimscripted();
			directionb2vault gun_recall();
			reassign_goal_volume( directionb2vault, "chaos_vault_vol" );
		}
		if ( IsAlive( directionb3vault ) )
		{
			directionb3vault anim_stopanimscripted();
			directionb3vault gun_recall();
			reassign_goal_volume( directionb3vault, "chaos_vault_vol" );
		}
		if ( IsAlive( vaultdoor ) )
		{
			vaultdoor anim_stopanimscripted();
			vaultdoor gun_recall();
			reassign_goal_volume( vaultdoor		, "chaos_lab_vol" );
		}
	}
	else
	{
						  //   guys 		     volume_name 	   
		reassign_goal_volume( directionb1vault, "chaos_vault_vol" );
		reassign_goal_volume( directionb2vault, "chaos_vault_vol" );
		reassign_goal_volume( directionb3vault, "chaos_vault_vol" );
		reassign_goal_volume( vaultdoor		  , "chaos_lab_vol" );
	}
		
	flag_wait( "chaos_upstairs_anims" );
	
	if ( IsAlive( directionb1vault ) )
		directionb1vault Delete();
	if ( IsAlive( directionb2vault ) )
		directionb2vault Delete();
	if ( IsAlive( directionb3vault ) )
		directionb3vault Delete();
	if ( IsAlive( vaultdoor ) )
		vaultdoor Delete();
	
}

vaultguys_vo( directionb2vault, directionb1vault )
{
	level endon( "exfil_fire_fail" );
	directionb2vault endon( "death" );
	directionb1vault endon( "death" );
	
	flag_wait( "chaos_ally_run" );
	
	//"Russian Soldier 3: What did they use?"
	directionb2vault char_dialog_add_and_go( "clockwork_rs3_whatdidtheyuse" );
	//"Russian Soldier 4: Thermite and C4."
	directionb1vault char_dialog_add_and_go( "clockwork_rs4_thermite" );
	flag_set( "chaos_meetupvo_start" );
	//"Russian Soldier 3: Do we know where the C4 came from?"
	directionb2vault char_dialog_add_and_go( "clockwork_rs3_c4camefrom" );
	//"Russian Soldier 4: The residue shows it was manufactured locally."
	directionb1vault char_dialog_add_and_go( "clockwork_rs4_manufacturedlocally" );
}

tendwounded()
{	
	wounded_scene	= getstruct( "chaos_wounded_scene1", "targetname" );
	
	///reviver 	= spawn_targetname( "chaos_wounded1" );
	//wounded 	= spawn_targetname( "chaos_wounded2" );
	bug_start	= getstruct( "chaos_bug_find_scene", "targetname" );
	
	extinguisher1 = spawn_targetname( "chaos_extinguisher" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		//reviver.animname 			= "generic";
		//wounded.animname 			= "generic";
		extinguisher1.animname		= "generic";
		
		//wounded gun_remove();
		
		//thread tendwounded_vo( reviver );
		
		if ( IsAlive( extinguisher1 ) )
			bug_start thread anim_loop_solo( extinguisher1, "extinguish" );
		
		//exting1 = spawn_anim_model( "chaos_ext", bug_start.origin );
		//joint 	= spawn_anim_model( "chaos_ext_j", bug_start.origin);
		//exting1 linkto( joint , "J_prop_1" );
		//bug_start thread anim_loop_solo( exting1, "ext" );
		
		//wounded_scene thread anim_single_solo( reviver, "DC_Burning_stop_bleeding_medic" );
		//wounded_scene anim_single_solo( wounded, "DC_Burning_stop_bleeding_wounded" );
		   
		//if ( IsAlive( reviver ) )
		//	wounded_scene thread anim_loop_solo( reviver, "DC_Burning_stop_bleeding_medic_idle"	, "kill_wounded" );
		//if ( IsAlive( wounded ) )
		//	wounded_scene thread anim_loop_solo( wounded, "DC_Burning_stop_bleeding_wounded_idle", "kill_wounded" );
		
		flag_wait_any( "chaos_upstairs_anims", "exfil_fire_fail" );
	
		wounded_scene notify( "kill_wounded" );
		//if ( IsAlive( reviver ) )
		//	reviver StopAnimScripted();
		//if ( IsAlive( wounded ) )
		//	wounded Delete();
		if ( IsAlive( extinguisher1 ) )
			extinguisher1 StopAnimScripted();
	}
	else
	{
		//wounded Kill();
		//reassign_goal_volume( reviver, "chaos_lab_vol" );
		reassign_goal_volume( extinguisher1, "chaos_lab_vol" );
	}
	
	flag_wait( "chaos_upstairs_anims" );
	
	//if ( IsAlive( reviver ) )
	//	reviver Delete();
	//if ( IsAlive( wounded ) )
	//	wounded Delete();
	if ( IsAlive( extinguisher1 ) )
		extinguisher1 Delete();
}

//tendwounded_vo( guy )
//{
//	level endon( "exfil_fire_fail" );
//	guy endon( "death" );
//	
//	wait 1;
//	
//	//"Russian Soldier 2: Can you hear me?"
//	guy char_dialog_add_and_go( "clockwork_rs2_hearme" );
//	//"Russian Soldier 2: He's bleeding out. Need to apply pressure and everything will be ok."
//	guy char_dialog_add_and_go( "clockwork_rs2_bleedingout" );
//	//"Russian Soldier 2: Someone help!"
//	guy char_dialog_add_and_go( "clockwork_rs2_someonehelp" );
//}

meetuptalkscene()
{	
	meetup_talk = getstruct( "chaos_meetup_location", "targetname" );
	
	meetup_follower	 = spawn_targetname( "chaos_meetup_follower" );
	//meetup_follower2 = spawn_targetname( "chaos_meetup_follower2" );
	//meetup_follower2 disable_arrivals();
	//meetup_follower3 = spawn_targetname( "chaos_meetup_followed_runner" );
	meetup_followed	 = spawn_targetname( "chaos_meetup_followed" );
	node1			 = GetNode( "chaos_end_of_hall_node1", "targetname" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		meetup_follower.animname  = "generic";
		meetup_followed.animname  = "generic";
		//meetup_follower2.animname = "generic";
			
		thread meetup_vo( meetup_follower, meetup_followed );
		
		//meetup_follower2 fast_walk( true );
		
		meetup_talk thread anim_reach_solo( meetup_follower, "meetup_follower" );
		meetup_talk anim_reach_solo( meetup_followed, "meetup_followed" );
		
										 //   guy 			   anime 			 
		meetup_talk thread anim_single_solo( meetup_follower, "meetup_follower" );
		meetup_talk thread anim_single_solo( meetup_followed, "meetup_followed" );
		
		meetup_follower set_goal_node( node1 );
		meetup_followed set_goal_node( node1 );
		
		flag_wait( "meetup_vo_done" );
		
		//meetup_follower2 fast_walk( false );
		//meetup_follower2 set_goal_node( node1 );
	}
	else
	{
						  //   guys 		     volume_name 	   
		reassign_goal_volume( meetup_follower , "chaos_vault_vol" );
		reassign_goal_volume( meetup_followed , "chaos_vault_vol" );
		//reassign_goal_volume( meetup_follower2, "chaos_vault_vol" );
	}
	
	flag_wait( "chaos_upstairs_anims" );
	
	if ( IsAlive( meetup_follower ) )
		meetup_follower Delete();
	if ( IsAlive( meetup_followed ) )
		meetup_followed Delete();
	//if ( IsAlive( meetup_follower2 ) )
		//meetup_follower2 Delete();
	//if ( IsAlive( meetup_follower3 ) )
		//meetup_follower3 Delete();
}

meetup_vo( pointer, runner )
{
	level endon( "exfil_fire_fail" );
	pointer endon( "death" );
	runner endon( "death" );
	
	flag_wait( "chaos_meetupvo_start" );
	
	wait 3;
	
	//"Russian Soldier 1: Report."
	pointer char_dialog_add_and_go( "clockwork_rs1_report" );
	//"Russian Soldier 2: They're still holed up in the labs."
	runner char_dialog_add_and_go( "clockwork_rs2_holdupinlabs" );
	//"Russian Soldier 1: Let's hurry."
	pointer char_dialog_add_and_go( "clockwork_rs1_letshurry" );
	
	flag_set( "meetup_vo_done" );
}

drag_interrogate_scene()
{
	meetup_talk	  = getstruct( "chaos_drag_scene" , "targetname" );
	meetup_talker = getstruct( "chaos_drag_talker", "targetname" );
	meetup_talkee = getstruct( "chaos_drag_talkee", "targetname" );
	
	meetup_follower	 = spawn_targetname( "chaos_dragger_interrogate" );
	meetup_follower2 = spawn_targetname( "chaos_drag_inter" );
	meetup_follower3 = spawn_targetname( "chaos_drag_talker" );
	level.heyyouguy  = meetup_follower3;
	meetup_followed	 = spawn_targetname( "chaos_drag_talkee" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		meetup_follower.animname  = "generic";
		meetup_follower2.animname = "generic";
		meetup_follower3.animname = "generic";
		meetup_followed.animname  = "generic";
		
		//meetup_follower  gun_remove();
		//meetup_follower2 gun_remove();
		
										 //   guy 			   anime 			 
		meetup_talker thread anim_loop_solo( meetup_follower3, "drag_talker_loop" );
		meetup_talkee thread anim_loop_solo( meetup_followed, "drag_talkee_loop" );
		meetup_talk thread anim_single_solo( meetup_follower2, "drag_interrogate" );
		meetup_talk anim_single_solo( meetup_follower, "dragger_interrogate" );
		
		if ( !flag( "exfil_fire_fail" ) )
		{
										   //   guy 		      anime 					 
			meetup_talk thread anim_loop_solo( meetup_follower2, "drag_interrogate_loop" );
			meetup_talk thread anim_loop_solo( meetup_follower , "dragger_interrogate_loop" );
		}
		else
		{
			if ( IsAlive( meetup_follower ) )							
				reassign_goal_volume( meetup_follower, "chaos_vault_vol" );
			if ( IsAlive( meetup_followed ) )
				reassign_goal_volume( meetup_followed, "chaos_vault_vol" );
			if ( IsAlive( meetup_follower2 ) )
			{
				reassign_goal_volume( meetup_follower2, "chaos_vault_vol" );
				meetup_follower2 gun_recall();
			}
			if ( IsAlive( meetup_follower3 ) )
				reassign_goal_volume( meetup_follower3, "chaos_vault_vol" );
		}
	}
	else
	{
						  //   guys 		     volume_name 	   
		reassign_goal_volume( meetup_follower , "chaos_vault_vol" );
		reassign_goal_volume( meetup_followed , "chaos_vault_vol" );
		reassign_goal_volume( meetup_follower2, "chaos_vault_vol" );
		reassign_goal_volume( meetup_follower3, "chaos_vault_vol" );
	}
	
	flag_wait( "chaos_upstairs_anims" );
	
	if ( IsAlive( meetup_follower ) )
		meetup_follower Delete();
	if ( IsAlive( meetup_followed ) )
		meetup_followed Delete();
	if ( IsAlive( meetup_follower2 ) )
		meetup_follower2 Delete();
	if ( IsAlive( meetup_follower3 ) )
		meetup_follower3 Delete();
}

computer_guys_runin()
{	
	runin_loc = getstruct( "chaos_computer_runin_loc", "targetname" );
	runinguy  = spawn_targetname( "chaos_computer_runin" );
	
	runinguy endon( "death" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		runinguy.animname = "generic";
		runin_loc anim_reach_solo( runinguy, "computer_stander_runin" );
		thread computer_guys_runin_vo( runinguy );
		runin_loc thread anim_loop_solo( runinguy, "computer_stander_runin", "computer_stop" );
	}
	else
	{
		reassign_goal_volume( runinguy, "chaos_security_vol" );
	}
	
	flag_wait( "spawn_jeeps" );
		
	if ( IsAlive( runinguy ) )
	{
		runin_loc notify( "computer_stop" );
		runinguy StopAnimScripted();
		runinguy Delete();
	}
}

computer_guys_runin_vo( guy )
{
	level endon( "exfil_fire_fail" );
	guy endon( "death" );
	
	wait 3;
	if ( IsAlive( guy ) )
	{
		//"Scientist 1: They shot the monitor on this one."
		guy char_dialog_add_and_go( "clockwork_sc1_shotmonitor" );
	}
	if ( IsAlive( guy ) )
	{
		//"Scientist 2: What was the password again?"
		guy char_dialog_add_and_go( "clockwork_sc2_password" );
	}
	if ( IsAlive( guy ) )
	{
		//"Scientist 1: Vodka."
		guy char_dialog_add_and_go( "clockwork_sc1_vodka" );
	}
	if ( IsAlive( guy ) )
	{
		//"Scientist 2: Running check on the files they're taking. Damn, they've blocked me!"
		guy char_dialog_add_and_go( "clockwork_sc2_blockingme" );
	}
	if ( IsAlive( guy ) )
	{
		//"Scientist 1: Do you see anything on the cameras?"
		guy char_dialog_add_and_go( "clockwork_sc1_seeanything" );
	}
	if ( IsAlive( guy ) )
	{
		//"Scientist 2: No. There's too much smoke."
		guy char_dialog_add_and_go( "clockwork_sc2_toomuchsmoke" );
	}
}

help_near_comps()
{
	bug_start		= getstruct( "chaos_bug_find_scene", "targetname" );
	help_loc = getstruct( "chaos_help_near_comp_struct", "targetname" );
	stumbler = spawn_targetname( "chaos_hurt_near_comp" );
	helper	 = spawn_targetname( "chaos_help_near_comp" );
	walker	 = spawn_targetname( "chaos_help_near_comp_walker" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		stumbler.animname = "generic";
		helper.animname	  = "generic";
		
		stumbler gun_remove();
		
		help_loc thread anim_loop_solo( stumbler, "hurt_start_loop", "end_loop" );
		help_loc anim_reach_solo( helper, "help_anim" );
		if ( !flag( "exfil_fire_fail" ) && IsAlive( helper ) && IsAlive( stumbler ) )
		{
			thread help_vo( stumbler, helper );
			help_loc notify( "end_loop" );
			help_loc thread anim_single_solo( stumbler, "hurt_anim" );
			help_loc anim_single_solo( helper, "help_anim" );
		}
		
		if ( !flag( "exfil_fire_fail" ) && IsAlive( helper ) && IsAlive( stumbler ) )
		{
			help_loc thread anim_loop_solo( stumbler, "hurt_end_loop" );
			help_loc thread anim_loop_solo( helper, "help_end_loop" );
		}
	}
	else
	{
		stumbler Kill();
		reassign_goal_volume( helper, "chaos_security_vol" );
	}
	
	flag_wait( "spawn_jeeps" );
	
	if ( IsAlive( helper ) )
		helper Delete();
	if ( IsAlive( stumbler ) )
		stumbler Delete();
}

help_vo( wounded, helper )
{
	level endon( "exfil_fire_fail" );
	wounded endon( "death" );
	helper endon( "death" );
	
	//"Scientist 1: Help!"
	wounded char_dialog_add_and_go( "clockwork_sc1_help" );
	//"Siberian Soldier 1: How many were there?"
	//helper char_dialog_add_and_go( "clockwork_rs2_i'mhere" );
	//"Scientist 1: In the knee and a bullet grazed my ear."
	wounded char_dialog_add_and_go( "clockwork_sc1_intheknee" );
	if ( IsAlive( helper ) )
	{
		//"Russian Soldier 2: Did you see the attackers?"
		helper char_dialog_add_and_go( "clockwork_rs2_seeattackers" );
	}
	//"Scientist 1: All I saw were muzzle flashes."
	wounded char_dialog_add_and_go( "clockwork_sc1_sawflashes" );
}

bugfinders()
{
	bug_start		= getstruct( "chaos_bug_find_scene", "targetname" );
	
	bugfinder	= spawn_targetname( "chaos_bug_finder" );
	bugdirector = spawn_targetname( "chaos_bug_director" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		bugfinder.animname	 = "generic";
		bugdirector.animname = "generic";
		
		thread bug_finders_vo( bugfinder, bugdirector );
		
		bug_start	thread anim_single_solo( bugfinder, "bug_finder" );
		bug_start	anim_single_solo( bugdirector, "bug_finder2" );
		
		if ( IsAlive( bugfinder ) )
		   bug_start	thread anim_loop_solo( bugfinder, "bug_finder_loop" );
		if ( IsAlive( bugdirector ) )
			bug_start	thread anim_loop_solo( bugdirector, "bug_finder_loop2" );		
	}
	else
	{
						  //   guys 	    volume_name 		 
		reassign_goal_volume( bugfinder	 , "chaos_security_vol" );
		reassign_goal_volume( bugdirector, "chaos_security_vol" );
	}
	
	flag_wait( "spawn_jeeps" );
	
	if ( IsAlive( bugfinder ) || IsDefined( bugfinder ) )
		bugfinder	Delete();
	if ( IsAlive( bugdirector ) || IsDefined( bugdirector ) )
		bugdirector Delete();
}

bug_finders_vo( helper, soldier )
{
	level endon( "exfil_fire_fail" );
	soldier endon( "death" );
	helper endon( "death" );
	
	flag_wait( "scientist_interview" );
	
	//"Siberian Soldier 1: It's very sophisticated."
	helper char_dialog_add_and_go( "clockwork_ru1_sophisticated" );
	//"Siberian Soldier 2: Who could have done all this?"
	soldier char_dialog_add_and_go( "clockwork_ss1_doneallthis" );
	//"Siberian Soldier 1: They rerouted to an outside transponder."
	helper char_dialog_add_and_go( "clockwork_ru1_rerouted" );
	
	//if ( IsDefined( level.pip ) && level.pip.enable )
		//maps\clockwork_pip::pip_disable();	
	
	//"Siberian Soldier 2: I want it taken apart piece by piece"
	soldier char_dialog_add_and_go( "clockwork_ru2_takenapart" );
}

cypher_helps_out()
{	
	bug_start	= getstruct( "chaos_bug_find_scene", "targetname" );
	
	needs_help	= spawn_targetname( "chaos_cypher_helps" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		needs_help.animname	= "generic";
		
		bug_start	thread anim_loop_solo( needs_help, "helpee_intro_loop", "helpee_intro_end" );
		
		flag_wait( "chaos_footstairs_anims" );
		
		thread cypher_helps_out_vo( needs_help, bug_start );
		
		bug_start	anim_reach_solo( level.allies[ 2 ], "helper_out" );
		
		if ( IsAlive( needs_help ) )
		{
			needs_help.moveplaybackrate = 1.2;
			level.allies[ 2 ].moveplaybackrate = 1.2;
			bug_start thread anim_single_solo( needs_help, "helpee_out" );
			bug_start notify( "helpee_intro_end" );
			bug_start anim_single_solo( level.allies[ 2 ], "helper_out" );
		}
		
		bug_start notify( "guy_helped" );
		needs_help.moveplaybackrate = 1;
		level.allies[ 2 ].moveplaybackrate = 1;
		
		if ( IsAlive( needs_help ) )
			bug_start	thread anim_loop_solo( needs_help, "helpee_exit_loop" );	
	}
	
	flag_wait( "spawn_jeeps" );
	
	if ( IsAlive( needs_help ) || IsDefined( needs_help ) )
		needs_help	Delete();
}

cypher_helps_out_vo( needs_help, bug_start )
{
	wait 2;
	//Hesh: I’m helping him.
	level.allies[ 2 ] char_dialog_add_and_go( "clockwork_hsh_imhelpinghim" );
	
	bug_start waittill( "helpee_intro_end" );
	
	//Hesh: Come here friend.
	level.allies[ 2 ] char_dialog_add_and_go( "clockwork_hsh_comeherefriend" );
	
	wait 10; 
	
	//Hesh: A medic will be right with you.
	level.allies[ 2 ] char_dialog_add_and_go( "clockwork_hsh_amedicwillbe" );
	//Federation Soldier 2: Thank you.
	needs_help char_dialog_add_and_go( "clockwork_saf2_thankyou" );
}

commander_moment()
{
	thread direction_group_dog();
	
	commander_start = getstruct( "chaos_commander_and_lt", "targetname" );
	node1			= GetNode( "choas_walkers_goal", "targetname" );
	
	dog_scene		= getstruct( "chaos_dog_scene", "targetname" );
	
	walkers	   = array_spawn_targetname( "chaos_walkers" );
	walkerJeep = spawn_vehicle_from_targetname( "chaos_walkers_jeep" );
	commander  = spawn_targetname( "chaos_commander" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		lt					 = spawn_targetname( "chaos_lt" );
		handlerdog			 = spawn_targetname( "chaos_dog_handler" );
		barkingdog			 = spawn_targetname( "barkingdog" );
		barkingdog.ignoreall = 1;
		leash 	= spawn_anim_model( "chaos_leash", 		dog_scene.origin );
		leash hide();
	
		if( IsDefined( lt ) )
		{
			lt.animname			= "generic";
			lt gun_remove();
			lt thread anim_loop_solo( lt, "wave_guard" );
		}
		
		if( IsDefined( handlerdog ) && IsDefined( barkingdog ) )
		{
			handlerdog.animname = "generic";
			barkingdog.animname = "generic";
			
			leash show();
			//joint 	= spawn_anim_model( "chaos_leash_j", 	dog_scene.origin );
			//leash linkto( joint , "J_prop_1" );
			dog_scene thread anim_loop_solo( handlerdog, "cha_handler_idle", "firstloop" );
			dog_scene thread anim_loop_solo( leash, 	 "cha_leash_idle", 	 "firstloop" );
			dog_scene thread anim_loop_solo( barkingdog, "cha_dog_idle", 	 "firstloop" );
		}
		
		if( IsDefined( commander ) )
		{
			commander.animname	= "generic";
			commander gun_remove();
			commander_start thread anim_loop_solo( commander, "commander_start" );
		}
		
		if( IsDefined( walkers ) )
		{
			array_thread( walkers, ::fast_walk, true );
					  //   entities    process 			  
			array_thread( walkers	, ::disable_arrivals );
			array_thread( walkers	, ::disable_exits );
		}
		
		flag_wait( "chaos_enemies_meetup" );
		
		if( IsDefined( walkers[0] ) ) 
			walkers[0] thread anim_single_solo( walkers[0], "pointer_start" );
		
		flag_wait( "chaos_start_commander_vo" );
		
		if ( IsDefined( barkingdog ) && IsAlive( barkingdog ) && IsDefined( handlerdog ) && IsAlive( handlerdog ) )
		{
			dog_scene notify( "firstloop" );
			
			dog_scene thread anim_single_solo( leash, 		"cha_leash_alert" );
			dog_scene thread anim_single_solo( handlerdog, 	"cha_handler_alert" );
			dog_scene anim_single_solo( barkingdog, 		"cha_dog_alert" );

			dog_scene thread anim_loop_solo( leash, 	 "cha_leash_react", 	"secloop" );
			dog_scene thread anim_loop_solo( handlerdog, "cha_handler_react", 	"secloop" );
			dog_scene thread anim_loop_solo( barkingdog, "cha_dog_react", 		"secloop" );
		}
		
		flag_wait( "chaos_outside_glass_room" );
		
		if ( IsDefined( barkingdog ) && IsAlive( barkingdog ) && IsDefined( handlerdog ) && IsAlive( handlerdog ) )
		{
			dog_scene notify( "secloop" );
			
			dog_scene thread anim_single_solo( leash, 		"cha_leash_turn" );
			dog_scene thread anim_single_solo( handlerdog, 	"cha_handler_turn" );
			dog_scene anim_single_solo( barkingdog, 		"cha_dog_turn" );

			dog_scene thread anim_loop_solo( leash, 	 "cha_leash_idle2" );
			dog_scene thread anim_loop_solo( handlerdog, "cha_handler_idle2" );
			dog_scene thread anim_loop_solo( barkingdog, "cha_dog_idle2" );
		}
	}
	else
	{
		reassign_goal_volume( walkers, "chaos_security_vol" );
	}
	
	thread commander_vo( commander, walkers );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		walkers = array_removeDead_or_dying( walkers );
		walkerJeep vehicle_load_ai( walkers );
	}
	
	flag_wait( "spawn_jeeps" );
	
	if ( flag( "exfil_fire_fail" ) )
		walkerJeep vehicle_unload();
	
	//wait 1;
	
	//walkerJeep ent_flag_wait( "loaded" );
	//level.playerJeep ent_flag_wait( "loaded" );
	//wait 1.5;
	
	//walkerJeep StartPath();
}

direction_group_dog()
{
	directionb1 = spawn_targetname( "chaos_direction_b1_dog" );
	directionb2 = spawn_targetname( "chaos_direction_b2_dog" );
	talka_start = getstruct( "dog_talk_guy", "targetname" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		directionb1.animname = "generic";
		directionb2.animname = "generic";
		directionb1 gun_remove();
		directionb2 gun_remove();
									   //   guy 	    anime 			 
		talka_start thread anim_loop_solo( directionb1, "direction_give" );
		talka_start thread anim_loop_solo( directionb2, "direction_take" );
	}
	else
	{
						  //   guys 	    volume_name 	 
		reassign_goal_volume( directionb1, "chaos_exit_vol" );
		reassign_goal_volume( directionb2, "chaos_exit_vol" );
	}

	flag_wait( "exfil_fire_fail" );
	
	if ( IsAlive( directionb1 ) )
	{
		reassign_goal_volume( directionb1, "chaos_exit_vol" );
		directionb1 gun_recall();
	}
	if ( IsAlive( directionb2 ) )
	{
		reassign_goal_volume( directionb2, "chaos_exit_vol" );
		directionb2 gun_recall();
	}
}

direction_group()
{
	directionb1 = spawn_targetname( "chaos_direction_b1" );
	directionb2 = spawn_targetname( "chaos_direction_b2" );
	direction1	= spawn_targetname( "chaos_direction1" );
	direction2	= spawn_targetname( "chaos_direction2" );
	talka_start = getstruct( "chaos_talking_a", "targetname" );
	talkb_start = getstruct( "chaos_talking_b", "targetname" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		directionb1.animname = "generic";
		directionb2.animname = "generic";
		directionb1 gun_remove();
		directionb2 gun_remove();
									   //   guy 	     anime 			  
		talkb_start thread anim_loop_solo( directionb1, "direction_give" );
		talkb_start thread anim_loop_solo( directionb2, "direction_take" );
		direction1.animname = "generic";
		direction2.animname = "generic";
		direction1 gun_remove();
		direction2 gun_remove();
									   //   guy 	    anime 			 
		talka_start thread anim_loop_solo( direction1, "direction_give" );
		talka_start thread anim_loop_solo( direction2, "direction_take" );
		
		thread losthope_vo( directionb1, directionb2 );
		thread additionalexit_vo( direction1, direction2 );
	}
	else
	{
						  //   guys 	    volume_name 	 
		reassign_goal_volume( directionb1, "chaos_exit_vol" );
		reassign_goal_volume( directionb2, "chaos_exit_vol" );
		reassign_goal_volume( direction1 , "chaos_exit_vol" );
		reassign_goal_volume( direction2 , "chaos_exit_vol" );
	}

	flag_wait( "exfil_fire_fail" );
	
	if ( IsAlive( directionb1 ) )
	{
		reassign_goal_volume( directionb1, "chaos_exit_vol" );
		directionb1 gun_recall();
	}
	if ( IsAlive( directionb2 ) )
	{
		reassign_goal_volume( directionb2, "chaos_exit_vol" );
		directionb2 gun_recall();
	}
	if ( IsAlive( direction1 ) )
	{
		reassign_goal_volume( direction1, "chaos_exit_vol" );
		direction1 gun_recall();
	}
	if ( IsAlive( direction2 ) )
	{
		reassign_goal_volume( direction2, "chaos_exit_vol" );
		direction2 gun_recall();
	}
}

//angletoplayer()
//{
//	self endon( "death" );
//	
//	while ( IsAlive( self ) )
//	{
//		angleto = VectorToAngles( level.player.origin - self.origin );
//		self Teleport( self.origin, angleto );
//		wait 0.05;
//	}
//}	

commander_vo( commander, walkers )
{
	level endon( "exfil_fire_fail" );
	commander endon( "death" );
	
	flag_wait( "chaos_start_commander_vo" );
	thread allies_move_on_color( walkers );
		
	if ( !flag( "exfil_fire_fail" ) )
	{
		if ( IsAlive( commander ) )
		{
			//"Siberian Commander: No lock it all down, no patrols in or out."
			commander char_dialog_add_and_go( "clockwork_ruc_lockitdown" );
			//"Siberian Commander: Get to the garage and help secure the area."
			commander char_dialog_add_and_go( "clockwork_ruc_gettogarage" );
		}
		
		//"Baker: Yes sir."
		//level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_yessir" );	
		
		allies_move_on_color( walkers );
	}
	else
	{
		foreach ( ally in level.allies )
			ally enable_ai_color();
		
		safe_activate_trigger_with_targetname( "chaos_move_allies_to_garage" );
	}
	
}

allies_move_on_color( walkers )
{
	flag_wait( "chaos_garage_move" );
	
	foreach ( ally in level.allies )
		ally enable_ai_color();

	flag_set( "player_DMS_allow_sprint" );
	thread blend_movespeedscale_custom( 70, 1 );
	safe_activate_trigger_with_targetname( "chaos_move_allies_to_garage" );
	
	level.allies[ 0 ]fast_walk( false );
	level.allies[ 0 ]fast_jog ( true );
	wait 0.25;
	walkers[ 0 ]fast_walk( false );
	walkers[ 0 ]fast_jog ( true );
	wait 0.5;
	walkers[ 1 ]fast_walk( false );
	walkers[ 1 ]fast_jog ( true );
	level.allies[ 1 ]fast_walk( false );
	level.allies[ 1 ]fast_jog ( true );
	wait 1;
	walkers[ 2 ]fast_walk( false );
	walkers[ 2 ]fast_jog ( true );
	wait 0.25;
	level.allies[ 2 ]fast_walk( false );
	level.allies[ 2 ]fast_jog ( true );
}

carry_in()
{
	wait 3;
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		carry_start = getstruct( "chaos_carry_loc", "targetname" );
		carrier		= spawn_targetname( "chaos_carrier" );
		carried		= spawn_targetname( "chaos_carried" );
		
		carrier.animname = "generic";
		carried.animname = "generic";
		
										   //   guy     anime 		   
		carry_start	thread anim_single_solo( carrier, "carrier_sin" );
		carry_start	anim_single_solo( carried, "carried_sin" );
		
		if ( IsAlive( carrier ) && !flag( "exfil_fire_fail" ) )									
			carry_start thread anim_loop_solo( carrier, "carrier_loop" );
		
		if ( IsAlive( carried ) && !flag( "exfil_fire_fail" ) )
			carry_start thread anim_loop_solo( carried, "carried_loop" );
	}
}

dieing_revival()
{	
	revival_loc = getstruct( "chaos_dieing_patient_loc", "targetname" );
	dead_loc	= getstruct		( "chaos_dead_patient_loc"	, "targetname" );
	dead_loc_md = getstructarray( "chaos_dead_patient_mdloc", "targetname" );
	
	reviver			  = spawn_targetname( "chaos_dieing_doctor" );
	wounded			  = spawn_targetname( "chaos_dieing_patient" );
	reviver.animname  = "generic";
	wounded.animname  = "generic";
	 
	reviver endon( "death" );
	 
	wounded gun_remove();
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		reviver gun_remove();
		
		thread dieingrevival_vo( reviver );
		revival_loc thread anim_single_solo( reviver, "dc_burning_cpr_medic" );
		revival_loc anim_single_solo( wounded, "dc_burning_cpr_wounded" );		
		
		if ( IsAlive( reviver ) )
			revival_loc thread anim_loop_solo( reviver, "dc_burning_cpr_medic_endidle", "doctor_wakeup" );
	}
	
	revival_loc thread anim_loop_solo( wounded, "dc_burning_cpr_wounded_endidle" );
	
	flag_wait( "exfil_fire_fail" );
	
	revival_loc notify( "doctor_wakeup" );
	reviver StopAnimScripted();	
	reviver gun_recall();
}

dieingrevival_vo( guy )
{
	level endon( "exfil_fire_fail" );
	guy endon( "death" );
	
	wait 3;
	//"Scientist 1: Initiating CPR."
	guy char_dialog_add_and_go( "clockwork_sc1_cpr" );
	wait 1;
	//"Scientist 2: Live! Live!"
	guy char_dialog_add_and_go( "clockwork_sc2_live" );
	wait 3;
	//"Scientist 2: Administering clotting agent."
	guy char_dialog_add_and_go( "clockwork_sc2_clottingagent" );
	wait 2;
	//"Scientist 1: Continuing CPR."
	guy char_dialog_add_and_go( "clockwork_sc1_continuingcpr" );
	wait 3;
	//"Scientist 2: Patient is stable. Next!"
	guy char_dialog_add_and_go( "clockwork_sc2_patientstable" );
	
}

stumbler_upstairs()
{	
	stumbler			= spawn_targetname( "chaos_stumbler" );
	
	wait 2;
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		struct 			  = getstruct( "chaos_stumbler_struct", "targetname" );
		stumbler.animname = "generic";
		stumbler gun_remove();
		struct anim_single_solo( stumbler, "stumble_to_wall" );
		struct thread anim_loop_solo( stumbler, "stumble_to_wall_idle" );
	}
	else
	{
		stumbler Kill();
	}
}

//*** Start of Exfil Code ***//

yurilast_vo( guy1, guy2 )
{
	level endon( "exfil_fire_fail" );
	guy1 endon( "death" );
	guy2 endon( "death" );
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		guy1.animname = "generic";
		guy2.animname = "generic";
		
		//"Russian Soldier 1: They killed Yuri."
		guy1 char_dialog_add_and_go( "clockwork_rs1_killedyuri" );
		//"Russian Soldier 2: Damn. Everyone loved that guy. I hope someone helps his boys."
		guy2 char_dialog_add_and_go( "clockwork_rs2_helpshisboys" );
	}
}

in_to_jeep()
{	
	flag_wait( "spawn_jeeps" );
	
	thread chaos_kill_player();
		
	wait 0.01;
	
	// shut entrance door and spawn enemies near jeep.
	carparkdoor2 = GetEnt( "car_park_door_intro", "targetname" );
	carparkdoor2 RotateYaw( -90, 0.2, 0.1, 0.1 );	
	carparkdoor2 ConnectPaths();
	carparkjeep	  = array_spawn_targetname( "car_park_base_jeep", 1 );
	startjeepguys = array_spawn_targetname( "car_park_enter_jeep", 1 );
	
	// spawn leading jeep
	level.startjeep = spawn_vehicle_from_targetname( "enemy_jeep_start2" );
	foreach( guy in startjeepguys )
	{
		if( IsAlive( guy ) && IsDefined( guy.script_startingposition ) )
		{
			guy thread waittoturnlightson( level.startjeep );
		}
	}
	//level.startjeep vehicle_lights_on( "headlights" );
	startjeep = spawn_vehicle_from_targetname( "enemy_jeep_start3" );
	startjeep vehicle_lights_on( "headlights" );
	
	//thread maps\clockwork_audio::garage_jeep_start_skid();
	
	// car inspecting group
	sniffingdog = spawn_targetname( "sniffingdog", 1 );
	if ( IsDefined( sniffingdog ) && !flag( "exfil_fire_fail" ) )
	{
		sniffingdog.animname = "generic";
		sniffingdog thread anim_loop_solo( sniffingdog, "dog_scratch_door" );
	}
	
	jeep_search_node = getstruct_delete( "intro_jeep_end_path", "targetname" );
	searcher		 = spawn_targetname( "car_park_base_searcher", 1 );
	if ( IsDefined( searcher ) && !flag( "exfil_fire_fail" ) )
	{
		searcher.animname = "generic";
		jeep_search_node thread anim_loop_solo( searcher, "check_jeep" );
	}
	
	level.jeep.animname = "jeep";
	jeep_search_node thread anim_loop_solo( level.jeep, "open_doors" );
	
	wait 1;
	
	// last runners
	standers = array_spawn_targetname( "car_park_stander", 1);
	
	//spawn jeeps
	level.playerJeep = spawn_vehicle_from_targetname( "jeep_exfil_ride_playerturret" );
	level.allies[1] thread waittoturnlightson( level.playerJeep );
	
	thread baker_anim();
	
	level.gold_jeep_player_door_exfil = Spawn( "script_model", level.playerJeep.origin );
	level.gold_jeep_player_door_exfil SetModel( "chinese_brave_warrior_obj_door_back_RI" );
	level.gold_jeep_player_door_exfil.angles = level.playerJeep.angles;
	level.gold_jeep_player_door_exfil LinkTo( level.playerJeep );
	
	wait 2;
	
	if ( !flag( "exfil_fire_fail" ) )
		level.startjeep vehicle_load_ai( startjeepguys );
	
	level.allies[ 0 ].script_startingposition = 1;//Baker
	level.allies[ 1 ].script_startingposition = 0;//Keegan
	level.allies[ 2 ].script_startingposition = 2;//Cypher
	secondload[ 0 ]							  = level.allies[ 0 ];
	firstload [ 0 ]							  = level.allies[ 1 ];
	firstload [ 1 ]							  = level.allies[ 2 ];
	level.playerJeep vehicle_load_ai( firstload );
	//thread maps\clockwork_audio::exfil_cypher_enter_jeep();
	//thread maps\clockwork_audio::exfil_keegan_enter_jeep();
	
	// needed in case the player goes loud, allies do not shoot if going to enter vehicle
	flag_wait( "get_in_the_jeep" );
	
	startjeep StartPath();
	
	thread maps\clockwork_audio::garage_jeep_start_skid();
	
//	exfiljeep = obj( "exfiljeep" );
//	Objective_Add( exfiljeep, "active", "Get in Jeep" );
//	Objective_OnEntity( exfiljeep, level.playerJeep, ( 0, 0, 64 ) );
//	Objective_Current( exfiljeep );
	
	autosave_by_name( "get_in_the_jeep" );
	thread yurilast_vo( startjeepguys[ 0 ], startjeepguys[ 1 ] );
	//"Baker: Hurry up and get in the jeeps."
	level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_getinthejeep" );
	thread blend_movespeedscale_custom( 100, 1 );
	flag_set( "player_DMS_allow_sprint" );
	
	flag_wait( "start_exfil_ride" ); //player entered jeep
	
	//thread maps\clockwork_audio::exfil_enter_jeep();
	
	//level.playerJeep vehicle_load_ai( secondload );
	
	level.gold_jeep_player_door_exfil Delete();
	disable_trigger_with_targetname( "start_exfil_ride" );
	//objective_complete( exfiljeep );
	
	level.playerJeep thread listen_player_collision();
	level.playerJeep thread listen_player_jolt();
	
	// kill player if truck dies.
	thread kill_player();
	
	// open exit door.
	carparkdoor = GetEnt( "car_park_door", "targetname" );
	carparkdoor RotateYaw( 90, 0.2, 0.1, 0.1 );	
	carparkdoor ConnectPaths();
		
	//place player in back of jeep.	
	level.player SetStance( "stand" );
	level.player DisableWeapons();
	
	//triggerexfil = getent( "start_exfil_ride", "targetname" );
	level.player DisableWeapons();
	wait 0.25;
	
	arms_struct = getstruct( "exfil_move_player_enter_jeep", "targetname" );
	
	level.jeep_player_arms = spawn_anim_model( "player_rig" );
	level.jeep_player_arms SetModel( "clk_watch_viewhands_off" );
	level.jeep_player_arms hide();
	level.jeep_player_arms LinkTo( level.playerjeep, "tag_guy1", ( -10, -45, -32 ), ( 0, 90, 0 ) );
	level.playerJeep thread anim_first_frame_solo( level.jeep_player_arms, "player_getin", "tag_guy1" );
	level.player PlayerLinkToBlend( level.jeep_player_arms, "tag_player", .25 );
	wait 0.25;
	
	if( !flag( "baker_ready" ) )
	   level.allies[ 0 ] anim_stopanimscripted();
	   
	thread maps\clockwork_audio::exfil_enter_jeep();
	exploder( 750 ); //fx on ramp
	
	level.jeep_player_arms Show();
	
	// Turn on headlights during the anim
	PlayFXOnTag( getfx( "spotlight_dlight" ), level.playerJeep, "tag_headlight_left" );
	
	level.playerJeep.animname = "jeep";
	level.playerJeep thread anim_single_solo( level.playerjeep, "player_getin" );
	level.playerJeep anim_single_solo( level.jeep_player_arms, "player_getin", "tag_guy1" );
	
	level.jeep_player_arms Hide();
	level.player EnableWeapons();
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player PlayerLinkToDelta( level.jeep_player_arms, "tag_player", 0.9, 360, 360, 45, 30, true );
	level.player SetPlayerAngles( ( 0, level.playerJeep.angles[ 1 ], 0 ) );
	   
	flag_wait( "baker_in_jeep" );
	
	while( 1 )
	{
		if( isdefined( level.allies[1].ridingvehicle ) )
			if( isdefined( level.allies[2].ridingvehicle ) )
				break;
		wait .1;
	}
	
	if ( !flag( "exfil_fire_fail" ) )
	{
		//"Baker: Wait for my signal before engaging"
		level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_waitformysignal" );
	}
	
	thread maps\clockwork_audio::chase_player();
	
	// start leading jeep
	if ( IsDefined( level.startjeep.driver ) && IsAlive( level.startjeep.driver ) )
	{
		thread maps\clockwork_audio::lead_jeep();
		level.startjeep StartPath();
		level.startjeep.driver magic_bullet_shield( 1 ); // make driver invulnerable when jeep starts
		level.startjeepmoving = 1;		
		if ( flag( "exfil_fire_fail" ) )
			level.startjeep Vehicle_SetSpeed( 40, 10 );
	}
	
	wait 1;
	
	level.allies[ 1 ].animname 	= "generic"; // Keegan
	level.allies[ 2 ].animname 	= "generic"; // Cypher
	level.playerJeep.animname 	= "jeep"; 
	level.playerJeep thread vehicle_play_guy_anim( "exfilstartdriver", 		level.allies[1], 	0 );
	level.playerJeep thread vehicle_play_guy_anim( "exfilstartpassenger", 	level.allies[0],  	1 );
	level.playerJeep SetFlaggedAnimRestart( "vehicle_anim_flag", level.playerJeep getanim("exfilstartJeep") );
	//level.playerJeep thread anim_single_solo( 		level.playerJeep, 		"exfilstartJeep", 	"tag_origin" );
	level.playerJeep StartPath();
		
	//vehicle
	wait 0.5;
	
	// kill off security group.
	security_enemies = GetEntArray( "chaos_patrollers", "script_noteworthy" );
	foreach ( guy in security_enemies )
	{
		if ( IsAlive( guy ) )
			guy Delete();
	}
	
	wait 2;
	
	// ambient enemies
	if ( !flag( "exfil_fire_fail" ) )
	{
		counterjeep = spawn_vehicles_from_targetname_and_drive( "enemy_jeep_start" );
		counterjeep[0] vehicle_lights_on( "headlights" );
	}
	
	runners		   = array_spawn_targetname( "exfil_warners", 1 );
	carpark		   = array_spawn_targetname( "car_park_base"   , 1 );
	carparkwalkers = array_spawn_targetname( "car_park_walkers", 1 );
	
	if ( !flag( "exfil_fire_fail" ) ) // sneak vo
	{
		thread handle_sneak_vo();
		foreach ( guy in carparkwalkers )
		{
			guy fast_walk( true );
		}
	}
	else // loud vo.
	{
		//"Baker: Scarecrow, we're exiting the base."
		level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_exitingthebase" );
		//Diaz: We'll meet on the exfil road.
		radio_dialog_add_and_go( "clockwork_diz_meetonexfil" );
		//Baker: Keep it tight. Exfil will be here in two minutes.
		level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_exfilin2mins" );
		thread clockwork_timer( 95, &"CLOCKWORK_EXFIL", true );	
	}
	
	// punch it moment
	flag_wait( "exfil_door_close_start" );
	
	if ( IsAlive( sniffingdog ) )
		sniffingdog Delete();
	
	/*
  	// Old punch it script
	thread stopitguy();
	
	wait 2;
	//level.player LerpViewAngleClamp( .5, 0, 0, 10, 30, 45, 30 );
	//level.player PlayerLinkToDelta( level.jeep_player_arms, "tag_player", 1, 10, 30, 45, 30, true );
	*/
	
	// start new anim
	if( !flag( "exfil_fire_fail" ) )
	{
		punchit_start( startjeep );
		
		wait .5;
		
		punchit_end( startjeep, carparkdoor, carparkwalkers, runners, carpark );
	}

	thread playfx_for_player_tread();

}

punchit_start( carparkjeep )
{
	//thread print_location( level.playerJeep );
	//thread print_location( level.startjeep );
	//thread print_location( carparkjeep );
	
	stopguy	= GetEntArray( "stop_guy", "script_noteworthy" );
	foreach ( guy in stopguy )
	{
		if ( IsAlive( guy ) )
		{
			level.stopguy1 = guy;
		}
	}
	
	stopguy2 = GetEntArray( "stop_guy2", "script_noteworthy" );
	foreach ( guy in stopguy2 )
	{
		if ( IsAlive( guy ) )
		{
			level.stopguy2 = guy;			
		}
	}
	
	stopguy3 = GetEntArray( "stop_guy3", "script_noteworthy" );
	foreach ( guy in stopguy3 )
	{
		if ( IsAlive( guy ) )
		{
			level.stopguy3 = guy;			
		}
	}
	
	punch_it = getstruct( "punchit_scene", "targetname" );

	level.startjeep.animname = "cw_punchit";
	level.startjeep SetFlaggedAnimRestart( "vehicle_anim_flag", level.startjeep getanim("punchit_start_enemy_jeep") );
//	level.startjeep thread anim_single_solo( level.startjeep, "punchit_start_enemy_jeep" );
	level.playerJeep.animname = "cw_punchit";
	level.playerJeep SetFlaggedAnimRestart( "vehicle_anim_flag", level.playerJeep getanim("punchit_start_ally_jeep") );
//	level.playerJeep thread anim_single_solo( level.playerJeep, "punchit_start_ally_jeep" );
		
//	carparkjeep.animname = "cw_punchit";
//	punch_it thread anim_single_solo( carparkjeep, "punchit_start_parked_jeep" );
//		
//	level.startjeep.animname = "cw_punchit";
//	punch_it thread anim_single_solo( level.startjeep, "punchit_start_enemy_jeep" );
	
	if( level.startjeep.riders[0].script_startingposition == 0 )
	{
		level.startjeep.riders[0].animname = "generic";
		level.startjeep.riders[1].animname = "generic";
		level.startjeep.riders[0] thread anim_single_solo( level.startjeep.riders[0], "punchit_start_edriver" );
		level.startjeep.riders[1] thread anim_single_solo( level.startjeep.riders[1], "punchit_start_epass" );
	}
	else
	{
		level.startjeep.riders[0].animname = "generic";
		level.startjeep.riders[1].animname = "generic";
		level.startjeep.riders[1] thread anim_single_solo( level.startjeep.riders[1], "punchit_start_edriver" );
		level.startjeep.riders[0] thread anim_single_solo( level.startjeep.riders[0], "punchit_start_epass" );
	}
	
	level.allies[ 1 ].animname = "generic"; // Keegan
	level.playerJeep thread vehicle_play_guy_anim( "punchit_start_keegan", 	level.allies[ 1 ], 0 );
		
	level.allies[ 0 ].animname = "generic"; // Baker
	level.playerJeep thread vehicle_play_guy_anim( "punchit_start_baker", 	level.allies[ 0 ], 1 );
		
	level.allies[ 2 ].animname = "generic"; // Cypher
	level.playerJeep thread vehicle_play_guy_anim( "punchit_start_cypher", 	level.allies[ 2 ], 2 );

	level.stopguy1.animname = "generic";
	level.stopguy2.animname = "generic";
	level.stopguy3.animname = "generic";
	punch_it thread anim_single_solo( level.stopguy1, "punchit_start_guard1" );
	punch_it thread anim_single_solo( level.stopguy2, "punchit_start_guard2" );
	punch_it thread anim_single_solo( level.stopguy3, "punchit_start_guard3" );
	
	level.pistol	    = spawn_anim_model( "cw_pistol", level.allies[ 2 ].origin );
	level.pistol.angles = level.allies[ 2 ].angles;
	level.pistol		linkto( level.playerJeep, "tag_guy0" );
	level.allies[ 2 ] thread anim_single_solo( level.pistol, "start" );
	
	flag_wait_or_timeout( "exfil_fire_fail", 23 );
}

//print_location( jeep )
//{
//	jeep endon( "death" );
//	
//	while( IsDefined( jeep ) )
//	{
//		IPrintLn( jeep.target + ": " + jeep.origin + " ; " + jeep.angles );
//		wait 1;
//	}
//}

punchit_end( carparkjeep, carparkdoor, carparkwalkers, runners, carpark )
{
	punch_it = getstruct( "punchit_scene", "targetname" );
	
	if( !flag( "exfil_fire_fail" ) )
	{
		thread punchit_jeeps( carparkjeep, punch_it );
	}
	
	if( level.startjeep.riders[0].script_startingposition == 0 )
	{
		if( IsDefined( level.startjeep.riders[0] ) && IsDefined( level.startjeep.riders[1] ) )
		{
			level.startjeep.riders[0].animname = "generic";
			level.startjeep.riders[1].animname = "generic";
			level.startjeep.riders[0] thread anim_single_solo( level.startjeep.riders[0], "punchit_end_edriver" );
			level.startjeep.riders[1] thread anim_single_solo( level.startjeep.riders[1], "punchit_end_epass" );
		}
	}
	else
	{
		if( IsDefined( level.startjeep.riders[0] ) && IsDefined( level.startjeep.riders[1] ) )
		{
			level.startjeep.riders[0].animname = "generic";
			level.startjeep.riders[1].animname = "generic";
			level.startjeep.riders[1] thread anim_single_solo( level.startjeep.riders[1], "punchit_end_edriver" );
			level.startjeep.riders[0] thread anim_single_solo( level.startjeep.riders[0], "punchit_end_epass" );
		}
	}
	
	level.playerJeep.animname = "cw_punchit";
	level.playerJeep SetFlaggedAnimRestart( "vehicle_anim_flag", level.playerJeep getanim("punchit_end_ally_jeep") );
//	level.playerJeep thread anim_single_solo( level.playerJeep, "punchit_end_ally_jeep" );
	
	level.allies[ 1 ].animname = "generic"; // Keegan
	level.playerJeep thread vehicle_play_guy_anim( "punchit_end_keegan", 	level.allies[ 1 ], 0 );
		
	level.allies[ 0 ].animname = "generic"; // Baker
	level.playerJeep thread vehicle_play_guy_anim( "punchit_end_baker", 	level.allies[ 0 ], 1 );
		
	level.allies[ 2 ].animname = "generic"; // Cypher
	level.playerJeep thread vehicle_play_guy_anim( "punchit_end_cypher", 	level.allies[ 2 ], 2 );

	if( IsDefined( level.startjeep.riders[0] ) && IsDefined( level.startjeep.riders[1] ) )
	{
		level.stopguy1.animname = "generic";
		punch_it thread anim_single_solo( level.stopguy1, "punchit_end_guard1" );
	}
	
	if( IsDefined( level.startjeep.riders[0] ) && IsDefined( level.startjeep.riders[1] ) )
	{
		level.stopguy2.animname = "generic";
		punch_it thread anim_single_solo( level.stopguy2, "punchit_end_guard2" );
	}
	
	if( IsDefined( level.startjeep.riders[0] ) && IsDefined( level.startjeep.riders[1] ) )
	{
		level.stopguy3.animname = "generic";
		punch_it thread anim_single_solo( level.stopguy3, "punchit_end_guard3" );
	}
	
	level.allies[ 2 ] thread anim_single_solo( level.pistol, "end" );
	
	wait .05;
	
	//"Baker: Punch it!"
	level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_punchit" );
	
	wait .2;
	
	flag_set( "chase_punch_it" );
	flag_set( "punchit_go" );
	
	carparkdoor RotateYaw( -90, 12, 8, 1 );	
	
	foreach ( guy in carparkwalkers )
	{
		if( IsDefined( guy ) )
			guy fast_walk( false );
	}
	
	if ( IsAlive( runners[ 0 ] ) )
	{
		enode1 = GetNodeArray( "runto_exfil_1", "targetname" );
		runners[ 0 ]SetGoalNode		  ( enode1[ 0 ] );
		runners[ 0 ]set_fixednode_true(	 );
	}
	
	if ( IsAlive( runners[ 1 ] ) )
	{
		enode2 = GetNodeArray( "runto_exfil_2", "targetname" );
		runners[ 1 ]SetGoalNode		  ( enode2[ 0 ] );
		runners[ 1 ]set_fixednode_true(	 );
	}
		
	thread wakeup_enemies( carpark );
	
	foreach ( ally in level.allies )
	{
		ally.ignoreall = false;
		ally.ignoreme  = false;
	}
	
	wait 1.25;
}

punchit_jeeps( carparkjeep, punch_it )
{
//	flag_wait( "punchit_car_one" );
//	carparkjeep.animname = "cw_punchit";
//	punch_it thread anim_single_solo( carparkjeep, "punchit_end_parked_jeep" );
	
	flag_wait( "punchit_car_two" );
	wait .05;
	//thread screen_shake_exfil();
	level.startjeep.animname = "cw_punchit";
	punch_it thread anim_single_solo( level.startjeep, "punchit_end_enemy_jeep" );
}

waittoturnlightson( car )
{
	self waittill( "enteredvehicle" );
	
	car vehicle_lights_on( "headlights" );
}

baker_anim()
{
	level.allies[ 0 ].animname = "generic"; // Baker
	
	if( !flag( "start_exfil_ride" ) )
		level.playerJeep anim_reach_solo( level.allies[0], "garage_enter" );
	
	if( !flag( "start_exfil_ride" ) )
		level.playerJeep anim_single_solo( level.allies[0], "garage_enter" );
	
	if( !flag( "start_exfil_ride" ) )
		level.playerJeep thread anim_loop_solo( level.allies[0], "garage_loop", "end_loop" );
		
	flag_wait( "start_exfil_ride" );
	
	level.playerJeep notify( "end_loop" );
	
	waittillframeend;
	
	flag_set( "baker_ready" );
	
	level.playerJeep anim_single_solo( level.allies[0], "garage_exit" );
	level.allies[0] thread anim_enter_finished( "baker_in_jeep" );
}
/*
stopitguy()
{	
	stopguy2 = GetEntArray( "stop_guy2", "script_noteworthy" );
	
	ent		   = createOneshotEffect( "fx/lights/lights_strobe_red_dist_max_small" );
	position   = getstruct( "exfil_red_light", "targetname" );
	ent.origin = position.origin;
	ent.angles = position.angles;
	
	thread first_stopitguy();
	
	wait 0.5;

	foreach ( guy in stopguy2 )
	{
		if ( IsAlive( guy ) )
		{
			guy endon( "Death" );
			
			guy.animname		= "keegan";
			guy thread anim_single_solo( guy, "stop_signal" );
		}
	}
	
	wait 10;
	
	foreach ( guy in stopguy2 )
	{
		if ( IsAlive( guy ) )
		{
			guy delete();
		}
	}
}

first_stopitguy()
{
	stopguy = GetEntArray( "stop_guy", "script_noteworthy" );
	runover = GetEntArray( "chaos_gets_runover", "script_noteworthy" );
	
	scene		 = getstruct( "chaos_stopitguy", "targetname" );
	runover_loc1 = getstruct( "chaos_stopitguy_runover", "targetname" );
	runover_loc2 = getstruct( "chaos_runaway_exit", "targetname" );
	
	foreach ( guy in stopguy )
	{
		if ( IsAlive( guy ) )
		{
			guy endon( "Death" );
						
			guy.animname		= "generic";
			//"Siberian Soldier 1: Stop! No patrols leave."
			guy thread char_dialog_add_and_go( "clockwork_ru1_stopnopatrols" );
			scene anim_single_solo( guy, "stopanim" );
		}
	}
	
	foreach ( guy in runover )
	{
		if ( IsAlive( guy ) )
		{
			guy endon( "Death" );
			
			guy.animname		= "keegan";
			guy thread anim_single_solo( guy, "stop_run2" );
		}
	}
	
	wait 10;
	
	foreach ( guy in runover )
	{
		if ( IsAlive( guy ) )
		{
			guy delete();
		}
	}
	foreach ( guy in stopguy )
	{
		if ( IsAlive( guy ) )
		{
			guy delete();
		}
	}
}
*/
wakeup_enemies( guys )
{
	guys = array_removeDead( guys );
	foreach ( guy in guys )
	{
		if ( IsDefined( guy ) )
		{
			guy.ignoreall = false;
			guy.ignoreme  = false;
			guy thread continous_fire();
		}
		wait 0.25;
	}
}

continous_fire()
{
	self endon( "death" );
	
	while ( IsAlive( self ) && ( self.weapon != "none" ) )
	{
		self ShootBlank();
		wait ( RandomFloatRange( 0.56, .7 ) );
	}
}

handle_sneak_vo()
{
	level endon( "exfil_fire_fail" );
	
	//"Baker: Scarecrow, we're exiting the base."
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_exitingthebase" );
	//Diaz: We'll meet on the exfil road.
	radio_dialog_add_and_go( "clockwork_diz_meetonexfil" );
	//Baker: Keep it tight. Exfil will be here in two minutes.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_exfilin2mins" );
	
	thread clockwork_timer( 125, &"CLOCKWORK_EXFIL", true );
	
	// punch it start
	flag_wait( "exfil_door_close_start" );
	wait 2;
	//Keegan: They’re stopping jeeps.
	level.allies[ 1 ] char_dialog_add_and_go( "clockwork_kgn_theyrestoppingjeeps" );
	//Merrick: Keep to the script. Stop but be ready.
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_keeptothescript" );
	
	wait 4;
	
	//Federation Soldier 1: Out of the car!
	level.stopguy2		thread char_dialog_add_and_go( "clockwork_saf1_outofthecar" );
	wait 1;
	//Federation Soldier 2: Hands up!
	level.stopguy1		char_dialog_add_and_go( "clockwork_saf2_handsup" );
	//Federation Soldier 1: Don’t move!
	level.stopguy2		char_dialog_add_and_go( "clockwork_saf1_dontmove" );
	
	//Federation Soldier 1: You guys stop, stop right there.
	level.stopguy2		char_dialog_add_and_go( "clockwork_saf1_youguysstopstop" );
	//Federation Soldier 1: Hey, cut the engine.
	level.stopguy2		char_dialog_add_and_go( "clockwork_saf1_heycuttheengine" );
	//Federation Soldier 1: Let’s go c’mon, cut the engine.
	level.stopguy2		char_dialog_add_and_go( "clockwork_saf1_letsgocmoncut" );
	//Keegan: What’s going on up there?
	level.allies[ 1 ] 	thread char_dialog_add_and_go( "clockwork_kgn_whatsgoingonup" );
	wait .25;
	//Federation Soldier 1: We gotta check everybody, we’re checking IDS, we’re checking badges, everybody…
	level.stopguy2		thread char_dialog_add_and_go( "clockwork_saf1_wegottacheckeverybody" );
	//Keegan: Command just ordered us to the perimeter!
	level.allies[ 1 ] 	char_dialog_add_and_go( "clockwork_kgn_commandjustorderedus" );
	//Federation Soldier 1: C’mon get the Masks off…
	level.stopguy2		thread char_dialog_add_and_go( "clockwork_saf1_cmongetthemasks" );
	//Keegan: We don’t have time for this!
	level.allies[ 1 ]	char_dialog_add_and_go( "clockwork_kgn_wedonthavetime" );
	if( IsDefined( level.stopguy2 ) && IsAlive( level.stopguy2 ) )
	{
		//Federation Soldier 1: Get the masks off, all 4 of you!
		level.stopguy2		char_dialog_add_and_go( "clockwork_saf1_getthemasksoff" );
	}
//	if( IsDefined( level.stopguy2 ) && IsAlive( level.stopguy2 ) )
//	{
//		//Federation Soldier 1: Now! Pull the masks off!  Let’s go!
//		level.stopguy2		char_dialog_add_and_go( "clockwork_saf1_nowpullthemasks" );
//	}
//	//"Keegan: Thirty seconds."
//	level.allies[ 1 ] char_dialog_add_and_go( "clockwork_kgn_thirtyseconds" );
//	//"Baker: Hold."
//	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_hold" );
	
}

crash_event()
{
	flag_wait( "ally_start_path_exfil" );
	
	wait 0.25;
	
	autosave_by_name( "exfil_baseexit_save" );
	
	battlechatter_on( "allies" );
	
	//"Diaz: Base is on full alert."
//	thread radio_dialog_add_and_go( "clockwork_diz_fullalert" );
	
	//level.playerJeep thread anim_single_solo( level.allies[1],  "exfilintensedriver" );
	//level.playerJeep SetFlaggedAnimRestart( "vehicle_anim_flag", level.playerJeep getanim("exfilintenseJeep") );
	//level.playerJeep thread anim_loop_solo( level.playerJeep, "exfilintenseJeep", "tag_origin" );
	
	// kill off carpark group.
	security_enemies = GetAIArray( "axis" );
	foreach ( guy in security_enemies )
	{
		if ( IsAlive( guy ) )
			guy Delete();
	}
	
	thread getinturret();
	
	wait 0.1;
	exteriorbase = array_spawn_targetname( "exfil_exterior_base", 1 );
	waittillframeend;
	level.enemy_jeep_follower1 = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_follower1" );
	waittillframeend;
	level.enemy_jeep_follower2 = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_follower2" );
	waittillframeend;
	level.enemy_jeep_follower1 vehicle_lights_on( "headlights" );
	//level.enemy_jeep_follower1 godon();
	//level.enemy_jeep_follower1.health = 2000000; // vehicle still dies in god mode
	
	level.enemy_jeep_follower2 vehicle_lights_on( "headlights" );
	//level.enemy_jeep_follower2 godon();
	//level.enemy_jeep_follower2.health = 2000000; // vehicle still dies in god mode
	thread enemy_jeep_group_fire();
	
	wait 3;
	
	//"Baker: Enemy jeeps on the lower right!"
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_enemyjeepsonthe" );
	//"Baker: Take them out!"
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_takethemout" );
	
	flag_wait( "gate_crash_player" );
	
	level.player EnableInvulnerability();
	//"Baker: Ram it!"
	level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_ramit" );
	wait 1;
	//"Baker: Hold on!"
	level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_holdon" );
	wait 1;
	
	//thread screen_shake_exfil();
	
	if ( IsAlive( level.enemy_jeep_follower1 ) )
	{
		level.enemy_jeep_follower1 VehPhys_EnableCrashing();
		vector = rotate_vector( ( 0, 90, 0 ), level.enemy_jeep_follower1.angles );
		level.enemy_jeep_follower1 VehPhys_Launch( ( vector * 2 ), 0 );
	}
	
	wait 3;
	
	level.player DisableInvulnerability();
		
	flag_wait( "rpg_spawn" );
	//sjp none of the 4 guys in the vehicles were being deleted- adding for greenlight SRE protection.
	riders_to_delete = get_living_ai_array( "riders_exterior_delete", "script_noteworthy" );
	
	foreach ( guy in riders_to_delete )
	{
		
		if ( IsDefined( guy ) )
		{
			guy Delete();
		}
	}
	
	
	foreach ( guy in exteriorbase )
	{
		if ( IsDefined( guy ) )
			guy Delete();
	}
	
	if ( IsAlive( level.enemy_jeep_follower1 ) )
	{
		level.enemy_jeep_follower1 Delete();
	}
	if ( IsAlive( level.enemy_jeep_follower2 ) )
	{
		level.enemy_jeep_follower2 Delete();
	}
}

getinturret()
{
	thread maps\clockwork_audio::exfil_get_on_turret();
	
	//"Baker: Rook, get on the turret."
	radio_dialog_add_and_go( "clockwork_bkr_getturret" );
	
	level.allies[ 0 ] clear_generic_idle_anim();
	level.allies[ 1 ] clear_generic_idle_anim();
	level.allies[ 2 ] clear_generic_idle_anim();
	
	// player moves to turret.
	level.player DisableWeapons();
	level.jeep_player_arms LinkTo( level.playerjeep, "tag_guy1", ( 50, 0, 0 ), ( 0, 0, 0 ) );
	level.jeep_player_arms thread anim_first_frame_solo( level.jeep_player_arms, "player_toturret" );
	level.jeep_player_arms Show();
	
				  //   number    waittime   
	thread standally( 0		  , .5 );
	thread standally( 2		  , .01 );
	
	level.player LerpViewAngleClamp( .5, 0, 0, 0, 0, 0, 0 );
	level.playerJeep anim_single_solo( level.jeep_player_arms, "player_toturret", "tag_guy1" );
	
	thread play_rumble_seconds( "damage_heavy", .25 );
	thread screenshakeFade( 0.35, .25 );
	
	level.jeep_player_arms Hide();
	level.player PlayerLinkToDelta( level.playerJeep, "tag_guy_turret", 0.1, 360, 360, 30, 20, true );
	level.jeep_player_arms Delete();
	turret = level.playerJeep.mgturret[ 0 ];
	turret MakeUsable();
	turret UseBy( level.player );
	turret MakeUnusable();
	
	level.player EnableWeapons();
	level.player_turret = turret;
	level.player SetPlayerAngles( ( 0, level.playerJeep.angles[ 1 ], 0 ) );
	level.player DisableTurretDismount();
	thread player_viewhands_minigun( turret, "viewhands_player_yuri" );
	level.playerJeep thread fire_grenade();
	level.player SetStance( "stand" );
	
	//Does this work?
	SetSavedDvar( "aim_aimAssistRangeScale", "0" );
	SetSavedDvar( "aim_autoAimRangeScale"  , "0" );
	
	level.playerJeep vehicle_ai_event( "idle_alert" ); 
	
	//level.player thread hint( "Press ^3[{weapnext}]^7 to switch from grenades.", 3 );
}

standally( number, waittime )
{
	wait waittime;
	
	level.allies[ number ] notify( "newanim" );
	level.allies[ number ].desired_anim_pose = "crouch";
	level.allies[ number ]anim_stopanimscripted(  );
	level.allies[ number ]AllowedStances	   ( "crouch" );

	level.allies[ number ].baseaccuracy			 = 0.1;
	level.allies[ number ].accuracystationarymod = 0.5;
}

headon_event()
{	
	flag_wait( "en_headon_road" );
	
	wait 0.25;
	
	level.enemy_jeep_turret[ level.enemy_jeep_turret.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_tank_headon" );

	
	thread enemy_zodiacs_spawn_and_attack();
	level.enemy_jeep_a[ level.enemy_jeep_a.size ] 	= spawn_vehicle_from_targetname_and_drive( "enemy_jeep_intercept1" );
	waittillframeend;
	level.speedJeep									= spawn_vehicle_from_targetname_and_drive( "enemy_jeep_intercept2" );
	waittillframeend;
	level.enemy_jeep_b[ level.enemy_jeep_b.size ] 	= spawn_vehicle_from_targetname_and_drive( "enemy_jeep_intercept4" );
	waittillframeend;
	level.enemy_jeep_b[ level.enemy_jeep_b.size ] 	= spawn_vehicle_from_targetname_and_drive( "enemy_jeep_intercept6" );
	waittillframeend;
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ]	vehicle_lights_on( "headlights" );
	level.speedJeep										vehicle_lights_on( "headlights" );
	level.enemy_jeep_b[ level.enemy_jeep_b.size - 1 ]vehicle_lights_on( "headlights" );
	level.enemy_jeep_b[ level.enemy_jeep_b.size - 1 ]vehicle_lights_on( "headlights" );
	thread enemy_jeep_group_fire();
	wait 3;
	
	//"Baker: Gaz, get off the road."
	level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_offtheroad" );	
	wait 1;
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_jeep_intercept3" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	wait 1;
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_jeep_intercept5" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	wait 2;
	
	//"Cypher: Targets behind us!"
	level.allies[ 2 ] thread char_dialog_add_and_go( "clockwork_cyr_targetsbehindus" );
	
	thread vehicle_hit_drift();
}

canal_event()
{	
	flag_wait( "rpg_spawn" );
	
	canal_rpgers		= array_spawn_targetname( "canal_rpgers", 1 );
	array_thread( canal_rpgers, ::magic_bullet_shield );
	
	// Start detecting holes in ice.
	level.icehole_count = 0;
	level.player thread handle_grenade_launcher();
	wait 4.5;
	
	//"Diaz: RPGS!"
	radio_dialog_add_and_go( "clockwork_diz_rpgs" );
	
	thread maps\clockwork_audio::chase_tower_fire();
	
	playerJeepRepulsor = Missile_CreateRepulsorEnt( level.playerJeep, 750, 10000 );
	startshoot		   = canal_rpgers[ 2 ].origin + ( -60, 0, 75 );
	targetshoot		   = getstruct( "rpg_hit_enemy_jeep", "targetname" );
	MagicBullet( "rpg_straight", startshoot, targetshoot.origin );
	wait 1.25;
	
	Missile_DeleteAttractor( playerJeepRepulsor );
	startshoot	= canal_rpgers[ 0 ].origin + ( -60, 0, 75 );
	targetshoot = getstruct( "rpg_hit_enemy_jeep", "targetname" );
	MagicBullet( "rpg_straight", startshoot, targetshoot.origin );
	wait 1.25;
	
	thread add_ice_radius( 50, targetshoot.origin );

	if ( IsAlive( level.speedJeep ) )
	{
		//level.speedJeep thread play_crash_anim( targetshoot.origin );
		level.speedJeep thread play_long_crash();
	}
	
	startshoot	= canal_rpgers[ 1 ].origin + ( 0, -60, 75 );
	targetshoot = getstruct( "rpg_target_ally_jeep", "targetname" );
	MagicBullet( "rpg_straight", startshoot, targetshoot.origin );
	wait 1.25;
	
	// create icehole for rpgs on ice.
	thread add_ice_radius( 50, targetshoot.origin );
	
	array_thread( canal_rpgers, ::stop_magic_bullet_shield );
	foreach ( rpg in canal_rpgers )
		rpg Delete();
	
	radio_dialog_add_and_go( "clockwork_bkr_shoottheice" );
	radio_dialog_add_and_go( "clockwork_bkr_shoottheice" );
						
	tunnelbase = array_spawn_targetname( "exfil_exterior_tunnel", 1 );
	
	flag_wait( "spawn_tunnel_jeep" );
	thread maps\clockwork_audio::chase_tunnel_jeep();
	
	//Garage FX Off
	flag_set( "cagelight" );
	flag_set( "tubelight_parking" );
	
			   //   num   
	stop_exploder( 250 );//turn off security checkpoint fx
	stop_exploder( 300 );//turn off ambient garage smoke
	stop_exploder( 301 );//turn off ambient garage smoke
	stop_exploder( 750 );//stop all fx on ramp

	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = thread spawn_vehicle_from_targetname_and_drive( "snowmobile_spawner_bend1" );
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ]	vehicle_lights_on( "headlights" );
	
	flag_wait( "en_jeep2_jump" );
	
	foreach ( guy in tunnelbase )
	{
		if ( IsDefined( guy ) )
			guy Delete();
	}
}

tank_event()
{	
	flag_wait( "en_jeepphys_spawn" );
	
	//"Neptune: Exfil will be in position in 60 seconds"
//	thread radio_dialog_add_and_go( "clockwork_npt_exfil60secs" );
	
	wait 3;
	//"Cypher: Snowmobiles behind."
	level.allies[ 2 ] thread char_dialog_add_and_go( "clockwork_cyr_snowmobilesbehind" );
		
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "snowmobile_spawner_bend2" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	wait 0.2;
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "snowmobile_spawner_bend3" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	
	thread wipeout_bikes();
	
	flag_wait( "en_jeep2_jump" );	
	wait 1;
	
	// build spotlight truck
	level.tank_bridge = spawn_vehicle_from_targetname_and_drive( "enemy_tank_bridge" );
	/*
	spotlight		 = spawn_tag_origin(   );
	spotlight.angles = level.tank_bridge GetTagAngles( "tag_turret" );
	spotlight.origin = level.tank_bridge GetTagOrigin( "tag_turret" );
	spotlight.origin = spotlight.origin + ( 0, 0, -64 );
	spotlight LinkTo( level.tank_bridge, "tag_turret" );
	PlayFXOnTag( getfx( "flashlight_spotlight" ), spotlight, "tag_origin" );
	level.tank_bridge thread aimlight( spotlight, level.player );
	*/
	
	wait 0.25;
	
	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_tankfire1" );
	waittillframeend;
	level.enemy_jeep_b[ level.enemy_jeep_b.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_tankfire2" );
	waittillframeend;
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] vehicle_lights_on( "headlights" );
	crashme = level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ];
	level.enemy_jeep_b[ level.enemy_jeep_b.size - 1 ] vehicle_lights_on( "headlights" );
	
	wait 1.7;
	
	level.tankfire_spline_jeep					  = thread spawn_enemy_bike_at_spawer( "enemy_jeep_tankfire3" );
	level.enemy_jeep_s[ level.enemy_jeep_s.size ] = level.tankfire_spline_jeep;
	level.tankfire_spline_jeep vehicle_lights_on( "headlights" );
		
	//"Cypher: More jeeps behind."
	level.allies[ 2 ] thread char_dialog_add_and_go( "clockwork_cyr_jeepsbehind" );
	
	thread enemy_jeep_group_fire();
		
	wait 4.5;
	
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_bridgea1" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	waittillframeend;
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_bridgea2" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	
	wait 3.5;
	
	thread forty_five_sec_vo();
	
	// start tank movement again
	if ( IsAlive( level.tank_bridge ) )
	{
		level.tank_bridge.attachedpath = undefined;
	    level.tank_bridge notify( "newpath" );
	    
	    level.tank_bridge Vehicle_SetSpeed( 30, 4, 4 ); //needed to get the vehicle moving
	    level.tank_bridge ResumeSpeed( 3 );
	    
		newtankpath = GetVehicleNode( "tank_chase_path", "targetname" );
		level.tank_bridge thread vehicle_paths( newtankpath );
	    level.tank_bridge StartPath( newtankpath );
	}
	
	flag_wait( "spawn_bridge_jeeps" );
	
	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = spawn_vehicle_from_targetname_and_drive( "highway_jeep1" );	
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] vehicle_lights_on( "headlights" );
	
	flag_wait( "exfil_car_should_crash" );
	
	crashme thread play_crash_anim( crashme.origin );
}

forty_five_sec_vo()
{
	//"Baker: Neptune this is Voodoo one actual - we are inbound for a hot exfil"
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_hotexfil" );
	//"Neptune: Understood Voodoo, we will be in position in 45 seconds"
	thread radio_dialog_add_and_go( "clockwork_npt_45seconds" );
}

bridge_event()
{	
	flag_wait( "exfil_prechoke_spawn" );
	thread maps\clockwork_fx::handle_jeep_launch_fx();
	
	autosave_by_name( "prechoke_save" );
		
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_bridge1" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	waittillframeend;
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_bridge2" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	thread wipeout_bikes();
	
	thread maps\clockwork_audio::snowmobiles();
		
	flag_wait( "exfil_spawn_choke_guys" );
	
	level.enemy_jeep_b[ level.enemy_jeep_b.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_prechoke1" );
	waittillframeend;
	level.enemy_jeep_b[ level.enemy_jeep_b.size - 1 ] vehicle_lights_on( "headlights" );
	prechokejeep1 = level.enemy_jeep_b[ level.enemy_jeep_b.size - 1 ];
	
	wait 1;
	
	prechokejeep2 = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_prechoke2" );
	waittillframeend;
	prechokejeep2 vehicle_lights_on( "headlights" );
	
	waittillframeend;
		
	thread enemy_jeep_group_fire();
	
	thread maps\clockwork_audio::bigjump();
	
	wait 2;
	
	level.enemy_jeep_b[ level.enemy_jeep_b.size ] = prechokejeep2;
	
	level.enemy_jeep_turret[ level.enemy_jeep_turret.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_prechoke3" );
	waittillframeend;
	level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ] vehicle_lights_on( "headlights" );
	thread enemy_jeep_group_fire();
	
	wait 3;
	
	//"Baker: Get us out of here!"
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_getusout" );
	//"Keegan: Heading under the bridge."
	level.allies[ 1 ] char_dialog_add_and_go( "clockwork_kgn_underbridge" );
	
	flag_wait( "exfil_bridge_spawn" );
	
	highway_jeep2 = spawn_vehicle_from_targetname_and_drive( "highway_jeep2" );
	waittillframeend;
	highway_jeep2 vehicle_lights_on( "headlights" );
	
	wait 0.25;
	level.enemy_jeep_b[ level.enemy_jeep_b.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_bridge1" );
	waittillframeend;
	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_bridge2" );
	waittillframeend;
	level.enemy_jeep_b[ level.enemy_jeep_b.size - 1 ] vehicle_lights_on( "headlights" );
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] vehicle_lights_on( "headlights" );
	thread enemy_jeep_group_fire();
	
	wait 0.25;
	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_bridge3" );
	waittillframeend;
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] vehicle_lights_on( "headlights" );
	
	//"Diaz: Vehicles coming from the right."
	thread radio_dialog_add_and_go( "clockwork_diz_vehiclesright" );
	
	wait 2.5;
	
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_choke1" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	waittillframeend;
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_choke2" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	waittillframeend;
	/*level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = thread spawn_enemy_bike_at_spawer( "enemy_jeep_choke3" );
	waittillframeend;
	level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ] vehicle_lights_on( "headlights" );
	*/	
	thread enemy_jeep_group_fire();
	
	// level.tankfire_spline_jeep speeds ahead. Kill him to prevent issues.
	if ( IsAlive( level.tankfire_spline_jeep ) )
	{
			level.tankfire_spline_jeep wipeout( "left behind!" );
	}
	
	wait .05;
	
	if ( IsAlive( prechokejeep2 ) )
	{
		health = prechokejeep2.maxhealth;
		prechokejeep2 DoDamage( health * 2, prechokejeep2.origin );
	}	
			
	wait .05;
	
	if ( IsAlive( prechokejeep1 ) )
	{
		health = prechokejeep1.maxhealth;
		prechokejeep1 DoDamage( health * 2, prechokejeep1.origin );
	}	
	
	wait 3;
	
	level.enemy_jeep_b[ level.enemy_jeep_b.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_straight1" );
	waittillframeend;
	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_straight2" );
	waittillframeend;
	level.enemy_jeep_b[ level.enemy_jeep_b.size - 1 ] vehicle_lights_on( "headlights" );
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] vehicle_lights_on( "headlights" );
	thread enemy_jeep_group_fire();
}

new_cliff_moment()
{
	flag_wait( "enemy_cave_spawn" );
		
	level.enemy_snowmobile = array_removeDead( level.enemy_snowmobile );
	foreach ( bike in level.enemy_snowmobile )
	{
		bike wipeout( "left behind!" );
	}
		
	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_cave1" );
	waittillframeend;
	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] vehicle_lights_on( "headlights" );
	thread enemy_jeep_group_fire();
		
	level.enemy_jeep_turret[ level.enemy_jeep_turret.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_cave2" );
	waittillframeend;
	level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ] vehicle_lights_on( "headlights" );
	
	wait 1;
	
	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_cave1" );
	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
	waittillframeend;
	thread enemy_jeep_group_fire();
	
	//"Diaz: Vehicles coming from the right."
	thread radio_dialog_add_and_go( "clockwork_diz_vehiclesright" );
	if( isalive( level.player ) ) 
		level.player LerpViewAngleClamp( 1.25, .5, .25, 45, 60, 30, 30 );
	wait 6;
	
	//level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit1" );
	//waittillframeend;
	level.endingjeep = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_collaspe1" );
	waittillframeend;
	//level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ] vehicle_lights_on( "headlights" );
	level.endingjeep vehicle_lights_on( "headlights" );
	thread enemy_jeep_group_fire();
	wait 1;
	
	//level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit2" );
	//waittillframeend;
	//level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit3" );
	//waittillframeend;
	//level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ]vehicle_lights_on( "headlights" );
	//level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ]vehicle_lights_on( "headlights" );
	waittillframeend;
	level.lastsnow1 = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_collaspe1" );
	waittillframeend;
	level.lastsnow2 = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_collaspe2" );
	if( isalive( level.player ) ) 
		level.player LerpViewAngleClamp( 1.25, .5, .25, 45, 45, 30, 30 );
	
	flag_wait_or_timeout( "kill_jeep_1", 6 );
	
	if( isalive( level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] ) 
	   && isalive( level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ].driver ) )
		level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ].driver kill();
	
	flag_wait_or_timeout( "kill_jeep_2", 3 );
	
	if( isalive( level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ] ) 
	   && isalive( level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ].driver ) )
	{
		thread dynamic_icehole_crash( level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ], 0 );
		level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ].driver kill();
	}
	
	flag_wait_or_timeout( "kill_jeep_3", 1.5 );
	
	if( isalive( level.endingjeep ) && isalive( level.endingjeep.driver ) )
	{
		flag_set( "kill_endingjeep" );
		wait .05;
		level.endingjeep.driver kill();
		thread dynamic_icehole_crash( level.endingjeep, 0 );
	}
}

#using_animtree( "vehicles" );
new_nxsub_breach_moment()
{
	subto	= getstruct( "submarine_origin_height", "targetname" );
	
	flag_wait( "exfil_exit_cave" );
	
	level.playerJeep.dontunloadonend = 1;
	
	wait 1;
	wait 1.05;
	
	// prevent the player from dieing at this point
	level.player EnableInvulnerability();
	
	//"Diaz: In position for exfil."
	thread radio_dialog_add_and_go( "clockwork_diz_inposition" );
	
	wait 1.5;
	
	// kill the timer
	thread killTimer();
	
	// rumble to hide small pop that occurs.
	thread play_rumble_seconds( "damage_heavy", .25 );
	thread screenshakeFade( .45, .5 );
	
	// ending rumbles for sub rise
	thread ending_screenshake();
		
	//Ice fx exploders
	thread play_fx_for_sub(  );
	thread play_fx_for_sub_front(	);
	thread play_fx_for_sub_back(  );
	thread play_fx_for_sub_largeice(  );
	thread play_fx_for_sub_blow(  );
	
	// spawn in sub and ice
	subice = spawn_anim_model( "cw_sub_ice", subto.origin );
	nxsub  = spawn_anim_model( "cw_sub_sub", subto.origin );
	
	// collision for the sub for fx
	sub_collision		 = GetEnt( "sub_collision", "targetname" );
	sub_collision.origin = nxsub GetTagOrigin( "j_sub_anim" );
	sub_collision.angles = nxsub GetTagAngles( "j_sub_anim" );
	sub_collision LinkTo( nxsub, "j_sub_anim" );

	level.allies[ 1 ].animname = "generic"; // Keegan
	level.playerJeep thread vehicle_play_guy_anim( "nxsubdriver", 		level.allies[ 1 ], 0 );
		
	level.allies[ 0 ].animname = "generic"; // Baker
	level.playerJeep thread vehicle_play_guy_anim( "nxsubpassenger", 	level.allies[ 0 ], 1 );
		
	level.allies[ 2 ].animname = "generic"; // Cypher
	level.playerJeep thread vehicle_play_guy_anim( "nxsubbackseat", 	level.allies[ 2 ], 2 );

	subto thread anim_single_solo( subice, "ice_breach" );
	
	level.subfx		   = spawn_anim_model( "nxsubfx", subto.origin );
	level.subfx.angles = subto.angles;
	level.subfx thread anim_single_solo( level.subfx, "subfxanim" );
		
	thread playfx_for_sub_slide();
	
	//"Neptune: Coming up now."
	thread surfacing_now_vo();
	
	subto thread anim_single_solo( nxsub, "sub_breach" );
	
	//thread end_now();
	
	wait 6.4;
	
	//*** START PLAYER/CAR ANIMS ***//
	// setup player arms
	level.jeep_player_arms_sub = spawn_anim_model( "player_rig", level.player.origin );
	level.jeep_player_arms_sub SetModel( "clk_watch_viewhands" );
	level.jeep_player_arms_sub Hide();
	subto thread anim_first_frame_solo( level.jeep_player_arms_sub, "nx_sub_alt" );

	// lerp player view
	level.player LerpViewAngleClamp( 1.25, .5, .25, 0, 0, 0, 0 );
	level.player DisableWeapons();
	level.player TakeAllWeapons();
	
	// notify that the mission is ending.
	level.missionend = 1;
	
	// stop hand anims for turret
	level.player notify( "missionend" );	
	
	// player dismount start
	turret = level.playerJeep.mgturret[ 0 ];
	
	// dismount from turret
	h = level.player GetPlayerViewHeight();
    o = level.player GetEye();
    turret SetTurretDismountOrg( level.jeep_player_arms_sub GetTagOrigin( "tag_player" ) + ( 16, 16, 0 ) );
	turret useby( level.player );

	// sync up anims
	level.playerJeep.animname = "cw_car_breach";
	subto thread anim_first_frame_solo( level.playerJeep, "player_car_alt" );
	level.player PlayerLinkToDelta( level.jeep_player_arms_sub, "tag_player", 1, 20, 20, 20, 0 );
	level.jeep_player_arms_sub Show();
	
	// start anims
	subto thread anim_single_solo( level.jeep_player_arms_sub, "nx_sub_alt" );
	subto thread anim_single_solo( level.playerJeep, "player_car_alt" );
	
	thread fire_tracers();
	
	wait 4;
	level.crashed_trucks show();
	level.crashed_truck1 show();
	level.crashed_truck2 show();
    thread start_jeep_fire(); // show fire fx on crashed trucks
	
	wait 4;
	level.player GiveWeapon( "ak47_silencer_reflex_iw6" );
	level.player EnableWeapons();
	//flag_wait( "exfil_player_land" ); //anim notify.
	//level waittill( "cut_on_end" ); //sound notify.
	
	//level.player PlayerLinkToDelta( level.jeep_player_arms_sub, "tag_player", 1, 180, 180, 45, 30 ); // leaves wierd tilt at second 14.
	
	// on the sub
	wait 1;
	level.jeep_player_arms_sub hide();
	level.player unlink();
	
	wait 6.25;
	maps\_hud_util::fade_out( .05, "black" ); //fast fade
	//maps\_hud_util::fade_out( 5, "black" ); //slow fade
	//"Baker: We need to be in the sub by 0-100 for debriefing."
	//level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_beinsub" );
	
	flag_set( "aud_fade_out" );
	wait 5;
	
	//flag_set( "exfil_finished" );
	
	nextmission();
}

//cliff_moment()
//{	
//	flag_wait( "enemy_cave_spawn" );
//		
//	level.enemy_snowmobile = array_removeDead( level.enemy_snowmobile );
//	foreach ( bike in level.enemy_snowmobile )
//	{
//		bike wipeout( "left behind!" );
//	}
//	
//	wait 1.2;
//	
//	level.enemy_jeep_a[ level.enemy_jeep_a.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_cave1" );
//	waittillframeend;
//	level.enemy_jeep_a[ level.enemy_jeep_a.size - 1 ] vehicle_lights_on( "headlights" );
//	thread enemy_jeep_group_fire();
//	
//	wait 0.7;
//	
//	level.enemy_jeep_turret[ level.enemy_jeep_turret.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_cave2" );
//	waittillframeend;
//	level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ] vehicle_lights_on( "headlights" );
//	
//	wait 2;
//	level.enemy_snowmobile[ level.enemy_snowmobile.size ] = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_cave1" );
//	level.enemy_snowmobile[ level.enemy_snowmobile.size -1 ] vehicle_lights_on( "headlights" );
//	waittillframeend;
//	thread enemy_jeep_group_fire();
//	
//	//"Cypher: Targets behind us!"
//	level.allies[ 2 ] thread char_dialog_add_and_go( "clockwork_cyr_targetsbehindus" );
//	
//	//level.altskybox show();
//}

//#using_animtree( "vehicles" );
//nxsub_breach_moment()
//{
//	subto	= getstruct( "submarine_origin_height", "targetname" );
//	
//	flag_wait( "exfil_exit_cave" );
//	
//	level.playerJeep.dontunloadonend = 1;
//	
//	level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit1" );
//	waittillframeend;
//	level.enemy_jeep_turret[ level.enemy_jeep_turret.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_collaspe1" );
//	waittillframeend;
//	level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ] vehicle_lights_on( "headlights" );
//	level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ] vehicle_lights_on( "headlights" );
//	
//	wait 1;
//	
//	level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit2" );
//	waittillframeend;
//	level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit3" );
//	waittillframeend;
//	level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ]vehicle_lights_on( "headlights" );
//	level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ]vehicle_lights_on( "headlights" );
//	thread enemy_jeep_group_fire();
//	waittillframeend;
//	level.lastsnow1 = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_collaspe1" );
//	waittillframeend;
//	level.lastsnow2 = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_collaspe2" );
//
//	wait 1.05;
//	
//	// setup player arms
//	level.jeep_player_arms_sub = spawn_anim_model( "player_rig", level.player.origin );
//	level.jeep_player_arms_sub SetModel( "clk_watch_viewhands_off" );
//	level.jeep_player_arms_sub Hide();
//	subto thread anim_first_frame_solo( level.jeep_player_arms_sub, "nx_sub_alt" );
//	
//	// prevent the player from dieing at this point
//	level.player EnableInvulnerability();
//	
//	// lerp player view
//	level.player LerpViewAngleClamp( 1.25, .5, .25, 0, 0, 0, 0 );
//	level.player DisableWeapons();
//	level.player TakeAllWeapons();
//	
//	//"Diaz: In position for exfil."
//	thread radio_dialog_add_and_go( "clockwork_diz_inposition" );
//	
//	// notify that the mission is ending.
//	level.missionend = 1;
//	wait 1.5;
//	
//	// stop hand anims for turret
//	level.player notify( "missionend" );	
//	
//	// kill the timer
//	thread killTimer();
//	
//	// rumble to hide small pop that occurs.
//	thread play_rumble_seconds( "damage_heavy", .25 );
//	thread screenshake( .45, .5 );
//	
//	// ending rumbles for sub rise
//	thread ending_screenshake();
//		
//	//Ice fx exploders
//	thread play_fx_for_sub(  );
//	thread play_fx_for_sub_front(	);
//	thread play_fx_for_sub_back(  );
//	thread play_fx_for_sub_largeice(  );
//	thread play_fx_for_sub_blow(  );
//		
//	// player dismount start
//	turret = level.playerJeep.mgturret[ 0 ];
//	
//	// dismount from turret
//	h = level.player GetPlayerViewHeight();
//    o = level.player GetEye();
//    turret SetTurretDismountOrg( level.jeep_player_arms_sub GetTagOrigin( "tag_player" ) + ( 16, 16, 0 ) );
//	turret useby( level.player );
//
//	// sync up anims
//	level.playerJeep.animname = "cw_car_breach";
//	subto thread anim_first_frame_solo( level.playerJeep, "player_car_alt" );
//	level.player PlayerLinkToDelta( level.jeep_player_arms_sub, "tag_player", 1, 20, 20, 20, 0 );
//	level.jeep_player_arms_sub Show();
//	
//	// start anims
//	subto thread anim_single_solo( level.jeep_player_arms_sub, "nx_sub_alt" );
//	
//	subto thread anim_single_solo( level.playerJeep, "player_car_alt" );
//	
//	// spawn in sub and ice
//	subice = spawn_anim_model( "cw_sub_ice", subto.origin );
//	nxsub  = spawn_anim_model( "cw_sub_sub", subto.origin );
//	
//	// collision for the sub for fx
//	sub_collision		 = GetEnt( "sub_collision", "targetname" );
//	sub_collision.origin = nxsub GetTagOrigin( "j_sub_anim" );
//	sub_collision.angles = nxsub GetTagAngles( "j_sub_anim" );
//	sub_collision LinkTo( nxsub, "j_sub_anim" );
//	
//	level.allies[ 1 ].animname = "generic"; // Keegan
//	level.playerJeep thread vehicle_play_guy_anim( "nxsubdriver", 		level.allies[ 1 ], 0 );
//		
//	level.allies[ 0 ].animname = "generic"; // Baker
//	level.playerJeep thread vehicle_play_guy_anim( "nxsubpassenger", 	level.allies[ 0 ], 1 );
//		
//	level.allies[ 2 ].animname = "generic"; // Cypher
//	level.playerJeep thread vehicle_play_guy_anim( "nxsubbackseat", 	level.allies[ 2 ], 2 );
//	
//	subto thread anim_single_solo( subice, "ice_breach" );
//	
//	level.subfx		   = spawn_anim_model( "nxsubfx", subto.origin );
//	level.subfx.angles = subto.angles;
//	level.subfx thread anim_single_solo( level.subfx, "subfxanim" );
//		
//	thread playfx_for_sub_slide();
//	
//	//"Neptune: Coming up now."
//	thread surfacing_now_vo();
//	
//	subto thread anim_single_solo( nxsub, "sub_breach" );
//	
//	//thread end_now();
//	
//	wait 6;
//	thread fire_tracers();
//	
//	wait 4;
//	level.crashed_trucks show();
//	level.crashed_truck1 show();
//	level.crashed_truck2 show();
//    thread start_jeep_fire(); // show fire fx on crashed trucks
//	
//	
//	wait 4;
//	level.player GiveWeapon( "ak47_silencer_reflex_iw6" );
//	level.player EnableWeapons();
//	//flag_wait( "exfil_player_land" ); //anim notify.
//	level waittill( "cut_on_end" ); //sound notify.
//	
//	//level.player PlayerLinkToDelta( level.jeep_player_arms_sub, "tag_player", 1, 180, 180, 45, 30 ); // leaves wierd tilt at second 14.
//	
//	// on the sub
//	level.jeep_player_arms_sub hide();
//	level.player unlink();
//	
//	wait 5;
//	
//	maps\_hud_util::fade_out( .05, "black" ); //fast fade
//	//maps\_hud_util::fade_out( 5, "black" ); //slow fade
//	//"Baker: We need to be in the sub by 0-100 for debriefing."
//	//level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_beinsub" );
//	
//	flag_set( "aud_fade_out" );
//	wait 5;
//	
//	//flag_set( "exfil_finished" );
//	
//	nextmission();
//}

surfacing_now_vo()
{
	wait(1);
	thread radio_dialog_add_and_go( "clockwork_npt_comingupnow" );	
}

fire_tracers()
{
	tracerstart = getstruct( "exfil_ending_tracer_start", "targetname" );
	
	BulletTracer( tracerstart.origin, level.player.origin + ( 32, 0, 64 ), 	true );
	wait .15;
	BulletTracer( tracerstart.origin, level.player.origin + ( 32, 16, 64 ), true );
	wait .25;
	BulletTracer( tracerstart.origin, level.player.origin + ( 16, 16, 64 ), true );

	wait 2;
	
	BulletTracer( tracerstart.origin, level.player.origin + ( 16, 0, 64 ), 	true );
	wait .15;
	BulletTracer( tracerstart.origin, level.player.origin + ( 32, 16, 64 ), true );
	wait .15;
	BulletTracer( tracerstart.origin, level.player.origin + ( 16, 0, 64 ), 	true );
}

//// test for quicker ending.
//end_now()
//{
//	level.player notifyOnPlayerCommand( "sudden_end", "+attack" );
//	
//	level.player waittill( "sudden_end" );
//	
//	maps\_hud_util::fade_out( .05, "black" );
//}
//
//lerp_player( anim_name )
//{
//	subto	= getstruct( "submarine_origin_height", "targetname" );
//	
//	level.jeep_player_arms_sub.angles = level.player.angles;
//	level.player PlayerLinkToDelta( level.jeep_player_arms_sub, "tag_player", 1, 20, 20, 20, 0 );
//	level.player LerpViewAngleClamp( 0.5, .25, .05, 20, 20, 20, 20 );
//	wait 0.5;
//	subto thread anim_first_frame_solo( level.jeep_player_arms_sub, anim_name );
//	level.jeep_player_arms_sub Show();
//}

/*
#using_animtree( "vehicles" );
sub_breach_moment()
{
	flag_wait( "exfil_exit_cave" );
	
	level.player PlayerLinkToDelta( level.playerJeep, "tag_guy_turret", 0.8, 360, 360, 30, 20, true );
	
	// spawn ice sooner so we can delete ice bsp
	subto	= getstruct( "submarine_origin_height", "targetname" );
	
	subice1a		= spawn_anim_model( "cw_new_ice_breach1a", subto.origin	 );
	subice1a.angles = subto.angles;
	subto thread anim_first_frame_solo( subice1a, "ice_breach" );
	subice1b		= spawn_anim_model( "cw_new_ice_breach1b", subto.origin );
	subice1b.angles = subto.angles;
	subto thread anim_first_frame_solo( subice1b, "ice_breach" );
	subice2a		= spawn_anim_model( "cw_new_ice_breach2a", subto.origin );
	subice2a.angles = subto.angles;
	subto thread anim_first_frame_solo( subice2a, "ice_breach" );
	subice2b		= spawn_anim_model( "cw_new_ice_breach2b", subto.origin );
	subice2b.angles = subto.angles;
	subto thread anim_first_frame_solo( subice2b, "ice_breach" );
	
	level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit1" );
	waittillframeend;
	level.enemy_jeep_turret[ level.enemy_jeep_turret.size ] = spawn_vehicle_from_targetname_and_drive( "enemy_jeep_collaspe1" );
	waittillframeend;
	level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ] vehicle_lights_on( "headlights" );
	level.enemy_jeep_turret[ level.enemy_jeep_turret.size - 1 ] vehicle_lights_on( "headlights" );
	
	wait 1;
	
	level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit2" );
	waittillframeend;
	level.enemy_jeep_s[ level.enemy_jeep_s.size ]		  = spawn_enemy_bike_at_spawer( "enemy_jeep_exit3" );
	waittillframeend;
	level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ]vehicle_lights_on( "headlights" );
	level.enemy_jeep_s[ level.enemy_jeep_s.size - 1 ]vehicle_lights_on( "headlights" );
	thread enemy_jeep_group_fire();
	
	wait 1;
	
	//"Diaz: In position for exfil."
	thread radio_dialog_add_and_go( "clockwork_diz_inposition" );
	
	level.lastsnow1 = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_collaspe1" );
	waittillframeend;
	level.lastsnow2 = thread spawn_enemy_bike_at_spawer( "enemy_snowmobile_collaspe2" );

	//thread ending_screenshake();

	//"Neptune: Coming up now."
	thread radio_dialog_add_and_go( "clockwork_npt_comingupnow" );
		
	level.player EnableInvulnerability();
	
	sub		   = spawn_anim_model( "cw_sub_breach", subto.origin );
	sub.angles = subto.angles;
	
	sub thread anim_single_solo( sub, "sub_breach" );
	level.subfx		   = spawn_anim_model( "subfx", subto.origin );
	level.subfx.angles = subto.angles;
	level.subfx thread anim_single_solo( level.subfx, "subfxanim" );
	
							   //   guy       anime 	   
	subto thread anim_single_solo( subice1a, "ice_breach" );
	subto thread anim_single_solo( subice1b, "ice_breach" );
	subto thread anim_single_solo( subice2a, "ice_breach" );
	subto thread anim_single_solo( subice2b, "ice_breach" );
	
	flag_wait( "exfil_player_sub_jump" );
	
	flag_set("hand_wait");
	//level.jeep_player_arms_sub = spawn_anim_model( "player_rig", level.playerjeep.origin);
	//level.jeep_player_arms_sub SetModel( "clk_watch_viewhands" );
	//level.jeep_player_arms_sub hide();
	//level.jeep_player_arms_sub LinkTo( level.playerjeep, "tag_guy_turret" );
	//level.player PlayerLinkToBlend( level.jeep_player_arms_sub, "tag_player", .01 );
	//level.jeep_player_arms_sub.angles = level.player.angles;
	//level.playerJeep thread anim_single_solo( level.jeep_player_arms_sub, "sub_jump", "tag_guy_turret" );
	//level.jeep_player_arms_sub thread anim_single_solo( level.jeep_player_arms_sub, "sub_jump" );
	level.playerJeep.mgturret[ 0 ] setanim( %clockwork_sub_breach_jump_player, 1, .1, 1.5 ); 
	
	sub_collision		 = getent( "sub_collision", "targetname" );
	sub_collision.origin = sub GetTagOrigin("body");
	sub_collision.angles = sub GetTagAngles("body");
	sub_collision linkto( sub, "body" );
	
	wait 1;
	
	flag_set("hand_wait");
	level.player PlayerLinkToDelta( level.playerJeep, "tag_guy_turret", 0.1, 360, 360, 30, 20, true );
	
	//Player jumps out
	flag_wait( "on_sub" );
	
	flag_set("hand_wait");
	level.playerJeep notify( "veh_jolt", (0, 1, 0) );
		
	wait 3;
	flag_set("hand_wait");
	
	thread maps\clockwork_audio::end_fade();
	maps\_hud_util::fade_out( 5, "black" );
	
	//"Baker: We need to be in the sub by 0-100 for debriefing."
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_beinsub" );
	
	flag_set("aud_fade_out");
	wait 1;
	
	//flag_set( "exfil_finished" );
	
	nextmission();
}
*/

// fx code

playfx_for_sub_slide()
{
	level endon( "on_sub" );
	flag_wait( "exfil_player_sub_jump" );
	
	while ( !flag( "on_sub" ) )
	{
		wait 1;
		PlayFXOnTag( getfx( "fx/treadfx/clk_jeep_skid_sub" ), level.playerJeep, "tag_wheel_front_left" );
		//PlayFXOnTag( getfx( "fx/treadfx/clk_jeep_skid_sub" ), level.playerJeep, "tag_wheel_front_right" );
		wait 0.5;
	}
	
	PlayFXOnTag( getfx( "fx/treadfx/clk_jeep_skid_sub" ), level.playerJeep, "tag_wheel_front_left" );
	//PlayFXOnTag( getfx( "fx/treadfx/clk_jeep_skid_sub" ), level.playerJeep, "tag_wheel_front_right" );
}

playfx_for_tread()
{	
	self.conttread = 1;
	self thread stop_tread();
	
	while ( IsAlive( self ) && self.conttread )
	{
		PlayFXOnTag( getfx( "fx/treadfx/tread_snow_speed_clk" ), self, "tag_wheel_back_left" );
		PlayFXOnTag( getfx( "fx/treadfx/tread_snow_speed_clk" ), self, "tag_wheel_back_right" );
		wait .1; // do not remove, doing so will cause blue bars
	}
}

stop_tread()
{	
	self waittill( "kill_tread" );

	if( IsAlive( self ) ) 
		self.conttread = 0;	
}

playfx_for_player_tread()
{	
	while ( 1 )
	{
		//PlayFXOnTag( getfx( "fx/treadfx/tread_snow_speed_clk" ), level.playerJeep, "tag_wheel_back_left" );
		//PlayFXOnTag( getfx( "fx/treadfx/tread_snow_speed_clk" ), level.playerJeep, "tag_wheel_back_right" );
		wait .25; // do not remove, doing so will cause blue bars
	}
}

play_fx_for_sub()
{
	wait 1;
	exploder ( 7005 );
	wait 0.1;
	exploder ( 7006 );	
	wait 0.4;
	exploder ( 7007 );
	wait 0.6;
	exploder ( 7008 );
	wait 0.1;
	exploder ( 7009 );
	wait 0.2;
	exploder ( 7010 );
	wait 0.3;
	exploder ( 7011 );
	wait 0.2;
	exploder ( 7100 );
	wait 0.1;
	exploder ( 7102 );
	wait 0.1;
	exploder ( 7103 );
	
}

play_fx_for_sub_front()
{
	wait 3.2;
	exploder ( 9000 );
	wait 0.1;
	exploder ( 9004 );	
	wait 0.2;
	exploder ( 9001 );
	wait 0.1;
	exploder ( 9002 );
	wait 0.2;
	exploder ( 9003 );
	wait 0.1;
	exploder ( 9005 );
	wait 0.2;
	exploder ( 9006 );
}

play_fx_for_sub_back()
{
	wait 3.4;
	exploder ( 9007 );
	wait 0.1;
	exploder ( 9010 );	
	wait 0.2;
	exploder ( 9009 );
	wait 0.1;
	exploder ( 9008 );
	wait 0.2;
	exploder ( 9011 );
	wait 0.1;
	exploder ( 9012 );
	wait 0.2;
	exploder ( 9013 );
}

play_fx_for_sub_largeice()
{
	wait 6;
	exploder ( 9200 );
	wait 0.1;
	exploder ( 9201 );	
	wait 0.2;
	exploder ( 9202 );
}

play_fx_for_sub_blow()
{
	wait 7;
	exploder ( 9300 );
}

//play_sub_fx_hull( sub )
//{
//		
//	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_water_roll" ], level.subfx, "J_sub_front_1" );
//	wait 0.05;
//	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_water_roll" ], level.subfx, "J_sub_front_2" );
//	wait 0.05;
//	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_water_roll" ], level.subfx, "J_sub_rear_1" );
//	wait 0.05;
//	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_water_roll" ], level.subfx, "J_sub_rear_2" );
//	wait 0.05;
//	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_water_roll" ], level.subfx, "J_sub_rear_3" );
//	wait 0.05;
//	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_water_roll" ], level.subfx, "J_sub_side" );
//	wait 0.05;
//	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_water_roll" ], level.subfx, "J_sub_side" );
//
//	
//}

play_sub_fx_icerise(sub)
{
		
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk01" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk02" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk03" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk04" );
	wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk05" );
	wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk06" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk07" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk08" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/misc/clk_sub_rise" ], level.subfx, "fx_ice_chunk09" );

	
}

play_sub_fx_settle(sub)
{
		
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk01" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk02" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk03" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk04" );
	wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk05" );
	wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk06" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk07" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk08" );
	//wait 0.05;
	PlayFXOnTag( level._effect[ "fx/weather/snow_sub_blow" ], level.subfx, "fx_ice_chunk09" );

	
}

//play_sub_fx_jeep( sub )
//{
//	
//	PlayFXOnTag( level._effect[ "fx/treadfx/clk_jeep_skid_sub" ], level.subfx, "J_chunk_front_1" );
//	
//	
//}

start_jeep_fire()
{
	
	createfx_origin = ( 34331.6, 21599.2, 244);
	createfx_angles = (  270.001, 359.436, 17.5646);
	fx_up = anglestoup(createfx_angles);
	fx_fwd = anglestoforward(createfx_angles);
	fx0 = spawnFx( level._effect["fx/fire/fire_gaz_clk"],createfx_origin , fx_fwd, fx_up );
	triggerFx( fx0, -20);
	
	
    createfx_origin = ( 33577.5, 21155.1, 223);
	createfx_angles = (  270.001, 359.501, 56.4988);
	fx_up = anglestoup(createfx_angles);
	fx_fwd = anglestoforward(createfx_angles);
	fx0 = spawnFx( level._effect["fx/fire/fire_gaz_clk"],createfx_origin , fx_fwd, fx_up );
	triggerFx( fx0, -20);
}

// support code

ending_screenshake()
{
	wait 1;
	
	thread play_rumbles();
}

play_rumbles()
{
					 //   damage_name     seconds   
	play_rumble_seconds( "drill_normal", 5.5 );
	play_rumble_seconds( "damage_heavy", .25 );  
	play_rumble_seconds( "drill_normal", .35 );	
	play_rumble_seconds( "damage_heavy", .75 );
	play_rumble_seconds( "drill_normal", 1.25 );
	play_rumble_seconds( "damage_heavy", .65 );
}

//spawn_jeep_allies()
//{
//	level.passplayer[ 0 ]					  = level.allies[ 0 ]; //baker
//	level.allies[ 0 ].script_startingposition = 0;
//	level.passplayer[ 1 ]					  = level.allies[ 1 ]; //keegan
//	level.allies[ 1 ].script_startingposition = 1;
//	level.passplayer[ 2 ]					  = level.allies[ 2 ]; //cipher
//	level.allies[ 2 ].script_startingposition = 2;
//}
//
//aimlight( light, ltarget )
//{
//	self endon( "death" );
//	
//	while ( 1 )
//	{
//		light.angles   = VectorToAngles( ( ltarget.origin + ( 256, -256, 32 ) ) - light.origin ); // Light away from your face
//		//light.angles = VectorToAngles( ( ltarget.origin + ( 0, 0, 32 ) ) - light.origin ); // Light in your face
//		light LinkTo( level.tank_bridge, "tag_turret" ); //, ( 0, 0, 32 ), ( 0, 0, 0 ) );
//		wait 0.01;
//	}
//}

fire_fail_exfil_vo()
{
	flag_wait( "exfil_fire_fail" );
	
	SetSavedDvar( "aim_aimAssistRangeScale", "3" );
	SetSavedDvar( "aim_autoAimRangeScale"  , "3" );
	
				//   entities      process 
	array_thread( level.allies, ::fast_walk, false );
	
	// reset player for comabt
	thread blend_movespeedscale_custom( 100, 1 );
	flag_set( "player_DMS_allow_sprint" );
	level.player EnableOffhandWeapons();
	
	foreach ( ally in level.allies )
	{
		ally.ignoreall = false;	
		ally set_baseaccuracy( 10 );
		ally.ignoresuppression			 = true;
		ally.suppressionwait			 = 0;
		ally.disableBulletWhizbyReaction = true;
		ally.ignorerandombulletdamage	 = true;
		ally thread disable_pain();
	}
	
	if ( !flag( "start_exfil_ride" ) )
	{
		//"Baker: Get to the Jeep!"
		level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_gettojeep" );
		//"Baker: Go! Go! Go!"
		level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_gogogo" );
	}
	
	flag_wait( "start_exfil_ride" );
	level.playerJeep ent_flag_wait( "loaded" );
		
	flag_clear( "punchit_exfil_hot" );
	flag_set( "punchit_go" );
	
	if ( !flag( "exfil_door_close_start" ) )
	{
		//"Baker: Punch it!"
		level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_punchit" );
		flag_set( "chase_punch_it" );
		
		level.playerJeep Vehicle_SetSpeed( 40, 10 );
		level.startjeep Vehicle_SetSpeed( 40, 10 );
	}
	
	flag_wait( "exfil_door_close_start" );
	
	level.playerJeep Vehicle_SetSpeed( 30, 10 );
	
	flag_wait( "ally_start_path_exfil" );
	
	level.playerJeep ResumeSpeed( 30 );
}

stop_ads_moment()
{
	while ( !flag( "chaos_meetup_follow_spawn" ) && !flag( "exfil_fire_fail" ) )
	{
		level.player AllowFire( false );
		if ( level.player PlayerAds() > 0.3 )
		{
			level.player AllowFire( false );
			level.player AllowAds( false );
			
			//Merrick: Weapons down!
			level.allies[ 0 ] char_dialog_add_and_go( "clockwork_mrk_weaponsdown" );
			level.player AllowAds( true );
			
			return;
		}
		wait 0.05;
	}
}

exfil_alert_handle()
{
	level endon( "ally_start_path_exfil" );
	
	flag_wait( "elevator_open" );
	
	self set_allowdeath( true );
	self.alertlevel = "noncombat";
	
	if ( !IsDefined( self.script_drone ) ) //skip this if drone
	{
		if ( flag( "exfil_fire_fail" ) )
		{
		   	self StopAnimScripted();
			self.ignoreall = false;
			self.ignoreme  = false;
		   	return;
		}
		
		self thread wakeup_drone_kill();
			
		self AddAIEventListener( "grenade danger" );
		self AddAIEventListener( "projectile_impact" );
		self AddAIEventListener( "silenced_shot" );
		self AddAIEventListener( "bulletwhizby" );
		self AddAIEventListener( "gunshot" );
		self AddAIEventListener( "explode" );
		self AddAIEventListener( "death" );
	    
	    self waittill( "ai_event", eventtype );
	    
	    if ( IsDefined( self ) )
	    {
	    	if ( IsDefined( self.vehicle_position ) && self.vehicle_position == 0 ) // never wakup a driver
			{
	    		//IPrintLnBold( "DRIVER" );
	    	}
	    	else
	    	{
	    		self StopAnimScripted();
				self.ignoreall = false;
				self.ignoreme  = false;
				self fast_walk( false );
	    	}
	    }
		flag_set( "exfil_fire_fail" );
	}
	else
	{
		if ( flag( "exfil_fire_fail" ) )
			if ( IsDefined( self ) && IsAlive( self ) )
				self Kill();
		
		self thread kill_drone();
		
		self waittill( "death" );
	    
		if ( IsDefined( self ) )
			flag_set( "exfil_fire_fail" );
	}
}

wakeup_drone_kill()
{
	self endon( "Death" );
	
	flag_wait( "exfil_fire_fail" );
	
	if ( IsDefined( self ) )
	{
	    self StopAnimScripted();
		self.ignoreall = false;
		self.ignoreme  = false;
    }
}

kill_drone()
{
	self endon( "Death" );
	
	flag_wait( "exfil_fire_fail" );
	
	if ( IsDefined( self ) && IsAlive( self ) )
	{
		self Kill();
	}
}

kill_player()
{	
	while ( 1 )
	{
		if ( !IsAlive( level.playerJeep ) )
		{
			level.player Kill();
		}
		wait 0.01;
	}
}

enemy_zodiacs_spawn_and_attack()
{	
	//if( flag( "enemy_zodiacs_wipe_out" ) )
	//	return;
	level endon( "enemy_zodiacs_wipe_out" );
	
	level.player.progress = 0;
	wait_time			  = 3;
	wait( 2 );
	for ( ;; )
	{
		level.player.progress += 450;
		thread spawn_enemy_bike();
		wait( wait_time );
		wait_time -= 0.5;
		if ( wait_time < 0.5 )
			wait_time = 0.5;
		//wait( randomfloatrange( 2, 3 ) );		
	}
}

//enemy_snowmobile_accuracy()
//{
//	foreach ( snowmobile in level.enemy_snowmobile )
//	{
//		if ( IsAlive( snowmobile ) )
//		{
//			snowmobile.attachedguys[ 1 ].baseaccuracy = 0.1;
//		}
//	}
//}

enemy_jeep_group_fire()
{	
	wait 0.25;
	foreach ( jeep in level.enemy_jeep_turret )
	{
		if ( isdefined( jeep ) && IsAlive( jeep ) && IsDefined( jeep.mgturret ) ) // SJP: added check for mgturret as it was SREing
		{
			foreach ( turret in jeep.mgturret )
			{
				if( IsAlive( jeep ) && IsDefined( turret ) )
				{
					turret SetAISpread( 20 );
					turret SetConvergenceTime( 3 );
					turret.accuracy = 0.1;
				}
			}
			jeep.spline = 0;
			//jeep godon();	
			thread driver_dies( jeep );
			jeep thread start_ice_effects();
			jeep thread vehicle_death_check();
			jeep thread playfx_for_tread();
		}
	}		
	foreach ( jeep in level.enemy_jeep_a )
	{
		if ( IsAlive( jeep ) )
		{
			jeep.spline = 0;
			jeep thread jeeps_fire();
			jeep.health = 200000;
			jeep thread crash_vehicle_on_death();	
			thread driver_dies( jeep );
			jeep thread start_ice_effects();
			jeep thread vehicle_death_check();
			jeep thread playfx_for_tread();
		}
	}	
	foreach ( jeep in level.enemy_jeep_b )
	{
		if ( IsAlive( jeep ) )
		{
			jeep.spline = 0;
			jeep thread jeeps_fire();
			jeep.health = 200000;
			jeep thread crash_vehicle_on_death();
			thread driver_dies( jeep );	
			jeep thread start_ice_effects();
			jeep thread vehicle_death_check();
			jeep thread playfx_for_tread();			
		}
	}	
	foreach ( jeep in level.enemy_jeep_s )
	{
		if ( IsAlive( jeep ) )
		{
			jeep.spline = 1;
			jeep thread jeeps_fire();
			//jeep.health = 2000000;
			//jeep thread crash_vehicle_on_death();
			thread driver_dies( jeep );
			jeep thread start_ice_effects();
			jeep thread vehicle_death_check();	
			jeep thread playfx_for_tread();
		}
	}
}

jeeps_fire()
{
	foreach ( rider in self.riders )
	{
		rider thread jeep_ai( self );
	}
}

jeep_ai( boat )
{
	// kill _vehicle_anim stuff. not completely just gets them out of idle loop
	if ( !IsAI( self ) || self == boat.attachedguys[ 0 ] )
		return;
	self notify( "newanim" );
	self anim_stopanimscripted();

	//make them attack
	if ( self == level.allies[ 0 ]  || self == level.allies[ 1 ] )
	{
		self.desired_anim_pose = "crouch";
		self AllowedStances( "crouch" );
		//self thread animscripts\utility::UpdateAnimPose();
		//self AllowedStances( "crouch" );
	}
	else
	{
		self.desired_anim_pose = "crouch";
		self AllowedStances( "crouch", "stand" );
		//self thread animscripts\utility::UpdateAnimPose();
		//self AllowedStances( "crouch", "stand" );
	}

	self.baseaccuracy		   = 0.1;
	self.accuracystationarymod = 1;
}

// Play crash anim on vehicle death if on ice.
crash_vehicle_on_death()
{
	self endon( "icehole_occured" );
	//self waittill( "death", attacker, cause, weapon );
	
	self waittill( "damage", amount, attacker );
	
	//crash_origin = drop_to_ground( self.origin );
	if( IsDefined( self ) && IsAlive( self ) )
	{
		crash_origin_z = self.origin[ 2 ];
	
		if( !flag( "start_icehole_shooting" ) )
			self play_crash_anim( self.origin );
		else
		{
			rand = RandomIntRange( 1, 3 );
			if( rand == 1 && !level.justplayed ) // check to see if long crash should be played
			{
				self play_long_crash();
				level.justplayed = 1;
			}
			else
			{
				self play_crash_anim( self.origin );
				level.justplayed = 0;
			}
		}
	}
}

vehicle_death_check()
{
	self waittill( "death" );	
	
	// play sound for death here.
}

wipeout_bikes()
{
	level.enemy_snowmobile = array_removeDead( level.enemy_snowmobile );
	if ( level.enemy_snowmobile.size > 3 )
	{
		for ( i = 0; i < ( level.enemy_snowmobile.size - 3 ); i++ )
		{
			level.enemy_snowmobile[ i ] wipeout( "left behind!" );
		}
	}
}

vehicle_play_guy_anim(anime, guy, pos, playIdle)
{	 
    animpos = anim_pos( self, pos );
    animation = guy getanim(anime);
    
    guy notify ("newanim");
    guy endon( "newanim" );
    guy endon( "death" );
    
	//self animontag(guy, animpos.sittag, animation );
	self anim_single_solo(guy, anime, animpos.sittag);
	
	if(!IsDefined(playIdle) || playIdle == true)
	{
		self guy_idle(guy, pos); 	
	}
}

//exfil_vehicle_play_guy_anim( anime, guy, pos, PlayIdle )
//{	
//	animpos	  = maps\_vehicle_aianim::anim_pos( level.playerJeep, pos );
//	animation = guy getanim( anime );
//    
//    guy notify ( "newanim" );
//	guy endon( "newanim" );
//	guy endon( "death" );
//    
//	//self animontag(guy, animpos.sittag, animation );
//	self anim_single_solo( guy, anime, animpos.sittag );
//	
//	if ( !IsDefined( PlayIdle ) || PlayIdle == true )
//	{
//		self guy_idle(guy, pos); 	
//	}
//}

anim_enter_finished( flag_to_set )
{
	self waittillmatch("single anim","end");
	level.playerJeep thread maps\_vehicle_aianim::guy_enter( self );
	flag_set( flag_to_set );
}
