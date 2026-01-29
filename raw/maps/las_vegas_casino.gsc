#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\las_vegas_code;
#include maps\_hud_util;

#using_animtree( "generic_human" );

CASINO_HALLWAY_CHANDELIER_MIN = 5;
CASINO_HALLWAY_CHANDELIER_MAX = 7;

casino_spawn_functions()
{

	// Gambling Room
	array_spawn_function_noteworthy( "casino_right_tomb_dudes", ::casino_floor_tomb_dudes, "casino_floor_rtomb_trig" );
	array_spawn_function_noteworthy( "kitchen_walker_flashlight_dude", ::kitchen_flashlight_guy_flashlight );
	array_spawn_function_noteworthy( "kitchen_walker_flashlight_dude", ::set_moveplaybackrate, 1.2 );
	//array_spawn_function_noteworthy( "casino_hallway_walkers", ::casino_hallway_walkers );
	array_spawn_function_targetname( "casino_gamblingroom_inital_guys", ::casino_floor_reinforcements, "casino_floor_moveup01", "front" );
	array_spawn_function_targetname( "casino_top_floor_second_spawners", ::casino_floor_reinforcements, "casino_floor_enemies_retreat" );
	array_spawn_function_targetname( "casino_gamblingroom_gate_dudes", ::casino_floor_gate_dudes );
	array_spawn_function_targetname( "casino_gamblingroom_gate_dudes_2", ::casino_floor_gate_dudes );
	//array_spawn_function_targetname( "casino_floor_rappeler_runners", ::waittill_goal, true );
	
	// hotel
	
//	spawner = getent( "casino_hotel_vending_pusher", "script_noteworthy" );
//	spawner add_spawn_function( ::casino_hotel_vendingmachine_knockdown );
	
	thread casino_start_stuff();
	//thread casino_gamblingroom_sandstorm();
}

casino_threatbias_groups()
{
	CreateThreatBiasGroup( "drones_stealth" );
	ignoreEachOther( "heroes", "drones_stealth" ); 
	setthreatbias( "heroes", "drones_stealth" , 0 );
}

casino_start_stuff()
{
	startPoint = level.start_point;
	if( startPoint == "bar" || startPoint == "hotel" || startPoint == "interrogation" ||
	   startPoint == "hallway" || startPoint == "hallway" || startPoint == "raid" || startpoint == "jumpout" || startpoint == "jumpout2" )
	{
		thread casino_interior_sandstorm();
		
		battlechatter_off( "allies" );
		battlechatter_off( "axis" );	
	}
	
	thread casino_er_bird_event();
	//thread player_slide_birds();
	
	ai  = getent( "casino_kitchen_cart_tester", "targetname" ) spawn_ai( true );
	ai hide();
	ai.animname = "ninja";
	spot = getstruct( "casino_keegan_bar_enter_spot", "targetname" );
	doors = getentarray( "casino_bar_doors01", "targetname" );
	ldoor = undefined;
	foreach( door in doors )
	{
		if( door.script_noteworthy == "left" )
			ldoor = door;
	}
	ldoor linkto( ai, "tag_inhand", ( 0,12,-2 ), ( 0,-90,0 ) );
	spot thread anim_single_solo( ai, "humanshield_checkdoor" );
	flag_wait( "TRACKFLAG_bar_event_attach_door" );
	ldoor unlink();
	ai delete();
	flag_clear( "TRACKFLAG_bar_event_attach_door" );
	
	startPoint = level.start_point;
	if( startPoint != "hallway"  )
		doors_open( "casino_hallway_door01", .05, "none" );
	else if( startPoint != "interrogation" || startPoint != "bar" )
	{
		level.ninja.radio = spawn( "script_origin", level.ninja.origin );
		level.ninja.radio setmodel( "com_hand_radio" );
		level.ninja.radio linkto( level.ninja, "j_hiptwist_ri", ( 0,-2,-5 ), ( 0,180,270 ) );	
	}
	
}

//---------------------------------------------------------
// Starts
//---------------------------------------------------------
start_casino_interrogation_sequence()
{
	thread set_vision_set( "lv_restaurant", .05 );
}

start_casino_bar()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	set_start_locations( "interrogation_startspots2" );
	thread set_vision_set( "lv_restaurant", .05 );
	music_play( "mus_vegas_bar_intro" );
	level.fadein thread fade_over_time( 0, 1.5 );
}

start_casino_kitchen()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	set_start_locations( "kitchen_startspots" );
	thread set_vision_set( "lv_restaurant", .05 );
	
	level.ninja.radio = spawn( "script_model", level.ninja.origin );
	level.ninja.radio setmodel( "com_hand_radio" );
	level.ninja.radio linkto( level.ninja, "tag_stowed_hip_rear", ( 0,0,0 ), ( 0,0,0 ) );
	
	thread maps\las_vegas_player_hurt::enable_player_hurt( 40 );
	level.wounded_ai maps\las_vegas_code::enable_wounded_ai();
	
	level.fadein thread fade_over_time( 0, 1.5 );
}

ADRENALINE_PLAYER_SPEED = 70;
start_casino_hallway()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
//	waitframe();
	
	set_start_locations( "casino_hallway_startspots" );
	
	level.wounded_ai set_run_anim( "wounded_run_diaz" );
	
	level.ninja enable_cqbwalk();
	level.leader enable_cqbwalk();
//	level.wounded_ai enable_cqbwalk();
	level.player player_speed_percent( ADRENALINE_PLAYER_SPEED );
	
	level.fadein thread fade_over_time( 0, 2 );	
	
	level.player giveweapon( "kriss+acogsmg_sp" );
	level.player SwitchToWeapon( "kriss+acogsmg_sp" );
//	waitframe();
}

start_casino_floor_sequence()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	set_start_locations( "casino_floor_startspots" );
	array_thread( level.heroes, ::move_to_node, "casino_atrium04" );
	
	level.ninja.ignoreall = true;
	level.wounded_ai.ignoreall = true;
	level.leader.ignoreall = true;
	
	level.player thread player_speed_percent( ADRENALINE_PLAYER_SPEED, .05 );
	
	gates = getentarray( "casino_atrium_exit_door", "targetname" );
	foreach( gate in gates )
	{
		handle = getent( gate.target, "targetname" );
		handle linkto( gate );
	}

	level.player giveweapon( "kriss+acogsmg_sp" );
	level.player SwitchToWeapon( "kriss+acogsmg_sp" );
	
	thread doors_open( gates, .05, "none" );
	
	level.wounded_ai set_run_anim( "wounded_run_diaz", true );
	
	level.fadein thread fade_over_time( 0, 2 );
}

start_casino_hotel_sequence()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	set_start_locations( "casino_hotel_startspots" );
	
	gate = getent( "casino_floor_gate", "targetname" );
	gate moveto( gate.origin + ( 0,0,50 ), .05 );
	gate connectpaths();
	
	level.player player_speed_percent( 75, .05 );
	level.player allowsprint( false );
	//level.wounded_ai maps\las_vegas_code::enable_wounded_ai( "jog" );
	//level.ninja enable_cqbwalk();
	
	array_thread( level.heroes, ::move_to_node, "casino_escalator01" );
	
	level.fadein thread fade_over_time( 0, 2 );
}

start_casino_raid_sequence()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	set_start_locations( "casino_raid2_startspots" );
	
	level.player player_speed_percent( 75, .05 );			
	level.fadein thread fade_over_time( 0, 1 );
}

start_casino_jumpout_sequence()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	thread set_vision_set( "lv_casino_atrium", .05 );
//	cinematicmode_on();
//	level.player freezecontrols( true );
//	level.player thread play_sound_on_entity( "vegas_bkr_theyretryingtocut" );
	set_start_locations( "casino_raid2_startspots" );
	
	level.baker_glight = spawn( "script_model", level.player.origin + ( 0, 0, 15 ) );
	level.baker_glight setmodel( "tag_origin" );
	level.baker_glight.animname = "leader";
	level.baker_glight linkto( level.player );
//	cinematicmode_off();
//	level.player freezecontrols( false );
	level.player player_speed_percent( 75, .05 );	
	level.fadein thread fade_over_time( 0, 1 );
}

start_casino_slide_sequence()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	level.fadein delaythread( .8, ::fade_over_time, 0, 1 );
}

// o/c
//---------------------------------------------------------
// Casino Interrogation
//---------------------------------------------------------

casino_interrogation_sequence()
{
	level.fadein = create_client_overlay( "black", 1, level.player );
	waitframe();
	
	set_start_locations( "interrogation_startspots2" );
	
	music_play( "mus_vegas_bar_intro" );

	foreach( ai in level.heroes )
	{
		ai.realname = ai.name;
		ai.name = "";		
	}
	
	thread maps\las_vegas_casino_vo::casino_interrogation_dialog();
	level.player freezecontrols( true );
	wait(4);
	level.player freezecontrols( false );
	level.fadein thread fade_over_time( 0, 2 );
}

//---------------------------------------------------------
// Casino Bar
//---------------------------------------------------------

casino_bar()
{
	autosave_by_name( "bar" );
	
	thread bar_player_setup();
	//thread bar_hang_upside_down();
	thread bar_player_stumbles();
	thread maps\las_vegas_casino_vo::casino_bar_dialog();
	
	//level.player player_speed_percent( 80, 10 );	
	//level.player maps\_player_limp::enable_limp( 30 );
	level.player SetWeaponAmmoStock( "p99", 0 );
	level.player SetWeaponAmmoClip( "p99", 0 );
	thread maps\las_vegas_player_hurt::enable_player_hurt( 40 );
	level.wounded_ai maps\las_vegas_code::enable_wounded_ai();
	
	level.ninja enable_cqbwalk();
	level.ninja pushplayer( true );
	level.ninja set_baseaccuracy( 1000 );
	level.ninja pathrandompercent_zero();
	//level.leader set_run_anim( "wounded_walk_baker" );
	level.leader enable_cqbwalk();
	array_thread( level.heroes, ::set_ignoreall, true );
	array_thread( level.heroes, ::move_to_node, "casino_bar01" );
	
	bSpot = getstruct( "casino_keegan_bar_enter_spot", "targetname" );
	foreach( ai in level.heroes )
		ai thread casino_bar_human_shield_scene( bSpot );
	
	trigger_waittill_trigger( "casino_bar_trig01" );
	
	//wait( randomintrange( .5, 1 ) );
	
	level.player EnableInvulnerability();
	//level.player FadeOutShellShock();
	
	bar_enemies = [];
	spawner = getent( "casino_bar_idler", "targetname" );
	dude = spawner spawn_ai();
	bar_enemies[ bar_enemies.size ] = dude;

	node = getnode( spawner.script_linkto, "script_linkname" );
	goal = getnode( spawner.target, "targetname" );
	
	//dude thread casino_bar_jumper();
	dude thread idle_and_react( node, spawner.animation, "none", goal );
	dude thread casino_bar_humanshield_deaths();
	
	thread casino_bar_radio_scene();
	
	flag_wait( "FLAG_humanshield_leader_inposition" );
	flag_set( "FLAG_start_human_shield_scene" );
	
	spawners = getentarray( "casino_bar_walkers", "targetname" );
	foreach( spawner in spawners )
	{
		ai = spawner spawn_ai();
		bar_enemies[ bar_enemies.size ] = ai;
		ai thread casino_bar_walkers( spawner );
	}
	
	level waittill( "start_human_shield_walkers" );
	flag_wait( "DEATHFLAG_bar_enemies_dead" );

	level.player DisableInvulnerability();
	
	foreach( ai in level.heroes )
		ai pushplayer( true );
	
	foreach( ai in level.heroes )
	{
		if( ai != level.wounded_ai )
		{	
			ai disable_cqbwalk();
			ai enable_creepwalk();
		}
	}
	
	flag_wait( "FLAG_bar_humanshield_done" );
	//flag_wait_or_timeout( "TRIGFLAG_player_inside_bar_room2", 1.5 );
	wait( 3 );
	
	level.leader thread move_to_node( "casino_bar03" );
	level.leader enable_readystand();
	//level.leader set_idle_anim( "readystand_idle" );
	//level.leader orientmode( "face angle", 345 );
	
	level.leader.ignoreall = true;
	level.leader.ignoreme = true;
	
	level add_wait( ::flag_wait, "FLAG_grab_radio_done" );
	level.wounded_ai add_wait( ::waittill_msg, "wounded_ai_atgoal" );
	do_wait();
	
	flag_wait( "FLAG_casino_start_kitchen" );
	
	//level.leader thread move_to_node( "casino_bar04" );
	
}

bar_hang_upside_down()
{
	hang_spot = getent( "rope_player_spot", "targetname" );
	rope_top = spawn_anim_model( "player_rig", hang_spot.origin );
//	rope_top setmodel( "tag_player" );
	level.player PlayerLinkToBlend( rope_top, "tag_player", 0.1 );
	level.player playerlinkToDelta( rope_top, "tag_player", 1, 30, 30, 30, 30, true );
}

bar_player_stumbles()
{
	cinematicmode_on();
	
	spot = getstruct( "bar_player_stumble01", "targetname" );
	
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	arc = 15;
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
	spot thread anim_single_solo( player_rig, "vegas_player_intro_stumble" );
	
	level.player allowsprint( false );
	
	level waittill( "intro_stumble_pullout_gun" );
	cinematicmode_off();
	spot waittill( "vegas_player_intro_stumble" );
	player_rig delete();
	
	//level endon( "player_moving_through_bar" );
	
	trigger_waittill_trigger( "bar_player_stumble01_trig" );
	
//	pangles = anglestoforward( level.player.angles );
//	while( 1 )
//	{
//		pangles = anglestoforward( level.player.angles );
//		iprintln( pangles );
//		wait( 1 ) ;
//	}
//	
//	if( ( ( pangles[0] >= .2 && pangles[0] < 0 ) && ( pangles[1] >= .9 && pangles[1] < 1 ) ) )
//	   return;
//	else if( ( pangles[0] >= .9 && pangles[0] < 1 ) && ( pangles[1] >= .2 && pangles[1] < 0 ) )
//		return;
	
	spot = getstruct( "bar_player_stumble02", "targetname" );
	
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	player_rig hide();
	spot anim_first_frame_solo( player_rig, "vegas_player_intro_trip_chair" );
	arc = 0;
	player_rig lerp_player_view_to_tag( level.player, "tag_player", .5, 1, arc, arc, arc, arc );
	
	cinematicmode_on();
	
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
	player_rig show();
	
	spot thread anim_single_solo( player_rig, "vegas_player_intro_trip_chair" );
	level waittill( "chair_trip_pullout_gun" );
	cinematicmode_off();
	spot waittill( "vegas_player_intro_trip_chair" );
	player_rig delete();
	
}

casino_bar_human_shield_scene( bSpot )
{
	
	if( self == level.ninja )
	{
		trigger = getent( "bar_diaz_trig", "targetname" );
		while(1)
		{
			trigger waittill( "trigger", ai );
			if( ai == level.wounded_ai )
				break;
		}
		
		//trigger_waittill_trigger( "bar_diaz_trig", undefined, undefined, level.player );
		flag_wait( "TRIGFLAG_bar_keegan_start_move" );
		
		spot = getstruct( "keegan_bar_rightside_spot", "targetname" );
		level.ninja.oldgoalradius = level.ninja.goalradius;
		level.ninja.goalradius = 56;
		level.ninja setgoalpos( spot.origin );
		level.ninja waittill( "goal" );
		level.ninja.goalradius = level.ninja.oldgoalradius;
		
		level.ninja thread move_to_node( "casino_bar02" );
		
		flag_wait_all( "FLAG_diaz_stepdown_for_humanshield", "TRIGFLAG_player_moving_through_bar" );
		
		aspot = getstruct( bSpot.target, "targetname" );
		
		level.ninja disable_arrivals_and_exits( true );
		
		aspot anim_reach_solo( level.ninja, "humanshield_doorstack" );
		aspot anim_single_solo( level.ninja, "humanshield_doorstack" );
		aspot = undefined;
		bSpot_idle = spawnstruct();
		bSpot_idle.origin = level.ninja.origin;
		bSpot_idle.angles = level.ninja.angles;
		bSpot_idle thread anim_loop_solo( level.ninja, "humanshield_doorstack_idle", "stop_anim" );
		
		flag_wait( "FLAG_start_human_shield_scene" );
		
		spawners = getentarray( "casino_bar_talkers", "targetname" );
		talkers = [];
		breach_ai = [];
		level.headshot_spot = undefined;
		foreach( spawner in spawners )
		{
			ai = spawner spawn_ai();
		
			if( isdefined( spawner.script_noteworthy ) )
			{
				talkers[ "shield" ] = ai;
				ai.animname = "hostage";
				level.hostage = ai;
			}
			else
			{
				talkers[ "other" ] = ai;
				ai.animname = "sacrifice";
				ai.headshotFX = true;
				ai gun_remove();
			}
			
			breach_ai[ breach_ai.size ] = ai;
		}
	
		doors = getentarray( "casino_bar_doors01", "targetname" );
		ldoor = undefined;
		foreach( door in doors )
		{
			if( door.script_noteworthy == "left" )
				ldoor = door;
		}

		bSpot thread anim_first_frame( breach_ai, "vegas_humanshield_breach" );
		
		bSpot_idle notify( "stop_anim" );
		//level.ninja stopanimscripted();
		
		bSpot thread anim_single_solo( level.ninja, "humanshield_checkdoor" );
		flagWaitThread( "TRACKFLAG_bar_event_attach_door", ::link_two_entites, ldoor, level.ninja, "tag_inhand", ( 0,12,-2 ), ( 0,-90,0 ) );
		flagWaitThread( "TRACKFLAG_bar_event_detach_door", ::r_unlink, ldoor );
		wait(5);
		bspot thread anim_set_rate_single( level.ninja, "humanshield_checkdoor", 0 );
		wait(.5);
		bspot thread anim_set_rate_single( level.ninja, "humanshield_checkdoor", 1 );

		bSpot waittill( "humanshield_checkdoor" );
		flag_set( "FLAG_humanshield_checkdoor" );
		
		level.player SetWeaponAmmoStock( "p99", 56 );
		thread casino_bar_fade_limp();
		
		breach_ai[ breach_ai.size ] = level.ninja;
		bSpot thread humanshield_breach_code( breach_ai );
		delaythread( 2.5, ::SetSlowMotion_func, 1, .25, .3 );
		delaythread( 3, ::SetSlowMotion_func, .25, 1, .5 );
		delaythread( 3.1, ::bar_player_ads_breathin );
		bSpot thread anim_single( breach_ai, "vegas_humanshield_breach" );
		wait( GetAnimLength( level.scr_anim[ "ninja" ][ "vegas_humanshield_breach" ] ) );
		
		level notify( "stealth_event_notify" );
		
		level endon( "DEATHFLAG_bar_enemies_dead" );
		
		breach_ai = remove_dead_from_array( breach_ai );
		level notify( "keegan_humanshield_shooting_start" );
		//delaythread( 2, maps\las_vegas_anim::ai_dropweapon, level.hostage );
		bSpot anim_single( breach_ai, "vegas_humanshield_breach_loop" );
		bSpot anim_single( breach_ai, "vegas_humanshield_breach_ending" );
		
		wait( 1.5 );
		
		//level.ninja disable_arrivals_and_exits( false ); // want this off for the radio pickup anims
		
		flag_set( "FLAG_bar_humanshield_done" );
		
	}
	
	else if( self == level.leader )
	{
		trigger_waittill_trigger( "bar_diaz_trig", undefined, undefined, level.wounded_ai );
		
		wait(1);
		bSpot anim_reach_solo( level.leader, "humanshield_doorstack" );
		bSpot anim_single_solo( level.leader, "humanshield_doorstack" );
		
		node = undefined;
		nodes = getnodearray( "casino_bar02", "targetname" );
		foreach( a in nodes )
			if( a.script_noteworthy == level.leader.script_noteworthy )
				node = a;
		level.leader thread move_to_node( "casino_bar02" );
		
		flag_set( "FLAG_humanshield_leader_inposition" );
		
		flag_wait( "FLAG_start_human_shield_scene" );
		
		bSpot thread anim_single_solo( level.leader, "humanshield_checkdoor" );
		wait(5);
		bspot thread anim_set_rate_single( level.leader, "humanshield_checkdoor", 0 );
		wait(.5);
		bspot thread anim_set_rate_single( level.leader, "humanshield_checkdoor", 1 );		
		
		level waittill( "keegan_humanshield_shooting_start" );
		
		level.leader.ignoreall = false;
		
		flag_wait( "DEATHFLAG_bar_enemies_dead" ); //DEATHFLAG_bar_enemies_dead
		
		level.leader.ignoreall = true;
		
//		node thread anim_loop_solo( level.leader, "humanshield_doorstack_idle", "stop_anim" );
//		
//		level waittill( "keegan_humanshield_shooting_start" );
//		
//		node anim_single_solo( level.leader, "humanshield_baker_trans_fire" );
//		node thread anim_loop_solo( level.leader, "humanshield_baker_fire", "stop_anim" );
//		
//		while( !flag( "bar_enemies_dead" ) )
//		{
//			wait( randomfloatrange( .2, .4 ) );
//			level.leader shoot();
//		}
//		
//		node notify( "stop_anim" );
//		node thread anim_single_solo( level.leader, "humanshield_baker_fire_trans" );
		
	}
	
	else if( self == level.wounded_ai )
	{
		dnode = getnode( "bar_diaz_stepup", "targetname" );
		dnode anim_reach_solo( level.wounded_ai, "bar_diaz_stepup" );
		dnode thread anim_single_solo_run( level.wounded_ai, "bar_diaz_stepup" );
	
		dnode = getnode( "bar_diaz_stepdown", "targetname" );
		dnode anim_reach_solo( level.wounded_ai, "bar_diaz_stepdown" );
		dnode anim_single_solo_run( level.wounded_ai, "bar_diaz_stepdown" );
		
		flag_set( "FLAG_diaz_stepdown_for_humanshield" );
		
		level.wounded_ai ent_flag_clear( "FLAG_wounded_ai_play_sounds" );
		
		bSpot anim_reach_solo( level.wounded_ai, "humanshield_doorstack" );
		bSpot anim_single_solo( level.wounded_ai, "humanshield_doorstack" );	

		istruct = SpawnStruct();
		istruct.origin = level.wounded_ai.origin;
		istruct.angles = level.wounded_ai.angles;
		istruct thread anim_loop_solo( level.wounded_ai, "humanshield_doorstack_idle", "stop_anim" );
		
		flag_wait( "FLAG_start_human_shield_scene" );
		
		istruct notify( "stop_anim" );
		level.wounded_ai stopanimscripted();
		
		bSpot thread anim_single_solo( level.wounded_ai, "humanshield_checkdoor" );
		wait(5);
		bspot thread anim_set_rate_single( level.wounded_ai, "humanshield_checkdoor", 0 );
		wait(.5);
		bspot thread anim_set_rate_single( level.wounded_ai, "humanshield_checkdoor", 1 );		
		
		istruct thread anim_loop_solo( level.wounded_ai, "humanshield_doorstack_idle", "stop_anim" );
		
		flag_wait( "FLAG_bar_humanshield_done" );
		wait( 4 );
		istruct notify( "stop_anim" );
		istruct thread anim_single_solo( level.wounded_ai, "wounded_stand_exit_f" );
		level.wounded_ai ent_flag_set( "FLAG_wounded_ai_play_sounds" );
		
		level.wounded_ai.forcegoal = true;
		snode = getnode( "bar_diaz_stepup2", "targetname" );
		level.wounded_ai notify( "wounded_ai_newgoal" );
		snode thread anim_reach_and_anim( level.wounded_ai, "bar_diaz_stepup" );
		thread func_waittill_msg( level.wounded_ai, "bar_diaz_stepup", ::move_to_node, "casino_bar03" );
		thread func_waittill_msg( level.wounded_ai, "bar_diaz_stepup", ::set_moveplaybackrate, 1 );
	}
	
}

humanshield_breach_code( breach_ai )
{
	self endon( "vegas_humanshield_breach_loop" );
	
	wait(2);
	
	level notify( "start_human_shield_walkers" );
		//level.player allowsprint( true );
	time = .8;
	sound = "double_door_wood_creeky";
	doors = getentarray( "casino_bar_doors01", "targetname" );
	foreach( door in doors )
	{
		thread single_door_open( door, time, sound, undefined, undefined, .4 );
		time = time + .2;
		sound = "none";
	}

	wait(.5);
	
	level notify( "give_player_weapons" );

	flag_wait( "DEATHFLAG_bar_enemies_dead" ); 
	
	breach_ai = remove_dead_from_array( breach_ai );
	foreach( ai in breach_ai )
		ai stopanimscripted();
	
	self anim_single( breach_ai, "vegas_humanshield_breach_ending" ); 

	flag_set( "FLAG_bar_humanshield_done" );
}

bar_player_ads_breathin()
{
	level endon( "DEATHFLAG_bar_enemies_dead" ); 
	
	sound = "weap_sniper_breathin";
	while(1)
	{
		if( level.player isADS() || level.player adsbuttonpressed() )
		{
			level.player thread play_sound_on_entity( sound );
			level.player notify( "stop_fake_shellshock" );
			level.ground_ref_ent rotateto( ( 0,0,0 ), .5, .1, .1 );
			break;
		}
		
		wait( .05 );
	}
	
}

bar_player_setup()
{
//	SetSavedDvar( "cg_drawCrosshair", 0 );
	SetSavedDvar( "player_swimForwardMinSpeed", 10000 );
	SetSavedDvar( "player_swimForwardAnimCatchupMax", 10 );
	SetSavedDvar( "player_swimForwardAnimCatchupMax", 5 );
	
	level.player TakeAllWeapons();
//	level.player DisableWeaponSwitch();
	level.player GiveWeapon("p99" );
//	level.player GiveWeapon("iw5_p99wounded_sp_swim");
	level.player SwitchToWeapon( "p99" );
//	level.player AllowAds( false );
//	level.player AllowFire( false );
//	level.player AllowMelee( false );
//	
//	level waittill( "give_player_weapons" );
//	
//	level.player TakeWeapon( "iw5_p99wounded_sp_swim" );
//	level.player SwitchToWeapon( "p99" );
//	level.player AllowAds( true );
//	level.player AllowFire( true );
//	level.player AllowMelee( true );
//	level.player EnableWeaponSwitch();
}

casino_bar_radio_scene()
{
	spawner = getent( "casino_bar_radio_guy", "targetname" );
	dnode = getstruct( spawner.target, "targetname" );
	//dude = spawner spawn_ai( true, true );
	//dude ignore_everything();
	drone = dronespawn_bodyonly( spawner ); // need interactable corpse
	drone.animname = "radio_guy";
	drone gun_remove();
	drone NotSolid();
	idleanim = "bar_radioguy_idle";
	reactanim = "bar_radioguy_react";
	deathanim = "bar_radioguy_death";
	level.ninja.radio = spawn( "script_model", drone.origin );
	level.ninja.radio setmodel( "com_hand_radio" );
	level.ninja.radio linkto( drone, "tag_inhand", ( 0,0,0 ), ( 0,0,0 ) );
	
	drone thread anim_loop_solo( drone, idleanim, "stop_anim" );
	level waittill( "stealth_event_notify" );
	drone notify( "stop_anim" );
	drone anim_single_solo( drone, reactanim );
	level.ninja.radio hide();
	dnode anim_single_solo( drone, deathanim );
	
	flag_wait( "DEATHFLAG_bar_enemies_dead" );
	
	level.ninja.radio unlink();
	level.ninja.radio linkto( drone, "tag_weapon_chest", ( 0,0,0 ), ( 0,0,0 ) );
	level.ninja.radio show();
	
	level.ninja disable_arrivals_and_exits();
	
	struct = getstruct( "bar_keegan_stairs_spot", "targetname" );
	struct anim_reach_solo( level.ninja, "creepwalk_2_run" );
	level.ninja disable_creepwalk();
	level.leader delaythread( .3, ::disable_creepwalk );
	struct anim_single_solo( level.ninja, "creepwalk_2_run" );
	
	dnode anim_reach_solo( level.ninja, "bar_radio_pickup" );
	array = [ drone, level.ninja ];
	dnode thread anim_single( array, "bar_radio_pickup" );
	level waittill( "keegan_grab_radio" );
	level.ninja.radio unlink();
	level.ninja.radio linkto( level.ninja, "tag_inhand", ( 0,0,0 ), ( 0,0,0 ) );
	level waittill( "keegan_holster_radio" );
	level.ninja.radio unlink();
	level.ninja.radio linkto( level.ninja,"tag_stowed_hip_rear" );
	
	dnode waittill( "bar_radio_pickup" );
	
	//level.ninja clear_run_anim();
	level.ninja enable_creepwalk();
	level.ninja disable_arrivals_and_exits( false );
	
	flag_set( "FLAG_grab_radio_done" );
}

casino_bar_fade_limp()
{
	//trigger_waittill_trigger( name );
	
	time = randomintrange( 4, 8 );
	level.player player_speed_percent( 35, time );	
	level.player allowsprint( false );
	//wait( time );
	
	level.player_limp[ "pitch" ][ "min" ] 	= .5;
	level.player_limp[ "pitch" ][ "max" ] 	= 1;
	level.player_limp[ "yaw" ][ "min" ]		= .5;
	level.player_limp[ "yaw" ][ "max" ] 	= 1;
	level.player_limp[ "roll" ][ "min" ] 	= .5;
	level.player_limp[ "roll" ][ "max" ] 	= 1;

}

casino_bar_jumper()
{
	self endon( "death" );
	
	self.ignoreme = true;
	self.ignoreall = true;
	self.ignoresuppression = true;
	self.suppressionwait = 0;
	self disable_surprise();
	self.IgnoreRandomBulletDamage = true;
	self disable_bulletwhizbyreaction();	
	
	level waittill( "stealth_event_notify" );
	wait(.5);
	
	self.ignoreme = false;
	self.ignoreall = false;
	self.ignoresuppression = false;
	self.suppressionwait = 1;
	self enable_surprise();
	self.IgnoreRandomBulletDamage = false;
	self enable_bulletwhizbyreaction();
}

casino_bar_walkers( spawner )
{
	self endon( "death" );
	level endon( "stealth_event_notify" );

	self.ignoreall = true;
	self.ignoreme = true;
	self disable_arrivals();
	self disable_exits();
	self disable_surprise();
	self disable_pain();
	self pathrandompercent_zero();
	self.animname = "box_guy";
	self set_run_anim( self.animation );
	
	strings = StrTok( self.animation, "_" );
	self.num = strings[2];
	
	self.deathanim = getanim( "vegas_guy_" + self.num + "_box_carry_dead" );
	self.reactanim = "vegas_guy_" + self.num + "_box_carry_turn_shoot";
	
	model = "com_cardboardbox_dusty_01";
	self.box = spawn( "script_model", self.origin );
	self.box setmodel( model );
	self.box linkto( self, "tag_inhand", ( 0,0,0 ), ( 0,90,0 ) );
	
	self thread waittill_stealth_notify();
	self thread casino_bar_walkers_reset();
	self thread casino_bar_humanshield_deaths();
	
	self.goalradius = 5;
	self setgoalpos( self.origin );
	wait( 4 );
	spot = getstruct( spawner.script_linkto, "script_linkname" );
	array = get_target_chain_array( spot );	

	for( i=0; i<array.size; i++ )
	{
		spot = array[i];
		
		self.goalradius = spot.radius;
		
		self setgoalpos( spot.origin );
		self waittill( "goal" );
		
		if( !flag( "FLAG_humanshield_checkdoor" ) )
		{
			self thread anim_first_frame_solo( self, self.animation );
			flag_wait( "FLAG_humanshield_checkdoor" );
			self StopAnimScripted();
		}
	}	
}

casino_bar_walkers_reset()
{
	self endon( "death" );	
	
	level waittill( "stealth_event_notify" );
	
	wait( randomfloatrange( .2, .5 ) );

	//self setgoalpos( self.origin );
	self.ignoreall = false;
//	self.ignoreme = false;
	self clear_run_anim();
	self clear_deathanim();
	delaythread( .5, ::clear_deathanim );
	
	self thread waittill_dead_and_stop_anim( self, self.reactanim);
	self thread casino_bar_walkers_boxes(); // this is for after deathanim is cleared but still want box to drop
	self thread anim_single_solo( self, self.reactanim );
	waitframe();
	self anim_set_rate_single( self, self.reactanim, 2 );
	wait( GetAnimlength( getanim( self.reactanim ) )/2 );
	self.box unlink();
	self.box PhysicsLaunchClient( self.origin + ( 0,0,2 ), ( 0,0,-10 ) );
	self.box notify( "phy_launched" );
	self setgoalpos( self.origin );
	self.favoriteenemy = level.ninja;
	
//	node = getnode( self.target, "targetname" );
//	self.goalradius = 25;
//	self setgoalnode( node );
}

casino_bar_walkers_boxes()
{
	self endon( self.reactanim );
	
	box = self.box;
	box endon( "phy_launched" );
	
	self waittill( "death" );
	
	playfx( level._effect["bar_box_exp"], box.origin );
	box unlink();
	box PhysicsLaunchClient( self.origin + ( 0,0,2 ), ( 0,0,-10 ) );
}

casino_bar_humanshield_deaths()
{
	self endon( "death" );
	
	level waittill( "keegan_humanshield_shooting_start" );	

	if( isdefined( self.script_death ) )
	{
		wait( self.script_death );
		playfxontag( level._effect[ "headshot_blood"	], self, "j_head" );
		self die();
	}
}

CONST_KEEGAN_WAVE_TIMEOUT = 11;

casino_kitchen()
{
	autosave_by_name_silent( "kitchen" );

	thread maps\las_vegas_casino_vo::casino_kitchen_dialog();
	thread casino_kitchen_rats();
	
	angle = ( 0, 90, 0 );
	foreach( ai in level.heroes )
	{
		if( ai != level.wounded_ai )
		{
			ai disable_arrivals_and_exits();
			ai disable_creepwalk();
			ai enable_cqbwalk();
			//ai thread casino_kitchen_ai_speed( angle  );
		}
	}
	
	// kitchen double door open
	onode = getstruct( "casino_kitchen_keegan_enter_node", "targetname" );
	onode anim_reach_solo( level.ninja, "double_doors_open" );
	onode thread anim_single_solo( level.ninja, "double_doors_open" );
	
	wait(.6);
	doors = getentarray( "casino_kitchen_doors01", "targetname" );
	foreach( door in doors )
		door.originalAngles = door.angles;
	thread doors_open( doors, 1.4, "double_door_wood_creeky", -90, 0, .5 );
	delaythread( 1.4, ::doors_open, doors, [ .8, 1.2 ], "none", [ 3, 8 ], 0, .4 );
	
	level notify( "keegan_in_kitchen" );

	array_thread( level.heroes, ::casino_kitchen_walkthrough );
	
	// if player is already in kitchen don't try to make him stay behind wounded_ai
	if( !flag( "TRIGFLAG_player_entering_kitchen" ) )
	{
		level.wounded_ai thread player_keep_distance_from_ai();
		flag_wait( "TRIGFLAG_player_entering_kitchen" );
	}
	
	// gets AI inside kitchen office
	ambushSpot = getstruct( "casino_kitchen_flashlight_scene", "targetname" );
	array_thread( level.heroes, ::casino_kitchen_ambush_setup, ambushSpot );
	
	thread casino_kitchen_exit_door( ambushSpot );
	
	level waittill( "start_kitchen_walkers" );
	
	
	//------------------- change player speed, wounded anim set to test how this feels from here.
	
	flag_set( "FLAG_player_used_adrenaline" ); // testing where it is best to stop the adrenaline.
	level.player player_speed_percent( 70 );
	
	//------------------- change player speed, wounded anim set to test how this feels from here.
	
	array_thread( getentarray( "kitchen_stealth_axis_trigs", "targetname" ), ::kitchen_stealth_code );
	
	walkeroverride = undefined;
	spawners = getentarray( "casino_kitchen_walkers", "targetname" );
	foreach( spawner in spawners )
	{
		if( isdefined( spawner.script_noteworthy ) && spawner.script_noteworthy == "kitchen_walker_flashlight_dude" )
			walkeroverride = "active_patrolwalk_v1";	
		
		thread casino_walkers_script( spawner, walkeroverride );
		
		walkeroverride = undefined;
	}
	
	thread waittill_walkers_done( spawners );
	
	trigger_waittill_trigger( "casino_walkers_enter_trig" );

	flag_set( "FLAG_walkers_entering_kitchen" );
	
	walkers = get_living_ai_array( "casino_kitchen_walkers", "targetname" );
	foreach( ai in walkers )
		if( isdefined( ai.script_noteworthy ) && ai.script_noteworthy == "flashlight" )
			ai thread notify_delay( "flashlight_on", .5 );
	
	//msg = waittill_any_return( "FLAG_walkers_done", "stealth_event_notify" );
	
	//msg = "FLAG_walkers_done";
	add_wait( ::waittill_msg, "stealth_event_notify" );
	add_wait( ::flag_wait, "FLAG_walkers_done" );
	do_wait_any();
	
	
	level.wounded_ai disable_wounded_ai();
	// the player should have picked this up by now.
	level.player giveweapon( "kriss+acogsmg_sp" );
	level.player SwitchToWeapon( "kriss+acogsmg_sp" );
	
	level.wounded_ai set_run_anim( "wounded_run_diaz" );
	
	if( flag( "FLAG_walkers_done" ) )
	{
		foreach( door in doors )
		{
			door rotateto( door.originalAngles, .05 );
			door disconnectpaths();
		}
	}
	else
	{
		walkers = remove_Dead_from_array( walkers );
		
		thread casino_kitchen_flashlight_scene_alert_timer( walkers );
		
		foreach( walker in walkers )
		{
			walker.ignoreall = false;
			walker.ignoreme = false;
			
			walker notify_delay( "flashlight_off", randomfloatrange( .2, .4 ) );
		}
	}
	
	doors = getentarray( "casino_hallway_door01", "targetname" );
	foreach( door in doors )
	{
		if( door.script_noteworthy == "right" )
			door rotateto( door.angles + ( 0, 90, 0 ) , .05 );
		else
			door rotateto( door.angles - ( 0, 90, 0 ), .05 );
		
		door DisconnectPaths();
	}
	
	array_thread( level.heroes, ::move_to_node, "casino_kitchen03" );
	
	flag_wait( "FLAG_casino_start_hallway" );
	
	//	thread maps\las_vegas_adrenaline::player_enable_adrenaline( 3 );
	
//	foreach( ai in level.heroes )
//	{
//		if( ai == level.wounded_ai )
//			level.wounded_ai disable_wounded_ai();
//		else
//			ai disable_creepwalk();
//	}
}

casino_kitchen_ai_speed( angle, minSpeed, maxSpeed )
{
	
}

casino_kitchen_exit_door( spot )
{
	
//	spot waittill( "casino_kitchen_event_enter" );
//	
//	rdoor = undefined;
	doors = getentarray( "casino_kitchen_doors02", "targetname" );

//	foreach( door in doors )
//	{
//		if( door.script_noteworthy == "left" )
//		{
//			rdoor = door;
//			rdoor.originalAngles = door.angles;
//		}
//	}
//	
//	minn = 15;
//	maxx = 35;
//	
//	while( !flag( "FLAG_walkers_entering_kitchen" ) )
//	{
//		wait( randomfloatrange( .5, 1.5 ) );
//		
//		num = randomintrange( minn, maxx );
//		time = randomfloatrange( .15, .75 );
//		
//		nAngles = rdoor.originalAngles + ( 0, num, 0 );
//		
//		rdoor rotateto( nAngles, time, time/2, 0 );
//		wait( time + randomfloatrange( .2, .5 ) );
//		
//		time = randomfloatrange( .15, .75 );
//		rdoor rotateto( rdoor.originalAngles, time );
//		
//		wait( time );
//	}

	flag_wait_all( "FLAG_walkers_entering_kitchen", "TRACKFLAG_kitchen_exit_double_doors_open" );

	doors_open( doors, 1.2, "double_door_wood_creeky", undefined, 0, .4  );
	doors_open( doors, 1.2, "none", [ -9, -1 ], 0, .4 );
}

casino_kitchen_rats()
{
	flag_wait( "TRIGFLAG_player_entering_kitchen" );
	
	rvehicle = spawn_vehicle_from_targetname( "kitchen_rat01" );
	rat = spawn( "script_model", rvehicle.origin );
	rat.angles = ( 0, 110, 0 );
	rat setmodel( "rat" );
	rat linkto( rvehicle );
	thread gopath( rvehicle );	
	rvehicle Vehicle_SetSpeed( 15, 15, 15 );
	
	rvehicle waittill( "reached_dynamic_path_end" );
	rat delete();
	
	level waittill( "start_kitchen_walkers" );
	
	rvehicle = spawn_vehicle_from_targetname( "kitchen_rat02" );
	rat = spawn( "script_model", rvehicle.origin );
	rat.angles = ( 0, 93, 0 );
	rat setmodel( "rat" );
	rat linkto( rvehicle );
	thread gopath( rvehicle );
	rvehicle Vehicle_SetSpeed( 10, 10, 10 );
	
	rvehicle waittill( "reached_dynamic_path_end" );
	rat delete();
}

player_keep_distance_from_ai()
{
	minDist = 100;
	
	defaultSpeed = 30;
	currentSpeed = 30;
	minSpeed = 10;
	
	setPspeed = false;
	while( !flag( "FLAG_kitchen_event_start" ) )
	{
		distancee = distance2d( self.origin, level.player.origin );

		if( distancee < minDist && currentSpeed > minSpeed && setPspeed == false )
		{
			currentSpeed = currentSpeed - 5;
			self player_speed_percent( currentSpeed, .05 );

			wait(.5);
		}
		if( distancee > minDist && currentSpeed < defaultSpeed )
		{
			currentSpeed = currentSpeed + 5;
			self player_speed_percent( currentSpeed, .05 );
			
			setPspeed = false;

			wait(2);			
		}
		
		wait(.05);
	}
	
	if( currentSpeed != defaultSpeed )
		self player_speed_percent( defaultSpeed, .05 );
}

casino_kitchen_walkthrough()
{
	if( self == level.wounded_ai )
	{

		self notify( "wounded_ai_newgoal" );
	
		kspot = getstruct( "casino_kitchen_diaz_kitchen_enter_spot", "targetname" );
		kspot anim_reach_solo( self, "vegas_diaz_kitchen_stumble" );
		
		cartModel = getent( "casino_kitchen_cart1", "targetname" );
		cartModel.animmodel = spawn_anim_model( "tag_origin", cartModel.origin + ( 0,0,39 ) );
		kspot anim_first_Frame_solo( cartModel.animmodel, "vegas_diaz_kitchen_stumble" );
		cartModel linkto( cartModel.animmodel, "tag_origin" );
		
		array = [ cartModel.animmodel, self ];
		kspot thread anim_single( array, "vegas_diaz_kitchen_stumble" );
		
		interuptTime = 6.8;
		animTime = getanimlength( self getanim( "vegas_diaz_kitchen_stumble" ) );
		remaintime = animTime - interuptTime;
	
		wait( interuptTime );
	
		cartModel delaycall( remainTime, ::unlink );
		cartModel.animmodel delaycall( remainTime, ::delete );

		// play diaz_kitchen_idle only if player is not halfway through the kitchen yet
		if( !flag( "TRIGFLAG_player_moving_through_kitchen" ) )
		{
			kspot waittill( "vegas_diaz_kitchen_stumble" );
			kspot thread anim_loop_solo( self, "vegas_diaz_kitchen_idle", "stop_anim" );
			
			flag_wait( "TRIGFLAG_player_moving_through_kitchen" );
			kspot notify( "stop_anim" );
			kspot anim_single_solo( self, "vegas_diaz_kitchen_idle_exit" );
		}
		else
			self stopanimscripted();
	}
	else if( self == level.leader )
	{	
		
		self disable_arrivals_and_exits();
		// special path for baker
		//array = [ ( -31012, -28032, 2140 ), ( -30964.5, -27899, 2144 ) ];
		array = [ ( -31032, -28256, 2140 ), ( -31176, -28128, 2140 ) ];
		cradius = self.goalradius;
		foreach( spot in array )
		{
			self.goalradius = 56;
			self setgoalpos( spot );
			self waittill( "goal" );
		}
		self.goalradius = cradius;
		self disable_arrivals_and_exits( false );
		
		flag_set( "FLAG_baker_kitchen_walkthrough_done" );
		wait( .2 );
		
		if( !flag( "TRIGFLAG_player_entering_kitchen" ) )
			self thread move_to_node( "casino_kitchen01" );	
	}
	else
	{
		spot = getstruct( "casino_kitchen_flashlight_scene", "targetname" );
		spot anim_reach_solo( self, "casino_kitchen_event_enter" );
		spot thread anim_first_frame_solo( self, "casino_kitchen_event_enter" );
	}
}

casino_kitchen_ambush_setup( spot )
{
	
	if( self == level.wounded_ai )
	{
		
		flag_wait( "TRIGFLAG_player_moving_through_kitchen" );
		
//		need to make sure both keegan and baker are at their start points for the ambush scene
//		count = 0;
//		while( count != 2 )
//		{
//			count = 0;
//			
//			foreach( ai in level.heroes )
//			{
//				
//				if( isdefined( ai.at_kitchen_ambush ) )
//					count++;
//			}
//			wait(.05);
//		}
		
		self notify( "wounded_ai_newgoal" );
		
		spot anim_reach_solo( self, "casino_kitchen_event_enter" );	
		
		flag_set( "FLAG_kitchen_event_start" );
		level.wounded_ai ent_flag_clear( "FLAG_wounded_ai_play_sounds" );
		
		cartModel = getent( "casino_kitchen_cart2", "targetname" );
		cartModel.animmodel = spawn_anim_model( "tag_origin", cartModel.origin + ( 0,0,39 ) );
		spot anim_first_frame_solo( cartModel.animmodel, "casino_kitchen_event_enter" );
		cartModel linkto( cartModel.animmodel, "tag_origin" );
		
		array = array_add( level.heroes, cartModel.animmodel );
		
		// stop bakers idle loop
		if( isdefined( level.leader.idlespot ) )
		{
			level.leader.idlespot notify( "stop_loop" );
			level.leader stopanimscripted();
			level.leader.idlespot = undefined;
		}
		
		spot anim_single( array, "casino_kitchen_event_enter" );
		
		cartModel unlink();
		cartModel.animmodel delete();
		
		// Did this kinda weird, this has the loops for all the AI
		array = array_remove( level.heroes, level.ninja );
		spot thread anim_loop( array, "casino_kitchen_event_wait_loop" ); 
		
		// need this to stop and start loops on ninja without stopping the other AI loops
		ninjaspot = spawnStruct();
		ninjaspot.angles = spot.angles;
		ninjaspot.origin = spot.origin;
		level.ninja.kitchenSpot = ninjaspot;
		ninjaspot thread anim_loop_solo( level.ninja, "casino_kitchen_keegan_wave_loop" );
		
		flag_set( "FLAG_kitchen_ambush_setup" );
		
		level waittill( "start_kitchen_ambush_scene" );
		
		level.wounded_ai ent_flag_set( "FLAG_wounded_ai_play_sounds" );
		
	}
	else
	{
//		if( self == level.leader )
//			wait( .5 );
//		self thread move_to_node( "casino_kitchen02" );
		
		self ignore_everything();
		
		if( self == level.leader )
			flag_wait( "FLAG_baker_kitchen_walkthrough_done" );
		
		// bakers readystand arrival
		if( self == level.leader )
		{
			spot = spawnstruct();
			spot.origin = ( -31247.5, -27520.5, 2112.1 );
			spot.angles = ( 0, 106.8, 0 );
			spot anim_reach_solo( self, "casino_kitchen_event_approach" );	
			spot anim_single_solo( self, "casino_kitchen_event_approach" );
			
			if( !flag( "FLAG_kitchen_event_start" ) )
			{
				self.idlespot = spawnstruct();
				self.idlespot.angles = self.angles;
				self.idlespot.origin = self.origin;
				self.idlespot thread anim_loop_solo( self, "readystand_idle" );
			}
		}
		else
			spot anim_reach_solo( self, "casino_kitchen_event_enter" );	
		
		flag_wait( "FLAG_kitchen_ambush_setup" );
		
		self clear_ignore_everything();
		self.at_kitchen_ambush = true;
		
		// this is to get Keegan into the hide room
		if( self == level.ninja )
		{
			flag_wait_or_timeout( "TRIGFLAG_kitchen_player_in_pantry", CONST_KEEGAN_WAVE_TIMEOUT );
			self stopanimscripted();
			self.kitchenspot notify( "stop_loop" );
			self.kitchenspot anim_single_solo( self, "casino_kitchen_event_enter_end" );
			self.kitchenspot thread anim_loop_solo( self, "vegas_keegan_kitchen_wait_loop" );
			
			level notify( "start_kitchen_walkers" );
		}
	}
	
}

casino_kitchen_flashlight_scene_alert_timer( walkers )
{
	level endon( "missionfailed" );
	
	wait(randomintrange( 4, 8 ) );
	walkers = remove_Dead_from_array( walkers );
	
	if( walkers.size > 0 ) 
	{
		SetDvar( "ui_deadquote", "Your actions caused your squadmates to die!" );
		thread MissionFailedWrapper();
	}
}
	
casino_kitchen_ambush( spawner, spot )
{
	// this makes the flashlight guy + keegan ambush scene happen
	
	spawner.walkdone = true;
	self.animname = "flashlight_guy";
	self gun_remove();
	
	spot anim_reach_solo( self, spot.animation );
	level notify( "start_kitchen_ambush_scene" );
	
	level.ninja.kitchenspot notify( "stop_anim" );
	level.ninja stopanimscripted();
	
	array = [ self, level.ninja ];
	spot thread anim_single( array, spot.animation );
	
	wait(11);
	
	level.ninja attach( "weapon_commando_knife_bloody", "tag_inhand" );
	
	spot waittill( spot.animation );
	maps\las_vegas_anim::ai_kill( self );

	level.ninja Detach( "weapon_commando_knife_bloody", "tag_inhand" );
	
	
	// cleanup
	level.ninja.kitchenspot = undefined;	
}

casino_kitchen_friendlies_exit( guy )
{
	// gets baker and diaz out of the office
	// this is called through addNotetrack_customFunction
	// guy is irrelevant
	
	spot = getstruct( "casino_kitchen_flashlight_scene", "targetname" );
	spot notify( "stop_loop" );
	
	array = array_remove( level.heroes, level.ninja );
	foreach( ai in array )
		ai stopanimscripted();
	
	spot thread anim_single( array, "casino_kitchen_event_ambush_exit" );
}

kitchen_flashlight_guy_flashlight()
{
	self.flashlight = spawn( "script_model", self.origin );
	self.flashlight setmodel( "com_flashlight_on" );
	self.flashlight linkto( self, "tag_inhand", ( 0,0,0 ), ( 0,0,0 ) );
	playfxontag( level._effect["flashlight_spotlight"], self.flashlight, "tag_light" );	
	
	level waittill( "flashlight_guy_unlink_flashlight" ); //notetrack
	
	self.flashlight unlink();
	
	// random flickering
	on = true;
	timeout = 5000; 
	starttime = gettime();
	while( gettime() - starttime <= timeout )
	{
		on = undefined;
		self.flashlight setmodel( "com_flashlight_off" );
		stopfxontag( level._effect["flashlight_spotlight"], self.flashlight, "tag_light" );
		wait( randomfloatrange( .1, .3 ) );
		on = true;
		self.flashlight setmodel( "com_flashlight_on" );
		playfxontag( level._effect["flashlight_spotlight"], self.flashlight, "tag_light" );
		wait( randomfloatrange( .2, .8 ) );		
	}
	
	// just in case the light is still on
	if( isdefined( on ) )
	{
		self.flashlight setmodel( "com_flashlight_off" );
		stopfxontag( level._effect["flashlight_spotlight"], self.flashlight, "tag_light" );
	}
}

kitchen_stealth_code()
{
	level endon( "walkers_done" );
	
	ltrigger = getent( self.target, "targetname" );
	trigger_waittill_trigger( self );
	
	while(1)
	{
		if( level.player istouching( ltrigger ) )
			level notify( "stealth_event_notify" );
		wait( .1 );
	}
	
}

casino_hallway()
{
	level endon( "FLAG_start_atrium_combat" );

	gates = getentarray( "casino_atrium_exit_door", "targetname" );
	foreach( gate in gates )
	{
		gate hide();
		gate ConnectPaths();
		handle = getent( gate.target, "targetname" );
		handle linkto( gate );
		handle hide();
	}
	
	//doors_open( ent, opentime, sound, amount, acelTime, decelTime )
	thread doors_open( gates, 1.9, "none", undefined, 0.3, 0.3 );
	
	//thread casino_hallway_chandeliers();
	thread maps\las_vegas_casino_vo::casino_atrium_dialog();
	autosave_by_name( "atrium" );
	
	if( isdefined( level.ninja.old_pathrandompercent ) )
		level.ninja pathrandompercent_reset();
	foreach( ai in level.heroes )
		ai.name = ai.realname;
	
	//	level.ninja disable_arrivals_and_exits( false );
	// This moves them in a position before the gate.
	array_thread( level.heroes, ::move_to_node, "casino_atrium01" );
	
	level.ninja.goalradius = 10;
	//level.wounded_ai maps\las_vegas_code::enable_wounded_ai();
	
	//array_thread( level.heroes, ::disable_cqbwalk );
	//level.wounded_ai set_run_anim( "wounded_run_diaz" );
	
	//thread maps\las_vegas_adrenaline::player_enable_adrenaline( 3 ); // took out for now jl.
	
	trigger_waittill_trigger( "casino_atrium_trig01" );
	
//	level.ninja waittill( "goal" );
	
//	trigger_waittill_trigger( "casino_atrium_trig02" );
	
	flag_set( "FLAG_gt_at_the_gate" );
	
	foreach( hero in level.heroes )
	{
		hero.ignoreall = true;
	}
	//delaythread( 1.5, ::atrium_room_destruction );
	thread hallway_combat_player_shoots();
	
	wait 6;
	wait 3;
	
	//getent("atrium_runners_trig", "targetname" ) notify( "trigger" );
	waitframe(); // give AI chance to spawn
	childthread move_to_node_heroes( "casino_atrium04" );

	level.ninja waittill( "goal" );
	flag_set( "cleared_atrium_no_fight" ); 	
	
	trigger_waittill_trigger( "casino_atrium_headto_gamblingroom" );
}

hallway_combat_player_shoots()
{	
	level endon( "cleared_atrium_no_fight" ); 
	
	// support this correctly.
	
	thread atrium_balcony_runners();
	
	// kill this once the guys above run by.
	
	while( 1 ) // guys run by
	{
		if( level.player AttackButtonPressed () )
		{
			flag_set( "FLAG_start_atrium_combat" );
			break;
		}
		wait 0.1;
	}
	
	 ai = getaiarray( "axis" ); 
	 
	 foreach( alive in ai )
	 {
	 		if( isalive( alive ) )
	 		{
			  	alive.ignoreme = false;
			  	alive.ignoreall = false;
				location = spawn( "script_origin", alive.origin ); // need to delete this location.
				location.origin = location.origin + ( 0, 0, 30 );
				alive.goalradius = 1000;
			    alive setgoalentity( location );				

				if( isdefined( alive.targetname ) && alive.targetname == "atrium_escalator_runners0" ||
					  alive.targetname == "atrium_escalator_runners1" || alive.targetname == "atrium_escalator_runners2")
				{
					spot = getent( "atrium_escalator_shoot_spot", "targetname" );
					alive.goalradius = 200;
					alive setgoalentity( spot );
				}

			    waitframe();
			    location delete();
			    alive allowedstances( "stand" );
	 		}
	 }
	 
	 foreach( hero in level.heroes )
	 {
		hero.ignoreme = false;
		hero.ignoreall = false;
		location = spawn( "script_origin", hero.origin ); // need to delete this location.
		location.origin = location.origin + ( 0, 0, 30 );
		hero.goalradius = 1000;
		hero setgoalentity( location );
		waitframe();
		location delete();
		hero allowedstances( "stand" );
	 }
	
	thread atrium_balcony_guys();
	
	array_thread( level.heroes, ::set_ignoreme, false );
	delaythread( 5, ::move_to_node_heroes, "casino_atrium02" );
	
	music_stop();
	
	wait( 9 );
	
	array = getaiarray( "axis" );
	
	waittill_dead_or_dying( array, array.size - 1 ); //array.size - 1 
	
	thread move_to_node_heroes( "casino_atrium03" );
	
	wait 6;
	
	array = getaiarray( "axis" );
	//	array = get_living_ai_array( "atrium_runners", "targetname" );
	waittill_dead_or_dying( array, array.size ); // array.size - 2 

	thread move_to_node_heroes( "casino_atrium04" );
	
	trigger_waittill_trigger( "casino_atrium_headto_gamblingroom" );

}

atrium_balcony_runners()
{
	level endon( "FLAG_start_atrium_combat" );
	
	spawners = getentarray( "atrium_escalator_runners0", "targetname" );
	goal = getnode( "atrium_escalator_delete0", "targetname" );
	
	childthread runners_delete( spawners, goal );
		
	wait 3;
	
	spawners = getentarray( "atrium_escalator_runners1", "targetname" );
	goal = getnode( "atrium_escalator_delete1", "targetname" );
	
	childthread runners_delete( spawners, goal );
	
	wait 2.7;
	
	spawners = getentarray( "atrium_escalator_runners2", "targetname" );
	goal = getnode( "atrium_escalator_delete0", "targetname" );
	
	childthread runners_delete( spawners, goal );
	
	
	spawners = getentarray( "atrium_balcony_runners", "targetname" );
	goal = getnode( "atrium_delete_runner", "targetname" );
	
	childthread runners_delete( spawners, goal );

	wait 3;
	
	spawners = getentarray( "atrium_balcony_runners1", "targetname" );
	goal = getnode( "atrium_delete_runner1", "targetname" );
	
	childthread runners_delete( spawners, goal );
}

runners_delete( spawners, goal ) 
{	
	foreach( spawner in spawners )
	{
		ai = spawner spawn_ai();
		waitframe();
		ai.ignoreall = true;
		ai.goalradius = 60;
		ai childthread run_to_goal_delete( goal );
	}	
}

atrium_balcony_guys()
{
	spawners = getentarray( "atrium_balcony_guys", "targetname" );
	
	
	stayers = [];
	foreach( spawner in spawners )
	{
		ai = spawner spawn_ai();
		
		if( isdefined( spawner.script_noteworthy ) && spawner.script_noteworthy == "atrium_initial_rappelers" )
		{
			time = 0;
			if( isdefined( spawner.script_delay ) )
				time = spawner.script_delay;

			ai delaythread( time + 5, ::actor_rappel, "rail" );
		}
		else
		{
			ai.spawner = spawner;
			stayers[ stayers.size ] = ai;
		}
	}

	trigger_waittill_trigger( "casino_atrium_trig03" );

	stayers = remove_dead_from_array( stayers );
	foreach( ai in stayers )
	{
		ent = getstruct( ai.spawner.script_linkto, "script_linkname" );
		ai thread actor_rappel( "rail", ent );
		wait( randomfloatrange( .4, .8 ) );
	}
}

atrium_runners()
{	
	spawner = self.spawner;
	if( !isdefined( spawner.script_linkto ) )
		return;
//	node = getstruct( spawner.script_linkto, "targetname" );
//	node anim_reach_solo( self, "vegas_guy_open_double_doors" ); // vegas_guy_open_double_doors
//	node thread anim_single_solo( self, "vegas_guy_open_double_doors" );
}

atrium_room_destruction()
{
	
	wait( randomfloatrange( 2, 4 ) );
	
	car = getent( "atrium_car_fall", "targetname" );
	spot = getent_or_struct_or_node( car.target, "targetname" );
	array = get_target_chain_array( spot );
	foreach( thing in array )
	{
		car moveto( thing.origin, .4 );
		car rotateto( thing.angles, .4 );
		wait( .4 );
	}
	
	glass = getglass( "atrium_car_fall_glass" );
	DestroyGlass( glass, ( -1, 0, 0 ) );
}

casino_hallway_gate_watcher()
{
	trigger = getent( "casino_hallway_gate_guys_trig", "targetname" );
	trigger_waittill_trigger( trigger );
	
	aiArray = get_living_ai_array_safe( "casino_hallway_gate_guys", "script_noteworthy" );

	while(1)
	{
		countt = 0;
		
		foreach( dude in aiArray )
		{
			if( isdefined( dude.throughgate ) )
				countt++;	
		}
	
		if( countt == aiArray.size )
			break;
		
		wait(.05);
	}
	
	flag_set( "hallway_gate_guys_done" );
	
}

waittill_walkers_done( spawners )
{
	level endon( "walkers_alerted" );
	level endon( "stealth_event_notify" );
	
	while(1)
	{
		done = 0;
		
		foreach( spawner in spawners )
		{
			if( isdefined( spawner.walkdone ) )
				done++;
		}
		if( done == spawners.size )
			break;
		
		wait(.05);
	}	
	
	flag_set( "FLAG_walkers_done" );
}

casino_hallway_ceiling_fx()
{
	
	structs = getstructarray( "explosion_ceiling_fxspots", "targetname" );

	structs = array_randomize( structs );
	foreach( struct in structs )
	{
			//struct.angles = struct.angles + ( -90, 0, randomfloatrange( -180, 180 ) );
		struct.angles = ( -90,0, randomfloatrange( -180, 180 ) );
		playfx( level._effect["ceiling_dust"], struct.origin, anglestoforward( struct.angles ) );
		wait( randomfloatrange( 1, 2 ) );
	}
	
}

casino_hallway_chandeliers()
{
	things = getentarray( "casino_hallway_chandeliers", "targetname" );
	foreach( thing in things )
	{
		thing.mover = spawn( "script_origin", thing.origin );
		thing linkto( thing.mover );
		thing thread casino_hallway_chandeliers_move();
		thing thread casino_hallway_chandeliers_fx();
	}	
}

casino_hallway_chandeliers_move()
{
	startMAX = CASINO_HALLWAY_CHANDELIER_MAX;
	startMIN = CASINO_HALLWAY_CHANDELIER_MIN;
	
	neg = false;
	if( cointoss() )
	{
		startMax = startMax * -1;
		startMin = startMin* -1;
		neg = true;		
	}
	
	moveTime = randomfloatrange( .6, .8 );
	
	origin_angles = self.angles;
	
	opp = false;
	
	rotAngles = [];
	
	wait( randomfloatrange( 0, .5 ) );
	
	while(1)
	{
		
		if( opp == true )
		{
			rotAngles[ "x" ] = rotAngles[ "x" ] * -1;
			rotAngles[ "y" ] = rotAngles[ "y" ] * -1;
			rotAngles[ "z" ] = rotAngles[ "z" ] * -1;
		}
		else
		{
			greater = 0;
			lesser = 0;
			if( startMax > startMin )
			{
				greater = startMax;
				lesser = startMin;
			}
			else
			{
				greater = startMin;
				lesser = startMax;				
			}
			
			rotAngles[ "x" ] = randomfloatrange( lesser, greater );
			rotAngles[ "y" ] = randomfloatrange( lesser, greater );
			rotAngles[ "z" ] = randomfloatrange( lesser, greater );			
		}
					
		newspot = self.angles + ( rotAngles[ "x" ], rotAngles[ "y" ], rotAngles[ "z" ] );
		
		self.mover rotateto( newspot, moveTime, 0, moveTime/2 );
		wait( moveTime );
		
		// move back to original angles
		self.mover rotateto( origin_angles, moveTime, moveTime/2, 0 );
		wait( moveTime );
		
		if( opp == false )
			opp = true;
		
//		THIS MAKES IT SLOW DOWN OVER TIME
//		else
//		{
//			opp = false;
//			if( neg == true )
//			{
//				startMAX = startMAX + randomfloatrange( .5, 1 );
//				startMIN = startMIN + randomfloatrange( .5, 1 );
//			}
//			else
//			{
//				startMAX = startMAX - randomfloatrange( .5, 1 );
//				startMIN = startMIN - randomfloatrange( .5, 1 );
//			}
//		}
		if( neg == true )
		{
			num = startMin * -1;
			if( num <= 0 )
				break;
		}
		else if( startMin <= 0 )
			break;
	}
		
}

casino_hallway_chandeliers_fx()
{
	while(1)
	{
		//struct.angles = struct.angles + ( -90, 0, randomfloatrange( -180, 180 ) );
		wait( randomfloatrange( 7.0, 15.0 ) );
		
		struct = spawnstruct();
		struct.angles = ( -90,0, randomfloatrange( -180, 180 ) );
		playfx( level._effect["ceiling_dust"], self.origin, anglestoforward( struct.angles ) );
	}
}

//---------------------------------------------------------
// Casino Floor
//---------------------------------------------------------

casino_floor_sequence()
{	
	add_wait( ::trigger_waittill_trigger, "casino_atrium_headto_gamblingroom" );
	do_wait_any();
	
	foreach( hero in level.heroes )
	{
		hero enable_cqbwalk();
	}
	
	//level.stairs_runners = [];
	thread maps\las_vegas_casino_vo::casino_gamblingroom_dialogue();
	
	autosave_by_name( "gamblingfloor" );
	
	//thread casino_gamblingroom_sandstorm();
	thread casino_floor_ambush();
	


	
	
	// Keegan moves first. He gets to the top of the stairs and fires upon guys coming up the stairs
	foreach( ai in level.heroes )
	{
		if( ai == level.ninja )
		{
			ai disable_creepwalk();
			ai enable_cqbwalk();
			
			casino_atrium_glass_node = getnode( "casino_atrium_glass_door", "targetname" );
			
			table = getent( "casino_table", "targetname" );
			a_mannequin = getentarray( "table_mannequin", "targetname" );
			foreach( manne in a_mannequin )
			{
				manne linkto( table );	
			}
			a_chair = getent( "chair_moves", "targetname" );
			a_chair linkto ( table );
			
//			ai disable_arrivals_and_exits( false );
			
			spot = getent( "keegan_move_object", "targetname" );
			spot anim_reach_solo( ai, "sliding_door" ); 
			spot thread anim_single_solo( ai, "sliding_door" );
			wait 1.2;
			table moveto( ( -30122, -27848.5, 2119 ), 3, 0.5, 1.5 );

			wait 3;
			
			//table DisconnectPaths();
			
//			ai AllowedStances( "stand" );
//			ai.goalradius = 5;
//			ai setgoalnode( casino_atrium_glass_node );
			//ai thread move_to_node( "casino_atrium_glass_node" );			
//			ai waittill( "goal" );
//			wait 3;
//			ai disable_arrivals_and_exits( true );
			
//			spot1 = getent( "poop", "targetname" ); //keegan_open_atrium_door0
//			wait 1;
//			spot1 anim_reach_solo( ai, "tactical_open_door" ); 
//			spot1 thread anim_single_solo( ai, "tactical_open_door" );
			
			wait 0.5;
			// wait till friends are close and then slowly open the gate.

			ai thread move_to_node( "casino_gamblingroom00" );
			//ai enable_cqbwalk();
			//ai delaythread( 5, ::disable_cqbwalk );
			//thread func_waittill_msg( ai, "goal", ::send_notify, "stealth_event_notify", level );
		}
		else
			ai delaythread( randomintrange( 1, 2 ), ::move_to_node, "casino_gamblingroom00" );
	}
	
	// start the guys coming up the stairs and the guys flooding into floor
//	trigger_waittill_trigger( "casino_gamblingroom_inital_stair_guys_trig" );
///	thread casino_floor_initial_stair_guys_death();
	
//	level notify_delay( "stealth_event_notify", 3 );
	
	// noone moves downstairs until guys are dead or player hits trigger
//	add_wait( ::get_living_ai_waittill_dead_or_dying, "casino_gamblingroom_inital_stair_guys", "targetname", 5 );
	add_wait( ::trigger_waittill_trigger, "casino_floor_move_downstairs" );
	do_wait_any();
	
	// start the guys on the lower floor
	//level.initial_gr_guys = [];
	//getent( "casino_gamblingroom_inital_guys_trig", "targetname" ) notify( "trigger" );
	
	// move all heroes down to stair middle
	thread move_to_node_heroes( "casino_gamblingroom01" );
	level.wounded_ai thread move_to_node( "casino_gamblingroom01" );
	//level.ninja thread move_to_node( "casino_gamblingroom01" );
	
	//	wait 37;
	
	// wait time or trigger to start sniper event
	trigger = getent( "casino_floor_moveup01", "targetname" );
	msg = trigger waittill_any_timeout( randomintrange( 1, 3 ), "trigger" ); // "trigger", "timeout"
	//msg = trigger waittill_any_timeout( randomintrange( 15, 20 ), "trigger" ); // "trigger", "timeout"
	//iprintlnbold( "Baker : Keegan stay up here and supply sniper support. Rook and Diaz you're with me!" );
	
//	thread move_to_node_heroes( "casino_gamblingroom02" );
//	level.wounded_ai thread move_to_node( "casino_gamblingroom02" );
//	tspot = getstruct( "gr_baker_balcony_jumpdown_spot", "targetname" );
//	tspot thread anim_reach_and_anim( level.leader, "traverse_jumpdown_130" );
//	thread func_waittill_msg( level.leader, "traverse_jumpdown_130", ::move_to_node, "casino_gamblingroom02" );
	
	// start keegans sniper event
	level.ninja thread casino_keegan_sniper_event();
	
//	if( msg == "timeout" )
//		trigger_waittill_trigger( "casino_floor_moveup01" );
	
//	level.initial_gr_guys = remove_dead_from_array( level.initial_gr_guys );
//	volume = getent( "casino_floor_volume_back", "targetname" );
//	foreach( guy in level.initial_gr_guys )
//	{
//		if( cointoss() )
//			guy thread casino_floor_retreaters( volume );
//	}
	
//	thread move_to_node_heroes( "casino_gamblingroom03" );
	
	trigger = getent( "ambush_trig", "targetname" );
	trigger waittill( "trigger" );
	level.wounded_ai thread move_to_node( "casino_gamblingroom01" );
	
	

	//msg = trigger waittill_any_timeout( randomintrange( 4, 6 ), "trigger" ); // "trigger", "timeout"
	wait 6;
	add_wait( ::get_living_ai_waittill_dead_or_dying, "casino_top_floor_ambush_spawners00", "targetname", 7 );
	do_wait_any();
	

	// if the player rushes
	//trigger_waittill_trigger( "casino_floor_moveup02", 34 );
	//trigger_waittill_trigger( "casino_floor_enemies_retreat", 34 );
	
	//	level.ninja forceuseweapon( "kriss", "primary" );
	//	array_thread( level.heroes, ::casino_gamblingroom_sandstorm_walk );
	
	thread casino_floor_sequence_part2();
	
	thread move_to_node_heroes( "casino_gamblingroom03" );
	
	add_wait( ::trigger_waittill_trigger, "start_enemies_up_second_stairs" );
	do_wait_any();
	
	wait 1;
	
	add_wait( ::get_living_ai_waittill_dead_or_dying, "casino_gamblingroom_second_stairs_spawners00", "targetname", 4 );
	do_wait_any();
	
	thread move_to_node_heroes( "casino_gamblingroom05" );
	
	
	//	spots = getstructarray( "casino_bottom_retreat_spots", "targetname" );
	//	array = GetAIArray( "axis" );
	//	foreach( ai in array )
	//	{
	//		ai thread casino_floor_retreaters( spots[0], true );
	//	}
	// fight from here for a while.
}

casino_atrium_stair_guys()
{
	self set_baseaccuracy( .1 );
	self.health = 50;
	
	if( isdefined( self.script_noteworthy ) )
	{
		self.favoritenemy = level.ninja;
		
		level.ninja disable_surprise();
		level.ninja.a.disablePain = true;
		level.ninja.nododgemove = true;
		level.ninja.ignoresuppression = true;
		level.ninja.ignorerandombulletdamage = true;
		level.ninja.allowpain = 0;
		level.ninja.favoriteenemy = self;
		
		self waittill( "death" );
		
		level.ninja enable_surprise();
		level.ninja.a.disablePain = false;
		level.ninja.nododgemove = false;
		level.ninja.ignoresuppression = false;
		level.ninja.ignorerandombulletdamage = false;
		level.ninja.allowpain = 1;
		level.ninja.favoriteenemy = undefined;
	}
	else
	{
		self endon( "death" );
		self.ignoreme = true;
		
		self waittill( "goal" );
		self.ignoreme = false;
	}
}

casino_floor_initial_stair_guys()
{
	self endon( "death" );
	
	//level.stairs_runners[ level.stairs_runners.size ] = self;
	self disable_surprise();
	self disable_arrivals_and_exits();
	
	self enable_cqbwalk();
	
	array = self get_target_chain_array( getstruct( self.target, "targetname" ) );
	self.goalradius = 25;
	self setgoalpos( array[0].origin );
	//thread func_waittill_msg( self, "goal", ::set_goal_pos, array[1].origin );
	
	self thread waittill_stealth_notify();
	
	level waittill( "stealth_event_notify" );

	self.ignoreme = false;
	self.ignoreall = false;
	self.baseaccuracy = 0.1;
	self delaythread( randomfloatrange( .2, .5 ), ::disable_cqbwalk );
	
	node = getnode( self.script_linkto, "script_linkname" );
	self.script_forcegoal = 1;
	self.goalradius = 25;
	self setgoalnode( node );
	
}

casino_floor_initial_stair_guys_death()
{
	level waittill( "stealth_event_notify" );
	
	wait( randomfloatrange( 2, 3 ) );
	
	while( 1 )
	{
		//level.stairs_runners = remove_dead_from_array( level.stairs_runners );
		array = array_randomize( level.stairs_runners );
		if( !isalive( array[ 0 ] ) && !isdefined( array[ 0 ] ) )
			break;
		
		if( level.player player_can_see_ai( array[ 0 ] ) )
		{
			wait(randomfloatrange( .5, 1 ) );
			continue;
		}
		array[ 0 ] DoDamage( array[ 0 ].health + 100, array[ 0 ].origin );
		wait(randomfloatrange( .5, 1 ) );
	}
		
}
casino_keegan_sniper_event()
{
	self forceuseweapon( "as50_keegan", "primary" ); //as50
	self.ignoreme = true;
	self.a.disablePain = true;
	self.nododgemove = true;
	self.ignoreSuppression = true;
	self.ignorerandombulletdamage = true;
	//self.baseaccuracy = 999999;
}

casino_floor_retreaters( goal, deletee )
{
	self endon( "death" );
	
	if( cointoss() )
		wait( randomfloatrange( .2, .4 ) );
	
	self ignore_everything();
	if( isdefined( goal.radius ) )
		self.goalradius = goal.radius;
	self thread set_goal_any( goal );
	self waittill( "goal" );
	if( isdefined( deletee ) )
		self delete();
	self clear_ignore_everything();
}

casino_floor_reinforcements( trigger, noteworthy )
{
	
	getent( trigger, "targetname" ) endon( "trigger" );
	
	dude = self;
	mespawner = dude.spawner;
	if( isdefined( mespawner.script_noteworthy ) && mespawner.script_noteworthy == "casino_right_tomb_dudes" )
		return;
	
	if( !isdefined( noteworthy ) )
		noteworthy = "";
	
	inital_gr_guys = undefined;
	if( mespawner.targetname == "casino_gamblingroom_inital_guys" )
	{
		inital_gr_guys = true;
		level.initial_gr_guys [ level.initial_gr_guys .size ] = dude;
	}
	goal = getent_or_struct_or_node( mespawner.target, "targetname" );
	
	spawners = [];
	things = getentarray( "gamblingroom_inital_guys_reinforcers", "targetname" );
	foreach( spawner in things )
	{
		if( !isspawner( spawner ) )
			continue;
		
		if( isdefined( spawner.script_noteworthy ) && spawner.script_noteworthy == noteworthy )
			spawners[ spawners.size ] = spawner;
		if( isdefined( spawner.script_noteworthy ) && spawner.script_noteworthy != noteworthy )
			continue;
		else
			spawners[ spawners.size ] = spawner;	
	}
	
	//spawners = SortByDistance( spawners, node.origin );
	
	while( 1 )
	{
		spawners = array_randomize( spawners );
		reinforcer = spawners[0];
		
		dude waittill( "death" );
		wait( randomintrange( 0, 4 ) );
		dude = reinforcer spawn_ai( true );
		if( isdefined( inital_gr_guys ) )
			level.initial_gr_guys [ level.initial_gr_guys .size ] = dude;
		
		dude.goalradius = goal.radius;
		dude set_goal_any( goal );
	}
}

casino_floor_ambush()
{	
	getent( "ambush_trig", "targetname" ) waittill( "trigger" );
	
	wait 3;
	
	foreach( hero in level.heroes )
	{
		hero.accuracy = 0.4;
	}
	
	spawners = GetEntArray( "casino_top_floor_ambush_spawners00", "targetname" );
	casino_gamblingroom03 = GetNodeArray( "casino_gamblingroom03", "targetname" ); 
	
	ambush_got_caught00 = GetEntArray( "ambush_got_caught00", "targetname" );

	foreach( spawner in spawners )
	{
		ai = spawner spawn_ai( true );
		ai.ignoreall = true;
		ai enable_cqbwalk();
		//ai enable_creepwalk();
		ai.goalradius = 100;
		ai thread wait_then_attack();
		ai.moveplaybackrate = 0.4;
		new_go_to = array_randomize( ambush_got_caught00 );
		ai setgoalentity(  new_go_to[ 0 ] );
		
		if( isdefined( spawner.script_noteworthy ) )
		{
			if( spawner.script_noteworthy == "flashlight" )
			{
//				if( isdefined( flashlightModel ) )
//				{
//					ai.flashlight = spawn( "script_model", ai.origin );
//					ai.flashlight setmodel( "com_flashlight_on" );
//					ai.flashlight linkto( ai, "tag_inhand", ( 0,0,0 ), ( 0,0,0 ) );
//					playfxontag( level._effect["flashlight_cheap"], ai.flashlight, "tag_light" );
//	
//					thread func_waittill_msg( level, "stealth_event_notify", ::deleteEnt, ai.flashlight );				
//				}
//				else
//				{
				ai thread attach_flashlight();
					
				
				if( isdefined( ai.target ) )
				{
					spot = ai get_target_ent();
						
					if( isdefined ( spot.targetname ) && spot.targetname == "flight_right" )
					{
						spot = getent( "flight_right", "targetname" );							
						ai setgoalentity(  spot );
					}
					else
						spot = getent( "flight_left", "targetname" );
						ai setgoalentity(  spot );
				}
			}
		}
		//walkeroverride = "active_patrolwalk_v1";	
		//thread casino_walkers_script( spawner, walkeroverride );
	}	

	thread generic_attack_func();
	
	waittill_any_timeout(  randomfloatrange( 26.1, 26.7), "player_attacked_cas_ambush" ); // "trigger", "timeout"
	
	flag_set ( "player_attacked_cas_ambush" );
	
	level.ninja.ignoreall = false;
	level.wounded_ai.ignoreall = false;
	level.leader.ignoreall = false;
	
	
	//	level.ninja disable_ai_color();
	//	level.wounded_ai disable_ai_color();
	//	level.leader disable_ai_color();
	
//	level.ninja AllowedStances( "stand" );
//	level.wounded_ai AllowedStances( "stand" );
//	level.leader AllowedStances( "stand" );
	
//	spots = getstructarray( "casino_bottom_retreat_spots", "targetname" );
//	array = GetAIArray( "axis" );
//	foreach( ai in array )
//	{
//		ai thread casino_floor_retreaters( spots[0], true );
//	}	
}

generic_attack_func()
{
	while( 1 )
	{
		if( level.player AttackButtonPressed () ) 
		{
			flag_set ( "player_attacked_cas_ambush" );
			break;
		}
		wait 0.1;
	}
}

wait_then_attack()
{
	self endon( "death" );
	self disable_arrivals();
	self disable_exits();
	
	
	flag_wait( "player_attacked_cas_ambush" );
	self.goalradius = 100;
	self.moveplaybackrate = 1;
	self disable_cqbwalk();	
	location = spawn( "script_origin", self.origin ); // need to delete this location.
	location.origin = location.origin + ( 0, 0, 30 );
	self setgoalentity( location );
	waitframe();
	location delete();	
	
	// play random get caught off guard anim
	wait RandomfloatRange( 0.2, 0.3 );
	self disable_arrivals();
	self disable_exits();
	
	self.ignoreall = false;
	self.goalradius = 1500;

//	wait RandomIntRange( 2, 3 );
	
	vol_fight = getent( "ambush_scatter_center", "targetname" );
	self set_goal_volume( vol_fight );  
}

casino_gamblingroom_sandstorm_walk()
{
	level endon( "casino_player_jumped" );
	
	trigger = getent( "casino_gr_current_trig", "targetname" );
	onoff = false;
	while(1)
	{
		if( self istouching( trigger ) && onoff == false )
		{
			self clear_run_anim();
			self set_run_anim( "sandstorm_walk", true );
			self pushplayer( true );
			onoff = true;
		}
		else if( !self istouching( trigger ) && onoff == true )
		{
			if( self == level.wounded_ai )
				self set_run_anim( "wounded_run_diaz" );
			else
				self clear_run_anim();
			self pushplayer( false );
			onoff = false;
		}
		wait(.1);
	}
}

casino_gamblingroom_sandstorm()
{
	
//	getent( "casino_floor_move_downstairs", "targetname" ) waittill( "trigger" );
//	
//	thread activate_exploder( "atrium_window_prematurebreak_01" );
//	
//	getent( "casino_floor_moveup02", "targetname" ) waittill( "trigger" );
//	
//	thread activate_exploder( "atrium_window_prematurebreak_02" );
//	
//	getent( "casino_gamblingroom_sandstorm_start", "targetname" ) waittill( "trigger" );
	
	thread activate_exploder( "atrium_window_01" );
	delaythread( 2, ::activate_exploder, "atrium_window_blowout_floor_runners" );
	delaythread( 2, ::casino_gamblingroom_sandstorm_current );
	//thread casino_gamblingroom_standstorm_luggage();
}

PLAYER_STRENGTH_MIN = 0;
PLAYER_STRENGTH_MAX = 5;
PUSH_STRENGTH_MIN = 5;
PUSH_STRENGTH_MAX = 15;
casino_gamblingroom_sandstorm_current()
{	
	trigger = getent( "casino_gr_current_trig", "targetname" );
	spot = getstruct( trigger.target, "targetname" );
	
	trigger_waittill_trigger( "casino_gr_current_trig" );	

	originalVisionSet = "lv_gamblingroom";//self.vision_set_transition_ent.vision_set;
	thread set_vision_set( "payback_heavy_fogonly", .5 );
	level.player allowsprint( false );
	
	angles = ( 0, 180, 0 );
	forward = AnglesToForward( angles );
	
	dirt = [];
	strings = [ "fullscreen_dirt_left", "fullscreen_dirt_right", "fullscreen_dirt_bottom_b", "fullscreen_dirt_bottom" ];
	thread casino_wind_screen_dirt( "player_out_of_current" );
//	foreach( thing in strings )
//	{	
//		time = randomfloatrange( .4, 1 );
//		a = create_client_overlay( thing, 0, level.player );
//		a thread fade_over_time( time, .4 );
//		//a delaythread( time, ::casino_gamblingroom_screen_dirt );
//		dirt[ dirt.size ] = a;
//	}
	
	strength = 0;
	player_strength = PLAYER_STRENGTH_MIN;
	push_strength = PUSH_STRENGTH_MIN;
	last_dist = undefined;
	while( 1 )
	{
		
		// is player isnt touching wait for him to retrigger the trigger
		if( !level.player istouching( trigger ) )
		{
			level notify( "player_out_of_current" );
			break;
		}
		distancee = distance2D( spot.origin , level.player.origin );
		if( !isdefined( last_dist ) )
			last_dist = distancee;
		
		// if player is getting closer to stairs increase push strength
		if( distancee < last_dist )
		{
			if( player_strength < PLAYER_STRENGTH_MAX )
				player_strength = player_strength + 1;
			
			if( push_strength < PUSH_STRENGTH_MAX )
				push_strength = push_strength + 10;
		}
		// if player is getting farther away from stairs decrease push strength
		else if( distancee > last_dist )
		{
			if( player_strength > PLAYER_STRENGTH_MIN )
				player_strength = player_strength - 1;
			
			if( push_strength > PUSH_STRENGTH_MIN )
				push_strength = push_strength - 10;
		}
			
		last_dist = distancee;
		
		// see if the player is walking into wind or away from it
		pvel = level.player GetVelocity();

		if( ( pvel[0] > 0 && pvel[1] <= 0 ) || 
		 	( pvel[0] >= 0 && pvel[1] > 0 ) )
			strength = player_strength;
		else
			strength = push_strength;
		
		earthquake( 0.07, .1, level.player.origin, 999 );
		if( cointoss() )
			thread set_blur( randomfloatrange( .5, 1 ), .1 );
		//level.player SetVelocity( forward * strength );
		
		println( "pstrengh : " + player_strength );
		println( "cstrengh : " + push_strength );
		
		wait( .1 );
	}
	
	level notify( "player_out_of_current" );
	foreach( thing in dirt )
		thing thread fade_over_time( 0, .5 );
	
	thread set_blur( 0, .1 );
	thread set_vision_set( originalVisionSet, .5 );
	level.player allowsprint( true );
	
	thread casino_gamblingroom_sandstorm_current();
}

casino_wind_screen_dirt( ender )
{
	
	array = [];
	array[ array.size ] = [ "fullscreen_dirt_left", -100, 5 ];
	array[ array.size ] = [ "fullscreen_dirt_right", -200, 15 ];

	scale = 1.5;
	huds  = [];
	foreach ( effect in array )
	{
		hud = NewHudElem();
		hud SetShader( effect[ 0 ], int( 640 * scale ), int( 480 * scale ) );
		hud.horzAlign = "fullscreen";
		hud.vertAlign = "fullscreen";
		hud.y += effect[ 1 ];

		hud FadeOverTime( .2 );
		hud.alpha = 1;
		hud thread casino_wind_screen_dirt_loop( ender );
		huds[ huds.size] = hud;
	}
	
	level waittill( ender );
	
	foreach( hud in huds )
	{
		num = randomfloatrange( .2, .6 );
		hud FadeOverTime( num );
		hud.alpha = 0;
		hud delaycall( num, ::destroy );
	}
	
}

casino_wind_screen_dirt_loop( ender )
{
	level endon( ender );
	
	while( 1 )
	{
		num = randomfloatrange( .2, .4 );
		self FadeOverTime( num );
		self.alpha = randomfloatrange( .5, 1 );
		wait( num );
	}
}

casino_gamblingroom_standstorm_luggage()
{
	wait( 3 );
	
	lug = getent( "casino_gr_luggage", "targetname" );
	lug PhysicsLaunchClient( lug.origin + ( 2,0,2 ), ( -99999, 0, 5000 ) );
	//wait( .5 );
	//playfx( level._effect["bar_box_exp"], lug.origin );
}

casino_floor_stair1_runners()
{
	self endon( "death" );
	
	self waittill( "goal" );
	self.ignoreme = false;
	self.ignoreall = false;
}

casino_gamblingroom_fake_flashlights()
{
	startMAX = 65;
	startMIN = -65;
	
	fspot = spawn_tag_origin();
	fspot.origin = self.origin;
	fspot.angles = self.angles;
	PlayFXOnTag( level._effect[ "flashlight_gamblingroom" ], fspot, "tag_origin" );
	
	origin_angles = fspot.angles;
	
	neg = false;
	if( cointoss() )
	{
		startMax = startMax * -1;
		startMin = startMin* -1;
		neg = true;		
	}
	
	moveTime = randomfloatrange( 5, 7 );

	opp = false;
	
	rotAngles = [];
	
	while(1)
	{
		
		if( opp == true )
		{
			rotAngles[ "x" ] = rotAngles[ "x" ] * -1;
			rotAngles[ "y" ] = rotAngles[ "y" ] * -1;
			rotAngles[ "z" ] = rotAngles[ "z" ] * -1;
		}
		else
		{
			greater = 0;
			lesser = 0;
			if( startMax > startMin )
			{
				greater = startMax;
				lesser = startMin;
			}
			else
			{
				greater = startMin;
				lesser = startMax;				
			}
			
			rotAngles[ "x" ] = randomfloatrange( lesser, greater );
			rotAngles[ "y" ] = randomfloatrange( lesser, greater );
			rotAngles[ "z" ] = randomfloatrange( lesser, greater );			
		}
					
		newspot = fspot.angles + ( rotAngles[ "x" ], rotAngles[ "y" ], rotAngles[ "z" ] );
		
		fspot rotateto( newspot, moveTime, 0, moveTime/2 );
		wait( moveTime );
		
		// move back to original angles
		fspot rotateto( origin_angles, moveTime, moveTime/2, 0 );
		wait( moveTime );
		
		if( opp == false )
			opp = true;
		
		if( neg == true )
		{
			num = startMin * -1;
		}
	}
}

casino_floor_sequence_part2()
{
	gate = getent( "casino_floor_gate", "targetname" );
	level.casino_floor_gate = gate;
	spots = getentarray( gate.target, "targetname" );
	foreach( spot in spots )
	{
		if( spot.script_noteworthy == "top" )
			gate.top = spot;
		else
			gate.bot = spot;
	}
	
//	thread move_to_node_heroes( "casino_gamblingroom07" );
	trigger_waittill_trigger( "casino_gamblingroom_second_stairs_upfront" );
	
	wait 1;
	
	add_wait( ::get_living_ai_waittill_dead_or_dying, "casino_gamblingroom_second_stairs_spawners01", "targetname", 3 );
	do_wait_any();
	
	//activate_trigger( "casino_gamblingroom_bottom_dudes_2_trig", "targetname" );
	//trigger_waittill_trigger( "casino_gamblingroom_bottom_dudes_2_trig" );
	
	thread move_to_node_heroes( "casino_gamblingroom08" );
	
	trigger_waittill_trigger( "casino_gamblingroom_bottom_start" );
	
	wait 1;
	
//	trigger = getent( "casino_gamblingroom_bottom_reinforcers_trig_1", "targetname" );
//	add_wait( ::get_living_ai_waittill_dead_or_dying, "casino_gamblingroom_second_stairs_spawners01", "targetname", 2 );
	add_wait( ::get_living_ai_waittill_dead_or_dying, "casino_gamblingroom_initial_bottomdudes", "targetname", 3 );
	//trigger add_wait( ::waittill_msg, "trigger" );
	do_wait_any();
	
	wait 1;
	
//	thread casino_floor_gate_dudes_2( trigger );
	
	get_living_ai_waittill_dead_or_dying( "casino_gamblingroom_bottom_ai", "script_noteworthy", undefined, true );
	
	thread move_to_node_heroes( "casino_gamblingroom09" );
	thread casino_gate_sequence();
	
	level waittill( "start_hotel_sequence" );
}

casino_gate_sequence()
{
	knode = getstruct( "casino_floor_gate_spot", "targetname" );
	
	goal = getstruct( knode.target, "targetname" );
	oldgoalradius = level.ninja.goalradius;
	level.ninja.goalradius = goal.radius;
	level.ninja setgoalpos( goal.origin );
	level.ninja disable_arrivals_and_exits( true );
	level.ninja waittill( "goal" );
	level.ninja.goalradius = oldgoalradius;
	level.ninja disable_arrivals_and_exits( false );
	
	level.ninja thread casino_gate_move_sequence();
	knode anim_reach_solo( level.ninja, "vegas_keegan_gate_approach" );
	
	wait( 8 );
	foreach( ai in level.heroes )
		if( ai != level.ninja )
			ai thread casino_gate_mantle( knode );
	
	knode anim_single_solo( level.ninja, "vegas_keegan_gate_approach" );
	level.ninja thread casino_keegan_gate_idle( knode );

	level notify( "start_hotel_sequence" );
	
	casino_gate_mantle_player( knode );
	
	flag_wait( "TRIGFLAG_casino_player_in_atrium" );
	
	knode notify( "stop_anim" );
	knode anim_single_solo( level.ninja, "vegas_mantle_under_gate" );
	level.casino_floor_gate moveto( level.casino_floor_gate.bot.origin, .5 );
	level.casino_floor_gate DisconnectPaths();
	
	level.ninja thread move_to_node( "casino_escalator01" );	
	
	foreach( ai in level.heroes )
		if( isdefined( ai.throughgate ) )
			ai.throughgate = undefined;
}

casino_gate_move_sequence()
{
	flag_wait( "TRACKFLAG_floor_open_gate" );
	
	level.casino_floor_gate moveto( level.casino_floor_gate.top.origin, 2, 0, .3 );
	
	flag_wait( "TRACKFLAG_floor_close_gate" );
	
	level.casino_floor_gate moveto( level.casino_floor_gate.bot.origin, 2, .3, 0 );
}

casino_keegan_gate_idle( node )
{
	level endon( "TRIGFLAG_casino_player_in_atrium" );
	
	while(1)
	{
		node thread anim_loop_solo( self, "vegas_keegan_gate_idle", "stop_anim" );
		wait( randomintrange( 6, 12 ) );
		node notify( "stop_anim" );
		node anim_single_solo( self, "vegas_keegan_gate_idle_twitch" );
	}
}

casino_gate_mantle( knode )
{
	
	if( self == level.wounded_ai )
	{
		while( !isdefined( level.leader.throughgate ) )
			wait( .05 );
	}
	else
		flag_wait( "TRACKFLAG_floor_gate_lifed" );
	
	knode anim_reach_solo( self, "vegas_mantle_under_gate" );
	knode thread anim_single_solo( self, "vegas_mantle_under_gate" );	
	if( self == level.leader )
		wait( 3.5 );
	else
		knode waittill( "vegas_mantle_under_gate" );
	self.throughgate = true;
	
	self thread move_to_node( "casino_escalator01" );
}

casino_gate_mantle_player( knode )
{
	array = [];
	array[0] = level.leader;
	array[1] = level.wounded_ai;
	while(1)
	{
		count = 0;	
		foreach( ai in array )
		{
			if( isdefined( ai.throughgate ) )
				count++;
		}
		if( count == 2 )
			break;
		
		wait(.05);
	}

	trigger_waittill_trigger( "casino_floor_gate_ptrig" );
	
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	arc = 15;

	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, arc, arc, arc, arc, 1 );
	
	level.player allowcrouch( false );
	level.player allowprone( false );
	level.player allowsprint( false );
	level.player disableweapons();
	
	knode anim_single_solo( player_rig, "vegas_mantle_under_gate" );
	
	waitframe();
	player_rig.origin = player_rig.origin + ( 0, 0, 25 );
	waitframe();
	level.player unlink();
	level.player allowcrouch( true );
	level.player allowprone( true );
	level.player allowsprint( true );
	level.player enableweapons();
	player_rig delete();
}

casino_floor_gate_dudes_2( stairTrig )
{
	trigger = getent( "casino_gamblingroom_bottom_dudes_2_trig", "targetname" );
	trigger endon( "trigger" );
	
	stairTrig waittill( "trigger" );
	
	array1 = get_living_ai_array( "casino_gamblingroom_gate_dudes", "targetname" );
	array2 = get_living_ai_array( "casino_gamblingroom_bottom_reinforcers_1", "targetname" );
	array = array_combine( array1, array2 );
	
	waittill_dead_or_dying( array, array.size - 3 );
	
	trigger notify( "trigger" );
}

casino_floor_tomb_dudes( name, ender )
{
	
	spawner = self.spawner;
	assert( isdefined( spawner ) );
	
	if( !isdefined( spawner.script_linkto ) )
		return;
	
	ai = self;
	
	if( isdefined( ender )  )
		getent( ender, "targetname" ) endon( "trigger" );
	
	ai endon( "death" );
	trigger_waittill_trigger( name );
	
	ai.ignoreall = true;
	ai.ignoreme = true;
	
	node = getnode( spawner.script_linkto, "script_linkname" );
	ai setgoalnode( node );
	ai waittill( "goal" );
	ai.ignoreall = false;
	ai.ignoreme = false;
}

casino_floor_runners()
{

	ai = self spawn_ai();
	
	ai endon( "death" );
		
	ai.baseaccuracy = .1;
	ai.health = 25;
	
	return ai;

}

casino_floor_topstairs_dudes( runners )
{
	
	thread kill_over_time( runners[1], undefined, 1, 1.5 );
	
	dude = undefined;
	while(1)
	{
		foreach( runner in runners )
		{
			if( !isalive( runner ) )
			{
				dude = runner;
				continue;	
			}
			
		}
		if( isdefined( dude ) )
			break;
	
		wait(.05);
	}
	
	if( isdefined( dude ) && isalive( dude ) )
		thread kill_over_time( runners[0], level.ninja, .3, .5 );
	
	level.ninja clear_ignore_everything();	
	level.ninja pushplayer( false );
}

casino_floor_farstair_dudes()
{
	spawners = getentarray( "casino_gamblingroom_farstair_dudes", "targetname" );
	runners = [];
	foreach( spawner in spawners )
	{
		ai = spawner spawn_ai();
		runners[ runners.size ] = ai;
		volumes = getentarray( "casino_gamblingroom_volume03", "targetname" );
		volume = undefined;
		if( !isdefined( spawner.script_noteworthy ) )
			volume = volumes[ randomint(1) ];

		else
		{
			foreach( volume in volumes )
			{
				if( spawner.script_noteworthy == volume.script_noteworthy )
			 	  	break;
			}
		}
		
		ai thread set_goal_any( volume, undefined, true );
		wait( randomfloatrange( .2, .4 ) );
	}	
}

hallway_wounded_ai_stumble()
{
//	self waittill( "goal" );
//	animm = "run_pain_stumble";
//	node = getnode( "casino_hallway_wounded_stumble", "targetname"  );
//	
//	self.PushPlayer = true;
//	node anim_reach_solo( self, animm );
//	node anim_single_solo( self, animm );
//	self.PushPlayer = false;
//	
//	self move_to_node( "casino_gamblingroom01" );
}

casino_floor_crate_kick()
{
	self endon( "death" );
	
	node = getnode( self.script_linkTo, "script_linkname" );
	crate = getent( node.target, "targetname" );
	crateTarg = getstruct( crate.target, "targetname" );
	
	blocker = getent( crate.script_linkTo, "script_linkname" );
	blocker linkto( crate );
	
	node anim_generic_reach( self, "doorkick_stand" );
	node thread anim_generic( self, "doorkick_stand" );
	self delaythread( 1, ::anim_stopanimscripted );
	
	wait( .5 );
	
	array = get_target_chain_array( crateTarg );
	foreach( thing in array )
	{
		if( !isdefined( thing.script_delay )  )
			time = .5;	
		else
			time = thing.script_delay;
	
		crate moveto( thing.origin, time );
		crate rotateto( thing.angles, time );
		wait( time );
	}
	
	blocker DisconnectPaths();
}

casino_floor_gate_dudes()
{
	self endon( "death" );
	
	node = getstruct( self.script_linkTo, "script_linkname" );
	self.animname = "gate_guy";
	
	last_guy = undefined;
	if( isdefined( self.script_parameters ) && self.script_parameters == "last_guy" )
	{
		last_guy = self;
		self thread magic_bullet_shield();
	}
	animm = "rununder_casino_gate";
	node anim_reach_solo( self, animm );
	node anim_single_solo( self, animm );
	
	if( isdefined( last_guy ) )
	{
		animm = "close_casino_gate";
		node = getstruct( "casino_floor_close_gate", "targetname" );
		node thread anim_single_solo( self, animm );
		wait(2.5);
		level.casino_floor_gate moveto( level.casino_floor_gate.bot.origin, .5 );
		wait(.5);
		self stopanimscripted();
		self stop_magic_bullet_shield();

	}
	
	node = getnode( self.target, "targetname" );
	
	oldradius = self.goalradius;
	self.goalradius = node.radius;
	self setgoalnode( node );
	self waittill( "goal" );
	self.goalradius = oldradius;
	
}

casino_floor_rappelers( name, goal )
{
//	side = player_touching_trig( "casino_gamblingroom_side_trigs" );
//	opp = get_opposite_side( side );
	
	spawners = getentarray( name, "targetname" );
	foreach( spawner in spawners )
	{
//		if( spawner.script_noteworthy != tolower( opp ) )
//			continue;
//		else
//		{
			if( isdefined( spawner.script_delay ) )
				wait( spawner.script_delay );
			
			ai = spawner spawn_ai();
			spot = getstruct( spawner.target, "targetname" );
			ai.animname = "rappeler";	
			ai.ignoreme = true;	
			ai thread actor_rappel( spot, "rail", goal );
//		}
	}
}

player_touching_trig( name )
{
	trigs = getentarray( name, "targetname" );
	foreach( trig in trigs )
	{
		if( level.player istouching( trig ) )
			return trig.script_noteworthy;
	}
}

get_opposite_side( side )
{	
	if( side == "left" )
		side = "Right";
	else
		side = "Left";
	
	return side;
}

//---------------------------------------------------------
// Casino Hotel
//---------------------------------------------------------

casino_hotel_sequence()
{
	autosave_by_name( "hotel" );
	
	//array_thread( level.heroes, ::move_to_node, "casino_escalator01" );
	
	//flag_wait( "casino_player_in_atrium" );
	
	//	array_spawn( getentarray( "casnio_escalator_dudes_1", "targetname" ) );
	
	trigger_waittill_trigger( "casino_atrium_trig_2" );
	
	array_thread( level.heroes, ::move_to_node, "casino_escalator02" );
	
	trigger_waittill_trigger( "casino_atrium_trig_2" );
	waitframe();
	array = get_living_ai_array( "casnio_escalator_dudes_1", "targetname" );
	add_wait(::waittill_dead_or_dying, array, array.size );
	getent( "casino_atrium_trig_3", "targetname" ) add_wait(::waittill_msg, "trigger");
	do_wait();
	
	//getent( "casion_er_pigeons_trigs", "script_noteworthy" ) notify( "trigger" );
	
	array_thread( level.heroes, ::move_to_node, "casino_escalator03" );
	
	trigger_waittill_trigger( "casino_atrium_trig_4" );
	waitframe();
	array = get_living_ai_array( "casino_hotel_baddies_1", "targetname" );
	add_wait(::waittill_dead_or_dying, array, array.size );
	getent( "casino_hotel_trig_2", "targetname" ) add_wait(::waittill_msg, "trigger");
	do_wait_any();
	
	array_thread( level.heroes, ::move_to_node, "casino_hotel01" );
//	drones = spawn_vehicles_from_targetname_and_drive( "casino_hotel_drones_1" );
//	foreach( drone in drones )
//		drone thread hotel_drones_1();
	
	waitframe();
	array = get_living_ai_array( "casino_hotel_baddies_2", "targetname" );
	add_wait(::waittill_dead_or_dying, array, array.size );
	getent( "casino_hotel_trig_3", "targetname" ) add_wait(::waittill_msg, "trigger");
	do_wait_any();
	
	array_thread( level.heroes, ::move_to_node, "casino_hotel03" );
	
	trigger_waittill_trigger( "casino_hotel_trig_4" );
}

casino_er_bird_event()
{
	bStructs = [];
	array = getentarray( "casino_er_interactive_birds", "targetname" );
	foreach( thing in array ) 
		bStructs[ bStructs.size ] = thing maps\interactive_models\_birds::birds_saveToStruct();

	trigger_waittill_trigger( "casino_atrium_trig_3" );
	
	foreach( struct in bStructs )
		struct maps\interactive_models\_birds::birds_loadFromStruct();
	
	trigs = getentarray( "casion_er_pigeons_trigs", "script_noteworthy" );
	foreach( thing in trigs )
		thing delaythread( randomfloatrange( .2, .3 ), ::send_notify, "trigger" );
}

casino_hotel_lights_swing()
{
	swingers = GetEntArray( "hotel_light_swinger", "script_noteworthy" );
	wait 0.2;
	foreach ( swinger in swingers )
	{
		// DoDamage directs the damage towards the origin, which means the lights don't swing.  Use notify instead.
		swinger notify( "damage", 60, undefined, (0,1,0), (0,0,0), "mod_explosive" );
	}
}

casino_atrium_kicker()
{
	knode = getnode( "casino_atrium_kicker_knode", "targetname" );
	thread doors_open( knode.target, true );
	knode anim_generic( self, "doorkick_stand" );
}

casino_hotel_runners( nums )
{
	wait( randomfloatrange( nums[0], nums[1] ) );
	
	struct = getstruct( self.target, "targetname" );
	
	ai = self spawn_ai( true );
	if( !isdefined( ai ) )
		return;
	
	ai disable_arrivals();
	ai disable_exits();
	ai ignore_everything();
	ai thread set_goal_any( struct, true );
	
}

casino_hotel_vendingmachine_knockdown()
{	
	
	node = getnode( "casino_hotel_machineknockover_spot", "targetname" );
	
	array = [];
	machine = spawn_anim_model( "vending_machine", node.origin );
	
	self.animname = "vending_dude";
	machine.animname = "vending_machine";
	
	array[0] = self;
	array[1] = machine;
	
	self.ignoreme = true;
	self thread waittill_dead_and_stop_anim( node, "vending_machine_sequence" );
	node thread anim_first_frame( array, "vending_machine_sequence" );
	
	self endon( "death" );
	
	trigger_waittill_trigger( "casino_hotel_trig_2" );
		
	node anim_single( array, "vending_machine_sequence" );
	
	self.ignoreme = false;
}

//---------------------------------------------------------
// Raid Room
//---------------------------------------------------------

casino_jumpout_sequence()
{	
	if( isdefined( level.jumpoutdone ) )
	{
		level.jumpoutdone = undefined;
		return;
	}
	
	level.player thread play_sound_on_entity( "vegas_bkr_theyretryingtocut" );
	
	SetSavedDvar( "player_sprintUnlimited", 1 );
	
	battlechatter_off( "axis" );
	battlechatter_off( "allies" );
	array_thread( level.heroes, ::ignore_everything );
	foreach( ai in level.heroes )
		ai SetCanDamage( false );

	level.jumpout_enemies = [];
	thread casino_hallway_checkpoint_system();
	
	trigger = getent( "casino_hotel_trig_5", "targetname" );
	thread func_waittill_msg( trigger, "trigger", ::casino_raid_end_hallway_guys );
	thread casino_raid_ambushers();
	
	rspot = getstruct( "casino_raid_sequence_spot", "targetname" );
	door = getent( "casino_hotel_door", "targetname" );
	attachements = getentarray( door.target, "targetname" );
	foreach( thing in attachements )
	{
		thing linkto( door );
		if( isdefined( thing.script_noteworthy ) )
			door.breakpiece = thing;
	}
	
	thread casino_jumpout_trenchrun();
	array_thread( level.heroes, ::casino_jumpout_code, rspot, door );
	
	flag_wait( "TRIGFLAG_player_in_hotel_room" );
	
	if( !flag( "TRACKFLAG_KEEGAN_JUMP" ) )
	{
		level.player allowsprint( false );
		flag_wait( "TRACKFLAG_KEEGAN_JUMP" );
		level.player allowsprint( true );
	}
		
	trigger_waittill_trigger( "casino_slide_start_trig" );
	flag_set( "FLAG_player_start_slide" );
	level notify( "player_not_looking_into_wind" );
	
	level.windspot delaythread( 2, ::stop_loop_sound_on_entity, "loop_wind_near" );
	level.windspot delaycall( 3, ::delete );
	
	foreach( ai in level.heroes )
		ai SetCanDamage( true );
	SetSavedDvar( "player_sprintUnlimited", 1 );
}

casino_jumpout_code( rspot, door )
{
	self disable_arrivals();
	self pushplayer( true );
	
	if( self == level.ninja )
	{
		//self enable_sprint();
		self.doslide = true;
		self forceuseweapon( "as50_keegan", "primary" );
		self set_run_anim( "sprint_1hand_gundown" );
		rspot anim_reach_solo( self, "vegas_raid_jump" );
		rspot thread anim_single_solo( self, "vegas_raid_jump" );
		self thread casino_heroes_tarp_anim( rspot );
		self delaythread( 1,  ::dialogue_queue, "vegas_kgn_inhere" );
		lines = [ "vegas_kgn_insideletsgo", "vegas_kgn_getinside_2", "vegas_kgn_comeonrook", "vegas_kgn_inhere" ];
		self delaythread( 3, ::play_nag_lines, lines, "vegas_kgn_inhere", "TRIGFLAG_player_in_hotel_room" );
		
		delaythread( 2.4, ::single_door_open, door, .4, undefined, 105 );
		delaythread( 2.85, ::single_door_open, door, .8, "none", -10, 0, .2 );
		
		wait( 5 );
		
		trigger = getent( "casino_raidroom_wind_trig", "targetname" );
		if( !level.player player_looking_at( trigger.origin  + ( -20, 0, 0 ) ) )
		{
			rspot anim_set_rate_single( self, "vegas_raid_jump", 0 );
			while(1)
			{
				if( level.player player_looking_at( trigger.origin + ( -20, 0, 0 ) ) )
					break;
				if( flag( "TRIGFLAG_player_in_hotel_room" ) )
					break;
				
				wait(.05);
			}
			rspot anim_set_rate_single( self, "vegas_raid_jump", 1 );
		}
		
		self delaythread( .5,  ::dialogue_queue, "vegas_kgn_windowsgo" );
		level.baker_glight delaythread( 1.2,  ::dialogue_queue, "vegas_diz_areyoukiddingme_2" );
		
		glassPanel = getent( "casino_raidroom_glass", "targetname" );
		level.windspot = spawn( "script_origin", glassPanel.origin + (0, -500, 0) );
		level.windspot delaythread( 1.3, ::play_loop_sound_on_entity, "loop_wind_near" );
		//rspot delaythread( 1.3, ::anim_set_rate_single, self, "vegas_raid_jump", .6 );
		delaythread( 1.3, ::play_sound_in_space, "glass_pane_blowout", glassPanel.origin );
		delaythread( 1.3, ::deleteEnt, glassPanel );
		delaythread( 1.3, ::activate_exploder, "raidroom_dust_enter" );
		glassSpot = getstruct( "raidroom_glass_spot", "targetname" );
		glass = spawn_anim_model( "window", glassSpot.origin );
		glassSpot anim_first_frame_solo( glass, "raid_window_shatter" );
		glass hide();
		glassSpot delaythread( .7, ::anim_single_solo, glass, "raid_window_shatter" );
		glass delaycall( .35, ::show );
		delaythread( 1.3, ::casino_raidroom_wind );
		//delaythread( 1.3, ::casino_raidroom_wind_phys );
		delaythread( 1.3, ::activate_exploder, "raidroom_paper_vortex" );
	
		count = 3;
		for( i=0; i<count; i++ )
		{
			self Shoot();
			wait( randomfloatrange( .2, .4 ) );
		}
		
		//self disable_sprint();
		self clear_run_anim();
		
		wait( 1.3 );
		
		starttime = gettime();
		timeout = 2500;
		if( !flag( "FLAG_player_start_slide" ) )
		{
			rspot anim_set_rate_single( self, "vegas_raid_jump", 0 );
			while( !flag( "FLAG_player_start_slide" ) )
			{
				if( gettime() - starttime >= timeout )
					break;
				wait(.05);
			}
			rspot anim_set_rate_single( self, "vegas_raid_jump", 1 );
		}
		
	}
	else
	{
		
		self thread casino_heroes_tarp_anim( rspot );
//		self enable_sprint();
//		rspot anim_reach_solo( self, "vegas_raid_enter_jump2" );
//		rspot anim_single_solo( self, "vegas_raid_enter_jump2" );
//		self disable_sprint();
//		rspot anim_reach_solo( self, "vegas_raid_jump" );
//		if( !flag( "FLAG_player_start_slide" ) )
//		{
//			self.doslide = true;
//			rspot anim_single_solo( self, "vegas_raid_jump" );
//		}
	}
	
	self enable_arrivals();
	self pushplayer( false );
	
}

casino_jumpout_trenchrun()
{
	physobjects = getentarray( "hotel_hallway_trenchrun_phys_obj", "targetname" );
	level.objectforce = [];
	level.objectforce[ "ac_prs_imp_com_lamp_ornate_off" ] = 400;
	level.objectforce[ "lv_luggagedestroyed_03_dust" ] = 100;
	level.objectforce[ "lv_luggagedestroyed_04_dust" ] = 100;
	
	fakeshooters = getstructarray( "hotel_hallway_trenchrun_fake_shooters", "targetname" );
	//array_thread( fakeshooters, ::trenchrun_fake_shooters );
	array_thread( getstructarray( "hotel_hallway_trenchrun_shot_obj", "targetname" ), ::trenchrun_objdamage, "bullet" );
	array_thread( physobjects, ::trenchrun_objdamage, "phys", undefined );
	
	skippedlast = false;
	starts = getstructarray( "hotel_hallway_trenchrun_lights_start", "targetname" );
	foreach( start in starts )
	{
		spot = start;
		time = randomfloatrange( .5, 1 );
		while(1)
		{
			//fakeshooter = trenchrun_get_fake_shooter( fakeshooters, spot );
			if( skippedlast == false )
			{
				if( cointoss() )
				{
					spot thread trenchrun_objdamage( "radius", time );
					skippedlast = false;
				}
				else
					skippedlast = true;
			}
			else
			{
				spot thread trenchrun_objdamage( "radius", time );	
				skippedlast = false;
			}
				
			if( !isdefined( spot.target ) )
				break;
			spot = getstruct( spot.target, "targetname" );
			time = time + randomfloatrange( .5, 1 );
			wait( .05 );
		}
	}
}

trenchrun_objdamage( type, time, objectforce )
{
	
	org = self.origin;
	
	starttime = undefined;
	timeout = undefined;
	if( isdefined( time ) )
	{
		starttime = gettime();
		timeout = time * 1000;
	}
	
	if( type == "phys" )
	{
		self endon( "damage" );
		self thread trenchrun_objdamage_phys_cancel();
	}
	while(1)
	{
		if( isdefined( time ) )
		{
			nowtime = gettime();
			if( nowtime - starttime >= timeout )
				break;
		}
		if( distance_2d_squared( level.player.origin, org ) < squared( 300 ) )
			break;

		wait( .05 );
	}
	
	if( cointoss() )
		wait( randomfloatrange( .1, .3 ) );
	
	switch( type )
	{
		case "radius" :
			RadiusDamage( org, 25, 999, 999 );
			break;
		case "bullet" :
			gun = trenchrun_get_gun();
			magicbullet( gun, org + ( 10, 0, 0 ), org );
			wait( .05 );
			magicbullet( gun, org + ( 10, 0, 0 ), org );
			break;
		case "phys" :
			assert( isdefined( level.objectforce[ self.model ] ) );
			self notify( "trenchrun_throw" );
			self PhysicsLaunchClient( org + ( 5, 0, 0 ), ( -25, 0, 0 ) * level.objectforce[ self.model ] ); // 500
			break;
	}
	if( isdefined( self.script_fxid ) )
		playfx( getfx( self.script_fxid ), org );
	
}

trenchrun_objdamage_phys_cancel()
{
	self endon( "trenchrun_throw" );
	
	self SetCanDamage( true );
	self waittill( "damage" );
	self PhysicsLaunchClient( self.origin, ( 0, 0, -25 ) );
}

trenchrun_get_fake_shooter( fakeshooters, spot )
{
	while( 1 )
	{
		foreach( shooter in fakeshooters )
		{
			success = BulletTracePassed( shooter.origin, spot.origin, false, undefined );
			if( success)
			{	
				gun = trenchrun_get_gun();
				magicbullet( gun, shooter.origin, spot.origin );
				return shooter;
			}
		}
		wait( .05 );
	}
}

trenchrun_get_gun()
{
	guns = [ "ak47", "kriss" ];
	guns = array_randomize( guns );
	return guns[ 0 ];
}

trenchrun_fake_shooters()
{
	level endon( "TRIGFLAG_player_in_hotel_room" );
	
	trigger = getent( "casino_hotel_trig_4", "targetname" );
	shootspot = getstruct( self.target, "targetname" );
	while( 1 )
	{
		wait( randomfloatrange( .5, 1 ) );
		if( cointoss() )
			continue;
		
		trace = bullettrace( self.origin, shootspot.origin, true );
		if( isdefined( trace[ "entity" ] ) && trace[ "entity" ] == level.player )
		   continue;
		
		if( level.player player_looking_at( trigger.origin ) )
			continue;
		
		// DO THIS WITH JESSES FX
//	if ( isdefined( trace[ "position" ] ) )
//		PlayFX( getfx( "body_splash_prague" ), trace[ "position" ] );
		
		if( cointoss() )
		{
			burst = randomintrange( 3, 5 );
			for( i=0; i<burst; i++ )
			{
				gun = trenchrun_get_gun();
				magicbullet( gun, self.origin, shootspot.origin );	
				wait( randomfloatrange( .1, .2 ) );
				
				trace = bullettrace( self.origin, shootspot.origin, true );
				if( isdefined( trace[ "entity" ] ) && trace[ "entity" ] == level.player )
				   continue;
				
				if( level.player player_looking_at( trigger.origin ) )
					continue;
			}
		}
		else
			magicbullet( "ak47", self.origin, shootspot.origin );
	}
}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

casino_raid_sequence()
{
	battlechatter_off( "axis" );
	battlechatter_off( "allies" );
	
	//music_play( "mus_vegas_outdoor_battle" );
	
	furniture = getentarray( "casino_raid_room_furniture", "targetname" );
	
	foreach( thing in furniture )
	{
		collision = getent( thing.target, "targetname" );
		collision linkto( thing );
		//collision delete();
		if( thing.script_noteworthy == "keegan" )
			level.ninja.armoire = thing;
		else
			level.leader.dresser = thing;
	}
	
	door = getent( "casino_hotel_door", "targetname" );
	attachements = getentarray( door.target, "targetname" );
	foreach( thing in attachements )
	{
		thing linkto( door );
		if( isdefined( thing.script_noteworthy ) )
			door.breakpiece = thing;
	}
	
	trigger = getent( "casino_hotel_trig_5", "targetname" );
	thread casino_raid_ambushers();
	thread func_waittill_msg( trigger, "trigger", ::casino_raid_end_hallway_guys );
	array_thread( level.heroes, ::set_ignoreall, true );
	array_thread( level.heroes, ::ignore_everything );
	
	rspot = getstruct( "casino_raid_sequence_spot", "targetname" );
	foreach( ai in level.heroes )
		ai thread casino_raid_sequence_enter( rspot, door );
	
	flag_wait( "FLAG_everyone_in_raid_room" );
	
	thread casino_raid_sequence_exit( rspot, door );
	
	level.leader delaythread( .3,  ::dialogue_queue, "vegas_bkr_everyonesincloseit" );
	//level.ninja delaythread( 1.7,  ::dialogue_queue, "vegas_kgn_closing" );
	delaythread( 1.3, ::single_door_open, door, 1, "none", -90 );
	door DisconnectPaths();
	
	flag_wait( "raid_exit_complete" );
}

casino_raid_sequence_enter( rspot, door )
{
	
	if( self == level.ninja )
	{	
		self enable_sprint();
		rspot anim_reach_solo( self, "vegas_raid_enter" );
		delaythread( 2.4, ::single_door_open, door, .4 );
		level.ninja delaythread( 1,  ::dialogue_queue, "vegas_kgn_inhere" );
		level.wounded_ai delaythread( 2,  ::dialogue_queue, "vegas_diz_imcmonimcmon" );
		level thread notify_delay( "start_raid_diazbaker_enter", 2 );
		rspot anim_single_solo( self, "vegas_raid_enter" );
		self.in_raidroom = true;
		self disable_sprint();
		thread casino_raid_waittime_everyone_in();
		lines = [ "vegas_kgn_insideletsgo", "vegas_kgn_getinside_2", "vegas_kgn_comeonrook", "vegas_kgn_inhere" ];
		level.ninja thread play_nag_lines( lines, "vegas_kgn_inhere", "TRIGFLAG_player_in_hotel_room" );
		rspot thread anim_loop_solo( self, "vegas_raid_enter_idle", "stop_anim" );
		
		flag_wait( "FLAG_everyone_in_raid_room" );
		
		rspot notify( "stop_anim" );
	}
	else
	{	
		self enable_sprint();
		rspot anim_reach_solo( self, "vegas_raid_enter" );	
		self disable_sprint();
		delaythread( 2.25, ::baker_inraidroom, self );	
		rspot anim_single_solo( self, "vegas_raid_enter" );	
		rspot anim_reach_solo( self, "vegas_raid_lookaround" );
		if( self == level.wounded_ai )
		{
			self pushplayer( true );
			self thread move_to_node( "casino_raidroom01" );
		}
		else
			rspot thread anim_first_frame_solo( self, "vegas_raid_lookaround" );
		
	}
}

casino_raid_sequence_exit( rspot, door )
{
	pmc1_vo = spawn_tag_origin();
	pmc1_vo.origin = ( -29336, -30936, 1464 );
	pmc1_vo.animname = "pmc";
	
	pmc2_vo = spawn_tag_origin();
	pmc2_vo.origin = ( -28896, -30928, 1464 );
	pmc2_vo.animname = "pmc";
	
	array = [ level.ninja, level.leader ];
	rspot thread anim_single( array, "vegas_raid_lookaround" );
	level.ninja delaythread( 2,  ::dialogue_queue, "vegas_kgn_weneedtimebarricade" );
	level.leader delaythread( 4.7,  ::dialogue_queue, "vegas_bkr_comeoncomeon" );
	pmc1_vo delaythread( 5.5, ::dialogue_queue, "vegas_pmc1_theywentinhere" );
	pmc2_vo delaythread( 6.6, ::dialogue_queue, "vegas_pmc2_getitopen" );
	level.leader delaythread( getanimlength( level.leader getanim( "vegas_raid_lookaround" ) ), ::move_to_node, "casino_raidroom01" );
	delaythread( 2.9, ::casino_armoir_move );
	//armoire linkto( level.ninja ); // 18.5
//	movetospot = getstruct( "casino_raid_armoir_moveto_spot", "targetname" );
//	level.ninja.armoire moveto( movetospot.origin, 2 );
//	level.ninja.armoire rotateto( movetospot.angles, 2 );
//	wait( 2 );
//	//armoire unlink(); // 20.5
//	wait( 1 );
//	level.leader.dresser linkto( level.leader ); //21.5
//	wait( 3 );
//	level.leader.dresser unlink(); //24.5
	
	level.leader.dresser delaythread( 3, ::linkto, level.leader );
	level.leader.dresser delaycall( 6, ::unlink );
	
	//rspot waittill( "vegas_raid_lookaround" );
	
	array = [ level.ninja.armoire, level.leader.dresser, door ];
	foreach( thing in array)
		thing delaythread( 11, ::casino_raid_furniture );
	
	delaythread( 13, ::casino_raid_bullets );
	delaythread( 14, ::deleteEnt, door.breakpiece );
	delaycall( 14, ::playfx, level._effect[ "raidroom_door_fx" ], door.breakpiece.origin + ( 0, 5, 0 ), ( 0, 1, 0 ) );
	
	//thread ninja_lookaround_anim( rspot );

	wait( 9.5 );
	//level.ninja setgoalpos( level.ninja.origin );
	level.leader thread dialogue_queue( "vegas_bkr_whatstheplanwere" );
	level.leader delaythread( 6,  ::dialogue_queue, "vegas_bkr_keegan_3" );
	wait( getanimlength( level.leader getanim( "vegas_raid_lookaround" )  ) - 8 );
	
	level.ninja delaythread( 0,  ::dialogue_queue, "vegas_kgn_wegottagetout" );
	level.wounded_ai delaythread( 2,  ::dialogue_queue, "vegas_diz_areyoukiddingme" );
	level.ninja delaythread( 3.5,  ::dialogue_queue, "vegas_kgn_wegottajumpits" );
	pmc1_vo delaythread( 5.5, ::dialogue_queue, "vegas_pmc1_theyvebarricadedin" );
	pmc2_vo delaythread( 10, ::dialogue_queue, "vegas_pmc2_getachargeon" );
	
	wait( 2 );
	
	level.ninja forceuseweapon( "as50_keegan", "primary" );
	
	count = 3;
	for( i=0; i<count; i++ )
	{
		level.ninja Shoot();
		wait( randomfloatrange( .2, .4 ) );
	}	
	
	rspot thread anim_single( level.heroes, "vegas_raid_jump" );
	array_thread( level.heroes, ::casino_heroes_tarp_anim, rspot );
	foreach( ai in level.heroes )
	{
		if( ai != level.ninja )
			ai thread casino_heroes_slide_hide( getanimlength( ai getanim( "vegas_raid_jump" )  ) );
	}

	level.leader delaythread( 4,  ::dialogue_queue, "vegas_bkr_diazrookyoureup" );
	level.wounded_ai delaythread( 6.5,  ::dialogue_queue, "vegas_diz_letsgo" );
	
	lines = [ "vegas_bkr_rookjump", "vegas_bkr_moveitwecant", "vegas_bkr_movenow" ];
	//level.leader thread play_nag_lines( lines, undefined, "FLAG_player_start_slide" );
	
	glasss = getent( "casino_raidroom_glass", "targetname" );
	fxspots = getstructarray( glasss.target, "targetname" );
	windspot = spawn( "script_origin", fxspots[0].origin + (0, -500, 0));	
	foreach( spot in fxspots  )
		delaycall( 2.8, ::playfx, level._effect[ "raidroom_window_glassbreak_fx" ], spot.origin, anglestoforward( spot.angles ) );
	windspot delaythread( 2.8, ::play_loop_sound_on_entity, "loop_wind_near" );
	delaythread( 2.8, ::play_sound_in_space, "glass_pane_blowout", glasss.origin );
	delaythread( 2.8, ::deleteEnt, glasss );
	delaythread( 2.8, ::activate_exploder, "raidroom_dust_enter" );
	delaythread( 2.8, ::casino_raidroom_wind );
	//delaythread( 2.8, ::casino_raidroom_wind_phys );
	delaythread( 2.5, ::activate_exploder, "raidroom_paper_vortex" );
	
	trigger_waittill_trigger( "casino_slide_start_trig" );
	level thread notify_delay( "raid_stop_bullet_spary", 4 );
	flag_set( "FLAG_player_start_slide" );
	player_slide();
	level notify( "delete_interior_sandstorm" );
	foreach( ai in level.heroes )
		ai show();
	array_thread( level.heroes, ::clear_ignore_everything );
	
	windspot stop_loop_sound_on_entity( "loop_wind_near" );
	windspot delete();
	
	flag_set( "raid_exit_complete" );
}

casino_heroes_tarp_anim( rspot )
{	
	if( isdefined( self.doslide ) )
	{
		self.doslide = undefined;
		rspot waittill( "vegas_raid_jump" );
//		animtime = getanimlength( self getanim( "vegas_raid_jump" ) );
//		wait( animtime );
	}
	
	struct = getstruct( "bottom_anim_entrance","targetname" );
	struct thread anim_first_frame_solo( self, "raid_getup" );
	self hide();
}

casino_raid_ambushers()
{
	volume = getent( "casino_hotel_baddies_ambushers_volume", "targetname" );
	ambushers = getentarray( "casino_hotel_baddies_ambushers", "targetname" );
	spawners = getentarray( "casino_hotel_baddies_ambushers_respawners", "targetname" );
	foreach( spawner in ambushers )
	{
		ai = spawner spawn_ai();
		level.jumpout_enemies[ level.jumpout_enemies.size ] = ai;
		nspawner = array_randomize( spawners );
		ai delaythread( .05, ::casino_raid_hallway_guys_respawn, nspawner[0], volume );
		ai.goalradius = 100;
		wait( randomfloatrange( .3, .8 ) );
	}
	//casino_raid_hallway_guys_respawn	
}

casino_raid_end_hallway_guys()
{
	volume = getent( "casino_hotel_baddies_flooders_volume", "targetname" );
	
	//level.baker_glight delaythread( 1.4,  ::dialogue_queue, "vegas_bkr_theyretryingtocut" );
	//level.player thread play_sound_on_entity( "vegas_bkr_theyretryingtocut" );
	
	spawners = getentarray( "casino_hotel_baddies_flooders", "targetname" );
	aiarray = casino_raid_end_hallway_guys_anims();
//	spawners = array_randomize( spawners );
//	foreach( spawner in spawners )
//	{
//		ai = spawner spawn_ai();
//		aiarray[ aiarray.size ] = ai;		
//		//ai.ignoreall = true;
//		ai.ignoreme = true;
//		ai thread casino_raid_increase_accuracy();
//		ai thread set_goal_any( volume );
//		ai thread waittill_death_and_respawn( spawner, volume, "FLAG_everyone_in_raid_room", 0, .2 );
//		
//		wait( randomfloatrange( .3, .5 ) );
//	}
	
	flag_wait( "FLAG_player_start_slide" );
	
	aiarray = get_living_ai_array( "casino_hotel_baddies_flooders", "targetname" );
	foreach( ai in aiarray )
		ai delete();
	
}

casino_raid_end_hallway_guys_anims()
{
	aiarray = [];
	nodes[ 0 ] = getnode( "raid_hallway_signal_node", "targetname" );
	//nodes[ 1 ] = getnode( "raid_hallway_signal_node2", "targetname" );
	runnodes = getnodearray( "raid_hallway_enemy_run_nodes", "targetname" );
	foreach( node in runnodes )
		nodes[ nodes.size ] = node;
	
	// need to do this because the script_linkname was getting passed to the AI
	foreach( node in nodes )
		node.spawner = getent( node.script_linkto, "script_linkname" );	

	volume = getent( "casino_hotel_baddies_flooders_volume", "targetname" );
	
	level.hallwayanimsdone = 0;
	wtimes = [ 2.2, .8, 0 ];
	foreach( i, node in nodes )
	{
		ai = node.spawner spawn_ai();
		level.jumpout_enemies[ level.jumpout_enemies.size ] = ai;
		goal = getnode( node.spawner.target, "targetname" );

		ai enable_sprint();
		ai delaythread( .05, ::casino_raid_hallway_guys_respawn, node.spawner, goal, "FLAG_end_hallway_anims_done" );
		ai delaythread( .05, ::casino_raid_end_hallway_anim_done, node, goal );
		aiarray[ aiarray.size ] = ai;

		node thread anim_reach_and_anim( ai, node.animation );
		ai thread waittill_dead_and_stop_anim( node, node.animation );
		wait( wtimes[i] );
	}
	
	return aiarray;
}

// each checkpoint is 256 units appart
// If the player doesn't get past a checkpoint in a certain amount of time, AI accurcay is turned up. If the player still hasnt reached
// the checkpoint in a larger amount of time and is still alive, start doing damage to the player.
// If the player passes a checkpoint reset accuracy 
// Important numbers is the player's X and the current checkpoint struct X

CONST_GOAL_MINTIME = 1300; // time player has to get to struct before AI accuracy is increased
CONST_GOALMAXTIME = 1800; // time player has to get to struct before script starts killing him
CONST_DEFAULT_DAMAGE_AMOUNT = 10;
CONST_DEFAULT_DAMAGE_TIME = .5;
CONST_DEFAULT_AI_ACCURACY = .1;
CONST_MAX_AI_ACCURACY = 10;

casino_hallway_checkpoint_system()
{
	level endon( "TRIGFLAG_player_in_hotel_room" );
	level.player endon( "death" );
	
	level.resetAccuracyGoal = undefined;
	level.stopKillGoal = undefined;
	level.playerDamageAmount = CONST_DEFAULT_DAMAGE_AMOUNT;	
	level.hallwayAiAccuracy = .1;
	
	structs = [];
	nstruct = getstruct( "jumpout_checkpoint_structs", "targetname" );

	while( 1 )
	{
		structs[ structs.size ] = nstruct;
		nstruct = getstruct( nstruct.target, "targetname" );
		if( !isdefined( nstruct.target ) )
			break;
		
		wait( .05 );
	}
	
	i = 1;
	foreach( stuct in structs )
	{
		thread casino_hallway_checkpoint_system_code( stuct, i );
		i++;	
	}
	
	end = structs[ structs.size - 1 ];
	
	
}

casino_hallway_checkpoint_system_code( start, i )
{	
	level.player endon( "death" );
	level endon( "TRIGFLAG_player_in_hotel_room" );
	
	end = getstruct( start.target, "targetname" );
	gmin = CONST_GOAL_MINTIME * i;
	gmax = CONST_GOALMAXTIME * i;
	
	didthis = undefined;
	starttime = gettime();
	while( 1 )
	{
		if( level.player.origin[0] <= end.origin[0] )
		{
			break;	
		}
		
		ctime = gettime() - starttime;
		if( ctime >= gmin  )
		{
			if( !isdefined( didthis ) )
			{
				level.resetAccuracyGoal = end;
				didthis = true; 
				//iprintln( "increasing ai accuracy" );
				childthread casino_hallway_checkpoint_system_aiAccuracy( end );
				// start raising AI accuracy
			}
			
			if( ctime >= gmax )
			{
				childthread casino_hallway_checkpoint_system_pkill( end );
				//iprintln( "doing player damage" );
				break;
				// start killing the player
			}
		}
		wait( .05 );
	}
	
	
}

casino_hallway_checkpoint_system_aiAccuracy( goal )
{
	level notify( "new_pkill_goal" );
	level endon( "new_pkill_goal" );
	
	while( level.player.origin[0] > goal.origin[0] )
	{
		if( level.hallwayAiAccuracy < CONST_MAX_AI_ACCURACY )
		{
			level.hallwayAiAccuracy = level.hallwayAiAccuracy + .3;
			
			level.jumpout_enemies = remove_dead_from_array( level.jumpout_enemies );
			foreach( ai in level.jumpout_enemies )
				ai set_baseaccuracy( level.hallwayAiAccuracy );
		}
		//iprintlnbold( level.hallwayAiAccuracy );
		wait( .5 );
	}
	//iprintln( "accuracy reset" );
	level.hallwayAiAccuracy = CONST_DEFAULT_AI_ACCURACY;
}

casino_hallway_checkpoint_system_pkill( goal )
{
	level notify( "new_pkill_goal" );
	level endon( "new_pkill_goal" );
	
	while( level.player.origin[0] > goal.origin[0] )
	{
		frontback = 50;
		if( cointoss() )
			frontback = -50;
		
		level.player dodamage( randomintrange( int(level.playerDamageAmount/2 ), level.playerDamageAmount ), level.player.origin + ( frontback, randomintrange( -25, 25 ), 0 ) );
		level.playerDamageAmount = level.playerDamageAmount + 4;
		wait( randomfloatrange( .1, .3 ) );
	}

	level.playerDamageAmount = CONST_DEFAULT_DAMAGE_AMOUNT;
	level.playerDamageTime = CONST_DEFAULT_DAMAGE_TIME;
}

casino_raid_hallway_guys_respawn( spawner, goal, flagwait )
{
	level endon( "FLAG_player_start_slide" );
	
	ai = self;
	while( 1 )
	{
		//ai thread set_goal_any( volume );
		ai set_baseaccuracy( level.hallwayAiAccuracy );
		ai disable_long_death();
		ai waittill_any( "death", "dying" );
		if( isdefined( flagwait ) )
			flag_wait( flagwait );
		
		wait( randomfloatrange( .05, .2 ) );
		
		ai = spawner spawn_ai();
		level.jumpout_enemies[ level.jumpout_enemies.size ] = ai;
		
		if( isdefined( goal ) )
		{
			ai thread set_goal_any( goal );
			//ai set_forcegoal();
			if( isdefined( goal.radius ) )
				ai.goalradius = goal.radius;
		}
	}
}

casino_raid_end_hallway_anim_done( node, goal )
{	
	level endon( "FLAG_player_start_slide" );
	
	self add_wait( ::waittill_msg, "death" );
	node add_wait( ::waittill_msg, node.animation );
	do_wait_any();
	level.hallwayanimsdone++;

	if( level.hallwayanimsdone == 3 )
	{
		flag_set( "FLAG_end_hallway_anims_done" );
		level.hallwayanimsdone = undefined;
	}

	if( isdefined( goal ) )
	{
		self.goalradius = goal.radius;
		//self set_forcegoal();
		self setgoalnode( goal );
	}
}

casino_raid_waittime_everyone_in()
{
	while(1)
	{
		count = 0;
		foreach( ai in level.heroes )
		{
			if( isdefined( ai.in_raidroom ) )
				count++;
		}
		if( count == 3 )
			break;
		
		wait( .05 );
	}

	flag_wait( "TRIGFLAG_player_in_hotel_room" );
	flag_set( "FLAG_everyone_in_raid_room" );
}

baker_inraidroom( guy )
{
	guy.in_raidroom = true;
}

play_nag_lines( lines, lastline, endflag )
{

	if( !isdefined( lastline ) )
		lastLine = "";
	dline = "";
	while( !flag( endflag ) )
	{
		while(1)
		{
			dline = lines[ randomint( lines.size ) ];
			if( dline != lastLine )
				break;
		}
		self dialogue_queue( dline );
		wait( randomfloatrange( 1, 1.5 ) );
		lastLine = dline;
	}
}

casino_armoir_move()
{
	movetospot = getstruct( "casino_raid_armoir_moveto_spot", "targetname" );
	self.armoire moveto( movetospot.origin, 2 );
	self.armoire rotateto( movetospot.angles, 2 );	
}

casino_raid_bullets()
{
	level endon( "raid_stop_bullet_spary" );
	start = getstruct( "casino_raid_bullet_spot", "targetname" );
	spots = getstructarray( start.target, "targetname" );
	
	while( 1 )
	{
		spots = array_randomize( spots );
		MagicBullet( "ak47", start.origin, spots[0].origin + ( randomintrange( 0, 20 ), randomintrange( 0, 20 ), randomintrange( 0, 20 ) ) );
		wait( randomfloatrange( .1, .4 ) );
	}
}

raid_lookaround_anim( rspot )
{
	node = getnode( "raidroom_lookaround_spot", "targetname" );
	node anim_reach_solo( self, "combatwalk_F_spin" );
	node thread anim_single_solo( self, "combatwalk_F_spin" );
	
	waitframe();
	node anim_set_rate_single( self, "combatwalk_F_spin", 1.5 );
	node waittill( "combatwalk_F_spin" );
}

casino_raid_furniture()
{
	//thread casino_raid_damage_dresser();
	
	orgAngles = self.angles;
	while( !flag( "raid_exit_complete" ) )
	{
		rotangles = ( 0,0,0 );
		if( self == level.ninja.armoire || self == level.leader.dresser )
			rotangles = ( randomintrange( 0, 5 ), randomintrange( 0, 5 ), randomintrange( 0, 5 ) );
		else
			rotangles = ( 0, randomintrange( 0, 5 ), 0 );
						 
		movetime = randomfloatrange( .1, .3 );
		self rotateto( self.angles + rotangles, movetime );
		wait( movetime );
		self rotateto( orgAngles, movetime );

		wait( randomfloatrange( .05, .8 ) + movetime );
	}
	
	self delete();
}

casino_raid_damage_dresser()
{
	dresser = getent( "casino_raid_room_bullets_dresser", "targetname" );
	links = getentarray( dresser.target, "targetname" );
	damagetrig = undefined;
	foreach( link in links )
	{
		if( link.classname == "trigger_multiple" )
			damagetrig = link;
		else
			link linkto( dresser );
	}
	
	damagetrig SetCanDamage( true );
	organgles = dresser.angles;
	while( !flag( "raid_exit_complete" ) )
	{
		damagetrig waittill( "damage" );
		movetime = randomfloatrange( .1, .3 );
		rotangles = ( randomintrange( 0, 5 ), 0, 0 );
		
		dresser rotateto( self.angles + rotangles, movetime );
		wait( movetime );
		self rotateto( organgles, movetime );
		wait( movetime );
	}
}

casino_raidroom_wind()
{
	level endon( "delete_interior_sandstorm" );
	
	trigger = getent( "casino_raidroom_wind_trig", "targetname" );
	trigger_waittill_trigger( "casino_raidroom_wind_trig" );
	
	//originalVisionSet = self.vision_set_transition_ent.vision_set;
	//thread set_vision_set( "payback_heavy_fogonly", .5 );
	screendirt = false;
	
	while(1)
	{
		if( !level.player istouching( trigger ) )
			break;
		
		equake = 0.15;
		
		// check to see if the player is looking into the wind
		pangles = anglestoforward( level.player.angles );
		if( ( pangles[0] <= 0 && pangles[1] <= 0 ) || ( pangles[0] >= 0 && pangles[1] <= 0 ) )
		{
			setblur( randomfloatrange( .3, 1 ), .1 );
			if( screendirt == false )
			{	
				screendirt = true;
				thread casino_wind_screen_dirt( "player_not_looking_into_wind" );
			}			
		}
		else
		{
			equake = 0.10;
			level notify( "player_not_looking_into_wind" );
			screendirt = false;
		}
		
		earthquake( equake, .1, level.player.origin, 9999 );
		wait( .1 );
	}
	
	thread set_blur( 0, .1 );
	//thread set_vision_set( originalVisionSet, .5 );
	level notify( "player_out_of_current" );
	thread casino_raidroom_wind();
}

casino_raidroom_wind_phys()
{
	ents = getentarray( "raid_room_phys_objects", "targetname" );
	luggage = [];
	angles = ( -1, 90, 0 );
	angles = anglestoforward( angles ) * 7000;
	foreach( thing in ents )
	{
		if( isdefined( thing.script_parameters ) && thing.script_parameters == "luggage" )
		{
			luggage[ luggage.size ] = thing;
			thing PhysicsLaunchClient( thing.origin + ( 0 ,0, 2 ), angles );
			//thing PhysicsLaunchClient();
			//thing RotateVelocity( angles, 12 );
			//thing MoveGravity( angles, 1 );
		}
	}
	
//	wait ( .1 );
//	center = ( -29174, -31702, 1390 );
//	while(1)
//	{
//		PhysicsExplosionSphere( center, 9999, 9999, 1);
//		wait( .05 );
//	}
}

casino_heroes_slide_hide( delayy )
{
	// this is so if they dont hit the hide if the player finishes his slide animation
	level endon( "FLAG_player_slide_complete" );
	wait( delayy );
	self hide();
}

casino_raid_breach( door )
{
	things = [ level.ninja.armoire, level.leader.dresser ];
	foreach( thing in things )
	{
		torigin = spawn( "script_model", thing.origin );
		torigin setmodel( "weapon_as50" );
		torigin hide();
		thing linkto( torigin );
		torigin PhysicsLaunchClient( torigin.origin + ( 0, -5, 0 ), ( 0, 999, 0 ) );
	}
	
	door delete();
}

#using_animtree("script_model" );
player_slide()
{
	thread maps\las_vegas_entrance::train_fall();

	ambientdrapes = getentarray( "player_slide_ambient_tarps", "targetname" );
	foreach( d in ambientdrapes )
	{
		d.animname = "tarp";
		d  UseAnimTree( #animtree );
		d thread anim_loop_solo( d, "vegas_ambient_tarp_idle", "stop_anim" );
	}
	
	hdrtexture = getent( "vegas_window_hdr", "targetname" );
	hdrtexture hide();
	
	snode = getstruct( "casino_player_slide_start", "targetname" );
	player_rig = spawn_anim_model( "player_rig", level.player.origin );
	player_rig hide();
	legs = spawn_anim_model( "player_legs", level.player.origin );
	tarp = getent( "player_slide_tarp", "targetname" );
	tarp UseAnimTree( #animtree );
	tarp.animname = "tarp";
	
	array = [ player_rig, legs ];

	cinematicmode_on();
	snode anim_first_frame_solo( player_rig, "casino_player_slide" );	
	
	time = .8; // if player is not looking at window, lerp slower
	pangles = anglestoforward( level.player.angles );
	if( ( pangles[0] <= 0 && pangles[1] <= 0 ) || ( pangles[0] >= 0 && pangles[1] <= 0 ) )
		time = 0.3;
	arc = 10;
	level.player PlayerLinkToBlend( player_rig, "tag_player", time );
	wait( time );
	level.player playerlinktodelta( player_rig, "tag_player", 1, arc, arc, arc, arc, arc, 1 );
	snode thread anim_single( array, "casino_player_slide" );
	
	thread casino_wind_screen_dirt( "TRACKFLAG_slide_stop_dirt_screen" );
	level.player delaycall( 6, ::LerpFOV, 100, 2.5 );
	delaythread( 2, ::flag_set, "FLAG_stop_feet_slide_fx" );
	//level.player delaythread( 3.7, ::play_loop_sound_on_entity, "loop_wind_near" );
	//level.player delaythread( 6.7, ::stop_loop_sound_on_entity, "loop_wind_near" );
	
	wait( .1 );
	player_rig show();
	thread player_slide_fx( snode, player_rig, legs );
	//waitframe();
	wait( 3.2 );
	earthquake( 0.30, .6, level.player.origin, 999 );
	SetBlur( 3, 0 );
	wait( .1 );
	setBlur( 0, .8 );
	
	snode waittill( "casino_player_slide" );
	//level.player ViewKick( 70, level.player.origin );
	//earthquake( .45, .5, level.player.origin, 999 );
	//SetBlur( 6, 0 );
	//wait( .2 );
	level.fadein = create_client_overlay( "black", 1, level.player );
	//level.fadein delaythread( 3, ::fade_over_time, 0, 2 );
	
	level.player thread play_sound_on_entity( "breathing_hurt_start" );
	
	level notify( "delete_interior_sandstorm" );
	array_call( level.heroes, ::show );
	if( isdefined( level.baker_glight ) ) 
		level.baker_glight delete();
	
	level.ninja forceuseweapon( "kriss", "primary" );
	
	//snode thread anim_loop_solo( tarp, "vegas_fall_tarp_idle", "stop_anim" );
	flag_set( "FLAG_player_slide_complete" );
	
	if( isdefined( level.jumpout_enemies ) )
	{
		level.jumpout_enemies = remove_dead_from_array( level.jumpout_enemies );
		foreach( guy in level.jumpout_enemies )
			guy delete();
	}
	
	cinematicmode_off();
	level.player unlink();
	player_rig delete();
	legs delete();
	SetBlur( 0, 0 );
	level.player lerpfov( 65, .05 );
	hdrtexture show();
	//music_stop();
}

player_slide_birds()
{
	bStructs = [];
	array = getentarray( "casino_slide_birds", "targetname" );
	foreach( thing in array ) 
		bStructs[ bStructs.size ] = thing maps\interactive_models\_birds::birds_saveToStruct();

	flag_wait( "FLAG_start_slide_birds" );
	
	foreach( struct in bStructs )
		struct maps\interactive_models\_birds::birds_loadFromStruct();
	
	trigs = getentarray( "casino_slide_pigeons", "script_noteworthy" );
	foreach( thing in trigs )
		thing notify( "trigger" );
}

player_slide_fx( start_node, player_rig, legs )
{
	tags = [ "j_ball_le", "j_ball_ri" ];
	foreach( tag in tags )
		thread player_slide_fx_legs( tag, legs );
	
	tags = [ "j_ringpalm_le", "j_ringpalm_ri" ];
	foreach( tag in tags )
		flagWaitThread( "TRACKFLAG_player_fall_grab", ::player_slide_fx_clap, player_rig, tag );
	
//	effect = getfx( "sand_dust_falling_runner" );
//	delaycall( 6, ::playfx, effect, ( -29192, -32448, 640 ) );
	
	// Hack to get the node into the center of the window
	offset = AnglesToForward( start_node.angles );
	offset *= -80;
	origin = start_node.origin + offset;
	
	// And hack to make it face forwards.  (Also tilt it down at 45 degrees, which I don't consider a hack.)
	forward = AnglesToRight( start_node.angles );
	forward += ( 0,0,-1 );
		
	// Glass that bounces down the slope as the player slides
	PlayFX( level._effect[ "raidroom_jump_slide_glass" ], origin, forward );
	wait 3;
	origin = level.player.origin;
	// Glass the showers around the player as he grabs the window frame
	PlayFX( level._effect[ "raidroom_jump_slide_glass" ], origin, forward );	
	wait 2.5;
	// Glass that rains down as the player falls
	PlayFX( level._effect[ "raidroom_jump_drop_glass" ], level.player.origin + (0,25,50) );
	
}

player_slide_fx_legs( tag, legs )
{	
	tags = [ "j_ball_le", "j_ball_ri" ];
	effect = getfx( "slide_boot_dust" );

	anglesfwd = anglestoforward( ( -45, 90, 0 ) );
	forward = AnglesToForward( ( 45, 270, 0 ) );
	while( !flag( "FLAG_stop_feet_slide_fx" ) )
	{				  
		origin = legs GetTagOrigin( tag ) + ( forward * 25 );
		
		playfx( effect, origin, anglesfwd );
		//wait( randomfloatrange( .05, .2 ) );
		wait( .05 );
	}
}

player_slide_fx_clap( player_rig, tag )
{
	anglesfwd = anglestoforward( ( -270, 0, -90 ) );
	if( tag == "j_ringpalm_ri" )
		wait( .13 );
	else
		wait( .09 );
	origin = player_rig GetTagOrigin( tag ) + ( -4, 0, 2 ); // + ( 0, randomintrange( 5, 10 ), 2 );
	effect = getfx( "vfx_dust_hand_clap" );
	playfx( effect, origin, anglesfwd );
}

casino_interior_sandstorm()
{
	spots = getstructarray( "casino_sandstorm_spots", "targetname" );
	fxspots = [];
	foreach( spot in spots )
	{
		thing = spawn_tag_origin();
		thing.fx = spot.script_fxid;
		thing.origin = spot.origin;
		thing.angles = spot.angles;
		
		playfxontag( getfx( thing.fx ), thing, "tag_origin" );
		
		fxspots[ fxspots.size ] = thing;
	}
	level waittill( "delete_interior_sandstorm" );

	foreach( spot in fxspots )
		spot delete();
	
	things = getentarray( "raidroom_dust_enter_exploder", "targetname" );
	foreach( thing in things )
		thing delete();
}

actor_rappel( type, ent, goal )
{
	self endon( "death" );
	
	assert( isdefined( type ) );
	
	self.animname = "rappeler";
	self thread actor_rappel_death();
	
	if( !isdefined( ent ) )
		ent = getent_or_struct_or_node( self.script_linkTo, "script_linkname" );
	
	if( type == "rail" )
	{
		if( !isdefined( ent.rope ) )
			ent.rope = spawn_anim_model( "rappel_rope_rail", ent.origin );
		rappelers[ 0 ] = self;
		rappelers[ 1] = ent.rope;
		//ent anim_reach_solo( self, "temp_rappel_over_rail" );
		ent thread anim_single( rappelers, "temp_rappel_over_rail" );
		waitframe();
		ent anim_set_rate( rappelers, "temp_rappel_over_rail", .8 );
		wait( 2.6 );
		foreach( thing in rappelers )
			thing stopanimscripted();
		
		ent thread anim_last_frame_solo( ent.rope, "temp_rappel_over_rail" );
	}
	
	if( !isdefined( goal ) )
		return;
	self thread set_goal_any( goal );
	
	self.ignoreme = false;
	
}

actor_rappel_death()
{
	self endon( "rappel_done" );
	
	self set_allowdeath( true );
	
	self waittill_any( "death", "damage" );
	self stopanimscripted();
	
	self kill();
	self startragdoll();
}

casino_walkers_script( spawner, walkOverride, flashlightModel, alertGoal )
{
	if( !isdefined( spawner ) )
		spawner = self.spawner;
	
//	if( isdefined( spawner.script_linkto ) )
//		alertGoal = getnode( spawner.script_linkto, "script_linkname" );
	
	if( !issentient( self ) )
		if( isdefined( spawner.script_delay ) )
			wait( spawner.script_delay );
	
	ai = undefined;
	if( isdefined( self ) && isalive( self ) )
		ai = self;
	else
		ai = spawner spawn_ai();
	
	ai endon( "death" );
	
	//ai ignore_everything();
	ai.ignoreme = true;
	ai.ignoreall = true;
	ai disable_arrivals();
	ai disable_exits();
	
	ai thread waittill_stealth_notify();
	ai thread waittill_stealth_notify_goloud();
	if( isdefined( alertGoal ) )
	{
	  thread func_waittill_msg( ai, "stealth_event_notify", ::set_goal_any, alertGoal );
	  thread func_waittill_msg( ai, "stealth_event_notify", ::set_forcegoal );
	  thread func_waittill_msg( ai, "stealth_event_notify", ::set_goalradius, 256 );
	}
	if( isdefined( walkOverride ) )
	{
		if( isdefined( ai.animname ) )
			ai set_run_anim( walkOverride );
		else
			ai set_generic_run_anim( walkOverride );
	
	}
	else
	{
		ai enable_cqbwalk();
		ai.moveplaybackrate = randomfloatrange( .8, 1.1 );
	}
	
	level endon( "stealth_event_notify" );
	
	if( isdefined( spawner.script_noteworthy ) )
	{
		if( spawner.script_noteworthy == "flashlight" )
		{
			if( isdefined( flashlightModel ) )
			{
				ai.flashlight = spawn( "script_model", ai.origin );
				ai.flashlight setmodel( "com_flashlight_on" );
				ai.flashlight linkto( ai, "tag_inhand", ( 0,0,0 ), ( 0,0,0 ) );
				playfxontag( level._effect["flashlight_cheap"], ai.flashlight, "tag_light" );

				thread func_waittill_msg( level, "stealth_event_notify", ::deleteEnt, ai.flashlight );				
			}
			else
			{
				ai thread attach_flashlight();
				//ai thread notify_delay( "flashlight_off", .05 );
			}
		}
	}
	
	spot = getent_or_struct_or_node( spawner.script_linkto, "script_linkname" );
	array = get_target_chain_array( spot );
	
	for( i=0; i<array.size; i++ )
	{
		spot = array[i];
		
		ai.goalradius = spot.radius;
		
		if( isdefined( spot.animation ) )
		{
			
			if( !isdefined( ai.animname ) )
			{
				
				if( spot.animation == "casino_kitchen_event_ambush" ) // special case
				{
					ai thread casino_kitchen_ambush( spawner, spot );
					return;
				}
				
				spot anim_generic_reach( ai, spot.animation );	
				spot anim_generic( ai, spot.animation );
				
			}
			else
			{
				spot anim_reach_solo( ai, spot.animation );
				spot anim_single_solo( ai, spot.animation );
			}
			
		}
		else
		{
			ai setgoalpos( spot.origin );
			ai waittill( "goal" );
		}
	}
	
	spawner.walkdone = true;
	
	//spot = array[ array.size-1 ];
	
	if( isdefined( spot.script_noteworthy ) && spot.script_noteworthy == "delete_me" )
		ai delete();
	else if( isdefined( spot.script_noteworthy ) && spot.script_noteworthy == "end_path" )
		ai notify( "reached_end_path" );
	else if( isdefined( spot.script_noteworthy ) && spot.script_noteworthy == "break_stealth" )
		level notify( "stealth_event_notify" );
	//else
		//spot thread anim_generic_loop( ai, "patrol_bored_idle", "stop_anim" );
}

casino_walkers_delete_flashlight()
{
	
}
