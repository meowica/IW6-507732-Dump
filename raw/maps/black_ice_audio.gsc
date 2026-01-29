#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;

main()
{
	audio_flag_init();
	
	sfx_black_ice_node_init();
	
	precacheshellshock( "default_nosound" );
	
	thread sfx_fire_tower_triggers();
	
	thread sfx_metal_beam_event();
	
	thread sfx_command_warning_sfx();
	
	thread sfx_derrick_expl_init();
	
	thread sfx_tanks_wind_gust_trigger();
	
	precommon_room = GetEnt( "pre_common_room", "targetname" );
	precommon_room thread precommon_sound();
	
}

audio_flag_init()
{
	flag_init( "sfx_stop_dist_oil_rig" );
	flag_init( "sfx_stop_underice_rig" );
	flag_init( "sfx_stop_blackice_alarm" );
	flag_init( "sfx_ascend_done" );
	flag_init( "sfx_rumble_ok" );
	flag_init( "sfx_stop_pa" );
	flag_init( "heli_mudpumps_in" );
	flag_init( "sfx_stop_heli_squibs" );
	flag_init( "sfx_stop_heli_shells" );
	flag_init( "sfx_lever_green" );
	flag_init( "sfx_lever_yellow" );
	flag_init( "sfx_lever_red" );
	flag_init( "sfx_warning_playing" );
	flag_init( "sfx_rumbles_playing" );
	flag_init( "minigame_practice_over" );
	flag_init( "sfx_cam_mvmt_gate" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

sfx_distant_oilrig()
{
	wait 0.1;
	underice_rig_sfx = Spawn( "script_origin", (-888, 4735, 172) );
	underice_rig_sfx PlayLoopSound("emt_blackice_underice_oilrig_lp");
	

	flag_wait("sfx_stop_underice_rig");
	
	underice_rig_sfx ScaleVolume(0.001, 2);
	
	wait 2;
	
	underice_rig_sfx delete();
	
}



sfx_distant_alarm()
{
	flag_wait( "bc_flag_alarm_start" );
	underice_alarm_sfx1 = Spawn( "script_origin", (-888, 4735, 1645) );
	underice_alarm_sfx2 = Spawn( "script_origin", (290, 3048, 1645) );
	underice_alarm_sfx3 = Spawn( "script_origin", (-1206, 4411, 1645) );
	underice_alarm_sfx1 PlayLoopSound( "emt_blackice_alarm_dist_lt_lp" );
	underice_alarm_sfx2 PlayLoopSound( "emt_blackice_alarm_dist_rt_lp" );
	underice_alarm_sfx3 PlayLoopSound( "emt_blackice_alarm_lp" );
	underice_alarm_sfx3 ScaleVolume(0.001, 0.1);
	
	while ( !flag( "flag_player_ascending" ) )
	{
		wait 0.05;
	}
	
	while ( !flag( "sfx_ascend_done" ) )
	{
		vol1 = 1.0;
		vol2 = 0.01;
		voldist = Distance( level.player.origin, (-1239, 2280, 1418) );
		if ( voldist < 1100 )
		{
			vol1 = 0.9;		
			vol2 = 0.1;		
		}
		if ( voldist < 900 )
		{
			vol1 = 0.75;		
			vol2 = 0.25;		
		}
		if ( voldist < 750 )
		{
			vol1 = 0.6;		
			vol2 = 0.4;		
		}
		if ( voldist < 600 )
		{
			vol1 = 0.45;		
			vol2 = 0.55;		
		}
		if ( voldist < 400 )
		{
			vol1 = 0.4;		
			vol2 = 0.7;		
		}
		if ( voldist < 200 )
		{
			vol1 = 0.15;		
			vol2 = 0.85;		
		}
		if ( voldist < 100 )
		{
			vol1 = 0.01;		
			vol2 = 1.0;		
		}
	underice_alarm_sfx1 ScaleVolume(vol1, 1);
	underice_alarm_sfx2 ScaleVolume(vol1, 1);
	underice_alarm_sfx3 ScaleVolume(vol2, 1);
		
		wait 1;
	}

	flag_wait("sfx_stop_blackice_alarm");
	
	wait 1;
	
	underice_alarm_sfx1 ScaleVolume(0.001, 4);
	underice_alarm_sfx2 ScaleVolume(0.001, 4);
	underice_alarm_sfx3 ScaleVolume(0.001, 4);
	
	
	wait 4;
	
	underice_alarm_sfx1 delete();
	underice_alarm_sfx2 delete();
	underice_alarm_sfx3 delete();
	
}

sfx_fire_tower_spawn()
{
	
	//spawning all the looped fire tower and metal creacking sounds defined in sfx_black_ice_node_init()
	for( i=0; i<10; i++)
	{
		level.sfx_black_ice_nodes[i] playloopsound( level.sfx_black_ice_nodes[i].soundalias );
	}
	
}

sfx_flare_stack_burn()
{
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_flarestack_int", 1 );
	
	//level waittill( "flag_flarestack_scene_start" );
	//wait 1.5;
		
	level waittill( "notify_dialogue_baker_enter_complete" );
	wait 1.5;
	
	//IPrintLnBold("Starting burning");
	
	//Spawn the amb emitters in the room - computers, etc
	thread sfx_flare_stack_amb_emt();
	
	// Start Flare Stack burning sfx loop
	flare_stack_burn_01 = Spawn( "script_origin", (-4745, 3844, 1950) );
	flare_stack_burn_01 PlayLoopSound("emt_blackice_flarestack_burn_lp");
	
	// Wait for button press then play stop sound and fade out/delete loop
	level waittill( "notify_flare_stack_button_press" );
	
	thread sfx_flare_stack_shutdown();
	
	flare_stack_burn_01 ScaleVolume(0.001, 1);
	wait 2;
	flare_stack_burn_01 delete();
}

sfx_flare_stack_amb_emt()
{
	wait 0.1;
	flare_stack_emt_server = Spawn( "script_origin", (-3533, 4322, 1931) );
	flare_stack_emt_server PlayLoopSound("emt_blackice_server_hum_lp");
	
	flare_stack_emt_console_01 = Spawn( "script_origin", (-3573, 4378, 1928) );
	flare_stack_emt_console_01 PlayLoopSound("emt_blackice_computer_hum_01_lp");
	
	flare_stack_emt_console_02 = Spawn( "script_origin", (-3577, 4452, 1928) );
	flare_stack_emt_console_02 PlayLoopSound("emt_blackice_computer_hum_02_lp");
	
	flare_stack_emt_relays = Spawn( "script_origin", (-3577, 4470, 1928) );
	flare_stack_emt_relays PlayLoopSound("emt_blackice_relay_clicks_lp");
	
	flare_stack_emt_computer_01 = Spawn( "script_origin", (-3394, 4626, 1926) );
	flare_stack_emt_computer_01 PlayLoopSound("emt_blackice_server_hum_lp");
	
	flare_stack_emt_computer_02 = Spawn( "script_origin", (-3573, 4587, 1921) );
	flare_stack_emt_computer_02 PlayLoopSound("emt_blackice_computer_hum_01_lp");
	
	flare_stack_emt_tv_static = Spawn( "script_origin", (-3585, 4579, 1986) );
	flare_stack_emt_tv_static PlayLoopSound("emt_blackice_tv_static_lp");
	
	flare_stack_emt_window_wind = Spawn( "script_origin", (-3585, 4428, 1966) );
	flare_stack_emt_window_wind PlayLoopSound("emt_blackice_int_wind_lp");
	
	flare_stack_light_buzz_01 = Spawn( "script_origin", (-3394, 4408, 2003) );
	flare_stack_light_buzz_01 PlayLoopSound("emt_light_fluorescent_hum3_int");
	
	flare_stack_light_buzz_02 = Spawn( "script_origin", (-3492, 4408, 2003) );
	flare_stack_light_buzz_02 PlayLoopSound("emt_light_fluorescent_hum3_int");
	
	flare_stack_light_buzz_03 = Spawn( "script_origin", (-3396, 4579, 2003) );
	flare_stack_light_buzz_03 PlayLoopSound("emt_light_fluorescent_hum2_int");
	
	flare_stack_light_buzz_04 = Spawn( "script_origin", (-3490, 4578, 2003) );
	flare_stack_light_buzz_04 PlayLoopSound("emt_light_fluorescent_hum3_int");
	
	level waittill( "notify_flare_stack_button_press" );
	wait 0.1;
	flare_stack_emt_relays delete();
	
	level waittill( "notify_refinery_explosion_start" );
	wait 1;
	
	flare_stack_emt_server delete();
	flare_stack_emt_console_01 delete();
	flare_stack_emt_console_02 delete();
	flare_stack_emt_computer_01 delete();
	flare_stack_emt_computer_02 delete();
	flare_stack_emt_tv_static delete();
	flare_stack_emt_window_wind delete();
	flare_stack_light_buzz_01 delete();
	flare_stack_light_buzz_02 delete();
	flare_stack_light_buzz_03 delete();
	flare_stack_light_buzz_04 delete();
}

sfx_flare_stack_shutdown()
{
	wait 0.1;
	
	flare_stack_burn_02 = Spawn( "script_origin", (-4740, 3840, 1945) );
	flare_stack_burn_02 PlaySound("emt_blackice_flarestack_turnoff_ss");
	
	thread sfx_flare_stack_arm_expl();
	
	wait 7;
	flare_stack_burn_02 delete();
}

sfx_flare_stack_arm_expl()
{
	wait 1.4;
	//IPrintLnBold("WRONK");
	level.player PlaySound("scn_blackice_flarestack_pipe_stress");
	
	wait 0.1;
	thread play_sound_in_space( "scn_blackice_flarestack_mtl_arm", (-4496, 3815, 1842) );
}

sfx_camera_intro()
{
	wait 0.2;
	level.player PlaySound("scn_blackice_intro_lr");
	thread sfx_intro_sweeteners();
	wait 25;
	level.player SetClientTriggerAudioZone( "blackice_underwater", 2 );
}

sfx_camera_mvmt()
{
	if (!flag("sfx_cam_mvmt_gate"))
	{
		//IPrintLnBold("cam mvmt sfx");
		flag_set("sfx_cam_mvmt_gate");
		level.player PlaySound("scn_blackice_intro_cam_mvmt");
		wait 0.3;
		flag_clear("sfx_cam_mvmt_gate");
	}
}

sfx_breach_plant_charges()
{
	//wait 6.35;
	//level.player PlaySound("scn_blackice_intro");
}

sfx_breach_detonate()
{
	wait 0.3;
	level.player playsound("scn_blackice_infil_expl_charges");
	level.player ClearClientTriggerAudioZone( 2 );
}

sfx_intro_sweeteners()
{
	wait 13;
	level.player PlaySound("scn_blackice_intro_snowmobiles_swt");
	wait 2;
	level.player PlaySound("scn_blackice_intro_hummer_swt");
}

sfx_hummer_over()
{
	//wait 15;
	//level.player playsound("scn_blackice_hummer_over_lr");
}

sfx_player_exits_water()
{
	level.player playsound( "scn_blackice_water_emerge_ss" );
	level.player playsound( "elm_blackice_windgust" );
	wait 2;	
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_outside", 2 );
}

sfx_heli_over()
{
	waittillframeend;
	level.player playsound("scn_blackice_heli_flyover_lr");
}

sfx_hangardoor_amb()
{
	wait 0.2;
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_open_door", 1 );
}

sfx_distant_oil_rig()
{
	// Main node on far left (closest side)
	oil_rig_node_01 = Spawn( "script_origin", (-1679, 2928, 500) );
	oil_rig_node_01 PlayLoopSound("emt_oil_rig_dist_lp");
	
	// Fade out and stop / cleanup
	flag_wait("sfx_stop_dist_oil_rig");
	
	//IPrintLnBold("Stopping oil rig sfx");
	
	oil_rig_node_01 ScaleVolume(0.001, 10);
	
	wait 10;
	
	oil_rig_node_01 delete();
}

sfx_stop_dist_oil_rig()
{
	flag_set("sfx_stop_dist_oil_rig");
}

sfx_blackice_door_rollup( door )
{
	door PlaySound( "scn_blackice_door_rollup" );
}

sfx_blackice_helo_flyby()
{
	//IPrintLnBold("JL: Helo Audio By Start");
	self playsound("scn_blackice_heli_camp_flyover");
}

sfx_blackice_rig_start_ss()
{
	level.player playsound( "scn_blackice_rig_start_ss" );
}

sfx_blackice_rig_start2_ss()
{
	level.player playsound( "scn_blackice_rig_start2_ss" );
}

sfx_blackice_rig_start3_ss()
{
	wait 0.3;
	level.player playsound( "scn_blackice_rig_start3_ss" );
}
sfx_stop_ascent_sounds()
{
	level.player playsound( "scn_blackice_rig_end_ss" );
	wait 0.2;
	level.sfx_ascend_node stopsounds();
	wait 0.1;
	level.sfx_ascend_node delete();
}

sfx_rig_ascend_logic( check )
{
	if ( !IsDefined( level.sfx_ascend_node ) )
		return;
	
	if( (check == "go") && (check != level.sfx_ascend_check) )
	{
		level.sfx_ascend_check = check;
		level.sfx_ascend_node stopsounds();
		level.sfx_ascend_node ScaleVolume( 1, 0 );
		level.sfx_ascend_node playsound( "scn_blackice_rig_ascend_ss" );
	}
	else if( (check == "stop") && (check != level.sfx_ascend_check) )
	{
		level.sfx_ascend_check = check;
		level.player playsound( "scn_blackice_rig_stop_ss" );
		thread sfx_stop_ascend_sound_wait( 0.5 );
	}	
}

sfx_stop_ascend_sound_wait( sfx_rig_time )
{
	level.sfx_ascend_node ScaleVolume( 0, (sfx_rig_time - 0.1) );
	wait 0.1;
	if( level.sfx_ascend_check == "stop" )
	{
		level.sfx_ascend_node stopsounds();
	}
}

sfx_cargo_sway()
{
	cargo_sway = Spawn( "script_origin", (-1546, 2479, 1276) );
	cargo_sway PlayloopSound("emt_blackice_cargo_sway");
	
	level waittill( "notify_damage_breacher" );
	cargo_sway delete();
}

sfx_cw_door_open(door)
{
	door PlaySound("scn_blackice_catwalk_mtl_door");
}

sfx_catwalk_guy_over_railing()
{
	wait 0.8;
	self playsound("scn_blackice_catwalk_guy_over_rail");
}

sfx_exited_flarestack()
{
	flag_set("sfx_rumble_ok");
}

sfx_black_ice_node_init()
{
	level.sfx_black_ice_nodes = [];
	level.sfx_fire_tower_lookat_flag = 0;
	level.sfx_fire_tower_lookat_section = 0;
	//fire tower section of nodes (metal creeking sounds and fire tower sounds)
	sfx_node_array_init( (1367, 3969, 3367), "emt_fire_tower_dist_lp", 0 );
	sfx_node_array_init( (1367, 3977, 2460), "emt_fire_tower_close_lp", 1 );
	sfx_node_array_init( (1367, 3977, 2460), "emt_fire_tower_close2_lp", 2 );
	sfx_node_array_init( (1106, 3239, 2732), "emt_fire_tower_metal_dist_lp", 3 );
	sfx_node_array_init( (1468, 3386, 3099), "emt_fire_tower_metal_med_lp", 4 );
	sfx_node_array_init( (1143, 4491, 2712), "emt_fire_tower_metal_med2_lp", 5 );
	sfx_node_array_init( (1877, 2785, 2426), "emt_fire_tower_metal_close_01_lp", 6 );
	sfx_node_array_init( (1740, 2514, 2492), "emt_fire_tower_metal_close_02_lp", 7 );
	sfx_node_array_init( (1536, 2261, 2416), "emt_fire_tower_metal_close_03_lp", 8 );
	sfx_node_array_init( (1415, 3054, 2457), "emt_fire_tower_metal_close_04_lp", 9 );
	
	//fire suppression section of nodes (nodes played ruing the room of death, playing alarm sounds
	//TimS - fire suppression removed
	sfx_node_array_init( (-1185, 4836, 2212), "null", 10 );
	sfx_node_array_init( (-1185, 3785, 2212), "null", 11 );
	//sfx_node_array_init( (-1185, 4836, 2212), "emt_fire_suppress_alarm_ss", 10 );
	//sfx_node_array_init( (-1185, 3785, 2212), "emt_fire_suppress_alarm_ss", 11 );
	//this is temp and will be used once we can fix the volume issues in the death room
	//right now it's just super loud and I had to play this sound on the player, will
	//fix this once we redo the death room explosions
	//sfx_node_array_init( (-770, 4443, 2262), "emt_fire_suppress_ss", 5 );
	
	//these are the nodes for the lookat logic for the flame tower once you get up close
	sfx_node_array_init( (1367, 3969, 3367), "emt_fire_tower_disteye_lp", 12 );
	sfx_node_array_init( (1367, 3977, 2683), "emt_fire_tower_closeeye_lp", 13 );
	sfx_node_array_init( (1367, 3977, 2683), "emt_fire_tower_close2eye_lp", 14 );
	sfx_node_array_init( (1367, 3977, 2683), "emt_fire_tower_closehigheye_lp", 15 );
	
}

sfx_node_array_init( org, sound, ref )
{
	//this script is called from sfx_black_ice_node_init(), and it
	//initializes all the nodes into structures for later reference
	object = spawn( "script_origin", org );
	object.soundalias = sound;
	object.refnum = ref;
	level.sfx_black_ice_nodes[level.sfx_black_ice_nodes.size] = object;
}

sfx_play_suppression_sounds()
{
	
	//plays the fire suppress sounds and plays the alarm sounds defined in sfx_black_ice_node_init()
	if( !IsDefined( level.sound_water_suppression ) )
	{
		level.sound_water_suppression = 1;
		//TimS - this is cut, removing
		//level.player playsound( "emt_fire_suppress_ss" );
		//for( i=10; i<12; i++ )
		//{
		//	level.sfx_black_ice_nodes[i] playsound( level.sfx_black_ice_nodes[i].soundalias );
		//}
	}
	
}

sfx_fire_tower_triggers()
{	
	
	level.sfx_fire_tower_trigger_array = [];
	
	//this script initializes all the trigger boxes used throughout the level to basically mix everything,
	//used this while mix presets weren't working, so will have to go back and look at this to see
	//if we want to keep it, this also will set the filter we want to use as well since we aren't
	//actually using the ambience system to make these changes
	
	//The volumes correspond directly to the nodes called in sfx_black_ice_node_init()
	//so if we have 0, 0, 1, that means emt_fire_tower_dist_lp=0, emt_fire_tower_close_lp=0,
	//and emt_fire_tower_close2_lp=1
	
	//trigger box at top of platform after tower explodes
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_1", 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, "blackice_oil_rain_ext" );
	//trigger box as you enter the enclosed area at that same platform before you go into the stairs
	//and enter into the death room
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_2", 0.6, 0, 0, 0.6, 0.6, 0, 0, 0, 0, 0, "blackice_oil_rain_ext" );
	//trigger box at the entrance to the death room (only used for backtracking)
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_3", 0.6, 0, 0, 0.6, 0.6, 0, 0, 0, 0, 0, "blackice_oil_rain_ext" );
	//trigger box as you enter the death room
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_4", 0.2, 0, 0, 0.2, 0.2, 0, 0, 0, 0, 0, "blackice_oil_rain_int" );
	//trigger box at the exit of the death room (only used for backtracking)
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_5", 0.2, 0, 0, 0.2, 0.2, 0, 0, 0, 0, 0, "blackice_oil_rain_int" );
	//trigger box as you exit the death room into the exterior
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_6", 0.8, 0.8, 0, 0, 1, 1, 0, 0, 0, 0, "blackice_oil_rain_ext" );
	//trigger box at the entrance to the tank room (again, only for back tracking)
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_7", 0.8, 0.8, 0, 0, 1, 1, 0, 0, 0, 0, "blackice_oil_rain_ext" );
	//trigger box as you enter the tank room interior
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_8", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "blackice_oil_rain_int", 0 );
	//trigger box at the exit door of the tank room (again, only for back tracking)
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_9", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "blackice_oil_rain_int", 0 );
	//trigger box when you leave the tank room and see all the destroyed oil rig
        sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_10", 0, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, "blackice_oil_rain_ext", 1 );
	//trigger box at the entrance of the comms tower (again, only for back tracking)
        sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_11", 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, "blackice_oil_rain_ext", 2 );
	//trigger box as you enter the comms tower interior
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_12", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "blackice_oil_rain_int", 0 );
	//trigger box at the door of the upper comms room (backtracking)
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_13", 0, 0, 0, 0.4, 0.4, 0.4, 0, 0, 0, 0, "blackice_oil_rain_int", 2 );
	//trigger box after you enter the upper comms room
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_14", 0, 0, 0, 0.7, 0.7, 0, 0, 0, 0, 0, "blackice_oil_rain_ext", 3 );
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_15", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "blackice_oil_rain_ext", 2 );
	sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_16", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "blackice_oil_rain_ext", 2 );
	
	//these are all copies of triggers 11 and 12, just going from outside to inside at the command center
	//sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_17", 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, "blackice_oil_rain_ext", 2 );
	//trigger box as you enter the comms tower interior
	//sfx_fire_tower_triggers_init( "sfx_fire_tower_trigger_18", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "blackice_oil_rain_int", 0 );
	
	spawner = [];
	
	//spawning all the scripts that will look for when the player get inside of the trigger boxes
	for(i=0; i<level.sfx_fire_tower_trigger_array.size; i++)
	{
		spawner[i] = GetEnt( level.sfx_fire_tower_trigger_array[i].trig, "targetname" );
		spawner[i] thread sfx_fire_tower_trigger_logic( i );		
	}
}

sfx_fire_tower_triggers_init( trig, vol0, vol1, vol2, vol3, vol4, vol5, vol6, vol7, vol8, vol9, filtering, lookatnum )
{
	//initializing all the trigger boxes and volume/filter given from sfx_fire_tower_triggers()
	object = SpawnStruct();
	object.trig = trig;
	object.vol = [];
	//volume of node 0 = emt_fire_tower_dist_lp, keeps in order from sfx_black_ice_node_init
	object.vol[0] = vol0;
	object.vol[1] = vol1;
	object.vol[2] = vol2;
	object.vol[3] = vol3;
	object.vol[4] = vol4;
	object.vol[5] = vol5;
	object.vol[6] = vol6;
	object.vol[7] = vol7;
	object.vol[8] = vol8;
	object.vol[9] = vol9;
	object.filter = filtering;
	//if we want to go into the lookat logic
	if( IsDefined(lookatnum) )
	{
		object.lookatnum = lookatnum;		
	}
	else
	{
		object.lookatnum = 0;	
	}
	level.sfx_fire_tower_trigger_array[level.sfx_fire_tower_trigger_array.size] = object;	
}

sfx_fire_tower_trigger_logic( spawned_trigger, onlyonce )
{
	//if onlyonce is defined, that means we want to skip the waiting on a trigger
	//and go ahead and set the volume and filter settings, this is used for
	//jumping around to different sections of the level
	if( !IsDefined( onlyonce ) )
	{
		self waittill( "trigger" );
	}
	
		//going through all the nodes and scaling the values depending on the variables defined in sfx_fire_tower_triggers_init()
		if( spawned_trigger < 8 )
		{
			//this is for the first part of the level, before you are really close to the fire tower
			/*
			for(i=0; i<10; i++)
			{
				//IPrintLnBold( "i = " + i );
				if ( isDefined( level.sfx_black_ice_nodes[i] ) )
				{ 
						level.sfx_black_ice_nodes[i] ScaleVolume( level.sfx_fire_tower_trigger_array[spawned_trigger].vol[i] );
						//if( i<3 )
						//{
							//IPrintLnBold( "here: " + level.sfx_fire_tower_trigger_array[spawned_trigger].vol[i] );
						//}
				}
			}*/
			
		}
		else
		{
			//changing the lookat section
			level.sfx_fire_tower_lookat_section = level.sfx_fire_tower_trigger_array[spawned_trigger].lookatnum;
			//for(i=3; i<10; i++)
			{
				//if ( isDefined( level.sfx_black_ice_nodes[i] ) )
				//{
					//level.sfx_black_ice_nodes[i] ScaleVolume( level.sfx_fire_tower_trigger_array[spawned_trigger].vol[i], 1.8 );
				//}
			//}
			//only called once when you exit the tank room
			if( level.sfx_fire_tower_lookat_flag == 0 )
			{
				level.sfx_fire_tower_lookat_flag = 1;
				thread sfx_fire_tower_lookat( spawned_trigger );
				thread sfx_kill_other_fire_nodes();
			}
			//if we are indoors and in the lookat sections, we want to just lower the volume
			//and not have the lookup logic working
			/*
			if ( level.sfx_fire_tower_trigger_array[spawned_trigger].lookatnum > 0 )
			{
				j = 12;
				for(i=0; i<3; i++)
				{	
					level.sfx_black_ice_nodes[j] ScaleVolume( level.sfx_fire_tower_trigger_array[spawned_trigger].vol[i], 1 );
					j = j + 1;
				}
			}*/
		}
		}
		//thread set_filter( level.sfx_fire_tower_trigger_array[spawned_trigger].filter );
		//these are trigger multiples, so we want to wait until the player has gotten off a trigger
		//and then gotten back on it before we do anything logic, otherwise this would be called
		//a million times if the player just happened to stand on the trigger box forever
	if( !IsDefined( onlyonce ) )
	{
		while( level.player istouching( self ) )
	   	{
	    	wait 0.1;                   
	   	}
		self thread sfx_fire_tower_trigger_logic( spawned_trigger );
	}
}

sfx_generic_node_delete( beginningnode, endingnode )
{
	//generic script to delete a node or multiple nodes, just have to
	//specify the node or range of nodes to kill
	if( !IsDefined(endingnode) )
	{
		if( IsDefined(level.sfx_black_ice_nodes[beginningnode]) )
		{
		   level.sfx_black_ice_nodes[beginningnode] delete();
		}
	}
	else
	{
		for(i=beginningnode;i<(endingnode+1); i++)
		{
			if( IsDefined(level.sfx_black_ice_nodes[i]) )
			{
				level.sfx_black_ice_nodes[i] delete();
			}
		}
	}
}

hall_search_music()
{
	// flag_wait( "flag_barracks_sweep_2" ); // BMcD NOTE: Flag no longer esists (moved start to when allies move)
	wait 0.2;
		//music_play( "mus_blackice_hallsearch_start_ss" );
	
}

sfx_metal_beam_event()
{
	trigger = GetEnt( "audio_metal_beam_event", "script_noteworthy" );
	trigger_beam = GetEnt( "audio_metal_beam_event_move", "script_noteworthy" );
	trigger waittill( "trigger" );
	
	delaythread( 0.01, ::play_sound_in_space, "emt_metal_beam_settle_rumble_ss", ( 1787, 2822, 2370 ) );

	delaythread( 1.2, ::play_sound_in_space, "emt_metal_beam_settle_01_ss", ( 1689, 2800, 2316 ) );

	delaythread( 4.4, ::play_sound_in_space, "emt_metal_beam_settle_02_ss", ( 2442, 2855, 2316 ) );
	
	trigger_beam waittill( "trigger" );
	//delaythread( 0.01, ::play_sound_in_space, "emt_metal_beam_settle_rumble_2_ss", ( 1787, 2822, 2365 ) );
	delaythread( 0.5, ::play_sound_in_space, "emt_metal_beam_settle_trigger_ss", ( 1787, 2822, 2370 ) );

}

sfx_kill_other_fire_nodes()
{
	for( i=0; i<3; i++)
	{
		if ( isDefined( level.sfx_black_ice_nodes[i] ) )
		{
			level.sfx_black_ice_nodes[i] ScaleVolume(0, 1);
		}
	}
	wait 1.01;
	for( i=0; i<3; i++ )
	{
		level.sfx_black_ice_nodes[i] stopsounds();
	}
	sfx_generic_node_delete( 0, 2 );
}

sfx_fire_tower_lookat( spawned_trigger )
{
	self endon( "death" );
	level endon( "flag_stop_fire_tower_sfx_logic" );
	firsttime = 1;

	//only happens once, just shooting off the new aliases for the lookat logic
	for( i=12; i<16; i++)
	{
		level.sfx_black_ice_nodes[i] playloopsound( level.sfx_black_ice_nodes[i].soundalias );
		level.sfx_black_ice_nodes[i] ScaleVolume(0, 0.01);
		wait .01;
	}

	wait 0.3;
	
	for( i=12; i<16; i++)
	{
		level.sfx_black_ice_nodes[i] playloopsound( level.sfx_black_ice_nodes[i].soundalias );
		level.sfx_black_ice_nodes[i] ScaleVolume(.5, 0.3);
		//wait .01;
	}
	
	wait 0.3;
	
	while(1)
	{
		//wait .5;
		
		waittillframeend;		
		//first section right after the tanks room
		
		if( level.sfx_fire_tower_lookat_section == 0 )
		{
			for( i=12; i<16; i++ )
			{
				level.sfx_black_ice_nodes[i] ScaleVolume(0, 1);		
			}
			wait 1;
		}
		
		if( level.sfx_fire_tower_lookat_section == 1 )
		{
			if ( within_fov_of_players( level.sfx_black_ice_nodes[12].origin, 0.7 ) )
			{
				//IPrintLnBold( "within fov 1" );
				for( i=12; i<16; i++)
				{
					level.sfx_black_ice_nodes[i] ScaleVolume(0.9, 0.35);
				}
				wait 0.35;
			}
			
			else
			{
				//IPrintLnBold( "not within fov 1" );
				for( i=12; i<16; i++)
				{
					level.sfx_black_ice_nodes[i] ScaleVolume(0.4, 1.5);
				}
				//level.sfx_black_ice_nodes[14] ScaleVolume(0.4, 1.5);
				wait 1.5;
 			}
		}
		//second section when you fight right next to the flame tower
		
		else if( level.sfx_fire_tower_lookat_section == 2 )
		{
			
			//if( firsttime == 1 )
			//{
				//firsttime = 0;
				//IPrintLnBold( "going into second section" );
				for( i=12; i<16; i++)
				{
					level.sfx_black_ice_nodes[i] ScaleVolume(0.9, 1.5);
					//wait .45;
				}
				wait 1.5;				
			//}
			//else
			//{
			//	wait 1.5;	
			//}
			/*
			if ( within_fov_of_players( level.sfx_black_ice_nodes[13].origin, 0.65 ) )
			{
				for( i=12; i<15; i++)
				{
					level.sfx_black_ice_nodes[i] ScaleVolume(1, 0.45);
				}
				wait 0.45;
			}
			else
			{
				for( i=12; i<14; i++)
				{
					level.sfx_black_ice_nodes[i] ScaleVolume(0.6, 1.5);
				}
				level.sfx_black_ice_nodes[14] ScaleVolume(0.6, 1.5);
				wait 1.5;
 			}
						
		}
		//this is used when indoors and we don't want to use lookup logic
		else
		{
			

			j = 12;
			for(i=0; i<3; i++)
			{	
				level.sfx_black_ice_nodes[j] ScaleVolume( 0.2, .8 );
				j = j + 1;
			}

			wait .8;*/
		}
		else if( level.sfx_fire_tower_lookat_section == 3 )
		{
			if ( within_fov_of_players( level.sfx_black_ice_nodes[12].origin, 0.5 ) )
			{
				//IPrintLnBold( "within fov 1" );
				for( i=12; i<16; i++)
				{
					level.sfx_black_ice_nodes[i] ScaleVolume(0.7, 0.35);
				}
				wait 0.35;
			}
			
			else
			{
				//IPrintLnBold( "not within fov 1" );
				for( i=12; i<16; i++)
				{
					level.sfx_black_ice_nodes[i] ScaleVolume(0.5, 1.5);
				}
				//level.sfx_black_ice_nodes[14] ScaleVolume(0.6, 1.5);
				wait 1.5;
 			}			
		}
		else
		{
			wait 1.5;	
		}
	}
}

sfx_spawn_refinery_fire_nodes()
{
	wait 5;
	level.refinery_fire_01 = Spawn( "script_origin", (-2217, 3667, 2320) );
	level.refinery_fire_01 Playloopsound("emt_blackice_fire_huge_lp");
	level.refinery_fire_02 = Spawn( "script_origin", (-2270, 3637, 2284) );
	level.refinery_fire_02 Playloopsound("emt_blackice_fire_med_lp");
	level.refinery_fire_03 = Spawn( "script_origin", (-2755, 3896, 2284) );
	level.refinery_fire_03 Playloopsound("emt_blackice_fire_sm_lp");
	level.refinery_fire_04 = Spawn( "script_origin", (-2899, 3711, 2284) );
	level.refinery_fire_04 Playloopsound("emt_blackice_fire_sm_lp");		
}

sfx_delete_refinery_fire_nodes()
{
	wait 1;
	
	if ( IsDefined(level.refinery_fire_01) )
	{
		//IPrintLnBold("Deleting refinery fire sfx");
		level.refinery_fire_01 StopLoopSound();
		level.refinery_fire_02 StopLoopSound();
		level.refinery_fire_03 StopLoopSound();
		level.refinery_fire_04 StopLoopSound();
		
		wait 0.1;
		level.refinery_fire_01 delete();
		level.refinery_fire_02 delete();
		level.refinery_fire_03 delete();
		level.refinery_fire_04 delete();
	}
}

sfx_start_flarestack_room_siren()
{
	wait 0.2;
	level.flarestack_siren = Spawn( "script_origin", (-3392, 4306, 1963) );
	level.flarestack_siren PlayLoopSound("emt_blackice_flarestack_alarm_02_lp");
}

sfx_flarestack_door_open()
{
	wait 2.9;
	//IPrintLnBold("Open door sfx");
	level.flarestack_door = Spawn( "script_origin", (-3438, 4200, 1948) );
	level.flarestack_door PlaySound("scn_blackice_flarestack_door_open");
}

sfx_spawn_refinery_alarm_node()
{
	wait 6;
	level.refinery_alarm_dist = Spawn( "script_origin", (-2206, 4286, 2352) );
	level.refinery_alarm_dist Playloopsound("emt_blackice_flarestack_alarm_05_lp");		
}

sfx_delete_refinery_alarm_node()
{
	wait 2;
	
	if ( IsDefined(level.refinery_alarm_dist) )
	{
		//IPrintLnBold("Deleting alarm/panic nodes");
		level.refinery_alarm_dist StopLoopSound();
		level.rus_panic_lp StopLoopSound();
		
		wait 0.1;
		level.refinery_alarm_dist delete();
		level.rus_panic_lp delete();
	}
	
	sfx_stop_pa_bursts();
	
}

sfx_russian_panic_dx()
{
	wait 0.1;
	//thread play_sound_in_space( "scn_blackice_walla_panic_os", (-2683, 3703, 2284) );
	level.rus_panic_os = Spawn( "script_origin", (-2683, 3703, 2284) );
	level.rus_panic_os PlaySound("scn_blackice_walla_panic_os");
	wait 0.2;
	thread play_sound_in_space( "scn_blackice_walla_panic_convo", (-2723, 3852, 2284) );
	//level.rus_convo = Spawn( "script_origin",  (-2723, 3852, 2284) );
	//level.rus_convo PlaySound("scn_blackice_walla_panic_convo");
	wait 6;
	level.rus_panic_os ScaleVolume(0.0, 5);
	wait 4;
	level.rus_panic_lp = Spawn( "script_origin", (-1800, 3648, 2284) );
	level.rus_panic_lp PlayLoopSound("scn_blackice_walla_panic_lp");
	wait 3;
	level.rus_panic_os delete();
}

sfx_stop_pa_bursts()
{
	flag_set("sfx_stop_pa");
}

sfx_pa_bursts()
{
	wait 12;
	
	level.pa_bursts = spawn( "script_origin", (-2170, 4050, 2480) );
	
	while( !flag("sfx_stop_pa") )
	{
		level.pa_bursts PlaySound("emt_blackice_pa_burst");
		wait RandomFloatRange(5.0, 9.0);
	}

	level.pa_bursts delete();
}

sfx_long_pipe_bursts()
{
	//wait 0.4;
	wait 1.1;
	//IPrintLnBold("Pipe Burst Start");
	pipe_exploding = Spawn( "script_origin", (-2372, 3402, 2725) );
	pipe_exploding PlaySound("scn_blackice_long_pipe_bursts");
	thread sfx_play_pipe_sounds();
	
	thread sfx_scale_lowend_volume_derrick();
	pipe_exploding scalevolume( 0.5, 6 );
	//level.player PlaySound("scn_blackice_long_pipe_bursts");
}

sfx_scale_lowend_volume_derrick()
{
	wait 2;
	level.flarestack_pressurelp_01 scalevolume( 0, 3 );
}

sfx_play_pipe_sounds()
{	
	pipe_groan = Spawn( "script_origin", (-2372, 3402, 2725) );
	pipe_groan PlaySound("scn_blackice_flarestack_pipe_stress2");
	pipe_groan scalevolume( 0, 4 );
}
audio_derrick_explode_logic( todo )
{
	
	if ( todo == "start" )
	{
		wait 2.5;
		level.flarestack_pressurelp_01 = Spawn( "script_origin", (-2372, 3402, 2725) );
		level.flarestack_pressurelp_01 Playloopsound("scn_blackice_flarestack_pressure_01_lp");
		level.flarestack_pressurelp_02 = Spawn( "script_origin", (-2300, 5516, 2725) );
		level.flarestack_pressurelp_02 Playloopsound("scn_blackice_flarestack_pressure_02_lp");
		
		// Do a little fade up
		/*
		level.flarestack_pressurelp_01 ScaleVolume(0.001, 0.001);
		level.flarestack_pressurelp_02 ScaleVolume(0.001, 0.001);
    	wait 0.01;
   		level.flarestack_pressurelp_01 ScaleVolume(1.0, 2);
   		level.flarestack_pressurelp_02 ScaleVolume(1.0, 2);
   		*/
  		
   		wait 0.1;
   		thread sfx_stereo_quake();
   		
   		// Play some alarm sounds
   		wait 1.3;
		level.flarestack_alarm_01 = Spawn( "script_origin", (-3365, 3372, 2148) );
		level.flarestack_alarm_01 PlayLoopSound("emt_blackice_flarestack_alarm_01_lp");
		//level.flarestack_alarm_02 = Spawn( "script_origin", (-2330, 4348, 1959) );
		//level.flarestack_alarm_02 PlayLoopSound("emt_blackice_flarestack_alarm_02_lp");
		
		level.flarestack_alarm_01 ScaleVolume(0.001, 0.001);
		//level.flarestack_alarm_02 ScaleVolume(0.001, 0.001);
    	wait 0.01;
   		level.flarestack_alarm_01 ScaleVolume(1.0, 4);
   		//level.flarestack_alarm_02 ScaleVolume(1.0, 4);
	}
	else
	{
		thread derrick_pop_and_explode();
		thread sfx_derrick_mix_change();
		thread play_sound_in_space( "scn_blackice_derrick_exp5_ss", (643, 3873, 3294) );
		thread sfx_spawn_refinery_fire_nodes();
		thread sfx_spawn_refinery_alarm_node();
		wait 0.2;
		level.flarestack_alarm_01 stopLoopSound();
		//level.flarestack_alarm_02 stopLoopSound();
		level.flarestack_pressurelp_01 stoploopsound();
		level.flarestack_pressurelp_02 stoploopsound();
		
		// <BMarv> If player uses Refinery checkpoint, this won't exist
		if( IsDefined( level.flarestack_quake_lp_01 ))
			level.flarestack_quake_lp_01 stoploopsound();
		
		wait 0.1;
		level.flarestack_alarm_01 delete();
		//level.flarestack_alarm_02 delete();
		level.flarestack_pressurelp_01 delete();
		level.flarestack_pressurelp_02 delete();
		
		// <BMarv> If player uses Refinery checkpoint, this won't exist
		if( IsDefined( level.flarestack_quake_lp_01 ))
			level.flarestack_quake_lp_01 delete(); 
		
		thread maps\black_ice_audio::sfx_playing_fire_tower_sounds();
		
		wait 4.1;
		thread play_sound_in_space( "scn_blackice_drk_explo_debris01", (-2781, 3665, 2284) );
				thread play_sound_in_space( "scn_blackice_drk_explo_debris01", (-2781, 3665, 2284) );
		wait 0.2;
		thread play_sound_in_space( "scn_blackice_drk_explo_debris02", (-2600, 3909, 2284) );
	}
	
}

derrick_pop_and_explode()
{

	thread sfx_other_derrick_explosions();
	wait 0.1;
	thread play_sound_in_space( "scn_blackice_derrick_exp_pop_ss", (643, 3873, 3294) );
	
}

sfx_other_derrick_explosions()
{
	level.player playsound( "scn_blackice_derrick_exp_ss" );
	wait 1.5;
	level.player playsound( "scn_blackice_derrick_exp2_ss" );		
}

sfx_blackice_derrick_exp4_ss()
{
	thread play_sound_in_space( "scn_blackice_derrick_exp4_ss", (643, 3873, 3294) );
}

sfx_playing_fire_tower_sounds()
{
	//spawning all the audio assets for the fire tower and metal sound
	sfx_fire_tower_spawn();
	//calling the correct volume and filter settings for this position
	sfx_fire_tower_trigger_logic( 0, 1 );
}

sfx_blackice_derrick_exp6_ss()
{
	thread play_sound_in_space( "scn_blackice_derrick_exp6_ss", (-2135, 3711, 2360) );
}

sfx_stereo_quake()
{
	//wait 1.6;
	level.player PlaySound("scn_blackice_flarestack_quake_ss");
	
   	level.flarestack_quake_lp_01 = Spawn( "script_origin", (-3610, 4413, 1948) );
   	level.flarestack_quake_lp_01 PlayLoopSound("emt_blackice_flarestack_quake_lp");
   	
   	wait 9;
	level.player PlaySound("scn_blackice_flarestack_quake_ss");
	
}

sfx_blackice_catwalk_collapse( upper )
{
	iprintlnbold( "playing upper" );
	upper playsound("scn_blackice_catwalk_collapse");
}

sfx_pre_engine_room()
{
	delaythread( 0.001, ::play_sound_in_space, "scn_blackice_tanks_engine_explo", ( 796, 2886, 2096 ) );
	delaythread( 1.2, ::loop_fx_sound, "emt_blackice_engine_fire_alarm_lp", ( 1090, 2866, 2160 ) );

	level.player playsound( "scn_blackice_tanks_dist_explo" );
}

sfx_blackice_engine_beam_fall( top_drive )
{
	top_drive thread delaycall( 0.65, ::PlaySound, "scn_blackice_engine_beam_fall");
	level.player PlaySound ("scn_blackice_engine_beam_fall_swtner");
}

sfx_blackice_fire_extinguisher_spray( extinguisher )
{
	extinguisher play_sound_on_tag( "scn_blackice_fire_extinguisher_spray", "tag_fx" );
}

sfx_blackice_catwalk_explode()
{
	//IPrintLnBold("JL: Audio Start");
	level._tanks.pipe playsound("scn_blackice_catwalk_explode");

}

sfx_hand_scan()
{
	wait 2;
	thread play_sound_in_space( "scn_blackice_hand_scanner", (-3570, 4385, 1930) );
	
	//scansfx = Spawn( "script_origin", (-3570, 4385, 1930) );
	//scansfx PlaySound( "scn_blackice_hand_scanner" );
}

sfx_use_console()
{
	//wait 0.1;
	level.player PlaySound("scn_blackice_command_console_use");
}

sfx_command_warning_sfx()
{	
	level waittill( "notify_activate_flarestack_console" );
		consolesfx = Spawn( "script_origin", (-3567, 4412, 1932) );
		consolesfx PlaySound( "scn_blackice_command_console_raise" );
		
		wait 0.1;
		warningsfx = Spawn( "script_origin", (-3567, 4412, 1930) );
		warningsfx PlayLoopSound( "scn_blackice_command_warning_lp" );
		
	level waittill( "notify_flare_stack_button_press" );
		warningsfx StopLoopSound();
		warningsfx delete();
		
		sfx_computer_error();
}

sfx_computer_error()
{
	wait 0.75;
	computer_beeps = Spawn( "script_origin", (-3573, 4421, 1939) );
	computer_beeps PlayLoopSound( "scn_blackice_computer_warning_lp" );
}

// A simple gate so that we don't flood the engine with PlaySounds
sfx_screenshake()
{
	if ( flag( "sfx_rumble_ok" ) )
	{
		flag_clear("sfx_rumble_ok");
		//IPrintLnBold("sfx: Quake");
		level.player PlaySound("scn_blackice_screenshake");
		
		wait 1;
		flag_set("sfx_rumble_ok");
	}
}

sfx_black_ice_tanks_rumble()
{
	level.player playsound("scn_black_ice_tanks_rumble");
}

sfx_blackice_tanks_dist_explo()
{
	thread sfx_death_stop_rumbles();
	thread sfx_death_stop_turbines();
	wait 0.1;
	level.player playsound( "scn_blackice_tanks_dist_explo" );
}

sfx_tanks_wind_gust_trigger()
{	
	/*
	wind_gust = GetEnt( "trigger_tanks_wind_gust", "targetname" );
	wind_gust waittill( "trigger" );
	
	level.player playSound("scn_blackice_tanks_wind_gust_ss");
	*/
}

sfx_tanks_door_open()
{
	thread play_sound_in_space( "scn_blackice_tanks_door_open", (761, 2887, 2114) );	
}

sfx_blackice_engine_dist_explo()
{
	level.player playsound( "scn_blackice_engine_dist_explo" );
}

sfx_blackice_exfil_heli()
{
	level.heli PlaySound( "scn_blackice_exfil_heli" );
}

sfx_tape_breach( node )
{
	
	wait 0.6;
	node playsound( "scn_blackice_door_breach_01_ss" );
	
}

sfx_barracks_breach( door )
{
	level.player playsound( "scn_blackice_common_breach" );
	thread sfx_common_breach_mix();
	if (IsDefined( level.precommon ))
	{
		wait 1.5;
		level.precommon ScaleVolume( 0, 3 );
		wait 3.1;
		level.precommon delete();
	}
}

sfx_common_breach_mix()
{
	//IPrintLnBold( "1" );
	level.player SetClientTriggerAudioZone( "blackice_common_breach1", 1 );
	wait 7.5;
	//IPrintLnBold( "2" );
	level.player SetClientTriggerAudioZone( "blackice_common_breach2", 1 );
	wait 3;
	//IPrintLnBold( "2.5" );
	level.player SetClientTriggerAudioZone( "blackice_common_breach3", 2 );
	wait 4.5;
	//IPrintLnBold( "3" );
	level.player ClearClientTriggerAudioZone( 1 );
}

sfx_derrick_expl_init()
{
	sfx_derrick_expl = GetEnt( "derrick_expl_trig", "targetname" );
	sfx_derrick_expl thread sfx_derrick_expl_trig();
}
sfx_derrick_expl_trig()
{
	self waittill( "trigger" );
	set_mix( "mix_derrick_expl_before", 3 );
}

sfx_derrick_mix_change()
{
	wait 1.45;
	set_mix( "mix_derrick_expl_after" );
}

sfx_baker_fight_scene()
{
	self playsound("scn_blackice_command_baker_door");
	self playsound("scn_blackice_command_baker_fight");
	self smart_dialogue("blackice_bkr_flarestruggle");
	
	wait 1.838;
	self PlayLoopSound("scn_blackice_command_idle_lp");
	
	level waittill( "notify_flarestack_baker_pistol_pullout" );	
	wait 1.0;
	
	// <BMarv> I commented this out b/c it kills the volume on Merrick's lines after he kills the flarestack guy
//	self ScaleVolume( 0.0, 0.2);
	
	self StopLoopSound();
}

/* Fly in from mudpumps */
sfx_heli_flyin_mudpumps(heli)
{
	flag_set("heli_mudpumps_in");
	
	thread sfx_heli_flyin_sweetener(heli);
	
	wait 0.2;	
	level.heli_flyin_mudpumps = Spawn( "script_origin", heli.origin );
	level.heli_flyin_mudpumps LinkTo(heli);
	level.heli_flyin_mudpumps PlaySound("scn_blackice_pipedeck_heli_in_boats");
	
	wait 0.8;
	level.heli_engine_lp_01 = Spawn( "script_origin", heli.origin );
	level.heli_engine_lp_01 LinkTo(heli);
	level.heli_engine_lp_01 PlayLoopSound("scn_blackice_pipedeck_heli_lp");
	level.heli_engine_lp_01 ScaleVolume(0.0, 0.0);
	
	// Start the wind sfx
	thread sfx_assault_heli_wind(heli);
	thread sfx_heli_wind_debris();

	wait 0.1;
	level.heli_engine_lp_01 ScaleVolume(1.0, 1.5);
}

sfx_heli_flyin_sweetener(heli)
{
	wait 1.2;
	
	level.heli_flyin_swt = Spawn( "script_origin", heli.origin );
	level.heli_flyin_swt LinkTo(heli);
	level.heli_flyin_swt PlaySound("scn_blackice_pipedeck_heli_in_swt");	
}

/* Contingency if plr starts from pipe deck */
sfx_heli_flyin_pipedeck(heli)
{
	if (!flag("heli_mudpumps_in"))
	{
		level.heli_engine_lp_01 = Spawn( "script_origin", heli.origin );
		level.heli_engine_lp_01 LinkTo(heli);
		level.heli_engine_lp_01 PlayLoopSound("scn_blackice_pipedeck_heli_lp");
		
		// Start the wind sfx
		thread sfx_assault_heli_wind(heli);
		thread sfx_heli_wind_debris();
	}
}

sfx_heli_move_pipedeck(heli)
{
	wait 1;
	level.heli_move_boats = Spawn( "script_origin", heli.origin );
	level.heli_move_boats LinkTo(heli);
	level.heli_move_boats PlaySound("scn_blackice_pipedeck_heli_move_01");
	wait 1;
	//Fade down the engine for a sec to make some room in the mix
	level.heli_engine_lp_01 ScaleVolume(0.6, 3.0 );
	wait 3;
	level.heli_engine_lp_01 ScaleVolume(1.0, 1 );
}

/* Heli Flyaway from pipedeck/boats */
sfx_heli_flyaway_boats(heli)
{
	level.heli_flyaway_boats = Spawn( "script_origin", heli.origin );
	level.heli_flyaway_boats LinkTo(heli);
	level.heli_flyaway_boats PlaySound("scn_blackice_pipedeck_heli_away_boats");
	
	level.heli_engine_lp_01 ScaleVolume(0.5, 1.0 );
	wait 1;
	level.heli_engine_lp_01 ScaleVolume(0.0, 8.0 );
	
	wait 7;
	level.heli_engine_lp_01 delete();
}

/* Fly in for pipe deck assault seq */
sfx_assault_heli_flyin()
{
	wait 2;
	play_sound_in_space("scn_blackice_pipedeck_heli_in", (2600, 5140, 2892) );
}

sfx_assault_heli_engine(heli)
{
	wait 0.1;
	level.heli_engine_lp_02 = Spawn( "script_origin", heli.origin );
	level.heli_engine_lp_02 LinkTo(heli);
	level.heli_engine_lp_02 PlayLoopSound("scn_blackice_pipedeck_heli_lp");
	level.heli_engine_lp_02 ScaleVolume(0.0);
	wait 0.2;
	level.heli_engine_lp_02 ScaleVolume(1.0, 2.5);
	wait 2.5;
}

sfx_assault_heli_engine_fade_down()
{
	wait 4;
	level.heli_engine_lp_02 ScaleVolume(0.0, 12);
}

/* Same heli wind debris used in flood */
sfx_heli_wind_debris()
{
	if (flag("heli_mudpumps_in"))
		wait 3;
	
	level.heli_wind_debris = Spawn( "script_origin", level.player.origin);
	level.heli_wind_debris LinkTo(level.player);
	
	level.heli_wind_debris PlayLoopSound("scn_blackice_pipedeck_heli_debris_lp");
	level.heli_wind_debris ScaleVolume(0.0, 0.0);
	wait 0.1;
	level.heli_wind_debris ScaleVolume(1.0, 4.0);
		
	level waittill("notify_heli_leave");
	level.heli_wind_debris ScaleVolume(0.0, 2.0);
	wait 2;
	level.heli_wind_debris StopLoopSound("scn_blackice_pipedeck_heli_debris_lp");
	level.heli_wind_debris delete();
}

/* Prototype. Unused */
sfx_assault_heli_wind(heli)
{
	level.heli_wind = spawn( "script_origin", ( 0, 0, 0 ) );
	level.heli_wind hide();
	
	level.heli_wind endon( "death" );
	thread delete_on_death( level.heli_wind );
	
	level.heli_wind.origin = heli.origin + (0, 0,-350);
	level.heli_wind linkto( heli );

	level.heli_wind PlayLoopSound( "scn_blackice_pipedeck_heli_wind_lp" );
	level.heli_wind ScaleVolume(0.0);
	wait 0.1;
	level.heli_wind ScaleVolume(1.0, 2);
}

sfx_heli_turret_fire_start()
{
	/*
	level.heli_turret_fire = Spawn( "script_origin", self.origin );
	level.heli_turret_fire LinkTo(self);
	
	level.heli_engine_lp_02 ScaleVolume(0.6, 1.0);
	
	level.heli_turret_fire PlaySound("scn_blackice_pipedeck_heli_fire_first");
	//wait 0.173;
	level.heli_turret_fire PlayLoopSound("scn_blackice_pipedeck_heli_fire_lp");
	*/
}

sfx_heli_turret_fire_stop()
{
	/*
	if ( isdefined(level.heli_turret_fire) )
	{
		level.heli_engine_lp_02 ScaleVolume(1.0, 0.5);
		
		level.heli_turret_fire StopLoopSound("scn_blackice_pipedeck_heli_fire_lp");
		level.heli_turret_fire PlaySound("scn_blackice_pipedeck_heli_fire_last");
	}
	*/
}

sfx_heli_turret_fire_squibs()
{
	if (flag("sfx_stop_heli_squibs"))
	flag_clear("sfx_stop_heli_squibs");
	
	if (!isdefined(level.heli_squibs) )
	{
		level.heli_squibs = Spawn( "script_origin", self.turret_impact.origin );
		level.heli_squibs LinkTo(self.turret_impact);
	}
		level.heli_squibs PlayLoopSound("scn_blackice_pipedeck_squib_lp");
	
	// Debris
	if (!isdefined(level.squib_debris) )
	{
		level.squib_debris = Spawn( "script_origin", self.turret_impact.origin );
		level.squib_debris LinkTo(self.turret_impact);
	}
		level.squib_debris PlayLoopSound("scn_blackice_pipedeck_debris_lp");
	
	flag_wait("sfx_stop_heli_squibs");
	
	level.heli_squibs StopLoopSound("scn_blackice_pipedeck_squib_lp");
	level.squib_debris ScaleVolume(0.1, 3.0);
	
	wait 3;
	
	level.squib_debris StopLoopSound("scn_blackice_pipedeck_debris_lp");
	
	//thread sfx_assault_heli_engine_fade_down();
}

sfx_heli_turret_fire_squibs_stop()
{
	flag_set("sfx_stop_heli_squibs");
}

sfx_heli_turret_shells()
{
	if (flag("sfx_stop_heli_shells"))
	flag_clear("sfx_stop_heli_shells");
	
	if (!isdefined(level.heli_shells) )
	{
		level.heli_shells = Spawn( "script_origin", self.origin );
		level.heli_shells.origin = self.origin + (0, 0, -450);
		level.heli_shells LinkTo(self);
	}
	
	wait 0.2;
	level.heli_shells PlayLoopSound("scn_blackice_pipedeck_shell_lp");
	
	flag_wait("sfx_stop_heli_shells");
	wait 0.5;
	level.heli_shells ScaleVolume(0.1, 2.0);
	wait 2;
	level.heli_shells StopLoopSound("scn_blackice_pipedeck_shell_lp");
	level.heli_shells ScaleVolume(1.0, 1.0);
}

sfx_heli_turret_shells_stop()
{
	flag_set("sfx_stop_heli_shells");
}

sfx_baker_move_body_chair(baker)
{
	wait 0.1;
	baker PlaySound("scn_blackice_cmd_baker_chair");
}

sfx_command_center_door_open()
{
	wait 1.2;
	self PlaySound("scn_blackice_command_door_open");
}

sfx_plr_cmd_console()
{
	level.player PlaySound("scn_blackice_cmd_plr_console");
	
	// Spawn the node for rumbles
	level.command_rumble_node = Spawn( "script_origin", (2464, 5463, 2800) );
	level.command_warning_node = Spawn( "script_origin", (2464, 5463, 2796) );
	
	thread sfx_cmd_amb_change();
	thread sfx_turbines();
	wait 1;
	thread sfx_turbine_beeps();
}

sfx_cmd_amb_change()
{
	wait 3;
	//TimS - setting second level of control room audio
	level.player SetClientTriggerAudioZone( "blackice_controlroom_02", 4 );	
}

sfx_cmd_amb_change_final()
{
	wait 0.7;
	//TimS - setting third level of control room audio
	level.player SetClientTriggerAudioZone( "blackice_controlroom_03", 1.5 );	
}

sfx_cmd_console_acknowledge()
{
	level.command_warning_node PlaySound("scn_blackice_cmd_turbine_ack");
	flag_set("minigame_practice_over");
}

sfx_turbines()
{
	wait 4.5;
	
	//IPrintLnBold("Turbines Start");
	level.player PlaySound("scn_blackice_cmd_turbine_start");
	
	wait 2;
	
	level.cmd_turbine_lp = Spawn( "script_origin", (0, 0, 0));
	level.cmd_turbine_lp PlayLoopSound("scn_blackice_cmd_turbine_lp");
	level.cmd_turbine_lp LinkTo(level.player);
	
	/* Fade up to -1 */
	level.cmd_turbine_lp SetVolume(0.43, 0.5);
	
	flag_wait("minigame_practice_over");
	wait 0.2;
	
	//IPrintLnBold("Starting turbine ramp sfx");
	level.player PlaySound("scn_blackice_cmd_turbine_ramp");
	
	level.cmd_turbine_lp ScaleVolume(0, 1.2);
	
	wait 2.5;
	//level.player PlaySound("scn_blackice_cmd_turbine_metal");
	level.cmd_turbine_lp delete();
}

sfx_turbine_beeps()
{
	level.turbine_fail_node = Spawn( "script_origin", (2455, 5463, 2798) );
	flag_wait("minigame_practice_over");
	wait 0.2;
		level.player PlaySound("scn_blackice_cmd_turbine_beeps_asc");
	wait 3.2;
		level.turbine_fail_node PlaySound("scn_blackice_cmd_turbine_fail_beep");
		level.player PlaySound("scn_blackice_cmd_turbine_shake_01_lr");
	wait 2.7;
		level.turbine_fail_node PlaySound("scn_blackice_cmd_turbine_fail_beep");
		//level.player PlaySound("scn_blackice_cmd_turbine_shake_02_lr");
	wait 1.5;
		level.turbine_fail_node PlaySound("scn_blackice_cmd_turbine_fail_beep");
		level.player PlaySound("scn_blackice_cmd_turbine_shake_02_lr");
}

sfx_exfil_alarm()
{
	wait 1.5;
	level.exfil_alarm = Spawn( "script_origin", (0, 0, 0));
	level.exfil_alarm PlayLoopSound("scn_blackice_cmd_exfil_alarm");
	level.exfil_alarm LinkTo(level.player);
	
	/* Fade up */
	level.exfil_alarm SetVolume(0.45, 0.2);
	
	/* Stop any beeps that may have been playing if bars drift into the red after the game ends */
	if (flag("sfx_warning_playing"))
	{
		level.command_warning_node StopLoopSound("scn_blackice_cmd_turbine_warning_lp");
		flag_clear("sfx_warning_playing");
	}
	
	wait 7;
	level.exfil_alarm SetVolume(0.3, 8);
}

sfx_exfil_stop_alarm()
{
	if (IsDefined(level.exfil_alarm))
		level.exfil_alarm ScaleVolume(0.0, 3);
	
	wait 3;
	thread sfx_cmd_node_cleanup();
}

sfx_cmd_node_cleanup()
{
	if (IsDefined(level.exfil_alarm))
		level.exfil_alarm delete();
	if (IsDefined(level.turbine_fail_node))
		level.turbine_fail_node delete();
	if (IsDefined(level.command_warning_node))
		level.command_warning_node delete();
	if (IsDefined(level.command_rumble_node))
		level.command_rumble_node delete();
}

sfx_death_stop_turbines()
{
	level.player StopSounds("scn_blackice_cmd_turbine_ramp");
}

/* Determine lever state by the rumbles setup in 'monitor_controls_and_fx' */
sfx_lever_logic(rumble)
{
	switch( rumble )
	{
		case 0:
			thread sfx_lever_green();
		break;
		case 1:
			thread sfx_lever_yellow();
		break;
		case 2:
			thread sfx_lever_red();
		break;
	}
}

sfx_lever_green()
{
	if (!flag("sfx_lever_green"))
	{
		if (flag("sfx_lever_yellow"))
			flag_clear("sfx_lever_yellow");
		if (flag("sfx_lever_red"))
			flag_clear("sfx_lever_red");
		
		flag_set("sfx_lever_green");
		//IPrintLnBold("GREEN");
		
		if (flag("sfx_warning_playing"))
		{
			level.command_warning_node StopLoopSound("scn_blackice_cmd_turbine_warning_lp");
			level.command_warning_node PlaySound("scn_blackice_cmd_turbine_beep_02");
			flag_clear("sfx_warning_playing");
		}
		
	}
}

sfx_lever_yellow()
{
	if (!flag("sfx_lever_yellow"))
	{
		if (flag("sfx_lever_green"))
			flag_clear("sfx_lever_green");
		if (flag("sfx_lever_red"))
			flag_clear("sfx_lever_red");
		
		flag_set("sfx_lever_yellow");
		//IPrintLnBold("YELLOW");
		
		if (!flag("sfx_warning_playing"))
		{
			flag_set("sfx_warning_playing");
			level.command_warning_node PlayLoopSound("scn_blackice_cmd_turbine_warning_lp");
		}
		
		if (!flag("sfx_rumbles_playing") && flag("minigame_practice_over") ) // Meaning, we are in the yellow, but 'probably' not down from red
			thread sfx_yellowshake();
	}
}

sfx_lever_red()
{
	if (!flag("sfx_lever_red"))
	{
		if (flag("sfx_lever_green"))
			flag_clear("sfx_lever_green");
		if (flag("sfx_lever_yellow"))
			flag_clear("sfx_lever_yellow");
		
		flag_set("sfx_lever_red");
		//IPrintLnBold("RED");
		
		if (!flag("sfx_rumbles_playing") && flag("minigame_practice_over") )
			thread sfx_lever_rumbles();
	}
}

// Main Shake loop
sfx_lever_rumbles()
{
	//IPrintLnBold("Playing rumbles");
	level.command_rumble_node PlayLoopSound("emt_blackice_cmd_quake_lp");
	thread sfx_redshake();
	
	if (!flag("sfx_rumbles_playing"))
		flag_set("sfx_rumbles_playing");
	
	flag_wait("sfx_lever_yellow");
	level.command_rumble_node ScaleVolume(0.1, 2.0);
	wait 1.5;
	level.command_rumble_node StopLoopSound("emt_blackice_cmd_quake_lp");
	//IPrintLnBold("Stopped rumbles");
	level.command_rumble_node ScaleVolume(1.0, 0.0);
	
	if (flag("sfx_lever_red"))
		sfx_lever_rumbles();
	else
		flag_clear("sfx_rumbles_playing");
}

// Heavy red shake
sfx_redshake()
{
	//IPrintLnBold("R-Quake");
	level.player PlaySound("scn_blackice_cmd_red_shake");
}

// Additional Quad shakes
sfx_yellowshake()
{
	//IPrintLnBold("Y-Quake");
	level.player PlaySound("scn_blackice_cmd_yellow_shake");
}

// If player is killed
sfx_death_stop_rumbles()
{
	level.command_rumble_node StopLoopSound("emt_blackice_cmd_quake_lp");
	level.command_warning_node ScaleVolume( 0, 1.5 );
	wait 1.5;
	level.command_warning_node StopLoopSound("scn_blackice_cmd_turbine_warning_lp");
}

sfx_controlroom_explosions(explode)
{
	expl_sfx = "null";
	shake_sfx = "null";
	
	switch(explode)
	{
		case "command_control_1":
			expl_sfx = "scn_blackice_cmd_expl_03";
			shake_sfx = "scn_blackice_cmd_expl_shake_01_lr";
			break;
		
		case "command_control_2":
			expl_sfx = "scn_blackice_cmd_expl_02";
			shake_sfx = "scn_blackice_cmd_expl_shake_02_lr";
			break;
			
		case "command_control_3":
			expl_sfx = "scn_blackice_cmd_expl_01";
			shake_sfx = "scn_blackice_cmd_expl_shake_03_lr";
			break;
			
		case "command_control_4":
			expl_sfx = "scn_blackice_cmd_expl_04";
			shake_sfx = "scn_blackice_cmd_expl_shake_04_lsrs";
			//wait 0.5;
			break;
	}
	
	level.player PlaySound(expl_sfx);
	wait 0.5;
	level.player PlaySound(shake_sfx);
	//IPrintLnBold(explode);
}

sfx_cmd_seq_end()
{
	thread sfx_cmd_amb_change_final();
	thread sfx_exfil_alarm();
	wait 0.3;
	level.player PlaySound("scn_blackice_cmd_plr_console_end");
	wait 0.2;
	//sfx_redshake();
	wait 0.2;
	//level.player PlaySound("scn_blackice_cmd_expl_shake_02_lr");
}

sfx_exfil_outro()
{
	//IPrintLnBold("Outro");
	thread sfx_exfil_outro_mix();
	
	level.player PlaySound("scn_blackice_exfil_outro_lr");
	//wait 3.07;
	//level.player PlaySound("scn_blackice_exfil_outro_lsrs");	
	//wait 8.98;
	wait 7.6;
	level.player PlaySound("scn_blackice_exfil_outro_lfe");
}

sfx_exfil_outro_mix()
{
	level.player SetClientTriggerAudioZone( "blackice_exfil_outro", 4 );
	//wait 15;
	//IPrintLnBold("Heli down");
	//level._exfil_heli Vehicle_TurnEngineOff();
}

precommon_sound()
{
	self waittill( "trigger" );
	level.precommon = Spawn( "script_origin", (-2636, 4609, 1931) );
	level.precommon playsound( "scn_blackice_common_prebreach" );
}


blackice_pre_ascend_music()
{
	music_play( "mus_blackice_camp_ss" );
	flag_wait( "flag_ascend_end" );
	music_stop( 10 );
}

