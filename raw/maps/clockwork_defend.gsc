#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\clockwork_code;

NUM_BETTYS = 4;
NUM_SHOCKWAVES = 2;
NUM_THROWBOTS = 3;

clockwork_defend_pre_load()
{

	PrecacheItem( "smoke_grenade_american" );
	//PrecacheItem( "smoke_grenade_fast" );
	
	flag_init( "defend_finished" );
	flag_init( "defend_combat_finished" );
	flag_init( "ally1_on_podium" );
	flag_init( "ally2_on_podium" );
	flag_init( "player_on_podium" );
	flag_init( "def_in_riot_gear" );
	flag_init( "def_wave1_done" );
	flag_init( "def_wave2_done" );
	flag_init( "def_wave3_done" );
	flag_init( "def_scientist_intro_complete" );
	flag_init( "defend_start_waves" );
	flag_init( "defend_used_duffel" );
	flag_init( "defend_used_sentry" );
	flag_init( "defend_used_mines" );
	flag_init( "defend_sentry_placed" );
	flag_init( "get_turret" );
	flag_init( "get_shockwave" );
	flag_init( "get_teargas" );
	flag_init( "get_proximity_mine" );
	flag_init( "trickle_spawn_all" );
	flag_init( "disallow_interrupt_baker" );
	flag_init( "defend_baker_in_position");
	flag_init( "defend_smoke_thrown" );
	flag_init( "wave2_pre_dialog" );
	flag_init( "player_out_of_defend" );
	flag_init( "cypher_in_position" );
	flag_init( "cypher_baker_interaction_done" );
	flag_init( "show_turret_pickup" );
	flag_init( "defend_timeto_hide_player_bag" );
	flag_init( "defend_allies_smoke_thrown" );
	flag_init( "other_allies_post_vault" );
	flag_init( "cypher_defend_close_door" );
	
	
	
	/*
	ent = createOneshotEffect( "fx/lights/lights_strobe_red_dist_max_small" );
	//ent set_origin_and_angles( (-26892, -1644, 1597), (270, 330, 0) );
	ent.v[ "origin" ] =  (-26911, -1653, 1547);// above the door
	//ent.v[ "origin" ] =  (-29409, -988, 1440);// in the doorway
	ent.v[ "angles" ] = (270, 330, 0);

	ent = createOneshotEffect( "fx/lights/lights_strobe_red_dist_max_small" );
	//ent set_origin_and_angles(,  );
	ent.v[ "origin" ] =  (-29262, -1019, 1547); // above the door.
//	ent.v[ "origin" ] =  (-26744, -1703, 1440); // in the doorway
	ent.v[ "angles" ] = (270, 330, 0);
*/
}

setup_defend_blowdoors1()
{
	level.override_check = 1;
    level.timer_override_check = level.override_check;
	
	setup_defend_plat("defend_plat");
}
setup_defend_blowdoors2()
{
	level.override_check = 2;
    level.timer_override_check = level.override_check;
	setup_defend_plat("defend_plat");
}
setup_defend_fire_blocker()
{
	level.override_check = 3;
    level.timer_override_check = level.override_check;
	setup_defend_plat("defend_plat");

	
}

setup_defend_plat(override_spawner)
{
	level.start_time = gettime();
    setup_player();
    level.start_point = "defend_plat";
    level.allies						= [];
	level.allies[ level.allies.size ]	= spawn_ally( "baker",override_spawner  );
	level.allies[ level.allies.size -1 ].animname = "baker";
	//level.scr_sound[ "baker" ] =[];
	level.allies[ level.allies.size ]	= spawn_ally( "keegan",override_spawner );
	level.allies[ level.allies.size-1 ].animname = "keegan";
	//level.scr_sound[ "keegan" ] =[];
	level.allies[ level.allies.size ]	= spawn_ally( "cipher",override_spawner );
	level.allies[ level.allies.size-1 ].animname = "cypher";
	//level.scr_sound[ "cypher" ] =[];
	
	setup_dufflebag_anims();
//    spawn_allies();
	vision_set_changes("clockwork_indoor", 0);
	flag_set("interior_cqb_finished");
	flag_set("cqb_guys7");
	flag_set("to_cqb");
    /#
    //level.defend_quick = 1;
    
    #/

	set_blow_doors_vis(true);
    
	defend_begin_common();
	array_thread( level.allies, ::handle_ally_bag_vis );
    flag_set( "defend_player_drop_bag" );
	
	//flag_set( "show_turret_pickup");
	delayThread(1, ::defend_platform);
    thread maps\clockwork_audio::checkpoint_defend();

    
}


begin_defend_plat()
{

	flag_wait( "defend_finished" );


}
begin_defend_blowdoors1()
{

	flag_wait( "defend_finished" );
}
begin_defend_blowdoors2()
{

	flag_wait( "defend_finished" );
}
begin_defend_fire_blocker()
{

	flag_wait( "defend_finished" );
	/*// sjp comment out minimap.
	minimap_off();
	*/
    flag_set( "defend_flasher_struct" );
}


setup_defend()
{
    setup_player();
    level.start_point = "defend";
    spawn_allies();
	vision_set_changes("clockwork_indoor", 0);
	flag_set("interior_cqb_finished");
	flag_set("cqb_guys7");
	flag_set("to_cqb");
    /#
    //level.defend_quick = 1;
    
    #/

    
    
    thread maps\clockwork_audio::checkpoint_defend();
    
}

defend_begin_common()
{
//	thread defend_enemy_radio_chatter();
	setup_blockers();
	thread handle_platform_blockers();
	
	safe_disable_trigger_with_targetname("defend_pickup_backups_trigger" );
	
	
	
	thread maps\clockwork_fx::turn_effects_on("defend_flasher_struct","fx/lights/lights_strobe_red_dist_max_small");
	level.moveup_doublespeed = false;
	set_bags_invisible();
	level.allies[0].animname = "baker";
	level.allies[1].animname = "keegan";
	level.allies[2].animname = "cypher";
	
//	if( IsDefined( level.pip) && level.pip.enable )
//		thread maps\clockwork_pip::pip_disable();
	
	set_bag_objective_visibility( 0 );
	
	thread maps\clockwork_audio::defend_start();
    thread defend_end();
	trigger = GetEnt( "defend_duffle_bag_turret_trigger", "targetname" );
	trigger trigger_off();
	level.defend_save_safe = true;
    
    thread listen_for_use_turret_duffle_bag();
    thread listen_for_use_shockwave_duffle_bag();
    thread listen_for_use_teargas_duffle_bag();
    thread listen_for_use_proximity_duffle_bag();
    thread handle_cypher_backups();
    	
    thread handle_animated_duffelbags();
}

begin_defend()
{
	//thread maps\clockwork_interior::cqb_PA();
	defend_begin_common();
	thread autosave_by_name( "defend_start" );
	
	set_blow_doors_vis(false);
	stop_exploder(850);
	
	battlechatter_off( "allies" );
	battlechatter_off( "axis" );
	
    thread defend_intro();

    level.player SetActionSlot( 1, "" ); // Remove NVG
    
    //disable the pickup turret trigger until we show the objective.
     //Wait for this section to finish.
    flag_wait( "defend_finished" );

}
watch_player_wake_scientists()
{
	level endon( "defend_shoot_air" );
	
	//wait until the player gets near the main room before we listen for his shot.
	while ( !flag( "defend_player_fail_leaving" ) )
		wait 0.05;
		  
	
	level.player waittill( "weapon_fired" );
	level.player_woke_scientists = true;
	level notify( "defend_shoot_air" );
	
	
}

defend_intro()
{
	flag_wait( "defend_vo_intro" );
	
	
	thread watch_player_wake_scientists();
		
	thread spawn_scientists();

	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_timecheck" );
	wait 1;
	radio_dialog_add_and_go( "clockwork_diz_onschedule" );
	

    
    flag_wait( "defend_room_entered" );
    music_play("clkw_enter_lab");
//    level.allies[0] gun_remove();
//    level.allies[0] forceUseWeapon( "ak47", "primary" );
//    level.allies[0] gun_recall();
    
    if( !IsDefined( level.player_woke_scientists ) )
    {
	    shoot_struct  = getstruct( "defend_animate_to_me", "targetname" );
	    shoot_anim_origin = spawn( "script_origin", shoot_struct.origin + (0,0,12) );
		shoot_anim_origin.angles = shoot_struct.angles;
		//shoot_anim_origin.angles = (0,0,0);
	    shoot_anim_origin anim_reach_solo( level.allies[0] , "baker_fire_air" );
	    shoot_anim_origin thread anim_single_solo( level.allies[0] , "baker_fire_air" );
		//thread blowdoors("door_blow_north");//test code to trigger earlier in level.
//	    lights = GetEntArray( "defend_northdoor_lights", "targetname" );
//		thread flicker_lights(lights);
 
	    
	    //shoot_anim_origin delayCall( 10,::Delete );
    }
    //IPrintLnBold("started wait");
    wait( 1.5);
    //IPrintLnBold("Notifying shot.");
	level notify( "defend_shoot_air" );
    
//	thread doors_explode();
    

    
    
	level.allies[0] thread char_dialog_add_and_go( "clockwork_bkr_outnow" );

	wait 2;	
	level.allies[0] thread char_dialog_add_and_go( "clockwork_bkr_preppingfortransfer" );
	
    
//	wait 2;
    
	
//	safe_activate_trigger_with_targetname( "def_allies_to_dropoff" );
	array_thread( level.allies, ::handle_ally_bag_vis );
	
	
	wait 1;
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_commandplatform" );
	
	level notify( "begin_defend_radio_chatter");
    
	//temp test code.
	//thread handle_fire_blocker( 1 );
	
	
	thread nag_podium();
	thread set_bag_objective_visibility( 1 );
    flag_wait( "player_on_podium");

	thread watch_player_leave_area();
    
    flag_wait( "defend_player_drop_bag" );
	set_blow_doors_vis(true);
    
    thread watch_placed_sentry();
    thread maps\clockwork_audio::command_platform_bag_player();
	
	set_bag_objective_visibility( 0 );
	defend_platform();
}
	

defend_platform()
{
	level.missileGlassShatterVel = GetDvarFloat( "missileGlassShatterVel" );
	SetSavedDvar( "missileGlassShatterVel", 0 );

	player_drop_bag();
	
	thread autosave_by_name( "defend_bag_dropoff" );
	
	
	

    
    
    trig = GetEnt( "defend_player_drop_bag_trigger", "targetname" );
    if( IsDefined( trig ) )
    	trig trigger_off();


    
	flag_wait( "defend_baker_in_position");

	//turn off fx glows on helipad
	flag_set( "ch_industrial_light_02_on_red" );
	flag_set( "clk_cargoship_wall_light_on" );
	stop_exploder(200);

//	flag_set( "disallow_interrupt_baker" );
	
	
	
//	flag_clear( "disallow_interrupt_baker" );
    
//    flag_wait_or_timeout( "defend_sentry_placed", 45 );
    waittime =[];
	waittime[0]=40;
	waittime[1]=15;
	waittime[2]=12;
    if( !isdefined(level.override_check))
    {
    thread trickle_spawn( 70, "defend_wave1", waittime );
    thread trickle_spawn( 70, "defend_wave1_uppers", waittime );
	
    quickwaittime= [];
	quickwaittime[0]=40;
		quickwaittime[1]=17;
	quickwaittime[2]=6;
	
    thread trickle_spawn( 70, "defend_wave1_quick", quickwaittime );
    if( !IsDefined( level.defend_quick ) )
    {
	    wait 5;
	    	
		level.allies[0]  char_dialog_add_and_go( "clockwork_mrk_theyllbefollowingus" );
	
		//break baker out of his table loop.
		struct = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	    struct notify( "baker_stop_table_loop" );
			//safe_activate_trigger_with_targetname( "def_baker_cover_atrium");
			//safe_activate_trigger_with_targetname( "defend_platform_color");
			
		//	wait 0.2;
	    	level.allies[ 0 ] disable_ai_color();
			level.allies[ 0 ].fixednode	 = 0;
			level.allies[ 0 ].goalraidus = 64;
	    	level.allies[ 1 ] disable_ai_color();
			level.allies[ 1 ].fixednode	 = 0;
			level.allies[ 1 ].goalraidus = 64;
			level.allies[ 1 ] AllowedStances( "crouch", "prone" );
			level.allies[ 0 ] AllowedStances( "crouch", "prone" );

			vol = GetEnt( "def_ally_middle", "targetname" );
			volrev = GetEnt( "defend_ally_split", "targetname");
			level.allies[ 0 ] SetGoalVolumeAuto( vol );
			level.allies[ 1 ] SetGoalVolumeAuto( volrev );
	    
	    wait 2;
	 
	    if( !flag( "defend_used_mines" ) )
	    {
			level.allies[0]  char_dialog_add_and_go( "clockwork_bkr_minesfrombag" );
	    }
	
		level.allies[0]  char_dialog_add_and_go( "clockwork_bkr_30secsdefenses" );
    }
    }
    else
    {
		struct = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	    struct notify( "baker_stop_table_loop" );
	    
	    level.allies[ 0 ] disable_ai_color();
    	level.allies[ 1 ] disable_ai_color();
	
    	wait 0.3;
		level.allies[ 1 ] AllowedStances( "crouch", "prone" );
		level.allies[ 0 ] AllowedStances( "crouch", "prone" );
	    
	    vol = GetEnt( "def_ally_middle", "targetname" );
		volrev = GetEnt( "defend_ally_split", "targetname");
		level.allies[ 0 ] SetGoalVolumeAuto( vol );
		level.allies[ 1 ] SetGoalVolumeAuto( volrev );

    	flag_set("def_wave1_done");
    }
    delayThread(14, maps\clockwork_audio::defend_combat);
    
	thread defend_start();
    
	//test the sides blowing up.
//	level notify( "blow_fire_blocker" );
	
}

watch_player_leave_area()
{
	//wait until the player has gone up the elevator so they cannot go back to the rotunda.
	level endon( "elevator_open" );
	
	flag_clear( "defend_player_fail_leaving" );
	
	last_warning = GetTime();
	
	
	while( 1 )
	{
	
		flag_wait( "defend_player_warn_leaving" );
		
		while( flag( "defend_player_warn_leaving" ) )
		{
			if(last_warning < GetTime() )
			{
				thread add_dialogue_line( "Baker", "Get Back Here! You must defend Cypher" );
				
				last_warning = GetTime() + 10000;
				
			}
			if( flag( "defend_player_fail_leaving" )) 
			{
				IPrintLnBold( &"CLOCKWORK_QUOTE_LEFT_TEAM" );
				wait 1;
				MissionFailed();	
				wait 10;
			}
			wait 0.05;
			
		}
		
	}
	
}
	

player_drop_bag()
{
    
    static_player_bag = GetEnt( "defend_duffle_bag_turret", "targetname" );
    
   	player_arms = spawn_anim_model( "player_rig" );
   	anim_player_bag = spawn_anim_model( "player_bag" );
//   	IPrintLnBold("NEW ANIM STRUCT 2");
   	
	root_struct = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	
	root = spawn_tag_origin();
	
	root.origin = root_struct.origin;
	root.angles = root_struct.angles;
	
	player_arms LinkTo( root, "tag_origin", ( 0, 0, 0 ), ( 0, 0, 0 ) );
	
	level.player_bag.animname = "player_bag";

	
	
	
	root anim_first_frame_solo( player_arms, "defend_bagdrop" );


	drop_actors = [];
	drop_actors[0] = player_arms;
	drop_actors[1] = anim_player_bag;
	player_arms hide();
	anim_player_bag hide();
	level.player SetStance( "stand" );
	level.player AllowCrouch( false );
	level.player AllowProne( false );
	level.player PlayerLinkToBlend( player_arms, "tag_player", 0.3 );
	level.player DisableWeapons();
//	level.player PlayerLinkToAbsolute( player_arms, "tag_player" );ss
	//root thread anim_single( drop_actors, "defend_bagdrop" );
	root thread anim_single( drop_actors, "defend_bagdrop" );
	wait 0.3;
	
	player_arms Show();
	anim_player_bag Show();
	flag_wait( "defend_timeto_hide_player_bag" );
	
	//wait(0.8);
	root anim_first_frame_solo( level.player_bag, "defend_world_player_bag" );
	
	drop_actors[0] waittillmatch( "single anim", "end" );
	
	
	level.player Unlink();
	player_arms Delete();
	level.player EnableWeapons();
	level.player EnableOffhandWeapons();
	level.player AllowCrouch( true );
	level.player AllowProne( true );
//	static_player_bag.origin = anim_player_bag.origin;
//	static_player_bag.angles = anim_player_bag.angles;
	anim_player_bag Delete();
    set_bag_visibility( "defend_duffle_bag_turret" );
	flag_wait( "show_turret_pickup" );
	if( !flag( "defend_used_sentry" ) )
    {
		level.sentry_obj Show();
    
    	trigger = GetEnt( "defend_duffle_bag_turret_trigger", "targetname" );
		trigger trigger_on();
	}
	flag_wait( "cypher_baker_interaction_done" );
    
//	level.allies[0]  thread char_dialog_add_and_go( "clockwork_bkr_sentryturret" );


    
}


handle_ally_bag_vis()
{
	animate_to = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	self PushPlayer( true );
	
	animate_to anim_reach_solo(self, "defend_bagdrop" );
	flag_wait( "player_on_podium" );
	if (self.animname == "keegan")
    {
        thread maps\clockwork_audio::command_platform_bag_keegan();
    }
	if (self.animname == "cypher")
    {
        thread maps\clockwork_audio::command_platform_bag_cypher();
    }
	if (self.animname == "baker")
    {
        thread maps\clockwork_audio::command_platform_bag_baker();
    }
	animate_to anim_single_solo(self, "defend_bagdrop" );
	if (self.animname == "keegan")
	{
	
	//	root waittillmatch("single anim","end");
			
	    level.allies[ 1 ] enable_ai_color();
		safe_activate_trigger_with_targetname( "def_keegan_during_defend" );
		level.allies[ 1 ] PushPlayer( false );
	}

}

bag_vis_callback( ally )
{
	if( ally.animname == "cypher" )
		ally thread cipher_vo();

		
//	self waittill( "defend_bagdrop", notetrack );
//	self waittill( "single anim", notetrack );
//	IPrintLnBold(" got callback: " + ally.animname );
	root = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	
	switch( ally.animname )
	{
		case "cypher":
			root anim_first_frame_solo( level.bags[2], "defend_world_cypher_bag" );
			level.allies[ 2 ]gun_remove	  (	 );
			level.allies[ 2 ]set_ignoreall( true );
			level.allies[ 2 ]set_ignoreme( true );
			level.allies[ 2 ]PushPlayer	 ( true );

			break;
		case "keegan":
			root anim_first_frame_solo( level.bags[1], "defend_world_keegan_bag" );
	
			break;
		case "baker":
			root anim_first_frame_solo( level.bags[0], "defend_world_baker_bag" );
			break;
		default:
			//player
			flag_set( "defend_timeto_hide_player_bag" );
			return;
	}
	//drop the bag on the table
	ally thread set_bag_visibility( ally.bag_name );
	wait 0.1;
	ally hide_dufflebag();
//	wait 1 + Randomfloat( 2 ) ;
	ally  waittill( "single anim", notetrack );
//	IPrintLnBold(" got waittill: " + ally.animname + " notetrack: " + notetrack);
	root = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	
	switch( ally.animname )
	{
		case "cypher":
			thread cipher_podium();
			break;
		case "keegan":
			root waittillmatch("single anim","end");
			
		    level.allies[ 1 ] enable_ai_color();
			safe_activate_trigger_with_targetname( "def_keegan_during_defend" );
			level.allies[ 1 ] PushPlayer( false );
			
			break;
		case "baker":
			flag_set( "defend_baker_in_position");
			
			root thread anim_loop_solo( level.allies[0],"table_stand_idle",  "baker_stop_table_loop" );
			//level.allies[0] thread amb_anim_goal( "table_stand_idle", "defend_player_drop_bag_location_mod", "baker_stop_table_loop" );
			wait 3;
			level.allies[ 0 ] PushPlayer( false );
			break;
	}
}



watch_placed_sentry()
{
	thread nag_sentry();
	flag_wait( "defend_used_sentry" );
	
	wait 0.25;
	level.player waittill ( "sentry_placement_finished" );
	flag_set( "defend_sentry_placed" );
	thread handle_autoturret_chatter();
}

nag_sentry()
{
	flag_wait( "cypher_baker_interaction_done" );
	
	wait 15;
	if( !flag( "defend_used_sentry" ) )
	{
		
		level.allies[0] thread char_dialog_add_and_go( "clockwork_bkr_sentryturretfrombags" );
	}
}


nag_podium()
{
	wait 5;
	while( 1 )
	{
		wait 9;
		if( flag( "player_on_podium" ) )
			break;
		level.allies[0] char_dialog_add_and_go( "clockwork_bkr_getuphere" );
		wait 5;
	}
	
	while( !flag( "defend_player_drop_bag" ) )
	{
		wait 6;
		level.allies[0] char_dialog_add_and_go( "clockwork_bkr_tableoverhere" );
		wait 9;
		
}

}

	
defend_start()
{
    
    thread place_defenses();
    
    thread handle_defend_waves();
    
}

cipher_vo()
{
	flag_waitopen( "disallow_interrupt_baker" );
	level.allies[ 2 ] PushPlayer( true );
	delayThread(1, ::flag_set, "show_turret_pickup" );
	
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_computerbank" );
	wait 0.5;
	
	level.allies[2] char_dialog_add_and_go( "clockwork_cyr_need2minutes" );
	wait 0.5;
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_defensiveposition" );
	


	defend_cypher = obj( "defendcypher" );
	
//	obj_position = level.allies[2].origin + ( 0, 0, 72 );

	Objective_Add( defend_cypher, "active" );
	Objective_Current( defend_cypher );
//	Objective_Position( defend_cypher, obj_position);
//	Objective_SetPointerTextOverride( defend_cypher, &"CLOCKWORK_PROTECT" );

	wait 1;
	
	flag_wait( "cypher_in_position" );
	/*// sjp comment out minimap.
	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_securityoverhead" );
	
	level.allies[2] char_dialog_add_and_go( "clockwork_cyr_onit" );
	
	wait 1;
	
	minimap_on();
	*/

	flag_set( "cypher_baker_interaction_done" );
//	wait 4;
//	level.allies[0] char_dialog_add_and_go( "clockwork_bkr_protectcypher" );
	wait 4;
	thread download_timer();


	flag_wait( "defend_combat_finished" );
	
	Objective_Delete( defend_cypher );




}

	
cipher_podium()
{
 //   flag_wait( "ally2_on_podium" );


	
//	laptop = GetEnt( "def_cipher_hack", "targetname" );
//	laptop anim_reach_solo(level.allies[ 2 ] , "laptop_sit_runin" );
	
//	laptop anim_single_solo( level.allies[ 2 ] , "laptop_sit_runin" );
//	animate_to = spawn( "script_origin", level.allies[ 2 ].origin );//+ (0,0,8) );
//	animate_to.angles = (0,0,0);

		
	
	animate_to = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	
	animate_to thread anim_loop_solo( level.allies[ 2 ] , "laptop_sit_idle_calm", "stop_hacking" );
	flag_set( "cypher_in_position" );
	level.allies[ 2 ] PushPlayer( false );
	
}

	


place_defenses()
{
    thread listen_for_use_multi_turret();
    
}
handle_defend_saves( last_save_time )
{
	level endon( "defend_combat_finished" );

	save_num = 1;
	save_every = 20000;
	while( 1 )
	{
		last_time = GetTime() - last_save_time;
		if(last_time < save_every )
		{
			wait((save_every - last_time) / 1000);
			
		}
		else 
			wait 1;
		if( level.defend_save_safe && !flag( "game_saving" ))
		{
			if ( !isDefined( level.curAutoSave ) )
			{
				last_success = 1;

			}
			else
			{
				 last_success =level.curAutoSave;
			}
			savename =  "defend_ongoing" + save_num ;
			save_started = GetTime();
			thread autosave_by_name( savename );
			save_num++;

			//Wait until we have saved our game.
			flag_wait( "game_saving" );
			flag_waitopen("game_saving" );
			level notify("stop_watch_abandon_save");
			save_ended = GetTime();
			
			if(level.curAutoSave > last_success)
			{
				last_save_time = save_ended;
//				IPrintLnBold( savename +" Success in " + ((save_ended- save_started)/1000) + " seconds.");
			}
			/*
			else
			{
				IPrintLnBold( savename +" FAILED in " + ((save_ended- save_started)/1000) + " seconds.");
			}
			*/
		}
	}
}



handle_defend_waves()
{
	battlechatter_on( "allies" );
	battlechatter_on( "axis" );
	
	thread monitor_enemies_in_pods();
	if ( !IsDefined( level.override_check ) )
	{
    thread defend_wave_1();
	}
	else
	{
    	thread handle_backfill();
	}
    thread open_vault_door();

    
    flag_wait_either( "def_wave1_done", "defend_combat_finished" );
	thread autosave_by_name( "defend_wave1" );
    wait 0.1;
    thread handle_defend_saves( GetTime() );
	//level notify( "blow_fire_blocker" );
    
    /*
    
	if( !flag( "defend_combat_finished") )
	{
    	thread defend_wave_2();
	}
	
    flag_wait_either( "def_wave2_done", "defend_combat_finished" );
	thread autosave_by_name( "defend_wave2" );
    wait 0.1;
	if( !flag( "defend_combat_finished") )
	{
    	thread defend_wave_3();
	}
	else
	{
		flag_set( "def_wave3_done" );
	}
		*/
    flag_wait_either( "def_wave3_done", "defend_combat_finished" );
	thread autosave_by_name( "defend_wave3" );
    wait 0.1;
	
	flag_wait( "defend_combat_finished" );
	
	SetSavedDvar( "missileGlassShatterVel", level.missileGlassShatterVel );
//    thread add_dialogue_line( "Cipher", "Download complete. Let's move." );
//    wait 2;
//	flag_set( "defend_combat_finished" );


}

defend_start_player_shield()
{
	level.player EnableInvulnerability();
	wait 15;
	level.player DisableInvulnerability();
	
}


defend_wave_1()
	{
    	
	level endon( "defend_combat_finished" );
    	
   // dynamic_wait_wave( 1 );
    wait 27;    
	
		
	level.player thread radio_dialog_add_and_go( "clockwork_mrk_tangoesincomingdownthe" );
	wait 2;
		
		
	level.allies[ 0 ] disable_ai_color();
    level.allies[ 1 ] disable_ai_color();
		
    wait 0.3;

    vol = GetEnt( "def_ally_middle", "targetname" );
	level.allies[ 1 ] set_goal_pos( level.allies[ 1 ].origin );
	volrev = GetEnt( "defend_ally_split", "targetname");

	level.allies[ 0 ] SetGoalVolumeAuto( vol );
	level.allies[ 1 ] SetGoalVolumeAuto( volrev );
	
	thread defend_start_player_shield();
	
	wait 1;
    
	
	//thread maps\clockwork_audio::defend_combat();
	// make sure that we spawn in any stragglers.
	flag_set( "trickle_spawn_all" );
	
	thread handle_teargas_chatter();
	

    
    wait 8;
    thread handle_backfill();
    
    thread wave1_radio_chatter();
    
    // give the stragglers a good chance to spawn in.
	wave = get_ai_group_ai( "defend_group" );
    
    
    waittill_dead_or_dying( wave, wave.size - 3 );
    
    level.allies[ 0 ] notify( "stop_defend_movement" );
    level.allies[ 1 ] notify( "stop_defend_movement" );
    
    
//    thread add_dialogue_line( "Cipher", "Bank 1 almost down." );
//    waittill_dead_or_dying( wave, wave.size );
//    level.allies[ 0 ] enable_ai_color();
    flag_set( "def_wave1_done" );
//	flag_clear( "trickle_spawn_all" );
    
}

handle_accuracy()
{
	old_accuracy =	self.baseaccuracy;
	self set_baseaccuracy( 50 );
	self set_ignoreme( true );
	self.grenadeawareness=0;
	self.ignoreexplosionevents=true;
	self.ignorerandombulletdamage=true;
	self.ignoresuppression=true;
	self.disableBulletWhizbyReaction=true;

	self disable_pain();




	flag_wait( "defend_allies_smoke_thrown" );
	
	self.grenadeawareness=1;
	self.ignoreexplosionevents=false;
	self.ignorerandombulletdamage=false;
	self.ignoresuppression=false;
	self.disableBulletWhizbyReaction=false;

	self enable_pain();
	self set_baseaccuracy( old_accuracy );
	self set_ignoreme( false );
	safe_activate_trigger_with_targetname("def_allies_after_smoke");
	
}


setup_ai_for_end()
{
	axis = GetAIArray("axis");
	vol = GetEnt( "def_ground_middle_mid", "targetname");
	array_call( axis,::SetGoalVolumeAuto,vol);
	array_thread( axis, ::set_baseaccuracy, 0.01 );
	
	foreach( guy in axis)
	{
		guy.health = 1;
	}
	
	
	array_thread(level.allies,::handle_accuracy );
	
	check_vol = GetEnt("defend_upper_area", "targetname");
	on_upper = check_vol get_ai_touching_volume("axis");
	
	array_thread(on_upper,::set_ignoreall,true);
	wait 8;
	foreach( guy in on_upper)
	{
		if(IsDefined(guy) && IsAlive(guy))
		{
			guy set_ignoreall(false);
		}
	}
				 
	
}

defend_end()
{
	flag_wait( "defend_combat_finished" );
	neutralize_turret();
	level.allies[ 1 ] AllowedStances( "crouch", "prone", "stand" );
	level.allies[ 0 ] AllowedStances( "crouch", "prone", "stand" );
	array_thread(level.allies,::enable_ai_color );

	thread setup_ai_for_end();
	thread defend_exit_objective();
//	level.allies[ 1 ] StopAnimScripted();
	
	animate_to = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	animate_to notify( "stop_hacking" );
	waittillframeend;
	
	//level.allies[ 2 ] anim_stopanimscripted();
	

	root = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	root thread anim_single_solo(level.allies[ 2 ], "laptop_stand" );
	level.allies[ 2 ] gun_recall();

	
	
	
	wait 1;
	level.allies[0]  char_dialog_add_and_go( "clockwork_bkr_datasecure" );
	
	
	flag_wait( "defend_allies_smoke_thrown");
	//thread handle_defend_rappel();
	flag_set( "defend_finished" );
	wait 2;
	radio_dialog_add_and_go( "clockwork_diz_makingthecall" );
	
	wait 2;
	
	level.allies[0]  char_dialog_add_and_go( "clockwork_bkr_throughheregogo" );
	
	flag_wait( "defend_vault_room" );
	
	handle_defend_vault();
}

defend_exit_objective()
{
	defend_exit = obj( "defendexit" );
	
	obj_position = getstruct("defend_exit_obj","targetname");

	Objective_Add( defend_exit, "active" );
	Objective_Current( defend_exit );
	Objective_Position( defend_exit, obj_position.origin );
		
	flag_wait( "defend_vault_room" );
	
	Objective_Delete( defend_exit );

	// TODO: Close Vault Door behind player	
	// TODO: show a camera of enemies looking for the player
	
	flag_wait("inpos_player_elevator");
	/*
	// after vault door is closed 
	level.player radio_dialog_add_and_go("clockwork_rs4_nosign"); //No sign of intruders in lab 3.
	level.player radio_dialog_add_and_go("clockwork_rs4_lab3clear"); //Lab 3 is clear.
	level.player radio_dialog_add_and_go("clockwork_rs2_aretheyamericans");
	level.player radio_dialog_add_and_go("clockwork_rs4_russianuniforms");
	*/
	/*
	thread overheard_radio_chatter("clockwork_rs4_nosign", 1, "inpos_player_elevator");	//No sign of intruders in lab 3.
	thread overheard_radio_chatter("clockwork_rs4_lab3clear", 2, "inpos_player_elevator");	//Lab 3 is clear.
	thread overheard_radio_chatter("clockwork_rs2_aretheyamericans", 3, "inpos_player_elevator");	
	thread overheard_radio_chatter("clockwork_rs4_russianuniforms", 4, "inpos_player_elevator");	
*/
}

watch_smoke()
{
	level endon( "defend_player_left_area" );
	level endon( "got_smoke" );
	while( 1 )
	{
		level.player waittill ( "grenade_fire", grenade, weapon_name );
		if( string_starts_with( weapon_name, "smoke_" ) )
		{
			flag_set( "defend_smoke_thrown" );
			break;
		}
	}
}


waittill_ready_to_do_smoke()
{
	flag_wait( "defend_combat_finished" );  // should be set, but just to make sure the threads are synced
	
	level.allies[2] waittill_notify_or_timeout( "goal", 10 );
}


defend_do_smoke()
{
	
	level.allies[ 0 ] char_dialog_add_and_go( "clockwork_bkr_coverourexit" );
	
//	flag_wait( "pickup_backups" );
	
	level.player takeWeapon( "teargas_grenade" );
	level.player setOffhandSecondaryClass( "smoke" );

	level.player GiveWeapon( "smoke_grenade_american" );
//	thread add_dialogue_line( "Baker", "Rook, throw smoke to cover our exit." );
	
	//thread allies_throw_smoke();

	level.allies[ 0 ] thread char_dialog_add_and_go( "clockwork_bkr_popsomesmoke" );
	                      
	
	thread watch_smoke();
	
//	level.player ForceUseHintOn( "Press ^3[{+smoke}]^7 to throw Smoke grenade." );

	
	waittill_ready_to_do_smoke();
	flag_set("defend_smoke_thrown");
	thread watch_ally_throw_end_smoke(level.allies[2],"defend_smoke_onexit",true);
	
	level.player ForceUseHintOff();
	level notify( "got_smoke" );
	
		

	wait 2; // give the players time to explode.
	
	smoke_structs = getstructarray( "defend_smoke", "targetname" );
	
	smoke_count = 0;
	foreach(struct in smoke_structs)
	{
		//don't do as much smoke on the ps3.
		if ( IsDefined( level.ps3 ) && level.ps3 == true )
		{
			smoke_count++;
			
			if ( ( smoke_count % 2 ) )
			{
				continue;
			}
		}
		MagicGrenade( "smoke_grenade_american", ( struct.origin + ( 0, 0, 50 ) ), struct.origin, RandomFloatRange( 0.1, 1 ) );
		//MagicGrenade( "smoke_grenade_fast", ( struct.origin + ( 0, 0, 50 )  ), struct.origin, randomfloatrange( .1, 1 ) );
	}
	// after smoke has been popped
	wait 5;
	thread overheard_radio_chatter("clockwork_rs4_smaokegrenades", 1, "defend_vault_room");	// Can't see a thing, they've used smoke grenades.
	thread overheard_radio_chatter("clockwork_rs2_thermlstolab", 2, "defend_vault_room");	
	thread overheard_radio_chatter("clockwork_rs1_affirmative", 3, "defend_vault_room");	
}

neutralize_turret()
{
	if ( IsDefined( level.defend_sentry ) )
	{
		foreach ( turret in level.defend_sentry )
		{
			if ( IsDefined( turret ) )
			{
  				wait (0.05);
  				
				  				
				if ( IsDefined( turret.carrier ) )
				{
					turret common_scripts\_sentry::sentry_place_mode_reset();
				}
				
  				if ( IsDefined( turret.badplace_name ) )
					turret common_scripts\_sentry::sentry_badplace_delete();
				
				turret SetCanDamage( false );
				turret.ignoreMe = true;
				
				turret common_scripts\_sentry::SentryPowerOff();
				turret makeUnusable();

  				
				turret SetContents( 0 );
				
			}
		}
	}
	to_disable = GetEntArray( "defend_disable_on_finish", "script_noteworthy" );

	foreach( trig in to_disable )
	{
		trig trigger_off();
	}
}


handle_defend_vault()
{
	//IPrintLnBold( "Teleporting player- the defend will join up to here via another vault door and an elevator" );
	entrance_tunnel_door = GetEnt("entrance_tunnel_door", "targetname");
	entrance_tunnel_door RotateYaw(210,0.1);
}

open_vault_door()
{
	
	root = getstruct( "defend_vault_door_pos", "targetname" );

	door = GetEnt( "defend_exit_vault_door", "targetname" );
	door.animname = "vault_door";
	door assign_animtree();

	root thread anim_first_frame_solo( door, "defend_open" );
	
	blocker = GetEnt( "defend_exit_vault_door_block", "targetname" );
	blocker linkto(door);
	
	level waittill( "defend_open_door" );
	thread maps\clockwork_audio::defend_door_open();
//	thread add_dialogue_line( "Baker", "Cypher, time to open the rear door." );
	
	root anim_single_solo( door, "defend_open" );

	blocker ConnectPaths();

	waittill_allies_exit();

	blocker DisconnectPaths();
	
	thread maps\clockwork_audio::defend_door_close();
	root thread anim_single_solo(door, "defend_close");
	wait 11;
	if(!flag("player_out_of_defend"))
	{
		IPrintLnBold( &"CLOCKWORK_QUOTE_SEPARATED" );
		wait 1;
		MissionFailed();
		wait 20;

		
	}

}
//Ally throws smoke on the platform as the player runs past hime.

watch_ally_throw_end_smoke(ally,struct_name, wait_for_flag)
{
	if( IsDefined(wait_for_flag) && wait_for_flag )
		ally disable_ai_color();
	
	if( IsDefined(wait_for_flag) && wait_for_flag )
	{
		flag_wait_either( "ally_throw_smoke", "chaos_moving_to_elevator" );
		ally disable_ai_color();
	}

	ally.grenadeammo=1;
	ally.grenadeWeapon = "smoke_grenade_american";	
	ally.grenade_roll_end_struct =struct_name;
	
	ally anim_single_solo(ally,"grenade_throw_exit");
	if( IsDefined(wait_for_flag) && wait_for_flag )
	{
		ally disable_ai_color();
		flag_wait( "other_allies_post_vault" );
		root = getstruct( "defend_vault_door_pos", "targetname" );
		root anim_reach_solo(ally,"defend_close_door");
		root anim_single_solo(ally,"defend_close_door");
		ally enable_ai_color();
		flag_set( "cypher_defend_close_door" );
	}

}

//Called when Cypher throws the end grenade.
grenade_tossed( thrower )
{
	timer =2;
	if(thrower.animname == "cypher")
		timer = 0.5;

	grenade_roll_end_struct = getstruct( thrower.grenade_roll_end_struct, "targetname" );
	gren					= thrower MagicGrenade( thrower GetTagOrigin( "tag_weapon_left" ), grenade_roll_end_struct.origin, timer );
	if ( !IsDefined( gren ) )
	{
		grenade_roll_end_struct = getstruct( thrower.grenade_roll_end_struct + "2", "targetname" );
		if ( IsDefined( grenade_roll_end_struct ) )
			gren = thrower MagicGrenade( thrower GetTagOrigin( "tag_weapon_left" ), grenade_roll_end_struct.origin, timer );
	
	}
}

waittill_allies_exit()
{
	exit_trigger = GetEnt("exit_defend_room_trigger", "targetname");
	
	ally_count =0;// I have no idea why this was written to use pow
	while ( ally_count < 3 )
	{
		exit_trigger waittill("trigger", who);
		for (i=0; i < level.allies.size; i++)
		{
			ally = level.allies[i];
			if ( who == ally && !IsDefined(who.left_defend) )
			{
				who.left_defend = true;
				ally_count++;
				if(ally_count ==2)
					flag_set( "other_allies_post_vault" );
			}
		}
	}
	flag_set( "allies_finished_defend_anims");
	exit_trigger Delete();
}



/*
 * 
 * 
 * 
 * 
 * Utility code, not part of regular level flow or used multiple times.
 * 
 * 
 * 
 * 
 */ 

update_file_download()
{
	level endon( "defend_combat_finished" );
	

	level.hudTimerIndex = 20;
	level.timer = maps\_hud_util::get_countdown_hud( 0, 120 );
	level.timer.alignX = "right";
	level.timer SetPulseFX( 30, 900000, 700 );// something, decay start, decay duration
	level.timer.label = "File: ";
//	level.timer settenthstimer( download_time );
	
	named_file = 0;
	
	nf			  = [];
	nf[ nf.size ] = "contacts.bkp";
	nf[ nf.size ] = "zork.exe";
	nf[ nf.size ] = "keystroke.log";
	nf[ nf.size ] = "passwd.sys";
	nf[ nf.size ] = "mail.box";
	nf[ nf.size ] = "harlequin.prj";
	nf[ nf.size ] = "rog.txt";
	nf[ nf.size ] = "odin.bak";
	nf[ nf.size ] = "gloaming.ogg";
	nf[ nf.size ] = "bluprnt.zip";
	nf[ nf.size ] = "odin.plan";
	
	ext = [];
	ext[ext.size]= ".txt";
	ext[ext.size]= ".bak";
	ext[ext.size]= ".arch";
	ext[ext.size]= ".plan";
	ext[ext.size]= ".sys";
	ext[ext.size]= ".bak";
	ext[ext.size]= ".ogg";
	ext[ext.size]= ".log";
	ext[ext.size]= ".vis";
	ext[ext.size]= ".com";
	ext[ext.size]= ".rar";
	ext[ext.size]= ".arj";
	ext[ext.size]= ".tar";
	ext[ext.size]= ".prn";
	ext[ext.size]= ".ch3";
	ext[ext.size]= ".fngr";
	
	txt = []; ;txt[txt.size]="b";txt[txt.size]="ch";txt[txt.size]="d";txt[txt.size]="ten";txt[txt.size]="fl";txt[txt.size]="gr";txt[txt.size]="th";
	;txt[txt.size]="ph";txt[txt.size]="nk";txt[txt.size]="ck";txt[txt.size]="tr";txt[txt.size]="m";txt[txt.size]="n";txt[txt.size]="st";txt[txt.size]="p";txt[txt.size]="sn";
	;txt[txt.size]="rt";txt[txt.size]="t";txt[txt.size]="at";txt[txt.size]="un";txt[txt.size]="v";txt[txt.size]="w";txt[txt.size]="sh";txt[txt.size]="sl";txt[txt.size]="nd";
	joiner = [];
	joiner[joiner.size]="a";joiner[joiner.size]="ee";joiner[joiner.size]="o";joiner[joiner.size]="ou";joiner[joiner.size]="i";joiner[joiner.size]="u";joiner[joiner.size]="_";
	joiner[joiner.size]="ai";
	
	while(1)
	{
		if( named_file < nf.size && RandomInt(100) > 96)
		{
			level.timer SetText( nf[named_file]);
			named_file++;
			
			wait (RandomFloatRange(2,6));
		
		}
		else
		{
			name_len = RandomIntRange(3,5);
			out = "";
			for(i =0;i<name_len;i++)
			{
				if(!(i%2))
					out +=txt[RandomIntRange(0,txt.size)];
				else
					out +=joiner[RandomIntRange(0,joiner.size)];
			}
			out +=ext[RandomIntRange(0,ext.size)];
			level.timer SetText( out );
			
		}
		
		
		wait (RandomFloatRange(0.05,0.5));
	}

}

download_timer()
{
	door_open_time = 9;
	download_time = 150;
	
	// Extra time because we show the download bar much earlier now.
	download_time += 40;
	
	//This is the extra time we need to plant the additional mines we now have.
	download_time += 15;

    if(IsDefined( level.timer_override_check ))
    {
    	if(level.timer_override_check == 3 )
    		download_time = 45;
    		//download_time = 15;
    	else
	    	download_time = download_time - (40 * level.timer_override_check);
	
    }

	
	//Once the player's bag is on the table, the defend can run its course.
	flag_wait( "defend_timeto_hide_player_bag" );
	
	
    /#
    if( IsDefined( level.defend_quick ) )
		download_time = door_open_time + 15;  //debug testing.
    
    #/

	delayThread( download_time  ,::defend_do_smoke );

	level.download_timer = download_time;
	
	level notify("download_timer_started");
	thread update_file_download();
	/*
	level.hudTimerIndex = 20;
	level.timer = maps\_hud_util::get_countdown_hud( 0, 120 );
	level.timer.alignX = "right";
	level.timer SetPulseFX( 30, 900000, 700 );// something, decay start, decay duration
	level.timer.label = "Downloading: ";
	level.timer settenthstimer( download_time );
	*/
	level.start_time = gettime();
	level.download_time = download_time;
	thread download_progress_bar( level.start_time, download_time * 1000 );

	// -- timer expired --
	//if ( bUseTick == true )
	//thread timer_tick();
		
	level thread notify_delay( "defend_open_door", ( download_time - door_open_time ) );
	wait download_time;
	level.timer Destroy();
	level.timer = undefined;
	flag_set( "defend_combat_finished" );
	level notify( "stop_callout" );
	
	level.allies[ 0 ]notify			( "stop_defend_movement" );
	level.allies[ 0 ]enable_ai_color(  );
	level.allies[ 1 ]enable_ai_color(  );
	level.allies[ 1 ]notify			( "stop_defend_movement" );
	level.allies[ 2 ]enable_ai_color(  );
	
}

download_progress_bar( start_time, download_time )
{
	bar = maps\_hud_util::createClientProgressBar( level.player, -60 );
	bar maps\_hud_util::setPoint( "MIDDLERIGHT", undefined, 0, -60 );
/*	bar.alignX = "right";
	bar.bar.alignX = "right";
	bar.horzAlign = "right";
	bar.bar.horzAlign = "right";
*/	
	while ( GetTime() - start_time <= download_time )
	{
		bar maps\_hud_util::updateBar( ( GetTime() - start_time ) / download_time );
		wait 0.05;
	}
	
	bar.bar Destroy();
	bar Destroy();
}
	


handle_backfill()
{
	watch_backfill();
//	IPrintLnBold("Player left area- killing off backfill.");
	
	ai = get_ai_group_ai( "defend_backfill" );
	array_call( ai, ::Delete );
}

watch_backfill()
{
	level endon( "defend_player_left_area" );
	
	
	nodes = GetNodeArray( "defend_disable_stair_nodes", "targetname" );
	array_call( nodes, ::DisconnectNode);
	
	backfill_start_time = GetTime();
	
	waittime =[];
	waittime[0]=30;
	waittime[1]=25;
	waittime[2]=22;
	
	min_to_backfill = 3;
	
	tospawn=[];
	tospawn[0]=10;
	tospawn[1]=13;
	tospawn[2]=14;
	tospawn[3]=16;
	tospawn[4]=16;
	tospawn[5]=16;
	tospawn[6]=23;
	
	timeupdates = [];
	timeupdates[0] = backfill_start_time + 25000;
	timeupdates[timeupdates.size] = timeupdates[timeupdates.size-1] + 35000;
	timeupdates[timeupdates.size] = timeupdates[timeupdates.size-1] + 45000;
	timeupdates[timeupdates.size] = timeupdates[timeupdates.size-1] + 50000;
	timeupdates[timeupdates.size] = timeupdates[timeupdates.size-1] + 30000;
	timeupdates[timeupdates.size] = timeupdates[timeupdates.size-1] + 990000;
	timeupdates[timeupdates.size] = timeupdates[timeupdates.size-1] + 990000;
	
	currcheck = 0;
	
//	spawners = GetEntArray( "def_backfill_spawner", "script_noteworthy" );
	spawners = GetEntArray( "defend_atrium_backfill", "targetname" );
	
	while(1)
	{
		badguys = GetAIArray("axis");
//		IPrintLn("TTl axis: " + badguys.size);
		count = get_ai_group_sentient_count( "defend_backfill" );
		if( Flag( "trickle_spawn_all" ) )
			count += get_ai_group_sentient_count( "defend_group" );
		if( count < tospawn[currcheck] )
		{
			index = RandomInt( spawners.size );
			//check the spawner's volume to see if it has too many guys in!!
			if(flag( "defend_combat_finished" ))
				nextvol = GetEnt( "def_ground_middle_mid", "targetname");
			else				
				nextvol = GetEnt( spawners[index].target,"targetname");
			
			guy = undefined;
			
			max_in_vol = 4;
			if( IsDefined(nextvol.script_parameters) )
				max_in_vol = Int( nextvol.script_parameters);
			guys = nextvol get_ai_touching_volume("axis");
			if( guys.size < max_in_vol)
				guy	  = spawners[ index ] spawn_ai( true );
		//	else IPrintLnBold( "NO SPAWN: Volume " + nextvol.targetname + " has " + guys.size + " guys in it already.");
			
			if( IsDefined( guy ) )
			{
//				IPrintLnBold( "Spawning Backfill- count at " + count );
				// they could be spawning whilst the smoke is active, so be sure to set their accuracy low.				
				if( flag( "defend_combat_finished" ) )
					guy set_baseaccuracy( 0.2 );
				else 
					guy thread monitor_guy_moveup( waittime );
			}
		}
		if( GetTime() > timeupdates[currcheck] || IsDefined(level.override_check))
		{
			currcheck++;
			//This is just in case the player hangs around in the elevator room after the defend- you could run off the end of the array, and badness happened.
			if(currcheck >= tospawn.size )
			{
				currcheck = tospawn.size-1;
				timeupdates[currcheck] = GetTime() + 990000;
				
				
			}
			for( i=0; i< waittime.size;i++)
			{
				waittime[i] = waittime[i] * 0.85;
			}
			if(IsDefined(level.override_check))
			{
				if( level.override_check >=2)
				{
					thread blowdoors( "door_blow_north" );
					safe_delete_trigger_with_targetname( "defend_looking_north_trigger");
				}
				if( level.override_check >=3)
				{
					thread blowdoors( "door_blow_south" );
					safe_delete_trigger_with_targetname( "defend_looking_south_trigger");
				}
				currcheck = level.override_check;
				level.override_check = undefined;	
				
			}
			if(currcheck == 1 || currcheck == 2)
			{
		//		IPrintLnBold("watching left / right doors.");
				result = waittill_any_timeout( 10,"defend_looking_south_doors","defend_looking_north_doors");
				if(result== "timeout")
				{
					trig = GetEnt("defend_looking_north_trigger","targetname");
					if(IsDefined(trig))
						result = "defend_looking_north_doors";
					else
						result = "defend_looking_south_doors";
				}
				toblow = "door_blow_north";
				
				//open up the left / south side.
			//	lights = [];
				if( result == "defend_looking_south_doors" )
				{
					toblow = "door_blow_south";
					safe_delete_trigger_with_targetname( "defend_looking_south_trigger");
					guys = GetEntArray( "defend_south_backfill","targetname");
					level.allies[0] char_dialog_add_and_go("clockwork_mrk_theyvebreachedthedoors");
					//IPrintLnBold("They've breached the doors on the Left! Incoming on the upper left side.");
				//	lights = GetEntArray( "defend_southdoor_lights", "targetname" );
					
					
				}
				else //open up the the right / north side.
				{
					safe_delete_trigger_with_targetname( "defend_looking_north_trigger");
					level.allies[0] char_dialog_add_and_go( "clockwork_mrk_theyrecominginthrough");
					//IPrintLnBold("They're coming in through the doors on the RIGHT!");
					guys = GetEntArray( "defend_north_backfill","targetname");
					
				//	lights = GetEntArray( "defend_northdoor_lights", "targetname" );
					
				}
				//thread flicker_lights(lights);

				  
				thread blowdoors( toblow );
				spawners = array_combine(spawners,guys);
				
			}
			if(currcheck == 3)
			{
				level notify( "blow_fire_blocker" );
				//This will stop guys spawning for a bit- probably a good thing so we can get a load of guys to the player to add pressure.
				level waittill("fire_blocker_success");
				array_call( nodes, ::ConnectNode);

				if(	level.fire_blocker_blown == 0)
					spawners = GetEntArray( "defend_south_pressure","targetname");
			else
					spawners = GetEntArray( "defend_north_pressure","targetname");

			}


			else
			{
				level.moveup_doublespeed = true;
			}
			//IPrintLnBold( "CurrCheck: " + currcheck + ". Waittime0: " + waittime[0]);
			
				
		}
		if( count >= tospawn[currcheck] )
		{
			//IPrintLnBold("waiting 5- full set of guys.");
			wait 5;
		}
		else
		{
		  wait 1;
		}
			
			
	}
}

set_blow_doors_vis(visible)
{
	ents = GetEntArray( "door_blow_north","targetname");
	ents = array_combine(ents, GetEntArray("door_blow_south","targetname"));
	clip = GetEnt("blowdoors_playerclip", "targetname");
	if(visible)
	{
		array_call(ents,::Show);
		clip Solid();
	}
	else
	{
		array_call(ents,::Hide);
		clip NotSolid();
	}
}


blowdoors( doors )
{

	
	//hide the bsp / models.
	ents = GetEntArray( doors,"targetname");
	array_call(ents,::hide);
	//play fx.
	struct = getstruct( doors+"_struct","targetname");

	//thread play_sound_in_space ("clkw_scn_door_expl_source", struct.origin);
	thread maps\clockwork_audio::defend_door_explosion(struct.origin);
	
	MagicGrenade( "smoke_grenade_american", ( struct.origin  ), struct.origin+ ( 0, 0, -30 ),0 );

	//doorfx = SpawnFx(level._effect[ "Thermite_Explosion"],struct.origin,AnglesToForward( struct.angles),AnglesToUp( struct.angles));
	//TriggerFX(doorfx);
	PlayFX( getfx( "throwbot_explode" ), struct.origin,AnglesToForward( struct.angles),AnglesToUp( struct.angles));
	
	// Spawn the guys in.
	waittime =[];
	waittime[0]=45;
	waittime[1]=10;
	waittime[2]=10;
    dudes = array_spawn_targetname_allow_fail( doors+"_guys", true );
	
	array_thread( dudes, ::monitor_guy_moveup, waittime );

	
	//	ent = createOneshotEffect( "fx/explosions/wood_explosion_1" );

}
trickle_spawn( trickle_time, guys_targetname, wait_array, post_wait_time )
{
	level endon( "defend_player_left_area" );
	
	if( !IsDefined( post_wait_time ) )
		post_wait_time = 5;
	
	// grab all the spawners.
	spawners = GetEntArray( guys_targetname, "targetname" );
	num_spawners = spawners.size;
	//figure out average wait time.
	avg_time = trickle_time / num_spawners;
	
	array_spawn_function( spawners, ::setup_trickle_guy, wait_array );
	
	curr_spawn = 0;
	
	spawned_guys = [];
	
	while( curr_spawn < num_spawners )
	{

		if( !Flag( "trickle_spawn_all" ) )
		{
			wait (avg_time - (RandomFloat( avg_time) / 2) );
		}
		else
		{
			wait (post_wait_time - (RandomFloat( post_wait_time / 2) ) );
		}
		
		guy	= spawners[curr_spawn] spawn_ai( true );
		if ( IsDefined( guy ) )
		{
			spawned_guys[ spawned_guys.size ] = guy;
		}
		
		curr_spawn++;
	}
	
}

setup_trickle_guy( wait_array )
{
	self endon( "death" );
	flag_wait( "trickle_spawn_all" );
	
	if( IsDefined( self.script_noteworthy ) )
	{
		vol = GetEnt( self.script_noteworthy, "targetname" );
		if( IsDefined( vol ) )
		{
			self SetGoalVolumeAuto( vol );
			self monitor_guy_moveup( wait_array );
		}
	}
}

//amb_anim_goal( anim_to_play, struct_name, ender )
//{
//	self waittill( "goal" );
//	wait 0.2;
//	struct = getstruct( struct_name, "targetname" );
//	struct thread anim_generic_loop( self, anim_to_play, ender );
//	
//}

spawn_scientists()
{
	flag_wait( "defend_spawn_scientists" );
	scientists_spawners = GetEntArray( "defend_scientists", "targetname" );
	array_spawn_function( scientists_spawners, ::set_axis);
	
	array_thread( scientists_spawners, ::ambient_animate, true );
	
	wait 0.1;
	sprint_wait = get_ai_group_ai( "defend_scientist_sprint" );
	array_thread( sprint_wait, ::set_scientist_sprinting );
	level waittill( "defend_shoot_air" );
	flag_set("moveit_scientist");
}
set_axis()
{
	self.team = "axis";
}

set_scientist_sprinting()
{
	self clear_generic_idle_anim();
	level waittill( "defend_shoot_air" );
	wait (RandomFloatRange(0, 0.7));
	if( !IsDefined( self ) )
	{
		return;
	}
	self clear_run_anim();
	waittillframeend;
	runanim = "defend_run_scientist_"+ RandomIntRange(1,4);
	self set_run_anim( runanim );
	//self set_run_anim( "prague_bully_civ_run" );
}


	
	
	
		
monitor_guy_moveup( waittime )
{
	if ( !IsDefined( self ) )
		return;
	
	self endon( "death" );
	vol		  = self GetGoalVolume();
	startwait = 0;
	
	if( !IsDefined( vol ) )
		return;
	
	while( IsDefined( vol.script_noteworthy ) )
	{
		nextvol = GetEnt( vol.script_noteworthy, "targetname");
		
		to_wait = waittime[startwait] + RandomFloat( 5 ) - 2;
		if(level.moveup_doublespeed)
			to_wait = to_wait / 2;
		
		max_in_vol = 4;
		if( IsDefined(nextvol.script_parameters) )
			max_in_vol = Int( nextvol.script_parameters);
		
		while( 1)
		{
			wait to_wait;
			//This won't include guys on the way there.
			guys = nextvol get_ai_touching_volume("axis");
			if( guys.size < max_in_vol)
				break;
		//	IPrintLnBold( "NO MOVEUP: Volume " + nextvol.targetname + " has " + guys.size + " of " + max_in_vol + " guys in it already- from " + vol.targetname );
			
			to_wait = 3;
		}
		
		if(	flag( "defend_combat_finished" ))
		{
			flag_wait( "defend_smoke_thrown" );
			wait (RandomFloatRange(0,5));
		}
			
		startwait++;
		if(startwait>= waittime.size)
			startwait = waittime.size - 1;
		self SetGoalVolumeAuto( nextvol );
		vol = nextvol;
		
	}
	//Last volume, only allow us to stand.
	self AllowedStances( "stand" );
	
	
}


monitor_enemies_in_pods()
{
	thread watch_pod( "def_south_has_enemy", level.allies[ 2 ] );
//	thread watch_pod( "def_north_has_enemy", level.allies[ 1 ] );

}


cypher_defend_self()
{
	//Volumes that wave 1 uses.
	/*
	xxx defend_quickmove_upper_north
	def_upper_middle
	def_ground_middle
	defend_quickmove_atrium
	defend_quickmove_upper_south
	
	*/
	/*
	 "def_south_has_enemy", "script_flag" 
	 "defend_callout_urgent", "script_parameters"  has 2,  "def_ground_north_end", "targetname" and \a south one.
	 
	 "defend_end_center", "targetname"
	 "defend_end_center", "script_noteworthy" also has on it "defend_quickmove_mid_4", "targetname"
	 */ 
	level endon( "defend_combat_finished" );
	self endon("death");
	root = getstruct( "defend_player_drop_bag_location_mod", "targetname" );
	
//	shootroot = getstruct( "defend_player_drop_bag_location", "targetname" );
		
	leftvol = GetEnt( "cypher_shoot_left", "targetname" );
	rightvol = GetEnt( "cypher_shoot_right", "targetname" );
	
	while(1)
	{
		if(!level.defend_save_safe )
		{
			if( self.last_defend_time + 5000<  GetTime())
			{
				left = true;
				axis = leftvol get_ai_touching_volume( "axis" );
				if(axis.size == 0 )
				{
					wait(0.05);//this doesn't need to be done on the same frame.
					left = false;
					axis = rightvol get_ai_touching_volume( "axis" );
				}
				
				if(axis.size > 0 )
				{
				
					self.last_defend_time = GetTime();
					
					root notify( "stop_hacking" );
					waittillframeend;
					
					if(left)
							root thread anim_single_solo(self,"defend_shoot_left_cypher");
					else
							root thread anim_single_solo(self,"defend_shoot_right_cypher");
					
					self waittillmatch("single anim", "fire");	// miss
						
					if(IsAlive( axis[0] ) )
						MagicBullet( "usp_silencer",self GetTagOrigin( "tag_flash" ), axis[0] GetTagOrigin( "j_head" ) );
					 
					self waittillmatch("single anim","end");
		
					root thread anim_loop_solo( self, "laptop_sit_idle_calm", "stop_hacking" );
				}
			   
			}
			wait 0.1;
		}
		else
		wait 1;
	}
	
}

watch_pod( pod_flag, ally )
{
	watch_pod_blocker( pod_flag, ally );
	//we could end up quitting out of the blocker thread with can_save cleared- that would be really really bad for the rest of the level!
	flag_set( "can_save" );
}


watch_pod_blocker( pod_flag, ally )
{

	attack_vo			  = [];
	who					  = [];
	who[ attack_vo.size ] = 2;
	//"Cypher: Under Attack! Need support NOW!"
	attack_vo[ attack_vo.size ] = "clockwork_cyr_underattack";
	who		 [ attack_vo.size ] = 2;
	attack_vo[ attack_vo.size ] = "clockwork_cyr_tangoesonme";
	who		 [ attack_vo.size ] = 0;
	attack_vo[ attack_vo.size ] = "clockwork_bkr_takingfire";
	who		 [ attack_vo.size ] = 0;
	attack_vo[ attack_vo.size ] = "clockwork_bkr_getbackthere";
	who		 [ attack_vo.size ] = -1;
	attack_vo[ attack_vo.size ] = "clockwork_dz_gotcompany";
	who		 [ attack_vo.size ] = -1;
	attack_vo[ attack_vo.size ] = "clockwork_dz_protectcypher";
	who		 [ attack_vo.size ] = -1;
	attack_vo[ attack_vo.size ] = "clockwork_dz_commandplatform";
	/*
	 * //test code to play the lines.
	for( vo = 0; vo < attack_vo.size; vo++ )
	{
		if(who[vo] == -1)
		{
			radio_dialog_add_and_go( attack_vo[vo] );
		}
		else
		{
			level.allies[who[vo]]  char_dialog_add_and_go( attack_vo[vo]);
		}
	}

*/
	level endon( "defend_combat_finished" );
//	level endon( "stop_callout" );
	
//	ally endon( "death" );
	active			= 0;
	last_start_time = 0;
	ally.last_defend_time = GetTime();
	ally thread cypher_defend_self();
	while ( 1 )
	{
//wait(0.05);//		flag_wait( pod_flag ); 
		flag_wait( pod_flag ); 
		level.defend_save_safe = false;
		
		vol = GetEnt( "defend_last_stand", "targetname" );
		level.allies[ 0 ] SetGoalVolumeAuto( vol );
		level.allies[ 1 ] SetGoalVolumeAuto( vol );
		
		if ( GetTime() > ( last_start_time + 10000 ) )
		{
			vo = RandomIntRange( 0, attack_vo.size );
			if ( who[ vo ] == -1 )
			{
				radio_dialog_add_and_go( attack_vo[ vo ] );
			}
			else
			{
				level.allies[ who[ vo ]] char_dialog_add_and_go( attack_vo[ vo ] );
			}
			
		}
		local_time	  = GetTime();
		ally.ignoreme = false;
		
//		while ( 1)//flag( pod_flag ) )
		while ( flag( pod_flag ) )
		{
			//whilst the player is in the center of the area, have the AI prefer the player, otherwise let them shoot Cypher.
			if( !flag( "def_player_mid"))
			{
				flag_clear( "can_save" );
				
				ally.allowdeath=true;
				if ( isdefined( ally.magic_bullet_shield ) )
					ally stop_magic_bullet_shield();

			}
			else
			{
				ally.allowdeath=false;
				if ( !isdefined( ally.magic_bullet_shield ) )
					ally magic_bullet_shield();
			}
			if( !IsDefined(ally) || !IsAlive(ally))
			{
				quote = &"CLOCKWORK_QUOTE_KEEGAN_SHOT";
				if ( ally.script_friendname == "Baker" )
					quote = &"CLOCKWORK_QUOTE_BAKER_SHOT";
				else if ( ally.script_friendname == "Cypher" )
					quote = &"CLOCKWORK_QUOTE_CYPHER_SHOT";
				IPrintLnBold( quote );
				wait 1;
				MissionFailed();
				wait 20;
			}
			wait 0.05;
		}
		flag_set( "can_save" );
		
	    vol = GetEnt( "def_ally_middle", "targetname" );
		volrev = GetEnt( "defend_ally_split", "targetname");
		level.allies[ 0 ] SetGoalVolumeAuto( vol );
		level.allies[ 1 ] SetGoalVolumeAuto( volrev );

		ally.allowdeath=false;
		if ( !isdefined( ally.magic_bullet_shield ) )
			ally magic_bullet_shield();

		level.defend_save_safe = true;
		last_start_time = local_time;
		ally.ignoreme	= true;
	}
}


set_bag_objective_visibility( show_obj )
{
	level notify( "set_bag_objective_visibility" );
	level endon( "set_bag_objective_visibility" );
	
	obj = GetEnt( "defend_duffle_obj", "targetname" );
	trig = GetEnt( "defend_player_drop_bag_trigger", "targetname" );
	if(show_obj )
	{
		obj Show();
		bTriggerOn = false;
		while ( 1 )
		{
			if ( level.player GetStance() == "stand" && !bTriggerOn )
			{
				trig trigger_on();
				bTriggerOn = true;
			}
			else if ( level.player GetStance() != "stand" && bTriggerOn )
			{
				trig trigger_off();
				bTriggerOn = false;
			}
			wait 0.05;
		}
	}
	else
	{
		obj Hide();
		trig trigger_off();
	}
}

set_bags_invisible( )
{
	bag_names = [];
	
	
	bag_names[ bag_names.size ] = "defend_duffle_bag_proximity";
	bag_names[ bag_names.size ] = "defend_duffle_bag_shockwave";
	bag_names[ bag_names.size ] = "defend_duffle_bag_teargas";
	bag_names[ bag_names.size ] = "defend_duffle_bag_turret";
	
	//let each ally know what they are carrying.

	level.allies[ 0 ].bag_name = bag_names[ 0 ] ;
	level.allies[ 1 ].bag_name = bag_names[ 1 ] ;
	level.allies[ 2 ].bag_name = bag_names[ 2 ] ;

	foreach( bag_name in bag_names )
	{
		bag = GetEnt( bag_name, "targetname" );
		trig_name = bag_name + "_trigger";

		trig = GetEnt( trig_name, "targetname" );

		bag Hide();
		trig trigger_off();
	}
	// also hide the sentry objective model, mines etc that are on the table.
	level.sentry_obj = GetEnt( "defend_sentry_obj", "targetname" );
	level.sentry_obj Hide();
	level.sentry_obj NotSolid();
	
	level.bettys = [];
	for( betty = 0; betty <	NUM_BETTYS; betty++ )
	{
		level.bettys[ betty ] = GetEnt( "defend_duffel_betty" + (betty + 1), "targetname" );
		level.bettys[ betty ] Hide();
		level.bettys[ betty ] NotSolid();
	}
	
	level.shockwaves = [];
	for( shockwave = 0; shockwave <	NUM_SHOCKWAVES; shockwave++ )
	{
		level.shockwaves[ shockwave ] = GetEnt( "defend_duffel_shockwave" + (shockwave + 1), "targetname" );
		level.shockwaves[ shockwave ] Hide();
		level.shockwaves[ shockwave ] NotSolid();
	}
/*
	level.throwbots = [];
	for( throwbot = 0; throwbot <	NUM_THROWBOTS; throwbot++ )
	{
		level.throwbots[ throwbot ] = GetEnt( "defend_duffel_throwbot" + (throwbot + 1), "targetname" );
		level.throwbots[ throwbot ] Hide();
		level.throwbots[ throwbot ] NotSolid();
	}
*/
	level.teargas_bag = GetEntArray( "defend_duffel_teargas1", "targetname" );
	array_call( level.teargas_bag, ::Hide);
	array_call( level.teargas_bag, ::NotSolid);
			   
	
	
	                    
}
handle_animated_duffelbags()
{

	init_animated_dufflebags();

}


set_bag_visibility( show_bag )
{
	bag_names = [];
	
	if ( show_bag == "all" )
	{
		bag_names[ bag_names.size ] = "defend_duffle_bag_teargas";
		bag_names[ bag_names.size ] = "defend_duffle_bag_shockwave";
		bag_names[ bag_names.size ] = "defend_duffle_bag_turret";
		bag_names[ bag_names.size ] = "defend_duffle_bag_proximity";
	}
	else 
		bag_names[ bag_names.size ] = show_bag;
	foreach( bag_name in bag_names )
	{
		bag = GetEnt( bag_name, "targetname" );
		trig_name = bag_name + "_trigger";
		
		trig = GetEnt( trig_name, "targetname" );
		/*
		if( show_bag != "defend_duffle_bag_turret" )
		{
			offset = bag GetTagOrigin( "j_cog" )
		
			bag.origin = self GetTagOrigin( "j_cog" );
			bag.angles = self GetTagAngles( "j_cog" );
		}
		*/
//		bag Show();
		if( bag_names.size == 1 )
    		flag_wait( "defend_player_drop_bag" );
		if( show_bag != "defend_duffle_bag_turret" )
		trig trigger_on();
		
		if( bag_name == "defend_duffle_bag_proximity" )
		{
			array_call( level.bettys, ::Show );
			level.curr_betty = 0;
		}
		else if( bag_name == "defend_duffle_bag_teargas" )
		{
			array_call( level.teargas_bag, ::Show);
		}
		else if( bag_name == "defend_duffle_bag_shockwave" )
		{
			array_call( level.shockwaves, ::Show );
			level.curr_shockwave = 0;
		}
	}
}

//defend_ammo_cache()
//{	
//	wait 1.0;
//	
//	self MakeUsable();
//	self setCursorHint( "HINT_NOICON" );
//	self setHintString( &"CLOCKWORK_RESUPPLY" );
//	//ammo_cache show_world_icon( "waypoint_ammo_friendly", (0, 0, 48), 14, 14);
//	
//	while ( !flag( "defend_combat_finished" ) )
//	{
//		self waittill( "trigger", player );
//		weaponList = level.player GetWeaponsListAll();
//		foreach ( weaponName in weaponList )
//		{	
//			if ( weaponName != "fraggrenade" && (isSubStr( weaponName, "grenade" ) || ( GetSubStr( weaponName, 0, 2 ) == "gl" ) ) || weaponName == "thermobaric_mine" )
//			{
//				continue;
//			} 
//			
//			level.player giveMaxAmmo( weaponName );
//		}
//	}
//	
//	self MakeUnusable();
//	self setHintString( "" );
//}

/*
 * 
 * 
 * 
 *   G A D G E T   C O D E
 * 
 * 
 * 
 * 
 */
 
 listen_for_use_shockwave_duffle_bag()
{
/* 	wait 1.0;
	
	self MakeUsable();
	self setCursorHint( "HINT_NOICON" );
	self setHintString( &"CLOCKWORK_SHOCKWAVE" );
*/	
	count = 0;
	
	level.player thread watchShockwaves();
	
	while ( !flag( "defend_finished" ) )
	{
		ret = flag_wait_any_return( "get_shockwave", "defend_finished" );
		
		if ( ret == "defend_finished" )
		{
			continue;
		}
		
		if ( level.player HasWeapon( "shockwave" ) )
		{
			flag_clear( "get_shockwave" );
			continue;
		}
		
		thread maps\clockwork_audio::mines_grab();
		
		level.player GiveWeapon( "shockwave" );
		level.player SwitchToWeapon( "shockwave" );
		level.player SetActionSlot( 4, "weapon", "shockwave" );
		flag_set( "defend_used_duffel" );
//		flag_set( "defend_used_shockwave" );
		
		flag_clear( "get_shockwave" );
		
		if ( IsDefined( level.shockwaves[ count ] ))
		{
			level.shockwaves[ count ] Hide();
		}
		
		count += 1;
		
		if ( count >= 2 )
		{
			trigger = GetEnt( "defend_duffle_bag_shockwave_trigger", "targetname" );
			trigger Delete();		
			return;
		}
	}
	
	while ( IsDefined( level.shockwaves[ count ] ) && count < level.shockwaves.size )
	{
		level.shockwaves[ count ] SetModel( "weapon_electric_claymore" );
		
		count += 1;
	}
}

watchShockwaves()
{
	while ( !flag( "defend_finished" ) )
	{
		self waittill( "grenade_fire", shockwave, weapname );
		if ( weapname == "shockwave" )
		{
			shockwave.owner = self;
			shockwave thread shockwaveDetonation();
			shockwave thread playShockwaveEffects();
		}
	}
}

shockwaveDetonation()
{
	// wait until we settle
	self waittill( "missile_stuck" );

	detonateRadius = 192;// matches MP
	
	if ( isdefined( self.detonateRadius ) )
		detonateRadius = self.detonateRadius;
		
	damagearea = spawn( "trigger_radius", self.origin + ( 0, 0, 0 - detonateRadius ), 9, detonateRadius, detonateRadius * 2 );

	self thread shockwaveDeleteOnDeath( damagearea );

	if ( !isdefined( level.shockwaves ) )
		level.shockwaves = [];
	level.shockwaves = array_add( level.shockwaves, self );

	// limit the number of active shockwaves
	if ( !is_specialop() && level.shockwaves.size > 15 )
	{
		level.shockwaves[ 0 ] delete();
	}

	while ( 1 )
	{
		damagearea waittill( "trigger", ent );

		if ( isdefined( self.owner ) && ent == self.owner )
			continue;

		if ( isplayer( ent ) )
			continue;// no enemy shockwaves in SP.

		if ( ent damageConeTrace( self.origin, self ) > 0 )
		{
//			self playsound( "shockwave_activated_SP" );
			wait 0.4;
			
			ai_array = [];
			
			foreach ( ai in GetAIArray( get_enemy_team( self.owner.team ) ) )
			{
				if ( Distance2DSquared( self.origin, ai.origin ) < pow( detonateRadius * 2.0, 2.0 ) && VectorDot( AnglesToForward( self.angles ), VectorNormalize( ai.origin - self.origin ) ) > 0.13397 && ai DamageConeTrace( self.origin, self ) > 0 )
				{
					ai thread watch_for_shockwave_hit();
					ai_array[ ai_array.size ] = ai;
				}
			}
			
			self PlaySound( "shock_charge_detonate" );
			
			if ( isdefined( self.owner ) )
				self detonate( self.owner );
			else
				self detonate( undefined );
			
			wait 15;
			
			foreach ( ai in ai_array )
			{
				ai notify( "end_shockwave_watch" );
			}

			return;
		}
	}
}

watch_for_shockwave_hit()
{
	self endon( "death" );
	self endon( "end_shockwave_watch" );
	
	time = GetTime();
	
	self waittill( "damage", amount, attacker, direction, loc, damageType, model, tag, part, dflags, weapon );
	
	if ( GetTime() - time < 0.1 && weapon == "shockwave" )
	{
		time = GetTime();
		
		self endon( "damage" );
		
		self.shockwave_pain_anim_index = RandomIntRange( 1, 5 );
		
		while ( GetTime() - time < 10000 && IsDefined( self ) && IsAlive( self ) )
		{
			self PlaySound( "shock_charge" );
			PlayFXOnTag( getfx( "shockwave_shock" ), self, "tag_origin" );
			self maps\_anim::anim_generic( self, "shockwave_shock_" + self.shockwave_pain_anim_index );
		}
	}
}

playShockwaveEffects()
{
	self endon( "death" );

	self waittill( "missile_stuck" );

	PlayFXOnTag( getfx( "claymore_laser" ), self, "tag_fx" );
}

shockwaveDeleteOnDeath( ent )
{
	self waittill( "death" );
	
	level.shockwaves = array_remove_nokeys( level.shockwaves, self );
	wait .05;
	if ( isdefined( ent ) )
		ent delete();
}


listen_for_use_multi_turret()
{
    level.player NotifyOnPlayerCommand( "use_multi_turret", "+actionslot 4" );
    
    while ( 1 )
    {
        level.player waittill( "use_multi_turret" );
        
    //    level.player maps\_multiturret::tryUseRemoteTurret( "mg_turret" );
    }
}

listen_for_use_turret_duffle_bag()
{
	count = 0;
	thread watch_sentry_badplace();
	while ( !flag( "defend_finished" ) )
	{
		ret = flag_wait_any_return( "get_turret", "defend_finished" );
		
		if ( ret == "defend_finished" )
		{
			continue;
		}
		level.sentry_obj Hide();
		flag_set( "defend_used_duffel" );
		flag_set( "defend_used_sentry" );
		
		
		sentry = level.player common_scripts\_sentry::spawn_and_place_sentry( "sentry_smg", ( 0, 0, 0 ), ( 0, 0, 0 ), true );
		
		sentry UseBy( level.player );
		
		if(! IsDefined( level.defend_sentry ) )
		{
			level.defend_sentry = [];
		}
		level.defend_sentry[ level.defend_sentry.size ] = sentry;
		
		count++;
		flag_clear( "get_turret" );
		
		if( count >=1 )
		{
			trigger = GetEnt( "defend_duffle_bag_turret_trigger", "targetname" );
			trigger Delete();
			return;
		}
		
		level.player waittill ( "sentry_placement_finished" );
		level.sentry_obj Show();
	}
	
	if ( IsDefined( level.sentry_obj ) && !flag( "defend_used_sentry" ) )
	{
		level.sentry_obj SetModel( "weapon_sentry_smg_animated_collapsed" );
	}
}


listen_for_use_teargas_duffle_bag()
{
	while ( !flag( "defend_finished" ) )
	{
		ret = flag_wait_any_return( "get_teargas", "defend_finished" );
		
		if ( ret == "defend_finished" )
		{
			return;
		}
		
		thread maps\clockwork_audio::teargas_grab();
		
		level.player TakeWeapon( "flash_grenade" );
		level.player setOffhandSecondaryClass( "smoke" );
		level.player GiveWeapon( "teargas_grenade" );
//		level.player SetActionSlot( 4, "weapon", "teargas_grenade" );
		array_call( level.teargas_bag, ::Hide);
		
		flag_clear( "get_teargas" );
		flag_set( "defend_used_duffel" );
		
		trigger = GetEnt( "defend_duffle_bag_teargas_trigger", "targetname" );
		trigger Delete();		
		
		if ( level.player.force_hint == undefined )
		{
			level.player.force_hint = "teargas" ;
			level.player ForceUseHintOn( &"CLOCKWORK_PRMOPT_TEARGAS" );
			wait 3;
			level.player ForceUseHintOff();
			level.player.force_hint = undefined;

			level.player thread watch_remove_hint( "teargas" );
		}
		
		return;
	}
}

listen_for_use_proximity_duffle_bag()
{
	count = 0;
	
	while ( !flag( "defend_finished" ) )
	{
		ret = flag_wait_any_return( "get_proximity_mine", "defend_finished" );
		
		if ( ret == "defend_finished" )
		{
			continue;
		}
		
		if ( level.player HasWeapon( "thermobaric_mine" ) )
		{
			flag_clear( "get_proximity_mine" );
			continue;
		}
		
		thread maps\clockwork_audio::mines_grab();
		
		level.player GiveWeapon( "thermobaric_mine" );
		level.player SwitchToWeapon( "thermobaric_mine" );
		level.player SetActionSlot( 1, "weapon", "thermobaric_mine" );
		flag_set( "defend_used_duffel" );
		flag_set( "defend_used_mines" );
		
		
		thread listen_for_mine_layed();
		
		flag_clear( "get_proximity_mine" );
		
		if ( IsDefined( level.bettys[ count ] ))
		{
			level.bettys[ count ] Hide();
		}
		
		count += 1;
		
		if ( count >= 4 )
		{
			trigger = GetEnt( "defend_duffle_bag_proximity_trigger", "targetname" );
			trigger Delete();		
			return;
		}
	}
	
	while ( IsDefined( level.bettys[ count ] ) && count < level.bettys.size )
	{
		level.bettys[ count ] SetModel( "weapon_proximity_mine" );
		
		count += 1;
	}
}


		
watch_remove_hint( weapon_held )
{
	level notify( "watch_remove_hint" );
	level endon( "watch_remove_hint" );
	
	wait 2;	
	while ( self GetCurrentWeapon( ) == weapon_held && self GetAmmoCount( weapon_held ) > 0 )
	{
		wait 0.1;
	}

	self ForceUseHintOff();
	self.force_hint = undefined;
}


listen_for_mine_layed()
{
	level notify( "listen_for_mine_laying" );
	level endon( "listen_for_mine_laying" );
	
	level.mine_pickup_sound = 0;
	
	level.player NotifyOnPlayerCommand( "attack", "+attack" );
	if ( level.player.force_hint == undefined )
	{
		level.player.force_hint = "prox_mine" ;
		level.player ForceUseHintOn( &"CLOCKWORK_PROMPT_MINE" );
		level.player thread watch_remove_hint( "thermobaric_mine" );
		
	}
	while ( level.player HasWeapon( "thermobaric_mine" ) )
	{
		level.player waittill( "attack" );
		
		if ( level.player GetCurrentWeapon( ) == "thermobaric_mine" )
		{
			while ( 1 )
			{
				mines = GetEntArray( "grenade", "classname" );
				
				foreach ( mine in mines )
				{
					if ( mine.model == "weapon_proximity_mine" && !IsDefined( mine.is_setup) )
					{
						mine thread arm_mine();
						
						if (level.mine_pickup_sound < 7)
						{
							level.mine_pickup_sound ++;
							thread maps\clockwork_audio::mines_ready_to_throw();
						}
						
						break;
					}
				}
				
				wait 0.05;
			}
		}
	}	
}

arm_mine()
{
	self.is_setup = true;
	
	self waittill( "missile_stuck" );
	
	trace = bulletTrace( self.origin + (0, 0, 4), self.origin - (0, 0, 4), false, self );
	
	pos = trace[ "position" ];
	if ( trace[ "fraction" ] == 1 ) //wtf, stuck to somthing that trace didnt hit
	{	
		pos = GetGroundPosition( self.origin, 12, 0, 32);
		trace[ "normal" ] *= -1;
	}
	
	normal = vectornormalize( trace[ "normal" ] );
	plantAngles = vectortoangles( normal );
	plantAngles += ( 90, 0, 0 );
	
	mine = spawnMine( pos, plantAngles );
	
	if ( !IsDefined( level.clockwork_thermobaric_mines ) )
	{
		level.clockwork_thermobaric_mines = [];
	}
	
	level.clockwork_thermobaric_mines[ level.clockwork_thermobaric_mines.size ] = mine;
	
	self Delete();
	
	wait 1;

	// Arm the mine
	mine.trigger = Spawn( "trigger_radius", mine.origin, 73, 72, 12 );	// 73 = AI_AXIS, NOT PLAYER, TOUCH ONCE
	mine thread listen_for_mine_trigger();
}

spawnMine( origin, angles )
{
	if ( !isDefined( angles ) )
	{
		angles = (0, RandomFloat(360), 0);
	}

	model = "weapon_proximity_mine";
	mine = Spawn( "script_model", origin );
	mine.angles = angles;
	mine SetModel( model );
	mine.weaponName = "thermobaric_mine";

	mine thread mineDamageMonitor();
	
	return mine;
}

mineDamageMonitor()
{
	self endon( "mine_triggered" );

	self SetCanDamage( true );
	self.maxhealth = 100000;
	self.health = self.maxhealth;

	attacker = undefined;

	while ( 1 )
	{
		self waittill( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags, weapon );
		
		if ( !IsPlayer( attacker ) || IsDefined( weapon ) && weapon == "thermobaric_mine" )
		{
			continue;
		}

		break;
	}

	self notify( "mine_destroyed" );
	
	foreach ( ai in GetAIArray( "axis" ) )
	{
		if ( DistanceSquared( ai.origin, self.origin ) < 19600 ) 
		{
			ai thread mine_damage_increase();
		}
	}

	PlayFX( getfx( "throwbot_explode" ), self.origin );
	RadiusDamage( self.origin, 140, 10, 1, undefined, undefined, "thermobaric_mine" );
	
	level.clockwork_thermobaric_mines = array_remove( level.clockwork_thermobaric_mines, self );
	
	foreach ( mine in level.clockwork_thermobaric_mines )
	{
		if ( DistanceSquared( mine.origin, self.origin ) <= 140 * 140 )
		{
			mine notify( "mine_triggered" );
			mine notify( "mine_destroyed" );
			level.clockwork_thermobaric_mines = array_remove( level.clockwork_thermobaric_mines, mine );
			if ( IsDefined( mine.trigger ) )
			{
				mine.trigger Delete();
			}
			
			if ( IsDefined( mine ) )
			{
				mine Delete();
			}
		}
	}
	
	if ( IsDefined( self.trigger ) )
	{
		self.trigger Delete();
	}
	
	if ( IsDefined( self ) )
	{
		self Delete();
	}
}

listen_for_mine_trigger()
{
	self endon( "mine_destroyed" );
	
	self.trigger waittill( "trigger", ai );
	//The trigger can end up being removed before it is deleted.
/#
	if( !IsDefined( self.trigger ) )
	
	{
		IPrintLn( "Mine trigger- can't delete as already undefined." );
	}
	   
#/
		
	self notify( "mine_triggered" );

	if( IsDefined( self.trigger ) )
	{
		self.trigger Delete();
	}
	org = self.origin;
	PlayFX( getfx( "mine_explode" ), self.origin + ( 0, 0, 50 ) );
	thread maps\clockwork_audio::mine_explode(org);
	
	level.clockwork_thermobaric_mines = array_remove( level.clockwork_thermobaric_mines, self );
	
	mines_to_remove = [];
	
	foreach ( mine in level.clockwork_thermobaric_mines )
	{
		if ( DistanceSquared( mine.origin, self.origin ) <= 360 * 360 )
		{
			mine notify( "mine_triggered" );
			mine notify( "mine_destroyed" );
			level.clockwork_thermobaric_mines = array_remove( level.clockwork_thermobaric_mines, mine );
			mines_to_remove[ mines_to_remove.size ] = mine;
		}
	}
	
	wait 0.5;
	
	ai_array = GetAIArray( "axis" );
	foreach ( ai in ai_array )
	{
		if ( DistanceSquared( ai.origin, org ) < 32400 ) // 15 feet
		{
			ai flashBangStart( 5 );
		}
	}
	
	wait 1;
	
	foreach ( ai in GetAIArray( "axis" ) )
	{
		if ( DistanceSquared( ai.origin, org ) < 129600 ) 
		{
			ai thread mine_damage_increase();
		}
	}
	
	// Explode
	PlayFX( getfx( "throwbot_explode" ), org + ( 0, 0, 50 ) );
	RadiusDamage( org + ( 0, 0, 50 ), 360, 50, 1, undefined, undefined, "thermobaric_mine" );
	if ( IsDefined( self ) )
	{
		self Delete();
	}
	
	foreach ( mine in mines_to_remove )
	{
		if ( IsDefined( mine.trigger ) )
		{
			mine.trigger Delete();
		}
		
		if ( IsDefined( mine ) )
		{
			mine Delete();
		}
	}
}

mine_damage_increase()
{
	self endon( "death" );
	self endon( "stop_mine_damage_increase" );

	self waittill( "damage", amount, attacker, dir, loc, type, model, tag, part, dflags, weapon );
	
	if ( weapon == "thermobaric_mine" )
	{
		self DoDamage( amount * 10, loc, attacker );
	}
}

//Call init_fx_triggers somewhere near the start of your script.

// Each trigger MUST be a  trigger_multiple_flag_set_touching
// ALL triggers must have the "targetname" of "fx_trigger"
// ALL triggers must have "script_flag" of "fx_XX", where XX is the exploder num, say 320.

//init_fx_triggers()
//{
//	triggers = GetEntArray( "fx_trigger", "targetname");
//	IPrintLnBold( "Got " + triggers.size + " fx triggers.");
//	
//	array_thread( triggers, ::handle_exploder_trigger );
//}
//
//handle_exploder_trigger()
//{
//	tokens = StrTok( self.script_flag, "_" );
//	if(tokens.size != 2)
//	{
//		IPrintLnBold( "trigger with flag " + self.script_flag + " is incorrect fx trigger." );
//		return;
//	}
//	fx_num = tokens[1];
//	// If the activate exploder function expects a number instead of a string, use this line instead.
//	//fx_num = Int( tokens[1] );
//	while( 1 )
//	{
//		flag_wait( self.script_flag );
//		IPrintLnBold( "activating exploder " + fx_num );
//		activate_exploder( fx_num );
//		flag_waitopen( self.script_flag );
//		
//		IPrintLnBold( "Stopping exploder " + fx_num );
//		stop_exploder( fx_num );
//	}
//}
//
//defend_enemy_radio_chatter()
//{
//	level waittill("begin_defend_radio_chatter");
//	thread overheard_radio_chatter("clockwork_rs1_intruderstakenover", 1, "defend_player_drop_bag");
//	thread overheard_radio_chatter("clockwork_rs2_proceedtolab3", 2, "defend_player_drop_bag");	
//	thread overheard_radio_chatter("clockwork_rs2_deadlyforce", 3, "defend_player_drop_bag");	
//	// TODO: Good place for ally VO: "Get ready for a big fight"
//	
///*	
//	// random chatter
//	thread overheard_radio_chatter("clockwork_rs2_watchfire", 1, "");	//Watch your fire. That lab is full of sensitive equipment.
//	thread overheard_radio_chatter("clockwork_rs2_avoidservers", 2, "");	//Avoid shooting the servers if possible.
//	thread overheard_radio_chatter("clockwork_rs4_affirmative", 3, "");	
//	
//	// after the player is long gone.
//	thread overheard_radio_chatter("clockwork_rs4_nobodies", 1, "");	
//	thread overheard_radio_chatter("clockwork_rs2_howisthatpossible", 1, "");	
//	thread overheard_radio_chatter("clockwork_rs4_exitssealed", 1, "");	
//	thread overheard_radio_chatter("clockwork_rs2_findthem", 1, "");	
//*/
//}

wave1_radio_chatter()
{
	wait 5;
    // after wave 1 has been going for a while	
	thread overheard_radio_chatter("clockwork_rs2_idintruders", 1, "def_wave1_done");	
	thread overheard_radio_chatter("clockwork_rs2_onserverdeck", 2, "def_wave1_done");	
}

handle_autoturret_chatter()
{
	level endon( "defend_combat_finished" );
	
	flag_wait("def_wave1_done");
	// if the player has set up an autoturret in the middle
	thread overheard_radio_chatter("clockwork_rs4_autoturret", 1, "wave2_pre_dialog");	
	thread overheard_radio_chatter("clockwork_rs4_approachcwing", 2, "wave2_pre_dialog");	
}

handle_teargas_chatter()
{
	level endon( "defend_combat_finished" );

	gasvolume = GetEnt("teargas_flush_volume","targetname");

	gasvolume waittill("teargas_exploded"); 
	
	wait 5;
	// reaction to teargas
	level.player radio_dialog_add_and_go("clockwork_rs4_teargas");
}


//New stuff- make the playspace get smaller over time.

/*
phys_blocker_south_brush
phys_blocker_south_model

"fire_blocker_north_hurt", "targetname"
"fire_blocker_north_brush", "targetname"
"fire_blocker_north_body", "targetname"
"fire_blocker_north_jet", "targetname"






*/

setup_blockers()
{
	level.phys_blockers_brush[ 0 ] =	GetEntArray( "phys_blocker_north_brush", "targetname" );
	level.phys_blockers_model[ 0 ] =	GetEntArray( "phys_blocker_north_model", "targetname" );
	level.fire_blockers_brush[ 0 ] =	GetEntArray( "fire_blocker_north_brush", "targetname" );
	level.fire_blockers_hurt[ 0 ]  = GetEntArray( "fire_blocker_north_hurt", "targetname" );
	level.fire_blockers_jet[ 0 ]   =  getstructarray( "fire_blocker_north_jet", "targetname" );
	level.fire_blockers_body[ 0 ]  = getstructarray( "fire_blocker_north_body", "targetname" );
	level.fire_radiusdamage[ 0 ]   = getstruct( "fire_blocker_north_radiusdamage", "targetname" );
	

	
	level.phys_blockers_brush[ 1 ] =	GetEntArray( "phys_blocker_south_brush", "targetname" );
	level.phys_blockers_model[ 1 ] =	GetEntArray( "phys_blocker_south_model", "targetname" );
	level.fire_blockers_brush[ 1 ] =	GetEntArray( "fire_blocker_south_brush", "targetname" );
	level.fire_blockers_hurt[ 1 ]  = GetEntArray( "fire_blocker_south_hurt", "targetname" );
	level.fire_blockers_jet[ 1 ]   =  getstructarray( "fire_blocker_south_jet", "targetname" );
	level.fire_blockers_body[ 1 ]  = getstructarray( "fire_blocker_south_body", "targetname" );
	level.fire_radiusdamage[ 1 ]   = getstruct( "fire_blocker_south_radiusdamage", "targetname" );
	
	foreach( side in level.phys_blockers_brush )
	{
		foreach( brush in side )
		{
			brush ConnectPaths();
			brush Hide();
			brush NotSolid();
		}
	}
	foreach( side in level.phys_blockers_model )
	{
		foreach( mod in side )
		{
			mod Hide();
			mod NotSolid();
		}
	}

	foreach( side in level.fire_blockers_hurt )
	{
		foreach( hurt in side )
			hurt trigger_off();
	}
	foreach( side in level.fire_blockers_brush )
	{
		foreach( brush in side )
		{
			brush ConnectPaths();
			brush Hide();
			brush NotSolid();
		}
	}
	
	
}
handle_platform_blockers()
{

	level waittill( "blow_fire_blocker" );
	south_vol = GetEnt(	"def_ally_south", "targetname" );
	north_vol = GetEnt(	"def_ally_north", "targetname" );
	
	waittime = 15;
	
	end_time = GetTime() + (waittime *100);
	
	toblow = -1;
	
	//This handles setting off the fire / explosion blocker.
	while(1)
	{
		result = waittill_any_timeout(  (waittime+0.1), "defend_looking_south","defend_looking_north");
		player_in_south = IsPointInVolume( level.player.origin + (0,0,50), south_vol);
		if( end_time < GetTime() || result == "timeout" )
		{
			toblow =1;
			if( player_in_south )
			{
				toblow = 0;
			}
			thread handle_fire_blocker(toblow);
			break;
		}
		if(result == "defend_looking_south" )
		{
			if(!player_in_south)
			{
				toblow = 1;
				thread handle_fire_blocker(toblow);
				break;
				
			}
		}
		else
		{
			if(!IsPointInVolume( level.player.origin + (0,0,50), north_vol))
			{
				toblow = 0;
				thread handle_fire_blocker(toblow);
				break;
				
			}
			
		}
			
		wait 0.1;
	}
	level notify("fire_blocker_success");
	level.fire_blocker_blown = toblow;
	lookers = GetEntArray("defend_fireblocker_lookers", "targetname");
	array_call(lookers,::Delete);
		
	

	//This handles setting up the blockade side.
	level waittill("setup_blockade");
	
}


handle_fire_blocker( side )
{
	

	foreach( hurt in level.fire_blockers_hurt[side] )
	{
		hurt trigger_on();
	}

	// kill any enemies on the podiums near the fire.
	RadiusDamage( level.fire_radiusdamage[side].origin, 256, 200, 150);
	
	foreach( struct in level.fire_blockers_jet[side] )
	{
	
		PlayFX( getfx( "throwbot_explode" ), struct.origin,AnglesToForward( struct.angles),AnglesToUp( struct.angles));

	}
	foreach( struct in level.fire_blockers_body[side] )
	{
	
	
		PlayFX( getfx( "fx/fire/fire_gaz_clk" ), struct.origin,AnglesToForward( struct.angles),AnglesToUp( struct.angles));

	}
	struct = level.fire_blockers_jet[side][0];
	//thread play_sound_in_space ("clkw_scn_door_expl_source", struct.origin);
	thread maps\clockwork_audio::defend_fire(struct.origin);
	
	
	//add a bad place to give allies time to get out of the way, then remove the nodes etc.
	BadPlace_Cylinder("",4,level.fire_blockers_body[side][0].origin-(0,0,40),128,128,"allies","axis");
	
	wait 4;
	foreach( brush in level.fire_blockers_brush[side] )
	{
		brush show();
		brush Solid();
		if(IsDefined(brush.script_noteworthy) && brush.script_noteworthy == "hideme")
		{
			brush DisconnectPaths();
			brush hide();
			brush NotSolid();
		}
	}

}

handle_cypher_backups(  )
{
	level endon( "defend_player_left_area" );
	backups = [];
	glow_backups = [];
	for ( i = 1;i < 6;i++ )
	{
		backups[backups.size]=GetEnt( "cypher_backup_" + i, "targetname" );
		glow_backups[glow_backups.size]=GetEnt( "cypher_backup_obj_" + i, "targetname" );
		backups[backups.size -1] Hide();
		glow_backups[glow_backups.size -1] Hide();
	}
	
	
	curr_backup = 0;
	level waittill("download_timer_started");
	interval = (level.download_timer -10) / (backups.size +1);
	while( curr_backup < backups.size)
	{ 
		level waittill_notify_or_timeout("add_cypher_backup",interval);
		backups[curr_backup] Show();
		curr_backup++;
		
	}
	flag_wait( "defend_combat_finished" );
//	wait 0.1;
	safe_activate_trigger_with_targetname( "def_combat_finished" );
	waitframe();
	level.allies[2] disable_ai_color();
	
	thread	allies_throw_smoke();
	enable_trigger_with_targetname( "defend_pickup_backups_trigger" );
		curr_backup = 0;
	while( curr_backup < backups.size)
	{ 
		backups[curr_backup] hide(); 
		glow_backups[curr_backup] show(); 
		curr_backup++;
		
	}
	
	flag_wait( "pickup_backups");
	safe_disable_trigger_with_targetname("defend_pickup_backups_trigger" );
	
	curr_backup = 0;
	while( curr_backup < glow_backups.size)
	{ 
	//	backups[curr_backup] Stopglow();
		glow_backups[curr_backup] Hide();
		curr_backup++;
		
	}
	
//	allies_throw_smoke();
	
}






allies_throw_smoke()
{
	flag_wait( "defend_smoke_thrown" );
	//thread ally_grenade( level.allies[0] );
	thread watch_ally_throw_end_smoke( level.allies[0], "baker_smoke_toss" );
	wait 0.2;
	watch_ally_throw_end_smoke( level.allies[1], "keegan_smoke_toss" );
	if(IsDefined (level.allies[0].maxfaceenemydist))
		level.allies[0].old_maxfaceenemydist=level.allies[0].maxfaceenemydist;
	else
		level.allies[0].old_maxfaceenemydist=undefined;
	level.allies[0].maxfaceenemydist= 2048;
	if(IsDefined (level.allies[1].maxfaceenemydist))
		level.allies[1].old_maxfaceenemydist=level.allies[0].maxfaceenemydist;
	else
		level.allies[1].old_maxfaceenemydist=undefined;
	level.allies[1].maxfaceenemydist= 2048;
	flag_set( "defend_allies_smoke_thrown" );
	
	
	flag_wait("defend_player_left_area");
	level.allies[0].maxfaceenemydist= level.allies[0].old_maxfaceenemydist;
	level.allies[1].maxfaceenemydist= level.allies[1].old_maxfaceenemydist;
		
}

watch_sentry_badplace()
{
	level endon( "defend_combat_finished" );
	while(1)
	{
		level.player waittill( "sentry_placement_finished");
		//IPrintLnBold("sentry placement finished!");
		wait 0.3;
		if(IsDefined(level.defend_sentry[0].badplace_name))
		{
			call [[ level.badplace_delete_func ]]( level.defend_sentry[0].badplace_name );
			call [[ level.badplace_cylinder_func ]]( level.defend_sentry[0].badplace_name, 0, level.defend_sentry[0].origin, 32, 48, level.defend_sentry[0].team, "neutral" );
			
		}
	}
	
	
}

