#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;
#include maps\black_ice_vignette;

SCRIPT_NAME = "black_ice_flarestack.gsc";

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "flag_flarestack_scene_start" );
	flag_init( "flag_flarestack_dialogue_start" );
	flag_init( "flag_flarestack_end" );
	flag_init( "flag_flamestack_alarm_light" );
	flag_init( "flag_flarestack_player_pressed_button" );
}
	
section_precache()
{	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_post_inits()
{	
	level._flarestack = SpawnStruct();
	
	// Scene struct
	level._flarestack.scene_struct = GetStruct( "struct_flarestack_ally1", "targetname" );
	
	// Setup flarestack stuff at start of level
	if( IsDefined( level._flarestack.scene_struct ))
	{			
		// Door in
		level._flarestack.door_in = setup_door( "model_flarestack_inside_door", "flarestack_door_in" );		
		level._flarestack.scene_struct anim_first_frame_solo( level._flarestack.door_in, "flarestack_start" );
		
		// Door out
		level._flarestack.door_out = setup_door( "model_flarestack_outside_door", "flarestack_door_out", "jnt_door" );
		level._flarestack.scene_struct anim_first_frame_solo( level._flarestack.door_out, "flarestack_exit" );
		
		// Flarestack initial fire fx
		if( level.start_point != "refinery" )
		{
			thread maps\black_ice_fx::turn_on_flarestack_fx();
			thread maps\black_ice_fx::flarestack_turn_on_console_fx();
		}

		// Hide blood splatter
//		level._flarestack.blood_splatter = GetEnt( "brushmodel_flarestack_blood_splatter", "targetname" );
//		level._flarestack.blood_splatter Hide();
	}
	else
	{
		iprintln( SCRIPT_NAME + ": Warning - Flarestack scene struct missing (compiled out?)" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start()
{
	iprintln( "Flare Stack" );
	
	maps\black_ice_util::player_start( "player_start_flarestack" );
	
	position_tNames = 
	[    
		"struct_ally_start_flarestack_01",
		"struct_ally_start_flarestack_02"
	];
	
	level._allies maps\black_ice_util::teleport_allies( position_tNames );
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_flarestack_int", 2 );

	flag_set( "flag_flarestack_dialogue_start" );
	
	//setExpFog (<Near Plane>, <Half Plane>, <Fog Color.R>, <Fog Color.G>, <Fog Color.B>, <Maximum Opacity>, <Transition Time>);
	//setExpFog( 0, 3240, 0.172549, 0.1803922, 0.2470588, 0.92, 0 );
	
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
}

main()
{
	// Wait to make sure we are past the color trigger frame at the end of the common room
	wait( 0.05 );
	
	
	SetSavedDvar( "r_snowAmbientColor", ( 0.02, 0.02, 0.03 ) );
	
	thread event_pressure_buildup();
	
	thread light_flamestack();
	thread light_hall_light();	
	thread light_alarm_lights();
	thread flamestack_godrays();
	
	thread dialogue();
	
	//AUDIO: Start Flare Stack burning sfx loop
	thread maps\black_ice_audio::sfx_flare_stack_burn();
	
	//let it snow
	exploder( "flamestack_snow" );
	exploder( "refinery_lights_b" );	
	
	// player keyturn event
	thread event_player_turns_key();
	
	//fx for scanning the hand.
	//NOTE: the notify that grants the player control to use the console is cotained in this script to sync it with the scanning/activation
	thread event_scan_manager();
	thread event_switch_animation();
	
	// Allies scripts
	thread allies();
	
	thread fx_door_open();
		
	// END!
	flag_wait( "flag_flarestack_end" );	
	
	activate_trigger_with_targetname( "trig_refinery_ally_1_start" );
	
	//thread change_zone();
	
	//AUDIO: audio changes for exiting flarestack
	thread maps\black_ice_audio::sfx_exited_flarestack();
	
	// Train (periph) movement
	thread maps\black_ice::trains_periph_logic( 6.0, true );
}	

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dialogue()
{	
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	flag_wait( "flag_flarestack_dialogue_start" );	
	
	// Dialogue - Baker - The foreman's in there. We need him alive.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_theforeman" );
	
	level notify( "notify_dialogue_baker_enter_complete" );

	// Console nags	
	thread dialogue_nag();
	
	level waittill( "notify_flarestack_enemy_on_console" );	
	
	// Wait for button rise
	wait( 4 );
			
	// Dialogue - Baker - Copy.  Rook, shut it down.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_shutitdown" );	
	
	level waittill( "notify_flarestack_baker_pistol_fire" );		
	
	// Give a beat after shooting guy
	wait( 1 );
	
	// Dialogue - Baker - Bravo, flare stack's off.  Stay clear of the derrick. It's about to get nasty up there.
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_bravoflarestacksoff" );
	
	// Dialogue - Diaz - Roger that Alpha.  We're clear.
	smart_radio_dialogue( "black_ice_diz_rogerthatalphawereclear" );	
	
	// Dialogue - Baker - Alright, let's head topside.
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_alrightletsheadtopside" );	
	
	// Dialogue - Baker - Stay frosty.  Do not fire until my command.
	level._allies[ 0 ] thread smart_dialogue( "black_ice_bkr_stayfrostydonot" );		
	
	// End of flarestack
	flag_set( "flag_flarestack_end" );
}

dialogue_nag()
{
	level endon( "flag_flarestack_player_pressed_button" );
	
	level waittill( "notify_activate_flarestack_console" );
		
	wait( 8 );
	
	// Dialogue - Baker - Rook, go to the console and shut down the flare stack.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_gotoconsole" );
	
	wait( 8 );
	
	// Dialogue - Baker - Shut down the flare stack!
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_shutdownflare" );
	
	wait( 8 );		
	
	// Dialogue - Baker - The console!  Now!
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_theconsolenow" );
	
	wait( 8 );
	
	// Dialogue - Baker - Go to the console and shut down the flare stack
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_consoleandshut" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies()
{
	array_call( level._allies, ::PushPlayer, true );
	array_thread( level._allies, ::set_forcesuppression, true );
		
	fuentes_exit_node = GetNode( "node_flarestack_fuentes_exit", "targetname" );		
	Assert( IsDefined( fuentes_exit_node ));
	
	// Baker / Enemy flarestack scene
	level._allies[ 0 ] event_flarestack_enter();
	
	// Allies move to final positions	
	level._allies[ 1 ] SetGoalNode( fuentes_exit_node );
	
	flag_wait( "flag_flarestack_end" );		

	level._allies[ 0 ] thread allies_baker_flarestack_exit();	
	
	array_thread( level._allies, ::set_forcesuppression, false );	
}

allies_baker_flarestack_exit()
{	
	// Setup door
	struct = level._flarestack.scene_struct;
	door_out = level._flarestack.door_out;	
	
	flag_wait( "flag_flarestack_end" );
	
	self notify( "stop_loop" );				

	guys = [ self, door_out ];
	
	thread maps\black_ice_audio::sfx_flarestack_door_open();
	
	struct anim_single( guys, "flarestack_exit" );	
	
	door_out.col_brush ConnectPaths();
	
	self enable_ai_color();
}

event_flarestack_enter()
{
	struct = level._flarestack.scene_struct;	
	door_in = level._flarestack.door_in;	
	
	// Send baker to start position
	activate_trigger_with_targetname( "trig_flarestack_ally1_start" );
	
	level waittill( "notify_dialogue_baker_enter_complete" );
	
	flag_wait( "flag_flarestack_scene_start" );
	
	self ignore_everything();

	// spawn the enemy	
	enemy = GetEnt( "enemy_flarestack", "targetname" ) spawn_ai( true );
	enemy.animname = "flarestack_guy";
	enemy.v.nogun = true;
	enemy.v.invincible = true;	
	struct anim_first_frame_solo( enemy, "flarestack_start" );	
	level._flarestack.flarestack_controller = enemy;
	
	// Fail if enemy killed
	enemy thread event_flarestack_enter_fail_watcher();
	
	// Baker moves to start position, then vignette starts
	struct anim_reach_solo( self, "flarestack_start" );
	
	door_in thread event_flarestack_enter_close_door();
										
	struct thread vignette_single_solo( enemy	 , "flarestack_start", "flarestack_idle", undefined, "flarestack_end" );
	struct thread vignette_single_solo( self , "flarestack_start", "flarestack_idle", "flarestack_end" );	
	struct thread anim_single_solo( door_in, "flarestack_start" );
	
	// Connect paths for door
	door_in.col_brush ConnectPaths();
	
	self thread maps\black_ice_audio::sfx_baker_fight_scene();
	
	// Enemy against console
	self waittill( "msg_vignette_start_anim_done" );	
	level notify( "notify_dialogue_clearance_start" );	
	
	// Flare stack turns off	
	level waittill( "notify_flare_stack_off" );	
	
	// Start end anims
	self vignette_interrupt();
	enemy vignette_kill();
	
	// Baker pulls out gun
	level waittill( "notify_flarestack_baker_pistol_pullout" );
	self playsound("scn_blackice_command_baker_pullout");
	gun = spawn_anim_model( "baker_sidearm", self GetTagOrigin( "TAG_INHAND" ));
	gun.angles = self GetTagAngles( "TAG_INHAND" );
	gun Linkto( self, "TAG_INHAND" );
	
	// Baker shoots
	level waittill( "notify_flarestack_baker_pistol_fire" );
	PlayFXOnTag( GetFX( "pistol_muzzleflash" ), gun, "tag_flash" );
	PlayFXOnTag( GetFX( "headshot_blood" ), gun, "tag_flash" );
	PlayFXOnTag( GetFX( "pistol_shot_smoke" ), gun, "tag_flash" );
	exploder ( "flarestack_headshot" );
	gun PlaySound( "weap_m1014_fire_npc" );
	enemy playsound("scn_blackice_command_baker_kill");
//	level._flarestack.blood_splatter Show();
	
	// Baker puts gun away
	level waittill( "notify_flarestack_baker_pistol_putaway" );
	gun delete();
	
	// Kill the AI (anim keeps playing)
//	enemy.a.nodeath = true;
//	enemy.allowdeath = true;
//	enemy stop_magic_bullet_shield();
//	enemy kill();		
	
	self waittill( "msg_vignette_interrupt_break_done" );
	
	// Baker idling at door		
	self cover_left_idle( "node_flarestack_baker_exit" );
}

event_flarestack_enter_fail_watcher()
{
	level endon( "flag_flarestack_player_pressed_button" );	
	
	while( 1 )
	{
		self waittill( "damage", amt, attacker, vec, point, type );
		if( type != "MOD_IMPACT" )
			break;
	}
	SetDvar( "ui_deadquote", &"BLACK_ICE_FLARESTACK_FAIL_ENEMY_KILL" );
	missionFailedWrapper();
}

event_flarestack_enter_close_door()
{	
	fuentes_warp_node = GetNode( "node_flarestack_ally2_start", "targetname" );
	Assert( IsDefined( fuentes_warp_node ));
		   
	flag_wait( "flag_flarestack_player_pressed_button" );
	
	level._allies[ 1 ] ForceTeleport( fuentes_warp_node.origin, fuentes_warp_node.angles );	
	self.angles = self.original_angles;
	wait( 0.05 );
	self.col_brush DisconnectPaths();		
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_player_turns_key()
{		
	//wait for notetrack trigger to start audio
	thread audio_start_pressure();
	
	player_struct = GetStruct( "struct_flarestack_player", "targetname" );
	Assert( IsDefined( player_struct ));
	
	// Setup button trigger
	button_trigger = GetEnt( "trig_flarestack_button", "targetname" );
	Assert( IsDefined( button_trigger ));		
	button_trigger trigger_off();
	
	// Setup player and blend them to anim
	player_rig = spawn_anim_model( "player_rig", level.player.origin );	
	
	//setup anims
	player_struct anim_first_frame_solo( player_rig, "turn_off_flare_stack" );
	
	//hide rig for blend
	player_rig Hide();	
	
	// Wait for button activation
	level waittill( "notify_activate_flarestack_console" );
	
	//wait for player imput
	util_wait_for_player_button_press( button_trigger );
	
	level.player AllowCrouch( false );
	level.player AllowProne( false );	
	level.player AllowMelee( false );
		
	// Start player vignette sequence
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player DisableWeaponSwitch();		
	
	//blend to rig while dropping weapon
	blendtime = 0.6;
	level.player PlayerLinkToBlend( player_rig, "tag_player", blendtime );
	
	//unhide rig and key after blend
	thread util_show_rig_after_blend( blendtime, player_rig );
	
	//play anims
	player_struct thread anim_single_solo( player_rig, "turn_off_flare_stack" );

	//cleanup(triggered in stages via notetrack so the player will draw his weapon before ending vignette)
	level waittill( "notify_player_draw_weapon" );
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player EnableWeaponSwitch();	
	
	level waittill( "notify_player_unlink" );
	level.player unlink();
	player_rig Delete();
	
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	level.player AllowMelee( true );
}

util_wait_for_player_button_press( button_trigger )
{
	// Player prompted to push button
	button_trigger waittill_trigger_activate_looking_at( level._flarestack.console, 0.5 );	
	
	flag_set( "flag_flarestack_player_pressed_button" );
	
	//AUDIO: Play console use sfx
	thread maps\black_ice_audio::sfx_use_console();
}

fx_console_button_light( console )
{	
	PlayFXOnTag( GetFX( "console_light_blink" ), console, "tag_fx_button" );
	
	//anim notetrack will notify when to stop blinking
	level waittill( "notify_flare_stack_button_press" );
	
	StopFXOnTag( GetFX( "console_light_blink" ), console, "tag_fx_button" );
	level.player PlayRumbleOnEntity( "damage_light" );
	
}

util_show_rig_after_blend( blendtime, player_rig )
{
	wait( blendtime );
	player_rig Show();
}

light_hall_light()
{
	lights = GetEntArray( "flarestack_hallway_1", "targetname" );
	flag_wait( "flag_flarestack_player_pressed_button" );
	foreach( light in lights )
	{
		light SetLightIntensity( 0.01 );
		light SetLightRadius( 12 );
	}
}

light_alarm_lights()
{
	
	lights_on  = GetEntArray( "flarestack_light_siren", "targetname" );
	lights_off = GetEntArray( "flarestack_light_siren_off", "targetname" );
	
	effect_sources = [];
	
	i = 0;
	foreach( light in lights_on )
	{
		
		effect_source_red = spawn_tag_origin();
		
		effect_source_red.origin = light gettagorigin( "TAG_fx_main" );
		effect_source_red.angles = light gettagangles( "TAG_fx_main" );
	
		effect_source_red LinkTo( light,  "TAG_fx_main" );
		
		effect_sources[i] = effect_source_red;
		
		light hide();
		
		i++;
	}
	
	red_lights = GetEntArray( "flarestack_emergency_1", "targetname" );
		
	level waittill( "notify_stop_flare_stack" );
	
	//wait a minute for the rigth time to start alarms	
	wait( 6.0 );
	
	thread maps\black_ice_audio::sfx_start_flarestack_room_siren();
	
	while( 1 )
	{
		//on!
		if( flag( "flag_flamestack_alarm_light" )  )
		{
			foreach( light in lights_on )
			{
				light show();
			}
			foreach( light in lights_off )
			{
				light hide();
			}
			foreach( effect in effect_sources )
			{
				PlayFXOnTag( level._effect[ "flarestack_siren_red" ], effect, "tag_origin" );
			}
			foreach( light in red_lights )
			{
				light SetLightIntensity( 2.0 );
			}
		}
		
		wait( 1 );
		
		//off!
		foreach( light in lights_on )
		{
			light hide();
		}
		foreach( light in lights_off )
		{
			light show();
		}
		foreach( effect in effect_sources )
		{
			StopFXOnTag( level._effect[ "flarestack_siren_red" ], effect, "tag_origin" );
		}
		foreach( light in red_lights )
		{
			light SetLightIntensity( 0.01 );
		}
		
		wait( 0.5 );
	}

}

audio_start_pressure()
{
	level waittill( "notify_stop_flare_stack" );
	// Trigger audio (temp until we get new sequence in )
	thread maps\black_ice_audio::audio_derrick_explode_logic( "start" );
	level waittill( "notify_flare_stack_button_press" );
}
//*******************************************************************
//																	*
//		Light Script												*
//*******************************************************************

flamestack_godrays()
{
	gr_origin = getEnt("origin_flarestack_fx","targetname");
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_catwalk");
		god_rays_from_world_location ( gr_origin.origin, "flag_flarestack_scene_start", "flag_flarestack_player_pressed_button", "black_ice_flamestack", undefined);
	}
}
light_flamestack()
{
	flamelight = GetEnt("flarestack_window_1","targetname");
	flamelight SetLightIntensity(2.5);
	flag_wait("flag_flarestack_scene_start");
	flamelight light_flamestack_flicker();
	flamelight SetLightIntensity(3.0);
	wait 0.1;
	flamelight SetLightColor((0.68, 0.81, 0.82));
	flamelight SetLightIntensity(0.8);
	maps\_art::sunflare_changes("mudpumps",0.1);
	vision_set_fog_changes("black_ice_refinery",6);
	
}

light_flamestack_flicker()
{
	fullIntensity = self GetLightIntensity();
	level endon( "flag_flarestack_player_pressed_button" );		
	for(;;)
	{
		//Brute Force...will copy light pulse script for more elegant solution
		self SetLightIntensity(fullIntensity);
		wait 0.07;
		self SetLightIntensity(fullIntensity*0.9);
		wait 0.05;
		self SetLightIntensity(fullIntensity*0.85);
		wait 0.1;
		self SetLightIntensity(fullIntensity*0.9);
		wait 0.05;
		self SetLightIntensity(fullIntensity);
		wait 0.05;
		self SetLightIntensity(fullIntensity*0.85);
		wait 0.05;
		self SetLightIntensity(fullIntensity*0.75);
		wait 0.075;
		self SetLightIntensity(fullIntensity*0.85);
		wait 0.1;
		self SetLightIntensity(fullIntensity);
		wait 0.05;		
	}
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

/*
change_zone()
{
	wait 2;
	//IPrintLnBold("Setting audio zone");
	set_audio_zone( "blackice_oilrig", 2 );
}
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_pressure_buildup()
{
		level waittill ( "notify_flare_stack_off" );
		event_pressure_buildup_start();
}

event_pressure_buildup_start( ramp_in_quakes )
{
	
	dist_node = GetStruct( "struct_rumble_dist", "targetname" );	
	normalized_dist_to_explosion = 0.0;
	
	//time it takes to ramp in the full quake effect
	if ( !IsDefined( ramp_in_quakes ) )
		ramp_in_quakes = 9.0;
	
	//the static shaking min and max, based on how close you are to the event occuring
	max_base_quake = 0.11;
	min_base_quake = 0.05;
	
	//distance from event to ramp in the effect
	max_dist = 1000;
	min_dist = 200;
	
	//random time between big shakes
	spike_random_time_max = 3.0;
	spike_random_time_min = 0.4;
	
	//initial random min and max for random big shakes
	spike_min_min = 0.12;
	spike_min_max = 0.18;
	
	//max random min and max for random bug shakes, based on how close you are to having the event occur
	spike_max_min = 0.18;
	spike_max_max = 0.25;
	
	//random duration for random big shakes
	spike_min_dur = 0.7;
	spike_max_dur = 1.1;
	
	current_random_spike_time = RandomFloatRange(spike_random_time_min, spike_random_time_max );
	
	ramp_in_quakes_mod = 1.0;
	//presubtract a fraction cause zero would be bad later
	ramp_in_quakes_timer = ( ramp_in_quakes - level.TIMESTEP);
	
	while( 1 )
	{	
		dist_to_explosion = Distance( level.player.origin, dist_node.origin );
			
		//IPrintLn( dist_to_explosion );
		
		normalized_dist_to_explosion = maps\black_ice_util::normalize_value( min_dist, max_dist, dist_to_explosion );
		
		//IPrintLn( normalized_dist_to_explosion );
		
		quake_mag = maps\black_ice_util::factor_value_min_max( max_base_quake, min_base_quake, normalized_dist_to_explosion );
		spike_min = maps\black_ice_util::factor_value_min_max( spike_max_min, spike_min_min, normalized_dist_to_explosion );
		spike_max = maps\black_ice_util::factor_value_min_max( spike_max_max, spike_min_max, normalized_dist_to_explosion );
		
		//quakemag = max_base_quake;
		
		//IPrintLn( "quakemag = " + quake_mag );
		if ( ramp_in_quakes_timer > 0 )
		{
			ramp_in_quakes_mod = maps\black_ice_util::normalize_value( 0.0, ramp_in_quakes, ramp_in_quakes_timer );
			ramp_in_quakes_mod = 1 - ramp_in_quakes_mod;
		}
		else
			ramp_in_quakes_mod = 1.0;
		
		//iprintln( "ramp_in_quakes_timer = " + ramp_in_quakes_timer + " ramp_in_quakes_mod = " + ramp_in_quakes_mod );
		
		quake_mag = quake_mag * ramp_in_quakes_mod;
		earthquake( quake_mag, 0.2, level.player.origin, 128 );
		
		//spikes
		if ( current_random_spike_time < 0.0 )
		{
			current_random_spike_time = RandomFloatRange(spike_random_time_min, spike_random_time_max );
			//IPrintLn( "spike!"  );
			
			dur = RandomFloatRange(spike_min_dur, spike_max_dur );
			
			spike_mag = RandomFloatRange(spike_min, spike_max );
			
			//IPrintLn( "spike! mag = " + spike_mag + " dur = " + dur );
			spike_mag = spike_mag * ramp_in_quakes_mod;
			earthquake( spike_mag, dur, level.player.origin, 128 );
			
			//AUDIO: screenshake sfx
			thread maps\black_ice_audio::sfx_screenshake();
		}
				
		if ( flag( "flag_derrick_exploded" ) )
			break;
		
		wait level.TIMESTEP;
		
		ramp_in_quakes_timer = ramp_in_quakes_timer - level.TIMESTEP;
		current_random_spike_time = current_random_spike_time - level.TIMESTEP;
	}
}

fx_door_open()
{	
	level waittill( "notify_flamestack_door_open" );
	exploder( "flamestack_door_open" );
	
	//kill amb fx from common and barracks
	stop_exploder ( "barracks_ambfx" );
	stop_exploder ( "common_room_ambfx" );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_scan_manager()
{
	
	level waittill ( "notify_flarestack_start_scan" );
	
	thread maps\black_ice_audio::sfx_hand_scan();
	
	exploder( "flamestack_scan_on" );
	
	//magic number, wait for scan to finish then open up console and let player activate
	wait( 4.75 );
	
	//open up console and grant player control to use switch
	level notify( "notify_activate_flarestack_console" );
	
	//turn off hand scanner after leaving flarestack
	level waittill ( "notify_refinery_explosion_start" );
	
	stop_exploder( "flamestack_scan_on" );
	//exploder( "flamestack_scan_off" );
	
}

event_switch_animation()
{
	//setup console
	console = GetEnt( "flarestack_shutoff_button", "targetname" );
	level._flarestack.console = console;
	console assign_animtree( "flare_stack_console" );
	console anim_first_frame_solo( console, "console_open" );
	
	//wait for scan hand, then open console
	level waittill( "notify_activate_flarestack_console" );
	
	console thread anim_single_solo( console, "console_open" );
	
	//give a moment for button to come out
	wait( 1.2 );

	//turn on and manage console light
	thread fx_console_button_light( console );
	
	//wait for player to flip switch
	level waittill( "notify_console_flip_switch" );
	
	//flip switch
	console thread anim_single_solo( console, "turn_off_flare_stack" );
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
fx_flarestack_motion()
{
	flarestack = GetEntArray( "flamestack_anim", "targetname" );
	flarestack_node_from_map = GetEnt( "flarestack_anim_node", "script_noteworthy" );
	
	// tagBR< Note >: Have to spawn one (not use the Radiant map one) due to needing a model for linking...grrrr
	flarestack_node = flarestack_node_from_map spawn_tag_origin();
	
	// Link the flarestack to the control node
	foreach ( ent in flarestack )
	{
		ent LinkTo( flarestack_node );
	}
	
	// Initial kick when the flame shuts off
	wait 0.5;
	flarestack_node Vibrate( ( 1, 0, 0 ), 0.2, 1.7, 1.0 );
	
	level waittill( "flamestack_steam_vent" );
	
	// Bigger kicks for the explosion, and taper off
	flarestack_node Vibrate( ( 1, 0, 0 ), 0.5, 1.0, 1.0 );
	wait 1.0;
	flarestack_node Vibrate( ( 1, 0, 0 ), 0.75, 0.7, 0.7 );
	wait 0.7;
	flarestack_node Vibrate( ( 1, 0, 0 ), 0.5, 1.0, 1.0 );
	wait 1.0;
	flarestack_node Vibrate( ( 1, 0, 0 ), 0.25, 1.0, 1.0 );
	wait 1.0;
	flarestack_node Vibrate( ( 1, 0, 0 ), 0.1, 1.0, 1.0 );
	wait 1.0;
	flarestack_node Vibrate( ( 1, 0, 0 ), 0.01, 1.0, 1.0 );
}
