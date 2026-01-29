#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;

main()
{
	carrier_starts();
	
	template_level( "carrier" );
	maps\createart\carrier_art::main();
	maps\carrier_fx::main();
	maps\carrier_precache::main();
	maps\_load::main();
	maps\carrier_anim::main();
	precache_for_startpoints();
	maps\carrier_audio::main();
	maps\carrier_code_javelin::carrier_javelin_init();
	maps\_stinger::init();
//	maps\_c4::main();
	maps\_drone_ai::init();
	thread maps\carrier_fx::fx_init();
}



carrier_starts()
{
	default_start( maps\carrier_slow_intro::setup_slow_intro );
	set_default_start( "slow_intro" );							
		   //   msg 		      func 											     loc_string 	   optional_func 									 
	add_start( "slow_intro"	   , maps\carrier_slow_intro::setup_slow_intro		  , "Slow Intro"	, maps\carrier_slow_intro::begin_slow_intro );
	add_start( "medbay"		   , maps\carrier_slow_intro::setup_medbay			  , "Medbay"		, maps\carrier_slow_intro::begin_medbay );
	add_start( "deck_combat"   , maps\carrier_deck_combat::setup_deck_combat	  , "Deck Combat"	, maps\carrier_deck_combat::begin_deck_combat );
	add_start( "heli_ride"	   , maps\carrier_heli_ride::setup_heli_ride		  , "Heli Ride"		, maps\carrier_heli_ride::begin_heli_ride );
	add_start( "deck_combat2"  , maps\carrier_deck_combat2::setup_deck_combat2	  , "Deck Combat 2" , maps\carrier_deck_combat2::begin_deck_combat2 );
	add_start( "defend_sparrow", maps\carrier_defend_sparrow::setup_defend_sparrow, "Defend Sparrow", maps\carrier_defend_sparrow::begin_defend_sparrow );
	add_start( "deck_victory"  , maps\carrier_deck_victory::setup_deck_victory	  , "Victory Deck"	, maps\carrier_deck_victory::begin_deck_victory );
	add_start( "deck_tilt"	   , maps\carrier_deck_tilt::setup_deck_tilt		  , "Deck Tilt"		, maps\carrier_deck_tilt::begin_deck_tilt );
	add_start( "outro"		   , maps\carrier_outro::setup_outro				  , "Outro"			, maps\carrier_outro::begin_outro );
	add_start( "art"	, ::setup_art_start		, "ART START" );
}


setup_art_start()
{
	level.start_point = "art";
	setup_common();	
}

precache_for_startpoints()
{
	maps\carrier_slow_intro::slow_intro_pre_load();
	maps\carrier_deck_combat::deck_combat_pre_load();
	maps\carrier_heli_ride::heli_ride_pre_load();
	maps\carrier_deck_combat2::deck_combat2_pre_load();
	maps\carrier_defend_sparrow::defend_sparrow_pre_load();
	maps\carrier_deck_victory::deck_victory_pre_load();
	maps\carrier_deck_tilt::deck_tilt_pre_load();
	maps\carrier_outro::outro_pre_load();
	
	obj_flags();
	
	PreCacheModel( "generic_prop_raven" );
	
	thread post_load();
}

post_load()
{	
	//Add / call your post load stuff here.
//	level waittill ( "load_finished" );
	
	setsaveddvar_cg_ng( "fx_alphathreshold", 9, 9 );
	
	maps\carrier_planes::setup_planes();
}

//objective stuff
obj_flags()
{
	flag_init( "obj_meet_merrick_complete" );
	flag_init( "obj_defend_carrier_complete" );
	flag_init( "obj_sparrow_complete" );
	flag_init( "obj_exfil_complete" );
	
	//"Meet Merrick on the flight deck."
	PreCacheString( &"CARRIER_OBJ_MEET_MERRICK" );
	//"Defend the carrier."
	PreCacheString( &"CARRIER_OBJ_DEFEND_CARRIER" );
	//"Take control of the Sparrow launcher."
	PreCacheString( &"CARRIER_OBJ_SPARROW" );
	//"Meet Merrick at the Osprey for exfil."
	PreCacheString( &"CARRIER_OBJ_EXFIL" );
}

obj_meet_merrick()
{
	objective_number = 1;
	//"Meet Merrick on the flight deck."
	Objective_Add( objective_number, "active", &"CARRIER_OBJ_MEET_MERRICK" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_meet_merrick_complete" );

	Objective_State( objective_number, "done" );
}

obj_defend_carrier()
{
	objective_number = 2;
	//"Defend the carrier."
	Objective_Add( objective_number, "active", &"CARRIER_OBJ_DEFEND_CARRIER" );
	Objective_State( objective_number, "current" );

	flag_wait( "obj_defend_carrier_complete" );

	Objective_State( objective_number, "failed" );
}

obj_sparrow()
{
	objective_number = 3;
	//"Take control of the Sparrow launcher."
	Objective_Add( objective_number, "active", &"CARRIER_OBJ_SPARROW" );
	Objective_State( objective_number, "current" );
	Objective_OnEntity( objective_number, level.hesh, (0, 0, 70) );	
	Objective_SetPointerTextOverride( objective_number , &"CARRIER_OBJ_FOLLOW" );
	orig_fade = getdvar( "objectiveFadeTooFar" );
    SetSavedDvar( "objectiveFadeTooFar", 1 );
    wait(3);
    SetSavedDvar( "objectiveFadeTooFar", orig_fade );	
	flag_wait( "defend_sparrow_platform" );
	
	Objective_SetPointerTextOverride( objective_number , "" );
	
	flag_wait( "obj_sparrow_complete" );

	Objective_State( objective_number, "done" );
}

obj_exfil()
{
	objective_number = 4;
	
	object = getEnt( "exfil_obj_origin", "targetname" );
	
	//"Meet Merrick at the Osprey for exfil."
	Objective_Add( objective_number, "active", &"CARRIER_OBJ_EXFIL" );
	Objective_State( objective_number, "current" );
	//Objective_SetPointerTextOverride( objective_number, "Exfil" );
	//thread maps\carrier_deck_combat::clear_on_proximity( objective_number, object );
	
	flag_wait( "obj_exfil_complete" );

	Objective_State( objective_number, "failed" );
}
