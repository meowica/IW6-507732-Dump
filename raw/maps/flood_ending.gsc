#include maps\_utility;
#include common_scripts\utility;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_precache()
{
	precacheShader( "hud_icon_usp_45" );

	PreCacheRumble( "heavygun_fire" );
	//PreCacheRumble( "smg_fire" );
	PreCacheRumble( "damage_heavy" );
	PreCacheRumble( "damage_light" );

	level._effect[ "fx_usp_muzzle_flash" ] = LoadFX( "fx/muzzleflashes/beretta_flash_wv" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "ending_ally_0_breach_ready" );
	flag_init( "ending_ally_1_breach_ready" );
	//flag_init( "ending_ally_2_breach_ready" );
	flag_init( "ending_done" );
	flag_init( "smash_rate_bad" );
	flag_init( "qte_prompt_solid" );
	flag_init( "already_failing" );
	flag_init( "hvt_dead" );
	flag_init( "ending_qte_catch_active" );
	flag_init( "ending_qte_reach_active" );
	flag_init( "ending_gate_open" );
	flag_init( "player_entering_final_area" );

	flag_init( "ending_vo_breach" );
	//flag_init( "ending_vo_1" );
	flag_init( "ending_vo_2" );
	flag_init( "ending_vo_3" );
	flag_init( "ending_vo_pt2_start" );
	flag_init( "ending_vo_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_start()
{
	maps\flood_util::player_move_to_checkpoint_start( "ending_start" );
	maps\flood_util::spawn_allies();

	level.allies[ 0 ] set_force_color( "r" );
	level.allies[ 1 ] set_force_color( "y" );
	level.allies[ 2 ] set_force_color( "g" );
	//level.allies[ 0 ] enable_cqbwalk();
	//level.allies[ 1 ] enable_cqbwalk();
	//level.allies[ 2 ] enable_cqbwalk();
	flag_set( "garage_ally_0_door_ready" );
	flag_set( "garage_ally_1_door_ready" );
	flag_set( "garage_ally_2_door_ready" );

	self thread maps\flood_util::setup_water_death();

	activate_trigger_with_targetname( "garage_ally_move480" );
	level thread maps\flood_garage::door_open();

	level.player TakeWeapon( "cz805bren+reflex_sp" );
	level.player TakeWeapon( "m9a1" );
	level.player GiveWeapon( "ak12+eotech_sp" );
	level.player GiveWeapon( "microtar" );
	level.player SwitchToWeapon( "ak12+eotech_sp" );

	maps\flood_anim::debris_bridge_final_loop();
	maps\flood_rooftops::rooftops_cleanup_post_debrisbridge();
	level thread ending_vo_main();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending()
{
	flag_wait( "garage_done" );
	SetDvar( "ui_deadquote", "" );
	//level.allies[ 0 ] disable_cqbwalk();
	//level.allies[ 1 ] disable_cqbwalk();
	//level.allies[ 2 ] disable_cqbwalk();

	//level thread ending_vo_main();
	level thread autosave_by_name_silent( "ending_start" );
	level thread maps\flood_anim::ending_animatic_setup();
	level thread move_to_breach();
	//level thread final_sequence();
	//level thread ending_vo_main();

	flag_wait( "ending_done" );

	nextmission();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

move_to_breach()
{
	trigger = GetEnt( "garage_ally_move480", "targetname" );
	if( IsDefined( trigger ) )
	{
		trigger delete();
	}

	activate_trigger_with_targetname( "ending_color_order_start" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_set_stacked_flag( ally_num )
{
	//self waittill( "goal" );

	node = GetNode( "ending_ally_" + ally_num + "_node", "targetname" );
	while( Distance( self.origin, node.origin ) > 32 )
	{
		//Line( self.origin, node.origin, ( 0, 0, 50 ), 1.0, false, 50 );
		//IPrintLn( "ally " + ally_num + " is " + Distance( self.origin, node.origin ) + " from goal node" );
		//wait ( 3.0 );
		wait( 0.05 );
	}
	//iprintln( "setting flag: ending_ally_" + ally_num + "_breach_ready" );
	flag_set( "ending_ally_" + ally_num + "_breach_ready" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

door_open( left_door_handle, right_door_handle )
{
	left_door_parts = GetEntArray( left_door_handle, "targetname" );
	right_door_parts = GetEntArray( right_door_handle, "targetname" );

	door_open_time = 0.3;

	foreach( ent in left_door_parts )
	{
		ent RotateYaw( 130, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}

	foreach( ent in right_door_parts )
	{
		ent RotateYaw( -130, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}

	wait door_open_time;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

final_sequence_fail_condition()
{
	level endon( "missionfailed" );
	level endon( "vignette_ending_player_jumped_flag" );

	wait( 6.0 );

	SetDvar( "ui_deadquote", &"FLOOD_ENDING_JUMP_FAIL" );
	level thread maps\_utility::missionFailedWrapper();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

final_sequence_player_setup()
{
	//flag_wait( "almost_there" );
	//issprinting();
	trigger = GetEnt( "ending_jump_zone", "targetname" );

	while ( true )
	{
		wait( 0.05 );
		if ( level.player JumpButtonPressed() && level.player IsTouching( trigger ) )
		{
			buttonTime = 0;
			while ( level.player JumpButtonPressed() )
			{
				if ( buttonTime >= 0.15 )
				{
					break;
				}
				buttonTime += 0.05;
				wait( 0.05 );
			}

			if ( buttonTime >= 0.15 )
			{
				break;
			}
		}
	}

	level.player GiveWeapon( "p226" );
	level.player SwitchToWeapon( "p226" );
	weapons = level.player GetWeaponsListPrimaries();
	foreach( weapon in weapons )
	{
		if ( "p226" != weapon )
		{
			level.player TakeWeapon( weapon );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_breach_ally()
{
	node = GetNode( "ending_ally_0_node", "targetname" );
	level.allies[ 0 ] ForceTeleport( node.origin, node.angles, 1024 );
	node = GetNode( "ending_ally_1_node", "targetname" );
	level.allies[ 1 ] ForceTeleport( node.origin, node.angles, 1024 );

	level.allies[ 0 ] maps\_vignette_util::vignette_actor_ignore_everything();
	level.allies[ 0 ].disableplayeradsloscheck = true;
	level.allies[ 0 ] PushPlayer( true );
	level.allies[ 0 ] disable_cqbwalk();
	level.allies[ 0 ] enable_heat_behavior();

	level.allies[ 1 ] maps\_vignette_util::vignette_actor_ignore_everything();
	level.allies[ 1 ].disableplayeradsloscheck = true;
	level.allies[ 1 ] PushPlayer( true );
	level.allies[ 1 ] disable_cqbwalk();
	level.allies[ 1 ] enable_heat_behavior();

	// need to send allies to proper locaiton
	//level.allies[ 1 ] thread maps\flood_anim::ending_pt1_allies_reach();
	wait( 0.20 );
	//level.allies[ 0 ] thread maps\flood_anim::ending_pt1_allies_reach();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_reach_final_sequence()
{
	while( 72 < Distance( level.player.origin, level.ending_heli GetTagOrigin( "door_rear_bottom_02" ) ) )
	{
		wait ( 0.05 );
		//Line( level.player.origin, level.ending_heli GetTagOrigin( "door_rear_bottom_02" ), ( 0, 0, 50 ), 1.0, false, 30 );
		//wait ( 0.50 );
	}

	flag_set( "vignette_ending_player_jumped_flag" );
	//autosave_by_name_silent( "ending_jump" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_land_on_heli_effects( guy )
{
	level.player PlayRumbleLoopOnEntity( "subtle_tank_rumble" );
	wait( 0.6 );
	StopAllRumbles();
	level.player thread maps\flood_util::earthquake_w_fade( 0.16, 64 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_price_gets_capped( guy )
{
	level endon( "vignette_ending_qte_success" );
	wait( 8.5 );
	PlayFXOnTag( level._effect[ "fx_usp_muzzle_flash" ], level.enemy_gun, "tag_flash" );
	level.ending_hvt PlaySound( "weap_p226_fire_npc" );
	flag_set( "vignette_ending_qte_failure" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_opfor_kill_pilot()
{
	wait( 1.0 );
	level.ending_opfor_2 Shoot( 1.0, level.ending_opfor_3.origin );
	wait( 0.20 );
	level.ending_opfor_2 Shoot( 1.0, level.ending_opfor_3.origin );
	wait( 0.20 );
	level.ending_opfor_2 Shoot( 1.0, level.ending_opfor_3.origin );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_shake_effects()
{
	level.player PlayRumbleLoopOnEntity( "subtle_tank_rumble" );
	level.player thread maps\flood_util::earthquake_w_fade( 0.30, 64, 2.5 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_punch_enemy_rumble( guy )
{
	level.player PlayRumbleLoopOnEntity( "subtle_tank_rumble" );
	wait( 0.6 );
	StopAllRumbles();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_fade( guy )
{
	level thread maps\_introscreen::introscreen_generic_fade_in( "black", 4.5, 1.0, 0.05 );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_slowmo_start( guy )
{
	SetSlowMotion( 1.0, 0.25, 0.5 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_slowmo_end( guy )
{
	SetSlowMotion( 0.25, 1.0, 0.05 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_broken_nose( guy )
{
	level.player DoDamage( 60, level.player.origin, level.ending_hvt );
	level.player PlayRumbleLoopOnEntity( "subtle_tank_rumble" );
	wait( 0.6 );
	StopAllRumbles();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_take_damage( guy )
{
	level.player PlayRumbleOnEntity( "damage_heavy" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_failed_qte_0( guy )
{
	PlayFXOnTag( level._effect[ "fx_usp_muzzle_flash" ], level.ending_gun, "tag_flash" );
	level.player PlaySound( "weap_p226_fire_plr" );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	SetDvar( "ui_deadquote", "" );
	level thread maps\_utility::missionFailedWrapper();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_qte_0_logic()
{
	self endon( "death" );
	self endon( "qte_0_fail" );

	self waittill( "qte_0_start" );

	level thread ending_qte_0_prompt_logic();

	while( level.player AttackButtonPressed() )
	{
		wait( 0.05 );
	}

	while( !level.player AttackButtonPressed() )
	{
		wait( 0.05 );
	}

	self PlayRumbleOnEntity( "heavygun_fire" );
	PlayFXOnTag( level._effect[ "fx_usp_muzzle_flash" ], level.ending_gun, "tag_flash" );
	self PlaySound( "weap_p99_fire_plr" );
	flag_set( "vignette_ending_qte_success" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_qte_0_prompt_logic()
{
	ending_create_qte_prompt( &"FLOOD_ENDING_QTE_0_PROMPT" );
	wait( 0.4 );
	ending_fade_qte_prompt( 0.1, 1.0 );
	flag_wait_or_timeout( "vignette_ending_qte_success", 0.933 );
	ending_fade_qte_prompt( 0.1, 0.0 );
	ending_destroy_qte_prompt();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_pickup_logic()
{
	wait ( 1.55 );		// should be waiting on a notetrack for when Price grabs Garcia

	ending_create_qte_prompt( &"FLOOD_ENDING_QTE_1_PROMPT", "hud_icon_usp_45" );
	ending_fade_qte_prompt( 0.05, 1.0 );

	level.can_still_save_price = true;
	waiting = true;
	while( level.can_still_save_price && waiting )
	{
		count = 0;

		while( self UseButtonPressed() )
		{
			count += 0.05;
			wait( 0.05 );

			if ( 0.25 <= count )
			{
				waiting = false;
				break;
			}
		}

		wait ( 0.05 );
	}

	ending_fade_qte_prompt( 0.05, 0.0 );
	ending_destroy_qte_prompt();

	if( level.can_still_save_price )
	{
		flag_set( "vignette_ending_qte_pickup_gun" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_qte_shoot_logic()
{
	level.ending_hvt thread ending_player_qte_success_logic();
	level.allies[ 0 ] thread ending_player_qte_failure_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_qte_success_logic()
{
	level endon( "hvt_dead" );

	self waittill( "damage" );
	flag_set( "vignette_ending_qte_success" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_qte_failure_logic()
{
	level endon( "vignette_ending_qte_success" );
	self waittill( "damage" );

	flag_set( "already_failing" );
	SetDvar( "ui_deadquote", &"SCRIPT_MISSIONFAIL_KILLTEAM_AMERICAN" );
	level thread maps\_utility::missionFailedWrapper();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_qte_reach_logic( guy )
{
	level.player thread ending_player_qte_button_smash_logic();
	level.player thread ending_player_qte_show_and_blink_logic();
	level.player thread ending_player_fov_change();

	smash_rate = 3;

	while( !flag( "vignette_ending_qte_success" ) )
	{
		wait ( 0.5 );

		if ( smash_rate > level.player.button_smash_count )
		{
			flag_set( "smash_rate_bad" );
		}
		else
		{
			flag_clear( "smash_rate_bad" );
		}

		level.player.button_smash_count = 0;
	}

	if( flag( "smash_rate_bad" ) )
	{
		flag_wait( "qte_prompt_solid" );
		level notify( "stop_blink" );
		level thread ending_fade_qte_prompt( 0.2, 0.0 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_fov_change()
{
	starting_fov = GetDvarInt( "cg_fov" );
	fov = starting_fov;
	while( !flag( "vignette_ending_qte_success" ) )
	{
		wait( 1.0 );
		fov -= 2;
		if( !flag( "smash_rate_bad" ) )
		{
			self LerpFOV( fov, 1.0 );
		}
	}
	self LerpFOV( starting_fov, 2.5 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_qte_button_smash_logic()
{
	self.button_smash_count = 0;

	while( !flag( "vignette_ending_qte_success" ) )
	{
		while ( !level.player UseButtonPressed() )
		{
			wait ( 0.05 );
		}

		self.button_smash_count++;

		while ( level.player UseButtonPressed() )
		{
			wait ( 0.05 );
		}
	}

	//IPrintLn( "total press = " + self.button_smash_count );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_qte_show_and_blink_logic()
{
	level endon( "vignette_ending_qte_success" );

	while( true )
	{
		flag_wait( "smash_rate_bad" );
		level thread ending_fade_qte_prompt( 0.2, 1.0 );
		flag_wait( "qte_prompt_solid" );
		level thread ending_blink_qte_prompt();
		flag_waitopen( "smash_rate_bad" );
		flag_wait( "qte_prompt_solid" );
		level notify( "stop_blink" );
		level thread ending_fade_qte_prompt( 0.2, 0.0 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_create_qte_prompt( text, icon )
{
	if ( !IsDefined( text ) )
	{
		text = &"FLOOD_ENDING_QTE_0_PROMPT";
	}

	y_offset	  = 90;
	x_offset	  = 35;
	font_scale	  = 2;
	icon_x_offset = -5;
	icon_y_offset = 90;
	elements	  = [];

	if( text == &"FLOOD_ENDING_QTE_1_PROMPT" )
	{
		x_offset = -3;
		y_offset = 70;
		font_scale = 1.50;

		icon_x_offset = 3;
		icon_y_offset = 95;
	}

	qte_text = level.player maps\_hud_util::createClientFontString( "default", font_scale );
	qte_text.x = x_offset * -1;
	qte_text.y = y_offset;
	qte_text.horzAlign = "right";
	qte_text.alignX = "right";
	qte_text.alignx = "center";
	qte_text.aligny = "middle";
	qte_text.horzAlign = "center";
	qte_text.vertAlign = "middle";
	qte_text.hidewhendead = true;
	qte_text.hidewheninmenu = true;
	qte_text.sort = 205;
	qte_text.foreground = true;
	qte_text.alpha = 0;
	qte_text SetText( text );
	//qte_text.foreground = false;
	//qte_text SetPulseFX( 100, 5000, 1000 );

	elements[ "text" ] = qte_text;

	if ( IsDefined( icon ) )
	{
		qte_icon = maps\_hud_util::createIcon( icon, 40, 40 );
		qte_icon.x = icon_x_offset;
		qte_icon.y = icon_y_offset;
		qte_icon.alignx = "center";
		qte_icon.aligny = "middle";
		qte_icon.horzAlign = "center";
		qte_icon.vertAlign = "middle";
		qte_icon.hidewhendead = true;
		qte_icon.hidewheninmenu = true;
		qte_icon.sort = 205;
		qte_icon.foreground = true;
		qte_icon.alpha = 0;
		//qte_icon.foreground = false;

		elements[ "icon" ] = qte_icon;
	}
	
	if( text == &"FLOOD_ENDING_QTE_2_PROMPT" )
	{
		qte_text = level.player maps\_hud_util::createClientFontString( "default", font_scale );
		qte_text.x = ( x_offset * -1 ) + 76;
		qte_text.y = y_offset - 2;
		qte_text.horzAlign = "right";
		qte_text.alignX = "right";
		qte_text.alignx = "center";
		qte_text.aligny = "middle";
		qte_text.horzAlign = "center";
		qte_text.vertAlign = "middle";
		qte_text.hidewhendead = true;
		qte_text.hidewheninmenu = true;
		qte_text.sort = 205;
		qte_text.foreground = true;
		qte_text.alpha = 0;
		qte_text SetText( &"FLOOD_ENDING_QTE_2_PROMPT_TEXT" );

		elements[ "text_2" ] = qte_text;
	}

	level.ending_qte_prompt = elements;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_destroy_qte_prompt()
{
	if ( !IsDefined( level.ending_qte_prompt ) )
	{
		//IPrintLn( "prompt does not exist" );
	}

	level notify( "stop_blink" );

	foreach( elem in level.ending_qte_prompt )
	{
		elem Destroy();
	}

	level.ending_qte_prompt = undefined;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_fade_qte_prompt( time, alpha )
{
	if ( !IsDefined( level.ending_qte_prompt ) )
	{
		//iprintln( "prompt does not exist" );
		return;
	}

	if ( !IsDefined( time ) )
	{
		time = 1.5;
	}

	foreach( elem in level.ending_qte_prompt )
	{
		elem FadeOverTime( time );
		elem.alpha = alpha;
	}

	if( alpha > .75 )
	{
		wait ( time );
		flag_set( "qte_prompt_solid" );
	}
	else
	{
		wait ( time );
		flag_clear( "qte_prompt_solid" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_blink_qte_prompt()
{
	level endon( "stop_blink" );
	
	if ( !IsDefined( level.ending_qte_prompt ) )
	{
		//iprintln( "prompt does not exist" );
		return;
	}

	text = level.ending_qte_prompt[ "text" ];

	while( true )
	{
		text FadeOverTime( 0.01 );
		text.alpha = 1.0;
		text ChangeFontScaleOverTime( 0.01 );
		text.fontScale = 2;

		wait ( 0.1 );
		flag_set( "qte_prompt_solid" );

		text FadeOverTime( 0.10 );
		text.alpha = 0.0;
		text ChangeFontScaleOverTime( 0.10 );
		text.fontScale = 0.25;

		wait ( 0.20 );
		flag_clear( "qte_prompt_solid" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_camera_logic()
{
	arc = 20;

	self EnableSlowAim( 0.25, 0.325 );
	self PlayerLinkToBlend( level.ending_arms, "tag_player", 0.3, 0.1, 0.1 );

	wait( 0.3 );

	self PlayerLinkToDelta( level.ending_arms, "tag_player", 1, 0, 0, 0, 0, 1 );
	self LerpViewAngleClamp( 0.5, 0.1, 0.1, arc, arc, arc, arc );

	flag_wait( "vignette_ending_qte_success" );

	wait( 0.7 );

	self LerpViewAngleClamp( 1.5, 0.4, 0.5, 0, 0, 0, 0 );

	level.ending_heli waittill( "outro_pt1_garcia_punch" );

	self LerpViewAngleClamp( 0.5, 0.1, 0.1, arc, arc, arc, arc );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_player_weapon_logic()
{
	weapons = self GetWeaponsListAll();
	foreach( weapon in weapons )
	{
		level.player TakeWeapon( weapon );
	}

	self GiveWeapon( "p226" );
	self SwitchToWeapon( "p226" );

	flag_wait( "vignette_ending_qte_success" );
	flag_waitopen( "vignette_ending_qte_success" );

	self thread maps\flood_ending::ending_player_pickup_logic();
	flag_wait( "vignette_ending_qte_pickup_gun" );

	scene = "outro_pt1_garcia_kill_pt2";
	level.ending_heli thread maps\_anim::anim_single( make_array( level.ending_arms ), scene, "tag_origin" );
	level.ending_heli waittill( scene );

	level.ending_gun Hide();
	self EnableWeapons();

	self thread maps\flood_ending::ending_player_qte_shoot_logic();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_qte_catch()
{
	self endon( "death" );
	self thread ending_qte_catch_prompt();
	level.outro_node endon( "outro_pt2_start" );

	flag_wait( "ending_qte_catch_active" );

	while( true )
	{
		if( self AdsButtonPressed() && self AttackButtonPressed() )
		{
			break;
		}

		wait( 0.05 );
	}

	flag_set( "vignette_ending_qte_success" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_qte_catch_prompt()
{
	flag_wait( "ending_qte_catch_active" );

	ending_create_qte_prompt( &"FLOOD_ENDING_QTE_3_PROMPT" );
	ending_fade_qte_prompt( 0.1, 1.0 );

	flag_wait_or_timeout( "vignette_ending_qte_success", 1.4 );

	ending_fade_qte_prompt( 0.1, 0.0 );
	ending_destroy_qte_prompt();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_qte_reach()
{
	self endon( "death" );
	level.outro_node endon( "outro_pt2_save_vargas" );
	level.outro_node endon( "outro_pt2_save_vargas_win_01" );

	flag_wait( "ending_qte_reach_active" );

	ending_create_qte_prompt( &"FLOOD_ENDING_QTE_2_PROMPT" );
	wait( 0.4 );
	ending_fade_qte_prompt( 0.1, 1.0 );

	while( true )
	{
		if( self UseButtonPressed() )
		{
			break;
		}

		wait( 0.05 );
	}

	flag_set( "vignette_ending_qte_success" );
	ending_fade_qte_prompt( 0.1, 0.0 );
	ending_destroy_qte_prompt();

	self thread ending_qte_reach();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_lower_raise_weapon_logic()
{
	level endon( "vignette_ending_player_jumped_flag" );

	trigger = GetEnt( "ending_lower_weapon", "targetname" );
	trigger waittill( "trigger" );

	self DisableWeapons();

	trigger = GetEnt( "ending_raise_weapon", "targetname" );
	trigger waittill( "trigger" );

	self EnableWeapons();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_transition()
{
	flag_set( "rooftops_done" );// make sure notetrack to door kick gets loaded
	self thread ending_heli_callout_vo();
	self thread ending_open_doors();
	self thread ending_vo_main();

	one_time = false;

	while( true )
	{
		enemies = GetAIArray( "axis" );
		if( 0 >= enemies.size )
		{
			break;
		}
		if ( 3 > enemies.size && !one_time )
		{
			foreach( enemy in enemies )
			{
				enemy.attackeraccuracy = 25;
			}
			activate_trigger_with_targetname( "ending_heli_path" );
			one_time = true;
		}
		wait( 0.05 );
	}

	level.allies[ 1 ] smart_dialogue( "flood_vrg_wegottagetthrough" );

	flag_set( "garage_done" );

	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	level.allies[ 0 ] disable_cqbwalk();
	level.allies[ 1 ] disable_cqbwalk();
	level.allies[ 2 ] disable_cqbwalk();

	flag_wait( "ending_vo_push_forward" );
	//wait( 0.75 );
	//level.allies[ 1 ] thread smart_dialogue( "flood_vrg_wegottagetthrough" );

	//flag_wait( "garage_ally_0_door_ready" );
	//level.allies[ 0 ] thread smart_dialogue( "flood_pri_garciasgottobe" );

	if( !flag( "ending_vo_1" ) )
	{
		flag_wait( "ending_vo_approach" );
		level.allies[ 1 ] smart_dialogue( "flood_pri_eliasvargasyourewith" );
		level.allies[ 1 ] smart_dialogue( "flood_pri_merrickcheckforsurvivors" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_vo_main()
{
	flag_clear( "rooftops_vo_push_forward_hassle" );
	//flag_wait( "ending_vo_interior" );

	flag_wait( "ending_vo_1" );
	//wait( 1.25 );
	if( !flag( "garage_done" ) )
	{
		level.allies[ 0 ] thread smart_dialogue( "flood_pri_wegottoget" );
	}

	if ( !flag( "rooftops_vo_push_forward_hassle" ) )
	{
		level.allies[ 0 ] thread maps\flood_util::nag_end_on_notify( make_array( "flood_pri_eliasgetthedoor", "flood_pri_openthedoorwell", "flood_pri_weregonnalosegarcia" ), "flag_set", true );
		flag_wait( "rooftops_vo_push_forward_hassle" );
		level.allies[ 0 ] notify( "flag_set" );
	}

	flag_wait( "ending_vo_2" );
	level.allies[ 0 ] thread smart_dialogue( "flood_pri_jump" );

	flag_wait( "ending_vo_3" );
	wait( 0.4 );
	level.allies[ 1 ] thread smart_dialogue( "flood_pri_getgarcia" );

	flag_wait( "ending_vo_pt2_start" );
	level.allies[ 0 ] smart_dialogue( "flood_mrk_everyonegood" );
	wait( 3.0 );
	level.allies[ 1 ] smart_dialogue( "flood_vrg_nobodymove" );
	wait( 3.6 );
	level.allies[ 0 ] smart_dialogue( "flood_mrk_vargas" );

	flag_wait( "vignette_ending_qte_success" );

	level.allies[ 0 ] smart_dialogue( "flood_mrk_shitgrabhimgrab" );
	//level.allies[ 0 ] smart_dialogue( "flood_mrk_wereslippin" );
	level.allies[ 1 ] smart_dialogue( "flood_vrg_eliasineedyou" );
	level.allies[ 1 ] thread smart_dialogue( "flood_vrg_ineedyouto" );
	wait( 1.25 );
	level.allies[ 0 ] smart_dialogue( "flood_mrk_dontdoitelias" );
	//level.allies[ 1 ] smart_dialogue( "flood_vrg_listentomesergeant" );
	level.allies[ 1 ] smart_dialogue( "flood_vrg_thatsanorderelias" );
	
	smart_radio_dialogue( "flood_hsh_sowhatdidyou" );
	wait( 0.95 );
	smart_radio_dialogue( "flood_els_ifollowedordersi3" );	//flood_els_ifollowedordersi, flood_els_ifollowedordersi2, flood_els_ifollowedordersi3
	thread nextmission();
	//flag_set( "ending_vo_done" );
	//flag_wait( "ending_vo_breach" );
	 //"flood_pri_getgarcia"	"Get Garcia!"
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_heli_callout_vo()
{
	wait_for_targetname_trigger( "ending_heli_path" );

	spawner = GetEnt( "ending_heli_path_veh", "targetname" );
	level.ending_heli_path = maps\_vehicle::vehicle_spawn( spawner );
	level.ending_heli_path maps\_vehicle::GodOn();
	level.ending_heli_path thread maps\_vehicle::gopath();

	wait( 2.0 );
	level.allies[ 2 ] smart_dialogue( "flood_mrk_heloinbound" );
	wait( 1.0 );
	level.allies[ 0 ] smart_dialogue( "flood_pri_theyrepickingupgarcia" );

	flag_wait( "player_entering_final_area" );
	if ( IsDefined( level.ending_heli_path ) )
	{
		level.ending_heli_path Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_open_doors()
{
	maps\flood_anim::setup_enemies_open_gate();
	maps\flood_util::waittill_enemy_count_or_trigger( 2, "ending_heli_path" );

	maps\flood_anim::enemies_open_gate();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_swing_doors_open()
{
	left_door_parts = GetEntArray( "garage_door_l", "targetname" );
	right_door_parts = GetEntArray( "garage_door_r", "targetname" );

	door_open_time = 0.3;

	foreach( ent in left_door_parts )
	{
		//ent RotateYaw( -130, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}

	foreach( ent in right_door_parts )
	{
		//ent RotateYaw( 130, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}

	GetNode( "ending_trouble_node", "targetname" ) DisconnectNode();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ending_temp_ignore()
{
	self endon( "death" );

	self.ignoreall = true;
	flag_wait( "ending_gate_open" );

	self SetGoalVolumeAuto( GetEnt( "ending_golvolume", "targetname" ) );

	wait( 1.2 );
	self.ignoreall = false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************