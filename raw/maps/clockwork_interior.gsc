#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\clockwork_code;

clockwork_interior_pre_load()
{
	flag_init( "interior_finished" );
	flag_init( "interior_combat_finished" );
	flag_init( "interior_cqb_finished" );
	flag_init( "at_vault_door" );
	flag_init( "green_zone" );
	flag_init( "lights_on" );
	flag_init( "vault_blast_area" );
	flag_init( "approaching_vault_door" );
	flag_init( "drill_pickup_ready" );
	flag_init( "got_drill" );
	flag_init( "drill_safezone" );
	flag_init( "drill_toofar" );
	flag_init( "drill_spot1_ready" );
	flag_init( "drill1_start" );
	flag_init( "drill1_complete" );
	flag_init( "drill_spot2_ready" );
	flag_init( "drill2_start" );
	flag_init( "drill2_complete" );
	flag_init( "enable_charge" );
	flag_init( "glow_start" );
	flag_init( "thermite_start" );
	flag_init( "thermite_stop" );
	flag_init( "explosion_start" );
	flag_init( "start_pip_cams" );
	flag_init( "discovery_guys" );
	flag_init( "discovery_spawn" );
	flag_init( "start_discovery" );
	flag_init( "end_discovery" );
	flag_init( "attack_discovery_guys" );
	flag_init( "combat_start" );
	flag_init( "combat_guys1" );
	flag_init( "combat_sidehall" );
	flag_init( "combat_first_guys_dead" );
	flag_init( "combat_1_over" );
	flag_init( "combat_flee" );
	flag_init( "to_cqb" );
	flag_init( "to_cqb2" );
	flag_init( "catwalks_open" );
	flag_init( "kick_a_door" );
	flag_init("shut_catwalk_door");
	flag_init( "cqb_attack5" );
	flag_init("catwalk_melee_abort");
	flag_init( "cqb1_dead" );
	flag_init( "cqb2_dead" );
	flag_init( "cqb3_dead" );
	flag_init( "cqb4_dead" );
	flag_init( "cqb5_dead" );
	flag_init( "cqb6_dead" );
	flag_init( "cqb7_dead" );
	flag_init( "extra_guys_dead" );
	flag_init( "round_room_fight" );
	flag_init( "rotunda_cam" );
	flag_init( "thermite_started" );
	flag_init( "aud_drilling_door" );
	flag_init( "drill_attached" );
	flag_init( "starting_rotunda_kill" );
}

setup_interior_vault_scene()
{
	setup_player();
	spawn_allies();
//	setup_dufflebag_anims();

	level.player SwitchToWeapon( "ak47_silencer_reflex_iw6" );
	
	battlechatter_off("allies");
	battlechatter_off("axis");
	
	array_thread(level.allies, ::enable_cqbwalk);
	flag_set("lights_out");
	flag_set("FLAG_eyes_and_ears_complete");
	flag_clear("lights_on");
	
	// fake the lights turning off for now	
	vision_set_changes("clockwork_lights_off", 0);

	// set special nightvision visionset for when lights are off (no bloom)
	VisionSetNight( "clockwork_night" );
	level.player SetActionSlot( 1, "nightvision" ); // player can now use night vision
	
	thread maps\clockwork_audio::checkpoint_interior_vault_scene();
	level.player thread maps\_nightvision::nightVision_On();
	level.player NightVisionGogglesForceOn();

	
	flag_set("nvg_light_on");
	thread maps\clockwork_interior_nvg::player_light();
	
//	thread maps\clockwork_pip::pip_enable();
}

begin_interior_vault_scene()
{
	bloodstains = GetEntArray( "chaos_decals", "targetname" );
	foreach( blood in bloodstains )
		blood hide();
	
	level.drill_pickup = GetEntArray("pickup_drill", "targetname");
	array_thread(level.drill_pickup, ::safe_hide);
	
	disable_trigger_with_targetname("pickup_drill_trigger");

	setup_vault_door(true);
	setup_vault_props();

	
//	disable_trigger_with_targetname( "drill_spot1" );
//	disable_trigger_with_targetname( "drill_spot2" );

//  old vault scene
//	disable_trigger_with_targetname( "vault_charge_trig" );
//	thread vault_scene();
	thread new_vault_scene();
	
	//Wait for this section to finish.
	flag_wait( "interior_finished" );
	
	thread autosave_by_name("vault_open");
}

setup_vault_props()
{
	level.tablet_prop = spawn_anim_model("vault_tablet_prop");
	level.tablet = spawn_anim_model("vault_tablet");
	level.tablet linkto( level.tablet_prop , "J_prop_1" );
	level.tablet Hide();
	PlayFXOnTag( level._effect[ "vfx/moments/clockwork/vfx_vault_tablet_screen" ], level.tablet_prop, "J_prop_1" );
	
	level.thermite1 = spawn_anim_model("vault_thermite1");
	level.thermite2 = spawn_anim_model("vault_thermite2");
	level.thermite3 = spawn_anim_model("vault_thermite3");
	level.thermite1 Hide();
	level.thermite2 Hide();
	level.thermite3 Hide();

	level.charge1 = spawn_anim_model("vault_charge1");
	level.charge2 = spawn_anim_model("vault_charge2");
	level.charge1 Hide();
	level.charge2 Hide();

	level.drill_prop = spawn_anim_model("vault_drill_prop");
	if ( !IsDefined(level.drill_pickup) )
	{
		level.drill_pickup = GetEntArray("pickup_drill", "targetname");
	}
	level.drill_pickup[0] linkto( level.drill_prop , "J_prop_1", (0,0,0), (0,0,0) );
	level.drill_pickup[1] linkto( level.drill_prop , "J_prop_1", (0,0,0), (0,0,0) );
	
	level.vault_props = make_array( level.thermite1, level.thermite2, level.charge1, level.charge2);
	
	//spawn generic raven props and attach a model to it for scene.
	level.spool_prop = spawn_anim_model("vault_spool_prop");
	level.spool = spawn_anim_model( "vault_spool");
	level.spool linkto( level.spool_prop , "J_prop_1" );
	level.spool Hide();

	level.glowstick1_prop = spawn_anim_model("vault_glowstick1_prop");
	level.glowstick1 = spawn_anim_model( "vault_glowstick1");
	level.glowstick1 linkto( level.glowstick1_prop , "J_prop_1" );
	level.glowstick1 Hide();

	level.glowstick2_prop = spawn_anim_model("vault_glowstick2_prop");
	level.glowstick2 = spawn_anim_model( "vault_glowstick2");
	level.glowstick2 linkto( level.glowstick2_prop , "J_prop_1" );
	level.glowstick2 Hide();
	
}

vault_nvg_off_hint()
{
	/*
	while ( !(level.player GetCurrentWeapon() == "drill_press") )
	{
		wait 0.01;
	}
	wait 1;
	*/
	flag_wait("at_vault_door");
	
	level.player thread display_hint( "disable_nvg" );
	
	flag_wait("approaching_vault_door");
	
	while ( level.player IsSwitchingWeapon() )
	{
		wait 0.01;
	}
	
	thread nvg_goggles_off();
}

// =============================================================================================================
// ============================ NEW VAULT SCENE IMPLEMENTATION BELOW ===========================================
// =============================================================================================================


new_vault_scene()
{
	//thread maps\clockwork_audio::drill_listener();
	level.number = 1;
	level.drilled_good_line=0;

	flag_wait("FLAG_eyes_and_ears_complete");

	thread vault_vo();
	
	array_thread(level.allies, ::disable_ai_color);

	anim_loc = GetEnt("vault_door_scene", "targetname");

	level.allies[0].animname = "baker";
	level.allies[1].animname = "keegan";
	level.allies[2].animname = "cypher";
	
	anim_loc thread anim_reach_together(level.allies, "vault_approach");
	
	
	array_thread(level.allies, ::ally_animate_vault_scene);
	
	level.allies[0] waittill( "anim_reach_complete" );
	
	// temporary fix
	allguys = GetAIArray("axis");
	array_thread (allguys, ::die_quietly);
	thread vault_nvg_off_hint();

	thread animate_vault_door();
	thread maps\clockwork_audio::vault_foley();
	
	// ALLIES STARTED ANIM SEQUENCE

	// TEMP HAX FOR CRAPPY PIP FAKERY
//	thread maps\clockwork_pip::pip_disable();

	// SWITCH TO DRILL
//	level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_readythedrill");

	thread handle_misc_drill_details();

	wait 1;	
	autosave_by_name_silent("at_vault");

	flag_wait_or_timeout("vault_blast_area", 1);
	
	GetDrill();
//	SwitchToDrill();
	
	// TODO: ENCORPOORATE THIS INTO OTHER DRILL LOGIC FUNCS:
//	thread drill_in_hand();

	level.player_arms = spawn_anim_model( "player_rig" );
	level.player_arms hide();
	
	flag_wait("drill_spot1_ready");

	anim_loc thread anim_first_frame_solo(level.player_arms, "back1" );
	
	handle_drill_spot("drill_spot1", "drill1_start", "drill1_complete", "TAG_FX_XMark_RI");
	
	// animate player back from drill spot
	anim_loc thread anim_single_solo( level.player_arms, "back1");
//	wait 0.1;
	level.player AllowADS(false);
	level.player PlayerLinkToDelta(level.player_arms, "tag_player", 1,45, 45, 10, 10);
	level.player_arms waittillmatch("single anim", "end");
	level.player Unlink();
	level.player AllowADS(true);
	
	flag_wait("drill_spot2_ready");
	
	anim_loc thread anim_first_frame_solo(level.player_arms, "back2" );
	handle_drill_spot("drill_spot2", "drill2_start", "drill2_complete", "TAG_FX_XMark_LE");
	
	
	// animate player to follow keegan as he walks away	
	len = GetAnimLength(level.scr_anim[ "player_rig" ][ "back2" ]);
	anim_loc thread anim_single_solo( level.player_arms, "back2", undefined, len);
//	wait 0.1;
	level.player AllowADS(false);
	level.player PlayerLinkToDelta(level.player_arms, "tag_player", 1,45, 45, 10, 10);
	level.player_arms waittillmatch("single anim", "end");
	level.player Unlink();
	
	// take drill back from player
	level.player EnableWeaponPickup();
	level.player GiveWeapon( level.pre_drill_weapon );
	level.player SwitchToWeapon( level.pre_drill_weapon );
	level.player AllowADS(true);
	wait 1;
	level.player TakeWeapon( "drill_press" );
	level.player SetActionSlot( 1, "" ); //  disable "real" nightvision

	//start nagging player to leave door area
//	level.allies[0] thread char_dialog_add_and_go( "clockwork_bkr_backup2" );

	
	flag_wait("explosion_start");
	
/*	
	array_thread( level.allies, ::cqb_walk, "off");
	array_thread( level.allies, ::cool_walk, true);
*/
	array_thread(level.allies, ::enable_ai_color );
//	safe_activate_trigger_with_targetname( "move_away_from_vault" );
	
	// check to see if the player is near the vault door
	if ( flag("vault_blast_area") )
	{
		damage_org = GetEnt("smoke_spot", "targetname");
		level.player DoDamage(level.player.health - 5, damage_org.origin );
		level.player ShellShock("default", 5);
		level.player SetStance("prone");
		level.player PushPlayerVector((100,0,0), true);
		wait 0.2;
		level.player PushPlayerVector( (0,0,0), true);
	}
}

GetDrill()
{
	flag_wait("drill_pickup_ready");
	
	array_thread(level.drill_pickup, ::show_entity);
	enable_trigger_with_targetname("pickup_drill_trigger");
	
	flag_wait("got_drill");
	
	disable_trigger_with_targetname("pickup_drill_trigger");
	array_thread(level.drill_pickup, ::hide_entity);
	SwitchToDrill();
}

SwitchToDrill()
{
	level.pre_drill_weapon = level.player GetCurrentWeapon();
	level.player GiveWeapon( "drill_press" );
	level.player DisableWeaponPickup();
	level.player SwitchToWeapon("drill_press");
	level.player DisableWeapons();
	wait 0.75;
	level.player playsound ("clkw_scn_vault_drill_from_bag");
	level.player TakeWeapon(level.pre_drill_weapon);
	wait 0.5;
	level.player EnableWeapons();
	wait 1;
}

handle_drill_spot(trigger_name, activate_flag, complete_flag, x_tag)
{
	thread handle_drilling( complete_flag, activate_flag );
	
	drilling = false;
	attached = false;
	attach_hint = false;
	need_hint = true;
	need_drill_hint = true;
	hint = undefined;
	drill_hint = undefined;
	
	anim_loc = GetEnt("vault_door_scene", "targetname");

	audio_loc = Spawn( "script_origin",(0, 0, 0));
	audio_loc2 = Spawn( "script_origin",(0, 0, 0));
/*
	drill_spot = GetStruct( struct_name, "targetname" );
	playerOrg = spawn_tag_origin();
	playerOrg.origin = drill_spot.origin;
	playerOrg.angles = drill_spot.angles;
*/
	
	drill_cam = GetEnt("pip_xray_cam", "targetname");
	
	enable_trigger_with_targetname(trigger_name);
		
	while( !flag(complete_flag) )
	{
		if (!flag(activate_flag) || (attach_hint == true && level.player GetCurrentWeapon() != "drill_press" ) )
		{
			need_hint = true;
			need_drill_hint = true;
			attach_hint = false;
			
			if (IsDefined(hint))
			{
				hint hint_delete();
				hint = undefined;
			}
			if ( IsDefined(drill_hint) )
			{
				drill_hint hint_delete();
				drill_hint = undefined;
			}
		}
		
		flag_wait(activate_flag);
		
		if (need_hint)
		{
			need_hint = false;
			
			if (level.player GetCurrentWeapon() == "drill_press")
			{
				hint = hint_create(&"CLOCKWORK_HINT_DRILL");
				attach_hint = true;
			}
			else
			{
				hint = hint_create( &"CLOCKWORK_HINT_DRILL_SWITCH");
				
				level.player NotifyOnPlayerCommand( "LISTEN_switch_weapons", "weapnext" );
				level.player waittill("LISTEN_switch_weapons");
				
				need_hint = true;
				hint hint_delete();
				hint = undefined;
				
				wait 1.5;
			}
		}
		
		if ( ( level.player AdsButtonPressed() || level.player AttackButtonPressed()) && level.player GetCurrentWeapon() == "drill_press" && !(level.player IsSwitchingWeapon()) )
		{
			if (IsDefined(hint))
			{
				hint hint_delete();
				hint = undefined;
			}
			if (attached == false)
			{				
				// =======================================  PLAYER ATTACHES TO DOOR HERE =================================
				// move player into position
				level.frag_ammo = level.player GetWeaponAmmoStock("fraggrenade");
				level.flash_ammo = level.player GetWeaponAmmoStock("flash_grenade");
				level.player TakeWeapon( "fraggrenade" );
				level.player TakeWeapon( "flash_grenade" );

				level.player SetStance("stand");
				level.player AllowCrouch(false);
				level.player AllowProne(false);
				attached = true;
				
				level.player DisableWeaponSwitch();
				// LERP TO DRILL SPOT HERE
				level.player PlayerLinkToBlend(level.player_arms, "tag_player", 0.25);
				
//				level.player PlayerLinkToBlend( playerOrg, "tag_player", 0.3 );
				thread maps\clockwork_audio::drill_plant();
				level.player SetActionSlot( 1, "" ); //  disable "real" nightvision
			
				if ( level.drill_bink )
				{
					reset_tablet_screen();
				}
				else
				{
					// USED FOR CREATING THE BINK
					maps\clockwork_pip::pip_enable(drill_cam, undefined, undefined, undefined, undefined, 50, 50, 400, 225, "clockwork_pillar_room");

/*					
					// TEMP HAX FOR CRAPPY PIP FAKERY
					if ( trigger_name == "drill_spot1" )
					{
						maps\clockwork_pip::pip_enable(drill_cam, undefined, undefined, undefined, undefined, 120, 50, 220, 200, "vault_pip");
					}
					else
					{
						maps\clockwork_pip::pip_enable(drill_cam, undefined, undefined, undefined, undefined, 150, 20, 230, 210, "vault_pip");
					}
*/
				}
				wait 0.3;
				flag_set("drill_attached");
			}

			if (need_drill_hint)
			{
				if ( level.drill_bink )
				{
					drill_hint = hint_create( &"CLOCKWORK_HINT_DRILL");
				}
				need_drill_hint = false;
			}

			
			if ( level.player AttackButtonPressed() && level.player GetCurrentWeapon() == "drill_press" && !(level.player IsSwitchingWeapon()) )
			{
				if (IsDefined(drill_hint))
				{
					drill_hint hint_delete();
					drill_hint = undefined;
				}
				
				if (drilling == false)
				{
					level notify("started_drilling");
					thread ShowDrillHole(x_tag);
					
					if ( level.drill_bink )
					{
						// start drilling movie up
						PauseCinematicInGame(false);
					}
					
					drilling = true;
					PlayFXOnTag(level._effect["drill_sparks"], level.vault_door, x_tag );
					thread drill_progress_fx(x_tag);
					// start drilling sounds
					level.player playsound("clkw_scn_vault_drill_wind_up");
					audio_loc playloopsound ("clkw_scn_vault_drill_lp");
				}
			}
			else // if ( !(level.player AttackButtonPressed()) )
			{
				if (drilling == true)
				{
					if ( level.drill_bink )
					{
						//pause drilling movie
						PauseCinematicInGame(true);
					}
					drilling = false;
					StopFXOnTag(level._effect["drill_sparks"], level.vault_door, x_tag);
					level notify("kill_drill_progress_fx");
					stop_drilling_sounds(audio_loc, audio_loc2);
				}
				
			}
		}
		else // if ( !(level.player AdsButtonPressed()) )
		{
			if ( drilling == true )
			{
				drilling = false;
				StopFXOnTag(level._effect["drill_sparks"], level.vault_door, x_tag);
				level notify("kill_drill_progress_fx");
				thread stop_drilling_sounds(audio_loc, audio_loc2);
			}
			
			if (attached == true )
			{
				// ====================================    detach from door  ===================================
				restore_grenade_weapons();
				need_hint = true;
				need_drill_hint = true;
				attached = false;
				flag_clear("drill_attached");
				level.player Unlink();
				level.player thread play_sound_on_entity("clkw_scn_vault_drill_off_door");

				if (IsDefined(drill_hint))
				{
					drill_hint hint_delete();
					drill_hint = undefined;
				}
				
				level.player SetActionSlot( 1, "nightvision" ); // player can now use night vision

				if ( level.drill_bink )
				{
					reset_tablet_screen();
				}
				else
				{
					// TEMP HAX FOR CRAPPY PIP FAKERY
					maps\clockwork_pip::pip_disable();
				}

				level.player EnableWeaponSwitch();
				level.player AllowCrouch(true);
				level.player AllowProne(true);

			}
		}
			
		wait 0.01;
	}
	
	if ( drilling == true )
	{
		drilling = false;
		StopFXOnTag(level._effect["drill_sparks"], level.vault_door, x_tag);
		level notify("kill_drill_progress_fx");
		thread stop_drilling_sounds(audio_loc, audio_loc2);		
	}
			
	if (attached == true )
	{
		// detach from door
		restore_grenade_weapons();
		level.player Unlink();
		level.player thread play_sound_on_entity("clkw_scn_vault_drill_pullout");
		level.player SetActionSlot( 1, "nightvision" ); // player can now use night vision

		if ( level.drill_bink )
		{
			reset_tablet_screen();
		}
		else
		{
			// TEMP HAX FOR CRAPPY PIP FAKERY
			thread maps\clockwork_pip::pip_disable();
		}

		level.player EnableWeaponSwitch();
		level.player AllowCrouch(true);
		level.player AllowProne(true);
	}
	
	flag_clear("aud_drilling_door");
	
	disable_trigger_with_targetname(trigger_name);
	flag_set( activate_flag );
}

restore_grenade_weapons()
{
	level.player GiveWeapon( "fraggrenade" );
	level.player GiveWeapon( "flash_grenade" );
	level.player SetWeaponAmmoStock("fraggrenade", level.frag_ammo);
	level.player SetWeaponAmmoStock("flash_grenade", level.flash_ammo);
}



drill_fail_animation()
{
	pistons = [];
	pistons[0] = GetEnt("piston_01", "targetname");
	pistons[1] = GetEnt("piston_02", "targetname");
	pistons[2] = GetEnt("piston_03", "targetname");
	pistons[3] = GetEnt("piston_04", "targetname");
	
	cog = [];
	cog[0] = GetEnt("cog_01", "targetname");
	cog[1] = GetEnt("cog_02", "targetname");
	cog[2] = GetEnt("cog_03", "targetname");
	cog[3] = GetEnt("cog_04", "targetname");
	
	
	cog[0] RotatePitch(90, 1);
	cog[1] RotatePitch(90, 1.5);
	cog[2] RotatePitch(-90, 1);
	cog[3] RotatePitch(-90, 1.5);
	
	wait 0.25;
	foreach(piston in pistons)
	{
		piston MoveY(200, 0.5);
		wait 0.25;
	}
}


stop_drilling_sounds(audio_loc, audio_loc2)
{
	level.player playsound("clkw_scn_vault_drill_wind_down");
	wait(0.05);
	audio_loc stoploopsound ("clkw_scn_vault_drill_lp");
	audio_loc2 StopSounds();
}

reset_tablet_screen()
{
	if (level.drill_bink)
	{
		level endon("started_drilling");
		
		CinematicInGameSync("clockwork_vault_drill");	
		wait 0.2;
		PauseCinematicInGame(true);
	}
}

handle_drilling( complete_flag, activate_flag )
{
	flag_clear( "drill_safezone" );
	flag_clear( "drill_toofar" );
	
	safe_zone = 300;
	
	if ( level.drill_bink )
	{
		// fudge factor to make bink line up properly with sfx etc
		safe_zone += 50;
	}
	
	//safe_zone = 1;
	kill_zone = 550;
	kill_zone_warning = 450;
	level.backplate_sound_on = false;
	level.safezone_sound_on = false;
	audio_loc = Spawn( "script_origin",(0, 0, 0));
	audio_loc3 = Spawn( "script_origin",(0, 0, 0));
	drilled_good = false;

	drill_add_vec = (0,4,0);
	diff = 0;
	firstvo = 1;

	drill_ent = GetEnt( "pip_drill", "targetname" );
	drill_ang = drill_ent.angles;
	
	//drill starts all the way in so it gets lighting- pull it out and remember the pos.
	if ( IsDefined(level.drill_reset_pos) )
	{
		drill_pos = level.drill_reset_pos;
	}
	else
	{
		drill_pos = drill_ent.origin+ (0,-900,0);
		level.drill_reset_pos = drill_pos;
	}

	drill_ent.origin = drill_pos;
	drill_start_pos = drill_pos;

	about_to_win = false;
/*	
	cam = GetEnt("pip_xray_cam", "targetname");

	level notify("pip_static_off");
	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 80);
*/
	flag_clear("aud_drilling_door");

	while( !flag(complete_flag) && !flag("drill_toofar") )
	{
		flag_wait( activate_flag );

		if ( (level.player ADSButtonPressed() || level.player AttackButtonPressed() ) &&  level.player GetCurrentWeapon() == "drill_press" && !(level.player IsSwitchingWeapon()) )
		{
			if ( level.player AttackButtonPressed() )
			{
				flag_set( "aud_drilling_door" );
				drill_pos += drill_add_vec;
				drill_ent.angles += (45,0,0);
				drill_ent.origin = drill_pos;
				diff = (drill_pos - drill_start_pos)[1];
				
				if ( diff > safe_zone )
				{
					if (!drilled_good)
					{
						thread drilled_good_vo(complete_flag);
						level.player PlayRumbleOnEntity("drill_through");
						drilled_good = true;
//						level notify("stop_drilling_sounds");
						// play "YOU MADE IT" sound here
						level.player thread play_sound_on_entity("clkw_scn_vault_drill_safezone_beep");
					}
				}
				
				if ( diff <= safe_zone )
				{
					if (diff > (safe_zone - 50) && about_to_win == false )
				    {
						about_to_win = true;
						audio_loc3 playsound( "clkw_scn_vault_drill_safezone" );
						level notify("drill_progress_safe");
					}
					thread drillthrough_plate_sound(audio_loc, "clkw_scn_vault_drill_frontplate");
				}

				if(diff > kill_zone )
				{
					level notify("stop_drilling_sounds");
					//flag_set( "aud_stop_drill" );
					flag_set( "drill_toofar" );
					flag_set( "drill_safezone" );
					
					if ( !level.drill_bink )
					{
						thread drill_fail_animation();
					}
					
					level.player play_sound_on_entity("clkw_scn_vault_drill_gears");
					thread vault_fail_vo();
					
					thread screenshakeFade( 1, .5);
					level.player PlayRumbleOnEntity("drill_through");
					level.player PlayRumbleOnEntity("drill_through");
					if ( level.drill_bink )
					{
						IPrintLnBold( &"CLOCKWORK_QUOTE_BACKPLATE" );
						wait 1;
						MissionFailed();
					}
					else
					{
						wait 10;
					}
					break;
				}
				
				if(diff > kill_zone_warning )
				{
					thread drillthrough_plate_sound(audio_loc, "clkw_scn_vault_drill_backplate");
					level notify("drill_progress_danger");
				}

			}
			else
			{
				level notify("stop_drilling_sounds");
				
				if (diff > safe_zone && !flag(complete_flag) )
				{
					flag_set(complete_flag);
				}
			}
		}
		else
		{
			level notify("stop_drilling_sounds");
			flag_clear("aud_drilling_door");
			audio_loc3 stopsounds();
			
			// player let go of ADS, pull drill from wall
			drill_ent.origin = drill_start_pos;
			drill_pos = drill_ent.origin;
			about_to_win = false;
			
			if (diff > safe_zone )
			{
				flag_set(complete_flag);
				flag_set( "drill_safezone" );
			}
		}
		
		wait 0.05;
	}
	
	level notify("stop_drilling_sounds");
	//flag_set( "aud_stop_drill" );
	
/*
 	if ( !level.drill_bink )
	{
		wait 2;
		maps\clockwork_pip::pip_static();
	}
*/
	if (flag("drill_toofar"))
	{
		wait 100;
	}

	drill_ent.origin = 	level.drill_reset_pos;
}

vault_fail_vo()
{
	fail_vo = [];
	fail_vo[0] = "clockwork_cyr_toofar";
	fail_vo[1] = "clockwork_cyr_lockingdown";
	
		
	level.allies[2] char_dialog_add_and_go( fail_vo[RandomInt(fail_vo.size)] );
		
	level.allies[2] thread char_dialog_add_and_go( "clockwork_bkr_abortmission" );
}


drillthrough_plate_sound(audio_loc, sound)
{		
	if (level.backplate_sound_on == false)
	{
		level.backplate_sound_on = true;
		flag_wait("drill_attached");
		
		if ( level.player AttackButtonPressed() )
		{
		audio_loc playsound(sound);
	
		level waittill("stop_drilling_sounds");
		audio_loc StopSounds();
		}
		level.backplate_sound_on = false;
	}
}

handle_misc_drill_details()
{
	// stuff like keeping ammo replenished and playing drilling sounds when not on the door
	
	audio_loc = Spawn( "script_origin",(0, 0, 0));
	drilling = false;
	foley_forward_played = false;
	foley_back_played = false;

	while ( !flag("thermite_start") )
	{
		cur_weapon = level.player GetCurrentWeapon();
			

		if ( cur_weapon == "drill_press" && level.player AttackButtonPressed() )
		{
			waitframe();

			if ( drilling != true )
			{
				if ( !flag("aud_drilling_door") )
				{
				drilling = true;
				level.player playsound("clkw_scn_vault_drill_wind_up");
				audio_loc playloopsound ("clkw_scn_vault_drill_removed_lp");
			}
		}
		}
		else
		{
			if (drilling == true)
			{
				drilling = false;
				level.player playsound("clkw_scn_vault_drill_wind_down_removed");
				wait(0.05);
				audio_loc stoploopsound ("clkw_scn_vault_drill_lp");
			}
		}
		
		// keep drill full of ammo - HACK
		if ( cur_weapon == "drill_press" )
		{
			level.player GiveMaxAmmo( cur_weapon );
			
			if ( level.player AttackButtonPressed() )
			{
				// player is running the drill
				
				if ( (flag("drill1_start") || flag("drill2_start"))  && (level.player AdsButtonPressed() || level.player AttackButtonPressed() ) )
				{
					// attached to door, do heavier rumble
					thread screenshakeFade( .15, .5);
					level.player PlayRumbleOnEntity("drill_vault");
				}
				else
				{
					// not attached to anything
					thread screenshakeFade( .1, .5);
					level.player PlayRumbleOnEntity("drill_normal");
				}
			}
				

			// NOTE: not sure of the purpose or validity of the code below
			if ( level.player AdsButtonPressed() || level.player AttackButtonPressed() )	
			{
				if(foley_forward_played == false)
				{
					foley_back_played = false;
					foley_forward_played = true;
					thread maps\clockwork_audio::drill_pullout();	
				}
			}
			else
			{
				if(foley_back_played == false)
				{
					foley_back_played = true;
					foley_forward_played = false;
					thread maps\clockwork_audio::drill_pullout();	
				}
			}
		}
		
		wait 0.05;
	}
}
	
//drill_in_hand()
//{
//	while( !flag( "drill2_complete" ))
//	{
//		if ( level.player AttackButtonPressed() )
//		{
//			thread screenshakeFade( .1, .5);
//			level.player PlayRumbleOnEntity("light_1");
//		}
//		wait(0.05);
//	}
//}

get_animating_actors(actors, anime)
{
	animators = [];
	
	foreach (actor in actors)
	{
		if ( IsDefined(actor) && IsDefined(level.scr_anim[actor.animname][anime]) )
		{
			animators[animators.size] = actor;
		}
	}
	
	return animators;
}

ally_animate_vault_scene()
{
	anim_loc = GetEnt("vault_door_scene", "targetname");
	
	props = self ally_vault_props();
	actors = array_add(props, self);
	
	// wait for ally to get to anim start spot
	self waittill( "anim_reach_complete" );

	if  (self.animname == "cypher" && level.drill_bink )
	{
		SetSavedDvar( "cg_cinematicFullScreen", "0" );
		CinematicInGameLoopResident("clockwork_vault_still");
	}
	
	animators = get_animating_actors(actors, "vault_approach");
	anim_loc anim_single(animators, "vault_approach");

	if ( !flag("drill1_complete") )
	{
		animators = get_animating_actors(actors, "vault_loop1");
		anim_loc thread anim_loop(animators, "vault_loop1", "drill1_complete"+self.animname);
		flag_wait("drill1_complete");
		anim_loc notify( "drill1_complete"+self.animname );
//		waittillframeend;
	}
	
	// once player has drilled 1st hole
	animators = get_animating_actors(actors, "vault_betweener");
	anim_loc thread anim_single(animators, "vault_betweener");
	self waittillmatch("single anim", "end");

	if ( !flag("drill2_complete") )
	{
		animators = get_animating_actors(actors, "vault_loop2");
		anim_loc thread anim_loop(animators, "vault_loop2", "drill2_complete"+self.animname);
		flag_wait("drill2_complete");
		anim_loc notify("drill2_complete"+self.animname);
//		waittillframeend;
	}
	
	// once player has drilled 2nd hole
	animators = get_animating_actors(actors, "vault_finish");
	anim_loc anim_single(animators, "vault_finish");
	
	anim_loc thread anim_loop_solo(self, "vault_loop3", "loop3_complete"+self.animname);

	flag_wait("explosion_start");

	anim_loc notify("loop3_complete"+self.animname);
	animators = get_animating_actors(actors, "vault_exit");
	anim_loc anim_single(animators, "vault_exit");
}

animate_vault_door()
{
	anim_loc = GetEnt("vault_door_scene", "targetname");
	
	actors = make_array(level.vault_door);
	
/*	
	self waittill( "anim_reach_complete" );

	anim_loc anim_single(actors, "vault_approach");
	
	if ( !flag("drill1_complete") )
	{
		anim_loc thread anim_loop(actors, "vault_loop1", "drill1_complete_door");
		flag_wait("drill1_complete");
		anim_loc notify("drill1_complete_door");
		waittillframeend;
	}
	
	// once player has drilled 1st hole
	anim_loc anim_single(actors, "vault_betweener");
	level.pip notify( "stop_interference" );
	if ( !flag("drill2_complete") )
	{
		anim_loc thread anim_loop(actors, "vault_loop2", "drill2_complete_door");
		flag_wait("drill2_complete");
		anim_loc notify("drill2_complete_door");
		waittillframeend;
	}
*/
	flag_wait("drill2_complete");
	anim_loc notify("animate_vault");
	waittillframeend;
	// once player has drilled 2nd hole
	thread vault_ceiling_lights(anim_loc);
	
	wait 1;
	
	thread thermite_fx();
	flag_wait("glow_start");
	level.player thread display_hint( "disable_nvg" );
	
	thread maps\clockwork_audio::thermite();

	flag_wait("thermite_start");

	thread nvg_goggles_off();
	level.player SetActionSlot( 1, "" ); //  disable "real" nightvision

	anim_loc thread anim_single(actors, "vault_burn");
//	anim_loc anim_single(actors, "vault_burn");
//	flag_set("thermite_stop");
	
	flag_wait("explosion_start");
	anim_loc thread anim_single(actors, "vault_finish");
	
	thread turn_on_lights();

	toggle_visibility("vault_ceiling_structure", false);
	toggle_visibility("vault_ceiling_structure_damaged", true);
	toggle_visibility("vault_frame_damage", true);
	toggle_visibility("drill_hole_01", false);
	toggle_visibility("drill_hole_02", false);
	
	level.tablet_prop delete();
	level.tablet delete();
	level.thermite3 delete();
	foreach( prop in level.vault_props)
		prop delete();
	
	foreach (chalk in level.chalk_mark)
		chalk delete();
	
//	anim_loc anim_single(actors, "vault_finish");
	
	thread maps\clockwork_code::screenshakeFade(.45, 1.25, .25, .8);
		
	smoke_spot = getEnt("smoke_spot", "targetname");
	PlayFX(level._effect[ "vault_smoke" ], smoke_spot.origin);
	
	// TODO: Put charge explosions on actual charges rather than CreateFX
	exploder(1001);	// door blast.
	exploder(1005);	// sprinklers

	level.player GiveWeapon("fraggrenade");
	level.player GiveWeapon("flash_grenade");

	level.player SetWeaponAmmoClip( "fraggrenade", level.grenades );
	level.player SetWeaponAmmoStock( "fraggrenade", level.grenades);

	level.player SetWeaponAmmoClip( "flash_grenade", level.flashbangs );
	level.player SetWeaponAmmoStock( "flash_grenade", level.flashbangs);

	
	thread handle_pip_cams();
	flag_set("interior_finished");

//	wait 3;	
	//thread maps\clockwork_code::screenshakeFade(.45, 0.75, .1, 0.4);
	open_vault(false, anim_loc);
	
}

ally_vault_props()
{
	// each ally has his own props
	props = [];
	if ( self.animname == "cypher" )
	{
		props = make_array(level.tablet_prop);
	}
	if (self.animname == "baker" )
	{
		props = make_array( level.thermite1, level.thermite2, level.thermite3, level.glowstick1_prop, level.spool_prop);
	}
	if (self.animname == "keegan")
	{
		props = make_array( level.drill_prop, level.charge1, level.charge2, level.glowstick2_prop );
	}
	
	return props;
}

tablet_light_on(actor)
{
	PlayFXOnTag( level._effect[ "vfx/moments/clockwork/vfx_vault_tablet_screen" ], level.tablet_prop, "J_prop_1" );
//	IPrintLnBold("TABLET ON");
}

tablet_light_off(actor)
{
	StopFXOnTag( level._effect[ "vfx/moments/clockwork/vfx_vault_tablet_screen" ], level.tablet_prop, "J_prop_1" );
//	IPrintLnBold("TABLET OFF");
}


start_scan(actor)
{
	if (level.drill_bink)
	{
		thread maps\clockwork_audio::drill_monitor();
		CinematicInGameLoopResident("clockwork_vault_scan");
	}
}

stop_scan(actor)
{
	if (level.drill_bink)
	{
		CinematicInGameLoopResident("clockwork_vault_still");
	}
}

vault_ceiling_lights(struct)
{
	light_r = GetEnt("vault_ceiling_light_right", "targetname");
	light_l = GetEnt("vault_ceiling_light_left", "targetname");
	
	light_r.animname = "vault_light_r";
	light_r assign_animtree();
	
	light_l.animname = "vault_light_l";
	light_l assign_animtree();
	
	flag_wait("explosion_start");
	
	light_r thread animate_vault_light(struct);
	light_l thread animate_vault_light(struct);
	
}

animate_vault_light(struct)
{
	level endon("death");
	struct anim_single_solo(self, "light_explode");
//	struct thread anim_loop_solo( self, "light_loop");
}

// ------------------------------------------------------------------------------------------
// ------------------------------------ shared functions between old and new vault scenes
// ------------------------------------------------------------------------------------------

setup_vault_door(do_upright_idle)
{
	level.drill_bink = true;
	
	level.world_vault_door = GetEnt("model_vault_door","targetname");

	level.world_vault_door Delete();

	level.world_vault_clip = GetEnt("vault_door_clip","targetname");

	level.vault_door = spawn_anim_model("vault_door");
	level.vault_door.animname = "vault_door";
	
	if ( IsDefined(do_upright_idle) && do_upright_idle == true )
	{
		scene = GetEnt("vault_door_scene", "targetname");
		scene thread anim_loop_solo(level.vault_door, "vault_closed", "animate_vault");

		toggle_visibility("vault_ceiling_structure_damaged", false);
		toggle_visibility("vault_frame_damage", false);  // damaged bits around vault dor
		toggle_visibility("vault_frame_hotmetal", false);  // hot glowing bits from thermite
		toggle_visibility("vault_frame_destroyed_hotmetal", false);  // hot glowing bits from thermite
	}

// temp to just get these hidden for a build	
	level.chalk_mark = [];
	level.chalk_mark[0] = GetEnt("chalk_swipe_1a", "targetname");
	level.chalk_mark[1] = GetEnt("chalk_swipe_1b", "targetname");
	level.chalk_mark[2] = GetEnt("chalk_swipe_2a", "targetname");
	level.chalk_mark[3] = GetEnt("chalk_swipe_2b", "targetname");
	
	array_thread(level.chalk_mark, ::safe_hide);

	thread align_chalk_marks();
}

align_chalk_marks()
{
	wait 1;	
	
	chalk_pos = level.vault_door GetTagOrigin("TAG_FX_XMark_RI");
	level.chalk_mark[0].origin = chalk_pos;
	level.chalk_mark[1].origin = chalk_pos;
		
	level.fx_charge1_pos = spawn_tag_origin();
	level.fx_charge1_pos.origin = chalk_pos;

	chalk_pos = level.vault_door GetTagOrigin("TAG_FX_XMark_LE");
	level.chalk_mark[2].origin = chalk_pos;
	level.chalk_mark[3].origin = chalk_pos;
	
	level.fx_charge2_pos = spawn_tag_origin();
	level.fx_charge2_pos.origin = chalk_pos;
}

ShowDrillHole(x_tag)
{
	hole_pos = level.vault_door GetTagOrigin(x_tag);
	
	hole = GetEnt("drill_hole_01", "targetname");
	
	if (x_tag != "TAG_FX_XMark_RI")
	{
		hole = GetEnt("drill_hole_02", "targetname");
	}
	hole.origin = hole_pos;
}

safe_hide()
{
	if ( IsDefined(self) )
	{
		self Hide();
	}
}

chalk_swipe1(actor)
{
	thread maps\clockwork_audio::chalk_swipe1();
	level.chalk_mark[1] Show();
	wait 0.3;
	level.chalk_mark[0] Show();
}

chalk_swipe2(actor)
{
	thread maps\clockwork_audio::chalk_swipe2();
	level.chalk_mark[3] Show();
	wait 0.3;
	level.chalk_mark[2] Show();
}

turn_on_lights()
{
	wait 2;
	flag_set("lights_on");
	
	thread maps\clockwork_interior_nvg::nvg_area_lights_on_fx();
	exploder( 5 ); // light halos in vault hallway
	
	vision_set_changes("clockwork_indoor", 0);
	wait 0.05;
	vision_set_changes("clockwork_lights_off", 0);
	wait 0.1;
	vision_set_changes("clockwork_indoor", 0);
	wait 0.05;
	vision_set_changes("clockwork_lights_off", 0.1);
	wait 0.1;
	vision_set_changes("clockwork_indoor", 0);
	wait 0.05;
	vision_set_changes("clockwork_lights_off", 0.1);

	wait 0.5;

	vision_set_changes("clockwork_indoor", 0);
	wait 0.1;
	vision_set_changes("clockwork_lights_off", 0.2);
	wait 0.1;
	vision_set_changes("clockwork_indoor", 0);
	wait 0.05;
	vision_set_changes("clockwork_lights_off", 0.1);
	
	wait 0.6;

	vision_set_changes("clockwork_indoor", 0);
	wait 0.05;
	vision_set_changes("clockwork_lights_off", 0.1);
	wait 0.1;
	vision_set_changes("clockwork_indoor", 0);
	wait 0.1;
	vision_set_changes("clockwork_lights_off", 0.2);

	wait 0.65;
		
	vision_set_changes("clockwork_indoor", 0);
	wait 0.1;
	vision_set_changes("clockwork_lights_off", 0.2);
	
	wait 0.3;
	
	vision_set_changes("clockwork_indoor", 0.1);	

}

drill_progress_fx(x_tag)
{
	level endon("kill_drill_progress_fx");
	
	level waittill("drill_progress_safe");		// minimum drill depth to succeed
	PlayFXOnTag(level._effect["drill_progress1"], level.vault_door, x_tag );
	
	/*
	level waittill("drill_progress_warn");		// half maximum drill depth (matched with warning VO)
	PlayFXOnTag(level._effect["drill_sparks"], level.vault_door, x_tag );
	*/
	
	level waittill("drill_progress_danger");	// stop now, or you're going to fail
	PlayFXOnTag(level._effect["drill_progress2"], level.vault_door, x_tag );
}

thermite_fx()
{
	fx_thermite_fuse	= getfx("vfx/moments/clockwork/vfx_vault_thermite_fuse");	// thermite fuse FX
	fx_thermite_start	= getfx("vfx/moments/clockwork/vfx_vault_thermite_start");	// thermite burn FX
	fx_thermite_end		= getfx("vfx/moments/clockwork/vfx_vault_thermite_end");	// end thermite burn FX
	
	flag_wait("glow_start");
	
	// thermite fuse FX
	PlayFXOnTag(fx_thermite_fuse, level.thermite1, "tag_thermite_strip");	// top left
	wait 0.1;
	PlayFXOnTag(fx_thermite_fuse, level.thermite2, "tag_thermite_strip");	// bottom left
	wait 0.15;
	PlayFXOnTag(fx_thermite_fuse, level.thermite3, "tag_thermite_strip");	// mid right

	flag_wait("thermite_start");  // currently redundant, but leaving here in case we go back to note-tracked timings

	// stop thermite fuse FX & ignite thermite burn FX
	PlayFXOnTag(fx_thermite_start, level.vault_door, "TAG_FX_Thermite_Top_LE");
	PlayFXOnTag(fx_thermite_end, level.vault_door, "TAG_FX_Thermite_Top_LE");
	StopFXOnTag(fx_thermite_fuse, level.thermite1, "tag_thermite_strip");
	
	wait 0.25;
	
	PlayFXOnTag(fx_thermite_start, level.vault_door, "TAG_FX_Thermite_Bot_LE");
	PlayFXOnTag(fx_thermite_end, level.vault_door, "TAG_FX_Thermite_Bot_LE");
	StopFXOnTag(fx_thermite_fuse, level.thermite2, "tag_thermite_strip");
	
	wait 0.35;

	PlayFXOnTag(fx_thermite_start, level.vault_door, "TAG_FX_Thermite_Mid_RI");
	PlayFXOnTag(fx_thermite_end, level.vault_door, "TAG_FX_Thermite_Mid_RI");
	StopFXOnTag(fx_thermite_fuse, level.thermite3, "tag_thermite_strip");

	level waittill("thermite_stop");
	
	// stop thermite burn FX
	
	StopFXOnTag(fx_thermite_start, level.vault_door, "TAG_FX_Thermite_Top_LE");
	wait 0.25;
	
	StopFXOnTag(fx_thermite_start, level.vault_door, "TAG_FX_Thermite_Bot_LE");
	wait 0.5;
	
	StopFXOnTag(fx_thermite_start, level.vault_door, "TAG_FX_Thermite_Mid_RI");

	// melted steel FX
	
	//toggle_visibility("vault_frame_hotmetal", true);
   
	flag_wait("explosion_start");
	
	StopFXOnTag(fx_thermite_end, level.vault_door, "TAG_FX_Thermite_Top_LE");
	StopFXOnTag(fx_thermite_end, level.vault_door, "TAG_FX_Thermite_Bot_LE");
	StopFXOnTag(fx_thermite_end, level.vault_door, "TAG_FX_Thermite_Mid_RI");
	
			  
	
	// stop melted steel FX	
	
	// swap glowing bits for damaged bits
	//toggle_visibility("vault_frame_hotmetal", false);
	//toggle_visibility("vault_frame_destroyed_hotmetal", true);	// disabled until final glow solution is in place
}

breach_charge_fx_unhide(actor)
{
	fx_charge_warmup	= getfx("vfx/moments/clockwork/vfx_vault_charge_warmup");
	
	PlayFXOnTag(fx_charge_warmup, actor, "TAG_LIGHT");	// start red light fx
}

breach_charge_fx_set(actor)
{
	fx_charge_warmup	= getfx("vfx/moments/clockwork/vfx_vault_charge_warmup");
	fx_charge_set		= getfx("vfx/moments/clockwork/vfx_vault_charge_set");
	
	StopFXOnTag(fx_charge_warmup, actor, "TAG_LIGHT");	// stop red light fx
	PlayFXOnTag(fx_charge_set, actor, "TAG_LIGHT");		// start green light fx
}

breach_charge_fx_activate()
{
	fx_charge_warmup	= getfx("vfx/moments/clockwork/vfx_vault_charge_warmup");
	fx_charge_set		= getfx("vfx/moments/clockwork/vfx_vault_charge_set");
	fx_charge_activate	= getfx("vfx/moments/clockwork/vfx_vault_charge_activate");
	fx_charge_explode	= getfx("vfx/moments/clockwork/vfx_vault_charge_explode");
	
	StopFXOnTag(fx_charge_set, level.charge1, "TAG_LIGHT");		// stop green light fx
	StopFXOnTag(fx_charge_set, level.charge2, "TAG_LIGHT");		// stop green light fx
	
	PlayFXOnTag(fx_charge_activate, level.charge1, "TAG_LIGHT");		// start green blinking light fx
	PlayFXOnTag(fx_charge_activate, level.charge2, "TAG_LIGHT");		// start green blinking light fx
	
	flag_wait("explosion_start");
	
	// actual charge explosion
	PlayFXOnTag(fx_charge_explode, level.fx_charge1_pos, "tag_origin");
	wait 0.2;
	PlayFXOnTag(fx_charge_explode, level.fx_charge2_pos, "tag_origin");	
	
	wait 30;
	level.fx_charge1_pos delete();
	level.fx_charge2_pos delete();
}

open_vault(instant_open, anim_loc)
{
	if ( !IsDefined(anim_loc) )
	{
		anim_loc = GetEnt("vault_door_scene", "targetname");
	}

	
	if ( IsDefined(instant_open) && instant_open == true )
	{
		level.drill_pickup = GetEntArray("pickup_drill", "targetname");
		array_thread(level.drill_pickup, ::safe_hide);
		disable_trigger_with_targetname("pickup_drill_trigger");
		
		toggle_visibility("vault_frame_hotmetal", false);  // hot glowing bits from thermite
		toggle_visibility("vault_ceiling_structure", false);

//		anim_loc thread anim_single_solo(level.vault_door, "vault_finish");
// old vault door anim		
//		anim_loc thread anim_loop_solo(level.vault_door, "door_dead");
	}


	level.world_vault_clip NotSolid();
	level.world_vault_clip ConnectPaths();
	level.world_vault_clip delete();
	glass_destroy_targetname("post_vault_door_glass");
}

drilled_good_vo(finished_flag)
{
	vo_lines = [];
	vo_lines[0] = "clockwork_hsh_stopthatsgood";
	vo_lines[1] = "clockwork_cyr_farenough";
	vo_lines[2] = "clockwork_cyr_woahwoah";
	vo_lines[3] = "clockwork_cyr_rightthere";
//	vo_lines[3] = "clockwork_cyr_thatsgood";

	
	while ( !flag(finished_flag) && !flag("drill_toofar") )
	{
		level.player smart_radio_dialogue( vo_lines[level.drilled_good_line] );
		level.drilled_good_line++;
		if (level.drilled_good_line >= vo_lines.size)
		{
			level.drilled_good_line = 0;
		}
	}
}


vault_vo()
{
	baker = level.allies[0];
	keegan = level.allies[1];
	cypher = level.allies[2];

	level.drill_nag_num = 0;
	
	flag_wait("green_zone");
	
	level.grenades = level.player GetWeaponAmmoClip( "fraggrenade" );
	level.flashbangs = level.player GetWeaponAmmoClip( "flash_grenade" );

	level.player TakeWeapon("fraggrenade");
	level.player TakeWeapon("flash_grenade");

	
//	thread add_dialogue_line("Baker", "Scarecrow-One we’re in the green zone prepping Victor now.");
	baker char_dialog_add_and_go( "clockwork_bkr_preppingvictor" );
//	thread add_dialogue_line("Diaz", "Copy VooDoo, 30 seconds until power is restored.", "blue");
	level.player radio_dialog_add_and_go( "clockwork_diz_powerisrestored" );
//	wait 2;
//	thread add_dialogue_line("Baker", "Everyone in position, just like we’ve run a dozen times, keep it tight.");
//	baker char_dialog_add_and_go( "clockwork_bkr_runadozentimes" );
	cypher char_dialog_add_and_go("clockwork_cyr_breakseal");

	flag_wait_either("drill_spot1_ready", "drill1_start");
	
	if ( !flag("drill1_start") )
	{
		cypher char_dialog_add_and_go("clockwork_cyr_drillhere");
		thread drill_nag("drill1_start", "drill1_complete");
		flag_wait("drill1_start");
	}
	
//	cypher char_dialog_add_and_go("clockwork_cyr_backtrip");
//	cypher char_dialog_add_and_go("clockwork_cyr_crackthatandwere");
	cypher char_dialog_add_and_go("clockwork_hsh_theresabacktrip");
	
	flag_wait("drill1_complete");
	cypher char_dialog_add_and_go("clockwork_cyr_1stshell");
	keegan char_dialog_add_and_go("clockwork_kgn_settingcharge");
	cypher char_dialog_add_and_go("clockwork_cyr_number2");
	level.player radio_dialog_add_and_go( "clockwork_brv_20seconds" );
		
	flag_wait("drill_spot2_ready");
	cypher char_dialog_add_and_go("clockwork_cyr_yourspot");
	thread drill_nag("drill2_start", "drill2_complete");
	
	flag_wait("drill2_complete");
//	cypher char_dialog_add_and_go("clockwork_cyr_2nddown");
	cypher char_dialog_add_and_go("clockwork_hsh_hydraulicsealsaredown");
//	wait 1.25;
	keegan char_dialog_add_and_go("clockwork_kgn_armed");

//	flag_wait("glow_start");
	baker char_dialog_add_and_go("clockwork_bkr_ignitethermite");
	thread thermite_timing();
	
//	baker char_dialog_add_and_go("clockwork_bkr_gogglesoff");
	baker char_dialog_add_and_go("clockwork_bkr_backup2");	
	flag_wait("thermite_stop");
	wait(1);
	
	thread maps\clockwork_audio::blowit_beep();
	baker char_dialog_add_and_go("clockwork_bkr_blowit");

	thread breach_charge_fx_activate();
	wait 0.25;
	flag_set("explosion_start");
}

thermite_timing()
{	// 9.62 total
	wait 0.10;
	flag_set("glow_start");
	wait 1.36;
	flag_set("thermite_start");
	wait 6;
	flag_set("thermite_stop");
//	flag_wait("thermite_stop");
//	wait 2;
}

drill_nag(zone_flag, endon_flag)
{
	nagline = [];
	nagline[0] = "clockwork_cyr_drillit";
	nagline[1] = "clockwork_cyr_hitit";
	num = 0;
	
	wait 8;

	while ( !flag(zone_flag) && !flag(endon_flag) )
	{
		level.allies[2] char_dialog_add_and_go(nagline[level.drill_nag_num]);

		level.drill_nag_num++;
		if (level.drill_nag_num >= nagline.size)
		{
			level.drill_nag_num = 0;
		}
		
		wait 8;
	}
}

// =======================================================================================================================
// ==================    Interior combat Scripting Begins here ===========================================================
// =======================================================================================================================

setup_interior_combat()
{
	setup_player();
	spawn_allies();
	
	//setup_dufflebag_anims();

	level.player SwitchToWeapon( "ak47_silencer_reflex_iw6" );

	scene_org = GetEnt("vault_door_scene", "targetname");
	//nvg_teleport(false, scene_org);

	disable_trigger_with_targetname( "drill_spot1" );
	disable_trigger_with_targetname( "drill_spot2" );

//	disable_trigger_with_targetname( "vault_charge_trig" );
	setup_vault_door();
	open_vault(true);
	flag_set("lights_on");
	flag_set("interior_finished");
	
	// for testing
/#
	SetDvarIfUninitialized( "optional_objective", "0" );
	if ( GetDvar( "optional_objective" ) != "0" )
	{
		flag_set( "obj_optional_scientist_activated" );
		thread maps\clockwork_intro::optional_objective();
	}
#/
	
//	thread maps\clockwork_pip::pip_enable();
// TEMP COMMENTED OUT FOR ART DEBUGGING	
	thread handle_pip_cams();
	vision_set_changes("clockwork_indoor", 0);
	

	smoke_spot = getEnt("smoke_spot", "targetname");
	PlayFX(level._effect[ "vault_smoke" ], smoke_spot.origin);
	
	battlechatter_off("allies");
	battlechatter_off("axis");

	waitframe();

/*
 * OLD VAULT SCENE EXIT
	anim_loc = GetEnt("vault_door_scene", "targetname");

	level.allies[0].animname = "baker";
	level.allies[1].animname = "keegan";
	level.allies[2].animname = "cypher";
//	init_animated_dufflebags();
	anim_loc thread anim_single(level.allies, "vault_blast");
//	array_thread(level.allies, ::clean_up_animated_duffle);
*/
	thread maps\clockwork_audio::checkpoint_interior_combat();
	
}

begin_interior_combat()
{
	bloodstains = GetEntArray( "chaos_decals", "targetname" );
	foreach( blood in bloodstains )
		blood hide();
	
	flag_clear("player_dynamic_move_speed");

	thread blend_movespeedscale_custom(85,1);
	thread ambient_combat_guys();
	
	foreach (ally in level.allies)
	{
//		ally cool_walk(true);
		array_thread( level.allies, ::cqb_walk, "on");
		ally.old_baseaccuracy = ally.baseaccuracy;
		ally set_baseaccuracy(500);
		ally.ignoreall = false;
		ally.disableReactionAnims = true;
	}

	thread spawn_discovery_guys();

	thread handle_combat_guys();
	thread combat_handle_allies();
	thread handle_combat_guys2();
	thread resume_optional_objective();

	wait 3.5;
	thread combat_vo();
//	wait 3;
//	thread kill_ambient_guys();
	
//	flag_wait_or_timeout("discovery_guys", 5);
//	grunts = discovery_guys();
//	wait 1;
//	flag_set("attack_discovery_guys");
//	attack_targets(level.allies, grunts);
	
	flag_wait("discovery_guys");
/*	
	array_thread(level.allies, ::cool_walk, false);
	array_thread( level.allies, ::cqb_walk, "on");
*/
	//Wait for this section to finish.
	flag_wait("to_cqb2");
}

//kill_ambient_guys()
//{
//	guys = get_ai_group_ai("combat_ambients1");
//	thread ai_array_killcount_flag_set(guys, guys.size, "combat_start");
//
//	attack_targets(level.allies, guys, 1, 1, true);
//	
//	//fallback incase allies don't kill 'em fast enough
//	wait 2.5;
//	
//	foreach (guy in guys)
//	{
//		if ( IsDefined(guy) && IsAlive(guy) )
//		{
//			guy die();
//			wait 0.5;
//		}
//	}
//}


/*
discovery_guys()
{
	thread maps\clockwork_audio::door_break_music();
	
	level.discovery_guys = undefined;
	thread spawn_discovery_guys();
	
	discovery_anim_org = GetStruct("discovery_scene", "targetname");
	
	baker = level.allies[0];
	
	baker.animname = "baker";
	discovery_anim_org anim_reach_solo(baker, "discovery");

	premature_discovery = true;

	if ( !flag("discovery_spawn") )
	{
		flag_set("discovery_spawn");
		premature_discovery = false;	
	}
	
	while ( !IsDefined(level.discovery_guys) )
	{
		wait 0.1;
	}

	flag_set("start_discovery");	

	if (!premature_discovery)
	{
		level.discovery_guys[0].animname = "guard1";
		level.discovery_guys[0].allowdeath = true;
		level.discovery_guys[1].animname = "guard2";
		level.discovery_guys[1].allowdeath = true;

		guys = array_add(level.discovery_guys, baker);
	
//		baker place_weapon_on( baker.secondaryweapon, "right" );

		discovery_anim_org anim_single(guys,"discovery");
		grunts = array_removeDead_or_dying(level.discovery_guys);
		array_thread (grunts, ::die_quietly);
	}
	else
	{
		level.discovery_guys = array_removeDead_or_dying(level.discovery_guys);
		
		thread attack_targets(level.allies, level.discovery_guys, 0.5);
	}
	
	flag_set("end_discovery");
	baker enable_ai_color();
		
*/	
/*	
	spawner = GetEnt("discovery_leader", "targetname");
	leader = spawner spawn_ai(true);
	grunts = array_spawn_targetname_allow_fail("discovery_grunt", true);
	leader thread handle_leader();
	array_thread(grunts, ::handle_discovery_guy);
	
	thread ai_array_killcount_flag_set(grunts, 2, "combat_guys1_pre");
	thread ai_array_killcount_flag_set(grunts, grunts.size, "combat_first_guys_dead");

	return grunts;
*/
//}

spawn_discovery_guys()
{
	flag_wait("discovery_spawn");
	
	level.discovery_guys = array_spawn_targetname_allow_fail("discovery_grunt", true);
	thread ai_array_killcount_flag_set(level.discovery_guys, 2, "end_discovery");	

	struct = GetStruct("discovery_scene", "targetname");
	
//	flag_wait("discovery_guys");

	i = 1;
	
	foreach (guy in level.discovery_guys)
	{
		if (IsDefined(guy) && IsAlive(guy) && !guy doingLongDeath() )
		{
//			guy.animname = "generic";
			guy.allowdeath = true;
			guy.ignoreall = false;
			guy.animname = "discoverguy"+string(i);
			i++;
//			guy thread anim_generic(guy, "surprise_stop");
//			wait 0.3;
		}
	}
	
	struct thread anim_single(level.discovery_guys, "discover_vault");
	
	flag_wait_or_timeout("discovery_guys", 3);
	flag_set("discovery_guys");
	
	wait 1;
	
	attack_targets(level.allies, level.discovery_guys);
}

//handle_leader()
//{
//	self endon("death");
//	
//	self.allowdeath = true;
//	self anim_generic(self, "london_dock_soldier_walk_point");
///*	
//	while (self GetAnimTime( getGenericAnim("london_dock_soldier_walk_point") ) < 0.79)
//	{
//		wait (0.05);
//	}
//*/
//	self thread anim_generic(self, "london_station_civ2_reaction");
//	waitframe();
//	self SetAnimTime(level.scr_anim["generic"]["london_station_civ2_reaction"] ,0.66);
//	self waittillmatch("single anim", "end");
//	self delete();
//}

/*
handle_discovery_guy()
{
	self endon("death");
	self.allowdeath = true;

	self waittill("goal");
	self.animname = "generic";
	self anim_generic(self, "surprise_stop_v1");
	self.ignoreme = false;
	self.ignoreall = false;
}
*/

combat_handle_allies()
{
	flag_wait("end_discovery");
	safe_activate_trigger_with_targetname("allies_start_combat");

	flag_wait("combat_guys1");
	
	thread combat_allies_mainhall();
	
	flag_wait("combat_1_over");
	safe_activate_trigger_with_targetname("to_second_combat");
}

combat_allies_mainhall()
{
	flag_wait("combat_first_guys_dead");
	if ( !flag("combat_sidehall") )
	{
		safe_activate_trigger_with_targetname("combat_mainhall1");
	}
}
	                                    

handle_combat_guys()
{
	flag_wait_either("combat_guys1", "end_discovery");

	foreach (ally in level.allies)
	{
		ally set_baseaccuracy(ally.old_baseaccuracy);
	}
	
	battlechatter_on("allies");
	battlechatter_on("axis");
	
	guys = array_spawn_targetname_allow_fail("combat_guys1_pre", true);
	array_thread(guys, ::disable_careful);
	thread ai_array_killcount_flag_set(guys, 1, "combat_guys1");
	thread ai_array_killcount_flag_set(guys, guys.size, "combat_first_guys_dead");

	flag_wait("combat_guys1");
	
	guys = array_spawn_targetname_allow_fail("combat_guys1", true);
	thread ai_array_killcount_flag_set(guys, guys.size, "combat_1_over");

}


ambient_combat_guys()
{
	ambient_spawners = GetEntArray("pillar_ambient_guys", "targetname");
	array_thread(ambient_spawners, ::ambient_animate, false, "bogus", true);
}


//fight_at_goal()
//{
//	self waittill("goal");
//	self.ignoreall = false;
//}

handle_combat_guys2()
{
	// set guys up in the hall for camera
	flag_wait_any("combat_1_over", "combat_guys2");
	guys = array_spawn_targetname_allow_fail("combat_guys2_pre");
	
	waver_guy_spawners = GetEntArray("combat_guys2_waver", "targetname");
	foreach (spawner in waver_guy_spawners)
	{
		spawner thread ambient_animate(false, "start_combat2", false, false);
	}

	flag_wait("combat_guys2");
	
	guys = array_spawn_targetname_allow_fail("combat_guys2");
	
	thread combat_ambient_guys2();

	flag_wait_or_timeout("start_combat2", 5);
	
	level notify ("start_combat2");

	foreach (guy in guys)
	{
		if (IsAlive(guy))
		{
			guy.ignoreme = false;
			guy.ignoreall = false;
		}
	}

	wait 1;
	more_guys = array_spawn_targetname_allow_fail("combat_guys2b");
	waver_guys = get_ai_group_ai("waver_guy");
	allguys = array_combine(guys, more_guys);
	allguys = array_combine(allguys, waver_guys);
	allguys = array_removeDead_or_dying(allguys);
	
	thread ai_array_killcount_flag_set(allguys, allguys.size, "to_cqb");
	
	flag_wait("to_cqb");
		
	safe_activate_trigger_with_targetname("to_cqb");

	flag_wait("kick_a_door");

//	safe_activate_trigger_with_targetname("to_cqb2");
//	flag_set("to_cqb2");

}

//watch_player_for_combat(set_flag, ender_flag)
//{
//	while ( !flag(ender_flag) )
//	{
//		if ( level.player IsFiring() )
//		{
//			flag_set(set_flag);
//		}
//		wait 0.01;
//	}
//}

combat_ambient_guys2()
{
	flee_spawners = GetEntArray("flee_guy1", "targetname");
	array_thread(flee_spawners, ::ambient_animate, true);
	
	flag_wait("combat_flee");
	wait 2;
	flee_spawners = GetEntArray("flee_guy2", "targetname");
	array_thread(flee_spawners, ::ambient_animate, true);
	
}
	
//kick_a_door(script_struct, door_ent, rotation, dialog)
//{
//	struct = GetStruct(script_struct, "targetname");
//	door = GetEnt(door_ent, "targetname");
//	
//	struct anim_generic_reach(self, "doorkick_2_cqbrun");
//	
//	if ( IsDefined(dialog) )
//	{
//		level.allies[0] thread char_dialog_add_and_go(dialog);
//	}
//
//	struct thread anim_generic_run(self, "doorkick_2_cqbrun");
//	wait 3;
//	door RotateYaw(rotation, 0.75, 0, 0.25);
//	wait 1;
//	door ConnectPaths();
//	self enable_ai_color();
//
//}
//
//ai_use_door(script_struct, door_ent, animname, rotation, start_door_time, door_move_time, dialog, early_exit_time)
//{
//	struct = GetStruct(script_struct, "targetname");
//	door = GetEnt(door_ent, "targetname");
//	
//
//	struct anim_generic_reach(self, animname);
//	if (script_struct == "cqb_door_kick1")
//	{
//		thread maps\clockwork_audio::cqb_door_shove();
//	}
//	
//	if (script_struct == "cqb_door_kick2")
//	{
//		//thread maps\clockwork_audio::cqb_door_open_slow();		
//	}
//	
//	if ( IsDefined(dialog) )
//	{
//		level.allies[0] thread char_dialog_add_and_go(dialog);
//	}
//
//	struct thread anim_generic_run(self, animname);
//	
//	if ( IsDefined(early_exit_time) )
//	{
//		self thread kill_anim_at_time(early_exit_time);
//	}
//	
//	wait start_door_time;
//	door RotateYaw(rotation, door_move_time, 0, 0);
//	wait 1;
//	door ConnectPaths();
//	self enable_ai_color();
//}
//
//kill_anim_at_time(early_exit_time)
//{
//	wait (early_exit_time);
//	self anim_stopanimscripted();
//}


	

// =======================================================================================================================
// ==================    Interior CQB Scripting Begins here ===========================================================
// =======================================================================================================================

setup_interior_cqb()
{
	setup_player();
	spawn_allies();
	flag_set("to_cqb");

	disable_trigger_with_targetname("to_cqb");
//	setup_dufflebag_anims();
	vision_set_changes("clockwork_indoor", 0);

	level.player SwitchToWeapon( "ak47_silencer_reflex_iw6" );

//	thread maps\clockwork_pip::pip_enable();
	thread handle_cqb_pip_cams();
	
	thread maps\clockwork_audio::checkpoint_interior_cqb();
}

begin_interior_cqb()
{
	flag_set("aud_stop_interior_combat_pa");

	thread handle_cqb_enemies();
	thread handle_cqb_allies();
	//thread cqb_PA();
	thread spin_fans("interior_cqb_finished");

	// set up doors
	// player preventative exit clip
	exit_clip = GetEnt("cqb_exit_clip", "targetname");
	exit_clip NotSolid();

	//outside door	
	outside_door = GetEnt("cqb_exterior_door", "targetname");
	outside_door.animname = "cqb_ext_door";
	outside_door assign_animtree();

	outside_door_clip = GetEnt("combat_exit_door_clip2", "targetname");
	outside_door_clip linkto( outside_door );

	struct = Getstruct("cqb_door_kick1", "targetname");
	struct anim_first_frame_solo(outside_door, "slow_open_door");
	
	// inside door
	door_prop = spawn_anim_model("cqb_int_door");
	door_clip = GetEnt("combat_exit_door_clip1", "targetname");
	door = GetEnt("combat_exit_inside_door", "targetname");

	struct anim_first_frame_solo(door_prop, "bust_door");
	
	wait 0.01;
	
	door linkto( door_prop , "J_prop_1" );
	door_clip linkto( door_prop , "J_prop_1" );

	// open the door	
//	level.allies[2] ai_use_door("cqb_door_kick1", "combat_exit_door1", "bust_door", -90, 2.85, 0.75, "clockwork_bkr_throughhere");
	door_guy1 = level.allies[2];
	struct anim_generic_reach(door_guy1, "bust_door");

	thread maps\clockwork_audio::cqb_door_shove();
	level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_throughhere");

	struct thread anim_single_solo(door_prop, "bust_door");
	struct anim_generic_run(door_guy1, "bust_door");
	door_clip ConnectPaths();
	door_guy1 enable_ai_color();
	
	level.allies[0] thread door_closer_guy(door_prop, door_clip);
	level.allies[2] thread wait_at_slow_door();
	
	safe_activate_trigger_with_targetname("cqb_move_up4");
	
	// commented out because the gaz doesn't exist.
	thread ambient_road_vehicles();
	
	flag_wait( "interior_combat_finished" );
	
	thread rotunda_kill();
	thread start_rotunda_fight();

	thread autosave_by_name("pillar_room_complete");
	
	battlechatter_off("allies");
	battlechatter_off("axis");
	player_speed_percent(85);  

/*	
	flag_wait("cqb_guys5");

	array_thread( level.allies, ::cqb_walk, "on");
	
	foreach (ally in level.allies)
	{
		ally.old_baseaccuracy = ally.baseaccuracy;
		ally set_baseaccuracy(5);
		ally.disableReactionAnims = true;
	}
	
	flag_wait("cqb5_dead");
	array_thread(level.allies, ::disable_cqbwalk);
*/	
	flag_wait( "interior_cqb_finished" );
	
/*	
	allguys = GetAIArray("axis");
	array_thread (allguys, ::die_quietly);
*/
	thread autosave_by_name("cqb_finished");
	
/*	
	foreach (ally in level.allies)
	{
		ally.baseaccuracy = ally.old_baseaccuracy;
		ally.disableReactionAnims = false;
	}
*/
}

spin_fans(endon_flag)
{
	fans = GetEntArray("clk_fan_spin01", "targetname");
	offset = RandomFloatRange(-5.0, 5.0);
	while ( !flag(endon_flag) )
	{
		foreach (fan in fans)
		{
			fan RotatePitch(30 + offset, 0.25);
		}
		wait 0.25;
	}
	
	flag_set("aud_stop_fan_sound");
}
	
ambient_road_vehicles()
{
	flag_wait("interior_combat_finished");
	gaz = spawn_vehicle_from_targetname_and_drive("catwalk_gaz");
	gaz maps\_vehicle::vehicle_lights_on("running");
}

wait_at_slow_door()
{
	struct = Getstruct("cqb_door_kick2", "targetname");
	struct anim_generic_reach(self, "slow_open_door_idle");
	struct thread anim_generic_loop(self, "slow_open_door_idle", "stop_waiting");

	flag_wait("shut_catwalk_door");
	
	thread maps\clockwork_audio::cqb_door_open_slow();	
		
	struct notify("stop_waiting");

	struct = Getstruct("cqb_door_kick1", "targetname");

	outside_door = GetEnt("cqb_exterior_door", "targetname");
	outside_door.animname = "cqb_ext_door";
	outside_door assign_animtree();
	
	// Turn on catwalk FX
	thread maps\clockwork_fx::turn_effects_on("ch_industrial_light_02_on_red","fx/lights/bulb_single_offset_red");
    thread maps\clockwork_fx::turn_effects_on("clk_cargoship_wall_light_on","fx/lights/bulb_single_cargoship");
	exploder(200);
	exploder(850); //turn on vista mist
	exploder(6400); // turn on defend light fx

	outside_door_clip = GetEnt("combat_exit_door_clip2", "targetname");

	exploder(40); //snow door
	outside_door_clip NotSolid();
	outside_door_clip ConnectPaths();

	self.animname = "generic";
	struct thread anim_single_solo(outside_door, "slow_open_door");
	struct anim_single_run_solo(self, "slow_open_door");
	flag_set("catwalks_open");
	
	self enable_ai_color();
//	self ai_use_door("cqb_door_kick2", "combat_exit_door2", "slow_open_door", 90, 1.9, 1.5);
	blend_movespeedscale_custom(85,1);
	player_speed_percent(85);  
}

door_closer_guy(door_prop, door_clip)
{
	// get dude in position to shut the door
	struct = Getstruct("cqb_door_kick1", "targetname");
	struct anim_generic_reach(self, "shut_door_start");
	struct anim_generic(self, "shut_door_start");

	actors = make_array(self, door_prop);
	self.animname = "generic";
	
	if ( !flag("to_catwalks") )
	{
		struct thread anim_loop(actors, "shut_door_loop", "shut_door");
		flag_wait("to_catwalks");
		struct notify("shut_door");
	}
	flag_set("shut_catwalk_door");
	
	thread maps\clockwork_audio::cqb_door_close_behind();	

	exit_clip = GetEnt("cqb_exit_clip", "targetname");
	exit_clip NotSolid();
	
	self.animname = "generic";
	struct anim_single(actors, "shut_door_end");

	exit_clip = GetEnt("cqb_exit_clip", "targetname");
	exit_clip NotSolid();
		
	door_clip DisconnectPaths();
	self enable_ai_color();

//	self ai_use_door("cqb_door_shut", "combat_exit_door1", "shut_door", 90, 1.1, 0.6, undefined, 2.4);
	leftovers = GetAIArray("axis");
	array_thread (leftovers, ::die_quietly);
	
	guys = array_spawn_targetname_allow_fail("combat_run_past_guys", true);
	array_thread (guys, ::delete_on_path_end);
	array_thread (guys, ::pathrandompercent_set, 200);

	
	wait 5;
	guys = array_spawn_targetname_allow_fail("combat_run_past_guys2", true);
	array_thread (guys, ::delete_on_path_end);
	array_thread (guys, ::pathrandompercent_set, 200);
	
}

catwalk_melee()
{
	winner = level.allies[2];
	spawner = GetEnt("cqb_guys5", "targetname");
	
	loser = spawner spawn_ai(true);
	loser.ignoreme = true;
	
	wait 0.01;
	oldanimname = winner.animname;
	winner.animname = "winner";
	loser.animname = "loser";
	actors = make_array(winner, loser);
	
	anim_org = GetStruct("catwalk_melee_org", "targetname");
	
	anim_org thread anim_first_frame_solo(loser, "catwalk_melee");
	loser magic_bullet_shield();
	
	loser thread catwalk_melee_abort();
	winner.ignoreall = true;
	winner disable_arrivals();
	anim_org anim_reach_solo(winner, "catwalk_melee");

	if ( !flag("catwalk_melee_abort") )
	{
		loser notify("ambushing");
		winner.animname = "winner";
		loser.animname = "loser";

		anim_org thread anim_single(actors, "catwalk_melee");
		thread maps\clockwork_audio::locker_brawl();
		thread maps\clockwork_audio::locker_brawl_vo();

		wait 1.5;
		flag_set("cqb5_dead");

		winner waittillmatch("single anim", "end");
		loser stop_magic_bullet_shield();
		loser die_quietly();
	}
	winner.ignoreall = false;
	winner enable_arrivals();

	winner enable_ai_color();
	winner.animname = oldanimname;
	
	blend_movespeedscale_custom(100,1);
	player_speed_percent(100);  
}

catwalk_melee_glass_break( actor )
{
	glass_destroy_targetname("exterior_catwalk_glass01");
}

catwalk_melee_abort()
{
	self endon("ambushing");
	
	flag_wait("catwalk_melee_abort");
	
	waitframe();

	self anim_stopanimscripted();
	self stop_magic_bullet_shield();
	self thread anim_generic(self, "surprise_stop");
	self.ignoreall = false;
	self.ignoreme = false;
	wait 1;
	flag_set("cqb5_dead");
}

rotunda_kill()
{
	cypher = level.allies[2];
	struct = GetStruct("melee_moment", "targetname");
	
	flag_wait("rotunda_runners");
	
	grunts = array_spawn_targetname_allow_fail("run_squad2", true);
	array_thread (grunts, ::pathrandompercent_set, 200);
	array_thread (grunts, ::attack_if_provoked);
	
	wait 1;
	
	level.rotunda_knife = spawn("script_model", (0,0,0));
	level.rotunda_knife SetModel("weapon_commando_knife");
	level.rotunda_knife LinkTo(cypher, "tag_inhand", (0,0,0), (0,0,0) );
	level.rotunda_knife Hide();
		
	flag_wait("hold_fire");
	
	if (!flag("round_room_fight") )
	{		
		guys = array_spawn_targetname_allow_fail("rotunda_kill_guys", true);
		array_thread (guys, ::interrupt_rotunda_kill);
					  
		i=1;
		foreach (guy in guys)
		{
			guy.animname = "guard"+string(i);

			guy.grenadeawareness = 0;
			guy.allowdeath = true;
			guy.health = 1;
			guy.noDrop = true;
			
			if (i <= 2)
			{
				guy.health = 1;
				guy thread rotunda_kill_gun_sync();
			}
			i++;
		}
		
		struct anim_first_frame(guys, "rotunda_kill");
		
		flag_wait("rotunda_kill");

		thread handle_troll_player(guys);
		
		if (!flag("round_room_fight") )
		{
			cypher.animname = "cipher";
			cypher thread interrupt_ally_rotunda_kill();

			thread activate_rotunda_fight(struct, cypher);

			flag_wait_any("moved_into_rotunda", "starting_rotunda_kill");
			
			if ( !flag("starting_rotunda_kill") )
			{
				array_notify(guys, "cancel");
				array_delete(guys);
			}
			else
			{
				guys = array_add(guys, cypher);
				
				struct anim_single(guys, "rotunda_kill");
				
				level notify("rotunda_kill_done");
				
				wait 0.5;
				foreach (guy in guys)
				{
					if (IsAlive(guy))
					{
						guy.ignoreme = false;
						guy.ignoreall = false;
						guy enable_ai_color();
					}
				}
			}
		}
	}
	
	cypher enable_ai_color();
	disable_trigger_with_targetname("rotunda_allies0");
	safe_activate_trigger_with_targetname("rotunda_allies1");
}

activate_rotunda_fight(struct, cypher)
{
	struct anim_reach_solo(cypher, "rotunda_kill");

	flag_set("starting_rotunda_kill");
	
	thread maps\clockwork_audio::rotunda_kill();
}

handle_troll_player(guys)
{
	flag_wait("cqb_guys7");
	
	if (IsDefined(guys[0]) && IsAlive(guys[0]))
	{
		guys[0] notify("damage");
	}
	
	level notify("rotunda_kill_interrupted");
}

start_rotunda_fight()
{
	level waittill_any("rotunda_kill_done", "rotunda_kill_interrupted", "runner_killed");

//	guys = get_ai_group_ai("roundroom_runners");  // doesn't work for some reaso
	guys = GetAIArray("axis");
	
	array_notify(guys, "fight");

	wait 0.5;
	array_thread( level.allies, ::enable_ai_color);
}

rotunda_knife_stab(actor)
{
	actor.stabbed = true;
}

show_rotunda_knife(actor)
{
	level.rotunda_knife Show();
}

hide_rotunda_knife(actor)
{
	level.rotunda_knife Hide();
}

get_killed(guy)
{

	if ( !isalive( guy ) )
		return;

	guy.allowDeath = true;
	guy.a.nodeath = true;
	guy set_battlechatter( false );

	guy kill();
}

interrupt_rotunda_kill()
{
	level endon("rotunda_kill_done");
	
	self AddAIEventListener( "grenade danger"	 );
	self AddAIEventListener( "projectile_impact" );
	self AddAIEventListener( "silenced_shot"	 );
	self AddAIEventListener( "bulletwhizby"		 );
	self AddAIEventListener( "gunshot"			 );
	self AddAIEventListener( "gunshot_teammate"	 );
	self AddAIEventListener( "explode"			 );
	    
	self waittill_any( "ai_event", "death", "damage" );


	if ( !IsDefined(self) || !IsAlive(self) )
	{
		return;
	}

	level notify("rotunda_kill_interrupted");
	
	self.noragdoll = false;
	self anim_stopanimscripted();

	
	if (IsDefined(self.stabbed))
	{
///		self Die();
	}
	else
	{
		self pathrandompercent_set(0);
		self enable_ai_color();
		self gun_recall();

		wait 0.5;
		self.ignoreme  = false;

		wait 0.5;
		self.ignoreall = false;
	}
}

rotunda_kill_gun_sync()
{
	self gun_remove();
	
	gun = Spawn("script_model", self.origin );
	gun SetModel("weapon_ak47");
	gun Linkto(self, "tag_sync", (0,0,0), (0,0,0));
	
	self waittill_any("death", "damage", "cancel");
	
//	if ( IsDefined(self.stabbed) )
//	{
		gun delete();
//	}
}
	
interrupt_ally_rotunda_kill(guys)
{
	level waittill("rotunda_kill_interrupted");
	
	self anim_stopanimscripted();
	self.ignoreme = false;
	self.ignoreall = false;
	self enable_ai_color();
	
	disable_trigger_with_targetname("rotunda_allies0");
	safe_activate_trigger_with_targetname("rotunda_allies1");
}


cqb_encounter(start_flag, complete_flag, move_trigger, fighting_allies, enemy_spawners, attack_flag, snipe)
{
	flag_wait(start_flag);
	spawners = GetEntArray(enemy_spawners, "targetname");
	guys = [];
	foreach (spawner in spawners)
	{
		if ( IsDefined(spawner.animation) )
		{
			guys[guys.size] = spawner ambient_animate(false, "cqb_attack5" );
		}
	}
	guys = array_combine(guys, array_spawn_targetname_allow_fail(enemy_spawners));
	thread ai_array_killcount_flag_set(guys, guys.size, complete_flag);
	thread cqb_encounter_allies_move_up(complete_flag, move_trigger);
	
	if ( IsDefined(attack_flag) )
	{
		flag_wait(attack_flag);
	}
	else
	{
		wait 1;
	}
	
	thread attack_targets(fighting_allies, guys, undefined, undefined, snipe);
}

cqb_encounter_allies_move_up(move_flag, move_trigger)
{
	flag_wait(move_flag);
	safe_activate_trigger_with_targetname(move_trigger);
}

handle_cqb_allies()
{
//	thread cqb_encounter_allies_move_up("cqb3_dead", "cqb_move_up3");
	thread cqb_ally_vo();

	flag_wait("cqb5_dead");
//	array_thread (level.allies, ::set_baseaccuracy, 0.25);
	safe_activate_trigger_with_targetname("cqb_move_up5");

//	thread pre_rotunda_stop();
	
	flag_wait("cqb_guys6");
	
	wait 1;

	while (level.run_guy_count > 0 && !flag("moved_into_rotunda") )
	{
		wait 0.25;
	}
	
//	safe_activate_trigger_with_targetname("cqb_move_up6");
	
	flag_wait("cqb_guys7");
	flag_set("player_DMS_allow_sprint");
	
	thread blend_movespeedscale_custom(80, 1);
//	thread player_dynamic_move_speed();
	
	flag_wait("interior_cqb_finished");
//	flag_clear("player_dynamic_move_speed");
	blend_movespeedscale_custom(100,1);
	player_speed_percent(100);  
}

handle_cqb_enemies()
{
	first_two_allies = make_array(level.allies[0], level.allies[1]);

	flag_wait("cqb_guys5");
	thread catwalk_melee();
	
//	thread cqb_encounter("cqb_guys5", "cqb5_dead", "cqb_move_up5", level.allies, "cqb_guys5");

//	thread cqb_encounter("cqb_guys6", "cqb6_dead", "cqb_move_up6", level.allies, "cqb_guys6");

	flag_wait("round_room_fight");
	
	flag_wait("cqb_guys7");
	
	roundroom_guys = get_ai_group_ai("roundroom_runners"); 
	
	foreach (guy in roundroom_guys)
	{
		guy.ignoreme = false;
	}
	
	if ( roundroom_guys.size < 3)
	{
		// only spawn in new guys if runners have already cleared out

		thread ai_array_killcount_flag_set(roundroom_guys, roundroom_guys.size, "extra_guys_dead");
		thread cqb_encounter("cqb_guys7", "cqb7_dead", "cqb_move_up7", level.allies, "cqb_guys7");
	}
	else
	{
		flag_set("extra_guys_dead");
		thread ai_array_killcount_flag_set(roundroom_guys, roundroom_guys.size, "cqb7_dead");
		thread cqb_encounter_allies_move_up("cqb7_dead", "cqb_move_up7");
	}


	thread cqb_encounter("cqb_guys8", "interior_cqb_finished", "cqb_move_up8", level.allies, "cqb_guys8");

}

attack_if_provoked()
{
	self AddAIEventListener( "grenade danger"	 );
	self AddAIEventListener( "projectile_impact" );
	self AddAIEventListener( "silenced_shot"	 );
	self AddAIEventListener( "bulletwhizby"		 );
	self AddAIEventListener( "gunshot"			 );
	self AddAIEventListener( "gunshot_teammate"	 );
	self AddAIEventListener( "explode"			 );
	    
	self waittill_any( "ai_event", "fight", "damage");
	
	level notify("runner_killed");
	
	wait 1;
	
	if ( !IsDefined(self) || !IsAlive(self) )
	{
		return;
	}
	self notify( "stop_going_to_node" );
	self.ignoreall = false;
	self.ignoreme  = false;
	self SetGoalPos(self.origin);
	self pathrandompercent_set(0);
	self enable_ai_color();
	
	wait 0.1;
	
	if ( !flag("round_room_fight") )
	{
		// for when player is on catwalks
		self reassign_goal_volume(self, "round_room_alerted_volume");
	}
	else
	{	
		// for when player is in round room
		self reassign_goal_volume(self, "round_room_combat_volume");
	}
	
	level notify( "round_room_enemies_provoked" );
}

watch_for_round_room_combat()
{
	level endon("death");
	
	level waittill_any("round_room_enemies_provoked", "rotunda_kill_interrupted");
	
	flag_set("round_room_fight");
	
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_goinghot");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_pickitupboys");

	thread overheard_radio_chatter("clockwork_rs2_gunfirecatwalks", 1, "cqb7_dead");
	thread overheard_radio_chatter("clockwork_rs1_sendallunits", 2, "cqb7_dead");
	thread overheard_radio_chatter("clockwork_rs2_ontheway", 3, "cqb7_dead");
}


// =======================================================================================================================
// ================================== VO and PIP STUFF =======================
// =======================================================================================================================

combat_vo()
{
	delayThread(3, ::flag_set, "start_pip_cams");
//	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_nest4minutes" );
//	radio_dialog_add_and_go( "clockwork_diz_havecompany" );
	level.allies[0] char_dialog_add_and_go( "clockwork_mrk_frontdoorsopeneta" );
	radio_dialog_add_and_go( "clockwork_oby_bossyougottamess" );
	
	flag_wait("discovery_guys");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_weaponsfree");

	flag_wait("combat_guys1");
	wait 2;
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_eyeonlabs");
	
	//thread combat_PA();
	
	thread overheard_radio_chatter("clockwork_rs2_gunfirelevel1", 3, "combat_1_over");
	thread overheard_radio_chatter("clockwork_rs3_securitybreach", 4, "combat_1_over");
	
	flag_wait("combat_1_over");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_letsgo");

	thread overheard_radio_chatter("clockwork_rs3_intruderslevel2", 2, "combat_guys2");
	thread overheard_radio_chatter("clockwork_rs1_locksectordown", 3, "combat_guys2");
	thread overheard_radio_chatter("clockwork_rs4_engaginglevel2", 4, "combat_guys2");
	
	flag_wait("combat_guys2");
	wait 1;
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_getthatguy");
	
	flag_wait("combat_flee");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_headright");

	thread overheard_radio_chatter("clockwork_rs4_engaginglevel2", 1, "to_cqb");
	thread overheard_radio_chatter("clockwork_rs2_takethemalive", 2, "to_cqb");
	thread overheard_radio_chatter("clockwork_rs4_siberianuniforms", 3, "to_cqb");
	thread overheard_radio_chatter("clockwork_rs2_traitors", 4, "to_cqb");
	thread overheard_radio_chatter("clockwork_rs4_idontknow", 5, "to_cqb");
	
	
	flag_wait("start_combat2");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_boggeddown");

	thread overheard_radio_chatter("clockwork_rs4_requestassistance", 10, "to_cqb");
	thread overheard_radio_chatter("clockwork_rs2_evacuatingpersonnel", 11, "to_cqb");
	
	flag_wait("to_cqb");
	radio_dialog_add_and_go( "clockwork_dz_allclear" );
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_movemove");
}

cqb_ally_vo()
{
	flag_wait("shut_catwalk_door");
	radio_dialog_add_and_go("clockwork_dz_southcorridor");
	radio_dialog_add_and_go("clockwork_dz_tangoesconverging");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_exitingbree");
//	level.allies[2] char_dialog_add_and_go("clockwork_hsh_exitingthetreetaking");
	radio_dialog_add_and_go("clockwork_dz_minimalactivity");
	radio_dialog_add_and_go("clockwork_dz_offradar");
	
	flag_wait("cqb5_dead");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_watchthosecorners");


	flag_wait("hold_fire");
	radio_dialog_add_and_go("clockwork_bkr_hold");
	
	wait 3;
	flag_set("rotunda_kill");
	
//	radio_dialog_add_and_go("clockwork_bkr_dontseeus");

	wait 2;
	
//	flag_wait("rotunda_cam");
	
	thread overheard_radio_chatter("clockwork_rs2_squad1reportin", 2, "round_room_fight");
	thread overheard_radio_chatter("clockwork_rs2_squad3status", 4, "round_room_fight");
	thread overheard_radio_chatter("clockwork_rs2_confirmid", 6, "round_room_fight");
	

	wait 3;
	
	thread overheard_radio_chatter("clockwork_rs2_squadsunresponsive", 8, "round_room_fight");
	thread overheard_radio_chatter("clockwork_rs1_sendentirecompany", 10, "round_room_fight");
	thread overheard_radio_chatter("clockwork_rs2_yessir", 12, "round_room_fight");
	thread overheard_radio_chatter("clockwork_rs3_massivecasualties", 14, "round_room_fight");
	thread overheard_radio_chatter("clockwork_rs2_locateintruders", 16, "round_room_fight");
	
	flag_wait("cqb_guys7");

//	radio_dialog_add_and_go("clockwork_rs2_intrudersrotunda");
//	radio_dialog_add_and_go("clockwork_rs2_squadslevel4");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_wholebase");
		
	flag_wait("cqb7_dead");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_targetlocation");
	
	flag_wait_all("almost_there", "interior_cqb_finished", "extra_guys_dead");
	level.allies[0] char_dialog_add_and_go("clockwork_bkr_90secstonest");
}


handle_pip_cams()
{
	flag_wait("start_pip_cams");
//	thread maps\clockwork_pip::pip_enable();

/*
	cam = GetEnt("pip_cam_entry", "targetname");
	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 80);
	
	flag_wait("discovery_spawn");
	cam = GetEnt("pip_cam2", "targetname");
	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 70);
*/
	flag_wait_either("combat_guys1", "end_discovery");
//	cam = GetEnt("pip_cam4", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 60);
	radio_dialog_add_and_go( "clockwork_dz_patchyouin" );
	radio_dialog_add_and_go("clockwork_dz_squadofenemies");

	flag_wait("combat_1_over");
	wait 2;
//	cam = GetEnt("pip_cam3", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 70);
	radio_dialog_add_and_go("clockwork_dz_majoractivity");

	flag_wait("combat_flee");
//	cam = GetEnt("pip_cam6", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 70);
	
	thread handle_cqb_pip_cams();
}

handle_cqb_pip_cams()
{
	flag_wait("shut_catwalk_door");
			 
//	cam = GetEnt("pip_cam10", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 70);
	wait 5;
//	cam = GetEnt("pip_cam3", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 70);

	flag_wait("cqb_guys5");
//	cam = GetEnt("pip_cam5", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 60);

	flag_wait("cqb_guys6");
	grunts = array_spawn_targetname_allow_fail("run_squad1", true);
	level.run_guy_count = grunts.size;
	array_thread (grunts, ::pathrandompercent_set, 200);
	array_thread (grunts, ::delete_on_path_end, "round_room_enemies_provoked", ::run_guy_done);
	array_thread (grunts, ::attack_if_provoked);
	thread watch_for_round_room_combat();

	wait 1;
//	cam = GetEnt("pip_cam9", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 75);
//	radio_dialog_add_and_go("clockwork_dz_rotundacam");
	radio_dialog_add_and_go("clockwork_dz_tangoesmassing");
	level.allies[0] thread char_dialog_add_and_go("clockwork_bkr_takeitslow");
	flag_set("rotunda_cam");
	
	flag_wait("cqb_guys7");
//	cam = GetEnt("pip_cam9", "targetname");
//	maps\clockwork_pip::pip_set_entity(cam, undefined, undefined, undefined, 80);
}

run_guy_done()
{
	level.run_guy_count--;
}

//combat_PA()
//{
//	level endon("death");
//
//	
//	while ( !flag("interior_combat_finished") )
//	{
//		if ( flag("combat_guys2") )
//		{
//			loc = GetStruct("combat2_speaker", "targetname");
//
//			play_sound_in_space("clockwork_mpa_redalert", loc.origin);
//			play_sound_in_space("clockwork_mpa_level1", loc.origin);
//
//			if ( flag("to_cqb") )
//			{
//				loc = GetStruct("combat2_speakerb", "targetname");
//				
//				wait 1;
//				play_sound_in_space("clockwork_mpa_barisov", loc.origin);
//				wait 1;
//				play_sound_in_space("clockwork_mpa_stations", loc.origin);
//			}
//			else
//			{
//				if ( RandomInt(100) < 50)
//				{
//					if ( RandomInt(100) < 50)
//					{
//						play_sound_in_space("clockwork_mpa_securelocation", loc.origin);
//					}
//					else
//					{
//						play_sound_in_space("clockwork_mpa_quarters", loc.origin);
//					}
//				}
//				else
//				{
//					play_sound_in_space("clockwork_mpa_stations", loc.origin);
//				}
//			}
//		}
//		else if ( flag("combat_1_over") )
//		{
//			loc = GetStruct("combat1_speakerb", "targetname");
//
//			play_sound_in_space("clockwork_mpa_yellowalert", loc.origin);
//			play_sound_in_space("clockwork_mpa_report", loc.origin);
//		}
//		else
//		{
//			loc = GetStruct("combat1_speaker", "targetname");
//
//			play_sound_in_space("clockwork_mpa_yellowalert", loc.origin);
//			play_sound_in_space("clockwork_mpa_suscious", loc.origin);
//		}
//			
//		wait RandomIntRange(4,7);
//	}
//}
//
//cqb_PA()
//{
//	level endon("death");
//
//	flag_wait("cqb_guys7");
//	
//	defend_locs = getstructarray("defend_pa_speaker", "targetname");
//	cqb_locs = getstructarray("cqb_pa_speaker", "targetname");
//
//	while ( !flag("defend_finished") )
////	while ( !flag("interior_cqb_finished") )
//	{
//		
//		if ( !flag("interior_cqb_finished") )
//		{
//			locs = cqb_locs;
//		}
//		else
//		{
//			locs = defend_locs;
//		}
//		
//		loc = getClosest(level.player.origin, locs);
//		play_sound_in_space("clockwork_mpa_redalert", loc.origin);
//		wait 1;
//
//		loc = getClosest(level.player.origin, locs);
//		play_sound_in_space("clockwork_mpa_level4", loc.origin);
//		wait 1;
//
//		loc = getClosest(level.player.origin, locs);
//		if (RandomInt(100) > 50)
//		{
//			play_sound_in_space("clockwork_mpa_tacticalgear", loc.origin);
//		}
//		else
//		{
//			play_sound_in_space("clockwork_mpa_securelocation", loc.origin);
//		}
//
//		wait RandomIntRange(4,7);
//	}
//}

resume_optional_objective()
{
	flag_wait( "combat_guys2" );
	
	level endon( "to_catwalks" );
		
	intel2 = GetEnt( "optional_objective_clipboard", "targetname" );
	intel2_glow = GetEnt( "optional_objective_clipboard_glow", "targetname" );
	spawner = GetEnt( "scientist_obj", "targetname" );

	if ( !flag( "obj_optional_scientist_activated" ) )
	{
		intel2 Delete();
		intel2_glow Delete();
		spawner Delete();
		return;
	}
	
	intel2 Hide();
	intel2_glow Hide();
	
	spawner add_spawn_function( ::scientist_failed );
		
	flag_wait( "combat_flee" );
	
	scientist = spawner spawn_ai( true );
	scientist.animname = "generic";
	scientist.health = 9999;
	scientist thread scientist_vo();
	scientist thread anim_loop_solo( scientist, "scientist_idle", "stop_loop" );
	
	while ( true )
	{
		scientist waittill( "damage", amount, attacker );
		if ( IsDefined( attacker ) && attacker == level.player )
			break;
		else
			scientist.health = 9999;
	}
	
	scientist StopAnimScripted();
	scientist notify( "stop_loop" );
	scientist Kill();
	
	thread radio_dialog_add_and_go( "clockwork_mrk_secondarytargetkill" );
	
	intel2 Show();
	intel2_glow Show();
	intel2 MakeUsable();
	//"Press and hold [{+usereload}] to retrieve intel."
	intel2 SetHintString( &"CLOCKWORK_OPTIONAL_PICKUP" );
	intel2 waittill( "trigger" );
	
	flag_set( "obj_optional_scientist_complete" );
	
	intel2 Delete();
	intel2_glow Delete();
	spawner Delete();
}

scientist_vo()
{
	level endon( "obj_optional_scientist_complete" );
	level endon( "to_catwalks" );
	
	waittill_player_close_to_or_aiming_at( self, 500, 25 );
	
	radio_dialog_add_and_go( "clockwork_sci_pleasenodontshoot" );
	
	waittill_player_close_to_or_aiming_at( self, 200, 25 );
	
	radio_dialog_add_and_go( "clockwork_sci_ihaveafamily" );
}

scientist_failed()
{
	level endon( "obj_optional_scientist_complete" );
	
	flag_wait( "to_catwalks" );
	
	optional_obj = obj( "optional" );
	Objective_State( optional_obj, "failed" );
	
	waittillframeend;
	self Delete();
	
	intel2 = GetEnt( "optional_objective_clipboard", "targetname" );
	intel2_glow = GetEnt( "optional_objective_clipboard_glow", "targetname" );
	spawner = GetEnt( "scientist_obj", "targetname" );
	
	intel2 Delete();
	intel2_glow Delete();
	spawner Delete();
}
