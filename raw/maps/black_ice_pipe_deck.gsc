#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;
#include maps\black_ice_util_ai;
#include maps\black_ice_vignette;

SCRIPT_NAME = "black_ice_pipe_deck.gsc";

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{	
	flag_init( "flag_pipe_deck_end" );
	flag_init( "flag_vision_pipedeck_heat_1" );
	flag_init( "flag_vision_pipedeck_heat_2" );
	flag_init( "flag_vision_pipedeck_heat_3" );
	flag_init( "flag_vision_pipedeck_heat_4" );
	flag_init( "flag_vision_pipedeck_heat_5" );
	flag_init( "flag_vision_pipedeck_heat_fx");
		
	flag_init( "flag_pipe_deck_hat_1" );
	flag_init( "flag_pipe_deck_hat_2" );
	flag_init( "flag_pipe_deck_hat_3" );
	flag_init( "flag_start_pipe_steam");
	flag_init("flag_pd_godrays_start");
	flag_init( "flag_pipedeck_explosion" );
	flag_init( "flag_heli_support_success" );
	flag_init( "flag_pipedeck_player_killzone" );
	flag_init( "flag_derrick_pipe_run_jump" );
}

section_precache()
{	
	PreCacheItem( "rpg_straight" );
}

section_post_inits()
{
	level._pipe_deck = SpawnStruct();
	
	level._fire_damage_ent = spawn_tag_origin();
	
	// Struct for lifeboats scene
	level._pipe_deck.boats_struct = GetStruct( "vignette_lifeboats", "script_noteworthy" );
	
	if( IsDefined( level._pipe_deck.boats_struct ))	
	{
		level._pipe_deck.derrick_scene_struct = GetStruct( "struct_derrick_scene", "targetname" );		
		
		// Hide parts for optimization
		if( start_point_is_before( "mudpumps" ))
			array_call( GetEntArray( "opt_hide_derrick", "script_noteworthy" ), ::Hide );
		
		// Disable turret use by player
		turrets = GetEntArray( "turret_command", "script_noteworthy" );
		foreach( turret in turrets )
			turret MakeUnusable();
	}
	else
	{
		iprintln( SCRIPT_NAME + ": Warning - Pipe Deck boats struct missing (compiled out?)" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start()
{
	iprintln( "Pipe_Deck" );
	
	flag_set( "flag_fire_damage_on" );
	flag_set( "flag_fx_screen_bokehdots_rain" );
	
	player_start( "player_start_pipe_deck" );	
	
	position_tNames = 
	[
		"struct_ally_start_pipe_deck_01",
		"struct_ally_start_pipe_deck_02"
	];
	
	level._allies teleport_allies( position_tNames );
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_rain_heavy", 2 );
	//Flickering light from geyser	
	thread black_ice_geyser_pulse();
	thread black_ice_geyser2_pulse();
	thread pipedeck_godrays();
	thread maps\black_ice_fx::fx_command_window_light_on();
	//SetSavedDvar("r_sky_fog_min_angle","85.28");	
	//SetSavedDvar("r_sky_fog_max_angle","90.62");
	//SetSavedDvar("r_sky_fog_intensity","1");
	
	// Remove refinery geo
	thread maps\black_ice_refinery::util_refinery_stack_cleanup();
	
	// Spawn helicopter
	heli = maps\black_ice_tanks_to_mud_pumps::heli_spawn();
//	heli thread heli_spot_on_single( level.player, 1 );
}

main()
{				
	thread dialogue();
	thread enemies();
	thread allies();
	thread threatbias();
	thread hats();
	thread fx_command_snow();
	thread pipedeck_godrays();
	
	if(is_gen4())
	{
		thread maps\black_ice_anim::vig_pipdeck_wires();
		thread maps\black_ice_anim::spawn_dead_bodies_pipe_deck();
	}		
	
	//light_set_pipedeck_rim_lights();
	light_com_center_lights_on();
	maps\_art::sunflare_changes("pipedeck",0.1);
	// Open the command center exit door
	thread util_open_exfil_door();
	
	// Boats drop scene / heli	
	thread event_boat_drop();
	thread heli();
	
	// FX	
	maps\black_ice_fx::pipe_deck_fx();	
	maps\black_ice_fx::fx_command_window_light_on();	
	
	flag_wait( "flag_pipe_deck_end" );		
	flag_clear( "flag_fx_screen_bokehdots_rain" );

	// No longer ignored
	level.player.ignoreme = false;
	
	trigger_wait_targetname( "trig_command_allies_enter" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dialogue()
{
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );	

	// Dialogue - Baker - "Command Center is up ahead.  Move it!"
	level._allies[ 0 ] thread smart_dialogue( "blackice_bkr_upahead" );
} 

dialogue_boats_run()
{
	wait( RandomIntRange( 0, 1 ));
	
	dialogue = 
	[
		"blackice_ru1_grabanak",
		"blackice_ru2_fallback"		
	];

	self smart_dialogue( random( dialogue ));
}

dialogue_mgs_1()
{
	// Dialogue - Merrick - Get those MGs down!
	level._allies[ 0 ] smart_dialogue( "black_ice_mrk_getthosemgsdown" );
}

dialogue_mgs_2()
{
	// Dialogue - Hesh - Got another MG on the balcony!
	level._allies[ 1 ] smart_dialogue( "black_ice_hsh_gotanothermgon" );
}

dialogue_end()
{
	// Dialogue - Merrick - Two-One, balcony's secure!  You're cleared to engage!
	level._allies[ 0 ] smart_dialogue( "black_ice_mrk_twoonebalconyssecureyoure" );

	// Dialogue - Oldboy - Copy.  Keegan, light it up.
	smart_radio_dialogue( "black_ice_oby_copykeeganlightit" ); 	
	
	// Send in the heli		
	level notify( "notify_heli_support_final" );

//	level waittill( "notify_all_enemies_dead" );
	
	// Dialogue - Merrick - "Thanks Bravo.  Moving up. Hold your fire."
//	level._allies[ 0 ] smart_dialogue( "blackice_bkr_holdyourfire" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies()
{
	array_thread( level._allies, ::disable_pain );	
	array_thread( level._allies, ::set_ignoresuppression, true );	
	array_thread( level._allies, ::ignore_everything );
	
	// Disable the allies' final moveup trigger for command center
	disable_trigger_with_targetname( "trig_command_allies_enter" );
	
	level._allies thread ally_advance_watcher( "trig_derrick_allies_1", "derrick_main" );
	
	trigger_wait_targetname( "trig_pipe_deck_ally_boats" );
	
	level._allies[ 0 ] enable_cqbwalk();
	wait( 2 );
	//level._allies[ 0 ] thread ally_cqb_kill( "derrick_main", 512, 1 );	
	
	// Wait until position, then unignore
	level wait_for_notify_or_timeout( "stop_ally_cqb_kill", 7 );
	array_thread( level._allies, ::unignore_everything );	
	
	level waittill( "notify_all_enemies_dead" );
	
	// Once all enemies are dead, eanble trigger to allow allies into command center	
	enable_trigger_with_targetname( "trig_command_allies_enter" );		
	
	activate_trigger_with_targetname( "trig_derrick_ally_7" );
	array_thread( level._allies, ::disable_cqbwalk );	
	array_thread( level._allies, ::enable_pain );
	array_thread( level._allies, ::set_ignoresuppression, false );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies()
{	
	level._enemies[ "derrick_main" ] = [];
	level._enemies[ "derrick_balcony" ] = [];
	
								 //   key 					      func 									  
	array_spawn_function_targetname( "enemy_derrick_scene"	   , ::spawnfunc_enemies_derrick_heat_shield );
	array_spawn_function_targetname( "enemy_pipe_deck_wave_1_2", ::spawnfunc_enemies_pipe_run );
								 
								 //   key 							    func 							   
	array_spawn_function_noteworthy( "enemy_boat_scene_01"			 , ::spawnfunc_enemies_boats, true );
	array_spawn_function_noteworthy( "enemy_boat_scene_02"			 , ::spawnfunc_enemies_boats );
	array_spawn_function_noteworthy( "enemy_pipedeck_command_balcony", ::spawnfunc_enemies_balcony );
	array_spawn_function_noteworthy( "enemy_pipedeck_spawner"		 , ::spawnfunc_enemies_generic );
	array_spawn_function_noteworthy( "enemy_pipedeck_spawner_ignore" , ::spawnfunc_enemies_generic_ignore );
	array_spawn_function_noteworthy( "enemy_pipedeck_spawner_rush"	 , ::spawnfunc_enemies_generic_rush );
	
	// Start the enemy retreat system
	thread retreat_watcher( "trig_derrick_retreat", "derrick_main", "vol_retreat_derrick_1", 3 );
	
	// Keep guys on the MGs... LIKE A BOWSS!	
	level.active_turrets = 0;
	thread enemies_mg_watcher( "derrick_balcony", "turret_command_2", "node_turret_command_2" );
	thread enemies_mg_watcher( "derrick_balcony", "turret_command_3", "node_turret_command_3" );

	// Final encounter
	trigger_wait( "trig_derrick_balcony_spawn", "script_noteworthy" );
	level notify( "notify_pipedeck_final_battle_start" );
		
	thread dialogue_mgs_1();
	
	while( level.active_turrets > 1 )
		wait( 0.2 );		
	
	if( level.active_turrets == 1 )
		thread dialogue_mgs_2();	
	
	thread dialogue_end();	
	
	// Heli comes out
	level waittill( "notify_heli_support_final" );
	wait( 3 );
	
	//
	// End
	//
	
	final_vol = GetEnt( "vol_retreat_derrick_final", "script_noteworthy" );
	node_ground = GetNodeArray( "node_command_ground_retreat", "targetname" );
	node_balcony = GetNode( "node_command_balcony_retreat", "targetname" );
	
	ground_enemies = SortByDistance( remove_dead_from_array( level._enemies[ "derrick_main" ] ), final_vol.origin );	
	balcony_enemies = remove_dead_from_array( level._enemies[ "derrick_balcony" ] );	
	
	//
	// Ground enemies
	//
	for( i = 0; i < ground_enemies.size; i++ )
	{
		guy = ground_enemies[ i ];
		if( i < 3 )
		{
			// A few guys stay to fight, but will die
			guy SetGoalVolumeAuto( final_vol );
			guy DelayThread( 5, maps\_utility_code::kill_deathflag_proc, 2 );			
		}
		else if( Random( [ 0, 1, 2 ] ) )
	    {
			// Unlucky 1/3 of guys die immediately	
			guy thread maps\_utility_code::kill_deathflag_proc( 2 );
	    }
		else
		{
			// Run away!!
			guy SetGoalNode( random( node_ground ) );
			guy ignore_everything();
			guy thread delete_at_goal();
//			thread ai_delete_when_out_of_sight( [ guy ], 1024 );
		}
	}
	
	//
	// Balcony enemies
	//
	array_thread( balcony_enemies, ::DelayCall, RandomFloatRange( 0, 1 ), ::SetGoalNode, node_balcony );
	array_thread( balcony_enemies, ::ignore_everything );
	thread ai_delete_when_out_of_sight( balcony_enemies, 256 );
	
	wait( 5 );
		
	level notify( "notify_all_enemies_dead" );				
	
	flag_set( "flag_pipe_deck_end" );
}

delete_at_goal()
{
	self endon( "death" );
	self.goalradius = 16;
	self waittill( "goal" );
	self delete();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_enemies_boats( bool_scene_only )
{			
	self.animname = self.script_parameters;
	self.v.instant_death = false;
	self.a.disableLongDeath = true;
	self.ignoreall = true;
	self.maxfaceenemydist = 384;
	self.health = 1;
	
	if( IsDefined( bool_scene_only ) && bool_scene_only )
	{
		// Guy falls with lifeboat, dies on end
		self.ragdoll_immediate = true;
		self.v.death_on_end = true;
	}

	// Guy becomes regular enemy		
	self endon( "death" );
	
	struct = level._pipe_deck.boats_struct;	
	struct anim_first_frame_solo( self, "lifeboat_deploy" );
	
	self add_to_group( "derrick_main" );
	
	trigger_wait_targetname( "trig_pipe_deck_boats_scene_start" );	
	
	// Play anim on guy	
	struct vignette_single_solo( self, "lifeboat_deploy" );
	
	if( IsDefined( bool_scene_only ) && bool_scene_only )
		return;
	
	// Guy attacks player once at goal
	self thread dialogue_boats_run();		
	self thread ignore_until_goal();
}

spawnfunc_enemies_derrick_heat_shield()
{		
	self add_to_group( "derrick_main" );	
	self.animname = self.script_parameters;	
	self.a.disablelongdeath = true;	
	self.maxfaceenemydist = 256;	

	self endon( "death" );	 
	
	self ignore_everything();	
	
	// Play anim on guy	
	level._pipe_deck.derrick_scene_struct vignette_single_solo( self, "heat_shield_run" );		
}

spawnfunc_enemies_pipe_run()
{		
	self add_to_group( "derrick_other" );
	self.a.disablelongdeath = true;
	self.maxfaceenemydist = 384;
	
	self endon( "death" );
	
	self thread ignore_until_goal();
	
	flag_wait( "flag_derrick_pipe_run_jump" );
	
	blocker = GetEnt( "brush_pipe_run_blocker", "targetname" );
	if( IsDefined( blocker ))
	{
		blocker ConnectPaths();
		blocker delete();
	}
	
	self add_to_group( "derrick_main" );
}

spawnfunc_enemies_balcony()
{		
	self add_to_group( "derrick_balcony", false );
	self SetThreatBiasGroup( "balcony" );
	self.goalradius = 16;	
	self.on_turret = false;
	
	self thread ignore_until_goal();			
}

spawnfunc_enemies_generic()
{
	self add_to_group( "derrick_main" );
	self.maxfaceenemydist = 384;	
}

spawnfunc_enemies_generic_ignore()
{
	self add_to_group( "derrick_main" );	
	self.maxfaceenemydist = 384;
	
	self thread ignore_until_goal();
}

spawnfunc_enemies_generic_rush()
{
	self add_to_group( "derrick_main", false );		
	self.maxfaceenemydist = 384;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies_mg_watcher( enemy_index, tTurret, tTurret_node )
{		
	level.active_turrets++;
	
	// Grab turret
	turret = GetEnt( tTurret, "targetname" );
	turret.toparc = 0;
	
	// Setup shield
	shield = GetEnt( "brush_shield_" + tTurret, "targetname" );
	shield.angles = ( 0, 0, -25);
	shield.origin = turret GetTagOrigin( "TAG_BARREL" ) + (AnglesToForward( turret GetTagAngles( "TAG_FLASH" )) * -20);
	shield Linkto( turret, "TAG_BARREL" );	
	shield delete();
	
//	shield thread enemies_mg_watcher_shield_damage();
	
	trigger_wait( "trig_derrick_balcony_spawn", "script_noteworthy" );
	
	wait( 2 );
	
	turret_node = GetNode( tTurret_node, "targetname" );
	
	if( !IsDefined( level._enemies[ enemy_index ] ))
		level._enemies[ enemy_index ] = [];
	
	while( 1 )
	{
		if( !IsTurretActive( turret ))
		{
			// If there is noone on the balcony turret, get closest balcony guy and put him on turret
			enemies = remove_dead_from_array( level._enemies[ enemy_index ] );
			enemies = SortByDistance( enemies, turret.origin );
			
			if( enemies.size > 0 )
			{								
				guy = undefined;
				
				foreach( enemy in enemies )
				{
					// Find closest guy NOT on a turret
					if( !enemy.on_turret )
					{
						guy = enemy;
						guy.on_turret = true;
						break;
					}
				}
				
				if( IsDefined( guy ))
				{
					// Get the guy on the gun
					result = guy enemies_get_on_mg( enemy_index, turret, turret_node );
						
					if( IsDefined( result ))
					{
						// Wait for turret to be active
						while( IsTurretActive( turret ))
							wait( 0.05 );
						
						if( IsAlive( guy ))
							guy.on_turret = false;					
					}
				}
				else
				{
					// Turret is done
					break;
				}
			}
			else
			{
				// Turret is done	
				break;
			}
		}
		
		wait( 0.2 );
	}
	
	level.active_turrets--;
}

enemies_mg_watcher_shield_damage()
{
	self endon( "flag_pipe_deck_end" );
	self SetCanDamage( true );
	
	while( 1 )
	{
		self waittill( "damage" );
		self RadiusDamage( self.origin, 128, 100, 100 );
	}
}

enemies_get_on_mg( enemy_index, turret, turret_node )
{
	self endon( "death" );
	
	self.on_turret = true;
		
	// Send him to gun				
	self SetGoalNode( turret_node );
	self.goalradius = 16;
	self.fixednode = true;
	self waittill( "goal" );				
	turret SetTurretIgnoreGoals( true );
	self maps\_spawner::use_a_turret( turret );
	
	return true;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

threatbias()
{
	level.player SetThreatBiasGroup( "player" );
	
	CreateThreatBiasGroup( "balcony" );
	
	// Allies enter main pipe deck stretch
	trigger_wait( "trig_derrick_allies_support_1", "script_noteworthy" );
	
	// Make it harder for the player
	SetThreatBias( "axis", "player", 300 );
	
	trigger_wait( "trig_derrick_balcony_spawn", "script_noteworthy" );	

	ClearThreatBias( "axis", "player" );	
	
	// Start threatbias killzone	
	thread player_killzone();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

player_killzone()
{
	level endon( "flag_pipe_deck_end" );
	
	while( 1 )
	{			
		flag_wait( "flag_pipedeck_player_killzone" );
		
		level.player.ignoreme = false;
		
		// Make it harder for the player
		SetThreatBias( "axis", "player", 1000 );
		SetThreatBias( "axis", "allies", 0 );
		
		enemies = GetAIArray( "axis" );
		if( enemies.size == 0 )
			break;
		
		array_thread( enemies, ::set_baseaccuracy, 10 );
		
		flag_waitopen( "flag_pipedeck_player_killzone" );
		
		SetThreatBias( "axis", "player", 0 );
		SetThreatBias( "axis", "allies", 1000 );
		
		enemies = GetAIArray( "axis" );
		if( enemies.size == 0 )
			break;
		
		array_thread( enemies, ::set_baseaccuracy, 1 );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

heli()
{
	heli = level._vehicles[ "exfil_heli" ];
	
//	heli debug_heli_spot();
	
	// Heli scripts
	heli thread heli_support_pipe_deck();
	heli thread heli_support_final();
}

heli_support_pipe_deck()
{			
	flag_wait( "flag_mudpumps_end" );	
	
	/* If plr starts from pipedeck chkpt */
	thread maps\black_ice_audio::sfx_heli_flyin_pipedeck(self);
	
	// self switches positions
	heli_pipe_deck_start = GetStruct( "struct_heli_mudpumps_stairs", "targetname" );
	self SetVehGoalPos( heli_pipe_deck_start.origin, true );		
	heli_face = GetEnt( "origin_heli_aim_boats_1", "script_noteworthy" );
	self SetLookAtEnt( heli_face );
	
	// Wait for boat scene to start
	trigger_wait_targetname( "trig_pipe_deck_boats_scene_start" );
	
	// Play mvmt sfx
	thread maps\black_ice_audio::sfx_heli_move_pipedeck(self);
	
	// Send self to boats
	boats_pos = GetStruct( "struct_heli_boats", "targetname" );		
	self SetVehGoalPos( boats_pos.origin, true );		
	
	// self turret looks at guys near boats		
	self thread heli_spot_on_single( heli_face, 2 );	
	
	wait( 5 );
	
	spot_targets = GetStructArray( "struct_heli_aim_boats_2", "script_noteworthy" );
	spot_targets = SortByDistance( spot_targets, self.origin );
	
	for( i = 1; i < spot_targets.size; i++ )
	{
		self thread heli_spot_on_single( spot_targets[ i ], 1, true );			
		wait( 1 );
	}		
	
	// heli moves to middle	
	exit_path = GetStruct( "struct_heli_boats_exit", "targetname" );	
	self vehicle_detachfrompath();
	self.currentnode = exit_path;
	self vehicle_resumepath();	
	
	self heli_fire_turret_start();
		
	self heli_spot_stop();
	
	wait( 2 );
	
	self heli_fire_turret_stop();

	self thread heli_support_leave();
		
	level waittill( "notify_heli_leave" );
				   
	// heli leaves
	exit_path = GetStruct( "struct_heli_leave", "targetname" );	
	self vehicle_detachfrompath();
	self.currentnode = exit_path;
	self vehicle_resumepath();	
}

heli_support_leave()
{		
	
	self ClearLookAtEnt();
	
	ghost_rpg = GetStruct( "struct_balcony_ghost_rpg", "script_noteworthy" );	
	heli = level._vehicles[ "exfil_heli" ];
	heli_pos_1 = (heli.origin[ 0 ] - 150, heli.origin[ 1 ], heli.origin[ 2 ] );	
	heli_pos_2 = (heli.origin[ 0 ] - 256, heli.origin[ 1 ], heli.origin[ 2 ] - 128 );	
	MagicBullet( "rpg_straight", ghost_rpg.origin, heli_pos_1 );
	thread maps\black_ice_audio::sfx_heli_flyaway_boats(heli);
	wait( 1 );
	
	level notify( "notify_heli_leave" );
	
	MagicBullet( "rpg_straight", ghost_rpg.origin, heli_pos_2 );	
	wait( 2 );
}

heli_support_final()
{													
	level waittill( "notify_heli_support_final" );
	
	// lights out in command center when heli starts shooting
	thread maps\black_ice_fx::fx_command_window_light_off();
	thread maps\black_ice_audio::sfx_assault_heli_engine(self);	
	
	// Queue up the heli fly in sfx
	thread maps\black_ice_audio::sfx_assault_heli_flyin();
	
	// Turret firing for animation
	self thread heli_fire_anim();
	self.turret_aim Unlink();	
	
	// Rotor anims	
	anim_length = GetAnimLength( self GetAnim( "final_support" ));	
	self thread heli_start_rotor( anim_length );
	
	// Remove command glass blocker
	glass_blocker = GetEnt( "brushmodel_command_glass", "targetname" );
	glass_blocker delete();	
	
	node = GetStruct( "struct_heli_support", "script_noteworthy" );				
	
	// Start anim
	guys = [ self, self.turret_aim ];
	node thread anim_single( guys, "final_support" );
		
	wait( anim_length - 12 );	

	// Keep heli in one spot
	self SetVehGoalPos( self.origin, true );	
	
	// Stop gun	
	self notify( "notify_stop_anim_turret_fire" );
	self.turret_aim StopAnimScripted();
	
	// Turn off command lights
	light_com_center_lights_off();
	
	self thread heli_spot_on_baker();
	
	trigger_wait_targetname( "trig_command_allies_enter" );	
	
	wait( 2 );
	
	// Spot not locked to baker
	self heli_spot_stop();			
	
	// heli leaves
	exit_path = GetStruct( "struct_heli_leave", "targetname" );	
	self vehicle_detachfrompath();
	self.currentnode = exit_path;
	self vehicle_resumepath();	
	
	self waittill( "reached_dynamic_path_end" );
	
	self notify( "deleted" );
	self delete();
	thread maps\black_ice_audio::sfx_assault_heli_engine_fade_down();
}

heli_start_rotor( anim_length )
{
	wait( anim_length );
	self thread maps\_vehicle_code::animate_drive_idle();
}

heli_spot_on_baker()
{
	wait( 4 );
	self thread heli_spot_on_single( level._allies[ 0 ] );
}

heli_spot_on_single( guy, travel_time, no_lookat )
{	
	self notify( "notify_stop_heli_spot_single" );
	self endon( "notify_stop_heli_spot_single" );
	self endon( "deleted" );
	
	// Time it takes spot to get to location
	time = 0.5;
	if( IsDefined( travel_time ))
		time = travel_time;
	
	lookatent = true;
	
	if( IsDefined( no_lookat ))
		lookatent = false;
	
	if( IsAI( guy ))
	{
		while( IsAlive( guy ))
		{
			if( lookatent )
				self SetLookAtEnt( guy );
			self.turret_aim MoveTo( guy.origin + (0,0,32), time );
			wait( 0.05 );
		}
	}
	else if( guy == level.player )
	{
		while( 1 )
		{
			if( lookatent )
				self SetLookAtEnt( guy );
			self.turret_aim MoveTo( guy.origin + (0,0,32), time );
			wait( 0.05 );
		}
	}
	else
	{
		if( lookatent )
			self SetLookAtEnt( guy );
		self.turret_aim MoveTo( guy.origin + (0,0,32), time );	
		wait( 0.05 );
	}
}

heli_spot_stop()
{
	self notify( "notify_stop_heli_spot_single" );			
	self ClearLookAtEnt();	
	self.turret_aim LinkTo( self );
}

debug_heli_spot()
{
	target = spawn_tag_origin();
	target.origin = self.turret_aim.origin;
	target LinkTo( self.turret_aim );	
	target thread debug_pos_3d();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_boat_drop()
{			
	struct = level._pipe_deck.boats_struct;
	
	// Boats
	boats = GetEntArray( "model_lifeboat", "targetname" );
	foreach( boat in boats )
		boat assign_animtree( boat.script_parameters );
	
	crates = spawn_anim_model( "lifeboat_crates" );
	
	all_props = array_add( boats, crates );
	
	// Setup scene
	trigger_wait_targetname( "trig_pipe_deck_boats_scene_setup" );
	
	struct anim_first_frame( all_props, "lifeboat_deploy" );
	
	trigger_wait_targetname( "trig_pipe_deck_boats_scene_start" );

	// Play scene on boats		
	struct thread anim_single( all_props, "lifeboat_deploy" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

//play quake on player that gets sronger as heli flys over
heli_player_quake()
{
	self endon( "deleted" );
	
	max_quake = 0.092;
	
	min_player_dist = 400;
	max_player_dist = 1750;

	//rumble_dist_small = 900;
	
	while ( 1 )
	{
		dist = Distance( level.player.origin, self.origin );

		quake_factor = maps\black_ice_util::normalize_value( min_player_dist, max_player_dist, dist );
		quakemag = maps\black_ice_util::factor_value_min_max(  max_quake, 0, quake_factor );

		if ( quakemag > 0 )
			earthquake( quakemag, 0.4, level.player.origin, 1000 );
		
		
		wait( 0.17 );
	}
	
}

//play rumble on player as heli gets closer
heli_player_rumble()
{
	self endon( "deleted" );
	
	while ( 1 )
	{
	
		self PlayRumbleOnEntity( "hind_flyover" );
	
		wait( 0.15 );
	}
}

heli_fire_anim()
{
	self endon( "notify_stop_anim_turret_fire" );
	
	while( 1 )
	{
		level waittill( "notify_heli_anim_fire_on" );
		self heli_fire_turret_start();
		level waittill( "notify_heli_anim_fire_off" );
		self heli_fire_turret_stop();
	}
}

heli_fire_turret_start()
{		
	if( !self.fire_turret )
	{
		self.fire_turret = true;
		self thread heli_fire_turret();	
		self thread heli_turret_ground_fx();
		self thread maps\black_ice_audio::sfx_heli_turret_fire_start();
		self thread maps\black_ice_audio::sfx_heli_turret_shells();
		PlayFXOnTag( getfx( "hind_shell_eject" ), self, "tag_flash" );		
	}
}

heli_fire_turret_stop()
{	
	if ( self.fire_turret )
	{
		self.fire_turret = false;
		self thread maps\black_ice_audio::sfx_heli_turret_fire_stop();
		self thread maps\black_ice_audio::sfx_heli_turret_shells_stop();
		stopFXOnTag( getfx( "hind_shell_eject" ), self, "tag_flash" );	
	}
}

heli_fire_turret()
{	
	while( self.fire_turret )
	{
		self FireWeapon();
		wait( 0.1 );
	}
}

heli_turret_ground_fx()
{
	fx_on = false;
			
	while( self.fire_turret )
	{
		// Calculate impact position
		muzzle_pos = self GetTagOrigin( "tag_flash" );
		dist_pos = muzzle_pos + ( AnglesToForward( self GetTagAngles( "tag_flash" )) * 1000 );
		trace = BulletTrace( muzzle_pos, dist_pos, false );		
		
		if( trace[ "surfacetype" ] != "none" )
		{
			// Bullets are hitting a surface
			self.turret_impact.origin = trace[ "position" ];
			self.turret_impact.angles = VectorToAngles( trace[ "normal" ] );		   
				
			if( !fx_on )
			{
				// Start FX
				PlayFXOnTag( getfx( "hind_turret_impacts" ), self.turret_impact, "tag_origin" );
				thread maps\black_ice_audio::sfx_heli_turret_fire_squibs();
				fx_on = true;
			}
		}
		else
		{
			if( fx_on )
			{
				// End FX (not hitting a surface)
				StopFXOnTag( getfx( "hind_turret_impacts" ), self.turret_impact, "tag_origin" );
				thread maps\black_ice_audio::sfx_heli_turret_fire_squibs_stop();
				fx_on = false;
			}
		}
		
		wait( 0.05 );
	}
	
	// Kill FX
	if( fx_on )
	{
		StopFXOnTag( getfx( "hind_turret_impacts" ), self.turret_impact, "tag_origin" );
		thread maps\black_ice_audio::sfx_heli_turret_fire_squibs_stop();
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

util_open_exfil_door()
{
	door = level._exfil.door;
	
	trigger_wait_targetname( "trig_exfil_door_open" );	
	door open_door( [120, -20], 0.6 );
	maps\black_ice_fx::fx_command_interior_on();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

hats()
{
	flag_wait( "flag_pipe_deck_hat_1" );
	flag_wait( "flag_pipe_deck_hat_2" );
	flag_wait( "flag_pipe_deck_hat_3" );
	iprintlnbold( "NOPE!" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

fx_command_snow()
{
	effect = false;
	while( 1 )
	{
		if( flag( "flag_vision_command" ) )
		{
			if ( effect == false )
			{
				exploder( "command_snow" );
				effect = true;
			}
		}
		else
		{
			if ( effect == true )
			{
				stop_exploder( "command_snow" );
				effect = false;
			}
		}
			
		wait( level.TIMESTEP );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

light_com_center_lights_on()
{
	comlight1 = getEnt("comms_overhead_1","targetname");
	comlight2 = getEnt("comms_overhead_2","targetname");
//	comlight3 = getEnt("comms_overhead_3","targetname");
	comlight1 SetLightIntensity(10);
	comlight2 SetLightIntensity(10);
//	comlight3 SetLightIntensity(10);
	
	uplights = GetEntArray("comms_uplight","targetname");
	for(i=0;i<uplights.size;i++)
	{
		uplights[i] SetLightIntensity(10);
	}	
}
light_com_center_lights_off()
{
	comlight1 = getEnt("comms_overhead_1","targetname");
	comlight2 = getEnt("comms_overhead_2","targetname");
//	comlight3 = getEnt("comms_overhead_3","targetname");
	comlight1 SetLightIntensity(2);
	comlight2 SetLightIntensity(2);
//	comlight3 SetLightIntensity(2);
	
	uplights = GetEntArray("comms_uplight","targetname");
	for(i=0;i<uplights.size;i++)
	{
		uplights[i] SetLightIntensity(0.01);
	}	
}
pipedeck_godrays()
{
	gr_origin = getEnt("cc_gr_origin","targetname");
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_catwalk");
		god_rays_from_world_location ( gr_origin.origin, "flag_pd_godrays_start", "flag_teleport_rig", undefined, undefined);
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

light_command_lights_out()
{	
	level waittill( "notify_command_lights_out" );
	
	light_com_center_lights_off();
	
}

