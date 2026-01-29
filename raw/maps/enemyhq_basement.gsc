#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\enemyhq_code;
#include animscripts\combat_utility;
#include maps\ally_attack_dog;

enemyhq_basement_pre_load()
{
	flag_init( "basement_combat_done" );
	flag_init( "basement_teargas_done" );
	flag_init( "clubhouse_done" );
	flag_init( "hvt_done" );
	flag_init("slowmo_over");
	
	flag_init("dog_scratching");
	flag_init("basement_guys_dead");
	flag_init("cage_firing");
	flag_init("cage_firing1");
	flag_init("cage_firing2");
	flag_init("tossed_gas");
	flag_init("gassed_out");
	flag_init("fight_over");
	
	flag_init("breach_setup1_ready");
	
	flag_init("to_trophy_room");
	
	flag_init("media_room_clear");

}


// ==============================================================================================================================================


setup_combat()
{
	level.start_point = "basement_combat";
	maps\enemyhq::setup_common();
	
	vision_set_changes("enemyhq_basement",0);
}

begin_combat()
{
	level.dog set_dog_scripted_mode( level.player );
	disable_trigger_with_targetname("cage_guys2_trigger");
	disable_trigger_with_targetname("cage_guys3_trigger");

	guys = GetAIArray("axis");
	array_thread(guys, ::delete_ai);
	
	thread basement_dog_ambush();
	thread basement_ally_movement();
	thread basement_combat_handlers();
	thread combat_vo();
	
	flag_wait("basement_vision");
	vision_set_changes("enemyhq_basement", 4);
	
	wait 1;
	autosave_by_name("basement_combat");

	flag_wait( "basement_combat_done" );
}

combat_vo()
{
	flag_wait("basement_vision");
	wait 2;
//	thread add_dialogue_line("Merrick", "They don't know where we are.");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_theydontknowwhere");
	
	level waittill("kick_off_basement_combat");
	wait 1;
//	thread add_dialogue_line("Keegan", "Now they do.");
	level.allies[1] char_dialog_add_and_go("enemyhq_kgn_nowtheydo");
	
	flag_wait("basement_guys_dead");
	wait 5;
//	thread add_dialogue_line("Merrick", "Quick! Before they move Bishop again.");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_quickbeforetheymove");
}

basement_patrol_guys()
{
	guys = array_spawn_targetname_allow_fail("basement_patroller");
	
	array_thread(guys, ::patrol_notice);
	
	return guys;
}

basement_dog_ambush()
{
	thread basement_dog_kill_anim();
	
	struct2 = GetStruct("doggie_chase2", "targetname");
	guy2 = spawn_targetname("dog_victim2", true);
	
	struct2 thread anim_generic_first_frame(guy2, "dog_flee");
	
	flag_wait("basement_dog_ambush");
	

	level.dog thread play_sound_on_entity( "anml_dog_bark" );
	struct2 anim_generic_run(guy2, "dog_flee");

	level notify("kick_off_basement_combat");
	
	if (IsAlive(guy2))
	{
		guy2 enable_ai_color();
		guy2.ignoreme = false;
		wait 3;
		guy2.ignoreall = false;
	}
}

basement_dog_kill_anim()
{
	struct1 = GetStruct("doggie_chase1", "targetname");
	guy1 = spawn_targetname("dog_victim1", true);
	
	struct1 thread anim_generic_first_frame(guy1, "basement_dog_ambush");
	flag_wait("basement_dog_ambush");

	guy1.animname = "generic";
	guys = make_array(level.dog, guy1);
	
	wait 1;
	
	level.dog thread play_sound_on_entity( "anml_dog_bark" );
	struct1 anim_single(guys, "basement_dog_ambush");
	guy1 die_quietly();

}

patrol_notice()
{
	self.animname = "generic";
	self set_run_anim("combat_jog");
	
//	self waittill_any("reached_path_end", "basement_combat1");
	self AddAIEventListener( "grenade danger" );
	self AddAIEventListener( "projectile_impact" );
	self AddAIEventListener( "bulletwhizby" );
	self AddAIEventListener( "gunshot" );
	self AddAIEventListener( "explode" );

	self waittill_any( "ai_event", "flashbang", "death", "damage");

	flag_set("basement_guys1");
	level notify("kick_off_basement_combat");

	self.ignoreall = false;
	self.ignoreme = false;
	self SetGoalPos(self.origin);
	self enable_ai_color();
	
	reassign_goal_volume(self, "basement_flee_volume");
}

basement_combat_handlers()
{
//	allguys = basement_patrol_guys();
	
	flag_wait_or_timeout("basement_guys1", 6);
/*
 	guys = GetAIArray("axis");
	array_thread(guys, ::set_ignoreme, 0);
//	array_notify(guys, "basement_combat1");
	wait 3;
*/	

	allguys = array_spawn_targetname_allow_fail("basement_guys1");
	
//	allguys = array_combine(allguys, guys);
//	allguys = array_removeDead_or_dying(allguys);
	
	set_flag_on_killcount(allguys, allguys.size-2, "basement_guys_dead");
	
	flag_wait("basement_guys_dead");
	
	// last straggler guy who runs out
	guys = array_spawn_targetname_allow_fail("basement_flee1");
	wait 2;
	level.dog GetEnemyInfo(guys[0]);
	wait 2;
	guys[0].ignoreme = false;
	
	flag_set("basement_combat_done");
}

basement_ally_movement()
{
	flag_wait("basement_guys1");
	wait 1.5;
	safe_activate_trigger_with_targetname("basement_allies1");
	
	flag_wait("basement_guys_dead");
	wait 5;
	safe_activate_trigger_with_targetname("basement_allies2");
}

// ==============================================================================================================================================

setup_teargas()
{
	level.start_point = "basement_teargas";
	maps\enemyhq::setup_common();

	level.dog set_dog_scripted_mode( level.player );

	disable_trigger_with_targetname("cage_guys2_trigger");
	disable_trigger_with_targetname("cage_guys3_trigger");

	safe_activate_trigger_with_targetname("basement_allies3");
	
	vision_set_changes("enemyhq_basement",0);
}

begin_teargas()
{
	thread give_player_teargas();

	thread handle_crawling();

	flag_wait("cage_guys");
	
	autosave_by_name("battingcage");

	thread teargas_vo();

	thread batting_cage_scenario();
	thread media_guys();
	thread mediaroom_gas();
//	thread dog_ambush();
	thread glowstick_scene();
	
	flag_wait( "basement_teargas_done" );
}

batting_cage_scenario()
{
	disable_trigger_with_targetname("battingcage2");
	
	merrick = level.allies[0];
	struct = GetStruct("open_battingcage", "targetname");
	struct2 = GetStruct("open_battingcage2", "targetname");
	
	// just a little peek inside
	struct anim_generic_reach(merrick, "open_battingcage");
	delaythread(0.5, ::battingcage_door_peek);
	delaythread(2.1, ::cage_fake_firing, "cage_firing1");
	delaythread(2.2, ::flag_set, "cage_firing");
	delaythread(3.0, ::flag_set, "cage_firing1");
	guys = array_spawn_targetname_allow_fail("cage_guys1");
	guys[0] GetEnemyInfo(level.player);
	struct anim_generic(merrick, "open_battingcage");
	
	// merrick jumps out of the way
	struct2 thread anim_generic(merrick, "open_battingcage2");

	guyanim = level.scr_anim[ "generic" ][ "open_battingcage2" ];

    while( merrick getanimtime( guyanim ) < 0.71 )
                        wait( 0.05 );

    merrick anim_stopanimscripted();
    merrick enable_ai_color();
	safe_activate_trigger_with_targetname("battingcage0");

	thread handle_gas();
	
	flag_wait("gassed_out");
	
	wait 1;
	array_thread(guys, ::die_quietly);
	// enemies pour out
	door = Getent("basement_door2", "targetname");
	door RotateYaw(90, 2, 0.1, 0.75);
	door ConnectPaths();

	spawners = GetEntArray("cage_guys", "targetname");
	array_thread(spawners, ::spawn_animate_and_get_shot, 800, 1, true);

	// ally opens door
	wait 1;
	
	spawner = GetEnt("cage_guys2a", "targetname");
	guy = spawner spawn_animate_and_get_shot(512, 1,true);

	thread cage_guys2();
	door = Getent("basement_door1", "targetname");
	door RotateYaw(60, 2, 0.1, 0.75);
	door ConnectPaths();

	struct = getStruct("battingcage_enter", "targetname");
	struct anim_generic_run(level.allies[1], "enter_battingcage");

//	array_thread(guys, ::monitor_teargas_lookat, 512, 2);
	thread merrick_shoots_first_guy(guy);
	
	// allies go in
	array_thread(level.allies, ::disable_cqbwalk);
	safe_activate_trigger_with_targetname("battingcage1");
	level.allies[0] enable_ai_color();
	
	wait 1;
	enable_trigger_with_targetname("battingcage2");
	
	// kill the guys who are staggering out of the gas via AI means
	wait 2;
	guys = array_removeDead_or_dying(guys);
	array_thread(guys, ::set_ignoreme, 0);
}

handle_gas()
{
	vol = GetEnt("batting_cage_volume", "script_noteworthy");
	vol waittill("teargas_touched");
	
	flag_set("tossed_gas");
	
	
	vol waittill("teargas_exploded");
	
	flag_set("gassed_out");

	fxpos =	getstructarray("gas_fx_loc", "targetname");
	foreach (fx in fxpos)
	{
		PlayFx( level._effect[ "cage_smoke" ], fx.origin);
	}
}

battingcage_door_peek()
{
	door = Getent("basement_door1", "targetname");
	door RotateYaw(20, 2.5, 0.1, 0.75);
}

merrick_shoots_first_guy(guy)
{
	// switched to keegan
	
	wait 1.5;
	guy.ignoreme = false;
	level.allies[1].ignoreall = false;
	level.allies[1] GetEnemyInfo(guy);
}

cage_guys2()
{
	enable_trigger_with_targetname("cage_guys2_trigger");
	enable_trigger_with_targetname("cage_guys3_trigger");
	
	flag_wait("cage_guys2");
	
	thread cage_guys3();
	
	spawners = GetEntArray("cage_guys2", "targetname");
	array_thread(spawners, ::spawn_animate_and_get_shot, 512, 1, true);
}

cage_guys3()
{
	flag_wait_any("entered_1st_cagedoor", "cage_guys3");

	if ( flag("cage_guys3") )
	{
		spawners = GetEntArray("cage_guys3", "targetname");
		array_thread(spawners, ::spawn_animate_and_get_shot, 512, 1, true);
	}
}

monitor_teargas_lookat(sightdist, killtime)
{
	self endon("death");
	
	spotted = false;
	d2 = sightdist * sightdist;
	dist =  Distance2DSquared(level.player.origin, self.origin);
		
	while ( IsDefined(self) && IsAlive(self) && !spotted )
	{
		if ( dist < d2 && raven_player_can_see_ai(self) )
	    {
	    	spotted = true;
	    }
	    else
	    {
			wait 0.1;
			dist = Distance2DSquared(level.player.origin, self.origin);
	    }
	}
	
	wait killtime;
	
	self.ignoreme = false;
	
	wait 1;
	
	self kill_me_now();
}


cage_fake_firing(flag)
{
	org = GetEnt("battingcage_shoot_from", "targetname");
	targ = GetEnt("battingcage_shoot_at", "targetname");
	
//	flag_wait("start_cage_shooting");
	
	while (!flag(flag))
	{
		// do a burst of bullets
		num = RandomIntRange(30,120);
		for (i=1; i<num; i++)
		{
			start = random_offset(org.origin, 16);
			finish = random_offset(targ.origin, 64);
			MagicBullet("pecheneg", start, finish);
			wait 0.1;
			
			if (flag(flag))
			{
				i = num;
			}
		}
		
		wait RandomFloatRange(0.5, 1.25);
	}
}

random_offset(loc, offset)
{
	new_loc = (loc[0] + RandomFloatRange(-1 * offset, offset), loc[1] + RandomFloatRange(-1 * offset, offset), loc[2] + RandomFloatRange(-1 * offset, offset) );
	return new_loc;
}

give_player_teargas()
{

	// play anims to give the player
	
	level.player.gasmask_on = true;
	foreach (ally in level.allies)
	{
		ally.gasmask_on = true;
	}
	
	level.player TakeWeapon( "flash_grenade" );
	level.player setOffhandSecondaryClass( "smoke" );
	level.player GiveWeapon( "teargas_grenade" );
	level.player GiveMaxAmmo( "teargas_grenade" );
	
//	thread add_dialogue_line("Merrick", "Adam, toss one in there and they'll come to us.");
//	level.allies[0] char_dialog_add_and_go("enemyhq_kgn_adamtosssomegas");
}


teargas_vo()
{
	flag_wait("cage_guys");
	thread add_dialogue_line("Merrick", "Hold up.");  // low key
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_holdup");
	flag_wait("cage_firing");
	thread add_dialogue_line("Merrick", "Shit!");
	delaythread(2, ::cage_fake_firing, "cage_firing2");
	wait 5;
	flag_set("cage_firing2");
	thread add_dialogue_line("Merrick", "Gas masks on!  We'll Flush 'em out!");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_wellflushemout");
	wait 1;
	thread cage_fake_firing("gassed_out");

	gas_mask_on_player_anim();
	
	thread nag_player_until_flag("Merrick", "gassed_out", "Adam, gas 'em!", "Throw some gas in there!", "Gas 'em out, Adam!"); // under fire
	thread teargas_hint();

//	wait 2;
//	thread add_dialogue_line("Merrick", "Take this.");
//	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_takethis");

/*	
	flag_wait("hall_fork");
//	thread add_dialogue_line("Keegan", "Split up.");
	level.allies[1] char_dialog_add_and_go("enemyhq_kgn_letssplitup");
*/

	flag_wait_any("enter_interview_room_above", "enter_interview_room");
	
	if (flag("enter_interview_room_above"))
	{
//		thread add_dialogue_line("Keegan", "Movement around the corner.");
		level.allies[1] char_dialog_add_and_go("enemyhq_kgn_movementaroundthecorner");
//		wait 2;
		thread add_dialogue_line("Keegan", "Gas 'em.");
		level.allies[1] char_dialog_add_and_go("enemyhq_mrk_gasem");
	}
	else
	{
		thread add_dialogue_line("Merrick", "Gas 'em.");
		level.allies[1] char_dialog_add_and_go("enemyhq_mrk_gasem");
	}
/*	
	flag_wait("dog_ambush");
	wait 3;
	thread add_dialogue_line("Keegan", "Good dog.");
*/	
	flag_wait("breach_setup1");
	
	thread dog_scratch_scene();
	flag_wait("dog_scratching");
//	thread add_dialogue_line("Keegan", "This must be where they're holding Bishop.");
	level.allies[1] char_dialog_add_and_go("enemyhq_kgn_thismustbewhere");
//	wait 2.5;
	thread add_dialogue_line("Merrick", "Keegan, Adam: See if there's another entrance.");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_seeiftheresanother");
//	wait 2.5;
//	thread add_dialogue_line("Merrick", "We'll wait here for your signal.");
	level.allies[0] thread char_dialog_add_and_go("enemyhq_mrk_wellwaitherefor");
	flag_set("breach_setup1_ready");
}

dog_scratch_scene()
{
	level.dog set_dog_scripted_mode( level.player );
	// To cancel scripted mode, either set him to a new mode or dog notify( "dog_scripted_end" );
	struct = GetStruct("dog_at_door", "targetname");
	
	struct anim_reach_solo(level.dog, "found_door");
	flag_set("dog_scratching");
	struct anim_single_solo(level.dog, "found_door");
	level.dog maps\_utility_dogs::enable_dog_sniff();
	level.dog enable_ai_color();
}

teargas_hint()
{
	wait 2;
	
	if ( !flag("tossed_gas") )
	{
		thread hint( "[{+smoke}] to throw teargas" );

		flag_wait("tossed_gas");	

		thread hint_fade();
	}
}

spawn_animate_and_get_shot(sightdist, seen_kill_time, nogun)
{
	anime = self.animation;
	timer = -1;
	if ( IsDefined(self.script_parameters) )
	{
		timer = float(self.script_parameters);
	}
	
	guy = spawn_ai();
	guy.allowdeath = true;
	
	if (nogun == true)
	{
		guy gun_remove();
	}
	
	guy thread animate_and_get_shot(sightdist, seen_kill_time, timer, anime);
	
	return guy;
}

animate_and_get_shot(sightdist, seen_kill_time, timer, anime)
{
	guy = self;
	
	guy thread monitor_teargas_lookat(sightdist, seen_kill_time);
	
	guy endon("death");
	
	if (timer > 0)
	{
		thread anim_generic(guy, anime);
		wait (timer-1);
	}
	else
	{
		anim_generic(guy, anime);
	}
	
	guy.ignoreme = false;
	
	wait 1;
	
	guy kill_me_now();
}

kill_me_now()
{
	self die();
}

media_guys()
{
	flag_wait("media_guys");
	thread cqb_time();
	
	autosave_by_name("media_guys");
	
	array_thread(level.allies, ::enable_cqbwalk);
	array_thread(level.allies, ::disable_surprise);

	allguys = array_spawn_targetname_allow_fail("media_guys");

	flag_wait("enter_interview_room");
	
	allguys = array_removeDead_or_dying(allguys);
	array_thread(allguys, ::set_ignoreme, 0);
	
	clip = GetEnt("media_room_lower_door", "targetname");
	clip NotSolid();
	clip ConnectPaths();
	clip Delete();
	
	allguys = array_removeDead_or_dying(allguys);
	array_thread(allguys, ::set_ignoreall, 0);
	
	guys = array_spawn_targetname_allow_fail("media_guys2");

	allguys = array_combine(allguys, guys);

	
	set_flag_on_killcount(allguys, allguys.size, "media_room_clear");
	
	flag_wait("media_room_clear");
	
//	safe_activate_trigger_with_targetname("flee_media_room");
	
	wait 3;
	safe_activate_trigger_with_targetname("exit_interview_room");
	
	flag_set("basement_teargas_done");
	array_thread(level.allies, ::cqb_walk, "off");
}

mediaroom_gas()
{
	flag_wait_any("inside_interview_room", "inside_interview_room_above");

	if (!flag("media_room_clear"))
	{
		foreach (guy in level.allies)
		{
			guy.oldaccuracy = guy.baseaccuracy;
			guy.baseaccuracy = 0.3;
		}
	}
	
	struct = GetStruct("grenade_toss_target", "targetname");
	targetpos = struct.origin;
	
	struct = GetStruct("grenade_toss_lower", "targetname");
	
	if ( !flag("inside_interview_room_above"))
	{
		struct = GetStruct("grenade_toss_upper", "targetname");
	}

	startpos = struct.origin;
	
	grenade = MagicGrenade("teargas_grenade", startpos, targetpos, 1, true);
	grenade thread maps\_teargas::track_teargas();
	
	flag_wait_or_timeout("media_room_clear", 7);
	
	foreach (guy in level.allies)
	{
		guy.baseaccuracy = guy.oldaccuracy;
	}
}

cqb_time()
{
	trig = GetEnt("start_cqb", "targetname");
	
	while ( !flag("breach_setup1_ready") )
	{
		trig waittill("trigger", other);
		if (other != level.dog)
		{
			other cqb_walk("on");
		}
	}
}

dog_ambush()
{
	flag_wait("dog_ambush");
	
	guys = array_spawn_targetname_allow_fail("dog_ambush");
}

glowstick_scene()
{

	struct = GetStruct("light_glowstick", "targetname");

	flag_wait("breach_setup1_ready");
	safe_activate_trigger_with_targetname("ch_door_positions1");
	
	//spawn a anim joint and attach a glowstick model to it for scene.
	prop = spawn_anim_model("glowstick_prop", struct.origin);
	glowstick = spawn_anim_model( "glowstick", struct.origin );
	glowstick linkto( prop , "J_prop_1" );

	guy = level.allies[1];
	guy.animname = "keegan";
	actors = make_array(guy, prop);
	struct anim_reach_solo(guy, "light_glowstick");
	
	struct thread anim_single(actors, "light_glowstick" );

	guyanim = level.scr_anim[ "keegan" ][ "light_glowstick" ];

    while( guy getanimtime( guyanim ) < 0.16 )
                        wait( 0.05 );
    
    guy anim_stopanimscripted();
    prop anim_stopanimscripted();
    
    prop unlink();
    prop linkto(guy, "TAG_STOWED_BACK", (12,0,0), (0,90,0));
    
    guy enable_ai_color();
}

handle_crawling()
{
	trig = GetEnt("dog_debris", "targetname");


	trig waittill("trigger", other);
		
	safe_activate_trigger_with_targetname("dog_debris_colors");
}

watch_crawl_triggers(end_flag, crawl)
{
	while ( !flag(end_flag) )
	{
		self waittill("trigger", other);
		
		if (other != level.dog)
		{
			if (crawl)
			{
				other AllowedStances("prone");
			}
			else
			{
				other AllowedStances("stand", "crouch", "prone");
			}
		}
	}
}

// ==============================================================================================================================================

setup_clubhouse()
{
	level.start_point = "clubhouse_breach";
	maps\enemyhq::setup_common();
	
	safe_activate_trigger_with_targetname("clubhouse_allies0");
	vision_set_changes("enemyhq_basement",0);
	
	prop = spawn_anim_model("glowstick_prop");
	glowstick = spawn_anim_model( "glowstick");
	glowstick linkto( prop , "J_prop_1" );

	guy = level.allies[1];
    prop linkto(guy, "TAG_STOWED_BACK", (12,0,0), (0,90,0));
    thread maps\enemyhq_anim::glowstick_on(prop);
}

begin_clubhouse()
{
	flag_wait("clubhouse_ready");
	delaythread(1, ::autosave_by_name, "clubhouse");
	
	thread ch_vo();
	thread clubhouse_breach();
	
	flag_wait( "clubhouse_done" );
}

clubhouse_breach()
{
	flag_wait ("breach_activate");
	
	disable_trigger_with_targetname("breach_trigger");
	
	
	// smoke fx
	structs = GetStructArray("ch_breach_gas", "targetname");
	foreach (fx in structs)
	{
		PlayFx( level._effect[ "cage_smoke" ], fx.origin);	
	}
//	wait 1;
	
	// player anim + doors
	thread kick_breach_anim("breach_struct_player");
		
	wait 5.5; // foot impacts with door time
	//enemies
	spawners = GetEntArray("CH_guys", "targetname");
	array_thread(spawners, ::spawn_animate_and_get_shot, 256, 5, false);
	
	thread clubhouse_clear();

	wait 0.5;
	
	safe_activate_trigger_with_targetname("breach_colors");
	SetSlowMotion(1.0, 0.3, 0.2);
	
	//doors
//	thread kick_breach_door_anim("clubhouse_door3", "clubhouse_door2");
	
	// near allies
	thread near_allies_breach();
	thread ch_dog_breach();
	
	// far allies
	far_allies_door = GetEnt("clubhouse_door1", "targetname");
	far_allies_door RotateYaw( 90, 0.2, 0.1, 0.1 );	
	far_allies_door ConnectPaths();

	far_allies_struct = GetStruct("breach_struct", "targetname");
	
	level.allies[0].animname = "ally1";
	level.allies[2].animname = "ally3";
	far_allies_struct thread anim_single([ level.allies[0], level.allies[2] ], "ch_breach");

	
	// 4 seconds of slow mo
	wait 4;
	// end slowmo
	SetSlowMotion(0.3, 1.0, 1.0);
	
	// make allies not running super fast.. make them looking around
	array_thread(level.allies, maps\enemyhq_vip::set_search_walk );
	wait 1;
	flag_set( "slowmo_over" );

	
	flag_wait("ch_stop_searching");

	array_thread(level.allies, ::clear_run_anim );

}

clubhouse_clear()
{
	wait 0.1;
	
	waittill_aigroupcleared("ch_guys");
	flag_wait( "slowmo_over" );
	
	level.dog maps\_utility_dogs::enable_dog_sniff();
	
//	thread add_dialogue_line("Merrick", "Bishop's here somewhere.  Find him.");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_bishopsheresomewherefind");
	
	safe_activate_trigger_with_targetname("post_breach_colors");
	flag_set("clubhouse_done");
}

ch_vo()
{
	flag_wait("clubhouse_ready");
	
//	thread add_dialogue_line("Keegan", "We found another door.  No guards.");
	level.allies[1] char_dialog_add_and_go("enemyhq_kgn_wefoundanotherdoor");
//	wait 2;
//	thread add_dialogue_line("Baker", "We'll wait for your go.");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_wellwaitforyour");
	wait 2;
//	thread nag_player_until_flag("Keegan", "breach_activate", "Adam, toss some gas in", "Get over to the door.", "Adam, gas 'em.");
	thread nag_player_until_flag(level.allies[1], "breach_activate", "enemyhq_kgn_adamtosssomegas", "enemyhq_kgn_getovertothe", "enemyhq_kgn_adamgasem");
	
	flag_wait ("breach_activate");
	wait 1;
//	thread add_dialogue_line("Keegan", "Breach in 5...");
	level.allies[1] thread char_dialog_add_and_go("enemyhq_kgn_breachin5");

}

ch_dog_breach()
{
	struct = GetStruct("breach_struct3", "targetname");
	spawner = GetEnt("CH_dog_guy", "targetname");

	guy = spawner spawn_ai(true);
	guy.animname = "generic";
	guy gun_remove();
	level.dog.animname = "dog";
	
	guys =  make_array(guy, level.dog);
	
	struct anim_single(guys, "dog_breach");
	guy die_quietly();
	level.dog enable_ai_color();
}

near_allies_breach()
{
	wait 0.5;
	near_allies_struct = GetStruct("breach_struct2", "targetname");
	level.allies[1].animname = "ally2";
//	level.allies[3].animname = "ally4";
	near_allies_struct thread anim_single([ level.allies[1] ], "ch_breach");
}

kick_breach_anim( anim_struct_targetname )
{
	struct = getstruct( anim_struct_targetname, "targetname" );

	door_prop = spawn_anim_model("clubhouse_doors");

	level.breach_player_rig = spawn_anim_model( "player_rig" );
	level.breach_player_rig hide();
	
	level.breach_player_legs = spawn_anim_model( "player_legs" );
	level.breach_player_legs hide();

	struct anim_first_frame( [ level.breach_player_rig, level.breach_player_legs, door_prop], "ch_breach" );

	door_l = GetEnt("clubhouse_door2", "targetname");
	door_r = GetEnt("clubhouse_door3", "targetname");
	door_l linkto( door_prop , "J_prop_1" );
	door_r linkto( door_prop , "J_prop_2" );
	
	
	SetUpPlayerForAnimations();
	
	level.player PlayerLinkToBlend( level.breach_player_rig, "tag_player", 0.4, 0.2, 0.2 );
	lerp_time = 0.4;
	wait lerp_time;
	
	level.breach_player_rig Show();
	level.breach_player_legs Show();
	
	struct anim_single( [level.breach_player_rig, level.breach_player_legs, door_prop], "ch_breach");
	
	//clean up
	level.player Unlink();
	SetUpPlayerForGamePlay();
	level.breach_player_rig Delete();
	level.breach_player_legs Delete();
	
	level notify( "kick_breach_anim_done" );
}

kick_breach_door_anim( rdoor, ldoor )
{
	breach_door_left = GetEnt( ldoor, "targetname" );
	breach_door_right = GetEnt( rdoor, "targetname" );

	breach_door_left RotateYaw( 120, 0.2, 0.1, 0.1 );	
	breach_door_left ConnectPaths();
	
	breach_door_right RotateYaw( -120, 0.2, 0.1, 0.1 );
	breach_door_right ConnectPaths();
}

/*
spawn_breach_enemies( enemy_targetname )
{
	if( enemy_targetname != "" || !IsDefined( enemy_targetname))
	{
		breach_enemy_spawners = GetEntArray( enemy_targetname, "targetname" );
		
		array_thread( breach_enemy_spawners, ::add_spawn_function, ::track_enemy_status );
		array_thread( breach_enemy_spawners, ::add_spawn_function, ::delay_shooting );
		array_thread( breach_enemy_spawners, ::add_spawn_function, ::play_custom_animation );
		array_thread( breach_enemy_spawners, ::add_spawn_function, ::low_health_during_breach );
		
		foreach ( breach_enemy_spawner in breach_enemy_spawners )
		{
			// spawn enemies for same breach group
			if ( breach_enemy_spawner.script_slowmo_breach == self.script_slowmo_breach )
			{
				breach_enemy_spawner StalingradSpawn();
			}
		}
   }
}
*/

// ==============================================================================================================================================

setup_hvt()
{
	level.start_point = "hvt_rescue";
	maps\enemyhq::setup_common();
	
	vision_set_changes("enemyhq_basement",0);
	safe_activate_trigger_with_targetname("to_hvt");
	flag_set("hvt_done");
}

begin_hvt()
{
	autosave_by_name("hvt_rescue");

	thread vip_vo();
//	thread hvt_fight();
	thread hvt_find();
	
	thread trophy_room();
	
	
	flag_wait( "hvt_done" );
}

hvt_find()
{
	thread hvt_dog_bark();
	
	flag_wait("start_hvt_fight");
	struct = GetStruct("hvt_find_struct", "targetname");

	spawner = GetEnt("bishop", "targetname");
	bishop = spawner spawn_ai();
	bishop gun_remove();
	bishop.animname = "bishop";
	level.bishop = bishop;
	
	struct thread anim_loop_solo(bishop, "hvt_loop", "stop_loop");
	
	flag_wait("fight_over");

	merrick = level.allies[0];
	merrick.animname = "merrick";
	struct anim_reach_solo(merrick, "hvt_pickup");
	guys = make_array(merrick, bishop);
	struct notify("stop_loop");
	struct anim_single(guys, "hvt_pickup");
	
	merrick carry_bishop();
	merrick enable_ai_color();
	flag_set("to_trophy_room");
}

hvt_dog_bark()
{
	flag_wait("start_hvt_fight");
	wait 2;
	while ( !flag("start_hvt_find") )
	{
		level.dog dog_force_talk();
		wait randomfloatrange(0.5, 1.5);
	}
}


hvt_fight()
{
	struct = GetStruct("hvt_rescue_struct", "targetname");

	spawner = GetEnt("bishop", "targetname");
	bishop = spawner spawn_ai(true, true);
	bishop.animname = "bishop";
	level.bishop = bishop;
	level.bishop make_hero();
	
	spawner = Getent("fight_guy", "targetname");
	guy = spawner spawn_ai(true);
	guy.animname = "generic";
	guy.allowdeath = true;
	
	guys = make_array(bishop, guy);
	struct anim_first_frame(guys, "hvt_fight");
	
	
	flag_wait("start_hvt_fight");
	struct thread anim_single(guys, "hvt_fight");
	
    wait 0.05;
    
	bishop SetAnimTime( bishop getanim("hvt_fight"), 0.166);
	guy SetAnimTime( guy getanim("hvt_fight"), 0.166);
	
	delayThread(3, ::safe_activate_trigger_with_targetname, "post_rescue");
	
	guy waittillmatch("single anim", "end");
	guy.no_pain_sound = true;
    guy.diequietly = true;
    guy.allowdeath = false;
    guy.noragdoll = true;
	guy die();
	
	flag_set("fight_over");
}

trophy_room()
{
	flag_wait("start_trophy_room");
	// play anims here	
}

vip_vo()
{
	flag_wait("start_hvt_find");
	thread add_dialogue_line("Old Boy", "Var...");
	wait 3;
	thread add_dialogue_line("Merrick", "Help me! Now--!!");
	wait 1;
	flag_set("fight_over");
	wait 2;
	thread add_dialogue_line("Old Boy", "Vargas...");

	
/*	
	flag_wait("fight_over");
	
	thread add_dialogue_line("Merrick", "Hold your fire! It's us!");
	wait 3;
	thread add_dialogue_line("Bishop", "About time. I was just about to come looking for you.");
	wait 3;
	thread add_dialogue_line("Merrick", "Lets go.");
	wait 2;
	flag_set("to_trophy_room");
*/

	flag_wait("start_trophy_room");

	thread add_dialogue_line("Merrick", "It's Vargas.");
	wait 2;
	thread add_dialogue_line("Keegan", "Vargas?  He's alive?" );
	wait 1;
	thread add_dialogue_line("Keegan", "Look at this.");
	wait 2;
	thread add_dialogue_line("Merrick", "It's a 'kill list.'");
	wait 2;
	thread add_dialogue_line("Keegan", "They got Reaper and Hobo, too.");
	wait 3;
/*	thread add_dialogue_line("Merrick", "Invasion plans.  They're headed for L.A.");
	wait 3;
	thread add_dialogue_line("Keegan", "That's not all.");
	wait 2;
	thread add_dialogue_line("Merrick", "What else?");
	wait 2;
	thread add_dialogue_line("Bishop", "They're targeting ghost squad.");
	wait 3;
*/
//	thread add_dialogue_line("Radio", "Los enemigos están acorralados en el vestuario. Obtenga ellos.");
	radio_dialog_add_and_go("enemyhq_saf1_theenemiesarecornered");
//	wait 2;
//	thread add_dialogue_line("Merrick", "They're coming in.  We have to go. NOW.");
	level.allies[0] char_dialog_add_and_go("enemyhq_mrk_theyrecominginwe");

	safe_activate_trigger_with_targetname("pre_exit");
	
	flag_set("hvt_done");
}

breach_gun_up(actor)
{
	level.player PlayerLinkTo( level.breach_player_rig, "tag_player", 1,70,70,70,70 );	
	level.player enableWeapons();
}
	
	

