#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\cornered_code;
#include maps\cornered_code_rappel;
#include maps\cornered_lighting;
#include maps\cornered_binoculars;
#include maps\_stealth_utility;
#include maps\player_scripted_anim_util;

cornered_interior_pre_load()
{
	// --use this to init flags or precache items for an area.--
	flag_init( "courtyard_finished" );
	flag_init( "bar_finished" );
	flag_init( "junction_finished" );
	
	// --Stealth--
	flag_init( "stealth_enabled" );
	flag_init( "stealth_broken" );
	flag_init( "hvt_got_away" );
	
	// --Courtyard Entry--
	flag_init( "baker_at_hallway_exit" );

	// --Courtyard Lobby Elevator--
	flag_init( "courtyard_intro_elevator_button" );
	flag_init( "elevator_guy1_done" );
	flag_init( "courtyard_intro_rorke_done" );
	flag_init( "courtyard_intro_elevator_opening" );
	flag_init( "cy_elevator_open" );
	flag_init( "cy_elevator_closed" );
	
	// --Courtyard Main--

	// --Courtyard Side Office--
	flag_init( "rorke_open_office_a" );
	flag_init( "courtyard_office_id_vo" );
	flag_init( "office_guy_killed" );
	flag_init( "courtyard_reception_office_a_chopper_shine_spotlight" );
	flag_init( "courtyard_reception_office_a_chopper_exit" );
	flag_init( "office_a_chopper_spotlight_on" );
	flag_init( "office_a_chopper_spotlight_off_and_exit" );
	flag_init( "at_cy_exit_door" );
	
	// --Courtyard Bridge--
	
	// --Bar--
	flag_init( "bar_light_shot" );
	flag_init( "strobe_on" );
	flag_init( "strobe_off" );
	flag_init( "bar_wave2" );
	flag_init( "activate_strobe_off_failsafe" );
	flag_init( "bar_enemies_reacted" );
	flag_init( "bar_guy_killed" );
	flag_init( "player_touched_enemy" );
	flag_init( "2nd_wave_standard" );
	
	flag_init( "e09_path_done" );
	flag_init( "e10_path_done" );
	
	// --Junction--
	flag_init( "rorke_opening_junction_exit_door" );
	flag_init( "rorke_starts_handoff_anim" );
	flag_init( "start_junction_pip_scenario" );
	flag_init( "hesh_elevator_vo_said" );
	flag_init( "start_hesh_elevator_exit" );
	flag_init( "player_shutting_down_elevators" );
	flag_init( "start_disable_elevators" );
	flag_init( "junction_enemies_wave_2" );
	flag_init( "junction_enemies_dead" );
	flag_init( "c4_vo_over" );
	
	PreCacheItem( "concussion_grenade" );
	
//	PreCacheModel( "cnd_portable_light_off" );
	PreCacheModel( "cnd_banner_sim" );
	PreCacheModel( "cnd_banner2_sim" );
	PreCacheModel( "cnd_server_control_panel_anim_obj" );
	PreCacheModel( "weapon_c4" );
	PreCacheModel( "cnd_rope_rappel_coil_04_obj" );
	
	//spotlight
	PreCacheModel( "com_blackhawk_spotlight_on_mg_setup" );
	PreCacheTurret( "heli_spotlight" );
	
	// elevator lights
	PreCacheModel( "cnd_controlpanel_elevator_grn_01" );
	PreCacheModel( "cnd_controlpanel_elevator_grn_02" );
	PreCacheModel( "cnd_controlpanel_elevator_grn_03" );
	PreCacheModel( "cnd_controlpanel_elevator_grn_04" );
	PreCacheModel( "cnd_controlpanel_elevator_grn_05" );
	PreCacheModel( "cnd_controlpanel_elevator_grn_06" );
	PreCacheModel( "cnd_controlpanel_elevator_red_07" );
	PreCacheModel( "cnd_controlpanel_elevator_red_08" );
	PreCacheModel( "cnd_controlpanel_elevator_red_09" );
	PreCacheModel( "cnd_controlpanel_elevator_red_10" );
	PreCacheModel( "cnd_controlpanel_elevator_red_11" );
	PreCacheModel( "cnd_controlpanel_elevator_red_12" );
	
	PreCacheShader( "hud_icon_strobe" );
	
	//"Your actions got Merrick killed."
	PreCacheString( &"CORNERED_RORKE_WAS_KILLED" );
	//"Your actions got Hesh killed."
	PreCacheString( &"CORNERED_BAKER_WAS_KILLED" );
	//"The HVT got away."
	PreCacheString( &"CORNERED_HVT_GOT_AWAY" );
	//"Press [{+actionslot 1}] to activate strobe light."
	PreCacheString( &"CORNERED_STROBE_ON" );
	//"Press [{+actionslot 1}] to deactivate strobe light."
	PreCacheString( &"CORNERED_STROBE_OFF" );
	
	//"Press [{+actionslot 1}] to activate strobe light."
	add_hint_string( "turn_on_strobe", &"CORNERED_STROBE_ON" );
	//"Press [{+actionslot 1}] to deactivate strobe light."
	add_hint_string( "turn_off_strobe", &"CORNERED_STROBE_OFF" );
	
	level.combat_rappel_rope_coil_rorke = GetEnt( "combat_rappel_rope_coil_rorke", "targetname" );
	level.combat_rappel_rope_coil_rorke Hide();
	
	level.combat_rappel_rope_coil_player = GetEnt( "combat_rappel_rope_coil_player", "targetname" );
	level.combat_rappel_rope_coil_player Hide();
	
	level.combat_rappel_rope_coil_baker = GetEnt( "combat_rappel_rope_coil_baker", "targetname" );
	level.combat_rappel_rope_coil_baker Hide();
}

setup_courtyard()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	setup_player();
	spawn_allies();
	
	level.started_courtyard_from_startpoint = true;
	//thread maps\cornered_building_entry::inverted_kill_balcony_door();
	
	//level.player SwitchToWeapon( "m14ebr_acog_silenced_cornered" );
	level.player SwitchToWeapon( "imbel+acog_sp+silencer_sp" );
	
	thread handle_intro_fx();
	thread maps\cornered_audio::aud_check( "courtyard" );
	thread fireworks_courtyard();
	thread courtyard_intro_elevator();
	thread courtyard_directory();
	thread courtyard_intro_elevator_guys();
	
	thread delete_building_glow();
	thread delete_window_reflectors();
	flag_set( "fx_screen_raindrops" );
	thread maps\cornered_fx::fx_screen_raindrops();
	do_specular_sun_lerp( true );
	level.player thread maps\cornered_building_entry::player_handle_outside_effects();
}

setup_bar()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	setup_player();
	spawn_allies();
	
	level.started_bar_from_startpoint = true;
	maps\_utility::vision_set_fog_changes( "cornered_04", .05 );

	//level.player SwitchToWeapon( "m14ebr_acog_silenced_cornered" );
	level.player SwitchToWeapon( "imbel+acog_sp+silencer_sp" );
	
	thread bar_prep();
	
	thread handle_intro_fx();
	thread fireworks_courtyard_post();
	thread maps\cornered_audio::aud_check( "bar" );
	thread maps\cornered_audio::aud_bar( "amb" );
	thread maps\cornered_audio::aud_bar( "stop" );
	
	thread delete_building_glow();
	thread delete_window_reflectors();
		
	// stealth stuff
	custom_cornered_stealth_settings();
	level.player stealth_default();
	level.allies[ level.const_rorke ] stealth_default			 (	 );
	level.allies[ level.const_rorke ] thread ally_stealth_settings(	 );
	level.allies[ level.const_rorke ] disable_ai_color			 (	 );
	level.allies[ level.const_rorke ] enable_arrivals			 (	 );
	level.allies[ level.const_rorke ] enable_exits				 (	 );
	
	level.allies[ level.const_baker ] stealth_default			 (	 );
	level.allies[ level.const_baker ] thread ally_stealth_settings(	 );
	level.allies[ level.const_baker ] disable_ai_color			 (	 );
	level.allies[ level.const_baker ] enable_arrivals			 (	 );
	level.allies[ level.const_baker ] enable_exits				 (	 );
	
	thread custom_bar_stealth_setting(); //changing corpse detect distances.
	thread stealth_corpse_reset_time_custom( 10 ); //default is 30
	thread maps\cornered_fx::fx_screen_raindrops();
	
	// for testing
/#
	SetDvarIfUninitialized( "optional_objective", "0" );
	if ( GetDvar( "optional_objective" ) != "0" )
	{
		flag_set( "double_agent_confirmed" );
		thread maps\cornered::obj_optional_double_agent();
	}
#/
}

setup_junction()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	setup_player();
	spawn_allies();
	
	level.started_junction_from_startpoint = true;

	//level.player SwitchToWeapon( "m14ebr_acog_silenced_cornered" );
	level.player SwitchToWeapon( "imbel+acog_sp+silencer_sp" );

	thread handle_intro_fx();
	thread maps\cornered_audio::aud_check( "junction" );
	
	delete_building_glow();

	// stealth stuff
	custom_cornered_stealth_settings();
	level.player stealth_default();
	level.allies[ level.const_rorke ] thread ally_stealth_settings(	 );
	level.allies[ level.const_rorke ] disable_ai_color			 (	 );
	level.allies[ level.const_rorke ] enable_arrivals			 (	 );
	level.allies[ level.const_rorke ] enable_exits				 (	 );
	
	level.allies[ level.const_baker ] thread ally_stealth_settings(	 );
	level.allies[ level.const_baker ] disable_ai_color			 (	 );
	level.allies[ level.const_baker ] enable_arrivals			 (	 );
	level.allies[ level.const_baker ] enable_exits				 (	 );

	junction_entrance_player_clip = GetEnt( "junction_entrance_player_clip", "targetname" );
	junction_entrance_player_clip Delete();
	
	thread maps\cornered_fx::fx_screen_raindrops();
}

begin_courtyard()
{
	thread courtyard_transient_unload();
	thread courtyard_transient_load();
	
	//--use this to run your functions for an area or event.--
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	custom_cornered_stealth_settings();
	level.player stealth_default();
	level.allies[ level.const_rorke ] thread ally_stealth_settings(	 );
	level.allies[ level.const_rorke ] disable_ai_color			 (	 );
	level.allies[ level.const_rorke ] enable_arrivals			 (	 );
	level.allies[ level.const_rorke ] enable_exits				 (	 );
	
	level.allies[ level.const_baker ] thread ally_stealth_settings(	 );
	level.allies[ level.const_baker ] disable_ai_color			 (	 );
	level.allies[ level.const_baker ] enable_arrivals			 (	 );
	level.allies[ level.const_baker ] enable_exits				 (	 );

	waitframe();
	thread maps\cornered_lighting::cnd_reception_elevator();
	thread courtyard_intro_handler();
	
	flag_wait( "courtyard_finished" );
	//thread autosave_now(); //there's a save in the courtyard_rorke_function, don't need this one.
}

begin_bar()
{
	//--use this to run your functions for an area or event.--
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	activate_exploder( "light_halogen_bar" );
	level.allies[ level.const_rorke ] thread bar_rorke();
	
	flag_wait( "bar_finished" ); //	-- handled by a trigger_multiple_flag_set in the .map file
	thread autosave_now();
	
}

begin_junction()
{
	//--use this to run your functions for an area or event.--
	level.player SetWeaponAmmoClip( "fraggrenade", 0 );
	level.player SetWeaponAmmoStock( "fraggrenade", 0 );
	level.player SetWeaponAmmoClip( "flash_grenade", 0 );
	level.player SetWeaponAmmoStock( "flash_grenade", 0 );
	
	thread junction_handler();
	
	flag_wait( "junction_finished" );	
	thread autosave_now();
}

junction_fireworks() // done in airlock function
{
	fireworks_stop();
	waitframe();
	fireworks_junction();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// COURTYARD
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
/////////////////////////////////////////////////////////////////////////////////////////////////
// Building entry after inverted rappel
/////////////////////////////////////////////////////////////////////////////////////////////////
courtyard_intro_handler()
{
	level.allies[ level.const_rorke ] thread courtyard_intro_rorke();
	//level.allies[ level.const_baker ] thread courtyard_intro_baker(); //--using original baker stuff
	level.allies[ level.const_baker ] thread courtyard_intro_baker_exit();
	thread courtyard_intro_ally_vo();
	//thread courtyard_intro_elevator();
	//thread courtyard_directory();
	//thread courtyard_intro_elevator_guys();

	// --Wait until elevator guys are dead and player has hit trigger to move on to courtyard.--
	flag_wait_all( "courtyard_intro_rorke_done", "courtyard_intro_patrol_dead" );
	flag_clear( "stealth_broken" );
	
	while ( !stealth_is_everything_normal() )
	{
		waitframe();
	}	
	
	flag_clear( "_stealth_spotted" );
	
	level.allies[ level.const_rorke ] thread courtyard_rorke();
	
	wait( 0.5 );
	thread autosave_stealth();
}

//unload starting transient fastfile upon building entry
courtyard_transient_unload()
{
	flag_wait( "courtyard_transient_unload" );
	transient_unload( "cornered_start_tr" );
}

courtyard_directory()
{
	//TODO: Make this turn on and off if you backtrack.
	
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameLoopResident( "cornered_directory" );
	
	flag_wait( "move_to_office_a_half_wall" );
	StopCinematicInGame();
}

courtyard_intro_rorke()
{
	level endon( "rorke_killed" );
	self endon( "death" );

	self.shootstyle	   = "single";
	self.oldgoalradius = self.goalradius;
	self.goalradius	   = 16;
	self set_battlechatter( false );
	
	// --Move to janitor cart.--
	node = GetNode( "cy_rorke_01", "targetname" );
	self SetGoalNode( node );
	
	flag_wait( "courtyard_intro_check_stairs" );
	
	// --Move to hallway stairs.--
	animnode = getstruct( "courtyard_entry_animnode", "targetname" );
	animnode anim_reach_solo( self, "cornered_courtyard_rail_check" );
	if ( !flag( "move_to_courtyard_new" ) )
	{
		animnode anim_single_solo( self, "cornered_courtyard_rail_check" );
	}
	
	node = GetNode( "hallway_stairs_rorke", "targetname" );
	self SetGoalNode( node );
	
	// --Player has caught up, give player a chance to shoot.--
	flag_wait( "move_to_courtyard_entrance" );
	node = GetNode( "hallway_stairs2_rorke", "targetname" );
	self SetGoalNode( node );
	wait( 5.0 );

	// --Kill guys--
	if ( !flag( "courtyard_intro_patrol_dead" ) )
	{
		level notify( "rorke_stealth_end" );
		self.maxsightdistsqrd  = 8000 * 8000;
		self.ignoreall		   = false;
		self.ignoresuppression = true;
		self.dontevershoot	   = undefined;
		self.baseaccuracy	   = 5000000;
		
		ai1 = get_living_ai( "courtyard_intro_guys_elevator", "script_noteworthy" );
		ai2 = get_living_ai( "courtyard_intro_guys_elevator_2", "script_noteworthy" );
	
		if ( IsDefined( ai1 ) && IsAlive( ai1 ) )
		{
			while ( IsAlive( ai1 ) )
			{
				self.favoriteenemy = ai1;
				ai1.threatbias	   = 20000;
				ai1.ignoreme	   = false;
				ai1.dontattackme   = undefined;
				ai1.health		   = 1;
				wait( 0.25 );			
			}
			wait( 0.5 );
		}
		
		if ( IsDefined( ai2 ) && IsAlive( ai2 ) )
		{
			while ( IsAlive( ai2 ) )
			{
				self.favoriteenemy = ai2;
				ai2.threatbias	   = 20000;
				ai2.ignoreme	   = false;
				ai2.dontattackme   = undefined;
				ai2.health		   = 1;
				wait( 0.25 );
			}
		}
		
		wait( 0.5 );
		flag_clear( "stealth_broken" );
		self thread ally_stealth_settings();
	}
	
	flag_set( "courtyard_intro_rorke_done" );
}

courtyard_intro_ally_vo()
{
	// --Moving down hallway.--
	
	// --At stairs.--
	flag_wait( "move_to_courtyard_new" );
	
	if ( !flag( "_stealth_spotted" ) && !flag( "courtyard_intro_patrol_dead" ) )
	{
		//Merrick: Drop 'em.
		level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_dropem" );
	}
	   
	flag_wait( "courtyard_intro_patrol_dead" );
	wait( 0.25 );
	//Merrick: Clear.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_clear" );
}

/*courtyard_intro_baker()
{
	level endon( "baker_killed" );
	self endon( "death" );
	
	self.shootstyle = "single";
	self courtyard_intro_baker_move_to_exit();
}

courtyard_intro_baker_move_to_exit()
{
	self endon( "death" );
	
	// --move out of sight--
	node = GetNode( "hallway_exit_baker", "targetname" );
	self thread courtyard_intro_baker_exit();
	self thread send_to_node_and_set_flag_if_specified_when_reached( node, "baker_at_hallway_exit" );
}*/

courtyard_intro_baker_exit()
{
	level endon( "baker_killed" );
	self endon( "death" );
	
	new_node = GetNode( "courtyard_baker_wait", "targetname" );
	
	//flag_wait( "baker_at_hallway_exit" );
	flag_wait( "inverted_baker_done" );

	anim_node		 = getstruct( "elevator_script_node", "targetname" );
	anim_node.angles = ( 0, 0, 0 );
	
	anim_node anim_first_frame_solo( self, "baker_enter_junction" );
	
	self SetGoalPos( self.origin );
	self SetGoalNode( new_node );
}

courtyard_intro_elevator_guys()
{
	array_spawn_function_targetname( "courtyard_intro_elevator_guy", ::courtyard_intro_elevator_guy );
	flag_wait( "courtyard_intro_goto_elevator" );
	array_spawn_targetname( "courtyard_intro_elevator_guy", true );
}

courtyard_intro_elevator_guy()
{
	self.grenadeammo = 0;
	self.allowdeath	 = true;
	self.health		 = 1;
	self thread courtyard_intro_elevator_guy_fail();
	self stealth_pre_spotted_function_custom( ::bar_spotted_func ); //don't wait before telling others.
	
	// running custom spotted function to not run battlechatter on axis.  Battle chatter is set in alert above.
	array			   = [];
	array[ "hidden"	 ] = maps\_stealth_behavior_enemy::enemy_state_hidden;
	array[ "spotted" ] = ::custom_bar_enemy_state_spotted;
	self maps\_stealth_behavior_enemy::enemy_custom_state_behavior( array );

	self endon( "damage" );
	self endon( "death" );
	self endon( "_stealth_spotted" );

	self.animname = "generic";
	animnode	  = getstruct( "courtyard_lobby_elevator_door_r_dest", "targetname" );

	//self waittill( "_patrol_reached_path_end" );
	
	if ( self.script_noteworthy == "courtyard_intro_guys_elevator" )
	{
		//animnode anim_reach_solo( self, "cornered_courtyard_elevator_enter" );
		animnode thread anim_single_solo( self, "cornered_courtyard_elevator_enter" );
		flag_set( "courtyard_intro_elevator_button" );
		
		self waittillmatch( "single anim", "elevator_open" );
		//flag_set( "courtyard_intro_elevator_button" );
		//thread maps\cornered_audio::aud_door( "elevator_open" ); //JZ - moving this to elevator because it was requested for elevator to open no matter what and this notetrack won't get called if guy dies.
		
		self waittillmatch( "single anim", "elevator_close" );
		flag_set( "elevator_guy1_done" );
		thread maps\cornered_audio::aud_door( "elevator_close" );
	}
	else
	{
		//animnode anim_reach_solo( self, "cornered_courtyard_elevator_enter_enemy2" );
		animnode thread anim_single_solo( self, "cornered_courtyard_elevator_enter_enemy2" );
	}

	self waittillmatch( "single anim", "end" );
	
	flag_wait( "cy_elevator_closed" );
	
	if ( IsAlive( self ) )
	{
		self Delete();
	}	
}

courtyard_intro_elevator_guy_fail()
{
	self endon( "death" );
	
	flag_wait( "_stealth_spotted" );
	
	// --if the elevator is closed, we don't care.--
	if ( flag( "cy_elevator_closed" ) )
	{
		self.ignoreall = true;
		self.ignoreme  = true;
		self Delete();
	}
	// --elevator is closing, wait for it to re-open--
	else if ( flag( "elevator_guy1_done" ) && !flag( "cy_elevator_closed" ) )
	{
		self disable_stealth_for_ai();
		
		flag_wait( "cy_elevator_open" );
		
		nodes = GetNodeArray( "elevator_guy_fail_node", "targetname" ); //array of 2 nodes
		
		if ( !IsNodeOccupied( nodes[ 0 ] ) )
		{
			self SetGoalNode( nodes[ 0 ] );
		}
		else
		{
			self SetGoalNode( nodes[ 1 ] );
		}	
	}
	// --not in elevator yet--
	else
	{
		self notify( "end_patrol" );
		self disable_stealth_for_ai();
		
		nodes = GetNodeArray( "elevator_guy_fail_node", "targetname" ); //array of 2 nodes
		
		if ( !IsNodeOccupied( nodes[ 0 ] ) )
		{
			self SetGoalNode( nodes[ 0 ] );
		}
		else
		{
			self SetGoalNode( nodes[ 1 ] );
		}	
	}

}

courtyard_intro_elevator()
{
	level endon( "cy_elevator_closed" );
	
	door_right = GetEnt( "courtyard_lobby_elevator_door_r", "targetname" );
	door_left  = GetEnt( "courtyard_lobby_elevator_door_l", "targetname" );

	door_left_clip	= GetEnt( "courtyard_lobby_elevator_door_l_clip", "targetname" );
	door_right_clip = GetEnt( "courtyard_lobby_elevator_door_r_clip", "targetname" );
	
	orig_r_org = door_right.origin;
	orig_l_org = door_left.origin;
		
	door_r_dest = getstruct( "courtyard_lobby_elevator_door_r_dest", "targetname" );
	door_l_dest = getstruct( "courtyard_lobby_elevator_door_l_dest", "targetname" );
	
	door_left_clip LinkTo( door_left );
	door_right_clip LinkTo( door_right );
	
	//this is to prevent the player from getting in the elevator while it's closing.	
	blocker = GetEnt( "courtyard_lobby_elevator_blocker", "targetname" );

	flag_wait( "courtyard_intro_elevator_button" );
	
	wait( 2.25 ); //guy presses button
	
	wait( 4.55 ); //door open
	flag_set( "courtyard_intro_elevator_opening" );
	
	door_right MoveTo( door_r_dest.origin, 1.5, .25, .4 );
	door_left MoveTo( door_l_dest.origin, 1.5, .25, .4 );
	
	wait( 0.95 );
	blocker NotSolid();
	blocker ConnectPaths();
	door_left_clip ConnectPaths();
	door_right_clip ConnectPaths();	
	
	// --start closing elevator--
	flag_wait( "elevator_guy1_done" );
	
	door_right MoveTo( orig_r_org, 1.25, .25, .4 );
	door_left MoveTo( orig_l_org, 1.25, .25, .4 );
	
	blocker Solid();
	blocker DisconnectPaths();	
	door_left_clip DisconnectPaths();
	door_right_clip DisconnectPaths();		

	for ( i = 0; i < 15; i++ )
	{
		wait( 0.1 );
		if ( flag( "_stealth_spotted" ) )
		{
			break;
		}
	}
	
	if ( !flag( "_stealth_spotted" ) )
	{
		flag_set( "cy_elevator_closed" );
		level notify( "cy_elevator_closed" );
	}
	
	// --player or ally shot while elevator is closing, reopen--
	door_right MoveTo( door_r_dest.origin, .75, .25, .2 );
	door_left MoveTo( door_l_dest.origin, .75, .25, .2 );
	
	wait( 0.5 );
	flag_set( "cy_elevator_open" );
	blocker NotSolid();
	blocker ConnectPaths();
	door_left_clip ConnectPaths();
	door_right_clip ConnectPaths();	
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// Courtyard entry
/////////////////////////////////////////////////////////////////////////////////////////////////
courtyard_rorke()
{
	level endon( "rorke_killed" );

	thread maps\_stealth_visibility_system::system_event_change( "hidden" );
	thread custom_bar_stealth_setting(); //changing corpse detect distances.
	
	// --Prep office--
	animnode = getstruct( "courtyard_office_entry_animnode", "targetname" );
	self thread add_magic_bullet_shield_if_off();
	thread courtyard_office_ally_vo();
	thread courtyard_office_a_doors();
	thread courtyard_office_enemies();
	thread courtyard_office_props();
	
	// --Move to directory sign--
	node = GetNode( "cy_rorke_02", "targetname" );
	self SetGoalNode( node );
	
	flag_wait( "move_to_office_door" );
	
	// --Move to office entrance--
	exploder( 13 );
	animnode anim_reach_solo( self, "cornered_courtyard_office_door_merrick_enter" );
	animnode anim_single_solo( self, "cornered_courtyard_office_door_merrick_enter" );
	
	if ( !flag( "baker_security_vo" ) )
	{
		animnode thread anim_loop_solo( self, "cornered_courtyard_office_door_merrick_idle", "stop_loop" );
	}
	flag_wait( "baker_security_vo" );
	
	// --Open office door and move to office front desk--
	animnode notify( "stop_loop" );
	waittillframeend;
	
	flag_set( "rorke_open_office_a" );
	thread autosave_by_name( "courtyard_office" );
	
	animnode thread anim_single_solo( self, "cornered_courtyard_office_door_merrick_exit" );
	flag_set( "courtyard_office_id_vo" );
	thread bar_prep();
		
			 //   timer    func 					  
	delayThread( 0.5	, ::courtyard_office_chopper );
	delayThread( 1		, ::setup_office_enemy_vo );
	
	thread maps\cornered_audio::aud_door( "carani" );
	
	wait( 3.0 );
	
	//self forceUseWeapon( "kriss", "primary" );
	self forceUseWeapon( "kriss+eotechsmg_sp+silencer_sp", "primary" );
	self.lastWeapon = self.weapon;	// needed to avoid animscript SRE later
	
	self waittillmatch( "single anim", "end" );
	
	
	// --Move into office and shoot--
	if ( !flag( "move_to_office_a_half_wall" ) )
	{
		node = self spawn_tag_origin();
		node thread anim_loop_solo( self, "CornerCrR_alert_idle", "stop_loop" );
		flag_wait( "move_to_office_a_half_wall" );
		node notify( "stop_loop" );
		waittillframeend;
		node Delete();
	}
	//else
	//{		
	//	flag_wait( "move_to_office_a_half_wall" );
	//}
	
	animnode anim_single_solo( self, "cornered_courtyard_office_sneak_merrick_exit" );
	
	self.fixednode = false;
	vol			   = GetEnt( "office_rorke_gundown_volume", "targetname" );
	self SetGoalVolumeAuto( vol );
	if ( !flag( "_stealth_spotted" ) )
	{
		wait( 0.35 );
	}
		
	// --Kill guys--
	if ( !flag( "office_guys_dead" ) )
	{
		level notify( "rorke_stealth_end" );
		self.maxsightdistsqrd  = 8000 * 8000;
		self.ignoreall		   = false;
		self.ignoresuppression = true;
		self.dontevershoot	   = undefined;
		self.baseaccuracy	   = 5000000;
		self add_magic_bullet_shield_if_off();
		
		ai = get_living_ai_array( "office_guys", "script_noteworthy" );

		if ( IsAlive( level.office_guy_c ) )
		{
			if ( !IsAlive( self.enemy ) )
			{
				self.favoriteenemy = level.office_guy_c;	
			}
			while ( IsAlive( level.office_guy_c ) )
			{
				level.office_guy_c.dontattackme = undefined;
				level.office_guy_c.health		= 1;
				level.office_guy_c.threatbias	= 20000;
				level.office_guy_c.ignoreme		= false;
				wait( 0.75 );
			}
		}
		
		wait( 1 );
		
		while ( !flag( "office_guys_dead" ) )
		{		
			foreach ( actor in ai )
			{
				
				if ( !IsAlive( actor ) )
				{
					continue;
				}
				if ( !IsAlive( self.enemy ) )
				{
					self.favoriteenemy = actor;	
				}
				while ( IsAlive( actor ) )
				{
					actor.dontattackme = undefined;
					actor.health	   = 1;
					actor.threatbias   = 20000;
					actor.ignoreme	   = false;
					wait( 0.75 );
				}
				wait( 1 );
			}	
		}
		wait( 0.5 );
	}
	self thread ally_stealth_settings();
	
	// --Move to office exit--
	flag_wait( "office_guys_dead" );
	self enable_cqbwalk();
		
	self ClearGoalVolume();
	self.fixednode = true;

	thread maps\_stealth_visibility_system::system_event_change( "hidden" );
	delayThread( 0.1, ::custom_bar_stealth_setting ); //changing corpse detect distances.
	delayThread( 0.1, ::stealth_corpse_reset_time_custom, 10 ); //default is 30	
	
	animnode = getstruct( "rorke_exit_office_approach", "targetname" );
	animnode anim_reach_solo( self, "corner_standL_trans_CQB_IN_2" );
	
	if ( !flag( "move_across_bridge" ) )
	{
		animnode anim_single_solo( self, "corner_standL_trans_CQB_IN_2" );
		flag_set( "at_cy_exit_door" );
	}

	animnode = getstruct( "courtyard_office_exit_animnode", "targetname" );
	
	// --Move to bar entrance stairs--
	if ( !flag( "move_across_bridge" ) )
	{
		node = self spawn_tag_origin();
		node thread anim_loop_solo( self, "corner_standL_alert_idle", "stop_loop" );

		flag_wait( "move_across_bridge" );
		
		node notify( "stop_loop" );
		waittillframeend;
		node Delete();
	}
	else
	{
		flag_wait( "move_across_bridge" );
	}
	
	if ( flag( "at_cy_exit_door" ) )
	{
		animnode anim_single_solo( self, "cornered_courtyard_office_exit_merrick" );
	}
	
	thread maps\cornered_audio::aud_bar( "amb" );
	thread maps\cornered_audio::aud_bar( "stop" );
	
	animnode = getstruct( "rorke_bridge_anim", "targetname" );
	animnode anim_reach_solo( self, "cornered_courtyard_bridge_check" );
	
	if ( !flag( "go_bar_walker" ) )
	{
		animnode anim_single_solo( self, "cornered_courtyard_bridge_check" );
	}
	
	node = GetNode( "bar_entrance_stairs_rorke", "targetname" );
	self SetGoalNode( node );
	
	flag_wait( "rorke_bar_position" );
	flag_set( "courtyard_finished" );
	thread autosave_by_name( "courtyard_bridge" );
}

courtyard_office_enemies()
{	
								 //   key 			     func 						   
	array_spawn_function_targetname( "office_guys_new", ::courtyard_office_death );
	array_spawn_function_targetname( "office_guys_new", ::courtyard_office_enemy_anim );
	
	flag_wait( "rorke_open_office_a" );
	
	array_spawn_targetname( "office_guys_new", true );
}

courtyard_office_death()
{
	self waittill( "death" );
	
	flag_set( "office_guy_killed" );
}

courtyard_office_enemy_anim()
{
	//self endon( "damage" );
	self endon( "death" );
	//level endon( "office_guy_killed" );
	//self endon( "_stealth_spotted" );
	
	self stealth_pre_spotted_function_custom( ::bar_spotted_func ); //don't wait before telling others.
	animnode		= getstruct( "courtyard_office_animnode", "targetname" );
	self.allowdeath = true;
	self.animname	= "generic";
	
	// running custom spotted function to not run battlechatter on axis.  Battle chatter is set in alert above.
	array			   = [];
	array[ "hidden"	 ] = maps\_stealth_behavior_enemy::enemy_state_hidden;
	array[ "spotted" ] = ::custom_bar_enemy_state_spotted;
	self maps\_stealth_behavior_enemy::enemy_custom_state_behavior( array );
	
	if ( self.script_parameters == "office_guy_a" )
	{
		level.office_guy_a = self;
		animnode anim_first_frame_solo( self, "cornered_office_fireworks_crowd_guard1" );
		flag_wait( "rorke_open_office_a" );
		animnode thread anim_single_solo( self, "cornered_office_fireworks_crowd_guard1" );
	}
	if ( self.script_parameters == "office_guy_b" )
	{
		animnode anim_first_frame_solo( self, "cornered_office_fireworks_crowd_guard2" );
		flag_wait( "rorke_open_office_a" );
		animnode thread anim_single_solo( self, "cornered_office_fireworks_crowd_guard2" );
	}
	if ( self.script_parameters == "office_guy_c" )
	{
		level.office_guy_c = self;
		self.health		   = 1;
		animnode anim_first_frame_solo( self, "cornered_office_fireworks_crowd_guard3" );
		flag_wait( "rorke_open_office_a" );
		animnode thread anim_single_solo( self, "cornered_office_fireworks_crowd_guard3" );
	}
	if ( self.script_parameters == "office_guy_d" )
	{
		animnode anim_first_frame_solo( self, "cornered_office_fireworks_crowd_guard4" );
		flag_wait( "rorke_open_office_a" );
		animnode thread anim_single_solo( self, "cornered_office_fireworks_crowd_guard4" );
	}
	if ( self.script_parameters == "office_guy_e" )
	{
		animnode anim_first_frame_solo( self, "cornered_office_fireworks_crowd_guard5" );
		flag_wait( "rorke_open_office_a" );
		animnode thread anim_single_solo( self, "cornered_office_fireworks_crowd_guard5" );
	}
	
	flag_wait_either( "office_guy_killed", "_stealth_spotted" );
	self.fixednode = false;
	self StopAnimScripted();
	self disable_stealth_for_ai();
	
	self thread set_battlechatter( true );
	
	if ( self.script_parameters == "office_guy_d" || self.script_parameters == "office_guy_e" )
	{
		vol = GetEnt( "cy_office_enemy_volume", "targetname" );
		self SetGoalVolumeAuto( vol );
	}
	else
	{
		vol = GetEnt( "cy_office_enemy_volume_2", "targetname" );
		self SetGoalVolumeAuto( vol );
	}
	
}

courtyard_office_props()
{
	thread courtyard_office_chair();
	thread courtyard_office_glass();
}

courtyard_office_chair()
{
	animnode = getstruct( "courtyard_office_animnode", "targetname" );

	rig	  = spawn_anim_model( "courtyard_office" );
	chair = GetEnt( "office_a_conf_chair", "targetname" );

	animnode anim_first_frame_solo( rig, "cornered_office_fireworks_crowd_chair" );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	waitframe();
	chair.origin = j1_origin;
	chair.angles = j1_angles;

	waitframe();
	chair LinkTo( rig, "J_prop_1" );

	flag_wait( "rorke_open_office_a" );
	if ( IsAlive( level.office_guy_c ) && !flag( "_stealth_spotted" ) )
	{
		rig thread courtyard_rig_kill( level.office_guy_c );
		animnode thread anim_single_solo( rig, "cornered_office_fireworks_crowd_chair" );
		
		rig waittillmatch( "single anim", "end" );
	}
	
	chair Unlink();
	//if ( IsDefined( rig ) )
	//{
	//	rig Delete();
	//}
}

courtyard_rig_kill( enemy )
{
	enemy waittill( "death" );
	self StopAnimScripted();
	self Delete();	
}

courtyard_office_glass()
{
	animnode = getstruct( "courtyard_office_animnode", "targetname" );

	rig	  = spawn_anim_model( "courtyard_office" );
	glass = GetEnt( "office_a_conf_glass", "targetname" );

	animnode anim_first_frame_solo( rig, "cornered_office_fireworks_crowd_drink" );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	waitframe();
	glass.origin = j1_origin;
	glass.angles = j1_angles;

	waitframe();
	glass LinkTo( rig, "J_prop_1" );

	flag_wait( "rorke_open_office_a" );
	if ( IsAlive( level.office_guy_a ) && !flag( "_stealth_spotted" ) )
	{
		rig thread courtyard_rig_kill( level.office_guy_a );
		animnode thread anim_single_solo( rig, "cornered_office_fireworks_crowd_drink" );
		glass thread courtyard_glass_drop();
		
		wait( 11.15 );
		//glass thread courtyard_glass_drop();
		
		if ( IsDefined( rig ) && flag( "_stealth_spotted" ) )
		{
			rig StopAnimScripted();
		}
		else
		{
			wait( 15.45 );
			
			level notify( "glass_on_table" );
			
			if ( IsDefined( rig ) )
			{
				rig waittillmatch( "single anim", "end" );
			}
		}
	}
	
	glass Unlink();
	//if ( IsDefined( rig ) )
	//{
	//	rig Delete();
	//}
}

courtyard_glass_drop()
{
	level endon( "glass_on_table" );
	
	level.office_guy_a waittill( "death" );
	self Unlink();
	self PhysicsLaunchClient( self.origin + ( 0, 0, 4 ), ( 0, 0, -10 ) );
}

courtyard_office_a_doors()
{
	door_r		  = GetEnt( "office_a_door_right", "targetname" );
	door_l		  = GetEnt( "office_a_door_left", "targetname" );
	door_r_hinges = GetEntArray( "office_a_door_right_hinges", "targetname" );
	door_l_hinges = GetEntArray( "office_a_door_left_hinges", "targetname" );
	
	foreach ( hinge in door_r_hinges )
	{
		hinge LinkTo( door_r );
	}
	
	foreach ( hinge in door_l_hinges )
	{
		hinge LinkTo( door_l );
	}
	
	animnode = getstruct( "courtyard_office_entry_animnode", "targetname" );
	
	thread generic_prop_raven_anim( animnode, "courtyard_office", "cornered_courtyard_office_door_door", "office_a_door_right", undefined, undefined, "rorke_open_office_a" );
	
	flag_wait( "rorke_open_office_a" );
	
	wait( 0.65 );
	
	//door_r RotateYaw( 85, 1.5, .25, .75 );
	wait( 0.75 );
	door_r ConnectPaths();
}

courtyard_office_ally_vo()
{
	level.allies[ level.const_rorke ] endon( "death" );
	
	// --Moving into office.--
	
	flag_wait( "courtyard_office_id_vo" );
	wait( 8.75 );
	if ( !flag( "_stealth_spotted" ) )
	{
		//Merrick: I count 5 tangos ahead.
		level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_icount5tangos" );
	}
	
	flag_wait( "move_to_office_a_half_wall" );
	
	if ( !flag( "office_guy_killed" ) )
	{
		wait( 3.5 );
		//Merrick: Drop 'em.
		level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_dropem_2" );
	}
		
	// --Enemies are dead.--
	
	// --Moving across bridge.--
	flag_wait( "move_across_bridge" );
	wait( 1.9 );
	if ( flag( "at_cy_exit_door" ) )
	{
		//Merrick: Clear right.
		level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_clearright" );
	}
	wait( 2.25 );
	
	//Merrick: Hesh, check in.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_heshcheckin" );
	wait( 0.1 );
	//Hesh: Main elevators offline, secondaries still active.
	smart_radio_dialogue( "cornered_hsh_mainelevatorsoffline" );
	wait( 0.1 );
	//Merrick: Copy, see ya in 5.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_copyseeyain" );
}

setup_office_enemy_vo()
{
	wait( 2.0 );
	
	//if( flag( "stealth_broken" ) )
	if ( flag( "_stealth_spotted" ) )
	   return;
	
	ai = get_living_ai_array( "office_guys", "script_noteworthy" );
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) && IsDefined( guy.script_parameters ) && guy.script_parameters == "office_guy_a" )
		{
			level.office_guy_a			= guy;
			level.office_guy_a.animname = "generic";
		}
		if ( IsAlive( guy ) && IsDefined( guy.script_parameters ) && guy.script_parameters == "office_guy_b" )
		{
			level.office_guy_b			= guy;
			level.office_guy_b.animname = "generic";
		}
	}
	
	thread office_enemy_vo( level.office_guy_a, level.office_guy_b );
	level.office_guy_a thread stop_vo_on_event();
	level.office_guy_b thread stop_vo_on_event();
}

office_enemy_vo( guy1, guy2 )
{
	guy1 endon( "stop_my_vo" );
	guy2 endon( "stop_my_vo" );
	
	//Federation Soldier 1: Wow. Would you look at those fireworks?
	guy1 smart_dialogue( "cornered_saf1_wowwouldyoulook" );
	wait( 0.2 );
	//Federation Soldier 2: They make me miss home.
	guy2 smart_dialogue( "cornered_saf2_theymakememiss" );
	wait( 0.1 );
	//Federation Soldier 1: Me too.  I go on leave in one week.  Can't wait to go back.
	guy1 smart_dialogue( "cornered_saf1_metooigo" );
	wait( 0.3 );
	//Federation Soldier 2: You lucky bastard!  I have to wait two more months.
	guy2 smart_dialogue( "cornered_saf2_youluckybastardi" );
}

stop_vo_on_event()
{
	self waittill_any( "stop_vo", "death", "damage", "_stealth_spotted" );
	
	if ( IsDefined( self ) )
	{
		self notify( "stop_my_vo" );
		self StopSounds();
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// Side office, helicopter sweep
/////////////////////////////////////////////////////////////////////////////////////////////////
courtyard_office_chopper()
{
	courtyard_office_chopper = spawn_vehicle_from_targetname_and_drive( "courtyard_reception_office_a_chopper" );
	
	/*foreach( turret in courtyard_office_chopper.mgturret )
	{
		turret TurretFireDisable();
	}*/
	
	courtyard_office_chopper_spotlight_target = GetEnt( "courtyard_reception_office_a_chopper_spotlight_target", "targetname" );
	
	courtyard_office_chopper thread littlebird_handle_spotlight( 0.5, undefined, undefined, 50, courtyard_office_chopper_spotlight_target );
	
	flag_wait( "courtyard_reception_office_a_chopper_shine_spotlight" );
	wait( 4.0 );
	
	flag_set( "courtyard_reception_office_a_chopper_exit" );
	
	courtyard_office_chopper thread littlebird_spotlight_off();
	courtyard_office_chopper notify( "stop_littlebird_spotlight" );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// COURTYARD BRIDGE
/////////////////////////////////////////////////////////////////////////////////////////////////

//initiate load of end transient fastfile
courtyard_transient_load()

{
	flag_wait( "courtyard_transient_load" );
	transient_load( "cornered_end_tr" );
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// BAR ENCOUNTER
/////////////////////////////////////////////////////////////////////////////////////////////////
bar_prep()
{
	if ( !IsDefined( level.started_bar_from_startpoint ) )
	{
		flag_wait( "move_across_bridge" );
	}
	
	thread bar_props();
	thread bar_enemies();
	thread bar_light();
	thread bar_enemies_wave2();
	
	level.allies[ level.const_rorke ] thread bar_rorke_strobe_attack();
	level.allies[ level.const_rorke ] thread bar_rorke_standard_attack();
	level.allies[ level.const_rorke ] thread bar_rorke_kill_failsafe();
}

bar_rorke()
{
	level endon( "bar_strobe_starting" );
	level endon( "_stealth_spotted" );
	level endon( "bar_guy_killed" );
	self endon( "death" );
	
	if ( flag( "bar_guy_killed" ) || flag( "_stealth_spotted" ) || flag( "player_bar_sneaking" ) )
	{
		return;
	}
	
	level notify( "rorke_stealth_end" ); //don't want him to revert to his standard AI through ally_stealth_settings function.

	self.goalradius = 16;
	
	// --Move to bar entrance
	node = GetNode( "rorke_bar_floor_1", "targetname" );
	self SetGoalNode( node );
	self waittill( "goal" );
	self.disableplayeradsloscheck = true;

	wait( 0.5 );
	//Merrick: Big group.  We'll need to surprise them.
	self thread smart_dialogue( "cornered_mrk_biggroupwellneed" );
	
	// --Move downstairs to strobe position
	wait( 1.25 );
	node = GetNode( "bar_strobe_rorke", "targetname" );
	self SetGoalNode( node );
	
	// --Tell player to kill lights
	self waittill( "goal" );
	self.disableplayeradsloscheck = false;
	flag_wait( "player_on_bar_floor" );
	
	//Merrick: Take out the light.
	self smart_dialogue( "cornered_mrk_takeoutthelight" );
	//Merrick: Left side
	self smart_dialogue( "cornered_mrk_leftside" );
	
	self thread bar_rorke_warning_vo();
	
	// --Kill lights if player doesn't	
	wait( 8 );

	//Merrick: I've got it.
	self smart_dialogue( "cornered_mrk_ivegotit" );

	wait( 0.25 );
	fixture	   = GetEnt( "bar_light_fixture", "targetname" );
	light_spot = GetEnt( "bar_light_origin", "targetname" );
	
	node = GetNode( "bar_strobe_rorke_failsafe", "targetname" );
	self SetGoalNode( node );
	self waittill( "goal" );
	self.baseaccuracy = 5000000;
	wait( 0.40 );
	self SetLookAtEntity( light_spot );
	wait( 0.40 );
	MagicBullet( self.weapon, self GetTagOrigin( "tag_flash" ), light_spot.origin );
	wait( 0.05 );
	self.baseaccuracy = 1;
}

bar_rorke_warning_vo()
{
	level endon( "bar_strobe_starting" );
	level endon( "_stealth_spotted" );
	level endon( "bar_light_shot" );
	self endon( "death" );
	self endon( "gave_warning" );
	
	ai = get_living_ai_array( "bar_guys", "script_noteworthy" );
	
	while ( 1 )
	{
		foreach ( guy in ai )
		{
			traceDist	  = 4096.0; //should be big enough to cover bar room.
			playerEye	  = level.player GetEye();
			playerAngles  = level.player GetPlayerAngles();
			playerForward = VectorNormalize( AnglesToForward( playerAngles ) );
			
			trace = BulletTrace( playerEye, playerEye + ( playerForward * traceDist ), true, level.player, true );
			
			if ( IsDefined( trace[ "entity" ] ) && trace[ "entity" ] == guy )
			{
				//Merrick: No. Hit the light. 
				self smart_dialogue( "cornered_mrk_nohitthelight" );
				self notify( "gave_warning" );
			}
		}
	
		wait( 0.05 );
	}
	
}

bar_rorke_strobe_attack()
{
	self endon( "death" );
	
	flag_wait( "bar_light_shot" );
	level notify( "bar_strobe_starting" );
	
	// --Call for strobe
	wait( 0.35 );
	//Merrick: Strobes on.
	self smart_dialogue( "cornered_mrk_strobeson" );
	thread bar_strobe_player_on();
	thread bar_strobe_player_force_off();
	thread bar_strobe_ally();
	if ( !flag( "bar_enemies_reacted" ) )
	{
		self.fixednode = true;
		disable_stealth_system();
		
		// --Help kill guys
		node = GetNode( "bar_gundown_rorke", "targetname" );
		self SetGoalNode( node );
	}
	
	//Merrick: Take 'em down
	self smart_dialogue( "cornered_mrk_takeemdown" );
	
	//If player tries to sneak through with strobe off, ::bar_rorke_kill_failsafe will make Rorke vulnerable.
	//But that function ends on strobe on which will continue this.
	
	flag_wait_or_timeout( "strobe_on", 8 );
	self waittill( "goal" );
	wait( 0.4 );
	
	vol = GetEnt( "rorke_bar_volume", "targetname" );
	self SetGoalVolumeAuto( vol );
	
	self add_magic_bullet_shield_if_off();
	self.maxsightdistsqrd  = 8000 * 8000;
	self.ignoreall		   = false;
	self.ignoresuppression = true;
	self.dontevershoot	   = undefined;
	self.baseaccuracy	   = 5000000;
	
	ai = get_living_ai_array( "bar_guys", "script_noteworthy" );
	
	while ( !flag( "bar_guys_new_dead" ) )
	{
		ai	  = array_removeDead( ai );
		actor = getClosest( self.origin, ai );
		
		if ( !IsAlive( actor ) )
		{
			wait( 0.05 );
			continue;
			
		}
		if ( !IsAlive( self.enemy ) )
		{
			self.favoriteenemy = actor;	
		}
		if ( IsAlive( actor ) )
		{
			self.ignoreall	   = false;
			actor.dontattackme = undefined;
			actor.health	   = 1;

			actors		= [];
			actors[ 0 ] = actor;
			waittill_dead( actors, 1 ); //don't need _or_dying because none of the AI have longdeath.
			//ai = array_removeDead( ai );
			
		}
		self.ignoreall = true;
		//wait( 0.7 );
		wait( 1.0 );
	}
	
	// --Wait till wave 1 guys are dead
	level notify( "bar_wave1_dead" );
	self ClearGoalVolume();
	wait( 1 );
	if ( !flag( "2nd_wave_standard" ) )
	{
		//Merrick: Check your corners.
		self smart_dialogue( "cornered_mrk_checkyourcorners" );
	}
	
	node = GetNode( "bar_corner_rorke", "targetname" );
	self SetGoalNode( node );
	self.ignoreall = true;
	
	flag_wait( "bar_wave2_failsafe" );
	wait( 3.4 );
	self.ignoreall = false;
	ai			   = get_living_ai_array( "bar_guys_2", "script_noteworthy" );
	
	while ( !flag( "bar_guys_new_2_dead" ) )
	{
		ai	  = array_removeDead( ai );
		actor = getClosest( self.origin, ai );
		
		if ( !IsAlive( actor ) )
		{
			wait( 0.05 );
			continue;
		}
		if ( !IsAlive( self.enemy ) )
		{
			self.favoriteenemy = actor;	
		}
		if ( IsAlive( actor ) )
		{
			self.ignoreall	   = false;
			actor.dontattackme = undefined;
			actor.health	   = 1;

			actors		= [];
			actors[ 0 ] = actor;
			waittill_dead( actors, 1 );
			//ai = array_removeDead( ai );
			
		}
		self.ignoreall = true;
		//wait( 0.7 );
		wait( 1.0 );
	}

	wait( 0.5 );
	
	//Merrick: Clear.
	self smart_dialogue( "cornered_mrk_clear" );
	wait( 0.75 );
	
	//Merrick: Strobes off.  This way.
	if ( flag( "strobe_on" ) )
	{
		self smart_dialogue( "cornered_mrk_strobesoffthisway" );
	}
	else
	{
		level.player SetWeaponHudIconOverride( "actionslot1", "" );
	}
	
	flag_set( "activate_strobe_off_failsafe" );
	
	self thread bar_rorke_move_on();
	
	wait( 1 );
	if ( flag( "strobe_on" ) )
	{
		level.player display_hint( "turn_off_strobe" );
	}
}

bar_rorke_standard_attack()
{
	// This will start if player shoots AI without shooting light.
	// This will end if player turns on strobe.

	level endon( "bar_strobe_starting" );
	
	// gets set if you shoot a guy without shooting light.
	flag_wait( "bar_enemies_reacted" );
	
	vol = GetEnt( "rorke_bar_volume", "targetname" );
	self SetGoalVolumeAuto( vol );
	
	// light shouldn't be shot but just a precaution.
	if ( !flag( "bar_light_shot" ) )
	{
		self thread bar_rorke_vulnerable();
	}
	
	wait( 4 );
	flag_set( "2nd_wave_standard" );
	
	flag_wait_all( "bar_guys_new_dead", "bar_guys_new_2_dead" );
	
	//vol = GetEnt( "bar_rorke_end_volume", "targetname" );
	
	//self SetGoalVolumeAuto( vol );
		
	// -- You win.	
	//flag_wait( "bar_guys_3_dead" );
	
	self ClearGoalVolume();
	self thread add_magic_bullet_shield_if_off();
	
	//Merrick: That wasn't a smart move.  This way.
	self smart_dialogue( "cornered_mrk_thatwasntasmart" );
	wait( 2 );
	
	self thread bar_rorke_move_on();
}

bar_rorke_move_on()
{
	// --Move downstairs, past bar
	node = GetNode( "bar_rorke", "targetname" );
	self SetGoalNode( node );
	
	flag_wait( "move_to_junction_entrance" );
	
	thread start_optional_objective();
	
	flag_set( "bar_finished" );
}

bar_rorke_vulnerable()
{
	disable_stealth_system();
	level thread mission_failed_watcher();
	self thread stop_magic_bullet_shield_if_on();
	self.maxsightdistsqrd = 8000 * 8000;
	self.ignoreall		  = false;
	self.dontevershoot	  = undefined;
	self.baseaccuracy	  = 1;

	// -- Delete hide volumes	
	stealth_volumes = GetEntArray( "stealth_clipbrush_custom", "targetname" );
	array_delete( stealth_volumes );
}

bar_rorke_kill_failsafe()
{
	self endon( "death" );
	level endon( "strobe_on" );
	
	// If the player shoots out the light and then tries to sneak through.
	flag_wait( "bar_light_shot" );
	
	// Player must be in bar to shoot out light.
	flag_clear( "player_left_bar" );
	
	// Now wait for player to try and leave.
	flag_wait_any( "bar_wave2_failsafe", "player_left_bar" );
	
	self thread bar_rorke_vulnerable();
	
	wait( 0.1 );
	
	self.baseaccuracy = 0.1; //Ally should suck and get killed since it's dark.
}

tv_play( tv )
{
	tv endon( "damage" );
	
	thread tv_stop( tv );
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	
	while ( true )
	{
		CinematicInGame( "london_football" );
		tv PlayLoopSound( "scn_london_soccer_tv_loop" );
		
		waitframe();
		
		while ( IsCinematicPlaying() )
		{
			waitframe();
		}
	}
}

tv_stop( tv )
{
	tv waittill( "damage" );
	
	StopCinematicInGame();
	tv StopLoopSound();
}

bar_light()
{
//	fixture = GetEnt( "bar_light_fixture", "targetname" );
//	volume	= GetEnt( "bar_light_volume", "targetname" );
	tv = GetEnt( "interactive_tv", "targetname" );
	light	= GetEnt( "bar_script_light", "targetname" );
	assist	= GetEnt( "bar_light_aim_assist", "targetname" );
	assist NotSolid();
	
	thread tv_play( tv );
	
	assist EnableAimAssist();
	
//	volume waittill( "trigger" );
	tv waittill( "damage" );
	flag_set( "_stealth_spotted" );
	flag_set( "bar_light_shot" );
	level notify( "bar_light_shot" );
	
	thread bar_pre_strobe_darkness();
	
	activate_exploder( "light_blowout_bar" );
	stop_exploder( "light_halogen_bar" );
	
	thread maps\cornered_audio::aud_bar( "light" );
	thread maps\cornered_audio::aud_bar( "panic" );
	thread maps\cornered_audio::aud_bar( "shuffle" );
	
//	fixture SetModel( "cnd_portable_light_off" );
	light SetLightIntensity( 0 );
	
	assist DisableAimAssist();
	assist Delete();
	
	wait( 2.25 );
	
	thread bar_panic_bullets();
}

bar_pre_strobe_darkness()
{
	level endon( "strobe_on" );
	level endon( "bar_wave2_failsafe" );
	level endon( "strobe_off_failsafe" );
	
	maps\_utility::vision_set_fog_changes( "cornered_strobe", .5 );
	shader	= undefined;
	overlay = maps\_hud_util::get_optional_overlay( shader );
	overlay FadeOverTime( 0.05 );
	overlay.alpha = 1;
	overlay.sort  = -100;
	
	look_target = getstruct( "bar_door_look", "targetname" );
	fade		= false;
	while ( 1 )
	{
		
		dist  = Distance2D( level.player.origin, look_target.origin );
		scale = dist / 500;				  //max distance I want for max alpha.
		scale = clamp( scale, 0.5, 0.9 ); //Anything over 500 is clamped to 1.
		
		// --player has turned from door to bar - Raise alpha to 1.0 --
		if ( !level.player WorldPointInReticle_Circle( look_target.origin, 90, 400 ) && !fade )
		{
			fade = true;
			
			step = 1 - overlay.alpha;
			
			for ( i = 0; i < 5; i++ )
			{
				overlay.alpha = overlay.alpha + ( step / 5 );
				wait( 0.05 );
			}
			
			overlay.alpha = 1.0;
		}
		// --player has turned towards door, fade down alpha --
		else if ( level.player WorldPointInReticle_Circle( look_target.origin, 90, 400 ) && fade )
		{
			fade = false;
			
			step = 1 - scale;
			
			for ( i = 0; i < 5; i++ )
			{
				overlay.alpha = overlay.alpha - ( step / 5 );
				wait( 0.05 );
			}
		}
		// --player is already looking at the door, but changing distance --
		else if ( level.player WorldPointInReticle_Circle( look_target.origin, 90, 400 ) )
		{
			overlay.alpha = scale;
		}
		
		waitframe();
	}
}		

bar_strobe_player_on()
{
	level endon( "strobe_off_failsafe" );
	
	level.player display_hint( "turn_on_strobe" );
	thread bar_strobe_vision();
	
	level.player SetWeaponHudIconOverride( "actionslot1", "hud_icon_strobe" );
	RefreshHudAmmoCounter();
		
	while ( 1 )
	{
		level.player NotifyOnPlayerCommand( "activate_strobe", "+actionslot 1" );
		
		level.player waittill( "activate_strobe" );
		flag_set( "strobe_on" );
		level notify( "strobe_on" );
		thread maps\cornered_audio::aud_bar( "strobe" );
		flag_clear( "strobe_off" );
		
		level.strobe_tag = Spawn( "script_model", ( 0, 0, 0 ) );
		level.strobe_tag SetModel( "tag_origin" );
		level.strobe_tag.angles = level.player.angles;
		level.strobe_tag LinkToPlayerView( level.player, "tag_flash", ( 2, 0.5, 0.5 ), ( 0, 0, 0 ), false );
		PlayFXOnTag( level._effect[ "cnd_spotlight_strobe" ], level.strobe_tag, "tag_origin" );
				
		wait( 0.05 );
		level.player NotifyOnPlayerCommand( "deactivate_strobe", "+actionslot 1" );
	
		level.player waittill( "deactivate_strobe" );
		flag_set( "strobe_off" );
		thread maps\cornered_audio::aud_bar( "strobe_stop" );
		flag_clear( "strobe_on" );
	
		waitframe();
		level.strobe_tag Delete();
		wait( 0.05 );
	}
}

bar_strobe_vision()
{
	level endon( "strobe_off_failsafe" );
	
	// -- Before player moves towards bar exit.
	while ( !flag( "bar_wave2_failsafe" ) )
	{
		// --In the bar.
		if ( flag( "bar_wave2_failsafe" ) )
		{
			break;
		}
		else
		{
			bar_strobe_vision_bar();
		}
	
		// --Left the bar through the entry door.  Trigger clears flag.
		maps\_utility::vision_set_fog_changes( "cornered_04", .5 );
		maps\_hud_util::fade_in( 0.05 );
		
		if ( flag( "bar_wave2_failsafe" ) )
		{
			break;
		}
		else
		{
			bar_strobe_vision_outside_bar();
		}
	}
	
	maps\_hud_util::fade_in( 0.05 );
	
	// -- After player moves towards bar exit.
	while ( 1 )
	{
		//  --Strobe on
		if ( !flag( "strobe_on" ) )
		{
			flag_wait( "strobe_on" );
			maps\_utility::vision_set_fog_changes( "cornered_strobe", .5 );
			wait( 0.05 );		
		}
		
		//  --Strobe off
		flag_wait( "strobe_off" );
		maps\_utility::vision_set_fog_changes( "cornered_04", .5 );
			
		wait( 0.05 );	
	}
}

bar_strobe_vision_bar()
{
	level endon( "player_left_bar" );
	level endon( "bar_wave2_failsafe" );
	
	while ( flag( "player_entered_bar" ) )
	{
		//  --Strobe on
		flag_wait( "strobe_on" );
		maps\_hud_util::fade_in( 0.05 );
		maps\_utility::vision_set_fog_changes( "cornered_strobe", .5 );
		wait( 0.05 );
		
		//  --Strobe off
		flag_wait( "strobe_off" );
		thread custom_fade_out( 0.05, undefined, 0.5 );		
		wait( 0.05 );
	}
	
	//level notify( "left_bar" );
}

bar_strobe_vision_outside_bar()
{
	level endon( "player_entered_bar" );
	level endon( "bar_wave2_failsafe" );
	
	while ( flag( "player_left_bar" ) )
	{
		//  --Strobe on
		flag_wait( "strobe_on" );
		maps\_utility::vision_set_fog_changes( "cornered_strobe", .5 );
		wait( 0.05 );
		
		//  --Strobe off
		flag_wait( "strobe_off" );
		maps\_utility::vision_set_fog_changes( "cornered_04", .5 );
		
		wait( 0.05 );
	}	
	
	//level notify( "entered_bar" );
}

bar_strobe_player_force_off()
{
	level waittill( "strobe_off_failsafe" );
	
	if ( IsDefined( level.strobe_tag ) )
{
		flag_set( "strobe_off" );
		thread maps\cornered_audio::aud_bar( "strobe_stop" );
		flag_clear( "strobe_on" );
	
		maps\_utility::vision_set_fog_changes( "cornered_04", 1.5 );
		level.strobe_tag Delete();

		level.player SetWeaponHudIconOverride( "actionslot1", "" );
	}
}

bar_strobe_ally()
{
	flag_wait( "strobe_on" );
	
	PlayFXOnTag( level._effect[ "cnd_ally_strobe" ], level.allies[ level.const_rorke ], "tag_flash" );
	
	flag_wait_all( "bar_guys_new_dead", "bar_guys_new_2_dead" );
	wait( 1.5 );
	StopFXOnTag( level._effect[ "cnd_ally_strobe" ], level.allies[ level.const_rorke ], "tag_flash" );
}

bar_enemies()
{
	level.bar_animnode = getstruct( "courtyard_bar_animnode", "targetname" );
	
								 //   key 	      func 			   
	array_spawn_function_targetname( "bar_guys", ::bar_enemy_anim );
	array_spawn_function_targetname( "bar_guys", ::bar_death );
	
	//flag_wait( "courtyard_finished" );
	
	array_spawn_targetname( "bar_guys", true );
	
	wait( 1 );
	
	thread bar_enemy_vo();
	thread bar_enemy_panic_vo();
	thread bar_enemy_strobe_vo();
}

bar_death()
{
	self waittill( "death" );
	
	flag_set( "bar_guy_killed" );
}

bar_spotted_func()
{
	wait( 0.1 ); //default is 2.25
}

bar_enemy_anim()
{
	self endon( "death" );
	
	self.allowdeath = true;
	self.animname	= "generic";
	self stealth_pre_spotted_function_custom( ::bar_spotted_func ); //don't wait before telling others.
	
	// running custom spotted function to not run battlechatter on axis.
	array			   = [];
	array[ "hidden"	 ] = maps\_stealth_behavior_enemy::enemy_state_hidden;
	array[ "spotted" ] = ::custom_bar_enemy_state_spotted;

	self maps\_stealth_behavior_enemy::enemy_custom_state_behavior( array );
	
	self thread bar_enemy_kill_failsafe();
	
	// Set up a few guys for talking.
	if ( IsDefined( self.script_parameters ) && self.script_parameters == "e09" )
	{
		level.bar_guy9 = self;
		self thread stop_vo_on_event();
	}
	if ( IsDefined( self.script_parameters ) && self.script_parameters == "e10" )
	{
		level.bar_guy10 = self;
		self thread stop_vo_on_event();
	}
	if ( IsDefined( self.script_parameters ) && self.script_parameters == "e11" )
	{
		level.bar_guy11 = self;
		self thread stop_vo_on_event();
	}
	
	// Set up bar scene idles.
	if ( IsDefined( self.script_parameters ) )
	{
		if ( self.script_parameters == "e09" || self.script_parameters == "e10" )
		{
			self bar_enemy_reach();
		}
		else
		{
			level.bar_animnode thread anim_loop_solo( self, "cornered_bar_" + self.script_parameters + "_idle", "stop_loop" );
		}
	}
		
	// Check if player breaks stealth.
	// --This occurs if player shoots someone with lights on.
	// --This also occurs if player shoots out light but doesn't turn on strobe.
	self bar_enemy_react();
	
	// React to strobe light.
	flag_wait( "strobe_on" );
	
	if ( self.script_parameters == "e01" || self.script_parameters == "e02" || self.script_parameters == "e04" )
	{
		// If they played a stealth break reaction, they shouldn't do a custom strobe reaction.
		if ( !flag( "bar_enemies_reacted" ) )
		{
			level.bar_animnode notify( "stop_loop" );
			self StopAnimScripted(); //need to stop immediately.
			level.bar_animnode anim_single_solo( self, "cornered_bar_" + self.script_parameters + "_react_strobe" );
			self thread bar_enemy_strobe_react();
		}
		else
		{
			self thread bar_enemy_strobe_react();
		}
	}
	else
	{
		self thread bar_enemy_strobe_react();
	}
	
	self.ignoreall	   = true;
	self.dontevershoot = true;

}

bar_enemy_reach()
{
	self endon( "death" );
	self endon( "enemy_spotted" + self.script_parameters );
	//level endon( "bar_light_shot" );
	level endon( "_stealth_spotted" );
	level endon( "strobe_on" );
	
	self.goalradius = 16;
	self waittill( "_patrol_reached_path_end" );
	level.bar_animnode thread anim_reach_solo( self, "cornered_bar_" + self.script_parameters + "_idle" );
	
	self waittill( "anim_reach_complete" );
	
	flag_set( self.script_parameters + "_path_done" );
	
	level.bar_animnode thread anim_loop_solo( self, "cornered_bar_" + self.script_parameters + "_idle", "stop_loop" );
}

bar_enemy_react()
{
	self endon( "death" );
	self endon( "enemy_spotted" + self.script_parameters );
	level endon( "strobe_on" );
	
	if ( flag( "strobe_on" ) )
	{
		return;
	}
		
	while ( 1 )
	{
		if ( flag( "_stealth_spotted" ) || flag( "bar_guy_killed" ) || flag( "player_bar_sneaking" ) )
		{
			level.bar_animnode notify( "stop_loop" );
			self notify( "stop_vo" );
			
			// Lights are off, get ready for strobe instead of reacting.
			if ( flag( "bar_light_shot" ) )
			{
				self.ignoreall = true;
				self disable_stealth_for_ai();
				self.dontevershoot = true;
				
				if ( self.script_parameters == "e01" || self.script_parameters == "e02" || self.script_parameters == "e04" )
				{
					level.bar_animnode anim_first_frame_solo( self, "cornered_bar_" + self.script_parameters + "_react_strobe" );
				}
			}
			// Lights are on, play reaction anim if available then go to AI.
			else
			{				
				self thread set_battlechatter( true );
				
				if ( self.script_parameters == "e01" || self.script_parameters == "e02" || self.script_parameters == "e03" || self.script_parameters == "e04" || self.script_parameters == "e07" || self.script_parameters == "e11" )
				{
					level.bar_animnode anim_single_solo( self, "cornered_bar_" + self.script_parameters + "_react_shoot" );
				}
				else if ( self.script_parameters == "e09" ) // he has to check to see if he finished pathing
				{
					if ( flag( self.script_parameters + "_path_done" ) )
				{
					level.bar_animnode anim_single_solo( self, "cornered_bar_" + self.script_parameters + "_react_shoot" );
				}
				}
				else
				{
					level.bar_animnode notify( "stop_loop" );
					self StopAnimScripted();
					waittillframeend;					
				}
				
				self.ignoreall = false;
				self disable_stealth_for_ai();
				self.dontevershoot = undefined;
				
				// They'll need to stop shooting if lights go out later than intended.
				self thread bar_enemy_lights_out_failsafe();
				
				flag_set( "bar_enemies_reacted" );
				
				self notify( "enemy_spotted" + self.script_parameters );
			}
		}
		
		wait( 0.05 );
	}
}

bar_enemy_lights_out_failsafe()
{
	self endon( "death" );
	self endon( "end_failsafe" );
	
	// If the player shoots out the light after starting regular combat.
	while ( 1 )
	{
		if ( flag( "bar_light_shot" ) )
		{
			wait( RandomFloatRange( 0.25, 1.25 ) );
			
			self.ignoreall	   = true;
			self.dontevershoot = true;
			self.favoriteenemy = undefined;
			self thread set_battlechatter( false );
			
			self notify( "end_failsafe" );
		}
		
		wait( 0.05 );
	}
}

bar_enemy_kill_failsafe()
{
	self endon( "death" );
	level endon( "strobe_on" );
	
	// If the player shoots out the light and then tries to sneak through.
	flag_wait( "bar_light_shot" );
	
	// Player must be in bar to shoot out light.
	flag_clear( "player_left_bar" );
	
	// Did player run into me?
	//if ( self.script_parameters == "e06" )
	//{
	//	self thread bar_enemy_player_touch();
	//}
	
	// Now wait for player to try and leave or pass a threshold.
	flag_wait_any( "bar_wave2_failsafe", "player_left_bar", "player_touched_enemy", "player_bar_sneaking" );
	
	self notify( "enemy_spotted" + self.script_parameters );
	flag_set( "bar_enemies_reacted" );
	
	wait( 0.25 );
	
	level.bar_animnode notify( "stop_loop" );
	self StopAnimScripted();
	self.ignoreall	   = false;
	self.dontevershoot = undefined;
	self thread set_battlechatter( true );	
	self disable_stealth_for_ai();
}

/*bar_enemy_player_touch()
{
	self endon( "death" );
	level endon( "strobe_on" );
	self endon( "touched" );
	
	dist = Distance2D( level.player.origin, self.origin );
	
	while ( dist >= 42 )
	{
		wait( 0.1 );
		dist = Distance2D( level.player.origin, self.origin );
	}
	
	wait( 0.1 );
	
	flag_set( "player_touched_enemy" );
	self notify( "touched" );
}*/

bar_enemy_strobe_react()
{
	self endon( "death" );
	
	guys	  = [];
	guys[ 0 ] = level.player;
	guys[ 1 ] = level.allies[ level.const_rorke ];
	
	while ( 1 )
	{
		// --Maybe move around in the dark. Only want wave 1 to do this.
		nodes = GetNodesInRadius( self.origin, 32, 16, 90 );
		if ( nodes.size && self.script_noteworthy == "bar_guys" )
		{
			node = nodes[ RandomInt( nodes.size ) ];
			if ( !IsNodeOccupied( node ) )
			{
				self set_goalradius( 20 );
				self set_goal_node( node );
			}
		}
		
		//behavior while strobe is on.
		if ( !flag( "strobe_on" ) )
		{
			flag_wait( "strobe_on" );	
		}		
		
		//figure out facing.
		dirToEnemy = VectorNormalize( level.player.origin - self.origin );
		forward	   = AnglesToForward( self.angles );
		cosine	   = VectorDot( dirToEnemy, forward ); //determines forward/backward
		
		tangent = VectorCross( dirToEnemy, forward );
		sign	= VectorDot( tangent, forward ); //determines left/right
		//IPrintLn( "Sign is " + sign );
		
		//play appropriate animation.
		if ( cosine >= 0.7 ) //forward cos45
		{
			self thread anim_generic_loop( self, "cornered_bar_react_front", "stop_loop" );
			//Print3d( self.origin + ( 0, 0, 60 ), "Front", ( 1, 0, 0 ), 1, 1, 5000 );
		}
		else if ( cosine <= -0.7 ) //backward cos135			
		{
			self thread anim_generic_loop( self, "cornered_bar_react_rear", "stop_loop" );
			//Print3d( self.origin + ( 0, 0, 60 ), "Back", ( 1, 0, 0 ), 1, 1, 5000 );
		}
		else if ( sign >= 0.0 )
		{
			self thread anim_generic_loop( self, "cornered_bar_react_left", "stop_loop" );
			//Print3d( self.origin + ( 0, 0, 60 ), "Left", ( 1, 0, 0 ), 1, 1, 5000 );
		}
		else
		{
			self thread anim_generic_loop( self, "cornered_bar_react_right", "stop_loop" );
			//Print3d( self.origin + ( 0, 0, 60 ), "Right", ( 1, 0, 0 ), 1, 1, 5000 );
		}
			
		flag_wait( "strobe_off" );
		wait( RandomFloatRange( 0.75, 1.25 ) );
	
		self notify( "stop_loop" );
		self StopAnimScripted();
		waitframe();
	}
}

bar_enemies_wave2()
{
	array_spawn_function_targetname( "bar_guys_new_2", ::bar_enemy_wave2_behavior );
	
	flag_wait_any( "bar_wave2_failsafe", "2nd_wave_standard" );
	array_spawn_targetname( "bar_guys_new_2", true );
}

bar_enemy_wave2_behavior()
{
	self endon( "death" );
	
	self.ignoreall	   = true;
	self.dontevershoot = true;
	self.goalradius	   = 40;
	self stop_magic_bullet_shield_if_on();
	self.allowdeath = true;
	
	while ( !self CanSee( level.player ) )
	{
		wait( 0.05 );
	}
	
	wait( 0.75 );
	self thread bar_enemy_wave2_3_react();
}

bar_enemy_wave2_3_react()
{
	self endon( "death" );
	
	// Lights are off, get ready for strobe instead of reacting.
	if ( flag( "bar_light_shot" ) )
	{
		self thread bar_enemy_strobe_react();
	}
	// Lights are on, play reaction anim if available then go to AI.
	else
	{		
		self.ignoreall = false;
		self disable_stealth_for_ai();
		self.dontevershoot = undefined;
		
		// They'll need to stop shooting if lights go out later than intended.
		self thread bar_enemy_lights_out_failsafe();
		
		flag_set( "bar_enemies_reacted" );
			
		flag_wait( "strobe_on" );
		
		self thread bar_enemy_strobe_react();
		self.ignoreall	   = true;
		self.dontevershoot = true;
	}
}

bar_panic_bullets()
{
	level endon( "strobe_on" );

	bullet_source_01 = getstruct( "bar_bullet_source_01", "targetname" );
	bullet_source_02 = getstruct( "bar_bullet_source_02", "targetname" );
	bullet_source_03 = getstruct( "bar_bullet_source_03", "targetname" );
	
	bullet_01 = getstruct( "bar_bullet_01", "targetname" );
	bullet_02 = getstruct( "bar_bullet_02", "targetname" );
	bullet_03 = getstruct( "bar_bullet_03", "targetname" );
	
	wait( 2 );
	
	MagicBullet( "kriss", bullet_source_01.origin, bullet_01.origin );
	
	wait( 0.6 );
	
	MagicBullet( "kriss", bullet_source_02.origin, bullet_02.origin );

	wait( 0.25 );
	
	MagicBullet( "kriss", bullet_source_03.origin, bullet_03.origin );
	wait( 0.1 );
	MagicBullet( "kriss", bullet_source_03.origin, bullet_03.origin + ( 3, 0, 8 ) );
	wait( 0.1 );
	MagicBullet( "kriss", bullet_source_03.origin, bullet_03.origin + ( 0, 0, 13 ) );
	wait( 0.1 );
	MagicBullet( "kriss", bullet_source_03.origin, bullet_03.origin + ( -4, 0, 18 ) );
}

bar_props()
{
					   //   array1 	     array2       anime 				    
	thread bar_stool_anim( "bar_01_1" , "bar_01_2" , "cornered_bar_chair_e01" );
	thread bar_stool_anim( "bar_02a_1", "bar_02a_2", "cornered_bar_chair_e02a" );
	thread bar_stool_anim( "bar_02b_1", undefined  , "cornered_bar_chair_e02b" );
	thread bar_stool_anim( "bar_04_1" , "bar_04_2" , "cornered_bar_chair_e04" );
}

bar_stool_anim( array1, array2, anime )
{
	bar_animnode = getstruct( "courtyard_bar_animnode", "targetname" );
	rig			 = spawn_anim_model( "bar_chair" );
	
	obj1	  = undefined;
	obj1_clip = undefined;
	
	obj2	  = undefined;
	obj2_clip = undefined;
	
	if ( IsDefined( array1 ) )
	{
		obj1_array = GetEntArray( array1, "targetname" );	//grabs stool and clip
		foreach ( item in obj1_array )
		{
			if ( item.script_noteworthy == "stool" )
			{
				obj1 = item;
			}
			if ( item.script_noteworthy == "clip_stool" )
			{
				obj1_clip = item;
			}
		}
		
		obj1_clip LinkTo( obj1 );
	}
	
	if ( IsDefined( array2 ) )
	{
		obj2_array = GetEntArray( array2, "targetname" ); //grabs stool and clip
		foreach ( item in obj2_array )
		{
			if ( item.script_noteworthy == "stool" )
			{
				obj2 = item;
			}
			if ( item.script_noteworthy == "clip_stool" )
			{
				obj2_clip = item;
			}
		}
	
		obj2_clip LinkTo( obj2 );
	}

	bar_animnode anim_first_frame_solo( rig, anime );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	j2_origin = rig GetTagOrigin( "J_prop_2" );
	j2_angles = rig GetTagAngles( "J_prop_2" );
	
	waitframe();
	
	if ( IsDefined( obj1 ) )
	{
		obj1.origin = j1_origin;
		obj1.angles = j1_angles;
		obj1 LinkTo( rig, "J_prop_1" );
	}
	
	if ( IsDefined( obj2 ) )
	{
		obj2.origin = j2_origin;
		obj2.angles = j2_angles;
		obj2 LinkTo( rig, "J_prop_2" );
	}
	
	flag_wait( "strobe_on" );

	if ( !flag( "bar_enemies_reacted" ) )
	{
		bar_animnode anim_single_solo( rig, anime );
	}
}

bar_enemy_vo()
{
	level.bar_guy9 endon( "stop_my_vo" );
	level.bar_guy10 endon( "stop_my_vo" );
	level.bar_guy11 endon( "stop_my_vo" );

	//Federation Soldier 1: To the Federation!
	level.bar_guy9 smart_dialogue( "cornered_saf1_tothefederation" );
	//Federation Soldier 2: The Federation!
	level.bar_guy10 smart_dialogue( "cornered_saf2_thefederation" );
	//Federation Soldier 3: Yes!  The Federation!
	level.bar_guy11 smart_dialogue( "cornered_pmc3_yesthefederation" );
	
	wait( RandomFloatRange( 3.5, 6.0 ) );

	//Federation Soldier 3: When are the lights going to come back on?
	level.bar_guy11 smart_dialogue( "cornered_pmc3_whenarethelights" );
	//Federation Soldier 1: I haven't heard.
	level.bar_guy9 smart_dialogue( "cornered_saf1_ihaventheard" );
	//Federation Soldier 2: The fireworks look better with them moff.
	level.bar_guy10 smart_dialogue( "cornered_saf2_thefireworkslookbetter" );		

	wait( RandomFloatRange( 3.5, 6.0 ) );
	
	//Federation Soldier 2: Drink up.  The beer will get warm if they don't get the power back on soon.
	level.bar_guy10 smart_dialogue( "cornered_saf2_drinkupthebeer" );
	//Federation Soldier 3: That's the best order I've been given all day.
	level.bar_guy11 smart_dialogue( "cornered_pmc3_thatsthebestorder" );
	//Federation Soldier 1: <laughing>
	level.bar_guy9 smart_dialogue( "cornered_saf1_laughing" );
	
	wait( RandomFloatRange( 3.5, 6.0 ) );
	
	//Federation Soldier 1: This American tequila tastes terrible.
	level.bar_guy9 smart_dialogue( "cornered_saf1_thisamericantequilatastes" );
	//Federation Soldier 2: Their beer is worse.
	level.bar_guy10 smart_dialogue( "cornered_saf2_theirbeerisworse" );
	//Federation Soldier 3: I know.  It's like water. <laughing>
	level.bar_guy11 smart_dialogue( "cornered_pmc3_iknowitslike" );
}

bar_enemy_panic_vo()
{
	level endon( "strobe_on" );
	
	flag_wait( "bar_light_shot" );
	
	wait( 0.25 );
	
	ai	= get_living_ai_array( "bar_guys", "script_noteworthy" );
	
	panic_vo = [];
	//Federation Soldier 1: What the hell is going on?
	panic_vo[ 0 ] = "cornered_saf1_whatthehellis";
	//Federation Soldier 2: Who turned off the lights!?
	panic_vo[ 1 ] = "cornered_saf2_whoturnedoffthe";
	//Federation Soldier 3: What happened? 
	panic_vo[ 2 ] = "cornered_pmc3_whathappened";
	//Federation Soldier 1: Are we under attack?
	panic_vo[ 3 ] = "cornered_saf1_areweunderattack";
	//Federation Soldier 2: Get a repair crew up here!
	panic_vo[ 4 ] = "cornered_saf2_getarepaircrew";
	//Federation Soldier 3: Someone get the lights on!
	panic_vo[ 5 ] = "cornered_pmc3_someonegetthelights";
	//Federation Soldier 1: Is anyone there?
	panic_vo[ 6 ] = "cornered_saf1_isanyonethere";

	vo_index = 0;
	
	while ( 1 )
	{
		ai = array_removeDead( ai );
		array_randomize( ai );
		
		if ( !IsAlive( ai[ 0 ] ) )
		{
			wait( 0.05 );
			continue;
		}
		if ( IsAlive( ai[ 0 ] ) )
		{
			if ( vo_index >= panic_vo.size )
			{
				vo_index = 0;	
			}
			vo = panic_vo[ vo_index ];
			
			ai[ 0 ] smart_dialogue( vo );
			vo_index++;
		}
		
		wait ( RandomFloatRange( 0.5, 1.0 ) );
	}
	
}

bar_enemy_strobe_vo()
{
	level endon( "bar_wave1_dead" );
	
	flag_wait( "strobe_on" );
	
	wait( 0.25 );
	
	ai	= get_living_ai_array( "bar_guys", "script_noteworthy" );
	
	panic_vo = [];
	//Federation Soldier 1: Over there!
	panic_vo[ 0 ] = "cornered_saf1_overthere";
	//Federation Soldier 2: There they are!
	panic_vo[ 1 ] = "cornered_saf2_theretheyare";
	//Federation Soldier 3: I can’t see them!
	panic_vo[ 2 ] = "cornered_pmc3_icantseethem";
	//Federation Soldier 1: How many are there?
	panic_vo[ 3 ] = "cornered_saf1_howmanyarethere";
	//Federation Soldier 2: What the hell is this?
	panic_vo[ 4 ] = "cornered_saf2_whatthehellis_2";
	//Federation Soldier 3: Get reinforcements up here! 
	panic_vo[ 5 ] = "cornered_pmc3_getreinforcementsuphere";
	//Federation Soldier 1: We need those lights back on! 
	panic_vo[ 6 ] = "cornered_saf1_weneedthoselights";
	
	vo_index = 0;
	
	while ( 1 )
	{
		ai = array_removeDead( ai );
		array_randomize( ai );
		
		if ( !IsAlive( ai[ 0 ] ) )
		{
			wait( 0.05 );
			continue;
		}
		if ( IsAlive( ai[ 0 ] ) )
		{
			if ( vo_index >= panic_vo.size )
			{
				vo_index = 0;	
			}
			vo = panic_vo[ vo_index ];
			
			ai[ 0 ] smart_dialogue( vo );
			vo_index++;
		}
		
		wait ( RandomFloatRange( 0.5, 1.0 ) );
	}
	

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// JUNCTION
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

courtyard_cleanup_enemies()
{
	//Cleanup of courtyard ents
	array = GetEntArray( "stealth_clipbrush_custom", "targetname" );
	array_delete( array );
}

junction_handler()
{
	// --Airlock between courtyard and junction.
	level.allies[ level.const_rorke ] thread junction_airlock_rorke					 (	 );
	level.allies[ level.const_baker ] thread junction_baker_open_elevator_control_room(	 );
	thread junction_elevator_control_panel();
	thread junction_pip_init();
	thread junction_pip_scenario();
	
	trigger = GetEnt( "send_in_junction_enemies_trigger", "targetname" );
	trigger trigger_off();
	
	// --Move Rorke to rappel hook up area, get player to elevator controls.
	flag_wait( "rorke_opening_junction_exit_door" );
	disable_stealth_system();

	death_vol = GetEnt( "combat_rappel_fall_volume", "targetname" ); // falling death anim if player jumps out window
	death_vol thread cornered_falling_death();
	
	delayThread( 1.5, ::junction_vo );
	
	level.allies[ level.const_rorke ] thread junction_rorke_window();
	
	// --Wait for player to disable elevators.  Rorke is discovered.
	flag_wait( "obj_disable_elevators_complete" );
	
	thread autosave_now();
	
	thread junction_enemies();
	
	trigger trigger_on();
	
	// --Combat starting, revert allies and player to combat behavior.
	max_ammo  = WeaponMaxAmmo( "fraggrenade" );
	clip_size = WeaponClipSize( "fraggrenade" );
	level.player SetWeaponAmmoClip( "fraggrenade", clip_size );
	level.player SetWeaponAmmoStock( "fraggrenade", max_ammo );
	
	max_ammo  = WeaponMaxAmmo( "flash_grenade" );
	clip_size = WeaponClipSize( "flash_grenade" );
	level.player SetWeaponAmmoClip( "flash_grenade", clip_size );
	level.player SetWeaponAmmoStock( "flash_grenade", max_ammo );
	
	level.allies[ level.const_rorke ] thread junction_ally_combat_state(	 );
	level.allies[ level.const_baker ] thread junction_ally_combat_state(	 );
	
	node = GetNode( "junction_backup_spot_baker", "targetname" );
	level.allies[ level.const_baker ] SetGoalNode( node );
	
	node = GetNode( "junction_backup_spot_rorke", "targetname" );
	level.allies[ level.const_rorke ] SetGoalNode( node );
	level.allies[ level.const_rorke ] teleport_ai( node );

	flag_wait( "junction_enemies_dead" );
	wait( 1.5 );
	level.allies[ level.const_rorke ] thread rorke_rappel_hookup();
	level.allies[ level.const_baker ] thread baker_rappel_hookup();
}

rorke_rappel_hookup()
{
	level endon( "c_rappel_player_on_rope" );
	
	level.rorke_and_combat_rappel_rope		= [];
	level.rorke_and_combat_rappel_rope[ 0 ] = self;
	level.rorke_and_combat_rappel_rope[ 1 ] = level.combat_rappel_rope_rorke;
//	level.combat_rappel_rope_rorke thread entity_cleanup( "c_rappel_player_on_rope" );
	
	level.player_start_rappel_struct thread anim_single( level.rorke_and_combat_rappel_rope, "cornered_junction_c4_enter_rorke" );
	self waittillmatch( "single anim", "ps_cornered_mrk_hookuptothe_2" );
	flag_set( "c4_vo_over" );
	
	self waittillmatch( "single anim", "end" );
		
	if ( !flag( "c_rappel_player_on_rope" ) )
	{
		level.player_start_rappel_struct thread anim_loop( level.rorke_and_combat_rappel_rope, "cornered_junction_c4_idle_rorke", "stop_loop_rorke" );
	}
}

baker_rappel_hookup()
{
	level endon( "c_rappel_player_on_rope" );
	
	baker_c4 = Spawn( "script_model", ( 0, 0, 0 ) );
	baker_c4 SetModel( "weapon_c4" );
	baker_c4.animname = "junction_baker_c4";
	baker_c4 SetAnimTree();
	baker_c4 Hide();
	baker_c4 thread entity_cleanup( "c_rappel_player_on_rope" );
	
	rorke_c4 = Spawn( "script_model", ( 0, 0, 0 ) );
	rorke_c4 SetModel( "weapon_c4" );
	rorke_c4.animname = "junction_rorke_c4";
	rorke_c4 SetAnimTree();
	rorke_c4 Hide();
	rorke_c4 thread entity_cleanup( "c_rappel_player_on_rope" );
		
														//   guy 	   anime 							  
	level.player_start_rappel_struct anim_first_frame_solo( baker_c4, "cornered_junction_c4_enter_baker" );
	level.player_start_rappel_struct anim_first_frame_solo( rorke_c4, "cornered_junction_c4_enter_baker" );
	
	baker_and_c4	  = [];
	baker_and_c4[ 0 ] = self;
	baker_and_c4[ 1 ] = baker_c4;
	baker_and_c4[ 2 ] = rorke_c4;
	
	baker_c4 Show();
	rorke_c4 Show();
	level.player_start_rappel_struct anim_single( baker_and_c4, "cornered_junction_c4_enter_baker" );
		
	if ( !flag( "c_rappel_player_on_rope" ) )
	{
		level.player_start_rappel_struct thread anim_loop( baker_and_c4, "cornered_junction_c4_idle_" + self.animname, "stop_loop_" + self.animname );
	}	
}

junction_cameras()
{
	//TODO: Make this turn on and off if you backtrack.
	
	SetSavedDvar( "cg_cinematicFullScreen", "0" );
	CinematicInGameLoopResident( "cornered_security_cam" );
	
	flag_wait( "c_rappel_player_on_rope" );
	StopCinematicInGame();
}

junction_airlock_rorke()
{
	animnode = getstruct( "junction_entry_animnode", "targetname" );
	
	if ( !IsDefined( level.started_junction_from_startpoint ) )
	{
		// This is to keep the player from blocking Rorke from shutting the door between the courtyard and junction airlock.
		junction_entrance_player_clip = GetEnt( "junction_entrance_player_clip", "targetname" );
		junction_entrance_player_clip NotSolid();
				
		animnode anim_reach_solo( self, "junction_door1_merrick_enter" );
		
		thread maps\cornered_audio::aud_door( "stealth1" );
		thread junction_airlock_door_open( "junction_door", "junction_door_handle", "junction_door1" );
		
		animnode anim_single_solo( self, "junction_door1_merrick_enter" );
	
		if ( !flag( "junction_entrance_close" ) )
		{
			animnode thread anim_loop_solo( self, "junction_door1_merrick_loop", "stop_loop" );
		}
		
		flag_wait( "junction_entrance_close" );
		animnode notify( "stop_loop" );
		thread maps\cornered_audio::aud_door( "stealth1b" );
		
		// This is to keep the player from blocking Rorke from shutting the door between the courtyard and junction airlock.
		junction_entrance_player_clip Solid();
		animnode anim_single_solo( self, "junction_door1_merrick_exit" );
		
		junction_entrance_player_clip Delete();
	}

	thread junction_banners();
	thread courtyard_cleanup_enemies();
	thread junction_fireworks();

	animnode anim_reach_solo( self, "junction_door2_merrick_enter" );
	thread maps\cornered_audio::aud_door( "stealth2" );
	
	thread junction_airlock_door_open( "junction_exit_door", "junction_door_exit_handle", "junction_door2" );
	flag_set( "rorke_opening_junction_exit_door" );
	
	animnode anim_single_solo( self, "junction_door2_merrick_enter" );
}

junction_airlock_door_open( doorname, handles, anime )
{
	junction_door = GetEnt( doorname, "targetname" );
	junc_handles  = GetEntArray( handles, "targetname" );
	foreach ( item in junc_handles )
	{
		item LinkTo( junction_door );
	}

	animnode = getstruct( "junction_entry_animnode", "targetname" );
	rig		 = spawn_anim_model( "junction_airlock_door" );
	
	animnode anim_first_frame_solo( rig, anime + "_enter" );
	junction_door LinkTo( rig, "J_prop_1" );
	
	animnode thread anim_single_solo( rig, anime + "_enter" );

	wait( 2.5 );
	junction_door ConnectPaths();
	
	rig waittillmatch( "single anim", "end" );
	
	if ( junction_door.targetname == "junction_door" )
	{
		if ( !flag( "junction_entrance_close" ) )
		{
			animnode thread anim_loop_solo( rig, anime + "_loop", "stop_loop" );
		}
		flag_wait( "junction_entrance_close" );
		animnode notify( "stop_loop" );
		junction_door DisconnectPaths();
		animnode anim_single_solo( rig, anime + "_exit" );	
	}

	junction_door Unlink();
	if ( IsDefined( rig ) )
	{
		rig Delete();
	}

	flag_wait( "part_one_start" ); //flag_init in cornered_rappel
	if ( IsDefined( junc_handles ) )
	{
		array_delete( junc_handles );
	}
}

junction_rorke_window()
{
	anim_node		 = getstruct( "elevator_script_node", "targetname" );
	anim_node.angles = ( 0, 0, 0 );
	
	anim_node anim_reach_solo( self, "rorke_enter_junction" );
	flag_set( "rorke_starts_handoff_anim" );
	anim_node anim_single_solo( self, "rorke_enter_junction" );
	
	if ( !flag( "obj_disable_elevators_complete" ) )
	{
		node = GetNode( "combat_rappel_hookup_spot_rorke", "targetname" );
		level.allies[ level.const_rorke ] SetGoalNode( node );
	}
}

junction_vo()
{
	wait( 0.05 );
	
	//Merrick: Hesh, we’re entering from the northeast corner.
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_heshwereenteringfrom" );
	wait( 0.2 );
	//Hesh: Roger that. I'm almost to the control room. 
	level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_rogerthatimalmost" );
	
	thread help_baker_control_panel_vo();
	
	flag_wait( "baker_open_elevator_control_room_doors" );
	
	//These are being played in the anim: cornered_junction_elevator_hesh
	//Hesh: Kill the power to the elevators.
	//level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_killthepowerto" );
	//Hesh: Looks like we’ve got company.
	//level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_lookslikewevegot" );
	
	flag_wait( "hesh_elevator_vo_said" );
	//Hesh: Shut it down.
	//Hesh: Go on.  Shut 'em down.
	//Hesh: Hurry up.  Shut down the elevators.
	//Hesh: Go on. Take out the elevators.
	nag_lines	= make_array( "cornered_hsh_shutitdown", "cornered_hsh_goonshutem", "cornered_hsh_hurryupshutdown", "cornered_hsh_goontakeout" );
	thread nag_until_flag( nag_lines, "start_disable_elevators", 5, 10, 5 );	
	
	flag_wait( "start_hesh_elevator_exit" );
	
	thread battlechatter_on( "axis" );
	
	//Hesh: Here they come.
	level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_heretheycometime1" );
	
	music_play( "mus_cornered_cutwire" );
	
	//Hesh: Time to upgrade.
	level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_heretheycometime2" );
		
	flag_wait( "obj_disable_elevators_complete" );
	wait( 2.0 );
	//Merrick: They've found us!  Get back here!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_theyvefoundusget" );
	wait( 1.0 );
	
	thread battlechatter_on( "allies" );

	flag_wait( "junction_enemies_wave_2" );
	wait( 1 );
	//Merrick: We’re losing time we need to move!
	level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_werelosingtimewe" );
		

	flag_wait( "junction_enemies_dead" );
	//This line is being played in the anim: cornered_junction_c4_baker_enter
	//Hesh: Targets down!
	//level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_targetsdown_2" );
	
	//This line is being played in the anim: cornered_junction_c4_rorke_enter
	//Merrick: We need to hook up before back up arrives!
	//level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_weneedtohook" );
	
	//This line is being played in the anim: cornered_junction_c4_baker_enter
	//Hesh: Give me your extra charges I’ll cover our exit.
	//level.allies[ level.const_baker ] smart_dialogue( "cornered_hsh_givemeyourextra" );
	
	//This line is being played in the anim: cornered_junction_c4_rorke_enter
	//Merrick: Hook up to the ropes.
	//level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_hookuptothe_2" );

	flag_wait( "c4_vo_over" );
	wait( 0.5 );
	
	volume = GetEnt( "hesh_junction_vo_volume", "targetname" );
	//Hesh: Go hook up Adam, I’ll be right behind you.
	thread vo_by_volume( level.allies[ level.const_baker ], volume, "cornered_hsh_gohookupadam" );

	volume = GetEnt( "merrick_junction_vo_volume", "targetname" );
	//Merrick: Grab your line, we need to move.
	thread vo_by_volume( level.allies[ level.const_rorke ], volume, "cornered_mrk_grabyourlinewe" );	
	
	flag_set( "junction_finished" );
}

help_baker_control_panel_vo()
{
	flag_wait( "rorke_starts_handoff_anim" );
	wait( 5 );
	if ( !flag( "baker_open_elevator_control_room_doors" ) )
	{
		//Merrick: Go give Hesh a hand. I’ll hook up the ropes.
		level.allies[ level.const_rorke ] smart_dialogue( "cornered_mrk_gogivehesha" );
	}
}

vo_by_volume( ally, volume, vo_alias )
{
	level endon( "c_rappel_player_on_rope" );
	
	while ( 1 )
	{
		if ( level.player IsTouching( volume ) && !IsDefined( level.vo_by_volume ) )
		{
			level.vo_by_volume = true;
			ally smart_dialogue( vo_alias );
			wait( 1 );
			level.vo_by_volume = undefined;
			break;
		}
		wait( 0.05 );
	}
}

junction_baker_open_elevator_control_room()
{
	anim_node		 = getstruct( "elevator_script_node", "targetname" );
	anim_node.angles = ( 0, 0, 0 );
	
	anim_node anim_first_frame_solo( self, "baker_enter_junction" );
	
	thread baker_junction_door_open( anim_node );
	
	flag_wait( "baker_enter_junction" );
	
	anim_node anim_single_solo( self, "baker_enter_junction" );
	
	anim_node thread anim_loop_solo( self, "baker_keypad_loop", "stop_loop" );
	
	flag_wait( "baker_open_elevator_control_room_doors" );
	thread junction_cameras();
	
	anim_node notify( "stop_loop" );
	waittillframeend;
	thread junction_elevator_control_doors_open( anim_node );
	flag_set( "start_junction_pip_scenario" );
	anim_node anim_single_solo( self, "baker_elevator_enter" );
	flag_set( "hesh_elevator_vo_said" );
	
	anim_node thread anim_loop_solo( self, "baker_elevator_loop", "stop_loop" );
	
	//flag_wait( "start_hesh_elevator_exit" );
	flag_wait( "player_shutting_down_elevators" );
	
	anim_node notify( "stop_loop" );
	self StopAnimScripted();
	waittillframeend;

	anim_node anim_first_frame_solo( self, "baker_elevator_exit" );
	
	flag_wait( "start_hesh_elevator_exit" );
	anim_node anim_single_solo( self, "baker_elevator_exit" );
	self disable_cqbwalk();
}

baker_junction_door_open( anim_node )
{
	baker_junction_door		  = GetEnt( "baker_junction_hallway_door_brushes", "targetname" );
	baker_junction_door_model = GetEnt( "baker_junction_hallway_door_model", "targetname" );

	baker_junction_door_model LinkTo( baker_junction_door );

	rig		= spawn_anim_model( "baker_junction_door" );
	
	anim_node anim_first_frame_solo( rig, "baker_enter_junction" );
	
	baker_junction_door LinkTo( rig, "J_prop_1" );
	
	flag_wait( "baker_enter_junction" );
	
	thread maps\cornered_audio::aud_junction( "hesh" );
	
	anim_node anim_single_solo( rig, "baker_enter_junction" );

	baker_junction_door Unlink();
	if ( IsDefined( rig ) )
	{
		rig Delete();
	}
}

junction_elevator_control_doors_open( anim_node )
{
	door_rig = spawn_anim_model( "junction_keypad_door" );
	
	anim_node anim_first_frame_solo( door_rig, "cornered_junction_keypad_door" );
	
	elevator_control_room_door_left	 = GetEnt( "elevator_control_room_door_left", "targetname" );
	elevator_control_room_door_right = GetEnt( "elevator_control_room_door_right", "targetname" );
	elevator_control_room_door_clip	 = GetEnt( "elevator_control_room_door_clip", "targetname" );

	waitframe();
	
	elevator_control_room_door_right LinkTo( door_rig, "J_prop_1" );
	elevator_control_room_door_left LinkTo( door_rig, "J_prop_2" );
	
	thread maps\cornered_audio::aud_door( "elevator_room" );
	
	anim_node thread anim_single_solo( door_rig, "cornered_junction_keypad_door" );
	
	wait( 1.5 );
	elevator_control_room_door_clip NotSolid();
	elevator_control_room_door_clip ConnectPaths();
	elevator_control_room_door_clip Delete();
}

junction_elevator_control_panel()
{	
	trigger = GetEnt( "disable_elevators_trigger", "targetname" );
	trigger trigger_off();
	//"Press and hold [{+activate}] to disable elevators"
	trigger SetHintString( &"CORNERED_DISABLE_ELEVATORS_HINT" );

	control_panel_upper = spawn_anim_model( "elevator_control_panel" );
	control_panel_lower = spawn_anim_model( "elevator_control_panel" );
	multi_tool			= spawn_anim_model( "multi_tool" );
	
	hide_player_arms();
	multi_tool Hide();
	
	scripted_node		 = getstruct( "elevator_script_node", "targetname" );
	scripted_node.angles = ( 0, 0, 0 );
	
	multi_tool anim_first_frame_solo( multi_tool, "cornered_elevator_junction_player_clippers" );
									 //   guy 					      anime 								   
	scripted_node anim_first_frame_solo( control_panel_upper	   , "cornered_elevator_junction_upper_panel" );
	scripted_node anim_first_frame_solo( control_panel_lower	   , "cornered_elevator_junction_lower_panel" );
	scripted_node anim_first_frame_solo( level.cornered_player_arms, "cornered_elevator_junction_player" );
	
	control_panel_lower thread control_panel_setup_lights();
	control_panel_upper thread control_panel_setup_lights();
	
	control_panel_upper	SetModel( "cnd_server_control_panel_anim_obj" );
	//control_panel_lower	SetModel( "cnd_server_control_panel_anim_obj" );
	
	flag_wait( "start_junction_pip_scenario" );
	wait( 8 );
	trigger trigger_on();
	
	waittill_trigger_activate_looking_at( trigger, control_panel_upper, Cos( 40 ), false, true );
	
	flag_set( "start_disable_elevators" );
	
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	if ( level.player GetStance() != "stand" )
	{
		level.player SetStance( "stand" );
	}
	
	level.combat_rappel_rope_coil_rorke Show();
	level.combat_rappel_rope_coil_player Show();
	level.combat_rappel_rope_coil_baker Show();
	
	level.combat_rappel_rope_rorke			= spawn_anim_model( "cnd_rappel_tele_rope" );
	level.combat_rappel_rope_rorke.animname = "combat_rappel_exit_rope_rorke";
	level.player_start_rappel_struct		= getstruct( "player_start_rappel_struct", "targetname" );
	level.player_start_rappel_struct anim_first_frame_solo( level.combat_rappel_rope_rorke, "cornered_junction_c4_enter_rorke" );
	
	control_panel_upper	SetModel( "cnd_server_control_panel_anim" );
	//control_panel_lower	SetModel( "cnd_server_control_panel_anim" );
	
	level.player DisableWeapons();
	
	blend_time = 0.5;
	right_arc  = 18;
	left_arc   = 18;
	top_arc	   = 5;
	bottom_arc = 20;
	level.player PlayerLinkToBlend( level.cornered_player_arms, "tag_player", 0.5 );
	wait 0.6;
	
	flag_set( "player_shutting_down_elevators" );

	level.player PlayerLinkToDelta( level.cornered_player_arms, "tag_player", 1, right_arc, 5, top_arc, bottom_arc, true );
	show_player_arms();
	multi_tool Show();
	
	thread maps\cornered_audio::aud_junction( "panel" );
									   //   guy 			     anime 										  
	scripted_node thread anim_single_solo( multi_tool		  , "cornered_elevator_junction_player_clippers" );
	scripted_node thread anim_single_solo( control_panel_upper, "cornered_elevator_junction_upper_panel" );
	control_panel_lower delayThread( 3.5, ::junction_elevator_control_panel_lights_off, control_panel_lower );
	//scripted_node thread anim_single_solo( control_panel_lower, "cornered_elevator_junction_lower_panel" );
	
	scripted_node thread anim_single_solo( level.cornered_player_arms		, "cornered_elevator_junction_player" );
	
	control_panel_upper thread waittill_control_panel_notetrack();
	control_panel_lower thread waittill_control_panel_notetrack();
	
	level.cornered_player_arms waittillmatch( "single anim", "start_hesh" );
	
	flag_set( "start_hesh_elevator_exit" );
	level.player LerpViewAngleClamp( 0.5, 0, 0, 0, 0, 0, 0 );
	
	level.cornered_player_arms waittillmatch( "single anim", "gun_up" );
	level.player EnableWeapons();
	
	level.cornered_player_arms waittillmatch( "single anim", "end" );
	
	multi_tool Delete();
	hide_player_arms();
	
	level.player Unlink();
	level.player AllowCrouch( true );
	level.player AllowProne( true );
	
	flag_set( "obj_disable_elevators_complete" );
	
	elevator_light = GetEnt( "junction_elevator_light", "targetname" );
	elevator_light SetLightIntensity( 0 );
	
	flag_wait( "c_rappel_player_on_rope" );
	
	foreach ( light in control_panel_upper.green_lights )
		light Delete();
	foreach ( light in control_panel_upper.red_lights )
		light Delete();
	foreach ( light in control_panel_lower.green_lights )
		light Delete();
	foreach ( light in control_panel_lower.red_lights )
		light Delete();
	control_panel_upper Delete();
	control_panel_lower Delete();
}

waittill_control_panel_notetrack()
{
	self waittillmatch( "single anim", "wire_spark" );
	PlayFXOnTag( level._effect[ "spark_flash_15" ], self, "tag_fx" );
}

junction_pip_init()
{
	level.pip.renderToTexture = true;
	pip_monitor_cam			  = getstruct( "pip_monitor_cam", "targetname" );
	level.pip.entity		  = Spawn ( "script_model", pip_monitor_cam.origin );
	level.pip.entity SetModel ( "tag_origin" );
	level.pip.entity.angles = pip_monitor_cam.angles;
	wait 0.05;

	level.pip.tag			= "tag_origin";
	level.pip.fov			= 65;
	level.pip.freeCamera	= true;
	level.pip.enableshadows = false;
	level.pip.x				= 50;
	level.pip.y				= 50;
	level.pip.width			= 240;
	level.pip.height		= 120;
	level.pip.enable		= true;
	
	level.pip.opened_x		= 50;
	level.pip.opened_y		= 50;
	level.pip.opened_width	= level.pip.width;
	level.pip.opened_height = level.pip.height;
	
  //level.pip.VisionSetNight = "ac130_enhanced";
  //level.pip.VisionSetNaked = "ac130_enhanced";
	
	//level thread pip_static();
	//level thread pip_static_lines();
	
	flag_wait( "c_rappel_player_on_rope" );
	level.pip.enable		= false;
}

junction_pip_scenario()
{
	flag_wait( "start_junction_pip_scenario" );
	
	wait( 2 );
	
	thread junction_pip_waver_drone();
	
	wait( 2 );
	
	level.total_drones					 = 0;
	level.total_runner_drone_spawn_count = 0;
	level.total_times_without_waver		 = 0;
	
	junction_pip_drone_far_right = GetEntArray( "junction_pip_drone_far_right", "targetname" );
	array_thread( junction_pip_drone_far_right, ::junction_pip_drone_think, "player_shutting_down_elevators" );
	
	junction_pip_drone_far_right_2 = GetEntArray( "junction_pip_drone_far_right_2", "targetname" );
	array_thread( junction_pip_drone_far_right_2, ::junction_pip_drone_think, "player_shutting_down_elevators" );
	
	junction_pip_drone_close_right = GetEntArray( "junction_pip_drone_close_right", "targetname" );
	array_thread( junction_pip_drone_close_right, ::junction_pip_drone_think, "player_shutting_down_elevators" );
	
	flag_wait( "start_hesh_elevator_exit" );
	
	thread junction_pip_waver_drone();
	
	junction_pip_drone_far_right = GetEntArray( "junction_pip_drone_far_right", "targetname" );
	array_thread( junction_pip_drone_far_right, ::junction_pip_drone_think, "send_in_junction_enemies" );
	
	junction_pip_drone_far_right_2 = GetEntArray( "junction_pip_drone_far_right_2", "targetname" );
	array_thread( junction_pip_drone_far_right_2, ::junction_pip_drone_think, "send_in_junction_enemies" );
	
	junction_pip_drone_close_right = GetEntArray( "junction_pip_drone_close_right", "targetname" );
	array_thread( junction_pip_drone_close_right, ::junction_pip_drone_think, "send_in_junction_enemies" );
	
	//flag_wait( "start_junction_pip_scenario" );
	//junction_pip_scenario_guys = array_spawn_targetname( "junction_pip_scenario_drones" );

/*
	array_spawn_function_targetname( "junction_pip_scenario_guys", ::junction_pip_scenario_guys_setup );
	
	flag_wait( "start_junction_pip_scenario" );
	junction_pip_scenario_guys = array_spawn_targetname( "junction_pip_scenario_guys" );
	
	flag_wait( "send_in_junction_enemies" );
	foreach ( guy in junction_pip_scenario_guys )
	{
		if ( IsDefined( guy ) )
		{
			guy Delete();
		}
	}
*/
}

junction_pip_drone_think( flag_to_end_on )
{	
	wait( RandomFloatRange( 0.6, 0.8 ) );
	spawn_junction_pip_drones( flag_to_end_on );
}

spawn_junction_pip_drones( flag_to_end_on )
{
	level endon( flag_to_end_on );
	
	for ( ;; )
	{
		count	= RandomIntRange( 1, 3 );
		for ( i = 0; i < count; i++ )
		{
			self thread spawn_a_drone();
			wait( RandomFloatRange( 0.4, 0.7 ) );
		}
		
		wait RandomFloatRange( 14, 18 );

		level.total_runner_drone_spawn_count++;
		while ( 1 )
		{
			if ( level.total_runner_drone_spawn_count == 3 )
				break;
			wait( 0.05 );
		}
		
		wait( 1 );
		
		level.total_times_without_waver++;
		if ( level.total_times_without_waver == 9 )
		{
			thread junction_pip_waver_drone();
			level.total_times_without_waver = 0;
			wait( 1 );
		}
		level.total_runner_drone_spawn_count = 0;
	}
}

spawn_a_drone()
{
	max_drones = 4;
	
	if ( level.total_drones >= max_drones )
		return;

//	self.count = 1;
	guy = self dronespawn();
	guy drone_count();
}

drone_count()
{
	level.total_drones++;
	
	while ( IsDefined( self ) )
	{
		wait( 0.05 );
	}
	
	level.total_drones--;
}

junction_pip_waver_drone()
{
	side = "";
	if ( cointoss() )
{
		side									  = "left";
		junction_pip_scenario_drone_waver_spawner = GetEnt( "junction_pip_scenario_drone_left_waver", "targetname" );
		junction_pip_scenario_drone_waver		  = junction_pip_scenario_drone_waver_spawner dronespawn();
	}
	else
	{
		side									  = "right";
		junction_pip_scenario_drone_waver_spawner = GetEnt( "junction_pip_scenario_drone_right_waver", "targetname" );
		junction_pip_scenario_drone_waver		  = junction_pip_scenario_drone_waver_spawner dronespawn();
	}
	
	junction_pip_scenario_drone_waver.animname = "generic";	
	wait( 1 );
	wave_struct = getstruct( side + "_wave_struct", "targetname" );
	junction_pip_scenario_drone_waver waittill( "goal" );
	wave_struct anim_generic_run( junction_pip_scenario_drone_waver, "wave_" + side );
	after_wave_struct						 = getstruct( "after_" + side + "_wave_struct", "targetname" );
	junction_pip_scenario_drone_waver.target = after_wave_struct.targetname;
	junction_pip_scenario_drone_waver thread maps\_drone::drone_move();
	junction_pip_scenario_drone_waver waittill( "goal" );
	junction_pip_scenario_drone_waver Delete();
}

/*
junction_pip_scenario_guys_setup()
{
	self.ignoreall = 1;
	self.animname  = "generic";
	
	wait( 0.5 );
	
	if ( IsDefined( self.script_delay ) )
	{
		wait( self.script_delay );
	}
	
	volume = GetEnt( "junction_pip_scenario_delete_volume", "targetname" );
	
	if ( self.script_noteworthy == "junction_pip_scenario_guy_L_1" )
	{
		self.struct = getstruct( "door_stack_L_1", "targetname" );
		self.struct anim_reach_solo( self, "intro_tactical_open_door_push_a" );
		self.struct anim_first_frame_solo( self, "intro_tactical_open_door_push_a" );
		self enable_cqbwalk();
		
		junction_pip_scenario_drone_waver_spawner = GetEnt( "junction_pip_scenario_drone_waver", "targetname" );
		junction_pip_scenario_drone_waver		  = junction_pip_scenario_drone_waver_spawner dronespawn();
		junction_pip_scenario_drone_waver thread junction_pip_scenario_drone();	
		wait( 1 );
		junction_pip_scenario_drone_runner_spawner = GetEnt( "junction_pip_scenario_drone_runner", "targetname" );
		junction_pip_scenario_drone_runner		   = junction_pip_scenario_drone_runner_spawner dronespawn();
		junction_pip_scenario_drone_runner thread junction_pip_scenario_drone();	
		
		flag_wait( "move_junction_pip_scenario_guys" );
		thread junction_pip_scenario_door();
		self.struct anim_single_solo( self, "intro_tactical_open_door_push_a" );
		self SetGoalVolumeAuto( volume );
	}
	if ( self.script_noteworthy == "junction_pip_scenario_guy_R_1" )
	{
		self.struct = getstruct( "door_stack_R_1", "targetname" );
		self.struct anim_reach_solo( self, "breach_flash_R1_idle" );
		self.struct thread anim_loop_solo( self, "breach_flash_R1_idle", "stop_loop" );
		flag_wait( "move_junction_pip_scenario_guys" );
		self enable_cqbwalk();
		wait( 1.5 );
		if ( IsAlive( self ) )
		{
			self.struct notify( "stop_loop" );
			self SetGoalVolumeAuto( volume );
		}
	}
	if ( self.script_noteworthy == "junction_pip_scenario_guy_R_2" )
	{
		self.struct = getstruct( "door_stack_R_2", "targetname" );
		self.struct anim_reach_solo( self, "breach_flash_R2_idle" );
		self.struct thread anim_loop_solo( self, "breach_flash_R2_idle", "stop_loop" );
		flag_wait( "move_junction_pip_scenario_guys" );
		self enable_cqbwalk();
		wait( 2.5 );
		if ( IsAlive( self ) )
		{
			self.struct notify( "stop_loop" );
			self SetGoalVolumeAuto( volume );
		}
	}
	if ( self.script_noteworthy == "junction_pip_scenario_guy_L_2" )
	{
		self.struct = getstruct( "door_stack_L_1", "targetname" );
		self.struct anim_reach_solo( self, "breach_kick_stackL1_idle" );
		self.struct thread anim_loop_solo( self, "breach_kick_stackL1_idle", "stop_loop" );
		flag_wait( "move_junction_pip_scenario_guys" );
		self enable_cqbwalk();
		wait( 4.5 );
		if ( IsAlive( self ) )
		{
			self.struct notify( "stop_loop" );
			self SetGoalVolumeAuto( volume );
		}
	}
}

junction_pip_scenario_door()
{
	junction_door = GetEnt( "junction_door", "targetname" );
	junc_handles  = GetEntArray( "junction_door_handle", "targetname" );
	foreach ( item in junc_handles )
	{
		item LinkTo( junction_door );
	}
}

*/
/*
pip_enable( ent, tagname, shoulder_cam, optional_offset, optional_fov, x_pos, y_pos, width, height, visionset_override, noStatic )
{	
	is_wide_screen			  = GetDvarInt( "widescreen", 1 );
	inv_standard_aspect_ratio = 3 / 4;
	
	if ( !IsDefined( x_pos ) || !IsDefined( y_pos ) || !IsDefined( width ) || !IsDefined( height ) )
	{
		x_pos  = ter_op( is_wide_screen, 545, 530 );
		y_pos  = ter_op( is_wide_screen, 15, 30 );
		width  = 165;
		height = 101;
	}
	
	if ( !IsDefined( visionset_override ) )
	{
		visionset_override = "ac130_enhanced";
	}

//	level.pip.opened_width 		= ter_op( is_wide_screen, 220, 130 ); //240
//	level.pip.opened_height 	= ter_op( is_wide_screen, 135, Int( Floor( inv_standard_aspect_ratio * level.pip.opened_width ) ) );
	level.pip.opened_width	= width;
	level.pip.opened_height = height;
	level.pip.closed_width	= 16;
	level.pip.closed_height		= 101;
//	level.pip.closed_height 	= ter_op( is_wide_screen, 135, Int( Floor( inv_standard_aspect_ratio * level.pip.opened_width ) ) );
//	level.pip.opened_x 			= ter_op( is_wide_screen, 490, 475 ); //ACTUAL X (bottom left =  -40) //460
	level.pip.opened_x		   = x_pos; //ACTUAL X (bottom left =  -40) //460
	level.pip.opened_y		   = y_pos; //ACTUAL Y (bottom left = 310)//32
	level.pip.closed_x		   = level.pip.opened_x + ( level.pip.opened_width * 0.5 ) - ( level.pip.closed_width * 0.5 );
	level.pip.closed_y		   = level.pip.opened_y;
	level.pip.border_thickness = 2;
		
	level.pip.enableshadows = false;
	level.pip.tag			= "tag_origin";
	level.pip.x				= level.pip.closed_x;
	level.pip.y				= level.pip.closed_y;
	level.pip.width			= level.pip.closed_width;
	level.pip.height		= level.pip.closed_height;

	level.pip.VisionSetNight = visionset_override;
	level.pip.VisionSetNaked = visionset_override;
	
  //  level.pip.visionsetnight = "vault_pip";
  //  level.pip.visionsetnaked = "vault_pip";
	
	x = level.pip.closed_x;
	y = level.pip.closed_y;
	
	level.pip.borders[ "top_left"	  ] = new_L_pip_corner( x, y, "top_left" );
	level.pip.borders[ "top_right"	  ] = new_L_pip_corner( x, y, "top_right" );
	level.pip.borders[ "bottom_left"  ] = new_L_pip_corner( x, y, "bottom_left" );
	level.pip.borders[ "bottom_right" ] = new_L_pip_corner( x, y, "bottom_right" );

	if ( !IsDefined( noStatic ) || noStatic == false )
	{
		level thread pip_static();
	}
	level thread pip_open();
//	level thread pip_display_timer();
	if ( !IsDefined( noStatic ) || noStatic == false )
	{
		level thread pip_border();
		level thread pip_static_lines();
	}
	
	pip_set_entity( ent, tagname, shoulder_cam, optional_offset, optional_fov );
}

pip_static()
{
	//creates the staticFX shader in PIP
	if ( !IsDefined( level.pip.static_overlay ) )
	{
		hud = NewHudElem();
	}
	else
	{
		hud = level.pip.static_overlay;
	}
	
	hud.alpha		   = 1;
	hud.sort		   = -50;
	hud.x			   = level.pip.opened_x;
	hud.y			   = level.pip.opened_y;
	hud.hidewheninmenu = false;
	hud.hidewhendead   = true;
	hud SetShader( "overlay_static", level.pip.opened_width, level.pip.opened_height ); //shader needs to be in CSV and precached

	level.pip.static_overlay = hud;

}	

pip_static_lines()
{
	// 220x135
	level.pip endon( "stop_interference" );
	
	//creates the static lines
	level.pip.line_a				= NewHudElem();
	level.pip.line_a.alpha			= 1;
	level.pip.line_a.sort			= -50;
	level.pip.line_a.x				= level.pip.opened_x;
	level.pip.line_a.y				= level.pip.opened_y;
	level.pip.line_a.hidewheninmenu = false;
	level.pip.line_a.hidewhendead	= true;
	
	lines	   = [];
	lines[ 0 ] = "ac130_overlay_pip_static_a";
	lines[ 1 ] = "ac130_overlay_pip_static_b";
	lines[ 2 ] = "ac130_overlay_pip_static_c";

	lines = array_randomize( lines );
	
	level thread random_line_flicker();
	level thread random_line_placement();
	pip_height		= 135;
	random_fraction = RandomFloatRange( 0.10, .35 ); //Height Random
	
	while ( 1 )
	{
		level.pip.line_a SetShader( random( lines ), level.pip.opened_width, Int( pip_height * random_fraction ) ); //shader needs to be in CSV and precached
		//wait( randomfloatrange( .05, .05 ) );			//Random wait between frame switch
		wait( 0.05 );
	}
}	

random_line_flicker()
{
	level.pip endon( "stop_interference" );
	
	while ( 1 )
	{
		time	= RandomFloatRange( 0.05, .08 ); //Random Duration Value between Alpha Value Change
												 //delay = time + RandomFloatRange( 0.1, 0.4 );
		alpha	= RandomFloatRange( 0.1, 0.8 );	 //Random Alpha Value Range
		level.pip.line_a FadeOverTime( time );
		level.pip.line_a.alpha = alpha;		
		wait( time );
		
		if ( RandomInt( 100 ) > 50 )					//Random decision to switch to nothing
		{
			time = RandomFloatRange( 0.25, .4 );			//Random duration of nothing if chosen
			level.pip.line_a FadeOverTime( time );
			//iprintlnbold("delay_error");
			level.pip.line_a.alpha = 0;		
			wait( time );
		}	
	}
}	

random_line_placement()
{
	level.pip endon( "stop_interference" );
	while ( 1 )
	{
		num				   = RandomIntRange( 10, Int( level.pip.height - 25 ) ); //Random height placement value
		level.pip.line_a.y = num;
		wait( RandomFloatRange( 0.05, .4 ) );						//Random Duration between height switch
	}
}	

pip_interference()
{
	level.pip endon( "stop_interference" );

	while ( IsDefined( level.pip ) && IsDefined( level.pip.static_overlay ) )
	{
		time  = RandomFloatRange( 0.1, 1 );
		delay = time + RandomFloatRange( 0.1, 0.4 );
		alpha = RandomFloatRange( 0.1, 0.2 );

		level.pip.static_overlay FadeOverTime( time );
		level.pip.static_overlay.alpha = alpha;

		wait( delay );

		time  = RandomFloatRange( 0.5, 0.75 );
		delay = time + RandomFloatRange( 0.5, 1.5 );

		level.pip.static_overlay FadeOverTime( time );
		level.pip.static_overlay.alpha = 0.3;

		wait( delay );
	}
}

*/
control_panel_setup_lights()
{
	waitframe(); // let control panel get into first frame
	
	self.green_lights = [];
	self.red_lights	  = [];
	
	num_lights = 6;
	r		   = 7;
	g		   = 1;
	i		   = 0;
	
	while ( i < num_lights )
	{
		green_light = Spawn( "script_model", ( 0, 0, 0 ) );
		green_light SetModel( "cnd_controlpanel_elevator_grn_0" + g );
		green_light.origin = self.origin;
		green_light.angles = self.angles;
		g++;
		self.green_lights[ i ] = green_light;
		
		red_light = Spawn( "script_model", ( 0, 0, 0 ) );
		if ( r < 10 )
			red_light SetModel( "cnd_controlpanel_elevator_red_0" + r );
		else // r >= 10
			red_light SetModel( "cnd_controlpanel_elevator_red_" + r );
		red_light.origin = self.origin;
		red_light.angles = self.angles;
		red_light Hide();
		r++;
		self.red_lights[ i ] = red_light;
		
		i++;
	}
}

junction_elevator_control_panel_lights_off( control_panel )
{
	num_lights = control_panel.green_lights.size;
	Assert( control_panel.green_lights.size == control_panel.red_lights.size );
	
	light_delay = 0.2;
	
	for ( i = num_lights - 1; i >= 0; i-- )
	{
		control_panel.green_lights[ i ] Hide();
		control_panel.red_lights[ i ] Show();
		
		wait light_delay;
	}
}

junction_enemy_setup()
{
	self set_baseaccuracy( 0.1 ); //look busy but miss a lot.
	
	flag_wait( "send_in_junction_enemies" );
	
	if ( IsDefined( self ) )
	{
		self set_baseaccuracy( 1 ); // can kill guys normally.
	}
}

junction_enemies()
{
	array_spawn_function_targetname( "junction_backup_guys_starters", ::junction_enemy_setup );
	starters = array_spawn_targetname( "junction_backup_guys_starters", true );
	
	array_thread( starters, ::magicbullet_spray );
	
	flag_wait( "send_in_junction_enemies" );
	
	array_spawn_function_targetname( "junction_backup_guys1", ::junction_enemy_setup );
	guys1 = array_spawn_targetname( "junction_backup_guys1", true );
	waitframe();
	//enemies = get_living_ai_array( "junction_backup_guys1", "script_noteworthy" ); //7
	remove_dead_from_array( starters );
	enemies	= array_combine( starters, guys1 );
	
	waittill_dead_or_dying( enemies, 3 );

	flag_set( "junction_enemies_wave_2" );
	
	guys2 = array_spawn_targetname( "junction_backup_guys2", true ); //4
	waitframe();
	remove_dead_from_array( enemies );
	enemies	= array_combine( enemies, guys2 );
	
	thread junction_last_stand( enemies );
	
	waittill_dead_or_dying( enemies );
	flag_set( "junction_enemies_dead" );
}

magicbullet_spray()
{
	level endon( "send_in_junction_enemies" );
	self endon( "death" );
	
	while ( 1 )
	{
  //ally = random( level.allies );
		ally = level.allies[ level.const_rorke ];
	
		ally_head  = ally GetTagOrigin( "j_head" ) + ( 0, 0, 20 );
		enemy_head = self GetTagOrigin( "j_head" );
		
		vector = VectorNormalize( ally_head - enemy_head );
		start  = enemy_head + vector * ( Distance( ally_head, enemy_head ) - 10 );
		if ( self.weapon != "none" )
		{
			MagicBullet( self.weapon, start, ally_head );
		}
		wait( RandomFloatRange( 0.5, 2.2 ) );
	}
}

junction_last_stand( enemies )
{
	last_stand_enemies = [];
	
	foreach ( enemy in enemies )
	{
		if ( IsDefined( enemy.script_noteworthy ) && enemy.script_noteworthy == "upper" )
		{
			
		}
		else
		{
			last_stand_enemies = add_to_array( last_stand_enemies, enemy );
		}
	}
	
	while ( last_stand_enemies.size > 3 )
	{
		last_stand_enemies = remove_dead_from_array( last_stand_enemies );
		wait( 0.05 );
	}
	
	volume = GetEnt( "junction_backup_guys_last_stand_volume", "targetname" );
	
	while ( 1 )
	{
		last_stand_enemies = remove_dead_from_array( last_stand_enemies );
		if ( last_stand_enemies.size == 0 )
			break;
		
		foreach ( last_stand_enemy in last_stand_enemies )
		{
			wait( RandomFloatRange( 1, 2.5 ) );
			if ( IsAlive( last_stand_enemy ) )
			{
				last_stand_enemy SetGoalVolumeAuto( volume );
			}
		}
		wait( 5 );
	}
}

junction_ally_combat_state()
{		
	self set_ignoreall( false );
	self set_ignoreme( false );
	self set_baseaccuracy( 0.1 ); //look busy but miss a lot.
	self disable_dontevershoot();
	self.favoriteenemy = undefined;
					 //   newWeapon       targetSlot   
	//self forceUseWeapon( "usp_silencer", "secondary" );
	self forceUseWeapon( "p226", "secondary" );
	//self forceUseWeapon( "kriss"	   , "primary" );
	self forceUseWeapon( "kriss+eotechsmg_sp+silencer_sp", "primary" );
	self.lastWeapon = self.weapon;	// needed to avoid animscript SRE later

	if ( self.animname == "rorke" )
	{
		self StopAnimScripted(); //in case he's still doing the look at ropes anim.
	}
	
	flag_wait( "send_in_junction_enemies" );
	self set_baseaccuracy( 1 ); // can kill guys normally.
}

junction_banners()
{
	anim_org = getstruct( "banner_org", "targetname" );

	banner_1 = spawn_anim_model( "elevator_junction_banner" );
  //banner_2 = spawn_anim_model( "elevator_junction_banner" );
	banner_3 = spawn_anim_model( "elevator_junction_banner_3" );
	
								//   guy 	   anime 		    ender 			   
	anim_org thread anim_loop_solo( banner_1, "banner_1_loop", "stop_banner_loop" );
	//anim_org thread anim_loop_solo( banner_2, "banner_2_loop", "stop_banner_loop" );
	anim_org thread anim_loop_solo( banner_3, "banner_3_loop", "stop_banner_loop" );
	
	flag_wait( "rappel_finished" );
	
	anim_org notify( "stop_banner_loop" );
	
	waittillframeend;
	banner_1 Delete();
	//banner_2 Delete();
	banner_3 Delete();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// Begin stealth utilities
/////////////////////////////////////////////////////////////////////////////////////////////////

//stealth_idle_and_react_or_patrol( flagname, delay_patrol )
//{
//	//Play a loop animation until player is seen or AI is told to move on.
//	AssertEx( IsDefined( self.target ), "Enemy with script_noteworthy " + self.script_noteworthy + " is expected to have a target." );
//	
//	node = getstruct( self.target, "targetname" );
//			
//	self.allowdeath = true;
//	node thread anim_generic_loop( self, self.script_noteworthy + "_loop", "stop_loop" );
//	
//	if ( !IsDefined( flagname ) )
//	{
//		flag_wait( "_stealth_spotted" );
//	}
//	else
//	{
//		flag_wait_any( "_stealth_spotted", flagname );
//	}
//	
//	//If told to patrol.
//	if ( IsDefined( flagname ) && flag( flagname ) )
//	{
//		if ( IsDefined( delay_patrol ) )
//		{
//			wait delay_patrol;
//		}
//		
//		node notify( "stop_loop" );
//		self StopAnimScripted();
//		waittillframeend;
//		
//		self thread patroller_logic();
//		waitframe();
//		self thread patroller_delete_on_path_end();		
//	}
//	
//	//Stealth failed, play reaction.
//	else
//	{
//		self notify( "stop_vo" );
//		if ( IsAlive( self ) )
//		{
//			node notify( "stop_loop" );
//			waittillframeend;
//			node anim_generic( self, node.script_noteworthy + "_react" );
//		}
//	}
//
//}
//
//patroller_logic( patrol_anim, patrol_twitch_weights, playback_rate )
//{
//	self endon( "death" );
//
  //  self.script_patroller = 1;
  //  self.target			= self.script_parameters;
//	
//	if ( IsDefined( playback_rate ) )
//	{
  //	  self.old_moveplaybackrate = self.moveplaybackrate;
  //	  self.moveplaybackrate		= playback_rate;
//	}
//	
//	if ( !IsDefined( patrol_anim ) && IsDefined( self.script_animation ) )
//		patrol_anim = self.script_animation;
//	
//	if ( IsDefined( patrol_anim ) )
//	{
//		self.patrol_walk_anim = patrol_anim;
//	}
//
//	if ( IsDefined( patrol_twitch_weights ) )
//	{
//		self.patrol_walk_twitch = patrol_twitch_weights;
//	}	
//
//	self thread maps\_patrol::patrol();
//	
//	flag_wait( "_stealth_spotted" );
//	
//	self.moveplaybackrate = self.old_moveplaybackrate;
//}
//
//monitor_someone_became_alert()
//{
//	// This is for enemies to see if they are alerted
//	self endon( "death" );
//	level endon( "bar_strobe_starting" );
//	
//	while ( 1 )
//	{
//		self ent_flag_waitopen( "_stealth_normal" );
//		
//		wait( 1.25 ); //gives player time to kill alerted guy
//		
//		if ( !stealth_is_everything_normal() )
//		{
//			//flag_set( "stealth_broken" ); //nope everything not normal, start fail.
//		}
//	}
//}

stop_magic_bullet_shield_if_on()
{
	if ( IsDefined( self.magic_bullet_shield ) && self.magic_bullet_shield == true )
		self stop_magic_bullet_shield();
}

add_magic_bullet_shield_if_off()
{
	if ( !IsDefined( self.magic_bullet_shield ) )
		self magic_bullet_shield();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// Begin generic utilities
/////////////////////////////////////////////////////////////////////////////////////////////////

//patroller_delete_on_path_end()
//{
//	self endon( "death" );
//
//	self waittill_any( "_patrol_reached_path_end", "reached_path_end" );
//	
  //  guys		= [];
  //  guys[ 0 ] = self;
//	
//	thread AI_delete_when_out_of_sight( guys, 750 );
//}

mission_failed_watcher()
{
	msg = flag_wait_any_return( "rorke_killed", "baker_killed", "hvt_got_away" );
	
	quote = undefined;

	switch( msg )
	{
		case "rorke_killed":
			//"Your actions got Merrick killed."
			quote = &"CORNERED_RORKE_WAS_KILLED";
			break;

		case "baker_killed":
			//"Your actions got Hesh killed."
			quote = &"CORNERED_BAKER_WAS_KILLED";
			break;

		case "hvt_got_away":
			//"The HVT got away."
			quote = &"CORNERED_HVT_GOT_AWAY";
			break;
	}

	SetDvar( "ui_deadquote", quote );
	thread maps\_utility::missionFailedWrapper();
	level notify( "stop_mission_failed_watcher" );
}

start_optional_objective()
{
	if ( !flag( "double_agent_confirmed" ) )
		return;
		
	spawner = GetEnt( "double_agent_meet", "targetname" );
	spawner add_spawn_function( ::double_agent_spawn );
	spawner add_spawn_function( ::double_agent_died );
		
	trigger = GetEnt( "optional_objective", "targetname" );
	trigger waittill( "trigger" );
	
	double_agent = spawner spawn_ai( true );
	double_agent disable_arrivals();
	double_agent set_generic_idle_anim( "patrol_idle_gundown" );
	double_agent set_generic_run_anim_array( "patrol_walk_gundown", undefined, false );

	pos						= getstruct( "agent_pos", "targetname" );
	double_agent.goalradius = 8;
	double_agent.noTeleport = true;
	double_agent SetGoalPos( pos.origin );
	double_agent.animname = "generic";
	double_agent thread smart_dialogue( "cornered_us1_friendlyatyour12" );
	double_agent waittill( "goal" );
	double_agent OrientMode( "face angle", pos.angles[ 1 ] );
	pos anim_generic_custom_animmode( double_agent, "gravity", "patrol_stop", undefined, undefined, true );
	double_agent waittillmatch( "custom_animmode", "end" );
	pos thread anim_generic_custom_animmode_loop( double_agent, "gravity", "patrol_idle_gundown", undefined, undefined, true );
	
	double_agent SetCursorHint( "HINT_NOICON" );
	//"Press and hold [{+activate}] to take the stolen data. "
	double_agent SetHintString( &"CORNERED_OPTIONAL_TAKE" );
	double_agent MakeUsable();
	
	double_agent waittill( "trigger" );
	double_agent thread double_agent_animate_give( pos );
	
	double_agent MakeUnusable();
	
	if ( !IsDefined( double_agent ) || !IsAlive( double_agent ) )
		return;
		
	double_agent magic_bullet_shield();
	
	flag_set( "obj_optional_agent_complete" );
	double_agent smart_dialogue( "cornered_us1_heresthedata" );
//	if ( level.player HasWeapon( "flash_grenade" ) )
//		level.player TakeWeapon( "flash_grenade" );
//	level.player GiveWeapon( "concussion_grenade" );
//	temp_dialogue( "Jackson", "And here, take these. Compliments of the Federation Weapons Program.", 4 );
	
	wait 8;
	
	if ( !flag( "junction_entrance_close" ) )
		double_agent smart_dialogue( "cornered_us1_keepmoving" );
}

double_agent_animate_give( pos )
{
	self endon( "death" );
	
	pos anim_generic_custom_animmode( self, "gravity", "patrol_twitch4", undefined, undefined, true );
	self waittillmatch( "custom_animmode", "end" );
	pos thread anim_generic_custom_animmode_loop( self, "gravity", "patrol_idle_gundown", undefined, undefined, true );
}

double_agent_died()
{
	level endon( "obj_optional_agent_complete" );
	level endon( "junction_entrance_close" );
	
	self waittill( "death" );
	
	Objective_State( 7, "failed" );
}

double_agent_spawn()
{
	self.ignoreall = true;
	self.ignoreme  = true;
	
	flag_wait( "junction_entrance_close" );
	waittillframeend;
	
	if ( !flag( "obj_optional_agent_complete" ) )
		Objective_State( 7, "failed" );
	
	if ( IsDefined( self.magic_bullet_shield ) )
		self stop_magic_bullet_shield();
	self Delete();
}