#include maps\_utility;
#include common_scripts\utility;
#include maps\enemyhq_code;
#include maps\_utility_dogs;


enemyhq_traverse_pre_load()
{
	flag_init("start_sniper_rpg_ambush");
	flag_init("ambush1_dead");
	flag_init("ambush2_dead");
	flag_init( "traverse_done" );
}


setup_traverse()
{
	level.start_point = "traverse";
	maps\enemyhq::setup_common();
}

begin_traverse()
{
	flag_clear("done_sniping_early");
	autosave_by_name("traverse");
	safe_activate_trigger_with_targetname("traversal_allies1");
										  
	thread handle_rpg_ambush();
	thread turn_off_sniping();
	
	flag_wait("start_rpg_ambush");
	
//RYAN: I am fixing up colors and noticed this. 

// I'm not sure exactly what you are doing, but it will probably  fight with the dog control unless you do it the dog friendly way- see the comments at the top of ally_attack_dog.gsc
//but you either want to lock control and / or put him in scripted mode where he won't try and do anything himself.
	level.dog disable_ai_color();
	level.dog SetGoalPos(level.dog.origin);
	wait 0.2;
	level.dog disable_dog_sniff();
	wait 0.2;
	level.dog enable_ai_color();
	
	flag_wait("to_basement");
	level.createRpgRepulsors = false;
	safe_activate_trigger_with_targetname("traversal_allies2");

	flag_wait("final_rpg_ambush");
	safe_activate_trigger_with_targetname("basement_allies0");
	
	flag_wait( "traverse_done" );
	level.createRpgRepulsors = true;
	level.dog disable_dog_sniff();
	level notify("cancel_rpg");
}


handle_rpg_ambush()
{
	level endon("cancel_rpg");

	starts = getstructarray("rpg_origin", "targetname");
	targs = getstructarray("rpg_targ", "targetname");

	flag_wait("start_rpg_ambush");

	thread fudge_ally_accuracy();
	
	thread fire_fake_rpgs(starts, targs);
	
	guys = array_spawn_targetname_allow_fail("rpg_ambush_guys", true);
	array_thread(guys, ::rpg_ambushers);
	
	thread ai_array_killcount_flag_set(guys, guys.size, "ambush1_dead");

	wait 1;
//	thread add_dialogue_line("Keegan", "Ambush!");
	level.allies[1] char_dialog_add_and_go("enemyhq_kgn_ambush");
//	wait 1;
	
	thread handle_rpg_sniper();
	thread handle_skip_rpg_sniping();
	flag_set("start_rpg_kibble");
	
	wait 1;
//	thread add_dialogue_line("Merrick", "Rook, use the remote sniper to clear those RPGs");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_adamusetheremote");
	
	thread sniper_hint("start_sniper_rpg_ambush", 4);
	
	flag_wait("ambush1_dead");
	if (flag("start_sniper_rpg_ambush"))
	{
		// now wait for all the extra guys who have been spawned to be dead
		flag_wait("ambush2_dead");
	}
	flag_set("done_sniping_early");
	
	wait 2;	
//	thread add_dialogue_line("Merrick", "All clear. Move!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_allclearmove");
	flag_set("to_basement");

//	wait 1;

}

rpg_ambushers()
{
	self endon( "death" );
	
	self GetEnemyInfo(level.player);
	
	max_ammo = 1;
	
	for ( ; ; )
	{
	    if ( IsDefined( self.a.rockets ) )
	    	self.a.rockets  = max_ammo;
		wait 0.05;
	}
}


fudge_ally_accuracy()
{
	foreach (guy in level.allies)
	{
		guy.oldaccuracy = guy.baseaccuracy;
		guy set_baseaccuracy(0.01);
	}
	
	flag_wait("to_basement");
	
	foreach (guy in level.allies)
	{
		guy set_baseaccuracy(guy.oldaccuracy);
	}
}

handle_skip_rpg_sniping()
{
	flag_wait("to_basement");
	
	if ( !flag("start_sniper_rpg_ambush") && !flag("ambush1_dead") )
	{
		// player running ahead without sniping or killing enemies
		
		// fire more rpgs for good measure
		starts = getstructarray("rpg_origin", "targetname");
		targs = getstructarray("rpg_targ2", "targetname");
		thread fire_fake_rpgs(starts, targs);
	
		// fire more rpgs for good measure
		flag_wait("final_rpg_ambush");
		if ( !flag("start_sniper_rpg_ambush") && !flag("ambush1_dead") )
		{
			targs = getstructarray("rpg_targ3", "targetname");
			thread fire_fake_rpgs(starts, targs);
		}
	}
}

turn_off_sniping()
{
	flag_wait_any("traverse_done", "done_sniping_early");
	
	if ( !flag("start_sniper_rpg_ambush") )
	{
		//disable sniping
		level.player notify( "stop_watching_remote_sniper");
		
/// TEMP TODO FIXME TAKE THESE 2 LINES OUT ONCE ABOVE NOTIFY IS HOOKED UP
		level.player setWeaponHudIconOverride( "actionslot1", "none" );
		level.player NotifyOnPlayerCommand( "", "+actionslot 1" ); // Only ever triggered by code now.

		// cancel hints
		flag_set("start_sniper_rpg_ambush");
	
	    if ( !flag("done_sniping_early") )
	    {
	    	// kill rpg snipers
	    	guys = GetEntArray("rpg_ambusher", "script_noteworthy");
	    	array_thread(guys, ::die_quietly);
	    }
	}
}

handle_rpg_sniper()
{	
	level endon("cancel_rpg");

	level.player waittill("scripted_sniper_dpad");
	flag_set("start_sniper_rpg_ambush");
	
	guys = array_spawn_targetname_allow_fail("rpg_ambush_guys2", true);
	array_thread(guys, ::rpg_ambushers);
	thread ai_array_killcount_flag_set(guys, guys.size, "ambush2_dead");
}

fire_fake_rpgs(starts, targs)
{
	for (i = 0; i < starts.size; i++)
	{
		MagicBullet("rpg", starts[i].origin, targs[i].origin);
		
		wait RandomFloatRange(0.5, 1);
	}
}


