#include maps\_utility;
#include common_scripts\utility;
//#include maps\_stealth_utility;
#include maps\flood_util;
#using_animtree("generic_human");

section_main()
{
	add_hint_string( "attack_hint", &"FLOOD_STEALTH_ATTACK", ::no_attack_hint );
	add_hint_string( "crouch_hint", &"FLOOD_CROUCH_HINT", ::no_crouch_hint );
}

section_precache()
{
	PreCacheItem( "flood_knife" );
	PrecacheModel( "viewmodel_bowie_knife" );
	PreCacheString( &"FLOOD_STEALTH_FAIL0" );
	PreCacheString( &"FLOOD_STEALTH_FAIL1" );
	PreCacheString( &"FLOOD_STEALTH_FAIL2" );
	PrecacheModel( "com_hatchet" );
}

section_flag_inits()
{
	flag_init( "stealth_attack_player" );
	flag_init( "stealth_kill_01_done" );
	flag_init( "player_start_stealth_kill_02" );
	flag_init( "stealth_kill_02_done" );
	flag_init( "stealth_player_touching" );
	flag_init( "hatchet_linked" );
	flag_init( "stealth_enemy_3_dead" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

roof_stealth_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "roof_stealth_start" );
	
	//set_audio_zone( "flood_stealth_int", 2 );
	
	// spawn the allies
	maps\flood_util::spawn_allies();
	level.allies[ 0 ] gun_remove();
	
	level.allies[ 0 ] thread ally0_main();

	// take your primaries when you get swept away
	weaplist = level.player GetWeaponsListPrimaries();
	foreach( weap in weaplist )
		level.player TakeWeapon( weap );

//	level.player GiveWeapon( "flood_knife" );
//	level.player SwitchToWeapon( "flood_knife" );
	level.player DisableOffhandWeapons();
	maps\flood_util::setup_default_weapons( true );
	
	// FIX JKU need to find a better way to do this.  just want to hide the offhand weapon ammo, not the compass
	// JKU maybe this is the best way now...
	SetSavedDvar( "ammoCounterHide", 1 );
//	level.player HideHud();
//	SetSavedDvar( "compass", 0 );
//	SetSavedDvar( "actionSlotsHide", 1 );
//	SetSavedDvar( "hud_showStance", 0 );
//	SetSavedDvar( "hud_drawhud", 0 );
	
	// hide swept away moment water
	//thread maps\flood_swept::swept_water_toggle( "noswim", "hide" );
	thread maps\flood_swept::swept_water_toggle( "swim", "show" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "hide" );
	
	VisionSetNaked("flood_stealth", 0);
		fog_set_changes( "flood_stealth", 0 );
	 	level.cw_vision_above = "flood_stealth";
	 	level.cw_fog_above = "flood_stealth";
}

roof_stealth()
{
	level thread autosave_now();
	
	//set_audio_zone( "flood_stealth_int", 2 );
		
	// start checking if the player is in water
	thread maps\flood_coverwater::register_coverwater_area( "coverwater_stealth", "skybridge_done" );
	level.cw_player_in_rising_water = false;
	level.cw_player_allowed_underwater_time = 30;

	// this should start any debris we want floating and bobbing
	thread float_stuff();
	// get rid of the knife and give you access to your offhands once you've picked something up
	thread check_for_weapon_pickup();
	thread firstframe_stealth_debris();
	//thread maps\flood_fx::fx_swept_underwater_fx_on();
	//thread maps\flood_fx::fx_swept_underwater_fx_off();
	
	// turn back on the health overlay which was turned off for the roof collapse
	level.player thread maps\_gameskill::healthOverlay();
	level.cover_warnings_disabled = undefined;
	
	// if you have all your grenade ammo, take 1 so you pick up the satchel
	grenade_ammo = level.player GetFractionMaxAmmo( "fraggrenade" );
	if( grenade_ammo == 1 )
	{
		ammo = level.player GetWeaponAmmoClip( "fraggrenade" );
		level.player SetWeaponAmmoClip( "fraggrenade", ( ammo - 1 ) );
	}
	
	level.player GiveWeapon( "flood_knife" );
	level.player SwitchToWeaponImmediate( "flood_knife" );

	flag_wait( "stealth_kill_02_done" );
	
	level notify( "onto_skybridge" );
}

ally0_main()
{
//	self thread maps\flood_coverwater::ai_setup_for_coverwater( "skybridge_player_outside" );
	
	self clear_force_color();
	self.ignoreall = 1;
	self PushPlayer( true );
	self set_ignoreme( true );
	
	self thread ally0_instruction_vo_table();
	
	thread stealth_kill_01();
	flag_wait_any( "stealth_kill_01_done", "player_start_stealth_kill_02" );

	if( !flag( "player_start_stealth_kill_02" ) )
	{
		node = GetEnt( "stealth_kill_01", "targetname" );
		// hack to keep hatchet from flipping and spinning around
//		self.hatchet Unlink();
		node thread maps\_anim::anim_loop_solo( self, "stealth_kill_idle", "stop_idle" );
//		delayThread( 0.15, ::give_hatchet );
		
		level waittill( "player_start_stealth_kill_02" );
		node notify( "stop_idle" );
	}
	
	// MJS<NOTE> need to setup teleport trigger.
	level thread maps\flood_anim::skybridge_doorbreach_setup();
	
	self stealth_kill_02_ally();

	self PushPlayer( false );
	self gun_recall();
	self set_force_color( "r" );
	
	ent = GetEnt( "stealth_hall_clip", "targetname" );
	ent Hide();
	ent NotSolid();
}

ally0_instruction_vo( guy )
{
	guy endon( "death" );
	level endon( "stealth_attack_player" );
	level endon( "player_start_stealth_kill_02" );
	level endon( "player_passed_table" );

	if( !flag( "player_passed_table" ) )
	{
		if( flag( "cw_player_underwater" ) )
		{
			//Vargas: Get below the water and sneak up on them.
			radio_dialogue( "flood_vrg_onlytwomoreup" );
		}
		else
		{
			//Vargas: Only two more up ahead. You go straight, I'll flank around.
			guy dialogue_queue( "flood_diz_yougoleft" );
		}
	
		wait 3;
		
		nags = [];
		//Vargas: Get below the water to sneak up on them.
		nags[ 0 ] = "flood_diz_getbelow";
		//Vargas: Go underwater and we'll get the jump on them.
		nags[ 1 ] = "flood_diz_gounderwater";

		nags_underwater = [];
		//Vargas: Get below the water to sneak up on them.
		nags_underwater[ 0 ] = "flood_vrg_getbelowthewater";
		//Vargas: Go underwater and we'll get the jump on them.
		nags_underwater[ 1 ] = "flood_vrg_gounderwaterandwell";

		guy thread play_nag_stealth( nags, nags_underwater, "player_passed_table", 8, 1, 1.5 );
	}
}

play_nag_stealth( nags, nags_underwater, flag, initial_time, steps, multiplier )
{
	self endon( "death" );
	self endon( "stop nags" );
	
	time = initial_time;
	max_time = 30;
	
	cur_step = 0;
	while( !flag( flag ) )
	{
		if( flag( "cw_player_underwater" ) )
		{
			nag = nags_underwater[ RandomInt( nags_underwater.size ) ];
			radio_dialogue( nag );
		}
		else
		{
			nag = nags[ RandomInt( nags.size ) ];
			self dialogue_queue( nag );
		}
		
		wait RandomFloatRange( ( time * 0.8 ), ( time * 1.2 ) );

		if( max_time > time )
		{
			cur_step += 1;
			
			if( cur_step == steps )
			{
				cur_step = 0;
				time *= multiplier;
				
				if( max_time < time )
				{
					time = max_time;
				}
			}
		}
	}
}


ally0_instruction_vo_table()
{
	self endon( "death" );
	level endon( "stealth_attack_player" );
	level endon( "player_start_stealth_kill_02" );
	
	flag_wait( "player_passed_table" );
	
	//Vargas: We'll take them out on your mark.
	radio_dialogue( "flood_vrg_welltakethemout" );
}
	
ally0_instruction_vo_holdup( guy )
{
	if( !flag( "player_passed_table" ) )
	{
		if( flag( "cw_player_underwater" ) )
		{
			//Vargas: Hold up.
			radio_dialogue( "flood_vrg_holdup_2" );
		}
		else
		{
			//Vargas: Hold up.
			guy thread dialogue_queue( "flood_vrg_holdup" );
		}
	}
}

	roof_stealth_create_enemies()
{
	stealth_enemy_1_spawner = GetEnt( "stealth_enemy_1", "targetname" );
	stealth_enemy_1_spawner add_spawn_function( ::roof_stealth_enemy_spawn_func, "stealth_kill_02_done" );
	stealth_enemy_1 = stealth_enemy_1_spawner spawn_ai();
	level.stealth_enemy_1 = stealth_enemy_1;
	stealth_enemy_1.animname = "stealth_enemy_flash";

	stealth_enemy_2_spawner = GetEnt( "stealth_enemy_2", "targetname" );
	stealth_enemy_2_spawner add_spawn_function( ::roof_stealth_enemy_spawn_func, "stealth_kill_02_done" );
	stealth_enemy_2 = stealth_enemy_2_spawner spawn_ai();
	level.stealth_enemy_2 = stealth_enemy_2;
	stealth_enemy_2.animname = "stealth_enemy_debris";
	
	stealth_enemy_3_spawner = GetEnt( "stealth_enemy_3", "targetname" );
	stealth_enemy_3_spawner add_spawn_function( ::roof_stealth_enemy_spawn_func, "stealth_enemy_3_dead" );
	stealth_enemy_3 = stealth_enemy_3_spawner spawn_ai();	
	level.stealth_enemy_3 = stealth_enemy_3;
	stealth_enemy_3.animname = "stealth_enemy_3";
}

roof_stealth_enemy_spawn_func( endflag )
{
	// animset must come first, certainly before cqbwalk
//	self maps\flood_coverwater::ai_setup_for_coverwater( endflag );
	self thread enable_cqbwalk();
	self magic_bullet_shield( true );
	self.favoriteenemy = level.player;	
	self.aggressivemode = 1;
	self disable_surprise();
	self disable_pain();
	self setEngagementMinDist( 0, 0 );
	self setEngagementMaxDist( 64, 64 );
	self.fixednode = 0;

	rnd_playbackrate = RandomFloatRange( 0.7, 0.75 );
	self.moveplaybackrate = rnd_playbackrate;
	self.movetransitionrate = rnd_playbackrate;
	self.animplaybackrate = rnd_playbackrate;
}

roof_stealth_enemy_flashlight()
{
	self endon( "death" );
	level endon( "stealth_attack_player" );
	
	self.allowdeath = true;
	self.health = 150;
	
	anim_pos = GetEnt( "stealth_kill_02", "targetname" );
	anim_pos maps\_anim::anim_reach_solo( self, "stealth_kill_02_idle" );
	thread enemy_debris_vo();
	// make sure not to check for stealth break on a guy who can die
	anim_pos thread check_break_stealth( 210, "debris" );
	anim_pos thread maps\_anim::anim_loop_solo( self, "stealth_kill_02_idle", "stop_first_loop" );	
	StopFXOnTag( level._effect[ "flood_swept_flashlight" ], self, "tag_flash" );
	PlayFXOnTag( level._effect[ "flood_swept_flashlight" ], self.flashlight, "tag_light" );
	self thread check_for_melee_stab();
	self thread detect_player_touching();
	
	flag_wait( "player_passed_table" );
	
	anim_pos notify( "stop_first_loop" );
	anim_pos maps\_anim::anim_single_solo( self, "stealth_kill_02_into_idle2" );	
	anim_pos thread maps\_anim::anim_loop_solo( self, "stealth_kill_02_idle2", "stop_second_loop" );	
}

roof_stealth_enemy_debris()
{
	self endon( "death" );
	level endon( "stealth_attack_player" );
	
	self take_flashlight();

	anim_pos = GetEnt( "stealth_kill_02", "targetname" );
	anim_pos maps\_anim::anim_reach_solo( self, "stealth_kill_02_idle" );
	self thread drop_grenade_bag();
	self gun_remove();
	anim_pos thread maps\_anim::anim_loop_solo( self, "stealth_kill_02_idle" );	
}

check_for_weapon_pickup()
{
	while( 1 )
	{
		weapon = level.player GetCurrentWeapon();
		if( weapon != "none" && weapon != "flood_knife" )
		{
//			level.player TakeWeapon( "flood_knife" );
			level.player EnableOffhandWeapons();
			SetSavedDvar( "ammoCounterHide", 0 );
			break;
		}
		waitframe();
	}
}

stealth_door_traverse_think()
{
	level.player endon( "mantle_used" );
	
	lookat_node = GetEnt( "stealth_mantle_lookat", "targetname" );
	NotifyOnCommand( "mantle", "+gostand" );
	
	while( 1 )
	{
		if( flag( "mantle_copier" ) && player_looking_at( lookat_node.origin, 0.8, true ) && level.player GetStance() == "stand" )
		{
			SetSavedDvar( "hud_forceMantleHint", 1 );
			level.player AllowJump( false );
			level.player thread player_mantle_wait();
			while( flag( "mantle_copier" ) && player_looking_at( lookat_node.origin, 0.8, true ) &&  level.player GetStance() == "stand" )
			{
				if ( level.player GetStance() != "stand" )
					break;
				waitframe();
			}
		}
		else
		{
			level.player notify( "not_active" );
			SetSavedDvar( "hud_forceMantleHint", 0 );
			level.player AllowJump( true );
		}		
		waitframe();
	}
}

player_mantle_wait()
{
	self endon( "not_active" );
	
	self waittill( "mantle" );
	
	SetSavedDvar( "hud_forceMantleHint", 0 );
	self notify( "mantle_used" );
	
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player DisableWeapons();
	//level.player HideViewModel();

	player_rig = spawn_anim_model( "player_rig" );
	
	guys = [];
	guys["player_rig"] = player_rig;
	
	node = GetEnt( "stealth_kill_02", "targetname" );
	node maps\_anim::anim_first_frame( guys, "stealth_traverse" );
	
//	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 15, 15, 15, 15, 1);
//	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.1 );
	level.player PlayerLinkToBlend( player_rig, "tag_player", .25, .1, .1, true );
	
	thread maps\flood_audio::sfx_plr_vault();
	
	level thread maps\flood_rooftops::skybridge_teleport_cheats();
	node maps\_anim::anim_single( guys, "stealth_traverse" );

	player_rig Delete();
	
	level.player Unlink();
	level.player FreezeControls( false );
	level.player AllowJump( true );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player EnableWeapons();
	//level.player ShowViewModel(); 
	stealth_debris_collision( "on" );
	
	// swap the water back
	//thread maps\flood_swept::swept_water_toggle( "noswim", "show" );
	thread maps\flood_swept::swept_water_toggle( "swim", "show" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "hide" );

	// Finished mantle check for TFF
	level notify( "player_done_stealth_mantle" );
}

reset_allies_to_defaults()
{
	rnd_playbackrate = RandomFloatRange( 0.9, 1.1 );
	level.allies[ 0 ] thread disable_cqbwalk();
	level.allies[ 0 ].goalradius =2048;
	level.allies[ 0 ].ignoreall = 0;
	level.allies[ 0 ] set_ignoreme( false );
	level.allies[ 0 ].moveplaybackrate = 1.0;
	level.allies[ 0 ].movetransitionrate = rnd_playbackrate;
	level.allies[ 0 ].animplaybackrate = rnd_playbackrate;	
}

// stolen from _spawner.gsc.  I want to guarantee that one guy drops a grenade pack
drop_grenade_bag()
{
	team = self.team;
	maps\_spawner::waittillDeathOrPainDeath();

	if ( !isdefined( self ) )
		return;
	
	if ( isdefined( self.noDrop ) )
		return;

	self.ignoreForFixedNodeSafeCheck = true;

	max = 25;
	min = 12;
	org = self.origin + ( randomint( max ) - min, randomint( max ) - min, 2 ) + ( 0, 0, 42 );
	ang = ( 0, randomint( 360 ), 90 );
	thread maps\_spawner::spawn_grenade_bag( org, ang, self.team );
	
	level.player EnableOffhandWeapons();
	SetSavedDvar( "ammoCounterHide", 0 );
//	level.player ShowHud();
}

float_stuff()
{
	ents = GetEntArray( "stealth_bob", "targetname" );
	foreach( ent in ents )
		ent delayThread(  RandomFloatRange( 0, 1.5 ), ::floater_logic, "stealth_bob" );
	
	// table we want you to crawl underneath.  these objects need to move in sync
//	ents = GetEntArray( "table_under", "targetname" );
//	foreach( ent in ents )
//		ent thread floater_logic( "bob" );
}

// Valid floating behaviors are "bob" and "spin"
floater_logic( behavior)
{
	// Stop this after exiting the building
	level endon( "window_smash" );
	self endon( "popped" );
	self endon( "death" );
	
	switch( behavior )
	  {
		case "stealth_bob":
			while ( 1 )
			{
//				rnd_move = RandomIntRange( -2, 2 );
//				rnd_angles = RandomIntRange( -2, 2 );
				rnd_move = 2;
				rnd_angles = 1;
				time = 1.25;
				self Moveto( ( self.origin - ( 0, 0, rnd_move ) ), time, 0.2, 0.2 );
				self RotateTo( ( self.angles - ( rnd_angles, 0, rnd_angles ) ), time, 0.4, 0.4 );
				wait time;
				self Moveto( ( self.origin + ( 0, 0, rnd_move ) ), time, 0.2, 0.2 );
				self RotateTo( ( self.angles + ( rnd_angles, 0, rnd_angles ) ), time, 0.4, 0.4) ;
				wait time;
			}
	}
}

// FIX JKU VO time this vo so the conversation makes more sense
enemy_start_vo( guy )
{
	// FIX JKU  need to end this when stealth is broken
	level.stealth_enemy_1 endon( "death" );
	level.stealth_enemy_2 endon( "death" );
	level.stealth_enemy_3 endon( "death" );
	level endon( "stealth_attack_player" );
	level endon( "player_start_stealth_kill_02" );

	if( flag( "cw_player_underwater" ) )
	{
		//Vargas: Get below the water and sneak up on them.
		level thread radio_dialogue( "flood_vrg_folowmyleashit" );
	}
	else
	{
		//Vargas: Follow my lea-- SHIT! Get down!
		level.allies[ 0 ] thread dialogue_queue( "flood_vrg_theyrecomingthisway" );
	}
	
	//Venezuelan Soldier 8: Duarte, check in there.
	level.stealth_enemy_1 dialogue_queue( "flood_vs8_duartecheckinthere" );
	//Venezuelan Soldier 7: Yes, sir.
	level.stealth_enemy_3 dialogue_queue( "flood_vs7_yessir" );
	
	wait 1;
	
	//Venezuelan Soldier 8: Castillo, you're with me.
	level.stealth_enemy_1 dialogue_queue( "flood_vs8_castilloyourewithme" );
	//Venezuelan Soldier 9: What's that up ahead?
	level.stealth_enemy_2 dialogue_queue( "flood_vs9_whatsthatupahead" );
	//Venezuelan Soldier 8: I think that's another doorway.
	level.stealth_enemy_1 dialogue_queue( "flood_vs8_ithinkthatsanother" );
	
	wait 1;
	
	//Venezuelan Soldier 8: Castillo, try and clear out that rubble.
	level.stealth_enemy_1 dialogue_queue( "flood_vs8_castillotryandclear" );
	//Venezuelan Soldier 9: Could I get some light on this, Cortez?
	level.stealth_enemy_2 dialogue_queue( "flood_vs9_couldigetsome" );
	//Venezuelan Soldier 8: Sure.
	level.stealth_enemy_1 dialogue_queue( "flood_vs8_sure" );
}
	
// FIX JKU VO time this vo so the conversation makes more sense
enemy_debris_vo()
{
	// FIX JKU  need to end this when stealth is broken
	level.stealth_enemy_1 endon( "death" );
	level.stealth_enemy_2 endon( "death" );
	level endon( "stealth_attack_player" );
	level endon( "player_start_stealth_kill_02" );
	
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	//Venezuelan Soldier 9: I just can’t get through here.
	level.stealth_enemy_2	dialogue_queue( "flood_vs9_getthrough" );
	//Venezuelan Soldier 8: Don't give up! Keep trying.
	level.stealth_enemy_1	dialogue_queue( "flood_vs8_dontgiveup" );
	
	wait 2;
	
	//Venezuelan Soldier 9: Can you help me with this?
	level.stealth_enemy_2	dialogue_queue( "flood_vs9_makingprogress" );
	//Venezuelan Soldier 9: I can't get a good grip.
	level.stealth_enemy_2	dialogue_queue( "flood_vs9_goodgrip" );
	//Venezuelan Soldier 9: But keep the light steady!
	level.stealth_enemy_2	dialogue_queue( "flood_vs9_lightsteady" );
	//Venezuelan Soldier 8: Do you want me to help of keep the light steady?
	level.stealth_enemy_1	dialogue_queue( "flood_vs8_keepthelight" );
	//Venezuelan Soldier 9: Fine, just keep is steady.
	level.stealth_enemy_2	dialogue_queue( "flood_vs9_finejustkeep" );
	
	wait 3;
	
	//Venezuelan Soldier 8: I  haven't heard anything from Duarte in a bit. Do you think something happened to him?
	level.stealth_enemy_1	dialogue_queue( "flood_vs8_thinksomething" );
	//Venezuelan Soldier 9: Cortez! The light!
	level.stealth_enemy_2	dialogue_queue( "flood_vs9_thelight" );
	//Venezuelan Soldier 8: Oh, right.
	level.stealth_enemy_1	dialogue_queue( "flood_vs8_ohright" );
	
	while( 1 )
	{
		if( RandomInt( 2 ) )
		{
			//Venezuelan Soldier 9: I just can’t get through here.
			level.stealth_enemy_2	dialogue_queue( "flood_vs9_getthrough" );
			//Venezuelan Soldier 8: Don't give up! Keep trying.
			level.stealth_enemy_1	dialogue_queue( "flood_vs8_dontgiveup" );
		}
		else
		{
			//Venezuelan Soldier 8: I  haven't heard anything from Duarte in a bit. Do you think something happened to him?
			level.stealth_enemy_1	dialogue_queue( "flood_vs8_thinksomething" );
			//Venezuelan Soldier 9: Cortez! The light!
			level.stealth_enemy_2	dialogue_queue( "flood_vs9_thelight" );
			//Venezuelan Soldier 8: Oh, right.
			level.stealth_enemy_1	dialogue_queue( "flood_vs8_ohright" );
		}
		
		wait RandomIntRange( 6, 9 );
	}
}

ai_alert_player_break_stealth()
{
	flag_set( "stealth_attack_player" );
	level notify( "stealth_attack_player" );
	
	level.allies[ 0 ] thread dialogue_queue( "flood_diz_theyseeyou" );
	
	// FIX JKU had to remove this because dialogue_queue has funcs that don't fire off immediately and the enemy playing the vo could die while he's talking.  seems like a bug with dialogue_queue really.
	/*
	if( IsAlive( level.stealth_enemy_1 ) && IsAlive( level.stealth_enemy_2 ) )
	{
		if( RandomInt( 2 ) )
		{
			level.stealth_enemy_1 thread dialogue_queue( "flood_vz8_americanshere" );
		}
		else
		{
			level.stealth_enemy_2 thread dialogue_queue( "flood_vz9_americanshere" );
		}
	}
	else if( IsAlive( level.stealth_enemy_1 ) )
	{
		level.stealth_enemy_1 thread dialogue_queue( "flood_vz8_americanshere" );
	}
	else
	{
		level.stealth_enemy_2 thread dialogue_queue( "flood_vz9_americanshere" );
	}
	*/
	
	level.allies[ 0 ] thread take_hatchet();
	level.allies[ 0 ] StopAnimScripted();
	// FIX JKU not that big of a deal, buy why do I need this check for failing the second stealth kill and not the first.  Nothing else should be removing it???
	if ( !IsDefined( level.allies[ 0 ].magic_bullet_shield ) )
		level.allies[ 0 ] stop_magic_bullet_shield();
	// FIX JKU do I want to track if the ally dies before you and fail.  Seems unnecessary
	level.allies[ 0 ].health = 1;
	node = GetNode( "ally_stealth_break_01_node", "targetname" );
	level.allies[ 0 ] AllowedStances( "crouch" );
	level.allies[ 0 ].goalradius = 8;
	level.allies[ 0 ] SetGoalNode( node );
	
	// you can kill him right before the first steatlh kill resulting in a fail but we still want to be able to gracefully go through this script
	if( IsAlive( level.stealth_enemy_1 ) )
	{
		level.stealth_enemy_1 StopAnimScripted();
		level.stealth_enemy_1 drop_flashlight();
		level.stealth_enemy_1.ignoreall = 0;
		level.stealth_enemy_1.goalradius = 8;
		level.stealth_enemy_1 SetGoalPos ( level.player.origin );
	}
	
	level.stealth_enemy_2 StopAnimScripted();
	level.stealth_enemy_2 drop_flashlight();
	level.stealth_enemy_2.ignoreall = 0;
	level.stealth_enemy_2.goalradius = 64;
	level.stealth_enemy_2 SetGoalPos ( level.player.origin );
	// FIX JKU he could be in a vign for stealthkill02 so maybe there needs to be a way to unstow from his back?
	level.stealth_enemy_2 gun_recall();
	
	// FIX JKU hmm...  maybe I shouldn't use this flag but for some reason can't use isalive because kill doesnt work???
	// this hack relies on this flag getting set before you can break stealth after the first stealthkill
	if(	!flag( "hatchet_linked" ) )
	{
		level.stealth_enemy_3 StopAnimScripted();
		level.stealth_enemy_3 drop_flashlight();
		level.stealth_enemy_3.ignoreall = 0;
		level.stealth_enemy_3 SetGoalPos ( level.player.origin );
	}
}

check_break_stealth( dist, sitch )
{
	self endon( "death" );
	level endon( "start_evade_success" );
	level endon( "player_start_stealth_kill_02" );
	level endon( "onto_skybridge" );
	
	JKUprint( "looking" );
	// if I continue to use dum dist should make a level var so I only have to change it in one place
	while( 1 )
	{
		// break stealth by being dumb
		if( ( !flag( "cw_player_underwater" ) && Distance2D( level.player.origin, self.origin ) < dist ) || flag( "stealth_player_touching" ) || !IsAlive( level.stealth_enemy_1 ) || !IsAlive( level.stealth_enemy_2 ) )
		{
			thread clean_up_attack( true );
			thread maps\flood_coverwater::player_abovewater_defaults();
			thread ai_alert_player_break_stealth();
    		break;
		}
		waitframe();
	}

	JKUprint( "spotted!" );
	self delayThread( 2, ::break_stealth_mg, sitch );
}
	
// machinegun the player to death
break_stealth_mg( sitch )
{
	while( IsAlive( level.player ) )
	{
		angles = level.player GetPlayerAngles();
		forward = AnglesToForward( angles );
		location = ( level.player.origin + ( 15 * forward ) ) + ( RandomFloatRange( -10, 10 ), RandomFloatRange( -10, 10 ), 55 );
//		MagicBullet( level.stealth_enemy_1.weapon, level.stealth_enemy_1 GetTagOrigin( "tag_flash" ), level.player.origin );
		MagicBullet( "microtar", location, level.player.origin );
		// magicbullet won't gurantee player hits so do this too
		level.player DoDamage( 50, level.player.origin );
		wait RandomFloatRange( 0.05, 0.15 );
	}
	
	if( sitch == "start" )
	{
		setDvar( "ui_deadquote", &"FLOOD_STEALTH_FAIL0" );
	}
	else
	{
		if( RandomInt( 2 ) )
			setDvar( "ui_deadquote", &"FLOOD_STEALTH_FAIL1" );
		else
			setDvar( "ui_deadquote", &"FLOOD_STEALTH_FAIL2" );
	}
}

no_attack_hint()
{
	if ( !IsAlive( level.player ) )
	{
		return true;
	}
	
	if ( !IsDefined( level.player.ready_to_attack ) || !level.player.ready_to_attack )
	{
		return true;
	}
	
	if ( IsDefined( level.player.in_attack ) && level.player.in_attack )
	{
		return true;
	}
	
	if ( flag( "stealth_attack_player" ) )
	{
		return true;
	}
	
	return false;
}

ready_to_attack()
{
	level.player AllowMelee( false );
	level.player.ready_to_attack = true;
//	level.player display_hint( "attack_hint" );
}

clean_up_attack( melee )
{
	if ( IsDefined( level.player.ready_to_attack ) && level.player.ready_to_attack )
		level.player.ready_to_attack = undefined;

	if( melee )
		level.player AllowMelee( true );
}

check_for_melee_stab()
{
	level.player endon( "death" );
	level endon( "stealth_attack_player" );
	
	max_stab_distance_sq = 90 * 90;
	while ( 1 )
	{
		distance_from_player = DistanceSquared( level.player.origin, self.origin );
//		angle_diff = abs( AngleClamp180( level.player.angles[ 1 ] - self.angles[ 1 ] ) );
//		if ( angle_diff < 45 && distance_from_player < max_stab_distance_sq )
		if( distance_from_player < max_stab_distance_sq && player_looking_at( self.origin + ( 0, 0, 30 ), 0.7 ) )
		{
			ready_to_attack();
			
//			if ( level.player MeleeButtonPressed() && isAlive( self ) && !level.player IsMeleeing() && !level.player IsThrowingGrenade() )
			if ( level.player MeleeButtonPressed() && !level.player IsMeleeing() && !level.player IsThrowingGrenade() )
			{
				flag_set( "player_start_stealth_kill_02" );
				level notify( "player_start_stealth_kill_02" );
				level.player.in_attack = true;
				stealth_kill_02_player();
				
			    level.stealth_enemy_1.a.nodeath = true;
			    level.stealth_enemy_1.allowdeath = true;
			    level.stealth_enemy_1.diequietly = true;
			    level.stealth_enemy_1 Kill();
			    
				level.stealth_enemy_2 DropWeapon( "microtar", "right", 0 );
			    level.stealth_enemy_2 stop_magic_bullet_shield();
			    level.stealth_enemy_2.a.nodeath = true;
			    level.stealth_enemy_2.allowdeath = true;
			    level.stealth_enemy_2.diequietly = true;
			    level.stealth_enemy_2 Kill();
				
			    clean_up_attack( true );
			    return;
			}
		}
		// if you're close but not looking at the guy, don't let you do anything
		else if( distance_from_player < max_stab_distance_sq && flag( "cw_player_underwater" ) )
		{
			clean_up_attack( false );
		}
		else
		{
			clean_up_attack( true );
		}
		waitframe();
	}
}

firstframe_stealth_debris()
{
	node = GetEnt( "stealth_kill_02", "targetname" );
	
	setup_node = GetEnt( "firstframe_test", "targetname" );
	
	level.stealth_filecab1 = spawn_anim_model( "flood_stealthkill_02_filecabinet_01" );
	level.stealth_filecab1.origin = setup_node.origin;
	ent = GetEnt( "stealth_door_filecab1", "targetname" );
	ent LinkTo( level.stealth_filecab1 );
	
	level.stealth_filecab2 = spawn_anim_model( "flood_stealthkill_02_filecabinet_02" );
	level.stealth_filecab2.origin = setup_node.origin;
	ent = GetEnt( "stealth_door_filecab2", "targetname" );
	ent LinkTo( level.stealth_filecab2 );
	
	level.stealth_photocopier = spawn_anim_model( "stealthkill_photocopier" );
	level.stealth_photocopier.origin = setup_node.origin;
	ent = GetEnt( "stealth_door_copier", "targetname" );
	ent LinkTo( level.stealth_photocopier );

	guys = [];
	guys["flood_stealthkill_02_filecabinet_01"] = level.stealth_filecab1;
	guys["flood_stealthkill_02_filecabinet_02"] = level.stealth_filecab2;
	guys["stealthkill_photocopier"] = level.stealth_photocopier;
	
	node maps\_anim::anim_first_frame(guys, "stealth_kill_02");
	ent DisconnectPaths();
}

stealth_debris_collision( stich )
{
	switch( stich )
	{
		case "on":
			ent = GetEnt( "stealth_door_filecab1", "targetname" );
			ent Solid();
			break;
		case "off":
			ent = GetEnt( "stealth_door_filecab1", "targetname" );
			ent NotSolid();
			break;
	}
}

crouch_hint()
{
	level.player display_hint_timeout( "crouch_hint", 3 );
}

no_crouch_hint()
{
	if ( !IsAlive( level.player ) )
	{
		return true;
	}
	
	return false;
}

remove_kill1_collision()
{
	ent = GetEnt( "stealth kill1 collision", "targetname" );
	
	ent NotSolid();
}

detect_player_touching()
{
	self endon( "death" );
	level endon( "player_start_stealth_kill_02" );
	level endon( "stealth_attack_player" );
	
	while( 1 )
	{
		starttime = GetTime();
		displaying_hint_too_close = undefined;
		// would've been nice but couldn't use istouching only here as you had to push up against the guy for a little while before it triggered
		while( Distance2D( level.player.origin, self.origin ) < 36 || level.player IsTouching( self ) )
		{
//			JKUprint( "get off my land!" );
			endtime = GetTime();
			// attack the player if you've been up against him for too long
			if( endtime - starttime > 3000 || level.player IsTouching( self ) )
			{
//				JKUprint( endtime - starttime );
				flag_set( "stealth_player_touching" );
				break;
			}
			// if you've only been up his ass for a little while, give you a hint to attack
			else if( endtime - starttime > 500 )
			{
//				JKUprint( endtime - starttime );
				// don't keep trying to diplay the hint if it's been displayed
				if( !IsDefined( displaying_hint_too_close ) )
				{
					displaying_hint_too_close = true;
					level.player display_hint( "attack_hint" );
				}
			}
			waitframe();
		}
		waitframe();
	}
}

stealth_kill_01()
{
	roof_stealth_create_enemies();
	
	node = GetEnt( "stealth_kill_01", "targetname" );
	
	// first 2 guys anims end at different times to thread their stuff off and put them in ai
	level.stealth_enemy_1 thread stealth_kill_01_enemy1( node );
	level.stealth_enemy_2 thread stealth_kill_01_enemy2( node );
	
	stealth_axebox = spawn_anim_model( "stealth_axebox" );
	col = GetEnt( "axbox_collision", "targetname" );
	col.origin = stealth_axebox GetTagOrigin( "j_bone_door_1" ) + ( 13.5, 0, 2.5 );
	col.angles = stealth_axebox GetTagAngles( "j_bone_door_1" );	
	col LinkTo( stealth_axebox, "j_bone_door_1" );
	
	level.allies[ 0 ] thread create_hatchet();
	
	guys						   = [];
	guys[ "ally_0"				 ] = level.allies[ 0 ];
	guys[ "stealth_axebox"		 ] = stealth_axebox;
	guys[ "stealth_enemy_3"		 ] = level.stealth_enemy_3;

	// FIX JKU probably want to play these off of notetracks????
//	delayThread( 2, maps\flood_roof_stealth::crouch_hint );
	// only need this on the second guy because he trails.  dist is way too high anyways
	level.stealth_enemy_2 delayThread( 11, ::check_break_stealth, 666, "start" );
	delayThread( 16, ::check_break_stealth_end );
	delayThread( 1, ::remove_kill1_collision );
//	delayThread( 14, ::remove_kill1_collision );
	delayThread( 21, ::autosave_now );
	
	level.stealth_enemy_3 give_flashlight();
	thread maps\flood_audio::wait_then_play_stealth_sounds( level.allies[ 0 ] );
	// FIX JKU this should probably be on a notetrack.  set a flag so we can stop the water surface fx
	delaythread( 21, ::flag_set, "stealth_enemy_3_dead" );
	node maps\_anim::anim_single( guys, "stealth_kill_01" );
	level.stealth_enemy_3 maps\_vignette_util::vignette_actor_kill();

	flag_set( "stealth_kill_01_done" );
}

stealth_kill_01_enemy1( node )
{
	self stop_magic_bullet_shield();
	self enable_pain();
	self give_flashlight();
	node maps\_anim::anim_single_solo( self, "stealth_kill_01" );
	StopFXOnTag( level._effect[ "flashlight" ], self.flashlight, "tag_light" );
	PlayFXOnTag( level._effect[ "flashlight" ], self, "tag_flash" );
	self roof_stealth_enemy_flashlight();
}

stealth_kill_01_enemy2( node )
{
	self give_flashlight();
	node maps\_anim::anim_single_solo( self, "stealth_kill_01" );
	self roof_stealth_enemy_debris();
}

give_flashlight()
{
	self.flashlight = spawn_anim_model( "stealth_flashlight" );
	self.flashlight.origin = self GetTagOrigin( "tag_inhand" );
	self.flashlight.angles = self GetTagAngles( "tag_inhand" );
	self.flashlight LinkTo( self, "tag_inhand" );
	PlayFXOnTag( level._effect[ "flood_swept_flashlight" ], self.flashlight, "tag_light" );
}

take_flashlight()
{
	StopFXOnTag( level._effect[ "flood_swept_flashlight" ], self.flashlight, "tag_light" );
	self.flashlight Unlink();
	self.flashlight Delete();
	self.flashlight = undefined;
}

drop_flashlight()
{
	if( IsDefined( self.flashlight ) )
	{
		self.flashlight Unlink();
		endpos = PhysicsTrace( self.flashlight.origin, self.flashlight.origin + ( 0, 0, -300 ) );
		
		time = 0.6;
		
		rot_array	   = [];
		rot_array[ 0 ] = 90;
		rot_array[ 1 ] = -90;
		
		self.flashlight MoveTo( endpos + ( 0, 0, 1 ), time );
		self.flashlight RotateTo( ( random( rot_array ), self.flashlight.angles[ 0 ], random( rot_array ) ), time );
		
//		grav_hack = self.flashlight spawn_tag_origin();
//		self.flashlight LinkTo( grav_hack );
//		endpos = PhysicsTrace( self.flashlight.origin, self.flashlight.origin + ( 0, 0, -300 ) );
//		grav_hack MoveGravity( self.velocity, 5 );
//		
//		while( self.flashlight.origin[ 2 ] > endpos[ 2 ] )
//			waitframe();
//		
//		self.flashlight Unlink();
//		grav_hack Delete();
	}
}

check_break_stealth_end()
{
	level notify( "start_evade_success" );
	
	JKUprint( "not looking" );
}

create_hatchet()
{
	if( !IsDefined( self.hatchet ) )
		self.hatchet = spawn_anim_model( "stealth_hatchet", ( 4191.9771, -2684.7275, 66.7125 ) );
	
	self.hatchet.angles = ( 90, 0, 0 );
}

give_hatchet( guy )
{
	flag_set( "hatchet_linked" );

	if( !flag( "player_passed_table" ) )
	{
		// FIX JKU do we want this line to play if you're underwater
		guy thread dialogue_queue( "flood_vrg_thiswillbeuseful" );
	}
	
	guy.hatchet.origin = guy GetTagOrigin( "tag_inhand" );
	guy.hatchet.angles = guy GetTagAngles( "tag_inhand" );
	guy.hatchet Delete();
	guy Attach( "com_hatchet", "tag_inhand", true );
}

take_hatchet()
{
	if(	flag( "hatchet_linked" ) )
		self Detach( "com_hatchet", "tag_inhand" );
}

detach_hatchet( guy )
{
	hatchet = spawn_anim_model( "stealth_hatchet" );
	hatchet.origin = guy GetTagOrigin( "tag_inhand" );
	hatchet.angles = guy GetTagAngles( "tag_inhand" );
	guy Detach( "com_hatchet", "tag_inhand" );
}

hatchet_linked( guy )
{
	flag_set( "hatchet_linked" );
}

stealth_kill_02_player()
{
	node = GetEnt( "stealth_kill_02", "targetname" );

	level.player FreezeControls( true );
	level.player AllowCrouch( false );
	level.player DisableWeapons();
	level.cw_no_waterwipe = true;

	level.stealth_enemy_1 thread smart_dialogue( "generic_death_enemy_3" );
	
	player_rig = spawn_anim_model( "player_rig" );
	player_rig_offset = spawn_tag_origin();
	player_rig_offset.origin = player_rig GetTagOrigin( "tag_player" ) + ( 0, 0, 20 );
	player_rig_offset.angles = player_rig GetTagAngles( "tag_player" );
	player_rig_offset LinkTo( player_rig, "tag_player" );

	guys									= [];
	guys[ "vignette_stealth_kill2_opfor1" ] = level.stealth_enemy_1;
	guys[ "player_rig"					  ] = player_rig;

	node maps\_anim::anim_first_frame( guys, "stealth_kill_02" );
	player_rig Hide();
	level.allies[ 0 ] Hide();
	
//	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 15, 15, 15, 15, 1 );
//	level.player PlayerLinkToBlend( player_rig, "tag_player", 0.1 );
	// FIX JKU back from break.  do this and then blend the player?
//	level.player LerpViewAngleClamp( 0.1, 0, 0, 0, 0, 0 ,0 );
	level.player PlayerLinkToBlend( player_rig_offset, "tag_origin", 0.1 );
	wait 0.1;
	level.player HideViewModel();
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 0, 0, 0, 0, 1 );
//	level.player delayCall( 0.1, ::PlayerLinkToDelta, player_rig, "tag_player", 1, 0, 0, 0, 0, 1 );

	player_rig Attach( "viewmodel_bowie_knife", "tag_knife_attach", true );
	level.player playsound( "scn_flood_plr_stealth_kill" );
	player_rig Show();
	level.allies[ 0 ] delayCall( 0.3, ::Show );
	node maps\_anim::anim_single( guys, "stealth_kill_02" );
	player_rig Detach( "viewmodel_bowie_knife", "tag_knife_attach", true );

	level.player Unlink();
	player_rig Delete();
	
	level.player ShowViewModel();
	level.player FreezeControls( false );
	level.player AllowCrouch( true );
	level.player EnableWeapons();
	level.cw_no_waterwipe = false;
}

stealth_kill_02_ally()
{
	node = GetEnt( "stealth_kill_02", "targetname" );

	guys										  = [];
	guys[ "flood_stealthkill_02_filecabinet_01" ] = level.stealth_filecab1;
	guys[ "flood_stealthkill_02_filecabinet_02" ] = level.stealth_filecab2;
	guys[ "stealthkill_photocopier"				] = level.stealth_photocopier;
	guys[ "vignette_stealth_kill2_opfor2"		] = level.stealth_enemy_2;
	guys[ "vignette_stealth_kill2_ally1"		] = level.allies[ 0 ];

	thread maps\flood_audio::sfx_diaz_stealth_kills2( guys["vignette_stealth_kill2_ally1"] );
	stealth_debris_collision( "off" );
	delayThread( 13.5, ::stealth_door_traverse_think );
	node maps\_anim::anim_single( guys, "stealth_kill_02" );
	
	flag_set( "stealth_kill_02_done" );
}

roof_stealth_cleanup()
{
	ents = GetEntArray( "stealth_bob", "targetname" );
	array_delete( ents );

	ents = GetEntArray( "stealth_cleanup", "script_noteworthy" );
	array_delete( ents );
}
