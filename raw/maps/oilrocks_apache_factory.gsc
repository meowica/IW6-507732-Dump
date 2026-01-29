#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\oilrocks_apache_vo;


// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Apache Factory Attack
//			- Player learns how to use the minigun and the 2 missile types
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

start()
{
	// Set up Player Apache
	apache_player = spawn_apache_player( "apache_factory" );
	
	// Set up blackhawk ally
	blackhawk_ally = spawn_blackhawk_ally( "struct_blackhawk_ally_factory" );
	
	spawn_apache_allies("struct_apache_ally_attack_0");
	
	// Move ally air vehicles
	blackhawk_ally thread vehicle_paths( getstruct( "path_blackhawk_ally_factory", "script_noteworthy" ) );
	
	apache_ids = [ 1, 2 ];
	foreach ( id in apache_ids )
	{
		apache_ally = get_apache_ally( id );
		apache_ally thread vehicle_paths( getstruct( "path_apache_ally_attack_0" + id, "script_noteworthy" ) );
	}
}

main()
{
	thread apache_mission_vo_think( ::apache_mission_vo_factory );

	thread maps\oilrocks_apache_hints::apache_hints_factory();
	thread autosave_by_name();
//	thread apache_factory_player_health();
	thread apache_factory_player_pitch();
	thread apache_factory_enemies();
	thread apache_factory_allies_apache_think();
	thread apache_factory_ally_blackhawk_think();
	thread apache_factory_objective();
	
	flag_wait("FLAG_apache_factory_finished");
}

apache_factory_objective()
{
	//"Assault HVT's Position"
	Objective_Add( obj( "apache_factory" ), "active", &"OILROCKS_OBJ_APACHE_ATTACK" );
	Objective_Current( obj( "apache_factory" ) );
	
	obj_ent = get_obj_ent_hvt();
	Objective_Position( obj( "apache_factory" ), getstruct( "struct_obj_apache_factory", "targetname" ).origin );
}

apache_factory_player_pitch()
{
	apache_player = get_apache_player();
	apache_player endon( "death" );
	
	flag_wait( "FLAG_apache_factory_exit_canyon" );
	
	thread lerp_savedDvar( "vehHelicopterPitchOffset", apache_player.heli.pitch_offset_ground, 2.0 );
	
	flag_wait( "FLAG_apache_factory_hint_mg" );
	
	thread lerp_savedDvar( "vehHelicopterPitchOffset", apache_player.heli.pitch_offset_mid, 4.0 );
	
	flag_wait( "FLAG_apache_factory_player_close" );
	
	thread lerp_savedDvar( "vehHelicopterPitchOffset", apache_player.heli.pitch_offset_ground, 4.0 );
}

apache_factory_enemies()
{
	// Spawn Setup
	
	// Enemy gaz heading to factory
	vehicle_spawners_adjust_health_and_damage_targetname( "apache_factory_gaz_road" );
//	array_spawn_function_targetname( "apache_factory_gaz_road", ::add_as_apache_target_on_spawn );
	array_spawn_function_targetname( "apache_factory_gaz_road", ::vehicle_ai_turret_think, false, false, undefined, false );
	
	// Enemy zpu road to factory
	vehicle_spawners_adjust_health_and_damage_targetname( "apache_factory_zpu_road" );
//	array_spawn_function_targetname( "apache_factory_zpu_road", ::add_as_apache_target_on_spawn );
	array_spawn_function_targetname( "apache_factory_zpu_road", ::vehicle_zpu_think );
	
	// Enemy zpu factory
	vehicle_spawners_adjust_health_and_damage_targetname( "apache_factory_zpu" );
								 //   key 				    func 						    
	array_spawn_function_targetname( "apache_factory_zpu", ::add_as_apache_target_on_spawn );
	array_spawn_function_targetname( "apache_factory_zpu", ::vehicle_zpu_think );
	
	// Parked enemy hinds
								 //   key 				     func 								   
	array_spawn_function_targetname( "apache_factory_hind", ::apache_factory_hind_parked_on_spawn );
	array_spawn_function_targetname( "apache_factory_hind", ::apache_factory_hind_parked_on_death );
	array_spawn_function_targetname( "apache_factory_hind", ::earthquake_on_death );	// these hinds don't get there health adjusted so this needs to be called on them
	
	
								 //   key 					    func 							  
	array_spawn_function_targetname( "apache_factory_ai_roof", ::add_as_apache_target_on_spawn );
	array_spawn_function_targetname( "apache_factory_ai_roof", ::ai_record_spawn_pos );
	array_spawn_function_targetname( "apache_factory_ai_roof", ::apache_factory_ai_roof_on_spawn );
	
	// Set up enemies that matter for factory completion
	
								 //   key 					    func 						    
	array_spawn_function_targetname( "apache_factory_zpu"	 , ::apache_factory_enemy_on_death );
	array_spawn_function_targetname( "apache_factory_hind"	 , ::apache_factory_enemy_on_death );
	array_spawn_function_targetname( "apache_factory_ai_roof", ::apache_factory_enemy_on_death );
	
	// Prevent reliable command buffer overflow (was spawning too much in one frame)
	spawn_delay = 0.05;
	
	// Spawn Enemies
	array_target_add_delay = [];
	road_gaz			   = spawn_vehicles_from_targetname_and_drive( "apache_factory_gaz_road" );
	array_target_add_delay = array_combine( array_target_add_delay, road_gaz );
	wait spawn_delay;
	road_zpu			   = spawn_vehicles_from_targetname( "apache_factory_zpu_road" );
	array_target_add_delay = array_combine( array_target_add_delay, road_zpu );
	wait spawn_delay;
	factory_zpus		   = spawn_vehicles_from_targetname( "apache_factory_zpu" );
	array_target_add_delay = array_combine( array_target_add_delay, factory_zpus );
	wait spawn_delay;
	factory_hinds		   = spawn_vehicles_from_targetname( "apache_factory_hind" );
	array_target_add_delay = array_combine( array_target_add_delay, factory_hinds );
	
	road_vehicles	 = array_combine( road_gaz, road_zpu );
	factory_vehicles = array_combine( factory_hinds, factory_zpus );
	
	// Add the just spawned vehicles to the targeting system on a delay
	// relative to distance
	apache				   = get_apache_player();
	array_target_add_delay = SortByDistance( array_target_add_delay, apache.origin );
	foreach ( idx, veh in array_target_add_delay )
	{
		veh thread addAsApacheHudTarget( apache, 0.5 * idx );
	}
	
	flag_wait( "FLAG_apache_factory_player_close" );
	
	factory_ai = array_spawn_targetname( "apache_factory_ai_roof" );
	
	flag_wait_all( "FLAG_apache_factory_destroyed_ai", "FLAG_apache_factory_destroyed_vehicles" );
	
	flag_set( "FLAG_apache_factory_destroyed" );
	
	factory_ai		 = array_remove_undefined_dead_or_dying( factory_ai );
	factory_vehicles = array_remove_undefined_dead_or_dying( factory_vehicles );
	road_vehicles	 = array_remove_undefined_dead_or_dying( road_vehicles );
	
			  //   entities 	     process 	    var1    var2   
	array_thread( factory_ai	  , ::ai_clean_up, true	 , false );
	array_thread( factory_vehicles, ::ai_clean_up, false , false );
	array_thread( road_vehicles	  , ::ai_clean_up, false , false );
	
	// Clean up AI count tracking array
	level.apache_factory_enemy_counts = undefined;
}

apache_factory_hind_parked_on_spawn()
{
	self.alwaysRocketDeath = true;
	self.enableRocketDeath = true;
	
	take_off = IsDefined( self.script_noteworthy ) && IsSubStr( self.script_noteworthy, "apache_factory_hind_take_off" );
	
	if ( take_off )
	{
		self godon();
		
		flag_wait( "FLAG_apache_factory_allies_close" );
		
		if ( IsDefined( self.script_parameters ) )
			wait( Float( self.script_parameters ) );
		
		self.alwaysRocketDeath = undefined;
		self.enableRocketDeath = undefined;
		
		thread gopath( self );
		
		self godoff();
		
		self waittill( "death" );
		
		flag_set( "FLAG_apache_factory_hind_take_off_dead" );
	}
}

apache_factory_hind_parked_on_death()
{
	self waittill( "death" );
	
	if ( !IsDefined( self.alwaysRocketDeath ) || !self.alwaysRocketDeath || !IsDefined( self.enableRocketDeath ) || !self.enableRocketDeath )
	{
		// Find the closest loc in the opposite direction of the player.
		crash_locs = maps\_vehicle_code::get_unused_crash_locations();
		crash_locs = SortByDistance( crash_locs, self.origin );
		
		dist_sqrd_player_to_chopper = DistanceSquared( level.player.origin, self.origin );
		
		foreach ( loc in crash_locs )
		{
			dist_sqrd_player_to_loc = DistanceSquared( level.player.origin, loc.origin );
			
			if ( dist_sqrd_player_to_loc > dist_sqrd_player_to_chopper && DistanceSquared( self.origin, loc.origin ) < dist_sqrd_player_to_loc )
			{
				self.perferred_crash_location = loc;
				break;
			}
		}
	}
}

apache_factory_ai_roof_on_spawn()
{
	self endon( "death" );
	
	self.a.disablelongdeath = true;
	
	self waittill( "goal" );
	
	self set_fixednode_true();
	self thread enemy_infantry_rpg_only();
	self SetEngagementMaxDist( 4096, 5200 );
}

apache_factory_enemy_on_death()
{
	// Placeholder win condition
	if ( !IsDefined( level.apache_factory_enemy_counts ) )
	{
		level.apache_factory_enemy_counts = [];
	}
	
	key	  = undefined;
	flag  = undefined;
	count = undefined;
	
	if ( IsAI( self ) )
	{
		key	  = "ai";
		flag  = "FLAG_apache_factory_destroyed_ai";
		count = 2;
	}
	else
	{
		key	  = "vehicles";
		flag  = "FLAG_apache_factory_destroyed_vehicles";
		count = 1;
	}
	
	if ( !IsDefined( level.apache_factory_enemy_counts[ key ] ) )
	{
		level.apache_factory_enemy_counts[ key ] = 0;
	}
	
	level.apache_factory_enemy_counts[ key ]++;
	
	self waittill( "death" );
	
	// Sequence has ended already
	if ( !IsDefined( level.apache_factory_enemy_counts ) || !IsDefined( level.apache_factory_enemy_counts[ key ] ) )
		return;
	
	level.apache_factory_enemy_counts[ key ]--;
	
	if ( level.apache_factory_enemy_counts[ key ] == count )
	{
		flag_set( flag );
		
		level.apache_factory_enemy_counts[ key ] = undefined;
	}
}

apache_factory_allies_apache_think()
{
	flag_wait( "FLAG_apache_factory_destroyed" );
	
	// Move the ally apaches into positiont to guard the ally troop drop off
	apache_ids = [ 1, 2 ];
	foreach ( id in apache_ids )
	{
		apache_ally = get_apache_ally( id );
		
		path_starts = getstructarray( "apache_factory_ally_guard_path_starts_0" + id, "script_noteworthy" );
		path_start	= getClosest( apache_ally.origin, path_starts );
		
		apache_ally thread vehicle_paths( path_start );
	}
}

apache_factory_ally_blackhawk_think()
{
	flag_wait( "FLAG_apache_factory_destroyed" );
	
	// Send blackhawk into factory to drop off troops
	// This sets the factory finished flag to initialize the chase
	blackhawk = get_blackhawk_ally();
	blackhawk thread vehicle_paths( getstruct( "path_blackhawk_factory_drop_off", "script_noteworthy" ) );
}
