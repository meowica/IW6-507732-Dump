#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;
#include maps\_hud_util;

slow_intro_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//flag inits
	flag_init( "intro_fade_done" );
	flag_init( "intro_part_1_done" );
	flag_init( "intro_part_2_done" );
	flag_init( "intro_part_3_done" );
	flag_init( "fb_01" );
	flag_init( "fb_02" );
	flag_init( "fb_03" );
	flag_init( "slow_intro_finished" );
	flag_init( "disable_hurt_breathing" );
	flag_init( "stop_player_ekg" );
	flag_init( "slow_intro_alarms" );
	flag_init( "slow_intro_deck" );
	
	//precache
	//TODO: localize	
	intro_screen_create( "Carrier", "September 15th - 16:01", "Rook.", "USMC.", "Off Coast, Gulf Shore." );	
	intro_screen_custom_func( ::custom_intro_screen_func );
		
	//init arrays/vars
	
	//setup island door
	level.intro_island_door = getent( "intro_island_door", "targetname" );	
	level.intro_island_door_clip = getent( "intro_island_door_clip", "targetname" );	
	level.intro_island_door_open = getent( "intro_island_door_open", "targetname" );
	level.intro_island_door_open hide_entity();
	
	//hide ents	
	level.aas = getent("destroyed_aas_prop_script","targetname");
	level.aas_clip = getent("destroyed_aas_prop_clip","targetname");
	level.aas_tail = getent("destroyed_aas_tail_prop","targetname");
	level.aas_tail_clip = getent("destroyed_aas_tail_prop_clip","targetname");
	
	level.aas hide_entity();
	level.aas_clip hide_entity();
	level.aas_tail hide_entity();
	level.aas_tail_clip hide_entity();
	
	level.tugger = getent("deck_combat_tugger","targetname");
	level.tugger_clip = getent("deck_combat_tugger_clip","targetname");
	level.barrels = getent("deck_combat_barrels","targetname");
	level.barrels_clip = getent("deck_combat_barrels_clip","targetname");
	
	level.tugger hide_entity();
	level.tugger_clip hide_entity();
	level.barrels hide_entity();
	level.barrels_clip hide_entity();
	
	level.fork4 = getent("forklift4","targetname");
	level.fork4_clip = getent("forklift4_clip","targetname");
	level.ammo = getent("ammo_crate2","targetname");
	level.ammo_clip = getent("ammo_crate2_clip","targetname");
	
	level.fork4 hide_entity();
	level.fork4_clip hide_entity();
	level.ammo hide_entity();
	level.ammo_clip hide_entity();
	
	//"THREE DAYS LATER"
	add_hint_string( "3_days", &"CARRIER_3DAYS" );
}


//*only* gets called from checkpoint/jumpTo
setup_slow_intro()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "slow_intro";
	setup_common();	
	//spawn_allies();	
	thread setup_blackhawk( "intro_blackhawk_player" );
	level.blackhawk_ally = spawn_vehicle_from_targetname_and_drive( "intro_blackhawk_ally" );
	level.blackhawk_ally2 = spawn_vehicle_from_targetname_and_drive( "intro_blackhawk_ally2" );
	thread maps\carrier_audio::aud_check( "slow_intro" );
}

//always gets called
begin_slow_intro()
{
	SetSavedDvar( "sm_sunSampleSizeNear", 5.0 );
	//--use this to run your functions for an area or event.--
	level.player DisableWeapons();
	
	level.intro_island_door hide_entity();
	level.intro_island_door_clip hide_entity();
	level.intro_island_door_open show_entity();
	
	thread maps\_utility::vision_set_fog_changes( "carrier_intro", 0 );
	//audio for checkpoint
	thread maps\carrier_audio::aud_check( "slow_intro" );
	thread maps\carrier_audio::aud_intro_seq_lr();
	
	thread slow_intro();
	flag_wait( "slow_intro_finished" );	
	thread autosave_tactical();
}

custom_intro_screen_func()
{
	maps\_introscreen::introscreen( undefined, 4 );
}

slow_intro()
{		
	battlechatter_off( "allies" );
	
	thread intro_vo();
	thread run_fly_in();
	//thread run_flashback_01();
	
	flag_wait( "intro_part_1_done" );
	thread run_deck();
	
	flag_wait( "fb_01" );
	//thread run_flashback_02();
	//thread run_deck();
	flag_wait( "intro_part_2_done" );
	thread run_medbay();
	
	flag_wait( "fb_02" );
	//thread run_flashback_03();
	//run_medbay();	
}

intro_vo()
{
	flag_wait( "intro_fade_done" );
	
	wait( 0.5 );
	//Pilot: Multiple wounded, meet us with the med-unit, chalk down in 30.
	smart_radio_dialogue( "carrier_plt_multiplewoundedmeetus" );
	
	wait( 1.15 );
	hesh = get_living_ai( "hesh_intro", "script_noteworthy" );
	hesh.animname = "hesh";
	//Hesh: We have to go after him!
	hesh smart_dialogue( "carrier_hsh_wehavetogo" );
	
	merrick = get_living_ai( "merrick_intro", "script_noteworthy" );
	merrick.animname = "merrick";	
	//Merrick: Vargas has to wait!  We have to stop the Federation from activating ODIN!
	merrick smart_dialogue( "carrier_mrk_vargashastowait" );
	
	flag_wait( "intro_part_1_done" );
	wait( 3.0 );
	//Vargas: Goodbye Elias.
	level.player PlaySound( "carrier_vrg_goodbyeelias" );
		
	flag_wait( "fb_01" );
	wait( 1.0 );
	//Crewman: Coming through, clear out.
	level.ally2 smart_dialogue( "carrier_cwm_comingthroughclearout" );

	//Merrick: Tell Cent-com we’ll be ready.
	level.deck_hesh smart_dialogue( "carrier_mrk_tellcentcomwellbe" );

	//Hesh: Hang on, Adam, almost there.
	level.deck_hesh smart_dialogue( "carrier_hsh_hangonadamalmost" );
	
	flag_wait( "intro_part_2_done" );
	wait( 1.25 );
	//Elias: Vargas. He’s leading a vendetta against the Ghosts.
	level.player PlaySound( "carrier_els_vargashesleadinga" );
	
	flag_wait( "fb_02" );
	wait( 2.5 );
	//Doctor: Prep the IV and get those two cleaned up.
	level.doctor smart_dialogue( "carrier_doc_preptheivand" );
	
	wait( 3 );
	//Hesh: We’ll get Vargas, Adam. I promise.
	level.medbay_hesh smart_dialogue( "carrier_hsh_wellgetvargasadam" );
	
	flag_wait( "intro_part_3_done" );
	wait( 1 );
	//Elias: You boys look out for each other. That’s the most important thing
	level.player PlaySound( "carrier_els_youboyslookout" );
}

run_fly_in()
{
	//fade in from black
	wait( 1 );
	set_blur( 4, .25 );
	
	wait( 2 );
	flag_set( "intro_fade_done" );
	thread player_hearbeat_intro();		
	
	wait( 3 );
	
	thread player_ride_shake();
	level.player thread player_hurt_breathing();
	
	//spawn jet landing and flybys
	thread spawn_vehicle_from_targetname_and_drive( "intro_landing_jet" );
	thread spawn_vehicle_from_targetname_and_drive( "intro_flyby_jet1" );
	thread spawn_vehicle_from_targetname_and_drive( "intro_flyby_jet2" );
	thread spawn_vehicle_from_targetname_and_drive( "intro_flyby_jet3" );

	set_blur( 0, 1 );
	
	wait( 3 );
	set_blur( 4, 1 );
	thread set_black_fade( .35, 1 );
	
	wait( 1 );
	set_blur( 0, 1 );
	thread set_black_fade( 0, 1 );
	
	wait( 3 );
	flag_set( "disable_hurt_breathing" );
	set_blur( 4, 2 );
	
	wait( 1 );
	flag_set( "disable_hurt_breathing" );
	thread run_flashback_01();
	
	level.player vision_set_fog_changes( "prague_escape_flashback", 1.0 );
	fade_out( 1.0, "white" );
	wait( 1 );
	
	level.player_blackhawk Vehicle_TurnEngineOff();
	
	waitframe();
	flag_set( "intro_part_1_done" );
	wait( .05 );
	set_blur( 0, 1 );
	
	//teleport
	//intro_blackhawk_path_end = getstruct( "intro_blackhawk_path_end", "targetname" );
	//level.player_blackhawk Vehicle_Teleport( intro_blackhawk_path_end.origin, intro_blackhawk_path_end.angles );
	//level.player_blackhawk thread vehicle_paths( intro_blackhawk_path_end );	
	level notify( "player_unloading" );
	level.player.is_on_heli = false;
	level.player_blackhawk Vehicle_Teleport( ( 50000, 50000, 50000 ), ( 0, 0, 0 ) );
	waitframe();
	level.player_blackhawk Delete();
	level.blackhawk_ally Delete();
	level.blackhawk_ally2 Delete();
	
	level.player SetViewKickScale( 1 );
}

player_ride_shake()
{
	level endon( "player_unloading" );
	
	while ( 1 )
	{
		power = RandomFloatRange( 0.05, 0.1 );
		Earthquake( power, 0.5, level.player.origin, 200 );
		wait( 0.2 );
	}
}

player_hearbeat_intro()
{
	for( i = 0; i < 10; i++ )
	{
		level.player thread play_sound_on_entity( "breathing_heartbeat" );
		wait 1;
	}
}

run_flashback_01()
{
	CinematicInGame( "carrier_flashback_1", true );
		
	flag_wait( "intro_part_1_done" );
		
	thread fade_in( 1.0, "white" );
	wait( .15 );
	
	PauseCinematicInGame( 0 );

	wait( 5.25 );

	fade_out( .25, "white" );
	flag_set( "fb_01" );
}

run_deck()
{
	SetSavedDvar( "sm_sunSampleSizeNear", 0.25 );
	
	thread run_deck_blocking_props();
	thread run_deck_blocking();
	thread run_deck_blocking_player();
	
	flag_wait( "fb_01" );
	set_blur( 4, .25 );
	level.player vision_set_fog_changes( "carrier_intro", 0 );
	//setup
	flag_set( "slow_intro_deck" );
	
	wait( .5 );
	thread fade_in( 1.0, "white" );

	wait( 3.0 );
	set_blur( 0, 2 );

	wait( 2.5 );
	thread run_flashback_02();
	
	//fadeout	
	level.player vision_set_fog_changes( "prague_escape_flashback", 1.0 );
	fade_out( 1.0, "white" );
	wait( 1.0 );
	waitframe();
	flag_set( "intro_part_2_done" );
	
	//cleanup
	level.intro_island_door show_entity();	
	level.intro_island_door_clip show_entity();
	level.intro_island_door_open hide_entity();			
}

#using_animtree( "generic_human" );
run_deck_blocking()
{
	ref_node = getstruct( "anim_ref_intro_deck", "targetname" );
		
	//allies
	level.deck_hesh = spawn_targetname( "hesh_deck", true );
	level.ally2 = spawn_targetname( "intro_deck_ally2", true );

	level.deck_hesh.animname = "hesh";
	level.ally2.animname = "generic";	
	
	level.deck_hesh.ignoreme = true;
	level.ally2.ignoreme = true;
	
	flag_wait( "fb_01" );
	ref_node thread anim_single_solo( level.deck_hesh, "carrier_ghost_intro_deck_ally1" );
	ref_node thread anim_single_solo( level.ally2, "carrier_ghost_intro_deck_ally2" );
		
	waitframe();
	level.deck_hesh SetAnimTime( %carrier_ghost_intro_deck_ally1, 0.59 );
	level.ally2 SetAnimTime( %carrier_ghost_intro_deck_ally2, 0.59 );
	
	wait( 7 );
	level.deck_hesh Delete();
	level.ally2 Delete();
}

#using_animtree( "player" );
run_deck_blocking_player()
{
	ref_node = getstruct( "anim_ref_intro_deck", "targetname" );
	
	player_rig = spawn_anim_model( "player_rig" );
	ref_node anim_first_frame_solo( player_rig, "carrier_ghost_intro_deck_player" );
	level.player PlayerLinkToDelta( player_rig, "tag_player", 0, 15, 15, 15, 15 );
	
	flag_wait( "fb_01" );
	ref_node thread anim_single_solo( player_rig, "carrier_ghost_intro_deck_player" );
	
	waitframe();
	player_rig SetAnimTime( %carrier_ghost_intro_deck_player, 0.59 );
	
	wait( 7 );
	level.player Unlink();
}

#using_animtree( "animated_props" );
run_deck_blocking_props()
{
	//thread generic_prop_raven_anim( ref_node, "cart", "carrier_ghost_intro_deck_cart", "intro_deck_cart", undefined, true, "slow_intro_deck", true );
	
	animnode = getstruct( "anim_ref_intro_deck", "targetname" );
	cart = getent( "intro_deck_cart", "targetname" );
	
	rig = spawn_anim_model( "cart" );
	
	animnode anim_first_frame_solo( rig, "carrier_ghost_intro_deck_cart" );
	
	j1_origin = rig GetTagOrigin( "J_prop_1" );
	j1_angles = rig GetTagAngles( "J_prop_1" );
	
	waitframe();
	
	cart.origin = j1_origin;
	cart.angles = j1_angles;
	
	waitframe();

	cart LinkTo( rig, "J_prop_1" );
	
	flag_wait( "fb_01" );
	
	animnode thread anim_single_solo( rig, "carrier_ghost_intro_deck_cart" );
	waitframe();
	rig SetAnimTime( %carrier_ghost_intro_deck_cart, 0.59 );
	
	wait( 7 );
	
	cart Delete();
	rig Delete();
}

run_flashback_02()
{
	CinematicInGame( "carrier_test_2", true );
		
	flag_wait( "intro_part_2_done" );
	wait( 1.0 );
	
	thread fade_in( 1.0, "white" );
	wait( .15 );
	
	PauseCinematicInGame( 0 );
	
	wait( 3.9 );
	fade_out( 0, "white" );

	flag_set( "fb_02" );
}

run_medbay()
{
	animnode = getstruct( "anim_ref_intro_medbay", "targetname" );
	//thread maps\_utility::vision_set_fog_changes( "carrier_intro", 0 );
	thread maps\_utility::vision_set_fog_changes( "carrier", 0 );
	
	//player
	level.medbay_rig = spawn_anim_model( "player_rig" );
	legs = spawn_anim_model( "player_legs" );
	animnode anim_first_frame_solo( level.medbay_rig, "carrier_ghost_intro_medbay_player" );	
	level.player PlayerLinkToDelta( level.medbay_rig, "tag_player", 0, 20, 20, 10, 20 );

	merrick_medbay = spawn_targetname( "merrick_medbay", true );
	merrick_medbay gun_remove();
	merrick_medbay.animname = "merrick";

	hesh_medbay = spawn_targetname( "hesh_medbay", true );
	hesh_medbay.animname = "hesh";
	hesh_medbay gun_remove();
	level.medbay_hesh = hesh_medbay;
	
	level.doctor = spawn_targetname( "intro_medbay_doc", true );
	level.doctor.animname = "generic";	
	
	flag_wait( "fb_02" );
	set_blur( 5, .25 );
	
	thread player_ekg();
	
	animnode thread anim_single_solo( level.medbay_rig, "carrier_ghost_intro_medbay_player" );
	animnode thread anim_single_solo( legs, "carrier_ghost_intro_medbay_player_legs" );	

	animnode thread anim_single_solo( hesh_medbay, "carrier_ghost_intro_medbay_dad" );
	animnode thread anim_single_solo( merrick_medbay, "carrier_ghost_intro_medbay_merrick" );
	
	//doc
	animnode thread anim_single_solo( level.doctor, "carrier_ghost_intro_medbay_ally1" );
	
	//fadein
	wait( 1.5 );
	thread fade_in( 1.5, "white" );
	
	wait( 4.0 );
	set_blur( 0, 1 );
	
	wait( 1.5 );
	set_blur( 5, 2.5 );
	
	wait( 2.3 );
	thread run_flashback_03();
	
	//blackout	
	fade_out( 1, "white" );
	level.player vision_set_fog_changes( "prague_escape_flashback", 1.0 );
	
	wait( 1.0 );
	flag_set( "intro_part_3_done" );
	flag_set( "stop_player_ekg" );
	set_blur( 0, .25 );
	
	//cleanup
	legs Delete();
	hesh_medbay Delete();
	merrick_medbay Delete();
	level.doctor Delete();

	level.player allowJump( true );
}

player_ekg()
{
	level.player endon( "death" );
	
	while ( !flag( "stop_player_ekg" ) )
	{
		level.player thread play_sound_on_entity( "medbay_ekg" );
		wait 1;
	}		
}

#using_animtree( "generic_human" );
run_flashback_03()
{
	CinematicInGame( "carrier_flashback_3", true );
		
	flag_wait( "intro_part_3_done" );
		
	thread fade_in( 1, "white" );
	wait( .15 );
	
	PauseCinematicInGame( 0 );
	
	wait( 3.8 );
	thread fade_out( 0, "white" );

	flag_set( "fb_03" );
	wait( 1 );
	StopCinematicInGame();
	
	thread fever_dream();
}

fever_dream()
{
	
	thread maps\_utility::vision_set_fog_changes( "carrier_fever_dream", 0 );
	
	level.player Unlink();
	intro_medbay_floor = getstruct( "player_fever", "targetname" );
	level.player teleport_player( intro_medbay_floor );	
	level.player SetMoveSpeedScale( .4 );
	wait( 1 );
	
	animnode = getstruct( "medbay_fever_animnode", "targetname" );
	
	player_arms = spawn_anim_model( "player_rig" );
	player_arms Hide();
	
	door_rig = spawn_anim_model( "medbay_doors" );
	door_left = GetEnt( "medbay_fever_door_left", "targetname" );
	door_right = GetEnt( "medbay_fever_door_right", "targetname" );
	
	stuff	   = [];
	stuff[ 0 ] = player_arms;
	stuff[ 1 ] = door_rig;
	
	animnode anim_first_frame( stuff, "carrier_medbay_fever_doors" );
	
	j1_org = door_rig GetTagOrigin( "j_prop_1" );
	j1_ang = door_rig GetTagAngles( "j_prop_1" );
	
	j2_org = door_rig GetTagOrigin( "j_prop_2" );
	j2_ang = door_rig GetTagAngles( "j_prop_2" );
	
	door_left.origin = j1_org;
	door_left.angles = j1_ang;
	
	door_right.origin = j2_org;
	door_right.angles = j2_ang;
	
	door_left LinkTo( door_rig, "j_prop_1" );
	door_right LinkTo( door_rig, "j_prop_2" );
		
	thread fade_in( 3.0, "white" );
	
	flag_wait( "fever_dream_exit_medbay" );
	
	level.player PlayerLinkToBlend( player_arms, "tag_player", 0.6 );
	wait( 0.6 );
	player_arms Show();
	
	animnode thread anim_single( stuff, "carrier_medbay_fever_doors" );
	
	wait( 2.25 );
	
	thread fade_out( 1, "white" );
	level.player vision_set_fog_changes( "prague_escape_flashback", 1 );
	
	//wait( .25 );
	player_arms waittillmatch( "single anim", "end" );
	level.player Unlink();
	
	player_arms Delete();
	door_left Delete();
	door_right Delete();
	door_rig Delete();
	
	fire_org = GetEnt( "campfire_origin", "targetname" );
	fire = fire_org spawn_tag_origin();
	PlayFXOnTag( level._effect[ "firelp_small_pm" ], fire, "tag_origin" );
	
	teleport_pos = getstruct( "camp_teleport", "targetname" );
	thread maps\_utility::vision_set_fog_changes( "carrier_flashback", 0 );

	teleport_player( teleport_pos );
	//level.player SetMoveSpeedScale( .55 );
	
	spawner = getent( "intro_deck_dad", "targetname" );
	level.father = spawner spawn_ai( true, false );
	level.father.animname = "dad";	
	
	camp_hesh = spawn_targetname( "camp_hesh", true );
	camp_hesh gun_remove();
	camp_hesh.animname = "dad";
	
	animnode = getstruct( "campfire", "targetname" );
	animnode thread anim_loop_solo( level.father, "sitting_guard_loadAK_idle" );
		
	wait( .75 );
	animnode2 = getstruct( "campfire2", "targetname" );
	animnode2 thread anim_loop_solo( camp_hesh, "sitting_guard_loadAK_idle" );
	
	thread fade_in( 1.0, "white" );
	
	flag_wait( "start_camp_vo" );
	
	//Elias: Someone once asked me what type of a man it takes to be a Ghost.
	level.father smart_dialogue( "carrier_els_someoneonceaskedme" );
	wait( .5 );
	//Elias: Like we were somehow ... born different.
	level.father smart_dialogue( "carrier_els_likeweweresomehow" );	
	wait( 1 );
	//Elias: Ghosts aren't born.
	level.father smart_dialogue( "carrier_els_ghostsarentborn" );
	//Elias: We choose to walk between life and death. 
	level.father smart_dialogue( "carrier_els_wechoosetowalk" );
	//Elias: We are the sin eaters. 
	level.father smart_dialogue( "carrier_els_wearethesin" );
	//Elias: We call the other side 'home"
	level.father smart_dialogue( "carrier_els_wecalltheother" );
	
	flag_wait( "finish_camp_vo" );
	
	wait( 1 );
	
	//Elias: You earned it, kiddo.
	level.father smart_dialogue( "carrier_els_youearneditkiddo" );
	
	wait( 1.5 );
	
	thread set_black_fade( 1, 1.5 ); 
	wait( 1.5 );
	
	thread intro_ending();
	
	level.player AllowJump( true );
	level.player SetMoveSpeedScale( 1.0 );
	
	StopFXOnTag( level._effect[ "firelp_small_pm" ], fire, "tag_origin" );
	waittillframeend;
	fire_org Delete();
	fire Delete();
	level.father Delete();
	camp_hesh Delete();

}

intro_ending()
{
	wait( 3.0 );
	
	//"THREE DAYS LATER"
	display_hint( "3_days" );
	
	level.player PlayerLinkToDelta( level.medbay_rig, "tag_player", 1, 20, 20, 15, 15 );
	waitframe();
	thread maps\_utility::vision_set_fog_changes( "carrier", 0 );
	
	//cleanup
	level.player Unlink();
	level.player FreezeControls( true );
	level.player allowCrouch( true );
	level.player allowProne( true );
	level.player AllowSprint( true );
	level.player AllowAds( true );	
	intro_medbay_floor = getstruct( "intro_medbay_floor", "targetname" );
	level.player teleport_player( intro_medbay_floor );	
	//level.father Delete();
	level.medbay_rig Delete();
	//legs Delete();
	flag_set( "slow_intro_finished" );
	
	intro_ai = get_living_ai_array( "ally_intro", "script_noteworthy" );
	array_delete( intro_ai );
}

/*---------------------------------------------------*/
/*------------------ MEDBAY JUMPTO ------------------*/
/*---------------------------------------------------*/
setup_medbay()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "medbay";
	setup_common();	
	
	level.player DisableWeapons();
	level.player FreezeControls( true );
	thread set_black_fade( 1, .01 );
	
	flag_set( "fb_01" );
	flag_set( "slow_intro_deck" );
	flag_set( "slow_intro_finished" );
}

begin_medbay()
{
	//--use this to run your functions for an area or event.--
	thread run_exit();
	battlechatter_on( "allies" );
	
	flag_wait( "medbay_finished" );
	thread flag_clear_delayed( "slow_intro_alarms", 10 );
	thread autosave_tactical();	
}

run_exit()
{
	//--Setup--
	flag_set( "slow_intro_alarms" );
	
	smoke_array = getstructarray( "slow_intro_smoke_fx", "targetname" );
	foreach( fx in smoke_array )
	{
		PlayFX( level._effect[ "hangar_smoke"], fx.origin );			   
	}
	
	thread maps\carrier_vista::run_vista();
	spawn_allies();
	thread medbay_revival();		
	thread hall_redshirt_talk();
	thread hall_redshirt_runner();
	
	//--Fade in--
	wait( 2 );
	level.player FreezeControls( false );	
	thread set_black_fade( 0, 1.5 ); 
	wait( 1.5 );

	//--Hesh enters--
	animnode = getstruct( "anim_ref_medbay_door", "targetname" );
	animnode thread anim_single_solo( level.hesh, "carrier_medbay_letsgo_hesh_enter" );
	
	wait( 2.0 );
	//Keegan: Good you're up, we've got to get top side now! Let's go!
	level.hesh thread smart_dialogue( "carrier_kgn_goodyoureup" );
	thread maps\carrier::obj_meet_merrick();
	
	level.hesh waittillmatch( "single anim", "end" );
	
	if( !flag( "player_reached_medbay_door" ))
	{
		animnode thread anim_loop_solo( level.hesh, "carrier_medbay_letsgo_hesh_loop", "stop_loop" );
	}
	
	//--Wait for player, then exit--
	flag_wait( "player_reached_medbay_door" );
	animnode notify( "stop_loop" );

	animnode anim_single_solo( level.hesh, "carrier_medbay_letsgo_hesh_exit" );
	level.hesh fast_jog( true );
	level.hesh enable_ai_color();
	
	flag_wait( "player_reached_medbay_hall" );
	level.player EnableWeapons();
	
	//--Cleanup--
	flag_wait( "medbay_finished" );
	level.hesh fast_jog( false );
	level.hesh.animname = "hesh";
}

medbay_revival()
{	
	medic_loc = getstruct( "intro_medbay_cpr_medic_loc", "targetname" );
	
	reviver			  = spawn_targetname( "intro_medbay_cpr_medic" );
	wounded			  = spawn_targetname( "intro_medbay_cpr_wounded" );
	reviver.animname  = "generic";
	wounded.animname  = "generic";
	 
	reviver endon( "death" );
	 
	wounded gun_remove();
	reviver gun_remove();
	
	medic_loc thread anim_single_solo( reviver, "cpr_medic" );
	medic_loc anim_single_solo( wounded, "cpr_wounded" );		
	
	if ( IsAlive( reviver ) )
		medic_loc thread anim_loop_solo( reviver, "cpr_medic_endidle" );

	medic_loc thread anim_loop_solo( wounded, "cpr_wounded_endidle" );
	
	flag_wait( "medbay_finished" );	
	wounded Delete();
	reviver Delete();
}

hall_redshirt_talk()
{
	guys = [];
	guys[ 0 ] = spawn_targetname( "hall_redshirt_1", true );
	guys[ 1 ] = spawn_targetname( "hall_redshirt_2", true );
	
	guys[ 0 ].animname = "rs1";
	guys[ 1 ].animname = "rs2";
	
	animnode = getstruct( "anim_ref_medbay_door", "targetname" );
	
	animnode thread anim_loop( guys, "carrier_hallway_talk_loop", "stop_rs_loop" );
	
	flag_wait( "redshirts_start" );
	animnode notify( "stop_rs_loop" );
	
	animnode anim_single( guys, "carrier_hallway_salute_enter" );
	animnode thread anim_loop( guys, "carrier_hallway_salute_loop", "stop_rs_loop" );
	
	flag_wait( "redshirts_end" );
	animnode notify( "stop_rs_loop" );
	
	animnode anim_single( guys, "carrier_hallway_salute_exit" );
	animnode thread anim_loop( guys, "carrier_hallway_talk_loop", "stop_rs_loop" );
	
	flag_wait( "redshirts_delete" );
	animnode notify( "stop_rs_loop" );
	
	waitframe();
	array_delete( guys );
}

hall_redshirt_runner()
{
	flag_wait( "redshirts_runners_start" );
	
	runaway_allies = array_spawn_targetname( "intro_hall_runaway_ally", true );
	foreach ( ally in runaway_allies )
	{
		ally thread run_to_and_delete();
		ally set_moveplaybackrate( 1.1 );		
	}
	
	wait( 1.75 );
	
	runaway_allies = array_spawn_targetname( "intro_hall_runaway_ally2", true );
	foreach ( ally in runaway_allies )
	{
		ally thread run_to_and_delete();
		ally set_moveplaybackrate( 1.1 );		
	}	
}

run_to_and_delete( node )
{
	self endon( "death" );
	self.goalradius = 8;
	//if ( IsDefined( node ) )
	//{
	//	self SetGoalNode( node );
	//}
	self waittill( "goal" );
	self Delete();
}
