#include maps\_utility;
#include common_scripts\utility;
#include maps\las_vegas_code;
#include maps\_anim;

casino_interrogation_dialog()
{
	level.ninja dialogue_queue( "vegas_kgn_heressomeadrenalineits" );	
}

casino_bar_dialog()
{	
	wait(2);
	level.leader dialogue_queue( "vegas_bkr_whatthehellhappened" );
	wait(.4);
	level.ninja dialogue_queue( "vegas_kgn_ourciacontactmust" );
	wait(.2);
	level.wounded_ai wounded_ai_dialog_queue( "vegas_diz_whothehelltold" );
	wait(.4);
	level.ninja dialogue_queue( "vegas_kgn_noclueletsjust" );
	
	flag_wait( "FLAG_start_human_shield_scene" );
	
	level.ninja thread radio_dialogue( "vegas_pmc1_gettheseboxesdownstairs" );
	
	wait(2.5);
	
	level.ninja thread radio_dialogue( "vegas_pmc1_assoonasthe" );
	
	wait(3);
	level.ninja dialogue_queue( "vegas_kgn_threeormoretangos" );
	wait(.2);
	level.ninja dialogue_queue( "vegas_kgn_everyoneready" );
	level.wounded_ai wounded_ai_dialog_queue( "vegas_diz_imgood" );
	level.leader dialogue_queue( "vegas_bkr_doit" );
	
	wait(3.2);
	
	if( isalive( level.hostage ) )
		level.hostage thread dialogue_queue( "vegas_pmc2_huh" );
	
	flag_wait( "DEATHFLAG_bar_enemies_dead" );
	
	wait(.8);
	level.ninja dialogue_queue( "vegas_kgn_roomclearnotime" );
	
	wait(1.5);
	//level.ninja dialogue_queue( "vegas_uhq_comein" );
	level.ninja.radio play_sound_on_entity( "vegas_uhq_comein" );
	wait(.2);
	level.wounded_ai wounded_ai_dialog_queue( "vegas_diz_hearthatenemyradio" );
	wait(.2);
	level.leader dialogue_queue( "vegas_bkr_wontbelonguntil" );
	wait(.2);
	//level.ninja dialogue_queue( "vegas_uhq_unioncomein" );
	level.ninja.radio play_sound_on_entity( "vegas_uhq_unioncomein" );
	wait( .6 );
	//level.ninja thread dialogue_queue( "vegas_uhq_noresponse" );
	level.ninja.radio play_sound_on_entity( "vegas_uhq_noresponse" );
	flag_set( "FLAG_casino_start_kitchen" );
	level.ninja delaythread( .4, ::dialogue_queue, "vegas_kgn_kitchennow" );
	//level.ninja dialogue_queue( "vegas_ds3_enroute" );
	level.ninja.radio play_sound_on_entity( "vegas_ds3_enroute" );
}

casino_kitchen_dialog()
{
	level waittill( "keegan_in_kitchen" );
	
	wait(.5);
	level.ninja dialogue_queue( "vegas_kgn_clear" );
	
	flag_wait( "TRIGFLAG_player_entering_kitchen" );
	
	level.leader dialogue_queue( "vegas_bkr_howdyougetin" );
	wait(.1);
	level.ninja thread dialogue_queue( "vegas_kgn_sandstormwasmakinga" );
	
	flag_wait( "FLAG_kitchen_event_start" );
	wait( .6 );
	
	level.wounded_ai thread wounded_ai_dialog_queue( "vegas_diz_coughs" );
	wait(2.2);
	level.leader thread dialogue_queue( "vegas_bkr_comeondiazget" );
	wait(2.2);
	level.ninja thread dialogue_queue( "vegas_pmc1_alphawithmethrough" );
	wait(3.5);
	level.ninja dialogue_queue( "vegas_kgn_patrolcomingthisway" );
	
	wait( 2 );
	level.ninja thread dialogue_queue( "vegas_kgn_hitthefloor" );
	
	level waittill( "start_kitchen_ambush_scene" );
	
	wait(.4);
	level.ninja thread dialogue_queue( "vegas_kgn_staydown" );
	
	wait(7);
	level.ninja thread dialogue_queue( "vegas_kgn_easy_2" );
	
	level waittill( "walkers_done" );
	
	level.leader thread dialogue_queue( "vegas_bkr_patrolpassedmoveout" );
	
	flag_wait( "FLAG_casino_start_hallway" );
	
	level.ninja.radio play_sound_on_entity( "vegas_pmc1_uniondiciplefiveis" );
//	level.leader thread dialogue_queue( "vegas_bkr_thatsthecueuse" );
	wait( 3 );
	level.ninja.radio play_sound_on_entity( "vegas_uhq_allunitsthisis" );
}

casino_atrium_dialog()
{
//	flag_wait( "player_in_hallway_bathroom" );
//	

//	level.ninja.radio play_sound_on_entity( "vegas_pmc1_uniondiciplefiveis" );
//	level.leader thread dialogue_queue( "vegas_bkr_thatsthecueuse" );
//	wait( 3 );
//	level.ninja.radio play_sound_on_entity( "vegas_uhq_allunitsthisis" );
	add_dialogue_line( "Keegan", "More of em, stay down. " );

	wait 1.5;	
	//flag_wait( "FLAG_gt_at_the_gate" );
	
	add_dialogue_line( "Keegan", " look, aboves us, let em pass. Cmon, keep movin" );
	wait 1.5;
//	add_dialogue_line( "Keegan", " There's too many of them." );
	
//	flag_set( "FLAG_start_atrium_combat" );
	
//	delaycall( 5, ::iprintlnbold, "DIAZ : THEY'RE COMING DOWN ON ROPES!" );
	
}

casino_gamblingroom_dialogue()
{
//	getent( "ambush_trig", "targetname" ) waittill( "trigger" );
	wait 5;
	add_dialogue_line( "Keegan", "More, find a place to hide" );
	wait 2;
	add_dialogue_line( "Keegan", "No more runnin" );
	wait 1;
	add_dialogue_line( "Keegan", "When they get close, take em out!" );
	
	wait 4;
	// when the ai is in position 
	add_dialogue_line( "Keegan", "let em get close and finish them" );
	wait 5;
	add_dialogue_line( "Keegan", "Now" );
	

	
//	add_dialogue_line( "Keegan", " look, aboves us, let em pass. Cmon, keep movin" );
//	level waittill( "stealth_event_notify" );
	
//	delayThread( randomintrange( 1, 3 ), ::radio_dialogue, "vegas_uhq_alotofactivity" );
}

wounded_ai_dialog_queue( msg )
{
	self notify( "dialog_started" );
	
	self dialogue_queue( msg );
	
	self notify( "dialog_ended" );
}