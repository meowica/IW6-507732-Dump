#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;

deck_victory_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//flag inits
	flag_init( "victory" );
	flag_init( "victory_music" );
	flag_init( "victory_music_stop" );
	flag_init( "rog_hit" );
	flag_init( "deck_victory_finished" );
	flag_init( "rog_reaction" );
	
	//precache
	PreCacheShellShock( "hijack_engine_explosion" );
	
	//init arrays/vars
	
	//hide ents
	level.deck_victory_finished = getent( "deck_victory_finished", "targetname" );
	level.deck_victory_finished hide_entity();	
	
	level.rog_victory_clouds = getent( "rog_victory_clouds", "targetname" );
	level.rog_victory_clouds hide_entity();
}

setup_deck_victory()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "deck_victory";
	setup_common();
	spawn_allies();
	thread maps\carrier_deck_combat2::ladder_blocker_guys(); //guys that block ladder on sparrow launcher platform so you can't climb up once you drop down.
	
	set_sun_post_heli_ride();
	
	flag_set( "slow_intro_finished" );
	level.player notify( "remove_sam_control" );
	thread maps\carrier_defend_sparrow::get_ships_in_position_for_defend_sparrow( true );
}

begin_deck_victory()
{
	//--use this to run your functions for an area or event.--	
	thread run_victory();
	thread rog_victory_clouds();
	flag_set( "victory_music" );
	
	wait 5;	
	reinforce_ally_heli_01 = thread spawn_vehicles_from_targetname_and_drive( "reinforce_ally_heli_01" );	
	reinforce_ally_jet_01 = thread spawn_vehicles_from_targetname_and_drive( "reinforce_ally_jet_01" );
	wait 6;
	thread destroy_all_enemy_vehicles();
	wait 1;
		
	run_rog();

	wait( 2.5 );
	
	flag_set( "clear_ladder" );
	ladder_blocker = getEnt( "ladder_blocker", "targetname" );
	ladder_blocker Delete();
		
	thread rog_carrier_clouds();
	thread rog_carrier_flashes();
	
	flag_wait( "deck_victory_finished" );	
	thread cleanup_vehicles();
	thread autosave_tactical();
}

run_victory()
{
	level.sparrow_deck_ally_1 = spawn_targetname( "sparrow_deck_ally_1", "targetname" );
	level.sparrow_deck_ally_2 = spawn_targetname( "sparrow_deck_ally_2", "targetname" );
	level.sparrow_deck_ally_3 = spawn_targetname( "sparrow_deck_ally_3", "targetname" );
	
	thread run_hesh();
	level.sparrow_deck_ally_1 thread run_sparrow_deck_ally_1();
	level.sparrow_deck_ally_2 thread run_sparrow_deck_ally_2();
	level.sparrow_deck_ally_3 thread run_sparrow_deck_ally_3();
	
	flag_set( "victory" );
}

run_hesh()
{
	deck_victory_hesh = getstruct( "deck_victory_hesh", "targetname" );
	level.hesh ForceTeleport( deck_victory_hesh.origin, deck_victory_hesh.angles );
		
	//wait until player exits sparrow
	level.player waittill( "remove_sam_control" );
	
	level.hesh gun_remove();
	ref = getstruct( "hesh_victory", "targetname" );
	ref anim_reach_solo( level.hesh, "plane_wave_on" );
	ref thread anim_single_solo( level.hesh, "plane_wave_on" );	
	level.hesh gun_recall();
	thread run_hesh_vo();
	
	
	flag_wait( "rog_reaction" );
	level.hesh StopAnimScripted();
	ref = getstruct( "hesh_react", "targetname" );
	ref anim_reach_solo( level.hesh, "corner_left_lookat_range_up" );
	ref thread anim_generic_loop( level.hesh, "corner_left_lookat_range_up", "stop_loop" );	
	
	flag_wait( "rog_hit" );
	level.hesh StopAnimScripted();
	level.hesh notify( "stop_loop" );	
	level.hesh gun_remove();
	level.hesh thread anim_single_solo( level.hesh, "unarmed_cowerstand_react" );	
	wait 3;
	level.hesh gun_recall();
	level.hesh StopAnimScripted();	
	
	node = getNode( "hesh_deck_tilt_start", "targetname" );
	level.hesh SetGoalNode( node );	
}

run_hesh_vo()
{
	//Hesh: That was a close call. Those birds should escort us to SatFarm
	level.hesh delayThread( 1, ::smart_dialogue, "carrier_hsh_thatwasaclose" );	

	flag_wait( "rog_hit" );	
	
	wait 1.5;
	
	//Hesh: SHIT!
	level.hesh smart_dialogue( "carrier_hsh_shit" );	
	
	wait 2;
	
	//Hesh: ODIN is operational!  
	level.hesh smart_dialogue( "carrier_hsh_odinisoperational" );	
	//Hesh: Come on, we have to move!
	level.hesh smart_dialogue( "carrier_hsh_comeonwehave" );
	//Hesh: We need to find Merrick!	
	level.hesh smart_dialogue( "carrier_hsh_weneedtofind" );
}

run_sparrow_deck_ally_1()
{
	self endon( "death" );	
	self.animname = "generic";
	self.goalradius = 16;
	self.ignoreme = true;
	self.ignoreall = true;
	
	flag_wait( "victory" );
	self gun_remove();
	self anim_single_solo( self, "london_police_jog_2_wave" );
	self thread anim_generic_loop( self, "london_police_wave_1", "stop_loop" );
	//Ally Soldier 1: There’s our birds!
	self thread smart_dialogue( "carrier_gs1_theresourbirds" );
	
	
	flag_wait( "rog_reaction" );	
	//Ally Soldier 1: Up in the sky!
	self thread smart_dialogue( "carrier_gs1_upinthesky" );
	wait 1;
	self StopAnimScripted();
	self notify( "stop_loop" );
	self gun_recall();
	self thread anim_generic_loop( self, "corner_left_lookat_range_up", "stop_loop" );

	flag_wait( "rog_hit" );
	self StopAnimScripted();
	self notify( "stop_loop" );
	self gun_remove();
	self anim_single_solo( self, "unarmed_cowerstand_react" );		
	self gun_recall();
	self StopAnimScripted();
	self SetGoalEntity( getent( "ally_tilt_run_goal", "targetname" ) );
}

run_sparrow_deck_ally_2()
{
	self endon( "death" );	
	self.animname = "generic";
	self.goalradius = 16;
	self.ignoreme = true;
	self.ignoreall = true;
	
	flag_wait( "victory" );
	wait RandomFloatRange( 0.1, 0.5 );
	self gun_remove();
	self thread anim_generic_loop( self, "london_civ_idle_wave", "stop_loop" );
	
	flag_wait( "rog_reaction" );
	self StopAnimScripted();
	self notify( "stop_loop" );
	self gun_recall();
	ref = getstruct( "sparrow_deck_ally_2_react", "targetname" );
	ref anim_reach_solo( self, "patrol_jog_look_up_once" );
	ref anim_single_solo( self, "patrol_jog_look_up_once" );
	goal = getstruct( self.target, "targetname" );
	self SetGoalPos( goal.origin );
}

run_sparrow_deck_ally_3()
{
	self endon( "death" );	
	self.animname = "generic";
	self.goalradius = 16;
	self.ignoreme = true;
	self.ignoreall = true;
	
	flag_wait( "victory" );
	wait RandomFloatRange( 0.1, 0.5 );
	self gun_remove();
	self thread anim_generic_loop( self, "london_civ_idle_wave", "stop_loop" );
	
	flag_wait( "rog_reaction" );
	//what the hell is that
	self delayThread( 3, ::smart_dialogue, "carrier_gs3_morezodiacsincoming" );
	wait 0.6;
	self StopAnimScripted();
	self notify( "stop_loop" );
	self gun_recall();
	ref = getstruct( "sparrow_deck_ally_3_react", "targetname" );
	ref anim_single_solo( self, "hunted_tunnel_guy1_lookup" );	
	wait 3;
	ref anim_single_solo( self, "hunted_tunnel_guy1_lookup" );	
	wait 2;
	ref anim_single_solo( self, "hunted_tunnel_guy1_lookup" );	
	
	flag_wait( "rog_hit" );
	wait RandomFloatRange( 0.1, 0.3 );
	self StopAnimScripted();
	self notify( "stop_loop" );	
	self gun_remove();
	self anim_single_solo( self, "unarmed_cowerstand_react" );	
	self gun_recall();
	self StopAnimScripted();
	self SetGoalEntity( getent( "ally_tilt_run_goal", "targetname" ) );	
}

//rod of god
run_rog()
{
	flag_set( "rog_reaction" );
	thread maps\_utility::vision_set_fog_changes( "carrier_rog", 10 );
	wait 2;
	
	rod_of_god_victory();
		
	flag_set( "rog_hit" );
	
	level.deck_victory_finished show_entity();
	
	delayThread( 2, ::rod_of_god_victory_vista );	
	delayThread( 7, ::rod_of_god_victory_vista_2 );
}

destroy_all_enemy_vehicles()
{
	vehicles = Vehicle_GetArray();
	foreach ( vehicle in vehicles )
	{
		if ( IsDefined( vehicle ) && IsAlive( vehicle ) && IsDefined( vehicle.script_team ) && vehicle.script_team == "axis" )
		{
			if ( IsDefined( vehicle.vehicletype ) && vehicle isHelicopter() )
			{	
				vehicle Delete();
//				vehicle kill();
			}
			else if ( IsDefined( vehicle.vehicletype ) && vehicle isAirplane() )
			{
				vehicle notify( "damage", 5000, level.player, (0,0,0), (0,0,0), "MOD_PROJECTILE" );
			}
		}		
	}	
}

cleanup_vehicles()
{
	vehicles = Vehicle_GetArray();
	foreach ( vehicle in vehicles )
	{
		if ( IsDefined( vehicle ) )
		{
			vehicle Delete();
		}
	}
}