#include maps\_utility;
#include common_scripts\utility;
#include maps\enemyhq_code;
#include maps\_vehicle;
#include maps\_vehicle_code;
#include maps\_anim;
#include maps\ally_attack_dog;

enemyhq_finale_pre_load()
{
	flag_init("finale_sniping");
	flag_init("finale_lynx_stop");
	flag_init("open_finale_doors");
	flag_init("start_butchdance");
	flag_init("end_of_sniping");
	flag_init("butchdance_sniping");
	flag_init("finale_combat1");
	flag_init("finale_combat3");
	flag_init("more_finale_guys");
	flag_init("flyaway_baddies");
	flag_init( "finale_done" );
}


setup_finale()
{
	level.start_point = "finale";
	maps\enemyhq::setup_common();
	
	flag_set("hvt_done");
	vision_set_changes("enemyhq_basement",0);  // TODO ADD A TRIGGER OUTSIDE TO TURN THIS OFF
	
	spawner = GetEnt("bishop", "targetname");
	level.bishop = spawner spawn_ai(true, true);
	level.bishop.animname = "bishop";
	level.bishop make_hero();
	level.bishop gun_remove();
	level.allies[0] carry_bishop();
	
	safe_activate_trigger_with_targetname("pre_exit");
}

begin_finale()
{
	guys = GetAIArray("axis");
	// clean up any leftover baddies
	array_thread (guys, ::die_quietly);
	
	level.finale_chopper = spawn_vehicle_from_targetname("finale_chopper");
//	level.finale_chopper thread vehicle_land();
	level.finale_chopper.origin = (406, -3620, -504);  // TEMP HACK
	level.finale_chopper godon();
	level.finale_chopper HidePart("door_L");
	level.finale_chopper HidePart("door_R");

	flag_clear("done_sniping_early");
	
	autosave_by_name("butchdance");
	
	thread handle_agressive_player();
	thread finale_vo();
	thread finale_dog_hijack();
	thread butchdance_combat();
	
	flag_wait("open_finale_doors");
	thread open_exit_doors();
	
	safe_activate_trigger_with_targetname("to_exit");

//	flag_wait("start_butchdance");
	
	level waittill("hot_butchdance_action");
	
	// move allies up inside the tunnel
	allies = array_combine(level.allies, make_array(level.bishop, level.dog));
	array_thread(allies, ::super_guy, true);
	safe_activate_trigger_with_targetname("butchdance0");
// cheaty teleport thing to make sure they're in position when needed
	node = GetNode("pre_exit_spot0", "targetname");
	level.allies[0] teleport_ai(node);
	node = GetNode("pre_exit_spot1", "targetname");
	level.allies[1] teleport_ai(node);
//	safe_activate_trigger_with_targetname("butchdance1");

	flag_wait("finale_asplode");
/*	
	// make bad guys less accurate
	guys = GetAIArray("axis");
	foreach (guy in guys)
	{
		guy.accuracy = 0.01;
		
	}
*/
	arms = spawn_anim_model( "player_rig" );
    arms.animname = "player_rig";
	arms SetModel( "viewhands_player_yuri" );
	arms LinkTo( level.finale_chopper , "tag_guy5", (0,0,0), (0,0,0));
	arms thread anim_first_frame_solo( arms, "get_in_chopper" );
	arms hide();

	flag_wait("get_in_choppa");
	level.player EnableInvulnerability();
	
	wait 0.5;
	
	// player get in chopper
	level.player DisableWeapons();
	level.player PlayerLinkToBlend(arms, "tag_player", 0.1);
	arms show();
	arms anim_single_solo( arms, "get_in_chopper" );
	level.player PlayerLinkTo( arms, "tag_player", 1,70,70,70,70 );	
	
	level.player EnableWeapons();
	
	thread finale_flyaway();
	thread finale_sniping();
	

	wait 20;

	flag_set("finale_done");
	
	
	level.player notify("fadeup_static_finale");
/*
	black = create_overlay_element( "black", 0 );
	black fadeovertime( 2 );
	black.alpha = 1;
*/	
	wait 5;	
	nextmission();
//	IPrintLnBold("END OF SCRIPTING");
}

super_guy(on)
{
	self.ignoreSuppression = on;
	if (on)
	{
		self.old_accuracy = self.baseaccuracy;
		self.baseaccuracy = 0.1;
	}
	else
	{
		self.baseaccuracy = self.old_accuracy;
	}
	self.doDangerReact = !on;
	self.disableBulletWhizbyReaction = on;
}
	
	
finale_dog_hijack()
{
	dog_struct = GetStruct("dog_hijack", "targetname");
	guy_struct = GetStruct("dog_hijack_dude", "targetname");
	
	spawner = GetEnt("dog_hijackee", "targetname");
	guy = spawner spawn_ai(true, true);
	guy.ignoreall = true;
	guy.ignoreme = true;
	guy.animname = "generic";
	guy_struct thread anim_first_frame_solo(guy, "dog_hijack");
	
	flag_wait("finale_push2");
	level.dog set_dog_scripted_mode( level.player );
	level.dog.allowpain = false;
	level.dog.animname = "dog";
	dog_struct anim_reach_solo(level.dog, "dog_hijack");
	
	dog_struct thread anim_single_solo(level.dog, "dog_hijack");
	guy_struct thread anim_single_solo(guy, "dog_hijack");
	guy stop_magic_bullet_shield();
	guy.ignoreme = false;
	guy die();
}


finale_flyaway()
{
	wait 5;
	target_node = GetStruct("finale_chopper_path", "targetname");
	
	level.finale_chopper.attachedpath = undefined;
    level.finale_chopper notify( "newpath" );
    level.finale_chopper thread vehicle_paths( target_node );
    level.finale_chopper Vehicle_SetSpeed( 5, 30, 30 ); //needed to get the vehicle moving
    level.finale_chopper ResumeSpeed( 5 );
}

open_exit_doors()
{
	breach_door_left = GetEnt( "dugout_exit_door_left", "targetname" );
	breach_door_right = GetEnt( "dugout_exit_door_right", "targetname" );

	breach_door_left RotateYaw( -105, 0.2, 0.1, 0.1 );	
	breach_door_left ConnectPaths();
	breach_door_left NotSolid();
	
	breach_door_right RotateYaw( 105, 0.2, 0.1, 0.1 );
	breach_door_right ConnectPaths();
	breach_door_right NotSolid();

	wait 1;
	thread add_dialogue_line("Keegan", "Incoming!  Back down!");
}

watch_for_end_of_sniping()
{
	level waittill("hot_butchdance_action");	
	flag_set("butchdance_sniping");
	
	level.player waittill("remote_turret_deactivate");
	flag_set("end_of_sniping");
	
	array_thread(level.allies, ::set_ignoreSuppression, false);
	
	level.bishop notify("stop_anim");
	level.allies[0] notify("stop_anim");
	level.allies[0] die_quietly();
	level.allies[1] die_quietly();
	
	level.bishop die_quietly();
	
	level.allies = make_array(level.allies[2]);

}

spawn_lockdown_guy()
{
	while ( !flag("finale_sniping") )
	{
		guy = self spawn_ai(true);
		guy gasmask_on_npc();
		if (IsDefined(self.script_aigroup) && self.script_aigroup == "finale_lmgs")
		{
			guy GetEnemyInfo(level.player);
		}
		guy thread handle_butchdance_enemies();
		
		if (IsDefined(guy))
		{
			guy waittill("death");
			wait 0.5;
		}
		else
		{
			return;
		}
	}
}

clear_lmgs()
{
	waittill_aigroupcleared("finale_lmgs")
	flag_set("finale_combat1");
}

handle_agressive_player()
{
	level endon("death");
	struct = GetStruct("killer_org", "targetname");
	
	flag_wait("finale_kill");
	
	delay = 0.5;
	
	if ( !flag("end_of_sniping") )
	{
		while (flag("finale_kill") )
		{
			MagicBullet("pecheneg", struct.origin, level.player.origin + (0,0,32));
			
			if (flag("finale_really_kill"))
			{
				level.player Kill();
			}
			
			wait delay;
			
			if (!flag("finale_kill") )
			{
				delay = 0.5;
			}
			else
			{
				delay -= 0.1;
				
				if (delay < 0.1)
					delay = 0.1;
			}
			   
		}
	}
}

butchdance_combat()
{
	spawners = GetEntArray("exfil_guys1", "targetname");

	foreach (spawner in spawners)
	{
		spawner thread spawn_lockdown_guy();
	}
	
	
	level.player waittill("scripted_sniper_dpad");
	flag_set("finale_sniping");
	
	guys = array_spawn_targetname_allow_fail("exfil_guys1b", true);
	array_thread(guys, ::handle_butchdance_enemies);

	guys = GetAIArray("axis");
	
	thread ai_array_killcount_flag_set(guys, 2, "finale_combat1");
	thread ai_array_killcount_flag_set(guys, int(min(guys.size, 6)), "done_sniping_early");
	thread clear_lmgs();
	
	flag_wait("finale_combat1");
	guys = GetAIArray("axis");
	guys array_thread(guys, ::set_force_color, "y");
	guys array_thread(guys, ::enable_ai_color );
	array_thread(level.allies, ::set_ignoreSuppression, true);
	
//	level.bishop set_ignoreSuppression(true);

	allies = array_add(level.allies, level.dog);
	array_thread(allies, ::super_guy, false);
	safe_activate_trigger_with_targetname("butchdance1");

	guys = array_spawn_targetname_allow_fail("exfil_guys2", true);

	flag_wait("start_finale_truck");
	
	lynx = spawn_vehicles_from_targetname_and_drive("finale_lynx");
	delayThread(3, ::safe_activate_trigger_with_targetname, "butchdance1a");

	flag_wait_or_timeout("finale_lynx_stop", 4);
	
	guys = GetAIArray("axis");
	ai_array_killcount_flag_set(guys, 3, "finale_push1");

	flag_wait_or_timeout("finale_push1", 5);
	flag_set("finale_push1");

	thread handle_final_finale_guys();
	thread handle_finale_drones();
	
	safe_activate_trigger_with_targetname("butchdance2");
	
	
	flag_wait_or_timeout("finale_push2", 7);
	flag_set("finale_push2");
	
	wait 2;
	
	safe_activate_trigger_with_targetname("butchdance3");

	flag_wait("get_in_choppa");
	
		
	allies = level.allies;
//	allies = array_add(allies, level.dog);
	level.dog.ignoreall = true;
	level.dog.ignoreme = true;
	level.dog Hide();
	level.finale_chopper SetVehicleTeam("allies");
	level.finale_chopper.script_team = "allies";
	allies[0].script_startingposition = 0;
	
	level.finale_chopper thread vehicle_load_ai(allies);
	
	flag_wait("flyaway_baddies");
	wait 2;
	
	delayThread(2, ::finale_explosions );
	
	level.dead_finale_trucks = 0;
	lynxs = spawn_vehicles_from_targetname_and_drive("flyaway_lynx");
	
	guys = array_spawn_targetname_allow_fail("exfil_guys4", true);
	array_thread(guys, ::fire_at_chopper, level.finale_chopper, 3,5);
	array_thread(lynxs, ::handle_end_lynxes);
	
	while(level.dead_finale_trucks < 2)
	{
		wait 0.1;
	}
	
	lynxs = spawn_vehicles_from_targetname_and_drive("flyaway_lynx2");
	array_thread(lynxs, ::handle_end_lynxes);
}


handle_end_lynxes()
{
	thread handle_dead_truck();
	riders = self.riders;
	self waittill("unloaded");
	
	array_thread(riders, ::fire_at_chopper, level.finale_chopper, 0.5, 1.5);
}

handle_dead_truck()
{
	self waittill("death");
	level.dead_finale_trucks++;
}
	

fire_at_chopper(who, mintime, maxtime)
{
	if (IsDefined(self) && IsAlive(self))
	{
		self endon("death");
		
		who.ignoreme = false;
		self GetEnemyInfo(who);
		flag_wait("flyaway_baddies");
		wait RandomFloatRange(mintime,maxtime);
		while ( !flag("finale_done") )
		{
			self Shoot(0.05, who.origin);
			wait RandomFloatRange(1,2);
		}
	}
}

handle_butchdance_enemies(guys)
{
	self endon("death");
	
	level waittill("hot_butchdance_action");
		
	self.ignoreme = false;
	wait ( RandomFloatRange(1.5, 2.5) );
		  
	self.accuracy = 0.1;
	self.ignoreall = false;
}

handle_finale_drones()
{
	level endon("death");
	
	spawners = GetEntArray("finale_drone", "targetname");
	
	spawners = array_randomize(spawners);
	
	foreach (spawner in spawners)
	{
		drone = dronespawn(spawner);
		drone.spawner = spawner;
		drone thread handle_drone();
		
		wait RandomFloatRange(0.2, 0.75);
	}
}
	
handle_drone()
{
	self endon( "death" );

//	self thread AI_ragdoll( true );
	
	self waittill( "goal" );
	
	if (!flag("finale_done"))
	{
		drone = dronespawn(self.spawner);
		drone.spawner = self.spawner;
		drone thread handle_drone();
	}
	
	self delete();
}

handle_final_finale_guys()
{
	// keep a some guys around
	level endon("death");
	
	while ( !flag("finale_done") )
	{
		guys = array_spawn_targetname_allow_fail("exfil_guys3", true);
		
		guys = GetAIArray("axis");

		ai_array_killcount_flag_set(guys, int(guys.size/2), "more_finale_guys");
	
		flag_wait("more_finale_guys");
		flag_clear("more_finale_guys");
	}
}

finale_explosions()
{
	sploders = getstructarray("finale_explosion", "targetname");
	
	foreach (fx in sploders)
	{
		PlayFx( level._effect[ "finale_explosion" ], fx.origin);
		wait (randomfloatrange(0.5, 1));
	}
}

finale_sniping()
{
	thread add_dialogue_line("Hesh", "Adam!  Cover us with the remote sniper while we take off.");
	flag_set("start_exfil_sniper");
	wait 0.2;
	level.player notify( "scripted_sniper_dpad");
	
	flag_set("flyaway_baddies");
	
	wait 7;
	
	safe_activate_trigger_with_targetname("butchdance4");
}

finale_vo()
{
	flag_wait("pre_exit_scene");
	thread add_dialogue_line("Merrick", "Gonna be hot as hell out there.");
	wait 1.5;
	thread add_dialogue_line("Merrick", "You're on your own.");
	wait 2;
	safe_activate_trigger_with_targetname("pre_exit2");
	thread add_dialogue_line("Hesh", "You're the Ghosts.");
	wait 2;
	thread add_dialogue_line("Merrick", "Ghosts? Don't get all carried away, kid. 31st Air Recon. Captain Merrick.");
	wait 3;
	thread add_dialogue_line("Hesh", "<pointing at patch> I've never seen this before.");
	wait 3;
	thread add_dialogue_line("Merrick", "That's just something my lady gave me for good luck a long time ago.");
	wait 0.5;
	flag_set("open_finale_doors");
	
/*
	wait 2.5;
	thread add_dialogue_line("Merrick", "Ambush!  Back down!");
//	thread add_dialogue_line("Merrick", "They'll be waiting for us.");
*/
	thread watch_for_end_of_sniping();
	
	wait 1;

	thread nag_player_until_flag("Merrick", "start_butchdance", "Adam, thin 'em out with the remote sniper rifle.", "Use the remote sniper!", "Rook, get on the remote sniper.");
	wait 1;
	thread sniper_hint("start_butchdance", 4);
	flag_set("enable_butchdance");

	level.player waittill("scripted_sniper_dpad");
	flag_set("start_butchdance");
	
//	thread nag_player_until_flag("Merrick", "butchdance_sniping", "On you.", "Whenever you're ready.", "Take a shot!");
	wait 3;
	thread nag_player_until_flag("Merrick", "butchdance_sniping", "Take out those LMGs.", "Whenever you're ready.", "Take a shot!");
		
//	thread add_dialogue_line("Merrick", "NOW!");
	flag_wait("end_of_sniping");
	
	wait 5;
	thread add_dialogue_line("Hesh", "Where the hell did they go!?");
	wait 3;
	flag_wait ("finale_push1");
	
	thread add_dialogue_line("Hesh", "Clear a path to the chopper!");

	
	flag_wait ("finale_push2");
	thread nag_player_until_flag("Hesh", "get_in_choppa", "Get to the choppa!", "Adam! The chopper!", "Adam! Get over here!", "We're leaving!");
	
	flag_wait("finale_done");
	
	add_dialogue_line("Hesh", "We're clear.");
	
}

