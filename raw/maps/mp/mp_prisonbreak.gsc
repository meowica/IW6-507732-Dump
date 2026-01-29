#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	maps\mp\mp_prisonbreak_precache::main();
	maps\createart\mp_prisonbreak_art::main();
	maps\mp\mp_prisonbreak_fx::main();
	
//	level thread rock_slides();
	level thread log_piles();
	
	maps\mp\_load::main();
	
	AmbientPlay( "ambient_mp_prisonbreak" );
	
  	maps\mp\_compass::setupMiniMap( "compass_map_mp_prisonbreak" );	
	
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.33 );
	setdvar( "r_diffuseColorScale", 1.37);
	setdvar( "r_specularcolorscale", "3.3" );
	
	if ( level.ps3 )
		setdvar( "sm_sunShadowScale", "0.8" ); // ps3 optimization
	else
		setdvar( "sm_sunShadowScale", "0.8" ); // optimization
	
	game["attackers"] = "allies";
	game["defenders"] = "axis";

	game[ "allies_outfit" ] = "woodland";
	game[ "axis_outfit" ] = "desert";

	if ( level.gametype == "sd" )
	{
		//level thread initPrisoners();
		level thread setOnBombTimerEnd();
	}
	
	//	cut for now, will try with anim support later
	//initInsertionVehicles();
	//level thread onAttackerSpawn();
	
	level thread tree_bridges();
	level thread falling_rocks();
	
	waitframe();
	level thread tower_radio();
}




setOnBombTimerEnd()
{
	level endon( "game_ended" );
	
	level.sd_onBombTimerEnd = ::onBombTimerEnd;
	
	level waittill( "bomb_planted", destroyedObj );
	
	if ( destroyedObj maps\mp\gametypes\_gameobjects::getLabel() == "_b" )
		level.sd_onBombTimerEnd = undefined;
}


onBombTimerEnd()
{	
	door1 = getEnt( "prisondoor1", "targetname" );
	door2 = getEnt( "prisondoor2", "targetname" );
	
	door1 RotateYaw( -70, 1.5 );
	door2 RotateYaw( 70, 1.5 );
	
	wait( 1 );
	level notify( "sd_free_prisoners" );
}


initPrisoners()
{
	initPrisonerLoadout();
	
	level.sd_prisonerObjective = getEnt( "sd_prisonerObjective", "targetname" );
	
	//	time needed for bot system initialization?
	wait( 3 );
	
	//	override _playerlogic::Callback_PlayerConnect() call to bot think
	level.bot_funcs["think"] = maps\mp\gametypes\_globallogic::blank;
	
	spawnPoints = getEntArray( "mp_spawn", "classname" );
	foreach( spawnPoint in spawnPoints )
		level thread createPrisoner( spawnPoint );	                          
}


createPrisoner( spawnPoint )
{
	bot = AddTestClient();	
	bot.pers[ "isBot" ] = true;
	bot.equipment_enabled = true;
	bot.bot_team = game["attackers"];	
	
	while(!isdefined(bot.pers["team"]))
		wait( 0.05 );	
	
	bot notify( "menuresponse", game["menu_team"], game["attackers"] );	
	wait( 0.5 );	
	
	bot.pers["gamemodeLoadout"] = level.sd_loadouts["prisoner"];
	
	spawnPoint.playerSpawnPos = spawnPoint.origin;
	spawnPoint.notTI = true;		
	bot.setSpawnPoint = spawnPoint;
	
	bot notify( "menuresponse", "changeclass", "gamemode" );	
	
	bot thread holdPrisoner();
}


holdPrisoner()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	
	self waittill( "spawned_player" );
	
	//	wait for prematch to finish
	gameFlagWait( "prematch_done" );

	self _disableWeapon();
	anchor = spawn( "script_origin", self.origin );
	self playerLinkTo( anchor );
	
	level waittill( "sd_free_prisoners" );
	
	self unlink();
	//self _enableWeapon();
	anchor delete();
	
	while( true )
	{
		self BotClearScriptGoal();
		self BotSetScriptGoal( level.sd_prisonerObjective.origin, 64, "critical" );		
		
		msg = self waittill_any_return( "goal", "bad_path" );
		if ( msg == "goal" )
			break;
		
		wait( 0.05 );
	}
}
	
	
initPrisonerLoadout()
{	
	//	bot
	level.sd_loadouts["prisoner"]["loadoutPrimary"] = "none";
	level.sd_loadouts["prisoner"]["loadoutPrimaryAttachment"] = "none";
	level.sd_loadouts["prisoner"]["loadoutPrimaryAttachment2"] = "none";
	level.sd_loadouts["prisoner"]["loadoutPrimaryBuff"] = "specialty_null";
	level.sd_loadouts["prisoner"]["loadoutPrimaryCamo"] = "none";
	level.sd_loadouts["prisoner"]["loadoutPrimaryReticle"] = "none";
	
	level.sd_loadouts["prisoner"]["loadoutSecondary"] = "none";
	level.sd_loadouts["prisoner"]["loadoutSecondaryAttachment"] = "none";
	level.sd_loadouts["prisoner"]["loadoutSecondaryAttachment2"] = "none";
	level.sd_loadouts["prisoner"]["loadoutSecondaryBuff"] = "specialty_null";
	level.sd_loadouts["prisoner"]["loadoutSecondaryCamo"] = "none";
	level.sd_loadouts["prisoner"]["loadoutSecondaryReticle"] = "none";
	
	level.sd_loadouts["prisoner"]["loadoutEquipment"] = "specialty_null";
	level.sd_loadouts["prisoner"]["loadoutOffhand"] = "none";
	
	level.sd_loadouts["prisoner"]["loadoutPerk1"] = "specialty_null";
	level.sd_loadouts["prisoner"]["loadoutPerk2"] = "specialty_null";
	level.sd_loadouts["prisoner"]["loadoutPerk3"] = "specialty_null";
	
	level.sd_loadouts["prisoner"]["loadoutActiveAbility"] = "specialty_null";
	level.sd_loadouts["prisoner"]["loadoutPassiveAbility"] = "specialty_null";
	
	level.sd_loadouts["prisoner"]["loadoutStreakType"] = "assault";
	level.sd_loadouts["prisoner"]["loadoutKillstreak1"] = "none";
	level.sd_loadouts["prisoner"]["loadoutKillstreak2"] = "none";
	level.sd_loadouts["prisoner"]["loadoutKillstreak3"] = "none";	
	
	level.sd_loadouts["prisoner"]["loadoutDeathstreak"] = "specialty_null";		

	level.sd_loadouts["prisoner"]["loadoutJuggernaut"] = false;	
}


//	script prototype
initInsertionVehicles()
{
	level.sd_insertionVehicles = [];
	starts = getEntArray( "sd_vehStart", "targetname" );	
	foreach ( start in starts )
	{
		vehicle = spawn( "script_model", start.origin );
		vehicle.origin = start.origin;
		vehicle.angles = start.angles;
		vehicle setModel( "vehicle_hummer_open_top_noturret" );
		
		path = [];	
		waypoint = getEnt( start.target, "targetname" );
		while ( isDefined( waypoint ) )
		{
			path[path.size] = waypoint;
			if ( isDefined( waypoint.target ) )
				waypoint = getEnt( waypoint.target, "targetname" );
			else
				break;
		}
		
		level.sd_insertionVehicles[start.script_count] = spawnStruct();
		level.sd_insertionVehicles[start.script_count].index = start.script_count;
		level.sd_insertionVehicles[start.script_count].vehicle = vehicle;
		level.sd_insertionVehicles[start.script_count].start = start;
		level.sd_insertionVehicles[start.script_count].path = path;
		level.sd_insertionVehicles[start.script_count].driver = false;
		level.sd_insertionVehicles[start.script_count].passenger = false;
		level.sd_insertionVehicles[start.script_count].arrived = false;
	}
	
	level.sd_insertionStarted = undefined;
}


onAttackerSpawn()
{
	level endon( "game_ended" );
	
	while( true )
	{
		level waittill( "player_spawned", player );
		
		if ( game["state"] != "postgame" && player.pers["team"] == game["attackers"] )
			player thread attackerRide();
	}
}


attackerRide()
{
	level endon( "game_ended" );
	self endon( "death" );
	self endon( "disconnect" );
	
	self _disableWeapon();
	
	//	first spawn triggers vehicles to start moving
	if ( !isDefined( level.sd_insertionStarted ) )
	{
		level.sd_insertionStarted = true;
		level thread startInsertionVehicles();
	}
	
	//	find a seat, search front to back vehicle, driver then passenger seats
	vehIndex = -1;
	isDriver = false;
	exitTag = "";
	vehicle = undefined;
	for ( i=0; i<level.sd_insertionVehicles.size; i++ )
	{
		vehicle = level.sd_insertionVehicles[i].vehicle;
		if ( !level.sd_insertionVehicles[i].driver )
		{
			vehIndex = i;
			isDriver = true;
			level.sd_insertionVehicles[i].driver = true;
			self playerLinkToDelta( vehicle, "tag_driver", 1, 30, 30, 30, 30, 1 );
			self setStance( "crouch" );
			
			if ( i==2 )
				exitTag = "tag_walker3";
			else
				exitTag = "tag_walker0";
			
			break;
		}
		else if ( !level.sd_insertionVehicles[i].passenger )
		{
			vehIndex = i;
			level.sd_insertionVehicles[i].passenger = true;
			self playerLinkToDelta( vehicle, "tag_passenger", 1, 30, 30, 30, 30, 1 );
			self setStance( "crouch" );
			
			if ( i==2 )
				exitTag = "tag_walker1";
			else
				exitTag = "tag_walker2";
			
			break;
		}
	}	
	if ( vehIndex < 0 )
		assertMsg( "Couldn't find seat for attacker in insertion vehicles!" );
	
	//	wait for ride to end
	wait( 0.05 );
	while ( !level.sd_insertionVehicles[vehIndex].arrived )
		wait( 0.05 );
	
	//	unlink from vehicle
	self unlink();
	self setStance( "stand" );
	
	//	create carrier to move player out of vehicle
	carrier = spawn( "script_model", self.origin );
	carrier.origin = self.origin;
	carrier.angles = self.angles;
	carrier setModel( "tag_player" );
	self playerLinkToDelta( carrier, "tag_player", 1, 30, 30, 30, 30, 1 );
	
	//	move player to the exit tag
	exitPos = vehicle getTagOrigin( exitTag );
	exitAngles = vehicle getTagAngles( exitTag );		
	time = distance( carrier.origin, exitPos ) / 100;
	carrier moveTo( exitPos, time, time/2, time/2 );
	carrier rotateTo( exitAngles, time, time/2, time/2 );
	
	wait( time );
	self unlink();
	carrier delete();
	
	self _enableWeapon();
	
	//	free up the seat (late spawns and suicides before end of grace period spawn in vehicle at arrival position)
	if ( isDriver )
		level.sd_insertionVehicles[vehIndex].driver = false;
	else
		level.sd_insertionVehicles[vehIndex].passenger = false;
}


startInsertionVehicles()
{
	level endon( "game_ended" );
	
	for ( i=0; i<level.sd_insertionVehicles.size; i++ )	
	{
		level thread vehicleMove( i );	
		wait( 0.3 );
	}
}


vehicleMove( vehicleIndex )
{
	level endon( "game_ended" );
	
	gameFlagWait( "prematch_done" );
	
	vehicle = level.sd_insertionVehicles[vehicleIndex].vehicle;
	path = level.sd_insertionVehicles[vehicleIndex].path;
	
	for ( i=0; i<path.size; i++ )
	{
		time = distance( vehicle.origin, path[i].origin ) / 550;
		accelTime = 0;
		decelTime = 0;
		if ( i == 0 )
			accelTime = time/2;
		else if ( i == path.size-1 )
			decelTime = time/2;
		
		vehicle moveTo( path[i].origin, time, accelTime, decelTime );
		vehicle rotateTo( path[i].angles, time );
		
		wait( time );
	}
	
	level.sd_insertionVehicles[vehicleIndex].arrived = true;	
}

////////////////////////////////
// Utility
////////////////////////////////
normalize_angles_180(angles)
{
	return (angle_180(angles[0]), angle_180(angles[1]), angle_180(angles[2]));
}

angle_180(ang)
{
	while(ang>180)
		ang -= 360;
	while(ang<-180)
		ang += 360;
	return ang;
}

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

/////////////
// Common trap code - used by multiple events
/////////
trap_init(remove)
{
	if( getDvar( "r_reflectionProbeGenerate" ) == "1" )
		return;
	
	if(!IsDefined(remove))
		remove = false;
	
	targets = GetEntArray(self.target, "targetname");
	
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch(target.script_noteworthy)
		{
			case "activate_trigger":
				if(remove)
				{
					target Delete();
				}
				else
				{
					self.activate_trigger = target;
				}
				break;
			case "use_model":
				if(remove)
				{
					target Delete();
				}
				else
				{
					self.use_model = target;
				}
				break;
			case "use_trigger":
				if(remove)
				{
					target Delete();
				}
				else
				{
					self.use_trigger = target;
				}
				break;
			default:
				break;
		}
	}
	
	if(IsDefined(self.activate_trigger) && IsDefined(self.use_model) && IsDefined(self.use_trigger))
	{
		self thread trap_use_watch();
		self thread trap_delete_visuals();
	}
}

trap_delete_visuals()
{
	self waittill("trap_activated");
	
	foreach(vis in self.useObject.visuals)
	{
		vis Delete();
	}
	
	self.useObject.visuals = [];
	
	trap_set_can_use(false);
}

trap_use_watch()
{
	wait .05;
	
	self.useObject = maps\mp\gametypes\_gameobjects::createUseObject( "neutral", self.use_trigger, [self.use_model], (0,0,0) );
	self.useObject.parent = self;
	
	self trap_set_can_use(true);
	self.useObject maps\mp\gametypes\_gameobjects::setUseTime( 4 );		
	self.useObject maps\mp\gametypes\_gameobjects::setUseText( &"MP_SET_TRAP" );
	self.useObject maps\mp\gametypes\_gameobjects::setUseHintText( &"MP_SET_TRAP" );
	self.useObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	self.useObject.onUse = ::trap_onUse;	
}

trap_set_can_use(canUse)
{
	if(canUse)
	{
		if( IsDefined( self.use_icon_angles ) && IsDefined( self.use_icon_origin ) )
		{
			self thread hand_icon( "use", self.use_icon_origin, self.use_icon_angles, "trap_triggered" );
		}
				
		foreach(vis in self.useObject.visuals)
		{
			vis SetModel("mil_semtex_belt_obj");
		}
		
		self.useObject maps\mp\gametypes\_gameobjects::allowUse( "any" );
	}
	else
	{
		foreach(vis in self.useObject.visuals)
		{
			vis SetModel("mil_semtex_belt");
		}
		self.useObject maps\mp\gametypes\_gameobjects::allowUse( "none" );
	}
}

trap_onUse(player)
{
	self.parent trap_set_can_use(false);
	self.parent notify( "trap_triggered" );
	
	self.parent.owner = player;
	self.parent thread trap_owner_watch();
	self.parent thread trap_active_watch();
}

trap_owner_watch()
{
	self endon("trap_activated");
	
	self.owner waittill("death");
	
	self trap_set_can_use(true);
}

trap_active_watch()
{
	self endon("trap_activated");
	self.owner endon("death");
	
	while(1)
	{
		self.activate_trigger waittill("trigger", player);
		
		if ( trap_can_damage_player(player) )
			break;
	}
	
	self notify("trap_activated");
}

trap_can_damage_player(player)
{
	if(!IsDefined(self.owner))
		return false;
	
	if(!level.teamBased)
		return true;
	
	if(player.team != self.owner.team)
		return true;
	
	return false;
}

////////////////////////////////
// Tree Bridges
////////////////////////////////
tree_bridges()
{
	PrecacheMpAnim("mp_prisonbreak_tree_fall");
	
	bridges = getstructarray("tree_bridge","targetname");
	array_thread(bridges, ::tree_bridge_init);
}

tree_bridge_init()
{
	self.tree = undefined;
	self.clip_up = undefined;
	self.clip_down = undefined;
	
	self.linked_ents = [];
	targets = GetEntArray(self.target, "targetname");
	structs = getstructarray(self.target, "targetname");
	
	targets = array_combine(targets, structs);
	
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch(target.script_noteworthy)
		{
			case "the_tree":
				self.tree = target;
				self.linked_ents[self.linked_ents.size] = target;
				break;
			case "clip_up":
				self.clip_up = target;
				self.linked_ents[self.linked_ents.size] = target;
				break;
			case "clip_down":
				self.clip_down = target;
				self.clip_down trigger_off();
				break;
			case "support":
				self thread tree_bridge_damage_watch(target, true);
				break;
			case "link":
				self.linked_ents[self.linked_ents.size] = target;
				break;
			case "delete":
				self.decal = target;
				break;
			default:
				break;
		}
	}
	
	self.animated_prop = spawn("script_model", self.tree.origin);
	self.animated_prop SetModel("generic_prop_raven");
	self.animated_prop.angles = self.tree.angles;
	
	foreach ( ent in self.linked_ents )
	{
		ent LinkTo(self.animated_prop, "j_prop_2");
	}
	
	//self thread tree_bridge_damage_watch();
	self thread tree_bridge_run();
}

tree_bridge_damage_watch(watch_ent, delete_on_trigger)
{
	self endon("tree_down");
	
	if(!IsDefined(delete_on_trigger))
		delete_on_trigger = false;
	
	large_health_value = 1000000;
	damage_needed_to_fall = 100;
	
	watch_ent.health = large_health_value;
	watch_ent SetCanDamage(true);
	
	while(1)
	{
		watch_ent waittill("damage");
		if(watch_ent.health < (large_health_value - damage_needed_to_fall))
			break;
	}
	
	watch_ent SetCanDamage(false);
	
	if(delete_on_trigger)
		watch_ent Delete();
	
	self notify("tree_down");
}

#using_animtree("animated_props");
tree_bridge_run()
{
	self waittill("tree_down");
	
	if( IsDefined( self.decal ) )
	{
		self.decal Delete();
	}
	
	self.clip_up ConnectPaths();
	
	self.animated_prop ScriptModelPlayAnimDeltaMotion("mp_prisonbreak_tree_fall");
	wait GetAnimLength( %mp_prisonbreak_tree_fall );
	
	self.clip_down trigger_on();
	self.clip_up Delete();
}

////////////////////////////////
// Log Piles
////////////////////////////////
log_piles()
{
	log_piles_precache();
	
	wait .05;
	
	piles = getstructArray("logpile","targetname");
	array_thread(piles, ::log_pile_init);
}

log_piles_precache()
{
	level.log_visual_link_joints = [];
	level.log_visual_link_joints["ten_log_roll"] = "j_log_5";
	
	level.log_anim_lengths = [];
	level.log_anim_lengths["ten_log_roll"] = GetAnimLength( %mp_prisonbreak_log_roll );
	
	level.log_anims = [];
	level.log_anims["ten_log_roll"] = "mp_prisonbreak_log_roll";
	foreach(key,value in level.log_anims)
	{
		PrecacheMpAnim(value);
	}
}

log_pile_init()
{
	self.logs = [];
	self.animated_logs = [];
	self.log_supports = [];
	self.log_supports_broken = [];
	self.clip_delete = [];
	self.clip_show = [];
	self.clip_move = [];
	self.kill_trigger = undefined;
	self.kill_trigger_linked = undefined;
	
	link_visuals_to = undefined;
	link_visuals_to_tag = undefined;
	
	if(!IsDefined(self.angles))
		self.angles = (0,0,0);
	
	targets = GetEntArray(self.target, "targetname");
	targets = array_combine( targets, getstructarray( self.target, "targetname" ) );
	
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch(target.script_noteworthy)
		{
			case "log_with_use_visuals":
				link_visuals_to = target;
				//fallthrough
			case "log":
				self.logs[self.logs.size] = target;
				if(IsDefined(target.target))
					target.endpos = GetStruct(target.target, "targetname");
				break;
			case "animated_log_use_visuals":
				link_visuals_to = target;
				if(IsDefined(target.script_animation))
					link_visuals_to_tag = level.log_visual_link_joints[target.script_animation];
				//fallthrough
			case "animated_log":
				if(IsDefined(target.script_animation) && IsDefined(level.log_anims[target.script_animation]))
					self.animated_logs[self.animated_logs.size] = target;
				break;
			case "log_support":
				self.log_supports[self.log_supports.size] = target;
				self thread log_pile_support_damage_watch(target);
				break;
			case "log_support_broken":
				self.log_supports_broken[self.log_supports_broken.size] = target;
				target Hide();
				break;
			case "clip_delete":
				self.clip_delete[self.clip_delete.size] = target;
				break;
			case "clip_move":
				//This is set up so the end position is viewed in the editor
				if(IsDefined(target.target))
				{
					target.end_pos = getstruct(target.target, "targetname");
					if(IsDefined(target.end_pos) && IsDefined(target.end_pos.target))
					{
						target.start_pos = getstruct(target.end_pos.target, "targetname");
						if(IsDefined(target.start_pos))
						{
							target.move_delta = target.end_pos.origin - target.start_pos.origin;
							if(target is_dynamic_path())
								target ConnectPaths();
							target.origin = target.origin - target.move_delta;
							self.clip_move[self.clip_move.size] = target;
						}
					}
				}
				break;
			case "clip_show":
				self.clip_show[self.clip_show.size] = target;
				target Hide();
				target NotSolid();
				break;
			case "kill_trigger":
				self.kill_trigger = target;
				if(IsDefined(self.kill_trigger.target))
				{
					self.kill_trigger.start_pos = getstruct(self.kill_trigger.target, "targetname");
					if(IsDefined(self.kill_trigger.start_pos) && isDefined(self.kill_trigger.start_pos.target))
					{
						self.kill_trigger.end_pos = getstruct(self.kill_trigger.start_pos.target, "targetname");
						if(IsDefined(self.kill_trigger.end_pos))
						{
							self.kill_trigger.script_mover = spawn("script_model", self.kill_trigger.start_pos.origin);
							self.kill_trigger.script_mover SetModel("tag_origin");
							self.kill_trigger.script_mover.killCamEnt = self.kill_trigger.script_mover;
							self.kill_trigger EnableLinkTo();
							self.kill_trigger LinkTo(self.kill_trigger.script_mover, "tag_origin");
						}
					}
				}
				break;
			case "kill_trigger_link":
				self.kill_trigger_linked = target;
				self.kill_trigger_linked EnableLinkTo();
				break;
			case "use_icon":
				self.use_icon_origin = target.origin;
				self.use_icon_angles = target.angles;
				break;
			default:
				break;
		}
	}
	
	self.nodes = GetNodeArray(self.target, "targetname");
	foreach(node in self.nodes)
	{
		node DisconnectNode();
	}
	
	if((self.logs.size || self.animated_logs.size) && self.log_supports.size>0)
	{
		self thread log_pile_run();
		self thread trap_init();
	}
	
	if(IsDefined(link_visuals_to) && IsDefined(self.use_model))
	{
		if(IsDefined(link_visuals_to_tag))
		{
			self.use_model LinkTo(link_visuals_to, link_visuals_to_tag);
			if(isDefined(self.kill_trigger_linked))
				self.kill_trigger_linked linkTo(link_visuals_to, link_visuals_to_tag);
			
		}
		else
		{
			self.use_model LinkTo(link_visuals_to);
			if(isDefined(self.kill_trigger_linked))
				self.kill_trigger_linked linkTo(link_visuals_to);
		}
	}
}

log_pile_support_damage_watch(log_support)
{
	self endon("trap_activated");
	
	large_health_value = 1000000;
	
	log_support.health = large_health_value;
	log_support SetCanDamage(true);
	
	while(1)
	{
		log_support waittill("damage", amount, attacker, direction_vec, point, type );
		
		log_support.health = large_health_value;
		if(is_explosive(type) && amount>=10)
		{
			self.owner = attacker;
			break;
		}
	}
	
	log_support SetCanDamage(false);
	
	self notify("trap_activated");
}

log_pile_run()
{
	self waittill("trap_activated");
	
	self trap_set_can_use(false);
	
	log_roll_time = 1.2;
	self thread log_pile_kill_trigger(self.kill_trigger);
	self thread log_pile_kill_trigger(self.kill_trigger_linked);
	self thread log_pile_kill_trigger_end(log_roll_time);
	
	array_call(self.log_supports, ::delete);
	array_call(self.log_supports_broken, ::Show);
	array_call(self.clip_delete, ::delete);
	array_call(self.clip_show, ::show);
	array_call(self.clip_show, ::solid);
	
	foreach(clip_move in self.clip_move)
	{
		if(clip_move is_dynamic_path())
			clip_move delayCall(log_roll_time, ::DisconnectPaths);
		clip_move MoveTo(clip_move.origin + clip_move.move_delta, log_roll_time);
	}
	
	if(IsDefined(self.kill_trigger) && IsDefined(self.kill_trigger.script_mover))
	{
		//TODO: Support angle change?
		self.kill_trigger.script_mover MoveTo(self.kill_trigger.end_pos.origin, log_roll_time, log_roll_time*.5, 0);
	}
	
	foreach(log in self.logs)
	{
		if(IsDefined(log.endpos))
		{
			log MoveTo(log.endpos.origin, log_roll_time, log_roll_time*.5, 0);
			
			delta_angles = log.endpos.angles - log.angles;
			delta_angles = normalize_angles_180(delta_angles);
			delta_angles += (4 * 360,0,0); //Roll 4 times
			vel = delta_angles/log_roll_time;
			log RotateVelocity(vel, log_roll_time, log_roll_time*.5, 0);
		}
	}
	
	foreach(animated_log in self.animated_logs)
	{
		animated_log ScriptModelPlayAnimDeltaMotion( level.log_anims[animated_log.script_animation] );
		
		anim_length = level.log_anim_lengths[animated_log.script_animation];
		if(isDefined(anim_length) && anim_length>log_roll_time)
		{
			log_roll_time = anim_length;
		}
	}
	
	
	wait log_roll_time;

	self notify("log_roll_done");
	
	wait .05;
	foreach(node in self.nodes)
	{
		node ConnectNode();
	}
	
}

log_pile_kill_trigger(trigger)
{
	if(!IsDefined(trigger))
		return;
	
	self endon("log_roll_end_kill_trigger");
	while(1)
	{
		trigger waittill("trigger", player);
		
		if ( !log_pile_can_damage_player(player) )
			continue;
		
		inflictor = trigger;
		if(IsDefined(trigger.script_mover))
			inflictor = trigger.script_mover;
		
		inflictor RadiusDamage(player.origin, 8, 1000, 1000, self.owner, "MOD_CRUSH", "none");
	}
}

log_pile_kill_trigger_end(waitTime)
{
	wait waitTime;
	self notify("log_roll_end_kill_trigger");
}

log_pile_can_damage_player(player)
{
//	if(!IsDefined(self.owner))
//		return false;
//	
//	if(!level.teamBased)
//		return true;
//	
//	if(player.team != self.owner.team)
//		return true;
//	
//	return false;
	
	return true;
}

////////////////////////////////
// Falling Rocks
////////////////////////////////
falling_rocks()
{
	rocks = getEntArray("falling_rock","targetname");
	array_thread(rocks, ::falling_rock_init);
}

falling_rock_init()
{
	
	self.fall_to =[]; 
	self.clip_move = [];
	
	targets = GetEntArray(self.target, "targetname");
	structs = getstructarray(self.target, "targetname");
	
	targets = array_combine(targets, structs);
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch(target.script_noteworthy)
		{
			case "kill_trigger":
				target EnableLinkTo();
				target LinkTo(self);
				self.kill_trigger = target;
				break;
			case "rock_clip":
				target LinkTo(self);
				self.clip = target;
				break;
			case "fall_to":
				self.fall_to[self.fall_to.size] = target;
				target.fall_dist = Distance(self.origin, target.origin);
				self.fall_dist = target.fall_dist;
				
				while(IsDefined(target.target))
				{
					prev_target = target;
					target = getstruct(target.target, "targetname");
					if(!IsDefined(target))
						break;
					
					self.fall_to[self.fall_to.size] = target;
					target.fall_dist = Distance(prev_target.origin, target.origin);
					self.fall_dist += target.fall_dist;
				}
				break;
				
			case "clip_move":
				//This is set up so the end position is viewed in the editor
				if(IsDefined(target.target))
				{
					target.end_pos = getstruct(target.target, "targetname");
					if(IsDefined(target.end_pos) && IsDefined(target.end_pos.target))
					{
						target.start_pos = getstruct(target.end_pos.target, "targetname");
						if(IsDefined(target.start_pos))
						{
							target.move_delta = target.end_pos.origin - target.start_pos.origin;
							target.origin = target.origin - target.move_delta;
							if(target is_dynamic_path())
								target ConnectPaths();
							self.clip_move[self.clip_move.size] = target;
						}
					}
				}
				break;
			default:
				break;
		}
	}
	
	self thread falling_rock_damage_watch();
	self thread falling_rock_run();
}

is_dynamic_path()
{
	return IsDefined(self.spawnflags) && self.spawnflags&1;
}

falling_rock_damage_watch()
{
	large_health_value = 1000000;
	
	self.health = large_health_value;
	self SetCanDamage(true);
	
	while(1)
	{
		self waittill("damage", amount, attacker, direction_vec, point, type );
		
		self.health = large_health_value;
		if(is_explosive(type))
		{
			self.attacker = attacker;
			break;
		}
	}
	
	self SetCanDamage(false);
	
	self notify("rock_fall");
}

falling_rock_run()
{
	self waittill("rock_fall");
	
	fall_time = 1.0;
	
	self thread falling_rock_kill_trigger();
	
	accel = 1;
	for(i=0; i<self.fall_to.size; i++)
	{
		next = self.fall_to[i];
		
		time = (next.fall_dist/self.fall_dist) * fall_time;
		
		self MoveTo(next.origin, time, time*accel, 0);
		self RotateTo(next.angles, time, time*accel, 0);
		
		//the last move, raise the clip
		if(i==self.fall_to.size-1)
		{
			foreach(clip_move in self.clip_move)
			{
				if(clip_move is_dynamic_path())
					clip_move delayCall(time, ::DisconnectPaths);
				clip_move MoveTo(clip_move.origin + clip_move.move_delta, time);
			}
		}
		
		self waittill("movedone");
		accel = 0; //only first move accels
	}
	
	self notify("rock_move_done");
	self.clip Delete();
	self.kill_trigger Delete();
}

falling_rock_kill_trigger()
{
	self endon("death");
	self endon("rock_move_done");
	
	while(1)
	{
		self.kill_trigger waittill("trigger", player);
		
		RadiusDamage(player.origin, 8, 1000, 1000, self.attacker, "MOD_CRUSH");
	}
	
}

////////////////////////////////
// Rock Slide
////////////////////////////////
rock_slides()
{
	rock_slides_precache();
	
	wait .05;
	rocks = getStructArray("rock_slide","targetname");
	array_thread(rocks, ::rock_slides_init);
}

rock_slides_precache()
{
	
}

rock_slides_init()
{	
	self.ground_ents = [];
	self.rocks = [];
	
	targets = GetEntArray(self.target, "targetname");
	
	remove = true;
	
	foreach(target in targets)
	{
		if(!IsDefined(target.script_noteworthy))
			continue;
		
		switch(target.script_noteworthy)
		{
			case "ground":
				if(IsDefined(target.target) && !remove)
				{
					target.start_pos = getstruct(target.target, "targetname");
					if(IsDefined(target.start_pos) && IsDefined(target.start_pos.target))
					{
						target.end_pos = getstruct(target.start_pos.target, "targetname");
						if(IsDefined(target.end_pos))
						{
							target.move_ent = spawn("script_model", target.start_pos.origin);
							target.move_ent SetModel("tag_origin");
							target.move_ent.angles = target.start_pos.angles;
							target LinkTo(target.move_ent);
							self.ground_ents[self.ground_ents.size] = target;
							target.move_delete = IsDefined(target.end_pos.script_noteworthy) && target.end_pos.script_noteworthy=="delete";
						}
					}
				}
				break;
			case "rock":
				if(remove)
				{
					target Delete();
				}
				else
				{
					target.end_pos = getstruct(target.target, "targetname"); 
					if(IsDefined(target.end_pos))
					{
						self.rocks[self.rocks.size] = target;
						target.move_delete = IsDefined(target.end_pos.script_noteworthy) && target.end_pos.script_noteworthy=="delete";	
					}
				}
				
				break;
			default:
				break;
		}
	}
	
	if(!remove)
	{
		array_thread(self.ground_ents, ::rock_slide_damage_watch, self);
		self thread rock_slide_run();
	}
	self thread trap_init(remove);
}

rock_slide_damage_watch(parent)
{
	parent endon("trap_activated");
	
	large_health_value = 1000000;
	
	self.health = large_health_value;
	self SetCanDamage(true);
	
	while(1)
	{
		self waittill("damage", amount, attacker, direction_vec, point, type );
		
		self.health = large_health_value;
		if(is_explosive(type))
		{
			self.attacker = attacker;
			break;
		}
	}
	
	self SetCanDamage(false);
	
	parent notify("trap_activated");
}

rock_slide_run()
{
	self waittill("trap_activated");
	
	Earthquake(.4, 3, self.origin, 800);
	
	rock_time = 1.5;
	foreach(rock in self.rocks)
	{
		rock MoveTo(rock.end_pos.origin, rock_time, rock_time, 0);
		rock RotateTo(rock.end_pos.angles, rock_time, rock_time, 0);
		if(rock.move_delete)
			rock delayCall(rock_time, ::delete);
	}
	
	wait .5;
	
	slide_time = 1;
	foreach ( ent in self.ground_ents )
	{
		ent.move_ent MoveTo(ent.end_pos.origin, slide_time, slide_time, 0);
		ent.move_ent RotateTo(ent.end_pos.angles, slide_time, slide_time, 0);
		if(ent.move_delete)
			ent delayCall(rock_time, ::delete);
	}
}

hand_icon(type, origin, angles, end_ons)
{
	if(level.createFX_enabled)
		return;
	if(!IsDefined(level.hand_icon_count))
		level.hand_icon_count = 0;
	
	level.hand_icon_count++;
	
	icon_id = "hand_icon_" + level.hand_icon_count;
	
	hand_icon_update(type, origin, angles, icon_id, end_ons);
	
	foreach(player in level.players)
	{
		if(IsDefined(player.hand_icons) && IsDefined(player.hand_icons[icon_id]))
		{
			player.hand_icons[icon_id] thread hand_icon_fade_out();
		}
	}
}

hand_icon_update(type, origin, angles, icon_id, end_ons)
{	
	if(IsDefined(end_ons))
	{
		if(isString(end_ons))
			end_ons = [end_ons];
		
		foreach(end_on in end_ons)
			self endon(end_on);
	}
	
	while(!IsDefined(level.players))
		wait .05;

	show_dist = 200;
	icon = "hint_usable";
	pin = false;
	switch(type)
	{
		default:
			break;
	}
	
	dir = undefined;
	if(IsDefined(angles))
	{
		dir = AnglesToForward(angles);
	}
	
	show_dist_sqr = show_dist*show_dist;
	
	while(1)
	{
		foreach(player in level.players)
		{
			if(!IsDefined(player.hand_icons))
				player.hand_icons = [];
			
			test_origin = player.origin+(0,0,50); //Switches are about 50 units off the ground
			dist_sqr = DistanceSquared(test_origin, origin);
			
			dir_check = true;
			if(IsDefined(dir))
			{
				dir_to_player = VectorNormalize(test_origin - origin);
				dir_check = VectorDot(dir, dir_to_player)>.2;
			}
			
			if(dist_sqr<=show_dist_sqr && dir_check && (!isDefined(self.in_use) || !self.in_use) && !( player isUsingRemote() ) )
			{
				if(!IsDefined(player.hand_icons[icon_id]))
				{
					player.hand_icons[icon_id] = hand_icon_create(player, icon, origin, pin);
					player.hand_icons[icon_id].alpha = 0;
				}
				
				player.hand_icons[icon_id] notify("stop_fade");
				player.hand_icons[icon_id] thread hand_icon_fade_in();
			}
			else
			{
				if(IsDefined(player.hand_icons[icon_id]))
				{
					player.hand_icons[icon_id] thread hand_icon_fade_out();
				}
			}
		}
		wait .05;
	}
}

hand_icon_create(player, icon, origin, pin)
{
	icon = player createIcon( icon, 16, 16 );
	icon setWayPoint( true, pin );
	icon.x = origin[0];
	icon.y = origin[1];
	icon.z = origin[2];
	return icon;
}
	
hand_icon_fade_in()
{
	self endon("death");
	
	if(self.alpha == 1)
		return;
	
	self FadeOverTime(.5);
	self.alpha = 1;
}

hand_icon_fade_out()
{
	self endon("death");
	self endon("stop_fade");
	
	if(self.alpha == 0)
		return;
	
	time = .5;
	self FadeOverTime(time);
	self.alpha = 0;
	wait time;

	self Destroy();
}

tower_radio()
{
	tower_radio = GetEnt( "tower_radio", "targetname" );
	
	tower_radio.tracklist = [];
	tower_radio.tracklist[0] = "mus_emt_portable_radio_01";
	tower_radio.tracklist[1] = "mus_emt_portable_radio_02";
	tower_radio.tracklist[2] = "mus_emt_portable_radio_03";
	
	gameFlagWait( "prematch_done" );
		
	tower_radio thread tower_radio_damage_watch();
	
	tower_radio endon( "death" );
	
	while( 1 )
	{
		level waittill( "connected", player );
		tower_radio thread tower_radio_sounds( player );
	}
}

tower_radio_damage_watch()
{
	self.health = 10000;
	self SetCanDamage( true );
	self waittill( "damage", damage, attacker, direction_vec, point, type );
	self PlaySound( "radio_destroyed_static" );
	self PhysicsLaunchClient( point, direction_vec );
}

tower_radio_sounds( player )
{
	self endon( "damage" );
	
	player waittill( "spawned_player" );
	waitframe();
	
	last_song = "";
	
	while( 1 )
	{
		song = last_song;
		while( song == last_song )
		{
			song = random( self.tracklist );
		}
		song_length = LookupSoundLength( song ) / 1000;
		if( song_length < 0.1 )
		{
			// breakpoint; // something went horribly wrong, bad soundalias or sound length
			wait( 5.0 ); // fail quietly, since at this point, it's probably more important that the map run than we force audio to get their .wav files out of devraw
		}
		else
		{
			self PlaySoundToPlayer( song, player );
		}

		wait( song_length );
		last_song = song;
	}	
}
