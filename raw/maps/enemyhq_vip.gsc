#include maps\_utility;
#include common_scripts\utility;
#include maps\enemyhq_code;
#include maps\_anim;
#include maps\_utility_dogs;
#include maps\ally_attack_dog;

enemyhq_vip_pre_load()
{
	flag_init("start_sniper_vip_breach");
	flag_init("vip_breach_hot");
	flag_init("done_sniping_early");
	flag_init("sniping_done");
	flag_init( "vip_done" );
}


setup_vip()
{
	level.start_point = "vip";
	maps\enemyhq::setup_common();
	
	safe_activate_trigger_with_targetname("vip_allies_set_up");
}

begin_vip()
{
	level.dog set_dog_scripted_mode( level.player );
	autosave_by_name("vip_room");

	thread ally_vo();
	flag_wait("setup_vip_enemies");
	thread animate_vip_enemies();
	thread animate_ally_breach();
	
	// player activates remote sniper
	level.player waittill("scripted_sniper_dpad");
	flag_set("start_sniper_vip_breach");

//	disable_trigger_with_targetname("sniper_use_trigger");
		
	// wait for player to shoot
	level waittill("vip_breach_hot");

	// wait for player to come back from sniper view
	level.player waittill("remote_turret_deactivate");
	flag_set("sniping_done");

	// clean up bad guys (if any are left)
	guys = GetAIArray("axis");
	array_thread(guys, ::die_quietly);
	
	
	// set up "where is he scene
	thread player_back_from_sniping();
	
	
	flag_wait( "vip_done" );
}


animate_vip_enemies()
{
	vol = GetEnt("vip_enemy_volume", "targetname");
	
	spawners = GetEntArray("vip_enemy", "targetname");
	spawners2 = GetEntArray("vip_enemy2", "targetname");
	spawners = array_combine(spawners, spawners2);
		
	guys = [];
	
	foreach (spawner in spawners)
	{
		animname = spawner.script_noteworthy;
		struct = GetStruct(spawner.target, "targetname");
		
		guy = spawner spawn_ai(true);
		
		guy.animname = animname;
		guy.struct = struct;
		guy.allowdeath = true;
		struct thread anim_first_frame_solo(guy, "vip_enemy");
		
		guy thread vip_enemy_interrupt(vol);
		
		guys = array_add(guys, guy);
	}
	
	thread ai_array_killcount_flag_set(guys, guys.size, "done_sniping_early");
	
	// wait for player to activeate sniper rifle
	flag_wait("start_sniper_vip_breach");

	foreach (guy in guys)
	{
		guy.struct thread anim_single_solo(guy, "vip_enemy");
	}
	
	level waittill("vip_breach_hot");
	
	foreach (guy in guys)
	{
		guy notify("go_time");
	}
	
}

vip_enemy_interrupt(vol)
{
	self endon("death");
	
	self waittill_any("death", "damage", "go_time" );
	
	self anim_stopanimscripted();
	self.allowdeath = true;
	self.ignoreme = false;
	self enable_ai_color();
//	self SetGoalVolumeAuto(vol);



	self anim_single_solo(self, "vip_breach_react");
	
	wait ( RandomFloatRange(0.25, 0.5) );
		  
	self.ignoreall = false;
}

animate_ally_breach()
{
	struct = GetStruct("vip_breach1", "targetname");
	
	level waittill("vip_breach_hot");
	
	wait 1;
	
	thread open_vip_doors();
	
	i = 1;
	foreach (ally in level.allies)
	{
		ally.animname = "ally" + string(i);
		struct thread anim_single_solo(ally, "vip_breach");
		i++;
	}
	
	safe_activate_trigger_with_targetname("vip_allies_enter");
	


}

open_vip_doors()
{
	breach_door_left = GetEnt( "vip_door_l", "targetname" );
	breach_door_right = GetEnt( "vip_door_r", "targetname" );

	breach_door_left RotateYaw( 90, 0.2, 0.1, 0.1 );	
	breach_door_left ConnectPaths();
	
	breach_door_right RotateYaw( -90, 0.2, 0.1, 0.1 );
	breach_door_right ConnectPaths();
}

player_back_from_sniping()
{
	thread handle_vip_drones();

	level.dog enable_dog_sniff();


	node = GetNode("vip_hesh_loc", "targetname");
	level.allies[2] teleport_ai(node);
	// anim for george, price and brother walking around: active_patrolwalk_v5
	searchers = make_array(level.allies[0], level.allies[2] );
	array_thread( searchers, ::set_search_walk );

	safe_activate_trigger_with_targetname("vip_allies_search");
	
	spawner = GetEnt("vip_interrogatee", "targetname");
	badguy = spawner spawn_ai(true);
	struct = GetStruct("vip_interrogate", "targetname");
	guys = make_array(level.allies[1], badguy, level.dog);
	level.allies[1].animname = "goodguy";
	level.dog.animname = "dog";
	badguy.animname = "badguy";
	badguy.allowdeath = true;

	struct anim_first_frame(guys, "vip_interrogate");

	flag_wait_or_timeout("start_interrogation_anims", 15);
	flag_set("start_interrogation_anims");

	struct thread anim_single(guys, "vip_interrogate");

	level.dog waittillmatch("single anim", "end");

	level.dog enable_ai_color();
	
	flag_wait("vip_done");

	array_thread(searchers, ::clear_run_anim );

	badguy die();
	
	wait 1;
	
	level.allies[1] anim_stopanimscripted();
}

set_search_walk()
{
	self.animname = "generic";
	self set_run_anim("search_walk", true);
}

handle_vip_drones()
{
	level endon("death");
	
	spawners = GetEntArray("vip_drone", "targetname");
	
	spawners = array_randomize(spawners);
	
	foreach (spawner in spawners)
	{
		spawner spawn_vip_drone();
		spawner delaythread(RandomFloatRange(2,5), ::spawn_vip_drone);
		
		wait RandomFloatRange(0.2, 0.75);
	}
}

spawn_vip_drone()
{
	drone = dronespawn(self);
	drone.spawner = self;
	drone thread handle_vip_drone();
}

handle_vip_drone()
{
	self endon( "death" );

	self waittill( "goal" );
	
	if (!flag("traverse_done"))
	{
		self.spawner spawn_vip_drone();
	}
	
	self delete();
}


ally_vo()
{
	flag_wait("setup_vip_enemies");
	
//	thread add_dialogue_line("Merrick", "This should be where they're holding Bishop.");
//	wait 2;
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_thisshouldbewhere");

//	thread nag_player_until_flag("Merrick", "start_sniper_vip_breach", "Rook, scope it out with the remote sniper.", "Use the remote sniper.", "Get on that remote sniper rifle.");
	thread nag_player_until_flag(level.allies[0], "start_sniper_vip_breach", "enemyhq_mrk_adamscopeitout", "enemyhq_mrk_usetheremotesniper", "enemyhq_mrk_getonthatremote");
	
	wait 1;
	flag_set("activate_vip_sniper");
	thread sniper_hint("start_sniper_vip_breach", 4);
	
	flag_wait("start_sniper_vip_breach");
	wait 2;
//	delaythread(0.5, ::nag_player_until_flag, "Merrick", "sniping_done", "We’ll breach on your shot", "On you.", "Take a shot.", "Any day now.");
	delaythread(0.5, ::nag_player_until_flag, level.player, "vip_breach_hot", "enemyhq_mrk_wellbreachonyour", "enemyhq_mrk_onyou", "enemyhq_mrk_takeashot", "enemyhq_mrk_anydaynow");

	level waittill("vip_breach_hot");
	flag_set("vip_breach_hot");
	
	wait 0.5;
	
//	thread add_dialogue_line("Merrick", "GO GO GO!");
	thread radio_dialog_add_and_go("enemyhq_mrk_gogogo");

	flag_wait("sniping_done");
	
//	thread add_dialogue_line("Merrick", "Bishop has to be close.  Find him.");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_bishophastobe");

	flag_wait("start_interrogation_anims");

	wait 6;
//	thread add_dialogue_line("Keegan", "Where is he!?");
	level.allies[1] thread char_dialog_add_and_go("enemyhq_kgn_whereishe");
	
	wait 3;
	
	safe_activate_trigger_with_targetname ("vip_allies_pre_leave");
	
//	thread add_dialogue_line("Hesh", "Cairo's got his scent.");
	level.allies[2] thread char_dialog_add_and_go("enemyhq_hsh_cairosgothisscent");
	
	wait 2;
	
	level.dog disable_dog_sniff();
//	thread add_dialogue_line("Merrick", "Lets go");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_letsgo");
	
	wait 1;
	
	flag_set("vip_done");
}

