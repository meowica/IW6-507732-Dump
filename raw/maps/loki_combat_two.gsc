#include maps\_utility;
#include common_scripts\utility;
#include maps\loki_util;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "combat_two_done" );
	flag_init("player_is_firing");
	flag_init("combat_two_stage_1_done");
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

combat_two_start()
{
	player_move_to_checkpoint_start( "combat_two" );
	spawn_allies();

	level.allies[ 0 ] set_force_color( "r" );
	level.allies[ 1 ] set_force_color( "r" );
	level.allies[ 2 ] set_force_color( "b" );
	
	foreach ( ally in level.allies )
	{
		ally thread maps\_space_ai::handle_angled_nodes();
//		ally.attackeraccuracy = .1;
	}
	
	level.player GiveWeapon( "kriss_eotech_space" );
	level.player SwitchToWeapon( "kriss_eotech_space" );
	level.player GiveMaxAmmo( "kriss_eotech_space" );
	
	array_spawn_function( GetSpawnerTeamArray( "axis" ), ::enemy_marker );
	
	level thread trigger_enemy_spawn( "combat_two_third_wave", "combat_two_enemy_wave_3", ::wave_3_spawn_func);
	level thread trigger_enemy_spawn( "combat_two_third_wave", "combat_two_enemy_wave_3_final", ::wave_3_final_spawn_func);
	level thread trigger_enemy_spawn( "combat_two_third_wave_exta", "combat_two_enemy_wave_3_extra", ::wave_3_final_spawn_func);
	wait(1.0);
	teleport_enemies();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

combat_two()
{
	
	autosave_by_name_silent( "combat_two" );

//	ais = spawn_space_ais_from_targetname( "combat_two_enemy" );
	level thread swap_nodes_init();
	level thread spinning_object( "spinning_non_cover", true );
	level thread spinning_object( "spinning_non_cover_tank" );
//	level thread check_for_player_in_open();

	level thread ignore_player_after_time(1,3);
	level thread convert_moving_cover_enemies_to_wave_3();
	
	trigger = GetEnt( "combat_two_second_wave_retreat", "targetname" );
	thread set_flag_on_trigger(trigger, "combat_two_stage_1_done");
	
	level.allies[ 0 ] set_force_color( "r" );
	level.allies[ 1 ] set_force_color( "r" );
	level.allies[ 2 ] set_force_color( "b" );
	
//	level thread trigger_enemy_spawn("combat_two_first_wave", "combat_two_enemy_wave_1");

//	level thread trigger_enemy_spawn( "combat_two_second_wave", "combat_two_enemy_wave_2" );

//	level thread trigger_enemy_spawn( "combat_two_second_wave_2", "combat_two_enemy_wave_2_2", ::wave_2_retreat );

//	level thread trigger_enemy_spawn( "combat_two_third_wave", "combat_two_enemy_wave_3" );//, ::wave_3_dont_die);
	
	
//	level thread trigger_enemy_spawn( "combat_two_third_wave", "combat_two_enemy_wave_3_final", ::wave_3_final);
	
	
	trigger = GetEnt( "combat_two_third_wave", "targetname" );
	if ( IsDefined( trigger ) )
	{
		trigger waittill( "trigger" );
	}
	
//	level thread check_for_player_underneath();
	
	wait( 0.5 );
//	level thread send_guy_to_node_then_rotate();
	wait( 1.5 );
	
//	if(!flag("combat_two_done" ))
//	{
//		advance_volume = GetEnt( "wave_3_push_advance_volume_1", "targetname" );
//		trigger		   = GetEnt( "combat_two_third_wave_push_1", "targetname" );
//		trigger trigger_if_volume_empty( advance_volume );
//	}
//	if(!flag("combat_two_done" ))
//	{
//		advance_volume = GetEnt( "wave_3_push_advance_volume_2", "targetname" );
//		trigger		   = GetEnt( "combat_two_third_wave_push_2", "targetname" );
//		trigger trigger_if_volume_empty( advance_volume );	
//	}
	
	flag_wait( "combat_two_done" );
}

trigger_enemy_spawn( trigger_name, ai_name, spawn_func )
{
	trigger = GetEnt( trigger_name, "targetname" );
	if ( IsDefined( trigger ) )
	{
		trigger waittill( "trigger" );
	}
	
//	ai_array = GetEntArray( ai_name, "targetname" );
	
	if ( IsDefined( spawn_func ) )
	{
		ai_array = GetEntArray( ai_name, "targetname" );
		foreach ( spawner in ai_array )
		{
			spawner add_spawn_function( spawn_func );
		}			
	}
	
	ais = spawn_space_ais_from_targetname( ai_name );

	
	foreach ( ai in ais)
	{
//		ai.goalradius = 4;
//		ai thread magic_bullet_shield();
		ai.attackeraccuracy = .1;
//		ai.attackeraccuracy = 0;
	}
	

}

trigger_if_volume_empty( advance_volume )
{
	while ( IsDefined( self ) && !flag( "combat_two_done" ) )
	{
		enemies = GetAIArray( "axis" );
		empty	= true;
		foreach ( guy in enemies )
		{
			if ( guy IsTouching( advance_volume ) )
			{
				empty = false;
			}
		}
		
		if ( empty )
		{
			if ( IsDefined( self ) )
			{
				self notify( "trigger" );
				self trigger_off();
			}
			break;
		}
		wait( 0.1 );
	}
}

teleport_enemies()
{
	enemies = GetAIArray("axis");
	teleport_node = getent("combat_two_teleport_node", "targetname");
	offset = 0;
	foreach ( guy in enemies)
	{
		teleport_node.origin = teleport_node.origin + (offset,0,0);
		guy ForceTeleport(teleport_node.origin, teleport_node.angles);
		offset -= 40;
//		IPrintLn("attackeraccuracy = " + guy.attackeraccuracy);
	}	
}

wave_2_retreat()
{
	self endon( "death" );
	
	trigger1 = GetEnt( "combat_two_second_wave_retreat", "targetname" );
	trigger2 = GetEnt( "combat_two_third_wave", "targetname" );
	if ( IsDefined( trigger1 ) &&  IsDefined( trigger2 ))
	{
		waittill_any_ents(trigger1, "trigger", trigger2, "trigger");
	}
	
	volume = GetEnt( "wave_2_retreat_volume", "targetname" );		
	self SetGoalVolumeAuto( volume );
	
	if(isdefined(trigger2))
	{
		trigger2 waittill("trigger");
	}
	
	orig_volume = GetEnt( "wave_3_everywhere_above_goal_volume", "targetname" );
	self thread swap_goal_volumes(orig_volume);
}

convert_moving_cover_enemies_to_wave_3()
{
	trigger = getent("ignore_volume","targetname");
	trigger waittill("trigger");
	
	enemies = GetAIArray("axis");
	wave_3 = get_ai_group_ai("combat_two_enemies");
	
	foreach ( guy in enemies)
	{
		if(!(is_in_array(wave_3, guy)))
		{
			guy Unlink();
			guy notify("stop_follow_cover");
//			IPrintLn("stopping moving cover ai");
			guy thread wave_3_spawn_func();	
		}
	}	
}

//wave_3_side_approach()
//{
//	self endon( "death" );
//	
//	wait(.1);
//	
////	self thread magic_bullet_shield();
//	
//	self ClearGoalVolume();
//	
//	volume = GetEnt( "wave_3_everywhere_above_goal_volume", "targetname" );		
//	self SetGoalVolumeAuto( volume );
//	self.favoriteenemy = level.player;
//}

//wave_3_final()
//{
//	self endon( "death" );
//	
//	wait(.1);
//	
////	self thread magic_bullet_shield();
//	
//	self ClearGoalVolume();
//	
//	volume = GetEnt( "wave_3_push_advance_volume_2", "targetname" );		
//	self SetGoalVolumeAuto( volume );
//	self.favoriteenemy = level.player;
//}

wave_3_spawn_func()
{
	self endon("death");
	
	wait(.1);
	
	self thread set_accuracy_when_allies_are_close();
	
	orig_volume = GetEnt( "wave_3_in_debris_goal_volume", "targetname" );
	self thread swap_goal_volumes(orig_volume);

//	combat_two_second_wave_retreat
//	combat_two_second_wave_push
	
	trigger = getent("combat_two_second_wave_retreat", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
	self notify("stop_goal_volume_swap");
	
	orig_volume = GetEnt( "wave_3_safe_volume", "targetname" );
	self thread swap_goal_volumes(orig_volume);
	
	trigger = getent("combat_two_third_wave_push_1", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
	self notify("stop_goal_volume_swap");
		
	orig_volume = GetEnt( "wave_3_push_advance_volume_2", "targetname" );
	self thread swap_goal_volumes(orig_volume);	
}

wave_3_final_spawn_func()
{
	self endon("death");
	
	wait(.1);
	
	self thread set_accuracy_when_allies_are_close();
	
	orig_volume = GetEnt( "wave_3_in_debris_goal_volume", "targetname" );
	self thread swap_goal_volumes(orig_volume);

	trigger = getent("combat_two_second_wave_retreat", "targetname");
	if(IsDefined(trigger))
	{
		trigger waittill("trigger");
	}
	self notify("stop_goal_volume_swap");
	
	orig_volume = GetEnt( "wave_3_push_advance_volume_1", "targetname" );
	self thread swap_goal_volumes(orig_volume);
	
	trigger = getent("combat_two_third_wave_push_1", "targetname");
	if(isdefined(trigger))
	{
		trigger waittill("trigger");
	}
	self notify("stop_goal_volume_swap");
		
	orig_volume = GetEnt( "wave_3_push_advance_volume_2", "targetname" );
	self thread swap_goal_volumes(orig_volume);	
	
	
}

swap_goal_volumes(orig_volume)
{
	self endon("death");
	self endon("stop_goal_volume_swap");

	in_open_trigger = GetEnt( "no_cover", "targetname" );
	underneath_trigger = GetEnt( "wave_3_underside", "targetname" );
	debris_trigger = GetEnt( "ignore_volume", "targetname" );
	
	in_debris_volume = GetEnt( "wave_3_in_debris_goal_volume", "targetname" );
	in_open_volume = GetEnt( "wave_3_in_open_goal_volume", "targetname" );
	underneath_volume = GetEnt( "wave_3_everywhere_below_goal_volume", "targetname" );
//	orig_volume = GetEnt( "wave_3_everywhere_above_goal_volume", "targetname" );
	
	self SetGoalVolumeAuto( orig_volume );
	
	current_volume = orig_volume;
	old_accuracy = self.baseaccuracy;
	while(!flag("space_breach_done"))
	{
		if(level.player IsTouching(in_open_trigger) && !flag("combat_two_stage_1_done"))
		{
			if(current_volume != in_open_volume)
			{
//				IPrintLn("in open volume");
				current_volume = in_open_volume;
				self SetGoalVolumeAuto( in_open_volume );
				self.favoriteenemy = level.player;
//				self.baseaccuracy = 1;
			}
		}
		else
		{
			if(level.player IsTouching(underneath_trigger))
			{
				if(current_volume != underneath_volume)
				{
//					IPrintLn("underneath volume");
					current_volume = underneath_volume;	
					self SetGoalVolumeAuto( underneath_volume );
					self.favoriteenemy = level.player;
//					self.baseaccuracy = old_accuracy;
				}
			}
			else
			{
//				if(level.player IsTouching(debris_trigger))
//				{
//					if(current_volume != in_debris_volume)
//					{
//	//					IPrintLn("underneath volume");
//						current_volume = in_debris_volume;	
//						self SetGoalVolumeAuto( in_debris_volume );
//	//					self.favoriteenemy = level.player;
//	//					self.baseaccuracy = old_accuracy;
//					}
//				}
//				else
//				{
					if(current_volume != orig_volume)
					{
						current_volume = orig_volume;
//						IPrintLn("original volume");
					//player is in the normal place
						self SetGoalVolumeAuto( orig_volume );	
						self.favoriteenemy = undefined;
	//					self.baseaccuracy = old_accuracy;
					}
				}
//			}		
		}
		
		wait(.1);
	}
}

//check_player_in_trigger_and_set_goalvolume(check_volume, new_goal_volume)
//{
//	if(level.player IsTouching(in_open_trigger))
//	{
//		if(current_volume != in_open_volume)
//		{
//			current_volume = in_open_volume;
//			self SetGoalVolumeAuto( in_open_volume );
//		}
//	}	
//}

swap_nodes_init()
{
	triggers = GetEntArray( "swap_node_trigger", "targetname" );
	foreach ( trigger in triggers )
	{
//		trigger thread swap_nodes();
	}
}

swap_nodes()
{
	level endon( "underside" );
	if ( IsDefined( self.target ) )
	{
		while ( !flag( "combat_two_done" ) )
		{
			self waittill( "trigger", guy );
			
			wait( RandomFloatRange( 3.0, 8.0 ) );
			
			new_node = GetNode( self.target, "targetname" );
			node_claimed = true;
			node_claimed = claimed_goal_node(new_node);
			if ( IsDefined( guy ) && IsAlive( guy ) && !node_claimed)
			{
				guy SetGoalNode( new_node );
				guy.goalradius = 8;
//				guy thread set_moveplaybackrate(1.5);
				guy waittill( "goal" );
			}
			if ( IsDefined( guy ) && IsAlive( guy ) )
			{
//				guy set_moveplaybackrate(1.0);
			}
		}
	}
	
}

claimed_goal_node(new_node)
{
	ai_array = GetAIArray("axis");
	foreach ( ai in ai_array)
	{
//		pos_vector = ai GetPathGoalPos();
		pos_vector = ai.goalpos;
				
		if(IsDefined(pos_vector) && (Distance(pos_vector, new_node.origin) < 50))
		{
//			IPrintLn("goal node was claimed goalpos");
			return true;
		}
		pos_vector = ai.origin;
				
		if(IsDefined(pos_vector) && (Distance(pos_vector, new_node.origin) < 50))
		{
//			IPrintLn("goal node was claimed origin");
			return true;
		}
	}
	
	return false;		
}

//player_in_open()
//{
//	while ( !flag( "combat_two_done" ) )
//	{
//		wait( 0.1 );
//	}
//}

send_guy_to_node_then_rotate()
{
	guy = undefined;
	while ( !IsDefined( guy ) )
	{
		enemies = GetAIArray( "axis" );
		foreach ( ai in enemies )
		{
			if ( IsDefined( ai.script_noteworthy ) && ( ai.script_noteworthy == "spinning_cover_guy" ) )
			{
				guy = ai;	
			}
		}
		
//		guy = getent("spinning_cover_guy", "script_noteworthy");
		wait( 0.1 );
	}
	guy.goalradius = 4;
	guy.ignoreall  = true;
//	thread spinning_cover("spinning_crate", guy);
	thread spinning_object( "spinning_crate", true );	
	
}

//only single ents
spinning_cover( targ_name, guy )
{
	spinning_obj	  = GetEnt( targ_name, "targetname" );
	spinning_obj_clip = GetEnt( targ_name + "_clip", "targetname" );
	
	if ( IsDefined( guy ) && IsAlive( guy ) )
	{
		guy waittill( "goal" );
		guy LinkTo( spinning_obj );
		
		guy.ignoreall = false;
		spinning_obj RotateVelocity( ( 0, 0, 2 ), 9999 );
		spinning_obj_clip RotateVelocity( ( 0, 0, 2 ), 9999 );
	}	
	
	while ( IsDefined( guy ) && IsAlive( guy ) )
	{
		guy thread maps\_space_ai::doing_in_space_rotation( guy.angles, spinning_obj.angles, 4 );
		wait( 0.1 );
	}
}

//can be an array
//will link its target to itself before rotating
spinning_object( targ_name, clip )
{
	spinning_obj_array = GetEntArray( targ_name, "script_noteworthy" );
	foreach ( spinning_obj in spinning_obj_array )
	{
		if ( IsDefined( spinning_obj.target ) )
		{
			spinning_obj_clip = GetEnt( spinning_obj.target, "targetname" );
			spinning_obj_clip LinkTo( spinning_obj );
		}
		
		spinning_obj RotateVelocity( ( 0, 0, 2 ), 9999 );		
	}
}


//check_for_player_underneath()
//{
//	volume_above	  = GetEnt( "wave_3_everywhere_above_goal_volume", "targetname" );
//	volume_below	  = GetEnt( "wave_3_everywhere_below_goal_volume", "targetname" );
//	underside_trigger = GetEnt( "wave_3_underside", "targetname" );
//	
//	while ( !flag( "combat_two_done" ) )
//	{
//	
//		if ( IsDefined( underside_trigger ) )
//		{
//			underside_trigger waittill( "trigger" );
//		}
//		
//		level notify( "underside" );
//		
//		enemies = GetAIArray( "axis" );
//		
//		foreach ( guy in enemies )
//		{
//			guy SetGoalVolumeAuto( volume_below );
//			guy.favoriteenemy = level.player;
//		}
//		
//		foreach ( guy in level.allies )
//		{
//			guy.ignoreme = true;
//		}
//		
//		while ( level.player IsTouching( underside_trigger ) )
//		{
//			wait( 0.1 );
//		}
//		
//		enemies = GetAIArray( "axis" );
//		
//		foreach ( guy in enemies )
//		{
//			guy SetGoalVolumeAuto( volume_above );
//			guy.favoriteenemy = undefined;
//		}
//		
//		foreach ( guy in level.allies )
//		{
//			guy.ignoreme = false;
//		}
//	
//	}
//}

//check_for_player_in_open()
//{
//	old_accuracy = level.player.attackeraccuracy;
//	spawn_area = getent("wave_3_spawn_area", "targetname");
//	while(!flag("space_breach_done"))
//	{
//		level.player.attackeraccuracy = old_accuracy;
//		no_cover = false;
//		no_cover_volume_array = GetEntArray("no_cover", "targetname");
//		foreach ( no_cover_volume in no_cover_volume_array)
//		{
//			if(level.player istouching(no_cover_volume)	)
//			{
////				IPrintLn("accuracy 1");
////		   		level.player.attackeraccuracy = 1;
//				no_cover = true;
//			}
//		}	
//
//		if(no_cover)
//		{
//			level.player.attackeraccuracy = 1;
//			
//			enemies = GetAIArray("axis");
//			foreach ( guy in enemies)
//			{
//				if(!guy IsTouching(spawn_area))
//				{
//					guy.favoriteenemy = level.player;
//					guy setgoalentity(level.player, 100);
//					guy.baseaccuracy = 1;
//				}
//			}			
//		}
//		else
//		{
//			level.player.attackeraccuracy = old_accuracy;
//			
//			enemies = GetAIArray("axis");
//			foreach ( guy in enemies)
//			{
//				guy.favoriteenemy = undefined;
//				guy.baseaccuracy = .1;
//			}
//		}
//
//		wait(.1);
//	}	
//}

trigger_wave_3_during_moving_cover()
{
	level thread trigger_enemy_spawn( "combat_two_third_wave", "combat_two_enemy_wave_3", ::wave_3_spawn_func);
	level thread trigger_enemy_spawn( "combat_two_third_wave", "combat_two_enemy_wave_3_final", ::wave_3_final_spawn_func);
	level thread trigger_enemy_spawn( "combat_two_third_wave_exta", "combat_two_enemy_wave_3_extra", ::wave_3_final_spawn_func);
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//current set to link to the rotating pieces in moving_cover map...
link_allies_to_moving_cover()
{
	ally_nodes = GetEntArray("ally_link_to", "targetname");
	foreach ( node in ally_nodes)
	{
		debris_array = GetEntArray("post_object_new_1", "script_noteworthy");
		debris_to_link_to = getClosest(node.origin, debris_array);
		node linkto(debris_to_link_to);
	}
	
//	wait(1.0);
	
	for ( i = 0; i < ally_nodes.size; i++ )
	{
		level.allies[i] ForceTeleport(ally_nodes[i].origin, ally_nodes[i].angles);
		level.allies[i] LinkTo(ally_nodes[i]);
		level.allies[i] rotate_ally(ally_nodes[i]);
	}	
	
}

rotate_ally(spinning_obj)
{
	while ( IsDefined( self ) && IsAlive( self ) )
	{
		self thread maps\_space_ai::doing_in_space_rotation( self.angles, spinning_obj.angles, 4 );
		wait( 0.1 );
	}	
}

ignore_player_after_time(time, total_ignores)
{
	level thread set_flag_when_not_firing(time);
	trigger = getent("ignore_volume","targetname");
	while(1)
	{
		if(level.player IsTouching(trigger) && !flag("player_is_firing") && (total_ignores > 0))
		{
			if(!level.player.ignoreme)
			{
				level.player.ignoreme = true;
				total_ignores--;
//				IPrintLn("ignoring player");
			}
		}
		else
		{
			if(level.player.ignoreme)
			{
				level.player.ignoreme = false;			
//				IPrintLn("not ignoring player");
			}
		}
		wait(.1);
	}
}

set_flag_when_not_firing(time)
{
	frames_to_ignore = 60*time;
	frames = frames_to_ignore;
	while(1)
	{
		if(level.player AttackButtonPressed())
		{
			frames = 0;
			if(!flag("player_is_firing"))
			{
				flag_set("player_is_firing");
//				IPrintLn("setting player_is_firing");
			}
		}
		else
		{
			frames++;
		}
		if(frames > frames_to_ignore)
		{
			if(flag("player_is_firing"))
			{
				flag_clear("player_is_firing");
//				IPrintLn("clearing player_is_firing");
			}
		}
		waitframe();
	}
}

set_accuracy_when_allies_are_close()
{
	self endon("death");
	while(1)
	{
		foreach ( guy in level.allies)
		{
			if(distance(self.origin, guy.origin) < 200)
			{
				self.attackeraccuracy = 1;	
			}
		}
		
		wait(.1);
	}
}

fake_function()
{
//level thread link_allies_to_cover();

level.player setPlayerAngles( (0,90,0) );
}

