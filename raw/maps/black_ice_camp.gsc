#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\black_ice_util;

//*******************************************************************
//																	*
//																	*
//*******************************************************************

section_flag_inits()
{
	// encounter flags
	flag_init( "player_water_breach" );
	flag_init( "flag_camp_move_allies" );
	flag_init( "flag_camp_front_retreat" );
	flag_init( "flag_camp_mid_retreat" );
	flag_init( "flag_camp_building_open" );
	flag_init( "flag_bc_porch_runner_done" );
	flag_init( "flag_camp_helo_retreat" );
	flag_init( "flag_camp_helo_ready" );
	flag_init( "flag_camp_helo_unload" );
	flag_init( "flag_camp_back_retreat" );
	flag_init( "flag_camp_back_lmg_retreat" );
	flag_init( "flag_camp_street_retreat" );
	flag_init( "bc_flag_alarm_start" );
	flag_init( "flag_camp_cleared" );
	flag_init( "flag_allies_reached_ascend" );
	flag_init( "bc_flag_spots_close" );
	flag_init( "bc_flag_spots_off" );
	
	// location tracking
	// flag_init( "bc_gps_player_start" );
	// flag_init( "bc_gps_player_front" );
	// flag_init( "bc_gps_player_side" );
	// flag_init( "bc_gps_player_ascend" );
	
	//Vision Set Flags
	flag_init( "flag_vision_campinteriors" );
}

section_precache()
{
	PreCacheItem( "famas_arctic_reflex" );
}

start()
{
	IPrintLn( "Camp" );
	
	// teleport player
	player_start( "player_start_camp" );
	
	// spawn bravo
	if ( !IsDefined( level._bravo ) || level._bravo.size < 2 )
		maps\black_ice_util::spawn_bravo();
	
	//cue truck on surface so fx can settle in before player surfces
	thread maps\black_ice_anim::swim_truck_surface_anim();
	thread ascend_snow_fx();
	
	// ice, water, some vehicles, etc.
	level.breach_anim_node = getstruct( "breach_anim_node", "script_noteworthy" );
	thread maps\black_ice_swim::create_persistent_ice_breach_props( true );
	thread maps\black_ice_swim::handle_ice_plugs();
	
	// spawn swim allies
	level.CONST_EXPECTED_NUM_SWIM_ALLIES = 2;
	level._allies_swim = maps\black_ice_util::spawn_allies_swim();
	array_call( level._allies_swim, ::Attach, level.scr_model[ "ascend_launcher_non_anim" ], "TAG_STOWED_BACK" );
	
	// play ally swim vignette
	level.allies_breach_anim_node = getstruct( "vignette_introbreach_allies", "script_noteworthy" );
	
	for ( index = 0; index < level._allies_swim.size; index++ )
	{
		level._allies_swim[ index ].animname = "scuba_ally";
		level.allies_breach_anim_node thread anim_loop_solo( level._allies_swim[ index ], "surface_ally" + ( index + 1 ) + "_idle" );
	}
	
	SetHUDLighting( true );
	level.player.hud_scubaMask = level.player  maps\_hud_util::create_client_overlay( "scubamask_overlay_delta", 1, level.player );
	level.player.hud_scubaMask.foreground = false;
	level.player.hud_scubaMask.sort = -99;
	
	flag_set ( "flag_player_breaching" );
	
	// Enable swim and add a black screen so the transition is masked
	level.player AllowSwim( true );
	thread maps\black_ice_swim::black_fade( 0.0, 0.4, 0.0 );
	
	maps\black_ice_swim::surface_breach();
	
	// finish vignette
	// level.allies_breach_anim_node notify( "stop_loop" );
	
	thread maps\black_ice_swim::player_post_swim();
	
	// start ambient sfx
	//TimS - removing these since we're moving to client triggers
	//set_audio_zone( "blackice_outside", 1 );		
}

main()
{
	// setup allies
	level.player SetThreatBiasGroup( "player" );
	
	// setup enemy spawners
	setup_spawners();
	
	// thread water to camp transision
	thread bc_intro();
	
	// encounter flow
	level bc_front();
	level bc_mid();
	level bc_back();
	level bc_helo_reinforce();
	level bc_street();
	level bc_ascend();
	level bc_end();
}

ascend_snow_fx()
{
	//end this in the flarestack(cant backtrack after that point
	level endon( "notify_start_catwalks_snow" );
	fx = false;
	while( 1 )
	{
		if( flag( "flag_ascend_snow_fx" ) )
		{
			if ( fx == false )
			{
				exploder( "ascend_snow_huge" );
				fx = true;
			}
		}
		else
		{
			if ( fx == true )
			{
				stop_exploder( "ascend_snow_huge" );
				fx = false;
			}
		}
		wait( level.TIMESTEP );
	}
}

bc_intro()
{
	// ****************************************************
	// Player pressed X to exit swim
	
	// spawn helo & crawling enemy
	thread heli_spawn_and_path( "bc_veh_intro_helo" );
	array_spawn_targetname( "bc_opfor_crawl", true, true );
	
	// save
	autosave_by_name( "ice_surface" );
	
	// waittill right before player start animating
	flag_wait( "flag_player_breaching" );
	
	// setup allies
	level._allies[ 0 ] thread set_force_color( "r" );
	level._allies[ 1 ] thread set_force_color( "b" );
	level._bravo[ 0 ] thread set_force_color( "b" );
	level._bravo[ 1 ] thread set_force_color( "r" );
	
	// ****************************************************
	// Player can see above water (still in anim)
	flag_wait( "player_water_breach" );
	
	// save
	autosave_by_name( "camp_start" );
	
	// thread fx
	thread bc_amb_fx();
	
	// thread vision sets
	thread bc_snow_tweaks();
	
	// Player finished ice mantle (full control restored)
	level waittill( "bc_player_ready" );
	
	// wait and allow allies to move
	flag_wait_or_timeout( "flag_camp_move_allies", 3 );
	level._allies[ 0 ] ent_flag_set( "flag_camp_move_ally" );
	level._bravo[ 0 ] delayThread( 0.5, ::ent_flag_set, "flag_camp_move_ally" );
	level._allies[ 1 ] delayThread( 5.75, ::ent_flag_set, "flag_camp_move_ally" );
	level._bravo[ 1 ] delayThread( 6.25, ::ent_flag_set, "flag_camp_move_ally" );
}


//*******************************************************************
//																	*
//		VISION SET CHANGES											*
//*******************************************************************
bc_snow_tweaks()
{
	// player starts outside
	//TAG CP commenting out this vision set change.  It happens with a notetrack during the player breach animation.
	//vision_set_fog_changes( "black_ice_basecamp", 0.1 );
	SetSavedDvar( "r_snowAmbientColor", ( 0.06, 0.08, 0.17 ) );
	//set skyfog
	//SetSavedDvar("r_sky_fog_min_angle","85.28");	
	//SetSavedDvar("r_sky_fog_max_angle","90.62");
	//SetSavedDvar("r_sky_fog_intensity","1");
}


//*******************************************************************
//																	*
//		EFFECTS														*
//*******************************************************************
bc_amb_fx()
{	
	// start ambient snow fx
	exploder ( "basecamp_snow" );
	exploder ( "basecamp_lights" );
		
	//turn on the cold_breath fx
	thread maps\black_ice_fx::coldbreathfx();
}


//*******************************************************************
//																	*
//		ENCOUNTERS													*
//*******************************************************************
bc_front()
{	
	// IPrintLnBold( "front: " + get_ai_group_sentient_count( "bc_opfor" ) );
	
	// Player can see above water (still in anim)
	flag_wait( "player_water_breach" );
	
	// spawn starting animated enemies
	array_spawn_targetname( "bc_opfor_run" );
	delayThread( 1.5, ::array_spawn_targetname, "bc_opfor_runback" );
	
	// Player finished ice mantle (full control restored)
	level waittill( "bc_player_ready" );
	
	// thread runaway fiction
	thread bc_front_fic();
	
	delay_retreat( "bc_opfor", 90, 2, "flag_camp_front_retreat", "bc_color_mid", true, "bc_start_mid_nag" );
}

bc_mid()
{
	// IPrintLnBold( "mid: " + get_ai_group_sentient_count( "bc_opfor" ) );
	
	// save
	autosave_by_name( "camp_mid" );
	
	// thread mid fiction
	thread bc_mid_fic();
	
	// wait for building to start opening
	flag_wait( "flag_camp_building_open" );
	SetThreatBias( "player", "axis", 250 );
	
	// open building
	thread bc_rolling_door_open();
	
	// setup left flank
	trig = GetEnt( "trig_left_flank", "script_noteworthy" );
	trig thread left_flank_spawn_proc();
	
	wait( 1 );
	delay_retreat( "bc_opfor", 180, 4, "flag_camp_mid_retreat", "bc_color_back", true );
}

bc_back()
{
	// IPrintLnBold( "back: " + get_ai_group_sentient_count( "bc_opfor" ) );
	
	// thread back fiction
	thread bc_back_fic();
	
	// spawn back reinforcements
	spawners = GetEntArray( "bc_opfor_back", "targetname" );
	flood_spawn( spawners );
	
	// remove right flank enemies
	delayThread( 2.0, maps\_spawner::killspawner, 66 );
	
	wait(1);
	delay_retreat( "bc_opfor", 180, 5, "flag_camp_helo_retreat" );
}

bc_helo_reinforce()
{
	// IPrintLnBold( "helo: " + get_ai_group_sentient_count( "bc_opfor" ) );
	
	// thread fiction
	thread bc_helo_fic();
	
	// spawn helo and opfor reinforcements
	spawner				   = GetEnt( "bc_veh_reinforce_helo", "targetname" );
	level.op_helo		   = spawner spawn_vehicle();
	level.op_helo.animname = "bc_reinforce_helo";
	guys				   = array_spawn( GetEntArray( "bc_opfor_helo_rein", "targetname" ), 1 );
	
	// init anim vars
	node			  = getstruct( "vignette_basecamp_heli", "script_noteworthy" );
	guys[ guys.size ] = level.op_helo;
	
	level.op_helo thread maps\black_ice_audio::sfx_blackice_helo_flyby();

	// animate arival & idle loop
	node anim_single( guys, "arrive" );
	// node thread anim_loop_solo( level.op_helo, "idle_loop", "stop_loop" ); // TEMP NO IDLE
	
	// init vars and run timeout
	// delayThread( 15, ::flag_set, "flag_camp_helo_unload" ); // TEMP NO IDLE
	
	/*while ( !flag( "flag_camp_helo_unload" ) )
	{
		if ( level.player player_looking_at( level.op_helo.origin, 0.7, undefined, level.op_helo ) )
		{
			flag_set( "flag_camp_helo_unload" );
		}
		IPrintLn( "waiting" );
		wait( 0.1 );
	}*/ // TEMP NO IDLE
	
	// animate leave
	flag_set( "flag_camp_helo_unload" ); // TEMP NO IDLE
	node notify( "stop_loop" );
	foreach ( guy in guys )
		node thread anim_single_solo( guy, "leave" );
	
	// queue helo cleanup
	level.op_helo thread bc_helo_reinforce_kill();
	
	wait( 1 );
	delay_retreat( "bc_opfor", 15, 7, "flag_camp_back_retreat", "bc_color_street", true );
}

bc_street()
{
	// IPrintLnBold( "street: " + get_ai_group_sentient_count( "bc_opfor" ) );
	
	// thread street fic
	thread bc_street_fic();
	
	// spawn street reinforcements
	array_spawn( GetEntArray( "bc_opfor_street", "targetname" ), undefined, true );
	
	// make sure old spawners are off
	thread maps\_spawner::killspawner( 64 );
	thread maps\_spawner::killspawner( 65 );
	thread maps\_spawner::killspawner( 66 );
	thread maps\_spawner::killspawner( 67 );
	thread maps\_spawner::killspawner( 68 );
	
	// retreat LMGs
	delayThread( 4, ::flag_set, "flag_camp_back_lmg_retreat" );
	SetThreatBias( "player", "bc_lmg", 250 );
	
	wait( 1 );
	delay_retreat( "bc_opfor", 180, 5, "flag_camp_street_retreat", "bc_color_ascend", true );
}

bc_ascend()
{
	// IPrintLnBold( "ascend " + get_ai_group_sentient_count( "bc_opfor" ) );
	
	// thread retreat fiction
	thread bc_ascend_fic();
	
	// wait for alarm and spotlights
	delay_retreat( "bc_opfor", 30, 4, "bc_flag_alarm_start" );
	
	//AUDIO: start distant rig alarm sfx
	thread maps\black_ice_audio::sfx_distant_alarm();
	
	// start spotlights
	thread main_spot();
				  //   spotlight_name    targets_name 	 
	thread fake_spot( "cw_spotlight_2", "cw_spot_2_org" );
	thread fake_spot( "cw_spotlight_3", "cw_spot_3_org" );
	
	// wait till end of base camp
	delay_retreat( "bc_opfor", 90, 1, "flag_camp_cleared" );
	
	// Cargo
	thread maps\black_ice_ascend::hanging_cargo_motion();
}

bc_end()
{
	// IPrintLnBold( "end: " + get_ai_group_sentient_count( "bc_opfor" ) );
	
	// thread ending fic and nag loop
	thread bc_end_fic();
	
	// check to cleanup guys
	guys = get_ai_group_ai( "bc_opfor" );
	array_thread( guys, maps\_utility_code::kill_deathflag_proc, 2.5 );
	thread clearThreatBias( "player", "bc_lmg" );
	thread clearThreatBias( "player", "axis" );
	
	// We need a new node to animate the runin anims
	level.ascend_anim_node = getstruct( "vignette_alpha_team_rigascend", "script_noteworthy" );
	runin_node = GetEnt( "vignette_rigascend_runin_node", "script_noteworthy" );
	
	// Spawn the actual launchers
	level.ally1_ascend_launcher = spawn_anim_model( "ally1_ascend_launcher" );
	level.ally1_ascend_launcher Hide();
	level._allies[0].launcher = level.ally1_ascend_launcher;
	level.ally2_ascend_launcher = spawn_anim_model( "ally2_ascend_launcher" );
	level.ally2_ascend_launcher Hide();
	level._allies[1].launcher = level.ally2_ascend_launcher;
	level.bravo1_ascend_launcher = spawn_anim_model( "bravo1_ascend_launcher" );
	level.bravo1_ascend_launcher Hide();
	level._bravo[0].launcher = level.bravo1_ascend_launcher;
	level.bravo2_ascend_launcher = spawn_anim_model( "bravo2_ascend_launcher" );
	level.bravo2_ascend_launcher Hide();
	level._bravo[1].launcher = level.bravo2_ascend_launcher;
	
	level.allies_ascend_ready = 0;
		
	foreach ( ally in level._allies )
	{
		ally thread maps\black_ice_ascend::runin_to_ascend( runin_node );
	}
	
	foreach ( bravo in level._bravo )
	{
		bravo thread maps\black_ice_ascend::runin_to_ascend( runin_node );
	}
	
	// Wait until they've all reached the ascend position
	while ( level.allies_ascend_ready < ( level._allies.size + level._bravo.size ) )
	{
		wait 0.05;
	}
	
	level.launchers_attached = false;
	
	// wait till an ally makes it his node
	//flag_wait( "flag_allies_reached_ascend" );
}

debug_end()
{
	while(1)
	{
		IPrintLn( get_ai_group_sentient_count( "bc_opfor" ) );
		wait( 0.1 );
	}
}

bc_front_fic()
{
	level endon( "stop_front_fic" );
	
	wait( 0.5 );
	//Baker: Drop them!  Don’t let them regroup!
	level._allies[0] smart_dialogue( "blackice_bkr_letthemregroup" );
}

bc_mid_fic()
{
	level notify( "stop_front_fic" );
	level endon( "stop_mid_fic" );
	
	// wait for building to start opening
	flag_wait( "flag_camp_building_open" );
	wait( 0.5 );
	//Grinch: Activity ahead. 12 o'clock. 
	level._bravo[ 1 ] smart_dialogue( "blackice_grn_activityahead" );
	wait( 1.0 );
	//Baker: Take cover, multiple tangos in the building ahead!
	level._allies[ 0 ] smart_dialogue( "black_ice_bkr_takecovermultipletangos" );
}

bc_back_fic()
{
	level notify( "stop_mid_fic" );
	level endon( "stop_back_fic" );
	
	//Baker: Push forward, they're falling back!
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_fallingback" );
}

bc_helo_fic()
{
	level notify( "stop_back_fic" );
	level endon( "stop_helo_fic" );
	
	wait( 2 );
	//Oldboy: Helo comin' in!
	level._bravo[ 0 ] smart_dialogue( "black_ice_diz_getreadyenemyhelo" );
	
	flag_wait( "flag_camp_helo_unload" );
	wait( 1.0 );
	//Oldboy: It's dropping reinforcements!
	level._bravo[ 0 ] smart_dialogue( "black_ice_bkr_helodroppingenemiesin" );
}

bc_street_fic()
{
	// level notify( "stop_helo_fic" );
	level endon( "stop_street_fic" );
	
	//Fuentes: Tangos doubling back to the rig.
	level._allies[ 1 ] smart_dialogue( "blackice_fnt_retreating" );
	wait( 1.5 );
	//Baker: Move up!  We have to get to those catwalks.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_gettocatwalks" );
}

bc_ascend_fic()
{
	level notify( "stop_street_fic" );
	level endon( "stop_ascend_fic" );
	
	//Baker: Clean 'em up.  Keep moving.
	level._allies[ 0 ] smart_dialogue( "blackice_bkr_cleanemup" );
	
	flag_wait( "bc_flag_alarm_start" );
	wait( 0.5 );
	//Diaz: Word got to the rig.  They're mobilizing.
	level._bravo[ 0 ] smart_dialogue( "blackice_diz_mobilizing" );
}

bc_end_fic()
{
	level notify( "stop_ascend_fic" );
	
	// wait for camp to be clear of enemies
	wait( 1 );
	
	//Baker: Get to the ascend point, now!
	level._allies[0] smart_dialogue( "blackice_bkr_movegetover" ); 
	
	//black ice music
	thread maps\black_ice_audio::blackice_pre_ascend_music();
	
	wait( 10 );
	//Baker: Get to the ascend point, now!
	//Baker: Rook, we're ready to move, get over here!
	//Baker: They're setting up on the catwalks!  Come on Rook, Get over here!
	//Baker: Move it Rook!  We don’t have much time.
	ascend_nag = [ "blackice_bkr_ascendpoint", "blackice_bkr_movegetover", "blackice_bkr_settingup", "blackice_bkr_muchtime" ];
	for ( i = 10; !flag( "flag_ascend_triggered" ); i=i+2 )
	{
		level._allies[0] smart_dialogue( ascend_nag[ RandomInt( ascend_nag.size ) ] );
		
		wait( RandomFloatRange( i, i + 2.0 ) );
	}
}


//*******************************************************************
//																	*
//		ENCOUNTER UTILS												*
//*******************************************************************
heli_spawn_and_path( heli_name )
{
	// spawn helo
	op_helo = spawn_vehicle_from_targetname_and_drive( heli_name );
	level.op_helo = op_helo;
	
	// setup endon
	op_helo endon( "death" );
	
	// ready low fastrope anims ( 136 + 106 )
	op_helo.fastropeoffset = 322; // 242;
	
	// check for sfx
	if ( heli_name == "bc_veh_intro_helo" )
		op_helo Vehicle_TurnEngineOff();
	
	// wait for end of path & delete
	op_helo waittill( "reached_dynamic_path_end" );
	op_helo Delete();
}

bc_door_open( guy )
{
	// get door
	door	  = GetEnt	   ( "bc_side_door"		, "targetname" );
	door_clip = GetEntArray( "bc_side_door_clip", "targetname" );
	door_org  = GetEnt	   ( "bc_side_door_org" , "targetname" );
	door LinkTo( door_org );
	array_call( door_clip, ::LinkTo, door_org );
	
	// get & delete clip
	door_clip = GetEnt( "bc_side_door_clip", "targetname" );
	door_clip thread delete_path_clip();
	
	// open door
	door_org RotateTo( ( 0, 149, 0 ), 0.75, 0.1, 0.1 );
	wait( 0.75 );
	door_org RotateTo( ( 0, 140, 0 ), 0.3, 0.1, 0.2 );
}

bc_rolling_door_open()
{
	// get door
	door = GetEnt( "bc_rolling_door", "targetname" );
	door_org = GetEnt( "bc_rolling_door_close", "targetname" ); // TEMP
	door LinkTo( door_org ); // TEMP
	
	// get clip brushes
	in_clip = GetEnt( "cw_clip_inside_building", "targetname" );
	roll_clip = GetEnt( "bc_rolling_door_clip", "targetname" );
	
	// delete roll clip
	roll_clip delete_path_clip();
	
	//AUDIO: play door opening sound
	thread maps\black_ice_audio::sfx_blackice_door_rollup( door );

	// open door // TEMP - to be animated
	open_time = 1.25;
	door_open = GetEnt( "bc_rolling_door_open", "targetname" );
	door_org MoveTo( door_open.origin, open_time, 0.5, 0.25 );
	door_org RotateTo( door_open.angles, open_time, 0.5, 0.25 );
	level notify( "bc_opening_rolling_door" );
	wait( open_time );
	level notify( "bc_rolling_door_open" );
	
	// connect inside paths
	in_clip delete_path_clip();
}

left_flank_spawn_proc()
{
	level endon( "flag_camp_back_retreat" );
	
	self waittill( "trigger" );
	wait( 1 );
	
	// wait till one all flank enemy are dead
	while ( level.mid_window_count > 0 )
		wait( 0.1 );
	
	spawner = GetEnt( "bc_opfor_flank_left", "targetname" );
	if ( IsDefined( spawner ) && spawner.count > 0 )
	{
		spawner spawn_ai();
		spawner Delete();
	}
}

helo_unload_proc()
{
	// wait for helo to get to unload node
	flag_wait( "flag_camp_helo_ready" );
	
	// init vars and run timeout
	org = GetEnt( "bc_node_helo_org", "targetname" );
	delayThread( 15, ::flag_set, "flag_camp_helo_unload" );
	
	while( !flag( "flag_camp_helo_unload" ) )
	{
		if( level.player player_looking_at( org.origin, 0.7 ) )
		{
			wait( 0.5 );
			flag_set( "flag_camp_helo_unload" );
		}
		
		wait( 0.1 );
	}
	
	// TEMP TEMP - unload guys from helo
	tele_nodes = getstructarray( "temp_helo_ai_teleport", "targetname" );
	foreach( i, guy in level.op_helo.riders )
	{
		if( IsDefined( guy ) && IsAlive( guy ) )
		{
			node = GetNode( guy.target, "targetname" );
			guy notify( "unload" );
			guy anim_stopanimscripted();
			guy Unlink();
			guy ForceTeleport( tele_nodes[i].origin, tele_nodes[i].angles );
			guy thread follow_path( node );
		}
	}
	
	// TEMP TEMP - cleanup helo riders list
	level.op_helo.riders = [];
}

bc_helo_reinforce_kill()
{
	self endon( "death" );
	
	self waittillmatch( "single anim", "end" );
	self Delete();
}


//*******************************************************************
//																	*
//		AI SCRIPTS													*
//*******************************************************************

setup_spawners()
{
	level.mid_window_count = 2;
	
	array_spawn_function_targetname( "bc_opfor_crawl"  , 		::opfor_crawl );
	array_spawn_function_targetname( "bc_opfor_run"	   , 		::opfor_run );
	array_spawn_function_targetname( "bc_opfor_runback", 		::opfor_runback );
	array_spawn_function_noteworthy( "bc_opfor_mid_normal", 	::opfor_mid_normal );
	array_spawn_function_targetname( "bc_opfor_mid_lmg", 		::opfor_bc_lmg );
	array_spawn_function_noteworthy( "bc_opfor_kicker",  		::opfor_kicker );
	array_spawn_function_targetname( "bc_opfor_mid_window",		::opfor_mid_window );
	array_spawn_function_targetname( "bc_opfor_flank_left",		::opfor_left_flank_run );
	array_spawn_function_targetname( "bc_opfor_helo_rein",		::opfor_helo_rein );
	
	// setup semi-random right flank enemies
	spawners = GetEntArray( "bc_opfor_flank_right", "targetname" );
	foreach ( i, spawner in spawners )
		if ( RandomInt( 3 - i ) == 0 )
			spawner Delete();
	
	// setup low flying fastrope
	setup_low_rope_anims();
	
	// setup threatbias
	SetThreatBias( "player", "bc_lmg", 10000 );
}

opfor_crawl()
{
	self endon( "death" );
	
	self force_crawling_death( 0.0, RandomIntRange( 2, 3 ), undefined, true );
	self gun_remove();
	
	wait( 0.05 );
	// self Kill( self.origin + ( 0, 0, 200 ), level.player, level.player );
	level.player RadiusDamage( self.origin, 32, self.health, self.health, level.player, "MOD_RIFLE_BULLET" );
	// self DoDamage( self.health, self.origin + ( 0, 0, 200 ), level.player, level.player );
	// MagicBullet( "m4_grunt_reflex", self.origin + ( 0, 0, 200 ), self GetEye(), level.player );
}

opfor_run()
{
	self endon( "death" );
	
	self.animname = "generic";
	
	if ( IsDefined( self.script_parameters ) )
	{
		node = GetEnt( self.script_parameters, "targetname" );
		
		// setup anim exit
		exit_time = 0.1;
		if( self.script_parameters == "camp_pain_short_1" )
			exit_time = 1;
		else if( self.script_parameters == "camp_pain_tumble" )
			self.ragdoll_immediate = true;
		
		// vo
		if( IsDefined( self.script_noteworthy ) )
			self thread smart_dialogue( self.script_noteworthy );
		
		// animate
		self.allowdeath = true;
		node anim_generic_first_frame( self, self.script_parameters );
		node anim_single_solo( self, self.script_parameters, undefined, exit_time, "generic" );
		
		if( self.script_parameters == "camp_pain_dead" )
			self Kill();
		else if( self.script_parameters == "camp_pain_tumble" )
			self.ragdoll_immediate = undefined;
	}
}

opfor_runback()
{
	self endon( "death" );
	
	self.animname = "generic";
	
	// drop weapon
	self gun_remove();
	self set_ignoreall( true );
	self set_generic_run_anim( "unarmed_run", true );
	
	// reach goal and play runback animation
	node = GetEnt( self.target, "targetname" );
	node anim_generic_reach( self, self.script_parameters );
	if( IsDefined( self.script_noteworthy ) )
		self thread smart_dialogue( self.script_noteworthy );
	self.allowdeath = 1;
	node anim_single_solo( self, self.script_parameters, undefined, 0.1, "generic" );
	
	// run back
	runback_node = GetNode( self.target, "script_noteworthy" );
	self follow_path( runback_node );
	
	self waittill( "goal" );
	self gun_recall();
	self set_ignoreall( false );
	self clear_run_anim();
	node = GetNode( "bc_node_front_right", "targetname" );
	self follow_path( node );
}

opfor_mid_normal()
{
	self endon( "death" );
	
	// check if porch runner
	if ( IsDefined( self.script_parameters ) && self.script_parameters == "porch_runner" && RandomInt( 4 ) > 0 )
	{
		self thread opfor_porch_runner();
		return;
	}
	
	// setup suppression workaround
	myNode = GetNode( self.target, "targetname" );
	self thread ignore_move_suppression( "stop_suppression_workaround" );
	self thread notify_delay( "stop_suppression_workaround", 10 );
	self delayThread( 10.05, ::set_ignoreSuppression, false );
	
	// setup retreat
	flag_wait( "flag_camp_mid_retreat" );
	self thread follow_path( GetNode( myNode.target, "targetname" ) );
}

opfor_porch_runner()
{
	self endon( "death" );
	
	// ignore supression and run on the porch
	self thread ignore_move_suppression( "stop_suppression_workaround" );
	self thread follow_path( GetNode( "bc_node_porch_start", "targetname" ) );
	
	// wait till end of porch and reset ai
	flag_wait( "flag_bc_porch_runner_done" );
	self thread notify_delay( "stop_suppression_workaround", 5 );
	self delayThread( 5.05, ::set_ignoreSuppression, false );
}

ignore_move_suppression( note )
{
	self endon( "death" );
	if( IsDefined( note ) )
		self endon( note );
	
	while( 1 )
	{
		if( self IsMoveSuppressed() )
		{
			self set_ignoreSuppression( true );
			wait( 4 );
		}
		else if( IsDefined( self.ignoreSuppression ) && self.ignoreSuppression )
			self set_ignoreSuppression( false );
		
		wait( 0.25 );
	}
}

opfor_bc_lmg()
{
	self.ignoresuppression = true;
	self.disableBulletWhizbyReaction = true;
}

opfor_kicker()
{
	self endon( "death" );
	
	// go to door
	self thread magic_bullet_shield( true );
	self thread ignore_everything();
	vig_node = GetEnt( "bc_side_door_kick", "targetname" );
	vig_node anim_generic_reach( self, "door_kick" );
	
	// kick door
	vig_node anim_single_solo( self, "bc_door_kick", undefined, 0.1, "generic" );
	
	// go into combat
	goto_node = GetNode( "bc_node_door_kick_leave", "targetname" );
	self thread follow_path( goto_node );
	self thread stop_magic_bullet_shield();
	self thread unignore_everything();
}

opfor_mid_window()
{
	self waittill( "death" );
	level.mid_window_count -= 1;
}

opfor_left_flank_run()
{
	self endon( "death" );
	
	// init
	self thread follow_path( GetNode( "bc_node_windows", "targetname" ) );
	self set_ignoreall( true );
	
	// wait till near doorway
	node = getstruct( "bc_left_flank_runaway", "targetname" );
	while( Distance2D( self.origin, node.origin ) > 70 )
		wait( 0.05 );
	
	if( level.mid_window_count < 1 && Distance2D( level.player.origin, node.origin ) > 300 )
	{
		node anim_generic_reach( self, "run_180_1" );
		self.allowdeath = true;
		node anim_single_solo( self, "run_180_1", undefined, 0.5, "generic" );
		self thread follow_path( GetNode( "bc_node_left_run", "targetname" ) );
		self waittill( "goal" );
	}
	
	self set_ignoreall( false );
}

opfor_helo_rein()
{
	self endon( "death" );
	
	if( IsDefined( self.script_parameters ) )
		self.animname = self.script_parameters;
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
main_spot()
{
	spotlight = GetEnt( "cw_spotlight_1", "targetname" );
	targets	  = GetEntArray( "cw_spot_1_org", "targetname" );
	
	// Initial target
	next_target		 = GetEnt( "cw_spot_1_start", "targetname" );
	spotlight.angles = VectorToAngles( next_target.origin - spotlight.origin );
	
	// Turn on the spotlight
	PlayFXOnTag( level._effect[ "catwalk_spot" ], spotlight, "spotlight_main" );
	
	// Spawn a dummy origin that will move between targets
	dummy = next_target spawn_tag_origin();
	
	curr_dir = ( 0, 0, 0 );
	
	// This flag is set when starting from the ascend checkpoint
	if ( !flag( "bc_flag_spots_close" ) )
	{
		// Grab the next target
		next_target = GetEnt( "cw_spot_1_end", "targetname" );;
		target_dir	= VectorNormalize( next_target.origin - dummy.origin );
		curr_dir	= target_dir;
		
		// Set up spotlight-specific parameters
		spotlight.near_dist_sq	  = 100.0;
		spotlight.lerp_rate		  = 0.065;
		spotlight.velocity_factor = 200.0;
	
		delayThread( 5, ::flag_set, "bc_flag_spots_close" );
		thread spotlight_motion( dummy, next_target, curr_dir, spotlight, targets, "bc_flag_spots_close" );

		level waittill( "end_spotlight_motion", next_target, curr_dir );
	}

	//targets	 = GetEntArray( "cw_spot_close_org", "targetname" );
	targets		 = [];
	targets[ 0 ] = level.player;
	targets[ 1 ] = level._allies[ 0 ];
	targets[ 2 ] = level._allies[ 1 ];
	targets[ 3 ] = level._bravo [ 0 ];
	targets[ 4 ] = level._bravo [ 1 ];
	
	// Grab the next target
	next_target = targets[ RandomInt( targets.size ) ];
	target_dir	= VectorNormalize( next_target.origin - dummy.origin );
	curr_dir	= target_dir;
	
	// Set up spotlight-specific parameters
	spotlight.near_dist_sq	  = 32.0;
	spotlight.lerp_rate		  = 0.2;
	spotlight.velocity_factor = 100.0;
	
	thread spotlight_motion( dummy, next_target, curr_dir, spotlight, targets, "flag_ascend_start", true );
	
	level waittill( "end_spotlight_motion", next_target, curr_dir );
	
	// Spotlight focuses on player during ascend
	while ( !flag( "bc_flag_spots_off" ) )
	{
		noise_angles = ( RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ), 0 );
		new_angle	 = VectorToAngles( ( level.player.origin + noise_angles ) - spotlight.origin );
		spotlight RotateTo( new_angle, 0.3 );
		
		wait( 0.1 );
	}
	
	// Stop FX
	spotlight notify( "noise_off" );
	StopFXOnTag( level._effect[ "catwalk_spot" ], spotlight, "spotlight_main" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
fake_spot( spotlight_name, targets_name )
{
	// This flag is set when starting from the ascend checkpoint
	if ( !flag( "bc_flag_spots_close" ) )
	{
		// So, if we are progressing here normally, we want to randomize turning this on
		wait RandomFloatRange( 0.6, 1.8 );
	}
	
	spotlight = GetEnt( spotlight_name, "targetname" );
	targets	  = GetEntArray( targets_name, "targetname" );
	
	// Initial target
	next_target		 = targets[ RandomInt( targets.size ) ];
	spotlight.angles = VectorToAngles( next_target.origin - spotlight.origin );
	
	// Turn on the spotlight
	PlayFXOnTag( level._effect[ "catwalk_spot_cheap" ], spotlight, "spotlight_main" );
	
	// Spawn a dummy origin that will move between targets
	dummy = next_target spawn_tag_origin();
	
	// Grab the next target
	next_target = targets[ RandomInt( targets.size ) ];
	target_dir	= VectorNormalize( next_target.origin - dummy.origin );
	curr_dir	= target_dir;
	
	// Set up spotlight-specific parameters
	spotlight.near_dist_sq	  = 100.0;
	spotlight.lerp_rate		  = 0.065;
	spotlight.velocity_factor = 200.0;
	
	// <intentional non-thread>
	spotlight_motion( dummy, next_target, curr_dir, spotlight, targets, "bc_flag_spots_off" );
	
	// Stop FX
	spotlight notify( "noise_off" );
	StopFXOnTag( level._effect[ "catwalk_spot_cheap" ], spotlight, "spotlight_main" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
spotlight_motion( dummy, next_target, curr_dir, spotlight, targets, flag_end_str, main_spotlight )
{
	while ( !flag( flag_end_str ) )
	{
		while ( DistanceSquared( dummy.origin, next_target.origin ) > spotlight.near_dist_sq )
		{
			target_dir = VectorNormalize( next_target.origin - dummy.origin );
			
			// lerp the curr_dir to target_dir
			// curr = curr + ( target - curr ) * rate
			curr_dir += ( target_dir - curr_dir ) * spotlight.lerp_rate;
		
			// Move the dummy
			dummy.origin += curr_dir * spotlight.velocity_factor * level.TIMESTEP;
			
			// Add noise if applicable
			if ( IsDefined( main_spotlight ) && main_spotlight )
			{
				dummy.origin += ( RandomFloatRange( -1, 1 ), RandomFloatRange( -1, 1 ), RandomFloatRange( -1, 1 ) );
			}
			
			// Set the angles of the spotlight
			spotlight.angles = VectorToAngles( dummy.origin - spotlight.origin );
			
			wait level.TIMESTEP;
		}
		
		// Add additional noise and pause before grabbing the next target
		if ( IsDefined( main_spotlight ) && main_spotlight )
		{
			start_time = GetTime();
			wait_ms	   = RandomFloatRange( 1000, 3000 );
			while ( GetTime() - start_time < wait_ms )
			{
				dummy.origin += ( RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ), RandomFloatRange( -2, 2 ) );
				spotlight.angles = VectorToAngles( dummy.origin - spotlight.origin );
				wait level.TIMESTEP;
			}
		}
		
		// Save off the old target
		old_target = next_target;
		
		// And remove it from the array (don't want to go back and forth between same nodes)
		targets = array_remove( targets, old_target );
		
		// Now we want to only select valid targets that are "in front" of the current movement direction...
		// ...to keep the momentum going
		// ...if it's not the main spotlight
		removed = [];
		
		if ( !IsDefined( main_spotlight ) || ( IsDefined( main_spotlight ) && !main_spotlight ) )
		{
			valid_targs = true;
			
			foreach ( targ in targets )
			{
				// Looking for a 75 degree cone in front
				dot = VectorDot( VectorNormalize( curr_dir ), VectorNormalize( targ.origin - dummy.origin ) );
				if ( dot < 0.25 )
				{
					removed[ removed.size ] = targ;
				}
				
				// Check to see if we've eliminated all targets
				if ( targets.size == removed.size )
				{
					valid_targs = false;
					break;
				}
			}
			
			// As long as we still have valid targets, remove the invalid ones from the selection
			if ( valid_targs )
			{
				foreach ( targ in removed )
				{
					targets = array_remove( targets, targ );
				}
			}
			else // If we've eliminated them all, it requires further logic
			{
				num_to_remove = 3;
				if ( targets.size > num_to_remove )
				{
					// In this scenario, we'd prefer to grab a target that is further away from the current one...
					// ...so, first we'll calculate the distance between each of the targets from the current one
					foreach ( targ in targets )
						targ.dist2D = Distance2D( old_target.origin, targ.origin );
					
					// Now sort the array based on the 2D distances
					targets = array_sort_by_handler( targets, ::target_dist_compare );
					
					// Remove closest targets
					removed = [];
					
					for ( i = 0; i < num_to_remove; i++ )
					{
						removed[ i ] = targets[ i ];
						targets		 = array_remove( targets, removed[ i ] );
					}
				}
			}
		}
		
		// Grab the next target
		next_target = targets[ RandomInt( targets.size ) ];
		
		// Add the removed targets back into the array
		targets[ targets.size ] = old_target;
		
		foreach ( targ in removed )
		{
			targets[ targets.size ] = targ;
		}
		
		wait level.TIMESTEP;
	}
	
	level notify( "end_spotlight_motion", next_target, curr_dir );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
target_dist_compare()
{
	Assert( IsDefined( self ) && IsDefined( self.dist2D ), "Need dist2D property defined." );
	
	return self.dist2D;	
}

spot_noise()
{
	self endon( "noise_off" );
	
	while ( 1 )
	{
		noise_angles = ( RandomFloatRange( -0.25, 0.25 ), RandomFloatRange( -0.25, 0.25 ), RandomFloatRange( -0.25, 0.25 ) );
		self RotateTo( self.angles + noise_angles, 0.1 );
		wait( 0.1 );
	}
}


//*******************************************************************
//																	*
//		TEMP SCRIPTS												*
//*******************************************************************

delete_path_clip()
{
	self MoveZ( -10000, 0.05 );
	wait( 0.05 );
	self ConnectPaths();
	self Delete();
}

#using_animtree( "generic_human" ); 
setup_low_rope_anims()
{
	// setup ai exit
	level.vehicle_aianims[ "script_vehicle_mi24p_hind_blackice" ][ 2 ].getout = %ny_harbor_jump_out_hind_guy2; // %bh_side01_fastrope_whole_test;
	level.vehicle_aianims[ "script_vehicle_mi24p_hind_blackice" ][ 3 ].getout = %ny_harbor_jump_out_hind_guy2; // %bh_side01_fastrope_whole_test;
	level.vehicle_aianims[ "script_vehicle_mi24p_hind_blackice" ][ 4 ].getout = %ny_harbor_jump_out_hind_guy2; // %bh_side02_fastrope_whole_test;
	level.vehicle_aianims[ "script_vehicle_mi24p_hind_blackice" ][ 5 ].getout = %ny_harbor_jump_out_hind_guy2; // %bh_side02_fastrope_whole_test;
	level.vehicle_aianims[ "script_vehicle_mi24p_hind_blackice" ][ 6 ].getout = %ny_harbor_jump_out_hind_guy2; // %bh_side01_fastrope_whole_test;
	level.vehicle_aianims[ "script_vehicle_mi24p_hind_blackice" ][ 7 ].getout = %ny_harbor_jump_out_hind_guy2; // %bh_side02_fastrope_whole_test;
	
	// remove ropes
	// level.vehicle_attachedmodels[ "script_vehicle_mi24p_hind_blackice" ] = undefined;
	foreach( pos in level.vehicle_aianims[ "script_vehicle_mi24p_hind_blackice" ] )
		pos.fastroperig = undefined;
}