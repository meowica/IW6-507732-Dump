#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

tower_init()
{
	level.start_point = "tower";

	//"Rendesvouz with Bravo Team."
	Objective_Add( obj( "rendesvouz" ), "invisible", &"SATFARM_OBJ_RENDESVOUZ" );
	objective_state_nomessage( obj( "rendesvouz" ), "done" );
	//"Reach the Air Strip."
	Objective_Add( obj( "reach_air_strip" ), "invisible", &"SATFARM_OBJ_REACH_AIR_STRIP" );
	objective_state_nomessage( obj( "reach_air_strip" ), "done" );
	//"Destroy Air Strip defenses."
	Objective_Add( obj( "air_strip_defenses" ), "invisible", &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES" );
	objective_state_nomessage( obj( "air_strip_defenses" ), "done" );
	
	//"Reach the train."
	Objective_Add( obj( "train" ), "current", &"SATFARM_OBJ_TRAIN" );
}

warehouse_init()
{
	level.start_point = "warehouse";
	
	//"Rendesvouz with Bravo Team."
	Objective_Add( obj( "rendesvouz" ), "invisible", &"SATFARM_OBJ_RENDESVOUZ" );
	objective_state_nomessage( obj( "rendesvouz" ), "done" );
	//"Reach the Air Strip."
	Objective_Add( obj( "reach_air_strip" ), "invisible", &"SATFARM_OBJ_REACH_AIR_STRIP" );
	objective_state_nomessage( obj( "reach_air_strip" ), "done" );
	//"Destroy Air Strip defenses."
	Objective_Add( obj( "air_strip_defenses" ), "invisible", &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES" );
	objective_state_nomessage( obj( "air_strip_defenses" ), "done" );
	
	//"Reach the train."
	Objective_Add( obj( "train" ), "current", &"SATFARM_OBJ_TRAIN" );
}

tower_main()
{
	if ( level.start_point == "tower" )
	{
		spawn_player_checkpoint( "tower" );
		spawn_allies();
		
		battlechatter_off( "allies" );
		battlechatter_on( "axis" );
	}
	
//	kill_spawners_per_checkpoint( "tower" );

	level.move_allies_to_javelin_nest_trigger = GetEnt( "move_allies_to_javelin_nest_trigger", "targetname" );
	level.move_allies_to_javelin_nest_trigger trigger_off();
	
	level.move_allies_to_server_room_trigger = GetEnt( "move_allies_to_server_room_trigger", "targetname" );
	level.move_allies_to_server_room_trigger trigger_off();
	
	level.player_elevator_clip_back = GetEnt( "player_elevator_clip_back", "targetname" );
	level.player_elevator_clip_back NotSolid();
	
	thread tower_begin();
	
	flag_wait( "tower_end" );
	
	maps\_spawner::killspawner( 200 );
	kill_vehicle_spawners_now( 200 );
	
	maps\_spawner::killspawner( 201 );
	kill_vehicle_spawners_now( 201 );
}

tower_begin()
{	
	thread ambient_building_explosions();
	thread javelin_nest_combat();
	thread loading_bay_combat();
	thread elevator_room_combat();
	
	thread allies_movement_tower();
	autosave_by_name( "tower" );
}

warehouse_main()
{
	if ( level.start_point == "warehouse" )
	{
		spawn_player_checkpoint( "warehouse" );
		spawn_allies();
		
		battlechatter_off( "allies" );
		battlechatter_on( "axis" );
		
		level.player_elevator_clip_back = GetEnt( "player_elevator_clip_back", "targetname" );
		level.player_elevator_clip_back NotSolid();
		
		thread ambient_building_explosions();
	}
	
	kill_spawners_per_checkpoint( "warehouse" );
	
	thread check_trigger_flagset( "advance_allies_wave_2_trigger" );
	thread check_trigger_flagset( "advance_allies_wave_3_trigger" );
	thread check_trigger_flagset( "advance_allies_wave_3a_trigger" );
	thread check_trigger_flagset( "advance_allies_wave_4_trigger" );
	
	level.player_train_trigger = GetEnt( "player_train_trigger", "targetname" );
	level.player_train_trigger trigger_off();
	
	thread warehouse_begin();
	
	flag_wait( "warehouse_end" );
	wait( 1 );
	maps\_spawner::killspawner( 202 );
	cleanup_ghost_section_entities = GetEntArray( "cleanup_ghost_section", "script_noteworthy" );
	array_thread( cleanup_ghost_section_entities, ::entity_cleanup );
}

warehouse_begin()
{		
	thread warehouse_elevator();
	thread warehouse_combat();
	thread exit_on_train();
	
	thread allies_movement_warehouse();
}

javelin_nest_combat()
{	
  //  level.player.ignoreme		  = 1;
  //  level.allies[ 0 ] .ignoreme = 1;
  //  level.allies[ 1 ] .ignoreme = 1;
	
	array_spawn_function_targetname( "javelin_nest_enemies", ::javelin_nest_enemy_setup );
	level.javelin_nest_enemies = array_spawn_targetname( "javelin_nest_enemies", true );
	
	thread javelin_nest_threatbiasgroup();
	thread javelin_tanks();
	
	thread player_waits_too_long_at_javelin_nest();
	
	flag_wait( "javelin_nest_alerted" );
	battlechatter_on( "allies" );
	
  //  level.player.ignoreme		  = 0;
  //  level.allies[ 0 ] .ignoreme = 0;
  //  level.allies[ 1 ] .ignoreme = 0;
	
	waittill_dead_or_dying( level.javelin_nest_enemies, 1 );
	
	if ( !flag( "player_on_stairs" ) )
	{
		javelin_nest_backup_enemies = array_spawn_targetname( "javelin_nest_backup_enemies", true );
		level.javelin_nest_enemies	= array_combine( level.javelin_nest_enemies, javelin_nest_backup_enemies );
	}
	
	thread cleanup_enemies( "player_in_loading_bay", level.javelin_nest_enemies );
	
	level.javelin_nest_enemies = array_removeDead_or_dying( level.javelin_nest_enemies );
	waittill_dead_or_dying( level.javelin_nest_enemies );
	flag_set( "javelin_nest_enemies_dead" );
}

javelin_nest_threatbiasgroup( enemy_array )
{
	CreateThreatBiasGroup( "ignore_group" );
	CreateThreatBiasGroup( "javelin_nest" );
	
	level.player SetThreatBiasGroup( "ignore_group" );
	level.allies[ 0 ] SetThreatBiasGroup( "ignore_group" );
	level.allies[ 1 ] SetThreatBiasGroup( "ignore_group" );
	
	foreach ( enemy in level.javelin_nest_enemies )
	{
		enemy SetThreatBiasGroup( "javelin_nest" );
	}
	
	SetIgnoreMeGroup( "ignore_group", "javelin_nest" );
	
	flag_wait( "javelin_nest_alerted" );
	
	level.player SetThreatBiasGroup();
	level.allies[ 0 ] SetThreatBiasGroup();
	level.allies[ 1 ] SetThreatBiasGroup();
}

javelin_tanks()
{
//	flag_wait( "player_ready_for_javelin_nest" );
	wait( 2 );
	
	level.javelin_tank_targets = spawn_vehicles_from_targetname_and_drive( "javelin_tank_targets" );
	array_thread( level.javelin_tank_targets, ::flag_wait_god_mode_off, "player_ready_for_javelin_nest" );
	array_thread( level.javelin_tank_targets, ::javelin_tank_shoot );
	array_thread( level.javelin_tank_targets, ::entity_cleanup, "player_and_allies_in_elevator" );
	
	level.javelin_targets	= spawn_vehicles_from_targetname_and_drive( "javelin_targets" );
	array_thread( level.javelin_targets, ::flag_wait_god_mode_off, "player_ready_for_javelin_nest" );
	array_thread( level.javelin_targets, ::javelin_target_tank_logic );
	array_thread( level.javelin_targets, ::entity_cleanup, "player_and_allies_in_elevator" );
	
	level.javelin_targets_left	= spawn_vehicles_from_targetname_and_drive( "javelin_targets_left" );
	array_thread( level.javelin_targets_left, ::javelin_tank_shoot );
	array_thread( level.javelin_targets_left, ::entity_cleanup, "warehouse_end" );
	
	ambient_tanks_for_javelin_nest = spawn_vehicles_from_targetname_and_drive( "ambient_tank_for_javelin_nest" );
	array_thread( ambient_tanks_for_javelin_nest, ::flag_wait_god_mode_off, "player_ready_for_javelin_nest" );
	
	flag_wait( "player_ready_for_javelin_nest" );
	javelin_a10s = spawn_vehicles_from_targetname_and_drive( "javelin_a10s" );
}

javelin_target_tank_logic()
{
	self endon( "death" );
	
	self ent_flag_init( "path_end" );
	
	self thread javelin_tank_shoot();
	self thread waittill_death_and_remove_from_array();
	
	self ent_flag_wait( "path_end" );
	self.ready_to_die = 1;
}

javelin_tank_shoot()
{
	self endon( "death" );
	
	wait RandomFloatRange( 2, 7 );
	volume = GetEnt( "control_tower_building_second_floor_volume", "targetname" );
	
	while ( 1 )
	{
		self shoot_anim();
		if ( level.player IsTouching( volume ) )
		{
			wait RandomFloatRange( 6, 12 );
		}
		else
		{
			wait RandomFloatRange( 12, 18 );
		}
	}
}

waittill_death_and_remove_from_array()
{
	self waittill( "death" );
	
	level.javelin_targets = array_remove( level.javelin_targets, self );
}

entity_cleanup( flag_to_wait_on )
{
	if ( IsDefined( flag_to_wait_on ) )
	{
		flag_wait( flag_to_wait_on );
	}
	
	if ( IsDefined( self ) )
	{
		self Delete();
	}
}

player_waits_too_long_at_javelin_nest()
{
	flag_wait( "start_javelin_nest_countdown" );
	
	wait( 10 );
	
	if ( !flag( "player_shot_at_javelin_nest" ) || !flag( "player_too_close_to_javelin_nest" ) )
	{
		flag_set( "player_waits_too_long_at_javelin_nest" );
	}
	
	foreach ( enemy in level.javelin_nest_enemies )
	{
		if ( IsAlive( enemy ) )
		{
			enemy.ignoreme = false;	
		}
	}
}

#using_animtree( "generic_human" );
javelin_nest_enemy_setup()
{
	self endon( "death" );
	
	self.ignoreme	= true;
  //self.ignoreall = true;
	self.animname	= "generic";
	self.allowdeath = true;
	
	self disable_surprise();
	self.ignoresuppression			 = true;
	self.disableBulletWhizbyReaction = true;
	self.disableFriendlyFireReaction = true;
	self.disableReactionAnims		 = true;
	
	self magic_bullet_shield();

	//self thread javelin_nest_shot_at();
	volume = GetEnt( "player_shot_in_javelin_nest_volume", "targetname" );
	//self thread enemies_shot_at( "javelin_nest_alerted", "player_ready_for_javelin_nest", "player_shot_at_javelin_nest", volume );
	self thread enemies_shot_at( "javelin_nest_alerted", "player_ready_for_javelin_nest", "player_shot_at_javelin_nest" );
	
	switch( self.script_noteworthy )
	{
		case "javelin_enemy":
			self.struct = getstruct( self.animation + "_struct", "targetname" );
			self Attach( "weapon_javelin_sp", "TAG_INHAND" );
			self.attached_item = "weapon_javelin_sp";
			self.idleanim	   = "javelin_idle_a";
			self.reactanim	   = "javelin_react_a";
			self.deathanim	   = %javelin_death_4;
			self thread AI_javelin_think();
			break;
		case "spotter_on_radio":
			self.struct	   = getstruct( "roadkill_cover_radio_soldier2_struct", "targetname" );
			self.idleanim  = "spotter_on_radio_idle";
			self.reactanim = "spotter_on_radio_react";
			self gun_remove();
			self.gun_removed = true;
			self thread play_idle_anims();
			break;
		case "javelin_nest_animated_gunner":
			self.struct	  = getstruct( "roadkill_cover_active_soldier2_struct", "targetname" );
			self.idleanim = "javelin_nest_animated_gunner";
			self thread play_idle_anims();
			break;
		case "javelin_nest_gunner":
			self thread javelin_nest_gunner();
			break;
	}
	
	flag_wait( "player_ready_for_javelin_nest" );
	self stop_magic_bullet_shield();
	
	flag_wait_any( "player_too_close_to_javelin_nest", "player_shot_at_javelin_nest", "player_waits_too_long_at_javelin_nest" );
	flag_set( "javelin_nest_alerted" );
	if ( self.script_noteworthy == "javelin_enemy" )
	{
		clear_deathanim();	
	}

	self alert_enemies_react();
	
	if ( self.script_noteworthy == "javelin_nest_backup" )
	{
		self set_fixednode_false();
		volume		= GetEnt( "javelin_nest_backup_volume", "targetname" );
		self SetGoalVolumeAuto( volume );
	}
	else
	{
		self set_fixednode_false();
		volume		= GetEnt( "javelin_nest_volume", "targetname" );
		self SetGoalVolumeAuto( volume );
	}
}

javelin_nest_shot_at()
{
	self endon( "death" );
	level endon( "player_too_close_to_javelin_nest" );
	level endon( "player_waits_too_long_at_javelin_nest" );
	
	flag_wait( "player_ready_for_javelin_nest" );
	
	volume = GetEnt( "player_shot_in_javelin_nest_volume", "targetname" );
	
	while ( 1 )
	{
		if ( level.player IsTouching( volume ) )
		{
			if ( level.player AttackButtonPressed() )
			{
				break;	
			}
		}
		
		wait( 0.05 );
	}
    
    flag_set( "player_shot_at_javelin_nest" );
}

play_idle_anims()
{
	self endon( "death" );
	self endon( "alerted" );
	
	self.struct anim_generic_loop( self, self.idleanim, "stop_loop" );
}

/*
enemies_shot_at( endon_flag, flag_to_wait_on, flag_to_set, volume )
{
	self endon( "death" );
	level endon( endon_flag );
	
	flag_wait( flag_to_wait_on );
	
	while ( 1 )
	{
		if ( level.player IsTouching( volume ) )
		{
			if ( level.player AttackButtonPressed() )
			{
				break;	
			}
		}
		
		wait( 0.05 );
	}
    
    flag_set( flag_to_set );
}

*/

enemies_shot_at( flag_to_end_on, flag_to_wait_on, flag_to_set )
{
	self endon( "death" );
	level endon( flag_to_set );
	
	flag_wait( flag_to_wait_on );
	
	self AddAIEventListener( "grenade danger" );
	self AddAIEventListener( "gunshot" );
//	self AddAIEventListener( "gunshot_teammate" );
	self AddAIEventListener( "silenced_shot" );
//	self AddAIEventListener( "bulletwhizby" );
//	self AddAIEventListener( "projectile_impact" );
//	self AddAIEventListener( "explode" );
	self waittill_any( "ai_event", "flashbang" );

 //   self waittill( "ai_event", eventtype );
    
    flag_set( flag_to_set );
}

alert_enemies_react()
{
	self endon( "death" );
	
	wait( RandomFloatRange( 0.1, 0.3 ) );
	self notify( "alerted" );
	if ( IsDefined( self.struct ) )
	{
		self.struct notify( "stop_loop" );
	}
	self notify( "stop_loop" );
	self StopAnimScripted();
	
	self ClearEntityTarget();
	
	if ( IsDefined( self.gun_removed ) )
	{
		self gun_recall();
	}
	
	if ( IsDefined( self.attached_item ) )
	{
		self Detach( self.attached_item, "TAG_INHAND" );
	}
	
	if ( IsDefined( self.reactanim ) )
	{
		self anim_single_solo( self, self.reactanim );
	}
	
	self.ignoreme  = false;
	self.ignoreall = false;
	
	self ClearGoalVolume();
}

AI_javelin_think()
{
	self endon( "death" );
	self endon( "alerted" );
/*
	self.struct thread anim_loop_solo( self, self.idleanim, "stop_loop" );	
	
	flag_wait( "player_ready_for_javelin_nest" );
	wait( 0.3 );
	self.struct notify( "stop_loop" );
	self thread anim_generic( self, "javelin_fire_a" );
	self waittillmatch( "single anim", "fire_weapon" );
	
  	level.script_origin_targets = GetEntArray( "javelin_script_origin_targets", "targetname" );
	
	javelin_target = self get_javelin_target();	
	if ( IsDefined( javelin_target ) )
	{
		newMissile	= MagicBullet( "javelin_dcburn", self GetTagOrigin( "tag_inhand" ), javelin_target.origin );
		PlayFXOnTag( getfx( "javelin_muzzle" ), self, "TAG_FLASH" );
		newMissile Missile_SetTargetEnt( javelin_target );
		newMissile Missile_SetFlightmodeTop();
	}
	self waittillmatch( "single anim", "end" );
*/	
  	level.script_origin_targets = GetEntArray( "javelin_script_origin_targets", "targetname" );
  	array_thread( level.script_origin_targets, ::entity_cleanup, "javelin_nest_alerted" );

	while ( IsAlive( self ) )
	{
		self.struct thread anim_loop_solo( self, self.idleanim, "stop_loop" );	
		
		wait( RandomFloatRange( 2, 7 ) );
		
		self.struct notify( "stop_loop" );
		self thread anim_generic( self, "javelin_fire_a" );
		self waittillmatch( "single anim", "fire_weapon" );
		
		javelin_target	= self get_javelin_target();
		if ( IsDefined( javelin_target ) )
		{		
			newMissile	= MagicBullet( "javelin_dcburn", self GetTagOrigin( "tag_inhand" ), javelin_target.origin );
			PlayFXOnTag( getfx( "javelin_muzzle" ), self, "TAG_FLASH" );
			newMissile Missile_SetTargetEnt( javelin_target );
			newMissile Missile_SetFlightmodeTop();
		}
		self waittillmatch( "single anim", "end" );
	}
}

get_javelin_target()
{
	javelin_target	= undefined;

	if ( IsDefined( level.javelin_targets ) && level.javelin_targets.size > 0 )
	{
  		tank_target	= random( level.javelin_targets );	
		if ( IsDefined( tank_target ) && IsDefined( tank_target.ready_to_die ) )
		{
			javelin_target = tank_target;
		}
		else
		{
			javelin_target	= random( level.script_origin_targets );
		}
	}
	else
	{
		javelin_target	= random( level.script_origin_targets );	
	}
	
	return javelin_target;	
}

javelin_nest_gunner()
{
	self endon( "death" );
	self endon( "alerted" );
	
	gunner_targets = GetEntArray( "javelin_nest_gun_targets", "targetname" );
	array_thread( gunner_targets, ::entity_cleanup, "javelin_nest_alerted" );
	
	while ( 1 )
	{
		gunner_target = random( gunner_targets );
		if ( IsDefined( gunner_target ) )
		{
			self SetEntityTarget( gunner_target );
		}
		wait RandomFloatRange( 4, 6 );
	}
}

loading_bay_combat()
{
	flag_wait( "player_on_stairs" );
	
	level thread wall_light_spinner();
	level thread wall_lights();
	
	array_spawn_function_targetname( "loading_bay_enemies", ::loading_bay_enemy_setup );
	level.loading_bay_enemies = array_spawn_targetname( "loading_bay_enemies", true );

	waittill_dead_or_dying( level.loading_bay_enemies, 2 );
	if ( !flag( "send_in_loading_bay_runner_3" ) ) //will this cause an issue??????????????????????????????????
	{
		flag_set( "send_in_loading_bay_runner_3" );
	}
	
	while ( level.loading_bay_enemies.size > 2 )
	{
		if ( flag( "player_in_middle_of_loading_bay" ) )
		{
			break;
		}
		level.loading_bay_enemies = array_removeDead_or_dying( level.loading_bay_enemies );

		wait( 0.05 );
	}

	flag_set( "loading_bay_enemies_retreat" );
	
	thread wait_for_all_enemies_to_leave_volume();
}

wait_for_all_enemies_to_leave_volume()
{
//	level endon( );
	
	loading_bay_volume = GetEnt( "loading_bay_volume", "targetname" );
	
	while ( 1 )
	{
		ai_array = loading_bay_volume get_ai_touching_volume( "axis" );
		if ( ai_array.size > 0 )
		{
			wait( 0.05 );	
		}
		else
		{
			flag_set( "all_enemies_out_of_loading_bay" );
			break;	
		}
	}
}

loading_bay_enemy_setup()
{
	self endon( "death" );
	
	loading_bay_volume = GetEnt( "loading_bay_volume", "targetname" );
	
	self thread retreat_to_elevator_room();
	
	if ( IsDefined( self.script_noteworthy ) )
	{
		switch( self.script_noteworthy )
		{
			case "loading_bay_runner_1":
				self.ignoreall = true;
				self.health	   = 50;
				flag_wait( "player_on_stairs" );
				wait( 1 );
				self set_fixednode_false();
				self SetGoalVolumeAuto( loading_bay_volume );
				self waittill( "goal" );
				self.ignoreall = false;
				break;
			case "loading_bay_runner_2":
				self.ignoreme = true;
				self set_baseaccuracy( 0.1 ); //so that they can't blast the player as he runs down the hall towards them
				flag_wait( "start_loading_bay_runners" );
				wait( RandomFloatRange( 0.3, 0.8 ) );
				self set_baseaccuracy( 0.5 );
				self.ignoreme = false;
				if ( !flag( "loading_bay_enemies_retreat" ) )
				{
					self set_fixednode_false();
					self SetGoalVolumeAuto( loading_bay_volume );
				}
				break;
			case "loading_bay_runner_3":
				self set_baseaccuracy( 0.1 ); //so that they can't blast the player as he runs down the hall towards them
				flag_wait( "start_loading_bay_runners" );
				wait( RandomFloatRange( 2.0, 3.0 ) );
				self set_baseaccuracy( 0.5 );
				if ( !flag( "loading_bay_enemies_retreat" ) )
				{
					self set_fixednode_false();
					self SetGoalVolumeAuto( loading_bay_volume );
				}
				break;
			case "loading_bay_runner_4":
				self.ignoreme = true;					
				flag_wait( "send_in_loading_bay_runner_3" );
				wait( RandomFloatRange( 0.3, 1.0 ) );
				if ( !flag( "loading_bay_enemies_retreat" ) )
				{
					self.ignoreme = false;
					self set_fixednode_false();
					self SetGoalVolumeAuto( loading_bay_volume );
				}
				break;
		}
	}
	/*
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "loading_bay_runner_1" )
	{
		self.ignoreme = true;
		self set_baseaccuracy( 0.1 ); //so that they can't blast the player as he runs down the hall towards them
		flag_wait( "start_loading_bay_runners" );
		wait( RandomFloatRange( 0.3, 0.8 ) );
		self set_baseaccuracy( 0.5 );
		self.ignoreme = false;
		if ( !flag( "loading_bay_enemies_retreat" ) )
		{
			self SetGoalVolumeAuto( loading_bay_volume );
		}
	}
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "loading_bay_runner_2" )
	{
		self set_baseaccuracy( 0.1 ); //so that they can't blast the player as he runs down the hall towards them
		flag_wait( "start_loading_bay_runners" );
		wait( RandomFloatRange( 2.0, 3.0 ) );
		self set_baseaccuracy( 0.5 );
		if ( !flag( "loading_bay_enemies_retreat" ) )
		{
			self SetGoalVolumeAuto( loading_bay_volume );
		}
	}
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "loading_bay_runner_3" )
	{
		self.ignoreme = true;					
		flag_wait( "send_in_loading_bay_runner_3" );
		wait( RandomFloatRange( 0.3, 1.0 ) );
		if ( !flag( "loading_bay_enemies_retreat" ) )
		{
			self.ignoreme = false;
			self SetGoalVolumeAuto( loading_bay_volume );
		}
	}
	*/
}

retreat_to_elevator_room()
{
	self endon( "death" );
	
	elevator_room_volume = GetEnt( "elevator_room_volume", "targetname" );
		
	flag_wait( "loading_bay_enemies_retreat" );
	
	wait( RandomFloatRange( 0.3, 0.8 ) );

	self set_fixednode_false();
	self SetGoalVolumeAuto( elevator_room_volume );
	self thread tunnel_behavior();
	self waittill( "goal" );
	self.ignoreall = false;
}

tunnel_behavior()
{
	self endon( "death" );
	
	volume = GetEnt( "tunnel_entrance_volume", "targetname" );
	while ( 1 )
	{
		if ( self IsTouching( volume ) )
		{
			self.ignoreall = true;
			self.health	   = 1;
			break;			
		}
		wait( 0.05 );
	}
}

run_out_behavior( volume, flag_to_check1, flag_to_check2 )
{
	self endon( "death" );
	
	while ( 1 )
	{
		if ( self IsTouching( volume ) )
		{
			break;
		}
		
		wait( 0.05 );
	}
	
	if ( IsDefined( flag_to_check2 ) )
	{
	   if ( flag( flag_to_check1 ) || flag( flag_to_check2 ) )
	   {
	   		self.ignoreall = false;
			self player_seek_enable();	
	   }
	   else
	   {
			self Delete();
	   }
	}
	else
	{
		if ( flag( flag_to_check1 ) )
		{
			self.ignoreall = false;
			self player_seek_enable();	
		}
		else
		{
			self Delete();
		}
	}
}

elevator_room_combat()
{
	flag_wait( "player_in_middle_of_loading_bay" );
	
	array_spawn_function_targetname( "elevator_room_enemies", ::elevator_room_enemy_setup );
	level.elevator_room_enemies = array_spawn_targetname( "elevator_room_enemies", true );
	level.loading_bay_enemies	= array_removeDead_or_dying( level.loading_bay_enemies );
	level.elevator_room_enemies = array_combine( level.elevator_room_enemies, level.loading_bay_enemies );
	
	flag_wait( "player_in_tunnel" );
	autosave_by_name( "tunnel" );
	wait( 0.5 );
	waittill_dead_or_dying( level.elevator_room_enemies );
	flag_set( "elevator_room_cleared" );
	battlechatter_off( "allies" );
}

elevator_room_enemy_setup()
{
	self endon( "death" );
	
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "elevator_room_runner_1" )
	{
		flag_wait( "send_in_elevator_room_runners_1" );
	}
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "elevator_room_runner_2" )
	{
		flag_wait( "player_in_tunnel" );
	}
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "elevator_room_runner_3" )
	{
		self.ignoreme = 1;
		flag_wait( "send_in_elevator_room_runners_3" );
		self.ignoreme = 0;
	}
	
	wait RandomFloatRange( 0.3, 0.8 );
	volume = GetEnt( "elevator_room_volume", "targetname" );
	self set_fixednode_false();
	self SetGoalVolumeAuto( volume );
}

allies_movement_tower()
{
	thread allies_vo_tower();
	
	flag_wait_any( "control_room_enemies_dead", "player_ready_for_javelin_nest" );
	autosave_by_name( "javelin_nest" );
	level.move_allies_to_javelin_nest_trigger trigger_on();
	if ( flag( "control_room_enemies_dead" ) )
	{
		battlechatter_off( "allies" );
		activate_trigger_with_targetname( "move_allies_to_javelin_nest_entrance" );
	}
	
	thread allies_start_cqb();
	
	flag_wait( "javelin_nest_alerted" );
	battlechatter_on( "allies" );
	
	flag_wait_any( "javelin_nest_enemies_dead", "player_on_stairs" );
	autosave_by_name( "post_javelin_nest" );
	
	if ( flag( "player_on_stairs" ) )
	{
	    if ( !flag( "player_in_server_room" ) )
		{
	    	safe_activate_trigger_with_targetname( "move_allies_into_hallway" );
	    }
	}
	else
	{
		activate_trigger_with_targetname( "move_allies_to_stairs" );
		level.move_allies_to_server_room_trigger trigger_on();		
	}
	
	level.allies[ 0 ] thread super_human( true );
	level.allies[ 1 ] thread super_human( true );
	
	flag_wait( "allies_stop_cqb_walk" );
	level.allies[ 0 ] disable_cqbwalk();
	level.allies[ 1 ] disable_cqbwalk();
	
	flag_wait( "player_in_loading_bay" );
	level.allies[ 0 ] thread super_human();
	level.allies[ 1 ] thread super_human();
		
//	flag_wait_any( "all_enemies_out_of_loading_bay", "player_in_middle_of_loading_bay" );
	flag_wait_any( "loading_bay_enemies_retreat", "player_in_middle_of_loading_bay" );
	
	level.allies[ 0 ] thread super_human( true );
	level.allies[ 1 ] thread super_human( true );
	
	wait( 1 ); //give enemies a chance to run out

	if ( !flag( "move_allies_into_tunnel_flag" ) )
	{
		safe_activate_trigger_with_targetname( "move_allies_to_tunnel_entrance" );
	}
	flag_wait( "allies_in_tunnel" );
	level.allies[ 0 ] thread super_human();
	level.allies[ 1 ] thread super_human();

	flag_wait( "elevator_room_cleared" );
	
	safe_activate_trigger_with_targetname( "move_allies_into_elevator_room_trigger" );
	
	safe_activate_trigger_with_targetname( "move_allies_into_elevator" );
	
	flag_set( "tower_end" );
}

allies_vo_tower()
{
	if ( level.start_point != "tower" )
	{
		flag_wait_any( "control_room_enemies_dead", "player_ready_for_javelin_nest" );

		wait( 2.5 );
		//Merrick: Overlord, Ghost Team is in the target building.
		radio_dialog_add_and_go( "satfarm_mrk_overlordghostteamis" );
		
		//Overlord: Solid copy Ghost One. Good hunting.
		//radio_dialog_add_and_go( "satfarm_hqr_solidcopyghostone" );
	}
	
	if ( !flag( "player_ready_for_javelin_nest" ) )
	{
		flag_wait( "player_ready_for_javelin_nest" );
		//Hesh: Enemy nest ahead.
		radio_dialog_add_and_go( "satfarm_hsh_enemynestahead" );
	}
	/*
	flag_wait_any( "javelin_nest_enemies_dead", "player_on_stairs" );
	//Merrick:  Overlord, second floor clear, we’re proceeding to lower level.
	radio_dialog_add_and_go( "satfarm_mrk_overlordsecondfloorclear" );
	//Overlord: Copy that Ghost One.
	radio_dialog_add_and_go( "satfarm_hqr_copythatghostone" );
	
	flag_wait_any( "loading_bay_enemies_retreat", "player_in_middle_of_loading_bay" );
	//Merrick: Fire teams suppressed in 3-1, advancing to the loading bay.
	radio_dialog_add_and_go( "satfarm_mrk_fireteamssuppressedin" );
	//Overlord: Copy all Ghost One.
	//radio_dialog_add_and_go( "satfarm_hqr_copyallghostone" );
	
	//Overlord: Ghost One, be advised, Intel has revised their data. Your target is likely mobile.
	radio_dialog_add_and_go( "satfarm_hqr_ghostonebeadvised" );
	//Merrick: Understood Overlord.
	radio_dialog_add_and_go( "satfarm_mrk_understoodoverlord" );
	//Hesh: Mobile?
	radio_dialog_add_and_go( "satfarm_hsh_mobile" );
	//Merrick: Vargas is on the train, let’s go.
	radio_dialog_add_and_go( "satfarm_mrk_vargasisonthe" );
	*/
}

allies_start_cqb()
{
	flag_wait( "allies_start_cqb_walk" );
	level.allies[ 0 ] enable_cqbwalk();
	level.allies[ 1 ] enable_cqbwalk();	
}

super_human( bool )
{
	if ( IsDefined( bool ) )
	{
		self disable_surprise();
		self disable_pain();
		self.ignoresuppression			 = true;
		self.disableBulletWhizbyReaction = true;
		self.disableFriendlyFireReaction = true;
		self.disableReactionAnims		 = true;
	}
	else
	{
		self enable_surprise();
		self enable_pain();
		self.ignoresuppression			 = false;
		self.disableBulletWhizbyReaction = false;
		self.disableFriendlyFireReaction = false;
		self.disableReactionAnims		 = false;
	}
}

//WAREHOUSE
warehouse_elevator()
{
	flag_wait( "allies_in_elevator" );
	
	thread warehouse_lift();
	
	volume = GetEnt( "warehouse_elevator_volume", "targetname" );
	while ( 1 )
	{
		if ( level.player IsTouching( volume ) )
		{
			break;
		}
		wait( 0.05 );
	}
	
	flag_set( "player_and_allies_in_elevator" );
	thread warehouse_bay_doors();
	level.player_elevator_clip_back Solid();
	
	warehouse_elevator_parts = GetEntArray( "warehouse_elevator", "targetname" );
	foreach ( warehouse_elevator_part in warehouse_elevator_parts )
	{
		if ( IsDefined( warehouse_elevator_part.script_noteworthy ) )
		{
			if ( warehouse_elevator_part.script_noteworthy == "elevator_room_side_door_right" )
			{
				elevator_room_side_door_right_struct = getstruct( "elevator_room_side_door_right_struct", "targetname" );
//				end									 = warehouse_elevator_part.origin + ( 0, elevator_room_side_door_right_struct.origin[ 1 ], 0 );
//				warehouse_elevator_part MoveTo( end, 2 );
				warehouse_elevator_part MoveTo( elevator_room_side_door_right_struct.origin, 2 );
			}
			else if ( warehouse_elevator_part.script_noteworthy == "elevator_room_side_door_left" )
			{
				elevator_room_side_door_left_struct = getstruct( "elevator_room_side_door_left_struct", "targetname" );
//				end									= warehouse_elevator_part.origin + ( 0, elevator_room_side_door_left_struct.origin[ 1 ], 0 );
//				warehouse_elevator_part MoveTo( end, 2 );
				warehouse_elevator_part MoveTo( elevator_room_side_door_left_struct.origin, 2 );
			}
		}
	}
	
	wait( 2 );
	
	warehouse_elevator_struct = getstruct( "warehouse_elevator_struct", "targetname" );
	warehouse_elevator_origin = warehouse_elevator_struct spawn_tag_origin();
	foreach ( ally in level.allies )
	{
		ally LinkTo( warehouse_elevator_origin, "tag_origin" );
	}
	
	foreach ( warehouse_elevator_part in warehouse_elevator_parts )
	{
		warehouse_elevator_part LinkTo( warehouse_elevator_origin, "tag_origin" );
	}
	
	warehouse_elevator_origin MoveTo( ( warehouse_elevator_origin.origin + ( 0, 0, -448 ) ), 15, 1, 1 );
	
	wait( 15 );
	
	foreach ( warehouse_elevator_part in warehouse_elevator_parts )
	{
		warehouse_elevator_part Unlink();
	}
	
	flag_set( "elevator_landed" );
	
	foreach ( warehouse_elevator_part in warehouse_elevator_parts )
	{
		if ( IsDefined( warehouse_elevator_part.script_noteworthy ) )
		{
			if ( warehouse_elevator_part.script_noteworthy == "warehouse_side_door_right" )
			{
				warehouse_side_door_right_struct = getstruct( "warehouse_side_door_right_struct", "targetname" );
//				end								 = warehouse_elevator_part.origin + ( 0, warehouse_side_door_right_struct.origin[ 1 ], 0 );
//				warehouse_elevator_part MoveTo( end, 2 );
				warehouse_elevator_part MoveTo( warehouse_side_door_right_struct.origin, 2 );
			}
			else if ( warehouse_elevator_part.script_noteworthy == "warehouse_side_door_left" )
			{
				warehouse_side_door_left_struct = getstruct( "warehouse_side_door_left_struct", "targetname" );
//				end								= warehouse_elevator_part.origin + ( 0, warehouse_side_door_left_struct.origin[ 1 ], 0 );
//				warehouse_elevator_part MoveTo( end, 2 );
				warehouse_elevator_part MoveTo( warehouse_side_door_left_struct.origin, 2 );
			}
		}
	}
	
	wait( 2 );
	
	flag_set( "unload_elevator" );
	foreach ( ally in level.allies )
	{
		ally Unlink();
	}
	
	flag_wait( "warehouse_end" );
	
	wait( 1 );
	foreach ( warehouse_elevator_part in warehouse_elevator_parts )
	{
		if ( IsDefined( warehouse_elevator_part ) )
		{
			warehouse_elevator_part Delete();
		}
	}
		
	warehouse_elevator_origin Delete();
}

warehouse_lift()
{
	flag_wait( "start_ambient_warehouse_scenarios" );
	autosave_by_name( "warehouse_elevator" );
	
	warehouse_lift_brush	= GetEnt( "warehouse_lift_brush", "targetname" );
	warehouse_lift_entities = GetEntArray( "warehouse_lift_entities", "targetname" );
	
	warehouse_lift_struct			= getstruct( "warehouse_lift_struct", "script_noteworthy" );
	level.warehouse_lift_tag_origin = warehouse_lift_struct spawn_tag_origin();
	
	warehouse_lift_brush LinkTo( level.warehouse_lift_tag_origin, "tag_origin" );
	
	foreach ( warehouse_lift_entity in warehouse_lift_entities )
	{
		warehouse_lift_entity LinkTo( level.warehouse_lift_tag_origin, "tag_origin" );
	}
	
	clockwork_chaos_extinguisher_enemy_struct		= getstruct( "clockwork_chaos_extinguisher_enemy_struct", "targetname" );
	level.clockwork_chaos_extinguisher_enemy_origin = clockwork_chaos_extinguisher_enemy_struct spawn_tag_origin();
	level.clockwork_chaos_extinguisher_enemy_origin LinkTo( level.warehouse_lift_tag_origin, "tag_origin" );
	clockwork_checkpoint_lean_rail_enemy_struct		  = getstruct( "clockwork_checkpoint_lean_rail_enemy_struct", "targetname" );
	level.clockwork_checkpoint_lean_rail_enemy_origin = clockwork_checkpoint_lean_rail_enemy_struct spawn_tag_origin();
	level.clockwork_checkpoint_lean_rail_enemy_origin LinkTo( level.warehouse_lift_tag_origin, "tag_origin" );
	
	array_spawn_function_targetname( "warehouse_enemies_lift", ::warehouse_enemy_lift_setup );
	warehouse_enemies_lift = array_spawn_targetname( "warehouse_enemies_lift", true );

	wait( 1 );
	end = level.warehouse_lift_tag_origin.origin + ( 0, 0, -192 );
	level.warehouse_lift_tag_origin MoveTo( end, 18, 1, 1 );
	wait( 18 );

	warehouse_lift_clip = GetEnt( "warehouse_lift_clip", "targetname" );
	end					= warehouse_lift_clip.origin + ( 0, 0, -64 );
	warehouse_lift_clip MoveTo( end, 0.5, 0, 0 );
	wait( 0.5 );
	warehouse_lift_clip ConnectPaths();
	
	flag_set( "lift_landed" );
	
	flag_wait( "warehouse_end" );
	wait( 1 );
	foreach ( warehouse_lift_entity in warehouse_lift_entities )
	{
		warehouse_lift_entity Delete();
	}
	
	warehouse_lift_brush Delete();
	
	level.warehouse_lift_tag_origin Delete();
}

warehouse_bay_doors()
{
	light = GetEnt( "warehouse_bay_doors_light", "targetname" );
	light SetLightIntensity( 1.0 );
	
	wait( 2 );
	warehouse_bay_doors = GetEntArray( "warehouse_bay_doors", "targetname" );
	
	foreach ( door in warehouse_bay_doors )
	{
		if ( door.script_noteworthy == "right" )
		{
			warehouse_bay_doors_right_struct = getstruct( "warehouse_bay_doors_right", "targetname" );
			door MoveTo( warehouse_bay_doors_right_struct.origin, 1 );
		}
		else
		{
			warehouse_bay_doors_left_struct = getstruct( "warehouse_bay_doors_left", "targetname" );
			door MoveTo( warehouse_bay_doors_left_struct.origin, 1 );
		}
	}
}

warehouse_combat()
{
	flag_wait( "spawn_warehouse_enemies" );
	array_spawn_function_targetname( "warehouse_enemies_ambient", ::warehouse_enemy_ambient_setup );
	warehouse_enemies_ambient = array_spawn_targetname( "warehouse_enemies_ambient", true );
	
	array_spawn_function_targetname( "warehouse_enemies_wave_1", ::warehouse_enemy_setup );
	warehouse_enemies_wave_1 = array_spawn_targetname( "warehouse_enemies_wave_1", true ); //4
	thread ai_array_killcount_flag_set( warehouse_enemies_wave_1, 3, "advance_allies_wave_2_flag" );
	
	volume = GetEnt( "warehouse_volume", "targetname" );
	thread set_accuracy( volume, "axis", .01 );
	
//	flag_wait_any( "player_ready_for_warehouse", "player_in_warehouse" );
//	flag_set( "start_warehouse_runners" );
	
	thread set_accuracy_in_warehouse_back();
	
	thread warehouse_right_flank();
	
	//WAVE 2	
	flag_wait( "advance_allies_wave_2_flag" );
	thread retreat_from_vol_to_vol( "warehouse_front_volume", "warehouse_middle_1_volume", .3, .5 );
	
	warehouse_enemies_wave_2 = array_spawn_targetname( "warehouse_enemies_wave_2", true );			//4
	warehouse_enemies_wave_1 = array_removeDead_or_dying( warehouse_enemies_wave_1 );
	level.warehouse_enemies	 = array_combine( warehouse_enemies_wave_1, warehouse_enemies_wave_2 ); //should be 6 now, if three killed
	thread ai_array_killcount_flag_set( level.warehouse_enemies, 3, "advance_allies_wave_3_flag" );
	
	array_spawn_function_targetname( "warehouse_enemies_upper", ::warehouse_enemy_upper_setup );
	warehouse_enemies_upper = array_spawn_targetname( "warehouse_enemies_upper", true );
	
	safe_activate_trigger_with_targetname( "advance_allies_wave_2_trigger" );
	
	//WAVE 3
	flag_wait( "advance_allies_wave_3_flag" );
	thread retreat_from_vol_to_vol( "warehouse_middle_1_volume", "warehouse_middle_2_volume", .3, .5 );
	volume = GetEnt( "warehouse_volume", "targetname" );
					 //   volume    team_name    value   
	thread set_accuracy( volume	 , "axis"	  , .01 );
	thread set_accuracy( volume	 , "allies"	  , .01 );
	
	warehouse_enemies_wave_3 = array_spawn_targetname( "warehouse_enemies_wave_3", true );		   //4
	level.warehouse_enemies	 = array_removeDead_or_dying( level.warehouse_enemies );
	level.warehouse_enemies	 = array_combine( level.warehouse_enemies, warehouse_enemies_wave_3 ); //should be 7 now, if three killed
	
	safe_activate_trigger_with_targetname( "advance_allies_wave_3_trigger" );
	
	autosave_by_name( "warehouse_combat_1" );
	
	//only triggered by player moving up
	flag_wait( "advance_allies_wave_3a_flag" );
	thread retreat_from_vol_to_vol( "warehouse_middle_2_volume", "warehouse_back_volume", .3, .5 );
	
	level.warehouse_enemies		= array_removeDead_or_dying( level.warehouse_enemies );
	thread ai_array_killcount_flag_set( level.warehouse_enemies, 3, "advance_allies_wave_4_flag" );
	
//	array_spawn_function_targetname( "warehouse_enemies_ambient_runners_upper_2", ::warehouse_enemy_ambient_runners_setup );
//	warehouse_enemies_ambient_runners_upper_2 = array_spawn_targetname( "warehouse_enemies_ambient_runners_upper_2", true );
	
	//WAVE 4
	flag_wait( "advance_allies_wave_4_flag" );
	
	warehouse_enemies_wave_4 = array_spawn_targetname( "warehouse_enemies_wave_4", true );		   //5
	level.warehouse_enemies	 = array_removeDead_or_dying( level.warehouse_enemies );
	level.warehouse_enemies	 = array_combine( level.warehouse_enemies, warehouse_enemies_wave_4 ); //should be 8 now, if three killed
	
	level.warehouse_enemies	= array_removeDead_or_dying( level.warehouse_enemies );
	while ( level.warehouse_enemies.size > 5 )
	{
		level.warehouse_enemies = remove_dead_from_array( level.warehouse_enemies );
		wait( 0.05 );
	}
	
	flag_set( "warehouse_last_push" );
	volume = GetEnt( "underground_warehouse_volume", "targetname" );
	thread set_accuracy( volume	, "axis"	, .01 );

	autosave_by_name( "warehouse_combat_2" );

	flag_wait( "warehouse_end" );
	wait( 1 );
	level.warehouse_enemies	= array_removeDead_or_dying( level.warehouse_enemies );
	if ( level.warehouse_enemies.size > 0 )
	{
		foreach ( enemy in level.warehouse_enemies )
		{
			enemy Delete();
		}
	}
	
//	waittill_dead_or_dying( level.warehouse_enemies );
//	flag_set( "warehouse_cleared" );
}

set_accuracy_in_warehouse_back()
{
	flag_wait( "player_in_warehouse" );
	volume = GetEnt( "warehouse_volume", "targetname" );
	thread set_accuracy( volume, "axis" );
}

set_accuracy( volume, team_name, value )
{
	team_array = volume get_ai_touching_volume( team_name );

	
	if ( IsDefined( value ) )
	{
		foreach ( team_member in team_array )
		{
			team_member.accuracy	 = value;
			team_member.baseaccuracy = value;
		}
	}
	else
	{
		foreach ( team_member in team_array )
		{
			team_member.accuracy	 = 0.2;
			team_member.baseaccuracy = 1;
		}
	}
}

warehouse_right_flank()
{
	flag_wait_any( "spawn_warehouse_right_flank_enemies", "disable_right_flank_scripting" );
	
	if ( flag( "disable_right_flank_scripting" ) )
	{
		triggers = GetEntArray( "warehouse_right_flank_triggers", "targetname" );
		foreach ( trigger in triggers )
		{
			trigger trigger_off();
		}
	}
	else
	{
		array_spawn_function_targetname( "warehouse_enemies_right_flank", ::warehouse_enemies_right_flank_setup );
		warehouse_enemies_right_flank = array_spawn_targetname( "warehouse_enemies_right_flank", true ); // 3
		wait( 0.1 );
		warehouse_enemies_right_flank_2 = get_ai_group_ai( "warehouse_enemies_right_flank_2" );
		
		thread warehouse_right_flank_threatbiasgroup( warehouse_enemies_right_flank_2 );
		
		flag_wait( "advance_allies_wave_4_flag" );
		warehouse_enemies_right_flank = array_removeDead_or_dying( warehouse_enemies_right_flank );
		if ( warehouse_enemies_right_flank.size > 0 )
		{
			level.warehouse_enemies = array_combine( level.warehouse_enemies, warehouse_enemies_right_flank );
		}
	}
}

warehouse_right_flank_threatbiasgroup( enemy_array )
{
	CreateThreatBiasGroup( "ignore_group" );
	CreateThreatBiasGroup( "right_flank_enemies" );
	
	level.player SetThreatBiasGroup( "ignore_group" );
	foreach ( enemy in enemy_array )
	{
		enemy SetThreatBiasGroup( "right_flank_enemies" );
	}
	
	SetIgnoreMeGroup( "ignore_group", "right_flank_enemies" );
	
	flag_wait_or_timeout( "player_in_second_right_flank_room", 10 );
	if ( flag( "player_in_second_right_flank_room" ) )
	{
		wait( 1 );
	}
	
	level.player SetThreatBiasGroup();
}

warehouse_enemies_right_flank_setup()
{
	self endon( "death" );
	
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "warehouse_enemies_right_flank_2" )
	{
		self.ignoreall = 1;
		flag_wait_or_timeout( "send_in_warehouse_right_flank_enemies_2", 2 );
		if ( !flag( "send_in_warehouse_right_flank_enemies_2" ) )
		{
			flag_set( "send_in_warehouse_right_flank_enemies_2" );
		}
		self.ignoreall = 0;
	}
}

warehouse_enemy_ambient_setup()
{
	self endon( "death" );
	
  //  self.ignoreme	  = true;
  //  self.ignoreall  = true;
  //  self.animname	  = "generic";
  //  self.allowdeath = true;
	
//	self thread enemies_shot_at( "warehouse_enemies_ready_to_be_alert", "player_shot_at_enemies_in_warehouse" );
	
	if ( IsDefined( self.script_noteworthy ) )
	{
		self.struct = getstruct( self.script_noteworthy + "_struct", "targetname" );

		switch( self.script_noteworthy )
		{
			case "clockwork_chaos_wave_enemy":
				self.animname	= "generic";
				self.allowdeath = true;
				self gun_remove();
				self.gun_removed  = true;
				self.alert_volume = GetEnt( "warehouse_front_center_platform_volume", "targetname" );
				self thread clockwork_chaos_wave_enemy();
				break;
			case "warehouse_enemies_ambient_runners_lower":
				flag_wait( "start_ambient_warehouse_scenarios" );
				self thread warehouse_enemy_ambient_runners_setup();
				break;
//			case "warehouse_enemies_ambient_runners_left_upper":
//				flag_wait( "start_ambient_warehouse_scenarios" );
//				self thread warehouse_enemy_ambient_runners_setup();
//				break;
			case "warehouse_enemies_ambient_runners_right_upper":
				flag_wait( "start_ambient_warehouse_scenarios" );
				self thread warehouse_enemy_ambient_runners_setup();
				break;
		}
	}
	
//	flag_wait_any( "player_too_close_to_enemies_in_warehouse", "player_shot_at_enemies_in_warehouse" );
//	self alert_enemies_react();
	
//	self SetGoalVolumeAuto( self.alert_volume );
}

warehouse_enemy_lift_setup()
{
	self endon( "death" );
	
	self.accuracy  = 0.01;
	self.ignoreall = 1;
	self.animname  = "generic";
	
	self thread enemies_shot_at( "warehouse_enemies_alerted", "start_ambient_warehouse_scenarios", "player_shot_at_enemies_in_warehouse" );
	
	if ( IsDefined( self.script_noteworthy ) )
	{
		switch( self.script_noteworthy )
		{
			case "clockwork_chaos_extinguisher_enemy":
				self.struct	= level.clockwork_chaos_extinguisher_enemy_origin;
				self LinkTo( self.struct, "tag_origin" );
				self.idleanim = "clockwork_chaos_extinguisher_idle";
				self thread play_idle_anims();
				break;
			case "clockwork_checkpoint_lean_rail_enemy":
				self.struct	= level.clockwork_checkpoint_lean_rail_enemy_origin;
				self LinkTo( self.struct, "tag_origin" );
				self.idleanim = "clockwork_checkpoint_lean_rail_enemy";
				self thread play_idle_anims();
				break;
		}	
	}
	
	flag_wait_any( "elevator_landed", "player_shot_at_enemies_in_warehouse" );
	
	if ( !flag( "warehouse_enemies_alerted" ) )
	{
		flag_set( "warehouse_enemies_alerted" );
	}
	
	self alert_enemies_react();
	
	if ( !flag( "lift_landed" ) )
	{
		flag_wait( "lift_landed" );
		wait( 1 );
		self Unlink();
		self.health				= 5;
	}
	
	self set_fixednode_false();
	volume		= GetEnt( "warehouse_middle_1_volume", "targetname" );
	self SetGoalVolumeAuto( volume );

	level.warehouse_enemies = add_to_array( level.warehouse_enemies, self );
}

warehouse_enemy_setup()
{
	self endon( "death" );
		
	self.ignoreall = 1;
	self.animname  = "generic";
	
	if ( IsDefined( self.script_noteworthy ) )
	{
		switch( self.script_noteworthy )
		{
			case "warehouse_enemies_talking_guys":
				thread animated_warehouse_guys();
				break;
			case "warehouse_enemies_run_in_1":
				self.ignoreme = 1;
				flag_wait( "elevator_landed" );
				self.ignoreall = 0;
				self.ignoreme  = 0;
		}
	}

}

animated_warehouse_guys()
{
	self thread anim_single_solo( self, self.animation );
	
	flag_wait_any( "elevator_landed", "player_shot_at_enemies_in_warehouse" );
	
	if ( !flag( "warehouse_enemies_alerted" ) )
	{
		flag_set( "warehouse_enemies_alerted" );
	}
	
	self alert_enemies_react();
	
	volume		= GetEnt( "warehouse_front_volume", "targetname" );
	self SetGoalVolumeAuto( volume );
}

clockwork_chaos_wave_enemy()
{
	self endon( "death" );
	self endon( "alerted" );
	
	self.struct anim_first_frame_solo( self, "clockwork_chaos_wave_guard" );	

	flag_wait( "start_ambient_warehouse_scenarios" );
	
	self.struct anim_single_solo( self, "clockwork_chaos_wave_guard" );	
	
	volume		= GetEnt( "warehouse_enemies_ambient_runners_lower_volume", "targetname" );
	self SetGoalVolumeAuto( volume );
	self run_out_behavior( volume, "player_on_train_platform" );
}

warehouse_enemy_ambient_runners_setup()
{
	self endon( "death" );
	self endon( "alerted" );
	
	self.ignoreall = true;
	
	if ( IsDefined( self.script_delay ) )
	{
		wait( self.script_delay );
	}
	
	self set_fixednode_false();
	volume = GetEnt( self.script_noteworthy + "_volume", "targetname" );
	self SetGoalVolumeAuto( volume );
	if ( self.script_noteworthy != "warehouse_enemies_ambient_runners_upper" )
	{
		self run_out_behavior( volume, "player_on_train_platform" );
	}
}

warehouse_enemy_upper_setup()
{
	self endon( "death" );
	
	self.accuracy	   = 0.01;
	self.base_accuracy = 0.01;
	
	if ( cointoss() )
	{
		self.favoriteenemy = level.allies[ 0 ];
	}
	else
	{
		self.favoriteenemy = level.allies[ 1 ];
	}
		
	
	flag_wait( "warehouse_end" );
	wait( 1 );
	self Delete();
}

safe_activate_trigger_with_targetname( msg )
{
    TOUCH_ONCE = 64;
    
    trigger = GetEnt( msg, "targetname" );
    if ( IsDefined( trigger ) && !IsDefined( trigger.trigger_off ) )
    {
        trigger activate_trigger();
        
        if ( IsDefined( trigger.spawnflags ) && ( trigger.spawnflags & TOUCH_ONCE ) )
        {
            trigger trigger_off();
        }
    }
}

retreat_from_vol_to_vol( from_vol, retreat_vol, delay_min, delay_max )
{
	AssertEx ( ( ( IsDefined( retreat_vol ) && IsDefined( from_vol ) ) ), "Need the two info volume names ." );

	checkvol		 = GetEnt( from_vol, "targetname" );
	retreaters		 = checkvol get_ai_touching_volume( "axis" );
	goalvolume		 = GetEnt( retreat_vol, "targetname" );
	goalvolumetarget = GetNode( goalvolume.target, "targetname" );
	
	foreach ( retreater in retreaters )
	{
		if ( IsDefined( retreater ) && IsAlive( retreater ) )
		{
			retreater.forcegoal			= 0;
			retreater.fixednode			= 0;
			retreater.pathRandomPercent = RandomIntRange( 75, 100 );
			retreater SetGoalNode( goalvolumetarget );
			retreater SetGoalVolumeAuto( goalvolume );		
					
		}
	}
}

check_trigger_flagset( targetname )
{
	trigger = GetEnt( targetname, "targetname" );
	
	trigger waittill( "trigger" );

	if ( IsDefined( trigger.script_flag_set ) )
	{
		flag_set( trigger.script_flag_set );
	}
}

exit_on_train()
{
	thread train_car();
	
	flag_wait( "player_train_trigger" );
	level.player.ignoreme = 1;
	//thread animate_player_to_train();
	
	flag_set( "player_on_train" );
	
	objective_complete( obj( "train" ) );
	
	thread delete_all_vehicles();
	
	wait( 6 );
	
	flag_set( "warehouse_end" );
	level.player.ignoreme = 0;
}

train_car()
{
	train_car_entities		   = GetEntArray( "satfarm_train_cars", "script_noteworthy" );
	train_car_struct		   = getstruct( "train_car_struct", "targetname" );
	level.train_car_tag_origin = train_car_struct spawn_tag_origin();
	
	foreach ( train_car_entity in train_car_entities )
	{
		train_car_entity LinkTo( level.train_car_tag_origin, "tag_origin" );
	}
	
	flag_wait( "start_ambient_warehouse_scenarios" );
	train_car_struct_2 = getstruct( "train_car_struct_2", "targetname" );
	level.train_car_tag_origin MoveTo( train_car_struct_2.origin, 20, 0, 8 );
	wait( 20 );
	
	flag_wait_any( "warehouse_last_push", "player_on_train_platform" );
	Objective_OnEntity( obj( "train" ), level.train_car_tag_origin, ( -280, -419, 105 ) );
	
	level.player_train_origin = GetEnt( "player_train_origin", "targetname" );
	level.player_train_origin LinkTo( level.train_car_tag_origin, "tag_origin" );
	
	level.ghost1_train_origin = GetEnt( "ghost1_train_origin", "targetname" );
	level.ghost1_train_origin LinkTo( level.train_car_tag_origin, "tag_origin" );
	
	level.ghost2_train_origin = GetEnt( "ghost2_train_origin", "targetname" );
	level.ghost2_train_origin LinkTo( level.train_car_tag_origin, "tag_origin" );
	
	level.player_train_trigger trigger_on();
	
	level.player_train_trigger EnableLinkTo();
	level.player_train_trigger LinkTo( level.train_car_tag_origin, "tag_origin" );

	train_car_player_fail_struct = getstruct( "train_car_player_fail_struct", "targetname" );
	level.train_car_tag_origin MoveTo( train_car_player_fail_struct.origin, 25, 8, 0 );
	wait( 25 );
	
	if ( !flag( "player_train_trigger" ) )
	{
		level.player_train_trigger trigger_off();
		//"You failed to reach the train."
		SetDvar( "ui_deadquote", &"SATFARM_FAIL_TRAIN" );
		missionFailedWrapper();
	}
	
	if ( !flag( "warehouse_end" ) )
	{
		train_car_end = getstruct( "train_car_end_struct", "targetname" );
		level.train_car_tag_origin MoveTo( train_car_end.origin, 10, 0, 0 );
		wait( 10 );
	}
	
//	flag_wait( "warehouse_end" );
	
	foreach ( car in train_car_entities )
	{
		car Delete();
	}
	
	level.player_train_origin Delete();
	
	level.ghost2_train_origin Delete();
	
	level.ghost1_train_origin Delete();
	
	level.train_car_tag_origin Delete();

}

animate_player_to_train()
{
	player_tag_origin = level.player spawn_tag_origin();
	level.player PlayerLinkToDelta( player_tag_origin, "tag_origin", 0, 180, 180, 15, 15 );
	
	player_tag_origin MoveTo( level.player_train_origin.origin, 0.5, 0, 0 );
	player_tag_origin RotateTo( level.player_train_origin.angles, 0.5, 0, 0 );
	wait( 0.5 );
	player_tag_origin LinkTo( level.train_car_tag_origin, "tag_origin" );
	flag_set( "player_on_train" );
}

allies_movement_warehouse()
{	
	thread allies_vo_warehouse();
	
	volume = GetEnt( "warehouse_elevator_volume", "targetname" );
	while ( 1 )
	{
		alltouching = true;
		foreach ( ally in level.allies )
		{
			if ( !ally IsTouching( volume ) )
			{
				alltouching = false;
			}
		}
		if ( alltouching )
		{
			flag_set( "allies_in_elevator" );
			break;
		}
		wait( 0.05 );
	}
	
	level.allies[ 0 ] thread super_human( true );
	level.allies[ 1 ] thread super_human( true );
	level.allies[ 0 ] .ignoreall = 1;
	level.allies[ 1 ] .ignoreall = 1;
	
	flag_wait( "warehouse_enemies_alerted" );
	wait( 0.5 );
	level.allies[ 0 ] .ignoreall = 0;
	level.allies[ 1 ] .ignoreall = 0;
	
	flag_wait( "unload_elevator" );
	
	safe_activate_trigger_with_targetname( "move_allies_into_warehouse" );
	
	flag_wait( "player_in_warehouse" );
	level.allies[ 0 ] thread super_human();
	level.allies[ 1 ] thread super_human();
	
//	flag_wait( "warehouse_last_push" );
  //  level.allies[ 0 ] .accuracy = 10.0;
  //  level.allies[ 1 ] .accuracy = 10.0;
	
	flag_wait_any( "warehouse_last_push", "player_on_train_platform" );
	wait( 0.1 );
	level.allies[ 0 ] thread animate_allies_to_train();
	level.allies[ 1 ] thread animate_allies_to_train();
	
	flag_wait( "warehouse_end" );
	wait( 5 );
	foreach ( ally in level.allies )
	{
		if ( IsDefined( ally.magic_bullet_shield ) )
	 	{
	    	ally stop_magic_bullet_shield();
	    	ally Delete();
		}	
	}
}

allies_vo_warehouse()
{
	flag_wait( "start_ambient_warehouse_scenarios" );
	wait( 0.5 );
	
	//Merrick: There's the train, straight ahead.
	radio_dialog_add_and_go( "satfarm_mrk_theresthetrainstraight" );
	
	flag_wait( "warehouse_enemies_alerted" );
	battlechatter_on( "allies" );
	
	flag_wait_any( "warehouse_last_push", "player_on_train_platform" );
	wait( 1 );
	
	//Merrick: Train's leaving. Let's go!
	radio_dialog_add_and_go( "satfarm_mrk_trainsleavingletsgo" );
	
//	thread train_nag();
	
	flag_wait( "player_train_trigger" );
	//Merrick: Overlord, area is secure, Ghost Team moving to intercept target.
	radio_dialog_add_and_go( "satfarm_mrk_overlordareaissecure" );
	wait( 0.5 );
	//Overlord: Overlord copies all. 
	radio_dialog_add_and_go( "satfarm_hqr_overlordcopiesall" );
}

train_nag()
{
	wait( 4 );
	if ( !flag( "player_train_trigger" ) )
	{
		//Merrick: Get on the train!
		radio_dialog_add_and_go( "satfarm_mrk_getonthetrain" );
	}
}

animate_allies_to_train()
{
	level endon( "warehouse_end" );
	
	self PushPlayer( true );
	self disable_ai_color();
	self thread super_human( true );
	self.ignoreall = 1;
	self enable_sprint();

	if ( self.animname == "merrick" )
	{
		goal = level.ghost1_train_origin;
	}
	else
	{
		goal = level.ghost2_train_origin;
	}

	self.goalradius = 32;
	goal.goalradius = 64;
	self SetGoalEntity( goal, 1 );
	
	while ( 1 )
	{
		if ( Distance( self.origin, goal.origin ) < goal.goalradius + 10 )
		//if(DistanceSquared( self.origin, goal.origin ) < goal.goalradius * goal.goalradius ) 
			break;
		wait( 0.05 );
	}
	
	ally_tag_origin = goal spawn_tag_origin();
	ally_tag_origin LinkTo( level.train_car_tag_origin, "tag_origin" );
	self LinkTo( ally_tag_origin, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	goal anim_single_solo( self, "traverse40_2_cover" );
	self.ignoreall = 0;
}

ambient_building_explosions()
{
	level endon( "warehouse_end" );
	
	sound_struct		  = undefined;
	ceiling_dust_fx_array = undefined;
	
	second_floor_volume = GetEnt( "control_tower_building_second_floor_volume", "targetname" );
	first_floor_volume	= GetEnt( "control_tower_building_first_floor_volume", "targetname" );
	
	while ( !flag( "start_ambient_warehouse_scenarios" ) )
	{
		if ( level.player IsTouching( first_floor_volume ) )
		{
			ceiling_dust_fx_array = getstructarray( "ceiling_dust_fx_first_floor", "script_noteworthy" );
		}
		else if ( level.player IsTouching( second_floor_volume ) )
		{
			ceiling_dust_fx_array = getstructarray( "ceiling_dust_fx_second_floor", "script_noteworthy" );
		}
		
		foreach ( ceiling_dust_fx in ceiling_dust_fx_array )
		{
			if ( IsDefined( ceiling_dust_fx.script_fxid ) )
			{
				PlayFX( getfx( ceiling_dust_fx.script_fxid ), ceiling_dust_fx.origin );
			}
		}
		
		random = RandomFloatRange( 0.1, .4 );
		Earthquake( random, 1, level.player.origin, 512 );
		mortar_explosion_sound_struct_array = getstructarray( "mortar_explosion_sound_struct", "targetname" );
		sound_struct						= getClosest( level.player.origin, mortar_explosion_sound_struct_array );
		thread play_sound_in_space( "mortar_explosion_intro", sound_struct.origin );
		
		wait( RandomFloatRange( 8, 12 ) );
	}
	
	while ( 1 )
	{
		ceiling_dust_fx_array = getstructarray( "ceiling_dust_fx_warehouse", "script_noteworthy" );

		foreach ( ceiling_dust_fx in ceiling_dust_fx_array )
		{
			if ( IsDefined( ceiling_dust_fx.script_fxid ) )
			{
				PlayFX( getfx( ceiling_dust_fx.script_fxid ), ceiling_dust_fx.origin );
			}
		}
		
		random = RandomFloatRange( 0.1, .4 );
		Earthquake( random, 1, level.player.origin, 512 );
		mortar_explosion_sound_struct_array = getstructarray( "mortar_explosion_sound_struct", "targetname" );
		sound_struct						= getClosest( level.player.origin, mortar_explosion_sound_struct_array );
		thread play_sound_in_space( "mortar_explosion_intro", sound_struct.origin );
		
		wait( RandomFloatRange( 8, 12 ) );
	}
}

            /*------------------------------------------------ */
            /*------------------ RED LIGHTS------------------ */
            /*------------------------------------------------ */
#using_animtree( "animated_props" );
wall_light_spinner()
{
	vertical_spinners = GetEntArray( "vertical_spinner", "targetname" );
	array_thread( vertical_spinners, ::vertical_spinners_think );
	
	flag_wait( "warehouse_end" );
	foreach ( vertical_spinner in vertical_spinners )
	{
		if ( IsDefined( vertical_spinner ) )
		{
			vertical_spinner Delete();
		}
	}
}

vertical_spinners_think()
{
	level endon( "warehouse_end" );
	
	self UseAnimTree(#animtree );
	self SetAnim( %launchfacility_b_emergencylight, 1, 0.1, 1.0 );
}

wall_lights()
{
	light = GetEntArray( "wall_light", "targetname" );
	array_thread( light, ::wall_lights_think );
	
	flag_wait( "warehouse_end" );
	foreach ( lighta in light )
	{
		if ( IsDefined( lighta ) )
		{
			lighta Delete();
		}
	}
}

wall_lights_think()
{
	level endon( "warehouse_end" );
	
	time = 5000;

	while ( true )
	{
		self RotateVelocity( ( 360, 0, 0 ), time );
		wait time;
	}
}