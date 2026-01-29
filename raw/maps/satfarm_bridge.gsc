#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

bridge_init()
{
	level.start_point = "bridge";
	
	thread rotate_big_sat();
}

bridge_main()
{
	kill_spawners_per_checkpoint( "bridge" );
	
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "bridge_" );
		
		// setup allies
		spawn_heroes_checkpoint( "bridge_" );
		
		if( !IsDefined( level.bridge_allies ) )
		{
			//spawn_bridge_allies( "bridge_" );
		}

		array_thread( level.allytanks, ::npc_tank_combat_init );
		
		thread rotate_big_sat();
		
		bridgeKill = spawn_vehicles_from_targetname( "bridge_kill" );
		foreach ( tank in bridgeKill )
		{
			if ( IsDefined( tank ) )
				tank Kill();
			
			wait RandomFloatRange( 0.1, .5 );
		}
	}
	else
	{
		//move heros to new path
		thread switch_node_on_flag( level.herotanks[0], "", "switch_bridge_path_hero0", "bridge_path_hero0" );
		thread switch_node_on_flag( level.herotanks[1], "", "switch_bridge_path_hero1", "bridge_path_hero1" );
		
		//move allies to new path
		//thread switch_node_on_flag( level.bridge_allies[1], "", "switch_bridge_path_ally1", "bridge_path_ally1" );
	}
	
	level.herotanks[0] thread tank_relative_speed( "a10_player_start", "bridge_end", 1000, 20, 10 );
	level.herotanks[1] thread tank_relative_speed( "a10_player_start", "bridge_end", 1000, 20, 10 );
	
	thread bridge_begin();
	
	flag_wait( "bridge_end" );
	
	maps\_spawner::killspawner( 301 );
	kill_vehicle_spawners_now( 301 );
}

spawn_bridge_allies( checkpoint_name )
{
	level.bridge_allies = [];
	
	array_spawn_function_noteworthy( "bridge_allies", ::npc_tank_combat_init );
	
	level.bridge_allies[ 1 ] = spawn_vehicle_from_targetname_and_drive( checkpoint_name + "ally1" );
	
	level.allytanks = array_combine( level.allytanks, level.bridge_allies );
}

bridge_begin()
{
	autosave_by_name( "bridge" );
		
	thread remove_bridge_clip_player_blocker();
	thread bridge_end_truck_setup();
	thread gaz_crushable_setup();
	
	wait .05;
	helis = spawn_vehicles_from_targetname_and_drive( "apache_ally_spawner2" );
	
	//flag_wait( "bridge_start_heli" );
	
	heli1 = spawn_vehicle_from_targetname_and_drive( "apache_ally1" );
	heli2 = spawn_vehicle_from_targetname_and_drive( "apache_ally2" );
	heli3 = spawn_vehicle_from_targetname_and_drive( "apache_ally3" );
	heli4 = spawn_vehicle_from_targetname_and_drive( "apache_ally4" );
	heli5 = spawn_vehicle_from_targetname_and_drive( "apache_ally5" );
	
	heli1 thread heli_missiles( "apache_ally1_target", "apache_ally1_fire" );
	heli2 thread heli_missiles( "apache_ally2_target", "apache_ally2_fire" );
	heli3 thread heli_missiles( "apache_ally3_target", "apache_ally3_fire" );
	heli4 thread heli_missiles( "apache_ally2_target", "apache_ally4_fire" );
	heli5 thread heli_missiles( "apache_ally3_target", "apache_ally5_fire" );
}

bridge_end_truck_setup()
{
	/*trucks = spawn_vehicles_from_targetname_and_drive( "bridge_end_trucks" );
	
	foreach( truck in trucks )
	{
		truck thread spawn_death_collision();
		truck thread gaz_damage_watcher();
	}
	*/
}

remove_bridge_clip_player_blocker()
{
	clip = GetEnt( "bridge_clip_player_blocker", "script_noteworthy" );
	clip Delete();
}

heli_missiles( fire_structs_name, flag_name )
{
	structarray = getstructarray( fire_structs_name, "targetname" );
	
	flag_wait( flag_name );
	
	self SetVehWeapon( "missile_attackheli" );
	
	self thread handle_missile( "tag_flash_11", (0, 15, 0),  structarray[0] );
	//attractor1 =  Missile_CreateAttractorOrigin( structarray[0].origin, 1000, 10000 );
	
	wait RandomFloatRange( .15, 1.0 );
	
	self thread handle_missile( "tag_flash_2", (0, -15, 0), structarray[1] );
	//attractor2 =  Missile_CreateAttractorOrigin( structarray[1].origin, 1000, 10000 );
	
	wait RandomFloatRange( .15, 1.0 );
	
	self thread handle_missile( "tag_flash_22", (0, -15, 0), structarray[2] );
	//attractor2 =  Missile_CreateAttractorOrigin( structarray[1].origin, 1000, 10000 );
	
	wait RandomFloatRange( .15, 1.0 );
	
	self thread handle_missile( "tag_flash_3", (0, -15, 0), structarray[3] );
	//attractor2 =  Missile_CreateAttractorOrigin( structarray[1].origin, 1000, 10000 );
	
	//wait 1;
	
	//Missile_DeleteAttractor( attractor1 );
	//Missile_DeleteAttractor( attractor2 );
		
	wait( RandomFloatRange( 3.0, 6.0 ) );
	
	self kill();
	
	wait( RandomFloatRange( .25, 3.0 ) );
	
	self notify( "crash_done" );//cause the heli to explode
	self notify( "in_air_explosion" );//stop the parent thread
	
}

handle_missile( tag, localoffset, destination_struct )
{	
	//setup a dummy model on the chopper at this tag
	//dummy = spawn("script_model",(0,0,0));
	//dummy SetModel("projectile_sidewinder_missile");
	//dummy LinkTo( self, tag, localoffset, (0,0,0));
	
//	missile Vehicle_Teleport(dummy.origin, dummy.angles);
//	missile show();
	target = spawn_tag_origin();
	target.origin = destination_struct.origin;
	
	self FireWeapon( tag, target );
	
	wait .05;
	
	target delete();
	
}