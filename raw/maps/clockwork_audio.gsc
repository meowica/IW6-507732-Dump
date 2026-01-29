#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;
#include maps\clockwork_code;
#include maps\_utility_code;
#include maps\_audio_code;

//format for calling functions in audio script:
//thread maps\clockwork_audio::function_name();

main()
{
	thread aud_init_flags();
	thread aud_init_globals();
	thread time_synchronizer();
	thread aud_init_animation_sounds();
	thread aud_gear_sounds();
	
	/#
	thread rvn_music_dvar_thread();
	#/
	
	setdvarifuninitialized( "cg_foliagesnd_alias", "clkw_foot_foliage_player" );
}

aud_init_flags()
{
	flag_init("aud_woods_oneshots");
	flag_init("aud_ambush_done");
	flag_init("aud_lights_out_music_started");
	flag_init("aud_stop_music_during_thermite");
	
	flag_init("aud_alarms_on");
	flag_init("aud_alarms_off");
	
	flag_init("aud_stop_interior_combat_pa");
	flag_init("aud_stop_vault_water");
	flag_init("aud_stop_fan_sound");
	flag_init("aud_defend_started");
	flag_init("aud_defend_combat_started");
	flag_init("aud_tick");
	flag_init("aud_fade_out");
	flag_init("aud_pre_lookout");
	
	//chase amb
	flag_init("aud_chase_interior");
	flag_init("aud_baker_getin");
	flag_init("aud_cypher_getin");
	flag_init("aud_keegan_getin");
	flag_init("aud_kill_idle");
	flag_init("chase_punch_it");
	flag_init("chase_garage_pre_exit_skid");
	flag_init("chase_garage_exit");
	flag_init("chase_crossroad");
	flag_init("chase_enter_ravine");
	flag_init("chase_enter_tunnel");
	flag_init("chase_exit_tunnel");
	flag_init("chase_under_bridge_1");
	flag_init("chase_sharp_turn");	
	flag_init("chase_under_bridge_2");
	flag_init("chase_under_bridge_3");
	flag_init("chase_enter_chasm");
	flag_init("chase_tight_spot");
	flag_init("chase_under_bridge_4");
	flag_init("chase_sub_comes_up");
	
	//chase ai vehicle sounds
	flag_init("aud_land_roof_playing");
	flag_init("aud_land_pileup_playing");
	flag_init("aud_pileup_playing");
	flag_init("aud_land_tires_big_playing");
	flag_init("aud_land_tires_small_playing");
	flag_init("aud_collision_playing");
	flag_init("aud_leftground_playing");
	flag_init("aud_start_pileup");
}

aud_init_globals()
{	
	level.bDriverKilled = false;
	level.bDoorBreakFoleyPlayed = false;
	level.aud_last_time = 0;
	level.bDrillOn = false;
	level.aud_charge_set = 0;
	level.bSnowmobilesStarted = false;
	level.pileupcounter = 0;
	level.bCrashMix = false;
	level.crashTimer = 0;
	level.pileupsequence = 1;
	level.aud_drillholenumber = 0;
	level.area1_ents = [];
	level.bCqb_pa_playing = false;
	level.bDefendDoorExplosionPlaying = false;
}

aud_init_animation_sounds()
{
	wait(0.1);
	//ambush
	anim.notetracks[ "frnt_l_open" ] = ::ambush_jeep_latch_open_lf;
	anim.notetracks[ "frnt_l_close" ] = ::ambush_jeep_latch_close_lf;
	anim.notetracks[ "frnt_r_open" ] = ::ambush_jeep_latch_open_rf;
	anim.notetracks[ "frnt_r_close" ] = ::ambush_jeep_latch_close_rf;
	anim.notetracks[ "rear_r_open" ] = ::ambush_jeep_latch_open_rr;
	anim.notetracks[ "rear_r_close" ] = ::ambush_jeep_latch_close_rr;
	
	//vault
	anim.notetracks[ "drill_get" ] = ::vault_keegan_drill_get;
	anim.notetracks[ "drill_set" ] = ::vault_keegan_drill_set;
	anim.notetracks[ "charge_set" ] = ::vault_keegan_charge_set;
		
	//exfil
	/*
	anim.notetracks[ "frontl_door_open_begin" ] = ::exfil_jeep_latch_open_lf;
	anim.notetracks[ "frontl_door_shut" ] = ::exfil_jeep_latch_close_lf;
	anim.notetracks[ "frontr_door_shut" ] = ::exfil_jeep_latch_open_rf;
	anim.notetracks[ "frontr_door_open_begin" ] = ::exfil_jeep_latch_close_rf;
	anim.notetracks[ "backl_door_open_begin" ] = ::exfil_jeep_latch_open_lr;
	anim.notetracks[ "backl_door_shut" ] = ::exfil_jeep_latch_close_lr;
	*/
}

aud_gear_sounds()
{
	allies = getaiarray( "allies" );
	foreach ( ally in allies )
	{
		ally SetClothType( "cloth type" );
	}
}

//checkpoints
//checkpoint_intro2()
//{
//}

checkpoint_start_ambush()
{	
	wait(0.05);
	thread pre_ambush();
}

checkpoint_interior()
{
	wait(0.05);
	//music_play("clkw_interior_start_cp");
	thread security_amb();
}

checkpoint_interior_vault_scene()
{
	wait(0.05);
	level.player SetClientTriggerAudioZone( "power_out" );
	thread pre_thermite_amb_cp();
	//thread rvn_add_mix("electrical_power_off");
}

checkpoint_interior_combat()
{
	wait(0.05);
	level.player playsound ("clkw_scn_power_up");
	thread vault_water();
	thread pa_announcements_interior_combat();
	thread alarms_1();
	thread door_debris_l();
	thread door_debris_r();
}

checkpoint_interior_cqb()
{
	wait(0.05);
	thread vault_water();
	thread alarms_1();
}

checkpoint_defend()
{
	wait(0.05);
	thread alarms_2();
}

checkpoint_chaos()
{
}

checkpoint_exfil()
{
	wait(0.05);
	thread alarms_3();
	thread exfil_keegan_and_cypher_enter_jeep();
	thread exfil_baker_enter_jeep();
	wait(3);
	thread pa_announcements_chaos();
}

checkpoint_tank()
{
	wait(0.05);
	thread chase_music();
	//thread pileupcounter_test();
	flag_set("aud_start_pileup");
	thread chase_amb_enter_tunnel();
	thread chase_amb_exit_tunnel();
	thread chase_amb_under_bridge_1();
	thread chase_amb_sharp_turn();
	thread chase_amb_under_bridge_2();
	thread chase_amb_under_bridge_3();
	thread chase_amb_enter_chasm();
	thread chase_amb_tight_spot();
	thread chase_amb_under_bridge_4();
	thread chase_amb_sub_comes_up();
}

checkpoint_bridge()
{
	wait(0.05);
	thread chase_music();
	flag_set("aud_start_pileup");
	thread chase_amb_under_bridge_1();
	thread chase_amb_sharp_turn();
	thread chase_amb_under_bridge_2();
	thread chase_amb_under_bridge_3();
	thread chase_amb_enter_chasm();
	thread chase_amb_tight_spot();
	thread chase_amb_under_bridge_4();
	thread chase_amb_sub_comes_up();
}

checkpoint_cave()
{
	wait(0.05);
	thread chase_music();
	flag_set("aud_start_pileup");
	thread chase_amb_under_bridge_2();
	thread chase_amb_under_bridge_3();
	thread chase_amb_enter_chasm();
	thread chase_amb_tight_spot();
	thread chase_amb_under_bridge_4();
	thread chase_amb_sub_comes_up();
}

//checkpoint_sub()
//{
//	wait(0.05);
//	thread chase_music();
//	flag_set("aud_start_pileup");
//	thread chase_amb_under_bridge_4();
//	thread chase_amb_sub_comes_up();
//}

//functions

time_synchronizer()
{
  while(1)
  {
     newTime =  GetTime();
     if (newTime - level.aud_last_time > 950)
     {
     	flag_set("aud_tick");
      	level.aud_last_time = (newTime);
     }
     wait(0.05);
     flag_clear("aud_tick");
  }
}

intro_black()
{
	//music_play("clkw_intro_start");

	//thread rvn_mix_oneshot( "intro_black", 0, 20.6, 3 );
	thread intro_gear();
	thread intro_gusts1();
	thread intro_mask();
	thread intro_headlamp_smash();
	thread woods_oneshots();
	//wait(2);
	//level.player playsound("clkw_scn_intro_gear");
}

intro_gear()
{
	wait(3);
	play_sound_in_space("clkw_scn_intro_gear", (-31930, 9037, 3527));	
}

intro_gusts1()
{	
	wait(1.2);
	level.player playsound("clkw_amb_intro_gusts_lr");	
}

intro_watch()
{
	level.player playsound("clkw_scn_intro_whoosh");
	wait(2);
	level.player playsound("clkw_scn_clock_tick");
}

intro_mask()
{
	wait(5.1);
	level.player playsound("clkw_scn_intro_mask");
}

intro_headlamp_smash()
{
	//flag_wait("flag_intro_baker_exit");
	wait(10.6);
	play_sound_in_space("clkw_scn_intro_smash_headlamp", (-31819, 8972, 3514));
}


woods_oneshots()
{
	flag_wait("aud_woods_oneshots");
	wait(1.5);
	thread play_sound_in_space("clkw_distant_wolf", (-34996, 10916, 4220));
}

jeeps_by()
{
	thread jeep1_by();
	wait(.75);
	thread jeep2_by();
}

jeep1_by()
{
		snd = Spawn( "script_origin",(-33425, 10931, 3586));
		dst1 = (-34456, 8972, 3586);
		dst2 = (-35421, 8299, 3586);
		dst3 = (-37562, 9396, 3586);

		snd playsound("clkw_scn_jeep1_by", "sounddone");
		snd MoveTo(dst1, 5);
		wait(5);
		snd MoveTo(dst2, 3.0);
		wait(3);
		snd MoveTo(dst3, 4.0);
		snd waittill("sounddone");
		snd delete();
}

jeep2_by()
{
		snd = Spawn( "script_origin",(-33753, 10221, 3586));
		dst1 = (-34456, 8972, 3586);
		dst2 = (-35421, 8299, 3586);
		dst3 = (-37562, 9396, 3586);

		snd playsound("clkw_scn_jeep2_by", "sounddone");
		snd MoveTo(dst1, 5.5);
		wait(5.5);
		snd MoveTo(dst2, 3.0);
		wait(3);
		snd MoveTo(dst3, 4.0);
		snd waittill("sounddone");
		snd delete();
}

pre_ambush()
{
	//thread intro_radio();
}

//intro_radio()
//{
//		wait(5);
//		play_sound_in_space("clockwork_ss1_checkpoint4", (-38268, 9294, 3537));
//		wait(0.7);
//		play_sound_in_space("clockwork_ss2_allnormal", (-38268, 9294, 3537));
//		wait(0.8);
//		play_sound_in_space("clockwork_ss2_weather", (-38268, 9294, 3537));
//		wait(0.4);
//		play_sound_in_space("clockwork_ss1_colder", (-38268, 9294, 3537));
//		wait(0.9);
//		play_sound_in_space("clockwork_ss2_great", (-38268, 9294, 3537));
//		wait(2);
//		play_sound_in_space("clockwork_ss2_location", (-38268, 9294, 3537));
//		wait(0.6);
//		play_sound_in_space("clockwork_ss1_maingate", (-38268, 9294, 3537));
//		wait(2);
//		play_sound_in_space("clockwork_ss3_headquarters", (-38268, 9294, 3537));
//		wait(0.7);
//		play_sound_in_space("clockwork_ss1_goahead", (-38268, 9294, 3537));
//		wait(0.6);
//
//		flag_wait("aud_ambush_done");
//		
//		play_sound_in_space("clockwork_ss3_urgentmatter", (-38268, 9294, 3537));
//		wait(1);
//		play_sound_in_space("clockwork_ss1_onmyway", (-38268, 9294, 3537));			
//}

player_drag_body()
{
	wait(0.5);
	level.player playsound("clkw_scn_player_drag_body");
}

foley_pre_ambush()
{
	thread keegan_drag_body();
	wait(2);
	//toss
	thread play_sound_in_space("clkw_scn_bag_throw", (-37668, 9088, 3563));
	wait(.5);
	thread play_sound_in_space("clkw_scn_bag_catch", (-37719, 9139, 3551));	
	wait(12.7);
	//drop in bushes
	thread play_sound_in_space("clkw_scn_bag_drop", (-38361, 9684, 3501));	
	wait(2.4);
	thread play_sound_in_space("clkw_scn_bag_drop", (-38331, 9708, 3501));
}


foley_post_ambush()
{
	//place bags in back of jeep 
	wait(7.1);
	thread play_sound_in_space("clkw_scn_bag_drop", (-38240, 9596, 3545));
	wait(2.3);
	thread play_sound_in_space("clkw_scn_bag_drop", (-38240, 9596, 3545));
	wait(2);
	//bag!
	thread play_sound_in_space("clkw_scn_bag_throw", (-38392, 9594, 3551));
	wait(0.5);
	thread play_sound_in_space("clkw_scn_bag_catch", (-38330, 9620, 3547));
	wait(1.5);
	//place bag in back of jeep 
	thread play_sound_in_space("clkw_scn_bag_drop", (-38240, 9596, 3545));
}

keegan_drag_body()
{
	wait(4);
	snd = Spawn( "script_origin",(-37686, 9058, 3509));
	dst = (-37737, 8948, 3509);
	snd playsound("clkw_scn_keegan_drag_body", "sounddone");
	wait(0.5);
	snd MoveTo(dst, 2.5);
	wait(2.5);
	snd waittill("sounddone");
	snd delete();
}

baker_drag_body1()
{
	thread baker_drop_bag();
	wait(3.5);
	snd = Spawn( "script_origin",(-38301, 9460, 3509));
	dst1 = (-38505, 9633, 3509);
	dst2 = (-38557, 9576, 3509);
	snd playsound("clkw_scn_baker_drag_body", "sounddone");
	wait(2.5);
	snd MoveTo(dst1, 5);
	wait(5);
	snd MoveTo(dst2, 1.5);
	snd waittill("sounddone");
	snd delete();
}

baker_drop_bag()
{
	wait(15.7);
	thread play_sound_in_space("clkw_scn_bag_catch", (-38498, 9597, 3508));	
}


vehicles_approaching()
{
		thread jeep_and_btr_appear();
		wait(9);
		level.jeep playsound("clkw_scn_ambush_jeep_stop");
}

/*
vehicles_approaching()
{
		thread jeep_and_btr_appear();
		wait(9);
		level.jeep playsound("clkw_scn_ambush_jeep_stop");
}
*/

jeep_and_btr_appear()
{
		snd = Spawn( "script_origin",(-38361, 12435, 3868));
		dst1 = (-38682, 10678, 3696);
		dst2 = (-36290, 8662, 3568);
		snd playsound("clkw_scn_ambush_approach", "sounddone");
		wait(7);
		snd MoveTo(dst1, 5);
		wait(6);
		snd MoveTo(dst2, 8);
		snd waittill("sounddone");
		snd delete();	
}

ambush_kill_driver_player()
{
	//thread ambush_kill_driver_player_latches();
	wait(0.3);
	thread play_sound_in_space("clkw_scn_ambush_driver_kill", (-38247, 9521, 3548));
	thread horn();
	wait(0.4);
	thread play_sound_in_space("clkw_scn_ambush_pass1_pull", (-38331, 9591, 3537));
	wait(2.5);
	thread play_sound_in_space("clkw_scn_ambush_driver_pull_player", (-38212, 9518, 3548));
	wait(3);
	thread play_sound_in_space("clkw_scn_ambush_driver_drop", (-38200, 9423, 3545));
	wait(1.7);
	thread dash_wipe();
}

horn()
{
	wait(1.3);
	thread play_sound_in_space("clkw_scn_ambush_driver_kill_horn", (-38302, 9484, 3548));
}

dash_wipe()
{
	if ( level.bDriverKilled == false )
	{
		level.bDriverKilled = true;
		thread play_sound_in_space("clkw_scn_ambush_dash_wipe", (-38261, 9515, 3548));
	}
}

ambush_jeep_latch_open_lf(note, flagName)
{
	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38243, 9509, 3542));	
}

ambush_jeep_latch_close_lf(note, flagName)
{
	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38243, 9509, 3542));	
}

ambush_jeep_latch_open_rf(note, flagName)
{
	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38303, 9552, 3542));	
}

ambush_jeep_latch_close_rf(note, flagName)
{
	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38303, 9552, 3542));	
}

ambush_jeep_latch_open_rr(note, flagName)
{
	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38288, 9579, 3542));	
}

ambush_jeep_latch_close_rr(note, flagName)
{
	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38288, 9579, 3542));	
}

ambush_kill_driver_cypher()
{
	//thread start_interior_music();
	//thread ambush_kill_driver_cypher_latches();
	wait(0.5);
	thread play_sound_in_space("clkw_scn_ambush_pass1_pull", (-38331, 9591, 3537));
	wait(1.3);
	thread play_sound_in_space("clkw_scn_ambush_driver_pull", (-38212, 9518, 3548));
	wait(2.5);
	thread play_sound_in_space("clkw_scn_ambush_driver_drop", (-38200, 9423, 3545));
	wait(1.5);
	thread keegan_drag_body2();
	wait(3.5);
	thread dash_wipe();
}

keegan_drag_body2()
{
	snd = Spawn( "script_origin",(-38363, 9575, 3522));
	dst = (-38533, 9643, 3522);
	snd playsound("clkw_scn_keegan_drag_body", "sounddone");
	wait(0.5);
	snd MoveTo(dst, 2.5);
	wait(2.5);
	snd waittill("sounddone");
	snd delete();
}

//ambush_kill_driver_player_latches()// temp - put in anims
//{
//	wait(0.9);
//	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38331, 9543, 3538));
//	wait(0.6);
//	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38241, 9507, 3538));
//	wait(6.8);
//	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38241, 9507, 3538));
//	wait(5.95);
//	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38281, 9582, 3538));
//	wait(0.5);
//	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38306, 9557, 3538));
//	wait(1.7);
//	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38239, 9509, 3538));
//}
//
//ambush_kill_driver_cypher_latches()// temp - put in anims
//{
//	wait(0.9);
//	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38331, 9543, 3538));
//	wait(0.6);
//	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38241, 9507, 3538));
//	wait(6.8);
//	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38241, 9507, 3538));
//	wait(5.95);
//	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-38281, 9582, 3538));
//	wait(0.5);
//	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38306, 9557, 3538));
//	wait(1.7);
//	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-38239, 9509, 3538));
//}
//
//temp_ambush_jeep_doors()// waiting on fix from design, temp hookup for mixing
//{
//	
//}

enter_jeep()
{
	level.player playsound ("clkw_scn_enter_jeep");
	wait(2);
	flag_set("aud_ambush_done");
}

vehicle_player_01()
{
	level.player playsound ("clkw_vehicle_player_01");
	thread jeep_start_music();
	//music_play("clkw_intro_mountainside", 5);
	//loc = Spawn( "script_origin",(0, 0, 0)); //temp workaround for no music fades problem.
	//loc scaleVolume(0.112);
	//wait(0.05);
	//loc playsound ("clkw_intro_mountainside", "sounddone");
	//wait(0.05);
	//loc scaleVolume(1, 16);
	wait(20);
	wait(7.5);
	thread btr_by_mountainside();
	wait(14.5);
	thread security_amb();
	//loc waittill("sounddone");
	//loc delete();
}

jeep_start_music()
{
	music_play("clkw_jeep_rolls");
}

btr_by_mountainside()
{
	snd = Spawn( "script_origin",(-32286, 3039, 2252));
	dst = (-32979, 2986, 2344);
	snd playsound("clkw_scn_interior_btr_by", "sounddone");
	snd MoveTo(dst, 2);
	snd waittill("sounddone");
	snd delete();	
}

//ride_watch_beep()
//{
//	wait(1.25);
//	level.player playsound("clkw_scn_clock_tick");
//}

exit_jeep()
{
	//wait(2);
	level.player playsound("clkw_scn_interior_jeep_exit");
	thread garage_misc();
}

garage_misc()
{
	wait(3.5);
	//IPrintLnBold("sound test");
	thread jeep_exit_bags();
}

jeep_exit_bags()
{
	snd = Spawn( "script_origin",(-29197, 2934, 2064));
	dst = (-29246, 2938, 2064);
	snd playsound("clkw_scn_pickup_bags");
	wait(1);
	snd MoveTo(dst, 0.5);
	wait(1);
	snd playsound("clkw_scn_bag_drop");
	wait(0.5);
	snd playsound("clkw_scn_bag_drop", "sounddone");
	snd waittill("sounddone");
	snd delete();	
}

timer_tick()
{
	ent = Spawn( "script_origin",(0, 0, 0));
	
	flag_wait("aud_tick");
	
	while( !flag( "lights_out" ) )
	{
		wait(0.4);
		ent playsound( "clkw_scn_clock_tick", "sounddone" );
		ent waittill("sounddone");
		flag_wait("aud_tick");
	}

	ent delete();
}
		
entry_door_close()
{
	wait(6.5);
	thread entry_door_beeper();
	thread entry_door_close_layer2();
	loc = Spawn( "script_origin",(-28749, 2619, 2120));
	loc playsound ("clkw_scn_entry_door_close");
	//flag_wait("lights_out");
	wait (22.25);
	thread entry_door_stop();
	thread team_foley_lights_out();
}

entry_door_close_layer2()
{
	loc = Spawn( "script_origin",(-28605, 2602, 2129));
	dst1 = (-28735, 2746, 2129);
	dst2 = (-28891, 2608, 2129);
	loc playsound ("clkw_scn_entry_door_close_layer2", "sounddone");
	loc MoveTo(dst1, 8.5);
	wait(8.5);
	loc MoveTo(dst2, 8.5);
	loc waittill("sounddone");
	loc delete();
}

security_amb()
{
	wait(11);

	thread security_vo();
}

security_vo()
{
		play_sound_in_space("clockwork_fs_pictureid", (-28147, 2003, 2117));
		wait(2.2);
		play_sound_in_space("clockwork_fs_wait", (-28147, 2003, 2117));
		wait(0.9);
		play_sound_in_space("clockwork_fs_allweapons", (-28147, 2003, 2117));
}

team_foley_lights_out()
{
		thread play_sound_in_space("clkw_keegan_ready_lights_out", (-28545, 2083, 2060));
		thread play_sound_in_space("clkw_cypher_ready_lights_out", (-28643, 1938, 2060));
		thread play_sound_in_space("clkw_baker_ready_lights_out", (-28590, 1931, 2060));
}

pre_thermite_amb()
{
	level.player playsound ("clkw_scn_power_down_lyr2");
	//loc = Spawn( "script_origin",(0, 0, 0));
	//loc playloopsound ("clkw_nvg");
	//wait(12);
	//loc scaleVolume (.501, 6);
	//flag_wait("aud_stop_music_during_thermite");
	//wait(3);
	//loc sound_fade_and_delete(2);
}

pre_thermite_amb_cp()
{
	loc = Spawn( "script_origin",(0, 0, 0));
	loc playloopsound ("clkw_nvg_cp");
	flag_wait("aud_stop_music_during_thermite");
	wait(3);
	loc sound_fade_and_delete(2);
}

security_beeps()
{
	wait(6.5);
	thread play_sound_in_space("clkw_scn_security_beep", (-28361, 1978, 2152));
	wait(9);
	thread play_sound_in_space("clkw_scn_security_beep", (-28361, 1978, 2152));
	wait(4.5);
	thread play_sound_in_space("clkw_scn_security_beep", (-28361, 2025, 2152));
	wait(6.5);
	thread play_sound_in_space("clkw_scn_security_gun_tray", (-28462, 1931, 2033));	
	
}

entry_door_beeper()
{
	wait(1.5);
	loc = Spawn( "script_origin",(-28751, 2619, 2111));
	loc playloopsound ("clkw_scn_entry_door_beeper");
	wait(0.05);
	flag_wait("aud_lights_out_music_started");
	wait(7);
	loc scaleVolume(0, 0.5);
	wait(0.6);
	loc delete();
}

entry_door_stop()
{
	thread play_sound_in_space("clkw_scn_entry_door_stop", (-28959, 2595, 2098));	
	thread play_sound_in_space("clkw_scn_entry_door_stop_layer2", (-28748, 2595, 2098));
}

lights_out_music()
{
	wait(1.5);
	flag_set("aud_lights_out_music_started");
	flag_wait("lights_out");
	music_stop(0.5);
}

power_down()
{
	level.player playsound ("clkw_scn_power_down");
	level.player SetClientTriggerAudioZone( "power_out" );
	wait(2);
	thread pre_thermite_amb();
}

hacking()	
{
	thread hacking_music();
	wait(1);
	thread play_sound_in_space("clkw_scn_hacking", (-26144, 1965, 2125));
	wait(14.7);
	thread play_sound_in_space("clkw_scn_hacking_complete", (-26144, 1965, 2125));
}

hacking_music()
{
	music_play("clkw_interior_doorbreak");
	wait(15);
	music_stop(3);
}

glowstick_hacking()
{
	wait(1.8);
	thread play_sound_in_space("clkw_scn_door_stick_break", (-26189, 1933, 2166));
	wait(12);
	thread play_sound_in_space("clkw_scn_door_stick_drop_01", (-26178, 1969, 2070));
}

glowsticks(actor)
{
	wait(1);
	thread play_sound_in_space("clkw_scn_door_stick_drop_01", (-26882, 670, 1938));
	wait(.1);
	thread play_sound_in_space("clkw_scn_door_stick_drop_02", (-26860, 772, 1938));
}

//glowstick_trans()
//{
//	level.player playsound("clkw_scn_vault_drill_glowstick_trans");
//}

vault_foley() // This is temp. All these sounds will be moved into notetracks.
{
	wait(2);
	thread door_break_foley();
	thread vault_bag_drops();
}

door_break_foley()
{
	snd = Spawn( "script_origin",(-26724, 752, 1995));
	dst = (-26888, 752, 1995);
	snd playsound("clkw_scn_door_break_foley_01", "sounddone");
	snd MoveTo(dst, 1.5);
	wait(1.5);
	snd waittill("sounddone");
	snd delete();	
}

//door_break_music()
//{
//	wait(4);
//	//music_play("clkw_interior_doorbreak");
//}

vault_bag_drops()
{
	wait(2.5);
	thread play_sound_in_space("clkw_scn_bag_drop", (-26885, 689, 1944));
	wait(0.7);
	thread play_sound_in_space("clkw_scn_bag_drop", (-26858, 849, 1944));
//	wait(0.4); 
//	thread play_sound_in_space("clkw_scn_vault_keegan_bag_foley", (-26880, 845, 1945));
//	wait(5.5);
//	thread play_sound_in_space("clkw_scn_vault_keegan_drill_place", (-26887, 790, 1943));	
}

drill_pullout()
{
	level.player playsound("clkw_scn_vault_drill_pullout");
}

drill_monitor()
{
	if ( level.aud_drillholenumber == 0 )
	{
		thread play_sound_in_space("clkw_scn_vault_drill_monitor", (-26896, 773, 2007));
		level.aud_drillholenumber = 1;
		//thread explosive_attach();
	}
	else
	{
		wait(2.8);
		thread play_sound_in_space("clkw_scn_vault_drill_monitor", (-26896, 706, 2000));	
	}
}

vault_keegan_drill_get(note, flagName)
{
	thread play_sound_in_space("clkw_scn_vault_keegan_bag_foley", (-26880, 845, 1945));
}

vault_keegan_drill_set(note, flagName)
{
	thread play_sound_in_space("clkw_scn_vault_keegan_drill_place", (-26887, 790, 1943));
}

vault_keegan_charge_set(note, flagName)
{
	if ( level.aud_charge_set == 0 )
	{
		wait(0.2);
		thread play_sound_in_space("clkw_scn_door_expl_attach", (-26900, 779, 1993));
		level.aud_charge_set = 1;
	}
	else
	{
		wait(0.1);
		thread play_sound_in_space("clkw_scn_door_expl_attach", (-26896, 715, 1993));	
	}
}

//explosive_attach()
//{
//	flag_wait("drill1_complete");
//	wait(1.8);
//	thread play_sound_in_space("clkw_scn_door_expl_attach", (-26900, 779, 1993));
//	flag_wait("drill2_complete");
//	wait(3.6);
//	thread play_sound_in_space("clkw_scn_door_expl_attach", (-26896, 715, 1993));
//}

chalk_swipe1()
{
	thread play_sound_in_space("clkw_scn_vault_drill_chalk_swipe", (-26896, 773, 2007));
}

chalk_swipe2()
{
	thread play_sound_in_space("clkw_scn_vault_drill_chalk_swipe", (-26896, 706, 2000));
}

drill_plant()
{
	wait(0.25);
	level.player playsound("clkw_scn_vault_drill_plant");
}


thermite()
{
//	wait(1);
	flag_wait("glow_start");
	thread thermite_start();
	thread play_sound_in_space("clkw_scn_thermite", (-26903, 9967, 2011));//teleport from here
	thread play_sound_in_space("clkw_scn_thermite", (-26903, 751, 2011));//to here
	flag_set("aud_stop_music_during_thermite");
	flag_wait("explosion_start");
	thread door_explosion();
}

thermite_start()
{
	flag_wait("thermite_start");
	thread play_sound_in_space("clkw_scn_thermite_start", (-26922, 741, 1995));
}

blowit_beep()
{
	wait(1);
	thread play_sound_in_space("clkw_mine_beep", (-26871, 754, 1995));
	wait(0.1);
	thread play_sound_in_space("clkw_mine_beep", (-26871, 754, 1995));
	wait(0.1);	
	thread play_sound_in_space("clkw_mine_beep", (-26871, 754, 1995));
}

door_explosion()
{
	thread play_sound_in_space ("clkw_scn_door_expl_source", (-26896, 744, 1995));
	level.player playsound ("clkw_scn_door_expl_debris");
	thread power_up();
	thread flying_debris();
	thread door_debris_l();
	thread door_debris_r();
	wait(0.3);
	thread play_sound_in_space("clkw_scn_door_glass_break_01", (-27089, 805, 1997));
	thread play_sound_in_space("clkw_scn_door_glass_break_02", (-27089, 697, 1997));
	wait(1);
	thread play_sound_in_space("clkw_door_explosion_lights", (-26840, 758, 2060));
	thread vault_water();
	wait(1);
	thread play_sound_in_space("clkw_scn_door_glass_fragments", (-27089, 750, 1997));
}

flying_debris()
{
	wait(0.3);
	thread play_sound_in_space("clkw_expl_metal_debris", (-26165, 727, 1995));
	wait(0.1);
	thread play_sound_in_space("clkw_expl_metal_debris", (-26561, 965, 1995));
	wait(0.15);
	thread play_sound_in_space("clkw_expl_metal_debris", (-26545, 330, 1995));
	wait(0.2);
	thread play_sound_in_space("clkw_expl_metal_debris", (-26188, 935, 1995));
}

vault_water()
{
	snd = Spawn( "script_origin",(-27093, 746, 2076));
	snd playloopsound("clkw_emt_vault_water");
	snd scalevolume(0);
	snd scalevolume(1, 1);
	flag_wait("aud_stop_vault_water");
	snd scalevolume(0, 1);
	snd delete();
}

vault_water2()
{
	snd = Spawn( "script_origin",(-27093, 746, 2076));
	snd playloopsound("clkw_emt_vault_water");
	snd scalevolume(0);
	snd scalevolume(1, 1);
}

door_debris_l()
{
    sound_forward_dist = 50;
    sound_height = 30;
    
	while (1)
    {
        flag_wait("touching_debris");
        soundpos = level.player.origin + (AnglesToForward(level.player.angles) * sound_forward_dist) + (0,-10,sound_height);
        thread play_sound_in_space("clkw_foot_metal_debris_player", soundpos);
        wait ( RandomFloatRange( 1, 2.5 ) );
        level.player waittill_movement();
    }
}

door_debris_r()
{
    sound_forward_dist = 50;
    sound_height = 30;
    
	while (1)
    {
        flag_wait("touching_debris");
        soundpos = level.player.origin + (AnglesToForward(level.player.angles) * sound_forward_dist) + (0,10,sound_height);
        thread play_sound_in_space("clkw_foot_metal_debris_player", soundpos);
        wait ( RandomFloatRange( 1, 2.5 ) );
        level.player waittill_movement();
    }
}

//END Power Out Area

power_up()
{
	flag_wait("explosion_start");
	wait(1);
	level.player playsound ("clkw_scn_power_up");
	level.player ClearClientTriggerAudioZone();
	wait(0.5);
	thread pa_announcements_interior_combat();
	thread alarms_1();
	wait(8);
	music_play("clkw_interior_combat");
}

//Alarms

alarms_1()
{
	if (!flag("aud_alarms_on") )
	{
		flag_set("aud_alarms_on");
		loc1 = Spawn( "script_origin",(-28579, 802, 2160));
		loc2 = Spawn( "script_origin", (-27287, 194, 2160));
		loc1 playloopsound("clkw_emt_clockwork_alarm_1", (-28579, 802, 2160));
		loc2 playloopsound("clkw_emt_clockwork_alarm_2", (-27287, 194, 2160));
		flag_wait("aud_alarms_off");
		loc1 sound_fade_and_delete(2);
		loc2 sound_fade_and_delete(2);
		flag_clear("aud_alarms_on");
	}
}

alarms_2()
{
	snd1 = Spawn( "script_origin",(-30025, -4292, 1949));
	snd2 = Spawn( "script_origin",(-28175, -1632, 1605));                        		
	snd1 playloopsound("clkw_emt_clockwork_alarm_3");
	snd2 playloopsound("clkw_emt_clockwork_alarm_4");	
	
	flag_wait("aud_defend_combat_started");
	snd1 scaleVolume(0.2, 4);
	snd2 scaleVolume(0.2, 4);
	wait(15);
	snd1 scaleVolume(0, 10);
	snd2 scaleVolume(0, 10);
	wait(10);
	snd1 stoploopsound("clkw_emt_clockwork_alarm_3");
	snd2 stoploopsound("clkw_emt_clockwork_alarm_4");
	snd1 delete();
	snd2 delete();
}

alarms_3()
{
	wait(0.1);
	
	loc1 = Spawn( "script_origin",(-28579, 802, 2160));
	loc2 = Spawn( "script_origin",(-27287, 194, 2160));
	loc3 = Spawn( "script_origin",(-25885, 1587, 2081));
	loc4 = Spawn( "script_origin",(-26629, 1277, 2143));
	loc5 = Spawn( "script_origin",(-25593, 2296, 2165));
	loc6 = Spawn( "script_origin",(-28850, 1968, 2139));
	loc7 = Spawn( "script_origin",(-29099, 3995, 2127));
		
	loc1 playloopsound("clkw_emt_clockwork_alarm_1");
	loc2 playloopsound("clkw_emt_clockwork_alarm_2");
	loc3 playloopsound("clkw_emt_clockwork_alarm_5");
	loc4 playloopsound("clkw_emt_clockwork_alarm_6");
	loc5 playloopsound("clkw_emt_clockwork_alarm_7");
	loc6 playloopsound("clkw_emt_clockwork_alarm_8");
	loc7 playloopsound("clkw_emt_clockwork_alarm_9");
	
	loc1 scaleVolume(0);
	loc2 scaleVolume(0);
	loc3 scaleVolume(0);
	loc4 scaleVolume(0);
	loc5 scaleVolume(0);
	loc6 scaleVolume(0);
	loc7 scaleVolume(0);
	
	wait(0.05);
		
	loc1 scaleVolume(0.3, 4);
	loc2 scaleVolume(0.3, 4);
	loc3 scaleVolume(0.3, 4);
	loc4 scaleVolume(0.3, 4);
	loc5 scaleVolume(0.3, 4);
	loc6 scaleVolume(0.3, 4);
	loc7 scaleVolume(0.3, 4);
	
	wait(4.5);
	
	loc1 scaleVolume(1, 1);
	loc2 scaleVolume(1, 1);
	loc3 scaleVolume(1, 1);
	loc4 scaleVolume(1, 1);
	loc5 scaleVolume(1, 1);
	loc6 scaleVolume(1, 1);
	loc7 scaleVolume(1, 1);
	
	flag_wait( "aud_kill_idle" );
	
	wait(4);
	loc1 scaleVolume(0, 5);
	loc2 scaleVolume(0, 5);
	loc3 scaleVolume(0, 5);
	loc4 scaleVolume(0, 5);
	loc5 scaleVolume(0, 5);
	loc6 scaleVolume(0, 5);
	loc7 scaleVolume(0, 5);
	
	wait(5);
	loc1 stoploopsound("clkw_emt_clockwork_alarm_1");
	loc2 stoploopsound("clkw_emt_clockwork_alarm_2");
	loc3 stoploopsound("clkw_emt_clockwork_alarm_5");
	loc4 stoploopsound("clkw_emt_clockwork_alarm_6");
	loc5 stoploopsound("clkw_emt_clockwork_alarm_7");
	loc6 stoploopsound("clkw_emt_clockwork_alarm_8");
	loc7 stoploopsound("clkw_emt_clockwork_alarm_9");
	
	loc1 delete();
	loc2 delete();
	loc3 delete();
	loc4 delete();
	loc5 delete();
	loc6 delete();
	loc7 delete();
}

//End Alarms

//Start PA Announcements

pa_announcements_interior_combat()
{	
	loop = [];
	loop[ loop.size ] = "clockwork_mpa_redalert";
	loop[ loop.size ] = "clockwork_mpa_quarters";
	loop[ loop.size ] = "clockwork_mpa_securelocation";
	loop[ loop.size ] = "clockwork_mpa_stations";
	loop[ loop.size ] = "clockwork_mpa_level3";

	loop = array_randomize( loop );
	level thread pa_announcements_interior_combat_thread( "speaker_path_1", loop );
}

pa_announcements_cqb()
{	
	loop = [];
	loop[ loop.size ] = "clockwork_mpa_intrudershavebreachedthe";
	loop[ loop.size ] = "clockwork_mpa_allsquadsreportto";
	loop[ loop.size ] = "clockwork_mpa_attentionintrudershave";
	loop[ loop.size ] = "clockwork_mpa_combatpersonnelreportto";
	loop[ loop.size ] = "clockwork_mpa_ourelectronicsurveillance";

	loop = array_randomize( loop );
	level thread pa_announcements_cqb_thread( "speaker_path_2", loop );
}

pa_announcements_chaos()
{	
	loop = [];
	loop[ loop.size ] = "clockwork_mpa_checktheidof";
	loop[ loop.size ] = "clockwork_mpa_damagecontrolreportto";
	loop[ loop.size ] = "clockwork_mpa_medicsareneededin";
	loop[ loop.size ] = "clockwork_mpa_additionaltechpersonnel";
	loop[ loop.size ] = "clockwork_mpa_theintrudersarewearing";

	loop = array_randomize( loop );
	level thread pa_announcements_chaos_thread( "speaker_path_3", loop );
}

pa_announcements_interior_combat_thread( path_targetname, snd_array )
{
	path_start = getstruct( path_targetname, "targetname" );
	max_dist = 700;
	max_dist *= max_dist;

	speakers = [];

	delay_struct = SpawnStruct();
	delay_struct.delay = 0;
	delay_struct.waiting_for_sound = false;

	for ( i = 0; i < 2; i++ )
	{
		speakers[ i ] = Spawn( "script_origin", ( 0, 0, 0 ) );
		speakers[ i ].id = i + 1;
	}
	
	index = 0;
	while( !flag( "aud_stop_interior_combat_pa" ) )
	{
		nodes = get_closest_speaker_nodes( path_start );

		foreach ( i, speaker in speakers )
		{
			speaker.origin = nodes[ i ].origin;
//			print3d( speaker.origin, "speaker" + speaker.id, ( 1, 1, 0 ), 1, 1, 4 );
		}
	
		if ( GetTime() > delay_struct.delay && !delay_struct.waiting_for_sound )
		{
			if ( DistanceSquared( level.player.origin, nodes[ 0 ].origin ) > max_dist )
			{
				wait( 0.1 );
				continue;
			}

			mod = index % snd_array.size;
			index++;
			if ( mod == 0 )
			{
				snd_array = array_randomize( snd_array );
			}

			delay_struct thread speaker_playsound( speakers, snd_array[ mod ] );
		}

		wait( 0.1 );
	}
}

pa_announcements_cqb_thread( path_targetname, snd_array )
{
	path_start = getstruct( path_targetname, "targetname" );
	max_dist = 700;
	max_dist *= max_dist;

	speakers = [];

	delay_struct = SpawnStruct();
	delay_struct.delay = 0;
	delay_struct.waiting_for_sound = false;

	for ( i = 0; i < 2; i++ )
	{
		speakers[ i ] = Spawn( "script_origin", ( 0, 0, 0 ) );
		speakers[ i ].id = i + 1;
	}
	
	index = 0;

	while( !flag( "aud_defend_started" ) )	
	{
		nodes = get_closest_speaker_nodes( path_start );

		foreach ( i, speaker in speakers )
		{
			speaker.origin = nodes[ i ].origin;
//			print3d( speaker.origin, "speaker" + speaker.id, ( 1, 1, 0 ), 1, 1, 4 );
		}
	
		if ( GetTime() > delay_struct.delay && !delay_struct.waiting_for_sound )
		{
			if ( DistanceSquared( level.player.origin, nodes[ 0 ].origin ) > max_dist )
			{
				wait( 0.1 );
				continue;
			}

			mod = index % snd_array.size;
			index++;
			if ( mod == 0 )
			{
				snd_array = array_randomize( snd_array );
			}

			delay_struct thread speaker_playsound( speakers, snd_array[ mod ] );
		}

		wait( 0.1 );
	}
}

pa_announcements_chaos_thread( path_targetname, snd_array )
{
	path_start = getstruct( path_targetname, "targetname" );
	max_dist = 700;
	max_dist *= max_dist;

	speakers = [];

	delay_struct = SpawnStruct();
	delay_struct.delay = 0;
	delay_struct.waiting_for_sound = false;

	for ( i = 0; i < 2; i++ )
	{
		speakers[ i ] = Spawn( "script_origin", ( 0, 0, 0 ) );
		speakers[ i ].id = i + 1;
	}
	
	index = 0;
	while( !flag( "aud_kill_idle" ) )	
	{
		nodes = get_closest_speaker_nodes( path_start );

		foreach ( i, speaker in speakers )
		{
			speaker.origin = nodes[ i ].origin;
//			print3d( speaker.origin, "speaker" + speaker.id, ( 1, 1, 0 ), 1, 1, 4 );
		}
	
		if ( GetTime() > delay_struct.delay && !delay_struct.waiting_for_sound )
		{
			if ( DistanceSquared( level.player.origin, nodes[ 0 ].origin ) > max_dist )
			{
				wait( 0.1 );
				continue;
			}

			mod = index % snd_array.size;
			index++;
			if ( mod == 0 )
			{
				snd_array = array_randomize( snd_array );
			}

			delay_struct thread speaker_playsound( speakers, snd_array[ mod ] );
		}

		wait( 0.1 );
	}
}

speaker_playsound( speakers, sound )
{
	self.waiting_for_sound = true;

	foreach ( speaker in speakers )
	{
		speaker PlaySound( sound, "sounddone" );
	}

	speakers[ 0 ] waittill( "sounddone" );

	self.waiting_for_sound = false;
	self.delay = GetTime() + ( RandomFloatRange( 1, 8 ) * 1000 );
}

get_closest_speaker_nodes( node )
{
	dist = DistanceSquared( level.player.origin, node.origin );
	closest = node;
	while ( IsDefined( node.target ) )
	{
		node = getstruct( node.target, "targetname" );

		test_dist = DistanceSquared( level.player.origin, node.origin );
		if ( test_dist < dist )
		{
			dist = test_dist;
			closest = node;
		}
	}

	// Now get the next closest for stereo feel
	prev = undefined;
	prev = getstruct( closest.targetname, "target" );

	next = undefined;
	if ( IsDefined( closest.target ) )
	{
		next = getstruct( closest.target, "targetname" );
	}

//	dist = 2147483647; // Largest number in script
	dist = 8000 * 8000;
	nodes = [ closest ];
	closest_2nd = undefined;

	nodes2 = [];

	if ( IsDefined( prev ) )
	{
		nodes2[ nodes2.size ] = prev;
	}

	if ( IsDefined( next ) )
	{
		nodes2[ nodes2.size ] = next;
	}

	if ( nodes2.size > 0 )
	{
		dist = DistanceSquared( level.player.origin, nodes2[ 0 ].origin );
		closest_2nd = nodes2[ 0 ];
	}

	foreach ( n in nodes2 )
	{
		test_dist = DistanceSquared( level.player.origin, n.origin );

		if ( test_dist < dist )
		{
			dist = test_dist;
			closest_2nd = n;
		}
	}

	if ( IsDefined( closest_2nd ) )
	{
		nodes[ nodes.size ] = closest_2nd;
	}

	return nodes;
}

//End PA Announcements

//cqb()
//{
//	loc = Spawn( "script_origin",(0, 0, 0));
//	loc playloopsound ("clkw_cqb");
//	flag_wait("aud_defend_started");
//	loc scaleVolume(0,2);
//	wait(2.5);
//	loc delete(0);
//}

cqb_door_shove()
{
	wait(2.1);
	thread play_sound_in_space("clkw_scn_cqb_doorbreak_hit_2", (-29566, -941, 1996));
	wait(2.1);
	thread play_sound_in_space("clkw_scn_cqb_doorbreak_break", (-29566, -941, 1996));
	thread cqb_fans();
}

cqb_door_open_slow()
{
	wait(0.5);
	thread play_sound_in_space("clkw_scn_cqb_door_open_slow", (-30017, -941, 1996));
	wait(0.3);
	thread pre_lookout();

	flag_set("aud_stop_vault_water");
}

cqb_door_close_behind()
{
	wait(1);
	thread play_sound_in_space("clkw_scn_cqb_door_close_behind", (-29580, -950, 1994));
}

cqb_fans()
{
	thread play_loopsound_in_space("clkw_scn_cqb_fan_blade_1", (-30088, -660, 1994));
	thread play_loopsound_in_space("clkw_scn_cqb_fan_blade_2", (-30088, -1223, 1994));
	thread play_loopsound_in_space("clkw_scn_cqb_fan_blade_3", (-30088, -1546, 1994));
	flag_wait("aud_stop_fan_sound");
}

pre_lookout()
{   
        flag_wait( "aud_pre_lookout" ); 
        
        if (level.bCqb_pa_playing == false)
        {
        	thread pa_announcements_cqb();
        	level.bCqb_pa_playing = true;
        }
}

locker_brawl(here)	
{
	wait(1);
	snd = Spawn( "script_origin",(-30664, -1684, 1856));
	dst1 = (-30650, -1613, 1860);
	dst2 = (-30628, -1733, 1855);
	dst3 = (-30627, -1687, 1803);
	snd playsound("clkw_scn_cqb_locker_brawl", "sounddone");
	snd MoveTo(dst1, 1);
	wait(2);
	snd MoveTo(dst2, 0.5);
	wait(0.7);
	snd MoveTo(dst3, 0.5);
	snd waittill("sounddone");
	snd delete();
	thread alarms_2();
}

locker_brawl_vo(here)	
{
	snd = Spawn( "script_origin",(-30664, -1684, 1856));
	wait(1);
	snd playsound("scn_clockwork_catwalk_npc_death", "sounddone");
	dst1 = (-30650, -1613, 1860);
	dst2 = (-30628, -1733, 1855);
	dst3 = (-30627, -1687, 1803);
	snd MoveTo(dst1, 1);
	wait(2);
	snd MoveTo(dst2, 0.5);
	wait(0.7);
	snd MoveTo(dst3, 0.5);
	snd waittill("sounddone");
	snd delete();
	thread alarms_2();
}

rotunda_kill()
{
	wait(4.6);
	thread play_sound_in_space("clkw_scn_cqb_encounter_foley_1", (-29922, -2931, 1740));
	wait(0.6);
	thread play_sound_in_space("clkw_scn_cqb_encounter_foley_2", (-29883, -2891, 1740));
}

defend_start()
{
	wait(0.05);
	flag_set("aud_defend_started");
	flag_set("aud_alarms_off");
	//music_play("clkw_defend_start");
	flag_wait("aud_defend_combat_started");
	music_stop(2);
}

defend_combat()
{
	wait(18);
	//thread rvn_add_mix("foot_combat", 12 );
	flag_set("aud_defend_combat_started");
	wait(110);
	music_play("clkw_defend_combat");
	//loc =  Spawn( "script_origin",(0, 0, 0));
	//loc playloopsound ("clkw_defend_combat");
	flag_wait( "defend_combat_finished" );
	music_stop(3);
	//wait(12);
	//thread defend_complete_music();
	//loc scaleVolume(0, 6);
	//wait(6.1);
	//loc sound_fade_and_delete(6);
}

defend_door_explosion(here)
{
	    if (level.bDefendDoorExplosionPlaying == false)
        {
	    	level.bDefendDoorExplosionPlaying = true;
        	thread play_sound_in_space ("clkw_defend_door_explosion", here);
        	level.player playsound ("clkw_defend_door_expl_debris");
        	wait(1);
        	level.bDefendDoorExplosionPlaying = false;
        }
}

defend_fire(here)
{
		if (level.bDefendDoorExplosionPlaying == false)
        {
		    level.bDefendDoorExplosionPlaying = true;
		    thread play_sound_in_space ("clkw_defend_door_explosion", here +(0, -100, 0));
			thread play_sound_in_space ("clkw_defend_fire_blocker_expl", here +(0, -100, 0));
	    	thread play_loopsound_in_space ("clkw_defend_fire", here +(0, -100, 0));
	    	wait(1);
        	level.bDefendDoorExplosionPlaying = false;
		}
}

command_platform_bag_cypher()
{
	wait(2.2);
	thread play_sound_in_space ("clkw_scn_defend_bag_drop_cypher", (-27927, -623, 1462));
}

command_platform_bag_keegan()
{
	wait(2.2);
	thread play_sound_in_space ("clkw_scn_defend_bag_drop_keegan", (-27948, -696, 1462));
}

command_platform_bag_baker()
{
	wait(3);
	thread play_sound_in_space ("clkw_scn_defend_bag_drop_baker", (-27871, -714, 1462));
}

command_platform_bag_player()
{
	wait(0.25);
	thread play_sound_in_space ("clkw_mine_drop_bag", (-27856, -649, 1451));
}

teargas_grab()
{
	level.player playsound("clkw_defend_item_grab");	
}

mines_grab()
{
	level.player playsound("clkw_defend_item_grab");
	wait(0.8);
	{
		level.player playsound ("clkw_mine_pickup");
	}
}

mines_ready_to_throw()
{
	wait(0.95);
	{
		level.player playsound ("clkw_mine_pickup");
	}
}

mine_explode(loc)
{
	thread play_sound_in_space("clkw_mine_flare", loc);
	wait(1.5);
	thread play_sound_in_space("clkw_mine_explode", loc);
}

//defend_complete_music()
//{
//	//music_stop(2);
//	wait(1.5);
//	music_play("clkw_defend_complete");
//}

defend_door_open()
{
	play_sound_in_space ("clkw_scn_defend_door_open", (-27656, 276, 1457));
}

defend_door_close()
{
	play_sound_in_space ("clkw_scn_defend_door_close", (-27656, 276, 1457));
}

chaos_music()
{
	flag_wait( "inpos_player_elevator" );
	//music_play("clkw_chaos");
}

//chaos_pa()
//{
//	self endon( "aud_kill_idle" );
//	
//	while(1)
//	{
//		play_sound_in_space("clockwork_mpa_warningthehostileforces", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_checktheidof", (-26232, 2379, 2177));
//
//		wait(3);
//		
//		play_sound_in_space("clockwork_mpa_thebaseisnow", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_damagecontrolreportto", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_medicsareneededin", (-26232, 2379, 2177));
//
//		wait(2);
//		
//		play_sound_in_space("clockwork_mpa_powerisstillout", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_backupisneededat", (-26232, 2379, 2177));
//
//		wait(5);
//		
//		play_sound_in_space("clockwork_mpa_medicalpersonnelareneeded", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_additionaltechpersonnel", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_commandervankovreportto", (-26232, 2379, 2177));
//
//		wait(1);
//		
//		play_sound_in_space("clockwork_mpa_additionalmedicalare", (-26232, 2379, 2177));
//
//		wait(5);
//		
//		play_sound_in_space("clockwork_mpa_theintrudersarewearing", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_arepaircrewis", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_doublesquadsatall", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_theenemyisstill", (-26232, 2379, 2177));
//
//		wait(6);
//		
//		play_sound_in_space("clockwork_mpa_searchteamsreportto", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_allmilitarypersonnelmust", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_thelocationofthe", (-26232, 2379, 2177));
//
//		play_sound_in_space("clockwork_mpa_nooneisto", (-26232, 2379, 2177));
//
//		wait(1);
//		
//		play_sound_in_space("clockwork_mpa_powerhasgoneout", (-26232, 2379, 2177));
//
//		wait(1);
//	}
//}

elevator()
{
	level.player playsound ("clkw_scn_elevator");
	wait(7);
	thread alarms_3();
	wait(8);
	thread pa_announcements_chaos();
}

elevator_door_close()
{
	thread play_sound_in_space("clkw_scn_elevator_door_close", (-27369, 1062, 1469));
}

elevator_door_open()
{
	level.player playsound ("clkw_scn_elevator_door_open", (-27369, 1062, 1990));
	music_play("clkw_chaos");
	thread vault_water2();

	//get next door sounds ready
	thread exfil_keegan_and_cypher_enter_jeep();
	thread exfil_baker_enter_jeep();
	//thread exfil_cypher_enter_jeep();
}

garage_jeep_start_skid()
{
	music_stop(3);
	//wait(2);
	snd = Spawn( "script_origin",(-28277, 2732, 2060));
	dst = (-27091, 3032, 2060);
	snd playsound("clkw_garage_jeep_start_skid", "sounddone");
	wait(2.1);
	snd MoveTo(dst, 5);
	snd waittill("sounddone");
	snd delete();	
}

exfil_enter_jeep()
{
	level.player playsound ("clkw_scn_exfil_enter_jeep");
	//thread exfil_baker_enter_jeep();
}

exfil_keegan_and_cypher_enter_jeep()
{
	flag_wait("aud_keegan_getin");
	thread exfil_keegan_enter_jeep();
	thread exfil_cypher_enter_jeep();
}

exfil_keegan_enter_jeep()
{
	thread exfil_jeep_latch_open_lf();
	wait(1.5);
	thread play_sound_in_space("clkw_keegan_enter_jeep", (-28656, 3079, 2062));
	wait(1.5);
	thread exfil_jeep_latch_close_lf();
	wait(0.5);
	thread exfil_engine_start_keegan();
}

exfil_cypher_enter_jeep()
{
	thread exfil_jeep_latch_open_lr();
	wait(0.5);
	thread play_sound_in_space("clkw_cypher_enter_jeep", (-28677, 3095, 2062));
	wait(1.8);
	thread exfil_jeep_latch_close_lr();
}

exfil_baker_enter_jeep()
{
	flag_wait("aud_baker_getin");
	thread exfil_engine_starts_axis();
	thread exfil_jeep_latch_open_rf();
	wait(1.5);
	thread play_sound_in_space("clkw_baker_enter_jeep", (-28678, 3044, 2062));
	wait(2);
	thread exfil_jeep_latch_close_rf();
}

exfil_engine_starts_axis()
{
	thread play_sound_in_space("clkw_scn_exfil_engine_start_b", (-28449, 3083, 2088));
	wait(1.5);
	thread play_sound_in_space("clkw_scn_exfil_engine_start_c", (-29112, 2915, 2088));
}

exfil_engine_start_keegan()
{
	snd = Spawn( "script_origin",(-28603, 3008, 2088));
	snd playsound("clkw_scn_exfil_engine_start_a", "sounddone");
	flag_wait("aud_kill_idle");
	snd scalevolume(0, 1);
	snd delete();
}

exfil_jeep_latch_open_lf()
{
	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-28638, 3085, 2090));
}

exfil_jeep_latch_close_lf()
{
	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-28638, 3085, 2090));
}

exfil_jeep_latch_open_rf()
{
	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-28691, 3035, 2090));
}

exfil_jeep_latch_close_rf()
{
	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-28691, 3035, 2090));	
}

exfil_jeep_latch_open_lr()
{
	thread play_sound_in_space("clkw_scn_ambush_latch_open", (-28661, 3106, 2090));

}

exfil_jeep_latch_close_lr()
{
	thread play_sound_in_space("clkw_scn_ambush_latch_close", (-28661, 3106, 2090));	
}

lead_jeep()
{
	snd = Spawn( "script_origin",(-28451, 3096, 2074));		
	dst1 = (-28320, 2865, 2074);
	dst2 = (-27412, 2934, 2074);
	dst3 = (-25944, 3491, 2069);
	snd playsound("clkw_garage_lead_jeep_by", "sounddone");
	snd moveTo(dst1, 1.5);
	wait(1.5);
	snd moveTo(dst2, 4);
	wait(4);
	snd moveTo(dst3, 3.5);
	wait(3.5);
	snd waittill("sounddone");
	snd delete();
}

exfil_get_on_turret()
{
	wait(3.5);
	level.player playsound("clkw_scn_chase_stand_up");
}

chase_tower_fire()
{
	snd1 = Spawn( "script_origin",(-8014, -3763, 949));
	snd2 = Spawn( "script_origin",(-8014, -3763, 949));
	snd3 = Spawn( "script_origin",(-8014, -3763, 949));
			
	dst1 = (-10889, -5143, 286);
	dst2 = (-10433, -4780, 264);
	dst3 = (-9275, -4338, 264);
	
	snd1 playsound("clkw_scn_chase_tower_fire_01", "sounddone");
	snd1 MoveTo(dst1, 1);
	wait(1);
	snd2 playsound("clkw_scn_chase_tower_fire_01", "sounddone");
	snd2 MoveTo(dst2, 1);
	wait(1);
	snd3 playsound("clkw_scn_chase_tower_fire_01", "sounddone");
	snd3 MoveTo(dst3, 1);
	
	snd3 waittill("sounddone");
	snd1 delete();
	snd2 delete();
	snd3 delete();	
}

chase_player()
{
	//thread chase_amb_test();
	//thread pileupcounter_test();
	thread exit_tunnel_jeep_by();
	thread checkpoint_foley();
	
	flag_set ("aud_kill_idle");
	
	thread chase_amb_garage_start();
	thread chase_amb_garage_punch_it();
	thread chase_amb_garage_pre_exit();
	thread chase_amb_garage_pre_exit_skid();
	thread chase_amb_garage_exit();
	thread chase_amb_crossroad();
	thread chase_amb_enter_ravine();
	thread chase_amb_enter_tunnel();
	thread chase_amb_exit_tunnel();
	thread chase_amb_under_bridge_1();
	thread chase_amb_sharp_turn();
	thread chase_amb_under_bridge_2();
	thread chase_amb_under_bridge_3();
	thread chase_amb_enter_chasm();
	thread chase_amb_tight_spot();
	thread chase_amb_under_bridge_4();
	thread chase_amb_sub_comes_up();
}

exit_tunnel_jeep_by()
{
	wait(9.2);
	snd = Spawn( "script_origin",(-25590, 3743, 2069));
	dst = (-26031, 3615, 2069);
	snd playsound("clkw_exfil_garage_jeep_by", "sounddone");
	snd MoveTo(dst, 4);
	snd waittill("sounddone");
	snd delete();	
}

checkpoint_foley()
{
	wait(16.5);
	thread play_sound_in_space( "clkw_garage_checkpoint_foley", (-23761, 3818, 2081));
}

chase_player_collision()
{
	level.player playsound( "clkw_scn_chase_player_impact" );
	//IPrintLnBold("player collision");
}

chase_player_jolt()
{
	level.player playsound( "clkw_scn_chase_player_jolt" );	
}

chase_concussion()
{
	/*
	if ( !flag( "aud_chase_interior" ) )
	{
		set_zone("chase_concussion");
		IPrintLnBold("concussion");
		wait(.2);
		set_zone("chase_exterior", 0.5);
	}
	*/
}
chase_pileup_counter()
{
	foo1 = level.pileupcounter;
	level.pileupcounter = foo1 + 1;
	wait(1.6);
	foo2 = level.pileupcounter;
	level.pileupcounter = foo2 - 1 ;
}

chase_crashmix(here)
{ 		    
	if((!level.bCrashMix)  && !flag("chase_under_bridge_4") && flag("aud_start_pileup"))
    {
        lag = 0.25;
        level.bCrashMix = true;
        oldmix = level._audio.mix.current;
        //set_mix("chase_concussion");
        level.player playsound("clkw_scn_ice_chase_expl_2d");
        level.player playsound("clkw_chase_expl_close_debris");
        while( level.crashTimer < lag  )
        {
            wait 0.1;
            level.crashTimer = level.crashTimer + 0.1;
        }
        level.bCrashMix = false;
        level.crashTimer = 0;
//        if ( flag( "aud_chase_interior" ) )
//        {
//            set_mix("chase_interior");
//        }
//        else
//        {
//            set_mix("chase_exterior");
//            //IPrintLnBold("clear concussion");
//        }
    }
    else
    {
        level.crashTimer = 0;
    }
    
}

//
//pileupcounter_test()
//{
//	while(1)
//	{
//		IPrintLnBold(level.pileupcounter);
//		wait(1);
//	}
//}

chase_land_tires_big(here)
{
	thread chase_pileup_counter();
			
	if ( !flag( "aud_land_tires_big_playing" ) )
	{
		thread play_sound_in_space( "clkw_scn_chase_land_tires_big", here );
		flag_set("aud_land_tires_big_playing");
		wait(1);
		flag_clear("aud_land_tires_big_playing");
	}
}

chase_land_tires_small(here)
{
	thread chase_pileup_counter();
			
	if ( !flag( "aud_land_tires_small_playing" ) )
	{
		thread play_sound_in_space( "clkw_scn_chase_land_tires_small", here );
		flag_set("aud_land_tires_small_playing");
		wait(3);
		flag_clear("aud_land_tires_small_playing");
	}
}

chase_land_roof(here)
{
	
	thread chase_pileup_counter();
	thread chase_pileup_counter();
	
	if ( level.pileupcounter > 4 )
	{
		thread pileup(here);
	}
		
	if ( !flag( "aud_land_roof_playing" ) )
	{
			thread play_sound_in_space( "clkw_scn_chase_land_roof", here );
			flag_set("aud_land_roof_playing");
			wait(2);
			flag_clear("aud_land_roof_playing");
	}
}

chase_leftground(here)
{
	thread chase_pileup_counter();
	thread chase_pileup_counter();
	
	if ( level.pileupcounter > 8 )
	{
		thread pileup(here);
	}
		
	if ( !flag( "aud_leftground_playing" ) )
	{
		thread play_sound_in_space( "clkw_scn_chase_leftground", here );
		rand = randomInt( 2 );
		if ( rand == 1 )
		{
			thread play_sound_in_space( "clockwork_chase_scream", here);
		}

		
		flag_set("aud_leftground_playing");
		wait(1);
		flag_clear("aud_leftground_playing");
	}
}

chase_collision(here)
{
	thread chase_pileup_counter();
		
	if ( level.pileupcounter > 15 )
	{
		thread pileup(here);
	}
		
	if ( !flag( "aud_collision_playing" ) )
	{
		thread play_sound_in_space( "clkw_scn_chase_collision", here );
		flag_set("aud_collision_playing");
		wait(0.5);
		flag_clear("aud_collision_playing");
	}
}

chase_sm_leftground(here)
{		
	if ( !flag( "aud_leftground_playing" ) )
	{
		thread play_sound_in_space( "clkw_scn_chase_leftground", here );
		rand = randomInt( 2 );
		if ( rand == 1 )
		{
			thread play_sound_in_space( "clockwork_chase_scream", here);
		}
		
		flag_set("aud_leftground_playing");
		wait(1);
		flag_clear("aud_leftground_playing"); 
	}
}

chase_sm_collision(here)
{		
	if ( !flag( "aud_collision_playing" ) )
	{
		thread play_sound_in_space( "clkw_scn_chase_sm_collision", here );
		//flag_set("aud_collision_playing");
		//wait(0.5);
		//flag_clear("aud_collision_playing");
	}
}

pileup(here)
{
	if ( flag( "aud_start_pileup" ))
	{
		if ( !flag( "aud_pileup_playing" ) && (level.pileupsequence == 1) )
		{
			//IPrintLnBold("TEST1");
			thread play_sound_in_space( "clkw_scn_chase_pileup_04", here );
			rand = randomInt( 2 );
			if ( rand == 1 )
			{
				thread play_sound_in_space( "clockwork_chase_scream", here);
			}
			flag_set("aud_pileup_playing");
			wait(6);
			flag_clear("aud_pileup_playing");
			level.pileupsequence = 2;
		}
	
		else if ( !flag( "aud_pileup_playing" ) && (level.pileupsequence == 2) )
		{
			//IPrintLnBold("TEST2");
			thread play_sound_in_space( "clkw_scn_chase_pileup_02", here );
			rand = randomInt( 2 );
			if ( rand == 1 )
			{
				thread play_sound_in_space( "clockwork_chase_scream", here);
			}
			flag_set("aud_pileup_playing");
			wait(6);
			flag_clear("aud_pileup_playing");
			level.pileupsequence = 3;
		}
		
		else if ( !flag( "aud_pileup_playing" ) && (level.pileupsequence == 3) )
		{
			//IPrintLnBold("TEST3");
			thread play_sound_in_space( "clkw_scn_chase_pileup_03", here );
			rand = randomInt( 2 );
			if ( rand == 1 )
			{
				thread play_sound_in_space( "clockwork_chase_scream", here);
			}
			flag_set("aud_pileup_playing");
			wait(6);
			flag_clear("aud_pileup_playing");
			level.pileupsequence = 4;
		}
		
		else if ( !flag( "aud_pileup_playing" ) && (level.pileupsequence == 4) )
		{
			//IPrintLnBold("TEST3");
			thread play_sound_in_space( "clkw_scn_chase_pileup_01", here );
			rand = randomInt( 2 );
			if ( rand == 1 )
			{
				thread play_sound_in_space( "clockwork_chase_scream", here);
			}
			flag_set("aud_pileup_playing");
			wait(6);
			flag_clear("aud_pileup_playing");
			level.pileupsequence = 1;
		}
	}
}

chase_sink(here)
{
	thread play_sound_in_space("clkw_scn_ice_chase_hole_loud", here);
	
	rand = randomInt( 2 );
	if ( rand == 1 )
	{
		wait(0.1);
		thread play_sound_in_space("clkw_scn_ice_chase_crack", here);
	}
}

chase_crack_icehole(here)
{
	rand = randomInt( 2 );
	if ( rand == 1 )
	{
		wait(0.1);
		thread play_sound_in_space("clkw_scn_ice_chase_crack", here);
	}
}

chase_amb_garage_start()
{
	loc = Spawn( "script_origin",(0, 0, 0));
	loc playsound ("clkw_scn_chase_garage_start");
	flag_wait("chase_punch_it");
	loc sound_fade_and_delete(1);
	music_stop(3);
	thread chase_music();
}

chase_amb_garage_punch_it()
{
	flag_wait( "chase_punch_it" );
	level.player playsound ( "clkw_scn_chase_garage_punch_it" );
	wait(1);
	thread garage_velocity_loops();
}

garage_velocity_loops()
{
	//left tunnel
	loc01 = Spawn( "script_origin",(-26797, 3359, 2079));
	loc02 = Spawn( "script_origin",(-25634, 3768, 2079));
	loc03 = Spawn( "script_origin",(-24862, 3925, 2079));
	
	//left exit
	loc04 = Spawn( "script_origin",(-24241, 3960, 2079));
	loc05 = Spawn( "script_origin",(-23679, 3949, 2079));
	loc06 = Spawn( "script_origin",(-23081, 3906, 2079));
	
	//right tunnel
	loc07 = Spawn( "script_origin",(-26787, 3027, 2079));
	loc08 = Spawn( "script_origin",(-25633, 3490, 2079));
	loc09 = Spawn( "script_origin",(-24890, 3610, 2079));
	
	//right exit
	loc10 = Spawn( "script_origin",(-24230, 3613, 2079));
	loc11 = Spawn( "script_origin",(-23864, 3693, 2079));
	loc12 = Spawn( "script_origin",(-23083, 3659, 2079));
	
	loc01 scalevolume(0.1);
	loc02 scalevolume(0.1);
	loc03 scalevolume(0.1);
	loc04 scalevolume(0.1);
	loc05 scalevolume(0.1);
	loc06 scalevolume(0.1);
	loc07 scalevolume(0.1);
	loc08 scalevolume(0.1);
	loc09 scalevolume(0.1);
	loc10 scalevolume(0.1);
	loc11 scalevolume(0.1);
	loc12 scalevolume(0.1);
	
	wait(0.05);

	loc01 playloopsound( "clkw_velocity_loop" );
	loc02 playloopsound( "clkw_velocity_loop" );
	loc03 playloopsound( "clkw_velocity_loop" );
	loc04 playloopsound( "clkw_velocity_loop" );
	loc05 playloopsound( "clkw_velocity_loop" );
	loc06 playloopsound( "clkw_velocity_loop" );
	loc07 playloopsound( "clkw_velocity_loop" );
	loc08 playloopsound( "clkw_velocity_loop" );
	loc09 playloopsound( "clkw_velocity_loop" );
	loc10 playloopsound( "clkw_velocity_loop" );
	loc11 playloopsound( "clkw_velocity_loop" );
	loc12 playloopsound( "clkw_velocity_loop" );
	
	loc01 scalevolume(1, 2);
	loc02 scalevolume(1, 2);
	loc03 scalevolume(1, 2);
	loc04 scalevolume(1, 2);
	loc05 scalevolume(1, 2);
	loc06 scalevolume(1, 2);
	loc07 scalevolume(1, 2);
	loc08 scalevolume(1, 2);
	loc09 scalevolume(1, 2);
	loc10 scalevolume(1, 2);
	loc11 scalevolume(1, 2);
	loc12 scalevolume(1, 2);
	
	flag_wait( "chase_garage_exit" );
	
	wait(3);
	
	loc01 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc02 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc03 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc04 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc05 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc06 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc07 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc08 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc09 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc10 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc11 stoploopsound( "clkw_amb_velocity_loop_light" );
	loc12 stoploopsound( "clkw_amb_velocity_loop_light" );
	
	loc01 delete();
	loc02 delete();
	loc03 delete();
	loc04 delete();
	loc05 delete();
	loc06 delete();
	loc07 delete();
	loc08 delete();
	loc09 delete();
	loc10 delete();
	loc11 delete();
	loc12 delete();
}

chase_amb_garage_pre_exit() //gets fired off at punch it moment
{
	flag_wait( "chase_punch_it" );
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.2);
	loc playloopsound( "clkw_scn_chase_garage_pre_exit" );
	wait(0.05);
	loc scaleVolume(1, 1.8);

	flag_wait( "chase_garage_exit" );

	wait(0.5);
	loc sound_fade_and_delete(1);
}

chase_amb_garage_pre_exit_skid()
{
	//flag_wait( "chase_garage_pre_exit_skid" );
	flag_wait( "chase_punch_it" );
	level.player playsound( "clkw_scn_chase_skid_player" );
	wait(0.7);
	level.player playsound("clkw_scn_chase_roadblock_smash");//temp for car to smash
	wait(0.4);
	thread play_sound_in_space("clkw_garage_hit_vehicle", (-23793, 3826, 2065 ));
	wait(0.3);
	level.player playsound ("clkw_garage_hit_body", (-23785, 3734, 2052 ));

}

chase_amb_garage_exit()
{
	flag_wait( "chase_garage_exit" );
	music_play("clkw_chase_start");
	//thread chase_roadblock_pa();
	loc = Spawn( "script_origin",(0, 0, 0));
	loc playloopsound( "clkw_scn_chase_garage_exit" );
	loc scalevolume(0.1);
	wait(0.05);
	loc scalevolume(0.891, 0.2);
	wait(2);
	loc scalevolume(0.707, 6);
	flag_wait("chase_crossroad");
	wait(1);
	loc sound_fade_and_delete(1);
}

chase_amb_crossroad()
{
	flag_wait("chase_crossroad");
	thread chase_roadblock_smash();
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.02);
	loc playloopsound( "clkw_scn_chase_crossroad" );
	loc scalevolume(1, 1);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_enter_ravine");
	wait(2);
	loc sound_fade_and_delete(1);
}

//chase_roadblock_pa()
//{
//	wait(3);
//	loc = Spawn( "script_origin",(-17496, -3985, 772));
//	loc playsound ("clockwork_mpa_theintrudersareat", "sounddone");
//	loc waittill("sounddone");
//	loc playsound ("clockwork_mpa_donotletthem", "sounddone");
//	loc waittill("sounddone");
//	loc playsound ("clockwork_mpa_stopthematall", "sounddone");
//	loc waittill("sounddone");
//	loc delete();
//}

chase_roadblock_smash()
{
		wait(0.2);
		level.player SetClientTriggerAudioZone( "chase_roadblock" );
		level.player playsound("clkw_scn_chase_roadblock_smash", "sounddone");
		thread play_sound_in_space("clkw_scn_roadblock_roll", (-18358, -3107, 381));
		wait(1);
		level.player ClearClientTriggerAudioZone( 1 );
		thread ravine_jeeps_to_the_right();
}

chase_amb_enter_ravine()
{
	flag_wait("chase_enter_ravine");
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_enter_ravine" );
	loc scalevolume(1, 0.5);
	wait(.25);
	level.player playsound("clkw_ravine_start_skid");
	wait(1);
	level.player playsound( "clkw_scn_chase_skid_player" );
	wait(3);
	flag_set("aud_start_pileup");
	//IPrintLnBold("started");
	flag_wait("chase_enter_tunnel");
	loc sound_fade_and_delete(2);
}

ravine_jeeps_to_the_right()
{
	wait(9.5);
	snd = Spawn( "script_origin",(-12520, -2842, 461));
	dst = (-8667, -4029, 461);
	snd playsound("clkw_scn_chase_jeeps_right", "sounddone");
	snd scalevolume(0.562);
	snd MoveTo(dst, 8, 4);
	snd waittill("sounddone");
	snd delete();
}

chase_amb_enter_tunnel()
{
	flag_wait("chase_enter_tunnel");
	loc = Spawn( "script_origin",(0, 0, 0));
	flag_set("aud_chase_interior");
	loc scalevolume(0.1);
	wait(0.02);
	loc playloopsound( "clkw_scn_chase_enter_tunnel" );
	loc scalevolume(1, 0.5);
	wait(4.15);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_exit_tunnel");
	loc sound_fade_and_delete(2);
}

chase_tunnel_jeep()
{
	thread snowmobiles_tunnel();
	snd = Spawn( "script_origin",(-6356, -6559, 319));
	dst = (-5572, -6555, 257);
	snd playsound("clkw_scn_chase_tunnel_jeep", "sounddone");
	snd MoveTo(dst, 1.8);
	snd waittill("sounddone");
	snd delete();
}

snowmobiles_tunnel()
{	
	wait(4);
	snd = Spawn( "script_origin",(-5741, -7607, 285));
	snd playsound("clkw_scn_chase_snowmb_tunnel", "sounddone");
	dst1 = (-5018, -8417, 285);
	dst2 = (-972, -8607, 285);
	snd MoveTo( dst1, 1.3);
	wait(1.3);
	snd MoveTo( dst2, 5);
    snd waittill("sounddone");
	snd delete();
}

chase_amb_exit_tunnel()
{
	flag_wait("chase_exit_tunnel");
	thread tunnel_exit_jeeps();
	loc = Spawn( "script_origin",(0, 0, 0));
	flag_clear("aud_chase_interior");
	loc playloopsound( "clkw_scn_chase_exit_tunnel" );
	loc scalevolume(0.1);
	wait(0.05);
	loc scalevolume(0.562, 0.2);
	wait(2.5);
	loc scalevolume(1, 3);
	wait(2);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_under_bridge_1");
	loc sound_fade_and_delete(2);
}

tunnel_exit_jeeps()
{
	snd = Spawn( "script_origin",(-472, -9053, 274));
	dst1 = (273, -8376, 274);
	dst2 = (762, -7454, 266);
	snd playsound("clkw_scn_chase_tunnel_exit_jeeps", "sounddone");
	snd MoveTo(dst1, 1.5);
	wait(1.5);
	snd MoveTo(dst2, 1.5);
	snd waittill("sounddone");
	snd delete();
}

chase_amb_under_bridge_1()
{
	flag_wait("chase_under_bridge_1");
	thread snowmobiles();
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_under_bridge_1" );
	loc scalevolume(1, 0.2);
	wait(0.05);
	loc scalevolume(0.63, 10);
	wait(5.25);
	level.player playsound( "clkw_scn_chase_skid_player" );
	wait(7.3);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_sharp_turn");
	loc sound_fade_and_delete(2);
}

snowmobiles()
{	
	if (level.bSnowmobilesStarted == false)
	{
		level.bSnowmobilesStarted = true;
		wait(1.5);
		snd = Spawn( "script_origin",(-273, -1821, 272));
		dst1 = (348, 3222, 272);
		dst2 = (3711, 2575, 272);
		snd MoveTo( dst1, 5);
		wait(1);
		snd playsound("clkw_scn_chase_snowmobiles", "sounddone");
		wait(4);
		snd MoveTo( dst2, 3);
	    snd waittill("sounddone");
		snd delete();
	}
}

bigjump()
{
	wait(0.5);
	thread play_sound_in_space("clkw_scn_chase_leftground_loud", (5365, 1031, 369));
	wait(1.2);
	thread play_sound_in_space("clkw_scn_chase_land_tires_big", (5938, 676, 252));
}

chase_amb_sharp_turn()
{
	flag_wait("chase_sharp_turn");
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_sharp_turn" );
	loc scalevolume(0.501, 0.2);
	wait(3.3);
	level.player playsound( "clkw_scn_chase_skid_player" );
	thread bridge_siren();
	wait(2.3);
	loc scalevolume(1, 2);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_under_bridge_2");
	loc sound_fade_and_delete(2);
}

bridge_siren()
{
	snd = Spawn( "script_origin",(12982, 2282, 655));
	//dst = (18438, 6501, 655);
	snd playsound("clkw_scn_chase_bridge_siren", "sounddone");
	//snd MoveTo(dst, 8);
	snd waittill("sounddone");
	snd delete();
}

chase_amb_under_bridge_2()
{
	flag_wait("chase_under_bridge_2");
	music_play("clkw_chase_bridge");
	thread bridge_jeep_by();
	thread bridge_jeeps_to_the_right();
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_under_bridge_2" );
	loc scalevolume(1, 0.2);
	wait(1);
	loc scalevolume(0.562, 2);
	wait(0.4);
	level.player playsound( "clkw_scn_chase_skid_player" );
	wait(2.2);
	level.player playsound( "clkw_scn_chase_skid_player" );
	wait(5);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_under_bridge_3");
	loc sound_fade_and_delete(2);
}

bridge_jeep_by()
{
	wait(1);
	snd = Spawn( "script_origin",(15959, 3132, 273));
	dst = (15300, 4213, 273);
	snd playsound("clkw_scn_chase_bridge_jeep_by", "sounddone");
	wait(1.25);
	snd MoveTo(dst, 0.8);
	snd waittill("sounddone");
	snd delete();
}

bridge_jeeps_to_the_right()
{
	wait(2);
	snd = Spawn( "script_origin",(14058, 4127, 273));
	dst1 = (15625, 4386, 273);
	dst2 = (18420, 6547, 273);
	dst3 = (19251, 9325, 273);
	snd playsound("clkw_scn_chase_jeeps_right", "sounddone");
	snd MoveTo(dst1, 3);
	wait(3);
	snd MoveTo(dst2, 4);
	wait(4);
	snd MoveTo(dst3, 4);
	snd waittill("sounddone");
	snd delete();
}

chase_amb_under_bridge_3()
{
	flag_wait("chase_under_bridge_3");
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_under_bridge_3" );
	loc scalevolume(1, 0.2);
	wait(1.5);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_enter_chasm");
	loc sound_fade_and_delete(2);
}
chase_amb_enter_chasm()
{
	flag_wait("chase_enter_chasm");
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_enter_chasm" );
	loc scalevolume(1, 0.2);
	flag_wait("chase_tight_spot");
	loc sound_fade_and_delete(2);
}
chase_amb_tight_spot()
{
	flag_wait("chase_tight_spot");
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_tight_spot" );
	loc scalevolume(1, 0.2);
	wait(1.6);
	level.player playsound( "clkw_scn_chase_skid_player" );
	flag_wait("chase_under_bridge_4");
	loc sound_fade_and_delete(2);
}
chase_amb_under_bridge_4()
{
	flag_wait("chase_under_bridge_4");
	thread submarine_rise();
	loc = Spawn( "script_origin",(0, 0, 0));
	loc scalevolume(0.1);
	wait(0.05);
	loc playloopsound( "clkw_scn_chase_under_bridge_4" );
	loc scalevolume(1, 0.2);
	thread dip_ambience(loc);
	flag_wait("chase_sub_comes_up");
	level.player playsound("clkw_scn_submarine_jeep_stop");
	wait(3);
	loc sound_fade_and_delete(2);
	wait(3.5);
	level.player playsound("clkw_amb_end_gusts");
}

dip_ambience(loc)
{
	wait(4.3);
	loc scaleVolume(0, 1);
	wait(4.7);
	loc scaleVolume(1, 2);
}
chase_amb_sub_comes_up()
{
	flag_wait("chase_sub_comes_up");
	thread snow_spray();
}

submarine_rise()
{
	wait(2.5);
	level.player SetClientTriggerAudioZone( "chase_sub_breach" );
	wait(1.5);
	level.player playsound ("clkw_scn_submarine_ice_chunks_02", (34247, 19655, 681));
	thread sub_breach_ice_chunks();
	wait(4.4);
	thread play_sound_in_space("clkw_scn_submarine_proto", (35697, 21236, 399));
	wait(0.6);
	level.player clearClientTriggerAudioZone( 1 );
	thread play_sound_in_space("clkw_scn_submarine_rise", (34640, 20204, 681));
	wait(1);
	thread play_sound_in_space("clkw_scn_submarine_rise_lyr2", (35228, 20734, 681));
}

sub_breach_ice_chunks()
{
	thread play_sound_in_space("clkw_scn_submarine_breach_01", (35204, 21388, 681));	
	wait(0.5);
	thread play_sound_in_space("clkw_scn_submarine_breach_02", (35200, 20415, 681));	
	wait(0.7);
	thread play_sound_in_space("clkw_scn_submarine_breach_03", (34889, 18522, 681));	
	wait(0.8);
	thread play_sound_in_space("clkw_scn_submarine_breach_04", (36476, 21402, 681));
	wait(0.3);
	thread play_sound_in_space("clkw_scn_sub_breach_boom_ly2", (34075, 19528, 681));	
	wait(0.8);
	thread play_sound_in_space("clkw_scn_submarine_breach_01", (36410, 22123, 681));	
	wait(0.5);
	thread play_sound_in_space("clkw_scn_submarine_breach_04", (34575, 20001, 826));	
	wait(0.8);
	thread play_sound_in_space("clkw_scn_submarine_breach_03", (34759, 20361, 681));
	wait(0.3);
	thread play_sound_in_space("clkw_scn_submarine_breach_01", (35986, 21630, 681));
	wait(0.3);
	thread play_sound_in_space("clkw_scn_submarine_breach_03", (34947, 20497, 681));
	wait(0.3);
	thread play_sound_in_space("clkw_scn_submarine_breach_02", (33576, 19010, 681));	
	wait(0.7);
	thread play_sound_in_space("clkw_scn_submarine_breach_04", (34003, 20768, 681));	
}

snow_spray()
{
	flag_wait("chase_sub_comes_up");
	wait(2.5);
	level.player playsound("clkw_scn_sub_breach_crack_close");
	wait(1.5);
	level.player playsound("clkw_scn_jeep_snow_spray");
}

chase_music()
{
	flag_wait("chase_sub_comes_up");
	thread end_jumpout();
	thread end_fade();
	wait(9.75);
	music_play("clkw_end");			
}


end_jumpout()
{
	wait(7.3);
	thread play_sound_in_space("clkw_scn_end_keegan_exit_jeep", (34275, 19726, 547));
	wait(0.3);
	thread play_sound_in_space("clkw_scn_end_cypher_exit_jeep", (34247, 19687, 547));
	wait(0.2);
	thread play_sound_in_space("clkw_scn_end_baker_exit_jeep", (34282, 19693, 547));
	wait(0.2);
	thread play_sound_in_space("clkw_scn_end_latch_open", (34284, 19748, 547));
	wait(0.2);
	thread play_sound_in_space("clkw_scn_end_latch_open", (34276, 19671, 547));
	wait(0.3);
	thread play_sound_in_space("clkw_scn_end_latch_open", (34252, 19670, 547));
	wait(1.5);
	level.player playsound("clkw_scn_end_jumpout");
}

end_fade()
{
	wait(10.8);
	level notify("cut_on_end");
	wait(5);
	level.player SetClientTriggerAudioZone( "end_fade" );
}

	
/#
rvn_music_dvar_thread()
{
	while (true)
	{
		rvn_check_music_dvar();
		wait(0.5);
	}
}
#/
	
/#
rvn_check_music_dvar()
{
    setdvarifuninitialized( "rvn_music", "1" );
    dvar = getdvar( "rvn_music" );
    if ( dvar == "1")
    {
        level.player SetVolMod("music", 1 );
    }
    else if ( dvar == "0" )
    {
    	music_stop(0.5);
       level.player SetVolMod("music", 0);
    }
}
#/

//create_sound_array(sound_ent, start_loc, end_loc)
//{
//    sound = [];
//    sound[ "ent" ] = sound_ent;
//    sound[ "start" ] = start_loc;
//    sound[ "end" ] = end_loc;
//    
//    return sound;
//}
//
//handle_moving_sounds(update_freq, center_loc, max_dist, sounds, flag_name)
//{
//    // keep track of last player location to only update system if player has moved
//    player_last = ( 0, 0, 0 );
//    dist = Distance(level.player.origin, center_loc);    
//    
//    while( dist <= max_dist && flag( flag_name ) )
//    {
//        dist = Distance(level.player.origin, center_loc);    
//        if ( level.player.origin != player_last )
//        {
//            foreach (sound in sounds)
//            {
//            	percent = 1 - ( dist / max_dist );
//                new_loc = VectorLerp( sound[ "start" ], sound[ "end" ], percent );
//                sound[ "ent" ] MoveTo( new_loc, 0.2 );
//            }
//        }
//        
//        player_last = level.player.origin;
//        wait( update_freq );
//    }
//    
//    if ( dist >= max_dist )
//    {
//        foreach (sound in sounds)
//        {
//            sound[ "ent" ] MoveTo( sound[ "start" ], 0.2 );
//        }
//    }
//    else
//    {
//        foreach (sound in sounds)
//        {
//            sound[ "ent" ] MoveTo( sound[ "end" ], 2 );
//        }
//    }
//    
//    flag_set( "aud_done_updating_emitter_movement" );
//}

