#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

NUMOFTURRETS = 10;

complex_init()
{
	// Relative Speed Flags
	//flag_init( "allies_stop_complex" );
	
	// Switch Flags
	flag_init( "tank1_change_satfarm" );
	flag_init( "tank2_change_satfarm" );
	flag_init( "tank3_change_satfarm" );
	flag_init( "tank_change_mesh" );
	
	flag_init( "tank1_change_satpath" );
	flag_init( "tank2_change_satpath" );
	flag_init( "tank3_change_satpath" );
	
	flag_init( "missile_base1" );
	flag_init( "missile_base2" );
	flag_init( "missile_base3" );
	flag_init( "missile_bases_destroyed" );
	
	flag_init( "satfarm_missile_strike" );
	flag_init( "missile_hit" );
	
	//level.start_point = "complex";
	
	thread maps\satfarm_audio::checkpoint_complex();
}

complex_main()
{
	kill_spawners_per_checkpoint( "complex" );
	
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "complex_" );
		
		// setup allies
		spawn_heroes_checkpoint( "complex_" );
		
		//allytanks = spawn_vehicles_from_targetname_and_drive( "complex_allytanks" );
		//level.allytanks = array_combine( level.allytanks, allytanks );
		array_thread( level.allytanks, ::npc_tank_combat_init );
		
		thread rotate_big_sat();
	}
	else
	{
		//get specfic ally tanks to move on
		foreach( ally in level.allytanks )
		{
			if( IsDefined( ally ) && ( ally.script_friendname == "Babe Ruth" || ally.script_friendname == "Bryce") )
				thread switch_node_on_flag( ally, "", "tank1_switch_satfarm", "tank1_target_satfarm" );
		}
		
		//move hero tanks to new path
		//thread switch_node_on_flag( level.herotanks[0], "", "tank2_switch_satfarm", "tank2_target_satfarm" );
		//thread switch_node_on_flag( level.herotanks[1], "", "tank3_switch_satfarm", "tank3_target_satfarm" );
		thread switch_node_on_flag( level.herotanks[0], "", "switch_canyon_hero0", "tank2_target_satfarm" );
		thread switch_node_on_flag( level.herotanks[1], "", "switch_canyon_hero1", "tank3_target_satfarm" );
	}
	
	//level.herotanks[0] thread tank_relative_speed( "complex_big_sat", "satcomplex_enter_combat" );
	//level.herotanks[1] thread tank_relative_speed( "complex_big_sat", "satcomplex_enter_combat" );
	
	thread complex_script();
	thread missile_bases();
	thread systems_down();
	
	flag_wait( "satfarm_complex_end" );
}

complex_script()
{		
	thread spawn_arms();
	thread spawn_front();
	thread spawn_left();
	thread spawn_right();
	thread setup_wall();
	thread setup_gate();
	
	thread hangar_wall_smash_setup();
	
	wait .5;
	
	allytanks = spawn_vehicles_from_targetname_and_drive( "complex_allies1" );
	allytanks[0] thread move_ally_to_mesh( "tank1_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks );
	wait .05;
	allytanks = spawn_vehicles_from_targetname_and_drive( "complex_allies2" );
	level.ally_kill = allytanks[0];
	allytanks[0] thread move_ally_to_mesh( "tank2_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks );
	wait .05;
	allytanks = spawn_vehicles_from_targetname_and_drive( "complex_allies3" );
	allytanks[0] thread move_ally_to_mesh( "tank3_target_satpath", "no_exit" );
	level.allytanks = array_combine( level.allytanks, allytanks );
	wait .05;
	array_thread( level.allytanks, ::npc_tank_combat_init );
	array_thread( level.allytanks, ::tank_relative_speed, "a10_player_start", "spawn_front", 1000, 20, 10 );
	
	// spawn dynamic enemy tanks
	// note: enemy tanks combat is inited inside.
	//dynamic_tanks = spawn_node_based_enemy_tanks_targetname( "complex_enemy_tank_spawner" );
	//level.enemytanks = array_combine( dynamic_tanks, level.enemytanks );
	
	spawn_vehicles_from_targetname_and_drive( "complex_a10_gun_dive" );
	
	wait 1;
	
	radio_dialog_add_and_go( "satfarm_hqr_enemyaaturretsneed" );
	//radio_dialog_add_and_go( "satfarm_hqr_thoseradardishesare" );
	
	level.herotanks[0] move_ally_to_mesh( "tank2_target_satpath", "no_exit" );
	level.herotanks[1] move_ally_to_mesh( "tank3_target_satpath", "no_exit" );
	
	//waittilltanksdead( dynamic_tanks, 2); //, 0, "complex_player_move1" );
	
	//level.herotanks[1] fire_on_non_vehicle( "mdb0" );
		
	//IPrintLnBold( "Take out the hard targets!" );
	
	//dynamic_tanks2 = spawn_node_based_enemy_tanks_targetname( "complex_enemy_tank_spawner2" );
	//level.enemytanks = array_combine( dynamic_tanks2, level.enemytanks );
	
}

spawn_arms()
{
	flag_wait( "spawn_arms" );
	enemytanks 			= spawn_node_based_enemy_tanks_targetname( "complex_enemy_tank_spawner2" );
	level.enemytanks 	= array_combine( level.enemytanks, enemytanks );
}

spawn_front()
{
	flag_wait( "spawn_front" );
	enemytanks 					= spawn_node_based_enemy_tanks_targetname( "complex_enemy_tank_spawner" );
	level.enemytanks 			= array_combine( level.enemytanks, enemytanks );
	level.straightenemytanks 	= spawn_vehicles_from_targetname_and_drive( "complex_enemy_tank_spawner_straight" );
	level.enemytanks 			= array_combine( level.enemytanks, level.straightenemytanks );
	array_spawn_targetname( "generic_enemy_guys_spawner1" );
	
	enemygazs 			= spawn_vehicles_from_targetname_and_drive( "cpx_gaz_group1" );
	array_thread( enemygazs, ::gaz_spawn_setup );
	
	Objective_Add( obj( "mantis" ), "active", "Takedown the mantis turrets." );
	Objective_String_NoMessage( obj( "mantis" ), "Takedown the mantis turrets. [ &&1 Remaining ]", NUMOFTURRETS );
	Objective_Current( obj( "mantis") );
	
	wait 3;
	
	foreach( tank in level.straightenemytanks )
	{
		if( IsDefined( tank ) )
			tank DoDamage( tank.health * 2, tank.origin );
	}
	
	wait 2;
	
	level.ally_kill DoDamage( level.ally_kill.health * 2, level.ally_kill.origin );
	
	waitframe();
	
	maps\_spawner::killspawner( 302 );
	kill_vehicle_spawners_now( 302 );
}

spawn_left()
{
	flag_wait( "spawn_left" );
	enemytanks 			= spawn_node_based_enemy_tanks_targetname( "complex_enemy_tank_spawner3" );
	level.enemytanks 	= array_combine( level.enemytanks, enemytanks );
	//array_spawn_targetname( "generic_enemy_guys_spawner3" );
	
	enemygazs 			= spawn_vehicles_from_targetname_and_drive( "cpx_gaz_group2" );
	array_thread( enemygazs, ::gaz_spawn_setup );
}

spawn_right()
{
	flag_wait( "spawn_right" );
	enemytanks 			= spawn_node_based_enemy_tanks_targetname( "complex_enemy_tank_spawner4" );
	level.enemytanks 	= array_combine( level.enemytanks, enemytanks );
	//array_spawn_targetname( "generic_enemy_guys_spawner2" );
	
	enemygazs 			= spawn_vehicles_from_targetname_and_drive( "cpx_gaz_group3" );
	array_thread( enemygazs, ::gaz_spawn_setup );
}

missile_bases()
{
	//thread setup_defense_bunkers( "satfarm_complex_defense_bunker_trigger", "missile_bases_destroyed" );
	autosave_by_name( "complex" );
		
	thread setup_position( 1 );
	thread setup_position( 2 );
	thread setup_position( 3 );	
	thread turret_down();
	
	//IPrintLnBold( "Disable the mantis turrets so we can fire Buster." );
//	
//	flag_wait( "missile_base1" );
//	wait .05;
//	flag_wait( "missile_base2" );
//	wait .05;
//	flag_wait( "missile_base3" );
	
	//radio_dialog_add_and_go( "satfarm_bgr_overlordallaaturrets" );
	
//	autosave_by_name( "misslelaunch" );
//	
//	Objective_Complete( obj( "mantis") );
//	
//	final_position = getstruct( "final_position", "targetname" );
//	Objective_Add( obj( "exfil" ), "active", "Leave the complex area.", final_position.origin );
//	Objective_Position( obj( "exfil" ), final_position.origin );
//	Objective_Current( obj( "exfil" ) );
//	
//	radio_dialog_add_and_go( "satfarm_hqr_copythatordinancepackage" );
	
//	wait 3;
	//maps\_hud_util::fade_out( .5 );	
	//level.player thread static_on( 1, 1, .1, .05 );
	wait .1;
//	objective_complete( obj( "exfil" ) );
	
	
	wait .5;
//	level.playertank dismount_tank( level.player );
//	thread maps\_hud_util::fade_in( .5 );
//	level.player thread static_on( .5, 1, .1, .05 );
//	flag_set( "satfarm_complex_end" );
}

turret_down()
{
	for( turretsdown = 0; turretsdown < NUMOFTURRETS; turretsdown++ )
	{
		if( turretsdown != 0 )
			objective_string( obj( "mantis" ), "Takedown the mantis turrets. [ &&1 Remaining ]", NUMOFTURRETS - turretsdown );
		
		level waittill( "turretdown" );
	}
	
	flag_set( "missile_base1" );
	flag_set( "missile_base2" );
	flag_set( "missile_base3" );
}

setup_position( number )
{
	if( number == 1 )
	{
		level.array_of_triggers1 = GetEntArray( "satfarm_complex_defense_bunker_trigger1", "targetname" );
		setup_defense_bunkers( level.array_of_triggers1, "missile_base1" );
//		level.radar_triggers1 = GetEntArray( "satfarm_complex_radar_trigger1", "targetname" );
//		setup_radar_pos( level.radar_triggers1, "missile_base1" );
//		
//		foreach( trigger in level.array_of_triggers1 )
//		{
//			if( IsDefined( trigger.target ) )
//			{
//				turret_bases = GetEnt( trigger.target, "targetname" );
//				turret_bases notify( "turret_deleted" );
//			}
//		}
		
		autosave_by_name( "mdb1" );
		radio_dialog_add_and_go( "satfarm_bct_enemyturretsdownin" );
	}
	else if( number == 2 )
	{
		level.array_of_triggers2 = GetEntArray( "satfarm_complex_defense_bunker_trigger2", "targetname" );
		setup_defense_bunkers( level.array_of_triggers2, "missile_base2" );
//		level.radar_triggers2 = GetEntArray( "satfarm_complex_radar_trigger2", "targetname" );
//		setup_radar_pos( level.radar_triggers2, "missile_base2" );
//		
//		foreach( trigger in level.array_of_triggers2 )
//		{
//			if( IsDefined( trigger.target ) )
//			{
//				turret_bases = GetEnt( trigger.target, "targetname" );
//				turret_bases notify( "turret_deleted" );
//			}
//		}
		
		autosave_by_name( "mdb2" );
		radio_dialog_add_and_go( "satfarm_bct_enemyturretsdownin" );
	}
	else
	{
		level.array_of_triggers3 = GetEntArray( "satfarm_complex_defense_bunker_trigger3", "targetname" );
		setup_defense_bunkers( level.array_of_triggers3, "missile_base3" );
//		level.radar_triggers3 = GetEntArray( "satfarm_complex_radar_trigger3", "targetname" );
//		setup_radar_pos( level.radar_triggers3, "missile_base3" );
//		
//		foreach( trigger in level.array_of_triggers3 )
//		{
//			if( IsDefined( trigger.target ) )
//			{
//				turret_bases = GetEnt( trigger.target, "targetname" );
//				turret_bases notify( "turret_deleted" );
//			}
//		}
		
		autosave_by_name( "mdb3" );
		radio_dialog_add_and_go( "satfarm_bct_enemyturretsdownin" );
	}
}

setup_radar_pos( triggers, flag_to_set_when_all_destroyed )
{	
	foreach( trigger in triggers )
	{
		turret_bases = GetEntArray( trigger.target, "targetname" );
		
		foreach( turret_base in turret_bases )
		{
			turret_base thread rotate_radar();
		}
		
		trigger thread setup_trigger_damaged( turret_bases );
	}
	
	while( triggers.size > 0 )
	{
		foreach( trigger in triggers )
		{
			if( !IsDefined( trigger ) )
				triggers = array_remove( triggers, trigger );
		}
		wait .05;	
	}
	
	flag_set( flag_to_set_when_all_destroyed );
}

rotate_radar()
{
	self endon( "turret_deleted" );
	
	while( 1 )
	{
		self RotateTo( ( 0, self.angles[ 1 ] + 90, 0 ), 2 );
		wait 2;
	}
}

setup_defense_bunkers( triggers, flag_to_set_when_all_destroyed )
{
	foreach( trigger in triggers )
	{
		turret_bases = GetEntArray( trigger.target, "targetname" );
		
		wait RandomFloatRange( .1, 1 );
		
		foreach( turret_base in turret_bases )
		{
			turret_base thread randomly_rotate_and_fire();
			thread add_ent_objective_to_compass( turret_base );
		}
		
		trigger thread setup_trigger_damaged( turret_bases );
	}
	
	while( triggers.size > 0 )
	{
		foreach( trigger in triggers )
		{
			if( !IsDefined( trigger ) )
			{
				triggers = array_remove( triggers, trigger );
			}
		}
		wait .05;	
	}
	
	flag_set( flag_to_set_when_all_destroyed );
}

randomly_rotate_and_fire()
{
	self endon( "turret_deleted" );
	
	self.original_yaw = self.angles[ 1 ];
	self.red_crosshair = true;
		
	turret_barrel = GetEnt( self.target, "targetname" );
	turret_barrel.red_crosshair = true;
	
	turret_barrel_flash = GetEnt( turret_barrel.target, "targetname" );
	turret_barrel_flash LinkTo( turret_barrel );
	
	self thread toggle_thermal_npc();
	turret_barrel thread toggle_thermal_npc();
	
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
			//self PlaySound( "weap_m2turret_50cal_fire_npc" );
			
			PlayFX( level._effect[ "a10_muzzle_flash" ], turret_barrel_flash.origin, AnglesToForward( turret_barrel_flash.angles ) );
				
			time += .1;
				
			wait( .1 );
		}
	}
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
			/*	
  				if( self.hit_count <= 0 )
				{
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin + offset );
					RadiusDamage( self.origin + offset, 600, 1000, 500, level.player );
					self PlaySound( "a10p_agm65_impact" );
					self.hit_count = 1;
					continue;
				}
				else
				{
				*/
				
					ai_spawn_trigs 	= GetEntArray( "bunker_radius_trig", "targetname" );
					ai_spawn_trig	= undefined;
					if( IsDefined( ai_spawn_trigs ) )
						ai_spawn_trig = getClosest( self.origin, ai_spawn_trigs );
						if( IsDefined( ai_spawn_trig ) )
							ai_spawn_trig Delete();
				
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin + offset );
					RadiusDamage( self.origin + offset, 600, 1000, 500, level.player );
					self PlaySound( "satf_agm65_impact" );
					
					wait( .5 );
					
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					PlayFX( level._effect[ "vehicle_explosion_t90_cheap" ], self.origin + offset );
					RadiusDamage( self.origin + offset, 600, 1000, 500, level.player );
					self PlaySound( "satf_agm65_impact" );
					
					wait( .5 );
					
					offset = ( RandomIntRange( 0, 300 ), RandomIntRange( 0, 300 ), RandomIntRange( 0, 200 ) );
					up = anglestoup( self.angles );
					PlayFX( level._effect[ "air_strip_bunker_explosion_main" ], self.origin, up );
					RadiusDamage( self.origin, 700, 2000, 1000, level.player );
					self PlaySound( "satf_agm65_impact" );
					
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
						thread remove_ent_objective_from_compass( turret_base );
						
						PlayFX( level._effect[ "generic_explosion_large" ], turret_base.origin );
						
						turret_barrel = undefined;
							
						if( IsDefined( turret_base.target ) )
						{
							turret_barrel = GetEnt( turret_base.target, "targetname" );
							turret_barrel Delete();
						}
						
						if( IsDefined( turret_barrel ) && IsDefined( turret_barrel.target ) )
						{
							turret_barrel_flash = GetEnt( turret_barrel.target, "targetname" );
							turret_barrel_flash Delete();
						}
						
						level notify( "turretdown" );
						turret_base notify( "turret_deleted" );
						turret_base Delete();
					}
					
					self delete();
					break;
				//}
			//}
		}
	}
}

setup_wall()
{
	saf_wall_triggers = GetEntArray( "saf_wall_trigger", "targetname" );
	
	foreach( trigger in saf_wall_triggers )
	{
		trigger thread trigger_animate();
	}
}

setup_gate()
{
	saf_gate_trigger = GetEntArray( "saf_gate_trigger", "targetname" );
	
	foreach( trigger in saf_gate_trigger )
	{
		trigger thread trigger_animate();
	}
}

trigger_animate()
{
	object = GetEnt( self.target, "targetname" );
	
	object SetContents( 0 );
	
	self waittill( "trigger", tank );

	tread_dist			 = 64.0;
	tank_velocity_vector = tank Vehicle_GetVelocity();
	speed				 = VectorDot( tank_velocity_vector, AnglesToForward( object.angles ) );
	                
	if ( speed != 0.0 )
	{
	    rotate_time = tread_dist / abs( speed );
	                    
	    if ( speed > 0 )
	    {
	        object rotateroll( -90, rotate_time * 2 );
	    }
	    else
	    {
	        object rotateroll(  90, rotate_time * 2 );
	    }
	}
	
}

hangar_wall_smash_setup()
{	
	hangar_wall_smash_triggers = GetEntArray( "wall_smash_trigger", "targetname" );
	
	array_thread( hangar_wall_smash_triggers, ::hangar_wall_smash_wait );
	
	flag_wait( "missile_strike_now" );
	
	wait 7;
	
	foreach( wall in hangar_wall_smash_triggers )
		wall notify( "trigger" );
}

hangar_wall_smash_wait()
{
	wall = GetEnt( self.target, "targetname" );
	
	self waittill( "trigger" );
	
	if( IsDefined( wall.animation ) )
	{
		fx_struct = getstruct( wall.target, "targetname" );
		PlayFX( level._effect[ "hangar_wall_destroy" ], fx_struct.origin, AnglesToForward( fx_struct.angles ) );
		self anim_single_solo( self, wall.animation );
	}
	
	else
	{
		fx_struct = getstruct( wall.target, "targetname" );
		PlayFX( level._effect[ "hangar_wall_destroy" ], fx_struct.origin, AnglesToForward( fx_struct.angles ) );
		wall Delete();
	}
}

systems_down()
{
	level.player endon( "tank_dismount" );
	
	thread create_missile_attractor();
	
	level waittill( "turretdown" );
	wait 1;
	level waittill( "turretdown" );

	start  		= getstruct( "a10_player_start", "targetname" );
	newMissile	= MagicBullet( "javelin_dcburn", start.origin, level.playertank.origin );
//	newMissile 	SetEntityOwner( level.missilefire );
	newMissile 	Missile_SetTargetEnt( level.playertank );
	newMissile 	Missile_SetFlightmodeTop();	
	
	level.player thread play_loop_sound_on_entity( "missile_incoming" );
	newMissile 	waittill( "death" );
	level.player thread stop_loop_sound_on_entity( "missile_incoming" );
		
	flag_set( "tow_out" );
	level.player notify( "cycle_weapon" );
	waitframe();
	level.player notify( "cycle_weapon" );
//	thread tank_hud_offline( "missile" );
	
	radio_dialog_add_and_go( "satfarm_bgr_werehit" );
	thread add_dialogue_line( "Badger", "Damage Report!" );
	wait 1;
	thread add_dialogue_line( "Tank Gunner", "Tow missiles offline! Still can fight." );
	
	wait 5;
	
	level.player EnableSlowAim( .5, .2);
	
	thread add_dialogue_line( "Tank Driver", "We're losing hydraulic fluid, Badger-1." );
	wait 1;
	thread add_dialogue_line( "Badger", "Are you combat effective?" );
	wait 1;
	thread add_dialogue_line( "Tank Driver", "Ain't easy but I can still make her dance." );
	
	wait 1;
	//level waittill( "turretdown" );
	
	start  		= getstruct( "a10_player_start", "targetname" );
	newMissile	= MagicBullet( "javelin_dcburn", start.origin, level.player.origin );
//	newMissile SetEntityOwner( level.missilefire );
	newMissile 	Missile_SetTargetEnt( level.playertank );
	newMissile 	Missile_SetFlightmodeTop();	
	
	level.player thread play_loop_sound_on_entity( "missile_incoming" );
	newMissile 	waittill( "death" );
	level.player thread stop_loop_sound_on_entity( "missile_incoming" );
	
	flag_set( "optics_out" );
	level.player notify( "zoomin" );
	level.player notify( "assist" );
	waitframe();
	level.player notify( "zoomout" );
//	flag_set( "thermal_out" );
//	if( level.bThermalOn )
//	{
//		level.player notify( "thermal" );
//		waitframe();
//	}
//	level.player notify( "thermal" );
	level.player notify( "thermal_off" );
	level.player uav_thermal_off();
	level.bThermalOn = false;
	
	thread add_dialogue_line( "Tank Operator", "Another javelin!" );
	wait 1;
	thread add_dialogue_line( "Tank Gunner", "Optics and thermal offline!" );
	wait 1;
	thread add_dialogue_line( "Badger", "Boomer! Exit the battle." );
	wait 1;
	thread add_dialogue_line( "Tank Operator", "Combat effective, Badger-1. We finish this." );
	
	wait 3;
	
	flag_set( "smoke_out" );
	level.player notify( "BUTTON_POP_SMOKE" );
	waitframe();
//	thread tank_hud_offline( "smoke" );
	flag_set( "compass_out" );
	SetSavedDvar( "compass", 0 );
	
	thread add_dialogue_line( "Tank Operator", "Smoke malfunctioning." );
	wait 1;
	thread add_dialogue_line( "Badger", "Move to exfil Boomer!" );
	wait 1;
	thread add_dialogue_line( "Tank Operator", "Combat effective, Badger-1." );
	
	wait 3;
	thread add_dialogue_line( "Tank Gunner", "Targeting hud is malfuntioning. Still can fire." );
//	thread tank_hud_offline( "turret" );
//	thread tank_hud_offline( "mg" );
	
	wait 2;
	
	thread add_dialogue_line( "Tank Gunner", "Targeting hud is down." );
	flag_set( "final_hit" );
	level.player EnableSlowAim( .5, .1);
	level.player tank_clear_hud();
	level.player DigitalDistortSetParams( .5, 1 );
	wait 1;
	thread add_dialogue_line( "Tank Operator", "Keep firing." );
	
	wait 3;
	
	flag_set( "satfarm_complex_end" );
	
	wait 1;
	
	cleanup_complex();
}

cleanup_complex()
{
	maps\_spawner::killspawner( 303 );
	kill_vehicle_spawners_now( 303 );
	
	foreach( enemy in level.enemytanks )
	{
		if( IsDefined( enemy ) )
			enemy kill();
	}
	foreach( enemy in level.enemygazs )
	{
		if( IsDefined( enemy ) )
			enemy kill();
	}
	enemys = GetAIArray( "axis" );
	foreach( enemy in enemys )
	{
		if( IsDefined( enemy ) && IsAlive( enemy ) )
			enemy kill();
	}
	foreach( ally in level.allytanks )
	{
		if( IsDefined( ally ) )
			ally kill();
	}
}

	