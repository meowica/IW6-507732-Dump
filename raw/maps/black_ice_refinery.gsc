#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;
#include maps\black_ice_vignette;

SCRIPT_NAME = "black_ice_refinery.gsc";

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

start()
{
	iprintln( "Refinery" );				
	player_start( "player_start_refinery" );		
	
	position_tNames = 
	[    
		"struct_ally_start_refinery_01",
		"struct_ally_start_refinery_02"
	];
	
	level._allies teleport_allies( position_tNames );
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_oilrig", 2 );
	
	thread maps\black_ice_audio::audio_derrick_explode_logic( "start" );	
	thread maps\black_ice_flarestack::event_pressure_buildup_start( 0.0 );
	
	//AUDIO: audio changes for post flarestack
	thread maps\black_ice_audio::sfx_exited_flarestack();
	
	// Train (periph) movement
	thread maps\black_ice::trains_periph_logic( 0.0, true );
	
	//add snow fx
	exploder ( "flamestack_snow" );
	exploder ( "refinery_lights" );
	exploder ( "refinery_lights_b" );
}

main()
{			
	// Show hidden optimization geo
	array_call( GetEntArray( "opt_hide_refinery", "script_noteworthy" ), ::Show );		
	
	//turning on the derrick lights		
	thread maps\black_ice_fx::turn_on_oil_derrick_lightsFX();				
	exploder( "refinery_stack_smoke" );	
	exploder ( "refinery_lights" );
	
	// Kill CQB
	array_thread( level._allies, ::disable_cqbwalk );	
	
	// Setup alpha threatbias		
	SetIgnoreMeGroup( "ignore_allies", "allies" );
	
	thread enemies();
	thread allies();
	thread event_derrick_explode();
	thread dialogue();
	thread event_elevator_door_open();
	thread player_tanks_foreshocks();
	
	thread maps\black_ice_fx::refinery_turn_on_buildup_fx_01();
	
	vision_set_fog_changes("black_ice_refinery",2.0);	
	SetSavedDvar( "r_snowAmbientColor", ( 0.02, 0.02, 0.03 ) );
	
	// Refinery done
	flag_wait( "flag_refinery_end" );		
}

section_flag_inits()
{	
	flag_init( "flag_refinery_explosion" );
	flag_init( "flag_refinery_engagement_start" );
	flag_init( "flag_refinery_advance_1" );
	flag_init( "flag_refinery_advance_2" );
	flag_init( "flag_refinery_advance_3" );
	flag_init( "flag_refinery_gas_blowout_01" );
	flag_init( "flag_refinery_gas_blowout_02" );
	flag_init( "flag_refinery_gas_blowout_03" );
	flag_init( "flag_retfinery_retreat" );
	flag_init( "flag_refinery_done" );
	flag_init( "flag_derrick_exploded" );
	flag_init( "flag_tanks_catwalk_collapse" );
	flag_init( "flag_ally_cqb" );
	flag_init( "flag_refinery_foreshocks" );
	flag_init( "flag_refinery_player_killed_enemy" );
}

section_precache()
{		
	PrecacheString( &"BLACK_ICE_REFINERY_DEBRIS_DEATH" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_post_inits()
{	
	level._refinery = SpawnStruct();
	
	// Hide destroyed derrick
	level._refinery.destroyed_derrick_models = GetEntArray( "model_derrick_collapsed", "script_noteworthy" );	
	
	array_call( level._refinery.destroyed_derrick_models, ::Hide );
	
	// Setup the derrick to first frame
	level._refinery.derrick_struct = GetStruct( "struct_derrick", "targetname" );
	Assert( IsDefined( level._refinery.derrick_struct ));
	
	level._refinery.enemy_struct = GetStruct( "struct_refinery_explosion_scene", "targetname" );
		
	if( IsDefined( level._refinery.enemy_struct ))
	{
		event_derrick_explode_debris_setup();	

		// Hide parts for optimization
		if( start_point_is_before( "refinery" ))
			array_call( GetEntArray( "opt_hide_refinery", "script_noteworthy" ), ::Hide );
	}
	else
	{
		iprintln( SCRIPT_NAME + ": Warning - Enemy struct missing (compiled out?)" );
	}
	
	// CQB for corners
	array_thread_targetname( "trig_ally_cqb_start", ::waittill_trigger_ent, level._allies, ::enable_cqbwalk );
	array_thread_targetname( "trig_ally_cqb_end", ::waittill_trigger_ent, level._allies, ::disable_cqbwalk );
	
	// Vignette interrupt notifies
	array_thread_targetname( "trig_vignette_interrupt", ::waittill_trigger, "notify_vignette_interrupt" );
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

dialogue()
{			
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
	level waittill( "notify_baker_hold_dialogue" );
	
	// Dialogue - Baker - Wait for it…
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_waitforit" );
		
	// Derrick finishes exploding
	level waittill( "notify_derrick_explode_done" ); 	
	
	// Dialogue - Baker - Get down!!
	level._allies[ 0 ] thread smart_dialogue( "black_ice_bkr_getdown" );
	
	level waittill_either( "notify_notetrack_debris_end", "flag_refinery_engagement_start" );

	// Dialogue - Baker - Weapons free!!  Weapons free!!
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_weaponsfreeweaponsfree" );
	
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	
	level waittill( "notify_baker_falling_back_dialogue" );
	
	wait( 2 );
	
	// Dialogue - Baker - They're falling back.  Push forward!
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_backpushforward" );		
}

dialogue_enemy()
{						 
	struct = GetStruct( "struct_refinery_enemy_dialogue", "targetname" );
	Assert( IsDefined( struct ));
	
	wait( 1 );	
//	thread smart_radio_dialogue( "blackice_ru1_grabanak" );
	wait( 1 );
//	thread smart_radio_dialogue( "blackice_ru2_fallback" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

allies()
{
	array_thread( level._allies, ::disable_pain );	
	array_thread( level._allies, ::ignore_everything );	
		
	level._allies[ 0 ] thread allies_baker_hold();	
				
	// Derrick finishes exploding
	level waittill_either( "notify_notetrack_debris_end", "flag_refinery_engagement_start" );

	wait( 0.05 );	
		
	activate_trigger_with_targetname( "trig_refinery_color_start" );
	
	level._allies[ 1 ] unignore_everything();
		
	trigger_wait_targetname( "trig_refinery_ally_1" );		
	
	trigger_ally_advance( "trig_refinery_ally_2", 20 );	
	trigger_ally_advance( "trig_refinery_ally_3", 10 );
	trigger_ally_advance( "trig_refinery_ally_4", 10 );
	trigger_ally_advance( "trig_refinery_ally_5", 10 );
	trigger_ally_advance( "trig_refinery_ally_6", 10, "refinery_main", 3 );
	trigger_ally_advance( "trig_refinery_ally_7", 5, "refinery_main", 1 );
	array_thread( level._allies, ::enable_pain );
}

allies_baker_hold()
{
	struct = GetStruct( "struct_refinery_baker_hold", "targetname" );
	Assert( IsDefined( struct ));
			
	// Get baker to position	
	trigger_wait_targetname( "trig_refinery_color_stairs" );
	
	// Baker says "waitforit" when player triggers scene
	thread dialogue_baker_waitforit();	
	
	// Keep player at bay a bit
	level.player thread util_player_rubber_banding_solo( self );
	self.moveplaybackrate = 1.1;
	
	// Baker moves up and waits
	self thread allies_baker_hold_approach_and_idle( struct );

	//level waittill( "notify_refinery_baker_hold" );
	level waittill( "notify_refinery_explosion_start" );	
	level notify( "notify_stop_rubber_banding" );
	
	// Default movement speeds
	SetSavedDvar( "g_speed", 190 );
	self.moveplaybackrate = 1;
	
	struct notify( "stop_loop" );
		
	// Breakout	
	struct anim_single_solo( self, "refinery_hold_end" );
	
	self unignore_everything();	
	self disable_pain();
	self enable_ai_color();
}

allies_baker_hold_approach_and_idle( struct )
{
	//level endon( "notify_refinery_baker_hold" );
	level endon( "notify_refinery_explosion_start" );	
	
	struct anim_reach_solo( self, "refinery_hold_init" );
	self.moveplaybackrate = 1;	
	struct anim_single_solo( self, "refinery_hold_init" );
	level notify( "notify_stop_rubber_banding" );	
	struct anim_loop_solo( self, "refinery_hold_idle" );
}

dialogue_baker_waitforit()
{		
	flag_wait( "flag_refinery_explosion" );		
	
	//AUDIO: Russian panic walla and russian PA bursts
	thread maps\black_ice_audio::sfx_russian_panic_dx();
	
	thread maps\black_ice_audio::sfx_pa_bursts();
	
	level notify( "notify_baker_hold_dialogue" ); 
	
}
	
//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies()
{	
	// Main enemy refinery container
	level._enemies[ "refinery_main" ] = [];
	
	enemies_setup_explosion_scene_guys();
	
								 //   key 						     func 					     param1 		 
	array_spawn_function_targetname( "enemies_refinery_right"	  , ::spawnfunc_enemy_right	  , "refinery_main" );
	array_spawn_function_targetname( "enemies_refinery_left"	  , ::spawnfunc_enemy_left	  , "refinery_main" );
	array_spawn_function_targetname( "enemies_refinery_left_fence", ::spawnfunc_enemy_left	  , "refinery_main" );
	array_spawn_function_targetname( "enemies_refinery_back"	  , ::spawnfunc_enemy_generic , "refinery_main" );
	array_spawn_function_targetname( "enemies_refinery_flood_1"	  , ::spawnfunc_enemy_generic , "refinery_main" );
	array_spawn_function_targetname( "enemies_refinery_rpg"		  , ::spawnfunc_enemy_rpg	  , "refinery_rpg" );
	array_spawn_function_targetname( "enemies_refinery_elevator"  , ::spawnfunc_enemy_elevator, "refinery_main" );
	
	// Interrupt
	thread enemies_player_attack_scene_interrupt();
	
	// Retreat logic
	thread enemies_retreat();	
	
	// Right door opens, enemies come out
	thread enemies_right_door();
	
	// Left side enemies
	thread enemies_left_side();
	
	// Thread that starts engagement
	thread encounter_start();	
}

enemies_setup_explosion_scene_guys()
{
	// Scripted enemies (not animating)
	array_spawn_function_targetname( "enemies_refinery_02", ::spawnfunc_enemy_scene_scripted, "refinery_initial" );
	
	guys = GetEntArray( "enemies_refinery_01", "targetname" );		
	
	// CONTROLLER GUY!!  This guy is hidden and used only to trigger the events in case the player attacks the guys
	controller = guys[ 0 ];	
	guys = array_remove_index( guys, 0 );	
	controller add_spawn_function( ::spawnfunc_enemy_scene_anim_controller );
	
	animnames = 
	[
		"refinery_guy1",
		"refinery_guy2",
		"refinery_guy3",
		"refinery_guy5",
		"refinery_guy6"		
	];
	
	Assert( guys.size == animnames.size );
	
	for( i = 0; i < guys.size; i++ )
		guys[ i ] add_spawn_function( ::spawnfunc_enemy_scene_anim, "refinery_initial", animnames[ i ] );
}

enemies_player_attack_scene_interrupt()
{	
	level endon( "flag_refinery_engagement_start" );
	
	while( 1 )
	{
		level waittill( "notify_vignette_end", attacker );
		if( IsDefined( attacker ) && ( attacker == level.player ))
			level notify( "flag_refinery_player_killed_enemy" );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_enemy_scene_anim( index, animname )
{		
	self add_enemy( index );
	self SetThreatBiasGroup( "ignore_allies" );		
	self.animname = animname;	
	self.a.disableLongDeath = true;
	self.doing_reaction_anim = false;	
			
	self thread spawnfunc_enemy_scene_solo();
}

spawnfunc_enemy_scene_scripted( index )
{
	self add_enemy( index );		
	self SetThreatBiasGroup( "ignore_allies" );	
	self.a.disableLongDeath = true;
	
	// Needs this to get by checks
	self.animname = "generic";
	
	thread spawnfunc_enemy_scene_scripted_damage_interrupt();
	thread spawnfunc_enemy_scene_scripted_natural_interrupt();	
}

spawnfunc_enemy_generic( index )
{
	self add_enemy( index );		
	self SetThreatBiasGroup( "axis" );	
	self.a.disableLongDeath = true;

	self go_to_goal_volume( level._refinery.current_volumes );
}

spawnfunc_enemy_right( index )
{
	self add_enemy( index );		
	self SetThreatBiasGroup( "axis" );	
	self.a.disableLongDeath = true;	
}

spawnfunc_enemy_left( index )
{
	self add_enemy( index );		
	self SetThreatBiasGroup( "axis" );	
	self.a.disableLongDeath = true;
	
	self SetGoalVolumeAuto( get_vol( "vol_retreat_refinery_left" ));
}
spawnfunc_enemy_rpg( index )
{
	self endon( "death" );
	
	self add_enemy( index );
	self SetThreatBiasGroup( "axis" );	
	
	self.a.disableLongDeath = true;
	self.goalradius = 8;
	self.ignoreall = true;
	
	self waittill( "goal" );
	self.ignoreall = false;
	
	trigger_wait_targetname( "trig_refinery_ally_7" );
	kill_deathflag( "deathflag_refinery_rpg" );
}

spawnfunc_enemy_elevator( index )
{
	self add_enemy( index );		
	self SetThreatBiasGroup( "axis" );	
	self.a.disableLongDeath = true;
	self SetThreatBiasGroup( "ignore_allies" );
	
	self thread spawnfunc_enemy_elevator_wait();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

spawnfunc_enemy_scene_scripted_damage_interrupt()
{
	level endon( "flag_refinery_engagement_start" );
	self endon( "death" );
		
	while( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, dflags, weapon );
		level notify( "notify_vignette_end", attacker );
	}
}

spawnfunc_enemy_scene_scripted_natural_interrupt()
{
	self endon( "death" );
	
	self ignore_everything();
	flag_wait( "flag_refinery_engagement_start" );
	self unignore_everything();
	self go_to_goal_volume( level._refinery.current_volumes );
}

spawnfunc_enemy_scene_anim_controller()
{		
	self Hide();		
	self SetThreatBiasGroup( "ignore_allies" );		
	
	// Set up actor as invincible (he is not killed, only deleted
	self.animname = "refinery_guy1";
	self.v.invincible = true;	
	self.a.disableLongDeath = true;
	self.doing_reaction_anim = false;	
			
	flag_wait( "flag_refinery_explosion" );
	level._refinery.enemy_struct anim_single_solo( self, "derrick_explode_scene" );
	level notify( "notify_refinery_scene_complete" );
	self delete();	
}

spawnfunc_enemy_scene_solo()
{		
	self endon( "death" );	
	
	// Setup guy in anim
	level._refinery.enemy_struct thread anim_first_frame_solo( self, "derrick_explode_scene" );
	
	// Wait for start
	flag_wait( "flag_refinery_explosion" );
	
	idle_anim = undefined;
	
	level._refinery.enemy_struct thread vignette_single_solo( self, "derrick_explode_scene" );
		
	if( IsSubStr( self.animname, "4" ))
	{
		// Specific guys should just die at end
		thread spawnfunc_enemy_scene_solo_auto_kill();
	}
	else
	{
		// Keep forman squashed
		if( IsSubStr( self.animname, "6" ))
			self thread spawnfunc_enemy_scene_solo_foreman_smash_end();		
		
		// Wait for engagement start or someone to die
		flag_wait( "flag_refinery_engagement_start" );				
		
		if( self.v.active )
		{								   
			if( IsSubStr( self.animname, "5" ) || IsSubStr( self.animname, "6" )) 
			{
				// Make sure foreman and crate guy continue anims unless player shot someone or player moved up before scene is done
				if( flag( "flag_refinery_player_killed_enemy" ) || flag( "flag_refinery_player_started_encounter" ))
				{
					self vignette_end( true );
				}
		   	}				
			else
			{
				self vignette_end( true );
			}
		}
		
		// Everyone except for top guys goes to volumes
		if( !IsSubStr( self.animname, "1" ) && !IsSubStr( self.animname, "2" ))
			self go_to_goal_volume( level._refinery.current_volumes );
	}
}

spawnfunc_enemy_scene_solo_foreman_smash_end()
{
	self endon( "death" );
	level endon( "flag_refinery_player_killed_enemy" );
	level endon( "flag_refinery_player_started_encounter" );
	
	self waittill( "msg_vignette_start_anim_done" );	
	self.v.invincible = true;		
	self ignore_everything();
	self.v.anim_node anim_first_frame_solo( self, "death_pose" );
}

spawnfunc_enemy_scene_solo_auto_kill()
{
	self endon( "death" );
	
	level waittill( "notify_refinery_scene_complete" );
	self vignette_kill();
}

spawnfunc_enemy_elevator_wait()
{
	self endon( "death" );
	self thread spawnfunc_enemy_elevator_damage_interrupt();	
	
	level waittill( "notify_elevator_open" );
	self SetThreatBiasGroup( "axis" );
	self go_to_goal_volume( level._refinery.current_volumes );
}

spawnfunc_enemy_elevator_damage_interrupt()
{		
	self endon( "death" );
	self endon( "notify_elevator_open" );
	
	self waittill( "damage" );
	self SetThreatBiasGroup( "axis" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

encounter_start()
{	
	level.player.ignoreme = true;
	
	// Scene is done OR player shoots a guy, causes guys to attack and go to cover positions
	level waittill_any( "notify_refinery_scene_complete", "flag_refinery_player_killed_enemy", "flag_refinery_player_started_encounter", "flag_refinery_engagement_start" );	
	
	flag_set( "flag_refinery_engagement_start" );
	
	// Start flooders 
	activate_trigger_with_noteworthy( "trig_refinery_flood_1" );
	
	// Initial guys attack		
	SetThreatBias( "allies", "axis", 1000 );
	SetThreatBias( "axis", "allies", 1000 );			
		
	// Move scene guys to main enemies group
	level._enemies[ "refinery_initial" ] = remove_dead_from_array( level._enemies[ "refinery_initial" ] );	
	array_thread( level._enemies[ "refinery_initial" ], ::add_enemy, "refinery_main" );
	array_call( level._enemies[ "refinery_initial" ], ::SetThreatBiasGroup, "axis" );		
	
	level notify( "notify_enemy_retreat_logic_start" );
	
	// Give the player a few moments to find cover
	if( !flag( "flag_refinery_player_started_encounter" ))
		wait( 3 );
	
	level.player.ignoreme = false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies_left_side()
{	
	level waittill_either( "flag_refinery_engagement_start", "flag_refinery_player_started_encounter" );
		
	array_spawn_targetname( "enemies_refinery_left" );
}

enemies_right_door()
{	
	level waittill_either( "flag_refinery_engagement_start", "flag_refinery_player_started_encounter" );
	
	if( !flag( "flag_refinery_player_started_encounter" ))
		wait( 3 );
	
	door = setup_door( "model_refinery_right_door" );			
	
	// open door
	door thread open_door( 90, 0.6, 0.05 );	
	
	array_spawn_targetname( "enemies_refinery_right" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

enemies_retreat()
{					
	// Setup initial vols
	level._refinery.current_volumes = "vol_retreat_refinery_initial";
	level.retreat_final = "vol_retreat_refinery_final";
	
	level.retreat_volumes_list =
	[
		"vol_retreat_refinery_2",
		"vol_retreat_refinery_3",
		"vol_retreat_refinery_4"
	];
	
	level waittill( "notify_enemy_retreat_logic_start" );
	
	// Advance 1
	flag_wait( "flag_refinery_advance_1" );	
	level._refinery.current_volumes = retreat_vol_pop();
	thread retreat( "refinery_main", level._refinery.current_volumes, 2 );
		
	level notify( "notify_baker_falling_back_dialogue" );
	
	// Advance 2
	flag_wait( "flag_refinery_advance_2");
	level._refinery.current_volumes = retreat_vol_pop();
	thread retreat( "refinery_main", level._refinery.current_volumes, 2 );
	
	// Advance 3
	flag_wait( "flag_refinery_advance_3" );
	level._refinery.current_volumes = retreat_vol_pop();
	thread retreat( "refinery_main", level._refinery.current_volumes, 2 );
	
	flag_wait( "flag_refinery_end" );
	
	// clear volumes
	level.retreat_volumes_list = undefined;	
	level.retreat_final = undefined;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_derrick_explode()
{
	lookat_node = GetEnt( "origin_derrick_lookat", "targetname" );
	Assert( IsDefined( lookat_node ));
	
	// Travelling block & destruction
	thread event_derrick_explode_debris_bomb();

	// Derrick events setup
	thread event_derrick_explode_setup();

	thread vision_set_refinery_visionsets();

	flag_wait( "flag_refinery_explosion" );
	
	// Wait for notetrack (explosion starts)
	level waittill( "notify_refinery_explosion_start" );
	
	// If pipe deck geo is compiled in, run periph anims on topside objects
	if( IsDefined( level._pipe_deck.boats_struct ))
		thread event_derrick_explode_stack_setup();
	
	//turn off pressure_buildup_fx
	thread maps\black_ice_fx::turn_off_refinery_buildup_fx_01();
	//thread maps\black_ice_fx::fx_screen_bokehdots_rain();
	flag_set( "flag_fx_screen_bokehdots_rain" );
		
	wait( 2 );
	
	autosave_by_name( "refinery_2" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_derrick_explode_stack_setup()
{
	NUM_STACKS = 4;
	
	amplitude = [ 1.5, 1.5, 2.5, 2.5 ];
	period = [ 4, 4, 3, 3 ];
	
	for ( i = 0; i < NUM_STACKS; i++ )
	{
		refinery_stack = GetEntArray( "refinery_stack_anim_" + i, "targetname" );
		refinery_node_from_map = GetEnt( "refinery_stack_anim_node_" + i, "script_noteworthy" );
		
		// tagBR< Note >: Have to spawn one (not use the Radiant map one) due to needing a model for linking...grrrr
		refinery_node = refinery_node_from_map spawn_tag_origin();
		
		// Link the flarestack to the control node
		foreach ( ent in refinery_stack )
		{
			ent LinkTo( refinery_node );
		}
		
		thread event_derrick_explode_stack_motion( refinery_node, amplitude[i], period[i] );
	}
}

util_refinery_stack_cleanup()
{
	// Remove animated stack geo
	NUM_STACKS = 4;
	for ( i = 0; i < NUM_STACKS; i++ )
	{
		refinery_stack = GetEntArray( "refinery_stack_anim_" + i, "targetname" );
		array_call( refinery_stack, ::delete );		
	}
	
	// Remove other geo
	refinery_stack = GetEntArray( "geo_refinery_stack_other", "targetname" );
	array_call( refinery_stack, ::delete );
	
	// Stop FX
	stop_exploder( "refinery_stack_smoke" );
}

event_derrick_explode_stack_motion( refinery_node, amplitude, period )
{
	// Calculate the force vector
	derrick_origin = ( 1408, 3968, 0 );

	force_dir = refinery_node.origin - derrick_origin;
	force_dir = ( force_dir[0], force_dir[1], 0 );
	
	dist = Length( force_dir );
	force_dir = VectorNormalize( force_dir );
	
	// Add in a delay based off dist
	dist_max = 3000.0;
	time_factor = 1.0;
	
	wait ( ( dist / dist_max ) * time_factor );
	
	refinery_node Vibrate( force_dir, amplitude, period, period );
	
	// Decrease the motion over time, until the amplitude is minute
	for ( i = 2; ( amplitude / i ) > 0.5; i++ )
	{
		wait period;
		
		refinery_node Vibrate( force_dir, ( amplitude / i ), period, period );
	}
	
	wait period;
	refinery_node Vibrate( force_dir, 0.01, period, period );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_derrick_explode_debris_bomb()
{
	// Refinery container
	container = GetEntArray( "model_refinery_container", "targetname" );
	broken_container_parts = GetEntArray( "model_refinery_container_destroyed", "targetname" );
	Assert( container.size > 0 );
//	Assert( broken_container_parts.size > 0 );
	foreach( part in broken_container_parts )
		part Hide();
	
	debris_explosion = GetEnt( "origin_refinery_debris_explosion", "targetname" );
	Assert( IsDefined( debris_explosion ));	
	
	level waittill( "notify_traveling_block_impact" ); 
	
	// Do container swap
	foreach( thing in container )
		thing Hide();
	
	foreach( part in broken_container_parts )
		part Show();
	
	// Prevent enemies from falling through the ground (because they are falling so fast)
	SetSavedDVar( "phys_gravity_ragdoll", -400 );
	
	// Enemies react
	foreach( guy in level._enemies[ "refinery_initial" ] )
	{
		if( IsAlive( guy ))
		{			
			node = spawn_tag_origin();
			node.origin = guy.origin;
			node.angles = VectorToAngles( guy.origin - debris_explosion.origin );
			
			// If close enough, guy gets thrown and dies
			if( Distance( guy.origin, debris_explosion.origin ) < 256 )
			{
				guy vignette_end();
				guy thread event_derrick_explode_debris_bomb_throw_enemy( node );
			}
		}
	}	
	
	// Explosion
	thread event_derrick_explode_debris_bomb_tank_player_quake();
	PhysicsExplosionSphere( debris_explosion.origin, 1024, 1023, 3 );
	//Tank Light
	tanklight = GetEnt("refinery_tank_fire_1","targetname");
	tanklight SetLightIntensity(2.0);
	//Flickering light from geyser	
	thread black_ice_geyser_pulse();
	thread black_ice_geyser2_pulse();
	// FX
	PlayFX( GetFX( "refinery_debris_explosion" ), debris_explosion.origin );
	stop_exploder( "refinery_lights_b" );
	
	wait(0.2);
	
	exploder( "refinery_debris_fire_oiltank" );	

	level waittill( "notify_derrick_vignette_done" );
	
	// Put gravity back
	SetSavedDVar( "phys_gravity_ragdoll", -800 );		
}

event_derrick_explode_debris_bomb_tank_player_quake()
{
	wait 0.15;
	earthquake( 0.21, 1.5, level.player.origin, 128 );	
}

event_derrick_explode_debris_bomb_throw_enemy( node )
{
	self endon( "death" );
	
	Assert( IsDefined( node ));
	
	node anim_single_solo( self, "derrick_explode_death" );
	self kill();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_elevator_door_open()
{	
	// Grab door / gate parts
	top_door = setup_door( "model_refinery_lift_door_top" );
	bottom_door = setup_door( "model_refinery_lift_door_bottom" );
	gate = setup_door( "model_refinery_lift_gate" );
			
	// Open the doors
	trigger_wait_targetname( "trig_refinery_elevator_enemies" );
	                         
	array_spawn_targetname( "enemies_refinery_elevator" );
	
	top_door thread open_gate( top_door.origin + (0,0,48), 6 );
	bottom_door thread open_gate( bottom_door.origin - (0,0,63), 6 );
	
	wait( 2 );
	
	// Gate opens
	gate open_gate( gate.origin + (0,0,88), 6, 4 );	
	
	level notify( "notify_elevator_open" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

util_derrick_destroy_quick()
{
	// Remove derrick
	if( IsDefined( level.derrick_model ))
		level.derrick_model delete();
	
	// Show destroyed
	util_show_destroyed_derrick();	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

util_show_destroyed_derrick()
{	
	level notify( "notify_remove_derrick_model" );
	
	// Remove animted derrick
	if( IsDefined( level._refinery.derrick_model ))
		level._refinery.derrick_model delete();
	
	// Show destroyed derrick
	destroyed_derrick_models = level._refinery.destroyed_derrick_models;
	stop_exploder( "oil_geyser_01" );
	exploder( "oil_geyser_02" );
	foreach( thing in destroyed_derrick_models )
		thing Show();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

event_derrick_explode_setup()
{						
	derrick_struct = level._refinery.derrick_struct;	
	derricK_model = level._refinery.derrick_model;
	barrel_model_1 = level._refinery.barrel_model_1;	
	barrel_model_2 = level._refinery.barrel_model_2;
	barrel_model_3 = level._refinery.barrel_model_3;
	barrel_model_4 = level._refinery.barrel_model_4;
	barrel_model_5 = level._refinery.barrel_model_5;
		
	// Derrick destruction events
//	thread vignette_derrick_explode_small( derrick_struct );
	thread event_derrick_explode_large( derrick_struct );
	thread event_derrick_explode_impact_rig( derrick_struct );
	thread event_derrick_explode_debris_oiltank( derrick_struct );
	thread event_derrick_explode_debris_main( derrick_struct );		
	thread event_derrick_explode_catwalk_break( derrick_struct );
	
	thread event_derrick_explode_debris_show_and_damage();
	thread fx_refinery_ceiling_fire();
	
//	level waittill( "notify_derrick_explode_small" );
//	derrick_struct thread anim_single_solo( derrick_model, "small_explosion" );
	
	// Start anim (called from black_ice_refinery.gsc )
	level waittill( "notify_refinery_explosion_start" );
	derrick_struct thread anim_single_solo( barrel_model_1, "barrel_crush_1" );
	derrick_struct thread anim_single_solo( barrel_model_2, "barrel_crush_2" );
	derrick_struct thread anim_single_solo( barrel_model_3, "barrel_crush_3" );
	derrick_struct thread anim_single_solo( barrel_model_4, "barrel_crush_4" );
	derrick_struct thread anim_single_solo( barrel_model_5, "barrel_crush_5" );
	derrick_struct anim_single_solo( derrick_model, "collapse" );
	
	level notify( "notify_derrick_vignette_done" );
	
	// Remove derrick and refinery oil fx
	level waittill( "notify_remove_derrick_model" );	
	barrel_model_1 Delete();
	barrel_model_2 Delete();
	barrel_model_3 Delete();
	barrel_model_4 Delete();
	barrel_model_5 delete();
}

event_derrick_explode_large( derrick_struct )
{
	// Second larger explosion
	//explode_nodes = GetEntArray( "origin_derrick_explode", "script_noteworthy" );
	//Assert( explode_nodes.size > 0 );
	
	// Get explosion nodes in order going from bottom to top
	//explode_nodes = SortByDistance( explode_nodes, derrick_struct.origin );		
	
	// Second Big explosion
	level waittill( "notify_derrick_large_explosion" );
	//cleanup snow from flamestack
	stop_exploder( "flamestack_snow" );
	//derrick_splotions
	exploder( "derrick_explode_large" );
    exploder( "oil_geyser_01" );
    exploder( "oil_spots_01" );
    thread maps\black_ice_fx::turn_off_oil_derrick_lightsFX();
    thread maps\black_ice_fx::turn_on_bokeh_fieryflash_player_fx();
    
	
	thread maps\black_ice_audio::audio_derrick_explode_logic( "stop" );
	
	wait( 0.5 );
	
	//send shockwave
	exploder( "derrick_shockwave" );
	
	//snow that pops up on barrels
	thread fx_snow_shockwave();
	
	wait( 1.0 );
	//SHOCKWAVE FX
	earthquake( 0.35, 2, level.player.origin, 128 );
	//get direction to push player
	push_dir = VectorNormalize( level.player.origin - derrick_struct.origin );
	//push player	
	thread maps\black_ice_util::push_player_impulse( push_dir, 21, 0.9 );
	//rumble and shock!
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	//level.player ShellShock("default_nosound", 2);
	
	level notify( "notify_derrick_explode_done" );	
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_rain_light", 2 );	
}

fx_snow_shockwave()
{
	wait 0.82;
	
	exploder( "shockwave_snow" );
}

event_derrick_explode_debris_oiltank( derrick_struct )
{
	spawned_debris_animnames = 
	[
		"oiltank_debris_1_1",
		"oiltank_debris_1_2",
		"oiltank_debris_1_3",
		"oiltank_debris_3"
	];
	
	spawned_debris = [];
	
	foreach( animname in spawned_debris_animnames )
	{
		piece = spawn_anim_model( animname );
		derrick_struct anim_first_frame_solo( piece, "derrick_explosion" );		
		spawned_debris = array_add( spawned_debris, piece );
	}	
	
	// Show objects
	foreach( obj in level._refinery.scripted )
		obj Show();
	
	level waittill( "notify_refinery_explosion_start" );
	
	things = array_combine( level._refinery.scripted, spawned_debris );;
	
	// Pull out the travelling block and chunk for anims (currently in another script)
	things = array_remove( things, level._refinery.scripted[ "traveling_block" ] );
	things = array_remove( things, level._refinery.scripted[ "derrick_chunk" ] );
	
	// Animate!
	derrick_struct thread anim_single( things, "derrick_explosion" );
	
	level waittill( "notify_notetrack_debris_end" );
	
	// Break paths with debris
	foreach( obj in level._refinery.scripted )
		foreach( col in obj._col )
			col DisconnectPaths();
	
	level waittill( "notify_remove_derrick_model" );
	
	foreach( piece in spawned_debris )
		piece delete();
}

event_derrick_explode_catwalk_break( derrick_struct )
{
	catwalk = spawn_anim_model( "oiltank_catwalk" );
	static_catwalk = getent( "model_refinery_tank_catwalk", "targetname" );
	
	level waittill( "notify_derrick_large_explosion" );
	
	derrick_struct thread anim_single_solo( catwalk, "oiltank_catwalk" );
	
	catwalk hide();
	
	level waittill( "notify_swap_catwalk" );
	
	catwalk show();
	static_catwalk hide();
}

event_derrick_explode_impact_rig( derrick_struct )
{		
	
	// Derrick impacts the rig
	level waittill( "notify_derrick_impact_rig" );	
	
	//AUDIO: derrick explode impact sfx
	thread maps\black_ice_audio::sfx_blackice_derrick_exp4_ss();
	
	//slight wait before impact
	wait 0.65;
	earthquake( 0.17, 2, level.player.origin, 128 );

}

event_derrick_explode_debris_main( derrick_struct )
{			
	chunk_1	   = level._refinery.scripted[ "derrick_chunk" ];
	chunk_2	   = level._refinery.scripted[ "traveling_block" ];
	
	debris_1_1 = spawn_anim_model( "derrick_debris_1" );
	debris_1_2 = spawn_anim_model( "derrick_debris_1" );
	debris_2_1 = spawn_anim_model( "derrick_debris_2" );
	debris_2_2 = spawn_anim_model( "derrick_debris_2" );
	debris_3_1 = spawn_anim_model( "derrick_debris_3" );
	debris_3_2 = spawn_anim_model( "derrick_debris_3" );
	debris_4_1 = spawn_anim_model( "derrick_debris_4" );
	debris_4_2 = spawn_anim_model( "derrick_debris_4" );
	debris_5_1 = spawn_anim_model( "derrick_debris_5" );
	debris_5_2 = spawn_anim_model( "derrick_debris_5" );
	debris_6_1 = spawn_anim_model( "derrick_debris_6" );
	debris_6_2 = spawn_anim_model( "derrick_debris_6" );
	
	// Wait for large explosion
	level waittill( "notify_derrick_large_explosion" );		
	
	chunk_1 thread event_derrick_explode_debris_main_fx_runner( chunk_1, "refinery_debris_trail_large", "refinery_debris_smolder_large"  );
	chunk_2 thread event_derrick_explode_debris_main_fx_runner( chunk_2, "refinery_debris_trail_large", "refinery_debris_smolder_large"  );		
	
	//apm
	thread maps\black_ice_fx::refinery_travelling_block_impact_fx();
	
	derrick_debris = [debris_1_1, debris_1_2, debris_2_1, debris_2_2, debris_3_1, debris_3_2, debris_4_1, debris_4_2, debris_5_1, debris_5_2, debris_6_1, debris_6_2];
	
	foreach( thing in derrick_debris )
	{
		thing thread event_derrick_explode_debris_main_fx_runner( thing, "refinery_debris_trail_small", "refinery_debris_smolder_small"  );
	}
	
	derrick_struct thread anim_single_solo( chunk_1, "derrick_explosion" );
	derrick_struct thread anim_single_solo( chunk_2, "derrick_explosion" );
	derrick_struct thread anim_single_solo( debris_1_1, "derrick_debris_1" );
	derrick_struct thread anim_single_solo( debris_1_2, "derrick_debris_2" );
	derrick_struct thread anim_single_solo( debris_2_1, "derrick_debris_1" );
	derrick_struct thread anim_single_solo( debris_2_2, "derrick_debris_2" );
	derrick_struct thread anim_single_solo( debris_3_1, "derrick_debris_1" );
	derrick_struct thread anim_single_solo( debris_3_2, "derrick_debris_2" );
	derrick_struct thread anim_single_solo( debris_4_1, "derrick_debris_1" );
	derrick_struct thread anim_single_solo( debris_4_2, "derrick_debris_2" );
	derrick_struct thread anim_single_solo( debris_5_1, "derrick_debris_1" );
	derrick_struct thread anim_single_solo( debris_5_2, "derrick_debris_2" );
	derrick_struct thread anim_single_solo( debris_6_1, "derrick_debris_1" );
	derrick_struct thread anim_single_solo( debris_6_2, "derrick_debris_2" );		
}

event_derrick_explode_debris_main_fx_runner( thing, trailing_fx, static_fx )
{
		emitter = spawn_tag_origin();
		emitter.origin = thing.origin;
		emitter LinkTo( thing );
		
		PlayFXOnTag( GetFX( trailing_fx ), emitter, "tag_origin" );
		
		self waittill ("hitground");
		
		StopFXOnTag( GetFX( trailing_fx ), emitter, "tag_origin" );
		
		PlayFXOnTag( GetFX( static_fx ), emitter, "tag_origin" );
}

event_derrick_explode_debris_setup()
{
	// Derrick destruction
	derrick_struct = level._refinery.derrick_struct;
	
	// Spawned
	level._refinery.derrick_model = GetEnt( "model_blackice_derrick", "targetname" );
	level._refinery.derrick_model assign_animtree( "derrick" );			
	
	derrick_struct anim_first_frame_solo( level._refinery.derrick_model, "collapse" );
	
	level._refinery.barrel_model_1 = spawn_anim_model( "barrel_crush", derrick_struct.origin );
	derrick_struct anim_first_frame_solo( level._refinery.barrel_model_1, "barrel_crush_1" );
	
	level._refinery.barrel_model_2 = spawn_anim_model( "barrel_crush", derrick_struct.origin );
	derrick_struct anim_first_frame_solo( level._refinery.barrel_model_2, "barrel_crush_2" );
	
	level._refinery.barrel_model_3 = spawn_anim_model( "barrel_crush", derrick_struct.origin );
	derrick_struct anim_first_frame_solo( level._refinery.barrel_model_3, "barrel_crush_3" );
	
	level._refinery.barrel_model_4 = spawn_anim_model( "barrel_crush", derrick_struct.origin );
	derrick_struct anim_first_frame_solo( level._refinery.barrel_model_4, "barrel_crush_4" );
	
	level._refinery.barrel_model_5 = spawn_anim_model( "barrel_crush", derrick_struct.origin );
	derrick_struct anim_first_frame_solo( level._refinery.barrel_model_5, "barrel_crush_5" );
			
	// Scripted
	level._refinery.scripted = [];
		
	models = GetEntArray( "models_derrick_explosion", "targetname" );
	
	foreach( model in models )
	{
		model assign_animtree( model.script_parameters );
		model event_derrick_explode_debris_setup_collision( model.script_parameters );
		derrick_struct anim_first_frame_solo( model, "derrick_explosion" );
		model Hide();
		level._refinery.scripted[ model.script_parameters ] = model;
	}	
}

event_derrick_explode_debris_setup_collision( name )
{
	self._col = GetEntArray( self.target, "targetname" );
	Assert( self._col.size > 0 );
	
	if( name == "traveling_block" )
	{
		foreach( piece in self._col )
		{
			if( IsSubStr( piece.script_noteworthy, "hook" ))
				piece LinkTo( self, "tag_hook" );
			else if( IsSubStr( piece.script_noteworthy, "block" ))
				piece LinkTo( self, "tag_base" );
			else
				AssertMsg( SCRIPT_NAME + ": Unknown collision piece script_noteworthy for derrick chunk!" );
		}
	}
	else
	{
		foreach( piece in self._col )
			piece LinkTo( self );
	}
}

event_derrick_explode_debris_show_and_damage()
{
	// Wait for large explosion
	level waittill( "notify_derrick_large_explosion" );
	
	// Start damage
	foreach( obj in level._refinery.scripted )
		foreach( col in obj._col )
			col thread event_derrick_explode_debris_damage();
}

fx_refinery_ceiling_fire()
{
	
	level waittill( "notify_refinery_scene_complete" );
	
	exploder( "refinery_ceiling_fire" );
	
}

event_derrick_explode_debris_damage()
{
	level endon( "notify_notetrack_debris_end" );	
	
	while( 1 )
	{		
		enemies = remove_dead_from_array( level._enemies[ "refinery_initial" ] );
		
		foreach( guy in enemies )
		{
			if( self IsTouching( guy ))
			{				
				if( flag( "flag_refinery_player_killed_enemy" ) || flag( "flag_refinery_player_started_encounter" ))
				{
					// If player moved up too soon or shot someone, all enemies are vulnerable
					if( guy.v.active )
						guy vignette_kill();
					else
						guy kill();
				}
				else if(	
					!IsSubStr( guy.animname, "1" ) &&
				   	!IsSubStr( guy.animname, "2" ) && 
				   	!IsSubStr( guy.animname, "5" ) && 
				   	!IsSubStr( guy.animname, "6" ))
				{
					// Player hasn't moved up or shot anyone, top guys, crate guy, and foreman skip the system
					if( guy.v.active )
						guy vignette_kill();
					else
						guy kill();
				}
			}				
		}
		
		if( self IsTouching( level.player ))
		{
			level.player kill();
			
			setdvar( "ui_deadquote", &"BLACK_ICE_REFINERY_DEBRIS_DEATH" );
			maps\_utility::missionFailedWrapper();
		}
		
		wait( 0.05 );
	}
}

player_tanks_foreshocks()
{
	trigger_wait_targetname( "trig_refinery_ally_7" );
	
	//cue up fx in tanks section
	exploder( "tanks_oil_rain" );
	exploder( "tanks_lights" );
	
	trigger_wait_targetname( "trig_tanks_foreshock" );
	
	min_quake = 0.07;
	max_quake = 0.18;
	min_duration = 0.7;
	max_duration = 1.3;
	min_time = 0.3;
	max_time = 1.8;
	quake_number = 6;
	
	while( !flag( "flag_tanks_catwalk_collapse" ) && quake_number > 0 )
	{
		//AUDIO: distant oil tanks rumble
		thread maps\black_ice_audio::sfx_black_ice_tanks_rumble();

		quake = RandomFloatRange( min_quake, max_quake );
		time = RandomFloatRange( min_time, max_time );
		duration = RandomFloatRange( min_duration, max_duration );
		Earthquake( quake, duration, level.player.origin, 3000 );
		
		//AUDIO: screenshake sfx
		thread maps\black_ice_audio::sfx_screenshake();
		
		wait( time );
		
		quake_number -= 1;
	}
}

util_debris_remove()
{
	// Delete debris 
	if( IsDefined( level._refinery.scripted ))
	{
		foreach( obj in level._refinery.scripted )
		{		
			if( IsDefined( obj ))
			{
				// Delete collision
				foreach( col in obj._col )
					col delete();
				
				// Delete object itself
				obj delete();
			}
		}
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

vision_set_refinery_visionsets()
{
	level waittill( "notify_derrick_large_explosion" );
	vision_set_changes("black_ice_refinery_burn",2.0);
	maps\_art::sunflare_changes("refinery",1.5);
	
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

util_player_rubber_banding_solo( guy )
{
	level endon( "notify_stop_rubber_banding" );	
			
	// Set highest / lowest allowed speeds
	//low_speed = GetDvarFloat( "g_speed");
	low_speed = 130;
	high_speed = 190;
	
	// Max distance before lowest speed
	max_distance = 64;	
	
	while( 1 )
	{
		dist = Distance( self.origin, guy.origin );	
						
		if( dist > max_distance )
			dist = max_distance;		
		else if( dist < 0 )
			dist = 0;

		// Find and set playback rate scaled based on distance
		rate = dist / max_distance;				
		player_rubberband_speed = high_speed - ((high_speed - low_speed ) * rate);
		
		//adjust player speed
		SetSavedDvar( "g_speed", player_rubberband_speed );
		
		wait( 0.05 );
	}
	
	level notify( "notify_stop_rubber_banding" );
}