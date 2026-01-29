#include maps\_utility;
#include common_scripts\utility;
#include maps\enemyhq_code;
#include maps\_vehicle;
#include maps\_vehicle_aianim;
#include maps\_vehicle_code;
#include maps\_anim;

enemyhq_atrium_pre_load()
{
	thread check_trigger_flagset("TRIG_advance_allies_wave2L");
	thread check_trigger_flagset("TRIG_advance_allies_wave2R");
	
	thread check_trigger_flagset("TRIG_advance_allies_wave3L");
	thread check_trigger_flagset("TRIG_advance_allies_wave3R");
	
	thread check_trigger_flagset("TRIG_advance_allies_wave4L");
	thread check_trigger_flagset("TRIG_advance_allies_wave4R");
	
	thread check_trigger_flagset("TRIG_advance_allies_wave5L");
	thread check_trigger_flagset("TRIG_advance_allies_wave5R");
	
	thread check_trigger_flagset("TRIG_advance_allies_wave6L");
	thread check_trigger_flagset("TRIG_advance_allies_wave6R");

	
	flag_init("kick_off_atrium_combat");
	//flag_init("FLAG_player_bust_thru_prep");
	flag_init("player_getout_atrium");
	flag_init("FLAG_bust_thru_player_control");
	flag_init("FLAG_bust_thru_prep");
	flag_init("FLAG_player_exit_truck");
	flag_init( "atrium_done" );
	flag_init("FLAG_atrium_wave2");
	flag_init("FLAG_atrium_wave3");
	flag_init("FLAG_atrium_wave4");
	flag_init("FLAG_atrium_wave5");
	flag_init("FLAG_atrium_wave6");
	flag_init("FLAG_atrium_done");
	flag_init("FLAG_bust_thru_prep");
	flag_init("FLAG_ai_final_stand");
}


setup_atrium()
{
	level.start_point = "atrium";
	maps\enemyhq::setup_common();
	
	level.setup_atrium_check = true;
	
	spawn_truck_setup_riders();
	
	flag_set("FLAG_bust_thru_prep");
}

begin_atrium()
{
	thread autosave_now_silent();
	handle_ally_threatbiasgroup();
	thread bust_thru();
	thread bust_thru_prep();
	thread watch_inside_trigger();
	thread watch_outside_trigger();
	
	
	SetIgnoreMeGroup( "dog", "axis" );
	//thread player_getout_atrium();
	thread start_atrium_combat();

	trigger_off("TRIG_player_exit_truck","targetname");
	
	flag_wait( "atrium_done" );
}

spawn_truck_setup_riders()
{
	level.player_truck = spawn_vehicle_from_targetname_and_drive("vehicle_breakthru");
	level.player_truck.dontunloadonend = true;
    veh = level.player_truck;
	
	//level.player_truck thread maps\_vehicle_aianim::guy_enter( level.allies[0] );
	level.allies[1] LinkTo(level.player_truck,"tag_driver");
   	veh thread anim_loop_solo(level.allies[1], "enter_truck_loop","stop_keegan_loop","tag_driver");
	
	level.allies[0] LinkTo(level.player_truck,"tag_detach");
   	veh thread anim_loop_solo(level.allies[0], "enter_truck_loop","stop_baker_loop","tag_detach");
    
	level.allies[2] LinkTo(level.player_truck,"tag_detach");
   	veh thread anim_loop_solo(level.allies[2], "enter_truck_loop","stop_hesh_loop","tag_detach");
    
    level.dog LinkTo(level.player_truck,"tag_dog");
    level.player_truck thread anim_loop_solo(level.dog, "veh_idle","stop_dog_loop","tag_dog");
   
    thread player_enter_truck_atrium_startpoint(level.player_truck);
}


bust_thru_prep()
{
	flag_wait("FLAG_bust_thru_prep");
	
	thread maps\enemyhq_audio::aud_bust_thru();
	thread add_dialogue_line("Merrick","Comin' in hot!");
	
	level.allies[2].animname = "hesh";
	level.allies[1].animname = "keegan";
	level.player_truck thread vehicle_play_guy_anim("bust_thru_prep",level.allies[2], 0, true);
	thread bust_thru_prep_dog();
	
}

bust_thru_prep_dog()
{	
	level.player_truck notify("stop_dog_loop");	
	level.player_truck anim_single_solo(level.dog, "bust_thru_prep","tag_dog");
	level.player_truck anim_loop_solo(level.dog, "veh_idle","stop_dog_loop","tag_dog");
}

bust_thru()
{
	flag_wait("kick_off_atrium_combat");
	level notify("bust_thru");
	flag_clear("FLAG_VO_hang_on_again");
	
	//level.player_truck thread maps\_vehicle_aianim::guy_unload( level.allies[0],1 );
	
	level.allies[0] unlink();
	level.allies[1] unlink();
	level.allies[2] unlink();
//	level.allies[3] unlink();
	level.dog unlink();
	
	scene = getstruct("player_teleport_atrium","targetname");
	spawner = GetEnt( "enemy1_bust_thru", "targetname" );
	guy = spawner spawn_ai( true );
	
	guy setcontents( 0 );
	guy.noragdoll = true;
	guy.nocorpsedelete = true;
	guy.ignoreme = true;
	guy.allowdeath = false;
    guy.health = 1;
    guy.no_pain_sound = true;
    guy.diequietly = true;
    guy.ignoreall = true;
    guy.dontEverShoot = true;
	
	actors = [];
	actors[0] = level.player_truck;
	actors[1] = level.allies[1];
	actors[2] = level.allies[2];
	actors[3] = guy;
	actors[4] = level.dog;
	
	actors[0].animname = "truck";
	actors[1].animname = "keegan";
	actors[2].animname = "hesh";
	actors[3].animname = "generic";
	actors[4].animname = "dog";
	
	scene notify("stop_loop");
	level.player_truck notify("stop_keegan_loop");
	level.player_truck notify("stop_hesh_loop");
	level.player_truck notify("stop_dog_loop");
	
	scene thread anim_single( actors, "bust_thru");
	
	level.dog thread dog_wait_anim_finished();
	
	//level.player_truck thread at_end_anim_freeze_frame( scene );
	thread kill_after_anim(actors[3]);
	
	delayThread(5,::battlechatter_on, "allies" );
	delayThread(5,::battlechatter_on, "axis" );
}

dog_wait_anim_finished()
{
	node1 = getNode("dog_here_post_bust_thru","targetname");
	self waittillmatch("single anim","end");
	self SetGoalNode(node1);
	self waittill("goal");
	flag_wait("FLAG_player_exit_truck");
	self disable_ai_color();
	maps\ally_attack_dog::set_dog_guard_owner( level.player ); 
}

at_end_anim_freeze_frame( scene )
{
	self waittillmatch("single anim","end");
	scene thread anim_last_frame_solo(self,"bust_thru");
}

kill_after_anim(guy)
{
	guy waittillmatch("single anim","end");
	guy kill();
}


start_atrium_combat()
{
	flag_wait("kick_off_atrium_combat");
	
	
	//mess with ally accuracy
	foreach(guy in level.allies)
	{
		guy.old_accuracy = guy.baseaccuracy;
		guy.baseaccuracy = 0.9;		
	}
	
	thread atrium_wave2();
	wave1 = array_spawn_targetname_allow_fail_setthreat_insideaware("atrium_wave_1");
	bust_thru_runners = array_spawn_targetname_allow_fail_setthreat_insideaware("bust_thru_runners");
	
	thread autosave_now_silent();
	activate_trigger_with_targetname("TRIG_advance_allies_wave1");
	thread ai_array_killcount_flag_set(wave1, int(wave1.size - 2), "FLAG_atrium_wave2");
}

atrium_wave2()
{
	flag_wait("FLAG_atrium_wave2");

	
	thread autosave_now_silent();
	thread atrium_wave3();

	
	wave2 = array_spawn_targetname_allow_fail_setthreat_insideaware("atrium_wave_2");
	wave2b = array_spawn_targetname_allow_fail_setthreat_insideaware("atrium_wave_2_b");
	
	
	thread add_dialogue_line("Merrick","Gotta reach Bishop!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_gottareachbishop");
	
	thread ai_array_killcount_flag_set(wave2, int(wave2.size - 3 ), "FLAG_atrium_wave3");
	
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave2L");
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave2R");
}

atrium_wave3()
{
	flag_wait("FLAG_atrium_wave3");
	thread autosave_now_silent();
	thread atrium_wave4();

	wave3 = array_spawn_targetname_allow_fail_setthreat_insideaware("atrium_wave_3");
	wave3b = array_spawn_targetname_allow_fail_setthreat_insideaware("atrium_wave_3_b");
	
	thread ai_array_killcount_flag_set(wave3, int(wave3.size -1), "FLAG_atrium_wave4");
	
	thread retreat_from_vol_to_vol("atrium_wave2_vol_l","atrium_wave3_vol_l", .3, .5);
	thread retreat_from_vol_to_vol("atrium_wave2_vol_r","atrium_wave3_vol_r", .3, .5);
	
	thread add_dialogue_line("Merrick","Keep pushing forward, tangoes falling back!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_keeppushingforwardtangoes");
	
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave3L");
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave3R");
}

atrium_wave4()
{
	flag_wait("FLAG_atrium_wave4");
	
	thread add_dialogue_line("Merrick","Lay it on them! ");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_layitonthem");
	
	//super aggressive allies... enemies move from thier color radius	
	foreach(guy in level.allies)
	{
		guy.fixednodesaferadius = 128;	//default = 64
	}
	
	thread autosave_now_silent();
	//thread atrium_wave5();
	thread atrium_final_stand();
	
	wave4 = array_spawn_targetname_allow_fail_setthreat_insideaware("atrium_wave_4");
	wait 1;
	thread ai_array_killcount_flag_set(wave4, wave4.size, "FLAG_atrium_wave6");

	wait .5;
	
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave4L");	
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave4R");
}



/*
atrium_wave5()
{
	flag_wait("FLAG_atrium_wave5");
	autosave_now_silent();
	thread atrium_final_stand();

	wave5 = array_spawn_targetname_allow_fail_setthreat_insideaware("atrium_wave_5");
	
	//remaining = GetAIArray("axis");
	thread ai_array_killcount_flag_set(wave5, int(wave5.size - 1), "FLAG_atrium_wave6");
	
	
	thread retreat_from_vol_to_vol("atrium_wave3_vol_l","atrium_wave4_vol_l", .3, .5);
	thread retreat_from_vol_to_vol("atrium_wave3_vol_r_up","atrium_wave4_vol_r_up", .3, .5);
	
	wait .5;
	
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave5L");	
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave5R");	
}
*/



atrium_final_stand()
{
	flag_wait("FLAG_atrium_wave6");
	
	thread add_dialogue_line("Merrick","Almost to the target, lets mop up!");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_almosttothetarget");

	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave6L");
	safe_activate_trigger_with_targetname("TRIG_advance_allies_wave6R");

	thread retreat_from_vol_to_vol("atrium_wave3_vol_l","atrium_wave5_vol_l", .3, .5);
	thread retreat_from_vol_to_vol("atrium_wave4_vol_r","atrium_wave5_vol_r", .3, .5);
	
	thread check_atrium_done();
	
	remainingguys = GetAIArray("axis");
	thread ai_array_killcount_flag_set(remainingguys, int(remainingguys.size - 5 ), "FLAG_ai_final_stand");
		
	flag_wait("FLAG_ai_final_stand");
	
	thread retreat_from_vol_to_vol("atrium_wave5_vol_r","atrium_wave5_vol_l", .3, .5);
}

check_atrium_done()
{
	//wait til 3 guys left out of everyone  then move on.
	
	remainingguys = getaiarray("axis");
	thread ai_array_killcount_flag_set(remainingguys, int(remainingguys.size - 2 ), "FLAG_atrium_done");
	thread atrium_done( remainingguys );	
}

atrium_done( remainingguys )
{
	flag_wait("FLAG_atrium_done");
	
	foreach(guy in remainingguys)
	{
		if(IsDefined(guy) && IsAlive(guy))
		{
			guy.ignoreall = true;	
			guy.health = 1;
			guy thread reach_goal_die();
		}
	}

	thread retreat_from_vol_to_vol("atrium_wave5_vol_l","atrium_stair_vol");
	
	thread add_dialogue_line("Merrick","Bishop should be up here... fingers on triggers.");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_bishopshouldbeup");
	
	foreach(guy in level.allies)
	{
		guy.fixednodesaferadius = 64;	//default = 64
	}
	
	level.dog enable_ai_color();
	
	//thread autosave_now_silent();
	flag_set( "atrium_done" );

	wait 1.25;
	
	safe_activate_trigger_with_targetname("TRIG_atrium_done");	
}


reach_goal_die()
{
	self waittill("goal");
	self die();
}

ai_group_killcount_flag_set( ai_group, count, flag_to_set )
{
	

	while(( get_ai_group_sentient_count( ai_group )) > count )
	{
		wait 0.05;
	}
	
	flag_set(flag_to_set);
		
}

check_trigger_flagset(targetname)
{
	trigger = getent(targetname,"targetname");
	
	trigger waittill( "trigger" );

	if ( IsDefined( trigger.script_flag_set ) )
	{
		flag_set( trigger.script_flag_set );
	}
}




array_spawn_targetname_allow_fail_setthreat_insideaware( tospawn )
{
	//Debug code to help get a handle on where too many guys spawn at once.
	/*
	axis = GetAIArray( "axis" );
	start_axis = axis.size;
	spawners = GetEntArray( tospawn, "targetname" );
	spawned = array_spawn_targetname_allow_fail( tospawn);
	IPrintLnBold( "Spawning: " + tospawn+". "+spawned.size+" of "+spawners.size );
	axis = GetAIArray( "axis" );
	end_axis = axis.size;
	
	lost = start_axis + spawners.size- end_axis;
	if(lost > 0)
	{
		if( !IsDefined(level.ttllost ) )
		{
			level.ttllost = 0;
		}
		level.ttllost += lost;
		IPrintLnBold( "LOST:" + lost +" TTL:"+ level.ttllost);
	}
	*/
	spawned = array_spawn_targetname_allow_fail( tospawn);
	
	foreach(spawn in spawned)
	{
		if(IsDefined( spawn ) )
		{
			if( IsDefined( spawn.script_parameters ) && spawn.script_parameters == "atrium_ai_starting_inside" )
			{
				spawn SetThreatBiasGroup( "axis_inside" );
				spawn.inside = 1;
			}
			else
			{
				spawn SetThreatBiasGroup( "axis_outside" );
				spawn.inside = 0;
				
			}
		}
		
	}
	return spawned;
}
	
watch_inside_trigger()
{
	trigger = GetEnt( "atrium_inside_border", "targetname" );
	while(1)
	{
		trigger waittill( "trigger", ent );
		if( IsDefined( ent) )
		{
			//IPrintLnBold( "inside trig by " + ent.classname );
			if(ent.team == "axis" )
			{
				if( ent GetThreatBiasGroup() != "axis_inside" )
				{
					ent SetThreatBiasGroup( "axis_inside" );
					ent.inside = 1;
					
					PokeBiasGroups();
				}
				
			}
			else
			{
				//IPrintLnBold( "inside trig by " + ent.classname );
				if( ent == level.player)
				{
					if( level.atrium_player_outside == 1 )
						setplayerinside();
				}
				else
				{
					if( ent GetThreatBiasGroup() != "ally_inside" )
					{
						ent SetThreatBiasGroup( "ally_inside" );
						PokeBiasGroups();
					}
				}
			}
		}
	}
}

watch_outside_trigger()
{
	trigger = GetEnt( "atrium_outside_border", "targetname" );
	while(1)
	{
		trigger waittill( "trigger", ent );
		//IPrintLnBold( "outside trig by " + ent.classname );
		if( IsDefined( ent ) )
		{
			if(ent.team == "axis" )
			{
				if( ent GetThreatBiasGroup() != "axis_outside" )
				{
					ent SetThreatBiasGroup( "axis_outside" );
					ent.inside = 0;
					
					PokeBiasGroups();
				}
			}
			else
			{
				//IPrintLnBold( "outside trig by " + ent.classname );
				if( ent == level.player )
				{
					if( level.atrium_player_outside == 0)
						setplayeroutside();
				}
				else
				{
					if( ent GetThreatBiasGroup() != "ally_outside" )
					{
						ent SetThreatBiasGroup( "ally_outside" );
						PokeBiasGroups();
					}
				}
			}
		}

	}
}

handle_ally_threatbiasgroup()
{
	// initial groups
	createthreatbiasgroup( "ally_outside");
	createthreatbiasgroup( "ally_inside");
	createthreatbiasgroup( "axis_inside");
	createthreatbiasgroup( "axis_outside");
	
	level.player SetThreatBiasGroup( "ally_inside" );
	level.atrium_player_inside = 1;
	level.atrium_player_outside = 0;
	
	level.allies[0]   SetThreatBiasGroup( "ally_outside" );
	level.allies[1]   SetThreatBiasGroup( "ally_inside" );
	level.allies[2]   SetThreatBiasGroup( "ally_inside" );
//	level.allies[3]   SetThreatBiasGroup( "ally_inside" );

	PokeBiasGroups();
}

PokeBiasGroups()
{
	SetIgnoreMeGroup("ally_inside","axis_outside");
	SetIgnoreMeGroup("axis_outside","ally_inside");
	SetIgnoreMeGroup( "ally_outside",	"axis_inside");
	SetIgnoreMeGroup( "axis_inside",	"ally_outside");
}

setplayerinside()
{
	level.player SetThreatBiasGroup( "ally_inside" );
//	level.red1   SetThreatBiasGroup( "ally_inside" );
//	thread setgroup_maybedead( "blueend1_spawned", level.blue1,"ally_outside");
//	thread setgroup_maybedead( "blueend2_spawned", level.blue2,"ally_outside");
	level.atrium_player_outside = 0;
	
	/*
	if( flag( "disabled_saves_outside" ) )
	{
		flag_set( "can_save" );
		//IPrintLnBold("SAVES ALLOWED");
		
		flag_clear( "disabled_saves_outside" );
	}
	*/
	PokeBiasGroups();

}

setplayeroutside()
{
		
	level.player SetThreatBiasGroup( "ally_outside" );
//	level.red1   SetThreatBiasGroup( "ally_outside" );
//	thread setgroup_maybedead( "blueend1_spawned", level.blue1,"ally_inside");
//	thread setgroup_maybedead( "blueend2_spawned", level.blue2,"ally_inside");
	level.atrium_player_outside = 1;
	PokeBiasGroups();
	
	/*
	//fix for odd bug where you can get a save when you are outside- stop it saving if player goes outside whilst the mortars are active.
	if( flag( "monitor_outside_for_saves" ) && !flag( "rooftop_javs_dead" ) )
	{
		flag_set( "disabled_saves_outside" );
		flag_clear( "can_save" );
		//IPrintLnBold("SAVES NOT HAPPENING");
		
		//thread wait_enable_save();
	}
	*/
}
