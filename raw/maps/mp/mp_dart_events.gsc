#include common_scripts\utility;
#include maps\mp\_utility;
////////////////////////
// Gas Station
////////////////////////

#using_animtree("animated_props");

gas_station()
{
	gas_station_precache();
	
	wait .05;
	
	structs = getstructarray("gas", "targetname");
	array_thread(structs, ::gas_station_init);
}
	
gas_station_init()
{
	target_ents = GetEntArray(self.target, "targetname");
	target_structs = getstructarray(self.target, "targetname");
	target_ents = array_combine(target_ents, target_structs);
	nodes = self getLinknameNodes();
	targets = array_combine(target_ents, nodes);
	
	self.clip_up = [];
	self.clip_down = [];
	self.launch_ents = [];
	self.linked_ents = [];
	
	foreach(target_ent in targets)
	{
		if(!IsDefined(target_ent.script_noteworthy))
			continue;
		
		if(!IsDefined(target_ent.script_parameters))
			target_ent.script_parameters = "corner1_hit";
		
		switch ( target_ent.script_noteworthy )
		{
			case "clip_up":
				self.clip_up[self.clip_up.size] = target_ent;
				break;
			case "clip_down_traverse":
				target_ent.nodisconnect = true;
				//Fallthrough
			case "clip_down":
				self.clip_down[self.clip_down.size] = target_ent;
				target_ent SetAISightLineVisible( 0 );
				target_ent ConnectPaths();
				target_ent trigger_off();
				break;
			case "link_to_launch":
				self thread gas_station_run_func_on_notify(target_ent.script_parameters, ::gas_station_launch_ent, target_ent);
				//Fallthrough
			case "link_to":
				self.linked_ents[self.linked_ents.size] = target_ent;
				break;
			case "fx":
				self thread gas_station_run_func_on_notify(target_ent.script_parameters, ::gas_station_play_fx, target_ent);
				break;
			case "animated":
				self.animated_model = target_ent;
				break;
			case "earthquake":
				self thread gas_station_run_func_on_notify(target_ent.script_parameters, ::gas_station_earthquake, target_ent);
				break;
			case "sound":
				self thread gas_station_run_func_on_notify(target_ent.script_parameters, ::gas_station_playSound, target_ent);
				break;
			case "connect_node":
				target_ent DisconnectNode();
				self thread gas_station_run_func_on_notify(target_ent.script_parameters, ::gas_station_connect_node, target_ent);
				break;
			default:
				break;
		}
	}
	
	if ( IsDefined( self.animated_model ) )
	{
		foreach(ent in self.linked_ents)
		{
			ent linkTo(self.animated_model, "j_awning_main");
		}
	}
		
	all_models = GetEntArray("script_model", "classname");
	gas_pumps = [];
	foreach(pump in all_models)
	{
		if(!IsDefined(pump.destructible_type) || pump.destructible_type != "destructible_gaspump_dart")
			continue;
		
		pump thread notify_explode(self);
		gas_pumps[gas_pumps.size] = pump;
	}
	
	self waittill("gas_station_explode", exploded_pump);
	 
	foreach(pump in gas_pumps)
	{
		if(pump == exploded_pump)
			continue;
		pump.dontAllowExplode = undefined;
		pump.forceExploding = true;
		pump notify( "damage", 100000, pump, pump.origin, pump.origin, "MOD_EXPLOSIVE", "", "" );
	}
	
	//Play fx on pump that exploded
	PlayFX(level._effect[ "vfx_gas_station_explosion" ], exploded_pump.origin);

	time = GetAnimLength( %mp_dart_gas_awning_fall );
	
	self.gas_station_events = [];
	self gas_station_add_event("start", 0.0);
	self gas_station_add_event("beam_break", 0.1);
	self gas_station_add_event("corner1_hit", 1.9);
	self gas_station_add_event("corner2_hit", 2.15);
	self gas_station_add_event("sign_hit", 2.5);
	self gas_station_add_event("end", time);
	
	self thread gas_station_run_func_on_notify("corner1_hit", ::gas_station_update_clip);

	self thread gas_station_run_events();
	
	if ( IsDefined( self.animated_model ) )
		self.animated_model ScriptModelPlayAnimDeltaMotion( "mp_dart_gas_awning_fall" );
}

gas_station_run_func_on_notify(note, func, param1)
{
	self waittill(note);
	
	if(IsDefined(param1))
	{
		self thread [[func]](param1);
	}
	else
	{
		self thread [[func]]();
	}
}

gas_station_update_clip()
{
	foreach(clip in self.clip_up)
	{
		clip SetAISightLineVisible( 0 );
		clip Delete();
	}
	
	foreach(clip in self.clip_down)
	{
		clip SetAISightLineVisible( 1 );
		clip trigger_on();
		if (!isDefined(clip.nodisconnect) || !clip.nodisconnect)
			clip DisconnectPaths();
		
		foreach(player in level.players)
		{
			if(player IsTouching(clip))
				player _suicide();
		}
	}
}

gas_station_launch_ent(ent)
{
	angles = self.animated_model GetTagAngles("j_awning_main");
	launch_dir = AnglesToUp(angles);
	ent Unlink();
	
	org_offset = (RandomFloatRange(-1,1),RandomFloatRange(-1,1),0); //give object rotation
	ent PhysicsLaunchClient(ent.origin + org_offset, launch_dir * 15000);
}

gas_station_play_fx(ent)
{
	if(!IsDefined(ent.script_fxid) || !IsDefined(level._effect[ent.script_fxid]))
		return;
	
	PlayFX(level._effect[ent.script_fxid], ent.origin, AnglesToForward(ent.angles));
}

gas_station_earthquake(ent)
{
	Earthquake(.3, .5, ent.origin, 800);
}

gas_station_playSound(ent)
{
	if(!isDefined(ent.script_sound))
		return;
	
	playSoundAtPos(ent.origin,ent.script_sound);
}
gas_station_connect_node(node)
{
	node ConnectNode();
}
gas_station_run_events()
{
	start_time = GetTime();
	while(1)
	{
		foreach(event in self.gas_station_events)
		{
			if(event.done)
				continue;
			
			if((GetTime()-start_time)/1000 >= event.time)
			{
				self notify(event.note);
				event.done = true;
				if(event.note == "end")
					return;
			}
		}
		wait .05;
	}
}

gas_station_add_event(note, time)
{
	if(!isDefined(self.gas_station_events))
		self.gas_station_events = [];
	s = SpawnStruct();
	s.time = time;
	s.note = note;
	s.done = false;
	
	self.gas_station_events[self.gas_station_events.size] = s;
}

// 
gas_station_precache()
{
	level._effect[ "gas_station_dust" ] = loadfx( "vfx/moments/mp_dart/vfx_gas_station_smk_linger" );
	level._effect[ "gas_station_corner_hit" ] = loadfx("vfx/moments/mp_dart/vfx_gas_station_column_dust_impact");
	level._effect[ "gas_station_impact" ] = loadfx("vfx/moments/mp_dart/vfx_gas_station_column_dust_linger");
	level._effect[ "gas_station_sign_impact" ] = loadfx("vfx/moments/mp_dart/vfx_gas_station_sign_impact");
	level._effect[ "gas_station_explosion" ] = loadfx("vfx/moments/mp_dart/vfx_gas_station_explosion");
	PrecacheMpAnim( "mp_dart_gas_awning_fall" );
}

notify_explode(gas_station)
{
	self waittill("exploded");
	
	gas_station notify("gas_station_explode", self);
}

/////////////////////////////////////////////
// Broken Walls
////////////////////////////////////////////
broken_walls()
{
	walls = getStructArray("broken_wall", "targetname");
	array_thread(walls, ::broken_wall_init);
}

broken_wall_init(requires_explosive)
{
	self.trigger_show = []; //May not be a trigger, just needs to be hidden like a trigger (origin +/- 10000)
	self.delete_ents = [];
	self.show_ents = [];
	self.trigger_damage = [];
	
	
	targets = GetEntArray(self.target, "targetname");
	
	foreach(target in targets)
	{	
		if(!IsDefined(target.script_noteworthy))
		{
			target.script_noteworthy = target.classname;
		}
		
		switch(target.script_noteworthy)
		{
			case "delete":
				self.delete_ents[self.delete_ents.size] = target;
				break;
			case "trigger_damage":
				self.trigger_damage[self.trigger_damage.size] = target;
				self thread broken_wall_damage_watch(target);
				break;
			case "show":
				target Hide();
				self.show_ents[self.show_ents.size] = target;
				break;
			case "trigger_show":
				target trigger_off();
				self.trigger_show[self.trigger_show.size] = target;
				break;
			default:
				break;
		}
	}
}

broken_wall_damage_watch(trigger, requires_explosive)
{
	self endon("break_wall");
	
	trigger waittill("trigger");
	
	array_thread(self.show_ents, ::broken_wall_show);
	array_call(self.trigger_damage, ::delete );
	array_thread(self.delete_ents, ::broken_wall_delete);
	array_thread(self.trigger_show, ::trigger_on);
	
	self notify("break_wall");
}

broken_wall_delete()
{
	if(IsDefined(self.script_index))
	{
		exploder(self.script_index);
	}
	
	self SetAISightLineVisible( 0 );
	self delete();
}

broken_wall_show()
{
	self SetAISightLineVisible( 1 );
	self Show();
}

///////////////
// Breach
///////////////
breach()
{
	if( getDvar( "r_reflectionProbeGenerate" ) == "1" )
		return;
	
	// The breach triggers both lead to the same area, so create a list of them both so we can disable both when one is used
	level.dart_linked_breach_triggers = [];
	
	maps\mp\_breach::breach_precache();
	dart_breach_precache();
	dart_breach_anims_init();
	waitframe();
	
	breaches = getstructarray("breach", "targetname");
	
	proxy = getstructarray("breach_proxy", "targetname");
	foreach(p in proxy)
	{
		if(!IsDefined(p.target))
			continue;
		
		breach = getstruct(p.target, "targetname");
		if(!IsDefined(breach))
			continue;
		
		breaches[breaches.size] = breach;			
	}
	
	array_thread(breaches, ::breach_init);
	array_thread(breaches, maps\mp\_breach::breach_init);
	
}

dart_breach_precache()
{
	PrecacheMpAnim( "mp_dart_container_breach_side1" );
	PrecacheMpAnim( "mp_dart_container_breach_side2" );
	PrecacheMpAnim( "mp_dart_container_breach_top" );
	PrecacheMpAnim( "mp_dart_container_idle_side1" );
	PrecacheMpAnim( "mp_dart_container_idle_side2" );
	PrecacheMpAnim( "mp_dart_container_idle_top" );
}

dart_breach_anims_init()
{
	level.breach_anims = [];
	level.breach_anims[ "mp_dart_container_breach_side1" ] = "mp_dart_container_breach_side1";
	level.breach_anims[ "mp_dart_container_breach_side1_idle" ] = "mp_dart_container_idle_side1";
	level.breach_anims[ "mp_dart_container_breach_side2" ] = "mp_dart_container_breach_side2";
	level.breach_anims[ "mp_dart_container_breach_side2_idle" ] = "mp_dart_container_idle_side2";
	level.breach_anims[ "mp_dart_container_breach_top" ] = "mp_dart_container_breach_top";
	level.breach_anims[ "mp_dart_container_breach_top_idle" ] = "mp_dart_container_idle_top";
}

breach_init()
{
	self.animated_doors = [];
	self.care_packages = [];
	self.delete_ents = [];
	self.doors = [];
	self.notsolid_ents = [];
	self.solid_ents = [];
	
	target_ents = GetEntArray(self.target, "targetname");
	target_structs = getstructarray(self.target, "targetname");
	
	targets = array_combine(target_structs, target_ents);
	
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch( target.script_noteworthy )
		{
			case "door":
				self.doors[ self.doors.size ] = target;
				self breach_door_init( target );
				break;
			case "triggers_with":
				if ( IsDefined( target.target ) )
				{
					other_breach = getstruct( target.target, "targetname" );
					if ( IsDefined( other_breach ) )
						self thread breach_other_watch( other_breach );
				}
				break;
			case "care_package":
				self.care_packages[ self.care_packages.size ] = target;
				break;
			case "animated_door":
				door = GetEnt( target.target, "targetname" );
				self.animated_doors[ self.animated_doors.size ] = door;
				self breach_animated_door_init( door );
				break;
			case "use_trigger":
				level.dart_linked_breach_triggers[level.dart_linked_breach_triggers.size] = target;
				add_to_bot_use_targets( target, 0.5 );
				break;
			default:
				break;
		}
	}
	
	foreach ( door in self.doors )
	{
		self thread breach_close_door(door);
	}
	
	self thread breach_open_watch();
}

add_care_package(origin, angles, owner, crateType, dropType)
{
	if(!IsDefined(dropType))
	{
		dropType = "airdrop_assault";
		if(IsDefined(crateType))
		{
			possible_dropTypes = ["airdrop_assault", "airdrop_support"];
			foreach(possible_dropType in possible_dropTypes)
			{
				if(is_valid_crateType(possible_dropType, crateType))
				{
					dropType = possible_dropType;
					break;
				}
			}
		}
	}
	
	if(!is_valid_dropType(dropType))
		return;
	
	if(!IsDefined(crateType))
	{
		crateType = random(GetArrayKeys(level.crateTypes[dropType]));
	}
	
	if(!is_valid_crateType(dropType, crateType))
		return;
	
	if(!IsDefined(angles))
		angles = (0,0,0);
	
	s = SpawnStruct();
	dropCrate = spawn( "script_model", origin );
	dropCrate setModel( "com_plasticcase_friendly" );
	dropCrate.angles = angles;
	dropCrate.crateType = crateType;
	dropCrate.owner = owner;
	dropCrate.team = owner.team;
	dropCrate.targetname = "care_package";
	dropCrate.droppingToGround = false;
	
	dropCrate CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
	dropCrate thread entity_path_disconnect_thread( 1.0 );
	dropCrate PhysicsLaunchServer( (0,0,0), (0,0,1) );
	
	dropCrate thread [[ level.crateTypes[ dropType ][ crateType ].func ]]( dropType );
	
	if ( IsBot(owner) )
	{
		wait(0.1);
		owner notify("new_crate_to_take");
	}
}

is_valid_dropType(dropType)
{
	if(!IsDefined(dropType))
		return false;
	
	foreach(key,value in level.crateTypes)
	{
		if(key == dropType)
			return true;
	}
	
	return false;
}

is_valid_crateType(dropType, crateType)
{
	if(!is_valid_dropType(dropType))
		return false;
	
	if(!IsDefined(crateType))
		return false;
	
	foreach(key,value in level.crateTypes[dropType])
	{
		if(key == crateType)
			return true;
	}
	
	return false;
	
}

breach_animated_door_init( door )
{
	AssertEx( IsDefined( door.script_noteworthy ), "animated_door in breach without animation defined in door.script_noteworthy" );
	if( IsDefined( level.breach_anims[ door.script_noteworthy + "_idle" ] ) )
	{
		door ScriptModelPlayAnim( level.breach_anims[ door.script_noteworthy + "_idle"] );	
	}
}

breach_door_init(door)
{
	target_ents = GetEntArray(door.target, "targetname");
	target_structs = getstructarray(door.target, "targetname");
	
	targets = array_combine(target_structs, target_ents);
	
	door_parts = [];
	pivot = undefined;
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch(target.script_noteworthy)
		{
			case "open":
				door.open_pos = target;
				break;
			case "closed":
				door.closed_pos = target;
				break;
			case "door_part":
				door_parts[door_parts.size] = target;
				break;
			case "pivot":
				pivot = target;
				break;
			default:
				break;
		}
	}
	
	if(!IsDefined(door.open_pos) || !IsDefined(door.closed_pos) || !IsDefined(pivot) || door_parts.size==0)
		return false; //ERROR
	
	door.closed_pos.move_angles = get_rotate_angle(door.open_pos.angles, door.closed_pos.angles, pivot.angles);
	door.open_pos.move_angles = -1 * door.closed_pos.move_angles;
	
	link_ent = spawn("script_model", pivot.origin);
	link_ent SetModel("tag_origin");
	link_ent.angles = pivot.angles;
	
	foreach ( ent in door_parts )
	{
		ent LinkTo(link_ent);
	}
	
	door.link_ent = link_ent;
	return true; //Great success
}

breach_other_watch(other)
{
	other waittill("breach_activated", player);
	self notify("breach_activated", player);
}

breach_open_watch()
{
	self waittill("breach_activated", player);
	
	if(IsDefined(player))
	{
		foreach(package in self.care_packages)
		{
			crateType = random(["deployable_vest", "emp", "ims"]);
			add_care_package(package.origin, package.angles, player, crateType);
		}
	}
	
	door_time = .2;
	
	// The breach triggers both lead to the same area, so disable both when one is used
	foreach( trigger in level.dart_linked_breach_triggers )
	{
		remove_from_bot_use_targets(trigger);
	}
	
	foreach(door in self.doors)
	{
		self thread breach_open_door(door, door_time);
	}
	
	foreach( animated_door in self.animated_doors )
	{
		animated_door ScriptModelPlayAnimDeltaMotion( level.breach_anims[ animated_door.script_noteworthy ] );
		
		switch(animated_door.script_noteworthy)
		{
			case "mp_dart_container_breach_side1":
				playSoundAtPos(animated_door.origin, "mp_dart_mtl_expl_01");
				break;
			case "mp_dart_container_breach_side2":
				playSoundAtPos(animated_door.origin, "mp_dart_mtl_expl_01");
				break;
			case "mp_dart_container_breach_top":
				playSoundAtPos(animated_door.origin, "mp_dart_mtl_expl_02");
				break;
			default:
				break;
		}

	}
	
	wait door_time;
	
	array_call(self.notsolid_ents, ::notsolid);
	array_call(self.delete_ents, ::delete);
	
	array_call(self.solid_ents, ::solid);
	foreach(ent in self.solid_ents)
	{
		ent Solid();
		if (IsDefined (level.players))
		{
			foreach ( player in level.players )
			{
				if(player IsTouching(ent))
				{
					self thread breach_kill_player(player);
				}
			}
		}
	}
}

breach_kill_player(player)
{
	RadiusDamage(player.origin, 8, 1000, 1000, self.owner, "MOD_CRUSH");
}

breach_open_door(door, time)
{
	breach_move_door(door, door.open_pos, time);
}

breach_close_door(door, time)
{
	breach_move_door(door, door.closed_pos, time);
}

breach_move_door(door, pos, time)
{
	angles = pos.angles;
	origin = pos.origin;
	
	if(IsDefined(time) && time>0)
	{
		if(IsDefined(angles) && angles !=door.link_ent.angles)
			door.link_ent RotateBy(pos.move_angles, time, time);
		if(IsDefined(origin) && origin != door.link_ent.origin)
			door.link_ent MoveTo(origin, time);
	}
	else
	{
		if(IsDefined(angles))
			door.link_ent.angles = angles;
		if(IsDefined(origin))
			door.link_ent.origin = origin;
	}
}

////////////
// Util
///////////
is_explosive( cause )
{
	if(!IsDefined(cause))
		return false;
	
	cause = tolower( cause );
	switch( cause )
	{
		case "mod_grenade_splash":
		case "mod_projectile_splash":
		case "mod_explosive":
		case "splash":
			return true;
		default:
			return false;
	}
	return false;
}
normalize_angles_180(angles)
{
	return (AngleClamp180(angles[0]), AngleClamp180(angles[1]), AngleClamp180(angles[2]));
}

get_rotate_angle(start, end, through)
{
	delta = end - start;
	delta = normalize_angles_180(delta);
	
	if(IsDefined(through))
	{
		dir = through - start;
		dir = normalize_angles_180(dir);
		
		for(i=0;i<3;i++)
		{
			//check if dir and delta have the same sign
			//if they dont the shortest path doesn't go through
			if(dir[i]*delta[i]<0)
			{
				change = 360;
				if(dir[i]<0)
					change = -360;
				delta = (delta[0]+(change*(i==0)), delta[1]+(change*(i==1)), delta[2]+(change*(i==2)));
			}
		}
	}
	
	return delta;
}

//////////////////////////
// Ceiling Rubble
/////////////////////////




ceiling_rubble()
{
	level thread ceiling_rubble_onPlayerConnect();
	wait .05;
	
	if (!IsDefined(level.fx_tag_origin))
		level.fx_tag_origin = spawn_tag_origin();
	
	rubbles = [];
	//Validate structs
	fxvolumes = GetEntArray("fx_building_impact","targetname");
	//foreach(volume in volumes)
	//{
	//	if(IsDefined(rubble.script_index))
	//	{
	//		rubble.radius_squared = rubble.radius*rubble.radius;
	//		rubbles[rubbles.size] = rubble;	
	//	}
	//}

	level thread do_rubble(fxvolumes);
}
wait_and_trigger_fx()
{
	wait(RandomFloatRange(0.0,0.4));
	TriggerFX(self);
}

do_rubble(fxvolumes)
{
	while(1)
	{
		level waittill("do_rubble", position);
		//tag_origin = spawn_tag_origin();
		foreach(volume in fxvolumes)
		{
			if(IsDefined(volume.script_index))
			{
				level.fx_tag_origin.origin = position;
				if (level.fx_tag_origin IsTouching(volume))
				{
					if (IsDefined(volume.script_index))
					{
						if (!IsDefined(volume.playing_effect))
							volume.playing_effect = false;
						if (volume.playing_effect == false)
						{
							volume.playing_effect = true;
							//exploder(volume.script_index);
							foreach ( effect in level.scripted_exploders[volume.script_index])
							{
								effect thread wait_and_trigger_fx();
							}
							volume thread clear_volume_flag();
						}
					}
				}
			}
		}
		//tag_origin delete();
	}
}
clear_volume_flag()
{
	wait(1.5);
	self.playing_effect = false;	
}

ceiling_rubble_onPlayerConnect()
{
	while(1)
	{
		level waittill("connected", player);
		player thread ceiling_rubble_watchUsage("missile_fire");
		player thread ceiling_rubble_watchUsage("grenade_fire");
	}
}

ceiling_rubble_watchUsage(note)
{
	self endon( "disconnect" );

	while(1)
	{
		self waittill( note, missile, weaponName );
		
		if(IsDefined(weaponName))
		{
			switch ( weaponName )
			{
				case "ac130_25mm_mp":
				case "flash_grenade_mp":
				case "concussion_grenade_mp":
				case "smoke_grenade_mp":
					continue;
			
				default:
					break;
			}
			
		}
		
		missile thread ceiling_rubble_missile_explode_watch();
	}
}

endOnDeath()
{
	self waittill( "death" );
	waittillframeend;
	self notify ( "end_of_frame_death" );
}

ceiling_rubble_missile_explode_watch()
{
	self thread endOnDeath();
	self endon("end_of_frame_death");
	self waittill( "explode", position );
	level notify("do_rubble", position);
}

search_bot()
{
	while(!IsDefined(level.players) || level.players.size==0)
		wait .05;
	
	allnodes = GetAllNodes();
	current_node = random(allnodes);
	player = level.players[0];
	
	search_bot = spawn("script_model", current_node.origin);
	search_bot SetModel("com_deploy_ballistic_vest_friend_world");
	
	while(1)
	{
		path_nodes = GetNodesOnPath(current_node.origin, player.origin);
		if(!IsDefined(path_nodes) || path_nodes.size == 0)
		{
			wait .1;
			continue;
		}
		
		goal_node = path_nodes[0];
		if(Distance(search_bot.origin,path_nodes[0].origin)<6)
		{
			if(path_nodes.size<=1)
			{
				wait .1;
				continue;
			}
			goal_node = path_nodes[1];
		}
		dir = goal_node.origin - current_node.origin;
		dir_angles = VectorToAngles(dir);
		
		speed = 180;
		dist = length(dir);
		time = dist/speed;
		
		if(time<=0)
		{
			wait .1;
			continue;
		}
		
		search_bot RotateTo(dir_angles,min(.5, time));
		search_bot MoveTo(goal_node.origin, time);
		search_bot waittill("movedone");
		current_node = goal_node;
	}
	
}