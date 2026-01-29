#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;
#include maps\satfarm_code_heli;

air_strip_init()
{
	level.start_point = "air_strip";
	
	Objective_Add( obj( "rendesvouz" ), "invisible", &"SATFARM_OBJ_RENDESVOUZ" );
	objective_state_nomessage( obj( "rendesvouz" ), "done" );
	
	Objective_Add( obj( "reach_air_strip" ), "current", &"SATFARM_OBJ_REACH_AIR_STRIP" );
	
	kill_spawners_per_checkpoint( "air_strip" );
}

air_strip_main()
{
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "air_strip_" );
		
		// setup allies
		spawn_heroes_checkpoint( "air_strip_" );
		
		array_thread( level.allytanks, ::npc_tank_combat_init );
	}
	else
	{
		//move hero tanks to new path
		thread switch_node_on_flag( level.herotanks[0], "", "switch_air_strip_path_hero0", "air_strip_path_hero0" );
		thread switch_node_on_flag( level.herotanks[1], "", "switch_air_strip_path_hero1", "air_strip_path_hero1" );
	}
	level.herotanks[0] thread tank_relative_speed( "air_strip_end_relative_speed", "change_bridge_deploy_path_hero1", 200, 15, 2 );
	level.herotanks[1] thread tank_relative_speed( "air_strip_end_relative_speed", "change_bridge_deploy_path_hero1", 250, 13.5, 1.5 );
	
	thread air_strip_begin();
	
	flag_wait( "air_strip_end" );
	
	maps\_spawner::killspawner( 40 );
    kill_vehicle_spawners_now( 40 );
    air_strip_cleanup();
}

air_strip_begin()
{
	flag_set( "air_strip_begin" );
	flag_init( "1_air_strip_bunker_destroyed" );
	flag_init( "2_air_strip_bunkers_destroyed" );
	
	thread air_strip_temp_dialog();
	
	thread falling_sat_dish();
	
	thread spawn_air_strip_a10_gun_dive_entrance();
	
	thread hangar_entrance_setup();
	
	thread setup_hangar_truck_pre_loaded();
	
	thread setup_hangar_truck_to_load();
	
	thread air_strip_choppers();

	thread saf_streetlight_dynamic_setup( "air_strip", "air_strip_end" );
	thread saf_concrete_barrier_dynamic_setup( "air_strip", "air_strip_end" );
	
    thread air_strip_hints();
    
    thread air_strip_obj_markers();
    
    thread air_strip_ambient_dogfight_1();
    thread air_strip_ambient_dogfight_2();
    thread air_strip_ambient_dogfight_3();
    
	mig = spawn_vehicle_from_targetname( "air_strip_take_off_mig_01" );
	mig thread air_strip_take_off_mig_01();
	
	mig = spawn_vehicle_from_targetname( "air_strip_take_off_mig_02" );
	mig thread air_strip_take_off_mig_02();
	
	thread setup_defense_bunkers( "satfarm_air_strip_defense_bunker_trigger", "air_strip_end" );
	
	autosave_by_name( "air_strip" );
	
	wait( 1.0 );
	
	level.herotanks[ 0 ] thread move_ally_to_mesh( "switch_bridge_deploy_path_hero0", "air_strip_exit_hero0", "air_strip_end" );
	level.herotanks[ 1 ] thread move_ally_to_mesh( "switch_bridge_deploy_path_hero1", "air_strip_exit_hero1", "air_strip_end" );
}

air_strip_temp_dialog()
{
	flag_wait( "1_air_strip_bunker_destroyed" );
	
	objective_string( obj( "air_strip_defenses" ), &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES_REMAINING", 2 );
	
	autosave_by_name( "1_air_strip_bunker_destroyed" );
	
	//Badger: One down, two to go.
	thread radio_dialog_add_and_go( "satfarm_bgr_onedowntwoto" );
	
	flag_wait( "2_air_strip_bunkers_destroyed" );
	
	objective_string( obj( "air_strip_defenses" ), &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES_REMAINING", 1 );
	
	autosave_by_name( "2_air_strip_bunker_destroyed" );
	
	//Badger: Good shooting. One more.
	thread radio_dialog_add_and_go( "satfarm_bgr_goodshootingonemore" );
	
	flag_wait( "air_strip_end" );
	
	objective_string( obj( "air_strip_defenses" ), &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES_REMAINING", 0 );
	
	objective_complete( obj( "air_strip_defenses" ) );
	
	//Badger: All enemy bunkers destroyed.
	thread radio_dialog_add_and_go( "satfarm_bgr_allenemybunkersdestroyed" );
}

falling_sat_dish()
{
	flag_init( "sat_dish_fall" );
	
	sat_dish_fall_dish = GetEnt( "sat_dish_fall_dish", "targetname" );
	
	sat_dish_fall_base = GetEnt( "sat_dish_fall_base", "targetname" );
	
	sat_dish_fall_dish LinkTo( sat_dish_fall_base );
	
	sat_dish_fall_spot_01 = getstruct( "sat_dish_fall_spot_01", "targetname" );
	
	sat_dish_fall_spot_02 = getstruct( "sat_dish_fall_spot_02", "targetname" );
	
	flag_wait( "sat_dish_fall" );
	
	sat_dish_fall_base RotateTo( sat_dish_fall_spot_01.angles, 3, 1, 0 );
	sat_dish_fall_base MoveTo( sat_dish_fall_spot_01.origin, 3, 1, 0 );
	
	wait( 3.0 );
	
	sat_dish_fall_base RotateTo( sat_dish_fall_spot_02.angles, 2, 1, 0 );
	sat_dish_fall_base MoveTo( sat_dish_fall_spot_02.origin, 2, 1, 0 );
	
	//Badger: The air strip is ahead. Clear it out.
	radio_dialog_add_and_go( "satfarm_bgr_theairstripis" );
	
	wait( 1.0 );
	
	sat_dish_fall_base PlaySound( "satf_tank_wall_crunch" );
	
	sat_dish_fall_fx_spot = getstruct( "sat_dish_fall_fx_spot", "targetname" );
	
	PlayFX( level._effect[ "sat_dish_sand_impact" ], sat_dish_fall_fx_spot.origin, AnglesToForward( sat_dish_fall_fx_spot.angles ), AnglesToUp( sat_dish_fall_fx_spot.angles ) );
}

spawn_air_strip_a10_gun_dive_entrance()
{
	flag_wait( "spawn_air_strip_a10_gun_dive_entrance" );
	
	level.air_strip_a10_gun_dive_entrance = spawn_vehicle_from_targetname_and_drive( "air_strip_a10_gun_dive_entrance" );
	
	mig = spawn_vehicle_from_targetname_and_drive( "air_strip_mig29_missile_entrance" );
	mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();

	flag_wait( "air_strip_a10_gun_dive_entrance_impact" );
	
	PlayFXOnTag( level._effect[ "aerial_explosion_mig29" ], level.air_strip_a10_gun_dive_entrance, "tag_origin" );
	
	wait( 0.1 );

	level.air_strip_a10_gun_dive_entrance godoff();
	level.air_strip_a10_gun_dive_entrance Kill();
	
	wait( 0.75 );
	
	if( IsDefined( level.air_strip_a10_gun_dive_entrance ) )
		level.air_strip_a10_gun_dive_entrance Delete();
	
	flag_set( "sat_dish_fall" );
}

air_strip_take_off_mig_01()
{
	self endon( "death" );
	
	self thread mig_damage_watcher();
	
	flag_wait( "air_strip_take_off_mig_01_go" );
	
	thread gopath( self );
	
	wait( 2.0 );
	
	self PlaySound( "veh_mig29_sonic_boom" );
	self thread vehicle_scripts\_mig29::playAfterBurner();
}

air_strip_take_off_mig_02()
{
	self endon( "death" );
	
	self thread mig_damage_watcher();
	
	flag_wait( "air_strip_take_off_mig_02_go" );
	
	thread gopath( self );
	
	wait( 2.0 );
	
	self PlaySound( "veh_mig29_sonic_boom" );
	self thread vehicle_scripts\_mig29::playAfterBurner();
}

mig_damage_watcher()
{
	self ent_flag_init( "off_ground" );
	
	while( 1 )
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type );
		if( IsDefined( type ) )
		{
			type = ToLower( type );
			
			if ( ( type == "mod_projectile" ) || ( type == "mod_projectile_splash" ) )
			{
				PlayFXOnTag( level._effect[ "aerial_explosion_mig29" ], self, "tag_origin" );
				wait( 0.1 );
				PlayFXOnTag( level._effect[ "jet_crash_dcemp" ], self, "tag_origin" );

				self godoff();
				self Kill();
				
				wait( 0.25 );
				
				if( IsDefined( self ) )
					self Delete();
			}
		}
	}
}

shoot_propane_tanks_near_hangar( propane_tank )
{
	self ent_flag_init( "blast_hangar" );
	
	self ent_flag_wait( "blast_hangar" );
	
	if( !flag( "hangar_blasted" ) )
   	{
		if( IsDefined( propane_tank ) )
		{
			self fire_on_non_vehicle( propane_tank, ( 0, 0, 56 ) );
		}
   	}
}

hangar_entrance_setup()
{
	thread hangar_baddies();
	
	thread hangar_wall_smash_setup();
	
	level.herotanks[0] thread shoot_propane_tanks_near_hangar( "hangar_wall_propane_tank_right" );
	level.herotanks[1] thread shoot_propane_tanks_near_hangar( "hangar_wall_propane_tank_left" );
}

hangar_baddies()
{
	flag_wait( "hangar_blasted" );
	
	hangar_baddies = array_spawn_targetname( "hangar_baddies" );
}

setup_hangar_truck_pre_loaded()
{
	flag_wait( "hangar_blasted" );
	
	truck = spawn_vehicle_from_targetname_and_drive( "hangar_truck_02" );
	
	truck thread gaz_spawn_setup();
}

setup_hangar_truck_to_load()
{
	flag_wait( "hangar_blasted" );
	
	truck = spawn_vehicle_from_targetname( "hangar_truck_01" );
	
	truck thread gaz_spawn_setup();
	
	guys = array_spawn_targetname( "hangar_truck_01_loaders" );
	
	truck thread vehicle_load_ai( guys );
	
	truck ent_flag_wait( "loaded" );
	
	thread gopath( truck );
}

setup_defense_bunkers( targetname_of_triggers, flag_to_set_when_all_destroyed )
{
	level.array_of_triggers = GetEntArray( targetname_of_triggers, "targetname" );
	
	thread monitor_defense_bunker_triggers( flag_to_set_when_all_destroyed );
	
	foreach( trigger in level.array_of_triggers )
	{
		turret_bases = GetEntArray( trigger.target, "targetname" );
		
		foreach( turret_base in turret_bases )
		{
			turret_base thread randomly_rotate_and_fire();
			turret_base.red_crosshair = true;
			turret_base thread toggle_thermal_npc();
			thread add_ent_objective_to_compass( turret_base, "air_strip_take_off_mig_01_go" );
		}
		
		trigger thread setup_trigger_damaged( turret_bases );
	}
}

monitor_defense_bunker_triggers( flag_to_set_when_all_destroyed )
{
	while( level.array_of_triggers.size > 0 )
	{
		if( level.array_of_triggers.size == 2 )
		{
			flag_set( "1_air_strip_bunker_destroyed" );
		}
		if( level.array_of_triggers.size == 1 )
		{
			flag_set( "2_air_strip_bunkers_destroyed" );
		}
		wait( 0.5 );
	}
	
	flag_set( flag_to_set_when_all_destroyed );
}

setup_trigger_damaged( turret_bases )
{
	self.hit_count = 0;
	while ( 1 )
	{
		self waittill( "trigger", triggerer );
		
		if( IsDefined( triggerer.driver ) && IsPlayer( triggerer.driver ) || IsPlayer( triggerer ) )
		{			
			//if( is_player_in_range( 16000000 ) )
			//{
				if( self.hit_count <= 0 )
				{
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin + offset );
					RadiusDamage( self.origin + offset, 600, 1000, 500 );
					self PlaySound( "satf_tank_damage_player" );
					self.hit_count = 1;
					continue;
				}
				else
				{
					ai_spawn_trigs = GetEntArray( "bunker_radius_trig", "targetname" );
					ai_spawn_trig = getClosest( self.origin, ai_spawn_trigs );
					ai_spawn_trig Delete();
				
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin + offset );
					RadiusDamage( self.origin + offset, 600, 1000, 500 );
					self PlaySound( "satf_tank_death_player" );
					
                    wait( 0.5 );
					
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin + offset );
					RadiusDamage( self.origin + offset, 600, 1000, 500 );
					self PlaySound( "satf_tank_death_player" );
					
                    wait( 0.5 );
					
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					up	   = AnglesToUp( self.angles );
					PlayFX( level._effect[ "air_strip_bunker_explosion_main" ], self.origin, up );
					RadiusDamage( self.origin, 700, 2000, 1000 );
					self PlaySound( "satf_tank_death_player" );
					
					ais = GetAIArray( "axis" );
					foreach( ai in ais )
					{
						if( ai IsTouching( self ) && IsAlive( ai ) )
						{
							ai Kill();
						}
					}
			
					foreach( turret_base in turret_bases )
					{
						turret_barrel = GetEnt( turret_base.target, "targetname" );
						turret_barrel_flash = GetEnt( turret_barrel.target, "targetname" );
						
						PlayFX( level._effect[ "generic_explosion_large" ], turret_base.origin );
						
						self PlaySound( "satf_turret_explosion" );
						thread remove_ent_objective_from_compass( turret_base );
						
						turret_base notify( "turret_deleted" );
						turret_base.red_crosshair = false;
						turret_barrel_flash Delete();
						turret_barrel.red_crosshair = false;
						turret_barrel Delete();
						turret_base Delete();
					}
					
					level.array_of_triggers = array_remove( level.array_of_triggers, self );
					break;
				}
			//}
		}
	}
}

is_player_in_range( range )
{
	current_range = DistanceSquared( self.origin, level.player.origin );
	
	if( current_range <= range )
	{
		IPrintLnBold( "That's a hit!" );
		return true;
	}
	else
	{
		IPrintLnBold( "Out of range!" );
		return false;
	}
}

randomly_rotate_and_fire()
{
	self endon( "turret_deleted" );
	
	self.original_yaw = self.angles[ 1 ];
	
	turret_barrel = GetEnt( self.target, "targetname" );
	turret_barrel.red_crosshair = true;
	turret_barrel thread toggle_thermal_npc();
	
	turret_barrel_flash = GetEnt( turret_barrel.target, "targetname" );
	turret_barrel_flash LinkTo( turret_barrel );

	while( 1 )
	{
		rotate_and_pitch_time = RandomFloatRange( 2.0, 4.0 ) / 2;
		
		if( cointoss() )
			self.new_yaw = self.original_yaw - RandomIntRange( 20, 45 );
		else
			self.new_yaw = self.original_yaw + RandomIntRange( 20, 45 );
		
		turret_barrel_pitch = 0 - RandomIntRange( 10, 35 );
		
		//self PlayLoopSound( "m1a1_abrams_turret_spin" );
		self RotateTo( ( 0, self.new_yaw, 0 ), rotate_and_pitch_time );
		turret_barrel RotateTo( ( turret_barrel_pitch, self.new_yaw, 0 ) , rotate_and_pitch_time );
		
		wait( rotate_and_pitch_time );
		
		//self StopLoopSound( "m1a1_abrams_turret_spin" );
		
		//self PlaySound( "m1a1_abrams_turret_stop" );
		
		time = 0;
		max_time = RandomFloatRange( 1.0, 3.0 );
		
		while( time <= max_time )
		{
			self PlaySound( "satfarm_turret_temp" );
			
			PlayFX( level._effect[ "a10_muzzle_flash" ], turret_barrel_flash.origin, AnglesToForward( turret_barrel_flash.angles ) );
				
            time += 0.1;
				
            wait( 0.1 );
		}
	}
}

air_strip_choppers()
{
	maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "heli_nav_mesh_air_strip_array" );
	
	flag_wait_either( "spawn_air_strip_choppers", "1_air_strip_bunker_destroyed" );
	
	choppers = spawn_hind_enemies( 3, "heli_nav_mesh_air_strip_array_start" );
	
	foreach ( chopper in choppers )
	{
		self thread chopper_explode_in_air();
	}

	//Badger: Enemy attack choppers moving in!
	radio_dialog_add_and_go( "satfarm_bgr_enemyattackchoppersmoving" );

	waittillhelisdead( get_hinds_enemy_active(), 2 );
	
	wait( 3.0 );
	
	choppers = get_hinds_enemy_active();
	
	foreach( chopper in choppers )
	{
		chopper Kill();
	}
}

chopper_explode_in_air()
{
	self waittill( "death" );
	
	if( IsDefined( self ) )
		self notify( "crash_done" );//cause the heli to explode
	if( IsDefined( self ) )
		self notify( "in_air_explosion" );//stop the parent thread
}

air_strip_hints()
{
	flag_wait( "hangar_blasted" );
	
	level.player thread display_hint_timeout( "HINT_MACHINE_GUN", 8 );
}

air_strip_obj_markers()
{
	air_strip_valley_corner_obj_marker = GetEnt( "air_strip_valley_corner_obj_marker", "targetname" );
	
	thread add_ent_objective_to_compass( air_strip_valley_corner_obj_marker );
	
	flag_wait( "spawn_air_strip_a10_gun_dive_entrance" );
	
	thread remove_ent_objective_from_compass( air_strip_valley_corner_obj_marker );
	
	air_strip_hangar_obj_marker = GetEnt( "air_strip_hangar_obj_marker", "targetname" );
	
	thread add_ent_objective_to_compass( air_strip_hangar_obj_marker );
	
	flag_wait( "air_strip_take_off_mig_01_go" );
	
	//Badger: Take out the defenses!
	thread radio_dialog_add_and_go( "satfarm_bgr_takeoutthedefenses" );
	
	objective_complete( obj( "reach_air_strip" ) );
	
	//"Destroy Air Strip defenses."
	Objective_Add( obj( "air_strip_defenses" ), "current", &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES" );
	//"Destroy Air Strip defenses [ &&1 Remaining ]."
	Objective_String_NoMessage( obj( "air_strip_defenses" ), &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES_REMAINING", 3 );
	
	thread remove_ent_objective_from_compass( air_strip_hangar_obj_marker );
}

hangar_wall_smash_setup()
{
	hangar_door_breakable = GetEnt( "hangar_door_breakable", "targetname" );
	if( IsDefined( hangar_door_breakable ) )
		hangar_door_breakable Delete();
	
	hangar_wall_propane_tanks = GetEntArray( "hangar_wall_propane_tank", "script_noteworthy" );
	array_thread( hangar_wall_propane_tanks, ::hangar_wall_propane_tank_wait );
	
	hangar_wall_unbroken = GetEnt( "hangar_wall_unbroken", "targetname" );
	
	hangar_wall_broken = GetEnt( "hangar_wall_broken", "targetname" );
	hangar_wall_broken Hide();
	
	hangar_wall_sections = GetEntArray( "hangar_wall_section", "script_noteworthy" );
	foreach ( hangar_wall_section in hangar_wall_sections )
		hangar_wall_section Hide();
	
	flag_wait( "hangar_blasted" );
	
	hangar_wall_unbroken Delete();
	
	hangar_wall_broken Show();
	
	foreach ( hangar_wall_section in hangar_wall_sections )
		hangar_wall_section Show();
	
	hangar_wall_smash_triggers = GetEntArray( "hangar_wall_smash_trigger", "targetname" );
	
	array_thread( hangar_wall_smash_triggers, ::hangar_wall_smash_wait );
}

hangar_wall_smash_wait()
{
	wall = GetEnt( self.target, "targetname" );
	
	self waittill( "trigger", triggerer );
	
	if( IsDefined( triggerer ) )
	{
		if( triggerer == level.playertank )
			level.player PlaySound( "satf_concrete_barrier_crush_plr" );
		else
			wall thread play_sound_on_entity( "satf_concrete_barrier_crush" );
	}
	
	if( IsDefined( wall.animation ) )
	{
		fx_struct = getstruct( wall.target, "targetname" );
		PlayFX( level._effect[ "hangar_wall_destroy" ], fx_struct.origin, AnglesToForward( fx_struct.angles ) );
		wall.animname = wall.animation;
		wall assign_animtree();
		wall assign_model();
		wall anim_single_solo( wall, wall.animation );
	}
}

hangar_wall_propane_tank_wait()
{
	self SetCanDamage( true );
	
	self waittill( "damage", damage, attacker, direction_vec, point, type );
	
	PlayFX( level._effect[ "hangar_propane_tank_explosion" ], self.origin, AnglesToForward( ( self.angles[ 0 ], self.angles[ 1 ] + 90, self.angles[ 2 ] ) ) );
	
	wait( 0.1 );
	
	self Delete();
	
	flag_set( "hangar_blasted" );
}

air_strip_ai_quick_cleanup_spawn_function( cleanup_distance )
{
	self endon( "death" );
	
	if ( IsSubStr( ToLower( self.classname ), "rpg" ) )
		self thread enemy_rpg_unlimited_ammo();
	
	if( IsDefined( self.script_parameters ) && self.script_parameters == "delete_on_goal" )
	{
		self thread waittill_goal( 32, true );
	}
	
	self.deathFunction = ::air_strip_ai_quick_cleanup_death_function;
	
	off_screen_dot = 0.75;

	while( !flag( "air_strip_end" ) )
	{
		wait( 0.1 );
		
		if ( DistanceSquared( self.origin, level.player.origin ) < cleanup_distance )
			continue;
		
		//if ( player_looking_at( self.origin + ( 0, 0, 48 ), off_screen_dot, true ) )
			//continue;

		if ( IsDefined( self.magic_bullet_shield ) )
			self stop_magic_bullet_shield();
		
		self Kill();
	}
}

air_strip_ai_quick_cleanup_death_function()
{
	if( IsDefined( self ) && IsDefined( self.spawner ) )
	   self.spawner.count = 1;
	
	if ( IsDefined( self ) )
		self StartRagdoll();
	
	wait( 4.0 );
	
	if( IsDefined( self ) )
		self Delete();
}

air_strip_ambient_dogfight_1()
{
	level endon ( "air_strip_end" );
	
	while( 1 )
	{
		wait( RandomFloatRange( 10.0, 20.0 ) );
		
		level.air_strip_ambient_a10_gun_dive_1 = undefined;
		
		level.air_strip_ambient_a10_gun_dive_1 = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_a10_gun_dive_1" );
		
		if( cointoss() )
			a10_buddy = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_a10_gun_dive_1_buddy" );
		
		wait( 0.5 );
		
		mig = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_mig29_missile_dive_1" );
		mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
		
		if( cointoss() )
			mig_buddy = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_mig29_missile_dive_1_buddy" );
		
		wait( RandomFloatRange( 5.0, 10.0 ) );
	}
}

air_strip_ambient_dogfight_2()
{
	level endon ( "air_strip_end" );
	
	while( 1 )
	{
		wait( RandomFloatRange( 20.0, 40.0 ) );
		
		level.air_strip_ambient_a10_gun_dive_2 = undefined;
		
		level.air_strip_ambient_a10_gun_dive_2 = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_a10_gun_dive_2" );
		
		if( cointoss() )
			a10_buddy = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_a10_gun_dive_2_buddy" );
		
		wait( 0.5 );
		
		mig = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_mig29_missile_dive_2" );
		mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
		
		if( cointoss() )
			mig_buddy = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_mig29_missile_dive_2_buddy" );
		
		wait( RandomFloatRange( 5.0, 10.0 ) );
	}
}

air_strip_ambient_dogfight_3()
{
	level endon ( "air_strip_end" );
	
	while( 1 )
	{
		wait( RandomFloatRange( 15.0, 30.0 ) );
		
		level.air_strip_ambient_a10_gun_dive_3 = undefined;
		
		level.air_strip_ambient_a10_gun_dive_3 = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_a10_gun_dive_3" );
		
		if( cointoss() )
			a10_buddy = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_a10_gun_dive_3_buddy" );
		
		wait( 0.5 );
		
		mig = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_mig29_missile_dive_3" );
		mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
		
		if( cointoss() )
			mig_buddy = spawn_vehicle_from_targetname_and_drive( "air_strip_ambient_mig29_missile_dive_3_buddy" );
		
		wait( RandomFloatRange( 5.0, 10.0 ) );
	}
}

air_strip_cleanup()
{
	//wait( 1.0 );
	ents = GetEntArray( "air_strip_ent", "script_noteworthy" );
	array_delete( ents );
}