#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

section_flag_inits()
{
	// catwalks
	flag_init( "flag_cw_bravo_breach_1" );
	flag_init( "flag_cw_bravo_breach_2" );
	flag_init( "flag_cw_bravo_breach" );
	flag_init( "flag_start_retreat" );
	flag_init( "flag_low_retreat" );
	flag_init( "flag_low_runaway" );
	flag_init( "flag_stairs_kill" );
	flag_init( "flag_mid_start" );
	flag_init( "flag_low_runaway_again" );
	flag_init( "flag_mid_retreat" );
	flag_init( "flag_high_retreat" );
	flag_init( "flag_no_catwalk_kill" );
	flag_init( "flag_vig_catwalk_kill" );
	flag_init( "flag_tape_breach_ally1" );
	flag_init( "flag_tape_breach_ally2" );
	flag_init( "flag_cw_breach_vo_ready" );
	flag_init( "flag_catwalks_end" );
	
	// barracks
	flag_init( "flag_barracks_go_fast" );
	flag_init( "flag_barracks_ally1_ready" );
	flag_init( "flag_barracks_ally2_ready" );
	flag_init( "flag_barracks_sweep_start" );
	flag_init( "flag_player_in_barracks_room1" );
	flag_init( "flag_player_in_barracks_room2" );
	flag_init( "flag_barracks_opfor_attack" );
	flag_init( "flag_barracks_cleared" );
	
	// common room
	flag_init( "flag_common_player_ready" );
	flag_init( "flag_common_ai_ready" );
	flag_init( "flag_common_breach" );
	flag_init( "flag_common_breach_ally_start" );
	flag_init( "flag_common_breach_done" );
	flag_init( "flag_common_player_inside" );
	flag_init( "flag_common_reinforce" );
	flag_init( "flag_common_retreat" );
	flag_init( "flag_common_end" );
	flag_init( "flag_common_cleared" );
	
	// location tracking
	flag_init( "cw_gps_tape_breach" );
	flag_init( "cw_gps_common_door" );
}

section_precache()
{
}

start_catwalks()
{
	IPrintLn( "Catwalks" );
	
	// teleport player
	player_start( "player_start_catwalks" );
	
	// teleport allies
	node = getstruct( "cw_start_ally1", "targetname" );
	level._allies[ 0 ] ForceTeleport( node.origin, node.angles );
	
	node = getstruct( "cw_start_ally2", "targetname" );
	level._allies[ 1 ] ForceTeleport( node.origin, node.angles );
	
	// set flags
	flag_set( "bc_flag_spots_off" );
	trig = GetEnt( "cw_trig_start_spawn", "script_noteworthy" );
	trig notify_delay( "trigger", 0.1 );
	
	// start ambient sfx
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_oilrig_catwalk", 2 );
	
	//start snow fx
	exploder( "catwalks_snow" );
	exploder( "catwalks_lights" );
	thread catwalk_godrays();
	
	// Cargo
	thread maps\black_ice_ascend::hanging_cargo_motion();
	
	// start catwalks
	thread notify_delay( "notify_ascend_rubberband_alpha_stop", 1.1 );
	delayThread( 1.1, ::flag_set, "flag_ascend_end" );
}

start_catwalks_end()
{
	IPrintLn( "Catwalks End" );
	
	// teleport player
	player_start( "player_start_catwalks_end" );
	
	// teleport allies
	node = getstruct( "cwe_start_ally1", "targetname" );
	level._allies[ 0 ] ForceTeleport( node.origin, node.angles );
	
	node = getstruct( "cwe_start_ally2", "targetname" );
	level._allies[ 1 ] ForceTeleport( node.origin, node.angles );
	
	// take away allies' grenades
	array_thread( level._allies, ::set_grenadeammo, 0 );
	
	// setup enemy spawners
	setup_spawners();
	
	// setup cqb trigs
	trigs = GetEntArray( "cw_trig_enable_cqb", "script_noteworthy" );
	array_thread( trigs, ::trig_enable_cqb );
	
	trigs = GetEntArray( "cw_trig_disable_cqb", "script_noteworthy" );
	array_thread( trigs, ::trig_disable_cqb );
	
	// spawn door
	node				   = GetEnt( "cw_vig_tape_breach", "targetname" );
	level.tape_breach_door = spawn_anim_model( "tape_breach_door" );	
	node anim_first_frame_solo( level.tape_breach_door, "cw_tape_breach" );
	
	// start ambient sfx
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_oilrig_catwalk", 2 );
	
	// Cargo
	thread maps\black_ice_ascend::hanging_cargo_motion();
	
	// set flags and vars
	trig = GetEnt( "cw_color_exit_door", "targetname" );
	trig notify( "trigger" );
	flag_set( "flag_vig_catwalk_kill" );
	level.tele_catwalks_end = true;
}

start_barracks()
{
	IPrintLn( "Barracks" );
	
	// teleport player
	player_start( "player_start_barracks" );
	
	// teleport allies
	node = getstruct( "cwb_start_ally1", "targetname" );
	level._allies[ 0 ] ForceTeleport( node.origin, node.angles );
	
	node = getstruct( "cwb_start_ally2", "targetname" );
	level._allies[ 1 ] ForceTeleport( node.origin, node.angles );
	
	// take away allies' grenades
	array_thread( level._allies, ::set_grenadeammo, 0 );
	
	// setup enemy spawners
	setup_spawners();
	
	// setup cqb trigs
	trigs = GetEntArray( "cw_trig_enable_cqb", "script_noteworthy" );
	array_thread( trigs, ::trig_enable_cqb );
	
	trigs = GetEntArray( "cw_trig_disable_cqb", "script_noteworthy" );
	array_thread( trigs, ::trig_disable_cqb );
	
	// delete door clip
	door_clip = GetEntArray( "cw_clip_tape_breach_door", "targetname" );
	array_call( door_clip, ::Delete );
	
	// stack up at the living quarters doors
	wait( 0.05 );
	array_thread( level._allies, ::set_force_cover, false );
	array_thread( level._allies, ::disable_ai_color );
	node = GetNode( "cwb_node_start_ally1", "targetname" );
	level._allies[ 0 ] thread follow_path( node );
	node = GetNode( "cwb_node_start_ally2", "targetname" );
	level._allies[ 1 ] thread follow_path( node );
	
	exploder ( "barracks_ambfx" );
		
	// start ambient sfx
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_oilrig_int", 2 );
}

start_common()
{
	IPrintLn( "Common Room" );
	
	// teleport player
	player_start( "player_start_common" );
	
	// teleport allies
	node = getstruct( "cwc_start_ally1", "targetname" );
	level._allies[ 0 ] ForceTeleport( node.origin, node.angles );
	
	node = getstruct( "cwc_start_ally2", "targetname" );
	level._allies[ 1 ] ForceTeleport( node.origin, node.angles );
	
	// take away allies' grenades
	array_thread( level._allies, ::set_grenadeammo, 0 );
	foreach( guy in level._allies )
		guy.old_react_dist = guy.newEnemyReactionDistSq;
	
	// setup enemy spawners
	setup_spawners();
	
	// stack up at the common room door
	wait( 0.05 );
	node1 = GetNode( "cwc_node_door_ally1", "targetname" );
	level._allies[ 0 ] thread follow_path( node1 );
	node2 = GetNode( "cwc_node_door_ally2", "targetname" );
	level._allies[ 1 ] thread follow_path( node2 );
	
	//launch ambfx
	exploder ( "barracks_ambfx" );
	
	//launch vision
	vision_set_fog_changes( "black_ice_commonroom", 0 );	
	// start ambient sfx
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_oilrig_int", 2 );		
}

main_catwalks()
{	
	// init catwalks
	thread catwalks_setup();
	
	thread catwalk_godrays();
	
	// thread bravo breach (while player ascends)
	wait( 1 );
	thread cw_bravo_breach();
	
	// init allies
	level waittill( "notify_ascend_rubberband_alpha_stop" );
	array_thread( level._allies, ::set_grenadeammo, 0 );
	level._allies[ 0 ]set_force_color( "r" );
	level._allies[ 1 ]set_force_color( "y" );
	
	// wait for ascend to complete
	flag_wait( "flag_ascend_end" );
	
	// Train (periph) movement
	thread maps\black_ice::trains_periph_logic( 0.0, false );
	
	//vision and snowtweaks
	vision_set_fog_changes( "black_ice_catwalks", 0 );
	SetSavedDvar( "r_snowAmbientColor", ( 0.02, 0.02, 0.03 ) );
	thread rotateLights("light_spinner_h","light_spin_h","yaw");
	thread rotateLights("light_spinner_v","light_spin_v","pitch");
	thread rotateLights("light_spinner_v2","light_spin_v2","pitch");
	
	// encounter flow
	level cw_start();
	level cw_low();
	level cw_mid();
}

catwalks_setup()
{
	// spawn door
	node				   = GetEnt( "cw_vig_tape_breach", "targetname" );
	level.tape_breach_door = spawn_anim_model( "tape_breach_door" );	
	node anim_first_frame_solo( level.tape_breach_door, "cw_tape_breach" );
	
	// setup cqb trigs
	trigs = GetEntArray( "cw_trig_enable_cqb", "script_noteworthy" );
	array_thread( trigs, ::trig_enable_cqb );
	
	trigs = GetEntArray( "cw_trig_disable_cqb", "script_noteworthy" );
	array_thread( trigs, ::trig_disable_cqb );
	
	// setup enemy spawners
	setup_spawners();
	
	// check for bravo setup
	if ( level._bravo.size < 2 )
	{
		// spawn bravo
		level spawn_bravo();
		
		// teleport bravo
		node = getstruct( "cw_start_bravo1", "targetname" );
		level._bravo[ 0 ] ForceTeleport( node.origin, node.angles );
		
		node = getstruct( "cw_start_bravo2", "targetname" );
		level._bravo[ 1 ] ForceTeleport( node.origin, node.angles );
	}
	
	// setup allies
	array_thread( level._bravo, ::set_ignoreall, true );
}

catwalks_end()
{
	// thread fiction
	thread catwalks_end_fic();
	
	// ready allies for door breach
	array_thread( level._allies, ::set_forceSuppression, true );
	
	high_catwalk_kill();
	
	// wait till end of catwalks to blow up door
	flag_wait( "flag_catwalks_end" );
	cw_tape_breach();
	
	// reset default ally behavior
	array_thread( level._allies, ::set_forceSuppression, false );
}

main_barracks()
{
	// save
	autosave_by_name( "barracks_start" );
	
	// encounter flow
	level cw_barracks();	// cwb
}

main_common()
{
	// save
	autosave_by_name( "common_start" );
	
	// encounter flow
	level cw_common();	// cwc
}

//*******************************************************************
//																	*
//		ENCOUNTERS													*
//*******************************************************************

//**************************************************************
//		Catwalks
//**************************************************************
cw_start()
{
	// init and save
	level.player.ignoreme = false;
	autosave_by_name( "catwalk_start" );
	
	// spawn door enemies
	wait( 1 );
	array_spawn_targetname( "cw_opfor_start_door", true );
	
	// open door
	door = setup_door( "cw_low_door" );
	door thread open_door( [ 168, -10 ], 1 );
	// open door sfx
	thread maps\black_ice_audio::sfx_cw_door_open(door);
	
	wait( 1 );
	SetThreatBias( "player", "axis", 0 );
	delay_retreat( "cw_opfor", 60, 3, "flag_start_retreat", "cw_color_low" );
}

cw_low()
{
	// thread fiction
	thread cw_low_fic();
	
	// spawn low opfor
	array_spawn_targetname( "cw_opfor_low_balcony", undefined, true );
	flood_spawn( GetEntArray( "cw_opfor_low", "targetname" ) );
	
	wait( 2 );
	flagWaitThread( "flag_low_runaway", ::flag_set, "flag_low_retreat" );
	delay_retreat( "cw_opfor", 90, 4, "flag_low_retreat", [ "cw_color_low_retreat", "cw_color_low" ], true );
	
	delay_retreat( "cw_opfor", 60, 2, "flag_low_runaway", "cw_color_low_runaway", true, "cw_to_mid_vo_nag" );
	
	// ready allies for next combat
	level.fixednodesaferadius_default = 100;
}

cw_mid()
{	
	flag_wait( "flag_mid_start" );
	
	// thread fiction
	thread cw_mid_fic();
	thread fx_snow_windtunnel();
	
	delay_retreat( "cw_opfor", 90, 2, "flag_high_retreat", [ "cw_color_exit_door", "cw_color_to_high" ], true );
	if ( !flag( "flag_mid_retreat" ) )
		flag_set( "flag_mid_retreat" );
	
	// cleanup high enemies
	thread maps\_spawner::killspawner( 129 );
	thread kill_deathflag( "flag_opfor_high_clear", 1.0 );
	
	// reset default ally combat behavior
	level.fixednodesaferadius_default = undefined;
	
	// go to door breach
	wait( 1 );
	level._allies[0] thread goto_door_breach( "cw_node_tape_breach_ally1", 1.20, "flag_tape_breach_ally1" );
	level._allies[1] thread goto_door_breach( "cw_node_tape_breach_ally2", 1.15, "flag_tape_breach_ally2" );
}

cw_low_fic()
{
	level endon( "stop_low_fic" );
	
	level waittill( "cw_to_mid_vo_nag" );
	//Baker: Move up, Alpha.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_moveupalpha" );
}

cw_mid_fic()
{
	level notify( "stop_low_fic" );
	level endon( "stop_mid_fic" );
	
	//Baker: They have the high ground.  Our 45's will cut through that metal.  
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_cutthroughmetal" );
	
	wait( 10 );
	if ( !flag( "flag_opfor_high_clear" ) )
		//Baker: That cover's useless, take them out.
		level._allies[ 0 ] smart_dialogue( "blackice_bkr_coversuseless" );
}

catwalks_end_fic()
{
	level notify( "stop_mid_fic" );
	
	if( !IsDefined( level.tele_catwalks_end ) )
		//Baker: They're falling back, move up.
		level._allies[ 0 ] smart_dialogue( "blackice_bkr_fallingbackmoveup" );
	
	flag_wait_all( "flag_tape_breach_ally1", "flag_catwalks_end" );
	//Baker: Doors sealed. Fuentes, Shape Charges.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_shapecharges" );
	flag_set( "flag_cw_breach_vo_ready" );
	
	level waittill( "cw_tape_breach_start" );
	//Fuentes: Copy, setting charges.
	level._allies[ 1 ] thread smart_dialogue( "blackice_fnt_settingcharges" );
	level waittill( "cw_tape_breach_cover" );
	//Fuentes: Stand clear.  
	level._allies[ 1 ] smart_dialogue( "blackice_fnt_standclear" );
}

//**************************************************************
//		Barracks
//**************************************************************
cw_barracks()
{
	// go up stairs
	thread cw_stairs_fic();
	
	// setup animated props
	vig_node = GetEnt( "cw_vig_hallway_sweep", "targetname" );
	tv_door = spawn_anim_model( "hallway_door" );
	vig_node anim_first_frame_solo( tv_door, "cw_hallsweep" );
	
	// start barracks sweep
	flag_wait( "flag_barracks_sweep_start" );
	
	// setup fast trigger
	end_trig = GetEnt( "cw_trig_common_ambush", "targetname" );
	thread cw_barracks_fast_trig_proc( end_trig );
	thread cw_barracks_fast_shoot_proc();
	
	// setup dialog cancels
	thread flagWaitThread( "flag_player_in_barracks_room1", maps\_anim::removeNotetrack, "ally2" , "fuentes_va_clear_1", "cw_hallsweep", "dialog" );
	thread flagWaitThread( "flag_player_in_barracks_room2", maps\_anim::removeNotetrack, "ally1" , "baker_vo_clear_1"  , "cw_hallsweep", "dialog" );
	
	// setup opfor
	level.op_barracks = spawn_targetname( "cw_barracks_opfor" );
	
	cw_barracks_setup();
	cw_barracks_slow( vig_node, tv_door );
	cw_barracks_fast( tv_door );
}

cw_barracks_setup()
{
	// get allies ready to move
	array_thread( level._allies, ::disable_cqbwalk );
	array_thread( level._allies, ::set_ignoreall, true );
	foreach( guy in level._allies )
	{
		guy.old_react_dist = guy.newEnemyReactionDistSq;
		guy.newEnemyReactionDistSq = 0;
	}
}

cw_barracks_slow( vig_node, tv_door )
{
	level endon( "flag_barracks_go_fast" );
	if( flag( "flag_barracks_go_fast" ) )
		return;
	
	// hallway sweep init
	flag_wait_all( "flag_barracks_ally1_ready", "flag_barracks_ally2_ready" );
	go_ally1 = GetNode( "cwc_node_door_ally1", "targetname" );
	go_ally2 = GetNode( "cwc_node_door_ally2", "targetname" );
	
	// check ally locations before anim
	foreach( ally in level._allies )
	{
		if( ally.origin != ally.goalpos )
			wait( 0.05 );
	}
	
	// thread music
	thread maps\black_ice_audio::hall_search_music();
	
	wait ( 0.5 );
	//Baker: Move.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_move" );
	//Baker: Rook, check your corners.
	level._allies[ 0 ] delayThread( 1, ::smart_dialogue, "black_ice_bkr_rookcheckyourcorners" );
	
	// hallway sweep anim calls
	vig_node thread anim_generic( level.op_barracks, "cw_hallsweep" );
	vig_node thread anim_single_solo( tv_door, "cw_hallsweep" );
	vig_node thread anim_reach_play( level._allies[ 1 ], "cw_hallsweep", undefined, 0.1, undefined, go_ally2, true );
	vig_node anim_reach_play( level._allies[ 0 ], "cw_hallsweep", undefined, 0.1, undefined, go_ally1, true );
}

cw_barracks_fast( tv_door )
{
	if ( !flag( "flag_barracks_go_fast" ) )
		return;
	
	// init vars
	if( tv_door GetAnimTime( tv_door getanim( "cw_hallsweep" ) ) > 0.16 )
		guys = [ level._allies[0], level._allies[1], level.op_barracks ];
	else
		guys = [ level._allies[0], level._allies[1], level.op_barracks, tv_door ];
	
	// move allies
	array_notify( guys, "anim_reach_play" );
	array_notify( guys, "new_anim_reach" );
	array_thread( guys, ::anim_stopanimscripted );
	array_thread( level._allies, ::disable_cqbwalk );
	array_thread( level._allies, ::enable_careful );
	array_thread( level._allies, ::set_ignoreall, false );
	array_thread( level._allies, ::set_baseaccuracy, 0.25 );
	level._allies[ 0 ]thread set_force_color( "r" );
	level._allies[ 1 ]thread set_force_color( "y" );
	trig = GetEnt( "cw_color_barracks_fast", "targetname" );
	trig notify( "trigger" );
	trig trigger_off();
	
	// thread fiction
	thread cw_barracks_fast_fic();
	
	// move allies after battle
	flag_wait( "flag_barracks_cleared" );
	array_thread( level._allies, ::set_baseaccuracy, 1 );
	
	array_thread( level._allies, ::disable_careful );
	go_ally1 = GetNode( "cwc_node_door_ally1", "targetname" );
	go_ally2 = GetNode( "cwc_node_door_ally2", "targetname" );
	level._allies[ 0 ]thread follow_path( go_ally1 );
	level._allies[ 1 ]thread follow_path( go_ally2 );
}

cw_stairs_fic()
{
	level endon( "flag_barracks_sweep_start" );
	
	wait( 0.5 );
	
	//Merrick: Dealer Two, this is One Actual.  We're internal and movin' on the East side.
	level._allies[ 0 ] smart_dialogue( "black_ice_mrk_dealertwothisis" );
	//Oldboy: Copy, One.
	smart_radio_dialogue( "black_ice_oby_copyone" );
	
	wait( 2 );
	//Baker: Keep alert. Fuentes, on my mark.
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_keepalertfuenteson" );
	
}

cw_barracks_fast_fic()
{
	// remove old dialog
	maps\_anim::removeNotetrack( "ally1", "baker_vo_clear_1"  , "cw_hallsweep", "dialog" );
	maps\_anim::removeNotetrack( "ally1", "baker_vo_clear_2"  , "cw_hallsweep", "dialog" );
	maps\_anim::removeNotetrack( "ally2", "fuentes_va_clear_1", "cw_hallsweep", "dialog" );
	maps\_anim::removeNotetrack( "ally2", "fuentes_va_clear_2", "cw_hallsweep", "dialog" );
	
	//Fuentes: Tango, watch out!
	flag_wait_any( "flag_barracks_opfor_attack", "flag_barracks_cleared" );
	if( !flag( "flag_barracks_cleared" ) )
		level._allies[ 1 ] smart_dialogue( "black_ice_fnt_tangowatchout" );
	
	flag_wait( "flag_barracks_cleared" );
	wait( 1.0 );
	//Baker: Hallway clear. Let's move. Someone had to hear that.
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_hallwayclearletsmove" );
}

//**************************************************************
//		Common Room
//**************************************************************
cw_common()
{	
	// init allies
	array_call( level._allies, ::PushPlayer, true );
	
	// wait for player - reach common room door
	flag_wait_all( "flag_common_player_ready", "flag_common_ai_ready" );
	
	// thread fiction
	thread cw_common_fic();
	
	// get allies ready for combat
	array_thread( level._allies, ::set_ignoreall, false );
	foreach( guy in level._allies )
		guy.newEnemyReactionDistSq = guy.old_react_dist;
	
	// ally1 check breach door
	wait( 1 );
	vig_node = GetEnt( "cw_vig_common_room_breach", "targetname" );
	vig_node thread anim_single_solo( level._allies[ 0 ], "rec_breach_check" );
	
	// ready allies
	wait( 0.05 );			 
	array_thread( level._allies, ::enable_cqbwalk );
	array_thread( level._allies, ::disable_ai_color );
	
	// wait to breach the common room
	flag_wait( "flag_common_breach" );
	
	autosave_by_name( "cw_common_room" );
	
	// open door and bullet event
	level cw_common_breach();
	
	// move allies
	array_call( level._allies, ::PushPlayer, false );
	level._allies[ 0 ] thread set_ignoreSuppression( true );
	level._allies[ 0 ] delayThread( 2.5, ::set_ignoreSuppression, false );
	level._allies[ 0 ] thread set_force_color( "r" );
	level._allies[ 1 ] delayThread( 1.5, ::set_force_color, "y" );
	trig = GetEnt( "cw_color_common_start", "targetname" );
	trig notify( "trigger" );
	trig trigger_off();
	array_thread( level._allies, ::set_force_cover, false );
	
	// setup forward reinforce
	delay_retreat( "com_opfor", 30, 5, "flag_common_reinforce" );
	array_spawn_targetname( "cw_opfor_common_runner" );
	
	// setup back reinforce & retreat
	wait( 1 );
	delay_retreat( "com_opfor", 90, 4, "flag_common_retreat", "cw_trig_common_retreat", true );
	
	// setup all out ending
	wait( 1 );
	delay_retreat( "com_opfor", 60, 2, "flag_common_end" );
	array_thread( get_ai_group_ai( "com_opfor" ), ::player_seek_enable );
	
	// setup cleanup
	delay_retreat( "com_opfor", 60, 1, "flag_common_cleared" );
	kill_deathflag( "flag_common_cleared", 2 );
	
	// wait till all enemies are killed
	flag_wait( "flag_common_cleared" );
	
	// reset allies
	array_thread( level._allies, ::disable_cqbwalk );
	array_thread( level._allies, ::set_grenadeammo, 3 );
	
	// move allies to outside doors
	old_trigs = GetEntArray( "cw_color_common", "script_noteworthy" );
	array_thread( old_trigs, ::trigger_off );
	trig = GetEnt( "cwc_color_leave", "targetname" );
	trig notify( "trigger" );
}

cw_common_fic()
{
	wait( 1 ); // sync wait to hand signal
	//Baker: Activity behind the door, get ready to flash.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_hearthat" );
	flag_set( "flag_common_breach" );
	
	level waittill( "flag_common_breach_ally_start" );
	//Baker: Shit!  Ambush!
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_ambush" );
	//Baker: Rook!  Take cover!
	level._allies[ 0 ] thread smart_dialogue( "blackice_bkr_rooktakecover" );
	
	level waittill( "cw_common_throw_flash" );
	//Baker: Doors down, flash now!
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_doorsdown" );
	
	// wait till all enemies are killed
	flag_wait( "flag_common_cleared" );
	wait( 1 );
	//Baker: Room's clear, move up.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_roomsclearmove" );
}

//*******************************************************************
//																	*
//		ENCOUNTER UTILS												*
//*******************************************************************

cw_bravo_breach()
{
	
	level._bravo[0] thread follow_path( GetNode( "cw_leave_bravo1", "targetname" ) );
	level._bravo[1] thread follow_path( GetNode( "cw_leave_bravo2", "targetname" ) );
	
	flag_wait_all( "flag_cw_bravo_breach_1", "flag_cw_bravo_breach_2" );
	flag_clear( "flag_cw_bravo_breach_1" );
	flag_clear( "flag_cw_bravo_breach_2" );
	
	wait( 1 );
	flag_set( "flag_cw_bravo_breach" );
	
	flag_wait_all( "flag_cw_bravo_breach_1", "flag_cw_bravo_breach_2" );
	array_thread( level._bravo, ::stop_magic_bullet_shield );
	wait( 0.1 );
	array_call( level._bravo, ::Delete );
}

fx_snow_windtunnel()
{
	//end this in the flarestack(cant backtrack after that point
	level endon( "notify_stop_flare_stack" );
	fx = false;
	while( 1 )
	{
		if( flag( "flag_catwalks_windtunnel_fx" ) )
		{
			if ( fx == false )
			{
				exploder( "catwalks_snow_windtunnel" );
				fx = true;
			}
		}
		else
		{
			if ( fx == true )
			{
				stop_exploder( "catwalks_snow_windtunnel" );
				stop_exploder( "catwalks_lights" );
				stop_exploder( "catwalks_snow" );
				exploder ( "barracks_ambfx" );
				fx = false;
			}
		}
		wait( level.TIMESTEP );
	}
}

goto_door_breach( node, speed, note )
{
	self endon( "death" );
	
	// init & speed up
	old_react_dist		 = self.newEnemyReactionDistSq;
	old_moveplaybackrate = self.moveplaybackrate;
	self thread set_moveplaybackrate( speed, 0.25 );
	
	// ignore stuff
	self.disableBulletWhizbyReaction = true;
	self.disableFriendlyFireReaction = true;
	self.doDangerReact				 = false;
	self.dontavoidplayer			 = true;
	self.disableplayeradsloscheck	 = true;
	self.ignorerandombulletdamage	 = true;
	self.ignoresuppression			 = true;
	self.newEnemyReactionDistSq		 = 0;
	
	self thread follow_path(  GetNode( node, "targetname" ) );
	level waittill( note );
	
	// reset ai
	self.disableBulletWhizbyReaction = undefined;
	self.disableFriendlyFireReaction = undefined;
	self.doDangerReact				 = 1;
	self.dontavoidplayer			 = 0;
	self.disableplayeradsloscheck	 = 0;
	self.ignorerandombulletdamage	 = 0;
	self.ignoresuppression			 = 0;
	self.newEnemyReactionDistSq		 = old_react_dist;
	
	// reset speed
	self set_moveplaybackrate( old_moveplaybackrate );
}

high_catwalk_kill()
{
	flag_wait( "flag_vig_catwalk_kill" );
	node = GetEnt( "cw_vignette_catwalk_kill", "targetname" );
	
	// init vars
	opfor = spawn_targetname( "cw_opfor_catwalk_kill" );
	ally  = getClosest( node.origin, level._allies, 256 );
	
	// check to abort high kill
	if ( !IsDefined( opfor ) )
	{
		return;
	}
	else if ( !IsDefined( ally ) || flag( "flag_no_catwalk_kill" ) )
	{
		opfor Delete();
		return;
	}
	
	// setup vars
	opfor.animname = "generic";
	guys		   = [ ally, opfor ];
	
	// reach anim
	ally thread disable_ai_color();
	node anim_reach_together( guys, "catwalk_kill" );
	ally thread maps\black_ice_audio::sfx_catwalk_guy_over_railing();
	node anim_single( guys, "catwalk_kill" );
	
	// go to color node
	if ( !flag( "flag_catwalks_end" ) )
		ally enable_ai_color();
		
	
	opfor Kill();
}

cw_tape_breach()
{
	// init vars
	node		   = GetEnt( "cw_vig_tape_breach", "targetname" );
	tape		   = spawn_anim_model( "tape_breach_tape" );
	door_destroyed = spawn_anim_model( "tape_breach_door_dam" );
	node anim_first_frame_solo( door_destroyed, "cw_tape_breach" );
	door_destroyed Hide();
	guys = [ level._allies[ 0 ], level._allies[ 1 ], level.tape_breach_door, door_destroyed, tape ];
	
	thread cw_tape_explode( tape, door_destroyed );
	
	// attach clip
	door_clip = GetEntArray( "cw_clip_tape_breach_door", "targetname" );
	array_call( door_clip, ::LinkTo, door_destroyed, "jnt_door" );
	
	// hide tape
	node thread anim_first_frame_solo( tape, "cw_tape_breach" );
	
	// get to anim
	array_call( level._allies, ::PushPlayer, true );
	level._allies[ 0 ]thread follow_path( GetNode( "cw_node_tape_breach_ally1", "targetname" ) );
	level._allies[ 1 ]thread follow_path( GetNode( "cw_node_tape_breach_ally2", "targetname" ) );
	
	// start player gps checks
	level._allies[0] thread tape_breach_player_wait_proc();
	
	// turn off cover peeking
	array_thread( level._allies, ::set_force_cover, true );
	
	flag_wait_all( "flag_cw_breach_vo_ready", "flag_tape_breach_ally2" );
	
	// check player position
	block_vol  = GetEnt( "cw_gps_tape_breach", "targetname" );
	block_clip = GetEnt( "cw_clip_tape_breach", "targetname" );
	if ( level.player IsTouching( block_vol ) )
	{
		thread temp_dialogue_line( "Baker", "Rook, stand back.", 1.0 );
		while ( level.player IsTouching( block_vol ) )
			wait( 0.05 );
		block_clip MoveZ( 128, 0.05 );
		wait( 0.05 );
		temp_dialogue_line( "Baker", "Fuentes, charges", 1.0 );
	}
	else
		block_clip MoveZ( 128, 0.05 );
	
	// check ally locations before anim
	foreach( ally in level._allies )
	{
		if( ally.origin != ally.goalpos )
			wait( 0.05 );
	}
	
	// thread notifies
	level notify( "cw_tape_breach_start" );
	level thread notify_delay( "cw_tape_breach_cover", 4 );
	
	// animate and play breach sound
	thread maps\black_ice_audio::sfx_tape_breach( node );
	node anim_single( guys, "cw_tape_breach", undefined, 0.1 );
	block_clip Delete();
	
	// move allies
	array_call( level._allies, ::PushPlayer, false );
	array_thread( level._allies, ::disable_cqbwalk );
	array_thread( level._allies, ::set_force_cover, false );
	array_thread( level._allies, ::disable_ai_color );
	node = GetNode( "cwb_node_start_ally1", "targetname" );
	level._allies[ 0 ] thread follow_path( node );
	node = GetNode( "cwb_node_start_ally2", "targetname" );
	level._allies[ 1 ] thread follow_path( node );
	
	// wait till baker is inside
	wait( 1 );
}

tape_breach_player_wait_proc()
{
	// init vars
	block_vol	= GetEnt( "cw_gps_tape_breach", "targetname" );
	breach_node = GetNode( "cw_node_tape_breach_ally1", "targetname" );
	detour_node = GetNode( "cw_node_tape_breach_ally1_detour", "targetname" );
	
	while ( !flag( "flag_tape_breach_ally1" ) )
	{
		if( level.player IsTouching( block_vol ) )
		{
			// take detour
			self follow_path( detour_node );
			
			// nag player to get out of the way
			self thread tape_breach_nag_proc( block_vol );
			
			// wait till player is out of the way
			while( level.player IsTouching( block_vol ) )
				wait( 0.1 );
			
			// go to breach location
			level notify( "cw_tape_breach_end_detour" );
			self thread follow_path( breach_node );
		}
		
		wait( 0.05 );
	}
}

tape_breach_nag_proc( block_vol )
{
	level endon( "cw_tape_breach_end_detour" );
	
	// nag player to get out of the way
	for ( i = 5; level.player IsTouching( block_vol ); i += 2 )
	{
		self SetLookAtEntity( level.player );
		self delayCall( 2, ::SetLookAtEntity );
		thread temp_dialogue_line( "Baker", "Rook, stand back.", 1.0 );
		wait( i );
	}
}

cw_tape_explode( tape, door_destroyed )
{
	
	level waittill ( "notify_cw_tape_explode" );
	
	cw_tape_explode_player_effect();
	
	door_destroyed Show();
	
	exploder( "catwalk_det_tape" );
	exploder( "catwalk_snow_suck" );
	
	wait( 0.1 );
	
	level.tape_breach_door Delete();
	tape Delete();
	
}

cw_tape_explode_player_effect()
{
	safe_dist = 14000;
	dist = DistanceSquared( level.player.origin, level.tape_breach_door.origin );
	
	    
    if ( dist > safe_dist )
    {
    	level.player PlayRumbleOnEntity( "damage_light" );
		Earthquake( 0.11, 1.0, level.player.origin, 128 );
    }
    else
    {
    	level.player PlayRumbleOnEntity( "grenade_rumble" );
		Earthquake( 0.3, 1.2, level.player.origin, 128 );
		level.player ShellShock( "default_nosound", 2 );
		level.player ViewKick( 10, level.tape_breach_door.origin );
		
		push_mag_max = 70;
		push_mag_min = 5;
		
		push_factor = maps\black_ice_util::normalize_value( 0, safe_dist, dist );
		push_mag	= maps\black_ice_util::factor_value_min_max( push_mag_max, push_mag_min, push_factor );
		
		//IPrintLn( "mag = " + push_mag );
		
		push_dir = VectorNormalize( level.player.origin - level.tape_breach_door.origin );
		
		thread maps\black_ice_util::push_player_impulse( push_dir, push_mag, 0.5 );
    }
}

cw_common_breach()
{
	level endon( "cw_common_flashed" );
	
	// get doors
	door	  = GetEnt( "cw_common_door", "targetname" );
	door_clip = GetEnt( door.target		, "targetname" );
	
	// wait for player to start breach
	use_trig = GetEnt( "cw_use_common_room_breach", "targetname" );
	use_trig SetHintString( &"BLACK_ICE_COMMON_BREACH" );
	use_trig thread cw_common_breach_trig_proc();
	
	while(1)
	{
		// wait till player actions door
		use_trig waittill( "trigger" );
		
		// check for grenade use
		if( !level.player IsThrowingGrenade() )
		{
			use_trig notify( "breach_triggered" );
			use_trig thread trigger_off();
			break;
		}
		
		// wait till next frame
		wait( 0.05 );
	}
	
	// start player anim and play breach sound
	thread maps\black_ice_audio::sfx_barracks_breach( door );
	thread maps\black_ice_anim::cw_common_breach_player( door );
	
	level waittill( "notify_start_red_light" );
	playFXOnTag( level._effect[ "breacher_light_red" ] ,level.breach_charge, "tag_red_light" );
	
	//wait to start blinking light
	level waittill( "notify_start_green_light" );
	StopFXOnTag( level._effect[ "breacher_light_red" ] ,level.breach_charge, "tag_red_light" );
	playFXOnTag( level._effect[ "breacher_light_green" ] ,level.breach_charge, "tag_green_light" );
	
	
	// wait to set charge before gunfire
	flag_wait( "flag_common_breach_ally_start" );
	
	// start firing
	thread cw_breach_bullets();
	delayThread( 0.1, ::cw_breach_bullets );
	
	// animate allies
	wait( 0.1 );
	vig_node = GetEnt( "cw_vig_common_room_breach", "targetname" );
	thread maps\black_ice_anim::cw_common_breach_allies();
	
	// wait to start damaged breach charge fx
	level waittill( "notify_damage_breacher" );
	PlayFXOnTag( level._effect[ "common_breach_damaged_breacher" ] ,level.breach_charge, "tag_damage_fx" );
	KillFXOnTag( level._effect[ "breacher_light_green" ] ,level.breach_charge, "tag_green_light" );
	
	// explosion
	level waittill( "cw_common_door_down" );
	exploder( "common_breach_charge" );
	exploder( "common_room_ambfx" );
	KillFXOnTag( level._effect[ "common_breach_damaged_breacher" ] ,level.breach_charge, "tag_damage_fx" );
	
	//small delay to let the fx start up
	wait( 0.15 );
	
	//effect player
	delayThread( 0.0, ::cw_breach_player_effects );	
	
	//delete breacher
	level.breach_charge Delete();
	
	// swap doors
	door_dam = spawn_anim_model( "common_door_dam", door.origin );
	vig_node thread anim_single_solo( door_dam, "explode" );
	door Delete();
	door_clip thread delete_path_clip();
	
	// ally flash check
	thread cw_breach_flash_protect();
	
	// allies enter
	delay_retreat( "com_opfor", 6, 4, "flag_common_breach_done" );
	
	// ally1 flash
	// node = GetEnt( "cw_common_flash_org", "targetname" );
	// node thread anim_single_solo( level._allies[0], "throw_flash" );
	
	// wait( 0.95 );
	// flash_grenade_proc( level._allies[0], "cw_org_common_flash" );
	// array_thread( level._allies, ::setFlashbangImmunity, true );
	// delayThread( 1.25, ::array_thread, level._allies, ::setFlashbangImmunity, false );
	
}

cw_common_breach_trig_proc()
{
	self endon( "breach_triggered" );
	node = GetEnt( "cw_common_breach_blast_source", "targetname" );
	
	while ( 1 )
	{
		if ( !IsDefined( self.trigger_off ) && ( level.player IsThrowingGrenade() || !level.player player_looking_at( node.origin, 0.9, true ) ) )
			self trigger_off();
		else if ( IsDefined( self.trigger_off ) && !level.player IsThrowingGrenade() && level.player player_looking_at( node.origin, 0.9, true ) )
			self trigger_on();
		
		wait( 0.05 );
	}
}


cw_breach_player_effects()
{

	damage_node = GetEnt( "cw_common_breach_blast_source", "targetname");
	
	//push the player, quake and rumble fx
	dir = (   level.player.origin - damage_node.origin  );
	thread maps\black_ice_util::push_player_impulse( dir, 0.12, 0.7 );
	Earthquake( 0.5, 0.75, level.player.origin, 2000 );
	level.player ShellShock( "blackice_nosound", 1.0);
	level.player PlayRumbleOnEntity( "grenade_rumble" );
	level.player ViewKick( 20, damage_node.origin );
	
}

cw_breach_bullets()
{
	level endon( "flag_common_breach_done" );
	
	//action music
		//music_play( "mus_blackice_hallsearch_end_ss" );
			
	level waittill( "notify_start_bullets" );
	
	// magic bullets
	start	   = GetEntArray( "cw_bullet_common_ambush", "targetname" );
	rand_start = undefined;
	end		   = GetEntArray( "cw_target_common_ambush", "targetname" );
	rand_end   = undefined;
	weap	   = [ "ak47_arctic", "ump45_arctic", "p90_arctic", "pecheneg" ];
	
	while ( true )
	{
		rand_start = RandomInt( start.size );
		rand_end = RandomInt( end.size );
		
		if ( flag( "cw_gps_common_door" ) && RandomInt( 5 ) == 0 )
		{
			MagicBullet( weap[ RandomInt( weap.size ) ], start[ rand_start ].origin, level.player GetEye() );
		}
		else
		{
			if( !BulletTracePassed( start[ rand_start ].origin, end[ rand_end ].origin, true, undefined ) )
				continue;
			
			MagicBullet( weap[ RandomInt( weap.size ) ], start[ rand_start ].origin, end[ rand_end ].origin );
		}
			
		wait( 0.05 * RandomIntRange( 1, 4 ) );
	}
}

cw_breach_flash_protect()
{
	level endon( "cw_common_flashed" );
	level.player endon( "death" );
	
	// wait for player to throw a grenade
	myGrenade = undefined;
	level.player waittill( "grenade_fire", myGrenade );
	
	wait( 0.5 );
	vol = GetEnt( "cw_vol_common", "targetname" );
	
	if ( IsDefined( myGrenade ) && myGrenade IsTouching( vol ) )
	{
		array_thread( level._allies, ::setFlashbangImmunity, true );
		delayThread( 1, ::array_thread, level._allies, ::setFlashbangImmunity, false );
	}
}

//*******************************************************************
//																	*
//		AI SCRIPTS													*
//*******************************************************************

setup_spawners()
{
	// setup vars
	vols = GetEntArray( "cw_vol_falling_area", "targetname" );
	level.cw_fall_chance = 1;
	
	array_spawn_function_noteworthy( "cw_opfor_starting_runners", ::opfor_starting_runners );
	array_spawn_function_noteworthy( "cw_opfor_death_runners"	, ::opfor_death_runners );
	array_spawn_function_noteworthy( "cw_opfor_low"				, ::opfor_catwalk_low );
	array_spawn_function_targetname( "cw_opfor_low_balcony"	 ,    ::opfor_low_balcony );
	array_spawn_function_noteworthy( "cw_opfor_falling", 		  ::opfor_catwalk_falling_death, vols );
	array_spawn_function_targetname( "cw_barracks_opfor"	 ,    ::opfor_barracks );
	array_spawn_function_targetname( "cw_opfor_common_ambush",    ::opfor_common_ambush );
	
	// setup threatbias
	SetThreatBias( "cw_low_balcony", "allies", 256 );
}

ascend_ignoreme_loop()
{
	level endon( "flag_ascend_end" );
	
	while ( 1 )
	{
		self set_ignoreme( false );
		
		while ( self.health == self.maxhealth )
			wait( 0.05 );
		
		self set_ignoreme( true );
		
		while ( self.health < self.maxhealth )
			wait( 0.1 );
	}
}

opfor_starting_runners()
{
	self endon( "death" );
	
	self set_ignoreall( true );
	
	self waittill( "goal" );
	self set_ignoreall( false );
}

opfor_death_runners()
{
	self endon( "death" );
	
	self set_ignoreall( true );
	
	self waittill( "goal" );
	self Delete();
}

opfor_catwalk_low()
{
	self endon( "death" );
	
	flag_wait( "flag_low_retreat" );
	if ( !flag( "flag_low_runaway" ) )
		self thread follow_path( GetNode( "cw_node_low_cover_retreat", "targetname" ) );
	
	flag_wait( "flag_low_runaway" );
	self set_ignoreSuppression( true );
	self thread follow_path( GetNode( "cw_node_low_cover_runaway", "targetname" ) );
	self delayThread( 5, ::set_ignoreSuppression, false );
}

opfor_low_balcony()
{
	self endon( "death" );
	
	self set_ignoreall( true );
	
	self waittill( "goal" );
	self set_ignoreall( false );
	
	flag_wait( "flag_low_runaway" );
	self follow_path( GetNode( "cw_node_mid_runners_end", "targetname" ) );
	self Delete();
}

opfor_catwalk_falling_death( vols )
{
	self waittill( "death" );
	
	// setup vars
	not_touching = true;
	
	// check if ai is standing in cover
	if ( self.movemode != "stop" || !IsDefined( self.a.coverMode ) || self.a.coverMode != "stand" )
		return;
	
	// check if ai is in position
	foreach ( vol in vols )
	{
		if ( self IsTouching( vol ) )
		{
			not_touching = false;
			break;
		}
	}
	
	if ( not_touching )
		return;
	
	// ai is in position and standing
	if( RandomInt( level.cw_fall_chance ) == 0 )
	{
		randNum		   = RandomInt( level.scr_anim[ "generic" ][ "cw_falling_death" ].size );
		self.deathanim = level.scr_anim[ "generic" ][ "cw_falling_death" ][ randNum ];
		level.cw_fall_chance += 4;
		IPrintLn( "deathanim: " + randNum );
	}
}

opfor_barracks()
{
	self endon( "death" );
	
	// thread unkillable ( once being killed by fuentes )
	level waittillThread( "cw_hallsweep_ally2_attack", ::magic_bullet_shield, true );
	
	flag_wait( "flag_barracks_go_fast" );
	
	// player seek
	self.newenemyreactiondistsq = 0;
	self set_fixednode_false();
	self.goalradius = 150;
	
	wait( 1 );
	self SetGoalEntity( level.player );
	
}

opfor_common_ambush()
{
	self endon( "death" );
	
	// stop from shooting early... haha
	self set_ignoreall( true );
	self set_ignoreme( true );
	
	level waittill( "notify_start_bullets" );
	
	// start flash check
	self thread common_flash_check();
	self thread random_flash();
	
	// setup shooting
	self set_ignoreall( false );
	self set_ignoreSuppression( true );
	
	// setup target
	my_targets = GetEntArray( "cw_target_common_ambush", "targetname" );
	self SetEntityTarget( my_targets[ RandomInt( my_targets.size ) ] );
	
	while ( !flag( "flag_common_breach_done" ) )
	{
		self SetEntityTarget( my_targets[ RandomInt( my_targets.size ) ] );
		wait( 0.3 );
	}
	
	// make shoot-able
	self set_ignoreme( false );
	
	// clear targets
	wait( RandomFloat( 0.5 ) );
	self ClearEntityTarget();
	
	wait( 1.5 );
	self set_ignoreSuppression( false );
}

common_flash_check()
{
	self endon( "death" );
	level endon( "cw_common_flashed" );
	
	while ( 1 )
	{
		if ( self isFlashed() )
		{
			flag_set( "flag_common_breach_done" );
			level notify( "cw_common_flashed" );
		}
		
		wait( 0.05 );
	}
}

random_flash()
{
	self endon( "death" );
	
	level waittill( "cw_common_flashed" );
	
	if ( IsDefined( self.script_parameters ) )
	{
		self AllowedStances( "stand" );
		self set_allowdeath( true );
		anim_generic( self, self.script_parameters );
		
		self AllowedStances( "stand", "crouch" );
	}
	else if ( RandomInt( 2 ) == 0 )
	{
		self flashBangStart( RandomFloatRange( 4.0, 5.0 ) );
	}
}
//*******************************************************************
//																	*
//		Light Script												*
//*******************************************************************

catwalk_godrays()
{
	gr_origin = getEnt("origin_flarestack_fx","targetname");
	if ( is_gen4() )
	{
		//IPrintLnBold ("god_rays_catwalk");
		god_rays_from_world_location ( gr_origin.origin, "flag_cw_bravo_breach_1", "flag_catwalks_end", undefined, undefined);
	}
}
//*******************************************************************
//																	*
//		UTIL SCRIPTS												*
//*******************************************************************
cw_barracks_fast_trig_proc( end_trig )
{
	level endon( "cw_hallsweep_ally2_attack" );
	level endon( "flag_barracks_go_fast" );
	end_trig endon( "trigger" );
	
	// init vars
	dist_org = GetEnt( "cw_barracks_dist_org", "targetname" );
	dist_org = dist_org.origin;
	guys	 = [ level.player, level._allies[ 0 ], level._allies[ 1 ] ];
	
	while ( 1 )
	{
		guy = getClosest( dist_org, guys, 384 );
		if ( IsDefined( guy ) && IsPlayer( guy ) )
		{
			flag_set( "flag_barracks_go_fast" );
			return;
		}
		
		wait( 0.1 );
	}
}

cw_barracks_fast_shoot_proc()
{
	level endon( "cw_hallsweep_ally2_attack" );
	level endon( "flag_barracks_go_fast" );
	
	level.player waittill_any( "weapon_fired", "grenade_fire" );
	flag_set( "flag_barracks_go_fast" );
}

delete_path_clip()
{
	self MoveZ( -10000, 0.05 );
	wait( 0.05 );
	self ConnectPaths();
	self Delete();
}

anim_reach_play( guys, anime, tag, anim_end_time, animname_override, goto_node, skip_reach )
{
	// make guys array
	if ( !IsArray( guys ) )
		guys = [ guys ];
	
	// endon
	guys[ 0 ]notify( "anim_reach_play" );
	guys[ 0 ]endon ( "anim_reach_play" );
	
	// handle follow path
	if ( IsDefined( goto_node ) && !IsDefined( anim_end_time ) )
		anim_end_time = 0.1;
	
	self anim_stopanimscripted();
	if( !IsDefined( skip_reach ) || !skip_reach )
		self anim_reach( guys, anime, tag, animname_override );
	self anim_single( guys, anime, tag, anim_end_time, animname_override );
	
	if ( IsDefined( goto_node ) )
		guys[ 0 ] follow_path( goto_node );
}

trig_enable_cqb()
{
	level endon( "turn_off_cw_cqb_trigs" );
	
	while ( 1 )
	{
		self waittill( "trigger", dude );
		
		dude thread enable_cqbwalk();
	}
}

trig_disable_cqb()
{
	level endon( "turn_off_cw_cqb_trigs" );
	
	while ( 1 )
	{
		self waittill( "trigger", dude );
		
		dude thread disable_cqbwalk();
	}
}