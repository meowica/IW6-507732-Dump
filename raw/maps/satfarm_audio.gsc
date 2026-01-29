#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_audio;
#include maps\satfarm_code;
#include maps\_utility_code;
#include maps\_audio_code;
#include maps\_hud_util;

main()
{
	thread aud_init_globals();
	thread aud_init_flags();
}

aud_init_globals()
{	
	level.bDamageSoundPlaying = false;
	level.bDeathSoundPlaying = false;
	level.bFirstChuteDeployed = false;
	level.bSecondChuteDeployed = false;
	level.bThermalOn = false;
	level.end_fade = 0;
}

aud_init_flags()
{
	flag_init("tow_cam_sound_off");
}

//checkpoints

checkpoint_crash_site()
{
	level.player SetClientTriggerAudioZone( "tank" );
}

checkpoint_base_array()
{
	level.player SetClientTriggerAudioZone( "tank" );	
}

checkpoint_air_strip()
{
	level.player SetClientTriggerAudioZone( "tank" );
}

checkpoint_air_strip_secured()
{
	level.player SetClientTriggerAudioZone( "exterior" );
}

checkpoint_tower()
{
	level.player SetClientTriggerAudioZone( "exterior" );	
}

checkpoint_bridge_deploy()
{
	level.player SetClientTriggerAudioZone( "exterior" );	
}

checkpoint_bridge()
{
	level.player SetClientTriggerAudioZone( "exterior" );	
}

checkpoint_canyon()
{
	
}

checkpoint_complex()
{
	
}

//functions

 satfarm_intro()
{
 	level.player SetClientTriggerAudioZone( "intro_cargo" );
 	thread cargo_amb();
	thread wind_amb();
	thread tank_ready();
	wait(12);
	music_play("satf_intro");
}
 
 cargo_amb()
 {			
	loc = Spawn( "script_origin",(0, 0, 0));
	loc playloopsound ("satf_amb_intro_jet");
	wait(16);
	level.player SetClientTriggerAudioZone( "intro_drop" );
	loc scalevolume (0, 1);
	wait(1);
	loc sound_fade_and_delete(1);
 }
 
 tank_ready()
 {
 	wait(14);
 	level.player playsound("satf_tank_ready");
 }
 
 wind_amb()
 {	
 	wait(14);
	loc = Spawn( "script_origin",(0, 0, 0));
	loc playloopsound ("satf_amb_intro_wind");
	loc scaleVolume (0);
	wait(1);
	loc scaleVolume (1,1);
	wait(2);
	loc sound_fade_and_delete(2);
 }
 
 deploychutes1()
 {
 	if(level.bFirstChuteDeployed == false)
 	{
 		level.bFirstChuteDeployed = true;
 		level.player playsound("satf_tank_para_deploy1");
 	}
 }
 
 deploychutes2()
 {
 	if(level.bSecondChuteDeployed == false)
 	{
 		level.bSecondChuteDeployed = true;	
 		level.player playsound("satf_tank_para_deploy2");
 		thread tank_drop();
 	}
 }
  
 tank_drop()
 {
 	thread tank_drop_jet_center();
 	thread tank_drop_player();
	thread tank_drop_jet_left();
	thread tank_drop_jet_right();
	thread intro_explosion();
	thread tank_drop_slide_allies();
	thread tank_drop_fighter_1();
	thread tank_drop_fighter_2();
	thread intro_explosion2();
 }
 
  tank_drop_player()
 {
  	loc = spawn("script_origin", (0, 0, 0));
  	wait(4.2);
 	loc playsound("satf_tank_drop_slide_plr", "sounddone");
 	wait(2);
 	level.player playsound("satf_tank_drop_turbine");
 	loc waittill ("sounddone");
 	loc delete();
 }
 
 tank_drop_jet_center()
 {
 	 wait(0.5);
 	 thread play_sound_in_space("satf_tank_drop_jet_center", (-27264, -7775, 2220));
 }
 
 tank_drop_jet_left()
 {
 	wait(3.5);
 	loc = Spawn( "script_origin",(-29525, -23227, 1189));
	dst = (-29502, -6641, 2025);
	loc playsound ("satf_tank_drop_jet_left", "sounddone");
	loc MoveTo(dst, 8.25);
	loc waittill("sounddone");
	loc delete();
 }
  
 tank_drop_jet_right()
 {
 	wait(6);
 	loc = Spawn( "script_origin",(-26803, -20129, 1138));
	dst = (-24412, -2417, 3214);
	loc playsound ("satf_tank_drop_jet_right", "sounddone");
	loc MoveTo(dst, 8);
	loc waittill("sounddone");
	loc delete();
 }
 
 intro_explosion()
 {
  	wait(7.85);
 	thread play_sound_in_space("satf_intro_explosion", (-27177, -14460, 1117));
 }
  
 intro_explosion2()
 {
  	wait(19.3);
 	thread play_sound_in_space("satf_intro_explosion", (-25957, -1208, 1192));
 }
 
 tank_drop_slide_allies()
 {
 	wait(8);
 	thread play_sound_in_space("satf_tank_drop_slide_allies", (-26793, -17658, 951));
 }
   
 tank_drop_fighter_1()
 {
 	wait(12.75);
 	loc = Spawn( "script_origin",(-30074, -24011, 1806));
	dst = (-25836, -110, 1767);
	loc playsound ("satf_tank_drop_fighter_1", "sounddone");
	loc MoveTo(dst, 3);
	loc waittill("sounddone");
	loc delete();
 }
 
 tank_drop_fighter_2()
 {
 	wait(10.75);
 	loc = Spawn( "script_origin",(-29537, -24954, 2181));
	dst = (-25414, -4713, 2962);
	loc playsound ("satf_tank_drop_fighter_2", "sounddone");
	loc MoveTo(dst, 3);
	loc waittill("sounddone");
	loc delete();
 }
 
 tow_missile_launch(here)
 {
 	loc = Spawn( "script_origin",(0, 0, 0));
 	level.player SetClientTriggerAudioZone( "tow_missile" );
	loc playsound ("satf_tow_launch");
	loc playsound ("satf_tow_camera");
	flag_wait ("tow_cam_sound_off");
	level.player SetClientTriggerAudioZone( "tank" );
	loc sound_fade_and_delete (0.1);
	wait(0.1);
	thread play_sound_in_space ("satf_tow_explosion", here);
	flag_clear ("tow_cam_sound_off");
 }
 
 overlord_trans()
 {
 	wait(0.6);
 	level.player SetClientTriggerAudioZone( "overlord" );
 	level.player playsound ("satf_airstrip_secured_transition");
 	wait(1.4);
 	music_play ("satf_airstrip_secured");
 	wait(13.2);
 	level.player SetClientTriggerAudioZone( "exterior" );
 }
 
 thermal()
 {
 	level.bThermalOn = true;
 	
 	level.player playsound ("satf_change_view_thermal");
 	level.player SetClientTriggerAudioZone( "thermal" );
 	
 	wait 1;
		
	level.player waittill( "thermal" );
	level.bThermalOn = false;
	
	level.player playsound ("satf_change_view_normal");
	level.player SetClientTriggerAudioZone( "tank" );
 }
 
  
player_tank_turret_sounds()
{
	ent1 = Spawn( "script_origin",(0, 0, 0));
	ent2 = Spawn( "script_origin",(0, 0, 0));
	ent3 = Spawn( "script_origin",(0, 0, 0));
	
	level.x_turretcheck = 0;
	level.y_turretcheck = 0;
	
	h_volume = 1;
	v_vomume = 1;
	s_volume = 1;
	h_pitch = 1;
	v_pitch = 1;
	
	while (!level.end_fade == 1 && flag( "player_in_tank" ) )
	{
		if (level.bThermalOn == true)
		{
			level.player SetClientTriggerAudioZone( "thermal" );
		}
		else		
		{
			level.player SetClientTriggerAudioZone( "tank" );
		}
			
		right_stick = level.player GetNormalizedCameraMovement();
		left_stick = level.player GetNormalizedMovement();
		
		x_turret = right_stick[0];
		y_turret = right_stick[1];
		
		x_move = left_stick[0];
		y_move = left_stick[1];
			
		if ((x_move < -0.2 || x_move > 0.2) || ( y_move < -0.2 || y_move > 0.2) )
		{	
			h_volume = 0.5;
			v_volume = 0.5;
			s_volume = 0.5;
			h_pitch = 1;
			v_pitch = 1;
		}
		else
		{
			if (x_turret < -0.8 || x_turret > 0.8)
			{
				v_volume = 1;
				v_pitch = 1.5;
			}
			else
			{
				v_volume = 0.5;
				v_pitch = 1;
			}
			if (y_turret < -0.8 || y_turret > 0.8)
			{
				h_volume = 1;
				h_pitch = 1.5;
			}
			else
			{
				h_volume = 0.5;
				h_pitch = 1;
			}
			s_volume = 1;
		}
		
		ent1 scalevolume(v_volume,0.1);
		ent2 scalevolume(h_volume,0.1);
		ent3 scalevolume(s_volume,0.1);
		
		ent1 scalepitch(v_pitch,0.1);
		ent2 scalepitch(h_pitch,0.1);
	
		if ((x_turret < -0.05 || x_turret > 0.05) && level.x_turretcheck != 1  )
		{	
			level.x_turretcheck = 1;
			ent1 playloopsound("satf_tank_turret_spin_v");
		}
		
		if (( y_turret < -0.05 || y_turret > 0.05) && level.y_turretcheck != 1 )
		{	
			level.y_turretcheck = 1;
			ent2 playloopsound("satf_tank_turret_spin_h");
		}
		
		if (x_turret >= -0.05 && x_turret <= 0.05)
		{
			level.x_turretcheck = 0;
			ent1 stoploopsound("satf_tank_turret_spin_v");
		}
				
		if (y_turret >= -0.05 && y_turret <= 0.05)
		{
			if (level.y_turretcheck == 1)
			{
				ent3 playsound("satf_tank_turret_stop");
			}
			
			level.y_turretcheck = 0;
			wait(0.05);
			ent2 stoploopsound("satf_tank_turret_spin_h");
		}
					
		wait (0.05);
	}
	
	if( IsDefined( ent1 ) )
	   ent1 Delete();
	
	if( IsDefined( ent2 ) )
	   ent2 Delete();
	
	if( IsDefined( ent3 ) )
	   ent3 Delete();
}

reload()
{
	wait(1);
	level.player PlaySound("m1a1_reload");
}

tank_death_player(here)
{
	if (level.bDeathSoundPlaying == false)
	{
		level.bDeathSoundPlaying = true;
		thread play_sound_in_space("satf_tank_death_player", here);
		wait(1);
		level.bDeathSoundPlaying = false;
	}
}

tank_damage_player(here)
{
	if (level.bDamageSoundPlaying == false)
	{
		level.bDamageSoundPlaying = true;
		thread play_sound_in_space("satf_tank_damage_player", here);
		wait(1);
		level.bDamageSoundPlaying = false;
	}
}

tank_death_allies(here)
{
	if (level.bDeathSoundPlaying == false)
	{
		level.bDeathSoundPlaying = true;
		thread play_sound_in_space("satf_tank_death_allies", here);
		wait(1);
		level.bDeathSoundPlaying = false;
	}
}

tank_damage_allies(here)
{
	if (level.bDamageSoundPlaying == false)
	{
		level.bDamageSoundPlaying = true;
		thread play_sound_in_space("satf_tank_damage_allies", here);
		wait(1);
		level.bDamageSoundPlaying = false;
	}
}

complex_expl()
{
	wait(0.1);
	music_play("satf_final");
	loc = Spawn( "script_origin",(0, 0, 0));
	loc playsound ("satf_complex_expl_inc");
	wait(5);
	loc sound_fade_and_delete(0.3);
	wait(0.25);
	level.player playsound("satf_complex_expl_imp");
	wait(9);
	level.end_fade = 1;
	level.player SetClientTriggerAudioZone( "end_fade" );
}
