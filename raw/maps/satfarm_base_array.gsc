#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;
#include maps\satfarm_code_heli;

base_array_init()
{
	level.start_point = "base_array";
	//"Rendesvouz with Bravo Team."
	Objective_Add( obj( "rendesvouz" ), "current", &"SATFARM_OBJ_RENDESVOUZ" );
	
	thread base_array_ridge_obj_marker();
	
	thread base_array_ambient_dogfight_1();
    thread base_array_ambient_dogfight_2();
    thread base_array_ambient_dogfight_3();
    
    kill_spawners_per_checkpoint( "base_array" );
}

base_array_main()
{
	if( !IsDefined( level.playertank ) )
	{
		spawn_player_checkpoint( "base_array_" );
		
		// setup allies
		spawn_heroes_checkpoint( "base_array_" );

		array_thread( level.allytanks, ::npc_tank_combat_init );
	}
	else
	{
		//move hero tanks to new path
		thread switch_node_on_flag( level.herotanks[0], "", "switch_base_array_path_hero0", "base_array_path_hero0" );
		thread switch_node_on_flag( level.herotanks[1], "", "switch_base_array_path_hero1", "base_array_path_hero1" );
	}
	
	level.herotanks[0] thread tank_relative_speed( "air_strip_relative_speed", "base_array_end", 200, 15, 2 );
	level.herotanks[1] thread tank_relative_speed( "air_strip_relative_speed", "base_array_end", 250, 13.5, 1.5 );
	
	thread base_array_begin();
	
	flag_wait( "base_array_end" );
	
	maps\_spawner::killspawner( 30 );
    kill_vehicle_spawners_now( 30 );
    base_array_cleanup();
}

base_array_begin()
{
	flag_set( "base_array_begin" );
	
	thread base_array_allies_setup();
	thread base_array_enemies_setup();
	thread spawn_sat_array_a10_missile_dive_1();
	thread spawn_sat_array_a10_gun_dive_1();
	thread base_array_trucks_01_setup();
	thread base_array_pinned_down_allies();
	thread base_array_vo();
	thread base_array_choppers();
	thread base_array_hints();
	thread base_array_obj_markers();
	thread base_array_exit_rpg();
	autosave_by_name( "base_array" );
}

spawn_sat_array_a10_missile_dive_1()
{
	flag_wait( "start_sat_array_a10_missile_dive_1" );
	
	spawn_vehicle_from_targetname_and_drive( "sat_array_a10_missile_dive_1" );
}

spawn_sat_array_a10_gun_dive_1()
{
	flag_wait( "start_sat_array_a10_gun_dive_1" ); //on sat_array_enemy_03 vehicle node
	
	spawn_vehicle_from_targetname_and_drive( "sat_array_a10_gun_dive_1" );
}

base_array_allies_setup()
{
	allytanks = spawn_vehicles_from_targetname_and_drive( "sat_array_allies" );
	level.allytanks = array_combine( level.allytanks, allytanks );
	array_thread( allytanks, ::flag_wait_god_mode_off, "base_array_ridge_reached" );
	array_thread( allytanks, ::npc_tank_combat_init );
	
	foreach( ally in allytanks )
	{
		if( IsDefined( ally.script_friendname ) && ally.script_friendname == "Buzzard" )
		{
			ally thread tank_relative_speed( "air_strip_relative_speed", "base_array_end", 200, 5, 1.5 );
		}
		else if( IsDefined( ally.script_friendname ) && ally.script_friendname == "Barracuda" )
		{
			ally thread tank_relative_speed( "air_strip_relative_speed", "base_array_end", 100, 2, 2.0 );
		}
		else if( IsDefined( ally.script_friendname ) && ally.script_friendname == "Bronco" )
		{
			ally thread tank_relative_speed( "air_strip_relative_speed", "base_array_end", 50, 1, 1.75 );
		}
	}
}

base_array_enemies_setup()
{
	enemytanks = spawn_vehicles_from_targetname( "sat_array_enemies" );
	array_thread( enemytanks, ::base_array_setup_reverse_start );
	level.enemytanks = array_combine( level.enemytanks, enemytanks );
	array_thread( enemytanks, ::flag_wait_god_mode_off, "base_array_ridge_reached" );
	array_thread( enemytanks, ::npc_tank_combat_init );
	
	foreach( tank in enemytanks )
	{
		if( IsDefined( tank.script_noteworthy ) && tank.script_noteworthy == "sat_array_reverse_enemy_scripted_kill" )
		{
			tank thread delayed_kill( 3.5, "sat_array_enemies_retreat_01" );
		}
	}
	
	waittilltanksdead( enemytanks, 2 );
	
	flag_set( "sat_array_enemies_retreat_01" );
	
	flag_wait_either( "sat_array_initial_enemies_dead", "spawn_base_array_choppers" );
	
	foreach( enemytank in enemytanks )
	{
		if( IsDefined( enemytank ) && enemytank.classname != "script_vehicle_corpse" )
		{
			enemytank thread maps\satfarm_code::random_wait_and_kill( 1.0, 3.0 );
		}
	}
}

base_array_choppers()
{
	maps\_chopperboss::chopper_boss_locs_populate( "script_noteworthy", "heli_nav_mesh_base_array" );
	
	flag_wait_either( "sat_array_initial_enemies_dead", "spawn_base_array_choppers" );
	
	choppers = spawn_hind_enemies( 3, "heli_nav_mesh_base_array_start" );
	
	foreach ( chopper in choppers )
	{
		self thread chopper_explode_in_air();
	}
	
	wait( 2.0 );
	
	//Badger: Enemy attack choppers moving in!
	thread radio_dialog_add_and_go( "satfarm_bgr_enemyattackchoppersmoving" );
	
	//display guided sabot hint here
	
	waittillhelisdead( get_hinds_enemy_active(), 2 );
	
	wait( 3.0 );
	
	choppers = get_hinds_enemy_active();
	
	foreach( chopper in choppers )
	{
		chopper Kill();
	}
}

chopper_explode_in_air()
{
	self waittill( "death" );
	
	if( IsDefined( self ) )
		self notify( "crash_done" );//cause the heli to explode
	if( IsDefined( self ) )
		self notify( "in_air_explosion" );//stop the parent thread
}

base_array_setup_reverse_start()
{
	self endon( "death" );
	
	if( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "sat_array_reverse_enemy_scripted_kill" )
		return;
	
	flag_wait( "sat_array_enemies_retreat_01" );
	
	wait( RandomFloatRange( 0.1, 0.5 ) );
	
	self.veh_transmission = "reverse";
	self.script_transmission  = "reverse";
	node = self.script_noteworthy + "_start_node";
	switch_node_now( self, GetVehicleNode( node, "targetname" ) );
	
	self.veh_transmission = "reverse";
	self.script_transmission  = "reverse";
	switch_node_name = "switch_" + self.script_noteworthy + "_start_node_2";
	target_node_name = self.script_noteworthy + "_start_node_2";
	thread switch_node_on_flag( self, "sat_array_enemies_retreat_02", switch_node_name, target_node_name );
	
	self.veh_transmission = "reverse";
	self.script_transmission  = "reverse";
	switch_node_name = "switch_" + self.script_noteworthy + "_start_node_3";
	target_node_name = self.script_noteworthy + "_start_node_3";
	thread switch_node_on_flag( self, "sat_array_enemies_retreat_02", switch_node_name, target_node_name );
}

base_array_trucks_01_setup()
{
	flag_wait( "sat_array_enemies_retreat_02" );
	
	trucks = spawn_vehicles_from_targetname_and_drive( "base_array_trucks_01" );
	
	array_thread( trucks, ::gaz_spawn_setup );
}

base_array_pinned_down_allies()
{
	guys = array_spawn_targetname( "base_array_pinned_down_allies", true );
	
	foreach( guy in guys )
	{
		guy forceUseWeapon( "rpg_straight" , "primary" );
		guy magic_bullet_shield();
	}
	
	flag_wait( "base_array_end" );
	
	foreach( guy in guys )
	{
		guy stop_magic_bullet_shield();
		guy Delete();
	}
}

base_array_vo()
{
	wait( 1.0 );
	
	//Badger: We’re nearing your position, Bravo.
	radio_dialog_add_and_go( "satfarm_bgr_werenearingyourposition" );
	
	wait( 0.5 );
	
	//Bravo: Roger that; popping green smoke.
	radio_dialog_add_and_go( "satfarm_brv_rogerthatpoppinggreen" );
		
	flag_wait( "base_array_ridge_reached" );
	
	//Badger: We have a visual on you, Bravo.
	radio_dialog_add_and_go( "satfarm_bgr_wehaveavisual" );
	
	//Bravo: Welcome to the party.
	radio_dialog_add_and_go( "satfarm_brv_welcometotheparty" );
	
	//Badger: You can buy us a drink later. Let’s push ‘em back.
	radio_dialog_add_and_go( "satfarm_bgr_youcanbuyus" );
}

base_array_hints()
{
	flag_wait( "base_array_ridge_reached" );
	
	objective_complete( obj( "rendesvouz" ) );
	
	//"Reach the Air Strip."
	Objective_Add( obj( "reach_air_strip" ), "current", &"SATFARM_OBJ_REACH_AIR_STRIP" );
	
	level.player thread display_hint_timeout( "HINT_ZOOM", 8 );
	
	flag_wait( "sat_array_enemies_retreat_01" );
	
	//Badger: Lay down some smoke!
	radio_dialog_add_and_go( "satfarm_bgr_laydownsomesmoke" );
	level.player display_hint_timeout( "HINT_SMOKE", 8 );
	
	wait( 0.1 );
	
	//Badger: Switch to thermals!
	radio_dialog_add_and_go( "satfarm_bgr_switchtothermals" );
	level.player thread display_hint_timeout( "HINT_THERMAL", 8 );
	
	flag_wait_either( "sat_array_initial_enemies_dead", "spawn_base_array_choppers" );
	
	wait( 2.0 );
	
	level.player display_hint( "HINT_SWITCH_TO_GUIDED_ROUND" );
	
	level.player display_hint( "HINT_GUIDED_ROUND_FIRE" );
}

base_array_obj_markers()
{
	flag_wait( "base_array_ridge_reached" );
	
	base_array_obj_marker = GetEnt( "base_array_obj_marker", "targetname" );
	
	thread add_ent_objective_to_compass( base_array_obj_marker );
	
	flag_wait( "base_array_allies_relative_speed" );
	
	thread remove_ent_objective_from_compass( base_array_obj_marker );
	
	base_array_exit_ridge_obj_marker = GetEnt( "base_array_exit_ridge_obj_marker", "targetname" );
	
	thread add_ent_objective_to_compass( base_array_exit_ridge_obj_marker );
	
	flag_wait( "sat_array_enemies_retreat_03" );
	
	thread base_array_end_vo();
	
	thread remove_ent_objective_from_compass( base_array_exit_ridge_obj_marker );
	
	base_array_end_obj_marker = GetEnt( "base_array_end_obj_marker", "targetname" );
	
	thread add_ent_objective_to_compass( base_array_end_obj_marker );
	
	flag_wait( "base_array_end" );
	
	thread remove_ent_objective_from_compass( base_array_end_obj_marker );
}

base_array_end_vo()
{
	//Bravo: Thanks for the assist. The airstrip is directly ahead.
	radio_dialog_add_and_go( "satfarm_brv_thanksfortheassist" );
	
	//Badger: Ghost One, we’ve regrouped with Bravo and are heading to the airstrip. Should have it cleared out soon.
	radio_dialog_add_and_go( "satfarm_bgr_ghostoneweveregrouped" );

	//Merrick: Roger that, Badger One. ETA 3 minutes.
	radio_dialog_add_and_go( "satfarm_mrk_rogerthatbadgerone" );
	
	thread setup_mortar_fire();
}

base_array_ridge_obj_marker()
{
	base_array_ridge_obj_marker = GetEnt( "base_array_ridge_obj_marker", "targetname" );
	
	thread add_ent_objective_to_compass( base_array_ridge_obj_marker );
	
	flag_wait( "base_array_ridge_reached" );
	
	thread remove_ent_objective_from_compass( base_array_ridge_obj_marker );
}

setup_mortar_fire()
{
	level endon( "stop_base_array_mortar_strikes" );
	
	thread base_array_mortar_strikes();
	
	//Badger: Incoming!
	radio_dialog_add_and_go( "satfarm_bgr_incoming" );
	
	//Bravo: Incoming!
	//radio_dialog_add_and_go( "satfarm_brv_incoming" );
	
	//Badger: They’ve targeted our position with mortars, push forward!
	radio_dialog_add_and_go( "satfarm_bgr_theyvetargetedourposition" );
	
	//Badger: Go! Go! Go!
	radio_dialog_add_and_go( "satfarm_bgr_gogogo" );
	
	//Bravo: Baker’s hit, Baker’s hit!
	//radio_dialog_add_and_go( "satfarm_brv_bakershitbakershit" );
	
	//Badger: Don't stop!
	radio_dialog_add_and_go( "satfarm_bgr_dontstop" );
	
	radio_dialog_add_and_go( "tankdrive_gnr_mortarfire" );
	
	radio_dialog_add_and_go( "tankdrive_alt_punchit" );

	//Badger: Full throttle
	radio_dialog_add_and_go( "satfarm_bgr_fullthrottle" );
	
	//Badger: Move! Move!!
	radio_dialog_add_and_go( "satfarm_bgr_movemove" );
	
	wait( RandomFloatRange( 2.0, 4.0 ) );
	
	while( 1 )
	{
		wait( RandomFloatRange( 2.0, 4.0 ) );
		
		//Badger: Go! Go! Go!
		radio_dialog_add_and_go( "satfarm_bgr_gogogo" );
	
		wait( RandomFloatRange( 2.0, 4.0 ) );
		
		//Badger: Incoming!
		radio_dialog_add_and_go( "satfarm_bgr_incoming" );
		
		wait( RandomFloatRange( 2.0, 4.0 ) );
		
		//Badger: Move! Move!!
		radio_dialog_add_and_go( "satfarm_bgr_movemove" );
	}
}

base_array_mortar_strikes()
{	
	while ( !flag( "stop_base_array_mortar_strikes" ) )
	{
		for( i = 0; i < 3; i++ )
		{
			playerPosition	= level.player GetEye();
			playerAngles 	= level.playertank.angles;
			playerForward 	= AnglesToForward( 	playerAngles );
			playerRight 	= AnglesToRight( 	playerAngles );
			playerSpeed 	= level.playertank Vehicle_GetSpeed();
			
			//strike location
			strikePosition 	= playerPosition + ( playerForward * 2000 );
			
			//strike offset
			offsetx 		= RandomFloatRange( -1000, 1000 );
			if( offsetx < 500  && offsetx >= 0 )
				offsetx 	= RandomFloatRange( 500, 1000 );
			if( offsetx > -500 && offsetx <  0 )
				offsetx 	= RandomFloatRange( -1000, -500 );
			
			offsety 		= RandomFloatRange( -1000, 1000 );
			if( offsety < 500  && offsety >= 0 )
				offsety 	= RandomFloatRange( 500, 1000 );
			if( offsety > -500 && offsety <  0 )
				offsety 	= RandomFloatRange( -1000, -500 );
			
			strikeOffset	= ( offsetx, offsety, 2000 );
			
			//create fx tag
			fxTag 			= spawn_tag_origin();
			fxTag.origin 	= drop_to_ground( strikePosition + strikeOffset );
			fxTag.angles	= (-90,0,0);
			
			//mortar fire
			thread play_sound_in_space( "mortar_incoming_intro", fxTag.origin );
			
			wait RandomFloatRange( .25, .45 );
			
			playfxontag( getfx( "mortar" ), fxTag, "tag_origin" );
			EarthQuake( .2, .5, level.player.origin, 512 );
			thread play_sound_in_space( "mortar_explosion_intro", fxTag.origin );
			PlayRumbleOnPosition( "damage_heavy", fxTag.origin );
			RadiusDamage( fxTag.origin, 400, 100, 50 );
			
			wait RandomFloatRange( .25, .45 );
			
			fxTag Delete();
		}
		
		wait RandomFloatRange( .5, 1 );
	}
	
	//Warthog: Warthog 3-1 coming in to clear your path.
	thread radio_dialog_add_and_go( "satfarm_whg_warthog31comingin" );
	spawn_vehicles_from_targetname_and_drive( "air_strip_mortar_killers" );
	
	for( i = 0; i < 4; i++ )
	{
		if ( i == 3 )
			//Badger: We’re clear, we’re clear! Air base up ahead, keep moving!
			thread radio_dialog_add_and_go( "satfarm_bgr_wereclearwereclear" );
		
		playerPosition	= level.player GetEye();
		playerAngles 	= level.playertank.angles;
		playerForward 	= AnglesToForward( 	playerAngles );
		playerRight 	= AnglesToRight( 	playerAngles );
		playerSpeed 	= level.playertank Vehicle_GetSpeed();
		
		//strike location
		strikePosition 	= playerPosition + ( playerForward * 2000 );
		
		//strike offset
		offsetx 		= RandomFloatRange( -1000, 1000 );
		if( offsetx < 500  && offsetx >= 0 )
			offsetx 	= RandomFloatRange( 500, 1000 );
		if( offsetx > -500 && offsetx <  0 )
			offsetx 	= RandomFloatRange( -1000, -500 );
		
		offsety 		= RandomFloatRange( -1000, 1000 );
		if( offsety < 500  && offsety >= 0 )
			offsety 	= RandomFloatRange( 500, 1000 );
		if( offsety > -500 && offsety <  0 )
			offsety 	= RandomFloatRange( -1000, -500 );
		
		strikeOffset	= ( offsetx, offsety, 2000 );
		
		//create fx tag
		fxTag 			= spawn_tag_origin();
		fxTag.origin 	= drop_to_ground( strikePosition + strikeOffset );
		fxTag.angles	= (-90,0,0);
		
		//mortar fire
		thread play_sound_in_space( "mortar_incoming_intro", fxTag.origin );
		
		wait RandomFloatRange( .25, .45 );
		
		playfxontag( getfx( "mortar" ), fxTag, "tag_origin" );
		EarthQuake( .2, .5, level.player.origin, 512 );
		thread play_sound_in_space( "mortar_explosion_intro", fxTag.origin );
		PlayRumbleOnPosition( "damage_heavy", fxTag.origin );
		RadiusDamage( fxTag.origin, 400, 100, 50 );
		
		wait RandomFloatRange( .25, .45 );
		
		fxTag Delete();
		
		wait( RandomFloatRange( 0.5, 0.75 ) );
	}
}

base_array_ai_cleanup_spawn_function()
{
	self endon( "death" );
	
	if ( IsSubStr( ToLower( self.classname ), "rpg" ) )
		self thread enemy_rpg_unlimited_ammo();
	
	flag_wait( "base_array_end" );
	
	if( IsDefined( self ) && IsAlive( self ) )
		self Kill();
}

base_array_ambient_dogfight_1()
{
	level endon ( "base_array_end" );
	
	while( 1 )
	{
		wait( RandomFloatRange( 10.0, 20.0 ) );
		
		level.base_array_ambient_a10_gun_dive_1 = undefined;
		
		level.base_array_ambient_a10_gun_dive_1 = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_a10_gun_dive_1" );
		
		if( cointoss() )
			a10_buddy = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_a10_gun_dive_1_buddy" );
		
		wait( 0.5 );
		
		mig = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_mig29_missile_dive_1" );
		mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
		
		if( cointoss() )
			mig_buddy = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_mig29_missile_dive_1_buddy" );
		
		wait( RandomFloatRange( 5.0, 10.0 ) );
	}
}

base_array_ambient_dogfight_2()
{
	level endon ( "base_array_end" );
	
	while( 1 )
	{
		wait( RandomFloatRange( 20.0, 40.0 ) );
		
		level.base_array_ambient_a10_gun_dive_2 = undefined;
		
		level.base_array_ambient_a10_gun_dive_2 = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_a10_gun_dive_2" );
		
		if( cointoss() )
			a10_buddy = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_a10_gun_dive_2_buddy" );
		
		wait( 0.5 );
		
		mig = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_mig29_missile_dive_2" );
		mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
		
		if( cointoss() )
			mig_buddy = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_mig29_missile_dive_2_buddy" );
		
		wait( RandomFloatRange( 5.0, 10.0 ) );
	}
}

base_array_ambient_dogfight_3()
{
	level endon ( "base_array_end" );
	
	while( 1 )
	{
		wait( RandomFloatRange( 15.0, 30.0 ) );
		
		level.base_array_ambient_a10_gun_dive_3 = undefined;
		
		level.base_array_ambient_a10_gun_dive_3 = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_a10_gun_dive_3" );
		
		if( cointoss() )
			a10_buddy = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_a10_gun_dive_3_buddy" );
		
		wait( 0.5 );
		
		mig = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_mig29_missile_dive_3" );
		mig thread maps\satfarm_ambient_a10::mig29_afterburners_node_wait();
		
		if( cointoss() )
			mig_buddy = spawn_vehicle_from_targetname_and_drive( "base_array_ambient_mig29_missile_dive_3_buddy" );
		
		wait( RandomFloatRange( 5.0, 10.0 ) );
	}
}

base_array_cleanup()
{
	//wait( 1.0 );
	ents = GetEntArray( "base_array_ent", "script_noteworthy" );
	array_delete( ents );
}

base_array_exit_rpg()
{
	flag_wait( "base_array_exit_rpg" );
	
	array_spawn_targetname( "base_array_exit_tower_rpg_guys", true );
	
	base_array_exit_rpg_spot = getstruct( "base_array_exit_rpg_spot", "targetname" );
	
	MagicBullet( "rpg_straight", base_array_exit_rpg_spot.origin, level.playertank.origin );
}