#include maps\_utility;
#include common_scripts\utility;


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_main()
{
	//level thread foo();
}

section_precache()
{
	// rumbles
	PreCacheRumble( "steady_rumble" );
	PreCacheRumble( "light_1s" );
	PreCacheRumble( "heavy_2s" );
	PreCacheRumble( "subtle_tank_rumble" );

	// shocks
	PreCacheShellShock( "flood_bridge_stumble" );
	
	// building01 debri assets
	PreCacheModel( "com_wallchunk_boardsmall03" );
	PreCacheModel( "pb_weaponscase" );
	PreCacheModel( "com_plastic_crate_pallet" );
	PreCacheModel( "com_wallchunk_boardlarge01" );
	PreCacheModel( "com_pallet_2" );
	PreCacheModel( "com_folding_chair" );
	PreCacheModel( "com_barrel_green" );
	PreCacheModel( "com_wallchunk_boardmedium01" );
	PreCacheModel( "com_wallchunk_boardmedium02" );
	PreCacheModel( "com_trashcan_metal_with_trash" );
	PreCacheModel( "com_wallchunk_boardsmall04" );
	PreCacheModel( "com_trashbin01" );


	level._effect[ "secondary_explosion" ] = LoadFX( "fx/explosions/small_vehicle_explosion" );
	// This will need to change once the ak12 flash is updated
	level._effect[ "glock_flash"		 ] = LoadFX( "fx/muzzleflashes/ak47_flash_wv" );
	level._effect[ "fx_flare_trail"		 ] = LoadFX( "fx/misc/flare_trail" );
}

section_flag_inits()
{
	//flag_init( "skybridge_enemies_aware" );
	flag_init( "skybridge_initial_hit" );
	flag_init( "debrisbridge_ready" );
	flag_init( "ally_using_water" );
	flag_init( "debrisbridge_setup_done" );
	flag_init( "rooftops_interior_encounter_start" );
	//flag_init( "rooftops_interior_in_combat_space" );		// using skybridge_safe_area flag, defined in the same threshold
	flag_init( "rooftops_exterior_encounter_start" );
	//flag_init( "rooftops_exterior_in_combat_space" );		// defined in flood_script_rooftops.map
	flag_init( "rooftops_water_encounter_start" );
	//flag_init( "rooftops_water_in_combat_space" );		// defined in flood_script_rooftops.map
	flag_init( "rooftops_encounter_b_done" );				// TODO should be changed to "rooftop_water_encounter_done"
	flag_init( "rooftops_heli_spawned" );
	flag_init( "rooftops_kill_shot" );
	flag_init( "rooftops_water_heli_approach" );
	flag_init( "player_fire_initiated_combat" );
	flag_init( "debrisbridge_LOS_blocked" );
	flag_init( "rooftops_water_advancing" );

	// vo
	flag_init( "skybridge_vo_1" );
	flag_init( "skybridge_vo_2" );
	flag_init( "skybridge_vo_3" );
	flag_init( "debrisbridge_vo_1" );
	//flag_init( "rooftops_vo_push_forward_hassle" );		// defined in flood_script_rooftops.map
	//flag_init( "rooftops_encounter_a_vo_upthestairs" );	// defined in flood_script_rooftops.map
	flag_init( "dont_interupt_vo" );
	flag_init( "rooftops_vo_interrior_done" );
	flag_init( "rooftops_vo_final_enemy" );
	flag_init( "rooftops_vo_kick_wall" );
	flag_init( "rooftops_vo_check_drop" );
	flag_init( "player_drop_progress" );
	//flag_init( "rooftops_water_vo_fromabove" );			// defined in flood_script_rooftops.map
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

SKYBRIDGE_SECTION_00	   = 0;
SKYBRIDGE_SECTION_01	   = 1;
SKYBRIDGE_SECTION_02	   = 2;
AI_SPAWN_WAVE_0			   = 0;
AI_SPAWN_WAVE_1			   = 1;
AI_SPAWN_WAVE_2			   = 2;
AI_SPAWN_WAVE_3			   = 3;
ROOFTOP_WATER_NUM_FLANKERS = 2;
ROOFTOP_WATER_LIMIT		   = 4;


//*******************************************************************
//                                                                  *
//                                                                  *
//				SKY BRIDGE SECTION									*
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "skybridge_start" );
	maps\flood_util::spawn_allies();
	//set_audio_zone( "flood_skybridge", 2 );

	thread maps\flood_coverwater::register_coverwater_area( "coverwater_stealth", "skybridge_done" );

	// hide swept away moment water
	thread maps\flood_swept::swept_water_toggle( "swim", "hide" );
	//thread maps\flood_swept::swept_water_toggle( "noswim", "show" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "show" );
	
	level thread maps\flood_anim::skybridge_doorbreach_setup();

	level.player TakeWeapon( "cz805bren+reflex_sp" );
	level.player TakeWeapon( "m9a1" );
	level.player GiveWeapon( "microtar" );
	level.player GiveWeapon( "flood_knife" );
	level.player SwitchToWeapon( "microtar" );
}


skybridge()
{
	{
		// some cleanup from stealth section
		level maps\flood_roof_stealth::reset_allies_to_defaults();
		battlechatter_off( "allies" );
		activate_trigger_with_targetname( "skybridge_color_order_start" );

		// these should already be turned off
		//level.allies[ 0 ] clear_force_color();
		level.allies[ 1 ] disable_ai_color();
		level.allies[ 2 ] disable_ai_color();
	}

	level.allies[ 0 ] set_force_color( "r" );

	//level thread skybridge_approach_fluff();

	// moved to flood_roof_stealth.gsc, should be moved again once we have a notetrack for teleport
	//level thread maps\flood_anim::skybridge_doorbreach_setup();

	level thread maps\flood_util::setup_water_death();

	level thread skybridge_encounter();
	level thread skybridge_to_rooftops_transition();
		// hide swept away moment water
	thread maps\flood_swept::swept_water_toggle( "swim", "hide" );
	//thread maps\flood_swept::swept_water_toggle( "noswim", "show" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "show" );

	level thread maps\flood_audio::skybridge_precursor_emitter();

	wait_for_targetname_trigger( "skybridge_encounter_0_trigger" );

	level thread autosave_by_name( "skybridge_start" );

	flag_wait( "skybridge_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_teleport_cheats()
{
	wait ( 1.25 );

	node  = GetNode( "skybridge_breach_node", "targetname" );
	delta = Distance( level.allies[ 0 ].origin, node.origin );

	if ( 256 < delta )
	{
		struct = GetStruct( "skybridge_breach_jumpto", "targetname" );
		level.allies[ 0 ] ForceTeleport( struct.origin, struct.angles, 1024 );

		rate = level.allies[ 0 ].moveplaybackrate;
		level.allies[ 0 ].moveplaybackrate = 1.2;
		wait ( 3.6 );
		level.allies[ 0 ].moveplaybackrate = rate;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_ally_setup_breach()
{
	wait ( 1.0 );

	node = GetNode( "skybridge_breach_node", "targetname" );
	rate = 1;
	if ( 128 < Distance( level.allies[ 0 ].origin, node.origin ) )
	{
		if ( 256 < Distance( level.allies[ 0 ].origin, node.origin ) )
		{
			struct = GetStruct( "skybridge_breach_jumpto", "targetname" );
			rate = self.moveplaybackrate;
			self.moveplaybackrate = 1.15;
		}
		else
		{
			struct = GetStruct( "skybridge_ally_1", "targetname" );
		}
		self ForceTeleport( struct.origin, struct.angles, 1024 );
	}
	
	wait ( 3.0 );
	self.moveplaybackrate = rate;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_encounter()
{
	level.allies[ 0 ] thread skybridge_ally_vo();
	level.allies[ 0 ] thread skybridge_ally_logic();

	//self thread skybridge_enemy_aware_logic();

	wait_for_targetname_trigger( "skybridge_encounter_0_trigger" );
	
	thread maps\flood_audio::skybridge_logic();
	/*
	spawners = GetEntArray( "skybridge_encounter_00_enemy_spawner", "targetname" );
	for ( spawner_index = 0; spawner_index < spawners.size; spawner_index++ )
	{
		spawners[ spawner_index ] add_spawn_function( ::skybridge_enemy_setup, spawner_index );
	}
	maps\_spawner::flood_spawner_scripted( spawners );

	flag_wait( "skybridge_initial_hit" );
	foreach( spawner in spawners )
	{
		spawner notify( "stop current floodspawner" );
	}
	*/
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
skybridge_breach_logic()
{
	trigger = GetEnt( "skybridge_breach_threshold", "targetname" );
	trigger waittill( "trigger", guy );

	if ( guy == level.player )
	{
		// remove blocker so player can activate door
		activate_trigger_with_targetname( "player_safety_blocker" );
	}
	else
	{
		
	}
}
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_debris_hit_large( guy )
{
	//skybridge_debris_hit( "large" );
}
skybridge_debris_hit_med( guy )
{
	//skybridge_debris_hit( "med" );
}
skybridge_debris_hit( type )
{
	if( flag( "on_skybridge" ) )
	{
		StopAllRumbles();
		if( "large" == type )
		{
			level.player ShellShock( "flood_bridge_stumble", 0.60 );
			level.player PlayRumbleOnEntity( "heavy_2s" );
			//level.player thread maps\flood_util::earthquake_w_fade( 0.7, 1.2 );
			wait( 0.75 );
			level.player.on_bridge = false;
		}
		else if( "med" == type )
		{
			level.player PlayRumbleOnEntity( "light_1s" );
			wait( 0.75 );
			level.player.on_bridge = false;
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// called on player
skybridge_rumble_logic()
{
	self endon( "death" );
	level.player.on_bridge = false;

	thread player_speed_set( 112, 0.05 );
	while( !flag( "skybridge_safe_area" ) )
	{
		if ( !self IsOnGround() && level.player.on_bridge )
		{
			StopAllRumbles();
			level.player notify( "earthquake_end" );
			level.player.on_bridge = false;
		}
		else if ( self IsOnGround() && !level.player.on_bridge )
		{
			level.player PlayRumbleLoopOnEntity( "subtle_tank_rumble" );
			level.player thread maps\flood_util::earthquake_w_fade( 0.21, 20 );
			level.player.on_bridge = true;
		}
		wait( 0.05 );
	}
	thread player_speed_default( 1.0 );
	StopAllRumbles();
	level.player thread maps\flood_util::earthquake_w_fade( 0.21, 1.0, 0, 0.5 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_ally_logic()
{
	// TODO fluff stuff like water dripping and wet looking ally
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_approach_fluff()
{
	trigger_wait_targetname( "skybridge_approach_rumble" );

	level.player PlaySound( "scn_flood_mall_rumble_shake_int_lg" );
	wait 1.893;
	level.player thread maps\flood_util::earthquake_w_fade( 0.2, 0.95, 0.25, 0.60 );
	level.player PlayRumbleOnEntity( "light_1s" );
	// effects
	//exploder( "" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//				ROOFTOPS SECTION									*
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "rooftops_start" );
	maps\flood_util::spawn_allies();

	level.allies[ 0 ] clear_force_color();
	level.allies[ 1 ] clear_force_color();
	level.allies[ 2 ] clear_force_color();
	level.allies[ 0 ] set_force_color( "r" );

	//set_audio_zone( "flood_rooftops", 2 );

	self thread maps\flood_util::setup_water_death();

	level thread skybridge_to_rooftops_transition();

	waittillframeend;		// heli & allies just spawned
	activate_trigger_with_targetname( "rooftops_ally_logic_0_trigger" );
	flag_set( "skybridge_heli_go" );
	flag_set( "skybridge_safe_area" );
	flag_set( "skybridge_ally_done" );
	activate_trigger_with_targetname( "rooftops_color_order_start" );

	// hide swept away moment water
	thread maps\flood_swept::swept_water_toggle( "swim", "hide" );
	//thread maps\flood_swept::swept_water_toggle( "noswim", "show" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "show" );
	
	//thread maps\flood_util::setup_bokehdot_volume( "skybridge_room_bokehdots" );


	level.player TakeWeapon( "cz805bren+reflex_sp" );
	level.player TakeWeapon( "m9a1" );
	level.player GiveWeapon( "microtar" );
	level.player GiveWeapon( "flood_knife" );
	level.player SwitchToWeapon( "microtar" );
}


rooftops()
{
	level thread autosave_by_name( "rooftops_a_start" );
	level thread rooftops_encounter_a();
	level thread rooftops_to_rooftops_water_transition();
	//thread maps\flood_util::setup_bokehdot_volume( "skybridge_room_bokehdots" );

	exploder( "ending_smk_plume" );

	flag_wait( "rooftops_done" );

	level thread rooftops_cleanup_post_wallkick();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a()
{
	//level thread rooftops_encounters_logic();			// call got moved to skybridge_to_rooftops_transition()
	self thread maps\flood_anim::rooftops_outro_scene_setup();
	self thread rooftops_outro_setup_blocker();
	//level.player thread debug_kill_enemies_in_order( 1.0 );

	for( index = 0; index < 3; index++ )
	{
		spawners = GetEntArray( "rooftops_encounter_a_" + index + "_spawner", "targetname" );

		array_thread( spawners, ::add_spawn_function, ::set_grenadeammo, 0 );

		switch( index )
		{
			case 0:	// rooftops interior enemies
				// spawn point for runners got moved to skybridge_to_rooftops_transition()
				break;

			case 1:	// rooftops heli actors
				array_thread( spawners, ::add_spawn_function, ::rooftop_enemy_exfil_logic );
				//array_thread( spawners, ::add_spawn_function, ::rooftops_enemy_combat_logic );
				array_thread( spawners, ::add_spawn_function, ::rooftops_enemy_aggresive_logic );
				maps\flood_anim::rooftops_enemy_exfil_spawn_actors( spawners );
				level thread maps\flood_anim::rooftops_enemy_exfil_setup_heli();

				rooftops_exterior_waittill_encounter_trigger();

				thread maps\flood_anim::rooftops_enemy_exfil_spawn();

				level.allies[ 0 ] thread rooftops_encounter_a_ally_reveal_logic();
				break;

			case 2:	// rooftops guards
				array_thread( spawners, ::add_spawn_function, ::rooftops_encounter_a_enemy_logic );
				array_thread( spawners, ::add_spawn_function, ::rooftop_enemy_exfil_logic );
				array_thread( spawners, ::add_spawn_function, ::rooftops_enemy_combat_logic );
				array_thread( spawners, ::add_spawn_function, ::rooftops_enemy_aggresive_logic );
				array_thread( spawners, ::spawn_ai );

				waittillframeend;
				if( flag( "rooftops_runner_escape" ) )
				{
					// make rooftop enemies instantly aware
					activate_trigger_with_targetname( "exfil_abort" );
					flag_set( "rooftops_exterior_encounter_start" );
				}
				break;

		}
	}

	flag_wait_all( "rooftops_encounter_a_death", "rooftop_runners_death" );

	maps\flood_util::cleanup_triggers( "rooftops_encounter_a" );

	level thread rooftops_encounter_a_outro();

	flag_wait( "rooftops_vo_check_drop" );
	autosave_by_name( "rooftops_a_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounters_logic()
{
	level.player thread rooftops_encounters_player_logic();
	level.allies[ 0 ] thread rooftops_encounters_ally_logic();

	flag_wait( "rooftops_interior_encounter_start" );

	thread battlechatter_on( "axis" );

	flag_wait( "rooftops_exterior_encounter_start" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounters_player_logic()
{
	// START OF ROOFTOPS INTERIOR
	flag_wait( "skybridge_safe_area" );

	level thread rooftops_cleanup_post_skybridge();

	set_player_attacker_accuracy( 0 );
	self.ignorerandombulletdamage = true;

	self thread rooftops_player_start_combat_attack( "rooftops_interior_encounter_start" );
	self thread rooftops_interior_player_start_combat_trigger();
	flag_wait( "rooftops_interior_encounter_start" );					// can be triggered by player firing or hitting trigger plane

	wait( 2.50 );

	maps\_gameskill::updateAllDifficulty();
	self.ignorerandombulletdamage = false;


	// START OF ROOFTOPS EXTERIOR
	flag_wait( "rooftops_exterior_in_combat_space" );

	set_player_attacker_accuracy( 0 );
	self.ignorerandombulletdamage = true;

	self thread rooftops_player_start_combat_attack( "rooftops_exterior_encounter_start" );
	flag_wait( "rooftops_exterior_encounter_start" );					// can be triggered by player firing or enemy spotting player

	// need to make sure the player is actually in view of everything before we start to take away the player's bullet shield
	trigger = GetEnt( "in_sight_of_enemy_exfil", "targetname" );
	if( IsDefined( trigger ) )
	{
		trigger waittill( "trigger" );
	}

	self thread maps\flood_util::notify_on_function_finish( "can_be_hit", ::waittill_notify_or_timeout, "weapon_fired", 2.5 );
	if( IsDefined( GetEnt( "exfil_abort", "targetname" ) ) )
	{
		self thread maps\flood_util::notify_on_function_finish( "can_be_hit", ::wait_for_targetname_trigger, "exfil_abort" );
		self waittill( "can_be_hit" );
	}

	// reset player to full attackeraccuracy
	maps\_gameskill::updateAllDifficulty();
	self.ignorerandombulletdamage = false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_player_start_combat_attack( flag_handle )
{
	flag_clear( "player_fire_initiated_combat" );
	self waittill_any( "weapon_fired", "grenade_fire" );
	flag_set( flag_handle );
	flag_set( "player_fire_initiated_combat" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_interior_player_start_combat_trigger()
{
	self thread rooftops_interior_start_combat_solid_sight_line();
	self thread rooftops_interior_start_combat_soft_sight_line();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_interior_start_combat_solid_sight_line()
{
	wait_for_targetname_trigger( "in_sight_of_runners" );
	flag_set( "rooftops_interior_encounter_start" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_interior_start_combat_soft_sight_line()
{
	wait_for_targetname_trigger( "in_sight_of_runners_early" );

	switch( getDifficulty() )
	{
		case "fu":
			wait( 1.5 );
			break;
		case "hard":
			wait( 3.0 );
			break;
		default:
			wait( 7.0 );
	}
	flag_set( "rooftops_interior_encounter_start" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounters_ally_logic()
{
	self thread rooftops_encounter_a_ally_vo();

	//wait_for_targetname_trigger( "rooftops_ally_logic_0_trigger" );
	flag_wait( "skybridge_ally_done" );

	self thread rooftops_ally_cqb_to_first_node();
	self disable_surprise();

	self.ignoreall = true;
	self.ignoreme = true;

	flag_wait( "rooftops_interior_encounter_start" );
	self notify( "spotted" );							// used in ally hold up VO

	self.ignoreme = false;
	if( flag( "rooftops_vo_interrior_done" ) )
	{
		// maybe some VO, we've been spotted
		self maps\flood_util::waittill_danger();
	}
	self.ignoreall = false;

	self thread rooftops_ally_advance_to_roof();

	wait_for_targetname_trigger( "rooftops_ally_logic_1_trigger" );

	self thread rooftops_encounter_a_ally_cleanup_logic();
	self thread rooftops_encounter_a_ally_crouch_walk_to_cover();

	// proper clean up of rooftops_encounter_a_ally_crouch_walk_to_cover()
	// if ally never makes it to goal node, he will crouch walk into outro vignette
	flag_wait( "rooftops_encounter_a_death" );
	self AllowedStances( "stand", "crouch", "prone" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_ally_crouch_walk_to_cover()
{
	// i should prolly be checking if the player has been spotted yet, not the trigger
	trigger = GetEnt( "in_sight_of_enemy_exfil", "targetname" );
	if ( IsDefined( trigger ) )
	{
		temp = self.goalradius;
		self.goalradius = 64;
		self AllowedStances( "crouch" );
		self waittill( "goal" );
		self.goalradius = temp;
		self AllowedStances( "stand", "crouch", "prone" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_exterior_waittill_encounter_trigger()
{
	trigger = GetEnt( "rooftops_encounter_a_1_trigger", "targetname" );
	while( !flag( "rooftops_runner_escape" ) )
	{
		if( !IsDefined( trigger ) )
		{
			break;
		}
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_ally_cleanup_logic()
{
	flag_wait( "rooftops_exterior_encounter_start" );

	self thread maps\flood_util::notify_on_enemy_count( 1, undefined, "rooftops_kill_shot" );
	flag_wait( "rooftops_kill_shot" );
	flag_set( "rooftops_vo_final_enemy" );
	maps\flood_util::cleanup_triggers( "rooftops_encounter_a" );
	activate_trigger_with_targetname( "rooftops_encounter_a_kill_shot" );
	thread battlechatter_off( "allies" );

	temp = self.suppressionwait;
	self.ignoresuppression = true;
	self.suppressionwait = 0;

	flag_wait( "rooftops_encounter_a_death" );

	self.suppressionwait = temp;
	self.ignoresuppression = false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_ally_cqb_to_first_node()
{
	self enable_cqbwalk();

	flag_wait( "rooftops_interior_encounter_start" );
	self disable_cqbwalk();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_ally_advance_to_roof()
{
	level thread maps\flood_util::notify_on_enemy_count_touching_volume( "rooftop_runners_vol", 0, "enemies_escaped" );

	level waittill_any( "enemies_escaped", "rooftop_runners_death" );
	level notify( "stop_checking_volume" );		//make sure notify_on_enemy_count_touching_volume() is no longer running

	trigger = GetEnt( "rooftops_encounter_a_setup", "targetname" );
	if( IsDefined( trigger ) )
	{
		trigger activate_trigger();
	}

	temp = self.suppressionwait;
	self disable_cqbwalk();
	self.suppressionwait = 0;
	self.ignoresuppression = true;
	self.disableplayeradsloscheck = true;
	self.disableFriendlyFireReaction = true;

	wait_for_targetname_trigger( "rooftops_ally_logic_1_trigger" );

	self.suppressionwait = temp;
	self.ignoresuppression = false;
	self.disableplayeradsloscheck = false;
	self.disableFriendlyFireReaction = undefined;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_ally_reveal_logic()
{
	// this needs to change as we have better reveal logic
	self.ignoreall = true;
	self.ignoreme = true;

	self maps\flood_util::waittill_danger_or_trigger( "exfil_abort" );

	self.ignoreall = false;
	self.ignoreme = false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_enemy_logic()
{
	self endon( "death" );

	self waittill( "combat_ready" );

	if ( !flag( "rooftops_kill_shot" ) )
	{
		self thread maps\flood_util::update_goal_vol_from_trigger( "rooftops_encounter_a_intro_trigger"		 , "rooftops_encounter_a_intro_vol" );
		self thread maps\flood_util::update_goal_vol_from_trigger( "rooftops_encounter_a_flank_left_trigger" , "rooftops_encounter_a_flank_left_vol" );
		self thread maps\flood_util::update_goal_vol_from_trigger( "rooftops_encounter_a_flank_right_trigger", "rooftops_encounter_a_flank_right_vol" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftop_enemy_runner_logic()
{
	self endon( "death" );

	self disable_surprise();

	Assert( IsDefined( self.target ) );
	if( "rooftop_runner_computer" == self.target )
	{
		self.animname	= "generic";
		self.health		= 1;
		self.allowdeath = true;
		anim_org		= getstruct( self.target, "targetname" );
		Assert( IsDefined( anim_org ) );

		anim_org thread maps\_anim::anim_loop_solo( self, "hacking", "enemies_spotted" );
	}
	else
	{
		struct = getstruct( self.target, "targetname" );
		self Teleport( struct.origin, struct.angles );
		self set_fixednode_true();
		self.ignoreall = true;
	}


	flag_wait( "rooftops_interior_encounter_start" );

	self notify( "enemy_near" );					// for VO that enemy is near
	self notify( "combat_ready" );					// for changing goal volumes when player moves around play space

	temp_dist		= self.maxFaceEnemyDist;
	temp_radius		= self.goalradius;
	self.goalradius = 32;							//level.magic_distance;

	if( "rooftop_runner_computer" == self.target )
	{
		if ( flag( "player_fire_initiated_combat" ) )
		{
			wait( RandomFloat( 0.50 ) );
		}
		else
		{
			wait( 1.0 + RandomFloat( 0.50 ) );
		}

		self notify( "enemies_spotted" );			// so guy on computer breaks out of anim
		self StopAnimScripted();

		self.fixednode = true;
		self.maxFaceEnemyDist = 1024;
		self SetGoalNode( GetNode( "runner_goal_0", "targetname" ) );
		wait( 2.0 );
		self.ignoreall = true;
		wait( 2.5 );
		self.ignoreall = false;
	}
	else
	{
		self notify( "fire" );
		if( !flag( "rooftops_vo_interrior_done" ) )
		{
			wait ( 0.50 );							// give the player a chance to recognize this first dangerous guy
		}
		self set_fixednode_false();
		self.ignoreall = false;
		self thread rooftop_runner_force_gunfire();
		self SetGoalNode( GetNode( "rooftop_runner_cover", "targetname" ) );
		self waittill( "goal" );

		wait( 2.5 );
		self SetGoalNode( GetNode( "runner_goal_1", "targetname" ) );
	}

	self waittill( "goal" );
	self.fixednode = false;
	self.maxfaceenemydist = temp_dist;
	self.goalradius = temp_radius;
	maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_a_intro_vol" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftop_runner_force_gunfire()
{
	wait( 0.5 );
	self Shoot( 1.0, level.player.origin + ( 0, 0, 64 ) );
	wait( 0.20 );
	self Shoot( 1.0, level.player.origin + ( 0, 0, 64 ) );
	wait( 0.20 );
	self Shoot( 1.0, level.player.origin + ( 0, 0, 64 ) );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftop_enemy_exfil_logic()
{
	self endon( "death" );

	waittillframeend;

	if ( IsDefined( self.script_noteworthy ) )
	{
		if ( "cover_flank" == self.script_noteworthy )
		{
			self.fixednode = true;
			self thread rooftops_player_spotted_vo( "exfil_abort" );
			level thread rooftops_enemy_alert_rest( self );

			// requested shittyness. I don't like making the enemies look like idiots
			node = GetNode( "node_cover_flank_start", "targetname" );
			node thread maps\_anim::anim_loop_solo( self, "stand_idle", "enemy_spotted" );

			self waittill( "enemy" );
			node notify( "enemy_spotted" );
			self StopAnimScripted();

			self handsignal( "enemy" );
			wait( 3.00 );
			self.fixednode = false;
		}
		else if ( "ladder_holder" == self.script_noteworthy )
		{
			self disable_surprise();
			self thread rooftops_encounter_a_enemy_logic();
			self waittill( "fight" );		// sent from rooftops_enemy_exfil_spawn()
			self.health			   = 120;
			//self.allowdeath		   = true;
		}
		else if ( "cover_ledge" == self.script_noteworthy )
		{
			self.animname = "generic";
			node = GetNode( "node_cover_ledge_start", "targetname" );
			node thread maps\_anim::anim_loop_solo( self, "stand_idle", "enemy_spotted" );

			self waittill( "fight" );
			wait( 0.30 );
			node notify( "enemy_spotted" );
			self StopAnimScripted();
		}
		else
		{
			self.ignoreall = true;
			self maps\_patrol_anims_creepwalk::enable_creepwalk();
			self thread maps\_patrol::patrol();
			self waittill( "fight" );		// this comes from enemy covering flank
			self.ignoreall = false;
			self waittill( "enemy" );		// this comes from ai picking up a target
			self notify( "stop_going_to_node" );
		}

		node = GetNode( "node_" + self.script_noteworthy, "targetname" );
		temp_radius = self.goalradius;
		self.goalradius = node.radius;
		self.fixednode = true;
		self SetGoalNode( node );
		self waittill( "goal" );
		self.goalradius = temp_radius;
		wait( 2.0 );
		self.fixednode = false;
		self notify( "combat_ready" );
		maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_a_intro_vol" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_enemy_alert_rest( actor )
{
	actor maps\flood_util::add_actor_danger_listeners();
	actor waittill_any( "enemy", "death", "ai_event" );

	enemies = get_ai_group_ai( "back_line" );
	foreach ( enemy in enemies )
	{
		enemy notify( "fight" );
	}
	flag_set( "rooftops_exterior_encounter_start" );
	activate_trigger_with_targetname( "rooftops_encounter_a_vo_1" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_outro_setup_blocker()
{
	blocker = GetEnt( "brick_wall_blocker", "targetname" );
	blocker MoveZ( -128, 0.05 );

	wait_for_targetname_trigger( "rooftops_ally_exited" );
	blocker = GetEnt( "brick_wall_blocker", "targetname" );
	blocker NotSolid();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_outro_remove_blocker( guy )
{
	blocker = GetEnt( "brick_wall_blocker", "targetname" );
	//blocker Delete();
	blocker NotSolid();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_outro()
{
	level.allies[ 0 ] PushPlayer( true );
	level.allies[ 0 ] disable_ai_color();
	level.allies[ 0 ] disable_turnAnims();
	maps\flood_anim::rooftops_outro_scene_spawn();
	level.allies[ 0 ] PushPlayer( false );

	if( flag( "vignette_rooftops_water_long_jump" ) )
	{
		level thread maps\flood_anim::rooftops_water_long_jump_spawn();
	}
	else
	{
		level.allies[ 0 ] enable_ai_color();
		activate_trigger_with_targetname( "rooftops_encounter_a_done" );
		level thread rooftops_long_jump();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_long_jump()
{
	flag_wait( "vignette_rooftops_water_long_jump" );
	maps\flood_anim::rooftops_water_long_jump_spawn();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//				ROOFTOPS B SECTION									*
//                                                                  *
//                                                                  *
//*******************************************************************

rooftop_water_start()
{
	maps\flood_util::player_move_to_checkpoint_start( "rooftop_water_start" );
	maps\flood_util::spawn_allies();

	level.allies[ 0 ] clear_force_color();
	level.allies[ 1 ] clear_force_color();
	level.allies[ 2 ] clear_force_color();
	level.allies[ 0 ] set_force_color( "r" );

	//set_audio_zone( "flood_rooftops", 2 );
	
	self thread maps\flood_util::setup_water_death();
	self thread rooftops_to_rooftops_water_transition();

	flag_set( "rooftops_player_dropped_down" );
	activate_trigger_with_targetname( "rooftop_water_color_order_start" );

	// hide swept away moment water
	thread maps\flood_swept::swept_water_toggle( "swim", "hide" );
	//thread maps\flood_swept::swept_water_toggle( "noswim", "show" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "show" );
}


rooftop_water()
{
	// start checking if the player is in water
	thread maps\flood_coverwater::register_coverwater_area( "coverwater_rooftop", "debrisbridge_done" );
	level.cw_player_in_rising_water = false;
	level.cw_player_allowed_underwater_time = 15;

	level thread autosave_by_name_silent( "rooftops_b_start" );
	level thread rooftops_encounter_b();

	level thread rooftop_water_to_debrisbridge_transition();
	
	level thread rooftops_water_splash();

	flag_wait( "rooftop_water_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b()
{
	level.allies[ 0 ] thread rooftops_encounter_b_ally_logic();
	level.player thread rooftops_water_player_logic();
	level thread rooftops_water_set_advancing_state();
	level thread rooftops_encounter_b_enemy_vo();
	level thread rooftops_encounter_b_enemy_movement_logic();
	//level thread rooftops_encounter_b_turret_logic();
	level thread rooftops_encounter_b_force_clear();
	level thread rooftops_water_enemy_heli_logic();

	for ( index = 0; index < 4; index++ )
	{
		spawners = GetEntArray( "rooftops_encounter_b_" + index + "_spawner", "targetname" );

		array_thread( spawners, ::add_spawn_function, ::disable_long_death );
		array_thread( spawners, ::add_spawn_function, ::set_grenadeammo, 0 );
		array_thread( spawners, ::add_spawn_function, ::rooftops_water_enemy_logic );

		switch( index )
		{
			case 0:
				array_thread( spawners, ::add_spawn_function, ::rooftops_water_truck_actor_setup );
				array_thread( spawners, ::add_spawn_function, ::rooftops_water_reveal_logic );
				maps\flood_anim::rooftops_water_intro_spawn_actors( spawners );
				thread maps\flood_anim::rooftops_water_intro();
				break;

			case 1:
				array_thread( spawners, ::add_spawn_function, ::rooftops_water_reveal_logic );
				array_thread( spawners, ::spawn_ai, true );
				break;

			case 2:
				flag_wait( "rooftops_water_in_combat_space" );
				level thread rooftops_cleanup_post_walkway();
				level notify( "fight" );

				level thread trigger_vo_in_combat( "rooftops_encounter_b_vo_1", 10.0 + RandomFloat( 3.0 ) );

				self maps\flood_util::waittill_aigroup_count_or_timeout( "rooftop_scene_actors", 1, 12.0 );
				maps\flood_util::cleanup_triggers( "rooftops_encounter_b_cleanup_push" );
				if( !flag( "rooftops_water_advancing" ) )
				{
					activate_trigger_with_targetname( "rooftops_water_push_0" );
				}

				array_thread( spawners, ::spawn_ai, true );
				break;

			case 3:
				maps\flood_util::waittill_enemy_count_or_flag( 3, "rooftops_water_enemy_retreat" );
				trigger = GetEnt( "debrisbridge_color_order_start", "targetname" );
				if( !flag( "rooftop_water_done" ) )
				{
					if ( Isdefined( trigger ) )
					{
						array_thread( spawners, ::spawn_ai, true );
					}
					self thread maps\flood_util::notify_on_enemy_count( 2, "final_push" );
					self waittill( "final_push" );
					maps\flood_util::cleanup_triggers( "rooftops_encounter_b" );
				}
				else
				{
					foreach( spawner in spawners )
					{
						spawner Delete();
					}
				}
				if( !flag( "rooftops_water_advancing" ) )
				{
					activate_trigger_with_targetname( "rooftops_water_push_1" );
				}
				break;

		}
	}

	flag_wait( "rooftops_encounter_b_death" );

	maps\flood_util::cleanup_triggers( "rooftops_encounter_b_cleanup_push" );
	maps\flood_util::cleanup_triggers( "rooftops_encounter_b" );

	flag_set( "rooftops_encounter_b_done" );

	rooftops_encounter_b_outro();

	autosave_by_name( "rooftops_b_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_intro_flare_setup( flare_0, flare_1 )
{
	PlayFXOnTag( level._effect[ "fx_flare_trail" ], flare_0 , "TAG_FIRE_FX" );
	PlayFXOnTag( level._effect[ "fx_flare_trail" ], flare_1, "TAG_FIRE_FX" );
	
	self thread rooftops_water_intro_flare_actor_cleanup();

	flag_wait( "rooftops_water_flare_intro_done" );

	flare_0 StopAnimScripted();
	flare_1 StopAnimScripted();

	// drop flares to the ground
	trace = BulletTrace( flare_0.origin, flare_0.origin - ( 0, 0, 10000 ), false );
	flare_0 MoveTo ( trace[ "position" ], 0.5 );
	flare_0 RotateTo( ( 0, RandomInt( 360 ), RandomInt( 360 ) )			, 0.5 );

	trace = BulletTrace( flare_1.origin, flare_1.origin - ( 0, 0, 10000 ), false );
	flare_1 MoveTo	( trace[ "position" ], 0.5 );
	flare_1 RotateTo( ( 0, RandomInt( 360 ), RandomInt( 360 ) )			, 0.5 );

	wait( 5.0 );
	StopFXOnTag( level._effect["fx_flare_trail"], flare_0, "TAG_FIRE_FX" );
	StopFXOnTag( level._effect["fx_flare_trail"], flare_1, "TAG_FIRE_FX" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_intro_flare_actor_cleanup()
{
	self waittill( "death" );

	flag_set( "rooftops_water_flare_intro_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_truck_intro_weapon_cleanup()
{
	self waittill( "death" );

	if( IsDefined( self.glock ) )
	{
		self.glock Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_truck_actor_setup()
{
	self thread maps\flood_util::add_actor_danger_listeners();

	self waittill( "ai_event" );
	flag_set( "rooftops_water_encounter_start" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_reveal_grab_gun( guy )
{
	guy.glock.origin = guy GetTagOrigin( "TAG_INHAND" );
	guy.glock.angles = guy GetTagAngles( "TAG_INHAND" );
	guy.glock Linkto( guy, "TAG_INHAND" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_reveal_shoot( guy )
{
	if( IsDefined( guy.glock ) )
	{
		eye	  = level.player GetEye();
		dir	  = VectorNormalize( eye - guy.glock GetTagOrigin( "TAG_FLASH" ) );
		right = AnglesToRight( VectorToAngles( dir ) );

		shoot_right = 1;
		if ( RandomInt( 2 ) )
		{
			shoot_right = -1;
		}

		PlayFXOnTag( level._effect[ "glock_flash" ], guy.glock, "TAG_FLASH" );
		MagicBullet( "microtar", guy.glock GetTagOrigin( "TAG_FLASH" ), eye + ( shoot_right * right * RandomIntRange( 20, 32 ) ) );
		//Line( guy.glock GetTagOrigin( "TAG_FLASH" ), eye + ( shoot_right * right * RandomIntRange( 20, 32 ) ), ( 0, 0, 50 ), 1.0, false, 50 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_player_logic()
{
	self thread rooftops_water_player_ignoreme_logic();

	set_player_attacker_accuracy( 0 );
	self.ignorerandombulletdamage = true;
	
	flag_wait( "rooftops_water_in_combat_space" );
	flag_set( "rooftops_water_encounter_start" );

	//level thread debug_countdown_timer( 4.0, "done" );
	self wait_for_notify_or_timeout( "weapon_fired", 6.0 );
	//level notify( "stop_timer" );
	//iprintln( "reseting attacker accuracy" );

	GetEnt( "rooftops_water_sight_blocker", "targetname" ) Delete();

	// reset player to full attackeraccuracy
	maps\_gameskill::updateAllDifficulty();
	self.ignorerandombulletdamage = false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_player_ignoreme_logic()
{
	self.ignoreme = true;

	flag_wait( "rooftops_water_in_combat_space" );
	self wait_for_notify_or_timeout( "weapon_fired", 4.0 );
	wait( RandomFloat( 0.50 ) );
	//iprintln( "enemies can now see the player" );

	self.ignoreme = false;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_enemy_logic()
{
	self endon( "death" );

//	self thread maps\flood_coverwater::ai_setup_for_coverwater( "rooftops_encounter_b_death" );
	self magic_bullet_shield();

	flag_wait( "rooftops_water_in_combat_space" );

	self notify( "stop_going_to_node" );
	self stop_magic_bullet_shield();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_enemy_heli_logic()
{
	heli_spawner = GetEnt( "rooftops_water_heli_0", "targetname" );
	heli_spawner add_spawn_function( ::rooftops_water_heli_movement_logic );

	heli = maps\_vehicle::vehicle_spawn( heli_spawner );

	/*
	for( index = 0; index < 2; index++ )
	{
		spawner = GetEnt( "rooftops_water_heli_" + index, "targetname" );

		heli = maps\_vehicle::vehicle_spawn( spawner );
		heli maps\_vehicle::godon();
		heli thread maps\_vehicle::gopath();
		wait ( 1.0 );
	}
	*/
}



//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_heli_movement_logic()
{
	self endon( "death" );
	level endon( "rooftops_water_heli_exit" );
	self thread rooftops_water_heli_exit_logic();
	self thread rooftops_water_heli_damage_logic();

	level.rooftops_water_heli = self;

	self notify( "stop_friendlyfire_shield" );
	self.health = self.script_startinghealth;

	if ( IsDefined( self.mgturret ) )
	{
		foreach ( turret in self.mgturret )
		{
			turret SetAISpread( 3 );
			turret SetConvergenceTime( 2.5 );
			turret.accuracy = .85;
			//turret Setautorotationdelay( 3 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_heli_damage_logic()
{
	self endon( "death" );

	while ( true )
	{
		self waittill( "damage" );
		if( self.health < 2500 )
		{
			break;
		}
	}

	flag_set( "rooftops_water_heli_exit" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_heli_exit_logic()
{
	self endon( "death" );

	flag_wait( "rooftops_water_encounter_start" );
	self thread maps\_vehicle::gopath();
	flag_wait_or_timeout( "rooftops_water_heli_exit", 5.7 );

	//self maps\_vehicle::godon();
	//self thread maps\_vehicle_code::friendlyfire_shield();

	exit_node = getstruct( "south_exit", "targetname" );

	self ClearLookAtEnt();
	self Vehicle_HeliSetAI( exit_node.origin, 45, 10, 15, 0, (0, 0, 0), 0, 0.0, 0, 0, 0, 0, 0 );

	self.attachedpath = exit_node;
	self thread maps\_vehicle::vehicle_paths( exit_node );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_enter_combat_space()
{
	trigger = GetEnt( "rooftops_water_jumpdown_splash_ally", "targetname" );
	trigger thread rooftops_water_enter_combat_space_play_effects();
	trigger = GetEnt( "rooftops_water_jumpdown_splash", "targetname" );
	trigger thread rooftops_water_enter_combat_space_play_effects();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_enter_combat_space_play_effects()
{
	self waittill( "trigger", ent );

	loc = undefined;

	if( ent == level.player )
	{
		ent PlayRumbleOnEntity( "heavy_2s" );
		forward = AnglesToForward( level.player GetPlayerAngles() );
		loc		= ( ent.origin + ( 0, 0, 24 ) ) + ( forward * 28 );
		ent PlaySound( "scn_flood_intowater_splash_plr_ss" );
	}
	else
	{
		loc = ent.origin + ( 0, 0, 16 );
		ent PlaySound( "scn_flood_intowater_splash_ss" );
	}

	//PlayFX( level._effect[ "splash" ], loc );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_ally_logic()
{
	self thread rooftops_encounter_b_ally_vo();

	wait_for_targetname_trigger( "rooftop_water_color_order_start" );

//	self maps\flood_coverwater::ai_setup_for_coverwater( "rooftop_water_done", false );
	self thread rooftops_water_ally_presence();
	self.ignoreall = true;
	self.ignoreme = true;

	self thread rooftops_encounter_b_ally_use_water_correctly();
	self disable_surprise();
	flag_wait( "rooftops_water_encounter_start" );
	trigger = GetEnt( "in_sight_of_rooftop_scene", "targetname" );
	if( IsDefined( trigger ) )
	{
		trigger activate_trigger();				// this gets the ally moving to his next color nodes
		// trigger Delete();
	}

	self.ignoreall = false;
	self.ignoreme = false;

	//wait_for_targetname_trigger( "rooftops_ally_logic_1_trigger" );

	self thread maps\flood_util::notify_on_enemy_count( 1, "go_for_the_kill" );
	self waittill( "go_for_the_kill" );

	maps\flood_util::cleanup_triggers( "rooftops_encounter_b" );
	trigger = GetEnt( "rooftops_encounter_b_kill_shot", "targetname" );
	if( IsDefined( trigger ) )
	{
		trigger activate_trigger();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_set_advancing_state()
{
	trigger = GetEnt( "push_to_next_encounter", "script_noteworthy" );
	trigger waittill( "trigger" );
	flag_set( "rooftops_water_advancing" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_ally_presence()
{
	self endon( "ai_event" );

	wait_for_targetname_trigger( "in_sight_of_rooftop_scene_ally" );

	wait( 20.0 );		// need to wait some abritrary amount. Hoping that player will jump down.

	flag_set( "rooftops_water_encounter_start" );		// trigger enemy actor animations
	self notify( "ai_event" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_enemy_movement_logic()
{
	turtling = false;
	defensive = false;
	aggresive = false;

	wait_for_targetname_trigger( "in_sight_of_rooftop_scene" );

	while ( !flag( "rooftops_encounter_b_death" ) )
	{
		if ( flag( "rooftops_encounter_b_player_turtling" ) && !flag( "cw_player_underwater" ) )
		{
			if ( !turtling )
			{
				self thread rooftops_encounter_b_handle_turtling();
				turtling = true;
			}
		}
		else
		{
			turtling = false;

			if ( flag( "rooftops_encounter_b_player_defensive" ) && !flag( "cw_player_underwater" ) )
			{
				if( !defensive )
				{
					self thread rooftops_encounter_b_handle_defensive();
					defensive = true;
				}
			}
			else
			{
				defensive = false;


				if( flag( "rooftops_encounter_b_player_aggresive" ) && !flag( "cw_player_underwater" ) )
				{
					actors_count = get_ai_group_sentient_count( "rooftop_scene_actors" );
					main_count = get_ai_group_sentient_count( "rooftops_encounter_b_main" );
					backup_count = get_ai_group_sentient_count( "rooftops_encounter_b_backup" );
		
					temp = array_combine( get_ai_group_ai( "rooftop_scene_actors" ), get_ai_group_ai( "rooftops_encounter_b_main" ) );
					front_line = array_combine( temp , get_ai_group_ai( "rooftops_encounter_b_backup" ) );
					maps\flood_util::reassign_goal_volume( front_line, "rooftops_encounter_b_ledge_vol" );
		
					wait( 5.0 );
					/*
					if( !aggresive )
					{
						aggresive = true;
					}
					*/
				}
				/*
				else
				{
					aggresive = false;
				}
				*/
			}
		}

		wait( 1.0 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_handle_turtling()
{
	self notify( "handle_turtling" );
	self endon( "handle_turtling" );


	self thread maps\flood_util::notify_on_flag_open( "rooftops_encounter_b_player_turtling", "handle_turtling" );

	wait( 10.0 );

	while( !flag( "rooftops_encounter_b_death" ) )
	{
		// need to determine if we need to send guys over
		flank_enemies = maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_flush_vol" );
		if( ROOFTOP_WATER_NUM_FLANKERS > flank_enemies.size )
		{
			// grab our guys from ledge first, then water area
			needed = ROOFTOP_WATER_NUM_FLANKERS - flank_enemies.size;
			flank_enemies = maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_catwalk_vol" );
			if( needed > flank_enemies.size )
			{
				flank_enemies = array_combine( flank_enemies, maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_ledge_vol" ) );
				if( needed > flank_enemies.size )
				{
					flank_enemies = array_combine( flank_enemies, maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_water_vol" ) );
					flank_enemies = get_array_of_farthest( level.player.origin, flank_enemies );
				}
				else
				{
					flank_enemies = get_array_of_closest( level.player.origin, flank_enemies );
				}
			}
			else
			{
				flank_enemies = get_array_of_closest( level.player.origin, flank_enemies );
			}
	
			// need to narrow it down to only the needed amount
			new_flankers = [];
			foreach( enemy in flank_enemies )
			{
				new_flankers = array_add( new_flankers, enemy );
				if ( needed <= new_flankers.size )
				{
					break;
				}
			}
	
			// make sure we got someone to send over
			if( 0 < new_flankers.size )
			{
				maps\flood_util::reassign_goal_volume( new_flankers, "rooftops_encounter_b_flush_vol" );
				array_thread( new_flankers, ::rooftops_encounter_b_waittill_flankers_dead, "rooftop_water_flanker_dead" );
				array_thread( new_flankers, ::set_grenadeammo, 1 );
				activate_trigger_with_targetname( "rooftops_encounter_b_vo_flank" );
				for( count = 0; count < new_flankers.size; count++ )
				{
					// if player moves up, we need to move these guys out of flank position
					level waittill( "rooftop_water_flanker_dead" );
				}
			}
			wait( 0.05 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_waittill_flankers_dead( msg )
{
	self waittill( "death" );
	level notify( msg );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_handle_defensive()
{
	self notify( "handle_defensive" );
	self endon( "handle_defensive" );


	self thread maps\flood_util::notify_on_flag_open( "rooftops_encounter_b_player_defensive", "handle_defensive" );

	while( !flag( "rooftops_encounter_b_death" ) )
	{
		// need to determine if we need to send guys over
		water_enemies = maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_water_vol" );
		if( ROOFTOP_WATER_LIMIT > water_enemies.size )
		{
			// grab our guys from ledge first
			needed = ROOFTOP_WATER_NUM_FLANKERS - water_enemies.size;
			water_enemies = maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_ledge_vol" );
			if( needed > water_enemies.size )
			{
				water_enemies = array_combine( water_enemies, maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_catwalk_vol" ) );
				if( needed > water_enemies.size )
				{
					water_enemies = array_combine( water_enemies, maps\flood_util::get_enemies_touching_volume( "rooftops_encounter_b_flush_vol" ) );
					water_enemies = get_array_of_farthest( level.player.origin, water_enemies );
				}
				else
				{
					water_enemies = get_array_of_closest( level.player.origin, water_enemies );
				}
			}
			else
			{
				water_enemies = get_array_of_closest( level.player.origin, water_enemies );
			}
	
			// need to narrow it down to only the needed amount
			new_water_enemies = [];
			foreach( enemy in water_enemies )
			{
				new_water_enemies = array_add( new_water_enemies, enemy );
				if ( needed <= new_water_enemies.size )
				{
					break;
				}
			}
	
			// make sure we got someone to send over
			if( 0 < new_water_enemies.size )
			{
				maps\flood_util::reassign_goal_volume( new_water_enemies, "rooftops_encounter_b_water_vol" );
			}
		}
		wait( 5.0 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_turret_logic()
{
	self endon( "encounter_b_done" );
	self thread maps\flood_util::notify_on_flag_set( "rooftops_encounter_b_death", "encounter_b_done" );
	
	default_goalradius = 512;
	trigger = GetEnt( "turret_safe_area", "script_noteworthy" );
	turret = GetEnt( "rooftops_turret", "targetname" );
	turret_node = GetNode( "turret_node", "targetname" );
	other_nodes = GetNodeArray( "gunner_secondary_nodes", "script_noteworthy" );

	turret SetDefaultDropPitch( 45.0 );

	self waittill( "fight" );

	while ( !flag( "rooftops_encounter_b_done" ) )
	{
		if ( flag( "rooftops_water_gunners_drop_down" ) )
		{
			break;
		}

		turret_operator = turret GetTurretOwner();
		if ( trigger IsTouching( level.player ) )
		{
			if ( IsDefined( turret_operator ) )
			{
				turret_operator StopUseTurret();
				maps\flood_util::reassign_goal_volume( turret_operator, "rooftops_encounter_b_gunner_vol" );

				other_nodes = array_randomize( other_nodes );
				foreach( node in other_nodes )
				{
					if( !IsNodeOccupied( node ) )
					{
						turret_operator SetGoalNode( node );
						turret_operator.suppressionwait = 0;
						turret_operator thread maps\flood_util::notify_on_actor_distance_to_goal( node.origin, 24, "reached_node" );

						msg = turret_operator waittill_any_timeout( 5, "reached_node", "death" );
						//turret_operator waittill( "goal" );
						if ( msg == "reached_node" )
						{
							turret_operator.goalradius		  = default_goalradius;
							turret_operator.ignoresuppression = false;
						}
						break;
					}
				}
			}
		}
		else
		{
			gunners = get_ai_group_ai( "turret_gunners" );
			if ( 0 != gunners.size && !IsDefined( turret_operator ) )
			{
				wait( 5.0 );
				if ( IsAlive( gunners[ 0 ] ) )
				{
					gunners[ 0 ] notify( "stop_going_to_node" );
					default_goalradius			  = gunners[ 0 ].goalradius;
					gunners[ 0 ].goalradius		  = level.magic_distance;	  // taken from _mgturret.gsc ln 37
					gunners[ 0 ].suppressionwait = 0;
					gunners[ 0 ].ignoresuppression = true;
					gunners[ 0 ]SetGoalNode( turret_node );
					gunners[ 0 ]thread rooftops_encounter_b_turret_ally_vo();
					gunners[ 0 ]waittill( "goal" );
					gunners[ 0 ]UseTurret( turret );
					//gunners[ 0 ]maps\flood_util::apply_deathtime		  ( RandomFloatRange( 10.0, 15.0 ) );
				}
			}
		}

		wait( 0.50 );
	}

	// currently this won't hurt anything, but i could leave this trigger to be cleaned up later when rooftops_encounter_b_cleanup_late gets cleaned up
	trigger Delete();

	gunners = get_ai_group_ai( "turret_gunners" );
	if( 0 < gunners.size )
	{
		foreach( enemy in gunners )
		{
			maps\flood_util::reassign_goal_volume( enemy, "rooftops_encounter_b_ledge_vol" );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_water_reveal_logic()
{
	self endon( "death" );

	waittillframeend;

	Assert( IsDefined( self.target ) );

	anim_org = getstruct( self.target, "targetname" );
	patrol_node = GetNode( self.target, "targetname" );

	if ( IsDefined( anim_org ) )
	{
		self disable_surprise();
		self waittill( "fight" );		// sent from end of animation
	}
	else if( IsDefined( patrol_node ) )
	{
		self.patrol_walk_anim = "active_patrolwalk_gundown";
		self thread maps\_patrol::patrol();
		self waittill( "enemy" );
		self notify( "stop_going_to_node" );
		level notify( "fight" );		// starts the turret logic
	}


	switch( self.target )
	{
		case "gunners_patrol_node":
			maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_b_gunner_vol" );
			break;

		case "catwalk_patrol_node":
			maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_b_catwalk_vol" );
			break;

		case "ledge_patrol_node":
			maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_b_ledge_vol" );
			break;

		case "flare_reveal":
			self.ragdoll_immediate = false;
			maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_b_catwalk_vol" );
			break;

		case "truck_reveal_a":
			temp_radius = self.goalradius;
			self.goalradius = 32;//level.magic_distance;
			self SetGoalNode( GetNode( "car_cover", "targetname" ) );
			self waittill( "goal" );
			self.goalradius = temp_radius;
			maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_b_water_vol" );
			break;

		case "rando":
			temp_radius = self.goalradius;
			self.goalradius = 32;//level.magic_distance;
			self SetGoalNode( GetNode( "water_front", "targetname" ) );
			self waittill( "goal" );
			self.goalradius = temp_radius;
			maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_b_water_vol" );

		default:
			maps\flood_util::reassign_goal_volume( self, "rooftops_encounter_b_ledge_vol" );

	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_ally_use_water_correctly()
{
	triggers = array_combine(
							 GetEntArray( "rooftops_encounter_b", "targetname" ),
							 GetEntArray( "rooftops_encounter_b_cleanup_push", "targetname" )
							 );
	triggers = array_add( triggers, GetEnt( "in_sight_of_rooftop_scene", "targetname" ) );
	array_thread( triggers, ::ally_crouch_walk_to_goal, self );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_force_clear()
{
	wait_for_targetname_trigger( "clear_rooftops_encounter_b" );

	for ( index = 0; index < 3; index++ )
	{
		spawners = GetEntArray( "rooftops_encounter_b_" + index + "_spawner", "targetname" );
		foreach( spawner in spawners )
		{
			spawner Delete();
		}
	}

	flag_set( "rooftops_water_heli_exit" );

	enemies = get_ai_group_ai( "rooftop_scene_actors" );
	foreach( enemy in enemies )
	{
		enemy Kill();
	}

	enemies = get_ai_group_ai( "rooftops_encounter_b_main" );
	foreach( enemy in enemies )
	{
		enemy Kill();
	}

	enemies = get_ai_group_ai( "rooftops_encounter_b_backup" );
	foreach( enemy in enemies )
	{
		enemy Kill();
	}

	enemies = get_ai_group_ai( "turret_gunners" );
	foreach( enemy in enemies )
	{
		enemy Kill();
	}

	flag_set( "rooftops_encounter_b_death" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_outro()
{
	level.allies[ 0 ] AllowedStances( "stand", "crouch", "prone" );
	trigger = GetEnt( "rooftops_encounter_b_vo_2", "targetname" );
	trigger activate_trigger();
	trigger delayCall( 0.1, ::Delete );
	move_forward_trigger = GetEnt( "rooftops_encounter_b_done", "targetname" );
	if ( IsDefined( move_forward_trigger ) )
	{
		move_forward_trigger activate_trigger();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

// hack so we do water fx when you jump down into the water
rooftops_water_splash()
{
	water_vol = GetEnt( "coverwater_rooftop_trigger", "targetname" );
	while( !level.player IsTouching( water_vol ) )
		waitframe();

	PlayFXOnTag( getfx( "waterline_under" ), level.cw_player_view_fx_source, "tag_origin" );
	thread maps\flood_coverwater::create_player_going_underwater_effects();
	
	wait 0.25;

	if( level.player GetStance() != "crouch" )
	{
		PlayFXOnTag( getfx( "waterline_above" ), level.cw_player_view_fx_source, "tag_origin" );
		thread maps\flood_coverwater::create_player_surfacing_effects();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//				DEBRIS BRIDGE SECTION								*
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_start()
{
	maps\flood_util::player_move_to_checkpoint_start( "debrisbridge_start" );
	maps\flood_util::spawn_allies();

	//set_audio_zone( "flood_rooftops", 2 );
	
	self thread maps\flood_util::setup_water_death();

	level.allies[ 0 ] set_force_color( "r" );
	level.allies[ 1 ] set_force_color( "p" );
	level.allies[ 2 ] set_force_color( "b" );

	level thread rooftop_water_to_debrisbridge_transition();
	flag_set( "rooftops_encounter_b_death" );
	flag_set( "rooftop_water_done" );

	activate_trigger_with_targetname( "debrisbridge_color_order_start" );

	// hide swept away moment water
	thread maps\flood_swept::swept_water_toggle( "swim", "hide" );
	//thread maps\flood_swept::swept_water_toggle( "noswim", "hide" );
	thread maps\flood_swept::swept_water_toggle( "debri_bridge", "show" );

}


debrisbridge()
{
	level thread autosave_by_name_silent( "debrisbridge_start" );
	level thread debrisbridge_encounter();
	
	// added by JKU  start the car and floater logic when you're on the other side because this logic also deals with the path connecting
	// for the destructible cars.
	thread maps\flood_garage::float_cars();

	flag_wait( "debrisbridge_done" );

	level thread rooftops_cleanup_post_debrisbridge();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_encounter()
{
	level.player thread debrisbridge_no_prone();

	self thread debrisbridge_ally_vo();
	self thread debrisbridge_path_logic();
	self thread debrisbridge_clear_enemies_bottom();
	self thread debrisbridge_clear_enemies_top();
	self thread debrisbridge_cleanup();

	wait_for_targetname_trigger( "debrisbridge_encounter_1_trigger" );

	level thread rooftops_cleanup_post_debrisbridge_dropdown();

	level.allies[ 1 ] set_force_color( "y" );
	level.allies[ 2 ] set_force_color( "b" );
	level.allies[ 0 ] set_grenadeammo( 0 );
	level.allies[ 1 ] set_grenadeammo( 0 );
	level.allies[ 2 ] set_grenadeammo( 0 );

	self thread debrisbridge_enemy_spawn_logic();
	// TODO need to find a better place to put this cleanup,
	maps\flood_util::cleanup_triggers( "rooftops_encounter_b_cleanup_late" );

	flag_wait( "debrisbridge_encounter_death" );

	maps\flood_util::cleanup_triggers( "debrisbridge_encounter" );

	debrisbridge_encounter_outro();

	autosave_by_name( "debrisbridge_done" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_enemy_spawn_logic()
{
	self thread debrisbridge_enemy_spawn_group_logic( "debrisbridge_enemies_top", 3, 7.0, "top" );
	self thread debrisbridge_enemy_spawn_group_logic( "debrisbridge_enemies_bottom", 2, 12, "bottom");
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_enemy_spawn_group_logic( ai_group, count, time, spawn_group )
{
	maps\flood_util::waittill_aigroup_count_or_timeout( ai_group, count, time );

	spawners = GetEntArray( "debrisbridge_encounter_1_" + spawn_group + "_spawner", "targetname" );
	array_thread( spawners, ::add_spawn_function, ::disable_long_death );
	array_thread( spawners, ::add_spawn_function, ::set_grenadeammo, 0 );
	array_thread( spawners, ::add_spawn_function, ::debrisbridge_enemy_aggrisive_logic );
	array_thread( spawners, ::spawn_ai, true );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_enemy_aggrisive_logic()
{
	self endon( "death" );

	flag_wait( "debrisbridge_LOS_blocked" );

	self.aggressivemode = true;
	self.health = 1;
	self.ignoresuppression = true;
	self.suppressionwait = 0;

	vol = GetEnt( "debrisbridge_aggresive_vol", "targetname" );
	trigger = GetEnt( "debrisbridge_enemy_aggresive", "targetname" );
	if ( self IsTouching( trigger ) )
	{
		self SetGoalVolumeAuto( vol );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_enemy_logic()
{
	Assert( IsDefined( self.script_aigroup ) );

	self magic_bullet_shield();

	if ( "debrisbridge_enemies_top" == self.script_aigroup )
	{
		wait_for_targetname_trigger( "debrisbridge_encounter_1_trigger" );
	}
	else if( "debrisbridge_enemies_bottom" == self.script_aigroup )
	{
		wait_for_targetname_trigger( "debrisbridge_allow_defensive_advantage" );
	}

	self stop_magic_bullet_shield();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_path_logic()
{
	flag_wait( "debrisbridge_ready" );

	trigger = GetEnt( "debrisbridge_stop_blocking", "targetname" );
	if ( IsDefined( trigger ) )
	{
		trigger activate_trigger();				// blockers are set up as expolders
		trigger Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_prevent_frogger( parent )
{
	level endon( "debrisbridge_ready" );

	// temp until linkto works with trigger_multiple ents
	self thread debrisbridge_move_trigger( parent );

	while ( !flag( "debrisbridge_ready" ) )
	{
		self waittill( "trigger", player );
		if( player == level.player )
		{
			player thread debrisbridge_slide_player( self );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_move_trigger( parent )
{
	level endon( "debrisbridge_ready" );

	while( true )
	{
		self.origin = parent.origin;
		self.angles = parent.angles;
		wait( 0.05 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_slide_player( trigger )
{
	if ( self IsSliding() || IsDefined( ( self.player_view ) ) )
	{
		return;
	}

	self endon( "death" );

	accel = undefined;
	if ( IsDefined( trigger.script_accel ) )
	{
		accel = trigger.script_accel;
	}

	self BeginSliding( undefined, accel );
	while ( self IsTouching( trigger ) )
	{
		wait( 0.05 );
	}

	if ( IsDefined( level.end_slide_delay ) )
	{
		wait( level.end_slide_delay );
	}

	self EndSliding();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_no_prone()
{
	self endon( "death" );

	wait_for_targetname_trigger( "debrisbridge_encounter_1_trigger" );

	if( self GetStance() == "prone" )
	{
		self SetStance( "crouch" );
	}
	self AllowProne( false );

	flag_wait( "debrisbridge_done" );

	self AllowProne( true );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_encounter_outro()
{
	//activate_trigger_with_targetname( "debrisbridge_encounter_vo_1" );
	//activate_trigger_with_targetname( "debrisbridge_encounter_done" );

	// enemy kill logic is turning a bunch of stuff back on for allies this frame.
	wait( 0.05 );
	maps\flood_anim::debris_bridge_allies_loop();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_clear_enemies_bottom()
{
	level waittill( "get_killed" );
	enemies = get_ai_group_ai( "debrisbridge_enemies_bottom" );
	foreach( enemy in enemies )
	{
		enemy thread debrisbridge_setup_enemies_for_clearance();
	}

	// notify happens at at specific moment
	level.allies[ 1 ] waittill( "kill_shot" );
	level.allies[ 0 ] thread debrisbridge_setup_ally_for_kill_shot( 0 );	// vargas
	wait( 1.05 );
	level.allies[ 2 ] thread debrisbridge_setup_ally_for_kill_shot( 2 );	// old boy

	//level.allies[ 2 ] waittill( "kill_shot" );
	//level.allies[ 2 ] thread debrisbridge_setup_ally_for_kill_shot( 1 );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_setup_enemies_for_clearance()
{
	self endon( "death" );

	self.ignoresuppression = true;
	wait( 2.0 );
	self.suppressionwait = 0;
	self.attackeraccuracy = 10000;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_setup_ally_for_kill_shot( ally_index )
{
	if( !flag( "debrisbridge_encounter_death" ) )
	{
		// setup for kill mode
		temp = self.suppressionwait;
		self.ignoreme = true;
		self.suppressionwait = 0;
		self.ignoresuppression = true;
		self.disableplayeradsloscheck = true;
		self.disableFriendlyFireReaction = true;
		self disable_ai_color();

		self SetGoalNode( GetNode( "debrisbridge_kill_shot_" + ally_index, "targetname" ) );

		flag_wait( "debrisbridge_encounter_death" );
		self.ignoreme = false;
		self.suppressionwait = temp;
		self.ignoresuppression = false;
		self.disableplayeradsloscheck = false;
		self.disableFriendlyFireReaction = undefined;
		//self enable_ai_color();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_clear_enemies_top()
{
	wait_for_targetname_trigger( "debrisbridge_encounter_vo_0" );

	for( index = 0; index < 4; index++ )
	{
		car = GetEnt( "debris_bridge_car_" + index, "script_noteworthy" );
		car thread debrisbridge_kill_enemies_top( index );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
#using_animtree( "destructibles" );
debrisbridge_kill_enemies_top( index )
{
	switch( index )
	{
		case 0:
			wait ( 26.0 );
			break;

		case 1:
			wait ( 26.6 );
			break;

		case 2:
			wait ( 13.0 );
			break;

		case 3:
			wait ( 17.6);
			break;

	}

	guys = get_ai_group_ai( "debrisbridge_enemies_top" );

	if( 0 < guys.size )
	{
		if ( IsDefined( self.exploded ) )
		{
			PlayFXOnTag( level._effect[ "secondary_explosion" ], self, "tag_death_fx" );
			self PlaySound( "car_explode" );
			//destructible_explode( 4000, 5000, 150, 250, 50, 300, undefined, undefined, 0.3, 500 );
			// -calls self RadiusDamage( damageLocation, range, maxdamage, mindamage, self, "MOD_RIFLE_BULLET" );
			// -calls Earthquake( earthQuakeScale, 2.0, damageLocation, earthQuakeRadius );
			if ( IsDefined( self.animsApplied ) )
			{
				foreach ( animation in self.animsApplied )
				{
					self clearanim( animation, 0 );
				}
			}
			self UseAnimTree(#animtree );
			self SetAnimKnobRestart( %vehicle_80s_sedan1_destroy, 1.0, 0.1, 1 );
			//car StopUseAnimTree();
		}
		else
		{
			self destructible_force_explosion();
		}
	}

	if( 1 == index )
	{
		wait( 0.20 );
		foreach ( guy in guys )
		{
			guy Kill( self.origin, level.player );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_cleanup()
{
	flag_wait( "debrisbridge_done" );

	foreach( ally in level.allies )
	{
		ally set_grenadeammo( 3 );
	}

	enemies = get_ai_group_ai( "debrisbridge_enemies_bottom" );
	foreach( enemy in enemies )
	{
		enemy Kill();
	}

	enemies = get_ai_group_ai( "debrisbridge_enemies_top" );
	foreach( enemy in enemies )
	{
		enemy Kill();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_wall_break_logic()
{
	// instead of waiting for notetracks...
	wait( 24.0 );

	start_node = GetNode( "debrisbridge_wall_node_0", "targetname" );
	foreach ( ally in level.allies )
	{
		if ( 32 > Distance( start_node.origin, ally.origin ) )
		{
			ally disable_ai_color();
			ally SetGoalNode( GetNode( "debrisbridge_wall_node_1", "targetname" ) );
			break;
		}
	}
	level.allies[ 1 ] thread debrisbridge_setup_ally_for_kill_shot( 1 );	// merrick

	wait( 2.0 );
	flag_set( "debrisbridge_LOS_blocked" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_crossing()
{
	diff = getDifficulty();

	if( !flag( "debrisbridge_done" ) )
	{
		if ( "fu" == diff )
		{
			set_player_attacker_accuracy( 0.50 );
		}
		if ( "hard" == diff )
		{
			set_player_attacker_accuracy( 0.25 );
		}
	}

	wait( 1.15 );
	spawner = GetEnt( "debrisbridge_fodder_0", "targetname" );
	if ( IsDefined( spawner ) )
	{
		spawner add_spawn_function( ::disable_long_death );
		spawner add_spawn_function( ::set_grenadeammo, 0 );
		level.debrisbridge_fodder = spawner spawn_ai( true );
	}
	if ( "fu" == diff || "hard" == diff )
	{
		wait ( 1.60 );
		spawner = GetEnt( "debrisbridge_fodder_1", "targetname" );
		if ( IsDefined( spawner ) )
		{
			spawner add_spawn_function( ::disable_long_death );
			spawner add_spawn_function( ::set_grenadeammo, 0 );
			level.debrisbridge_fodder_extra = spawner spawn_ai( true );
		}
	}

	flag_wait( "debrisbridge_done" );
	maps\_gameskill::updateAllDifficulty();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_combat_crossing( actor )
{
	if( !IsDefined( level.debrisbridge_fodder ) )
	{
		return;
	}

	if( !isDefined( level.debrisbridge_shot_count ) )
	{
		level.debrisbridge_shot_count = 0;
	}
	else
	{
		level.debrisbridge_shot_count++;
	}

	//iprintln( level.debrisbridge_shot_count );

	if( IsAlive( level.debrisbridge_fodder ) )
	{
		target = undefined;
		if ( 2 > level.debrisbridge_shot_count )
		{
			targets = make_array( "TAG_WEAPON_RIGHT", "TAG_WEAPON_LEFT", "TAG_REFLECTOR_ARM_RI", "TAG_REFLECTOR_ARM_LE", "TAG_WEAPON_CHEST" );
			target	= level.debrisbridge_fodder GetTagOrigin( targets[ RandomInt( targets.size ) ] );
		}
		else
		{
			target = level.debrisbridge_fodder GetEye();
		}

		switch ( getDifficulty() )
		{
			case "easy":
			case "medium":
			case "hard":
				MagicBullet( "ak12", actor GetTagOrigin( "tag_flash" ), target );
				break;

			case "fu":
				if ( 1 > level.debrisbridge_shot_count )
				{
					MagicBullet( "ak12", actor GetTagOrigin( "tag_flash" ), target );
					//Line( actor GetTagOrigin( "tag_flash" ), target, ( 0, 0, 50 ), 1.0, false, 50 );
				}
				else
				{
					MagicBullet( "ak12", actor GetTagOrigin( "tag_flash" ), target + ( 0, 0, 32 ) );
					//Line( actor GetTagOrigin( "tag_flash" ), target + ( 0, 0, 32 ), ( 0, 0, 50 ), 1.0, false, 50 );
				}
				break;

		}
		actor Shoot( 0.0, target );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//				COMMON / SHARED / BLEED OVER						*
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_to_rooftops_transition()
{
	level thread rooftops_encounters_logic();
	self thread rooftops_heli_logic();

	wait_for_targetname_trigger( "rooftops_color_order_start" );


	spawners = GetEntArray( "rooftops_encounter_a_0_spawner", "targetname" );
	array_thread( spawners, ::add_spawn_function, ::rooftops_encounter_a_enemy_logic );
	array_thread( spawners, ::add_spawn_function, ::rooftop_enemy_runner_logic );
	array_thread( spawners, ::add_spawn_function, ::disable_long_death );
	array_thread( spawners, ::add_spawn_function, ::set_grenadeammo, 0 );
	for( index = 0; index < spawners.size; index++ )
	{
		level.rooftops_runner[ index ] = spawners[ index ] spawn_ai();
	}
	thread battlechatter_off( "axis" );
	self thread rooftops_encounter_a_runners_vo();


	weapons = level.player GetWeaponsList( "primary" );
	if( 1 != weapons.size || "flood_knife" != weapons[ 0 ] )
	{
		weapons = GetEntArray( "derp_award", "targetname" );
		foreach( weapon in weapons )
		{
			weapon Delete();
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

suspend_actor_turnanims()
{
	self endon( "death" );

	trigger_wait_targetname( "rooftops_water_turn_hack_start" );
	self.noTurnAnims = true;
	trigger_wait_targetname( "rooftops_water_turn_hack_stop" );
	self.noTurnAnims = undefined;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_heli_logic()
{
	spawner = GetEnt( "rooftops_encounter_heli", "targetname" );

	// DK This is also being used by the TFF system so please check with Daryl before changing/removing
	flag_wait( "skybridge_heli_go" ); 

	level.rooftop_heli = maps\_vehicle::vehicle_spawn( spawner );
	level.rooftop_heli maps\_vehicle::GodOn();
	level.rooftop_heli thread maps\_vehicle::gopath();
	//level.rooftop_heli Vehicle_SetSpeed( 25 );
	level.rooftop_heli HidePart( "door_L", level.rooftop_heli.model );
	level.rooftop_heli HidePart( "door_L_handle", level.rooftop_heli.model );
	level.rooftop_heli HidePart( "door_L_lock", level.rooftop_heli.model );

	flag_set( "rooftops_heli_spawned" );
	thread maps\flood_audio::rooftops_mix_heli_down();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ally_crouch_walk_to_goal( ally )
{
	self endon( "death" );
	while ( true )
	{
		self waittill( "trigger" );
		ally thread actor_use_water_when_moving();
		while( self IsTouching( level.player ) )
		{
			wait( 0.1 );
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

actor_use_water_when_moving()
{
	self notify( "using_water" );
	self endon( "using_water" );

	level.rooftop_ally_temp = self.goalradius;
	self.goalradius = 32;
	self AllowedStances( "crouch" );
	self.ignoresuppression = true;
	self waittill( "goal" );

	self.goalradius = level.rooftop_ally_temp;
	self AllowedStances( "stand", "crouch", "prone" );
	self.ignoresuppression = false;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_enemy_combat_logic()
{
	self endon( "death" );
	self magic_bullet_shield();
	flag_wait( "rooftops_exterior_in_combat_space" );
	self stop_magic_bullet_shield();
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************


rooftops_enemy_aggresive_logic()
{
	self endon( "death" );

	self thread maps\flood_util::notify_on_enemy_count( 1, "last_man_standing" );
	self waittill( "last_man_standing" );

	self notify( "stop_goal_volume_updates" );		// stop update_goal_vol_from_trigger(); rooftop encounter specific
	self.aggressivemode = true;
	self.health = 1;

	self ClearGoalVolume();

	if( flag( "rooftop_water_done" ) )
	{
		// specific to debrisbridge section
		self.goalradius = 16;
		node = undefined;
		
		if ( 0 < get_ai_group_count( "debrisbridge_enemies_top" ) )
		{
			node = GetNode( "debrisbridge_get_killed_node", "targetname" );
		}
		else if( 0 < get_ai_group_count( "debrisbridge_enemies_bottom" ) )
		{
			node = GetNode( "debrisbridge_get_killed_node_bottom", "targetname" );
		}
		node.radius = 32;
		self SetGoalNode( node );
	}
	else
	{
		self.goalradius = 16;
		node = GetNode( "rooftops_encounter_a_final_stand", "targetname" );
		node.radius = 32;
		self SetGoalNode( node );
		self.ignoresuppression = true;
		self.suppressionwait = 0;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftop_water_to_debrisbridge_transition()
{
	// wait till previous encounter is finished
	flag_wait_any( "rooftops_encounter_b_death", "rooftop_water_done" );

	spawners = GetEntArray( "debrisbridge_encounter_0_top_spawner", "targetname" );
	spawners = array_combine( spawners, GetEntArray( "debrisbridge_encounter_0_bottom_spawner", "targetname" ) );
	array_thread( spawners, ::add_spawn_function, ::disable_long_death );
	array_thread( spawners, ::add_spawn_function, ::debrisbridge_enemy_aggrisive_logic );
	array_thread( spawners, ::add_spawn_function, ::set_grenadeammo, 0 );
	array_thread( spawners, ::add_spawn_function, ::debrisbridge_enemy_logic );
	array_thread( spawners, ::spawn_ai, true );


	// actor enter stage right...
	struct = getstruct( "debrisbridge_ally_1", "targetname" );
	level.allies[ 1 ] Teleport( struct.origin, struct.angles );
	level.allies[ 1 ] enable_ai_color();
	level.allies[ 1 ] set_force_color( "p" );
	level.allies[ 1 ].goalradius = 96;

	struct = getstruct( "debrisbridge_ally_2", "targetname" );
	level.allies[ 2 ] Teleport( struct.origin, struct.angles );
	level.allies[ 2 ] enable_ai_color();
	level.allies[ 2 ] set_force_color( "b" );
	level.allies[ 2 ].goalradius = 96;

	activate_trigger_with_targetname( "debrisbridge_new_allies" );

	level.allies[ 0 ] thread ally_rooftop_water_to_debrisbridge();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

ally_rooftop_water_to_debrisbridge()
{
	trigger = GetEnt( "debrisbridge_ally_logic_0_trigger", "targetname" );

	temp							 = self.suppressionwait;
	self.ignoreall					 = true;
	self.ignoresuppression			 = true;
	self.suppressionwait			 = 0;
	self.disableplayeradsloscheck	 = true;
	self.disableFriendlyFireReaction = true;

	while ( !self IsTouching( trigger ) )
	{
		wait( 1.0 );
	}

	self.ignoreall					 = false;
	self.ignoresuppression			 = false;
	self.suppressionwait			 = temp;
	self.disableplayeradsloscheck	 = false;
	self.disableFriendlyFireReaction = undefined;
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

temp_debrisbridge_remove_base_clip()
{/*
	for( index = 0; index < 2; index++ )
	{
		temp_clip = GetEnt( "debrisbridge_base_clip_" + index, "targetname" );
		if( IsDefined( temp_clip ) )
		{
			temp_clip Delete();
		}
	}
	*/
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_to_rooftops_water_transition()
{
	//level.allies[ 1 ] thread suspend_actor_turnanims();

	flag_wait( "rooftops_player_dropped_down" );
	level thread rooftops_water_enter_combat_space();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_shoot_around_actor( target, time, kill_target )
{
	Assert( IsDefined( target ) );

	self endon( "death" );

	if( !IsDefined( time ) )
	{
		time = 0.10;
	}
	if( !IsDefined( kill_target ) )
	{
		kill_target = false;
	}
	step = 0.10;

	while( 0.0 < time )
	{
		if( !IsAlive( target ) )
		{
			break;
		}

		if( ( 0 >= time - step ) && kill_target )
		{
			MagicBullet( "microtar", self GetTagOrigin( "TAG_FLASH" ), target GetEye() );
			self Shoot();
			if ( IsAlive( target ) )
			{
				target Kill();
			}
		}
		else
		{
			eye	  = target GetEye();
			dir	  = VectorNormalize( eye - self GetTagOrigin( "TAG_FLASH" ) );
			right = AnglesToRight( VectorToAngles( dir ) );

			shoot_right = 1;
			if ( RandomInt( 2 ) )
			{
				shoot_right = -1;
			}
			left_right_adjustment = ( shoot_right * right * RandomIntRange( 20, 32 ) );
			height_adjustment = ( 0, 0, RandomInt( 14 ) );
			MagicBullet( "microtar", self GetTagOrigin( "TAG_FLASH" ), eye + left_right_adjustment + height_adjustment );
			self Shoot();
			//Line( self GetTagOrigin( "TAG_FLASH" ), eye + left_right_adjustment + height_adjustment, ( 0, 0, 50 ), 1.0, false, 50 );
		}

		wait( 0.10 );
		time = time - step;
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
/*
rooftops_door_swing_logic( ent_handle )
{
	trigger = GetEnt( ent_handle, "targetname" );
	if( IsDefined( trigger ) )
	{
		trigger = GetEnt( ent_handle, "script_noteworthy" );
		AssertEx( IsDefined( trigger ), "Could not find entity with KVP." );
	}

	trigger waittill( "trigger", guy );
	
}
*/

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_cleanup_jumpto()
{
	waittillframeend;
	origin = GetEnt( "skybridge_start", "targetname" );
	origin Delete();
	origin = GetEnt( "rooftops_start", "targetname" );
	origin Delete();
	origin = GetEnt( "rooftop_water_start", "targetname" );
	origin Delete();
	origin = GetEnt( "debrisbridge_start", "targetname" );
	origin Delete();
	origin = GetEnt( "ending_start", "targetname" );
	origin Delete();
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_cleanup_post_skybridge()
{
	// jumpto fix. If jumping to rooftops checkpoint, heli is getting spawned earlier in the frame.
	waittillframeend;

	// heli spawner
	spawner = GetEnt( "rooftops_encounter_heli", "targetname" );
	spawner Delete();

	// volumes used to determine ally position
	vol = GetEnt( "ally_in_front_vol", "targetname" );
	vol Delete();

	// no prone trigger
	triggers = GetEntArray( "skybridge_noprone", "targetname" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_cleanup_post_wallkick()
{
	// weapons
	weapons = GetEntArray( "derp_award", "targetname" );
	foreach ( weapon in weapons )
	{
		weapon Delete();
	}
	for ( index = 0; index < 2; index++ )
	{
		weapons = GetEntArray( "rooftops_weapon_upgrade_" + index, "targetname" );
		foreach ( weapon in weapons )
		{
			weapon Delete();
		}
	}

	// spawners
	for ( index = 0; index < 3; index++ )
	{
		spawners = GetEntArray( "rooftops_encounter_a_" + index + "_spawner", "targetname" );
		foreach ( spawner in spawners )
		{
			spawner Delete();
		}
	}

	// volumess
	vol = GetEnt( "rooftop_runners_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_a_intro_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_a_flank_left_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_a_flank_right_vol", "targetname" );
	vol Delete();

	// triggers
	trigger = GetEnt( "trigger_water_death_0", "targetname" );
	trigger Delete();
	triggers = GetEntArray( "rooftops_misc_triggers", "script_noteworthy" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}

	// flags
	flags = GetEntArray( "rooftops_misc_flags", "targetname" );
	foreach ( flag in flags )
	{
		flag Delete();
	}

	// skybridge clip and models
	for ( index = 0; index < 3; index++ )
	{
		clip = GetEnt( "skybridge_clip_" + index, "targetname" );
		clip Delete();
		if ( IsDefined( level.skybridge_sections ) && IsDefined( level.skybridge_sections[ index ] ) )
		{
			level.skybridge_sections[ index ] Delete();
			level.skybridge_origins[ index ] Delete();
		}
	}
	clip = GetEnt( "skybridge_doorbreach_clip", "targetname" );
	clip Delete();

	// models
	// some parts of the parallel skybridge need to be cleaned up as well
	if( IsDefined( level.skybridge_door ) )
	{
		level.skybridge_door Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_cleanup_post_walkway()
{
	trigger = GetEnt( "trigger_water_death_1", "targetname" );
	trigger Delete();

	// wall kick animation stuff
	if( IsDefined( level.rooftop_outro_props ) )
	{
		foreach ( prop in level.rooftop_outro_props )
		{
			prop Delete();
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_cleanup_post_debrisbridge_dropdown()
{
	// turret
	//turret = GetEnt( "rooftops_turret", "targetname" );
	//turret Delete();
	
	// spawners
	for ( index = 0; index < 4; index++ )
	{
		spawners = GetEntArray( "rooftops_encounter_b_" + index + "_spawner", "targetname" );
		foreach ( spawner in spawners )
		{
			if( IsDefined( spawner ) )
			{
				spawner Delete();
			}
		}
	}

	// volumes
	vol = GetEnt( "rooftops_encounter_b_water_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_b_flush_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_b_catwalk_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_b_ledge_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_b_gunner_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "rooftops_encounter_b_safe_vol", "targetname" );
	vol Delete();

	// triggers
	triggers = GetEntArray( "rooftops_water_misc_triggers", "script_noteworthy" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}

	// flags
	flags = GetEntArray( "rooftops_water_heli_zone_flags", "targetname" );
	foreach ( flag in flags )
	{
		flag Delete();
	}
	flags = GetEntArray( "rooftops_water_player_zone_flags", "targetname" );
	foreach ( flag in flags )
	{
		flag Delete();
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_cleanup_post_debrisbridge()
{
	// enemies
	if( IsDefined( level.debrisbridge_fodder ) )
	{
		level.debrisbridge_fodder Delete();
	}
	if( IsDefined( level.debrisbridge_fodder_extra ) )
	{
		level.debrisbridge_fodder_extra Delete();
	}

	// weapons
	weapons = GetEntArray( "debrisbridge_weapons", "targetname" );
	foreach ( weapon in weapons )
	{
		weapon Delete();
	}

	// spawners
	for ( index = 0; index < 2; index++ )
	{
		spawners = GetEntArray( "debrisbridge_encounter_" + index + "_bottom_spawner", "targetname" );
		foreach ( spawner in spawners )
		{
			spawner Delete();
		}
		spawners = GetEntArray( "debrisbridge_encounter_" + index + "_top_spawner", "targetname" );
		foreach ( spawner in spawners )
		{
			spawner Delete();
		}
	}
	spawner = GetEnt( "debrisbridge_fodder_0", "targetname" );
	spawner Delete();
	spawner = GetEnt( "debrisbridge_fodder_1", "targetname" );
	spawner Delete();

	// volumes
	vol = GetEnt( "debrisbridge_encounter_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "debrisbridge_encounter_bottom_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "debrisbridge_crossing_vol", "targetname" );
	vol Delete();
	vol = GetEnt( "debrisbridge_aggresive_vol", "targetname" );
	vol Delete();

	// triggers
	trigger = GetEnt( "debrisbridge_enemy_aggresive", "targetname" );
	trigger Delete();
	trigger = GetEnt( "trigger_water_death_2", "targetname" );
	trigger Delete();
	trigger = GetEnt( "debrisbridge_noprone", "targetname" );
	trigger Delete();
	triggers = GetEntArray( "debrisbridge_misc_triggers", "script_noteworthy" );
	foreach ( trigger in triggers )
	{
		trigger Delete();
	}

	// debrisbridge clip
	clip = GetEnt( "debrisbridge_prop_14", "targetname" );
	clip Delete();
	clip = GetEnt( "debrisbridge_prop_15", "targetname" );
	clip Delete();
	clip = GetEnt( "debrisbridge_clip_all", "targetname" );
	clip Delete();

	// origins
	if ( IsDefined( level.debrisbridge_origins ) )
	{
		foreach ( origin in level.debrisbridge_origins )
		{
			origin Delete();
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//				VO													*
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_player_spotted_vo( trigger_handle )
{
	self endon( "death" );
	self.animname = "generic";

	self maps\flood_util::waittill_danger_or_trigger( trigger_handle );

	dialogue = make_array( "flood_vz12_getguns", "flood_vz2_americans", "flood_vz2_notalone", "flood_vz11_enemies" );
	self smart_dialogue( dialogue[ RandomInt( dialogue.size ) ] );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

trigger_vo_in_combat( trigger_handle, wait_time )
{
	if ( IsDefined( wait_time ) )
	{
		wait( wait_time );
	}

	activate_trigger_with_targetname( trigger_handle );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

skybridge_ally_vo()
{
	//wait_for_targetname_trigger( "skybridge_vo_0" );
	//wait_for_targetname_trigger( "skybridge_color_order_start" );		// this now gets triggered too early

	self thread smart_dialogue( "flood_diz_stabelground" );

	flag_wait( "skybridge_vo_1" );

	self thread smart_dialogue( "flood_diz_onlywaytogo" );
	//self handsignal( "moveup" );

	flag_wait_any( "skybridge_vo_2", "skybridge_vo_3" );

	if( !flag( "skybridge_vo_3" ) )
	{
		self thread smart_dialogue( "flood_diz_rightforus" );

		flag_wait_or_timeout( "skybridge_vo_3", 8.0 );

		vo_array = make_array( /*"flood_diz_barelyholding",*/ "flood_diz_keepmoving2", "flood_diz_rightforus", "flood_diz_hurry" );
		self thread maps\flood_util::play_nag( vo_array, "on_skybridge", 8, 30, 1, 1.5, "on_skybridge" );	
		flag_wait( "on_skybridge" );
		self notify( "on_skybridge" );
	}

	flag_wait( "skybridge_vo_3" );

	self thread smart_dialogue( "flood_diz_barelyholding" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_ally_vo()
{
	// ai_group just spawned in this frame
	waittillframeend;

	self thread rooftops_encounter_a_ally_vo_holdup();

	battlechatter_off( "allies" );

	// end of runner encounter
	wait_for_targetname_trigger( "rooftops_encounter_a_setup" );
	self thread rooftops_encounter_a_ally_vo_runners();


	// start off rooftop encounter
	wait_for_targetname_trigger( "rooftops_encounter_a_vo_1" );
	wait( 0.5 );
	flag_wait( "rooftops_exterior_ally_in_combat_space" );
	self smart_dialogue( "flood_diz_itshostile" );
	battlechatter_on( "allies" );

	// end of rooftop encounter
	flag_wait_all( "rooftops_encounter_a_death", "rooftop_runners_death" );
	battlechatter_off( "axis" );
	wait ( 0.75 );
	self smart_dialogue( "flood_diz_getsomebearings" );

	wait_for_targetname_trigger( "rooftops_exterior_ally_vo_0" );

	level thread radio_dialogue_queue( "flood_pri_thisghostzerooneif" );
	wait ( 4.3 );
	self thread smart_dialogue( "flood_vrg_thisisghostzerotwo" );
	wait ( 2.7 );
	thread radio_dialogue_queue( "flood_pri_vargaswereunderheavy" );
	wait ( 2.5 );
	flag_set( "rooftops_vo_kick_wall" );		// for the kick animation to start"
	wait ( 3.0 );
	flag_set( "rooftops_vo_check_drop" );
	wait ( 0.5 );
	self smart_dialogue( "flood_diz_gethimselfkilled" );

	wait ( 10.0 );

	// for player looking at 
	//Vargas: Keep moving.
	//Vargas: Let's go!
	vo_array = make_array( "flood_diz_keepmoving3", "flood_diz_gethimselfkilled" );
	level.allies[ 0 ] thread maps\flood_util::play_nag( vo_array, "player_drop_progress", 8, 30, 1, 1.5, "flag_set" );	
	flag_wait_any( "player_in_sight_of_ally", "rooftops_player_dropped_down", "rooftops_player_pushing" );
	flag_set( "player_drop_progress" );
	self notify( "flag_set" );
	flag_clear( "player_drop_progress" );
	
	// for player to follow ally down the ledge
	wait( 5.0 );
	//Vargas: Elias drop down.
	vo_array = make_array( "flood_diz_dropdown" );
	level.allies[ 0 ] thread maps\flood_util::play_nag( vo_array, "rooftops_vo_push_forward_hassle", 15, 30, 1, 2, "flag_set" );
	flag_wait( "rooftops_vo_push_forward_hassle" );
	self notify( "flag_set" );
	flag_clear( "rooftops_vo_push_forward_hassle" );

	// directive for where to go
	flag_wait( "rooftops_encounter_a_vo_2" );
	//self smart_dialogue( "flood_diz_ahelipad" );
	
	// for player to jump across exposed building section
	wait( 5.0 );
	//Vargas: Jump the gap.
	vo_array = make_array( "flood_diz_jumpthegap" );
	level.allies[ 0 ] thread maps\flood_util::play_nag( vo_array, "rooftops_vo_push_forward_nag1", 15, 30, 1, 2, "flag_set" );
	flag_wait( "rooftops_vo_push_forward_nag1" );
	self notify( "flag_set" );
	flag_clear( "rooftops_vo_push_forward_nag1" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
// the player used to be able to reach this trigger before the ally
rooftops_encounter_a_ally_vo_holdup()
{
	self endon( "spotted" );

	trigger = GetEnt( "ally_handsignal", "targetname" );
	trigger waittill( "trigger", guy );

	if ( guy == self )
	{
		self thread maps\flood_anim::rooftops_ally_holdup();
	}

	flag_wait( "skybridge_done" );

	weapons = level.player GetWeaponsList( "primary" );
	if( 1 >= weapons.size && "flood_knife" == weapons[ 0 ] )
	{
		self smart_dialogue( "flood_diz_hostileahead" );
	}
	else
	{
		wait( 0.8 );
		self smart_dialogue( "flood_diz_holdup" );
	}
	self smart_dialogue( "flood_diz_gohotmark" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_ally_vo_runners()
{
	wait( 0.75 );
	if( 0 < get_ai_group_count( "rooftop_runners" ) )
	{
		if ( 0 >= maps\flood_util::get_enemies_touching_volume( "rooftop_runners_vol" ).size )
		{
			self smart_dialogue( "flood_diz_onesgettin" );
			self smart_dialogue( "flood_diz_upthestairs2" );
		}
	}
	else
	{
		self smart_dialogue( "flood_diz_haveabird" );
		self smart_dialogue( "flood_diz_moveslowly" );
		//thread add_dialogue_line( "Ally_1", "Sounds like a chopper is on the roof, could be hostile.", "green" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_runners_vo()
{
	// guys just spawned in this frame
	waittillframeend;

	runners = get_ai_group_ai( "rooftop_runners" );
	if( runners[0].target == "rooftop_runner_computer" )
	{
		computer_guy = runners[ 0 ];
		it_support	 = runners[ 1 ];
	}
	else
	{
		computer_guy = runners[ 1 ];
		it_support	 = runners[ 0 ];
	}
	computer_guy thread maps\flood_util::stop_enemy_dialogue();
	it_support thread maps\flood_util::stop_enemy_dialogue();

	it_support endon( "enemy_near" );		// notify in rooftop_enemy_runner_logic

	computer_guy.animname = "generic";
	it_support.animname = "generic";

	computer_guy thread rooftops_encounter_a_runners_escape_vo();
	it_support smart_dialogue( "flood_vs10_hearme" );
	it_support thread rooftops_encounter_a_runners_escape_vo();
	computer_guy smart_dialogue( "flood_vz11_downloaddata" );
	computer_guy thread rooftops_encounter_a_runners_escape_vo();
	it_support smart_dialogue( "flood_vs10_priorityalert" );
	it_support thread rooftops_encounter_a_runners_escape_vo();
	computer_guy smart_dialogue( "flood_vs11_rewire" );
	computer_guy thread rooftops_encounter_a_runners_escape_vo();
	it_support smart_dialogue( "flood_vs10_setupfine" );
	it_support thread rooftops_encounter_a_runners_escape_vo();
	computer_guy smart_dialogue( "flood_vz11_goargue" );
	/*
	computer_guy thread rooftops_encounter_a_runners_escape_vo();
	it_support smart_dialogue( "flood_vs10_beenflooded" );
	it_support thread rooftops_encounter_a_runners_escape_vo();
	computer_guy smart_dialogue( "flood_vz11_accept" );
	computer_guy thread rooftops_encounter_a_runners_escape_vo();
	it_support smart_dialogue( "flood_vz10_digital" );
	it_support thread rooftops_encounter_a_runners_escape_vo();
	computer_guy smart_dialogue( "flood_vz11_secureenough" );

	wait( 2.0 );
	*/

	// trigger encounter
	flag_set( "rooftops_vo_interrior_done" );
	flag_set( "rooftops_interior_encounter_start" );
	it_support notify( "enemy_near" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_a_runners_escape_vo()
{
	level notify( "runners_escape" );
	level endon( "runners_escape" );
	self endon( "death" );
	self waittill( "enemy_near", triggered );

	// cut off any previous dialogue
	self anim_stopanimscripted();

	if( IsAlive( self ) )
	{
		callouts = make_array( "flood_vz11_enemies", "flood_vz2_americans" );
		self smart_dialogue( callouts[ RandomInt( callouts.size ) ] );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_ally_vo()
{
	self thread maps\flood_util::notify_on_flag_set( "rooftops_encounter_b_death", "early_out" );
	self endon( "early_out" );

	battlechatter_off( "allies" );

	self thread rooftops_encounter_b_ally_end_vo();

	//self anim_stopanimscripted();
	//wait_for_targetname_trigger( "rooftops_encounter_b_vo_0" );

	wait_for_targetname_trigger( "in_sight_of_rooftop_scene_ally" );
	//self smart_dialogue( "flood_diz_getready" );
	//add_dialogue_line( "Ally_1", "Oh sh.... Tangos! Get down here Rook", "green" );

	wait( 2.0 );
	
	// urgent but stealthy
	if( !flag( "rooftops_vo_push_forward_hassle" ) )
	{
		//Vargas: Elias, down here!
		vo_array = make_array( "flood_vrg_downhereelias" );
		level.allies[ 0 ] thread maps\flood_util::play_nag( vo_array, "player_drop_progress", 15, 30, 1, 2, "flag_set" );
	}
	
	flag_wait_any( "rooftops_vo_push_forward_hassle", "rooftops_water_encounter_start" );
	flag_set( "player_drop_progress" );
	self notify( "flag_set" );

	wait( 2.0 );
	
	// urgent
	//Vargas: Elias, get down here! I need support!
	vo_array = make_array( "flood_diz_getdownhereneedsupport" );
	level.allies[ 0 ] thread maps\flood_util::play_nag( vo_array, "rooftops_vo_push_forward_hassle", 15, 30, 1, 2, "flag_set" );
	flag_wait( "rooftops_vo_push_forward_hassle" );
	self notify( "flag_set" );
	battlechatter_on( "allies" );

	self thread rooftops_encounter_b_water_vo();
	self thread rooftops_encounter_b_flank_vo();
	
	wait( 1.0 );
	
	flag_clear( "rooftops_vo_push_forward_hassle" );

	/*
	wait_for_targetname_trigger( "rooftops_encounter_b_vo_1" );

	flag_set( "dont_interupt_vo" );
	self anim_stopanimscripted();
	radio_dialogue_queue( "flood_kgn_westofrv" );
	self smart_dialogue( "flood_diz_youmadeit" );
	radio_dialogue_queue( "flood_kgn_getsomesupport" );
	wait( 0.75 );
	self smart_dialogue( "flood_diz_whatwecando" );
	flag_clear( "dont_interupt_vo" );
	*/
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_ally_end_vo()
{
	endon_trigger = GetEnt( "clear_rooftops_encounter_b", "targetname" );
	endon_trigger endon( "trigger" );

	wait_for_targetname_trigger( "rooftops_encounter_b_vo_2" );
	battlechatter_off( "allies" );
	trigger = GetEnt( "rooftops_encounter_b_vo_3", "targetname" );
	if( IsDefined( trigger ) )
	{
		wait( 0.75 );
		//Vargas: Let's go!
		vo_array = make_array( "flood_diz_gethimselfkilled" );
		level.allies[ 0 ] thread maps\flood_util::play_nag( vo_array, "rooftops_vo_push_forward_hassle", 15, 30, 1, 2, "flag_set" );
	}

	flag_wait( "rooftops_vo_push_forward_hassle" );
	self notify( "flag_set" );
	
	trigger = GetEnt( "rooftops_encounter_b_vo_3", "targetname" );
	if( IsDefined( trigger ) )
	{
		self smart_dialogue( "flood_diz_cominginfromabove" );
	}

	trigger = GetEnt( "rooftops_encounter_b_vo_3", "targetname" );
	if( IsDefined( trigger ) )
	{
		trigger waittill( "trigger" );
	}
	trigger = GetEnt( "clear_rooftops_encounter_b", "targetname" );
	if( IsDefined( trigger ) )
	{
		flag_wait( "rooftops_water_vo_fromabove" );
		self smart_dialogue( "flood_diz_infromabove" );
	}
	battlechatter_on( "allies" );
	
	flag_clear( "rooftops_vo_push_forward_hassle" );
	
	wait( 3.0 );

	// for when the ally doesn't jump down into the debris bridge encounter
	//Price: Elias, drop down here!
	//Vargas: Get down here, Elias!
	//Merrick: Elias, we need support down here!
	vo_array = make_array( "flood_bkr_dropdownhere" );
	level.allies[ 0 ] thread maps\flood_util::play_nag( vo_array, "rooftops_vo_push_forward_nag1", 30, 30, 1, 1, "flag_set" );
	
	wait( 10.0 );
	vo_array = make_array( "flood_diz_getdownhere");
	level.allies[ 1 ] thread maps\flood_util::play_nag( vo_array, "rooftops_vo_push_forward_nag1", 30, 30, 1, 1, "flag_set" );
	
	wait( 10.0 );
	vo_array = make_array( "flood_kgn_needsupport" );
	level.allies[ 2 ] thread maps\flood_util::play_nag( vo_array, "rooftops_vo_push_forward_nag1", 30, 30, 1, 1, "flag_set" );
	
	flag_wait( "rooftops_vo_push_forward_nag1" );
	
	level.allies[ 0 ] notify( "flag_set" );
	level.allies[ 1 ] notify( "flag_set" );
	level.allies[ 2 ] notify( "flag_set" );
	
	wait( 1.0 );
	
	flag_clear( "rooftops_vo_push_forward_nag1" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_turret_ally_vo()
{
	self notify( "turret_vo" );
	self endon( "turret_vo" );
	self endon( "death" );

	hassle_dialogue = make_array( "flood_diz_watchoutforturret", "flood_diz_mgontheroof", "flood_diz_turretuphigh" );

	flag_wait( "rooftops_water_encounter_start" );

	timer_array = maps\flood_util::wait_incremental_nag_timer();

	while ( IsAlive( self ) )
	{
		flag_waitopen( "dont_interupt_vo" );
		level.allies[ 1 ] dialogue_queue( hassle_dialogue[ RandomInt( hassle_dialogue.size ) ] );
		timer_array = maps\flood_util::wait_incremental_nag_timer( timer_array );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_water_vo()
{
	self endon( "death" );
	level endon( "cw_player_underwater" );

	//Vargas: Use the water for cover.
	hassle_dialogue = make_array( "flood_diz_usethewater" );
	hurt			= false;
	count			= 0;

	while ( !flag( "rooftops_encounter_b_done" ) && 3 > count )
	{
		if ( !hurt && 0.50 > ( level.player.health / level.player.maxhealth ) )
		{
			if( flag( "cw_player_in_water" ) )
			{
				flag_waitopen( "dont_interupt_vo" );
				self dialogue_queue( hassle_dialogue[ RandomInt( hassle_dialogue.size ) ] );
				hurt = true;
				count++;
			}
			wait( 10.0 );
		}
		if ( hurt && level.player.health == level.player.maxhealth )
		{
			hurt = false;
		}
		wait( 0.50 );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_flank_vo()
{
	level endon( "rooftops_encounter_b_done" );

	while ( true )
	{
		wait_for_targetname_trigger( "rooftops_encounter_b_vo_flank" );
		flag_waitopen( "dont_interupt_vo" );
		self smart_dialogue( "flood_diz_flankingus" );
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

rooftops_encounter_b_enemy_vo()
{
	flag_wait( "rooftops_water_encounter_start" );
	battlechatter_on( "axis" );
	wait( 0.75 );

	enemies = get_ai_group_ai( "rooftop_scene_actors" );
	foreach( enemy in enemies )
	{
		if( IsAlive( enemy ) )
		{
			enemy.animname = "generic";
			enemy smart_dialogue( "flood_vz12_getguns" );
			break;
		}
	}
}


//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

debrisbridge_ally_vo()
{
	wait_for_targetname_trigger( "debrisbridge_encounter_vo_0" );

	level.allies[ 1 ] smart_dialogue( "flood_vrg_gladtoseeyou" );
	level.allies[ 0 ] smart_dialogue( "flood_pri_vargasstartlayingdown" );
	level.allies[ 0 ] smart_dialogue( "flood_pri_garciawasspottedheading" );

	wait ( 8.0 );
	level notify( "get_killed" );
	wait( 4.0 );
	level.allies[ 1 ] notify( "kill_shot" );
	wait ( 2.1 );
	
	level.allies[ 1 ] smart_dialogue( "flood_vrg_sowhatthehell" );
	level.allies[ 0 ] smart_dialogue( "flood_pri_weneedtofind" );
	level.allies[ 0 ] smart_dialogue( "flood_vrg_merrickeliasfollowmy" );


	flag_wait( "debrisbridge_vo_1" );

	/*
	if( !flag( "debrisbridge_done" ) )
	{
		level.allies[ 1 ] smart_dialogue( "flood_diz_watchyourfooting" );
		wait( 0.75 );
	}
	if( !flag( "debrisbridge_done" ) )
	{
		level.allies[ 2 ] smart_dialogue( "flood_kgn_barelystaying" );
	}
	*/

	wait( 15.0 );
	
	//Price: Elias, you've got to get across now!
	vo_array = make_array( "flood_diz_getacrossnow" );
	level.allies[ 2 ] thread maps\flood_util::play_nag( vo_array, "debrisbridge_done", 15, 30, 1, 2, "flag_set" );
	
	flag_wait( "debrisbridge_done" );
	level.allies[ 2 ] notify( "flag_set" );
}


//*******************************************************************
//                                                                  *
//                                                                  *
//				DEBUG												*
//                                                                  *
//                                                                  *
//*******************************************************************

//addNotetrack_dialogue
//script_moveoverride
//ignore_triggers( time )
foo()
{
	while( true )
	{
		//level.player ShellShock( "flood_bridge_stumble", 0.60 );
		wait( 0.05 );
		//wait( 5.00 );
	}
}

debug_kill_enemies_in_order( wait_time )
{
	self notifyonplayercommand( "debug_kill", "+usereload" );
	self waittill( "debug_kill" );

	for( index = 0; index < 2; index++ )
	{
		actors = GetEntArray( "debug_kill_group_" + index, "script_noteworthy" );
		foreach( actor in actors )
		{
			actor Kill();
		}
		wait ( wait_time );
	}
}

wtf_is_it( ent )
{
	while( true )
	{
		eye = level.player GetEye();
		Line( eye, ent.origin, ( 0, 0, 50 ), 1.0, false, 50 );
		wait( 1.0 );
	}
}

debug_countdown_timer( time, msg )
{
	level endon( "stop_timer" );
	
	while( 0 < time )
	{
		//IPrintLn( time );
		time = time - 0.05;
		wait( 0.05 );
	}

	if( IsDefined( msg ) )
	{
		//IPrintLn( msg );
	}
}

//*******************************************************************
//                                                                  *
//                                                                  *
//				DEPRECATED											*
//                                                                  *
//                                                                  *
//*******************************************************************
/*
*/