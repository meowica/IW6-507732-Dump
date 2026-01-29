#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_helicopter_spotlight;


///////////////////////////////////////////////////////

start()
{
	level.player maps\factory_util::move_player_to_start_point( "playerstart_rooftop" );
	
	maps\factory_util::actor_teleport( level.squad[ "ALLY_ALPHA" ]	, "rooftop_start_alpha" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_BRAVO" ]	, "rooftop_start_bravo" );
	maps\factory_util::actor_teleport( level.squad[ "ALLY_CHARLIE" ], "rooftop_start_charlie" );
	
	flag_set ( "ambush_escape_clear" );
	flag_set ( "spawn_loading_dock_vehicles" );
	thread rooftop_heli();
		
	maps\factory_util::safe_trigger_by_targetname( "ambush_escape_allies_rooftop" );
	thread maps\factory_fx::rooftop_wind_gusts();

	// thread maps\factory_util::make_it_rain( "rain_heavy_mist", "car_chase_complete" );

	thread rooftop_door_breach();
	thread maps\_weather::rainLight ( 1 );
	
	thread maps\factory_chase::chase_ally_vehicle_setup();
	
	// Deletes script models
	thread maps\factory_powerstealth::train_cleanup();
}

main()
{
	
	// thread rooftop_enemy_waves();
	thread rooftop_fan_spin();
	// thread rooftop_pipes_cleanup();
	
	autosave_by_name( "rooftop" );
	
	foreach ( guy in level.squad )
	{
		guy.no_pistol_switch = true;	
	}
	
	thread rooftop_win();
	
	level waittill ( "rooftop_door_kicked" );
		
	thread rooftop_enemy_cleanup();
	thread rooftop_ally_movement_setup();
	thread rooftop_enemy_retreating();
	thread maps\factory_chase::car_chase_intro_car_crash_setup();
	thread rooftop_staircase_threatbias();
	
	level.squad[ "ALLY_ALPHA"	]enable_ai_color(  );
	level.squad[ "ALLY_BRAVO"	]enable_ai_color(  );
	level.squad[ "ALLY_CHARLIE" ]enable_ai_color(  );
	
	level waittill ( "rooftop_enemies_cleared" );
}

section_precache()
{
	
}

section_flag_init()
{
	flag_init ( "rooftop_complete" );
	flag_init ( "player_jumping" );
	flag_init ( "rooftop_heli_unloaded" );
	flag_init ( "rooftop_heli_okay_to_depart" );
	flag_init ( "rooftop_breach_alpha_in_position" );
	flag_init ( "rooftop_breach_charlie_in_position" );
	// flag_init ( "spotlight_thermal_hint" );
}

rooftop_fan_spin()
{
	level endon ( "rooftop_complete" );
	fan = GetEnt ( "rooftop_fan", "targetname" );
	while ( 1 )
	{
		fan RotatePitch ( 360, 10 );
		wait 10;
	}
}

rooftop_pipes_cleanup()
{
	flag_wait ( "player_off_roof" ); 
	pipes = getentarray( "pipe_shootable", "targetname" );
	foreach( pipe in pipes )
	{
		if( isDefined( pipe ) )
		{
			pipe delete();
		}
	}
}

rooftop_enemy_waves()
{
	
	flag_wait ( "player_near_rooftop_door" );
	
	thread rooftop_enemy_surprised();
	
	rooftop_enemy_wave_1();
	thread rooftop_enemy_wave_2_upper();
	thread rooftop_enemy_wave_2_lower();
	thread rooftop_parking_lot_enemies();
	waittillframeend;
	rooftop_enemies_wait_to_attack();
	rooftop_last_guys_rush();
	
	level.player.threatbias = 0;
}

// CF - TESTING OUT SOME FEET SPLASHING STUFF
// Deprecated, this stuff should be handled by materials and footsteps.
/*
rooftops_splash_on_enemies()
{
	wait 1;
	guys = GetAIArray( "axis" );
	foreach ( guy in guys )
	{
		guy thread maps\factory_fx::splash_on_actor ( undefined, "player_in_loading_dock" );
	}
	
}
*/
rooftop_enemy_wave_1()
{
	enemy_spawners_wave_1	= GetEntArray ( "rooftop_enemy_spawner_wave_1", "targetname" );
	foreach ( spawner in enemy_spawners_wave_1 )
	{
		spawner spawn_ai( true );
	}
	// CF - TESTING OUT SOME FEET SPLASHING STUFF
	// Deprecated, this stuff should be handled by materials and footsteps.
	// thread rooftops_splash_on_enemies();
}

rooftop_enemy_wave_2_upper()
{
	level endon ( "player_went_lower_path" );
	trigger_wait_targetname ( "rooftop_upper_wave_2_trigger" );
	level notify ( "player_went_upper_path" );
	trigger = GetEnt ( "rooftop_wave_2_trigger", "targetname" );
	trigger trigger_off();
	// CF - TESTING OUT SOME FEET SPLASHING STUFF
	// Deprecated, this stuff should be handled by materials and footsteps.
	// thread rooftops_splash_on_enemies();
	
}

rooftop_enemy_wave_2_lower()
{
	level endon ( "player_went_upper_path" );
	trigger_wait_targetname ( "rooftop_wave_2_trigger" );
	level notify ( "player_went_lower_path" );
	trigger = GetEnt ( "rooftop_upper_wave_2_trigger", "targetname" );
	trigger trigger_off();
	trigger = GetEnt ( "rooftop_enemy_fan_spawner_trigger", "targetname" );
	trigger trigger_off();
	// CF - TESTING OUT SOME FEET SPLASHING STUFF
	// thread rooftops_splash_on_enemies();
}

rooftop_parking_lot_enemies()
{
	level waittill ( "rooftop_enemies_cleared" );
	thread maps\factory_parking_lot::parking_lot_blockade_vehicle_1( "blockade_vehicle_1" );
	
	spawners = GetEntArray ( "parking_lot_wave_1", "targetname" );
	maps\_spawner::flood_spawner_scripted( spawners );
	// CF - TESTING OUT SOME FEET SPLASHING STUFF
	// thread rooftops_splash_on_enemies();
	level waittill ( "here_comes_the_truck");
	foreach ( spawner in spawners )
	{
		spawner notify( "stop current floodspawner" );
	}
}

rooftop_enemies_wait_to_attack()
{
	guys = GetAIArray( "axis" );
	foreach ( guy in guys )
	{
		guy.dontevershoot = true;	
	}
	level waittill ( "rooftop_door_kicked" );
	wait 1;
	foreach ( guy in guys )
	{
		guy.dontevershoot = undefined;	
	}
	
}

rooftop_last_guys_rush()
{
	while ( 1 )
	{
		guys = get_living_ai_array ( "rooftop_enemy", "script_noteworthy" );
		// Note the fastropers should always keep this number from dropping below the threshold too early
		if ( guys.size <= 2 )
		{
			// guys = get_living_ai_array ( "rooftop_enemy", "script_noteworthy" );
			foreach ( guy in guys )
			{
				guy maps\factory_util::playerseek();
			}
			maps\factory_util::safe_trigger_by_targetname( "rooftop_r_ally_move_410" );
			maps\factory_util::safe_trigger_by_targetname( "p_b_ally_move_600" );
			level notify ( "rooftop_enemies_cleared" );
			break;
		}
	wait 0.25;
	}
}

rooftop_enemy_retreating()
{
	trigger_wait_targetname ( "rooftop_ally_move_406" );
	volume = GetEnt ( "rooftop_section_1", "targetname" );
	BadPlace_Brush( "rooftop_section_1", -1, volume, "axis" );
	
	trigger_wait_targetname ( "rooftop_ally_move_408" );
	volume = GetEnt ( "rooftop_section_2", "targetname" );
	BadPlace_Brush( "rooftop_section_2", -1, volume, "axis" );
	
	level waittill ( "rooftop_complete" );
	
	BadPlace_Delete ( "rooftop_section_1" );
	BadPlace_Delete ( "rooftop_section_2" );
	
}

rooftop_enemy_door_kicker()
{
	wait 2;
	guy					 = spawn_targetname ( "rooftop_enemy_spawner_door_kicker" );
	guy.ignoreme		 = true;
	guy.attackeraccuracy = 100;
	guy.health = 1;
	guy.animname		 = "enemy";
	node				 = GetEnt ( "door_kicker_node", "targetname" );	
	node thread anim_single_run_solo ( guy, "rooftop_enemy_door_kick" );
	thread maps\factory_audio::sfx_kicking_door_sound();
	wait 2.1;
	blocker = GetEnt ( "rooftop_enemy_door_blocker", "targetname" );
	blocker ConnectPaths();
	blocker NotSolid();
	thread rooftop_ally_doorway_blocker();
	enemy_door = GetEnt ( "rooftop_enemy_door", "targetname" );
	enemy_door RotateTo ( ( enemy_door.angles - ( 0, 175, 0 ) ), .3, 0, 0.1 );
	guy.ignoreme								= false;
	level.squad[ "ALLY_CHARLIE" ].favoriteenemy = guy;
	wait 0.3;
	enemy_door RotateTo ( ( enemy_door.angles + ( 0, 20, 0 ) ), .7, 0, 0.1 );
}

rooftop_staircase_threatbias()
{
	level endon ( "rooftop_complete");
	CreateThreatBiasGroup ( "squad" );
	trigger_wait_targetname ( "rooftop_stair_flank_trigger" );
	level.player.threatbias = -2000;
	
	foreach ( guy in level.squad)
	{
		guy SetThreatBiasGroup ( "squad" );
	}
	
	SetThreatBias ( "axis", "squad", 1500);
}

rooftop_ally_movement_setup()
{
	level endon ( "rooftop_enemies_cleared");
	thread allies_jump_off_roof();
	foreach ( guy in level.squad )
	{
		guy.fixednodesaferadius = 128;
		guy.suppressionwait		= 4200;
	}
	rooftop_ally_movement ( "rooftop_section_1", "rooftop_ally_move_404" );
	wait 2;
	rooftop_ally_movement ( "rooftop_section_2", "rooftop_ally_move_406" );
	// this is problematic when allies advance far on the bottom before the player advances on the top.
	wave_2_spawn_trigger = GetEnt ( "rooftop_wave_2_trigger", "targetname" );
	flag_set ( "factory_rooftop_wind_gust_moment" );
	maps\factory_util::safe_trigger_by_targetname( "rooftop_wave_2_trigger" );
	wait 2;
	rooftop_ally_movement ( "rooftop_section_3", "rooftop_ally_move_408" );
	flag_wait ( "rooftop_heli_unloaded" );
	rooftop_ally_movement ( "rooftop_section_4", "rooftop_ally_move_409" );
	wait 1;
	rooftop_ally_movement ( "rooftop_section_5", "rooftop_ally_move_410" );
	wait 1;
	rooftop_ally_movement ( "rooftop_section_6", "p_b_ally_move_600" );
	maps\factory_util::safe_trigger_by_targetname( "rooftop_r_ally_move_411" );
	flag_set ( "rooftop_heli_okay_to_depart" );
	flag_set ( "factory_rooftop_wind_gust_moment" );
	level notify ( "rooftop_enemies_cleared" );

}

rooftop_ally_doorway_blocker()
{
	trigger_wait_targetname	 ( "doorway_block_trigger" );
	level.squad[ "ALLY_BRAVO" ].ignoreall = true;
	level.squad[ "ALLY_BRAVO" ] ClearEnemy();
	blocker = GetEnt ( "rooftop_enemy_door_blocker", "targetname" );
	blocker Solid();
	blocker DisconnectPaths();
	wait 2;
	level.squad[ "ALLY_BRAVO" ].ignoreall = false;
}

allies_jump_off_roof()
{
	level waittill ( "rooftop_enemies_cleared" );

	level.squad[ "ALLY_ALPHA"	]thread ally_vignette_traversal( "ally_alpha_jump_node"	 , "factory_rooftop_jumpoff_ally01");
	level.squad[ "ALLY_CHARLIE" ]thread ally_vignette_traversal( "ally_charlie_jump_node", "factory_rooftop_jumpoff_ally03");
	maps\factory_util::safe_trigger_by_targetname( "rooftop_r_ally_move_411" );
	
	// If the player has found a nice spot to camp on the rooftop, and chooses to sit there, we're still going to blow up the factory. 
	wait_for_flag_or_timeout ( "player_near_rooftop_end", 30 );
	
	flag_set ( "rooftop_heli_okay_to_depart" );
	
	level.squad[ "ALLY_BRAVO" ] ally_vignette_traversal( "ally_bravo_jump_node", "factory_rooftop_jumpoff_ally02");
	
	foreach ( guy in level.squad )
	{
		guy thread ally_color_node_hack();
	}
	
	maps\factory_util::safe_trigger_by_targetname( "r_ally_move_600" );
}

// Apparently allies are incapable of selecting another color node if the player is using it. This hack prevents a progression blocker if the player happens to be sitting on an assigned node in the parking lot.
// SO, if the playe ris hanging out at their node, we set the ally's goal to the node's origing and push the player aside to ensure they are where they need to be for the curb hop anims
ally_color_node_hack()
{
	while ( !flag ( "allies_in_loading_dock" ) )
	{
		if ( IsDefined( self.color_node ) && IsAlive ( self.color_node.owner ) )
		{
			self PushPlayer( true );
			self  SetGoalPos( self.color_node.origin );
		}
		wait 1;	
	}
}

ally_vignette_traversal( node_noteworthy,  animation )
{
	// self enable_sprint();
	self disable_pain();
	self.ignoresuppression = true;
	node				   = GetEnt ( node_noteworthy, "script_noteworthy" );
	node anim_reach_solo ( self, animation );
	node anim_single_run_solo ( self, animation );
	self enable_ai_color();	
	
}

rooftop_ally_movement( volume_targetname, trigger_targetname )
{
	level endon ( "rooftop_enemies_cleared");
	volume = GetEnt ( volume_targetname, "targetname" );
	volume waittill_volume_dead_or_dying();
	move_trigger = GetEnt ( trigger_targetname, "targetname" );
	maps\factory_util::safe_trigger_by_targetname( trigger_targetname );
	waittillframeend;
	if ( IsDefined ( move_trigger ) )
	{
		move_trigger Delete();
	}
}

rooftop_door_breach()
{
	foreach ( guy in level.squad )
	{
		guy disable_surprise();
	}
	
	guys			  = [];
	guys[ guys.size ] = level.squad[ "ALLY_ALPHA" ];
	guys[ guys.size ] = level.squad[ "ALLY_CHARLIE" ];
	
	door		  = GetEnt ( "rooftop_breach_door", "targetname" );
	door.animname = "rooftop_breach_door";
	door assign_animtree();
	
	anim_node = GetEnt ( "rooftop_breach_node", "script_noteworthy" );
	
	// Make sure both guys reach the door and idle
	anim_node thread rooftop_breach_alpha_get_ready();
	anim_node thread rooftop_breach_charlie_get_ready();

	// Wait for both guys to reach the door, and player ready for breach
	thread rooftop_door_breach_sight_check();
	flag_wait_all( "rooftop_breach_alpha_in_position", "rooftop_breach_charlie_in_position", "player_near_rooftop_door" );
	
	thread kill_backtrackers();
	
	thread rooftop_enemy_waves();
	
	thread rooftop_dialog();
	
	wait .75;
	anim_node notify ( "stop_idle" );
	level notify ( "door_kick_start" );
	
	guys[ guys.size ] = door;
	anim_node thread anim_single ( guys, "rooftop_breach" );
	
	waittillframeend;
	
	thread rooftop_enemy_door_kicker();
	
	wait 3.6;	

	//thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_ALPHA" ]  , "player_mount_vehicle_start", 0.1 );
	//thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_BRAVO" ]  , "player_mount_vehicle_start", 0.1 );
	//thread maps\factory_fx::rain_on_actor( level.squad[ "ALLY_CHARLIE" ], "player_mount_vehicle_start", 0.1 );
	
	level notify ( "rooftop_door_kicked" );
	
	door_clip = GetEnt ( "rooftop_door_clip", "targetname" );
	door_clip ConnectPaths();
	
	wait 0.3;

	activate_trigger( "rooftop_go_trigger", "targetname" );
	door_clip Delete();

	wait 1;
	
	foreach ( guy in level.squad )
	{
		guy enable_surprise();
	}
	
	battlechatter_on();
}

rooftop_door_breach_sight_check()
{
	level endon ( "player_near_rooftop_door" );
	
	location = GetEnt ( "rooftop_door_lookat_check", "targetname" );
	while ( !level.player player_looking_at( location.origin ) )
	{
		wait 0.1;		
	}
	flag_set ( "player_near_rooftop_door" );
}

// Make sure alpha gets to the door
rooftop_breach_alpha_get_ready()
{
	guys			  = [];
	guys[ guys.size ] = level.squad[ "ALLY_ALPHA" ];
	self anim_reach_and_approach( guys, "rooftop_breach_idle" );

	self thread anim_loop ( guys, "rooftop_breach_idle", "stop_idle" );
	flag_set( "rooftop_breach_alpha_in_position" );
}

// Make sure charlie gets to the door
rooftop_breach_charlie_get_ready()
{
	guys			  = [];
	guys[ guys.size ] = level.squad[ "ALLY_CHARLIE" ];
	self anim_reach_and_approach( guys, "rooftop_breach_idle" );

	self thread anim_loop ( guys, "rooftop_breach_idle", "stop_idle" );
	flag_set( "rooftop_breach_charlie_in_position" );
}

rooftop_enemy_surprised()
{
	sucker = spawn_targetname ( "door_breach_enemy_01" );
	sucker endon ( "damage" );
	level waittill ( "rooftop_door_kicked" );
	if ( IsAlive ( sucker ) )
	{
		sucker.animname = "enemy";
		sucker thread anim_single_solo ( sucker, "exposed_idle_reactB" );
		//Generic Soldier 1: They're here!
		sucker thread smart_dialogue ( "factory_gs1_here" );
		sucker.allowdeath = 1;
		wait 1.5;
	}	
	if ( IsAlive ( sucker ) )
	{
		sucker.attackeraccuracy						= 100;
		level.squad[ "ALLY_CHARLIE" ].favoriteenemy = sucker;
	}	
}

rooftop_enemy_breach_kill( spawner_targetname, anime )
{
	guy			 = spawn_targetname ( spawner_targetname );
	guy.animname = "enemy";
	guy endon ( "damage" );
	
	level waittill ( "rooftop_door_kicked" );
	wait 0.25;
	if ( IsAlive ( guy ) )
	{
		guy anim_single_solo ( guy, anime );
		guy maps\_vignette_util::vignette_actor_kill();
	}	
}

rooftop_dialog()
{
	thread rooftop_enemy_dialog();
						
	//Merrick: Okay, We're moving on three.
	level.squad[ "ALLY_ALPHA"	 ] smart_dialogue ( "factory_mrk_okayweremovingon" );
	
	// Merrick: One, two, three!
	level.squad[ "ALLY_ALPHA"	 ] smart_dialogue ( "factory_mrk_onetwothree" );
	
	level waittill ( "rooftop_enemies_cleared" );
	wait 1;
	//Rogers: Parking lot is up ahead!
	level.squad[ "ALLY_CHARLIE"	 ] smart_dialogue( "factory_rgs_parkinglot" );
	//Merrick: That's our RV - let's get down there!
	level.squad[ "ALLY_ALPHA"	 ] smart_dialogue( "factory_bkr_ourrv" );
	//Merrick: Diaz, where are you?!
	level.squad[ "ALLY_ALPHA"	 ] smart_dialogue( "factory_bkr_whereareyou" );
	//Diaz: One minute!
	smart_radio_dialogue( "factory_diz_oneminute" );
	//Merrick: We don't have a minute!
	level.squad[ "ALLY_ALPHA"	 ] smart_dialogue( "factory_bkr_donthaveaminute" );
	
	//Merrick: Get off the roof!
	//Merrick: Rook, get down here!
	//Merrick: Come on!
	lines = [ "factory_bkr_getofftheroof", "factory_bkr_rookgetdownhere", "factory_bkr_comeon" ];
	level.squad[ "ALLY_ALPHA" ] thread maps\factory_util::nag_line_generator( lines, "player_off_roof" );		
}

rooftop_enemy_dialog()
{
	guys = get_living_ai_array ( "rooftop_enemy", "script_noteworthy" );
		foreach ( guy in guys )
	{
		guy.animname = "enemy";	
	}
	guy = random( guys );
	//Generic Soldier 1: They've been spotted. Heading this way!
	guy smart_dialogue( "factory_gs1_beenspotted" );
	guy = random( guys );
	//Generic Soldier 1: Take poisitions up there!
	guy smart_dialogue( "factory_gs1_takepositions" );
	guy = random( guys );
	//Generic Soldier 1: Get a charge on that door!
	guy smart_dialogue( "factory_gs1_getacharge" );
	
}

rooftop_win()
{
	trigger_wait_targetname ( "start_chase_sequence_trigger" );
	level notify ( "rooftop_complete" );	
}

rooftop_enemy_cleanup()
{
	trigger_wait_targetname( "start_chase_sequence_trigger" );
	rooftop_enemies = get_living_ai_array( "rooftop_enemy", "script_noteworthy" );
	foreach ( enemy in rooftop_enemies )
	{
		if ( IsDefined ( enemy.magic_bullet_shield ) )
		{
			enemy stop_magic_bullet_shield();
		}
		enemy Delete();
	}
}
rooftop_heli()
{
	thread maps\factory_audio::rooftop_heli_distant_idle_sfx();
	flag_wait ( "spawn_loading_dock_vehicles" );

	heli	= spawn_vehicle_from_targetname_and_drive ( "rooftop_heli" );
	heli godon();
	
	flag_wait ( "ambush_escape_clear" );
	
	heli thread spotlight_hitbox();
	heli thread maps\factory_audio::rooftop_heli_engine_sfx();
	if ( is_gen4() )
	{
		heli thread maps\factory_util::god_rays_from_moving_source( heli,"tag_flash", "ambush_escape_clear", "rooftop_heli_depart", "factory_rooftop_floodlight", "default" );
	}
	
	wait 2;
	
	PlayFXOnTag ( level._effect[ "spotlight_model_factory" ], heli, "tag_flash" );
	heli thread maps\factory_audio::rooftop_heli_speaker_vo_sfx();

	flag_set("music_chase_start");
	
	heli thread spotlight_heli_target_think();
	heli thread spotlight_heli_spotlight_off();
	
	heli waittill ( "rooftop_heli_unload" );
	spotlight_target = GetEnt ( "heli_spotlight_fastrope_target", "targetname" );
	heli SetTurretTargetEnt( spotlight_target, ( 0, 0, 0 ) );
	
	wait 12;	// todo: the time it takes to unload must exist somewhere.
	
	heli thread spotlight_heli_target_think();
	flag_set ( "rooftop_heli_unloaded" );
	flag_wait ( "rooftop_heli_okay_to_depart" );
	flag_set ( "rooftop_heli_depart" );
}

spotlight_heli_spotlight_off()
{
	self waittill ( "rooftop_spotlight_off" );
	StopFXOnTag ( level._effect[ "spotlight_model_factory" ], self, "tag_flash" );
	wait 1.5;
	flag_set ( "rooftop_heli_okay_to_depart" );
}

spotlight_heli_target_think()
{
	self endon ( "rooftop_spotlight_off" );
	self endon ( "rooftop_heli_unload" );
	spotlight_target = Spawn ( "script_origin", level.player.origin );
		
	offsetMinX = 0;
	offsetMaxX = 16;
	offsetMinY = 0;
	offsetMaxY = 16;
	offsetMinZ = 0;
	offsetMaxZ = 16;

	self SetTurretTargetEnt( spotlight_target, ( 0, 0, 0 ) );
	self vehicle_scripts\_attack_heli::heli_default_target_setup();
	
	while ( 1 )
	{

		// Re-roll the randoms
		randX_offset = RandomIntRange( offsetMinX, offsetMaxX );
		randY_offset = RandomIntRange( offsetMinY, offsetMaxY );
		randZ_offset = RandomIntRange( offsetMinZ, offsetMaxZ );

		// Randomize left/right Y offset
		if ( cointoss() )
		{
			randY_offset *= -1;
		}
		
		// Randomize up/down Z offset
		if ( cointoss() )
		{
			randZ_offset *= -1;
		}
		
		// Randomize fore/back X offset
		if ( cointoss() )
		{
			randX_offset *= -1;
		}

		// Move the target entity to the random position
		best_choice				= self spotlight_heli_target_choice();
		spotlight_target.origin = ( best_choice.origin + ( randX_offset, randY_offset, randZ_offset ) );
		wait ( RandomFloatRange ( 0.01, 0.1 ) );
	}
}

/*
spotlight_disables_thermal( heli, hitbox )
{
	heli endon ( "rooftop_spotlight_off" );
	while ( 1 )
	{
		trace = BulletTrace ( heli GetTagOrigin ( "tag_flash" ), level.player GetEye (), false, hitbox, false, false );
		if ( trace[ "fraction" ]     > 0.9 )
		{
			// Notify the player he is blinded
			level.player notify( "spotlight_blind" );
			
			// If this is the first time, hint to the player why thermals don't work
			if ( level.player.thermal == true && !flag ("spotlight_thermal_hint" ))
			{
				// Merrick: That spotlight's blowing out our thermals!
				level.squad[ "ALLY_ALPHA"	 ] smart_dialogue( "factory_mrk_thatspotlightsblowingout" );
				flag_set ( "spotlight_thermal_hint" );
			}
		}
		wait 0.25;
	}
}
*/

spotlight_heli_target_choice()
{
	// Simply choose the closest guy to the helicopter
	guys			  = level.squad;
	guys[ guys.size ] = level.player;
	guy				  = getClosest( self.origin, guys );
	return guy;
 }
 
spotlight_hitbox()
{
	self endon ( "rooftop_spotlight_off" );
	hitbox		  = GetEnt ( "rooftop_spotlight_hitbox", "targetname" );
	hitbox.origin = self GetTagOrigin ( "tag_flash" );
	hitbox LinkTo ( self, "tag_flash" );
	hitbox SetCanDamage( true );
	hitbox Hide();
	hits = 0;
	
	// thread spotlight_disables_thermal( self, hitbox );

	// Lots of health to ensure that stray bullets don't accidentally destroy it.
	hitbox.health = 100000;
	while ( 1 )
	{
		hitbox waittill ( "damage", amount, attacker );
		// Only shots from the player count
		if ( attacker == level.player )
		{
			hits ++;
			// how many hits to destroy hitbox
			if ( hits == 2 )
			{
				break;
			}
		}
		wait 0.05;
	}
	
	// Now enemies have more difficulty hitting the allied squad members
	squad = level.squad;
	squad[ squad.size ] = level.player;
	foreach ( guy in squad )
	{
		guy.attackeraccuracy = .75;	
	}
	
	/*
	// If the player got the spotlight/thermal hint, let them know they fixed the issue.
	if ( flag ("spotlight_thermal_hint" ))
	{
		// Note, this line gives the opposite information. Redo is requested.
		// Nice thinking!  Thermals off!
		level.squad[ "ALLY_ALPHA"	 ] thread smart_dialogue( "factory_mrk_nicethinkingthermalsoff" );
	}
	*/
	self thread maps\factory_audio::rooftop_heli_speaker_destroy();
	self thread spotlight_destroyed_fx();
	flag_clear( "ambush_thermal_flashed" );
	self notify ( "rooftop_spotlight_off" );
}

spotlight_destroyed_fx()
{
	for ( i = 0 ; i < 4; i++ )
	{
		PlayFX ( level._effect[ "welding_sparks_funner" ], self GetTagOrigin ( "tag_flash" ) );
		wait 1;
	}
}

// If the rooftop door has opened, and the player goes back to the assembly room, the airstrike arrives and kills them.
// This way they hopefully don't notice that the assembly line has stopped.
kill_backtrackers()
{
	level endon ( "rooftop_complete" );
	
	trigger_wait_targetname ( "ambush_escape_clear_trigger" );
	
	// Merrick: Adam, get back on mission!
	smart_radio_dialogue ( "factory_mrk_adamgetbackhere");
	
	trigger_wait_targetname ( "ambush_escape_backtrack_trigger" );
	
	//"You were killed by the airstrike.\nEscape the factory with your team."
	SetDvar( "ui_deadquote", &"FACTORY_FAIL_BACKTRACKING" );
	PlayFX ( level._effect[ "101ton_bomb" ], level.player.origin );
	level.player Kill();	
	missionFailedWrapper();
}