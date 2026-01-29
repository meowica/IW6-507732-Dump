#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\_weather;
#include maps\carrier_code;

deck_tilt_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//flag inits
	flag_init( "deck_tilt_finished" );
	flag_init( "show_ocean_water" );
	flag_init( "hide_ocean_water" );	
	flag_init( "damage_slide" );

	flag_init( "stop_dmg_check" );
	
	flag_init( "tilt_part_1" );
	flag_init( "tilt_part_2" );
	flag_init( "tilt_part_15" );
	flag_init( "tilt_part_23" );
	flag_init( "tilt_part_30" );
	flag_init( "tilt_part_35" );
	flag_init( "tilt_part_50" );
	
	//precache
	
	//init arrays/vars
	
	//hide ents
	level.rog_carrier_clouds = getent( "rog_carrier_clouds", "targetname" );
	level.rog_carrier_clouds hide_entity();	
	
	level.deck_destroyed_odin = GetEntArray( "deck_destroyed_odin", "targetname" );
	array_thread( level.deck_destroyed_odin, ::hide_entity );
	
	deck_triggers = GetEntArray( "deck_tilt_triggers", "targetname" );
	array_thread( deck_triggers, ::hide_entity );
	
	water_sheet = getEnt( "water_sheet_volume", "targetname" );
	water_sheet hide_entity();
	
	thread player_slide_manager();

	// --Large props
	thread tilt_props_aircraft();
	thread tilt_props_large();
	thread tilt_props_medium();
	
	// --Medium props
	//thread handle_medium_objects(); //items hooked to generic prop raven
	//thread handle_rolling_objects(); //special rolling barrels
	
	// --Small props	
}

setup_deck_tilt()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "deck_tilt";
	setup_common();
	spawn_allies();
	set_sun_post_heli_ride();
	
	ladder_blocker = getEnt( "ladder_blocker", "targetname" );
	ladder_blocker Delete();
	
	jet2 = GetEnt( "jet_launcher2", "targetname" );
	jet3 = GetEnt( "jet_launcher3", "targetname" );
	
	jet2 Delete();
	jet3 Delete();
	
	thread maps\carrier_deck_combat::fork1_move();
	
	flag_set( "slow_intro_finished" );
}

begin_deck_tilt()
{
	//--use this to run your functions for an area or event.--
	level notify( "pre_odin_strike" );
	
	node = getNode( "hesh_deck_tilt_start", "targetname" );
	level.hesh SetGoalNode( node );
	
	deck_triggers = GetEntArray( "deck_tilt_triggers", "targetname" );
	array_thread( deck_triggers, ::show_entity );
	
	flag_wait( "start_main_odin_strike" );
	
	lookat = getstruct( "looking_at_deck", "targetname" );
	if ( !level.player WorldPointInReticle_Circle( lookat.origin, 65, 400 ))
	{
	    wait( 1 );
	}
	
	thread tilt_handler();
	thread tilt_handle_vista();
	thread tilt_allies();
	
	// --Environment, water, vista, shakes, etc.
	thread tilt_environment(); //put all earthquake rumble and shellshocks here
		
	flag_wait( "deck_tilt_finished" );	
	thread autosave_tactical();
}

tilt_handle_vista()
{
	wait( 7.2 );
	
	SetPhysicsGravityDir( ( 0.25, 0.0, -1.0 ) );
	thread gravity_shift(); //This increments gravity dir over time.
	thread player_gravity_slide(); //This increments the push vector on the player over time.
	
	thread vista_tilt(); //This handles the actual tilt.
	
	flag_wait_or_timeout( "player_slide_fall", 30 );
	
	flag_set( "obj_exfil_complete" ); //OBJECTIVE FAILED
	
	thread player_slide_fall();
	wait( 5 );
	set_black_fade( 1.0, 0.5 );
	wait( .5 );
	flag_set( "deck_tilt_finished" );
}

tilt_handler()
{
	SetSavedDvar( "ragdoll_max_life", 3600000 );
	
	// --ODIN HITS TOWER THEN DECK--
	thread tilt_odin_strike();
	wait( 2.5 );
	
	hole_badplace = GetEnt( "deck_node_blocker", "targetname" );
	BadPlace_Brush( "deck_node_blocker", -1, hole_badplace, "allies", "axis" );

	antenna_badplace = GetEnt( "antenna_badplace", "targetname" );
	BadPlace_Brush( "antenna_badplace", -1, antenna_badplace, "allies", "axis" );
	
	// --START THE RUN--
	flag_set( "tilt_part_1" );
	thread tilt_props_island_antenna();
	
	wait( 1.0 );
	//IPrintLnBold( "GET TO THE CHOPPER!" );
	level.osprey = spawn_vehicle_from_targetname_and_drive( "deck_tilt_heli" );
		
	flag_set( "tilt_part_2" );
			
	// --SECONDARY DECK EXPLOSION--
	wait( 2.25 );
	flag_set( "tilt_part_15" );
	thread tilt_vo();

	wait( 4.0 );
	// --DEBRIS
	flag_set( "tilt_part_23" );
	
	wait( 6.5 );
	// --HELICOPTER EXPLOSION--	
	flag_set( "tilt_part_30" );
	thread maps\carrier_audio::tilt_helicopter_destroyed( level.exploding_heli );
	
	wait( 4.5 );
	// --PLANES
	flag_set( "tilt_part_35" );
	
	wait( 7.0 );
	// --FINAL DEBRIS--
	flag_set( "tilt_part_50" );
}

tilt_allies()
{
	hesh_node_a = getNode( "hesh_deck_a", "targetname" );
	level.hesh SetGoalNode( hesh_node_a );
	
	flag_wait( "hesh_tilt_deck_move_to_end" );
	
	deck_tilt_hesh_goal = getstruct( "deck_tilt_hesh_goal", "targetname" );
	level.hesh setgoalpos( deck_tilt_hesh_goal.origin );
}

tilt_vo()
{
	//Merrick: Hesh!  Adam!  Head for that incoming Osprey, I’ll meet you there!
	smart_radio_dialogue( "carrier_mrk_heshadamheadfor" );
	thread maps\carrier::obj_exfil();
	
	flag_wait( "tilt_part_30" );
	
	//Hesh: Get to the Osprey!
	level.hesh smart_dialogue( "carrier_hsh_gettotheosprey" );
}

tilt_odin_strike()
{
	//target = getstruct( "rog_target_carrier", "targetname" );
	thread rod_of_god_carrier();
			
	wait( 2.5 );
	exploder( 10 ); //giant wave
	exploder( 6 ); //deck fires
	//Earthquake( 0.7, 1.5, target.origin, 10000 );
	thread maps\carrier_audio::tilt_odin_impact();
	
	wait( .5 );
	deck_intact_odin = GetEnt( "deck_intact_odin", "targetname" );
	deck_intact_odin Hide();
	deck_intact_odin NotSolid();
	
	thread tilt_props_odin_phys();
	
	deck_objects = getEntArray( "odin_crates", "targetname" );
	array_delete( deck_objects );

	array_thread( level.deck_destroyed_odin, ::show_entity );
	
	wait( 0.5 );
	//background ROGs
	target = getstruct( "rog_target_3", "targetname" );	
	delaythread( 0, ::rod_of_god, target.origin );
	target = getstruct( "rog_target_4", "targetname" );	
	delaythread( 2, ::rod_of_god, target.origin );
	target = getstruct( "rog_target_5", "targetname" );	
	delaythread( 1, ::rod_of_god, target.origin );
	
	wait( 1.0 );
	
	thread maps\_weather::rainMedium ( 1 );
	
	exploder( 3 ); //surface water sheets & large waves
	exploder( 4 ); //small splashes
	exploder( 5 ); //surface foam
	water_sheet = getEnt( "water_sheet_volume", "targetname" );
	water_sheet show_entity();
	
	wait( 12 );

	thread maps\_weather::rainNone ( 5 );
}

tilt_environment()
{
	//DECK EXPLOSION
	flag_wait( "tilt_part_1" );
	earthquake( .30, 2.0, level.player.origin, 20000 );
	//level.player PlayRumbleOnEntity( "carrier_explosion" );
	//level.player ShellShock( "hijack_engine_explosion", 3 );
	
	//HELICOPTER EXPLODES
	flag_wait( "tilt_part_30" );
	wait( .75 );
	earthquake( .25, 2.0, level.player.origin, 20000 );
	//level.player PlayRumbleOnEntity( "heavy_1s" );
	wait( 2.0 );
	earthquake( .08, 1.85, level.player.origin, 20000 );	
	wait( .75 );
	earthquake( .25, 2.0, level.player.origin, 20000 ); //11.6 fuselage hits
	//thread maps\proto_carrier_aud::deck_rumble();
	//thread maps\proto_carrier_aud::fuselage_hits();
	//level.player PlayRumbleOnEntity( "heavy_2s" );
	wait( 2.0 );
	earthquake( .08, 60.0, level.player.origin, 20000 );	
	//thread maps\proto_carrier_aud::deck_rumble();
	//thread maps\proto_carrier_aud::deck_stress();
}

tilt_props_island_antenna()
{
	antenna = getEnt( "island_antenna", "targetname" );
	
	path1 = getstruct( "antenna_path", "targetname" );
	path2 = getstruct( path1.target, "targetname" );
	path3 = getstruct( path2.target, "targetname" );
	path4 = getstruct( path3.target, "targetname" );
	path5 = getstruct( path4.target, "targetname" );
	path6 = getstruct( path5.target, "targetname" );
	
	wait( 2 );
	
	antenna moveTo( path1.origin, 1.5, 1.2, 0 );
	antenna RotateTo( path1.angles, 1.5, 1.2, 0 );
	antenna PlaySound( "carr_metal_groan" );
	wait( 1.5 );
	antenna moveTo( path2.origin, 1.0, 0, 0 );
	antenna RotateTo( path2.angles, 1.0, 0, 0 );
	wait( 1.0 );
	antenna moveTo( path3.origin, .85, 0, 0 );
	antenna RotateTo( path3.angles, .85, 0, 0 );
	wait( .85 );
	antenna moveTo( path4.origin, .75, 0, 0 );
	antenna RotateTo( path4.angles, .75, 0, 0 );
	antenna PlaySound( "carr_hallway_stress_02" );
	wait( .75 );
	antenna moveTo( path5.origin, .5, 0, 0 );
	antenna RotateTo( path5.angles, .5, 0, 0 );
	antenna PlaySound( "carr_deck_rumble" );
	
	antenna_impact = getEnt( "antenna_impact_spot", "targetname" );
	impact = antenna_impact spawn_tag_origin();
	
	PlayFXOnTag( level._effect[ "building_collapse_smoke_lg" ], impact, "tag_origin" );
	ScreenShake( level.player.origin, 3, 2, 2, 2.5, 0, 1.5, 256, 8, 15, 12, 1.8 );
	level.player PlayRumbleOnEntity( "ac130_40mm_fire" );
	level.player ShellShock( "hijack_engine_explosion", 1.0 );
	
	wait( .5 );
	antenna moveTo( path6.origin, .75, 0, 0 );
	antenna RotateTo( path6.angles, .75, 0, 0 );

	wait( 4.5 );
	StopFXOnTag( level._effect[ "building_collapse_smoke_lg" ], impact, "tag_origin" );
	
	waitframe();
	antenna_impact Delete();
	impact Delete();
}

tilt_props_aircraft()
{
	struct = getStruct( "deck_run_struct", "targetname" );
	
	level.exploding_heli = getEnt( "exploding_heli", "targetname" );
	level.exploding_heli thread maps\carrier_fx::tilt_chopper_fx( "tilt_part_30" );
	
	//level.sliding_jet1 = getEnt( "sliding_jet1", "targetname" );
	//level.sliding_jet1 thread maps\carrier_fx::tilt_jet_a_fx( "tilt_part_2" );
	level.sliding_jet2 = getEnt( "sliding_jet2", "targetname" );
	level.sliding_jet2 thread maps\carrier_fx::tilt_jet_a_fx( "tilt_part_15" );
	level.sliding_jet3 = getEnt( "sliding_jet3", "targetname" );
	level.sliding_jet3 thread maps\carrier_fx::tilt_jet_c_fx( "tilt_part_15" );
//	level.sliding_jet5 = getEnt( "sliding_jet5", "targetname" );
	//level.sliding_jet10 = getEnt( "sliding_jet10", "targetname" );
	//level.sliding_jet10 thread maps\carrier_fx::tilt_jet_a_fx( "tilt_part_35" );
	level.sliding_jet11 = getEnt( "sliding_jet11", "targetname" );
	level.sliding_jet12 = getEnt( "sliding_jet12", "targetname" );
	level.sliding_jet20 = getEnt( "sliding_jet20", "targetname" );
	
	level.exploding_heli thread tilt_anim_loop_to_solo( "exploding_heli", "carrier_mi_17_idle", "carrier_mi_17_explosion", "tilt_part_30", undefined, undefined, undefined, undefined, true );
	
	//level.sliding_jet1 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_a", "tilt_part_2", undefined, undefined, true );
	level.sliding_jet2 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_a", "tilt_part_15", undefined, undefined, "carr_jet_slide", undefined, true );
	level.sliding_jet3 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_c", "tilt_part_1", undefined, 0.5, "carr_jet_slide", undefined, true );
//	level.sliding_jet5 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_b", "tilt_part_15", undefined, undefined, "carr_jet_slide", undefined, true );
	
	//level.sliding_jet10 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_a", "tilt_part_35", undefined, undefined, "carr_jet_slide", undefined, true );
	level.sliding_jet11 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_a", "tilt_part_35", undefined, 1.25, "carr_jet_slide", undefined, true );
	level.sliding_jet12 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_c", "tilt_part_35", undefined, undefined, "carr_jet_slide", undefined, true );
	
	level.sliding_jet20 thread tilt_anim_solo( "sliding_jet", "carrier_mig29_deck_slide_c", "tilt_part_15", undefined, 1.0, "carr_jet_slide", undefined, true );
	
	//jet1_clip = getEnt( "jet1_clip", "targetname" );
	//jet1_clip.origin = level.sliding_jet1.origin;
	//jet1_clip.angles = level.sliding_jet1.angles;
	//jet1_clip LinkTo( level.sliding_jet1, "front_wheel_panel_jnt", (0, 0, 16), (0, 0, 0) );
		
	jet2_clip = getEnt( "jet2_clip", "targetname" );
	jet2_clip.origin = level.sliding_jet2.origin;
	jet2_clip.angles = level.sliding_jet2.angles;
	jet2_clip LinkTo( level.sliding_jet2, "front_wheel_panel_jnt", (0, 0, 16), (0, 0, 0) );

	jet3_clip = getEnt( "jet3_clip", "targetname" );
	jet3_clip.origin = level.sliding_jet3.origin;
	jet3_clip.angles = level.sliding_jet3.angles;
	jet3_clip LinkTo( level.sliding_jet3, "front_wheel_panel_jnt", (0, 0, 16), (0, 0, 0) );
	
	jet11_clip = getEnt( "jet11_clip", "targetname" );
	jet11_clip.origin = level.sliding_jet11.origin;
	jet11_clip.angles = level.sliding_jet11.angles;
	jet11_clip LinkTo( level.sliding_jet11, "front_wheel_panel_jnt", (0, 0, 16), (0, 0, 0) );
	
	jet12_clip = getEnt( "jet12_clip", "targetname" );
	jet12_clip.origin = level.sliding_jet12.origin;
	jet12_clip.angles = level.sliding_jet12.angles;
	jet12_clip LinkTo( level.sliding_jet12, "front_wheel_panel_jnt", (0, 0, 16), (0, 0, 0) );
	
	flag_wait( "tilt_part_15" );
	jet2_clip thread player_hit_detect( 300 );
	jet3_clip thread player_hit_detect( 300 );
	jet11_clip thread player_hit_detect( 300 );
	jet12_clip thread player_hit_detect( 300 );
}

tilt_props_large()
{
	struct = getStruct( "deck_run_struct", "targetname" );
	
	/*barrel_large1 = getent( "barcolypse1", "targetname" );
	barrel_large2 = getent( "barcolypse2", "targetname" );
	barrel_large3 = getent( "barcolypse3", "targetname" );
	barrel_large4 = getent( "barcolypse4", "targetname" );
	barrel_large5 = getent( "barcolypse5", "targetname" );
	barrel_large6 = getent( "barcolypse6", "targetname" );
	barrel_large7 = getent( "barcolypse7", "targetname" );
		
	barrel_small1 = getent( "barrel_small1", "targetname" );*/
	barrel_small2 = getent( "barrel_small2", "targetname" );
	barrel_small2_clip = GetEnt( "barrel_small2_clip", "targetname" );
	
	barrel_med1a = getent( "barrel_med1a", "targetname" );
	barrel_med1b = getent( "barrel_med1b", "targetname" );
	barrel_med2a = getent( "barrel_med2a", "targetname" );
	barrel_med2b = getent( "barrel_med2b", "targetname" );
	
	forklift = getEnt( "forklift", "targetname" );
	
	/*barrel_large1 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_c1", "end_container_move", undefined, 4.0, true );
	barrel_large2 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_c2", "end_container_move", undefined, 4.0, true );
	barrel_large3 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_c3", "end_container_move", undefined, 4.0, true );
	barrel_large4 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_c4", "end_container_move", undefined, 4.0, true );
	barrel_large5 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_c5", "end_container_move", undefined, 4.0, true );	
	barrel_large6 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_c6", "end_container_move", undefined, 4.0, true );
	barrel_large7 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_c7", "end_container_move", undefined, 4.0, true );
	
	barrel_small1 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_a", "tilt_part_1", undefined, .15, true );*/
	barrel_small2 thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_a", "tilt_part_23", undefined, undefined,"carr_metal_fall_03", undefined, true );
	
	barrel_med1a thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_b1", "tilt_part_35", undefined, undefined,"carr_metal_fall_03", undefined, true );
	barrel_med1b thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_b2", "tilt_part_35", undefined, undefined,"carr_metal_fall_03", undefined, true );
	
	barrel_med2a thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_b1", "tilt_part_50", undefined, undefined,"carr_metal_fall_03", undefined, true );
	barrel_med2b thread tilt_anim_solo( "barrels", "carrier_barrel_pallet_slide_b2", "tilt_part_50", undefined, undefined,"carr_metal_fall_03", undefined, true );
	
	forklift thread tilt_anim_solo( "forklift", "carrier_forklift_slide", "tilt_part_50", "forklift_struct", undefined, undefined, undefined, undefined );
	
	flag_wait( "tilt_part_23" );
	barrel_small2_clip Delete();
}

tilt_props_medium()
{
	sliding_crate_01a = spawn_anim_model( "generic_slide" );
	sliding_crate_01a thread tilt_anim_med_prop( "sliding_crate_01a", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", undefined, true, 15 );

	sliding_crate_01b = spawn_anim_model( "generic_slide" );
	sliding_crate_01b thread tilt_anim_med_prop( "sliding_crate_01b", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", .15, true, 15 );
	
	sliding_crate_01c = spawn_anim_model( "generic_slide" );
	sliding_crate_01c thread tilt_anim_med_prop( "sliding_crate_01c", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", .65, true, 15 );
	
	
//	sliding_crate_02a = spawn_anim_model( "generic_slide" );
//	sliding_crate_02a thread tilt_anim_med_prop( "sliding_crates_02a", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", .85, true, 15 );
//	
//	sliding_crate_02b = spawn_anim_model( "generic_slide" );
//	sliding_crate_02b thread tilt_anim_med_prop( "sliding_crates_02b", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", .95, true, 15 );
//	
//	sliding_crate_02c = spawn_anim_model( "generic_slide" );
//	sliding_crate_02c thread tilt_anim_med_prop( "sliding_crates_02c", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", 1.05, true, 15 );

	sliding_crate_02d = spawn_anim_model( "generic_slide" );
	sliding_crate_02d thread tilt_anim_med_prop( "sliding_crates_02d", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", .95, true, 15 );
	
	
//	sliding_crate_03a = spawn_anim_model( "generic_slide" );
//	sliding_crate_03a thread tilt_anim_med_prop( "sliding_crates_03a", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", 1.45, true, 5 );
//	
//	sliding_crate_03b = spawn_anim_model( "generic_slide" );
//	sliding_crate_03b thread tilt_anim_med_prop( "sliding_crates_03b", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", 1.45, true, 5 );
//	
//	sliding_crate_03c = spawn_anim_model( "generic_slide" );
//	sliding_crate_03c thread tilt_anim_med_prop( "sliding_crates_03c", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", 1.55, true, 15 );
//	
//	sliding_crate_03d = spawn_anim_model( "generic_slide" );
//	sliding_crate_03d thread tilt_anim_med_prop( "sliding_crates_03d", "J_prop_1", "carrier_prop_deck_slide_full", "tilt_part_2", 1.65, true, 15 );
}

tilt_props_odin_phys()
{
	objects = getEntArray( "odin_phys_objects", "targetname" );
	
	foreach( object in objects )
	{
		if( IsDefined( object.script_noteworthy ) && object.script_noteworthy == "clip" )
		{
			object Delete();
			
			continue;
		}
			
		randomx = RandomIntRange( 1000, 2000 );
		randomy = RandomIntRange( -1000, 1000 );
		randomz = RandomIntRange( 8000, 10000 );
		object PhysicsLaunchClient( object.origin + ( 0, 0, -2 ), ( randomx, randomy, randomz ));
	}
}

tilt_anim_med_prop( entname, tag, anime, flag, delay, link_clip, dmgamt )
{
	// --This is a generic prop raven anim that aligns with the placement of a model and has no scripted node.
	
	models = getEntArray( entname, "targetname" );
	model = undefined;
	clip = undefined;
	ent_flag_init( "tilt_debris_fall" );
	fall_vols = GetEntArray( "carrier_edge_volume", "targetname" );
	
	foreach( item in models )
	{
		if( item.script_noteworthy == "item" )
		{
			model = item;
		}	
	}
	
	self.origin = model.origin;
	self.angles = ( 0, 0, 0 );
	
	model LinkTo( self, tag );
	
	if( IsDefined( link_clip ))
	{
		foreach( item in models )
		{
			if( item.script_noteworthy == "clip" )
			{
				clip = item;
			}	
		}
		
		clip LinkTo( model );
	}
	
	flag_wait( flag );
	if ( IsDefined( delay ) )
	{	
		wait( delay );
	}
	if( IsDefined( dmgamt ))
	{
		thread player_hit_detect( dmgamt );
	}
	
	self thread anim_single_solo( self, anime );
		
	while( !ent_flag( "tilt_debris_fall" ))
	{
		foreach( vol in fall_vols )
		{
			if( self isTouching( vol ))
			{
				ent_flag_set( "tilt_debris_fall" );
			}
		}
		
		wait( .05 );
	}
	
	self notify( "falling" );
	self anim_single_solo( self, "carrier_prop_deck_slide_fall" );
	
	self delete();
	model delete();
}

tilt_anim_solo( animname, anime, waitflag, structname, start_delay, soundalias, sound_delay, delete_on_end )
{
	self.animname = animname;
	self SetAnimTree();
	
	AssertEx( IsDefined( waitflag ), "Must have a flag_wait defined for the animation: " + anime );
	
	// --play on scripted node or not
	if( IsDefined( structname ))
	{
		animnode = getstruct( structname, "targetname" );		
	}
	else
	{
		animnode = self spawn_tag_origin();
	}
	
	animnode thread anim_first_frame_solo( self, anime );
	
	// --wait to be triggered
	flag_wait( waitflag );
	
	// --delay if desired
	if( IsDefined( start_delay ))
	{
		wait( start_delay );
	}
	
	// --start anim	
	animnode thread anim_single_solo( self, anime );
	
	// --play sounds if desired with delay
	if( IsDefined( soundalias ))
	{
	   	if( IsDefined( sound_delay )) 		
		{
	   		wait( sound_delay );
		}
		
	   	self play_sound_on_entity( soundalias );
	}
	
	self waittillmatch( "single anim", "end" );
	
	// --if not on a scripted node, clean up ent
	if( !IsDefined( structname ))
	{
		animnode Delete();
	}
	
	// --delete self if desired
	if( IsDefined( delete_on_end ))
	{
		self delete();
	}
}

tilt_anim_loop_to_solo( animname, anime_loop, anime, waitflag, structname, start_delay, soundalias, sound_delay, delete_on_end )
{
	self.animname = animname;
	self SetAnimTree();
	
	AssertEx( IsDefined( waitflag ), "Must have a flag_wait defined for the animation: " + anime );
	
	// --play on scripted node or not
	if( IsDefined( structname ))
	{
		animnode = getstruct( structname, "targetname" );		
	}
	else
	{
		animnode = self spawn_tag_origin();
	}
	
	// --start looping animation
	animnode thread anim_loop_solo( self, anime_loop, "stop_loop" );
	
	// --wait to be triggered
	flag_wait( waitflag );
	
	// --delay if desired
	if( IsDefined( start_delay ))
	{
		wait( start_delay );
	}
	
	// --start anim	
	animnode notify( "stop_loop" );
	animnode thread anim_single_solo( self, anime );
	
	// --play sounds if desired with delay
	if( IsDefined( soundalias ))
	{
	   	if( IsDefined( sound_delay )) 		
		{
	   		wait( sound_delay );
		}
		
	   	self play_sound_on_entity( soundalias );
	}
	
	self waittillmatch( "single anim", "end" );
	
	// --if not on a scripted node, clean up ent
	if( IsDefined( structname ))
	{
		animnode Delete();
	}
	
	// --delete self if desired
	if( IsDefined( delete_on_end ))
	{
		self delete();
	}

}

player_hit_detect( dmgamt )
{
	self endon( "falling" );
	
	while ( !flag( "stop_dmg_check" ) )
	{
		b_touched_player = self IsTouching( level.player );
		
		if ( b_touched_player )
		{
			level.player DoDamage( dmgamt, self.origin, self );
			level.player PushPlayerVector( ( 35, 0, 0 ) );
			flag_set( "stop_dmg_check" );
			return;
		}
		
		waitframe();
	}
}

gravity_shift()
{
	x = 0.25;
	z = -0.9;
	
	for( i = 0; i < 13; i++ )
	{
		SetPhysicsGravityDir( ( x, 0.0, z ) );
		
		x += ( 0.05 );
		z += ( 0.01 );
		
		wait( 1 );
	}
}
