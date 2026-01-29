#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vignette_util;
#include maps\_vehicle;
#include maps\flood_util;

section_main()
{
}

section_precache()
{
	PreCacheRumble( "damage_light" );
	PreCacheString( &"FLOOD_TANKS_FAIL" );
}

section_flag_inits()
{
    flag_init( "infil_done" );
	flag_init( "enemy_tank_killed" );
	flag_init( "allies_run_for_garage" );
	flag_init( "allies_in_position" );
    flag_init( "allied_tank_killed" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

infil_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "infil_start" );
	
	// Leaving this call in, but took out the ambience in the soundtable as it's all one long audio stream for the vignette.
	//set_audio_zone( "flood_infil", 2 );
	
	// spawn the allies
	maps\flood_util::spawn_allies();
	
	vision_set_changes( "flood_infil", 0 );
	
//	maps\_art::dof_enable_script( 0, 745, 4, 65000, 88000, 0.5, 1.5 );
	
}

infil()
{
	level.player DisableWeapons();
	level.player EnableInvulnerability();
	
	//flood music
	music_play( "mus_flood_infil_ss" );

//	vehicle_scripts\_t90::main( "vehicle_t90_tank_woodland" );
//	vehicle_scripts\silenthawk::main( "vehicle_silenthawk" );
//	maps\_vehicle::build_aianims( ::infil_silenthawk_setanims, vehicle_scripts\silenthawk::set_vehicle_anims );

	wait 1;
	
	level.player play_sound_on_entity( "flood_pri_itsbeenfifteenyears" );
	
	// everything is timed off these anims when this was 0, so if the anim lengths change, just adjust this offset to fix everything downstream
	// timed for anim start frame of 1100
	level.infil_global_offset = 0;

	wait 1;
	
	level thread infil_flyin_player();
	level thread infil_flyin_allies();
	level thread setup_initial_ai();
	level thread setup_dead_destroyed_and_misc();
	level thread allies_first_advance();
	level delayThread( level.infil_global_offset + 0.0, ::infil_sidestreet );
	level delayThread( level.infil_global_offset + 0.0, ::rpg_guy_shoot_flyin_choopers );
	level delayThread( level.infil_global_offset + 0.5, ::tank_battle );
	
	thread maps\flood_fx::fx_infil_heli_smoke();


	// removed for shortened infil
//	level thread infil_heli_outside_city();
//	level thread infil_convoy_outside_city();
//	level thread swap_hi_res_dam( 15 );
//	level thread infil_flyin_battle_init();
	
	SetSavedDvar( "sm_sunSampleSizeNear", 0.6 );
	
	level waittill( "infil_done" );

	level.player DisableInvulnerability();
	
	maps\flood::streets();
	
	// tagDK<temp> - Remove when anim is properly linked to player
//	maps\flood_util::player_move_to_checkpoint_start( "streets_start" );
}

#using_animtree( "generic_human" );
infil_flyin_player()
{
//	level thread vignette_old_choppers_for_test();
	
	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player DisableWeapons();

	//to keep player from jumping back in heli
	player_blocker = getent("player_heli_infil_clip", "targetname");
	player_blocker hide();
	player_blocker NotSolid();
	
	// Start the vignette sfx for helicopter ride
	thread maps\flood_audio::sfx_heli_infil();
	
	delayThread( level.infil_global_offset + 11, maps\flood_fx::fx_heli_land );

	chopper = spawn_vehicle_from_targetname_and_drive( "infil_player_chopper_new" );
	level.infil_heli_player = chopper;
	chopper godon();
	chopper Vehicle_TurnEngineOff();
	chopper SetMaxPitchRoll( 20, 10 );
	chopper Vehicle_SetSpeedImmediate( 50, 999 );
	level thread infil_vo( chopper );
	
	level.allies[ 0 ].script_startingposition = 2;
	chopper guy_enter_vehicle( level.allies[ 0 ] );
//	animpos = maps\_vehicle_aianim::anim_pos( chopper, 0 );
//	org thread anim_loop_solo( level.allies[ 0 ], "infil_loop", "stop_infil_loop" );

	level.allies[ 1 ].script_startingposition = 3;
	chopper guy_enter_vehicle( level.allies[ 1 ] );
	
	level.allies[ 2 ].script_startingposition = 6;
	chopper guy_enter_vehicle( level.allies[ 2 ] );
	
	chopper.player_link_ent = spawn_tag_origin();
	chopper.player_link_ent LinkTo( chopper, "tag_player", ( 14, 6, -10 ), ( 0, -66, 0 ) );
	level.player PlayerLInkToDelta( chopper.player_link_ent, "tag_player", 0.8, 10, 35, 20, 30, false );
	
	chopper thread infil_flyin_player_unload_GT();
	
	player_lz_node = getstruct( "player_chopper_lz", "targetname" );
	player_lz_node waittill( "trigger");
	
	Earthquake( 0.3, 0.35, level.player.origin, 1600 );
	noself_delayCall( 0.5, ::Earthquake, 0.15, 0.35, level.player.origin, 1600 );

//	level thread smart_radio_dialogue( "flood_pri_moveout" );
	
	wait 2.25;
	
	level.allies[ 0 ] thread smart_radio_dialogue( "flood_pri_moveout" );
	level thread smart_radio_dialogue( "flood_gp1_ondeck" );
	level thread smart_radio_dialogue( "flood_hqr_helix47" );
	
	level.allies[ 0 ] thread smart_radio_dialogue( "flood_pri_overlordpatchmeinto" );
	level thread smart_radio_dialogue( "flood_hqr_roger" );
	
	level.player EnableWeapons(); 
	level.player lerp_player_view_to_position_oldstyle( ( 2405, -11455, -40 ), ( 0, 45, 0 ), 1 );

	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", 0 );
	SetSavedDvar( "actionSlotsHide", 0 );
	SetSavedDvar( "hud_showStance", 1 );
	level.player Unlink();
	chopper.player_link_ent Delete(); 
	level.player FreezeControls( false );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	
	//keep player from jumping back in heli
	player_blocker Show();
	player_blocker Solid();
//	IPrintLn("blocker here");
	
	wait 0.5;

    flag_set( "infil_done" );
    
    // FIX JKU need to come back to this and make sure I'm doing this when and where I want.  setting it earlier makes sense but need to make sure tanks still shoot at me from the ground.
    level.player.ignoreme = 1;
    wait 1.0;
    player_blocker delete();
//	IPrintLn("blocker gone");
    wait 2.0;
    
    level.player.ignoreme = 0;
}

infil_silenthawk_setanims()
{
	positions = vehicle_scripts\silenthawk::setanims();

	positions[ 2 ].idle_alert = %flood_infil_ally1_loop;
	positions[ 3 ].getout = %flood_infil_ally2_jumpout;

	return positions;
}

infil_vo( chopper )
{
	//Overlord: Helix Four, Echo Eight-One should be at the L.Z. by the time you get there.
	level smart_radio_dialogue( "flood_hqr_bythetime" );
	//Generic Pilot 2: Copy that.
	level smart_radio_dialogue( "flood_gp2_copythat" );
	//Helix Leader: Overlord, be advised, helix four has entered the hot zone.  One mike til deployment.
	level smart_radio_dialogue( "flood_hlx_overlordbeadvisedhelix" );
	chopper delayThread( 1.3, ::anim_single_solo, level.allies[ 0 ], "infil_vo", "tag_detach_right" );
	// FIX JKU need to make sure the notify is run on the correct ent.
	chopper notify( "stop_infil_loop" );
	level.allies[ 0 ] notify( "stop_infil_loop" );
	//Overlord: Roger that, Four Seven.
	level smart_radio_dialogue( "flood_hqr_rogerthatfourseven" );
	//Price: We're here for one man! Garcia! Follow my lead!
	level smart_radio_dialogue( "flood_pri_werehereforone" );
//	level.allies[ 0 ] delayThread( 13.25, ::smart_radio_dialogue_interrupt, "flood_pri_werehereforone" );
//	level thread smart_radio_dialogue( "flood_gp2_touchingdown" );
}

infil_flyin_player_unload_GT()
{
	leader_start_node = GetNode( "streets_leader_start_node", "targetname" );
    ally_1_start_node = GetNode( "streets_ally_1_start_node", "targetname" );
    ally_2_start_node = GetNode( "streets_ally_2_start_node", "targetname" );
	
	level.allies[ 0 ] thread GT_get_to_cover_after_landing( self, leader_start_node );
	level.allies[ 1 ] thread GT_get_to_cover_after_landing( self, ally_1_start_node );
	level.allies[ 2 ] thread GT_get_to_cover_after_landing( self, ally_2_start_node );
}

GT_get_to_cover_after_landing( chopper, node, delay )
{
	self SetGoalNode( node );
	start_goalradius = self.goalradius;
	self.goalradius = 16;
	self.ignoreall = true;
	self.ignoreme = true;
    self.grenadeawareness = 0;
    self.ignoreexplosionevents = true;
    self.ignorerandombulletdamage = true;
    self.ignoresuppression = true;
    self.disableBulletWhizbyReaction = true;
    self disable_pain();
	
	chopper waittill( "unloaded" );
	
	level thread vision_set_changes( "flood", 3 );
		
	self Unlink();

	// FIX JKU probably shouldn't do ai specific stuff in here...
	if( self.animname == "ally_0" )
	{
		self.run_overrideanim = getanim( "price_exit_chopper_wave" );
		wait GetAnimLength( getanim( "price_exit_chopper_wave" ) );
		self.run_overrideanim = undefined;
		self.prevMoveMode = "none"; 
		self notify( "move_loop_restart" );
	}
		
   	self waittill( "goal" );
    
	self.goalradius = start_goalradius;
	self.ignoreall = false;
	self.ignoreme = false;
    self.grenadeawareness = 1;
    self.ignoreexplosionevents = false;
    self.ignorerandombulletdamage = false;
    self.ignoresuppression = false;
    self.disableBulletWhizbyReaction = false;
    self enable_pain();
}

infil_flyin_allies()
{
	chopper = spawn_vehicle_from_targetname_and_drive( "infil_ally_chopper_new" );
	level.infil_heli_ally = chopper;
	chopper godon();
	chopper Vehicle_TurnEngineOff();
	chopper SetMaxPitchRoll( 20, 60 );
	chopper Vehicle_SetSpeedImmediate( 60, 999 );
	
	death_node = GetNode( "infil_redshirt_death", "targetname" );
	ais = chopper vehicle_get_riders_by_group( "passengers" );
	
	chopper waittill( "unloaded" );
	
	foreach( ai in ais )
		ai thread chopper02_ally( death_node.origin );
}

vignette_old_choppers_for_test()
{
	node = getstruct( "vignette_infil_old", "script_noteworthy" );

	infil_heli_player = vignette_vehicle_spawn( "infil_heli_player", "infil_heli_player" );
	infil_heli_ally	  = vignette_vehicle_spawn( "infil_heli_ally", "infil_heli_ally" );

	helicopters						   = [];
	helicopters[ "infil_heli_player" ] = infil_heli_player;
	helicopters[ "infil_heli_ally"	 ] = infil_heli_ally;

	node thread anim_single( helicopters, "infil" );
}

infil_flyin_old()
{    
	infil_heli_player = vignette_vehicle_spawn( "infil_heli_player", "infil_heli_player" );
	level.infil_heli_player = infil_heli_player;
	level.infil_heli_player godon();;
	infil_heli_ally	  = vignette_vehicle_spawn( "infil_heli_ally", "infil_heli_ally" );
	level.infil_heli_ally = infil_heli_ally;
	level.infil_heli_ally godon();
	heli_01_copilot	  = vignette_actor_spawn( "heli_01_copilot", "heli_01_copilot" );
	heli_02_ally_01	  = vignette_actor_spawn( "heli_02_ally_01", "heli_02_ally_01" );
	heli_02_ally_02	  = vignette_actor_spawn( "heli_02_ally_02", "heli_02_ally_02" );
	heli_02_ally_03	  = vignette_actor_spawn( "heli_02_ally_03", "heli_02_ally_03" );
	heli_02_ally_04	  = vignette_actor_spawn( "heli_02_ally_04", "heli_02_ally_04" );

	//Audio: Turning off vehicle engines
	infil_heli_player vehicle_turnengineoff();
	infil_heli_ally vehicle_turnengineoff();
	
	// Start the vignette sfx for helicopter ride
	thread maps\flood_audio::sfx_heli_infil();
	delayThread( level.infil_global_offset + 9, maps\flood_fx::fx_heli_land );
    
	node = getstruct( "vignette_infil_old", "script_noteworthy" );

	SetSavedDvar( "compass", 0 );
	SetSavedDvar( "ammoCounterHide", 1 );
	SetSavedDvar( "actionSlotsHide", 1 );
	SetSavedDvar( "hud_showStance", 0 );
	level.player FreezeControls( true );
	level.player AllowProne( false );
	level.player AllowCrouch( false );
	level.player DisableWeapons();

	// Remove the weapons from the extra AI so they don't float under the chopper
	infil_vignette_remove_weapon( heli_01_copilot );
	
	helicopters						   = [];
	helicopters[ "infil_heli_player" ] = infil_heli_player;
	helicopters[ "infil_heli_ally"	 ] = infil_heli_ally;

	player_rig = spawn_anim_model( "player_rig" );
	player_rig Hide();
	player_rig LinkTo( infil_heli_player, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 1, 65, 65, 15, 15, true );
	level.allies[ 0 ] LinkTo( infil_heli_player, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	level.allies[ 1 ] LinkTo( infil_heli_player, "tag_player", ( 40, 300, 0 ), ( 0, 0, 0 ) );
	level.allies[ 2 ] LinkTo( infil_heli_player, "tag_player", ( 40, 200, 0 ), ( 0, 0, 0 ) );
	
	//Guys sitting in player helicopter
	guys_heli_01							= [];
	guys_heli_01[ "heli_01_copilot"		  ] = heli_01_copilot;
	
	//Player and Allies
	guys_heli_01_dismount				  = [];
	guys_heli_01_dismount[ "player_rig" ] = player_rig;
	guys_heli_01_dismount[ "ally_0" 	] = level.allies[ 0 ];
	
	//Allies that dismount from ally helicopter
	guys_heli_02_dismount					   = [];
	guys_heli_02_dismount[ "heli_02_ally_01" ] = heli_02_ally_01;
	guys_heli_02_dismount[ "heli_02_ally_02" ] = heli_02_ally_02;
	guys_heli_02_dismount[ "heli_02_ally_03" ] = heli_02_ally_03;
	guys_heli_02_dismount[ "heli_02_ally_04" ] = heli_02_ally_04;
	
	foreach ( guy in guys_heli_01 )
		guy LinkTo( infil_heli_player, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	foreach ( guy in guys_heli_02_dismount )
		guy LinkTo( infil_heli_ally, "tag_player", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	node thread anim_single( helicopters, "infil" );
	node thread anim_single( guys_heli_01, "infil" );
	node thread anim_single( guys_heli_02_dismount, "infil" );
	delayThread( level.infil_global_offset + 0, ::helo_01_palyer_and_price, node, guys_heli_01_dismount, player_rig );
	delayThread( level.infil_global_offset + 13, ::helo_01_others );
	foreach( guy in guys_heli_02_dismount )
		guy delayThread( level.infil_global_offset + 4.6, ::helo_02_dismount, node );
	
	wait GetAnimLength( infil_heli_player getanim( "infil" ) );
	
	// FIX JKU these should be based per helicopter not all at once
	infil_heli_player vignette_vehicle_delete();
	infil_heli_ally vignette_vehicle_delete();
	heli_01_copilot vignette_actor_delete();
}

infil_vignette_remove_weapon( guy )
{
	if( IsDefined( guy.weapon ) )
		guy gun_remove();
}

helo_01_palyer_and_price( node, guys_heli_01_dismount, player_rig )
{
//	level.player delayCall( 0.05, ::PlayerLinkToDelta, player_rig, "tag_player", 1, 45, 45, 15, 15, true );
	node anim_single( guys_heli_01_dismount, "infil" );
	
	level.player Unlink();
	player_rig Delete(); 
	level.player FreezeControls( false );
	level.player AllowProne( true );
	level.player AllowCrouch( true );
	level.player EnableWeapons(); 
	
	SetSavedDvar( "compass", 1 );
	SetSavedDvar( "ammoCounterHide", 0 );
	SetSavedDvar( "actionSlotsHide", 0 );
	SetSavedDvar( "hud_showStance", 1 );
	
	leader_start_node = GetNode( "streets_leader_start_node", "targetname" );
	
    level.allies[ 0 ] Unlink();
	level.allies[ 0 ] SetGoalNode( leader_start_node );
    level.allies[ 0 ].ignoresuppression = true;
    level.allies[ 0 ].disableBulletWhizbyReaction = true;
	   
    flag_set( "infil_done" );
}

helo_01_others()
{
    ally_1_start_node = GetNode( "streets_ally_1_start_node", "targetname" );
    ally_2_start_node = GetNode( "streets_ally_2_start_node", "targetname" );
	
    level.allies[ 1 ] Unlink();
    level.allies[ 1 ] SetGoalNode( ally_1_start_node );
    level.allies[ 1 ].ignoresuppression = true;
    level.allies[ 1 ].disableBulletWhizbyReaction = true;
    
    level.allies[ 2 ] Unlink();
    level.allies[ 2 ] SetGoalNode( ally_2_start_node );
    level.allies[ 2 ].ignoresuppression = true;
    level.allies[ 2 ].disableBulletWhizbyReaction = true;
}

helo_02_dismount( node )
{
	self Unlink();
	
	node anim_single_solo( self, "infil_dismount" );
	
	death_node = GetNode( "infil_redshirt_death", "targetname" );
	self.goalradius = 8;
   	self SetGoalNode( death_node );
   	self waittill( "goal" );
	self vignette_actor_delete();  	
}

chopper02_ally( death_node )
{
	self endon( "death" );
	
	self.ignoreall = 1;
	self.ignoreme = 1;
	self.goalradius = 8;
	
	// give the chopper a bit to get out of your way
	wait RandomFloatRange( 0.5, 0.7 );
	
   	self SetGoalPos( death_node );
   	self waittill( "goal" );
	self vignette_actor_delete();
}

unlink_ally_from_heli(guy)
{
	guy Unlink();
}

swap_hi_res_dam(timer)
{
	low_res_dam = getent("flood_dam", "targetname");
	low_res_dam hide();
	
	wait(timer);
	
	low_res_dam = getent("flood_dam", "targetname");
	low_res_dam show();
}

setup_dead_destroyed_and_misc()
{
	ents	 = GetEntArray( "infil_start_destroyed", "targetname" );
	foreach ( ent in ents )
	{
		vehicle	= vehicle_spawn( ent );
		vehicle Kill();
	}
	
	ents	 = GetEntArray( "infil_start_destroyed_lynx", "targetname" );
	foreach ( ent in ents )
	{
		ent Kill();
	}
	
	man7t = spawn_vehicle_from_targetname( "tanks_burning_man7t" );
	man7t godon();

//	thread create_dead_guys();
	
	// wait as this can get called before everything is created
	while( !IsDefined( level.tank_ally_joel ) )
		waitframe();

//	barrier = GetEnt( "barrier1", "script_noteworthy" );
//	if( IsDefined( barrier ) )
//		barrier thread rotate_barrier_when_near_tank( 215 );
//	
//	barrier = GetEnt( "barrier2", "script_noteworthy" );
//	if( IsDefined( barrier ) )
//		barrier thread rotate_barrier_when_near_tank( 245 );
//	
//	barrier = GetEnt( "barrier3", "script_noteworthy" );
//	if( IsDefined( barrier ) )
//		barrier thread rotate_barrier_when_near_tank( 216 );
	
	node = getstruct( "vignette_street_stop_sign_01", "script_noteworthy" );
	node thread crush_stop_sign_when_near_tank( 165 );
}

create_dead_guys()
{
	num_dead_allies = 10;
	num_dead_enemies = 8;
	
	ally_spawner = GetEnt( "dead_guy_ally", "targetname" );
	ally_nodes = GetNodeArray( "infil_dead_ally_node", "targetname" );
	
	for( i = 0; i < num_dead_allies; i++ )
	{
		node = ally_nodes[ RandomInt( ally_nodes.size ) ];
		ally_nodes = array_remove( ally_nodes, node );

		ally_spawner add_spawn_function( ::dead_guy_spawn_func );
		dead_guy = ally_spawner spawn_ai();
		dead_guy ForceTeleport( node.origin, ( 0, 0, RandomFloat( 300 ) ) );
		
		waitframe();
	}
}

dead_guy_spawn_func( node )
{
    self.allowdeath = true;
    self.diequietly = true;
    self Kill();
}

setup_initial_ai()
{
	street_start_allies = GetEntArray( "street_start_allies", "targetname" );
	foreach( ally_spawner in street_start_allies )
	{
		ally_spawner add_spawn_function( ::infil_redshirts_spawn_func );
		ally_spawner delayThread( level.infil_global_offset + 0, ::spawn_ai );
	}

	// FIX JKU kinda hacky, don't hide the after collision for the tank because the player could be standing in it when it's turned on.  probably not too big of a deal to leave it this way.
	// if re-enabled this will need to be adjusted below as well where it's actually turned on.
//	col = GetEnt( "lynx_smash_col_after", "targetname" );
//	col Hide();
//	col NotSolid();
	
	// Wait until TFF is loaded	
	flag_wait( "flood_intro_tr_loaded" );
	
	level.lynx_smash_array						  = [];
	level.lynx_smash_array[ "lynx_smash"		] = spawn_anim_model( "lynx_smash" );
	level.lynx_smash_array[ "lynx_smash_debris" ] = spawn_anim_model( "lynx_smash_debris" );
	
	node = GetEnt( "lynx_smash_node", "targetname" );
	node thread maps\_anim::anim_first_frame( level.lynx_smash_array, "lynx_smash" );

	level.tank_window_array										= [];
	level.tank_window_array[ "flood_tank_battle_barrier_01"	  ] = spawn_anim_model( "flood_tank_battle_barrier_01" );
	level.tank_window_array[ "flood_tank_battle_barrier_02"	  ] = spawn_anim_model( "flood_tank_battle_barrier_02" );
	level.tank_window_array[ "flood_tank_battle_window_frame" ] = spawn_anim_model( "flood_tank_battle_window_frame" );
	level.tank_window_array[ "flood_tank_battle_tankdebris"	  ] = spawn_anim_model( "flood_tank_battle_tankdebris" );
	
	node = GetEnt( "tank_window_node", "targetname" );
	node thread maps\_anim::anim_first_frame( level.tank_window_array, "tank_window" );
}

enemy_tank_shoot_flyin_choopers()
{
	self endon( "death" );
	self endon( "end flyin script" );
	
	self SetMode( "manual" );
	
	while( !flag( "infil_done" ) )
	{
		self StartFiring();
		self SetTargetEntity( level.infil_heli_player, ( 0, 180, 80 ) );

		wait 1;

		self SetMode( "manual" );
		self StopFiring();
		self StopBarrelSpin();

		wait RandomFloatRange( 0.5, 1 );

		self SetTargetEntity( level.infil_heli_ally, ( 0, 0, -80 ) );
		self StartFiring();

		wait 1;
		
		self SetMode( "manual" );
		self StopFiring();
		self StopBarrelSpin();
		
		wait RandomFloatRange( 0.5, 1 );
	}
	
	self StopFiring();
	self StopBarrelSpin();
	self ClearTargetEntity();
	self TurretFireDisable();
}

// check wether the player has moved forward and if the allies should move forward with him as we want them to wait a bit for the tank.
allies_first_advance()
{
	flag_wait_all( "enemy_tank_killed", "allies_first_advance" );
	
	activate_trigger( "allies_first_advance", "targetname" );
}

infil_sidestreet()
{
	sidestreet_array = getstructarray( "infil_sidestreet_bullet_array", "targetname" );
	
	// removed for now because you can't even see them
	/*
	spawners = GetEntArray( "infil_tanks_sidestreet", "targetname" );
	foreach( spawner in spawners)
	{
		ent  = spawner spawn_vehicle_and_gopath();
		ent Vehicle_SetSpeedImmediate( 10, 999 );
	}
	*/
	
	chopper = spawn_vehicle_from_targetname_and_drive( "infil_heli_flyby01" );
	chopper Vehicle_SetSpeedImmediate( 60, 999 );
	chopper godon();
//	chopper delayThread( 2.95, ::get_origin_for_rpg );
	crash_node = getstruct( "infil_chopper_crash01", "targetname" );
	chopper.perferred_crash_location = crash_node;
	chopper delayThread( 3.25, ::kill_intro_chopper );
	
//	MagicBullet( "rpg_straight", sidestreet_array[ 0 ].origin, ( 8877.4, -9492.91, 1837.82 ) );	// exact
	MagicBullet( "rpg_straight", sidestreet_array[ 0 ].origin, ( 8877.4, -9450, 1890) );

	chopper = spawn_vehicle_from_targetname_and_drive( "infil_heli_flyby02" );
	chopper Vehicle_SetSpeedImmediate( 60, 999 );
	chopper godon();
	noself_delayCall( 1.5, ::MagicBullet, "rpg_straight", sidestreet_array[ 1 ].origin, chopper.origin + ( 0, 0, 100 ) );
	
	chopper = spawn_vehicle_from_targetname( "infil_heli_flyby03" );
	chopper delayThread( 3, ::gopath );
	noself_delayCall( 5, ::MagicBullet, "rpg_straight", sidestreet_array[ 0 ].origin, chopper.origin + ( 0, 0, 600 ) );
	
	jets = spawn_vehicles_from_targetname_and_drive( "infil_flyin_jet" );
	foreach( jet in jets )
		jet godon();

	chopper = delayThread( 12, ::spawn_vehicles_from_targetname_and_drive, "tanks_landing_chopper_flyby" );
}

get_origin_for_rpg()
{
	JKUprint( self.origin );
}

kill_intro_chopper()
{
//	self maps\_vehicle_code::turn_unloading_drones_to_ai();
//	
//	wait 1;
//	
//	foreach( rider in self.riders )
//	{
//		rider Unlink();
//		rider.ragdoll_immediate = 1;
//		rider Kill();
//	}
//	
//	wait 1;
	
	self Kill();
}

tank_damage_player( dmg, no_offset )
{
	self endon( "death" );
	level.player endon( "death" );
	
	if( IsDefined( no_offset ) )
		dmg_radius = Spawn( "trigger_radius", self.origin, 0, 100, 100 );
	else
		dmg_radius = Spawn( "trigger_radius", self.origin + ( 130 * AnglesToForward( self.angles ) ), 0, 70, 70 );
		
	dmg_radius EnableLinkTo();
	dmg_radius LinkTo( self );
	
	while( IsDefined( dmg_radius ) )
	{
		dmg_radius waittill( "trigger" );
		
		while( level.player IsTouching( dmg_radius ) && IsAlive( level.player ) )
		{
			level.player DoDamage( dmg, level.player.origin );
			level.player PlayRumbleOnEntity( "damage_light" );
			wait 0.1;
		}
	}
}

#using_animtree( "vehicles" );
tank_battle()
{
	delayThread( level.infil_global_offset + 5.5, ::tank_wall_stuff );
	
	level.tank_ally_joel = spawn_vehicle_from_targetname_and_drive( "infil_tank_ally_joel" );
	level.tank_ally_joel godon();
	// FIX JKU why the hell do I need to delay this and why does it need to be more than one frame?
	level.tank_ally_joel delayThread( 0.25, ::mgoff );
	level.tank_ally_joel Vehicle_SetSpeed( 12, 6 );
	
	tank_spawner = GetEnt( "infil_tank_ally_pease", "targetname" );
	tank_ally_pease = tank_spawner spawn_vehicle_and_gopath();
	tank_ally_pease Vehicle_SetSpeed( 12, 12 );
	tank_ally_pease godon();

	enemy_tank = spawn_vehicle_from_targetname( "enemy_tank_infil_destroyed" );
	enemy_tank godon();
	enemy_tank mgoff();
	enemy_tank.mgturret[ 1 ] thread enemy_tank_shoot_flyin_choopers();
		
	wait 0.5;
	
	enemy_tank thread fire_cannon_at_target( tank_ally_pease, 1, ( 0, 220, -12 ) );
	
	wait 1.5;
	
	tank_ally_pease thread fire_cannon_at_target( enemy_tank, 1, ( 0, -200, 10 ) );
	delayThread( 0.75, ::exploder, "tank_debri_hit_02" );

	wait 1.25;
	
	enemy_tank thread fire_cannon_at_target( tank_ally_pease, 1, ( 0, 0, 45 ) );
	
	wait 0.85;
	
	PlayFXOnTag(GetFX("tank_fire_ground_dust"), tank_ally_pease, "tag_origin");

	tank_ally_pease Kill();
	level.tank_ally_joel Vehicle_SetSpeed( 5 );
	delayThread( 2, ::activate_trigger_with_targetname, "redshirts_first_advance" );
	
	wait 1.5;
	
	level.tank_ally_joel Vehicle_SetSpeed( 10.5, 6 );

	wait 1;

	// MMason tanks change
	level.tank_ally_joel mgon();
	level.tank_ally_joel.mgturret[ 0 ] SetTargetEntity( enemy_tank, ( 0, 0, 45 ) );
	level.tank_ally_joel thread fire_cannon_at_target( enemy_tank, 1, ( 0, 120, 20 ) );
	delayThread( 0.75, ::exploder, "tank_debri_hit_01" );
	
	wait 2;

	// MMason tanks change
	level.tank_ally_joel.mgturret[ 0 ] delayCall( 1.25, ::ClearTargetEntity );
	level.tank_ally_joel.mgturret[ 0 ] delayCall( 1.25, ::StopFiring );
	level.tank_ally_joel fire_cannon_at_target( enemy_tank, 1, ( 0, 0, 45 ) );
	
	wait 0.85;
	
	//IPrintLnBold( "tank 1 explosion" );
	//PlayFXOnTag(GetFX("flood_big_tank_explosion"), enemy_tank, "tag_origin");

	PlayFXOnTag(GetFX("tank_fire_ground_dust"), enemy_tank, "tag_origin");
	exploder( "tank_explosion_01" );
	enemy_tank Kill();

	wait 3.5;
    
	level.enemy_tank_wall thread fire_cannon_at_target( level.tank_ally_joel, 2, ( 0, 0, 45 ) );

	wait 2;
// MMason tanks change
	level.tank_ally_joel.mgturret[ 0 ] delayCall( 1, ::SetTargetEntity, level.enemy_tank_wall, ( 0, 0, 45 ) );
	
	wait 2.5;
	
	level.tank_ally_joel Vehicle_SetSpeed( 0, 6 );
	level.tank_ally_joel fire_cannon_at_target( level.enemy_tank_wall, 1, ( 0, 0, 45 ) );
	
	wait 0.5;
	
	PlayFXOnTag(GetFX("tank_fire_ground_dust"), level.enemy_tank_wall, "tag_origin");
	exploder( "tank_explosion_02" );

	//IPrintLnBold( "tank 1 explosion" );
	//PlayFXOnTag(GetFX("flood_big_tank_explosion"), level.enemy_tank_wall, "tag_origin");

	level.enemy_tank_wall Kill();
	flag_set( "enemy_tank_killed" );

	level.tank_ally_joel Vehicle_SetSpeed( 10.5, 6 );
	// MMason tanks change
	level.tank_ally_joel.mgturret[ 0 ] ClearTargetEntity();
	level.tank_ally_joel.mgturret[ 0 ] StopFiring();
	level.tank_ally_joel.mgturret[ 0 ] SetConvergenceHeightPercent( 0.25 );
	level.tank_ally_joel.mgturret[ 0 ] delayCall( 2, ::SetMode, "auto_nonai" );
	level.tank_ally_joel.mgturret[ 0 ] delayCall( 6, ::SetConvergenceHeightPercent, 1 );
	level.tank_ally_joel.mgturret[ 0 ] delayThread( 6, ::mg_turret_do_something_while_waiting_for_player );
	
	nags	= [];
	//Price: Keep up with team!
	nags[ 0 ] = "flood_pri_keepupwithteam";
	level.allies[ 0 ] delayThread( 15, maps\flood_util::play_nag, nags, "player_at_corner", 25, 50, 1, 2 );
	
	// straighten out the tank turret so it doesn't clip through the tree and lightpole
	level.tank_ally_joel delayCall( 2, ::SetTurretTargetVec, AnglesToForward( level.tank_ally_joel.angles ) );
	
	// FIX JKU can I sprint ahead and see these guys spawned?
	// FIX JKU these guys should be invulnerable or something like it until the player gets there
	enemies = GetEntArray( "streets_enemy_tank_soldiers_2", "targetname" );
    foreach( enemy_spawner in enemies )
    {
        enemy_spawner add_spawn_function( ::enemy_tank_soldiers_2_init );
		enemy_spawner spawn_ai();
    }
	
	level thread activate_trigger_with_targetname( "corner_start" );

	wait 1;
	
	level thread autosave_now();

	garage_nodes = GetNodeArray( "path_to_garage_node", "targetname" );
	foreach ( node in garage_nodes )
		node DisconnectNode();
	
	tank_at_corner = GetVehicleNode( "allied_tank_corner_start", "targetname" );
	tank_at_corner waittill( "trigger");

	//Tank Commander: I need visual on targets
	level thread smart_radio_dialogue( "flood_tnk_ineedvisualon" );
	//Tank Commander: One-Three engage left! Gunner, we've got right!
	level thread smart_radio_dialogue( "flood_tnk_onethreeengageleftgunner" );
	
	animation = %flood_tank_battle_lynx_smash_tank;
//	animation = level.tank_ally_joel getanim( "lynx_smash_tank" );
	
	anim_point = GetEnt( "lynx_smash_node", "targetname" );
	struct = SpawnStruct();
	struct.origin = GetStartOrigin( anim_point.origin, anim_point.angles, animation );
	struct.angles = GetStartAngles( anim_point.origin, anim_point.angles, animation );
	
	level.tank_ally_joel Vehicle_OrientTo( struct.origin, struct.angles, 0, 0.0 );
	level.tank_ally_joel waittill( "orientto_complete" );
	level.tank_ally_joel Vehicle_SetSpeedImmediate( 0 );
	
	////////////////////////////////////////////////////
	//                                                //
	//      ********  PLAYER AT CORNER  ********      //
	//                                                //
	////////////////////////////////////////////////////
	
	flag_wait( "player_at_corner" );
	
	// MMason tanks change
	level.tank_ally_joel.mgturret[ 0 ] SetMode( "manual" );
	level.tank_ally_joel.mgturret[ 0 ] StopBarrelSpin();
	
    tank_spawner = GetEnt( "enemy_tank_2", "targetname" );
	level.enemy_tank_2 = tank_spawner spawn_vehicle();
	level.enemy_tank_2 godon();
	level.enemy_tank_2 delayThread( 0.25, ::mgoff );
	level.enemy_tank_2 gopath();
	level.enemy_tank_2 Vehicle_SetSpeedImmediate( 6, 5 );
	
	tank_spawner = GetEnt( "enemy_tank_3", "targetname" );
	level.enemy_tank_3 = tank_spawner spawn_vehicle();
	level.enemy_tank_3 godon();
	level.enemy_tank_3 delayThread( 0.25, ::mgoff );
	level.enemy_tank_3 gopath();
	level.enemy_tank_3 Vehicle_SetSpeedImmediate( 7, 5 );
	
	level delayThread( 9, ::spawn_vehicles_from_targetname_and_drive, "tanks_mainstreet_driveby" );
	
	// this wait is here to give you some time to fight before the tank takes care of it for you.
    wait 2;
	
    ally_tank_target = GetEnt( "tank_target_balcony", "targetname" );
	//Generic Soldier 13: On!
	level.tank_ally_joel thread smart_radio_dialogue_overlap( "flood_us12_on" );
	level.tank_ally_joel fire_cannon_at_target( ally_tank_target, 1, undefined, undefined, "flood_us7_away" );
	level thread kill_deathflag( "streets_wave_2a" );
	thread exploder( "tank_debri_hit_03" );
	wait 1.75;

    ally_tank_target = GetEnt( "tank_target_planters", "targetname" );
	//Generic Soldier 13: On!
	level.tank_ally_joel thread smart_radio_dialogue_overlap( "flood_us12_on" );
	level.tank_ally_joel fire_cannon_at_target( ally_tank_target, 1, undefined, undefined, "flood_us7_away" );
	thread exploder( "tank_debri_hit_04" );
	level thread maps\flood_streets::destroy_planter( "planter_06" );
	level thread maps\flood_streets::destroy_planter( "planter_08" );
	level thread kill_deathflag( "streets_wave_2b" );
//	level.tank_ally_joel delayCall( 1, ::SetTurretTargetVec, AnglesToForward( level.tank_ally_joel.angles ) );
	// MMason tanks change
	level.tank_ally_joel.mgturret[ 0 ] delayCall( 5.5, ::SetTargetEntity, level.enemy_tank_2, ( 0, 0, 45 ) );
	tanks_corner_target = GetEnt( "enemy_tank_2_garage_target", "targetname" );
	level.tank_ally_joel delayCall( 3, ::SetTurretTargetVec, tanks_corner_target.origin + ( 400, 0, 300 ) );
	level.tank_ally_joel delayCall( 10, ::SetTurretTargetEnt, level.enemy_tank_2 );
	
	level thread enemy_mg_pin_down_player( level.enemy_tank_2.mgturret[ 1 ], level.enemy_tank_3.mgturret[ 1 ] );
	
	//Generic Soldier 5: Two Targets at 10!
	level delayThread( 4, ::smart_radio_dialogue, "flood_gs5_twotargetsat10" );
	//Price: Enemy Armor! Get to cover!
	level delayThread( 4.1, ::smart_radio_dialogue, "flood_pri_enemyarmorgetto" );
	//Tank Commander: Gun left!
	level delayThread( 4.2, ::smart_radio_dialogue, "flood_tnk_gunleft" );

	level thread activate_trigger_with_targetname( "second_street_advance" );
	
	level thread animated_script_model( level.tank_ally_joel, anim_point, #animtree, animation );
	
	level.tank_ally_joel notify( "suspend_drive_anims" );
	level.tank_ally_joel AnimScripted( "tank_animation", anim_point.origin, anim_point.angles, animation );
	level.tank_ally_joel delayThread( 3, ::tank_damage_player, 50 );
	
	anim_point thread anim_single( level.lynx_smash_array, "lynx_smash" );
	thread maps\flood_audio::sfx_lynx_smash();
	wait 6;
	
	level.enemy_tank_2 fire_cannon_at_target( level.tank_ally_joel, 1, ( 200 * AnglesToForward( level.tank_ally_joel.angles ) ) + ( 0, 0, 32 ) );
	level thread smart_radio_dialogue( "flood_us8_werehit" );
	
	wait 1.5;
	
	level.enemy_tank_3 fire_cannon_at_target( level.tank_ally_joel, 1, ( 0, 0, 60 ) );
	
	foreach( rider in level.tank_ally_joel.riders )
		if ( IsDefined( rider.magic_bullet_shield ) )
			rider stop_magic_bullet_shield();
	
	level thread maps\flood_util::hide_models_by_targetname( "lynx_smash_col_before" );
	// FIX JKU kinda hacky, don't hide the after collision for the tank because the player could be standing in it when it's turned on.  probably not too big of a deal to leave it this way.
//	level thread maps\flood_util::show_models_by_targetname( "lynx_smash_col_after" );

	//Generic Soldier 6: Thompson is down!
	level thread smart_radio_dialogue( "flood_gs6_thompsonisdown" );
	
	PlayFXOnTag(GetFX("tank_fire_ground_dust"), level.tank_ally_joel, "tag_origin");

	level.tank_ally_joel Kill();
	
	flag_set( "allied_tank_killed" );
	
	// FIX JKU need to come back to this, should these guys ever be ignoring???
//	level.allies[ 0 ] thread react_correctly_to_tank_fire();
//	level.allies[ 1 ] thread react_correctly_to_tank_fire();
//	level.allies[ 2 ] thread react_correctly_to_tank_fire();
	
	level thread battlechatter_off("allies");
	
	//Price: We're pinned down by two enemy tanks. We need support!
	level thread smart_radio_dialogue( "flood_pri_werepinneddownby" );
	
	// FIX JKU this could be done a different way
	level thread set_flag_when_allies_in_position();
	level thread set_flag_after_timer( "allies_in_position", 5 );	

	flag_wait( "allies_in_position" );
	
	wait 2;

	//Generic Soldier 9: We're almost there.
	level thread smart_radio_dialogue( "flood_us9_werealmostthere" );

	wait 1;

	//Generic Soldier 9: Brace for impact!
	level thread smart_radio_dialogue( "flood_us9_braceforimpact" );
	
	ent = GetEnt( "enemy_tank_2_window_target", "targetname" );
	level.enemy_tank_3 fire_cannon_at_target( ent, 1 );
	thread exploder( "tank_debri_hit_05" );
	level thread kill_deathflag( "infil_ally_redshirt" );
	thread maps\flood_audio::sfx_tank_bust_wall();	
	
	wait 5;
	
	animation = %flood_tank_battle_window_tank;
	
	anim_point = GetEnt( "tank_window_node", "targetname" );
	struct = SpawnStruct();
	struct.origin = GetStartOrigin( anim_point.origin, anim_point.angles, animation );
	struct.angles = GetStartAngles( anim_point.origin, anim_point.angles, animation );

	allied_tank_2 = GetEnt( "allied_tank_2", "targetname" );
	allied_tank_2 = allied_tank_2 spawn_vehicle();
	allied_tank_2 godon();
	//level.tank_wall_sfx moveto( anim_point.origin, 0.02 );
	level.tank_wall_sfx linkto( allied_tank_2, "tag_origin", (120, 0, 100), (0, 0, 0) );

	level thread animated_script_model( allied_tank_2, anim_point, #animtree, animation );
	
	allied_tank_2 notify( "suspend_drive_anims" );
	allied_tank_2 AnimScripted( "tank_animation", anim_point.origin, anim_point.angles, animation );		
	allied_tank_2 thread tank_damage_player( 999 );
	allied_tank_2 thread tank_damage_player( 999, true );
	anim_point thread anim_single( level.tank_window_array, "tank_window" );
	thread maps\flood_fx::fx_tank_window_break();

	ent = GetEnt( "flag_remove_after_window_tank", "targetname" );
	ent trigger_off();
	ent = GetEnt( "streets_run_for_it", "targetname" );
	ent trigger_off();
	
	wait 2.63;
	
	barrier_col = GetEnt( "allied_tank_2_blocker", "targetname" );
	barrier_col NotSolid();
	
	level.enemy_tank_2.veh_pathdir = "reverse";
	level.enemy_tank_2.veh_transmission = "reverse";
	level.enemy_tank_2 StartPath();
	level.enemy_tank_2 Vehicle_SetSpeed( 5 );
	level.enemy_tank_2 vehicle_wheels_backward();	
	
	//Generic Soldier 10: Visual on targets!
	level thread smart_radio_dialogue( "flood_us10_visualontargets" );

	wait 0.5;
	
	//Generic Soldier 5: On!
	allied_tank_2 thread smart_radio_dialogue_overlap( "flood_gs5_on" );
	allied_tank_2 fire_cannon_at_target( level.enemy_tank_2, 1, ( 0, 0, 60 ), undefined, "flood_us8_away" );
	
	wait 0.5;
	
	level.enemy_tank_3.veh_pathdir = "reverse";
	level.enemy_tank_3.veh_transmission = "reverse";
	level.enemy_tank_3 StartPath();
	level.enemy_tank_3 Vehicle_SetSpeed( 5 );
	level.enemy_tank_3 vehicle_wheels_backward();	

	level.enemy_tank_2 Kill();
	
	//Generic Soldier 9: One Target down!
	level thread smart_radio_dialogue( "flood_us9_onetargetdown" );
	
	level thread set_flag_when_allies_in_garage();
	
	barrier_col ConnectPaths();
	foreach ( node in garage_nodes )
		node ConnectNode();

	level thread activate_trigger_with_targetname( "move_to_garage" );

	flag_set( "allies_run_for_garage" );
	
	//Price: Head to the Parking Garage!
	level.allies[ 0 ] thread smart_dialogue( "flood_pri_headtotheparking" );
	
	level.allies[ 0 ]thread allies_run_for_garage();
	level.allies[ 1 ]thread allies_run_for_garage();
	level.allies[ 2 ]thread allies_run_for_garage();

	wait 1;
	
	//Generic Soldier 9: Gun right!
	level thread smart_radio_dialogue( "flood_us9_gunright" );
	allied_tank_2 SetTurretTargetEnt( level.enemy_tank_3 );
	
	wait 0.5;
	
	level.enemy_tank_3 fire_cannon_at_target( allied_tank_2, 1, ( 0, 0, 60 ) );
	level.enemy_tank_3 Vehicle_SetSpeed( 0 );
	
	wait 0.5;
	
	ducks				= [];
	ducks[ ducks.size ] = "run_stumble";
	ducks[ ducks.size ] = "run_flinch";
	ducks[ ducks.size ] = "run_duck";
	
	for( i = 0; i < 3; i++ )
	{
		if( Distance2D( level.allies[ i ].origin, allied_tank_2.origin ) < 450 && level.allies[ i ].a.movement == "run" )
			level.allies[ i ] thread maps\flood_streets::stumble_anim( ducks[ i ] );
	}

	allied_tank_2 Kill();
	
	battlechatter_on("allies");
}

enemy_mg_pin_down_player( turret2, turret3 )
{
	level.player endon( "death" );
	
	turret2 SetMode( "manual" );
	turret3 SetMode( "manual" );
	
	while( 1 )
	{
		if( ( flag( "infil_player_in_open" ) || flag( "infil_player_in_open_behind_tank" ) ) && !flag( "allies_run_for_garage" ) )
		{
//			IPrintLn( "player in open" );
			
			if( IsAlive( turret2 ) )
			{
				turret2 SetTargetEntity( level.player );
				turret2 StartFiring();
				turret2 SetConvergenceTime( 0 );
			}
			
			turret3 SetTargetEntity( level.player );
			turret3 StartFiring();
			turret3 SetConvergenceTime( 0 );
		
			wait_player_not_in_open_or_needs_garage();
		}
		else if( !flag( "allies_run_for_garage" ) )
		{
//			IPrintLn( "player not in open" );
			
			if( IsAlive( turret2 ) )
			{
				turret2 StopFiring();
				turret2 StopBarrelSpin();
			}
			
			turret3 StopFiring();
			turret3 StopBarrelSpin();
			
			if( IsAlive( turret2 ) )
			{
				turret2.mg_target = turret2 enemy_mg_get_untargeted_random_target();
				turret2 thread enemy_mg_adjust_if_target_dies( turret2.mg_target );
				turret2 thread enemy_mg_burst_fire();
			}
			
			turret3.mg_target = turret3 enemy_mg_get_untargeted_random_target();
			turret3 thread enemy_mg_adjust_if_target_dies( turret3.mg_target );
			turret3 thread enemy_mg_burst_fire();
			
			flag_wait_any( "infil_player_in_open", "infil_player_in_open_behind_tank", "allies_run_for_garage" );
			
			if( IsAlive( turret2 ) )
				turret2.mg_target.is_currently_mg_target = undefined;

			turret3.mg_target.is_currently_mg_target = undefined;
		}
		else
		{
			nags	= [];
			//Vargas: Elias! Keep up!
			nags[ 0 ] = "flood_vrg_cmoneliaskeepup";
			//Merrick: Make a run for it!
			nags[ 1 ] = "flood_mrk_makearunfor";
			level.allies[ 1 ] delayThread( 15, maps\flood_util::play_nag, nags, "firing_garage_shot", 10, 30, 1, 2 );
			
			while( !flag( "firing_garage_shot" ) )
			{
//				IPrintLn( "player needs to get to garage" );

				turret3 enemy_mg_shoot_randomly_at_player_until_he_runs_for_it();
				
				// FIX JKU need to come back to this.  there are timing issues because you can run towards the garage right when the kool aid tank comes out
				// but the enemy tank will still be trying to shoot kool aid
				level.enemy_tank_3 SetTurretTargetEnt( level.player );
				turret3 SetConvergenceTime( 0 );
				turret3 SetTargetEntity( level.player, -100 * AnglesToForward( level.player.angles ) );
				turret3 StartFiring();
				turret3 SetTargetEntity( level.player );
				turret3 SetConvergenceTime( 3 );
				
				flag_waitopen( "infil_player_in_open" );
				flag_waitopen( "infil_player_in_open_behind_tank" );
			}

//			IPrintLn( "player finally in garage" );

			// FIX JKU need to reset all turrets here so they stop tracking you
			turret3 StopFiring();
			turret3 StopBarrelSpin();
		
//			ent = GetEnt( "enemy_tank_2_garage_target", "targetname" );
//			level.enemy_tank_3 FireWeapon( "tag_barrel", ent );
			level.enemy_tank_3 FireWeapon();
			break;
		}
		waitframe();
	}
}

enemy_mg_shoot_randomly_at_player_until_he_runs_for_it()
{
	self endon( "death" );
	level.player endon( "death" );
	level endon( "infil_player_in_open" );
	level endon( "infil_player_in_open_behind_tank" );
	level endon( "firing_garage_shot" );
	
	while( 1 )
	{
		self SetTargetEntity( level.player, ( RandomIntRange( -100, 100 ), RandomIntRange( -100, 100 ), RandomIntRange( -100, 100 ) ) );
		self StartFiring();
		
		wait RandomFloatRange( 4, 5.5 );

		self StopFiring();
		self StopBarrelSpin();

		wait RandomFloatRange( 1.5, 2 );
	}
}

wait_player_not_in_open_or_needs_garage()
{
	level.player endon( "death" );
	level endon( "firing_garage_shot" );
	
	while( 1 )
	{
		if( !flag( "infil_player_in_open" ) && !flag( "infil_player_in_open_behind_tank" ) || flag( "allies_run_for_garage" ) )
			break;
		else
			waitframe();
	}
}

enemy_mg_adjust_if_target_dies( target )
{
	self endon( "death" );
	level endon( "infil_player_in_open" );
	level endon( "infil_player_in_open_behind_tank" );
	level endon( "allies_run_for_garage" );
	level endon( "firing_garage_shot" );
	
	while( IsAlive( target ) )
		waitframe();
	
	self.mg_target = self enemy_mg_get_untargeted_random_target();
}

enemy_mg_burst_fire()
{
	self endon( "death" );
	level endon( "infil_player_in_open" );
	level endon( "infil_player_in_open_behind_tank" );
	level endon( "allies_run_for_garage" );
	level endon( "firing_garage_shot" );
	
	while( 1 )
	{
		wait RandomFloatRange( 3, 4 );

		self StopFiring();
		self StopBarrelSpin();

		wait RandomFloatRange( 1, 2.5 );
		
//		IPrintLn( "finding new target" );
		self.mg_target = self enemy_mg_get_untargeted_random_target();
	}
}

enemy_mg_get_untargeted_random_target()
{
	self endon( "death" );
	
	mg_targets = GetAIArray( "allies" );
	mg_targets = add_to_array( mg_targets, level.player );
	mg_target = mg_targets[ RandomInt( mg_targets.size ) ];
	have_ally = false;
	
	while( !have_ally )
	{
		if( !IsDefined( mg_target.is_currently_mg_target ) )
		{
			mg_target.is_currently_mg_target = true;
			self SetConvergenceTime( 2 );
			have_ally = true;
		}
		else
		{
			mg_target = mg_targets[ RandomInt( mg_targets.size ) ];
		}
		waitframe();
	}
	
//	if( IsPlayer( mg_target ) )
//	   IPrintLn( "player is target" );
//	else
//		IPrintLn( mg_target.unique_id );
	
	if( IsPlayer( mg_target ) )
	{
		self SetTargetEntity( mg_target );
	}
	else
	{
		if( IsDefined( mg_target.sprint ) && mg_target.sprint )
			self SetTargetEntity( mg_target );
		else
			self SetTargetEntity( mg_target, ( 0, 0, RandomIntRange( 16, 60 ) ) );
	}
	
	self StartFiring();
	
	if( IsDefined( self.mg_target ) )
		self.mg_target.is_currently_mg_target = undefined;

	return mg_target;
}

animated_script_model( vehicle, anim_point, animtree, animation )
{
	if ( GetDvarInt( "show_script_model" ) == 0 )
	{
		return;
	}

	offset = ( 0, -3000, 0 );
	ent = Spawn( "script_model", anim_point.origin );
	ent SetModel( vehicle.model );
	ent UseAnimTree( animtree );

	ent AnimScripted( "blah", anim_point.origin + offset, anim_point.angles, animation );
	
	vehicle waittill( "death" );
	wait( 1 );
	ent Delete();
}

allies_run_for_garage()
{
	self enable_sprint();
	
	self waittill( "in_garage" );
	
	wait 2.0;
	
	self disable_sprint();
}

tank_wall_stuff()
{
	convoy_array = spawn_vehicles_from_targetname( "enemy_convoy_vehicles_infil" );
	foreach( vehicle in convoy_array )
	{
		vehicle godon();
		vehicle delayThread( 7, ::gopath );
	}
	
	tank_spawner = GetEnt( "enemy_tank", "targetname" );
	enemy_tank = tank_spawner spawn_vehicle_and_gopath();
	level.enemy_tank_wall = enemy_tank;
	enemy_tank godon();
	enemy_tank mgoff();
//	enemy_tank Vehicle_SetSpeed( 10, 10, 2.5 );
	enemy_tank.mgturret[ 1 ] thread enemy_tank_shoot_flyin_choopers();
	
	enemies = GetEntArray( "streets_enemy_tank_soldiers", "targetname" );
	foreach( enemy in enemies )
	{
		enemy add_spawn_function( ::follow_tank_enemies_spawn_func );
		enemy spawn_ai();
	}
	
	tank_at_end = GetVehicleNode( "enemy_tank_wall_end", "targetname" );
	tank_at_end waittill( "trigger");

	enemy_tank.mgturret[ 1 ] notify( "end flyin script" );
	enemy_tank.mgturret[ 1 ] StopFiring();
	enemy_tank.mgturret[ 1 ] StopBarrelSpin();
	enemy_tank.mgturret[ 1 ] ClearTargetEntity();
	enemy_tank.mgturret[ 1 ] SetMode( "manual" );
	enemy_tank.mgturret[ 1 ] SetTargetEntity( level.tank_ally_joel, ( 0, 0, 45 ) );
}

infil_redshirts_spawn_func()
{
	if( !IsDefined( level.street_start_allies ) )
		level.street_start_allies = [];
	
	level.street_start_allies[ level.street_start_allies.size ] = self;
	self magic_bullet_shield( true );
    self.grenadeawareness = 0;
    self.ignoreexplosionevents = true;
    self.ignorerandombulletdamage = true;
    self.ignoresuppression = true;
    self.disableBulletWhizbyReaction = true;
    self disable_pain();
    self.dontavoidplayer = true;

    flag_wait( "allied_tank_killed" );
    
	self stop_magic_bullet_shield();
    self.grenadeawareness = 1;
    self.ignoreexplosionevents = false;
    self.ignorerandombulletdamage = false;
    self.ignoresuppression = false;
    self.disableBulletWhizbyReaction = false;
    self enable_pain();
    self.dontavoidplayer = false;
}

rpg_guy_shoot_flyin_choopers()
{
	spawner = GetEnt( "infil_rpg_guy_start", "targetname" );
	rpg_guy = spawner spawn_ai();
	
	rpg_guy endon( "death" );
	
	rpg_guy thread maps\flood_streets::remove_rpgs_on_death();
	rpg_guy magic_bullet_shield( true );
    rpg_guy.grenadeawareness = 0;
    rpg_guy.ignoreexplosionevents = true;
    rpg_guy.ignorerandombulletdamage = true;
    rpg_guy.ignoresuppression = true;
    rpg_guy.disableBulletWhizbyReaction = true;
    rpg_guy disable_pain();
    rpg_guy.ignoreall = 1;
    rpg_guy.ignoreme = 1;
    
    // need to wait a frame for the animated chopper positions to be updated from where they were spawned
    waitframe();

    pos = rpg_guy GetTagOrigin( "tag_flash" ) + ( 0, 0, 50 );
    target = getstruct( "rpg_guy_target1", "targetname" );
    noself_delayCall( 1, ::MagicBullet, "rpg_straight", pos + ( 0, 0, 50 ), target.origin );
   	rpg_guy anim_generic( rpg_guy, "rpg_reload" );
	MagicBullet( "rpg_straight", pos, level.player.origin + ( 0, 100, 100 ) );
   	rpg_guy anim_generic( rpg_guy, "rpg_reload" );
   	MagicBullet( "rpg_straight", pos, level.player.origin + ( 0, 100, 100 ) );
	rpg_guy.grenadeammo = 0;
		
	rpg_guy stop_magic_bullet_shield();
    rpg_guy.grenadeawareness = 1;
    rpg_guy.ignoreexplosionevents = false;
    rpg_guy.ignorerandombulletdamage = false;
    rpg_guy.ignoresuppression = false;
    rpg_guy.disableBulletWhizbyReaction = false;
    rpg_guy enable_pain();
    rpg_guy.ignoreall = 0;
    rpg_guy.ignoreme = 0;
    
	flag_wait( "enemy_tank_killed" );
    
	goal_volume = GetEnt( "streets_enemy_tank_soldiers_goal_volume_2", "targetname" );
	rpg_guy SetGoalVolumeAuto( goal_volume );
}

follow_tank_enemies_spawn_func()
{
	self endon("death");
	
	self thread enemies_attack_player_when_in_open();
	
	goal_volume = GetEnt( "streets_enemy_tank_soldiers_goal_volume", "targetname" );
	self SetGoalVolumeAuto( goal_volume );
	
//	self disable_pain();
	self magic_bullet_shield();
	self.ignoreall = 1;
	self.attackeraccuracy = 0;
	self.grenadeawareness = 0;
	self.ignoreexplosionevents = true;
	self.ignorerandombulletdamage = true;
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
	
	tank_past_wall = GetVehicleNode( "wall_tank_past_wall", "targetname" );
	tank_past_wall waittill( "trigger");

	self stop_magic_bullet_shield();

	flag_wait( "enemy_tank_killed" );
	
	self.ignoreall = 0;
	goal_volume = GetEnt( "streets_enemy_tank_soldiers_goal_volume_2", "targetname" );
	self SetGoalVolumeAuto( goal_volume );
	
	// give them some time to start running to the balcony
	wait 1;
	
//	self enable_pain();
//	self stop_magic_bullet_shield();
	self.attackeraccuracy = 1;
	self.grenadeawareness = 1;
	self.ignoreexplosionevents = false;
	self.ignorerandombulletdamage = false;
	self.ignoresuppression = false;
	self.disableBulletWhizbyReaction = false;
}

enemy_tank_soldiers_2_init()
{
	self endon("death");
    
	self thread enemies_attack_player_when_in_open();
	self thread enemies_magic_bullet_until_player_at_corner();
	
//    goal_volume = GetEnt( "streets_enemy_tank_soldiers_goal_volume_2", "targetname" );
//    self SetGoalVolumeAuto( goal_volume );
	
	self.health = 300;
    self magic_bullet_shield();
    self.attackeraccuracy = 0;
    self.grenadeawareness = 0;
    self.ignoreexplosionevents = true;
    self.ignorerandombulletdamage = true;
    self.ignoresuppression = true;
    self.disableBulletWhizbyReaction = true;
    self disable_pain();
    self.fixednode = 1;
    
    flag_wait( "player_at_corner" );
    
    self stop_magic_bullet_shield();
    self.attackeraccuracy = 1;
    self.grenadeawareness = 1;
    self.ignoreexplosionevents = false;
    self.ignorerandombulletdamage = false;
    self.ignoresuppression = false;
    self.disableBulletWhizbyReaction = false;
    self enable_pain();
    
    wait 2.5;
    
    self.fixednode = 0;
}

enemies_magic_bullet_until_player_at_corner()
{
	self endon( "death" );
	level endon( "player_at_corner" );
	
	while( 1 )
	{
		if( !flag( "player_at_corner" ) )
		{
			self waittill( "damage", damage, attacker, impact_vec, point, damageType, modelName, tagName );
			if( attacker == level.player )
				flag_set( "player_at_corner" );
		}
		waitframe();
	}
}

enemies_attack_player_when_in_open()
{
	self endon( "death" );
	
	while( 1 )
	{
		flag_wait_any( "infil_player_in_open", "infil_player_in_open_behind_tank" );
		
//		IPrintLn( "attackiing only player" );
		self.favoriteenemy = level.player;
		self.baseaccuracy = 50;

		flag_waitopen( "infil_player_in_open" );
		flag_waitopen( "infil_player_in_open_behind_tank" );

//		IPrintLn( "not attackiing only player" );
		self.favoriteenemy = undefined;
		self.baseaccuracy = 1;
	}
}

infil_heli_outside_city()
{
	helis = [];
	heli_array = GetEntArray("infil_blackhawk_outside_city", "targetname");
	foreach ( element in heli_array)
	{
		helis[helis.size] = element thread spawn_vehicle();
	}
	
	wait(3);
	
	foreach ( element in helis)
	{
		element thread gopath();
	}	
}

infil_convoy_outside_city()
{	
	vehs = [];
	veh_array = GetEntArray("infil_city_convoy", "targetname");
	foreach ( element in veh_array)
	{
		vehs[vehs.size] = element thread spawn_vehicle();
	}
	
	wait(6);
	
	foreach ( element in vehs)
	{
		element thread gopath();
	}	
}

//when allied tank is close to stop sign, set flag
crush_stop_sign_when_near_tank(distance)
{
	while(Distance2D(level.tank_ally_joel.origin, self.origin) > distance)
	{
		wait(.1);
	}
	
	flag_set("vignette_streets_stop_sign_01");
}

//rotates object from 0,90,0 back to it's placed rotation when allied tank is within distance
//barrier must be a script_model
rotate_barrier_when_near_tank( distance )
{
	end_rotation = self.angles;
	start_rotation = ( 0, 90, 0 );
	self.angles = start_rotation;
	
	while( Distance2D( level.tank_ally_joel.origin, self.origin ) > distance )
		waitframe();
	
	self RotateTo( start_rotation + ( 0, 0, -10 ), 0.2 );
	wait 0.2;
	self RotateTo( end_rotation, 0.6 );
	wait 0.6;
	self RotateTo( end_rotation + ( 0, 0, 5 ), 0.15 );
	wait 0.15;
	self RotateTo( end_rotation, 0.15 );
	wait 0.1;
	self RotateTo( end_rotation + ( 0, 0, -5 ), 0.1 );
	wait 0.1;
	self RotateTo( end_rotation, 0.1 );
}

 fire_cannon_at_target( shoot_at_this, number, offset, delay, away_vo )
{
	self endon( "death" );
	self endon( "stop_firing" );
	
	if( !IsDefined( number ) )
		number = 10000;

	if( !IsDefined( offset ) )
		offset = ( 0, 0, 0 );

	if( !IsDefined( delay ) )
		delay = RandomFloatRange( 1.5, 2 );

	while( IsDefined( shoot_at_this ) && number > 0 )
	{
		if( IsDefined( self ) )
		{
			self SetTurretTargetVec( shoot_at_this.origin + offset );
			self waittill( "turret_on_target" );
			if( IsDefined( away_vo ) )
			{
				self thread smart_radio_dialogue_overlap( away_vo );
			}
			self FireWeapon();
			PlayFXOnTag(GetFX("tank_fire_ground_dust"), self, "tag_origin");
		}
		
		number--;
		if( number > 0 )
			wait delay;
	}
}

set_flag_when_allies_in_garage()
{
	player = true;
	ally_0 = true;
	ally_1 = true;
	ally_2 = true;

	while(player|| ally_0 || ally_1 || ally_2)
	{
		trigger = getent("parking_garage_doorway", "targetname");
		trigger waittill("trigger", guy);
		
//		if(guy == level.player)
		if(level.player IsTouching(trigger))
		{
			player = false;	
		}
//		if(guy == level.allies[0])
		if(level.allies[0] IsTouching(trigger))
		{
			ally_0 = false;
			guy notify("in_garage");
		}
//		if(guy == level.allies[1])
		if(level.allies[1] IsTouching(trigger))
		{
			ally_1 = false;	
			guy notify("in_garage");
		}
//		if(guy == level.allies[2])
		if(level.allies[2] IsTouching(trigger))
		{
			ally_2 = false;	
			guy notify("in_garage");
		}
		
	}
	flag_set("everyone_in_garage");
//	PrintLn("done waiting");
}

mg_turret_do_something_while_waiting_for_player()
{
	level endon( "player_at_corner" );
	// MMason tanks change
	level.tank_ally_joel.mgturret[ 0 ] SetMode( "auto_nonai" );
	
	while( !flag( "player_at_corner" ) )
	{
		// MMason tanks change
		level.tank_ally_joel.mgturret[ 0 ] TurretFireDisable();
		level.tank_ally_joel.mgturret[ 0] StopBarrelSpin();
		wait RandomFloatRange( 3, 4.5 );
		level.tank_ally_joel.mgturret[ 0 ] TurretFireEnable();
		wait RandomFloatRange( 4.5, 7.5 );
	}
	
	level.tank_ally_joel.mgturret[ 0 ] SetMode( "manual" );
}

react_correctly_to_tank_fire()
{
	self.ignoresuppression = false;
	self.ignorerandombulletdamage = true;
	self.disableBulletWhizbyReaction = true;
	self.script_dontpeek = 1;
	self disable_pain();
}

set_flag_when_allies_in_position()
{
	foreach (guy in level.street_start_allies)
	{
		if(isdefined(guy))
		{
			guy PushPlayer(true);
		}
		
	}
	
	not_there_yet = true;
	while(not_there_yet && !flag("allies_in_position"))
	{
		number = 0;
		total = 0;
		volume = getent("ally_behind_planter", "targetname");
		foreach (guy in level.street_start_allies)
		{
			if(isdefined(guy))
			{
				if(guy istouching(volume))
				{
					number++;	
				}
				total++;
			}			
		}
		
		if(number >= total-1)
		{
			not_there_yet = false;	
		}
		wait(.1);
	}
	
	flag_set("allies_in_position");	
	
	foreach (guy in level.street_start_allies)
	{
		if(isdefined(guy))
		{
			guy PushPlayer(false);
		}
		
	}
}

set_flag_after_timer(flag_string, timer)
{
	wait(timer);
	flag_set(flag_string);	
}
	
kill_barriers_when_close( tank, Distance )
{
	tank endon( "death" );
	
	while ( Distance2D( tank.origin, self.origin ) > Distance )
	{
		wait( 0.1 );
		if ( !IsDefined( tank ) )
		{
			break;
		}
	}
	
	if ( IsDefined( tank ) )
	{
		self Delete();
	}
}

infil_flyin_battle_init()
{
	delayThread( 28, ::infil_flyin_battle );
	level thread notify_delay( "kill enemy tank", 37 );
	level thread notify_delay( "start tanks", 31 );
}

infil_flyin_battle()
{
	JKUprint( "start the battle" );
	
	destroyed_tanks			   = GetEntArray( "infil_flyin_battle_tank_destroyed", "targetname" );
	hummers					   = GetEntArray( "infil_flyin_battle_tank_ally_hummer", "targetname" );
	ally_moving_tanks		   = GetEntArray( "infil_flyin_battle_tank_ally", "targetname" );
	static_stuff			   = GetEntArray( "infil_flyin_battle_static", "targetname" );
	enemy_tank				   = GetEnt( "infil_flyin_battle_tank_enemy", "targetname" );
	enemy_tank_target		   = getstruct( "infil_flyin_battle_tank_enemy_target", "targetname" );
	enemy_tank_barrier_targets = getstructarray( "infil_flyin_battle_tank_enemy_barrier_target", "targetname" );
	ally_tank_aim			   = GetEnt( "infil_flyin_battle_tank_ally_aim", "targetname" );
	ally_tank_bridge_l		   = GetEnt( "infil_flyin_battle_tank_ally_bridge_l", "targetname" );
	ally_tank_bridge_r		   = GetEnt( "infil_flyin_battle_tank_ally_bridge_r", "targetname" );

	foreach( tank in destroyed_tanks )
	{
		tank Kill();
	}

	enemy_tank thread enemy_tank_spawn_func( enemy_tank_barrier_targets );
	
	ally_tank_aim delayCall( 6, ::SetTurretTargetVec, enemy_tank.origin );
    
	ally_tank_bridge_l add_spawn_function( ::tank_spawn_func, enemy_tank_target );
	ally_tank_bridge_l = ally_tank_bridge_l spawn_vehicle_and_gopath();
	
	ally_tank_bridge_r add_spawn_function( ::tank_spawn_func, enemy_tank_target );
	ally_tank_bridge_r = ally_tank_bridge_r spawn_vehicle_and_gopath();
	
	// FIX JKU make sure this isn't spawning multiple scripts
	foreach( hummer in hummers )
	{
		hummer add_spawn_function( ::hummer_spawn_func );
		hummer spawn_vehicle_and_gopath();
	}
	
	foreach( tank in ally_moving_tanks )
	{
		tank add_spawn_function( ::tank_moving_spawn_func );
		tank spawn_vehicle_and_gopath();
	}

	level waittill( "kill enemy tank" );
	JKUprint( "kill enemy tank" );
	enemy_tank Kill();
	exploder( "infil_tank_explode" );
}

enemy_tank_spawn_func( barrier_targets )
{
	self endon( "death" );
	
	while( 1 )
	{
		target = barrier_targets[ RandomIntRange( 0, barrier_targets.size ) ];
		self fire_cannon_at_target( target, 1 );
		wait RandomFloatRange( 1.5, 3.0 );
	}
}

tank_spawn_func( enemy_tank )
{
	self endon( "death" );
	
	self Vehicle_SetSpeed( 14, 14, 7 );
	
	// hmm, need to wait a sec because their speed starts out at 0
	wait 1;
	
	while( 1 )
	{
		if( self Vehicle_GetSpeed() < 1 )
		{
			self thread fire_cannon_at_target( enemy_tank );
			break;
		}
		waitframe();
	}
	
	level waittill( "kill enemy tank" );
	self notify( "stop_firing" );

	level waittill( "infil kill everything" );
	self Delete();
}

tank_moving_spawn_func()
{
	self endon( "death" );
	
	self Vehicle_SetSpeed( 0, 1, 1 );
	
	level waittill( "start tanks" );
	
	self Vehicle_SetSpeed( 14, 14, 7 );

	level waittill( "infil kill everything" );
	self Delete();
}

hummer_spawn_func()
{
	self endon( "death" );
	
	// hmm, need to wait a sec because their speed starts out at 0
	wait 1;

	while( 1 )
	{
		if( self Vehicle_GetSpeed() < 0.2 )
		{
			self JoltBody( self.origin + ( 0, 0, 64 ), 100 );
			break;
		}
		waitframe();
	}
			
	self vehicle_unload( "all" );

	level waittill( "infil kill everything" );
	self Delete();
}

infil_cleanup()
{
	level notify ( "infil kill everything" );
	
	ents = GetEntArray( "infil_cleanup", "script_noteworthy" );
	array_delete( ents );
}

tanks_cleanup()
{
	
	ents = GetEntArray( "tanks_cleanup", "script_noteworthy" );
	array_delete( ents );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

streets_start()
{
	level.street_start_allies = [];
    maps\flood_util::player_move_to_checkpoint_start( "streets_start" );
    
    //set_audio_zone( "flood_streets", 2 );    
    
    // spawn the allies
    maps\flood_util::spawn_allies();
}

streets()
{
	level thread autosave_now_silent();
	
	//thread set_audio_zone( "flood_streets", 2 );
	maps\flood_audio::sfx_flood_streets_emitters();
	
	SetSavedDvar("sm_sunSampleSizeNear", 0.25);
	
	level thread streets_battle_blackhawk();
	level thread blackhawk_countermeasure();
	
	level thread kill_player_past_tank();
	level thread kill_player_run_for_it();
	
	level thread maps\flood_streets::aim_missiles_2();
	level thread maps\flood_streets::hide_missile_launcher_collision();
	level thread maps\flood_streets::hide_spire();
	level thread maps\flood_streets::hide_garage_debris();
	level thread maps\flood_streets::garage_opening_collapse();
	
	// Wait until player nears the barriers
	trigger = getent("into_parking_garage", "targetname");
	trigger waittill("trigger");
	
	level notify( "end_streets" );
}

kill_player_past_tank()
{
	trigger = GetEnt( "streets_beyond_enemy_tank_2", "targetname" );
	trigger waittill( "trigger" );
	
	if( IsAlive ( level.enemy_tank_2 ) )
	{
		level.enemy_tank_2 FireWeapon();
		wait 0.25;
	}

	if( IsAlive ( level.enemy_tank_3 ) )
		level.enemy_tank_3 FireWeapon();
	
	wait 0.25;
	
	if( IsAlive ( level.enemy_tank_3 ) )
		level.player Kill( level.enemy_tank_3.origin, level.enemy_tank_3, level.enemy_tank_3 );
	else
		level.player Kill();
	
	setDvar( "ui_deadquote", &"FLOOD_TANKS_FAIL" );
}

kill_player_run_for_it()
{
	trigger = GetEnt( "streets_run_for_it", "targetname" );
	trigger waittill( "trigger" );
	
	if( IsAlive ( level.enemy_tank_2 ) )
	{
		level.enemy_tank_2 FireWeapon();
		wait 0.25;
	}

	if( IsAlive ( level.enemy_tank_3 ) )
		level.enemy_tank_3 FireWeapon();

	wait 0.25;

	if( IsAlive ( level.enemy_tank_3 ) )
		level.player Kill( level.enemy_tank_3.origin, level.enemy_tank_3, level.enemy_tank_3 );
	else
		level.player Kill();

	setDvar( "ui_deadquote", &"FLOOD_TANKS_FAIL" );
}

streets_battle_blackhawk()
{
	trigger = GetEnt( "trig_battle_blackhawk_fight", "targetname" );
	trigger waittill( "trigger" );
	
	thread streets_battle_fire_rocket( "streets_battle_blackhawk_rocket_1", "streets_battle_blackhawk_missile_impact_1" );
	wait( 0.9 );
	thread streets_battle_fire_rocket( "streets_battle_blackhawk_rocket_2", "streets_battle_blackhawk_missile_impact_2" );
	wait( 0.9 );
	thread streets_battle_fire_rocket( "streets_battle_blackhawk_rocket_3", "streets_battle_blackhawk_missile_impact_3" );
	
	wait( 1.4 );
	
	chopper = spawn_vehicle_from_targetname_and_drive( "streets_battle_blackhawk" );
	chopper.path_gobbler = true;
	chopper.script_vehicle_selfremove = true;
	chopper Vehicle_SetSpeed( 60 );

}

streets_battle_fire_rocket( rocket_name, impact_name )
{
	spawner = GetEnt( rocket_name, "targetname" );
	spawner thread add_spawn_function( ::postspawn_crash_blackhawk_rocket );
	rocket = spawner spawn_vehicle_and_gopath();
	
	rocket waittill( "reached_end_node" );
	
	impact = GetEnt( impact_name, "targetname" );
	PlayFX( level._effect[ "temp_missile_impact" ], impact.origin );
}

//MM not currently used
streets_crash_blackhawk()
{	
//	trigger = GetEnt( "trig_crash_blackhawk_fight", "targetname" );
//	trigger waittill( "trigger" );
//	
//	chopper = spawn_vehicle_from_targetname_and_drive( "streets_crash_blackhawk" );
//	chopper SetMaxPitchRoll( 30, 60 );
//	chopper SetYawSpeedByName( "slow" );
//	chopper.path_gobbler = true;
//	//chopper.script_vehicle_selfremove = true;
//
//	flag_init( "trig_crash_blackhawk" );
//	chopper thread crash_blackhawk_think();
}

postspawn_crash_blackhawk_rocket()
{	
	self SetModel( "projectile_rpg7" );
	fx = getfx( "rpg_trail" );
	PlayFXOnTag( fx, self, "tag_origin" );
	if ( IsDefined( self.script_sound ) )
	{
		if ( IsDefined( self.script_wait ) )
		{
			self delaycall( self.script_wait, ::PlaySound, self.script_sound );
		}
		else
		{
			self PlaySound( self.script_sound );
		}
	}
	else
	{
		self PlayLoopSound( "weap_rpg_loop" );
	}
	
	self waittill( "reached_end_node" );

	if ( IsDefined( self.script_exploder ) )
	{
		exploder( self.script_exploder );
	}
	else if ( IsDefined( self.script_fxid ) )
	{
		PlayFx( getfx( self.script_fxid ), self.origin, AnglesToForward( self.angles ) );
	}
	
	self Delete();
}

//MM not currently used
crash_blackhawk_think()
{
	self thread crash_blackhawk_fire_think();
	
	self SetHoverParams( 64, 10, 3 );
	
	//removing crashed helicopter for memory reasons
//	crash_model = GetEnt( "streets_crash_blackhawk_crash", "targetname" );
//	crash_model Hide();
	
	trigger = GetEnt( "trig_crash_blackhawk", "targetname" );
	trigger waittill( "trigger" );
	
	flag_set( "trig_crash_blackhawk_crash" );
	
	struct = getstruct( "streets_crash_blackhawk_death_spot", "targetname" );
	self.perferred_crash_location = struct;
	self.heli_crash_indirect_zoff = 300;
	self.preferred_crash_style = 0;
	self.no_rider_death = true;
	
	spawner = GetEnt( "streets_crash_blackhawk_rocket", "targetname" );
	spawner thread add_spawn_function( ::postspawn_crash_blackhawk_rocket );
	
	rocket = spawner spawn_vehicle_and_gopath();

	rocket waittill( "reached_end_node" );

	PlayFXOnTag( getfx( "blackhawk_explosion" ), self, "tag_engine_right" );
	self DoDamage( self.health, self.origin );

	// level.player PlayRumbleOnEntity( "grenade_rumble" );
	
	riders = self.riders;
	
	foreach( rider in self.riders )
	{
		self thread  maps\_vehicle_aianim::guy_idle( rider, rider.vehicle_position, true );
	}	

	wait( 0.2 );
	
	riders = array_randomize( riders );
	
	foreach ( rider in riders )
	{
		if ( !IsDefined( rider ) )
			continue;
		if ( !IsAlive( rider ) )
			continue;
			
		if ( rider.vehicle_position == 0 || rider.vehicle_position == 1 )
		{
			continue;
		}
			
		rider unlink();
		rider notify ( "newanim" );
		rider StopAnimScripted();
		rider.skipDeathAnim = true;
		rider Kill();
		rider StartRagdoll();
		wait( RandomFloatRange( 0.1, 0.3 ) );
	}
	
	self waittill( "crash_done" );
	
//	crash_model.origin = self.origin;
//	crash_model.angles = self.angles;
//	
//	crash_model Show();
	
	level waittill( "end_streets" );
	
//	crash_model Hide();
}

//MM not currently used
crash_blackhawk_fire_think()
{
	self endon( "death" );
	
	self thread crash_blackhawk_missile_impacts();
	
	target_org = GetEnt( "crash_blackhawk_target", "targetname" );
	
	current_origin = target_org.origin;
	
	//fire magic bullets from tag_barrel to target
    while(1)
    {	
    	endX = current_origin[ 0 ] + RandomIntRange( -25, 25 );
	    endY = current_origin[ 1 ] + RandomIntRange( -25, 25 );
	    endZ = current_origin[ 2 ];
	    
	    endPos = (endX, endY, endZ);
        
        bullet_start = self GetTagOrigin("tag_barrel");
        
        MagicBullet( "stinger_speedy", bullet_start, endPos );
        
       	wait( 1.0 );
    }
}

//MM not currently used
crash_blackhawk_missile_impacts()
{
    missile_impact_array = GetEntArray( "crash_blackhawk_missile_impact", "targetname" );
    
    while( 1 )
    {
    	if( flag( "trig_crash_blackhawk_crash" ) )
	   	{
	   		break;
	   	}
    	
    	chosen = RandomIntRange( 0, missile_impact_array.size - 1 );
    	
    	if ( IsDefined( missile_impact_array[ chosen ] ) )
        {
            PlayFX( level._effect[ "temp_missile_impact" ], missile_impact_array[ chosen ].origin );
        }
    	
	    missile_pause = RandomFloatRange( 2.25, 3.0 );
	    wait( missile_pause );
    }
}

blackhawk_countermeasure()
{
	trigger = GetEnt( "trig_countermeasure_blackhawk", "targetname" );
	trigger waittill( "trigger" );
	
	chopper = spawn_vehicle_from_targetname_and_drive( "streets_countermeasure_blackhawk" );
	chopper.script_vehicle_selfremove = true;
	chopper Vehicle_SetSpeedImmediate( 60 );
	countermeasure_fx = getfx( "chopper_countermeasure" );
	
	flare_pos_l = spawn_tag_origin();
	flare_pos_l.origin = chopper GetTagOrigin( "tag_light_l_wing" );
	flare_pos_l.angles = chopper GetTagAngles( "tag_light_l_wing" );
	flare_pos_l LinkTo( chopper );
	
	flare_pos_r = spawn_tag_origin();
	flare_pos_r.origin = chopper GetTagOrigin( "tag_light_r_wing" );
	flare_pos_r.angles = chopper GetTagAngles( "tag_light_r_wing" );
	flare_pos_r LinkTo( chopper );
	
	wait 2.75;

	for( i = 0; i < 5; i++ )
	{
//		maps\_debug::drawArrow( flare_pos_l.origin, flare_pos_l.angles, ( 0, 255, 0 ), 5000 );
//		maps\_debug::drawArrow( flare_pos_r.origin, flare_pos_r.angles, ( 0, 255, 0 ), 5000 );
//		PlayFXOnTag( countermeasure_fx, flare_pos_l, "tag_origin" );
//		PlayFXOnTag( countermeasure_fx, flare_pos_r, "tag_origin" );
		wait 0.3;
	}
	
	flare_pos_l Delete();
	flare_pos_r Delete();
}

nh90_convoy_choppers()
{
	crash_node = GetEnt( "convoy_helicopter_crash_location", "targetname" );
	
	trigger = GetEnt( "trig_enemy_convoy_choppers", "targetname" );
	trigger waittill( "trigger" );
	
	if(!flag("m880_has_spawned"))
	{	
		chopper = spawn_vehicle_from_targetname_and_drive( "streets_enemy_convoy_chopper1" );
		chopper Vehicle_TurnEngineOff();
		chopper thread maps\flood_audio::flood_convoy_chopper1_sfx();
		chopper.script_vehicle_selfremove = true;
		chopper Vehicle_SetSpeedImmediate( 60 );
		chopper.perferred_crash_location = crash_node;
		
		wait 2.5;
		
		chopper2 = spawn_vehicle_from_targetname_and_drive( "streets_enemy_convoy_chopper2" );
		chopper2 Vehicle_TurnEngineOff();
		chopper2 thread maps\flood_audio::flood_convoy_chopper2_sfx();
		chopper2.script_vehicle_selfremove = true;
		chopper2.perferred_crash_location = crash_node;
	
		wait 1;
		
	//	chopper3 = spawn_vehicle_from_targetname_and_drive( "streets_enemy_convoy_chopper3" );
	//	chopper3.script_vehicle_selfremove = true;
	//	chopper3.perferred_crash_location = crash_node;
	
		wait 2;
		
		chopper4 = spawn_vehicle_from_targetname_and_drive( "streets_enemy_convoy_chopper4" );
		chopper4 Vehicle_TurnEngineOff();
		chopper4 thread maps\flood_audio::flood_convoy_chopper4_sfx();
		chopper4.script_vehicle_selfremove = true;
		chopper4 HidePart( "door_R", chopper4.model );
		chopper4 HidePart( "door_R_handle", chopper4.model );
		chopper4 HidePart( "door_R_lock", chopper4.model );
		chopper4.perferred_crash_location = crash_node;
	}
}

flag_waitopen_any( msg, msg2 )
{
	while ( flag( msg ) )
		level waittill( msg );
}

aent_flag_waitopen_either( flag1, flag2 )
{
	AssertEx( ( !IsSentient( self ) && IsDefined( self ) ) || IsAlive( self ), "Attempt to check a flag on entity that is not alive or removed" );

	while ( IsDefined( self ) )
	{
		if ( !ent_flag( flag1 ) )
			return;
		if ( !ent_flag( flag2 ) )
			return;

		self waittill_either( flag1, flag2 );
	}
}

awaittill_either( msg1, msg2 )
{
	self endon( msg1 );
	self waittill( msg2 );
}
