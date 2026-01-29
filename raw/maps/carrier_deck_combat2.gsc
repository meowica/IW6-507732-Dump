#include maps\_utility;
#include common_scripts\utility;
#include animscripts\utility;
#include maps\_anim;
#include maps\_vehicle;
#include maps\carrier_code;

deck_combat2_pre_load()
{
	//--use this to init flags or precache items for an area.--
	
	//flag inits
	flag_init( "deck_combat2_finished" );
	flag_init( "clear_ladder" );
	flag_init( "hesh_vo_done" );
	
	//precache

	//init arrays/vars
	
	//hide ents
	level.c2_redshirt_spawn = getent( "c2_redshirt_spawn", "targetname" );
	level.c2_redshirt_spawn hide_entity();
	level.goodmove_kick = getent( "goodmove_kick", "targetname" );
	level.goodmove_kick hide_entity();
	level.c2_goodmove2 = getent( "c2_goodmove2", "targetname" );
	level.c2_goodmove2 hide_entity();
	
	//hide kill triggers and warnings
	towards_front_warning1 = getent( "dc2_warning1","targetname" );
	towards_front_warning1 hide_entity();
	
	towards_front_warning2 = getent( "dc2_warning2","targetname" );
	towards_front_warning2 hide_entity();
	
	towards_front_kill_trigger = getent( "dc2_kill_me","targetname" );
	towards_front_kill_trigger hide_entity();
	
	side_warning1 = getent( "dc2_warning1_side","targetname" );
	side_warning1 hide_entity();
	
	side_warning2 = getent( "dc2_warning2_side","targetname" );
	side_warning2 hide_entity();
	
	side_kill_trigger = getent( "dc2_kill_me_side","targetname" );
	side_kill_trigger hide_entity();
	
}

//*only* gets called from checkpoint/jumpTo
setup_deck_combat2()
{
	//--use this to setup checkpoint items, spawn allies, player, set flags, etc.--
	level.start_point = "deck_combat2";
	setup_common();
	
	spawn_allies();
	
	//no merrick for dc2
	level.merrick stop_magic_bullet_shield();
	level.merrick Delete();
	
	thread maps\carrier_vista::run_vista();
	
	set_sun_post_heli_ride();
	
	flag_set( "slow_intro_finished" );
	
	fork = GetEnt( "forklift3", "targetname" );
	fork hide_entity();
	fork_clip = GetEnt( "forklift3_clip", "targetname" );
	fork_clip hide_entity();	
	
	level.heli_ride_destroyer_sinking hide_entity();
	thread maps\carrier_defend_sparrow::get_ships_in_position_for_defend_sparrow( true );
}

//always gets called
begin_deck_combat2()
{
	//--use this to run your functions for an area or event.--
	level.goodmove_kick show_entity();
	level.c2_redshirt_spawn show_entity();
	level.c2_goodmove2 show_entity();
	
	level.aas show_entity();
	level.aas_clip show_entity();
	level.aas_tail show_entity();
	level.aas_tail_clip show_entity();
	level.deck_combat_tugger show_entity();
	level.deck_combat_tugger_clip show_entity();
	level.deck_combat_barrels show_entity();
	level.deck_combat_barrels_clip show_entity();
	
	//show kill triggers and warnings
	towards_front_warning1 = getent( "dc2_warning1","targetname" );
	towards_front_warning1 show_entity();
	
	towards_front_warning2 = getent( "dc2_warning2","targetname" );
	towards_front_warning2 show_entity();
	
	towards_front_kill_trigger = getent( "dc2_kill_me","targetname" );
	towards_front_kill_trigger show_entity();
	
	side_warning1 = getent( "dc2_warning1_side","targetname" );
	side_warning1 show_entity();
	
	side_warning2 = getent( "dc2_warning2_side","targetname" );
	side_warning2 show_entity();
	
	side_kill_trigger = getent( "dc2_kill_me_side","targetname" );
	side_kill_trigger show_entity();
	
	
	
	
	activate_trigger_with_targetname ("c2_redshirt_spawn");
	
	thread run_ambience();
	thread Kill_trigger_towards_front_of_ship();
	thread Kill_trigger_side_of_ship();
	thread run_fx();
	thread run_enemies();
	thread ladder_blocker_guys(); //guys that block ladder on sparrow launcher platform so you can't climb up once you drop down.
	thread after_crash();
	
	flag_wait( "hesh_jumpdown" );
	flag_set( "deck_combat2_finished" );	
	
	//hide kill triggers and warnings
	towards_front_warning1 = getent( "dc2_warning1","targetname" );
	towards_front_warning1 hide_entity();
	
	towards_front_warning2 = getent( "dc2_warning2","targetname" );
	towards_front_warning2 hide_entity();
	
	towards_front_kill_trigger = getent( "dc2_kill_me","targetname" );
	towards_front_kill_trigger hide_entity();
	
	side_warning1 = getent( "dc2_warning1_side","targetname" );
	side_warning1 hide_entity();
	
	side_warning2 = getent( "dc2_warning2_side","targetname" );
	side_warning2 hide_entity();
	
	side_kill_trigger = getent( "dc2_kill_me_side","targetname" );
	side_kill_trigger hide_entity();
	
	
	flag_wait( "deck_combat2_finished" );
	thread autosave_tactical();
	
}

after_crash()
{
	thread run_redshirt();
	thread run_hesh();
}

run_hesh()
{		
	deck_combat2_hesh = getstruct( "deck_combat2_hesh", "targetname" );
	level.hesh ForceTeleport( deck_combat2_hesh.origin, deck_combat2_hesh.angles );
	
	thread maps\carrier::obj_sparrow();
	
	//crouch cover position 1
	level.hesh disable_pain();
	level.hesh.ignoreall = true;
	level.hesh.ignoreme = true;
	level.hesh set_ignoreSuppression( true );
	level.hesh.ignorerandombulletdamage = true;
	level.hesh.disableBulletWhizbyReaction = true;
	
	thread hesh_vo();
	hesh_run_ref = getent("hesh_run_crouch_ref","targetname");
	hesh_run_ref anim_reach_solo( level.hesh, "run_into_cover" );
	hesh_run_ref thread anim_loop_solo( level.hesh, "run_into_cover", "stop_loop" );
		
	thread run_right_enemies();
	
	flag_wait_all( "hesh_moveup", "hesh_vo_done" );

	//Hesh: Ready... go!
	level.hesh thread smart_dialogue( "carrier_hsh_readygo" );			
	wait 1.5;
	
	hesh_run = GetNode( "hesh_jumpdown_wait", "targetname" );
	thread hesh_moveto_cover_2();

	//jumpdown
	flag_wait("hesh_jumpdown");
	level notify( "hesh_jumpdown" );
	
	level.hesh StopAnimScripted();
	hesh_run = getstruct( "hesh_jumpdown_wait", "targetname" );
	hesh_run notify( "stop_loop" );	
	hesh_jump = getnode("hesh_sparrow_location","targetname");
	level.hesh setgoalnode(hesh_jump); 		
}

hesh_moveto_cover_2()
{
	level endon( "hesh_jumpdown" );
	hesh_run_ref = getent("hesh_run_crouch_ref","targetname");
	level.hesh StopAnimScripted();
	hesh_run_ref notify( "stop_loop" );
	hesh_run = getstruct( "hesh_jumpdown_wait", "targetname" );
	level.hesh SetGoalPos( hesh_run.origin );
	level.hesh set_goalradius( 16 );
	level.hesh waittill( "goal" );
	hesh_run thread anim_loop_solo( level.hesh, "hesh_crouch", "stop_loop" );	
}

hesh_vo()
{
	//Triton: All call signs, additional hostile forces inbound.
	smart_radio_dialogue( "carrier_ttn_allcallsignsadditional" );	
	//Hesh: The Sparrow missiles are functional but the targeting is offline
	level.hesh smart_dialogue( "carrier_hsh_thesparrowmissilesare" );	
	//Hesh: We need to target them manually with the guidance lasers
	level.hesh smart_dialogue( "carrier_hsh_weneedtotarget" );	

	flag_set( "hesh_vo_done" );
}

run_redshirt()
{
	spawner = getent( "c2_redshirt_croucher", "targetname" );
	level.ally1 = spawner spawn_ai( true, false );
	level.ally1.animname = "generic";	
	level.ally1 endon("death");
	
	crouch_ref = getstruct( "redshirt_crouch_ref", "targetname" );
	crouch_ref thread anim_generic_loop( level.ally1, "redshirt_crouch", "stop_loop" );
	level.ally1.ignoreall = true;
	
	flag_wait_all( "hesh_moveup", "hesh_vo_done" );
	wait 1.5;	
	level.ally1 notify( "stop_loop" );
	level.ally1 StopAnimScripted();
	redshirt_die = getnode("redshirt_crouch_die","targetname");
	level.ally1 setgoalnode(redshirt_die);
	level.ally1.ignoreall = false;
	wait 2;
	level.ally1 thread maps\ss_util::fake_death_bullet();	
}

run_right_enemies()
{
	c2_right_enemies_vol = getent ( "c2_right_enemies_vol", "targetname" );
	ai = c2_right_enemies_vol get_ai_touching_volume( "axis" );
	waittill_dead_or_dying( ai, ai.size, 15 );
	wait 1;
	flag_set( "hesh_moveup" );	
}

run_fx()
{
	wait .01;
	
	burningjetfx= getstruct("c2_jet_burn","targetname");
	playfx( level._effect[ "burning_oil_slick_1" ], burningjetfx.origin);
    
    helifx= getstruct("c2_heli_burn","targetname");
    playfx( level._effect[ "fire_line_sm" ], helifx.origin);
    
    
    linefirefx = GetstructArray("c2_heli_burntrail","targetname");
	foreach( fx in linefirefx )
		{
			playfx( level._effect[ "fire_line_sm" ], fx.origin,(90,0,0));  
	    }
}

run_enemies()
{
	array_spawn_targetname_allow_fail("c2_right_enemies",true);	
	array_spawn_targetname_allow_fail("c2_left_enemies",true);	
}

ladder_blocker_guys()
{
	array_spawn_function_targetname( "ally_ladder_blocker_1", ::ladder_guy_anim );
	guys = array_spawn_targetname( "ally_ladder_blocker_1", true );
	
	flag_wait( "defend_sparrow_platform" );
	
	wait .2;
	
	//Ally Soldier 2: We’ve got incoming!
	guys[ 0 ] smart_dialogue( "carrier_gs2_wevegotincoming" );
}

ladder_guy_anim()
{
	self endon( "death" );
	
	self.animname = "generic";
	self.goalradius = 16;
	self.ignoreme = true;
	self.ignoreall = true;
	
	node = getnode( self.target, "targetname" );
	self thread anim_generic_loop( self, self.animation, "stop_loop" );
	
	flag_wait( "rog_reaction" );
	wait RandomFloatRange( 0, 1.0 );
	self StopAnimScripted();
	self notify( "stop_loop" );
	self thread anim_generic_loop( self, "corner_left_lookat_range_up", "stop_loop" );	
	
	flag_wait( "clear_ladder" );  //this will get set in carrier_deck_victory
	self StopAnimScripted();
	self notify( "stop_loop" );	
	self setGoalNode( node );
}

run_ambience()
{
	thread run_ambient_helis();
	wait 1;
	thread run_ambient_jets();
}

run_ambient_helis()
{
	array_spawn_function_noteworthy( "heli_ship_assault", ::heli_ship_assault );
	array_spawn_function_targetname( "dc2_enemy_heli_foreground", ::vehicle_randomly_explode_after_duration, 15, 10, 20 );
	array_spawn_function_targetname( "dc2_enemy_heli_ship_assault", ::vehicle_randomly_explode_after_duration, 15, 10, 20 );
	array_spawn_function_targetname( "dc2_enemy_heli_background", ::vehicle_randomly_explode_after_duration, 15, 10, 20 );
	array_spawn_function_targetname( "dc2_enemy_heli_foreground", ::sam_add_target );
	array_spawn_function_targetname( "dc2_enemy_heli_ship_assault", ::sam_add_target );
	array_spawn_function_targetname( "dc2_enemy_heli_background", ::sam_add_target );
	
	thread vehicles_loop_until_endon( "dc2_enemy_heli_foreground", "defend_sparrow_start", 5, 10 );
	wait 1;
	thread vehicles_loop_until_endon( "dc2_enemy_heli_ship_assault", "defend_sparrow_start", 5, 10 );
	
	wait 4;
	thread vehicles_loop_until_endon( "dc2_enemy_heli_background", "defend_sparrow_start", 5, 10 );
}

run_ambient_jets()
{
	array_spawn_function_targetname( "dc2_enemy_jet_01", ::vehicle_randomly_explode_after_duration, 15, 10, 20 );
	array_spawn_function_targetname( "dc2_enemy_jet_02", ::vehicle_randomly_explode_after_duration, 15, 10, 20 );
	array_spawn_function_targetname( "dc2_enemy_jet_03", ::vehicle_randomly_explode_after_duration, 15, 10, 20 );
	array_spawn_function_targetname( "dc2_enemy_jet_01", ::sam_add_target );
	array_spawn_function_targetname( "dc2_enemy_jet_02", ::sam_add_target );
	array_spawn_function_targetname( "dc2_enemy_jet_03", ::sam_add_target );	
	thread vehicles_loop_until_endon( "dc2_enemy_jet_01", "defend_sparrow_start", 3, 7 );
	wait 3;
	thread vehicles_loop_until_endon( "dc2_enemy_jet_02", "defend_sparrow_start", 3, 7 );
	wait 4;
	thread vehicles_loop_until_endon( "dc2_enemy_jet_03", "defend_sparrow_start", 8, 12 );
}

heli_ship_assault()
{
	self endon( "death" );
	if ( IsDefined( self.script_parameters ) )
	{
		self SetLookAtEnt( getent( self.script_parameters, "targetname" ) );
	}
}
/*------------------------------------------------------------------------*/
/*------------------ Activate Kill triggers for Player -------------------*/
/*------------------------------------------------------------------------*/

Kill_trigger_towards_front_of_ship()
{
	flag_wait("dc2_warning1_towardsfront");
	IPrintLnBold("Adam, where are you going?");
	
	flag_wait("dc2_warning2_towardsfront");
	IPrintLnBold("Get back here and fight now!");
	level.player play_sound_on_entity( "carrier_gs1_fastmoversincomiiiiing" );
	
	flag_wait("dc2_death_time_towardsfront");
	level.player play_sound_on_entity( "a10p_missile_launch"  );
	
	startshoot           = level.player.origin + (0,0,50);
    targetshoot           = level.player.origin;
    MagicBullet( "rpg_straight", startshoot, targetshoot);
    level.player Kill();

    
}

Kill_trigger_side_of_ship()
{
	flag_wait("dc2_warning_1_side");
	IPrintLnBold("Adam, where are you going?");
	
	
	flag_wait("dc2_warning_1_side");
	IPrintLnBold("Get back here and fight now!");
	level.player play_sound_on_entity( "carrier_gs1_fastmoversincomiiiiing" );
	
	flag_wait("dc2_death_time_side");
	level.player play_sound_on_entity( "a10p_missile_launch"  );
	
	startshoot           = level.player.origin + (0,0,50);
    targetshoot           = level.player.origin;
    MagicBullet( "rpg_straight", startshoot, targetshoot);
    level.player Kill();

}