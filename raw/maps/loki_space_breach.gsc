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
	
	PreCacheModel("weapon_proximity_mine");
	PreCacheModel("weapon_proximity_mine_obj");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "space_breach_done" );
	flag_init( "left_pressed" );
	flag_init( "right_pressed" );
	flag_init( "forward_pressed" );
	flag_init( "attack_pressed" );
	flag_init("target_found");	
	flag_init( "earth_move1" );			
	flag_init( "earth_move2" );
	flag_init("controlroom_moved");
	flag_init("breach_done");
	flag_init("push_left");
	flag_init("push_down");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

space_breach_start()
{
	player_move_to_checkpoint_start( "space_breach" );
//	move_controlroom_to_new_location();
	maps\loki_util::spawn_allies();
	flag_set("combat_two_done");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

space_breach()
{
	flag_wait("combat_two_done");
	autosave_by_name_silent( "space_breach" );
	
//	thread spawn_allies();
	thread spawn_enemies();
	thread allies_catch_up();
//	thread earth_move();
	thread set_flags_on_input();
	thread test_quick_breach();
	
	flag_wait( "space_breach_done" );
}

test_quick_breach()
{	
	flag_wait("controlroom_moved");

//	enemies = get_ai_group_ai("combat_two_enemies");
	
	wait(1.0);
//	IPrintLn("waiting for combat two enemies to be dead");
	
//	if(isdefined(level._ai_group[ "combat_two_enemies" ]))
//   	{
		while ( level._ai_group[ "combat_two_enemies" ].aicount )
		{
	//		num_ai = level._ai_group[ "combat_two_enemies" ].aicount;
	//		IPrintLn("ai still alive: "+ num_ai);
			wait( 0.25 );
		}
//	}
//	waittill_aigroupcleared("combat_two_enemies");
//	IPrintLn("combat two enemies are now dead");
//	while(enemies.size > 0)
//	{
//		enemies = get_ai_group_ai("combat_two_enemies");	
//		wait(.1);
//	}
	
	//player gets close enough to one of the charges
	location_array = GetEntArray("quick_breach_door_target", "targetname");
	c4_array = [];
	foreach ( breach_target in location_array)
	{
		index = c4_array.size;
		breach_target MakeUsable();
		traced_loc = BulletTrace(breach_target.origin, breach_target.origin + (-100,0,0),false);
		new_pos = traced_loc[ "position" ];
		new_angles = traced_loc[ "normal" ];
		c4_array[index] = add_c4_to_spot(new_pos, new_angles + (70,0,0));
//		c4_array[index] = add_c4_to_spot(breach_target.origin, breach_target.angles + (70,0,0));
//		IPrintLn("c4_array "+ index);
	}
	
	//waits in this function till player presses button while close
	player_closest_location = player_is_close_to_breach_locations(100, location_array);
	location_array = GetEntArray("quick_breach_door_target_ai", "targetname");
//	location_array = array_remove(location_array, player_closest_location);
	//ai swims to other charges
	
	foreach(ally in level.allies)
	{
		if(location_array.size > 0)
		{
			closest_location = location_array[0];
			foreach(loc in location_array)
			{
				if(distance(ally.origin, loc.origin) < distance(ally.origin, closest_location.origin))
				{
					closest_location = loc;
				}
			}
			if(isdefined(closest_location.target))
			{
				ai_teleport_loc = closest_location.target;
				ai_teleport_loc = getent(ai_teleport_loc,"targetname");
				ally ForceTeleport(ai_teleport_loc.origin, ai_teleport_loc.angles);
				ally thread ally_breach_movement(ai_teleport_loc);
			}
			location_array = array_remove(location_array, closest_location);
		}
	}
	
	level.player allowprone( false );
	level.player allowcrouch( false );
	level.player DisableWeapons();
	//bring up prompt to plant charge (or mines to throw)
	level.player PlayerLinkToBlend(player_closest_location, "",1.0);
	wait(1.0);
	level.player PlayerLinkToDelta(player_closest_location, "",1.0, 15, 15, 15, 15,true);
	wait(.2);
//	thread player_push_anim(player_closest_location, "down");
//	wait(.5);
	foreach ( c4 in c4_array)
	{
		c4 thread unglow_c4();
	}
	ally_c4_array = GetEntArray("quick_breach_door_target_ai", "targetname");
	foreach ( c4 in ally_c4_array)
	{
		c4 = add_c4_to_spot(c4.origin, c4.angles);
		c4 thread unglow_c4();
		wait(.25);
	}	

	wait(.5);
	back_off = getent("quick_breach_back_off", "targetname");
	back_off MakeUsable();
	back_off SetHintString( &"SCRIPT_HOLD_TO_USE" );
	level.player PlayerLinkToBlend(back_off, "",.5);
	wait(.5);
	level.player PlayerLinkToDelta(back_off, "",1.0, 15, 15, 15, 15,true);
//	wait(.2);

	
	while(flag("attack_pressed"))
	{
		wait(.1);
	}
	//bring up detonator
	flag_wait("attack_pressed");
	//blow off roof
//	wait(.2);
//	foreach ( c4 in c4_array)
//	{
//		c4 thread unglow_c4();
//	}
	wait(.5);
	level notify("activate_breach");
	
//	foreach ( c4 in c4_array)
//	{
//		c4 delete();
//	}
//	center2.angles = center2.angles + (0,180,0);
	explosion_center1 = getent("explosion_center_quick_1", "targetname");
	explosion_center2 = getent("explosion_center_quick_2", "targetname");
//	explosion_center2 print_object_vectors(true, true);
	transform_posrot(explosion_center2, level.center2, level.center1, explosion_center1);
	wait(.1);
//	explosion_center2 print_object_vectors(true, true);
	hide_undamaged_comm_centers();
	show_damaged_comm_centers();
	level thread break_entrance(explosion_center1, 500, (0,0,1));
	level thread break_entrance(explosion_center2, 500, (-1,0,0));
	wait(.2);
	level thread spawn_fx_and_launch_bodies(level.center1, level.center2);
	wait(.5);
	level.player Unlink();
	
	thread player_push_anim(back_off, "down");
	wait(.67);
//	thread push_player_around((0,0,100));
	nodes = GetNodeArray("inside_node", "targetname");
	foreach ( node in nodes)
	{
		node ConnectNode();
	}	
	//blend into z-trans
	z_trans_inside(level.center1, level.center2);

	flag_set("space_breach_done");
}

move_controlroom_to_new_location()
{
//	obj1_orig = getent("comm_center_origin_1_orig", "targetname");
	level.comm_center_1_pieces = [];
	level.comm_center_2_pieces = [];
	
	center_array = GetEntArray("control_room_center","targetname");
	foreach ( center in center_array)
	{
		if(center.script_noteworthy == "zone_03_controlroom")
		{
			level.center1 = center;
		}
		if(center.script_noteworthy == "zone_02_controlroom")
		{
			level.center2 = center;
		}
//		iprintln("SPACE BREACH: control_room_center found!!!!!!!!!!!!!!!!!!!!!!!!");
	}
	wait(.1);
	
	center_point = GetEnt("comm_center_origin_1","targetname");
	center_point2 = GetEnt("comm_center_origin_2","targetname");
	
	//move flipped control room so it's lit the same as the one we'll come back to
	
	current_center = level.center1;
	current_center2 = level.center2;
	center_to_move_to = center_point;
	center_to_move_to2 = center_point2;
	
	move_array = GetEntArray("move_model", "targetname");
	interior_array = GetEntArray("interior_model", "targetname");
	impulse_array = GetEntArray("impulse_model", "targetname");
	delete_array = GetEntArray("delete_model", "targetname");
	move_02_array = GetEntArray("move_model02", "targetname");
	move_array = array_combine(move_array, interior_array);
	move_array = array_combine(move_array, impulse_array);
	move_array = array_combine(move_array, delete_array);
	move_array = array_combine(move_array, move_02_array);
	foreach(piece in move_array)
	{
		if(Distance(piece.origin, current_center.origin) < 400)
		{
			transform_posrot(piece, center_to_move_to, current_center, piece);
			level.comm_center_1_pieces[level.comm_center_1_pieces.size] = piece;
			piece hide();
		}
		if(Distance(piece.origin, current_center2.origin) < 400)
		{
			transform_posrot(piece, center_to_move_to2, current_center2, piece);
			level.comm_center_2_pieces[level.comm_center_2_pieces.size] = piece;
			piece hide();			
		}
	}

	level.center1.origin = center_point.origin;
	level.center1.angles = center_point.angles;

	level.center2.origin = center_point2.origin;
	level.center2.angles = center_point2.angles;	
	
//	thread sun_directions_init();
	
	flag_set("controlroom_moved");
}

player_is_close_to_breach_locations(dist, location_array)
{
//	dist = 100;
	closest_location = undefined;
	while(!isdefined(closest_location))
	{
		foreach(loc in location_array)
		{
			if(distance(level.player.origin, loc.origin) < dist)
			{
				loc SetHintString( &"SCRIPT_HOLD_TO_USE" );
				if(flag("attack_pressed"))
				{
					if(!isdefined(closest_location))
					{
						closest_location = loc;
					}
					else
					{
						if(distance(level.player.origin, loc.origin) < distance(level.player.origin, closest_location.origin))
						{
							closest_location = loc;
						}
					}
				}
			}
		}
		wait(.1);
	}
	return closest_location;	
}

ally_breach_movement(ai_teleport_loc)
{
	node_name = ai_teleport_loc.target;
	node = GetNode(node_name, "targetname");
	self SetGoalNode(node);
	level waittill("activate_breach");
//	flag_wait("breach_started");
	wait(RandomFloatRange(1.0,2.0));
	
	link_ent = spawn("script_origin", self.origin);
	self linkto(link_ent);
	
	node_name = node.target;
	move_target = GetEnt(node_name, "targetname");
	link_ent MoveTo(move_target.origin, 2.0);
	link_ent RotateTo(move_target.origin, 2.0);
//	self LinkToBlendToTag(move_target, "", false);
	
//	self SetGoalNode(node);
}

z_trans_inside(center1, center2)
{
//	level thread breach_anim_push_logic();
	
//	level.ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
//	level.player playerSetGroundReferenceEnt( level.ground_ref_ent );
//	origins = [];
	z_trans_1 = GetEnt( "z_trans_1" , "targetname" );
//	origins[1] = GetEnt( "hall_1_turn_2" , "targetname" );
	z_trans_2 = GetEnt( "z_trans_2" , "targetname" );
	z_trans_3 = GetEnt( "z_trans_3" , "targetname" );
	z_trans_4_array = GetEntArray( "z_trans_4" , "targetname" );
//	z_trans_5 = GetEnt( "z_trans_5" , "targetname" );
//	z_trans_6 = GetEnt( "z_trans_6" , "targetname" );
		
//	thread ally_z_movements( origins );
//	thread ally_Proper_movement( origins );
	//center2 is final spot
//	center1 = getent("comm_center_origin_1", "targetname");
//	center2 = getent("comm_center_origin_2", "targetname");
//	obj3 = origins[0];
//	PrintLn("z_trans_3 transform");
//	z_trans_3 print_object_vectors(true, true);
//	center2 print_object_vectors(true, true);
//	center1 print_object_vectors(true, true);
//	z_trans_2 print_object_vectors(true, true);
	
//	z_trans_3 print_object_vectors(true, true);
//	obj3 = getent("quick_breach_z_trans_blend_1", "targetname");
//	new_posrot = getent("quick_breach_z_trans_blend_2", "targetname");
//	transform_posrot(new_posrot, obj1, obj2, obj3);
	
//	node = origins[0];
//	alt_node = origins[2];
	
	trigger = getent("space_breach_z_trans_trigger", "targetname");
	trigger waittill("trigger");
	
	level.player FreezeControls( true );
//	level.player allowprone( false );
//	level.player allowcrouch( false );
//	level.player DisableWeapons();
//	wait(.5);
//	flag_set("push_down");
//	wait(.5);
//	flag_clear("push_down");
//	arc = 0;
//	level.player PlayerLinkToBlend( z_trans_1, "", 1.0, 0.15, 0.15 );
////	level.player PlayerLinkToBlend( node, "", 0.5, 0.15, 0.15 );
//	wait 1.0;
//	flag_wait("attack_pressed");
//	level.player PlayerLinkToDelta( origins[2], "", 1, arc, arc, arc, arc, 1 );
	
	arc = 0;
	z_trans_2.origin = level.player.origin;
	transform_posrot(z_trans_3, center2, center1, z_trans_2);
	level.player PlayerLinkToBlend( z_trans_2, "", 2.0, 0.15, 0.15 );
//	level.player PlayerLinkToBlend( node, "", 0.5, 0.15, 0.15 );
	wait 2.0;
//	flag_wait("attack_pressed");
	//annnnd...swap
	
//	thread player_push_anim(z_trans_2, "left");
//	thread player_push_anim(z_trans_3, "left");
//	wait(.4);
	flag_set( "earth_move1" );
	level.player PlayerLinkToDelta( z_trans_3, "", 1, arc, arc, arc, arc, 1 );
	waitframe();
//	ResetSunDirection();
	
//	wait(.3);
	thread teleport_allies_to_comm_center_interior();
//	thread player_push_anim(z_trans_3, "left");
	wait(.4);
//	flag_wait("attack_pressed");
//	alt_node_2 = origins[3];
	
	z_trans_4 = getClosest(level.player.origin, z_trans_4_array);
	z_trans_5 = GetEnt(z_trans_4.target, "targetname");
	level.player PlayerLinkToBlend( z_trans_4, "", 2.0, .3, .3 );
//	wait(1.9);
	wait(1.5);
	level notify("ai_out_of_view");
////	flag_wait("attack_pressed");
////	level.player PlayerLinkToDelta( z_trans_4, "", 1, arc, arc, arc, arc, false );
////	waitframe();
//	thread player_push_anim(z_trans_4, "left");
//	wait(.67);
	level.player PlayerLinkToBlend( z_trans_5, "", 2.0, .3, .3 );
	wait(1.9);
////	flag_wait("attack_pressed");
////	level.player PlayerLinkToDelta( z_trans_5, "", 1, arc, arc, arc, arc, false );
////	waitframe();
//	
//	level.player PlayerLinkToBlend( z_trans_6, "", 2.0, .3, .3 );
//	wait(2.0);
//	flag_wait("attack_pressed");
//	level.player PlayerLinkToDelta( z_trans_6, "", 1, arc, arc, arc, arc, false );
//	wait(.1);
	
	
	level.player unlink();

//	player_rig delete();
//	alt_player_rig delete();

	level.player FreezeControls( false );
	level.player allowprone( true );
	level.player allowcrouch( true );
	level.player enableWeapons();	
}

//set posrot of move_ent to the transform move of transformed_obj from ref2 to ref1
transform_posrot(move_ent, ref1, ref2, transformed_obj)
{
	result = TransformMove(ref1.origin, ref1.angles, ref2.origin, ref2.angles, transformed_obj.origin, transformed_obj.angles);
	move_ent.origin = result["origin"];
	move_ent.angles = result["angles"];	
}

hide_undamaged_comm_centers()
{
	hide_array = GetEntArray("undamaged_model", "targetname");
	foreach ( piece in hide_array)
	{
//		piece NotSolid();
//		piece hide();
		piece delete();
	}
	
}

show_damaged_comm_centers()
{
	foreach ( piece in level.comm_center_1_pieces)
	{
		piece show();
	}
	foreach ( piece in level.comm_center_2_pieces)
	{
		piece show();
	}
}

push_player_around(vector)
{
    level.player PushPlayerVector(vector);
    wait(.1);
    level.player PushPlayerVector((vector[0]/2, vector[1]/2, vector[2]/2));
    wait(.1);
    level.player PushPlayerVector((vector[0]/4, vector[1]/4, vector[2]/4));
    wait(.2);
    level.player PushPlayerVector((0, 0, 0));
//    PrintLn("Done pushing player");
}

//breach_anim_push_logic()
//{
//
//	
//	while(!flag("breach_done"))
//	{
//		if(flag("push_left"))
//		{
//			player_side_push(player_rig);
//			wait(.5);
//		}
//		else
//		{
//			if(flag("push_down"))
//			{
//				player_down_push(player_rig);
//				wait(.5);				
//			}
//		}
//		wait(.1);
//	}
//}

#using_animtree( "player" );
player_push_anim(link_to, direction)
{
	player_rig = spawn_anim_model( "player_rig" );
	player_rig.origin = link_to.origin ;
	player_rig.angles = link_to.angles;
//	player_rig LinkTo ( level.player );
//	player_rig Hide();
//	IPrintLn("side push!");
//	player_rig show();
	//level.player thread anim_single ( guys , "viewmodel_space_l_arm_sidepush");
	if(direction == "left")
	{
		player_rig SetAnimRestart( %viewmodel_space_l_arm_sidepush , 1 , 0 , 1.0 );
	}
	if(direction == "down")
	{
		player_rig SetAnimRestart( %viewmodel_space_l_arm_downpush , 1 , 0 , 1.0 );
	}
	wait 1;
//	wait .67;
	player_rig delete();
}

allies_catch_up()
{
	
//	ally_check_volume = getent("space_breach_ally_check", "targetname");
	goal_node_array = GetNodeArray("space_breach_ally_start_node", "targetname");
	foreach ( guy in level.allies)
	{
		guy SetGoalNode(goal_node_array[0]);
		guy set_force_color("r");
		goal_node_array = array_remove(goal_node_array, goal_node_array[0]);
	}
	
//	wait(1.0);
//	spawners = getentarray( "friend_starting_allies", "targetname" );
//	array_thread(spawners, ::add_spawn_function, ::ally_spawn_func);
//	
//	if(isdefined(spawners[0]))
//	{
//		level.ally1 = spawners[0] spawn_ai( true );
//	}
//	if(isdefined(spawners[1]))
//	{
//		level.ally2 = spawners[1] spawn_ai( true );
//	}
//	if(isdefined(spawners[2]))
//	{
//		level.ally3 = spawners[2] spawn_ai( true );
//	}
}

spawn_enemies()
{
	enemies = GetEntArray("space_breach_enemy", "targetname");
	foreach ( guy in enemies)
	{
		guy add_spawn_function(::enemy_spawn_func);
		guy spawn_ai();
	}
	
}

enemy_spawn_func()
{
	self thread teleport_to_target();
	
	self thread maps\_space_ai::enable_space();
	self.diequietly = true;
//	self.forceRagdollImmediate = true;
	wait(.5);
	self.deathFunction = ::breach_ai_space_death;
}

ally_spawn_func()
{
	level.allies[level.allies.size] = self;
	self thread teleport_to_target();
	self thread magic_bullet_shield();
	self thread set_force_color("r");
	
	self thread maps\_space_ai::enable_space();

//	thread script_acquire_spacerifle();
	self thread temp_ally_marker();
	Objective_Add( obj ("follow"), "current", "FOLLOW ALLY" );
	Objective_OnEntity( obj ("follow"), self, (0, 0, 0) );
}

teleport_allies_to_comm_center_interior()
{
	transform_loc = spawn("script_origin", level.player.origin);
	ally_array = GetAIArray("allies");
	loc_array = GetEntArray("z_trans_ally_location", "targetname");
	for ( i = 0; i < ally_array.size; i++ )
	{
		if(isdefined(ally_array[i]) && isdefined(loc_array[i]))
		{
			ally_array[i] unlink();
			transform_posrot(transform_loc,level.center2,level.center1, ally_array[i]);
			ally_array[i] ForceTeleport(transform_loc.origin, transform_loc.angles);
			ally_array[i] SetGoalPos(ally_array[i].origin);
		}
	}
	
	level waittill("ai_out_of_view");
	
	for ( i = 0; i < ally_array.size; i++ )
	{
		if(isdefined(ally_array[i]) && isdefined(loc_array[i]))
		{
//			ally_array[i] unlink();
//			transform_posrot(transform_loc,level.center2,level.center1, ally_array[i]);
//			ally_array[i] ForceTeleport(transform_loc.origin, transform_loc.angles);
			ally_array[i] SetGoalPos(loc_array[i].origin);
		}
	}
}

set_flags_on_input()
{
	level endon("stop_listening_for_input");
	while( 1 )
	{
		analog_input = level.player GetNormalizedMovement();

		if((abs(analog_input[ 1 ]) - abs(analog_input[ 0 ])) > 0)
		{
			y_most = true;	
		}
		else
		{
			y_most = false;
		}
		if( analog_input[ 1 ] >= 0.15 && y_most)
		{
//			IPrintLn( "pressing right" + analog_input[ 1 ]);
			flag_clear( "left_pressed" );
			flag_clear( "forward_pressed" );
			flag_set( "right_pressed" );			
		}
		else if( analog_input[ 1 ] <= -0.15 && y_most)
		{
//			IPrintLn( "pressing left" + analog_input[ 1 ] );
			flag_clear( "right_pressed" );
			flag_clear( "forward_pressed" );
			flag_set( "left_pressed" );			
		}
		else if( analog_input[ 0 ] >= 0.15 )
		{
			//x_most by default now...
//			IPrintLn( "pressing forward" + analog_input[ 0 ]);
			flag_clear( "right_pressed" );
			flag_clear( "left_pressed" );
			flag_set( "forward_pressed" );			
		}
		else
		{
			flag_clear( "left_pressed" );
			flag_clear( "right_pressed" );
			flag_clear( "forward_pressed" );
		}
		
		if( level.player UseButtonPressed())// || level.player AttackButtonPressed())
		{
			//x_most by default now...
//			IPrintLn( "pressing attack");
			flag_set( "attack_pressed" );			
		}
		else
		{
			flag_clear( "attack_pressed" );
		}
		
		waitframe();
	}
}

add_c4_to_spot(loc, ang)
{
	objmodel = "weapon_proximity_mine_obj";
	c4model = "weapon_c4";
	c4 = spawn( "script_model", loc);
	c4 setmodel( objmodel );
	c4.angles = ang;
		
	while(!isdefined(c4))
	{
		waitframe();
	}
//	IPrintLn("adding c4");
	return c4;
}

unglow_c4()
{
	c4model = "weapon_proximity_mine";
	self setmodel( c4model );
//	IPrintLn("unglowing c4");
	
	level waittill("activate_breach");
	
	PlayFX( getfx( "fire_extinguisher_exp" ), self.origin );
	wait(.1);
	self delete();
}

print_object_vectors(print_origin, print_angles)
{
	if(print_origin)
	IPrintLn("origin: " + self.origin[0] + ", "+ self.origin[1] + ", " + self.origin[2]);
	if(print_angles)
	IPrintLn("angles: " + self.angles[0] + ", "+ self.angles[1] + ", " + self.angles[2]);
}

break_entrance(center, dist, up_vector)
{
//	wait(.3);
	
	delete_model_array = GetEntArray("delete_model", "targetname");
	foreach ( guy in delete_model_array)
	{
//		fx = PlayFX( getfx( "factory_roof_steam_small_01" ), guy.origin, (0,0,1),(0,1,0) );
		thread delete_fx_after_time(3.0, guy.origin, guy.angles);
		guy delete();
	}
	
	center_ent = undefined;
	impulse_model_array = GetEntArray("impulse_model", "targetname");
//	impulse_model_array = GetEntArray("move_model02_top", "script_noteworthy");
	foreach ( guy in impulse_model_array)
	{
		if(IsArray(center))
		{
			center_ent = getClosest(guy.origin,center);
		}
		else
		{
			center_ent = center;	
		}
		if(isdefined(guy.origin) && Distance(center.origin, guy.origin) < dist)
		{
//			speed = guy.script_speed;
//			if(speed <= 0)
//			{
//				speed = 1;
//			}
			speed = 1.5;
			if(isdefined(guy.target))
			{
				target_obj = GetEnt(guy.target, "targetname" );
				place = target_obj.origin;	
			}
			else
			{

//				dir_vector = guy.origin - center.origin;
				dir_vector = VectorNormalize(guy.origin - center_ent.origin);
				if(!isdefined(up_vector))
				{
					up_vector = (0,0,1);
				}
				dir_vector2 = VectorNormalize(guy.origin) + up_vector;
				dir_vector = (dir_vector + dir_vector2)/2;
				dir_vector = dir_vector * 5000;
				place = guy.origin + dir_vector;
//				place = guy.origin + (0, 0, 10000);
			}
			time = 60/speed;
			guy NotSolid();
			guy Moveto(place, time);
			wait(.05);
		}
		
		forward = AnglesToForward(center_ent.angles);
		up = AnglesToUp(center_ent.angles);
//		fx = PlayFX( getfx( "factory_roof_steam_small_01" ), guy.origin, forward,up );
		thread delete_fx_after_time(3.0, guy.origin, guy.angles);
		
		vel_angles = (0,0,0);
		if(isdefined(guy.script_angles))
		{
			vel_angles = guy.script_angles;
		}	
			vel_angles = (RandomFloatRange(-10,10),RandomFloatRange(-10,10),RandomFloatRange(-10,10));
			guy RotateVelocity(vel_angles, 999 );	
		
	}
}

delete_fx_after_time(timer, ent_origin, ent_angles)
{
	fx_loc = spawn_tag_origin();
	fx_loc.origin = ent_origin;
	fx_loc.angles = ent_angles;
	PlayFXOnTag( getfx( "factory_roof_steam_small_01" ), fx_loc, "tag_origin" );
	wait(timer);
	StopFXOnTag( getfx( "factory_roof_steam_small_01" ), fx_loc, "tag_origin" );
}

spawn_fx_and_launch_bodies(center1, center2)
{
	//so ragdolls don't stop in mid float
	//may have to set this back before rog...
	SetSavedDVar( "ragdoll_max_life", 3600000 ); 

	//spawn enemies
//	array_spawn_targetname("breach_enemy", true);
	wait(.1);
	enemies = get_ai_group_ai("breach_enemy");
	// kill them
	impulse_link_array = GetEntArray("impulse_link" ,"targetname");
	foreach ( guy in enemies)
	{
//		guy kill();
		if(distance(guy.origin, center1.origin) < 400)
		{
			loc = getClosest(guy.origin, impulse_link_array);
			offset_pos = guy.origin - loc.origin;
			guy LinkTo(loc, "", offset_pos, (0,0,0));
			launch_enemies(loc, center1, (0,0,1));
		}
		else
		{
			if(distance(guy.origin, center2.origin) < 400)
			{
				loc = getClosest(guy.origin, impulse_link_array);
				offset_pos = guy.origin - loc.origin;
				guy LinkTo(loc, "", offset_pos, (0,0,0));
				thread launch_enemies(loc, center2, (-1,0,0));
			}
		}
	}
	
	wait(1.0);
			
	//impulse them outta there
	enemies = get_ai_group_ai("breach_enemy");
//	location_object = spawn("script_origin",level.player.origin);
	breach_enemy_teleport_array = GetEntArray("breach_enemy_teleport" ,"targetname");
	teleport_index = 0;
	wait(.1);
	for ( i = 0; i < enemies.size; i++ )
	{
		enemies[i] Unlink();
		wait(.1);
		location_object = breach_enemy_teleport_array[i];
		enemies[i] ForceTeleport(location_object.origin, location_object.angles);
		wait(.5);
		enemies[i] kill();
		teleport_index++;
	}
	
	wait(2.0);
//	while(1)
//	{
	physicsexplosionsphere ( level.center2.origin + (0,0,300), 700,600, .75 );
//		wait(1.0);
//	}
	
//	foreach ( guy in enemies)
//	{
//		guy Unlink();
//		wait(.1);
////		guy print_object_vectors(true, true);
////		location_object print_object_vectors(true, true);
////		transform_posrot(location_object, level.center2, level.center1, guy);
////		location_object print_object_vectors(true, true);
//		location_object = breach_enemy_teleport_array[index];
//		guy ForceTeleport(location_object.origin, location_object.angles);
//		index++;
//		wait(.1);
//		guy kill();
//	}	
}

launch_enemies(linked_obj, center, up_vector)
{
	center_ent = center;
//	impulse_model_array = GetEntArray(linked_obj_array_name, "targetname");

	speed = 1.5;

	dir_vector = VectorNormalize(linked_obj.origin - center_ent.origin);
	dir_vector2 = VectorNormalize(linked_obj.origin) + up_vector;
	dir_vector = (dir_vector + dir_vector2)/2;
	dir_vector = dir_vector * 5000;
	place = linked_obj.origin + dir_vector;

	time = 60/speed;
	linked_obj Moveto(place, time);
	wait(.05);
			
	forward = AnglesToForward(center_ent.angles);
	up = AnglesToUp(center_ent.angles);
	
//	if(isdefined(linked_obj.script_angles))
//	{
//		vel_angles = linked_obj.script_angles;
//		vel_angles = (RandomFloatRange(-10,10),RandomFloatRange(-10,10),RandomFloatRange(-10,10));
//		linked_obj RotateVelocity(vel_angles, 999 );
//	}		
		
}

teleport_to_target()
{
	org = self get_target_ent();
	if ( !isdefined( org.angles ) )
		org.angles = self.angles;
	if( IsAI(self))
	{
		self ForceTeleport( org.origin, org.angles );
	}
	// Don't need this stuff for space right now.
	if ( isdefined( org.target ) )
	{
		org = org get_Target_ent();
		// if ( isdefined( org.script_animation ) )
			// self maps\ship_graveyard_stealth::stealth_idle( org, org.script_animation );
		//if ( isdefined( org.script_idlereach ) )
			// self stealth_idle_reach( org );
		// else
		self maps\_utility::follow_path_and_animate( org, 0 );
		
	}
	
}

temp_ally_marker(  )
{
	follow_icon = NewHudElem();
	follow_icon SetShader( "apache_target_lock", 5, 5 );
	follow_icon.alpha = .25;
	follow_icon.color = ( 0, 1, 0 );
	// follow_icon SetTargetEnt( self );
	follow_icon SetWayPoint( true, true );
	
	self thread hud_element_follow_ent(follow_icon);
//	while ( IsAlive ( self ) )
//	{
//		follow_icon.x = self.origin [0];
//		follow_icon.y = self.origin[ 1 ];
//		follow_icon.z = self.origin[ 2 ];	
//		wait .1;
//	}
	
	self waittill_either ( "death", "no_icon" );
	follow_icon Destroy();	
	
}

hud_element_follow_ent(follow_icon)
{
	self endon("death");
	self endon("no_icon");
	while ( IsAlive ( self ) )
	{
		follow_icon.x = self.origin [0];
		follow_icon.y = self.origin[ 1 ];
		follow_icon.z = self.origin[ 2 ];	
		wait .1;
	}
}

script_acquire_spacerifle()
{
//	waittill_aigroupcount( "aigroup_stealth_kill_guy01", 0 );
//	IPrintLnBold( "YOU ACQUIRED SPACE RIFLE and SPACE GRENADE GUN" );
	level.player TakeAllWeapons();
	level.player giveWeapon( "spaceaps" );
//	level.player giveWeapon( "spacexm25_zoom" );
	level.player giveWeapon( "spaceshotgun" );
	level.player SwitchToWeapon( "spaceaps" );
	wait 2;
//	IPrintLnBold( "PRESS Y TO SWITCH WEAPONS" );

}
#using_animtree( "generic_human" );
breach_ai_space_death()
{
	PlayFXOnTag( getfx( "swim_ai_death_blood" ), self, "j_spineupper" );
	PlayFXOnTag( getfx( "sp_blood_float" ), self, "j_spineupper" );
	PlayFXOnTag( getfx( "factory_roof_steam_small_01" ), self, "j_spineupper" );
	if ( !isdefined( self.deathanim ) )
    {
		if ( ( self.damageyaw > - 60 ) && ( self.damageyaw <= 60 ) )
		{
			self.deathanim = %space_idle_death_behind;
		}
		else if ( self.a.movement == "run" )
		{
			self.deathanim = %space_death_1;
		}
		else
		{
			if ( animscripts\utility::damageLocationIsAny( "left_arm_upper" ) )
			{
				self.deathanim = %space_firing_death_1;
			}	
			else if ( animscripts\utility::damageLocationIsAny( "head", "helmet" ) )
			{
				self.deathanim = %space_firing_death_2;
			}
			else
			{
				self.deathanim = Random( [ %space_firing_death_1, %space_firing_death_2, %space_firing_death_3 ] );
			}
		}
    }
	if ( !isdefined( self.noDeathSound ) )
		self animscripts\death::PlayDeathSound();
	thread breach_spawn_space_death_impulse (self.origin);
	return false;
}

breach_spawn_space_death_impulse (impulse_origin)
{
	wait RandomFloatRange (0.1, 2);
    new_model = spawn_tag_origin();
//    new_model.origin = impulse_origin+(RandomFloatRange(1,10),0,0);
    new_model.origin = impulse_origin+(5,0,0);
	//IPrintLnBold ("dying impulse");
//	physicsexplosionsphere ( new_model.origin, 20, 15, .75 );
	PlayFX( getfx( "fire_extinguisher_exp" ), new_model.origin );
	new_model delete();
	
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
