#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_anim;
#include maps\black_ice_util;
#include maps\black_ice_vignette;
#include maps\black_ice_util_ai;

SCRIPT_NAME = "black_ice_tanks_to_mud_pumps.gsc";

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	flag_init( "flag_vignette_engineroom_workers_door" );
	flag_init( "flag_vignette_engineroom_workers_hallway" );
	flag_init( "flag_engine_room_hallway" );
	flag_init( "flag_top_drive_walkway" );
	flag_init( "flag_vision_mudpumps" );
	flag_init( "flag_vision_engine_room" );
	flag_init( "flag_tanks_end" );		
	flag_init( "flag_engine_room_end" );	
	flag_init( "flag_player_crouching" );
	flag_init( "flag_engine_room_nodamage" );
	flag_init( "flag_mudpumps_end" );
	flag_init( "flag_fire_damage_on" );
	flag_init( "flag_player_at_topdrive" );
}

section_precache()
{		
	add_hint_string( "hint_crouch", &"BLACK_ICE_ENGINE_ROOM_SMOKE_DUCK", ::hint_crouch );
	PrecacheString( &"BLACK_ICE_ENGINE_ROOM_SMOKE_DEATH" );
}

hint_crouch()
{
	return false || ((level.player GetStance() != "stand" ) || !flag( "flag_vision_engine_room" ));
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_post_inits()
{	
	level._tanks = SpawnStruct();
	level._engine_room = SpawnStruct();	

	level._engine_room.damage_smoke_ent = spawn_tag_origin();	
	
	// Spawn catwalk and pipe models
	level._tanks.struct_bridge = GetStruct( "struct_tanks_bridge_fall_scene", "targetname" );
	if( IsDefined( level._tanks.struct_bridge ))	
	{
		level._tanks.pipe = GetEnt( "model_tanks_pipe", "targetname" );
		level._tanks.pipe assign_animtree( "tanks_pipe" );
		level._tanks.bridge = GetEnt( "model_tanks_bridge", "targetname" );
		level._tanks.bridge assign_animtree( "tanks_bridge" );
		level._tanks.bridge_destroyed = GetEnt( "model_tanks_bridge_damaged", "targetname" );
		level._tanks.bridge_destroyed assign_animtree( "tanks_bridge" );
		level._tanks.bridge_destroyed Hide();
		
		// Hide parts for optimization
		if( start_point_is_before( "tanks" ))
			array_call( GetEntArray( "opt_hide_tanks", "script_noteworthy" ), ::Hide );
								
		// Attach bridge collision
		collision = GetEntArray( level._tanks.struct_bridge.target, "targetname" );
		Assert( collision.size > 0 );	
		foreach( col in collision )
			col LinkTo( level._tanks.bridge );
		
		// Set first frame
		guys = [ level._tanks.pipe, level._tanks.bridge_destroyed, level._tanks.bridge ];	
		level._tanks.struct_bridge anim_first_frame( guys, "tanks_bridge_fall_scene" );
		
		// Baker enter struct
		level._engine_room.baker_enter_struct = GetStruct( "struct_engine_room_baker_enter", "targetname" );
	}
	else
	{
		iprintln( SCRIPT_NAME + ": Warning - Tanks bridge struct missing (compiled out?)" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start_tanks()
{
	iprintln( "Tanks" );
	
	player_start( "player_start_tanks" );
	
	position_tNames = 
	[
		"struct_ally_start_tanks_01",
		"struct_ally_start_tanks_02"
	];
	
	exploder( "tanks_oil_rain" );
	exploder( "tanks_lights" );
	flag_set( "flag_fx_screen_bokehdots_rain" );
	level._allies teleport_allies( position_tNames );	
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_rain_med", 2 );	
}

start_engine_room()
{
	iprintln( "Engine Room" );
	
	flag_set( "flag_fire_damage_on" );
	
	player_start( "player_start_derrick" );
	
	position_tNames = 
	[
		"struct_ally_start_derrick_01",
		"struct_ally_start_derrick_02"
	];
	
	level._allies teleport_allies( position_tNames );	
	
	array_thread( level._allies, ::enable_cqbwalk );
	
	thread enemies_engineroom_entry_door_open();
	thread maps\black_ice_fx::engineroom_turn_on_fx();
	//TimS - removing these since we're moving to client triggers
	//thread set_audio_zone( "blackice_rain_med" );
	
	thread black_ice_geyser2_pulse();
	
	exploder( "tanks_oil_rain" );
	exploder( "tanks_lights" );
	stop_exploder( "refinery_lights" );
	
}

start_mudpumps()
{
	iprintln( "Mudpumps" );
	
	flag_set( "flag_fire_damage_on" );
	flag_set( "flag_fx_screen_bokehdots_rain" );
	
	player_start( "player_start_mudpumps" );
	
	position_tNames = 
	[
		"struct_ally_01_start_mudpumps",
		"struct_ally_02_start_mudpumps"
	];
	
	level._allies teleport_allies( position_tNames );	
			
	thread maps\black_ice_fx::engineroom_turn_on_fx();
	
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_rain_heavy", 2 );
	
	// thread ambient animations
	thread maps\black_ice_anim::ambient_derrick_animation();
	
	// Show destroyed derrick
	thread maps\black_ice_refinery::util_show_destroyed_derrick();
	
	thread black_ice_geyser2_pulse();
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

main_tanks()
{
	// Show hidden optimization geo
	array_call( GetEntArray( "opt_hide_tanks", "script_noteworthy" ), ::Show );
		
	thread dialogue_tanks();
	thread allies_tanks();
	thread enemies_tanks();	
	thread event_tanks_bridge_fall_scene();
	thread util_flicker_geyeser_light();	
	flag_wait( "flag_tanks_end" );	
}

main_engine_room()
{		
	thread dialogue_engine_room();
	thread allies_engine_room();
	thread enemies_engine_room();
	
	flag_clear( "flag_fx_screen_bokehdots_rain" );
	maps\_art::sunflare_changes("mudpumps",0.1);
	// thread ambient animations
	thread maps\black_ice_anim::ambient_derrick_animation();
	
	// Show destroyed derrick
	thread maps\black_ice_refinery::util_show_destroyed_derrick();	
	
	//Audio cleanup
	thread maps\black_ice_audio::sfx_delete_refinery_fire_nodes();
	thread maps\black_ice_audio::sfx_delete_refinery_alarm_node();			
	
	//fx_cleanup
	stop_exploder( "refinery_lights" );
	
	flag_wait( "flag_engine_room_end" );
}

main_mudpumps()
{			
	// Show hidden optimization geo
	array_call( GetEntArray( "opt_hide_derrick", "script_noteworthy" ), ::Show );
	
	thread event_topdrive_fall();	
	thread dialogue_mudpumps();
	thread allies_mudpumps();
	
	// Remove refinery geo
	thread maps\black_ice_refinery::util_refinery_stack_cleanup();
	
	if(is_gen4())
		thread maps\black_ice_anim::spawn_dead_bodies_mudpumps();
	
	flag_set( "flag_fx_screen_bokehdots_rain" );	
	
	//fx
	thread maps\black_ice_fx::fx_command_window_light_on();
	stop_exploder( "tanks_oil_rain" );
	stop_exploder( "tanks_lights" );
	
	flag_wait( "flag_mudpumps_end" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dialogue_tanks()
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
//	trigger_wait_targetname( "trig_tanks_enter" );
	
	// Oldboy - Dealer One, we've secured a helo for exfil.  Spooling up now.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_securedexfil" );
	
	// Merrick - Check.  We’re two mikes from the command room.  Coming up on the North side.
	smart_radio_dialogue( "blackice_diz_inoursights" );
	
	// Oldboy - We'll be waitin' for ya.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_commandcenter" );
}

dialogue_engine_room()
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level waittill( "notify_dialogue_stay_low" );
	
	level._allies [0 ] smart_dialogue( "blackice_bkr_staylowmovefast" );
	
	level waittill( "notify_vignette_death" );
	
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
}

dialogue_mudpumps()
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	flag_wait( "flag_top_drive_walkway" );
	
	// Dialogue - Oldboy - One-One, We're on station.  Ready for targets.
	smart_radio_dialogue( "black_ice_oby_oneonewereonstation" );
	
	// Dialogue - Merrick - Copy that.  Just keep an eye on us.
	level._allies[ 0 ] smart_dialogue( "black_ice_mrk_copythatjustkeep" );
	
	// Dialogue - Baker - Keegan and Oldboy have a helo for exfil, so watch your fire.
	level._allies[ 0 ] smart_dialogue( "black_ice_mrk_keeganandoldboyhave" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies_tanks()
{			
	ally1 = level._allies[ 0 ];	
	ally1 PushPlayer( true );
	
	array_thread( level._allies, ::ally_catchup );
	
	flag_wait( "flag_tanks_engineroom_door" );	
	
	array_thread( level._allies, ::ally_catchup );
	
	trigger_wait_targetname( "trig_baker_kill_door_guys" );
	
	// Merrick cleans up door guys
	if( level._enemies[ "engine_room_door" ].size > 0 )
	{
		level notify( "notify_stop_engineroom_entry_timeout" );
		wait( 1 );
		ally1 ally_cqb_kill( "engine_room_door" );
		ally1 disable_cqbwalk();		
	}		
	
	flag_set( "flag_tanks_end" );
	
	// Merrick moves into engine room
	struct_engine_room_enter = level._engine_room.baker_enter_struct;			
	struct_engine_room_enter anim_reach_solo( ally1, "engine_room_enter" );
	level notify( "notify_dialogue_stay_low" );
	struct_engine_room_enter anim_single_solo( ally1, "engine_room_enter" );	
	ally1 enable_ai_color();			
	ally1 enable_cqbwalk();	
	
	// Set new color nodes for allies
	activate_trigger_with_targetname( "trig_allies_engine_room_enter" );
}

allies_engine_room()
{		
	level._engine_room.vol = "vol_retreat_engine_room_1";
	
	level._allies thread ally_advance_watcher( "trig_allies_engine_room_start", "engine_room_extinguisher" );
	
	level._allies[ 0 ] PushPlayer( true );
	array_thread( level._allies, ::disable_pain );
	array_thread( level._allies, ::util_set_max_visible_dist );
	level.player util_set_max_visible_dist();
	
	level._allies[ 0 ] ignore_everything();
		
	if( level.start_point == "engine_room" )
	{
		level notify( "notify_dialogue_stay_low" );
		activate_trigger_with_targetname( "trig_allies_engine_room_enter" );
		level._engine_room.baker_enter_struct anim_single_solo( level._allies[ 0 ], "engine_room_enter" );
		level._allies[ 0 ] enable_ai_color();
		level._allies[ 0 ] enable_cqbwalk();
	}
	
	flag_wait( "flag_vignette_engineroom_workers_hallway" );	

	// Give Merrick a breather before firing
	wait( 2 );
	
	// Baker kills first engine room guy
	if( level._enemies[ "engine_room_extinguisher" ].size == 3 )
	{
		level._allies[ 0 ] ally_cqb_kill( "engine_room_extinguisher", 256, 1, true );
		wait( 0.5 );
		level._allies[ 0 ] unignore_everything();
	}	
	
	array_thread( level._allies, ::set_ignoresuppression, true );
	
	activate_trigger_with_targetname( "trig_engine_room_hallway" );		
			
	flag_wait( "flag_engine_room_end" );
	
	array_thread( level._allies, ::enable_pain );		
	array_thread( level._allies, ::util_clear_max_visible_dist );	
	array_thread( level._allies, ::set_ignoresuppression, false );
	level.player util_clear_max_visible_dist();
}

allies_mudpumps()
{
	level._allies[ 0 ].goalradius = 16;
	
	flag_wait( "flag_mudpumps_end" );
	
	level._allies[ 0 ].goalradius = 2048;
}
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

util_set_max_visible_dist()
{
	self.maxvisibledist_old = self.maxvisibledist;
	self.maxvisibledist = 384;	
}

util_clear_max_visible_dist()
{
	self.maxvisibledist = self.maxvisibledist_old;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// Watches for when player is above or below smoke
player_smoke_duck()
{
	self endon( "notify_stop_player_smoke_duck" );
	
	standing = false;	
	
	thread maps\black_ice_fx::engineroom_headsmoke_fx_start();
	thread maps\black_ice_fx::engineroom_heat_fx_shake();
	
	hint_shown = false;		
	
	flag_set( "flag_player_crouching" );
	
	while( 1 )
	{
		if( self GetStance() == "stand" )
		{
			if( !hint_shown )
			{
				thread player_smoke_hint();
				hint_shown = true;
			}
			
			if( flag( "flag_player_crouching" ))
			{
				flag_clear( "flag_player_crouching" );
				//setExpFog( 4, 50, 0.4, 0.2, 0.1, 0.1, 0.5 );
				//fog_set_changes("black_ice_smokehigh",0.5);
				SetBlur( 0.5, 0.5 );	
				self thread player_cough_rumble();				
				self thread player_cough_sound();
				self thread player_cough_damage();
			}			
		}
		else if( !flag( "flag_player_crouching" ) )
		{						
			flag_set( "flag_player_crouching" );
			//setExpFog( 7, 50, 0.4, 0.2, 0.1, 0.05, 0.5 );
			//fog_set_changes("black_ice_smokelow",0.5);
        	SetBlur( 0, 0.5 );			         	
		}
		wait( 0.05 );
	}
}
		
player_smoke_hint()
{
	self endon( "notify_stop_player_smoke_duck" );
	
	//wait to clear the transition zone
	while( flag( "flag_engine_room_nodamage" ))
	{
		wait( level.TIMESTEP );
	}
	
	display_hint( "hint_crouch" );	
}

player_cough_damage()
{
	self endon( "notify_stop_player_smoke_duck" );
	level endon( "flag_player_crouching" );
		
	while( 1 )
	{
		if( self.health > 40 )
		{
			if( !flag( "flag_engine_room_nodamage" ) )
				self DoDamage( 40, level.player.origin, level._engine_room.damage_smoke_ent );
		}
		else
		{
			if( !flag( "flag_engine_room_nodamage" ) )
			{
			level.player kill();
			
			setdvar( "ui_deadquote", &"BLACK_ICE_ENGINE_ROOM_SMOKE_DEATH" );
			maps\_utility::missionFailedWrapper();
		}
		}
		wait( 1 );
	}
}

player_cough_rumble()
{	
	rumbling = false;
	while( !flag( "flag_player_crouching" ) && flag( "flag_vision_engine_room" ))
	{
		if( !flag( "flag_engine_room_nodamage" ) )
		{
			//IPrintLnBold( "norumble!" );
			if( rumbling == false  )
			{	
				//IPrintLnBold( "rumbleFOREREALLL!" );
				self PlayRumbleLoopOnEntity( "tank_rumble" );	
				rumbling = true;
			}
		}
		else
		{
			//IPrintLnBold( "norumble!" );
			if( rumbling == true )
			{
				//IPrintLnBold( "norumbleFORREALLL!" );				
				StopAllRumbles();
				rumbling = false;
			}
	
		}
		wait( level.TIMESTEP );
	}
	
	StopAllRumbles();
}

player_cough_sound()
{	
	self endon( "notify_stop_player_smoke_duck" );
	level endon( "flag_player_crouching" );
	
	while( 1 )
	{				
		if( !flag( "flag_engine_room_nodamage" ) )
		smart_radio_dialogue( "blackice_plr_cough" );
		wait( 0.05 );
	}
}

player_smoke_duck_end()
{
	thread maps\black_ice_fx::engineroom_headsmoke_fx_end();
	self notify( "notify_stop_player_smoke_duck" );
	flag_set( "flag_player_crouching" );
	StopAllRumbles();		
	SetBlur( 0, 0.5 );	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies_tanks()
{		
	level._enemies[ "engine_room_door" ] = [];	
	thread enemies_engineroom_entry();	
	array_spawn_function_targetname( "enemies_tanks_01", ::spawnfunc_enemy_tanks );
}
	
spawnfunc_enemy_tanks()
{
	self.ignoreall = true;
	self.ignoreme = true;
	self.goalradius = 8;
	
	if( !IsDefined( self.target ))
	{
		command_vol = GetEnt( "vol_retreat_refinery_final", "targetname" );
		if( IsDefined( command_vol ))
			self SetGoalVolumeAuto( command_vol );
	}

	self waittill( "goal" );
	self delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies_engine_room()
{		
	thread enemies_engineroom_extinguisher( "engine_room_extinguisher" );	

	array_spawn_function_targetname( "spawner_engine_room_extinguish", ::spawnfunc_engine_room_extinguisher_guys );			
	array_spawn_function_targetname( "spawner_engine_room_attack", ::spawnfunc_engine_room_reinforcements );		
	array_spawn_function_targetname( "spawner_engine_room_attack_retreat", ::spawnfunc_engine_room_reinforcements_2 );
	
	thread enemies_engine_room_reinforcements();

	// Enemy second positions
	trigger_wait_targetname( "trig_allies_engine_room_start" );	
	level._engine_room.vol = "vol_retreat_engine_room_2";
	thread retreat( "engine_room_extinguisher", level._engine_room.vol );	
	
	// Send guys packing
	trigger_wait_targetname( "trig_allies_engine_room_end" );
	enemies = remove_dead_from_array( level._enemies[ "engine_room_extinguisher" ] );		
	array_thread( enemies, ::disable_cqbwalk );	
	thread retreat( "engine_room_extinguisher", "vol_retreat_derrick_2" );
	thread AI_delete_when_out_of_sight( level._enemies[ "engine_room_extinguisher" ], 256 );
}

enemies_engine_room_reinforcements()
{
	// Reinforcements
	level waittill( "notify_spawn_reinforcements" );
	array_spawn_targetname( "spawner_engine_room_attack" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_tanks_bridge_fall_scene()
{	
	trigger_wait_targetname( "trig_tanks_enter" );
	
	//trigger_wait_targetname( "trig_tanks_bridge" );
	flag_set( "flag_tanks_catwalk_collapse" );
	
	//AUDIO: tank explode/catwalk fall sfx
	thread maps\black_ice_audio::sfx_blackice_catwalk_explode();

	thread maps\black_ice_fx::tanks_bridge_fall_explosions();
	thread maps\black_ice_fx::tanks_bridge_fall_fx();
	
	// Animate guys
	ai1 = GetEnt( "enemy_tanks_catwalk_scene_1", "targetname" ) spawn_ai( true );
	ai2 = GetEnt( "enemy_tanks_catwalk_scene_2", "targetname" ) spawn_ai( true );
	ai1.animname = "tanks_guy_1";
	ai2.animname = "tanks_guy_2";
	ai1.v.nogun = true;
	ai2.v.nogun = true;
	ai1.v.delete_on_end = true;
	ai2.v.delete_on_end = true;
	
	ai1 add_to_group( "tanks_bridge", false );
	ai2 add_to_group( "tanks_bridge", false );
														
	level._tanks.struct_bridge thread tank_guy_anim( ai1, "tanks_bridge_fall_scene", "tanks_bridge_fall_death" );
	level._tanks.struct_bridge thread tank_guy_anim( ai2, "tanks_bridge_fall_scene" );
	
	// Animate pipe/catwalk
	guys = [ level._tanks.pipe, level._tanks.bridge_destroyed, level._tanks.bridge ];
	level._tanks.struct_bridge thread anim_single( guys, "tanks_bridge_fall_scene" );		

	// Swap model
	level waittill( "notify_bridge_model_swap" );	
	level._tanks.bridge Hide();
	level._tanks.bridge_destroyed Show();	
}

tank_guy_anim( guy, start_anim, death_anim )
{
	guy endon( "death" );
	guy endon( "kill" );
			
	self thread vignette_single_solo( guy, start_anim, undefined, undefined, death_anim );
	guy thread util_enable_death_anim();
	
	guy waittill( "msg_vignette_start_anim_done" );
	guy delete();	
}

util_enable_death_anim()
{
	self endon( "death" );
	self endon( "kill" );
	
	level waittill( "notify_tanks_start_custom_death" );
	self.v.death_anim_anytime = true;
	level waittill( "notify_tanks_end_custom_death" );	
	self.v.death_anim_anytime = false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies_engineroom_entry()
{		
	flag_wait( "flag_tanks_engineroom_door" );

	thread enemies_engineroom_entry_door_open();
	thread maps\black_ice_fx::engineroom_turn_on_fx();
	thread maps\black_ice_audio::sfx_tanks_door_open();
	
	spawner_targetnames = [ "actor_vignette_engineroom_door_1", "actor_vignette_engineroom_door_2" ];
	animnames = [ "ai0", "ai1" ];
	coughs = [ "blackice_ru1_cough", "blackice_ru2_cough" ];
	guys = [];
	
	struct = getstruct( "vignette_engineroom_workers", "script_noteworthy" );
	
	for( i = 0; i < animnames.size; i++ )
	{
		ai = GetEnt( spawner_targetnames[ i ], "targetname" ) spawn_ai( true );
		ai.animname = animnames[ i ];
		
		// Let death anims happen at any time
		ai.v.death_anim_anytime = true;			
		
		guys = array_add( guys, ai );		
		
		struct thread vignette_single_solo( ai, "engineroom_workers_throughdoor", "engineroom_workers_idle", undefined, "engineroom_workers_death" );
		ai thread enemies_engineroom_entry_cough( coughs[ i ] );
	}
	
	// Add guys to global array	
	level._enemies[ "engine_room_door" ] = guys;
	
	// Timeout (enemies will eventually attack player if he is ahead of allies, but stays away from enemies)
//	level endon( "notify_stop_engineroom_entry_timeout" );
//	
//	wait( 5 );
//	
//	if( !flag( "flag_engineroom_player_start" ))
//	{
//		guys = remove_dead_from_array( guys );
//		if( guys.size > 0 )
//		{
//			level vignette_interrupt();
//			array_thread( guys, ::player_seek_enable );
//		}
//	}
}

enemies_engineroom_entry_door_open()
{	
	door = setup_door( "model_engine_room_door", undefined, "jnt_door" );			
	
	// open door
	door open_door( [120, -10], 0.6 );	
}

enemies_engineroom_entry_cough( alias )
{
	self endon( "death" );
	level endon( "notify_stop_engineroom_entry_timeout" );
	
	org = spawn( "script_origin", ( 0, 0, 0 ) );
	org hide();	
	self thread util_delete_on_vignette_kill( org );
	org.origin = self GetTagOrigin( "J_HEAD" );
	org.angles = self.angles;
	org linkto( self );
	
	while( IsDefined( org ))
	{
		org thread play_sound_on_tag( alias, undefined, true, "notify_sound_end" );	
		org waittill( "notify_sound_end" );
	}
}

util_delete_on_vignette_kill( ent )
{		
	ent endon( "death" );
	self waittill( "death" );
	if ( IsDefined( ent ) )
		ent Delete();
}

enemies_engineroom_extinguisher( index )
{
	level._enemies[ "engine_room_extinguisher" ] = [];
	
	spawners = GetEntArray( "spawner_engine_room_extinguish", "targetname" );
	
	nodes = [];
	nodes[ 0 ] = GetEnt( "origin_engine_room_extinguish_2", "targetname" );
	nodes[ 1 ] = GetEnt( "origin_engine_room_extinguish_3", "targetname" );
	nodes[ 2 ] = GetEnt( "origin_engine_room_extinguish_1", "targetname" );
	
	Assert( spawners.size > 0 );	
	Assert( nodes.size > 0 );
	Assert( spawners.size >= nodes.size );	
	
	flag_wait( "flag_engineroom_player_start" );
	
	actors = [];	
	
	for( i = 0; i < nodes.size; i++ )		
	{		
		// Spawn actor and extinguisher		
		extinguisher = spawn_anim_model( "extinguisher" );
		guy = spawners[ i ] spawn_ai( true );
		guy.animname = "extinguisher_guy";
		guy.v.prop = extinguisher;
		guy.v.interrupt_all_notifies = true;
		guy.v.interrupt_level = true;
		
		// Start loop
		nodes[ i ] thread vignette_single_solo( guy, undefined, "extinguisher_loop" + ( i + 1 ), "extinguisher_loop_break" + ( i + 1 ) );
		guy thread enemies_engineroom_extinguisher_fx( extinguisher );
		guy thread enemies_engineroom_extinguisher_interrupt();
		
		actors = array_add( actors, guy ); 		
	}
	
	level._enemies[ index ] = actors;		
}

enemies_engineroom_extinguisher_interrupt()
{		
	level waittill( "notify_vignette_end" );	
		
	if( IsAlive( self ))
	{
		wait( 1 );	
		self vignette_interrupt();
		self enable_cqbwalk();
		self go_to_goal_volume( level._engine_room.vol );
		self util_set_max_visible_dist();
	}
	
	wait( 2 );
	
	level notify( "notify_spawn_reinforcements" );
}

enemies_engineroom_extinguisher_fx( extinguisher )
{
	self endon( "death" );
	self endon( "msg_vignette_interrupt");
		
	while( 1 )
	{
		for( i = 0; i < 5; i++)
		{
			//AUDIO: play fire extinguisher sounds
			thread maps\black_ice_audio::sfx_blackice_fire_extinguisher_spray( extinguisher );

			playfxontag( getfx( "fire_extinguisher_spray"), extinguisher, "tag_fx" );		
			wait( 0.1 );
		}		
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_engine_room_extinguisher_guys()
{
	self.a.disableLongDeath = true;
}

spawnfunc_engine_room_reinforcements()
{
	self add_enemy( "engine_room_extinguisher" );
	
	self enable_cqbwalk();
	self util_set_max_visible_dist();
	self.a.disableLongDeath = true;
	
	self go_to_goal_volume( level._engine_room.vol );
}

spawnfunc_engine_room_reinforcements_2()
{
	self add_enemy( "engine_room_extinguisher" );
	
	self.a.disableLongDeath = true;
	self util_set_max_visible_dist();

	self thread ignore_until_goal();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_topdrive_fall( bool_mudpumps )
{		
	// Topdrive struct
	struct = getstruct( "vignette_topdrive", "script_noteworthy" );
	Assert( IsDefined( struct ));
	
	// Ally duck struct
	duck_struct = GetStruct( "struct_mudpumps_topdrive_duck", "targetname" );
	Assert( IsDefined( duck_struct ));
	
	// Spawn heli			
	array_thread_targetname( "trig_mudpumps_player_spawn_heli", ::waittill_trigger, "notify_spawn_pipedeck_heli" );
	thread waittill_trigger_ent_targetname( "trig_mudpumps_player_spawn_heli", level.player, ::flag_set, "flag_player_at_topdrive" );
	struct thread heli_spawn();
	
	// Setup anims      
	top_drive = GetEnt( "model_mudpmps_topdrive", "targetname" );
	top_drive assign_animtree( "top_drive" );		
	pipe_1 = spawn_anim_model( "drill_pipe1", level.player.origin );
	pipe_2 = spawn_anim_model( "drill_pipe2", level.player.origin );
	pipe_3 = spawn_anim_model( "drill_pipe3", level.player.origin );
	pipe_4 = spawn_anim_model( "drill_pipe4", level.player.origin );
	
	props = [ top_drive, pipe_1, pipe_2, pipe_3, pipe_4 ];
	
	struct anim_first_frame( props, "fall" );

	trigger_wait_targetname( "trig_top_drive_fall" );

	level._allies[ 0 ] thread event_topdrive_fall_ally1_duck( duck_struct );
    level._allies[ 1 ] thread event_topdrive_fall_ally2_duck( duck_struct );
    
    wait( 0.6 );
	
	//AUDIO: top drive fall sfx
	thread maps\black_ice_audio::sfx_blackice_engine_beam_fall( top_drive );
	
	struct thread anim_single( props, "fall" );
	
	quake( "scn_blackice_engine_dist_explo", 0.64 );
}

event_topdrive_fall_ally1_duck( struct )
{
	trigger_wait_targetname( "trig_mudpumps_ally1_duck" );
	
	// Duck under topdrive
	struct anim_reach_solo( self, "topdrive_duck" );
	
	if( flag( "flag_player_at_topdrive" ))
	struct anim_single_solo( self, "topdrive_duck" );
	else
		struct anim_single_solo( self, "topdrive_duck_full" );
		
	self enable_ai_color();	
}

event_topdrive_fall_ally2_duck( struct )
{		
	// Wait until triggered to duck under topdrive
	flag_wait( "flag_mudpumps_end" );
	struct anim_reach_solo( self, "topdrive_duck" );
	struct anim_single_solo( self, "topdrive_duck" );
	self enable_ai_color();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

heli_spawn()
{	
	mudpumps_intro = true;
			
	// Are we playing the mudpumps intro for the heli?
	if( start_point_is_after( "mudpumps" ))
		mudpumps_intro = false;
	
	if( mudpumps_intro )
		level waittill( "notify_spawn_pipedeck_heli" );
		
	heli = spawn_vehicle_from_targetname( "vehicle_exfil_helo" );
	Assert( IsDefined( heli ));	
	
	level._vehicles[ "exfil_heli" ] = heli;
	
	//Turn off heli engine
	heli Vehicle_TurnEngineOff();

	heli.animname = "pipedeck_heli";
	heli GodOn();	
	heli.fire_turret = false;
	heli.turret_move = false;
	
	// Heli turret aiming point
	heli.turret_aim = spawn_anim_model( "pipedeck_heli_target" );		
	heli.turret_aim Hide();
	heli.turret_aim.origin = heli GetTagOrigin( "tag_flash" ) + (AnglesToForward( heli GetTagAngles( "tag_flash" )) + ((-1) * AnglesToUp( heli GetTagAngles( "tag_flash" ))) * 256);
	heli.turret_aim Linkto( heli );		
	
	// Heli impact point
	heli.turret_impact = spawn_tag_origin();
	
	// Spotlight
	heli.turret_aim UnLink();
	heli thread heli_turret_and_spotlight_aim( 1.5 );
	heli thread maps\black_ice_pipe_deck::heli_spot_on_single( level.player, 0.5, true );
	
	if( mudpumps_intro )
		heli thread heli_spot_search_intro();
	else
		heli heli_spotlight_on();
	
	//putting distance based rumble and cam shake on heli
	heli thread maps\black_ice_pipe_deck::heli_player_quake();
	heli thread maps\black_ice_pipe_deck::heli_player_rumble();
	
	if( mudpumps_intro)
	{						
		// Audio: Play self in sfx
		thread maps\black_ice_audio::sfx_heli_flyin_mudpumps(heli);
		
		// Play reveal anims
		self anim_single_solo( heli, "heli_reveal" );
		
		// Play looping anims
		self thread heli_loop( heli );
		flag_wait( "flag_mudpumps_end" );
		self notify( "stop_loop" );
		heli StopAnimScripted();
		heli thread maps\_vehicle_code::animate_drive_idle();
	}
	
	return heli;
}

heli_spotlight_on()
{
	PlayFxOnTag( level._effect[ "heli_spotlight" ], self, "tag_flash" );
}

heli_spotlight_extrabright()
{
	PlayFxOnTag( level._effect[ "heli_spotlight_bright" ], self, "tag_flash" );
	
	level waittill( "flag_mudpumps_end" );
	
	stopFxOnTag( level._effect[ "heli_spotlight_bright" ], self, "tag_flash" );
	PlayFxOnTag( level._effect[ "heli_spotlight_bright_fade" ], self, "tag_flash" );
}

heli_spot_search_intro()
{		
	wait( 2.5 );
	
	self heli_spotlight_on();
	self thread heli_spotlight_extrabright();
	
	flag_wait( "flag_player_at_topdrive" );
	
	wait( 3 );
	
	self thread maps\black_ice_pipe_deck::heli_spot_on_single( level._allies[ 0 ], 0.5, true );	
}

heli_loop( heli )
{
	level endon( "flag_mudpumps_end" );
	self thread anim_loop_solo( heli, "heli_reveal_loop" );
}

heli_turret_and_spotlight_aim( noise_amp )
{
	self endon( "noise_off" );
	self endon( "death" );
	
	while ( 1 )
	{
		noise_angles = ( RandomFloatRange( -1 * noise_amp, noise_amp ), RandomFloatRange( -1 * noise_amp, noise_amp ), RandomFloatRange( -1 * noise_amp, noise_amp ) );
		
		self SetTurretTargetEnt( self.turret_aim, noise_angles );
		
		wait 0.1;
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

util_flicker_geyeser_light()
{
	lights = GetEntarray( "tanks_geyser_1", "targetname" );
	foreach( light in lights )
	{
		light SetLightIntensity( 2.5 );
		light thread flicker( 0.2, 0.8 );
	}
}


