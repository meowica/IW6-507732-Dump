#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;


audio_main()
{
	//called from the map's main() anytime you start the level, or jump to a checkpoint
	
	//this function has been deprecated and replaced by music_enable
	//SetDvarIfUninitialized( "level_music", "on" );

	

	
	//set the non-pitching music channel
	soundsettimescalefactor("music", 0);
	soundsettimescalefactor("effects2d1", 0);	
	soundsettimescalefactor("effects2d2", 0);		
	soundsettimescalefactor("ambient", 0);	
	soundsettimescalefactor("weapon", 0);
	soundsettimescalefactor("bulletimpact", 0);
	soundsettimescalefactor("bulletwhizbyin", 0);
	soundsettimescalefactor("bulletwhizbyout", 0);

	//setup crate land trigger for intro
	thread sfx_crate_trigger_setup();
	thread sfx_mud_trigger_setup();
	thread sfx_reveal_mix_trigger_setup();
	
	
	//create the line emitter array for the conveyor belt
	thread sfx_create_conveyor_line_emitter();
	thread start_conveyor_line_emitter();

	//create the line emitter array for the jungle
	thread sfx_create_jungle_line_emitter();
	thread sfx_create_truckyard_line_emitter();
	thread start_truckyard_line_emitter();
	//thread start_jungle_line_emitter();

	//create the line emitter array for the two chains in moving cover 2
	thread sfx_create_movingcover2_line_emitters();
	thread start_movingcover2_sfx_loops();	

	//hide the truck start up underneath the train sfx
	// Should only be called on the first few starts, otherwise it asserts
	if ( level.start_point == "intro" || level.start_point == "intro_train" || level.start_point == "default" || level.start_point == "factory_ingress")
	{
			thread audio_sfx_truck_idle_loop_start();			
	}
	    
	//this level variable is used to flip the moving cover between two different aliases
	level.rollingloop = "emt_movingcover2_rolling1_loop";
	
	//this is used by the level to play an ambience when starting up the level
	level.jump_to_amb_alias = undefined;

	//this is the constant drone of factory 1
	thread audio_sfx_factory_distant_loop_start();

	//this is used by the level to play the factory ambience while standing 
	//in the doorway of the reveal
	level.factoryrevealambience = Spawn( "script_origin", ( 5300, 2500, 500 ) );
	level.factoryrevealambienceemt = Spawn( "script_origin", ( 6192, 2592, 500 ) );		
	level.factoryrevealambienceemt2 = Spawn( "script_origin", ( 6357, 3113, 396 ) );		

	//setup the int ext triggers for the factory reveal
	thread audio_setup_factory_reveal_ambience_triggers();
	
	//setup trigger box for entrance to tank room
	thread audio_setup_tank_room_trigger();

}

intro_ambience_changes()
{
	level.player SetClientTriggerAudioZone( "factory_fadein", 0 );
	thread playthisthing();
	wait 1;
	//wait 3;
	level.player ClearClientTriggerAudioZone( 5 );
}

playthisthing()
{
	wait 1;
	level.player playsound( "scn_factory_beg_thunder_lr" );
}

audio_thunder_play_and_fp_rain()
{		
	level.rain_loop_2d = Spawn( "script_origin", ( 0,0,0 ) );
	level.rain_loop_2d playloopsound( "emt_rain_fp" );
	/*
	while(1)
	{
		if (!flag ("audio_end_thunder"))
		{		
			//train is still around
			level.player playsound( "elm_factory_thunder" );
			wait randomfloatrange(9, 11);
		}
		else
			break;
	}*/	
}	

audio_setup_tank_room_trigger()
{
	flag_init( "trigger_tank_room_volume" );
	tankroom_trigger = GetEnt( "intro_to_tankroom", "targetname" );
	tankroom_trigger thread trigger_tank_room_flag();
}

trigger_tank_room_flag()
{
	self waittill( "trigger" );
	flag_set( "trigger_tank_room_volume" );
}
	
audio_flag_inits()
{
	//script to initialize audio flags for music script
	flag_init( "music_wait_forever" );
	flag_init( "music_chk_jungle" );
	flag_init( "music_chk_intro" );
	flag_init( "music_chk_ingress" );
	flag_init( "music_chk_powerstealth" );
	flag_init( "music_chk_ambush" );
	flag_init( "music_chk_ambush_escape" );
	flag_init( "music_chk_rooftop" );	
	flag_init( "music_chk_parkinglot" );
	flag_init( "music_chk_chase" );
	flag_init( "music_chk_crash" );

	flag_init( "music_jungle_slide" );
	flag_init( "music_stealth_intro" );
	flag_init( "music_factory_reveal" );	
	flag_init( "music_ambush_battle" );
	flag_init( "music_ambush_battle_ends" );		
	flag_init( "music_chase_start" );
	flag_init( "music_chase_ending" );

	flag_init( "sfx_landed_crate" );
	flag_init( "audio_endofclacks" );
	flag_init( "audio_notrain" );
	flag_init( "sfx_slowmo_begins" );
	
	flag_init( "audio_end_thunder" );
	
	flag_init( "sfx_dont_play_desk" );
}


mission_music()
{
	//script that handles music calls
	//in conjuction with jump_to_music_flag_setup() it will start executing
	//from a given point, then continue the rest of the mission
		
	//this script will set all the flags that need to be set up to this point in the mission
	//it will also set the ambient looping alias for starting this checkpoint
	jump_to_music_flag_setup();	

	level.special_amb_is_playing = 0;

	//this will start the looping alias, if its defined for this start point
	if (isdefined (level.jump_to_amb_alias))
		wait 0.01;
		//set_audio_zone(level.jump_to_amb_alias);
	
	//playing thunder sounds in beginning of level as well as first person rain
	if (!flag("audio_end_thunder"))
	{
		thread audio_thunder_play_and_fp_rain();
	}
	//now jump to the start point and start executing from there forward
	switch ( level.start_point )
	{			
		// Game will jump to the jump to checkpoint selected and continue execution from there - no breaks, please
		case "default":
		case "intro":
		case "intro_train":
		
			
			//wait for the train sfx to start
			flag_wait("music_stealth_intro");
						
			//if we are jumping to the powerstealth checkpoint, don't wait to play the music
			//if( !flag( "music_chk_ingress" ) )
			//{
				//IPrintLnBold( "waiting" );
				//wait 7;
			//}					
			
		case "factory_ingress":			
			//play the stealth music once through then no music until ambush
			if ( GetDvar( "music_enable" ) == "1" )
				music_play("mus_factory_powerstealth");			

			//flag_wait( "music_factory_reveal" );
			flag_wait( "powerstealth_end" );
			music_stop(12);
			thread audio_start_positional_fake_int_amb("TRUE");
			thread audio_start_shuffle_emitter();

		case "powerstealth":	
		case "weapon_security":
		case "sat_room":
			//thread a script to fade out the second emitter that started 
			//when the door went up
			//level.factoryrevealambienceemt scalevolume(0.0, 12.0 ); 
			//wait 12;
			//level.factoryrevealambienceemt stoploopsound();
			
		case "ambush":
		case "greenlight":

			//wait for the ambush moment to start
			flag_wait( "music_ambush_battle" );
			
			//if( !flag( "music_ambush_battle_ends" ) )
			//{
			//	wait 1;
			//}			

			//play the ambush music cue
			//if ( GetDvar( "level_music" ) == "on" )	
				//music_loop("mus_factory_ambushbattle", 0.5);			

			//wait for the ambush battle to end			
			flag_wait("music_ambush_battle_ends");

			//fade out and stop the music
			music_stop(18);

		case "ambush_escape":
		case "rooftop":
		case "parking_lot":
		case "chase":
			flag_wait( "music_chase_start" );
			//wait 4;
			music_play("mus_factory_carchase");
			//level.player playsound( "mus_factory_carchase" );
			
			flag_wait ( "music_chase_ending" );
			//iprintlnbold ( "flag wait" );
			wait 0.6;
			//iprintlnbold ( "music stop" );

			//fade out value is double the length it should be because of the music fade bug			
			music_stop ( 4 );
			wait 4.0;
			//iprintlnbold ( "music play" );
			music_play("mus_factory_carchaseend");	
		case "face_off":		
			flag_wait("music_wait_forever");
		
	}


}

jump_to_music_flag_setup()
{			
	level.jump_to_amb_alias = "factory_jungle_ext";		

	if (level.start_point == "intro")						
		return;		

	level.jump_to_amb_alias = "factory_intro_ext"; 	
	flag_set("music_jungle_slide");
	
	if (level.start_point == "intro_train")						
		return;

	flag_set("music_stealth_intro");
	flag_set("music_chk_ingress");	
	flag_set("audio_end_thunder");
	//flag_set("music_chk_powerstealth");

	if (level.start_point == "factory_ingress")						
		return;
		
	thread audio_start_positional_fake_int_amb();
	thread audio_start_shuffle_emitter();					
	level.jump_to_amb_alias = "factory_powerstealth";
	flag_set("music_factory_reveal");	
	
	if (level.start_point == "powerstealth")
		return;			
	
	if (level.start_point == "weapon_security" )						
		return;			

	if (level.start_point == "presat_room" )
		return;
	
	level.jump_to_amb_alias = "factory_sat_room";
	
	if (level.start_point == "sat_room")						
		return;			

	flag_set("music_chk_ambush");	
	
	
	if (level.start_point == "ambush")
	{
		level.jump_to_amb_alias = "factory_wh1_greenlight";
		return;		
	}
	
	if ( level.start_point == "greenlight" )
	{
		level.jump_to_amb_alias = "factory_before_tank_room";
		return;		
	}
	flag_set("music_ambush_battle");	
	flag_set("music_chk_ambush_escape");
	level.jump_to_amb_alias = "factory_office_before_hallway";
	thread sfx_ambush_alarm_sound();
	
	
	if (level.start_point == "ambush_escape")				
		return;	

	flag_set("music_chk_rooftop");
	
	level.jump_to_amb_alias = "factory_hallway_bf_rooftop";

	flag_set("music_chase_start");
	
	if (level.start_point == "rooftop")
		return;			

	flag_set("music_chk_parkinglot");		
	level.jump_to_amb_alias = "factory_rooftop_ext";

	if (level.start_point == "parking_lot")				
		return;	

	flag_set("music_chk_chase");	

	if (level.start_point == "chase")				
		return;	

	flag_set("music_chk_crash");

	if (level.start_point == "face_off")
		return;

}

//===============================================
// AUDIO - Binocular sound calls from Raven
//===============================================

aud_binoculars_foley()
{
	self PlaySound( "fly_binoc_foley" );
}

aud_binoculars_vision_on()
{
	self PlaySound( "fly_binoc_vision_on" );
}

aud_binoculars_vision_off()
{
	self PlaySound( "fly_binoc_vision_off" );
}

aud_binoculars_bg_loop()
{
	bg_loop_sound = Spawn( "script_origin", self.origin );
	bg_loop_sound PlayLoopSound( "fly_binoc_bg_loop" );
	
	self waittill( "stop_binocular_bg_loop_sound" );
	
	bg_loop_sound StopLoopSound();
	bg_loop_sound Delete();
}

aud_binoculars_zoom_in()
{
	self PlaySound( "fly_binoc_zoom_in" );
}

aud_binoculars_zoom_out()
{
	self PlaySound( "fly_binoc_zoom_out" );
}

aud_binoculars_on_target()
{
	wait 0.1;
	//self PlaySound( "fly_binoc_circle_reticle" );
	self PlaySound("fly_binoc_scan_positive");
}

aud_binoculars_scan_loop()
{
	scan_loop_sound = Spawn( "script_origin", self.origin );
	scan_loop_sound PlayLoopSound( "fly_binoc_scan_loop" );
	
	self waittill_any( "stop_binocular_scan_loop_sound", "stop_binocular_bg_loop_sound" );
	
	scan_loop_sound StopLoopSound();
	scan_loop_sound Delete();
}

aud_binoculars_scan_positive()
{
	self PlaySound( "fly_binoc_scan_positive" );
}

aud_binoculars_scan_negative()
{
	self PlaySound( "fly_binoc_scan_negative" );
}

//===============================================
// AUDIO - End Binocular sound calls from Raven
//===============================================

sfx_bak_mudslide()
{
	wait 0.6;
	//IPrintLnBold("Mudslide - Baker");
	play_sound_in_space ("scn_factory_mudslide_baker", (1325, 6387, 722) );
}

sfx_plr_mudslide()
{
	//IPrintLnBold("Mudslide");
	wait 0.2;
	level.player playSound("scn_factory_mudslide_plr");
}

sfx_crate_trigger_setup()
{
	crate_trig = GetEnt( "trigger_crate_land", "targetname" );
	crate_trig thread sfx_crate_trigger();
}

sfx_mud_trigger_setup()
{
	mud_trig = GetEnt( "trigger_mud_land", "targetname" );
	mud_trig thread sfx_mud_trigger();
}

sfx_crate_trigger()
{
	self waittill( "trigger" );
	
	//IPrintLnBold("Landed on crate");
	level.player PlaySound("scn_factory_intro_land_crate");
	flag_set( "sfx_landed_crate" );
}

sfx_mud_trigger()
{
	self waittill( "trigger" );
	
	if (!flag("sfx_landed_crate"))
	{
		//IPrintLnBold("Landed in mud");
		level.player PlaySound("scn_factory_intro_land_ground");
	}
}

sfx_land_crate()
{
	//level.player PlaySound("scn_factory_intro_land_crate");
}

sfx_land_ground()
{
	//level.player PlaySound("scn_factory_intro_land_ground");
}

sfx_train_sound()
{
	wait 0.1;
	//level.player playsound("scn_factory_introtrain");
	//thread audio_start_train_click_clacks();
}

sfx_create_conveyor_line_emitter()
{
	level.conveyor_entarray = GetEntArray( "conveyor_line_emitter_sfx", "targetname"); 	
}

sfx_create_jungle_line_emitter()
{
	level.jungle_entarray = GetEntArray( "jungle_line_emitter_sfx", "targetname"); 	
}

sfx_create_truckyard_line_emitter()
{
	level.truckyard_entarray = GetEntArray( "truckyard_line_emitter_sfx", "targetname"); 	
}

sfx_create_movingcover2_line_emitters()
{
	level.movingcover2_entarray = GetEntArray( "movingcover2_line_emitter_sfx", "targetname"); 	
	level.movingcover2b_entarray = GetEntArray( "movingcover2b_line_emitter_sfx", "targetname"); 	
}


start_conveyor_line_emitter()
{
	flag_wait( "music_factory_reveal" );	
	thread play_linear_sfx_conveyor( level.conveyor_entarray, "emt_conveyor_belt_loop", "music_ambush_battle" );
}

start_jungle_line_emitter()
{
	//wait for the slide	
	flag_wait("music_jungle_slide");
	//thread a function that starts it during the slide
	//and fades it in during the slide
	//have that thread endon the factory reveal music flag
	//thread play_linear_sfx_conveyor( level.jungle_entarray, "emt_factory_jungle_persp", "music_factory_reveal" );
}

start_truckyard_line_emitter()
{
	if (!flag("audio_notrain"))
	{
		flag_wait("audio_endofclacks");
	}
	
	//thread play_linear_sfx_conveyor( level.truckyard_entarray, "emt_factory_truckyard_lp", "entered_factory_1" );
	thread play_linear_sfx_truckyard("emt_factory_truckyard_lp");
	thread play_truckyard_pa();
}

play_truckyard_pa()
{
	truckyard_pa = Spawn( "script_origin", ( 3703, 3790, 346 ) );
	//wait 1.5;
	
	while(!flag("entered_factory_1"))
	{
		truckyard_pa PlaySound("emt_factory_truckyard_pa");
		wait 2;
		
		if (flag("entered_factory_1"))
			break;
		
		wait RandomFloatRange(4.0, 6.0);
	}
	
	truckyard_pa ScaleVolume(0, 5);
	wait 5;
	truckyard_pa delete();
}

play_linear_sfx_truckyard( soundalias )
{
	soundorg = Spawn( "script_origin", ( 0,0,0 ) );
	soundplaying = 0;
	while(1)
	{
		if (flag("entered_factory_1"))
			break;
		
		linepoint = PointOnSegmentNearestToPoint( (3703.7, 3790.7, 346.1), (686.4, 4396.5, 367.1), level.player.origin );
		soundorg MoveTo( linepoint, 0.01 );
		if ( soundplaying == 0 )
		{
			soundorg PlayLoopSound( soundalias );
			soundplaying = 1;
		}
		wait 0.1;
	}
	
	soundorg ScaleVolume(0, 2);
	wait 2;
	soundorg StopLoopSound(soundalias);
	soundorg delete();
}


start_movingcover2_sfx_loops()
{
	flag_wait( "music_factory_reveal" );
	//thread play_linear_sfx_conveyor( level.movingcover2_entarray, "emt_movingcover2_chain1_loop", "music_chase_start"  );
	//thread play_linear_sfx_conveyor( level.movingcover2b_entarray, "emt_movingcover2_chain2_loop", "music_chase_start" );
}

play_linear_sfx_conveyor( array, soundalias, stoponthis )
{
	if (isdefined(stoponthis))
	{
		self endon (stoponthis);
	}

	soundorg = Spawn( "script_origin", ( 0,0,0 ) );
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
		soundorg MoveTo( linepoint, 0.01 );
		if ( soundplaying == 0 )
		{
			soundorg PlayLoopSound( soundalias );
			soundplaying = 1;
		}
		wait 0.1;
	}
}


audio_crane_movement_factory_reveal_01( time, acceleration, deceleration )
{
	wait 0.02;
	
	//level.tank_crane_soundorg_start_stop playsound("factory_moving_crane_start_reveal");
	//level.tank_crane_soundorg_start_stop playsound("emt_tank_crane_start");
	//level.tank_crane_soundorg_loop PlayLoopSound( "factory_moving_crane_loop_reveal" );
	//level.tank_crane_soundorg_loop PlayLoopSound( "emt_tank_crane_lp" );
	level.tank_crane_soundorg_loop scalevolume(0.0, 0.0);	
	wait 0.1;
	level.tank_crane_soundorg_loop scalevolume(1.0, 0.5);
	
	wait 15.5;
	level.tank_crane_soundorg_start_stop playsound("factory_moving_crane_stop_reveal", "sounddone" );
	wait 0.5;
	level.tank_crane_soundorg_loop scalevolume(0.0, 1.5);
	wait 1.5;
	level.tank_crane_soundorg_loop StopLoopSound();
	
}

audio_crane_movement_factory_reveal_02( time, acceleration, deceleration )
{
	wait 0.02;

	level.tank_crane_soundorg_start_stop playsound("factory_moving_crane_start_reveal");
	level.tank_crane_soundorg_loop PlayLoopSound( "factory_moving_crane_loop_reveal" );
	level.tank_crane_soundorg_loop scalevolume(0.0, 0.03);	
	wait 0.4;
	level.tank_crane_soundorg_loop scalevolume(1.0, 1);
	
	wait 7;

	level.tank_crane_soundorg_start_stop playsound("factory_moving_crane_stop_reveal", "sounddone" );
	wait 0.3;
	level.tank_crane_soundorg_loop scalevolume(0.0, 2.9);
	wait 0.6;
		level.tank_crane_soundorg_start_stop playsound("factory_tank_crane_heavy_hit");
	wait 2.9;
	level.tank_crane_soundorg_loop StopLoopSound();
	
	
}

audio_sfx_truck_idle_loop_start()
{
	//spawn an object in the location of the truck engine
	//truck_idle_cab = GetEnt( "intro_truck_cab", "targetname" );
	
	
	flag_wait ("factory_exterior_reveal");
	truck_idle_cab = level.intro_truck_cab;
	
	level.truckidlesfx_intro = Spawn( "script_origin", truck_idle_cab.origin + (100, 0, 60) );	
	level.truckidlesfx_intro LinkTo( truck_idle_cab );
	
	level.truckidlesfx = Spawn( "script_origin", truck_idle_cab.origin + (100, 0, 60) );	
	level.truckidlesfx LinkTo( truck_idle_cab );

	//this starts the truck idle before the truck starts moving in - temp
	//wait on the stealth intro to hide the idle under the train sound
	flag_wait("music_stealth_intro");

	//if we are jumping to the powerstealth checkpoint, don't wait to start the idle
	if( !flag( "music_chk_powerstealth" ) )
	{
		wait 3;
	}

	waittillframeend;

	//start a looping sound on that entity
	//IPrintLnBold("Idle start");
	level.truckidlesfx_intro PlayLoopSound( "scn_factory_truckidle_intro" );

	flag_wait("player_entered_awning");
	level.truckidlesfx_intro ScaleVolume(0.0, 3.0);
	wait 1;
	level.truckidlesfx PlayLoopSound( "scn_factory_truckidle");
}

audio_sfx_truck_in_start()
{

	flag_wait ("factory_exterior_reveal");
	flag_set ("audio_end_thunder");
	//stop 2d rain layer
	thread stop_2d_rain_layer();
	
	//spawn an object in the location of the truck engine
	// truck_idle_cab = level.intro_truck_cab;

	level.truckmovesfx = Spawn( "script_origin", level.intro_truck_cab.origin + (100, 0, 60) );	
	level.truckmovesfx LinkTo( level.intro_truck_cab );

	waittillframeend;

	//start a sound on that entity for it approaching
	//IPrintLnBold("Truck in engine ch: mission");
	level.truckmovesfx PlaySound( "scn_factory_truckinengine" );

	//temporarily fade out the idle, wait, and then fade it back in
	level.truckidlesfx scalevolume(0.0, 3.0);

	wait 4.5;

	level.truckidlesfx scalevolume(1.0, 1.0);

}

stop_2d_rain_layer()
{
	if(isdefined(level.rain_loop_2d))
	{
		level.rain_loop_2d scalevolume( 0, 5 );
		wait 5;
		level.rain_loop_2d StopSounds();
		wait 0.1;
		level.rain_loop_2d delete();
	}
}


audio_sfx_truck_chatter( intro_pmcs, intro_truck_cab )
{
	flag_wait("player_entered_awning");
	//IPrintLnBold("Chatter start");
	//this will eventually be something that uses the guys' objects and such....
	self endon("intro_truck_driver_dead");
	intro_pmcs[ 0 ] endon( "death" );
	intro_pmcs[ 1 ] endon( "death" );
	intro_pmcs[ 2 ] endon( "death" );
	

	//spawn an object in the location of the truck engine
	//truck_idle_cab = GetEnt( "intro_truck_cab", "targetname" );

	level.truckchatter = Spawn( "script_origin", level.intro_truck_cab.origin + (300, 0, 60) );
	level.truckchatter LinkTo( level.intro_truck_cab );

	waittillframeend;
	
	truckdude1 = get_living_ai( "entrance_enemy_02", "script_noteworthy" );
	truckdude2 = get_living_ai( "intro_truck_driver", "script_noteworthy" );	
	truckdude3 = get_living_ai( "entrance_enemy_03", "script_noteworthy" );
	
	wait 1;
	if ( isdefined(truckdude1) )
	{
		truckdude1 playsound("factory_vs1_holdon");
	}
	wait 6;
	if ( isdefined(truckdude2) )
	{
		truckdude2 playsound("factory_vs2_heavyload");
	}
	wait 4;
	if ( isdefined(truckdude3) )
	{
		truckdude3 playsound("factory_vs3_expectingyou");
	}
	wait 7.5;
	if ( isdefined(truckdude2) )
	{
		truckdude2 playsound("factory_vs2_seethat");
	}
	wait 5.8;
	if ( isdefined(truckdude3) )
	{
		truckdude3 playsound("factory_vs3_yeahsorry");
	}
	wait 4;
	if ( isdefined(truckdude2) )
	{
		truckdude2 playsound("factory_vs2_secretaccount");
	}
	wait 5;
	if ( isdefined(truckdude3) )
	{
		truckdude3 playsound("factory_vs3_doubleworkload");
	}
}

audio_factory_search_body()
{
	wait 0.1;
	//IPrintLnBold("Search");
	level.squad[ "ALLY_CHARLIE" ] PlaySound("scn_factory_search_body");
}

audio_sfx_factory_distant_loop_start()
{

	//spawn an object in the location of the truck engine
	level.distfactorysfx = Spawn( "script_origin", ( 5400, 1900, 0 ) );	
	level.constantfactorysfx = Spawn( "script_origin", ( 4800, 1800, 0 ) );	
	//level.constantfactorysfx2 = Spawn( "script_origin", ( 4000, 1800, 0 ) );	

	//start a looping sound on that entity
	level.distfactorysfx PlayLoopSound( "emt_factory_ominous_lp" );
	level.constantfactorysfx PlayLoopSound( "emt_factory_dist_lp" );
	//level.constantfactorysfx2 PlayLoopSound( "emt_factory_dist_lp_2" );

}

audio_sfx_truck_idle_loop_stop()
{
	//fade out the looping sound
	level.truckidlesfx scalevolume(0.0, 2.5);

	//wait fade length
	wait 2.5;
	
	//stop the looping sound
	level.truckidlesfx StopLoopSound( "scn_factory_truckidle");

	//kill script entity	
	level.truckidlesfx delete();
}



audio_sfx_alternate_rolling_loop_alias()
{
	if (level.rollingloop == "emt_movingcover2_rolling1_loop")
		level.rollingloop = "emt_movingcover2_rolling2_loop";	
	else
		level.rollingloop = "emt_movingcover2_rolling1_loop";	
}

audio_sfx_car_chase_sequence()
{
	
	//iprintlnbold("starting");
	//delaythread( 12, ::play_sound_in_space, "scn_factory_chase_trainmiss", ( -8299, -534, 105 ) );
	//level.player delaycall( 9, ::PlaySound, "scn_factory_chase_drivethru");
	// delaythread( 22, ::play_sound_in_space, "scn_factory_chase_truckbustwall", ( -10539, 6276, 117 ) );
	//delaythread( 31, ::play_sound_in_space, "scn_factory_chase_trainhittruck", ( -12113, 15469, 117 ) );	

}


audio_car_explode()
{
	//play an explosion sound in space at the origin of this self
	play_sound_in_space ("explo_metal_rand", self.origin);
}

audio_factory_door_open()
{
	//had to make this its own function because the sound only needs to be played when 
	//the player opens it, and not during the intro fo the mission
	factory_entrance_door = GetEnt( "factory_entrance_door", "script_noteworthy" );	
	factory_entrance_door playsound ("scn_factory_garage_door_open");
}

audio_setup_factory_reveal_ambience_triggers()
{
	//these are special case ambience changes with directional ambience at the opening	
	factory1_ambience_ext = GetEnt( "swap_to_amb_ext", "targetname" );
	factory1_ambience_ext thread audio_factory_ambient_switch_to_ext();
	factory1_ambience_int = GetEnt( "swap_to_amb_int", "targetname" );
	factory1_ambience_int thread audio_factory_ambient_switch_to_int();	
}


audio_factory_ambient_switch_to_ext()
{

	while(1)
	{
		self waittill( "trigger" );
		//in the trigger - do stuff here
		//iprintlnbold("EXT");

		//change the BG		
		//set_audio_zone("factory_intro_ext_w_verb", 4.0);	

		//if the door is open, play the emitter
		if (flag("music_factory_reveal"))
		{
			//iprintlnbold ("EXT - ITS OPEN");
			//see if the emitter is already playing or not
			if (level.special_amb_is_playing == 0)
			{
				//the ambient is not playing yet - start it and track that it is playing
				level.factoryrevealambience playloopsound ("emt_factory_int_amb_from_ext");
				level.factoryrevealambience scalevolume(0.0, 0.0);			
				level.special_amb_is_playing = 1;	
				
				//level.factoryrevealambienceemt playloopsound ("emt_factory_int_amb_from_ext_2");
				//level.factoryrevealambienceemt scalevolume(0.0, 0.0);			

				wait 0.1;
				
				
			}			
			thread audio_fade_in_int_amb();
		}

		while( level.player istouching( self ) )
			{
				wait 0.1;
			}
		//leaving the trigger - do stuff here
		//iprintlnbold("Leaving EXT");
	
	}

}

audio_factory_ambient_switch_to_int()
{
	//this will be the trigger box that will play audio from a script node while
	//the player is outside - it will need to be a shorter looping sound version of the
	//main interior ambient - probably mono
	//first it will play the sound and then fade it in
	//the volume will adjust based on your distance to a plane or script object so that
	//once you are inside it will fade out and the normal ambient takes over

	while(1)
	{
		self waittill( "trigger" );
		//in the trigger - do stuff here
		//iprintlnbold("INT");

		//change the BG		
		//set_audio_zone("factory_wh1_int", 3.5);	
		//set_audio_zone("factory_wh1_int", 15);	

		//fade out and stop the factory ambience
		if (flag("music_factory_reveal"))
		{
			//iprintlnbold ("INT - ITS OPEN");
			//see if the emitter is already playing or not
			//or can we just set the volume over a period of time...?
			//will that conflict when setting it again in less than a second, when running through
			thread audio_fade_out_int_amb();


		}	

		while( level.player istouching( self ) )
			{
				wait 0.1;
			}
		//leaving the trigger - do stuff here
		//iprintlnbold("leaving INT");
	
	}

}

audio_start_shuffle_emitter()
{
	level.factoryrevealambienceemt playloopsound ("emt_factory_int_amb_from_ext_2");
	level.factoryrevealambienceemt scalevolume(0.0, 0.0);
	
	level.factoryrevealambienceemt2 playloopsound ("emt_factory_int_amb_from_ext_3");
	level.factoryrevealambienceemt2 scalevolume(0.0, 0.0);
	
	wait 0.1;			
	level.factoryrevealambienceemt scalevolume(1.0, 3.0);	
	level.factoryrevealambienceemt2 scalevolume(1.0, 3.0);			
}

audio_start_positional_fake_int_amb(fadein)
{
	level.factoryrevealambience playloopsound ("emt_factory_int_amb_from_ext");
	level.factoryrevealambience scalevolume(0.0, 0.0);			
	level.special_amb_is_playing = 1;
	wait 0.1;
	if (isdefined (fadein))
	{
		if (fadein == "TRUE")							
		{
			level.factoryrevealambience scalevolume(1.0, 2.2);			
		}
	}
}


audio_fade_in_int_amb()
{	
	//NOTIFY FADING IN
	level notify( "positional_ambience_fading_in" );
	//endon notified fade out
	level endon( "positional_ambience_fading_out" );	
	
	//iprintlnbold ("START fading in");
	level.factoryrevealambience scalevolume(1.0, 2.5);	

	wait 4.6;
	//iprintlnbold ("DONE fading in");

}

audio_fade_out_int_amb()
{
	//NOTIFY FADING OUT
	level notify( "positional_ambience_fading_out" );

	//endon notified fade in
	level endon( "positional_ambience_fading_in" );

	//iprintlnbold ("START fading out");
	level.factoryrevealambience scalevolume(0.0, 4.5 );
	// not gonna fade this out, gonna keep it in then find another place to fade it out
	//level.factoryrevealambienceemt scalevolume(0.0, 4.5 );

	wait 4.6;
	//iprintlnbold ("DONE fading out");
	if (level.special_amb_is_playing == 1)
	{
		//stop the loop
		level.factoryrevealambience stoploopsound();
		level.special_amb_is_playing = 0;
		
	}
}

audio_trainpass_chkpt()
{
	/* 
     *From the "Train pass" checkpt there is apparently no "train pass", so we are setting this flag.
     *The sfx start at intro, so if player plays from beginning, this function will fall through (which is intended).
     */
    //IPrintLnBold("Train pass checkpt - setting no train flag"); 
    flag_set("audio_notrain");
}

//a script to start the constant loops and looping click clacks a and b
//then waits for the timed scene to start and waits for periods of time before 
//it fires off flags to stop the click clacks and fade out the constants
//as well as play the final passby

//constant loop locations
//2500, 5200, 375
//2100, 5200, 375
//1200, 5200, 375

audio_start_train_looping()
{	
	//fire off constant loops
	//fire off click clacks 1 and 2
	//wait for scene to start
	//wait for final car to pass by and fire off a notify
}

audio_train_constant_loop()
{
	if (!flag("audio_notrain"))
	{
		//spawn an entity in space - 1
		level.constanttrainloop1 = Spawn( "script_origin", ( 2500, 5200, 375 ) );
		//play a constant loop on that entity
		level.constanttrainloop1 playloopsound("scn_factory_train_constant_01");
	
		//spawn an entity in space - 2
		level.constanttrainloop2 = Spawn( "script_origin", ( 2100, 5200, 375 ) );
		//play a constant loop on that entity
		level.constanttrainloop2 playloopsound("scn_factory_train_constant_02");
	
		//spawn an entity in space - 3
		level.constanttrainloop3 = Spawn( "script_origin", ( 1200, 5200, 375 ) );
		//play a constant loop on that entity
		level.constanttrainloop3 playloopsound("scn_factory_train_constant_03");
		
		//wait for a notify of some sort to tell us the train is about done passing by
		flag_wait("audio_endofclacks");
		//IPrintLnBold("AUDIO: End of clacks");
		wait 2;
		//iprintlnbold ("playing last car sound and moving it");
		thread audio_train_last_car_passby();
		wait 1;
		//iprintlnbold("fading out loops");
		level.constanttrainloop1 scalevolume(0.0, 5);
		level.constanttrainloop2 scalevolume(0.0, 5);
		level.constanttrainloop3 scalevolume(0.0, 5);
		wait 5;
		level.constanttrainloop1 stoploopsound();
		level.constanttrainloop2 stoploopsound();
		level.constanttrainloop3 stoploopsound();
		//move entity 1 to end point
		//wait a brief moment
		//move entity 2 to end point
		//wait a brief moment
		//start fading out entity 1 and 2 as they are moving to end point
		//wait a brief moment
		//move entity 3 to end point and fade it out
	}
}

audio_train_last_car_passby()
{
	//wait 0.5;
	//IPrintLnBold("last car");
	lastcarpassby = Spawn( "script_origin", ( 3100, 5200, 375 ) );
	lastcarpassby playsound("scn_factory_train_clacks_final_by");
	lastcarpassby MoveX( -1350, 6.3, 0, 0 );	
}


audio_train_click_clacks_1()
{
	while(1)
	{		
		if (!flag ("audio_endofclacks"))
		{
			//train is still around
			thread audio_train_individual_click_clack("scn_factory_train_clacks_a");
			wait randomfloatrange(1.05, 1.4);
		}
		else
			break;
	}
	//iprintlnbold ("popped out of while loop 1");		
	//train has notified us it is not going to be around soon
	
	thread audio_train_individual_click_clack("scn_factory_train_clacks_a");
	wait 1.4;
	thread audio_train_individual_click_clack("scn_factory_train_clacks_a");
	wait 1.4;
	thread audio_train_individual_click_clack("scn_factory_train_clacks_a");
	wait 1.4;
	thread audio_train_individual_click_clack("scn_factory_train_clacks_a");
	wait 1.4;
	thread audio_train_individual_click_clack("scn_factory_train_clacks_a");
	wait 1.4;

	//we need to move the origins down the track for the last few
	thread audio_train_individual_click_clack("scn_factory_train_clacks_a", -500) ;
	wait 1.4;

	thread audio_train_individual_click_clack("scn_factory_train_clacks_a", -900); 
	wait 1.4;

	thread audio_train_individual_click_clack("scn_factory_train_clacks_a", -1500); 
	wait 1.4;
	
}

audio_train_click_clacks_2()
{
	while(1)
	{
		if (!flag ("audio_endofclacks"))
		{		
			//train is still around
			thread audio_train_individual_click_clack("scn_factory_train_clacks_b", 600, 2.5, -1400);
			wait randomfloatrange(4.5, 6.5);
		}
		else
			break;
	}
	//iprintlnbold ("popped out of while loop 2");		

	//train has notified us it is not going to be around soon
	thread audio_train_individual_click_clack("scn_factory_train_clacks_b", 600, 2.5, -1400);
	wait 4.5;

	//we need to move the origins down the track for the last few	
	thread audio_train_individual_click_clack("scn_factory_train_clacks_b", 200, 2.5, -1400);
	//wait 4.5;
	
	//thread audio_train_individual_click_clack("scn_factory_train_clacks_b", 0, 2.5, -1400) ;
	//wait 4.5;

}

audio_train_individual_click_clack(aliasname, location, passbyspeed, movedist)
{
	xloc = 2500;
	speed = 0.874;
	moveby = -900;

	if (isdefined(location))
		xloc = (xloc + location);	

	if (isdefined(passbyspeed))
		speed = passbyspeed;

	if (isdefined(movedist))
		moveby = movedist;		

	//spawn a new scirpt origin in space	
	thisclickclack = Spawn( "script_origin", ( xloc, 5200, 375 ) );

	//play a sound on it	
	//iprintlnbold("click-clack");
	thisclickclack playsound(aliasname, "donewiththissound");
	
	//move it to the end point
	thisclickclack MoveX( moveby, speed, 0, 0 );	

	//wait for the sound to stop with a notify on the playsound
	thisclickclack waittill( "donewiththissound" );

	wait 0.1;
	thisclickclack delete();
}




//a script that loops and has a while statement that stops playing click clacks
//the above script will set a flag or notify that will cause it to not play anymore click clacks
//but still finish the one that is currently playing


//a script that is called for the final passby when the final passby is triggered

//a script that plays the constant loops and waits for a notify in order to fade them out
//and stop them

audio_start_train_click_clacks()
{
	if (!flag("audio_notrain"))
	{
		thread audio_train_click_clacks_1();
		thread audio_train_click_clacks_2();
	}
}

audio_start_train_click_clacks_2()
{
	//spawn a script origin
	//train_03 = GetEnt( "train_reveal_01", "script_noteworthy" );	

	//first position is the original origin of car 3
	//first_pos = train_03.origin;	

	//train_clacks_2 = Spawn( "script_origin", first_pos );

	//move it to the first position on the train track
	//train_clacks_2 MoveX( -4000, 0.01, 0, 0 );

	//start the sound
	//train_clacks_2 playsound("scn_factory_introtrain_clacks2");

	//timing it perfectly, move it back and forth between the first 
	//position on the tracks and the second position on the tracks
	//to give the appearance that the train is constantly passing by
	//moveto, etc... here
	
	wait 1.685;

	
	//train_clacks_2 MoveX( -1200, 0.600, 0, 0 );
	wait 2.784;
	//train_clacks_2 MoveX( 1200, 0.01, 0, 0 );
	wait 1.866;

	//train_clacks_2 MoveX( -1200, 1.2, 0, 0 );
	wait 1.856;
	//train_clacks_2 MoveX( 1200, 0.01, 0, 0 );
	wait 1.38;

	//train_clacks_2 MoveX( -1200, 1.461, 0, 0 );
	wait 2.368;
	//train_clacks_2 MoveX( 1200, 0.01, 0, 0 );
	wait 2.221;
	iprintlnbold("end of clacks2 wait");	

	//train_clacks_2 MoveX( -1200, 2.304, 0, 0 );
	wait 15;

}

audio_start_train_click_clacks_1()
{
	//spawn a script origin
	train_03 = GetEnt( "train_reveal_01", "script_noteworthy" );		

	//first position is the original origin of car 3
	first_pos = train_03.origin;	

	train_clacks_1 = Spawn( "script_origin", first_pos );

	//move it to the first position on the train track
	train_clacks_1 MoveX( -4100, 0.01, 0, 0 );

	//start the sound
	//train_clacks_1 playsound("scn_factory_introtrain_clacks1");

	//timing it perfectly, move it back and forth between the first 
	//position on the tracks and the second position on the tracks
	//to give the appearance that the train is constantly passing by
	//moveto, etc... here
	
	wait 2.278;

	
	train_clacks_1 MoveX( -900, 0.565, 0, 0 );
	wait 1.348;
	train_clacks_1 MoveX( 900, 0.01, 0, 0 );
	wait 0.101;

	
	train_clacks_1 MoveX( -900, 0.874, 0, 0 );
	wait 1.325;
	train_clacks_1 MoveX( 900, 0.01, 0, 0 );
	wait 0.133;

	
	train_clacks_1 MoveX( -900, 0.818, 0, 0 );
	wait 0.858;
	train_clacks_1 MoveX( 900, 0.01, 0, 0 );
	wait 0.117;

	
	train_clacks_1 MoveX( -900, 0.638, 0, 0 );
	wait 1.790;
	train_clacks_1 MoveX( 900, 0.01, 0, 0 );
	wait 0.394;

	
	train_clacks_1 MoveX( -900, 0.818, 0, 0 );
	wait 1.262;
	train_clacks_1 MoveX( 900, 0.01, 0, 0 );
	wait 0.1;

	
	train_clacks_1 MoveX( -900, 0.818, 0, 0 );
	wait 2.747;
	train_clacks_1 MoveX( 900, 0.01, 0, 0 );
	wait 0.480;

	
	train_clacks_1 MoveX( -900, 0.739, 0, 0 );
	wait 1.070;
	train_clacks_1 MoveX( 900, 0.01, 0, 0 );
	wait 0.210;

	
	train_clacks_1 MoveX( -900, 1.024, 0, 0 );
	wait 6.5;
	

}

audio_play_unlock_sound()
{
	thread sfx_play_security_beep();
	wait 0.3;
	play_sound_in_space ("scn_factory_door_security_unlock", (4923, 3366, 300 ) );	
}

sfx_play_security_beep()
{
	play_sound_in_space ( "scn_factory_door_security_beep_success", (4659, 3367, 300 ) );		
}

audio_container_move()
{
	self PlayLoopSound("emt_factory_rollers");	
}

audio_container_move_above_door()
{
	self PlayLoopSound("emt_factory_rollers_above_door");	
}

audio_distant_train_horn()
{
	wait 0.2;
	play_sound_in_space ("scn_factory_dist_train_horn", (4923, 3366, 300 ) );	

}
audio_player_intro()
{

	wait 4.2;
	//IPrintLnBold("YES");
	level.player playsound("scn_factory_intro_player");
	
	//hack for the milestone
	//wait 15.0;
	//thread set_audio_zone("factory_jungle_ext", 3);
}

audio_baker_intro()
{

	wait 3.23;
	//iprintlnbold("baker start");
	self playsound("scn_factory_intro_baker");

}

audio_plr_intro_knife_pullout()
{

	//wait 2.65;
	//IPrintLnBold("plr Knife");
	self playsound("scn_factory_intro_plrknife");

}

audio_ally_intro_knife_pullout()
{

	//wait 2.65;
	//IPrintLnBold("ally Knife");
	self playsound("scn_factory_intro_allyknife");

}

audio_player_intro_jump_kill()
{

	//wait 4.1;
	//IPrintLnBold("jumpkill");
	level.player playsound("scn_factory_intro_playerjumpkill");
	stop_2d_rain_layer();

}

audio_ally_intro_jump_kill()
{

	wait 2.65;
	//IPrintLnBold("ally jumpkill");
	self playsound("scn_factory_intro_allyjumpkill");
	flag_set( "music_stealth_intro" );

}

audio_player_train_track_stealth_kill()
{
	level.player playsound("scn_factory_player_train_kill");
	thread sfx_hey_vo_line();	
	wait 0.316;
	level.player playsound("factory_train_tacks_npc_death");
}

sfx_hey_vo_line()
{
	guy = Spawn( "script_origin", ( 0,0,0 ) );
	wait 0.316;
	guy playsound("factory_train_tacks_npc_vo");	
}




///////////////////////////////////////////////////////////////
//REMOVED OR DEPRECATED FUNCTIONALITY
///////////////////////////////////////////////////////////////

/*
sfx_turn_on_slo_mo_sound_sequence_1()
{
	iprintln ("TURN ON 1");	
	flag_set( "music_slomo_1" );
	level.player playsound("scn_factory_kickdooropen");
	wait 0.1;
	iprintln ("DONE WITH WAIT TURN ON 1");
	set_audio_zone("factory_rooftop_ext_slomo_v1");	
}

sfx_turn_off_slo_mo_sound_sequence_1()
{
	iprintln ("TURN OFF 1");
	set_audio_zone("factory_rooftop_ext");
}

sfx_turn_on_slo_mo_sound_sequence_2()
{	
	iprintln ("TURN ON 2");
	set_audio_zone("factory_rooftop_ext");	
}

sfx_turn_off_slo_mo_sound_sequence_2()
{
	iprintln ("TURN OFF 2");
	set_audio_zone("factory_rooftop_ext");	
}
*/

/*
start_crane_room_b_sfx_loop()
{
	level.crane_sfx_org = Spawn( "script_origin", ( 0,0,0 ) );
	//wait 0.2;
	level.crane_sfx_org2 = Spawn( "script_origin", ( 0,0,0 ) );
	thread play_linear_sfx_crane(level.cranesfx_line, "factory_moving_crane_loop", level.crane_sfx_org, level.crane_sfx_org2 );
}
*/


/*
play_linear_sfx_crane( array, soundalias, soundorg, soundorg2 )
{
	if ( !isdefined( soundorg ) )
		soundorg = Spawn( "script_origin", ( 0,0,0 ) );
	
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
		soundorg MoveTo( linepoint, 0.01 );
		
		if ( isdefined( soundorg2 ) )
		{
			soundorg2 MoveTo( linepoint, 0.01 );
		}
		if ( soundplaying == 0 )
		{
			soundorg PlayLoopSound( soundalias );
			soundplaying = 1;
		}
		wait 0.1;
	}
}
*/

/*
audio_crane_movement( time, acceleration, deceleration )
{
	wait 0.02;
	
	level.crane_sfx_org2 playsound("factory_moving_crane_start");
	wait 0.4;
	level.crane_sfx_org scalevolume(1.0, acceleration);
	
	wait time - deceleration;
	level.crane_sfx_org2 playsound("factory_moving_crane_stop", "sounddone" );
	wait 0.3;
	level.crane_sfx_org scalevolume(0.0, deceleration);
	
}
*/

/*
audio_sfx_truck_pull_away_start()
{
	//stop the idle loop
	thread audio_sfx_truck_idle_loop_stop();

	//set up two nodes, one for the fron and one for the back
	level.truckenginesfx = Spawn( "script_origin", ( 5068, 3664, 260 ) );	
	level.truckearsfx = Spawn( "script_origin", ( 4568, 3664, 260 ) );	

	//link those two nodes to the truck org
	entrance_reveal_18wheeler = GetEntArray( "entrance_reveal_18wheeler", "script_noteworthy" );
	closest = getClosest( level.truckenginesfx.origin, entrance_reveal_18wheeler );
	level.truckenginesfx LinkTo( closest );
	level.truckearsfx LinkTo( closest );	

	//play a sound on each of them with notifies
	level.truckenginesfx playsound ("scn_factory_truckawayengine", "enginesfxdone");
	level.truckearsfx playsound ("scn_factory_truckawaybackend", "rearsfxdone");

	//wait until both notifies have been reached
	self waittill ("enginesfxdone");
	self waittill ("rearsfxdone");

	//kill entities	
	level.truckenginesfx delete();
	level.truckearsfx delete();

}
*/

audio_factory_intro_mix()
{
		
		level.player SetVolMod( "vehicle_npc", 0.4, 1 );
		wait 14;
		level.player setvolmod( "vehicle_npc", 1, 1 );
			
}

audio_factory_reveal_mix( mixer )
{
	
	if( mixer == "one" )
	{
		wait 0.2;
		level.player SetVolMod( "max", 0.45, 1 );
		level.player SetVolMod( "emitter", 0.45, 1 );
		level.player SetVolMod( "element", 0.45, 1 );
	}
	else if( mixer == "two" )
	{
		level.player SetVolMod( "max", 0.7, 1 );
		level.player SetVolMod( "emitter", 0.7, 1 );
		level.player SetVolMod( "element", 0.7, 1 );	
	}
	else if( mixer == "three" )
	{
		wait 2;
		level.player SetVolMod( "max", 1, 1 );
		level.player SetVolMod( "emitter", 1, 1 );
		level.player SetVolMod( "element", 1, 1 );	
	}
	
}

audio_factory_wait_for_mix_change()
{
	wait 1.5;
	audio_factory_reveal_mix( "two" );
}

ambush_line_emitter_create()
{
	lineemitterarray = [];
	lineemitterarray[0] = spawn( "script_origin", (4876,-495,325) );
	lineemitterarray[1] = spawn( "script_origin", (4658,-1873,352) );
	//lineemitterarray[1] = spawn( "script_origin", (4865,-1877,352) );
	//lineemitterarray[2] = spawn( "script_origin", (4308,-1886,352) );

	ambush_line_emitter_logic( lineemitterarray, "scn_factory_assembly_back_lp", "ambush_escape_spawn_helis" );	
}

ambush_line_emitter_logic( array, soundalias, stoponthis )
{
	if (isdefined(stoponthis))
	{
		self endon (stoponthis);
	}

	soundorg = Spawn( "script_origin", ( 0,0,0 ) );
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
		soundorg MoveTo( linepoint, 0.01 );
		if ( soundplaying == 0 )
		{
			soundorg PlayLoopSound( soundalias );
			soundplaying = 1;
		}
		wait 0.1;
	}
}

sfx_glass_door_open(door)
{
	door PlaySound("scn_factory_glass_door_open");
}


sfx_glass_door_close(door)
{
	door PlaySound("scn_factory_glass_door_close");
}

sfx_metal_door_open(door)
{
	door PlaySound("scn_factory_metal_door_open");
}


sfx_metal_door_close(door)
{
	door PlaySound("scn_factory_metal_door_close");
}

sfx_revolving_door_open(door)
{
	door PlaySound("scn_factory_revolving_door");
}

sfx_sat_room_panel_railing()
{
	self playsound("scn_factory_sat_panel_railing");
}

sfx_sat_room_panel_pry_open()
{
	self playsound("scn_factory_sat_panel_pry");
}

sfx_sat_room_panel_pull_panel()
{
	level endon( "sat_room_player_pulled" );

	// Original sound
	//self playsound("scn_factory_sat_panel_pull");

	// Wait for a audio notifies from the pull event
	while( 1 )
	{
		event = waittill_any_return( "sat_pull_anim_past_15", "sat_pull_anim_past_45", "sat_pull_anim_past_65" );
		
		switch( event )
		{
			case "sat_pull_anim_past_15":
				level.playing_sat_anim_sound = true;

				// Play some sound when the anim goes past 45%
				// playsound();
				iprintln( "Creak" );

				// Dont trigger other anim SFX for a short while
				wait randomFloatRange( 1.1, 2.75 );

				level.playing_sat_anim_sound = false;
				break;
			case "sat_pull_anim_past_45":
				level.playing_sat_anim_sound = true;

				// Play some sound when the anim goes past 45%
				// playsound();
				iprintln( "Stretch" );

				// Dont trigger other anim SFX for a short while
				wait randomFloatRange( 1.1, 2.75 );

				level.playing_sat_anim_sound = false;
				break;
			case "sat_pull_anim_past_65":
				level.playing_sat_anim_sound = true;

				// Play some sound when the anim goes past 45%
				// playsound();
				iprintln( "Pop" );

				// Dont trigger other anim SFX for a short while
				wait randomFloatRange( 1.1, 2.75 );

				level.playing_sat_anim_sound = false;
				break;
			default:
		}

		wait 0.1;
	}
}

sfx_sat_room_panel_panel_flip()
{
	//wait 1.0;
	//IPrintLnBold("JL: Panel Flip");
	self playsound("scn_factory_sat_panel_flip");
}

sfx_sat_room_panel_hand_off_sfx()
{
	wait 4.1;
	//IPrintLnBold("JL: Panel Hand Off");
	self playsound("scn_factory_sat_panel_hand");
}

greenlight_amb_change()
{
	//delaythread( 2000, ::play_sound_in_space, "scn_factory_chase_trainhittruck", ( -12113, 15469, 117 ) );
	level.tankroom_node = Spawn( "script_origin", (5412, 134, 453) );
	level.tankroom_node PlayloopSound( "scn_factory_greenlight_opening_lp" );
	level.tankroom_node scalevolume(0.0, 0.0);
	
	wait 0.8;
	
	level.tankroom_node scalevolume(1.0, 1.0);
	
	wait 0.2;
	
	thread play_sound_in_space ("scn_factory_greenlight_opening", (6038, 289, 428));
	//wait 2;
	//
	//scalevolume(0.0, 12.0 );
	
	//wait 4.1;
	
	//set_audio_zone( "factory_wh1_greenlight" );
	
	//wait 3;
	flag_wait( "trigger_tank_room_volume" );
	level.tankroom_node scalevolume(0.0, 2.0);
	
	wait 2.1;
	
	//level.tankroom_node stopsounds();
	//wait 0.1;
	level.tankroom_node delete();
}

garage_sfx_reveal()
{
	//IPrintLnBold("Playing reveal SFX");
	wait 0.1;
	level.garage_node = Spawn( "script_origin", (5200, 3000, 400) );
	level.garage_node PlaySound( "scn_factory_garage_reveal" );
	level.garage_node scalevolume(0.0, 0.0);
	
	
	level.garage_node scalevolume(1.0, 1.5);
	
	wait 9;
	level.garage_node scalevolume(0.7, 3);
	
	wait 5;
	
	level.garage_node scalevolume(0.0, 10);
	
	wait 15;
	
	level.garage_node delete();
}

sfx_garage_reveal_crane()
{
	level.reveal_filtered_node ScaleVolume(0, 3);
	
	wait 0.2;
	level.crane_beam = GetEnt( "reveal_crane_org", "targetname" );
	level.crane_beam PlaySound( "scn_factory_garage_reveal_crane" );
	
	wait 3;
	level.reveal_filtered_node delete();
}

sfx_garage_reveal_filtered()
{
	wait 0.1;
	level.reveal_filtered_node = Spawn( "script_origin", (4937, 3279, 300) );
	level.reveal_filtered_node PlayLoopSound( "scn_factory_garage_reveal_filtered" );
}

sfx_reveal_mix_trigger_setup()
{
	stairs_trig = GetEnt( "trigger_warehouse_stairs", "targetname" );
	stairs_trig thread sfx_reveal_mix_down();
}

sfx_reveal_mix_down()
{
	self waittill( "trigger" );
	
	if( isdefined(level.crane_beam) )
	{
		level.crane_beam ScaleVolume(0.4, 5);
		
		flag_wait( "ps_begin" );
		
		wait 3;
		level.crane_beam ScaleVolume(0.1, 7);
		
		wait 7;
		level.crane_beam ScaleVolume(0, 0.1);
		wait 0.1;
		level.crane_beam delete();
	}
}

sfx_rods_move()
{
	//wait 0.5;
	rog = GetEnt( "satellite_ROG_05_org", "targetname" );
	//IPrintLnBold("Rods Mvmt");
	rog PlaySound("scn_factory_rods_mvmt");
	level.player PlaySound("scn_factory_rods_verb_lr");
}

sfx_bridge_lower(bridge)
{
	bridge PlaySound("scn_factory_bridge_lower");
}
ambush_start_intro_foley_sfx()
{
		level.player PlaySound( "scn_factory_ambush_intro" );
		wait 0.1;
		if(IsDefined(level.keegan_search_desk_sfx))
		{
			level.keegan_search_desk_sfx ScaleVolume(0.0, 0.1);
			wait 0.2;
			level.keegan_search_desk_sfx StopSounds();
			level.keegan_search_desk_sfx delete();
		}
		else
		{
			flag_set( "sfx_dont_play_desk" );
		}
}

ambush_battle_start_ambience_change()
{
	level.player playsound("scn_factory_ambush_door_breach_lr");
	level.player SetClientTriggerAudioZone( "factory_wh1_ambush_slomo", 0.01 );
	//maps\_audio::set_mix( "ambush_slomo" );
	flag_set ( "sfx_slowmo_begins" );
	wait 2.4;
	level.player ClearClientTriggerAudioZone( 0.2 );
	//maps\_audio::set_mix( "after_ambush_scene" );
	//set_audio_zone( "factory_wh1_ambush_control_room_after" );	
}

ambush_start_fx_sounds()
{
	play_loopsound_in_space("emt_ambush_fire_lp", (5198, -2361, 294));
	play_loopsound_in_space("emt_ambush_fire_lp", (4728, -2638, 398));
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (5193, -2230, 297) );
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (4924, -2709, 507) );
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (4040, -2704, 495) );
	
	play_loopsound_in_space("emt_factory_ambush_alarm_05", (5263, -1547, 708) );
	play_loopsound_in_space("emt_factory_ambush_alarm_04", (3601, -2704, 428) );
	play_loopsound_in_space("emt_factory_ambush_alarm_04", (4058, -2704, 460) );
	//play_loopsound_in_space("emt_ambush_fire_lp", (5401, -2192, 297));
	
			    
}

sfx_ambush_alarm_sound()
{
	wait 0.5;
	play_loopsound_in_space("emt_factory_ambush_alarm_01", (5559, -698, 394) );
	play_loopsound_in_space("emt_factory_ambush_alarm_01", (5994, -936, 402) );
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (5873, -466, 369) );
	play_loopsound_in_space("emt_ambush_fire_lp", (5198, -2361, 294));
	play_loopsound_in_space("emt_ambush_fire_lp", (4728, -2638, 398));
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (5193, -2230, 297) );
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (4924, -2709, 507) );
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (4040, -2704, 495) );
	//Main Factory
	play_loopsound_in_space("emt_factory_ambush_alarm_05", (5263, -1547, 708) );
	//Hallway
	play_loopsound_in_space("emt_factory_ambush_alarm_05b",(3648, -1799, 500));
	play_loopsound_in_space("emt_factory_ambush_alarm_04", (4058, -2704, 460) );
	play_loopsound_in_space("emt_factory_ambush_alarm_04", (4012, -1443, 428) );
	
	play_loopsound_in_space("emt_factory_ambush_alarm_02", (3931, -1780, 426) );
	//play_loopsound_in_space("emt_factory_ambush_alarm_03", (5256, -1523, 558) );
	//level.ambush_alarm = Spawn( "script_origin", ( 4568, 3664, 260 ) );
	//level.ambush_alarm playloopsound( "emt_factory_ambush_alarm_01" );
}
ambush_smoke_grenade_explo_sfx()
{
	thread play_sound_in_space( "scn_factory_ambush_smoke_explo01",  (5658, -1255, 280) );
	wait 0.4;
	thread play_sound_in_space( "scn_factory_ambush_smoke_explo02",  (5317, -733, 280) );
}
	
sfx_pa_bursts()
{
	/*
	//pa_01 = Spawn( "script_origin", (3751, -2337, 500) );
	pa_02 = Spawn( "script_origin", (3554, -1852, 486) );
	pa_03 = Spawn( "script_origin", (3994, -1361, 500) );
	i = 1;
	//alias_office = "null";
	alias_hall = "null";
	
	wait 1.5;
	
	while(1)
	{
		switch(i)
		{
			case 1:
				//alias_office = "emt_factory_pa_burst_office_01";
				alias_hall = "emt_factory_pa_burst_hall_01";
				break;
			case 2:
				//alias_office = "emt_factory_pa_burst_office_02";
				alias_hall = "emt_factory_pa_burst_hall_02";
				break;
			case 3:
				//alias_office = "emt_factory_pa_burst_office_03";
				alias_hall = "emt_factory_pa_burst_hall_03";
				break;
			case 4:
				//alias_office = "emt_factory_pa_burst_office_04";
				alias_hall = "emt_factory_pa_burst_hall_04";
				break;
			case 5:
				//alias_office = "emt_factory_pa_burst_office_05";
				alias_hall = "emt_factory_pa_burst_hall_05";
				break;
		}
		
		//pa_01 PlaySound( alias_office );
		pa_02 PlaySound( alias_hall );
		wait 0.1;
		pa_03 PlaySound( alias_hall );

		i++;
		if (i > 5) i = 1;
		
		wait RandomFloatRange(4.0, 6.0);
	}
	*/
}

sfx_stop_truckchatter()
{
	level.truckchatter StopSounds();	
}

sfx_rolling_gate_sounds( ent )
{
	//ent PlaySound("scn_factory_fence_close");	
}

sfx_play_stacker_down()
{
	self delaycall( 0.15, ::PlaySound, "emt_factory_stacker_down");	
}

sfx_play_stacker_up()
{
	self delaycall( 0.15, ::PlaySound, "emt_factory_stacker_up");
}

sfx_end_slomo_sound()
{
	level.player playsound("scn_factory_ambush_slomo_end");	
}

sfx_play_crash_scene()
{
	self PlaySound( "scn_factory_chase_truck_intro" );
	
	level waittill ( "semi_stopped" );
	//IPrintLnBold("Audio Start - semi pull away");
	level.ally_vehicle_trailer PlaySound( "scn_factory_chase_truck_pullaway" );
	wait 0.788;
	level.ally_vehicle_trailer PlaySound( "scn_factory_chase_truck_tires" );
		
	flag_wait("player_mount_vehicle_start");
	//IPrintLnBold("Audio Start - player mount");
	level.player PlaySound( "scn_factory_chase_truck_mount" );
	
}

sfx_play_heartbeat_sound()
{
	level.heartbeat_sound = Spawn( "script_origin", ( 4800, 1800, 1 ) );
	level.heartbeat_sound playloopsound( "emt_factory_heartbeat_controlroom" );
	flag_wait( "sfx_slowmo_begins" );
	level.heartbeat_sound scalevolume( 0, 0 );
	wait 0.1;
	level.heartbeat_sound stopsounds();
	level.heartbeat_sound delete();
}

sfx_explo_after_flashbang()
{
	play_sound_in_space( "explo_after_flashbang", ( 5313, -2226, 326 ) );		
}

sfx_keegan_desk()
{
	if( !flag( "sfx_dont_play_desk" ) )
	{
		level.keegan_search_desk_sfx = Spawn( "script_origin", self.origin );
		level.keegan_search_desk_sfx LinkTo(self);
		level.keegan_search_desk_sfx playsound( "scn_factory_keegan_search_desk" );
	}
}

sfx_jeep_drive_up_01()
{

	self Vehicle_TurnEngineOff();
	//self playsound( "scn_factory_chase_enemy_jeep_drive_up" );
	play_sound_in_space("scn_factory_chase_enemy_jeep_drive_up", (-1069, -455, 44));
}
 
sfx_jeep_drive_up_02()
{
	self Vehicle_TurnEngineOff();
	//self playsound( "scn_factory_chase_enemy_jeep_drive_up" );
}

sfx_tank_drive_up()
{
	wait 0.7;
	self Vehicle_TurnEngineOff();
	self playsound( "scn_factory_chase_enemy_tank_drive_up" );
}

// TEMP!!!! JEREMEY - CF ADDED THIS AS TEMP FOR INTRO KILL SFX
sfx_introkill_splash_player()
{
	level.player playsound( "warl_towerstab_grab" );
	level.player playsound( "scn_factory_intro_water_splash" );
	level.player playsound( "warl_towerstab_slice" );
	wait 0.15;
	level.player playsound( "scn_factory_intro_water_splash" );
	wait 0.17;
	level.player playsound( "scn_factory_intro_water_splash" );
}
	
// TEMP!!!! JEREMEY - CF ADDED THIS AS TEMP FOR INTRO KILL SFX
sfx_introkill_splash_baker()
{
	level.player playsound( "scn_factory_intro_water_splash" );
	wait 0.15;
	level.player playsound( "scn_factory_intro_water_splash" );
	wait 1.27;
	level.player playsound( "scn_factory_intro_water_splash" );
	wait 0.10;
	level.player playsound( "warl_towerstab_slice" );
}

sfx_intro_helicopter_and_splash( chopper )
{
	chopper playsound( "scn_factory_introhelicopter_pass" );
	level.player playsound( "scn_factory_intro_water_splash" );
}

sfx_rod_sounds( rod )
{
	thread wait_and_play_end_alarm();
	rod playsound( "emt_factory_sat_motor_01" );
	level.sat_alarm1 = Spawn( "script_origin", ( 7114, 147, 1346 ) );
	level.sat_alarm2 = Spawn( "script_origin", ( 7428, -1599, 1346 ) );
	level.sat_alarm3 = Spawn( "script_origin", ( 6468, -783, 317 ) );
	level.sat_alarm1 playloopsound( "emt_factory_sat_alarm" );
	level.sat_alarm2 playloopsound( "emt_factory_sat_alarm" );
	level.sat_alarm3 playloopsound( "emt_factory_sat_alarm" );
}

wait_and_play_end_alarm()
{
	wait 18;
	thread play_sound_in_space( "emt_factory_sat_alarm2", 	( 7114, 147, 1346 ) );
	thread play_sound_in_space( "emt_factory_sat_alarm2", ( 7428, -1599, 1346 ) );
	level.sat_alarm1 scalevolume(0, 1.5);
	level.sat_alarm2 scalevolume(0, 1.5);
	level.sat_alarm3 scalevolume(0, 1.5);
	wait 1.6;
	level.sat_alarm1 delete();
	level.sat_alarm2 delete();
	level.sat_alarm3 delete();
}

moving_platform_warning_beeps_sfx( start_pos )
{

	moving_platform = Spawn( "script_origin", (start_pos - (300,0,-200)) );
	moving_platform LinkTo(self);
	
	wait 3.5;	
	moving_platform playloopsound("emt_factory_moving_platform_beeps");
	//moving_platform ScaleVolume(0.0, 0.01);
	
	wait 0.1;
	//moving_platform ScaleVolume(1.0, 4.5);

	self waittill( "movedone" );
	moving_platform ScaleVolume(0.0,0.2);
	wait 0.4;
	moving_platform StopLoopSound();
	moving_platform delete();
	
}

moving_platform_movement_loop_sfx( start_pos, wait_time )
{
	if(!IsDefined(wait_time))
		wait_time = 30;

	moving_platform = Spawn( "script_origin", start_pos );
	moving_platform LinkTo(self);
	
	moving_platform_close = Spawn( "script_origin", (start_pos) );
	moving_platform_close LinkTo(self);
	
	moving_platform_metal = Spawn( "script_origin", (start_pos) );
	moving_platform_metal LinkTo(self);
	
	moving_platform playloopsound("emt_moving_platform_movement_lp");
	moving_platform_close playloopsound("emt_moving_platform_movement_close_lp");
	moving_platform_metal playloopsound("emt_moving_platform_metal_lp");
	
	//moving_platform ScaleVolume(0.0, 0.01);
	//moving_platform_close ScaleVolume(0.0, 0.01);
	//moving_platform_metal ScaleVolume(0.0, 0.01);
	
	wait 1.5;
	//moving_platform ScaleVolume(1.0, 1);
	//moving_platform_close ScaleVolume(1.0, 0.5);
	//moving_platform_metal ScaleVolume(1.0, 4.5);
	
	
	wait wait_time;

	moving_platform_stop = Spawn( "script_origin", moving_platform_close.origin );
	moving_platform_stop LinkTo(self);
	moving_platform_stop playsound("emt_factory_moving_platform_stop");
	
	moving_platform ScaleVolume(0.0,8.5);
	moving_platform_close ScaleVolume(0.0,6.5);
	moving_platform_metal ScaleVolume(0.0,6.5);
	
	wait 10.0;
	moving_platform StopLoopSound();
	moving_platform_close StopLoopSound();	
	moving_platform_metal StopLoopSound();	
	
	moving_platform delete();
	moving_platform_close delete();
	moving_platform_stop delete();	
	moving_platform_metal delete();	
}

stealth_kill_throat_stab_sfx()
{
	level.player playsound("scn_factory_player_stealth_kill");
	level.player playsound("factory_sitting_desk_npc_vo");
}

stealth_kill_table_left_sfx()
{	
	if ( IsDefined( self ) )
	{
		wait 0.16;
		self playsound("scn_factory_stealth_kill_table_left");
	}
}

stealth_kill_table_right_sfx() 
{
	if ( IsDefined( self ) )
	{
		self playsound("scn_factory_stealth_kill_table_right");
	}
}

stealth_kill_table_alert_left_sfx()
{	
	if ( IsDefined( self ) )
	{
		wait 0.16;
		self playsound("scn_factory_stealth_kill_table_alert_left");
	}
}

stealth_kill_table_alert_right_sfx() 
{
	if ( IsDefined( self ) )
	{
		self playsound("scn_factory_stealth_kill_table_alert_right");
	}
}

stealth_kill_railing_sfx()
{
	self playsound("scn_factory_stealth_kill_railing");
}


stealth_kill_console_sfx( guy )
{
	if ( !IsDefined( self.knocked_over ) )
	{
		self playsound("scn_factory_stealth_kill_console");
	}
}

stealth_kill_console_chair_sfx()
{
	self playsound("scn_factory_stealth_kill_console_chair");
}

rooftop_heli_speaker_vo_sfx()
{
	self endon ( "rooftop_spotlight_off" );
	
	heli_speaker_vo = Spawn( "script_origin", self.origin );	
	heli_speaker_vo LinkTo( self );
	
	heli_speaker_vo_filtered = Spawn( "script_origin", self.origin );	
	heli_speaker_vo_filtered LinkTo( self );
	
	self thread rooftop_heli_speaker_vo_watcher(heli_speaker_vo, heli_speaker_vo_filtered);
	
	wait 1.0;
	//IPrintLnBold("JL: start vo loops");
	heli_speaker_vo_filtered playloopsound("emt_heli_speaker_vo_filtered_lp");
	heli_speaker_vo playloopsound("emt_heli_speaker_vo_lp");
	heli_speaker_vo ScaleVolume( 0.0, 0.0);

	
	level waittill( "rooftop_door_kicked" );
	//IPrintLnBold("JL: xfade vo loops");
	heli_speaker_vo ScaleVolume( 1.0, 1.5);
	heli_speaker_vo_filtered thread rooftop_heli_speaker_vo_cleanup( 2.5 );
	

}

rooftop_heli_speaker_vo_watcher(heli_speaker_vo, heli_speaker_vo_filtered)
{
	self waittill ( "rooftop_spotlight_off" );
	//IPrintLnBold("JL: stop vo loops");
	
	if( IsDefined(heli_speaker_vo))
		heli_speaker_vo thread rooftop_heli_speaker_vo_cleanup( 0.1 );
	
	if( IsDefined(heli_speaker_vo_filtered))	
		heli_speaker_vo_filtered thread rooftop_heli_speaker_vo_cleanup( 0.1 );
	
}

rooftop_heli_speaker_vo_cleanup( fade_time )
{
	self ScaleVolume( 0.0, fade_time);
	wait fade_time;
	if ( isdefined ( self ))
	{
		self StopLoopSound();
		self delete();
	}
}

rooftop_heli_speaker_destroy()
{
	wait 0.25;
	self playsound("emt_heli_speaker_vo_shootout");
}

rooftop_heli_engine_sfx()
{
	heli_engine_sfx = Spawn( "script_origin", self.origin );	
	heli_engine_sfx LinkTo( self );
	
	//IPrintLnBold("JL: Start Helo Move");
	self playsound("scn_factory_rooftop_heli_reveal");
	
	//Holding off on this for now
	self thread rooftop_heli_lights_on();
	
	self thread rooftop_heli_engine_2nd_move_watcher();
	
	wait 9.0;
	
	heli_engine_sfx PlayLoopSound("scn_factory_rooftop_heli_idle_lp");
	//wait 0.1;
	heli_engine_sfx ScaleVolume( 0.0, 0.01);
	
	wait 0.4;
	heli_engine_sfx ScaleVolume( 1.0, 6.0);
	

	flag_wait ( "rooftop_heli_depart" );
	wait 3.0;
	//IPrintLnBold("JL: Ending Helo - fading out");
	heli_engine_sfx ScaleVolume( 0.0, 25.0);
	wait 25;
	//IPrintLnBold("JL: Kill Helo");
	heli_engine_sfx delete();
	
}

rooftop_heli_lights_on()
{
	wait 1.9;
	//IPrintLnBold("JL: Lights on");
	self playsound("emt_heli_lights_on");
}

rooftop_heli_engine_2nd_move_watcher()
{
	flag_wait ( "player_near_rooftop_door" );
	//IPrintLnBold("JL: Start 2nd Move");
	
	self playsound("scn_factory_rooftop_heli_move");	
}

rooftop_heli_distant_idle_sfx()
{
	//wait 1.4;
	//IPrintLnBold("JL: Starting Distant Helo Loop");
	heli_engine_idle_distant_sfx = Spawn( "script_origin", (3894, -871, 457) );
	
	waitframe();
	heli_engine_idle_distant_sfx PlayLoopSound("scn_factory_rooftop_heli_distant_lp");
	
	flag_wait ( "ambush_escape_clear" );
	heli_engine_idle_distant_sfx ScaleVolume( 0.0, 4.0);
	wait 4.0;
	heli_engine_idle_distant_sfx delete();
}

audio_play_ending_scene()
{
	//thread set_audio_zone("factory_wh1_office_int");
	//wait 3.3;
	level.player playsound( "scn_factory_end_sequence" );
}

sfx_kicking_door_sound()
{
	wait 1.6;
	door1 = spawn( "script_origin", ( 3567, -935, 428 ) );
	door1 playsound( "scn_factory_door_kick_ss" );
	door2 = Spawn( "script_origin", ( 3567, -935, 427 ) );	
	door2 playsound( "scn_factory_door_kick2_ss" );
}