#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;
#include maps\_utility_code;
#include maps\_audio_code;


main()
{
	aud_init_globals();
	aud_ignore_timescale();
	
	/#
	thread rvn_music_dvar_thread();
	#/
}

aud_init_globals()
{
	level.aud_old_rotation = 0;
	level.aud_old_height = 0;
	level.aud_updating_movement = false;
	level.aud_can_play_rope_creak = true;
	level.aud_can_play_rappel_footsteps = true;
	level.aud_can_play_bldg_shake = true;
	level.aud_ext_bombs = false;
	level.aud_can_play_outside_wind_gusts = false;
	level.aud_outside_music = spawn( "script_origin", (-22880, 658, 13956) );
	level.aud_outside_crowd = spawn( "script_origin", (-22880, 658, 13956) );
	level.aud_outside_music_rear = spawn( "script_origin", (-22880, 658, 13956) );
	level.aud_outside_crowd_rear = spawn( "script_origin", (-22880, 658, 13956) );
	level.aud_turret_loop_on = false;
	level.aud_weapon_strobe = spawn( "script_origin", level.player.origin );
	level.aud_wind_state_last = "down";
	level.aud_wind_loop = spawn( "script_origin", level.player.origin );
	level.aud_wind_loop LinkTo( level.player );
	level.aud_flap_loop = spawn( "script_origin", level.player.origin );
	level.aud_flap_loop LinkTo( level.player );
	level.aud_slow_mo = spawn( "script_origin", level.player.origin );
	level.aud_slow_mo LinkTo( level.player );
}

aud_ignore_timescale()
{
	SoundSetTimeScaleFactor("norestrict2d", 0);
	SoundSetTimeScaleFactor("auto", 0);
	SoundSetTimeScaleFactor("voice", 0);
	SoundSetTimeScaleFactor("local3", 0);
}

// CHECKPOINTS

aud_check( ref )
{
	if ( ref == "intro" )
	{
		level.player SetClientTriggerAudioZone("intro");
		wait(1);
		thread intro_convoy();
		wait(5);
		
		set_mix("intro2", 3);
		
		wait(22.9);
	
		level.player SetClientTriggerAudioZone("ext_roof");
	}
	else if ( ref == "zipline" )
	{
		level.player SetClientTriggerAudioZone("ext_roof");	
		level.aud_ext_bombs = true;
	}
	else if ( ref == "rappel_stealth" )
	{
		level.player SetClientTriggerAudioZone("ext_stealth_rappel");
	}
	else if ( ref == "building_entry" )
	{
		level.player SetClientTriggerAudioZone("ext_rappel");
		level.aud_ext_bombs = false;
	}
	else if ( ref == "shadow_kill" )
	{
		
	}
	else if ( ref == "inverted" )
	{
		aud_party( "out_music" );	
		thread aud_play_loop_until_flag( "outside_party_crowd_3d", (-23084, 1715, 25130),"player_has_exited_the_building" );
		thread aud_play_loop_until_flag( "outside_party_crowd_3d", (-22988, 1715, 25130),"player_has_exited_the_building" );
		thread aud_play_loop_until_flag( "amb_ext_wind_hum_window_lp", (-23084, 1715, 25130),"player_has_exited_the_building" );
		thread aud_play_loop_until_flag( "amb_ext_wind_hum_window_lp", (-22988, 1715, 25130),"player_has_exited_the_building" );
	}
	else if ( ref == "courtyard" )
	{
		aud_party( "out_amb" );
	}
	else if ( ref == "rappel" )
	{
		
	}
	else if ( ref == "bar" )
	{
		
	}
	else if ( ref == "junction" )
	{
		
	}
	else if ( ref == "garden" )
	{
		level.player SetClientTriggerAudioZone("ext_rappel");
		wait(0.5);
		aud_start_garden_events();
	}
	else if ( ref == "stairwell" )
	{
		level.player SetClientTriggerAudioZone("int_collapse");
	}
	else if ( ref == "atrium" )
	{
		level.player SetClientTriggerAudioZone("int_collapse");
		thread aud_collapse( "rumble" );
	}
	else if ( ref == "horizontal" )
	{
		level.player SetClientTriggerAudioZone("int_horizontal");
		thread aud_collapse( "window_check" );
	}
	else if ( ref == "ending" )
	{
		level.player SetClientTriggerAudioZone("int_horizontal");
	}
	else if ( ref == "ending_ground" )
	{
		level.player SetClientTriggerAudioZone( "int_postgarden" );
	}
}

 
// EVENT FUNCS

aud_intro( ref )
{
	if ( ref == "r_goggles" )
	{
		level.allies[ level.const_rorke ] PlaySound("rorke_goggles");
		wait(1.1);
		level.allies[ level.const_rorke ] PlaySound("rorke_intro_movement");
		
		wait(3.4);
		level.allies[ level.const_rorke ] PlaySound("rorke_intro_movement2");
	}
	else if ( ref == "r_jump" )
	{
		wait(10.5);
		level.allies[ level.const_rorke ] PlaySound("rorke_intro_jump");
	}
}

intro_convoy()
{
	wait(13);
	thread play_sound_in_space("crnd_intro_convoy_1", (-29501, -2995, 28143));
	thread play_sound_in_space("crnd_intro_convoy_2", (-27321, -5488, 28143));
	thread play_sound_in_space("crnd_intro_convoy_3", (-29114, -7564, 28143));
	thread play_sound_in_space("crnd_intro_convoy_4", (-31379, -6353, 28312));
}

//aud_intro_choppers(choppers)
//{
////	foreach (chopper in choppers)
////	{
////		chopper VehicleUseAltBlendedAudio(true);
////	}
////	
////	wait(0.5);
////	
////	level.player PlaySound("intro_choppers_front");
//}

//aud_binoculars_foley()
//{
//	self PlaySound( "fly_binoc_foley" );
//}

aud_binoculars( ref )
{
	if ( ref == "on" )
	{
		self PlaySound( "fly_binoc_vision_on" );
		set_mix("binocs");
	}
	else if ( ref == "off" )
	{
		self PlaySound( "fly_binoc_vision_off" );
		set_mix("ext_roof");
	}
	else if ( ref == "bg_loop" )
	{
		bg_loop_sound = Spawn( "script_origin", self.origin );
		bg_loop_sound PlayLoopSound( "fly_binoc_bg_loop" );
		
		self waittill( "stop_binocular_bg_loop_sound" );
		
		bg_loop_sound StopLoopSound();
		bg_loop_sound Delete();
	}
	else if ( ref == "zoom_in" )
	{
		self PlaySound( "fly_binoc_zoom_in" );
	}
	else if ( ref == "zoom_out" )
	{
		self PlaySound( "fly_binoc_zoom_out" );
	}
//	else if ( ref == "on_target" )
//	{
//		self PlaySound( "fly_binoc_circle_reticle" );
//	}
	else if ( ref == "scan_loop" )
	{
		self.scan_loop_sound = Spawn( "script_origin", self.origin );
		self.scan_loop_sound PlayLoopSound( "fly_binoc_scan_loop" );
		
		self waittill_any( "stop_binocular_scan_loop_sound", "stop_binocular_bg_loop_sound" );
		
		self.scan_loop_sound StopLoopSound();
		self.scan_loop_sound Delete();
		self.scan_loop_sound = undefined;
	}
	else if ( ref == "scan_loop_red" )
	{
		self.scan_loop_red_sound = Spawn( "script_origin", self.origin );
		self.scan_loop_red_sound PlayLoopSound( "fly_binoc_scan_loop_red" );
		
		self waittill_any( "stop_binocular_scan_loop_red_sound", "stop_binocular_bg_loop_sound" );
		
		self.scan_loop_red_sound StopLoopSound();
		self.scan_loop_red_sound Delete();
		self.scan_loop_red_sound = undefined;
	}
	else if ( ref == "positive" )
	{
		self PlaySound( "fly_binoc_scan_positive" );
	}
	else if ( ref == "negative" )
	{
		self PlaySound( "fly_binoc_scan_negative" );
	}
	else if ( ref == "seeker_move" )
	{
		self PlaySound( "fly_binoc_seeker_move" );
	}
	else if ( ref == "seeker_on" )
	{
		self PlaySound( "fly_binoc_seeker_on" );
	}
	else if ( ref == "seeker_off" )
	{
		self PlaySound( "fly_binoc_seeker_off" );
	}
}

aud_zipline( ref, loc )
{
	if ( ref == "unfold" )
	{
		wait(1.25);
		level.player PlaySound("zipline_launcher_unfold");
		
		level.aud_zipline_launcher_turn_cooldown = false;
		level.aud_zipline_launcher_loop = spawn( "script_origin", level.player.origin );
		
		wait(4.2);
		
		level.player PlaySound("zipline_launcher_anchor");
		flag_wait("player_fired_zipline");
		
		level.aud_zipline_launcher_loop ScaleVolume(0, 0.05);
		waitframe();
		
		level.aud_zipline_launcher_loop StopLoopSound();
		waitframe();
		
		wait(2);
		
		level.aud_zipline_launcher_loop Delete();
	}
	else if ( ref == "unfold2" )
	{
		wait(6.1);
		thread play_sound_in_space("zipline_launcher_unfold_2", loc);
		wait(8.3);
		thread play_sound_in_space("zipline_launcher_anchor_2", loc);
	}
	else if ( ref == "unfold3" )
	{
		wait(0.2);
		thread play_sound_in_space("zipline_launcher_unfold_3", loc);
		wait(7.9);
		thread play_sound_in_space("zipline_launcher_anchor_3", loc);
	}
	else if ( ref == "aim" )
	{
		maxrange = 0.3;
		minrange = 0.01;
			
		if (!level.aud_turret_loop_on)
		{
			level.aud_turret_loop_on = true;	
			level.aud_zipline_launcher_loop PlayLoopSound("zipline_fire_turn_horizontal");
		}
		
		vol = 0.3;
		
		if (loc < maxrange)
		{
			
			vol *= (loc - minrange) / (maxrange - minrange);
			PrintLn((loc - minrange) / (maxrange - minrange));
		}
		
		level.aud_zipline_launcher_loop SetVolume(vol, 0.1);
		level.aud_zipline_launcher_loop SetPitch(1);
		
	}
	else if ( ref == "stop_loop" )
	{
		level.aud_zipline_launcher_loop ScalePitch(0.5, 0.25);
		level.aud_zipline_launcher_loop ScaleVolume(0, 0.25);
	}
	else if ( ref == "rope_shot_ally" )
	{
		thread play_sound_in_space("zipline_fire", loc);
		thread play_sound_in_space("zipline_post_fire", loc);
	}
	else if ( ref == "rope_shot_verb" )
	{
		thread play_sound_in_space("zipline_fire_verb", loc);
		thread play_sound_in_space("zipline_post_fire", loc);
	}
	else if ( ref == "rope_shot" )
	{
		thread play_sound_in_space("zipline_fireb", loc);
		thread play_sound_in_space("zipline_post_fire", loc);
	}
	else if ( ref == "start" )
	{
		// thread set_mix("pre_zipline");
		thread aud_zipline( "pre" );
		level.player SetClientTriggerAudioZone("ext_zipline");
		wait(0.9);
		
		level.player PlaySound("rappel_clickin");
		wait(0.3);
		
		level.player PlaySound("zipline_movement_plr");
		wait(0.2);
		
		thread zipline_mvmt_npc();
		wait(2);;
		
		level.player PlaySound("zipline_wind");
		thread aud_zipline( "wind" );
		level.player PlaySound("plr_breathe_exert_2");
		// thread set_mix("zipline");
		wait(1);
		thread aud_party( "fade_in" );
	}
	else if ( ref == "pre" )
	{
		level.player PlaySound("step_run_plr_concrete");
		wait(0.72);
		
		level.player PlaySound("step_run_plr_concrete");
		wait(0.5);
		
		level.player PlaySound("step_run_plr_concrete");
		wait(0.25);
		
		level.player PlaySound("step_run_plr_concrete");
		wait(0.25);
		
		level.player PlaySound("step_run_plr_concrete");
		wait(0.21);
		
		level.player PlaySound("step_run_plr_concrete");
		wait(0.21);
		
		level.player PlaySound("step_run_plr_concrete");
		wait(0.76);
		
		level.player PlaySound("rappel_rope_creak");
	}
	else if ( ref == "detach" )
	{
		wait(7.2);
		level.player PlaySound("rappel_clipout");
		level.player PlaySound("wind_zipline_detach");
		
		wait(1.0);
		
		wait(0.8);
		level.player PlaySound("zipline_movement_2");
		
		wait(1.7);
		level.player PlaySound("plr_breathe_exert");
		
		wait(6.4);
		level.player SetClientTriggerAudioZone("ext_stealth_rappel", 5 );
	}
	else if ( ref == "wind" )
	{
		thread _aud_zip_wind_1();
		
		level.player PlaySound("wind_gust_near");
		
		ent2 = Spawn("script_origin", level.player.origin);
		ent2 PlayLoopSound("wind_ext_lp_3");
		ent2 ScaleVolume(0);
		
		ent2 ScaleVolume(0.7, 3);
		wait(3.6);
		
		ent2 ScaleVolume(0, 0.25);
		wait(1);
		
		ent2 StopLoopSound();
		wait(0.1);
		ent2 Delete();
	}
	else if ( ref == "landing" )
	{
		//wait(0.1);
		level.player PlaySound("rappel_land");
		wait(1.4);
		level.player PlaySound("rappel_land");
	}
}

zipline_mvmt_npc()
{
	snd = Spawn( "script_origin",(-28957, -4495, 27315));
	dst = (-24549, 516, 26865);
	snd PlaySound("zipline_movement_npc", "sounddone");
	snd MoveTo(dst, 10.25);
	snd waittill("sounddone");
	snd delete();
}

_aud_zip_wind_1()
{
	ent = Spawn("script_origin", level.player.origin);
	ent PlayLoopSound("wind_ext_lp_2");
	ent ScaleVolume(0);
	wait(1.5);
	
	ent ScaleVolume(0.5, 3);	
	wait(5.5);
	
	ent ScaleVolume(0, 3);
	wait(4);
	
	ent StopLoopSound();
	wait(0.1);
	ent Delete();
}

//!RAPPEL - EVENTS

aud_rappel( ref )
{
	if ( ref == "jump" )
	{
		level.player PlaySound("rappel_pushoff");
		if (flag("player_has_exited_the_building") && !flag("inverted_rappel_finished"))
		{
			wait(1.35);
		}
		else	
		{
			wait(1.9);	
		}
		level.player PlaySound("rappel_land");
	}
	else if ( ref == "foot" )
	{
		if (level.aud_can_play_rappel_footsteps)
		{
			level.aud_can_play_rappel_footsteps = false;
			level.player PlaySound("step_run_plr_rappel");
			thread aud_rappel( "creak" );
			
			wait(0.15);
			level.aud_can_play_rappel_footsteps = true;
		}
	}
	else if ( ref == "event1" )
	{
		ent = Spawn("script_origin", level.player.origin);
		ent PlayLoopSound("wind_ext_lp_sur");
		flag_wait("rappel_stealth_finished");
		wait(4);
		ent StopSounds();
		wait(0.1);
		ent delete();
	}
	else if ( ref == "creak" )
	{
		if (level.aud_can_play_rope_creak)
		{
			level.aud_can_play_rope_creak = false;
			level.player playsound("rappel_rope_creak");
			wait( RandomFloatRange(2, 6) );
			level.aud_can_play_rope_creak = true;
		}
	}
	else if ( ref == "r_glass" )
	{
		level.allies[ level.const_rorke ] PlaySound("building_entry_glass_rorke_preentry");
		wait(2.2);
		
		level.allies[ level.const_rorke ] PlaySound("building_entry_glass_rorke");
		wait(5.4);
		
		level.allies[ level.const_rorke ] PlaySound("building_entry_glass_rorke_punch");
		wait(0.6);
		
		thread play_sound_in_space("building_entry_glass_rorke_smash", ( -22940, 1867, 25080 ) );
		wait(0.6);
		
		level.allies[ level.const_rorke ] PlaySound("building_entry_glass_rorke_land");
	}
	else if ( ref == "enter" )
	{
		level.player PlaySound("building_entry_glass");
		wait(1.7);
		
		level.player PlaySound("building_entry_glass2");
	}
	else if ( ref == "enter2" )
	{
		level.player PlaySound("building_entry_glass4");
		wait(0.5);
		
		level.player PlaySound("wind_gust_fall");
		wait(1);
		
		level.player PlaySound("building_entry_glass_kick_through");
		
		level.aud_outside_music SetVolume(1);
		level.aud_outside_music_rear SetVolume(1);
		
		level.player SetClientTriggerAudioZone("int_building_entry", 1);
		level.player PlaySound("building_entry_glass3");
		level.aud_ext_bombs = false;
		wait(1.2);
		
		level.player PlaySound("rappel_clipout");
		level.player ClearClientTriggerAudioZone(1);
		wait(3);
		
		level.aud_can_play_outside_wind_gusts = true;
		thread aud_play_random_wind_gust( (-23090, 1760, 25132), 6, 13 );
		thread aud_play_random_wind_gust( (-22982, 1760, 25132), 5, 10 );
	}
}

aud_do_wind( state )
{
	if ( state == "up" && level.aud_wind_state_last != "up" )
	{
		level.player PlaySound("wind_gust_rappel");
		level.player PlaySound("rappel_rope_creak");
		
		level.aud_wind_loop PlayLoopSound("wind_gust_near_lp");
		level.aud_flap_loop PlayLoopSound("rappel_wind_flap");
		
		level.aud_wind_loop SetVolume(0.5, 2);
		level.aud_flap_loop SetVolume(0.5, 3);
		
		thread aud_rand_creak();
		thread aud_rand_gust_near();
		
	}
	else if (state == "down" && level.aud_wind_state_last != "down")
	{
		thread aud_stop_wind();
	}
	
	level.aud_wind_state_last = state;
}

aud_rand_creak()
{
	wait( RandomFloatRange(0, 2) );
	level.player PlaySound("rappel_rope_creak");
	wait( RandomFloatRange(0,5, 2) );
	level.player PlaySound("rappel_rope_creak");
}

aud_rand_gust_near()
{
	wait( RandomFloatRange(1.0, 2.5) );
	level.player PlaySound("wind_gust_near");	
}

aud_stop_wind()
{
	level.aud_wind_loop SetVolume(0, 7);
	level.aud_flap_loop SetVolume(0, 5);
	wait(5);
	level.aud_flap_loop StopLoopSound();	
	wait(2);
	level.aud_wind_loop StopLoopSound();	
}

aud_play_random_wind_gust( loc, random_min, random_max )
{
	while (level.aud_can_play_outside_wind_gusts)
	{
		play_sound_in_space( "wind_gust_close", loc );
		wait( RandomFloatRange(random_min, random_max) );
	}
}

aud_start_pseudo_occlusion()
{
	trigger = GetEnt( "aud_ai_trigger", "targetname" );
	trigger2 = GetEnt( "aud_ai_trigger2", "targetname" );
	has_set_last = false;	
	aud_filter_on();
	level.player SetEqLerp( 1, 1 );
	
	while ( !flag( "player_has_exited_the_building" ) && !flag( "enemies_aware" ) )
	{
		if ( flag(	"aud_player_in_alcove" ) )
		{
			if ( IsAlive( level.first_patroller ) && level.first_patroller IsTouching( trigger ) == false )
			{
				if ( !has_set_last )
				{
					aud_filter_on();
					thread aud_lerp_eq_over_time(1);
					has_set_last = true;
				}
			}
			else // level.first_patroller IsTouching( trigger ) == true
			{
				if ( has_set_last )
				{
					aud_filter_off();
					thread aud_lerp_eq_over_time(0);
					has_set_last = false;
				}
			}
		}
		else  // flag(	"aud_occlusion_player_in_alcove" )
		{
			if ( IsAlive( level.first_patroller ) && level.player IsTouching( trigger2 ) == false )
			{
				if ( !has_set_last )
				{
					aud_filter_on();
					level.player SetEqLerp( 1, 1 );
					has_set_last = true;
				}
			}
			else if ( has_set_last )
			{
				aud_filter_off();
				level.player SetEqLerp( 1, 1 );
				has_set_last = false;
			}
		}	
		wait(0.05);
	}
	
	aud_filter_off();
	level.player SetEqLerp( 1, 1 );
}

aud_filter_on()
{
	level.player SetEq( "voice", 1, 0, "highshelf", -7, 800, 1);
	level.player SetEq( "voice", 1, 1, "highshelf", -5, 1200, 1);
}

aud_filter_off()
{
	level.player SetEq( "voice", 1, 0, "highshelf", 0, 400, 1);
	level.player SetEq( "voice", 1, 1, "highshelf", 0, 800, 1);
}

aud_lerp_eq_over_time( index )
{
	self endon("enemy_aware");
	for (i = 0; i < 40; i++)
	{
		level.player SetEqLerp( (i * 0.025) + 0.025, index );
		wait(0.05);
	}
}

aud_enemy_foley()
{
	self endon( "enemy_aware" );
	flag_wait( "start_power_junction_patrol_chatter" );
	wait(30);
	if ( IsDefined( level.first_patroller ) && IsAlive( level.first_patroller ) )
		level.first_patroller PlaySound("shadowkill_enemy_foley2");
	wait(2.75);
	if ( IsDefined( level.first_patroller ) && IsAlive( level.first_patroller ) )
		level.first_patroller PlaySound("shadowkill_enemy_foley1");
	
}

aud_play_loop_until_flag( alias, origin, flagname )
{
	ent = Spawn( "script_origin", origin );
	ent PlayLoopSound( alias );
	
	flag_wait( flagname );
	
	ent ScaleVolume(0, 1);
	wait(1);
	ent StopLoopSound();
	waitframe();
	ent delete();
}

aud_virus( ref, ent )
{
	if ( ref == "plant" )
	{
		level.player PlaySound("plant_virus_6");
		
		wait(0.35);
		level.player PlaySound("plant_virus");
		
		wait(4.5);
		level.player PlaySound("plant_virus_2");
		
		thread aud_virus( "upload" );
		thread aud_start_pseudo_occlusion();
	}
	else if ( ref == "replant" )
	{
		level.player PlaySound("plant_virus_6");
		
		wait(0.35);
		level.player PlaySound("plant_virus");
		
		wait(4.5);
		level.player PlaySound("plant_virus_2");
	}
	else if ( ref == "upload" )
	{
		ent = spawn("script_origin", level.player.origin);
		
		aud_virus( "loop", ent );
		level.player PlaySound("plant_virus_3");
		
		waitframe();
		ent Delete();
	}
	else if ( ref == "loop" )
	{
		thread aud_virus( "outside_ambience" );
		thread aud_enemy_foley();
		
		while ( !flag("virus_upload_bar_complete") )
		{
			flag_wait("player_start_upload");
			wait(0.1);
			level.player PlaySound("plant_virus_2");
			wait(0.15);
			
			ent PlayLoopSound("plant_virus_beep_loop");
			ent ScaleVolume(0.4);
	
			flag_wait_any( "player_stop_upload", "virus_upload_bar_complete" );
			ent ScaleVolume(0, 0.1);
			wait(0.1);
			ent StopLoopSound();
		}
		
		wait(0.3);
		level.player PlaySound("plant_virus_end");
	}
	else if ( ref == "outside_ambience" )
	{
		flag_wait( "virus_upload_bar_complete" );
		thread aud_party( "out_music" );
		
		thread aud_play_loop_until_flag( "outside_party_crowd_3d", (-23084, 1715, 25130),"player_has_exited_the_building" );
		thread aud_play_loop_until_flag( "outside_party_crowd_3d", (-22988, 1715, 25130),"player_has_exited_the_building" );
		thread aud_play_loop_until_flag( "amb_ext_wind_hum_window_lp", (-23084, 1715, 25130),"player_has_exited_the_building" );
		thread aud_play_loop_until_flag( "amb_ext_wind_hum_window_lp", (-22988, 1715, 25130),"player_has_exited_the_building" );	
	}
	else if ( ref == "stop" )
	{
		level.player PlaySound("plant_virus_5");	
	}
	else if ( ref == "restart" )
	{
		wait(0.7);
		level.player PlaySound("plant_virus_4");
	}
	else if ( ref == "r_approach" )
	{
		wait(6.6);
		thread play_sound_in_space("plant_virus_rorke_start", (-21917, 2888, 25113));
	}
	else if ( ref == "r_loop" )
	{
		anim_ref = level.scr_anim[ "rorke" ][ "virus_upload_loop_rorke" ][ 0 ];
		last_time = 1;
		
		while ( !flag("start_power_junction_patrol_chatter") )
		{
			current_time = self GetAnimTime( anim_ref );
			
			if ( current_time < last_time)
			{
				level.allies[ level.const_rorke ] StopSounds();
				wait(0.1);
				level.allies[ level.const_rorke ] PlaySound("plant_virus_rorke");
			}
		
			last_time = current_time;
			waitframe();
		}
		
		level.allies[ level.const_rorke ] StopSounds();
	}
	else if ( ref == "r_end" )
	{
		wait(5.25);
		level.allies[ level.const_rorke ] PlaySound("plant_virus_rorke_end");
	}
	else if ( ref == "kill" )
	{
		wait(1.7);
		level.allies[ level.const_rorke ] PlaySound( "rorke_stealth_kill" );
	}
	else if ( ref == "activate" )
	{
		level.player PlaySound("activate_virus");
		wait(2);
		level.player PlaySound("lights_power_down_2");
	}
}

//INVERTED
aud_invert( ref )
{
	if ( ref == "start" )
	{
		level.player PlaySound("inverted_hookup");
		level.allies[ level.const_rorke ] PlaySound("inverted_hookup_merrick");
		level.aud_can_play_outside_wind_gusts = false;
		
		wait(3);
		level.player SetClientTriggerAudioZone("ext_inverted_rappel", 1);
		aud_party( "crowd" );
		waitframe();
		thread aud_party( "crowd_swell" );
		
		wait(2.6);
//		level.player PlaySound("wind_gust_med");
//		level.player PlaySound("wind_gust_near");
		
		//wait(3);
		level.player PlaySound("wind_gust_near");
	}
	else if ( ref == "knife" )
	{
		wait(0.44);
		level.player PlaySound("crnd_inverted_knife_out");
	}
	else if ( ref == "ready" )
	{
		level.player PlaySound("crnd_inverted_pounce_ready");
	}
	else if ( ref == "pounce" )
	{
		level.player PlaySound("crnd_inv_kill_drop");
		thread aud_inverted_kill_firstguy();
		//level.player PlaySound("crnd_inverted_pounce");
		level.player ClearClientTriggerAudioZone(0.5);
	}
	else if ( ref == "throw" )
	{
		ent = spawn("script_origin", level.player.origin);
		ent	PlaySound("crnd_inv_kill_slowknife");
		wait(0.5);
		ent PlaySound("crnd_inv_kill_slowknife_death");
		wait(3);
		ent delete();
	}
	else if ( ref == "slow" )
	{
		level.aud_slow_mo PlaySound("crnd_inv_kill_slowmo");
	}
	else if ( ref == "slow_end" )
	{
		level.aud_slow_mo SetVolume(0, 0.5);
		wait(0.5);
		level.aud_slow_mo StopSounds();
	}
	else if ( ref == "hit" )
	{
		thread aud_inverted_kill_finish();
		wait(0.3);
		thread play_sound_in_space("crnd_inverted_knife_hit", (-23110, 1745, 22860) );
	}
	else if ( ref == "r_pounce" )
	{
		//thread play_sound_in_space("crnd_inverted_rorke_pounce", (-23044, 1744, 22845) );
	}
}

aud_inverted_kill_firstguy()
{
	wait(0.55);
	ent = spawn("script_origin", level.player.origin);
	ent	PlaySound("crnd_inv_kill_land", "sounddone");
	wait(0.1);
	ent PlaySound("crnd_inv_kill_knife_in_1");
	wait(0.6);
	thread play_sound_in_space("generic_pain_enemy_8", (-23238, 1730, 22818) );
	wait(0.45);
	ent PlaySound("crnd_inv_kill_knife_in_2");
	wait(0.4);
	ent PlaySound("crnd_inv_kill_transition", "sounddone");
	wait(0.35);
	ent PlaySound("crnd_inv_kill_knife_out");
	ent waittill("sounddone");
	ent delete();
	}

aud_inverted_kill_finish()
{
	wait(0.5);
	level.player PlaySound("crnd_inv_kill_finish");
	wait(0.75);
	thread play_sound_in_space("generic_death_enemy_6", (-22973, 1752, 22870) );
}

//INVERTED KNIFE KILL END
/////////////////////////

//aud_inverted_rappel_land()
//{
//	wait(0.4);
//	level.player PlaySound("stealth_land");
//}

aud_party( ref )
{
	if ( ref == "out_amb" )
	{
		aud_party( "out_music" );
		aud_party( "crowd" );
	}
	else if ( ref == "out_music" )
	{
		level.aud_outside_music PlayLoopSound("outside_party_music");
		level.aud_outside_music_rear PlayLoopSound("outside_party_music_rear");
	}
	else if ( ref == "crowd" )
	{
		level.aud_outside_crowd PlayLoopSound("outside_party_crowd");	
		level.aud_outside_crowd_rear PlayLoopSound("outside_party_crowd_rear");	
	}
	else if ( ref == "fade_in" )
	{
		wait(4);
		level.aud_outside_music ScaleVolume(0.3, 4);
		level.aud_outside_music_rear ScaleVolume(0.3, 4);
		
		wait(5);
		
		level.aud_outside_music ScaleVolume(0.25, 2);
		level.aud_outside_music_rear ScaleVolume(0.5, 2);
	}
	else if ( ref == "crowd_swell" )
	{
		first_alias = true;
		while ( !flag("start_courtyard") )
		{
			if (first_alias)
			{
				thread play_sound_in_space("outside_party_crowd_swell", (-23313, -2048, 14120));
				wait(2.7);
			}
			else
			{
				thread play_sound_in_space("outside_party_crowd_swell_02", (-23313, -2048, 14120));
				wait(3.2);
			}
			
			exploder(890);
			first_alias = !first_alias;
			wait( RandomIntRange(8, 15) );
		}
	}
}

//!COURTYARD - EVENTS


//BAR

aud_bar( ref )
{
	if ( ref == "amb" )
	{
		level.crnd_bar_amb = spawn("script_origin", (-24220, 4169, 22770));
		level.crnd_bar_amb playLoopsound("crnd_bar_ambience");
		
		crnd_bar_music = spawn("script_origin", (-23777, 3976, 22676));
		crnd_bar_music playLoopsound("restaurant_music");
		
		flag_wait( "bar_light_shot" );
		crnd_bar_music stopLoopsound("restaurant_music");
		waittillframeend;
		crnd_bar_music delete();
	}
	else if ( ref == "stop" )
	{
		flag_wait( "_stealth_spotted" );
		
		level.crnd_bar_amb stopLoopsound("crnd_bar_ambience");
		waittillframeend;
		level.crnd_bar_amb delete();
	}
	else if ( ref == "shuffle" )
	{
		wait 1.0;
		if( !flag( "bar_guys_new_dead" ))
		{
			thread play_sound_in_space("crnd_bar_shuffle", (-24220, 4169, 22770) );
		}
	}
	else if ( ref == "panic" )
	{
		level endon( "junction_entrance_close" );
		
		flag_wait( "strobe_on" );
		
		if( !flag( "bar_guys_new_dead" ))
		{
			wait( 0.7 );
			thread play_sound_in_space( "crnd_bar_stool_01", ( -24127, 4404, 22749 ) );
			wait( 1.65 );
			thread play_sound_in_space( "crnd_bar_stool_02", ( -23909, 4033, 22749 ) );
			wait( 2 );
			thread play_sound_in_space( "crnd_bar_stool_03", ( -24169, 3968, 22749 ) );
			wait( 2.38 );
			thread play_sound_in_space( "crnd_bar_stool_04", ( -24231, 4223, 22749 ) );
		}
	}
	else if ( ref == "strobe" )
	{
		thread play_sound_in_space("crnd_weapon_strobe_on", level.player.origin);
		level.aud_weapon_strobe PlayLoopSound("crnd_weapon_strobe");
	}
	else if ( ref == "strobe_stop" )
	{
		thread play_sound_in_space("crnd_weapon_strobe_off", level.player.origin);
		level.aud_weapon_strobe StopLoopSound("crnd_weapon_strobe");
	}
	else if ( ref == "light" )
	{
		thread play_sound_in_space("crnd_strobe_lights_out", (-24040, 3799, 22720));
	}
}

aud_door( ref )
{
	if ( ref == "elevator_open" )
	{
		thread play_sound_in_space("crnd_elevator_open", (-22544, 2351, 22701) );
	}
	else if ( ref == "elevator_close" )
	{
		thread play_sound_in_space("crnd_elevator_close", (-22544, 2351, 22701) );
	}
	else if ( ref == "carani" )
	{
		wait(2.35);
		thread play_sound_in_space("crnd_office_door_open_03", (-22233, 3097, 22667) );
		
		wait(1);
		
		level.aud_outside_crowd ScaleVolume( 0, 3 );
		level.aud_outside_crowd_rear ScaleVolume( 0, 3 );
		level.aud_outside_music ScaleVolume( 0, 3 );
		level.aud_outside_music_rear ScaleVolume( 0, 3 );
		
		wait(3.2);
		
		level.aud_outside_crowd StopLoopSound();
		level.aud_outside_crowd_rear StopLoopSound();
		level.aud_outside_music StopLoopSound();
		level.aud_outside_music_rear StopLoopSound();
	}
	else if ( ref == "stealth1" )
	{
		wait(1.1);
		thread play_sound_in_space("crnd_office_door_open_02", (-23696, 5147, 22676) );
	}
	else if ( ref == "stealth1b" )
	{
		wait(0.75);
		thread play_sound_in_space("crnd_office_door_close", (-23696, 5147, 22676) );
	}
	else if ( ref == "stealth2" )
	{
		wait(1.05);
		thread play_sound_in_space("crnd_office_door_open_01", (-23757, 5574, 22676) );
		level.crnd_elevator_hum = spawn("script_origin", (-25298, 4901, 22652));
		level.crnd_elevator_hum playLoopsound("crnd_elevator_motor");
	}
	else if ( ref == "elevator_room" )
	{
		wait(2.6);
		thread play_sound_in_space("crnd_elevator_room_open", (-25409, 4995, 22652) );
	}
}

aud_junction( ref )
{
	if ( ref == "hesh" )
	{
		wait(1.6);
		thread play_sound_in_space("crnd_hesh_junction_door_01", (-25621, 4896, 22652) );
		wait(0.75);
		thread play_sound_in_space("crnd_hesh_junction_door_02", (-25621, 4896, 22652) );
		wait(3.1);
		thread play_sound_in_space("crnd_hesh_junction_keypad", (-25453, 4943, 22652) );
	}
	else if ( ref == "stock" )
	{
		wait(4.6);
		level.allies[ level.const_baker ] PlaySound("crnd_hesh_junction_stockup_01");
		wait(1.2);
		level.allies[ level.const_baker ] PlaySound("crnd_hesh_junction_stockup_02");
	}
	else if ( ref == "panel" ) //in-view player arms cut the wires
	{
		thread aud_junction( "stock" );
		thread play_sound_in_space("crnd_elevator_panel", level.player.origin );
		wait(3.33);
		thread play_sound_in_space("crnd_elevator_disabled", (-25297, 4914, 22652) );
		wait(0.15);
		level.crnd_elevator_hum StopLoopSound("crnd_elevator_motor");
		wait(3);
		level.crnd_elevator_hum delete();
		thread play_sound_in_space("crnd_junction_ambush_expl", (-24232, 5873, 22652) );
		wait(0.2);
		thread play_sound_in_space("crnd_junction_ambush_expl_02", (-24232, 5873, 22652) );
		wait(1.8);
		thread play_sound_in_space("cornered_junction_scripted_battlechatter_01", (-24637, 5630, 22652) );
		wait(2.5);
		thread play_sound_in_space("cornered_junction_scripted_battlechatter_01", (-24637, 5630, 22652) );
		wait(1.5);
		thread play_sound_in_space("cornered_junction_scripted_battlechatter_01", (-24637, 5630, 22652) );
		wait(2);
		thread play_sound_in_space("cornered_junction_scripted_battlechatter_01", (-24637, 5630, 22652) );
	}
	else if ( ref == "hookup" )
	{
		wait(0.3);
		level.player PlaySound("crnd_third_rappel_hookup");
		wait(2.25);
		
		//VO battle chatters for approaching enemies as you hook up
		thread play_sound_in_space("cornered_junction_scripted_battlechatter_01", (-25078, 5824, 22652) );
		wait(1);
		thread play_sound_in_space("cornered_junction_scripted_battlechatter_01", (-25078, 5824, 22652) );
		wait(1);
		thread play_sound_in_space("cornered_junction_scripted_battlechatter_01", (-25078, 5824, 22652) );
	}
}

aud_rappel_combat( ref, ent )
{
	if ( ref == "event" )
	{
		wait(1);
		//level.player PlaySound("rappel_clickin");
		wait(2);
		level.player SetClientTriggerAudioZone("ext_rappel", 2);
		
		wait(1.5);
		//aud_rappel_jump_down(.5, 1.4);
		wait(1.5);
		//aud_rappel_jump_down(.4, 1);
	}
	else if ( ref == "swing" )
	{
		thread play_sound_in_space("crnd_swing_to_garden", level.player.origin );
		wait(4);
		music_play("mus_cornered_garden");
	}
	else if ( ref == "window1" ) //window breaks when ally on the right swings into garden
	{
		thread play_sound_in_space("crnd_into_garden_window_01", (-24976, 6182, 21134) );
	}
	else if ( ref == "window2" ) //window breaks when ally on the left swings into garden
	{
		thread play_sound_in_space("crnd_into_garden_window_02", (-24889, 6317, 21130) );
	}
	else if ( ref == "window3" ) //window breaks when player swings into garden
	{
		thread play_sound_in_space("crnd_into_garden_window_03", level.player.origin );
	}
	else if ( ref == "copy" )
	{
		wait(1.6);
		ent PlaySound("falling_item");
	}
	else if ( ref == "hit" )
	{
		level.player PlaySound("copy_machine_hit");
	}
	else if ( ref == "explode" )
	{
		wait(0.5);
		thread play_sound_in_space( "crnd_die_hard_expl", ( -24947, 6287, 22305 ) );
		wait(1.6);
		thread play_sound_in_space( "crnd_die_hard_expl_rear", ( -24958, 6296, 21764 ) );
		wait(2.35);
		thread play_sound_in_space( "crnd_hesh_die_hard", ( -24838, 6396, 22069 ) );
	}
}


aud_rappel_jump_down(time_before_slide, time_after_slide)
{
	level.player PlaySound("rappel_pushoff");
	wait(time_before_slide);
	level.player PlaySound("rappel_slide");
	wait(time_after_slide);
	level.player PlaySound("rappel_land");
}

//!GARDEN - EVENTS

aud_start_garden_events()
{
	music_stop(7);
	// set_mix("garden_insertion", 3);
	//level.player PlaySound("inverted_enter_garden");
	wait(4.4);
	level.player SetClientTriggerAudioZone("int_garden", 1);
	wait(2);
	level.player ClearClientTriggerAudioZone(1);
}

//!RESCUE - EVENTS

aud_hvt( ref, hvt )
{
	if ( ref == "door" )
	{
		wait(4.5);
		sliding_door = spawn("script_origin", (-22359, 3308, 21116) );
		sliding_door PlaySound("crnd_hvt_sliding_door");
		sliding_door MoveTo( (-22348, 3251, 21116), 1);
		wait(4);
		thread play_sound_in_space( "crnd_hvt_door_scuffle", ( -22769, 3254, 21116 ) );
		sliding_door Delete();
	}
	else if ( ref == "part1" )
	{
		thread play_sound_in_space( "crnd_office_door_open", ( -22770, 3255, 21116 ) );
		thread aud_hvt( "v1", hvt );
		thread aud_hvt( "desk" );
		thread aud_hvt( "chair" );
		thread aud_hvt( "gun1" );
	}
	else if ( ref == "part2" )
	{
		thread aud_hvt( "p1" );
		thread aud_hvt( "p2" );
		thread aud_hvt( "p3" );
		thread aud_hvt( "v2", hvt );
		thread aud_hvt( "v3", hvt );
		thread aud_hvt( "r1" );
		thread aud_hvt( "v4", hvt );
		thread aud_hvt( "r2" );
		thread aud_hvt( "b1" );
		thread aud_hvt( "r3" );
		thread aud_hvt( "v5" );
		thread aud_hvt( "gun2" );
		thread aud_hvt( "gun3" );
		thread aud_hvt( "b2" );
		thread aud_hvt( "v6" );
		thread aud_hvt( "b3" );
	}
	else if ( ref == "v1" )
	{
		wait(0.15);
		hvt PlaySound("crnd_hvt_villain_01");
	}
	else if ( ref == "desk" )
	{
		wait(1.3);
		desk_debris = spawn("script_origin", (-22559, 3218, 21116) );
		desk_debris PlaySound("crnd_hvt_desk_debris_01");
		desk_debris MoveTo( (-22382, 3195, 21082), 1.1);
		wait(5);
		desk_debris Delete();
	}
	else if ( ref == "chair" )
	{
		wait(3.36);
		thread play_sound_in_space("crnd_hvt_chair_01", (-22576, 3166, 21111) );
	}
	else if ( ref == "gun1" )
	{
		wait(8.39);
		level.allies[ level.const_rorke ] PlaySound("crnd_hvt_rorkegun_draw");
	}
	else if ( ref == "p1" )
	{
		wait(0.77);
		thread play_sound_in_space("crnd_hvt_player_01", level.player.origin );
		wait(35);
		thread play_sound_in_space("crnd_timer_countdown", (-22591, 3226, 21116) );
		wait(1.37);
		thread play_sound_in_space("crnd_hvt_bomb_01", (-22445, 3610, 21116) );
		wait(0.49);
		thread play_sound_in_space("crnd_hvt_bomb_02", (-22817, 3553, 21116) );
		wait(0.61);
		thread play_sound_in_space("crnd_hvt_bomb_03", (-22697, 3131, 21116) );
		wait(0.61);
		thread play_sound_in_space("crnd_hvt_bomb_04", (-22359, 3142, 21116) );
		wait(0.74);
		thread play_sound_in_space("crnd_detonation", level.player.origin );
		level.player SetClientTriggerAudioZone("int_collapse");
		music_play("mus_cornered_hvt");
		wait(0.5);
		level.crnd_hvt_alarm01 = spawn("script_origin", (-23441, 3090, 21068));
		level.crnd_hvt_alarm01 playLoopsound("crnd_fire_alarm_lp_02");
		level.crnd_hvt_alarm02 = spawn("script_origin", (-23242, 4069, 20730));
		level.crnd_hvt_alarm02 playLoopsound("crnd_fire_alarm_lp_01");
		
	}
	else if ( ref == "p2" )
	{
		wait(13.75);
		thread play_sound_in_space("crnd_hvt_player_02", (-22573, 3236, 21109) );
	}
	else if ( ref == "p3" )
	{
	//	wait(35.82);
	//	level.player PlaySound("crnd_hvt_player_03");
	}
	else if ( ref == "v2" )
	{
		wait(6.62);
		hvt PlaySound("crnd_hvt_villain_02");
	}
	else if ( ref == "v3" )
	{
		wait(11.7);
		hvt PlaySound("crnd_hvt_villain_03");
	}
	else if ( ref == "r1" )
	{
	//	wait(14.12);
	//	level.allies[ level.const_rorke ] PlaySound("crnd_hvt_rorke_01");
	}
	else if ( ref == "v4" )
	{
	//	wait(14.26);
	//	hvt PlaySound("crnd_hvt_villain_04");
	}
	else if ( ref == "r2" )
	{
	//	wait(17.29);
	//	level.allies[ level.const_rorke ] PlaySound("crnd_hvt_rorke_02");
	}
	else if ( ref == "b1" )
	{
	//	wait(19.46);
	//	thread play_sound_in_space("crnd_hvt_baker_01", (-22559, 3219, 21099) );
	}
	else if ( ref == "r3" )
	{
	//	wait(31.73);
	//	level.allies[ level.const_rorke ] PlaySound("crnd_hvt_rorke_03");
	}
	else if ( ref == "v5" )
	{
		wait(44.50);
		thread play_sound_in_space("crnd_hvt_villain_05", (-22588, 3170, 21104) );
	}
	else if ( ref == "gun2" )
	{
		wait(4.18);
		level.allies[ level.const_rorke ] PlaySound("crnd_hvt_rorkegun_holster");
	}
	else if ( ref == "gun3" )
	{
		wait(16.17);
		level.allies[ level.const_rorke ] PlaySound("crnd_hvt_rorkegun_draw");
	}
	else if ( ref == "b2" )
	{
		wait(8.11);
		thread play_sound_in_space("crnd_hvt_baker_02", (-22582, 3227, 21116) );
	}
	else if ( ref == "b3" )
	{
		wait(16.60);
		thread play_sound_in_space("crnd_hvt_baker_03", (-22582, 3227, 21116) );
	}
	else if ( ref == "v6" )
	{
		wait(15.45);
		thread play_sound_in_space("crnd_hvt_villain_06", (-22545, 3182, 21116) );
	}
	else if ( ref == "exit" )
	{
		thread play_sound_in_space( "crnd_office_door_open", ( -22940, 3267, 21116 ) );
	}
}

aud_hvt_destruct01()
{
	thread play_sound_in_space("crnd_hvt_destruct_01", (-23379, 3257, 21124) );
	thread play_sound_in_space("crnd_hvt_destruct_01_lsrs", (-22789, 3224, 21116) );
}

aud_hvt_destruct02()
{
	thread play_sound_in_space("crnd_hvt_destruct_02", (-23385, 3156, 20830) );
	thread play_sound_in_space("crnd_hvt_destruct_02_lsrs", (-22987, 3067, 20911) );
}

//!ATRIUM - EVENTS & !HORIZONTAL - EVENTS
aud_collapse( ref )
{
	if ( ref == "crack" )
	{
		thread play_sound_in_space("crnd_building_blast_01",  (-21989, 4468, 20492) );
		thread play_sound_in_space("bldg_death_slide",  (-22380, 3988, 20518) );
		level.aud_can_play_bldg_shake = false;
		thread aud_collapse( "debris" );
		thread aud_collapse( "chunk1" );
		wait(4.5);
		thread play_sound_in_space("crnd_building_blast_02",  (-22448, 4054, 20544) );
		thread play_sound_in_space("crnd_building_blast_02b",  (-22654, 4604, 20544) );
		thread aud_collapse( "slide1" );
		thread aud_collapse( "slide2" );
		thread aud_collapse( "slide3" );
		thread aud_collapse( "tilt2" );
		thread aud_collapse( "panic_scream" );
		thread aud_collapse( "short_scream" );
	}
	else if ( ref == "debris" )
	{
		wait(1.25);
		thread play_sound_in_space("crnd_building_tilt_01", (-22355, 4446, 20668) );
	}
	else if ( ref == "chunk1" )
	{
		wait(0.7);
		thread play_sound_in_space("crnd_horiz_debris_01", (-22293, 4025, 20487) );
		wait(0.42);
		thread play_sound_in_space("crnd_chunk_fall_01", (-22509, 4162, 20483) );
		wait(1.12);
		thread play_sound_in_space("crnd_chunk_fall_02", (-22509, 4162, 20483) );
	}
	else if ( ref == "slide1" )
	{
		wait(1.3);
		//level.player PlaySound("crnd_player_slide_01");
	}
	else if ( ref == "slide2" )
	{
		wait(9.33);
		//level.player PlaySound("crnd_player_slide_02");
	}
	else if ( ref == "slide3" )
	{
		wait(18.2);
		//level.player PlaySound("crnd_player_slide_03");
	}
	else if ( ref == "tilt2" )
	{
		wait(0.32);
		thread play_sound_in_space("crnd_building_tilt_02", (-22822, 4323, 20582) );
		wait(17.1);
		thread play_sound_in_space("crnd_plr_building_plummet", level.player.origin );
		wait(3.2);
		thread play_sound_in_space("crnd_plummet_gapper", (-22509, 4162, 20483) );
		wait(0.41);
		thread play_sound_in_space("crnd_slowmo_window_imp", level.player.origin );
		level.player SetClientTriggerAudioZone("ext_collapse");
		wait(0.1);
		thread play_sound_in_space("crnd_end_city", level.player.origin);
		wait(2.1);
		thread play_sound_in_space("crnd_parachute_dist", (-22356, -58, 18097) );
		wait(0.1);
		thread play_sound_in_space("crnd_parachute", level.player.origin);
		wait(0.9);
		thread play_sound_in_space("crnd_building_top_hit", (-22481, -5972, 19973));
		wait(15);
		level.player SetClientTriggerAudioZone("end_fade", 5);
	}
	else if ( ref == "panic_scream" )
	{
		wait(12);
		panic_scream01 = spawn("script_origin", (-22635, 3575, 20521) );
		panic_scream02 = spawn("script_origin", (-22164, 3617, 20457) );
		panic_scream01 PlaySound("cornered_saf1_panickyyellsasbuilding");
		panic_scream02 PlaySound("cornered_saf2_panickyyellsasbuilding");
		panic_scream01 MoveTo( (-22590, 1886, 20516), 9.8);
		panic_scream02 MoveTo( (-22162, 1874, 20516), 9.8);
	}
	else if ( ref == "short_scream" )
	{
		wait(5);
		thread play_sound_in_space("cornered_saf1_shortfallscream", (-22387, 3724, 20457) );
		wait(2.25);
		thread play_sound_in_space("cornered_saf2_whatsgoingisthis", (-22129, 3464, 20494) );
	}
	else if ( ref == "stumble" )
	{
		thread play_sound_in_space("crnd_lobby_boom", (-22822, 4323, 20582) );
		thread play_sound_in_space("crnd_lobby_boom_02", (-22822, 4323, 20582) );
		thread play_sound_in_space("crnd_building_shifting", (-22822, 4323, 20582) );
		
		wait(0.1);
		thread play_sound_in_space("crnd_baker_atrium_stumble", (-22822, 4323, 20582) );
		thread play_sound_in_space("crnd_blast_debris", (-22426, 4406, 20538) );
	}
	else if ( ref == "shelf" )
	{
		thread play_sound_in_space("crnd_atrium_shelf_debris_01", (-22928, 4593, 20714) );
		wait(0.75);
		thread play_sound_in_space("crnd_atrium_shelf_debris_02", (-22852, 4586, 20578) );
	}
	else if ( ref == "pillar" )
	{
		//thread play_sound_in_space("crnd_pillar_blast", (-21966, 2818, 20586) );
		wait(0.56);
		//thread play_sound_in_space("crnd_pillar_fall", (-22378, 2750, 20550) );
	}
	else if ( ref == "slow" )
	{
		//thread set_mix("slow_mo");
		music_stop(0.5);
		//wait(0.1);
		//level.player PlaySound("crnd_fall_slowmo");
		wait(2.6);
		thread aud_collapse( "window" );
	}
	else if ( ref == "window" )
	{
		level.player SetClientTriggerAudioZone("ext_collapse", 2);
		_window_imp();
	}
	else if ( ref == "window_check" ) //This only plays on the checkpoint. Doesn't fade the zone, and adds a delay so the window impact sounds play.
	{
		wait(0.05);
		_window_imp();
	}
	else if ( ref == "debris2" )
	{
		wait(7.5);
		//thread play_sound_in_space("crnd_horiz_debris_01", (-21530, -51190, 13335));
		wait(3.5);
		//thread play_sound_in_space("crnd_horiz_debris_02", (-21313, -50940, 13335));
	}
	else if ( ref == "stairs1" )
	{
		wait(12.93);
		//thread play_sound_in_space("stairs_fall", (-21134, -50705, 13460));
	}
	else if ( ref == "stairs2" )
	{
		wait(15.3);
		//thread play_sound_in_space("crnd_big_stairs_fall", (-21423, -50428, 13460));
	}
	else if ( ref == "metal" )
	{
		//removed
	}
	else if ( ref == "chunk" )
	{
		//removed
	}
	else if ( ref == "event1" )
	{
		/*
		ent = Spawn("script_origin", level.player.origin);
		ent PlayLoopSound("crnd_bg_layer_02");
		ent ScaleVolume(0);
		ent ScaleVolume(1, 4);
		*/
		
		wait(0.5);
		
		/*
		flag_wait( "teleport_to_end_ground" );
		ent StopLoopSound();
		*/
	}
	else if ( ref == "event3" )
	{
		//IPrintLnBold("event 3");
		//level.player PlaySound("bldg_tilt_stop");
	}
	else if ( ref == "event9" )
	{
		//IPrintLnBold("event 9");
		//level.player PlaySound("bldg_chunks_falling");
	}
	else if ( ref == "building" )
	{
		thread aud_collapse( "rumble" );
		thread aud_collapse( "pipes" );
	}
	else if ( ref == "rumble" )
	{
		//bg layer called in a zone now
		/*
		rumble = Spawn("script_origin", level.player.origin);
		rumble PlayLoopSound("crnd_bg_layer_01");
		
		flag_wait( "lobby_shake" );
		
		rumble ScaleVolume(0, 2);
		wait (2.1);
		rumble StopLoopSound();
		wait(0.05);
		rumble delete();
		*/
	}
	else if ( ref == "pipes" )
	{
		flag_wait( "stairwell_shake_1" );
		
		thread play_loopsound_in_space("crnd_pipe_spray", (-23393, 3142, 21116));
		thread play_loopsound_in_space("emt_water_pipe_splashy", (-23410, 3088, 20964));
		thread play_sound_in_space("crnd_pipe_burst1", (-23393, 3142, 21116));
		
		flag_wait( "stairwell_pipe_2" );
		
		thread play_loopsound_in_space("crnd_pipe_spray", (-22994, 3048, 20860));
		thread play_loopsound_in_space("emt_water_pipe_splashy", (-22999, 3048, 20811));
		thread play_sound_in_space("crnd_pipe_burst2", (-22994, 3048, 20860));
		
		thread play_loopsound_in_space("emt_water_drip_splat_int", (-23395, 3116, 20685));
	}
	else if ( ref == "lobby" )
	{
		if ( !flag("go_building_fall") && level.aud_can_play_bldg_shake == true )
		{	
			thread play_sound_in_space("crnd_shake", (-22420, 4412, 20727));
		}
	}
}

_window_imp()
{
	//removed
}

aud_rumble_loop(loop_length, loop_fade_out, alias, play_volume)
{
	/*
	rumble = Spawn("script_origin", level.player.origin);
	rumble PlayLoopSound(alias);
	
	if (IsDefined(play_volume))
	{
		rumble ScaleVolume(play_volume);
	}
	
	wait(loop_length);
	rumble ScaleVolume(0, loop_fade_out);
	wait (loop_fade_out + 0.15);
	rumble StopLoopSound();
	wait(0.05);
	rumble delete();
	*/
}

// MUSIC FUNCS

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
		level.player SetVolMod("music", 1);
		
	}
	else if ( dvar == "0" )
	{
		level.player SetVolMod("music", 0);
	}
}
#/