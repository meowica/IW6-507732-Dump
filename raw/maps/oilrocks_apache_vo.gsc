#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\oilrocks_code;
#include maps\oilrocks_apache_code;
#include maps\_hud_util;
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //
//
//		Mission VO
//
// -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. //

apache_mission_vo_until_flag( line_array, line_delay, flag_stop, dialogue_start_delay )
{
	if ( flag( flag_stop ) )
		return undefined;
	
	level endon( flag_stop );
	
	if ( IsDefined( dialogue_start_delay ) && dialogue_start_delay > 0 )
	{
		wait dialogue_start_delay;
	}
	
	foreach ( idx, vo_line in line_array )
	{
		smart_radio_dialogue( vo_line );
		
		wait line_delay;
	}
	
	return true;
}

apache_mission_vo_think( vo_function )
{
	level endon( "FLAG_apache_crashing" );
	[[ vo_function ]]();
}

apache_mission_vo_player_crashing()
{
	level endon( "FLAG_transition_to_infantry_slamzoom_start" );
	
	flag_wait( "FLAG_apache_crashing" );
	
	radio_dialogue_stop();
	
	// JC-ToDo: V.O. for the chopper crash.
}

apache_mission_vo_tutorial()
{
	wait 6.0;
	
	//Mongoose Pilot: Alright, 100 meter spread.
	smart_radio_dialogue( "oilrocks_mgp_100meter" );
	
	flag_wait( "introscreen_complete" );
	
	//Mongoose Pilot: We're about 3 clicks from our destination.  Keep it low and tight.
	smart_radio_dialogue( "oilrocks_mgp_3clicks" );
	
	flag_wait( "FLAG_apache_tut_fly_quarter" );
	
	//Viper Passenger: You think after 2 tours they would retire this chopper.
	smart_radio_dialogue( "oilrocks_vps_2tours" );
	
	wait 0.25;
	
	//Viper Gunner: Keep it down man, you'll hurt her feelings.
	smart_radio_dialogue( "oilrocks_vpg_keepitdown" );
	
	//Viper Pilot: *laughs*
	smart_radio_dialogue( "oilrocks_vpp_laugh" );
	
	wait 0.6;
	
	smart_radio_dialogue( "oilrocks_pyp_focusclose" );
	
	flag_wait( "FLAG_apache_tut_fly_half" );
	
	//Baker: Remember we need Ceaser alive.
	smart_radio_dialogue( "oilrocks_bkr_ceasaralive" );
	
	wait 1.6;
	
	//Viper Gunner: How do you plan on dragging this asshole outta' here?
	smart_radio_dialogue( "oilrocks_vpg_youplan" );
	//Baker: Just get us on the ground. We'll handle the rest.
	smart_radio_dialogue( "oilrocks_bkr_handlerest" );
	
	flag_wait( "FLAG_apache_tut_fly_targets" );
	
	//Viper Gunner: Looks like they sent a welcoming party.
	smart_radio_dialogue( "oilrocks_vpg_welcomingparty" );
	//Mongoose Pilot: Then let's give them a show. Weapons hot gentlemen.
	smart_radio_dialogue( "oilrocks_mgp_givethem" );
}

apache_mission_vo_factory()
{
	
	//Mongoose Pilot: Light 'em up!
	smart_radio_dialogue( "oilrocks_mgp_lightemup" );
	
	wait 0.5;
	
	//Viper Pilot: Sweeping up right side.
	smart_radio_dialogue( "oilrocks_vpp_sweepingup" );
	
	// Combat chatter that ends when the factory is destroyed
	apache_mission_vo_factory_combat();
	
	wait 2.5;
	
	flag_wait( "FLAG_apache_factory_destroyed" );
	
	//Mongoose Pilot: Building is clear, deploy ground team.
	smart_radio_dialogue( "oilrocks_mgp_deployground" );
	
	flag_wait_or_timeout( "FLAG_apache_factory_finished", 3.0 );
	
	//Mongoose Gunner: Caesar appears to be on the move.
	smart_radio_dialogue( "oilrocks_mgg_onthemove" );
}

apache_mission_vo_factory_combat()
{
	if ( flag( "FLAG_apache_factory_destroyed" ) )
		return;
	
	level endon( "FLAG_apache_factory_destroyed" );
	
	flag_wait( "FLAG_apache_factory_allies_close" );
	wait 1.0;
	
	//Mongoose Gunner: Two enemy birds lifting off.
	smart_radio_dialogue( "oilrocks_mgg_enemybirds" );
	//Mongoose Pilot: I see them, missiles out.
	smart_radio_dialogue( "oilrocks_mgp_missilesout" );
	
	flag_wait( "FLAG_apache_factory_hind_take_off_dead" );
	wait 0.75;
	
	//Python Gunner: Direct hits!
	smart_radio_dialogue( "oilrocks_pyg_directhits" );
	
	wait 1.0;
	
	//Mongoose Pilot: Got a ping on Caesar, he's inside the factory.
	smart_radio_dialogue( "oilrocks_mgp_gotaping" );
	
	wait 1.75;
	//Baker: Clear that roof and get us on the ground.
	smart_radio_dialogue( "oilrocks_bkr_clearthatroof" );
	//Mongoose Pilot: You heard the man, let’s soften this place up.
	smart_radio_dialogue( "oilrocks_mgp_heardtheman" );
	
	flag_wait( "FLAG_apache_factory_player_close" );
	
	wait 1.5;
	//Python Gunner: We’ve got hostile RPG fire coming from the building top.
	smart_radio_dialogue( "oilrocks_pyg_hostilerpg" );
	
	wait 2.0;
	//Mongoose Pilot: Keep circling and use your mini-guns.
	smart_radio_dialogue( "oilrocks_mgp_keepcircling" );
	
	wait 3.0;

	//Viper Gunner: Careful, we don’t want to take this whole place down.
	smart_radio_dialogue( "oilrocks_vpg_wholeplacedown" );
}

apache_mission_vo_chase()
{
	//Viper Gunner: Eyes on the target - back of the factory in a Gun Boat.  Heading to the main island.
	smart_radio_dialogue( "oilrocks_vpg_onthetarget" );
	//Mongoose Pilot: Abort all infantry deployment, apaches stay on that gunboat.
	smart_radio_dialogue( "oilrocks_mgp_abortallinfantry" );
	
	wait 0.5;
	
	//Viper Gunner: Taking fire.
	smart_radio_dialogue( "oilrocks_vpg_takingfire" );
	
	wait 0.6;
	
	//Mongoose Pilot: All apaches engage but do not hit Caesar's boat.
	smart_radio_dialogue( "oilrocks_mgp_allapachesengagebut" );
	
	wait 1.0;
	
	//Viper Pilot: They’ve got a lock on us.
	smart_radio_dialogue( "oilrocks_vpp_gotalock" );
	
	wait 0.25;
	
	//Mongoose Gunner: More enemy ground vehicles and water craft ahead.
	smart_radio_dialogue( "oilrocks_mgg_moreenemygroundvehicles" );
	
	flag_wait( "FLAG_apache_chase_caesar_close_to_island" );
	
	//Baker: Caesar just entered the main island. We need to go after him!
	smart_radio_dialogue( "oilrocks_bkr_everyminute" );
	//Mongoose Pilot: I don't know, looks a little hot down there, sir…
	smart_radio_dialogue( "oilrocks_mgp_hotdownthere" );
	
	flag_set( "FLAG_apache_chase_vo_done" );
}

apache_mission_vo_antiair()
{
	//Viper Gunner: Eyes on the target - back of the factory in a Gun Boat.  Heading to the main island.
	smart_radio_dialogue( "oilrocks_vpg_onthetarget" );
	
	wait 0.5;
	
	//Viper Gunner: Taking fire.
	smart_radio_dialogue( "oilrocks_vpg_takingfire" );
	
	wait 3.0;
	
	//Viper Pilot: They’ve got a lock on us.
	smart_radio_dialogue( "oilrocks_vpp_gotalock" );
	
	wait 0.25;
	
	//Mongoose Gunner: More enemy ground vehicles and water craft ahead.
	smart_radio_dialogue( "oilrocks_mgg_moreenemygroundvehicles" );
	
	//Mongoose Pilot: I don't know, looks a little hot down there, sir…
	smart_radio_dialogue( "oilrocks_mgp_hotdownthere" );
	
	flag_set( "FLAG_apache_chase_vo_done" );
}


apache_mission_vo_escort()
{
										//   value 					     key 			      level_flag 								    
	array_spawn_function_flag_on_death_all( "apache_escort_enc_2_jeep", "script_noteworthy", "FLAG_apache_escort_allies_enc_02_jeeps_dead" );
	array_spawn_function_flag_on_death_all( "apache_escort_enc_4_jeep", "script_noteworthy", "FLAG_apache_escort_allies_enc_04_jeeps_dead" );
	
	flag_wait( "FLAG_apache_chase_finished" );
	
	//Baker: Just put us down as close as you can.
	smart_radio_dialogue( "oilrocks_bkr_putusdown" );
	
	//Mongoose Pilot: It's your call, all apaches protect that Blackhawk.
	smart_radio_dialogue( "oilrocks_mgp_yourcall" );
	
	flag_wait( "FLAG_apache_escort_blackhawk_dropping_off" );
	
	thread add_dialogue_line( "Diaz", "Large infantry force headed to the LZ." );
	wait 1.25;
	//Mongoose Gunner: I see 'em.
	smart_radio_dialogue( "oilrocks_mgg_iseeem" );
	
	wait 1.0;
	
	//Baker: Bravo team touching down now, heading to the bridge.
	smart_radio_dialogue( "oilrocks_bkr_touchingdown" );
	
	flag_wait( "FLAG_apache_escort_allies_enc_start_01" );
	
	if ( !flag( "FLAG_apache_escort_allies_enc_end_01" ) )
	{
		//Baker: Engaging, get some clearing fire down here.
		smart_radio_dialogue( "oilrocks_bkr_clearingfire" );
	}
	
	//Mongoose Pilot: Switching to mini-gun.
	smart_radio_dialogue( "oilrocks_mgp_switchtomini" );
	
	flag_wait( "FLAG_apache_escort_allies_enc_end_01" );
	
	//Baker: Bridge clear, moving up.
	smart_radio_dialogue( "oilrocks_bkr_bridgeclear" );
	
	flag_wait( "FLAG_apache_escort_allies_enc_start_02" );
	
	flag_wait_or_timeout( "FLAG_apache_escort_allies_enc_02_jeeps_dead", 4.0 );
	
	if ( !flag( "FLAG_apache_escort_allies_enc_02_jeeps_dead" ) )
	{
		//Baker: Enemy vehicles pinning us in. Take 'em out!
		//Diaz: This cover's not going to last much longer!
		//Rorke: That jeep's 50 cal is starting to come through!
		pinned_lines = [ "oilrocks_bkr_pinningus", "oilrocks_diz_thiscoversnotgoing", "oilrocks_rke_thatjeeps50cal" ];
		
		finished = apache_mission_vo_until_flag( pinned_lines, 2.75, "FLAG_apache_escort_allies_enc_02_jeeps_dead" );
		if ( IsDefined( finished ) && finished )
		{
			//Diaz: I'm hit! I'm hit bad.
			smart_radio_dialogue( "oilrocks_diz_imhitimhit" );
			//"Protect the Infantry"
			//Baker: Diaz is down, I repeat Diaz is down.
			mission_fail( &"OILROCKS_QUOTE_ESCORT_INFANTRY_DIED", "oilrocks_bkr_diazisdowni" );
		}
	}
	
	flag_wait( "FLAG_apache_escort_allies_enc_end_02" );
	
	radio_dialogue_stop();
	//Baker: Exiting bridge, moving to the building foundation.
	smart_radio_dialogue( "oilrocks_bkr_exitingbridge" );
	//Mongoose Pilot: Apaches keep peppering the area.
	smart_radio_dialogue( "oilrocks_mgp_apacheskeeppepperingthe" );
	
	flag_wait( "FLAG_apache_escort_allies_enc_start_03" );
	//Baker: Enemies are closing in. Get some missiles on that refinery!
	smart_radio_dialogue( "oilrocks_bkr_closingin" );
	
	flag_wait( "FLAG_apache_escort_allies_enc_end_03" );
	//Baker: Good enough!  We're heading for that ramp!  Move!
	smart_radio_dialogue( "oilrocks_bkr_goodenough" );
	wait 1.0;
	//Mongoose Pilot: Two more jeeps incoming, take them out.
	smart_radio_dialogue( "oilrocks_mgp_morejeeps" );
	
	flag_wait( "FLAG_apache_escort_allies_enc_start_04" );
	
	//Baker: Get these jeeps off of us now!
	//Baker: Air support, we're pinned!
	//Diaz: We can't hold against that 50 cal fire much longer.
	pinned_lines = [ "oilrocks_bkr_jeepsoff", "oilrocks_bkr_airsupportwerepinned", "oilrocks_diz_wecantholdagainst" ];
	
	finished = apache_mission_vo_until_flag( pinned_lines, 2.75, "FLAG_apache_escort_allies_enc_04_jeeps_dead", 4.5 );
	if ( IsDefined( finished ) && finished )
	{
		//Diaz: Shit, Rorke is down!
		smart_radio_dialogue( "oilrocks_diz_shitrorkeisdown" );
		//"Protect the Infantry"
		//Baker: Rorke, rorke answer me!
		mission_fail( &"OILROCKS_QUOTE_ESCORT_INFANTRY_DIED", "oilrocks_bkr_rorkerorkeanswerme" );
	}
	
	flag_wait( "FLAG_apache_escort_allies_enc_end_04" );
	
	radio_dialogue_stop();
	//Baker: We have Caesar on the heart beat monitor. He’s one hundred meters ahead, in the parking garage.
	smart_radio_dialogue( "oilrocks_bkr_heartbeat" );
	
	wait 0.25;
	
	//Mongoose Pilot: Apaches clear the rest of the refinery and get Bravo team inside.
	smart_radio_dialogue( "oilrocks_mgp_cleartherest" );
	
	flag_wait_or_timeout( "FLAG_apache_escort_allies_enc_end_05", 1.5 );
	if ( !flag( "FLAG_apache_escort_allies_enc_end_05" ) )
	{
		//Baker: Taking heavy fire, get these guys off us.
		smart_radio_dialogue( "oilrocks_bkr_heavyfire" );
		
		flag_wait( "FLAG_apache_escort_allies_enc_end_05" );
	}
	
	//Baker: We’re going for it, give us cover fire!
	smart_radio_dialogue( "oilrocks_bkr_goingforit" );
	
	flag_wait( "FLAG_apache_escort_allies_inside" );
	
	//Baker: Bravo team inside, fifty meters to Caesar and closing.
	smart_radio_dialogue( "oilrocks_bkr_fiftymeters" );
	//Mongoose Pilot: Sounds good Bravo team, we’ll cover the rooftops.
	smart_radio_dialogue( "oilrocks_mgp_soundsgood" );
}

apache_mission_vo_chopper()
{
	wait 1.0;
	
	//Viper Gunner: We’ve got company Mongoose. Three enemy birds inbound.
	smart_radio_dialogue( "oilrocks_vpg_gotcompany" );
	
	wait 0.8;
	
	//Mongoose Pilot: Apaches fan out and ready your flares.
	smart_radio_dialogue( "oilrocks_mgp_fanout" );
	
	wait 1.5;
	
	//Mongoose Pilot: Let's take it to 'em.
	smart_radio_dialogue( "oilrocks_mgp_takeit" );
	
	flag_set( "FLAG_apache_chopper_vo_take_it_done" );
	
	flag_wait( "FLAG_apache_chopper_hind_destroyed_two" );
	
	wait 1.0;
	
	//Viper Gunner: Three more hinds coming in fast, watch your backs.
	smart_radio_dialogue( "oilrocks_vpg_threemore" );
	
	flag_wait( "FLAG_apache_chopper_hind_remaining_three" );
	
	wait 1.0;
	
	//Baker: We're still tracking Caesar, Mongoose how are things in the air?
	smart_radio_dialogue( "oilrocks_bkr_werestilltrackingcaesar" );
	
	wait 0.5;
	
	//Mongoose Pilot: Don't worry about us Baker. Just nail that scumbag.
	smart_radio_dialogue( "oilrocks_mgp_dontworryaboutus" );
	
	flag_wait( "FLAG_apache_chopper_hind_remaining_one" );

	
	flag_set( "FLAG_apache_chopper_vo_done" );
}

apache_mission_vo_finale()
{
	wait 1.0;
	
	//Mongoose Gunner: Looks like we stirred up the hornets’ nest again.
	smart_radio_dialogue( "oilrocks_mgg_lookslikewestirred" );
}
