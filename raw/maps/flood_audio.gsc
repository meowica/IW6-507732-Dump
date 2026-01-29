#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;


main()
{
	
	//thread audio_start_rushing_water_line_emitter_01();
	//thread audio_start_rushing_water_line_emitter_02();
	//thread audio_start_rushing_water_line_emitter_03();
	audio_flag_init();
	sfx_flood_streets_node_init();
	
	level.current_audio_zone = "flood_streets";
	
	thread sfx_flood_int_alarm();
	thread trigger_heli_staircase();
	thread trigger_int_building_hits();
	thread sfx_rooftops_player_jump();
	thread sfx_stairwell_heli_trig_setup();
	thread sfx_stairwell_mid_trig_setup();
	
	level.swept_away = 0;
	
	soundsettimescalefactor("announcer", 0.1 );
	soundsettimescalefactor("mission", 0 );
	soundsettimescalefactor("missionfx", 0.1 );
	soundsettimescalefactor("norestrict2d", 0 );
	
}

audio_flag_init()
{
	flag_init( "sfx_warehouse_water_start" );
	flag_init( "sfx_stop_warehouse_water" );
	flag_init( "sfx_stop_stairwell_water" );
	flag_init( "sfx_stop_mall_water" );
	flag_init( "sfx_stop_alley_water" );
	flag_init( "sfx_missiles_launched" );
	flag_init( "sfx_launcher_destroyed" );
	flag_init( "rooftop_heli_flyaway" );
	flag_init( "rooftop_stairwell_top" );
	flag_init( "rooftop_stairwell_mid" );
}

cleanupent(waittime)
{
	wait waittime;
	self delete();
}

change_zone_stairwell()
{
	//wait 3;
	//IPrintLnBold("Opening door...");
	//set_audio_zone( "flood_mall", 6 );
}

audio_start_rushing_water_line_emitter_01()
{
	wait 0.1;
	lineemitterarray = [];
	lineemitterarray[0] = spawn( "script_origin", (3847,-3631,123) );
	lineemitterarray[1] = spawn( "script_origin", (3759,-4085,123) );
	lineemitterarray[2] = spawn( "script_origin", (4914,-4086,123) );
	lineemitterarray[3] = spawn( "script_origin", (4906,-3434,123) );
	lineemitterarray[4] = spawn( "script_origin", (5480,-3370,123) );

	audio_stereo_line_emitter( lineemitterarray, "emt_flood_rushing_water_l" );
	//audio_stereo_line_emitter( lineemitterarray, "emt_flood_rushing_water_l", "emt_flood_rushing_water_r" );
}

audio_start_rushing_water_line_emitter_02()
{
	wait 0.1;
	lineemitterarray = [];
	lineemitterarray[0] = spawn( "script_origin", (6100,-3398,157) );
	lineemitterarray[1] = spawn( "script_origin", (6484,-3182,157) );
	lineemitterarray[2] = spawn( "script_origin", (6486,-2786,157) );

	audio_stereo_line_emitter( lineemitterarray, "emt_flood_rushing_water_l" );
	//audio_stereo_line_emitter( lineemitterarray, "emt_flood_rushing_water_l", "emt_flood_rushing_water_r" );
}

audio_start_rushing_water_line_emitter_03()
{
	wait 0.1;
	lineemitterarray = [];
	lineemitterarray[0] = spawn( "script_origin", (5653,-2121,123) );
	lineemitterarray[1] = spawn( "script_origin", (5641,2134,123) );
	lineemitterarray[2] = spawn( "script_origin", (6514,2906,123) );

	audio_stereo_line_emitter( lineemitterarray, "emt_flood_rushing_water_l" );
	//audio_stereo_line_emitter( lineemitterarray, "emt_flood_rushing_water_l", "emt_flood_rushing_water_r" );
}

audio_stereo_line_emitter( array, soundalias_left, soundalias_right )
{
	soundorg = Spawn( "script_origin", ( 0,0,0 ) );
	soundorg2 = Spawn( "script_origin", ( 0,0,0 ) );

		
	line_ent1 = undefined;
	line_ent2 = undefined;
	soundplaying = 0;
	while(1)
	{
	line_ents = 0;
	closest_ents = get_array_of_closest( level.player.origin, array, undefined, 2 );
	foreach ( line_ent in closest_ents )
		{
		if ( line_ents == 0 )
			{
			line_ents = 1;
			line_ent1 = line_ent;
			}
		else
			{
			line_ent2 = line_ent;
			}

		}
		linepoint = PointOnSegmentNearestToPoint( line_ent1.origin, line_ent2.origin, level.player.origin );
		if ( isdefined( soundalias_right ) )
		{
			soundorg MoveTo( (linepoint + (0,30,0)), 0.01 );
			soundorg2 MoveTo((linepoint - (0,30,0)), 0.01 );
		}
		else
		{
			soundorg MoveTo( linepoint, 0.01 );
		}
		


		if ( soundplaying == 0 )
		{
			if ( isdefined( soundalias_right ) )
				soundorg2 PlayLoopSound( soundalias_right );
			
			soundorg PlayLoopSound( soundalias_left );
			soundplaying = 1;
		}
		wait 0.1;
	}
}

sfx_heli_infil()
{
	level.player SetClientTriggerAudioZone( "flood_infil", 0.1 );
	wait 0.1;
	level.player PlaySound("scn_flood_infil_lr");
	wait 0.5;
	level.player ClearClientTriggerAudioZone( 2 );
}

sfx_lynx_smash()
{
	wait 3;
	level.tank_ally_joel PlaySound("scn_flood_tank_crush_lynx");
	wait 3;
	//IPrintLnBold( "got lynx crush fx" );
	exploder( "lynx_crush");
}

sfx_tank_bust_wall()
{
	//allied_tank_2_audio = getent("allied_tank_2_fake", "targetname");
	wait 2.0;
	//IPrintLnBold("start audio");
	level.tank_wall_sfx = spawn( "script_origin", (1093, -9790, 50) );
	level.tank_wall_sfx playsound("scn_streets_tank_bust_wall");
}

sfx_missile_buzzer(launcher, audio_flag)
{
//	missile_launcher = getent("missile_launcher_4", "targetname");
	missile_launcher = level.dam_break_m880;
	missile_launcher = launcher;
	
	level.buzzer_node = spawn( "script_origin", missile_launcher.origin );
	level.buzzer_node LinkTo( missile_launcher );

	waittillframeend;
	
	battlechatter_on( "axis" ); 
	thread missile_launcher_battlechatter( audio_flag );
	
	while(1)
	{		
		if (!flag (audio_flag))
		{
			level.buzzer_node PlaySound("emt_flood_missile_buzzer_2");
			wait 1.32;
		}
		else
			break;
	}
	
	level.buzzer_node delete();
}

missile_launcher_battlechatter( audio_flag )
{
	launcher_battlechatter_sfx = spawn( "script_origin", (-1554,-3711,0) );
	waittillframeend;
	while(1)
	{		
		if (!flag (audio_flag))
		{
			launcher_battlechatter_sfx PlaySound("scn_flood_missile_scripted_bc");
			wait( RandomFloatRange( 2, 5 ) );
		}
		else
			break;
	}	
}

sfx_stop_buzzer(audio_flag)
{
	flag_set(audio_flag);
}

/* Dam Bursting water SFX */
sfx_dam_start_water()
{		
	// Setup and play siren
	thread start_sfx_dam_siren_ext( 5.0, 1.0 );
	
	// Play Rumble
	level.player PlaySound("scn_flood_dam_rumble");
	
	// Setup and play first tidal wave sfx
	thread sfx_dam_tidal_wave_01();
	
	// Set the mix preset - waiting so we don't get an overflow error
	//wait 0.2;
	//set_audio_zone( "flood_tidal_wave", 1 );
}
setup_sfx_dam_siren()
{

    level.sirenorg_ext_l = Spawn( "script_origin", (-6839, -67, 1962) );
    level.sirenorg_ext_l ScaleVolume(0.001, 0.001);
    level.sirenorg_ext_l PlayLoopSound("scn_flood_dam_siren_lp_l");
    
    level.sirenorg_ext_r = Spawn( "script_origin", (5969, 1090, 1962) );
    level.sirenorg_ext_r ScaleVolume(0.001, 0.001);
    level.sirenorg_ext_r PlayLoopSound("scn_flood_dam_siren_lp_r");
    
    level.sirenorg_ext_s = Spawn( "script_origin", (-25, -13632, 1962) );
    level.sirenorg_ext_s ScaleVolume(0.001, 0.001);
    level.sirenorg_ext_s PlayLoopSound("scn_flood_dam_siren_lp_s");
    
    level.sirenorg_int = Spawn( "script_origin", level.player.origin );
    level.sirenorg_int LinkTo( level.player );
    level.sirenorg_int PlayLoopSound("scn_flood_dam_siren_int_lp");
    level.sirenorg_int ScaleVolume(0.001, 0.001);
    
    wait 0.6;
    
    level.sirenorg_ext_l ScaleVolume(1.0, 4.0);
    level.sirenorg_ext_r ScaleVolume(1.0, 4.0); 
    level.sirenorg_ext_s ScaleVolume(1.0, 4.0);    
}

start_sfx_dam_siren_ext( fadein_time, scale_vol )
{
	if ( !IsDefined( fadein_time ) )
	{
		fadein_time = 5.0;
	}
	
	if ( !IsDefined( scale_vol ) )
	{
		scale_vol = 1.0;
	}
	
	if ( !IsDefined( level.sirenorg_ext_l ) || !IsDefined( level.sirenorg_ext_r) || !IsDefined( level.sirenorg_ext_s) || !IsDefined( level.sirenorg_int ) )
	{
		setup_sfx_dam_siren();
	}
	

    level.sirenorg_ext_l ScaleVolume(scale_vol, fadein_time );
    level.sirenorg_ext_r ScaleVolume(scale_vol, fadein_time );
    level.sirenorg_ext_s ScaleVolume(scale_vol, fadein_time );    
}

stop_sfx_dam_siren_ext()
{
	
	if ( !IsDefined( level.sirenorg_ext_l ) || !IsDefined( level.sirenorg_ext_r) || !IsDefined( level.sirenorg_ext_s) || !IsDefined( level.sirenorg_int ) )
	{
		setup_sfx_dam_siren();
	}
		
    level.sirenorg_ext_l ScaleVolume(0.001, 15);
    level.sirenorg_ext_r ScaleVolume(0.001, 15);
    level.sirenorg_ext_s ScaleVolume(0.001, 15);

}

start_sfx_dam_siren_int()
{
	if ( !IsDefined( level.sirenorg_ext_l ) || !IsDefined( level.sirenorg_ext_r) || !IsDefined( level.sirenorg_ext_s) || !IsDefined( level.sirenorg_int ) )
	{
		setup_sfx_dam_siren();
	}
	

    level.sirenorg_int ScaleVolume(0.001, 0.001);
    wait 0.01;
    level.sirenorg_int ScaleVolume(1.0, 3);
}

stop_sfx_dam_siren_int()
{
	if ( !IsDefined( level.sirenorg_ext_l ) || !IsDefined( level.sirenorg_ext_r) || !IsDefined( level.sirenorg_ext_s) || !IsDefined( level.sirenorg_int ) )
	{
		setup_sfx_dam_siren();
	}
	
    level.sirenorg_int ScaleVolume(0.001, 15);

}

kill_sfx_dam_sirens()
{
	if ( !IsDefined( level.sirenorg_ext_l ) || !IsDefined( level.sirenorg_ext_r) || !IsDefined( level.sirenorg_ext_s) || !IsDefined( level.sirenorg_int ) )
	{
		setup_sfx_dam_siren();
	}
	
    level.sirenorg_ext_l ScaleVolume(0.001, 2.5);
    level.sirenorg_ext_r ScaleVolume(0.001, 2.5);
    level.sirenorg_ext_s ScaleVolume(0.001, 2.5);
    level.sirenorg_int ScaleVolume(0.001, 2.5);

    wait 2.5;
    level.sirenorg_int StopLoopSound("scn_flood_dam_siren_int_lp");
    level.sirenorg_ext_l StopLoopSound("scn_flood_dam_siren_lp_l");
    level.sirenorg_ext_r StopLoopSound("scn_flood_dam_siren_lp_r"); 
    level.sirenorg_ext_s StopLoopSound("scn_flood_dam_siren_lp_s");
    level.sirenorg_ext_l delete();
    level.sirenorg_ext_r delete();
    level.sirenorg_ext_s delete();
    level.sirenorg_int delete();    

}

sfx_dam_tidal_wave_01()
{
	/*
	water_node_01 = Spawn( "script_origin", (-1600,-3159, 60) );
	water_node_02 = Spawn( "script_origin", (-1600,-5400, 60) );
	water_node_lp_01 = Spawn( "script_origin", (-1400,-4000, 60) );
	
	water_node_01 PlaySound("scn_flood_dam_tidal_wave_01");
	water_node_02 PlaySound("scn_flood_dam_tidal_wave_02");
	
	// Setup and play rushing water loop
	wait 10;
	//water_node_lp_01 PlayLoopSound("emt_flood_water_rushing_heavy_alley");
	// Fade up the sound under the first tidal wave
	water_node_lp_01 SetVolume(0.001);
	
	wait 0.05;
	waittillframeend;
	
	water_node_lp_01 SetVolume(1, 3);
	
	// Cleanup
	wait 10;
	water_node_01 delete();
	water_node_02 delete();
	
	flag_wait("sfx_stop_alley_water");
	
	water_node_lp_01 ScaleVolume(0.001, 2);
	wait 2;
	water_node_lp_01 delete();
	*/
}

sfx_dam_tidal_wave_02()
{
	water_node_03 = Spawn( "script_origin", (900,-4026, 60) );
	water_node_lp_02 = Spawn( "script_origin", (256,-4026, 60) );
	truck_node = Spawn( "script_origin", (700, -4176, 33) );
	
	wait 0.5;
	
	water_node_lp_02 PlayLoopSound( "emt_flood_water_rushing_heavy" );
	
	wait 1.2;
	
	water_node_03 PlaySound("scn_flood_dam_tidal_wave_03");
	
	wait 1.2;
	
	truck_node PlaySound("scn_flood_dam_truck_impact");
	water_node_lp_02 ScaleVolume(0.001, 1 );
	
	wait 1;
	
	water_node_lp_02 StopLoopSound( "emt_flood_water_rushing_heavy" );
	// Fade out the mix preset
	/*
	wait 2;
	set_audio_zone( "flood_generic", 4 );
	*/
	
	wait 0.6;
	// Start loop sound
	water_node_lp_02 PlayLoopSound("emt_flood_water_rushing_heavy_alley");
	
	// Fade up the sound under the second tidal wave
	water_node_lp_02 ScaleVolume(0.001);
	
	wait 0.1;
	
	water_node_lp_02 ScaleVolume(1, 2);
	
	// Cleanup
	wait 10;
	water_node_03 delete();
	
	flag_wait("sfx_stop_alley_water");
	
	water_node_lp_02 ScaleVolume(0.001, 2);
	wait 2;
	water_node_lp_02 delete();
}

sfx_stop_alley_water()
{
	flag_set("sfx_stop_alley_water");
}

sfx_big_metal_stress()
{
	wait 15;
	//IPrintLnBold("Playing metal stress");
	level.player PlaySound("scn_flood_warehouse_mtl_huge_stress_lr");
}

sfx_warehouse_door_burst_01( door )
{
	//IPrintLnBold("Burst 01");
	door PlaySound("scn_flood_warehouse_door_burst_01");
	wait 1;
	door PlayLoopSound("emt_flood_door_rattle_lp");
	
	water_spray_node_01 = Spawn( "script_origin", (310,-2410, 44) );
	water_spray_node_01 PlayLoopSound("emt_flood_water_spray_lp_02");
	
	flag_wait("sfx_stop_warehouse_water");
	
	wait 2;
	water_spray_node_01 delete();
	
}

sfx_warehouse_door_burst_02( door )
{
	thread play_sound_in_space( "scn_flood_warehouse_door_burst_02", (373, -2033, 75) );
	wait 0.1;
	thread sfx_warehouse_water_sprays();
	wait 0.1;
	door PlayLoopSound("emt_flood_door_rattle_lp");
}

sfx_warehouse_water_sprays()
{
	wait 0.6;
	water_spray_node_02 = Spawn( "script_origin", (292,-2120, 47) );
	water_spray_node_02 PlayLoopSound("emt_flood_water_spray_lp_01");
	
	wait 0.3;
	water_spray_node_03 = Spawn( "script_origin", (278,-1908, 47) );
	water_spray_node_03 PlayLoopSound("emt_flood_water_spray_lp_02");
	
	//stairwell right side
	water_spray_node_04 = Spawn( "script_origin", (74,-1431, 69) );
	water_spray_node_04 PlayLoopSound("emt_flood_water_spray_lp_02");
	
	//stairwell dbl doors
	wait 0.1;
	water_spray_node_05 = Spawn( "script_origin", (9,-1093, 90) );
	water_spray_node_05 PlayLoopSound("emt_flood_water_spray_lp_01");
	
	flag_wait("sfx_stop_warehouse_water");
	
	wait 2;
	water_spray_node_02 delete();
	water_spray_node_03 delete();
	water_spray_node_04 delete();
	water_spray_node_05 delete();
	
}

sfx_warehouse_water()
{
	// Spawn nodes
	// These nodes are on the main entrance doors
	door_stress_node_01 = Spawn( "script_origin", (36, -2932, 52) );
	door_stress_node_02 = Spawn( "script_origin", (-91, -2932, 52) );
	
	door_water_node_01 = Spawn( "script_origin", (-21,-2932, 10) );
	door_water_node_02 = Spawn( "script_origin", (81,-2932, 10) );
	door_water_node_03 = Spawn( "script_origin", (-129,-2932, 10) );
	
	// These nodes are for the 3 doors against the wall
	door_stress_node_03 = Spawn( "script_origin", (373,-2597, 52) );
	door_stress_node_04 = Spawn( "script_origin", (373,-2273, 52) );
	door_stress_node_05 = Spawn( "script_origin", (373,-1952, 52) );
	
	wall_water_node_01 = Spawn( "script_origin", (252,-2704, 52) );
	wall_water_node_02 = Spawn( "script_origin", (373,-2511, 52) );
	//wall_water_node_03 = Spawn( "script_origin", (373,-2353, 92) );
	wall_water_node_04 = Spawn( "script_origin", (373,-2191, 85) );
	//wall_water_node_05 = Spawn( "script_origin", (373,-2033, 75) );
	//wall_water_node_06 = Spawn( "script_origin", (373,-1871, 92) );
	
	// Nodes for the stairwell door and water sprays
	door_stress_node_06 = Spawn( "script_origin", (4,-1027, 91) );
	
	//wall_water_node_07 = Spawn( "script_origin", (60, -1038, 92) );
	//wall_water_node_08 = Spawn( "script_origin", (-67,-1034, 66) );
	//wall_water_node_09 = Spawn( "script_origin", (366,-759, 217) );
	//wall_water_node_10 = Spawn( "script_origin", (141,-749, 177) );
	
	water_spray_node_06 = Spawn( "script_origin", (221,-3168, 47) );
	
	wait 0.05;
	waittillframeend;
	
	// Main double doors
	door_stress_node_01 PlayLoopSound("emt_flood_mtl_buckling_lp_01");
	door_stress_node_01 ScaleVolume(0.1);
	door_stress_node_02 PlayLoopSound("emt_flood_mtl_buckling_lp_02");
	door_stress_node_02 ScaleVolume(0.1);
	
	door_water_node_01 PlayLoopSound("emt_flood_water_seep_low_lp");
	door_water_node_01 ScaleVolume(0.1);
	door_water_node_02 PlayLoopSound("emt_flood_water_seep_low_lp");
	door_water_node_02 ScaleVolume(0.1);
	//door_water_node_03 PlayLoopSound("emt_flood_water_seep_low_lp");
	//door_water_node_03 ScaleVolume(0.1);
	
	// Side wall
	door_stress_node_03 PlayLoopSound("emt_flood_mtl_buckling_lp_02");
	door_stress_node_03 ScaleVolume(0.1);
	door_stress_node_04 PlayLoopSound("emt_flood_mtl_buckling_lp_01");
	door_stress_node_04 ScaleVolume(0.1);
	door_stress_node_05 PlayLoopSound("emt_flood_mtl_buckling_last_lp");
	door_stress_node_05 ScaleVolume(0.1);
	
	wall_water_node_01 PlayLoopSound("emt_flood_water_spray_lp_01");
	wall_water_node_01 ScaleVolume(0.1);
	wall_water_node_02 PlayLoopSound("emt_flood_water_seep_int_lp");
	wall_water_node_02 ScaleVolume(0.1);
	//wall_water_node_03 PlayLoopSound("emt_flood_water_seep_lp");
	//wall_water_node_03 ScaleVolume(0.1);
	wall_water_node_04 PlayLoopSound("emt_flood_water_seep_int_lp");
	wall_water_node_04 ScaleVolume(0.1);
	//wall_water_node_05 PlayLoopSound("emt_flood_water_seep_last_lp");
	//wall_water_node_05 ScaleVolume(0.1);
	//wall_water_node_06 PlayLoopSound("emt_flood_water_seep_last_lp");
	//wall_water_node_06 ScaleVolume(0.1);
	
	// Stairwell
	door_stress_node_06 PlayLoopSound("emt_flood_mtl_buckling_lp_01");
	door_stress_node_06 ScaleVolume(0.1);
	
	//wall_water_node_07 PlayLoopSound("emt_flood_water_seep_int_lp");
	//wall_water_node_07 ScaleVolume(0.1);
	//wall_water_node_08 PlayLoopSound("emt_flood_water_seep_lp");
	//wall_water_node_08 ScaleVolume(0.1);
	//wall_water_node_09 PlayLoopSound("emt_flood_water_seep_int_lp");
	//wall_water_node_09 ScaleVolume(0.1);
	//wall_water_node_10 PlayLoopSound("emt_flood_water_seep_lp");
	//wall_water_node_10 ScaleVolume(0.1);
	
	water_spray_node_06 PlayLoopSound("emt_flood_water_spray_lp_02");
	water_spray_node_06 ScaleVolume(0.1);
	
	// Fade up
	wait 0.05;
	waittillframeend;

	// Main double doors
	door_stress_node_01 ScaleVolume(1, 1);
	door_stress_node_02 ScaleVolume(1, 1);
	
	door_water_node_01 ScaleVolume(1, 1);
	door_water_node_02 ScaleVolume(1, 1);
	door_water_node_03 ScaleVolume(1, 1);
	
	// Side wall
	door_stress_node_03 ScaleVolume(1, 1);
	door_stress_node_04 ScaleVolume(1, 1);
	door_stress_node_05 ScaleVolume(1, 1);
	
	wall_water_node_01 ScaleVolume(1, 1);
	wall_water_node_02 ScaleVolume(1, 1);
	//wall_water_node_03 ScaleVolume(1, 1);
	wall_water_node_04 ScaleVolume(1, 1);
	//wall_water_node_05 ScaleVolume(1, 1);
	//wall_water_node_06 ScaleVolume(1, 1);
	
	//Stairwell
	door_stress_node_06 ScaleVolume(0.75, 1);
	
	//wall_water_node_07 ScaleVolume(1, 1);
	//wall_water_node_08 ScaleVolume(1, 1);
	//wall_water_node_09 ScaleVolume(1, 1);
	//wall_water_node_10 ScaleVolume(1, 1);
	water_spray_node_06 ScaleVolume(1, 1);
		
	// Warehouse Fade out
	flag_wait("sfx_stop_warehouse_water");
	//IPrintLnBold("Initiating warehouse sfx cleanup");
	
	door_stress_node_01 ScaleVolume(0.001, 2);
	door_stress_node_02 ScaleVolume(0.001, 2);
	door_stress_node_03 ScaleVolume(0.001, 2);
	door_stress_node_04 ScaleVolume(0.001, 2);
	door_stress_node_05 ScaleVolume(0.001, 2);
	
	door_water_node_01 ScaleVolume(0.001, 2);
	door_water_node_02 ScaleVolume(0.001, 2);
	door_water_node_03 ScaleVolume(0.001, 2);
	
	wall_water_node_01 ScaleVolume(0.001, 2);
	wall_water_node_02 ScaleVolume(0.001, 2);
	//wall_water_node_03 ScaleVolume(0.001, 2);
	wall_water_node_04 ScaleVolume(0.001, 2);
	//wall_water_node_05 ScaleVolume(0.001, 2);
	//wall_water_node_06 ScaleVolume(0.001, 2);

	water_spray_node_06 ScaleVolume(0.001, 2);
	
	// Warehouse Cleanup
	wait 2;
	
	door_stress_node_01 delete();
	door_stress_node_02 delete();
	door_stress_node_03 delete();
	door_stress_node_04 delete();
	door_stress_node_05 delete();
	
	door_water_node_01 delete();
	door_water_node_02 delete();
	door_water_node_03 delete();
	
	wall_water_node_01 delete();
	wall_water_node_02 delete();
	//wall_water_node_03 delete();
	wall_water_node_04 delete();
	//wall_water_node_05 delete();
	//wall_water_node_06 delete();
	
	water_spray_node_06 delete();
	
	// Stairwell cleanup
	
	flag_wait("sfx_stop_stairwell_water");
	//IPrintLnBold("Initiating stairwell sfx cleanup");
	
	door_stress_node_06 ScaleVolume(0.001, 4);
	
	//wall_water_node_07 ScaleVolume(0.001, 4);
	//wall_water_node_08 ScaleVolume(0.001, 4);
	//wall_water_node_09 ScaleVolume(0.001, 4);
	//wall_water_node_10 ScaleVolume(0.001, 4);
	
	wait 4;
	
	door_stress_node_06 delete();
		
	//wall_water_node_07 delete();
	//wall_water_node_08 delete();
	//wall_water_node_09 delete();
	//wall_water_node_10 delete();
}

sfx_stop_warehouse_water()
{
	//wait 0.1;
	wait 12;
	flag_set("sfx_stop_warehouse_water");
}


sfx_stop_stairwell_water()
{
	wait 4;
	flag_set("sfx_stop_stairwell_water");
}

sfx_stop_mall_water()
{
	wait 0.1;
	flag_set("sfx_stop_mall_water");
}


sfx_mall_water()
{
	wait 3;
	//IPrintLnBold("Starting mall water");
	street_water_node_01 = Spawn( "script_origin", (638, -2325, 277) );
	wait 0.05;
	waittillframeend;
	
	// Main double doors
	street_water_node_01 PlayLoopSound("emt_flood_water_rushing_heavy_mall");
	street_water_node_01 SetVolume(0.1);
	
	// Fade up
	wait 0.05;
	waittillframeend;

	// Main double doors
	street_water_node_01 SetVolume(0.4, 6);
	
	flag_wait("sfx_stop_mall_water");
	//IPrintLnBold("Initiating mall sfx cleanup");
	
	street_water_node_01 delete();
}


sfx_flood_streets_node_init()
{
	level.sfx_flood_nodes = [];
	
	sfx_node_array_init( (299, -10367, 119), "emt_flood_streets_01", 0 );
	sfx_node_array_init( (-1586, -9082, 100), "emt_flood_streets_01", 1 );
	sfx_node_array_init( (-1586, -9082, 141), "emt_flood_streets_02", 2 );
	sfx_node_array_init( (-1723, -8539, 160), "emt_flood_streets_05", 3 );
	sfx_node_array_init( (-1875, -7567, 100), "emt_flood_streets_03", 4 );
	sfx_node_array_init( (-1875, -7567, 50), "emt_flood_streets_04", 5 );
	
}
	
sfx_node_array_init( org, sound, ref )
{
	object = spawn( "script_origin", org );
	object.soundalias = sound;
	object.refnum = ref;
	level.sfx_flood_nodes[level.sfx_flood_nodes.size] = object;
}

sfx_flood_streets_emitters()
{
	thread sfx_flood_streets_triggers();
	for( i=0; i<level.sfx_flood_nodes.size; i++ )
	{
		level.sfx_flood_nodes[i] playloopsound( level.sfx_flood_nodes[i].soundalias );
	}
}

sfx_flood_streets_triggers()
{	
	
	level.sfx_flood_streets_trigger_array = [];
	
	sfx_flood_streets_triggers_init( "sfx_streets_trigger_1", 0 );
	sfx_flood_streets_triggers_init( "sfx_streets_trigger_2", 1, 3 );
	sfx_flood_streets_triggers_init( "sfx_streets_trigger_3", 4, 5 );
	
	spawner = [];
	
	for(i=0; i<(level.sfx_flood_streets_trigger_array.size - 1); i++)
	{
		spawner[i] = GetEnt( level.sfx_flood_streets_trigger_array[i].trig, "targetname" );
		spawner[i] thread sfx_flood_streets_trigger_logic( i );		
	}	
}

sfx_flood_streets_triggers_init( trig, node1, node2 )
{
	object = SpawnStruct();
	object.trig = trig;
	object.node1 = node1;
	if( isdefined( node2 ) )
	{
		object.node2 = node2;
	}
	else
	{
		object.node2 = -1;	
	}
	level.sfx_flood_streets_trigger_array[level.sfx_flood_streets_trigger_array.size] = object;	
}

sfx_flood_streets_trigger_logic( spawned_trigger, oneshot )
{
	
	if( !IsDefined( oneshot ) )
	{
		self waittill( "trigger" );
	}
	if( level.sfx_flood_streets_trigger_array[spawned_trigger].node2 == -1 )
	{
		level.sfx_flood_nodes[level.sfx_flood_streets_trigger_array[spawned_trigger].node1] ScaleVolume( 0, 1.5 );
		wait 1.6;
		sfx_flood_generic_node_delete( level.sfx_flood_streets_trigger_array[spawned_trigger].node1 );
	}
	else
	{
		for(i=level.sfx_flood_streets_trigger_array[spawned_trigger].node1; i<(level.sfx_flood_streets_trigger_array[spawned_trigger].node2 + 1); i++)
		{
			level.sfx_flood_nodes[i] ScaleVolume( 0, 1.5 );
		}
		wait 1.6;
		sfx_flood_generic_node_delete( level.sfx_flood_streets_trigger_array[spawned_trigger].node1, level.sfx_flood_streets_trigger_array[spawned_trigger].node2 );
	}
}

sfx_flood_generic_node_delete( beginningnode, endingnode )
{
	if( !IsDefined(endingnode) )
	{
		if( IsDefined(level.sfx_flood_nodes[beginningnode]) )
		{
		   level.sfx_flood_nodes[beginningnode] delete();
		}
	}
	else
	{
		for(i=beginningnode;i<(endingnode+1); i++)
		{
			if( IsDefined(level.sfx_flood_nodes[i]) )
			{
				level.sfx_flood_nodes[i] delete();
			}
		}
	}
}

audio_flood_end_logic()
{
	thread swept_away_scene( "end" );
	wait 4.4;
	//level.player playsound( "scn_flood_swept_end_ss" );
	level.swept_away = 0;
}

debris_bridge_sfx()
{
	thread debris_bridge_shaking_loop();
	start_padding = 0.0;
	//IPrintLnBold("start");	
	
	wait 8.4;
	thread play_sound_in_space("scn_flood_debris_bridge",( 5540, 2494, 110 ));
	/*
	delaythread( (start_padding + 0.2), ::play_sound_in_space, "scn_flood_debris_bridge_hit_01_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 1.143), ::play_sound_in_space, "scn_flood_debris_bridge_hit_02_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 3.981), ::play_sound_in_space, "scn_flood_debris_bridge_hit_03_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 6.351), ::play_sound_in_space, "scn_flood_debris_bridge_hit_04_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 8.917), ::play_sound_in_space, "scn_flood_debris_bridge_hit_05_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 9.591 ), ::play_sound_in_space, "scn_flood_debris_bridge_hit_06_ss", ( 5981, 2365, 100 ) );
	delaythread( (start_padding + 10.310), ::play_sound_in_space, "scn_flood_debris_bridge_hit_07_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 12.190), ::play_sound_in_space, "scn_flood_debris_bridge_hit_08_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 13.49), ::play_sound_in_space, "scn_flood_debris_bridge_hit_09_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 16.089), ::play_sound_in_space, "scn_flood_debris_bridge_hit_10_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 18.329), ::play_sound_in_space, "scn_flood_debris_bridge_hit_11_ss", ( 5701, 2204, 110 ) );
	delaythread( (start_padding + 19.205), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_lg", ( 6286, 2225, 160 ) );
	*/
	//up stream hits
	//delaythread( (start_padding + 5.950), ::play_sound_in_space, "scn_flood_debris_bridge_hit_12_ss", ( 6129, 2884, 110 ) );
	//delaythread( (start_padding + 14.400), ::play_sound_in_space, "scn_flood_debris_bridge_hit_13_ss", ( 6129, 2884, 110 ) );
	
	
	//last hit
	//delaythread( (start_padding + 24.000), ::play_sound_in_space, "scn_flood_debris_bridge_hit_14_ss", ( 5862, 2439, 100 ) );
	
	//room debris stuff
	delaythread( (start_padding + 0.2), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 1.143), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 6.351), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 8.917), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 9.591 ), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 10.310), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 12.190), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 13.49), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );
	delaythread( (start_padding + 16.089), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_sm", ( 6286, 2225, 160 ) );

	delaythread( (start_padding + 19.205), ::play_sound_in_space, "scn_flood_debris_bridge_ceiling_debris_lg", ( 6286, 2225, 160 ) );
	
}

debris_bridge_shaking_loop()
{
	
	flag_wait( "debrisbridge_ready" );
	//IPrintLnBold("debrisbridge_ready");
	lineemitterarray1 = [];
	lineemitterarray1[0] = spawn( "script_origin", (6034,2388,95) );
	lineemitterarray1[1] = spawn( "script_origin", (2628,2499,95) );
	
	lineemitterarray2 = [];
	lineemitterarray2[0] = spawn( "script_origin", (5970,2280,119) );
	lineemitterarray2[1] = spawn( "script_origin", (5537,2364,119) );
	
	lineemitterarray3 = [];
	lineemitterarray3[0] = spawn( "script_origin", (6034,2388,95) );
	lineemitterarray3[1] = spawn( "script_origin", (2628,2499,95) );

	thread audio_stereo_line_emitter( lineemitterarray1, "emt_flood_debris_bridge_lp_01" );
	thread audio_stereo_line_emitter( lineemitterarray2, "emt_flood_debris_bridge_lp_02" );
	thread audio_stereo_line_emitter( lineemitterarray3, "scn_flood_debris_bridge_lp" );

}

swept_away_scene( scene )
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	if( scene == "beginning" )
	{
			//maps\_audio::set_mix( "mix_swept_away" );
			level.player SetClientTriggerAudioZone( "flood_swept", 0.1 );
			level.player playsound( "scn_flood_swept_away_beg_lr_ss" );
			//IPrintLnBold( "1" );
			//level.prescene = spawn( "script_origin", (6034,2388,98) );
			//level.prescene playsound( "scn_flood_swept_away_beg_lr_ss" );
			level.scene1emitter = spawn( "script_origin", (6034,2388,96) );
			wait 6.3;
			level.scene1emitter playsound( "scn_flood_swept_away_pt1_lr_ss" );
			//level.prescene ScaleVolume( 0, 0.1 );
			wait 0.1;
			//level.prescene stopsounds();
			wait 0.2;
			//level.prescene delete();
	}
	if( scene == "start" )
	{
		level.prescene = spawn( "script_origin", (6034,2388,98) );
		level.prescene playsound( "scn_flood_swept_fadein_lr_ss" );
		//maps\_audio::set_mix( "mix_swept_away" );
		level.player SetClientTriggerAudioZone( "flood_swept", 0.1 );
		level.scene1emitter = spawn( "script_origin", (6034,2388,96) );
		wait 6.1;
		level.scene1emitter playsound( "scn_flood_swept_away_pt1_lr_ss" );		
	}
	if( scene == "switch" )
	{
		level.scene2emitter = spawn( "script_origin", (6034,2388,97) );
		//level.scene2emitter playsound( "scn_flood_swept_away_pt2_lr_ss" );
		level.scene2emitter ScaleVolume( 0.0, 0 );
		level.scene2emitter ScaleVolume( 1.0, 0.3 );
		level.scene1emitter ScaleVolume( 0.0, 0.3 );
		wait 0.4;
		level.scene1emitter stopsounds();
		wait 0.1; 
		level.scene1emitter delete();
		if( IsDefined( level.prescene ) )
		{
			level.prescene delete();
		}
	}
	if( scene == "end" )
	{
		wait 10;
		level.player ClearClientTriggerAudioZone( 1.0 );
		//set_audio_zone( "flood_stealth_int" );
	}
}
skybridge_precursor_emitter()
{
	skybridge_precursor_emitter = spawn("script_origin", (5037, -2444, 96));
	skybridge_precursor_emitter playloopsound("scn_flood_skybridge_lp");
	
	flag_wait( "on_skybridge" );
	
	wait 3.0;
	skybridge_precursor_emitter ScaleVolume( 0.0, 1.5);
	wait 1.6;
	skybridge_precursor_emitter delete();
}

skybridge_logic()
{
	//wait 2.2;
	thread play_sound_in_space( "scn_flood_skybridge_ss", (5278, -1710, 135) );
	wait 6.3;
	play_sound_in_space( "scn_flood_skybridge_impact_ss", (5334, -1710, 186) );
}

skybridge_wash_away()
{
	level.player playsound("scn_flood_skybridge_wash_away");
	wait 6.0;
	play_sound_in_space( "scn_flood_skybridge_break_away", (5458, -2537, 170) );
}

mssl_launch_front_wheels()
{
	level.front_wheel_sfx = Spawn( "script_origin", (-1560, -7899, 25) );
	wait 0.05;
	level.front_wheel_sfx PlayLoopSound( "scn_flood_mssl_stuck_front_lp" );
}

mssl_launch_destory_sfx()
{
	level.lnchr_dstry_sfx = Spawn( "script_origin", (-1560, -7899, 25) );
	level.lnchr_dstry_sfx LinkTo( level.player );
	level.lnchr_dstry_sfx PlaySound( "scn_flood_mssl_destroy_ss" );
	wait 8.72;
	level.first_launcher ScaleVolume( 0.0, 2 );
	level.front_wheel_sfx ScaleVolume( 0.0, 2 );
	wait 2;
	level.first_launcher StopLoopSound();
	level.front_wheel_sfx StopLoopSound();
	wait 1.66;
	play_sound_in_space( "scn_flood_mssl_explo", ( -1743, -7314, 0 ) );	
}

sfx_diaz_stealth_kills2( guy )
{
	guy playsound( "scn_flood_diaz_stealth_kill_02" );
	wait 7.5;
	guy playsound( "scn_flood_diaz_stealth_cabinets" );
}

sfx_plr_vault()
{
	level.player PlaySound("scn_flood_stealth_plr_vault");
}

diaz_door_kick_sfx()
{
	flood_door_kick_sfx = Spawn( "script_origin", (-62, -3906, -3) );
	wait 0.05;
	flood_door_kick_sfx PlaySound( "scn_flood_diaz_door_kick" );
	wait 5;
	flood_door_kick_sfx Delete();
}

sfx_flood_int_alarm()
{
	level.flood_int_alarm01 = Spawn( "script_origin", (1.77724, -1607.53, 146.668) );
	level.flood_int_doors = Spawn( "script_origin", (21, -1233, 92) );
	wait 0.1;
	level.flood_int_alarm01 PlayLoopSound( "emt_flood_fire_alarm" );
	level.flood_int_doors PlayLoopSound( "emt_flood_doubledoor_lp" );
	
	
	flag_wait( "player_at_stairs" );
	//set_audio_zone( "flood_stairwell" );
	sfx_flood_int_alarm_stop();
	
}

sfx_flood_int_alarm_stop()
{
	if ( IsDefined( level.flood_int_alarm01 ))
	{	
		level.flood_int_alarm01 ScaleVolume( 0.0, 2 );
		level.flood_int_doors ScaleVolume( 0.0, 2 );
		wait 1;	
		level.flood_int_alarm01 StopSounds();
		level.flood_int_doors StopSounds();
		wait 0.1;
		level.flood_int_doors delete();
		level.flood_int_alarm01 delete();	
	}
}

trigger_heli_staircase()
{	
	heli_trigger = Getent( "sfx_trigger_heli", "targetname" );
	heli_trigger thread trigger_heli_wait();
}

trigger_heli_wait()
{
	self waittill( "trigger" );
	//IPrintLnBold( "BEGIN" );
	
	heli_02 = Spawn( "script_origin", (-2255,-1872,1290 ) );
	heli_02 playsound( "emt_flood_roof_heli_02" );
	heli_02 MoveTo( ( 1734,-1812,1290 ), 12 );
	
	wait 5;
	heli_01 = Spawn( "script_origin", ( 1734,-1812,1290 ) );
	heli_01 playsound( "emt_flood_roof_heli_01" );
	heli_01 MoveTo( (-2255,-1872,1290 ), 16 );
	
	wait 13;
	heli_03 = Spawn( "script_origin", ( -2963,-613,1307 ) );
	heli_03 playsound( "emt_flood_roof_heli_03" );
	heli_03 MoveTo( (4092,-6121,2233 ), 11 );
	
}

sfx_play_chopper_5( chopper )
{
	level.destruc_chopper = Spawn( "script_origin", chopper.origin );
	level.destruc_chopper LinkTo( chopper );
	wait 1;
	level.destruc_chopper playsound( "emt_flood_roof_heli_05" );
	level waittill( "swept_away" );
	if ( IsDefined( level.destruc_chopper ))
		level.destruc_chopper StopSounds();
}

sfx_kill_chopper_sound()
{
	if ( IsDefined( level.destruc_chopper ))
	{
		level.destruc_chopper ScaleVolume( 0, 1 );
		wait 1.1;
		level.destruc_chopper delete();
	}
}

sfx_chopper_4_play( chopper )
{
	chopper playsound( "emt_flood_roof_heli_04" );
}

sfx_chooper_wait_and_play( chopper )
{
	wait 3;
	chopper playsound( "emt_flood_roof_heli_06" );
}

trigger_int_building_hits()
{	
	building_hit_01 = Getent( "int_building_shake_sfx_01", "targetname" );
	building_hit_01 thread trigger_int_building_hit_01_wait();
	
	building_hit_02 = Getent( "int_building_shake_sfx_02", "targetname" );
	building_hit_02 thread trigger_int_building_hit_02_wait();
}

trigger_int_building_hit_01_wait()
{
	self waittill( "trigger" );
	//IPrintLnBold( "BEGIN _01" );
	
	level.player playsound("scn_flood_int_building_hit_01");	
}

trigger_int_building_hit_02_wait()
{
	self waittill( "trigger" );
	//IPrintLnBold( "BEGIN _02" );
	
	level.player playsound("scn_flood_int_building_hit_02");	
}

sfx_rooftop_collapse()
{
	
	level.rooftop_collapse_crumble_01_sfx = spawn( "script_origin", (31, -2198, 341) );
	
	level.rooftop_collapse_end_build_sfx = spawn( "script_origin", level.player.origin );
	level.rooftop_collapse_end_build_sfx LinkTo( level.player );
	
	//IPrintLnBold("Build Up");
	level.player SetClientTriggerAudioZone( "flood_mall_rooftop_crumble", 1.0 );
	//maps\_audio::set_mix( "mix_rooftop_crumble" );
	level.player playsound("scn_flood_mall_crumble_build_up");
	
	wait 2.95;
	//IPrintLnBold("JL: audio start Building Fall");
	thread play_sound_in_space("scn_flood_mall_crumble_building", (539, -2614, 349));
	level.rooftop_collapse_sfx ScaleVolume( 0.7, 1.1);
	
	wait 1.8;
	//IPrintLnBold("Right Side Collapse");
	level.rooftop_collapse_crumble_01_sfx playsound("scn_flood_mall_crumble_01");
	level.rooftop_collapse_end_build_sfx playsound("scn_flood_mall_end_build");
	level.rooftop_collapse_sfx ScaleVolume( 0.5, 4.1);

	//thread play_sound_in_space("scn_flood_mall_crumble_01", (54, -2154, 318));
	
	wait 5.15;
	//IPrintLnBold("Left Side Collapse");
	//thread play_sound_in_space("scn_flood_mall_crumble_01", (177, -1880, 309));
	level.player ClearClientTriggerAudioZone( 0.6 );		
}

sfx_rocket_aiming_sound()
{
	// CF - Removing specific lines but leaving for reference
	// removing the greenlight specific delay to the rocket launcher SFX
	////if ( getdvar( "greenlight" ) == "1" )
	//if( level.start_point == "dam" )
	//{
	//	wait( 3.0 );
	//}
	
	wait( 3.0 );
	thread play_sound_in_space( "scn_flood_rocket_launcher_movement_ss", (-1754, -4349, 65) );
}

sfx_rocket_explosion_sound()
{
	level.player playsound( "scn_flood_rocket_explosion_lr_ss" );
    //thread maps\_audio::set_mix( "mix_swept_away" );
    level.player SetClientTriggerAudioZone( "flood_streets_rocket_launch", 0.1 );
	wait 14;
	level.player ClearClientTriggerAudioZone( 1.0 );
	level.player playsound( "scn_flood_rocket_explosion_aftermath_ss" );
	wait 4;
	moving = spawn( "script_origin", (-1585, -2111, 153) );
	moving playsound( "scn_flood_rocket_explosion_aftermath2_ss" );
	wait 0.5;
	moving MoveTo( (-1536, -4392, 153), 6.5 );
}

sfx_mall_ceiling_debris()
{
	wait 0.55;
	thread play_sound_in_space( "scn_flood_mall_rumble_ceiling_debris", (233, -756, 168) );
	thread play_sound_in_space( "scn_flood_mall_rumble_ceiling_debris", (352, -997, 264) );
	thread play_sound_in_space( "scn_flood_mall_rumble_ceiling_debris", (363, -1302, 264) );
	thread play_sound_in_space( "scn_flood_mall_rumble_ceiling_debris", (307, -1436, 304) );
}

sfx_mall_exit_door()
{
	//flag_wait( "player_on_mall_roof" );
	//trigger = GetEnt("sfx_mall_exit_door", "targetname");
	//if ( IsDefined(trigger) )
	//{
		mall_player = spawn( "script_origin", level.player.origin );
		mall_player LinkTo( level.player );
		
		level.rooftop_collapse_sfx = spawn( "script_origin", level.player.origin );
		level.rooftop_collapse_sfx LinkTo( level.player );
		
		//trigger waittill( "trigger" );

		thread play_sound_in_space( "scn_flood_mall_wave_hit", (498, -1849, 284) );
		delaythread( 7, ::play_sound_in_space, "scn_flood_mall_wave_hit", (498, -1849, 284) );
		delaythread( 15, ::play_sound_in_space, "scn_flood_mall_wave_hit", (498, -1849, 284) );
		delaythread( 22, ::play_sound_in_space, "scn_flood_mall_wave_hit", (498, -1849, 284) );
		delaythread( 30, ::play_sound_in_space, "scn_flood_mall_wave_hit", (498, -1849, 284) );
		
		//IPrintLnBold("start pre encounter loop");
		mall_player PlayLoopSound("scn_flood_mall_rumble_lr_lp");
		mall_player ScaleVolume( 0.0, 0.001);
		
		wait 0.1;
		mall_player ScaleVolume( 1.0, 0.5);
		
		flag_wait( "mall_attack_player" );
		//IPrintLnBold("start buildup sound!");
		//IPrintLnBold("JL: audio start");
		level.rooftop_collapse_sfx playsound("scn_flood_mall_rooftop_collapse_lr");
		
		//IPrintLnBold("fading out pre encounter loop");
		mall_player ScaleVolume( 0.0, 5);

		
		flag_wait( "mall_rooftop_sfx_fadeout" );
		//wait 0.5;
		//IPrintLnBold("JL: Start Player drop audio");
		level.player playsound("scn_flood_mall_player_fall_01");
		level.rooftop_collapse_end_build_sfx ScaleVolume( 0.0, 0.7);
		wait 0.2;
		level.rooftop_collapse_sfx ScaleVolume( 0.0, 0.7);
		level.rooftop_collapse_crumble_01_sfx ScaleVolume( 0.0, 0.7);

		
		
		level waittill( "swept_away" );
		//IPrintLnBold("fade out build up sound!");
		mall_player delete();
		//mall_player PlayLoopSound("scn_flood_mall_rumble_lr_lp");
			
	//}
}

sfx_mall_hanging_falling_floor()
{
	play_sound_in_space("scn_flood_mall_crumble_02", (201, -2043, 199));
}

sfx_mall_first_screen_shake()
{
	level.player playsound("scn_flood_mall_rumble_01");
}

sfx_flood_int_door()
{
	door_sfx = spawn( "script_origin", (312, -1535, 305) );
	door_water_sfx = spawn( "script_origin", (358, -1587, 305) );
	wait 0.1;
	door_water_sfx PlayLoopSound( "scn_flood_door_water" );
	door_water_sfx ScaleVolume( 0.001, 0.1 );
	wait 1.9;
	door_sfx PlaySound( "scn_flood_int_door", "sound_done" );
	door_water_sfx ScaleVolume( 0.75, 1.5 );
	door_sfx waittill( "sound_done" );
	door_sfx Delete();
}

rooftops_mix_heli_down()
{	
	flag_wait( "rooftops_exterior_encounter_start" );
	wait 8;
	//set_mix( "mix_rooftops_helifade", 10 );
	level.player SetClientTriggerAudioZone( "overridezone1", 10 );
	wait 6;
	//set_mix( "mix_rooftops_heliback", 4 );
	level.player SetClientTriggerAudioZone( "overridezone1", 4 );
}

sfx_rooftops_wall_kick()
{
	wait 12.3;
	self playsound("scn_rooftops_wall_kick");
}

sfx_rooftops_ally_jump()
{
	wait 1.3;
	self playsound("scn_rooftops_ally_vault");
}

sfx_rooftops_player_jump()
{	
	land_trigger = Getent( "sfx_player_rooftop_vault_land", "targetname" );
	land_trigger thread trigger_player_jum_wait();
}

trigger_player_jum_wait()
{
	self waittill( "trigger" );

	level.player playsound("scn_rooftops_plr_vault");
}

wait_then_play_stealth_sounds( guy )
{
	wait 16.5;
	guy playsound( "scn_flood_diaz_stealth_kill_01" );
	wait 11.5;
	guy playsound( "scn_flood_diaz_stealth_kill_01b" );	
}

sfx_heli_rooftops_sequence(heli)
{
	thread sfx_heli_rooftops_wind(heli);
	wait 0.1;
	thread sfx_heli_rooftops_engine(heli);
	
	flag_wait( "rooftops_exterior_encounter_start" );
	//IPrintLnBold("Playing flyaway sfx");

	flag_set("rooftop_heli_flyaway");
	
	level.rooftops_heli_flyaway = Spawn( "script_origin", heli.origin );
	level.rooftops_heli_flyaway LinkTo(heli);
	level.rooftops_heli_flyaway PlaySound("scn_flood_rooftop_heli_away");
	
	if (!flag("rooftop_stairwell_mid"))
	{	
		//IPrintLnBold("Fading down flyaway sfx (because player is at bottom of stairs)");
		level.rooftops_heli_flyaway ScaleVolume(0.2, 0.1);
		wait 2;
		heli Vehicle_TurnEngineOff();
	}
	else if (!flag("rooftop_stairwell_top"))
	{
		//IPrintLnBold("Fading down flyaway sfx (because player isn't on roof)");
		level.rooftops_heli_flyaway ScaleVolume(0.6, 0.1);
		wait 0.5;
		heli Vehicle_TurnEngineOff();
	}
	else
	{
		wait 0.2;
		heli Vehicle_TurnEngineOff();
	}
	
	/* Fade Down Engine */
	wait 2.5;
	level.rooftops_heli_engine_lp ScaleVolume(0.0, 3.0);
	
}

sfx_heli_rooftops_wind(heli)
{
	//IPrintLnBold("Spawning wind");
	level.heli_wind = spawn( "script_origin", ( 0, 0, 0 ) );
	level.heli_wind hide();
	
	level.heli_wind endon( "death" );
	thread delete_on_death( level.heli_wind );
	
	level.heli_wind.origin = heli.origin + (0, 0,-200);
	level.heli_wind linkto( heli );

	level.heli_wind PlayLoopSound( "scn_flood_rooftop_heli_wind_lp" );
	
	wait 0.1;
	level.heli_wind_debris = Spawn( "script_origin", (0, 0, 0));
	level.heli_wind_debris PlayLoopSound("scn_flood_rooftop_heli_debris_lp");
	level.heli_wind_debris LinkTo(level.player);
	
	flag_wait("rooftop_stairwell_top");
	
	/* If Heli hasn't flown away yet */
	//if ( !flag("rooftop_heli_flyaway") )
	//{
		level.heli_wind_debris SetVolume(0.32, 0.4);
		
		flag_wait("rooftop_heli_flyaway");
		wait 5;
		level.heli_wind_debris ScaleVolume(0.0, 3.0);
		wait 3;
		level.heli_wind_debris StopLoopSound("scn_flood_rooftop_heli_debris_lp");
	//}
	
	wait 5;
	level.heli_wind delete();
	level.heli_wind_debris delete();
}

sfx_heli_rooftops_engine(heli)
{
	level.rooftops_heli_engine_lp = Spawn( "script_origin", heli.origin );
	level.rooftops_heli_engine_lp LinkTo(heli);
	level.rooftops_heli_engine_lp PlayLoopSound("scn_flood_rooftop_heli_lp");
	
	level.rooftops_heli_engine_lp endon( "death" );
	thread delete_on_death( level.rooftops_heli_engine_lp );
	
	level.rooftops_heli_engine_lp ScaleVolume(0.8, 0.1);
	
	flag_wait("rooftop_stairwell_top");
	
	// Heli flew away or started to before reaching top of stairs.
	if ( flag("rooftop_heli_flyaway") )
	{
		//IPrintLnBold("Fading up Heli Flyaway sound");
		if (isdefined(level.rooftops_heli_flyaway))
			level.rooftops_heli_flyaway ScaleVolume(1.0, 0.7);
	}
	
	// Heli hasn't flown away yet. Reached top of stairs. Fade up engine.
	else
	{
		level.rooftops_heli_engine_lp ScaleVolume(1.0, 0.2);
	}
	
	wait 10;
	// Delete engine
	level.rooftops_heli_engine_lp delete();
}

sfx_stairwell_wind()
{
	level.rooftops_stairwell_wind = Spawn( "script_origin", (6444, -1315, 392) );
	level.rooftops_stairwell_wind PlayLoopSound("scn_flood_stairwell_wind_lp");
	level.rooftops_stairwell_wind SetVolume(0.3, 0.4);
	
	flag_wait("rooftop_stairwell_mid");

	if (isdefined(level.heli_wind_debris))
		level.heli_wind_debris SetVolume(0.11, 2);
	
	flag_wait("rooftop_stairwell_top");
	
	level.rooftops_stairwell_wind ScaleVolume(0.0, 2.0);
	wait 2;
	level.rooftops_stairwell_wind delete();
}

sfx_stairwell_heli_trig_setup()
{
	stairwell_trig = GetEnt( "trigger_rooftop_exit_stairwell", "targetname" );
	stairwell_trig thread sfx_stairwell_heli_trig();
}

sfx_stairwell_heli_trig()
{
	self waittill( "trigger" );
	
	flag_set( "rooftop_stairwell_top" );
}

sfx_stairwell_mid_trig_setup()
{
	stairwell_mid_trig = GetEnt( "trigger_rooftop_mid_stairwell", "targetname" );
	stairwell_mid_trig thread sfx_stairwell_mid_trig();
}

sfx_stairwell_mid_trig()
{
	self waittill( "trigger" );
	
	flag_set( "rooftop_stairwell_mid" );
}

flood_convoy_chopper1_sfx()
{
	self PlaySound( "scn_flood_convoyheli_01" );
		wait 4;
		self ScaleVolume( 0, 4 );
		wait 4;
		self StopSounds();
}

flood_convoy_chopper2_sfx()
{
	self PlaySound( "scn_flood_convoyheli_02" );
}

flood_convoy_chopper4_sfx()
{
	self PlaySound( "scn_flood_convoyheli_03" );
}

flood_convoy_attackheli01_sfx()
{
	self PlaySound( "scn_flood_convoy_attackheli_01" );
}

flood_convoy_attackheli02_sfx()
{
	wait 6.06;
	self PlaySound( "scn_flood_convoy_attackheli_02" );
}

flood_convoy_sfx( spawn_num )
{
	if ( spawn_num == 0 )
	{
		self PlaySound( "scn_flood_convoypass_ss_01" );
	}
	if ( spawn_num == 1 )
	{
		self PlaySound( "scn_flood_convoypass_ss_02" );
	}
	if ( spawn_num == 2 )
	{
		self PlaySound( "scn_flood_convoypass_ss_03" );
	}
	if ( spawn_num == 3 )
	{
		self PlaySound( "scn_flood_convoypass_ss_04" );
	}
	if ( spawn_num == 4 )
	{
		self PlaySound( "scn_flood_convoypass_ss_05" );
	}
	if ( spawn_num == 5 )
	{
		self PlaySound( "scn_flood_convoypass_ss_06" );
	}
	if ( spawn_num == 6 )
	{
		self PlaySound( "scn_flood_convoypass_ss_07" );
	}
}

flood_convoy_exp_sfx()
{
	convoy_exp_sfx01 = spawn( "script_origin", ( -1600, -8900, -9 ) );
	convoy_exp_sfx03 = spawn( "script_origin", ( -1600, -8600, -9 ) );
	flag_wait("start_heli_attack");
	wait 3.6;
	convoy_exp_sfx01 PlaySound( "exp_armor_vehicle" );
	wait 6;
	convoy_exp_sfx01 delete();
	convoy_exp_sfx03 delete();
}

flood_launcher_crash_sfx()
{
	wait 2;
	self PlaySound( "scn_flood_mssl_crash_ss" );
}

sfx_parking_lot_explode()
{
	level.player playsound( "scn_flood_parklot_exp_lr_ss" );
}

sfx_heli_jump_script( guy )
{
	level.heli_jump = spawn( "script_origin", (0, 0, 0) );
	level.heli_jump playsound( "scn_flood_exfil_heli_jump" );
	thread sfx_change_zone_exfil();
	if( isdefined( level.ending_heli ))
	{
		wait 3;
		level.ending_heli scalevolume( 0, 5 );
	}
}

sfx_change_zone_exfil()
{
	level.player SetClientTriggerAudioZone( "flood_exfil_01", 6 );
}

sfx_change_zone_exfil2()
{
	level.player SetClientTriggerAudioZone( "flood_exfil_02", 1 );
}

sfx_alarms_script( guy )
{
	level.alarms = spawn( "script_origin", (0, 0, 0) );
	level.alarms playloopsound( "scn_flood_heli_alarms" ); 	
}

sfx_stop_alarms_script( guy )
{
	if( isdefined( level.alarms ))
	{
		level.alarms scalevolume( 0, 0.2 );
		wait 0.2;
		level.alarms stopsounds();
		wait 0.1;
		level.alarms delete();
	} 	
}


sfx_slomo_script( guy )
{
	level.slomo = spawn( "script_origin", (0, 0, 0) );
	level.slomo playsound( "scn_flood_exfil_slowmo" );
	thread music_flood_exfil_end();
	thread sfx_change_zone_exfil2();
	if( isdefined( level.heli_jump ))
	{
		level.heli_jump scalevolume( 0, 0.2 );
		wait 0.25;
		level.heli_jump delete();
	}
}

music_flood_exfil_end()
{
	wait 2.3;
	music_play( "mus_flood_exfil_end_ss" );
}

sfx_gun_grab_script( guy )
{
	level.gun_grab = spawn( "script_origin", (0, 0, 0) );
	level.gun_grab playsound( "scn_flood_exfil_gun_grab" );
}

sfx_ally_grab_script( guy )
{
	level.ally_grab = spawn( "script_origin", (0, 0, 0) );
	level.ally_grab playsound( "scn_flood_exfil_ally_grab" );
	thread sfx_change_zone_exfil();
}

sfx_plane_crash_script( guy )
{
	level.plane_crash = spawn( "script_origin", (0, 0, 0) );
	level.plane_crash playsound( "scn_flood_exfil_heli_crash" );
	if( isdefined( level.slomo ))
	{
		level.slomo scalevolume( 0, 0.2 );
		if( isdefined( level.ally_grab ))
		{
			level.ally_grab scalevolume( 0, 0.2 );
			wait 0.25;
			level.ally_grab delete();
		}
		else
		{
			wait 0.25;	
		}
		level.slomo delete();
	}
}

sfx_wake_up_script( guy )
{
	level.wake_up = spawn( "script_origin", (0, 0, 0) );
	level.wake_up playsound( "scn_flood_exfil_wakeup" );
	if( isdefined( level.plane_crash ))
	{
		level.plane_crash scalevolume( 0, 2 );
		wait 2.1;
		level.plane_crash delete();
	}
}

sfx_save_script( guy )
{
	level.save_end = spawn( "script_origin", (0, 0, 0) );
	level.save_end playsound( "scn_flood_exfil_end" );
	if( isdefined( level.wake_up ))
	{
		level.wake_up scalevolume( 0, 2 );
		wait 2.1;
		level.wake_up delete();
	}
}

play_helicopter_leaving_sound()
{
	level.ending_heli playsound( "scn_flood_exfil_helicopter_intro" );
}