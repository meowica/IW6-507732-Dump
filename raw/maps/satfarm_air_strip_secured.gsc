#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\satfarm_code;

air_strip_secured_init()
{
	level.start_point = "air_strip_secured";
	
	//"Rendesvouz with Bravo Team."
	Objective_Add( obj( "rendesvouz" ), "invisible", &"SATFARM_OBJ_RENDESVOUZ" );
	objective_state_nomessage( obj( "rendesvouz" ), "done" );
	//"Reach the Air Strip."
	Objective_Add( obj( "reach_air_strip" ), "invisible", &"SATFARM_OBJ_REACH_AIR_STRIP" );
	objective_state_nomessage( obj( "reach_air_strip" ), "done" );
	//"Destroy Air Strip defenses."
	Objective_Add( obj( "air_strip_defenses" ), "invisible", &"SATFARM_OBJ_DESTROY_AIR_STRIP_DEFENSES" );
	objective_state_nomessage( obj( "air_strip_defenses" ), "done" );
	
	kill_spawners_per_checkpoint( "air_strip_secured" );
}

air_strip_secured_main()
{
	if ( level.start_point == "air_strip_secured" )
	{
		spawn_player_checkpoint( "air_strip_secured" );
	}
	
	kill_spawners_per_checkpoint( "air_strip_secured" );
	
	level.start_point = "air_strip_secured"; //hmm, manually setting this here because spawn allies is trying to spawn allies in when just "air_strip" is the level.start_point and there are no ally spawn point structs in that section
	
	spawn_allies();
		
	if ( !IsDefined( level.playertank ) )
	{

	}
	else
	{

	}
	
	level.send_enemy_for_player_trigger trigger_on();

	thread air_strip_secured_begin();
	
	flag_wait( "air_strip_secured_end" );
}

air_strip_secured_begin()
{
	enemies = GetAIArray( "axis" );
	thread AI_delete_when_out_of_sight( enemies, 2048 );
	
	enemytanks = getVehicleArray();
	
	foreach ( enemytank in enemytanks )
	{
		if ( IsDefined( enemytank.script_team ) && enemytank.script_team == "axis" )
		{
			enemytank thread enemytank_cleanup();
		}
	}
	
	hangar_door_breakable = GetEnt( "hangar_door_breakable", "targetname" );
	if ( IsDefined( hangar_door_breakable ) )
		hangar_door_breakable Delete();
	
	thread air_strip_victory();
	
	autosave_by_name( "air_strip_secured" );

}

air_strip_victory()
{
	green_smoke_structs = getstructarray( "green_smoke_structs", "targetname" );
	
	foreach ( green_smoke_struct in green_smoke_structs )
	{
		wait( RandomFloatRange( 0.1, 2.0 ) );
		
		PlayFX( level._effect[ "signal_smoke_green" ], green_smoke_struct.origin );
	}
	
	wait( 1.0 );
	
	thread air_strip_secured_vo();
	
	level thread maps\satfarm_audio::overlord_trans();
	
	wait( 1.0 );
	
	if ( IsDefined( level.playertank ) )
	{
		level.playertank dismount_tank( level.player );
	}
	
	level.player thread air_strip_to_chopper();
}

victory_choppers_land()
{
	self ent_flag_init( "landed" );
    self ent_flag_wait( "landed" );
   
    self Vehicle_Teleport( self.origin, self.angles );
    
    guys = self vehicle_unload();
    
    foreach ( guy in guys )
	{
		if ( IsDefined( guy ) )
			guy.ignoreall = 1;
			guy.ignoreme  = 1;
	}
    
    flag_wait( "player_landed" );
    
    foreach ( guy in guys )
	{
		if ( IsDefined( guy ) )
			guy Delete();
	}
    
    if ( IsDefined( self ) )
    	self Delete();
}

#using_animtree( "generic_human" );
ally_chopper_unload()
{
	flag_wait( "enable_ghost2_rappel" );
	level.ally_littlebird_1 thread littlebird_hover();
	flag_wait( "enable_player_rappel" );
	
	//ally_chopper_anim_struct = getstruct( "ally_chopper_anim_struct", "targetname" );
	level.player_chopper_anim_struct = getstruct( "player_chopper_anim_struct", "targetname" );
	level.allies[ 1 ] allies_jump_to_tower( level.ally_littlebird_1 );
	
	flag_set( "ghost2_landed" );
	
	flag_wait( "ghost2_littlebird_path_end" );
	
	level.ally_littlebird_3 Delete();
}

littlebird_hover()
{	
	self SetGoalYaw( self.angles[ 1 ] );
	self SetTargetYaw( self.angles[ 1 ] );	
	self SetHoverParams( 4, 2, 2 );
	self SetMaxPitchRoll( 10, 10 );
	self SetVehGoalPos( self.origin, 1 );
	self Vehicle_SetSpeedImmediate( 0 );
	self Vehicle_Teleport( self.origin, self.angles );
}

air_strip_to_chopper()
{
	new_slamout_test();
	
	thread chopper_drive_in_vo();

	thread control_room_combat();
	
	flag_wait( "enable_player_rappel" );
	level.player_littlebird thread littlebird_hover();
	wait( 0.5 );
	//Merrick: Jump, Adam!
	thread radio_dialog_add_and_go( "satfarm_mrk_jumpadam" );
	
	level.allies[ 0 ] SetLookAtEntity();
	
//	level.player_chopper_anim_struct = getstruct( "player_chopper_anim_struct", "targetname" );
	
//	level.allies[ 1 ].get_out_override = %satfarm_control_tower_merrick;
	level.allies[ 0 ] thread allies_jump_to_tower( level.player_littlebird );
	
	self thread display_hint( "HINT_RAPPEL" );
	
	level.player.ignoreme = false;
	
//	player_wait_for_jump_button();

//	level.player PlayerSetGroundReferenceEnt( undefined );
  
	thread player_jump_to_tower();
	
	flag_wait( "player_landed" );
	
	if ( IsDefined( level.player_littlebird ) )
		level.player_littlebird Delete();
	
//	flag_wait( "control_room_enemies_dead" );
	
	flag_set( "air_strip_secured_end" );
}

/*
player_wait_for_jump_button()
{	
	NotifyOnCommand( "playerjump", "+gostand" );
	NotifyOnCommand( "playerjump", "+moveup" );
			
	level.player waittill( "playerjump" );

	flag_set( "start_rappel" );
}
*/

allies_jump_to_tower( vehicle )
{
	//vehicle vehicle_unload();
	self notify( "unload" );
	self anim_stopanimscripted();
	self Unlink();
	vehicle.riders = [];
	level.player_chopper_anim_struct anim_single_solo( self, "satfarm_control_tower_" + self.animname );
	activate_trigger_with_targetname( "move_" + self.animname + "_to_control_room" );
}

player_jump_to_tower()
{
	NotifyOnCommand( "playerjump", "+gostand" );
	NotifyOnCommand( "playerjump", "+moveup" );
			
	level.player waittill( "playerjump" );

	flag_set( "start_rappel" );
	
	level.player PlayerSetGroundReferenceEnt( undefined );

	level.player AllowProne( false );
   	level.player AllowCrouch( false );
   	level.player AllowSprint( false );
   	level.player AllowJump( false );
   	level.player DisableWeapons();
	
   	player_arms = spawn_anim_model( "player_arms" );
   	player_arms Hide();
   	
   	level.player_chopper_anim_struct anim_first_frame_solo( player_arms, "satfarm_control_tower_player" );

	level.player PlayerLinkToDelta( player_arms, "tag_player", 0, 15, 15, 10, 10, 0 );
 	player_arms Show();
	level.player_chopper_anim_struct anim_single_solo( player_arms, "satfarm_control_tower_player" );
	level.player AllowProne( true );
   	level.player AllowCrouch( true );
   	level.player AllowSprint( true );
   	level.player AllowJump( true );
	level.player EnableWeapons();
	level.player Unlink();
	player_arms Delete();
	
	flag_set( "player_landed" );
   	
	/*
	rappel_end_point = getstruct( "rappel_end_point", "targetname" );
	
	linker = level.player spawn_tag_origin();
	
	level.player AllowProne( false );
   	level.player AllowCrouch( false );
   	level.player AllowSprint( false );
   	level.player AllowJump( false );
	
	level.player PlayerLinkToDelta( linker, "tag_origin", 0, 15, 15, 10, 10, 0 );
	
	linker MoveTo( rappel_end_point.origin, 1 );
	linker RotateTo( rappel_end_point.angles, 1 );
	wait( 1 );
	
	level.player AllowProne( true );
   	level.player AllowCrouch( true );
   	level.player AllowSprint( true );
   	level.player AllowJump( true );
	
	level.player Unlink();
	
	level.player_littlebird maps\_vehicle_aianim::guy_unload( level.allies[ 0 ], 6 );
		
	tower_ghost1_struct = getstruct( "ghost1_control_room_teleport_struct", "targetname" );
	level.allies[ 0 ] ForceTeleport( tower_ghost1_struct.origin, tower_ghost1_struct.angles );
	
	flag_set( "player_landed" );
	
	wait( 0.05 );
	
	level.allies[ 0 ] SetLookAtEntity();
	*/
}

HINT_RAPPEL_OFF()
{
	return flag( "start_rappel" );
}

air_strip_secured_vo()
{
	//Badger: Overlord, airstrip is secure.
	radio_dialog_add_and_go( "satfarm_bgr_overlordairstripissecure" );
	
	wait( 0.5 );
	
	//Overlord: High Value Acquisition underway in Foxtrot-9 – Ghost Team is active, repeat Ghosts are en route.
	radio_dialog_add_and_go( "satfarm_hqr_highvalueacquisition" );
}

chopper_drive_in_vo()
{
	//Merrick: Air Base is up ahead!  There’s a network of train tunnels below that we can follow to Vargas.
	radio_dialog_add_and_go( "satfarm_mrk_airbaseisup" );
	
	//Hesh: We miss him here we might not get another shot.
	radio_dialog_add_and_go( "satfarm_hsh_wemisshimhere" );
	
	level.player_littlebird thread vehicle_ai_event( "idle_alert" );
	
	//Merrick: You’ll get your chance, ready weapons.
	radio_dialog_add_and_go( "satfarm_mrk_youllgetyourchance" );
	
	//"Reach the train."
	Objective_Add( obj( "train" ), "current", &"SATFARM_OBJ_TRAIN" );
	
	wait( 3 );
	level.allies[ 0 ] thread merrick_shoot_until_player_jumps_into_tower();
	
//	flag_wait_any( "control_room_enemies_dead", "player_ready_for_javelin_nest" );
	
//	wait( 2.5 );
	//Merrick: Overlord, Ghost Team is in the target building.
//	radio_dialog_add_and_go( "satfarm_mrk_overlordghostteamis" );
	
	//Overlord: Solid Copy, good luck gentlemen.
//	radio_dialog_add_and_go( "satfarm_hqr_solidcopygoodluck" );
}

control_room_combat()
{
	autosave_by_name( "chopper_ride_in" );
	wait( 0.5 );
	
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	
	array_spawn_function_targetname( "control_room_enemies", ::control_room_enemy_setup );
	level.control_room_enemies = array_spawn_targetname( "control_room_enemies", true ); //8

	thread ai_array_killcount_flag_set( level.control_room_enemies, 3, "spawn_control_room_enemies_wave_2" );
	
	flag_wait_either( "spawn_control_room_enemies_wave_2", "enable_player_rappel" );
	array_spawn_function_targetname( "control_room_enemies_wave_2", ::control_room_enemy_wave_2_setup );
	control_room_enemies_wave_2 = array_spawn_targetname( "control_room_enemies_wave_2", true ); //4
	level.control_room_enemies	= array_combine( level.control_room_enemies, control_room_enemies_wave_2 );

	flag_wait( "player_landed" );
	
	level.control_room_enemies = array_removeDead_or_dying( level.control_room_enemies );
	volume					   = GetEnt( "control_room_lower_volume", "targetname" );
	foreach ( enemy in level.control_room_enemies )
	{
		enemy set_fixednode_false();
		enemy SetGoalVolumeAuto( volume );	
	}

	while ( level.control_room_enemies.size > 4 )
	{
		level.control_room_enemies = array_removeDead_or_dying( level.control_room_enemies );	
		wait( 0.05 );
	}
	
	volume = GetEnt( "control_room_back_volume", "targetname" );
	if ( !( level.player IsTouching( volume ) ) )
	{
		control_room_enemies_wave_3 = array_spawn_targetname( "control_room_enemies_wave_3", true ); //2
		level.control_room_enemies	= array_combine( level.control_room_enemies, control_room_enemies_wave_3 );
	}
	
//	thread control_room_combat_movement();

	while ( level.control_room_enemies.size > 3 )
	{
		level.control_room_enemies = array_removeDead_or_dying( level.control_room_enemies );	
		wait( 0.05 );
	}
	
	flag_set( "control_room_three_left" );
	
	waittill_dead_or_dying( level.control_room_enemies, ( level.control_room_enemies.size - 1 ) );
	level.control_room_enemies = array_removeDead_or_dying( level.control_room_enemies );
	if ( IsDefined( level.control_room_enemies[ 0 ] ) )
	{
		level.control_room_enemies[ 0 ] ClearGoalVolume();
		level.control_room_enemies[ 0 ].health = 50;
		level.control_room_enemies[ 0 ] player_seek_enable();
	}

	thread cleanup_enemies( "start_loading_bay_runners", level.control_room_enemies );
	
	waittill_dead_or_dying( level.control_room_enemies );
	flag_set( "control_room_enemies_dead" );
}

control_room_combat_movement()
{
	wait( 5 );
	volume								 = GetEnt( "control_room_lower_back_room_volume", "targetname" );
	control_room_lower_back_room_enemies = volume get_ai_touching_volume( "axis" );
	
	while ( 1 )
	{
		if ( control_room_lower_back_room_enemies.size < 2 )
		{
			break;
		}
		wait( 0.05 );
	}
	
	volume					   = GetEnt( "control_room_lower_volume", "targetname" );
	control_room_lower_enemies = volume get_ai_touching_volume( "axis" );
	if ( control_room_lower_enemies.size > 0 )
	{
		control_room_lower_enemies set_fixednode_false();
		volume = GetEnt( "control_room_lower_back_room_volume", "targetname" );
		control_room_lower_enemies[ 0 ] SetGoalVolumeAuto( volume );
	}
}

control_room_enemy_setup()
{
	self endon( "death" );
	
	self.health	  = 50;
	self.accuracy = 0.01;
	self set_baseaccuracy( 0.01 );
	self.ignoreme = 1;

	if ( self.target == "control_room_upper_volume" )
	{
		self.favoriteenemy = level.allies[ 0 ];
	}
	else if ( self.target == "control_room_lower_volume" )
	{
		self.favoriteenemy = level.allies[ 1 ];
	}
	
	flag_wait( "start_control_room_combat" );
	wait( 1 );
	self.ignoreme = 0;

	
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "control_room_runner_1" )
	{
		self magic_bullet_shield();
		flag_wait( "start_control_room_combat" );
		wait( 2 );
		self stop_magic_bullet_shield();
		self set_fixednode_false();
		volume		= GetEnt( "control_room_upper_volume", "targetname" );
		self SetGoalVolumeAuto( volume );
	}
	
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "hidden_enemies" )
	{
		self magic_bullet_shield();
		flag_wait( "player_landed" );
		self stop_magic_bullet_shield();
		self.ignoreme = 1;
		self set_fixednode_false();
		volume		  = GetEnt( "control_room_lower_volume", "targetname" );
		self SetGoalVolumeAuto( volume );
		self waittill( "goal" );
		self.ignoreme = 0;
	}
	
	if ( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "enemy_for_player" )
	{
		self.ignoreme = 1;
		self magic_bullet_shield();
		flag_wait( "send_enemy_for_player" );
		self stop_magic_bullet_shield();
		self.favoriteenemy = level.allies[ 0 ];
		self set_fixednode_false();
		volume			   = GetEnt( "control_room_upper_volume", "targetname" );
		self SetGoalVolumeAuto( volume );
		self waittill( "goal" );
		self.ignoreme = 0;
	}
	
	flag_wait( "player_landed" );
	self.favoriteenemy = undefined;
	
}

control_room_enemy_wave_2_setup()
{
	self endon( "death" );
	
	if ( self.target == "control_room_balcony_volume" )
	{
		wait( 0.5 );
		level.control_room_enemies = array_remove( level.control_room_enemies, self );
		flag_wait_any( "control_room_three_left", "player_leaving_control_room" );
		self.ignoreall = 1;
		wait RandomFloatRange( 0.3, 0.8 );
		volume		= GetEnt( "upper_delete_volume", "targetname" );
		self SetGoalVolumeAuto( volume );
		
		while ( 1 )
		{
			if ( self IsTouching( volume ) )
			{
				break;
			}
		
			wait( 0.05 );
		}
		
		volume = GetEnt( "upper_volume", "targetname" );
		if ( level.player IsTouching( volume ) )
		{
			self.ignoreall = 0;
			self player_seek_enable();
		}
		else
		{
			self Delete();	
		}
	}
}

new_slamout_test()
{		
	player_link		   = Spawn( "script_model", level.player.origin );
	player_link.angles = level.player GetPlayerAngles();
	player_link SetModel( "tag_origin" );
	
	level.player FreezeControls( true );
	level.player SetStance( "stand" );
	level.player AllowCrouch( false );
	level.player PlayerLinkToAbsolute( player_link, "tag_origin" );
	
	level.player EnableInvulnerability();
	level.player HideViewModel();
	level.player DisableWeapons();
	level.player DisableOffhandWeapons();
	level.player.ignoreme = true;
	
	final_orign	 = ( level.player.origin[ 0 ], level.player.origin[ 1 ], 12000 );
	final_angles = ( 87, 27.3719, level.player.angles[ 2 ] );

	//player_link unlink();
	player_link MoveZ( 12000, 3.0, 1.8 );		// old times - 1.8, 1.4, .4
	//player_link MoveZ( 12000, 1.8, 1.8 );		// old times - 1.8, 1.4, .4
	player_link thread play_loop_sound_on_entity( "satf_slamout_static" );
	
	player_link RotateTo( final_angles, 0.3, 0.3 );
	player_link thread play_sound_on_entity( "satf_player_slamzoom_out" );
	wait( 1.1 );
	
	thread maps\satfarm_fx::overlord_transition_fx();
	thread sat_view_ally_and_enemy_tanks();
			
	//thread slamout_static( 0.2 );
	//thread fade_out_in( "overlay_static", 0.3, 1 );
	VisionSetNaked( "satfarm_satellite_view", 2 );
	wait( 1.5 );
	player_link thread stop_loop_sound_on_entity( "satf_slamout_static" );
	
	air_strip_sat_view_org		= GetEnt( "air_strip_sat_view_org", "targetname" );
	player_link_sat_view		= Spawn( "script_model", air_strip_sat_view_org.origin );
	player_link_sat_view.angles = air_strip_sat_view_org.angles;
	player_link_sat_view SetModel( "tag_origin" );
	player_link_sat_view.origin += AnglesToUp( player_link_sat_view.angles ) * 500;
	level.player PlayerLinkToAbsolute( player_link_sat_view, "tag_origin" );
	
	//VisionSetNaked( "satfarm_satellite_view", 0.0 );
	
	player_link_sat_view MoveTo( player_link_sat_view.origin + AnglesToRight( player_link_sat_view.angles ) * -20, 2.25 );
	player_link_sat_view RotateTo( player_link_sat_view.angles + ( -1, -1, 1 ), 2.25 );
	
	level.player maps\satfarm_satellite_view::satellite_view_init_hud();
	
	wait( 1.25 ); //wait a moment to get your bearings with the sat view
	
	level.player maps\satfarm_satellite_view::satellite_view_move_to_point( 45, 60, 0.5 );
	
	level notify( "populate_sat_view_tank_icons" );

	wait( 1.0 );
	
	level.player maps\satfarm_satellite_view::satellite_view_move_to_point( 0, 0, 0.5 );
	
	new_loc = level.playertank.origin + AnglesToForward( level.playertank.angles ) * 475 + AnglesToRight( level.playertank.angles ) * 450 - AnglesToForward( player_link_sat_view.angles ) * ( player_link_sat_view.origin[ 2 ] - level.playertank.origin[ 2 ] );
	player_link_sat_view MoveTo( new_loc, 0.5 );
	
	wait 0.5;
	
	player_link_sat_view LinkTo( level.playertank );
	
	wait 0.25;
	
	level.player LerpFOV( 30, 0.25 );
	
	wait 0.75;
	
	//"Badger-1"
	level.player maps\satfarm_satellite_view::satellite_view_pip_display_name( &"SATFARM_BADGER_1" );
	level.player maps\satfarm_satellite_view::satellite_view_pip_enable( level.playertank, "tag_player" );
	
	wait( 1.0 ); //wait a moment for ally and enemy tanks to populate and for VO to play
	
	level.playertank shoot_anim();
	
	level notify( "spawn_ally_choppers_and_tanks" );
	
	wait( 1.5 ); //wait a moment for ghost team to enter the sat view before sat view crosshair starts to move to them
	
	level.player maps\satfarm_satellite_view::satellite_view_pip_display_name( "" );
	level.player maps\satfarm_satellite_view::satellite_view_pip_change_size( 32, 32, 0.25 );
	level.player maps\satfarm_satellite_view::satellite_view_pip_disable();
	
	player_link_sat_view Unlink();
	level.player LerpFOV( 65, 0.25 );
	
	player_link_sat_view MoveTo( player_link_sat_view.origin - AnglesToRight( player_link_sat_view.angles ) * 2000 + AnglesToUp( player_link_sat_view.angles ) * 2000, 0.5 );
	player_link_sat_view RotateTo( player_link_sat_view.angles + ( -1, -1, 1 ), 2 );
	
	wait 0.5;
	
	player_link_sat_view MoveTo( player_link_sat_view.origin - AnglesToRight( player_link_sat_view.angles ) * 25, 1.5 );
	
	wait 0.25;
	
	level.player maps\satfarm_satellite_view::satellite_view_move_to_point( -360, -115, 1.0 );
	
	wait( 1.5 ); //wait for sat view crosshair to move over ghost team's general position
	
	level.player maps\satfarm_satellite_view::satellite_view_move_to_point( 0, 0, 0.45 );
	
	new_loc = level.player_littlebird.origin - AnglesToForward( level.player_littlebird.angles ) * 1000 + AnglesToRight( level.player_littlebird.angles ) * 550 - AnglesToForward( player_link_sat_view.angles ) * ( player_link_sat_view.origin[ 2 ] - level.player_littlebird.origin[ 2 ] );
	player_link_sat_view MoveTo( new_loc, 0.5 );
	
	wait 0.5;
	

/*	
	player_link_sat_view MoveTo( player_link_sat_view.origin + AnglesToRight( player_link_sat_view.angles ) * -50, 5.5 );
	player_link_sat_view RotateTo( player_link_sat_view.angles + ( -2.5, -2.5, 2.5 ), 5.5 );
*/

	player_link_sat_view LinkTo( level.player_littlebird );
	level.player LerpFOV( 30, 0.25 );
	
	wait 0.5;
	
	//"Ghost-1"
	level.player maps\satfarm_satellite_view::satellite_view_pip_display_name( &"SATFARM_GHOST_1" );
	level.player maps\satfarm_satellite_view::satellite_view_pip_enable( level.player_littlebird, "tag_player" );
	
	wait( 2.0 ); //wait for a moment to play vo and set up ghost team

	foreach ( index, border in level.satellite_view_borders )
	{
		border.vertical.alpha	= 0;
		border.horizontal.alpha = 0;
	}
	
	thread delete_temp_sat_view_targets();

	level.player maps\satfarm_satellite_view::satellite_view_pip_change_size( 888, 500, 0.5 );
//	level.player maps\satfarm_satellite_view::satellite_view_move_to_point( -320, -240, 0.5 );
	level.player maps\satfarm_satellite_view::satellite_fade_hud( 0.5 );
	level.player LerpFOV( 65, 0.05 );
	
	wait 0.5;
	
	VisionSetNaked( "satfarm", 0.0 );
	
	level.player SetOrigin( level.player_littlebird GetTagOrigin( "tag_player" ) );
	level.player SetPlayerAngles( level.player_littlebird GetTagAngles( "tag_player" ) );
	level.player PlayerLinkToAbsolute( level.player_littlebird, "tag_player" );
	
	wait 1;
	
	level.player maps\satfarm_satellite_view::satellite_view_clear_hud();
	
	level.player ShowViewModel();
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player FreezeControls( false );
	level.player PlayerClearStreamOrigin();
	level.player DisableInvulnerability();
	level.player Unlink();
	level.player PlayerLinkToDelta( level.player_littlebird, "tag_player", 1, 0, 165, 35, 35, true );
}

slamout_static( start_delay )
{
	//a  fullscreen snap of pip mode with staticon 
	if ( IsDefined( start_delay ) )
	{
		wait( start_delay );
	}	

	overlay	  = NewHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay SetShader( "overlay_static", 640, 480 ); //"black", "white"
	overlay.alignX	  = "left";
	overlay.alignY	  = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	
	//starts strong
	overlay.alpha = 0.4;
	//out to 0 
	overlay FadeOverTime( 0.2 );
	overlay.alpha = 0;
	wait( 0.2 );
	//back in 
	overlay FadeOverTime( 0.2 );
	overlay.alpha = 0.9;
	wait( 0.4 );
	
	//back out
	overlay FadeOverTime( 0.2 );
	overlay.alpha = 0;
	
	
	wait( 1 );
	//out
	overlay Destroy();
	
}

fade_out_in( fade_color, time, time_out )
{
	if ( !IsDefined( time_out ) )
	{
		time_out = time * 0.5;
		time	 = time_out;
	}
	
	//fade out/fade in on flag
	overlay	  = NewHudElem();
	overlay.x = 0;
	overlay.y = 0;
	overlay SetShader( fade_color, 640, 480 ); //"black", "white"
	overlay.alignX	  = "left";
	overlay.alignY	  = "top";
	overlay.horzAlign = "fullscreen";
	overlay.vertAlign = "fullscreen";
	overlay.alpha	  = 0;
	overlay.sort	  = -1;
	overlay FadeOverTime( time );
	overlay.alpha = 1;
	
	wait( time );

	
	wait( time_out );
	
	overlay FadeOverTime( time_out );
	overlay.alpha = 0;	
	wait( 1 );

	overlay Destroy();
}

sat_view_ally_and_enemy_tanks()
{
	if ( IsDefined( level.playertank ) )
	{
		level.playertank Delete();
	}
	
	if ( IsDefined( level.herotanks ) )
	{
		foreach ( tank in level.herotanks )
		{
			tank Delete();
		}
	}
	
	sat_view_ally_tanks = spawn_vehicles_from_targetname_and_drive( "sat_view_ally_tanks" );
	level.allytanks		= array_combine( level.allytanks, sat_view_ally_tanks );
	level.playertank	= sat_view_ally_tanks[ 0 ];
	array_thread( sat_view_ally_tanks, ::npc_tank_combat_init );
	
	level.sat_view_enemy_tanks = spawn_vehicles_from_targetname_and_drive( "sat_view_enemy_tanks" );
	level.enemytanks		   = array_combine( level.enemytanks, level.sat_view_enemy_tanks );
			  //   entities 				   process 				    
	array_thread( level.sat_view_enemy_tanks, ::npc_tank_combat_init );
	array_thread( level.sat_view_enemy_tanks, ::remove_target_on_death );
	
	level waittill( "populate_sat_view_tank_icons" );
	
	thread air_strip_secured_tank_ambient();
	
	level.temp_sat_view_target_ents = [];
	
	foreach ( tank in sat_view_ally_tanks )
	{
		thread target_enable_sat_view( tank, "ac130_hud_friendly_vehicle_diamond_s_w", ( 0, 1, 0 ) );
		
		wait( 0.2 );
	}
	
	foreach ( tank in level.sat_view_enemy_tanks )
	{
		thread target_enable_sat_view( tank, "ac130_hud_enemy_vehicle_target_s_w", ( 1, 0, 0 ) );
		
		wait( 0.2 );
	}
	
	level notify( "spawn_ally_choppers_and_tanks" );
	
	level.player_littlebird			= spawn_vehicle_from_targetname_and_drive( "player_littlebird" );
	level.player_littlebird thread maps\_vehicle_aianim::guy_enter( level.allies[ 0 ] );
	
	wait( 0.05 );

	level.player_littlebird thread vehicle_ai_event( "idle_alert_to_casual" );
	
	level.ally_littlebird_1 = spawn_vehicle_from_targetname_and_drive( "ally_littlebird_1" );
	level.ally_littlebird_1 thread maps\_vehicle_aianim::guy_enter( level.allies[ 1 ] );
	level.ally_littlebird_1 thread ally_chopper_unload();
	
	level.ally_littlebird_2 = spawn_vehicle_from_targetname_and_drive( "ally_littlebird_2" );
	level.ally_littlebird_2 thread victory_choppers_land();
	
	victory_tanks_hangar_minigunners = spawn_vehicles_from_targetname_and_drive( "victory_tanks_hangar_minigunners" );
	        	
	thread target_enable_sat_view( level.player_littlebird, "ac130_hud_friendly_vehicle_diamond_s_w", ( 0, 1, 0 ) );
	
	wait( 0.2 );
	
//	thread target_enable_sat_view( level.ally_littlebird_3, "ac130_hud_friendly_vehicle_diamond_s_w", ( 0, 1, 0 ) );
		
	wait( 0.2 );
	
	thread target_enable_sat_view( level.ally_littlebird_1, "ac130_hud_friendly_vehicle_diamond_s_w", ( 0, 1, 0 ) );
		
	wait( 0.2 );
	
	thread target_enable_sat_view( level.ally_littlebird_2, "ac130_hud_friendly_vehicle_diamond_s_w", ( 0, 1, 0 ) );
	
	wait( 2.0 );
	
	victory_a10s = spawn_vehicles_from_targetname_and_drive( "victory_a10s" );
	
	wait( 2.0 );
	
	victory_tanks_air_strip_horizon = spawn_vehicles_from_targetname_and_drive( "victory_tanks_air_strip_horizon" );
	
	wait( 2.0 );
	
	victory_tanks = spawn_vehicles_from_targetname_and_drive( "victory_tanks" );
	
	flag_wait( "player_landed" );
	
	foreach ( tank in sat_view_ally_tanks )
	{
		if ( IsDefined( tank ) )
			tank Delete();
	}
		
	foreach ( tank in level.sat_view_enemy_tanks )
	{
		if ( IsDefined( tank ) )
			tank Delete();
	}
	
	foreach ( tank in victory_tanks )
	{
		if ( IsDefined( tank ) )
			tank Delete();
	}
	
	foreach ( tank in victory_tanks_air_strip_horizon )
	{
		if ( IsDefined( tank ) )
			tank Delete();
	}
	
	foreach ( tank in victory_tanks_hangar_minigunners )
	{
		if ( IsDefined( tank ) )
			tank Delete();
	}
	
//	if ( IsDefined( level.player_littlebird ) )
//		level.player_littlebird Delete();
	
	level.playertank = undefined;
}

delete_temp_sat_view_targets()
{
	foreach ( ent in level.temp_sat_view_ents )
	{
		if ( IsDefined( ent ) && !ent maps\_vehicle_code::is_corpse() )
			Target_Remove( ent );
	}
}

target_enable_sat_view( target, shader, color )
{
	if ( !IsDefined( target ) )
		return;
	
	offset = ( 0, 0, 0 );
	
	Target_Alloc( target, offset );
	Target_SetShader( target, shader );
	
	Target_SetScaledRenderMode( target, true );	
	
	Target_DrawSquare( target );
	Target_DrawSingle( target );
	//Target_DrawCornersOnly( target, true );	
	
	if ( IsDefined( color ) )
		Target_SetColor( target, color );
	Target_SetMaxSize( target, 24 );
	Target_SetMinSize( target, 16, false );
	
	Target_Flush( target );
	
	level.temp_sat_view_ents = add_to_array( level.temp_sat_view_ents, target );
}

merrick_shoot_until_player_jumps_into_tower()
{
	wait( 1.0 );
	
	while ( !flag( "enable_player_rappel" ) )
	{
		if ( IsAlive( self.enemy ) )
		{
			self SetLookAtEntity( self.enemy );
			self Shoot();
			wait( 0.1 );
		}
		wait( 0.1 );
	}
}

air_strip_secured_tank_ambient()
{
	wait( 4.0 );
	setup_ambient_tank_drop( "air_strip_secured_tank_ambient", undefined, true, "player_landed" );
}