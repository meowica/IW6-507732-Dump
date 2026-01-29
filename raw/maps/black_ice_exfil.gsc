#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;

SCRIPT_NAME = "black_ice_exfil.gsc";
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start()
{
	iprintln( "Exfil" );
	
	maps\black_ice_util::player_start( "player_start_exfil" );
	
	position_tNames = 
	[    
		"struct_ally_start_exfil_01",
		"struct_ally_start_exfil_02"
	];
	
	level._allies maps\black_ice_util::teleport_allies( position_tNames );
	//TimS - setting black ice exfil amb
	level.player SetClientTriggerAudioZone( "blackice_exfil_int", 2 );	
	
	level._command.door_out thread open_door( 90, 1 );
	
	thread maps\black_ice_command::command_light_change();
		
	//maps\black_ice_fx::pipe_deck_water_suppression_fx();
		
	//exploder( "pipedeck_giant_smoke_for_exfil" );
	//maps\black_ice_fx::exfil_heli_smoke_fx_01();
	
	//fx turn on command center interior fx
	exploder ( "fx_command_interior" );
	
	// Remove refinery geo
	thread maps\black_ice_refinery::util_refinery_stack_cleanup();
	thread black_ice_geyser2_pulse();
	SetSavedDvar( "r_snowAmbientColor", ( 0.01, 0.01, 0.01 ) );
	
}

main()
{		
	//TimS - setting black ice exfil amb
	level.player SetClientTriggerAudioZone( "blackice_exfil_int", 2 );	
	
	// Pipe explosion anims (on run out )
	thread event_pipe_explosions();
	
	// Temp fix to remove blocker
	blocker = GetEnt( "brush_pipe_run_blocker", "targetname" );
	if( IsDefined( blocker ))
	{
		blocker ConnectPaths();
		blocker delete();
	}
	
	
	// exfil oil rig model
	oil_rig = spawn_anim_model( "exfil_oilrig" );
	oil_rig thread retarget_rig();
	lifeboat1 = spawn_anim_model( "exfil_lifeboat1" );
	lifeboat2 = spawn_anim_model( "exfil_lifeboat2" );
	lifeboat3 = spawn_anim_model( "exfil_lifeboat3" );	
	lifeboat4 = spawn_anim_model( "exfil_lifeboat4" );
	lifeboat5 = spawn_anim_model( "exfil_lifeboat5" );
	lifeboat6 = spawn_anim_model( "exfil_lifeboat6" );
	lifeboat7 = spawn_anim_model( "exfil_lifeboat7" );
	lifeboat8 = spawn_anim_model( "exfil_lifeboat8" );
	lifeboat9 = spawn_anim_model( "exfil_lifeboat9" );
	lifeboat10 = spawn_anim_model( "exfil_lifeboat10" );
	lifeboat11 = spawn_anim_model( "exfil_lifeboat11" );
	lifeboat12 = spawn_anim_model( "exfil_lifeboat12" );
	lifeboat13 = spawn_anim_model( "exfil_lifeboat13" );
	lifeboat14 = spawn_anim_model( "exfil_lifeboat14" );
	lifeboat15 = spawn_anim_model( "exfil_lifeboat15" );
	lifeboat16 = spawn_anim_model( "exfil_lifeboat16" );
	lifeboat17 = spawn_anim_model( "exfil_lifeboat17" );
	lifeboat18 = spawn_anim_model( "exfil_lifeboat18" );
	lifeboat19 = spawn_anim_model( "exfil_lifeboat19" );
	lifeboat20 = spawn_anim_model( "exfil_lifeboat20" );
	
	playerlegs = spawn_anim_model( "player_legs_exfil" );
	


	oil_rig Hide();
	playerlegs Hide();
//	level waittillThread( "notify_exfil_showlegs", ::show_legs, playerlegs );
	thread maps\black_ice_fx::exfil_oilrig_preboom_fx(oil_rig);
	
	
	//setup anim node for final flyout vignette.  It will teleport, so it needs to be a spawned tag_origin that can be moved and move the scene with it.
	struct = level._exfil.struct;	

	final_anim_node = spawn_tag_origin();
	final_anim_node.origin = struct.origin;
	final_anim_node.angles = struct.angles;	
	
	//anim node for cornering anims during exfil
	
	cornering_struct = GetStruct( "vignette_exfil_runout" ,"script_noteworthy" );
	
	flag_set( "flag_stop_fire_tower_sfx_logic" );

	thread player_sprint();
	thread ally_sprint();
	thread dialog_main();
	thread player_heat_fx();
	thread exfil_slomo();
	thread exfil_heli( struct );
	thread exfil_random_quaker();
	thread exfil_deck_explosions();
	thread exfil_hall_explosions();
	//thread setup_siren_light();
	thread rotateLights("light_spinner_h","light_spin_h","yaw");
	thread rotateLights("light_spinner_v","light_spin_v","pitch");
	thread rotateLights("light_spinner_v2","light_spin_v2","pitch");
	thread exfil_light_burst();
	thread exfil_steam_burst();
	thread exfil_hall_light_flicker();
	thread exfil_engine_fires();
	thread exfil_yellow_alarms();
	//thread open_exfil_door();
	thread flyout_lights();
	thread exfil_dof();
	thread exfil_vision_bump();
	//thread exfil_rimlight();
	
	//SetSunFlarePosition((-6.46712, -142.115, 0));
	
	// Guys run to heli	
	guys = level._allies;	
	array_thread( guys, ::set_goal_radius, 8 );
	
	//TAG CP If this wait is not commneted out, I checked in some debug stuff and I am stupid.
	//wait 10000;
	
	//reach and play anims for exfil.
	thread exfil_anims_cornering( cornering_struct, struct, guys, 1 );
	thread exfil_anims_cornering( cornering_struct, struct, guys, 0 );
	
	//wait for guys to get to the right point of thier anim
	level waittill( "notify_start_ladder_chase" );
	

	
	flag_set( "flag_ladder_chase" );
	
	// Setup player rig and load everyone into one array
	maps\black_ice_util::setup_player_for_animated_sequence( false, undefined, undefined, undefined, true, true );
	level.player_rig hide();
	
	//combine arrays for final vignette
	scene_pieces = [ level.player_rig, oil_rig, playerlegs, lifeboat1, lifeboat2, lifeboat3, lifeboat4, lifeboat5, lifeboat6, lifeboat7, lifeboat8, lifeboat9, lifeboat10, lifeboat11, lifeboat12, lifeboat13, lifeboat14, lifeboat15, lifeboat16, lifeboat17, lifeboat18, lifeboat19, lifeboat20 ];
	guys = array_combine( guys, level._exfil_heli );
	guys = array_combine( scene_pieces, guys );
	
	// Link everyone to node
	foreach( guy in guys )
	{
		guy Linkto( final_anim_node );
	}
			
	guys = array_add( guys, oil_rig );	
	
	final_anim_node thread anim_single( guys, "ladder_chase" );	
	final_anim_node thread exfil_teleport( oil_rig );

	// attach boat wakes
	lifeboats = [ lifeboat1, lifeboat2, lifeboat3, lifeboat4, lifeboat5, lifeboat6, lifeboat7, lifeboat8, lifeboat9, lifeboat10, lifeboat11, lifeboat12, lifeboat13, lifeboat14, lifeboat15, lifeboat16, lifeboat17, lifeboat18, lifeboat19, lifeboat20 ];
	foreach( lifeboat in lifeboats )
	{
		thread maps\black_ice_fx::fx_exfil_lifeboat_wake(lifeboat); 	
	}	
	
	// Explosions during ladder chase
	thread ladder_chase_explosion_fx();
	//effect of explosion on player
	thread player_explosion_reaction();
	
	//check to see if the player jumps at the right time.  Also plays anims and does all jump events to reduce frame lag.  
	thread ladder_player_jumpcheck();
	
	//player will drop the gun right before jumping
	thread player_dropgun_before_jump();
	
	//Rupperband the scene until the player jumps off the side.
	rubberband_ladder_chase( guys );
	
	//if player is farther than this, player will not autograb ladder.  mission failed.
	
	if( ( level.jump_distance_allowed == false ) || flag("flag_ladder_jumpfail_nojump" ) )
	{
		//player is too far from rope when jumping, or has missed his window to jump
		//give him a moment to see if he is actively attempting a jump or just hanging out on the rig.  
		//triggering "flag_ladder_autojump" would suggest the player is trying to jump,
		//If he never passes that volume, he is just hanging out and will just die in explosions.
		distcheck_timeout = 1.0;
		while( distcheck_timeout > 0.0 )
		{
			if( flag( "flag_ladder_autojump" ) )
			{
				flag_set( "flag_jumped_too_late" );
				break;
			}

			distcheck_timeout -= level.TIMESTEP;
			wait level.TIMESTEP;		
		}
		//set this flag because the player is either too far from the rope, or the flag is already set.
		flag_set("flag_ladder_jumpfail_nojump");				
	}
	
	if( flag( "flag_jumped_too_late" ))
	{
		//plauyer did not jump, ran off the edge.
		
		//cool smoke fx during fall
		thread maps\black_ice_fx::exfil_player_view_smoke_particles();
		
		//play fail vignetter for player only
	   	fail_player_rig = spawn_anim_model( "player_rig" );
		fail_player_rig Hide();
		blendtime = 0.8;
		final_anim_node thread anim_single_solo( fail_player_rig, "exfil_fail" );

		level.player PlayerLinkToBlend( fail_player_rig, "tag_player", blendtime );
		
		level.player notify( "notify_player_animated_sequence_restrictions" );
		
		wait( blendtime );
		
		fail_player_rig Show();
		
		//player did not get to rope.
		
		level waittill( "notify_player_hit_ice" );
		
		// Black overlay
		black_overlay = maps\_hud_util::create_client_overlay( "black", 0, level.player );
		black_overlay FadeOverTime( 0.01 );
		black_overlay.alpha = 1;
		//black_overlay.sort = 3;
		black_overlay.foreground = false;
		
		//kill player
		//level.player Kill();
		
		wait( 2.5 );
		
		SetDvar( "ui_deadquote", "Jump to ladder to escape rig" );
		thread MissionFailedWrapper();
	   	
	}
	else if( flag("flag_ladder_jumpfail_nojump" ))
	{
		//player was too far from allies when time to jump
		SetDvar( "ui_deadquote", "Sprint to helo to escape rig" );		
		player_fail_rigexplode();
	}
	else
	{
		//player made jump to ladder
		autosave_by_name( "exfil_end" );          //save
		level notify( "player_ladder_success" );  //notify success
		flag_set( "flag_teleport_rig" );		  //allow the scene to teleport
		
		//view smoke fx that make cool thick smoke and mask the teleport
		thread maps\black_ice_fx::exfil_player_view_smoke_particles();
		
		//shakey cam and rumble when player is swinging out
		thread player_view_shake();
		
		thread player_unhide_arms_with_notetrack();

		//blend player into vignette, make sure the blend ends before the player teleports
		blendtime = get_blendtime_from_notetrack( level.player_rig, level.scr_anim [ "player_rig" ][ "ladder_chase" ], "end_blend", 1.0  );
		
		//IPrintLnBold( blendtime );

		level.player PlayerLinkToBlend( level.player_rig, "tag_player", blendtime );
		
		level.player notify( "notify_player_animated_sequence_restrictions" );
		
		wait( blendtime );		

		playerlegs show();
		
		AmbientPlay( "ambient_blackice_outside_lr", 2 );	
		
		level waittill( "notify_flyout_fade_to_black" );

		black_overlay = maps\_hud_util::create_client_overlay( "black", 0, level.player );
		black_overlay FadeOverTime( 1.6 );
		black_overlay.alpha = 1;
		//black_overlay.sort = 3;
		black_overlay.foreground = false;
		
		wait( 2.5 );
		
		nextmission();
			
	}
}


section_flag_inits()
{
	flag_init( "flag_stop_fire_tower_sfx_logic" );	
	//flag_init( "flag_exfil_hint_off" );	
	flag_init( "flag_exfil_end" );
	flag_init( "flag_ladder_jump" );
	flag_init( "flag_ladder_autojump" );
	flag_init( "flag_ladder_jumpfail_nojump" );
	flag_init( "flag_ladder_jumpcheck" );
	flag_init( "flag_helo_swing" );
	flag_init( "flag_baker_steam_react" );
	flag_init( "flag_ladder_chase" );
	flag_init( "flag_teleport_rig" );
	flag_init( "flag_command_pipes_explosion" );
	flag_init( "flag_player_dying_on_rig" );
	flag_init( "flag_kick_player_to_death" );
	flag_init( "flag_jumped_too_late" );
}

section_precache()
{	
	PrecacheItem( "freerunner" );
	//add_hint_string( "hint_exfil", &"BLACK_ICE_EXFIL_GRAB_LADDER", ::hint_exfil );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_post_inits()
{
	level._exfil = SpawnStruct();
	
	level.jump_distance_allowed = true;
		
	// Setup the derrick to first frame
	level._exfil.struct = GetStruct( "struct_exfil", "targetname" );	
	
	if( IsDefined( level._exfil.struct ))
	{
		level._exfil.door = setup_door( "model_exfil_door", "bulkhead_door", "jnt_door" );
	}
	else
	{
		iprintln( SCRIPT_NAME + ": Warning - Exfil struct missing (compiled out?)" );
	}
}
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//hint_exfil()
//{	
//	return flag( "flag_exfil_hint_off" );
//}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//setup_siren_light()
//{
//	
//	//wait for runout cause the light bleeds into the command center
//	trigger_wait_targetname( "trig_exfil_light_burst" );
//	
//	light = GetEnt( "exfil_siren_light_red", "targetname" );
//	
//	maps\black_ice_fx::Link_siren_fx( light, "TAG_fx_main", level._effect[ "exfil_siren_red" ] );
//	maps\black_ice_fx::Link_siren_fx( light, "TAG_fx_back", level._effect[ "exfil_siren_yellow_cheap" ] );
//	
//	light RotateVelocity( (0,320,0 ), 600 );
//		
//}


dialog_main()
{
	
	trigger_wait_targetname( "trig_exfil_dialog_radiobravo" );
	dialog_radiobravo();
	
	trigger_wait_targetname( "trig_exfil_dialog_seehelo" );
	dialog_seehelo();
	
	level waittill ( "notify_exfil_dialog_1");
	dialog_explode();
	
	level waittill ( "notify_exfil_dialog_2");
	//dialog_jump();
	
}

dialog_radiobravo()
{
	
	smart_radio_dialogue( "black_ice_bkr_bravowereheadingto" );
	
	wait 0.1;
	
	smart_radio_dialogue( "black_ice_diz_copywellgetas" );
	
}

dialog_seehelo()
{
	
	smart_radio_dialogue( "black_ice_bkr_theretheyaremove" );
	
}

dialog_explode()
{
	
	smart_radio_dialogue( "black_ice_bkr_shitbravo" );
	
	//wait( 0.1 );
	
	//thread smart_radio_dialogue( "black_ice_diz_werelosinglifti" );
	
	wait( 1.3 );
	
	smart_radio_dialogue( "black_ice_bkr_gogogowe" );
	
}

dialog_jump()
{
	smart_radio_dialogue( "black_ice_bkr_jump" );	
}


exfil_slomo()
{
	level waittill ( "notify_exfil_start_slomo" );
	//IPrintLnBold( "slomo!" );
	SetSlowMotion( 1.0, 0.5, 3.0 );
	
	level waittill ( "notify_exfil_end_slomo" );
	
	SetSlowMotion( 0.5, 1.0, 3.0 );
}

//show_legs( playerlegs )
//{
//	playerlegs show();
//}


ladder_chase_explosion_fx()
{
	//test_viewmodel_anim( "cam_test" );

	exploder( "exfil_vignette_explosion" );
	
	//AUDIO: distant explosion sfx
	thread maps\black_ice_audio::sfx_blackice_engine_dist_explo();

	
	wait( 3.0 );
	exploder( "exfil_vignette_explosion_perif_c" );
	Earthquake( 0.3, 1, level.player.origin, 3000 );
	
	wait( 0.8 );
	exploder( "exfil_vignette_explosion_perif_d" );
	Earthquake( 0.2, 1, level.player.origin, 3000 );
	
}

player_explosion_reaction()
{
	//get dist from source
	explosion_source = GetStruct( "struct_exfil_explosion_damage", "targetname" );
	explosion_distance = Distance( level.player.origin, explosion_source.origin );
	
	//IPrintLnBold( explosion_distance );
	
	player_speed_reaction_distance( 750, 1100, explosion_distance );
	player_viewkick_distance( explosion_source, 30, 750, 1200, explosion_distance );
	player_quake_distance( 0.7, 0.8, 750, 1300, explosion_distance );
	player_quake_distance( 0.3, 3.0, 750, 1300, explosion_distance );
	player_rumble_distance( explosion_distance, "grenade_rumble", 850, "damage_light", 1200 );
	player_push_distance( ( 1, 0, 0 ), 200, 0.35, 750, 1100, explosion_distance );
	
	if( explosion_distance < 1000  )
	{
		level.player ShellShock( "blackice_nosound", 3.0);
		level.player AllowSprint( false );
		level.player DisableWeapons();
		level.player HideViewModel( );
		level.player DisableOffhandWeapons();
		level.player DisableWeaponSwitch();
	}
	
}

player_pipe_explosion_reaction()
{
	//get dist from source
	explosion_source = GetStruct( "struct_exfil_pipe_explosion", "targetname" );
	explosion_distance = Distance( level.player.origin, explosion_source.origin );
	
	//IPrintLnBold( explosion_distance );
	
	//player_speed_reaction_distance( 750, 1100, explosion_distance );
	player_viewkick_distance( explosion_source, 15, 650, 900, explosion_distance );
	player_quake_distance( 0.4, 0.8, 650, 900, explosion_distance );
	player_quake_distance( 0.15, 3.0, 650, 900, explosion_distance );
	player_rumble_distance( explosion_distance, "grenade_rumble", 800, "damage_light", 1000 );
	//player_push_distance( ( -1, 0, 0 ), 100, 0.35, 650, 900, explosion_distance );
	
	
}

player_speed_reaction_distance( min_dist, max_dist, dist )
{
	
	stun_factor = maps\black_ice_util::normalize_value( min_dist, max_dist, dist );
	
	//player speed reacts to explosion
	thread player_stunned_speed_blender( stun_factor );
}

player_quake_distance( max_scale, duration, min_dist, max_dist, dist )
{
	if( dist < max_dist )
	{
		scale_factor = maps\black_ice_util::normalize_value( min_dist, max_dist, dist );
		
		scale = maps\black_ice_util::factor_value_min_max( max_scale, 0, scale_factor );
		
		Earthquake( scale, duration, level.player.origin, 3000 );
	}
}

player_viewkick_distance( kick_source, max_kick_strength, min_dist, max_dist, dist )
{
	if( dist < max_dist )
	{
		strength_factor = maps\black_ice_util::normalize_value( min_dist, max_dist, dist );
		
		strength = int( maps\black_ice_util::factor_value_min_max( max_kick_strength, 0, strength_factor ));
		
		level.player viewkick( strength, kick_source.origin );
	}
}

player_rumble_distance( dist, rumble1, max_dist1, rumble2, max_dist2 )
{
	if ( dist < max_dist1 )
		level.player PlayRumbleOnEntity( rumble1 );
	else if( dist < max_dist2  )
		level.player PlayRumbleOnEntity( rumble2 );
}

player_push_distance( dir, max_mag, time, min_dist, max_dist, dist )
{
	if( dist < max_dist )
	{
		mag_factor = maps\black_ice_util::normalize_value( min_dist, max_dist, dist );
		
		mag = maps\black_ice_util::factor_value_min_max( max_mag, 0, mag_factor );	
		
		thread maps\black_ice_util::push_player_impulse( dir, mag, time );
	}
}


player_unhide_arms_with_notetrack()
{
	
	level waittill( "notify_player_unhide_arms" );
	
	level.player_rig Show();
		
}

player_view_shake()
{
	in_time = 1.0;
	swing_In_time = 0.5;
	swing_hold_time = 0.5;
	swing_out_time = 3.5;
	fall_strength = 0.15;
	swing_strength = 0.22;
	end_strengh = 0.07;
	
	//init
	maps\black_ice_util::player_view_shake_blender( in_time, 0.02, fall_strength );
	//hold
	while( !flag( "flag_helo_swing" ) )
	{
		//IPrintLn("quake = " + fall_strength );
		earthquake( fall_strength, 0.2, level.player.origin, 100000.00 );
		wait( level.TIMESTEP );
	}
	//swing_in
	maps\black_ice_util::player_view_shake_blender( swing_in_time, fall_strength, swing_strength );
	//swing_hold
	maps\black_ice_util::player_view_shake_blender( swing_hold_time, swing_strength, swing_strength );
	//swing_out
	maps\black_ice_util::player_view_shake_blender( swing_out_time, swing_strength, end_strengh );
	//ending flyout
	while( 1 )
	{
		earthquake( end_strengh, 0.2, level.player.origin, 100000.00 );
		wait( level.TIMESTEP );
	}
}


exfil_teleport( rig )
{	
	level endon( "notify_exfil_fail" );
	
	Assert( IsDefined( rig ));
	
	struct = GetStruct( "struct_exfil_teleport", "targetname" );
	Assert( IsDefined( struct ));
	
	// Move scene to new position to animate rig
	level waittill( "notify_exfil_player_teleport" );
	exploder ( "flyout_water_fx" );
	
	//only teleport if the player has grabbed the rope successfully
	if( flag( "flag_teleport_rig" ))
	{
	self.origin = struct.origin;
	self.angles = struct.angles;	
	wait( 0.05 );
	rig Show();
}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
exfil_deck_explosions()
{
	
	trigger_wait_targetname( "trig_exfil_explode_1" );
	level.player PlaySound( "scn_blackice_exfil_explo04" );
	exploder( "exfil_vignette_explosion_perif_a" );
	Earthquake( 0.3, 1, level.player.origin, 3000 );
		
	trigger_wait_targetname( "trig_exfil_explode_2" );
	exploder( "exfil_vignette_explosion_perif_b" );
	Earthquake( 0.3, 1, level.player.origin, 3000 );
	
	wait( 1.2 );
	exploder( "exfil_vignette_explosion_perif_e" );
	Earthquake( 0.3, 1, level.player.origin, 3000 );
	
}

exfil_random_quaker()
{
	
	min_quake = 0.05;
	max_quake = 0.26;
	min_duration = 0.7;
	max_duration = 1.3;
	min_time = 0.3;
	max_time = 1.3;

	
	
	while( !flag( "flag_ladder_jump" ))
	{
		quake = RandomFloatRange( min_quake, max_quake );
		time = RandomFloatRange( min_time, max_time );
		duration = RandomFloatRange( min_duration, max_duration );
		Earthquake( quake, duration, level.player.origin, 3000 );
		wait( time );
	}
	
}

exfil_hall_explosions()
{
	trigger_wait_targetname( "trig_command_quake_1" );
	//maps\black_ice_util::quake( "scn_blackice_tanks_dist_explo" );
	Earthquake( 0.4, 1, level.player.origin, 3000 );
	trigger_wait_targetname( "trig_command_quake_2" );
	level.player PlaySound( "scn_blackice_exfil_explo02" );
	//maps\black_ice_util::quake( "scn_blackice_tanks_dist_explo" );
	Earthquake( 0.5, 1.8, level.player.origin, 3000 );
	wait 1.3;
	exploder( "exfil_light_1" );
	wait 1.0;
	exploder( "exfil_light_2" );
	level.player PlaySound( "scn_blackice_exfil_explo03" );

	
}

exfil_light_burst()
{
	thread maps\black_ice_anim::runout_group1();
	thread maps\black_ice_anim::runout_group2();
	light = GetEnt( "escape_emergency_1", "targetname" );
	
	light SetLightIntensity( 1.6 );
	
	trigger_wait_targetname( "trig_exfil_light_burst" );
	exploder( "exfil_light_3" );
	level.player PlaySound( "scn_blackice_exfil_explo01" );
	
	earthquake( 0.3, 1.1, level.player.origin, 2000 );
	
	//light SetLightIntensity( 1.4 );
	light SetLightIntensity( 2 );
	
	light flicker( 0.9, 0.5 );
	
}

exfil_steam_burst()
{
	thread maps\black_ice_anim::runout_group3();
	level waittill( "notify_exfil_steam_burst" );
	
	earthquake( 0.35, 1.3, level.player.origin, 2000 );
	
	exploder("exfil_steam_burst");
	stop_exploder( "fx_command_interior" );
	
}

exfil_hall_light_flicker()
{
	
	lights = GetEntarray( "escape_emergency_3", "targetname" );
	
	foreach( light in lights )
	{
		light SetLightIntensity( 1.5 );
		light thread flicker( 0.9, 0.5 );
	}
}

exfil_engine_fires()
{
	
	exploder( "exfil_hall_ambfx" );
	exploder( "exfil_engine_fire" );
	
}


exfil_yellow_alarms()
{
	
	//exploder( "exfil_wall_alarm_yellow" );
	
//	while( 1 )
//	{
//		exploder( "exfil_wall_alarm_yellow" );
//		wait( 0.25 );
//		exploder( "exfil_wall_alarm_yellow" );
//		wait( 0.6 );
//	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_sprint()
{
	//level.player TakeAllWeapons();
	//level.player GiveWeapon( "freerunner" );
	//level.player SwitchToWeapon( "freerunner" );
	setSavedDvar( "player_sprintUnlimited", "1" );
	player_speed_percent( 90, 1 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ally_sprint()
{			
	//iprintln( "rubberduckie" );
	array_thread( level._allies, ::ally_sprint_setup );
	
	level._allies[ 1 ] thread ally_rubber_banding_solo( level._allies[ 0 ] );
	level._allies[ 0 ] thread ally_rubber_banding_solo( level.player );
	level.player player_rubber_banding_solo( level._allies[ 0 ] );
	
	level waittill( "notify_stop_rubber_banding" );
	
	array_thread( level._allies, ::ally_sprint_end );
}

ally_sprint_setup()
{	
	self disable_cqbwalk();	
	self.disablearrivals = true;
	self.disableexits = true;
	self.usechokepoints = false;
	self enable_sprint();
	
	self ignore_everything();	
	
	self set_run_anim( "DRS_sprint" );
}

ally_sprint_end()
{
	self.disablearrivals = false;
	self.disableexits = false;
	self.usechokepoints = true;
	self disable_sprint();
	
	self unignore_everything();
	
	self clear_run_anim();
}

exfil_anims_cornering( struct1, struct2, guys, i )
{
	if(( i == 0  ) && ( level.start_point != "exfil"  ))
		guys[ i ] waittill( "notify_command_end_done" );
	
	//reach and play first corner cutting animation
	struct1 anim_reach_solo( guys[i], "exfil_corner_cut" );
	struct1 anim_single_solo( guys[i], "exfil_corner_cut", undefined, 0.1 );
	
	//reach and play second steam react anim
	struct1 anim_reach_solo( guys[i], "exfil_steam_react" );
	//stop the old AI run rubberbanding
	level notify( "notify_stop_rubber_banding" );
	//que rubberbanding and play steam_react anim
	if( i == 0 )
	{
		//near ally should rubberband with distance from player.  Note that near anim ends a little sooner.  This is to aid in blending with the next anim.
		thread rubberband_near_ally_steam_reaction_runout( guys, i );
		struct1 anim_single_solo( guys[i], "exfil_steam_react" );
	}
	else
	{
		//door for far ally to open
		//shoulder_door = spawn_anim_model( "bulkhead_door" );		
		
		//far ally should rubberband with near ally.  Distance apart is irrelevnt, but timers should sync up
		thread rubberband_far_ally_steam_reaction_runout( guys );
		struct1 thread anim_single_solo( guys[i], "exfil_steam_react" );
		//door that the guy shoulders
		struct1 anim_single_solo( level._exfil.door, "shoulder_door" );
	}
}

rubberband_near_ally_steam_reaction_runout( guys, i )
{
	
	flag_set( "flag_baker_steam_react" );
	
	min_player_dist = 80;
	ideal_player_dist = 180;
	max_player_dist = 320;
	
	fail_dist = 625;
	
	ally_max_rate = 1.1;
	ally_min_rate = 0.8;
	
	player_max_speed = 210;
	player_speed = 180;
	player_min_speed = 110;
	
	dist = 0;
	
	while ( !flag( "flag_ladder_chase" ))
	{
		//get the distance from near ally to far ally
		dist_ally_to_ally = Distance( guys[0].origin, guys[1].origin );
		//get the distance from the player to the near ally
		dist_player_to_ally = Distance( level.player.origin, guys[1].origin );
		
		dist = ( dist_player_to_ally -  dist_ally_to_ally );
		
		//IPrintLn( "dist =" + dist  );
		
		if( dist > ideal_player_dist )
		{
			//player needs to speed up, scene needs to slow down
			rubberband_factor = maps\black_ice_util::normalize_value( ideal_player_dist, max_player_dist, dist );
		
			player_rubberband_speed = maps\black_ice_util::factor_value_min_max( player_speed, player_max_speed, rubberband_factor );
			ally_rubberband_rate = maps\black_ice_util::factor_value_min_max( 1, ally_min_rate, rubberband_factor );
			//IPrintLn( "dist =" + dist  );
		}
		else
		{
			//player needs to slow down, scene needs to speed up
			rubberband_factor = maps\black_ice_util::normalize_value( min_player_dist, ideal_player_dist, dist );
		
			player_rubberband_speed = maps\black_ice_util::factor_value_min_max( player_min_speed, player_speed, rubberband_factor );
			ally_rubberband_rate = maps\black_ice_util::factor_value_min_max( ally_max_rate, 1, rubberband_factor );
		}
		//IPrintLn( "dist =" + dist + "speed and rate = " + player_rubberband_speed  +  ally_rubberband_rate );
		SetSavedDvar ( "g_speed", player_rubberband_speed);
		anim_set_rate_single( guys[ 0 ] ,  "exfil_steam_react", ally_rubberband_rate );
		
		if( dist > fail_dist  )
		{
			SetDvar( "ui_deadquote", "sprint to escape command center" );
			player_fail_rigexplode();
		}
		
		wait( level.TIMESTEP );
	}
			
	
}

rubberband_far_ally_steam_reaction_runout( guys )
{
	
	wait( 0.1 );
	
	//amount the anim for the far ally will be advanced forward or back to match near ally	
	anim_rubberband_delta = 0.005;
	
	//wait for baker to start his anim cause it needs to sample that one to work
	flag_wait( "flag_baker_steam_react"  );
	
	//rubberbanding.  Baker should react to the players position, and the other allie should sync his timer up with baker over the course of the anim
	while ( !flag( "flag_ladder_chase" ))
	{
		ally1_animtime = guys[0] getanimtime( level.scr_anim[ "ally1" ][ "exfil_steam_react" ] );
		ally2_animtime = guys[1] getanimtime( level.scr_anim[ "ally2" ][ "exfil_steam_react" ] );
	
		//get the absolue different in time (% through animation) between the 2 allies
		delta = abs( ally2_animtime - ally1_animtime );
		//iprintln( "ally = " + ally2_animtime );
		//iprintln( "delta = " + delta );
		//if that time is greater than the anim_rubberband_delta, we need to adjust the time of the ally to get closer to bakers time
		if( delta > anim_rubberband_delta )
		{
			//is ally ahead of baker? (% through anim)
			if ( ally2_animtime > ally1_animtime )
			{
				ally2_animtime = ally2_animtime - anim_rubberband_delta;
			}
			//bakers % is ahead of allys
			else
			{
				ally2_animtime = ally2_animtime + anim_rubberband_delta;
			}
			//iprintln( "ally new= " + ally2_animtime );
		}
		//if that time is less than the anim_rubberband_delta, just explicitly make they allies time the same as bakers
		else
		{
			ally2_animtime = ally1_animtime;	
		}
		
		//set animtime for baker
		guys[ 1 ] setanimtime( level.scr_anim[ "ally2" ][ "exfil_steam_react" ], ally2_animtime );
		
		//also set animtime for door
		level._exfil.door setanimtime( level.scr_anim[ "bulkhead_door" ][ "shoulder_door" ], ally2_animtime );
		
		wait( level.TIMESTEP );
	}
}

ally_rubber_banding_solo( guy )
{
	level endon( "notify_stop_rubber_banding" );	
			
	// Set highest / lowest allowed speeds
	low_speed = 0.8;
	high_speed = 2.0;
	
	// Max distance before lowest speed
	max_distance = 384;
	
	while( 1 )
	{
		dist = Distance( self.origin, guy.origin );	

		if( dist > max_distance )
			dist = max_distance;		
		else if( dist < 0 )
			dist = 0;

		// Find and set playback rate scaled based on distance
		rate = dist / max_distance;		
		playbackrate = high_speed - ((high_speed - low_speed ) * rate);		
		
		self.moveplaybackrate = playbackrate;
		
		// Cap the rate so the ally doesn't look ludicrous when moving away from the player at the start
		if( self.moveplaybackrate > 1.2 )
			self.moveplaybackrate = 1.2;	
		
		wait( 0.05 );
	}
	
}

player_rubber_banding_solo( guy )
{
	level endon( "notify_stop_rubber_banding" );	
			
	// Set highest / lowest allowed speeds( defaults 189 )

	low_speed = 210;
	high_speed = 110;
	
	// Max distance before lowest speed
	max_distance = 384;	
	
	// Fail distance
	death_distance = 650;
	
	while( 1 )
	{
		dist = Distance( self.origin, guy.origin );	
				
		//IPrintLn( "solodist = " + dist  );
				
		if( dist > death_distance )
		{
		//TAG CP If this break is commented out, I checked in some debug stuff and I am stupid.
			SetDvar( "ui_deadquote", "Follow your allies and escape the oil rig" );
			thread player_fail_rigexplode();
			//check = 12;		
		}
		else if( dist > max_distance )
			dist = max_distance;		
		else if( dist < 0 )
			dist = 0;

		// Find and set playback rate scaled based on distance
		rate = dist / max_distance;				
		player_rubberband_speed = high_speed - ((high_speed - low_speed ) * rate);
		
		//adjust player speed
		SetSavedDvar ( "g_speed", player_rubberband_speed);
		
		wait( 0.05 );
	}
	//level notify( "notify_stop_rubber_banding" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

exfil_heli( struct )
{
	trigger_wait_targetname( "trig_exfil_heli_start" );	
	
	exploder ( "pipedeck_exfil_fx" );
	thread fires();
	
	heli = spawn_anim_model( "exfil_helo" );
	level.heli = heli;
	ladder = spawn_anim_model( "exfil_ladder" );
	
	thread exfil_heli_spotlight();
	
	level._exfil_heli = [ heli, ladder ];
	
	//AUDIO: playing exfil helicopter sfx
	thread maps\black_ice_audio::sfx_blackice_exfil_heli();
	
	//FX: turn on heli's blinking lights
	thread maps\black_ice_fx::exfil_blackice_exfil_heli_lights_fx();
	
	// Heli idles
	struct thread anim_single( level._exfil_heli, "idle" );	
	
	//smoke the helo falls into
	exploder( "pipedeck_giant_smoke_for_exfil" );
	maps\black_ice_fx::exfil_heli_smoke_fx_01();
}

exfil_heli_spotlight()
{

	//level waittill( "notify_helo_spotlight_on" );
	
	PlayFxOnTag( level._effect[ "heli_spotlight_bright" ], level.heli, "tag_flash" );
	wait(  level.TIMESTEP );
	PlayFxOnTag( level._effect[ "heli_spotlight" ], level.heli, "tag_flash" );
	//level.heli thread maps\black_ice_pipe_deck::heli_spotlight_noise( 3.2 );
	
	level waittill( "notify_helo_spotlight_off" );
	
	PlayFxOnTag( level._effect[ "exfil_helospotlight_explode" ], level.heli, "tag_flash" );
	wait(  level.TIMESTEP );
	stopFxOnTag( level._effect[ "heli_spotlight_bright" ], level.heli, "tag_flash" );
	wait(  level.TIMESTEP );
	stopFxOnTag( level._effect[ "heli_spotlight" ], level.heli, "tag_flash" );
	
//	wait( 0.1 );
//	
////	//damaged spotlight will flicker off
//	flickerwaitmax = 0.1;
//	flickerwaitmin = 0.05;
//	counter = 6;
//	while( counter > 0 )
//	{
//		
//		IPrintLn( "on" );
//		
//		PlayFxOnTag( level._effect[ "heli_spotlight" ], level.heli, "tag_flash" );
//		//PlayFxOnTag( level._effect[ "heli_spotlight_bright" ], level.heli, "tag_flash" );
//		
//		//wait( RandomFloatRange( flickerwaitmin, flickerwaitmax ) );
//		wait( 0.2 );
//		
//		IPrintLn( "off" );
//		
//		stopFxOnTag( level._effect[ "heli_spotlight" ], level.heli, "tag_flash" );
//		//stopFxOnTag( level._effect[ "heli_spotlight_bright" ], level.heli, "tag_flash" );
//		
//		//wait( RandomFloatRange( flickerwaitmin, flickerwaitmax ) );
//		wait( 0.2 );
//		
//		
//		
//		counter -= 1;
//	}
//	
//	stopFxOnTag( level._effect[ "heli_spotlight" ], level.heli, "tag_flash" );
//	//stopFxOnTag( level._effect[ "heli_spotlight_bright" ], level.heli, "tag_flash" );


}


fires()
{
	// temp fires on ground for exfil (burning exploders and nodes, yay!)
	
	fires = [ "exfil_fire" ];
	
	structs = GetStructArray( "struct_exfil_fires", "targetname" );
	
	foreach( struct in structs )
	{
		PlayFX( GetFX( random( fires )), (struct.origin + (0,0,-200)) );
	}	
}

//player_grab_ladder()
//{	
//	// Distance to allow grab
//	distance = 200;
//	
//	// Timeout
//	timer_max = 5;
//	
//	timer = 0;
//	distance *= distance;	
//	hint_active = false;
//	
//	while( 1 )
//	{				
//		flag_clear( "flag_exfil_hint_off" );
//		
//		// Failed!
//		if( timer >= timer_max )
//		{
//			thread MissionFailedWrapper();
//			return false;
//		}
//		
//		// Check distance for hint
//		if( DistanceSquared( level._allies[ 1 ].origin, level.player.origin ) <= distance )
//		{
//			if( !hint_active )
//			{
//				display_hint( "hint_exfil" );
//				hint_active = true;
//			}
//			
//			if( level.player UseButtonPressed())
//				break;
//		}
//		else
//		{
//			flag_set( "flag_exfil_hint_off" );
//			hint_active = false;
//		}					
//		
//		wait( 0.05 );
//		timer += 0.05;
//	}
//	
//	// Make sure hint is off
//	flag_set( "flag_exfil_hint_off" );	
//	
//	return true;
//}

//
//
//


rubberband_ladder_chase( guys )
{
	level endon( "notify_exfil_fail" );

	//if player is further than this, he can not jump onto the rig
	fail_distance = 100000;
	
	//max_speed = 220.0;
	//min_speed = 100.0;
	max_dist = 60000.0;
	min_dist = -90000.0;
	max_rate = 0.8;
	min_rate = 1.2;
	
	//init for debugging
	dist_from_target = 0.0;
	target_dist = 0.0;
	player_dist = 0.0;
	player_rubberband_speed = 0.0;
	
	while ( !flag( "flag_ladder_jump" ) && !flag( "flag_ladder_autojump" ) && !flag( "flag_ladder_jumpfail_nojump" ) )
	{	
		
		//min and max speeds are set dynamically during explosion event
		max_speed = level.player_max_speed;
		min_speed = level.player_min_speed;
		
		//IPrintLn( "minspeed = " + min_speed + "maxspeed = " + max_speed );
		
		target_dist = DistanceSquared( level.player_rig.origin, level._allies[ 1 ].origin );
		player_dist = DistanceSquared( level.player GetEye(), level._allies[ 1 ].origin );
		dist_from_target = player_dist - target_dist;

		rubberband_factor = maps\black_ice_util::normalize_value( min_dist, max_dist, dist_from_target );
		
		player_rubberband_speed = maps\black_ice_util::factor_value_min_max( min_speed, max_speed, rubberband_factor );
		scene_rubberband_rate = maps\black_ice_util::factor_value_min_max( min_rate, max_rate, rubberband_factor );
		
		//adjust player speed
		SetSavedDvar ( "g_speed", player_rubberband_speed);
		
		//adjust scene speed	
		anim_set_rate( guys, "ladder_chase", scene_rubberband_rate );
		
		//IPrintLn("dist = " + dist_from_target );
			
		//boadcast distance check
		if( dist_from_target < fail_distance )
			level.jump_distance_allowed = true;
		else
			level.jump_distance_allowed = false;

		wait level.TIMESTEP;
	}
	
	//return speeds to 1
	anim_set_rate( guys, "ladder_chase", 1 );
	
	return dist_from_target;
	
}

player_dropgun_before_jump()
{
	
	level waittill( "flag_player_drop_gun" );
	
	level.player.disableReload = true;
	level.player GiveWeapon( "freerunner" );
	level.player switchtoWeapon( "freerunner");
	level.player disableWeaponSwitch();

	//level.player AllowSprint( true );
	
}


test_viewmodel_anim( anime )
{
	
	//create player rig and link to view
	player_arms = spawn_anim_model( "player_rig" );
	player_arms LinkToPlayerView( level.player, "tag_origin", (0,0,0), (0,0,0), true );
	
	//create tag_origin and assign animtree
	camera_mover = spawn_tag_origin();
	camera_mover assign_animtree( anime );
		
	//set cam mover as ground ref to influence player vie
	level.player PlayerSetGroundReferenceEnt( camera_mover );

	//play anims...assuming they are the same length
	player_arms thread anim_single_solo( player_arms, anime );
	camera_mover anim_single_solo( camera_mover, anime );
		
	//clean up.  Set world as ref, and delete camera
	level.player PlayerSetGroundReferenceEnt( undefined );
	camera_mover delete();
	player_arms delete();
	
}

ladder_player_jumpcheck()
{	
	
	level endon( "flag_player_dying_on_rig" );
	
	jump_pressed = false;
	jump_held = false;
	
	//absolute worse hardcoded value ever...should move to a sruct test
	fakegroundheight = 2576;
	heightoffground = 0;
	
	//setup jump anims, arms linked to player view
	player_jump_arms = spawn_anim_model( "player_rig" );
	player_jump_arms LinkToPlayerView( level.player, "tag_origin", (0,0,0), (0,0,0), true );
	player_jump_arms anim_first_frame_solo( player_jump_arms, "jump_arms" );
	level.jumparms = player_jump_arms;
	//IPrintLnBold( "spawn" );
	
	cam_shake = spawn_anim_model( "cam_shake" );
	cam_shake.origin = level.player.origin;
	cam_shake.angles = level.player.angles;
	cam_shake linkto( level.player );
	
	while ( !flag( "flag_ladder_jump" ))
	{	
				
		//check to see if player is holding button or if he just pressed it..
		if ( level.player JumpButtonPressed() )
		{
			if( jump_pressed  )
				jump_held = true;
			else
				jump_pressed = true;
		}
		else
		{
			if ( jump_held )
			jump_held = false;
			if ( jump_pressed )
				jump_pressed = false;
		}
			
		//following conditions need to be met for a successful "jump":
		//--within the volume( flag_ladder_jumpcheck )
		//--approximatly on the ground
		//--player pressed the button
		//--but the button was not held
		if (  (flag( "flag_ladder_jumpcheck" ) && ( heightoffground < 10 ) && ( jump_pressed ) && ( !jump_held )) || ( flag( "flag_ladder_autojump" )))
		{
			
			flag_set( "flag_ladder_jump" );
			cam_shake unlink();
			level.player PlayerSetGroundReferenceEnt( cam_shake );
			level.player PlayRumbleOnEntity( "pistol_fire" );
			
			if( level.jump_distance_allowed == true )
			{
				//play outro sfx
				thread maps\black_ice_audio::sfx_exfil_outro();
				
				//play successful jump anim
				cam_shake thread anim_single_solo( cam_shake, "jump_shake" );
				player_jump_arms anim_single_solo( player_jump_arms, "jump_arms" );
			}
			else
			{
				//play unsuccessful jump anim
//				cam_shake thread anim_single_solo( cam_shake, "jump_shake_fail" );
//				player_jump_arms anim_single_solo( player_jump_arms, "jump_arms_fail" );
			}
			
			player_jump_arms delete();
		}

		//determine the approx players height off the ground. doing this after the check so the check is actually using last frames height.  evedently there is a frame lag on "jumpbuttonpressed()"
		heightoffground = level.player.origin[2] - fakegroundheight;
		
		wait level.TIMESTEP;
	}
}

player_heat_fx()
{
	//heat warble
	particle_source = spawn( "script_model", ( 0, 0, 0 ) );
	particle_source setmodel( "tag_origin" );
	
	particle_source.origin = level.player.origin;
	
	particle_source LinkToPlayerView( level.player, "tag_origin", (0,0,0), (0,0,0), true );
	fx_on = false;
	
	level waittill( "flag_vision_exfil_deck" );
	
	while( 1 )
	{
		if  (flag( "flag_vision_exfil_deck") )
		{
			if ( fx_on != true )
			{
				player_heat_fx_start( particle_source );
				fx_on = true;
			}
			earthquake( 0.05, 0.2, level.player.origin, 128 );
			//IPrintLn ( "vision flag on!" );
		}
		else 
			if ( fx_on == true )
			{
				player_heat_fx_end( particle_source );
				fx_on = false;
			}
		
		wait( level.TIMESTEP);
	}
}

player_heat_fx_start( particle_source )
{
	//PlayFXOnTag(  GetFX( "pipedeck_heat_haze3" ), particle_source, "tag_origin" );
	maps\_art::dof_enable_script( 0, 0, 4, 0, 777, 1.49, 0 );
	level.player SetViewModelDepthOfField( 0.0, 13.26 );
}

player_heat_fx_end( particle_source )
{
	//StopFXOnTag(  GetFX( "pipedeck_heat_haze3" ), particle_source, "tag_origin" );
	maps\_art::dof_disable_script( 0 );
	level.player SetViewModelDepthOfField( 0.0, 0.0 );
}

player_stunned_speed_blender( stun_factor )
{
	//player min and max speeds(used in rubberbanding) will start off slower as the player reacts to the explosion, and slowly ramp up as the stun fx wear off.
	//player "normal" rubberband speeds during the ladder chase
	player_max_speed = 220;
	player_min_speed = 100;
	
	//player rubberbanded speeds while stunned by explosion that starts the ladder chase
	player_min_max_stun_speed = 80;
	player_min_min_stun_speed = 20;
	player_max_max_stun_speed = 180;
	player_max_min_stun_speed = 50;
	
	//time in and out to blend player speed
	stun_time_in = 1.0;
	stun_hold_time = 1.2;
	stun_time_out = 4.0;
	
	current_speed = GetDvarFloat( "g_speed" );
	
	//factor player stun speed based on distance from explosion
	player_min_stun_speed = maps\black_ice_util::factor_value_min_max( player_min_min_stun_speed, player_max_min_stun_speed, stun_factor );
	player_max_stun_speed = maps\black_ice_util::factor_value_min_max( player_min_max_stun_speed, player_max_max_stun_speed, stun_factor );
	
	//slow down player
	player_lerp_speed( current_speed, current_speed, player_min_stun_speed, player_max_stun_speed, stun_time_in );
	
	wait ( stun_hold_time );
	
	//give back weapons and sprint to player
	thread player_stun_return_weapons_sprint( 0.0 );
	
	//speed player back up
	player_lerp_speed( player_min_stun_speed, player_max_stun_speed, player_min_speed, player_max_speed, stun_time_out );
	
	
}

player_stun_return_weapons_sprint( waittime )
{
	wait( waittime );
	level.player ShowViewModel( );
	level.player AllowSprint( true );
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player EnableWeaponSwitch();
}

player_lerp_speed( current_min, current_max, target_min, target_max, time )
	
{
	
	current_time = time;
	
	while ( 1 )
	{
		//IPrintLn("--");
		time_factor = maps\black_ice_util::normalize_value( 0, time, current_time );
		
		min_speed = maps\black_ice_util::factor_value_min_max( target_min, current_min, time_factor );
		max_speed = maps\black_ice_util::factor_value_min_max( target_max, current_max, time_factor );
		
		level.player_min_speed = min_speed;
		level.player_max_speed = max_speed;
		
		//IPrintLn("min = " + level.player_min_speed);
		//IPrintLn("max = " + level.player_max_speed);
		
		wait( level.TIMESTEP );
		current_time -= level.TIMESTEP;
		
		if ( current_time < 0  )
			break;
	}
	
	level.player_min_speed = target_min;
	level.player_max_speed = target_max;
	
}

player_fail_rigexplode()
{
	
	//set this flag to null other attempts to link things to view.  if its set this script is already running.
	if( !flag( "flag_player_dying_on_rig"  ))
		flag_set( "flag_player_dying_on_rig" );
	else
		return;
	
	//delete linked viewarms if they exist
	if( IsDefined( level.jumparms ))
		level.jumparms delete();
	
	kicksource = spawn_anim_model( "exfil_viewexplosion_source" );
	
	kicksource LinkToPlayerView( level.player, "tag_origin", ( 0,0,0 ), ( 0,0,0 ), false );
	
	vision_set_fog_changes("black_ice_exfil_explosive_death",1.3);
	
	//wait( 1000.75 );
	level.player HideViewmodel();
	level.player DisableWeapons();
	
	//level.player ViewKick( 50, kicksource.origin );
	Earthquake( 0.6, 0.9, level.player.origin, 3000 );
	level.player ShellShock( "blackice_nosound", 1.25);
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	level.player thread maps\_gameskill::blood_splat_on_screen( "right" );
	PlayFXOnTag( getfx( "exfil_view_explosion" ), kicksource, "tag_splode_1"  );
	
	level.player AllowSprint( false );
	
	wait( 0.65 );
	
	//level.player ViewKick( 25, kicksource.origin );
	Earthquake( 0.5, 0.7, level.player.origin, 3000 );
	level.player ShellShock( "blackice_nosound", 0.75);
	level.player PlayRumbleOnEntity( "damage_light" );
	level.player thread maps\_gameskill::blood_splat_on_screen( "left" );
	PlayFXOnTag( getfx( "exfil_view_explosion" ), kicksource, "tag_splode_2"  );
	
	//level.player AllowStand( false );
	
	wait( 0.8 );
	
	thread player_viewkicker( kicksource );
	Earthquake( 0.7, 2.0, level.player.origin, 3000 );
	level.player ShellShock( "blackice_nosound", 3.0);
	level.player ShellShock( "slowview", 5000 );
	level.player thread maps\_gameskill::blood_splat_on_screen( "bottom" );
	PlayFXOnTag( getfx( "exfil_view_explosion" ), kicksource, "tag_splode_3"  );
	
	//level.player allowcrouch( false );
		
	wait( 0.2 );
		
	
	player_freeze = spawn_tag_origin();
	level.player PlayerLinkTo( player_freeze, "tag_origin", 1, 0, 0, 0, 0, false );
	black_overlay = maps\_hud_util::create_client_overlay( "black", 0, level.player );
	black_overlay FadeOverTime( 0.5 );
	black_overlay.alpha = 1;
	//black_overlay.sort = 3;
	black_overlay.foreground = false;
	

	wait( 2.5  );
	
	thread MissionFailedWrapper();
	
}


player_viewkicker( kicksource )
{
	thread player_viewkicker_timer();
	
	while( !flag( "flag_kick_player_to_death" ) )
	{
		//level.player ViewKick( 20, kicksource.origin );
		level.player PlayRumbleOnEntity( "grenade_rumble" );
		wait( 0.1 );
	}
}

player_viewkicker_timer()
{
	wait( 0.45 );
	
	flag_set("flag_kick_player_to_death" );
	
}

notetrack_slowmo_start(player_rig)
{
    
   /* slowmo_setspeed_slow( 0.15 );
    slowmo_setlerptime_in( .75 );
    thread slowmo_lerp_in();
    
    earthquake( .3, 1.0, level.player.origin, 2048  );
    level.player PlayRumbleOnEntity( "artillery_rumble" );
    
    wait 0.90;
    
    slowmo_setlerptime_out( .25 );
    thread slowmo_lerp_out();
  */    
 
}


get_blendtime_from_notetrack( ent, anime, notetrack, maxblendtime )
{
	
	anim_duration = GetAnimLength( anime );
	
	notetrack_time = getnotetracktimes( anime, notetrack );
	
	current_time = ent GetAnimTime( anime );
	
	blendtime = ( ( notetrack_time[0] - current_time ) * anim_duration );
	
	if( blendtime > maxblendtime )
		blendtime = maxblendtime;
	
	return( blendtime );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

open_exfil_door()
{
	door = level._exfil.door;
	
	door.angles = door.original_angles;
	
	trigger_wait_targetname( "trig_exfil_door_open" );
	
	door open_door( 120, 0.6 );
}

notetrack_grab_shake(player_rig)
{
    
   // earthquake( .3, 1.0, level.player.origin, 2048  );
    level.player PlayRumbleOnEntity( "grenade_rumble" );
  
}

notetrack_shockwave_shake(player_rig)
{
    
    earthquake( .3, 1.0, level.player.origin, 2048  );
    level.player PlayRumbleOnEntity( "grenade_rumble" );
  
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_pipe_explosions()
{
	// Setup rigs
	rig_4			= setup_tag_anim_rig( "pipe_explosion4"		  , "pipedeck_explosion4_rig" );
	//rig_exfil_pipes = setup_tag_anim_rig( "exfil_pipes_explosion", "exfil_pipes_explosion_rig" );
	
	// Setup rigs to animate on flag (flags are triggered in script_exfil.map)
	//rig_4 thread tag_anim_rig_init_and_flag_wait( "flag_command_pipes_explosion", "pipes_explode" );
	
	rig_4.anim_node anim_first_frame_solo( rig_4, "pipes_explode" );
	
	flag_wait( "flag_command_pipes_explosion" );
	PlayFX( level._effect[ "explosion_oiltank_lg" ], rig_4.origin + ( -75, 0, 0) );
	level.player PlaySound( "scn_blackice_exfil_pipes" );
	
	//TimS - setting black ice exfil exterior amb
	level.player SetClientTriggerAudioZone( "blackice_exfil_ext", 2 );
	thread maps\black_ice_audio::sfx_exfil_stop_alarm();
	
	player_pipe_explosion_reaction();
	
	rig_4.anim_node anim_single_solo( rig_4, "pipes_explode" );
	//rig_exfil_pipes thread tag_anim_rig_init_and_flag_wait( "flag_command_pipes_exfil_pipes", "pipes_explode" );	
	
	//taking this point to shuf down the past amb fx
	stop_exploder( "exfil_hall_ambfx" );
	stop_exploder( "exfil_light_1" );
	stop_exploder( "exfil_light_2" );
	stop_exploder( "exfil_light_3" );
	stop_exploder( "exfil_engine_fire" );
}
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//blow out the screen a little when the rig explodes
exfil_vision_bump()
{
	
	level waittill ( "notify_sphere_hit_ground" );
	
	wait( 1.1);
	
	IPrintLn("visionchange");
	
	vision_hit_transition( "black_ice_rig_explode", "black_ice_flyout", 1.0, 0.3, 1.6 );
	
	IPrintLn("visionchangdonee");
	
}


exfil_dof()
{
	level waittill("flag_teleport_rig");
	
	maps\_art::sunflare_changes("flyout",0.1);
	SetSavedDvar( "r_snowAmbientColor", ( 0.025, 0.025, 0.025 ) );
	
	maps\_art::dof_enable_script( 0, 62, 4, 73, 1380, 2, 0.25 );
	
	level waittill("flag_helo_swing");
	
	maps\_art::dof_enable_script( 1, 62, 4, 3848, 4000, 0, 6 );
}
exfil_rimlight()
{
	level waittill("flag_teleport_rig");
	//TODO: Replace with new Rim Light Dvars or Add to visionset
	/*SetSavedDvar("r_rimLightDiffuseIntensity","6.65");
	SetSavedDvar("r_rimLightSpecIntensity","0");
	SetSavedDvar("R_rimLightPower","31.54");
	SetSavedDvar("R_rimLightBias","0.302");	
	SetSavedDvar("r_rimLight0Pitch","-12.487");
	SetSavedDvar("r_rimLight0Heading","67.73");
	SetSavedDvar("r_rimLight0Col","1 0.5 0.1 1");*/
}
flyout_lights()
{
	lights = GetEntArray("flyout_lights","targetname");
	foreach(light in lights)
	{
		light SetLightColor((1,0.501961,0));
		light SetLightIntensity(2);
		light thread flicker(undefined,undefined,undefined,2);
	}
}
retarget_rig()
{
	self RetargetScriptModelLighting(getEnt("rig_lighttarget","targetname"));
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************