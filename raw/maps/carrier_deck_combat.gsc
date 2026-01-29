#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;



deck_combat_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//flag inits
	flag_init( "deck_combat_finished" );
	flag_init( "raise_front_elevator" );
	flag_init("tuggergo");
	flag_init("tuggergo2");
	flag_init("tuggergo3");
	
	flag_init("forklift1");
	flag_init("forklift2");
	flag_init("forklift3");
	flag_init("forklift4");
	
	flag_init("back_fill_heli1");
	flag_init("end_carrier_life");
	flag_init("elevator_up_ding_ding");
	
 	flag_init("at_wave_struct");
 	flag_init("at_wave_cont_run");
 	flag_init("combat_1_kick");
 	flag_init("warning_1");
 	flag_init("warning_2");
 	flag_init("warning_1_rear");
 	flag_init("warning_2_rear");
 	flag_init("death_time");
 	flag_init("death_time_rear");
 	flag_init("background_jet_shot");
 	flag_init("final_wave_kick");

	
	//precache
//	PreCacheItem( "c4" );
	PrecacheItem( "stinger" );
	PrecacheItem( "javelin_carrier" );
	PreCacheModel( "weapon_javelin_sp" ); 
	PreCacheModel( "weapon_javelin_obj" );
 	

	//init arrays/vars
	
	//hide ents
	
	level.aas MoveZ(-100,1);
	level.aas hide_entity();
	level.aas_clip MoveZ(-100,1);
	level.aas_clip hide_entity();
	level.aas_tail MoveZ(-100,1);
	level.aas_tail hide_entity();
	level.aas_tail_clip MoveZ(-100,1);
	level.aas_tail_clip hide_entity();
	
	level.deck_combat_tugger = getent( "deck_combat_tugger", "targetname" );
	level.deck_combat_tugger_clip = getent( "deck_combat_tugger_clip", "targetname" );
	level.deck_combat_tugger hide_entity();
	level.deck_combat_tugger_clip hide_entity();
	
	level.deck_combat_barrels = getent( "deck_combat_barrels", "targetname" );
	level.deck_combat_barrels_clip = getent( "deck_combat_barrels_clip", "targetname" );
	level.deck_combat_barrels hide_entity();
	level.deck_combat_barrels_clip hide_entity();
		
	rear_warning1 = getent( "rear_warning1","targetname" );
	rear_warning1 hide_entity();
	
	rear_warning2 = getent( "rear_warning2","targetname" );
	rear_warning2 hide_entity();
	
	rear_kill_trigger = getent( "rear_kill_trigger","targetname" );
	rear_kill_trigger hide_entity();
	
	front_warning1 = getent( "front_warning1","targetname" );
	front_warning1 hide_entity();
	
	front_warning2 = getent( "front_warning2","targetname" );
	front_warning2 hide_entity();
	
	front_kill_trigger = getent( "front_kill_trigger","targetname" );
	front_kill_trigger hide_entity();
	
	door_clip= getent( "dc_island_door_clip","targetname" );
	door_clip hide_entity();
	
	jav_crate = getent("jav_crate","targetname");
    jav_crate_clip = getent("jav_crate_clip","targetname");
    jav_crate hide_entity();
    jav_crate_clip hide_entity();	
    
	level.sparrow_left = getstruct("dc1_sparrow_left","targetname");
	level.sparrow_right =getstruct("dc1_sparrow_right","targetname");    

	
}

//*only* gets called from checkpoint/jumpTo
setup_deck_combat()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "deck_combat";
	setup_common();
	
	spawn_allies();
	
	thread maps\carrier::obj_meet_merrick();
	thread maps\carrier_vista::run_vista();
	
	flag_set( "fb_01" );
	flag_set( "slow_intro_deck" );
	flag_set( "slow_intro_finished" );	
}

//always gets called
begin_deck_combat()
{
	//--use this to run your functions for an area or event.--
	
	level.player EnableWeapons();
	level.player takeweapon( "m9a1" );

	thread pre_set_front_elevator();
	
	door = getent( "deck_combat_door", "targetname" );
    door RotateTo( door.angles - (0, 100, 0), .01 );    
	
		
	level.deck_combat_tugger show_entity();
	level.deck_combat_tugger_clip show_entity();
	level.deck_combat_barrels show_entity();
	level.deck_combat_barrels_clip show_entity();
	
	level.deck_combat_tugger show_entity();
	level.deck_combat_tugger_clip show_entity();
	level.deck_combat_barrels show_entity();
	level.deck_combat_barrels_clip show_entity();
	
	level.fork4 show_entity();
	level.fork4_clip show_entity();
	level.ammo show_entity();
	level.ammo_clip show_entity();
	
	rear_warning1 = getent( "rear_warning1","targetname" );
	rear_warning1 show_entity();
	
	rear_warning2 = getent( "rear_warning2","targetname" );
	rear_warning2 show_entity();
	
	rear_kill_trigger = getent( "rear_kill_trigger","targetname" );
	rear_kill_trigger show_entity();
	
	front_warning1 = getent( "front_warning1","targetname" );
	front_warning1 show_entity();
	
	front_warning2 = getent( "front_warning2","targetname" );
	front_warning2 show_entity();
	
	front_kill_trigger = getent( "front_kill_trigger","targetname" );
	front_kill_trigger show_entity();
	
	level.heli_ride_destroyer_smoking show_entity();
	
	level.elevator_allies = array_spawn_targetname_allow_fail("redshirts_elevator",true);	
	
	thread Kill_trigger_front();
	thread Kill_trigger_rear();
    thread start_out_on_4();
    thread run_deck_combat();
    thread carrier_life_jet_anim();
    thread carrier_life_anims();
   
	
	
	flag_wait( "deck_combat_finished" );
	
	rear_warning1 = getent( "rear_warning1","targetname" );
	rear_warning1 hide_entity();
	
	rear_warning2 = getent( "rear_warning2","targetname" );
	rear_warning2 hide_entity();
	
	rear_kill_trigger = getent( "rear_kill_trigger","targetname" );
	rear_kill_trigger hide_entity();	
	
	front_warning1 = getent( "front_warning1","targetname" );
	front_warning1 hide_entity();
	
	front_warning2 = getent( "front_warning2","targetname" );
	front_warning2 hide_entity();
	
	front_kill_trigger = getent( "front_kill_trigger","targetname" );
	front_kill_trigger hide_entity();
	
	thread autosave_tactical();
}


start_out_on_4()
{
	flag_wait("carrier_life_kick");
	flag_set( "obj_meet_merrick_complete" ); //OBJECTIVE COMPLETE
	
	thread Merrick_talk();
	
	flag_set("tuggergo");
	flag_set("tuggergo2");
	flag_set("tuggergo3");
	
	flag_set("forklift1");
	flag_set("forklift2");
	flag_set("forklift3");
	
	
	wait .5;
	
	//deck life animation
	thread raise_front_elevator();
	thread genric_runners();
	thread background_redshirts();
	thread repairs_needed();
	thread jet_wave();
	thread island_door_shut();
	

	thread run_deck_vehicles();
	wait 2;
//	thread raise_front_elevator();

}

run_deck_vehicles()
{
	thread tugger_movement1();
	thread tugger_movement2();
	thread tugger_movement3();
	thread fork1_move();
	wait 2;
	thread fork3_move();
//	thread fork4_move();
	thread small_tugger();	
}

/*--------------------------------------------------*/
/*------------------ Carrier Life ------------------*/
/*--------------------------------------------------*/

carrier_life_anims()
{
	anim_node = getstruct("redshirt_forklift_stopper_ref","targetname");
	
	guys = [];
	
	guys[0]= spawn_targetname("tugger_director");
	guys[ 0 ].animname = "director";
	guys[0] gun_remove();
	
	guys[1]= spawn_targetname("tugger_inspector1");
	guys[1].animname = "inspector1";
	guys[1] gun_remove();
	
	guys[2]= spawn_targetname("tugger_inspector2");
	guys[2].animname = "inspector2";
	guys[2] gun_remove();
	
	guys[3]= getent("anim_tugger","targetname");
	guys[3].animname = "tugger";
	guys[3] SetAnimTree();
		
	anim_node anim_single(guys,"tugger_scene_enter");
	
	if(!flag("end_carrier_life"))
	{
		anim_node thread anim_loop(guys,"tugger_scene_loop","stop_loop");
	}
	
	flag_wait("end_carrier_life");
	
	anim_node notify("stop_loop");
	anim_node anim_single(guys,"tugger_scene_exit");
	
	
}
carrier_life_jet_anim()
{
	flag_wait("elevator_up_ding_ding");
	
	jet = getent("elevator_jet","script_noteworthy");
	jet_clip = getent("elevator_jet_clip","targetname");
	jet_clip.origin = jet.origin;
	jet_clip.angles = jet.angles;
	jet_clip linkto (jet);
	
	guy= spawn_targetname("jet_pilot");
	guy.animname = "pilot";
	guy gun_remove();
	guy linkto(jet);
	
	
	jet unlink();
	
	
	
	jet.animname = "elevator_jet";
	jet SetAnimTree();
	anim_node = jet spawn_tag_origin();
	anim_node.origin = jet GetTagOrigin("tag_body");
	anim_node.angles = jet GetTagangles("tag_body");
	
	anim_node anim_single_solo(guy,"tugger_scene_enter");
	anim_node anim_single_solo(jet,"elevator_jet_scene_enter");
	
	if(!flag("end_carrier_life"))
	{
		anim_node thread anim_loop_solo(jet,"elevator_jet_scene_loop","stop_loop");
//		anim_node thread anim_loop_solo(guy,"tugger_scene_exit","stop_loop");
	}
	
	flag_wait("end_carrier_life");
	
	anim_node notify("stop_loop");
	anim_node anim_single_solo(jet,"elevator_jet_scene_exit");
	anim_node anim_single_solo(guy,"tugger_scene_exit");
}
	
	



jet_events()
{
	   
	wait 7;
	thread jet_steam_effects();
	
	//move jet shield 1 up
    shield1 = getent("blast_shield1","targetname");
    shield1 movez(8,2,1);
    shield1 RotateTo((0,0,80),2,1 );
    
    wait 3;
    
    jet2= getent( "jet_launcher2", "targetname" );
    jet2_target = getstruct( jet2.target, "targetname" );
    jet2 MoveTo(jet2_target.origin, 2,1 );
    
    wait 1.2;
    
    jet2_target2 = getstruct( jet2_target.target, "targetname" );
    jet2 MoveTo(jet2_target2.origin, 2 );
    
    //steam effect
    steam_blast1 = getent ("steam_jet_blast1","targetname");
	playfx( level._effect[ "smoke_blow_1" ], steam_blast1.origin,(0,90,0));
   
    wait 1;
    
    jet2 delete();
    
    //move jet shield 2 up and shield 1 down
   
    shield2 = getent("blast_shield2","targetname");   
    shield2 movez(8,2,1);
    shield2 RotateTo((0,0,80),2,1 );
    
    shield1 RotateTo((0,0,0),3,1 );
    shield1 movez(-8,4,1);
    wait 2;
    
        
    jet3= getent( "jet_launcher3", "targetname" );
    jet3_target = getstruct( jet3.target, "targetname" );
    jet3 MoveTo(jet3_target.origin, 2,1 );
	
    wait 1.2;
    
    jet3_target2 = getstruct( jet3_target.target, "targetname" );
    jet3 MoveTo(jet3_target2.origin, 2 );
    
    wait 2;
    
    shield1 movez(8,2,1);
    shield1 RotateTo((0,0,80),2,1 );
    
    jet3 Delete();
    
            
}
jet_steam_effects()
{
	steam_large1 = getstruct ("steam_jet_launch1","targetname");
	playfx( level._effect[ "steam_large" ], steam_large1.origin,(0,90,0));
	
	steam_large2 = getent ("steam_jet_launch2","targetname");
	playfx( level._effect[ "steam_large" ], steam_large2.origin,(0,90,0));
	
	steam_linger1 = getent ("steam_jet_linger1","targetname");
	playfx( level._effect[ "steam_large" ], steam_linger1.origin,(90,0,-20));
	
	steam_linger2 = getent ("steam_jet_linger2","targetname");
	playfx( level._effect[ "steam_large" ], steam_linger2.origin,(90,0,-20));
	
	steam_cloud1 = getent ("steam_jet_cloud1","targetname");
	playfx( level._effect[ "steam_cloud" ], steam_cloud1.origin);
	
	steam_cloud2 = getent ("steam_jet_cloud2","targetname");
	playfx( level._effect[ "steam_cloud" ], steam_cloud2.origin);
	
	steam_cloud3 = getent ("steam_jet_cloud3","targetname");
	playfx( level._effect[ "steam_cloud" ], steam_cloud3.origin);
	
	





//	steam_tag1		  = spawn_tag_origin();
//	steam_large1 = getstruct ("steam_jet_launch1","targetname");
//	steam_large1.angles = steam_large1.angles + (90,0,0);
//	
//	steam_tag1.origin = steam_large1.origin;
//	PlayFXOnTag( level._effect[ "steam_large" ],steam_tag1, "tag_origin");
//	
//	
//	steam_tag2		  = spawn_tag_origin();
//	steam_large2 = getent ("steam_jet_launch2","targetname");
//	steam_tag2.origin = steam_large2.origin;
//	PlayFXOnTag( level._effect[ "steam_large" ],steam_tag2, "tag_origin");
//	

}



tugger_movement1()
{
	flag_wait ("tuggergo");
	
	//setup
	tugger_1 = getent( "large_tugger1", "targetname" );
	tugger_clip_1= getent( "large_tugger_clip1", "targetname" );
		
	tugger_clip_1 linkto(tugger_1);
		
	//move
	tugger_1_target = getstruct( tugger_1.target, "targetname" );
    tugger_1 MoveTo(tugger_1_target.origin, 5 );
    final = getstruct("tugger1_final_pos","targetname");
    tugger_1 RotateTo(final.angles,5,1);

    
    wait 5;
    
    tugger_1_target2 = getstruct( tugger_1_target.target, "targetname" );
    tugger_1 MoveTo(tugger_1_target2.origin, 5 );
    
    wait 5;
    tugger_clip_1 DisconnectPaths();
   
	
}
tugger_movement2()
{
	flag_wait ("tuggergo2");
	
	//setup
	tugger = getent( "tugger2", "targetname" );
	tugger_clip = getent( "tugger_clip2", "targetname" );
	tugger_clip linkto(tugger);
		
	//move
	tugger_target = getstruct( tugger.target, "targetname" );
    tugger MoveTo(tugger_target.origin, 7 );
        
    wait 7;
    
    tugger_target2 = getstruct( tugger_target.target, "targetname" );
    tugger MoveTo(tugger_target2.origin, 7 );
   
	
}
tugger_movement3()
{
	flag_wait ("tuggergo3");
	
	//setup
	tugger = getent( "large_tugger2", "targetname" );
	tugger_clip = getent( "large_tugger_clip2", "targetname" );
	
	tugger_clip linkto(tugger);
	
		
	//move
	tugger_target = getstruct( tugger.target, "targetname" );
    tugger MoveTo(tugger_target.origin, 5 );
        
    wait 5;
    
    tugger_target2 = getstruct( tugger_target.target, "targetname" );
    tugger MoveTo(tugger_target2.origin, 5 );
    final = getstruct("large_tugger2_final_pos","targetname");
    tugger RotateTo(final.angles,5,1);
    
    wait 5;
    tugger_target3 = getstruct( tugger_target2.target, "targetname" );
    tugger MoveTo(tugger_target3.origin, 5 );
    
   	wait 5;
    tugger_clip DisconnectPaths();
	
}

fork1_move()
{
	//TODO: JZ - Re-work all deck combat ground vehicle functions to do set up at map load so we can let them do normal playthrough or hijack them for checkpoints.
	
	//flag_wait("forklift1");
	
	//setup
	fork = getent( "forklift1", "targetname" );
	fork_clip= getent( "forklift1_clip", "targetname" );
	fork_crate = getent( "fork_move_ammocrate", "targetname" );
	fork_crate_clip= getent( "fork_move_ammocrate_clip", "targetname" );
	
	fork_crate_clip linkto (fork_crate);
	fork_clip linkto(fork);
	
	
	fork_crate linkto(fork);
	
	//JZ - moving this to final position if starting at checkpoint.
	if( level.start_point != "deck_combat" )
	{
		final = getstruct( "fork1_final_pos", "targetname" );
		
		fork MoveTo( final.origin, .05 );
		fork RotateTo( final.angles, .05 );
		
		return;
	}
	
	flag_wait( "forklift1" ); //JZ - moved this to do the prep earlier.
	
	//move
	wait 5;
	fork_target = getstruct( fork.target, "targetname" );
    fork MoveTo( fork_target.origin, 3 );
        
    wait 3;
    fork_target2 = getstruct( fork_target.target, "targetname" );
    fork MoveTo( fork_target2.origin, 4 );
    final = getstruct( "fork1_final_pos", "targetname" );
    fork RotateTo( final.angles, 4, 1 );
    
    wait 4;
    
   	fork_target3 = getstruct( fork_target2.target, "targetname" );
    fork MoveTo( fork_target3.origin, 3 );
    
    wait 3;
    fork_clip DisconnectPaths();
    fork_crate_clip DisconnectPaths();
}

fork3_move()
{
	flag_wait("forklift3");
	
	//setup
	fork = getent( "forklift3", "targetname" );
	fork_clip= getent( "forklift3_clip", "targetname" );
	ammo_crate = getent( "ammo_crate1", "targetname" );
	ammo_crate_clip= getent( "ammo_crate_clip1", "targetname" );
	
	ammo_crate_clip linkto (ammo_crate);
	fork_clip linkto(fork);
	
	
	ammo_crate linkto(fork);
	
	//move
	wait 5;
	
	fork_target = getstruct( fork.target, "targetname" );
    fork MoveTo(fork_target.origin, 4 );
        
    wait 4;
    fork_target2 = getstruct( fork_target.target, "targetname" );
    fork MoveTo(fork_target2.origin, 4 );
    final = getstruct("fork3_final_pos","targetname");
    fork RotateTo(final.angles,4,1);
    
    wait 4;
    
    fork_target3 = getstruct( fork_target2.target, "targetname" );
    fork MoveTo(fork_target3.origin, 2 );
    
    wait 4;
    fork_clip DisconnectPaths();
    ammo_crate_clip DisconnectPaths();
    

    
	
}
fork4_move()
{
	flag_wait("forklift4");
	
	//setup
	
	tag_ref = getent( "redshirt_seat", "targetname" );
	
//	spawner = getent( "redshirt_forkdriver4", "targetname" );
//	level.forkdriver = spawner spawn_ai( true, false );
//	level.forkdriver.animname = "generic";
//	level.forkdriver gun_remove();
//	
//	level.forkdriver thread forklift_driver();
				
//	fork = getent( "forklift4", "targetname" );
//	fork_clip= getent( "forklift4_clip", "targetname" );
//	ammo_crate = getent( "ammo_crate2", "targetname" );
//	ammo_crate_clip= getent( "ammo_crate2_clip", "targetname" );
//	
//	ammo_crate_clip linkto (ammo_crate);
//	fork_clip linkto(fork);
////	level.forkdriver linkto(tag_ref);
//	
//	
//	
//	ammo_crate linkto(fork);
//	tag_ref linkto(fork);
//	
//	//move
//	wait 3;
//	
//	fork_target = getstruct( fork.target, "targetname" );
//    fork MoveTo(fork_target.origin, 5 );
//    final = getstruct("fork4_final_pos","targetname");
//    fork RotateTo(final.angles,3,1);
//    
//    wait 5;
//    fork_target2 = getstruct( fork_target.target, "targetname" );
//    fork MoveTo(fork_target2.origin, 5 );
//   
//        
//    
//    wait 2.8;   
////    level.forkdriver unlink();
////    level.forkdriver gun_recall(); 
//    
//    jav1loc = getent("jav1_position","targetname");
//    jav1 = spawn("weapon_javelin_dcburn",jav1loc.origin);
//    jav1 ItemWeaponSetAmmo(1,2);
//    
//    stinger1loc = getent("stinger1_position","targetname");
//    sting1 = spawn("weapon_stinger",stinger1loc.origin);
//    
//    
//    stinger2loc = getent("stinger2_position","targetname");
//    sting2 = spawn("weapon_stinger",stinger2loc.origin);
    
    
    
        
	
}
forklift_driver()
{
	self endon("death");
	tag_ref = getent("redshirt_seat","targetname");
	tag_ref anim_single_solo( self,"fork_driver");
	self.ignoreall = true;
}

small_tugger()
{
	tugger = getent( "small_tugger1", "targetname" );
	tugger_clip= getent( "small_tugger1_clip", "targetname" );
	ammo_crate = getent( "ammo_crate3", "targetname" );
	ammo_crate_clip= getent( "ammo_crate3_clip", "targetname" );
	
	ammo_crate_clip linkto (ammo_crate);
	tugger_clip linkto(tugger);
	ammo_crate linkto(tugger);
	
	//move
	wait 3;
	
	tugger_target = getstruct( tugger.target, "targetname" );
    tugger MoveTo(tugger_target.origin, 3 );
    final = getstruct("small_tugger1_final_pos","targetname");
    tugger RotateTo(final.angles,3,1);
    
    wait 3;
    tugger_target2 = getstruct( tugger_target.target, "targetname" );
    tugger MoveTo(tugger_target2.origin, 3 );
    
    wait 3;
    jav_crate = getent("jav_crate","targetname");
    jav_crate_clip = getent("jav_crate_clip","targetname");
    jav_crate show_entity();
    jav_crate_clip show_entity();
    
    
    javelin1 = spawn( "weapon_javelin_carrier", (202,4620,1434), 1 );// 1 = suspended
	javelin1.angles = ( 300,4,-3.5 );
	javelin1 ItemWeaponSetAmmo(1,2);
	javelin1 thread add_jav_glow();
	
	
	javelin2 = spawn( "weapon_javelin_carrier", (232,4594,1440), 1 );// 1 = suspended
	javelin2.angles = ( 0,90,0 );
	javelin2 ItemWeaponSetAmmo(1,2);
	javelin2 thread add_jav_glow();
    
    wait 3;
    tugger_clip DisconnectPaths();
    ammo_crate_clip DisconnectPaths();

          
            
//    c4loc = getent("c4_position","targetname");
//    c4 = spawn("c4",c4loc.origin);
    
    
    
   
}

genric_runners()
{
	//spawn
	
	spawner = getent( "redshirt_door_runby1", "targetname" );
	ally1 = spawner spawn_ai( true, false );
	ally1.animname = "generic";
	
	spawner = getent( "redshirt_door_runby2", "targetname" );
	ally2 = spawner spawn_ai( true, false );
	ally2.animname = "generic";	
	
	spawner = getent( "redshirt_door_runby3", "targetname" );
	ally3 = spawner spawn_ai( true, false );
	ally3.animname = "generic";	
	ally3 set_run_anim( "jog_1" ); 
	
	wait 7;
	//spawn_deck_runner_guys
	spawner = getent( "redshirt_deck_runner1", "targetname" );
	ally4 = spawner spawn_ai( true, false );
	ally4.animname = "generic";
	ally4 gun_remove();
	
	spawner = getent( "redshirt_deck_runner2", "targetname" );
	ally5 = spawner spawn_ai( true, false );
	ally5.animname = "generic";
	ally5 gun_remove();
	
//	spawner = getent( "redshirt_deck_runner3", "targetname" );
//	ally6 = spawner spawn_ai( true, false );
//	ally6.animname = "generic";
//	
//	spawner = getent( "redshirt_deck_runner4", "targetname" );
//	ally7 = spawner spawn_ai( true, false );
//	ally7.animname = "generic";
	
	
	//spawn_background_guys
	spawner = getent( "redshirt_backgroundrunner1", "targetname" );
	ally8 = spawner spawn_ai( true, false );
	ally8.animname = "generic";
	
//	position = getstruct("run_wave","targetname");
	
	spawner = getent( "redshirt_backgroundwaver1", "targetname" );
	ally9 = spawner spawn_ai( true, false );
	ally9.animname = "generic";
	
	//animate_door_runners
	ally1 thread set_generic_run_anim( "jog_1");	
	ally2 thread set_generic_run_anim( "jog_2");
//	ally3 thread set_generic_run_anim( "jog_1");
	
	//animate_deck_runners
	ally4 thread set_generic_run_anim( "jog_1");	
	ally5 thread set_generic_run_anim( "jog_2");
//	ally6 thread set_generic_run_anim( "jog_1");	
//	ally7 thread set_generic_run_anim( "jog_2");
	
	
	//animate_background_guys
	
	ally8 thread set_generic_run_anim( "jog_2");
	
	
	flag_wait("at_wave_struct");
	ally9 anim_single_solo( ally9,"waveguy1");
	flag_set("at_wave_cont_run");
	
	
	
}
background_redshirts()
{
	background_ally_fighters = array_spawn_targetname_allow_fail("redshirt_background",true);
	foreach (guy in background_ally_fighters)
	{
		guy set_force_color("r");
	}
}

jet_wave()
{
	//spawn
	position = getstruct("jetwave_struct","targetname");
	
	spawner = getent( "redshirt_plane_waver", "targetname" );
	ally1 = spawner spawn_ai( true, false );
	ally1.animname = "generic";
	ally1 gun_remove();
	
	position2 = getstruct("jet_blast_rear_guy2","targetname");
	
	spawner = getent( "redshirt_plane_blast_checker2", "targetname" );
	ally2 = spawner spawn_ai( true, false );
	ally2.animname = "generic";
		
		
	//animate
	position2 anim_single_solo( ally2, "waveguy2" );
	position2 anim_single_solo( ally2, "waveguy2" );
	wait .5;
	position thread anim_single_solo( ally1, "plane_wave_on" );
	
//	wait 10;
//	ally1 delete();
	
		
}
repairs_needed()
{
	//spawn
	
	position4 = getstruct("repair_struct4","targetname");
	
	spawner = getent( "redshirt_jet_repair4", "targetname" );
	ally4 = spawner spawn_ai( true, false );
	ally4.animname = "generic";
	ally4 gun_remove();
	
	
	//animate
	
	
//	position2 thread anim_single_solo( ally2, "repair2" );	
	
	position4 thread anim_single_solo( ally4, "repair3" );
	wait 6;
	ally4 gun_recall();
}
walk_on()
{
	//spawn
//	spawner = getent( "redshirt_gunrun1", "targetname" );
//	ally1 = spawner spawn_ai( true, false );
//	ally1 enable_cqbwalk();
//	
//	spawner = getent( "redshirt_gunrun2", "targetname" );
//	ally2 = spawner spawn_ai( true, false );
//	ally2 enable_cqbwalk();
//	
}
island_door_shut()
{
	flag_wait("island_doorshut");
		
	door = getent( "deck_combat_door", "targetname" );
    door RotateTo( door.angles - (0, -100, 0), .5 ); 
    
    door_clip= getent( "dc_island_door_clip","targetname" );
	door_clip show_entity();
	
	flag_set("end_carrier_life");
    
	
}



/*------------------------------------------------------------*/
/*------------------ Merrick meet and greet ------------------*/
/*------------------------------------------------------------*/

Merrick_talk()
{
	thread Merrick_speaking_softly();
	
	battlechatter_off( "allies" );
    
	flag_set("forklift4");
	
	//talking redshirt
	spawner = getent( "redshirt_merrick_talker", "targetname" );
	ally1 = spawner spawn_ai( true, false );
	ally1.animname = "generic";
	ally1 gun_remove();
	
	redshirt_talking_ref = getstruct( "deck_merrick_wave_ref", "targetname" );
	redshirt_talking_ref thread anim_custom_animmode_solo( ally1, "gravity", "outside_door_talk" );

	redshirt_talk_run = getnode("redshirt_talk_run","targetname");
	ally1 SetGoalNode (redshirt_talk_run);	
	ally1 enable_sprint();
	ally1 gun_recall();
	
	
	wait 9;
	redshirt_forklift_stop_ref = getstruct( "redshirt_forklift_stopper_ref", "targetname" );
	redshirt_forklift_stop_ref thread anim_single_solo( ally1, "stop that forklift" );
	//soldier: "move those tuggers into position"
	ally1 smart_dialogue("carrier_gs1_movethosetuggersinto");
	wait 4;
	//soldier: "take defensive positions"
	ally1 smart_dialogue("carrier_gs1_takedefensivepositions");
	ally1 StopAnimScripted();
	ally1 gun_recall();
	
	
	
}
Merrick_speaking_softly()
{
	//talking Merrick

	thread jet_events();
	flag_set("combat_1_kick");

	
	merrick_wave_ref = getstruct( "deck_merrick_wave_ref", "targetname" );

	merrick_wave_ref thread anim_custom_animmode_solo( level.merrick, "gravity", "wave_to_player" );
	
	level.merrick enable_cqbwalk();
 	level.merrick gun_recall();
	merrick_walk = getnode("merrick_walking","targetname");
	level.merrick setgoalnode(merrick_walk);
	
	
	thread hesh_talking_Merrick();
		
	//hesh: "Adam's up"
	level.player play_sound_on_entity( "carrier_kgn_adamsup" );
	
	wait .8;
	//Merrick: "Nice to have you back"
	level.player play_sound_on_entity( "carrier_mer_nicetohaveyouback" );	
	
		
    
//	//spawn in background redshirts
//	spawner = getent( "redshirt_gunrun1", "targetname" );
//	ally1 = spawner spawn_ai( true, false );
//	ally1.animname = "generic";	
//	ally1 enable_cqbwalk(); 
//	
//	spawner = getent( "redshirt_gunrun2", "targetname" );
//	ally2 = spawner spawn_ai( true, false );
//	ally2.animname = "generic";	
//	ally2 enable_cqbwalk(); 
//		
 	//Merrick: "We need to hold off enemy forces until incoming blackhawks arrive"
	level.player thread play_sound_on_entity( "carrier_mrk_weneedtohold" );
	
			 	
 	thread maps\carrier::obj_defend_carrier();
 	
 	wait 3.4; 	 	
	//Merrick: "move soldier move"
 	level.player play_sound_on_entity( "carrier_mer_movesoldiermove" );
 	
//	activate_trigger_with_targetname("dc1_good_move_1");
//	
	battlechatter_on( "allies" );
	
	
	
	
	
	
	//defend marker
	obj_name = obj( "Defend" );

	defend_loc = getstruct("defend_pos","targetname");
	
	Objective_Add(obj_name, "active","Defend Deck from Enemy Choppers", defend_loc.origin );

    Objective_Current(obj_name);
    
    Objective_SetPointerTextOverride( obj_name, "Defend" );
    
    thread clear_on_proximity(obj_name, defend_loc);


    //play ambient v/o
    
    wait 1;
    //Overlord: "multiple runners portside"
    smart_radio_dialogue( "carrier_hqr_multiplerunnersportside" );
	wait 0.5;
	
    //Blackhawk: "i have visuals breaking"
	smart_radio_dialogue( "carrier_hp1_ihavevisualsbreaking" );
	wait .7;
	
	//Merrick: "Damn it grab a javelin and take some of the choppers out of the sky"
	level.player play_sound_on_entity( "carrier_mrk_damnitgraba" );
	
	//Overlord: "secondary targets approaching at zulu one niner"
	smart_radio_dialogue( "carrier_hqr_secondarytargetsat" );
	
	//Overlord: "f18s are in the air"
    level.player play_sound_on_entity( "carrier_hqr_f18sareinthe" );
	
	thread autosave_tactical();
	
	wait 1;
	//Blackhawk: "negative, negative airspace hostile they are everywhere"
	smart_radio_dialogue ( "carrier_hp1_negativenagativeairspace" );
	
	
	wait 2;
	//Overlord: "10 more bogeys within alert five distance"
	smart_radio_dialogue( "carrier_hqr_10morebogeyswithin" );
	
	thread walk_on();
 	
	

 	
}
hesh_talking_Merrick()
{
	
	hesh_talk_ref = getstruct( "deck_merrick_wave_ref", "targetname" );
	hesh_talk_ref thread anim_single_solo( level.hesh,"hesh_talk");
	wait 6;
	activate_trigger_with_targetname("dc1_good_move_1");
}


clear_on_proximity(obj_name, loc)
{
   OBJ_CLEAR_DIST  = 800;
    while ( DistanceSquared( level.player.origin, loc.origin ) > OBJ_CLEAR_DIST * OBJ_CLEAR_DIST )
    {
        wait 1.0;    
    }
    Objective_State( obj_name, "invisible" );    
}




 /*--------------------------------------------------------- */
 /*------------------ It just hit the fan ------------------ */
 /*--------------------------------------------------------- */
			
run_deck_combat()
{
	flag_wait( "combat_1_kick" );
	thread sparrow_heli_attack();
	thread dummy_heli_waves();
    thread front_ambient_helis_wave1();
    thread middle_ambient_helis_wave1();
    thread rear_ambient_helis_wave1();
	
	enemy_helis			= spawn_vehicles_from_targetname_and_drive( "bad_helis1" );
	fastrope_enemy_heli = spawn_vehicles_from_targetname_and_drive( "bad_heli1_fastrope" );
	enemy_helis			= array_combine( enemy_helis, fastrope_enemy_heli );
 	 	
 	enemy_helis kill_heli_engine_sounds();
 	
// 	spawn_vehicle_from_targetname_and_drive( "heli_gun_run1" );
 	

// 	array_spawn_function_targetname( "ally_jav_heli", ::javelin_heli_blowup );
// 	level.ally_jav_heli = spawn_vehicle_from_targetname_and_drive( "ally_jav_heli");
 	
	wait 1;
 	thread javelin_target_set( enemy_helis, ( 0,0,0 ) );
 	thread fly_by_helis();
 	
 	//blowup helis with sparrows
 	flag_wait("blowup_fastropeheli");
	
//	startshoot = getstruct( "dc1_rpg_launch", "targetname" );
//	targetshoot = getstruct( "dc1_rpg_hit", "targetname" );;
//    MagicBullet( "rpg_straight", startshoot.origin, targetshoot.origin );
 	
    
    wait 2;
    thread middle_ambient_ally_drones();
    thread final_wave_ambient_ally_drones();
    
    wait 3;
    thread front_ambient_ally_drones();
    thread rear_ambient_ally_drones();
 	thread backfill_helis();
 	thread background_jets();
 	thread background_helis();
 	
 	
 	 //Ally Javelin user
    
//    array_spawn_function_targetname( "redshirt_javelin_guy", ::javelin_guy_setup );
//    level.redshirtjav = array_spawn_targetname( "redshirt_javelin_guy", true );
  
}
sparrow_heli_attack()
{
	//spawn sparrow heli wave targets
	target_right1 = spawn_vehicle_from_targetname_and_drive( "sparrow_target_right1" );
    Target_Set( target_right1 );
    Target_HideFromPlayer( target_right1, level.player );
    
    target_right2 = spawn_vehicle_from_targetname_and_drive( "sparrow_target_right2" );
    Target_Set( target_right2 );
    Target_HideFromPlayer( target_right2, level.player );
    
    target_right3 = spawn_vehicle_from_targetname_and_drive( "sparrow_target_right3" );
    Target_Set( target_right3 );
    Target_HideFromPlayer( target_right3, level.player );
    
    target_right4 = spawn_vehicle_from_targetname_and_drive( "sparrow_target_right4" );
    Target_Set( target_right4 );
    Target_HideFromPlayer( target_right4, level.player );
    
    target_left1 = spawn_vehicle_from_targetname_and_drive( "sparrow_target_left1" );
    Target_Set( target_left1 );
    Target_HideFromPlayer( target_left1, level.player );
    
    target_left2 = spawn_vehicle_from_targetname_and_drive( "sparrow_target_left2" );
    Target_Set( target_left2 );
    Target_HideFromPlayer( target_left2, level.player );
    
    target_left3 = spawn_vehicle_from_targetname_and_drive( "sparrow_target_left3" );
    Target_Set( target_left3 );
    Target_HideFromPlayer( target_left3, level.player );
	
	
    
    //blowup wave of helis with sparrow launcher
	wait 8;
	
	fire_single_sparrow_missile( level.sparrow_right, target_right1 );
	fire_single_sparrow_missile( level.sparrow_right, target_right2 );
	fire_single_sparrow_missile( level.sparrow_left, target_left1 );
	
	fire_single_sparrow_missile( level.sparrow_right, target_right3 );
	fire_single_sparrow_missile( level.sparrow_right, target_right4 );
	fire_single_sparrow_missile( level.sparrow_left, target_left2 );
	fire_single_sparrow_missile( level.sparrow_left, target_left3 );
    
	
	//spawn jets to blow up sparrow
	wait 4;
	spawn_vehicle_from_targetname_and_drive( "enemy_jet_missile");
	
	target_jet = spawn_vehicle_from_targetname_and_drive( "enemy_jet_sparrow_blowup" );
    Target_Set( target_jet );
    Target_HideFromPlayer( target_jet, level.player );
	
    //blow up fast mover
	fire_single_sparrow_missile( level.sparrow_right, target_jet );
	
	wait 4;
	
    playfx( level._effect[ "vehicle_explosion_mig29" ], target_jet.origin);
    target_jet delete();
    
    sparrow_destroyedfx = getstruct("sparrow_fire","targetname");
    playfx( level._effect[ "window_fire_large" ], sparrow_destroyedfx .origin);
	
}
dummy_heli_waves()
{
	///wave 1
	dummy_helis = spawn_vehicles_from_targetname_and_drive( "dummy_wave_helis" );
		
	thread javelin_target_set( dummy_helis, ( 0,0,0 ) );
	
	flag_wait("dummy_helis_death");
	    
    dummy_sparrow = getent("dummy_heli_sparrow_launch","targetname");
    
    foreach(heli in dummy_helis)
    {
    	if ( IsDefined (heli) && IsAlive(heli))
    	{
    		fire_single_sparrow_missile( dummy_sparrow, heli );
    		RandomIntRange(3,8);
    		array_spawn_function_targetname( "dummy_wave_helis", ::heli_fast_explode );
    	}
    }
    
    wait 15;
    
    ///wave 2
    dummy_helis2 = spawn_vehicles_from_targetname_and_drive( "dummy_wave2_helis" );
		
	thread javelin_target_set( dummy_helis2, ( 0,0,0 ) );
	
	flag_wait("dummy_helis_death_wave2");
	    
    dummy_sparrow = getent("dummy_heli_sparrow_launch","targetname");
    
    foreach(heli in dummy_helis2)
    {
    	if ( IsDefined (heli) && IsAlive(heli))
    	{
    		fire_single_sparrow_missile( dummy_sparrow, heli );
    		RandomIntRange(3,8);
    	}
    }
    
    
  
}
kill_heli_engine_sounds()
{
    foreach( v in self )
    {
    	if ( IsDefined( v.script_noteworthy ) && v.script_noteworthy == "kill_engine_sound" )
    	{
        	v Vehicle_TurnEngineOff();
    	}
    }
}



backfill_helis()
{
			
	backfill_wave2_heli1 = spawn_vehicle_from_targetname_and_drive( "backfill_wave2_heli1");
	backfill_wave2_heli2 = spawn_vehicle_from_targetname_and_drive( "backfill_wave2_heli2");
	
	
	backfill_helis_array = [backfill_wave2_heli1,backfill_wave2_heli2];
	
	wait 5;
	thread final_wave_helis();
	
	
	thread javelin_target_set(backfill_helis_array, ( 0,0,0 ) );
	
	foreach (heli in backfill_helis_array)
	{
		heli thread unloading_backfill();
	}
	wait 10;
	
	
	thread front_ambient_helis_wave2();
	thread middle_ambient_helis_wave2();
	thread rear_ambient_helis_wave2();	
	
	
	//clean up drones on deck
	flag_wait("heli_ride_finished");
	
//	foreach (guy in level.drones_front_ally)
//	{
//		guy delete();
//	}
//	
//	
//	foreach (guy in level.drones_rear_ally)
//	{
//		guy delete();
//	}
	
	
	foreach (guy in level.rear_enemies)
	{
		guy delete();
	}

	
	front_enemy_vol = getent("amb_heli_enemy_battle_vol","targetname");
	guys = front_enemy_vol get_drones_touching_volume();
	foreach (guy in guys)
	{
		guy delete();
	}
		
}

unloading_backfill()
{
	
	self waittill( "unloaded" );
	
	enemies = GetAIArray( "axis" );
	enemy_left_vol = getent( "enemy_left_vol", "targetname" );
	final_enemy_vol = getent( "final_enemy_vol", "targetname" );
	enemy_right_vol = getent("dc1_enemy_vol2","targetname");
	
	flag_set ("final_wave_kick");
	
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && IsAlive( guy ) && guy IsTouching( enemy_left_vol ) )
		{
			guy SetGoalVolumeAuto( final_enemy_vol );	
		}
		else if	( IsDefined( guy ) && IsAlive( guy ) && guy IsTouching( enemy_right_vol ) )
		
		{
			guy SetGoalVolumeAuto( enemy_left_vol );
		}
		
	}
	
}

final_wave_helis()
{
	flag_wait ("final_wave_kick");
	
	final_wave_enemies = spawn_vehicles_from_targetname_and_drive( "final_wave_helis");
	activate_trigger_with_targetname("ally_move_final");
	wait 3;
	thread pop_that_smoke();
	
	wait 25;
	
	flag_set( "deck_combat_finished" );
		
	thread middle_ambient_helis_wave3();
	thread rear_ambient_helis_wave3();
	wait 10;
	
		
	thread dogfight();
	
	wait 5;
	thread redshirt_heli_runby();
	
}




//////////////////
//Drone Helis////
////////////////

front_ambient_helis_wave1()
{
	
	
	front_wave1= spawn_vehicles_from_targetname_and_drive( "front_background_helis_wave1");
	
	thread javelin_target_set( front_wave1, ( 0,0,0 ) );
	
	foreach (heli in front_wave1)
	{
		heli thread front_ambient_heli_drones_wave1(heli.script_parameters);
		
	}
	
}
middle_ambient_helis_wave1()
{
	
	
	middle_wave1= spawn_vehicles_from_targetname_and_drive( "middle_helis_wave1");
	
	thread javelin_target_set( middle_wave1, ( 0,0,0 ) );
	
	foreach (heli in middle_wave1)
	{
		heli thread middle_ambient_heli_drones_wave1(heli.script_parameters);
		
	}
	
}
rear_ambient_helis_wave1()
{
	rear_wave1= spawn_vehicles_from_targetname_and_drive( "rear_background_helis_wave1");
	
	thread javelin_target_set( rear_wave1, ( 0,0,0 ) );
	
	foreach (heli in rear_wave1)
	{
		heli thread rear_ambient_heli_drones_wave1( heli.script_parameters );
		
	}
	
}


front_ambient_helis_wave2()
{
	
	level.front_enemies = [];
	front_wave2= spawn_vehicles_from_targetname_and_drive( "ambient_helis_front");
	
	foreach (heli in front_wave2)
	{
		heli thread front_ambient_heli_drones_wave2(heli.script_parameters);
		
	}
	
}

middle_ambient_helis_wave2()
{
	level.middle_enemies = [];
	middle_wave2= spawn_vehicles_from_targetname_and_drive( "middle_helis_wave2");
	
	foreach (heli in middle_wave2)
	{
		heli thread middle_ambient_heli_drones_wave2(heli.script_parameters);
		
	}
}
	
rear_ambient_helis_wave2()
{
	
	level.rear_enemies = [];
	rear_wave2= spawn_vehicles_from_targetname_and_drive( "ambient_helis_rear");
	
	foreach (heli in rear_wave2)
	{
		heli thread rear_ambient_heli_drones_wave2( heli.script_parameters );
		
	}
	
}

middle_ambient_helis_wave3()
{
	
	middle_wave3= spawn_vehicles_from_targetname_and_drive( "middle_helis_wave3");
	
	foreach (heli in middle_wave3)
	{
		heli thread middle_ambient_heli_drones_wave3(heli.script_parameters);
		
	}
}
	
rear_ambient_helis_wave3()
{
	
	
	rear_wave3= spawn_vehicles_from_targetname_and_drive( "ambient_helis_rear3");
	
	foreach (heli in rear_wave3)
	{
		heli thread rear_ambient_heli_drones_wave3( heli.script_parameters );
		
	}
	
}




/////////////////////////////
//// Background Vehicles ////
////////////////////////////

 background_helis()
{
	array_spawn_function_targetname( "background_helis", ::heli_fast_explode );
 	array_spawn_function_targetname( "background_helis", ::vehicle_randomly_explode_after_duration, 60, 20, 30 );
 	thread vehicles_loop_until_endon( "background_helis", "heli_ride", 3, 10 );

 	
}
 fly_by_helis()
{
 	array_spawn_function_targetname( "ambient_fly_over_helis", ::javelin_target_set_solo, (0,0,0) );
 	array_spawn_function_targetname( "ambient_fly_over_helis", ::heli_fast_explode );
 	array_spawn_function_targetname( "ambient_fly_over_helis", ::vehicle_randomly_explode_after_duration, 10, 10, 20 );
 	thread vehicles_loop_until_endon( "ambient_fly_over_helis", "heli_ride", 2, 4 );
}
background_jets()
{		
	thread background_jets_shot_down();
	thread vehicles_loop_until_endon( "jet_dogfighter_enemy_amb1", "heli_ride", 4, 15 );
	thread vehicles_loop_until_endon( "jet_dogfighter_ally_amb1", "heli_ride", 4, 15 );
	thread vehicles_loop_until_endon( "background_jet_missile_attack", "heli_ride", 4, 15 );
	thread vehicles_loop_until_endon( "jet_dogfighter_enemy_amb2", "heli_ride", 6, 15 );
	thread vehicles_loop_until_endon( "jet_dogfighter_ally_amb2", "heli_ride", 6, 15 );
}
background_jets_shot_down()
{
	flag_wait("background_jet_shot");
	
	jet_boom = getent("jet_dogfighter_enemy_amb2","targetname");
	playfx( level._effect[ "vehicle_explosion_mig29" ], jet_boom.origin);
	
	
}

dogfight()
{
	dogfight_bad = spawn_vehicle_from_targetname_and_drive( "jet_dogfighter_enemy");
	dogfight_good = spawn_vehicle_from_targetname_and_drive( "jet_dogfighter_ally");
	
	flag_wait("dogfight_death");
	
	playfx( level._effect[ "vehicle_explosion_mig29" ], dogfight_bad.origin);
	
	
	
	
}


/*---------------------------------------------*/
/*------------------ Drones  ------------------*/
/*---------------------------------------------*/

///enemy drones
rear_ambient_heli_drones_wave1( script_parameters )
{
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 4; //This is the number of nodes they can go to.
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "rear_paths", node_index );
			node_index ++;	
			if( node_index > node_max )
			{
				node_index = 1;
			}				
		}
	}
	
	
	
	
	
}
rear_ambient_heli_drones_wave2( script_parameters )
{
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 4; //This is the number of nodes they can go to.
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "rear_paths", node_index );	
			node_index ++;
			if( node_index > node_max )
			{
				node_index = 1;
			}				
		}
	}
	
	
}
rear_ambient_heli_drones_wave3( script_parameters )
{
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 4; //This is the number of nodes they can go to.
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "rear_paths", node_index );	
			node_index ++;
			if( node_index > node_max )
			{
				node_index = 1;
			}				
		}
	}
	
	
}

middle_ambient_heli_drones_wave1(script_parameters)
{
	
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 6; //This is the number of nodes they can go to.
	
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "middle_paths", node_index );
			node_index ++;
			if( node_index > node_max )
			{
				node_index = 1;
			}
				
		}
	}
}	

middle_ambient_heli_drones_wave2(script_parameters)
{
	
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 6; //This is the number of nodes they can go to.
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "middle_paths", node_index );
			node_index ++;
			if( node_index > node_max )
			{
				node_index = 1;
			}			
		}
	}
}
middle_ambient_heli_drones_wave3(script_parameters)
{
	
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 6; //This is the number of nodes they can go to.
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "middle_paths", node_index );
			node_index ++;
			if( node_index > node_max )
			{
				node_index = 1;
			}			
		}
	}
}	

front_ambient_heli_drones_wave1(script_parameters)
{
	
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 4; //This is the number of nodes they can go to.
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "front_paths", node_index );
			node_index ++;
			if( node_index > node_max )
			{
				node_index = 1;
			}				
		}
	}
}

front_ambient_heli_drones_wave2(script_parameters)
{
	AssertEx( IsDefined( script_parameters ), "Must have script_parameters set on vehicle" );
	
	self waittill( "unloading" );
	
	node_index = 1;
	node_max = 4; //This is the number of nodes they can go to.
	//vol = getent( "rear_drone_enemies_vol", "targetname" );
		
	enemies = GetEntArray( script_parameters, "script_noteworthy" );
	foreach ( guy in enemies )
	{
		if ( IsDefined( guy ) && guy.classname == "script_model" ) //&& guy IsTouching(vol ) )
		{
			guy thread drone_unload( "front_paths", node_index );
			node_index ++;
			if( node_index > node_max )
			{
				node_index = 1;
			}				
		}
	}
}



////////////////////////
////ally drones////////
//////////////////////


front_ambient_ally_drones()
{
	
	drone_spawner = getentarray("ally_front_drones", "targetname");
	foreach( spawner in drone_spawner )
	{
		thread drone_respawner( spawner, "heli_ride" );
	}

}
middle_ambient_ally_drones()
{
	drone_spawner = getentarray("ally_middle_drones", "targetname");
	foreach( spawner in drone_spawner )
	{
		thread drone_respawner( spawner, "heli_ride" );
	}	
}

rear_ambient_ally_drones()
{
	drone_spawner = getentarray("ally_rear_drones", "targetname");
	foreach( spawner in drone_spawner )
	{
		thread drone_respawner( spawner, "heli_ride" );
	}	
}
final_wave_ambient_ally_drones()
{
	drone_spawner = getentarray("ally_finalwave_drones", "targetname");
	foreach( spawner in drone_spawner )
	{
		thread drone_respawner( spawner, "heli_ride" );
	}	
}
redshirt_heli_runby()
{
	flag_wait("blackhawk_ally_shoot_stern");
	
	drone_spawner = getentarray("redshirt_heli_runby", "targetname");
}



////////////////
//Drone Script// 
///////////////


drone_unload( path_area, node_index )
{
	self waittill( "jumpedout" );

	self.target = path_area + node_index;
	
	self maps\_drone::drone_init();
	//self thread maps\_drone::drone_move();
	self thread randomly_kill_drone();
	self waittill( "death" );
	self maps\_drone::drone_drop_real_weapon_on_death();
	
}
randomly_kill_drone()
{
	wait RandomFloatRange(8,16);
	self DoDamage(self.health, self.origin);
}

drone_respawner( spawner, endon_flag )
{
	while ( !flag( endon_flag ) )
	{
		guy = spawner spawn_ai( true );
		wait RandomFloatRange(8,20);
		if ( IsDefined( guy ) )
		{
			guy DoDamage(guy.health, guy.origin);
		}
		wait RandomFloatRange(8,20);
	}
}


/*---------------------------------------------*/
/*------------------ JAVELIN ------------------*/
/*---------------------------------------------*/

javelin_target_set( enemy_helis, offset )
{
	foreach(heli in enemy_helis)
	{
		target_set( heli, offset );
		target_setJavelinOnly( heli, true );
		Target_SetAttackMode( heli, "direct" );
		heli thread javelin_target_death();
	}
}

javelin_target_set_solo( offset )
{
	target_set( self, offset );
	target_setJavelinOnly( self, true );
	Target_SetAttackMode( self, "direct" );
	self thread javelin_target_death();
}

javelin_target_death()
{
	self waittill( "death" );
	if( isdefined( self ) && isAlive( self ) )
		Target_Remove( self );
}

//javelin_guy_setup()
//{
//	
//	self waittill("goal");
//	
//	self.animname = "generic";
//    self anim_reach_solo(self,"javelin_idle_a");
//	self.struct = getstruct("ally_javelin_postition","targetname");
//    self.struct thread anim_loop_solo( self, "javelin_idle_a", "stop_loop" );
//    self Attach( "weapon_javelin_sp", "TAG_INHAND" );     
//    self.struct notify( "stop_loop" );
//    self thread anim_single_solo( self, "javelin_fire_a" );
//    self waittillmatch( "single anim", "fire_weapon" );
//    
//    javelin_target = Getent( "jav_strike_target", "targetname" );
//    newMissile       = MagicBullet( "javelin_dcburn", self GetTagOrigin( "tag_inhand" ), javelin_target.origin );
////    PlayFXOnTag( getfx( "javelin_muzzle" ), self, "TAG_FLASH" );
//    newMissile Missile_SetTargetEnt( javelin_target );
//    newMissile Missile_SetFlightmodeDirect();
//    self waittillmatch( "single anim", "end" );
//}
//javelin_heli_blowup()
//{
//	while (1)
//	{
//		self waittill( "damage", amount, attacker, direction_vec, point, type );
//		if (type == "MOD_PROJECTILE"|| type == "grenade_explode" )
//		{
//			level.ally_jav_heli kill();
//		}
//	}
//		
//}


/*------------------------------------------------------------------------*/
/*------------------ Activate Kill triggers for Player -------------------*/
/*------------------------------------------------------------------------*/

Kill_trigger_front()
{
	flag_wait("warning_1");
	IPrintLnBold("Adam, where are you going?");
	
	flag_wait("warning_2");
	IPrintLnBold("Get back here and fight now!");
	level.player play_sound_on_entity( "carrier_gs1_fastmoversincomiiiiing" );
	
	flag_wait("death_time");
	level.player play_sound_on_entity( "a10p_missile_launch"  );
	
	startshoot           = level.player.origin + (0,0,50);
    targetshoot           = level.player.origin;
    MagicBullet( "rpg_straight", startshoot, targetshoot);
    level.player Kill();

    
}

Kill_trigger_rear()
{
	flag_wait("warning_1_rear");
	IPrintLnBold("Adam, where are you going?");
	
	
	flag_wait("warning_2_rear");
	IPrintLnBold("Get back here and fight now!");
	level.player play_sound_on_entity( "carrier_gs1_fastmoversincomiiiiing" );
	
	flag_wait("death_time_rear");
	level.player play_sound_on_entity( "a10p_missile_launch"  );
	
	startshoot           = level.player.origin + (0,0,50);
    targetshoot           = level.player.origin;
    MagicBullet( "rpg_straight", startshoot, targetshoot);
    level.player Kill();

}

/*----------------------------------------------*/
/*------------------ Effects -------------------*/
/*----------------------------------------------*/



pop_that_smoke()
{
	add_dialogue_line("Wasp 1", "Inbound, Mark target with smoke for gun run ");
	add_dialogue_line("Hesh", "Poping smoke, Hold this area ");
	
	smoke_tag		  = spawn_tag_origin();
	green_smoke = getent ("pop_smoke_fx_ref","targetname");
	smoke_tag.origin = green_smoke.origin;
	smoke_tag.angles = green_smoke.angles;
	smoke_tag.angles += (-90,0,0);
	PlayFXOnTag( level._effect[ "signal_smoke_green" ],smoke_tag, "tag_origin");
	flag_wait("gunner_death_finished");
	StopFXOnTag( level._effect[ "signal_smoke_green" ],smoke_tag, "tag_origin");
		
	
}

