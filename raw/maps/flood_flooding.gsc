#include maps\_utility;
#include common_scripts\utility;
#include maps\_vehicle;
#include maps\flood_util;
#using_animtree("generic_human");

section_main()
{
}

section_precache()
{
	PreCacheModel( "flood_angryflood_edge_tracker_0" );
	PreCacheModel( "flood_angryflood_big_wave_1" );
	PreCacheModel( "flood_alley_flood_near_trackers" );
	PreCacheModel( "flood_alley_flood_far_trackers" );
	
//	PreCacheModel( "flood_waterball_mini" );
//	PreCacheModel( "trigger_radius_display_128" );
//	PreCacheModel( "trigger_radius_display_192" );
//	PreCacheModel( "trigger_radius_display_256" );
//	PreCacheModel( "ac_prs_bld_debris_wood_a_6" );
//	PreCacheModel( "ac_prs_enm_crates_b_debris_3" );
//	PrecacheModel( "ac_prs_prp_roof_debris_a_01" );
//	PreCacheModel( "foliage_tree_destroyed_tree_a" );

	PreCacheModel( "com_coffee_machine_destroyed" );
    PreCacheModel("road_barrier_post");
	PreCacheModel("com_trafficcone01");
	PreCacheModel("cardboard_box5");
	PreCacheModel("cardboard_box9");
	PreCacheModel("com_cardboardboxshortclosed_1");
	PreCacheModel("com_picture_16_scaled_large");
	PreCacheModel("com_copypaper_box");
	PreCacheModel("com_trash_bin_sml01");
	PreCacheModel("intro_wood_floorboard_piece02");
	PreCacheModel("intro_wood_floorboard_piece03");
	PreCacheModel("intro_wood_floorboard_piece01");
	PreCacheModel("com_office_book_blue_paper_folder");
	PreCacheModel("com_office_book_red_flat");
	PreCacheModel("com_picture_17_scaled_large");
	PreCacheModel("flood_crate_plastic_single02");
	
	PrecacheModel("com_plastic_crate_pallet");
	PrecacheModel("com_barrel_green");
	// PrecacheModel("com_wheelbarrow");
	PrecacheModel("com_trashcan_metal_with_trash");
	PrecacheModel("com_folding_chair");
	PrecacheModel("com_trafficcone02");
	PrecacheModel("com_plasticcase_beige_big");
	PrecacheModel("com_pallet_2");
	PrecacheModel("cardboard_box3");
	PrecacheModel("furniture_shelf_wood_1");
	PrecacheModel("com_trashbin01");
	PrecacheModel("com_bookshelves1_d");
	PrecacheModel("com_office_chair_killhouse");
	PrecacheModel("pb_weaponscase");
	
	PreCacheShellShock( "default_nosound" );
	PreCacheShellShock( "player_limp" );
}

section_flag_inits()
{
	flag_init( "alley_move_toend" );
	flag_init( "alley_move_shitfuck" );
	flag_init( "alley_move_kickdoor" );
	flag_init( "warehouse_door_breached" );
	flag_init( "player_doing_warehouse_mantle" );
	flag_init( "stop_alley_wakes" );
	flag_init( "ally0_stair_ready" );
	flag_init( "ally1_stair_ready" );
	flag_init( "moving_to_mall" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flooding_ext_start()
{
//	level.black_overlay = maps\_hud_util::create_client_overlay( "black", 1, level.player );
//    level.player FreezeControls( true );
	
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "flooding_ext_start" );
	//set_audio_zone( "flood_flooding_ext", 2 );	

	// spawn the allies.  should probably kill or deal with baker here.
	maps\flood_util::spawn_allies();
	
	maps\flood_util::setup_default_weapons();
	
	// last frame the allies to get them in the right spots to start
	allies_dam_vign();
	
	level.allies[ 0 ] thread ally0_main();
	level.allies[ 1 ] thread ally1_main();
	level.allies[ 2 ] thread ally2_main();
	
//	thread setup_missile_launcher();
		
	flag_set("end_of_dam");
}

flooding_ext()
{
	flag_wait("end_of_dam");
	
	// CF - Removing specific lines but leaving for reference
	// another autosave hitch being removed for greenlight
	// temp for greenlight
	//if( level.start_point != "dam" )
	level thread switch_to_last_player_weapon();
	level thread autosave_now();
	
	stop_exploder( "flak" );
	thread maps\flood_fx::alley_end_of_alley_fx();
	
	//starts warehouse debris effects
	thread maps\flood_fx::fx_warehouse_floating_debris();
	
	// this flag will turn off all of the old (uyeda) angry flood stuff
	level.OldAngryFlood = false;

	// FIX JKU re-enable weapon switch but force you back to a rifle if you have one in the anim script	
//	level.player DisableWeaponSwitch();
//	level.player DisableOffhandWeapons();
	
	// debug only
//	forward = AnglesToForward( level.player.angles );
//	level.player SetVelocity( forward * -100 );
//	thread maps\flood_util::print_player_speed();
	
	// Audio: start dam bursting water sfx (rumble, siren, tidal wave crashing)
	thread maps\flood_audio::sfx_dam_start_water();
	
	if( level.OldAngryFlood )
	{
		thread waterball_main_setup( "waterball_path_1" );
		// this is the ally ground water
		delayThread( 10, ::waterball_alley_stream_setup );
		thread alley_giantsplashes_left();
	}
	
	thread inside_loadingdocks();
	// set the warehouse doors to always be open
	thread breach_warehouse_doors();
	// adjust the player speed for the run from the water, give him unlimited sprint, etc...
	thread player_adjust_speed();
	thread alley_bokehdots();
	// setup big door state
	thread warehouse_collision_hacks_toggle();
	// wait till you get to the stairs and close the alley doors so you can't run too far back
	thread close_loading_dock_doors();
	// create kill triggers in alley so you can't run back
	thread alley_kill_triggers( "off" );
	// kill player if they get in front of floating lynx
	thread crush_player_with_floating_lynx();
	
	trigger = GetEnt( "inside_loadingdocks", "targetname" );
	trigger waittill( "trigger" );
	
	// stop the fx that may be running from the alley
	StopFXOnTag( GetFX( "bokehdots_and_waterdrops_heavy" ), level.flood_source_bokehdots, "tag_origin" );
}

//make player get up using the same gun they got knocked down with
switch_to_last_player_weapon()
{
	if(isdefined(level.dam_break_weapon))
	{
		level.player SwitchToWeapon(level.dam_break_weapon);
	}	
}

fade_up_black( fadeUpTime )
{
	level.black_overlay FadeOverTime( fadeUpTime );
	level.black_overlay.alpha = 0;
}

setup_missile_launcher()
{
   	ml = GetEnt( "missile_launcher_4", "targetname" );
    ml RotateYaw( -180, 0.01 );
}

player_adjust_speed()
{
	// FIX JKU DONT LEAVE THIS.  NEED TO DO THIS THE RIGHT WAY
	// Why can't I leave this?
//	level.player AllowSprint( false );
	level.player blend_movespeedscale( 0.4, 0.01 );
	level.player thread blend_movespeedscale_default( 3 );
//	wait 1.5;
//	level.player AllowSprint( true );
	
	// setup player movement stuff so you have more sprint, can't get ahead of guys and move similar regardless of the weapon you have.
	maps\flood_util::player_water_movement( 95, 0.01 );
	setSavedDvar( "player_sprintUnlimited", "1" );
	
	flag_wait( "player_at_stairs" );
	
	maps\flood_util::player_water_movement( 100, 2 );
	setSavedDvar( "player_sprintUnlimited", "0" );
}

ally_flee_setup( color )
{
	self clear_force_color();
	self disable_cqbwalk();
	SetSavedDvar( "ai_friendlyFireBlockDuration", 0 );
	self disable_surprise();
    self disable_pain();
	self.ignoreall = true;
	self.ignoreme = true;
    self.grenadeawareness = 0;
	self.dontavoidplayer = 1;
	self.ignoreSuppression = true;
	self.IgnoreRandomBulletDamage = true;
	self.ignoreExplosionEvents = true;
	self.disableBulletWhizbyReaction = true;
	self.disableFriendlyFireReaction = true;
	self animscripts\weaponList::RefillClip();
	
	// this is unique and can't use the ally version of the general script because the last bool passes makes sure the rising param is set.
//	self thread maps\flood_coverwater::entity_fx_and_anims_think( "mall_breach_start", ( 0, 0, 0 ), true );
	self.cw_in_rising_water = true;
	self thread ai_water_rising_think( "breach_start" );
	
	// set a fixed playbackrate so the timing is consistent
	self.flood_og_moveplaybackrate = self.moveplaybackrate;
	self.flood_og_movetransitionrate = self.movetransitionrate;
	self.flood_og_animplaybackrate = self.animplaybackrate;
	
	playbackrate = 1;
	self.moveplaybackrate = playbackrate;
	self.movetransitionrate = playbackrate;
	self.animplaybackrate = playbackrate;
}

ally_clear_flee_behavior()
{
	self disable_sprint();
	SetSavedDvar( "ai_friendlyFireBlockDuration", 2000 );
	self enable_surprise();
    self enable_pain();
	self disable_heat_behavior();
	self.ignoreall = false;
	self.ignoreme = false;
    self.grenadeawareness = 1;
	self.dontavoidplayer = 0;
    self.ignoreSuppression = false;
    self.IgnoreRandomBulletDamage = false;
    self.ignoreExplosionEvents = false;
    self.disableBulletWhizbyReaction = false;
    self.disableFriendlyFireReaction = false;
    
    // only reset these if they've been set in the first place.
    // they wouldn't be set if you skipped to checkpoint
    if( IsDefined( self.flood_og_moveplaybackrate ) )
    {
	    self.moveplaybackrate = self.flood_og_moveplaybackrate;
		self.movetransitionrate = self.flood_og_movetransitionrate;
		self.animplaybackrate = self.flood_og_animplaybackrate;
    }
}

ally_start_cornerwaving( anim_node, nowait )
{
	self endon( "death" );
//	level endon( "alley_move_toend" );
	
	if( !nowait )
	{
		// don't go straight into the waving so they'll flow into a run if you're right behind
		// this also gives them time to play they're stop anim under AI
		while( self.a.movement != "stop" )
			waitframe();
		
		wait( RandomFloatRange( 0.75, 1.25 ) );
	}
	
	self disable_heat_behavior();
	// FIX JKU talk to john w about why this isn't working
	self.prevMoveMode = "none"; 
	self notify( "move_loop_restart" );

	while( !flag( "alley_move_toend" ) )
	{
		anim_node maps\_anim::anim_loop_solo( self, "flood_cornerwaving_loop", "stop_loop" );
	}
}

block_ally_cornerwaving( dist )
{
	self endon( "death" );
	
	flag_wait( "alley_move_toend" );
	
	// let ally 1 get back ahead a little bit so the timing is correct and you're encouraged to follow ally 1
	ally_dist = Distance2D( level.allies[ 1 ].origin, self.origin );
	
	while( ally_dist < dist )
	{
		ally_dist = Distance2D( level.allies[ 1 ].origin, self.origin );
		waitframe();
	}
//	IPrintLn( self.animname + " dist: " + ally_dist );
}

allies_dam_vign()
{
	anim_node = getstruct( "vignette_dam_break", "script_noteworthy" );
	
	guys = [];
	guys["ally_0"] = level.allies[ 0 ];
	guys["ally_1"] = level.allies[ 1 ];
	guys["ally_2"] = level.allies[ 2 ];

//	level.allies[ 0 ] thread maps\flood_anim::dam_break_ally( anim_node );
//	level.allies[ 1 ] thread maps\flood_anim::dam_break_ally( anim_node );
//	level.allies[ 2 ] maps\flood_anim::dam_break_ally( anim_node );
	
	anim_node thread maps\_anim::anim_single( guys, "dam_break" );
	delayThread( 0.05, maps\_anim::anim_set_time, guys, "dam_break", 0.9 );
	wait 3;
}

ally_turnanim_hack( time )
{
	self endon( "death" );
	
	self.noTurnAnims = true;
	wait time;
	self.noTurnAnims = undefined;
}

block_until_fully_stopped_and_idle( anim_node, idle_loops, delay_time )
{
	self endon( "death" );
	
	while( self.a.movement != "stop" )
		waitframe();

	// delay for a time if wanted so they don't pop straight into their idle from something that would look bad like aiming
	wait delay_time;

	if( !flag( "alley_move_toend" ) )
		anim_node thread maps\_anim::anim_loop_solo( self, idle_loops, "stop_loop" );
}

ally0_main()
{
	self thread ally_flee_setup( "r" );
//	self enable_heat_behavior();
	self disable_heat_behavior();
	self PushPlayer( true );
	self ent_flag_init( "started_cornerwaving" );
	// need to do this to make sure they're not using the combat standrun move state
	self.alertlevelint = 1;
	
	// added for E3.  start him at a node that doesn't cause him to turn right away
//	next_node = getstruct( "ally0_flee_start", "targetname" );
//	next_node = block_until_at_struct( next_node, 400 );
	
	self.moveplaybackrate = self.moveplaybackrate - 0.06;
	next_node = getstruct( "ally0_flee_face", "targetname" );
	next_node thread maps\_anim::anim_reach_solo( self, "flood_cornerwaving_enter" );
	
	// wait until he gets closeish to the node and if the allies are running down the alley, skip the cornerwaving
	dist_to_node = Distance2D( next_node.origin, self.origin );
	while( dist_to_node > 200 )
	{
		dist_to_node = Distance2D( next_node.origin, self.origin );
		waitframe();
	}
	
	// don't do any cornerwaving if you're close enough that everyone keeps running
	if( !flag( "alley_move_toend" ) )
	{
		self waittill( "goal" );
		next_node maps\_anim::anim_single_solo( self, "flood_cornerwaving_enter" );
		next_node thread maps\_anim::anim_loop_solo( self, "flood_cornerwaving_loop", "stop_loop" );
		self ent_flag_set( "started_cornerwaving" );
		
		nags = [];
		//Price: Keep moving!
		nags[ 0 ] = "flood_bkr_keepmoving";
		//Price: Move, Elias!
		nags[ 1 ] = "flood_bkr_moverook";
		//Price: Pick up the pace, Elias!
		nags[ 2 ] = "flood_bkr_pickuppace";

		self delayThread( 0, maps\flood_util::play_nag, nags, "alley_move_toend", 3, 15, 3, 2 );
	}
	
	self.moveplaybackrate = self.moveplaybackrate + 0.06;
	
	self block_ally_cornerwaving( 230 );
	
	next_node notify( "stop_loop" );
	
	// don't do any cornerwaving if you're close enough that everyone keeps running
	if( self ent_flag( "started_cornerwaving" ) )
	{
		next_node maps\_anim::anim_single_run_solo( self, "flood_cornerwaving_run" );
	}
	
//	self disable_heat_behavior();
	// FIX JKU talk to john w about why this isn't working
	self enable_sprint();
	self.prevMoveMode = "none"; 
	self notify( "move_loop_restart" );

	next_node = getstruct( next_node.target, "targetname" );	
	self thread ally_alley_flood_spawn( next_node );
	next_node maps\_anim::anim_reach_solo( self, "flood_warehouse_breach" );
	
	// wait for baker to shitfuck before starting door kick
//	flag_wait( "alley_move_shitfuck" );

	// Audio: Stop alley water
	thread maps\flood_audio::sfx_stop_alley_water();
	
	// FIX JKU notetrack?
	self thread ally0_inhere();
	self disable_sprint();
	exploder( "wh_lipwater" );
	next_node maps\_anim::anim_single_run_solo( self, "flood_warehouse_breach" );
	
	self ally0_main_int();
}

ally1_main()
{
	self thread ally_flee_setup( "r" );
	self enable_sprint();
//	self enable_heat_behavior();
	self disable_heat_behavior();
	self PushPlayer( true );
	// need to do this to make sure they're not using the combat standrun move state
	self.alertlevelint = 1;

	//Vargas: It's the flood waters! We need to move!
	self delayThread( 2, ::dialogue_queue, "flood_diz_floodwaters" );
	
	// extra node to try and get them to face down the ally
	// this is an exposed node to get them to face the correct direction
	self.goalradius = 128;
	self.moveplaybackrate = self.moveplaybackrate + 0.03;
	next_node = GetNode( "ally1_flee_face", "targetname" );
	self SetGoalNode( next_node );
	self.flood_current_goalnode = next_node.targetname;
	self waittill( "goal" );
	self.moveplaybackrate = self.moveplaybackrate - 0.03;
	
	// thread the script for the idles so we can simply break out below when needed
	self thread block_until_fully_stopped_and_idle( next_node, "flood_cornerwaving_loop", 1 );
//	next_node maps\_anim::anim_reach_and_approach_solo( self, "flood_cornerwaving_loop" );
//	next_node thread maps\_anim::anim_loop_solo( self, "flood_cornerwaving_loop", "stop_loop" );
	
	// FIX JKU  this should be only temp and be removed when stuff gets fixed
	self thread ally_turnanim_hack( 4 );

	// need to wait/wave for player here if you're not close enough
	player_dist = Distance2D( level.player.origin, self.origin );
	while( player_dist > 550 )
	{
		player_dist = Distance2D( level.player.origin, self.origin );
//		IPrintLn( player_dist );
		waitframe();
	}
	
	flag_set( "alley_move_toend" );
	next_node notify( "stop_loop" );
	self StopAnimScripted();

//	self disable_heat_behavior();
	// FIX JKU talk to john w about why this isn't working
	self.prevMoveMode = "none"; 
	self notify( "move_loop_restart" );

	// FIX JKU VO we need this line for vargas
	//Price: Down the alley!
	level.allies[ 1 ] thread dialogue_queue( "flood_bkr_downthealley" );
	//Merrick: The water's right on our tail!
//	level.allies[ 2 ] delayThread( 2.5, ::dialogue_queue, "flood_kgn_onourtail" );

	// shitfuck!
	// run to the end of the ally
	next_node = getstruct( next_node.target, "targetname" );
	next_node = block_until_at_struct( next_node, 666 );

	flag_set( "alley_move_shitfuck" );

	level notify( "stop_crazyness" );
		
	// Audio: Fade down and stop the siren sfx
	thread maps\flood_audio::stop_sfx_dam_siren_ext();
	thread maps\flood_audio::start_sfx_dam_siren_int();	
	
	// 180 turn node
	// skip the node before the door node so it looks smoother for E3.  Hopefully we should be able to leave it this way
	next_node = getstruct( next_node.target, "targetname" );
	self.moveplaybackrate = self.moveplaybackrate - 0.1;
	next_node = block_until_at_struct( next_node, 666 );

	// go back to the doors
//	next_node = block_until_at_struct( next_node );

	self.moveplaybackrate = self.moveplaybackrate + 0.1;
	self disable_sprint();

//	thread add_dialogue_line( self.name, "Come on! Come on!" );
	self ally1_main_int();
}

ally2_main()
{
	self thread ally_flee_setup( "r" );
	self enable_sprint();
//	self enable_heat_behavior();
	self disable_heat_behavior();
	self PushPlayer( true );
	// need to do this to make sure they're not using the combat standrun move state
	self.alertlevelint = 1;
	
	// special flag to see if keegan should be snapped closer to you in the loading docks
	self.flood_hasmantled = false;
		
	//Merrick: Let's move it, Elias!
	self thread dialogue_queue( "flood_kgn_letsmoveit" );
	
	// extra node to try and get them to face down the ally
	// this is an exposed node to get them to face the correct direction
	self.goalradius = 128;
	self.moveplaybackrate = self.moveplaybackrate + 0.04;
	next_node = GetNode( "ally2_flee_face", "targetname" );
	self SetGoalNode( next_node );
	self.flood_current_goalnode = next_node.targetname;
	self waittill( "goal" );
	self.moveplaybackrate = self.moveplaybackrate - 0.04;
	cornerwaving_time = GetTime();
	next_node = getstruct( next_node.target, "targetname" );	
//	self disable_heat_behavior();

	// FIX JKU  this should be only temp and be removed when stuff gets fixed
	self thread ally_turnanim_hack( 4 );

	self block_ally_cornerwaving( 88 );
	cornerwaving_time = GetTime() - cornerwaving_time;

	// FIX JKU talk to john w about why this isn't working
	self.prevMoveMode = "none"; 
	self notify( "move_loop_restart" );
	
//	if( cornerwaving_time > 400 )
//		self delayThread( 3.25, ::alley_stumble );
//	else
//		self delayThread( 2.25, ::alley_stumble );

	// run to end of alley
	next_node = block_until_at_struct( next_node );
	
	// 180 turn node.
	// skip the node before the door node so it looks smoother for E3.  Hopefully we should be able to leave it this way
	next_node = getstruct( next_node.target, "targetname" );
	self.moveplaybackrate = self.moveplaybackrate - 0.1;
	next_node = block_until_at_struct( next_node, 666 );

	// run to double doors
//	next_node = block_until_at_struct( next_node );
	
	self.moveplaybackrate = self.moveplaybackrate + 0.1;
	self disable_sprint();
	
	self ally2_main_int();
}
	
ally0_start_path2( shitfuck_node )
{
	self endon( "death" );
	
	shitfuck_dist = Distance2D( shitfuck_node.origin, self.origin );
	while( 1 )
	{
		if( shitfuck_dist < 510 )
		{
			thread waterball_main_setup( "waterball_path_2" );
//			thread damage_vehicles_path2();
			break;
		}
		shitfuck_dist = Distance2D( shitfuck_node.origin, self.origin );
		waitframe();
	}	
}

alley_stumble()
{
	self endon( "death" );

	// run_stumble run_flinch run_duck
	self.run_overrideanim = getgenericanim( "run_stumble_non_loop" );
	wait GetAnimLength( getgenericanim( "run_stumble_non_loop" ) );
	self.run_overrideanim = undefined;
	self.prevMoveMode = "none"; 
	self notify( "move_loop_restart" );
}

ally_alley_flood_spawn( dist_node )
{
	self endon( "death" );
	
	//edit PH- don't want to use this water anymore
	//delayThread ( 0.0, maps\flood_fx::alley_water_show_and_move );
	
	// DelayThread(0, ::Exploder, "flood_alley_paper");
	flood_spawn_dist = Distance2D( dist_node.origin, self.origin );
	// this dist determines when we start the alley flood anim
	// this is the dist from where diaz starts the door breach anim
	// lower means the truck hits later
	while( flood_spawn_dist > 850 )
	{
		flood_spawn_dist = Distance2D( dist_node.origin, self.origin );
		waitframe();
	}

	// Audio: Play alley tidal wave SFX / truck impact
	thread maps\flood_audio::sfx_dam_tidal_wave_02();
	
//	IPrintLn( flood_spawn_dist );
	thread maps\flood_anim::alley_flood_spawn();
//	delayThread( 2, maps\flood_fx::alley_fill_shallow, "alley_fill_shallow_end", "flood_water_alley_fill_shallow" );
	
	//exploder("wh_coverplashes");
}

ally0_inhere()
{
	wait 0.3;

	//Price: Dead end!
	level.allies[ 1 ] thread dialogue_queue( "flood_kgn_weretrapped" );
		
	wait 0.2;
	// only tell them to move towards the door if they're not already moving towards that node
	if( level.allies[ 1 ].flood_current_goalnode == "ally1_alley_node" )
		level.allies[ 1 ] notify( "goal" );
	
	wait 0.6;
	//Vargas: In here!
	self thread dialogue_queue( "flood_diz_inhere" );
	
	wait 0.2;
	if( level.allies[ 2 ].flood_current_goalnode == "ally2_alley_node" )
		level.allies[ 2 ] notify( "goal" );
}

open_loading_dock_doors( guy )
{
	thread start_loadingdocks_water();
	
	// wait here to give the water a chance to move to position
	waitframe();
	
	left_door_parts = GetEntArray( "alley_door_l", "targetname" );
	right_door_parts = GetEntArray( "alley_door_r", "targetname" );
	
	//sfx for doors opening
	thread maps\flood_audio::diaz_door_kick_sfx();
	thread maps\flood_fx::fx_warehouse_door_breach();
	
	door_open_time = 0.3;
	
	foreach( ent in left_door_parts )
	{
		ent RotateYaw( 85, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}
	
	foreach( ent in right_door_parts )
	{
		ent RotateYaw( -85, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}
	
	// FIX JKU need to revisit this and see if there's a better way to fix this other than turning off the door collision
	wait 0.2;
	collision_hack = GetEnt( "loading_dock_door_hack", "targetname" );
	collision_hack NotSolid();
}

close_loading_dock_doors()
{
	flag_wait( "player_at_stairs" );
	
	left_door_parts = GetEntArray( "alley_door_l", "targetname" );
	right_door_parts = GetEntArray( "alley_door_r", "targetname" );
	
	door_open_time = 0.3;
	
	foreach( ent in left_door_parts )
	{
		ent RotateYaw( -85, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent DisconnectPaths();
	}
	
	foreach( ent in right_door_parts )
	{
		ent RotateYaw( 85, door_open_time, 0, 0.2 );
		if( ent.classname == "script_brushmodel" )
			ent DisconnectPaths();
	}
}

waterball_main_setup( path )
{
	level endon( "enter_loadingdocks" );
	level endon( "stop_crazyness" );
	
	// start the small balls first then get bigger.
	wave_delay = 0.25;
	
	// small wave that maybe you can run through
	// don't need this for the second street
	if( path == "waterball_path_1" )
	{
		// giantsplashes near the church that hide the object creation
		thread waterball_main_startfx( path );
		// start the low water before we do anything big
		thread waterball_main_stream_setup( path );
		// JKU delay so the new vignette has some time to happen
		wait 4;
//		thread damage_vehicles_path1();
	}
	
	// start the wave to the left
	for( i = 0; i < 15; i++ )
		thread waterball_main_spawn( path, "debris", 666, true );
	for( i = 0; i < 6; i++ )
		thread waterball_main_spawn( path, "medium_water_splash", 4, true );
	wait wave_delay;
	
	// spawn these to make sure you can't hide on the sides
	if( path == "waterball_path_1" )
		thread waterball_main_side_setup( path );
		
	// main infinite spawn
	for( ;; )
	{
		// FIX JKU stop the ground water when the big stuff comes.  was running out of ents.
//		for( n = 0; n < 4; n++ )
//			thread waterball_main_stream( path );
		thread waterball_main_spawn( path, "debris", 666, false );
		thread waterball_main_spawn( path, "debris", 666, false );
		thread waterball_main_spawn( path, "debris", 666, false );
		if( path == "waterball_path_1" )
			thread waterball_main_spawn( path, "medium_water_splash", 8, false );
		else
			thread waterball_main_spawn( path, "medium_water_splash", 666, false );
		wait wave_delay;
	}
}

waterball_test()
{
//	pos_start = ( GetEnt( "waterball_path_1", "targetname" ) ).origin;
//	waterball = Spawn( "script_model", ( pos_start + ( 0, 0, 10 ) ) );
//	waterball SetModel( "vehicle_btr80_d" );
//	waterball.angles = ( 0, 45, 0 );
//	waterball RotateTo( ( -90, 0, 0 ), 2 );
//	waterball thread waterball_play_smallfx_fast();
//	wait 2;
//	waterball RotateVelocity( ( 90, 0, 0 ), 3000 );
}

waterball_debris_whee()
{
	self RotateVelocity( ( RandomFloatRange( -200, 200 ), RandomFloatRange( -200, 200 ), RandomFloatRange( -200, 200 ) ), 3000 );
	wait 4;
	self RotateVelocity( ( 0, 0, RandomFloatRange( 50, 200 ) ), 3000 );
}

waterball_main_spawn( path, type, chance, asymmetrical )
{
	path_nodes = waterball_get_pathnodes( path );
	
	// setup random offsets
	// offset to the left at the start to create a wedge you can run away from
	if( IsDefined( asymmetrical ) && asymmetrical )
		waterball_x = RandomFloatRange( -300, 0 );
	else
		waterball_x = RandomFloatRange( -300, 300 );
	
	waterball_y = RandomFloatRange( -1000, 0 );
	waterball_z = RandomFloatRange( 30, 50 );
	waterball_speed = RandomFloatRange( 1100, 1450 );

	start_path_node = 0;
	waterball = Spawn( "script_model", ( path_nodes[start_path_node].origin + ( waterball_x, waterball_y, waterball_z ) ) );
	
	// attach trigger radius to deal damage
	waterball thread trigger_radius_damage( 128, 50 );
	
	
	if( type == "debris" )
	{
		debris[0] ="ac_prs_bld_debris_wood_a_6";
		debris[1] ="ac_prs_enm_crates_b_debris_3";
		debris[2] ="ac_prs_prp_roof_debris_a_01";
		debris[3] ="com_coffee_machine_destroyed";
		debris[4] ="vehicle_man_7t_iw6";
		debris[5] ="foliage_tree_destroyed_tree_a";
		debris[6] ="vehicle_iveco_lynx_iw6";
		
		type = debris[ RandomInt( debris.size ) ];
//		waterball SetModel( "trigger_radius_display_128" );
//		waterball SetModel( type );

		// need to do this or we run out of light cache
		waterball StartUsingLessFrequentLighting();
		// randomly rotate ???
//		waterball.angles = ( 275, 270, 90 );
		
		// start spinning
//		waterball thread waterball_debris_whee();
		waterball RotateVelocity( ( RandomFloatRange( -200, 200 ), RandomFloatRange( -200, 200 ), RandomFloatRange( -200, 200 ) ), 3000 );
	}
	else
	{
//		waterball SetModel( "trigger_radius_display_128" );
		waterball SetModel( "tag_origin" );
		waterball thread waterball_play_fx( type );
		waterball thread waterball_play_bigfx( chance );
	}

	// move along path
	next_path_node = 1;
	while( IsDefined( path_nodes[next_path_node] ) )
	{
		waterball_time = ( Distance( path_nodes[start_path_node].origin, path_nodes[next_path_node].origin ) / waterball_speed );
		waterball MoveTo( path_nodes[next_path_node].origin + ( waterball_x, waterball_y, waterball_z ), waterball_time );
		wait waterball_time;
		start_path_node++;
		next_path_node++;
	}
	
	waterball Delete();
}

waterball_main_side_setup( path )
{
	level endon( "enter_loadingdocks" );
	level endon( "stop_crazyness" );
	
	// wait for a moment so you can move to the side and be safe to allow you more time to see the crazy shit!
	wait 5;
	
	while( 1 )
	{
		thread waterball_main_side_spawn( path, 320 );
		thread waterball_main_side_spawn( path, -500 );
		wait RandomFloatRange( 0.3, 0.5 );
	}
}

waterball_main_side_spawn( path, offset )
{
	level endon( "enter_loadingdocks" );
	
	path_nodes = waterball_get_pathnodes( path );
	start_path_node = 0;
	
	waterball = Spawn( "script_model", ( path_nodes[start_path_node].origin + ( offset, 0, 0 ) ) );
//	waterball SetModel( "trigger_radius_display_256" );
	waterball SetModel( "tag_origin" );
	waterball thread trigger_radius_damage( 256, 50 );
	waterball thread waterball_play_fx( "medium_water_splash" );
	
	// move along path
	next_path_node = 1;
	while( IsDefined( path_nodes[next_path_node] ) )
	{
		waterball_time = ( Distance( path_nodes[start_path_node].origin, path_nodes[next_path_node].origin ) / 1500 );
		waterball MoveTo( path_nodes[next_path_node].origin + ( offset, 0, 0 ), waterball_time );
		wait waterball_time;
		start_path_node++;
		next_path_node++;
	}
	
	waterball Delete();
}

waterball_main_stream_setup( path )
{
	for( i = 0; i < 10; i++ )
	{
		for( n = 0; n < 6; n++ )
			thread waterball_main_stream( path );
		wait 0.25;;
	}
}
	
waterball_main_stream( path )
{
	path_nodes = waterball_get_pathnodes( path );
	
	// setup random offsets
	waterball_x = RandomFloatRange( -300, 300 );
	waterball_y = RandomFloatRange( -100, 0 );
	waterball_z = RandomFloatRange( 5, 15 );
	waterball_speed = RandomFloatRange( 800, 1000 );
	
	// this is a little lame because i'm assuming you know the size of the path_pos array
	rnd_start_path = RandomIntRange( 1, 4 );
	
	waterball = Spawn( "script_model", ( path_nodes[rnd_start_path].origin + ( waterball_x, waterball_y, waterball_z ) ) );
	waterball SetModel( "tag_origin" );
	waterball.angles = ( 275, 270, 90 );
	
	// attach ball size test
	waterball thread trigger_radius_push( 128, 50 );

	// attach fx
	waterball thread waterball_play_smallfx_fast();
	
	// start the churning water rotation
	waterball RotateVelocity( ( 0, 0, RandomFloatRange( -50, 50 ) ), 3000 );

	// move along path
	next_path_node = rnd_start_path + 1;
	while( IsDefined( path_nodes[next_path_node] ) )
	{
		// rotate the nodes if they're not coming down the hill anymore
		if( next_path_node == 4 )
			waterball RotateTo( ( -90, 0, 0 ), 0.25 );
		
		waterball_time = ( Distance( path_nodes[rnd_start_path].origin, path_nodes[next_path_node].origin ) / waterball_speed );
		waterball MoveTo( path_nodes[next_path_node].origin + ( waterball_x, waterball_y, waterball_z ), waterball_time );
		wait waterball_time;
		rnd_start_path++;
		next_path_node++;
	}
		
	waterball notify( "finished" );
	waterball Delete();
}

waterball_get_pathnodes( targetname )
{
	next_node = getstruct( targetname, "targetname" );

	for( node_num = 0; IsDefined( next_node.target ); node_num++ )
	{
//		IPrintLn( next_node.origin );
		array[node_num] = next_node;
		next_node = getstruct( next_node.target, "targetname" );
	}
	array[node_num] = next_node;
	return( array );
}

// play fx as the balls move down the path
waterball_play_smallfx( chance )
{
	if( RandomInt ( chance ) == 1 )
		PlayFXOnTag( level._effect[ "small_water_splash" ], self, "tag_origin" );
}

waterball_play_smallfx_fast()
{
	PlayFXOnTag( level._effect[ "small_water_splash_fast" ], self, "tag_origin" );
}

waterball_play_fx( fx )
{	
	self endon( "death" );

	PlayFXOnTag( level._effect[ "medium_water_splash" ], self, "tag_origin" );
}

waterball_play_bigfx( chance )
{	
	self endon( "death" );

	if( chance != 666 )
	{
		wait RandomFloatRange( 1, 5 );
		if( RandomInt ( chance ) == 1 )
			PlayFX( level._effect[ "giant_water_splash" ], self.origin );
	}
}

// play fx at the start to hide the ball creation
waterball_main_startfx( path )
{	
	level endon( "enter_loadingdocks" );
	level endon( "stop_crazyness" );

	pos_start = ( GetEnt( path, "targetname" ) ).origin;

	PlayFX( level._effect[ "giant_water_splash" ], pos_start + ( 0, 0, -200 ) );
	
	for( i = 0; i < 12; i++ )
	{
		PlayFX( level._effect[ "giant_water_splash" ], pos_start + ( RandomFloatRange( -600, 600 ), -400, RandomFloatRange( -300, -200 ) ) );
		wait RandomFloatRange( 0.1, 0.4 );
	}
}

waterball_alley_stream_setup()
{
	level endon( "enter_loadingdocks" );
	
	wave_delay = 0.15;
	
	path3 = GetEnt( "waterball_path_3", "targetname" );
	path4 = GetEnt( "waterball_path_4", "targetname" );
	
	for( ;; )
	{
		thread waterball_alley_stream_spawn( "flood_waterball_mini", path3, -90, 2 );
		thread waterball_alley_stream_spawn( "flood_waterball_mini", path4, 90, 2 );
		wait wave_delay;
	}
}

waterball_alley_stream_spawn( model, path, rot, chance )
{
	// setup random offsets
	waterball_x = RandomFloatRange( -100, 100 );
	waterball_y = RandomFloatRange( -100, 100 );
	waterball_z = RandomFloatRange( 5, 12 );
	waterball_speed = RandomFloatRange( 150, 200 );

	waterball = Spawn( "script_model", ( path.origin + ( waterball_x, waterball_y, waterball_z ) ) );
	waterball SetModel( "tag_origin" );
	waterball.angles = ( -90, 0, 0 );
	
	// need to do this or we run out of light cache
	waterball StartUsingLessFrequentLighting();
	
	// make the water look like its swirling
	waterball RotateVelocity( ( 0, 0, RandomFloatRange( -50, 0 ) ), 3000 );
	
	waterball thread waterball_play_smallfx( chance );
	next_node = GetEnt( path.target, "targetname" );
	waterball_time = ( Distance( path.origin, next_node.origin ) / waterball_speed );
	waterball MoveTo( next_node.origin + ( waterball_x, waterball_y, waterball_z ), waterball_time );
	wait waterball_time;
	
	waterball Delete();
}
 
waterball_alley_setup()
{
	level endon( "breach_start" );
	
	// start the water flowing into the loading docks
	// remove this for now as I don't think I want this to work this way
//	thread waterball_loadingdocks_setup();
		
	wave_delay = 1;
	
	path3 = GetEnt( "waterball_path_3", "targetname" );
	path4 = GetEnt( "waterball_path_4", "targetname" );
	
	for( ;; )
	{
		thread waterball_alley_spawn( path3 );
		thread waterball_alley_spawn( path4 );
		wait wave_delay;
	}
}

waterball_alley_spawn( path )
{
	// setup random offsets
//	waterball_y = 90;
	// temp remove the offset untill I find a better way to offset the damage ball
	waterball_y = 0;
	waterball_speed = 200;

	waterball = Spawn( "script_model", ( path.origin + ( 0, waterball_y, 0 ) ) );
	waterball SetModel( "tag_origin" );
	
	waterball thread waterball_play_fx( "medium_water_splash" );
	waterball thread trigger_radius_damage( 180, 75 );
	
	next_node = GetEnt( path.target, "targetname" );
	waterball_time = ( Distance( path.origin, next_node.origin ) / waterball_speed );
	waterball MoveTo( next_node.origin + ( 0, waterball_y, 0 ), waterball_time );
	wait waterball_time;
	
	waterball Delete();
}
 
waterball_loadingdocks_setup()
{
	level endon( "breach_start" );
	
	wait 4;
	
	wave_delay = 1;
	
	path = GetEnt( "waterball_path_5", "targetname" );
	
	for( ;; )
	{
		thread waterball_loadingdocks_spawn( path );
		wait wave_delay;
	}
}

waterball_loadingdocks_spawn( path )
{
	// setup random offsets
//	waterball_y = 90;
	// temp remove the offset untill I find a better way to offset the damage ball
	waterball_y = 0;
	waterball_speed = 200;

	waterball = Spawn( "script_model", ( path.origin + ( 0, waterball_y, 0 ) ) );
	waterball SetModel( "tag_origin" );
	
	waterball thread waterball_play_fx( "medium_water_splash" );
	waterball thread trigger_radius_damage( 130, 20 );
	
	next_node = GetEnt( path.target, "targetname" );
	waterball_time = ( Distance( path.origin, next_node.origin ) / waterball_speed );
	waterball MoveTo( next_node.origin + ( 0, waterball_y, 0 ), waterball_time );
	wait waterball_time;
	
	waterball Delete();
}
 
waterball_loadingdocks_floor()
{
	level endon( "breach_start" );
	
	wave_delay = 0.05;
	floor_array = GetEntArray( "loadingdocks_floor", "targetname" );
	
	for( ;; )
	{
		floor_node = floor_array[ RandomInt( floor_array.size ) ];
		PlayFX( level._effect[ "small_water_splash" ], ( floor_node.origin + ( 0, 0, 10 ) ) );
		wait wave_delay;
	}
}

moving_damage_radius_think_damage( damage )
{
	self endon( "death" );
	
	self waittill( "trigger" );
	level.player DoDamage( damage, level.player.origin);
	level.player ShellShock( "default_nosound", 0.5 );
}

moving_damage_radius_think_push( push )
{
	self endon( "death" );
	
	self waittill( "trigger" );
//	level.player ShellShock( "default", 1 );
}

trigger_radius_damage( radius, damage )
{
	trigger_radius = Spawn( "trigger_radius", ( self.origin ), 0, radius, radius );
	trigger_radius EnableLinkTo();
	trigger_radius LinkTo( self );
	trigger_radius thread moving_damage_radius_think_damage( damage );
	
	self waittill( "death" );
	trigger_radius Delete();
}

trigger_radius_push( radius, push )
{
	trigger_radius = Spawn( "trigger_radius", ( self.origin ), 0, radius, radius );
	trigger_radius EnableLinkTo();
	trigger_radius LinkTo( self );
	trigger_radius thread moving_damage_radius_think_push( push );
	
	self waittill( "death" );
	trigger_radius Delete();
}
damage_vehicles_path1()
{
	level endon( "enter_loadingdocks" );
	level endon( "stop_crazyness" );

	vehicle = GetEnt( "flood_street_car_1", "script_noteworthy" );
	vehicle thread damage_vehicle_think( 1 );

	vehicle = GetEnt( "flood_street_car_2", "script_noteworthy" );
	vehicle thread damage_vehicle_think( 3 );

	vehicle = GetEnt( "flood_street_car_3", "script_noteworthy" );
	vehicle thread damage_vehicle_think( 4.5 );

	vehicle = GetEnt( "flood_street_car_4", "script_noteworthy" );
	vehicle thread damage_vehicle_think( 4.5 );

	vehicle = GetEnt( "flood_street_car_5", "script_noteworthy" );
	vehicle thread damage_vehicle_think( 5 );
}

damage_vehicles_path2()
{
	vehicle = GetEnt( "flood_street_car_path2_1", "script_noteworthy" );
	vehicle thread damage_vehicle_think( 1.8 );
	wait 2.2;
	thread alley_giantsplashes_right();
}

damage_vehicle_think( wait_time )
{
//	self JoltBody( self.origin, 5 );
//	wait 1;
	wait wait_time;
	self DoDamage( 999999, self.origin );
	vector = ( AnglesToUp( self.origin ) * 1000 );
	self VehPhys_Launch( vector, 2 );
	wait 5;
//	self Delete();
}

alley_giantsplashes_left()
{
	level endon( "enter_loadingdocks" );
	
	trigger = GetEnt( "alley_splashes", "targetname" );
	trigger waittill( "trigger" );
	
	for( ;; )
	{
		PlayFX( level._effect[ "giant_water_splash" ], GetEnt( "alley_giantsplash_left", "targetname" ).origin );
		wait 3;
	}
}

alley_giantsplashes_right()
{
	level endon( "enter_loadingdocks" );
	
	for( ;; )
	{
		PlayFX( level._effect[ "giant_water_splash" ], GetEnt( "alley_giantsplash_right", "targetname" ).origin );
		wait 3;
	}
}

inside_loadingdocks()
{
	trigger = GetEnt( "inside_loadingdocks", "targetname" );
	trigger waittill( "trigger" );
	level notify( "enter_loadingdocks" );
}

setup_loadingdocks_water()
{
	// first call the water height in so we can get it up to the warehouse ground instantly
	// standard warehouse water
	thread start_coverheight_water_rising( -125, true, "coverwater_warehouse" );
	// loading docks water that's up high so it has lighting like it's up high.  this is swapped in when you mantle
	thread start_coverheight_water_rising( -125, true, "coverwater_warehouse_postmantle" );
	// loading docks water that has lower lighting.  this is what you see when you first enter the loading docks and is swapped out when you mantle
	thread start_coverheight_water_rising( -0, true, "coverwater_warehouse_premantle" );
	
	// theres something messed up here and I need to wait longer than I should.  no biggie but something to be aware of
	wait 0.1;
	
	//thread maps\flood_fx::fx_warehouse_splashes();
	//thread maps\flood_fx::fx_warehouse_stop_cover_water();

}

start_loadingdocks_water()
{
	// setup an ent that goes between the double doors that fx can link to
	level.flood_double_door_center = GetEnt( "double_door_center_ent", "targetname" );
	water_ent = GetEntArray( "coverwater_warehouse", "targetname" );
	
	level.flood_double_door_center LinkTo( water_ent[ 0 ] );
//	level.flood_double_door_center SetModel( "flood_waterball_mini" );	
		
	setup_loadingdocks_water();
	
	// start checking if the player is in water
	// must be passed the name of the water plane if water is rising.  if not pass "none"
	thread maps\flood_coverwater::register_coverwater_area( "coverwater_warehouse", "swept_away" );
	thread start_coverheight_water_rising( 1, false, "coverwater_warehouse" );
	level.cw_player_in_rising_water = true;
	// default time the player is allowed to be underneath cover water
	level.cw_player_allowed_underwater_time = 1;

	// use this to test eyelevel stuff
//	thread maps\flood_coverwater::register_coverwater_area( "water_loadingdocks", "swept_away" );
//	thread maps\flood_util::start_coverheight_water_rising( 10, true, "water_loadingdocks_lower_high" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************

flooding_int_start()
{
	// setup and teleport player
	maps\flood_util::player_move_to_checkpoint_start( "flooding_int_start" );
	
	VisionSetNaked("flood_warehouse", 0);
	fog_set_changes( "flood_warehouse", 0);
 	level.cw_vision_above = "flood_warehouse";
	level.cw_fog_above = "flood_warehouse";

	// spawn the allies.  should probably kill or deal with baker here.
	maps\flood_util::spawn_allies();
	
	// teleport the allies to make sure they're in the correct place after progression
	maps\flood_util::allies_move_to_checkpoint_start( "flooding_int", true );
	
	level.allies[ 0 ] ally_flee_setup( "r" );
	level.allies[ 1 ] ally_flee_setup( "r" );
	level.allies[ 2 ] ally_flee_setup( "r" );

	level.allies[ 0 ] thread ally0_main_int();
	level.allies[ 1 ] thread ally1_main_int();
	level.allies[ 2 ] thread ally2_main_int();
	
	// start the floating debris effects if they haven't already started (if the player started at the interior checkpoint)
	thread maps\flood_fx::fx_warehouse_floating_debris_int();
	
	// start the rising water at the correct height
	thread start_loadingdocks_water();
	// set the warehouse doors to always be open
	thread breach_warehouse_doors();
	// adjust the player speed for the run from the water, give him unlimited sprint, etc...
	thread player_adjust_speed();
	// setup big door state
	thread warehouse_collision_hacks_toggle();
		
	maps\flood_util::setup_default_weapons();
//	level.player GiveWeapon( "flood_hands" );
//	level.player SwitchToWeapon( "flood_hands" );
//	level.player DisableWeaponSwitch();
//	level.player DisableOffhandWeapons();
}

flooding_int()
{
	// CF - Removing specific lines but leaving for reference
	// another autosave hitch removal for GL
	// temp for greenlight
	//if( level.start_point != "dam" )
	level thread autosave_now();
	
//	thread hide_hole1_pieces();
	// start the check for the forced mantle
//	thread loadingdocks_no_jump();
	// start checking for when it's safe to close the warehouse doors
	thread close_warehouse_doors();
	// setup script to trigger the door burst moment
	thread trigger_warehouse_door_burst();
	// start checked for when the player is mantling
	thread check_player_warehouse_mantle();
	// teleport keegan if he's too far behind when you mantle the loading docks
	thread teleport_ally2();
	// start bokehdot checker
	thread maps\flood_util::setup_bokehdot_volume( "flooding_bokehdot" );
	// spawn the rooftop door and first frame it
	thread maps\flood_mall::mall_roof_door_firstframe();
	// start the double doors animating
	thread warehouse_double_doors();
	// roof spanish vo
	thread enemy_spanish_vo();
	// start checking for when to ignore the water setting your speed and lock it so you move slowly in the stiarwell
	thread player_set_stairwell_speed();
	// turn on the alley kill triggers
	thread alley_kill_triggers( "on" );
	thread exit_water_tired();

	//thread maps\flood_fx::fx_lens_splash_02();
	thread maps\flood_fx::fx_warehouse_amb_fx();
    thread maps\flood_fx::fx_retarget_warehouse_waters_lighting();
		
// DK: Commented because it was causing errors. Did you mean for this to be called twice?
//	thread maps\flood_mall::enemy_setup_vign();
	
	//set_audio_zone( "flood_flooding_int", 2 );	
	
	// Audio: Start warehouse water
	thread maps\flood_audio::sfx_warehouse_water();
		
	flag_wait( "mall_breach_start" );
}

hide_hole1_pieces()
{
	trigger = GetEnt( "mall_roof_hole1_trig", "targetname" );
	trigger trigger_off();
}

ally_main_walk()
{
	self disable_heat_behavior();
	self cqb_walk( "on" );
}

ally0_main_int()
{
	self endon( "death" );
	
	ent_flag_init( "stop_alley_wakes" );
	ent_flag_set( "stop_alley_wakes" );
	
	// run to inside of warehouse
	next_node = getstruct( "ally0_flee_int_start", "targetname" );
	next_node maps\_anim::anim_reach_solo( self, "flood_warehouse_mantle" );
	self thread maps\flood_fx::character_make_wet( 1, false );
	self thread maps\flood_fx::fx_warehouse_ally_mantle(0.3, 0.3);
	next_node maps\_anim::anim_single_run_solo( self, "flood_warehouse_mantle" );
	
	// start checking to make wet
	self thread trigger_splash_wet( "warehouse_wet01", 50 );
	self thread trigger_splash_wet( "warehouse_wet02", 40 );

	//Vargas: We're not safe here! We've got to make it to higher ground.
	self thread dialogue_queue( "flood_bkr_notsafehere" );
	//Vargas: Don't stop running, Elias!
	level.allies[ 1 ] delayThread( 4, ::dialogue_queue, "flood_diz_dontstoprunning" );
	//Merrick: Keep moving!
	level.allies[ 2 ] delayThread( 10, ::dialogue_queue, "flood_kgn_keepmoving2" );
	
	// Audio: Big Metal stress after this line
	thread maps\flood_audio::sfx_big_metal_stress();
	
	// start checking when to say the up the stairs line
	self thread trigger_warehouse_hallway_vo();

	// run to a node at the bottom of the stairs then turn off water stuff to better transition into the stair vignette
//	next_node = getstruct( next_node.target, "targetname" );
//	next_node = block_until_at_struct( next_node, 64 );
	// turn off the archetype stuff for underwater
//	self notify( "breach_start" );
	
	// go to top of the stairs node
//	next_node = block_until_at_struct( next_node, 8 );
	next_node = getstruct( "warehouse_stairs", "targetname" );
	next_node maps\_anim::anim_reach_solo( self, "warehouse_stairs_start" );
	self thread maps\flood_fx::character_make_wet( 20, false );
//	delayThread( 0.1, maps\_anim::anim_set_rate_single, self, "warehouse_stairs_start", 1.2 );
	next_node maps\_anim::anim_single_solo( self, "warehouse_stairs_start" );
	flag_set( "ally0_stair_ready" );

	next_node thread maps\_anim::anim_loop_solo( self, "warehouse_stairs_loop", "stop_loop" );
	
//	self thread ally_main_walk();
	flag_wait_all( "player_at_stairs", "ally1_stair_ready" );
	next_node notify( "stop_loop" );
	
//	level waittill( "stairs_end_done" );
//	IPrintLn( "ally 0 moving: " + GetTime() );
//	delayThread( 0.1, maps\_anim::anim_set_rate_single, self, "warehouse_stairs_end", 1.1 );

	delayThread( 2, ::flooding_stairs_vo );
	next_node maps\_anim::anim_single_solo( self, "warehouse_stairs_end" );
//	IPrintLn( "ally 0 stop moving: " + GetTime() );
	
	level.player EnableWeaponSwitch();
	level.player EnableOffhandWeapons();

	// Audio: Water emitter cleanup
	thread maps\flood_audio::sfx_stop_warehouse_water();

	self maps\flood_mall::ally0_mall();
}

flooding_stairs_vo( guy )
{
	level.player endon( "death" );
	level.allies[ 0 ] endon( "death" );
	level.allies[ 1 ] endon( "death" );
	level.allies[ 2 ] endon( "death" );
	
	//flag to switch drips back to pooling ones
	flag_set( "moving_to_mall" );
	
	//Vargas: Commentary, Lieutenant.
	level.allies[ 0 ] dialogue_queue( "flood_vrg_commentarylieutenant" );
	wait .77 * 0.33;
	//Merrick: I think it's bad, sir.
	level.allies[ 1 ] dialogue_queue( "flood_mrk_ithinkitsbad" );
	wait .82 * 0.33;
	//Vargas: Run of the mill bad or holy-shit-I-can't-believe-that-just-happened bad?
	level.allies[ 0 ] dialogue_queue( "flood_vrg_runofthemill" );
	wait .45 * 0.33;
	//Merrick: Holy-shit-I-can't-believe-that-just-happened, sir.
	level.allies[ 1 ] dialogue_queue( "flood_mrk_sir" );
	wait .63 * 0.33;
	//Vargas: That would be 'Sit-Rep confirmed.'
	level.allies[ 0 ] dialogue_queue( "flood_vrg_thatwouldbesitrep" );
	wait .63 * 0.33;
	//Merrick: Sit-rep confirmed, sir.
	level.allies[ 1 ] dialogue_queue( "flood_mrk_sitrepconfirmedsir" );
	wait 1.4 * 0.33;
	//Merrick: What kind of man floods his own city?
	level.allies[ 1 ] dialogue_queue( "flood_mrk_whatkindofman" );
	wait .72 * 0.33;
	//Vargas: A man who won't surrender.
	level.allies[ 0 ] dialogue_queue( "flood_vrg_amanwhowont" );
	wait 2.7 * 0.33;
	//Oldboy: This place isn't gonna hold much longer.
	level.allies[ 2 ] dialogue_queue( "flood_bkr_thisplaceisntgonna" );
	wait .83 * 0.33;
	//Vargas: It's hot out there.
	level.allies[ 0 ] dialogue_queue( "flood_vrg_itshotoutthere" );
	wait .87 * 0.33;
	//Vargas: Any objections to finishing up our mission?
	level.allies[ 0 ] dialogue_queue( "flood_vrg_anyobjectionstofinishing" );
	wait 1.13 * 0.33;
	//Vargas: All right, let's go get this sonofabitch.
	level.allies[ 0 ] dialogue_queue( "flood_vrg_allrightletsgo" );
	
	/*
	//Vargas: Iron Horse, this is Ghost Team. What's your location, over?
	level.allies[ 0 ] dialogue_queue( "flood_bkr_gamma1thisis" );
//	wait 0.15;
	wait 0.5;
	//Vargas: [Laughing under his breath]
//	level.allies[ 1 ] delayThread( 1.1, ::dialogue_queue, "flood_vrg_laughingunderhisbreath" );
	//Vargas: Iron Horse, do you read?
	level.allies[ 0 ] dialogue_queue( "flood_bkr_gamma1doyou" );
	//Price: You think this is funny?
//	level.allies[ 0 ] dialogue_queue( "flood_pri_youthinkthisis" );
	//Vargas: No, I think Garcia outplayed us.
//	level.allies[ 1 ] dialogue_queue( "flood_vrg_noithinkgarcia" );
	//Price: We're not done yet.
//	level.allies[ 0 ] dialogue_queue( "flood_pri_wellwerenotdone" );
	//Vargas: What are you talking about?
	level.allies[ 1 ] dialogue_queue( "flood_vrg_whatareyoutalking" );
	//Price: We're alive, so Garcia is still going to die.
	level.allies[ 0 ] dialogue_queue( "flood_pri_werealivesogarcia" );
	//Vargas: He'd already be dead, if I was in charge.
	level.allies[ 1 ] dialogue_queue( "flood_vrg_hedalreadybedead" );
	//Vargas: Fall in! We're moving!
	level.allies[ 0 ] dialogue_queue( "flood_pri_fallinweare" );

	wait 5;
	
	//Price: This place isn't gonna hold much longer.
	level.allies[ 2 ] dialogue_queue( "flood_bkr_thisplaceisntgonna" );
	*/
}

ally1_main_int()
{
	self endon( "death" );
	
	ent_flag_init( "stop_alley_wakes" );
	ent_flag_set( "stop_alley_wakes" );

	// now that he doesn't push, speed up a bit as he can get behind
	self.moveplaybackrate = 1.1;
	self.movetransitionrate = 1.1;
	self.animplaybackrate = 1.1;

	// run to inside of warehouse
	// the second node is used in the breach vign, so now run to the node it's linked to
	next_node = getstruct( "ally1_flee_int_start", "targetname" );
	self delayThread( 0.1, maps\flood_util::push_player, false );
	next_node maps\_anim::anim_reach_solo( self, "flood_warehouse_mantle" );
	self thread maps\flood_fx::character_make_wet( 1, false );
	self thread maps\flood_fx::fx_warehouse_ally_mantle(0.3, 0.25);
	next_node maps\_anim::anim_single_run_solo( self, "flood_warehouse_mantle" );
	
	self thread trigger_splash_wet( "warehouse_wet01", 50 );
	self thread trigger_splash_wet( "warehouse_wet02", 40 );
	
	// run to a node at the bottom of the stairs then turn off water stuff to better transition into the stair vignette
//	next_node = getstruct( next_node.target, "targetname" );
//	next_node = block_until_at_struct( next_node, 64 );
	// turn off the archetype stuff for underwater
//	self notify( "breach_start" );
	
	// stair node
//	next_node = block_until_at_struct( next_node, 8 );
	next_node = getstruct( "warehouse_stairs", "targetname" );
	self delayThread( 0.1, maps\flood_util::push_player, false );
	next_node maps\_anim::anim_reach_solo( self, "warehouse_stairs_start" );
	self thread maps\flood_fx::character_make_wet( 20, false );
//	delayThread( 0.1, maps\_anim::anim_set_rate_single, self, "warehouse_stairs_start", 1.2 );
	next_node maps\_anim::anim_single_solo( self, "warehouse_stairs_start" );
	flag_set( "ally1_stair_ready" );

	next_node thread maps\_anim::anim_loop_solo( self, "warehouse_stairs_loop", "stop_loop" );

//	nags = [];
//	//Baker: Up the stairs!
//	nags[ 0 ] = "flood_diz_upthestairs";
//	//Baker: Don't stop running, Rook!
//	nags[ 1 ] = "flood_diz_dontstoprunning";
//	self thread maps\flood_util::play_nag( nags, "player_at_stairs_stop_nag", 3, 3, 2 );

//	self thread ally_main_walk();
//	self thread hallway_blocker();

	flag_wait_all( "player_at_stairs", "ally0_stair_ready" );
	next_node notify( "stop_loop" );
	
//	level waittill( "stairs_end_done" );
//	IPrintLn( "ally 1 moving: " + GetTime() );
//	delayThread( 0.1, maps\_anim::anim_set_rate_single, self, "warehouse_stairs_end", 1.1 );
	next_node maps\_anim::anim_single_solo( self, "warehouse_stairs_end" );
//	IPrintLn( "ally 1 stop moving: " + GetTime() );

	// FIX JKU  do we want this???
//	self delayThread( 5, ::dialogue_queue, "flood_diz_hearhostiles" );
	
	self.moveplaybackrate = 1;
	self.movetransitionrate = 1;
	self.animplaybackrate = 1;

	self maps\flood_mall::ally1_mall();
}

ally2_main_int()
{
	self endon( "death" );
	
	ent_flag_init( "stop_alley_wakes" );
	ent_flag_set( "stop_alley_wakes" );

	self.flood_hasmantled = false;
	
	// run to inside of warehouse and stay out of anim reach for as long as possible
	next_node = getstruct( "ally2_flee_int_start", "targetname" );
	self delayThread( 0.1, maps\flood_util::push_player, false );
	next_node maps\_anim::anim_reach_solo( self, "flood_warehouse_mantle" );
	self.flood_hasmantled = true;
	self thread maps\flood_fx::character_make_wet( 1, false );
	self thread maps\flood_fx::fx_warehouse_ally_mantle(0.4, 0.2);
	next_node maps\_anim::anim_single_run_solo( self, "flood_warehouse_mantle" );
	
	self thread trigger_splash_wet( "warehouse_wet01", 50 );
	self thread trigger_splash_wet( "warehouse_wet02", 40 );
	
	// go to the node linked to the first node inside the warehouse
	// stair node
	next_node = getstruct( next_node.target, "targetname" );
	next_node = block_until_at_struct( next_node, 48 );
	
	next_node = getstruct( "warehouse_stairs", "targetname" );
	self delayThread( 0.1, maps\flood_util::push_player, false );
	next_node maps\_anim::anim_reach_solo( self, "warehouse_stairs_start" );
	self thread maps\flood_fx::character_make_wet( 20, false );
//	delayThread( 0.1, maps\_anim::anim_set_rate_single, self, "warehouse_stairs_start", 1.2 );
	next_node maps\_anim::anim_single_solo( self, "warehouse_stairs_start" );
	next_node thread maps\_anim::anim_loop_solo( self, "warehouse_stairs_loop", "stop_loop" );
	
	self thread ally_main_walk();
	flag_wait_all( "player_at_stairs", "ally0_stair_ready", "ally1_stair_ready" );
	next_node notify( "stop_loop" );
	
	// delay keegan up the stairs so he doesn't push you
	wait 1;
//	IPrintLn( "ally 2 moving: " + GetTime() );
//	delayThread( 0.1, maps\_anim::anim_set_rate_single, self, "warehouse_stairs_end", 1.1 );
	next_node maps\_anim::anim_single_run_solo( self, "warehouse_stairs_end" );

	self maps\flood_mall::ally2_mall();
}

trigger_warehouse_hallway_vo()
{
	self endon( "death" );
	
	dist_node = getstruct( "warehouse_hallway_vo", "targetname" );
	
	// sit in this loop and check distance to the node and break out when you get close enough
	while( Distance2D( dist_node.origin, self.origin ) > 100 )
		waitframe();
	
	//Price: Up the stairs!
	self thread dialogue_queue( "flood_bkr_upthestairs" );
}

trigger_splash_wet( wet_node, dist )
{
	self endon( "death" );
	
	dist_node = getstruct( wet_node, "targetname" );
	
	// sit in this loop and check distance to the node and break out when you get close enough
	while( Distance2D( dist_node.origin, self.origin ) > dist )
		waitframe();
	
	self thread maps\flood_fx::character_make_wet( 2, false );
}

hallway_blocker()
{
	level endon( "breach_start" );
	
	blocker = GetEnt( "flooding_hallway_blocker", "targetname" );
	blocker.origin = self.origin;
	blocker LinkTo( self, "tag_origin", ( 0, 0, 48 ), ( 0, 0, 0 ) );
	
	// FIX JKU????  Why am I sitting in this loop?
	// oh wait, I'm sitting in here to keep the blocker oriented perpendicular to the hallway
	while( 1 )
	{
		blocker LinkTo( self, "tag_origin", ( 0, 0, 48 ), ( 0, ( self.angles[ 1 ] * -1 ), 0 ) );
		wait 0.05;
	}
}

breach_warehouse_doors()
{
	left_door_parts = GetEntArray( "warehouse_door_int_l", "targetname" );
	right_door_parts = GetEntArray( "warehouse_door_int_r", "targetname" );
	
	left_door_lock = GetEnt( "warehouse_door_int_l_lock", "targetname" );
	right_door_lock = GetEnt( "warehouse_door_int_r_lock", "targetname" );

	left_door_lock LinkTo( left_door_parts[ 0 ] );
	right_door_lock LinkTo( right_door_parts[ 0 ] );

	foreach( ent in left_door_parts )
	{
		ent RotateYaw( 85, 0.2, 0.1, 0.1 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}
	
	foreach( ent in right_door_parts )
	{
		ent RotateYaw( -85, 0.2, 0.1, 0.1 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}

	// show the faux wall
	ents = GetEntArray( "mall_ware_brush_show", "targetname" );
	foreach( ent in ents )
	{
		ent Hide();
		ent NotSolid();
	}

	flag_set( "warehouse_door_breached" );
}


close_warehouse_doors()
{
	level endon( "swept_away" );
	
	flag_wait( "mall_breach_start" );
	// FIX JKU need to come back to this.  Changed to just close these doors when you enter the mall checkpoint...
	// because otherwise you could run back and get them closed on the wrong side...
//	flag_wait_all( "ally1_breach_ready", "ally2_breach_ready" );

	left_door_parts = GetEntArray( "warehouse_door_int_l", "targetname" );
	right_door_parts = GetEntArray( "warehouse_door_int_r", "targetname" );
	
	foreach( ent in left_door_parts )
	{
		ent RotateYaw( -85, 0.2, 0.1, 0.1 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}
	
	foreach( ent in right_door_parts )
	{
		ent RotateYaw( 85, 0.2, 0.1, 0.1 );
		if( ent.classname == "script_brushmodel" )
			ent ConnectPaths();
	}
}

wait_for_intro_vignette_use()
{
	level.player endon( "mantle_used" );
	
	coupling_org = GetEnt( "train_coupling", "targetname" );
	NotifyOnCommand( "mantle", "+gostand" );
	
	for( ;; )
	{
		if( flag( "trig_intro_vignette" ) && player_looking_at( coupling_org.origin, 0.3 ) && level.player GetStance() == "stand" )
		{
			SetSavedDvar( "hud_forceMantleHint", 1 );
			level.player AllowJump( false );
			level.player thread player_mantle_wait();
			while( flag( "trig_intro_vignette" ) && player_looking_at( coupling_org.origin, 0.3 ) && level.player GetStance() == "stand" )
			{
				if ( level.player GetStance() != "stand" )
					break;
				wait( 0.05 );
			}
		}
		else
		{
			level.player notify( "not_active" );
			SetSavedDvar( "hud_forceMantleHint", 0 );
			level.player AllowJump( true );
		}
			
		wait( 0.05 );
	}
}

player_mantle_wait()
{
	self endon( "not_active" );
	
	self waittill( "mantle" );
	
	SetSavedDvar( "hud_forceMantleHint", 0 );
	self notify( "mantle_used" );
}

loadingdocks_no_jump()
{
	level endon( "swept_away" );
	level endon( "mall_attack_player" );
	
	while( 1 )
	{
		if( flag( "loadingdocks_no_jump" ) )
			level.player AllowJump( false );
		else
			level.player AllowJump( true );
		waitframe();
	}
}

trigger_warehouse_door_burst()
{
	level endon( "player_on_mall_roof" );
	
	door1 = GetEnt( "warehouse_door_burst1", "targetname" );
	door1.animname = "warehouse_door_burst";
	door1 assign_animtree();
	door2 = GetEnt( "warehouse_door_burst2", "targetname" );
	door2.animname = "warehouse_door_burst";
	door2 assign_animtree();
	door3 = GetEnt( "warehouse_door_burst3", "targetname" );
	door3.animname = "warehouse_door_burst";
	door3 assign_animtree();
	
	door1 thread maps\_anim::anim_loop_solo( door1, "flood_warehouse_doorbuckling_door_loop1" );
	door2 thread maps\_anim::anim_loop_solo( door2, "flood_warehouse_doorbuckling_door_loop1", "stop_loop" );
	door3 thread maps\_anim::anim_loop_solo( door3, "flood_warehouse_doorbuckling_door_loop1", "stop_loop" );
	
	flag_wait( "warehouse_door_burst_alt" );
	
	thread maps\flood_audio::sfx_warehouse_door_burst_01( door2 );
	thread maps\flood_fx::fx_warehouse_door_burst_02();
	
	door2 notify( "stop_loop" );
	door2 maps\_anim::anim_single_solo( door2, "flood_warehouse_doorbuckling_door_alt" );
	door2 thread maps\_anim::anim_loop_solo( door2, "flood_warehouse_doorbuckling_door_loop2_alt" );

	flag_wait( "warehouse_door_burst" );

	thread maps\flood_audio::sfx_warehouse_door_burst_02( door3 );
	
	door3 notify( "stop_loop" );
	thread maps\flood_fx::fx_warehouse_door_burst();
	door3 maps\_anim::anim_single_solo( door3, "flood_warehouse_doorbuckling_door" );
	door3 thread maps\_anim::anim_loop_solo( door3, "flood_warehouse_doorbuckling_door_loop2" );
}

check_player_warehouse_mantle()
{
	level endon( "player_on_mall_roof" );
	
	while( 1 )
	{
		if( flag( "player_warehouse_mantle" ) )
		{
//			IPrintLn( "in mantling area" );
			if( level.player IsMantling() )
			{
//				IPrintLn( "mantling" );
				flag_set( "player_doing_warehouse_mantle" );
			}
			else
			{
				flag_clear( "player_doing_warehouse_mantle" );
			}
		}
		waitframe();
	}
}

teleport_ally2()
{
	level endon( "player_on_mall_roof" );
	
	flag_wait( "player_doing_warehouse_mantle" );
	
	if( !level.allies[ 2 ].flood_hasmantled && ( Distance2D( level.player.origin, level.allies[ 2 ].origin ) > 169 ) )
	{
//		IPrintLn( "tko" );
		ent = getstruct( "ally2_warehouse_snap", "targetname" );
		level.allies[ 2 ] ForceTeleport( ent.origin, ent.angles );
		level.allies[ 2 ] SetGoalPos( ent.origin );
	}
}

angry_flood_collision( guys, collision_radius, freq, delete_flag )
{
	collision_damage = 25;
	
	foreach( guy in guys )
	{
		model_name = level.scr_model[ guy.animname ];
//		IPrintLn( model_name );
		num_parts = GetNumParts( model_name );
		for( i = 0; i < num_parts; i++ )
		{
			part_name = GetPartName( model_name, i );
//			IPrintLn( part_name );
			if( RandomInt( freq ) == 0 )
			{
				thread angry_flood_collision_spawn( guy, part_name, collision_radius, collision_damage, delete_flag );
			}
		}
	}
}

angry_flood_collision_spawn( guy, part_name, collision_radius, collision_damage, delete_flag )
{
//	waterball = Spawn( "script_model", guy GetTagOrigin( part_name ) );
//	waterball SetModel( "trigger_radius_display_128" );
	waterball = Spawn( "trigger_radius", guy GetTagOrigin( part_name ), 0, collision_radius, collision_radius );
	waterball EnableLinkTo();
	waterball LinkTo( guy, part_name );
	
	waterball thread angry_flood_collision_dodamage( collision_damage );
	flag_wait( delete_flag );
	
	waterball Delete();
}

angry_flood_collision_dodamage( collision_damage )
{
	self endon( "death" );
	
	while( 1 )
	{
		self waittill( "trigger" );
		thread maps\flood_fx::fx_bokehdots_close();
		level.player DoDamage( collision_damage, level.player.origin );
		wait 3;
	}
}

angry_flood_collision_cheater( path )
{
	level endon( "enter_loadingdocks" );
	level endon( "stop_crazyness" );
	
	while( 1 )
	{
		
		// this is for the near miss stuff.  this should be the same as the allyside collision but bigger
		delayThread( 0.3, ::angry_flood_collision_cheater_spawn, path, 150, 352, true );
		
		// actual collision checkers
		delayThread( 0.3, ::angry_flood_collision_cheater_spawn, path, 150, 256 );
		delayThread( 0.15, ::angry_flood_collision_cheater_spawn, path, -80, 256 );
		thread angry_flood_collision_cheater_spawn( path, -300, 256 );
		wait 0.55;
	}
}

alley_flood_collision_cheater( path )
{
	level endon( "player_at_stairs" );
	
	while( 1 )
	{
		thread angry_flood_collision_cheater_spawn( path, 0, 192 );
		wait 0.4;
	}
}

angry_flood_collision_cheater_spawn( path, offset, radius, nearmiss )
{
	path_nodes = waterball_get_pathnodes( path );
	start_path_node = 0;
	collision_radius = radius;
	
	waterball = Spawn( "script_model", path_nodes[start_path_node].origin + ( offset, 0, 0 ) );
//	waterball SetModel( "trigger_radius_display_256" );
	waterball_trigger = Spawn( "trigger_radius", path_nodes[start_path_node].origin + ( offset, 0, 0 ),  0, collision_radius, collision_radius );
	waterball_trigger EnableLinkTo();
	waterball_trigger LinkTo( waterball );
	
	if( IsDefined( nearmiss ) && nearmiss )
		waterball_trigger thread maps\flood_fx::fx_angry_flood_nearmiss( false );
	else
		waterball_trigger thread angry_flood_collision_dodamage( 50 );
	
	// move along path
	next_path_node = 1;
	while( IsDefined( path_nodes[next_path_node] ) )
	{
		waterball_time = ( Distance( path_nodes[start_path_node].origin, path_nodes[next_path_node].origin ) / 1000 );
		waterball MoveTo( path_nodes[next_path_node].origin + ( offset, 0, 0 ), waterball_time );
		wait waterball_time;
		start_path_node++;
		next_path_node++;
	}
	
	waterball Delete();
	waterball_trigger Delete();
}

// new alley bokeh logic so they build up as the water comes at you.
alley_bokehdots()
{
	level endon( "enter_loadingdocks" );
	level endon( "player_on_mall_roof" );
	
	// init the bokehdot source
	maps\flood_fx::fx_create_bokehdots_source();
	
	flag_wait( "alley_bokehdots" );
	
	// stop them if they're still on from the angry flood
	StopFXOnTag( GetFX( "bokehdots_close" ), level.flood_source_bokehdots, "tag_origin" );
	waitframe();
	StopFXOnTag( GetFX( "bokehdots_and_waterdrops_heavy" ), level.flood_source_bokehdots, "tag_origin" );
	
	flag_wait( "alley_move_shitfuck" );
	
	while( 1 )
	{
		thread maps\flood_fx::fx_bokehdots_and_waterdrops_heavy( 3 );
		wait 1;
	}
	
	StopFXOnTag( GetFX( "bokehdots_and_waterdrops_heavy" ), level.flood_source_bokehdots, "tag_origin" );
}

alley_bokehdots_old()
{
	level endon( "player_on_mall_roof" );
	
	ent = GetEnt( "alley_bokehdots", "targetname" );

	pos_max = getstruct( ent.target, "targetname" );
	pos_min = getstruct( pos_max.target, "targetname" );
	pos_max = pos_max.origin;
	pos_min = pos_min.origin;
	pos_diff = Distance2D( pos_min, pos_max );

	// init the bokehdot source
	maps\flood_fx::fx_create_bokehdots_source();
	
	// stop them if they're still on from the angry flood
	StopFXOnTag( GetFX( "bokehdots_close" ), level.flood_source_bokehdots, "tag_origin" );
	waitframe();
	StopFXOnTag( GetFX( "bokehdots_and_waterdrops_heavy" ), level.flood_source_bokehdots, "tag_origin" );
	
	while( 1 )
	{
		while( flag( "alley_bokehdots" ) )
		{
			if( flag( "alley_move_shitfuck" ) )
			{
				thread maps\flood_fx::fx_bokehdots_and_waterdrops_heavy();
			}
			else
			{
//				thread maps\flood_fx::fx_bokehdots_far();
			}
			
			// get a percentage of where you are in the volume and wait accordingly
			wait_time = Distance2D( level.player.origin, pos_max ) / pos_diff;
			wait_time = RandomFloatRange( wait_time * 2.85 , wait_time * 3.15 );
//			IPrintLn( wait_time );
			wait wait_time;
		}
		// no need to check this every frame
		// changed my mind, for now...
		waitframe();
	}
}

warehouse_double_doors()
{
	level endon( "player_on_mall_roof" );
	
	door_node = getstruct( "ware_double_doors", "targetname" );
	
	doorl = spawn_anim_model( "warehouse_double_doorl", door_node.origin );
	doorr = spawn_anim_model( "warehouse_double_doorr", door_node.origin );
	
	door_node thread maps\_anim::anim_loop_solo( doorl, "warehouse_double_door" );
	door_node thread maps\_anim::anim_loop_solo( doorr, "warehouse_double_door" );
}

enemy_spanish_vo()
{
	level endon( "swept_away" );
	level endon( "mall_attack_player" );
	
	flag_wait( "mall_spanish_vo" );
	
    pos = GetEnt( "flood_mall_roof_opfor", "targetname" );
    
    // FIX JKU space out the ones that aren't question answer.  one continual conversation.  and loop the ones that make sense if we get there
	// gotta be a better way to do this....
	
	/*
	while( !flag( "event_quaker_big" ) )
	{
		//Venezuelan Soldier 2: We lose anyone to that big wave?
		pos play_sound_on_entity( "flood_vs2_weloseanyoneto" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 4: Everyone's accounted for, sir.
		pos play_sound_on_entity( "flood_vs4_everyonesaccountedforsir" );
		if ( flag( "event_quaker_big" ) ) break;
		
		wait 1;

		//Venezuelan Soldier 3: The report said we will be getting helicopter extraction as soon as they can provide it.
		pos play_sound_on_entity( "flood_vs3_thereportsaidwe" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 3: Since this was a last minute move, it's going to take some time to get enough helicopters in the air.
		pos play_sound_on_entity( "flood_vs3_sincethiswasa" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 2: Start prepping the landing zone.
		pos play_sound_on_entity( "flood_vs2_startpreppingthelanding" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 2: Get the supplies together. Prioritize what's worth salvaging.
		pos play_sound_on_entity( "flood_vs2_getthesuppliestogether" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 2: Keep an eye out for any Americans.  Some of them may have already gotten to high ground before the dam broke.
		pos play_sound_on_entity( "flood_vs2_keepaneyeout" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 3: Make sure you have a full loadout before we leave. We might encounter resistant during the flight out.
		pos play_sound_on_entity( "flood_vs3_makesureyouhave" );
		if ( flag( "event_quaker_big" ) ) break;
		
		wait 2;

		//Venezuelan Soldier 1: Did you hear that?
		pos play_sound_on_entity( "flood_vs1_didyouhearthat" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 4: I can barely hear anything over the water.
		pos play_sound_on_entity( "flood_vs4_icanbarelyhear" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 5: The water jammed up my gun. Can someone toss me a dry weapon?
		pos play_sound_on_entity( "flood_vs5_thewaterjammedup" );
		if ( flag( "event_quaker_big" ) ) break;

		//Venezuelan Soldier 1: I can't believe they actually gave that order.
		pos play_sound_on_entity( "flood_vs1_icantbelievethey" );
	}
	*/
	
	// FIX JKU  hmm, what should I do here.  We've run out of vo lines but the quake hasn't happened, can this even happen?
	flag_wait( "event_quaker_big" );
	wait 6;
	
	// similar to above	
	//Venezuelan Soldier 2: Everyone check your equipment.
	pos play_sound_on_entity( "flood_vs2_everyonecheckyour" );
	//Venezuelan Soldier 2: Jimenez, Ramos, Garcia! Check the south side of the building.  See if it's any more stable.
	pos play_sound_on_entity( "flood_vs2_jimenezramosgarciacheck" );
	//Venezuelan Soldier 1: On it!
	pos play_sound_on_entity( "flood_vs1_onit" );
	
	wait 2;
	
	//Venezuelan Soldier 2: How much longer for that helicopter?
	pos play_sound_on_entity( "flood_vs2_howmuchlongerfor" );
	//Venezuelan Soldier 3: 5 minutes!
	pos play_sound_on_entity( "flood_vs3_5minutes" );
	//Venezuelan Soldier 2: We might not be here in 5 minutes.  We need that helicopter now!
	pos play_sound_on_entity( "flood_vs2_wemightnotbe" );
	//Venezuelan Soldier 2: Make sure they understand our status.
	pos play_sound_on_entity( "flood_vs2_makesuretheyunderstand" );
	
	wait 2;
	
	//Venezuelan Soldier 2: Rodriguez, I need you to keep an eye out for…
	pos play_sound_on_entity( "flood_vs2_rodriguezineedyou" );
	//Venezuelan Soldier 4: I'm a bit busy over here, sir.
	pos play_sound_on_entity( "flood_vs4_imabitbusy" );
	//Venezuelan Soldier 2: Hurry up and pull Pinto out of that hole.  We need to make sure we're ready for extraction.
	pos play_sound_on_entity( "flood_vs2_hurryupandpull" );
	
	wait 2;
	
	//Venezuelan Soldier 2: Sanchez and Castillo! Make sure we still have a secured landing zone for the helicopter!
	pos play_sound_on_entity( "flood_vs2_sanchezandcastillomake" );
	//Venezuelan Soldier 2: I don't want anything keeping us from getting out of here.
	pos play_sound_on_entity( "flood_vs2_idontwantanything" );
	//Venezuelan Soldier 6: Yes, sir!
	pos play_sound_on_entity( "flood_vs6_yessir" );
	
	wait 1;
	
	//Venezuelan Soldier 2: Any update on that helicopter.
	pos play_sound_on_entity( "flood_vs2_anyupdateonthat" );
	//Venezuelan Soldier 3: The operator's are overwhelmed.  I can't get any type of real response.
	pos play_sound_on_entity( "flood_vs3_theoperatorsare" );
	//Venezuelan Soldier 2: Anyone seeing a safe way off of this roof, if we can't get a helicopter?
	pos play_sound_on_entity( "flood_vs2_anyoneseeingasafe" );
	//Venezuelan Soldier 2: How're things looking on the south side?
	pos play_sound_on_entity( "flood_vs2_howrethingslookingon" );
	//Venezuelan Soldier 6: It feels like the roof is starting to shift.
	pos play_sound_on_entity( "flood_vs6_itfeelslikethe" );
	//Venezuelan Soldier 2: Get the supplies together. Prioritize what's worth salvaging.
	pos play_sound_on_entity( "flood_vs2_getthesuppliestogether" );
}

warehouse_collision_hacks_toggle( state )
{
	big_rollup = GetEnt( "warehouse_big_rollup_collision", "targetname" );
	side = GetEnt( "loading_dock_rollup_collision", "targetname" );
	
	if( !IsDefined( state ) )
		state = "default";

	switch( state )
	{
		case "big_rollup":
			big_rollup Show();
			big_rollup Solid();
			break;
		case "side":
			side Show();
			side Solid();
			break;
		default:
			big_rollup Hide();
			big_rollup NotSolid();
			side Hide();
			side NotSolid();
	}
}

player_set_stairwell_speed()
{
	flag_wait( "player_at_stairs" );
	
	flag_set( "cw_player_no_speed_adj" );
	
	JKUprint( "settting stairwell speed" );
	thread maps\flood_util::player_water_movement( 50, 2 );
}

alley_kill_triggers( state )
{
	left = GetEnt( "alley_runback_kill_left", "targetname" );
	loadingdocks = GetEnt( "alley_runback_kill_loadingdocks", "targetname" );
	
	switch( state )
	{
		case "on":
			left trigger_on();
//			loadingdocks trigger_on();
			break;
		case "off":
			left trigger_off();
			loadingdocks trigger_off();
			break;
	}
}

crush_player_with_floating_lynx()
{
	
	kill_trigger = GetEnt( "flooding_crush_player", "targetname" );
	kill_trigger waittill("trigger");
	
	level.player kill();
}

flooding_cleanup()
{
	ents = GetEntArray( "flooding_bokehdot", "targetname" );
	array_delete( ents );

	// FIX JKU need to remove this because for some reason this will cause an error even though the water scripts should've cleaned themselves up by now
//	ents = GetEntArray( "water_loadingdocks_flag", "script_noteworthy" );
//	array_delete( ents );

	ents = GetEntArray( "flooding_cleanup", "script_noteworthy" );
	array_delete( ents );
}

start_coverheight_water_rising( height, instant, layers )
{
	// semi-hack to bypass the complicated water stuff for when I want to move the water instantly when you skip to checkpoint
	if( instant )
	{
		water_layers = GetEntArray( layers, "targetname" );
		water_layers_above = GetEnt( layers + "_above", "targetname" );
		water_layers_under = GetEnt( layers + "_under", "targetname" );
		water_layers = array_add( water_layers, water_layers_above );
		water_layers = array_add( water_layers, water_layers_under );

		foreach ( layer in water_layers )
			layer MoveZ( height, 0.01, 0, 0 );
	}
	else
	{
		//thread maps\flood_fx::fx_retarget_warehouse_waters_lighting();
		thread maps\flood_fx::fx_wh_splashes();
		// water in the alley
		water_layers_alley = GetEntArray( "water_alley", "targetname" );

		// main warehouse water
		warehouse_layers = GetEntArray( "coverwater_warehouse", "targetname" );
		warehouse_layers_above = GetEnt( "coverwater_warehouse_above", "targetname" );
		warehouse_layers_under = GetEnt( "coverwater_warehouse_under", "targetname" );
		//wh_splashes_lower = GetEnt( "wh_splashes_lower", "targetname" );
		wh_splashes_upper = GetEnt( "wh_splashes_upper", "targetname" );
                warehouse_layers_debris = GetEnt( "coverwater_warehouse_debris", "targetname" );


		warehouse_layers = array_add( warehouse_layers, warehouse_layers_above );
		warehouse_layers = array_add( warehouse_layers, warehouse_layers_under );
		//warehouse_layers = array_add( warehouse_layers, wh_splashes_lower );
		warehouse_layers = array_add( warehouse_layers, wh_splashes_upper );
                warehouse_layers = array_add( warehouse_layers, warehouse_layers_debris );

		// loading docks water thats there before you mantle
		warehouse_premantle_layers = GetEntArray( "coverwater_warehouse_premantle", "targetname" );
		warehouse_premantle_layers_above = GetEnt( "coverwater_warehouse_premantle_above", "targetname" );
		warehouse_premantle_layers_under = GetEnt( "coverwater_warehouse_premantle_under", "targetname" );
		wh_splashes_lower = GetEnt( "wh_splashes_lower", "targetname" );
                warehouse_premantle_layers_debris = GetEnt( "coverwater_warehouse_premantle_debris_T", "targetname" );
		warehouse_premantle_layers = array_add( warehouse_premantle_layers, warehouse_premantle_layers_above );
		warehouse_premantle_layers = array_add( warehouse_premantle_layers, warehouse_premantle_layers_under );
		warehouse_premantle_layers = array_add( warehouse_premantle_layers, wh_splashes_lower );
                warehouse_premantle_layers = array_add( warehouse_premantle_layers, warehouse_premantle_layers_debris );

		
                // loading docks water thats there after you mantle
		warehouse_postmantle_layers = GetEntArray( "coverwater_warehouse_postmantle", "targetname" );
		warehouse_postmantle_layers_above = GetEnt( "coverwater_warehouse_postmantle_above", "targetname" );
		warehouse_postmantle_layers_under = GetEnt( "coverwater_warehouse_postmantle_under", "targetname" );
		warehouse_postmantle_layers = array_add( warehouse_postmantle_layers, warehouse_postmantle_layers_above );
		warehouse_postmantle_layers = array_add( warehouse_postmantle_layers, warehouse_postmantle_layers_under );

		// combine all the layers as we'll be able to move them all later on after the mantle...
		all_warehouse_layers = array_combine( warehouse_layers, warehouse_premantle_layers );
		all_warehouse_layers = array_combine( all_warehouse_layers, warehouse_postmantle_layers );
		

	    // hide the post mantle stuff
		foreach( brush in warehouse_postmantle_layers )
	    {
	    	brush Hide();
	    	brush NotSolid();
	    }
	    
		// swap the water planes when you mantle.
		thread start_coverheight_water_swap( warehouse_premantle_layers, warehouse_postmantle_layers );

		// FIX JKU not sure I like this, but wait until you're inside the warehouse to start moving the water
		trigger = GetEnt( "inside_loadingdocks", "targetname" );
		trigger waittill( "trigger" );

		// loading docks premangle move
		JKUprint( "wr: ld" );
		rise_time = 4;
		foreach ( layer in warehouse_premantle_layers )
			layer MoveZ( 45, rise_time, 0, 4 );
//		foreach ( layer in water_layers_upper )
//			layer MoveZ( 5, 9, 0, 0 );
		wait rise_time;
		
		flag_wait_or_timeout( "start_warehouse_water", 2 );
		
		// turn off the water cascading down.  preferrably right when the water level reaches its height
		delayThread( 0.9, ::coverheight_water_rising_lip );

		// warehouse
		JKUprint( "wr: ware" );
		rise_time = 5;
		foreach ( layer in all_warehouse_layers )
			layer MoveZ( 53, rise_time, 2, 2 );
		wait rise_time;
	
		flag_wait_or_timeout( "start_stairs_water", 7 );
		
		// hack to turn on some collision for the side roll up doors in the loading docks
		thread maps\flood_flooding::warehouse_collision_hacks_toggle( "side" );

		// rise the water a little faster/smoother if you're moving forwards and trigger the flag
		if( flag( "start_stairs_water" ) )
		{
			// stairs
			JKUprint( "wr: stairs no close" );
			rise_time = 5;
			foreach ( layer in all_warehouse_layers )
				layer MoveZ( 40, rise_time, 2, 2 );
			wait rise_time;
		}
		else
		{
			JKUprint( "wr: ware close" );
			rise_time = 2;
			foreach ( layer in all_warehouse_layers )
				layer MoveZ( 10, rise_time, 1, 1 );
			wait rise_time;
			
			// stairs
			JKUprint( "wr: stairs" );
			rise_time = 3;
			foreach ( layer in all_warehouse_layers )
				layer MoveZ( 30, rise_time, 1, 2 );
			wait rise_time;
		}
	
		flag_wait_or_timeout( "player_at_stairs", 3 );
		
		// hack to turn on some collision for the big roll up door
		thread maps\flood_flooding::warehouse_collision_hacks_toggle( "big_rollup" );

		if( flag( "player_at_stairs" ) )
		{
			JKUprint( "wr: final no close" );
			rise_time = 12;
			foreach ( layer in all_warehouse_layers )
				layer MoveZ( 35, rise_time, 6, 6 );		}
		else
		{
			JKUprint( "wr: stairs close" );
			rise_time = 3;
			foreach ( layer in all_warehouse_layers )
				layer MoveZ( 10, rise_time, 1, 1 );
			wait rise_time;
	
			JKUprint( "wr: final" );
			rise_time = 8;
			foreach ( layer in all_warehouse_layers )
				layer MoveZ( 25, rise_time, 4, 4 );
		}
	}
}

start_coverheight_water_swap( warehouse_premantle_layers, warehouse_postmantle_layers )
{
	flag_wait( "player_doing_warehouse_mantle" );
	
	// need to wait a bit as the water may snap up because it starts at the upper level height
	wait 0.2;
	
	//kill lip effects in premantle area
	thread maps\flood_fx::destroy_lip_debris_fx();
	
    // swap the water layers
	foreach( brush in warehouse_postmantle_layers )
    {
    	brush Show();
    	brush Solid();
    }

    foreach( brush in warehouse_premantle_layers )
    {
    	brush Hide();
    	brush NotSolid();
	}
}

coverheight_water_rising_lip()
{
	brush = GetEnt( "warehouse_water_lip_02", "targetname" );
	brush Hide();
	brush NotSolid();
}

#using_animtree("generic_human");
ai_water_rising_think( endon_event )
{
	self endon( "death" );
	level endon( endon_event );
	
	//init some vars  out, under, hip
	self.flooding_last_water_state = "out";
	
	level ai_flooding_hip_anims();
	level ai_flooding_under_anims();
	
	while( 1 )
	{
		trace = BulletTrace( self.origin, self GetEye(), false, self );
		
		if ( trace[ "surfacetype" ] == "water" )
		{
			height_underwater = trace[ "position" ][ 2 ] - self.origin[ 2 ];

			if( height_underwater > 40 )
			{
				if( self.flooding_last_water_state != "under" )
				{
					self.flooding_last_water_state = "under";
					self.standRunTransTime = 0.8;
					self set_archetype( "under_water" );
				}
			}
			else if( height_underwater > 20 )
			{
				// leave a window underneath the under height so they're not changing when it's not necessary
				if( self.flooding_last_water_state != "hip" && ( height_underwater < 36 || self.flooding_last_water_state == "out" ) )
				{
					self.flooding_last_water_state = "hip";
					self.standRunTransTime = 0.8;
					self set_archetype( "hip_water" );
				}
			}
			else
			{
				if( self.flooding_last_water_state != "out" )
				{
					self.flooding_last_water_state = "out";
					self.standRunTransTime = undefined;
					self clear_archetype();
					self thread maps\flood_fx::character_make_wet();
				}
			}
		}
		waitframe();
	}	
}

ai_flooding_hip_anims()
{
	// only register these once
	if ( !isDefined( anim.archetypes ) || !isDefined( anim.archetypes[ "hip_water" ] ) )
	{
		archetype = [];
		mains = [];
		
		mains[ "straight"	 ] = %flood_ally_water_walking_mid_70;
		mains[ "straight_v2" ] = %flood_ally_water_walking_mid_70;
		mains[ "move_f"		 ] = %flood_ally_water_walking_mid_70;		
		
		archetype[ "run"  ] = mains;
		archetype[ "walk" ] = mains;
		
		register_archetype( "hip_water", archetype );
	}
}

ai_flooding_under_anims()
{
	// only register these once
	if ( !isDefined( anim.archetypes ) || !isDefined( anim.archetypes[ "under_water" ] ) )
	{
		archetype = [];
		mains = [];
		
		mains[ "straight"	 ] = %flood_ally_water_walking_high;
		mains[ "straight_v2" ] = %flood_ally_water_walking_high;
		mains[ "move_f"		 ] = %flood_ally_water_walking_high;		
		
		archetype[ "run"  ] = mains;
		archetype[ "walk" ] = mains;
		
		register_archetype( "under_water", archetype );
	}
}

exit_water_tired()
{
	level endon( "exit_water_stop_tired" );
	
	// FIX JKU need to come back to this and make sure it's not needed.  This was sre but only when I had it hacked to work in the mall checkpoint
//	level.player vision_set_changes( "flood", 0 );
	
	// FIX JKU this really should be checking if you're underwater, not just in the volume
	// but to do that correctly water func needs to be added to turn off the speed adjustments so they don't clash
	flag_waitopen( "cw_player_underwater" );
	flag_wait( "player_at_stairs" );

	//Price: Everyone catch your breath.
	level.allies[ 0 ] thread dialogue_queue( "flood_bkr_catchyourbreath" );
	
	tired_length = 15;
	start_time = GetTime();
	level.tired_time_remaining = tired_length - ( ( GetTime() - start_time ) / 1000 );
	level.player thread enable_tired( 75, level.tired_time_remaining );
	thread exit_water_tired_timer( start_time, tired_length );	
	JKUprint( "tired" );
	
	while( 1 )
	{
		flag_wait( "cw_player_underwater" );
		level.player thread disable_tired( true, 0 );
		JKUprint( "disabled" );

		flag_waitopen( "cw_player_underwater" );
		level.tired_time_remaining = tired_length - ( ( GetTime() - start_time ) / 1000 );
		level.player thread enable_tired( 75, level.tired_time_remaining );
		JKUprint( "enabled "  + level.tired_time_remaining );
	}
}

exit_water_tired_timer( start_time, tired_length )
{
	level.tired_time_remaining = tired_length - ( ( GetTime() - start_time ) / 1000 );
	while( level.tired_time_remaining > 0 )
	{
		level.tired_time_remaining = tired_length - ( ( GetTime() - start_time ) / 1000 );
		waitframe();
	}
	
	JKUprint( "done" );
	level notify( "exit_water_stop_tired" );
}

TIRED_STUMBLE_TIME_MIN = 0.15; // .15
TIRED_STUMBLE_TIME_MAX = 0.45; // .45

TIRED_RECOVER_TIME_MIN = 0.65; 
TIRED_RECOVER_TIME_MAX = 1.25;

enable_tired( lspeed, fadelimp )
{
	init_default_tired();
	
	self.limp_strength = 1.0;
	self.ground_ref_ent = spawn( "script_model", ( 0, 0, 0 ) );
	self playerSetGroundReferenceEnt( self.ground_ref_ent );
	
	self player_speed_percent( lspeed, .05 );	
	self.player_speed = lspeed;
	
	self thread tired();
	thread fade_tired( fadelimp );
	
	self player_speed_percent( 100, fadelimp );
	self.player_speed = 100;
}

init_default_tired()
{
	level.player_tired					   = [];
	level.player_tired[ "pitch" ][ "min" ] = -3;
	level.player_tired[ "pitch" ][ "max" ] = 4;
	level.player_tired[ "yaw"	][ "min" ] = -8;
	level.player_tired[ "yaw"	][ "max" ] = 5;
	level.player_tired[ "roll"	][ "min" ] = 3;
	level.player_tired[ "roll"	][ "max" ] = 5;
}

disable_tired( forgood, fadetime )
{
	
	self notify( "stop_limp" );
	self notify( "stop_random_blur" );
	//self StopShellShock();
	self FadeOutShellShock();
	
	self thread vision_set_changes( level.cw_vision_above, 0.25 );
	
	if( !isdefined( fadetime ) )
		fadetime = 0;
	
	if( isdefined( forgood ) )
	{
		self playerSetGroundReferenceEnt( undefined );
		setSavedDvar( "player_sprintUnlimited", "0" );
		
		self notify( "stop_limp_forgood" );
	}
	else
	{
		recover_time = randomfloatrange( TIRED_RECOVER_TIME_MIN, TIRED_RECOVER_TIME_MAX );
		base_angles = adjust_angles_to_player( ( 0,0,0 ) );
		self.ground_ref_ent rotateto( base_angles, recover_time, 0, recover_time / 2 );
		self.ground_ref_ent waittill( "rotatedone" );
	}
	
//	level.player vision_set_fog_changes( level.originalVisionSet, 0 );
	level.player player_speed_percent( 100 );
	setblur( 0, randomfloatrange( .5, .75 ) );
	self allowstand( true );
	self allowcrouch( true );
	self allowsprint( true );
	self allowjump( true );
	
	//kill debris effects in warehouse area
	delayThread ( 8, maps\flood_fx::destroy_fx_warehouse_floating_debris);
	//thread maps\flood_fx::destroy_fx_warehouse_floating_debris();	
	//kill effects in premantle area
	//thread maps\flood_fx::destroy_fx_warehouse_floating_debris( "coverwater_warehouse_premantle_debris" );
}

fade_tired( time )
{
	self endon( "stop_limp" );
	wait( time );
	self thread disable_tired();	
}

tired( override )
{
	self endon( "stop_limp" );
	
	self ShellShock( "player_limp", 9999 ); // shellshock doesnt allow sprint :(
	
	self allowsprint( false );
	self allowjump( false );
	self thread player_random_blur();
	self thread player_hurt_sounds();
	
//	level waittill( "blah blah blah" );
	
	while ( true )
	{
		
		if( self PlayerAds() > .3 )
		{
			wait(.05);
			continue;				
		}
		
		stance = level.player GetStance();
		if( stance == "crouch" || stance == "prone" )
		{
			wait(.05);
			continue;	
		}
		
		velocity = self getvelocity(); // get player's speed
		player_speed = abs( velocity [ 0 ] ) + abs( velocity[ 1 ] );
	
		if ( player_speed < 10 )
		{
			wait 0.05;
			continue;
		}

		speed_multiplier = player_speed / self.player_speed;

		p = randomfloatrange( level.player_tired[ "pitch" ][ "min" ], level.player_tired[ "pitch" ][ "max" ] );
		if ( randomint( 100 ) < 20 )
			p *= 1.5;
		r = RandomFloatRange( level.player_tired[ "roll" ][ "min" ], level.player_tired[ "roll" ][ "max" ] );
		y = RandomFloatRange( level.player_tired[ "yaw" ][ "min" ], level.player_tired[ "yaw" ][ "max" ] );

		stumble_angles = ( p, y, r );
		stumble_angles = stumble_angles * speed_multiplier;
		stumble_angles = stumble_angles * self.limp_strength;
		
		stumble_time = randomfloatrange( TIRED_STUMBLE_TIME_MIN, TIRED_STUMBLE_TIME_MAX );
		recover_time = randomfloatrange( TIRED_RECOVER_TIME_MIN, TIRED_RECOVER_TIME_MAX );

		self thread vision_set_changes( "aftermath_pain", 3 );
		self thread stumble( stumble_angles, stumble_time, recover_time );
		wait stumble_time;
		self thread vision_set_changes( level.cw_vision_above, recover_time );
		self waittill( "recovered" );

	}
}

stumble( stumble_angles, stumble_time, recover_time, no_notify )
{
	self endon( "stop_stumble" );
	self endon( "stop_limp" );

	stumble_angles = adjust_angles_to_player( stumble_angles );

	self notify( "stumble" );
	self.ground_ref_ent rotateto( stumble_angles, stumble_time, ( stumble_time / 4 * 3 ), ( stumble_time / 4 ) );
//	self.ground_ref_ent rotateto( stumble_angles, stumble_time, ( stumble_time / 4 * 3 ), ( stumble_time / 4 ) );
	self.ground_ref_ent waittill( "rotatedone" );

//	if ( level.player getstance() == "stand" )
//		level.player PlayRumbleOnEntity( "damage_light" );

	base_angles = ( randomfloat( 4 ) - 4, randomfloat( 5 ), 0 );
	base_angles = adjust_angles_to_player( base_angles );

	self.ground_ref_ent rotateto( base_angles, recover_time, 0, recover_time / 2 );
	self.ground_ref_ent waittill( "rotatedone" );

 	if ( !isdefined( no_notify ) )
		self notify( "recovered" );
}

player_random_blur()
{
	self endon( "dying" );
	self endon( "stop_random_blur" );

	while ( true )
	{
		wait 0.05;
		if ( randomint( 100 ) > 10 )
			continue;

		blur = randomint( 3 ) + 4;
		blur_time = randomfloatrange( 0.1, 0.3 );
		recovery_time = randomfloatrange( 0.3, 1 );
		setblur( blur * 1.2, blur_time );
		wait blur_time;
		setblur( 0, recovery_time );
		wait( recovery_time );
		wait( RandomFloatRange( 0, 1.5 ) );
		self waittill_notify_or_timeout( "blur", 5 );

	}
}

player_hurt_sounds()
{
	self endon( "stop_limp" );
	
	//level.player thread player_heartbeat();
	while( 1 )
	{
		// dont want to play over player hurt sounds when player actually gets hurt
		if( player_playing_hurt_sounds()  )
		{
			wait(.05);
			continue;
		}
		
		self notify( "blur" );
		self play_sound_in_space( "breathing_limp_start" );
		self play_sound_in_space( "breathing_limp_better" );
		wait( RandomFloatRange( 0, 1 ) );
//		NewValue = ( ( ( OldValue - OldMin ) * ( NewMax - NewMin ) ) / ( OldMax - OldMin ) ) + NewMin
		value = ( ( ( level.tired_time_remaining - 0 ) * ( 1 - 6 ) ) / ( 15 - 0 ) ) + 6;
//		IPrintLn( value );
		self waittill_notify_or_timeout( "stumble", value );
//		self waittill_notify_or_timeout( "stumble", RandomFloatRange( value, ( value * 1.5 ) ) );
	}
}

player_playing_hurt_sounds()
{
	if( level.player.health < 50 )
		return true;	
	else
		return false;		
}

adjust_angles_to_player( stumble_angles )
{
	pa = stumble_angles[ 0 ];
	ra = stumble_angles[ 2 ];

	rv = anglestoright( self.angles );
	fv = anglestoforward( self.angles );

	rva = ( rv[ 0 ], 0, rv[ 1 ] * - 1 );
	fva = ( fv[ 0 ], 0, fv[ 1 ] * - 1 );
	angles = rva * pa;
	angles = angles + ( fva * ra );
	return angles + ( 0, stumble_angles[ 1 ], 0 );
}

