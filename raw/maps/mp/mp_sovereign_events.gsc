#include common_scripts\utility;
#include maps\mp\_utility;

assembly_line()
{	
	level thread script_mover_connect_watch();
	assembly_line_animate();
}

assembly_line_precache()
{
	PrecacheMpAnim( "mp_sovereign_assembly_line_front_piece" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station01_arm_A" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station01_arm_A_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station01_arm_B" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station01_arm_B_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_A" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_A_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_B" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_B_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_C" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_C_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_D" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station02_arm_D_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_A" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_A_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_B" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_B_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_C" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_C_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_D" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station03_arm_D_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station04_arm_A" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station04_arm_A_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station04_arm_B" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station04_arm_B_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station04_arm_C" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station04_arm_C_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station05_arm_A" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station05_arm_A_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station05_arm_B" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station05_arm_B_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station05_arm_C" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station05_arm_C_idle" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station06_arm_A" );
	PrecacheMpAnim( "mp_sovereign_assembly_line_station06_arm_A_idle" );
	
	level._effect["tank_part_explode"] = LoadFX("fx/props/barrelexp");
	level._effect["tank_part_burn"] = LoadFX( "fx/fire/propane_large_fire" );
	level._effect["tank_part_extinguish"] = LoadFX( "vfx/ambient/steam/vfx_steam_escape" );
}

#using_animtree( "animated_props" );
assembly_line_animate()
{	
	initialize_arms();

	num_tanks		   = 3;
	time_between_tanks = 25;
	
	level.next_destructible_tank = RandomIntRange(4,6);
	for ( i = 0; i < num_tanks; i++ )
	{
		collision_brush = GetEnt( "tank_chassis_collision" + ( i + 1 ), "targetname" );
		level thread assembly_line_piece( collision_brush );
		wait( time_between_tanks );
	}
}

initialize_arms()
{
	arm1a = GetEnt( "factory_assembly_line_front_station01_arm_a", "targetname" );
	arm1b = GetEnt( "factory_assembly_line_front_station01_arm_b", "targetname" );
	arm1a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station01_arm_A_idle" );
	arm1b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station01_arm_B_idle" );
	
	arm2a = GetEnt( "factory_assembly_line_front_station02_arm_a", "targetname" );
	arm2b = GetEnt( "factory_assembly_line_front_station02_arm_b", "targetname" );
	arm2c = GetEnt( "factory_assembly_line_front_station02_arm_c", "targetname" );
	arm2d = GetEnt( "factory_assembly_line_front_station02_arm_d", "targetname" );
	arm2a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_A_idle" );
	arm2b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_B_idle" );
	arm2c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_C_idle" );
	arm2d ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_D_idle" );
	
	arm3a = GetEnt( "factory_assembly_line_front_station03_arm_a", "targetname" );
	arm3b = GetEnt( "factory_assembly_line_front_station03_arm_b", "targetname" );
	arm3c = GetEnt( "factory_assembly_line_front_station03_arm_c", "targetname" );
	arm3d = GetEnt( "factory_assembly_line_front_station03_arm_d", "targetname" );
	arm3a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_A_idle" );
	arm3b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_B_idle" );
	arm3c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_C_idle" );
	arm3d ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_D_idle" );
	
	arm4a = GetEnt( "factory_assembly_line_front_station04_arm_a", "targetname" );
	arm4b = GetEnt( "factory_assembly_line_front_station04_arm_b", "targetname" );
	arm4c = GetEnt( "factory_assembly_line_front_station04_arm_c", "targetname" );
	arm4a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station04_arm_A_idle" );
	arm4b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station04_arm_B_idle" );
	arm4c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station04_arm_C_idle" );	
	
// NOTE: the differences between the arm names and the animations played in stations 5 and 6 are due to confusion the animator had with the level designer, and are intentional in scripting

// Model layout:
//			5c
//  5b	    6a
//          6b

// Animation layout:
//			5a
//	5b		5c
//			6a

	arm5b = GetEnt( "factory_assembly_line_front_station05_arm_b", "targetname" );
	arm5c = GetEnt( "factory_assembly_line_front_station05_arm_c", "targetname" );
	arm5b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station05_arm_B_idle" );
	arm5c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station05_arm_A_idle" );
	
	arm6a = GetEnt( "factory_assembly_line_front_station06_arm_a", "targetname" );
	arm6b = GetEnt( "factory_assembly_line_front_station06_arm_b", "targetname" );
	arm6a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station05_arm_C_idle" );
	arm6b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station06_arm_A_idle" );
}


assembly_line_piece( collision_brush )
{
	assembly_line_start_pos = getstruct( "assembly_start_point", "targetname" );
	
	assembly_piece = Spawn( "script_model", assembly_line_start_pos.origin );
	assembly_piece.angles = assembly_line_start_pos.angles;
	assembly_piece SetModel( "mp_sovereign_assembly_moving_front_piece" );
	
	collision_brush.origin = assembly_piece GetTagOrigin( "tag_origin" );
	collision_brush LinkTo( assembly_piece, "tag_origin" );
	
	//Set up exploding barrel part
	assembly_piece.parts = [];
	if(IsDefined(assembly_line_start_pos.target))
	{
		parts = GetEntArray(assembly_line_start_pos.target, "targetname");
		foreach(part in parts)
		{
			part_copy = spawn("script_model", part.origin);
			part_copy.angles = part.angles;
			part_copy SetModel(part.model);
			
			if(IsDefined(part.target))
			{
				collision = GetEnt(part.target, "targetname");
				if(IsDefined(collision))
				{
					//part_copy CloneBrushmodelToScriptmodel(collision);
				}
			}
			
			part_copy LinkTo(assembly_piece);
			part_copy assembly_line_tank_part_visible(false);
			part_copy.parent = assembly_piece;
			assembly_piece.parts[assembly_piece.parts.size] = part_copy;
		}
	}
	
	assembly_piece thread assembly_line_tank_damage_watch();
	while ( 1 )
	{
		level.next_destructible_tank--;
		
		if(level.next_destructible_tank<=0)
		{
			foreach(part in assembly_piece.parts)
			{
				part assembly_line_tank_part_visible(true);
			}
			level.next_destructible_tank = RandomIntRange(9,12);
		}
		
		assembly_piece ScriptModelPlayAnimDeltaMotion( "mp_sovereign_assembly_line_front_piece" );
		
		fullAnimLength = GetAnimLength( %mp_sovereign_assembly_line_front_piece );
		thread animate_arms( fullAnimLength );
		wait( fullAnimLength );

		assembly_piece ScriptModelClearAnim();
		assembly_piece.origin = assembly_line_start_pos.origin;
		assembly_piece.angles = assembly_line_start_pos.angles;
		
		//Turn off parts/Reset Health
		foreach(part in assembly_piece.parts)
		{
			part assembly_line_tank_part_visible(false);
		}
	}	
}

assembly_line_tank_damage_watch()
{
	while(1)
	{
		self waittill("part_destroyed", attacker);
		foreach(part in self.parts)
		{
			part thread assembly_line_tank_part_explode(attacker);
			part thread assembly_line_tank_part_visible(false);	
		}
		
		wait 1;
		level notify("activate_halon_system");
		wait 4;
		
		foreach(part in self.parts)
		{
			part thread assembly_line_tank_part_extinguish();
		}

	}
}

assembly_line_tank_part_visible(visible)
{
	if(IsDefined(self.is_visable) && self.is_visable==visible)
		return;
	
	if(visible)
	{
		self SetModel(self.visable_model);
		self SetContents(self.visable_contents);
		self thread assembly_line_tank_part_damage_watch();
	}
	else
	{
		self.visable_model = self.model;
		self SetModel("tag_origin");
		self.visable_contents = self SetContents(0);
		self assembly_line_tank_part_damage_watch_end();
	}
	
	self.is_visable=visible;
}

assembly_line_tank_part_damage_watch()
{
	self endon("stop_tank_part_damage_watch");
	self.health = 50;
	self SetCanDamage(true);
	self.last_attacker=undefined;
	while(self.health>0)
	{
		self waittill("damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags);
		self.last_attacker = attacker;
	}
	self waittill("death");
	self.parent notify("part_destroyed", self.last_attacker);
}

assembly_line_tank_part_explode(attacker)
{
	self PlaySound("barrel_mtl_explode");
	
	PlayFXOnTag(level._effect["tank_part_explode"], self, "tag_origin");
	
	PlayFXOnTag(level._effect["tank_part_burn"], self, "tag_origin");
	if(!IsDefined(attacker))
		attacker = self;
	RadiusDamage( self.origin, 400, 300, 50, attacker, "MOD_EXPLOSIVE" );
}

assembly_line_tank_part_extinguish()
{
	StopFXOnTag(level._effect["tank_part_burn"], self, "tag_origin");
	
	PlayFXOnTag(level._effect["tank_part_extinguish"], self, "tag_origin");	
}

assembly_line_tank_part_damage_watch_end()
{
	self notify("stop_tank_part_damage_watch");
	self SetCanDamage(false);
}

animate_arms( fullAnimLength )
{
	front_station_01_times = GetNotetrackTimes( %mp_sovereign_assembly_line_front_piece, "front_station_01_start" );
	front_station_02_times = GetNotetrackTimes( %mp_sovereign_assembly_line_front_piece, "front_station_02_start" );
	front_station_03_times = GetNotetrackTimes( %mp_sovereign_assembly_line_front_piece, "front_station_03_start" );
	front_station_04_times = GetNotetrackTimes( %mp_sovereign_assembly_line_front_piece, "front_station_04_start" );
	front_station_05_times = GetNotetrackTimes( %mp_sovereign_assembly_line_front_piece, "front_station_05_start" );
	front_station_06_times = GetNotetrackTimes( %mp_sovereign_assembly_line_front_piece, "front_station_06_start" );
			 //   timer 									    func 					   
	delayThread( front_station_01_times[ 0 ] * fullAnimLength, ::animate_front_station_01 );
	delayThread( front_station_02_times[ 0 ] * fullAnimLength, ::animate_front_station_02 );
	delayThread( front_station_03_times[ 0 ] * fullAnimLength, ::animate_front_station_03 );
	delayThread( front_station_04_times[ 0 ] * fullAnimLength, ::animate_front_station_04 );
	delayThread( front_station_05_times[ 0 ] * fullAnimLength, ::animate_front_station_05 );
	delayThread( front_station_06_times[ 0 ] * fullAnimLength, ::animate_front_station_06 );
		
}

animate_front_station_01()
{
	arm1a = GetEnt( "factory_assembly_line_front_station01_arm_a", "targetname" );
	arm1b = GetEnt( "factory_assembly_line_front_station01_arm_b", "targetname" );
	arm1a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station01_arm_A" );
	arm1b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station01_arm_B" );	
}

animate_front_station_02()
{
	arm2a = GetEnt( "factory_assembly_line_front_station02_arm_a", "targetname" );
	arm2b = GetEnt( "factory_assembly_line_front_station02_arm_b", "targetname" );
	arm2c = GetEnt( "factory_assembly_line_front_station02_arm_c", "targetname" );
	arm2d = GetEnt( "factory_assembly_line_front_station02_arm_d", "targetname" );
	arm2a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_A" );
	arm2b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_B" );
	arm2c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_C" );
	arm2d ScriptModelPlayAnim( "mp_sovereign_assembly_line_station02_arm_D" );
}

animate_front_station_03()
{
	arm3a = GetEnt( "factory_assembly_line_front_station03_arm_a", "targetname" );
	arm3b = GetEnt( "factory_assembly_line_front_station03_arm_b", "targetname" );
	arm3c = GetEnt( "factory_assembly_line_front_station03_arm_c", "targetname" );
	arm3d = GetEnt( "factory_assembly_line_front_station03_arm_d", "targetname" );
	arm3a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_A" );
	arm3b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_B" );
	arm3c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_C" );
	arm3d ScriptModelPlayAnim( "mp_sovereign_assembly_line_station03_arm_D" );
}

animate_front_station_04()
{
	arm4a = GetEnt( "factory_assembly_line_front_station04_arm_a", "targetname" );
	arm4b = GetEnt( "factory_assembly_line_front_station04_arm_b", "targetname" );
	arm4c = GetEnt( "factory_assembly_line_front_station04_arm_c", "targetname" );
	arm4a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station04_arm_A" );
	arm4b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station04_arm_B" );
	arm4c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station04_arm_C" );
}

// NOTE: the differences between the arm names and the animations played in stations 5 and 6 are due to confusion the animator had with the level designer, and are intentional in scripting

// Model layout:
//			5c
//  5b	    6a
//          6b

// Animation layout:
//			5a
//	5b		5c
//			6a

animate_front_station_05()
{
	// arm5a doesn't exist in the map
	
//	arm5a = GetEnt( "factory_assembly_line_front_station05_arm_a", "targetname" );
	arm5b = GetEnt( "factory_assembly_line_front_station05_arm_b", "targetname" );
	arm5c = GetEnt( "factory_assembly_line_front_station05_arm_c", "targetname" );
//	arm5a ScriptModelPlayAnim( "factory_assembly_line_front_station05_arm_A" );
	arm5b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station05_arm_B" );
	arm5c ScriptModelPlayAnim( "mp_sovereign_assembly_line_station05_arm_A" );
}

animate_front_station_06()
{
	arm6a = GetEnt( "factory_assembly_line_front_station06_arm_a", "targetname" );
	arm6b = GetEnt( "factory_assembly_line_front_station06_arm_b", "targetname" );
	arm6a ScriptModelPlayAnim( "mp_sovereign_assembly_line_station05_arm_C" );
	arm6b ScriptModelPlayAnim( "mp_sovereign_assembly_line_station06_arm_A" );	
}

script_mover_connect_watch()
{
	while(1)
	{
		level waittill("connected", player);
		player thread player_unresolved_collision_watch();
	}
}

player_unresolved_collision_watch()
{
	self endon( "disconnect" );
	
	self.unresolved_collision = undefined;
	self thread player_unresolved_collision_update();
	
	while ( 1 )
	{
		while ( !IsDefined( self.unresolved_collision ) )
		{
			wait 0.05;
		}
		
		unresolved_collision_count = 0;
		
		while ( IsDefined( self.unresolved_collision ) )
		{
			unresolved_collision_count++;
			unresolved_collision_kill_count = self.unresolved_collision script_mover_get_num_unresolved_collisions();
			if ( unresolved_collision_count > unresolved_collision_kill_count )
			{
				playerNum = self GetEntityNumber();
				moverNum  = self.unresolved_collision GetEntityNumber();
				PrintLn( "Unresolved Collision (" + unresolved_collision_kill_count + ") - Player: " + playerNum + " " + self.origin + " Mover: " + moverNum + " " + self.unresolved_collision.origin );
				self _suicide();
			}
			self.unresolved_collision = undefined;
			wait 0.05;
		}
	}
}

script_mover_get_num_unresolved_collisions()
{	
	return 1;
}

player_unresolved_collision_update()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "unresolved_collision", mover );
		if ( self IsMantling() )
			continue;
		if ( mover script_mover_get_num_unresolved_collisions() < 0 )
			continue;
		
		self.unresolved_collision = mover;
	}
}


halon_system()
{
	level.vision_set_stage = 0;
	level thread halon_system_spawn_watch();
	
	/#
		level thread halon_system_test();
	#/

	while(1)
	{
		level waittill("activate_halon_system");
		
		level thread halon_system_run();
	
	}
}

halon_system_run()
{
	fade_in_time = 2;
	fade_out_time = 10;
	
	alarm_sound_ents = getEntArray("halon_alarm_sound", "targetname");
	fan_sound_ents = getEntArray("halon_fan_sound", "targetname");
	
	foreach(ent in alarm_sound_ents)
	{
		ent PlayLoopSound("halon_fire_alarm_lp");
	}
	
	wait 2;
	
	exploder(1);
	wait .5;
	
	level.vision_set_stage = 1;
	foreach(player in level.players)
	{
		player VisionSetStage(level.vision_set_stage, fade_in_time);
	}
	
	wait 5;
	foreach(ent in alarm_sound_ents)
	{
		ent StopLoopSound();
	}
	
	wait 10;
	
	foreach(ent in fan_sound_ents)
	{
		ent PlayLoopSound("halon_fans");
	}
	
	level.vision_set_stage = 0;
	foreach(player in level.players)
	{
		player VisionSetStage(level.vision_set_stage, fade_out_time);
	}
	
	wait fade_out_time;
		
	foreach(ent in fan_sound_ents)
	{
		ent StopLoopSound();
	}
	
}

halon_system_spawn_watch()
{
	while(1)
	{
		level waittill( "player_spawned", player );
		if(IsDefined(level.vision_set_stage))
			player VisionSetStage(level.vision_set_stage, .1);	
	}
}

/#
halon_system_test()
{
	dvar_name = "trigger_halon";
	default_value = 0;
	SetDevDvarIfUninitialized(dvar_name, default_value);
	while(1)
	{
		value = GetDvarInt(dvar_name, default_value);
		if(!value)
		{
			waitframe();
		}
		else
		{
			level notify("activate_halon_system");
			SetDvar(dvar_name, default_value);
		}
	}
}	
#/
