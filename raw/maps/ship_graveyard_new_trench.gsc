#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_hud_util;

#include maps\ship_graveyard_util;

main()
{
	SetSavedDvar( "bg_viewKickMax", 30 );
	
	level.baker thread dyn_swimspeed_disable();
	
	level.player DisableWeapons();
	
	level.player thread vision_set_fog_changes( "shpg_start_chasm_lessfog", 0.05 );

	level.killfirm_suffix = "_loud";
	
	setSavedDvar( "player_swimSpeed", 80 );
	setSavedDvar( "player_sprintUnlimited", "1" );
	
	maps\ship_graveyard_stealth::stealth_disable();

	level.baker.goalradius = 64;
	level.baker.pathrandompercent = 0;
	level.stealth_ally_accu = 1;
	level.baker.baseaccuracy = level.stealth_ally_accu;

	set_start_positions( "new_trench" );
	
	autosave_by_name( "drown" );
	
	thread trench_drowning();
	thread trench_things_crashing();
	thread trench_light_flicker();
}

trench_light_flicker()
{
	level endon( "start_new_canyon" );
	light = get_target_ent( "new_trench_drown_light" );
	lightintensity = light GetLightIntensity();
	while ( 1 )
	{
		i = RandomFloatRange( lightintensity * 0.7, lightintensity * 1.2 );
		light SetLightIntensity( i );
		wait( 0.05 );
	}
}

canyon_main()
{
	SetSavedDvar( "bg_viewKickMax", 20 );
	level.killfirm_suffix = "_loud";
	flag_set( "allow_killfirms" );
	
	level.baker.pathrandompercent = 50;
	level.baker thread dyn_swimspeed_disable();
	level.baker.moveplaybackrate = 1.25;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	thread start_canyon_combat();
	thread hit_player_when_flag();
}

trench_drowning()
{
	namedist = getdvar( "g_friendlyNameDist" );
	setsaveddvar( "g_friendlyNameDist", 0 );
	model = get_target_ent( "new_trench_first_crash" );
	model delete();
	
//	if (IsDefined (	level.sun_pos_pre_lcs_death ))
//	{
//		setDvar( "r_sunflare_position", level.sun_pos_pre_lcs_death );
//	}
	    
	level.ro_index = 0;
	level.player FreezeControls( true );
	level.player DisableWeapons();
//	level.player SetBlurForPlayer( 10, 0.1 );
	level.player notify( "stop_scuba_breathe" );

	//thread fake_shellshock_sound();	
	level.player thread maps\_Swim_player::shellshock_forever();
	
	chopper = spawn_anim_model( "crash_chopper" );
	
	level.baker.animname = "generic";
	
	boat = get_target_ent( "trench_bottom_boat" );
	attach = getentarray( "trench_bottom_boat_attach", "targetname" );
	array_call( attach, ::linkTo, boat );
	
	boat_tag = spawn_anim_model( "trench_boat" );
	debris = spawn_anim_model( "debris" );
	hose = spawn_anim_model( "breather_hose" );
	
	player_swim_offset = (0,0,48);
	
	rig = maps\_player_rig::get_player_rig();
	rig.origin = level.player.origin - player_swim_offset;
	rig.angles = level.player.angles;
	
	dummy = spawn_tag_origin();
	dummy.origin = rig.origin;
	dummy.angles = rig.angles;
	dummy linkTo( rig, "tag_player", player_swim_offset, (0,0,0) );

	level.player PlayerLinkToAbsolute( dummy, "tag_origin" );
	
	actors = [ rig, chopper, level.baker, boat_tag, hose, debris ];
	
	node = get_target_ent( "new_trench_anim_node" );
	node anim_first_frame( actors, "trench_drown" );
	wait( 0.5 );
	
	level notify( "stop_sun_movement" );
	ResetSunDirection();
	
	level.f_min[ "gasmask_overlay" ] = 0.7;
	level.f_max[ "gasmask_overlay" ] = 0.9;
	level.player.breathing_overlay[ "gasmask_overlay" ].alpha = 0.9;
	
	boat linkTo( boat_tag );
	
	exploder( "lcs_collapsing" );
	
	wait( 2 );
//	level.player.hud_scubaMask setModel( "shpg_viewmodel_scuba_mask_cr01" );	
//	level.player thread play_sound_on_entity( "scn_shipg_scuba_mask_crack" );
	
	exploder( "dead_bodies_underwater" );
	exploder( "lcs_collapsing" );
	
	thread drowning_hudfx();

	hose thread hose_fx();
	
	//sound for the hose
	hose thread play_sound_on_tag("scn_shipg_rescue_hose", "tag_fx");
	//sound for the player drowning grunts, timed with the scene
	thread drowning_dialogue();
	//sfx for the scene broken out
	// thread rescue_scene_sfx();
	
	chopper thread chopper_fx();
	chopper Hide();
	
	level.f_min[ "halo_overlay_scuba_steam" ] = 0.7;
	level.f_max[ "halo_overlay_scuba_steam" ] = 0.9;
	level.player.breathing_overlay[ "halo_overlay_scuba_steam" ].alpha = 0.9;
	delayThread( 14, ::player_gives_up );
	
	thread rig_fx( rig );
	thread rebreather_plug_in();
	thread unlink_player( node, rig, hose, boat_tag );
	thread unlink_baker();
	thread lcs_back();
	thread drowning_dof( dummy, rig );
	
	str = get_Target_ent( "first_cheap_object" );
	str delayThread( 22.5, ::generate_cheap_falling_object, 217, 50 );
		
//	level.player delaythread( 24, ::vision_set_fog_changes, "shpg_start_chasm_lessfog", 5 );
	
	level.baker disable_exits();
	node anim_single( actors, "trench_drown" );
	wait( 0.2 );
	level.baker enable_exits();
	dummy delete();
	setsaveddvar( "g_friendlyNameDist", namedist );
}

rescue_scene_sfx()
{	
	wait (8.266);
	//sound for the player's stuck hand - 08:08 (timecode)
	level.player playsound("scn_shipg_rescue_hand");	
	
	wait (9.3);	
	//sound for baker plugging in the air - 17:17 (timecode)
	level.player playsound("scn_shipg_rescue_helmet");	
	
	wait (2.634);	
	//sound for baker grabbing and heaving metal - 20:06 (timecode)
	level.player playsound("scn_shipg_rescue_heave");	
	
	wait (10.166);	
	//sound for the helicopter hitting the wall - 30:11 (timecode)
	level.player playsound("scn_shipg_rescue_heli");	
	
	wait (3.734);	
	//sound for the players tank hitting when thrown back - 34:03 (timecode)
	level.player playsound("scn_shipg_rescue_hitback");	
	
}

drowning_dof( dummy, rig )
{
	wait( 7.25 );
	flag_set( "pause_dynamic_dof");
	maps\_art::dof_enable_script( 0, 0, 10, 30, 60, 1.5, 1 ); //hand
	flag_wait( "drown_rebreather_plugin" );
	wait( 4.5 );
	maps\_art::dof_enable_script( 0, 0, 10, 450, 750, 1.5, 3.5 ); //free hand
	flag_wait( "drown_debris_impact" );
	//level.player PlayerLinkToDelta( dummy, "tag_origin", 0.6, 15, 15, 30, 30, true );
	level.player unlink();
	rig hide();
	level.player EnableSlowAim( 0.5, 0.5 );
	level.player AllowSprint( false );
	setSavedDvar( "player_swimSpeed", 15 );
	setSavedDvar( "player_swimVerticalSpeed", 15 );
	wait( 0.5 );
	maps\_art::dof_enable_script( 0, 0, 10, 450, 750, 3, 2.5 );  // A ok
	flag_wait( "drown_chopper_i1" );
	rig show();
	level.player DisableSlowAim();
	level.player AllowSprint( true );
	level.player PlayerLinkToBlend( dummy, "tag_origin", 0.5, 0, 0 );
	wait( 0.05 );
	maps\_art::dof_enable_script( 0, 150, 10, 1100, 5000, 5, 0.5 );  // WTF!!
	flag_wait( "drown_chopper_i2" );
	//level.player LerpViewAngleClamp( 0.75, 0.7, 0.05, 0, 0, 0, 0 );
	maps\_art::dof_disable_script( 1 );
	wait(1);
	flag_clear( "pause_dynamic_dof" );
}

drowning_dialogue()
{
	level.baker waittillmatch( "single anim", "shipg_bkr_rookrook" );
	thread smart_radio_dialogue( "shipg_bkr_rookrook_new" );
	level.baker waittillmatch( "single anim", "shipg_bkr_cmonstaywithme" );
	thread smart_radio_dialogue( "shipg_bkr_cmonstaywithme_new" );
	level.baker waittillmatch( "single anim", "shipg_bkr_alrightletsgetthis" );
	thread smart_radio_dialogue( "shipg_bkr_alrightletsgetthis_new" );
	level.f_min[ "gasmask_overlay" ] = 0.3;
	level.f_max[ "gasmask_overlay" ] = 0.95;
	level.baker waittillmatch( "single anim", "shipg_bkr_grunt" );
	thread smart_radio_dialogue_overlap( "shipg_bkr_grunt_new" );	
	delaythread( 7.5, ::smart_radio_dialogue_overlap, "shipg_bkr_youok" );
	level.baker waittillmatch( "single anim", "shipg_bkr_whatthe" );
	thread smart_radio_dialogue_overlap( "shipg_bkr_whatthe_new" );
	level.baker waittillmatch( "single anim", "shipg_bkr_move_2" );
	thread smart_radio_dialogue_overlap( "shipg_bkr_move_2_new" );	
}

drowning_hudfx()
{
	wait( 2 );
	thread maps\_hud_util::fade_in( 5.5 );
	level.player SetBlurForPlayer( 0, 6 );
	wait( 4.5 );
	thread mash_to_survive();
	//wait( 11 );
	/*
	level.player.hud_scubaMask setModel( "shpg_viewmodel_scuba_mask_cr02" );
	level.player thread play_sound_on_entity( "scn_shipg_scuba_mask_crack" );
	*/
	//thread maps\_hud_util::fade_out( 16 );
	//wait( 1.75 );
	/*
	level.player.hud_scubaMask setModel( "shpg_viewmodel_scuba_mask_cr03" );
	level.player thread play_sound_on_entity( "scn_shipg_scuba_mask_crack" );
	*/
}

mash_to_survive()
{
	wait( 2 );
	fade_in_x_hint( 2 );
	thread x_hint_blinks();
	thread increase_difficulty();
	level endon( "drown_rebreather_plugin" );
	level.player endon( "death" );
	level.fade_out_death_time = 2.5;
	level.occumulator = 0;
	level.drown_max_alpha = 0;
	while( 1 )
	{
		fade_out_death();
		wait( 0.05 );
	}
}

increase_difficulty()
{
	level waittill( "player_hit_x" );
	//level.fade_out_death_time = 2;
	//wait( 3 );
	//level.drown_max_alpha = 0.2;
}

fade_out_death()
{
	thread wait_for_x_input();
	level endon( "player_hit_x" );
//	level.player setBlurForPlayer( 4, level.fade_out_death_time );
	thread fade_out( level.fade_out_death_time );
	
	first_wait = Max( 0, level.fade_out_death_time - 1.75 );
	second_wait = level.fade_out_death_time - first_wait;
	
	wait( first_wait );
	
	level.occumulator = 0;
	
	wait( second_wait );
	
	fade_out_x_hint( 0.25 );
	level.player kill();
	force_deathquote( &"SHIP_GRAVEYARD_HINT_DROWN" );
}

wait_for_x_input()
{
	level.player endon( "death" );
	level endon( "drown_rebreather_plugin" );
	while( use_Pressed() )
		wait( 0.05 );
	while( !use_Pressed() )
		wait( 0.05 );
	level notify( "player_hit_x" );
	thread fade_in_to_alpha( 0.1, level.drown_max_alpha );
	Earthquake( 0.25, 0.2, level.player.origin, 512 );
	level.player PlayRumbleOnEntity( "damage_light" );
//	level.player setBlurForPlayer( 0, 0.1 );
	level.occumulator += 1;
}

fade_in_to_alpha( time, alpha )
{
	if ( level.MissionFailed )
		return;
        
	overlay = get_optional_overlay( "black" );
	overlay FadeOverTime( time );
	overlay.alpha = alpha;

	wait( time );
}

fade_in_x_hint( time )
{
	if ( !isdefined( time ) )
		time = 1.5;

	if ( !isdefined( level.x_hint ) )
		draw_x_hint();

	foreach ( elem in level.x_hint )
	{
		elem FadeOverTime( time );
		elem.alpha = 0.95;
	}
}

draw_x_hint()
{
	y_offset = 125;
	x_offset = 0;

	knife_text = level.player createClientFontString( "default", 2 );
	
	
	knife_text.x = x_offset * -1;
	knife_text.y = y_offset;
	knife_text.horzAlign = "right";
	knife_text.alignX = "right";
	knife_text set_default_hud_stuff();
	// ^3[{+usereload}]^7
	knife_text SetText( &"SHIP_GRAVEYARD_HINT_RT" );
	//knife_text SetPulseFX( 100, 5000, 1000 );

	elements = [];
	elements[ "text" ] = knife_text;

	level.x_hint = elements;
}

x_hint_blinks()
{
	level notify( "fade_out_x_hint" );
	level endon( "fade_out_x_hint" );

	
	if ( !isdefined( level.x_hint ) )
		draw_x_hint();

	fade_time = 0.60;
	hold_time = 0.20;

	foreach ( elem in level.x_hint )
	{
		elem FadeOverTime( 0.1 );
		elem.alpha = 0.95;
	}

	wait 0.1;

	hud_button = level.x_hint[ "text" ];

	console_scalar = 3;
		
	for ( ;; )
	{
		
		hud_button FadeOverTime( 0.01 );
		hud_button.alpha = 0.95;
		hud_button ChangeFontScaleOverTime( 0.01 );
		
		if (!level.Console && !level.player usinggamepad())
			hud_button.fontScale = 2;
		else
			hud_button.fontScale = 2 * console_scalar;
		
		wait 0.18;

		hud_button FadeOverTime( fade_time );
		hud_button.alpha = 0.0;
		hud_button ChangeFontScaleOverTime( fade_time );

		if (!level.Console && !level.player usinggamepad())
			hud_button.fontScale = 0.25;
		else
			hud_button.fontScale = 0.25 * console_scalar;

		wait hold_time;

		hide_hint_presses = 4;

		while ( IsDefined( level.occumulator ) )
		{
			if ( level.occumulator < hide_hint_presses )
				break;

			foreach ( elem in level.x_hint )
			{
				elem.alpha = 0;
			}
			fade_time = 0.30;
			hold_time = 0.10;
			wait 0.05;
		}
	}
}

fade_out_x_hint( time )
{
	level notify( "fade_out_x_hint" );
	if ( !isdefined( time ) )
		time = 1.5;

	if ( !isdefined( level.x_hint ) )
		draw_x_hint();

	foreach ( elem in level.x_hint )
	{
		elem FadeOverTime( time );
		elem.alpha = 0;
	}
}

set_default_hud_stuff()
{
//	MYFADEINTIME = 2.0;
//	MYFLASHTIME = 0.75;
//	MYALPHAHIGH = 0.95;
//	MYALPHALOW = 0.4;


	self.alignx = "center";
	self.aligny = "middle";
	self.horzAlign = "center";
	self.vertAlign = "middle";
	//self.foreground = false;
	self.hidewhendead = true;
	self.hidewheninmenu = true;

	self.sort = 205;
	self.foreground = true;

	self.alpha = 0;
//	self FadeOverTime( MYFADEINTIME );
//	self.alpha = MYALPHAHIGH;

}

use_pressed()
{
	return level.player AttackButtonPressed();
}

player_gives_up()
{
	level notify( "stop_drowning" );
	//level.player DoDamage( 3, level.player.origin );
//	level.player SetBlurForPlayer( 6, 4 );
	//thread maps\_hud_util::fade_out( 5 );
	level.fade_out_death_time = 1;
	level.drown_max_alpha = 0.5;
}

lcs_back_bubbles()
{
	self script_delaY();
	PlayFXOnTag( getfx( self.script_fxid ) , self, "Tag_origin" );
	self waittill( "stopfx" );
	self script_delaY();
	StopFXOnTag( getfx( self.script_fxid ) , self, "Tag_origin" );
	self script_delaY();
	self delete();
}

lcs_back()
{
	model = get_target_ent( "first_lcs_crash" );
	othermodels = model get_linked_ents();
	model Hide();
	
	fx_org = model spawn_Tag_origin();
	fx_org linkTo( model );
	
	bubble_orgs = [];
	markers = getstructarray_delete( "lcs_back_bubble_fx", "targetname" );
	d = 0.0;
	foreach ( m in markers )
	{
		org = spawn_tag_origin();
		org.origin = m.origin;
		org.angles = m.angles;
		org.script_fxid = m.script_fxid;
		org.script_delay = d;
		d = d + 0.2;
		bubble_orgs = array_add( bubble_orgs, org );
		org linkTo( model );
	}
	
	flag_wait( "drown_drop_lcs" );

	array_thread( bubble_orgs, ::lcs_back_bubbles );
	
	wait( 1 );
	
//	PlayFXOnTag( getfx( "lcs_back_lights" ) , fx_org, "Tag_origin" );
	
	model thread play_sound_on_entity("scn_shipg_lcs_back_fall");
	model thread crash_model_go( othermodels );
	array_thread( othermodels, ::lcs_back_damage );
	vol = get_target_ent( "lcs_back_crash_vol" );
	vol thread lcs_back_damage();
	
	targetorg = model get_target_ent();
	model delayCall( 0.5, ::rotateTo, targetorg.angles, 6, 0, 6 );
	
	wait( 3.5 );
	
	thread smart_radio_dialogue( "shipg_bkr_timetogo" );
	flag_set( "trench_allow_things_to_crash" );	
	flag_set( "start_base_alarm" );
	level.player thread vision_set_fog_changes( "", 4 );
	wait 1; 
	array_thread( bubble_orgs, ::send_notify, "stopfx" );
	music_play( "mus_shipgrave_trenchrun_battle" );
	
	wait( 2 );
//	StopFXOnTag( getfx( "lcs_back_lights" ) , fx_org, "Tag_origin" );
	fx_org delete();
}

lcs_back_damage()
{
	self waittill( "stop_damage" );
	vol = get_target_ent( "lcs_back_crash_vol" );
	if ( vol != self )
		vol notify( "stop_damage" );
	if ( level.player isTouching( self ) )
	{
		player_smash_death();
	}
}


rebreather_plug_in()
{
	wait( 4 );
	//level.player ShellShock( "shipg_player_drown", 6 );
	//level.player delayThread( 10, ::ShellShock, "shipg_player_drown", 3 );	
	thread scn_rescue_shockfile_thread();
	level.player LerpFOV( 50, 10 );
	flag_wait( "drown_rebreather_plugin" );
	thread fade_out_x_hint( 0.25 );
	level.player LerpFOV( 65, 0.6 );
	level notify( "stop_shellshock" );
	level.player thread play_sound_on_entity( "shipg_player_better_breath" );
	//level.player FadeOutShellShock();
//	level.player SetBlurForPlayer( 0, 0.5 );
	
	level.player.playerFxOrg = spawn( "script_model", level.player.origin + ( 0, 0, 0 ) );
	level.player.playerFxOrg setmodel( "tag_origin" );
	level.player delayThread( 0.1, ::player_panic_bubbles );
	thread maps\_hud_util::fade_in( 0.1 );
	level.player.playerFxOrg.angles = level.player GetPlayerAngles();
	level.player.playerFxOrg.origin = level.player getEye() - ( 0,0,10 );
	level.player.playerFxOrg LinkToPlayerView( level.player, "tag_origin", ( 5, 0, -55 ), ( 0, 0, 0 ), true );
	
	playfxontag( getfx( "scuba_bubbles" ), level.player.playerFxOrg, "TAG_ORIGIN" );
	wait( 0.25 );
	
	thread maps\_hud_util::fade_out( 3 );
	level.f_min[ "gasmask_overlay" ] = 0.1;
	level.f_max[ "gasmask_overlay" ] = 0.2;
	wait( 0.5 );
	maps\_hud_util::fade_in( 1 );
	level.f_min[ "halo_overlay_scuba_steam" ] = 0.4;
	level.f_max[ "halo_overlay_scuba_steam" ] = 0.6;
	wait( 0.5 );
	level.player.playerFxOrg delete();
	wait( 0.1 );
	level.player thread maps\_underwater::player_scuba();
	wait( 0.1 );
	level.player thread maps\_swim_player::flashlight();
}

scn_rescue_shockfile_thread()
{
	wait 10;
	level.player ShellShock( "shipg_player_drown", 5 );	
}


rig_fx( rig )
{
	wait( 10.66 );
	org = rig GetTagOrigin( "j_wrist_ri" );
	PlayFX( getfx( "player_arm_blood" ), org, (0,0,1), (1,0,0) );
}

unlink_player( node, rig, hose, boat_tag )
{
	SetSavedDvar( "sv_znear", "1" );
	flag_wait( "drown_hand_sound" );
	rig thread play_sound_on_tag( "scn_shipg_rescue_hand", "j_wrist_ri" );
		
	flag_init( "drown_player_triggered_unlink" );
	
	level.player FreezeControls( false );
	
	flag_wait( "drown_debris_impact" );
	
	level.player playsound ("scn_shipg_rescue_metal_drop");
	
	Exploder( 49 );
	
	flag_wait( "drown_player_impact" );
	Earthquake( 0.4, 0.5, level.player.origin, 512 );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	
	flag_wait( "drown_pre_unlink_player" );
	SetSavedDvar( "sv_znear", "4" );
	
	level.player EnableWeapons();
	//level.player delayThread( 1.5, ::vision_set_fog_changes, "", 3 );
	thread unlink_on_stick();
	
	flag_wait_either( "drown_unlink_player", "drown_player_triggered_unlink" );

	thread trench_smash_death();
	thread trench_stay_close_1();
	thread trench_stay_close_2();
	
	level.player unlink();
	
	thread deathquote_on_death();
	
	setSavedDvar( "player_swimSpeed", 80 );
	setSavedDvar( "player_swimVerticalSpeed", 80 );
	level.f_min[ "gasmask_overlay" ] = 0.3;
	level.f_max[ "gasmask_overlay" ] = 0.95;

	rig Hide();
	hose Hide();
	boat_tag Hide();

	autosave_by_name( "trench" );
	
	flag_wait( "drown_unlink_player" );

	rig delete();
	hose delete();
	boat_tag delete();
	
	level.player ClearClientTriggerAudioZone(1.0);
	
	thread trench_run_Dialogue();
	thread random_trench_falling();
//	org = get_target_ent( "new_trench_lookat_start" );
//	org waittill_player_lookat( 0.65, undefined, true, 4 );
}

unlink_on_stick()
{
	level endon( "drown_unlink_player" );
	
	while ( Distance( level.player GetNormalizedMovement(), (0,0,0) ) < 0.3 )
		wait( 0.05 );
	
	flag_set( "drown_player_triggered_unlink" );
}

unlink_baker()
{
	level.baker.goalradius = 128;
	level.baker.moveplaybackrate = 1.2;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker thread dyn_swimspeed_enable( 500 );
	
	level.baker thread follow_path_and_animate( get_target_ent( "new_trench_baker_path" ), 0 );	
}

chopper_fx()
{
	flag_wait( "drown_chopper_start" );
	self Show();	
	PlayFXOntag( getfx( "ship_wreckage_spark_underwater" ), self, "tag_fire" );
	PlayFXOntag( getfx( "ship_wreckage_spark_underwater" ), self, "main_rotor" );
	
	flag_wait( "drown_chopper_i1" );
	wait( 0.1 );
	exploder( 51 );
	Earthquake( 0.5, 0.7, self.origin, 2000 );	
	
	
	flag_wait( "drown_chopper_i2" );
	Earthquake( 0.7, 1.5, self.origin, 3000 );
	exploder( 52 );
	player_shake( 100 );
	level.player PlayRumbleOnEntity( "damage_light" );
	level.player delayCall( 0.25, ::PlayRumbleOnEntity, "damage_heavy" );
	/*level.player.hud_scubaMask setModel( "shpg_viewmodel_scuba_mask_cr03" );
	level.player thread play_sound_on_entity( "scn_shipg_scuba_mask_crack" );*/
	
	flag_wait( "drown_chopper_i3" );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	exploder( 53 );
	
	wait( 4 );
	
	StopFXOntag( getfx( "ship_wreckage_spark_underwater" ), self, "tag_fire" );
	wait( 0.1 );
	StopFXOntag( getfx( "ship_wreckage_spark_underwater" ), self, "main_rotor" );
}

hose_fx()
{
	PlayFXOnTag( getfx( "rebreather_hose_bubbles" ), self, "TAG_FX" );
	flag_wait( "drown_rebreather_plugin" );
	StopFXOnTag( getfx( "rebreather_hose_bubbles" ), self, "TAG_FX" );
}

trench_wakeup()
{
	new_dvar = GetDvarInt( "trench_drown", 1 );
	if ( new_dvar )
	{
		thread trench_drowning();
		return;
	}
	flag_set( "trench_allow_things_to_crash" );
	
	level.player FreezeControls( true );
	level.player DisableWeapons();
//	level.player SetBlurForPlayer( 10, 0.1 );
	
	waitframe();
	
	/*
	crack_overlay = create_client_overlay( "gfx_growing_ice_cracks01", 1, level.player );
	crack_overlay.foreground = false;
	crack_overlay.sort = 0;
	*/
	
	src_array = getstructarray( "new_trench" , "targetname" );
	src = undefined;
	foreach ( a in src_array )
	{
		if ( a.script_noteworthy == "player" )
		{
			src = a;
			break;
		}
	}
	
	org = src Spawn_tag_origin();
//	org.angles = level.player GetPlayerAngles();
	level.player PlayerLinkToAbsolute( org, "tag_origin" );
	
	level.baker.moveplaybackrate = 1.15;
	level.baker.moveTransitionRate = level.baker.moveplaybackrate;
	level.baker thread dyn_swimspeed_enable( 300 );
	
	//thread fake_shellshock_sound();
	level.player thread maps\_Swim_player::shellshock_forever();
	wait( 1 );
	level.player PlayerLinkToDelta( org, "tag_origin", 1, 40, 40, 40, 40 );
	model = get_target_ent( "new_trench_first_crash" );
	othermodels = model get_linked_ents();
	model thread crash_model_go( othermodels );
	wait( 3 );
	flag_set( "start_base_alarm" );
	thread maps\_hud_util::fade_in( 5 );
	wait( 2 );
//	level.player SetBlurForPlayer( 0, 7 );
	level notify( "player_wakeup" );
	thread smart_radio_dialogue( "shipg_bkr_wakeup" );

	level notify( "stop_shellshock" );
	
	flag_wait( "new_trench_first_crash" );
	level.player FreezeControls( false );
	trench_death_warning();
//	activate_trigger_with_noteworthy( "second_crash" );
	thread smart_radio_dialogue( "shipg_bkr_pain2" );
	wait( 2.75 );
	level.baker thread follow_path_and_animate( get_target_ent( "new_trench_baker_path" ), 0 );
	level.player FreezeControls( false );
	level.player EnableWeapons();
	autosave_by_name( "trench" );
	thread trench_run_Dialogue();
	thread random_trench_falling();
	wait( 0.25 );
	level.player Unlink();
	org delete();
}

deathquote_on_death()
{
	level endon( "start_new_canyon" );
	level.player waittill( "death" );
	
	times_died = getDvarInt( "shpg_trench_times_died", 0 );
	SetDvar( "shpg_trench_times_died", times_died + 1 );
	force_deathquote( &"SHIP_GRAVEYARD_HINT_TRENCH" );
}

trench_sprint_hint()
{
	wait( 0.75 );
	
	times_died = getDvarInt( "shpg_trench_times_died", 0 );
	if ( times_died > 1 )
		thread display_hint( "hint_sprint" );
}
	
trench_run_Dialogue()
{
	level.baker disable_Pain();
	thread trench_sprint_hint();	
	
	wait( 1.12 );
	smart_radio_dialogue( "shipg_bkr_clearedforphase2" );		
	wait( 1.27 );
	smart_radio_dialogue( "shipg_orb_quiteastir" );
	wait( 0.96 );	
	smart_radio_dialogue( "shipg_bkr_handleourselves2" );
	wait( 3.25 );	
	level.baker enable_Pain();
	
	flag_wait( "new_canyon_combat_start" );
	wait( 4 );
	smart_radio_dialogue( "shipg_hsh_morediverstakeem" );
	wait( 5 );
	smart_radio_dialogue( "shipg_bkr_movethisway" );
}

fake_shellshock_sound()
{
	level.player thread play_loop_sound_on_entity( "scn_shipg_drowning_loop" );
	level waittill( "stop_shellshock" );
	level.player delaythread( 0.5, ::stop_loop_sound_on_entity, "scn_shipg_drowning_loop" );
	level.player play_sound_on_entity( "scn_shipg_drowning_end" );
}

trench_things_crashing()
{
	thread trench_lcs_crashing();
	array_thread( getentarray( "crashing_trigger", "targetname" ), ::crash_trigger_think );
	
	node = get_Target_ent( "trench_cars_node" );
	rig = spawn_anim_model( "cars" );
	cars = getentarray( "trench_crashing_cars", "targetname" );
	
	node thread anim_first_frame( [ rig ], "car_crash" );
	wait( 0.1 );
	foreach( car in cars )
	{
		car linkTo( rig, "tag_" + car.script_parameters );
		wait( 0.1 );
		collision = car get_linked_ents();
		array_thread( collision, ::trigger_EnableLinkTo );
		array_call( collision, ::linkTo, car );
		array_thread( collision, ::crash_model_damage );
	}
	
	rig Hide();
	
	trigger_wait_targetname( "car_crashing_trigger" );
	node thread anim_single( [ rig ], "car_crash" );
	org = rig getTagOrigin( "tag_car0" );
	rig thread play_sound_on_tag( "scn_shipg_car_fall", "tag_car0" );
	
	wait( 2.2 );
	PlayFXOnTag( getfx( "falling_car_bubbles" ), rig, "tag_car0" );
	thread play_sound_in_space( "scn_shipg_car_fall_debris", org );
	
	node waittill( "car_crash" );
	
	rig delete();
}

trench_lcs_crashing()
{
	node = get_Target_ent( "trench_cars_node" );
	
	lcs = get_target_ent( "lcs_crashing_animated" );
	lcs.animname = "lcs";
	lcs setAnimtree();
	lcs Hide();
	
	barge = get_target_ent( "barge_crashing_animated" );
	barge.animname = "barge";
	barge setAnimtree();
	
	linked = lcs get_linked_ents();
	array_call( linked, ::linkTo, lcs, "j_front" );
	
	fx_org = lcs spawn_tag_origin();
	fx_org linkTo( lcs, "j_front" );
		
	wait( 0.1 );
	
	node thread anim_first_frame( [lcs, barge], "lcs_crash" );
	flag_wait( "trench_lcs_crash" );
	
	lcs Show();
	node thread anim_single( [lcs, barge], "lcs_crash" );
	
	PlayFXOnTag( getfx( "lcs_front_lights" ), fx_org, "tag_origin" );
	PlayFXOnTag( getfx( "lcs_front_bubbles" ), fx_org, "tag_origin" );
	lcs thread play_sound_on_entity( "scn_shipg_lcs_fall" );
	
	flag_wait( "trench_lcs_hit_ground" );
	
	Exploder( 60 );
	
	flag_wait( "trench_lcs_hit_barge" );
	
	wait( 0.5 );
	for ( i=0; i<5; i++ )
	{
		glass = GetGlass( "barge_glass_" + i );
		DestroyGlass( glass, (0,0,-1) );
		wait( randomFloatRange( 0.05, 0.15 ) );
	}
	
	flag_wait( "start_new_canyon" );
	StopFXOnTag( getfx( "lcs_front_lights" ) , fx_org, "Tag_origin" );
	StopFXOnTag( getfx( "lcs_front_bubbles" ), fx_org, "tag_origin" );
	fx_org delete();
}

crash_trigger_think()
{
	models = getentarray( self.target, "targetname" );
	array_thread( models, ::crash_model_think );
	flag_wait( "trench_allow_things_to_crash" );
	self waittill( "trigger" );
	array_thread( models, ::send_notify, "trigger" );
}

crash_model_think()
{
	model = self;
	model hide();
	
	othermodels = model get_linked_ents();
	array_call( othermodels, ::Hide );
	
	model waittill( "trigger" );
	model crash_model_go( othermodels );
}

crash_model_go( othermodels )
{
	model = self;
	model show();
	array_call( othermodels, ::Show );	
	array_thread( othermodels, ::trigger_EnableLinkTo );
	array_call( othermodels, ::linkTo, model );
	array_thread( othermodels, ::crash_model_damage, model );
	
	speed = 20;
	accel = 0;
	decel = 0;
	
	p = model get_target_ent();
	sliding = false;
	
	fxorgs = [];
	
	if ( isdefined( model.script_soundalias ) )
		model thread play_sound_on_entity( model.script_soundalias );
	
	fxname = undefined;
	tagname = undefined;
	trailfx = false;
	spark_tag = undefined;
	
	noshake = false;
	
	if ( model.model == "shpg_machinery_baggage_container_dmg" )
	{
		model.fxorg = model;
		fxname = "falling_box_bubbles";
		tagname = "tag_origin";
		trailfx = true;
		noshake = true;
	}
	else if ( model.model == "vehicle_mi24p_hind_plaza_body_destroy_animated" )
	{
		spark_tag = spawn_tag_origin();
		spark_tag linkTo( model, "tag_origin", (28,152,-48), (0,0,0) );
		PlayFXOntag( getfx( "ship_wreckage_spark_underwater" ), spark_tag, "tag_origin" );
		fxname = "falling_box_bubbles";
		tagname = "tag_origin";
		trailfx = true;
	}
	else if ( model.model == "com_boat_fishing_1" )
	{
		self.fxorg = model spawn_tag_origin();
		self.fxorg linkTo( model );
		
		fxname = "falling_box_bubbles";
		tagname = "tag_origin";
		trailfx = true;
	}
	
	if ( trailfx )
		PlayFXOnTag( getfx( fxname ), model.fxorg, tagname );
	
	while ( isdefined( p ) )
	{
		if ( isdefined( p.speed ) )
			speed = p.speed;
		
		if ( isdefined( p.script_accel ) )
			accel = p.script_accel;
		
		if ( isdefined( p.script_decel ) )
			decel = p.script_decel;
		
		model moveTo_rotateTo_speed( p, speed, accel, decel );
		
		dist = Distance( level.player.origin, model.origin );
		
		if ( isdefined( p.script_flag_set ) )
			flag_set( p.script_flag_set );
		
		if ( isdefined( p.script_earthquake ) )
			thread do_earthquake( p.script_earthquake, model.origin );
		
		if ( isdefined( p.script_soundalias ) )
			model thread play_sound_on_entity( p.script_soundalias );
		
		if ( isdefined( p.script_fxid ) )
		{
			vec = -1*AnglesToUp( model.angles );
			if ( VectorDot( (0,0,-1), vec ) < 0.2 )
				vec = ( 0,0,-1 );
			
			trace = BulletTrace( model.origin, model.origin + (vec*500), false, model );
			
			fx_org = spawn_Tag_origin();
			fx_org.origin = trace[ "position" ];
			fx_org.angles = model.angles;
			fx_org linkTo( model );
			PlayFX( getfx( p.script_fxid ), fx_org.origin, (0,0,1), fx_org.origin - level.player.origin );
			fxorgs[ fxorgs.size ] = fx_org;
		}
		
		if ( isdefined( p.script_noteworthy ) && p.script_noteworthy == "crash" )
		{						
			if ( isdefined( p.target ) )
			{
				// sliding stuff
				sliding = true;
				vec = -1*AnglesToUp( model.angles );
				if ( VectorDot( (0,0,-1), vec ) < 0.2 )
					vec = ( 0,0,-1 );
				
				if ( isdefined( model.fxorg ) && model.fxorg != model )
				{
					model.sliding_fx_org = model.fxorg;
				}
				else
				{
					model.sliding_fx_org = spawn_Tag_origin();
					model.sliding_fx_org.origin = model.origin;
					model.sliding_fx_org.angles = model.angles;
					model.sliding_fx_org linkTo( model );
					fxorgs[ fxorgs.size ] = model.sliding_fx_org;
				}
				if ( !noshake )
					PlayFXOnTag( getfx( "boat_fall_slide" ), model.sliding_fx_org, "tag_origin" );
				model thread sliding_earthquake( p.script_earthquake );
				model PlayRumbleLoopOnEntity( "littoral_ship_rumble" );
			}
			
			if ( dist < 300 )
			{
				if ( isdefined( p.script_earthquake ) && p.script_earthquake != "small" )
					thread player_shake( dist );
				thread thrash_player( 300, 0.1, model.origin );
			}
		}
		
		if ( isdefined( p.target ) )
			p = p get_target_ent();
		else
			p = undefined;
	}
	
	if ( sliding )
	{
//		thread play_sound_in_space( "middle_boat_crash", model.origin );
		StopFXOnTag( getfx( "boat_fall_slide" ), model.sliding_fx_org, "tag_origin" );
		model StopRumble( "littoral_ship_rumble" );
		model notify( "stopped" );
		
		dist = Distance( level.player.origin, model.origin );
		if ( dist < 300 && !noshake )
		{
			Earthquake( 0.35, 0.7, model.origin, 1500 );
			level.player PlayRumbleOnEntity( "damage_heavy" );
			thread thrash_player( 300, 0.1, model.origin );
		}
	}

	if ( trailfx )
		StopFXOnTag( getfx( fxname ), model.fxorg, tagname );
	
	if ( isdefined( model.fxorg ) && model.fxorg != model )
		model.fxorg delete();
	
	array_thread( othermodels, ::send_notify, "stop_damage" );
	foreach( f in fxorgs )
		f delete();
	
	if ( model.model == "vehicle_mi24p_hind_plaza_body_destroy_animated" )
	{
		wait( 8 );
		StopFXOntag( getfx( "ship_wreckage_spark_underwater" ), spark_tag, "tag_origin" );
		spark_tag delete();
	}
}

player_shake( dist )
{
	if ( dist < 200 )
	{
		level.player PlayRumbleOnEntity( "damage_heavy" );
		level.player Shellshock( "nearby_crash_underwater", 3.5 );
		level.player thread delay_reset_swim_shock( 5 );
	}
	else if ( dist < 300 )
	{
		level.player PlayRumbleOnEntity( "damage_light" );
		level.player Shellshock( "nearby_crash_underwater", 2.5 );
		level.player thread delay_reset_swim_shock( 3 );
	}
	else
	{
		level.player PlayRumbleOnEntity( "damage_light" );
	}
}

sliding_earthquake( quakesize )
{
	self endon( "death" );
	self endon( "stopped" );
	
	dist = 512;
	
	if ( isdefined( quakesize ) )
	{
		switch( quakesize )
		{
			case "small":
				dist = 50;
				break;
		}
	}
	
	while( 1 )
	{
		Earthquake( 0.3, 0.2, self.origin, dist );
		wait( 0.1 );
	}
}

crash_model_damage( parent )
{
	if ( isdefined( parent ) && self.classname == "script_model" )
	{
		if ( self.model == "tag_origin" )
		{
			parent.fxorg = self;
			return;
		}
	}
	
	if ( self.classname != "script_brushmodel" && 
	    self.classname != "trigger_multiple" )
		return;
	
	self endon( "stop_damage" );
	
	if ( isdefined( self.damage ) )
		dam = self.damage;
	else
		dam = 60;
	
	while( 1 )
	{
		if ( level.player isTouching( self ) )
		{
			level.player doDamage( dam, self.origin );
			wait( 0.05 );
			continue;
		}
		wait( 0.1 );
	}
}

random_trench_falling()
{
	level endon( "new_canyon_combat_start" );
	
	level.ro_index = 0;
	structs = GetStructArray_delete( "new_trench_random" , "targetname" );
	
	while ( 1 )
	{
		s = random( structs );
		if ( Distance2d( s.origin, level.player.origin ) < 1000 )
		{
			wait( 0.1 );
			continue;
		}
		s thread generate_cheap_falling_object();
		wait RandomFloatRange( 3, 6 );
	}
}

generate_cheap_falling_object( speed, impact_exploder )
{
	trace = BulletTrace( self.origin, self.origin - (0,0,9999), false );
	model = Spawn( "script_model", self.origin );
	model setModel( random( level.debris ) );
	model.angles = ( RandomFloatRange(0,360), RandomFloatRange(0,360), RandomFloatRange(0,360) );
	model.target = "randomobject" + level.ro_index;
	modeltarget = Spawn( "script_origin", trace[ "position" ] - (0,0,30) );
	modeltarget.targetname = "randomobject" + level.ro_index;
	
	if ( !isdefined( speed ) )
		modeltarget.speed = RandomFloatRange( 200, 260 );
	else
		modeltarget.speed = speed;
	
	modeltarget.script_earthquake = "small";
	modeltarget.script_soundalias = "scn_shipg_box_fall_generic";
	modeltarget.script_noteworthy = "crash";
	modeltarget.target = modeltarget.targetname + "_2";
	modeltarget.angles = ( 0, 0, 0 );
	modeltarget.script_decel = 0.1;
	
	if ( isdefined( impact_exploder ) )
		modeltarget.script_exploder = impact_exploder;
	else
		modeltarget.script_fxid = "boat_fall_impact_small";
	
	level.ro_index = level.ro_index + 1;
	
	modeltarget2 = Spawn( "script_origin", modeltarget.origin - (0,0,80) );
	modeltarget2.speed = 30;
	modeltarget2.script_accel = 0.4;
	modeltarget2.targetname = modeltarget.targetname + "_2";
	modeltarget2.angles = model.angles;
	modeltarget.script_decel = 0.1;
	
	model crash_model_go( [] );
	wait( 0.5 );
	
	modeltarget delete();
	modeltarget2 delete();
	
	while( Distance2d( model.origin, level.player.origin ) < 800 && level.player player_looking_at( model.origin, 0.6, true ) )
		wait( 0.1 );
	
	model delete();
}

trigger_enablelinkto()
{
	if ( self.classname == "trigger_multiple" )
		self enableLinkTo();
}

trench_smash_death()
{
	flag_wait( "new_trench_smash_death" );
	player_smash_death();
}

trench_stay_close_1()
{
	level.player endon( "death" );
	level endon( "new_canyon_combat_start" );
	
	while( 1 )
	{
		if ( Distance( level.player.origin, level.baker.origin ) > 750 )
		{
			trench_death_warning();
			wait( 6 );
			if ( Distance( level.player.origin, level.baker.origin ) > 750 )
			{
				player_smash_death();
			}
				
		}
		
		wait( 0.1 );
	}
}

trench_death_warning()
{
	fwd = AnglesToForward( level.player.angles );
	org = level.player.origin - (fwd*64);
	PlayFX( getfx( "boat_fall_impact" ), org, (0,0,1), org - level.player.origin );
	thread play_sound_in_space( "middle_boat_crash", org );
	level.player PlayRumbleOnEntity( "damage_heavy" );
	Earthquake( 0.35, 0.7, org, 1500 );
	level.player ViewKick( 100, org );
	level.player PlayRumbleOnEntity( "damage_heavy" );
//	level.player thread maps\_gameskill::grenade_dirt_on_screen( "left" );
	level.player thread maps\_gameskill::blood_splat_on_screen( "bottom" );
	level.player delayThread( .1, ::playLocalSoundWrapper, "breathing_hurt" );
	//level.player delayThread( 1.25, ::playLocalSoundWrapper, "breathing_better" );
	level.player DoDamage( 30, org );
}

trench_stay_close_2()
{
	level.player endon( "death" );
	level endon( "new_canyon_combat_start" );
	
	while( 1 )
	{
		if ( Distance( level.player.origin, level.baker.origin ) > 1200 )
		{
			player_smash_death();
			return;
		}
		wait( 0.1 );
	}
}

player_smash_death()
{
	level.player notify( "smash_death" );
	thread trench_death_warning();
	wait( 0.25 );
	level.player kill();
}

/* ****** *
 * CANYON *
 * ****** */

start_canyon_combat()
{
	boats = spawn_vehicles_from_Targetname_and_drive( "new_canyon_boats_1" );
	array_thread( boats, ::trench_boat_think );
	flag_Wait( "new_canyon_combat_start" );
	
	autosave_by_name( "new_canyon" );
	level.baker set_force_color( "r" );
	
	baker_glint_off();
	
	array_spawn_targetname( "nc_enemies_1" );
	
	delaythread( 45, ::try_to_melee_player, "start_depth_charges" );
}

#using_animtree( "generic_human" );

trench_boat_think()
{
	self endon( "death" );
	self waittill( "reached_end_node" );
	
	trigger = get_Target_ent( self.script_noteworthy + "_trigger" );
	trigger trigger_off();
	
	flag_wait( "new_canyon_combat_start" );
	
	
	guys = array_spawn_targetname( self.script_noteworthy + "_guys" );
	array_thread( guys, ::canyon_jumper_setup );
	
	guys[0] waittill_either( "done_jumping_in", "death" );
	
	wait( RandomFloatRange( 1, 3 ) );
	
	level endon( "stop_killing_player" );
	level waittill( "never" );
	
	self thread boat_Shoot_entity( level.player, "stop_killing_player" );
	
	trigger trigger_on();
	while( 1 )
	{
		trigger waittill( "trigger", attacker );
		
		if ( attacker == level.player )
			break;
	}
	self notify( "stop_shooting" );
	spawner = get_target_ent( self.script_noteworthy + "_body" );
	guy = spawner spawn_ai( true );
	guy.origin = ( spawner.origin[0], spawner.origin[1], level.water_level_z + 5 );
	waitframe();
	org = spawner;
	
	fwd = AnglesToForward( org.angles );
	org.origin = org.origin + (fwd*16);

	guy thread magic_bullet_shield();
	guy.forceRagdollImmediate = true;
	guy.skipDeathAnim  = true;
	playFXONTag( getfx( "underwater_object_trail" ), guy, "tag_origin" );
	spawner thread anim_generic( guy, "death_boat_A" );
	wait( 1.5 );
	PlayFX( getfx( "jump_into_water_splash" ), org.origin );
	thread play_sound_in_space( "enemy_water_splash", org.origin );
	spawner waittill( "death_boat_A" );
	
	mover = guy spawn_tag_origin();
	guy linkTo( mover, "tag_origin" );

	weapon_model = getWeaponModel( guy.weapon );
	weapon = guy.weapon;
	if ( isdefined( weapon_model ) )
	{
		//self waittill_match_or_timeout( "deathanim", "end", 4 );
		guy detach( weapon_model, "tag_weapon_right" );
		org = guy gettagorigin( "tag_weapon_right" );
		ang = guy gettagangles( "tag_weapon_right" );
		gun = Spawn( "weapon_" + weapon, ( 0, 0, 0 ) );
		gun.angles = ang;
		gun.origin = org;
	}
	
	mover thread anim_generic_loop( guy, "death_boat_A_loop" );
	
	trace = BulletTrace( guy.origin - (0,0,200), guy.origin - (0,0,6000), false, guy );
	endpos = trace["position"];
	endpos = ( endpos[0], endpos[1], endpos[2] + 50 );
	mover moveTo_speed( endpos, 100, 0, 0 );
	stopFXONTag( getfx( "underwater_object_trail" ), guy, "tag_origin" );
	guy stop_magic_bullet_shield();
	guy startragdoll();
	guy unlink();
	mover notify( "stop_loop" );
	wait( 0.1 );
	mover delete();
	wait( 0.5 );
	guy kill();
}

canyon_jumper_setup()
{
	self endon( "death" );
	
	org = self get_target_ent();
	
	if ( isdefined( org ) )
	{
		if ( isdefined( org.target ) )
		{
			self waittill( "done_jumping_in" );
			org = org get_target_ent();
			self follow_path_and_animate( org, 0 );
		}
	}
}

hit_player_when_flag()
{
	level endon( "stop_killing_player" );
	
	while( 1 )
	{
		if ( flag( "trench_shoot_player" ) )
		{
			fwd = AnglesToforward( level.player.angles );
			pos1 = level.player GetEye() + (0,0,5) + fwd;
			pos2 = level.player GetEye();
			MagicBullet( "aps_underwater", pos1, pos2 );
		}
		wait( RandomFloatRange( 0.3, 0.5 ) );
	}
}
